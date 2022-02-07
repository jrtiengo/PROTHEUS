#include 'rwmake.ch'
#include 'protheus.ch'
#include "topconn.ch"

#define STR0001 'Sirtec - STCA013'

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA013   | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cadastro de Equipes x Tecnicos                                |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
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

User Function STCA013

// Array com os botões do Browse
	Private c_Alias		:= "ZZ4"
	Private c_Titulo		:= "Cadastro de Equipes"
	Private c_CampoCab	:= "ZZ4_EQUIPE/ZZ4_NOMEEQ/ZZ4_GRPPR/ZZ4_CODSUP"

	Private aRotina   	:= {{OemToAnsi("Pesquisar"), 	"AxPesqui",	0, 1, 0, NIL},;
		{OemToAnsi("Visualizar"), 	"U_STCA013A",	0, 2, 0, NIL},;
		{OemToAnsi("Incluir"), 		"U_STCA013A",	0, 3, 0, NIL},;
		{OemToAnsi("Alterar"), 		"U_STCA013A",	0, 4, 0, NIL},;
		{OemToAnsi("Excluir"), 		"U_STCA013A",	0, 5, 0, NIL}}

	DbSelectArea(c_Alias)
	DbSetOrder(1)
	DbGoTop()
	mBrowse( 6,1,22,75,c_Alias)

Return

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA013A    | Microsiga Vitória | Data | 09.10.2007 |
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

User Function STCA013A(cAlias,nReg,nOpc)

	Private _aAcolAnt := {}

	Private nOpcx	:= nOpc // Opção Escolhida
	Private cGrupo 	:= ""
	Private cDesc	:= ""
	Private cPpr 	:= ""
	Private aCols 	:= {}
	Private _cSX3 	:= GetNextAlias()
	Private _cSX32 	:= GetNextAlias()

//+-----------------------------------------------+
//¦ Montando aHeader                              ¦
//+-----------------------------------------------+
	nUsado:=0
	aHeader:={}


DbSelectArea("Sx3")
DbSetOrder(1)
DbSeek(c_Alias)

nUsado:=0
aHeader:={}
//Percorre a X3 para achar o ALIAS correto para: ACOLS e AHEADER

