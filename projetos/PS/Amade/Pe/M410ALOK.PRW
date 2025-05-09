#include "rwmake.ch"
/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M410ALOK ³ Autor ³ Rogerio Batista       ³ Data ³ 11/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de entrada para travar alteracao de pedidos com carga ±±
±±³          ³ montada.                                                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Amade.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alt.     ³ Carlos N. Puerta  em 30/12/2004                            ³±±
±±³          ³ Carlos em 09/08/2005 - Permissao usuario 000001 altere PV  ³±±
±±³          ³ em carga                                                   ³±±
±±³          ³ Carlos em 08/04/2008 - Criacao de controle para permitir   ³±±
±±³          ³                        ou nao a alteracao do pedido venda. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/

/****************************************************************************
* Incluído tratamento para impedir que o PV seja alterado se já foi liberado
* para exepdição, conforme novo processo de controle de pedidos.
* Robson Santos - Call System - 24/09/2012
****************************************************************************/
/****************************************************************************
* Ajustado para que, onde considerava a empresa 10-Web Amade, considere
* igualmente a empresa 11-Web Empório.
* Robson Santos - Call System - 03/12/2012  - refeito 21/01/2013
* Solicitante: Osni de Paula
****************************************************************************/
/****************************************************************************
* Alterado para verificar a marca se o PV está em processo de impressão para
* não permitir alteração (Campo C5_XIMPR).
* Motivo: Novo processo de expedição.
* Robson Santos - Call System - 08/07/2013
****************************************************************************/
/****************************************************************************
* Alterado para pedir confirmação de alteração se o pedido estiver com status
* de liberado para Expedição/Retira e cancelar a liberação se confirmado.
* Robson Santos - Call System - 15/07/2013
****************************************************************************/
/****************************************************************************
* Ajustado para não testar prioridades de Expedição para empresa 10/11 WEB.
* Robson Santos - Call System - 26/08/2013
****************************************************************************/
/****************************************************************************
* Ajustada falha em que mudava o status do pedido durante o processo de cópia
* O correto é somente em caso de alteração.
* Robson Santos - Call System - 02/09/2013
****************************************************************************/

User Function M410ALOK()
Local  aUser   := PswRet(1)
//Local _cAltPed := Upper(GetMv("MV_AMAALTP"))        //Criado por Alexandre em 19/01/2007
//Local _cAltPedE:= Upper(GetMv("MV_AMAALTP"))        // Usuários com permissão para alterar PVs a Entregar
//Local _cAltPedR:= Upper(GetMv("MV_AMAALTR"))        // Usuários com permissão para alterar PVs a Retirar

Private _aArea := GetArea()
Private _cUsr  := Space(06)
Private _lRet  := .T.
Private _cZBUsrs  := ""
Private _cZCUsrs  := ""
Private _cUsrs    := ""

Private _cA1Vend  := ""

If Altera
	If OmsHasCg(SC5->C5_NUM) .And. ( aUser[1,1] <> "000000" .And. aUser[1,1] <> "000001" )
		Alert("Pedido de venda em carga. Nao pode ser alterado...!!!")
		_lRet := .F.
	Else
		//Criado por Alexandre em 19/01/2007
		//      Virada Protheus11
		//		If !SC5->C5_LIBEROK $ "Z,W" .Or. ALLTRIM(UPPER(SUBST(CUSUARIO,7,15))) $ _cAltPed
		//		If !SC5->C5_LIBEROK $ "Z,W" .Or. RetCodUsr() $ _cAltPed
		
		
		If !(cEmpAnt $ "10/11")
			If !Empty( SC5->C5_LIBEROK ) .And. !Empty( SC5->C5_XLIBOK ) .And. !( SC5->C5_XLIBOK $ 'W,Z,L' ) .And. Empty( C5_NOTA )
				Alert( "Aguardando o faturamento. O pedido não pode ser alterado.")
				_lRet := .F.
			ElseIf SC5->C5_XIMPR == "S"       // Se pedido está em processo de impressão pela Expedição/Retira
				Alert("Pedido está em processo de impressão pela Expedição ou Retira. Não pode ser alterado.")
				_lRet := .F.
			Elseif !SC5->C5_XLIBOK $ "Z,W,L"                                     //Se Pedido NÃO estiver liberado para Expedição, Recepcionado ou Em separação;
				_lRet := .T.                                                     //Permite
			Elseif SC5->C5_XLIBOK $ "L"								             //Se liberado para Expedição
				_lRet := .F.     
				
				If FWAlertYesNo("Essa ação vai cancelar a separação do seu pedido, e o mesmo sera colocado ao final da fila de separação, deseja MESMO cancelar? ", "Cancelamento WMS!")
					//Tratamento para permitir cancelamento do pedido no WMS
					DbSelectArea( "ZS3" )
					ZS3->(DbSetOrder(1)) //ZS3_FILIAL+ZS3_TABELA+ZS3_CHAVE 
					cChave := ZS3->(MsSeek(FWxFilial("ZS3")+"SC5"+FWxFilial("SC5")+'|'+SC5->C5_NUM))
					
					If cChave .and. Empty(SC5->C5_ZCANCW)
							RecLock("SC5",.F.)
							SC5->C5_ZCANCW		:= '1' //Cancelamento solicitado
							SC5->(MSUnLock())	
							FWAlertWarning('Requisicao enviada ao WMS aguardar a liberacao (cerca de 15 min)!','Cancelamento WMS')
							_lRet := .F. 
					Elseif cChave .and. SC5->C5_ZCANCW == '1'
						FWAlertWarning('Cancelamento ja enviado ao WMS, aguardando retorno do cancelamento!','Cancelamento WMS')
						_lRet := .F. 
					Elseif cChave .and. SC5->C5_ZCANCW == '2'
						FWAlertWarning('Pedido ja cancelado no WMS, alteracao permitida!.','Cancelamento WMS')
						_lRet := .T.
					Elseif ! cChave .and. Empty(SC5->C5_ZCANCW)
						FWAlertWarning('Pedido nao enviado ao WMS, alteracao permitida!.','Cancelamento WMS')
						_lRet := .T.
					Endif    
				Endif                                            
				
				/*
				lResp := msgbox("Pedido já foi liberado para Expedição mas ainda não foi recepcionado. Se continuar será necessário liberar novamente. Deseja mesmo alterar?","Atenção!", "YESNO")
				if _lResp
					_lRet := .T.            //Permite                                                                                                             
				Else
					Alert("Alteração cancelada.")
					_lRet := .F.            //Não permite
				Endif
				*/
