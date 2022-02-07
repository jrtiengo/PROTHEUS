#Include "TOTVS.CH"
#Include "RESTFUL.CH"   

//Opcoes ExecAuto 
#Define PD_INCLUIR 3 
#Define PD_ALTERAR 4 
#Define PD_EXCLUIR 5   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TEDA120     ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para manutenção do                     ³±±
±±³          ³ ANALISE DE LAUDOS - TEDA120 - SZ9 -                        ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL TEDA120 DESCRIPTION "Análises de Laudos"

WSDATA Z9_DOC AS STRING
WSDATA Z9_SERIE AS STRING		
WSDATA Z9_DATA AS STRING 
WSDATA Z9_RESUL AS STRING 
WSDATA Z9_OBS AS STRING

//WSMETHOD GET DESCRIPTION "Listar Análise de Laudos." WSSYNTAX "/"
WSMETHOD POST DESCRIPTION "Incluir Análise de Laudos." WSSYNTAX "/" 
//WSMETHOD PUT DESCRIPTION "Alterar Análise de Laudos." WSSYNTAX "/"
WSMETHOD DELETE DESCRIPTION "Excluir Análise de Laudos." WSSYNTAX "/"

END WSRESTFUL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ POST     ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para incluir                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDA120

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()

	Private oJson 	

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a Análise de LaudosJson em Objeto

		lOk := .F.						
		SetRestFault( 101, "Nao foi possivel processar a Análise de LaudosJson." )	

	Else
		//-------------------------------
		//valida os dados do JSON 
		//-----------------------------
		lOk:=VLD_JSON(PD_INCLUIR) 

	EndIf

	If lOk   

		aRet:=PROC_MOV(PD_INCLUIR)
		
		If aRet[1]
		
			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"INCLUIDO"')
			::SetResponse('}')
		
		ELSE
			SetRestFault(115, "Erro ao incluir o Laudo"+aRet[2]  )
		End
		

	EndIf

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ DELETE   ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para deletar lancamento                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD DELETE WSRECEIVE Z9_DOC,Z9_SERIE WSSERVICE TEDA120

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local oJson 

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile := .T.

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	/*If !FWJsonDeserialize(cBody,@oJson)//Converte a Análise de LaudosJson em Objeto

		lOk := .F.						
		SetRestFault( 101, "Nao foi possivel processar a Análise de LaudosJson." )	
*/

	IF VALTYPE(::Z9_DOC)=="U".or.VALTYPE(::Z9_SERIE)=="U".or.EMPTY(::Z9_DOC).OR.EMPTY(::Z9_SERIE)
		lOk := .F.						
		SetRestFault( 100, "Documento ou Série não foi enviado." )	
	Else
		Private cPesqDoc		:= ::Z9_DOC
		Private cPesqSerie		:= ::Z9_SERIE
		//-------------------------------
		//valida os dados do JSON 
		//-----------------------------
		lOk:=VLD_JSON(PD_EXCLUIR) 

	EndIf

	If lOk   
		//-------------------------------
		//faz a EXCLUSAO do movimento 
		//-----------------------------

		aRet:=PROC_MOV(PD_EXCLUIR)
		If aRet[1]
		
			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"EXCLUIDO"')
			::SetResponse('}')
		
		ELSE
			SetRestFault(115, "Erro ao excluir o Laudo"+aRet[2]  )
		End

	EndIf
Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VLD_JSON    ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que valida os dados do JSON enviados para           ³±±
±±³          ³ manutencao da informacao                                   ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VLD_JSON(nOper)
	Local lOk := .T.
	Local aArea:=GetArea()
	
	If nOper=PD_EXCLUIR 
	
		dbSelectArea('SZ9')
		dbSetOrder(1)
		If !dbSeek(xFilial('SZ9')+ PadR( cPesqDoc , TamSX3("Z9_DOC")[01])+PadR( cPesqSerie , TamSX3("Z9_SERIE")[01]) )
			lOk := .F.	 				
			SetRestFault( 104, "Analise da Nota Fiscal "+cPesqDoc+'/'+cPesqSerie+" não cadastrado" )
		EndIf
	END
	
	If nOper==PD_INCLUIR

		If VALTYPE(oJson:Z9_DOC)=="U".or.;
			VALTYPE(oJson:Z9_SERIE)=="U".or.;
			VALTYPE(oJson:Z9_DATA)=="U".or.;
		    Empty(oJson:Z9_DOC).or.;
			Empty(oJson:Z9_SERIE).or.;
			Empty(oJson:Z9_DATA)
			lOk := .F.
			SetRestFault( 100, "Existem campos obrigatórios no cabeçalho que não foram preenchidos." )
			
		End

		For nX := 1 To Len( oJson:ensaios )
		
			/*dbSelectArea("SX5")
			dbSetOrder(1)
			If !dbSeek( xFilial("SX5") + 'Z9'+PadR( oJson:ensaios[nX]:Z9_ANALISE, TamSX3("Z9_ANALISE")[01] ) )
				lOk := .F.	 				
				SetRestFault( 103, "Análise "+oJson:ensaios[nX]:Z9_ANALISE+" não cadastrado" )
			EndIf*/
	
		Next nX
		
		dbSelectArea('SZ9')
		dbSetOrder(1)
		If dbSeek(xFilial('SZ9')+PadR( oJson:Z9_DOC , TamSX3("Z9_DOC")[01])+PadR( oJson:Z9_SERIE , TamSX3("Z9_SERIE")[01]) )
			lOk := .F.	 				
			SetRestFault( 105, "Analise da Nota Fiscal "+oJson:Z9_DOC+'/'+oJson:Z9_SERIE+" já cadastrado" )
		EndIf
	
		
	End
	
	RestArea(aArea)
