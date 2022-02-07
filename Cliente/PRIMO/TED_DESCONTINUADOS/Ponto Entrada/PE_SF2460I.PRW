#include "rwmake.ch"





/*/{Protheus.doc} SF2460I
Inclusão de dados Complementares na Emissão da Nota Fiscal de Faturamento
@type function
@version  
@author solutio
@since 31/03/2021
@return return_type, return_description
/*/
User Function SF2460I()

	Local _aArea	  := getarea()
	Local _aAreaSF2	  := SF2->(getarea())
	Local _aAreaSD2	  := SD2->(getarea())
	Local _aAreaSE1	  := SE1->(getarea())

	Local aTamSX3   := {}
	Local aSetField := {}

	Local  cTRB := GetNextAlias()
	Local lPESONFS := SuperGetMV("ES_PESONFS",.F.,.F.) //Ativa Funcionalidade de Peso Liq/Bruto na Filial

	Private _nPLiqui  := 0
	Private _nPBruto  := 0


	lPESONFS := .F. //Desativado customização especificamente neste PE.
	If lPESONFS

		aTamSX3 := TAMSX3("F2_PLIQUI")
		AADD(aSetField,{"PLIQUI", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

		aTamSX3 := TAMSX3("F2_PBRUTO")
		AADD(aSetField,{"PBRUTO", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

		//busca op em registros deletados do SC2
		cSql := "SELECT SUM (D2_PESO * D2_QUANT) as F2_PLIQUI ,SUM(D2_PBRUTO  * D2_QUANT) as F2_PBRUTO, "
		cSql += " SUM(C6_TPESO) PLIQPV, SUM(C6_TPBRUTO)  PBRUTOPV
		cSql += " FROM " + RetSqlName("SD2") + " SD2 "
		cSql += "  INNER JOIN " + RetSqlName("SC6") + " SC6
		cSql += "				ON SC6.D_E_L_E_T_  <> '*' "
		cSql += "				AND C6_FILIAL = '" + FWxFilial("SC6") + "'"
		cSql += "				AND C6_NUM = D2_PEDIDO
		cSql += "				AND C6_ITEM = D2_ITEMPV
		cSql += " WHERE D2_FILIAL = '" + FWxFilial("SD2") + "' AND D2_DOC  = '" + SF2->F2_DOC+ "' AND D2_SERIE = '" + SF2->F2_SERIE+ "' AND D2_CLIENTE = '" + SF2->F2_CLIENTE+ "' AND D2_LOJA = '" + SF2->F2_LOJA+ "'  AND SD2.D_E_L_E_T_  <> '*' "
		cSql += " GROUP BY D2_FILIAL, D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA"

		MPSysOpenQuery( cSql, cTRB,aSetField)

		IF (cTRB)->(!EOF())
			_nPLiqui := (cTRB)->PLIQPV
			_nPBruto := (cTRB)->PBRUTOPV
		Endif


		//AtuSF2() // Solicitado não atualizar mais o Cabeçalho da NF com Pesos


		(cTRB)->(DBCloseArea())
	Endif
	restarea(_aAreaSF2)
	restarea(_aAreaSD2)
	restarea(_aAreaSE1)
	restarea(_aArea)

Return(.T.)


Static Function AtuSF2()

	RecLock("SF2",.F.)
	If !Empty(_nPLiqui)
		SF2->F2_PLIQUI	:= _nPLiqui
	Endif
	If  !Empty(_nPBruto)
		SF2->F2_PBRUTO	:= _nPBruto
	Endif
	MsUnlock()

Return()
