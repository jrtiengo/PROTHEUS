#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fb101mdt ³ Autor ³ Daniela Maria Uez     ³ Data ³13/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa Cadastro de EPCs entregues às equipes de funcio-  ³±±
±±³          ³ nários.                                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user function fb101mdt()

	PRIVATE aRotina 		:= MenuDef()

	PRIVATE cCadastro 	:= OemtoAnsi("EPCs Entregues por Equipe")
	PRIVATE aSMENU 		:= {}, aCHKDEL := {}
	PRIVATE lWhenEpi   	:= .f.
	PRIVATE nIndTNB  		:= 1
  	Private _codVer	   := getMv("ML_VERBEPC")

	//Integracao com o Estoque
	PRIVATE cUsaInt1 		:= AllTrim(GetMv("MV_NGMDTES")) // integração do mdt com o estoque. Tem que estar S
	PRIVATE lESTNEGA 		:= IIf(AllTrim(GETMV("MV_ESTNEG")) == 'S',.T.,.F.)
	PRIVATE lCpoNumSep 	:= IIf(ZZ9->(FieldPos("ZZ9_NUMSEQ"))>0,.t.,.f.)	 // numero de sequencia

	Private aArrayAE:={}
	Private bFiltraBrw := {|| Nil}

	// cria o array
 	aCols 	 	:= {}
 	aColsBrw 	:= {}

 	aAreaSX3 	:= GetArea()
 	dbSelectArea("SX3")
	dbSetOrder(1)

	//.And. cNivel >= X3_NIVEL .And. X3_BROWSE == "S")
	_i := 0
	If dbSeek("TN3")
		While !Eof() .And. X3_ARQUIVO == "TN3"

				If Trim(x3_campo) = "TN3_CODEPI" .Or.;
				Trim(x3_campo) = "TN3_NUMCAP" .Or.;
				Trim(x3_campo) = "TN3_DESC"   .Or.;
				Trim(x3_campo) = "TN3_FILIAL" .Or.;
				Trim(x3_campo) = "TN3_DURABI"

				AAdd(aCols, { Trim(X3_CAMPO), X3_TIPO, X3_TAMANHO, X3_DECIMAL})

				// não mostra a filial
				if Trim(x3_campo) != "TN3_FILIAL"  .AND. Trim(x3_campo) != "TN3_DURABI"
					AADD(aColsBrw, { TRIM(X3_TITULO), 	X3_CAMPO,		X3_TIPO, ;
						X3_TAMANHO, 	X3_DECIMAL, 	X3_PICTURE,		X3_VALID,;
						X3_USADO,		X3_ARQUIVO, 	X3_CONTEXT })
				endif
			EndIf

			SX3->(dbSkip())
		End

	EndIf
	RestArea(aAreaSX3)

   _cQuery := "SELECT DISTINCT  " +;
   		" 			  TN3.TN3_CODEPI AS EPI"+;
   		" FROM " + RetSqlName("TN3") + " TN3 " +;
			" 	WHERE TN3.TN3_FILIAL = '" + xFilial("TN3") + "' AND " +;
			" 		TN3.D_E_L_E_T_ = ' ' AND " +;
			" 		EXISTS ( " +;
			"			SELECT 1 FROM " + RetSqlName("SB1") + " SB1 "+;
			"				WHERE (SB1.B1_TPEPI = '3' OR  " +;
			" 					   SB1.B1_TPEPI = '4') AND " +;
			"					  SB1.B1_COD = TN3.TN3_CODEPI) "

	_cQuery := changeQuery(_cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TMPTN3", .T., .T.)

	cArqTrab := CriaTrab( aCols )  		// Arquivo de trabalho
	cArqTra1 := CriaTrab( NIL, .F. ) 	// ÍNDICE 1
	cArqTra2 := CriaTrab( NIL, .F. ) 	// ÍNDICE 2

	dbUseArea( .T.,, cArqTrab, "TRB", .T., .F. )        // usa o arquivo de trabalho com o nome TRB

	dbSelectArea("TMPTN3")
	TMPTN3->(dbGoTop())

	// inclui no arquivo de trabalho os dados
	While !Eof()
		dbSelectArea("TRB")
		RecLock("TRB", .T.)

		TRB->TN3_CODEPI := TMPTN3->EPI

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+TMPTN3->EPI)
		TRB->TN3_DESC   := SB1->B1_DESC
		TRB->TN3_DURABI := SB1->B1_PRVALID         // -> a pedido do flávio dia 17/02/2011 - alterado para buscar os dados do campo B1_PRVALID
		MsUnLock()

		dbSelectArea("TMPTN3")
		TMPTN3->(dbSkip())
	End
	dbCloseArea("TMPTN3")

	dbSelectArea("TRB")
	IndRegua("TRB", cArqTra1, "TN3_CODEPI", , , OemToAnsi("Selecionando Registros..."))
	DbSetIndex(cArqTra1+OrdBagExt())

	DbSetOrder(1)
	dbSelectArea("TRB")

	// chama o mbrowse: coordenadas da tela, alias, colunas a serem mostradas
	mBrowse( 6, 1, 22, 75, "TRB", aColsbrw, /*cCpo*/, /*n5*/, /*cfun*/, 2, /*acolors*/, /*ctopfun*/, /*cbotfun*/, /*n5*/, /*binitbloc*/, .F. )

  	dbCloseArea("TRB")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fb101ini  ³ Autor³Daniela Maria Uez      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Inclusao,alteracao,exclusao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpTM = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada no menu                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA630                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function fb101ini(cAlias,nReg,nOpcx)

	LOCAL LVar01:=1,nLinhas:=0,bCampo,cSaveMenuh,nCnt
	LOCAL GetList:={},nSavRec
	LOCAL _oDlg, oGet, i
	Local aNoFields := {}

	nSavRec := RecNo()
  	nOpcao	:=nOpcx

	PRIVATE aCOLS
	PRIVATE aCOLSZZ9

	If !SoftLock(cAlias)
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum dado no arquivo                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea( cAlias )
	dbSetOrder(1)

	FOR i := 1 TO FCount()
		x   := "m->" + FieldName(i)
		&x. := FieldGet(i)
	Next i

	_cQuery := "SELECT ZZ9.* " +;
		" FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
		" 	WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' AND " +;
		" 		ZZ9.D_E_L_E_T_ = ' ' AND " +;
     	"		ZZ9.ZZ9_CODEPC = '" + M->TN3_CODEPI + "' " +;
     	"	ORDER BY ZZ9_EQUIPE, ZZ9.ZZ9_DTENTR, ZZ9.ZZ9_FORNEC, ZZ9.ZZ9_LOJA"//, ZZ9.ZZ9_DTENTR"
     	/*"		ZZ9.ZZ9_FORNEC = '" + M->TN3_FORNEC + "' AND " +;*/
     	/*"		ZZ9.ZZ9_LOJA   = '" + M->TN3_LOJA 	+ "' AND " +;*/
     	/*" 		ZZ9.ZZ9_NUMCAP = '" + M->TN3_NUMCAP + "'" +;*/

	_cQuery := changeQuery(_cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRBZZ9", .T., .T.)

	dbSelectArea("TRBZZ9")
	dbgotop()

	nCnt := 0
	While !TRBZZ9->(EOF())
		nCnt++
		TRBZZ9->(dbSkip())
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0
	bHotArea := {|| HotAreas(12, 2,20,74,nUsado)}
	bCampo 	 := {|nCPO| Field(nCPO) }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o cabecalho                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nUsado := 0
	_aCposAux := {	"ZZ9_ETIQ",	"ZZ9_EQUIPE", 	"ZZ9_NOMEEQ", "ZZ9_ENDLOC", "ZZ9_NUMSER", "ZZ9_LOCAL",;
					"ZZ9_DTENTR", 	"ZZ9_HRENTR",	"ZZ9_DTDEV",	"ZZ9_MOTIVO",;
					"ZZ9_DEV", 		"ZZ9_DIASUT",	"ZZ9_NUMSEQ",	"ZZ9_CODEPC",;
					"ZZ9_FORNEC",	"ZZ9_LOJA", 	"ZZ9_NUMCAP",  	"ZZ9_NOVO" }

	//Inclui no aHeader os campos da tabela SC6
	for _iX := 1 to len(_aCposAux)
		SX3->(DbSetOrder(2))

		if SX3->(DbSeek(_aCposAux[_iX]))
			nUsado++

        	AADD (aHeader, {TRIM(SX3->X3_TITULO), 	SX3->X3_CAMPO, 		SX3->X3_PICTURE,;
	        					SX3->X3_TAMANHO, 	SX3->X3_DECIMAL, 	SX3->X3_VALID,;
	        					SX3->X3_USADO, 		SX3->X3_TIPO, 		SX3->X3_F3,;
	        					SX3->X3_CONTEXT, 	SX3->X3_CBOX, 		SX3->X3_RELACAO,;
	        					SX3->X3_WHEN})
 		endif

   next


   	// inicializador padrão!!
		aHeader[6][12]  := "Posicione('SB1',1,xFilial('SB1')+M->TN3_CODEPI,'B1_LOCPAD')"	//almoxarifado - LOCAL
   	aHeader[7][12]  := "date()"															// data
   	aHeader[8][12]  := "time()"															// hora
   	aHeader[11][12]  := "1"																// devolvido
   	aHeader[14][12] := "M->TN3_CODEPI"    												// epi
   	aHeader[15][12] := Space(6)//"M->TN3_FORNEC"                                         			// fornecedor
		aHeader[16][12] := Space(2)//"M->TN3_LOJA"													// loja
		aHeader[15][12] := "M->TN3_NUMCAP"													// num Certif. aprovacao
	//aHeader[5][13]  := "empty(_acols1[n][11])"

	aCols := Array(nCnt,nUsado+1)

  	TcSetField("TRBZZ9", "ZZ9_DTENTR", "D")      // ENTREGA DO EPC AO FUNCIONÁRIO
	TcSetField("TRBZZ9", "ZZ9_DTDEV",  "D")      // DEVOLUÇÃO DO EPC PELO FUNCIONÁRIO

	If nCNT > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		dbSelectArea("TRBZZ9")
		dbgotop()

		nCnt := 0
		While !EOF()

			nCnt++
			nUsado:=0

			for _iX := 1 to len(_aCposAux)

				dbSelectArea("SX3")
				SX3->(DbSetOrder(2))

				if SX3->(DbSeek(_aCposAux[_iX]))

					nUsado++

					If X3_CONTEXT # "V"
						aCOLS[nCnt][nUsado] := &("TRBZZ9" + "->" + X3_CAMPO)
					ElseIf X3_CONTEXT == "V"
						aCOLS[nCnt][nUsado] := CriaVar(Alltrim(X3_CAMPO))
					Endif

					if X3_CAMPO = "ZZ9_DIASUT"
						aCOLS[nCnt][nUsado] := iif(empty(&("TRBZZ9->ZZ9_DTDEV")),;
								date() - &("TRBZZ9->ZZ9_DTENTR") + 1,;
								&("TRBZZ9->ZZ9_DTDEV")-&("TRBZZ9->ZZ9_DTENTR")+1)

					elseif X3_CAMPO = "ZZ9_NOMEEQ"
						aCOLS[nCnt][nUsado] := Posicione('AA1',1,;
								xFilial('AA1')+&("TRBZZ9->ZZ9_EQUIPE"),'AA1_NOMTEC')
					ENDIF
				Endif

				dbSkip()
			next

			aCOLS[nCnt][nUsado+1] := .F.

			dbSelectArea("TRBZZ9")
			dbSkip()
		End

	Else

		aCols:=Array(1,nUsado+1)
		nUsado  := 0
		for _iX := 1 to len(_aCposAux)

			dbSelectArea("SX3")
			SX3->(DbSetOrder(2))

			if SX3->(DbSeek(_aCposAux[_iX]))

				nUsado++

            	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            	//³ Monta Array de 1 elemento ³
            	//³ vazio. Se inclus†o.       ³
            	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	         IF x3_tipo == "C"
	            	aCOLS[1][nUsado] := SPACE(X3_TAMANHO)
	   		ELSEIF x3_tipo == "N"
	            	aCOLS[1][nUsado] := 0
				ELSEIF x3_tipo == "D"
	            	aCOLS[1][nUsado] := stod("")
				ELSEIF x3_tipo == "M"
	   				aCOLS[1][nUsado] := ""
				ELSE
	            	aCOLS[1][nUsado] := .F.
				Endif

	   	Endif
	   next

		aCOLS[1][nUsado+1]	:= .F.
		aCOLS[1][7] 		:= date()
		aCOLS[1][8] 		:= time()
		aCOLS[1][11]  		:= "1"
		aCOLS[1][14] 		:= M->TN3_CODEPI
		aCOLS[1][15] 		:= Space(6)//M->TN3_FORNEC
		aCOLS[1][16] 		:= Space(2)//M->TN3_LOJA
		aCOLS[1][17] 		:= M->TN3_NUMCAP

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+M->TN3_CODEPI)
		aCOLS[1][6]  := SB1->B1_LOCPAD  // LOCAL

	Endif

	If Len(aCOLS)=0
		AAdd (aCOLS, aclone( U_LinVazSI (aHeader)))
	Endif

	_aHeader1 := aClone(aHeader)
	_aCols1	 := {}

	aCOLSZZ9  := aClone(aCOLS)

	nOpca 	 := 0

	DEFINE MSDIALOG _oDlg TITLE cCadastro From 9,0 To 38,80 //OF oMainWnd

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+M->TN3_CODEPI)

	@ 5.1, .8 SAY OemToAnsi("Codigo EPC")
	@ 5.1, 5  MSGET M->TN3_CODEPI SIZE 52,10  When .f.
	@ 5.1, 12 SAY OemToAnsi("Descricao")
	@ 5.1, 16 MSGET SB1->B1_DESC SIZE 110,10  When .f.
	@ 5.1, 30 SAY OemToAnsi("U.M.")
	@ 5.1, 32 MSGET SB1->B1_UM SIZE 15,10 	  When .f.
	@ 6.3, .8 SAY OemToAnsi("Loc. Padrao")
	@ 6.3, 5  MSGET SB1->B1_LOCPAD SIZE 15,10 When .f.
	@ 6.3, 12 SAY OemToAnsi("Durabilidade")
	@ 6.3, 16 MSGET M->TN3_DURABI SIZE 15,10  When .f.
	@ 6.3, 22 SAY OemToAnsi("Certif. Aprov.")
	@ 6.3, 27 MSGET M->TN3_NUMCAP SIZE 30,10  When .f.

 	oGet := MsNewGetDados():New(100, 1, 228, 450,;			//{|| _aCols1:=oGet:aCols, "AllwaysTrue()"}
  				GD_INSERT+GD_UPDATE+GD_DELETE,;
  				"AllwaysTrue()", {|| _aCols1:=oGet:aCols, U__linhaOk()},;
  				/**/,		 /**/,		 /*freeze*/, /**/,;
  				/*fieldok*/, /*supdel*/, /*delok*/,  /*folder*/,;
  				aHeader,	 aCOLS)

 	_bBotaoOK  := {|| IIf(oGet:TudoOk(),nOpcA:=1,nOpcA:=0), _aCols1:=oGet:aCols, iif(nOpcA==1, _oDlg:End(), NIL)}
	_bBotaoCan := {|| _oDlg:End()}
	_aBotAdic  := {}

	Activate Dialog _oDlg on init (EnchoiceBar (_oDlg, _bBotaoOK, _bBotaoCan,, _aBotAdic))

   dbSelectArea("ZZ9")
	If nOpcA == 1
		Begin Transaction
			lGravaOk := grava(_aCols1)//_GRAVA("ZZ9", nOpca, _acols1)
			If lGravaOk
				//Processa Gatilhos
	 			EvalTrigger()
	 		EndIf
	 	End Transaction
	Endif

	TRBZZ9->(dbclosearea())
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _GRAVA   ³ Autor ³ Daniela Maria Uez     ³ Data ³28/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os dados no ZZ9                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA630                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function _grava(cAlias, nOpcao, _aCols1)
	Local nx ,ny ,i ,nInd, nMaxArray , aBACK := aCLONE(_aCOLS1)
	Local _nCustoit := 0
	Local lAtEstoque := .t.
	Local _aMot := {"Admissional", "Desgaste/Mau Uso", "Defeito", "Perda", "Roubo", "Demissional", "Outros", "Troca Equipe"}

	dbSelectArea("ZZ9")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ verifica se o ultimo elemento do array esta em branco        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aCOLS1 := {}
	aEVAL(aBACK, {|x| If( !Empty(x[1]),  AAdd(_aCOLS1,x), NIL) })
	nMaxArray := Len(_aCOLS1)

	If nMaxArray <= 0
	   Return .F.
	Endif

	nEPI    	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_CODEPC"})
	nFORNEC 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_FORNEC"})
	nLOJA   	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_LOJA"})
	nEqp 		:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_EQUIPE"})
	nDTENTR 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_DTENTR"})
	nHRENTR 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_HRENTR"})
  	nNumSer 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_NUMSER"})
	nDTADEV 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_DTDEV"})
	nLocalT 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_LOCAL"})
	nNumCa  	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_NUMCAP"})
	nMotivo 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_MOTIVO"})
	nDev		:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_DEV"})
	nSeqD3  	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_NUMSEQ"})
	nDias   	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_DIASUT"})

	If nFORNEC == 0 .or. nLOJA == 0 .or. nEPI == 0 .or. nDTENTR == 0 .or.;
		nHRENTR == 0 //.or. nNUMCAP == 0

	   	DbSelectArea("ZZ4")
		Return .F.
	Endif

	// *****************************************************************************************************
	//Deleta registros que foram alterados e atualiza estoque em caso de devolução ou exclusão do item

	Dbselectarea("ZZ9")
	Dbsetorder(3)
	Dbseek(xFilial("ZZ9")+SA2->A2_COD+SA2->A2_LOJA+SB1->B1_COD)
	While !eof() .and. xFilial("ZZ9")+SA2->A2_COD+SA2->A2_LOJA+SB1->B1_COD == ;
			ZZ9->ZZ9_FILIAL+ZZ9->ZZ9_FORNEC+ZZ9->ZZ9_LOJA+ZZ9->ZZ9_CODEPC

		xx := 0
		cCondTN3 := ZZ9->ZZ9_NUMSER+ZZ9->ZZ9_NUMCAP+ZZ9->ZZ9_EQUIPE

		For nInd := 1 to Len(_aCOLS1)
			If _aCOLS1[nInd,nNumSer]+_aCOLS1[nInd,nNumCa]+_aCOLS1[nInd,nEqp] == cCondTN3
				RecLock("ZZ9",.F.,.T.)
				dbDelete()
				MsunLock("ZZ9")
			Endif
		Next nInd

		Dbskip()
	End

	// para todos os itens do array
	For nx = 1 to nMaxArray

		If _aCOLS1[nx][Len(_aCOLS1[nx])] // se o item foi excluído
			dbSelectArea("ZZ9")
			Dbsetorder(3)

			If dbSeek(xFilial("ZZ9")+_aCOLS1[nx][nFORNEC]+_aCOLS1[nx][nLOJA]+_aCOLS1[nx][nEPI]+_aCOLS1[nx][nNumSer])
				lDevolvido   := .f.

				If !Empty(ZZ9->ZZ9_DTDEV)
					lDevolvido := .t.
				Endif

				RecLock("ZZ9",.F.,.T.)
				dbDelete()
				MSUNLOCK("ZZ9")

				If lCpoNumSep .and. !lDevolvido
					If cUsaInt1 == "S"
						//cNUMSEQ := _MDTGeraD3("DE1", 2)
					Endif
				Endif


				dbSelectArea("ZZ4")
				dbSetOrder(1)
				dbSeek(xFilial("ZZ4")+_aCOLS1[nx][nEqp])
				// apaga os funcionários da tabela tnf
				while ZZ4->ZZ4_EQUIPE == _aCOLS1[nx][nEqp]

					IF !empty(ZZ4->ZZ4_CODSRA)
						// verifica se o registro já existe na tabela
						dbselectArea("TNF")
						DBORDERNICKNAME("MATSERIE") 	//Matricula+Codigo+Serie EPI+Num. Cer. Aprov. +Fornecedor+Loja+Dt. Entrega+Hr. Entregue

						IF dbSeek(xFilial("TNF")+ZZ4->ZZ4_CODSRA+_aCOLS1[nx][nEPI]+_aCOLS1[nx][nNumSer]+_aCOLS1[nx][nNumCa]+;
							_aCOLS1[nx][nFORNEC]+_aCOLS1[nx][nLOJA]+DTOS(_aCOLS1[nx][nDTENTR])+_aCOLS1[nx][nHRENTR])

							RecLock("TNF",.F., .T.)
							dbdelete()
							msunlock("TNF")
						endif
					endif
					ZZ4->(DBSKIP())

				ENDDO

			EndIf  //if dbseek zz9

			dbSelectArea("ZZ9")
			Loop
		Endif		//_aCOLS1[nx][Len(_aCOLS1[nx])] - final do item excluído

		// ********************************************************************************************
		// inclui dados da entrega do EPC para equipe
		If !empty(_aCOLS1[nx][nEqp])
			lIncTNF := .f.
			dbSelectArea("ZZ9")
			Dbsetorder(3)

			//3. FILIAL + FORNECEDOR + LOJA + EPC + NUMSER + NUMCAP + EQUIPE + DTOS(DTENTR) + HRENTR
			If dbSeek(xFilial("ZZ9")+_aCOLS1[nx][nFORNEC]+_aCOLS1[nx][nLOJA]+_aCOLS1[nx][nEPI]+_aCOLS1[nx][nNumSer]+;
					_aCOLS1[nx][nNumCa]+_aCOLS1[nx][nEqp]+DTOS(_aCOLS1[nx][nDTENTR])+_aCOLS1[nx][nHRENTR])
				lIncTNF := .f.
			Else
				lIncTNF := .t.
			Endif

			lAlterou := .t. //Se alterou algum campo da linha

			If Len(_aCOLS1) >= nx .and. Len(aCOLSZZ9) >= nx .and. !lIncTNF
				lAlterou := .f.
				For nInd := 1 To Len(_aCOLS1[nx])
					If _aCOLS1[nx,nInd] <> aCOLSZZ9[nx,nInd]
						lAlterou := .t.
						Exit
					Endif
				Next nInd
			Endif

			lQtdIgual  := .t.
			lDevolvido := .f.
			lDevRetorn := .f.

			If cUsaInt1 == "S" .and. lCpoNumSep .and. !lIncTNF .and. lAlterou
				If nLocalT > 0
					If _aCOLS1[nx][nLocalT] <> ZZ9->ZZ9_LOCAL
						lQtdIgual := .f.
					Endif
				Endif

				If Empty(_aCOLS1[nx][nDTADEV]) .and. !Empty(ZZ9->ZZ9_DTDEV)
					lDevRetorn := .t.
				Endif

				If !Empty(_aCOLS1[nx][nDTADEV]) .and. Empty(ZZ9->ZZ9_DTDEV)
					lDevolvido := .t.
				Endif

				//
				// não retornam o produto ao estoque
				//if //_aCOLS1[nX][nMotivo]$"2345"


				//só atualiza estoque se foi devolvido. Se motivos de devolução
				// 2=Desgaste/Mau Uso, 3=Defeito, 4=Perda, 5=Roubo também não atualizam estoque.
				if _aCOLS1[nX][nDev] <> "3" .or. _aCOLS1[nX][nMotivo]$"2345"
					lAtEstoque := .f.
				endif

				If (!lQtdIgual .or. lDevolvido) .and. lAtEstoque
					//cNUMSEQ := _MDTGeraD3("DE1", 2)
				Endif
			Endif     //cUsaInt1 == "S" .and. lCpoNumSep .and. !lIncTNF .and. lAlterou

			If cUsaInt1 == "S" .and. !lESTNEGA .and. (lIncTNF .or. !lQtdIgual .or. lDevRetorn) .and. !lDevolvido
				cLocTnf_ := If(ZZ9->(FieldPos("ZZ9_LOCAL"))>0,_aCOLS1[nX][nLocalT],"01")
				If !NGSALSB2(_aCOLS1[nX][nEPI],cLocTnf_,1)//_aCOLS1[nX][nQTDENT])
					MsgInfo("Problema ocorreu na linha: "+Alltrim(Str(nX,9)))
					Return .f.
				EndIf
			EndIf

			dbSelectArea("ZZ9")
			If !lIncTNF
				RecLock("ZZ9",.F.)
			Else
				RecLock("ZZ9",.T.)
			Endif

			dbselectArea("ZZ4")
			dbSetOrder(1)
			dbSeek(xFilial("ZZ4")+_aCOLS1[nx][nEqp])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza dados dos epi's entregues                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ZZ9->ZZ9_FILIAL := xFilial('ZZ9')
			ZZ9->ZZ9_EQUIPE := ZZ4->ZZ4_EQUIPE

			dbSelectArea("ZZ9")
			dbSetOrder(3)

			FOR i := 1 TO FCount()
				If FieldName(i) == "ZZ9_FILIAL" .OR. FieldName(i) == "ZZ9_EQUIPE" .OR.;
					aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == FieldName(i) }) < 1
					Loop
				EndIf

				x  := "m->" + FieldName(i)
				&x.:= _aCOLS1[nx][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == FieldName(i) })]
				y  := "ZZ9->" + FieldName(i)
				&y := &x
			Next i

			If cUsaInt1 == "S" .and. lCpoNumSep .and. (lIncTNF .or. !lQtdIgual .or. lDevRetorn) .and. !lDevolvido
				//cNUMSEQ 		:= _MDTGeraD3("RE1",1)
				//ZZ9->ZZ9_NUMSEQ := cNUMSEQ
				_nCustoit  		:= SD3->D3_CUSTO1
			EndIf
			MSUNLOCK("ZZ9")
		Endif  //!empty(_aCOLS1[nx][nEqp])

		//********************************************************************************************
		// Grava no TNF OS DADOS DOS FUNCIONÁRIOS QUE ESTÃO NA EQUIPE
		// tem q excluir os que já estão e começar tudo de novo...
		// dia 08/06/2010: somente inclui o líder da equipe na tnf.
		dbSelectArea("ZZ4")
		dbSetOrder(1)
		dbSeek(xFilial("ZZ4")+_aCOLS1[nx][nEqp])

		_cEncar := ""
		while ZZ4->ZZ4_EQUIPE == _aCOLS1[nx][nEqp]

			// Procura matrícula do funcionário
			// Se tem código de funcionário, é funcionário. Senão pode ser outro tipo de recurso, como caminhão.
			IF !empty(ZZ4->ZZ4_CODSRA)

				// Procura o encarregado da equipe. Ele quem responde pelo equipamento
				if ZZ4->ZZ4_ENCARE = "2"
					_cEncar := ZZ4->ZZ4_CODSRA


					// verifica se o registro já existe na tabela
					dbselectArea("TNF")
					DBORDERNICKNAME("MATSERIE") 	//Matricula+Codigo+Serie EPI+Num. Cer. Aprov. +Fornecedor+Loja+Dt. Entrega+Hr. Entregue
					IF dbSeek(xFilial("TNF")+ZZ4->ZZ4_CODSRA+_aCOLS1[nx][nEPI]+_aCOLS1[nx][nNumSer]+_aCOLS1[nx][nNumCa]+;
						M->ZZ9_FORNECE+M->ZZ9_LOJA+DTOS(_aCOLS1[nx][nDTENTR])+_aCOLS1[nx][nHRENTR])
						RecLock("TNF",.F.)
					else
						RecLock("TNF",.T.)
					endif

					TNF->TNF_FILIAL  	:= xFilial("TNF")
					TNF->TNF_MAT  	  	:= ZZ4->ZZ4_CODSRA
					TNF->TNF_FORNEC  	:= M->ZZ9_FORNECE
					TNF->TNF_LOJA    	:= M->ZZ9_LOJA
					TNF->TNF_NUMCAP  	:= M->ZZ9_NUMCAP
					TNF->TNF_CODEPI  	:= _aCOLS1[nx][nEPI]
					TNF->TNF_DTENTR  	:= iif(empty(_aCOLS1[nx][nDTENTR]), date(), _aCOLS1[nx][nDTENTR])
					TNF->TNF_HRENTR  	:= _aCOLS1[nx][nHRENTR]
					TNF->TNF_QTDENTR 	:= 1 														// ENTREGA SEMPRE UMA ÚNICA UNIDADE
					TNF->TNF_DTRECI  	:= _aCOLS1[nx][nDTENTR]
					TNF->TNF_CODFUN  	:= ZZ4->ZZ4_CODTEC
					TNF->TNF_INDDEV  	:= IIF(EMPTY(_aCOLS1[nx][nDTADEV]), "2", "1") // 1 INDICA DEVOLUÇÃO
					TNF->TNF_NUMSEQ  	:= ZZ9->ZZ9_NUMSEQ
					TNF->TNF_DTDEVO  	:= iif(empty(_aCOLS1[nx][nDTADEV]),stod(""),_aCOLS1[nx][nDTADEV])
					TNF->TNF_LOCAL   	:= _aCOLS1[nx][nLocalT]
					TNF->TNF_SERIE   	:= _aCOLS1[nx][nNumSer]

					IF !empty(_aCOLS1[nX][nMotivo])		// SE INFORMOU MOTIVO DE DEVOLUÇÃO
						// se devolução foi por 2=Desgaste/Mau Uso, 3=Defeito, 4=Perda, 5=Roubo ou 7=não devolvido
						// não deve retornar ao almoxarifado
						// senão retorna
						TNF->TNF_TIPODV 	:= IIF(_aCOLS1[nX][nMotivo]$"23457","2","1")
					ENDIF

					MSUNLOCK("ZZ9")
				endif
			endif
			dbSelectArea("ZZ4")
			ZZ4->(dbSkip())

		enddo   //ZZ4->ZZ4_EQUIPE == _aCOLS1[nx][nEqp]

		//***********************************************************************************
		// se for devolução por motivos 2=Desgaste/Mau Uso, 4=Perda ou 5=Roubo
		// deve ser cobrado do funcionário! O valor é rateado entre a equipe
		// Motivos 3 (defeito) e 6(demissional) serão cobrados somente se não houver devolução do EPC

		// não´tá vazio o motivo e foi alterado o status
	Next nx
	DbSelectArea("TNF")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³_linhaOk  ³ Autor ³ Daniela Maria Uez	     ³ Data ³15/04/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpTM = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NGFUN695                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function _linhaOk()
	Local xx := 0, npos:= 0,npos1:= 0,npos2:= 0, lRET := .T.
	Local nX,nInd
	Local aArea := GetArea()
	Local nPosNum := 0

	nPOS  	:= aSCAN(aHEADER, {|x| AllTrim(Upper(x[2])) == "ZZ9_CODEPC"})
	nPOS3 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(x[2])) == "ZZ9_FORNEC"})
	nPOS4 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(x[2])) == "ZZ9_LOJA"})
	nPOS1 	:= aSCAN(aHEADER, {|x| AllTrim(Upper(x[2])) == "ZZ9_DTENTR"})
	nPOS2  	:= aSCAN(aHEADER, {|x| AllTrim(Upper(x[2])) == "ZZ9_HRENTR"})
	nNSer  	:= aSCAN(aHEADER, {|x| AllTrim(Upper(x[2])) == "ZZ9_NUMSER"})
	nLocalT  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_LOCAL" })
	nNumseq  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_NUMSEQ"})
	nDtdev   := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_DTDEV"})
	nMotivo  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_MOTIVO"})
	nEqp     := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_EQUIPE"})
	nNumCa   := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_NUMCAP" })
	nDev     := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_DEV" })

	dDte := _aCOLS1[n][nPos1]
	cHra := _aCOLS1[n][nPos2]

	If !_aCOLS1[n][len(_aCOLS1[n])]
		If Empty(_aCOLS1[n][nPOS])
			Return .F.
		Endif

		lAlterou := .t. //Se alterou algum campo da linha
		If Len(_aCOLS1) >= n .and. Len(aCOLSZZ9) >= n
			lAlterou := .f.
			For nInd := 1 To Len(_aCOLS1[n])
				If _aCOLS1[n,nInd] <> aCOLSZZ9[n,nInd]
					lAlterou := .t.
					Exit
				Endif
			Next nInd
		Endif

		// Se a data de devolução foi informada e não havia registro
		if !empty(_aCOLS1[n][nDtdev]) .and. (n > len(aCOLSZZ9)  .or. empty(aColsZZ9[n][nNSer]))
			msgStop("O EPC não pode ser devolvido antes de confirmada sua entrega." )
			return .f.
		endif

		If cUsaInt1 == "S"
			If ZZ9->(FieldPos("ZZ9_LOCAL")) > 0 .and. nLocalT > 0 .and. lAlterou
			   If Empty(_aCOLS1[n][nLocalT])
			      MsgStop("O campo Local Almox. deve ser informado")
			      Return .F.
			   EndIf
			Endif
		endif

		if lAlterou .and. len(aColsZZ9)>=n
			// não deixa alterar a data de entrega do epc. Mas não cancela. Avisa e volta pra data anterior.
		 	if _aCOLS1[n][nPOS1] <> aColsZZ9[n][nPOS1] .and. !empty(aColsZZ9[n][nNSer])
		    	MsgStop("A data de entrega do EPC não pode ser alterada!")
				_aCOLS1[n][nPOS1] := aColsZZ9[n][nPOS1]
		   	endif

		   // não deixa alterar a hora de entrega do epc. Mas não cancela. Avisa e volta pra hora anterior.
		 	if _aCOLS1[n][nPOS2] <> aColsZZ9[n][nPOS2] .and. !empty(aColsZZ9[n][nNSer])
		    	MsgStop("A hora de entrega do EPC não pode ser alterada!")
				_aCOLS1[n][nPOS2] := aColsZZ9[n][nPOS2]
		   	endif

		   	// não deixa alterar o número de série do epc. Mas não cancela. Avisa e volta pro número de série original
		 	if _aCOLS1[n][nNSer] <> aColsZZ9[n][nNSer] .and. !empty(aColsZZ9[n][nNSer])
		    	MsgStop("O número de série do EPC não pode ser alterado!")
				_aCOLS1[n][nNSer] := aColsZZ9[n][nNSer]
		   	endif

		   	// não deixa alterar o código da equipe. Mas não cancela. Avisa e volta pra equipe anterior.
		 	if _aCOLS1[n][nEqp] <> aColsZZ9[n][nEqp] .and. !empty(aColsZZ9[n][nNSer])
		    	MsgStop("A equipe não pode ser alterada!")
				_aCOLS1[n][nEqp] := aColsZZ9[n][nEqp]
		  	endif

		   	// não deixa alterar o almoxarifado do epc. Mas não cancela. Avisa e volta pro anterior.
		   	if _aCOLS1[n][nLocalT] <> aColsZZ9[n][nLocalT] .and. !empty(aColsZZ9[n][nNSer])
		    	MsgStop("O almoxarifado do EPC não pode ser alterada!")
			 	_aCOLS1[n][nLocalT] := aColsZZ9[n][nLocalT]
		   	endif

		   // se a data de devolução foi preenchida e não estava preenchida antes, valida
			If !Empty(_aCOLS1[n][nDtdev]) .and. empty(aColsZZ9[n][nDtdev]) .and. !empty(aColsZZ9[n][nNSer])
				if _aCOLS1[n][nDtdev] > Date()
			    	MsgStop("A data de devolução não pode ser superior à data atual!")
					Return .F.
			  	endif
				if _aCOLS1[n][nDtdev] < _aCOLS1[n][nPOS1]
			    	MsgStop("A data de devolução não pode ser inferior à data de entrega!")
					Return .F.
			  	endif
				if Empty(_aCOLS1[n][nMotivo])
			    	MsgStop("O motivo da devolução deve ser informado!")
					Return .F.
			   endif
			EndIf

			if empty(_aCOLS1[n][nDtdev])
			   _aCOLS1[n][nMotivo] 	:= " "	// não tem data de devolução, não tem motivo
			   _aCols1[n][nDev] 		:= "1"  // e o epc está em uso.

			else
				If !empty(aColsZZ9[n][nDtdev])
					//a data de devoluão não pode ser alterada!
					if _aCOLS1[n][nDtdev] <> aColsZZ9[n][nDtdev]
				   		MsgStop("A data de devolução do EPC não pode ser alterada!")
					 	_aCOLS1[n][nDtdev] := aColsZZ9[n][nDtdev]
					endif

					if _aCOLS1[n][nMotivo] <> aColsZZ9[n][nMotivo]
						MsgStop("O motivo da devolução do EPC não pode ser alterado!")
					 	_aCOLS1[n][nMotivo] := aColsZZ9[n][nMotivo]
					 	_aCOLS1[n][nDev] := aColsZZ9[n][nDev]
					endif

					if _aCOLS1[n][nDev] <> aColsZZ9[n][nDev]
						// o status da devolução do epc não pode ser alterado
						// para 1 caso o status anterior seja 2
						if aColsZZ9[n][nDev] == "2" .and.  _aCOLS1[n][nDev]=="1"
							MsgStop("O status de devolução do EPC não pode ser 'Em uso' depois de informada a devolução")
							_aCOLS1[n][nDev] := aColsZZ9[n][nDev]
						endif

						if aColsZZ9[n][nDev] == "3"
							MsgStop("O EPC havia sido informado como devolvido. O status não pode ser alterado!")
							_aCOLS1[n][nDev] := aColsZZ9[n][nDev]
						endif

						if aColsZZ9[n][nDev] == "4" .and.  _aCOLS1[n][nDev]$"12"
							MsgStop("O status de devolução do EPC não pode alterado para 'Em uso' ou "+;
									" 'Aguardando devolução' depois de informada a devolução")
							_aCOLS1[n][nDev] := aColsZZ9[n][nDev]
						endif

						_nDiasLim := getmv("ML_DIASLIM")
						if aColsZZ9[n][nDev] == "4" .and. (date() - _aCOLS1[n][nDtdev]) > _nDiasLim .and.;
							_aCOLS1[n][nDev]$"3"
							MsgStop("O status do EPC não pode ser alterado para devolvido após " + strzero(_nDiasLim,3) +;
									" dias de devolução." )
							_aCOLS1[n][nDev] := aColsZZ9[n][nDev]
						endif
					endif
				endif      //informado  devolução anterior.

				if _aCOLS1[n][nDev]=="1"
					MsgStop("O status de devolução do EPC não pode ser 'Em uso' depois de informada a devolução")
					_aCOLS1[n][nDev] := "2"
				endif
			endif //empty(_aCOLS1[n][nDtdev])
		endif  //lAlterou

		if empty(_aCOLS1[n][nDtdev]) .and. n <= len(aCOLSZZ9)
			// verifica se o número de série existe
			_cQuery := " SELECT 1 " +;
				" FROM " + RetSqlName("SBF") + " SBF " +;
				" WHERE SBF.BF_FILIAL = '" + xFilial("SBF") + "' AND " +;
				" 		SBF.D_E_L_E_T_ = ' ' AND " +;
		     	"		SBF.BF_PRODUTO = '"  + M->TN3_CODEPI + "' AND " +;
		     	"		SBF.BF_NUMSERI = '"  + _aCOLS1[n][nNSer] + "' AND " + ;
		     	"		SBF.BF_LOCAL = '" 	 + _aCOLS1[n][nLocalT] + "' "

			_cQuery := changeQuery(_cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "_TRBNUMS", .T., .T.)

			_nCt := 0
			dbSelectArea("_TRBNUMS")
			dbgotop()
			if _TRBNUMS->(eof())
				MsgStop("O número de série não existe no local informado.")
				_TRBNUMS->(dbCloseArea())
				return .f.
			endif
			_TRBNUMS->(dbCloseArea())

		endif

		dbSelectArea("ZZ9")
		dbSetOrder(3)
		If !dbSeek(xFilial("ZZ9")+_aCOLS1[n][nPOS3]+_aCOLS1[n][nPOS4]+_aCOLS1[n][nPOS]+_aCOLS1[n][nNSer]+;
				_aCOLS1[n][nNumCa] + _aCOLS1[n][nEqp]+DTOS(_aCOLS1[n][nPOS1])+_aCOLS1[n][nPOS2])

			// verifica se foi devolvido
			_cQuery := " SELECT MAX(ZZ9.ZZ9_DTENTR+ZZ9_HRENTR), ZZ9.ZZ9_DTDEV" +;
				" FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
				" WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' AND " +;
				" 		ZZ9.D_E_L_E_T_ = ' ' AND " +;
				" 		ZZ9.ZZ9_FORNEC = '"  + _aCOLS1[n][nPOS3] + "' AND " +;
		     	"		ZZ9.ZZ9_LOJA   = '"  + _aCOLS1[n][nPOS4] 	+ "' AND " +;
		     	"		ZZ9.ZZ9_CODEPC = '"  + M->TN3_CODEPI + "' AND " +;
		     	"		ZZ9.ZZ9_NUMSER = '"  + _aCOLS1[n][nNSer] + "' AND " + ;
		     	"		ZZ9.ZZ9_NUMSEQ <> '" + _aCOLS1[n][nNumSeq] + "' AND " +;
		     	" 		ZZ9.ZZ9_NUMCAP = '"  + _aCOLS1[n][nNumCa]  + "' " +;
		     	" GROUP BY ZZ9.ZZ9_DTENTR, ZZ9.ZZ9_HRENTR, ZZ9.ZZ9_DTDEV " +;
		     	" ORDER BY ZZ9.ZZ9_DTENTR, ZZ9.ZZ9_HRENTR, ZZ9.ZZ9_DTDEV "

			_cQuery := changeQuery(_cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "_TRBZZ9", .T., .T.)

			_nCt := 0
			dbSelectArea("_TRBZZ9")
			dbgotop()
			while(!_TRBZZ9->(eof()))
				_nCt++
				_TRBZZ9->(dbSkip())
			enddo

			dbSelectArea("_TRBZZ9")
			dbgotop()
			if _nCt > 0
				If empty(_TRBZZ9->ZZ9_DTDEV)
					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek(xFilial("SB1")+M->TN3_CODEPI)

					MsgStop("O EPC " + ALLTRIM(SB1->B1_DESC) + " num. série " + _aCOLS1[n][nNSer] +;
							" não foi devolvido!")

					_TRBZZ9->(dbCloseArea())
					Return .F.
				endif
			endif
			_TRBZZ9->(dbCloseArea())

			_cQuery := " SELECT MAX(ZZ9.ZZ9_DTDEV) AS DEV, MIN(ZZ9.ZZ9_DTENTR) AS ENTR " +;
				" FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
				" WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' AND " +;
				" 		ZZ9.D_E_L_E_T_ = ' ' AND " +;
				" 		ZZ9.ZZ9_FORNEC = '" + _aCOLS1[n][nPOS3] + "' AND " +;
		     	"		ZZ9.ZZ9_LOJA   = '" + _aCOLS1[n][nPOS4] 	+ "' AND " +;
		     	"		ZZ9.ZZ9_CODEPC = '" + M->TN3_CODEPI + "' AND " +;
		     	"		ZZ9.ZZ9_NUMSER = '" + _aCOLS1[n][nNSer] + "' AND " + ;
		     	"		ZZ9.ZZ9_NUMSEQ <> '" + _aCOLS1[n][nNumSeq] + "' AND " +;
		     	" 		ZZ9.ZZ9_NUMCAP = '"  + _aCOLS1[n][nNumCa]  + "' " +;
		     	" GROUP BY ZZ9.ZZ9_CODEPC " +;
		     	" ORDER BY ZZ9.ZZ9_CODEPC "

			_cQuery := changeQuery(_cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "_TRBZZ9", .T., .T.)

			dbSelectArea("_TRBZZ9")
			dbgotop()
			if _nCt > 0
				If _TRBZZ9->DEV > dtos(_aCOLS1[n][nPOS1])
					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek(xFilial("SB1")+M->TN3_CODEPI)

					MsgStop("O EPC " + ALLTRIM(SB1->B1_DESC) + " num. série " + _aCOLS1[n][nNSer] +;
							" não pode ser entregue nesta data!")

					_TRBZZ9->(dbCloseArea())
					Return .F.
				endif
			endif
			_TRBZZ9->(dbCloseArea())

			// ****************************************************************
			// verifica tempo de uso se já passou.
			dbSelectArea("TN3")
			dbSetOrder(1)         // forn loja epi numcap
			dbSeek(xFilial("TN3") + _aCOLS1[n][nPOS3] + _aCOLS1[n][nPOS4] + M->TN3_CODEPI + _aCOLS1[n][nNumCa])
			_numDias 	  := TN3->TN3_DURABI

			_cQuery := " SELECT SUM(ZZ9_DIASUT) AS DIAS " +;
				" FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
				" WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' AND " +;
				" 		ZZ9.D_E_L_E_T_ = ' ' AND " +;
				" 		ZZ9.ZZ9_FORNEC = '"  + _aCOLS1[n][nPOS3] + "' AND " +;
		     	"		ZZ9.ZZ9_LOJA   = '"  + _aCOLS1[n][nPOS4] 	+ "' AND " +;
		     	"		ZZ9.ZZ9_CODEPC = '"  + M->TN3_CODEPI + "' AND " +;
		     	"		ZZ9.ZZ9_NUMSER = '"  + _aCOLS1[n][nNSer] + "' AND " +;
		     	" 		ZZ9.ZZ9_NUMCAP = '"  + _aCOLS1[n][nNumCa]  + "' " +;
		     	" GROUP BY ZZ9.ZZ9_CODEPC, ZZ9.ZZ9_NUMSER " +;
		     	" ORDER BY ZZ9.ZZ9_CODEPC, ZZ9.ZZ9_NUMSER "

			_cQuery := changeQuery(_cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "_TRBZZ9", .T., .T.)

			If (_numDias <= _TRBZZ9->DIAS .and. _numDias > 0)
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+M->TN3_CODEPI)
				MsgStop("O EPC " + ALLTRIM(SB1->B1_DESC) + " num. série " + ALLTRIM(_aCOLS1[n][nNSer]) +;
						" já atingiu seu tempo máximo de uso.")

				_TRBZZ9->(dbCloseArea())
				Return .F.
			endif

			_TRBZZ9->(dbCloseArea())

			// confere se há encarregado cadastrado na equipe
			_cEncar := ""

			// busca o funcionário responsável pela equipe
			dbSelectArea("ZZ4")
			dbSetOrder(1)
			dbSeek(xfilial("ZZ4")+ALLTRIM(_aCOLS1[n][nEqp]))

			while(ZZ4->ZZ4_EQUIPE = ALLTRIM(_aCOLS1[n][nEqp]))
				if ZZ4->ZZ4_ENCARE == "2"
					_cEncar := ZZ4->ZZ4_CODSRA
				endif
				ZZ4->(dbskip())
			enddo

			if empty(_cEncar)
				dbSelectArea("AA1")
				dbSetOrder(1)
				dbSeek(xFilial("AA1")+_aCOLS1[n][nEqp])
				MsgStop("A equipe " + ALLTRIM(_aCOLS1[n][nEqp]) +;
						" não possui encarregado cadastrado.")
				Return .F.
			endif

			If !lESTNEGA .and. lAlterou
				lInclusao := .t.
				lAuxIF    := .f.
				If lCpoNumSep
					nPosNum   := aSCAN(aCOLSZZ9, {|x| X[nNumseq] == _aCOLS1[n][nNumseq]})
				EndIf

				dbSelectArea("ZZ9")
				dbSetOrder(3)
				If dbSeek(xFilial("ZZ9")+_aCOLS1[n][nPOS3]+_aCOLS1[n][nPOS4]+_aCOLS1[n][nPOS]+_aCOLS1[n][nNSer]+;
						_aCOLS1[n][nNumCa]+_aCOLS1[n][nEqp]+DTOS(_aCOLS1[n][nPOS1])+_aCOLS1[n][nPOS2])
					lInclusao := .f.
				Endif

				If nPosNum == 0 .or. nPosNum <> n
					lAuxIF := .t.
				Endif

				If nPosNum == n
					If nLocalT > 0
						If _aCOLS1[n][nLocalT] <> aCOLSZZ9[nPosNum][nLocalT]
							lAuxIF := .t.
						Endif
					Endif
				Endif

				If lInclusao .or. lAuxIF
					cLocTnf_ := If(ZZ9->(FieldPos("ZZ9_LOCAL"))>0,_aCOLS1[n][nLocalT],"01")
					If !NGSALSB2(_aCOLS1[n][nPOS],cLocTnf_,1)
						Return .f.
					EndIf
				Endif

			EndIf
		EndIf

	else	// _aCOLS1[n][len(_aCOLS1[n])]  ---

		// não deixa excluir se houve devolução!!
		if len(aCOLSZZ9)>= n
			if aCOLSZZ9[n][nDev] $ "34"
				MsgStop("Esse EPC já foi devolvido! O registro não pode ser excluído!")
				_aCOLS1[n][len(_aCOLS1[n])] := .F.
				Return .F.
			endif
		endif

	EndIf

	RestArea(aArea)
