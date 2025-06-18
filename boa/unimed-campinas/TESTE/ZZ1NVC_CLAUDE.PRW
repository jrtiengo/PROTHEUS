#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ZZCADMVC
Tela de cadastro MVC Modelo 1 para tabela ZZ1
@author Desenvolvedor
@since 16/06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ZZ1CADMVC1()

    Local oBrowse
    
    oBrowse := FWMBrowse():New()                        //Cria o objeto de browse
    oBrowse:SetAlias("ZZ1")                             //Define a tabela
    oBrowse:SetDescription("Cadastro de Sub-Grupos")    //Define o titulo
    oBrowse:SetFields(GetFields())                      //Define campos do browse   
    oBrowse:SetMenuDef("ZZCADMVC")                      //Habilita o menu funcional
    oBrowse:Activate()                                  //Ativa o browse                            
    
Return Nil

Static Function MenuDef()

    Local aRotina := {}
    
    ADD OPTION aRotina TITLE "Pesquisar"   ACTION "PesqBrw"            OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"  ACTION "VIEWDEF.ZZ1CADMVC1" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"     ACTION "VIEWDEF.ZZ1CADMVC1" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"     ACTION "VIEWDEF.ZZ1CADMVC1" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"     ACTION "VIEWDEF.ZZ1CADMVC1" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"    ACTION "VIEWDEF.ZZ1CADMVC1" OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar"      ACTION "VIEWDEF.ZZ1CADMVC1" OPERATION 9 ACCESS 0
    
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados MVC
@author Desenvolvedor
@since 16/06/2025
@version 1.0
@return Objeto do modelo de dados
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStruZZ1 := FWFormStruct(1, "ZZ1")
    
    // Cria o objeto do modelo de dados
    oModel := MPFormModel():New("ZZCADMVC_MODEL", /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)
    
    // Adiciona a estrutura do modelo
    oModel:AddFields("ZZ1MASTER", /*cOwner*/, oStruZZ1, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
    
    // Define a chave primária
    oModel:SetPrimaryKey({"ZZ1_FILIAL", "ZZ1_CODIGO"})
    
    // Adiciona a descrição do modelo
    oModel:SetDescription("Modelo de Dados ZZ1")
    
    // Adiciona a descrição do componente
    oModel:GetModel("ZZ1MASTER"):SetDescription("Dados da ZZ1")
    
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface visual MVC
@author Desenvolvedor
@since 16/06/2025
@version 1.0
@return Objeto da interface visual
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oView
    Local oModel := ModelDef()
    Local oStruZZ1 := FWFormStruct(2, "ZZ1")
    
    // Cria o objeto de view
    oView := FWFormView():New()
    
    // Define qual modelo de dados será utilizado
    oView:SetModel(oModel)
    
    // Adiciona a estrutura de campos
    oView:AddField("VIEW_ZZ1", oStruZZ1, "ZZ1MASTER")
    
    // Cria um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox("TELA", 100)
    
    // Relaciona o identificador da view com o "box" para exibição
    oView:SetOwnerView("VIEW_ZZ1", "TELA")
    
    // Define campos incremental
    oView:EnableTitleView("VIEW_ZZ1", "Cadastro ZZ1")
    
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFields
Campos para Exebi��o no browse
@author Desenvolvedor
@since 16/06/2025
@version 1.0
@return Array com os campos do browse
/*/
//-------------------------------------------------------------------
Static Function GetFields()

    Local aFields := {}
    
    // Adiciona os campos que serão exibidos no browse
    AADD(aFields, {"ZZ1_CODIGO", "C�digo",     "@!", 6})
    AADD(aFields, {"ZZ1_NOME",   "Descri��o",  "@!", 50})
    
Return(aFields)

//-------------------------------------------------------------------
/*/{Protheus.doc} ZZ1INIT
Inicialização de campos
@author Desenvolvedor
@since 16/06/2025
@version 1.0
@param cCampo - Campo a ser inicializado
@return Variant - Valor inicial do campo
/*/
//-------------------------------------------------------------------
User Function ZZ1INIT(cCampo)
    Local xRet := ""
    
    Do Case
        Case cCampo == "ZZ1_CODIGO"
            // Gera código sequencial automático
            xRet := GetSXENum("ZZ1", "ZZ1_CODIGO")
            
        Case cCampo == "ZZ1_STATUS"
            // Status padrão ativo
            xRet := "A"
            
        Case cCampo == "ZZ1_DTNASC"
            // Data padrão vazia
            xRet := CtoD("  /  /    ")
            
    EndCase
    
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZZ1COMMIT
Processamento após gravação
@author Desenvolvedor
@since 16/06/2025
@version 1.0
@param oModel - Modelo de dados
@return Logical - .T. se processamento ok
/*/
//-------------------------------------------------------------------
Static Function ZZ1COMMIT(oModel)

    Local lRet := .T.
    Local nOperation := oModel:GetOperation()
    
    // Processa a gravação padrão
    FWFormCommit(oModel)
    
    // Processamentos específicos por operação
    Do Case
        Case nOperation == MODEL_OPERATION_INSERT
            FWAlertSuccess('Registro incluido com sucesso!')
        Case nOperation == MODEL_OPERATION_UPDATE
            FWAlertSuccess('Registro alterado com sucesso!')  
        Case nOperation == MODEL_OPERATION_DELETE
            FWAlertSuccess('Registro exclu�do com sucesso!')
            
    EndCase
    
Return(lRet)
