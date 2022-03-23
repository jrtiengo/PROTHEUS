#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} MARC090
Rotina que mostra os logs dos processamentos realizados por algumas opções dentro da rotina de Gestor de OP ( MARA090 )
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 13/01/2022
/*/
User Function MARC090()

    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CV8")
    oBrowse:SetDescription("Log de Processamento")
    oBrowse:SetFilterDefault( "LEFT( CV8->CV8_PROC, 7 ) == 'MARA090' " )
    oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
Monta as opões do menu
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 13/01/2022
@return array, Opções do menu
/*/
Static Function MenuDef()
    
    Local aRot := {}
    ADD OPTION aRot TITLE "Visualizar"  ACTION "VIEWDEF.MARC090"    OPERATION 2  ACCESS 0
    ADD OPTION aRot TITLE "Buscar OP"   ACTION "U_C90BUSPR()"       OPERATION 2  ACCESS 0

Return( aRot )


/*/{Protheus.doc} ModelDef
Model da rotina
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 13/01/2022
@return object, Objeto do Model
/*/
Static Function ModelDef()
    
    Local oModel := Nil
    Local oStCV8 := FWFormStruct(1, "CV8")

    oModel := MPFormModel():New("MARC090MD", /*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMCV8",/*cOwner*/,oStCV8)
    oModel:SetPrimaryKey({'CV8_FILIAL', 'CV8_PROC', 'CV8_DATA', 'CV8_HORA'})
    oModel:SetDescription("Log de Processamento")
    oModel:GetModel("FORMCV8"):SetDescription("Log de Processamento")

Return( oModel )


/*/{Protheus.doc} ViewDef
View da rotina
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 13/01/2022
/*/
Static Function ViewDef()

    Local oModel := FWLoadModel("MARC090")
    Local oStCV8 := FWFormStruct(2, "CV8")
    Local oView
 
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CV8", oStCV8, "FORMCV8")
    oView:CreateHorizontalBox("TELA",100)
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("VIEW_CV8","TELA")

Return( oView )


/*/{Protheus.doc} C90BUSPR
Buscar o Produto nos logs
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 23/07/2021
/*/
User Function C90BUSPR()

    Local oSize
    Local oSizeSup
    Local oDlg
    Local oBrwCab
    Local oGgpOpcoes
    Local oGgpCab
    Local oGgpInf
    Local cOP    := Space( 14 )
    Local cMGet  := ""
    Local aDados := {}

    AADD( aDados, Array(5) )

    // #############################################################
	//    Calcula as 2 dimensões, onde cada uma terá seus objetos
    // #############################################################
	oSize := FwDefSize():New( .F. ) // Não terá barra com os botões
	oSize:AddObject( "SUPERIOR", 100, 40, .T., .T. )
	oSize:AddObject( "INFERIOR", 100, 60, .T., .T. )
	oSize:lProp := .T. // Proporcional
	oSize:Process() // Dispara os calculos

    // #############################################################
	//      Divide a Superior em 2
    // #############################################################
	oSizeSup := FwDefSize():New( .F. )
	oSizeSup:aWorkArea := oSize:GetNextCallArea( "SUPERIOR" )
	oSizeSup:AddObject( "OPCOES", 15, 100, .T., .T. )
	oSizeSup:AddObject( "CAB"   , 85, 100, .T., .T. )
	oSizeSup:lLateral := .T. //Calculo em Lateral
	oSizeSup:lProp := .T.
	oSizeSup:Process()

    oDlg := MSDialog():New( oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],"Busca OP",,,.F.,,,,,,.T.,,,.T. )

    oGgpOpcoes := TGroup():New( oSizeSup:GetDimension("OPCOES","LININI"),;
                                oSizeSup:GetDimension("OPCOES","COLINI"),;
                                oSizeSup:GetDimension("OPCOES","LINEND"),;
                                oSizeSup:GetDimension("OPCOES","COLEND"),'Opções',oDlg,,,.T.)

    TGet():New( oSizeSup:GetDimension("OPCOES","LININI")+15,;
                oSizeSup:GetDimension("OPCOES","COLINI")+10,;
                {|u| If(PCount()>0,cOP:=u,cOP)},oGgpOpcoes,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC2","cOP",,,,,,,"OP",1/*Label no topo*/)

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+40,;
                oSizeSup:GetDimension("OPCOES","COLINI")+10,;
                "Consultar",oGgpOpcoes,{|| MsgRun( "Buscando pela OP...  aguarde...", "Busca Produto", {|| BuscaOP( AllTrim(cOP), @oBrwCab, @aDados, oMGet, @cMGet ) } ) },037,012,,,,.T./*lPixel*/ )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+60,;
                oSizeSup:GetDimension("OPCOES","COLINI")+10,;
                "Voltar",oGgpOpcoes,{|| oDlg:End() },037,012,,,,.T./*lPixel*/ )

    oGgpCab := TGroup():New(oSizeSup:GetDimension("CAB","LININI"),;
                            oSizeSup:GetDimension("CAB","COLINI"),;
                            oSizeSup:GetDimension("CAB","LINEND"),;
                            oSizeSup:GetDimension("CAB","COLEND"),'Logs da OP',oDlg,,,.T.)

    oBrwCab := TCBrowse():New(  oSizeSup:GetDimension("CAB","LININI")+10,;
                                oSizeSup:GetDimension("CAB","COLINI")+5,;
                                oSizeSup:GetDimension("CAB","XSIZE")-10,;
                                oSizeSup:GetDimension("CAB","YSIZE")-15,;
                                ,,,oGgpCab,,,,{|| Detalhe( oMGet, @cMGet, aDados[oBrwCab:nAt,05] ) },,,,,,,,,,.T./*lPixel*/ )
    
    oBrwCab:AddColumn( TCColumn():New("Data"   ,{|| aDados[oBrwCab:nAt,01]},,,,"CENTER", 40 ) )
    oBrwCab:AddColumn( TCColumn():New("Hora"   ,{|| aDados[oBrwCab:nAt,02]},,,,"CENTER", 30 ) )
    oBrwCab:AddColumn( TCColumn():New("Usuário",{|| aDados[oBrwCab:nAt,03]},,,,"CENTER", 60 ) )
    oBrwCab:AddColumn( TCColumn():New("Resumo" ,{|| aDados[oBrwCab:nAt,04]},,,,"LEFT"  , 100 ) )

    oGgpInf := TGroup():New( oSize:GetDimension("INFERIOR","LININI"),;
                             oSize:GetDimension("INFERIOR","COLINI"),;
                             oSize:GetDimension("INFERIOR","LINEND"),;
                             oSize:GetDimension("INFERIOR","COLEND"),'Detalhes do log',oDlg,,,.T.)

    oMGet := TMultiGet():New(   oSize:GetDimension("INFERIOR","LININI")+10,;
                                oSize:GetDimension("INFERIOR","COLINI")+5,;
                                {|u| If(PCount()>0,cMGet:=u,cMGet)},oGgpInf,;
                                oSize:GetDimension("INFERIOR","XSIZE")-10,;
                                oSize:GetDimension("INFERIOR","YSIZE")-15,;
                                , .T./*lHScroll*/,CLR_BLACK,CLR_WHITE,,.T./*lPixel*/,,,,.F.,.F.,.T./*lReadOnly*/,,,,,.T./*lVScroll*/ )

    oDlg:Activate(,,,.T.)

