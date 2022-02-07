#Include 'Totvs.ch'

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � FB002PPR � Autor � Felipe S. Raota             � Data � 03/04/13  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de Estrutura de Grupos.                                  ���
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

User Function FB002PPR()

Local oSay, oTGet1

Private _cRef   := "001"
Private _cGet1  := Space(6)
Private _aGrupo := {}

dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))

DEFINE DIALOG oDlg TITLE "Estrutura Grupos PPR" FROM 180,180 TO 550,700 PIXEL

// Cria a Tree
oTree := DbTree():New(4,4,155,259,oDlg,,,.T.)

// Insere item principal, somente para controle
oTree:AddItem("Estrutura PPR",_cRef,"FOLDER5",,,,1)

// Busca estrutura j� cadastrada (SZ9), j� retorna o pr�ximo c�digo dispon�vel...
_cRef := _buscaDados()

_cRef := Soma1(_cRef)

oSay   := TSay():New(160,004,{|| "Informe abaixo o Grupo PPR" },oDlg,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
oTGet1 := TGet():New(171,004,{|u| if( Pcount( )>0, _cGet1:=u , _cGet1 )},oDlg,070,009,"@!",{|| Vazio() .OR. ExistCpo("SZ4") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SZ4","_cGet1",,,, )

TButton():New( 160, 080, "Adicionar", oDlg,{|| TreeNewIt() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 172, 080, "Remover",   oDlg,{|| TreeDelIt() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

TButton():New( 172, 175, "Gravar",    oDlg,{|| (GravaEstru(), oDlg:End()) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 172, 219, "Cancelar",  oDlg,{|| oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

oTree:EndTree()

ACTIVATE DIALOG oDlg CENTERED

Return                                             

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � TreeNewIt  � Autor � Felipe S. Raota            � Data � 03/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona item abaixo do componente selecionado.                   ���
���          �                                                                   ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB002PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function TreeNewIt()

Local nNiv := 0
Local cCodPai := ""
Local nPosPai := 0

If SZ4->(MsSeek( xFilial("SZ4") + _cGet1 ))
	
	If aScan(_aGrupo, { |x| x[3] == _cGet1 }) == 0
	
		If oTree:TreeSeek(oTree:GetCargo())
			
			// Busco c�digo do Grupo do Pai
			If oTree:GetCargo() <> "001"
				
				nPosPai := aScan(_aGrupo, { |x| x[4] == oTree:GetCargo() })
				
				If nPosPai <> 0
					cCodPai := _aGrupo[nPosPai,3]
				Else
					cCodPai := ""
				Endif
			Else
				cCodPai := ""
			Endif
			
			nNiv := oTree:Nivel() + 1
			
			oTree:AddItem(SZ4->Z4_DESC,_cRef,"FOLDER6",,,,nNiv)
			aADD(_aGrupo, {oTree:Nivel(), oTree:GetCargo(), _cGet1, _cRef, cCodPai})
			oTree:TreeSeek(_cRef)
			_cRef := Soma1(_cRef)
			
			_cGet1 := Space(6)
		
		Endif
	
	Else
		Alert("Componente j� adicionado na estrutura.")
	Endif

Else
	Alert("Grupo n�o encontrado, verifique.")
Endif

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � TreeDelIt  � Autor � Felipe S. Raota            � Data � 03/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Deleta componente da estrutura.                                   ���
���          �                                                                   ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB002PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function TreeDelIt()

Local cCargo := oTree:GetCargo()
Local lCont  := .T.
Local nPos   := 0

If Alltrim(cCargo) <> "001"
	
	// Busco se o componente selecionado tem filhos
	nPos := aScan(_aGrupo, { |x| x[2] == cCargo })
	
	If nPos == 0 // Posso excluir
		
		// Busco onde ele � componente
		nPos := aScan(_aGrupo, { |x| x[4] == cCargo })
		
		If nPos <> 0
			aDel(_aGrupo, nPos)
	  		aSize(_aGrupo, len(_aGrupo) - 1)
	  	Endif
	  	
		// Limpa o componente e seus filhos
		If oTree:TreeSeek(cCargo)
			oTree:DelItem()
		Endif
	  	
	Else
		Alert("Grupo selecionado possui sub-itens, s� � permitido exclus�o de componentes individuais.")
	Endif
	
Else
	Alert("Exclus�o do componente inicial n�o � permitida.")
Endif


/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � GravaEstru � Autor � Felipe S. Raota            � Data � 03/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Grava estrutura de Grupos PPR na tabela SZ9.                      ���
���          �                                                                   ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB002PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function GravaEstru()

SZ9->(dbGoTop())

While SZ9->(!EoF())
	
	RecLock("SZ9", .F.)
		SZ9->(dbDelete())
	MsUnLock()
	
	SZ9->(dbSkip())
Enddo

For _x:=1 to len(_aGrupo)
	RecLock("SZ9", .T.)
		SZ9->Z9_FILIAL := xFilial("SZ4")
		SZ9->Z9_COD    := _aGrupo[_x,5]
		SZ9->Z9_COMP   := _aGrupo[_x,3]
		SZ9->Z9_REF    := _aGrupo[_x,4]
		SZ9->Z9_NIV    := _aGrupo[_x,1] + 1
		SZ9->Z9_REFPAI := _aGrupo[_x,2]
	MsUnLock()
Next

MsgInfo("Estrutura de Grupo PPR gravada com sucesso.")

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _BuscaDados� Autor � Felipe S. Raota            � Data � 03/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Busca estrutura cadastrada na tabela SZ9.                         ���
���          �                                                                   ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB002PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _BuscaDados()

Local cRefMax := "001"

SZ9->(dbGoTop())

While SZ9->(!EoF())
	
	If SZ4->(MsSeek( xFilial("SZ4") + SZ9->Z9_COMP ))
		
		If oTree:TreeSeek(SZ9->Z9_REFPAI)
			
			// Busco c�digo do Grupo do Pai
			If SZ9->Z9_REFPAI <> "001"
				
				nPosPai := aScan(_aGrupo, { |x| x[4] == SZ9->Z9_REFPAI }) 
				
				If nPosPai <> 0
					cCodPai := _aGrupo[nPosPai,3]
				Else
					cCodPai := ""
				Endif
			Else
				cCodPai := ""
			Endif
			
			oTree:AddItem(SZ4->Z4_DESC,SZ9->Z9_REF,"FOLDER6",,,,SZ9->Z9_NIV)
			aADD(_aGrupo, {SZ9->Z9_NIV, SZ9->Z9_REFPAI, SZ9->Z9_COMP, SZ9->Z9_REF, cCodPai})
			oTree:TreeSeek(SZ9->Z9_REF)
			
			If Val(SZ9->Z9_REF) > Val(cRefMax)
				cRefMax := SZ9->Z9_REF
			Endif
		
		Endif
		
	Else
		Alert("Grupo n�o encontrado, verifique.")
	Endif
	
	SZ9->(dbSkip())
Enddo

Return cRefMax