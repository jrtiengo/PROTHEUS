#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA033     | Microsiga         | Data | 05.09.2008 |
+----------+------------+-------------------+------+------------+
|Descrição | Cadastro de Materiais x Endereço                   |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |função a ser executada                              |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |                                                    |
+----------+----------------------------------------------------+
|Uso       |Estoque - Sirtec                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/                    
User Function STCA033()

	Private cAlias    := "ZZ8"
	Private cCadastro := "Cadastro Materiais x Endereço"

// Array com os botões do Browse
	Private aRotina   := {	{OemToAnsi("Pesquisar"),	"AxPesqui",		0, 1, 0, .F.},;
		{OemToAnsi("Visualizar"),	"U_STCA033A",	0, 2, 0, NIL},;
		{OemToAnsi("Incluir"),		"U_STCA033A",	0, 3, 0, NIL},;
		{OemToAnsi("Alterar"),		"U_STCA033A",	0, 4, 0, NIL},;
		{OemToAnsi("Excluir"),		"U_STCA033A",	0, 5, 0, NIL},;
		{OemToAnsi("Copiar"),		"U_STCA033B",	0, 3, 0, NIL}}

	dbSelectArea(cAlias)
	dbSetOrder(1)
	DbGoTop()

	mBrowse( 6,1,22,75,cAlias)
Return

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA033A    | Microsiga         | Data | 05.09.2008 |
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

User Function STCA033A(cAlias,nReg,nOpc)

//Variaveis de controle das informações do cabeçalho
	Local cCpoCabec := 'ZZ8_LOCAL /ZZ8_END   '
	Private cMLocal   := ''
	Private cMEnd     := ''

//Variaveis de execução
	Private _aAcolAnt := {}
	Private nOpcx     := nOpc // Opção Escolhida
	Private aCols     := {}
	Private cChaveMod := 'ZZ8->ZZ8_FILIAL+ZZ8->ZZ8_LOCAL+ZZ8->ZZ8_END'  //Chave de controle do registro no modelo 2
	Private cChave    := ''   											//Chave de controle do registro no modelo 2
	Private _cSX3 	:= GetNextAlias()
	Private _cSX32 	:= GetNextAlias()

//+-----------------------------------------------+
//¦ Montando aHeader                              ¦
//+-----------------------------------------------+
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1)) //X3_CAMPO
		(_cSX3)->(dbSeek(cAlias))
		
		nUsado:=0
		aHeader:={}
		
		While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == cAlias )

			If (Alltrim( &("(_cSX3)->x3_campo")) $ cCpoCabec ) // Não mostra no Acols os campos informados na String
				(_cSX3)->(DbSkip())
				Loop
			EndIf

			IF X3USO( &("(_cSX3)->X3_USADO")) .AND. cNivel >= &("(_cSX3)->X3_NIVEL")
		
				nUsado:=nUsado + 1
				AADD(aHeader,{ TRIM( &("(_cSX3)->x3_titulo")), &("(_cSX3)->x3_campo") , &("(_cSX3)->x3_picture") , &("(_cSX3)->x3_tamanho"), &("(_cSX3)->x3_decimal"),;
			   ,&("(_cSX3)->x3_usado"), &("(_cSX3)->x3_tipo"), &("(_cSX3)->x3_arquivo"), &("(_cSX3)->x3_context") } )
																	            										 
			Endif

			(_cSX3)->(DBSkip())
		EndDo		
	endif
	(_cSX3)->(dbCloseArea())

/*
DbSelectArea("Sx3")
DbSetOrder(1)
DbSeek(cAlias)
nUsado:=0
aHeader:={}

	While !Eof() .And. (x3_arquivo == cAlias)
	
		If Alltrim(x3_campo) $ cCpoCabec // Não mostra no Acols os campos informados na String
		DbSkip()
		Loop
		EndIf

		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		
		nUsado:=nUsado + 1
		AADD(aHeader,{ TRIM(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,   ,x3_usado,x3_tipo, x3_arquivo, x3_context } )
																	             //validacao
		Endif
	
	DbSkip()
	EndDo
*/


