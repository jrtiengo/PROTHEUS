#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STCR002   º Autor ³ Microsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Atendimento da OS                             º±±
±±º          ³ (conceito Valores em USS)                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sirtec - Field Service                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function STCR002

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2    := "de acordo com os parametros informados pelo usuario."
Local cDesc3    := "Atendimento de OS em USS"
Local cPict     := ""
Local titulo    := "Atendimento de OS em USS"
Local nLin         := 80

Local Cabec1    := ""
Local Cabec2    := ""
Local imprime   := .T.
Local aOrd 		:= {"Cliente+Loja"}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "STCR002" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := padr("STCR02", 10 , " ")    //padr("STCR02", LEN(SX1->X1_GRUPO), " ") 
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "STCR002" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "AB9" 

//Variaveis de controle do relatorio
Private cChave1 := ""
Private cChave2 := ""
Private cChave3 := ""
Private cChave4 := ""
Private nHoras1 := 0
Private nHoras2 := 0
Private nValor1 := 0  
Private nCliTot1 := nOSTot1 := nITTot1 := nATTot1 := 0
Private nCliTot2 := nOSTot2 := nITTot2 := nATTot2 := 0
Private nCliTot3 := nOSTot3 := nITTot3 := nATTot3 := 0
Private nCliTot4 := nOSTot4 := nITTot4 := nATTot4 := 0 
Private cCliDe  
Private cLojDe  
Private cCliAte 
Private cLojAte 
Private cOSDe   
Private cOSAte  
Private cDatDe  
Private cDatAte 
Private nTipo   
Private cNumeroOS := ""

DbSelectArea("AB9")
DbSetOrder(1)

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem := aReturn[8]

/*/
+------------+-----------------------------+
| Parametro  | Descricao                   |
+============+=============================+
| MV_PAR01   |Codigo inicial do cliente    |
| MV_PAR02   |Loja inicial do cliente      |
| MV_PAR03   |Codigo final do cliente      |
| MV_PAR04   |Loja final do cliente        |
| MV_PAR05   |Codigo inicial da OS         |
| MV_PAR06   |Codigo Final da OS           |
| MV_PAR07   |Data inicial                 |
| MV_PAR08   |Data final                   |
| MV_PAR09   |1 - OS / 2 - Atendimentos    |
+------------+-----------------------------+
/*/
cCliDe  := MV_PAR01
cLojDe  := MV_PAR02
cCliAte := MV_PAR03
cLojAte := MV_PAR04
cOSDe   := MV_PAR05
cOSAte  := MV_PAR06
cDatDe  := DTOS(MV_PAR07)
cDatAte := DTOS(MV_PAR08) 
nTipo   := MV_PAR09  

//Monta dados do reltorio
fSTC001()

cString := "_AB6"

DbSelectArea(cString)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount())

