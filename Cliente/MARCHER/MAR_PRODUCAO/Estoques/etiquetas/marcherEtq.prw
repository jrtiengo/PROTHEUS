#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � marcherEtq   �Autor  � lISANDRO S     � Data �  17/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Immpress�o de etiquetas Marcher                            ���
���          � Sele��o de dados                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Marcher                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function marcherEtq()

// Variaveis Locais da Funcao
Local oProdIni
Local oProdFim
Local oQtde

// Variaveis da Funcao de Controle e GertArea/RestArea
Local _aArea   		:= {}
Local _aAlias  		:= {}
// Variaveis Private da Funcao

Private aComboBx1	 := {"USB001","LPT1","LPT2","COM1","COM2","COM3","COM4","COM5","COM6"}
Private cComboBx1
Private cProdIni	 := Space(15)
Private cProdFim	 := Space(15)
Private nQtde	 	 := 1

Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.

DEFINE MSDIALOG oDlg TITLE "Impress�o de Etiqueta com C�digo de Barras" FROM C(100),C(100) TO C(300),C(520) PIXEL

// Cria Componentes Padroes do Sistema
@ C(020),C(005) Say "Do Produto:" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
@ C(015),C(035) MsGet oProdIni Var cProdIni F3 "SB1" Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

@ C(020),C(108) Say "At� Produto:" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
@ C(015),C(136) MsGet oProdFim Var cProdFim F3 "SB1" Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

@ C(040),C(005) Say "Qtd Etiquetas:" Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
@ C(035),C(035) MsGet oQtde Var nQtde Size C(038),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg

@ C(040),C(95) Say "Porta:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
@ C(037),C(127) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg

DEFINE SBUTTON FROM C(70),C(50) TYPE 1 ENABLE OF oDlg  ACTION( ImpEtq()  )
DEFINE SBUTTON FROM C(70),C(110) TYPE 2 ENABLE OF oDlg ACTION( oDlg:end() )


ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ImpEtq       �Autor  � lISANDRO S     � Data �  17/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Immpress�o de etiquetas Marcher                            ���
���          � Sele��o de dados                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Marcher                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpEtq

Local aDados := {{nil,nil,nil}}

If nQtde <= 0
	MsgAlert("Quantidade menor ou igual a zero(0)! Verifique os parametros! ")
	Return                                                                    
EndIf

If cProdFim < cProdIni
	MsgAlert("Produto Final menor que o Produto Inicial! Verifique os parametros! " )
	Return
EndIf

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") +cProdIni )

x:=1
y:=1

While !Eof() .And. B1_Cod >= cProdIni .And. B1_Cod <= cProdFim

	//controle de c�pias
	For nI := 1 To nQtde
		
		IF y > 3
			y:=1
			x++
			aadd(aDados,{nil,nil,nil})
		EndIf
		
		aDados[x][y] :=  SB1->B1_COD
		
		y++
		
	Next
		IF y > 3
			y:=1
			x++
			aadd(aDados,{nil,nil,nil})
		EndIf
		aDados[x][y] := "0" //indica o fim da etiqueta
	DbSkip()
EndDo


If Len( aDados) > 0 	
	u_ImpArgox( aDados , cComboBx1)
	
	MsgAlert("pASSAMOS,4")
	oDlg:end()
	
EndIf


Return

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()   � Autores � Norbert/Ernani/Mansano � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//���������������������������Ŀ
//�Tratamento para tema "Flat"�
//�����������������������������
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CtrlArea � Autor �Ricardo Mansano     � Data � 18/05/2005  ���
�������������������������������������������������������������������������͹��
���Locacao   � Fab.Tradicional  �Contato � mansano@microsiga.com.br       ���
�������������������������������������������������������������������������͹��
���Descricao � Static Function auxiliar no GetArea e ResArea retornando   ���
���          � o ponteiro nos Aliases descritos na chamada da Funcao.     ���
���          � Exemplo:                                                   ���
���          � Local _aArea  := {} // Array que contera o GetArea         ���
���          � Local _aAlias := {} // Array que contera o                 ���
���          �                     // Alias(), IndexOrd(), Recno()        ���
���          �                                                            ���
���          � // Chama a Funcao como GetArea                             ���
���          � P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         ���
���          �                                                            ���
���          � // Chama a Funcao como RestArea                            ���
���          � P_CtrlArea(2,_aArea,_aAlias)                               ���
�������������������������������������������������������������������������͹��
���Parametros� nTipo   = 1=GetArea / 2=RestArea                           ���
���          � _aArea  = Array passado por referencia que contera GetArea ���
���          � _aAlias = Array passado por referencia que contera         ���
���          �           {Alias(), IndexOrd(), Recno()}                   ���
���          � _aArqs  = Array com Aliases que se deseja Salvar o GetArea ���
�������������������������������������������������������������������������͹��
���Aplicacao � Generica.                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)
Local _nN
// Tipo 1 = GetArea()

If _nTipo == 1
	_aArea   := GetArea()
	For _nN  := 1 To Len(_aArqs)
		DbSelectArea(_aArqs[_nN])
		AAdd(_aAlias,{ Alias(), IndexOrd(), Recno()})
	Next
	// Tipo 2 = RestArea()
Else
	For _nN := 1 To Len(_aAlias)
		DbSelectArea(_aAlias[_nN,1])
		DbSetOrder(_aAlias[_nN,2])
		DbGoto(_aAlias[_nN,3])
	Next
	RestArea(_aArea)
Endif
Return Nil
