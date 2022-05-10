#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MARA110
Função que filtrará os movimentos da T4K e irá limpar eles, para que então chame a rotina padrão PCPA138.
@type function
@version 12.1.33
@author Jorge Alberto - Solutio
@since 17/03/2022
/*/
User function MARA110()

	Local nQtde   := 0
	Local cQuery  := ""
	Local cFilT4K := FWxFilial("T4K")

	If MsgYesNo("Deseja reprocessar lançamentos pendentes de PCP ?")
		
		cQuery := "SELECT COUNT(T4K_OP) AS NREGISTRO FROM " + RetSqlName("T4K") + " WHERE T4K_FILIAL = " + cFilT4K + " AND D_E_L_E_T_ = ' ' "		

		nQtde := MpSysExecScalar( cQuery, "NREGISTRO" )

		If nQtde > 0
			Processa( {|| u_fprocessa( nQtde ) }, "Lançamentos pendentes", "Processando aguarde...", .f.)
		Else
			MsgInfo("Não existem registros a serem reprocessados", "Registros Pendentes")
		EndIf
		
	EndIf

Return


/*/{Protheus.doc} fProcessa
Processar os movimentos
@type function
@version 12.1.33
@author Jorge Alberto - Solutio
@since 17/03/2022
@param nRegistros, numeric, Quantidade de registros a serem processados
/*/
User Function fProcessa(nRegistros)

	Local cFilT4K   := FWxFilial("T4K")
	Local cFilSC2   := FWxFilial("SC2")
	Local cAliOPPe  := ""
	Local cQuery    := ""

	procregua(nRegistros)

	dbSelectArea("T4K")
	dbSetOrder(1)

	dbSelectArea("SC2")
	dbSetOrder(1)

	cQuery := "SELECT T4K_OP, R_E_C_N_O_ AS RECT4K FROM " + RetSqlName("T4K") + " WHERE T4K_FILIAL = " + cFilT4K + " AND D_E_L_E_T_ = ' ' "
	
	cAliOPPe := MPSysOpenQuery( cQuery )

	While (cAliOPPe)->( .NOT. EOF() )

		Incproc( "Verificando OP " + (cAliOPPe)->T4K_OP )

		T4K->( DbGoTo( (cAliOPPe)->RECT4K ) )

		If SC2->( dbSeek( cFilSC2 + (cAliOPPe)->T4K_OP ) )

			// Com a OP encerrada, deleta o registro
			If .NOT. Empty( SC2->C2_DATRF )
				dbSelectArea("T4K")
				If Reclock("T4K",.F.)
					T4K->(dbDelete())
					T4K->(MsUnLock())
				EndIf
			EndIf
		Else
			// Não encontrou a OP, deleta o registro
			dbSelectArea("T4K")	
			If Reclock("T4K",.F.)
				T4K->(dbDelete())
				T4K->(MsUnLock())
			EndIf
		EndIf
		
		(cAliOPPe)->(dbSkip())
	EndDo
	(cAliOPPe)->( DbCloseArea() )

	// Chama a rotina padrão
	PCPA138()

Return
