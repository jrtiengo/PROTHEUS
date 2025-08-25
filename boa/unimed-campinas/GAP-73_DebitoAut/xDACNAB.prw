#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#include "fileio.ch"

/*/{Protheus.doc} xCTBAUC
Este programa tem como objetivo gerar CNAB para Debito Automatico, inclusão, alteração e exclusão
@type  Function
@author Tiengo Junior
@since 21/07/2025
@version version
@param 
	MV_PAR01 = Cliente de ?                   
	MV_PAR02 = Cliente Até ?                
	MV_PAR03 = Banco Unimed ? 
	MV_PAR04 = Subconta ?         
	MV_PAR05 = Data de Movimentação de 
	MV_PAR06 = Data de Movimentação Até  
	MV_PAR07 = Tipo 1=Inclusão ? 2=Alteração ? 3=Exclusão ?
/*/

User Function xDACNAB()

	Local aArea         := FWGetArea()
	Local bProcess      := {|oSelf| fBusca(oSelf)}
	Local cPerg         := "xDACNAB"
	Local cTitulo       := "CNAB - Debito Automatico"
	Local cDesc         := "Este programa tem como objetivo realizar a geração de CNAB para Debito Automatico, inclusão, alteração e exclusão."

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
	local nHandle 			:= 0
	Local cLocDir 			:= "C:\Temp\"
	Local cArq 				:= "CNAB_BB_" + DToS(Date()) + "_" + StrZero(nNSA,6) + ".REM"

	cQuery := "SELECT	SZ6.Z6_CODCLI, 								"
	cQuery += "			SZ6.Z6_BCOUNI,                              "
	cQuery += "			SZ6.Z6_SUBCTA,                           	"
	cQuery += "			SZ6.Z6_DTAMOV,                              "
	cQuery += "			SZ6.Z6_TIPMOV, 	                          	"
	cQuery += "         SZ6.R_E_C_N_O_                              "
	cQuery += "FROM " + RetSqlName("SZ6") + " SZ6 				   	"
	cQuery += "WHERE SZ6.D_E_L_E_T_ = '' "                         	"
	cQuery += "	 AND SZ6.Z6_CODCLI >= '" + MV_PAR01 + "' "          "
	cQuery += "	 AND SZ6.Z6_CODCLI <= '" + MV_PAR02 + "' "          "
	cQuery += "	 AND SZ6.Z6_BCOUNI = '" + MV_PAR03 + "' "           "
	cQuery += "	 AND SZ6.Z6_SUBCTA = '" + MV_PAR04 + "' "        	"
	cQuery += "	 AND SZ6.Z6_DTAMOV >= '" + MV_PAR05 + "' "          "
	cQuery += "	 AND SZ6.Z6_DTAMOV <= '" + MV_PAR06 + "' "          "

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		If ! IsBlind()
			FWAlertWarning('Atenção não foram encontrados registros','Atenção')
			Return()
		Endif
	Endif

	DbSelectArea("SZ6")
	SZ6->(DbSetOrder(1)) //Z6_FILIAL+Z6_CODCLI+Z6_LOJA

	//Cria o diretório e o arquivo de remessa
	If ! ExistDir(cLogDir)
		MakeDir(cLogDir)
	Endif

	nHandle := FCreate(cLocDir + cArq)

	If nHandle = -1
		FWAlertError('Erro ao criar arquivo','Erro')
		Return()
	Endif

	While ! (cAlias)->(EoF())

		//Header(A)
		cHeader := fHeader()
		FWrite(nHandle, cHeader + CRLF)



		SZ6->(DbGoTo(nRecno))
		SZ6->(RecLock("SZ6", .F.))
		SZ6->Z6_DATPROC    := dDatabase
		SZ6->Z6_BCOUNI 	   := MV_PAR03
		SZ6->Z6_SUBCTA 	   := MV_PAR04
		SZ6->Z6_TIPMOV     := MV_PAR07

		SZ6->(MsUnlock())

		(cAlias)->(dbSkip())
	Enddo

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
 -----------------------------------------------------------------------------
*/
User Function fHeader()

	local nHandle 			:= 0
	Local cLocDir 			:= "C:\Temp\"
	Local cArq 				:= ""

	cArq 				:= "CNAB_BB_" + DToS(Date()) + "_" + "000001" + ".EDI"

	RPCSetEnv("99" , "01",,,"FIN",,,,,,)

	nHandle := FCreate(cLocDir + cArq)

	If nHandle = -1
		FWAlertError('Erro ao criar arquivo','Erro')
		Return()
	Endif

	cRet := 'A'
	cRet += '1'
	cRet += PadR("14837", 20)
	cRet += PadR("UNIMED CAMPINAS COOP", 20)
	cRet += PadL("001", 3)
	cRet += PadR("BANCO DO BRASIL S.A.", 20)
	cRet += DtoS(ddatabase)
	cRet += PadL("000001", 6)
	cRet += "04"
	cRet += PadR("DEBITO AUTOMATICO", 17)
	cRet += Space(52)
	cRet := Stuff(cRet, 146, 5, "TESTE")

	FWrite(nHandle, cRet + CRLF)

	FClose(nHandle)

	RpcClearEnv()

Return (cRet)

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

User Function fExclusao()

	local nHandle 			:= 0
	Local cLocDir 			:= "C:\Temp\"
	Local cArq 				:= ""

	cArq 				:= "CNAB_BB_" + DToS(Date()) + "_" + "000001" + ".EDI"

	RPCSetEnv("99" , "01",,,"FIN",,,,,,)

	nHandle := FCreate(cLocDir + cArq)

	If nHandle = -1
		FWAlertError('Erro ao criar arquivo','Erro')
		Return()
	Endif

	cRet := 'D'
	cRet += PadR("IDCLI EMPRESA ANT", 25)
	cRet += PadR("AG DE DÉBITO", 4)
	cRet += PadL("IDCLI BANCO", 14)
	cRet += PadR("IDCLI EMPRESA ATU", 25)
	cRet += PadR("EXCLUSAO POR ALTERACAO CADASTRAL DO CLIENTE", 60)
	cRet += Space(20)
	cRet += '1'

	FWrite(nHandle, cRet + CRLF)

	FClose(nHandle)

	RpcClearEnv()

Return (cRet)
