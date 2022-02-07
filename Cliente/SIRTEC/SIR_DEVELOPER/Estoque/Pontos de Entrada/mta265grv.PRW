/*
 * Ponto de entrada após a alteração 
 */

user function MTA265GRV()    

_cProd := M->DA_PRODUTO
cPerg := PADR("FB102EST", LEN(SX1->X1_GRUPO)," ")   

If MsgYesNo("Deseja imprimir as etiquetas ?")
	// 1 - Grupo de perguntas a atualizar
	// 2 - Codigo (ordem) da pergunta
	// 3 - Dado a ser gravado
	U_GravaSX1 (cPerg, "01", _cProd)
	U_GravaSX1 (cPerg, "02", _cProd)	  
	U_GravaSX1 (cPerg, "03", "")
	U_GravaSX1 (cPerg, "04", "")

   U_fb102est()
Endif

return 