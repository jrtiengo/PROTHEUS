#INCLUDE "GPER030.CH"
#INCLUDE "PROTHEUS.CH"
#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER030 (Alterado para RECPAG)             � Autor           ���   R.H. - Ze Maria         � Data � 14.03.95 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao de Recibos de Pagamento                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER030(void)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Mauro      � 14/03/01 �------� Colocado DbsetOrder Src,causava erro Top ���
��� J. Ricardo � 16/02/01 �------� Utilizacao da data base como parametro   ���
���            �          �      � para impressao.                          ���
��� Emerson    � 27/04/01 �------�Ajustes para tratar a pensao alimenticia a���
���            � -------- �------�partir do cadastro de beneficiarios(novo) ���
��� Natie      � 24/08/01 �------� Inclusao PrnFlush()-Descarrega Spool     ���
��� Natie      � 24/08/01 �ver609�fSendDPagto()-Envio de E-mail Demont.Pagto���
��� Natie      � 29/08/01 �009963�PrnFlush-Descarrega spool impressao teste ���
��� Marinaldo  � 20/09/01 �Melhor�Geracao de Demonstrativo de Pagamento   pa���
���            � -------- �------�ra o Terminal de Consulta.                ���
��� Marinaldo  � 26/09/01 �Melhor�Passagem de dDataRef para OpenSRC() por re���
���            � -------- �------�ferencia.					     	 	    ���
��� Marinaldo  � 08/10/01 �Melhor�Inclusao de Regua de Processamento  Quando���
���            � -------- �------�geracao de e-mail  	 	 	 	 	    ���
��� Mauro      � 05/11/01 �010528�Verificar a Sit.de Demitido no mes de ref.���
���            �          �      �nao listava demitido posterior a dt.ref.  ���
��� Marinaldo  � 21/12/01 �Acerto�O Programa devera sempre retornar caracter���
���            �          �      �Qdo. Chamada atraves do Terminal para  evi���
���            �          �      �tar erro de comparacao de tipo            ���
��� Natie      � 11/12/01 �009963� Acerto Impressao-Teste                   ���
���            � 11/12/01 �011547� Quebra pag.qdo func. tem mais de 2 recibo���
��� Mauro      � 14/01/02 �012282�Acerto na compar. d Mes Aniv. Dezembro.   ���
��� Silvia     � 20/02/02 �013293�Acerto nos Dias Trabalhados para Paraguai ���
��� Mauro      � 20/03/02 �------�Inicializar o Li com _prow() estava pulan-���
���            �          �      �do pag.na prim.Impr. Epson 1170		    ���
��� Natie      � 05/04/02 �------�Quebra de pagina - pre impresso           ���
��� Emerson    � 15/08/02 �Meta  �Se RC_QTDSEM maior que 0, sera impresso   ���
���            �          �      �como referencia, caso contrario RC_HORAS. ���
��� Emerson    � 06/01/03 �------�Buscar o codigo CBO no cadastro de funcoes���
���            �          �------�de acordo com os novos codigos CBO/2002.  ���
��� Mauro      � 17/05/03 �064530�Acerto na Compactacao e salto devido alt. ���
���            �          �------�na Lib.             			 	        ���
��� Andreia    � 29/05/03 �------�Ajuste na Quebra de pagina - pre impresso ���
��� Mauro      � 06/09/03 �------�Trocada funcao retorno Salario (fBuscasal)���
��� Pedro Eloy � 08/12/03 �------�Aplicacao do comando SetPgEject(.F.)      ���
��� Pedro Eloy � 06/02/04 �------�Ajuste no retorno da funcao OpenSrc().    ���
��� Natie      � 16/03/04 �F01027�Acerto p/trazer Funcao do mes de Referec. ���
��| Natie      � 08/04/04 �------� Acerto no Driver p/Impressao             ���
��| Natie      � 16/04/04 �------� PerSemana()busca semana do Cad.Perido    ���
��| Emerson GR.� 27/05/04 �------�Tratamento do Cargo de Funcionario.		���
��| Emerson    � 08/06/04 �------�Igualar variavel lEnvioOk na chamada da   ���
���            �          �------�funcao GPEMail() p/ que seja atualizada.  ���
��� Pedro Eloy � 03/06/04 �070926|Ajustado o disposicionamento do nome empr.���
���            �          �      |e tratado o botao cancelar no teste impres���
��� Ricardo D. � 20/08/04 �Melhor|Tratamento da data de liberacao para con- ���
���            �          �      |sulta ao recibo pagto no Rh-OnLine.       ���
��� Pedro Eloy � 26/08/04 �------|Estava se perdendo ao imprimir um funciona���
���            �          �      |rio onde tivesse mais de um recibo.       ���
��� Ricardo D. � 30/08/04 �Melhor|Passagem do parametro ".F." em todas as   ���
���            �          �      |chamadas da funcao R030IMPR.              ���
��� Pedro Eloy � 01/09/04 �073931�Ajuste no disposicionamento do nome da    ���
���            �          �      �empresa, emissao do recibo de pagamento.  ���
���Emerson     � 28/10/04 �075658�Checar parametro MV_IREFSEM para imprimir ���
���            �          �------�referencias em Semanas ou Horas. 	 	    ���
��� Ricardo D. � 12/01/05 �077579�Ajuste da impressao da mensagem do recibo.���
��� Ricardo D. � 17/01/05 �FNC092|Ajuste da impressao c.custos c/ate 20carac���
��� Ricardo D. � 04/05/05 �081718|Ajuste do tipo dos parametros do rh-online���
���            �          �------�MV_TCFD???. Devem ser do tipo caracter.   ���
���Ricardo/Emer� 02/06/05 �FN1996|Ajuste no teste dos parametros MV_TCFD???.���
��� Andreia S. � 20/07/05 �084451|Ajuste na impressao do Liquido a Receber e���
���            �          �------�banco para credito quando o formulario for���
���            �          �------�zebrado.                                  ���
��� Tania      �05/04/2006�096455�Acertada leitura da SRI pelo indice 1, na ���
���            �          �------�impressao do recibo de 13o.               ���
��� Tania      �18/05/2006�097654|Retirada a obrigatoriedade de informacao  ���
���            �          �      |da senha da conta de e-mail remetente.    ���
���Ronan       �08/08/2006�      |Fechamento da tabela SRC apos construido  ���
���            �          �      |o HTML para o TCF. Alteracao para efetuar ���
���            �          �      |o fechamento mensal sem a necessidade de  ���
���            �          �      |sair do RH|Online                         ���
��� Ricardo D. � 24/11/06 �108807|Criado parametro MV_TCFMFEC para fazer a  ���
���            �          �------�consistencia dos parametros MV_TCFD??? p/ ���
���            �          �------�meses fechados.                           ���
��� Ricardo D. � 30/01/07 �118298|Ajuste no tratamento do parametro         ���
���            �          �      �MV_TCFDFOL para utilizar a configuracao"0"���
���            �          �      �(zero). Desta forma, a data limite sera   ���
���            �          �      �o ultimo dia do mes. Caso esteja configura���
���            �          �      �do com branco, nao havera teste da data   ���
���            �          �      �limite.                                   ���
���Renata      �02/05/2007�125113|Ajuste na paginacao da base e vlr FGTS,   ���
���            �          �      |acrescentando valores de dif.dissidio     ���
���Natie       �28/06/07  �114838|Estava impr.vlrs.de dif.13o juntamente com���
���            �          �      |o vlr do 13o sal.pago em  ferias          ���
���Joeudo S.F. �02/08/07  �108197|cBaseAux = SIM quando chamdao do RH-online���
��� Alexandre  �21/11/07  �104793� Implemntado Querys para trazer a quanti- ���
��� Conselvan  �          �      � dade de registros que ser�o processados  ���
���            �          �      � assim a regua progrider� corretamente    ���
���            �          �      � ate o final							    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function RECPAG(lTerminal,cFilTerminal,cMatTerminal,cMesAnoRef,nRecTipo,cSemanaTerminal) //GPER030
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local cString:="SRA"        // alias do arquivo principal (Base)
Local aOrd   := {STR0001,STR0002,STR0003,STR0004,STR0005} //"Matricula"###"C.Custo"###"Nome"###"Chapa"###"C.Custo + Nome"
Local cDesc1 := STR0006		//"Emiss�o de Recibos de Pagamento."
Local cDesc2 := STR0007		//"Ser� impresso de acordo com os parametros solicitados pelo"
Local cDesc3 := STR0008		//"usu�rio."
Local aDriver:= ReadDriver()
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Programa)                           �
//����������������������������������������������������������������
Local nExtra,cIndCond,cIndRc
Local Baseaux := "S", cDemit := "N"
Local cHtml := ""

//��������������������������������������������������������������Ŀ
//� Define o numero da linha de impress�o como 0                 �
//����������������������������������������������������������������
SetPrc(0,0)

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Basicas)                            �
//����������������������������������������������������������������
Private aReturn  := {STR0009, 1,STR0010, 2, 2, 1, "",1 }	//"Zebrado"###"Administra��o"
Private nomeprog := "RECPAG"
Private aLinha   := { },nLastKey := 0
Private cPerg    := padr("GPR030", LEN(SX1->X1_GRUPO), " ") 
Private cSem_De  := "  /  /    "
Private cSem_Ate := "  /  /    "
Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe

Private cCompac := aDriver[1]
Private cNormal := aDriver[2]

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Programa)                           �
//����������������������������������������������������������������
Private aLanca := {}
Private aProve := {}
Private aDesco := {}
Private aBases := {}
Private aInfo  := {}
Private aCodFol:= {}
Private li     := _PROW()
Private Titulo := STR0011		//"EMISS�O DE RECIBOS DE PAGAMENTOS"
Private lEnvioOk := .F.
Private lRetCanc	:= .t.
Private cIRefSem    := GetMv("MV_IREFSEM",,"S")

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:="RECPAG"            //Nome Default do relatorio em Disco

//��������������������������������������������������������������Ŀ
//� Verifica se o programa foi chamado do terminal - TCF         �
//����������������������������������������������������������������
lTerminal := If( lTerminal == Nil, .F., lTerminal )

IF !( lTerminal )
	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)
Else           
	If Select("SRC")>0
		SRC->(DbCloseArea())
	EndIf
EndIF

//��������������������������������������������������������������Ŀ
//� Define a Ordem do Relatorio                                  �
//����������������������������������������������������������������
nOrdem := IF( !( lTerminal ), aReturn[8] , 1 )

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
cSemanaTerminal := IF( Empty( cSemanaTerminal ) , Space( TamSx3("RC_SEMANA")[1] ) , cSemanaTerminal )
dDataRef   := IF( !( lTerminal ), mv_par01 , Stod(Substr(cMesAnoRef,-4)+SubStr(cMesAnoRef,1,2)+"01"))//Data de Referencia para a impressao
nTipRel    := IF( !( lTerminal ), mv_par02 , 3					)	//Tipo de Recibo (Pre/Zebrado/EMail)
Esc        := IF( !( lTerminal ), mv_par03 , nRecTipo			)	//Emitir Recibos(Adto/Folha/1�/2�/V.Extra)
Semana     := IF( !( lTerminal ), mv_par04 , cSemanaTerminal	)	//Numero da Semana
cFilDe     := IF( !( lTerminal ),mv_par05,cFilTerminal			)	//Filial De
cFilAte    := IF( !( lTerminal ),mv_par06,cFilTerminal			)	//Filial Ate
cCcDe      := IF( !( lTerminal ),mv_par07,SRA->RA_CC			)	//Centro de Custo De
cCcAte     := IF( !( lTerminal ),mv_par08,SRA->RA_CC			)	//Centro de Custo Ate
cMatDe     := IF( !( lTerminal ),mv_par09,cMatTerminal			)	//Matricula Des
cMatAte    := IF( !( lTerminal ),mv_par10,cMatTerminal			)	//Matricula Ate
cNomDe     := IF( !( lTerminal ),mv_par11,SRA->RA_NOME			)	//Nome De
cNomAte    := IF( !( lTerminal ),mv_par12,SRA->RA_NOME			)	//Nome Ate
ChapaDe    := IF( !( lTerminal ),mv_par13,SRA->RA_CHAPA 		)	//Chapa De
ChapaAte   := IF( !( lTerminal ),mv_par14,SRA->RA_CHAPA 		)	//Chapa Ate
Mensag1    := mv_par15										 	//Mensagem 1
Mensag2    := mv_par16											//Mensagem 2
Mensag3    := mv_par17											//Mensagem 3
cSituacao  := IF( !( lTerminal ),mv_par18, fSituacao( NIL , .F. ) )	//Situacoes a Imprimir
cCategoria := IF( !( lTerminal ),mv_par19, fCategoria( NIL , .F. ))	//Categorias a Imprimir
cBaseAux   := IF( !( lTerminal ),If(mv_par20 == 1,"S","N"),"S")		//Imprimir Bases

If aReturn[5] == 1 .and. nTipRel == 1
	li	:=  0
EndIf


IF !( lTerminal )
	cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
	//��������������������������������������������������������������Ŀ
	//� Inicializa Impressao                                         �
	//����������������������������������������������������������������
	If ! fInicia(cString,nTipRel)
		Return
	Endif
	
