#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STCR007   º Autor ³ Microsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relação de Materiais por Endereço                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sirtec - Field Service                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function STCR007


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2    := "de acordo com os parametros informados pelo usuario."
Local cDesc3    := "Relação de Materiais por Endereço"
Local cPict     := ""
Local titulo    := "Relação de Materiais por Endereço"
Local nLin      := 80

Local Cabec1    := "Armazem Endereço                                           Centro de Custo                                   Produto                                                      Quant.Ideal   Quant.Real     Diferença"
Local Cabec2    := ""
Local imprime   := .T.
Local aOrd 		:= {"Endereço","Centro de Custo","Produto"}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "STCR007" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := padr("STCR07", 10 , " ")   //padr("STCR07", LEN(SX1->X1_GRUPO), " ") 
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "STCR007" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nOrdem       := 0

Private cString := "SBF"

//Variaveis de Controle do relatorio
Private cChave  := ''
Private cDeLocal:= ''
Private cAtLocal:= ''
Private cDeEnd  := ''
Private cAtEnd  := ''
Private cDeProd := ''
Private cAtProd := ''
Private cDeCent := ''
Private cAtCent := ''

DbSelectArea("SBF")
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

Local cOrdem := ''

/*/
+------------+-----------------------------+
| Parametro  | Descricao                   |
+============+=============================+
| MV_PAR01   |De Armazem                   |
| MV_PAR02   |Ate Armazem                  |
| MV_PAR03   |De Endereço                  |
| MV_PAR04   |Ate Endereço                 |
| MV_PAR05   |De Produto                   |
| MV_PAR06   |Ate Produto                  |
| MV_PAR07   |De Centro de Custo           |
| MV_PAR08   |Ate Centro de Custo          |
+------------+-----------------------------+
/*/

cDeLocal := MV_PAR01
cAtLocal := MV_PAR02
cDeEnd   := MV_PAR03
cAtEnd   := MV_PAR04
cDeProd  := MV_PAR05
cAtProd  := MV_PAR06
cDeCent  := MV_PAR07
cAtCent  := MV_PAR08                                

nOrdem  := aReturn[8]

Do Case 
	Case nOrdem == 1
		cOrdem := 'ARQ1->ZZ8_LOCAL+ARQ1->ZZ8_END'
	Case nOrdem == 2
		cOrdem := 'ARQ1->CTT_CUSTO'
	Case nOrdem == 3
		cOrdem := 'ARQ1->ZZ8_PRODUTO'
EndCase

//Monta arquivo temporario com os dados do relatorio                   
fSTC001()

cString := "ARQ1"

DbSelectArea(cString)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

ARQ1->(DbGoTop())
While !ARQ1->(EOF())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	nLin := nLin + 1 // Avanca a linha de impressao
	
	//Verifica chave do relatorio
	If cChave <> &cOrdem
		
		//Imprime o cabecalho do tecnico                                       
		nLin := fSTC002(nLin)
		
		cChave := &cOrdem
	Endif
	
	//Calcula totais do relatorio                                          
	//fSTC005()
	
	//Imprime itens                                                        
	nLin := fSTC003(nLin)
	
	ARQ1->(DbSkip()) // Avanca o ponteiro do registro no arquivo
	
	/*
    //Impressao dos totais
	If cChave <> _AB9->ZZ5_CODTEC
		//Imprime totais
		nLin := fSTC004(nLin)
	Endif
	*/
	
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


