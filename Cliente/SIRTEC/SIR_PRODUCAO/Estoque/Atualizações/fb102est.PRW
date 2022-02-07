#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ML_ETS   ³ Autor ³ Rodny                 ³ Data ³ Dez/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao etiqueta termica cadastro de produtos 			   ±±
±±³				no enderecamento de estoque            					   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Especifico para Clientes Microsiga                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function fb102est(cSer,cNfDe)


_cNumnf    := ""//space(06)
_cSernf    := ""//space(03)
_nQtdEtq   := 0
_cProd	  := ""

//NOVO
//parametros automaticos passados pelo SF2460I
If !Empty(cNfDe) .or. !Empty(cSer)
	//	if type(cNfDe) == "C"
	_cNumnf := cNfDe
	//	endif
	//if type(cSer) == "C"
	_cSernf := cSer
	//	endif
	//else
	
endif


Exec       := .t.
_cPrinter := GetNewPar("FB_E102EST","\\PC0336\ETIQ_ALMOX") //
_cArquivo  := "\etiquetas\etinfs.txt" 
_aArea     := GetArea()
//_cNumnf    := space(06)
//_cSernf    := space(03)
cWorkTra   := ""
//+++++
Private cPerg := PADR("FB102EST", 10 ," ") //PADR("FB102EST", LEN(SX1->X1_GRUPO)," ")

validPerg()
//Pergunte(cPerg,.T.)	
if !pergunte(cPerg,.T.)
	RestArea(_aArea)
	Return NIL
Endif


MakeDir("c:\temp")
if !File("c:\temp\print.bat")
	memowrite("c:\temp\print.bat","copy %1 %2")
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela para informar os dados de impressao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


_cQuery := "SELECT DB_PRODUTO _CODPRO, DB_NUMSERI _SERIE, B1_DESC _DESCPRO,"
_cQuery += " _CODBARR = RIGHT('000000' + RTRIM(DB_PRODUTO), 6) +  RIGHT('000000' + RTRIM(DB_NUMSERI), 6) "  
_cQuery += " FROM " + RetSQLName("SDB") + " AS SDB, " + RetSQLName("SDA") + " AS SDA, " + RetSQLName("SB1") + " AS SB1 "
_cQuery += " WHERE "
_cQuery += " SDB.D_E_L_E_T_ = '' AND "
_cQuery += " SDA.D_E_L_E_T_ = '' AND "
_cQuery += " SB1.D_E_L_E_T_ = '' AND "
_cQuery += " DA_PRODUTO BETWEEN '" + mv_par01 + "'AND '" + mv_par02 + "' AND "
_cQuery += " DB_NUMSERI BETWEEN '" + mv_par03 + "'AND '" + mv_par04 + "' AND "
_cQuery += " DA_PRODUTO = DB_PRODUTO AND "
_cQuery += " B1_COD = DA_PRODUTO AND "
_cQuery += " DB_NUMSERI <> ''  "
_cQuery += " GROUP BY DB_PRODUTO, DB_NUMSERI, B1_DESC " 
_cQuery += " ORDER BY DB_PRODUTO "

_cQuery := changeQuery(_cQuery)                                               
//TcQuery _cQuery new alias _TRB
dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TRB", .F., .T.)

//cWorkTra := CriaTrab(_TRB)
//DbUseArea(.t.,,cWorkTra,"TRB",.f.,.f.)

//U_ShowTRB("TRB")       
_Imprimir()


RestArea(_aArea)

Return


// Impressao
Static Function _Imprimir()

_xFIM := CHR(13)+CHR(10)

nHdl := fCreate(_cArquivo)
If nHdl==-1
	#IFDEF WINDOWS
		MsgAlert("Arquivo de nome "+_cArquivo+" nao pode ser executado! ","Atencao!")
	#ENDIF
	Return
Endif

cCmd := ''
lImp := .F.
nPos := 10

