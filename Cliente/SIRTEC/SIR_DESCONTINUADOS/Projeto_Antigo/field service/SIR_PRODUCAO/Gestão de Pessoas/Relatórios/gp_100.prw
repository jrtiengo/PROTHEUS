#INCLUDE "GPER100.CH"
#INCLUDE "PROTHEUS.CH"
/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER100  ³ Autor ³ R.H. - Ze Maria         ³ Data ³ 03.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio por Codigos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER100(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marinaldo  ³ 27/07/00 ³------³ Retirada Dos, Validacao Filial/Acesso   e³±±
±±³            ³ -------- ³------³ PosSrv() para Tipo de Verba.             ³±±
±±³Emerson G.R.³ 30/05/01 ³------³ Config. Tamanho do Rel. de acordo com o  ³±±
±±³            ³ 		  ³      ³ numero de codigos que ira listar.        ³±±
±±³Mauro       ³ 13/08/01 ³------³ Acerto nas totalizacoes 	                ³±±
±±³Andreia     ³ 12/11/01 ³010375³ Inclusao da perg. "Lista total empresa"  ³±±
±±³Andreia     ³ 13/11/01 ³010955³ Nao imprimir linha de Total Liquido(mode-³±±
±±³            ³          ³------³ lo vertical) quando valor estiver zerado.³±±
±±³Silvia      ³ 04/03/02 ³------³ Ajustes na Picture para Localizacoes    .³±±
±±³Priscila    ³ 15/04/02 ³012959³ Ajustes no Total Liquido da impressao no ³±±
±±³            ³          ³      ³ Modo Horizontal.                         ³±±
±±³Priscila    ³ 10/04/02 ³014458³ Alteracao na perg. Semana, onde o sistema³±±
±±³            ³          ³      ³ devera imprimir todas as semanas qdo sele³±±
±±³            ³          ³      ³ cionado 99 no parametro.                 ³±±
±±³Mauro       ³ 25/11/02 ³------³ Qdo.Solic.Verba de Desc.+Liq.nao Imprimia³±±
±±³Pedro Eloy  ³ 22/03/04 ³070293³ Ajuste do nChar de 18 para 15 comprimido ³±±
±±³Pedro Eloy  ³ 07/04/04 ³068973³ Ajuste da col.do relatorio quando horiz. ³±±
±±³Pedro Eloy  ³ 16/04/04 ³070232³ Acerto na descricao do Centro de Custo.  ³±±
±±³Ricardo D.  ³ 19/01/05 ³073612³ Ajuste para nao totalizar o salario base ³±±
±±³            ³          ³------³ junto com as verbas impressas.           ³±±
±±³Natie       ³ 17/06/05 ³081033³ Reposiciona impressao totais da fil e Emp³±±
±±³Tania       ³14/02/2006³092240³ Ajuste posicionamento das colunas quando ³±±
±±³            ³ -------- ³------³ selecionado relatorio Horizontal, tanto  ³±±
±±³            ³ -------- ³------³ para impressao de valores, como horas.   ³±±
±±³Tania       ³13/03/2006³093683³ Passa a permitir a impressao das colunas ³±±
±±³            ³ 		  ³      ³ de Liquido e Total no mesmo relatorio.   ³±±
±±³Tania       ³03/04/2006³093683³ Acerto na string de Total Liquido no ca- ³±±
±±³            ³          ³      ³ becalho horizontal.                      ³±±
±±³Tania       ³24/04/2006³096638³ Incluido cod.verba quando emitido em hrs.³±±
±±³            ³ 		  ³      ³ Aumentada descricao em 1 posicao.        ³±±
±±³Andreia     ³24/07/2006³102478³ Ajuste para imprimir corretamente o total³±±
±±³            ³ 		  ³      ³ Liquido quando a impressao for vertical. ³±±
±±³Pedro Eloy  ³24/04/2007³085733³ Feito o salto da pagina por centro custo.³±±
±±³Natie       ³19/03/07  ³118490³ Ajuste na impressão das linhas que sepa- ³±±
±±³            ³ 		  ³      ³ ram os vlrs dos totais das filiais-estava³±±
±±³            ³ 		  ³      ³ imprimindo linhas p/filiais sem total    ³±±
±±³            ³ 		  ³      ³ Padronizar pergunta/ajuste helps mv_par23³±±
±±³Valdeci L.  ³15/08/07  ³127967³Correcao filtro contr. acesso usuario com ³±±
±±³			   ³          ³      ³a funcao ffiltro                          ³±±
±±³Reginaldo   ³21/08/09  ³20257 ³Ajuste da filial de 2 para 4 DIGITOS      ³±± 
±±³Raquel Hager³07/03/12  ³003939³Criacao de funcao AjustSx1 para inclusao  ³±± 
±±³        	   ³          ³  2012³da opcao 'Nao' no param MV_CHN no grupo   ³±± 
±±³        	   ³          ³      ³de perguntas GPR100.                      ³±± 
±±³Luis Artuso ³18/10/2012³025562³Ajuste para validar qual filtro sera uti- ³±±
±±³			   ³		  ³  2012³lizado na geracao de relatorio			³±±
±±³			   ³		  ³TFXGIP³                                          ³±±
±±³Mauricio MR ³04/01/2013³032479³Ajuste p/tornar dinamico o dimensionamento³±±
±±³			   ³		  ³  2012³das colunas a serem impressas permitindo a³±±
±±³			   ³		  ³TGILHR³exibicao do nome do empregado por completo³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User function GP_100()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cDesc1 := "Relatorio por Codigo"
LOCAL cDesc2 := "Ser  impresso de acordo com os parametros solicitados pelo"
LOCAL cDesc3 := "usuario."
LOCAL cString:= "SRA"       	// alias do arquivo principal (Base)
LOCAL aOrd   :={"Matricula","Centro de Custo","Nome"}	//"Matricula"###"Centro de Custo"###"Nome"
Local cSize	 := "G"      
Local nFor    
Local nY	 := 0 
Local cDescVerb:= ''  
Local nPict1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVATE(Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn := {"Zebrado", 1,"Administra", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
PRIVATE nomeprog:="GP_100"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="GP_100"
PRIVATE aAC := {"Abandona","Confirma"}		//"Abandona"###"Confirma"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVATE(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nOrdem
PRIVATE aInfo	:={}
PRIVATE aTotais:={ } 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel para tratamento do tamanho das culnas/dados         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCab1		:= {}
Private aTam1		:= {} 
Private aTam2		:= {} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Vetor de Totalizacao Generico 1 Coluna = CODIGO                    ³
//³                              2 Coluna = Total Horas do Funcionario³
//³                              3 Coluna = Total Valor do Funcionario³
//³                              4 Coluna = Total Horas Centro Custo  ³
//³      aTotais                 5 Coluna = Total Valor Centro Custo  ³
//³                              6 Coluna = Total Horas Filial        ³
//³                              7 Coluna = Total Valor Filial        ³
//³                              8 Coluna = Total Geral Horas         ³
//³                              9 Coluna = Total Geral Valor         ³
//³                             10 Coluna = Proventos/Base(-)Descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE titulo
PRIVATE AT_PRG := "GPER100"
PRIVATE wCabec0
PRIVATE wCabec1
PRIVATE wCabec2
PRIVATE CONTFL   := 1
PRIVATE LI       := 0
PRIVATE COLUNAS  := 220
PRIVATE nTamanho := "G"
PRIVATE nChar	 := 15
Private cPict1	:=	If (MsDecimais(1)==2,"@E 99,999,999,999.99",TM(99999999999,17,MsDecimais(1)))  // "@E 99,999,999,999.99
Private lImprRel	:=	.T.  
Private nTamNome	:= TamSX3("RA_NOME"	)[01] 
 
nPict1	:= Len(Substr(cPict1,4))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajuste no Grupo de Perguntas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
AjustSx1()

pergunte("GPR100",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTit   := "VALORES POR CODIGO "
wnrel:="GP_100"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,"GP_100",@cTit,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial  De                               ³
//³ mv_par02        //  Filial  Ate                              ³
//³ mv_par03        //  Centro de Custo De                       ³
//³ mv_par04        //  Centro de Custo Ate                      ³
//³ mv_par05        //  Matricula De                             ³
//³ mv_par06        //  Matricula Ate                            ³
//³ mv_par07        //  Nome De                                  ³
//³ mv_par08        //  Nome Ate                                 ³
//³ mv_par09        //  Folha / 2¦ / Valores Extras              ³
//³ mv_par10        //  Numero da Semana                         ³
//³ mv_par11        //  Formato Vertical / Horizontal            ³
//³ mv_par12        //  Listar Horas / Valores                   ³
//³ mv_par13        //  Relatorio Analitico ou Sintetica         ³
//³ mv_par14        //  Se lista todos os codigos encontrados    ³
//³ mv_par15        //  Lista Salario do Cadastro ?              ³
//³ mv_par16        //  Cria String com Situacao do Funcionario  ³
//³ mv_par17        //  Cria String contendo Categorias          ³
//³ mv_par18        //  Codigos a Listar                         ³
//³ mv_par19        //  Cont. Codigos a Listar                   ³
//³ mv_par20        //  Imprimir Totais                          ³
//³ mv_par21        //  Imprimir Liquidos                        ³
//³ mv_par22        //  Imprimir Total da Empresa                ³
//³ mv_par23        //  Imprime C.C em outra Pagina              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FilialDe  := mv_par01
FilialAte := mv_par02
CcDe      := mv_par03
CcAte     := mv_par04
MatDe     := mv_par05
MatAte    := mv_par06
NomDe     := mv_par07
NomAte    := mv_par08
nRelat    := mv_par09
cSemana   := mv_par10
nVerHor   := If(mv_par14=1,1,mv_par11)
nValHor   := mv_par12
nSinAna   := mv_par13
lTodos    := If(mv_par14=1,.T.,.F.)
lSalario  := If(mv_par15=1,.T.,.F.)
cSituacao := mv_par16
cCategoria:= mv_par17
cCodigos  := ALLTRIM(mv_par18)
cCodigos  += ALLTRIM(mv_par19)
lTotais   := If(mv_par20=1,.T.,.F.)
lLiquido  := If(mv_par21=1,.T.,.F.)
lImpEmpr  := If(mv_par22=1,.T.,.F.)
nSaltaCC  := mv_par23

cDesc		:= " "
cDescr1		:= " "
cDescr2		:= " "
nDesc		:= 0

If	nLastKey = 27
	Return
Endif

// Cria no vetor de totalizacao, as verbas solicitadas
If !Empty(cCodigos)
	For nFor := 1 To Len(ALLTRIM(cCodigos)) Step 3
		cVerba := Subs(cCodigos,nFor,3)
		Aadd(aTotais,{cVerba,0,0,0,0,0,0,0,0,0,0})
	Next nFor
	If nVerHor = 2 .And. lLiquido 
		Aadd(aTotais,{"LIQ",0,0,0,0,0,0,0,0,0,0})
	Endif	             
	If nVerHor = 2 .And. lTotais
		Aadd(aTotais,{"TOT",0,0,0,0,0,0,0,0,0,0})
	Endif	             
	
Endif

// Verifica se foi solicitado o salario do cadastro
If lSalario
	Aadd(aTotais,{" SB",0,0,0,0,0,0,0,0,0,0})
Endif
       

//--Permite listar 10 Verbas se a opcao de listar Liquido nao for selecionada//
If  nVerHor = 2 .And. !lLiquido .And. !lTotais
	If Len(aTotais) > 10 .AND. nValHor  = 1
		Help(" ",1,"R100MAIO8")
		Return
	ElseIf Len(aTotais) > 15 .AND. nValHor = 2
		Help(" ",1,"R100MAIO15")
		Return
	Endif                               
	If (Len(aTotais) > 4 .AND. nValHor = 1) .OR. (Len(aTotais) > 6 .AND. nValHor = 2)
		cSize   	:= "G"
        aReturn[4]	:= 2
		nTamanho   	:= "G"
		COLUNAS    	:= 220
        nChar		:= 15
	EndIf  

Elseif nVerHor # 2
	cSize   	:= "M"
	nTamanho	:= "M"
	COLUNAS    	:= 132
    nChar		:= 15
    aReturn[4]	:= 1
Endif


If nVerHor = 2 .and. nValHor = 1
	IF Len(aTotais) > 9
		nTamNome:= 20
	Endif	
Endif

//--Permite listar 9 Verbas se Selecionada a opcao de listar Liquido e Salario Base//
If nVerHor = 2 .And. (lLiquido .Or. lTotais)
	If Len(aTotais) > 10 .AND. nValHor  = 1
        Aviso("Atencao","Nao e possivel listar mais do que 7 Codigos na Horizontal,quando os mesmos forem solicitados em valores e solicitada a impressao do Total Liquido ou Salario Base",{"ok"})
		Return
	ElseIf Len(aTotais) > 15 .AND. nValHor = 2
		Help(" ",1,"R100MAIO15")
		Return
	Endif
	If (Len(aTotais) > 4 .AND. nValHor = 1) .OR. (Len(aTotais) > 6 .AND. nValHor = 2)
		cSize   	:= "G"
        aReturn[4]	:= 2
		nTamanho   	:= "G"
		COLUNAS    	:= 220
        nChar		:= 15
	EndIf
	
Elseif nVerHor # 2
	cSize   	:= "M"
	nTamanho	:= "M"
	COLUNAS    	:= 132
    nChar		:= 15
    aReturn[4]	:= 1
Endif


//TITULO := 	STR0012+IIf(mv_par09==1,STR0013,;								//'VALORES POR CODIGO '###'DA FOLHA '
//			IIf(mv_par09 == 2,STR0014,STR0015))+"  "+IIf (cSemana # Space(2),STR0037+" : " +cSemana,"") + ;
//			IIf(nValHor=1 .or. (nVerHor = 1)," - "+ Alltrim(STR0021)," - "+ Alltrim(STR0022) ) ;
//				+STR0033+aOrd[ aReturn[8] ]+" )"	//'DA 2a. PARCELA 13o. SAL.'###"DE VALORES EXTRAS"###"    ( Ordem: "

wCabec0 := 2
If nVerHor = 1
   	AADD(aCab1,"FI") //"FI"                   	01
	AADD(aCab1,"C.CUSTO") //"C.CUSTO"   				02
	AADD(aCab1,"MATR.") //"MATR."                	03
	AADD(aCab1,"NOME") //"NOME"   				04
	AADD(aCab1,"COD.DESCRIÇÃO") //"CÓD.DESCRIÇÃO"     		05
	AADD(aCab1,Space(1)) //"DESCRIÇÃO"     			06 // *** Artificio para reservar a posicao da descricacao da verba.NAO RETIRAR. ***
	AADD(aCab1,"HORAS") //"HORAS"               	07
	AADD(aCab1,"V A L O R") //"V A L O R"             	08
	
	AADD(aTam1, Max(Len(aCab1[01] )		,TamSX3("RA_FILIAL"	)[01] 			))//01
	AADD(aTam1, Max(Len(aCab1[02] )		,TamSX3("RA_CC"		)[01] 			))//02
	AADD(aTam1, Max(Len(aCab1[03] )		,TamSX3("RA_MAT"	)[01] 			))//03
	AADD(aTam1, Max(Len(aCab1[04] )		,TamSX3("RA_NOME"	)[01] 			))//04
	AADD(aTam1, Max(Len(aCab1[05] )		,TamSX3("RC_PD"		)[01] + 1 + 15	))//05  //Codigo + Decricao da Verba
	AADD(aTam1, Max(Len(aCab1[05] )		, 15								))//06  //Apenas Descricao da verba
//	AADD(aTam1, Max(Len(aCab1[05] )		,TamSX3("RC_PD"		)[01] + Space(1)+TamSX3("RC_DESCPD"	)[01] 	) ) //05

	AADD(aTam1, Max( Len(aCab1[07]), 9  								))//07
	AADD(aTam1, Max( Len(aCab1[08]), nPict1    						))//08
    
                               
	nY:=aTam1[01] + 2 + aTam1[02] + 2 +aTam1[03]+ 1 + aTam1[04] + 2
	AADD(aTam1,nY)

	wCabec1 	:= Space(nY)+'|- PROVENTO/DESCONTO -|'
	wCabec2  :=   ;
	  				PADR(aCab1[01]							,aTam1[01])				+ SPACE(2)	+;//"FI"
					PADR(aCab1[02]							,aTam1[02])				+ SPACE(2)	+;//"C.CUSTO" 
	  				PADR(aCab1[03]							,aTam1[03])				+ SPACE(1)	+;//"MATR."#
	  				PADR(aCab1[04]							,aTam1[04])				+ SPACE(2)	+;//"NOME"
					PADR(aCab1[05]							,aTam1[05])				+ SPACE(2)	+;//"CÓD.DESCRIÇÃO"
					PADl(aCab1[07]							,aTam1[07])				+ SPACE(2)	+;//"HORAS" 
					PADl(aCab1[08]							,aTam1[08])    		 	  			  //"V A L O R"   
		
Else
	AADD(aCab1,"FI") //"FI"                   	01
	AADD(aCab1,"MATR.") //"MATR."                	03
	AADD(aCab1,"NOME") //"NOME"   				04
		
	AADD(aTam1, Max(Len(aCab1[01] )		,TamSX3("RA_FILIAL"	)[01] 	) )                    	//01
	AADD(aTam1, Max(Len(aCab1[02] )		,TamSX3("RA_MAT"	)[01] 	) )                    	//02
	AADD(aTam1, Max(Len(aCab1[03] )		,nTamNome					) ) 					//03
	
	
	aTotais := aSort(aTotais,,,{ |x,y| x[1] < y[1] })
    
  
 	wCabec1   :=  PADR(aCab1[01],aTam1[01]) + SPACE(1) +;//"FI"
	  			  PADR(aCab1[02],aTam1[02]) + SPACE(1) +;//"MATR."
				  PADR(aCab1[03],aTam1[03]) + SPACE(1)   //"NOME"
				  

	wCabec2 := space(Len(wCabec1))  	//"   		
	Aeval(aTam1,{|X| nY+=x },1,3 )
	nY+=1*(Len(aTam1)) 
   //-- Tamanho da parte fixa do cabecalho
	AADD(aTam1,nY  )
	
	
	For nFor := 1 To Len(aTotais)                           
        If nValHor=1
			IF aTotais[nFor,1]= "LIQ"
				cDescVerb:= "TOTAL LIQUIDO"
			ElseIf aTotais[nFor,1]= "TOT"
				   cDescVerb:= STR0023  
            ElseIf aTotais[nFor,1]= " SB"
					cDescVerb:= "SAL. BASE"  
            Else //Verbas Selecionados pelo usuario              
             	cDescVerb:= aTotais[nFor,1]+"-"+ Substr(Alltrim(fdesc("SRV",aTotais[nFor,1], "RV_DESC")),1,13) 
            Endif   

          	cDescVerb:=Padl(cDescVerb, Max(Len(cDescVerb), nPict1)) //Demais colunas (Verbas ou Liq ou Tot)
			AADD(aTam2, Len(cDescVerb)) //Demais colunas (Verbas ou Liq ou Tot)	  
	
			WCabec1 += cDescVerb + Space(1)
		
		Else
			If aTotais[nFor,1] == " SB"
				cDesc 	:= "SAL. BASE"  
			ElseIf aTotais[nFor,1] == "LIQ"
				cDesc	:= "TOTAL LIQUIDO"
			ElseIf aTotais[nFor,1] == "TOT"
				cDesc	:= STR0023
			Else
				cDesc	:= aTotais[nFor,1]+"-"+ Substr(Alltrim(fdesc("SRV",aTotais[nFor,1], "RV_DESC")),1,20) 
				cDesc	:= StrTran(cDesc,"BASE ","BS.")
				cDesc	:= StrTran(cDesc,"HORAS ","HS.")
				cDesc	:= StrTran(cDesc,"HORA EXTRA","HE.")
			EndIf 
			
			nDesc	:= At(" ",cDesc)
			cDescr2	:= " "
			If aTotais[nFor,1] == "TOT"
				cDescr1		:= cDesc
			Else
				nDesc		:= iif(nDesc<1,9,nDesc) 
				cDescr1		:= Alltrim(Substr(cDesc,1,iif(nDesc>9,9,iif(nDesc<1,9,nDesc))))
				cDescr2		:= iif(nDesc>0,Alltrim(Substr(cDesc,nDesc+1,9)),"")
			Endif			
			
			
			cDescr1		:=Padl(cDescr1, Max( Len(cDescr1), 9  )) //Demais colunas (Verbas ou Liq ou Tot)
			cDescr2		:=Padl(cDescr2, Max(Max( Len(cDescr2), 9 ),Len(cDescr1))) //Demais colunas (Verbas ou Liq ou Tot)
			
			WCabec1 	+= cDescr1 + Space(1) 
		    
			AADD(aTam2, Len(cDescr1)	)  ////Demais colunas (Verbas ou Liq ou Tot)
       
			If nValHor=2 
   	   	  		WCabec2 += cDescr2 + Space(1) 
	   		Endif
	   	
		Endif
	
	   
	Next nFor                              
 
Endif

If	nLastKey = 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Passa parametros de controle da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString,,,cSize)

RptStatus({|lEnd| GR100Imp(@lEnd,wnRel,cString)},titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER100  ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 03.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio por Codigos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GPR100Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd        - A‡Æo do Codelock                             ³±±
±±³          ³ wnRel       - T¡tulo do relat¢rio                          ³±±
±±³Parametros³ cString     - Mensagem			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GR100Imp(lEnd,wnRel,cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt // Ambiente
Local CbCont
Local aArray := {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis de Acesso do Usuario                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cAcessaSR1	:= &( " { || " + ChkRH( "GPER100" , "SR1" , "2" ) + " } " )
Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER100" , "SRA" , "2" ) + " } " )
Local cAcessaSRC	:= &( " { || " + ChkRH( "GPER100" , "SRC" , "2" ) + " } " )
Local cAcessaSRI	:= &( " { || " + ChkRH( "GPER100" , "SRI" , "2" ) + " } " )

aArray := {"SR1", "SRA", "SRC", "SRI"} 
ffiltro("GPER100",aArray,1) //1- Executa os filtros                         

//--Salvar Ordem Selecionada SETPRINT                                       
nOrdem    := aReturn[8]

dbSelectArea( "SRA" )
dbGoTop()
If nOrdem == 1
	dbSetOrder(1)
	dbSeek(FilialDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim     := FilialAte + MatAte
ElseIf nOrdem == 2
	dbSetOrder(2)
	dbSeek(FilialDe + CcDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := FilialAte + CcAte + MatAte
ElseIf nOrdem == 3
	dbSetOrder(3)
	dbSeek(FilialDe + NomDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim     := FilialAte + NomAte + MatAte
Endif

cFilAnterior := Replicate("!", FWGETTAMFILIAL)
cCcAnt  := "!!!!!!!!!"

dbSelectArea("SRA")
SetRegua(SRA->(RecCount()))

While	!Eof() .And. &cInicio <= cFim
	
	IncRegua()

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif	 

	If	Sra->ra_Filial # cFilAnterior
		If	cFilAnterior # Replicate("!", FWGETTAMFILIAL)
			fImpFil()    // Totaliza Filial
		Endif
		cFilAnterior := SRA->RA_FILIAL
  	   cCcAnt       := SRA->RA_CC
	   fInfo(@aInfo,cFilAnterior)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SRA->RA_NOME < NomDe) .Or. (SRA->RA_NOME > NomAte) .Or. ;
		(SRA->RA_MAT < MatDe)  .Or. (SRA->RA_MAT > MatAte)  .Or. ;
		(SRA->RA_CC < CcDe)    .Or. (SRA->RA_CC > CcAte)
		fTestaTotal()
		Loop
	EndIf
		
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    If !( SRA->RA_FILIAL $ fValidFil() ) .Or. !Eval( cAcessaSRA )
       	fTestaTotal()
       	Loop
    EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Despreza Registros Conforme Situacao e Categoria Funcionarios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	!( SRA->RA_SITFOLH $ cSituacao ) .OR.  !( SRA->RA_CATFUNC $ cCategoria )
		fTestaTotal()		
		Loop
	Endif
	
	If	nRelat == 1       // Folha
		dbSelectArea("SRC")
		If	dbSeek(Sra->ra_Filial + Sra->ra_Mat )
			While	!Eof() .And. (Src->Rc_Filial+Src->Rc_Mat == Sra->ra_filial+Sra->ra_Mat)
				
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Consiste Filiais e Acessos                                             ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	            If !( SRC->RC_FILIAL $ fValidFil() ) .Or. !Eval( cAcessaSRC )
		           	dbSelectArea("SRC")
		           	dbSkip()
		           	Loop
		        EndIF
		                               
				//--Nao listar semana diferente da semana selecionada no parametro
				IF cSemana # "99" .And. SRC->RC_SEMANA # cSemana 
					dbSkip()
					Loop
				Endif
			
				FAcumula(SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
				
				If PosSrv( SRC->RC_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"		//Proventos
					nValorM := SRC->RC_VALOR * (-1)
                Else
					nValorM := SRC->RC_VALOR                 
                Endif
				If lliquido .And. nVerHor = 2 .And. Ascan(aTotais,{ |x| x[1] = SRC->RC_PD}) > 0
					FAcumula("LIQ",SRC->RC_HORAS,nValorM)
				Endif					
				If lTotais .And. nVerHor = 2 .And. Ascan(aTotais,{ |x| x[1] = SRC->RC_PD}) > 0
					FAcumula("TOT",SRC->RC_HORAS,SRC->RC_VALOR)
				Endif					
				dbSelectArea("SRC")
				dbSkip()
			Enddo
		Endif
	Elseif nRelat == 2   // 2¦ Parcela
		dbSelectArea("SRI")
		If dbSeek(Sra->ra_Filial + Sra->ra_Mat )
			While !Eof().And. (SRI->RI_Filial+SRI->RI_Mat == Sra->ra_filial+Sra->ra_Mat)
		
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Consiste Filiais e Acessos                                             ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			    If !( SRI->RI_FILIAL $ fValidFil() ) .Or. !Eval( cAcessaSRI )
        		   	dbSelectArea("SRI")
		           	dbSkip()
		           	Loop
		        EndIF

				FAcumula(SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
				
				If PosSrv( SRI->RI_PD, SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"		//Proventos
					nValorM := SRI->RI_VALOR * (-1)
                Else
					nValorM := SRI->RI_VALOR                 
                Endif
				If lliquido .And. nVerHor = 2 .And. Ascan(aTotais,{ |x| x[1] = SRI->RI_PD}) > 0
					FAcumula("LIQ",SRI->RI_HORAS,nValorM)
				Endif					
				If lTotais .And. nVerHor = 2 .And. Ascan(aTotais,{ |x| x[1] = SRI->RI_PD}) > 0
					FAcumula("TOT",SRI->RI_HORAS,SRI->RI_VALOR)
				Endif					
				dbSelectArea("SRI")
				dbSkip()
			Enddo
		Endif
	Elseif nRelat == 3   // Valores Extras
		dbSelectArea("SR1")
		If dbSeek(Sra->ra_Filial + Sra->ra_Mat )
			While !Eof() .And. (SR1->R1_Filial+SR1->R1_Mat == Sra->ra_filial+Sra->ra_Mat)
				
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Consiste Filiais e Acessos                                             ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			    If !( SR1->R1_FILIAL $ fValidFil() ) .Or. !Eval( cAcessaSR1 )
		           	dbSelectArea("SR1")
		           	dbSkip()
		           	Loop
        		EndIF
        		
				//--Nao listar semana diferente da semana selecionada no parametro
				IF cSemana # "99" .And. SR1->R1_SEMANA # cSemana 
					dbSkip()
					Loop
				Endif
				
				FAcumula(SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
				If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"		//Proventos
					nValorM := SR1->R1_VALOR * (-1)
                Else
					nValorM := SR1->R1_VALOR                 
                Endif
				If lliquido .And. nVerHor = 2 .And. Ascan(aTotais,{ |x| x[1] = SR1->R1_PD}) > 0
					FAcumula("LIQ",SR1->R1_HORAS,nValorM)
				Endif					
				If lTotais .And. nVerHor = 2 .And. Ascan(aTotais,{ |x| x[1] = SR1->R1_PD}) > 0
					FAcumula("TOT",SR1->R1_HORAS,SR1->R1_VALOR)
				Endif					
				dbSelectArea("SR1")
				dbSkip()
			Enddo
		Endif
	Endif
	If	FTotaliza(2)+FTotaliza(3) > 0 .and. lSalario
		FAcumula(" SB",SRA->RA_HRSMES,SRA->RA_SALARIO)
	Endif
	fImpFun()
	fTestaTotal()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRA")
Set Filter to 
dbSetOrder(1)

Set Device To Screen
If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif
MS_FLUSH()

ffiltro("GPER100",aArray,0) //0- Limpa os filtros
********************************
Static Function fTestaTotal()      // Executa Quebras
********************************
cCcAnt       := SRA->RA_CC
cFilAnterior := SRA->RA_FILIAL

dbSelectArea("SRA")
dbSkip()
If Eof() .Or. &cInicio > cFim
	fImpCc()
	fImpFil()
	if lImpEmpr // se listar empresa for igual a "Sim", imprime total da empresa
		fImpEmp()
	EndIF	
Elseif cFilAnterior # SRA->RA_FILIAL
	fImpCc()
	fImpFil()
Elseif cCcAnt # SRA->RA_CC .And. !Eof()

	fImpCc()

	// Saltar a pagina quando quebra CC e Sim
	If nSaltaCC  = 1
		IMPR("","P")
	Endif

Endif
Return Nil

***********************
Static Function fImpFun            // Imprime um Funcionario
***********************
If nSinAna = 2 // Se Relatorio e' Analitico
	fImprime(1,2)
Endif
FZera(2) // Zerar a Coluna de Funcionarios
FZera(10)
Retu Nil

**********************
Static Function fImpCc             // Imprime Centro de Custo
**********************
If nOrdem ==  2 .AND. FTotaliza(4)+FTotaliza(5) > 0
	fImprime(2,4) // Imprime
Endif
FZera(4)
Retu Nil

***********************
Static Function fImpFil            // Imprime Filial
***********************
fImprime(3,6)
FZera(6)
Retu Nil

***********************
Static Function fImpEmp            // Imprime Geral
***********************
fImprime(4,8)
FZera(8)
Retu Nil

************************************
Static Function fImprime(nTipo,nCol)
************************************
// nTipo: 1- Funcionario
//        2- Centro de Custo
//        3- Filial
//        4- Geral

If nTipo == 1                  
	If nVerHor == 1
	   DET :=SRA->RA_FILIAL +Space(2)+Padr(SRA->RA_CC,aTam1[2])+Space(2)+Padr(SRA->RA_MAT,aTam1[3])+"-"+Padr(SRA->RA_NOME, aTam1[4])+SPACE(02)  
	Else
	   DET :=SRA->RA_FILIAL +Space(1)+Padr(SRA->RA_MAT,aTam1[2])+Space(1)+Padr(SRA->RA_NOME, aTam1[3])+SPACE(01)  
	Endif	
	FImpDet(2,3,1)
Elseif nTipo == 2
	If nVerHor == 1
	    DET:= Padr(cFilAnterior +Space(2)+Subs(cCcAnt+Space(20),1,20)+ " - " + DescCC(cCcAnt,cFilAnterior,20),aTam1[Len(aTam1)]) 
	ElseIf nVerHor = 2 // Se e' horizontal
		IMPR(REPL("-",COLUNAS),"C")
	    DET:= Padr(Subs(AllTrim(cCcAnt),1,20)+"-"+AllTrim(DescCC(cCcAnt,cFilAnterior,20)),aTam1[Len(aTam1)]) 
	Endif
    FImpDet(4,5,2)
Elseif nTipo == 3
	If nVerHor == 1
		DET:= Padr(cFilAnterior + Space(2) + Subs(aInfo[1],1,15), aTam1[Len(aTam1)]) 
	Else
		If nOrdem # 2 .and. ;
		  (FTotaliza(6)+FTotaliza(7) # 0 )	
			IMPR(REPL("-",COLUNAS),"C")	
		Endif	
		DET:= Padr(cFilAnterior + Space(2) + Subs(aInfo[1],1,15) ,aTam1[Len(aTam1)]) 
	Endif		
	FImpDet(6,7,3)
	IF (FTotaliza(6)+FTotaliza(7) # 0 )	
		IMPR("","P")                // Salta Pagina apos Quebra Cc/Filial/Empresa
	Endif	
Elseif nTipo == 4
	If nVerHor == 1
		DET:= Padr(STR0025 + Subs(aInfo[3],1,40), aTam1[Len(aTam1)])  	//"Empresa: "
	Else
		DET:= Padr(STR0025 + Subs(aInfo[3],1,23), aTam1[Len(aTam1)])	//"Empresa: "
	Endif		
	FImpDet(8,9,4)
	IF (FTotaliza(8)+FTotaliza(9) # 0 )	
		IMPR("","P")                // Salta Pagina apos Quebra Cc/Filial/Empresa
	EndIF	
Endif
Return Nil

*******************************************
Static Function FAcumula(cPd,nHoras,nValor)
*******************************************
LOCAL n := 0
n := Ascan(aTotais,{ |x| x[1] = cPd } )
If n = 0 .AND. lTodos
	Aadd(aTotais,{cPd,nHoras,nValor,nHoras,nValor,nHoras,nValor,nHoras,nValor,0.00})
	If lLiquido 
		If PosSrv( cPd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"		//Descontos
			nValor	:= nValor*(-1)
		EndIf
	EndIf
	If lTotais .or. lLiquido	
		aTotais[Len(aTotais),10] += nValor
	Endif
ElseIf n > 0
	aTotais[n,2] += nHoras
	aTotais[n,3] += nValor
	aTotais[n,4] += nHoras
	aTotais[n,5] += nValor
	aTotais[n,6] += nHoras
	aTotais[n,7] += nValor
	aTotais[n,8] += nHoras
	aTotais[n,9] += nValor
	If nVerHor = 1
		If lLiquido 
			If PosSrv( cPd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"		//Descontos
				nValor := nValor*(-1)
			EndIf 
		EndIf
		If lTotais .or. lLiquido	
			aTotais[n,10] += nValor
		Endif	
	Endif	
Endif
Return Nil    


***************************
Static Function FZera(nCol)
***************************
Local nFor
For nFor := 1 To Len(aTotais)
	aTotais [nFor,nCol]   := 0   // Zera Totais de horas
	If nCol # 10
		aTotais [nFor,nCol+1] := 0   // Zera Totais de Valores
	Endif	
Next nFor
Return Nil

*******************************
Static Function FTotaliza(nCol)
*******************************
LOCAL nTot := 0
AEVAL(aTotais,{ |x| nTot += If (x[1] $ "LIQ* SB", 0 , x[nCol])  })
Return nTot

********************************************
Static Function FImpDet(nCol1,nCol2,nMsgTot)
********************************************
LOCAL lImprime := .F.
LOCAL cMsg[4]
Local nFor  
LOCAL cDescVerba	:= ''

If nVerHor = 1
	aTotais := aSort(aTotais,,,{ |x,y| x[1] < y[1] })
Endif 

cMsg[1] := 'D O     F U N C I O N A R I O      '
cMsg[2] := 'D O     C E N T R O  D E  C U S T O'
cMsg[3] := 'D A     F I L I A L                '
cMsg[4] := 'D A     E M P R E S A              '
For nFor := 1 To Len(aTotais)
	IF nVerHor = 1  // Vertical
		If aTotais[nFor,nCol1]+aTotais[nFor,nCol2] # 0
                      
            If aTotais[nFor,1]=" SB"
            	 cDescVerba:=	Space(len(aTotais[nFor,1]))+ Space(1)+ "SALARIO BASE   "
            Else
            	 cDescVerba:=	aTotais[nFor,1] + Space(1) + DescPd(aTotais[nFor,1],cFilAnterior,15)
            Endif
 
            cDescVerba:= Padr(cDescVerba, aTam1[5] ) + Space(2)   //Cod.Descricao
 
            DET+= cDescVerba
            DET+= Padl(TRANSFORM(aTotais[nFor,nCol1],'@E 999999.99'), aTam1[7]) + Space(2)
            DET+= Padl(TRANSFORM(aTotais[nFor,nCol2],cPict1		), aTam1[8]) + Space(2)
			
			IMPR(DET,'C')
			lImprime := .T.
		Endif
		IF lImprime = .T.
			DET := Space(aTam1[Len(aTam1)])
		Endif
	Else
		If (nValHor=2)
			DET += Padl(TRANSFORM(aTotais[nFor,nCol1],'@E 999999.99'),aTam2[nFor])
		Else
			DET += Padl(TRANSFORM(aTotais[nFor,nCol2],cPict1),aTam2[nfor])
		Endif

		DET+=Space(1)

	Endif
Next nFor
If nVerHor = 2  // Horizontal
	If FTotaliza(nCol1) # 0 .Or. FTotaliza(nCol2) # 0
		IMPR(DET,'C')
		If nMsgTot = 2
			IMPR(REPL("-",COLUNAS),"C")
		Endif
	Endif
Else
	If lLiquido  .And. fTotaliza(10) > 0.00
		DET := Space(aTam1[Len(aTam1)]) + Repl("-",aTam1[5]+2+aTam1[7]+2+aTam1[8])
		IMPR(DET,'C')

	   	DET:= Space( aTam1[1]+2+aTam1[2]+2+aTam1[3]+2+aTam1[4]+2+aTam1[5]-1-aTam1[6] ) //Desconsidera o tamanho da Descricao da verba
		DET+= Padr( "TOTAL LIQUIDO   ", aTam1[6] ) +Space(2)+Space(aTam1[7])+Space(2)
		
		DET+= Padl(TRANSFORM(FTotaliza(10),cPict1),aTam1[8])
		
		IMPR(DET,'C')
	EndIf
	If lTotais
		DET :=Padl(STR0031+Space(2)+cMsg[nMsgTot]+Space(2)+">>>>>", aTam1[1]+2+aTam1[2]+2+aTam1[3]+2+aTam1[4]+2+aTam1[5]-1-aTam1[6])	//"T O T A L"
		DET += Space(1) + Space(aTam1[6]) + Space(1) + Padl(TRANSFORM(FTotaliza(nCol1),'@E 999999.99'),aTam1[7])+Space(2)
		DET += Padl(TRANSFORM(FTotaliza(nCol2),cPict1),aTam1[8])
		
	EndIf
	IF FTotaliza(nCol1)+FTotaliza(nCol2) # 0	
		IMPR(" ","C")
		If(lTotais,IMPR(DET,"C"),)
		IMPR(REPLICATE('-',COLUNAS),'C')
	Endif
EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AjustSx1 ³ Autor ³ Raquel Hager          ³ Data ³ 07.03.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Ajuste inclusao de opcao 'Nao' no param. MV_CHN - Loc. Uru ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AjustSx1                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico do programa gper100                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustSx1()
Local aArea := GetArea()

    /*If cPaisLoc $ "URU*SAL"
		dbSelectArea("SX1")
		dbSetorder(1)    
		dbSeek("GPR100    ")   
		While SX1->(!Eof()) .and. AllTrim(SX1->X1_GRUPO) == "GPR100" 
			If SX1->X1_GRUPO + SX1->X1_ORDEM == "GPR100    23"     
				RecLock("SX1",.F.)
				SX1->X1_DEF02:= "Nao" 
				SX1->X1_DEFSPA2:= "No"
				SX1->X1_DEFENG2:= "No"
				SX1->(MsUnlock()) 
			EndIf  
			SX1->(DbSkip())		  
		End  
	EndIf*/

RestArea(aArea)
Return Nil  
