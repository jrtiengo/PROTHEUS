#Include "rwmake.ch"
#include 'protheus.ch'

/*
+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | F580ADDB  | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | PE que adiciona botÃµes no browse dos titulos a serem liberados            |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado na rotina FINA580                                               |
+-----------+---------------------------------------------------------------------------+
*/
USER FUNCTION F580BROW()

	Set Key VK_F4 TO fOpenPdf()


Return .t.

Static Function fOpenPdf()
	Local cOper     := "open"
	Local cFileName
	Local cDirSrv   :="dirdoc\co"+alltrim(SM0->M0_CODIGO)+"\shared\"
	Local cParam    := ""
	Local aArea     :=GetArea()
	Local cDocAc9   :=''
	lOCAL cTempPath :=  MsDocRmvBar(GetTempPath())+'\'
   
	cQuery:=" SELECT F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA "
	cQuery+=" FROM "+RETSQLtab("SF1")
	cQuery+=" WHERE F1_DUPL = '"+SE2->E2_NUM+"'"
	cQuery+=" AND F1_PREFIXO = '"+SE2->E2_PREFIXO+"'"
	cQuery+=" AND F1_FORNECE = '"+SE2->E2_FORNECE+"'"
	cQuery+=" AND F1_LOJA = '"+SE2->E2_LOJA+"'"
	cQuery+=" AND "+RetSqlDel("SF1")
	cQuery+=" AND "+RetSqlFil("SF1")

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRB", .t., .t.)

	If !eof()
		cDocAc9:=TRB->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	eND

	dbSelectArea('TRB')
	dbCloseArea()
	RestArea(aArea)

	/*
	If Empty(cDocAc9)
		alert('Nao tem documentos para abrir')
		Return
	End
	*/

	cQuery:=" SELECT * "
	cQuery+=" FROM "+RETSQLtab("AC9,ACB")
	cQuery+=" WHERE ((AC9_ENTIDA = 'SF1' AND AC9_CODENT = '"+cDocAc9+"' ) OR 
	cQuery+="        (AC9_ENTIDA = 'SE2' AND AC9_CODENT ='"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"' ) )"
	cQuery+=" AND "+RetSqlDel("AC9,ACB")
	cQuery+=" AND "+RetSqlFil("AC9,ACB")
	cQuery+=" AND AC9_CODOBJ=ACB_CODOBJ "
	cQuery+=" AND AC9_FILIAL=ACB_FILIAL "

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRB", .t., .t.)
	dbSelectArea('TRB')

	WHILE !eof()
		cFileName:=ALLTRIM(TRB->ACB_OBJETO)

		iF !File(cTempPath+cFileName)
			If !CpyS2T( cDirSrv+cFileName, cTempPath, .T. )
				Alert('problema para copiar '+cFileName+' para '+cTempPath)
				dbSelectArea('TRB')
				dbskip()
			end
		end

		nRet := ShellExecute(cOper,cFileName,cParam,cTempPath, 1 )

		If nRet <= 32
			alert('Não foi possível abrir arquivo '+cTempPath+'\'+cFileName ) 	 //"Atencao!"###"Nao foi possivel abrir o objeto '"###"'!"###"Ok"
		EndIf
		dbSelectArea('TRB')
		dbskip()
	END

	dbSelectArea('TRB')
	dbCloseArea()
	RestArea(aArea)

Return


Static Function MsDocRmvBar( cDirDocs )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira a ultima barra invertida ( se houver )                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDirDocs  := If( Right( cDirDocs, 1 ) == "\", Left( cDirDocs, Len( cDirDocs ) -1 ), cDirDocs )

Return( cDirDocs )

