#INCLUDE "rwmake.ch"                    

#DEFINE STR0001 "SIRTEC - F750BROW"
#DEFINE STR0002 "Rotina não está liberada para esse usuário. Para efetuar a liberação deste usuário, altere o parametro MV_YLIBPG."
#DEFINE STR0003 "Não existe nenhum usuário liberado para utilizar a rotina LIBERACAO PARA PAGAMENTO. Para efetuar a liberação, altere o parametro MV_YLIBPG."
#DEFINE STR0004 "Existe divergência entre a variavel nPadrao e a posição do botão Lib. Pagto."

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F750BROW  º Autor ³ RAFAEL COSTA LEITE º Data ³  12/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*

==>>> ATENCAO ESSE PONTO DE ENTRADA DEVE SER TESTADO SEMPRE QUE OUVER ATUALIZAÇÃO DO RPO <<<===

*/
User Function F750BROW

	Private MV_YLIBPG	:= GetMv("MV_YLIBPG") 
	Private nPadrao		:= Ascan(aRotina, { |x| x[1] == "Lib p/Pagto" })
	
	//Testa variaveis
	//Verifica se o parâmetro está em branco.
	If Empty(MV_YLIBPG)
		
		//Informa que o parâmetro está em branco, apenas informativo.
		MsgInfo(STR0003,STR0001)
		
	Elseif nPadrao == 0
	    
		//Informa que existe divergência entre a posição do botão "Lib. Pagto" e a variavel nPadrao
		MsgStop(STR0004,STR0001)   	   
		Return
	
	Endif 	
	
	//Verifica se o usuário está liberado.
	If ! (__CUSERID $ MV_YLIBPG) .or. Empty(MV_YLIBPG)
	
		//Se o usuário não estiver liberado, retira a rotina de liberação.
		aRotina[nPadrao][2][1][2] := aRotina[2][2]  
		aRotina[nPadrao][2][2][2] := aRotina[2][2]  
		aRotina[nPadrao][2][3][2] := aRotina[2][2] 
	Endif
Return