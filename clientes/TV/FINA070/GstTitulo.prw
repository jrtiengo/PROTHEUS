#include "TOTVS.CH"
#include "RESTFUL.CH"
#Include "Protheus.ch"
#Include "TopConn.ch"


#define STR001 "Servico de Baixa de Titulos do Holos Ric [ERP Protheus]"
#define STR002 "Metodo de baixa de titulos"

wsrestful GstTitulo description STR001

	wsdata codusu as string
	wsdata token  as string

	wsmethod post   description STR002 wssyntax "/GstTitulo/{option}"

end wsrestful

wsmethod post wsreceive codusu, token wsservice GstTitulo

	Local cContent		:= ""
	Local oJson			:= nil
	Local oUser			:= nil
	Local oLogin		:= nil
	Local lRet          := .T.
    
	Private lMsErroAuto	:= .F.
	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile	:= .T.
	
	if len(::aURLParms) == 0
		SetRestFault(401,"Informe a operacao (baixar)")
		return .F.
	endif

	if ::codusu == nil .or. ::token == nil
		SetRestFault(401,"Informe os parametros de autenticacao")
		return .F.
	endif

	SM0->(DbSeek("01"+ "022802"))
	cNumEmp:= SM0->M0_CODIGO + Alltrim(SM0->M0_CODFIL)
	cFilAnt:= SM0->M0_CODFIL

	::SetContentType("application/json")
	cContent := ::GetContent()
	
	oUser	:= ZADUserPortal():New(,::codusu)
	oLogin	:= CRMLoginSite():New()

	if !oLogin:valToken(oUser,::token)
		SetRestFault(401,oLogin:erroAuto)
		return .F.
	endif

	if !FwJsonDeserialize(cContent,@oJson)
		SetRestFault(401, "Erro interno")
		return .F.
	endif
    
    lRet := fBaixaTitulo(oJson)

return lRet

