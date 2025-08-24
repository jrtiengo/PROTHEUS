#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"

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

	FCreate(cLocDir + cArq)

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
 | A03 - C�digo do Conv�nio   | 003 - 022    | X(020)    | C�digo do Banco   |
 | A04 - Nome da Empresa      | 023 - 042    | X(020)    | Nome da Empresa   |
 | A05 - C�digo do Banco      | 043 - 045    | 9(003)    | C�digo Compensa��o|
 | A06 - Nome do Banco        | 046 - 065    | X(020)    | Nome do Banco     |
 | A07 - Data de Gera��o      | 066 - 073    | 9(008)    | AAAAMMDD          |
 | A08 - NSA                  | 074 - 079    | 9(006)    | N� Sequencial     |
 | A09 - Vers�o do Lay-out    | 080 - 081    | 9(002)    | "04"              |
 | A10 - Identifica��o Servi�o| 082 - 098    | X(017)    | "D�BITO AUTOM�TICO"|
 | A11 - Reservado/Futuro     | 099 - 150    | X(052)    | Brancos/"TESTE"   |
 -----------------------------------------------------------------------------
*/
Static Function fHeader()

	cRet := 'A'
	cRet += '1'
	cRet += PadR("C�digo do Conv�nio", 20)
	cRet += PadR("Nome da Empresa ", 20)
	cRet += PadL(Transform('C�digo do Banco', "@R 999"), 3, "0")
	cRet += PadR("NOME DO BANCO", 20)
	cRet += DToC(Date())
	cRet += PadL(Transform(1, "@R 999999"), 6, "0")
	cRet += "04"
	cRet += PadR("DEBITO AUTOMATICO", 17)
	cRet := Stuff(cRet, 146, 5, "TESTE")

Return cRet
