#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

#INCLUDE "RWMAKE.CH"
#include "ap5mail.ch"


#define ENTER Chr(13)+Chr(10)

/*/{Protheus.doc} BACA003
Programa para adicionar MOD98 e MOD99 nas estururas de Canoas. Criar os empenhos das OP´s pendente e movimentos de consumo para ops já apontadas. 
@type function
@version 1.0
@author Márcio Borges
@since 05/02/2021
/*/
User Function BACA003()

	Local cLocProc  := GetMvNNR('MV_LOCPROC','99')
	Local cTRB	    := GetNextAlias() //Alias Tabela Temporária
	Local cTRBSC2   := GetNextAlias() //Alias Tabela Temporária
	Local cSql  := ""
	Local aSetField := {}
	Local x_filial := cFilant 






	DBSelectArea("SG1")
	DBSetOrder(1)

	aTamSX3 := TAMSX3("G1_COD")
	AADD(aSetField,{"G1_COD", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

	aTamSX3 := TAMSX3("G1_COMP")
	AADD(aSetField,{"G1_COMP", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })


	cFilAnt := '0102'


	cSql += "SELECT DISTINCT D3_COD G1_COD,'MOD98' G1_COMP FROM SD3980 WHERE D3_CF = 'PR0' AND D3_EMISSAO >=  '20210101' AND D_E_L_E_T_  <> '*' "
	cSql += "	AND NOT EXISTS (SELECT G1_COMP FROM SG1980 G1 WHERE G1.D_E_L_E_T_  <> '*' AND G1_FILIAL = D3_FILIAL AND G1_COD = D3_COD AND G1_COMP = 'MOD98' )"
	cSql += "	AND EXISTS (SELECT 1 FROM SB1980 WHERE B1_FILIAL = D3_FILIAL AND B1_COD = D3_COD AND SB1980.D_E_L_E_T_ <> '*' AND B1_GRUPO = '5620' and B1_TIPO = 'PA')"
	cSql += "	AND  EXISTS (SELECT G1_COMP FROM SG1980 G1 WHERE G1.D_E_L_E_T_  <> '*' AND G1_FILIAL = D3_FILIAL AND G1_COD = D3_COD  )"
	cSql += " UNION "
	cSql += " SELECT DISTINCT D3_COD G1_COD ,'MOD99' G1_COMP FROM SD3980 WHERE D3_CF = 'PR0' AND D3_EMISSAO LIKE '2020%' AND D_E_L_E_T_  <> '*'"
	cSql += "	AND NOT EXISTS (SELECT G1_COMP FROM SG1980 G1 WHERE G1.D_E_L_E_T_  <> '*' AND G1_FILIAL = D3_FILIAL AND G1_COD = D3_COD AND G1_COMP = 'MOD99' )"
	cSql += "	AND EXISTS (SELECT 1 FROM SB1980 WHERE B1_FILIAL = D3_FILIAL AND B1_COD = D3_COD AND SB1980.D_E_L_E_T_ <> '*' AND B1_GRUPO = '5600'  and B1_TIPO = 'PA')"
	cSql += "	AND  EXISTS (SELECT G1_COMP FROM SG1980 G1 WHERE G1.D_E_L_E_T_  <> '*' AND G1_FILIAL = D3_FILIAL AND G1_COD = D3_COD  )"


	MPSysOpenQuery( cSql, cTRB, aSetField  )

	Do While (cTRB)->(!EOF())

		
		RecLock("SG1",.T.)
		SG1->G1_FILIAL  := FWxFilial("SG1")
		SG1->G1_COD     := (cTRB)->G1_COD
		SG1->G1_COMP    := (cTRB)->G1_COMP
		SG1->G1_QUANT   := 1
		SG1->G1_INI     := STOD("20200101")
		SG1->G1_FIM     := STOD("20491231")
		SG1->G1_FIXVAR  := "V"
		SG1->G1_REVFIM  := "ZZZ"
		SG1->G1_NIV     := "01"
		SG1->G1_NIVINV  := "99"
		SG1->G1_VLCOMPE := 'N'
		SG1->G1_USAALT  := '1'
		MsUnLock()
		

		PUTMV("MV_NIVALT", "S")

		dbSelectArea('SB1')
		SB1->(dbSetOrder(1))
		SB1->(MSSeek(FWxFilial('SB1')+PADR((cTRB)->G1_COMP,TAMSX3("G1_COMP")[1])))

		cLocal := If(SB1->B1_APROPRI=="I",cLocProc,SB1->B1_LOCPAD)

		dbSelectArea('SB2')
		SB2->(dbSetOrder(1))
		if !SB2->(MSSeek(xFilial("SB2")+PADR((cTRB)->G1_COMP,TAMSX3("G1_COMP")[1])+cLocal))
			CriaSB2((cTRB)->G1_COMP,cLocal)
		Endif

		//Busca OP´s em Aberto

		cSql := "select SC2980.R_E_C_N_O_ NREG FROM SC2980 WHERE C2_FILIAL = '0102' AND D_E_L_E_T_  <> '*' AND C2_PRODUTO = '" + (cTRB)->G1_COD + "' AND C2_QUJE < C2_QUANT"
		MPSysOpenQuery( cSql, cTRBSC2  )



		Do While (cTRBSC2)->(!EOF())
			DbSelectArea('SC2')
			DBSetOrder(1)
			SC2->(DBGOTOP())
			SC2->(DBGOTO((cTRBSC2)->NREG))


			DbselectArea("SD4")
			DBsetOrder(2) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL

            //Cria empenho se não localizar registro
			If !SD4->(MSSeek(FWxFilial("SD4") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + PADR((cTRB)->G1_COMP,TAMSX3("G1_COMP")[1]) + cLocal ))
				RecLock("SD4",.T.)
				SD4->D4_FILIAL  := FWxFilial("SD4")
				SD4->D4_COD     := (cTRB)->G1_COMP
				SD4->D4_LOCAL   := cLocal
				SD4->D4_OP      := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
				SD4->D4_DATA    := SC2->C2_DATPRI
				SD4->D4_QTDEORI := SC2->C2_QUANT //QUANTIDADE DA OP
				SD4->D4_QUANT   := SC2->C2_QUANT - SC2->C2_QUJE  // QUANTIDADE QUE FALTA PRODUZIR E DEVE ESTAR EMPENHADA
				SD4->D4_PRODUTO := SC2->C2_PRODUTO
				SD4->D4_ROTEIRO := SC2->C2_ROTEIRO
				MsUnLock()
			Endif


			(cTRBSC2)->(DBSKIP())
		Enddo



		(cTRB)->(DBSKIP())


        //Para cada apontamento PR0, precisa existir um registro na SD3. (FEITO VIA SDU)



	Enddo

	cFilAnt := x_filial
return
