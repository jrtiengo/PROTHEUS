#INCLUDE "PROTHEUS.CH"
/*/-----------------------------------------------------------------------------------/
{Protheus.doc} MTA103OK
Este P.E. é chamado na função A103LinOk()
Pode ser usado para validar a inclusao da NF: Executada ao sair da linha de registri  - item a item .
@obs Programa Fonte: MATA103.PRW
@type  Function
@author Jean Rehermann - Solutio IT
@since 28/09/2021
@return logical, lRet - (LÓGICO) .T. se todas as validações OK ou .F. se houver problema
/-----------------------------------------------------------------------------------/*/
User Function MTA103OK()

	Local lRet   := ParamIxb[1]
	Local nPCCt  := aScan( aHeader, {|o| AllTrim( o[2] ) == "D1_CONTA"   } )
	Local nPItC  := aScan( aHeader, {|o| AllTrim( o[2] ) == "D1_ITEMCTA" } )
	Local nPTes  := aScan( aHeader, {|o| AllTrim( o[2] ) == "D1_TES"     } )
	Local nPPed  := aScan( aHeader, {|o| AllTrim( o[2] ) == "D1_PEDIDO"  } )
	Local cConta := ""
	Local cItCta := ""
	Local cTes   := ""
	Local cPedido:= ""
	
	Local aArea  := SF4->( GetArea() )

	//Validação é executada Item-aItem 
	If lRet .AND. !GDDeleted(n) .And. nPCCt > 0 .And. nPTes > 0 .And. nPItC > 0


			cConta := AllTrim( aCols[ n, nPCCt ] )
			cTes   := AllTrim( aCols[ n, nPTes ] )
			cItCta := AllTrim( aCols[ n, nPItC ] )
		/*
		// # http://portfolio.solutio.inf.br/issues/30705 - Comentado bloco de Código pois impleemntaçaõ não foi validada. 
			If cConta == "12030302" .Or. SubString( cItCta, 4, 3 ) == "999"

				If cFilAnt == "0101"

					lRet := cTes $ "017/031"

				ElseIf cFilAnt == "0102"

					lRet := cTes $ "017/030/031/141/142/143"

				EndIf

			EndIf

			If !lRet
				If !IsBlind() //!( Type('l103Auto') <> 'U' .And. l103Auto )
					MsgAlert("Validação TES x Conta contábil x Item conta incorreta no item "+ cValToChar( nX ) )
				EndIf
			EndIf
		*/

			// Validar se TES gera Duplicata, então o item tem que ter PC - Solutio #30996
			IF  !(cTipo $ 'D') .AND.  lRet .And. nPPed > 0 .And. !(cTes $ SUPERGETMV("ES_EXTESPD",.F.,"193"))

				cPedido := AllTrim( aCols[ n, nPPed ] )

				dbSelectArea("SF4")
				dbSetOrder(1)
				SF4->(dbSeek( xFilial("SF4") + cTes ))

				If Empty( cPedido ) .AND. SF4->F4_DUPLIC == "S"

					If !IsBlind() //!( Type('l103Auto') <> 'U' .And. l103Auto )
						MsgAlert("Item sem pedido e com TES que gera financeiro no item "+ cValToChar( n ) )
					EndIf
					lRet := .F.
				EndIf
			EndIf


	EndIf
	RestArea( aArea )

Return( lRet )
