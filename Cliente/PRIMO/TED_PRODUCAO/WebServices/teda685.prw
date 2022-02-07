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
±±³Funcao    ³TEDA685     ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para manutenção do cadastro de         ³±±
±±³          ³ Apontamento de Perda de Produção mata010                               ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL TEDA685 DESCRIPTION "Apontamento de Perda de Produção" 

WSDATA BC_OP AS FLOAT
WSDATA BC_PRODUTO AS STRING
WSDATA BC_QUANT AS FLOAT
WSDATA BC_MOTIVO AS FLOAT
WSDATA BC_DATA AS STRING

//WSMETHOD GET DESCRIPTION "Listar Pedido de Compra." WSSYNTAX "/"
WSMETHOD POST DESCRIPTION "Método para inclusão de Apontamento de Perda de Produção" WSSYNTAX "/" 
//WSMETHOD PUT DESCRIPTION "Método para alteração de Apontamento de Perda de Produção" WSSYNTAX "/"
WSMETHOD DELETE DESCRIPTION "Método para exclusão de Apontamento de Perda de Produção" WSSYNTAX "/" 

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
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDA685

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local cErro  	:= ""
	Local aMsg		:= {}
	Local nX		:= 0
	Private oJson 

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Private __nnLock 
	Private __CCARQ

	u_LogConsole("TEDA685", "Entrei TEDA685 POST")

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.						
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )	
		u_LogConsole("TEDA685", "JSON COM PROBLEMA")

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
			cMsgErro := "Erro ao incluir o Apontamento de Perda de Produção ."+aRet[2]  
			SetRestFault(115, EncodeUTF8(cMsgErro, "cp1252")   )
		End

	EndIf
	
Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ PUT      ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para alterar                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE TEDA685

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local cErro  	:= ""
	Local aMsg		:= {}
	Local nX		:= 0
	Private oJson 

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Private __nnLock 
	Private __CCARQ

	u_LogConsole("TEDA685", "Entrei TEDA685,put ")


	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.						
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )	
		u_LogConsole("TEDA685", "JSON COM PROBLEMA")
	Else
	
		//-------------------------------
		//valida os dados do JSON 
		//-----------------------------
		lOk:=VLD_JSON(PD_ALTERAR) 

	End

	If lOk   

		aRet:=PROC_MOV(PD_ALTERAR)

		If aRet[1]
		
			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"ALTERADO"')
		
			::SetResponse('}')
		
		ELSE
			SetRestFault(115, "Erro ao alterar o Apontamento de Perda de Produção ."+aRet[2]  )
		End
	end

Return( lOk )
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ DELETE   ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para excluir OP                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD DELETE WSRECEIVE B1_COD WSSERVICE TEDA685

	Local lOK		 	:= .T.
	Local cMsg		:= ""
	Local cErrorLog	:= ""
	//Local cBody		:= ::GetContent()
	Private cB1Cod:=::B1_COD
	Private lMsErroAuto := .F.
	Private oJson 
	
	u_LogConsole("TEDA685", 'Entrei na rotina, delete')

	::SetContentType("application/json")	// define o tipo de retorno do método

	//+-------------------------------------------------+
	//| Verifica se foi informado os parametros no link |
	//+-------------------------------------------------+
	If VALTYPE(::B1_COD)=="U" .OR. EMPTY(::B1_COD)

		lOk := .F.						
		cMsgErro
		cMsgErro :=  "Codigo B1_COD não informado"
		SetRestFault(115, EncodeUTF8(cMsgErro, "cp1252")   )

		u_LogConsole("TEDA685", "B1_COD não informado para deletar")

	else
		//-------------------------------
		//valida os dados do JSON 
		//-----------------------------
		lOk:=VLD_JSON(PD_EXCLUIR) 
	
	END
	
	If lOk   

		aRet:=PROC_MOV(PD_EXCLUIR)

		If aRet[1]
		
			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"EXCLUIDO"')
		
			::SetResponse('}')
		
		ELSE
			cMsgErro :=  "Erro ao excluir o Apontamento de Perda de Produção ."+aRet[2]  
			SetRestFault(115, EncodeUTF8(cMsgErro, "cp1252")   )
		End
	end

