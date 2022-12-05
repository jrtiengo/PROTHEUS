#include "Protheus.ch"                             
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR80.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/12/2012                                                          *
// Objetivo..: Programa que gera o Tracker da Oportunidade em forma de tree View.  *
// Parâmetros: _Filial - Código da Filial do Documento                             *
//             _Codigo - Código do Documento a ser pesquisado                      *
//             _Tipo   - Tipo de documento a ser pesquisado                        *
//                       1 - Indica Tracker de Oportunidade                        *
//                       2 - Indica Tracker de Pedidos de Venda                    *
//**********************************************************************************

//utilização da função DbTree
User Function AUTOMR80( _Filial, _Codigo, _Tipo)

   Local _aAreaAD1 := AB1->(GetArea()) 
   Local _aAreaAD2 := AB2->(GetArea()) 
   Local _aAreaAD3 := AB3->(GetArea()) 
   Local _aAreaAD4 := AB4->(GetArea()) 
   Local _aAreaAD9 := AB9->(GetArea()) 
   Local _aAreaADJ := ADJ->(GetArea()) 

   Local cBmp1         := "PMSEDT3" 
   Local cBmp2         := "PMSDOC" 
   Local cSql          := ""
   Local cOportunidade := ""
   Local cNomeCliente  := ""
   Local cNomeCondicao := ""
   Local cNomeV01      := ""
   Local cNomeV02      := ""
   Local cPedido       := ""
   Local cProducao     := ""
   Local aPedidos      := {}
   Local _Direita      := 4
   Local _Esquerda     := 0
   Local nContar       := 0
   Local cClausulaIn   := ""
   Local __Codigo      := _Codigo

   Private cCadastro := "Tracker Automatech" 
   Private oDlg 
   Private oDBTree 

   U_AUTOM628("AUTOMR80")

   // Caso for um Tracker de Pedido, descobre o número da Oportunidade.
   // Isso serve para o resto do programa não tenha que ser alterado.
   If _Tipo == 2

      If Select("T_BUSCACOD") > 0
         T_BUSCACOD->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT A.C6_FILIAL   , "  
      cSql += "       A.R_E_C_D_E_L_, "
      cSql += "       A.C6_NUMORC   , "
      cSql += "       B.CJ_NROPOR     "
      cSql += "  FROM " + RetSqlName("SC6") + " A, "
      cSql += "       " + RetSqlName("SCJ") + " B  "
      cSql += " WHERE A.C6_NUM       = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND A.C6_FILIAL    = '" + Alltrim(_Filial) + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = 0"
      cSql += "   AND B.CJ_NUM + B.CJ_FILIAL = SUBSTRING(A.C6_NUMORC,01,06) + A.C6_FILIAL"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BUSCACOD", .T., .T. )

      _Codigo := T_BUSCACOD->CJ_NROPOR

      // Se não retornou nada, gera o treeview com os dado do pedido de venda
      If Empty(Alltrim(_Codigo))

         // Pesquisa os Produtos do Pedido de Venda para alimentar o Grid de Produtos da Tela.
         If Select("T_PRODUTOS") > 0
            T_PRODUTOS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.C6_PRODUTO,"
         cSql += "       B.B1_DESC   ,"
         cSql += "       B.B1_DAUX   ,"
         cSql += "       A.C6_QTDVEN ,"
         cSql += "       A.C6_PRCVEN ,"
         cSql += "       A.C6_VALOR  ,"
         cSql += "       A.C6_NOTA   ,"
         cSql += "       A.C6_DATFAT ,"
         cSql += "       C.C5_CLIENTE,"
         cSql += "       C.C5_LOJACLI,"
         cSql += "       D.A1_NOME   ,"
         cSql += "       C.C5_VEND1  ,"
         cSql += "       C.C5_CONDPAG,"
         cSql += "       E.E4_DESCRI  "
         cSql += "  FROM " + RetSqlName("SC6") + " A, "
         cSql += "       " + RetSqlName("SB1") + " B, "
         cSql += "       " + RetSqlName("SC5") + " C, "
         cSql += "       " + RetSqlName("SA1") + " D, "
         cSql += "       " + RetSqlName("SE4") + " E  "
         cSql += " WHERE A.C6_NUM          = '" + Alltrim(__Codigo) + "'"
         cSql += "   AND A.C6_FILIAL       = '" + Alltrim(_Filial)  + "'"
         cSql += "   AND A.C6_PRODUTO      = B.B1_COD    "
         cSql += "   AND A.D_E_L_E_T_      = ''          "
         cSql += "   AND A.C6_NUM          = C.C5_NUM    "
         cSql += "   AND A.C6_FILIAL       = C.C5_FILIAL "
         cSql += "   AND C.D_E_L_E_T_      = ''          "
         cSql += "   AND C.C5_CLIENTE      = D.A1_COD    "
         cSql += "   AND C.C5_LOJACLI      = D.A1_LOJA   "
         cSql += "   AND C.C5_CONDPAG      = E.E4_CODIGO "
         cSql += "   AND E.D_E_L_E_T_      = ''          "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

         If !T_PRODUTOS->( Eof() )

            If !Empty(Alltrim(T_PRODUTOS->C5_VEND1))
               If Select("T_VENDEDOR") > 0
                  T_VENDEDOR->( dbCloseArea() )
               EndIf
               cSql := ""
               cSql := "SELECT A3_NOME FROM " + RetSqlName("SA3") + " WHERE A3_COD = '" + Alltrim(T_PRODUTOS->C5_VEND1) + "' AND D_E_L_E_T_ = ''"
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
               cNomeVende = T_VENDEDOR->A3_NOME
            Else
               cNomeVende = ""
            Endif   

            cPedido       := __Codigo
            cProducao     := ""
            cEmissao      := T_PRODUTOS->C6_DATFAT
            cNomeCliente  := T_PRODUTOS->A1_NOME
            cNomeCondicao := T_PRODUTOS->E4_DESCRI
            cNomeV01      := cNomeVende
            cNomeV02      := ""
            corcamento    := ""
            cproposta     := ""
            
            While !T_PRODUTOS->( EOF() )

  	           aAdd( aPedidos, { cPedido                             ,;
     	                         cProducao                           ,;
     	                         T_PRODUTOS->C6_NOTA                 ,;
         	                     Substr(T_PRODUTOS->C6_PRODUTO,01,06),;
     	                         Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),;
         	                     STR(T_PRODUTOS->C6_QTDVEN,05)       ,;
         	                     STR(T_PRODUTOS->C6_PRCVEN,10,02)    ,;
        	                     STR(T_PRODUTOS->C6_VALOR,10,02)     ,;
        	                     cEmissao                            })

               T_PRODUTOS->( DbSkip() )
               
            Enddo
            
         Endif      
            
         If Len(aPedidos) == 0
            MsgAlert("Não existem dados a serem visualizados para esta Oportunidade.")
            RestArea(_aAreaAD1) 
            RestArea(_aAreaAD2)	
            RestArea(_aAreaAD3) 
            RestArea(_aAreaAD4)	
            RestArea(_aAreaAD9) 
            RestArea(_aAreaADJ)	
            Return .T.
         Endif   
        
         DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 500,500 PIXEL 

         oDBTree := dbTree():New(10,10,230,240,oDlg,,,.T.)                                                               
                                                                                                   
         oDBTree:AddTree("Pedido de Venda Nº " + Alltrim(cPedido) + Space(24),.T.,cBmp1,cBmp1,,,"1.0") 
         oDBTree:AddTreeItem("Cliente: " + Alltrim(cNomeCliente)   ,cBmp2,,"1.1") 
         oDBTree:AddTreeItem("Cond.Pgtº: " + Alltrim(cNomeCondicao),cBmp2,,"1.2") 
         oDBTree:AddTreeItem("Vendedor 1: " + Alltrim(cNomeV01)    ,cBmp2,,"1.3") 
         oDBTree:AddTreeItem("Vendedor 2: " + Alltrim(cNomeV02)    ,cBmp2,,"1.4") 

