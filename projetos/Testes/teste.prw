#include "totvs.ch"
#include 'fwMVCDef.ch'

/*
Programa.: Z49MVC.PRW
Tipo.....: Atualização 
Autor....: Daniel Gouveia - Unidade TOTVS Londrina
Data.....: 10/06/2018
Descrição: Declaração de Transporte
Notas....: Rotina desenvolvida em MVC para atender ao Modelo 2 de template, quando a mesma tabela
		   é o cabeçalho e os itens
*/

static cTitle 	:= "Declaração de Transporte"
static cProgram := "Z49MVC"

//-------------------------------------------------------------------
/*/{Protheus.doc} Z49MVC
Função principal do programa
@type function
@author Daniel Gouveia - Unidade TOTVS Londrina
@since 10/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
user function Z49MVC()
	local aArea   := GetArea()
	local oBrowse := nil
	local cFunBkp := funName()
	Private cButOp := ""

	setFunName(cProgram)

	//Cria um browse para a Z49
	oBrowse := fwMBrowse():New()
	oBrowse:SetAlias("Z49")
	oBrowse:SetDescription(cTitle)
	oBrowse:Activate()

	restArea(aArea)

	setFunName(cFunBkp)
return(nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu MVC
@type function
@author Daniel Gouveia - Unidade TOTVS Londrina
@since 10/06/2018
@version 1.0
@return aRot, array, conteúdo do menu
/*/
//-------------------------------------------------------------------
static function MenuDef()
	local aRot := {}
	local aSub := {}

	//Adicionando opções
	add option aSub title 'Declaracao'   action  "U_Z49MVCB" operation 8 access 0
	add option aSub title 'Etiqueta'	 action  "U_Z49MVCC" operation 9 access 0

	add option aRot title 'Visualizar' action 'ViewDef.' + cProgram operation MODEL_OPERATION_VIEW access 0
//	add option aRot title 'Incluir'    action 'ViewDef.' + cProgram operation MODEL_OPERATION_INSERT access 0
	add option aRot title 'Incluir'    action "U_Z49MANUT('I')" operation MODEL_OPERATION_INSERT access 0
//	add option aRot title 'Alterar'    action 'ViewDef.' + cProgram operation MODEL_OPERATION_UPDATE access 0
	add option aRot title 'Alterar'    action "U_Z49MANUT('A')" operation MODEL_OPERATION_UPDATE access 0
	add option aRot title 'Cancelar'   action "U_Z49MANUT('C')" operation MODEL_OPERATION_DELETE access 0
	add option aRot title 'Imprimir'   action "U_RELZ49()" operation 6 access 0
	add option aRot title 'Etiqueta'   action "U_ETIQLOG2()" operation 6 access 0 //INCLUIDO POR ANA CAROLINE EM 15/03/2021
	add option aRot title 'Faixa'  	   action aSub operation 7 access 0 //INCLUIDO POR ANA CAROLINE EM 15/03/2021

return(aRot)

user function Z49MVCB()

	local aPergs	:= {}
	local aRet		:= {}

	aAdd( aPergs ,{1,"Declarac De ",Space(TamSx3("Z49_CODIGO")[1]),"","","   ","",0,.F.}) // 01
	aAdd( aPergs ,{1,"Declarac Ate",Space(TamSx3("Z49_CODIGO")[1]),"","","   ","",0,.F.}) // 02
	aAdd( aPergs ,{1,"Usuario     ",Space(TamSx3("Z49_USUARI")[1]),"@!","","   ","",0,.F.}) // 02

	If !ParamBox(aPergs ,"Z49MVCB",@aRet, /*{|x| Validbox() }*/ ,{} , .T. , , , , ,.T.,.T. )
		return
	EndIf

	MsgRun( "Gerando o etiquetas, aguarde...","Declaração", {|| U_RELZ492(MV_PAR01,MV_PAR02,MV_PAR03) } )

return nil

user function Z49MVCC()

	local aPergs	:= {}
	local aRet		:= {}

	aAdd( aPergs ,{1,"Declarac De ",Space(TamSx3("Z49_CODIGO")[1]),"","","   ","",0,.F.}) // 01
	aAdd( aPergs ,{1,"Declarac Ate",Space(TamSx3("Z49_CODIGO")[1]),"","","   ","",0,.F.}) // 02
	aAdd( aPergs ,{1,"Usuario     ",Space(TamSx3("Z49_USUARI")[1]),"@!","","   ","",0,.F.}) // 02

	If !ParamBox(aPergs ,"Z49MVCB",@aRet, /*{|x| Validbox() }*/ ,{} , .T. , , , , ,.T.,.T. )
		return
	EndIf

	MsgRun( "Gerando o etiquetas, aguarde...", "Declaração" , {|| faixaetq(MV_PAR01,MV_PAR02,MV_PAR03) } )

return nil

static function faixaetq(cCod1,cCod2,cContem)

	local aRecnos   := GetQry(cCod1,cCod2,cContem)
	local nX        := 1
	Local _area     := getarea()
	Local _aZ49     := Z49->(getarea())
	Private cPerg := "ETIQLOG2"

	if len(aRecnos) > 0

		IF !pergunte(cPerg,.T.)
			return
		ENDIF


		for nX  := 1 to len(aRecnos)
			dbSelectArea("Z49")
			Z49->(dbgoto(aRecnos[nX]))
			U_ETIQLOG3()
		next

	endif
	restarea(_aZ49)
	restarea(_Area)

return nil