Return(lOk)



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
	
		If  Empty(oJson:BC_PRODUTO).or.;
			Empty(oJson:BC_QUANT).or.;
			Empty(oJson:BC_OP).or.;
			Empty(oJson:BC_DATA).or.;
			Empty(oJson:BC_MOTIVO)
			lOk := .F.
			cMsgErro :=  "Existem campos obrigatórios que não foram preenchidos." 
			SetRestFault(104, EncodeUTF8(cMsgErro, "cp1252")   )
		End
		iF EMPTY(u_fOPbyOF(oJson:BC_OP)[1])
			lOk := .F.
			cMsgErro := "Ordem de Produão não cadastrada" 
			SetRestFault(105, EncodeUTF8(cMsgErro, "cp1252")   )
		EndIf

		dbSelectArea('SB1')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SB1')+PadR( oJson:BC_PRODUTO, TamSX3("BC_PRODUTO")[01] ))
			lOk := .F.
			cMsgErro :=  "Produto não Cadastrado" 
			SetRestFault(106, EncodeUTF8(cMsgErro, "cp1252")   )
		EndIf
		
		dbSelectArea('SB1')
		dbSetOrder(1)
		IF sb1->b1_peso==0
			lOk := .F.
			cMsgErro := "Peso Não cadastrado"
			SetRestFault(108, EncodeUTF8(cMsgErro, "cp1252")   )
		EndIf
		

		dbSelectArea('CYO')
		dbSetOrder(1)
		IF !dbSeek(xFilial('CYO')+PADR(ALLTRIM(STR(oJson:BC_MOTIVO)), TamSX3("BC_MOTIVO")[01] ) )
			lOk := .F.
			cMsgErro := "Motivo (BC_MOTIVO) não Cadastrado" 
			SetRestFault(107, EncodeUTF8(cMsgErro, "cp1252")   )
		EndIf
		
	end

	If nOper=PD_EXCLUIR
		
	end

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
	
	If nOper==PD_INCLUIR
		
		Aadd(aCabec,{'BC_OP'	    , PadR( u_fOPbyOF(oJson:BC_OP)[1], TamSX3("BC_OP")[01]), Nil })
		Aadd(aCabec,{'BC_OPERAC'	, '10' 												, Nil })
		
		Aadd(aLinha,{'BC_PRODUTO'	, PadR( oJson:BC_PRODUTO, TamSX3("BC_PRODUTO")[01] ), Nil })
		Aadd(aLinha,{'BC_CODDEST'	, GETMV('ES_CODREFU')				 				, Nil })
		Aadd(aLinha,{'BC_QUANT'		, oJson:BC_QUANT 									, Nil })
		Aadd(aLinha,{'BC_QTDDEST'	, oJson:BC_QUANT*sb1->b1_peso						, Nil })
		Aadd(aLinha,{'BC_TIPO'		, 'R'												, Nil })
		Aadd(aLinha,{'BC_LOCORIG'	, SB1->B1_LOCPAD									, Nil })
		Aadd(aLinha,{'BC_MOTIVO'	, ALLTRIM(STR(oJson:BC_MOTIVO))						, Nil })
		Aadd(aLinha,{'BC_DATA'		, CTOD(oJson:BC_DATA)					 			, Nil })
		Aadd(aLinha,{'BC_OPERAC'	, '10' 												, Nil })
		//Aadd(aLinha,{'BC_LOCAL'		, Posicione('SB1',1,xFilial('SB1')+GETMV('ES_CODREFU'),'B1_LOCPAD')	, Nil })

						
		Aadd(aItens,aLinha)

	END
	
	If nOper=PD_EXCLUIR
		
		
	END
	
	
	lMsErroAuto := .f.

	u_LogConsole("TEDA685", "vou processar operação "+Str(nOper,1))
	
	MSExecAuto( { |x,y,z| MatA685( x, y , z )}, aCabec, aItens,nOper ) 
			
	If lMsErroAuto

		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErro += x })
		u_LogConsole("TEDA685", "problemas..."+cErro)
		lOk := .F.				 				
	end
	
Return {lOk,cErro} 		

