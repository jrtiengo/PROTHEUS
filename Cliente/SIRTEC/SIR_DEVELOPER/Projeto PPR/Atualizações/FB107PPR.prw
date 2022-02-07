#Include 'Totvs.ch'
#Include 'Rwmake.ch'
#Include 'TopConn.ch'

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � FB107PPR � Autor � Felipe S. Raota             � Data � 24/07/14  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Gera��o de verba 178(PPR) na folha de pagamento.                  ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para cliente Sirtec - Projeto PPR                      ���
��������������������������������������������������������������������������������Ĵ��
���Analista  �  Data  � Manutencao Efetuada                                      ���
��������������������������������������������������������������������������������Ĵ��
���          �  /  /  �                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function FB107PPR(cCalc)

Local oDlg, oSay1, oSay2, oSay3, oSay4, oSay5, oTGet, oTGet2, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local aColsZD  := {}
Local aYesAlt  := {"ZD_TOTAL"}
Local aYesCmp  := {"ZD_MAT", "ZD_NOME", "ZD_TOTPOS", "ZD_TOTNEG", "ZD_TOTAL"}
Local aSizeAut := MsAdvSize()

Local oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Arial",,22,,.T.,,,,,.F. )

Local lMenu := .F.

Private _oSayTot := NIL
Private _cCalc := cCalc
Private oGDValFix
Private aHeadZD  := {}

Private _aPosObj := {{002,002,499,030},; // TPanel 1
					 {034,002,499,226},; // TPanel 2
					 {245,002,499,014},; // TPanel 3
					 {002,002,497,209}}  // MsNewGetDados

dbSelectArea("SZD")
SZD->(dbSetOrder(1))

aHeadZD := U_GeraHead("SZD",.T.,,aYesCmp,.T.)

