#INCLUDE "PROTHEUS.CH"

User Function LDTOCB( cCodBar )

	Local cCod  := AllTrim( cCodBar )
	Local _lRet := VldCodBar( cCod ) // Validação padrão do sistema
	Local _cCod := ""
	
	If _lRet
		
		// Ajuste caso a linha digitável tenha menos de 44 caracteres (completa com zeros)
		If Len( cCod ) < 44
			cCod := Left( cCod + Replicate( "0", 48 - Len( cCod ) ), 47 )
		Endif

 		If Len( cCod ) == 44 // Informado código de barras
 		
			M->E2_CODBAR := cCod

		ElseIf Len( cCod ) == 47 // Informada linha digitável

			_cCod += SubStr( cCod, 01, 03 ) // Identificação do Banco
			_cCod += SubStr( cCod, 04, 01 ) // Moeda
			_cCod += SubStr( cCod, 33, 01 ) // DV do CB
			_cCod += SubStr( cCod, 34, 04 ) // Fator de Vencimento
			_cCod += SubStr( cCod, 38, 10 ) // Valor do título
			_cCod += SubStr( cCod, 05, 05 ) // Campo livre 1
			_cCod += SubStr( cCod, 11, 10 ) // Campo livre 2
			_cCod += SubStr( cCod, 22, 10 ) // Campo livre 3
			
			M->E2_CODBAR := _cCod

		ElseIf Len( cCod ) == 48 // Informada linha digitável de concessionária

			_cCod := Left( cCod, 11 ) + SubStr( cCod, 13, 11 ) + SubStr( cCod, 25, 11 ) + SubStr( cCod, 37, 11 )

			M->E2_CODBAR := _cCod
		
		EndIf
		
	EndIf

Return( _lRet )