While !Eof() .And. (x3_arquivo == c_Alias)
	//Não inclui os campos que estão na sequencia do c_CampoCab
	If Alltrim(x3_campo) $ c_CampoCab
		DbSkip()
		Loop
	EndIf
	//Inclui os campos que estão na sequencia do c_CampoCab
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		nUsado:=nUsado + 1
		AADD(aHeader,{ TRIM(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,x3_vlduser,x3_usado,x3_tipo, x3_arquivo, x3_context } )
	Endif
dbSkip()
EndDo

aCols := Array(1,nUsado+1)

DbSelectArea("Sx3")
DbSeek(c_Alias)
nUsado:=0
//Realiza o mesmo trajeto pro aCols
While !Eof() .And. (x3_arquivo == c_Alias)
	If Alltrim(x3_campo) $ c_CampoCab
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



	If nOpcx <> 3 // Se Inclusão
		aCols := {}
		DbSelectArea(c_Alias)
		DbSetOrder(1)
		cChave   := xFilial(c_Alias) + ZZ4->ZZ4_EQUIPE
		_cChave  := xFilial(c_Alias) + ZZ4->ZZ4_EQUIPE

		_cCampo1 := ZZ4->ZZ4_EQUIPE
		cCampo1 := ZZ4->ZZ4_EQUIPE
		cCampo2 := ZZ4->ZZ4_NOMEEQ
		cCampo3 := ZZ4->ZZ4_GRPPR
		cCampo4 := ZZ4->ZZ4_CODSUP
		cCampo5 := iif(!Empty(ZZ4->ZZ4_CODSUP),SZ0->(FBUSCACPO("SZ0",1,xFilial("SZ0")+ZZ4->ZZ4_CODSUP,"Z0_NOME")),space(50))

		DbGoTop()
		DbSeek(_cChave)
		While !EOF() .And. ZZ4->ZZ4_FILIAL+ZZ4->ZZ4_EQUIPEO = _cChave
			if ZZ4->(FIELDPOS("ZZ4_SENHA")) >0
				Aadd(aCols    ,{ZZ4->ZZ4_CODTEC,ZZ4->ZZ4_NOMETC,ZZ4->ZZ4_CODSRA,ZZ4->ZZ4_ENCARE,ZZ4->ZZ4_SENHA,.f.})
				Aadd(_aAColAnt,{ZZ4->ZZ4_CODTEC,ZZ4->ZZ4_NOMETC,ZZ4->ZZ4_CODSRA,ZZ4->ZZ4_ENCARE,ZZ4->ZZ4_SENHA,.f.})
			else
				Aadd(aCols    ,{ZZ4->ZZ4_CODTEC,ZZ4->ZZ4_NOMETC,ZZ4->ZZ4_CODSRA,ZZ4->ZZ4_ENCARE,.f.})
				Aadd(_aAColAnt,{ZZ4->ZZ4_CODTEC,ZZ4->ZZ4_NOMETC,ZZ4->ZZ4_CODSRA,ZZ4->ZZ4_ENCARE,.f.})
			endif

			DbSkip()
		EndDo
	Else
		aCOLS[1][nUsado+1] := .F.
		cCampo1 := Space(6)
		cCampo2 := Space(30)
		cCampo3 := Space(6)
		//cCampo4 := "1"
		cCampo4 := Space(6)
		cCampo5 := Space(50)
	EndIf

	nLinGetD:=0

	cTitulo:= c_Titulo

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

		AADD(aC,{"cCampo1" ,{15,22}  ,"Grupo"    ,"@!","U_STCA013B(cCampo1)","AA1",Iif(ALTERA,.F.,.T.)})
		AADD(aC,{"cCampo2" ,{15,200} ,"Descrição","@!",,,.F.})
		AADD(aC,{"cCampo3" ,{31,10}  ,"Grupo PPR","@!","U_STCA013C(cCampo3)","SZ4",.T.})
		AADD(aC,{"cCampo4" ,{47,10}  ,"Supervisor","@!","U_STCA013D(cCampo4,@cCampo5)","SZ0",.T.})
		AADD(aC,{"cCampo5" ,{47,200}  ,"Nome","@!",,,.F.})

	#ELSE

		AADD(aC,{"cGrupo" ,{6,5}  ,"Grupo","@!",,"",})
		AADD(aC,{"cDesc"  ,{6,40} ,"Descrição","@!",,,})
		AADD(aC,{"cPpr"   ,{18,6} ,"Grupo PPR","@!",,,})
		AADD(aC,{"cSup"   ,{30,6} ,"Supervisor","@!",,,})
		AADD(aC,{"cNomSup"   ,{30,50} ,"Nome","@!",,,})

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
				aCGD:={54,5,118,315}
			#ELSE
				aCGD:={10,04,15,73}
			#ENDIF

//+----------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2           ¦
//+----------------------------------------------+

				cLinhaOk := "u_SValLin(n, CCAMPO1)" //"ExecBlock('Md2LinOk',.f.,.f.)"
				cTudoOk  := "u_013TudOk(cCampo3,cCampo4)" //"AlwaysTrue()"

// lRet = .t. se confirmou
// lRet = .f. se cancelou

				lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,,,.T.)

				If lRet

					fProcessa()

				EndIf

				Return

// Função para Processar o Cadastro
Static Function fProcessa()
	Local I := 0
