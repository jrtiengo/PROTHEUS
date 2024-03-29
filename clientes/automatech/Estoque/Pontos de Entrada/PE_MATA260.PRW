#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE_MATA260  �Autor  �Celso Rene         � Data �  03/07/14  ���
�������������������������������������������������������������������������͹��
���Desc.     �  PE_MATA260              . 				                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus - Automatech                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT260TOK() �Autor  �Celso Rene          � Data �  03/07/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � PE - OK na Inclusao de Transferencias                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus - Automatech                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//LOCALIZA��O : Ponto de Entrada localizado na confirma��o da Dialog na fun��o A260TudoOK.
//EM QUE PONTO :  � executada ao pressionar o bot�o da EnchoiceBar.FINALIDADE : Validar as informa��es inseridas pelo Usu�rio

User Function MT260TOK()

Local _lRet 	:= .T.
Local _cQuery	:= ""

   U_AUTOM628("PE_MATA260")

If PROCNAME(10) $ "A260INCLUI" 

	_cQuery += " SELECT AA1_CODTEC, AA1_NOMTEC, AA1_LOCAL"+ CHR(13)
	_Cquery += " FROM " + RetSqlName("AA1") + "  WITH(NOLOCK) " + CHR(13)
	_Cquery += " WHERE AA1_LOCAL = '"+CLOCORIG+"' OR AA1_LOCAL = '"+CLOCDEST+"' " 
   
	If( Select( "TMPAA1" ) <> 0 )
		TMPAA1->( DbCloseArea() )
	EndIf

	TcQuery _cQuery New Alias "TMPAA1"
    /*
	If !TMPAA1->( EOF() )
		MsgAlert("N�o � poss�vel realizar transfer�ncias para Armazens de T�nicos.","Armazem de T�cnicos")
		TMPAA1->( DBCloseArea() )
		_lRet:=	 .F.
	EndIf      
	  */
EndIf

Return(_lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA260EST �Autor  �Celso Rene         � Data �  03/07/14     ���
�������������������������������������������������������������������������͹��
���Desc.     �  PE - OK no Estorno de Transferencias                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus - Automatech                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//LOCALIZA��O : Function MTA260OK() - Respons�vel pela Confirmacao antes de executar o estorno. 
//EM QUE PONTO : Ponto de entrada para validar se pode efetuar o estorno da transferencia ou nao .


User Function MA260EST()

Local _lRet 	:= .T.
Local _cQuery	:= ""

If PROCNAME(10) $ "A260ESTORN" 

	_cQuery += " SELECT AA1_CODTEC, AA1_NOMTEC, AA1_LOCAL"+ CHR(13)
	_Cquery += " FROM " + RetSqlName("AA1") + "  WITH(NOLOCK) " + CHR(13)
	_Cquery += " WHERE AA1_LOCAL = '"+CLOCORIG+"' OR AA1_LOCAL = '"+CLOCDEST+"' " 
   
	If( Select( "TMPAA1" ) <> 0 )
		TMPAA1->( DbCloseArea() )
	EndIf

	TcQuery _cQuery New Alias "TMPAA1"

/*	If !TMPAA1->( EOF() )
		MsgAlert("N�o � poss�vel realizar transfer�ncias para Armazens de T�nicos.","Armazem de T�cnicos")
		TMPAA1->( DBCloseArea() )
		_lRet:=	 .F.
	EndIf      
	*/
EndIf

Return(_lRet)


