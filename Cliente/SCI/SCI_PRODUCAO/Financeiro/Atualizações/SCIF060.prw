#Include 'rwmake.ch'
/*
�����������������������������������������������������������������������������
���Programa  �SCIF060   �Autor  �Microsiga           � Data �  05/10/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para sugerir banco ficticio quando PA prestacao contas��
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�����������������������������������������������������������������������������
*/
User Function SCIF060()

If M->E2_TPPA $ '1/2' //(1=Presta��o de Contas;2=Ressarcimento)
	cBancoAdt	:= Padr(  SuperGetMv("ES_BCOPA",.F.,"FIC"), TamSX3("A6_COD")[01] )
	cAgenciaAdt	:= Padr(  SuperGetMv("ES_AGEPA",.F.,"FIC  ") , TamSX3("A6_AGENCIA")[01] )                            
	cNumCon	 	:= Padr(  SuperGetMv("ES_CONPA",.F.,"FIC       ") , TamSX3("A6_NUMCON")[01] )    

	//Sempre dever� deixar como N�o
	mv_par05 := 2 //-- Gera Chq. para Adiantamento == Nao
	mv_par09 := 2  //-- Somente gera movimento apos geracao do cheque
	
EndIf




Return(.T.)