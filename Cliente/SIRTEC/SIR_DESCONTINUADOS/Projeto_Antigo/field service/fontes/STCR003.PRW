#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSTCR003   บ Autor ณ Microsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Indice de Produtividade                       บฑฑ
ฑฑบ          ณ (conceito USS por atendimento)                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sirtec - Field Service                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function STCR003

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2    := "de acordo com os parametros informados pelo usuario."
Local cDesc3    := "Indice de Produtividade"        
Local cPict     := ""
Local titulo    := "Indice de Produtividade"          
Local nLin         := 80

Local Cabec1    := ""                                      	
Local Cabec2    := ""
Local imprime   := .T.
Local aOrd 		:= {"Equipe"}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "STCR003" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := padr("STCR03", 10 , " ")   //padr("STCR03", LEN(SX1->X1_GRUPO), " ") 
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "STCR003" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "AB9"  

//Variaveis de controle do relatorio
Private cChave1  := ""
Private nHrInter := 0 
Private nHrAtend := 0  
Private nUSSAten := 0 
Private nIndFunc := 0  
Private nProdEsp := 0  
Private nIndProd := 0  
Private nTotal1  := 0
Private nTotal2  := 0 
Private nTotal3  := 0 
Private cEqpDe  
Private cEqpAte 
Private cOSDe   
Private cOSAte   
Private cDatDe  
Private cDatAte 
Private cNomeEqp := ""

DbSelectArea("AB9")
DbSetOrder(1)

