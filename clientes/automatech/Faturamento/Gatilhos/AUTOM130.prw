#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM130.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/07/2012                                                          *
// Objetivo..: Gatilho que verifica se a TES é de Transferência. Caso for, busca o *
//             custo médio do produto e o grava como preço unitário.               *
// Parãmetros: < _Tipo     > - Indica de onde foi chamado o gatilho                *
//                             1 - Pedido de Venda                                 *
//                             2 - Documento de Entrada                            *
//                             3 - Proposta Comercial                              *
//             < _Operacao > - Em que operação está                                *
//                             O - Tipo de Operação                                *                    
//                             T - Campo TES                                       *
//                             U - Preço Unitário                                  *
//**********************************************************************************

// Função que define a Window
User Function AUTOM130( _Tipo, _Operacao)

   Local cSql      := ""
   Local nPosQua   := 0
   Local nPosOpe   := 0
   Local nPosTES   := 0
   Local nPosPro   := 0
   Local nPosUni   := 0
   Local nPosTab   := 0
   Local nPosTot   := 0
   Local cConteudo := ""
   Local nContar   := 0
   Local lExiste   := .F.

   U_AUTOM628("AUTOM130")

   If _Tipo <> 1 .AND. _Tipo <> 2 .AND. _Tipo <> 3
      Return 0
   Endif   

   Do Case
      Case _Tipo == 1 // Pedido de Venda
           nPosPro := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})    
           nPosQua := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })    
           nPosUni := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN" })    
           nPosTab := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT" })    
           nPosTot := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"  })          
           nPosOpe := aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPER"   })
           nPosTES := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"    })      
      Case _Tipo == 2 // Nota Fiscal de Entrada
           nPosPro := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"    })
           nPosQua := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"  })
           nPosUni := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAUT" })    
           nPosTab := 0
           nPosTot := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"  })          
           nPosTo2 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"  })          
           nPosOpe := aScan(aHeader,{|x| AllTrim(x[2])=="D1_OPER"   })
           nPosTES := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"    })      
      Case _Tipo == 3 // Proposta Comercial
           nPosPro := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRODUT"})
           nPosQua := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_QTDVEN"})
           nPosUni := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRCVEN"})    
           nPosTab := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRCTAB"})    
           nPosTot := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_TOTAL" })          
           nPosOpe := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_OPER"  })
           nPosTES := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_TES"   })      
   EndCase

   // Zera o campo preço unitário do pedido de venda para evitar que seja dado desconto na impressão da nota fiscal
   If _Tipo == 2
   Else
      aCols[n, nPosTab] := 0
   Endif

   // Guarda o conteúdo do campo para retorno
   Do Case
      Case _Operacao == "O"
           cConteudo := aCols[n, nPosOpe]
      Case _Operacao == "T"
           cConteudo := aCols[n, nPosTes]
      Case _Operacao == "U"
           cConteudo := aCols[n, nPosUni]
   EndCase

   // Se chamada foi feita da pré-nota de entrada, retorna com o valor informado
   If funname() == "MATA140"
      Return cConteudo
   Endif   

   // Verifica se o TES é referente a TES de Demonstração.
   // Caso for, o custo para a Demonstração.
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TESD" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )

      lExiste := .F.
      
      For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TESD, "|", 1)
          If Alltrim(aCols[n, nPosTes]) == Alltrim(U_P_CORTA(T_PARAMETROS->ZZ4_TESD, "|", nContar))
             lExiste := .T.
             Exit
          Endif
      Next nContar    

      If lExiste

         // Pesquisa o custo médio para o produto informado
         If Select("T_CUSTO") > 0
            T_CUSTO->( dbCloseArea() )
         EndIf
         
         cSql := "SELECT B2_FILIAL, "
         cSql += "       B2_COD   , "
         cSql += "       B2_LOCAL , "
         cSql += "       B2_CM1     "
         cSql += "  FROM " + RetSqlName("SB2")
         cSql += " WHERE B2_FILIAL  = '" + Alltrim(cFilAnt)           + "'"
         cSql += "   AND B2_COD     = '" + Alltrim(aCols[n, nPosPro]) + "'"
         cSql += "   AND B2_LOCAL   = '01'"
         cSql += "   AND D_E_L_E_T_ = ''  "
   
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSTO", .T., .T. )

         If T_CUSTO->( EOF() )
            MsgAlert("Produto informado não possui custo médio para esta operação.")
            aCols[n, nPosUni] := 0
            aCols[n, nPosTot] := 0
            Return cConteudo
         Endif
         aCols[n, nPosUni] := Round((T_CUSTO->B2_CM1 / 2),2)
   	     aCols[n, nPosTot] := aCols[n, nPosQua] * aCols[n, nPosUni]

         If _Operacao == "U"
            cConteudo := Round((T_CUSTO->B2_CM1 / 2),2)
         Endif   

         If _Tipo == 2
            // Valor Unitário
            aCols[n, nPosTot] := Round((T_CUSTO->B2_CM1 / 2),2)
            // Valor Total Virtual
            aCols[n, nPosUni] := aCols[n, nPosQua] * aCols[n, nPosTot]
            // Valor Total da nota Fiscal
            aCols[n, nPosTo2] := aCols[n, nPosQua] * aCols[n, nPosTot]
         Endif   

         Return cConteudo
      
      Endif

   Endif

   // Pesquisa na tabela SF4 se a TES pesquisada é referente a Transferência entre Filiais
   If Select("T_TRANSFE") > 0
      T_TRANSFE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F4_CODIGO,"
   cSql += "       F4_TRANFIL"
   cSql += "  FROM " + RetSqlName("SF4")
   cSql += " WHERE F4_CODIGO  = '" + aCols[n, nPosTes] + "'"
   cSql += "   AND D_E_L_E_T_ = ''
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSFE", .T., .T. )

   If T_TRANSFE->( EOF() )
      Return cConteudo
   Endif
      
   If Alltrim(T_TRANSFE->F4_TRANFIL) == "1"
      
      // Pesquisa o custo médio para o produto informado
      If Select("T_CUSTO") > 0
         T_CUSTO->( dbCloseArea() )
      EndIf
         
      cSql := "SELECT B2_FILIAL, "
      cSql += "       B2_COD   , "
      cSql += "       B2_LOCAL , "
      cSql += "       B2_CM1     "
      cSql += "  FROM " + RetSqlName("SB2")
      cSql += " WHERE B2_FILIAL  = '" + Alltrim(cFilAnt)           + "'"
      cSql += "   AND B2_COD     = '" + Alltrim(aCols[n, nPosPro]) + "'"
      cSql += "   AND B2_LOCAL   = '01'"
      cSql += "   AND D_E_L_E_T_ = ''  "
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSTO", .T., .T. )

      If T_CUSTO->( EOF() )
         MsgAlert("Produto informado não possui custo médio para esta operação.")
         aCols[n, nPosUni] := 0
         aCols[n, nPosTot] := 0
         Return cConteudo
      Endif

      aCols[n, nPosUni] := Round(T_CUSTO->B2_CM1,2)  
      aCols[n, nPosTot] := aCols[n, nPosQua] * aCols[n, nPosUni]

      If _Operacao == "U"
         cConteudo := Round(T_CUSTO->B2_CM1,2)
      Endif   

      If _Tipo == 2
         // Valor Unitário
         aCols[n, nPosTot] := Round(T_CUSTO->B2_CM1,2)
         // Valor Total Virtual
         aCols[n, nPosUni] := aCols[n, nPosQua] * aCols[n, nPosTot]
         // Valor Total da nota Fiscal
         aCols[n, nPosTo2] := aCols[n, nPosQua] * aCols[n, nPosTot]
      Endif   
      
   Endif

Return cConteudo