//         oDBTree:AddTree("Orçamento Nº " + Alltrim(cOrcamento),.T.,cBmp1,cBmp1,,,"2.0") 
//         oDBTree:AddTree("Proposta Comercial Nº " + Alltrim(cProposta),.T.,cBmp1,cBmp1,,,"3.0") 

//       _Direita  := 4
         _Direita  := 2
         _Esquerda := 0

         _Esquerda += 1
         _Pedido   := aPedidos[01,01]
         _Nota     := aPedidos[01,03]
         _Primeiro := .T.

         For nContar = 1 to Len(aPedidos)

             If Alltrim(_Pedido)  == Alltrim(aPedidos[nContar,01])
                If Alltrim(_Nota) == Alltrim(aPedidos[nContar,03])
                   If _Primeiro == .T.
                      oDBTree:AddTree("Pedido(s) de Venda Nº " + Alltrim(aPedidos[nContar,01]),.T.,cBmp1,cBmp1,,, Str(_Direita,1) + "." + Str(_esquerda,1) ) 
                      _Esquerda += 1
                      oDBTree:AddTreeItem("Nota Fiscal Nº " + Alltrim(aPedidos[nContar,3]),cBmp2,,"4." + Strzero(_Esquerda,3))
                      _Esquerda += 1
                      oDBTree:AddTreeItem("Data Emissão " + Alltrim(aPedidos[nContar,9]),cBmp2,,"4." + Strzero(_Esquerda,3))
                      _Esquerda += 1
                      oDBTree:AddTreeItem(Replicate("-",160), cBmp2,,"4." + Strzero(_Esquerda,3))  
                      _Esquerda += 1
                      _Primeiro := .F.
                   Endif
                Else
                   _Nota := aPedidos[nContar,03]
                   oDBTree:AddTreeItem("Nota Fiscal Nº " + Alltrim(aPedidos[nContar,3]),cBmp2,,"4." + Strzero(_Esquerda,3))
                   _Esquerda += 1
                   oDBTree:AddTreeItem("Data Emissão " + Alltrim(aPedidos[nContar,9]),cBmp2,,"4." + Strzero(_Esquerda,3))
                   _Esquerda += 1
                   oDBTree:AddTreeItem(Replicate("-",160), cBmp2,,"4." + Strzero(_Esquerda,3))  
                   _Esquerda += 1
                Endif

                oDBTree:AddTreeItem("Código: " + Alltrim(aPedidos[nContar,4])  ,cBmp2,,"4." + Strzero(_Esquerda,3))  
                _Esquerda += 1
                oDBTree:AddTreeItem("Produto: " + Alltrim(aPedidos[nContar,5]) ,cBmp2,,"4." + Strzero(_Esquerda,3))  
                _Esquerda += 1
                oDBTree:AddTreeItem("Quantidade: " + Alltrim(aPedidos[nContar,6]) + " X " + Alltrim(aPedidos[nContar,7]) + " = " + Alltrim(aPedidos[nContar,8]) ,cBmp2,,"4." + Strzero(_Esquerda,3))  
                _Esquerda += 1
                oDBTree:AddTreeItem(Replicate("-",160),cBmp2,,"4." + Strzero(_Esquerda,3))      
             Else
                _Pedido   := aPedidos[nContar,01]
                _Nota     := aPedidos[nContar,03]
                _Primeiro := .T.
                _Direita  += 1
                _Esquerda := 0
                nContar   -= 1
             Endif
          
         Next ncontar    

         oDBTree:EndTree() 

         oDBTree:EndTree()    

         DEFINE SBUTTON FROM 235,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg 
         ACTIVATE MSDIALOG oDlg CENTER 

         RestArea(_aAreaAD1) 
         RestArea(_aAreaAD2)	
         RestArea(_aAreaAD3) 
         RestArea(_aAreaAD4)	
         RestArea(_aAreaAD9) 
         RestArea(_aAreaADJ)	

         Return .T.
      
      Endif
      
   Endif

   // Pesquisa dados da Opotunidade para montagem do tree view
   If Select("T_RESUMO") > 0
      T_RESUMO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT AD1_NROPOR, "
   cSql += "       AD1_PROPOS, "
   cSql += "       AD1_NUMORC  "
   cSql += "  FROM " + RetSqlName("AD1010")
   cSql += " WHERE AD1_NROPOR = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND AD1_FILIAL = '" + Alltrim(_Filial) + "'"
   cSql += "   AND R_E_C_D_E_L_ = '' "  
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )

   If T_RESUMO->( Eof() )
      MsgAlert("Não existem dados a serem visualizados para esta Oportunidade.")
      RestArea(_aAreaAD1) 
      RestArea(_aAreaAD2)	
      RestArea(_aAreaAD3) 
      RestArea(_aAreaAD4)	
      RestArea(_aAreaAD9) 
      RestArea(_aAreaADJ)	
      Return .T.
   Else

      cOportunidade := T_RESUMO->AD1_NROPOR
      cProposta     := T_RESUMO->AD1_PROPOS
      cOrcamento    := T_RESUMO->AD1_NUMORC

      // Se código do orçamento <> de branco, pesquisa cliente e vendedores do Orçamento para display
      If !Empty(Alltrim(T_RESUMO->AD1_NUMORC))

         If Select("T_DEMAIS") > 0
            T_DEMAIS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.CJ_NUM    , "
         cSql += "       A.CJ_CLIENTE, "
         cSql += "       A.CJ_LOJA   , "
         cSql += "       A.CJ_VEND1  , "
         cSql += "       A.CJ_VEND2  , "
         cSql += "       B.A1_NOME   , "
         cSql += "       A.CJ_CONDPAG, "
         cSql += "       C.E4_DESCRI   "
         cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
         cSql += "       " + RetSqlName("SA1010") + " B, "
         cSql += "       " + RetSqlName("SE4010") + " C  "
         cSql += " WHERE A.CJ_NUM     = '" + Alltrim(T_RESUMO->AD1_NUMORC) + "'"
         cSql += "   AND A.CJ_FILIAL  = '" + Alltrim(_Filial)              + "'" 
         cSql += "   AND A.CJ_CONDPAG = C.E4_CODIGO "
         cSql += "   AND A.CJ_CLIENTE = B.A1_COD    "
         cSql += "   AND A.CJ_LOJA    = B.A1_LOJA   "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEMAIS", .T., .T. )

         If !T_DEMAIS->( Eof() )

            cNomeCliente  := T_DEMAIS->A1_NOME
            cNomeCondicao := T_DEMAIS->E4_DESCRI

            // Pesquisa o vendedor 1 se preenchido
            If !Empty(T_DEMAIS->CJ_VEND1)

               If Select("T_COMISSAO") > 0
                  T_COMISSAO->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT A3_NOME "
               cSql += "  FROM " + RetSqlName("SA3010")
               cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND1) + "'"
              
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

               If !T_COMISSAO->( Eof() )
                  cNomeV01 := T_COMISSAO->A3_NOME
               Endif   
                                 
            Endif
               
            // Pesquisa o vendedor 2 se preenchido
            If !Empty(T_DEMAIS->CJ_VEND2)

               If Select("T_COMISSAO1") > 0
                  T_COMISSAO1->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT A3_NOME "
               cSql += "  FROM " + RetSqlName("SA3010")
               cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND2) + "'"
               
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO1", .T., .T. )

               If !T_COMISSAO1->( Eof() )
                  cNomeV02 := T_COMISSAO->A3_NOME
               Endif   
                                 
            Endif
            
         Endif   
            
      Endif

      // Limpa o Array dos dados dos Pedidos de Venda
      aPedidos := {}

      // Pesquisa o nº dos Pedidos de Venda da Oportunidade
      If Select("T_RETPEDIDO") > 0
         T_RETPEDIDO->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT A.CJ_NUM   , "
      cSql += "       A.CJ_FILIAL, "
      cSql += "       B.C6_NUM   , "
      cSql += "       B.C6_NOTA  , "
      cSql += "       B.C6_DATFAT  "      
      cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
      cSql += "       " + RetSqlName("SC6010") + " B  "
      cSql += " WHERE A.CJ_NROPOR    = '" + Alltrim(_Codigo)    + "'"
      cSql += "   AND A.CJ_FILIAL    = '" + Alltrim(_FILIAL)    + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''"
