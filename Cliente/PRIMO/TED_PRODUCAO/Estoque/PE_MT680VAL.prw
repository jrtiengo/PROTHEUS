#Include "Protheus.ch"
#Include "topconn.ch"


/*/{Protheus.doc} MT680VAL
//Ponto de entrada: É utilizado para validar a inclusão do apontamento das produções PCP.
@author Celso Renee
@since 18/01/2021
@version 1.0
@type function
/*/
User Function MT680VAL()

//Local _lRet     := .T.
	Local cMV_Etiq  := ""
	Local cMaquina  := ""
	Local cNovaETiq := ""
	Local aAreaCB0  := CB0->(GetArea())
	Local cTRB	     //Alias Tabela Temporária
    Local cEsRoTEtiq := SUPERGETMV("ES_ETIQROT",.f.,"01#02") //Roteiros considerados para geração de etiquetas

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + M->H6_PRODUTO)

	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSeek(xFilial("SB5") + M->H6_PRODUTO)
	if (Found() .and. SB5->B5_IMPETI = "1" .and. Empty(M->H6_XETIQ) .and. (SB1->B1_RASTRO == "N" .or. Empty(SB1->B1_RASTRO) ))

		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial("SC2") + M->H6_OP)
		if ( SC2->(Found()) .and. SC2->C2_ROTEIRO $ cEsRoTEtiq)
			cMaquina  := Right(Alltrim(M->H6_RECURSO),1)
			cMV_Etiq  := "ES_ETIQM0"+cMaquina

			//Valida a existência do Parâmetro para a maquina utilizada
			If !GetMV(cMV_Etiq,.T.) //Verifica a Existência do Parâmetro
				MsgAlert("Não foi cadastrado parâmetro para controle da numeração da etiqueta. Solicite para a TI o cadastramento do parâmetro " + cMV_Etiq + " com conteúdo de oito zeros: 00000000")
				Return .F.
			Endif

            //Inicializa o Parâmetro caso esteja vazio
            If Empty(GetMV(cMV_Etiq)) .OR. Len(AllTrim(GetMV(cMV_Etiq)))+2 < TAMSX3("CB0_CODETI")[1]
                PutMV(cMV_Etiq,"00000000")
            Endif 

			cNovaETiq := cMaquina +"-"+ Soma1(Alltrim(GetMV(cMV_Etiq)))
			DBSelectArea("CB0")
			DBSetOrder(1) //CB0_FILIAL + CB0_CODETI

			//Atualiza Parâmetro com o ultimo existente se Já existir
			If   CB0->(MsSeek(xFilial("CB0") + cNovaETiq)) 
				cTRB	    := GetNextAlias() //Alias Tabela Temporária
				cSql :=  "SELECT MAX(CB0_CODETI) ULTIMA_ETIQ FROM " + RetSqlName("CB0") + " WHERE CB0_FILIAL = '" + xFilial("CB0")+ "' AND CB0_CODETI LIKE '" + cMaquina + "-%' AND  LEN(CB0_CODETI) = " + ALLTRIM(STR(TAMSX3("CB0_CODETI")[1])) + " AND  D_E_L_E_T_  <> '*'"
				MPSysOpenQuery( cSql, cTRB  )
				If (cTRB)->(EOF())
					PutMV(cMV_Etiq,"00000000")
				else
					PutMV(cMV_Etiq, SUBSTR((cTRB)->ULTIMA_ETIQ,3,8))
				Endif
				cNovaETiq := cMaquina +"-"+ Soma1(Alltrim(GetMV(cMV_Etiq)))
				(cTRB)->(DBCloseArea())
			Endif

			M->H6_XETIQ := cNovaETiq
			PutMV(cMV_Etiq,Soma1(Alltrim(GetMV(cMV_Etiq))))
		endif

	endif

	RestArea(aAreaCB0)
Return(.T.)
