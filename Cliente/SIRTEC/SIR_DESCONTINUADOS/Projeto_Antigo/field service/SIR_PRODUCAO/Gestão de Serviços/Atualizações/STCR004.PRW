#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSTCR004   บ Autor ณ Microsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Indice Task Time                              บฑฑ
ฑฑบ          ณ (conceito Hora de Intervalo e Equipe x Tecnico)            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sirtec - Field Service                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function STCR004

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2    := "de acordo com os parametros informados pelo usuario."
Local cDesc3    := "Indice Task Time"                  
Local cPict     := ""
Local titulo    := "Indice Task Time"                 
Local nLin         := 80

Local Cabec1    := ""                                      	
Local Cabec2    := ""
Local imprime   := .T.
Local aOrd 		:= {"Codigo"}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "STCR004" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := padr("STCR04", 10 , " ")   //padr("STCR04", LEN(SX1->X1_GRUPO), " ") 
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "STCR004" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "AB9"  

//Variaveis de controle do relatorio
Private nTipo
Private cCodDe  
Private cCodAte   
Private cDatDe  
Private cDatAte                     
Private cChave1  := ""
Private nHrInter := 0 
Private nJornada := 0 
Private nServico := 0 
Private nIndice  := 0 
Private nTotal1  := 0 
Private nTotal2  := 0
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
nTipo   := MV_PAR01
cCodDe  := MV_PAR02
cCodAte := MV_PAR03
cDatDe  := DTOS(MV_PAR04)
cDatAte := DTOS(MV_PAR05)

//Ajusta cabecalho do relatorio
If aReturn[4] == 1
	Cabec1    := ""                                      	
	Cabec2    := ""
	Tamanho   := "P"
Else             
	Cabec1    := "Codigo  Nome                                      Atendimento Seq  Data      Jornada   Hr Servico         Indice"
	Cabec2    := ""
	Tamanho   := "G"
Endif

//Monta dados do reltorio
fSTC001()

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
				nLin := fSTC008(nLin,"Total",nTotal1,nTotal2,NoRound((nTotal2/nTotal1),2))
				
				//Zera totais
				nTotal1  := 0
				nTotal2  := 0
			Endif
		
		//220 Colunas
		Otherwise
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Impressao do cabecalho do relatorio. . .                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif
			
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
				nLin := fSTC010(nLin,cNomeEqp,nTotal1,nTotal2,NoRound((nTotal2/nTotal1),2))
				
				//Zera totais
				nTotal1  := 0
				nTotal2  := 0
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
Static Function fSTC001

Local cSQL := ""
Local cAB9 := RetSQLName("AB9") + " AB9 "
Local cAA1 := RetSQLName("AA1") + " AA1 "
Local cZZ5 := RetSQLName("ZZ5") + " ZZ5 "

