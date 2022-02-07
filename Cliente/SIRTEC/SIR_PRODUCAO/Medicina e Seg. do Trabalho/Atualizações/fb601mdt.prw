#INCLUDE "MDTR810.ch"
#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fb601mdt ³ Autor ³ Daniela Uez           ³ Data ³ 09/06/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Relatorio dos funcionarios que receberam EPI.                ³±±
±±³          ³O usuario pode selecionar o Funcionario, o EPI e um periodo  ³±±
±±³          ³obtendo a relacao dos fucinarios que ja receberam os EPI.    ³±±
±±³          ³O programa inicia com a tabela de EPI,s entregues, obtem     ³±±   s
±±³          ³dados do funcionario na tabela de funcionario(SRA).          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user Function fb601mdt()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel   := "fb601mdt"
LOCAL limite  := 132
LOCAL cDesc1  := "Relatorio de apresentacao dos funcionarios que receberam EPI/EPC  "
LOCAL cDesc2  := "em um determinado período."
LOCAL cDesc3  :=  ""
LOCAL cString := "TNF"
Local nSizeCod := If((TAMSX3("B1_COD")[1]) < 1,20,(TAMSX3("B1_COD")[1]))

SETKEY(VK_F9, {|| NGVersao("MDTR810",04)})

nTa1 		:= If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
nTa1L 		:= If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
nSizeTD 	:= nTa1+nTa1L

PRIVATE nTamB1Des 	:= If((TAMSX3("B1_DESC")[1]) < 1,30,(TAMSX3("B1_DESC")[1]))
PRIVATE nomeprog 	:= "MDTR810"
PRIVATE tamanho  	:= "G"
PRIVATE aReturn  	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE titulo   	:= "EPI/EPC's por Funcionário"
PRIVATE ntipo    	:= 0
PRIVATE nLastKey 	:= 0
PRIVATE cPerg 		:= padr("fb601mdt", LEN(SX1->X1_GRUPO), " ")
PRIVATE cabec1, cabec2
PRIVATE nSizeSA2	:= If((TAMSX3("A2_COD")[1]) < 1,6,(TAMSX3("A2_COD")[1]))
PRIVATE nSizeSRJ 	:= If((TAMSX3("RJ_FUNCAO")[1]) < 1,4,(TAMSX3("RJ_FUNCAO")[1]))

pergunte(cPerg,.F.)

wnrel:="fb601mdt"

wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| R810Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R810Imp  ³ Autor ³ Inacio Luiz Kolling   ³ Data ³13/04/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR810                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R810Imp(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRodaTxt := ""
LOCAL nCntImpr := 0
LOCAL nLenStr
LOCAL nY
LOCAL nX
LOCAL nXX
LOCAL cCLiente := ""
LOCAL lPri := .T.
Local nSizeCod := If((TAMSX3("B1_COD")[1]) < 1,20,(TAMSX3("B1_COD")[1]))

Local cArqTrab
Local aDBF
Local cIndTRB

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para controle do cursor de progressao do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nTotRegs := 0 ,nMult := 1 ,nPosAnt := 4 ,nPosAtu := 4 ,nPosCnt := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cChave           := SPACE(16)
Local lContinua        := .T.

Private cAliasTRB

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private li := 80 ,m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



cabec1 := "Matricula  Nome Funcionario                           Sexo  Admissao  Idade  C.Custo - Descricao" //STR0007 //
cabec2 := "      EPI                       Nome do EPI                           Tipo         Dt.Entrega       Dt. Dev.        Qtde.          Fornec - Descricao                               C.A."

	aDBF := {}
	AADD(aDBF,{"MATRICULA","C",06,0})
	AADD(aDBF,{"EPI"      ,"C",nSizeCod,0})
	AADD(aDBF,{"DATAENTR" ,"D",08,0})
	AADD(aDBF,{"DATADEVO" ,"D",08,0})
	AADD(aDBF,{"QTDENT "  ,"N",06,2	})
	AADD(aDBF,{"FORNEC"   ,"C",nSizeSA2,0})
	AADD(aDBF,{"FUNCAO"   ,"C",nSizeSRJ,0})
	AADD(aDBF,{"CA"       ,"C",12,0})

	cArqTrab := CriaTrab(aDBF)
	cAliasTRB := GetNextAlias()
	dbUseArea(.T.,,cArqTrab,cAliasTRB,.f.)

	cIndTRB := CriaTrab(Nil, .F.)

	IndRegua(cAliasTRB,cIndTRB,"FUNCAO+MATRICULA+DTOS(DATAENTR)+EPI")

	dbClearIndex()
	dbSetIndex(cIndTRB + OrdBagExt())

	dbSelectArea("TNF")
	dbSetOrder(03)
	dbSeek(xFilial("TNF")+MV_PAR01,.T.)

	SetRegua(LastRec())

	While !Eof()                                   .AND.;
	      TNF->TNF_FILIAL == xFIlial('TNF')        .AND.;
	      TNF->TNF_MAT <= MV_PAR02

	      IncRegua()
	      If TNF->TNF_CODEPI < MV_PAR03 .OR. TNF->TNF_CODEPI > MV_PAR04
	         dbSelectArea("TNF")
	         dbSKIP()
	       	 loop
	      Endif

	      If TNF->TNF_DTENTR < MV_PAR05 .OR. TNF->TNF_DTENTR > MV_PAR06
	         dbSelectArea("TNF")
	         dbSKIP()
	         loop
	      Endif
	      DbSelectArea("TN3")
	      DbSetOrder(1)
	      DbSeek(xFilial("TN3")+TNF->TNF_FORNEC+TNF->TNF_LOJA+TNF->TNF_CODEPI+TNF->TNF_NUMCAP)
	      DbSelectArea(cAliasTRB)
	         (cAliasTRB)->(DbAppend())
	         (cAliasTRB)->MATRICULA := TNF->TNF_MAT
	         (cAliasTRB)->EPI       := TNF->TNF_CODEPI
	         (cAliasTRB)->DATAENTR  := TNF->TNF_DTENTR
	         (cAliasTRB)->DATADEVO  := TNF->TNF_DTDEVO
	         (cAliasTRB)->QTDENT    := TNF->TNF_QTDENT
	         (cAliasTRB)->FORNEC    := TNF->TNF_FORNEC
	         If !Empty(TNF->TNF_CODFUN)
			    (cAliasTRB)->FUNCAO := TNF->TNF_CODFUN
		   	 Else
		   	 	dbSelectArea("SRA")
	 		    dbSetOrder(1)
			    dbSEEK(xfilial("SRA")+(cAliasTRB)->MATRICULA)
			    (cAliasTRB)->FUNCAO :=  SRA->RA_CODFUNC
			 EndIf
	         (cAliasTRB)->CA        := TN3->TN3_NUMCAP
	      dbSelectArea("TNF")
	      dbSKIP()
	End
	dbSelectArea(cAliasTRB)
	dbGOTOP()

	If RecCount()==0
		MsgInfo(STR0014)	//"Não há nada para imprimir no relatório."
		Use
		Return .F.
	EndIf

	While !eof()
	   cFUNC := (cAliasTRB)->FUNCAO
	   Somalinha()
	   dbSelectArea("SRJ")
	   dbSetOrder(01)
	   dbSeek(xFilial("SRJ")+cFUNC)
	   @Li,000 PSAY "FUNÇÃO: " + Alltrim((cAliasTRB)->FUNCAO) + " - " + Alltrim(SRJ->RJ_DESC)
	   Somalinha()
	   Do while !eof() .AND. (cAliasTRB)->FUNCAO == cFUNC
		   cMAT  := (cAliasTRB)->MATRICULA
		   Somalinha()
		   dbSelectArea("SRA")
	 	   dbSetOrder(1)
		   dbSEEK(xfilial("SRA")+(cAliasTRB)->MATRICULA)
		   @Li,000 PSAY (cAliasTRB)->MATRICULA
		   @Li,054 PSAY SRA->RA_SEXO
		   @Li,060 PSAY SRA->RA_ADMISSA
		   @Li,070 PSAY YEAR(DATE())-YEAR(SRA->RA_NASC) PICTURE "99"

	       dbSelectArea("SI3")
	 	   dbSetOrder(01)
	   	   dbSeek(xFilial("SI3")+SRA->RA_CC)
	   	   If !Empty(SI3->I3_DESC)
			   @Li,077 PSAY Alltrim(SRA->RA_CC) + " - " + Alltrim(SI3->I3_DESC)
		   Else
			   @Li,077 PSAY SRA->RA_CC
		   EndIf

		   If SRA->(FieldPos("RA_NOMECMP")) > 0 .AND. !Empty(SRA->RA_NOMECMP)
			   nLenStr := Len ( AllTrim(SRA->RA_NOMECMP) )
			   If nLenStr <= 40
					@Li,011 PSAY AllTrim(SRA->RA_NOMECMP)
			   Else
			   		nY := 0
			   		nXX := 1
			   		While nLenStr > 40
			   			nY ++
	             		nX := 40 * nY
	             		@ Li,If(nY==1,011,010) Psay SubStr(SRA->RA_NOMECMP,nXX,40)
	             		SomaLinha()
	             	    nXX := nX + 1
	             	    nLenStr -= 40
	             	End
	             	If nLenStr > 0
	             		@ Li,010 Psay SubStr(SRA->RA_NOMECMP,nXX,nLenStr)
	             	EndIf
			   Endif
		   Else
			   nLenStr := Len ( AllTrim(SRA->RA_NOME)  )
			   If nLenStr <= 40
					@Li,011 PSAY AllTrim(SRA->RA_NOME)
			   Else
			   		nY := 0
			   		nXX := 1
			   		While nLenStr > 40
			   			nY ++
	             		nX := 40 * nY
	             		@ Li,If(nY==1,011,010) Psay SubStr(SRA->RA_NOME,nXX,40)
	             		SomaLinha()
	             	    nXX := nX + 1
	             	    nLenStr -= 40
	             	End
	             	If nLenStr > 0
	             		@ Li,010 Psay SubStr(SRA->RA_NOME,nXX,nLenStr)
	             	EndIf
			   Endif
		   Endif

		   dbSelectArea(cAliasTRB)
		   Do while !eof() .AND. (cAliasTRB)->MATRICULA == cMAT .AND. (cAliasTRB)->FUNCAO == cFUNC
			   Somalinha()
			   @Li,006 PSAY (cAliasTRB)->EPI

			   dbSelectArea("SB1")
			   dbSetOrder(1)
			   dbSEEK(xfilial("SB1")+(cAliasTRB)->EPI)

			   //Se o tamanho do campo do "Nome do EPI" for maior que 30, imprime conforme as medidas do relatorio grande
	           @Li,033 PSAY Left(SB1->B1_DESC,35)
	           @Li,071 PSAY iif(SB1->B1_TPEPI=="1", "OUTROS", IIF(SB1->B1_TPEPI=="2", "EPI", IIF(SB1->B1_TPEPI=="3", "EPC", "AMBOS")))
			   @Li,084 PSAY (cAliasTRB)->DATAENTR
	   		   @Li,101 PSAY (cAliasTRB)->DATADEVO
			   @Li,116 PSAY (cAliasTRB)->QTDENT PICTURE "999.99"

			   dbSelectArea("SA2")
			   dbSetOrder(1)
			   dbSEEK(xfilial("SA2")+(cAliasTRB)->FORNEC)
			   If !Empty(SA2->A2_NOME)
			   		@Li,132 PSAY Substr(Alltrim((cAliasTRB)->FORNEC) + " - " + SA2->A2_NOME,1,30)
			   Else
			   		@Li,132 PSAY (cAliasTRB)->FORNEC
			   EndIf
			   @Li,181 PSAY Alltrim((cAliasTRB)->CA)

			   dbSelectArea(cAliasTRB)
			   dbSKIP()
		   EndDo
	   Somalinha()
	   EndDo
	   Somalinha()
	EndDo

	Roda(nCntImpr,cRodaTxt,Tamanho)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve a condicao original do arquivo principal             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex("TNF")

	Set Filter To

	Set device to Screen

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()

	dbSelectArea(cAliasTRB)
	use
	dbSelectArea("TNF")
	dbSetOrder(01)

Return NIL
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ SomaLinha³ Autor ³ Inacio Luiz Kolling   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha e Controla Salto de Pagina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR810                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function Somalinha()
    Li++
    If Li > 58
        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
    EndIf
Return