//    cSql += "   AND B.C6_NUMORC = A.CJ_NUM || A.CJ_FILIAL "
      cSql += "   AND SUBSTRING(B.C6_NUMORC,01,06) = A.CJ_NUM "
      cSql += "   AND A.CJ_FILIAL = '" + Alltrim(_FILIAL)  + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )
      
      If !T_RETPEDIDO->( EOF() )

         WHILE !T_RETPEDIDO->( EOF() )
//          cClausulaIn := cClausulaIn + "'" + Alltrim(T_RETPEDIDO->CJ_NUM) + "',"
            cClausulaIn := cClausulaIn + "'" + Alltrim(T_RETPEDIDO->C6_NUM) + "',"
            T_RETPEDIDO->( DbSkip() )
         ENDDO
         
         cClausulaIn := Substr(cClausulaIn,01,  Len(Alltrim(cClausulaIn)) - 1)

      Endif
         
      If Empty(Alltrim(cClausulaIn))
         MsgAlert("Sem dados para visualização.")
         Return .T.
      Endif   

      // Pesquisa o Nº do Pedido de Venda
      If Select("T_PEDIDO") > 0
         T_PEDIDO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT C6_NUM   , "
      cSql += "       C6_NOTA  , " 
      cSql += "       C6_NUMOP , "
      cSql += "       C6_DATFAT  "
      cSql += "  FROM " + RetSqlName("SC6010")
