#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*--------------------------------------------------------------------
  Program : ZZ1MVC
  Purpose : CRUD single-screen form for table ZZ1 (MVC Model 1)
  Author  : Codex
--------------------------------------------------------------------*/

User Function ZZ1MVC()
    ZZ1Init()
Return

//----------------------------------------------------------------------
// Initializes the browse screen and controls
//----------------------------------------------------------------------
Static Function ZZ1Init()
    ZZ1Browse()
Return

//----------------------------------------------------------------------
// Load and browse ZZ1 records
//----------------------------------------------------------------------
Static Function ZZ1Browse()
    Local oBrowse := NIL

    If !AliasInDic("ZZ1")
        MsgStop("Tabela ZZ1 nao cadastrada no dicionario.", "Erro")
        Return
    EndIf

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZ1")
    oBrowse:SetDescription("Cadastro ZZ1")
    oBrowse:SetMenuDef("ZZ1MENU")
    oBrowse:Activate()
Return

//----------------------------------------------------------------------
// Menu definition for browse actions
//----------------------------------------------------------------------
Static Function ZZ1MENU()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION 'ZZ1View()'   OPERATION OP_VISUALIZAR ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION 'ZZ1Add()'    OPERATION OP_INCLUIR    ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION 'ZZ1Edit()'   OPERATION OP_ALTERAR    ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION 'ZZ1Delete()' OPERATION OP_EXCLUIR    ACCESS 0
Return aRotina

//----------------------------------------------------------------------
Static Function ZZ1View()
    ZZ1Execute(MODEL_OPERATION_VIEW)
Return

//----------------------------------------------------------------------
Static Function ZZ1Add()
    ZZ1Execute(MODEL_OPERATION_INSERT)
Return

//----------------------------------------------------------------------
Static Function ZZ1Edit()
    ZZ1Execute(MODEL_OPERATION_UPDATE)
Return

//----------------------------------------------------------------------
Static Function ZZ1Delete()
    ZZ1Execute(MODEL_OPERATION_DELETE)
Return

//----------------------------------------------------------------------
// Execute view according to operation
//----------------------------------------------------------------------
Static Function ZZ1Execute(nOperation)
    Local lRet := .T.
    Begin Sequence
        FWExecView("Cadastro ZZ1", "ZZ1MVC", nOperation)
    Recover Using oErr
        lRet := .F.
        MsgStop(oErr:Description, "Erro")
    End Sequence
Return lRet

//----------------------------------------------------------------------
// Model definition - loads ZZ1 structure from dictionary
//----------------------------------------------------------------------
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'ZZ1')
    Local oModel  := MPFormModel():New('ZZ1MVC', , , {|oM| ZZ1Commit(oM)}, {|oM| ZZ1Cancel(oM)})

    oModel:AddFields('ZZ1MASTER', , oStruct)
    oModel:SetPrimaryKey({})
    oModel:SetDescription('Cadastro ZZ1')
Return oModel

//----------------------------------------------------------------------
// View definition
//----------------------------------------------------------------------
Static Function ViewDef()
    Local oModel  := FWLoadModel('ZZ1MVC')
    Local oStruct := FWFormStruct(2, 'ZZ1')
    Local oView   := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZ1', oStruct, 'ZZ1MASTER')
Return oView

//----------------------------------------------------------------------
// Handles OK/Delete events (commit)
//----------------------------------------------------------------------
Static Function ZZ1Commit(oModel)
    Local lOk := FWFormCommit(oModel)

    If lOk
        Do Case
            Case oModel:GetOperation() == MODEL_OPERATION_INSERT
                FWAlertSuccess('Registro incluido com sucesso!')
            Case oModel:GetOperation() == MODEL_OPERATION_UPDATE
                FWAlertSuccess('Registro alterado com sucesso!')
            Case oModel:GetOperation() == MODEL_OPERATION_DELETE
                FWAlertSuccess('Registro excluido com sucesso!')
        EndCase
    Else
        MsgStop('Falha ao gravar registro!', 'Erro')
    EndIf
Return lOk

//----------------------------------------------------------------------
// Handles Cancel event
//----------------------------------------------------------------------
Static Function ZZ1Cancel(oModel)
    FWFormCancel(oModel)
    MsgInfo('Operacao cancelada.')
Return .T.
