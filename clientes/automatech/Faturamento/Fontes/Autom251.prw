#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM251.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Michel Aoki                                                         ##
// Data......: 29/09/2014                                                          ##
// Objetivo..: Realiza a valida��o do campo tipo de opera��o no pedido de venda.   ##
// Par�metros: C�digo do Cliente                                                   ##
//             Loja do Cliente                                                     ##
//             Tipo de Pedido de Venda                                             ##
//             C�digo da Opera��o                                                  ##   
// ##################################################################################

User Function Autom251(_cCliente,_cLoja,_cTipo,_cOper) 

   Local _aArea    := GetArea()
   Local _aAreaSA1 := SA1->(GetArea())
   Local _lRet     := .t.

   U_AUTOM628("AUTOM251")
   
   If Alltrim(_cTipo) == "N"

      DbSelectArea("SA1")
  	  DbSetOrder(1)
	  
	  If DbSeek(xFilial("SA1")+_cCliente+_cLoja)

	     If Alltrim(SA1->A1_GRPTRIB) == "002" // IE ATIVO

		    If Alltrim(_cOper) =="02" // Isento
		       _lRet := .f.
		       Alert("Esta opera��o n�o pode ser selecionada para este cliente. Utilize a opera��o 03 para este cliente.")
  	        EndIf

	     ElseIf Alltrim(SA1->A1_GRPTRIB) == "003" //IE ISENTO

	   	    If Alltrim(_cOper) =="03" //Ativo
		       _lRet := .f.
		       Alert("Esta opera��o n�o pode ser selecionada para este cliente. Utilize a opera��o 02 para este cliente.")
		    EndIf

	     EndIf

	  EndIf

   EndIf

   RestArea(_aArea)
   RestArea(_aAreaSA1)

Return(_lRet)