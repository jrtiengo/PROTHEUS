#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA001     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Cadastro de Fatores de Avaliação                   |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |função a ser executada                              |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |                                                    |
+----------+----------------------------------------------------+
|Uso       |Estoque/Custos - Sirtec                             |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/                    

User Function STCA001

	Private cAlias := "ZZ1"

	Private cCadastro := "Cadastro de Fatores de Avaliação"

// Array com os botões do Browse
	Private aRotina   := {	{OemToAnsi("Pesquisar"),	"AxPesqui",		0, 1, 0, .F.},;
		{OemToAnsi("Visualizar"),	"U_STCA001A",	0, 2, 0, NIL},;
		{OemToAnsi("Incluir"),		"U_STCA001A",	0, 3, 0, NIL},;
		{OemToAnsi("Alterar"),		"U_STCA001A",	0, 4, 0, NIL},;
		{OemToAnsi("Excluir"),		"U_STCA001A",	0, 5, 0, NIL}}

	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbGoTop()

	mBrowse( 6,1,22,75,cAlias)
Return

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA01A     | Microsiga Vitória | Data | 03.04.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Função Modelo 2                                    |
|          |                                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Motivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/                    

User Function STCA001A(cAlias,nReg,nOpc)

	Private _aAcolAnt := {}

	Private nOpcx:= nOpc // Opção Escolhida
	Private cGrupo := ""
	Private cForm  := ""
	Private cDesc  := ""
	Private aCols  := {}
	Private _cSX3  := GetNextAlias()
//+-----------------------------------------------+
//¦ Montando aHeader                              ¦
//+-----------------------------------------------+

	//DbSelectArea("Sx3")
	//DbSetOrder(1)
	//DbSeek("ZZ1")

	nUsado:=0

	aHeader:={}

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1))
		(_cSX3)->(dbSeek("ZZ1"))
		if (Found())
			While ( !(_cSX3)->(Eof()) .And.  &("(_cSX3)->X3_ARQUIVO") == "ZZ1" )
				If Alltrim(  &("(_cSX3)->x3_campo")) $ "ZZ1_FORM,ZZ1_FORMUL,ZZ1_DESC" // Não mostra no Acols os campos informados na String
					DbSkip()
					Loop
				EndIf

				IF (X3USO( &("(_cSX3)->x3_usado")) .AND. cNivel >=  &("(_cSX3)->x3_nivel"))

					nUsado:= nUsado + 1

					AADD(aHeader,{ TRIM(  &("(_cSX3)->x3_titulo")),  &("(_cSX3)->x3_campo"),  &("(_cSX3)->x3_picture"),  &("(_cSX3)->x3_tamanho"),  &("(_cSX3)->x3_decimal"),;
						, &("(_cSX3)->x3_usado"),  &("(_cSX3)->x3_tipo"),  &("(_cSX3)->x3_arquivo"),  &("(_cSX3)->x3_context") } )

				Endif
				(_cSX3)->(DBSkip())
			EndDo
		endif
	Endif
	(_cSX3)->(dbCloseArea())


