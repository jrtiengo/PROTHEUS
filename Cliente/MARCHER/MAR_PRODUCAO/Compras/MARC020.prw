#INCLUDE "TOTVS.ch"
#INCLUDE "TOPCONN.ch"

STATIC PCAB_CODPROD     := 01
STATIC PCAB_DESCPROD    := 02
STATIC PCAB_UM          := 03
STATIC PCAB_TIPO        := 04
STATIC PCAB_QTDPREV     := 05
STATIC PCAB_QTDNEC      := 06
STATIC PCAB_NUMMRP      := 07
STATIC PCAB_DIFQTD      := 08

// Posições do Array aItPrev
STATIC PITPR_TIPO       := 01
STATIC PITPR_DOC        := 02
STATIC PITPR_DATA       := 03
STATIC PITPR_DTPRF      := 04
STATIC PITPR_QUANT      := 05
STATIC PITPR_TPOP       := 06
STATIC PITPR_SEQMRP     := 07
STATIC PITPR_ITEM       := 08
STATIC PITPR_CODFOR     := 09
STATIC PITPR_NOMEFOR    := 10

// Posições do Array aItNece
STATIC PITNEC_TIPO      := 01
STATIC PITNEC_DOC       := 02
STATIC PITNEC_DATA      := 03
STATIC PITNEC_DTPRF     := 04
STATIC PITNEC_QUANT     := 05
STATIC PITNEC_SALDO     := 06
STATIC PITNEC_TPOP      := 07


