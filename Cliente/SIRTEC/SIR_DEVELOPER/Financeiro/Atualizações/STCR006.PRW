#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STCR006   º Autor ³ Microsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para ajuste dos titulos provisorios                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sirtec - Financeiro                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function STCR006


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1	:= "Este programa tem como objetivo processar os titulos"
Local cDesc2    := "de acordo com os parametros informdos pelo usuario. "
Local cDesc3    := "Ajuste de titulos provisorios"
Local cPict     := ""
Local titulo    := "Ajuste de titulos provisorios"
Local nLin      := 80

Local Cabec1    := "Natureza                                       Prefixo   Numero     Parcela   Tipo   Codigo   Loja   Data Emissao    Data Vencimento             Valor"
Local Cabec2    := ""
Local imprime   := .T.
Local aOrd 		:= {"Natureza"}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "STCR006" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "STCR05"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "STCR006" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""
Private aTitulos := {}
Private aOrigem  := {}
Private nValor := nSaldo := 0

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
| MV_PAR01   |Tipo: 1-Rec / 2-Pag          |
| MV_PAR02   |Data de                      |
| MV_PAR03   |Data ate                     |
+------------+-----------------------------+
/*/

nOpc     := MV_PAR01
cDatDe   := DTOS(MV_PAR02)
cDatAte  := DTOS(MV_PAR03)

//Monta arquivo temporario com os dados do relatorio                   
fSTC001()

cString := "_TMP"

DbSelectArea(cString)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

_TMP->(DbGoTop())
While !_TMP->(EOF())
	
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
	
	//Imprime itens
	nLin := fSTC002(nLin)
	
	//Seleciona titulos normais
	fSTC004()
	nValor := 0
	
	_TRB->(DbGoTop())
	While ! _TRB->(EOF())
	
		//Imprime itens
		nLin := fSTC005(nLin)
		
		//Controle dos titulos
		nValor += _TRB->VALOR
		
		AADD(aOrigem,{_TRB->PREFIXO,_TRB->NUMERO,_TRB->PARCELA,_TRB->TIPO,_TRB->CODIGO,_TRB->LOJA,_TRB->VALOR})
		
		_TRB->(Dbskip())
	EndDo
	
	nSaldo := (_TMP->VALOR - nValor)
	nSaldo := If( nSaldo < 0,0,nSaldo)
	
	//Controle dos tiulos
	AADD(aTitulos,{_TMP->PREFIXO,_TMP->NUMERO,_TMP->PARCELA,_TMP->TIPO,_TMP->CODIGO,_TMP->LOJA,nSaldo})
	
	_TMP->(DbSkip())

	nLin := nLin + 1
		
	@ nLin,000 PSAY "Novo saldo:" + Padl(Transform(nSaldo,"@E 999,999,999.99"),14)
	
	nLin := nLin + 1
	nLin := nLin + 1
	
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

fSTC003()

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
Local cSED := RetSQLName("SED") + " SED "
Local cSE1 := RetSQLName("SE1") + " SE1 "
Local cSE2 := RetSQLName("SE2") + " SE2 "

Do Case
	Case nOpc == 1
		
		cSQL := " SELECT  "
		
		cSQL += " SE1.E1_PREFIXO PREFIXO "
		cSQL += ",SE1.E1_NUM NUMERO "
		cSQL += ",SE1.E1_PARCELA PARCELA "
		cSQL += ",SE1.E1_TIPO TIPO "
		cSQL += ",SE1.E1_CLIENTE CODIGO "
		cSQL += ",SE1.E1_LOJA LOJA "
		cSQL += ",SE1.E1_VENCTO VENCIMENTO "
		cSQL += ",SE1.E1_EMISSAO EMISSAO "
		cSQL += ",SE1.E1_VALOR VALOR "
		cSQL += ",SE1.E1_NATUREZ NATUREZA "
		cSQL += ",SED.ED_DESCRIC DESCRICAO " 
		
		cSQL += " FROM " + cSE1 + " "
		
		cSQL += " INNER JOIN " + cSED + " ON "
		
		cSQL += " SED.D_E_L_E_T_ = '' " 
		cSQL += " AND SED.ED_FILIAL = '" + xFilial("SEE") + "' " 
		cSQL += " AND SED.ED_CODIGO = SE1.E1_NATUREZ " 
		
		cSQL += " WHERE "
		cSQL += " SE1.D_E_L_E_T_ = '' "
		cSQL += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
		cSQL += " AND SE1.E1_TIPO   = 'PR ' "
		cSQL += " AND SE1.E1_VENCTO BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " ORDER BY SE1.E1_FILIAL,SE1.E1_NATUREZ,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_CLIENTE,SE1.E1_LOJA"
		
		//Log de controle
		Memowrite('\STCR006-1.TXT',cSQL)
		
	Case nOpc == 2
		
		cSQL := " SELECT  "
		
		cSQL += " SE2.E2_PREFIXO PREFIXO"
		cSQL += ",SE2.E2_NUM NUMERO"
		cSQL += ",SE2.E2_PARCELA PARCELA"
		cSQL += ",SE2.E2_TIPO TIPO"
		cSQL += ",SE2.E2_FORNECE CODIGO"
		cSQL += ",SE2.E2_LOJA LOJA"
		cSQL += ",SE2.E2_VENCTO VENCIMENTO"
		cSQL += ",SE2.E2_EMISSAO EMISSAO"
		cSQL += ",SE2.E2_VALOR VALOR"
		cSQL += ",SE2.E2_NATUREZ NATUREZA"
		cSQL += ",SED.ED_DESCRIC DESCRICAO" 
		
		cSQL += " FROM " + cSE2 + " "
		
		cSQL += " INNER JOIN " + cSED + " ON "
		
		cSQL += " SED.D_E_L_E_T_ = '' " 
		cSQL += " AND SED.ED_FILIAL = '" + xFilial("SEE") + "' " 
		cSQL += " AND SED.ED_CODIGO = SE2.E2_NATUREZ " 
		
		cSQL += " WHERE "
		cSQL += " SE2.D_E_L_E_T_ = '' "
		cSQL += " AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
		cSQL += " AND SE2.E2_TIPO   = 'PR ' "
		cSQL += " AND SE2.E2_VENCTO BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " ORDER BY SE2.E2_FILIAL,SE2.E2_NATUREZ,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_LOJA"
		
		//Log de controle
		Memowrite('\STCR006-2.TXT',cSQL) 
EndCase		
		
//Verifica se alias está em uso
If chkfile("_TMP")
	DbselectArea("_TMP")
	DbCloseArea()
End If

//Cria query
TcQuery cSQL New Alias "_TMP"

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC002   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime os itens do relatorio                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fSTC002(nLin)

@nLin,000 PSAY "Titulo Provisorio: "

nLin := nLin + 1
nLin := nLin + 1

@nLin,000 PSAY MascNat(_TMP->NATUREZA) 
@nLin,018 PSAY _TMP->DESCRICAO 
@nLin,057 PSAY _TMP->PREFIXO 
@nLin,063 PSAY _TMP->NUMERO
@nLin,075 PSAY _TMP->PARCELA
@nLin,080 PSAY _TMP->TIPO
@nLin,086 PSAY _TMP->CODIGO
@nLin,096 PSAY _TMP->LOJA
@nLin,100 PSAY STOD(_TMP->EMISSAO)
@nLin,110 PSAY STOD(_TMP->VENCIMENTO)
@nLin,120 PSAY Padl(Transform(_TMP->VALOR,"@E 999,999,999.99"),14)

nLin := nLin + 1

@nLin,000 PSAY Replicate("-",150)

nLin := nLin + 1

Return nLin
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC003   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Processamento da rotina                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fSTC003


If MsgYesNo("Confirma processamento dos titulos apresentados na rotina?")

	Do Case 
		Case nOpc == 1
			SE1->(DbSetOrder(1))
			//Titulos provisorios
			For i:=1 To Len(aTitulos)
				If SE1->(DbSeek(xFilial("SE1")+aTitulos[i,1]+aTitulos[i,2]+aTitulos[i,3]+aTitulos[i,4]))
					Reclock("SE1",.F.)
						SE1->E1_VALOR := aTitulos[i,7]
						SE1->E1_SALDO := aTitulos[i,7]
						SE1->E1_VLCRUZ:= aTitulos[i,7]
					SE1->(MsUnlock())
				Endif	
			Next i               
			
			//Titulos normais
			For i:=1 To Len(aOrigem)
				If SE1->(DbSeek(xFilial("SE1")+aOrigem[i,1]+aOrigem[i,2]+aOrigem[i,3]+aOrigem[i,4]))
					Reclock("SE1",.F.)
						SE1->E1_YATU := 'S' 
					SE1->(MsUnlock())
				Endif	
			Next i
			
		Case nOpc ==2
		
			SE2->(DbSetOrder(1))
			//Titulos provisorios
			For i:=1 To Len(aTitulos)
				If SE2->(DbSeek(xFilial("SE2")+aTitulos[i,1]+aTitulos[i,2]+aTitulos[i,3]+aTitulos[i,4]+aTitulos[i,5]+aTitulos[i,6]))
					Reclock("SE2",.F.)
						SE2->E2_VALOR := aTitulos[i,7]
						SE2->E2_SALDO := aTitulos[i,7]
						SE2->E2_VLCRUZ:= aTitulos[i,7]
					SE2->(MsUnlock())
				Endif	
			Next i               
			
			//Titulos normais
			For i:=1 To Len(aOrigem)
				If SE2->(DbSeek(xFilial("SE1")+aOrigem[i,1]+aOrigem[i,2]+aOrigem[i,3]+aOrigem[i,4]+aOrigem[i,5]+aOrigem[i,6]))
					Reclock("SE2",.F.)
						SE2->E2_YATU := 'S' 
					SE2->(MsUnlock())
				Endif	
			Next i
	EndCase	
EndIf
Return           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC004   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Cria arquivo temporario com os dados a serem impressos no  º±±
±±º          ³ relatorio.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSTC004

Local cSQL := ""
Local cSED := RetSQLName("SED") + " SED "
Local cSE1 := RetSQLName("SE1") + " SE1 "
Local cSE2 := RetSQLName("SE2") + " SE2 "

Local cTamNat := Alltrim(STR(Len(Alltrim(_TMP->NATUREZA))))

Do Case
	Case nOpc == 1
		
		cSQL := " SELECT  "
		
		cSQL += " SE1.E1_PREFIXO PREFIXO "
		cSQL += ",SE1.E1_NUM NUMERO "
		cSQL += ",SE1.E1_PARCELA PARCELA "
		cSQL += ",SE1.E1_TIPO TIPO "
		cSQL += ",SE1.E1_CLIENTE CODIGO "
		cSQL += ",SE1.E1_LOJA LOJA "
		cSQL += ",SE1.E1_VENCTO VENCIMENTO "
		cSQL += ",SE1.E1_EMISSAO EMISSAO "
		cSQL += ",SE1.E1_VALOR VALOR "
		cSQL += ",SE1.E1_NATUREZ NATUREZA "
		cSQL += ",SED.ED_DESCRIC DESCRICAO " 
		
		cSQL += " FROM " + cSE1 + " "
		
		cSQL += " INNER JOIN " + cSED + " ON "
		
		cSQL += " SED.D_E_L_E_T_ = '' " 
		cSQL += " AND SED.ED_FILIAL = '" + xFilial("SEE") + "' " 
		cSQL += " AND SED.ED_CODIGO = SE1.E1_NATUREZ " 
		
		cSQL += " WHERE "
		cSQL += " SE1.D_E_L_E_T_                           = '' "
		cSQL += " AND SE1.E1_FILIAL                        = '" + xFilial("SE1") + "' "
		cSQL += " AND LEFT(SE1.E1_NATUREZ," + cTamNat + ") = '" + Alltrim(_TMP->NATUREZA) + "' "
		cSQL += " AND SE1.E1_YATU                          = '' "
		cSQL += " AND SE1.E1_TIPO                          <> 'PR ' "
		cSQL += " AND SE1.E1_VENCTO BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " ORDER BY SE1.E1_FILIAL,SE1.E1_NATUREZ,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_CLIENTE,SE1.E1_LOJA"
		
		//Log de controle
		Memowrite('\STCR006-3.TXT',cSQL)
		
	Case nOpc == 2
		
		cSQL := " SELECT  "
		
		cSQL += " SE2.E2_PREFIXO PREFIXO"
		cSQL += ",SE2.E2_NUM NUMERO"
		cSQL += ",SE2.E2_PARCELA PARCELA"
		cSQL += ",SE2.E2_TIPO TIPO"
		cSQL += ",SE2.E2_FORNECE CODIGO"
		cSQL += ",SE2.E2_LOJA LOJA"
		cSQL += ",SE2.E2_VENCTO VENCIMENTO"
		cSQL += ",SE2.E2_EMISSAO EMISSAO"
		cSQL += ",SE2.E2_VALOR VALOR"
		cSQL += ",SE2.E2_NATUREZ NATUREZA"
		cSQL += ",SED.ED_DESCRIC DESCRICAO" 
		
		cSQL += " FROM " + cSE2 + " "
		
		cSQL += " INNER JOIN " + cSED + " ON "
		
		cSQL += " SED.D_E_L_E_T_ = '' " 
		cSQL += " AND SED.ED_FILIAL = '" + xFilial("SEE") + "' " 
		cSQL += " AND SED.ED_CODIGO = SE2.E2_NATUREZ " 
		
		cSQL += " WHERE "
		cSQL += " SE2.D_E_L_E_T_                           = '' "
		cSQL += " AND SE2.E2_FILIAL                        = '" + xFilial("SE2") + "' "
		cSQL += " AND LEFT(SE2.E2_NATUREZ," + cTamNat + ") = '" + Alltrim(_TMP->NATUREZA) + "' "
		cSQL += " AND SE2.E2_YATU                          = '' "
		cSQL += " AND SE2.E2_TIPO                          <> 'PR ' "
		cSQL += " AND SE2.E2_VENCTO BETWEEN '" + cDatDe + "' AND '" + cDatAte + "' "
		
		cSQL += " ORDER BY SE2.E2_FILIAL,SE2.E2_NATUREZ,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_LOJA"
		
		//Log de controle
		Memowrite('\STCR006-4.TXT',cSQL) 
EndCase		
		
//Verifica se alias está em uso
If chkfile("_TRB")
	DbselectArea("_TRB")
	DbCloseArea()
End If

//Cria query
TcQuery cSQL New Alias "_TRB"

Return     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³fSTC005   º Autor ³ Micorsiga Vitoria  º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime os itens do relatorio                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fSTC005(nLin)

@nLin,000 PSAY MascNat(_TRB->NATUREZA) 
@nLin,018 PSAY _TRB->DESCRICAO 
@nLin,057 PSAY _TRB->PREFIXO 
@nLin,063 PSAY _TRB->NUMERO
@nLin,075 PSAY _TRB->PARCELA
@nLin,080 PSAY _TRB->TIPO
@nLin,086 PSAY _TRB->CODIGO
@nLin,096 PSAY _TRB->LOJA
@nLin,100 PSAY STOD(_TRB->EMISSAO)
@nLin,110 PSAY STOD(_TRB->VENCIMENTO)
@nLin,120 PSAY Padl(Transform(_TRB->VALOR,"@E 999,999,999.99"),14)

nLin := nLin + 1

Return nLin