dbselectarea("TRB")
TRB->(DbGoToP())
While !TRB->(EOF())
	lImp := .T.
	If nPos == 10
		cCmd += Chr(2)+'f320'+_xFim
		cCmd += Chr(2)+'L'+_xFim
		cCmd += Chr(2)+'m'+_xFim
		cCmd += Chr(2)+'H18'+_xFim
		cCmd += Chr(2)+'D11'+_xFim
	Endif
	cCmd += '19110020180'+StrZero(nPos,4)+'COD.'+_xFim
	cCmd += '19110020180'+StrZero(nPos+80,4)+alltrim(_CODPRO)+_xFim
	cCmd += '19110020180'+StrZero(nPos+300,4)+'SERIE'+_xFim
	cCmd += '19110020180'+StrZero(nPos+400,4)+Alltrim(_SERIE)+_xFim
	cCmd += '19110020140'+StrZero(nPos,4)+left(_DESCPRO,25)+_xFim
	If len(alltrim(_DESCPRO)) > 25
		cCmd += '19110020100'+StrZero(nPos,4)+substr(_DESCPRO,26,25)+_xFim
	Endif
	cCmd += '1E000450010'+StrZero(nPos+30,4)+_CODBARR+_xFim
	If nPos == 10
		nPos := 550
	Else
		nPos := 10
		cCmd += 'Q0001'+_xFim
		cCmd += 'E'+_xFim
	Endif
	
	TRB->(DbSkip())
End
TRB->(DbCloseArea())

If nPos == 550
	cCmd += 'Q0001'+_xFim
	cCmd += 'E'+_xFim
Endif

If fWrite(nHdl,cCmd,Len(cCmd)) != Len(cCmd)
	MsgAlert("Ocorreu um erro na gravacao do arquivo " + _cArquivo,"Atencao!")
	fClose(nHdl)
	Return
Endif

/*
dbselectarea("TRB")
//copy to aaaetiq.dbf
//alert("gravou arquivo")
dbgotop()
do while ! eof ()
		
		_cLinha01 := "m"+_xFim
		_cLinha02 := "O0559"+_xFim
		//_cLinha03 := "f759"+_xFim           // Indica o quando a impressora avanca apos impressao 10mm
		_cLinha04 := "L"+_xFim
		_cLinha05 := "H18"+_xFim
		_cLinha06 := "D11"+_xFim
		_cLinha07 := "R0000"+_xFim
		_cLinha08 := "C0000"+_xFim
                  //abcdeeeffffgggg
					//       	linhcolu
		//COLUNA 1
		_cLinha09 := "191100201500020COD."+_xFim
		_cLinha10 := "191100201500100"+alltrim(_CODPRO)+_xFim
		_cLinha11 := "191100201500320SERIE"+_xFim
		_cLinha12 := "191100201500450"+_SERIE+_xFim
	  	_cLinha13 := "191100201000020"+_DESCPRO+_xFim
		_cLinha14 := "1E0004500200040"+_CODBARR+_xFim
	
	dbselectarea("TRB")
	dbskip()
	
		//COLUNA 2
		_cLinha15 := "191100201500545COD."+_xFim
		_cLinha16 := "191100201500625"+alltrim(_CODPRO)+_xFim
		_cLinha17 := "191100201500845SERIE"+_xFim
		_cLinha18 := "191100201500955"+_SERIE+_xFim
		_cLinha19 := "191100201000545"+_DESCPRO+_xFim
		_cLinha20 := "1E0004500200565"+_CODBARR+_xFim

		_cLinha21 := "Q0001"+_xFim  //quantidade de etiquetas para imprimir
		_cLinha22 := "E"+_xFim // fim do bloco 
		
		cLin := ""
		cLin := cLin + _cLinha01 + _cLinha02 + _cLinha03 + _cLinha04 + _cLinha05 + _cLinha06 +;
		_cLinha07 + _cLinha08 + _cLinha09 + _cLinha10 + _cLinha11 + _cLinha12 +;
		_cLinha13 + _cLinha14 + _cLinha15 + _cLinha16 + _cLinha17 + _cLinha18 +;
		_cLinha19 + _cLinha20 + _cLinha21 + _cLinha22 
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert("Ocorreu um erro na gravacao do arquivo " + _cArquivo,"Atencao!")
		Endif
		
		
		_cLinha42 := "Q0001"+_xFim  //quantidade de etiquetas para imprimir
		_cLinha43 := "E"+_xFim // fim do bloco
	
	dbselectarea("TRB")
	dbskip()
	
enddo
//_cCmd := "COMMAND.COM /C \\192.168.0.250\etiquetas\ml_ets.bat"
//WinExec(_cCmd)
//waitrun("\\server\siga\protheus8\protheus_data\ml_ets.bat" )
dbselectarea("TRB")
dbclosearea()
ferase(cWorkTra+".dbf")
*/
fClose(nHdl)

