#Include "TOTVS.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} MARA100
Cadastro de Funcionários simplificado
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
/*/
User Function MARA100()

	Local oBrowse

    Private lInclui := .F.
    Private lAltera := .F.
    Private lVisual := .F.
    Private cMat    := ""
    Private cNome   := ""
    Private cCC     := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SRA")
	oBrowse:SetDescription("Cadastro de Funcionários")
	oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
Função que carrega as opções do menu
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
@return array, Opções do menu
/*/
Static Function MenuDef()

	Local aRotina := {}

    //ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MARA100" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
    //ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.MARA100" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    //ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.MARA100" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar" ACTION "U_MARA100V()" OPERATION MODEL_OPERATION_VIEW 	 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "U_MARA100I()" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "U_MARA100A()" OPERATION MODEL_OPERATION_UPDATE ACCESS 0

Return( aRotina )


/*/{Protheus.doc} ModelDef
Model da rotina
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
@return object, objeto do model
/*/
Static Function ModelDef()

	Local oModel := Nil
	Local oStSRA := FWFormStruct(1, "SRA")

	oModel := MPFormModel():New("MARA100MD",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/) 
	oModel:AddFields("SRAMASTER", ,oStSRA)
	
Return( oModel )


/*/{Protheus.doc} ViewDef
View da rotina
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
@return object, objeto da view
/*/
Static Function ViewDef()

    Local oView
    Local oModel := FWLoadModel("MARA100")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField( "SRAMASTER" , FWFormStruct(2,"SRA"))
    oView:CreateHorizontalBox("ALL",100)
    oView:SetOwnerView("SRAMASTER","ALL")
Return( oView )


/*/{Protheus.doc} MARA100I
Opção de Inclusão
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
/*/
User Function MARA100I()

    lVisual := .F.
    lInclui := .T.
    lAltera := .F.
    cMat    := Soma1( PadR( AllTrim( MpSysExecScalar( "SELECT MAX(RA_MAT) ULTMAT FROM " + RetSqlName("SRA") + " WHERE D_E_L_E_T_ = ' '", "ULTMAT" ) ), TamSX3("RA_MAT")[1] ) )
    cNome   := Space( TamSX3("RA_NOME")[1] )
    cCC     := Space( TamSX3("RA_CC")[1] )

    MRA080()

Return


/*/{Protheus.doc} MARA100A
Opção de Alteração
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
/*/
User Function MARA100A()

    lVisual := .F.
    lInclui := .F.
    lAltera := .T.
    cMat    := SRA->RA_MAT
    cNome   := SRA->RA_NOME
    cCC     := SRA->RA_CC

    MRA080()

Return


/*/{Protheus.doc} MARA100V
Opção de Visualização
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
/*/
User Function MARA100V()

    lVisual := .T.
    lInclui := .F.
    lAltera := .F.
    cMat    := SRA->RA_MAT
    cNome   := SRA->RA_NOME
    cCC     := SRA->RA_CC

    MRA080()

Return


/*/{Protheus.doc} MRA080
Rotina principal que irá montar a tela com os dados e irá gravar na tabela SRA
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
/*/
Static Function MRA080()

    Local oDlg
    Local oGrp
    Local lConf := .F.

    oDlg := MSDialog():New( 092,232,596,1123,"Funcionário",,,.F.,,,,,,.T.,,,.T. )
    
        oGrp := TGroup():New( 016,016,180,420,"Cadastro de Funcionário",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

        TGet():New( 040,025,{|u| If(PCount()>0,cMat:=u,cMat)},oGrp,044,008,'',{|| NaoVazio() .And. EXISTCHAV("SRA",cMat) .And. FreeForUse("SRA",cMat) },CLR_BLACK,CLR_WHITE,,,,.T.,"Matrícula do Funcionário",,{|| lInclui }/*bWhen*/,.F.,.F.,,.F.,.F.,"","cMat",,,,,,,"Matrícula",1/*Label no topo*/)
        TGet():New( 065,025,{|u| If(PCount()>0,cNome:=u,cNome)},oGrp,215,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"Nome do Funcionário",,{|| lInclui .Or. lAltera }/*bWhen*/,.F.,.F.,,.F.,.F.,"","cNome",,,,,,,"Nome",1/*Label no topo*/)
        TGet():New( 090,025,{|u| If(PCount()>0,cCC:=u,cCC)},oGrp,044,008,'',{|| NaoVazio() .And. EXISTCPO("CTT",cCC) },CLR_BLACK,CLR_WHITE,,,,.T.,"Centro de Custo do Funcionário",,{|| lInclui .Or. lAltera }/*bWhen*/,.F.,.F.,,.F.,.F.,"CTT","cCC",,,,,,,"Centro de Custo",1/*Label no topo*/)

        If .NOT. lVisual
            TButton():New( 204,068,"Gravar"  ,oDlg,{|| IIF( TudoOK(), ( lConf := .T., oDlg:End() ), NIL ) },064,012,,,,.T.,,"",,,,.F. )
        EndIf
        TButton():New( 204,296,"Cancelar",oDlg,{|| lConf := .F., oDlg:End() },064,012,,,,.T.,,"",,,,.F. )

    oDlg:Activate(,,,.T.)

    If lConf
        DbSelectArea("SRA")
        RecLock("SRA", lInclui)

            If lInclui
                SRA->RA_MAT := cMat
            EndIf

            // Tanto na inclusão como na Alteração irá gravar esses campos
            SRA->RA_FILIAL := FWFilial("SRA")
            SRA->RA_NOME   := cNome
            SRA->RA_CC     := cCC
        MsUnlock()
    EndIf

Return


/*/{Protheus.doc} TudoOK
Validar se todos os campos da tela foram preenchidos
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 04/01/2022
@return logical, .T. se todos os campos estão preenchidos ou .F. caso contrário
/*/
Static Function TudoOK()

    Local lOk := .T.

    If( Empty( cMat ) .Or. Empty( cNome ) .Or. Empty( cCC ) )
        MsgAlert( "Informe todos os campos", "Funcionário")
        lOk := .F.
    EndIf

Return( lOk )
