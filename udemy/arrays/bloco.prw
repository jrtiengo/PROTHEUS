#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  bloco()

    //Local bBloco := {|| Alert("Ol� Mundo")}
    //    Eval(bBloco)
    
    Local bBloco := {|cMsg| Alert(cMsg)}
        Eval(bBloco, "Ol� Mundo!")

Return
