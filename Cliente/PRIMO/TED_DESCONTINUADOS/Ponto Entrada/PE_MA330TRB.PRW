#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MA330TRB
Ajusta a Ordenação do Arquivo de Trabalho (TRB) no recálculo do Custo Médio ANTES DO PROCESSAMENTO FINAL
@type function
@version  1.0
@author Márcio.Borges
@since 10/03/2021
/*/
User Function MA330TRB()

	Local nTotRec   := 0
	Local nAtuRec   := 0
	//Local nRecno    := 0
	Local aArea     := GetArea()
	Local aAreaSd3  := SD3->(GetArea('SD3'))




	//MsgAlert("Entrou ma330trb","Atenção")
	// ORDENA SEQUENCIA DE CÁLCULO 300 DO CUSTO MÉDIO (MATA330)
	//Caso queira desativar a rotina, crie o parâmetro com conteúdo .F.
	If !GetMv( "ES_SEQ300" , .T., .T. )
		RestArea(aArea)
		RestArea(aAreaSd3)
		Return()
	Else

		dbSelectArea('TRB')
		nTotRec:=LastRec()
		dbSelectArea('TRB')
		Procregua(nTotRec)
		dbGoTop()

		//cRetFName := RetFullName('TRB')
		//cRetSQLName := RetSqlName('TRB')

		//MsgAlert(cRetFName,"Teste")
		//MsgAlert(cRetSQLName,"Teste")

		While TRB->(!Eof())

			//Regras:
			// 1 - Altera Ordem DE6,RE6,DE4 --> 297 --> nivel 1
			// 2 - Altera ordem RE7 --> 298 -->
			// 3 - Altera ordem DE7 --> 299
			// 4 - Altera ordem RE4, se for transf de mesmo produto, mesmo armazém e mesma filial -> nivel 1
			//	4.1  - Outros Tipos de RE4 --> nivel zz
			// 5 - Se não for op:
			//	5.1 -  CF DE% --> nivel 4
			//	5.2 - demais CF´s --> nivel zz

			// X - Todos os demais itens mantém a ordenação padrão

			IncProc('PE_MA330TRB - Ajustando Sequencia: '+StrZero(nAtuRec,6)+' de '+StrZero(nTotRec,6))



			If TRB->TRB_ORDEM == "300"

				RecLock('TRB',.F.)

				IF ALLTRIM(TRB->TRB_SEQ) $ '99CKCD/99D7D4/99CMEQ'  .AND.   ALLTRIM(TRB->TRB_COD) == '090105130EX' .AND. TRB->TRB_LOCAL  == '22'
					LACHOU := .T.
				ENDIF

				// regra 1
				If AllTrim(TRB->TRB_CF) $ 'DE6/RE6/DE4'
					//TRB->TRB_SEQPRO := "297"
					//TRB->TRB_ORDEM 	:= "297"
					TRB->TRB_NIVEL := '1'

					// regra 2 e 3
				ElseIf AllTrim(TRB->TRB_CF) $ 'RE4' //Requisição de uma devolução de mesmo produto e mesmo armazém
					cSql := "SELECT  '1' AS ACHOU   FROM " + RetSqlName("SD3") + " WHERE D3_FILIAL = '" + TRB->TRB_FILIAL + "' AND D3_CF = 'DE4' AND D3_COD = '" + TRB->TRB_COD + "' AND D3_LOCAL = '" + TRB->TRB_LOCAL + "' AND  D3_NUMSEQ = '" + TRB->TRB_SEQ + "' AND  D_E_L_E_T_  <> '*' "
					MPSysOpenQuery( cSql, 'QRYTMP' )

					IF QRYTMP->(!EOF())
						//TRB->TRB_SEQPRO := "297"
						//TRB->TRB_ORDEM 	:= "297"
						TRB->TRB_NIVEL := '1'
					Else
						//TRB->TRB_SEQPRO := TRB->TRB_ORDEM
						TRB->TRB_NIVEL := 'zz' //TRB->TRB_NIVSD3
					Endif
				
				ElseIf EMPTY(TRB->TRB_OP)
					If SUBSTR(TRB->TRB_CF,1,2) == 'DE'
						TRB->TRB_NIVEL := '4'
					Else
						TRB->TRB_NIVEL := 'zz'
					Endif 
				Endif

				/*
				
				ElseIF EMPTY(TRB->TRB_OP) 
					//mantem a sequencia do bloco para respeitar a ordenação padrão
					//nos demais itens
					//TRB->TRB_SEQPRO := TRB->TRB_ORDEM
					TRB->TRB_NIVEL := TRB->TRB_NIVSD3
				ElseIf SUBSTR(TRB->TRB_CF,1,2) == 'DE'//AllTrim(TRB->TRB_CF) $ 'DE0'
					TRB->TRB_NIVEL := '4'
					// Regra X
				Endif
				*/
			ENDIF
			TRB->(MsUnlock())

			TRB->(dbSkip())
		EndDo

	Endif
	dbSelectArea('TRB');dbGoTop()
	RestArea(aArea)
	RestArea(aAreaSd3)

	//Atualiza Estatísticas da Tabela Temporária

	_cSQL := "UPDATE STATISTICS dbo.TRB98SP WITH FULLSCAN;"

	If TcSQLExec(_cSQL) < 0

		cMsgErro := "Erro Statística TRB: "+ CRLF
		cMsgErro += "Erro retornado pelo Top Connect: " + TcSqlError()

		u_LogConsole("MA330TRB", cMsgErro)
		MemoWrite("MATA330-LOGERR STATISTICAS TRB98SP.LOG",cMsgErro)
	Endif
	_cSQL := "UPDATE STATISTICS dbo.TRX98SP WITH FULLSCAN;"
	If TcSQLExec(_cSQL) < 0

		cMsgErro := "Erro Statística TRX: "+ CRLF
		cMsgErro += "Erro retornado pelo Top Connect: " + TcSqlError()

		u_LogConsole("MA330TRB", cMsgErro)
		MemoWrite("MATA330-LOGERR STATISTICAS TRX98SP.LOG",cMsgErro)
	Endif


Return
