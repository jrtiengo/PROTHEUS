#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100VST  ³ Autor ³ Manoel Mariante       ³ Data ³Out/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ valida a alteraçao do status do contrato                   ³±±
±±³			 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sport Club Internacional						              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function CN100VST

	Local lRet   :=.T.
	Local cCampos:=""
	Local cSit   :=PARAMIXB[1]
	Local cAuxNat:=""
	Posicione("CNB",1,xFilial("CNB")+CN9->CN9_NUMERO+CN9->CN9_REVISA+"000001","CNB_NATURE")
	//ALERT(CNB->CNB_CONTRA)
	IF !EMPTY(CNB->CNB_NATURE)
		cAuxNat:=CNB->CNB_NATURE
	ELSEIF !EMPTY(CN9->CN9_NATURE)
		cAuxNat:=CN9->CN9_NATURE
	END

	If cSit$'02'

		If (CN9->CN9_SCILA='S') .or. (CN9->CN9_LAPNC='S')
			cAlert:="Este contrato já foi contabilizado!"
			cAlert+=" "+ Chr(13) + Chr(10) +"É necessário desontabilizá-lo e retirar o flag pela rotina"
			cAlert+=" "+ Chr(13) + Chr(10) +"u_DflagCn9 - Contrato->Miscelania->Desflag Contrato."
			Alert(cAlert)

			return .f.
		end
	End


	If cSit$'01'
		atuProv()
		u_GrCt2CNW()
		u_GrCt2CN9()
	End



	If cSit$'05'
		//	If Empty(CN9->CN9_NATURE) .AND. Empty(CNB->CNB_NATURE)
		//		lRet:=.F.
		//		cCampos+="Natureza_GCT"+Chr(10)
		//	End

		//If Empty(CN9->CN9_CONTAB )
		//	lRet:=.F.
		//	cCampos+="Contab ?"+Chr(10)
		//End

		If CN9->CN9_TPOCTO == 'LIC '

			If Empty(CN9->CN9_PERACE)
				lRet:=.F.
				cCampos+="Periodo de Acerto."+Chr(10)

			End

			If Empty(CN9->CN9_VLMIGR)
				lRet:=.F.
				cCampos+="Valor Minimo de Garantia."+Chr(10)

			End

			If Empty(CN9->CN9_TXROY)
				lRet:=.F.
				cCampos+="Percentual de Royalties."+Chr(10)

			End
			If Empty(CN9->CN9_PRZESC)
				lRet:=.F.
				cCampos+="Prazo de Escoamento."+Chr(10)

			End
			If Empty(CN9->CN9_CTCORT)
				lRet:=.F.
				cCampos+="Cota Cortesia."+Chr(10)

			End

			If Empty(CN9->CN9_CARMIN)
				lRet:=.F.
				cCampos+="Carencia Minima."+Chr(10)

			End

			If Empty(CN9->CN9_FORPAG)
				lRet:=.F.
				cCampos+="Forma de Pagamento."+Chr(10)

			End

			If Empty(CN9->CN9_DIAVEN)
				lRet:=.F.
				cCampos+="Dia do Vencimento."+Chr(10)

			End

			If Empty(CN9->CN9_DIAREL)
				lRet:=.F.
				cCampos+="Dia de entrega do Rel."+Chr(10)

			End

			If Empty(CN9->CN9_SELOBR)
				lRet:=.F.
				cCampos+="Selo Holografico."+Chr(10)

			End
		End


	End

	If !lRet
		Alert('As seguintes informações não foram preenchidas !'+chr(13)+chr(10)+cCampos,;
			'Campos vazios...')
	else
		If cSit$'05'
			IF EMPTY(CN9->CN9_CLIENT)
				If !Empty(cAuxNat)
					/*
					dbSelectArea("SX6")
					dbSetOrder(1)
					dbSeek(xFilial("SX6")+"MV_CNNAT")
		        	Reclock("SX6",.f.)   
		        	SX6->X6_CONTEUD:=cAuxNat
		        	msUnlock()  
		           //	ALERT('GRAVEI '+cAuxNat)
		           */
					PutMv("MV_CNNAT",cAuxNat)
				End
			ELSE
				If !Empty(cAuxNat)
		   			/*
		   			dbSelectArea("SX6")
					dbSetOrder(1)
					dbSeek(xFilial("SX6")+"MV_CNNATCL")
		        	Reclock("SX6",.f.)
		        	SX6->X6_CONTEUD:=cAuxNat
		        	msUnlock()
		        	*/
					PutMv("MV_CNNATCL",cAuxNat)

				End
			END
		end
	End