_AB6->(DbGoTop())
While !_AB6->(EOF())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin  := 5
	Endif
	
	//Cabecalo do cliente
	If cChave1 <> _AB6->(AB6_CODCLI+AB6_LOJA)
	    If nLin > 5
			//Imprime nova pagina para cada cliente
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 5
		Endif
		
		nLin := nLin + 1
		
		//Imprime informacoes do cliente
		nLin := fSTC002(nLin)

		cChave1 := _AB6->(AB6_CODCLI+AB6_LOJA)
	Endif
	
	//Para compor o total da OS
	If cChave4 <> _AB6->(AB6_NUMOS)
		cChave4 := _AB6->(AB6_NUMOS)
	Endif 
	
	//Ordens de Servico
	If cChave2 <> _AB6->(AB6_NUMOS+AB7_ITEM)
		
		//Imprime o cabecalho dos itens
		nLin := fSTC003(nLin,1)
	
		//Imprime os itens da OS
		nLin := fSTC004(nLin)
		
		//Verifica se imprime as informacoes do atendimento
		If nTipo == 2
			//Imprime cabecalho da despesa do Atendimento
			nLin := fSTC003(nLin,3)
		Endif	
		cChave2 := _AB6->(AB6_NUMOS+AB7_ITEM)
	Endif
	
	//Atendimentos da OS
	If cChave3 <> _AB6->(AB9_NUMOS+AB9_CODTEC+AB9_SEQ)
		
		//Calculo das horas
		fSTC006(1)
		
		//Verifica se imprime as informacoes do atendimento
		If nTipo == 1
			//Imprime o cabecalho da observacao
			nLin := fSTC003(nLin,2)
			
			//Imprime o atendimento da OS
			nLin := fSTC005(nLin)
		
			//Imprime cabecalho da despesa do Atendimento
			nLin := fSTC003(nLin,3)
		Endif
		
		cChave3 := _AB6->(AB9_NUMOS+AB9_CODTEC+AB9_SEQ)
	Endif
    
	//Calculo das horas
	fSTC006(2)
	
	//Imprime depesas da OS
	nLin := fSTC007(nLin)
	
	//Chave da consulta de tabelas de preco
	cNumeroOS := _AB6->AB6_NUMOS
	
	_AB6->(DbSkip()) // Avanca o ponteiro do registro no arquivo
    
	//Imprime Totais do Atendimento
	If cChave3 <> _AB6->(AB9_NUMOS+AB9_CODTEC+AB9_SEQ) .and. nTipo == 1
		
		nLin := nLin +1
		nLin := nLin +1
		
		//Imprime o total
		nLin := fSTC008(nLin,"Total Atendimento",nATTot1,nATTot2,nATTot3,nATTot4)
		
		//Zera totais
		nATTot1 := 0
		nATTot2 := 0
		nATTot3 := 0
		nATTot4 := 0	
	Endif	
	//Imprime Totais do Item da OS
	If cChave2 <> _AB6->(AB6_NUMOS+AB7_ITEM)
		//Verifica se imprime as informacoes do atendimento
		If nTipo == 2
			nLin := nLin +1
			nLin := nLin +1
		Endif
		
		//Imprime o total
		nLin := fSTC008(nLin,"Total do Item da Ordem de Servico",nITTot1,nITTot2,nITTot3,nITTot4)
		
		//Zera totais
		nITTot1 := 0
		nITTot2 := 0
		nITTot3 := 0
		nITTot4 := 0	
	Endif
 
	//Imprime Totais da OS
	If cChave4 <> _AB6->(AB6_NUMOS)
		//Imprime o total
		nLin := fSTC008(nLin,"Total da Ordem de Servico",nOSTot1,nOSTot2,nOSTot3,nOSTot4)
		
		//Zera totais
		nOSTot1 := 0
		nOSTot2 := 0
		nOSTot3 := 0
		nOSTot4 := 0
		
		//Gera totais por tabela de preco
		fSTC009()
		//Imprime Totais por tabela de preco
		nLin := fSTC010(nLin)
	Endif
	
	//Imprime Totais do Cliente
	If cChave1 <> _AB6->(AB6_CODCLI+AB6_LOJA)
		//Imprime o total
		nLin := fSTC008(nLin,"Total Cliente",nCliTot1,nCliTot2,nCliTot3,nCliTot4)
		
		//Zera totais
		nCliTot1 := 0
		nCliTot2 := 0
		nCliTot3 := 0
		nCliTot4 := 0
	Endif
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC001   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Cria arquivo temporario com os dados a serem impressos no  º±±
±±º          ³ relatorio.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC001

Local cSQL := ""
Local cAB6 := RetSQLName("AB6") + " AB6 "
Local cAB7 := RetSQLName("AB7") + " AB7 "
Local cAB9 := RetSQLName("AB9") + " AB9 "
Local cABC := RetSQLName("ABC") + " ABC "
Local cDA1 := RetSQLName("DA1") + " DA1 "
Local cSA1 := RetSQLName("SA1") + " SA1 "
Local cSB1 := RetSQLName("SB1") + " SB1 "

cSQL := " SELECT  "