EndIF

IF nTipRel==3
	IF lTerminal
		cHtml := R030Imp(.F.,wnRel,cString,cMesAnoRef,lTerminal)
		If Select("SRC")>0
			SRC->(DbCloseArea())
		EndIf
	Else
		ProcGPE({|lEnd| R030IMP(@lEnd,wnRel,cString,cMesAnoRef,.f.)},,,.T.)  // Chamada do Processamento
	EndIF
Else
	RptStatus({|lEnd| R030Imp(@lEnd,wnRel,cString,cMesAnoRef,.f.)},Titulo)  // Chamada do Relatorio
EndIF

Return( IF( lTerminal , cHtml , NIL ) )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R030IMP  � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento Para emissao do Recibo                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local lIgual                 //Vari�vel de retorno na compara�ao do SRC
Local cArqNew                //Vari�vel de retorno caso SRC # SX3
Local aOrdBag     := {}
Local cMesArqRef  := If(Esc == 4,"13"+Right(cMesAnoRef,4),cMesAnoRef)
Local cArqMov     := ""
Local aCodBenef   := {}
Local cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
Local cAcessaSRA  := &("{ || " + ChkRH("GPER030 ","SRA","2") + "}")
Local cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")
Local cAcessaSRI  := &("{ || " + ChkRH("GPER030","SRI","2") + "}")
Local cNroHoras   := &("{ || If(SRC->RC_QTDSEM > 0 .And. cIRefSem == 'S', SRC->RC_QTDSEM, SRC->RC_HORAS) }")
Local cHtml		  := ""
Local nHoras      := 0
Local nMes, nAno
Local nX
Local cMesCorrente:= If(GetMv("MV_TCFMFEC",,"2")=="2",getmv("MV_FOLMES"),mesano(dDataRef))
Local cAnoMesCorr := cMesCorrente
Local dDataLibRh
Local nTcfDadt		:= if(lTerminal,getmv("MV_TCFDADT",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF 
Local nTcfDfol		:= if(lTerminal,getmv("MV_TCFDFOL",,0),0)		// indica a quantidade de dias a somar ou diminuir no ultimo dia do mes corrente para liberar a consulta do TCF
Local nTcfD131		:= if(lTerminal,getmv("MV_TCFD131",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
Local nTcfD132		:= if(lTerminal,getmv("MV_TCFD132",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
Local nTcfDext		:= if(lTerminal,getmv("MV_TCFDEXT",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
Local lNaoChkDFol	:= ( valtype(ntcfdfol)=="C" .And. Empty(alltrim(nTcfDFol)) )

Private tamanho     := "M"
Private limite		:= 132
Private cAliasMov 	:= ""
Private cDtPago     := ""
Private cPict1	:=	"@E 999,999,999.99"
Private cPict2 := "@E 99,999,999.99"
Private cPict3 :=	"@E 999,999.99"
If MsDecimais(1) == 0
	cPict1	:=	"@E 99,999,999,999"
	cPict2 	:=	"@E 9,999,999,999"
	cPict3 	:=	"@E 99,999,999"
Endif

// Ajuste do tipo da variavel
nTcfDadt	:= if(valtype(ntcfdadt)=="C",val(ntcfdadt),ntcfdadt)
nTcfD131	:= if(valtype(nTcfD131)=="C",val(nTcfD131),nTcfD131)
nTcfD132	:= if(valtype(nTcfD132)=="C",val(nTcfD132),nTcfD132)
nTcfDfol	:= if(valtype(ntcfdfol)=="C",val(ntcfdfol),ntcfdfol)
nTcfDext	:= if(valtype(ntcfdext)=="C",val(ntcfdext),ntcfdext)

If cPaisLoc $ "URU|ARG|PAR"  
	If Esc == 3
		cMesArqRef := "13" + Right(cMesAnoRef,4)
	ElseIf Esc == 4
		cMesArqRef := "23" + Right(cMesAnoRef,4)
	Else
		cMesArqRef := cMesAnoRef
	Endif
Else
	If Esc == 4
		cMesArqRef := "13" + Right(cMesAnoRef,4)
	Else
		cMesArqRef := cMesAnoRef
	Endif
Endif

//��������������������������������������������������������������Ŀ
//| Verifica se existe o arquivo de fechamento do mes informado  |
//����������������������������������������������������������������
If !OpenSrc( cMesArqRef, @cAliasMov, @aOrdBag, @cArqMov, @dDataRef , NIL ,lTerminal )
	Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
Endif

//��������������������������������������������������������������Ŀ
//| Verifica se o Mes solicitado esta liberado para consulta no  |
//| terminal de consulta do funcionario.                         |
//����������������������������������������������������������������
If lTerminal

	If !empty(cMesCorrente)
		cMesCorrente := substr(cMesCorrente,-2)+substr(cMesCorrente,1,4)
	endif

	If	cMesCorrente == cMesArqRef  .or. right(cMesCorrente,4)+left(cMesCorrente,2) == mesano(ddataref) .Or. ;
		mesano(ddataref) > substr(cMesCorrente,3,4)+substr(cMesCorrente,1,2) .Or.;		
		left(cMesArqRef,2) == "13"

		If Esc == 1
			If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == cAnoMesCorr,day(date()) < nTCFDADT,.F.) )
				Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
			EndIf
		ElseIf Esc == 2 .and. !lNaoChkDFol
			dDataLibRh := fMontaDtTcf(cMesCorrente,nTCFDFOL)
			If date() < dDataLibRH 
				Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
			Endif
		ElseIf Esc == 3
			If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == cAnoMesCorr,day(date()) < nTCFD131,.F.) )
				Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
			Endif
		ElseIf Esc == 4
			If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == cAnoMesCorr,day(date()) < nTCFD132,.F.) )
				Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
			Endif
		ElseIf Esc == 5
			If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == cAnoMesCorr,day(date()) < nTCFDEXT,.F.) )
				Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
			Endif
		endif
	Endif
Endif
If cPaisLoc == "ARG"
	nMes := Month(dDataRef) - 1
	nAno := Year(dDataRef)
	If nMes == 0
		nMes := 1
		nAno := nAno - 1
	Endif
	If nMes < 0
		nMes := 12 - ( nMes * -1 )
		nAno := nAno - 1
	Endif
	If Esc == 1 .or. Esc == 2
		cAnoMesAnt := StrZero(nAno,4)+StrZero(nMes,2)
	ElseIf Esc == 3 .or. Esc == 4
		cAnoMesAnt := Right(cMesAnoRef,4)-1	+"13"
	Endif
Endif

//��������������������������������������������������������������Ŀ
//� Selecionando a Ordem de impressao escolhida no parametro.    �
//����������������������������������������������������������������
dbSelectArea( "SRA")
IF !( lTerminal )
	If nOrdem == 1
		dbSetOrder(1)
	ElseIf nOrdem == 2
		dbSetOrder(2)
	ElseIf nOrdem == 3
		dbSetOrder(3)
	Elseif nOrdem == 4
		cArqNtx  := CriaTrab(NIL,.f.)
		cIndCond :="RA_Filial + RA_Chapa + RA_Mat"
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0012)		//"Selecionando Registros..."
	ElseIf nOrdem == 5
		dbSetOrder(8)
	Endif
	
	dbGoTop()
	
	If nTipRel == 2
		@ LI,00 PSAY AvalImp(Limite)
	Endif
EndIF

//��������������������������������������������������������������Ŀ
//� Selecionando o Primeiro Registro e montando Filtro.          �
//����������������������������������������������������������������
If nOrdem == 1 .or. lTerminal
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	IF !( lTerminal )
		dbSeek(cFilDe + cMatDe,.T.)
		cFim    := cFilAte + cMatAte
	Else
		cFim    := &(cInicio)
	EndIF