//+-----------------------------------------------+
//¦ Montando aCols                                ¦
//+-----------------------------------------------+
	aCols:=Array(1,nUsado+1)

	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX32,"SX3",Nil,.F.)
	lOpen := Select(_cSX32) > 0
	If (lOpen)
		dbSelectArea(_cSX32)
		(_cSX32)->(dbSetOrder(1)) //X3_CAMPO
		(_cSX32)->(dbSeek(cAlias))
		
		nUsado:=0
		aHeader:={}
		
		While ( !(_cSX32)->(Eof()) .And. &("(_cSX32)->X3_ARQUIVO") == cAlias )

			If (Alltrim( &("(_cSX32)->x3_campo")) $ cCpoCabec) // Não mostra no Acols os campos informados na String
				(_cSX32)->(DbSkip())
				Loop
			EndIf

			IF (X3USO( &("(_cSX32)->x3_usado")) .AND. cNivel >= &("(_cSX32)->x3_nivel"))
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
	(_cSX32)->(dbCloseArea())

	
	/*DbSelectArea("SX3")
	DbSeek(cAlias)
	nUsado:=0

	While !Eof() .And. (x3_arquivo == cAlias)
		If Alltrim(x3_campo) $ cCpoCabec // Não mostra no Acols os campos informados na String
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
	End
	*/

//+-----------------------------------------------+
//¦ Execução da rotina                            ¦
//+-----------------------------------------------+
	If nOpcx <> 3 // Se Inclusão
		aCols := {}
		DbSelectArea(cAlias)
		DbSetOrder(1)
		//Controla chave do registro
		cChave := ZZ8->ZZ8_LOCAL+ZZ8->ZZ8_END

		//Varivaveis do cabeçalho
		cMEnd   := ZZ8->ZZ8_END
		cMLocal := ZZ8->ZZ8_LOCAL

		DbGoTop()
		DbSeek(xFilial(cAlias)+cChave)
		While !EOF() .And. &cChaveMod = xFilial(cAlias)+cChave

			Aadd(aCols    ,{ZZ8->ZZ8_PRODUT,ZZ8->ZZ8_QUANT,.f.})
			Aadd(_aAColAnt,{ZZ8->ZZ8_PRODUT,ZZ8->ZZ8_QUANT,.f.})
			DbSkip()
		EndDo
	Else
		aCOLS[1][nUsado+1] := .F.
		cMEnd   := Space(TamSX3('ZZ8_END')[1])
		cMLocal := Space(TamSX3('ZZ8_LOCAL')[1])
	EndIf



//+-----------------------------------------------+
//¦ Monta cabeçalho da rotina                     ¦
//+-----------------------------------------------+

	nLinGetD:=0
	cTitulo:=cCadastro
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

		AADD(aC,{"cMLocal"   ,{15,10} ,"Armazem" ,"@!",,"SBE-1",})
		AADD(aC,{"cMEnd"     ,{15,200},"Endereço","@!",,,})
	#ELSE

		AADD(aC,{"cMLocal"   ,{6,5} ,"Armazem" ,"@!",,,})
		AADD(aC,{"cMEnd"     ,{6,40},"Endereço","@!",,,})
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
				aCGD:={44,5,118,315}
			#ELSE
				aCGD:={10,04,15,73}
			#ENDIF

//+----------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2           ¦
//+----------------------------------------------+

				cLinhaOk := "AlwaysTrue()" //"ExecBlock('Md2LinOk',.f.,.f.)"
				cTudoOk  := "AlwaysTrue()" //"ExecBlock('Md2TudOk',.f.,.f.)"

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

			If aCols[I][Len(aHeader)+1] = .t. // Testa se o item está deletado
				Loop
			EndIf

			RecLock(cAlias,.T.)

			ZZ8->ZZ8_FILIAL		:= xFilial(cAlias)
			ZZ8->ZZ8_LOCAL 		:= cMLocal
			ZZ8->ZZ8_END   		:= cMEnd
			ZZ8->ZZ8_PRODUT		:= GdFieldGet("ZZ8_PRODUT",I)
			ZZ8->ZZ8_QUANT 		:= GdFieldGet("ZZ8_QUANT",I)
			MsUnLock()
		Next

	ElseIf nOpcx = 5

		I := 0

		DbSelectArea(cAlias)
		DbGoTop()
		DbsetOrder(1)

		For I := 1 To Len(aCols)
			If DbSeek(xFilial(cAlias)+cMLocal+cMEnd)
				RecLock(cAlias,.F.)
				DbDelete()
				MsUnlock()
			EndIf
		Next

	ElseIf nOpcx = 4

		I := 0

		DbSelectArea(cAlias)
		DbGoTop()
		DbsetOrder(1)
		For I := 1 To Len(_aAcolAnt)
			If DbSeek(xFilial(cAlias)+cMLocal+cMEnd)
				RecLock(cAlias,.F.)
				DbDelete()
				MsUnlock()
			EndIf
		Next

		I := 0

		For I := 1 To Len(aCols)

			If aCols[I][Len(aHeader)+1] = .t.  // Testa se o item está deletado
				Loop
			EndIf


			RecLock(cAlias,.T.)

			ZZ8->ZZ8_FILIAL		:= xFilial(cAlias)
			ZZ8->ZZ8_LOCAL 		:= cMLocal
			ZZ8->ZZ8_END   		:= cMEnd
			ZZ8->ZZ8_PRODUT		:= GdFieldGet("ZZ8_PRODUT",I)
			ZZ8->ZZ8_QUANT 		:= GdFieldGet("ZZ8_QUANT",I)
			MsUnLock()

		Next

	EndIf

