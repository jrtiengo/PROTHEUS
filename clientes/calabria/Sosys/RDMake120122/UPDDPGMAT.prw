#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} UPDDPGMAT
Programa para ajustar o campo R8_DPAGOS que estão incorretos devido a erro no fechamento do periodo
@author  paulo.inzonha
@since   22/03/2019
@version 1.0
/*/
User Function UPDDPGMAT()
Local aArea    := GetArea()
Private aLog    := {}
Private aTitle  := {}

    fMontaWizard()
    RestArea(aArea)
Return

/*/{Protheus.doc} fMontaWizard
Função para montar a Wizard de execução
@author  gabriel.almeida
@since   25/02/2018
@version 1.0
/*/
Static Function fMontaWizard()
    Local cText1 := "Realize o backup da base antes de executar esse processo."
    Local cText2 := "Ferramenta para ajuste dos dias pagos na SR8 para comissionado puro em licença maternidade."
    Local cText3 := "UPDDPGMAT - Atualizar dias pagos empresa na ausência do funcionário comissionado puro em licença maternidade."
    Local ctext4 := " "
    
	oWizard := APWizard():New( cText1, cText2, cText3, ctext4, {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )
	
	//Painel 2 - Execução do processo
	oWizard:NewPanel(	"Realizando atualização da base..." ,; 
						"Aguarde enquanto o processamento é executado." ,; 
						{||.F.}                   ,; //<bBack>
						{||.F.}                   ,; //<bNext>
						{||.T.}                   ,; //<bFinish>
						.T.                       ,; //<.lPanel.>
						{| lEnd| fCallExec(@lEnd)}) //<bExecute>
	
	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
Return

/*/{Protheus.doc} fCallExec
Função para preparação e chamada da execução
@author  gabriel.almeida
@since   25/02/2018
@version 1.0
/*/
Static Function fCallExec(lEnd)
	Private oProcess
	
	// Executa o processamento de atualização das datas chamando a função fUpdDtPgFer
	oProcess := MsNewProcess():New( {|lEnd| fUpdDPgSR8(oProcess) } , "Executando atualização" , "Executando atualização" ) 
	oProcess:Activate()
	
Return

/*/{Protheus.doc} fUpdDtPgFer
Função que executa o processo de atualização da base corrigindo os dias pagos 
@author  paulo.inzonha
@since   22/03/2019
@version 1.0
/*/
Static Function fUpdDPgSR8(lEnd)
Local lBackup   := MsgYesNo("O backup da base já foi realizado?")
Local cAliasQry	:= GetNextAlias()
Local cAliasSRD
Local cPd407 	:= "" 
Local cPd040 	:= ""
Local cFilTmp	:= "!!"
Local aCodFol	:= {}
Local ndPagos	:= 0
Local aLog		:= {}

Aadd( aTitle, OemToAnsi( "Funcionários que tiveram afastamentos alterados:" ) )
Aadd( aLog, {} )
    
If lBackup
    Begin Transaction			
		BeginSql alias cAliasQry
			SELECT SR8.R8_FILIAL,SR8.R8_MAT, SR8.R_E_C_N_O_ AS RECNOSR8 , SR8.R8_DATAINI,SR8.R8_DATAFIM FROM %Table:SRA%  SRA
			INNER JOIN %Table:SR8%  SR8 ON SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT AND SR8.%NotDel%
			WHERE SRA.RA_CATFUNC = 'C'
			AND SRA.RA_SALARIO = 0
			AND SRA.%NotDel%
			AND SRA.RA_SITFOLH = 'A'
			AND SRA.RA_SEXO = 'F'
			AND SR8.R8_TIPOAFA IN ('006','008')
			AND SR8.R8_DPAGOS = SR8.R8_DPAGAR
			ORDER BY SR8.R8_FILIAL, SR8.R8_MAT
		EndSql
		If !(cAliasQry)->(Eof())
			While !(cAliasQry)->(Eof())
				cAliasSRD	:= GetNextAlias()
				ndPagos	:= 0
				If cFilTmp <> (cAliasQry)->R8_FILIAL
					FP_CODFOL(@aCodFol,(cAliasQry)->R8_FILIAL)
					cPd407 	:= fGetCodFol("0407") 
					cPd040 	:= fGetCodFol("0040")
				EndIf
				
				BeginSql alias cAliasSRD
					SELECT SUM(RD_HORAS) AS VALOR 
					FROM %Table:SRD% SRD
					WHERE SRD.RD_FILIAL=%exp:(cAliasQry)->R8_FILIAL%
					AND SRD.RD_MAT=%exp:(cAliasQry)->R8_MAT% 
					AND SRD.%NotDel%
					AND SRD.RD_PD IN(%exp:cPd407%,%exp:cPd040%)
					AND SRD.RD_PERIODO BETWEEN %exp:Substr((cAliasQry)->R8_DATAINI,1,6)% AND %exp:Substr((cAliasQry)->R8_DATAFIM,1,6)%
				EndSql
				If !(cAliasSRD)->(Eof())
					ndPagos	:= (cAliasSRD)->VALOR
					If ndPagos > 0
						SR8->(dbGoto((cAliasQry)->RECNOSR8))
						If Reclock("SR8",.F.)
							SR8->R8_DPAGOS 	:= ndPagos
							SR8->R8_SDPAGAR := SR8->R8_DPAGAR - ndPagos 
							SR8->(MsUnlock())
						EndIf
						
						aAdd( aLog[1], "Filial: " + (cAliasQry)->R8_FILIAL + "  -  Matrícula: " + (cAliasQry)->R8_MAT + " Periodo afastamento : " + dtoc(stod((cAliasQry)->R8_DATAINI)) + ' A ' +  dtoc(stod((cAliasQry)->R8_DATAFIM))) 
					EndIf
				EndIf
				(cAliasSRD)->(dbCloseArea())
				
				cFilTmp	:= (cAliasQry)->R8_FILIAL
				(cAliasQry)->(dbSkip())
			EndDo
			MsgInfo("Sistema atualizado")
			fMakeLog(aLog,aTitle,,,"UPDDPGMAT",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
		Else
			MsgInfo("Não há funcionarios para atualizar")
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	End Transaction
Else
    MsgInfo("Realize o backup e execute a rotina novamente.") 
EndIf
Return