Return lRET


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _MDTGeraD3³ Autor ³ Daniela Maria Uez     ³ Data ³ jan/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Movimento de Requisicao e/ou Devolucao nos Arquivos de ³±±
±±³          ³ Movimentacao Interna (SD3).                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numero Sequencial gravado no SD3                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCod = Codigo da movimentação (DE1/RE1)                     ³±±
±±³          ³ tpMov= 1. Requisicao/ 2. Devolucao                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function _MDTGeraD3(cCod, tpMov)

	Local aAreaAnt   := GetArea()
	Local aCm        := {}
	Local aCusto     := {}
	Local cProduto   := ''
	Local cAlmoxa    := CriaVar('D3_LOCAL')
	Local cnumSeqD   := CriaVar('D3_NUMSEQ')
	Local nQtdZZ9    := 0
	Local cLOCZZ9    := Space(Len(sb1->b1_locpad))


	_nTPMov := ""
	if tpMov == 1
		_nTPMov := supergetmv("ML_SAIEPI", .F., "")
	else
		_nTPMov := supergetmv("ML_ENTEPI", .F., "")
	endif

	If empty(_nTPMov)
		MsgStop("Não foi informado o tipo de movimentação do estoque. " +;
				"Confira os parâmetros ML_ENTEPI e ML_SAIEPI.",;
				"Alteração de estoque não efetuada!")
		Return .F.
	endif

	_cEncar := ""

	// busca o funcionário responsável pela equipe
	dbSelectArea("ZZ4")
	dbSetOrder(1)
	dbSeek(xfilial("ZZ4")+ZZ9->ZZ9_EQUIPE)
	while(ZZ4->ZZ4_EQUIPE = ZZ9->ZZ9_EQUIPE)
		if ZZ4->ZZ4_ENCARE = "2"
			_cEncar := ZZ4->ZZ4_CODSRA
		endif
		ZZ4->(dbskip())
	enddo

	Dbselectarea("SRA")
	Dbsetorder(1)
	Dbseek(xfilial("SRA")+_cEncar)

	DbSelectArea("ZZ9")
	If FieldPos("ZZ9_LOCAL") > 0
	   cLOCZZ9 := ZZ9->ZZ9_LOCAL
	EndIf

	cLOCZZ9 := If (Empty(cLOCZZ9),"01",cLOCZZ9)
	cAlmoxa := cLOCZZ9

	cProduto := ZZ9->ZZ9_CODEPC

	Dbselectarea("SB1")
	Dbsetorder(1)
	Dbseek(xfilial("SB1")+cProduto)

	Dbselectarea("SB2")
	Dbsetorder(1)
	If !Dbseek(xfilial("SB2")+cProduto+cLOCZZ9)
	   CriaSB2(cProduto,cLOCZZ9)
	   // A FUNCAO ACIMA NAO LIBERA O REGISTRO
	   MsUnlock("SB2")
	EndIf

	Dbselectarea("SBF")
	Dbsetorder(4)
	Dbseek(xfilial("SBF")+cProduto+ZZ9->ZZ9_NUMSER)

	nQTEMP  := SB2->B2_QEMP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega o proximo numero sequencial de movimento      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cnumSeqD := ProxNum()
	_aAuto := {}
	AADD (_aAuto, {"D3_FILIAL",  	xFilial('SD3'), 	NIL})
	AADD (_aAuto, {"D3_TM",  		_nTPMov, 			NIL})			// tipo de movimento
	AADD (_aAuto, {"D3_COD",  		cProduto, 			NIL})
	AADD (_aAuto, {"D3_UM",  		SB1->B1_UM, 		NIL})
	AADD (_aAuto, {"D3_QUANT",   	1, 					NIL})  // sempre entrega só uma unidade
	AADD (_aAuto, {"D3_CF",   		cCod, 				NIL})
	AADD (_aAuto, {"D3_CONTA",   	SB1->B1_CONTA, 	NIL})
	AADD (_aAuto, {"D3_LOCAL",   	If(Empty(cAlmoxa), SB1->B1_LOCPAD, cAlmoxa), NIL})
	AADD (_aAuto, {"D3_EMISSAO",  ZZ9->ZZ9_DTENTR, 	NIL})
	AADD (_aAuto, {"D3_NUMSEQ",   cnumSeqD, 			NIL})
	AADD (_aAuto, {"D3_SEGUM",   	SB1->B1_SEGUM, 	NIL})
	AADD (_aAuto, {"D3_QTSEGUM",  ConvUm(cProduto,1,0,2), NIL})
	AADD (_aAuto, {"D3_GRUPO",   	SB1->B1_GRUPO, 	NIL})
	AADD (_aAuto, {"D3_TIPO",   	SB1->B1_TIPO,		NIL})
	AADD (_aAuto, {"D3_CHAVE",   	SubStr(cCod,2,1)+If(cCod=='DE4','9','0'), NIL})
	AADD (_aAuto, {"D3_NUMSERI",  ZZ9->ZZ9_NUMSER, 	NIL}) //Número de série do epc entregue
	AADD (_aAuto, {"D3_USUARIO",  SRA->RA_NOME, 		NIL}) //cUserName
	AADD (_aAuto, {"D3_CC",   		SRA->RA_CC, 		NIL})
