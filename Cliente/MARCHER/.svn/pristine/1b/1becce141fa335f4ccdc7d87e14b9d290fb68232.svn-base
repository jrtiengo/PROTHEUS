//#Include 'Protheus.ch'


/*/{Protheus.doc} MTA240MNU
(long_description)
@type function
@author Marcio Borges
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MTA240MNU()

	Local cUsrPermitidos :=  SuperGetMV( "MA_ESTUSRM",, "000008/000081/000067/000050" ) // Usuarios permitidos movimentar estoque
	Local cRot_BLQMT240  :=  SuperGetMV( "MA_BQMT240",, "A240Inclui/A240Estorn" ) // Rotinas Bloqueadas do Menu para rotinas MATA240
	Local cCodUsr  :=  RetCodUsr ( )
	Local X_ROTINA := 2
	Local nTam
	
	
	If !(cCodUsr $ cUsrPermitidos)
		// Retira do array rotinas
		nTam := LEN(aRotina)
		x:= 1
		While  x <=  nTam
			If aRotina [x][X_ROTINA]  $ cRot_BLQMT240  // Busca Rotinas para retirar do menu  //aScan(aRotina, {|x| AllTrim( X[X_ROTINA] ) == "A240Inclui" } )
				//Diminui o tamanho do array
				ADEL(aRotina, x)
				nTam-- 	
				ASIZE(aRotina,nTam)
				//Ao deletar a posição do array diminui a posição para manter a mesma
				//para próxima operação
				x--
			Endif
			x++
		Enddo
	Endif
	
Return()

