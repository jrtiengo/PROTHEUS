#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM229.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/04/2014                                                          *
// Objetivo..: Programa que permite o usuário alterar o campo Mensagem para NFiscal*
//             e Observações Internas dos Contratos.                               *
//**********************************************************************************

User Function AUTOM229()

   Private lChumba   := .F.
   Private aFilial   := U_AUTOM539(2, cEmpAnt) // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private cComboBx1
   Private cContrato := Space(15)
   Private cMensagem := ""
   Private cInternas := ""
   Private cControlc := ""
   Private cMemo3	 := ""
   Private oGet1
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Alteração Mensagem Contratos" FROM C(178),C(181) TO C(603),C(761) PIXEL

   @ C(005),C(005) Jpeg FILE "logoautoma.bmp"      Size C(147),C(034) PIXEL NOBORDER OF oDlg

   @ C(041),C(005) Say "Filial"                                          Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(120) Say "Nº do Contrato"                                  Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(066),C(005) Say "Mensagem a ser gravada - Observação Nota Fiscal" Size C(124),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(103),C(005) Say "Mensagem para Nota Fiscal"                       Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(149),C(005) Say "Observações Internas"                            Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(066),C(205) Say "PV não Faturados do Contrato"                    Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(038),C(005) GET oMemo3 Var cMemo3 MEMO Size C(282),C(001) PIXEL OF oDlg

   @ C(050),C(005) ComboBox cComboBx1 Items aFilial   Size C(112),C(010) PIXEL OF oDlg
   @ C(050),C(120) MsGet    oGet1     Var   cContrato Size C(084),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(049),C(209) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PsqObsCnt() )
   @ C(049),C(251) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ C(074),C(005) GET oMemo4 Var cControlc MEMO Size C(282),C(026) PIXEL OF oDlg
   @ C(112),C(005) GET oMemo1 Var cMensagem MEMO Size C(282),C(036) PIXEL OF oDlg
   @ C(158),C(005) GET oMemo2 Var cInternas MEMO Size C(282),C(036) PIXEL OF oDlg

   @ C(197),C(248) Button "Gravar" When lChumba Size C(037),C(012) PIXEL OF oDlg ACTION( GrvObsCnt() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa as observações do contrato informado
Static Function PsqObsCnt()

   If Empty(Alltrim(cContrato))
      lChumba := .F.
      MsgAlert("Nº do Contrato a ser pesquisado não informado.")
      Return(.T.)
   Endif

   // Prepara o Contrato para pesquisa
   If Len(Alltrim(cContrato)) <> 15
      cContrato := Strzero(Int(Val(cContrato)),15)
      oGet1:Refresh()
   Endif
   
   // Pesquisa a Filial/Contrato informado    
   If Select("T_OBSERVA") > 0
      T_OBSERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CN9_FILIAL,"
   cSql += "       CN9_NUMERO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), CN9_MNOT)) AS MENSAGEM,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), CN9_OINT)) AS INTERNAS "
   cSql += "  FROM " + RetSqlName("CN9")
   cSql += " WHERE CN9_FILIAL = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   cSql += "   AND CN9_NUMERO = '" + Alltrim(cContrato) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )
   
   If T_OBSERVA->( EOF() )
      cMensagem := ""
      cInternas := ""
      oMemo1:Refresh()
      oMemo2:Refresh()
      lChumba := .F.
      MsgAlert("Não existem dados a serem visualizados para este filtro. Verifique informações.")
      Return(.T.)
   Endif
   
   lChumba   := .T.

   If Empty(Alltrim(cControlc))
      cMensagem := T_OBSERVA->MENSAGEM
   Else
      cMensagem := cControlc
   Endif

   cInternas := T_OBSERVA->INTERNAS
   oMemo1:Refresh()
   oMemo2:Refresh()

Return(.T.)

// #########################################################
// Função que grava a mensagem e a observação no contrato ##
// #########################################################
Static Function GrvObsCnt()

   Local _nErro      := 0
   Local cSql        := ""
   Local cPedidos    := ""
   Local nContar     := 0

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   Private aListaPed := {}
   Private oListaPed

   // ####################################################
   // Envia para a função que abre a janela dos pedidos ##
   // ####################################################
   MarcaPedidos(cComboBx1, cContrato)

   cInternas := Strtran(cInternas, "'", "")
   cInternas := Strtran(cInternas, '"', "")   
   cInternas := Alltrim(cInternas)

   cMensagem := Strtran(cMensagem, "'", "")
   cMensagem := Strtran(cMensagem, '"', "")   
   cMensagem := Alltrim(cMensagem)

   // #########################################################
   // Atualiza os dados de recebimento do Documento/Material ##
   // #########################################################
// DbSelectArea("CN9")
// DbSetOrder(1)
// If DbSeek( Substr(cComboBx1,01,02) + Alltrim(cContrato) )
//    RecLock("CN9",.F.)
//    CN9->CN9_MNOT := cInternas
//    CN9->CN9_OINT := cMensagem
//    MsUnLock()
// Endif

   cSql := ""
   cSql := "UPDATE " + RetSqlName("CN9")
   cSql += "   SET "
   cSql += "   CN9_MNOT = '" + Alltrim(cMensagem) + "',"
   cSql += "   CN9_OINT = '" + Alltrim(cInternas) + "' "
   cSql += " WHERE CN9_FILIAL = '" + Alltrim(Substr(cComboBx1,01,02))  + "'"
   cSql += "   AND CN9_NUMERO = '" + Alltrim(cContrato) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   // ########################################################
   // Atualiza a mensagem nos pedidos de venda selecionados ##
   // ########################################################
   For nContar = 1 to Len(aListaPed)

       If aListaPed[nContar,01] == .T.

 	      dbSelectArea("SC5")
		  dbSetOrder(1)
		  If dbSeek( Substr(cComboBx1,01,02) + aListaPed[nContar,02] )
		     Reclock("SC5",.F.)
             SC5->C5_MENNOTA := Alltrim(cMensagem)
             SC5->C5_OBSI    := Alltrim(cInternas)
		     MsUnlock()
		  Endif

//          cSql := ""
//          cSql := "UPDATE " + RetSqlName("SC5")
//          cSql += "   SET "
//          cSql += "   C5_MENNOTA     = '" + Alltrim(cMensagem)               + "',"
//          cSql += "   C5_OBSI        = '" + Alltrim(cInternas)               + "'"
//          cSql += " WHERE C5_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
//          cSql += "   AND C5_NUM     = '" + Alltrim(aListaPed[nContar,02])   + "'"
//          cSql += "   AND C5_MDCONTR = '" + Alltrim(cContrato)               + "'"
//
//          _nErro := TcSqlExec(cSql) 
//
//          If TCSQLExec(cSql) < 0 
//             alert(TCSQLERROR())
//             Return(.T.)
//          Endif
       
       Endif
        
   Next nContar       

   lChumba   := .F.
   cContrato := Space(15)
   cMensagem := ""
   cInternas := ""
   oGet1:Refresh()
   oMemo1:Refresh()
   oMemo2:Refresh()

Return(.T.)

// ##################################################################################
// Função que abre a jenela para marcação dos pedidos de venda a serem atualizados ##
// ##################################################################################
Static Function MarcaPedidos(_xFilial, _xContrato)
 
   Local cSql := ""

   Private oDlgM

   If Empty(Alltrim(_xContrato))
      Return(.T.)
   Endif

   // ##################################################################
   // Carrega os Pedidos de Venda não faturados do contrato informado ##
   // ##################################################################
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL , "
   cSql += "       SC5.C5_NUM    , "
   cSql += "       SC5.C5_MDCONTR, "
   cSql += "       SC6.C6_FILIAL , "
   cSql += "       SC6.C6_NOTA     "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SC6") + " SC6  "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(Substr(_xFilial,01,02)) + "'"
   cSql += "   AND SC5.C5_MDCONTR = '" + Alltrim(_xContrato)             + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_FILIAL  = SC5.C5_FILIAL"
   cSql += "   AND SC6.C6_NUM     = SC5.C5_NUM   "
   cSql += "   AND SC6.C6_NOTA    = ''           "
   cSql += "   AND SC6.D_E_L_E_T_ = ''           "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If !T_PEDIDO->( EOF() )
      T_PEDIDO->( DbGoTop() )
      WHILE !T_PEDIDO->( EOF() )
         aAdd( aListaPed, { .F., T_PEDIDO->C5_NUM } )
         T_PEDIDO->( DbSkip() )
      ENDDO
   Endif

   If Len(aListaPed) == 0
      aAdd( aListaPed, { .F., "" } )
   Endif

   DEFINE MSDIALOG oDlgM TITLE "Observações" FROM C(178),C(181) TO C(460),C(416) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"              Size C(110),C(026)                 PIXEL NOBORDER OF oDlgM
   @ C(030),C(005) Say "Indique PVs que serão atualizados" Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(124),C(075) Button "Continuar ..."                  Size C(037),C(012)                 PIXEL OF oDlgM ACTION( oDlgM:End() )
      
   @ 050,005 LISTBOX oListaPed FIELDS HEADER "M", "Nº Pedido Venda" PIXEL SIZE 138,105 OF oDlgM ON dblClick(aListaPed[oListaPed:nAt,1] := !aListaPed[oListaPed:nAt,1],oListaPed:Refresh())     
   oListaPed:SetArray( aListaPed )
   oListaPed:bLine := {||{Iif(aListaPed[oListaPed:nAt,01],oOk,oNo), aListaPed[oListaPed:nAt,02]}}

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)