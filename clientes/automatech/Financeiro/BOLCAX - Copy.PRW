#include "rwmake.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBOLCAX    บAutor  ณMauro JPC           บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao de boleto da CEF.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION BOLCAX(lBord,cNumBord)

SetPrvt("AAC,ACRA,CNOMEREL,CFILE,CSAVSCR1,CSAVCUR1")
SetPrvt("CSAVROW1,CSAVCOL1,CSAVCOR1,ANOTA,CALIAS,CSAVSCR3,CCOLOR")
//SetPrvt("MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10")
SetPrvt("CTELA,AFILE,CSAVSCR,I,CSAVCOR,NOPCFILE")
SetPrvt("NOPCA,NTREGS,NMULT,NANT,NATU,NCNT")
SetPrvt("NTOTPORCEN,CSAV20,CSAV7,NDIA,CBARRA,CLINHA,cBarraImp,cBarraFim")
SetPrvt("NDIGITO,CCAMPO,NCONT,NVAL,instr1,instr2,cBarraImp4,X,NOSSONUM,cCondicao")

Private nLastKey		:= 0
Private cPerguntas		:= .F.
Private oFont, cCode
Private cBarraFim
Private cBarraImp		:= space(50)
Private nHeight			:= 15
Private lBold			:= .F.
Private lUnderLine		:= .F.
Private lPixel			:= .T.
Private lPrint			:= .F.
Private nSedex			:= 1
Private MsgInstr01		:= " "
Private MsgInstr02		:= " "
Private MsgInstr03		:= 0
Private MsgInstr04		:= " "
Private nossonum		:= ""
Private lNew			:= .F.

oFont1 := TFont():New( "Times New Roman"	,,08	,,.T.,,,,,.F. )
oFont2 := TFont():New( "Times New Roman"	,,10	,,.T.,,,,,.F. )
oFont3 := TFont():New( "Times New Roman"	,,12	,,.T.,,,,,.F. )
oFont4 := TFont():New( "Times New Roman"	,,14	,,.T.,,,,,.F. )
oFont5 := TFont():New( "Times New Roman"	,,16	,,.T.,,,,,.F. )

oFont6 := TFont():New( "HAETTENSCHWEILLER"	,,10	,,.T.,,,,,.F. )

oFont8 	:= TFont():New( "Free 3 of 9" 		,,44	,,.T.,,,,,.F. )
oFont10	:= TFont():New( "Free 3 of 9" 		,,38	,,.T.,,,,,.F. )
oFont11	:= TFont():New( "Courier New" 		,,10	,,.T.,,,,,.F. )
oFont12	:= TFont():New( "Courier New" 		,,09	,,.T.,,,,,.F. )
oFont13	:= TFont():New( "Arial"       		,,06	,,.F.,,,,,.F. )
oFont14	:= TFont():New( "Arial"       		,,09	,,.F.,,,,,.F. )
oFont15	:= TFont():New( "Arial"       		,,10	,,.T.,,,,,.F. )
oFont16	:= TFont():New( "Arial"       		,,12	,,.F.,,,,,.F. )
oFont17	:= TFont():New( "Arial"       		,,14	,,.T.,,,,,.F. )
oFont18	:= TFont():New( "Arial"       		,,09	,,.T.,,,,,.F. )
oFont19	:= TFont():New( "Arial"       		,,22	,,.T.,,,,,.F. )
oFont20	:= TFont():New( "Arial Black" 		,,16	,,.T.,,,,,.F. )
oFont21	:= TFont():New( "Arial"       		,,18	,,.T.,,,,,.F. )
oFont22	:= TFont():New( "Times New Roman"	,,15.5	,,.T.,,,,,.F. )
oFont23	:= TFont():New( "Arial Black" 		,,15.7	,,.T.,,,,,.F. )
oFont24	:= TFont():New( "Arial"				,,07	,,.T.,,,,,.F. )

If lBord
	mv_par01 := ""
	mv_par02 := ""
	mv_par03 := "ZZZZZZZZZ"
	mv_par04 := ""
	mv_par05 := "Z"
	
	ImprimeDup()
Else
	cPerg	:= "BOLCAX    "
	ValidPerg()
	cPerguntas := Pergunte(cPerg,.T.)
	
	If cPerguntas == .T.
		ImprimeDup()
	Endif
EndIf