//	AADD (_aAuto, {"D3_ESTORNO",  SD3->D3_ESTORNO, 	NIL})
	AADD (_aAuto, {"D3_LOCALIZ",  SBF->BF_LOCALIZ, 	NIL})

	If Len(_aAuto) > 0
      lMSErroAuto := .F.
      DbSelectArea("SD3")
      MSExecAuto({|x,y| mata240(x,y)}, _aAuto, 3)    //Inclusão

      If lmserroauto
         MsgAlert("Houve erro na movimentacao de estoque. Verifique na tela seguinte.", procname ())
         MostraErro()
      Endif

      SD3->(dbskip())
      SD3->(dbclosearea())
   	Endif
 	RestArea(aAreaAnt)

Return cnumSeqD

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG630EXCC ³ Autor ³Denis                  ³ Data ³ 30/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Solicita confirmacao de exclusao de epi                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MDTA695                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function NG630EXCC()

	Local nPOS1 := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_MAT" })
	Local nPOS2 := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "ZZ9_DTENTR" })

	If _aCOLS1[n,Len(_aCOLS1[n])]
		cHora695 := Substr(Time(),1,7)
		cEpie695 := _aCOLS1[n,nPOS1]+DTOS(_aCOLS1[n,nPOS2])
		Return .t.
	Else
		If cHora695 <> Substr(Time(),1,7) .or. cEpie695 <> _aCOLS1[n,nPOS1]+DTOS(_aCOLS1[n,nPOS2])
			lRet__ := MsgYesNo("Confirma exclusão do Epi entregue ao funcionário?")
			cHora695 := Substr(Time(),1,7)
			cEpie695 := _aCOLS1[n,nPOS1]+DTOS(_aCOLS1[n,nPOS2])
			Return lRet__
		Else
			cHora695 := "99:99:9"
			cEpie695 := _aCOLS1[n,nPOS1]+DTOS(_aCOLS1[n,nPOS2])
		Endif
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Daniela Maria Uez     ³ Data ³13/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transacao a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra jos Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina

	aRotina := { { OemToAnsi("Pesquisar"),   		"AxPesqui",  	0, 1, 0, .F.},;
				 { OemToAnsi("EPCs x Equipe"),  	"U_fb101ini", 	0, 4, 0, NIL} }

    //{ OemToAnsi("Pesquisar"),   		"AxPesqui",  	0, 1, 0, .F.},;
