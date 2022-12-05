#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM034.CH"

STATIC aEfd	  		:= If( cPaisLoc == "BRA", If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.}), {.F.,.F.,.F.} )
Static lTela    	:= .T.
Static lIntTaf  	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 2 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEM034    ³ Autor ³ Alessandro Santos       	                ³ Data ³ 17/05/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Tela chamadora das rotina eventuais - eSocial.            			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³                                                           	  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alessandro S.³17/05/2014³00000012843/2014³   TPJYJ3³Inclusao da rotina para tela com opcoes de in³±±
±±³             ³          ³                ³         ³tegracoes eventuais com o SIGATAF. eSocial   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alessandro S.³30/05/2014³00000016375/2014³   TPSIC2³Adicionado chamada para a rotina de abertura ³±±
±±³             ³          ³                ³         ³de folhas GPEM036 e ajustes na tela inicial. ³±±
±±³Marcia Moura |10/07/2014|00000017984/2014|   TPVLRZ³Adicionado chamada para a rotina de abertura ³±±
±±³             ³          ³                ³         ³de Desoneracao S-1380                        ³±±
±±³Marcia Moura |10/07/2014|00000017984/2014|   TQAUEZ³Adicionado chamada para a rotina de abertura ³±±
±±³             ³          ³                ³         ³de Folha de Pagamento S-1200                 ³±±
±±³Marcia Moura |11/08/2014|00000014123/2014|   TPNBN5³Programa recompilado com as alteracoes soli- ³±±
±±³             |          |                |         ³citadas pela rejeicao do SQA                 ³±±
±±³Marcia Moura |06/08/2014|                |   TQAUN9³Programa que contem a funcao para o S-1300   ³±±
±±³Marcia Moura |24/05/2017| DRHESOCP-211   |         ³Adaptacao novo leiaute 2.2.01                ³±±
±±³Marcia Moura |26/05/2014|DRHESOCP-104    |         ³Refeita a geracao do evento S-1280           ³±±
±±³Oswaldo L    |05/06/2017|DRHESOCP-372    |         ³Layout S1200 para e-social                   ³±±
±±³             |          |                |         ³Aproveitamos para tratar Projeto SOYUZ e     ³±±
±±³             |          |                |         ³ajust tela(tinha componentes desposicionados)³±±
±±³Oswaldo L    |20/06/2017|DRHESOCP-348    |         ³Layout S1210 e-social ajuste chamada função  ³±±
±±³Oswaldo L    |20/07/2017|DRHESOCP-637    |         ³Erro era devido a falta do RHLIBDB no pacote ³±±
±±³             |          |                |         ³mas aproveitei p/ajustar passagem parametros ³±±
±±³Cecilia Car. |10/05/2018|DRHESOCP-4607   |         ³Ajuste para exibir a mensagem para orientar  ³±±
±±³             |          |                |         ³sobre a configuração dos parâmetros MV_RHTAF ³±±
±±³             |          |                |         ³e MV_FASESOC.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM034(aInfoAut)

Local aArea		 	:= GetArea()
Local oRetific		:= Nil
Local oIndic13		:= Nil
Local oProcess		:= Nil
Local oEvenAll		:= Nil
Local cCompete		:= Space(6)
Local cTitle  		:= OemToAnsi(STR0001) + "-" + OemToAnsi(STR0002)
Local cRetific		:= ""
Local cIndic13		:= ""
Local cProcess		:= ""
Local cAliasTRB		:= GetNextAlias()
Local cPerIni		:= Space(6)
Local cPerFim		:= Space(6)
Local cExpFiltro	:= ""
Local nOpcA			:= 1
Local aRetific		:= {"Nao", "Sim"}
Local aIndic13		:= {"Nao", "Sim"}
Local aProces		:= {"Geração", "Exclusão", "Relatório"}
Local aInfo   		:= {}
Local aObjects 		:= {}
Local aPosObj  	:= {}
Local aArrayFil		:= {}
Local aCheck		:= { .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .T., .T.} //Itens checkBox
Local aObjCheck		:= Array(Len(aCheck)) //Objetos dos eventos
Local lEvenAll		:= .F.
Local aObjCoords	:= {}
Local oFont
Local bFecha 		:= { || nOpcA:=2,oDlg:End()}
Local bFilt			:= { || GpFltBldExp( "SRA" , NIL , @cExpFiltro , NIL ) }
Local bOK1			:= { || IIF(fGp34TdOk1(cCompete, cPerIni, cPerFim, aCheck, aArrayFil, cAliasTRB, cIndic13, cExpFiltro), (fGP034Mark(aCheck, cCompete, cPerIni, cPerFim, aArrayFil, cRetific, cIndic13, cAliasTRB, cProcess, cExpFiltro), nOpcA := 1), Nil)}
Local oBtFiliais
Local oBtFechar
Local oBtFiltrar
Local aTitle 		:= {}
local oPeriodo
Local lWhen			:= .T.
Local lWhen13		:= .F.
Local lWhenExc		:= .T.
Local lWhenRel		:= .T.
Local cFilRCA 		:= xFilial( "RCA", cFilAnt )
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList({"RA_CIC"}) )

Private oArq1Tmp
Private cRotina		:= "GPEM034"
Private lPar06		:= .F.
Private oMark
Private oDlg
Private lAglut		:= .F.

Private aLogs 		:= {}
Private cPeriodo

Private cCPFDe		:= ""
Private cCPFAte		:= ""

Private lWorkFlow	:= .F.

Default aInfoAut	:= {}

lWorkFlow := !Empty(aInfoAut)

//Validacoes da rotina
If !lMiddleware .And. !(SuperGetMv("MV_RHTAF",, .F.) == .T.) //Valida parametro de controle integracao TAF
	MsgStop(OemToAnsi(STR0030), OemToAnsi(STR0029)) //#"Sistema não está configurado para integração com o módulo SIGATAF, verifique o parâmetro MV_RHTAF." #"Atencao"
	Return()
EndIf

If !lMiddleware .And. !(Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 2 ) //Valida parametro de fase do e-social
	MsgStop(OemToAnsi(STR0040), OemToAnsi(STR0029)) //#"Sistema não está configurado para geração dos eventos periódicos, verifique o parâmetro MV_FASESOC." #"Atencao"
	Return()
EndIf

RCA->( dbSetOrder(1) )
If RCA->( dbSeek( cFilRCA + "P_ESOCMV" ) )
	lAglut := (AllTrim(RCA->RCA_CONTEU) == ".T.")
EndIf

If !lMiddleware .And. lAglut .And. C91->(ColumnPos("C91_CPF")) == 0
	MsgStop(OemToAnsi(STR0052), OemToAnsi(STR0029)) //#""Sistema não possui atualização de dicionário diferencial do TAF de Julho/2018"" #"Atencao"
	Return()
EndIf

//Retirar essa validação no próximo Release, pois o PE nao foi publicado porque foi disponibilizado apenas para 1 cliente
If ExistBlock("GPE036DTPGTO") .And. Empty( SuperGetMv("MV_PERAUT",, "") )
	MsgStop(OemToAnsi(STR0055), OemToAnsi(STR0029)) //"O Ponto de Entrada GPE036DTPGTO foi desativado e substituído pelo parâmetro MV_PERAUT. Para prosseguir é necessário configurar esse parâmetro." #"Atencao"
	Return()
EndIf

//Validação de tamanho do campo RJ5_COD
If !fVldRJ5()
	Return()
EndIf

//Validação TAFXERP e TAFST2
If !lMiddleware .And. !fVldTaf()
	Return()
