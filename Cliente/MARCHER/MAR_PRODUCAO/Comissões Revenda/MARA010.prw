#include 'protheus.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MARA010  � Autor � Jorge Alberto      � Data � 10/10/2017  ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Fretes personalizados.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Marcher                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MARA010()

	Private cCadastro := "Cadastro de Fretes Marcher"
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
			             {"Visualizar","AxVisual",0,2} ,;
			             {"Incluir","AxInclui",0,3} ,;
			             {"Alterar","AxAltera",0,4} ,;
			             {"Excluir","AxDeleta",0,5} }
	
	Private cDelFunc := ".T."
	Private cString := "SZ1"
		
	dbSelectArea("SZ1")
	dbSetOrder(1)
	
	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString)
	
Return