/*
	While !Eof() .And. (x3_arquivo == "ZZ1")
	
		If Alltrim(x3_campo) $ "ZZ1_FORM,ZZ1_FORMUL,ZZ1_DESC" // Não mostra no Acols os campos informados na String
		DbSkip()
		Loop
		EndIf

		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		
		nUsado:=nUsado + 1
		
		AADD(aHeader,{ TRIM(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,;
		,x3_usado,x3_tipo, x3_arquivo, x3_context } )
		
		Endif
	
	dbSkip()
	
	EndDo
*/	



	nUsado:=0
	_cSX32  := GetNextAlias()
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX32,"SX3",Nil,.F.)
	lOpen := Select(_cSX32) > 0
	If (lOpen)
		dbSelectArea(_cSX32)
		(_cSX32)->(dbSetOrder(1))
		(_cSX32)->(dbSeek("ZZ1"))
		if (Found())
			While ( !(_cSX32)->(Eof()) .And.  &("(_cSX32)->X3_ARQUIVO") == "ZZ1" )
				
				If Alltrim((&("(_cSX32)->x3_campo"))) $ "ZZ1_FORM,ZZ1_FORMUL,ZZ1_DESC" // Não mostra no Acols os campos informados na String
					DbSkip()
					Loop
				EndIf

				IF X3USO( &("(_cSX32)->x3_usado")) .AND. cNivel >= &("(_cSX32)->x3_nivel")
					nUsado:=nUsado+1
					IF nOpcx == 3
						IF &("(_cSX32)->x3_tipo") == "C"
					aCOLS[1][nUsado] := SPACE( &("(_cSX32)->x3_tamanho"))
						Elseif &("(_cSX32)->x3_tipo") == "N"
					aCOLS[1][nUsado] := 0
						Elseif &("(_cSX32)->x3_tipo") == "D"
					aCOLS[1][nUsado] := dDataBase
						Elseif &("(_cSX32)->x3_tipo") == "M"
					aCOLS[1][nUsado] := ""
						Else
					aCOLS[1][nUsado] := .F.
						Endif
					Endif
				Endif

				(_cSX32)->(DBSkip())
			EndDo
		endif
	Endif
	(_cSX32)->(dbCloseArea())


	aCols:=Array(1,nUsado+1)


	/*DbSelectArea("Sx3")
	DbSeek("ZZ1")

	nUsado:=0

	While !Eof() .And. (x3_arquivo == "ZZ1")
		If Alltrim(x3_campo) $ "ZZ1_FORM,ZZ1_FORMUL,ZZ1_DESC" // Não mostra no Acols os campos informados na String
			DbSkip()
			Loop
		EndIf

		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado:=nUsado+1
			IF nOpcx == 3
				IF x3_tipo == "C"
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
				Elseif x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				Elseif x3_tipo == "D"
					aCOLS[1][nUsado] := dDataBase
				Elseif x3_tipo == "M"
					aCOLS[1][nUsado] := ""
				Else
					aCOLS[1][nUsado] := .F.
				Endif
			Endif
		Endif
		dbSkip()
	End*/


	If nOpcx <> 3 // Se Inclusão
		aCols := {}
		DbSelectArea("ZZ1")
		DbSetOrder(1)
		_cGrupo := ZZ1->ZZ1_FORM // Guarda a Formula do registro posicionado
		cGrupo	:= ZZ1->ZZ1_FORM
		_cForm  := ZZ1->ZZ1_FORMUL
		cForm   := ZZ1->ZZ1_FORMUL
		_cDesc  := ZZ1->ZZ1_DESC
		cDesc   := ZZ1->ZZ1_DESC

		DbGoTop()
		DbSeek(xFilial("ZZ1")+_cGrupo)
		While !EOF() .And. ZZ1->ZZ1_FILIAL+ZZ1->ZZ1_FORM = xFilial("ZZ1")+_cGrupo
			Aadd(aCols,{ZZ1->ZZ1_FATOR,ZZ1->ZZ1_NOME,ZZ1->ZZ1_NOTAS,ZZ1->ZZ1_CAMPO,ZZ1_DESCNT,.f.})
			Aadd(_aAColAnt,{ZZ1->ZZ1_FATOR,ZZ1->ZZ1_NOME,ZZ1->ZZ1_NOTAS,ZZ1->ZZ1_CAMPO,ZZ1_DESCNT,.f.})
			DbSkip()
		EndDo
	Else
		aCOLS[1][nUsado+1] := .F.
		cGrupo := Space(3)
		cForm  := Space(100)
		cDesc  := Space(30)
	EndIf

	nLinGetD:=0

	cTitulo:="Fatores de Avaliação"

	aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em
//           Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel t. se nao .f.

	#IFDEF WINDOWS

		AADD(aC,{"cGrupo" ,{15,10} ,"Formula   ","@!","ExistChav('ZZ1',cGrupo,1)",,Iif(ALTERA,.f.,.t.)})
		AADD(aC,{"cDesc"  ,{15,60} ,"Descricao ","@!",,,})
		AADD(aC,{"cForm"  ,{30,10} ,"Equacao   ","@!",,,})

	#ELSE

		AADD(aC,{"cGrupo" ,{15,10} ,"Formula   ","@!","ExistChav('ZZ1',cGrupo,1)",,Iif(ALTERA,.f.,.t.)})
		AADD(aC,{"cDesc"  ,{15,60} ,"Descricao ","@!",,,})
		AADD(aC,{"cForm"  ,{30,50} ,"Equacao   ","@!",,,})

	#ENDIF

//+-------------------------------------------------+
//¦ Array com descricao dos campos do Rodape        ¦
//+-------------------------------------------------+

		aR:={}

// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em
//           Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel t. se nao .f.

		#IFDEF WINDOWS

			AADD(aR,{"nLinGetD" ,{120,10},"Linha na GetDados","@E 999",,,.F.})

		#ELSE

			AADD(aR,{"nLinGetD" ,{19,05},"Linha na GetDados","@E 999",,,.F.})

		#ENDIF

//+------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2   ¦
//+------------------------------------------------+

			#IFDEF WINDOWS
				aCGD:={80,5,118,315}
			#ELSE
				aCGD:={10,04,15,73}
			#ENDIF

//+----------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2           ¦
//+----------------------------------------------+

				cLinhaOk := "U_STCA001C(n)" //"ExecBlock('SIRTA001B',.f.,.f.)"
				cTudoOk  := "AlwaysTrue()"