cSQL += "  AB6.AB6_NUMOS  	 "
cSQL += " , AB6.AB6_CODCLI  	 "
cSQL += " , AB6.AB6_LOJA  	 "
cSQL += " , SA1.A1_NOME  	 "
cSQL += " , AB6.AB6_YDESCR  	 "
cSQL += " , AB6.AB6_TPOS  	 "       //Alterado por Renato Gumesson (08-12-08)
cSQL += " , AB6.AB6_NROBRA  	 "   //Alterado por Renato Gumesson (08-12-08)
cSQL += " , AB6.AB6_EQREF  	 "       //Alterado por Renato Gumesson (08-12-08)
cSQL += " , AB6.AB6_PERIOD  	 "   //Alterado por Renato Gumesson (08-12-08)
cSQL += " , AB6.AB6_YEST  	 "
cSQL += " , AB6.AB6_YMUNI  	 "
cSQL += " , AB6.AB6_YEND  	 "
cSQL += " , AB7.AB7_ITEM  	 "
cSQL += " , AB7.AB7_TIPO  	 "
cSQL += " , AB7.AB7_CODPRO  	 "
cSQL += " , AB7.AB7_NUMSER  	 "
cSQL += " , AB7.AB7_CODPRB  	 "
cSQL += " , AB9.AB9_NUMOS  	 "
cSQL += " , AB9.AB9_CODTEC  	 "
cSQL += " , AB9.AB9_SEQ  	 "
cSQL += " , AB9.AB9_DTINI  	 "
cSQL += " , AB9.AB9_HRINI  	 "
cSQL += " , AB9.AB9_HRFIM  	 "
cSQL += " , AB9.AB9_YIINT  	 "
cSQL += " , AB9.AB9_YFINT  	 "
cSQL += " , ABC.ABC_SUBOS  	 "
cSQL += " , ABC.ABC_ITEM  	 "
cSQL += " , ABC.ABC_CODPRO  	 "
cSQL += " , ABC.ABC_DESCRI  	 "
cSQL += " , ABC.ABC_CODSER  	 "
cSQL += " , ABC.ABC_YTABPR  	 "
cSQL += " , ABC.ABC_QUANT  	 "
cSQL += " , DA1.DA1_YQUSS  	 "
cSQL += " , ABC.ABC_VALOR   "

cSQL += " FROM " + cABC + " "

cSQL += " INNER JOIN " + cAB9 + " ON "

cSQL += "     AB9.D_E_L_E_T_ = '' "
cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' "
cSQL += " AND AB9.AB9_NUMOS  = ABC.ABC_NUMOS "
cSQL += " AND AB9.AB9_CODTEC = ABC.ABC_CODTEC "
cSQL += " AND AB9.AB9_SEQ    = ABC.ABC_SEQ "


cSQL += " INNER JOIN " + cAB7 + " ON "

cSQL += "     AB7.D_E_L_E_T_             = '' "
cSQL += " AND AB7.AB7_FILIAL             = '" + xFilial("AB7") + "' "
cSQL += " AND AB7.AB7_NUMOS+AB7.AB7_ITEM = ABC.ABC_NUMOS "

cSQL += " INNER JOIN " + cAB6 + " ON "

cSQL += "     AB6.D_E_L_E_T_ = '' "
cSQL += " AND AB6.AB6_FILIAL = '" + xFilial("AB6") + "' "
cSQL += " AND AB6.AB6_NUMOS  = LEFT(ABC.ABC_NUMOS,6) "

cSQL += " INNER JOIN " + cSA1 + "  ON  	 "

cSQL += "     SA1.D_E_L_E_T_ = ''  "
cSQL += " AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
cSQL += " AND AB9.AB9_CODCLI = SA1.A1_COD "
cSQL += " AND AB9.AB9_LOJA   = SA1.A1_LOJA  "

cSQL += " LEFT OUTER JOIN " + cDA1 + "  ON  	 "

