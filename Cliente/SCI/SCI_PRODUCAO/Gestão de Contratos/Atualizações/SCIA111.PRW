#INCLUDE 'PROTHEUS.CH'





USER FUNCTION APRCNW()

Processa( {|| sTransf() },"" )

RETURN






Static Function sTransf()


Local   cMes        := SubStr( DtoS( ddatabase ), 5, 2 )
Local 	cAnoFim     := SubStr( DtoS(     YearSum( ddatabase , 1 )       ), 1, 4 )//adicinando mais um exercicio para determinar longo
Local 	sHist:=''
Local 	cMeg :=''

Private lMsErroAuto := .F.



IF cMes<>"01"
	Alert("Para que a rotina seja executada sera preciso alterar a data base para o primeiro dia do exercicio atual.")
	Return
END

cMsg:="Esta rotina ira alterar informacoes" + Chr(13) + Chr(10)
cMsg+="dos cronogramas contabeis de longo prazo "+ Chr(13) + Chr(10)
cMsg+="para curto prazo de acordo com o" + Chr(13) + Chr(10)
cMsg+="exercicio."+ Chr(13) + Chr(10)
cMsg+="Serao realizados os lancamentos cantabeis de"+ Chr(13) + Chr(10)
cMsg+="transferencia dos valores dos cronogramas alterados."+ Chr(13) + Chr(10)
cMsg+="Deseja executar essa rotina?"

