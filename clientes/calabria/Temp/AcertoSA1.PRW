#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcertoSA1  บ Autor ณ AP5 IDE            บ Data ณ  29/02/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP5 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function AcertoA1()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   
Processa( {|| fAcertoSA1() },"Acerto do Codigo Municipio - IBGE da Tabela SA1","Aguarde...." )
                        
Return

Static Function fAcertoSA1()

Local nRecSA1  := 0   
Local cMun     := Space(25)         
Local cEst     := Space(2)
Local cCodMun  := ""

dbSelectArea("CC2")
dbSetOrder(2)

dbSelectArea("SA1")
dbSetOrder(1)
ProcRegua(RecCount())
DBGOTOP()
Do While !EOF()
      
   IncProc()              
   
   If !Empty(A1_COD_MUN)
      dbSkip()
      Loop
   EndIf       
             
   nRecSA1 := RecNo() 
   cMun    := AllTrim(A1_MUN)
   cEst    := A1_EST
   cCodMun := ""
   
   dbSelectArea("CC2")
   If dbSeek(xFilial("CC2")+cMun)
	  If cEst <> CC2_EST
	     dbSkip()
	     Do While cMun == AllTrim(CC2_MUN) .And. !EOF()
	        If cEst == CC2_EST
	           cCodMun := CC2_CODMUN  
	           Exit
	        EndIf
	        dbSkip()
	     EndDo
	  Else
	     cCodMun := CC2_CODMUN 
	  EndIf
   EndIf
   
   dbSelectArea("SA1")
   dbGoTo(nRecSA1)
   RecLock("SA1",.F.)
     SA1->A1_COD_MUN := cCodMun
   MsUnLock()
   dbSkip()
EndDo

Return
