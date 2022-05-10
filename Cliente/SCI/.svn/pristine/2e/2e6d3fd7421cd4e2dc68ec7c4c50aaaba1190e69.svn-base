#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#include "rwmake.ch"

User Function M460FIM()

Local aArea :=getArea()
Local aAreaSE2  := SE2->(GetArea())
Local aAreaSD2  := SD2->(GetArea())
Local aAreaSF2  := SF2->(GetArea())

Local _cHist:=Alltrim(Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_HIST"))


If _cHist<>''
	Reclock("SF2",.F.)
	SF2->F2_HIST:=_cHist
	SF2->(msUnlock())
	
	RecLock('SE2',.F.)
	SE2->E2_HIST := _cHist
	SE2->(MsUnlock())
Endif


DadosSE2() 


restarea(aArea)
restarea(aAreaSE2)
restarea(aAreaSD2)
restarea(aAreaSF2)
return(.t.)

Static Function DadosSE2()
                                                       
Local cCtaCtb:=''    
Local cContaD:=''

	cQuery := "SELECT E2_CTACTB,E2_CONTAD,E2_CCCTB,E2_ITCTB,E2_CLVLCTB FROM "+ RetSqlName( 'SE2' )
	cQuery += " WHERE "
	cQuery += "       E2_NUM          = '" + SD2->D2_NFORI  + "'"
	cQuery += "   AND E2_FORNECE  = '" + SD2->D2_CLIENTE+ "'"
    cQuery += "   AND E2_LOJA     = '" + SD2->D2_LOJA   + "'"
	cQuery += "   AND SE2010.D_E_L_E_T_  <> '*'"
	
	cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE2",.F.,.T.)
    
	cQuery :=""

	cQuery := " UPDATE "+ RetSqlName( 'SE2' )+" SET "
	cQuery += " E2_CCCTB		  = '" + TSE2->E2_CCCTB + "',"
	cQuery += " E2_ITCTB		  = '" + TSE2->E2_ITCTB + "',"
	cQuery += " E2_CLVLCTB		  = '" + TSE2->E2_CLVLCTB + "',"
	cQuery += " E2_CTACTB         = '" + TSE2->E2_CTACTB + "',"
	cQuery += " E2_CONTAD         = '" + TSE2->E2_CONTAD + "'"      
	cQuery += " FROM "+ RetSqlName( 'SE2' )
	cQuery += " WHERE "
	cQuery += "       E2_TIPO     = 'NDF' "
    cQuery += "   AND E2_NUM      = '" + SD2->D2_DOC  + "'"
	cQuery += "   AND E2_FORNECE  = '" + SD2->D2_CLIENTE+ "'"
    cQuery += "   AND E2_LOJA     = '" + SD2->D2_LOJA   + "'"
	cQuery += "   AND SE2010.D_E_L_E_T_  <> '*'"
	
	MemoWrite('TMPCONTAD.SQL',cQuery)
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	End 
	

Return
