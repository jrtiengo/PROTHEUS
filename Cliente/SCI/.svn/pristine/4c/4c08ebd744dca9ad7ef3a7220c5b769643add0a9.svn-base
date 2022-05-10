#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"


User Function SCIA110()

Processa( {|| sTransf() },"" )

return


Static Function sTransf()


Local   cMes        := SubStr( DtoS( ddatabase ), 5, 2 )
Local 	cAnoFim     := SubStr( DtoS(     YearSum( ddatabase , 1 )       ), 1, 4 )//adicinando mais um exercicio para determinar longo
Local 	sHist:=''
Local 	cMeg :=''
Local   cFech:= GetMv("ES_CURLON")
Private lMsErroAuto := .F.


If Alltrim(cFech)<>""
	
	If Val(cFech)>= Val(cAnoFim)
		
		Alert("Esta rotina ja foi executada para o exercicio de "+cFech+".  Confira o parametro ES_CURLON.")
		Return
	Endif
	
Endif

IF cMes<>"01"
	Alert("Para que a rotina seja executada sera preciso alterar a data base para o primeiro dia do exercicio atual.")
	Return
END

cMsg:="Esta rotina ira alterar as naturezas" + Chr(13) + Chr(10)
cMsg+="dos titulos de longo prazo para curto "+ Chr(13) + Chr(10)
cMsg+="prazo de acordo com o exercicio." + Chr(13) + Chr(10)
cMsg+="Deseja executar essa rotina?"

If ApMsgNoYes(cMsg, "Transferecia de Exercicio")
	
	/*
	- Todos os contratos com titulos no financeiro
	*/
	
	cQuery := "  SELECT E2_MDCONTR "
	cQuery += "  FROM "+RetSqlName('SE2')+" SE2 "
	cQuery += "  INNER JOIN SED010 SED ON ( SE2.E2_NATUREZ=SED.ED_CODIGO) "
	cQuery += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
	cQuery += "   AND SED.D_E_L_E_T_<>'*' "
	cQuery += "   AND SE2.D_E_L_E_T_<>'*' "
	cQuery += "   AND SE2.E2_TIPO='PR' "
	//cQuery += "   AND SE2.E2_MDCONTR IN ('195/FUT/15')"
	cQuery += "   AND YEAR(SE2.E2_VENCTO)='"+cAnoFim+"'"
	cQuery += "   AND SED.ED_NATCLP='L' "
	cQuery += "   GROUP BY E2_MDCONTR "
	cQuery += "   ORDER BY E2_MDCONTR "
	
	MEMOWRIT('SCIA110_1.SQL', cQuery)
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE2",.F.,.T.)
	DbSelectArea("TSE2")
	
	
	/*
	-----------------------------------------------------------------
	*/
	
	
	ProcRegua(TSE2->(RECCOUNT()))
	dbGoTop()
	While TSE2->(!EOF())
		IncProc("Transferindo Titulos do Contrato: "+TSE2->E2_MDCONTR)
		sHist:=''
		cCTACCP:=''
		cCTACLP:=''
		cNATUREZ:=''
		
		cCTACCP	:=""
		cCTACLP	:=""
		cNATUREZ:=""
		
		
		/*
		- Total dos titulos longo prazo no exercicio por contrato
	    */
	    
		nSaldo:=0.00
		cQuery := " SELECT ISNULL(SUM(E2_SALDO),0)SALDO "
		cQuery += "  FROM "+RetSqlName('SE2')+" SE2 "
		cQuery += "  INNER JOIN SED010 SED ON ( SE2.E2_NATUREZ=SED.ED_CODIGO) "
		cQuery += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
		cQuery += "   AND SED.D_E_L_E_T_<>'*' "
		cQuery += "   AND SE2.D_E_L_E_T_<>'*' "
		cQuery += "   AND SE2.E2_TIPO='PR' "
		cQuery += "   AND YEAR(SE2.E2_VENCTO)='"+cAnoFim+"' "
		cQuery += "   AND SED.ED_NATCLP='L' "
		cQuery += "   AND SE2.E2_MDCONTR = '"+TSE2->E2_MDCONTR+"' "
		
		
		MEMOWRIT('SCIA110_2.SQL', cQuery)
		
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSAL",.F.,.T.)
		DbSelectArea("TSAL")
		
		nSaldo:=TSAL->SALDO
		TSAL->(dbCloseArea())
		
		
		IF  nSaldo>0
			
			cQuery := " UPDATE "+RetSqlName('SE2')
			cQuery += " SET E2_NATUREZ=SED.ED_NATCPLP "
			cQuery += "  FROM "+RetSqlName('SE2')+" SE2 "
			cQuery += "  INNER JOIN SED010 SED ON ( SE2.E2_NATUREZ=SED.ED_CODIGO) "
			cQuery += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
			cQuery += "   AND SED.D_E_L_E_T_<>'*' "
			cQuery += "   AND SE2.D_E_L_E_T_<>'*' "
			cQuery += "   AND SE2.E2_TIPO='PR' "
			cQuery += "   AND YEAR(SE2.E2_VENCTO)='"+cAnoFim+"' "
			cQuery += "   AND SED.ED_NATCLP='L' "
			cQuery += "   AND SE2.E2_MDCONTR = '"+TSE2->E2_MDCONTR+"' "
			
			nRet:=TcSqlExec(cQuery)
			If nRet<>0
				Alert(TCSQLERROR())
			End
			
		END
		
		
		
		TSE2->(dbSkip())
		
		
		
	EndDo
	PUTMV("ES_CURLON",cAnoFim)
	
	Alert('Transferencia concluida com sucesso!')
	
	TSE2->(dbCloseArea())
	
Endif
/*
-----------------------------------------------------------------
*/

RETURN NIL



