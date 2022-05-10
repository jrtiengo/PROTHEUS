#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±?Programa  =MT100GE2  ?Autor  =Ednei Silva         ? Data =  28/12/2015 ?±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕp±±
±±?Desc.     = Ponto de Entrada - Documento de Entrada para preencher o   ?±±
±±?          = campo E2_HIST - TÌtulos e pagar                            ?±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕp±±
±±?Uso       = Totvs P 11.8                                               ?±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/

User Function _F090CHOK() //desabilitado em 10.01.2020 tarasconi acredito que nunca usaram e estava no projeto 

//Local aCols   := PARAMIXB[1]
//Local nOpc    := PARAMIXB[2]
//Local aHeadSE2:= PARAMIXB[3]      
Private _oDlg  
Private _cHist    := SPACE(150)

DEFINE MSDIALOG _oDlg TITLE "Digitar Historico" FROM 000, 000 TO 250, 800 PIXEL
 
@ 020, 005 SAY "Historico" SIZE 072, 027 OF _oDlg COLORS 0, 16777215 PIXEL    
@ 020, 030 MSGET oHist VAR _cHist SIZE 365, 010 OF _oDlg COLORS 0, 16777215 PIXEL 
@ 100, 295 BUTTON "Salvar"  SIZE 43,11 ACTION (Grava(),Close(_oDlg)) OF _oDlg PIXEL //confirma
@ 100, 345 BUTTON "Fechar" SIZE 43,11 ACTION CLOSE (_oDlg) OF _oDlg PIXEL  //cancela

ACTIVATE MSDIALOG _oDlg CENTERED     

Return()

//Salvar o Historico

Static Function Grava()
 
Local aArea     := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSF1  := SF1->(GetArea())

   RecLock('SE2',.F.)
   SE2->E2_HIST := _cHist
   SF1->F1_HIST := _cHist
   SE2->(MsUnlock())

RestArea(aAreaSE2)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea) 

Return () 

