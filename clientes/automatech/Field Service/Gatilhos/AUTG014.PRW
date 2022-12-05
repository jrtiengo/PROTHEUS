#Include "Protheus.ch"
#Include "TOTVS.ch"

/*/{Protheus.doc} AUTG014

@author Lucas Moresco
@since 30/06/2014
@version 1.0
/*/
User Function AUTG014()

Local cQry       := ""
Local aArea      := GetArea()
Local aAreaABB   := GetArea("ABB")
Local cTecnico   := M->AB6_RLAUDO
Local lTemAgenda := .F.
Local lContinua  := .T.

	// Não permite a alteracao de tecnico quando existe requisicao de peça.
	If (Altera)
	
		If Select("TECA450ZZZ") > 0
			TECA450ZZZ->(dbCloseArea())
		EndIf
	
		cQry := "Select Top(1) ZZZ_NUMOS From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
		cQry += "Where ZZZ.ZZZ_NUMOS = '"+AB6->AB6_NUMOS+"' And "+chr(13)
		cQry += "ZZZ.ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "+chr(13)
		cQry += "ZZZ.D_E_L_E_T_ <> '*' "+chr(13)
		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TECA450ZZZ", .T., .T. )
	
		TECA450ZZZ->( DbGoTop() )
	
		While ! Eof()
			MsgAlert("Atenção! Não é possível realizar a troca do técnico, existe req. de peça aberta. Exclua os apontamentos antes.")	
			cTecnico  := AB6->AB6_RLAUDO
			lContinua := .F.
			DbSkip()
		EndDo
		
		TECA450ZZZ->(dbCloseArea())	
	
	
		//Verifica se existe agendamento para este técnico, se sim, não permite a troca, se não, permite criar o agendamento.
	
		
		If (lContinua)	
		
			If Select("TECA450ABB") > 0
				TECA450ABB->(dbCloseArea())
			EndIf
	
			cQry := "Select Top(1) ABB_NUMOS From "+RetSqlName("ABB")+" ABB(NoLock) "+chr(13)
			cQry += "Where ABB.ABB_NUMOS = '"+AB6->AB6_NUMOS+"' And ABB.ABB_CODTEC = '"+AB6->AB6_RLAUDO+"' And "+chr(13)
			cQry += "ABB.ABB_FILIAL = '"+xFilial("ABB")+"' And "+chr(13)
			cQry += "ABB.D_E_L_E_T_ <> '*' "+chr(13)
			cQry := ChangeQuery(cQry)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TECA450ABB", .T., .T. )
		
			TECA450ABB->( DbGoTop() )
		
			While ! Eof()
				If (MsgYesNo("Atenção! O técnico já possui agenda para esta O.S., deseja excluir as agendas?"))
				
					cQry := "Update "+RetSqlName("ABB")+" Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_, ABB_OBSERV = 'REM MANUAL "+UsrRetName(RetCodUsr())+"'"+chr(13)
					cQry += "Where ABB_NUMOS = '"+AB6->AB6_NUMOS+"' And ABB_CODTEC = '"+AB6->AB6_RLAUDO+"' And "+chr(13)
					cQry += "ABB_FILIAL = '"+xFilial("ABB")+"' And "+chr(13)
					cQry += "D_E_L_E_T_ <> '*' "+chr(13)
		
					If TcSqlExec(cQry) < 0
						UserException("Erro na exclusao dos itens da tabela ABB (Agendamentos)")
						cTecnico  := AB6->AB6_RLAUDO
					Else
						MsgAlert("Agendas Excluídas com sucesso.")
					EndIf
				
				Else
					cTecnico := AB6->AB6_RLAUDO
					Exit
					lTemAgenda := .T.
				EndIf	
				
				DbSkip()
			EndDo
			
			TECA450ABB->(dbCloseArea())	
			
			If (! ltemAgenda)
	
				If Select("TECA4502ABB") > 0
					TECA4502ABB->(dbCloseArea())
				EndIf
		
				cQry := "Select Top(1) ABB_NUMOS From "+RetSqlName("ABB")+" ABB(NoLock) "+chr(13)
				cQry += "Where ABB.ABB_NUMOS = '"+AB6->AB6_NUMOS+"' And ABB.ABB_CODTEC = '"+M->AB6_RLAUDO+"' And "+chr(13)
				cQry += "ABB.ABB_FILIAL = '"+xFilial("ABB")+"' And "+chr(13)
				cQry += "ABB.D_E_L_E_T_ <> '*' "+chr(13)
				cQry := ChangeQuery(cQry)
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TECA4502ABB", .T., .T. )
			
				TECA4502ABB->( DbGoTop() )
				
				While ! Eof()
					MsgAlert("Atenção! o novo técnico já possui agenda marcada para esta O.S.")
					ltemAgenda := .T.
					DbSkip()
				EndDo
				
				TECA4502ABB->(dbCloseArea())	
	
				If (! ltemAgenda)
					If (MsgYesNo("Atençao! Técnico não alocado para esta O.S., deseja efetuar a alocação?"))
						
						RecLock("ABB",.T.)
							ABB->ABB_FILIAL := xFilial("ABB")
							ABB->ABB_CODTEC := M->AB6_RLAUDO 
							ABB->ABB_NUMOS  := AB6->AB6_NUMOS 
							ABB->ABB_DTINI  := dDataBase
							ABB->ABB_HRINI  := Time()
							ABB->ABB_DTFIM  := dDataBase
							ABB->ABB_HRFIM  := Time()
							ABB->ABB_OBSERV := "TROCA MANUAL POR "+UsrRetName(RetCodUsr())+" "
							ABB->ABB_SACRA  := "S"
						MsUnlock()
					
						MsgAlert("Alocação realizada com sucesso!")
						
					EndIf
				EndIf
			EndIf
		
		EndIf
	
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaABB)

Return(cTecnico)