cSQL := " SELECT                                                                                                                           " + CRLF
cSQL += "   ZZ8.ZZ8_LOCAL                                                                                                                  " + CRLF
cSQL += "  ,ZZ8.ZZ8_END                                                                                                                    " + CRLF
cSQL += "  ,SBE.BE_DESCRIC                                                                                                                 " + CRLF
cSQL += "  ,CTT.CTT_CUSTO                                                                                                                  " + CRLF
cSQL += "  ,CTT.CTT_DESC01                                                                                                                 " + CRLF
cSQL += "  ,ZZ8.ZZ8_PRODUT                                                                                                                 " + CRLF
cSQL += "  ,SB1.B1_DESC                                                                                                                    " + CRLF
cSQL += "  ,SBF.BF_QUANT                                                                                                                   " + CRLF
cSQL += "  ,CASE                                                                                                                           " + CRLF
cSQL += "  		WHEN SBF.BF_QUANT IS NULL THEN 0                                                                                           " + CRLF
cSQL += "  		ELSE SBF.BF_QUANT                                                                                                          " + CRLF  
cSQL += "   END AS BF_QUANT                                                                                                                " + CRLF
cSQL += "  ,ZZ8.ZZ8_QUANT                                                                                                                  " + CRLF
cSQL += " FROM !ZZ8! ZZ8                                                                                                                   " + CRLF
cSQL += " LEFT OUTER JOIN !SBE! SBE ON                                                                                                     " + CRLF
cSQL += "      SBE.D_E_L_E_T_ = ''                                                                                                         " + CRLF
cSQL += "  AND SBE.BE_FILIAL  = !SBE.FILIAL!                                                                                               " + CRLF
cSQL += "  AND ZZ8.ZZ8_LOCAL  = SBE.BE_LOCAL                                                                                               " + CRLF
cSQL += "  AND ZZ8.ZZ8_END    = SBE.BE_LOCALIZ                                                                                             " + CRLF
cSQL += " LEFT OUTER JOIN !SBF! SBF ON                                                                                                     " + CRLF
cSQL += "      SBF.D_E_L_E_T_ = ''                                                                                                         " + CRLF
cSQL += "  AND SBF.BF_FILIAL  = !SBF.FILIAL!                                                                                               " + CRLF
cSQL += "  AND ZZ8.ZZ8_LOCAL  = SBF.BF_LOCAL                                                                                               " + CRLF
cSQL += "  AND ZZ8.ZZ8_END    = SBF.BF_LOCALIZ                                                                                             " + CRLF
cSQL += "  AND ZZ8.ZZ8_PRODUT = SBF.BF_PRODUTO                                                                                             " + CRLF
cSQL += " LEFT OUTER JOIN !SB1! SB1 ON                                                                                                     " + CRLF
cSQL += "      SB1.D_E_L_E_T_ = ''                                                                                                         " + CRLF
cSQL += "  AND SB1.B1_FILIAL  = !SB1.FILIAL!                                                                                               " + CRLF
cSQL += "  AND SB1.B1_COD     = ZZ8.ZZ8_PRODUT                                                                                             " + CRLF
cSQL += " LEFT OUTER JOIN !SRA! SRA ON                                                                                                     " + CRLF
cSQL += "      SRA.D_E_L_E_T_ = ''                                                                                                         " + CRLF
cSQL += "  AND SRA.RA_FILIAL  = !SRA.FILIAL!                                                                                               " + CRLF
cSQL += "  AND SRA.RA_MAT     = SUBSTRING(ZZ8.ZZ8_END,3,6)                                                                                 " + CRLF
cSQL += " LEFT OUTER JOIN !CTT! CTT ON                                                                                                     " + CRLF
cSQL += "      CTT.D_E_L_E_T_ = ''                                                                                                         " + CRLF
cSQL += "  AND CTT.CTT_FILIAL = !CTT.FILIAL!                                                                                               " + CRLF
cSQL += "  AND CTT.CTT_CUSTO  = SRA.RA_CC                                                                                                  " + CRLF
cSQL += " WHERE                                                                                                                            " + CRLF
cSQL += "      ZZ8.D_E_L_E_T_ = ''                                                                                                         " + CRLF
cSQL += "  AND ZZ8.ZZ8_FILIAL  = !ZZ8.FILIAL!                                                                                              " + CRLF
cSQL += "  AND ZZ8.ZZ8_LOCAL   BETWEEN !DE_LOCAL!        AND !ATE_LOCAL!                                                                   " + CRLF
cSQL += "  AND ZZ8.ZZ8_END     BETWEEN !DE_ENDERECO!     AND !ATE_ENDERECO!                                                                " + CRLF
cSQL += "  AND ZZ8.ZZ8_PRODUT  BETWEEN !DE_PRODUTO!      AND !ATE_PRODUTO!                                                                 " + CRLF
cSQL += "  AND CTT.CTT_CUSTO   BETWEEN !DE_CENTRO!       AND !ATE_CENTRO!                                                                  " + CRLF
Do Case
	Case nOrdem == 1
		cSQL += " ORDER BY ZZ8.ZZ8_FILIAL,ZZ8.ZZ8_LOCAL,ZZ8.ZZ8_END,ZZ8.ZZ8_PRODUT                             	                           " + CRLF

	Case nOrdem == 2
		cSQL += " ORDER BY CTT.CTT_FILIAL, CTT.CTT_CUSTO, ZZ8.ZZ8_FILIAL,ZZ8.ZZ8_LOCAL,ZZ8.ZZ8_END,ZZ8.ZZ8_PRODUT                          " + CRLF

	Case nOrdem == 3
		cSQL += " ORDER BY ZZ8.ZZ8_FILIAL,ZZ8.ZZ8_PRODUT,ZZ8.ZZ8_LOCAL,ZZ8.ZZ8_END                         	                               " + CRLF
EndCase