// lRet = .t. se confirmou
// lRet = .f. se cancelou

				lRet:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,,,.T.)

				If lRet
					fProcessa()
				EndIf

				Return

// Função para Processar o Cadastro
Static Function fProcessa()

// nOpcx = 2 // Visualizar
// nOpcx = 3 // Incluir
// nOpcx = 4 // Alterar
// nOpcx = 5 // Excluir

	If nOpcx = 3

		I := 0

		For I := 1 To Len(aCols)

			If aCols[I][(LEN(AHEADER)+1)] = .t. // Testa se o item está deletado
				Loop
			EndIf

			RecLock("ZZ1",.T.)

			ZZ1->ZZ1_FILIAL		:= xFilial("ZZ1")
			ZZ1->ZZ1_FORM  		:= cGrupo
			ZZ1->ZZ1_FORMUL     := cForm
			ZZ1->ZZ1_DESC       := cDesc
			ZZ1->ZZ1_FATOR  	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_FATOR"})]
			ZZ1->ZZ1_NOME   	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_NOME"})]
			ZZ1->ZZ1_NOTAS      := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_NOTAS"})]
			ZZ1->ZZ1_CAMPO      := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_CAMPO"})]
			ZZ1->ZZ1_DESCNT     := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_DESCNT"})]

			MsUnLock()
		Next

	ElseIf nOpcx = 5

		I := 0

		DbSelectArea("ZZ1")
		DbGoTop()
		DbsetOrder(1)
		For I := 1 To Len(aCols)
			If DbSeek(xFilial("ZZ1")+cGrupo)
				RecLock("ZZ1",.f.)
				DbDelete()
				MsUnlock()
			EndIf
		Next

	ElseIf nOpcx = 4

		I := 0

		DbSelectArea("ZZ1")
		DbGoTop()
		DbsetOrder(1)
		For I := 1 To Len(_aAcolAnt)
			If DbSeek(xFilial("ZZ1")+cGrupo)
				RecLock("ZZ1",.f.)
				DbDelete()
				MsUnlock()
			EndIf
		Next

		I := 0

		For I := 1 To Len(aCols)

			If aCols[I][(LEN(AHEADER)+1)] = .T.  // Testa se o item está deletado
				Loop
			EndIf

			RecLock("ZZ1",.T.)

			ZZ1->ZZ1_FILIAL		:= xFilial("ZZ1")
			ZZ1->ZZ1_FORM  		:= cGrupo
			ZZ1->ZZ1_FORMUL      := cForm
			ZZ1->ZZ1_DESC       := cDesc
			ZZ1->ZZ1_FATOR  	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_FATOR"})]
			ZZ1->ZZ1_NOME   	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_NOME"})]
			ZZ1->ZZ1_NOTAS      := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_NOTAS"})]
			ZZ1->ZZ1_CAMPO      := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_CAMPO"})]
			ZZ1->ZZ1_DESCNT     := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ1_DESCNT"})]
			MsUnLock()
		Next

	EndIf
Return()

/*
+----------+------------+-------------------+------+------------+
|Programa  | STCA01B    | Microsiga Vitória | Data | 03.04.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação do campo ZZ1_CAMPO                       |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |                                                    |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   | Variavel Logica                                    |
+----------+----------------------------------------------------+
|Uso       |STCA01 - Fatores de Avaliação - Estoque - Sirtec    |
+----------+----------------------------------------------------+
*/
User Function STCA001B

	Private lRet	 := .F.
	Private _cSX33	 := GetNextAlias()
	//Private aSX3Area := SX3->(GetArea())

	If Left(M->ZZ1_CAMPO,8) == 'ZZ2_NOTA'

		//SX3->(DbSetOrder(2))
		//If SX3->(DbSeek(ZZ1_CAMPO))
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX33,"SX3",Nil,.F.)
		lOpen := Select(_cSX33) > 0
		If (lOpen)
  			dbSelectArea(_cSX33)
  			(_cSX33)->(dbSetOrder(2)) //X3_CAMPO
  			(_cSX33)->(dbSeek(ZZ1_CAMPO))
			If (Found())
				lRet := .T.
			Else
				MsgStop("Esse campo não foi encontrado na tabela ZZ2, efetue a criação deste campo pelo configurador. STCA01B.","STCA01B")
			Endif
		Endif
		(_cSX33)->(dbCloseArea())
		
	Else
		MsgStop("Devem ser utilizados somente os campos da tabela ZZ2 e com nome NOTA. STCA01B.","STCA01B")
	Endif

	For i:=1 to Len(aCols)
		If  !GdDeleted(i) .and. GdFieldGet("ZZ1_CAMPO",i) == M->ZZ1_CAMPO
			lRet := .F.
			MsgStop("O campo " + M->ZZ1_CAMPO + " está sendo utilizado no fator " + GdFieldGet("ZZ1_FATOR",i) + ". ";
				+ "Utilize outro campo. STCA01B.","STCA01B")
		Endif
	Next i

	//Restarea(aSX3Area)
	