If lImp
	lCopy := CPYS2T(_cArquivo,"c:\temp\")
	If lCopy
		winexec("c:\temp\print.bat c:\temp\etinfs.txt "+Alltrim(_cPrinter),0)
		//alert('imprimindo')
	Else
		MsgAlert("Problemas na impressão da etiqueta.")
		lCont := .F.
	Endif	
	sleep(1000)
Else
	MsgInfo("Não há dados a imprimir.")
Endif

Return


//Perguntas
Static Function ValidPerg()
	local _aArea  := GetArea ()
	local _aRegs  := {}
	local _aHelps := {}
	local _i      := 0
	local _j      := 0
	
	_aRegs = {}
	//           GRUPO  ORDEM PERGUNT                         PERSPA PERENG  VARIAVL   TIPO  TAM DEC PRESEL GSC  VALID         	VAR01   DEF01              	DEFSPA1             DEFENG1             CNT01 VAR02 	DEF02              	DEFSPA2             DEFENG2           	CNT02 VAR03 DEF03   					DEFSPA3  DEFENG3  CNT03 VAR04 DEF04  			DEFSPA4  	DEFENG4  CNT04 VAR05 DEF05   	DEFSPA5   DEFENG5  	CNT05  F3    	PYME   GRPSXG                                           
	AADD(_aRegs,{cPerg,"01","Produto de?           				",	"",	 "",   "mv_ch1",	"C",	15, 0, 0, 	"G", "",	  "mv_par01",	"",						"",                 "",                 "",	 "",		"",						"",						"",					"",	"",	"",							"",		"",		"",	"",	"",	 			"",			"",		"",	"",	"",		"",      "",         "",   "SB1",     ""})
	AADD(_aRegs,{cPerg,"02","Produto Até?       					",	"",	 "",   "mv_ch2",	"C",	15, 0, 0, 	"G", "",	  "mv_par02",	"",						"",                 "",                 "",	 "",		"",						"",						"",					"",	"",	"",							"",		"",		"",	"",	"",	 			"",			"",		"",	"",	"",		"",      "",         "",   "SB1",     ""})
	AADD(_aRegs,{cPerg,"03","Série de?								",	"",	 "",   "mv_ch3",	"C",	10, 0, 0, 	"G", "",   "mv_par03",	"",						"",                 "",                 "",	 "",		"",						"",						"",					"",	"",	"",							"",		"",		"",	"",	"",	 			"",			"",		"",	"",	"",		"",		"",			"",	""})
	AADD(_aRegs,{cPerg,"04","Série Até?			     				",	"",	 "",   "mv_ch4",	"C",	10, 0, 0, 	"G", "",   "mv_par04",	"",						"",    		        "",   			       "",	 "", 		"",						"",	 					"",		   		"",	"",	"",			 				"",		"",		"",	"",	"",	 			"",			"",		"",	"",	"",		"",		"",			"",	""})
   

	// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
	_aHelps = {}
	//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
	AADD (_aHelps, {"01", {"Código de Produto Inicial  ", "                                  ", "                                       "}})
	AADD (_aHelps, {"02", {"Código de Produto Final    ", "                                  ", "                                       "}})
	AADD (_aHelps, {"03", {"Código de Série Inicial 	", "                                  ", "	                                    "}})                                                                                                                                                                                                                                                                                                                                                              
	AADD (_aHelps, {"04", {"Código de Série Final 	 	", "                                  ", "	                                    "}})                                                                                                                                                                                                                                                                                                                                                              
	
	 
	/*	
	DbSelectArea ("SX1")
	DbSetOrder (1)
	For _i := 1 to Len (_aRegs)
	    If ! DbSeek (cPerg + _aRegs [_i, 2])
	       RecLock("SX1", .T.)
	    Else
	       RecLock("SX1", .F.)
	    Endif
	    For _j := 1 to FCount ()
	       // Campos CNT nao sao gravados para preservar conteudo anterior.
	       If _j <= Len (_aRegs [_i]) .and. left (fieldname (_j), 6) != "X1_CNT" .and. fieldname (_j) != "X1_PRESEL"
	          FieldPut(_j, _aRegs [_i, _j])
	       Endif
	    Next
	    MsUnlock()
	Next
	
	// Deleta do SX1 as perguntas que nao constam em _aRegs
	DbSeek (cPerg, .T.)
	do while ! eof () .and. x1_grupo == cPerg
	   if ascan (_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
	      reclock("SX1", .F.)
	      dbdelete()
	      msunlock()
	   endif
	   dbskip()
	enddo
	
	// Gera helps das perguntas
	For _i := 1 to Len (_aHelps)
	   PutSX1Help ("P." + AllTrim(cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
	Next
	
	*/
	
	Restarea(_aArea)
	
Return