Return lRet


user function GrCt2CNW()

	aCab   := {}
	aItens := {}
	Private lMsErroAuto := .f.
	Private sHist:=""
	sHist:="CANC. DIR. DE IMAGEM CONT."+" "+POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_CONTRA")
	sHist+=" "+POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_COMPET")
	sHist+=" "+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_CODIGO")
	sHist+=" "+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_LOJA")
	sHist+=" "+SUBSTR( POSICIONE("SA2", 1, xFilial("SA2")+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_CODIGO")+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_LOJA"),"A2_NOME"),1,25)



	c3Query := " SELECT ISNULL(MAX(CT2_DOC)+1,'1') PROXDOC "
	c3Query += " FROM CT2010 "
	c3Query += " WHERE CT2_DATA = '" + Dtos(dDataBase) + "'"
	c3Query += " AND   CT2_LOTE = '000GCT' "
	c3Query += " AND   CT2_FILIAL = '" + xFilial("CT2") + "'"
	c3Query += " AND D_E_L_E_T_ <> '*' "
	c3Query := ChangeQuery(c3Query)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c3Query),"MAXCT2",.F.,.T.)
	DbSelectArea("MAXCT2")



	cDocCt2:=Strzero(MAXCT2->PROXDOC,6)
	MAXCT2->(dbCloseArea())


	nVlCont:=0
	/*---------Valor aprorpiado do cronograma contabil-------*/
	cQuery := " SELECT SUM(CNW_VLPREV) VALPREV "
	cQuery += " FROM CNW010 "
	cQuery += " WHERE CNW_FILIAL = '" + xFilial("CN9") + "'"
	cQuery += " AND CNW_CONTRA ='" + CN9->CN9_NUMERO + "'"
	cQuery += " AND CNW_REVISA ='" + CN9->CN9_REVISA + "'"
	cQuery += " AND CNW_FLGAPR='1' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TCNW",.F.,.T.)
	DbSelectArea("TCNW")

	IF TCNW->VALPREV >0
		nVlCont:=TCNW->VALPREV
	ELSE
		nVlCont:=0
	ENDIF
	TCNW->(dbCloseArea())
	cCC:=""
	cCV:=""
	cCC:=POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_CC")
	cCV:=POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_CLVL")
	//Inclusão de Lançamento Contábil Cabecalho
	aAdd(aCab,  {'DDATALANC'     ,dDataBase ,NIL} )
	aAdd(aCab,  {'CLOTE'         ,'000GCT'  ,NIL} )
	aAdd(aCab,  {'CSUBLOTE'      ,'001'     ,NIL} )
	aAdd(aCab,  {'CDOC'          ,cDocCt2   ,NIL} )
	aAdd(aCab,  {'CPADRAO'       ,''        ,NIL} )
	aAdd(aCab,  {'NTOTINF'       ,0         ,NIL} )
	aAdd(aCab,  {'NTOTINFLOT'    ,0         ,NIL} )

	//Inclusão de Lançamento Contábil

	Aadd 	(aItens, {{'CT2_FILIAL'       ,'01'                            ,NIL},;
		{'CT2_LOTE'     ,'000GCT'                        ,NIL},;
		{'CT2_SBLOTE'   ,'001'                           ,NIL},;
		{'CT2_DOC'      ,cDocCt2						   ,NIL},;
		{'CT2_DATA'     ,dDataBase                       ,NIL},;
		{'CT2_LINHA'    ,'001'                           ,NIL},;
		{'CT2_MOEDLC'   ,'01'                            ,NIL},;
		{'CT2_DC'       ,'3'                             ,NIL},;
		{'CT2_DEBITO'   ,'12070010030020'                ,NIL},;
		{'CT2_CREDIT'   ,'32010010050001'                ,NIL},;
		{'CT2_VALOR'    ,nVlCont			     		   ,NIL},;
		{'CT2_EMPORI'   ,'01'             			   ,NIL},;
		{'CT2_FILORI'   ,'0101'             			   ,NIL},;
		{'CT2_TPSALD'   ,'1'                			   ,NIL},;
		{'CT2_CCC'      ,cCC         	        		   ,NIL},;
		{'CT2_ORIGEM'   ,'GCT-CANCELADO'    			   ,NIL},;
		{'CT2_HIST'     ,substr(sHist,1,40) 			   ,NIL},;
		{'CT2_CRCONV'   ,cCV   						   ,NIL},;
		{'CT2_CLVLCR'   ,'100003' 					   ,NIL},;
		{'CT2_AGLUT'    ,'2'							   ,NIL}})

	//Inclusão de Lançamento Contábil Historico 01
	Aadd 	(aItens, {{'CT2_FILIAL'   	  ,'01'							   ,NIL},;
		{'CT2_LOTE'     ,'000GCT'						   ,NIL},;
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

	MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)   // 85 - 126


	If lMsErroAuto
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Erro na inclusao(Valor CNW - Lote 000GCT )!", 0, 0, {})
		MostraErro()
	EndIf




return

User function GrCt2CN9()

	aCab   := {}
	aItens := {}
	Private lMsErroAuto := .f.
	Private sHist:=""
	sHist:="CANC. DIR. DE IMAGEM CONT."+" "+POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_CONTRA")
	sHist+=" "+POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_COMPET")
	sHist+=" "+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_CODIGO")
	sHist+=" "+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_LOJA")
	sHist+=" "+SUBSTR( POSICIONE("SA2", 1, xFilial("SA2")+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_CODIGO")+POSICIONE("CNC", 1, xFilial("CNC")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNC_LOJA"),"A2_NOME"),1,25)



	c3Query := " SELECT ISNULL(MAX(CT2_DOC)+1,'1') PROXDOC "
	c3Query += " FROM CT2010 "
	c3Query += " WHERE CT2_DATA = '" + Dtos(dDataBase) + "'"
	c3Query += " AND   CT2_LOTE = '001GCT' "
	c3Query += " AND   CT2_FILIAL = '" + xFilial("CT2") + "'"
	c3Query += " AND D_E_L_E_T_ <> '*' "
	c3Query := ChangeQuery(c3Query)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c3Query),"XMAXCT2",.F.,.T.)
	DbSelectArea("XMAXCT2")


	cDocCt2:=""
	cDocCt2:=Strzero(XMAXCT2->PROXDOC,6)
	XMAXCT2->(dbCloseArea())


	nVlCont:=0

	IF (CN9->CN9_VLINI >0) .AND. (ALLTRIM(CN9->CN9_REVISA)="")
		nVlCont:=CN9->CN9_VLINI
	ELSE
		IF (ALLTRIM(CN9->CN9_REVISA)<>"") .AND. (CN9->CN9_VLADIT>0)
			nVlCont:=CN9->CN9_VLADIT
		End
	End


	cCC:=""
	cCV:=""
	cCC:=POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_CC")
	cCV:=POSICIONE("CNW", 1, xFilial("CNW")+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNW_CLVL")
	//Inclusão de Lançamento Contábil Cabecalho
	aAdd(aCab,  {'DDATALANC'     ,dDataBase ,NIL} )
	aAdd(aCab,  {'CLOTE'         ,'001GCT'  ,NIL} )
	aAdd(aCab,  {'CSUBLOTE'      ,'001'     ,NIL} )
	aAdd(aCab,  {'CDOC'          ,cDocCt2   ,NIL} )
	aAdd(aCab,  {'CPADRAO'       ,''        ,NIL} )
	aAdd(aCab,  {'NTOTINF'       ,0         ,NIL} )
	aAdd(aCab,  {'NTOTINFLOT'    ,0         ,NIL} )

	//Inclusão de Lançamento Contábil
	// ALTERADA A CONTA CREDITO CFE SOLIC DE LEANDRO SANTOS DIA 06/06/18 DE: 12070010030001 PARA 32010010050001
	Aadd 	(aItens, {{'CT2_FILIAL'       ,'01'                            ,NIL},;
		{'CT2_LOTE'     ,'001GCT'                        ,NIL},;
		{'CT2_SBLOTE'   ,'001'                           ,NIL},;
		{'CT2_DOC'      ,cDocCt2						   ,NIL},;
		{'CT2_DATA'     ,dDataBase                       ,NIL},;
		{'CT2_LINHA'    ,'001'                           ,NIL},;
		{'CT2_MOEDLC'   ,'01'                            ,NIL},;
		{'CT2_DC'       ,'3'                             ,NIL},;
		{'CT2_DEBITO'   ,'32010010010002'                ,NIL},;
		{'CT2_CREDIT'   ,'32010010050001'                ,NIL},;
		{'CT2_VALOR'    ,nVlCont			     		   ,NIL},;
		{'CT2_EMPORI'   ,'01'             			   ,NIL},;
		{'CT2_FILORI'   ,'0101'             			   ,NIL},;
		{'CT2_TPSALD'   ,'1'                			   ,NIL},;
		{'CT2_CCC'      ,cCC         	        		   ,NIL},;
		{'CT2_ORIGEM'   ,'GCT-CANCELADO'    			   ,NIL},;
		{'CT2_HIST'     ,substr(sHist,1,40) 			   ,NIL},;
		{'CT2_CRCONV'   ,cCV   						   ,NIL},;
		{'CT2_CLVLCR'   ,'100003' 					   ,NIL},;
		{'CT2_AGLUT'    ,'2'							   ,NIL}})

	//Inclusão de Lançamento Contábil Historico 01
	Aadd 	(aItens, {{'CT2_FILIAL'   	  ,'01'							   ,NIL},;
		{'CT2_LOTE'     ,'001GCT'						   ,NIL},;
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

	MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)   // 85 - 126


	If lMsErroAuto
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Erro na inclusao(Valor CN9 - Lote 001GCT)!", 0, 0, {})
		MostraErro()
	EndIf

return

static function atuProv()

	IF !EMPTY(CND->CND_FORNEC) //CONTAS A PAGAR


		dbSelectArea("CNB")
		dbSetOrder(1)
		dbSeek(CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA+'000001'),.T. )

		dbSelectArea("CTH")
		dbSetOrder(1)
		dbSeek(xFilial("CTH")+CNB->CNB_CLVL,.T. )

		cQuery:=" UPDATE "+RETSQLNAME("SE2")+" "
		cQuery+=" SET "
		cQuery+="     E2_CLVLCTB ='"+CNB->CNB_CLVL+"',"
		cQuery+="     E2_DESCLVL='"+CTH->CTH_DESC01+"' "
		cQuery+=" WHERE E2_FILIAL='"+XfILIAL("SE2")+"'"
		cQuery+=" AND E2_PREFIXO='CTR'"
		cQuery+=" AND E2_MDCONTR='"+CNB->CNB_CONTRA+"'"
		cQuery+=" AND E2_MDREVIS='"+CNB->CNB_REVISA+"'"
		cQuery+=" AND E2_MDPLANI='"+CNB->CNB_NUMERO+"'"
		cQuery+=" AND E2_TIPO='PR'"
		cQuery+=" AND D_E_L_E_T_=''"

		nRet:=TcSqlExec(cQuery)
		If nRet<>0
			Alert(TCSQLERROR())
		Endif
	Endif

return
