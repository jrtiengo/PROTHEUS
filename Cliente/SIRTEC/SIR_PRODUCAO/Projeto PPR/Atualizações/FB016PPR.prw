#Include 'Totvs.ch'
#Include 'Rwmake.ch'

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � FB016PPR � Autor � Felipe S. Raota             � Data � 10/07/14  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de Faturamento por Regi�o.                               ���
���          � Utilizado para controle de Base de C�lculo de Coordenadores Reg.  ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para cliente Sirtec - Projeto PPR                      ���
��������������������������������������������������������������������������������Ĵ��
���Analista  �  Data  � Manutencao Efetuada                                      ���
��������������������������������������������������������������������������������Ĵ��
���          �  /  /  �                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function FB016PPR()

Local oDlg, oSay1, oSay2, oSay3, oSay4, oSay5, oTGet, oTGet2, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local aColsZL  := {}
Local aYesAlt  := {}
Local aYesCmp  := {}
Local aSizeAut := MsAdvSize()

Local oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Arial",,22,,.T.,,,,,.F. )

Local aTipos := {}

Local cDescTel := ""

Private oCombo := NIL

Private oGDVarM
Private aHeadZL  := {}

Private _aPosObj := {{002,002,499,030},; // TPanel 1
					 {034,002,499,226},; // TPanel 2
					 {245,002,499,014},; // TPanel 3
					 {002,002,497,209}}  // MsNewGetDados

Private cMesAno  := Space(7)
Private cTipo    := Space(1)

dbSelectArea("SZP")

aYesAlt  := {"ZP_MAT", "ZP_VAL"}
aYesCmp  := {"ZP_MAT", "ZP_NOME", "ZP_VAL"}
aTipos   := {"","Faturamento"}
cTitle   := "Cadastro de Valores por Regi�o"

SZP->(dbSetOrder(1))

aHeadZL := U_GeraHead("SZP",.T.,,aYesCmp,.T.)

