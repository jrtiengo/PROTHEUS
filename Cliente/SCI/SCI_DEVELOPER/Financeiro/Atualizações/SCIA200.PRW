#Include "Totvs.ch"
#Include "FWMVCDef.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณSCIA200   บAutor  ณMicrosiga           บ Data ณ  22/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SCIA200()

Local oBrowse

Private aRotina := MenuDef()

//Instaciamento da Classe de Browse
oBrowse := FWMBrowse():New()

//Definicao da tabela do Browse
oBrowse:SetAlias("Z04")

//Definicao da legenda
//oBrowse:AddLegend("Z04_COD<>''","YELLOW","OK")

//Definicao de filtro
//oBrowse:SetFilterDefault("ZA0_TIPO='1'")

//Titulo da Browse
oBrowse:SetDescription("Cadastro de Categorias")

//Opcionalmente pode ser desligado a exibi็ใo dos detalhes
oBrowse:DisableDetails()

//Ativacao da Classe
oBrowse:Activate()

Return



/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | MenuDef | Autor | Denis Rodrigues        | Data |18/08/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Funcao para gerar o Menu                                   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function MenuDef()

Return FWMVCMenu("SCIA200")


/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | ModelDef| Autor | Denis Rodrigues        | Data |18/08/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Funcao ModelDef                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ModelDef()

//Cria a estrutura a ser uada no Modelo de dados
Local oStruZ04 := FWFormStruct( 1,"Z04" )
Local oModel //Modelo de dados que sera contruido
//Local aRelZ04   := { "Z04_FILIAL", "Z04_CAT", "Z04_NAT", "Z04_CC" } 

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("SCIA200M" , /*{|oModel| MA200PreVl(oModel)}*/ , {|oModel| MA200PosVl(oModel)} , /*{|oModel| MA200Commi(oModel)}*/)

//Adiciona ao modelo um componente de formulario
oModel:AddFields( "Z04MASTER", /*cOwner*/, oStruZ04)

//oModel:SetPrimaryKey( aRelZ04 )

//AADD( aRelZ04, { 'Z04_FILIAL'	, 'xFilial( "Z04" )'	})
//AADD( aRelZ04, { 'Z04_CHAVE'	, 'Z04_NAT'		     	})
//AADD( aRelZ04, { 'Z04_NUMRES'	, 'Z04_CC'		    	})
//AADD( aRelZ04, { 'Z04_CAT'      , 'Z04_CAT'		    	})

//oModel:SetRelation('Z04MASTER', aRelZ04, Z04->(IndexKey(1) ) )
 
//oModel:SetPrimaryKey({"ZTM_CODCLI","ZTM_LOJCLI","ZTM_PRODUT"})
//oModel:GetModel('MdGridZTM'):SetUniqueLine({'ZTM_FILIAL','ZTM_CODCLI','ZTM_LOJCLI','ZTM_PRODUT'})
//oModel:GetModel('SCIA200M'):SetUniqueLine( { "Z04_FILIAL", "Z04_CAT", "Z04_NAT", "Z04_CC" })
//oModel:GetModel('Z04MASTER'):SetUniqueLine( { "Z04_FILIAL", "Z04_CAT", "Z04_NAT", "Z04_CC" })

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'Z04MASTER' ):SetUniqueLine( { "Z04_FILIAL", "Z04_CAT", "Z04_NAT", "Z04_CC" }  )


//Adiciona a descri็ใo do Modelo de dados
oModel:SetDescription("Cadastro de Categorias")

//Adiciona a descri็ใo do Componente do Modelo de Dados
oModel:GetModel("Z04MASTER"):SetDescription("Formulแrio - Cadastro de Categorias")

Return( oModel )

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | ViewDef | Autor | Denis Rodrigues        | Data |18/08/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Funcao ViewDef                                             |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ViewDef()

//Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel("SCIA200")

//Cria a estrutura a ser usada na View
Local oStruZ04 := FWFormStruct( 2,"Z04")

//Interface de visualiza็ใo construํda
Local oView

//Cria o objeto de View
oView := FWFormView():New()

//Define qual o Modelo de dados serแ utilizado na View
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
oView:Addfield( "VIEW_Z04", oStruZ04, "Z04MASTER" )

//Criar um 'box' horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "TELA",100 )

//Relaciona o identificador (ID) da View com o 'box' para exibicao
oView:SetOwnerView( "VIEW_Z04", "TELA" )

Return( oView )


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA200PreVl( oModel )

Local lRet := .T.

Return lRet


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA200PosVl( oModel )

Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaZ04 := Z04->(GetArea())

If oModel:GetOperation() <> MODEL_OPERATION_DELETE

	dbSelectArea("Z04")
	dbSetORder(1) //Cat+ Nat + Cc
	If dbSeek(xFilial("Z04")+M->Z04_CAT+M->Z04_NAT+M->Z04_CC ,.f.)
	
		Help( ,, "HELP","", "Jแ existe este registro", 1, 0)
		lRet := .F.
	EndIf
	
EndIf

Return lRet

*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA200Commi( oModel )

Local lRet       := .T.

Return lRet