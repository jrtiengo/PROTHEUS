#Include 'Protheus.ch'

/*/{Protheus.doc} SX5ZP
//Cadastro de unidade
@author Celso Rene
@since 22/03/2019
@version 1.0
@type function
/*/
User Function XCadUnidad()

	Local bPre := {||VALUNID()}
	Local bOK  := {||ValidUNID()}
	//Local bTTS  := {||}
	//Local bNoTTS  := {||Msgalert("bNoTTS")}    
	Local aButtons := {}//adiciona botões na tela de inclusão, alteração, visualização e exclusao

	dbSelectArea("SX5")
	dbSetOrder(1)

	cString:= "SX5"

	SET FILTER TO X5_TABELA == 'ZD'
	DBFILTER() 
	
	AxCadastro(cString, "Cadastro de Unidades", , , , bPre, bOK, ,          , , , aButtons, , )

Return()                        

/*/{Protheus.doc} VALUNID
//Valida Inicializacao
@author Celso Rene
@since 22/03/2019
@version 1.0
@return Logico
@type function
/*/
Static Function VALUNID()

	M->X5_TABELA:=  "ZD"

Return( .T. )


/*/{Protheus.doc} ValidUNID
//Valida OK - ZD - SX% - modalidade
@author Celso Rene
@since 19/03/2018
@version 1.0
@return Logico
@type function
/*/
Static Function ValidUNID()

	Local _lRet	:= .T.

	If M->X5_TABELA <> "ZD"
		MsgAlert("Tabela informada diferente de 'ZD' - Unidades","# Unidades")
		_lRet:= .F.
	EndIf

Return(_lRet)