DEFINE MSDIALOG oDlg TITLE cTitle  From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	// Painel 1
	oPane1 := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	oSay1  := TSay():New(003,002,{||"M�s/Ano: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet  := TGet():New(002,040,{|u| If(Pcount()>0,(cMesAno:=u,_GerCols(@aColsZL)),cMesAno) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| .T. },.F.,.F.,,cMesAno,,,, )
	
	//oSay3  := TSay():New(018,002,{||"Tipo: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	//oCombo := TComboBox():New(017,040,{|u|if(PCount()>0,(cTipo:=u,_GerCols(@aColsZL)),cTipo)},aTipos,80,45,oPane1,,{|| },,,,.T.,oFont14,,,{|| "" },,,,,'cTipo')
	
	cDescTel := "_Valores por Regi�o_"
	
	oSay5  := TSay():New(012,350,{|| cDescTel },oPane1,,oFont22N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	
	// Painel 2
	oPane2  := TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	
	oGDVarM := MsNewGetDados():New(_aPosObj[4,1],_aPosObj[4,2],_aPosObj[4,4],_aPosObj[4,3],GD_UPDATE+GD_INSERT+GD_DELETE,"U_016PPRLOK()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane2,aHeadZL,aColsZL)
	oGDVarM:Disable() 
	
	// Painel 3
	oPane3 	:= TPanel():New(_aPosObj[3,1],_aPosObj[3,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[3,3],_aPosObj[3,4],.F.,.F.)
	
	oTButton1 	:= TButton():New( 02, 010, "&Gravar", oPane3,{|| _GrvVMet(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 	:= TButton():New( 02, 055, "&Limpar", oPane3,{|| _CleanScr(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTButton3 	:= TButton():New( 02, 450, "&Fechar", oPane3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _GerCols   � Autor � Felipe S. Raota            � Data � 10/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Gera linhas do aCols para a grid.                                 ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB006PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _GerCols(aC)

If !Empty(cMesAno)
	
	If SZP->(MsSeek( xFilial("SZP") + cMesAno ))
		
		aC := {}
		
		While SZP->(!EoF()) .AND. xFilial("SZP") + cMesAno == SZP->ZP_FILIAL + SZP->ZP_MESANO
			
			_cDescMat := fBuscaCPO("SRA", 1, xFilial("SRA") + SZP->ZP_MAT, "RA_NOME")
			aADD(aC, {SZP->ZP_MAT, _cDescMat, SZP->ZP_VAL, .F.})
			
			SZP->(dbSkip())
		Enddo
		
		If len(aC) == 0
			aADD(aC, U_LinVazia(aHeadZL))
		Endif
		
		_GetDadHab(aC, .T.)
		
	Else
		aC := {}
		aADD(aC, U_LinVazia(aHeadZL))
		
		_GetDadHab(aC, .T.)
	Endif

Else
	aC := {}
	
	// Valida��o pode ser executada antes de criar o objeto.
	If TYPE("oGDVarM") == "O"
		oGDVarM:Disable()
	Endif
	
Endif

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � 016PPRLOK  � Autor � Felipe S. Raota            � Data � 30/04/14 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida linha do aCols.                                            ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB015PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function 016PPRLOK() 

Local aAux := oGDVarM:aCols
Local lOk  := .T.

// Valida��es

Return lOk

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _015TOK    � Autor � Felipe S. Raota            � Data � 10/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida aCols completo.                                            ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB015PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _015TOK()

Local lOk   := .T.

/*
For _y:=1 to len(aAux2)
	
	If !GdDeleted(_y, aHeadZL, aAux2)
		
		//....
		
	Endif
	
Next
*/

Return lOk

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _GrvVMet    � Autor � Felipe S. Raota           � Data � 30/04/14 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua grava��o dos dados.                                        ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB015PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _GrvVMet(oSay2, oSay4, oTGet, oTGet2)

_aC := oGDVarM:aCols

If _015TOK()
	
	If SZP->(MsSeek( xFilial("SZP") + cMesAno ))
		
		While SZP->(!EoF()) .AND. xFilial("SZP") + cMesAno == SZP->ZP_FILIAL + SZP->ZP_MESANO
			
			RecLock("SZP", .F.)
				SZP->(dbDelete())
			MsUnLock()
			
			SZP->(dbSkip())
		Enddo
		
	Endif
	
	For _x:=1 to len(_aC)
		
		If !GdDeleted(_x, aHeadZL, _aC)
			
			RecLock("SZP", .T.)
				
				SZP->ZP_FILIAL  := xFilial("SZP")
				SZP->ZP_MESANO  := cMesAno
				SZP->ZP_MAT     := GDFieldGet( "ZP_MAT", _x, .F., aHeadZL, _aC )
				SZP->ZP_VAL     := GDFieldGet( "ZP_VAL", _x, .F., aHeadZL, _aC )
				
			MsUnLock()
		Endif 
		
	Next
	
	// Mes/Ano
	cMesAno := Space(7)
	oTGet:SetText(cMesAno)
	
	aColsZL := {}
	aADD(aColsZL, U_LinVazia(aHeadZL))
	_GetDadHab(aColsZL, .F.)
	
	MsgInfo("Valores por regi�o, gravados com sucesso.")
	
Endif

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _CleanScr  � Autor � Felipe S. Raota            � Data � 10/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua grava��o dos dados.                                        ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB006PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _CleanScr(oSay2, oSay4, oTGet, oTGet2)

// Mes/Ano
cMesAno := Space(7)
oTGet:SetText(cMesAno)

aColsZL := {}
aADD(aColsZL, U_LinVazia(aHeadZL))
_GetDadHab(aColsZL, .F.)

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _GetDadHab � Autor � Felipe S. Raota            � Data � 10/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Habilita ou Desabilita GetDados                                   ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB006PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _GetDadHab(aC, lHab)

aColsZL := aC
oGDVarM:aCols := aColsZL
oGDVarM:ForceRefresh()

If lHab
	oGDVarM:Enable()
Else
	oGDVarM:Disable()
Endif

Return
