#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
Ponto de Entrada MA650FIL - Filtra o markbrowse da tela de gera��o de OP para PV
N�o permite gerar OP para item que esteja em processo de compra

Jean Rehermann | JPC - 21/09/2011
*/

User Function MA650FIL()

	Local cCond:= "C6_PCOMPRA = '      '"
	
   U_AUTOM628("PE_MA650FIL")
   
Return cCond