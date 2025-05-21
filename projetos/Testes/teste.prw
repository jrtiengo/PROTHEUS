#include "TOTVS.ch"

User Function teste()

    Local aArea     := FWGetArea()
    Local cAutoEmp  := "99"
    Local cAutoFil  := "01"
    Local cAutoUsu  := "admin"
    Local cAutoSen  := "123"
    Local cAutoAmb  := "GPE"
 
    //Se o dicionário não estiver aberto, irá preparar o ambiente
    If Select("SX2") <= 0
        RPCSetEnv(cAutoEmp, cAutoFil, cAutoUsu, cAutoSen, cAutoAmb)
    EndIf

    aSM0Data1 := FWSM0Util():GetSM0Data( "99" , "01" , { "M0_CODFIL" } ) 

 FWRestArea(aArea)

Return(nCalc)  


  "specifications": [
        {
            "name": "Aro",
            "values": [
                "55"
            ]
        }
    ],                                                                                                                                                                        

