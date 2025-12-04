#Include "Protheus.ch"

User Function teste2()

	nTotal := 1000 + 1000 + 1000 + 1000 + 1 + 1 + 1 + 1

    RPCSetEnv('99', '01', , , 'FAT')

	If FWAlertYesNo( "Valor Total: " + Transform(cValToChar(nTotal), PesqPict("SF1","F1_VALBRUT")) + CRLF;
			,"Confirma a geração da nota ?" )
	Endif

Return()
