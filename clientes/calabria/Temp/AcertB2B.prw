#INCLUDE "rwmake.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AcertB2B  º Autor ³ AP5 IDE            º Data ³  14/01/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP5 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AcertB2B()
   
Processa( {|| Acerto() },"Zerando Valores e Custos nas demais Moedas nas Tabelas SB2, SB9, SD3, SD1, SD2.","Aguarde...." )
                        
Return

Static Function Acerto()

Local dData := dDataBase

dbSelectArea("SB2")
dbSetOrder(1) 
dbGoTop()
ProcRegua(LASTREC())
Do While !EOF() .And. xFilial("SB2") == B2_FILIAL  
   IncProc()              
   RecLock("SB2",.F.)
	  SB2->B2_CM2   := 0
	  SB2->B2_VFIM2 := 0 
	  SB2->B2_VATU2 := 0 
	  SB2->B2_CM3   := 0 
	  SB2->B2_VFIM3 := 0 
	  SB2->B2_VATU3 := 0 
	  SB2->B2_CM4   := 0 
	  SB2->B2_VFIM4 := 0 
	  SB2->B2_VATU4 := 0 
	  SB2->B2_CM5   := 0 
	  SB2->B2_VFIM5 := 0 
	  SB2->B2_VATU5 := 0 
   MsUnLock()          
   dbSkip()
EndDo   

dbSelectArea("SB9")
dbSetOrder(1) 
dbGoTop()
ProcRegua(LASTREC())
Do While !EOF() .And. xFilial("SB9") == B9_FILIAL
   IncProc()              
   RecLock("SB9",.F.)
	  SB9->B9_CM2   := 0
	  SB9->B9_VINI2 := 0 
	  SB9->B9_CM3   := 0 
	  SB9->B9_VINI3 := 0 
	  SB9->B9_CM4   := 0 
	  SB9->B9_VINI4 := 0 
	  SB9->B9_CM5   := 0 
	  SB9->B9_VINI5 := 0 
   MsUnLock()          
   dbSkip()
EndDo   
                   
dbSelectArea("SD3")
dbSetOrder(6)
dbSeek(xFilial("SD3")+DTOS(dData))
ProcRegua(LASTREC())
Do While !EOF() .And. xFilial("SD3") == D3_FILIAL
   IncProc()              
   RecLock("SD3",.F.)
	  SD3->D3_CUSTO2 := 0
	  SD3->D3_CUSTO3 := 0
	  SD3->D3_CUSTO4 := 0
	  SD3->D3_CUSTO5 := 0
   MsUnLock()          
   dbSkip()
EndDo   

dbSelectArea("SD2")
dbSetOrder(5)                      
dbSeek(xFilial("SD2")+DTOS(dData))
ProcRegua(LASTREC())
Do While !EOF() .And. xFilial("SD2") == D2_FILIAL
   IncProc()              
   RecLock("SD2",.F.)
	  SD2->D2_CUSTO2 := 0
	  SD2->D2_CUSTO3 := 0
	  SD2->D2_CUSTO4 := 0
	  SD2->D2_CUSTO5 := 0
   MsUnLock()          
   dbSkip()
EndDo    

dbSelectArea("SD1")
dbSetOrder(3)
dbSeek(xFilial("SD1")+DTOS(dData))
ProcRegua(LASTREC())
Do While !EOF() .And. xFilial("SD1") == D1_FILIAL
   IncProc()              
   RecLock('SD1',.F.)
	  SD1->D1_CUSTO2 := 0
	  SD1->D1_CUSTO3 := 0
	  SD1->D1_CUSTO4 := 0
	  SD1->D1_CUSTO5 := 0
   MsUnLock()          
   dbSkip()
EndDo

Return .T.