static function GetQry(cCod1,cCod2,cContem)

	local aRet      := {}
	local cQuery    := ""

	cQuery := " 	    SELECT * FROM (
	cQuery += " 		SELECT R_E_C_N_O_ NRECNO , Z49_CODIGO CODIGO, Z49_FILIAL FILIAL
	cQuery += " 		FROM "+RetSqlName("Z49")
	cQuery += " 		WHERE Z49_FILIAL = '"+xFilial("Z49")+"'"
	cQuery += " 		AND Z49_CODIGO BETWEEN '"+cCod1+"' AND '"+cCod2+"'
	cQuery += " 		AND Z49_STATUS <> 'CANCELADA'
	cQuery += " 	    AND Z49_USUARI LIKE '%"+AllTrim(cContem)+"%'
	cQuery += " 		AND D_E_L_E_T_ = ''
	cQuery += " 		) ASD
	cQuery += " 		WHERE NRECNO = (SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("Z49")+" WHERE
	cQuery += " 	    Z49_FILIAL = FILIAL AND Z49_CODIGO = CODIGO AND D_E_L_E_T_ = '' )
	cQuery += " 		ORDER BY NRECNO "

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), 'TRAB', .F., .T.)
	while TRAB->(!eof())
		aadd(aRet,TRAB->NRECNO)
		TRAB->(dbSkip())
	enddo
	TRAB->(dbclosearea())


return aRet

/*/{Protheus.doc} Z49MVC
Classe do Observer 
@author delson.filho
@since 14/07/2020
@version 1.0
/*/

	Class Z49MVC FROM FWModelEvent

		Method New()
		Method VldActivate()
		Method ModelPosVld()
		Method AfterTTS()
	End Class

/*/{Protheus.doc} New
Metodo New que inicia a classe
@author delson.filho
@since 14/07/2020
@version 1.0
/*/

Method New() Class Z49MVC
Return

/*/{Protheus.doc} VldActivate
Metodo de validação de ativação do modelo
@author delson.filho
@since 14/07/2020
@version 1.0
/*/

Method VldActivate(oModel, cModelId) Class Z49MVC
	Local lRet      := .T.

return lRet

Method ModelPosVld(oModel, cModelId) Class Z49MVC
return .T.