cSQL += "     DA1.D_E_L_E_T_ = ''  "
cSQL += " AND DA1.DA1_FILIAL  = '" + xFilial("DA1") + "' "
cSQL += " AND ABC.ABC_YTABPR = DA1.DA1_CODTAB  	 "
cSQL += " AND ABC.ABC_CODPRO = DA1.DA1_CODPRO  	 "
 

cSQL += " WHERE "

cSQL += "     ABC.D_E_L_E_T_  = ''  "
cSQL += " AND ABC.ABC_FILIAL  = '" + xFilial("ABC") + "' "
cSQL += " AND AB6.AB6_NUMOS      BETWEEN '" + cOSDe + "'  AND '" + cOSAte + "'  "
cSQL += " AND AB6.AB6_CODCLI BETWEEN '" + cCliDe + "' AND '" + cCliAte + "' "
cSQL += " AND AB6.AB6_LOJA   BETWEEN '" + cLojDe + "' AND '" + cLojAte + "' "
cSQL += " AND AB9.AB9_DTINI  BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "

cSQL += " ORDER BY AB6.AB6_FILIAL"
cSQL += " ,AB6.AB6_CODCLI"
cSQL += " ,AB6.AB6_LOJA"
cSQL += " ,AB9.AB9_FILIAL"
cSQL += " ,AB9.AB9_NUMOS"
cSQL += " ,AB9.AB9_CODTEC"
cSQL += " ,AB9.AB9_SEQ"
cSQL += " ,ABC.ABC_FILIAL"
cSQL += " ,ABC.ABC_NUMOS"
cSQL += " ,ABC.ABC_CODTEC"
cSQL += " ,ABC.ABC_SEQ"
cSQL += " ,ABC.ABC_ITEM  "

//Log de controle
Memowrite('\STCR002-1.TXT',cSQL)

//Verifica se alias está em uso
If chkfile("_AB6")
	DbselectArea("_AB6")
	DbCloseArea()
End If

//Cria query
TcQuery cSQL New Alias "_AB6"
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC002   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime o cabecalho do cliente                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC002(nLin)
                                               
@nLin,000 PSAY "Cliente: "
@nLin,011 PSAY _AB6->AB6_CODCLI
@nLin,020 PSAY "Loja: "
@nLin,027 PSAY _AB6->AB6_LOJA
@nLin,040 PSAY "Nome: "
@nLin,046 PSAY _AB6->A1_NOME

nLin := nLin + 1

@nLin,000 PSAY "Descricao: " 
@nLin,011 PSAY _AB6->AB6_YDESCR 

// Início alteração por Renato Gumesson (08-12-08)

nLin := nLin + 1

@nLin,000 PSAY "Tipo OS: " 
@nLin,011 PSAY _AB6->AB6_TPOS 
@nLin,070 PSAY "Nr Obra: " 
@nLin,080 PSAY _AB6->AB6_NROBRA

nLin := nLin + 1

@nLin,000 PSAY "Equipam. Ref: " 
@nLin,015 PSAY _AB6->AB6_EQREF 
@nLin,070 PSAY "Período: " 
@nLin,080 PSAY _AB6->AB6_PERIOD
 
// Fim Alteração por Renato Gumesson

nLin := nLin + 1

@nLin,000 PSAY "Estado: " 
@nLin,011 PSAY _AB6->AB6_YEST
@nLin,015 PSAY "Cidade: " 
@nLin,023 PSAY _AB6->AB6_YMUNI 
@nLin,070 PSAY "Endereco: " 
@nLin,080 PSAY _AB6->AB6_YEND

nLin := nLin + 1
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC003   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime cabecalho dos itnes                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC003(nLin,nOpc)

Local cCab1 := ""
Local cCab2 := ""

