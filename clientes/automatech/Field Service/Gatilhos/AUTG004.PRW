#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AUTG004    �Autor  �Samuel Schneider  � Data �  13/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava o numero da etiqueta no campo AB9_ETIQUE    		  ���
���          � 															  ���
���          �   														  ���
���          �  														  ���
���          �              											  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus / Automatech                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AUTG004()

Local _cOs     := Left( M->AB9_NUMOS, 6 )  
Local _cEtique := " "
Local cQuery   := " "
Local _aArea1  := GetArea()
Local _aArea2  := AB6->( GetArea() )


cQuery := " SELECT AB6.AB6_ETIQUE, AB6.AB6_NUMOS FROM "+RetSqlName("AB6")+" AB6(NOLOCK) "
cQuery += " WHERE AB6.AB6_NUMOS = '"+ _cOS +"' AND AB6.AB6_FILIAL = '"+ xFilial("AB6") +"' "
cQuery += " AND AB6.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery( cQuery )
Iif( Select("T_AB6") > 0, T_AB6->( dbCloseArea() ), )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_AB6",.T.,.T.)
	
DbSelectArea("T_AB6")
DbGoTop()

	_cEtique := T_AB6->AB6_ETIQUE

RestArea( _aArea2 )
RestArea( _aArea1 )	   
	   
Return(_cEtique)