Else
	Alert("Pedido já recepcionado pela Expedição ou Retira. Não pode ser alterado.")
	_lRet := .F.
Endif
Endif

EndIf
EndIf
//  Alteracao em 30/12/2004

If _lRet .And. (SM0->M0_CODIGO $ "10/11")
	_cUsr := RetCodUsr()
	If cNivel < 3
		If _cUsr <> SC5->C5_USER
			Alert("Usuario nao autorizado a alterar o PV...!!!")
			_lRet := .F.
		EndIf

	ElseIf cNivel < 5
		DbSelectArea( "SZF" )
		SZF->( DbSetOrder( 2 ) ) // SZF_FILIAL+SZF_CODLOC+SZF_CODCLI+SZF_LOJA+SZF_CODIGO
		If SZF->( !DbSeek( xFilial( "SZF" ) + SC5->( C5_X_ENTR + C5_CLIENTE + C5_LOJACLI ) + _cUsr ) )
			Alert("Usuario nao autorizado a alterar o PV...!!!")
			_lRet := .F.
		EndIf
	EndIf
EndIf

//  Regra incluida em 08/04/2008 - Solicitante: Sr. Osni
If !(cEmpAnt $ "10/11")
	If cNivel < 6
		If _lRet
			_cUsr    := RetCodUsr(Subst(cUsuario,1,6))
			_cA1Vend := AllTrim(GETADVFVAL("SA1","A1_VEND",XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,1,SPACE(06)))
			If Substr(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+_cA1Vend,1,""),1,2) <> "X "
				If AllTrim(GetAdvFVal("SA3","A3_COD",xFilial("SA3")+_cUsr,7,"")) <> AllTrim(_cA1Vend)
					_cZBUsrs := Tabela("ZB",_cUsr,.F.)
					_cZCUsrs := Tabela("ZB",_cUsr,.F.)
					_cUsrs   := AllTrim(_cZBUsrs) + IIF(!Empty(_cZCUsrs),"/"+AllTrim(_cZCUsrs),"")
					If _cUsr != SC5->C5_USER .And. !(SC5->C5_USER $ _cUsrs)
						Aviso("ATENÇÃO !","Usuario "+AllTrim(USRRETNAME(_cUsr))+" nao autorizado a alterar PV do(a) usuario(a) "+AllTrim(USRRETNAME(sc5->c5_user)),{ " Sair >> "},1,"Pedido de Venda")
						_lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If SC5->C5_XLIBOK $ "L" .and. _lRet .and. Altera        // Se estava liberado para Expedição mas não recepcionado e está solicitando alteração
	RecLock("SC5",.F.)
	SC5->C5_XLIBOK      := ""                           // Muda status para pedido em aberto
	SC5->C5_XDTHLIB     := ""                           // Limpa data da liberação para Expedição
	SC5->C5_XCODBAR     := ""                           // Limpa o código de barras que identifica a versão liberada anteriormente
	SC5->C5_ZCANCW	    := ""                           // Limpa o código de cancelamento enviado ao WMS
	MsUnLock()
Endif

RestArea(_aArea)
Return(_lRet)