/*/{Protheus.doc} MARC020
Gerenciamento de Pedidos Firmes Excedentes
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/08/2021
/*/
User Function MARC020()

    Local oSize
    Local oSizeSup
    Local oSizeInf
    Local oSizePrev
    Local oSizeNece
    Local oDlg

    Private oBrwCab
    Private oBrwEst
    Private oBrwPrev
    Private oBrwNece
    Private oGgpOpcoes
    Private oGgpCab
    Private oGgpEst
    Private oGgpPrev
    Private oGgpNece
    Private oGetNeceTot
    Private oGetPrvTot
    Private oGetPrvOP
    Private oGetPrvPC
    Private oGetPrvSC
    Private aDados       := {}
    Private aItPrev      := {}
    Private aItNece      := {}
    Private aEstoque     := {}
    Private nTotPrvOP    := 0
    Private nTotPrvPC    := 0
    Private nTotPrvSC    := 0
    Private nTotPrv      := 0
    Private nTotNece     := 0
    Private cTitulo      := "Gerenciamento de Pedidos Firmes Excedentes"
    Private cZKQTENTRPct := X3Picture( "CZK_QTENTR" )
    Private cZKQTSAIDPct := X3Picture( "CZK_QTSAID" )
    Private cCodMRPDe    := ""
    Private dEntregaDe   := CtoD('')
    Private dEntregaAte  := CtoD('')
    Private cCdPrdDe     := ""
    Private cCdPrdAte    := ""
    Private cTipoProd    := ""
    Private aTmD4OP      := TamSX3("D4_OP")

    // #############################################################
	//    Calcula as 2 dimensões, onde cada uma terá seus objetos
    // #############################################################
	oSize := FwDefSize():New( .F. ) // Não terá barra com os botões
	oSize:AddObject( "SUPERIOR", 100, 40, .T., .T. )
	oSize:AddObject( "INFERIOR", 100, 60, .T., .T. )
	oSize:lProp := .T. // Proporcional
	oSize:Process() // Dispara os calculos

    // #############################################################
	//      Divide a Superior em 3
    // #############################################################
	oSizeSup := FwDefSize():New( .F. )
	oSizeSup:aWorkArea := oSize:GetNextCallArea( "SUPERIOR" )
	oSizeSup:AddObject( "OPCOES", 10, 100, .T., .T. )
	oSizeSup:AddObject( "CAB"   , 70, 100, .T., .T. )
	oSizeSup:AddObject( "EST"   , 20, 100, .T., .T. )
	oSizeSup:lLateral := .T. //Calculo em Lateral
	oSizeSup:lProp := .T.
	oSizeSup:Process()

    // #############################################################
	//      Divide a Inferior em 2
    // #############################################################
	oSizeInf := FwDefSize():New( .F. )
	oSizeInf:aWorkArea := oSize:GetNextCallArea( "INFERIOR" )
	oSizeInf:AddObject( "PREV", 60, 100, .T., .T. )
	oSizeInf:AddObject( "NECE", 40, 100, .T., .T. )
	oSizeInf:lLateral := .T. //Calculo em Lateral
	oSizeInf:lProp := .T.
	oSizeInf:Process()

    // #############################################################
	//      Divide o Previsto em 2
    // #############################################################
	oSizePrev := FwDefSize():New( .F. )
	oSizePrev:aWorkArea := oSizeInf:GetNextCallArea( "PREV" )
	oSizePrev:AddObject( "DADOS" , 100, 90, .T., .T. )
	oSizePrev:AddObject( "TOTAIS", 100, 10, .T., .T. )
    oSizePrev:lLateral := .F.
	oSizePrev:lProp := .T.
	oSizePrev:Process()

    // #############################################################
	//      Divide o Necessário em 2
    // #############################################################
	oSizeNece := FwDefSize():New( .F. )
	oSizeNece:aWorkArea := oSizeInf:GetNextCallArea( "NECE" )
	oSizeNece:AddObject( "DADOS" , 100, 90, .T., .T. )
	oSizeNece:AddObject( "TOTAIS", 100, 10, .T., .T. )
    oSizeNece:lLateral := .F.
	oSizeNece:lProp := .T.
	oSizeNece:Process()

    oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4], cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.)

    oGgpOpcoes := TGroup():New(oSizeSup:GetDimension("OPCOES","LININI"),;
                                oSizeSup:GetDimension("OPCOES","COLINI"),;
                                oSizeSup:GetDimension("OPCOES","LINEND"),;
                                oSizeSup:GetDimension("OPCOES","COLEND"),'Opções',oDlg,,,.T.)

    TButton():New(  oSizeSup:GetDimension("OPCOES","LININI")+20,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+10,;
                    "Sair",oGgpOpcoes,{|| oDlg:End() },;
                    035,012,,,,.T.,,"",,,,.F. )
    
    TButton():New(  oSizeSup:GetDimension("OPCOES","LININI")+40,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+10,;
                    "Filtrar",oGgpOpcoes,{|u| Processa( {|| FiltrarDados() }, "Processando...", "Registros" ) },035,012,,,,.T.,,"",,,,.F. )

    TButton():New(  oSizeSup:GetDimension("OPCOES","LININI")+60,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+10,;
                    "Relatório",oGgpOpcoes,{|u| Relatorio() },035,012,,,,.T.,,"",,,,.F. )


    // #############################################################
    //      Cabeçalho com os Produtos e Quantidades
    // #############################################################
    oGgpCab := TGroup():New(oSizeSup:GetDimension("CAB","LININI"),;
                            oSizeSup:GetDimension("CAB","COLINI"),;
                            oSizeSup:GetDimension("CAB","LINEND"),;
                            oSizeSup:GetDimension("CAB","COLEND"),'Produtos e Quantidades do MRP',oDlg,,,.T.)

    oBrwCab := TWBrowse():New(  oSizeSup:GetDimension("CAB","LININI")+10,;
                                oSizeSup:GetDimension("CAB","COLINI")+5,;
                                oSizeSup:GetDimension("CAB","XSIZE")-10,;
                                oSizeSup:GetDimension("CAB","YSIZE")-15,;
                                ,,,oGgpCab,,,,{|| MsgRun( "Carregando detalhes, aguarde...", "Detalhes", {|| MostraDet( oBrwCab:nAt, .T. ) } ) },,,,,,,,,,.T./*lPixel*/ )


    // #############################################################
    //      Cabeçalho com o Estoque dos Produtos
    // #############################################################
    oGgpEst := TGroup():New(oSizeSup:GetDimension("EST","LININI"),;
                            oSizeSup:GetDimension("EST","COLINI"),;
                            oSizeSup:GetDimension("EST","LINEND"),;
                            oSizeSup:GetDimension("EST","COLEND"),'Estoque do Produto',oDlg,,,.T.)

    oBrwEst := TWBrowse():New(  oSizeSup:GetDimension("EST","LININI")+10,;
                                oSizeSup:GetDimension("EST","COLINI")+5,;
                                oSizeSup:GetDimension("EST","XSIZE")-10,;
                                oSizeSup:GetDimension("EST","YSIZE")-15,;
                                ,,,oGgpCab,,,,{||},,,,,,,,,,.T./*lPixel*/ )

    // #############################################################
    //      Itens com os dados Previstos
    // #############################################################
    oGgpPrev := TGroup():New(  oSizeInf:GetDimension("PREV","LININI"),;
                               oSizeInf:GetDimension("PREV","COLINI"),;
                               oSizeInf:GetDimension("PREV","LINEND"),;
                               oSizeInf:GetDimension("PREV","COLEND"),'Previstos do MRP ( SC / PC / OP )',oDlg,,,.T.)

	oBrwPrev := TcBrowse():New( oSizePrev:GetDimension("DADOS","LININI")+5,;
                                oSizePrev:GetDimension("DADOS","COLINI")+2,;
                                oSizePrev:GetDimension("DADOS","XSIZE")-2,;
                                oSizePrev:GetDimension("DADOS","YSIZE")-5,,,,oGgpPrev,,,,,,,,,,,,,,.T./*lPixel*/ )
    
    oGetPrvOP := TGet():New( oSizePrev:GetDimension("TOTAIS","LININI")+2,;
                             oSizePrev:GetDimension("TOTAIS","COLINI")+10,;
                             {|u| If(PCount()>0,nTotPrvOP:=u,nTotPrvOP)},oGgpPrev,050,008,cZKQTENTRPct,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nTotPrvOP",,,,,.T.,,"Qtde total por OP",1)
    oGetPrvOP:Disable()

    oGetPrvPC := TGet():New( oSizePrev:GetDimension("TOTAIS","LININI")+2,;
                             oSizePrev:GetDimension("TOTAIS","COLINI")+90,;
                             {|u| If(PCount()>0,nTotPrvPC:=u,nTotPrvPC)},oGgpPrev,050,008,cZKQTENTRPct,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nTotPrvPC",,,,,.T.,,"Qtde total por PC",1)
    oGetPrvPC:Disable()

    oGetPrvSC := TGet():New( oSizePrev:GetDimension("TOTAIS","LININI")+2,;
                             oSizePrev:GetDimension("TOTAIS","COLINI")+170,;
                             {|u| If(PCount()>0,nTotPrvSC:=u,nTotPrvSC)},oGgpPrev,050,008,cZKQTENTRPct,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nTotPrvSC",,,,,.T.,,"Qtde total por SC",1)
    oGetPrvSC:Disable()

    oGetPrvTot := TGet():New( oSizePrev:GetDimension("TOTAIS","LININI")+2,;
                             oSizePrev:GetDimension("TOTAIS","COLINI")+260,;
                             {|u| If(PCount()>0,nTotPrv:=u,nTotPrv)},oGgpPrev,050,008,cZKQTENTRPct,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nTotPrv",,,,,.T.,,"Qtde total",1)
    oGetPrvTot:Disable()

    // #############################################################
    //      Itens com os dados Necessário
    // #############################################################
    oGgpNece := TGroup():New(  oSizeInf:GetDimension("NECE","LININI"),;
                               oSizeInf:GetDimension("NECE","COLINI"),;
                               oSizeInf:GetDimension("NECE","LINEND"),;
                               oSizeInf:GetDimension("NECE","COLEND"),'Necessidades do MRP ( Empenhos )',oDlg,,,.T.)

	oBrwNece := TcBrowse():New( oSizeNece:GetDimension("DADOS","LININI")+5,;
                                oSizeNece:GetDimension("DADOS","COLINI")+2,;
                                oSizeNece:GetDimension("DADOS","XSIZE")-2,;
                                oSizeNece:GetDimension("DADOS","YSIZE")-5;
                                ,,,,oGgpNece,,,,,,,,,,,,,,.T./*lPixel*/ )

    oGetNeceTot := TGet():New( oSizeNece:GetDimension("TOTAIS","LININI")+2,;
                               oSizeNece:GetDimension("TOTAIS","COLINI")+10,;
                               {|u| If(PCount()>0,nTotNece:=u,nTotNece)},oGgpPrev,050,008,cZKQTENTRPct,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nTotNece",,,,,.T.,,"Qtde total",1)
    oGetNeceTot:Disable()


    Processa( {|| FiltrarDados() }, "Processando...", "Registros" )

    If Len( aDados ) > 0
        oDlg:Activate()
    Endif

Return


/*/{Protheus.doc} FiltrarDados
Chamar a tela dos parâmetros e carregar o array com os registros localizados ( PC e/ou OP ).
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/08/2021
/*/
Static Function FiltrarDados()

    Local cAliQry := ""
    Local cQuery  := ""
    Local nPos    := 0
    Local nTotReg := 0
    Local nReg    := 0
    Local nQtNece := 0
    Local nQtPrev := 0

    If !Pergunte("MARC020",.T.)
        Return()
    Endif

    cFornDe     := MV_PAR01
    cFornAte    := MV_PAR02
    cCodMRPDe   := MV_PAR03
    cCodMRPAte  := MV_PAR04
    dEntregaDe  := MV_PAR05
    dEntregaAte := MV_PAR06
    cCdPrdDe    := MV_PAR07
    cCdPrdAte   := MV_PAR08
    cTipoProd   := MV_PAR09
    aDados      := {}

    If( Empty(cFornDe) .And. Empty(cCodMRPDe) .And. Empty(dEntregaDe) .And. Empty(cCdPrdDe) )
        MsgInfo("É necessário informar pelo menos um dos parâmetros DE...ATE e a Data de Entrega Prevista !")
        Return()
    Endif

    cQuery += "SELECT DISTINCT CASE CZI.CZI_ALIAS "
    cQuery += "        WHEN 'SC1' THEN 'SC' "
    cQuery += "        WHEN 'SC7' THEN 'PC' "
    cQuery += "        WHEN 'SD4' THEN 'EMPENHO' "
    cQuery += "        ELSE 'OP' "
    cQuery += "    END TIPO, "
    cQuery += "    CZI.CZI_NRMRP, "
    cQuery += "    CZI.CZI_PROD, "
    cQuery += "    SB1.B1_DESC, "
    cQuery += "    SB1.B1_UM, "
    cQuery += "    SB1.B1_TIPO, "
    cQuery += "    CZI.CZI_DOC, "
    cQuery += "    CZI.CZI_ITEM, "
    cQuery += "    CZI.CZI_DTOG, "
    cQuery += "    CZI.CZI_QUANT "
    cQuery += "FROM " + RetSqlName( "CZI" ) + " CZI "
    cQuery += "INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON (SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
    cQuery += "                        AND SB1.B1_COD = CZI.CZI_PROD "
    If !Empty( cTipoProd )
        cQuery += "                    AND SB1.B1_TIPO = '" + cTipoProd + "' "
    EndIf
    cQuery += "                        AND SB1.D_E_L_E_T_ = ' ') "
    cQuery += "WHERE CZI.D_E_L_E_T_ = ' ' "
    cQuery += "AND CZI.CZI_FILIAL = '" + xFilial( "CZI" ) + "' "
    cQuery += "AND CZI.CZI_PROD BETWEEN  '" + cCdPrdDe + "' AND '" + cCdPrdAte + "' "
    cQuery += "AND CZI.CZI_NRMRP BETWEEN '" + cCodMRPDe + "' AND '" + cCodMRPAte + "' "
    cQuery += "AND CZI.CZI_DTOG BETWEEN '" + DtoS(dEntregaDe) + "' AND '" + DtoS(dEntregaAte) + "' "
    cQuery += "AND CZI.CZI_TPRG IN ('2','3') "
    cQuery += "AND CZI.CZI_ALIAS IN ('SC1','SC7','SC2','SD4') "
    cQuery += "ORDER BY CZI.CZI_PROD "

    //Memowrit( "c:\temp\MARC020_cab.sql", cQuery )
    
    cAliQry := GetNextAlias()
    DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliQry,.F.,.F.)
    TCSetField( cAliQry, "CZI_QUANT", "N", 12, 2 )
    TCSetField( cAliQry, "CZI_DTOG" , "D", 8, 0 )

    DbSelectArea( cAliQry)
    Count To nTotReg
    dbGoTop()
    ProcRegua( nTotReg )

    while (cAliQry)->( !EOF() )

        If AllTrim((cAliQry)->TIPO) == "EMPENHO"
            nQtPrev := 0
            nQtNece := (cAliQry)->CZI_QUANT
        Else // SC, PC e OP
            nQtPrev := (cAliQry)->CZI_QUANT
            nQtNece := 0
        Endif

        nReg += 1
        nPos := aScan( aDados,{ |x| x[PCAB_NUMMRP] == (cAliQry)->CZI_NRMRP .And. x[PCAB_CODPROD] == (cAliQry)->CZI_PROD } )

        If nPos > 0
            aDados[ nPos, PCAB_QTDPREV] += nQtPrev
            aDados[ nPos, PCAB_QTDNEC]  += nQtNece
        Else
            AADD( aDados, { (cAliQry)->CZI_PROD,;
                            AllTrim((cAliQry)->B1_DESC),;
                            (cAliQry)->B1_UM,;
                            (cAliQry)->B1_TIPO,;
                            nQtPrev,;
                            nQtNece,;
                            (cAliQry)->CZI_NRMRP,;
                            0;
                            } )
            nPos := Len(aDados)
        Endif

        aDados[nPos,PCAB_DIFQTD] := aDados[nPos,PCAB_QTDNEC] - aDados[nPos,PCAB_QTDPREV]

        IncProc( "Registro " + cValToChar( nReg ) + " de " + cValToChar( nTotReg ) )

        (cAliQry)->( DbSkip() )
    EndDo
    (cAliQry)->( DbCloseArea() )

    If Len( aDados ) <= 0
        MsgInfo("Não foram localizados registros conforme os parâmetros informados")
        AADD( aDados, Array( 08, '' ) )
    Endif

    // Ordena pela Maior diferença de Quantidade
    aSort( aDados,,,{ |x,y| x[PCAB_DIFQTD] > y[PCAB_DIFQTD] } )

    oBrwCab:setArray( aDados )
    oBrwCab:aHeaders  := {"Produto","Descrição","UM","Tipo","Qtde SC/PC/OP","Qtde Empenho","Diferença" }
    oBrwCab:bLine := {||{   aDados[oBrwCab:nAt,PCAB_CODPROD],;
                            aDados[oBrwCab:nAt,PCAB_DESCPROD],;
                            aDados[oBrwCab:nAt,PCAB_UM],;
                            aDados[oBrwCab:nAt,PCAB_TIPO],;
                            Transform(aDados[oBrwCab:nAt,PCAB_QTDPREV], cZKQTENTRPct ),;
                            Transform(aDados[oBrwCab:nAt,PCAB_QTDNEC], cZKQTSAIDPct ),;
                            Transform(aDados[oBrwCab:nAt,PCAB_DIFQTD], cZKQTSAIDPct );
                            } }
    oBrwCab:nAt := 1
    oBrwCab:nRowPos := 1
    oBrwCab:ResetLen()
	oBrwCab:Refresh()

    // Atualiza os Itens
    MostraDet( 1, .T. )
    
Return()



/*/{Protheus.doc} MostraDet
Mostrar os Detalhes do Produto gerado no MRP
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/08/2021
@param nLin, numeric, Número da linha selecionado
@param lTela, logical, .T. se foi chamado da Tela e .F. caso foi chamado do Relatório
/*/
Static Function MostraDet( nLin, lTela )

    Local nQtdEst  := 0
    Local nSldSD4  := 0
    Local cSeqMRP  := ''
    Local cItem    := ''
    Local cQuery   := ''
    Local cFilSC2  := ''
    Local cFilSC1  := ''
    Local cFilSC7  := ''
    Local cFilSA2  := ''
    Local cFilSD4  := ''
    Local cTpOP    := ''
    Local cCodFor  := ''
    Local cNomeFor := ''
    Local dDatPRF  := CtoD('')
    Local lAdd     := .F.
    Local cAliTmp  := GetNextAlias()

    Default lTela := .F.
    
    aItNece  := {}
    aItPrev  := {}
    aEstoque := {}

    nTotPrvOP := 0
    nTotPrvPC := 0
    nTotPrvSC := 0
    nTotPrv   := 0
    nTotNece  := 0

    DbSelectArea("SC1")
    DbSetOrder(2) // C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM
    cFilSC1 := xFilial("SC1")

    DbSelectArea("SC7")
    DbSetOrder(4) // C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
    cFilSC7 := xFilial("SC7")

    DbSelectArea("SC2")
    DbSetOrder(1)
    cFilSC2 := xFilial("SC2")

    DbSelectArea("SA2")
    DbSetOrder(1)
    cFilSA2 := xFilial("SA2")
    
    DbSelectArea("SD4")
    DbSetOrder(1) // D4_FILIAL + D4_COD + D4_OP + D4_TRT + D4_LOTECTL + D4_NUMLOTE
    cFilSD4 := xFilial("SD4")

    DbSelectArea("SB2")
    DbSetOrder(1)

    cQuery += "SELECT CASE CZI_ALIAS "
    cQuery += "        WHEN 'SC1' THEN 'SC' "
    cQuery += "        WHEN 'SC7' THEN 'PC' "
    cQuery += "        WHEN 'SD4' THEN 'EMPENHO' "
    cQuery += "        ELSE 'OP' "
    cQuery += "    END TIPO, "
    cQuery += "    CZI_DOC, "
    cQuery += "    CZI_ITEM, "
    cQuery += "    CZI_DTOG, "
    cQuery += "    CZI_QUANT "
    cQuery += "FROM " + RetSqlName( "CZI" ) + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' "
    cQuery += "AND CZI_FILIAL = '" + xFilial( "CZI" ) + "' "
    cQuery += "AND CZI_PROD = '" + aDados[ nLin, PCAB_CODPROD ] + "' "
    cQuery += "AND CZI_NRMRP = '" + aDados[ nLin, PCAB_NUMMRP ] + "' "
    cQuery += "AND CZI_DTOG BETWEEN '" + DtoS(dEntregaDe) + "' AND '" + DtoS(dEntregaAte) + "' "
    cQuery += "AND CZI_TPRG IN ('2','3') "
    cQuery += "AND CZI_ALIAS IN ('SC1','SC7','SC2','SD4') "
    cQuery += "ORDER BY TIPO, CZI_DOC, CZI_ITEM, CZI_PROD, CZI_DTOG "

    //Memowrit( "c:\temp\MARC020_itens.sql", cQuery )

    DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliTmp,.F.,.F.)
    TCSetField( cAliTmp, "CZI_QUANT", "N", 12, 2 )
    TCSetField( cAliTmp, "CZI_DTOG" , "D", 08, 0 )

    While (cAliTmp)->( !EOF() ) 

        nSldSD4  := 0
        cCodFor  := ''
        cNomeFor := ''
        cItem    := ''
        dDatPRF  := CtoD('')
        cSeqMRP  := ''
        cTpOP    := ''
        lAdd     := .F.
        
        If AllTrim((cAliTmp)->TIPO) == "EMPENHO"
            //D4_FILIAL + D4_COD + D4_OP + D4_TRT + D4_LOTECTL + D4_NUMLOTE
            If SD4->( DbSeek( cFilSD4 + aDados[ nLin, PCAB_CODPROD ] + PadR( (cAliTmp)->CZI_DOC, aTmD4OP[1] ) ) )
                
                dDatPRF  := SD4->D4_DATA
                nTotNece += (cAliTmp)->CZI_QUANT
                nSldSD4  := SD4->D4_SLDEMP

                lAdd := .T.
                If SC2->( DbSeek( cFilSC2 + AllTrim( SD4->D4_OP ) ) )
                    cTpOP := IIF( SC2->C2_TPOP == "F", "Firme", IIF(  SC2->C2_TPOP $ " /P", "Prevista", "" ) )
                Endif
            Endif

        ElseIf AllTrim((cAliTmp)->TIPO) == "SC"
            If SC1->( DbSeek( cFilSC1 + aDados[ nLin, PCAB_CODPROD ] + AllTrim( (cAliTmp)->CZI_DOC) + AllTrim( (cAliTmp)->CZI_ITEM) ) )

                lAdd := .T.

                // If ( SC1->C1_DATPRF >= dEntregaDe .And. SC1->C1_DATPRF <= dEntregaAte )
                //     lAdd := .T.
                // Else
                //     lAdd := .F.
                // Endif

                // If ( lAdd .And. SC1->C1_SEQMRP == aDados[ nLin, PCAB_NUMMRP ] .And. .NOT. Empty(SC1->C1_SEQMRP) )
                //     lAdd := .T.
                // Else
                //     lAdd := .F.
                // Endif

                If lAdd
                    cItem   := SC1->C1_ITEM
                    dDatPRF := SC1->C1_DATPRF
                    cSeqMRP := SC1->C1_SEQMRP
                    cTpOP   := IIF( SC1->C1_TPOP == "F", "Firme", IIF(  SC1->C1_TPOP == "P", "Prevista", "" ) )
                    nTotPrvSC += (cAliTmp)->CZI_QUANT
                Endif
            Endif
        ElseIf AllTrim((cAliTmp)->TIPO) == "PC"
            If SC7->( DbSeek( cFilSC7 + aDados[ nLin, PCAB_CODPROD ] + AllTrim( (cAliTmp)->CZI_DOC) + AllTrim( (cAliTmp)->CZI_ITEM) ) )

                lAdd := .T.

                // If ( SC7->C7_DATPRF >= dEntregaDe .And. SC7->C7_DATPRF <= dEntregaAte )
                //     lAdd := .T.
                // Else
                //     lAdd := .F.
                // Endif

                // If ( lAdd .And. SC7->C7_SEQMRP == aDados[ nLin, PCAB_NUMMRP ] .And. .NOT. Empty(SC7->C7_SEQMRP) )
                //     lAdd := .T.
                // Else
                //     lAdd := .F.
                // Endif

                If lAdd
                    cItem   := SC7->C7_ITEM
                    cCodFor := SC7->C7_FORNECE
                    dDatPRF := SC7->C7_DATPRF
                    cSeqMRP := SC7->C7_SEQMRP
                    cTpOP   := IIF( SC7->C7_TPOP == "F", "Firme", IIF(  SC7->C7_TPOP == "P", "Prevista", "" ) )
                    nTotPrvPC += (cAliTmp)->CZI_QUANT

                    If SA2->( DbSeek( cFilSA2 + SC7->C7_FORNECE ) )
                        cNomeFor := AllTrim(SA2->A2_NOME)
                    Endif
                Endif
            Endif

        ElseIf AllTrim((cAliTmp)->TIPO) == "OP"
            If SC2->( DbSeek( cFilSC2 + AllTrim( (cAliTmp)->CZI_DOC ) ) )
                
                lAdd := .T.

                // If ( SC2->C2_DATPRF >= dEntregaDe .And. SC2->C2_DATPRF <= dEntregaAte )
                //     lAdd := .T.
                // Else
                //     lAdd := .F.
                // Endif

                // If ( lAdd .And. SC2->C2_SEQMRP == aDados[ nLin, PCAB_NUMMRP ] .And. .NOT. Empty(SC2->C2_SEQMRP) )
                //     lAdd := .T.
                // Else
                //     lAdd := .F.
                // Endif

                 If lAdd
                    dDatPRF := SC2->C2_DATPRF
                    cSeqMRP := SC2->C2_SEQMRP
                    cTpOP   := IIF( SC2->C2_TPOP == "F", "Firme", IIF(  SC2->C2_TPOP $ " /P", "Prevista", "" ) )
                    nTotPrvOP += (cAliTmp)->CZI_QUANT
                Endif
            Endif
        Endif

        If lAdd

            If AllTrim((cAliTmp)->TIPO) == "EMPENHO"
                AADD( aItNece, { AllTrim((cAliTmp)->TIPO),;
                                (cAliTmp)->CZI_DOC,;
                                (cAliTmp)->CZI_DTOG,;
                                dDatPRF,;
                                (cAliTmp)->CZI_QUANT,;
                                nSldSD4,;
                                cTpOP;
                                } )
            Else // SC, PC e OP
                AADD( aItPrev, { AllTrim((cAliTmp)->TIPO),;
                                (cAliTmp)->CZI_DOC,;
                                (cAliTmp)->CZI_DTOG,;
                                dDatPRF,;
                                (cAliTmp)->CZI_QUANT,;
                                cTpOP,;
                                cSeqMRP,;
                                cItem,;
                                cCodFor,;
                                cNomeFor;
                                } )
                nTotPrv += (cAliTmp)->CZI_QUANT
            Endif
        Endif

        (cAliTmp)->( DbSkip() ) 
    EndDo 
    (cAliTmp)->( DbCloseArea() )
    cAliTmp := ""
    
    // Consultar o Saldo do Produto
    cQuery := "SELECT B2_FILIAL, B2_COD, B2_LOCAL, NNR_DESCRI "
    cQuery += "FROM " + RetSqlName("SB2") + " SB2 "
    cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR ON ( NNR_FILIAL = '"+xFilial("NNR")+"' AND B2_LOCAL = NNR_CODIGO AND NNR.D_E_L_E_T_ = ' ' ) "
    cQuery += "WHERE SB2.D_E_L_E_T_ = ' ' "
    cQuery += "AND B2_FILIAL = '" + xFilial( "SB2" ) + "' "
    cQuery += "AND B2_COD = '" + aDados[ nLin, PCAB_CODPROD ] + "' "
    cQuery += "ORDER BY B2_COD, B2_LOCAL "
    cAliTmp  := GetNextAlias()
    //Memowrit( "c:\temp\MARC020_itens_saldo.sql", cQuery )

    DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliTmp,.F.,.F.)
    TCSetField( cAliTmp, "B2_QATU", "N", 12, 2 )

    While (cAliTmp)->( !EOF() )

        SB2->( DbSeek( (cAliTmp)->B2_FILIAL + (cAliTmp)->B2_COD + (cAliTmp)->B2_LOCAL ) )

        nQtdEst :=  SaldoSB2()

        If nQtdEst > 0
            AADD( aEstoque, { nQtdEst, (cAliTmp)->B2_LOCAL, Left( (cAliTmp)->NNR_DESCRI, 15 ) } )
        EndIf
        (cAliTmp)->( DbSkip() )
    EndDo
    (cAliTmp)->( DbCloseArea() )
    cAliTmp := ""

    If Len( aEstoque ) <= 0
        AADD( aEstoque, Array( 3 ) )
        aEstoque[1,1] := 0
        aEstoque[1,1] := ""
        aEstoque[1,3] := ""
    EndIf

    If Len( aItPrev ) <= 0
        AADD( aItPrev, Array( 10 ) )
        aItPrev[1,1] := ''
        aItPrev[1,2] := ''
        aItPrev[1,3] := CtoD('')
        aItPrev[1,4] := CtoD('')
        aItPrev[1,5] := 0
        aItPrev[1,6] := ''
        aItPrev[1,7] := ''
        aItPrev[1,8] := ''
        aItPrev[1,9] := ''
        aItPrev[1,10] := ''
    Endif

    If Len( aItNece ) <= 0
        AADD( aItNece, Array( 07 ) )
        aItNece[1,1] := ''
        aItNece[1,2] := ''
        aItNece[1,3] := CtoD('')
        aItNece[1,4] := CtoD('')
        aItNece[1,5] := 0
        aItNece[1,6] := 0
        aItNece[1,7] := ''
    Endif

    If lTela

        // #############################################################
        //      Itens com os dados Previstos
        // #############################################################
        oBrwPrev:setArray( aItPrev )
        oBrwPrev:aHeaders  := {"Num. Doc.","Data","Qtde","Seq. MRP","Tipo SC/PC/OP","Prev. Entrega","Item","Nome Fornec.","Cod. Fornec."}
        oBrwPrev:bLine := {||{  Transform(aItPrev[oBrwPrev:nAt,PITPR_DOC], IIF( Len(AllTrim(aItPrev[oBrwPrev:nAt,PITPR_DOC]))>6, "@R 999999.99.9999", "@!" ) ),;
                                DtoC(aItPrev[oBrwPrev:nAt,PITPR_DATA]),;
                                Transform(aItPrev[oBrwPrev:nAt,PITPR_QUANT], cZKQTENTRPct ),;
                                aItPrev[oBrwPrev:nAt,PITPR_SEQMRP],;
                                aItPrev[oBrwPrev:nAt,PITPR_TPOP],;
                                DtoC(aItPrev[oBrwPrev:nAt,PITPR_DTPRF]),;
                                aItPrev[oBrwPrev:nAt,PITPR_ITEM],;
                                aItPrev[oBrwPrev:nAt,PITPR_NOMEFOR],;
                                aItPrev[oBrwPrev:nAt,PITPR_CODFOR];
                                } }
        oBrwPrev:nAt := 1
        oBrwPrev:nRowPos := 1
        oBrwPrev:ResetLen()
        oBrwPrev:Refresh()
        oBrwPrev:bLDblClick := {|| MsgRun( "Abrindo registro ! Aguarde...", cTitulo, {|| VisualReg( aItPrev, oBrwPrev:nAt, aDados[ nLin, PCAB_CODPROD ] ) } ) }

        oGetPrvOP:Refresh()
        oGetPrvPC:Refresh()
        oGetPrvSC:Refresh()
        oGetPrvTot:Refresh()

        // #############################################################
        //      Itens com os dados Necessário
        // #############################################################
        oBrwNece:setArray( aItNece )
        oBrwNece:aHeaders  := {"Num. Doc.","Data","Qtde","Saldo","Dt Empenho","Tipo Empenho" }
        oBrwNece:bLine := {||{  Transform(aItNece[oBrwNece:nAt,PITNEC_DOC], "@R 999999.99.9999" ),;
                                DtoC(aItNece[oBrwNece:nAt,PITNEC_DATA]),;
                                Transform(aItNece[oBrwNece:nAt,PITNEC_QUANT], cZKQTSAIDPct ),;
                                Transform(aItNece[oBrwNece:nAt,PITNEC_SALDO], cZKQTSAIDPct ),;
                                DtoC(aItNece[oBrwNece:nAt,PITNEC_DTPRF]),;
                                aItNece[oBrwNece:nAt,PITNEC_TPOP];
                                } }

        oBrwNece:nAt := 1
        oBrwNece:nRowPos := 1
        oBrwNece:ResetLen()
        oBrwNece:Refresh()
        oBrwNece:bLDblClick := {|| MsgRun( "Abrindo registro ! Aguarde...", cTitulo, {|| VisualReg( aItNece, oBrwNece:nAt, aDados[ nLin, PCAB_CODPROD ] ) } ) }

        oGetNeceTot:Refresh()


        // #############################################################
        //      Armazéns e Saldos do Produto
        // #############################################################
        oBrwEst:setArray( aEstoque )
        oBrwEst:aHeaders  := {"Saldo", "Armazém", "Descrição" }
        oBrwEst:bLine := {||{  Transform(aEstoque[oBrwEst:nAt,1], cZKQTSAIDPct ),;
                               aEstoque[oBrwEst:nAt,2],;
                               aEstoque[oBrwEst:nAt,3];
                               } }
        oBrwEst:nAt := 1
        oBrwEst:nRowPos := 1
        oBrwEst:ResetLen()
        oBrwEst:Refresh()

    EndIf

Return



/*/{Protheus.doc} VisualReg
Visualizar o registro posicionado
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/08/2021
@param nLin, numeric, Linha posicionada
/*/
Static Function VisualReg( aItens, nLin, cProd )

    Local nOpc := 0
    Private cCadastro := ""
    Private aRotina   := {}

    If Empty( aItens[nLin,PITPR_DOC] )
        Return
    Endif

    If aItens[nLin,PITPR_TIPO] == "OP"
        
        DbSelectArea("SC2")
        DbSetOrder(1)
        If DbSeek( xFilial("SC2") + AllTrim( aItens[nLin,PITPR_DOC] ) )

            cCadastro := "Consulta a Ordem de Produção"
            A650View("SC2",RecNo(),2)
        Else
            MsgInfo( "Não foi localizada a O.P. !" )
        Endif
    
    ElseIf aItens[nLin,PITPR_TIPO] == 'EMPENHO' 
        
        DbSelectArea("SD4")
        DbSetOrder(2)
        If DbSeek( xFilial("SD4") + AllTrim( aItens[nLin,PITPR_DOC] ) )

            nOpc := AVISO("Selecione uma opção", "Como deseja visualizar o Empenho ", { "Simples", "Múltiplo", "Voltar"}, 1)

            If nOpc == 1
                AxVisual(Alias(),Recno(),2)
            ElseIf nOpc  == 2
                Private l381Auto  := .F.
                Private aSDC      := {}
                aRotina   := {}
                cCadastro := "Consulta de Empenho"

                //--Monta o aRotina para compatibilizacao
                AAdd( aRotina, { '' , '' , 0, 1 } )
                AAdd( aRotina, { '' , '' , 0, 2 } )
                AAdd( aRotina, { '' , '' , 0, 3 } )
                AAdd( aRotina, { '' , '' , 0, 4 } )
                AAdd( aRotina, { '' , '' , 0, 5 } )

                A381Manut(Alias(),Recno(),2)
            Endif
        Else
            MsgInfo( "Não foi localizado Empenho !" )
        Endif
    
    ElseIf aItens[nLin,PITPR_TIPO] == 'SC'
        
        DbSelectArea("SC1")
        DbSetOrder(2) // C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM
        If DbSeek( xFilial("SC1") + cProd + AllTrim( aItens[nLin,PITPR_DOC] ) )

            Private l110Auto  := .F.
            aRotina   := {}
            cCadastro := "Consulta ao Solicitação de Compras"
            INCLUI    := .F.
            ALTERA    := .F.

            //--Monta o aRotina para compatibilizacao
            AAdd( aRotina, { '' , '' , 0, 1 } )
            AAdd( aRotina, { '' , '' , 0, 2 } )
            AAdd( aRotina, { '' , '' , 0, 3 } )
            AAdd( aRotina, { '' , '' , 0, 4 } )
            AAdd( aRotina, { '' , '' , 0, 5 } )

            A110Visual(Alias(),RecNo(),2)
        Else
            MsgInfo( "Não foi localizada a S.C. !" )
        Endif

    Else
        
        DbSelectArea("SC7")
        DbSetOrder(4) // C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
        If DbSeek( xFilial("SC7") + cProd + AllTrim( aItens[nLin,PITPR_DOC] ) )

            Private l120Auto  := .F.
            Private nTipoPed  := 1
            aRotina   := {}
            cCadastro := "Consulta ao Pedido de Compra"
            INCLUI    := .F.
            ALTERA    := .F.

            //--Monta o aRotina para compatibilizacao
            AAdd( aRotina, { '' , '' , 0, 1 } )
            AAdd( aRotina, { '' , '' , 0, 2 } )
            AAdd( aRotina, { '' , '' , 0, 3 } )
            AAdd( aRotina, { '' , '' , 0, 4 } )
            AAdd( aRotina, { '' , '' , 0, 5 } )

            A120Pedido(Alias(),RecNo(),2)
        Else
            MsgInfo( "Não foi localizado o P.C. !" )
        Endif
    Endif

Return


/*/{Protheus.doc} Relatorio
Impressão dos dados que estão na tela
@type function
@version 12.1.25
@author Jorge Alberto - Solutio 
@since 26/08/2021
/*/
Static Function Relatorio()
    
    Local Cabec1     := " Produto                       Descrição                                                Qtd.Prev.      Qtd.Necess        Diferença"
	Local Cabec2     := ""

    Private cbTxt	 := ""
    Private cbCont	 := ""
    Private nOrdem 	 := 0
    Private Tamanho	 := "M"
    Private Limite	 := 80
    Private cImpri   := ""
    Private nTotal   := 0
    Private Titulo   := cTitulo
    Private cDesc1   := "Listagem do " + cTitulo
    Private cDesc2   := ""
    Private cDesc3   := ""
    Private aReturn	 := { "Zebrado", 1,"Administração", 2/*Retrato*/, 2, 1,"",1 }
    Private NomeProg := "MARC020"
    Private cPerg	 := ""
    Private nLastKey := 0 
	Private CONTFL   := 01
	Private m_pag    := 01
    Private nTipo    := 18
    Private nLinPrt  := 99
    Private wnrel 	 := "MARC020"
    Private cString  := ""
    Private lAbortPrint := .F.

    Begin Sequence

        wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,,,.F.)
        If ( nLastKey == 27 .Or. LastKey() == 27 )
            Break
        Endif

        SetDefault(aReturn,cString)
        If ( nLastKey == 27 .Or. LastKey() == 27 )
            Break
        Endif

        nTipo := If(aReturn[4]==1,15,18)
        RptStatus({|lEnd| RunReport(@lEnd,Cabec1,Cabec2,Titulo,nLinPrt) },Titulo)

    End Sequence
    
Return



/*/{Protheus.doc} RunReport
Processamento do array aDados para a impressão no relatório
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/08/2021
@param lEnd, logical, Cancelamento realizado pelo usuário
@param Cabec1, character, Cabeçalho 1
@param Cabec2, character, Cabeçalho 2
@param Titulo, character, Título
@param nLinPrt, numeric, Linha do relatório
/*/
Static Function RunReport(lEnd,Cabec1,Cabec2,Titulo,nLinPrt)

    Local nLin      := 0
    Local nLnPrt    := 999
    Local nTotLin   := Len(aDados)

    SetRegua( nTotLin )
    
    For nLin := 1 To nTotLin

        If nLnPrt > 60
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nLnPrt := 8
        Endif

        //          1         2         3         4         5         6         7         8         9         100       110       120       130
        //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        // Produto                       Descrição                                                Qtd.Prev.      Qtd.Necess        Diferença
        // 0000000001                    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  999,999,999.99   999,999,999.99   999,999,999.99

        @nLnPrt,001 psay aDados[nLin,PCAB_CODPROD] + Left(aDados[nLin,PCAB_DESCPROD],50)
        
        @nLnPrt,082 psay Transform( aDados[nLin,PCAB_QTDPREV], cZKQTENTRPct )

        @nLnPrt,099 psay Transform( aDados[nLin,PCAB_QTDNEC], cZKQTENTRPct )

        @nLnPrt,116 psay Transform( aDados[nLin,PCAB_DIFQTD], cZKQTENTRPct )

        nLnPrt := nLnPrt + 1

        If lEnd
            nLnPrt := nLnPrt + 1
            @nLnPrt,001 psay "<<< CANCELADO PELO USUÁRIO >>>"
            Exit
        EndIf

        IncRegua()
    Next

	SET DEVICE TO SCREEN
	If aReturn[5]==1
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif
	MS_FLUSH()

Return