Method AfterTTS(oModel, cModelId) Class Z49MVC
return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@type function
@author Daniel Gouveia - Unidade TOTVS Londrina
@since 10/06/2018
@version 1.0
@return oModel, objeto, modelo de dados
/*/
//-------------------------------------------------------------------
static function ModelDef()
	local oModel   := nil
	local oStrHead := fwFormModelStruct():New()
	local oStrZ49  := fwFormStruct(1, 'Z49')
	local aZ49Rel  := {}
	Local oEvent := Z49MVC():New()


	//Adiciona a tabela na estrutura temporária
	oStrHead:AddTable('Z49', {'Z49_CODIGO', 'Z49_CLIENT', 'Z49_LOJA','Z49_CODPOL','Z49_NOMECL','Z49_NREDUZ' ;
		,'Z49_CONTAT','Z49_TIPOEN','Z49_ENDCON','Z49_TRANSP','Z49_NOMETR','Z49_FRETE' ;
		,'Z49_NUMVOL','Z49_CC','Z49_NOMECC','Z49_DESCGE','Z49_VALDEC','Z49_OBS','Z49_DATA','Z49_HORA','Z49_STATUS' ;
		,'Z49_CODCON','Z49_USUARI','Z49_NVOLTT','Z49_DOC', 'Z49_SERIE'}, "Declaração de Transporte")

	//Adiciona o campo de Ordem Produção Auxiliar
	oStrHead:AddField(;
		"Codigo",;                                                                                  // [01]  C   Titulo do campo
	"Codigo",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_CODIGO",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_CODIGO")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	NIL,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_CODIGO,GETSXENUM('Z49','Z49_CODIGO'))" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Cliente",;                                                                                  // [01]  C   Titulo do campo
	"Cliente",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_CLIENT",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_CLIENT")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	{||U_VLDZ491(1)},;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_CLIENT,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Loja",;                                                                                  // [01]  C   Titulo do campo
	"Loja",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_LOJA",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_LOJA")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	{||U_VLDZ491(2)},;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_LOJA,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Polo",;                                                                                  // [01]  C   Titulo do campo
	"Polo",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_CODPOL",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_CODPOL")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	{||U_VLDZ491(3)},;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_CODPOL,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Nome Cliente",;                                                                                  // [01]  C   Titulo do campo
	"Nome Cliente",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_NOMECL",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_NOMECL")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .f.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_NOMECL,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Nome Fantasia",;                                                                                  // [01]  C   Titulo do campo
	"Nome Fantasia",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_NREDUZ",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	60,;                                                                    					// [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .f.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_NREDUZ,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Codigo",;                                                                                  // [01]  C   Titulo do campo
	"Codigo",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_CONTAT",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_CONTAT")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_CONTAT,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Tipo End.",;                                                                                  // [01]  C   Titulo do campo
	"Tipo Endereço",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_TIPOEN",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_TIPOEN")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_TIPOEN,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"End Contato",;                                                                                  // [01]  C   Titulo do campo
	"Endereço Contato",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_ENDCON",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	120,;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .T.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_ENDCON,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Transportadora",;                                                                                  // [01]  C   Titulo do campo
	"Transportadora",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_TRANSP",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_TRANSP")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_TRANSP,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Nome Transportadora",;                                                                                  // [01]  C   Titulo do campo
	"Nome Transportadora",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_NOMETR",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_NOMETR")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_NOMETR,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Frete",;                                                                                  // [01]  C   Titulo do campo
	"Frete",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_FRETE",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_FRETE")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_FRETE,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Num Volumes",;                                                                                  // [01]  C   Titulo do campo
	"Numero Volumes",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_NUMVOL",;                                                                               // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_NUMVOL")[1],;                                                                    // [05]  N   Tamanho do campo
	TamSX3("Z49_NUMVOL")[2],;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_NUMVOL,0)" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Centro Custo",;                                                                                  // [01]  C   Titulo do campo
	"Centro Custo",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_CC",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_CC")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_CC,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Desc. CC",;                                                                                  // [01]  C   Titulo do campo
	"Descricao CC",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_NOMECC",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_NOMECC")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_NOMECC,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)

	oStrHead:AddField(;
		"Desc Generic",;                                                                                  // [01]  C   Titulo do campo
	"Descricao Generica",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_DESCGE",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_DESCGE")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_DESCGE,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Val Declarado",;                                                                                  // [01]  C   Titulo do campo
	"Valor Declarado",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_VALDEC",;                                                                               // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_CODIGO")[1],;                                                                    // [05]  N   Tamanho do campo
	TamSX3("Z49_CODIGO")[1],;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_VALDEC,0)" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Observacao",;                                                                                  // [01]  C   Titulo do campo
	"Observacao",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_OBS",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_OBS")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_OBS,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Data",;                                                                                  // [01]  C   Titulo do campo
	"Data",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_DATA",;                                                                               // [03]  C   Id do Field
	"D",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_DATA")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_DATA,date())" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Usuario",;                                                                                  // [01]  C   Titulo do campo
	"Usuario",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_USUARI",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_USUARI")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_USUARI,usrfullname(__cUserID))" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Hora",;                                                                                  // [01]  C   Titulo do campo
	"Hora",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_HORA",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_HORA")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_HORA,TIME())" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Status",;                                                                                  // [01]  C   Titulo do campo
	"Status",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_STATUS",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_STATUS")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_STATUS,'INCLUIDA')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"Cod. Contato",;                                                                                  // [01]  C   Titulo do campo
	"Codigo Contato",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_CODCON",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_CODCON")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_CODCON,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStrHead:AddField(;
		"NVolumeTotal",;                                                                                  // [01]  C   Titulo do campo
	"NVolumeTotal",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_NVOLTT",;                                                                               // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_NVOLTT")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .t.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z49->Z49_NVOLTT,'')" ),;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	oStrHead:AddField(;
		"Doc",;                                                                                  // [01]  C   Titulo do campo
	"Doc",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_DOC",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_DOC")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	Nil,;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	oStrHead:AddField(;
		"Serie",;                                                                                  // [01]  C   Titulo do campo
	"Serie",;                                                                                  // [02]  C   ToolTip do campo
	"Z49_SERIE",;                                                                               // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3("Z49_SERIE")[1],;                                                                    // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	{|| .F.},;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	Nil,;   // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Setando campos (default) na grid para não dar mensagem de coluna vazia nos campos não usados
	oStrZ49:SetProperty('Z49_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))

	//Criando o FormModel
//	oModel := MPFormModel():New('MainModel')
	oModel := MPFormModel():New('MainModel' ;
		, /*{|oModel| preValidDef(oModel)}*/ ;	//Pré-validação (Linha)
	, {|oModel| validDef(oModel)} ;			//Validação
	, ;			//Gravação
	, /*{|oModel| cancelDef(oModel)}*/)		//Cancelamento

	oModel:InstallEvent("Z49MVC",/*Owner*/ , oEvent)

	oStrHead:AddTrigger("Z49_TRANSP"    , "Z49_NOMETR"   , {|| .t.}, {|| gatTRANSP(oModel)})
	oStrHead:AddTrigger("Z49_CC"    , "Z49_NOMECC"   , {|| .t.}, {|| gatCC(oModel)})
	oStrHead:AddTrigger("Z49_CLIENT"    , "Z49_CONTAT"   , {|| .t.}, {|| gatCont(oModel)})
	oStrHead:AddTrigger("Z49_LOJA"    , "Z49_CONTAT"   , {|| .t.}, {|| gatCont(oModel)})

	//Adicionando cabeçalho e grid ao FormModel
	oModel:AddFields("mFormZ49",/*cOwner*/, oStrHead)

	oModel:AddGrid('mGridZ49','mFormZ49', oStrZ49,,, {|oModel, nLine, cEvent, cField|})//| Z49PreLine(oModel, nLine, cEvent, cField)})

	oStrHead:SetProperty("Z49_CLIENT",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_LOJA"  ,MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_CODPOL",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_NOMECL",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_NREDUZ",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_CONTAT",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_TIPOEN",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_ENDCON",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})
	oStrHead:SetProperty("Z49_CODCON",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I', .T.,.F.)})

	oStrHead:SetProperty("Z49_TRANSP",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I' .OR. CBUTOP='A', .T.,.F.)})
	oStrHead:SetProperty("Z49_CC",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I' .OR. CBUTOP='A', .T.,.F.)})
	oStrHead:SetProperty("Z49_FRETE",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I' .OR. CBUTOP='A', .T.,.F.)})
	oStrHead:SetProperty("Z49_OBS",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I' .OR. CBUTOP='A', .T.,.F.)})
	oStrHead:SetProperty("Z49_DESCGE",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I' .OR. CBUTOP='A', .T.,.F.)})
	oStrHead:SetProperty("Z49_NVOLTT",MODEL_FIELD_WHEN, {||IIF(CBUTOP=='I' .OR. CBUTOP='A', .T.,.F.)})

	//Criando o relacionamento.
	aAdd(aZ49Rel, {'Z49_FILIAL', 'Z49_FILIAL'})
	aAdd(aZ49Rel, {'Z49_CODIGO', 'Z49_CODIGO'})

	oModel:SetRelation('mGridZ49',{{"Z49_FILIAL", "FwXFilial('Z49')"}, {"Z49_CODIGO", "Z49_CODIGO"}}, Z49->(indexKey(1)))

	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('mGridZ49'):SetUniqueLine({"Z49_CODIGO", "Z49_PRODUT"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitle)
	oModel:SetPrimaryKey({})
	oModel:GetModel("mFormZ49"):SetDescription(cTitle)

//D	oModel:addFields('MFormZ49',, oStrHead)
	oModel:AddCalc('mFormTOT', 'mFormZ49', 'mGridZ49', 'Z49_QUANT', 'Z49_NUMVOL', 'SUM',,, "Total Quant:")
	oModel:AddCalc('mFormTOT', 'mFormZ49', 'mGridZ49', 'Z49_TOTAL', 'Z49_VALDEC', 'SUM',,, "Valor Total:")

return(oModel)

static function gatTRANSP(oModel)
	local areaDEF    := getArea()
	local oModelHead := oModel:GetModel('mFormZ49')
	local cReturn    := ""

	dbSelectArea("SA4")
	dbSetOrder(1)
	if dbseek(xFilial()+oModelHead:GetValue("Z49_TRANSP"))
		cReturn := SA4->A4_NOME
	endIf

	restArea(areaDEF)
return(cReturn)

static function gatCC(oModel)
	local areaDEF    := getArea()
	local oModelHead := oModel:GetModel('mFormZ49')
	local cReturn    := ""

	dbSelectArea("CTT")
	dbSetOrder(1)
	if dbseek(xFilial()+oModelHead:GetValue("Z49_CC"))
		cReturn := CTT->CTT_DESC01
	endIf

	restArea(areaDEF)
return(cReturn)

static function gatCONT(oModel)
	local areaDEF    := getArea()
	local oModelHead := oModel:GetModel('mFormZ49')
	local cReturn    := ""

	dbSelectArea("SA1")
	dbSetOrder(1)
	if dbseek(xFilial()+oModelHead:GetValue("Z49_CLIENT")+oModelHead:GetValue("Z49_LOJA"))
		cReturn := SA1->A1_CONTATO
	endIf

	restArea(areaDEF)
return(cReturn)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface
@type function
@author Daniel Gouveia - Unidade TOTVS Londrina
@since 10/06/2018
@version 1.0
@return oView, objeto, view da interface
/*/
//-------------------------------------------------------------------
static function ViewDef()
	local oView    := nil
	local oModel   := ModelDef()
	local oStrHead := fwFormViewStruct():New()
	local oStrZ49  := fwFormStruct(2, 'Z49')
	local oStrTOT  := fwCalcStruct(oModel:GetModel('mFormTOT'))

	//Adicionando o campo Ordem Produção Auxiliar para ser exibido
	oStrHead:AddField(;
		"Z49_CODIGO",;          // [01]  C   Nome do Campo
	"01",;                      // [02]  C   Ordem
	"Codigo",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_CODIGO'),;   // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_CODIGO"),;   // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_CLIENT",;                // [01]  C   Nome do Campo
	"02",;                      // [02]  C   Ordem
	"Cliente",;                 // [03]  C   Titulo do campo
	X3Descric('Z49_CLIENT'),;   // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_CLIENT"),;   // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	"SA1",;                     // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_LOJA",;                // [01]  C   Nome do Campo
	"03",;                      // [02]  C   Ordem
	"Loja",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_LOJA'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_LOJA"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_CODPOL",;              // [01]  C   Nome do Campo
	"04",;                      // [02]  C   Ordem
	"Polo",;                    // [03]  C   Titulo do campo
	X3Descric('Z49_CODPOL'),;   // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_CODPOL"),;   // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	"SA1PO2",;                  // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_NOMECL",;                // [01]  C   Nome do Campo
	"05",;                      // [02]  C   Ordem
	"Nome Cliente",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_NOMECL'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_NOMECL"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_NREDUZ",;                // [01]  C   Nome do Campo
	"06",;                      // [02]  C   Ordem
	"Nome Fantasia",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_NREDUZ'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_NREDUZ"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_CONTAT",;                // [01]  C   Nome do Campo
	"07",;                      // [02]  C   Ordem
	"Nome Contato",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_CONTAT'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_CONTAT"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_TIPOEN",;                // [01]  C   Nome do Campo
	"08",;                      // [02]  C   Ordem
	"Tipo Endereço",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_TIPOEN'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_TIPOEN"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	{"1=Cliente","2=Contato"} ,;// [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_ENDCON",;                // [01]  C   Nome do Campo
	"09",;                      // [02]  C   Ordem
	"End. Contato",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_ENDCON'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_ENDCON"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_TRANSP",;                // [01]  C   Nome do Campo
	"10",;                      // [02]  C   Ordem
	"Transp.",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_TRANSP'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_TRANSP"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	"SA4",;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_NOMETR",;                // [01]  C   Nome do Campo
	"11",;                      // [02]  C   Ordem
	"Nome Transp.",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_NOMETR'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_NOMETR"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_FRETE",;                // [01]  C   Nome do Campo
	"12",;                      // [02]  C   Ordem
	"Frete",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_FRETE'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_FRETE"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	{"1=CIF","2=FOB"},;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
	/*
    oStrHead:AddField(;
		"Z49_NUMVOL",;                // [01]  C   Nome do Campo
		"13",;                      // [02]  C   Ordem
		"Num. Vol.",;                  // [03]  C   Titulo do campo
		X3Descric('Z49_NUMVOL'),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"N",;                       // [06]  C   Tipo do campo
		X3Picture("Z49_NUMVOL"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo   
    */
	oStrHead:AddField(;
		"Z49_CC",;                // [01]  C   Nome do Campo
	"14",;                      // [02]  C   Ordem
	"Centro Custo",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_CC'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_CC"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	"CTT",;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_NOMECC",;                // [01]  C   Nome do Campo
	"15",;                      // [02]  C   Ordem
	"Nome Centro Custo",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_NOMECC'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_NOMECC"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_DESCGE",;                // [01]  C   Nome do Campo
	"17",;                      // [02]  C   Ordem
	"Desc Generic",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_DESCGE'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_DESCGE"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_OBS",;                // [01]  C   Nome do Campo
	"17",;                      // [02]  C   Ordem
	"Obs",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_OBS'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"N",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_OBS"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_DATA",;                // [01]  C   Nome do Campo
	"18",;                      // [02]  C   Ordem
	"Data",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_DATA'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"D",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_DATA"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo


	oStrHead:AddField(;
		"Z49_HORA",;                // [01]  C   Nome do Campo
	"19",;                      // [02]  C   Ordem
	"Hora",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_HORA'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_HORA"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     					// [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo


	oStrHead:AddField(;
		"Z49_CODCON",;                // [01]  C   Nome do Campo
	"20",;                      // [02]  C   Ordem
	"Cod. Contato",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_CODCON'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"D",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_CODCON"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	"SU5",;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_USUARI",;                // [01]  C   Nome do Campo
	"21",;                      // [02]  C   Ordem
	"Usuario",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_USUARI'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_USUARI"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_STATUS",;                // [01]  C   Nome do Campo
	"22",;                      // [02]  C   Ordem
	"Status",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_STATUS'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_STATUS"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     					// [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_NVOLTT",;                // [01]  C   Nome do Campo
	"32",;                      // [02]  C   Ordem
	"NVolumeTotal",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_NVOLTT'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"N",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_NVOLTT"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_DOC",;                // [01]  C   Nome do Campo
	"34",;                      // [02]  C   Ordem
	"NDocumento",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_DOC'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_DOC"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrHead:AddField(;
		"Z49_SERIE",;                // [01]  C   Nome do Campo
	"35",;                      // [02]  C   Ordem
	"Serie",;                  // [03]  C   Titulo do campo
	X3Descric('Z49_SERIE'),;    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	X3Picture("Z49_SERIE"),;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;     // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := fwFormView():New()
	oView:SetModel(oModel)
	oView:AddField("fZ49Head", oStrHead, "mFormZ49")
	oView:AddGrid('fZ49Grid', oStrZ49, 'mGridZ49')
	oView:AddField('formTOT', oStrTOT,'mFormTOT')

	oView:CreateHorizontalBox('boxCab', 50)
	oView:CreateHorizontalBox('boxIte', 35)
	oView:CreateHorizontalBox('boxTOT', 15)

	oView:SetOwnerView('fZ49Head', 'boxCab')
	oView:SetOwnerView('fZ49Grid', 'boxIte')
	oView:SetOwnerView('formTOT', 'boxTOT')

	//Habilitando título
	oView:EnableTitleView('fZ49Head', 'Cabeçalho')
	oView:EnableTitleView('fZ49Grid', 'Itens')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({|| .t.})

	//Remover campos desnecessários da estrutura do grid
	oStrZ49:RemoveField('Z49_CODIGO')
	oStrZ49:RemoveField('Z49_CLIENT')
	oStrZ49:RemoveField('Z49_LOJA')
	oStrZ49:RemoveField('Z49_CODPOL')
	oStrZ49:RemoveField('Z49_NOMECL')
	oStrZ49:RemoveField('Z49_NREDUZ')
	oStrZ49:RemoveField('Z49_CONTAT')
	oStrZ49:RemoveField('Z49_TIPOEN')
	oStrZ49:RemoveField('Z49_ENDCON')
	oStrZ49:RemoveField('Z49_TRANSP')
	oStrZ49:RemoveField('Z49_NOMETR')
	oStrZ49:RemoveField('Z49_FRETE')
	oStrZ49:RemoveField('Z49_NUMVOL')
	oStrZ49:RemoveField('Z49_CC')
	oStrZ49:RemoveField('Z49_NOMECC')
	oStrZ49:RemoveField('Z49_VALDEC')
	oStrZ49:RemoveField('Z49_OBS')
	oStrZ49:RemoveField('Z49_DESCGE')
	oStrZ49:RemoveField('Z49_DATA')
	oStrZ49:RemoveField('Z49_HORA')
	oStrZ49:RemoveField('Z49_CODCON')
	oStrZ49:RemoveField('Z49_ANO')
	oStrZ49:RemoveField('Z49_STATUS')
	oStrZ49:RemoveField('Z49_USUARI')
	oStrZ49:RemoveField('Z49_NVOLTT')
	oStrZ49:RemoveField('Z49_DOC')
	oStrZ49:RemoveField('Z49_SERIE')
return(oView)


//-------------------------------------------------------------------
/*/{Protheus.doc} Z49PreLine
Procedimentos executados antes da validação da linha 
@author Daniel Gouveia - Unidade TOTVS Londrina
@since 10/06/2020
@version 1.0
@type function
/*/
//-------------------------------------------------------------------

static function Z49PreLine(oModel, nLine, cEvent, cField)

	local oModelHead := oModel:GetModel('mFormZ49')
	local oModelZ49  := oModel:GetModel('mGridZ49')
	

	if cEvent == 'SETVALUE' ;
			.and. cField == 'Z49_PRODUT' ;
			.and. valType(oModelHead) == 'O' ;
			.and. valType(oModelZ49)  == 'O'
		
		oModelZ49:SetValue('Z49_FILIAL'		, FWxFilial('Z49'))
		oModelZ49:SetValue('Z49_ANO'   		, cValToChar(year(date())))
		oModelZ49:SetValue('Z49_CODIGO'		, oModelHead:GetValue('Z49_CODIGO'))
		oModelZ49:SetValue('Z49_CLIENT'		, oModelHead:GetValue('Z49_CLIENT'))
		oModelZ49:SetValue('Z49_LOJA'  		, oModelHead:GetValue('Z49_LOJA'))
		oModelZ49:SetValue('Z49_CODPOL'		, oModelHead:GetValue('Z49_CODPOL'))
		oModelZ49:SetValue('Z49_NOMECL'		, oModelHead:GetValue('Z49_NOMECL'))
		oModelZ49:SetValue('Z49_NREDUZ'		, oModelHead:GetValue('Z49_NREDUZ'))
		oModelZ49:SetValue('Z49_CONTAT'		, oModelHead:GetValue('Z49_CONTAT'))
		oModelZ49:SetValue('Z49_TIPOEN'		, oModelHead:GetValue('Z49_TIPOEN'))
		oModelZ49:SetValue('Z49_ENDCON'		, oModelHead:GetValue('Z49_ENDCON'))
		oModelZ49:SetValue('Z49_TRANSP'		, oModelHead:GetValue('Z49_TRANSP'))
		oModelZ49:SetValue('Z49_NOMETR'		, oModelHead:GetValue('Z49_NOMETR'))
		oModelZ49:SetValue('Z49_FRETE' 		, oModelHead:GetValue('Z49_FRETE'))
		oModelZ49:SetValue('Z49_DATA' 		, oModelHead:GetValue('Z49_DATA'))
		oModelZ49:SetValue('Z49_HORA' 		, oModelHead:GetValue('Z49_HORA'))
		oModelZ49:SetValue('Z49_USUARI' 	, oModelHead:GetValue('Z49_USUARI'))
		oModelZ49:SetValue('Z49_OBS' 		, oModelHead:GetValue('Z49_OBS'))
		oModelZ49:SetValue('Z49_DESCGE' 	, oModelHead:GetValue('Z49_DESCGE'))
		oModelZ49:SetValue('Z49_VALDEC'		, oModelHead:GetValue('Z49_VALDEC'))
		oModelZ49:SetValue('Z49_CC'			, oModelHead:GetValue('Z49_CC'))
		oModelZ49:SetValue('Z49_NOMECC' 	, oModelHead:GetValue('Z49_NOMECC'))
		oModelZ49:SetValue('Z49_STATUS' 	, oModelHead:GetValue('Z49_STATUS'))
		oModelZ49:SetValue('Z49_NVOLTT' 	, oModelHead:GetValue('Z49_NVOLTT'))
		//oModelZ49:SetValue('Z49_DOC' 		, oModelHead:GetValue('Z49_DOC'))
		//oModelZ49:SetValue('Z49_SERIE'		, oModelHead:GetValue('Z49_SERIE'))

	endIf

return(.t.)

User Function Gatpb7()

	Local oModel   	 := FWModelActive()
	local oModelHead := oModel:GetModel('mFormZ49')
	local oModelZ49  := oModel:GetModel('mGridZ49')

		oModelZ49:SetValue('Z49_FILIAL'		, FWxFilial('Z49'))
		oModelZ49:SetValue('Z49_ANO'   		, cValToChar(year(date())))
		oModelZ49:SetValue('Z49_CODIGO'		, oModelHead:GetValue('Z49_CODIGO'))
		oModelZ49:SetValue('Z49_CLIENT'		, oModelHead:GetValue('Z49_CLIENT'))
		oModelZ49:SetValue('Z49_LOJA'  		, oModelHead:GetValue('Z49_LOJA'))
		oModelZ49:SetValue('Z49_CODPOL'		, oModelHead:GetValue('Z49_CODPOL'))
		oModelZ49:SetValue('Z49_NOMECL'		, oModelHead:GetValue('Z49_NOMECL'))
		oModelZ49:SetValue('Z49_NREDUZ'		, oModelHead:GetValue('Z49_NREDUZ'))
		oModelZ49:SetValue('Z49_CONTAT'		, oModelHead:GetValue('Z49_CONTAT'))
		oModelZ49:SetValue('Z49_TIPOEN'		, oModelHead:GetValue('Z49_TIPOEN'))
		oModelZ49:SetValue('Z49_ENDCON'		, oModelHead:GetValue('Z49_ENDCON'))
		oModelZ49:SetValue('Z49_TRANSP'		, oModelHead:GetValue('Z49_TRANSP'))
		oModelZ49:SetValue('Z49_NOMETR'		, oModelHead:GetValue('Z49_NOMETR'))
		oModelZ49:SetValue('Z49_FRETE' 		, oModelHead:GetValue('Z49_FRETE'))
		oModelZ49:SetValue('Z49_DATA' 		, oModelHead:GetValue('Z49_DATA'))
		oModelZ49:SetValue('Z49_HORA' 		, oModelHead:GetValue('Z49_HORA'))
		oModelZ49:SetValue('Z49_USUARI' 	, oModelHead:GetValue('Z49_USUARI'))
		oModelZ49:SetValue('Z49_OBS' 		, oModelHead:GetValue('Z49_OBS'))
		oModelZ49:SetValue('Z49_DESCGE' 	, oModelHead:GetValue('Z49_DESCGE'))
		oModelZ49:SetValue('Z49_VALDEC'		, oModelHead:GetValue('Z49_VALDEC'))
		oModelZ49:SetValue('Z49_CC'			, oModelHead:GetValue('Z49_CC'))
		oModelZ49:SetValue('Z49_NOMECC' 	, oModelHead:GetValue('Z49_NOMECC'))
		oModelZ49:SetValue('Z49_STATUS' 	, oModelHead:GetValue('Z49_STATUS'))
		oModelZ49:SetValue('Z49_NVOLTT' 	, oModelHead:GetValue('Z49_NVOLTT'))
		//oModelZ49:SetValue('Z49_DOC' 		, oModelHead:GetValue('Z49_DOC'))
		//oModelZ49:SetValue('Z49_SERIE'		, oModelHead:GetValue('Z49_SERIE'))

Return()

Static Function Z49LIOK(oModel, nLine, cEvent, cField)
	Local lRet := .T.
	//local oModel     := oModel:GetModel()
	//local oModelHead := oModel:GetModel('mFormZ49')
	//local oModelZ49  := oModel:GetModel('mGridZ49')

	_a := 1

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} validDef
Função chamada na validação do botão Confirmar, para verificar se já existe a tabela digitada
@type function
@author Daniel Gouveia - Unidade TOTVS Londrina
@since 10/06/2018
@version 1.0
@param  oModel, objeto, Obejeto do modelo de dados
@return lRet  , lógico, .T. se pode prosseguir e .F. se deve barrar
/*/
//-------------------------------------------------------------------
static function validDef(oModel)
	local aArea      := getArea()
	local oModelHead := oModel:GetModel('mFormZ49')
	local oModelZ49  := oModel:GetModel('mGridZ49')
	local nOpc       := oModel:GetOperation()
	local nRow       := 0
	local hasError   := .f.
	Local nValDec := 0
	Local nQuant := 0

	//Se for Inclusão
	if nOpc == 3 .or. nOpc == 4		//Upsert
		//Inserir aqui as valiações do cabeçalho

		for nRow := 1 to oModelZ49:Length()
			oModelZ49:GoLine(nRow)

			if !oModelZ49:IsDeleted()

				nValDec += oModelZ49:getValue('Z49_TOTAL')
				nQuant += oModelZ49:getValue('Z49_QUANT')

			endif
		next

		for nRow := 1 to oModelZ49:Length()
			oModelZ49:GoLine(nRow)

			if !oModelZ49:IsDeleted()
				//Inserir aqui as validações do grid
				oModelZ49:SetValue('Z49_FILIAL', xFilial('Z49'))
				oModelZ49:SetValue('Z49_ANO'   , cValToChar(year(date())))
				oModelZ49:SetValue('Z49_CODIGO', oModelHead:GetValue('Z49_CODIGO'))
				oModelZ49:SetValue('Z49_CLIENT', oModelHead:GetValue('Z49_CLIENT'))
				oModelZ49:SetValue('Z49_LOJA'  , oModelHead:GetValue('Z49_LOJA'))
				oModelZ49:SetValue('Z49_CODPOL', oModelHead:GetValue('Z49_CODPOL'))
				oModelZ49:SetValue('Z49_NOMECL', oModelHead:GetValue('Z49_NOMECL'))
				oModelZ49:SetValue('Z49_NREDUZ', oModelHead:GetValue('Z49_NREDUZ'))
				oModelZ49:SetValue('Z49_CONTAT', oModelHead:GetValue('Z49_CONTAT'))
				oModelZ49:SetValue('Z49_TIPOEN', oModelHead:GetValue('Z49_TIPOEN'))
				oModelZ49:SetValue('Z49_ENDCON', oModelHead:GetValue('Z49_ENDCON'))
				oModelZ49:SetValue('Z49_TRANSP', oModelHead:GetValue('Z49_TRANSP'))
				oModelZ49:SetValue('Z49_NOMETR', oModelHead:GetValue('Z49_NOMETR'))
				oModelZ49:SetValue('Z49_FRETE' , oModelHead:GetValue('Z49_FRETE'))
				oModelZ49:SetValue('Z49_DATA' , oModelHead:GetValue('Z49_DATA'))
				oModelZ49:SetValue('Z49_HORA' , oModelHead:GetValue('Z49_HORA'))
				oModelZ49:SetValue('Z49_USUARI' , oModelHead:GetValue('Z49_USUARI'))
				oModelZ49:SetValue('Z49_OBS' , oModelHead:GetValue('Z49_OBS'))
				oModelZ49:SetValue('Z49_DESCGE' , oModelHead:GetValue('Z49_DESCGE'))
				oModelZ49:SetValue('Z49_VALDEC' , nValDec)
				oModelZ49:SetValue('Z49_NUMVOL' , nQuant)
				oModelZ49:SetValue('Z49_CC' , oModelHead:GetValue('Z49_CC'))
				oModelZ49:SetValue('Z49_NOMECC' , oModelHead:GetValue('Z49_NOMECC'))
				oModelZ49:SetValue('Z49_STATUS' , oModelHead:GetValue('Z49_STATUS'))
				oModelZ49:SetValue('Z49_NVOLTT' , oModelHead:GetValue('Z49_NVOLTT'))
				oModelZ49:SetValue('Z49_DOC' , oModelHead:GetValue('Z49_DOC'))
				oModelZ49:SetValue('Z49_SERIE' , oModelHead:GetValue('Z49_SERIE'))
			endIf
		next nRow
	endIf

	restArea(aArea)

	if hasError
		help("", 1, "Erro ao validar dados",, "Existem campos com dados inconsistentes", 4, 8, .f.)
	endIf
return(!hasError)

User Function VLDZ491(nTipo)

	Local _area := getarea()
	Local lRet := .T.
	local oModel   := FwModelActive()
	Local oModelHead := oModel:GetModel('mFormZ49')
	Local cCliente :=  oModelHead:GetValue('Z49_CLIENT')
	Local cLoja   :=  oModelHead:GetValue('Z49_LOJA')
	Local cPolo   := oModelHead:GetValue('Z49_CODPOL')
	if nTipo==1 //cliente
		dbselectarea("SA1")
		dbsetorder(1)
		if dbseek(xFilial()+cCLiente)
			if empty(SA1->A1_UCODPOL)
				alert("Cliente não é polo")
			elseif (SA1->A1_MSBLQL = '1')
				alert("Cliente Bloqueado")
			endif
			oModelHead:SetValue('Z49_LOJA', SA1->A1_LOJA)
			oModelHead:SetValue('Z49_CODPOL', SA1->A1_UCODPOL)
			oModelHead:SetValue('Z49_NOMECL', SA1->A1_NOME)
			oModelHead:SetValue('Z49_NREDUZ', SA1->A1_NREDUZ)
			oModelHead:SetValue('Z49_ENDCON', SA1->A1_END)
			oModelHead:SetValue('Z49_FRETE', "1")
			oModelHead:SetValue('Z49_TIPOEN', "1")

		else
			alert("Cliente não existe")
			lRet := .F.
		endif
	elseif nTipo==2 //loja
		dbselectarea("SA1")
		dbsetorder(1)
		if dbseek(xFilial()+cCliente+cLoja)
			if empty(SA1->A1_UCODPOL)
				alert("Cliente não é polo")
			endif
			oModelHead:SetValue('Z49_CODPOL', SA1->A1_UCODPOL)
			oModelHead:SetValue('Z49_NOMECL', Alltrim(SA1->A1_NOME))
			oModelHead:SetValue('Z49_NREDUZ', Alltrim(SA1->A1_NREDUZ))
			oModelHead:SetValue('Z49_ENDCON',Alltrim(SA1->A1_END))
			oModelHead:SetValue('Z49_FRETE', "1")
			oModelHead:SetValue('Z49_TIPOEN', "1")

		else
			alert("Cliente não existe")
			lRet := .F.
		endif
	elseif nTipo==3 //polo
		dbselectarea("SA1")
		dbordernickname("CODPOL")
		if dbseek(xFilial()+cPolo)
			oModelHead:SetValue('Z49_CLIENT', SA1->A1_COD)
			oModelHead:SetValue('Z49_LOJA', SA1->A1_LOJA)
			oModelHead:SetValue('Z49_NOMECL', SA1->A1_NOME)
			oModelHead:SetValue('Z49_NREDUZ', SA1->A1_NREDUZ)
			oModelHead:SetValue('Z49_ENDCON', SA1->A1_END)
			oModelHead:SetValue('Z49_FRETE', "1")
			oModelHead:SetValue('Z49_TIPOEN', "1")
		else
			alert("Cliente não existe")
			lRet := .F.
		endif
	endif

	restarea(_area)
return lRet

USER FUNCTION Z49MANUT(cButOper)

	Local oExecView  := nil
	Local oModel     := FwLoadModel("Z49MVC")
	Local cTitulo     := ""
	Local nOpera := 2
	Local _area := getarea()

	if cButOPer == "C"
		cTitulo := "Cancelamento de Declaração"
		nOpera := 5
		cButOp := cButOper
		if Z49->Z49_STATUS=="CANCELADA"
			alert("Não pode excluir. Status "+Z49->Z49_STATUS)
			return .f.
		else
			if msgyesno("Tem certeza de que deseja cancelar a Declaração?","")
				cQuery := " UPDATE "+RetSqlName("Z49")+" SET Z49_STATUS='CANCELADA' "
				cQuery += " WHERE D_E_L_E_T_=' ' AND Z49_FILIAL='"+xFilial("Z49")+"' "
				cQuery += " AND Z49_CODIGO='"+Z49->Z49_CODIGO+"' "
				TCSQLEXEC(cQuery)
				return
			ELSE
				return
			endif
		endif
	Elseif cButOper == "A"
		cTitulo := "Alteração de Declaração"
		nOpera := 4
		cButOp := cButOper
	Elseif cButOper == "I"
		cTitulo := "Inclusão de Declaração"
		nOpera := 3
		cButOp := cButOper
	Elseif cButOper == "V"
		cTitulo := "Visualização de Declaração"
		nOpera := 2
		cButOp := cButOper
	Endif

	oExecView := FWViewExec():New()
	oExecView:SetTitle(cTitulo)
	oExecView:SetSource("Z49MVC")
	oExecView:SetOK({||.T.})//{|oModel| ACTB005C(oModel)})
	oExecView:setModel(oModel)
	oExecView:SetModal(.F.)
	oExecView:SetOperation(nOpera) //<—— aqui tem que passar a operação
	oExecView:OpenView(.F.)

	RESTAREA(_area)
RETURN