Do Case
	
	//SELECIONA OS ATENDIMENTOS POR EQUIPE       
	Case nTipo == 1
		
		cSQL := " SELECT  " 
		
		cSQL += " AB9.AB9_CODTEC " 
		cSQL += " , AB9.AB9_NUMOS " 
		cSQL += " , AB9.AB9_SEQ " 
		cSQL += " , AB9.AB9_DTCHEG " 
		cSQL += " , AB9.AB9_HRSAID " 
		cSQL += " , AB9.AB9_HRCHEG " 
		cSQL += " , AB9.AB9_YFINT " 
		cSQL += " , AB9.AB9_YIINT " 
		cSQL += " , AB9.AB9_HRINI " 
		cSQL += " , AB9.AB9_HRFIM " 
		
		cSQL += " FROM " + cAB9 + " "
		
		cSQL += " INNER JOIN " + cAA1 + " ON "
		
		cSQL += "     AA1.D_E_L_E_T_ = '' "
		cSQL += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
		cSQL += " AND AA1.AA1_CODTEC = AB9.AB9_CODTEC " 
		
		cSQL += " WHERE " 
		
		cSQL += "     AB9.D_E_L_E_T_ = '' " 
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' "
		cSQL += " AND AB9.AB9_CODTEC BETWEEN '" + cCodDe + "' AND '" + cCodAte + "' "
		cSQL += " AND AB9.AB9_DTINI  BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " ORDER BY AB9.AB9_FILIAL,AB9.AB9_CODTEC,AB9.AB9_NUMOS,AB9.AB9_SEQ " 
		
		//Log de controle
		Memowrite('\STCR004-1.TXT',cSQL)

		//Verifica se alias estแ em uso
		If chkfile("_AB9")
			DbselectArea("_AB9")
			DbCloseArea()
		End If

		//Cria query
		TcQuery cSQL New Alias "_AB9" 
	
	//SELECION OS ATENDIMENTOS POR TECNICO               
	Case nTipo == 2                  
	
		cSQL := " SELECT  " 
		
		cSQL += " ZZ5.ZZ5_CODTEC AB9_CODTEC " 
		cSQL += " , AB9.AB9_NUMOS " 
		cSQL += " , AB9.AB9_SEQ " 
		cSQL += " , AB9.AB9_DTCHEG " 
		cSQL += " , AB9.AB9_HRSAID " 
		cSQL += " , AB9.AB9_HRCHEG " 
		cSQL += " , AB9.AB9_YFINT " 
		cSQL += " , AB9.AB9_YIINT " 
		cSQL += " , AB9.AB9_HRINI " 
		cSQL += " , AB9.AB9_HRFIM " 
		
		cSQL += " FROM " + cZZ5 + " "
        
		cSQL += " INNER JOIN " + cAB9 + " ON "
	
		cSQL += "     AB9.D_E_L_E_T_ = '' " 
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' " 
		cSQL += " AND ZZ5.ZZ5_NUMOS  = AB9.AB9_NUMOS " 
		cSQL += " AND ZZ5.ZZ5_EQUIPE = AB9.AB9_CODTEC " 
		cSQL += " AND ZZ5.ZZ5_SEQ    = AB9.AB9_SEQ " 
		cSQL += " AND AB9.AB9_CODTEC BETWEEN '" + cCodDe + "' AND '" + cCodAte + "' "
		cSQL += " AND AB9.AB9_DTINI  BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " INNER JOIN " + cAA1 + " ON "

		cSQL += "     AA1.D_E_L_E_T_ = '' "
		cSQL += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
		cSQL += " AND AA1.AA1_CODTEC = ZZ5.ZZ5_CODTEC " 
		
		cSQL += " WHERE " 
		
		cSQL += "     ZZ5.D_E_L_E_T_ = '' " 
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' "
		cSQL += " AND AB9.AB9_CODTEC BETWEEN '" + cCodDe + "' AND '" + cCodAte + "' "
		cSQL += " AND AB9.AB9_DTINI  BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " ORDER BY ZZ5.ZZ5_FILIAL,ZZ5.ZZ5_CODTEC,ZZ5.ZZ5_NUMOS,ZZ5.ZZ5_SEQ " 
		
		//Log de controle
		Memowrite('\STCR004-2.TXT',cSQL)

		//Verifica se alias estแ em uso
		If chkfile("_AB9")
			DbselectArea("_AB9")
			DbCloseArea()
		End If

		//Cria query
		TcQuery cSQL New Alias "_AB9" 
		
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
@nLin,010 PSAY DTOC(MV_PAR04) + " ate " + DTOC(MV_PAR05)

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
	 	cCab2 := "Atendimento  Seq   Jornada    Horas Prod.      Indice"
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
nHrInter := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YIINT,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YFINT) 

//Horas de trabalho
nJornada := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRCHEG,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRSAID) - nHrInter

//Horas de servico
nServico := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRINI,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRFIM) - nHrInter

//Indice
nIndice  := NoRound((nServico/nJornada),2)

//Totais da Equipe
nTotal1 += nJornada 
nTotal2 += nServico 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC007   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime itens das despesas para 80 colunas                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fSTC007(nLin)

@nLin,000 PSAY _AB9->AB9_NUMOS                       
@nLin,013 PSAY _AB9->AB9_SEQ                       
@nLin,019 PSAY IntToHora(nJornada)
@nLin,030 PSAY IntToHora(nServico)
@nLin,045 PSAY Padl(Transform(nIndice,"@E 999,999.99"),10)

nLin := nLin + 1
Return nLin               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC008   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Totais do relatorio  80 colunas                            บฑฑ
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
@nLin,019 PSAY IntToHora(n1)
@nLin,030 PSAY IntToHora(n2)
@nLin,045 PSAY Padl(Transform(n3,"@E 999,999.99"),10)


nLin := nLin +1
nLin := nLin +1
Return nLin  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC009   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime itens das despesas para 220 colunas                บฑฑ
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
@nLin,067 PSAY STOD(_AB9->AB9_DTCHEG)                       
@nLin,077 PSAY IntToHora(nJornada)
@nLin,087 PSAY IntToHora(nServico)
@nLin,102 PSAY Padl(Transform(nIndice,"@E 999,999.99"),10)

nLin := nLin + 1
Return nLin 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณfSTC008   บ Autor ณ Micorsiga Vitoria  บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Totais do relatorio 220 colunas                            บฑฑ
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
@nLin,077 PSAY IntToHora(n1)
@nLin,087 PSAY IntToHora(n2)
@nLin,102 PSAY Padl(Transform(n3,"@E 999,999.99"),10)

nLin := nLin +1
Return nLin              