#include 'totvs.ch'

/*/{Protheus.doc} MT084FOL
 Objetivo: Bloqueio customizado de aprovação por tipo de produto.
PARAMIXB = {aDocto,dDataRef,nOper,cDocSF1,lResiduo}
aDocto = {SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,APROVADOR}
@type user function
@author Gregory A.
@since 13/04/2020
@version 1.0 
@see https://tdn.totvs.com.br/display/public/PROT/MT094FIL+-+Filtra+registros+da+mBrowse 
/*/
User Function MT097GRV()

	Local _lRet    := .T.
	Local nOper    := PARAMIXB[ 3 ]
	Local aDocto   := PARAMIXB[ 1 ]
	Local cTipo    := AllTrim( aDocto[ 2 ] )
	Local cNumero  := AllTrim( aDocto[ 1 ] )
	Local aArea 	:= GetArea()
	Local cProd 	:= ""
	Local cPed		:= ""
	Local cTipoAp	:= ""
	Local cTipos	:= SuperGetMV("ES_APVTPPR", .F.,"MP")
	Local nValApv	:= SuperGetMV("ES_APVTPVL", .F.,15000)
	Local cTpProd	:= ""
	Local nTotal	:= 0
	Local lProdPar	:= .F.
	
	If nOper == 4 // Verifica se é liberação
	
		If cTipo == "PC" //Verifica se é pedido de compra
			dbSelectArea('SAK')
			dbSetOrder(1)
			dbSeek(xFilial('SAK')+SCR->CR_APROV,.f.)
			//dbSeek(xFilial('SAK')+__cUserID,.f.)
			cTipoAp := AllTrim(SAK->AK_TPPROD)
			If cTipoAp == "S" //Verifica se o aprovador tem limitação de tipo
				
				dbSelectArea("SC7")
				MsSeek(xFilial("SC7") + cNumero )
				While !SC7->( Eof() ) .And. SC7->C7_FILIAL + Substr( SC7->C7_NUM, 1, Len( SC7->C7_NUM ) ) == xFilial("SC7") + cNumero
			
					dbSelectArea("SB1")
					dbSeek(xFilial("SB1") + SC7->C7_PRODUTO )
					If !(SB1->B1_TIPO $ cTipos)
						lProdPar:= .T.
						cProd	:= AllTrim(SB1->B1_COD)
						cPed	:= AllTrim(SC7->C7_NUM)
						cTpProd	:= AllTrim(SB1->B1_TIPO)  
					EndIf
					nTotal += SC7->C7_TOTAL
					SC7->(dbSkip())
				EndDo
				
				If lProdPar //Verifica se teve algum produto diferente dos tipos indicados pelo parametro 
					If nTotal > nValApv
						_lRet := .F.
						MsgStop("O pedido não pode ser liberado pois há produto(s) com valor limite excedido."+CRLF+;
						"Pedido: " + cPed + " Produto: " + cProd + " Tipo: " +cTpProd, "Liberação Doc."+CRLF+;
						"Valor total do pedido: " +cValToChar(nTotal))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return _lRet