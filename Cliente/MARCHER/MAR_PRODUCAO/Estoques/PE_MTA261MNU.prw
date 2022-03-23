//#Include 'Protheus.ch'

/*/{Protheus.doc} MTA240MNU
(long_description)
@type function
@author mimra
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MTA261MNU()


	Local cUsrPermitidos :=  SuperGetMV( "MA_ESTUSRT",, "000045/000071/000088/000056/000064/000008/000050" ) // Usuarios permitidos transferir estoque
	Local cRot_BLQMT261		 :=  SuperGetMV( "MA_BQMT261",, "A261Inclui/A261Estorn" ) // Rotinas Bloqueadas do Menu
	Local cCodUsr  :=  RetCodUsr ( )
	Local X_ROTINA := 2
	Local nTam 
	
	
	If !(cCodUsr $ cUsrPermitidos)
		// Retira do array rotinas
		nTam := LEN(aRotina)
		x:= 1
		While  x <=  nTam
			If aRotina [x][X_ROTINA]  $ cRot_BLQMT261  // Busca Rotinas para retirar do menu  //aScan(aRotina, {|x| AllTrim( X[X_ROTINA] ) == "A240Inclui" } )
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

