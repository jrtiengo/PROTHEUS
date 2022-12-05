#INCLUDE "protheus.ch"

User Function AT450FIL()
                
                Local cQuery := ""
                
                cQuery += "AB6_FILIAL=='"+xFilial("AB6")+"'.And."
                cQuery += "AB6_STATUS=='B' .And."
                cQuery += "AB6_CODCLI>='"+MV_PAR01+"'.And."
                cQuery += "AB6_CODCLI<='"+MV_PAR02+"'.And."
                cQuery += "Dtos(AB6_EMISSA)>='"+Dtos(MV_PAR03)+"'.And."
                cQuery += "Dtos(AB6_EMISSA)<='"+Dtos(MV_PAR04)+"'.And."
                cQuery += "AB6_NUMOS>='"+MV_PAR05+"'.And."
                cQuery += "AB6_NUMOS<='"+MV_PAR06+"'.And."
                cQuery += "AB6_CONPAG<>'" + Space( Len( AB6->AB6_CONPAG ) ) + "'"

Return(cQuery)
