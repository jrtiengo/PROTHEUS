#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ JPCHrTec º Autor ³ Gerson L. Lage     º Data ³  03/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao da Lista de horas trabalhadas por tecnico        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function JPCHrTec

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de horas trabalhadas conforme parametros.          "
Local cDesc3         := "Horas Trabalhadas"
Local titulo         := "Horas Trabalhadas por Tecnico"
Local nLin           := 80					// Numero maximo de linhas
Local aOrd           := "" //{}					// Ordem selecionada
Local Cabec1         := ""

Local Cabec2         := ""					// Cabecalho 2
Local cPerg          := "HRTRBTEC"			// Pergunte que eh chamado no relatorio

Private Cabecalho    := "Etiqueta Cliente                       Dt Inicio Dt Final Hr Ini Hr Fim Total Hr"
Private lEnd         := .F.					// Controle do termino do relatorio
Private lAbortPrint  := .F.					// Controle para interrupcao do relatorio
Private limite       := 132					// Limite de colunas (caracteres)
Private tamanho      := "P"					// Tamanho do relatorio
Private nomeprog     := "HRTRBTEC"			// Nome do programa para impressao no cabecalho
Private nTipo        := 15					// Tipo do relatorio
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0					// Codigo ASCII da ultima tecla pressionada pelo usuario
Private m_pag        := 01
Private wnrel        := "HRTRBTEC"			// Nome do arquivo usado para impressao em disco
Private cString      := "AB9"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

GeraPerg( cPerg ) // Cria as perguntas
Pergunte( cPerg, .f.)
wnrel := SetPrint(	cString , NomeProg, cPerg 	, @titulo, cDesc1, cDesc2  , cDesc3	, .F. , aOrd  , .F., Tamanho )

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"AB9")

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)
Cabec1         := "Período de : "+DtoC(MV_PAR03)+" até "+DtoC(MV_PAR04)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do relatorio.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| MATRICIAL(Cabec1, "", Titulo, nLin ) } ,Titulo)

Return

Static Function MATRICIAL(Cabec1 ,Cabec2 ,Titulo,	nLin)
Local cTecAnt  := " "
Local nTHrsTec := 0
Local nTTHrsTec := 0
Local nDifHrs  := 0
Local cSql

cSql := ""
cSql += " SELECT AB9.*,AA1.AA1_NOMTEC,SA1.A1_NOME "
cSql += " FROM "+RetSqlName("AB9")+" AB9 (NOLOCK), "+RetSqlName("AA1")+" AA1 (NOLOCK), "+RetSqlName("AB6")+" AB6 (NOLOCK), "+RetSqlName("SA1")+" SA1 (NOLOCK) "
cSql += " WHERE "
cSql += "       AB9.D_E_L_E_T_ = ' ' AND "
cSql += "       AA1.D_E_L_E_T_ = ' ' AND "
cSql += "       AB6.D_E_L_E_T_ = ' ' AND "
cSql += "       SA1.D_E_L_E_T_ = ' ' AND "
cSql += "       AB9.AB9_CODTEC = AA1.AA1_CODTEC AND  "
cSql += "       AB9.AB9_FILIAL  = AB6.AB6_FILIAL  AND  "
cSql += "       LEFT(AB9.AB9_NUMOS,6)  = AB6.AB6_NUMOS  AND  "
cSql += "       AB6.AB6_CODCLI = SA1.A1_COD  AND AB6.AB6_LOJA = SA1.A1_LOJA          AND AB6.AB6_CODCLI BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cSql += "       AB6.AB6_CODCLI = AB9.AB9_CODCLI  AND AB6.AB6_LOJA = AB9.AB9_LOJA     AND "
cSql += "       AB9.AB9_CODTEC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cSql += "       AB9.AB9_DTINI  BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' "
cSql += " ORDER BY AB9_CODTEC, AB9_NUMOS "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"TMPOSREL", .F., .T.)

DbSelectArea("TMPOSREL")
DbGoTop()
While !eof()
	
	If nLin > 60
		Cabec(	Titulo	, Cabec1, "", NomeProg, Tamanho	, nTipo )
		nLin     := 8
		
		@nLin++,001 PSAY Cabecalho
		@nLin++,001 PSAY Replicate("-",len(cabecalho))
	Endif
	
