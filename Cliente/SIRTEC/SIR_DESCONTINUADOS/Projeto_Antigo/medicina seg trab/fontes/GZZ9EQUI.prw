#Include "rwmake.ch"
#Include "topconn.ch"
#Include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GZZ9EQUI  �Autor  �Ezequiel Pianegonda � Data �  14/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ajuste do status de em uso para aguardando devolucao        ���
���          �dos itens do ecp                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function GZZ9EQUI()
Local nX:= 0

//verifico se existe algum produto acima do atual em uso e altero para aguardando devolucao
For nX:= n-1 To 1 Step -1
	//verifica se a linha nao esta deletada
	If !gdDeleted(nX)
		//se forem o mesmo produto
		If gdFieldGet("ZZ9_CODEPC", nX)+gdFieldGet("ZZ9_EQUIPE", nX) == gdFieldGet("ZZ9_CODEPC", n)+M->ZZ9_EQUIPE
			//se for motivo igual a 1 - Em Uso, troco por 2 - Aguardando Devolucao
			If gdFieldGet("ZZ9_DEV", nX) == '1'
				//ajusto no browser
				gdFieldPut("ZZ9_DEV", "2", nX)				
			EndIf
		EndIf
	EndIf
Next nX
Return .T.