Return

/*/
	+----------+------------+-------------------+------+------------+
	|Programa  |STCA033B    | Microsiga Vitória | Data | 01.08.2007 |
	+----------+------------+-------------------+------+------------+
	|Descrição |Copia de materiais                                  |
	|          |                                                    |
	+----------+----------------------------------------------------+
	|Sintaxe   |Processamento                                       |
	+----------+----------------------------------------------------+
	|Parametros|#                                                   |
	+----------+----------------------------------------------------+
	|Retorno   |#                                                   |
	+----------+----------------------------------------------------+
	|Uso       |Estoque -> Sirte                                    |
	+----------+----------------------------------------------------+
	|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
	+------------+--------+-----------+-----------------------------+
	|Função      |Data    |Programador| Mutivo da Alteraçao         |
	+------------+--------+-----------+-----------------------------+
	|            |00.00.00|           |                             |
	+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA033B

	//Variaveis Locais de Controle da rotina
	Local cPerg := padr("STC033", 10 , " ") //padr("STC033", LEN(SX1->X1_GRUPO), " ")
	Local aArea := GetArea()

	//Variaveis de controle da rotina
	Private aCampos := {}				//Controla campos da MSSelect
	Private aCpoBrw := {}				//Controla cabeçalho da MSSelect
	Private aHeadA	:= {}				//Controla cabeçalho da GetDados
	Private aColsA	:= {}				//Controla campos da GetDados
	Private cMarca  := GetMark()
	Private cLocal  := ''
	Private cEnd	:= ''
	Private nOpc

	//Variaveis de controle dos objetos
	Private oDlgSTC			//Dialog
	Private oFont			//Fonte utilizada
	Private oGet01			//Getdados
	Private oTCab1			//Titulo no Cabeçalho
	Private oICab1			//Informação no Cabeçalho
	Private oTCab2			//Titulo no Cabeçalho
	Private oICab2			//Informação no Cabeçalho
	Private oTCab3			//Titulo no Cabeçalho
	Private oICab3			//Informação no Cabeçalho
	Private oGetDado		//Getdados

	//Parâmetros iniciais
	If !Pergunte(cPerg,.T.)
		Return
	Else
		cLocal   := MV_PAR01
		cEnd     := MV_PAR02
	Endif

	If Empty(cLocal) .or. Empty(cEnd)
		MsgInfo('Não podem ser selecionados itens com o armazem ou endereço em branco.','Copia de material')
		Return
	Endif

	//Processamento da tela.
	MsAguarde({|| fSTCA001()},'Criando relacionamento','Copia de material')

	//////////////////////////////////////////
	// Monta Tela de seleção dos registros  //
	//////////////////////////////////////////
	Eval({||fSTCA003()})

	//////////////////////////////////////////
	// Monta Tela de confirmação dos dados  //
	//////////////////////////////////////////
	If nOpc ==1    									//nOpc == 1 (OK); nOpc == 2 (Cancela)

		//Processamento da tela.
		MsAguarde({|| fSTCA004()},'Gravando copias de materiais','Copia de material')
	EndIf

	RestArea(aArea)
Return

/*/
	+----------+----------+-------+-----------------------+------+------------+
	|Função    |fSTCA001  | Autor |Microsiga Vitória      | Data |09.10.2007  |
	+----------+----------+-------+-----------------------+------+------------+
	|Descrição |Cria informações para a consulta                              |
	+----------+--------------------------------------------------------------+
	|Retorno   |#                                                             |
	+----------+--------------------------------------------------------------+
	|Parâmetros|#                                                             |
	+----------+--------------------------------------------------------------+
	|Uso       |Estoque -> Sirtec                                             |
	+----------+--------------------------------------------------------------+
	| Atualizacoes sofridas desde a Construcao Inicial.                       |
	+----------+--------------------------------------------------------------+
	| Data     | Descrição                                                    |
	+----------+--------------------------------------------------------------+
	|          |                                                              |
	+----------+--------------------------------------------------------------+
