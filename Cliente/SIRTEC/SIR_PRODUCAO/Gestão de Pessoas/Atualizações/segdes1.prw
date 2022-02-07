#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
#INCLUDE 'SEGDES.CH'

User Function Segdes1()        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private NSALARIO	:=0,NSALHORA	:=0,NORDEM		:=0
Private NSALMES		:=0,NSALDIA		:=0,NLUGAR		:=0
Private NVALULT		:=0,NVALPEN		:=0,NVALANT		:=0
Private NVALULTSAL	:=0,NVALPENSAL	:=0,NVALANTSAL	:=0,NX		:=0

SetPrvt("CTIT,CDESC1,CDESC2,CDESC3,CSTRING,CALIAS")
SetPrvt("AORD,WNREL,CPERG,CFILANTE,LEND,LFIRST")
SetPrvt("ARETURN,AINFO,NLASTKEY")
SetPrvt("CFILDE,CFILATE,CMATDE,CMATATE,CCOMPL")
SetPrvt("CCCDE,CCCATE,NVIAS,DDTBASE,CVERBAS,DDEMIDE,DDEMIATE")
SetPrvt("CNOME,CEND,CCEP,CUF,CFONE,CMAE,CTPINSC")
SetPrvt("CCGC,CCNAE,CPIS,CCTPS,CCTSERIE,CCTUF")
SetPrvt("CCBO,COCUP,DADMISSAO,DDEMISSAO,CSEXO,CGRINSTRU")
SetPrvt("DNASCIM,CHRSEMANA,CMAT,CFIL,CCC,CNMESES")
SetPrvt("C6SALARIOS,CINDENIZ,DDTULTSAL,DDTPENSAL,DDTANTSAL,CTIPO")
SetPrvt("CVALOR,CCPF,aCodFol, cEndCompl")


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma     ³SEGDES   ºAutor  ³Microsiga           º Data ³  10-01-02  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³Requerimento de Seguro-Desemprego - S.D.	 	 	 	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³AP6                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º			     	ATUALIZACOES OCORRIDAS	         	 	 	 	       º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºProgramador  ³Data    ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºPriscila     ³30/09/02³015780³Ajuste p/ Impressao, qdo Cal.Resc. mes se ³±±
±±º             ³        ³      ³guinte e nao foi feito o Fechamento Atual.³±±
±±º             ³        ³------³Ajuste no salto de pagina.                ³±±
±±º             ³        ³------³Acerto nos Valores dos 3 Ultimos Salarios.³±±
±±º             ³        ³------³Ajuste para posicionar correto no SRA.    ³±±
±±º             ³        ³------³Ajuste na impressao em Disco.             ³±±
±±º             ³        ³------³Validacao Impr.Rescisao somente Efetiva.  ³±±
±±ºEmerson      ³06/01/03³------³Buscar o codigo CBO no cadastro de funcoes³±±
±±º             ³        ³------³de acordo com os novos codigos CBO/2002.  ³±±
±±ºPriscila     ³15/05/03³063264³Ajuste p/ trazer correto os valores dos 3 ³±±
±±º             ³        ³      ³ultimos salarios.                         ³±±
±±ºSilvia       ³30/09/03³066800³Ajuste no calculo dos 3 ult.salario       ³±±
±±ºPedro Eloy   ³12/02/04³069232|Definicao das variaveis atribuindo o :=0  ³±±
±±ºPedro Eloy   ³02/06/04³068748|Foi tratado os valores AntPen. e Penul.   ³±± 
±±º             ³17/08/04³073442³Troca da fSomaAcl por fBuscaAcm- verifica ³±±
±±º             ³        ³------³as transf. do funcionario                 ³±±
±±º             ³13/09/04³------³Novo lay-out - Resol. 393/2004            ³±±
±±º             ³15/02/05³075395³Faz a impressao dos salarios juntamente   ³±±
±±º             ³        ³------³com as verbas incorporadas -Busca id 318  ³±±
±±ºPedro Eloy   ³13/07/05³SADVLQ³Ajuste no retorno do campo SRA->RA_SerCp  ³±±
±±º             ³        ³------³busca a serie da carteira trabalhista.    ³±±
±±º             ³29/07/05³082433³Impressao do campo telefone do Funcion.   ³±±
±±ºRicardo D.   ³05/01/06³090269³Ajuste na pesquisa do penultimo salario no³±±
±±º             ³        ³      ³caso em que a demissao ocorrer no mes se- ³±±
±±º             ³        ³      ³guinte ao mes aberto.                     ³±±
±±ºTania/Ricardo³22/02/06³092668³Acerto para impressao das verbas no acumu-³±±
±±º             ³        ³      ³lado quando em Top.                       ³±±
±±ºNatie        ³04/07/06³101533³Ajuste na impressao do cpo Endereco       ³±±
±±ºNatie        ³28/11/06³111215³Ajuste na impressao do Cep qdo nao havia  ³±±
±±º             ³        ³      ³impressao de complemento  de endereco     ³±±
±±ºPedro Eloy   ³01/06/07³126187³Tratamento na emissao do aviso indenizado.³±±
±±ºNatie        ³06/06/07³096700³Ajuste na composicao dos meses trabalhados³±±
±±ºMarcelo      ³20/01/09³155069³Conversao p/ permitir impressao em formato³±±
±±º             ³        ³      ³grafico. Inclusao das funcoes: AjustaSX e ³±±
±±º             ³        ³      ³fIncSpace.                                ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