EndIf

	If !lWorkFlow
		If lBlqAcesso	//Tratamento de acesso a dados pessoais
			Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
			Return
		EndIf

		aAdvSize	:= MsAdvSize( .F.,.F.,570)
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

		Define MsDialog oDlg FROM 0, 0 To 430, 915 Title cTitle Pixel

		// Cria o conteiner onde serão colocados os paineis
		oTela1     := FWFormContainer():New( oDlg )
		cIdTel1	  := oTela1:CreateHorizontalBox( 15 )
		cIdTel2   := oTela1:CreateHorizontalBox( 20 )
		cIdTel3	  := oTela1:CreateHorizontalBox( 35 )
		cIdTel4	  := oTela1:CreateHorizontalBox( 25 )

		oTela1:Activate( oDlg, .F. )

		//Cria os paineis onde serao colocados os browses
		oPanel1  	:= oTela1:GeTPanel(cIdTel1)
		oPanel2  	:= oTela1:GeTPanel(cIdTel2)
		oPanel3  	:= oTela1:GeTPanel(cIdTel3)
		oPanel4		:= oTela1:GetPanel(cIdTel4)

		// Primeiro Painel
		@ aObjSize[1,1]*0.5	, aObjSize[1,2]+2		SAY   OemToAnsi(STR0018) SIZE 038,007 OF oPanel1 PIXEL	//"Competência (MMAAAA)"
		@ (aObjSize[1,1]*0.5)+8, aObjSize[1,2]+2	MSGET cCompete SIZE 010,007	ON CHANGE EventComp(cCompete, @lWhen13, @lWhen, @cIndic13) OF oPanel1 PIXEL WHEN .T. PICTURE "@R 99/9999"

		@ aObjSize[1,1]*0.5, aObjSize[1,2]+80 		SAY   OemToAnsi(STR0025) SIZE 038,007 OF oPanel1 PIXEL	//"Ref. 13 Salário?"
		@ (aObjSize[1,1] * 0.5) + 8, aObjSize[1,2] + 80 MSCOMBOBOX oIndic13 VAR cIndic13 ITEMS aIndic13 SIZE 060,007 ON CHANGE Event13(cIndic13, @lWhen, aCheck) OF oPanel1 PIXEL WHEN lWhen13

		//Processo
		@ aObjSize[1,1]*0.5, aObjSize[1,2]+180 		SAY   OemToAnsi(STR0074) SIZE 058,007 OF oPanel1 PIXEL	//"Processo"
		@ (aObjSize[1,1] * 0.5) + 8, aObjSize[1,2] + 180 MSCOMBOBOX oProcess VAR cProcess ITEMS aProces SIZE 060,007 ON CHANGE EventExc(cProcess, @lWhenExc, @lWhen, @lWhenRel, aCheck) OF oPanel1 PIXEL WHEN .T.


		// Segundo Painel (eventos )
		@ 0 , aObjSize[1,2]	GROUP oGroup TO 40,aObjSize[1,4]*0.64 LABEL OemToAnsi(STR0041) OF oPanel2  PIXEL	//"Eventos"
		oGroup:oFont:=oFont

		@ aObjSize[1,1]*0.85, aObjSize[1,2]+5	CHECKBOX aObjCheck[1] VAR aCheck[1] SIZE 010,007 OF oPanel2 PIXEL WHEN .T.
		@ aObjSize[1,1]*0.85, aObjSize[1,2]+15	SAY OemToAnsi(STR0006)  SIZE 200,060 OF oPanel2 PIXEL	//"S-1200 - Remuneração do Trabalhador vinculado ao RGPS"

		@ aObjSize[1,1]*0.85, aObjSize[1,2]+205 CHECKBOX aObjCheck[2] VAR aCheck[2] SIZE 010,007 OF oPanel2 PIXEL WHEN (lWhen .Or. lWhenRel)
		@ aObjSize[1,1]*0.85, aObjSize[1,2]+220 SAY   OemToAnsi(STR0007)  SIZE 200,060 OF oPanel2 PIXEL	//"S-1210 - Pagamentos de Rendimentos do Trabalho"

		@ aObjSize[1,1]*1.800, aObjSize[1,2]+5	CHECKBOX aObjCheck[4] VAR aCheck[4] SIZE 010,007 OF oPanel2 PIXEL WHEN lWhenExc
		@ aObjSize[1,1]*1.800, aObjSize[1,2]+15	SAY OemToAnsi(STR0010)  SIZE 250,060 OF oPanel2 PIXEL	//"S-1280 - Informações Complementares aos Eventos Periodicos"

		@ aObjSize[1,1]*1.800, aObjSize[1,2]+205	CHECKBOX aObjCheck[3] VAR aCheck[3] SIZE 010,007 OF oPanel2 PIXEL WHEN ( lWhen .And. lWhenExc )
		@ aObjSize[1,1]*1.800, aObjSize[1,2]+220	SAY OemToAnsi(STR0011)  SIZE 250,060 OF oPanel2 PIXEL	//"S-1300 - Contribuição Sindical Patronal"


		// Terceiro Painel (Opções de geração)

		@ 0 , aObjSize[1,2]	GROUP oGroup TO 70,aObjSize[1,4]*0.64 LABEL OemToAnsi(STR0042) OF oPanel3  PIXEL	//"Opções de geração
		oGroup:oFont:=oFont

		@ aObjSize[1,1]*0.85, aObjSize[1,2]+5	CHECKBOX aObjCheck[5] VAR aCheck[5] SIZE 010,007 OF oPanel3 PIXEL WHEN (lWhenExc .Or. lWhenRel)
		@ aObjSize[1,1]*0.85, aObjSize[1,2]+15	SAY OemToAnsi(STR0043)  SIZE 200,060 OF oPanel3 PIXEL//"Considerar dados do período em aberto?"

		If !lMiddleware
			@ aObjSize[1,1]*0.85, aObjSize[1,2]+205	CHECKBOX aObjCheck[6] VAR aCheck[6] SIZE 010,007 OF oPanel3 PIXEL WHEN lWhenExc
			@ aObjSize[1,1]*0.85, aObjSize[1,2]+220	SAY OemToAnsi(STR0044)  SIZE 250,060 OF oPanel3 PIXEL//"Sobrescrever eventos não validados ou não trasmitidos?"

			@ aObjSize[1,1]*1.900, aObjSize[1,2]+5	CHECKBOX aObjCheck[7] VAR aCheck[7] SIZE 010,007 OF oPanel3 PIXEL WHEN lWhenExc
			@ aObjSize[1,1]*1.900, aObjSize[1,2]+15	SAY OemToAnsi(STR0045)  SIZE 250,060 OF oPanel3 PIXEL//"Sobrescrever eventos com inconsistências encontradas pelo TAF?"
		Else
			@ aObjSize[1,1]*1.900, aObjSize[1,2]+5	CHECKBOX aObjCheck[6] VAR aCheck[6] SIZE 010,007 OF oPanel3 PIXEL WHEN lWhenExc
			@ aObjSize[1,1]*1.900, aObjSize[1,2]+15	SAY OemToAnsi(STR0078)  SIZE 250,060 OF oPanel3 PIXEL//"Sobrescrever eventos não transmitidos?"
		EndIf

		@ aObjSize[1,1]*1.900, aObjSize[1,2]+205 CHECKBOX aObjCheck[8] VAR aCheck[8] SIZE 010,007 OF oPanel3 PIXEL WHEN lWhenExc
		@ aObjSize[1,1]*1.900, aObjSize[1,2]+220 SAY OemToAnsi(STR0046)  SIZE 250,060 OF oPanel3 PIXEL//"Sobrescrever eventos com inconsistências retornadas pelo governo?"

		@ aObjSize[1,1]*2.900, aObjSize[1,2]+5 CHECKBOX aObjCheck[9] VAR aCheck[9] SIZE 010,007 OF oPanel3 PIXEL WHEN lWhenExc
		@ aObjSize[1,1]*2.900, aObjSize[1,2]+15 SAY OemToAnsi(STR0047)  SIZE 250,060 OF oPanel3 PIXEL//"Sobrescrever eventos com exclusão transmitida e retornada pelo governo?"

		@ aObjSize[1,1]*2.900, aObjSize[1,2]+205 CHECKBOX aObjCheck[10] VAR aCheck[10] SIZE 010,007 OF oPanel3 PIXEL WHEN lWhenExc
		@ aObjSize[1,1]*2.900, aObjSize[1,2]+220 SAY   OemToAnsi(STR0048)  SIZE 200,060 OF oPanel3 PIXEL//"Retificar eventos transmitidos e retornados pelo governo?"

		@ aObjSize[1,1]*3.900, aObjSize[1,2]+5 CHECKBOX aObjCheck[12] VAR aCheck[12] SIZE 010,007 OF oPanel3 PIXEL WHEN (lWhenExc .Or. lWhenRel)
		@ aObjSize[1,1]*3.900, aObjSize[1,2]+15 SAY   OemToAnsi(STR0066)  SIZE 200,060 OF oPanel3 PIXEL//"Gerar o evento S-1200 para funcionários sem movimentação de valores?"

		@ aObjSize[1,1]*3.900, aObjSize[1,2]+205 CHECKBOX aObjCheck[13] VAR aCheck[13] SIZE 010,007 OF oPanel3 PIXEL WHEN (lWhenExc .Or. lWhenRel) 
		@ aObjSize[1,1]*3.900, aObjSize[1,2]+220 SAY   OemToAnsi(STR0067)  SIZE 200,060 OF oPanel3 PIXEL//"Gerar o evento S-1210 para funcionários sem valores a declarar?"

		// Quarto Painel (Diagnósticos)
		@ 0 , aObjSize[1,2]	GROUP oGroup TO 25,aObjSize[1,4]*0.64 LABEL OemToAnsi(STR0053) OF oPanel4  PIXEL	//"Diagnósticos"
		oGroup:oFont:=oFont
		@ aObjSize[1,1]*0.85, aObjSize[1,2]+5	CHECKBOX aObjCheck[11] VAR aCheck[11] SIZE 010,007 OF oPanel4 PIXEL WHEN (lWhenExc .Or. lWhenRel)
		@ aObjSize[1,1]*0.85, aObjSize[1,2]+15	SAY OemToAnsi(STR0054)  SIZE 200,060 OF oPanel4 PIXEL //Habilitar diagnóstico de verbas

		oBtFiltrar		:= TButton():New( aObjSize[1,1]*13.000, aObjSize[1,2]+15+230, "Filtro",NIL,bFilt, 060 , 012 , NIL , NIL , NIL , .T. )	// "Filtro"
		oBtFiliais		:= TButton():New( aObjSize[1,1]*13.000, aObjSize[1,2]+15+300 , "&"+"Processar",NIL,bOK1	, 060 , 012 , NIL , NIL , NIL , .T. )	// "Processar"
		oBtFechar		:= TButton():New( aObjSize[1,1]*13.000, aObjSize[1,2]+15+370, "&"+"Fechar",NIL,bFecha, 040 , 012 , NIL , NIL , NIL , .T. )	// "Fechar"

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		aCheck  	:= aInfoAut[4]
		cCompete 	:= aInfoAut[1]
		aArrayFil	:= aInfoAut[5]
		cRetific	:= "Não"
		cIndic13	:= aInfoAut[2]
		cProcess	:= aInfoAut[3]
		cCPFDe		:= aInfoAut[6]
		cCPFAte		:= aInfoAut[7]
		fGp34InTaf(aCheck, cCompete, cPerIni, cPerFim, aArrayFil, cRetific, cIndic13, cProcess)
	EndIf

	If Select(cAliasTRB) > 0
		DbCloseArea(cAliasTRB)
	EndIf

	If oArq1Tmp <> Nil
		oArq1Tmp:Delete()
		Freeobj(oArq1Tmp)
	EndIf
Return Nil

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³fGp34MAno    	³Autor³Marcia Moura       ³ Data ³15/08/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Validar o lancamento de Mes/Ano ou Ano/Mes                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cMesAno = Mes/Ano ou Ano/Mes                                ³
³          ³nTipo = 1=Valida MM/AAAA 2=Valida AAAA/MM                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico 	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function fGp34MAno( cMesAno, nTipo )
Local cMes
Local cAno
Local dData
Local lRet 	:= .F.
Local nTam

Default nTipo := 1

If Empty( cMesAno ) .Or. ( Len(cMesAno) <> Len(AllTrim(cMesAno)) )
	Return( .F. )
EndIf

nTam := Len( cMesAno )

If nTipo == 1
	If nTam == 4
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero( Val(Substr( cMesAno, 3, 2 )), 2)
	ElseIf nTam == 5
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero( Val(Substr( cMesAno, 4, 2 )), 2)
	ElseIf nTam == 6
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero( Val(Substr( cMesAno, 3, 4 )), 4)
	ElseIf nTam == 7
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero( Val(Substr( cMesAno, 4, 4 )), 4)
	EndIf
ElseIf nTipo == 2
	If nTam == 4
		cAno := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cMes := StrZero( Val(Substr( cMesAno, 3, 2 )), 2)
	ElseIf nTam == 5
		cAno := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cMes := StrZero( Val(Substr( cMesAno, 4, 2 )), 2)
	ElseIf nTam == 6
		cAno := StrZero(Val(Substr( cMesAno, 1, 4)), 4)
		cMes := StrZero( Val(Substr( cMesAno, 5, 2 )), 2)
	ElseIf nTam == 7
		cAno := StrZero(Val(Substr( cMesAno, 1, 4)), 4)
		cMes := StrZero( Val(Substr( cMesAno, 6, 2 )), 2)
	EndIf
