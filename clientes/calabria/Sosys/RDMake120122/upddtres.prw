#INCLUDE "PROTHEUS.CH"
#INCLUDE "UPDDTRES.CH"

/*/{Protheus.doc} User Function upddtfer
atualiza os registros das tabelas SRR e SRD de verbas informadas no cálculo de Rescisão
@type User Function
@author Cícero Alves
@since 19/02/2020
@see https://tdn.totvs.com/x/U9wYI
/*/
User Function upddtres()
	
	Local aArea := GetArea()
	
	//"ATENÇÃO!" "Realize o backup da base antes de executar esse processo."
	//"Essa rotina atualiza registros nas tabelas SRR - Itens de Férias e Rescisão e SRD - Histórico de Movimentos."
	//"Executar Rotina" "Cancelar"
	If Aviso(STR0002, CRLF + STR0003 + CRLF + CRLF + ;
		STR0004 + CRLF, {STR0005, STR0006}, 2 ) == 1
		
		//"Essa rotina atualiza os registros das tabelas SRR e SRD de verbas informadas no cálculo de Rescisão que podem estar com o campo data de pagamento divergente do cabeçalho da rescisão, tabela SRG."
		// "Atualização data de pagamento"
		tNewProcess():New("upddtres", STR0007, {|oSelf| UpdDtPgRES(oSelf) }, STR0001)
		
	EndIf
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} UpdDtPgRES
Busca os resgistros divergentes nas tabelas SRD e SRR e altera o campo data de pagamento
@type  Static Function
@author Cícero Alves
@since 19/02/2020
@param oProcess, Objeto, Instância da classe TNewProcess
/*/
Static Function UpdDtPgRES(oProcess)
	
	Local cTabAlias := GetNextAlias()
	
	oProcess:SetRegua1(3)
	
	BEGINSQL ALIAS cTabAlias 
		
		COLUMN RG_DATAHOM AS DATE
		
		SELECT 
			SRG.RG_DATAHOM,
			SRR.R_E_C_N_O_ RECNO, 
			TAB = 'SRR' 
		FROM %Table:SRR% SRR
		INNER JOIN %Table:SRG% SRG 
			ON (SRG.RG_FILIAL  = SRR.RR_FILIAL AND 
				SRG.RG_MAT     = SRR.RR_MAT AND 
				SRG.RG_DTGERAR = SRR.RR_DATA AND 
				SRG.RG_PERIODO = SRR.RR_PERIODO)
		WHERE 
			SRG.RG_DATAHOM != SRR.RR_DATAPAG AND 
			SRR.RR_TIPO2 IN ('I', 'G') AND 
			SRR.%NotDel% AND SRG.%NotDel%
		
		UNION 
		
		SELECT
			SRG.RG_DATAHOM, 
			SRD.R_E_C_N_O_ RECNO, 
			TAB = 'SRD' 
		FROM %Table:SRD% SRD
		INNER JOIN %Table:SRG% SRG 
			ON (SRD.RD_FILIAL = SRG.RG_FILIAL AND 
				SRD.RD_MAT    = SRG.RG_MAT AND 
				SRD.RD_DATARQ = SRG.RG_PERIODO)
		INNER JOIN %Table:SRR% SRR 
			ON (SRD.RD_FILIAL  = SRR.RR_FILIAL AND
				SRD.RD_MAT     = SRR.RR_MAT AND 
				SRD.RD_PD      = SRR.RR_PD AND 
				SRG.RG_DTGERAR = SRR.RR_DATA AND
				SRR.RR_PERIODO = SRD.RD_DATARQ)
		WHERE 
			SRR.RR_TIPO2 IN ('I', 'G') AND 
			SRG.RG_DATAHOM != SRR.RR_DATAPAG AND 
			SRR.%NotDel% AND 
			SRG.%NotDel% AND 
			SRD.%NotDel%
		ORDER BY TAB
		
	ENDSQL
	
	oProcess:SetRegua2(Contar(cTabAlias,"!Eof()"))
	(cTabAlias)->(dbGoTop())
	
	// Altera os registros da SRD
	oProcess:IncRegua1("Atualizando tabela SRD")
	dbSelectArea("SRD")
	While (cTabAlias)->(!EoF() .And. TAB == "SRD")
		oProcess:IncRegua2("Atualizando Registro " + cValToChar((cTabAlias)->RECNO))
		SRD->(dbGoTo((cTabAlias)->RECNO))
		RecLock("SRD", .F.)
			SRD->RD_DATPGT := (cTabAlias)->RG_DATAHOM
		SRD->(MsUnLock())
		
		(cTabAlias)->(dbSkip())
	EndDo
	
	// Altera os registros da SRR
	oProcess:IncRegua1("Atualizando tabela SRR")
	dbSelectArea("SRR")
	While (cTabAlias)->(!EoF() .And. TAB == "SRR")
		oProcess:IncRegua2("Atualizando Registro " + cValToChar((cTabAlias)->RECNO))
		SRR->(dbGoTo((cTabAlias)->RECNO))
		RecLock("SRR", .F.)
			SRR->RR_DATAPAG := (cTabAlias)->RG_DATAHOM
		SRR->(MsUnLock())
		(cTabAlias)->(dbSkip())
	EndDo
	
	SRD->(dbCloseArea())
	SRR->(dbCloseArea())
	(cTabAlias)->(dbCloseArea())
	
Return 