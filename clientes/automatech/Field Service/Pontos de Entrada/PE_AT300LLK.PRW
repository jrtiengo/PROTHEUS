/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AT300LLK  �Autor  �Samuel Schneider    � Data �  11/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa que n�o permite a inclusao de mais um chamado     ���
���          � na rotina de chamado Tecnico                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION AT300LLK()

   Local _lret := .t.         

   Local _Ocorrencia := aScan(aHeader,{|x| AllTrim(x[2])=="AB2_CODPRB"})

   IF n = 1 .and. procname(6) <> "TUDOOK" 
      _lret := .f.
      MsgAlert("N�o � Permitido incluir mais de um equipamento por chamado.")	
   ENDIF	

   // Verifica se a ocorr�ncia est� em branco.
   // Este teste � necess�rio pois mesmo o campo estando como obrigat�rio, ao confirmar com ocorr�ncia em branco, o Sistema deixa gravar
   If Empty(Alltrim(aCols[1,_Ocorrencia]))
      _lret := .f.
      MsgAlert("Ocorr�ncia n�o informada. Verifique!")
   Endif
                                                                 
RETURN _lRet