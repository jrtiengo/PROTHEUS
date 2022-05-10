#include "Totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SCI99B � Autor � Ednei Silva          � Data � 29/06/2017 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �  Tela para a configuracao dos parametros customizados      ���
���          �  do processo de Workflow do Compras e Solicitacao de Comp. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Internacional                           ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function SCI99B()

	Local oPanel
	Local oDlg
	Local cHtmlC 		:= PadR( GetMV("ES_WFHTMLC"), 30 )
	Local cHtmlS		:= PadR( GetMV("ES_WFHTMLS"), 30 )
	Local cHtmlEmail	:= PadR( GetMV("ES_WFLHTML"), 30 )
	Local cWfLink		:= PadR( GetMV("ES_WFLINK"),  50 )
	Local cWfTitSC	    := PadR( GetMV("ES_WFTITSC"), 70 )
	Local cWfTitPC	    := PadR( GetMV("ES_WFTITPC"), 70 )
	
	Local bProcess

	DEFINE MSDIALOG oDlg TITLE "Parametros Workflow Zenvia" FROM 001,001 TO 428,280 PIXEL
	@ 005,005 TO 210,138 Label "" PIXEL OF oPanel
	
	@ 010,010 Say "Arquivo Modelo Compras:"										    OF oDlg PIXEL
	@ 020,010 MSGET oHtmlC VAR cHtmlC VALID SCI99BARQ(cHtmlC,1) SIZE 120,010			OF oDlg PIXEL
	     
	@ 040,010 Say "Arquivo Modelo Solicita��o de Compras:"							OF oDlg PIXEL
	@ 050,010 MSGET oHtmlS VAR cHtmlS VALID SCI99BARQ(cHtmlS,2) SIZE 120,010			OF oDlg PIXEL
	    
	@ 070,010 Say "Arquivo Modelo Corpo do E-mail:"  								OF oDlg PIXEL
	@ 080,010 MSGET oHtmlEmail VAR cHtmlEmail VALID SCI99BARQ(cHtmlEmail,3) SIZE 120,010	OF oDlg PIXEL
	
	@ 100,010 Say "Endere�o web do diret�rio do Workflow:"							OF oDlg PIXEL
	@ 110,010 MSGET oWfLink VAR cWfLink SIZE 120,010								OF oDlg PIXEL	
	
	@ 130,010 Say "Titulo do Assunto do e-mail da Solic. Compra:"					OF oDlg PIXEL
	@ 140,010 MSGET oWfTitSC VAR cWfTitSC SIZE 120,010								OF oDlg PIXEL

	@ 160,010 Say "Titulo do Assunto do e-mail do Ped. Compra:"						OF oDlg PIXEL
	@ 170,010 MSGET oWfTitPC VAR cWfTitPC SIZE 120,010								OF oDlg PIXEL	
		
	bProcess := {|| SCI99BSALVPAR( cHtmlC,cHtmlS,cHtmlEmail,cWfLink,cWfTitSC,cWfTitPC ), oDlg:End()  }
	     
	@ 190,020 BUTTON "&Salvar"	SIZE 38,12 PIXEL ACTION( Eval( bProcess ) )	OF oDlg PIXEL   
	@ 190,080 BUTTON "S&air"	SIZE 38,12 PIXEL ACTION( oDlg:End() )		OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SCI99BSALVPAR �Autor  � Ednei Silva  � Data     � 29/06/2017 ���
�������������������������������������������������������������������������͹��
�� Descricao � Funcao para salvar os parametros na tabela de parametros   ���
��           �                                                            ���
�������������������������������������������������������������������������͹��
��Retorno    �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Internacial                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function SCI99BSALVPAR(cHtmlC,cHtmlS,cHtmlEmail,cWfLink,cWfTitSC,cWfTitPC)

	If MsgYesNo("Deseja salvar os parametros?")
	
		PutMV( "ES_WFHTMLC"	, AllTrim( cHtmlC ) )
		PutMV( "ES_WFHTMLS"	, AllTrim( cHtmlS ) )
		PutMV( "ES_WFLHTML"	, AllTrim( cHtmlEmail ) )
		PutMV( "ES_WFLINK"	, AllTrim( cWfLink ) )
		PutMV( "ES_WFTITPC" , AllTrim( cWfTitPC ) )
		PutMV( "ES_WFTITSC" , AllTrim( cWfTitSC ) )
		
	EndIf	

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SCI99BARQ �  Autor  �  Ednei Silva      � Data �  29/06/2017 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para verificar o caminho do arquivo                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � SCI99BARQ(cExp,nopc)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cNomArq = Caminho fisico do arquivo HTML                   ���
���          � nOpc = Informa de qual campo foi chamada a funcao          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Internacional                           ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function SCI99BARQ( cNomArq,nOpc )

	Local lOK := .T.

	If !File( cNomArq ) 
	
		Do Case
			Case nOpc = 1
				MsgAlert( "O arquivo Modelo do Pedido de Compras n�o foi encontrado " + CRLF + "no caminho especificado.","Arquivo Modelo" )
			Case nOpc = 2
				MsgAlert( "O arquivo Modelo da Solicita��o n�o foi encontrado " + CRLF + "no caminho especificado.","Arquivo Modelo" )
			Case nOpc = 3
				MsgAlert( "O arquivo Modelo do Corpo do e-mail n�o foi encontrado " + CRLF + "no caminho especificado.","Arquivo Modelo" )
		EndCase
		
		lOK := .F.
		
	EndIf
	
Return( lOK )