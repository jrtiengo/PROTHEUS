#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#include "fileio.ch"

/*/{Protheus.doc} xCTBAUC
Este programa tem como objetivo gerar CNAB para Debito Automatico, inclus�o, altera��o e exclus�o
@type  Function
@author Tiengo Junior
@since 21/07/2025
@version version
@param 
	MV_PAR01 = Cliente de ?                   
	MV_PAR02 = Cliente At� ?                
	MV_PAR03 = Banco Unimed ? 
	MV_PAR04 = Subconta ?         
	MV_PAR05 = Data de Movimenta��o de 
	MV_PAR06 = Data de Movimenta��o At�  
	MV_PAR07 = Tipo 1=Inclus�o ? 2=Altera��o ? 3=Exclus�o ?
/*/

User Function xDACNAB()

	Local aArea         := FWGetArea()
	Local bProcess      := {|oSelf| fBusca(oSelf)}
	Local cPerg         := "xDACNAB"
	Local cTitulo       := "CNAB - Debito Automatico"
	Local cDesc         := "Este programa tem como objetivo realizar a gera��o de CNAB para Debito Automatico, inclus�o, altera��o e exclus�o."

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
			FWAlertWarning('Aten��o n�o foram encontrados registros','Aten��o')
			Return()
		Endif
	Endif

	DbSelectArea("SZ6")
	SZ6->(DbSetOrder(1)) //Z6_FILIAL+Z6_CODCLI+Z6_LOJA

	//Cria o diret�rio e o arquivo de remessa
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
	cRet += PadR("AG DE D�BITO", 4)
	cRet += PadL("IDCLI BANCO", 14)
	cRet += PadR("IDCLI EMPRESA ATU", 25)
	cRet += PadR("EXCLUSAO POR ALTERACAO CADASTRAL DO CLIENTE", 60)
	cRet += Space(20)
	cRet += '1'

	FWrite(nHandle, cRet + CRLF)

	FClose(nHandle)

	RpcClearEnv()

Return (cRet)
