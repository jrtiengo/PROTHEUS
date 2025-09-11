#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#include "fileio.ch"

/*/{Protheus.doc} xDACNAB
Este programa tem como objetivo gerar solicitacao de exclus�o para debito automatico ao banco selecionado .
GAP 73 
@type  Function
@author Tiengo Junior
@since 21/08/2025
@version version
@param 
	MV_PAR01 = Cliente de ?                   
	MV_PAR02 = Cliente At� ?
	MV_PAR03 = Banco ?                 
/*/

User Function xDACNAB()

	Local aArea         := FWGetArea()
	Local aPergs  		:= {}


	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Cliente De",  	Space(TamSX3('A1_COD')[1]), "", "", "SA1CLI", 	"", 060,	.F.})
	aAdd(aPergs, {1, "Cliente At�", 	Space(TamSX3('A1_COD')[1]), "", "", "SA1CLI", 	"", 060,	.T.})
	aAdd(aPergs, {1, "Banco", 		Space(TamSX3('A1_COD')[1]), "", "", "SA6BCO", 	"", 060,	.T.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, 'Informe os par�metros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		Processa({|| fBusca(Alltrim(MV_PAR01), Alltrim(MV_PAR02), Alltrim(MV_PAR03))}, "Processando...", , , , )
	EndIf

	FwRestArea(aArea)

Return()

//Consulta com base nos parametros informados
Static Function fBusca(cClide, cCliAte, cBanco)

	Local aArea             := fWGetArea()
	Local cQuery            := ''
	Local cAlias            := ''
	Local nHandle 			:= 0
	Local cLocDir 			:= "C:\Temp\"
	Local cArq 				:= ""
	Local cIdCliEmp			:= ""
	Local cTotReg			:= "000002"
	Local cTrailler			:= ""
	Local cHeader			:= ""
	Local cExcl				:= ""
	Local aSX5				:= {}
	Local cIdSeq			:= ""

	cQuery := "SELECT	SA1.A1_FILIAL, 								"
	cQuery += "			SA1.A1_COD,                           		"
	cQuery += "			SA1.A1_LOJA,                           	    "
	cQuery += "			SA1.A1_XDEBA,                           	"
	cQuery += "			SA1.A1_XBCO,                           		"
	cQuery += "			SA1.A1_XAGE                           		"
	cQuery += "FROM " + RetSqlName("SA1") + " SA1 				   	"
	cQuery += "WHERE SA1.D_E_L_E_T_ = ' ' 	                        "
	cQuery += "  AND SA1.A1_FILIAL = '" +FWxfilial('SA1')+ "'       "
	cQuery += "	 AND SA1.A1_XCOBD = 'S' 				          	"
	cQuery += "  AND SA1.A1_COD >= '" +cClide+ "' 					"
	cQuery += "	 AND SA1.A1_COD <= '" +cCliAte+ "'   				"
	cQuery += "	 AND SA1.A1_XBCO = '" +cBanco+ "' 					"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		If ! IsBlind()
			FWAlertWarning('N�o foram encontrados registros','Aten��o')
			Return()
		Endif
	Endif

	//Busco o pr�ximo ID Sequencial
	aSX5 := FWGetSX5("Z1", cBanco)

	If Len(aSX5) == 0
		FWAlertWarning('Erro ao buscar ID Sequencial','Aten��o')
		Return()
	Endif

	cIdSeq := aSX5[1][4]

	//Cria o diret�rio e o arquivo de remessa
	If ! ExistDir(cLocDir)
		MakeDir(cLocDir)
	Endif

	cArq 	:= "DA_" + cBanco + "_" + cIdSeq + ".EDI"
	nHandle := FCreate(cLocDir + cArq, Nil, Nil, .F.)

	If nHandle == -1
		FWAlertError('Erro ao criar arquivo','Erro')
		Return()
	Endif

	//Header(A)
	cHeader := fHeader(Alltrim((cAlias)->A1_XBCO), cIdSeq)
	FWrite(nHandle, cHeader + CRLF)

	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	While ! (cAlias)->(EoF())

		cIdCliEmp := (cAlias)->A1_COD + (cAlias)->A1_LOJA
		cTotReg   := SOMA1(cTotReg)

		//Altera��o(D)
		cExcl := fExclusao(Alltrim((cAlias)->A1_XBCO), cIdCliEmp, Alltrim((cAlias)->A1_XDEBA), Alltrim((cAlias)->A1_XAGE), cIdSeq)
		FWrite(nHandle, cExcl + CRLF)

		If SA1->(MSSeek((cAlias)->A1_FILIAL + (cAlias)->A1_COD + (cAlias)->A1_LOJA))
			SA1->(RecLock("SA1", .F.))
			SA1->A1_XCOBD	:= 'N'
			SA1->(MsUnlock())
		Endif

		cIdCliEmp := ''

		(cAlias)->(dbSkip())
	Enddo

	//Trailler(Z)
	cTrailler := fTrailler(cTotReg, cIdSeq, cBanco)
	FWrite(nHandle, cTrailler)

	//Grava o pr�ximo numero a ser gerado
	FwPutSX5(, 'Z1', cBanco, SOMA1(cIdSeq), SOMA1(cIdSeq), SOMA1(cIdSeq))

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	FClose(nHandle)

	FwRestArea(aArea)

	If ! IsBlind()
		FWAlertInfo('Processamento finalizado! Arquivo gerado em ' + cLocDir + cArq,'Processamento')
	Endif

Return()

/*Header A do arquivo - primeiro registro f�sico do arquivo - Registro A
 -----------------------------------------------------------------------------
 | Campo                      | Posi��o      | Formato   | Conte�do          |
 |----------------------------|--------------|-----------|-------------------|
 | A01 - C�digo do Registro   | 001 - 001    | X(001)    | "A"               |
 | A02 - C�digo de Remessa    | 002 - 002    | 9(001)    | 1=Remessa, 2=Ret. |
 | A03 - C�digo do Conv�nio   | 003 - 022    | X(020)    | C�digo do Conv�nio|
 | A04 - Nome da Empresa      | 023 - 042    | X(020)    | Nome da Empresa   |
 | A05 - C�digo do Banco      | 043 - 045    | 9(003)    | C�digo do Banco na C�mara de compensa��o.|
 | A06 - Nome do Banco        | 046 - 065    | X(020)    | Nome do Banco     |
 | A07 - Data de Gera��o      | 066 - 073    | 9(008)    | AAAAMMDD          |
 | A08 - NSA                  | 074 - 079    | 9(006)    | N� Sequencial     |
 | A09 - Vers�o do Lay-out    | 080 - 081    | 9(002)    | "04"              |
 | A10 - Identifica��o Servi�o| 082 - 098    | X(017)    | "D�BITO AUTOM�TICO"|
 | A11 - Reservado/Futuro     | 099 - 150    | X(052)    | Brancos/"TESTE"   |

 CAIXA
 -------------------------------------------------------------------------------------------------------------------
 | Campo                               | Posi��o   | Formato | Conte�do                                                                                       |
 |-------------------------------------|-----------|---------|------------------------------------------------------------------------------------------------|
 | A.11 Conta Compromisso              | 099 - 114 | 9(16)   | Nota 8                                                                                         |
 | A.12 Identifica��o do Ambiente Cli  | 115 - 115 | X(01)   | �P� = Produ��o �T� = Teste                                                                     |
 | A.13 Identifica��o do Ambiente Caixa| 116 - 116 | X(01)   | �P� = Produ��o �T� = Teste                                                                     |
 | A.14 Filler                         | 117 - 143 | X(27)   | Espa�os (brancos)                                                                              |
 | A.15 N�mero Sequencial do Registro  | 144 - 149 | 9(06)   | "000000" = Remessa (Convenente para CAIXA) Espa�os (brancos) = Retorno (CAIXA para Convenente) |
 | A.16 Filler                         | 150 - 150 | X(01)   | Espa�os (brancos)                                                                              |
 -------------------------------------------------------------------------------------------------------------------
*/
static Function fHeader(cBanco, cIdSeq)

	Local cRet 			:= ""
	Local cBcoDesc 		:= ""
	Local cBcoConv 		:= ""
	Local lAmbiente 	:= .F.

	lAmbiente := SuperGetMV("UC_DAAMB", .F., .F.)

	Do Case
	Case cBanco == '001'
		cBcoDesc := "BANCO DO BRASIL S.A."
		cBcoConv := SuperGetMV("UC_DABBCV", .F., "")
	Case cBanco == '341'
		cBcoDesc := "BANCO ITAU"
		cBcoConv := SuperGetMV("UC_DAITCV", .F., "")
	Case cBanco == '033'
		cBcoDesc := "BANCO SANTANDER"
		cBcoConv := SuperGetMV("UC_DASACV", .F., "")
	Case cBanco == '104'
		cBcoDesc := "CAIXA"
		cBcoConv := SuperGetMV("UC_DACXCV", .F., "")
	Case cBanco == '237'
		cBcoDesc := "BANCO BRADESCO"
		cBcoConv := SuperGetMV("UC_DABRCV", .F., "")
	Case cBanco == '136'
		cBcoDesc := "BANCO UNICRED"
		cBcoConv := SuperGetMV("UC_DAUNCV", .F., "")
	EndCase

	cRet := 'A'
	cRet += '1'
	cRet += PadR(cBcoConv, 20) //codigo do convenio ???
	cRet += PadR("UNIMED CAMPINAS COOP", 20)
	cRet += PadL(cBanco, 3)
	cRet += PadR(cBcoDesc, 20)
	cRet += DtoS(ddatabase)
	cRet += PadL(cIdSeq, 6)
	cRet += "04"
	cRet += PadR("DEBITO AUTOMATICO", 17)

	// Diferen�a: Se for Caixa, monta conforme layout
	If cBanco == '104'
		cRet += PadL("42729553199 ",16)       	  // 099-114 Conta Compromisso (exemplo)
		cRet += iif(lAmbiente, "P", "T")       	  // 115 Ambiente Cliente (P=Produ��o, T=Teste)
		cRet += iif(lAmbiente, "P", "T")          // 116 Ambiente Caixa (P=Produ��o, T=Teste)
		cRet += Space(27)                         // 117-143 Filler
		cRet += "000000"                          // 144-149 Seq. Registro (Remessa)
		cRet += " "                               // 150 Filler
	Else
		// Demais bancos continuam usando os 52 brancos + TESTE
		cRet += Space(52)                         // 099-150
		cRet := iif(lAmbiente, "", Stuff(cRet, 146, 5, "TESTE"))
	EndIf

Return(cRet)

/* Registro de D�bito - Detalhe - Registro D
 -------------------------------------------------------------------------------------------------------------------
 | Campo                                            | Posi��o   | Formato | Conte�do                                                                                       |
 |--------------------------------------------------|-----------|---------|------------------------------------------------------------------------------------------------|
 | D01-C�digo do Registro                           | 001 - 001 | X(001)  | �D�                                                                                            |
 | D02-Identifica��o do Cliente na Empresa - Anter  | 002 - 026 | X(025)  | Identifica��o do Cliente na Empresa - Anterior                                                 |
 | D03-Ag�ncia para D�bito                          | 027 - 030 | X(004)  | O conte�do dever� ser id�ntico ao anteriormente enviado pelo Banco, no registro tipo �B�       |
 | D04-Identifica��o do Cliente no Banco            | 031 - 044 | X(014)  | O conte�do dever� ser id�ntico ao anteriormente enviado pelo Banco, no registro tipo �B�       |
 | D05-Identifica��o do Cliente na Empresa - Atual  | 045 - 069 | X(025)  | Identifica��o do Cliente na Empresa - Atual                                                    |
 | D06-Ocorr�ncia                                   | 070 - 129 | X(060)  | Mensagem explicativa do movimento enviado pela Empresa, quando o C�digo do Movimento for igual a 1.|
 | D07-Reservado para o futuro                      | 130 - 149 | X(020)  | Brancos                                                                                        |
 | D08-C�digo do Movimento                          | 150 - 150 | 9(001)  | 0 = Altera��o da Identifica��o do Cliente na Empresa                                           |
 |                                                  |           |         | 1 = Exclus�o de optante do D�bito Autom�tico                                                   |
 -------------------------------------------------------------------------------------------------------------------
 |CAIXA
 |D.07 Filler 										| 130 - 143 | X(14)    |Espa�os (brancos)
 |D.08 N�mero Sequencial do Registro 				| 144 - 149 | 9(06)    |Nota 19
 |D.09 C�digo do movimento 							| 150 - 150 | 9(001)   | 0 = Altera��o da Identifica��o do Cliente na Empresa
 |                                                  |           |          | 1 = Exclus�o de optante do D�bito Autom
*/

static Function fExclusao(cBanco, cIdCliEmp, cIdCliBco, cAgencia, cIdSeq)

	Local cRet 			:= ""

	cRet := 'D'
	cRet += PadR(cIdCliEmp, 25)
	cRet += PadR(cAgencia, 4)
	cRet += PadL(cIdCliBco, 14)
	cRet += PadR(cIdCliEmp, 25)
	cRet += PadR("EXCLUSAO POR ALTERACAO CADASTRAL DO CLIENTE", 60)
	If cBanco == '104'
		cRet += Space(14)
		cRet += PadL(cIdSeq, 6)
	Else
		cRet += Space(20)
	EndIf

	cRet += '1'

Return(cRet)

/* Trailler do arquivo - �ltimo registro f�sico do arquivo - Registro Z
 -------------------------------------------------------------------------------------------------------------------
 | Campo                               | Posi��o   | Formato | Conte�do                                                                                       |
 |-------------------------------------|-----------|---------|------------------------------------------------------------------------------------------------|
 | Z01-C�digo do Registro              | 001 - 001 | X(001)  | �Z�                                                                                            |
 | Z02-Total de registros do arquivo   | 002 - 007 | 9(006)  | No somat�rio dos registros, dever�o ser tamb�m inclu�dos, os registros Header e Trailler.      |
 | Z03-Valor total dos registros       | 008 - 024 | 9(017)  | Este campo dever� ser o somat�rio do campo E06 (remessa) ou F06 (retorno).                     |
 | Z04-Reservado para o futuro         | 025 - 150 | X(126)  | Brancos                                                                                        |
 -------------------------------------------------------------------------------------------------------------------
CAIXA
 | Campo                               | Posi��o   | Formato | Conte�do         |
 |-------------------------------------|-----------|---------|------------------|
 | Z.04 Reservado para o futuro        | 025 - 143 | X(119)  | Espa�os (brancos)|
 | Z.05 N�mero Sequencial do Registro  | 144 - 149 | 9(06)   | Nota 19          |
 | Z.06 Reservado para o futuro        | 150 - 150 | 9(01)   | Espa�os (brancos)|
 -------------------------------------------------------------------------------
*/

static Function fTrailler(cTotReg, cIdSeq, cBanco)

	Local cRet 			:= ""
	Local cValReg		:= "00000000000000000"

	// Parte comum at� a posi��o 024
	cRet := 'Z'                               // 001-001 C�digo do Registro
	cRet += PadL(cTotReg, 6)                  // 002-007 Total de Registros (inclui Header e Trailler)
	cRet += PadL(cValReg,17)	  			  // 008-024 Valor Total dos registros (E06/F06).

	If cBanco == '104'   // CAIXA
		cRet += Space(119)                   // 025-143 Reservado (brancos)
		cRet += PadL(cIdSeq, 6)              // 144-149 N�mero Sequencial do Registro (remessa/retorno)
		cRet += " "                          // 150 Filler
	Else
		cRet += Space(126)                   // 025-150 Reservado (brancos)
	EndIf

Return(cRet)
