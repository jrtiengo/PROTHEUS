#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TSTDBGRID � Autor � HELITOM SILVA      � Data �  23/04/2012 ���
�������������������������������������������������������������������������͹��
���Descricao �Exemplo de Uso da DBGRID                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Fabrica Totvs Mato Grosso                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function TSTDBGRID()

	Local nCampo		:= 0

	Private aCpoBro   := {}
	Private _cTrab
	Private tpMovim   := 4
	Private nCols     := 0

	Private aAlterGDa := {}        // Colunas a alterar.
	Private aHeader   := {}        // Cabecalho das colunas da GetDados.
	Private aCols     := {}        // Colunas da GetDados.
	Private cAlias    := 'SB1'

    /*
   ����������������������������������������������������������������������������������������ͻ
   � Cria variaveis de memoria:                                                             �
   � Para cada campo da tabela, cria uma variavel de memoria com o mesmo nome.              �
   � Estas variaveis sao usadas em validacoes e gatilhos que existirem para este arquivo.   �
   �                                                                                        �
   �	       																						   �
   �	 Campos do SB1:																			   �
   �	  ,-----------,----------,------,-------------------------------,                    �
   �	  |   Campo   |   Tipo   | Tam. |     Inicializador padrao      |                    �
   �	  |-----------|----------|------|-------------------------------|                    �
   �	1 | B1_FILIAL | Caracter |   2  |                               |				       �
   �   2 | B1_DESC   | Caracter |  20  |                               |					   �
   �	  '-----------'----------'------'-------------------------------'                    �
   �	                                                                                     �
   ����������������������������������������������������������������������������������������ͼ
	*/


	dbSelectArea(cAlias)

	For nCampo := 1 To FCount()
		cCampo := FieldName(nCampo)
		M->&(cCampo) := CriaVar(cCampo, .F.)
	Next


    /*
    ����������������������������������������������������������������������������������������ͻ
    � Carrega o Array aHeader com o cabe�alho da Grid contendo as colunas da Grid.           �
    ����������������������������������������������������������������������������������������ͼ
	*/
	CarraHeader()


    /*
    ����������������������������������������������������������������������������������������ͻ
    � Adiciona linhas com dados na Grid . Obs: Isso pode ser feito apos Instaciar a DbGrid   �
    ����������������������������������������������������������������������������������������ͼ
	*/
	CarraCols()

	//----------------------------------------------------------------------------------------------------------------//
	//Declara��o de Variaveis Private dos Objetos
	//----------------------------------------------------------------------------------------------------------------//
	SetPrvt("oDlg1","oPanel1","oDbGrid")

	//----------------------------------------------------------------------------------------------------------------//
	// Definicao do Dialog e todos os seus componentes.
	//----------------------------------------------------------------------------------------------------------------//
	oDlg1 := MSDialog():New( 091,232,529,1085,"Exemplo de Uso da DBGRID",,,.F.,,,,,,.T.,,,.T. )

	//----------------------------------------------------------------------------------------------------------------//
	//Definicao visual - Panel
	//----------------------------------------------------------------------------------------------------------------//
	oPanel1    	:= TPanel():New( 000,000,"",oDlg1,,.F.,.F.,,,430,212,.T.,.F. )

	//----------------------------------------------------------------------------------------------------------------//
	//Definicao visual - DbGrid
	//----------------------------------------------------------------------------------------------------------------//
	nTop      := 040
	nLeft     := 004
	nBottom   := 210
	nRight    := 426

	cLinhaOK  := "U_TSTLinOK()"
	cTudoOK   := "U_TSTTudOK()"
	cIniCpos  := ""
	lDelete   := .T.
	nMax      := 99
	cFieldOK  := "U_TSTFldOK()"
	cSuperDel := "(MsgInfo('SuperDel'), .T.)"
	cDelOK    := "U_TSTDelOK()"

	/* Breve descricao dos parametros da DbGrid

	nTop 	      Num�rico 			Distancia entre a MsNewGetDados e o extremidade superior do objeto que a cont�m.
	nLeft 	      Num�rico 			Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a cont�m.
	nBottom 	  Num�rico 			Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a cont�m.
	nRight    	  Num�rico 			Distancia entre a MsNewGetDados e o extremidade direita do objeto que a cont�m.
	nStyle   	  Num�rico 			Essa nova propriedade, passada via par�metro, substitui a passagem das vari�veis nOpc. Pode ser utilizada GD_INSERT + GD_UPDATE + GD_DELETE para criar a flexibilidade da MsNewGetdados.
	cLinhaOk 	  Caracter 			Fun��o executada para validar o contexto da linha atual do oDbGrid:aCols.
	cTudoOk 	  Caracter 			Fun��o executada para validar o contexto geral da MsNewGetDados (todo oDbGrid:aCols).
	cIniCpos 	  Caracter 			Nome dos campos do tipo caracter que utilizar�o incremento autom�tico. Este parametro deve ser no formato .
	aAlter 	      Array of Record 	Vetor com os campos que poder�o ser alterados.
	nFreeze 	  Num�rico 			Congela a coluna da esquerda para a direita. Se 0 n�o congela, se 1 congela a primeira coluna. Obs: atualmente s� � possivel congelar a primeira coluna, devido a limita��o do objeto.
	nMax 	      Num�rico 			N�mero m�ximo de linhas permitidas. Valor padr�o 99.
	cFieldOk 	  Caracter 			Fun��o executada na valida��o do campo.
	cSuperDel 	   Caracter 			Fun��o executada quando pressionada as teclas +.
	cDelOk    	   Caracter 			Fun��o executada para validar a exclus�o de uma linha do oDbGrid:aCols.
	oWnd 	       Objeto 			 	Objeto no qual a MsGetDados ser� criada.
	aPartHeader 	Array of Record 	aHeader
	aParCols 	   Array of Record 	oDbGrid:aCols
	uChange 	   Bloco de c�digo 	Bloco de execu��o a ser executado na propriedade bChange do Objeto.
	cTela 	       Caracter 			String contendo os campos contidos no X3_TELA.
	*/

	//----------------------------------------------------------------------------------------------------------------//
	//Esta Grid e implementacao da Classe MsNewGetDados()
	//Se precisar implementar algo, por favor utilize todas as propriendades e metodos da MsNewGetDados
	//----------------------------------------------------------------------------------------------------------------//
	oDbGrid := DbGrid():Create(nTop, nLeft, nBottom, nRight, GD_INSERT + GD_UPDATE + GD_DELETE , cLinhaOK, cTudoOK, cIniCpos, aAlterGDa, , nMax, cFieldOK, cSuperDel, cDelOK, oPanel1, aHeader, aCols, 1, 0, {|| Msginfo('NA CRIACAO')}/*, 'B1_COD', 5, '0000'*/)

	//oDbGrid:Refresh()
	oDbGrid:hDuplClk := {|| Msginfo('TESTE')}
	oDbGrid:oBrowse:lUseDefaultColors := .F.
	oDbGrid:oBrowse:SetBlkBackColor({|| 65280})

	oDlg1:Activate(,,,.T.)

