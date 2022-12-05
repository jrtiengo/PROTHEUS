#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �AT450GRV  �Autor  �Microsiga           � Data �  05/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AT460GRV()
 // nOpcao    : [3] Exclusao [1] Inclusao [2] Alteracao 
 
If AB9->AB9_TIPO == '1' // 1=Encerrado; 2= Aberto
                                                  

	BEGIN TRANSACTION

		cQuery := "UPDATE " + RetSqlName("AB9")
		cQuery += " SET 	AB9_TIPO   	 = 	'1' 			   		"+ENTER
		cQuery += " WHERE 	AB9_FILIAL 	 =	'"+xFilial('AB9')+"' 	"+ENTER
		cQuery += " AND	    AB9_NUMOS    = 	'"+AB9->AB9_NUMOS+"'	"+ENTER
		cQuery += " AND		D_E_L_E_T_	!=	'*'		   				"+ENTER
		
		nErro := TcSqlExec(cQuery)
		
		If nErro != 0
			Alert('Problema na atualiza��o da tabela - AB9'+ENTER+'Entre em contato com o Administrador!!!')
			DisarmTransaction()
		EndIf

	END TRANSACTION
	
EndIf

Return()