MS_FLUSH()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeDup                                                  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION IMPRIMEDUP()
Local cQuery 		:= {}
Private x			:= ""
Private nossonum 	:= ""

//Localiza o nosso n๚mero no cadastro de parโmetros banco.                    
cQuery := " SELECT EE_NUMBCO FROM "+ RETSQLNAME("SEE") +" "
cQuery += " WHERE EE_FILIAL = '01' "
cQuery += " AND EE_AGENCIA = '0446' "
cQuery += " AND EE_CONTA = '22810' "
cQuery += " AND EE_SUBCTA = '001' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TEMPSEE',.T.,.T.)
DbSelectArea("TEMPSEE")
	x:= TEMPSEE->EE_NUMBCO
DbSelectArea("TEMPSEE")
DbCloseArea()	

//Caso nใo encontre, finaliza a opera็ใo.             
If Empty(x)
	MsgBox("Nใo foi possivel localizar o registro. Favor verificar!")
	Return()
EndIf

//Monta o nosso n๚mero, com 10 caracteres. Depois serแ acrescentado o dํgito, finalizando 11 caracteres.
nossonum := '82'+strzero(val(x),8)

DbSelectArea("SE1")

	SE1->(dbSetOrder(1))   // prefixo+numero
	SE1->(dbgotop())
	SE1->(dbSeek(xFilial("SE1")+mv_par01+mv_par02+mv_par04,.T.))
	cCondicao := "SE1->E1_FILIAL == xFilial() .And.	SE1->E1_prefixo == mv_par01 .and. se1->e1_num <= mv_par03 .and. se1->e1_PARCELA <= mv_par05"