ElseIf nOrdem == 2
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	dbSeek(cFilDe + cNomDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim    := cFilAte + cNomAte + cMatAte
ElseIf nOrdem == 4
	dbSeek(cFilDe + ChapaDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_CHAPA + SRA->RA_MAT"
	cFim    := cFilAte + ChapaAte + cMatAte
ElseIf nOrdem == 5
	dbSeek(cFilDe + cCcDe + cNomDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME"
	cFim     := cFilAte + cCcAte + cNomAte
Endif

dbSelectArea("SRA")
//��������������������������������������������������������������Ŀ
//� Carrega Regua Processamento	                                 �
//����������������������������������������������������������������
#IFDEF TOP                  
	cAliasTMP := "QNRO"
	BeginSql alias cAliasTMP
		SELECT COUNT(*) as NROREG
		FROM %table:SRA% SRA
		WHERE      SRA.RA_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAte% 
			   AND SRA.RA_MAT    BETWEEN %exp:cMatDe% AND %exp:cMatAte%
			   AND SRA.RA_CC     BETWEEN %exp:cCCDe%  AND %exp:cCCAte% 
			   AND SRA.%notDel%
	EndSql                
		
	nRegProc := (cAliasTMP)->(NROREG)
	( cAliasTMP )->( dbCloseArea() )	
	IF nTipRel # 3
		SetRegua(nRegProc)	// Total de elementos da regua
	Else
		IF !( lTerminal )
			GPProcRegua(nRegProc)// Total de elementos da regua
		EndIF
	EndIF
	
	dbSelectArea("SRA")
	
#ELSE
	IF nTipRel # 3
		SetRegua(RecCount())	// Total de elementos da regua
	Else
		IF !( lTerminal )
			GPProcRegua(RecCount())// Total de elementos da regua
		EndIF
	EndIF
	
	dbSelectArea("SRA")
	
#ENDIF 



TOTVENC:= TOTDESC:= FLAG:= CHAVE := 0

Desc_Fil := Desc_End := DESC_FUNC:= "" //DESC_CC:= 
Desc_Comp:= Desc_Est := Desc_Cid:= ""
DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space(01)
cFilialAnt := "  "
Vez        := 0
OrdemZ     := 0

While SRA->( !Eof() .And. &cInicio <= cFim )
	
	//��������������������������������������������������������������Ŀ
	//� Movimenta Regua Processamento                                �
	//����������������������������������������������������������������
	IF !( lTerminal )
		
		IF nTipRel # 3
			IncRegua()  // Anda a regua
		ElseIF !( lTerminal )
			GPIncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)
		EndIF
		
		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
		Endif
		//��������������������������������������������������������������Ŀ
		//� Consiste Parametrizacao do Intervalo de Impressao            �
		//����������������������������������������������������������������
		If (SRA->RA_CHAPA < ChapaDe) .Or. (SRA->Ra_CHAPa > ChapaAte) .Or. ;
			(SRA->RA_NOME < cNomDe)    .Or. (SRA->Ra_NOME > cNomAte)    .Or. ;
			(SRA->RA_MAT < cMatDe)     .Or. (SRA->Ra_MAT > cMatAte)     .Or. ;
			(SRA->RA_CC < cCcDe)       .Or. (SRA->Ra_CC > cCcAte)
			SRA->(dbSkip(1))
			Loop
		EndIf
		
	EndIF
	
	aLanca:={}         // Zera Lancamentos
	aProve:={}         // Zera Lancamentos
	aDesco:={}         // Zera Lancamentos
	aBases:={}         // Zera Lancamentos
	nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00
	
	Ordem_rel := 1     // Ordem dos Recibos
	
	//��������������������������������Ŀ
	//� Verifica Data Demissao         �
	//����������������������������������
	cSitFunc := SRA->RA_SITFOLH
	dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")
	If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
		cSitFunc := " "
	Endif
	
	IF !( lTerminal )
		
		//��������������������������������������������������������������Ŀ
		//� Consiste situacao e categoria dos funcionarios			     |
		//����������������������������������������������������������������
		If !( cSitFunc $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria )
			dbSkip()
			Loop
		Endif
		If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
			dbSkip()
			Loop
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Consiste controle de acessos e filiais validas				 |
		//����������������������������������������������������������������
		If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			dbSkip()
			Loop
		EndIf
		
	EndIF
	
	If SRA->RA_Filial # cFilialAnt
		If ! Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or. ! fInfo(@aInfo,Sra->Ra_Filial)
			Exit
		Endif
		Desc_Fil := aInfo[3]
		Desc_End := aInfo[4]                // Dados da Filial
		Desc_CGC := aInfo[8]
		DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space(01)
		Desc_Est := Substr(fDesc("SX5","12"+aInfo[6],"X5DESCRI()"),1,12)
		Desc_Comp:= aInfo[14]        			// Complemento Cobranca
		Desc_Cid := aInfo[05]
		// MENSAGENS
		If MENSAG1 # SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG1)
				DESC_MSG1 := Left(SRX->RX_TXT,30)
			ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG1)
				DESC_MSG1 := Left(SRX->RX_TXT,30)
			Endif
		Endif
		
		If MENSAG2 # SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG2)
				DESC_MSG2 := Left(SRX->RX_TXT,30)
			ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG2)
				DESC_MSG2 := Left(SRX->RX_TXT,30)
			Endif
		Endif
		
		If MENSAG3 # SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG3)
				DESC_MSG3 := Left(SRX->RX_TXT,30)
			ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG3)
				DESC_MSG3 := Left(SRX->RX_TXT,30)
			Endif
		Endif
		dbSelectArea("SRA")
		cFilialAnt := SRA->RA_FILIAL
	Endif
	
	Totvenc := Totdesc := 0
	
	If Esc == 1 .OR. Esc == 2
		If lTerminal
			If !ChkFile( "SRC", .F. )
			   cHtml := HtmlDefault( STR0121, STR0122 )
			   Return cHtml
			EndIf
	    Endif
		DbSelectArea("SRC")
		dbSetOrder(1)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT
				If SRC->RC_SEMANA # Semana
					dbSkip()
					Loop
				Endif
				If !Eval(cAcessaSRC)
					dbSkip()
					Loop
				EndIf
				If (Esc == 1) .And. (Src->Rc_Pd == aCodFol[7,1])      // Desconto de Adto
					u_fSomaPdRec("P",aCodFol[6,1],Eval(cNroHoras),SRC->RC_VALOR)
					TOTVENC += Src->Rc_Valor
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[12,1])
					u_fSomaPdRec("D",aCodFol[9,1],Eval(cNroHoras),SRC->RC_VALOR)
					TOTDESC += SRC->RC_VALOR
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[8,1])
					u_fSomaPdRec("P",aCodFol[8,1],Eval(cNroHoras),SRC->RC_VALOR)
					TOTVENC += SRC->RC_VALOR
				Else
					If PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
						If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
							If cPaisLoc == "PAR" .and. Eval(cNroHoras) == 30
								LocGHabRea(Ctod("01/"+SubStr(DTOC(dDataRef),4)), Ctod(StrZero(F_ULTDIA(dDataRef),2)+"/"+Strzero(Month(dDataRef),2)+"/"+right(str(Year(dDataRef)),2),"ddmmyy"),@nHoras)
							Else
								nHoras := Eval(cNroHoras)
							Endif
							u_fSomaPdRec("P",SRC->RC_PD,nHoras,SRC->RC_VALOR)
							TOTVENC += Src->Rc_Valor
						Endif
					Elseif SRV->RV_TIPOCOD == "2"
						If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
							u_fSomaPdRec("D",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
							TOTDESC += Src->Rc_Valor
						Endif
					Elseif SRV->RV_TIPOCOD == "3"
						//No Paraguai imprimir somente o valor liquido
						If cPaisLoc <> "PAR" .Or. (SRC->RC_PD == aCodFol[047,1])
							If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
								u_fSomaPdRec("B",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
							Endif
						Endif
					Endif
				Endif
				If ESC = 1
					If SRC->RC_PD == aCodFol[10,1]
						nBaseIr := SRC->RC_VALOR
					Endif
				ElseIf SRC->RC_PD == aCodFol[13,1]
					nAteLim += SRC->RC_VALOR
           // BASE FGTS SAL, 13.SAL E DIF DISSIDIO E DIF DISSIDIO 13
				Elseif SRC->RC_PD$ aCodFol[108,1]+'*'+aCodFol[17,1]+'*'+ aCodFol[337,1]+'*'+aCodFol[398,1]
					nBaseFgts += SRC->RC_VALOR
           // VALOR FGTS SAL, 13.SAL E DIF DISSIDIO E DIF.DISSIDIO 13
				Elseif SRC->RC_PD$ aCodFol[109,1]+'*'+aCodFol[18,1]+'*'+aCodFol[339,1]+'*'+aCodFol[400,1]
					nFgts += SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[15,1]
					nBaseIr += SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[16,1]
					nBaseIrFe += SRC->RC_VALOR
				Endif
				dbSelectArea("SRC")
				dbSkip()
			Enddo
		Endif
	Elseif Esc == 3 .And. !(cPaisLoc $ "URU|ARG|PAR")
		//��������������������������������������������������������������Ŀ
		//� Busca os codigos de pensao definidos no cadastro beneficiario�
		//����������������������������������������������������������������
		fBusCadBenef(@aCodBenef, "131",{aCodfol[172,1]})
		dbSelectArea("SRC")
		dbSetOrder(1)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
				If !Eval(cAcessaSRC)
					dbSkip()
					Loop
				EndIf
				If SRC->RC_PD == aCodFol[22,1] .And. !(SRC->RC_TIPO2 $ "K/R")
					u_fSomaPdRec("P",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
					TOTVENC += SRC->RC_VALOR
				Elseif Ascan(aCodBenef, { |x| x[1] == SRC->RC_PD }) > 0
					u_fSomaPdRec("D",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
					TOTDESC += SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[108,1] .Or. SRC->RC_PD == aCodFol[109,1] .Or. SRC->RC_PD == aCodFol[173,1] .or. SRC->RC_PD ==aCodFol[398,1] .Or. SRC->RC_PD == aCodFol[400,1] // acresc.dif.dissidio.13.sal
					u_fSomaPdRec("B",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
				Endif

				If SRC->RC_PD == aCodFol[108,1] .or. SRC->RC_PD == aCodFol[398,1] // base fgts 13.sal e base fgts dif.dissidio 13.sal. 
					nBaseFgts := SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[109,1] .or. SRC->RC_PD == aCodFol[400,1] // vlr fgts 13.sal e vlr fgts dif. dissidio 13.sal.
					nFgts     := SRC->RC_VALOR
				Endif
				dbSelectArea("SRC")
				dbSkip()
			Enddo
		Endif
	Elseif Esc == 4 .or. If(cPaisLoc $ "URU|ARG|PAR", Esc ==3,.F.)
		dbSelectArea("SRI")
		dbSetOrder(1)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRI->RI_FILIAL + SRI->RI_MAT
				If !Eval(cAcessaSRI)
					dbSkip()
					Loop
				EndIf
				If PosSrv( SRI->RI_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					u_fSomaPdRec("P",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
					TOTVENC = TOTVENC + SRI->RI_VALOR
				Elseif SRV->RV_TIPOCOD == "2"
					u_fSomaPdRec("D",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
					TOTDESC = TOTDESC + SRI->RI_VALOR
				Elseif SRV->RV_TIPOCOD == "3"
					u_fSomaPdRec("B",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
				Endif
				
				If SRI->RI_PD == aCodFol[19,1]
					nAteLim += SRI->RI_VALOR
				Elseif SRI->RI_PD$ aCodFol[108,1] .or.  SRI->RI_PD$ aCodFol[398,1] // acrescido base fgts dif.dissidio 13.sal.
					nBaseFgts += SRI->RI_VALOR
				Elseif SRI->RI_PD$ aCodFol[109,1] .or.  SRI->RI_PD$ aCodFol[400,1] // acrescido vlr fgts dif.dissidio 13.sal.
					nFgts += SRI->RI_VALOR
				Elseif SRI->RI_PD == aCodFol[27,1]
					nBaseIr += SRI->RI_VALOR
				Endif
				dbSkip()
			Enddo
		Endif
	Elseif Esc == 5
		dbSelectArea("SR1")
		dbSetOrder(1)
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
				If Semana # "99"
					If SR1->R1_SEMANA # Semana
						dbSkip()
						Loop
					Endif
				Endif
				If !Eval(cAcessaSR1)
					dbSkip()
					Loop
				EndIf
				If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					u_fSomaPdRec("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					TOTVENC = TOTVENC + SR1->R1_VALOR
				Elseif SRV->RV_TIPOCOD == "2"
					u_fSomaPdRec("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					TOTDESC = TOTDESC + SR1->R1_VALOR
				Elseif SRV->RV_TIPOCOD == "3"
					u_fSomaPdRec("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
				Endif
				dbskip()
			Enddo
		Endif
	Endif
	If cPaisLoc == "ARG"
		dbSelectArea("SRD")
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			While !Eof() .And. (SRA->RA_FILIAL+SRA->RA_MAT == SRD->RD_FILIAL+SRD->RD_MAT)
				If (SRA->RA_FILIAL+SRA->RA_MAT == SRD->RD_FILIAL+SRD->RD_MAT).And. SRD->RD_DATARQ == cAnoMesAnt
					If Esc == 1 .Or. Esc == 2
						cDtPago := dtoc(SRD->RD_DATPGT)
					ElseIf Esc == 3
						If SRD->RD_TIPO2 == "P"
							cDtPago := dtoc(SRD->RD_DATPGT)
						Endif
					ElseIf Esc == 4
						If SRD->RD_TIPO2 == "S"
							cDtPago := dtoc(SRD->RD_DATPGT)
						Endif
					Endif
				Endif
				dbSkip()
			Enddo
		Endif
	Endif
	dbSelectArea("SRA")
	
	If TOTVENC = 0 .And. TOTDESC = 0
		dbSkip()
		Loop
	Endif
	
	If Vez == 0  .And.  Esc == 2 //--> Verifica se for FOLHA.
		PerSemana() // Carrega Datas referentes a Semana.
	EndIf
	
	If nTipRel == 1 .and. !( lTerminal )
		fImpressao()   // Impressao do Recibo de Pagamento
		IF !( lTerminal )
			If Vez = 0  .and. nTipRel # 3  .and. aReturn[5] # 1
				//��������������������������������������������������������������Ŀ
				//� Descarrega teste de impressao                                �
				//����������������������������������������������������������������
				fImpTeste(cString)
				If !lRetCanc
					Exit
				Endif
				TotDesc := TotVenc := 0
				If mv_par01 = 2
					Loop
				Endif
				
			ENDIF
		EndIF
	ElseIf nTipRel == 2 .and. !( lTerminal )
		For nX := 1 to If(cPaisLoc <> "ARG",1,2)
			fImpreZebr()
		Next nX
		ASize(AProve,0)
		ASize(ADesco,0)
		ASize(aBases,0)
	ElseIf nTipRel == 3 .or. lTerminal
		cHtml := fSendDPgto(lTerminal)   //Monta o corpo do e-mail e envia-o
	Endif
	
	dbSelectArea("SRA")
	SRA->( dbSkip() )
	TOTDESC := TOTVENC := 0
	
EndDo

//��������������������������������������������������������������Ŀ
//� Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      �
//����������������������������������������������������������������
If !Empty( cAliasMov )
	fFimArqMov( cAliasMov , aOrdBag , cArqMov )
EndIf

IF !( lTerminal )
	
	//��������������������������������������������������������������Ŀ
	//� Termino do relatorio                                         �
	//����������������������������������������������������������������
	dbSelectArea("SRC")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRI")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRA")
	SET FILTER TO
	RetIndex("SRA")
	
	If !(Type("cArqNtx") == "U")
		fErase(cArqNtx + OrdBagExt())
	Endif
	
	Set Device To Screen
	
	If lEnvioOK
		APMSGINFO(STR0042)
	ElseIf nTipRel== 3
		APMSGINFO(STR0043)
	EndIf
	SeTPgEject(.F.)
	nlin:= 0	
	If aReturn[5] = 1 .and. nTipRel # 3
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif
	MS_FLUSH()
	
EndIF

Return( cHtml )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fImpressao� Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMRESSAO DO RECIBO FORMULARIO CONTINUO                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpressao()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpressao()

Local lLinhaRoda := .T.	// Variavel que informa se foram impressas todas as linhas do miolo do recibo.
Local nConta  := 0
Local nContr  := 0
Local nContrT :=0
Private nLinhas:=16              // Numero de Linhas do Miolo do Recibo

Ordem_Rel := 1

If cPaisLoc == "ARG"
	fCabecArg()
Else
	fCabec()
Endif

For nConta = 1 To Len(aLanca)
	fLanca(nConta)
	nContr ++
	nContrT ++
	If nContr = nLinhas .And. nContrT < Len(aLanca)
		nContr:=0
		Ordem_Rel ++
		fContinua()
		If cPaisLoc == "ARG"
			fCabecArg()
		Else
			fCabec()
		Endif
	Endif
Next nConta
Li:=Li -1
Li+=IF( lLinhaRoda := (nLinhas-nContr) == 0,1,(nLinhas-nContr))
If cPaisLoc == "ARG"
	@ ++LI,01 PSAY TRANS(TOTVENC,cPict1)
	@ LI,44 PSAY TRANS(TOTDESC,cPict1)
	@ LI,88 PSAY TRANS((TOTVENC-TOTDESC),cPict1)
	Li +=2
	@ Li,01 PSAY MesExtenso(MONTH(dDataRef)) + " de "+ STR(YEAR(dDataRef),4)
	@ ++Li,01 PSAY EXTENSO(TOTVENC-TOTDESC,,,)+REPLICATE("*",130-LEN(EXTENSO(TOTVENC-TOTDESC,,,)))
	@ ++Li,01 PSAY StrZero(Day(dDataRef),2) + " de " + MesExtenso(MONTH(dDataRef)) + " de "+STR(YEAR(dDataRef),4)
	@ ++Li,01 PSAY TRANS((TOTVENC-TOTDESC),cPict1)
Else
	fRodape(lLinhaRoda)
Endif

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fImpreZebr� Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMRESSAO DO RECIBO FORMULARIO ZEBRADO                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpreZebr()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpreZebr()

Local nConta    := nContr := nContrT:=0

If li >= 60
	li := 0
Endif
If cPaisLoc == "ARG"
	fCabecZAr()
Else
	fCabecZ()
Endif
fLancaZ(nConta)

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fCabec    � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMRESSAO Cabe�alho Form Continuo                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCabec()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCabec()   		// Cabecalho do Recibo
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario

/*��������������������������������������������������������������Ŀ
� Carrega Funcao do Funcion. de acordo com a Dt Referencia     �
����������������������������������������������������������������*/
fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )

@ PROW(),PCOL() PSAY ""
LI ++
@ LI,01 PSAY &cNormal+DESC_Fil
LI ++
@ LI,01 PSAY DESC_END
LI ++
@ LI,01 PSAY DESC_CGC

If !Empty(Semana) .And. Semana # '99' .And.  Upper(SRA->RA_TIPOPGT) == 'S'
	@ Li,37 pSay STR0013 + Semana + ' (' + cSem_De + STR0014 + ;	//'Semana '###' a '
	cSem_Ate + ')'
Else
	@ LI,55 PSAY MesExtenso(MONTH(dDataRef))+"/"+STR(YEAR(dDataRef),4)
EndIf

LI +=2
@ LI,01 PSAY SRA->RA_Mat
@ LI,08 PSAY Left(SRA->RA_NOME,28)
@ LI,37 PSAY fCodCBO(SRA->RA_FILIAL,cCodFunc ,dDataRef)
@ LI,44 PSAY SRA->RA_Filial
@ LI,47 PSAY PADC(ALLTRIM(SRA->RA_CC),20)
@ LI,67 PSAY ORDEM_REL PICTURE "99"
LI ++

cDet := STR0015       + cCodFunc						//-- Funcao
cDet += cDescFunc     + ' '
//cDet += DescCc(SRA->RA_CC,SRA->RA_FILIAL) + ' '
cDet += STR0016 + SRA->RA_CHAPA					//'CHAPA: '
@ Li,01 pSay cDet

Li += 3 //2
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fCabecz   � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMRESSAO Cabe�alho Form ZEBRADO                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCabecz()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCabecZ()   // Cabecalho do Recibo Zebrado
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario

/*��������������������������������������������������������������Ŀ
� Carrega Funcao do Funcion. de acordo com a Dt Referencia     �
����������������������������������������������������������������*/
fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )
@ Li,00 PSAY Avalimp(Limite)
LI ++
@ LI,00 PSAY "*"+REPLICATE("=",130)+"*"

LI ++
@ LI,00  PSAY  "|"
@ LI,46  PSAY STR0017		//"RECIBO DE PAGAMENTO  "
@ LI,131 PSAY "|"

LI ++
@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"

LI ++
@ LI,00  PSAY STR0018 +  DESC_Fil		//"| Empresa   : "
@ LI,92  PSAY STR0019 + SRA->RA_FILIAL	//" Local : "
@ LI,131 PSAY "|"

LI ++
@ LI,00 PSAY STR0020 + SRA->RA_CC + " - " + DescCc(SRA->RA_CC,SRA->RA_FILIAL)	//"| C Custo   : "
If !Empty(Semana) .And. Semana # "99" .And.  Upper(SRA->RA_TIPOPGT) == "S"
	@ Li,92 pSay STR0021 + Semana + " (" + cSem_De + STR0022 + ;   //'Sem.'###' a '
	cSem_Ate + ")"
Else
	@ LI,92 PSAY MesExtenso(MONTH(dDataRef))+"/"+STR(YEAR(dDataRef),4)
EndIf
@ LI,131 PSAY "|"

LI ++
ORDEMZ ++
@ LI,00  PSAY STR0023 + SRA->RA_MAT		//"| Matricula : "
@ LI,30  PSAY STR0024 + SRA->RA_NOME	//"Nome  : "
@ LI,92  PSAY STR0025						//"Ordem : "
@ LI,100 PSAY StrZero(ORDEMZ,4) Picture "9999"
@ LI,131 PSAY "|"

LI ++
@ LI,00  PSAY STR0026+cCodFunc+" - "+cDescFunc											//"| Funcao    : "

@ LI,131 PSAY "|"

LI ++
@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"

LI ++
@ LI,000 PSAY STR0027		//"| P R O V E N T O S "
@ LI,044 PSAY STR0028		//"  D E S C O N T O S"
@ LI,088 PSAY STR0029		//"  B A S E S"
@ LI,131 PSAY "|"

LI ++
@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
LI++

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCabecArg �Autor  �Silvia Taguti       � Data �  02/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao do Cabecalho - Argentina                          ���
���          �Pre Impresso                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCabecArg()
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
Local cCargo		:= ""		//-- Codigo do Cargo do funcionario

/*��������������������������������������������������������������Ŀ
� Carrega Funcao do Funcion. de acordo com a Dt Referencia     �
����������������������������������������������������������������*/
fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )

@ ++LI,01 PSAY DESC_Fil
@ ++LI,01 PSAY Alltrim(Desc_End)+" "+Alltrim(Desc_Comp)+" "+Desc_Cid
@ ++LI,01 PSAY DESC_CGC
@ ++LI,01 PSAY cDtPago
//@ LI,20 PSAY STR0072
@ LI,40 PSAY Alltrim(SRA->RA_BCDEPSAL) + "-" + DescBco(SRA->RA_BCDEPSAL,SRA->RA_FILIAL)
Li +=2
@ Li,01 PSAY SRA->RA_NOME
@ Li,45 PSAY SRA->RA_CIC
@ ++Li,01 PSAY SRA->RA_ADMISSA
@ Li,12 PSAY Substr(cDescFunc,1,15)
cCargo := fGetCargo(SRA->RA_MAT)
@ Li,30 PSAY Substr(fDesc("SQ3",cCargo,"SQ3->Q3_DESCSUM"),1,10)
Li += 2

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCabecZAr �Autor  �Microsiga           � Data �  02/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Impressao do Cabecalho - Argentina                         ���
���          � Zebrado                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCabecZAr()
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
Local cCargo		:= ""		//-- Codigo do Cargo do Funcionario

/*��������������������������������������������������������������Ŀ
� Carrega Funcao do Funcion. de acordo com a Dt Referencia     �
����������������������������������������������������������������*/
fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )


@ ++LI,00 PSAY "*"+REPLICATE("=",130)+"*"

@ ++LI,00  PSAY  "|"
@ LI,46  PSAY STR0090		//"RECIBO DE PAGAMENTO  "
@ LI,131 PSAY "|"

@ ++LI,00 PSAY "|"+REPLICATE("-",130)+"|"

@ ++LI,00  PSAY STR0087 + DESC_Fil		//"| Empregador   : "
@ LI,131 PSAY "|"

@ ++LI,00  PSAY STR0088 + Alltrim(Desc_End)+" "+Alltrim(Desc_Comp)+"-"+Desc_Est	//" Domicilio : "
@ LI,131 PSAY "|"

@ ++Li,00 PSAY STR0089 + DESC_CGC
@ LI,131 PSAY "|"

@ ++LI,00 PSAY STR0071 + cDtPago
@ LI,35 PSAY STR0072
@ LI,70 PSAY STR0073 + Alltrim(SRA->RA_BCDEPSAL) + "-" + DescBco(SRA->RA_BCDEPSAL,SRA->RA_FILIAL)
@ LI,131 PSAY "|"
@ ++LI,00 PSAY "|"+REPLICATE("-",130)+"|"
@ ++Li,00 PSAY STR0074 + SRA->RA_NOME
@ Li,45 PSAY STR0075 + SRA->RA_CIC
@ LI,130 PSAY "|"

@ ++Li,00 PSAY STR0076 + DTOC(SRA->RA_ADMISSA)
@ Li,30  PSAY STR0077 + Substr(cDescFunc ,1,15)
cCargo := fGetCargo(SRA->RA_MAT)
@ Li,80 PSAY STR0078 + Substr(fDesc("SQ3",cCargo,"SQ3->Q3_DESCSUM"),1,6)
@ LI,131 PSAY "|"
LI ++
@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"

LI ++
@ LI,000 PSAY STR0091		//"| H A B E R E S "
@ LI,046 PSAY STR0092		//"  D E D U C C I O N E S"
@ LI,090 PSAY STR0029		//"  B A S E S
@ LI,131 PSAY "|"

LI ++
@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
LI++

Return Nil



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fLanca    � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao das Verbas (Lancamentos) Form. Continuo          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fLanca()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fLanca(nConta)   // Impressao dos Lancamentos

Local cString := Transform(aLanca[nConta,5],cPict2)
Local nCol := If(aLanca[nConta,1]="P",43,If(aLanca[nConta,1]="D",57,27))

@ LI,01 PSAY aLanca[nConta,2]
@ LI,05 PSAY aLanca[nConta,3]
If aLanca[nConta,1] # "B"        // So Imprime se nao for base
	@ LI,36 PSAY TRANSFORM(aLanca[nConta,4],"999.99")
Endif
@ LI,nCol PSAY cString
Li ++

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fLancaZ   � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao das Verbas (Lancamentos) Zebrado                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fLancaZ()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fLancaZ(nConta)   // Impressao dos Lancamentos

Local nTermina  := 0
Local nCont     := 0
Local nCont1    := 0
Local nValidos  := 0

nTermina := Max(Max(LEN(aProve),LEN(aDesco)),LEN(aBases))

For nCont := 1 To nTermina
	@ LI,00 PSAY "|"
	IF nCont <= LEN(aProve)
		@ LI,02 PSAY aProve[nCont,1]+TRANSFORM(aProve[nCont,2],'999.99')+TRANSFORM(aProve[nCont,3],cPict3)
	ENDIF
	@ LI,44 PSAY "|"
	IF nCont <= LEN(aDesco)
		@ LI,46 PSAY aDesco[nCont,1]+TRANSFORM(aDesco[nCont,2],'999.99')+TRANSFORM(aDesco[nCont,3],cPict3)
	ENDIF
	@ LI,88 PSAY "|"
	IF nCont <= LEN(aBases)
		@ LI,90 PSAY aBases[nCont,1]+TRANSFORM(aBases[nCont,2],'999.99')+TRANSFORM(aBases[nCont,3],cPict3)
	ENDIF
	@ LI,131 PSAY "|"
	
	//---- Soma 1 nos nValidos e Linha
	nValidos ++
	Li ++
	
	If nValidos = If(cPaisLoc <> "ARG",12,10)
		@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
		LI ++
		@ LI,00 PSAY "|"
		@ LI,05 PSAY STR0030			// "CONTINUA !!!"
		//		@ LI,76 PSAY "|"+&cCompac
		LI ++
		@ LI,00 PSAY "*"+REPLICATE("=",130)+"*"
		LI += 8
		If li >= 60
			li := 0
		Endif
		If cPaisLoc == "ARG"
			fCabecZAr()
		Else
			fCabecZ()
		Endif
		nValidos := 0
	ENDIF
Next nCont

For nCont1 := nValidos+1 To If(cPaisLoc <> "ARG",12,10)
	@ Li,00  PSAY "|"
	@ Li,44  PSAY "|"
	@ Li,88  PSAY "|"
	@ Li,131 PSAY "|"
	Li++
Next nCont1
If cPaisLoc <> "ARG"
	@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
	LI ++
	@ LI,000 PSAY "|"
	@ LI,005 PSAY DESC_MSG1
	@ LI,044 PSAY STR0031+SPACE(10)+TRANS(TOTVENC,cPict1)	//"| TOTAL BRUTO     "
	@ LI,088 PSAY "|"+STR0032+SPACE(07)+TRANS(TOTDESC,cPict1)	//" TOTAL DESCONTOS     "
	@ LI,131 PSAY "|"
	LI ++
	@ LI,000 PSAY "|"
	@ LI,005 PSAY DESC_MSG2
	@ LI,044 PSAY "|"+REPLICATE("-",86)+"|"
	
	LI ++
	@ LI,000 PSAY "|"      
	@ LI,005 PSAY DESC_MSG3                   
	@ LI,044 PSAY STR0033+SRA->RA_BCDEPSAL+"-"+substr(DescBco(SRA->RA_BCDEPSAL,SRA->RA_FILIAL),1,25)	//"| CREDITO:"
	@ LI,088 PSAY STR0034+SPACE(05)+TRANS((TOTVENC-TOTDESC),cPict1)			//"| LIQUIDO A RECEBER     "
	@ LI,131 PSAY "|"
	
	LI ++
	@ LI,000 PSAY "|"+REPLICATE("-",130)+"|"
	
	LI ++
	@ LI,000 PSAY "|"
	@ LI,034 PSAY STR0035 + SRA->RA_CTDEPSAL		//"| CONTA:"
	@ LI,088 PSAY "|"
	@ LI,131 PSAY "|"
	
	LI ++
	@ LI,000 PSAY "|"+REPLICATE("-",130)+"|"
	
	LI ++
	@ LI,00  PSAY STR0036 + Replicate("_",40)		//"| Recebi o valor acima em ___/___/___ "
	@ li,131 PSAY "|"
	
	LI ++
	@ LI,00 PSAY "*"+REPLICATE("=",130)+"*"
Else
	fRodapeAr()
Endif

Li += 1

//Quebrar pagina
If LI > 63
	LI := 0
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fContinua � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressap da Continuacao do Recibo                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fContinua()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fContinua()    // Continuacao do Recibo

Li+=1
@ LI,05 PSAY &cNormal + STR0037		//"CONTINUA !!!"
Li+= 7 //8

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fRodape   � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Rodape                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fRodape()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fRodape(lLinhaRoda)    // Rodape do Recibo

If !lLinhaRoda
	LI += 1
Endif
@ LI,05 PSAY DESC_MSG1
LI ++
@ LI,05 PSAY DESC_MSG2
@ LI,42 PSAY TOTVENC PICTURE cPict1
@ LI,56 PSAY TOTDESC PICTURE cPict1
LI ++
@ LI,05 PSAY DESC_MSG3
LI ++
IF MONTH(dDataRef) = MONTH(SRA->RA_NASC)
	@ LI, 02 PSAY STR0038		//"F E L I Z   A N I V E R S A R I O  ! !"
ENDIF
@ LI,56 PSAY TOTVENC - TOTDESC PICTURE cPict1
LI +=2

If !Empty( cAliasMov )
	nValSal := 0
	nValSal := fBuscaSal(dDataRef)
	If nValSal ==0
		nValSal := SRA->RA_SALARIO
	EndIf
Else
	nValSal := SRA->RA_SALARIO
EndIf
@ LI,05 PSAY &cCompac+Transform(nValSal,cPict2)

If Esc = 1  // Bases de Adiantamento
	If cBaseAux = "S" .And. nBaseIr # 0
		@ LI,89 PSAY nBaseIr PICTURE cPict1
	Endif
ElseIf Esc = 2 .Or. Esc = 4  // Bases de Folha e 13o. 2o.Parc.
	If cBaseAux = "S"
		@ LI,23 PSAY Transform(nAteLim,cPict1)
		If nBaseFgts # 0
			@ LI,46 PSAY nBaseFgts PICTURE cPict1
		Endif
		If nFgts # 0
			@ LI,66 PSAY nFgts PICTURE cPict2
		Endif
		If nBaseIr # 	0
			@ LI,89 PSAY nBaseIr PICTURE cPict1
		Endif
		@ LI,103 PSAY Transform(nBaseIrfE,cPict1)
	Endif
ElseIf Esc = 3 // Bases de FGTS e FGTS Depositado da 1� Parcela
	If cBaseAux = "S"
		If nBaseFgts # 0
			@ LI,46 PSAY nBaseFgts PICTURE cPict1
		Endif
		If nFgts # 0
			@ LI,66 PSAY nFgts PICTURE cPict2
		Endif
	Endif
Endif

@ LI,Pcol() Psay &cNormal

Li ++
IF SRA->RA_BCDEPSAL # SPACE(8)
	Desc_Bco := DescBco(Sra->Ra_BcDepSal,Sra->Ra_Filial)
	@ LI,01 PSAY STR0039	//"CRED:"
	@ LI,06 PSAY SRA->RA_BCDEPSAL
	@ LI,14 PSAY "-"
	@ LI,15 PSAY DESC_BCO
	@ LI,50 PSAY STR0040 + SRA->RA_CTDEPSAL	//"CONTA:"
ENDIF
LI += 2
@ LI,05 PSAY " "
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fRodapeAr �Autor  �Silvia Taguti       � Data �  02/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Impressao Rodape-Argentina                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fRodapeAr()

@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
@ ++LI,00 PSAY "| " + STR0094 + TRANS(TOTVENC,cPict1)
@ LI,44 PSAY STR0095 +TRANS(TOTDESC,cPict1)
@ LI,88 PSAY STR0096 +TRANS((TOTVENC-TOTDESC),cPict1)
@ LI,131 PSAY "|"
@ ++LI,00 PSAY "|" + REPLICATE("-",130)+"|"
Li ++
@ Li,00 PSAY STR0079 + MesExtenso(MONTH(dDataRef)) + STR0080 + STR(YEAR(dDataRef),4)
@ LI,131 PSAY "|"
@ ++LI,00 PSAY "|" + REPLICATE("-",130) + "|"
@ ++Li,00 PSAY STR0081 +EXTENSO(TOTVENC-TOTDESC,,,"-")+REPLICATE("*",95-LEN(EXTENSO(TOTVENC-TOTDESC,,,"-")))
@ LI,131 PSAY "|"
@ ++Li,00 PSAY STR0082
@ LI,131 PSAY "|"
@ ++Li,00 PSAY STR0083
@ LI,131 PSAY "|"
@ ++Li,00 PSAY "|"
@ LI,131 PSAY "|"
@ ++Li,00 PSAY STR0084 + StrZero(Day(dDataRef),2) + STR0080 + MesExtenso(MONTH(dDataRef)) + STR0080+STR(YEAR(dDataRef),4)
@ Li,070 PSAY + REPLICATE("_",40)
@ LI,131 PSAY "|"
@ ++Li,00 PSAY STR0085 + TRANS((TOTVENC-TOTDESC),cPict1)
@ LI,131 PSAY "|"
@ ++Li,00 PSAY STR0086
@ LI,131 PSAY "|"
@ ++Li,00 PSAY "|"
@ LI,131 PSAY "|"
@ ++LI,00 PSAY "*"+REPLICATE("-",130)+"*"



Return Nil

********************
Static Function PerSemana() // Pesquisa datas referentes a semana.
********************
Local cChaveSem	:= ""

dbSelectArea( "RCF" )

If !Empty(Semana)
	
	cChaveSem := StrZero(Year(dDataRef),4)+StrZero(Month(dDataRef),2)+SRA->RA_TNOTRAB
	
	If !dbSeek(xFilial("RCF") + cChaveSem + Semana, .T. )
		cChaveSem := StrZero(Year(dDataRef),4)+StrZero(Month(dDataRef),2)+"   "
		If !dbSeek(xFilial("RCF") + cChaveSem + Semana  )
			HELP( " ",1,"GPCALEND",  )						//--Nao existe periodo cadastrado
			Return(NIL)
		Endif
	Endif
	cSem_De  := DtoC(RCF->RCF_DTINI,'DDMMYY')
	cSem_Ate := DtoC(RCF->RCF_DTFIM,'DDMMYY')
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �u_fSomaPdRec� Autor � R.H. - Mauro          � Data � 24.09.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Somar as Verbas no Array                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � u_fSomaPdRec(Tipo,Verba,Horas,Valor)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function fSomaPdRec(cTipo,cPd,nHoras,nValor)

Local Desc_paga

Desc_paga := DescPd(cPd,Sra->Ra_Filial)  // mostra como pagto

If cTipo # 'B'
	//--Array para Recibo Pre-Impresso
	nPos := Ascan(aLanca,{ |X| X[2] = cPd })
	If nPos == 0
		Aadd(aLanca,{cTipo,cPd,Desc_Paga,nHoras,nValor})
	Else
		aLanca[nPos,4] += nHoras
		aLanca[nPos,5] += nValor
	Endif
Endif

//--Array para o Recibo Pre-Impresso
If cTipo = 'P'
	cArray := "aProve"
Elseif cTipo = 'D'
	cArray := "aDesco"
Elseif cTipo = 'B'
	cArray := "aBases"
Endif

nPos := Ascan(&cArray,{ |X| X[1] = cPd })
If nPos == 0
	Aadd(&cArray,{cPd+" "+Desc_Paga,nHoras,nValor })
Else
	&cArray[nPos,2] += nHoras
	&cArray[nPos,3] += nValor
Endif
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fSendDPgto| Autor � R.H.-Natie            � Data � 15.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envio de E-mail -Demonstrativo de Pagamento                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico :Envio Demonstrativo de Pagto atraves de eMail  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fSendDPgto(lTerminal)

Local aSvArea		:= GetArea()
Local aGetArea		:= {}
Local cEmail		:= If(SRA->RA_RECMAIL=="S",SRA->RA_EMAIL,"    ")
Local cHtml			:= ""
Local cHtmlAux		:= NIL
Local cSubject		:= STR0044	//" DEMONSTRATIVO DE PAGAMENTO "
Local cMesComp		:= IF( Month(dDataRef) + 1 > 12 , 01 , Month(dDataRef) )
Local cTipo			:= ""
Local cReferencia	:= ""
Local cVerbaLiq		:= ""
Local dDataPagto	:= Ctod("//")
Local nZebrado		:= 0.00
Local nResto		:= 0.00
Local nProv
Local nDesco
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario

Private cMailConta	:= NIL
Private cMailServer	:= NIL
Private cMailSenha	:= NIL
Private nSalario		:= 0

lTerminal := IF( lTerminal == NIL .or. ValType( lTerminal ) != "L" , .F. , lTerminal )

IF Esc == 1
	aGetArea	:= SRC->( GetArea() )
	cTipo		:= STR0060 // "Adiantamento"
	cVerbaLiq	:= PosSrv( "007ADT" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	SRC->( dbSetOrder( RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ") ) )
	IF SRC->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + cVerbaLiq ) )
		While SRC->( !Eof() .and. RC_FILIAL + RC_MAT == SRA->( RA_FILIAL + RA_MAT ) )
			IF Empty( Semana ) .or. ( SRC->RC_SEMANA == Semana )
				dDataPagto := SRC->RC_DATA
				Exit
			EndIF
			SRC->( dbSkip() )
		End While
	EndIF
	RestArea( aGetArea )
ElseIF Esc == 2
	aGetArea	:= SRC->( GetArea() )
	cTipo := STR0061	//"Folha"
	cVerbaLiq	:= PosSrv( "047CAL" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	SRC->( dbSetOrder( RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ") ) )
	IF SRC->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + cVerbaLiq ) )
		While SRC->( !Eof() .and. RC_FILIAL + RC_MAT == SRA->( RA_FILIAL + RA_MAT ) )
			IF Empty( Semana ) .or. ( SRC->RC_SEMANA == Semana )
				dDataPagto := SRC->RC_DATA
				Exit
			EndIF
			SRC->( dbSkip() )
		End While
	EndIF
	RestArea( aGetArea )
ElseIF Esc == 3
	aGetArea	:= SRC->( GetArea() )
	cTipo := STR0062 //"1a. Parcela do 13o."
	cVerbaLiq	:= PosSrv( "022C13" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	SRC->( dbSetOrder( RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ") ) )
	IF SRC->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + cVerbaLiq ) )
		While SRC->( !Eof() .and. RC_FILIAL + RC_MAT == SRA->( RA_FILIAL + RA_MAT ) )
			IF Empty( Semana ) .or. ( SRC->RC_SEMANA == Semana )
				dDataPagto := SRC->RC_DATA
				Exit
			EndIF
			SRC->( dbSkip() )
		End While
	EndIF
	RestArea( aGetArea )
ElseIF Esc == 4
	aGetArea	:= SRI->( GetArea() )
	cTipo := STR0063 //"2a. Parcela do 13o."
	cVerbaLiq	:= PosSrv( "021C13" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	SRI->( dbSetOrder( RetOrdem("SRI","RI_FILIAL+RI_MAT+RI_PD") ) )
	IF SRI->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + cVerbaLiq ) )
		dDataPagto := SRI->RI_DATA
	EndIF
ElseIF Esc == 5
	cTipo		:= STR0064 //"Valores Extras"
	cVerbaLiq	:= ""
EndIF

IF !( lTerminal )
	
	//��������������������������������������������������������������Ŀ
	//� Busca parametros                                             �
	//����������������������������������������������������������������
	cMailConta	:=If(cMailConta == NIL,GETMV("MV_EMCONTA"),cMailConta)             //Conta utilizada p/envio do email
	cMailServer	:=If(cMailServer == NIL,GETMV("MV_RELSERV"),cMailServer)           //Server
	cMailSenha	:=If(cMailSenha == NIL,GETMV("MV_EMSENHA"),cMailSenha)
	
	If Empty(cEmail)
		Return
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Verifica se existe o SMTP Server                             �
	//����������������������������������������������������������������
	If 	Empty(cMailServer)
		Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Verifica se existe a CONTA                                   �
	//����������������������������������������������������������������
	If 	Empty(cMailServer)
		Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf
	
EndIF

IF ( !Empty(Semana) .and. ( Semana # "99" ) .and. ( Upper(SRA->RA_TIPOPGT) == "S" ) )
	/*
	��������������������������������������������������������������Ŀ
	� Carrega Datas Referente a semana                             �
	����������������������������������������������������������������*/
	PerSemana()
	cReferencia := STR0045 + Semana + " (" + cSem_De + STR0046 +	cSem_Ate + ")" //"Semana  "###" a "
Else
	cReferencia	:= AllTrim( MesExtenso(Month(dDataRef))+"/"+STR(YEAR(dDataRef),4) ) + " - ( " + cTipo + " )"
EndIF

IF !Empty( cAliasMov )
	nSalario := fBuscaSal( dDataRef )
	IF ( nSalario == 0 )
		nSalario := SRA->RA_SALARIO
	EndIf
Else
	nSalario := SRA->RA_SALARIO
EndIF


cHtml +=	'<html>'
cHtml +=		'<head>'
IF !( lTerminal )
	
	cHtml += 		'<title>DEMONSTRATIVO DE PAGAMENTO</title>'
	cHtml +=			'<style>'
	cHtml +=				'th { text-align:left; background-color:#4B87C2; line-height:01; line-width:400; border-left:0px solid  #FF9B06; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:0px solid #FF9B06 }'
	cHtml +=				'.tdPrinc { text-align:left; line-height:1; line-width:340 ; border-left:0px solid #FF9B06; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:0px solid #FF9B06; color="#000082" }'
	cHtml +=				'.td18_94_AlignR { text-align:right ; line-height:1; line-width:94; color="#000082" }'
	cHtml +=				'.td18_95_AlignR { text-align:right ; line-height:1; line-width:95; color="#000082" }'
	cHtml +=				'.td26_94_AlignR { text-align:right ; line-height:1; line-width:94; color="#000082" }'
	cHtml +=				'.td26_95_AlignR { text-align:right ; line-height:1; line-width:95; color="#000082" }'
	cHtml += 				'.td26_18_AlignL { lext-align:left ; line-height:1; line:width:18 ; border-left:0px solid #FF9B06; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:0px solid #FF9B06 bgcolor=#6F9ECE" }'
	cHtml +=    			'.pStyle1 { line-height:100% ; margin-top:15 ; margin-bottom:0; color="#000082" }'
	cHtml +=			'</style>'
	cHtml +=	'</head>'
	cHtml +=		'<body bgcolor="#F0F0F0"  topmargin="0" leftmargin="0">'
	cHtml +=			'<center>'
	cHtml +=				'<table  border="1" cellpadding="0" cellspacing="0" bordercolor="#000082" bgcolor="#000082" width=598 height="637">'

	//Cabecalho
	cHtml +=    				'<td width="598" height="181" bgcolor="#FFFFFF">'
	cHtml += 					'<center>'
	cHtml += 					'<font color="#000000">'
	cHtml +=					'<b>'
	cHtml += 					'<h4 size="03">'
	cHtml +=					'<br>'
	cHtml += 						STR0044 // " DEMONSTRATIVO DE PAGAMENTO "
	cHtml += 					'<br>'
	
Else
	
	cHtml += 		'<title>RH Online</title>' + CRLF
	cHtml += 		'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' + CRLF
	cHtml += 		'<link rel="stylesheet" href="css/rhonline.css" type="text/css">' + CRLF
	cHtml += 	'</head>' + CRLF
	cHtml += 	'<body bgcolor="#FFFFFF" text="#000000">' + CRLF
	cHtml += 		'<Table width="515" border="0" cellspacing="0" cellpadding="0">' + CRLF
	
	//Cabecalho
	cHtml += 			CabecHtml( cReferencia , dDataPagto , dDataRef )
	
	//Separador
	cHtml +=			"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=				"<TBODY>" + CRLF
	cHtml +=					"<TR>" + CRLF
	cHtml +=						"<TD vAlign=top width='100%' height=10>" + CRLF
	cHtml +=						"</TD>" + CRLF
	cHtml +=	 				"</TR>" + CRLF
	cHtml +=				"</TBODY>" + CRLF
	cHtml +=			"</TABLE>" + CRLF
	
	cHtml +=			"<TABLE border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=				"<TBODY>" + CRLF
EndIF

If !Empty(Semana) .And. Semana # "99" .And.  Upper(SRA->RA_TIPOPGT) == "S"
	IF !( lTerminal )
		cHtml += cReferencia
	EndIF
Else
	IF !( lTerminal )
		cHtml += cReferencia
	EndIF
EndIf

/*��������������������������������������������������������������Ŀ
� Carrega Funcao do Funcion. de acordo com a Dt Referencia     �
����������������������������������������������������������������*/
fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )

IF !( lTerminal )
	
	cHtml += '</b></h4></font></center>'
	cHtml += '<hr width = 100% align=right color="#000082">'

	//��������������������������������������������������������������Ŀ
	//� Dados da Empresa	                                         �
	//����������������������������������������������������������������
	cHtml += '<!Dados da Empresa>'
	cHtml += '<p align=left  style="margin-top: 0">'
	cHtml +=   '<font color="#000082" face="Courier New"><i><b>'
	cHtml +=  	'&nbsp;&nbsp;&nbsp;' + Desc_Fil+'</i></b></font><br>'  //Empresa
	cHtml += 	'<font color="#000082" face="Courier New" size="2">'
	cHtml += 	'&nbsp;&nbsp;&nbsp;&nbsp;'+ STR0098  + Desc_End	+'<br>'		//Endere�o
	cHtml += 	'&nbsp;&nbsp;&nbsp;&nbsp;' +STR0117  + Desc_Cid	+ '&nbsp;&nbsp;&nbsp;'+STR0118+Desc_Est+'<br>'
	cHtml +=  	'&nbsp;&nbsp;&nbsp;&nbsp;'+ STR0099  + Transform( Desc_CGC , "@R 99.999.999/9999-99")  	//CNPJ
	cHtml += '</p></font>'

	//��������������������������������������������������������������Ŀ
	//� Dados do funcionario                                         �
	//����������������������������������������������������������������
	//cHtml += '<hr width = 100% align=right color="#FF812D">'
	cHtml += '<hr width = 100% align=right color="#000082">'
	cHtml += '<!Dados do Funcionario>'
	cHtml += '<p align=left  style="margin-top: 0">'
	cHtml +=   '<font color="#000082" face="Courier New"><i><b>'
	cHtml +=  	'&nbsp;&nbsp;&nbsp;' + SRA->RA_NOME + "- " + SRA->RA_MAT+'</i></b></font><br>'
	cHtml += 	'<font color="#000082" face="Courier New" size="2">'
	cHtml += 	'&nbsp;&nbsp;&nbsp;&nbsp;' + STR0048 + cCodFunc + "  "+cDescFunc	+'<br>' //"Funcao    - "
	cHtml +=  	'&nbsp;&nbsp;&nbsp;&nbsp;' + STR0047 + SRA->RA_CC + " - " + DescCc(SRA->RA_CC,SRA->RA_FILIAL) +'<br>' //"C.Custo   - "
	cHtml +=    '&nbsp;&nbsp;&nbsp;&nbsp;' + STR0049 + SRA->RA_BCDEPSAL+" - "+DescBco(SRA->RA_BCDEPSAL,SRA->RA_FILIAL)+ '&nbsp;'+  SRA->RA_CTDEPSAL //"Bco/Conta - "
	cHtml += '</p></font>'

	cHtml += '<!Proventos e Desconto>'
	cHtml += '<div align="center">'
	cHtml += '<Center>'
	cHtml += '<Table bgcolor="#F0F8FF" style="border: 1px #003366 solid;" border="0" cellpadding ="1" cellspacing="0" width="553" height="296">'
	cHtml +=    '<tr bgcolor="A2B5CD">' 
	cHtml += 	'<td><font face="Arial" size="02" color="#000082"><b>' + STR0050 + '</b></font></td>' //"Cod  Descricao "
	cHtml += 	'<td align="right"><font face="Arial" size="02" color="#000082"><b>' + STR0051 + '</b></font></td>' //"Referencia"
	cHtml += 	'<td align="right"><font face="Arial" size="02" color="#000082"><b>' + STR0052 + '</b></font></td>' //"Valores"
	cHtml += 	'<td>&nbsp;</td>'
	cHtml += 	'</tr>'
	
	//��������������������������������������������������������������Ŀ
	//� Espacos Entre os Cabecalho e os Proventos/Descontos          �
	//����������������������������������������������������������������
	cHtml += 	'<tr>'
	cHtml += 		'<td class="tdPrinc"></td>'
	cHtml += 		'<td class="td18_94_AlignR">&nbsp;&nbsp</td>'
	cHtml += 		'<td class="td18_95_AlignR">&nbsp;&nbsp</td>'
	cHtml += 		'<td class="td18_18_AlignL"></td>'
	cHtml += 	'</tr>' 
	
Else
	
	//Cabecalho dos valores
	cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=						"<TBODY>" + CRLF
	cHtml += 							'<tr align="center">' + CRLF
	cHtml += 								'<td width="45" height="1">' + CRLF
	cHtml += 									'<span class="etiquetas"><div align="Left">'+ STR0068 + '</span></div>' + CRLF //C&oacute;digo
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="219" valign="top">' + CRLF
	cHtml += 									'<span class="etiquetas"><div align="left">' + STR0069 + '</span></div>' + CRLF //Descri&ccedil;&atilde;o
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top">' + CRLF
	cHtml += 									'<span class="etiquetas"><div align="right">' + STR0070  + '</span></div>' + CRLF //Refer&ecirc;ncia
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top">' + CRLF
	cHtml += 									'<span class="etiquetas"><div align="right">' + STR0052 + '</span></div>' + CRLF //Valores
	cHtml += 								'<td width="107" valign="top">' + CRLF
	cHtml += 									'<span class="etiquetas"><div align="right"> (+/-) </span></div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 							'</tr>' + CRLF
	cHtml +=						"</TBODY>" + CRLF
	cHtml += 					'</TABLE>' + CRLF
	
	//Separador
	cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=						"<TBODY>" + CRLF
	cHtml +=							"<TR>" + CRLF
	cHtml +=								"<TD vAlign=top width='100%' height=05>" + CRLF
	cHtml +=								"</TD>" + CRLF
	cHtml +=	 						"</TR>" + CRLF
	cHtml +=						"</TBODY>" + CRLF
	cHtml +=					"</TABLE>" + CRLF
	
	cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=						"<TBODY>" + CRLF
	cHtml +=							"<TR>" + CRLF
	
EndIF

//��������������������������������������������������������������Ŀ
//� Proventos                                                    �
//����������������������������������������������������������������
	For nProv:=1 To Len( aProve )
	
	nResto := ( ++nZebrado % 2 )
	
	IF !( lTerminal )
		
		cHtml += '<tr>'
		cHtml += 	'<td class="tdPrinc">' + aProve[nProv,1] + '</td>'
		cHtml += 	'<td class="td18_94_AlignR">' + Transform(aProve[nProv,2],'999.99')+'</td>'
		cHtml += 	'<td class="td18_95_AlignR">' + Transform(aProve[nProv,3],cPict3) + '</td>'
		cHtml +=    '<td class="td18_18_AlignL"></td>'
		cHtml += '</tr>'
		
	Else
		
		cHtml += 							'<tr>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="45" vAlign=top height="1" bgcolor="#FAFBFC">'
		Else
			cHtml += 							'<td width="45" vAlign=top height="1">' + CRLF
		EndIF
		cHtml += 									'<div align="left"><span class="dados">'  + Substr( aProve[nProv,1] , 1 , 3 ) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="219" vAlign=top="top">' + CRLF
		EndIF
		cHtml += 									'<div align="Left"><span class="dados">'  + Capital( AllTrim( Substr( aProve[nProv,1] , 4 ) ) ) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="127" valign="top">' + CRLF
		EndIF
		cHtml += 									'<div align="right"><span class="dados">' + Transform(aProve[nProv,2],'999.99') + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="127" valign="top">' + CRLF
		EndIF
		cHtml += 									'<div align="right"><span class="dados">' + Transform(aProve[nProv,3],cPict3) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="107" valign="top">' + CRLF
		EndIF
		cHtml += 									'<div align="right"><span class="dados"> (+) </span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 							'</tr>' + CRLF
	EndIF
Next nProv

IF ( lTerminal )
	cHtml +=							"</TR>" + CRLF
	cHtml +=							"<TR>" + CRLF
EndIF

//��������������������������������������������������������������Ŀ
//� Descontos                                                    �
//����������������������������������������������������������������
For nDesco := 1 to Len(aDesco)
	
	nResto := ( ++nZebrado % 2 )
	
	IF !( lTerminal )
		
		cHtml += '<tr>'
		cHtml += 	'<td class="tdPrinc">' + aDesco[nDesco,1] + '</td>'
		cHtml += 	'<td class="td18_94_AlignR">' + Transform(aDesco[nDesco,2],'999.99') + '</td>'
		cHtml += 	'<td class="td18_95_AlignR">' + Transform(aDesco[nDesco,3],cPict3) + '</td>'
		cHtml += 	'<td class="td18_18_AlignL">-</td>'
		cHtml += '</tr>'
		
	Else
		
		cHtml += 							'<tr>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="45" align="center" height="19" bgcolor="#FAFBFC">'
		Else
			cHtml += 							'<td width="45" align="center" height="19">' + CRLF
		EndIF
		cHtml += 									'<div align="left"><span class="dados">'  + Substr( aDesco[nDesco,1] , 1 , 3 ) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="219" valign="top">' + CRLF
		EndIF
		cHtml += 									'<div align="Left"><span class="dados">'  + Capital( AllTrim( Substr( aDesco[nDesco,1] , 4 ) ) ) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="127" valign="top">' + CRLF
		EndIF
		cHtml += 									'<div align="right"><span class="dados">' + Transform(aDesco[nDesco,2],'999.99') + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="127" valign="top">' + CRLF
		EndIF
		cHtml += 									'<div align="right"><span class="dados">' + Transform(aDesco[nDesco,3],cPict3) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		IF nResto > 0.00
			cHtml += 							'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
		Else
			cHtml += 							'<td width="107" valign="top">' + CRLF
		EndIF
		cHtml += 									'<div align="right"><span class="dados"> (-) </span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 							'</tr>' + CRLF
	EndIF
Next nDesco

IF ( lTerminal )
	
	cHtml +=							"</TR>" + CRLF
	cHtml +=						"</TBODY>" + CRLF
	cHtml +=					"</TABLE>" + CRLF
	
	//Separador
	cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=						"<TBODY>" + CRLF
	cHtml +=							"<TR>" + CRLF
	cHtml +=								"<TD vAlign=top width='100%' height=05>" + CRLF
	cHtml +=								"</TD>" + CRLF
	cHtml +=	 						"</TR>" + CRLF
	cHtml +=						"</TBODY>" + CRLF
	cHtml +=					"</TABLE>" + CRLF
	
	cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=						"<TBODY>" + CRLF
	cHtml +=							"<TR>" + CRLF
	
EndIF

IF !( lTerminal )
	
	//��������������������������������������������������������������Ŀ
	//� Espacos Entre os Proventos e Descontos e os Totais           �
	//����������������������������������������������������������������
	cHtml += 	'<tr>'
	cHtml += 		'<td class="tdPrinc"></td>'
	cHtml += 		'<td class="td18_94_AlignR">&nbsp;&nbsp</td>'
	cHtml += 		'<td class="td18_95_AlignR">&nbsp;&nbsp</td>'
	cHtml += 		'<td class="td18_18_AlignL"></td>'
	cHtml += 	'</tr>'
	
	//��������������������������������������������������������������Ŀ
	//� Totais                                                       �
	//����������������������������������������������������������������
	cHtml += '<!Totais >'
	cHtml +=	'<b><i>'
	cHtml += 	'<tr>'
	cHtml += 		'<td class="tdPrinc">' + STR0053 + '</td>' //"Total Bruto "
	cHtml += 		'<td class="td18_94_AlignR"></td>'
	cHtml += 		'<td class="td18_95_AlignR">' + Transform(TOTVENC,cPict3) + '</td>'
	cHtml += 		'<td class="td18_18_AlignL"></td>'
	cHtml +=	'</tr>'
	cHtml += 	'<tr>'
	cHtml += 		'<td class="tdPrinc">' + STR0054 + '</td>' //"Total Descontos "
	cHtml += 		'<td class="td18_94_AlignR"></Td>'
	cHtml += 		'<td class="td18_95_AlignR">' + Transform(TOTDESC,cPict3) + '</td>'
	cHtml += 		'<td class="td18_18_AlignL">-</td>'
	cHtml += 	'</tr>'
	cHtml += 	'<tr>'
	cHtml += 		'<td class="tdPrinc">' + STR0055 + '</td>' //"Liquido a Receber "
	cHtml += 		'<td class="td18_94_AlignR"></td>'
	cHtml += 		'<td align=right height="18" width="95" Style="border-left:0px solid #FF812D; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:1px solid #000082 bgcolor=#4B87C2">'
	cHtml +=        '<font color="#000082">' + Transform((TOTVENC-TOTDESC),cPict3) + '</font></td>'
	cHtml += 	'</tr>'
	cHtml += '<!Bases>'
	cHtml += 	'<tr>'
	
Else
	
	//Total de Proventos
	cHtml += 							'<tr>' + CRLF
	cHtml += 								'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> ' + STR0065 + '</div>' + CRLF //"Total Bruto: "
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="45" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="right"><span class="dados">' + Transform(TOTVENC,cPict3) + '</span></div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="right"><span class="dados"> (+) </span></div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 							'</tr>' + CRLF
	
	//Total de Descontos
	cHtml += 							'<tr>' + CRLF
	cHtml += 								'<td width="219" valign="top">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> ' + STR0066 + '</div>' + CRLF //"Total de Descontos: "
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="45" valign="top">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top">' + CRLF
	cHtml += 									'<div align="right"><span class="dados">' + Transform(TOTDESC,cPict3) + '</span></div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="107" valign="top">' + CRLF
	cHtml += 									'<div align="right"><span class="dados"> (-) </span></div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 							'</tr>' + CRLF
	
	
	//Liquido
	cHtml += 							'<tr>' + CRLF
	cHtml += 								'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas">' + STR0067  + '</div>' + CRLF //"L&iacute;quido a Receber: "
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="45" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="right"><span class="dados">' + Transform((TOTVENC-TOTDESC),cPict3) + '</span></div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 								'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
	cHtml += 									'<div align="right"><span class="dados"> (=) </span></div>' + CRLF
	cHtml += 								'</td>' + CRLF
	cHtml += 							'</tr>' + CRLF
	
	cHtml +=							"</TR>" + CRLF
	cHtml +=						"</TBODY>" + CRLF
	cHtml +=					"</TABLE>" + CRLF
	
	//Separador
	cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=						"<TBODY>" + CRLF
	cHtml +=							"<TR>" + CRLF
	cHtml +=								"<TD vAlign=top width='100%' height=10>" + CRLF
	cHtml +=								"</TD>" + CRLF
	cHtml +=	 						"</TR>" + CRLF
	cHtml +=						"</TBODY>" + CRLF
	cHtml +=					"</TABLE>" + CRLF
	
	cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=						"<TBODY>" + CRLF
	cHtml +=							"<TR>" + CRLF
	
EndIF

//��������������������������������������������������������������Ŀ
//� Espacos Entre os Totais e as Bases                           �
//����������������������������������������������������������������
IF !( lTerminal )
	cHtml += 	'<tr>'
	cHtml += 		'<td class="tdPrinc"></td>'
	cHtml += 		'<td class="td18_94_AlignR">&nbsp;&nbsp</td>'
	cHtml += 		'<td class="td18_95_AlignR">&nbsp;&nbsp</td>'
	cHtml += 		'<td class="td18_18_AlignL"></td>'
	cHtml += 	'</tr>'    
	
	//��������������������������������������������������������������Ŀ
	//� Salario Base                                                 �
	//����������������������������������������������������������������
	cHtml +=	'<tr>'
	cHtml +=		'<td class="tdPrinc"><p class="pStyle1">'+STR0120+'</p></td>' //"Salario Base
	cHtml +=		'<td class="td26_94_AlignR"><p></p></td>'
	cHtml +=		'<td class="td26_95_AlignR"><p>'+ Transform(nSalario,cPict1)+'</p></td>'
	cHtml += '</tr>'
	
Else
	cHtml += '<table width="498" border="0" cellspacing="0" cellpadding="0">' + CRLF
EndIF

//��������������������������������������������������������������Ŀ
//� Base de Adiantamento                                         �
//����������������������������������������������������������������
If Esc = 1
	If cBaseAux = "S" .And. nBaseIr # 0
		IF !( lTerminal )
			cHtml +=	'<tr>'
			cHtml +=		'<td class="tdPrinc"><p class="pStyle1"><font color=#000082 face="Courier new" size=2><i>'+STR0058+'</i></p></td></font>' //"Base IR Adiantamento"
			cHtml +=		'<td class="td26_94_AlignR"><p></td>'
			cHtml +=		'<td class="td26_95_AlignR"><p>'+ Transform(nBaseIr,cPict1)+'</td>'
			cHtml +=		'<td class="td26_18_AlignL"><p></td>'
			cHtml += 	'</tr>'
		Else
			cHtml += '<tr>'
			cHtml += '<td width="304" class="etiquetas">' + STR0058 + ' + </td>' + CRLF
			cHtml += '<td width="103" class="dados"><div align="center">' + Transform(nBaseIr,cPict3) + '</div></td>' + CRLF
			cHtml += '<td width="91"  class="dados"><div align="center">' + Transform(0.00   ,cPict3) + '</div></td>' + CRLF
			cHtml += '</tr>'
		EndIF
	Endif
	//��������������������������������������������������������������Ŀ
	//� Base de Folha e de 13o 20 Parc.                              �
	//����������������������������������������������������������������
ElseIf Esc = 2 .Or. Esc = 4
	
	IF cBaseAux = "S"
		
		IF !( lTerminal )
			
			cHtml += '<tr>'
			cHtml +=	'<td class="tdPrinc">'
			cHtml +=    '<p class="pStyle1">'+ STR0056 +'</p></td>'//"Base FGTS/Valor FGTS"
			cHtml +=	'<td class="td26_94_AlignR">' + Transform(nBaseFgts,cPict3)+'</td>'
			cHtml +=	'<td class="td26_95_AlignR">' + Transform(nFgts    ,cPict3)+'</td>'
			cHtml += '</tr>'
			cHtml += '<tr>'
			cHtml +=	'<td class="tdPrinc">'
			cHtml +=    '<p class="pStyle1">'+ STR0057 +'</p></td>'//"Base IRRF Folha/Ferias"
			cHtml +=	'<td class="td26_94_AlignR">' + Transform(nBaseIr,cPict3)+'</td>'
			cHtml +=	'<td class="td26_95_AlignR">' + Transform(nBaseIrfe,cPict3)+'</td>'
			cHtml += '</tr>'                                   
			cHtml += '<tr>'
			cHtml +=	'<td class="tdPrinc">'
			cHtml +=    '<p class="pStyle1">'+ STR0116 +'</p></td>'//"Base INSS"
			cHtml +=	'<td class="td26_94_AlignR">' + Transform(nAteLim,cPict3)+'</td>'
			cHtml += '</tr>'
		
		Else
			
			cHtml += 								"<tr>"
			cHtml += 									"<td width=219' bgcolor='#FAFBFC' class='etiquetas'>"
			cHtml +=										STR0056 + CRLF //"Base FGTS/Valor FGTS"
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='45' bgcolor='#FAFBFC' class='dados'>" + CRLF
			cHtml += 										'<div align="left" class="etiquetas"> </div>' + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='127' bgcolor='#FAFBFC' class='dados'>" + CRLF
			cHtml +=										"<div align='right'>" + Transform(nBaseFgts,cPict3) + "</div>" + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='127'  bgcolor='#FAFBFC' class='dados'>" + CRLF
			cHtml +=										"<div align='right'>" + Transform(nFgts    ,cPict3) + "</div>" + CRLF
			cHtml +=									'</td>' + CRLF
			cHtml += 									"<td width='107' valign='top' bgcolor='#FAFBFC'>" + CRLF
			cHtml += 										"<div align='right'><span class='dados'></span></div>" + CRLF
			cHtml += 									"</td>" + CRLF
			cHtml += 								"</tr>" + CRLF
			
			cHtml += 								"<tr>" + CRLF
			cHtml += 									"<td width='219' class='etiquetas'>"
			cHtml +=										STR0057 + CRLF //"Base IRRF Folha/Ferias"
			cHtml += 									"</td>" + CRLF
			cHtml += 									"<td width='45' class='dados'>" + CRLF
			cHtml += 										'<div align="left" class="etiquetas"> </div>' + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='127' class='dados'>" + CRLF
			cHtml +=											"<div align='right'>" + Transform(nBaseIr,cPict3) + "</div>" + CRLF
			cHtml += 									"</td>" + CRLF
			cHtml += 									"<td width='127'  class='dados'>"  + CRLF
			cHtml += 										"<div align='right'>" + Transform(nBaseIrFe,cPict3) + "</div>" + CRLF
			cHtml += 									"</td>" + CRLF
			cHtml += 									"<td width='107' class='dados'>" + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 								'</tr>'
			
			cHtml += 								"<tr>" + CRLF
			cHtml += 									"<td width='219' class='etiquetas' bgcolor='#FAFBFC' >"
			cHtml +=										STR0116 + CRLF //"Base INSS"
			cHtml += 									"</td>" + CRLF
			cHtml += 									"<td width='45' class='dados'>" + CRLF
			cHtml += 										'<div align="left" class="etiquetas" bgcolor="#FAFBFC"> </div>' + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='127' class='dados' bgcolor='#FAFBFC' >" + CRLF
			cHtml +=											"<div align='right'>" + Transform(nAteLim,cPict3) + "</div>" + CRLF
			cHtml += 									"</td>" + CRLF
			cHtml += 									"<td width='127'  class='dados' bgcolor='#FAFBFC' >"  + CRLF
			cHtml += 										"<div align='right'></div>" + CRLF
			cHtml += 									"</td>" + CRLF
			cHtml += 									"<td width='107' class='dados' bgcolor='#FAFBFC' >" + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 								'</tr>'
			
		EndIF
		
		//�������������������������������������������������������������������������������������������������������Ŀ
		//�Motivo: Permitir que possam ser exibidos no rodape do recibo de pagamento valores de verbas especificas�
		//���������������������������������������������������������������������������������������������������������
		If ExistBlock("GP30BASEHTM")
			cHtmlAux := ExecBlock("GP30BASEHTM",.F.,.F.)
			If ValType(cHtmlAux) = "C"
				cHtml  += cHtmlAux
			Endif	
		Endif
	EndIF
	//��������������������������������������������������������������Ŀ
	//� Bases de FGTS e FGTS Depositado da 1� Parcela                �
	//����������������������������������������������������������������
ElseIf Esc = 3
	
	If cBaseAux = "S"
		
		IF !( lTerminal )
			
			cHtml += 	'<tr>'
			cHtml += 		'<td class="tdPrinc">'
			cHtml +=		'<p class="pStyle1">'+ STR0056 +'</td>' //"Base FGTS / Valor FGTS"
			cHtml += 		'<td class="td26_94_AlignL">' + Transform(nBaseFgts,cPict1) +'</td>'
			cHtml += 		'<td class="td26_95_AlignL">' + Transform(nFgts,cPict2)+'</td>'
			cHtml +=		'<td align=right height="26" width="95"  style="border-left: 0px solid #FF9B06; border-right:0px solid #FF9B06; border-bottom:1px solid #FF9B06 ; border-top: 0px solid #FF9B06 bgcolor=#6F9ECE"></td>'
			cHtml += 	'</tr>'
			
		Else
			
			cHtml += 								"<tr>"
			cHtml += 									"<td width=219' bgcolor='#FAFBFC' class='etiquetas'>"
			cHtml +=										STR0056 + CRLF //"Base FGTS/Valor FGTS"
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='45' bgcolor='#FAFBFC' class='dados'>" + CRLF
			cHtml += 										'<div align="left" class="etiquetas"> </div>' + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='127' bgcolor='#FAFBFC' class='dados'>" + CRLF
			cHtml +=										"<div align='right'>" + Transform(nBaseFgts,cPict3) + "</div>" + CRLF
			cHtml +=									"</td>" + CRLF
			cHtml += 									"<td width='127'  bgcolor='#FAFBFC' class='dados'>" + CRLF
			cHtml +=										"<div align='right'>" + Transform(nFgts    ,cPict3) + "</div>" + CRLF
			cHtml +=									'</td>' + CRLF
			cHtml += 									"<td width='107' valign='top' bgcolor='#FAFBFC'>" + CRLF
			cHtml += 										"<div align='right'><span class='dados'></span></div>" + CRLF
			cHtml += 									"</td>" + CRLF
			cHtml += 								"</tr>" + CRLF
			
		EndIF
		
	Endif
	
EndIF

IF !( lTerminal )
	
	cHtml += '</font></i></b>'
	cHtml += '</table>'
	cHtml += '</center>'
	cHtml += '</div>'
	cHtml += '<hr whidth = 100% align=right color="#000082">'
	
	//��������������������������������������������������������������Ŀ
	//� Espaco para Observacoes/mensagens                            �
	//����������������������������������������������������������������
	cHtml += '<!Mensagem>'
	cHtml += '<Table bgColor="#FFFFFF" border=0 cellPadding=0 cellSpacing=0 height=100 width=598>'
	cHtml += 	'<TBody>'
	cHtml +=	'<tr>'
	cHtml +=	'<td align=left height=18 width=574 ><i><font face="Arial" size="2" color="#000082"><b>'+STR0119+'</b></font></td></tr>'
	cHtml +=	'<tr>'
	cHtml +=	'<td align=left height=18 width=574 ><i><font face="Arial" size="2" color="#000082">'+DESC_MSG1+ '</font></td></tr>'
	cHtml +=	'<tr>'
	cHtml +=	'<td align=left height=18 width=574 ><i><font face="Arial" size="2" color="#000082">'+DESC_MSG2+ '</font></td></tr>'
	cHtml +=	'<tr>'
	cHtml += 	'<td align=left height=18 width=574 ><i><font face="Arial" size="2" color="#000082">'+DESC_MSG3+ '</font></td></tr>'
	IF cMesComp == Month(SRA->RA_NASC)
		cHtml += '<TD align=left height=18 width=574 bgcolor="#FFFFFF"><EM><B><CODE>      <font face="Arial" size="4" color="#000082">'
		cHtml += '<MARQUEE align="middle" bgcolor="#FFFFFF">' + STR0059	+ '</marquee><code></b></font></td></tr>' //"F E L I Z &nbsp;&nbsp  A N I V E R S A R I O !!!! "
	EndIF
	cHtml += '</TBody>'
	cHtml += '</Table>'
	cHtml += '</table>'
	cHtml += '</body>'
	cHtml += '</html>'
	
Else
	
	cHtml +=							"</TR>" + CRLF
	cHtml +=						"</TBODY>" + CRLF
	cHtml +=					"</TABLE>" + CRLF
	
	cHtml +=				"</TBODY>" + CRLF
	cHtml +=			"</TABLE>" + CRLF
	
	//Separador
	cHtml +=			"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=				"<TBODY>" + CRLF
	cHtml +=					"<TR>" + CRLF
	cHtml +=						"<TD vAlign=top width='100%' height=10>" + CRLF
	cHtml +=						"</TD>" + CRLF
	cHtml +=			 		"</TR>" + CRLF
	cHtml +=				"</TBODY>" + CRLF
	cHtml +=			"</TABLE>" + CRLF
	
	//Rodape
	cHtml += 			RodaHtml()
	
	cHtml += 		'</TABLE>' + CRLF
	cHtml += 		'<p align="right"><a href="javascript:self.print()"><img src="imagens/imprimir.gif" width="90" height="28" hspace="20" border="0"></a></p>' + CRLF
	cHtml += 	'</body>' + CRLF
	cHtml += '</html>' + CRLF
	
EndIF

//��������������������������������������������������������������Ŀ
//� Envia e-mail p/funcionario                                   �
//����������������������������������������������������������������
IF !( lTerminal )
	lEnvioOK := GPEMail(cSubject,cHtml,cEMail)
EndIF

RestArea( aSvArea )

Return( IF( lTerminal , cHtml , NIL ) )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpTeste �Autor  �R.H. - Natie        � Data �  11/29/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Testa impressao de Formulario Teste                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function fImpTeste(cString,nTipoRel)

//--Comando para nao saltar folha apos o MsFlush.
SetPgEject(.F.)

@ PROW(),PCOL() PSAY ""
//��������������������������������������������������������������Ŀ
//� Descarrega teste de impressao                                �
//����������������������������������������������������������������
MS_Flush()
fInicia(cString,nTipoRel)

//����������������������������������������������������������������������������������Ŀ
//� Define o Li com a a linha de impress�o correten para n�o saltar linhas no teste  �
//������������������������������������������������������������������������������������
li := _Prow()

If nTipoRel == 2
	@ LI,00 PSAY AvalImp(Limite)
Endif

lRetCanc	:= Pergunte(Padr("GPR30A", len(SX1->X1_GRUPO)," "),.T.)
Vez := If(mv_par01 = 1,1,0)

Return Vez

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fInicia   �Autor  �Natie               � Data �  04/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa parametros para impressao                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function  fInicia(cString,nTipoRel)


If LastKey() = 27 .Or. nLastKey = 27
	Return  .F.
Endif

If nTipoRel# 3
	SetDefault(aReturn,cString)
Endif

If LastKey() = 27 .OR. nLastKey = 27
	Return .F.
Endif

Return .T.

/*
�����������������������������������������������������������������������Ŀ
�Fun��o	   �CabecHtml  		�Autor�Marinaldo de Jesus � Data �18/09/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna Cabecalho HTML para o RHOnLine                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Retorno   �cHtml  														�
�����������������������������������������������������������������������Ĵ
�Uso	   �GPER030       										    	�
�������������������������������������������������������������������������*/
Static Function CabecHtml( cReferencia , dDataPagto , dDataRef )

Local cHtml 		:= ""
Local cLogoEmp		:= RetLogoEmp()
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
Local cAltLogo		:= SUPERGETMV("MV_GPALTLOGO",,"30")
Local cLarLogo		:= SUPERGETMV("MV_GPLARLOGO",,"206")

DEFAULT cReferencia	:= ""

/*��������������������������������������������������������������Ŀ
� Carrega Funcao do Funcion. de acordo com a Dt Referencia     �
����������������������������������������������������������������*/
fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc  )

//Logo e Titulo
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY class='fundo'>"
cHtml +=			"<img src='" + cLogoEmp +"' width='"+cLarLogo+"' height='"+cAltLogo+"'align=left hspace=30>" + CRLF
cHtml +=					"<b>" + CRLF
cHtml += 						"<span class='titulo_opcao'>" + Capital( STR0044 ) + "</span>" + CRLF //DEMONSTRATIVO DE PAGAMENTO
cHtml +=					"</b>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Empresa
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0097 + CRLF //"Empresa: "
cHtml += 						"</span>" + CRLF
cHtml +=	        			 "<span class='dados'>" + CRLF
cHtml +=								Capital( AllTrim( Desc_Fil ) ) + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Endereco e CNPJ
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='65%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0098 + CRLF //"Endere�o:"
cHtml +=						"</span>" + CRLF
cHtml +=						"<span class='dados'>"
cHtml +=								Capital( AllTrim( Desc_End ) ) + "</span>" + CRLF
cHtml +=						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='35%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0099 + CRLF	//"CNPJ:"
cHtml +=						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								Transform( Desc_CGC , "@R 99.999.999/9999-99") + CRLF
cHtml +=						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=			"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Data do Credito e Conta Corrente
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=				"<TD vAlign=top width='40%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0101 + CRLF //"Cr�dito em:"
cHtml +=						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								Dtoc(dDataPagto) + CRLF
cHtml +=						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='60%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0102 + CRLF //"Banco/Ag�ncia/Conta:"
cHtml +=						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								AllTrim( Transform( SRA->RA_BCDEPSA , "@R 999/999999" ) ) + "/" + SRA->RA_CTDEPSA + CRLF
cHtml +=						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=			"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Referencia
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" +  STR0100 + CRLF //"Refer�ncia:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								cReferencia + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=5>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Nome e Matricula
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='75%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0105 + CRLF //"Nome:
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								Capital( AllTrim( SRA->RA_NOME ) ) + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='25%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0106 + CRLF //"Matricula:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								SRA->RA_MAT + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=			"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//CTPS, Serie e CPF
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0107 + CRLF	//"CTPS:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=							SRA->RA_NUMCP + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='100' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0108 + CRLF //"S�rie:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								SRA->RA_SERCP + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='172' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0109 + CRLF //"CPF:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								Transform( SRA->RA_CIC , "@R 999.999.999-99" ) + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='60%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0103  + CRLF //Funcao
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								Capital( AllTrim( cDescFunc ) ) + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='40%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0104 + CRLF //Sal�rio Nominal:
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								Transform( nSalario , cPict1 ) + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=			"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Centro de Custo
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0110 + CRLF //Centro de Custo:
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								AllTrim( SRA->RA_CC ) + " - " + Capital( AllTrim(fDesc("SI3",SRA->RA_CC,"I3_DESC",TamSx3("I3_DESC")[1]) ) ) + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=			"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Separador
cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=	 		"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

//Admissao
cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top width='329' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0111 + CRLF //"Admiss�o:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								Dtoc( SRA->RA_ADMISSA ) + CRLF
cHtml +=						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='231' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0112 + CRLF //"Dependente(s) IR:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								SRA->RA_DEPIR + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=				"<TD vAlign=top width='390' height=1>" + CRLF
cHtml +=					"<P align=left>" + CRLF
cHtml +=						"<span class='etiquetas'>" + STR0113 + CRLF //"Dependente(s) Sal�rio Fam�lia:"
cHtml += 						"</span>" + CRLF
cHtml +=						"<span class='dados'>" + CRLF
cHtml +=								SRA->RA_DEPSF + CRLF
cHtml += 						"</span>" + CRLF
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=			"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

Return( cHtml )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o	   �RodaHtml  		�Autor�Marinaldo de Jesus � Data �18/09/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna Rodape HTML para o RHOnLine                         �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Retorno   �cHtml  														�
�����������������������������������������������������������������������Ĵ
�Uso	   �GPER030       										    	�
�������������������������������������������������������������������������*/
Static Function RodaHtml()

Local cHtml	:= ""

cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
cHtml +=		"<TBODY>" + CRLF
cHtml +=			"<TR>" + CRLF
cHtml +=				"<TD vAlign=top height=1>" + CRLF
cHtml +=					"<P align=center>" + CRLF
cHtml += 							STR0114 + CRLF //'"V�lido como Comprovante Mensal de Rendimentos"'
cHtml +=						"<br>" + CRLF
cHtml += 							STR0115 + CRLF //"( Artigo no. 41 e 464 da CLT, Portaria MTPS/GM 3.626 de 13/11/1991 )"
cHtml +=					"</P>" + CRLF
cHtml +=				"</TD>" + CRLF
cHtml +=			"</TR>" + CRLF
cHtml +=		"</TBODY>" + CRLF
cHtml +=	"</TABLE>" + CRLF

Return( cHtml )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fMontaDtTcf 	�Autor�Ricardo Duarte     � Data �13/08/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna a data valida para a consulta do Terminal Consulta  �
�          �do Funcionario                                         		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Retorno   �cHtml  														�
�����������������������������������������������������������������������Ĵ
�Uso	   �GPER030       										    	�
�������������������������������������������������������������������������*/
Static Function fMontaDtTcf(cMesAno,nDia)

Local dDataValida
Default nDia := 0

dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+"01")
dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+strzero(f_UltDia(dDataValida),2))+nDia

return(dDataValida)
