#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "RptDef.CH"
#Include "FwPrintSetup.ch

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELENFER01บAutor  ณTotvs    บ Data ณ  09/13/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de peso total por data e Cliente                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Enfer                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RELENFER01()


Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
//Local cPict          := ""
Local titulo         := ""
Local nLin           := 80

Local Cabec1         := "Data                  Cliente                       Descri็ใo                     					 Vlr.Nf              Peso Total"
Local Cabec2         := ""
//Local imprime        := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "RELENFER01" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RELENFER01" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg        := "RELENFER01"
//Private oFont16n	 := TFont():New("TIMES",9,25,.T.,.F.,5,.T.,5,.T.,.F.)
//Private oObjeto
Private cString := "SF2"

CriaPerg(cPerg)

If !Pergunte(cPerg,.T.)
	Return(Nil)
EndIf

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunReportบAutor  ณTotvs    บ Data ณ  09/13/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Enfer                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cQry := ""
Local nTotVal:= 0
Local nTotPes := 0

cQry := "SELECT F2_EMISSAO,F2_CLIENTE,F2_PLIQUI,F2_LOJA,F2_VALBRUT FROM "+RetSqlName("SF2")+" "
cQry += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' "
cQry += "AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01) +"' AND '"+DTOS(MV_PAR02) +"' "
cQry += "AND F2_CLIENTE = '"+ ALLTRIM(MV_PAR03) +"' "
cQry += "AND F2_TIPO = 'B' "
cQry += "ORDER BY F2_DOC "

If Select("TMPSF2") <> 0
	TMPSF2->(DbCloseArea())
EndIf

TcQuery cQry New Alias "TMPSF2"


DbSelectArea("TMPSF2")
SetRegua(RecCount())
TMPSF2->(dbGoTop())
While TMPSF2->(!EOF())
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	/*
	dF2Data := STOD(TMPSF2->F2_EMISSAO) 
	PrintOut(@nLin,00,DTOC(dF2Data),,cTaman)
	PrintOut(@nLin,23,TMPSF2->F2_CLIENTE,,cTaman)
	PrintOut(@nLin,50,POSICIONE("SA1",1,xFilial("SA1")+alltrim(TMPSF2->F2_CLIENTE)+alltrim(TMPSF2->F2_LOJA),'A1_NOME'),,cTaman)
	PrintOut(@nLin,125,Transform(TMPSF2->F2_VALBRUT,"@e 9,999,999,999,999.99"),,cTaman)
	PrintOut(@nLin,155,Transform(TMPSF2->F2_PLIQUI,"@E 999999.9999"),,cTaman)
	*/

	dF2Data := STOD(TMPSF2->F2_EMISSAO)
    @nLin,00    PSAY DTOC(dF2Data)
    @nLin,23    PSAY TMPSF2->F2_CLIENTE
    @nLin,50    PSAY POSICIONE("SA1",1,xFilial("SA1")+alltrim(TMPSF2->F2_CLIENTE)+alltrim(TMPSF2->F2_LOJA),'A1_NOME')
    @nLin,125   PSAY Transform(TMPSF2->F2_VALBRUT,"@e 9,999,999,999,999.99")
    @nLin,155   PSAY Transform(TMPSF2->F2_PLIQUI,"@E 999999.9999")
	
	nLin := nLin + 1
	
	nTotVal += TMPSF2->F2_VALBRUT
	nTotPes += TMPSF2->F2_PLIQUI
	
	TMPSF2->(dbSkip())
EndDo
nLin := nLin + 1
@nLin,00 PSAY "Total"
@nLin,10 PSAY REPLICATE("*",160)

nLin := nLin + 1
@nLin,125 PSAY Transform(nTotVal,"@e 9,999,999,999,999.99")
@nLin,155 PSAY Transform(nTotPes,"@E 999999.9999")

TMPSF2->(DbCloseArea())

SET DEVICE TO SCREEN


If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaPerg บAutor  ณTotvs     บ Data ณ  09/13/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria o grupo de perguntas no SX1                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Enfer                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaPerg(cPerg)


PutSx1(cPerg, "01","Emissใo de?","","","mv_ch1","D",08,00,00,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{"Digite uma data inicial"},{},{},"")
PutSx1(cPerg, "02","Emissใo ate?","","","mv_ch2","D",08,00,00,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",{"Digite uma data Final"},{},{},"")
PutSx1(cPerg, "03","Fornecedor de?","","","mv_ch3","C",06,00,00,"G","","SA2","","","mv_par03","","","","","","","","","","","","","","","","",{"Digite o codigo do Fornecedor"},{},{},"")




Return

