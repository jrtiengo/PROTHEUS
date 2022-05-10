#include "Totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SCIA070 � Autor � Denis Rodrigues      � Data � 20/10/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Browse de Controle de Etiquetas Holograficas somente para  ���
���          � Consulta                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � U_SCIA070()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente S.C Internacional                       ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function SCIA070()

	Private cCadastro := "Controle de Etiquetas Hologr�ficas"
	Private aRotina   := MenuDef()//O MenuDef serve para exibir a rotina na tela maior do Protheus
	Private aCores    := {}
						
	aAdd( aCores,{ '(SZ0->Z0_STATUS = "A")' ,'BR_VERDE'   })
	aAdd( aCores,{ '(SZ0->Z0_STATUS = "E")' ,'BR_VERMELHO'})	
						
	dbSelectArea("SZ0")
	mBrowse( 6,1,22,75,"SZ0",,,,,,aCores )
	
Return

/*
+---------------+
|Menu do mBrowse|
+---------------+*/
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina,{ "Pesquisar"  ,"AxPesqui"	 , 0, 1} )
	aAdd( aRotina,{ "Visualizar" ,"AxVisual"	 , 0, 2} )
	aAdd( aRotina,{ "Legenda" 	  ,"U_A070LG"	 , 0, 6} )

Return( aRotina )


/*
+------------------+
|Legenda do mBRowse|
+------------------+*/
User Function A070LG()

	BrwLegenda( cCadastro,"Legenda",{{"BR_VERDE" 	,"Lanc. Aberto"},;
										      {"BR_VERMELHO"	,"Lanc. Encerrado"}} )

Return
