#INCLUDE "protheus.ch"
/*
Fun��o MT500APO
Jean Rehermann | SOLUTIO - 18/01/2012 - Ponto de entrada na elimina��o de res�duos do pedido de vendas
Este ponto de entrada � executado para cada item do pedido de vendas.
*/
User Function MT500APO()

	Local _aArea := GetArea()
	Local _lLock := .F.

    U_AUTOM628("PE_MT500APO")

	_lLock := RLock( SC6->( Recno() ) )
	   
	reclock("SC6",.F.)
	
	SC6->C6_STATUS := "14"  // Gravo novo status no item "14 - Pedido Cancelado (eliminado res�duos)"

    MSUNLOCK()

	U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "14", "PE_MT500APO") // Gravo o log de atualiza��o de status na tabela ZZ0
	
	If _lLock
		MsUnLock()
	EndIf
	
	RestArea( _aArea )

Return