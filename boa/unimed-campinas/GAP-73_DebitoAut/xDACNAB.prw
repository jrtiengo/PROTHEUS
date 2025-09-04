#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#include "fileio.ch"

/*/{Protheus.doc} xCTBAUC
Este programa tem como objetivo gerar solicitacao de exclusão para debito automatico ao banco selecionado .
GAP 73 
@type  Function
@author Tiengo Junior
@since 21/08/2025
@version version
@param 
	MV_PAR01 = Cliente de ?                   
	MV_PAR02 = Cliente Até ?
	MV_PAR03 = Banco ?                 
/*/

User Function xDACNAB()

	Local aArea         := FWGetArea()
	Local bProcess      := {|oSelf| fBusca(oSelf) }
	Local cTitulo       := "Debito Automatico - Exclusão"
	Local cDesc         := "Este programa tem como objetivo realizar a geração de arquivo para exclusão do Debito Automatico banco."
	Local cPerg         := "xDACNAB"

	If ! IsBlind()
		tNewProcess():New( "xDACNAB", cTitulo, bProcess, cDesc, cPerg )
	Endif

	FwRestArea(aArea)

Return()

//Consulta com base nos parametros informados
Static Function fBusca(oSelf)

	Local aArea             := fWGetArea()
	Local cQuery            := ''
	Local cAlias            := ''
	Local nHandle 			:= 0
	Local cLocDir 			:= "C:\Temp\"
	Local cArq 				:= ""
	Local cIdCliEmp			:= ""
	Local cTotReg			:= "000001"
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
	cQuery += "WHERE SA1.D_E_L_E_T_ = ' ' "                         "
	cQuery += "  AND SA1.A1_FILIAL = '" +FWxfilial('SA1')+ '"       "
	cQuery += "	 AND SA1.A1_XCOBD = 'S' 				          	"
	cQuery += "  AND SA1.A1_CODCLI >= '" + MV_PAR01 + "' 			"
	cQuery += "	 AND SA1.A1_CODCLI <= '" + MV_PAR02 + "'   			"
	cQuery += "	 AND SA1.A1_XBCO = '" + MV_PAR03 + "' 				"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		If ! IsBlind()
			FWAlertWarning('Não foram encontrados registros','Atenção')
			Return()
		Endif
	Endif

	//Busco o próximo ID Sequencial
	aSX5 := FWGetSX5("UC", MV_PAR03)

	If Len(aSX5) == 0
		FWAlertWarning('Erro ao buscar ID Sequencial','Atenção')
		Return()
	Endif

	cIdSeq := aSX5[1][4]

	//Cria o diretório e o arquivo de remessa
	If ! ExistDir(cLogDir)
		MakeDir(cLogDir)
	Endif

	cArq 	:= "DA_" + MV_PAR03 + "_" + cIdSeq + ".EDI"
	nHandle := FCreate(cLocDir + cArq)

	If nHandle == -1
		FWAlertError('Erro ao criar arquivo','Erro')
		Return()
	Endif

	//Header(A)
	cHeader := fHeader((cAlias)->A1_XBCO, cIdSeq)
	FWrite(nHandle, cHeader + CRLF)

	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	While ! (cAlias)->(EoF())

		cIdCliEmp := Alltrim((cAlias)->A1_FILIAL + (cAlias)->A1_COD + (cAlias)->A1_LOJA)
		cTotReg   := SOMA1(cTotReg)

		//Alteração(D)
		cExcl := fExclusao(cIdCliEmp, (cAlias)->A1_XDEBA, (cAlias)->A1_XAGE)
		FWrite(nHandle, cExcl + CRLF)

		If SA1->(MsSeek((cAlias)->A1_FILIAL) + AllTrim((cAlias)->A1_COD) + AllTrim((cAlias)->A1_LOJA))
			SA1->(RecLock("SA1", .F.))
			SA1->A1_XCOBD	:= 'N'
			SA1->(MsUnlock())
		Endif

		cIdCliEmp := ''

		(cAlias)->(dbSkip())
	Enddo

	//Trailler(Z)
	cTrailler := fTrailler(cTotReg, cIdSeq)
	FWrite(nHandle, cHeader)

	//Grava o próximo numero a ser gerado
	FwPutSX5(, 'ZZ', MV_PAR03, SOMA1(cIdSeq), SOMA1(cIdSeq), SOMA1(cIdSeq))

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	FClose(nHandle)

	FwRestArea(aArea)

	If ! IsBlind()
		FWAlertInfo('Processamento finalizado!','Processamento')
	Endif

