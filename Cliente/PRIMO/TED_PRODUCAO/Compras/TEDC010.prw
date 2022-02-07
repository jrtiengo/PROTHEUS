#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TEDC010
Cadastro da tabela SZ2 - Contabilização de Serviços.
@type function
@version 
@author Jorge Alberto - Solutio
@since 18/08/2020
/*/
User Function TEDC010()

	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ2")
	oBrowse:SetDescription("Contabilização de Serviços")
	oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
Opções do Menu
@type function
@version 
@author Jorge Alberto - Solutio
@since 18/08/2020
@return array
/*/
Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE "Incluir"    	ACTION "VIEWDEF.TEDC010"	OPERATION MODEL_OPERATION_INSERT	ACCESS 0
	ADD OPTION aRot TITLE "Visualizar" 	ACTION "VIEWDEF.TEDC010"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0
	ADD OPTION aRot TITLE "Alterar"    	ACTION "VIEWDEF.TEDC010"	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0
	ADD OPTION aRot TITLE "Excluir"    	ACTION "VIEWDEF.TEDC010"	OPERATION MODEL_OPERATION_DELETE	ACCESS 0

Return( aRot )


/*/{Protheus.doc} MODELDEF
Modelo do Cadastro
@type function
@version 
@author Jorge Alberto - Solutio
@since 18/08/2020
@return object
/*/
Static Function MODELDEF()

	Local oModel := Nil
	Local oStSZ2 := FWFormStruct(1, "SZ2")

	oModel := MPFormModel():New("TEDC010MD",,{|oModel| TED010Pos( oModel ) })
	oModel:AddFields("SZ2MASTER", ,oStSZ2)
    oModel:SetPrimaryKey({}) //Z2_FILIAL + Z2_PRODUTO + Z2_GRUPO
	oModel:SetDescription("Contabilização de Serviços")

Return( oModel )


/*/{Protheus.doc} VIEWDEF
Visão do cadastro
@type function
@version 
@author Jorge Alberto - Solutio
@since 18/08/2020
@return object
/*/
Static Function VIEWDEF()

	Local oModel := ModelDef()
	Local oStSZ2 := FWFormStruct(2, "SZ2")
	Local oView := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SZ2", oStSZ2, "SZ2MASTER")
	oView:CreateHorizontalBox("SZ2",100)
	oView:SetOwnerView("VIEW_SZ2","SZ2")

Return( oView )


/*/{Protheus.doc} TED010Pos
Função que pega o Produto e o Grupo, para consultar na base para que não permita a duplicação de registro.
ATENCAO: Essa função equilave ao "TUDOOK" dos cadastros !
@type function
@version 
@author Jorge Alberto - Solutio
@since 18/08/2020
@param oModel, object, Modelo
@return logical, Permite ou não a Inclusão ou Alteração do registro.
/*/
Static Function TED010Pos( oModel )

    Local nOperation := oModel:GetOperation()
	Local lRet := .T.
    Local cProd := FwFldGet("Z2_PRODUTO")
    Local cGrupo := FwFldGet("Z2_GRUPO")
    Local aArea := SZ2->( GetArea() )

    If nOperation == MODEL_OPERATION_INSERT

        DbSelectArea("SZ2")
        DbSetOrder(1)
        If DbSeek( FWxFilial("SZ2") + cProd + cGrupo )
            Help( ,,"HELP", "", "Já foi cadastrado o Produto e Grupo informados !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Altere o Produto ou o Grupo."} )
            lRet := .F.
        EndIf

    ElseIf ( nOperation == MODEL_OPERATION_UPDATE .And. ( cProd <> SZ2->Z2_PRODUTO .Or. cGrupo <> SZ2->Z2_GRUPO ) )
        
        DbSelectArea("SZ2")
        DbSetOrder(1)
        If DbSeek( FWxFilial("SZ2") + cProd + cGrupo )
            Help( ,,"HELP", "", "Já foi cadastrado o Produto e Grupo informados !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Altere o Produto ou o Grupo."} )
            lRet := .F.
        EndIf
    EndIf

    DbSelectArea("SB1")
    DbSetOrder(1)
    DbSeek( FWxFilial("SB1") + cProd )
    If SB1->B1_TIPO <> "SV"
        Help( ,,"HELP", "", "Produto não é um Serviço !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Somente devem ser informados produtos do Tipo Serviço."} )
        lRet := .F.
    EndIf

    RestArea( aArea )
	
Return( lRet )


/*/{Protheus.doc} GetConta
Retornar a Conta Contábil do cadastro customizado chamado "Contabilização de Serviços" - tabela SZ2.
Essa função é chamada via gatilho nos campos:
SD1 -> D1_COD e D1_CC.
SC7 -> C7_PRODUTO e C7_CC.
@type function
@version 
@author Jorge Alberto - Solutio
@since 19/08/2020
@return character, Código da Conta Contábil da tabela customizada ou o proprio valor que tiver sido informado no D1_CONTA.
/*/
User Function GetConta()
    
    Local aArea := GetArea()
    Local aAreaSB1 := SB1->( GetArea() )
    Local cAliAtu := Alias()
    Local nPosProd := aScan( aHeader, { |x| AllTrim(x[2]) == 'D1_COD' } )
    Local nPosCC := aScan( aHeader, { |x| AllTrim(x[2]) == 'D1_CC' } )
    Local nPosConta := aScan( aHeader, { |x| AllTrim(x[2]) == 'D1_CONTA' } )
    Local cProd := ""
    Local cCC := ""
    Local cRet := ""

    If nPosProd <= 0
        nPosProd := aScan( aHeader, { |x| AllTrim(x[2]) == 'C7_PRODUTO' } )
        nPosCC := aScan( aHeader, { |x| AllTrim(x[2]) == 'C7_CC' } )
        nPosConta := aScan( aHeader, { |x| AllTrim(x[2]) == 'C7_CONTA' } )
    EndIf

    cProd := aCols[n,nPosProd]
    cCC := Left( aCols[n,nPosCC], 2 )
    cRet := aCols[n,nPosConta]
    
    If !Empty( cProd ) .And. !Empty( cCC )
        If "SV" == Posicione( "SB1", 1, FWxFilial( "SB1") + cProd, "B1_TIPO" )
            // O índice é Z2_FILIAL + Z2_PRODUTO + Z2_GRUPO, porém os 2 primeiros caracteres do Centro de Custo, fazem parte do Grupo lá no cadastro da SZ2.
            cRet := Posicione( "SZ2", 1, FWxFilial("SZ2") + cProd + cCC, "Z2_CONTA" )
        EndIf
    EndIf

    If !Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf
    RestArea( aAreaSB1 )
    RestArea( aArea )

Return( cRet )
