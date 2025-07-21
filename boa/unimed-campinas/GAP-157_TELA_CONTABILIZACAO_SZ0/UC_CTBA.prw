#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} UC_CTBA
(long_description)
@type  Function
@author user
@since 21/07/2025
@version version
@param 
    Da Filial ?                   
    Até a Filial ?                
    Processo                      
    Aglut. Lançamentos ?          
    Mostra Lanç Contab ?        
/*/

User Function UC_CTBA()

	Local aSays         := {}
	Local cPerg         := "UCCTB01"
	Local cCadastro     := "SPM - Lançamentos Contabeis Off-Line"
	Local aButtons      := {}

	If ! IsBlind()

		Pergunte(cPerg,.F.)
		aadd(aSays,"Este programa tem como objetivo gerar automaticamente os Lançamentos contábeis")
		aadd(aSays,"para Documentos de entrada, Contas a Pagar, Contas a Receber.")
		aadd(aSays,"--")
		aadd(aSays,"Para prosseguir com o processo, clique no botão 'OK'")

		aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
		aadd(aButtons, { 1,.T.,{|| nOpcA:= 1, FechaBatch() }} )
		aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )

		FormBatch( cCadastro, aSays, aButtons )

		//Se o usuário clicou no Confirmar
		If nContinua == 1
			fProcessa(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05)
		EndIf
	Endif

Return()

Static Function fProcessa(cFilde, cFilAte, cTpDoc, nAglutLc, nVisLc)

	Local aArea      := fWGetArea()
	Local cQuery := ""

	If cTpDoc == "DocEntrada"

		cQuery := "SELECT * FROM" + RetSqlName("SD1") + "SD1"
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " SC7 ON SC7.C7_FILIAL = SD1.D1_FILIAL "
		cQuery += "AND SC7.C7_NUM = SD1.D1_PEDIDO "
		cQuery += "AND SC7.D_E_L_E_T_ = '' "
		cQuery += "AND SC7.C7_XRATSPM = 'S' "
		cQuery += "WHERE SD1.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)

		MPSysOpenQuery(cQuery, 'TMP')
	Endif

	FwRestArea(aArea)
Return()
