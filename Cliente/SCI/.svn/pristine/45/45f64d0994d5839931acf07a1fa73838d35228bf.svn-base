#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MTA103MNU ³ Autor ³ Manoel Mariante       ³ Data ³Jan/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada pelo PE MT100TOK                     			  ³±±
±±³			 ³ Serve para amarrar os Conhec Frete as Notas de Venda       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sport Club Internacional						              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function CN110GRV 
    Local dDataMed:=''
    Local nOpc    :=PARAMIXB[1]
    
    //IF CN9->CN9_CONTAB =='1'
	//    IF MSGBOX("Deseja Imprimir a Estimativa de Parcelas/Impostos ?","Relatório","YESNO")
	//    	u_SCIR035(CN9->CN9_NUMERO)
	//    End
 
    //	RETURN .T.
    //END                
    
    RETURN .T.
    dbSelectArea("CNF")
    dbsetOrder(3)
    dbSeek(xFilial('CNF')+CN9->(CN9_NUMERO+CN9_REVISA),.t.)
    dDataMed:=CNF->CNF_PRUMED
    
	cQuery:=" UPDATE "+RETSQLNAME("CNF")+" "
	cQuery+=" SET CNF_PRUMED ='"+Dtos(dDataMed)+"'"
	cQuery+=" WHERE CNF_FILIAL='"+XfILIAL("CNF")+"'"
	cQuery+=" AND CNF_CONTRA ='"+CN9->CN9_NUMERO+"'"
	 //	cQuery+=" AND CNF_REVISA ='"+CN9->CN9_REVISA+"'"
	cQuery+=" AND D_E_L_E_T_=''"
	
	nRet:=TcSqlExec(cQuery)			
	If nRet<>0
		Alert(TCSQLERROR())
	End

    IF MSGBOX("Deseja Imprimir a Estimativa de Parcelas/Impostos ?","Relatório","YESNO")
    	u_SCIR035(CN9->CN9_NUMERO)
    End
Return .t.