Pergunte(cPerg,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem := aReturn[8]

/*/
+------------+-----------------------------+
| Parametro  | Descricao                   |
+============+=============================+
| MV_PAR01   |Codigo inicial da equipe     |
| MV_PAR02   |Codigo final da equipe       |
| MV_PAR03   |Codigo inicial do Atendimento|
| MV_PAR04   |Codigo final do Atendimento  |
| MV_PAR05   |Data inicila do Atendimento  |
| MV_PAR06   |Data final do Atendimento    |
+------------+-----------------------------+
/*/
cEqpDe  := MV_PAR01
cEqpAte := MV_PAR02
cOSDe   := MV_PAR03
cSeqDe  := MV_PAR04
cOSAte  := MV_PAR05
cSeqAte := MV_PAR06  
cDatDe  := DTOS(MV_PAR07)
cDatAte := DTOS(MV_PAR08) 

//Ajusta cabecalho do relatorio
If aReturn[4] == 1
	Cabec1    := ""                                      	
	Cabec2    := ""
	Tamanho   := "P"
Else             
	Cabec1    := "Codigo  Nome                                      Atendimento Seq   Data      Horas       USS Atd.    Ind. Func.    Esperado       Indice"
	Cabec2    := ""
	Tamanho   := "G"
Endif

//Monta dados do reltorio
fSTC001(1)

cString := "_AB9"

DbSelectArea(cString)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetRegua(RecCount())

_AB9->(DbGoTop())
While !_AB9->(EOF())
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//Pega nome
	cNomeEqp := Posicione("AA1",1,xFilial("AA1")+_AB9->AB9_CODTEC,"AA1_NOMTEC")
	
	Do Case 
		//80 Colunas
		Case aReturn[4] == 1

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Impressao do cabecalho do relatorio. . .                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 5
			Endif
			
			//CALCULA O INDICE DAS FUNCOES PARA CADA ATENDIMENTO
			fSTC001(2)
			
			//CALCULA A QUANTIDADE DE USS DO ATENDIMENTO
			fSTC001(3)
			
			//Cabecalo da Equipe
			If cChave1 <> _AB9->(AB9_CODTEC)
					If nLin > 5 
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 5
					Endif
				
				nLin := nLin + 1
				
				//Imprime informacoes da Equipe
				nLin := fSTC002(nLin)
		        
				//Imprime o cabecalho do Atendimento de OS
				nLin := fSTC003(nLin,1)
			
				cChave1 := _AB9->(AB9_CODTEC)
			Endif
			
			//Calculo das horas
			fSTC006()
			
			//Imprime informacoes dos Atendimentos de OS				
			nLin := fSTC007(nLin)
			
			_AB9->(DbSkip()) // Avanca o ponteiro do registro no arquivo
		    
			//Imprime Totais da Equipe
			If cChave1 <> _AB9->(AB9_CODTEC)
				//Imprime o total
				nLin := fSTC008(nLin,"Total da Equipe",nTotal1,nTotal2,nTotal3)
				
				//Zera totais
				nTotal1  := 0
				nTotal2  := 0
				nTotal3  := 0
			Endif
	Otherwise
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		
		//CALCULA O INDICE DAS FUNCOES PARA CADA ATENDIMENTO
		fSTC001(2)
		
		//CALCULA A QUANTIDADE DE USS DO ATENDIMENTO
		fSTC001(3)
		
		//Cabecalo da Equipe
		If cChave1 <> _AB9->(AB9_CODTEC)

			nLin := nLin + 1
			
			cChave1 := _AB9->(AB9_CODTEC)
		Endif
		
		//Calculo das horas
		fSTC006()
		
		//Imprime informacoes dos Atendimentos de OS				
		nLin := fSTC009(nLin)
		
		_AB9->(DbSkip()) // Avanca o ponteiro do registro no arquivo
	    
		//Imprime Totais da Equipe
		If cChave1 <> _AB9->(AB9_CODTEC)
			//Imprime o total
			nLin := fSTC010(nLin,cNomeEqp,nTotal1,nTotal2,nTotal3)
			
			//Zera totais
			nTotal1  := 0
			nTotal2  := 0
			nTotal3  := 0
		Endif		
	EndCase
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC001   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cria arquivo temporario com os dados a serem impressos no  บฑฑ
ฑฑบ          ณ relatorio.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC001(nOpc)

Local cSQL := ""
Local cAB9 := RetSQLName("AB9") + " AB9 "
Local cABC := RetSQLName("ABC") + " ABC "
Local cDA1 := RetSQLName("DA1") + " DA1 "
Local cAA1 := RetSQLName("AA1") + " AA1 "
Local cAA5 := RetSQLName("AA5") + " AA5 "
Local cZZ5 := RetSQLName("ZZ5") + " ZZ5 "
Local cSRJ := RetSQLName("SRJ") + " SRJ "

Do Case
	
	//SELECIONA OS ATENDIMENTOS A SEREM IMPRESSOS
	Case nOpc == 1
		
		cSQL := " SELECT  " 
		
		cSQL += " AB9.AB9_CODTEC " 
		cSQL += " , AB9.AB9_NUMOS " 
		cSQL += " , AB9.AB9_SEQ " 
		cSQL += " , AB9.AB9_DTCHEG " 
		cSQL += " , AB9.AB9_HRSAID " 
		cSQL += " , AB9.AB9_HRCHEG " 
		cSQL += " , AB9.AB9_YFINT " 
		cSQL += " , AB9.AB9_YIINT " 
		
		cSQL += " FROM " + cAB9 + " " 
		
		cSQL += " WHERE " 
		
		cSQL += "     AB9.D_E_L_E_T_ = '' " 
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' "
		cSQL += " AND AB9.AB9_CODTEC BETWEEN '" + cEqpDe + "' AND '" + cEqpAte + "' "
		cSQL += " AND AB9.AB9_NUMOS  BETWEEN '" + cOSDe  + "' AND '" + cOSAte  + "'  " 
		cSQL += " AND AB9.AB9_SEQ    BETWEEN '" + cSeqDe + "' AND '" + cSeqAte + "'  " 
		cSQL += " AND AB9.AB9_DTINI  BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " ORDER BY AB9.AB9_FILIAL,AB9.AB9_CODTEC,AB9.AB9_NUMOS,AB9.AB9_SEQ " 
		
		//Log de controle
		Memowrite('\STCR003-1.TXT',cSQL)

		//Verifica se alias estแ em uso
		If chkfile("_AB9")
			DbselectArea("_AB9")
			DbCloseArea()
		End If

		//Cria query
		TcQuery cSQL New Alias "_AB9" 
	
	//CALCULA O INDICE DAS FUNCOES PARA CADA ATENDIMENTO
	Case nOpc == 2
		
		cSQL := " SELECT  " 

		cSQL += " SUM(SRJ.RJ_YMETA) META_FUNCAO " 
		
		cSQL += " FROM " + cZZ5 + " " 
		
		cSQL += " INNER JOIN " + cAB9 + " ON " 
		
		cSQL += "     AB9.D_E_L_E_T_ = '' " 
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' " 
		cSQL += " AND ZZ5.ZZ5_NUMOS  = AB9.AB9_NUMOS " 
		cSQL += " AND ZZ5.ZZ5_EQUIPE = AB9.AB9_CODTEC " 
		cSQL += " AND ZZ5.ZZ5_SEQ    = AB9.AB9_SEQ " 
		cSQL += " AND AB9.AB9_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND AB9.AB9_CODTEC = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND AB9.AB9_SEQ    = '" + _AB9->AB9_SEQ    + "' "
		
		cSQL += " INNER JOIN " + cAA1 + " ON " 
		
		cSQL += "     AA1.D_E_L_E_T_ = '' "
		cSQL += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' " 
		cSQL += " AND AA1.AA1_CODTEC = ZZ5.ZZ5_CODTEC " 
		
		cSQL += " INNER JOIN " + cSRJ + " ON " 
		
		cSQL += "     SRJ.D_E_L_E_T_ = '' " 
		cSQL += " AND SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "' "
		cSQL += " AND SRJ.RJ_FUNCAO  = AA1.AA1_FUNCAO " 
		
		cSQL += " WHERE  " 
		
		cSQL += "     ZZ5.D_E_L_E_T_ = '' " 
		cSQL += " AND ZZ5.ZZ5_FILIAL = '" + xFilial("ZZ5") + "' "
		cSQL += " AND ZZ5.ZZ5_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND ZZ5.ZZ5_EQUIPE = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND ZZ5.ZZ5_SEQ    = '" + _AB9->AB9_SEQ    + "' "
		
		//Log de controle
		Memowrite('\STCR003-2.TXT',cSQL)

		//Verifica se alias estแ em uso
		If chkfile("_SRJ")
			DbselectArea("_SRJ")
			DbCloseArea()
		End If

		//Cria query
		TcQuery cSQL New Alias "_SRJ" 

	//CALCULA A QUANTIDADE DE USS DO ATENDIMENTO	
	Case nOpc == 3
		
		cSQL := " SELECT  " 
		
		cSQL += " SUM(ABC.ABC_QUANT*DA1.DA1_YQUSS*(AA5_PRCCLI/100)) USS_ATEND "
		
		cSQL += " FROM " + cABC + " " 
		
		cSQL += " INNER JOIN " + cAB9 + " ON " 
		
		cSQL += "     AB9.D_E_L_E_T_ = '' "
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' " 
		cSQL += " AND ABC.ABC_FILIAL = AB9.AB9_FILIAL " 
		cSQL += " AND ABC.ABC_NUMOS  = AB9.AB9_NUMOS " 
		cSQL += " AND ABC.ABC_CODTEC = AB9.AB9_CODTEC " 
		cSQL += " AND ABC.ABC_SEQ    = AB9.AB9_SEQ " 
		cSQL += " AND AB9.AB9_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND AB9.AB9_CODTEC = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND AB9.AB9_SEQ    = '" + _AB9->AB9_SEQ    + "' "
		
		cSQL += " LEFT OUTER JOIN " + cDA1 + "   ON  " 
		
		cSQL += "     DA1.D_E_L_E_T_ = '' "
		cSQL += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "  
		cSQL += " AND ABC.ABC_YTABPR = DA1.DA1_CODTAB  	   " 
		cSQL += " AND ABC.ABC_CODPRO = DA1.DA1_CODPRO   " 
		
		cSQL += " LEFT OUTER JOIN " + cAA5 + " ON " 
		
		cSQL += "     AA5.D_E_L_E_T_ = '' " 
		cSQL += " AND AA5.AA5_FILIAL = '" + xFilial("AA5") + "' " 
		cSQL += " AND ABC.ABC_CODSER = AA5.AA5_CODSER   " 
		
		cSQL += " WHERE " 
		
		cSQL += " ABC.D_E_L_E_T_ = '' "                 
		cSQL += " AND ABC.ABC_FILIAL = '" + xFilial("ABC") + "' " 
		cSQL += " AND ABC.ABC_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND ABC.ABC_CODTEC = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND ABC.ABC_SEQ    = '" + _AB9->AB9_SEQ    + "' "	

		//Log de controle
		Memowrite('\STCR003-3.TXT',cSQL)

		//Verifica se alias estแ em uso
		If chkfile("_ABC")
			DbselectArea("_ABC")
			DbCloseArea()
		End If

		//Cria query
		TcQuery cSQL New Alias "_ABC"
EndCase	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC002   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime o cabecalho do cliente                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC002(nLin)
                                               
@nLin,000 PSAY "Equipe: "
@nLin,010 PSAY _AB9->AB9_CODTEC
@nLin,020 PSAY "Nome: "
@nLin,030 PSAY cNomeEqp

nLin := nLin + 1  

@nLin,000 PSAY "Data: "
@nLin,010 PSAY DTOC(MV_PAR07) + " ate " + DTOC(MV_PAR08)
@nLin,040 PSAY "OS: "
@nLin,045 PSAY cOSDe+"."+cSeqDe + " ate " + cOSAte+"."+cSeqAte 

nLin := nLin + 1 

Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC003   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime cabecalho dos itnes                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC003(nLin,nOpc)

Local cCab1 := ""
Local cCab2 := ""

Do Case
	Case nOpc == 1
	 	cCab1 := "________________________________________________________________________________"
	 	cCab2 := "Atendimento  Data      Horas      USS Atd.  Ind. Func.    Esperado       Indice"
EndCase

nLin := nLin +1

@nLin,000 PSAY cCab2 + Space(limite-Len(cCab2)-1) //+ "|"

nLin := nLin +1

@nLin,000 PSAY cCab1 

nLin := nLin +1
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC006   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Calcula Totais do Relatorio                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC006()

//Horas de intervalo
nHrInter  := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YIINT,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YFINT) 