Return


/*/{Protheus.doc} Detalhe
Preenche o conteúdo do Multiget conforme a linha selecionada
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 13/01/2022
@param oMGet, object, Objeto do Multiget
@param cMGet, character, Variavel que será atualizada do Multiget
@param nRecCV8, numeric, Recno da CV8
/*/
Static Function Detalhe( oMGet, cMGet, nRecCV8 )

    cMGet := AllTrim(Space(Len(cMGet)))

    If nRecCV8 > 0
        CV8->( DbGoTo( nRecCV8 ) )
        cMGet := AllTrim( CV8->CV8_DET )
    EndIf
    oMGet:Refresh()
Return


/*/{Protheus.doc} BuscaOP
Consultar a OP informado nos log
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 13/01/2022
@param cOP, character, Produto informado pelo usuário
@param oBrwCab, object, Browse
@param aDados, array, Dados que serão apresentados
/*/
Static Function BuscaOP( cOP, oBrwCab, aDados, oMGet, cMGet )

    Local cAliAtu  := ''
    Local cQuery   := ''
    Local aAreaCV8 := CV8->(GetArea())
    Local cAliAnt  := Alias()
    
    aDados := {}

    If .NOT. Empty( cOP )

        cQuery += "SELECT CV8_DATA, CV8_HORA, CV8_USER, CV8_MSG, R_E_C_N_O_ AS RECCV8, CV8_DET "
        cQuery += "FROM " + RetSqlName("CV8") + " "
        cQuery += "WHERE CV8_FILIAL = '" +FWFilial("CV8")+ "' "
        cQuery += "AND CV8_PROC = 'MARA090' "
        cQuery += "AND ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), CV8_DET)),'') LIKE '%" + cOP + "%' "
        cQuery += "AND D_E_L_E_T_ = ' ' "
        cQuery += "ORDER BY CV8_DATA, CV8_HORA, R_E_C_N_O_ "

        cAliAtu := GetNextAlias()
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAtu,.F.,.T.)
        TCSetField( cAliAtu, "CV8_DATA", "D", 8, 0 )
        While .NOT. (cAliAtu)->( EOF() )

            AADD( aDados, { DtoC((cAliAtu)->CV8_DATA), (cAliAtu)->CV8_HORA, (cAliAtu)->CV8_USER, AllTrim((cAliAtu)->CV8_MSG), (cAliAtu)->RECCV8 } )
            (cAliAtu)->( DbSkip() )
        EndDo
        (cAliAtu)->( DbCloseArea() )
    EndIf

    If Len( aDados ) <= 0
        AADD( aDados, Array(5) )
    EndIf

    oBrwCab:setArray( aDados )
    oBrwCab:bLine := {||{aDados[oBrwCab:nAt,01],; 
                        aDados[oBrwCab:nAt,02],;
                        aDados[oBrwCab:nAt,03],;
                        aDados[oBrwCab:nAt,04] }}
    oBrwCab:nAt := 1
    oBrwCab:Refresh()

    Detalhe( oMGet, @cMGet, aDados[oBrwCab:nAt,05] )

    RestArea( aAreaCV8 )
    DbSelectArea( cAliAnt )

Return
