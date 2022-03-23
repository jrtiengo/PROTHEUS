#include 'protheus.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SF1100E � Autor � Jorge Alberto       � Data � 10/10/2017  ���
�������������������������������������������������������������������������͹��
���Descricao � PE Este ponto de entrada pertence � exclusao da Nota Fiscal���
���          � de Entrada.                                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Marcher                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function SF1100E()

	Local cAreaAnt := Alias()
	Local aArea := GetArea()
	
	DbSelectArea("SZ2")
	DbSetOrder(3)

	If SZ2->( DbSeek( xFilial("SZ2") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )

		// Chama a rotina para alterar a Entrega T�cnica com a Situa��o 4 - Excluida NF Entrada
		If ! U_MA020ALT( SZ2->Z2_NUMERO,,,,"5" )
			
			MsgInfo( "N�o foi alterada a Situa��o da Entrega T�cnica, a altera��o dever� ser feita manualmente ! ", "Comiss�o de Revenda" )
		EndIf

	EndIf
	
	RestArea( aArea )
	dbSelectArea( cAreaAnt )
	
Return