//Horas de atendimento
nHrAtend := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRCHEG,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRSAID) - nHrInter

//Quantidade USS do Atendimento
nUSSAten := NoRound(_ABC->USS_ATEND,2)

//Indice das Funcoes
nIndFunc := NoRound(_SRJ->META_FUNCAO,2)

//Produtividade Esperada
nProdEsp := NoRound((nHrAtend*nIndFunc),2)

//Indice de Produtividade
nIndProd := NoRound((nUSSAten/nProdEsp),2)

//Totais da Equipe
nTotal1 += nUSSAten 
nTotal2 += nProdEsp 
nTotal3 += nIndProd

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC007   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime itens das despesas                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC007(nLin)

@nLin,000 PSAY _AB9->AB9_NUMOS+"."+_AB9->AB9_SEQ                       
@nLin,013 PSAY STOD(_AB9->AB9_DTCHEG)                       
@nLin,023 PSAY Padl(Transform(nHrAtend,"@E 99.99"),5)                      
@nLin,030 PSAY Padl(Transform(nUSSAten,"@E 9,999,999.99"),12)
@nLin,044 PSAY Padl(Transform(nIndFunc,"@E 999,999.99"),10)
@nLin,056 PSAY Padl(Transform(nProdEsp,"@E 999,999.99"),10)
@nLin,069 PSAY Padl(Transform(nIndProd,"@E 999,999.99"),10)

