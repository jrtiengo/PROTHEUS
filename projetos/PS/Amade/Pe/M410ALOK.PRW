#include "rwmake.ch"
/*/
�������������������������������������������������������������������������Ŀ��
���Funcao    � M410ALOK � Autor � Rogerio Batista       � Data � 11/06/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada para travar alteracao de pedidos com carga ��
���          � montada.                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Amade.                                          ���
�������������������������������������������������������������������������Ĵ��
��� Alt.     � Carlos N. Puerta  em 30/12/2004                            ���
���          � Carlos em 09/08/2005 - Permissao usuario 000001 altere PV  ���
���          � em carga                                                   ���
���          � Carlos em 08/04/2008 - Criacao de controle para permitir   ���
���          �                        ou nao a alteracao do pedido venda. ���
��������������������������������������������������������������������������ٱ�
/*/

/****************************************************************************
* Inclu�do tratamento para impedir que o PV seja alterado se j� foi liberado
* para exepdi��o, conforme novo processo de controle de pedidos.
* Robson Santos - Call System - 24/09/2012
****************************************************************************/
/****************************************************************************
* Ajustado para que, onde considerava a empresa 10-Web Amade, considere
* igualmente a empresa 11-Web Emp�rio.
* Robson Santos - Call System - 03/12/2012  - refeito 21/01/2013
* Solicitante: Osni de Paula
****************************************************************************/
/****************************************************************************
* Alterado para verificar a marca se o PV est� em processo de impress�o para
* n�o permitir altera��o (Campo C5_XIMPR).
* Motivo: Novo processo de expedi��o.
* Robson Santos - Call System - 08/07/2013
****************************************************************************/
/****************************************************************************
* Alterado para pedir confirma��o de altera��o se o pedido estiver com status
* de liberado para Expedi��o/Retira e cancelar a libera��o se confirmado.
* Robson Santos - Call System - 15/07/2013
****************************************************************************/
/****************************************************************************
* Ajustado para n�o testar prioridades de Expedi��o para empresa 10/11 WEB.
* Robson Santos - Call System - 26/08/2013
****************************************************************************/
/****************************************************************************
* Ajustada falha em que mudava o status do pedido durante o processo de c�pia
* O correto � somente em caso de altera��o.
* Robson Santos - Call System - 02/09/2013
****************************************************************************/

User Function M410ALOK()
Local  aUser   := PswRet(1)
//Local _cAltPed := Upper(GetMv("MV_AMAALTP"))        //Criado por Alexandre em 19/01/2007
//Local _cAltPedE:= Upper(GetMv("MV_AMAALTP"))        // Usu�rios com permiss�o para alterar PVs a Entregar
//Local _cAltPedR:= Upper(GetMv("MV_AMAALTR"))        // Usu�rios com permiss�o para alterar PVs a Retirar

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
				Alert( "Aguardando o faturamento. O pedido n�o pode ser alterado.")
				_lRet := .F.
			ElseIf SC5->C5_XIMPR == "S"       // Se pedido est� em processo de impress�o pela Expedi��o/Retira
				Alert("Pedido est� em processo de impress�o pela Expedi��o ou Retira. N�o pode ser alterado.")
				_lRet := .F.
			Elseif !SC5->C5_XLIBOK $ "Z,W,L"                                     //Se Pedido N�O estiver liberado para Expedi��o, Recepcionado ou Em separa��o;
				_lRet := .T.                                                      //Permite
			Elseif SC5->C5_XLIBOK $ "L"                                          //Se liberado para Expedi��o
/* TRECHO COMENTADO PARA POR AS NOVAS REGRAS DO WMS
				_lResp := msgbox("Pedido j� foi liberado para Expedi��o mas ainda n�o foi recepcionado. Se continuar ser� necess�rio liberar novamente. Deseja mesmo alterar?","Aten��o!", "YESNO")
				if _lResp
					_lRet := .T.            //Permite
				Else
					Alert("Altera��o cancelada.")
					_lRet := .F.            //N�o permite
				Endif
*/
				//Nova regra para WMS
				_lRet := .F.             //N�o permite
				
				If FWAlertYesNo("Essa a��o vai cancelar a separa��o do seu pedido, e o mesmo sera colocado ao final da fila de separa��o, deseja MESMO cancelar? ", "Cancelamento WMS!")
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
			Else
				Alert("Pedido j� recepcionado pela Expedi��o ou Retira. N�o pode ser alterado.")
				_lRet := .F.
			Endif
		Endif
		////////////////////////////////////
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
						Aviso("ATEN��O !","Usuario "+AllTrim(USRRETNAME(_cUsr))+" nao autorizado a alterar PV do(a) usuario(a) "+AllTrim(USRRETNAME(sc5->c5_user)),{ " Sair >> "},1,"Pedido de Venda")
						_lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If SC5->C5_XLIBOK $ "L" .and. _lRet .and. Altera        // Se estava liberado para Expedi��o mas n�o recepcionado e est� solicitando altera��o
	RecLock("SC5",.F.)
	SC5->C5_XLIBOK      := ""                           // Muda status para pedido em aberto
	SC5->C5_XDTHLIB     := ""                           // Limpa data da libera��o para Expedi��o
	SC5->C5_XCODBAR     := ""                           // Limpa o c�digo de barras que identifica a vers�o liberada anteriormente
	SC5->C5_ZCANCW	    := ""                           // Limpa o c�digo de cancelamento enviado ao WMS
	MsUnLock()
Endif

RestArea(_aArea)
Return(_lRet)
