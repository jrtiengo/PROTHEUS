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




&(posicione('SA1',1,FWxFilial('SA1')+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")) 
Empty(Alltrim(posicione('SC5',1,FWxFilial('SC5')+posicione('SD2',1,SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,'D2_PEDIDO'),'C5_X_ENTR')))                                                                                                                                                                                  

&(POSICIONE("SZ1",1,FWxFilial("SZ1")+SF2->F2_CLIENTE+SF2->F2_LOJA+posicione('SC5',1,FWxFilial('SC5')+posicione('SD2',1,SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,'D2_PEDIDO'),'C5_X_ENTR'),'Z1_CEP'))
!Empty(Alltrim(posicione('SC5',1,FWxFilial('SC5')+posicione('SD2',1,SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,'D2_PEDIDO'),'C5_X_ENTR')))                                                                                                                                                                              