Return()

/*Header A do arquivo - primeiro registro físico do arquivo - Registro A
 -----------------------------------------------------------------------------
 | Campo                      | Posição      | Formato   | Conteúdo          |
 |----------------------------|--------------|-----------|-------------------|
 | A01 - Código do Registro   | 001 - 001    | X(001)    | "A"               |
 | A02 - Código de Remessa    | 002 - 002    | 9(001)    | 1=Remessa, 2=Ret. |
 | A03 - Código do Convênio   | 003 - 022    | X(020)    | Código do Convênio|
 | A04 - Nome da Empresa      | 023 - 042    | X(020)    | Nome da Empresa   |
 | A05 - Código do Banco      | 043 - 045    | 9(003)    | Código do Banco na Câmara de compensação.|
 | A06 - Nome do Banco        | 046 - 065    | X(020)    | Nome do Banco     |
 | A07 - Data de Geração      | 066 - 073    | 9(008)    | AAAAMMDD          |
 | A08 - NSA                  | 074 - 079    | 9(006)    | Nº Sequencial     |
 | A09 - Versão do Lay-out    | 080 - 081    | 9(002)    | "04"              |
 | A10 - Identificação Serviço| 082 - 098    | X(017)    | "DÉBITO AUTOMÁTICO"|
 | A11 - Reservado/Futuro     | 099 - 150    | X(052)    | Brancos/"TESTE"   |

 CAIXA
 -------------------------------------------------------------------------------------------------------------------
 | Campo                               | Posição   | Formato | Conteúdo                                                                                       |
 |-------------------------------------|-----------|---------|------------------------------------------------------------------------------------------------|
 | A.11 Conta Compromisso              | 099 - 114 | 9(16)   | Nota 8                                                                                         |
 | A.12 Identificação do Ambiente Cli  | 115 - 115 | X(01)   | “P” = Produção “T” = Teste                                                                     |
 | A.13 Identificação do Ambiente Caixa| 116 - 116 | X(01)   | “P” = Produção “T” = Teste                                                                     |
 | A.14 Filler                         | 117 - 143 | X(27)   | Espaços (brancos)                                                                              |
 | A.15 Número Sequencial do Registro  | 144 - 149 | 9(06)   | "000000" = Remessa (Convenente para CAIXA) Espaços (brancos) = Retorno (CAIXA para Convenente) |
 | A.16 Filler                         | 150 - 150 | X(01)   | Espaços (brancos)                                                                              |
 -------------------------------------------------------------------------------------------------------------------
*/
static Function fHeader(cBanco, cIdSeq)

	Local cRet 			:= ""
	Local cBcoDesc 		:= ""
	Local cBcoConv 		:= ""

	Do Case
	Case cBanco == '001'
		cBcoDesc := "BANCO DO BRASIL S.A."
		cBcoConv := "001"
	Case cBanco == '341'
		cBcoDesc := "BANCO ITAU"
	Case cBanco == '033'
		cBcoDesc := "BANCO SANTANDER"
	Case cBanco == '104'
		cBcoDesc := "CAIXA"
	Case cBanco == '237'
		cBcoDesc := "BANCO BRADESCO"
	Case cBanco == '136'
		cBcoDesc := "BANCO UNICRED"
	EndCase

	cRet := 'A'
	cRet += '1'
	cRet += PadR("14837", 20) //codigo do convenio ???
	cRet += PadR("UNIMED CAMPINAS COOP", 20)
	cRet += PadL(cBanco, 3)
	cRet += PadR(cBcoDesc, 20)
	cRet += DtoS(ddatabase)
	cRet += PadL(cIdSeq, 6)
	cRet += "04"
	cRet += PadR("DEBITO AUTOMATICO", 17)
	//cRet += Space(52)
	//cRet := Stuff(cRet, 146, 5, "TESTE")

	// Diferença: Se for Caixa, monta conforme layout
	If cBanco == '104'
		cRet += PadL("1234567890123456",16)       // 099-114 Conta Compromisso (exemplo)
		cRet += "T"                               // 115 Ambiente Cliente (P=Produção, T=Teste)
		cRet += "T"                               // 116 Ambiente Caixa
		cRet += Space(27)                         // 117-143 Filler
		cRet += "000000"                          // 144-149 Seq. Registro (Remessa)
		cRet += " "                               // 150 Filler
	Else
		// Demais bancos continuam usando os 52 brancos + TESTE
		cRet += Space(52)                         // 099-150
		cRet := Stuff(cRet, 146, 5, "TESTE")
	EndIf

