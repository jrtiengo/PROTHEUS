#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"



User Function BACA001()
	Local cTRB	:= GetNextAlias() //Alias Tabela Temporária
	Local aSetField := {}
	Local aTamSX3
    Local cTabAux := "SG1XPAPELAO_B"

	DBSelectArea("SG1")
	DBSetOrder(1)

	aTamSX3 := TAMSX3("G1_QUANT")
	AADD(aSetField,{"G1_QUANT", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	aTamSX3 := TAMSX3("G1_PERDA")
	AADD(aSetField,{"G1_PERDA", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	aTamSX3 := TAMSX3("G1_INI")
	AADD(aSetField,{"G1_INI", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	aTamSX3 := TAMSX3("G1_FIM")
	AADD(aSetField,{"G1_FIM", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })


	cQuery :=  "SELECT G1_FILIAL, G1_COD, G1_COMP , G1_TRT , G1_QUANT, G1_PERDA, G1_INI, G1_FIM, G1_OBSERV , G1_FIXVAR , G1_NIVINV, G1_VLCOMPE, G1_USAALT FROM " + cTabAux
	MPSysOpenQuery( cQuery, cTRB, aSetField  )

	Do While (cTRB)->(!EOF())
		Reclock("SG1",.T.)
		SG1->G1_FILIAL  := (cTRB)->G1_FILIAL
		SG1->G1_COD     := (cTRB)->G1_COD
		SG1->G1_COMP    := (cTRB)->G1_COMP
		SG1->G1_TRT     := (cTRB)->G1_TRT
		SG1->G1_QUANT   := (cTRB)->G1_QUANT
		SG1->G1_PERDA   := (cTRB)->G1_PERDA
		SG1->G1_INI     := (cTRB)->G1_INI
		SG1->G1_FIM     := (cTRB)->G1_FIM
		SG1->G1_OBSERV  := (cTRB)->G1_OBSERV
		SG1->G1_FIXVAR  := (cTRB)->G1_FIXVAR
		SG1->G1_NIVINV  := (cTRB)->G1_NIVINV
		SG1->G1_VLCOMPE := (cTRB)->G1_VLCOMPE
		SG1->G1_USAALT  := (cTRB)->G1_USAALT
		MsUnlock()

		(cTRB)->(DBSKIP())
	Enddo


Return
