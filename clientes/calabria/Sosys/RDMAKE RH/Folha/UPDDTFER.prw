#INCLUDE "TOTVS.CH"
#INCLUDE "UPDDTFER.CH"

/*/{Protheus.doc} UPDDTFER
Programa para ajustar as datas de pagamentos das verbas de mês seguinte
@author  gabriel.almeida
@since   25/02/2018
@version 1.0
/*/
User Function UPDDTFER()
    Local aArea    := GetArea()

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
    Local cText1 := STR0001 //"Realize o backup da base antes de executar esse processo."
    Local cText2 := STR0002 //"Ferramenta para ajuste das datas de pagamento das verbas de mês seguinte na SRD."
    Local cText3 := STR0003 //"UPDDTFER - Atualizada data de pagamento de férias"
    Local ctext4 := STR0004 //"Ao final do processamento as datas de pagamento da SRD das verbas vindas das férias que transitaram para o mês seguinte estarão corrigidas."
    
	oWizard := APWizard():New( cText1, cText2, cText3, ctext4, {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )
	
	//Painel 2 - Execução do processo
	oWizard:NewPanel(	STR0005 ,; //"Realizando atualização da base..."
						STR0006 ,; //"Aguarde enquanto o processamento é executado."
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
	oProcess := MsNewProcess():New( {|lEnd| fUpdDtPgFer(oProcess) } , STR0007 , STR0007 ) //"Executando atualização das datas..."
	oProcess:Activate()
Return

/*/{Protheus.doc} fUpdDtPgFer
Função que executa o processo de atualização da base corrigindo as datas de pagamento das verbas de mês seguinte
@author  gabriel.almeida
@since   25/02/2018
@version 1.0
/*/
Static Function fUpdDtPgFer(lEnd)
	Local lBackup   := MsgYesNo(STR0008) //"O backup da base já foi realizado?"
    Local cAliasQry := GetNextAlias()
    Local cJoinSRV  := FWJoinFilial( "SRA", "SRV" )
    Local cJoinSRV2 := StrTran( cJoinSRV , "SRV."	, "SRVINT." )

    cJoinSRV  := "%" + cJoinSRV + "%"
    cJoinSRV2 := "%" + cJoinSRV2 + "%"

    If lBackup
        BeginSql Alias cAliasQry
        	column RH_DATAINI AS Date
        	column RH_DATAFIM AS Date
            SELECT DISTINCT
                SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRH.RH_PERIODO, SRH.RH_DTRECIB, SRH.RH_DATAINI, SRH.RH_DATAFIM, SRD.RD_PD,
                SRV.RV_DESC, SRV.RV_CODFOL, SRV.RV_CODMSEG, SRD.RD_DATPGT, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_SEQ, SRD.RD_CC,
                SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_ITEM, SRD.RD_CLVL, SRD.RD_PERIODO, SRD.RD_DTREF, SRD.RD_ROTEIR, SRH.RH_DABONPE,SRH.RH_ABOPEC
            FROM
                %Table:SRA% SRA
                INNER JOIN %Table:SRH% SRH ON SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT
                INNER JOIN %Table:SRD% SRD ON SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT 
                INNER JOIN %Table:SRV% SRV ON %Exp:cJoinSRV% AND SRV.RV_COD = SRD.RD_PD AND (RV_CODMSEG <> ' ' OR RV_CODFOL = '0164' ) 
                WHERE
                SRV.RV_CODFOL NOT IN ('0106','0107','0088','0090','0095','0094','0092','0090','1416','1417','0096','0098','0161','0841','0838')
                AND SRV.RV_REFFER = 'S'
                AND SRH.RH_DTRECIB <> SRD.RD_DATPGT
                AND SRA.%NotDel%
                AND SRH.%NotDel%
                AND SRD.%NotDel%
                AND SRV.%NotDel%
        EndSql

        If !(cAliasQry)->( EOF() )
            oProcess:SetRegua2(100)

            DbSelectArea("SRD")
            SRD->(DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+DTOS(RD_DTREF)")))
        EndIf

        While !(cAliasQry)->( EOF() )
            oProcess:IncRegua2()
            
            If SUBSTR(DTOS(If((cAliasQry)->RH_ABOPEC == "1",(cAliasQry)->RH_DATAINI - (cAliasQry)-> RH_DABONPE ,(cAliasQry)->RH_DATAINI )),1,6) = (cAliasQry)->RD_PERIODO .OR. ;
               SUBSTR(DTOS(If((cAliasQry)->RH_ABOPEC <> "1",(cAliasQry)->RH_DATAFIM + (cAliasQry)-> RH_DABONPE ,(cAliasQry)->RH_DATAFIM )),1,6) = (cAliasQry)->RD_PERIODO
           
	            If SRD->( DbSeek( (cAliasQry)->(RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+RD_DTREF) ) )
	                RecLock("SRD",.F.)
	                    SRD->RD_DATPGT := SToD( (cAliasQry)->RH_DTRECIB )
	                SRD->( MsUnlock() )
	            EndIf
	         
	         EndIf
	         (cAliasQry)->(DbSkip())
	         
        EndDo

        (cAliasQry)->(DbCloseArea())
    Else
        MsgInfo(STR0009) //"Realize o backup e execute a rotina novamente."
    EndIf
Return