Return(cRet)

/* Registro de Débito - Detalhe - Registro D
 -------------------------------------------------------------------------------------------------------------------
 | Campo                                            | Posição   | Formato | Conteúdo                                                                                       |
 |--------------------------------------------------|-----------|---------|------------------------------------------------------------------------------------------------|
 | D01-Código do Registro                           | 001 - 001 | X(001)  | “D”                                                                                            |
 | D02-Identificação do Cliente na Empresa - Anter  | 002 - 026 | X(025)  | Identificação do Cliente na Empresa - Anterior                                                 |
 | D03-Agência para Débito                          | 027 - 030 | X(004)  | O conteúdo deverá ser idêntico ao anteriormente enviado pelo Banco, no registro tipo “B”       |
 | D04-Identificação do Cliente no Banco            | 031 - 044 | X(014)  | O conteúdo deverá ser idêntico ao anteriormente enviado pelo Banco, no registro tipo “B”       |
 | D05-Identificação do Cliente na Empresa - Atual  | 045 - 069 | X(025)  | Identificação do Cliente na Empresa - Atual                                                    |
 | D06-Ocorrência                                   | 070 - 129 | X(060)  | Mensagem explicativa do movimento enviado pela Empresa, quando o Código do Movimento for igual a 1.|
 | D07-Reservado para o futuro                      | 130 - 149 | X(020)  | Brancos                                                                                        |
 | D08-Código do Movimento                          | 150 - 150 | 9(001)  | 0 = Alteração da Identificação do Cliente na Empresa                                           |
 |                                                  |           |         | 1 = Exclusão de optante do Débito Automático                                                   |
 -------------------------------------------------------------------------------------------------------------------
*/

static Function fExclusao(cIdCliEmp, cIdCliBco, cAgencia)

	Local cRet 			:= ""

	cRet := 'D'
	cRet += PadR(cIdCliEmp, 25)
	cRet += PadR(cAgencia, 4)
	cRet += PadL(cIdCliBco, 14)
	cRet += PadR(cIdCliEmp, 25)
	cRet += PadR("EXCLUSAO POR ALTERACAO CADASTRAL DO CLIENTE", 60)
	cRet += Space(20)
	cRet += '1'

Return(cRet)

/* Trailler do arquivo - último registro físico do arquivo - Registro Z
 -------------------------------------------------------------------------------------------------------------------
 | Campo                               | Posição   | Formato | Conteúdo                                                                                       |
 |-------------------------------------|-----------|---------|------------------------------------------------------------------------------------------------|
 | Z01-Código do Registro              | 001 - 001 | X(001)  | “Z”                                                                                            |
 | Z02-Total de registros do arquivo   | 002 - 007 | 9(006)  | No somatório dos registros, deverão ser também incluídos, os registros Header e Trailler.      |
 | Z03-Valor total dos registros       | 008 - 024 | 9(017)  | Este campo deverá ser o somatório do campo E06 (remessa) ou F06 (retorno).                     |
 | Z04-Reservado para o futuro         | 025 - 150 | X(126)  | Brancos                                                                                        |
 -------------------------------------------------------------------------------------------------------------------
CAIXA
 | Campo                               | Posição   | Formato | Conteúdo         |
 |-------------------------------------|-----------|---------|------------------|
 | Z.04 Reservado para o futuro        | 025 - 143 | X(119)  | Espaços (brancos)|
 | Z.05 Número Sequencial do Registro  | 144 - 149 | 9(06)   | Nota 19          |
 | Z.06 Reservado para o futuro        | 150 - 150 | 9(01)   | Espaços (brancos)|
 -------------------------------------------------------------------------------
*/

static Function fTrailler(cTotReg, cIdSeq)

	Local cRet 			:= ""

	// Parte comum até a posição 024
	cRet := 'Z'                               // 001-001 Código do Registro
	cRet += PadL(cTotReg, 6)                  // 002-007 Total de Registros (inclui Header e Trailler)
	cRet += PadL(AllTrim(Str(nValorTotal)),17) // 008-024 Valor Total dos registros (E06/F06). Aqui somei como numérico.

	If cBanco == '104'   // CAIXA
		cRet += Space(119)                   // 025-143 Reservado (brancos)
		cRet += PadL(cIdSeq, 6)             // 144-149 Número Sequencial do Registro (remessa/retorno)
		cRet += " "                          // 150 Filler
	Else
		cRet += Space(126)                   // 025-150 Reservado (brancos)
	EndIf

Return(cRet)
