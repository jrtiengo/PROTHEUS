#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
                                                                              
//Ponto de Entrada para manipulacão do saldo 

User Function A650SLDPV()


Local _nQtdPV := PARAMIXB[1] //Saldo do Pedido de Venda
Local nRet    := 0

 


 cQuery := " select sum (B2_QATU - B2_RESERVA) soma FROM "+RetSqlName("SB2")+" WHERE D_E_L_E_T_ =' ' "
 cQuery += " AND B2_COD ='"+SC6->C6_PRODUTO+"' "

 TCQUERY cQuery NEW ALIAS 'QRY'
 DbSelectArea('QRY')
 nRet :=   (_nQtdPV - QRY->soma )
 DbCloseArea('QRY')

//  Tratamento do usuario


Return(nRet)
