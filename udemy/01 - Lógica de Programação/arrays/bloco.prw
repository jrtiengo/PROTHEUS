#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  bloco()

    //Local bBloco := {|| Alert("Olá Mundo")}
    //    Eval(bBloco)
    
    Local bBloco := {|cMsg| Alert(cMsg)}
        Eval(bBloco, "Olá Mundo!")

Return