/*/
Do Case
	Case nOpc == 1
	 	cCab1 := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	 	cCab2 := "| Item | Situacao       | Produto       | Descricao Produto             | Num. Serie         | Ocorrencia | Descricao                    | Observacao"
	
	Case nOpc == 2 
		cCab1 := "       +-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		cCab2 := "       | Atendimento | Equipe | SEQ | Dt. Chegada | Hr. Inicial | Hr. Termino | Tot. Intervalo | Total Hrs." 
       
    Case nOpc == 3
		cCab1 := "                     +-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
		cCab2 := "                     | Produto     | Descricao | Servico | Tabela | Quant | USS Unitaria | Total USS | Valor Total

EndCase
/*/

Do Case
	Case nOpc == 1
	 	cCab1 := "____________________________________________________________________________________________________________________________________________________________________________________________________________________________"
	 	cCab2 := " OS      Item   Situacao         Produto         Descricao Produto               Num. Serie           Ocorrencia   Descricao                      Observacao"
	
	Case nOpc == 2 
		cCab1 := "        ____________________________________________________________________________________________________________________________________________________________________________________________________________________"
		cCab2 := "         Atendimento   Equipe   SEQ   Dt. Chegada   Hr. Inicial   Hr. Termino   Tot. Intervalo   Total Hrs." 
       
    Case nOpc == 3
		cCab1 := "                      ______________________________________________________________________________________________________________________________________________________________________________________________________"
		cCab2 := "                      Item  Sub.It.  Produto           Descricao                        Cod. Servico   Servico                          Tabela            Quant        USS Unitaria           Total USS         Valor Total"

EndCase

nLin := nLin +1

//@nLin,000 PSAY cCab1 
//nLin := nLin +1

@nLin,000 PSAY cCab2 + Space(limite-Len(cCab2)-1) //+ "|"

nLin := nLin +1

@nLin,000 PSAY cCab1 

nLin := nLin +1
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC004   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime os itens da Ordem de Servico                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC004(nLin)

Local cTipo    := ""
Local cDescPro := Posicione("SB1",1,xFilial("SB1")+_AB6->AB7_CODPRO,"B1_DESC")
Local cOcorren := Posicione("AAG",1,xFilial("AAG")+_AB6->AB7_CODPRB,"AAG_DESCRI") 
Local cOBS1    := Posicione("AB7",1,xFilial("AB7")+_AB6->(AB6_NUMOS+AB7_ITEM),"AB7_MEMO1")
Local cOBS2    := '' 

SYP->(DbSetOrder(1))
If SYP->(DbSeek(xFilial("SYP")+cOBS1))
	While ! SYP->(EOF()) .and. SYP->YP_CHAVE == cOBS1
		cOBS2 += Alltrim(SYP->YP_TEXTO)
		SYP->(DbSkip())
	EndDo
EndIf

// Coloca o salto de linha		
While .T.
 
   nPos := AT("\13\10",cOBS2)
   IF nPos > 0
      cOBS2 := stuff(cOBS2,nPos,6,CHR(13)+CHR(10))
   ELSE
      exit
   End

End         
	
Do Case
	Case _AB6->AB7_TIPO == "1"
		cTipo := "O.S." 

	Case _AB6->AB7_TIPO == "2"
		cTipo := "Pedido Gerado" 

	Case _AB6->AB7_TIPO == "3"
		cTipo := "Em Atendimento"
		
	Case _AB6->AB7_TIPO == "4"
		cTipo := "Atendido"	

	Case _AB6->AB7_TIPO == "5"
		cTipo := "Encerrado"			
EndCase

@nLin,001 PSAY _AB6->AB6_NUMOS
@nLin,009 PSAY _AB6->AB7_ITEM
@nLin,016 PSAY cTipo
@nLin,033 PSAY _AB6->AB7_CODPRO
@nLin,049 PSAY cDescPro
@nLin,081 PSAY _AB6->AB7_NUMSER      
@nLin,102 PSAY _AB6->AB7_CODPRB                      
@nLin,115 PSAY cOcorren                     

//Imprime a observacao
nOBS := MLCount(cOBS2,70)
For nBegin := 1 To nOBS
	@nLin,146 PSAY Memoline(cOBS2,70,nBegin)
	nLin := nLin +1