//    cSql += " WHERE LEFT(C6_NUMORC,6) IN (" + Alltrim(cClausulaIn) + ")"
      cSql += " WHERE C6_NUM IN (" + Alltrim(cClausulaIn) + ")"
      cSql += "   AND C6_FILIAL         = '" + Alltrim(_Filial)      + "'" 
      cSql += "   AND R_E_C_D_E_L_      = ''  "
      cSql += " GROUP BY C6_NUM, C6_NOTA, C6_NUMOP, C6_DATFAT "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

      If !T_PEDIDO->( Eof() )

         WHILE !T_PEDIDO->( EOF() )

            cPedido   := T_PEDIDO->C6_NUM
            cProducao := T_PEDIDO->C6_NUMOP 
            cNota     := T_PEDIDO->C6_NOTA
            cEmissao  := T_PEDIDO->C6_DATFAT

            // Pesquisa os Produtos do Pedido de Venda para alimentar o Grid de Produtos da Tela.
            If Select("T_PRODUTOS") > 0
               T_PRODUTOS->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.C6_PRODUTO," + chr(13)
            cSql += "       B.B1_DESC   ," + chr(13)
            cSql += "       B.B1_DAUX   ," + chr(13)
            cSql += "       A.C6_QTDVEN ," + chr(13)
            cSql += "       A.C6_PRCVEN ," + chr(13)
            cSql += "       A.C6_VALOR  ," + chr(13)
            cSql += "       A.C6_NOTA    " + chr(13)
            cSql += "  FROM " + RetSqlName("SC6010") + " A, " + chr(13)
            cSql += "       " + RetSqlName("SB1010") + " B  " + chr(13)
            cSql += " WHERE A.C6_NUM          = '" + Alltrim(cPedido) + "'" + chr(13)
            cSql += "   AND A.C6_FILIAL       = '" + Alltrim(_Filial) + "'"  + chr(13)
            cSql += "   AND A.C6_PRODUTO      = B.B1_COD " + chr(13)
            cSql += "   AND A.R_E_C_D_E_L_    = ''       " + chr(13)

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

            If !T_PRODUTOS->( Eof() )
            
               While !T_PRODUTOS->( EOF() )

     	          aAdd( aPedidos, { cPedido                             ,;
     	                            cProducao                           ,;
     	                            T_PRODUTOS->C6_NOTA                 ,;
         	                        Substr(T_PRODUTOS->C6_PRODUTO,01,06),;
     	                            Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),;
         	                        STR(T_PRODUTOS->C6_QTDVEN,05)       ,;
         	                        STR(T_PRODUTOS->C6_PRCVEN,10,02)    ,;
        	                        STR(T_PRODUTOS->C6_VALOR,10,02)     ,;
        	                        cEmissao                            })

                  T_PRODUTOS->( DbSkip() )
               
               Enddo
            
            Endif      
            
            T_PEDIDO->( DbSkip() )
            
         Enddo
         
      Endif
      

   Endif

   DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 500,500 PIXEL 

   @ C(002),C(010) Jpeg FILE "logoautoma.bmp"        Size C(162),C(026) PIXEL NOBORDER OF oDlg

