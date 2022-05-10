#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050ALT       ºAutor  ³Marllon Figueiredo       11/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Permite validar a alteracao do titulo a pagar                     ±±
±±º                                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FA050ALT()
Local aArea       := GetArea()
Local aAreaCT1    := CT1->( GetArea() )
Local aAreaSED    := SED->( GetArea() )
Local lReturn     := .t.
Local cE2_Naturez := M->E2_NATUREZ
Local cE2_ccd     := M->E2_CCCTB





// REMOVIDO PARA ANALISE POSTERIOR - MIGRACAO P11

Return( lReturn )

//


// posiciona na natureza para pegar a conta contabil
SED->( dbSetOrder(1) )
If SED->( dbSeek(xFilial('SED')+cE2_Naturez) )
	
	// posiciona no CT1 para verificar obrigatoriedades
	CT1->( dbSetOrder(1) )
	If CT1->( dbSeek(xFilial('CT1')+SED->ED_CONTA) )
		
		If CT1->CT1_CCOBRG == '1' .and. Empty(cE2_ccd)
			
			Alert("Obrigatório informar o Centro de Custo!")
			lReturn := .f.
			
		EndIf
		
		// CC nao obrig. e nao aceita e o usuario preencheu, nao deixo!
		If CT1->CT1_CCOBRG <> '1' .and. CT1->CT1_ACCUST == '2' .and. ! Empty(cE2_ccd)

	    	Alert("Centro de Custo não é aceito neste lançamento!")
			lReturn := .f.

		EndIf
		
	EndIf
EndIf

// reposiciona alias
RestArea(aAreaSED)
RestArea(aAreaCT1)
RestArea(aArea)

Return( lReturn )