Do While &cCondicao .And. !Eof()
	oPrn := tAvPrinter():New( "Protheus2" )
	oPrn :Setup()   // para configurar impressora
	
	If SE1->E1_TIPO == "IR-"
		dbSkip()
		Loop
	Endif
	
	If SE1->E1_PORTADO <> "104" //Caixa Economica Federal
		dbSkip()
		Loop
	Endif
	
	If SE1->E1_IMPRESS == "S"
		bImpress := MSGBOX("Imprimir novamente o titulo "+SE1->E1_NUM+" "+SE1->E1_PARCELA+" ?","Aviso de Impressao","YESNO")
		If bImpress == .f.
			dbSkip()
			Loop
		Endif
	Endif
	
	MsgInstr01	:= SE1->E1_INSTR1
	MsgInstr02	:= SE1->E1_INSTR2
	MsgInstr03	:= 0 //MV_PAR10
	MsgInstr04	:= ""//MV_PAR08
	
	SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.f.))
	
	njuros := 0
	njuros := (MsgInstr03/30)/100
	njuros := Round(SE1->E1_VALOR * njuros,2)
	njuros := transf(njuros,"@E 999,999.99")
	
	nDiaMes		:= ""
	nDataBase	:= ""
	nFatorVen	:= ""
	nDiaMes		:=(Strzero(day(SE1->E1_VENCREA),2)+Strzero(month(SE1->E1_VENCREA),2)) // busca dia e mes para codigo de barra
	nDiaMesAno	:=(Strzero(day(SE1->E1_VENCREA),2)+Strzero(month(SE1->E1_VENCREA),2)+subs(Strzero(year(SE1->E1_VENCREA),4),3,2))
	
	nDataBase 	:= CtoD("07/10/1997") 			// data base para calculo do fator
	nFatorVen	:= SE1->E1_vencTO - nDataBase 	// acha a diferenca em dias para o fator de vencimento
	
	nDia:=Str((SE1->E1_VENCTO - CTOD("01/01/"+Subs(STR(YEAR(SE1->E1_VENCREA),5),4,2)))+1,3)+Subs(STR(YEAR(SE1->E1_VENCREA),5),5,1)
	cLinha		:=""
	
	If SE1->E1_IMPRESS == "S"
		nossonum := alltrim(Substr(SE1->E1_NUMBCO,1,10))//"82"+alltrim(Substr(SE1->E1_NUMBCO,1,8))
	Endif

	cBarra:=SE1->E1_PORTADO+If(SE1->E1_MOEDA==1,'9','0')+strzero(nFatorVen,4);
	+SUBS(STRZERO(SE1->E1_SALDO,16,2),6,8) +SUBS(STRZERO(SE1->E1_SALDO,16,2),15,2);
	+NOSSONUM + "044687000000695" //Agencia(4)+Operacao(3)+Cod cedente(8)

	//agencia  cedente      carteira
	DVN := CDigitoNosso()  // calculo dos digitos verificadores do nosso numero.
	CDigitoChave()
	
	BOLLINDIG() //Calcula Linha de Digitacao
	
	oPrn:StartPage()
	
	cBitMap	       := "\system\logo_caixa.bmp"
	cLogoEmp	   := "\system\logo_caixa.bmp"
	
	
	oPrn:Say( 0, 0, " ",oFont,100 ) // startando a impressora
	
	//******************************************
	//  MONTA COMPROVANTE CLIENTE
	//******************************************
	cNome   := SA1->A1_NOME
	
	// Monta box do boleto
	oPrn:Box (0690, 0200, 1610, 2180)	
	
	// Monta linhas horizontais
	oPrn:Line(0800, 0200, 0801, 2180)
	oPrn:Line(0870, 0200, 0871, 2180)
	oPrn:Line(0940, 0200, 0941, 2180)
	oPrn:Line(1010, 0200, 1011, 2180)
	oPrn:Line(1355, 0200, 1356, 2180)

	oPrn:Line(1080, 1720, 1081, 2180)
	oPrn:Line(1150, 1720, 1151, 2180)
	oPrn:Line(1220, 1720, 1221, 2180)
	oPrn:Line(1290, 1720, 1291, 2180)
	
	oPrn:Line(2000, 0200, 2001, 2180)

	// Monta linha verticais
	oPrn:Line(0610, 0550, 0690, 0551)
	oPrn:Line(0610, 0730, 0690, 0731)
	oPrn:Line(0690, 1720, 1355, 1721)
	
	oPrn:Line(0870, 0500, 1011, 0501)
	oPrn:Line(0870, 0900, 1011, 0901)
	oPrn:Line(0870, 1100, 0941, 1101)
	oPrn:Line(0870, 1400, 1011, 1401)
	oPrn:Line(0940, 0700, 1011, 0701)
	
	oPrn:Say( 0550, 1800, "RECIBO SACADO"			,oFont24,100)	
	//oPrn:SayBitmap( 0580, 0210,cBitMap,300,80 )
	oPrn:Say( 0660, 0220, "CAIXA ECONิMICA FEDERAL"	,oFont13,100)
	oPrn:Say( 0615, 0560, "104-0"                  	,oFont21,100)
	oPrn:Say( 0615, 0745, cLinha                   	,oFont17,150)
	
	oPrn:Say( 0695, 0220, "Local de Pagamento "		,oFont13,100)
	oPrn:Say( 0695, 1730, "Vencimento "				,oFont13,100)
	oPrn:Say( 0745, 0240, ;
	"Pagแvel Preferencialmente nas Ag๊ncias Caixa Econ๔mica Federal",;
	oFont12,100  )
	oPrn:Say( 0745, 1940, DTOC(SE1->E1_VENCTO)		,oFont15,100)   //Vencimento do Titulo
	
	oPrn:Say( 0805, 0220, "Cedente "               	,oFont13,100)
	oPrn:Say( 0805, 1730, "Codigo Cedente "        	,oFont13,100)
	
	oPrn:Say( 0830, 0240, SM0->M0_NOMECOM			,oFont12,100)   //Cedente
	oPrn:Say( 0830, 1740, "0446.870.00000069-5"		,oFont12,100)   //Codigo do Cedente

	oPrn:Say( 0875, 0220, "Data Documento "        	,oFont13,100)
	oPrn:Say( 0875, 0510, "Nบ. Documento "         	,oFont13,100)
	oPrn:Say( 0875, 0910, "Especie Doc. "          	,oFont13,100)
	oPrn:Say( 0875, 1110, "Aceite "                	,oFont13,100)
	oPrn:Say( 0875, 1410, "Data do Processamento " 	,oFont13,100)
	oPrn:Say( 0875, 1730, "Nosso Numero "          	,oFont13,100)
	
	oPrn:Say( 0900, 0240, DTOC(SE1->E1_EMISSAO)		,oFont12,100)
	oPrn:Say( 0900, 0530, SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+;
	SE1->E1_PARCELA , oFont12,100  )
	oPrn:Say( 0900, 0970, "DM"						,oFont12,100)
	oPrn:Say( 0900, 1230, "N"						,oFont12,100)
	oPrn:Say( 0900, 1440, DTOC(DDATABASE)			,oFont12,100)
	oPrn:Say( 0900, 1880, NOSSONUM+"-"+DVN			,oFont12,100)
	
	oPrn:Say( 0945, 0220, "Uso do Banco "			,oFont13,100)
	oPrn:Say( 0945, 0510, "Carteira "				,oFont13,100)
	oPrn:Say( 0945, 0710, "Especie "				,oFont13,100)
	oPrn:Say( 0945, 0910, "Quantidade "				,oFont13,100)
	oPrn:Say( 0945, 1410, "Valor "					,oFont13,100)
	oPrn:Say( 0945, 1730, "Valor do Documento "		,oFont13,100)
	
	oPrn:Say( 0970, 0560, "SR"						,oFont12,100)   //Carteira
	oPrn:Say( 0970, 0770, "R$"						,oFont12,100)

	oPrn:Say( 0970, 1500, TRANSF(SE1->E1_SALDO,"@E 999,999.99") ,; //Valor
	oFont12,100)

	oPrn:Say( 0970, 1920, TRANSF(SE1->E1_SALDO,"@E 999,999.99") ,; //Valor documento
	oFont12,100)
	
	oPrn:Say( 1015, 0220, "Instru็๕es "				,oFont13,100)
	oPrn:Say( 1015, 1730, "(-) Desconto "			,oFont13,100)
	oPrn:Say( 1085, 0240, MsgInstr01				,oFont18,100)
	oPrn:Say( 1120, 0240, MsgInstr02				,oFont18,100)

	//Mensagem texto
	oPrn:Say( 1030, 0240, "Texto de responsabilidade do cedente. ",oFont18,100  )


	//Mensagem
	oPrn:Say( 1145, 0240, " ",oFont18,100  )

	//Mensagem
	oPrn:Say( 1185, 0240, " ",oFont18,100  )
	
	//Juros
	//oPrn:Say( 1225, 0240, "Ap๓s o Vcto. Cobrar, R$ "+njuros+" Por dia de Atraso." ,oFont18,100)

	
	oPrn:Say( 1265, 0240, MsgInstr04				,oFont18,100)
	
	oPrn:Say( 1085, 1730, "(-) Outras dedu็๕es "	,oFont13,100)
	oPrn:Say( 1155, 1730, "(+) Mora/Multa/Juros "	,oFont13,100)
	oPrn:Say( 1225, 1730, "(+) Outros Acrecimos "	,oFont13,100)
	oPrn:Say( 1295, 1730, "(=) Valor Cobrado "		,oFont13,100)
	
	oPrn:Say( 1355, 0220, "Sacado"					,oFont13,100)
	oPrn:Say( 1380, 0240, SE1->E1_CLIENTE + " - " + ALLTRIM(cNome),;
	oFont12,100  )
	oPrn:Say( 1420, 0240, ALLTRIM(SA1->A1_END)		,oFont12,100)
	oPrn:Say( 1460, 0240, substr(SA1->A1_CEP,1,5)+"-"+;
	substr(SA1->A1_CEP,6,3)+"  "+ALLTRIM(SA1->A1_BAIRRO)+" - "+;
	ALLTRIM(SA1->A1_MUN)+"   "+SA1->A1_EST, oFont12,100)
	oPrn:Say( 1500, 0240, "CNPJ: "+SUBS(SA1->A1_CGC,1,2)+"."+;
	SUBS(SA1->A1_CGC,3,3)+"."+SUBS(SA1->A1_CGC,6,3)+"/"+;
	SUBS(SA1->A1_CGC,9,4)+"-"+SUBS(SA1->A1_CGC,13,2),oFont12,100)
	oPrn:Say( 1620, 1800, "AUTENTICACAO MECANICA"	,oFont24,100)
	
	oPrn:Say( 1960, 1100, "Corte na linha abaixo:"	,oFont13,100)


	//******************************************
	//  MONTA FICHA COMPENSAวรO
	//******************************************
	// Monta box do boleto
	oPrn:Box (2180, 0200, 3100, 2180)
	
	// Monta linhas horizontais
	oPrn:Line(2290, 0200, 2291, 2180)
	oPrn:Line(2360, 0200, 2361, 2180)
	oPrn:Line(2430, 0200, 2431, 2180)
	oPrn:Line(2500, 0200, 2501, 2180)
	oPrn:Line(2845, 0200, 2846, 2180)
	
	// Monta linha verticais
	oPrn:Line(2100, 0550, 2180, 0551)
	oPrn:Line(2100, 0730, 2180, 0731)
	oPrn:Line(2180, 1720, 2845, 1721)
	
	oPrn:Line(2570, 1720, 2571, 2180)
	oPrn:Line(2640, 1720, 2641, 2180)
	oPrn:Line(2710, 1720, 2711, 2180)
	oPrn:Line(2780, 1720, 2781, 2180)

	oPrn:Line(2360, 0500, 2501, 0501)
	oPrn:Line(2360, 0900, 2501, 0901)
	oPrn:Line(2360, 1100, 2431, 1101)
	oPrn:Line(2360, 1400, 2501, 1401)
	oPrn:Line(2430, 0700, 2501, 0701)
	
	oPrn:Say( 2040, 1800, "FICHA DE COMPENSACAO"	,oFont24,100)
	oPrn:SayBitmap( 2070, 0210,cBitMap,300,80 )
	oPrn:Say( 2150, 0220, "CAIXA ECONิMICA FEDERAL"	,oFont13,100)
	oPrn:Say( 2105, 0560, "104-0"                  	,oFont21,100)
	oPrn:Say( 2105, 0745, cLinha                   	,oFont17,150)
	
	oPrn:Say( 2185, 0220, "Local de Pagamento "		,oFont13,100)
	oPrn:Say( 2185, 1730, "Vencimento "				,oFont13,100)
	oPrn:Say( 2235, 0240, ;
	"Pagแvel Preferencialmente nas Ag๊ncias Caixa Econ๔mica Federal",;
	oFont12,100  )
	oPrn:Say( 2235, 1940, DTOC(SE1->E1_VENCTO)		,oFont15,100)   //Vencimento do Titulo
	
	oPrn:Say( 2295, 0220, "Cedente "               	,oFont13,100)
	oPrn:Say( 2295, 1730, "Codigo Cedente "        	,oFont13,100)
	
	oPrn:Say( 2320, 0240, SM0->M0_NOMECOM			,oFont12,100)   //Cedente
	oPrn:Say( 2320, 1740, "0446.870.00000069-5" 		,oFont12,100)   //Codigo do Cedente

	oPrn:Say( 2365, 0220, "Data Documento "        	,oFont13,100)
	oPrn:Say( 2365, 0510, "Nบ. Documento "         	,oFont13,100)
	oPrn:Say( 2365, 0910, "Especie Doc. "          	,oFont13,100)
	oPrn:Say( 2365, 1110, "Aceite "                	,oFont13,100)
	oPrn:Say( 2365, 1410, "Data do Processamento " 	,oFont13,100)
	oPrn:Say( 2365, 1730, "Nosso Numero "          	,oFont13,100)
	
	oPrn:Say( 2390, 0240, DTOC(SE1->E1_EMISSAO)		,oFont12,100)
	oPrn:Say( 2390, 0530, SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+;
	SE1->E1_PARCELA , oFont12,100  )
	oPrn:Say( 2390, 0970, "DM"						,oFont12,100)
	oPrn:Say( 2390, 1230, "N"						,oFont12,100)
	oPrn:Say( 2390, 1440, DTOC(DDATABASE)			,oFont12,100)
	oPrn:Say( 2390, 1880, NOSSONUM+"-"+DVN			,oFont12,100)
	
	oPrn:Say( 2435, 0220, "Uso do Banco "			,oFont13,100)
	oPrn:Say( 2435, 0510, "Carteira "				,oFont13,100)
	oPrn:Say( 2435, 0710, "Especie "				,oFont13,100)
	oPrn:Say( 2435, 0910, "Quantidade "				,oFont13,100)
	oPrn:Say( 2435, 1410, "Valor "					,oFont13,100)
	oPrn:Say( 2435, 1730, "Valor do Documento "		,oFont13,100)
	
	oPrn:Say( 2460, 0560, "SR"						,oFont12,100)   //Carteira
	oPrn:Say( 2460, 0770, "R$"						,oFont12,100)
	oPrn:Say( 2460, 1920, TRANSF(SE1->E1_SALDO,"@E 999,999.99") ,;
	oFont12,100)
	
	oPrn:Say( 2505, 0220, "Instru็๕es "				,oFont13,100)
	oPrn:Say( 2505, 1730, "(-) Desconto "			,oFont13,100)
	oPrn:Say( 2575, 0240, MsgInstr01				,oFont18,100)
	oPrn:Say( 2610, 0240, MsgInstr02				,oFont18,100)

	//Mensagem texto
	oPrn:Say( 2520, 0240, "Texto de responsabilidade do cedente. ",oFont18,100  )

    
	//Mensagem
	oPrn:Say( 2635, 0240, " ",oFont18,100  )
	
	//Mensagem
	oPrn:Say( 2675, 0240, " ",oFont18,100  )
	
	//Juros
	//oPrn:Say( 2715, 0240, "Ap๓s o Vcto. Cobrar, R$ "+njuros+" Por dia de Atraso." ,oFont18,100)

	oPrn:Say( 2755, 0240, MsgInstr04				,oFont18,100)
	
	oPrn:Say( 2575, 1730, "(-) Outras dedu็๕es "	,oFont13,100)
	oPrn:Say( 2645, 1730, "(+) Mora/Multa/Juros "	,oFont13,100)
	oPrn:Say( 2715, 1730, "(+) Outros Acrecimos "	,oFont13,100)
	oPrn:Say( 2785, 1730, "(=) Valor Cobrado "		,oFont13,100)
	
	oPrn:Say( 2845, 0220, "Sacado"					,oFont13,100)
	oPrn:Say( 2870, 0240, SE1->E1_CLIENTE + " - " + ALLTRIM(cNome),;
	oFont12,100  )
	oPrn:Say( 2910, 0240, ALLTRIM(SA1->A1_END)		,oFont12,100)
	oPrn:Say( 2950, 0240, substr(SA1->A1_CEP,1,5)+"-"+;
	substr(SA1->A1_CEP,6,3)+"  "+ALLTRIM(SA1->A1_BAIRRO)+" - "+;
	ALLTRIM(SA1->A1_MUN)+"   "+SA1->A1_EST, oFont12,100)
	oPrn:Say( 2990, 0240, "CNPJ: "+SUBS(SA1->A1_CGC,1,2)+"."+;
	SUBS(SA1->A1_CGC,3,3)+"."+SUBS(SA1->A1_CGC,6,3)+"/"+;
	SUBS(SA1->A1_CGC,9,4)+"-"+SUBS(SA1->A1_CGC,13,2),oFont12,100)
	oPrn:Say( 3110, 1580, "AUTENTICACAO MECANICA/FICHA COMPENSACAO"	,oFont24,100)
	
    //Impressใo do c๓digo de barras.
	MSBAR("INT25"	,26.8,2.3,Alltrim(cBarraFim),oPrn ,.F.,Nil,Nil,0.025,1.3,Nil,Nil    ,"A",.F.)
	oPrn:EndPage()
	
	oPrn:EndPage()     // Finaliza a pแgina
	oPrn:Preview()
	
	//  GRAVACAO DO NOSSO NUMERO NO SE1
	If SE1->E1_IMPRESS # "S"
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO  := NOSSONUM+DVN
		SE1->E1_IMPRESS := "S"
		MsUnLock()
		
		nossonum := STRzero(VAL(nossonum) + 1,10)
		x := STRzero(VAL(x) + 1,6)
		lNew:=.T.
	Endif
	SE1->(dbSkip())
	Loop