/*/

Static Function fSTCA001(nOpc)

	Local 	cSQL	 := ""
	Private _cTRB1	 := GetNextAlias() //Alias Tabela Temporária

	//Cria arquivo temporário
	aAdd(aCampos,{"MARCA"     ,"C",02,0}                     )
	aAdd(aCampos,{"ARMAZEM"   ,"C",TamSX3("BE_LOCAL")[1]  ,0})
	aAdd(aCampos,{"ENDERECO"  ,"C",TamSX3("BE_LOCALIZ")[1],0})

	/*If Select("ARQTRB")>1
		ARQTRB->(DbCloseArea())
	End If
	ARQTRB := CriaTrab(aCampos,.T.)
	DbUseArea(.T.,,ARQTRB,"ARQTRB",.F.)*/

	//-------------------
	//Criação do objeto
	//-------------------
	If (Select(_cTRB1) > 0)
	    oTempTab1:Delete()
	EndIf
	oTempTab1 := FWTemporaryTable():New( _cTRB1, aCampos  )
	oTempTab1:AddIndex("01", {aCampos[1] + aCampos[2] + aCampos[3]} )	
	oTempTab1:Create()


	aAdd(aCpoBrw,{"MARCA"     ,,""})
	aAdd(aCpoBrw,{"ARMAZEM"   ,,RetTitle("BE_LOCAL")  })
	aAdd(aCpoBrw,{"ENDERECO"  ,,RetTitle("BE_LOCALIZ")})

	SBE->(DbSetOrder(1))
	SBE->(DbGoTop())
	While !SBE->(Eof())

		If cLocal+cEnd <> SBE->BE_LOCAL + SBE->BE_LOCALIZ
			(_cTRB1)->(DBAppend())
				(_cTRB1)->MARCA	:= ""
				(_cTRB1)->ARMAZEM := SBE->BE_LOCAL
				(_cTRB1)->ENDERECO:= SBE->BE_LOCALIZ
			(_cTRB1)->(DBCommit())

			/*Reclock("ARQTRB",.T.)
			ARQTRB->MARCA	:= ""
			ARQTRB->ARMAZEM := SBE->BE_LOCAL
			ARQTRB->ENDERECO:= SBE->BE_LOCALIZ
			MsUnlock()*/
		Endif

		SBE->(Dbskip())
	EndDo

	//Controle da posição que o acols será exibido
	//DbSelectArea("ARQTRB")
	DbSelectArea(_cTRB1)
	DbGoTop()

Return

/*/
	+----------+----------+-------+-----------------------+------+------------+
	|Função    |fSTCA002  | Autor |Microsiga Vitória      | Data |09.10.2007  |
	+----------+----------+-------+-----------------------+------+------------+
	|Descrição |Atualiza campo de controle (marca)                            |
	+----------+--------------------------------------------------------------+
	|Retorno   |                                                              |
	+----------+--------------------------------------------------------------+
	|Parâmetros|                                                              |
	+----------+--------------------------------------------------------------+
	|Uso       |Estoque -> Sirtec                                             |
	+----------+--------------------------------------------------------------+
	| Atualizacoes sofridas desde a Construcao Inicial.                       |
	+----------+--------------------------------------------------------------+
	| Data     | Descrição                                                    |
	+----------+--------------------------------------------------------------+
	|          |                                                              |
	+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA002

	/*RecLock("ARQTRB",.F.)
	ARQTRB->MARCA := Iif(ARQTRB->MARCA!=cMarca,cMarca,"")
	MsUnlock()*/
	RecLock(_cTRB1,.F.)
		(_cTRB1)->MARCA := Iif((_cTRB1)->MARCA!=cMarca,cMarca,"")
	(_cTRB1)->(MsUnlock())

	oGet01:oBrowse:Refresh()

Return

