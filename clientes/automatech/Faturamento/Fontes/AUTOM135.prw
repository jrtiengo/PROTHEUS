#INCLUDE "PROTHEUS.CH"
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM135.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/10/2012                                                          *
// Objetivo..: Programa que abre janela para informação das datas previstas de re- *
//             torno de produtos em Demonstração pela tela da Proposta Comercial.  *
// Parâmetros: __Tipo     -> Indica se foi chamado pela Oportunidade ou PV         *
//             __Proposta -> Nº da Proposta Comercial ou Pedido de venda           *
//             __Filial   -> Filial da Proposta Comercial ou Pedido de Venda       *
//**********************************************************************************

User Function AUTOM135(__Tipo, __Proposta, __Filial)

   Local cSql      := ""
   Local nPosicao  := 0

   Private __PosItem := 0
   Private __PosCodi := 0
   Private __PosNome := 0
   Private __PosData := 0
                         
   Private aBrowse := {}
   
   Private oDlg

   U_AUTOM628("AUTOM135")
   
   If Empty(Alltrim(__Proposta))
      Return .T.
   Endif

   If Select("T_PREVISTO") > 0
      T_PREVISTO->( dbCloseArea() )
   EndIf

   If __Tipo == 1
      cSql := ""
      cSql := "SELECT A.ADZ_FILIAL,"
      cSql += "       A.ADZ_PROPOS,"
      cSql += "       A.ADZ_ITEM  ,"
      cSql += "       A.ADZ_PRODUT,"
      cSql += "       A.ADZ_TES   ,"
      cSql += "       A.ADZ_DEVO  ,"
      cSql += "       B.B1_DESC   ,"
      cSql += "       B.B1_DAUX    "
      cSql += "  FROM " + RetSqlName("ADZ") + " A, "
      cSql += "       " + RetSqlName("SB1") + " B  "
      cSql += " WHERE A.ADZ_PROPOS = '" + Alltrim(__Proposta) + "'"
      cSql += "   AND A.ADZ_FILIAL = '" + Alltrim(__Filial)   + "'"
      cSql += "   AND A.ADZ_TES IN ('523', '542') "               
      cSql += "   AND A.ADZ_PRODUT = B.B1_COD     "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      T_PREVISTO->( DbGoTop() )

      WHILE !T_PREVISTO->( EOF() )

         aAdd( aBrowse, { T_PREVISTO->ADZ_ITEM  ,;
                          T_PREVISTO->ADZ_PRODUT,;
                          Padr(Alltrim(T_PREVISTO->B1_DESC)  + " " + Alltrim(T_PREVISTO->B1_DAUX),90),;
                          Substr(T_PREVISTO->ADZ_DEVO,07,02) + "/" + ;
                          Substr(T_PREVISTO->ADZ_DEVO,05,02) + "/" + ;
                          Substr(T_PREVISTO->ADZ_DEVO,01,04)         ;
                          } )

         T_PREVISTO->( DbSkip() )      

      ENDDO

   Else

      // Localiza a posição do Item
      For nPosicao = 1 to Len(aHeader)
          If Alltrim(aHeader[nPosicao,02]) == "C6_ITEM"
             __PosItem := nPosicao
             Exit
          Endif
      Next nPosicao

      // Localiza a posição do Produto
      For nPosicao = 1 to Len(aHeader)
          If Alltrim(aHeader[nPosicao,02]) == "C6_PRODUTO"
             __PosCodi := nPosicao
             Exit
          Endif
      Next nPosicao

      // Localiza a posição da Descrição do Produto
      For nPosicao = 1 to Len(aHeader)
          If Alltrim(aHeader[nPosicao,02]) == "C6_DESCRI"
             __PosNome := nPosicao
             Exit
          Endif
      Next nPosicao

      // Localiza a posição da Data Prevista de Retorno
      For nPosicao = 1 to Len(aHeader)
          If Alltrim(aHeader[nPosicao,02]) == "C6_DTADEV"
             __PosData := nPosicao
             Exit
          Endif
      Next nPosicao

      For nPosicao = 1 to Len(aCols)

          aAdd( aBrowse, { aCols[nPosicao,__PosItem] ,;
                           aCols[nPosicao,__PosCodi] ,;
                           aCols[nPosicao,__PosNome] ,;
                           Dtoc(aCols[nPosicao,__PosData]) ;
                          } )

      Next nPosicao                    

   Endif      

   DEFINE MSDIALOG oDlg TITLE "Confirmação Data de Retorno de Demonstração" FROM C(178),C(181) TO C(420),C(742) PIXEL Style DS_MODALFRAME

   If __Tipo == 1
      @ C(005),C(005) Say "Esta é uma Proposta Comercial com produtos destinados a Demonstração, porém, existem produtos sem indicação da Data Prevista de retorno." Size C(300),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   Else
      @ C(005),C(005) Say "Esta é um Pedido de Venda com produtos destinados a Demonstração, porém, existem produtos sem indicação da Data Prevista de retorno." Size C(300),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   Endif
            
   @ C(014),C(005) Say "Favor informar estas datas nos referidos produtos." Size C(226),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(104),C(200) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( TrocaData(__Tipo, __Proposta, __Filial, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) )
   @ C(104),C(239) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( SairDaTela() )

   oBrowse := TCBrowse():New( 030 , 005, 350, 100,,{'Item', 'Código', 'Descrição dos Produtos', 'Data Retorno'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                       } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que fecha e sai do programa consistindo os dados antes de tudo
Static Function SairDaTela()

   Local nContar := 0
   Local lVolta  := .F.
   
   For nContar = 1 to Len(aBrowse)
       If Ctod(aBrowse[nContar,04]) = Ctod("  /  /    ")
          lVolta := .T.
          Exit
       Endif
   Next nContar
       
   If lVolta
      MsgAlert("Necessário informar Data de Retorno dos Produtos.")
      Return .T.
   Endif
   
   oDlg:End() 
   
Return .T.      

// Função que abre janela para informação da data de retorno do produto selecionado
Static Function TrocaData(xTipo, xProposta, xFilial, _Item, _Produto, _Nome, _Data)

   Local lChumba     := .F.

   Private cProduto	 := Alltrim(_Item) + " - " + Alltrim(_produto) + " - " + Alltrim(_Nome)
   Private cData	 := cTod(_Data)

   Private oGet1
   Private oGet2

   Private oDlgX

   DEFINE MSDIALOG oDlgX TITLE "Confirmação Data de Retorno de Demonstração" FROM C(178),C(181) TO C(292),C(569) PIXEL

   @ C(022),C(055) Say "Data de Retorno" Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(005),C(005) MsGet oGet1 Var cProduto When lChumba Size C(183),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(021),C(094) MsGet oGet2 Var cData                 Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX

   @ C(038),C(057) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgX ACTION( SalvaData( xTipo, xProposta, xFilial, _Item, cData, _Produto) )
   @ C(038),C(096) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que salva a data de retorno informada
Static Function SalvaData(yTipo, yProposta, yFilial, yItem, yData, yProduto)

   Local cSql    := ""
   Local nContar := 0

   If yData == Ctod("  /  /    ")
      MsgAlert("Data de Retorno não informada.")
      Return .T.
   Endif
   
   If yData > (Date() + 45)
      MsgAlert("Data de Retorno não pode ser maior que 45 dias.")
      Return .T.
   Endif

   // Atualiza a data na tabela ADZ
   If yTipo == 1

      DbSelectArea("ADZ")
      DbSetOrder(1)
      DbSeek(yFilial + yProposta + yItem)
   
      IF !EOF()
	     Reclock("ADZ",.f.)
   	     ADZ_DEVO := yData
	     MsUnlock()         
      Endif

   Else

      For nContar = 1 to Len(aCols)
          
          If Alltrim(aCols[nContar,__PosItem]) == Alltrim(yItem) .and. Alltrim(aCols[nContar,__posCodi]) == Alltrim(yproduto)
             aCols[nContar,__PosData] := yData
             Exit
          Endif
          
      Next nContar       
   
   Endif   
             
   oDlgx:End()

   // Atualiza o Browse
   If Select("T_PREVISTO") > 0
      T_PREVISTO->( dbCloseArea() )
   EndIf

   If yTipo == 1

      cSql := ""
      cSql := "SELECT A.ADZ_FILIAL,"
      cSql += "       A.ADZ_PROPOS,"
      cSql += "       A.ADZ_ITEM  ,"
      cSql += "       A.ADZ_PRODUT,"
      cSql += "       A.ADZ_TES   ,"
      cSql += "       A.ADZ_DEVO  ,"
      cSql += "       B.B1_DESC   ,"
      cSql += "       B.B1_DAUX    "
      cSql += "  FROM " + RetSqlName("ADZ") + " A, "
      cSql += "       " + RetSqlName("SB1") + " B  "
      cSql += " WHERE A.ADZ_PROPOS = '" + Alltrim(yProposta) + "'"
      cSql += "   AND A.ADZ_FILIAL = '" + Alltrim(yFilial)   + "'"
      cSql += "   AND A.ADZ_TES IN ('523', '542') "               
      cSql += "   AND A.ADZ_PRODUT = B.B1_COD     "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      aBrowse := {}

      T_PREVISTO->( DbGoTop() )

      WHILE !T_PREVISTO->( EOF() )

         aAdd( aBrowse, { T_PREVISTO->ADZ_ITEM  ,;
                          T_PREVISTO->ADZ_PRODUT,;
                          Padr(Alltrim(T_PREVISTO->B1_DESC)  + " " + Alltrim(T_PREVISTO->B1_DAUX),90),;
                          Substr(T_PREVISTO->ADZ_DEVO,07,02) + "/" + ;
                          Substr(T_PREVISTO->ADZ_DEVO,05,02) + "/" + ;
                          Substr(T_PREVISTO->ADZ_DEVO,01,04)         ;
                          } )

         T_PREVISTO->( DbSkip() )      

      ENDDO

   Else

      aBrowse := {}

      For nPosicao = 1 to Len(aCols)

          aAdd( aBrowse, { aCols[nPosicao,__PosItem] ,;
                           aCols[nPosicao,__PosCodi] ,;
                           aCols[nPosicao,__PosNome] ,;
                           Dtoc(aCols[nPosicao,__PosData]) ;
                          } )
      Next nPosicao                    

   Endif      

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                       } }

Return .T.   