If ApMsgNoYes(cMsg, "Transferecia de Exercicio")
	
	/*
	- Todos os contratos com titulos no financeiro
	*/
	
	cQuery := " SELECT CNW_CONTRA, CNW_REVISA,CNW_FGLPCP,CNW_FGEXER "
	cQuery += " FROM "+RetSqlName('CNW')+" CNW "
	cQuery += " INNER JOIN "+RetSqlName('CNV')+" CNV ON ( CNW.CNW_FILIAL=CNV.CNV_FILIAL AND CNW.CNW_CONTRA=CNV.CNV_CONTRA AND "
	cQuery += "		  									  CNW.CNW_REVISA=CNV.CNV_REVISA AND CNW.CNW_NUMERO=CNV.CNV_NUMERO AND "
	cQuery += "							   				  CNV.D_E_L_E_T_<>'*') "
	cQuery += "	INNER JOIN "+RetSqlName('CNB')+" CNB ON ( CNB.CNB_FILIAL=CNV.CNV_FILIAL AND CNB.CNB_CONTRA=CNV.CNV_CONTRA AND "
	cQuery += "							   				  CNB.CNB_REVISA=CNV.CNV_REVISA AND CNB.CNB_NUMERO=CNV.CNV_PLANIL AND "
	cQuery += "							   				  CNB.D_E_L_E_T_<>'*') "
	cQuery += "	INNER JOIN "+RetSqlName('CNA')+" CNA ON ( CNB.CNB_FILIAL=CNA.CNA_FILIAL AND CNB.CNB_CONTRA=CNA.CNA_CONTRA AND "
	cQuery += "							   				  CNB.CNB_REVISA=CNA.CNA_REVISA AND CNB.CNB_NUMERO=CNA.CNA_NUMERO AND "
	cQuery += "							   				  CNA.D_E_L_E_T_<>'*') "
	cQuery += " INNER JOIN "+RetSqlName('CN9')+" CN9 ON ( CN9.CN9_FILIAL=CNA.CNA_FILIAL AND CN9.CN9_NUMERO=CNA.CNA_CONTRA AND "
	cQuery += "							   				  CN9.CN9_REVISA=CNA.CNA_REVISA AND CN9.D_E_L_E_T_<>'*') "
	cQuery += " WHERE  "
	cQuery += "	CNW.CNW_FGLPCP='L' "
	cQuery += "	AND CNA.CNA_FORNEC<>'' "
	cQuery += "	AND CNW.CNW_FGEXER='' "
	cQuery += "	AND CN9.CN9_SITUAC='05' "
	cQuery += "	AND CNW.D_E_L_E_T_		 <>'*' "
	cQuery += "	GROUP BY CNW_CONTRA, CNW_REVISA,CNW_FGLPCP,CNW_FGEXER "
	
	MEMOWRIT('SCIA110_CNW_10.SQL', cQuery)
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TCNW",.F.,.T.) // TCNW
	DbSelectArea("TCNW")
	
	
	/*
	-----------------------------------------------------------------
	*/
	
	//	IF TCNW->(RECCOUNT())<=0
	//		Alert('Nao foram encontrados registros!')
	//		return
	//endif
	
	ProcRegua(TCNW->(RECCOUNT()))
	dbGoTop()
	While TCNW->(!EOF())
		IncProc("Transferindo registros do Contrato: "+TCNW->CNW_CONTRA)
		sHist:=''
		
		/*
		- Total dos titulos longo prazo no exercicio por contrato
		*/
		nSaldo:=0.00
		
		cQuery := " SELECT ISNULL(SUM(CNW_VLPREV),0) SALDO "
		cQuery += " FROM "+RetSqlName('CNW')+" CNW "
		cQuery += " WHERE  "
		cQuery += "	CNW.CNW_FGLPCP='L' "
		cQuery += "	AND CNW.CNW_FGEXER='' "
		cQuery += " AND YEAR(CNW.CNW_DTPREV) = '"+cAnoFim+"' "
		cQuery += " AND CNW.CNW_CONTRA = '"+TCNW->CNW_CONTRA+"' "
		cQuery += " AND CNW.CNW_REVISA = '"+TCNW->CNW_REVISA+"' "
		cQuery += "	AND CNW.D_E_L_E_T_		 <>'*' "
		
		MEMOWRIT('SCIA111_CNW_SALDO.SQL', cQuery)
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSAL",.F.,.T.)
		DbSelectArea("TSAL")
		
		nSaldo:=TSAL->SALDO
		TSAL->(dbCloseArea())
		
		
		IF  nSaldo>0
			
			cQuery := " UPDATE "+RetSqlName('CNW')
			cQuery += " SET CNW_FGEXER='"+cAnoFim+"', "
			cQuery += " CNW_FGLPCP='C' "
			cQuery += " FROM "+RetSqlName('CNW')+" CNW "
			cQuery += "	WHERE CNW.CNW_FGLPCP ='L' "
			cQuery += "	  AND CNW.CNW_FGEXER ='' "
			cQuery += "   AND YEAR(CNW.CNW_DTPREV) = '"+cAnoFim+"' "
			cQuery += "   AND CNW.CNW_CONTRA = '"+TCNW->CNW_CONTRA+"' "
			cQuery += "   AND CNW.CNW_REVISA = '"+TCNW->CNW_REVISA+"' "
			cQuery += "	  AND CNW.D_E_L_E_T_ <>'*' "
			
			nRet:=TcSqlExec(cQuery)
			If nRet<>0
				Alert(TCSQLERROR())
			Endif
			
		Endif
		
		cDocCt2 :=""
		c3Query := " SELECT ISNULL(MAX(CT2_DOC)+1,'1') PROXDOC "
		c3Query += " FROM  CT2010 "
		c3Query += " WHERE CT2_DATA = '" + Dtos(dDataBase) + "'"
		c3Query += " AND   CT2_LOTE = 'TEXEC' "
		c3Query += " AND   CT2_FILIAL = '" + xFilial("CT2") + "'"
		c3Query += " AND D_E_L_E_T_ <> '*' "
		c3Query := ChangeQuery(c3Query)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c3Query),"MAXCT2",.F.,.T.)
		DbSelectArea("MAXCT2")
		
		cDocCt2:=Strzero(MAXCT2->PROXDOC,6)
		MAXCT2->(dbCloseArea())
		
		
		
		
		cQueryA1 := "   SELECT A2_NOME "
		cQueryA1 += "   FROM "+RetSqlName('CNA')+" CNA "
		cQueryA1 += "   INNER JOIN "+RetSqlName('SA2')+" SA2  ON ( SA2.A2_COD=CNA.CNA_FORNEC AND SA2.A2_LOJA=CNA.CNA_LJFORN ) "
		cQueryA1 += "   WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
		cQueryA1 += "   AND SA2.D_E_L_E_T_<>'*' "
		cQueryA1 += "   AND CNA.D_E_L_E_T_<>'*' "
		cQueryA1 += "   AND CNA.CNA_CONTRA = '"+TCNW->CNW_CONTRA+"' "
		cQueryA1 += "   AND CNA.CNA_REVISA = '"+TCNW->CNW_REVISA+"' "
		
		MEMOWRIT('SCIA111_FORNECEDOR.SQL', cQueryA1)
		
		
		cQueryA1 := ChangeQuery(cQueryA1)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryA1),"TSA2",.F.,.T.)
		DbSelectArea("TSA2")
		
		sHist:="TRANSF. LP/CP CTR. N." +"  " +ALLTRIM(TCNW->CNW_CONTRA)+"  "+ALLTRIM(TSA2->A2_NOME)
		
		TSA2->(dbCloseArea())
		
		If nSaldo>0
			
			aCab   :={}
			aItens :={}
			
			//Inclusão de Lançamento Contábil Cabecalho
			aAdd(aCab,  {'DDATALANC'     ,dDataBase ,NIL} )
			aAdd(aCab,  {'CLOTE'         ,'APRCNW'   ,NIL} )
			aAdd(aCab,  {'CSUBLOTE'      ,'001'     ,NIL} )
			aAdd(aCab,  {'CDOC'          ,cDocCt2   ,NIL} )
			aAdd(aCab,  {'CPADRAO'       ,''        ,NIL} )
			aAdd(aCab,  {'NTOTINF'       ,0         ,NIL} )
			aAdd(aCab,  {'NTOTINFLOT'    ,0         ,NIL} )
			
			
			//Inclusão de Lançamento Contábil
			Aadd 	(aItens, {{'CT2_FILIAL'       ,'0101'      ,NIL},;
			{'CT2_LOTE'     ,'APRCNW'                           ,NIL},;
			{'CT2_SBLOTE'   ,'001'                             ,NIL},;
			{'CT2_DOC'      ,cDocCt2				  	       ,NIL},;
			{'CT2_DATA'     ,dDataBase                         ,NIL},;
			{'CT2_LINHA'    ,'001'                             ,NIL},;
			{'CT2_MOEDLC'   ,'01'                              ,NIL},;
			{'CT2_DC'       ,'3'                               ,NIL},;
			{'CT2_DEBITO'   ,'22040010020001'                  ,NIL},;
			{'CT2_CREDIT'   ,'21040010020001'                  ,NIL},;
			{'CT2_VALOR'    ,nSaldo	    		     		   ,NIL},;
			{'CT2_EMPORI'   ,'01'               			   ,NIL},;
			{'CT2_FILORI'   ,'0101'             			   ,NIL},;
			{'CT2_TPSALD'   ,'1'                			   ,NIL},;
			{'CT2_CCC'      ,''         	        		   ,NIL},;
			{'CT2_ORIGEM'   ,'GCT-LONGO-CURTO'        	       ,NIL},;
			{'CT2_HIST'     ,substr(sHist,1,40) 			   ,NIL},;
			{'CT2_CRCONV'   ,'1'   						       ,NIL},;
			{'CT2_CLVLCR'   ,''      					       ,NIL},;
			{'CT2_AGLUT'    ,'2'							   ,NIL}})
			
			If len(sHist)>40
				//Inclusão de Lançamento Contábil Historico 02
				Aadd 	(aItens, {{'CT2_FILIAL'   ,'0101' 							,NIL},;
				{'CT2_LOTE'     ,'APRCNW'						   ,NIL},;
				{'CT2_SBLOTE'   ,'001'					   	   ,NIL},;
				{'CT2_DOC'      ,cDocCt2						   ,NIL},;
				{'CT2_DATA'     ,dDataBase					   ,NIL},;
				{'CT2_LINHA'    ,'002'						   ,NIL},;
				{'CT2_MOEDLC'   ,'01'							   ,NIL},;
				{'CT2_DC'       ,'4'    					       ,NIL},;
				{'CT2_DEBITO'   ,''							   ,NIL},;
				{'CT2_CREDIT'   ,''							   ,NIL},;
				{'CT2_VALOR'    ,0							   ,NIL},;
				{'CT2_EMPORI'   ,'01'							   ,NIL},;
				{'CT2_FILORI'   ,'0101'						   ,NIL},;
				{'CT2_TPSALD'   ,'1'							   ,NIL},;
				{'CT2_ORIGEM'   ,'GCT-CANCELADO'  	     	   ,NIL},;
				{'CT2_HIST'     ,substr(sHist,40,len(sHist))	   ,NIL},;
				{'CT2_CRCONV'   ,'1'							   ,NIL},;
				{'CT2_AGLUT'    ,'2' 							   ,NIL}})
			endif
			
			MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)   // 85 - 126
			
			
			If lMsErroAuto
	
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Erro na inclusao(Valor Curto Prazo)!"  , 0, 0, {}) 
				MostraErro()
			EndIf
			
		endif
		
		TCNW->(dbSkip())
		
		
		
	EndDo
	
	IF sHist<>''
		Alert('Transferencia concluida com sucesso!')
	else
		Alert('Nao foram encontrados registros!')
	endif
	
	TCNW->(dbCloseArea())
	
Endif
/*
-----------------------------------------------------------------
*/

RETURN NIL