// nOpcx = 2 // Visualizar
// nOpcx = 3 // Incluir 
// nOpcx = 4 // Alterar
// nOpcx = 5 // Excluir
	Begin Transaction

		If nOpcx = 3

			I := 0

			For I := 1 To Len(aCols)

				If aCols[I][Len(aHeader)+1] // Testa se o item está deletado
					Loop
				EndIf

				if (ZZ4->(FIELDPOS("ZZ4_SENHA")))>0


					RecLock(c_Alias,.T.)

					ZZ4->ZZ4_FILIAL	:= xFilial(c_Alias)
					ZZ4->ZZ4_EQUIPE	:= cCampo1
					ZZ4->ZZ4_NOMEEQ	:= cCampo2
					ZZ4->ZZ4_CODTEC	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODTEC"})]
					ZZ4->ZZ4_NOMETC := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_NOMETC"})]
					ZZ4->ZZ4_CODSRA	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODSRA"})]
					ZZ4->ZZ4_ENCARE	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_ENCARE"})]
					ZZ4->ZZ4_SENHA	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_SENHA"})]
					ZZ4->ZZ4_GRPPR	:= cCampo3
					ZZ4->ZZ4_CODSUP := cCampo4

					MsUnLock()
				else
					RecLock(c_Alias,.T.)

					ZZ4->ZZ4_FILIAL	:= xFilial(c_Alias)
					ZZ4->ZZ4_EQUIPE	:= cCampo1
					ZZ4->ZZ4_NOMEEQ	:= cCampo2
					ZZ4->ZZ4_CODTEC	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODTEC"})]
					ZZ4->ZZ4_NOMETC := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_NOMETC"})]
					ZZ4->ZZ4_CODSRA	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODSRA"})]
					ZZ4->ZZ4_ENCARE	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_ENCARE"})]
					ZZ4->ZZ4_GRPPR	:= cCampo3
					ZZ4->ZZ4_CODSUP := cCampo4

					MsUnLock()
				endif
			Next

		ElseIf nOpcx = 5

			I := 0

			DbSelectArea(c_Alias)
			DbGoTop()
			DbsetOrder(1)
			For I := 1 To Len(aCols)
				If DbSeek(cChave+aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODTEC"})])
					RecLock(c_Alias,.f.)
					DbDelete()
					MsUnlock()
				EndIf
			Next

		ElseIf nOpcx = 4

			I := 0

			DbSelectArea(c_Alias)
			DbGoTop()
			DbsetOrder(1)
			For I := 1 To Len(_aAcolAnt)
				If DbSeek(cChave+_aAcolAnt[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODTEC"})])
					RecLock(c_Alias,.f.)
					DbDelete()
					MsUnlock()
				EndIf
			Next

			I := 0

			For I := 1 To Len(aCols)

				If aCols[I][Len(aHeader)+1] // Testa se o item está deletado
					Loop
				EndIf

				if (ZZ4->(FIELDPOS("ZZ4_SENHA")))>0
					RecLock(c_Alias,.T.)

					ZZ4->ZZ4_FILIAL	:= xFilial(c_Alias)
					ZZ4->ZZ4_EQUIPE	:= cCampo1
					ZZ4->ZZ4_NOMEEQ	:= cCampo2
					ZZ4->ZZ4_CODTEC	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODTEC"})]
					ZZ4->ZZ4_NOMETC := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_NOMETC"})]
					ZZ4->ZZ4_CODSRA := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODSRA"})]
					ZZ4->ZZ4_ENCARE	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_ENCARE"})]
					ZZ4->ZZ4_SENHA	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_SENHA"})]
					ZZ4->ZZ4_GRPPR	:= cCampo3
					ZZ4->ZZ4_CODSUP := cCampo4

					MsUnLock()
				else
					RecLock(c_Alias,.T.)

					ZZ4->ZZ4_FILIAL	:= xFilial(c_Alias)
					ZZ4->ZZ4_EQUIPE	:= cCampo1
					ZZ4->ZZ4_NOMEEQ	:= cCampo2
					ZZ4->ZZ4_CODTEC	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODTEC"})]
					ZZ4->ZZ4_NOMETC := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_NOMETC"})]
					ZZ4->ZZ4_CODSRA := aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODSRA"})]
					ZZ4->ZZ4_ENCARE	:= aCols[I][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_ENCARE"})]
					ZZ4->ZZ4_GRPPR	:= cCampo3
					ZZ4->ZZ4_CODSUP := cCampo4

					MsUnLock()
				endif
			Next
		EndIf

	End Transaction
	ZZ4->(DbCommit())

Return

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA013B    | Microsiga Vitória | Data | 09.10.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação do campo ZZ4->ZZ4_EQUIPE                 |
|          |                                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Motivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/

User Function STCA013B(cCod)

	Local lRet	:= .F.
	Local cEq	:= "S"

	If cEq == Posicione("AA1",1,xFilial("AA1")+cCod,"AA1_YEQUIP")
		lRet	:= .T.
	Else
		MsgStop("Código não é de Equipe.",STR0001)
	Endif

Return lRet

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA013C    | Microsiga Vitória | Data | 09.10.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação do campo ZZ4->ZZ4_GRPPR                  |
|          |                                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Motivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/

User Function STCA013C(cCod)

	Local lRet	:= .F.
	Local T_Area:= GetArea()   // Assis em 31/01/2020 - 11:36 - 46724
	If Empty(cCod)
		lRet := .F.
		MsgStop("Obrigatório preenchimento do Código PPR.","Atenção")
	Else
		dbSelectArea("SZ4")
		SZ4->(dbSetOrder(1))
		If SZ4->(MsSeek( xFilial("SZ4") + cCod ))
			lRet := .T.
		Else
			lRet := .F.
			MsgStop("Grupo PPR não encontrado.")
		Endif
	Endif
    RestArea( T_Area ) // Assis em 31/01/2020 - 11:36 - 46724
Return lRet

/*
+----------+------------+-------------------+------+------------+
|Programa  |013TudOK    | Microsiga Vitória | Data | 09.10.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação TUDOOK Modelo2                           |
|          |                                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Motivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/

User Function 013TudOK(cCod,cSup)

	Local lRet	:= .T.

	If lRet .and. Empty(cCod)
		lRet := .F.
		MsgStop("Obrigatório preenchimento do Código PPR.","Atenção")
	Endif

/*If lRet .and. Empty(cSup)
	lRet := .F.
	msgStop("Obrigatório preenchimento do Código do Supervisor.","Atenção")
Endif
*/
Return lRet

/*
+----------+------------+-------------------+------+------------+
|Programa  | ValidLin   | Totvs TRS			  | Data | COU18.09.2012 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação da Linha do Grid.                        |
|          |                                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Motivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/

User Function SValLin(nLIN, CEQUIPE)
	Local _lRet := .T.
	Local _cTecnico := GdFieldGet("ZZ4_CODTEC",nLin)
	Local _cQuery:= ""
	Local _i := 0
	Local T_Area:= GetArea()   // Assis em 31/01/2020 - 11:36 - 46724

	_cQuery:= "SELECT COUNT(*) as QUANT"
	_cQuery+= " FROM " +  RetSQLName("ZZ4") + " ZZ4 "
	_cQuery+= " WHERE ZZ4_CODTEC ='" +_cTecnico + "' "
	_cQuery+= " AND ZZ4_EQUIPE <> '" +	CEQUIPE + "' AND "
	_cQuery += " "+RetSqlCond("ZZ4")+" "

	TCQuery ChangeQuery(_cQuery) New Alias TRB


	IF TRB->QUANT > 0 .and. TRB->(!EOF())
		Alert("Técnico já cadastrado em outra equipe.")
		_lRet := .F.
	Endif

	For _i := 1 To Len(aCols)
		if aCols[_i][aScan(aHeader,{|x|Alltrim(x[2])=="ZZ4_CODTEC"})] == _cTecnico .and. nLIN <> _i .and. _lRet
			Alert("Técnico já cadastrado nessa equipe.")
			_lRet := .F.
		endif
	next

	TRB->(dbclosearea())
    RestArea( T_Area ) // Assis em 31/01/2020 - 11:36 - 46724
	
return _lRet


/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA013D    | TRS PRIMME        | Data | 06.09.2017 |
+----------+------------+-------------------+------+------------+
|Descrição | Validação do campo ZZ4->ZZ4_CODSUP                 |
|          |                                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Motivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/

User Function STCA013D(cCod,cNome)
	Local lRet	:= .F.
	cNome := ''
	If !Empty(cCod)
		SZ0->(DbSetOrder(1))
		If SZ0->(DbSeek(xFilial("SZ0")+cCod))
			If SZ0->Z0_MSBLQL == '1'
				msginfo("Registro bloqueado para uso.")
			Else
				cNome := SZ0->Z0_NOME
				lRet := .T.
			Endif
		Else
			MsgInfo("Supervisor não encontrado.")
		Endif
	Else
		lRet := .T.
	Endif
Return lRet