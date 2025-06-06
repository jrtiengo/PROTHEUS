#Include "Protheus.ch"
/*
-----------------------------------------------------------------------------
| Programa  | MS520VLD  | Autor | Call System           | Data | 12/09/2016 |
-----------------------------------------------------------------------------
| Desc.     | PE acionado na exclusao da nota fiscal                        |
-----------------------------------------------------------------------------
*/
User Function MS520VLD()
Local aArea		:= GetArea()
Local aAreaSF2	:= SF2->( GetArea() )
Local aAreaSD2	:= SD2->( GetArea() )
Local cPedidos	:= ""
Local lRet		:= .T.
Local lAglutina	:= GetMV( "ES_AGLUTIN",, .T. )

// Nao excluir a nota fiscal aglutinadora se um dos pedidos
// que compoe ja foi faturado. (filhos faturados)
If lAglutina .And. SF2->( !Eof() )
	DbSelectArea( "SD2" )
	SD2->( DbSetOrder( 3 ) )
	SD2->( DbSeek( xFilial( "SD2" ) + SF2->F2_DOC + SF2->F2_SERIE ) )
	While SD2->( !Eof() ) .And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE ) == xFilial( "SD2" ) + SF2->F2_DOC + SF2->F2_SERIE
		DbSelectArea( "SC6" )
		SC6->( DbSetOrder( 12 ) ) //C6_FILIAL+C6_PVAGLUT+C6_ITAGLUT
		SC6->( DbSeek( xFilial( "SC6" ) + SD2->D2_PEDIDO ) )
		While SC6->( !Eof() ) .And. SC6->( C6_FILIAL + C6_PVAGLUT ) == xFilial( "SC6" ) + SD2->D2_PEDIDO
			If !Empty( SC6->C6_NOTA )
				If !( SC6->C6_NUM $ cPedidos )
					cPedidos += SC6->C6_NUM + ";"
				EndIf

				lRet := .F.
				Exit
			EndIf

			SC6->( DbSkip() )
		End

		SD2->( DbSkip() )
	End

	If !lRet .And. !Empty( cPedidos )
		MsgStop( "A nota fiscal n�o pode ser exclu�da pois foram faturados os pedidos:" + CRLF + cPedidos )
	EndIf
EndIf

RestArea( aAreaSD2 )
RestArea( aAreaSF2 )

//Valida��o para n�o permitir a exclus�o da nota, se a nota j� foi despachada - WMS.
	If ! Empty(SF2->F2_ZDTDESP)

		FWAlertError("Nota j� despachada pelo WMS", "Cancelamento n�o autorizado")

		lRet := .F.
	Endif
//
// (ZZ2) - Customiza��o para permitir ou n�o a exclus�o de NFe de Venda com NFe de remessa emitida.
// 28/07/2021
// Retirado ap�s solucionar probema na ordem de emissao das NF de Venda e SR
/*/
If lRet .And. (cEmpAnt == "01" .Or. cEmpAnt == "03")
    If SF2->F2_TIPO == "N"
	    dbSelectArea("ZZ2")
		dbSetOrder(3)              // ZZ2_FILIAL+ZZ2_NFVEN
		If MsSeek(xFilial("ZZ2")+SF2->F2_SERIE+"/"+SF2->F2_DOC)
		    If !Empty(ZZ2->ZZ2_NFSR)
			    Alert("Exclus�o N�o Permitida. Exclua a NF de Simples Remessa primeiro: "+ZZ2->ZZ2_NFSR)
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
/*/
//
RestArea( aArea )
Return lRet