//+--------------------------------------------------------------+
//¦ Define Variaveis Locais (Basicas)                            ¦
//+--------------------------------------------------------------+
cTit     := STR0001 // ' REQUERIMENTO DE SEGURO-DESEMPREGO - S.D. '
cDesc1   := STR0002 // 'Requerimento de Seguro-Desemprego - S.D.'
cDesc2   := STR0003 // 'Será impresso de acordo com os parametros solicitados pelo'
cDesc3   := STR0004 // 'usuario.'
cString  := 'SRA'
cAlias   := 'SRA'
aOrd     := {STR0005,STR0006}	// 'Matricula'###'Centro de Custo'
WnRel    := 'SEGDES'
cPerg    := PADR('SEGDES', len(SX1->X1_GRUPO), " ")
cFilAnte := '··'
lEnd     := .F.
lFirst   := .T.
aReturn  := { STR0007,1,STR0008,2,2,1,'',1 }	// 'Zebrado'###'Administraçäo'	
aInfo    := {}
nLastKey := 0
nLinha	 := 0
aRegs    := {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis de Acesso do Usuario                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cAcessaSRA	:= &( " { || " + ChkRH( "SEGDES" , "SRA" , "2" ) + " } " )

AjustaSX()

//+--------------------------------------------------------------+                      
//¦ Verifica as perguntas selecionadas                           ¦
//+--------------------------------------------------------------+
pergunte(PADR('SEGDES', len(SX1->X1_GRUPO), " "), .F.)
   
//+--------------------------------------------------------------+
//¦ Variaveis utilizadas para parametros                         ¦
//¦ mv_par01        //  FiLial De                                ¦
//¦ mv_par02        //  FiLial Ate                               ¦
//¦ mv_par03        //  Matricula De                             ¦
//¦ mv_par04        //  Matricula Ate                            ¦
//¦ mv_par05        //  Centro De Custo De                       ¦
//¦ mv_par06        //  Centro De Custo Ate                      ¦
//¦ mv_par07        //  Nº de Vias                               ¦
//¦ mv_par08        //  Data Base                                ¦
//¦ mv_par09        //  Verbas a serem somadas ao Salario        ¦
//¦ mv_par10        //  Compl.Verbas a somar ao Salario          ¦
//¦ mv_par11        //  Data Demissao De                         ¦
//¦ mv_par12        //  Data Demissao Ate                        ¦
//¦ mv_par13        //  1=impressao Grafica; 2=Impressao Zebrada ¦
//+--------------------------------------------------------------+
   
//+--------------------------------------------------------------+
//¦ Envia controle para a funcao SETPRINT                        ¦
//+--------------------------------------------------------------+
WnRel :=SetPrint(cString,WnRel,cPerg,cTit,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,'M')

//+--------------------------------------------------------------+
//¦ Carregando variaveis mv_par?? para Variaveis do Sistema.     ¦
//+--------------------------------------------------------------+
nOrdem  := aReturn[8]
cFilDe  := If(!Empty(mv_par01), mv_par01 ,'00')
cFilAte := If(!Empty(mv_par02), mv_par02 ,'99')
cMatDe  := If(!Empty(mv_par03), mv_par03,'00000')
cMatAte := If(!Empty(mv_par04), mv_par04,'99999')
cCCDe   := If(!Empty(mv_par05), mv_par05,'0        ')
cCCAte  := If(!Empty(mv_par06), mv_par06,'999999999')
nVias   := If(!Empty(mv_par07), If(mv_par07<=0,1,mv_par07),1)
dDtBase := If(!Empty(mv_par08), If(Empty(mv_par08),dDataBase,mv_par08),dDataBase)
cVerbas := ALLTRIM(mv_par09)
cVerbas += ALLTRIM(mv_par10)
dDemiDe  := mv_par11
dDemiAte := mv_par12
   
Private nTipoRel :=	mv_par13 // 1= impressao Grafica; 2= Impressao Zebrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos p/ Impresssao Grafica  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont10

oFont10	:= TFont():New("Arial",10,10,,.F.,100,,100,,,.F.)   
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fTransVerba()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Impressao                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! fInicia(cString)
	Return
Endif     

If nTipoRel = 1
	lFirst := .T.
	oPrint := TMSPrinter():New( STR0001 )
	oPrint:SetPortrait()
Endif	

nLinha	:= 6

RptStatus({|| fSegDes()})// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	RptStatus({|| Execute(fSegDes)})

If nTipoRel == 1
	oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir
Endif                  

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FSEGDES   ºAutor  ³Microsiga           º Data ³  10-01-02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSegDes()

Local nCont := 0
Local nX
Local nTam	:= 0 

dbSelectArea('SRA')
dbSetOrder(nOrdem)
SetRegua(RecCount())
dbSeek(cFilDe + cMatDe,.T.)

Do While !Eof()	
	//+------------------------------------------- -----------------+
	//¦ Incrementa Regua de Processamento.                           ¦
	//+--------------------------------------------------------------+
	IncRegua()

	//+--------------------------------------------------------------+
	//¦ Processa Quebra de Filial.                                   ¦
	//+--------------------------------------------------------------+
	If SRA->RA_FILIAL #cFilAnte
		If	!fInfo(@aInfo,SRA->RA_FILIAL) .or. !( Fp_CodFol(@aCodFol,Sra->Ra_Filial) )
			dbSkip()
			Loop
		Endif		
		cFilAnte := SRA->RA_FILIAL		
	Endif		
	
	//+--------------------------------------------------------------+
	//¦ Cancela Impres¦o ao se pressionar <ALT> + <A>.               ¦
	//+--------------------------------------------------------------+
	If lEnd
		@ pRow()+ 1, 00 PSAY STR0009 // ' CANCELADO PELO OPERADOR . . . '
		Exit
	EndIF
	
	//+--------------------------------------------------------------+
	//¦ Consiste Parametrizaç¦o do Intervalo de Impress¦o.           ¦
	//+--------------------------------------------------------------+
	If 	(SRA->RA_Filial < cFilDe)	.Or. (SRA->RA_FILIAL > cFilAte)	.Or.;
		(SRA->RA_MAT < cMatDe)		.Or. (SRA->RA_MAT > cMatAte)	.Or.;
		(SRA->RA_CC < cCcDe)		.Or. (SRA->RA_CC > cCCAte) 
        SRA->(dbSkip())
		Loop
	EndIf
	
	//+--------------------------------------------------------------+
	//¦ Pesquisando o Tipo de Rescisao ( Indenizada ou nao )         ¦
	//+--------------------------------------------------------------+
	cAlias := Alias()                                                            
	lAchouSrg := .F.
	dbSelectArea('SRG')     
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
		While ! EOF() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRG->RG_FILIAL+SRG->RG_MAT
			If (SRG->RG_DATADEM < dDemiDe) .Or. (SRG->RG_DATADEM > dDemiAte) .Or. SRG->RG_EFETIVA == "N"
				SRG->(dbSkip())
				Loop
			EndIf
			lAchouSrg := .T.
			Exit
		Enddo
	EndIf    
		/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Caso nao encontre o funcionario no SRG, le o proximo funcionario no SRA³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/	
	If ! lAchouSrg .OR.(SRG->RG_DATADEM < dDemiDe) .Or. (SRG->RG_DATADEM > dDemiAte) .Or. SRG->RG_EFETIVA == "N"
		dbSelectArea("SRA")
		dbSkip()
		Loop
	Endif
	

  	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
		dbSelectArea("SRA")
   		dbSkip()
  		Loop
	EndIF


	//--Carregar a descricao do tipo da rescisao		
	cIndeniz   := fPHist82(SRG->RG_Filial,'32',SRG->RG_TipoRes,32,1)
	
	//+--------------------------------------------------------------+
	//¦ Variaveis utilizadas na impressao.                           ¦
	//+--------------------------------------------------------------+
	cNome      := Left(SRA->RA_Nome,38)
	cMae       := Left(SRA->RA_Mae,38)     
	cEndCompl  := AllTrim(SRA->RA_Endereco) + '-' + AllTrim(SRA->RA_Bairro)   + '-' + AllTrim(SRA->RA_MUNICIP)   + ' ' + alltrim(SRA->RA_Complem) 
	cEnd       := Left(cEndCompl, If( nTipoRel=1, 40, 38 )) 	
	cCompl	   := If( nTipoRel=1, substr(cEndCompl,41,16) , substr(cEndCompl,39,14) )
	If Len(cCompl) < 14 
		nTam	:= 14 - Len(cCompl)
		cCompl	:= cCompl+space(nTam)
	Endif 
	cCep       := Transform(Left(SRA->RA_Cep,8),'@R #####-###')
	cUF        := Left(SRA->RA_Estado,2)
	cFone      := Left(alltrim(SRA->RA_Telefon),10)
	cTpInsc    := If(aInfo[15]==1,'2','1') //-- 1=C.G.C. 2=C.E.I.
	cCgc       := Transform(Left(aInfo[8],14),'@R ')
	cCNAE      := Left(aInfo[16],5)
	cPis       := Left(SRA->RA_Pis,11)
	cCTPS      := Left(SRA->RA_NumCp,7)
	cCTSerie   := Right(Alltrim(SRA->RA_SerCp),3)
	cCTUF      := Left(SRA->RA_UFCP,2)
	cCBO       := fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,dDtBase)
	cOcup      := DescFun(SRA->RA_CodFunc,SRA->RA_Filial)
	dAdmissao  := SRA->RA_Admissa
	dDemissao  := SRG->RG_DATADEM
	cSexo      := If(Sra->RA_Sexo=='M','1','2')
	dNascim    := SRA->RA_Nasc
	cHrSemana  := StrZero(Int(SRA->RA_HrSeman),2)
	cMat       := Left(SRA->RA_Mat,6)
	cFil       := Left(SRA->RA_Filial,2)
	cCC        := Left(SRA->RA_CC,9)
	cCpf	   := SRA->RA_CIC
	cNMeses    := fMesesTrab (SRA->RA_ADMISSA,If(Empty(SRG->RG_DTAVISO),SRG->RG_DATADEM,SRG->RG_DTAVISO))
	cNMeses	   := If (SRA->RA_MESESAN > 0,cNMeses + SRA->RA_MESESAN,CNMeses) 
	cNMeses    := If(cNMeses<=36,StrZero(cNMeses,2),'36')
	c6Salarios := If(Val(cNMeses)+SRA->RA_MesesAnt>=6,'1','2')
	
	//+--------------------------------------------------------------+
	//¦ Pesquisando o Tipo de Rescisao ( Indenizada ou nao )         ¦
	//+--------------------------------------------------------------+
	cAlias := Alias()
	dbSelectArea('SRG')
	If dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.)
		cIndeniz   := fPHist82(SRA->RA_Filial,'32',SRG->RG_TipoRes,32,1)
	Else
		cIndeniz   := ' '	
	EndIf
	dbSelectArea(cAlias)

	If cIndeniz == "I"
	   cIndeniz := "1"
	Else
	   cIndeniz := "2"
	Endif
	
	//
	cGrInstru := "1"
	If SRA->RA_GRINRAI == "10"
		cGrInstru := "1"
	Elseif SRA->RA_GRINRAI == "20"
		cGrInstru := "2"					
	Elseif SRA->RA_GRINRAI == "25"
		cGrInstru := "3"					
	Elseif SRA->RA_GRINRAI == "30"
		cGrInstru := "4"					
	Elseif SRA->RA_GRINRAI == "35"
		cGrInstru := "5"					
	Elseif SRA->RA_GRINRAI == "40"
		cGrInstru := "6"					
	Elseif SRA->RA_GRINRAI == "45"
		cGrInstru := "7"					
	Elseif SRA->RA_GRINRAI == "50"
		cGrInstru := "8"					
	Else
		cGrInstru := "9"					
	Endif

	//+--------------------------------------------------------------+
	//¦ Pesquisando os Tres Ultimos Salarios ( Datas e Valores )     ¦
	//+--------------------------------------------------------------+	
	cTipo   	:= "A"
	nSalMes		:= 0				   				//--  Incluso verbas que incorporam  ao salario 
	nVAlUlt 	:= nValPen		:= nValant		:=0
	NValUltSal	:= nValPenSal	:= nValAntSal	:=0
	dDTUltSal 	:= dDemissao						//-- Data do Ultimo Salario 

	//-- Data do Penultimo Salario.
	dDTPenSal := If(Month(dDemissao)-1#0,CtoD('01/' +StrZero(Month(dDemissao)-1,2)+'/'+Right(StrZero(Year(dDemissao),4),2)),CtoD('01/12/'+Right(StrZero(Year(dDemissao)-1,4),2)) )
	If MesAno(dDtPenSal) < MesAno(dAdmissao)
		dDTPenSal 	:= CTOD("  /  /  ")
 		nValPenSal 	:= 0.00
    Endif

	//-- Data do Antepenultimo Salario.	
	dDTAntSal := If(Month(dDtPenSal)-1#0,CtoD('01/'+StrZero(Month(dDtPenSal)-1,2)+'/'+Right(StrZero(Year(dDtPenSal),4),2)),CtoD('01/12/'+Right(StrZero(Year(dDtPenSal)-1,4),2)) )	
	If MesAno(dDtAntSal) < MesAno(dAdmissao)
		dDTAntSal 	:= CTOD("  /  /  ")
		nValAntSal 	:= 0.00
    Endif
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Busca Salario ( + verba incorporada)do Movto Acumulado                 ³  
	³Somar verbas informadas nos parametros                                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	//fSalario(@nSalario,@nSalHora,@nSalDia,@nSalMes,cTipo)
	nSalMes		:= SRG->RG_SALMES   				//--  Incluso verbas que incorporam  ao salario 
	nValUltSal 	:= nSalMes
		
	fSomaSrr(StrZero(Year(dDTUltSal),4), StrZero(Month(dDTUltSal),2), cVerbas, @nValUlt)
    //--Penultimo 
	If !Empty(dDTPenSal)              
		nValPen := fBuscaAcm(cVerbas + acodfol[318,1]  ,,dDTPenSal,dDTPenSal,"V")	//-- Salario do mes + verbas que incorporaram  ao salario
		//--Pesquisa no movimento mensal quando o mes corrente estiver aberto
		//--e nao encontrar salario nos acumulados anuais.
		If nValPen == 0 .And. MesAno(dDTPenSal) == SuperGetMv("MV_FOLMES")
			If SRC->(Dbseek(SRA->(RA_FILIAL+RA_MAT)))
				While !SRC->(eof()) .And. SRA->(RA_FILIAL+RA_MAT) == SRC->(RC_FILIAL+RC_MAT)
					If SRC->RC_PD $cVerbas + acodfol[318,1]
						nValPen += SRC->RC_VALOR
					Endif
					SRC->(dbskip())
				Enddo
			Endif
		Endif
	Endif
	//--Antepenultimo
	If !Empty(dDTAntSal)
		nValAnt := fBuscaAcm(cVerbas + acodfol[318,1]   ,,dDTAntSal,dDTAntSal,"V") 	//-- Salario do mes + verbas que incorporaram  ao salario 
	Endif
	
	//--Somar verbas informardas aos salarios
	nValUltSal += nValUlt
	nValPenSal += nValPen
	nValAntSal += nValAnt

	//+--------------------------------------------------------------+
	//¦** Inicio da Impressao do Requerimento de Seguro-Desemprego **¦
	//+--------------------------------------------------------------+	
	For Nx := 1 to nVias
		If nCont >= 2
			SetPrc(0,0)
			nLinha	:= 10
		Else
			nCont:= nCont + 1
		Endif

		If nTipoRel == 1
			fImpSegGraf(Nx)
		Else
			fImpSeg()
		EndIf			
			
		If aReturn[5] # 1
			If lFirst  
				fInicia(cString)
				nLinha	:= 10
				Pergunte(PADR("GPR30A", len(SX1->X1_GRUPO)," "),.T.)                 
				lFirst	:= If(mv_par01 = 1 ,.F. , .T. )    //  Impressao Correta ? Sim/Nao 
				If lFirst == .T.       						// Se impressao esta incorreta, zera contador para imprimir o numero de vias correto
					nx := 0 
					Loop 
				EndIf
			EndIf    
    	Endif
	Next Nx

	//+--------------------------------------------------------------+
	//¦** Final  da Impressao do Requerimento de Seguro-Desemprego **¦
	//+--------------------------------------------------------------+
	dbSelectArea("SRA")
	dbSkip()	
EndDo	

//+--------------------------------------------------------------+
//¦ Termino do Relatorio.                                        ¦
//+--------------------------------------------------------------+
dbSelectArea( 'SRA' )
RetIndex('SRA')
dbSetOrder(1)   
dbGoTop()
Set Device To Screen

If aReturn[5] == 1 .And. nTipoRel # 1
	Set Printer To
	dbCommitAll()
	OurSpool(WnRel)
Endif

MS_Flush()

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpSeg   ºAutor  ³Microsiga           º Data ³  10-01-02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao do Requerimento de Seguro-Desemprego			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSeg()
Local nColIni	:= 08
//Local	nLinha  := 5 // 4

//+--------------------------------------------------------------+
//¦** Inicio da Impressao do Requerimento de Seguro-Desemprego **¦
//+--------------------------------------------------------------+
@ nLinha, nColIni PSAY  fPluSpace( cNome ) 
nLinha	+= 3 
@ nLinha, nColIni PSAY  fPluSpace( cMae )
nLinha	+= 3 
@ nLinha, nColIni PSAY fPluSpace( cEnd )
nLinha	+= 3
@ nLinha, nColini      PSAY fPluSpace( cCompl )
@ nLinha, nColIni+ 30  PSAY fPluSpace( cCep )
@ nLinha, nColIni+ 50  PSAY fPluSpace( cUF )
@ nLinha, nColIni+ 56  PSAY fPluSpace( cFone )
nLinha	+= 3 
@ nLinha, nColIni      PSAY fPluSpace( cPIS )
@ nLinha, nColIni+ 26  PSAY fPluSpace( cCTPS ) 
@ nLinha, nColIni+ 40  PSAY fPluSpace( cCTSerie )
@ nLinha, nColIni+ 46  PSAY fPluSpace( cCTUF )
@ nLinha, nColIni+ 54  PSAY fPluSpace( cCPF )
nLinha	+= 3
@ nLinha, nColIni+ 08  PSAY fPluSpace( cTpInsc )
@ nLinha, nColIni+ 13  PSAY fPluSpace( cCgc )
//@ nLinha, nColIni+ 44  PSAY fPluSpace( cCNAE )
// JULIO ALMEIDA - inclusao carimbo CGC
@ nLinha, nColIni+ 44  PSAY fPluSpace( cCNAE )  + '      ' + chr(15) + Transform(AllTRIM(aInfo[8]),'@R ##.###.###/####-##') + chr(18)
nLinha	+= 1
@ nLinha, nColIni+ 57  PSAY chr(15) + aInfo[3]+ chr(18)
nLinha	+= 1
@ nLinha, nColIni+ 57  PSAY chr(15) + RTrim(aInfo[4]) + Space(1) + '-' + Space(1) + RTrim(aInfo[13]) + chr(18)
nLinha	+= 1
//nLinha	+= 3
@ nLinha, nColIni      PSAY fPluSpace( cCBO )
//@ nLinha, nColIni+ 14  PSAY cOcup 
@ nLinha, nColIni+ 14  PSAY cOcup  + Space(23) +  chr(15) + RTRIM(aInfo[5]) + '/' + aInfo[6] + Space(1) + '-' + Space(1) + Transform(Left(aInfo[7],8),'@R #####-###') + chr(18)
//
nLinha	+= 6
@ nLinha, nColIni     PSAY fPluSpace( StrZero(Day(dAdmissao),2) ) + fPluSpace( StrZero(Month(dAdmissao),2) )+ fPluSpace( Right(StrZero(Year(dAdmissao),4),2))
@ nLinha, nColIni+ 15 PSAY fPluSpace( StrZero(Day(dDemissao),2) ) + fPluSpace( StrZero(Month(dDemissao),2) )+ fPluSpace( Right(StrZero(Year(dDemissao),4),2))
@ nLinha, nColIni+ 38 PSAY fPluSpace( cSexo )
@ nLinha, nColIni+ 50 PSAY fPluSpace( cGrInstru )
@ nLinha, nColIni+ 55 PSAY fPluSpace( StrZero(Day(dNascim),2) )+ fPluSpace( StrZero(Month(dNascim),2)) + fPluSpace( Right(StrZero(Year(dNascim),4),2))
@ nLinha, nColIni+ 70 PSAY fPluSpace( cHrSemana )
nLinha	+= 3
@ nLinha, nColIni     PSAY fPluSpace( StrZero(Month(dDtAntSal),2))
@ nLinha, nColIni+ 05 PSAY fPluSpace( Transform(nValAntSal*100,'@E 9999999999' ))
@ nLinha, nColIni+ 25 PSAY fPluSpace( StrZero(Month(dDtPenSal),2) )
@ nLinha, nColIni+ 30 PSAY fPluSpace( Transform(nValPenSal*100,'@E 9999999999'))
@ nLinha, nColIni+ 51 PSAY fPluSpace( StrZero(Month(dDtUltSal),2) )
@ nLinha, nColIni+ 56 PSAY fPluSpace( Transform(nValUltSal*100,'@E 9999999999'))
nLinha	+= 3
@ nLinha, nColIni     PSAY fPluSpace( Transform( ( nValAntSal+nValPenSal+nValUltSal) *100,'@E 9999999999'))
@ nLinha, nColIni+ 72 PSAY fPluSpace( cNMeses  )
nLinha	+= 3
@ nLinha, nColIni+ 20 PSAY fPluSpace( c6Salarios)
@ nLinha, nColIni+ 39 PSAY fPluSpace( cIndeniz  )
nLinha	+= 15
@ nLinha, nColIni PSAY fPluSpace( cPis )
nLinha	+= 3
@ nLinha, nColIni PSAY fPluSpace( cNome )
nLinha	+= 3
@ nLinha, nColIni+ 10 PSAY aInfo[3]
nLinha	+= 6
@ nLinha, 00 PSAY ' '

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fSomaSRR  ºAutor  ³Microsiga           º Data ³  10-01-02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Soma Verbas do arquivo SRR								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌParametros³ CAno 	-Ano do ultimo salario                            º±±
±±º          ³ CMes 	-Mes do ultimo salario                            º±±
±±º          ³ CVerbas  -Verbas a serem somada                            º±±
±±º          ³ nValor   -Valor das verbas                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
static Function fSomaSrr(cAno, cMes, cVerbas, nValor)

Local lRet    := .T.
Local cPesq   := ''
Local cFilSRR := If(Empty(xFilial('SRR')),xFilial('SRR'),SRA->RA_FILIAL)
Local dDtGerar:= ctod('  /  /  ')	

//-- Reinicializa Variaveis
cAno    := If(Empty(cAno),StrZero(Year(dDTUltSal),4),cAno)
cMes    := If(Empty(cMes),StrZero(Month(dDTUltSal),2),cMes)
cVerbas := If(Empty(cVerbas),'',AllTrim(cVerbas))
nValor  := If(Empty(nValUlt).Or.ValType(nValUlt)#'N',0,nValUlt)

Begin Sequence

	If Empty(cVerbas) .Or. Len(cVerbas) < 3 .Or. ;
		!SRR->(dbSeek((cPesq := cFilSRR + SRA->RA_MAT +'R'+ cAno + cMes), .T.))
		lRet := .F.
		Break
	EndIf


	dbSelectarea('SRG')
	If dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.)
		dDtGerar := SRG->RG_DTGERAR
		dbSelectArea("SRR")
		dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.)
		While !EOF() .And. RR_FILIAL+RR_MAT == cFil+cMat
			If dDtGerar == SRR->RR_DATA
				If SRR->RR_PD $ cVerbas
					If PosSrv(SRR->RR_PD,SRR->RR_FILIAL,"RV_TIPOCOD") $ "1*3"
				  		nValor += SRR->RR_VALOR
					Else
						nValor -= SRR->RR_VALOR
					EndIf
				Endif
			EndIf
			SRR->(DbSkip())
		Enddo	
	EndIf

	If nValor == 0
		lRet := .F.
		Break
	EndIf

End Sequence
dbSelectArea('SRA')
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fInicia   ºAutor  ³R.H.Natie           º Data ³  11/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa Impressao                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fInicia(cString)

//--Lendo os Driver's de Impressora e gravando no Array--// 
MS_Flush()
aDriver := ReadDriver()
If nLastKey == 27
	Return .F.
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return  .F. 
Endif
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fTransVerbaºAutor ³R.H.                º Data ³  17/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  fTransVerba()
Local cPD	:= ""
Local nX	:= 0

For nX := 1 to Len(cVerbas) step 3 
	cPD += Subs(cVerbas,nX,3)
	cPD += "/" 
Next nX

cVerbas:= cPD

Return( )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fPluSpace ºAutor  ³R.H.                º Data ³  14/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  fPluSpace( cDet )
Local cDetF :=""
Local nX	:= 0

For nX := 1 to Len(cDet)
	cDetF += Subs(cDet,nX,1) + space(1)
Next nX    

Return(cDetF)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpSegGraf ºAutor  ³Microsiga           º Data ³ 10-01-09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao GRAFICA do Requerimento de Seguro-Desemprego     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSegGraf( nNumVias )

//Local nLinha   := 310
//Local nColun   := 150  
Local nLinha   := 330
Local nColun   := 50  
Local nTresSal := 0
Local cDtAdmis := ""
Local cDtDemis := ""
Local cDtNasci := ""

oPrint:StartPage() //Inicia uma nova pagina

oPrint:say( nLinha, nColun, fIncSpace(cNome), oFont10, 100 ) //Nome
nLinha += 150

oPrint:say( nLinha, nColun, fIncSpace(cMae),  oFont10, 100 ) //Nome da Mae
nLinha += 150

oPrint:say( nLinha, nColun, fIncSpace(cEnd),  oFont10, 100 ) //Endereco
nLinha += 150
                                                                       
oPrint:say( nLinha, nColun,      fIncSpace(cCompl), oFont10, 100 ) //Complemento endereco
oPrint:say( nLinha, nColun+0900, fIncSpace(cCep),   oFont10, 100 ) //CEP
oPrint:say( nLinha, nColun+1450, fIncSpace(cUF),    oFont10, 100 ) //UF
oPrint:say( nLinha, nColun+1600, fIncSpace(cFone),  oFont10, 100 ) //Telefone
nLinha += 150
                                                                     
oPrint:say( nLinha, nColun,      fIncSpace(cPIS ),    oFont10, 100 ) //Pis
oPrint:say( nLinha, nColun+0730, fIncSpace(cCTPS),    oFont10, 100 ) //CTPS
oPrint:say( nLinha, nColun+1130, fIncSpace(cCTSerie), oFont10, 100 ) //Serie CTPS
oPrint:say( nLinha, nColun+1270, fIncSpace(cCTUF),    oFont10, 100 ) //UF CTPS
oPrint:say( nLinha, nColun+1550, fIncSpace(cCPF),     oFont10, 100 ) //CPF
nLinha += 200        

oPrint:say( nLinha, nColun+0250, fIncSpace(cTpInsc), oFont10, 100 ) //Tipo Inscricao
oPrint:say( nLinha, nColun+0370, fIncSpace(cCgc),    oFont10, 100 ) //CNPJ/CEI
oPrint:say( nLinha, nColun+1230, fIncSpace(cCNAE),   oFont10, 100 ) //Atividade economia
// Inclusao Carimbo CNPJ
oPrint:say( nLinha, nColun+1530, '      ' + Transform(AllTRIM(aInfo[8]),'@R ##.###.###/####-##'),   oFont10, 100 ) //Carimbo CNPJ - CNPJ
nLinha += 50
oPrint:say( nLinha, nColun+1530, aInfo[3],   oFont10, 100 )  //Carimbo CNPJ - Nome Empresa
nLinha += 50
oPrint:say( nLinha, nColun+1530, RTrim(aInfo[4]) + Space(1) + '-' + Space(1) + RTrim(aInfo[13]),   oFont10, 100 )  //Carimbo CNPJ - Endereco
nLinha += 50
oPrint:say( nLinha, nColun+1530, RTRIM(aInfo[5]) + '/' + aInfo[6] + Space(1) + '-' + Space(1) + Transform(Left(aInfo[7],8),'@R #####-###'),   oFont10, 100 )  //Carimbo CNPJ - Endereco
nLinha += 20       

oPrint:say( nLinha, nColun,      fIncSpace( Transform(cCBO,'@R 99999 9'),  oFont10, 100 ) ) //CBO
oPrint:say( nLinha, nColun+0370, fIncSpace(cOcup), oFont10, 100 ) //Ocupacao
nLinha += 220  

cDtAdmis := StrZero(Day(dAdmissao),2) + StrZero(Month(dAdmissao),2) + Right(StrZero(Year(dAdmissao),4),2)
cDtDemis := StrZero(Day(dDemissao),2) + StrZero(Month(dDemissao),2) + Right(StrZero(Year(dDemissao),4),2)
cDtNasci := StrZero(Day(dNascim),2)   + StrZero(Month(dNascim),2)   + Right(StrZero(Year(dNascim),4),2)

oPrint:say( nLinha, nColun,      fIncSpace(cDtAdmis),  oFont10, 100 ) //Data admissao
oPrint:say( nLinha, nColun+0430, fIncSpace(cDtDemis),  oFont10, 100 ) //Data dispensa
oPrint:say( nLinha, nColun+1075, fIncSpace(cSexo),     oFont10, 100 ) //Sexo
oPrint:say( nLinha, nColun+1340, fIncSpace(cGrInstru), oFont10, 100 ) //Grau de instrucao
oPrint:say( nLinha, nColun+1480, fIncSpace(cDtNasci),  oFont10, 100 ) //Data nascimento
oPrint:say( nLinha, nColun+1910, fIncSpace(cHrSemana), oFont10, 100 ) //Horas trabalhadas por semana
nLinha += 160

oPrint:say( nLinha, nColun,      fIncSpace ( StrZero(Month(dDtAntSal),2) ) )  				 	//Mes antepenultimo salario
oPrint:say( nLinha, nColun+0150, fIncSpace ( Transform(nValAntSal*100,'@E 9999999999') ) )		//Antepenultimo salario
oPrint:say( nLinha, nColun+0720, fIncSpace ( StrZero(Month(dDtPenSal),2)))						//Mes penultimo salario
oPrint:say( nLinha, nColun+0870, fIncSpace ( Transform(nValPenSal*100,'@E 9999999999') ) )		//Penultimo salario
oPrint:say( nLinha, nColun+1450, fIncSpace ( StrZero(Month(dDtUltSal),2)))						//Mes ultimo salario
oPrint:say( nLinha, nColun+1610, fIncSpace ( Transform(nValUltSal*100,'@E 9999999999') ) )		//Ultimo salario
nLinha += 150  

nTresSal := Transform( ( nValAntSal+nValPenSal+nValUltSal) *100,'@E 9999999999') 

oPrint:say( nLinha, nColun,      fIncSpace (nTresSal), oFont10, 100 ) //Soma 3 ultimos salarios
oPrint:say( nLinha, nColun+2020, fIncSpace (cNMeses),  oFont10, 100 ) //Qtd meses com vinculo ultimos 36 meses
nLinha += 150  

oPrint:say( nLinha, nColun+0470, fIncSpace(c6Salarios), oFont10, 100 ) //Recebeu ultimos 6 meses
oPrint:say( nLinha, nColun+1115, fIncSpace(cIndeniz),   oFont10, 100 ) //Aviso previo indenizado
nLinha += 825  
                
//If nNumVias == 2      
	oPrint:say( nLinha, nColun-50, fIncSpace(cPis),  oFont10, 100 ) //Pis 2o. Via
	nLinha += 100  
	
	oPrint:say( nLinha, nColun-50, fIncSpace(cNome), oFont10, 100 ) //Nome 2o. Via
	nLinha += 100  
	
	oPrint:say( nLinha, nColun-50, fIncSpace(aInfo[3]), oFont10, 100 ) //Nome da Empresa 2o. Via
	
//EndIf

oPrint:EndPage() //Finaliza a pagina

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fIncSpace ºAutor  ³Microsiga           º Data ³  10-01-09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento dos espacos para impressao no formato grafico   º±±
±±º          ³ fonte Arial 10                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fIncSpace( cTexto )

	Local cTextoFim := ""
	Local nPos 		:= 1
	Local i 		:= 1  

	nQtdLetras := Len( cTexto )
	
	For i := 1 To nQtdLetras
		If Upper( SubStr( cTexto, nPos, 1 ) ) $ "I|-|1" 
			cTextoFim += Space(1)
			cTextoFim += SubStr( cTexto, nPos, 1 ) + Space(4)
		ElseIf Upper( SubStr( cTexto, nPos, 1 ) ) $ "1" 
			cTextoFim += Space(1)
			cTextoFim += SubStr( cTexto, nPos, 1 ) + Space(3)
		ElseIf Upper( SubStr( cTexto, nPos, 1 ) ) $ "O|C|Q" 
			cTextoFim += SubStr( cTexto, nPos, 1 ) + Space(2)			
		ElseIf Upper( SubStr( cTexto, nPos, 1 ) ) == " " 
			cTextoFim += Space(5)
		Else	
			cTextoFim += SubStr( cTexto, nPos, 1 ) + Space(3)
		EndIf
		nPos++
	Next i		

Return(cTextoFim)
                       

     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX  ºAutor  ³Microsiga           º Data ³  10-01-09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta dicionario de dados                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX()

Local aArea     := getArea()
Local cPerg		:= padr("SEGDES", LEN(SX1->X1_GRUPO), " ") 
Local cHelp 	:= ".GPRPPP19." 

Aadd(aRegs,{cPerg, "13", "Tipo de Impressao ?", "¿Tipo de Impressao ?", "Tipo de Impressao ?", "MV_CHD", "N", 1, 0, 2, "C", "", "MV_PAR13", "Grafico", "Grafico", "Grafico", "", "", "Zebrado", "Zebrado", "Zebrado", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", , , , cHelp} )
ValidPerg( aRegs, cPerg, .T. )

RestArea( aArea )

Return