Return lRet


/*
+----------+------------+-------------------+------+------------+
|Programa  | STCA01C    | Microsiga Vitória | Data | 03.04.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação da linhaOK                               |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |                                                    |
+----------+----------------------------------------------------+
|Parametros| nLinha - linha a ser validada                      |
+----------+----------------------------------------------------+
|Retorno   | Variavel Logica                                    |
+----------+----------------------------------------------------+
|Uso       |STCA01 - Fatores de Avaliação - Estoque - Sirtec    |
+----------+----------------------------------------------------+
*/
User Function STCA001C(nLin)

	Private lRet := .T.
	Private cString := GdFieldGet("ZZ1_NOTAS",nLin)
	Private aFator := {}

//Verifica se a linha esta deletada
	If GdDeleted()
		Return .T.
	Endif

	Do Case

	Case Empty(GdFieldGet("ZZ1_FATOR",nLin))
		MsgStop("O campo ZZ1_FATOR está em branco para linha " + Alltrim(Str(nLin)) + ". Preencha o campo. STCA01C.","STCA01C")
		lRet := .F.
		Return lRet

	Case Empty(GdFieldGet("ZZ1_NOME",nLin))
		MsgStop("O campo ZZ1_NOME está em branco para linha " + Alltrim(Str(nLin)) + ". Preencha o campo. STCA01C.","STCA01C")
		lRet := .F.
		Return lRet

	Case Empty(GdFieldGet("ZZ1_NOTAS",nLin))
		MsgStop("O campo ZZ1_NOTAS está em branco para linha " + Alltrim(Str(nLin)) + ". Preencha o campo. STCA01C.","STCA01C")
		lRet := .F.
		Return lRet

	Case Empty(GdFieldGet("ZZ1_CAMPO",nLin))
		MsgStop("O campo ZZ1_CAMPO está em branco para linha " + Alltrim(Str(nLin)) + ". Preencha o campo. STCA01C.","STCA01C")
		lRet := .F.
		Return lRet
	Endcase

	aFator := U_STCA001D(cString)

	For i:=1 to Len(aFator)
		If aFator[i,1] <> StrZero(aFator[i,2],2)
			MsgStop("A Nota de numero " + Alltrim(Str(i)) + " não está correta, verifique. STCA01C.","STCA01C")
			lRet := .F.
			Return lRet
		Endif
	Next i


Return lRet

/*
+----------+------------+-------------------+------+------------+
|Programa  | STCA01D    | Microsiga Vitória | Data | 03.04.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Transforma as Notas liberadas para o fator de      |
|          | CARACTER PARA MUNERICA                             |
+----------+----------------------------------------------------+
|Sintaxe   |                                                    |
+----------+----------------------------------------------------+
|Parametros| cNotas - notas cadastradas                         |
+----------+----------------------------------------------------+
|Retorno   | array com as caracteres digitados                  |
|          | array com as notas no formato numerico             | 
+----------+----------------------------------------------------+
|Uso       |STCA01 - Fatores de Avaliação - Estoque - Sirtec    |
+----------+----------------------------------------------------+
*/

User Function STCA001D(cNotas)

	Private aArr	:= {}
	Private aElem	:= {}
	Private aRet	:= {}

	While Len(cNotas) > 0
		AADD(aElem,Parse(@cNotas))
	End

	aArr := aClone( aElem )

	FOR i:=1 TO Len(aArr)
		If !Empty(aArr[i])
			aArr[i]:=Val(aArr[i])
			AADD(aRet,{aElem[i],aArr[i]})
		Endif
	Next i

Return aRet

/*
+----------+------------+-------------------+------+------------+
|Programa  | STCA01E    | Microsiga Vitória | Data | 03.04.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação do campo ZZ1_FATOR                       |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |                                                    |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   | Variavel Logica                                    |
+----------+----------------------------------------------------+
|Uso       |STCA01 - Fatores de Avaliação - Estoque - Sirtec    |
+----------+----------------------------------------------------+
*/
User Function STCA001E

	Private lRet := .T.

	For i:=1 to Len(aCols)
		If  !GdDeleted(i) .and. GdFieldGet("ZZ1_FATOR",i) == M->ZZ1_FATOR
			lRet := .F.
			MsgStop("O fator " + M->ZZ1_FATOR + " está sendo utilizado no item " + GdFieldGet("ZZ1_FATOR",i) + ". ";
				+ "Ajuste a informação. STCA01B.","STCA01B")
		Endif
	Next i

Return lRet