Static Function fBaixaTitulo(oContent)

	Local cPed      := Alltrim(oContent:pedido)
	Local dDtBaixa  := ctod(Alltrim(oContent:databaixa))
	Local nValRec	:= (oContent:valor)
	Local nDescon	:= (oContent:desconto)
	Local cBanco    := fRetBco((oContent:banco))
	Local nI        := 0
    Local aErroRot  := {}
    Local cStrErro  := ""
    Local oResp     := JsonObject():New()
	Local lAchou    := .f.	

	Private lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile	:= .T.

	if !empty(cBanco)
		dbSelectArea("SA6")
		SA6->(dbSetOrder(1))
		
		_cCodigo  := PadR(SUBSTR(cBanco, 1,3),TamSx3("A6_COD")[1])
		_cAgencia := PadR(SUBSTR(cBanco, 4,5),TamSx3("A6_AGENCIA")[1])
		_cConta   := PadR(SUBSTR(cBanco, 9,15),TamSx3("A6_NUMCON")[1])

		dbSeek(xFilial("SA6") + PadR(_cCodigo ,TamSX3("A6_COD")[1]) + PadR(_cAgencia , TamSX3("A6_AGENCIA")[1]) + PadR(_cConta, TamSX3("A6_NUMCON")[1]))
		If Found()

			cQryAux := ""
			cQryAux += "SELECT R_E_C_N_O_ AS SE1REC  "	   
			cQryAux += "  FROM " +RetSqlName("SE1") + " E1 "   	
			cQryAux += " WHERE "	  
			cQryAux += "    E1.D_E_L_E_T_ =' ' "	
			cQryAux += "   AND E1_PEDIDO  =  '" + PADR(alltrim(cPed),TamSx3("E1_PEDIDO")[1])  + "'  "	   	
			cQryAux += "   AND E1_FILIAL  = '022802'  "	   		
			cQryAux += "    AND E1_SALDO > 0  "			
 
 			cQryAux := ChangeQuery(cQryAux)   
			if SELECT('QRY_AUX') <> 0
				QRY_AUX->(DbCloseArea())	
			endIf
			TCQuery cQryAux New Alias "QRY_AUX"
			QRY_AUX->(DbGoTop())
			Do While ! QRY_AUX->(Eof())
				lAchou := .T.
				dbSelectArea("SE1")

				SE1->(dbGoTo(QRY_AUX->SE1REC))
					//dbSelectArea('SA1')
					//dbSetOrder(1)
					//dbSeek(xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA)
													
					if empty(SE1->E1_BAIXA)

						 aBaixa	:= {{"E1_FILIAL"   ,SE1->E1_FILIAL      ,Nil},;
									{"E1_PREFIXO"  ,SE1->E1_PREFIXO     ,Nil},;
									{"E1_NUM"      ,SE1->E1_NUM         ,Nil},;
									{"E1_PARCELA"  ,SE1->E1_PARCELA     ,Nil},;
									{"E1_TIPO"     ,SE1->E1_TIPO        ,Nil},;
									{"E1_MOEDA"	   ,SE1->E1_MOEDA, 		  Nil},;
									{"AUTMOTBX"    ,"NOR"               ,Nil},;
									{"AUTBANCO"    ,PadR(_cCodigo        ,   TamSX3("A6_COD")[1]),        Nil},;
									{"AUTAGENCIA"  ,PadR(_cAgencia       ,   TamSX3("A6_AGENCIA")[1]),    Nil},;
									{"AUTCONTA"    ,PadR(_cConta         ,   TamSX3("A6_NUMCON")[1]),     Nil},;
									{"AUTDTBAIXA"  ,dDtBaixa            ,Nil},;
									{"AUTDTCREDITO",dDtBaixa            ,Nil},;
									{"AUTHIST"     ,"VALOR RECEBIDO"    ,Nil},;
									{"AUTJUROS"    ,0   				,Nil,.T.},;
									{"AUTDESCONT"  ,nDescon      		,Nil},;
									{"AUTVALREC"   ,nValRec      		,Nil}} 
						
						MSExecAuto ({|x,y| FINA070(x,y)},aBaixa, 3)
						//MSExecAuto ({|x,y| u_xFINA070(x,y)},aBaixa, 3)

						If lMsErroAuto

							DisarmTransaction()
							lRet := .F.
							cStrErro := '[MsExecAuto - FINA070|erro|]' + CRLF
							aErroRot := GetAutoGRLog()
							for ni := 1 to len(aErroRot)
								cStrErro += aErroRot[ni]+ CRLF
							next
							SetRestFault(401,cStrErro)
							return .F.
						else

							oResp['status'] := 'Titulo Baixado com sucesso'
							::SetResponse(ENCODEUTF8(oResp:toJson()))

						endif
					endIf
				QRY_AUX->(DbSkip())
			EndDo
			QRY_AUX->(DbCloseArea())

			if !lAchou
				 SetRestFault(401, "Nenhum titulo encontrado para o pedido nr: "+alltrim(cPed))
		   	 	return .F.
			endif
		else
            SetRestFault(401, "Banco nao encontrado")
		    return .F.
		endIf
	else
		SetRestFault(401, "Banco nao encontrado")
		return .F.
	endIf

Return

Static Function fRetBco(cBanco)
	Local cSA6Key := ""

	Do Case
	case ALLTRIM(cBanco) == "239404"
		cSA6Key := padr("001",tamsx3("A6_COD")[1],"")+padr("34258",tamsx3("A6_AGENCIA")[1],"")+padr("58734",tamsx3("A6_NUMCON")[1],"")
	case ALLTRIM(cBanco) == "239614"
		cSA6Key := padr("104",tamsx3("A6_COD")[1],"")+padr("3525",tamsx3("A6_AGENCIA")[1],"")+padr("3341",tamsx3("A6_NUMCON")[1],"")
	case ALLTRIM(cBanco) == "248538"
		cSA6Key := padr("237",tamsx3("A6_COD")[1],"")+padr("26573",tamsx3("A6_AGENCIA")[1],"")+padr("960004",tamsx3("A6_NUMCON")[1],"")
	case ALLTRIM(cBanco) == "340778"
		cSA6Key := padr("237",tamsx3("A6_COD")[1],"")+padr("26573",tamsx3("A6_AGENCIA")[1],"")+padr("960004",tamsx3("A6_NUMCON")[1],"")
	case ALLTRIM(cBanco) == "391898"
		cSA6Key := padr("461",tamsx3("A6_COD")[1],"")+padr("0001",tamsx3("A6_AGENCIA")[1],"")+padr("57989",tamsx3("A6_NUMCON")[1],"")
	endCase

Return cSA6Key
