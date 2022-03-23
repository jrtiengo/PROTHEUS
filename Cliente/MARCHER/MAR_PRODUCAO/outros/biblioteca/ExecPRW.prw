#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ExecPRW   � Autor �MarquiQuevedoBorges    � Data �23/12/2009���
�������������������������������������������������������������������������Ĵ��
���Locacao   �                  �Contato �                                ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Executa Rotinas sem precisar criar Menu                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Aplicacao � Usado para testes de programas                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  �                                               ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �                                               ���
���              �  /  /  �                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function ExecPRW
                                


//����������������������������������������Ŀ
//�Declara��o de cVariable dos componentes �
//������������������������������������������
LOCAL bRefresh   := { || uValid(cRotina) }
LOCAL cValid     := "{|| Eval(bRefresh) }"
Private cRotina    := Space(25)

//���������������������������������������������Ŀ
//� Declara��o de Variaveis Private dos Objetos �
//�����������������������������������������������

SetPrvt("oDlg1","oSay1","oGet1","oSBtn1","oSBtn2")


//�����������������������������������������������������
//�Definicao do Dialog e todos os seus componentes.   �
//�����������������������������������������������������

oDlg1      := MSDialog():New( 088,232,174,647,"Executa Rotina",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 016,008,{||"Executa Rotina:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
oGet1      := TGet():New( 016,048,{|u| If(PCount()>0,cRotina:=u,cRotina)},oDlg1,060,008,'@!',&(cValid),CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cRotina",,)
oSBtn1     := SButton():New( 016,124,1,{|| Executa(cRotina)},oDlg1,.T.,,)
oSBtn2     := SButton():New( 016,156,2,{|| oDlg1:End()},oDlg1,.T.,,)
//          	  SButton():New( 187,50 ,1,{||lRet:=.T.,oDlg:End()}, oDlg,.T.,,)

oDlg1:Activate(,,,.T.)

Return


Static Function Executa(cRotina)
Local nPosFim := 0 

//LOCAL bExec   := &( '{ || ' + cRotina }
//LOCAL cValid     := "{|| Eval(bExec) }"
	IF !Empty(cRotina)
		nPosFim := AT('(',crotina)
		If Empty(nPosFim)
			nPosFim := Len(crotina)
		Else
			nPosFim--
		Endif
		IF EXISTBLOCK(substring(crotina,1,nPosFim)) // Para rotinas de usu�rio
			EXECBLOCK(cRotina) 
		ELSEIF  FindFunction(substring(crotina,1,nPosFim))
			IF 'U_' $ UPPER(cRotina) .AND.   !( '(' $ cRotina .AND. ')' $ cRotina)
			cRotina := PADR(AllTrim(cRotina) + '()', 25)
			ENDIF
			&(cRotina)  
			
		ELSE
		MsgBox("Fun��o " + cRotina + " n�o encontrada no reposit�rio !",'Aten��o !','INFO')		
		ENDIF
	ENDIF

Return

Static Function uValid(cRotina	)

Local lReturn:= .T.

	IF !Empty(cRotina) .and. !( FindFunction(cRotina) .OR. EXISTBLOCK(crotina))
	lReturn:= .F. 
	ENDIF

	IF !lReturn
	MsgBox("Fun��o " + cRotina + " n�o encontrada no reposit�rio !",'Aten��o !','INFO')
	ENDIF


Return lReturn
