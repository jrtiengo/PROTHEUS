#INCLUDE "Protheus.CH"
#include "rwmake.ch"
#include "TOTVS.ch"
#include "TBICONN.ch"

User Function MyAtfa012()
    Local aArea := GetArea()
    Local dAquisic //:= dDataBase //:= CTOD("01/06/20")//dDataBase
    Local dIndDepr //:= RetDinDepr(dDataBase)
    Local cDescric := "Teste 01"
    Local nTamBase //:= TamSX3("N3_CBASE")[1]
    Local nTamChapa //:= TamSX3("N3_CBASE")[1]
    Local aParam := {}
    Local aCab := {}
    Local aItens := {}

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.

    PREPARE ENVIRONMENT EMPRESA "07" FILIAL "04" MODULO "ATF" TABLES "SN1","SN3"

        dAquisic := dDataBase //:= CTOD("01/06/20")//dDataBase
        dIndDepr := RetDinDepr(dDataBase)

        DBSelectArea(aArea)
        nTamBase := TamSX3("N3_CBASE")[1]
        nTamChapa := TamSX3("N3_CBASE")[1]

        aCab := {}
        AAdd(aCab,{"N1_CBASE"  , '0000000293' ,NIL}) //
        AAdd(aCab,{"N1_ITEM"   , '0001' ,NIL})
        AAdd(aCab,{"N1_AQUISIC", dDataBase ,NIL}) //
        AAdd(aCab,{"N1_DESCRIC", cDescric ,NIL}) //
        AAdd(aCab,{"N1_QUANTD" , 1 ,NIL}) //
        AAdd(aCab,{"N1_CHAPA"  , 'TESTE CHAPA 3' ,NIL})
        AAdd(aCab,{"N1_PATRIM" , 'N' ,NIL})
        AAdd(aCab,{"N1_GRUPO"  , '' ,NIL}) 
        AAdd(aCab,{"N1_NFISCAL", '123456' ,NIL}) //
        AAdd(aCab,{"N1_NSERIE"  , '5' ,NIL}) //
        AAdd(aCab,{"N1_STATUS"  , '1' ,NIL})
        //AAdd(aCab,{"N1_CALCPIS", '2' ,NIL})
        //Coloque os campos desejados aqui 

        aItens := {}
        //-- Preenche itens

        AAdd(aItens,{;
        {"N3_CBASE"   , '0000000293' ,NIL},;
        {"N3_ITEM"    , '0001' ,NIL},;
        {"N3_TIPO"    , '01' ,NIL},; 
        {"N3_BAIXA"   , "0" ,NIL},; // sempre criar assim
        {"N3_HISTOR"  , cDescric ,NIL},;
        {"N3_DINDEPR" , dIndDepr ,NIL},; //
        {"N3_VORIG1"  , 1000 ,NIL},;
        })
        //{"N3_TXDEPR1" , 20 ,NIL},;
        //{"N3_CCDEPR"  , '130204006' ,NIL};
        //{"N3_CCONTAB" , '13020800101' ,NIL},;
        //{"N3_CUSTBEM" , '03440' ,NIL},;
        //{"N3_CDEPREC" , '32010100231' ,NIL},;
        //{"N3_CCUSTO"  , '03440' ,NIL},;
        //{"N3_SUBCCON" , '0704' ,NIL},;
        //{"N3_SUBCTA"  , '0704' ,NIL};
        
        //Coloque os campos desejados aqui

        Begin Transaction

            MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
            If lMsErroAuto 

                MostraErro()
                DisarmTransaction()
            Endif
        End Transaction

        RestArea(aArea)
    RESET ENVIRONMENT

Return