EndIf

dData := Ctod( "01/" + cMes + "/" + cAno )

If !Empty(dData) .and. dData >= Ctod( "01/01/1900" )
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} fGp34TdOk1
Pos-validacao do modelo relativo aos eventuais eSocial. - Uso Exclusivo Pais Brasil
@author Alessandro Santos
@since 17/05/2014
@return lRet, return_description
@param cCompete, characters, Competência para geracao dos eventos
@param cPerIni, characters, Período inicial
@param cPerFim, characters, Período Final
@param aCheck, array, Array para controle de selecao dos eventos
@param aArrayFil, array, Array para armazenar as filiais selecionadas
@param cAliasTRB, characters, Alias do arquivo temporario
@param cIndic13, characters, Integracao tipo de folha 13/Normal
/*/
Function fGp34TdOk1(cCompete, cPerIni, cPerFim, aCheck, aArrayFil, cAliasTRB, cIndic13, cExpFiltro)

	Local aArea			:= GetArea()
	Local nErro			:= 0
	Local nI			:= 0
	Local lRet 			:= .T.
	Local aCheckAux 	:= aClone(aCheck) //Salva itens selecionados
	Local aCodFol		:= {}

	lTela := .F.

	//Limpa array
	aArrayFil := {}

	//Validacoes da rotina
		If !fGp34MAno( cCompete, 1)
			MsgStop(OemToAnsi(STR0032)) //"Competencia inconsistente"
			lRet := .F.
			nErro := 1
		Endif

		If Empty(cCompete) .And. nErro = 0    //Vaida competencia
			MsgStop(OemToAnsi(STR0023)) //#"Necessário preencher a competência."
			lRet := .F.
			nErro += nErro
		Endif

		If aScan(aCheck, {|x| x}, 1, 4) == 0  .And. nErro = 0 //Valida eventos
			If !lMiddleware
				MsgStop(OemToAnsi(STR0022)) //#"Necessário selecionar um evento para integração com o TAF"
			Else
				MsgStop(OemToAnsi(STR0075)) //#"Necessário selecionar um evento para integração com o Middleware"
			EndIf
			lRet := .F.
			nErro += nErro
		Endif

		If SubStr(cCompete, 1, 2) != "12" .And. aCheck[1]
			If fVerRot132(cCompete, aCheck[5])
				RstaCodFol()
				If Fp_CodFol(@aCodFol, xFilial('SRV', cFilAnt))
					If Len(aCodFol) < 1655
						MsgStop(OemToAnsi(STR0058) + "http://tdn.totvs.com/pages/viewpage.action?pageId=435110991") //"Ambiente desatualizado. Contate o administrador do sistema para efetuar a atualização disponível em: "
						lRet := .F.
					ElseIf Empty(aCodFol[1655, 1])
						MsgStop(OemToAnsi(STR0059) + CRLF + CRLF + OemToAnsi(STR0060) + "http://tdn.totvs.com/pages/viewpage.action?pageId=435110991") //"Necessário possuir cadastro de verba para o Id de cálculo 1655 - 13º integral pago antes de Dezembro"##"Para mais informações, consulte a documentação disponível em: "
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If cIndic13 == "Sim" .And. aCheck[1]
			RstaCodFol()
			If Fp_CodFol(@aCodFol, xFilial('SRV', cFilAnt))
				fVerRot131(cCompete, aCheck[5], aCodFol)
			Else
				lRet := .F.
			EndIf
		EndIf

		If aCheck[1]
			RstaCodFol()
			If Fp_CodFol(@aCodFol, xFilial('SRV', cFilAnt))
				fVer1397(cCompete, aCodFol)
			Else
				lRet := .F.
			EndIf
		EndIf

	//Restaura itens selecionados
	If nErro > 0
		lRet := .F.
	EndIf

	If lRet .And. (aCheck[1] .Or. aCheck[2]) .And. Empty(cExpFiltro)
		lRet := MsgYesNo(OemToAnsi(STR0068),OemToAnsi(STR0029)) //"Nenhum filtro foi selecionado! Processar toda a tabela?"##"Atenção"
	EndIf

	RestArea(aArea)

Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCriaTmp()³ Autor ³ Alessandro Santos     ³ Data ³ 03/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria tabela temporaria para utilizar na fwmarkbrouwse      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlgEven  - Tela onde serao criados os objetos             ³±±
±±³          ³ aPosObj   - Dimensoes da tela                              ³±±
±±³          ³ cAliasTRB - Alias do arquivo temporario                    ³±±
±±³          ³ aPosObj   - Array com as dimensoes da tela                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fCriaTmp(cAliasTRB)

Local oMarkFil		:= Nil
Local oFilAll		:= Nil
Local cArq 			:= ""
Local cQryWhere 	:= ""
Local nPos			:= 0
Local aArea		 	:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aAreaC1E    	:= {}
Local cAliasC1E  	:= ""
Local oView 		:= FWViewActive()
Local aStru   		:= {}
Local cFilTAF		:= ""
Local lTAFCFGE 		:= SuperGetMv("MV_TAFCFGE", Nil, .F.)
Local nCont			:= 0

Local aSM0    		:= FWLoadSM0(.T.,,.T.)
Local lInverte  	:= .F.
Local lContinua		:= .T.
Local cMark   		:= GetMark()
Local aLstIndices := {}

Private cCadastro 	:= OemToAnsi(STR0005)
Private aRotina	:= {}

//Estrutura da tabela temporaria
Aadd(aStru, {"OK"		, "C", 2						, 0})
Aadd(aStru, {"FILTAF"	, "C", FwGetTamFilial			, 0})
Aadd(aStru, {"NOME"  	, "C", 100						, 0})
Aadd(aStru, {"CNPJ"  	, "C", TamSx3("CTT_CEI")[1]  	, 0})
If !lMiddleware
	Aadd(aStru, {"DTINI" 	, "C", TamSx3("C1E_DTINI")[1]	, 0})
	Aadd(aStru, {"DTFIN" 	, "C", TamSx3("C1E_DTFIN")[1]	, 0})
EndIf
AAdd( aLstIndices, {"FILTAF"})

oArq1Tmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

//Busca informacoes C1E - Complemento empresas
If !lMiddleware
	aAreaC1E   	:= C1E->(GetArea())
	cAliasC1E 	:= GetNextAlias()
	#IFDEF TOP
		cQryWhere := "%C1E_CODFIL <> '<NPI>' AND C1E_ATIVO = '1'%"

		//Query para buscar informacoes de processos e varas
		BeginSql alias cAliasC1E
			SELECT
				C1E_FILTAF, C1E_NOME, C1E_DTINI, C1E_DTFIN 	, 	C1E_CODFIL
			FROM
				%table:C1E% C1E
			WHERE
				%exp:cQryWhere% AND C1E.%notDel%
		EndSql

	#ELSE
		cAliasC1E := "C1E"
	#ENDIF

	//Posiciona no inicio do arquivo
	dbSelectArea(cAliasC1E)
	(cAliasC1E)->(dbGoTop())

	While (cAliasC1E)->(!EOF())
		lContinua := .T.

		//Validacao DBF
		#IFNDEF TOP
			If (cAliasC1E)->C1E_ATIVO <> "1"
				lContinua := .F.
			EndIf
		#ENDIF

		//Busca CNPJ
		nPos := aScan(aSM0, {|x| alltrim(x[1] + X[2]) == AllTrim((cAliasC1E)->C1E_CODFIL/*FILTAF*/)})

		//Alimentando a tabela
		If nPos > 0
			//Caso utilize o controle do TAF de complemento cadastro 1 X N para eSocial e 1 X 1 para REINF (parâmetro MV_TAFCFGE)
			//não haverá filiais com <NPI> preenchido, sendo necessário validar se a filial de integração já foi adicionada na lista
			If lTAFCFGE
				cFilTaf := fTafGetFil( cEmpAnt + (cAliasC1E)->C1E_FILTAF, , , .T.)
				If (cAliasTRB)->( dbSeek( cFilTaf ) )
					(cAliasC1E)->(dbSkip())
					Loop
				EndIf
			EndIf
			RecLock(cAliasTRB, .T.)
				(cAliasTRB)->FILTAF	:= (cAliasC1E)->C1E_FILTAF
				(cAliasTRB)->NOME  	:= (cAliasC1E)->C1E_NOME
				(cAliasTRB)->CNPJ 	:= aSM0[nPos, 18]
				(cAliasTRB)->DTINI 	:= (cAliasC1E)->C1E_DTINI
				(cAliasTRB)->DTFIN 	:= (cAliasC1E)->C1E_DTFIN
			(cAliasTRB)->(MsUnlock())
		EndIf

		(cAliasC1E)->(dbSkip())
	EndDo

	#IFDEF TOP
		(cAliasC1E)->(DbCloseArea())
	#ENDIF
Else
	For nCont := 1 To Len(aSM0)
		If aSM0[nCont, 1] == cEmpAnt
			fPosFil( cEmpAnt, aSM0[nCont, 2] )
			If !Empty(fXMLInfos())
				RecLock(cAliasTRB, .T.)
					(cAliasTRB)->FILTAF	:= aSM0[nCont, 2]
					(cAliasTRB)->NOME  	:= aSM0[nCont, 7]
					(cAliasTRB)->CNPJ 	:= aSM0[nCont, 18]
				(cAliasTRB)->(MsUnlock())
			EndIf
		EndIf
	Next nCont
EndIf

//Posicionando no inicio da tabela temporaria
(cAliasTRB)->(dbGoTop())

RestArea(aAreaSM0)
If !lMiddleware
	RestArea(aAreaC1E)
EndIf
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³fGP400Mark³ Autor   ³ Marcia Moura                    ³ Data ³ 04/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ FwMarkBrowse para selecao das Filiais                              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ fGP400Mark()                                                 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Generico                                                    			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGP034Mark(aCheck, cCompete, cPerIni, cPerFim, aArrayFil, cRetific, cIndic13, cAliasTRB, cProcess, cExpFiltro)

Local oSize
Local oPanel4
Local oTela2
Local oGroup
Local oFont
Local lMArcar 		:= .F.
Local lOk	  		:= .T.
Local bOK2			:= {||IIF(fGp34TdOk2(cAliasTRB), (oDlgGrid:End(), nOpcB := 1), Nil)}
Local bFecha 		:= {||oDlgGrid:End()}
Local nOpcB 		:= 0
Local aButtons 		:= {}
Local aStru 		:= {}
Local aStruCTT 		:= {}
Local nX    		:= 0
Local nPosFilTaf 	:= 0
Local nPosNome   	:= 0
Local nPosCnpj  	:= 0
Local nPosDini   	:= 0
Local nPosDfin   	:= 0
Private cRotina		:= "GPEM034"
Private oMark
Private oDlgGrid
Private aColumns 	:= {}
//Tabela Auxiliar
fCriaTmp(cAliasTRB)