// oDBTree := dbTree():New(10,10,230,240,oDlg,{|| X_Proc(oDBTree:GetCargo())},,.T.)                                                               

   oDBTree := dbTree():New(40,10,230,240,oDlg,,,.T.)                                                               
                                                                                                   
   oDBTree:AddTree("Oportunidade Nº " + Alltrim(cOportunidade) + Space(24),.T.,cBmp1,cBmp1,,,"1.0") 
   oDBTree:AddTreeItem("Cliente: " + Alltrim(cNomeCliente)   ,cBmp2,,"1.1") 
   oDBTree:AddTreeItem("Cond.Pgtº: " + Alltrim(cNomeCondicao),cBmp2,,"1.2") 
   oDBTree:AddTreeItem("Vendedor 1: " + Alltrim(cNomeV01)    ,cBmp2,,"1.3") 
   oDBTree:AddTreeItem("Vendedor 2: " + Alltrim(cNomeV02)    ,cBmp2,,"1.4") 

   oDBTree:AddTree("Orçamento Nº " + Alltrim(cOrcamento),.T.,cBmp1,cBmp1,,,"2.0") 
   oDBTree:AddTree("Proposta Comercial Nº " + Alltrim(cProposta),.T.,cBmp1,cBmp1,,,"3.0") 

   _Direita  := 4
   _Esquerda := 0

   _Esquerda += 1
   _Pedido   := aPedidos[01,01]
   _Nota     := aPedidos[01,03]
   _Primeiro := .T.

   For nContar = 1 to Len(aPedidos)

       If Alltrim(_Pedido)  == Alltrim(aPedidos[nContar,01])
          If Alltrim(_Nota) == Alltrim(aPedidos[nContar,03])
             If _Primeiro == .T.
                oDBTree:AddTree("Pedido(s) de Venda Nº " + Alltrim(aPedidos[nContar,01]),.T.,cBmp1,cBmp1,,, Str(_Direita,1) + "." + Str(_esquerda,1) ) 
                _Esquerda += 1
                oDBTree:AddTreeItem("Nota Fiscal Nº " + Alltrim(aPedidos[nContar,3]),cBmp2,,"4." + Strzero(_Esquerda,3))
                _Esquerda += 1
                oDBTree:AddTreeItem("Data Emissão " + Alltrim(aPedidos[nContar,9]),cBmp2,,"4." + Strzero(_Esquerda,3))
                _Esquerda += 1
                oDBTree:AddTreeItem(Replicate("-",160), cBmp2,,"4." + Strzero(_Esquerda,3))  
                _Esquerda += 1
                _Primeiro := .F.
             Endif
          Else
             _Nota := aPedidos[nContar,03]
             oDBTree:AddTreeItem("Nota Fiscal Nº " + Alltrim(aPedidos[nContar,3]),cBmp2,,"4." + Strzero(_Esquerda,3))
             _Esquerda += 1
             oDBTree:AddTreeItem("Data Emissão " + Alltrim(aPedidos[nContar,9]),cBmp2,,"4." + Strzero(_Esquerda,3))
             _Esquerda += 1
             oDBTree:AddTreeItem(Replicate("-",160), cBmp2,,"4." + Strzero(_Esquerda,3))  
             _Esquerda += 1
          Endif

          oDBTree:AddTreeItem("Código: " + Alltrim(aPedidos[nContar,4])  ,cBmp2,,"4." + Strzero(_Esquerda,3))  
          _Esquerda += 1
          oDBTree:AddTreeItem("Produto: " + Alltrim(aPedidos[nContar,5]) ,cBmp2,,"4." + Strzero(_Esquerda,3))  
          _Esquerda += 1
          oDBTree:AddTreeItem("Quantidade: " + Alltrim(aPedidos[nContar,6]) + " X " + Alltrim(aPedidos[nContar,7]) + " = " + Alltrim(aPedidos[nContar,8]) ,cBmp2,,"4." + Strzero(_Esquerda,3))  
          _Esquerda += 1
          oDBTree:AddTreeItem(Replicate("-",160),cBmp2,,"4." + Strzero(_Esquerda,3))      
       Else
          _Pedido   := aPedidos[nContar,01]
          _Nota     := aPedidos[nContar,03]
          _Primeiro := .T.
          _Direita  += 1
          _Esquerda := 0
          nContar   -= 1
       Endif
          
   Next ncontar    

   oDBTree:EndTree() 

   oDBTree:EndTree()    

   DEFINE SBUTTON FROM 235,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg 
   ACTIVATE MSDIALOG oDlg CENTER 

   RestArea(_aAreaAD1) 
   RestArea(_aAreaAD2)	
   RestArea(_aAreaAD3) 
   RestArea(_aAreaAD4)	
   RestArea(_aAreaAD9) 
   RestArea(_aAreaADJ)	