//Ajusta consulta
cSQL := StrTran(cSQL,'!SBF!'          ,RetSQLName('SBF')       )
cSQL := StrTran(cSQL,'!SBE!'          ,RetSQLName('SBE')       )
cSQL := StrTran(cSQL,'!SB1!'          ,RetSQLName('SB1')       )
cSQL := StrTran(cSQL,'!ZZ8!'          ,RetSQLName('ZZ8')       )
cSQL := StrTran(cSQL,'!SRA!'          ,RetSQLName('SRA')       )
cSQL := StrTran(cSQL,'!CTT!'          ,RetSQLName('CTT')       )
cSQL := StrTran(cSQL,'!SBF.FILIAL!'   ,ValToSQL(xFilial('SBF')))
cSQL := StrTran(cSQL,'!SBE.FILIAL!'   ,ValToSQL(xFilial('SBE')))
cSQL := StrTran(cSQL,'!SB1.FILIAL!'   ,ValToSQL(xFilial('SB1')))
cSQL := StrTran(cSQL,'!ZZ8.FILIAL!'   ,ValToSQL(xFilial('ZZ8')))
cSQL := StrTran(cSQL,'!SRA.FILIAL!'   ,ValToSQL(xFilial('SRA')))
cSQL := StrTran(cSQL,'!CTT.FILIAL!'   ,ValToSQL(xFilial('CTT')))
cSQL := StrTran(cSQL,'!DE_LOCAL!'     ,ValToSQL(cDeLocal)      )
cSQL := StrTran(cSQL,'!ATE_LOCAL!'    ,ValToSQL(cAtLocal)      )
cSQL := StrTran(cSQL,'!DE_ENDERECO!'  ,ValToSQL(cDeEnd)        )
cSQL := StrTran(cSQL,'!ATE_ENDERECO!' ,ValToSQL(cAtEnd)        )
cSQL := StrTran(cSQL,'!DE_PRODUTO!'   ,ValToSQL(cDeProd)       )
cSQL := StrTran(cSQL,'!ATE_PRODUTO!'  ,ValToSQL(cAtProd)       )
cSQL := StrTran(cSQL,'!DE_CENTRO!'    ,ValToSQL(cDeCent)       )
cSQL := StrTran(cSQL,'!ATE_CENTRO!'   ,ValToSQL(cAtCent)       )

//Log de controle
Memowrite('\STCR007-1.TXT',cSQL)

//Verifica se alias está em uso
If chkfile("ARQ1")
	DbselectArea("ARQ1")
	DbCloseArea()
End If

//Cria query
TcQuery cSQL New Alias "ARQ1"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC002   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime o cabecalho do tecnico                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FSTC002(nLin)

nLin := nLin + 1

Do Case
	Case nOrdem == 1
	                                               
		@nLin,00 PSAY "Localização: " + ARQ1->ZZ8_LOCAL + Space(1) + ARQ1->ZZ8_END
        
	Case nOrdem == 2
	                                               
		@nLin,00 PSAY "Centro de Custo: " + ARQ1->CTT_CUSTO + Space(1) + ARQ1->CTT_DESC01

	Case nOrdem == 3
	                                               
		@nLin,00 PSAY "Produto: " + ARQ1->ZZ8_PRODUT
EndCase
        
nLin := nLin + 1
nLin := nLin + 1

Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC003   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime os itens do relatorio                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FSTC003(nLin)

@nLin,00  PSAY ARQ1->ZZ8_LOCAL
@nLin,08  PSAY ARQ1->ZZ8_END + " - " + ARQ1->BE_DESCRIC   
@nLin,58  PSAY ARQ1->CTT_CUSTO + " - " + ARQ1->CTT_DESC01
@nLin,110 PSAY ARQ1->ZZ8_PRODUT + " - " + ARQ1->B1_DESC
@nLin,170 PSAY Transform(ARQ1->ZZ8_QUANT,"@E 999,999.99")
@nLin,185 PSAY Transform(ARQ1->BF_QUANT,"@E 999,999.99")
@nLin,200 PSAY Transform((ARQ1->BF_QUANT - ARQ1->ZZ8_QUANT),"@E 999,999.99")

//nLin := nLin +1

Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC004   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime os itens do relatorio                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function FSTC004(nLin)

nLin := nLin +1

@nLin,00  PSAY "Totais"
@nLin,87  PSAY IntToHora(nTotal1)
@nLin,98  PSAY IntToHora(nTotal2)   
@nLin,142 PSAY IntToHora(nTotal3)

nLin := nLin +1
nLin := nLin +1

Return nLin  
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC005   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Calcula Totais do Relatorio                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function FSTC005

//nRet := IntToHora(HoraToInt(M->AB9_TOTFAT) - SubtHoras(M->AB9_DTINI,M->AB9_YIINT,M->AB9_DTINI,M->AB9_YFINT))     

nHoras1 := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YIINT,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YFINT) 
nHoras2 := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRCHEG,STOD(_AB9->AB9_DTSAID),_AB9->AB9_HRSAID) - nHoras1
nHoras3 := SubtHoras(STOD(_AB9->AB9_DTINI),_AB9->AB9_HRINI,STOD(_AB9->AB9_DTFIM),_AB9->AB9_HRFIM) - nHoras1

nTotal1 += nHoras1
nTotal2 += nHoras2
nTotal3 += nHoras3
Return
*/