If !lMiddleware
	Dbselectarea('C1E')
	aStru		    := C1E->(DBSTRUCT())
	Dbselectarea('CTT')
	aStruCTT		    := CTT->(DBSTRUCT())

	nPosFilTaf 	:= aScan( aStru 	, { |x| x[1] == "C1E_FILTAF" } )
	nPosNome   	:= aScan( aStru 	, { |x| x[1] == "C1E_NOME" 	 } )
	nPosCnpj   	:= aScan( aStruCTT 	, { |x| x[1] == "CTT_CEI"	 } )
	nPosDini 	:= aScan( aStru 	, { |x| x[1] == "C1E_DTINI"  } )
	nPosDfin 	:= aScan( aStru 	, { |x| x[1] == "C1E_DTFIN"  } )
EndIf

If nPosFilTaf > 0 .Or. lMiddleware
	AAdd(aColumns,FWBrwColumn():New())

	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILTAF}") )
	aColumns[Len(aColumns)]:SetTitle("Filial" )
	aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@!")
EndIf

If nPosNome > 0 .Or. lMiddleware
	AAdd(aColumns,FWBrwColumn():New())

	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
	aColumns[Len(aColumns)]:SetTitle("Nome")
	aColumns[Len(aColumns)]:SetSize(Len(FWFilName( cEmpAnt, cFilAnt) ))
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@!")
EndIf


If nPosCnpj > 0 .Or. lMiddleware
	AAdd(aColumns,FWBrwColumn():New())

	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CNPJ}") )
	aColumns[Len(aColumns)]:SetTitle("Cnpj")
	aColumns[Len(aColumns)]:SetSize(14)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture(  "@R 99.999.999/9999-99"   )
EndIf

If nPosDini > 0
	AAdd(aColumns,FWBrwColumn():New())

	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1],"C1E_", "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Dt. Ini. Validade")
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDini][3])
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDini][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("C1E",  aStru[nPosDini][1]))
EndIf


If nPosDfin > 0
	AAdd(aColumns,FWBrwColumn():New())

	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDfin][1],"C1E_", "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Dt. Fin. Validade")
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDfin][3])
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDfin][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("C1E",  aStru[nPosDfin][1]))
EndIf


DbSelectArea(cAliasTRB)

//Tela
oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0001 ) From 0,0 TO 380,930 OF oMainWnd PIXEL


// Cria o conteiner onde serão colocados os paineis
oTela2		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela2:CreateHorizontalBox( 80 )

oTela2:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel4	:= oTela2:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431   LABEL OemToAnsi(STR0001) OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY OemToAnsi(STR0004) Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()
oMark:SetAlias(cAliasTrb)
oMark:SetTemporary(.T.)
//oMark:SetFields(aColsMark)

oMark:SetColumns(aColumns)

//oMark:SetOnlyFields( { 'OK', 'FILTAF', 'NOME', 'CNPJ', 'DTINI', 'DTFIN' } )

//Indica o container onde sera criado o browse
oMark:SetOwner(oPanel4)
oMark:bAllMark := { || SetMarkAll(oMark:Mark(),lMarcar := !lMarcar,cAliasTRB ), oMark:Refresh(.T.)  }

oMark:SetFieldMark('OK')

oMark:SetMenuDef("GPEM034")
oMark:Activate()

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, bOK2 ,bFecha,NIL, aButtons)

if nOpcB == 1
	 aArrayFil		:= {}
	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)
			aAdd(aArrayFil, Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()))
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	fGp34InTaf(aCheck, cCompete, cPerIni, cPerFim, aArrayFil, cRetific, cIndic13, cProcess, cExpFiltro)
Endif

PgsShared()

(cAliasTRB)->(dbCloseArea())


Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp34InTaf ³ Autor ³ Alessandro Santos     ³ Data ³ 19/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada das integracoes a serem realizadas com o SIGATAF.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCheck    - Array para controle de selecao dos eventos       ³±±
±±³          ³ cCompete  - Competencia para geracao dos eventos             ³±±
±±³          ³ cPerIni   - Periodo inicial                                  ³±±
±±³          ³ cPerFim   - Periodo final                                    ³±±
±±³          ³ aFilSM0   - Array com as filiais para integracao             ³±±
±±³          ³ lRetific  - Integracao retificadora                          ³±±
±±³          ³ cIndic13  - Integracao tipo de folha 13/Normal               ³±±
±±³          ³ cProcess  - Processo                                			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGp34InTaf(aCheck, cCompete, cPerIni, cPerFim, aArrayFil, cRetific, cIndic13, cProcess, cExpFiltro)

Local aArea	 		:= GetArea()
Local lRetific		:= cRetific == "Sim" //Controle retificadora
Local lIndic13		:= cIndic13 == "Sim" //Tipo de Folha
Local lExcLote		:= cProcess == "Exclusão" //Exclusao em Lote
Local lRelat		:= cProcess == "Relatório" //Relatório
Local aLogs			:= {}
Local aTitle		:= {}
Local aTitle		:= {}
Local lContinua     := .T.
Local cChoice		:= ""
Local nCont			:= 0

Aadd(aTitle, OemToAnsi(STR0079)) //"Registros do evento S-1200 integrados corretamente: "##1
Aadd(aTitle, OemToAnsi(STR0080)) //"Registros do evento S-1200 que NÃO foram integrados: "##2
Aadd(aTitle, OemToAnsi(STR0081)) //"Resumo de processamento do evento S-1200"##3
Aadd(aTitle, OemToAnsi(STR0082)) //"Registros do evento S-1210 integrados corretamente: "##4
Aadd(aTitle, OemToAnsi(STR0085)) //"Registros do evento S-1210 que NÃO foram integrados: "##5
Aadd(aTitle, OemToAnsi(STR0088)) //"Resumo de processamento do evento S-1210"##6
Aadd(aTitle, OemToAnsi(STR0083)) //"Registros do evento S-1280 integrados corretamente: "##7
Aadd(aTitle, OemToAnsi(STR0086)) //"Registros do evento S-1280 que NÃO foram integrados: "##8
Aadd(aTitle, OemToAnsi(STR0089)) //"Resumo de processamento do evento S-1280"##9
Aadd(aTitle, OemToAnsi(STR0084)) //"Registros do evento S-1300 integrados corretamente: "##10
Aadd(aTitle, OemToAnsi(STR0087)) //"Registros do evento S-1300 que NÃO foram integrados: "##11
Aadd(aTitle, OemToAnsi(STR0090)) //"Resumo de processamento do evento S-1300"##12
Aadd(aTitle, OemToAnsi(STR0091)) //"Diagnóstico de Verbas"##13
For nCont := 1 To 13
	aAdd( aLogs, {} )
Next nCont

//Se existirem filiais com periodo vigente aArrayFil contera informacoes
If Len(aArrayFil) > 0

	cChoice := Iif( aCheck[5], "1", "0" )

	//Diagnóstico de verbas onde é verificado natureza das verbas usadas nos cálculos de plano de saúde e o campo RV_INCIRF das verbas de IR e Pensão Alimentícia
	If aCheck[11]
		fDlgVb(cCompete, aArrayFil, @aLogs[13])
	Endif

	//S-1280 - Informacoes complementares - Desoneracao
	If aCheck[4]
		fNew1280(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs[7], aCheck, @aLogs[8])
	EndIf

	//S-1200 - Servicos Tomados mediante Cessao de Mao de Obra
	If aCheck[1]
		fNew1200(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs[1], cChoice, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, lRelat, @aLogs[2], @aLogs[3])
	EndIf

	//S-1300 - Cntrinuicao sindical patronal
	If aCheck[3]
		fNew1300(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs[10], aCheck, @aLogs[11])
	EndIf

	If aCheck[2]
		fNew1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs[4], cChoice, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, @aLogs[5], @aLogs[6], lRelat)
	EndIf

	If !lWorkFlow .And. !lRelat .And. Len(aLogs) > 0
		fMakeLog(aLogs, aTitle, Nil, Nil, , OemToAnsi(STR0001), "M", "L",, .F.) //"Log de Ocorrencias"
		aLogs := {}
    Endif
EndIf

RestArea(aArea)

Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp34TdOk2 ³ Autor ³ Alessandro Santos     ³ Data ³ 17/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do modelo relativo aos eventuais eSocial.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aArrayFil - Array para armazenar as filiais selecionadas     ³±±
±±³          ³ cAliasTRB - Alias do arquivo temporario                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet = .T. ou .F.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function fGp34TdOk2(cAliasTRB)

Local aArea			:= GetArea()
Local nErro			:= 0
Local nI			:= 0
Local lRet 			:= .T.

//Limpa array
aArrayFil := {}

//Adiciona filiais selecionadas
(cAliasTRB)->(dbGoTop())

While (cAliasTRB)->(!EOF())
	If !Empty((cAliasTRB)->OK)
		aAdd(aArrayFil, Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()))
	EndIf
	(cAliasTRB)->(dbSkip())
EndDo

//Valida filiais
If Len(aArrayFil) == 0
	If !lMiddleware
		MsgStop(OemToAnsi(STR0021)) //#"Necessário selecionar uma filial para integração com o TAF"
	Else
		MsgStop(OemToAnsi(STR0076)) //#"Necessário selecionar uma filial para integração com o Middleware"
	EndIf
	lRet := .F.
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp34EvAll ³ Autor ³ Alessandro Santos     ³ Data ³ 30/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/Desmarca todos os eventos para integracao com TAF      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEvenAll  - Controla se marca ou desmarca                    ³±±
±±³          ³ aCheck    - Array com os eventos                             ³±±
±±³          ³ aObjCheck - Objetos dos eventos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGp34EvAll(lEvenAll, aCheck, aObjCheck)

Local nI := 0

//Atualiza check evento atual
lEvenAll := !lEvenAll

//Atualiza checks de todos os eventos
For nI := 1 To Len(aCheck)
	aCheck[nI] := lEvenAll
Next nI

//Atualiza objetos
For nI := 1 To Len(aObjCheck)
	aObjCheck[nI]:Refresh()
Next nI

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SetMarkAll  ³ Autor ³ Leandro Drumond       ³ Data ³ 17/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/desmarca todos os itens 			                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SetMarkAll(cMarca,lMarcar )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)