Return aRotina

Static Function Grava(aCols)
Local nX:= 0

For nX:= 1 To Len(aCols)
	dbSelectArea("ZZ9")
	dbSetOrder(1)
	//ZZ9_FILIAL, ZZ9_CODEPC, ZZ9_NUMSER, ZZ9_EQUIPE, ZZ9_NUMCAP
	dbSeek(xFilial("ZZ9")+aCols[nX, 14]+aCols[nX, 5]+aCols[nX, 2])

	If Found()
		RecLock("ZZ9", .F.)
	Else
		RecLock("ZZ9", .T.)
		ZZ9->ZZ9_FILIAL:= xFilial("ZZ9")
	EndIf

	ZZ9->ZZ9_NUMSER:= aCols[nX, 5]
	ZZ9->ZZ9_EQUIPE:= aCols[nX, 2]
	ZZ9->ZZ9_DTENTR:= aCols[nX, 7]
	ZZ9->ZZ9_HRENTR:= aCols[nX, 8]
	ZZ9->ZZ9_DTDEV:= aCols[nX, 9]
	ZZ9->ZZ9_DIASUT:= aCols[nX, 12]
	ZZ9->ZZ9_MOTIVO:= aCols[nX, 10]
	ZZ9->ZZ9_LOCAL:= aCols[nX, 6]
	ZZ9->ZZ9_NUMSEQ:= aCols[nX, 13]
	ZZ9->ZZ9_CODEPC:= aCols[nX, 14]
	ZZ9->ZZ9_FORNEC:= aCols[nX, 15]
	ZZ9->ZZ9_LOJA:= aCols[nX, 16]
	ZZ9->ZZ9_NUMCAP:= aCols[nX, 17]
	ZZ9->ZZ9_DEV:= aCols[nX, 11]
	ZZ9->ZZ9_ENDLOC:= aCols[nX, 4]
	ZZ9->ZZ9_ETIQ:= aCols[nX, 1]
	MsUnLock()
Next nX

Return .T.