Return 

// Função de teste pego da internet. Esta mostra como disparar um evento quando clicado em uma opção da árvore.
User Function X_Proc(cCargo) 
   
   Local cRet := "" 

   return .t.

   If cCargo == "1.1" 
      MsgInfo("Gabinete Torre com 4 baias - Preto, com unidade de leitura e gravação de CD/DVD",cCadastro) 
   Elseif cCargo == "1.2" 
      MsgInfo("Monitor LCD 17' - LG",cCadastro) 
   Elseif cCargo == "1.3" 
      MsgInfo("Teclado multimídia com funções de internet e e-mail",cCadastro) 
   Elseif cCargo == "1.4" 
      MsgInfo("Mouse Optico sem fio",cCadastro) 
   Elseif cCargo == "1.5" 
      MsgInfo("2 Caixas de Som - 50W RMS Cada",cCadastro) 
   Elseif cCargo == "2.1" 
      MsgInfo("Processador Pentium 4 - 3.8 Ghz",cCadastro) 
   Elseif cCargo == "2.2" 
      MsgInfo("1 Pente de Memória de 1Gb - DDR 500",cCadastro) 
   Elseif cCargo == "2.3" 
      MsgInfo("Placa de Vídeo GeoForce 5000 com 256Mb",cCadastro) 
   Elseif cCargo == "2.4" 
      MsgInfo("Fonte de Alimentação de 500W",cCadastro) 
   Endif 
     
Return