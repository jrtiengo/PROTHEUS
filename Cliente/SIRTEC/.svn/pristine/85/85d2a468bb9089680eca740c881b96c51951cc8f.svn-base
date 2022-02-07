#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTSTDBGRID บ Autor ณ HELITOM SILVA      บ Data ณ  23/04/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณExemplo de Uso da DBGRID                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fabrica Totvs Mato Grosso                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
   ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
   บ Cria variaveis de memoria:                                                             บ
   บ Para cada campo da tabela, cria uma variavel de memoria com o mesmo nome.              บ
   บ Estas variaveis sao usadas em validacoes e gatilhos que existirem para este arquivo.   บ
   บ                                                                                        บ
   บ	       																						   บ
   บ	 Campos do SB1:																			   บ
   บ	  ,-----------,----------,------,-------------------------------,                    บ
   บ	  |   Campo   |   Tipo   | Tam. |     Inicializador padrao      |                    บ
   บ	  |-----------|----------|------|-------------------------------|                    บ
   บ	1 | B1_FILIAL | Caracter |   2  |                               |				       บ
   บ   2 | B1_DESC   | Caracter |  20  |                               |					   บ
   บ	  '-----------'----------'------'-------------------------------'                    บ
   บ	                                                                                     บ
   ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	*/


	dbSelectArea(cAlias)

	For nCampo := 1 To FCount()
		cCampo := FieldName(nCampo)
		M->&(cCampo) := CriaVar(cCampo, .F.)
	Next


    /*
    ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ Carrega o Array aHeader com o cabe็alho da Grid contendo as colunas da Grid.           บ
    ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	*/
	CarraHeader()


    /*
    ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ Adiciona linhas com dados na Grid . Obs: Isso pode ser feito apos Instaciar a DbGrid   บ
    ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	*/
	CarraCols()

	//----------------------------------------------------------------------------------------------------------------//
	//Declara็ใo de Variaveis Private dos Objetos
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

	nTop 	      Num้rico 			Distancia entre a MsNewGetDados e o extremidade superior do objeto que a cont้m.
	nLeft 	      Num้rico 			Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a cont้m.
	nBottom 	  Num้rico 			Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a cont้m.
	nRight    	  Num้rico 			Distancia entre a MsNewGetDados e o extremidade direita do objeto que a cont้m.
	nStyle   	  Num้rico 			Essa nova propriedade, passada via parโmetro, substitui a passagem das variแveis nOpc. Pode ser utilizada GD_INSERT + GD_UPDATE + GD_DELETE para criar a flexibilidade da MsNewGetdados.
	cLinhaOk 	  Caracter 			Fun็ใo executada para validar o contexto da linha atual do oDbGrid:aCols.
	cTudoOk 	  Caracter 			Fun็ใo executada para validar o contexto geral da MsNewGetDados (todo oDbGrid:aCols).
	cIniCpos 	  Caracter 			Nome dos campos do tipo caracter que utilizarใo incremento automแtico. Este parametro deve ser no formato .
	aAlter 	      Array of Record 	Vetor com os campos que poderใo ser alterados.
	nFreeze 	  Num้rico 			Congela a coluna da esquerda para a direita. Se 0 nใo congela, se 1 congela a primeira coluna. Obs: atualmente s๓ ้ possivel congelar a primeira coluna, devido a limita็ใo do objeto.
	nMax 	      Num้rico 			N๚mero mแximo de linhas permitidas. Valor padrใo 99.
	cFieldOk 	  Caracter 			Fun็ใo executada na valida็ใo do campo.
	cSuperDel 	   Caracter 			Fun็ใo executada quando pressionada as teclas +.
	cDelOk    	   Caracter 			Fun็ใo executada para validar a exclusใo de uma linha do oDbGrid:aCols.
	oWnd 	       Objeto 			 	Objeto no qual a MsGetDados serแ criada.
	aPartHeader 	Array of Record 	aHeader
	aParCols 	   Array of Record 	oDbGrid:aCols
	uChange 	   Bloco de c๓digo 	Bloco de execu็ใo a ser executado na propriedade bChange do Objeto.
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
// Valida a linha atual da GetDados ao teclar seta para baixo ou para cima para a mudan็a de linha.
//----------------------------------------------------------------------------------------------------------------//
User Function TSTLinOK()

Return .T.

//----------------------------------------------------------------------------------------------------------------//
// Valida todas as linhas da GetDados ao confirmar a grava็ao.
//----------------------------------------------------------------------------------------------------------------//
User Function TSTTudOK()

	Local lRet := .T.
	Local nDel := 0

	If nDel == Len(oDbGrid:aCols)
		MsgInfo("Para excluir todos os itens, utilize a op็ใo EXCLUIR", 'Valida็ใo de Grava็ใo')
		lRet := .F.
	EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------//
// Valida็ใo de campo.
// Sequencia de execu็๕es ap๓s o <Enter> no campo:
//   1 - valida็ใo definida no SX3;
//   2 - esta valida็ใo;
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
			lRet := MsgYesNo("Confirma a exclusใo da linha?")
		EndIf
		lPrimeiraVez := .F.
	Else
		lPrimeiraVez := .T.
	EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------//
// Carrega o 	Array aHeader com o cabe็alho da Grid contendo as colunas da Grid.
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

				If X3Uso(  &("(_cSX3)->X3_Usado"))    .And.;               // O Campo ้ usado.
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
		If X3Uso(SX3->X3_Usado)    .And.;                            // O Campo ้ usado.
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
