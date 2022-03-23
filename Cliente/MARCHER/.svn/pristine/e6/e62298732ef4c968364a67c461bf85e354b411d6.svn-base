#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³MT100LOK  ³ Autor ³ Jair Junior            ³    a ³08.08.2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Ponto de entrada valida necessidade prenchimento chassis    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ   
*/

User Function MT100LOK()

Local _lRet := .T.
Local _nPosChassi := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CHASSI"})
Local _nPosCod   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
  
//If Funname() =="MATA103"

 lTemChassi := POSICIONE("SB1",1,XFILIAL("SB1")+acols[n][_nPosCod],"B1_CHASSIS")

 If lTemChassi == "S"
    // Valido o Chassi
    
     If empty(acols[n][_nPosChassi])
          // Campo vazio... Obriga a digitacao
    MsgAlert("Produto tem controle de Chassis","Totvs")
       _lRet := .f.
  Else
    // campo preenchido preciso validar
    _lRet := .t.
 EndIf
    
EndIf

Return(_lRet)