nLin := nLin + 1
Return nLin               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC008   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Totais do relatorio                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC008(nLin,cTotal,n1,n2,n3)

nLin := nLin +1

@nLin,011 PSAY cTotal                     
@nLin,030 PSAY Padl(Transform(n1,"@E 9,999,999.99"),12)
@nLin,056 PSAY Padl(Transform(n2,"@E 999,999.99"),10)
@nLin,069 PSAY Padl(Transform(NoRound((n1/n2),2),"@E 999,999.99"),10)

nLin := nLin +1
nLin := nLin +1
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC009   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime itens das despesas                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC009(nLin)

@nLin,000 PSAY _AB9->AB9_CODTEC
@nLin,008 PSAY cNomeEqp
@nLin,050 PSAY _AB9->AB9_NUMOS
@nLin,062 PSAY _AB9->AB9_SEQ                       
@nLin,068 PSAY STOD(_AB9->AB9_DTCHEG)                       
@nLin,078 PSAY Padl(Transform(nHrAtend,"@E 99.99"),5)                      
@nLin,086 PSAY Padl(Transform(nUSSAten,"@E 9,999,999.99"),12)
@nLin,102 PSAY Padl(Transform(nIndFunc,"@E 999,999.99"),10)
@nLin,114 PSAY Padl(Transform(nProdEsp,"@E 999,999.99"),10)
@nLin,127 PSAY Padl(Transform(nIndProd,"@E 999,999.99"),10)

nLin := nLin + 1
Return nLin 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC010   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Totais do relatorio                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC010(nLin,cTotal,n1,n2,n3)

nLin := nLin +1

@nLin,000 PSAY cTotal                     
@nLin,086 PSAY Padl(Transform(n1,"@E 9,999,999.99"),12)
@nLin,114 PSAY Padl(Transform(n2,"@E 999,999.99"),10)
@nLin,128 PSAY Padl(Transform(NoRound((n1/n2),2),"@E 999,999.99"),10)

nLin := nLin +1
Return nLin                