/*
//           1         2         3         4         5         6         7         8         9        10        10
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Etiqueta Cliente                       Dt Inicio Dt Final Hr Ini Hr Fim Total Hr
								
								
	Cod. Técnico	000001	Nome do Tecnico:		JEAN DA COSTA			
								
	000010   JOAO DA SILVA xxxxxxxxxxxxxxxx 01/06/11 01/06/11  08:00  12:00    04:00	
	000025	 JOAO DA SILVA	                04/06/11 04/06/11  13:15  18:23    05:08	

	Total de Horas do Técnico:		9:08					
*/
	If cTecAnt <> AB9_CODTEC
		cTecAnt := AB9_CODTEC
		@nLin++,001 PSAY "Cod. Tecnico: "+TMPOSREL->AB9_CODTEC+" Nome do Tecnico: "+TMPOSREL->AA1_NOMTEC
		@nLin++,001 PSAY replicate('-',len(cabecalho))
	Endif
	@nLin,001 PSAY TMPOSREL->AB9_ETIQUE		//AB9_NUMOS 
	@nLin,010 PSAY left(TMPOSREL->A1_NOME,30)
	@nLin,041 PSAY left(DtoC(StoD(TMPOSREL->AB9_DTINI)),6)+right(DtoC(StoD(TMPOSREL->AB9_DTINI)),2)
	@nLin,050 PSAY left(DtoC(StoD(TMPOSREL->AB9_DTFIM)),6)+right(DtoC(StoD(TMPOSREL->AB9_DTFIM)),2)
	@nLin,060 PSAY TMPOSREL->AB9_HRCHEG
	@nLin,067 PSAY TMPOSREL->AB9_HRSAID

	nDifHrs := SubtHoras((StoD(TMPOSREL->AB9_DTINI)),TMPOSREL->AB9_HRCHEG,(StoD(TMPOSREL->AB9_DTFIM)),TMPOSREL->AB9_HRSAID) // Funcao em TECXFUN
	@nLin++,076 PSAY IntToHora(nDifHrs,3)
	nTHrsTec += nDifHrs
	nTTHrsTec += nDifHrs
	
	DbSelectArea("TMPOSREL")
	DbSkip()
	If cTecAnt <> AB9_CODTEC
		@nLin++,001 PSAY Replicate("-",len(cabecalho))
		@nLin++,001 PSAY "Total de horas do tecnico: "+IntToHora(nTHrsTec,5)
		nTHrsTec := 0
		nLin++
	Endif
	
Enddo
If nTTHrsTec <> 0
	@nLin++,001 PSAY Replicate("-",len(cabecalho))
	@nLin++,001 PSAY "Somatoria total de horas: "+IntToHora(nTTHrsTec,5)
Endif
DbSelectArea("TMPOSREL")
DbCloseArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descarrega o Cache armazenado na memoria para a impressora.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MS_FLUSH()

Return(.t.)

// Cria as perguntas

Static Function GeraPerg( cPerg )	   

	PutSx1( cPerg, "01","Do tecnico"       ,"Do tecnico"       ,"Do tecnico"       ,"mv_ch1","C",TamSX3("AB9_CODTEC")[1],TamSX3("AB9_CODTEC")[2],0,"G","","AA1","","","mv_par01"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "02","Ate o tecnico"    ,"Ate o tecnico"    ,"Ate o tecnico"    ,"mv_ch2","C",TamSX3("AB9_CODTEC")[1],TamSX3("AB9_CODTEC")[2],0,"G","","AA1","","","mv_par02"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "03","Periodo de"       ,"Periodo de"       ,"Periodo de"       ,"mv_ch3","D",TamSX3("AB9_DTINI")[1] ,TamSX3("AB9_DTINI")[2] ,0,"G","","","","","mv_par03"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "04","Periodo ate"      ,"Periodo ate"      ,"Periodo ate"      ,"mv_ch4","D",TamSX3("AB9_DTINI")[1] ,TamSX3("AB9_DTINI")[2] ,0,"G","","","","","mv_par04"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "05","Cliente de"       ,"Cliente de"       ,"Cliente de"       ,"mv_ch5","C",TamSX3("AB6_CODCLI")[1],TamSX3("AB6_CODCLI")[2],0,"G","","SA1","","","mv_par05"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "06","Cliente ate"      ,"Cliente ate"      ,"Cliente ate"      ,"mv_ch6","C",TamSX3("AB6_CODCLI")[1],TamSX3("AB6_CODCLI")[2],0,"G","","SA1","","","mv_par06"," ","","","","","","","","","","","","","","","")

Return()