Return


//----------------------------------------------------------------------------------------------------------------//
// Valida a linha atual da GetDados ao teclar seta para baixo ou para cima para a mudan�a de linha.
//----------------------------------------------------------------------------------------------------------------//
User Function TSTLinOK()

Return .T.

//----------------------------------------------------------------------------------------------------------------//
// Valida todas as linhas da GetDados ao confirmar a grava�ao.
//----------------------------------------------------------------------------------------------------------------//
User Function TSTTudOK()

	Local lRet := .T.
	Local nDel := 0

	If nDel == Len(oDbGrid:aCols)
		MsgInfo("Para excluir todos os itens, utilize a op��o EXCLUIR", 'Valida��o de Grava��o')
		lRet := .F.
	EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------//
// Valida��o de campo.
// Sequencia de execu��es ap�s o <Enter> no campo:
//   1 - valida��o definida no SX3;
//   2 - esta valida��o;
//   3 - gatilhos.
//----------------------------------------------------------------------------------------------------------------//
User Function TSTFldOK()
	Local i_ret := .T.

Return i_ret

//----------------------------------------------------------------------------------------------------------------//
// Valida Delecao da Linha.
//----------------------------------------------------------------------------------------------------------------//
User Function TSTDelOK()

	Local  lRet := .T.
	Static lPrimeiraVez := .T.

	If lPrimeiraVez
		If !oDbGrid:aCols[n][Len(oDbGrid:aHeader)+1]
			lRet := MsgYesNo("Confirma a exclus�o da linha?")
		EndIf
		lPrimeiraVez := .F.
	Else
		lPrimeiraVez := .T.
	EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------//