EndDo

If lNew
	cQuery := {}
	cQuery := " UPDATE "+ RETSQLNAME("SEE") +" "
	cQuery += " SET EE_NUMBCO = '"+ x +"' "
	cQuery += " WHERE EE_FILIAL = '01' "
	cQuery += " AND EE_AGENCIA = '0446' "
	cQuery += " AND EE_CONTA = '22810' "
	cQuery += " AND EE_SUBCTA = '001' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	TcSqlExec(cQuery)
	
Endif

RETURN(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBOLLINDIG                                                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION BOLLINDIG()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calculo do Primeiro Campo.                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cLinha:=""
nDigito:=0

// banco+moeda+(nosso numero,1,5)
cCampo:=SE1->E1_PORTADO+if(SE1->E1_MOEDA==1,'9','0')+SUBS(cBarra,19,5)
Digito()
cLinha:=cLinha+SE1->E1_PORTADO+If(SE1->E1_MOEDA==1,'9','0')+Subs(cBarra,19,1)+"."+Subs(cBarra,20,4)+Str(nDigito,1)+Space(2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calculo do Segundo Campo.                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//substr(nosso numero,6,6)+agencia(4)
//cCampo:=Subs(cBarra,24,6)+"4140"
cCampo:=Subs(cBarra,24,10)
Digito()
cLinha:=cLinha+Subs(cBarra,24,5)+"."+Subs(cBarra,29,5)+Str(nDigito,1)+Space(2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calculo do Terceiro Campo.                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//codigo cedente (8)+carteira(2)
cCampo:=Subs(cBarra,34,10)
Digito()
cLinha:=cLinha+Subs(cBarra,34,5)+"."+Subs(cBarra,39,5)+Str(nDigito,1)+Space(2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calculo do Quarto Campo.                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// dv codigo barras + fator vencto + valor
If Val(Subs(cBarra,05,14))==0 .OR. SE1->E1_MOEDA != 1
	cCampo:="            000"
Else
	cCampo:=Str(Val(Subs(cBarra,05,14)),14)
Endif
cLinha:=cLinha+subs(cBarraFim,5,1)+" "+cCampo
li := 0
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIGITO                                                      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION DIGITO()

nCont:=0
cCampo:=StrZero(Val(cCampo),10)
For i:=1 to Len(cCampo)
	If (i%2) != 0
		nCont:=nCont+(Val(Subs(cCampo,i,1))*1)
	Else
		If Val(Subs(cCampo,i,1))*2 >= 10
			nVal:=Val(Subs(cCampo,i,1))*2
			nCont:=nCont+(Val(Subs(Str(nVal,2),1,1))+Val(Subs(Str(nVal,2),2,1)))
		Else
			nCont:=nCont+(Val(Subs(cCampo,i,1))*2)
		Endif
	Endif
Next i
nDigito:=Abs(If(nCont%10==0,0,(nCont%10)-10))
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCDIGITOCHAVE                                                บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION CDIGITOCHAVE()


nCont:=0
cBarraImp 	:= space(43)
cBarraImp	:= Subs(cBarra,1,43)

CalculaModulo11()

nResto := MOD(ncont,11)
nDigitoImp := 11 - nResto

If nResto <= 1 .or. nResto > 9
	nDigitoImp := 1
Endif

cBarraFim := subs(cBarra,1,4) + strzero(nDigitoImp,1) + subs(cBarra,5,43)
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalculaModulo11                                             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION CALCULAMODULO11()

nCont	:= 0.00
nCont	:= nCont+(Val(Subs(cBarraImp,43,1))*2)
nCont	:= nCont+(Val(Subs(cBarraImp,42,1))*3)
nCont	:= nCont+(Val(Subs(cBarraImp,41,1))*4)
nCont	:= nCont+(Val(Subs(cBarraImp,40,1))*5)
nCont	:= nCont+(Val(Subs(cBarraImp,39,1))*6)
nCont	:= nCont+(Val(Subs(cBarraImp,38,1))*7)
nCont	:= nCont+(Val(Subs(cBarraImp,37,1))*8)
nCont	:= nCont+(Val(Subs(cBarraImp,36,1))*9)
nCont	:= nCont+(Val(Subs(cBarraImp,35,1))*2)
nCont	:= nCont+(Val(Subs(cBarraImp,34,1))*3)
nCont	:= nCont+(Val(Subs(cBarraImp,33,1))*4)
nCont	:= nCont+(Val(Subs(cBarraImp,32,1))*5)
nCont	:= nCont+(Val(Subs(cBarraImp,31,1))*6)
nCont	:= nCont+(Val(Subs(cBarraImp,30,1))*7)
nCont	:= nCont+(Val(Subs(cBarraImp,29,1))*8)
nCont	:= nCont+(Val(Subs(cBarraImp,28,1))*9)

nCont	:= nCont+(Val(Subs(cBarraImp,27,1))*2)
nCont	:= nCont+(Val(Subs(cBarraImp,26,1))*3)
nCont	:= nCont+(Val(Subs(cBarraImp,25,1))*4)
nCont	:= nCont+(Val(Subs(cBarraImp,24,1))*5)
nCont	:= nCont+(Val(Subs(cBarraImp,23,1))*6)
nCont	:= nCont+(Val(Subs(cBarraImp,22,1))*7)
nCont	:= nCont+(Val(Subs(cBarraImp,21,1))*8)
nCont	:= nCont+(Val(Subs(cBarraImp,20,1))*9)
nCont	:= nCont+(Val(Subs(cBarraImp,19,1))*2)

nCont	:= nCont+(Val(Subs(cBarraImp,18,1))*3)
nCont	:= nCont+(Val(Subs(cBarraImp,17,1))*4)
nCont	:= nCont+(Val(Subs(cBarraImp,16,1))*5)
nCont	:= nCont+(Val(Subs(cBarraImp,15,1))*6)
nCont	:= nCont+(Val(Subs(cBarraImp,14,1))*7)
nCont	:= nCont+(Val(Subs(cBarraImp,13,1))*8)

nCont	:= nCont+(Val(Subs(cBarraImp,12,1))*9)
nCont	:= nCont+(Val(Subs(cBarraImp,11,1))*2)
nCont	:= nCont+(Val(Subs(cBarraImp,10,1))*3)
nCont	:= nCont+(Val(Subs(cBarraImp,09,1))*4)
nCont	:= nCont+(Val(Subs(cBarraImp,08,1))*5)
nCont	:= nCont+(Val(Subs(cBarraImp,07,1))*6)

nCont	:= nCont+(Val(Subs(cBarraImp,06,1))*7)
nCont	:= nCont+(Val(Subs(cBarraImp,05,1))*8)
nCont	:= nCont+(Val(Subs(cBarraImp,04,1))*9)
nCont	:= nCont+(Val(Subs(cBarraImp,03,1))*2)
nCont	:= nCont+(Val(Subs(cBarraImp,02,1))*3)
nCont	:= nCont+(Val(Subs(cBarraImp,01,1))*4)

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCDIGITONOSSO                                                บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION CDIGITONOSSO()

nCont:=0
cBarraImp3 	:= space(11)
cBarraImp3	:= nossonum  // Subs(cBarra,19,10)
CalNosso()
nCont1  := int(nCont  / 11)
nCont2	:= ncont1 * 11
nResto  := ncont - ncont2
nResto  := 11 - nResto
If nResto > 9
	nResto := 0
	cBarraImp4 := cBarraImp3+"0"
	Return("0")
Else
	cBarraImp4 := cBarraImp3 + strzero(nResto,1)
	Return(StrZero(nResto,1))
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCALNOSSO                                                    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION CALNOSSO()

nCont	:= 0
//nCont	:= nCont+(Val(Subs(cBarraImp3,11,1))*9)
nCont	:= nCont+(Val(Subs(cBarraImp3,10,1))*2)
nCont	:= nCont+(Val(Subs(cBarraImp3,09,1))*3)
nCont	:= nCont+(Val(Subs(cBarraImp3,08,1))*4)
nCont	:= nCont+(Val(Subs(cBarraImp3,07,1))*5)
nCont	:= nCont+(Val(Subs(cBarraImp3,06,1))*6)
nCont	:= nCont+(Val(Subs(cBarraImp3,05,1))*7)
nCont	:= nCont+(Val(Subs(cBarraImp3,04,1))*8)
nCont	:= nCont+(Val(Subs(cBarraImp3,03,1))*9)
nCont	:= nCont+(Val(Subs(cBarraImp3,02,1))*2)
nCont	:= nCont+(Val(Subs(cBarraImp3,01,1))*3)

Return()




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณMauro JPC           บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao das perguntas.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALIDPERG()

Private cAlias 	:= Alias()
Private aRegs 	:= {}

//          Grupo/Ordem/Pergunta             /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01" ,"Prefixo			?","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Do titulo			?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Ate titulo			?","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Da parcela			?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Ate a parcela		?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerg,"06","Mensagem			?","","","mv_ch5","C",50,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerg,"07","Segunda Mensagem	?","","","mv_ch7","C",50,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerg,"08","% de Juros ao M๊s	?","","","mv_ch8","N",14,2,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})

DbSelectArea("SX1")
DbSetOrder(1)
For nConti:=1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[nConti,2])
		RecLock("SX1",.T.)
		For nContj:=1 to FCount()
			If nContj<=Len(aRegs[nConti])
				FieldPut(nContj,aRegs[nConti,nContj])
			Endif
		Next
		MsUnlock()
	Endif
Next
DbSelectArea(cAlias)

Return()
