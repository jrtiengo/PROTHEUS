#include "Totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CN150APR ³ Autor ³ Denis Rodrigues     ³ Data ³ 09/04/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PONTO DE ENTRADA: Executado apos a aprovação da revisão.   ³±±
±±³          ³ Rotina que vincula as tabelas SZB, SZC e SZA a nova revisao³±±
±±³          ³ do Contrato apos a aprovacao da nova revisao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_CN150APR                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CN150APR()

Local aArea   := GetArea()
Local cNumCto := ParamIxb[1]// Numero do Contrato aprovado
Local cNumRev := ParamIxb[2]// Numero da nova revisao
Local cRevAnt := "" // Revisao anterior
Local cQuery  := ""
Local cAlias1 := GetNextAlias()
Local cAno     := VAL(SubStr( DtoS(     YearSum( date() , 1 )       ), 1, 4 ))//adicinando mais um exercicio para determinar longo

cQuery:=" UPDATE "+RETSQLNAME("SE2")+" "
cQuery+=" SET E2_NATUREZ =ED_NATCPLP "
cQuery += " FROM "+RetSqlName('SE2')+" SE2 "
cQuery += "  INNER JOIN "+RETSQLNAME("SED")+" SED ON ( SE2.E2_NATUREZ=SED.ED_CODIGO) "
cQuery += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
cQuery += "  AND SE2.E2_PREFIXO='CTR'
cQuery += "  AND SED.D_E_L_E_T_<>'*' "
cQuery += "  AND SE2.D_E_L_E_T_<>'*' "
cQuery += "  AND SE2.E2_TIPO='PR' "
cQuery += "  AND YEAR(SE2.E2_VENCTO)>'"+ALLTRIM(str(cAno))+"' "
cQuery += "  AND SED.ED_NATCLP  ='C' "
cQuery += "  AND SE2.E2_MDCONTR = '"+cNumCto+"' "
cQuery += "  AND SE2.E2_MDREVIS = '"+cNumRev+"' "

nRet:=TcSqlExec(cQuery)
If nRet<>0
	Alert(TCSQLERROR())
Endif







//+-----------------------------------------------------------------------+
//| Se a nova revisao for a primeira a revisao anterior tem que ser vazia |
//+-----------------------------------------------------------------------+
If Val( cNumRev )-1 = 0
	cRevAnt := Space( TamSX3("CN9_REVISA")[01] )
Else
	cRevAnt := StrZero( Val( "003" )-1, TamSX3("CN9_REVISA")[01] )
EndIf



//+-----------------------------------------------+
//| Atualizando a data do ultimo fechamento de    |
//| Royalties                                     |
//+-----------------------------------------------+
cQuery := " SELECT * "
cQuery += " FROM "+RetSQLName("CN9")
cQuery += " WHERE CN9_FILIAL  = '"+xFilial("CN9")+"'"
cQuery += "   AND CN9_NUMERO  = '"+cNumCto+"'"
cQuery += "   AND CN9_REVISA  = '"+cRevAnt+"'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )

If ( cAlias1 )->( !EOF() )	
		
		dbSelectArea("CN9")
		
		RecLock( "CN9", .F.)
		CN9->CN9_ULTFEC:=sToD(( cAlias1 )->CN9_ULTFEC)
		MsUnLock()
	
EndIf

cAlias1 := GetNextAlias()

//+-----------------------------------------------+
//| Alterando a revisao do Contrato na tabela SZC |
//| Licenciado x Produtos                         |
//+-----------------------------------------------+
cQuery := " SELECT R_E_C_N_O_ AS RECNO"
cQuery += " FROM "+RetSQLName("SZC")
cQuery += " WHERE ZC_FILIAL  = '"+xFilial("SZC")+"'"
cQuery += "   AND ZC_NUMCTO  = '"+cNumCto+"'"
cQuery += "   AND ZC_REVISA  = '"+cRevAnt+"'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )

If ( cAlias1 )->( !EOF() )
	
	While ( cAlias1 )->( !EOF() )
		
		dbSelectArea("SZC")
		SZC->( dbGoTo( ( cAlias1 )->RECNO ) )
		RecLock( "SZC", .F.)
		SZC->ZC_REVISA := cNumRev
		MsUnLock()
		
		( cAlias1 )->( dbSkip() )
		
	EndDo
	
EndIf

( cAlias1 )->( dbCloseArea() )

//+-----------------------------------------------+
//| Alterando a revisao do Contrato na tabela SZB |
//| Licenciado x Ponto de Venda                   |
//+-----------------------------------------------+
cAlias1 := GetNextAlias()

cQuery := " SELECT R_E_C_N_O_ AS RECNO"
cQuery += " FROM "+RetSQLName("SZB")
cQuery += " WHERE ZB_FILIAL  = '"+xFilial("SZB")+"'"
cQuery += "   AND ZB_NUMCTO  = '"+cNumCto+"'"
cQuery += "   AND ZB_REVISA  = '"+cRevAnt+"'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )

If ( cAlias1 )->( !EOF() )
	
	While ( cAlias1 )->( !EOF() )
		
		dbSelectArea("SZB")
		SZB->( dbGoTo( ( cAlias1 )->RECNO ) )
		RecLock( "SZB", .F.)
		SZB->ZB_REVISA := cNumRev
		MsUnLock()
		
		( cAlias1 )->( dbSkip() )
		
	EndDo
	
EndIf

( cAlias1 )->( dbCloseArea() )

//+-----------------------------------------------+
//| Alterando a revisao do Contrato na tabela SZA |
//| Licenciado x Venda x Ponto de Venda           |
//+-----------------------------------------------+
cAlias1 := GetNextAlias()

cQuery := " SELECT R_E_C_N_O_ AS RECNO"
cQuery += " FROM "+RetSQLName("SZ9")
cQuery += " WHERE "
cQuery += "   Z9_NUMCTO      = '"+cNumCto+"'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )

If ( cAlias1 )->( !EOF() )
	
	While ( cAlias1 )->( !EOF() )
		
		dbSelectArea("SZ9")
		SZ9->( dbGoTo( ( cAlias1 )->RECNO ) )
		RecLock( "SZ9", .F.)
		SZ9->Z9_REVCTO := cNumRev
		MsUnLock()
		
		( cAlias1 )->( dbSkip() )
		
	EndDo
	
EndIf

( cAlias1 )->( dbCloseArea() )

//+-----------------------------------------------+
//| Alterando a revisao do Contrato na tabela SZA |
//| Licenciado x Venda x Ponto de Venda           |
//+-----------------------------------------------+
cAlias1 := GetNextAlias()

cQuery := " SELECT R_E_C_N_O_ AS RECNO"
cQuery += " FROM "+RetSQLName("SZA")
cQuery += " WHERE ZA_FILIAL  = '"+xFilial("SZA")+"'"
cQuery += "   AND ZA_NUMCTO  = '"+cNumCto+"'"
cQuery += "   AND ZA_REVISA  = '"+cRevAnt+"'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )

If ( cAlias1 )->( !EOF() )
	
	While ( cAlias1 )->( !EOF() )
		
		dbSelectArea("SZA")
		SZA->( dbGoTo( ( cAlias1 )->RECNO ) )
		RecLock( "SZA", .F.)
		SZA->ZA_REVISA := cNumRev
		MsUnLock()
		
		( cAlias1 )->( dbSkip() )
		
	EndDo
	
EndIf

( cAlias1 )->( dbCloseArea() )

RestArea( aArea )

Return
