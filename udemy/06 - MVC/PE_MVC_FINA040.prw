#include 'protheus.ch'
#include 'FwMvcDef.ch'

User Function FI040ROT() 

    Local aRotRet := AClone(PARAMIXB)
    
        aAdd( aRotRet,{"#Cópia", "u_copiaSE1()", 0, 7})

Return aRotRet