Local cAliasMark:=cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)
Return .T.

/*/{Protheus.doc} fDLGCHECK
Montagem de dialog para check da consulta de dados
@type function
@author Eduardo
@since 18/05/2018
@version 1.0
@param cChoice, caractere, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Function fDLGCHECK( cChoice )

Local lRet      := .F.
Local cOrd      := "1"
Local oDlg      := Nil
Local oCheck1   := Nil
Local oBtnOk    := Nil
Local oBtnCl    := Nil
Local bSet15
Local bSet24
Local aObjects      := {}
Local aInfo         := {}
Local aPosObj       := {}
Local aArrayFil     := {}
Local aCheck        := {.F.}
Local nChoice         := 1
//Monta as Dimensões da tela
aAdvSize    := MsAdvSize()

DEFINE MSDIALOG oDlg FROM 0,0 TO 120,300 PIXEL TITLE OemToAnsi("Informação"/*STR0039*/)
bSet15 := {|| lRet := .T., oDlg:End()}
bSet24 := {|| oDlg:End()}
aInfo   := {aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 3, 3}
AAdd(aObjects,{100, 075, .T., .T.})
AAdd(aObjects,{100, 125, .T., .T.})
aPosObj := MsObjSize(aInfo, aObjects, .T.)

//oGroup := TGROUP():New(aPosObj[1, 1], aPosObj[1, 2], aPosObj[1, 3]-50, aPosObj[1, 4]-200, OemToAnsi("Dados Complementares"), oDlg, CLR_BLUE,, .T.) //#"Eventos"
oCheck1 := TCheckBox():New(aPosObj[1, 1]+10, aPosObj[1, 2]+10, OemtoAnsi(STR0039), {|| aCheck[1]}, oDlg, 250, 10,, {|| aCheck[1] := !aCheck[1]},,,,,, .T.,,,)
oDlg:lEscClose := .F.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , Nil , Nil ) CENTERED
If aCheck[1]
    cChoice:= "1"
Else
    cChoice:= "0"
EndIF

Return ( lRet )

/*/{Protheus.doc} Event13
Habilita ou desabilitas as opções na tela de acordo com o campo "Ref. 13"
@author cicero.pereira
@since 23/07/2018
@param cIndic13, characters, Conteúdo do campo Ref. 13 - Sim / Não
@param lWhen, logical, Variável que determina se as checkboxes estão habilitadas
@param aCheck, array, Opções selecionadas na tela
/*/
Static Function Event13(cIndic13, lWhen, aCheck)

	If cIndic13 == "Sim"
		lWhen := .F.
		aCheck[2] := aCheck[3] := .F.
	Else
		lWhen := .T.
	EndIf

	oDlg:Refresh()

Return

/*/{Protheus.doc} EventExc
Habilita ou desabilitas as opções na tela de acordo com o campo "Ref. 13"
@author jose.silveira
@since 25/09/2018
@param cProcess, characters, Exclusao de eventos - Sim / Não
@param lWhenExc, logical, Variável que determina se as checkboxes estão habilitadas
@param lWhen, logical, Variável que determina se a checkbox do S-1200 está habilitada
@param lWhenRel, logical, Variável que determina se as checkboxes estão habilitadas
@param aCheck, array, Opções selecionadas na tela
/*/
Static Function EventExc(cProcess, lWhenExc, lWhen, lWhenRel, aCheck)

	//Habilita somente a seleção dos eventos S-1200 e S-1210
	If cProcess == "Exclusão"
		lWhenExc := .F.
		lWhenRel := .F.
		aCheck[3] := aCheck[4] := aCheck[5] := aCheck[6] := .F.
		aCheck[7] := aCheck[8] := aCheck[9] := aCheck[10] := aCheck[11] := .F.
	ElseIf cProcess == "Relatório"
		lWhen 	 := .F.
		lWhenExc := .F.
		lWhenRel := .T.
		aCheck[3] := aCheck[4] := aCheck[6] := .F. 
		aCheck[7] := aCheck[8] := aCheck[9] := aCheck[10] := .F.
	Else
		lWhen 	 := .T.
		lWhenExc := .T.
		lWhenRel := .T.
	EndIf

	oDlg:Refresh()

Return

/*/{Protheus.doc} EventComp
Habilita ou desabilita o campo "Ref. 13"
@author allyson.mesashi
@since 14/11/2018
@param cCompete, characters, Conteúdo do campo Competência
@param lWhen13, logical, Variável que determina se o campo "Ref. 13" estará habilitado
@param lWhenExc, logical, Variável que determina se as checkboxes estão habilitadas
@param cIndic13, characters, Variaval do campo "Ref. 13"
/*/
Static Function EventComp(cCompete, lWhen13, lWhenExc, cIndic13)

	If SubStr(cCompete,1,2) == "12"
		lWhen13  := .T.
	Else
		lWhen13  := .F.
		lWhenExc := .T.
		cIndic13 := "Nao"
	EndIf

	oDlg:Refresh()

Return

/*/{Protheus.doc} fVerRot132
Verifica se houve pagamento do roteiro 132 na competência
@author allyson.mesashi
@since 14/11/2018
@param cCompete, characters, Conteúdo do campo Competência
@param lVerSRC, logical, Check se verifica periodo em aberto
@return lRet, logical, Indica se há pagamento do roteiro 132
/*/
Static Function fVerRot132(cCompete,lVerSRC)

Local cJoinRCxRY	:= "% " + FWJoinFilial( "SRC", "SRY" ) + " %"
Local cJoinRDxRY	:= "% " + FWJoinFilial( "SRD", "SRY" ) + " %"
Local cSRDAlias		:= GetNextAlias()
Local lRet			:= .F.

Local oButton1
Local oButton2
Local oGroup1
Local oPanel1
Local oSay1
Local oSay2
Local oDlg

If lVerSRC
	BeginSql alias cSRDAlias
		SELECT SRD.R_E_C_N_O_
		FROM %table:SRD% SRD
		INNER JOIN %table:SRY% SRY ON %exp:cJoinRDxRY% AND SRD.RD_ROTEIR = SRY.RY_CALCULO
		WHERE SRD.RD_DATARQ = %exp:SubStr(cCompete,3,4)+SubStr(cCompete,1,2)%
		AND	SRD.RD_EMPRESA = '  '
		AND	SRY.RY_TIPO = '6'
		AND SRD.%notDel%
		AND SRY.%notDel%
		UNION ALL
		SELECT SRC.R_E_C_N_O_
		FROM %table:SRC% SRC
		INNER JOIN %table:SRY% SRY ON %exp:cJoinRCxRY% AND SRC.RC_ROTEIR = SRY.RY_CALCULO
		WHERE SRC.RC_PERIODO =	%exp:SubStr(cCompete,3,4)+SubStr(cCompete,1,2)%
		AND	SRY.RY_TIPO = '6'
		AND SRC.%notDel%
		AND SRY.%notDel%
	EndSql
Else
	BeginSql alias cSRDAlias
		SELECT SRD.R_E_C_N_O_
		FROM %table:SRD% SRD
		INNER JOIN %table:SRY% SRY ON %exp:cJoinRDxRY% AND SRD.RD_ROTEIR = SRY.RY_CALCULO
		WHERE SRD.RD_DATARQ = %exp:SubStr(cCompete,3,4)+SubStr(cCompete,1,2)%
		AND	SRD.RD_EMPRESA = '  '
		AND	SRY.RY_TIPO = '6'
		AND SRD.%notDel%
		AND SRY.%notDel%
	EndSql
EndIf

