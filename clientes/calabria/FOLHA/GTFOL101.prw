#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function GTFOL101(cTipo)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NORDER,NSELECT,NREC,Order_AntCT1,Rec_AntCT1,Order_AntCTT,Rec_AntCTT")  
SetPrvt("Order_AntSRV,Rec_AntSRV")
SetPrvt("cNivelCRG,cLanPad,cTpLan,nValNeg,cPD,cCC,cConta,cTpDC,cCtaRed,cLPRed")
   
nOrder  := DbSetOrder()
nSelect := Select()
nRec    := Recno()

cTpLan  := CT5->CT5_DC
If cTipo == "D"
   cCC := Iif(!Empty(CT5->CT5_CCD),SRZ->RZ_CC,Space(9))
Else                                          
   cCC := Iif(!Empty(CT5->CT5_CCC),SRZ->RZ_CC,Space(9))
EndIf 
nValNeg := SRZ->RZ_VAL < 0
cPD     := SRZ->RZ_PD 
cTpDC   := Iif(nValNeg,Iif(cTipo=="D","C","D"),cTipo) 
cLPRed  := Substr(CT5->CT5_LANPAD,1,1)
cLPLancP:= "P"+Substr(CT5->CT5_LANPAD,2,2)
cLPLancD:= "D"+Substr(CT5->CT5_LANPAD,2,2)

DbSelectARea("SRV")   // CAD VERBAS
Order_AntSRV := IndexOrd()
Rec_AntSRV   := Recno()
DbSetOrder(1)
DbSeek(xFilial("SRV")+cPD) 
cLanPad := RV_LCTOP  // o conteudo eh o mesmo do CT5_LANPAD
 
DbSelectARea("CTT")  // CAD CCUSTO
Order_AntCTT := IndexOrd()
Rec_AntCTT   := Recno() 
DbSetOrder(1)  
If !Empty(cCC)       
   DbSeek(xFilial("CTT")+cCC) 
   cNivelCRG := CTT_CRGNV1     
Else 
   cNivelCRG := Space(12)
EndIf   
DbSelectARea("CT1") // P cONTAS
Order_AntCT1 := IndexOrd()
Rec_AntCT1   := Recno()    
DbSetOrder(8)
If cTpLan <> "3"
   If cLPRed == "C" 
      DbSeek(xFilial("CT1")+cLPLancD+cNivelCRG)   
   ElseIf cLanPad $ "F09/F10"  
      DbSeek(xFilial("CT1")+"B01"+cNivelCRG)
   Else 
      DbSeek(xFilial("CT1")+cLanPad+cNivelCRG)  
   EndIf
ElseIf cLPRed == "Y" // Baixa Provisao
   If cTpDC == "C"  // Credito
      DbSeek(xFilial("CT1")+cLPLancP+cNivelCRG+"3")        
   Else    // Debito
      DbSeek(xFilial("CT1")+cLPLancP+cNivelCRG+"2")        
   EndIf  
Else                                                       
   If cTpDC == "C"  // Credito
      DbSeek(xFilial("CT1")+cLanPad+cNivelCRG+"2")        
   Else    // Debito
      DbSeek(xFilial("CT1")+cLanPad+cNivelCRG+"3")        
   EndIf
EndIf         
cConta := CT1_CONTA
If Empty(cConta)
   cConta := cConta
EndIf

DbSelectARea("SRV")
DbSetOrder(Order_AntSRV)
DbGoTo(Rec_AntSRV)

DbSelectARea("CTT")
DbSetOrder(Order_AntCTT)
DbGoTo(Rec_AntCTT)

DbSelectARea("CT1")
DbSetOrder(Order_AntCT1)
DbGoTo(Rec_AntCT1)

DbSelectArea( nSelect )
DbSetOrder( nOrder )
DbGoto( nRec )

Return(cConta)
