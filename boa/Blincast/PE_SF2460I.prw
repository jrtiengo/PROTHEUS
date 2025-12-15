#include "protheus.ch"
#include "totvs.ch"

/*/{Protheus.doc} SF2460I
description localizado após a atualização das tabelas referentes à nota fiscal (SF2/SD2). 
O Ponto de entrada é executado após a exibição da tela de contabilização On-Line, mas antes da contabilização oficial.
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@param oSelf, object, param_description
@param lSchedule, logical, param_description
@param nRecno, numeric, param_description
@return variant, return_description
/*/

User Function SF2460I()

	Local aArea	    := FWGetArea()
	Local aAreaSE1  := SE1->(FWGetArea())
	Local aAreaSF2	:= SF2->(FWGetArea())
	Local aAreaSD2	:= SD2->(FWGetArea())
	Local aAreaCND	:= CND->(FWGetArea())
	Local aAreaSC5  := SC5->(FWGetArea())
	Local cNRental := ""

	If ! Empty(SC5->C5_XRENTA)

		cNRental := SC5->C5_XRENTA

		SE1->(DBSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

		If SE1->(MSSeek(FWxFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC)))

			While !SE1->(Eof()) .And. ;
					FWxFilial("SE1") == SE1->E1_FILIAL .And. ;
					SF2->F2_CLIENTE == SE1->E1_CLIENTE .And. ;
					SF2->F2_LOJA == SE1->E1_LOJA .And. ;
					SF2->F2_SERIE == SE1->E1_PREFIXO .And. ;
					SF2->F2_DOC == SE1->E1_NUM

				Reclock("SE1", .F.)
				SE1->E1_XRENTA := cNRental
				SE1->(MsUnlock())

				SE1->(DbSkip())
			EndDo
		Endif
		
		//Posiciona na tabela de locacao x projetos, volto o campo para STATUS nao faturado.
		FPA->(DbSetOrder(1))// FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
		If FPA->(MSSeek(FWxFilial("FPA")+ cNRental))
			While ! FPA->(Eof()) .And. FWxFilial("FPA") == SC5->C5_FILIAL .And. FPA->FPA_PROJET == cNRental
				If FPA->FPA_XREPAS == '1'
					FPA->(RecLock("FPA", .F.))
					FPA->FPA_XSTSRE := '0' // NAO FATURADO
					FPA->(MsUnlock())
				Endif
				FPA->(DbSkip())
			Enddo
		EndIf
	Endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaCND)
	RestArea(aAreaSC5)

Return()
