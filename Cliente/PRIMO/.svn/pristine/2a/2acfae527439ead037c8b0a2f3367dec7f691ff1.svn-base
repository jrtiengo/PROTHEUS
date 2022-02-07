


User Function R330TRANS()
	Local cCFOP  := ParamIXB[1] //-- Código da Op.Fiscal
	Local lRetorno := .F.                  //-- Não é transferência (default)

//-- Considerações realizadas pelo cliente para considerar ou nao como TRANSFERÊNCIA:
	//If SF4->F4_TRANFIL == '1' .And. Substr(AllTrim(cCFOP),1,1) >= '5'  // CFOP de SAíDA
    If AllTrim(cCFOP) $ '6151'
// Tratamento do usuário, exemplo:   
		lRetorno = .T.  // Ao retornar .T. consideraria o movto. como Transferência
	EndIf
Return lRetorno
