#Include "Protheus.ch"
#Include "topconn.ch"


/*/{Protheus.doc} SD3250E
 Executado na função A250DesAtu(), rotina responsável por estornar a atualização das tabelas de apontamentos de produção simples.
 DESCRIÇÃO Executado após atualização dos arquivos no processamento do estorno das atualizações. Eventos
@type function
@version  1
@author Márcio Borges
@since 19/07/2021
@return variant, Retorno Nulo
/*/
User Function SD3250E
	Local _aAreaCB0 := CB0->(GetArea())
	//Local _aRecords := ParamIXB
	Local cTRB	    := GetNextAlias() //Alias Tabela Temporária
	Local cSql      := ""

	//MsgAlert("Chamou PE SD325E", "Entrou")

	IF (!Empty(SH6->H6_XETIQ))
		cSql := " SELECT R_E_C_N_O_ NREG FROM " + RetSqlName("CB0") +" WHERE CB0_FILIAL = '" + XFilial("CB0") + "' AND D_E_L_E_T_ = ' ' AND CB0_CODETI = '" + SH6->H6_XETIQ + "' "
		MPSysOpenQuery( cSql, cTRB  )

		DBSelectArea("CB0")
		DBSetOrder(1)
		While (cTRB)->(!EOF())
			CB0->(MSGoto((cTRB)->NREG))
			IF CB0->(Recno()) == (cTRB)->NREG
				RECLOCK("CB0",.F.)
				CB0->(dbDelete())
				CB0->(MsUnlock())
			Else
				MsgAlert("SD3250E - Falha na exclusão de Etiqueta. Desposicionamento de registro. Etiqueta: " + SH6->H6_XETIQ, "Informe TI")
			Endif

			(cTRB)->(DBSkip())
		EndDo
	ENDIF


	RestArea(_aAreaCB0)
Return