Next nBegin

nLin := nLin +1
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC005   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime o cabecalho dos atendimentos de OS                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC005(nLin)

@nLin,009 PSAY _AB6->AB9_NUMOS                       
@nLin,023 PSAY _AB6->AB9_CODTEC                      
@nLin,032 PSAY _AB6->AB9_SEQ                         
@nLin,038 PSAY _AB6->AB9_DTINI                      
@nLin,052 PSAY _AB6->AB9_HRINI                       
@nLin,066 PSAY _AB6->AB9_HRFIM                       
@nLin,080 PSAY IntToHora(nHoras1)                       
@nLin,097 PSAY IntToHora(nHoras2)                       

nLin := nLin +1	
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC006   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Calcula Totais do Relatorio                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC006(nOpc)

Do Case
	Case nOpc == 1
		//Horas de intervalo
		nHoras1 := SubtHoras(STOD(_AB6->AB9_DTINI),_AB6->AB9_YIINT,STOD(_AB6->AB9_DTINI),_AB6->AB9_YFINT) 

		//Horas de servico
		nHoras2 := SubtHoras(STOD(_AB6->AB9_DTINI),_AB6->AB9_HRINI,STOD(_AB6->AB9_DTINI),_AB6->AB9_HRFIM) - nHoras1

		//Totais dO Atendimento
		nATTot1 += nHoras1
		nATTot2 += nHoras2 
				
		//Totais do Item da OS
		nITTot1 += nHoras1
		nITTot2 += nHoras2 
		
		//Totais do Item da OS
		nOSTot1 += nHoras1
		nOSTot2 += nHoras2 

		//Totais do cliente
		nCliTot1 += nHoras1
		nCliTot2 += nHoras2
	
	Case nOpc == 2
		//Total USS da despesa
		nValor1 := NoRound(_AB6->ABC_QUANT*_AB6->DA1_YQUSS)

		//Totais do Atendimento		
		nATTot3 += nValor1
		nATTot4 += _AB6->ABC_VALOR
		
		//Totais da OS		
		nOSTot3 += nValor1
		nOSTot4 += _AB6->ABC_VALOR
		
		//Totais do Item da OS		
		nITTot3 += nValor1
		nITTot4 += _AB6->ABC_VALOR

		//Totais do cliente
		nCliTot3 += nValor1
		nCliTot4 += _AB6->ABC_VALOR
	EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC007   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime itens das despesas                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC007(nLin)

@nLin,022 PSAY _AB6->ABC_SUBOS                       
@nLin,028 PSAY _AB6->ABC_ITEM                       
@nLin,037 PSAY _AB6->ABC_CODPRO                       
@nLin,055 PSAY _AB6->ABC_DESCRI
@nLin,088 PSAY _AB6->ABC_CODSER
@nLin,103 PSAY "SERVICO"
@nLin,136 PSAY _AB6->ABC_YTABPR
@nLin,145 PSAY Padl(Transform(_AB6->ABC_QUANT,"@E 999,999,999.99"),14)
@nLin,165 PSAY Padl(Transform(_AB6->DA1_YQUSS,"@E 999,999,999.99"),14)
@nLin,185 PSAY Padl(Transform(nValor1        ,"@E 999,999,999.99"),14)
@nLin,205 PSAY Padl(Transform(_AB6->ABC_VALOR,"@E 999,999,999.99"),14)

nLin := nLin + 1
Return nLin               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC008   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Totais do relatorio                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC008(nLin,cTotal,n1,n2,n3,n4)

@nLin,001 PSAY cTotal
//Verifica se imprime as informacoes do atendimento
If nTipo == 1
	@nLin,080 PSAY IntToHora(n1)                       
	@nLin,097 PSAY IntToHora(n2) 
Endif
@nLin,185 PSAY Padl(Transform(n3,"@E 999,999,999.99"),14)
@nLin,205 PSAY Padl(Transform(n4,"@E 999,999,999.99"),14)

