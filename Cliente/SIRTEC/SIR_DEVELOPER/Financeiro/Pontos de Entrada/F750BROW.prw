#INCLUDE "rwmake.ch"                    

#DEFINE STR0001 "SIRTEC - F750BROW"
#DEFINE STR0002 "Rotina n�o est� liberada para esse usu�rio. Para efetuar a libera��o deste usu�rio, altere o parametro MV_YLIBPG."
#DEFINE STR0003 "N�o existe nenhum usu�rio liberado para utilizar a rotina LIBERACAO PARA PAGAMENTO. Para efetuar a libera��o, altere o parametro MV_YLIBPG."
#DEFINE STR0004 "Existe diverg�ncia entre a variavel nPadrao e a posi��o do bot�o Lib. Pagto."

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F750BROW  � Autor � RAFAEL COSTA LEITE � Data �  12/02/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

/*

==>>> ATENCAO ESSE PONTO DE ENTRADA DEVE SER TESTADO SEMPRE QUE OUVER ATUALIZA��O DO RPO <<<===

*/
User Function F750BROW

	Private MV_YLIBPG	:= GetMv("MV_YLIBPG") 
	Private nPadrao		:= Ascan(aRotina, { |x| x[1] == "Lib p/Pagto" })
	
	//Testa variaveis
	//Verifica se o par�metro est� em branco.
	If Empty(MV_YLIBPG)
		
		//Informa que o par�metro est� em branco, apenas informativo.
		MsgInfo(STR0003,STR0001)
		
	Elseif nPadrao == 0
	    
		//Informa que existe diverg�ncia entre a posi��o do bot�o "Lib. Pagto" e a variavel nPadrao
		MsgStop(STR0004,STR0001)   	   
		Return
	
	Endif 	
	
	//Verifica se o usu�rio est� liberado.
	If ! (__CUSERID $ MV_YLIBPG) .or. Empty(MV_YLIBPG)
	
		//Se o usu�rio n�o estiver liberado, retira a rotina de libera��o.
		aRotina[nPadrao][2][1][2] := aRotina[2][2]  
		aRotina[nPadrao][2][2][2] := aRotina[2][2]  
		aRotina[nPadrao][2][3][2] := aRotina[2][2] 
	Endif
Return