/*/
	+----------+----------+-------+-----------------------+------+------------+
	|Função    |fSTCA003  | Autor |Microsiga Vitória      | Data |09.10.2007  |
	+----------+----------+-------+-----------------------+------+------------+
	|Descrição |Monta tela de seleção                                         |
	+----------+--------------------------------------------------------------+
	|Retorno   |#                                                             |
	+----------+--------------------------------------------------------------+
	|Parâmetros|#                                                             |
	+----------+--------------------------------------------------------------+
	|Uso       |Field Service -> Sirtec                                       |
	+----------+--------------------------------------------------------------+
	| Atualizacoes sofridas desde a Construcao Inicial.                       |
	+----------+--------------------------------------------------------------+
	| Data     | Descrição                                                    |
	+----------+--------------------------------------------------------------+
	|          |                                                              |
	+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA003

	//Definição da Fonte
	oFont  := tFont():new(,,-11,,.T.)

	DEFINE MSDIALOG oDlgSTC TITLE 'Copia de material' FROM C(200),C(200) TO C(500),C(700) PIXEL

	// Cria as Groups do Sistema
	@ C(012),C(008) TO C(040),C(245) LABEL "Local de origem: " PIXEL OF oDlgSTC

	//Informações do cabeçalho
	oTCab1 := tSay():New(025,015,{||"Armazem: "},oDlgSTC,,,,,,.T.,,,270,20)
	oICab1 := tSay():New(025,050,{||cLocal}       ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)

	oTCab2 := tSay():New(025,085,{||"Endereço: "}   ,oDlgSTC,,,,,,.T.,,,270,20)
	oICab2 := tSay():New(025,120,{||cEnd}      ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)

	//Inclusao dos GetDados
	oGet01 := MsSelect():New("ARQTRB","MARCA","",aCpoBrw,.F.,cMarca,{C(045),C(008),C(140),C(245)})
	oGet01:bAval := {|| fSTCA002()}

	ACTIVATE MSDIALOG oDlgSTC On Init (EnchoiceBar(oDlgSTC,{|| nOpc:=1,oDlgSTC:End()},{|| nOpc:=2,oDlgSTC:End()},,/*aButtons*/)) CENTERED

Return

/*/
	+----------+----------+-------+-----------------------+------+------------+
	|Função    |fSTCA004  | Autor |Microsiga Vitória      | Data |09.10.2007  |
	+----------+----------+-------+-----------------------+------+------------+
	|Descrição |Grava copias                                                  |
	+----------+--------------------------------------------------------------+
	|Retorno   |#                                                             |
	+----------+--------------------------------------------------------------+
	|Parâmetros|#                                                             |
	+----------+--------------------------------------------------------------+
	|Uso       |Estoque -> Sirtec                                             |
	+----------+--------------------------------------------------------------+
	| Atualizacoes sofridas desde a Construcao Inicial.                       |
	+----------+--------------------------------------------------------------+
	| Data     | Descrição                                                    |
	+----------+--------------------------------------------------------------+
	|          |                                                              |
	+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA004

	Local cSQL := ''

	cSQL := " SELECT * FROM !ZZ8! ZZ8 WHERE ZZ8.D_E_L_E_T_ = '' AND ZZ8.ZZ8_FILIAL = !FILIAL! AND ZZ8.ZZ8_LOCAL = !LOCAL! AND ZZ8.ZZ8_END = !ENDERECO!"

	cSQL := StrTran(cSQL,'!ZZ8!'      ,RetSQLName("ZZ8")       )
	cSQL := StrTran(cSQL,'!FILIAL!'   ,ValToSQL(xFilial("ZZ8")))
	cSQL := StrTran(cSQL,'!LOCAL!'    ,ValToSQL(cLocal)        )
	cSQL := StrTran(cSQL,'!ENDERECO!' ,ValToSQL(cEnd)          )

//Log de controle
	Memowrite('\STCA033-1.TXT',cSQL)

//Verifica se alias está em uso
	If chkfile("ARQ1")
		DbselectArea("ARQ1")
		DbCloseArea()
	End If

//Cria query
	TcQuery cSQL New Alias "ARQ1"

	ARQTRB->(DbGoTop())
	While !ARQTRB->(EOF())

		If ARQTRB->MARCA == cMarca

			ARQ1->(DbGoTop())
			While !ARQ1->(EOF())

				RecLock("ZZ8",.T.)
				ZZ8->ZZ8_FILIAL := xFilial("ZZ8")
				ZZ8->ZZ8_LOCAL  := ARQTRB->ARMAZEM
				ZZ8->ZZ8_END    := ARQTRB->ENDERECO
				ZZ8->ZZ8_PRODUT := ARQ1->ZZ8_PRODUT
				ZZ8->ZZ8_QUANT  := ARQ1->ZZ8_QUANT
				ZZ8->(MsUnlock())
				ARQ1->(DbSkip())
			EndDo
		EndIf

		ARQTRB->(DbSkip())
	EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
	
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28                                                               
	EndIf
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90                                                            
		EndIf
	EndIf
Return Int(nTam)