// Carrega o 	Array aHeader com o cabe�alho da Grid contendo as colunas da Grid.
//----------------------------------------------------------------------------------------------------------------//
Static Function CarraHeader()

	Local _cSX3 	:= GetNextAlias()

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1)) //X3_CAMPO
		(_cSX3)->(dbSeek(cAlias))
		If (Found())
			While ( !(_cSX3)->(Eof()) .And.  &("(_cSX3)->X3_ARQUIVO") == cAlias )

				If X3Uso(  &("(_cSX3)->X3_Usado"))    .And.;               // O Campo � usado.
					cNivel >=  &("(_cSX3)->X3_Nivel") .And.;              // Nivel do Usuario >= Nivel do Campo.
					.Not. allTrim(  &("(_cSX3)->X3_Campo")) $ "B1_FILIAL"  // Campos que nao ficarao na GetDados.

					AAdd(aHeader, {Trim( &("(_cSX3)->X3_Titulo")),;
						 &("(_cSX3)->X3_Campo")       ,;
						 &("(_cSX3)->X3_Picture")     ,;
						 &("(_cSX3)->X3_Tamanho")     ,;
						 &("(_cSX3)->X3_Decimal")     ,;
						 &("(_cSX3)->X3_Valid")       ,;
						 &("(_cSX3)->X3_Usado")       ,;
						 &("(_cSX3)->X3_Tipo")        ,;
						 &("(_cSX3)->X3_Arquivo")     ,;
						 &("(_cSX3)->X3_Context")})
					AADD(aAlterGDa,  &("(_cSX3)->X3_Campo"))
				EndIf

				(_cSX3)->(DBSkip())
			EndDo
		EndIf
	Endif
	(_cSX3)->(dbCloseArea())

	/*dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)

	While SX3->X3_Arquivo == cAlias .And. !SX3->(EOF())
		If X3Uso(SX3->X3_Usado)    .And.;                            // O Campo � usado.
	      cNivel >= SX3->X3_Nivel .And.;                            // Nivel do Usuario >= Nivel do Campo.
	      .Not. allTrim(SX3->X3_Campo) $ "B1_FILIAL"      // Campos que nao ficarao na GetDados.

	      AAdd(aHeader, {Trim(SX3->X3_Titulo),;
	                     SX3->X3_Campo       ,;
	                     SX3->X3_Picture     ,;
	                     SX3->X3_Tamanho     ,;
	                     SX3->X3_Decimal     ,;
	                     SX3->X3_Valid       ,;
	                     SX3->X3_Usado       ,;
	                     SX3->X3_Tipo        ,;
	                     SX3->X3_Arquivo     ,;
	                     SX3->X3_Context})
		  		  AADD(aAlterGDa, X3_Campo)
		EndIf
	   SX3->(dbSkip())
	End*/

Return

//----------------------------------------------------------------------------------------------------------------//
// Carrega os Dados da Grid.
//----------------------------------------------------------------------------------------------------------------//
Static Function CarraCols()

	Local i	:= 0

	aSize(aCols, 0)

   dbSelectArea(cAlias)
   DbSetOrder(1)
   DbGoTop()

	While !(cAlias)->(EOF())

      AAdd(aCols, Array(Len(aHeader) + 1))
      nCols++

		For i := 1 To Len(aHeader)
          aCols[nCols][i] := FieldGet(FieldPos(aHeader[i][2]))
		Next

      aCols[nCols][Len(aHeader) + 1] := .F.

      dbSelectArea(cAlias)
      dbSkip()

		If nCols = 30
         Exit
		EndIf

	End

Return