If (cSRDAlias)->( !EoF() )
	lRet := .T.

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0063) FROM 000, 000  TO 230, 500 COLORS 0, 16777215 PIXEL //"Aviso"

		@ 000, 000 MSPANEL oPanel1 SIZE 300, 230 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 065, 237 PROMPT OemToAnsi(STR0029) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
		@ 022, 017 SAY oSay1 PROMPT OemToAnsi(STR0057) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL //'Foram encontrados pagamentos de 2º parcela do 13º Salário neste mês, estes pagamentos serão considerados nos eventos S-1200/S-1210 juntamente com os valores de Folha, conforme Nota Orientativa 10.2018. Clique em "Abrir Link" para consultar a documentação no TDN'
		@ 090, 160 BUTTON oButton1 PROMPT STR0061 SIZE 037, 012 OF oPanel1 PIXEL//"Abrir Link"
		@ 090, 200 BUTTON oButton2 PROMPT STR0062 SIZE 037, 012 OF oPanel1 PIXEL//"Fechar"

		oButton1:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/x/T0TvGQ","","",1) }
		oButton2:bLClicked := {|| oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED

EndIf

(cSRDAlias)->( dbCloseArea() )

Return lRet

/*/{Protheus.doc} fVerRot131
Verifica se houve pagamento do roteiro 131 com os Ids antigos
@author allyson.mesashi
@since 26/11/2018
@param cCompete, characters, Conteúdo do campo Competência
@param lVerSRC, logical, Check se verifica periodo em aberto
@return lRet, logical, Indica se há pagamento do roteiro 132
/*/
Static Function fVerRot131(cCompete, lVerSRC, aVerbas)

Local cDtIni 		:= "%'" + SubStr(cCompete,3,4)+"01" + "'%"
Local cDtFim 		:= "%'" + SubStr(cCompete,3,4)+"11" + "'%"
Local cJoinRCxRY	:= "% " + FWJoinFilial( "SRC", "SRY" ) + " %"
Local cJoinRDxRY	:= "% " + FWJoinFilial( "SRD", "SRY" ) + " %"
Local cSRDAlias		:= GetNextAlias()
Local cVbPesq		:= ""

Local lRet			:= .F.

Local oButton1
Local oButton2
Local oGroup1
Local oPanel1
Local oSay1
Local oSay2
Local oDlg

cVbPesq	:= aVerbas[0123,1] + aVerbas[0124,1] + aVerbas[1288,1] + aVerbas[1289,1] + aVerbas[1290,1] + aVerbas[1291,1]
cVbPesq	+= aVerbas[1292,1] + aVerbas[1293,1] + aVerbas[1294,1] + aVerbas[1295,1] + aVerbas[0181,1] + aVerbas[0182,1]
cVbPesq	+= aVerbas[1436,1] + aVerbas[1437,1] + aVerbas[1438,1] + aVerbas[1439,1] + aVerbas[1440,1]
cVbPesq	+= aVerbas[1441,1] + aVerbas[1442,1] + aVerbas[1443,1] + aVerbas[1444,1] + aVerbas[1445,1]
cVbPesq := Upper("%" + fSqlIN( cVbPesq, 3 ) + "%")

If lVerSRC
	BeginSql alias cSRDAlias
		SELECT SRD.R_E_C_N_O_
		FROM %table:SRD% SRD
		INNER JOIN %table:SRY% SRY ON %exp:cJoinRDxRY% AND SRD.RD_ROTEIR = SRY.RY_CALCULO
		WHERE SRD.RD_DATARQ >= %exp:cDtIni%
		AND SRD.RD_DATARQ <= %exp:cDtFim%
		AND	SRD.RD_EMPRESA = '  '
		AND SRD.RD_PD IN (%exp:cVbPesq%)
		AND	SRY.RY_TIPO = '5'
		AND SRD.%notDel%
		AND SRY.%notDel%
		UNION ALL
		SELECT SRC.R_E_C_N_O_
		FROM %table:SRC% SRC
		INNER JOIN %table:SRY% SRY ON %exp:cJoinRCxRY% AND SRC.RC_ROTEIR = SRY.RY_CALCULO
		WHERE SRC.RC_PERIODO >= %exp:cDtIni%
		AND SRC.RC_PERIODO <= %exp:cDtFim%
		AND SRC.RC_PD IN (%exp:cVbPesq%)
		AND	SRY.RY_TIPO = '5'
		AND SRC.%notDel%
		AND SRY.%notDel%
	EndSql
Else
	BeginSql alias cSRDAlias
		SELECT SRD.R_E_C_N_O_
		FROM %table:SRD% SRD
		INNER JOIN %table:SRY% SRY ON %exp:cJoinRDxRY% AND SRD.RD_ROTEIR = SRY.RY_CALCULO
		WHERE SRD.RD_DATARQ >= %exp:cDtIni%
		AND SRD.RD_DATARQ <= %exp:cDtFim%
		AND	SRD.RD_EMPRESA = '  '
		AND SRD.RD_PD IN (%exp:cVbPesq%)
		AND	SRY.RY_TIPO = '5'
		AND SRD.%notDel%
		AND SRY.%notDel%
	EndSql
EndIf

If (cSRDAlias)->( !EoF() )
	lRet := .T.

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0063) FROM 000, 000  TO 230, 500 COLORS 0, 16777215 PIXEL //"Aviso"

		@ 000, 000 MSPANEL oPanel1 SIZE 300, 230 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 065, 237 PROMPT OemToAnsi(STR0029) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
		@ 022, 017 SAY oSay1 PROMPT OemToAnsi(STR0064) + CRLF + OemToAnsi(STR0065) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL //'Foram encontrados pagamentos de 1º parcela do 13º Salário sem as verbas referente a separação dos adicionais e das médias. É necessário efetuar a execução do rdmake UPDVB131 para a atualização do histórico de movimentos.'##'Clique em "Abrir Link" para consultar a documentação no TDN'
		@ 090, 160 BUTTON oButton1 PROMPT STR0061 SIZE 037, 012 OF oPanel1 PIXEL//"Abrir Link"
		@ 090, 200 BUTTON oButton2 PROMPT STR0062 SIZE 037, 012 OF oPanel1 PIXEL//"Fechar"

		oButton1:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/x/o6oQG","","",1) }
		oButton2:bLClicked := {|| oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED

EndIf

(cSRDAlias)->( dbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fDlgVb
Função responsável por executar validações e montar log
@author  Rafael Reis
@since   29/08/18
@version 1
/*/
//-------------------------------------------------------------------
Function fDlgVb(cCompete, aArrayFil, aLogs)
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local aIncons		:= {}
Local aFilInTaf 	:= {}

fGp23Cons(aFilInTaf, aArrayFil)
For nX:= 1 to Len(aFilInTaf)
	For nZ := 1 to Len(aFilInTaf[nX][3])
		aAdd( aLogs, "------------------------------------------------------------------------------------------------------------------------------------")
		aAdd( aLogs, "Filial " + aFilInTaf[nX][3][nZ] )
		Aadd( aLogs, "Competência " + cCompete)
		/* Validação de verbas usadas no cálculo de assistência médica */
		aIncons := fVldVbPla(aFilInTaf[nX][3][nZ], cCompete)
		If Len(aIncons[1]) > 0
			aAdd( aLogs, "Verbas de Assistência Médica com Natureza incorreta:" )
			For nY := 1 to Len(aIncons[1])
				aAdd( aLogs, aIncons[1][nY][1] + " - " + aIncons[1][nY][2] + " - RV_NATUREZ: " + aIncons[1][nY][3] + " - Atualizar RV_NATUREZ para 9219" )
			Next
		EndIf
		If Len(aIncons[2]) > 0
			aAdd( aLogs, "Verbas de Assistência Médica com Natureza incorreta:" )
			For nY := 1 to Len(aIncons[2])
				aAdd( aLogs, aIncons[2][nY][1] + " - " + aIncons[2][nY][2] + " - RV_NATUREZ: " + aIncons[2][nY][3] + " - Atualizar RV_NATUREZ para 1405" )
			Next
		EndIf
		If Len(aIncons[1]) == 0 .And. Len(aIncons[2]) == 0
			aAdd( aLogs, "Nenhuma inconsistência encontrada nas verbas de Assistência Médica." )
		Endif
		/* Validação de verbas de IRRF  */
		aIncons := fVldVbIrrf(aFilInTaf[nX][3][nZ], cCompete)
		If Len(aIncons) > 0
			aAdd( aLogs, "Verbas de IRRF com incidência incorreta:" )
			For nY := 1 to Len(aIncons)
				Aadd( aLogs, aIncons[nY][1] + " - " + aIncons[nY][2] + " - RV_INCIRF: " + aInCons[nY][3] + " - Atualizar RV_INCIRF para " + aIncons[nY][4] )
			Next
		Else
			aAdd( aLogs, "Nenhuma inconsistência encontrada nas verbas de IR." )
		Endif
		/* Validação de verbas de Pensão Alimentícia  */

		aIncons := fVldVbSrq(aFilInTaf[nX][3][nZ], cCompete)
		If Len(aIncons) > 0
			aAdd( aLogs, "Verbas de Pensão Alimentícia com incidência incorreta:" )
			For nY := 1 to Len(aIncons)
				Aadd( aLogs, aIncons[nY][1] + " - " + aIncons[nY][2] + " - " + aIncons[nY][3] + ": " + aInCons[nY][4] + " - Atualizar "+ aIncons[nY][3] +" para " + aIncons[nY][5] )
			Next
		Else
			aAdd( aLogs, "Nenhuma inconsistência encontrada nas verbas de Pensão Alimentícia." )
		Endif
		aAdd( aLogs, "------------------------------------------------------------------------------------------------------------------------------------")
	Next nZ
Next nX

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldVbPla
Função responsável por validar a configuração do campo RV_NATUREZA
nas verbas usadas para cálculo de plano de saúde
@author  Rafael Reis
@since   29/08/18
@version 1
/*/
//-------------------------------------------------------------------
Static Function fVldVbPla(cFil, cCompete)
Local cAliasTmp		:= GetNextAlias()
Local cJoinHRxRV	:= "% " + FWJoinFilial( "RHR", "SRV" ) + " %"
Local cJoinHSxRV	:= "% " + FWJoinFilial( "RHS", "SRV" ) + " %"
Local cJoinHPxRV	:= "% " + FWJoinFilial( "RHP", "SRV" ) + " %"
Local cFilRH		:= xFilial('RHR', cFil)
Local aIncons		:= { {}, {} }

BeginSql Alias cAliasTmp
	SELECT DISTINCT SRV.RV_COD, SRV.RV_DESC, SRV.RV_NATUREZ
	FROM %table:RHR% RHR
	INNER JOIN %table:SRV% SRV ON %exp:cJoinHRxRV% AND RHR.RHR_PD = SRV.RV_COD
	WHERE	RHR.RHR_COMPPG = %exp:Substr(cCompete,3,4)+Substr(cCompete,1,2)%
	AND		RHR.RHR_FILIAL = %exp:cFilRH%
	AND 	RHR.RHR_TPLAN IN ('1','2')
	AND 	SRV.RV_NATUREZ <> '9219'
	AND		RHR.%notDel%
	AND		SRV.%notDel%
	UNION
	SELECT DISTINCT SRV.RV_COD, SRV.RV_DESC, SRV.RV_NATUREZ
	FROM %table:RHS% RHS
	INNER JOIN %table:SRV% SRV ON %exp:cJoinHSxRV% AND RHS.RHS_PD = SRV.RV_COD
	WHERE	RHS.RHS_COMPPG = %exp:Substr(cCompete,3,4)+Substr(cCompete,1,2)%
	AND		RHS.RHS_FILIAL = %exp:cFilRH%
	AND		SRV.RV_NATUREZ <> '9219'
	AND		RHS.%notDel%
	AND		SRV.%notDel%
	UNION
	SELECT DISTINCT SRV.RV_COD, SRV.RV_DESC, SRV.RV_NATUREZ
	FROM %table:RHP% RHP
	INNER JOIN %table:SRV% SRV ON %exp:cJoinHPxRV% AND RHP.RHP_PD = SRV.RV_COD
	WHERE	RHP.RHP_COMPPG = %exp:Substr(cCompete,3,4)+Substr(cCompete,1,2)%
	AND		RHP.RHP_FILIAL = %exp:cFilRH%
	AND 	RHP.RHP_TPLAN = '1'
	AND		SRV.RV_NATUREZ <> '9219'
	AND		RHP.%notDel%
	AND		SRV.%notDel%
Endsql

While !(cAliasTmp)->(Eof())
	Aadd( aIncons[1], { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC , (cAliasTmp)->RV_NATUREZ } )
	(cAliasTmp)->(DbSkip())
Enddo
(cAliasTmp)->(DbCloseArea())

BeginSql Alias cAliasTmp
	SELECT DISTINCT SRV.RV_COD, SRV.RV_DESC, SRV.RV_NATUREZ
	FROM %table:RHR% RHR
	INNER JOIN %table:SRV% SRV ON %exp:cJoinHRxRV% AND RHR.RHR_PD = SRV.RV_COD
	WHERE	RHR.RHR_COMPPG = %exp:Substr(cCompete,3,4)+Substr(cCompete,1,2)%
	AND		RHR.RHR_FILIAL = %exp:cFilRH%
	AND 	RHR.RHR_TPLAN = '3' AND SRV.RV_NATUREZ <> '1405'
	AND		RHR.%notDel%
	AND		SRV.%notDel%
	UNION
	SELECT DISTINCT SRV.RV_COD, SRV.RV_DESC, SRV.RV_NATUREZ
	FROM %table:RHP% RHP
	INNER JOIN %table:SRV% SRV ON %exp:cJoinHPxRV% AND RHP.RHP_PD = SRV.RV_COD
	WHERE	RHP.RHP_COMPPG = %exp:Substr(cCompete,3,4)+Substr(cCompete,1,2)%
	AND		RHP.RHP_FILIAL = %exp:cFilRH%
	AND 	RHP.RHP_TPLAN = '2'
	AND		SRV.RV_NATUREZ <> '1405'
	AND		RHP.%notDel%
	AND		SRV.%notDel%
Endsql

While !(cAliasTmp)->(Eof())
	Aadd( aIncons[2], { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC , (cAliasTmp)->RV_NATUREZ } )
	(cAliasTmp)->(DbSkip())
Enddo
(cAliasTmp)->(DbCloseArea())

Return aIncons


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldVbIrrf
Função responsável por validar a configuração do campo RV_INCIRF das verbas
com id de cálculo de IRRF
@author  Rafael Reis
@since   29/08/18
@version 1
/*/
//-------------------------------------------------------------------
Static Function fVldVbIrrf(cFil, cCompete)
Local cAliasTmp		:= GetNextAlias()
Local cJoinRDxRV	:= "% " + FWJoinFilial( "SRD", "SRV" ) + " %"
Local cJoinRCxRV	:= "% " + FWJoinFilial( "SRC", "SRV" ) + " %"
Local cFilSR		:= xFilial('SRD', cFil)
Local cVersEnvio	:= ""
Local cIncIrf		:= ""
Local cVerb31		:= ""
Local cVerb32		:= ""
Local cVerb33		:= ""
Local cVerb34		:= ""
Local cVerb35		:= ""
Local aIncons		:= {}

fVersEsoc("S1010", .T.,/**/,/**/,@cVersEnvio)

BeginSql Alias cAliasTmp
	SELECT DISTINCT SRV.RV_COD, SRV.RV_DESC, SRV.RV_CODFOL, SRV.RV_INCIRF
	FROM %table:SRD% SRD
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRDxRV% AND SRD.RD_PD = SRV.RV_COD
	WHERE	SRD.RD_PERIODO = %exp:Substr(cCompete,3,4)+Substr(cCompete,1,2)%
	AND		SRD.RD_FILIAL = %exp:cFilSR%
	AND		SRV.RV_CODFOL IN ( '0009', '0066', '0067', '0071', '0152', '0237', '0978', '0983', '0993', '0995')
	AND		SRD.%notDel%
	AND		SRV.%notDel%
	UNION
	SELECT DISTINCT SRV.RV_COD, SRV.RV_DESC, SRV.RV_CODFOL, SRV.RV_INCIRF
	FROM %table:SRC% SRC
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRCxRV% AND SRC.RC_PD = SRV.RV_COD
	WHERE	SRC.RC_PERIODO = %exp:Substr(cCompete,3,4)+Substr(cCompete,1,2)%
	AND		SRC.RC_FILIAL = %exp:cFilSR%
	AND		SRV.RV_CODFOL IN ( '0009', '0066', '0067', '0071', '0152', '0237', '0978', '0983', '0993', '0995')
	AND		SRC.%notDel%
	AND		SRV.%notDel%
Endsql

While !(cAliasTmp)->(Eof())

	If cVersEnvio >= "2.6.00"
		cVerb31	:= "31  "
		cVerb32	:= "32  "
		cVerb33	:= "33  "
		cVerb34	:= "34  "
		cVerb35	:= "35  "
		cIncIrf := (cAliasTmp)->RV_INCIRF
	Else
		cVerb31	:= "31"
		cVerb32	:= "32"
		cVerb33	:= "33"
		cVerb34	:= "34"
		cVerb35	:= "35"
		cIncIrf := Substr((cAliasTmp)->RV_INCIRF,1,2)
	EndIf

	If (cAliasTmp)->RV_CODFOL $ '0009/0066/0993' .AND. cIncIrf <> cVerb31
		Aadd( aIncons, { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC, (cAliasTmp)->RV_INCIRF, '31' } )
	Elseif (cAliasTmp)->RV_CODFOL $ '0071/0995' .AND. cIncIrf <> cVerb32
		Aadd( aIncons, { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC, (cAliasTmp)->RV_INCIRF, '32' } )
	Elseif (cAliasTmp)->RV_CODFOL $ '0067/0237' .AND. cIncIrf <> cVerb33
		Aadd( aIncons, { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC, (cAliasTmp)->RV_INCIRF, '33' } )
	Elseif (cAliasTmp)->RV_CODFOL $ '0152' .AND. cIncIrf <> cVerb34
		Aadd( aIncons, { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC, (cAliasTmp)->RV_INCIRF, '34' } )
	Elseif (cAliasTmp)->RV_CODFOL $ '0978/0983' .AND. cIncIrf <> cVerb35
		Aadd( aIncons, { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC, (cAliasTmp)->RV_INCIRF, '35' } )
	Endif
	(cAliasTmp)->(DbSkip())
Enddo
(cAliasTmp)->(DbCloseArea())

Return aIncons

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldVbSrq
Função responsável por validar as configurações de natureza e incidência
das verbas de Pensão Alimentícia
@author  Rafael Reis
@since   29/08/18
@version 1
/*/
//-------------------------------------------------------------------
Static Function fVldVbSrq(cFil, cCompete)
Local cAliasTmp		:= GetNextAlias()
Local cJoinRQxRV	:= "% " + FWJoinFilial( "SRQ", "SRV" ) + " %"
Local cFilSRQ		:= xFilial('SRQ', cFil)
Local aIncons		:= {}

BeginSql Alias cAliasTmp
	SELECT DISTINCT RV_COD, RV_DESC, RV_INCIRF, RV_NATUREZ, '51' AS TIPO
	FROM %table:SRQ% SRQ
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRQxRV% AND SRQ.RQ_VERBADT = SRV.RV_COD
	WHERE SRQ.RQ_FILIAL = %exp:cFilSRQ% AND (SRV.RV_INCIRF <> '51' OR SRV.RV_NATUREZ <> '9213') AND SRQ.%notDel% AND SRV.%notDel%
	UNION
	SELECT DISTINCT RV_COD, RV_DESC, RV_INCIRF, RV_NATUREZ, '51' AS TIPO
	FROM %table:SRQ% SRQ
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRQxRV% AND SRQ.RQ_VERBFOL = SRV.RV_COD
	WHERE SRQ.RQ_FILIAL = %exp:cFilSRQ% AND (SRV.RV_INCIRF <> '51' OR SRV.RV_NATUREZ <> '9213') AND SRQ.%notDel% AND SRV.%notDel%
	UNION
	SELECT DISTINCT RV_COD, RV_DESC, RV_INCIRF, RV_NATUREZ, '53' AS TIPO
	FROM %table:SRQ% SRQ
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRQxRV% AND SRQ.RQ_VERBFER = SRV.RV_COD
	WHERE SRQ.RQ_FILIAL = %exp:cFilSRQ% AND (SRV.RV_INCIRF <> '53' OR SRV.RV_NATUREZ <> '9213') AND SRQ.%notDel% AND SRV.%notDel%
	UNION
	SELECT DISTINCT RV_COD, RV_DESC, RV_INCIRF, RV_NATUREZ, '52' AS TIPO
	FROM %table:SRQ% SRQ
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRQxRV% AND SRQ.RQ_VERB131 = SRV.RV_COD
	WHERE SRQ.RQ_FILIAL = %exp:cFilSRQ% AND (SRV.RV_INCIRF <> '52' OR SRV.RV_NATUREZ <> '9213') AND SRQ.%notDel% AND SRV.%notDel%
	UNION
	SELECT DISTINCT RV_COD, RV_DESC, RV_INCIRF, RV_NATUREZ, '52' AS TIPO
	FROM %table:SRQ% SRQ
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRQxRV% AND SRQ.RQ_VERB132 = SRV.RV_COD
	WHERE SRQ.RQ_FILIAL = %exp:cFilSRQ% AND (SRV.RV_INCIRF <> '52' OR SRV.RV_NATUREZ <> '9213') AND SRQ.%notDel% AND SRV.%notDel%
	UNION
	SELECT DISTINCT RV_COD, RV_DESC, RV_INCIRF, RV_NATUREZ, '54' AS TIPO
	FROM %table:SRQ% SRQ
	INNER JOIN %table:SRV% SRV ON %exp:cJoinRQxRV% AND SRQ.RQ_VERBPLR = SRV.RV_COD
	WHERE SRQ.RQ_FILIAL = %exp:cFilSRQ% AND (SRV.RV_INCIRF <> '54' OR SRV.RV_NATUREZ <> '9213') AND SRQ.%notDel% AND SRV.%notDel%
Endsql

While !(cAliasTmp)->(Eof())
	If (cAliasTmp)->RV_NATUREZ <> '9213'
		Aadd( aIncons, { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC, "RV_NATUREZ", (cAliasTmp)->RV_NATUREZ, "9213" } )
	Endif
	If (cAliasTmp)->RV_INCIRF <> (cAliasTmp)->TIPO
		Aadd( aIncons, { (cAliasTmp)->RV_COD, (cAliasTmp)->RV_DESC, "RV_INCIRF", (cAliasTmp)->RV_INCIRF, (cAliasTmp)->TIPO } )
	Endif
	(cAliasTmp)->(DbSkip())
Enddo
(cAliasTmp)->(DbCloseArea())

Return aIncons


/*/{Protheus.doc} fVldRJ5
Verifica se há divergência na estrutura do campo RJ5_COD
@author allyson.mesashi
@since 10/05/2019
@return lRet, logical, Indica se a estrutura está correta
/*/
Static Function fVldRJ5()

Local lRet			:= .T.

Local oButton1
Local oButton2
Local oGroup1
Local oPanel1
Local oSay1
Local oSay2
Local oDlg

If ChkFile('RJ5') .And. TamSX3("CTT_CUSTO")[1] != TamSX3("RJ5_COD")[1]
	lRet := .F.
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0063) FROM 000, 000  TO 240, 500 COLORS 0, 16777215 PIXEL //"Aviso"

		@ 000, 000 MSPANEL oPanel1 SIZE 330, 230 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 079, 237 PROMPT OemToAnsi(STR0029) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
		@ 022, 017 SAY oSay1 PROMPT OemToAnsi(STR0070) + CRLF + OemToAnsi(STR0071) + CRLF + OemToAnsi(STR0065) SIZE 215, 055 OF oPanel1 COLORS 0, 16777215 PIXEL //"O campo RJ5_COD possui tamanho divergente em relação ao tamanho do campo CTT_CUSTO."##"Solicite ao administrador que efetue o ajuste do tamanho do campo RJ5_COD através do módulo SIGACFG - Configurador e revise o relacionamento de lotações através da rotina GPEA934B."##'Clique em "Abrir Link" para consultar a documentação no TDN'#"Atencao"
		@ 090, 160 BUTTON oButton1 PROMPT STR0061 SIZE 037, 012 OF oPanel1 PIXEL//"Abrir Link"
		@ 090, 200 BUTTON oButton2 PROMPT STR0062 SIZE 037, 012 OF oPanel1 PIXEL//"Fechar"

		oButton1:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/x/0o5DHQ","","",1) }
		oButton2:bLClicked := {|| oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

Return lRet

/*/{Protheus.doc} fVldTaf
Verifica se há divergência na estrutura das tabelas TAFXERP e TAFST2
@author allyson.mesashi
@since 17/06/2019
@return lRet, logical, Indica se a estrutura está correta
/*/
Function fVldTaf()

Local aErros	:= {}
Local cAliasERP	:= GetNextAlias()
Local cAliasST2	:= GetNextAlias()
Local cMsgErro	:= ""
Local lRet		:= .T.

If FindFunction("TAFTabInteg")
	If TAFTabInteg("TAFXERP", cAliasERP, @aErros)
		If !TAFTabInteg("TAFST2", cAliasST2, @aErros)
			lRet := .F.
			If !Empty(aErros)
				cMsgErro := STR0072 + CRLF//"Erro na Criação/Abertura da tabela TAFST2."
				cMsgErro += aErros[1, 6]
			EndIf
		EndIf
	Else
		lRet := .F.
		If !Empty(aErros)
			cMsgErro := STR0073 + CRLF//"Erro na Criação/Abertura da tabela TAFXERP."
			cMsgErro += aErros[1, 6]
		EndIf
	EndIf
EndIf

If Select(cAliasERP) > 0
	(cAliasERP)->( dbCloseArea() )
EndIf
If Select(cAliasST2) > 0
	(cAliasST2)->( dbCloseArea() )
EndIf

If !lRet
	Help( ,, OemToAnsi(STR0029),, OemToAnsi(cMsgErro), 1, 0 ) //"Atenção"
EndIf

Return lRet

/*/{Protheus.doc} fVer1397
Verifica se houve geração da verba de Id 1397 no roteiro ADI
@author allyson.mesashi
@since 11/05/2020
@param cCompete, characters, Conteúdo do campo Competência
@return lRet, logical, Indica se há pagamento do roteiro 132
/*/
Static Function fVer1397(cCompete, aVerbas)

Local aLog			:= { {} }
Local aTitle		:= {STR0092}//"Verbas geradas"

Local cJoinRDxRY	:= "% " + FWJoinFilial( "SRD", "SRY" ) + " %"
Local cPeriod 		:= "%'" + SubStr( cCompete, 3, 4 ) + SubStr( cCompete, 1, 2 ) + "'%"
Local cSRDAlias		:= GetNextAlias()
Local cVbNew		:= Space(3)
Local cVbPesq		:= aVerbas[1397,1]

Local lNovo			:= .F.
Local lRet			:= .F.

Local oButton1
Local oButton2
Local oGroup1
Local oPanel1
Local oSay1
Local oSay2
Local oDlg

cVbPesq := Upper("%" + fSqlIN( cVbPesq, 3 ) + "%")

DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD

BeginSql alias cSRDAlias
	SELECT SRD.R_E_C_N_O_, 'SRD' AS TAB
	FROM %table:SRD% SRD
	INNER JOIN %table:SRY% SRY ON %exp:cJoinRDxRY% AND SRD.RD_ROTEIR = SRY.RY_CALCULO
	WHERE SRD.RD_DATARQ = %exp:cPeriod%
	AND	SRD.RD_EMPRESA = '  '
	AND SRD.RD_PD IN (%exp:cVbPesq%)
	AND	SRY.RY_TIPO = '2'
	AND SRD.%notDel%
	AND SRY.%notDel%
EndSql

If (cSRDAlias)->( !EoF() )
	lRet := .T.

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0063) FROM 000, 000  TO 230, 500 COLORS 0, 16777215 PIXEL Style 128//"Aviso"

		@ 000, 000 MSPANEL oPanel1 SIZE 300, 230 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 070, 237 PROMPT OemToAnsi(STR0029) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
		@ 022, 017 SAY oSay1 PROMPT OemToAnsi(STR0093) + CRLF + OemToAnsi(STR0065) SIZE 215, 055 OF oPanel1 COLORS 0, 16777215 PIXEL //'Identificamos que foi realizada a Redução Salarial (MP 936/2020) no Cálculo de Adiantamento, utilizando a mesma verba do Cálculo Mensal. Isso irá gerar erro no cálculo do INSS feito pelo sistema DCTFWeb. Para correção iremos gerar uma verba de contra-partida em sua base de dados (tabela SRD) no roteiro de Adiantamento com o mesmo valor da redução gerada. Informe o código da verba no campo abaixo.'##'Clique em "Abrir Link" para consultar a documentação no TDN'

		@ 077, 012 SAY oSay2 PROMPT OemToAnsi(STR0094) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL FONT oFont//'Código da verba: '
		@ 077, 062 MSGET cVbNew SIZE 56,07 OF oDlg PIXEL F3 'SRV' WHEN .T. PICTURE "@!" VALID (Empty(cVbNew) .Or. fValSRV(cVbNew))

		@ 090, 160 BUTTON oButton1 PROMPT STR0061 SIZE 037, 012 OF oPanel1 PIXEL//"Abrir Link"
		@ 090, 200 BUTTON oButton2 PROMPT STR0095 SIZE 037, 012 OF oPanel1 PIXEL//"Processar"

		oButton1:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/x/hOynI","","",1) }
		oButton2:bLClicked := {|| Iif( !Empty(cVbNew) .And. fValSRV(cVbNew), oDlg:End(), MsgAlert(STR0096) ) }//"Informe um código de verba válido"

	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

SRD->( dbSetOrder(2) )//RD_FILIAL+RD_CC+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ

While (cSRDAlias)->( !EoF() )
	SRD->( dbGoTo( (cSRDAlias)->R_E_C_N_O_ ) )

	cFilNew	:= SRD->RD_FILIAL
	cMatNew	:= SRD->RD_MAT
	cTp1New	:= SRD->RD_TIPO1
	cHorNew	:= SRD->RD_HORAS
	cVlrNew	:= SRD->RD_VALOR
	cDtPNew	:= SRD->RD_DATPGT
	cSeqNew	:= SRD->RD_SEQ
	cTp2New	:= SRD->RD_TIPO2
	cMesNew	:= SRD->RD_MES
	cStaNew	:= SRD->RD_STATUS
	cInsNew	:= SRD->RD_INSS
	cIrNew	:= SRD->RD_IR
	cFgtNew	:= SRD->RD_FGTS
	cPrcNew	:= SRD->RD_PROCES
	cPerNew	:= SRD->RD_PERIODO
	cSemNew	:= SRD->RD_SEMANA
	cRotNew	:= SRD->RD_ROTEIR
	cDtRNew	:= SRD->RD_DTREF
	cVlBNew	:= SRD->RD_VALORBA
	cCCNew	:= SRD->RD_CC
	cItmNew	:= SRD->RD_ITEM
	cClVNew	:= SRD->RD_CLVL

    lNovo := SRD->( !dbSeek( cFilNew + cCCNew + cMatNew + cPerNew + cVbNew + cSemNew + cSeqNew ) )

	If SRD->( Reclock("SRD", lNovo) )
		SRD->RD_FILIAL	:=	cFilNew
		SRD->RD_MAT		:=	cMatNew
		SRD->RD_PD		:=	cVbNew
		SRD->RD_TIPO1	:=	cTp1New
		SRD->RD_HORAS	:=	cHorNew
		SRD->RD_VALOR	:=	cVlrNew
		SRD->RD_DATPGT	:=	cDtPNew
		SRD->RD_SEQ		:=	cSeqNew
		SRD->RD_TIPO2	:=	cTp2New
		SRD->RD_MES		:=	cMesNew
		SRD->RD_STATUS	:=	cStaNew
		SRD->RD_INSS	:=	cInsNew
		SRD->RD_IR		:=	cIrNew
		SRD->RD_FGTS	:=	cFgtNew
		SRD->RD_PROCES	:=	cPrcNew
		SRD->RD_PERIODO	:=	cPerNew
		SRD->RD_DATARQ	:=	cPerNew
		SRD->RD_SEMANA	:=	cSemNew
		SRD->RD_ROTEIR	:=	cRotNew
		SRD->RD_DTREF	:=	cDtRNew
		SRD->RD_VALORBA	:=	cVlBNew
		SRD->RD_CC		:=	cCCNew
		SRD->RD_ITEM	:=	cItmNew
		SRD->RD_CLVL	:=	cClVNew
		SRD->( MsUnlock() )
		If aScan( aLog[1], { |x| x == STR0097 + cFilNew + STR0098 + cMatNew + STR0100 + cCCNew + STR0099 + Transform( cVlrNew, "@E 99,999,999,999.99" ) }  ) == 0
			aAdd( aLog[1], STR0097 + cFilNew + STR0098 + cMatNew + STR0100 + cCCNew + STR0099 + Transform( cVlrNew, "@E 99,999,999,999.99" ) )//"Filial: "##"  -  Matrícula: "##" -  Centro de Custo: "##" -  Valor: R$ "
		EndIf
	EndIf

	(cSRDAlias)->( dbSkip() )
Enddo

(cSRDAlias)->( dbCloseArea() )

If !Empty(aLog)
	fMakeLog(aLog, aTitle, Nil, Nil, , OemToAnsi(STR0001), "M", "L",, .F.) //"Log de Ocorrencias"
	aLog := {}
EndIf

Return lRet

/*/{Protheus.doc} fValSRV
Valida se há a verba informada na tabela SRV
@author allyson.mesashi
@since 11/05/2020
@param cVbNew, characters Verba informada pelo usuario
@return lRet, logical, Indica se há a verba cadastrada
/*/
Static Function fValSRV(cVbNew)

Local lRet	:= .F.

SRV->( dbSetOrder(1) )
If SRV->( dbSeek( xFilial("SRV")+cVbNew ) )
	lRet := .T.
EndIf

Return lRet