nLin := nLin +1
Return nLin  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC009   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Cria arquivo temporario com os dados a serem impressos no  º±±
±±º          ³ relatorio. Totais das tabelas de preco "                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC009

Local cSQL := ""
Local cAB6 := RetSQLName("AB6") + " AB6 "
Local cAB7 := RetSQLName("AB7") + " AB7 "
Local cAB9 := RetSQLName("AB9") + " AB9 "
Local cABC := RetSQLName("ABC") + " ABC "
Local cDA1 := RetSQLName("DA1") + " DA1 "
Local cSA1 := RetSQLName("SA1") + " SA1 "
Local cSB1 := RetSQLName("SB1") + " SB1 "

cSQL += "  SELECT    " 

cSQL += " DA1.DA1_CODTAB" 
cSQL += " ,SUM(ABC.ABC_QUANT*DA1.DA1_YQUSS) DA1_YQUSS" 

cSQL += " FROM " + cABC + "   " 

cSQL += " INNER JOIN " + cAB9 + "  ON      " 

cSQL += " AB9.D_E_L_E_T_ = ''  " 
cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' "
cSQL += " AND AB9.AB9_NUMOS  = ABC.ABC_NUMOS  " 
cSQL += " AND AB9.AB9_CODTEC = ABC.ABC_CODTEC  " 
cSQL += " AND AB9.AB9_SEQ    = ABC.ABC_SEQ  " 

cSQL += " INNER JOIN " + cAB7 + "  ON      " 

cSQL += " AB7.D_E_L_E_T_             = ''  " 
cSQL += " AND AB7.AB7_FILIAL         = '" + xFilial("AB7") + "' "
cSQL += " AND AB7.AB7_NUMOS+AB7.AB7_ITEM = ABC.ABC_NUMOS  " 

cSQL += " INNER JOIN " + cAB6 + "  ON      " 

cSQL += " AB6.D_E_L_E_T_ = ''  " 
cSQL += " AND AB6.AB6_FILIAL = '" + xFilial("AB6") + "' "
cSQL += " AND AB6.AB6_NUMOS  = LEFT(ABC.ABC_NUMOS,6)  " 

cSQL += " INNER JOIN " + cDA1 + "  ON  	      " 

cSQL += " DA1.D_E_L_E_T_ = ''   " 
cSQL += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "
cSQL += " AND ABC.ABC_YTABPR = DA1.DA1_CODTAB  	  " 
cSQL += " AND ABC.ABC_CODPRO = DA1.DA1_CODPRO  	  " 

cSQL += " WHERE      " 

cSQL += " ABC.D_E_L_E_T_ = ''   " 
cSQL += " AND ABC.ABC_FILIAL = '" + xFilial("ABC") + "' "
cSQL += " AND AB6.AB6_NUMOS  = '" + cNumeroOS + "' "

cSQL += " GROUP BY DA1.DA1_CODTAB" 

cSQL += " ORDER BY DA1.DA1_CODTAB"    


//Log de controle
Memowrite('\STCR002-2.TXT',cSQL)

//Verifica se alias está em uso
If chkfile("_DA1")
	DbselectArea("_DA1")
	DbCloseArea()
End If

//Cria query
TcQuery cSQL New Alias "_DA1"

Return    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC010   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Totais da tabela de preco                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC010(nLin)

nLin := nLin +1
@nLin,001 PSAY "Totais de USS por Tabela de preco" 
nLin := nLin +1
@nLin,001 PSAY "---------------------------------
nLin := nLin +1

_DA1->(DbGoTop())
While !_DA1->(EOF())	
	
	@nLin, 005 PSAY _DA1->DA1_CODTAB	
	@nLin, 025 PSAY Padl(Transform(NoRound(_DA1->DA1_YQUSS,2),"@E 999,999,999.99"),14)
	
	nLin := nLin +1
	
	_DA1->(DbSkip())
EndDo
nLin := nLin +1

Return nLin  