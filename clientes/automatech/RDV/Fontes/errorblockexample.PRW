#INCLUDE "TOTVS.CH"
 
Function ErrorBlockExample()

   Local cError     := ""
   Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
   Local uTemp      := Nil
      
   uTemp := "A" + 1
      
   ErrorBlock(oLastError)
      
   // Anota o erro no console.
   ConOut(cError)
 
Return
 