DEFINE MSDIALOG oDlg TITLE "Pagamento PPR"  From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	_GerCols(@aColsZD)
	
	// Painel 1
	oPane1 := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	_oSayTot 	:= TSay():New(012,010,{|| "Total PPR: 0.00" },oPane1,,oFont22N,,,,.T.,CLR_RED,CLR_RED,200,10)
	
	// Painel 2
	oPane2  := TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	    
	oGDValFix := MsNewGetDados():New(_aPosObj[4,1],_aPosObj[4,2],_aPosObj[4,4],_aPosObj[4,3],GD_UPDATE+GD_DELETE,"U_107PPRLOK()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,"U_107PPRDOK()",oPane2,aHeadZD,aColsZD)
	
	// Painel 3
	oPane3 	:= TPanel():New(_aPosObj[3,1],_aPosObj[3,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[3,3],_aPosObj[3,4],.F.,.F.)
	
	oTButton1 	:= TButton():New( 02, 010, "&Gerar Verba", oPane3,{|| _GrvVFix() },60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 	:= TButton():New( 02, 450, "&Fechar", oPane3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	_CalcTot(aColsZD)
	
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _GerCols   � Autor � Felipe S. Raota            � Data � 24/07/14 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Gera linhas do aCols para a grid.                                 ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB009PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _GerCols(aC)

Local cQry := ""
Local lDel := .F.

dbSelectArea("SRA")
SRA->(dbSetOrder(1))

If Select("TRB") > 0
	TRB->(dbCloseArea())
Endif

cQry := " SELECT SZD.ZD_MAT, SZD.ZD_NOME, SUM(SZD.ZD_TOTPOS) as ZD_TOTPOS, SUM(SZD.ZD_TOTNEG) as ZD_TOTNEG, SUM(SZD.ZD_TOTAL) as ZD_TOTAL "
cQry += " FROM "+RetSqlName("SZD")+" SZD "
cQry += " WHERE " + RetSqlCond("SZD")
cQry += "   AND SZD.ZD_CODCALC = '"+_cCalc+"' "
cQry += " GROUP BY SZD.ZD_MAT, SZD.ZD_NOME "
cQry += " ORDER BY SZD.ZD_MAT "

cQry := ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TRB", .F., .T.) 

If !TRB->(EoF())

	aC := {}
	
	While !TRB->(EoF()) 
		
		lDel := .F.
		
		//*************************************
		//Valida��es de deleta ou n�o registro
		//*************************************
		
		//Valor zerado
		If TRB->ZD_TOTAL == 0
			lDel := .T.
		Endif
		
		aADD(aC, {TRB->ZD_MAT, TRB->ZD_NOME, TRB->ZD_TOTPOS, TRB->ZD_TOTNEG, TRB->ZD_TOTAL, lDel})
		
		TRB->(dbSkip())
	Enddo
	
Else
	aC := {}
	aADD(aC, U_LinVazia(aHeadZD))
Endif

TRB->(dbCloseArea())

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _CalcTot   � Autor � Felipe S. Raota            � Data � 24/07/14 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula total da grid.                                            ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB107PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _CalcTot(aC)

local nTot := 0

For _x:=1 to len(aC)
	If !GdDeleted(_x, aHeadZD, aC)
		nTot += GDFieldGet( "ZD_TOTAL", _x, .F., aHeadZD, aC )
	Endif
Next

_oSayTot:SetText("Total PPR: R$ " + Transform(nTot,"@E 999,999,999.99"))

Return nTot

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � 107PPRLOK  � Autor � Felipe S. Raota            � Data � 24/07/14 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida linha.                                                     ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB107PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function 107PPRLOK()

_CalcTot(oGDValFix:aCols)

Return .T.

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � 107PPRDOK  � Autor � Felipe S. Raota            � Data � 24/07/14 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida dele��o da linha.                                          ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB107PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function 107PPRDOK()

_CalcTot(oGDValFix:aCols)

Return .T.


/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _GrvVFix   � Autor � Felipe S. Raota            � Data � 24/07/14 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua grava��o dos dados.                                        ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB107PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _GrvVFix()

Local cVerbas := Alltrim(GetMV("FS_VERBPPR"))
Local aVerbas := StrTokArr (cVerbas, ";")

_aC := oGDValFix:aCols

dbSelectArea("SRC")
SRC->(dbSetOrder(1))

For _x:=1 to len(_aC)
	
	If !GdDeleted(_x, aHeadZD, _aC)
		
		For _y:=1 to len(aVerbas)
			
			If !Empty(aVerbas[_y])
			
				RecLock("SRC", .T.)
					SRC->RC_FILIAL := xFilial("SRC")
					SRC->RC_MAT    := GDFieldGet( "ZD_MAT",  _x, .F., aHeadZD, _aC )
					SRC->RC_PD     := aVerbas[_y]
					SRC->RC_TIPO1  := "V"
					SRC->RC_VALOR  := GDFieldGet( "ZD_TOTAL", _x, .F., aHeadZD, _aC )
					SRC->RC_CC     := fBuscaCPO("SRA", 1, xFilial("SRA") + GDFieldGet( "ZD_MAT",  _x, .F., aHeadZD, _aC ), "RA_CC")
					SRC->RC_TIPO2  := "I"
				MsUnLock()
			
			Endif
		
		Next _y
		
	Endif
	
Next

MsgInfo("Registros gerados para a verba de PPR.")

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _CleanScr  � Autor � Felipe S. Raota            � Data � 11/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua grava��o dos dados.                                        ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB009PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _CleanScr(oSay2, oSay4, oTGet, oTGet2)

// Grupo PPR
cCodGrp := Space(6)
oTGet:SetText(cCodGrp)

oSay2:SetText(Space(80))
oSay2:CtrlRefresh()

// Indicador
cCodInd := Space(6)
oTGet2:SetText(cCodInd)

oSay4:SetText(Space(80))
oSay4:CtrlRefresh()

aColsZD := {}
aADD(aColsZD, U_LinVazia(aHeadZD))
_GetDadHab(aColsZD, .F.)

Return