Return lOk 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PROC_MOV    ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que faz a insercao/alteracao/exclusoa do            ³±±
±±³          ³ da rotina                                                  ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PROC_MOV(nOper)
	Local aCabec:={}
	Local aItens:={}
	Local aLinha:={}
	Local cErro := ""
	Local aMsg  :={}
	Local nX	 := 0
	Local lOk   :=.t.

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
	IF nOper==PD_EXCLUIR
		dbSelectArea('SZ9')
		dbSetOrder(1)
		dbSeek(xFilial('SZ9')+ PadR( cPesqDoc , TamSX3("Z9_DOC")[01])+PadR( cPesqSerie , TamSX3("Z9_SERIE")[01]) )
		While Z9_DOC+Z9_SERIE == PadR( cPesqDoc , TamSX3("Z9_DOC")[01])+PadR( cPesqSerie , TamSX3("Z9_SERIE")[01]).and.!eof()
			RecLock('SZ9',.f.)
			dbDelete()
			Msunlock()
			dbSkip()
		End
	End
	
	IF nOper==PD_INCLUIR
	
		dbSelectArea('SZ9')
		For nX := 1 To Len( oJson:ensaios )
			Reclock('SZ9',.t.)
			SZ9->Z9_FILIAL	:=xFilial('SZ9')
			SZ9->Z9_DOC		:=oJson:Z9_DOC
			SZ9->Z9_SERIE	:=oJson:Z9_SERIE
			SZ9->Z9_DATA	:=CTOD(oJson:Z9_DATA)

			SZ9->Z9_TIPO	:="1"		
			SZ9->Z9_RESULT	:=oJson:ensaios[nX]:Z9_RESULT
			SZ9->Z9_OBS		:=oJson:ensaios[nX]:Z9_OBS
			SZ9->Z9_ENSAIO	:=oJson:ensaios[nX]:Z9_ENSAIO
			SZ9->Z9_ESPECIF	:=oJson:ensaios[nX]:Z9_ESPECIF
			SZ9->Z9_VARIACA	:=oJson:ensaios[nX]:Z9_VARIACA
			SZ9->Z9_NORMA	:=oJson:ensaios[nX]:Z9_NORMA
			msUnlock()
		Next
		
		For nX := 1 To Len( oJson:parametros )
			Reclock('SZ9',.t.)
			SZ9->Z9_FILIAL	:=xFilial('SZ9')
			SZ9->Z9_DOC		:=oJson:Z9_DOC
			SZ9->Z9_SERIE	:=oJson:Z9_SERIE
			SZ9->Z9_DATA	:=CTOD(oJson:Z9_DATA)
			
			SZ9->Z9_TIPO	:="2"		
			SZ9->Z9_PARAMET	:=oJson:parametros[nX]:Z9_PARAMET
			SZ9->Z9_REFER	:=oJson:parametros[nX]:Z9_REFER
			msUnlock()
		Next
	End

Return {lOk,''} 		
