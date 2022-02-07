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
±±³Funcao    ³TEDA240     ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para manutenção do                     ³±±
±±³          ³ MOVIMENTOS INTERNOS - MATA240 - SD3 -                      ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL TEDA240 DESCRIPTION "Movimentos Internos""

WSDATA D3_TM AS STRING
WSDATA D3_COD AS STRING		
WSDATA D3_OP AS STRING 
WSDATA D3_EMISSAO AS STRING
WSDATA D3_CC AS STRING 
WSDATA D3_QUANT AS FLOAT
WSDATA D3_DOC AS STRING

//WSMETHOD GET DESCRIPTION "Listar Movimentos Internos  ." WSSYNTAX "/"
WSMETHOD POST DESCRIPTION "Incluir Movimentos Internos  ." WSSYNTAX "/" 
//WSMETHOD PUT DESCRIPTION "Alterar Movimentos Internos  ." WSSYNTAX "/"
WSMETHOD DELETE DESCRIPTION "Excluir Movimentos Internos  ." WSSYNTAX "/"

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
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDA240

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()

	Private oJson 	

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a Movimentos Internos  Json em Objeto

		lOk := .F.						
		SetRestFault( 101, "Nao foi possivel processar Json." )	

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
			::SetResponse('"message":"INCLUIDO",')
			::SetResponse('"D3_DOC":"'+SD3->D3_DOC+'",')
			::SetResponse('"D3_FILIAL":"'+SD3->D3_FILIAL+'"')
		
			::SetResponse('}')
		
		ELSE
			SetRestFault(115, "Erro ao incluir o movimento interno"+aRet[2]  )
		End
		

	EndIf

Return( lOk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ DELETE   ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para deletar PV                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD DELETE WSRECEIVE D3_DOC WSSERVICE TEDA240

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local oJson 

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile := .T.
	Private cChavePesq		:=  PadR( ::D3_DOC, TamSX3("D3_DOC")[01])

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If VALTYPE(::D3_DOC)=="U".OR.EMPTY(::D3_DOC)

		lOk := .F.						
		SetRestFault( 116, "D3_DOC nao informado na querystring" )	

	Else
		//-------------------------------
		//valida os dados do JSON 
		//-----------------------------
		lOk:=VLD_JSON(PD_EXCLUIR) 

	EndIf

	If lOk   
		aRet:=PROC_MOV(PD_EXCLUIR)
		If aRet[1]
		
			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"ESTORNADO"')
			::SetResponse('}')
		
		ELSE
			SetRestFault(115, "Erro "+cChavePesq )
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
	

	If nOper=PD_INCLUIR

		dbSelectArea("SF5")
		dbSetOrder(1)
		If !dbSeek( xFilial("SF5") + PadR( oJson:D3_TM, TamSX3("D3_TM")[01] ) )
			lOk := .F.	 				
			SetRestFault( 112, "Tipo de Movimento "+oJson:D3_TM+" não cadastrado" )
		EndIf
		
		If VALTYPE(oJson:D3_OP)<>"U" .AND. !Empty(oJson:D3_OP)
			/*dbSelectArea("SC2")
			dbSetOrder(1)
			If !dbSeek( xFilial("SC2") + PadR( oJson:D3_OP, TamSX3("D3_OP")[01] ) )*/
			if empty(u_fOPbyOF(oJson:D3_OP)[1])
				lOk := .F.	 				
				SetRestFault( 113, "Ordem de Produção "+str(oJson:D3_OP)+" não existe" )
			EndIf
		End
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		If !dbSeek( xFilial("SB1") + PadR( oJson:D3_COD, TamSX3("D3_COD")[01] )  )
			lOk := .F.	 				
			SetRestFault( 103, "Produto "+oJson:D3_COD+" nao cadastrado." )
		EndIf
		
		iF VALTYPE(oJson:D3_CC)<>"U" .AND. !EMPTY(oJson:D3_CC)
			dbSelectArea("CTT")
			dbSetOrder(1)
			If !dbSeek( xFilial("CTT") + PadR( oJson:D3_CC, TamSX3("D3_CC")[01] ) )
				lOk := .F.	 				
				SetRestFault( 105, "Centro de Custo "+oJson:D3_CC+" não existe" )
			EndIf
		END
		
	END

	If nOper=PD_EXCLUIR 
	
		dbSelectArea('SD3')
		dbSetOrder(2)
		If !dbSeek(xFilial('SD3')+cChavePesq,.F.)
			lOk := .F.	 				
			SetRestFault( 111, "Movimentos Interno "+cChavePesq+" não cadastrado" )
		EndIf
		u_LogConsole("TEDA240", "ACHEI" + SD3->D3_DOC+' '+cChavePesq )
	END

	If nOper=PD_INCLUIR
		If  VALTYPE(oJson:D3_TM)='U'.OR.Empty(oJson:D3_TM).or.;
			VALTYPE(oJson:D3_COD)='U'.OR.Empty(oJson:D3_COD).or.;
			VALTYPE(oJson:D3_QUANT)='U'.OR.Empty(oJson:D3_QUANT).or.;
			VALTYPE(oJson:D3_EMISSAO)='U'.OR.Empty(oJson:D3_EMISSAO)
			lOk := .F.
			SetRestFault( 104, "Existem campos obrigatórios no cabeçalho que não foram preenchidos." )
			
		End
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
	Local lOk	:=.t.

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
	IF nOper==PD_INCLUIR
		cDocumen := GetSxeNum("SD3","D3_DOC")
	
		aAdd( aCabec, {"D3_TM"     	, oJson:D3_TM,NIL})
		aAdd( aCabec, {"D3_COD"  	, oJson:D3_COD,NIL})
		aAdd( aCabec, {"D3_QUANT"  	, oJson:D3_QUANT,NIL})
		aAdd( aCabec, {"D3_EMISSAO"	, CTOD(oJson:D3_EMISSAO),NIL})
		If VALTYPE(oJson:D3_OP)<>"U" .AND. !Empty(oJson:D3_OP)
			aAdd( aCabec, {"D3_OP" 		, u_fOPbyOF(oJson:D3_OP)[1],NIL})
		END
		If VALTYPE(oJson:D3_CC)<>"U" .AND. !Empty(oJson:D3_CC)
			aAdd( aCabec, {"D3_CC" 		, oJson:D3_CC,NIL} )
		END
		aAdd( aCabec, {"D3_DOC" 	, cDocumen,NIL} )
	
		MSExecAuto( {|x,y| MATA240(x,y)}, aCabec, nOper )//3- Inclusão, 4- Alteração, 5- Exclusão
	
		If lMsErroAuto
			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })
			lOk := .F.
			u_LogConsole("TEDA240", "Erro não Identificado" + cChavePesq+CRLF + cErro )				 				
		END
					    
	ELSE
	
		Private l240:=.T.,l250:=.F.,l241:=.F.,l242:=.F.,l261:=.F.,l185:=.F.
		Private	l240Auto	:= .t.
		Private cCusMed := GetMv("MV_CUSMED")
	
		a240Estorn( 'SD3', SD3->( RecNo() ), 4 )
		
		IF SD3->D3_ESTORNO<>'S'
			lOkt:=.f.
		eND
	END
			
	Return {lOk,cErro} 		

