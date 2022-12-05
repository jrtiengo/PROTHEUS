#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AcertoSFT  º Autor ³ AP5 IDE            º Data ³  29/02/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP5 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AcertoFT()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
Processa( {|| fAcertoSFT() },"Acerto dos Campos FT_CLASFIS e FT_CTIPI na Tabela SFT","Aguarde...." )
                        
Return

Static Function fAcertoSFT()

Local nRecSFT  := 0   
Local cCTIPI   := Space(2)         
Local cClasFis := Space(2)
Local cNFiscal := Space(6)
Local cSerie   := Space(3)
Local cCliFor  := Space(6)
Local cLoja    := Space(2)
Local cTes     := Space(3)
Local cCF      := Space(5)

dbSelectArea("SD1")
dbSetOrder(1)

dbSelectArea("SF4")
dbSetOrder(1)    

dbSelectArea("SFT")
dbSetOrder(2)
ProcRegua(RecCount())
dbSeek(xFilial("SFT")+"E20120102")
Do While !EOF() .And. FT_TIPOMOV == "E"
      
   IncProc()              

   nRecSFT  := RecNo()       
   cCTIPI   := Space(2)         
   cClasFis := Space(2)
   cNFiscal := FT_NFISCAL
   cSerie   := FT_SERIE
   cCliFor  := FT_CLIEFOR
   cLoja    := FT_LOJA 
   cCF      := FT_CFOP
             
   dbSelectArea("SD1")
   If dbSeek(xFilial("SD1")+cNFiscal+cSerie+cCliFor+cLoja)
	  cTes := D1_TES
	  
	  dbSelectArea("SF4")  
	  dbSeek(xFilial("SF4")+cTes)
	  cCTIPI   := F4_CTIPI
      cClasFis := "0"+F4_SITTRIB
   EndIf
   
   dbSelectArea("SFT")
   dbGoTo(nRecSFT)
   RecLock("SFT",.F.)
     SFT->FT_CLASFIS := cClasFis
     SFT->FT_CTIPI   := cCTIPI  
   MsUnLock()
   dbSkip()
EndDo

Return
