//#Include 'rwmake.ch'
#Include 'Totvs.ch'
//#include "protheus.ch"
#define DS_MODALFRAME   128

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NOVO6     ºAutor  ³Microsiga           º Data ³  05/02/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SCIF040(cOrig) //'1'-MATA097 SCR     '2'-SCIA130 Z02    3- ressacimento

Local aArea    := GetArea()
Local aAreaSE2 := SE2->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local aAreaZ02 := Z02->(GetArea())
Local aAreaSX6 := SX6->(GetArea())
Local lContabiliza := .F.
Local lAglutina    := .F.
Local lDigita      := .F.

Local lAtivo := .F.
PRIVATE oDlg
PRIVATE oFont := TFont():New("Arial",,14,.T.)

Private cGet  := Space( TamSX3("A6_COD")[1])
Private cGet2 := Space( TamSX3("A6_AGENCIA")[1])
Private cGet3 := Space( TamSX3("A6_NUMCON")[1])
Private oSay  := ''
Private oSay2 := ''
Private oSay3 := ''


Private aRecPA := {}
Private aRecSE2:= {}

//Begin Transaction


//Primeiro verifica de onde está vindo //'1'-MATA097 SCR     '2'-SCIA130 Z02
If cOrig == "1"
	
	cCampoTp := "SCR->CR_TIPO"
	cChave   := SCR->CR_NUM
ElseIf cOrig $ "2/3"
	
	cCampoTp := "Z02->Z02_TPPA"
	cChave   := Z02->Z02_CHAVE 
EndIf



//PA deve ser liberado, mas antes deve-se escolher o banco do movimento a ser efetuado na SE5. -FINA100
If cOrig == '1' .and. &(cCampoTp) == 'PA'
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 200,350 PIXEL TITLE 'Liberação Movimento PA'
	
	oSay := TSay():New( 19, 10,{|| "Banco:"},oDlg,, oFont,,,, .T., CLR_BLACK,CLR_WHITE )
	oSay:lTransparent:= .F.
	@ 17,75 MSGET oGet VAR cGet F3('SA6') Valid !Empty(cGet) SIZE 76,10 OF oDlg PIXEL //PICTURE  "99/99/9999"
	
	oSay2 := TSay():New( 35, 10,{|| "Agencia:"},oDlg,, oFont,,,, .T., CLR_BLACK,CLR_WHITE )
	oSay2:lTransparent:= .F.
	@ 33,75 MSGET oGet2 VAR cGet2 Valid !Empty(cGet2) SIZE 76,10 OF oDlg PIXEL
	
	oSay3 := TSay():New( 51, 10,{|| "Conta:"},oDlg,, oFont,,,, .T., CLR_BLACK,CLR_WHITE )
	oSay3:lTransparent:= .F.
	@ 49,75 MSGET oGet3 VAR cGet3 Valid !Empty(cGet3) SIZE 76,10 OF oDlg PIXEL
	
	//aSize := MsAdvSize(.F.)
	//Define MsDialog oDialog TITLE "Titulo" STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
	//oDialog:lMaximized := .T. //Maximiza a janela
	
	oSButton1 := SButton():New( 70,120,1,{|| oDlg:End()},oDlg,.T.,,)
	//oSButton2 := SButton():New( 50,120,22,{|| lOk := .F., oDlg:End()},oDlg,.T.,,)
	
	//DEFINE MsDialog oDlg Pixel Style DS_MODALFRAME // Cria Dialog sem o botão de Fechar.
	ACTIVATE MSDIALOG oDlg CENTERED
	
	//Se for banco que gera Mov Bancario
	//If cGet $ GetMv('ES_BCOSE5')
	
	aFINA100 := {   { "E5_DATA"		, Date()	        , Nil },;
					{ "E5_MOEDA"	, "M1"			    , Nil },;
					{ "E5_VALOR"	, SCR->CR_TOTAL	    , Nil },;
					{ "E5_NATUREZ"	, '210115' /*GetMv('ES_NATSE5')*/, Nil },;
					{ "E5_BANCO"	, cGet			    , Nil },;
					{ "E5_AGENCIA"	, cGet2			    , Nil },;
					{ "E5_CONTA"	, cGet3	            , Nil },;
					{ "E5_BENEF"	, 'Beneficiario'    , Nil },;
					{ "E5_HISTOR"	, 'Historico'	    , Nil }}
					
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3) //Pagamento
	
	// -- trecho de validacao e gravacao apos rotina automatica
	If lMsErroAuto
		
		MostraErro()
		//DisarmTransaction()
	Else
	EndIf
	
	//EndIf
	
	
	//Prestação de Contas - Compensa PA já aprovado contra as linhas do Z02 a serem criadas no SE2.
	//Cada linha do Z02 será uma NF
ElseIf ( cOrig == '1' .and. &(cCampoTp) == 'D1' ) .or. cOrig == '2'//Prestão de Contas
	
	
	nValPA  := 0
	nValTit := 0
	
	//If cOrig == '2'
	//	If Z02->Z02_STATUS == '1' //Se o Processo ainda está bloqueado
	//		Help( ,, "HELP","MDMVlPos", "Processo ainda bloqueado. Efetue desbloqueio pelo Compras", 1, 0)

	//		Return()
	//	EndIf
	//EndIf
	
	//Faz Update no Z02 para Inc PA Ressacimento
	cQuery := " UPDATE " +RetSQLName("Z02") + " "
	cQuery += " SET Z02_STATUS = '2' "
	cQuery += " WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
	cQuery += " AND Z02_CHAVE = '" + cChave /*SCR->CR_NUM*/ + "'"
	cQuery += " AND D_E_L_E_T_= '' "


	
	nRet := TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	End
	
	
	//Pelo campo de chave CR_CHAVE, acha o SE2 PA.
	dbSelectArea('SE2')
	dbSetOrder(1)
	If dbSeek(xFilial('SE2')+cChave /*SCR->CR_NUM*/,.f.)
		aADD(aRecPA,SE2->(Recno()))
		nValPA := SE2->E2_VALOR
	EndIf
	
	//Com esta mesma chave, vamos achar o Z02...
	dbSelectArea('Z02')
	dbSetOrder(1)
	dbSeek(xFilial('Z02')+Padr(cChave /*SCR->CR_NUM*/, TamSX3('Z02_CHAVE')[1]),.f.)
	
	cChavePsq := Z02->(Z02_FILIAL+Z02_CHAVE)
	
	While !EOF() .and. cChavePsq == Z02->(Z02_FILIAL+Z02_CHAVE)
		
		//Aqui eu testo se ja nao existe este lançamento
		dbSelectArea('SE2')
		dbSetOrder(1) //Filial + PRefixo + Num + PArc + Tipo + Fornec + Loja
		If dbSeek(xFilial('SE2')+Z02->(Z02_PREF+Z02_NUMERO+Z02_PARC+Z02_TIPO+Z02_FORNEC+Z02_LOJA),.f.)
			aADD(aRecSE2,SE2->(Recno())) //Preciso dos RECNOS para depois compensar
			nValTit += SE2->E2_VALOR
			Z02->(dbSkip())
			Loop
		EndIf
		
		//Lançar os titulos NF das linhas Z02
		cHistorico := "Incl Auto Desp"
		
		aCab := {	{	"E2_FILIAL"		,	xFilial("SE2")						,	NIL},;	// Filial do Sistema
					{	"E2_PREFIXO"	,	Z02->Z02_PREF						,	NIL},;	// Prefixo do Titulo
					{	"E2_NUM"		,	Z02->Z02_NUMERO						,	NIL},;	// Numero do Titulo
					{	"E2_PARCELA"	,	Z02->Z02_PARC						,	NIL},;	// Parcela do Titulo
					{	"E2_TIPO"		,	Z02->Z02_TIPO						,	NIL},;	// Tipo do Titulo
					{	"E2_FORNECE"	,	Z02->Z02_FORNECE					,	NIL},; 	// Fornecedor
					{	"E2_LOJA"		,	Z02->Z02_LOJA						,	NIL},;	// Loja do Fornecedor
					{	"E2_NATUREZ"	,	Z02->Z02_NAT             			,	NIL},;	// Natureza do Titulo
					{	"E2_EMISSAO"	,	DDATABASE							,	NIL},;	// Data de Emissao
					{	"E2_VENCTO"		,	DDATABASE+10							,	NIL},;	// Data de Vencimento
					{	"E2_VENCREA"	,	DataValida(DDATABASE+10,.T.)			,	NIL},;	// Data de Vencimento Real
					{	"E2_VALOR"		, 	Z02->Z02_VALOR						,	NIL},;	// Valor do Titulo
					{	"E2_HIST"		,	cHistorico							,	NIL},;	// Historico do titulo
					{	"E2_MOEDA"		,	1									,	NIL} }	// Moeda
					
		aReturn := U_SCIF050( aCab )	// Executa a rotina automatica
		
		If aReturn[1] // Sucesso
			
			cLog := "Sucesso "
			cLog += aReturn[2]

			
			RecLock("Z02",.f.)
			Z02->Z02_RETINC := 'Incluido em ' + DtoC( Date() ) + ' as ' + Time()
			Z02->(MsUnlock())
			
			aADD(aRecSE2,SE2->(Recno())) //Preciso dos RECNOS para depois compensar
			nValTit += SE2->E2_VALOR
			
		Else // Erro
			
			cLog := "Erro "
			cLog += aReturn[2]

			
			lOk := .F.
			aLog := {}
			AADD(aLog,cLog)
			aEval( aLog, {|x| AutoGrLog( x ) } )
			MostraErro()
			
			RecLock("Z02",.f.)
			Z02->Z02_RETINC := 'Erro em ' + DtoC( Date() ) + ' as ' + Time() + ' Log ' + cLog
			Z02->(MsUnlock())
			
		EndIf

		dbSelectArea('Z02')		
		Z02->(dbSkip())
	End
	
	
	//Checagem dos títulos lançadas, se todos OK, então vamos compensar...
	dbSelectArea('Z02')
	dbSetOrder(1)
	dbSeek(xFilial('Z02')+cChave /*SCR->CR_NUM*/,.f.)
	
	cChavePsq := Z02->(Z02_FILIAL+Z02_CHAVE)
	lTudoOK := .T.
	While !EOF() .and. cChavePsq == Z02->(Z02_FILIAL+Z02_CHAVE)
		
		If "Erro" $ Z02->Z02_RETINC
			lTudoOK := .F.
		EndIf
		Z02->(dbSkip())
	End
	
	If lTudoOK





	Else

	EndIf
		
	//Carregar as info na função de CP.
	If lTudoOK
		
		If MaIntBxCP(2,aRecSE2,,aRecPA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,date()/*dBaixaCMP*/)
			

                           
			If nValPA > nValTit // Devemos lançar SE1 para titular nos devolver

				cHistorico := "Cob ao Tit pago a mais"
				
				cNumTitulo := Soma1(   Strzero(Val(GetMV( 'ES_ACETITR' )), 9) , 9 ) // atualiza o proximo numero do titulo
				PutMV( 'ES_ACETITR', cNumTitulo )
				aDuplicR := {}
				aAdd(aDuplicR,{ "E1_FILIAL"	  , xFilial("SE1")    , NIL })
				aAdd(aDuplicR,{ "E1_PREFIXO"  , "REC"             , NIL })
				aAdd(aDuplicR,{ "E1_NUM"      , cNumTitulo        , NIL })
				aAdd(aDuplicR,{ "E1_PARCELA"  , ""                , NIL })
				aAdd(aDuplicR,{ "E1_TIPO"     , "NF"              , NIL })
				aAdd(aDuplicR,{ "E1_CLIENTE"  , Z03->Z03_CLI      , NIL })
				aAdd(aDuplicR,{ "E1_LOJA"     , Z03->Z03_CLILJ    , NIL })
				aAdd(aDuplicR,{ "E1_VALOR"    , Abs(nValPA - nValTit)  , NIL })
				aAdd(aDuplicR,{ "E1_SALDO"    , Abs(nValPA - nValTit)  , NIL })
				aAdd(aDuplicR,{ "E1_EMISSAO"  , dDataBase	      , NIL })
				aAdd(aDuplicR,{ "E1_VENCTO"	  , dDataBase+10	  , NIL })
				aAdd(aDuplicR,{ "E1_VENCREA"  , DataValida(dDataBase+10,.T.)   , NIL })
				aAdd(aDuplicR,{ "E1_NATUREZ"  , GetMv("ES_NATCOB"), NIL })
				aAdd(aDuplicR,{ "E1_HIST"     ,cHistorico         , NIL })
				
				nModulo := 6 // Financeiro
				lAutoErrNoFile:= .T.
				lMsErroAuto := .f.
				// -- contas a receber
				MsExecAuto( { |x,y| FINA040(x,y)} , aDuplicR, 3)
				
				If lMsErroAuto

					aLog := GetAutoGRLog()
					aEval(aLog,{|x| cLog += x + CRLF})
		
					MostraErro()

					lOk := .F.
					//DisarmTransaction()
					Break
				Else
					cLog := "Sucesso "

				
				Endif
					
			ElseIf nValPA < nValTit // Devemos lançar SE2 para titular pagando mais pra ele...
				
				cHistorico := "Dev ao Tit gasto a mais"
				
				cNumTitulo := Soma1(   Strzero(Val(GetMV( 'ES_ACETITP' )), 9) , 9 ) // atualiza o proximo numero do titulo
				PutMV( 'ES_ACETITP', cNumTitulo )

				aCab := {	{	"E2_FILIAL"		,	xFilial("SE2")			 ,	NIL},;	// Filial do Sistema
							{	"E2_PREFIXO"	,	"DEV"					 ,	NIL},;	// Prefixo do Titulo
							{	"E2_NUM"		,	cNumTitulo				 ,	NIL},;	// Numero do Titulo
							{	"E2_PARCELA"	,	""						 ,	NIL},;	// Parcela do Titulo
							{	"E2_TIPO"		,	"NF"					 ,	NIL},;	// Tipo do Titulo
							{	"E2_FORNECE"	,	Z03->Z03_FOR			 ,	NIL},; 	// Fornecedor
							{	"E2_LOJA"		,	Z03->Z03_FORLJ			 ,	NIL},;	// Loja do Fornecedor
							{	"E2_NATUREZ"	,	GetMv("ES_NATPAG")       ,	NIL},;	// Natureza do Titulo
							{	"E2_EMISSAO"	,	DDATABASE				 ,	NIL},;	// Data de Emissao
							{	"E2_VENCTO"		,	DDATABASE				 ,	NIL},;	// Data de Vencimento
							{	"E2_VENCREA"	,	DataValida(DDATABASE,.T.),	NIL},;	// Data de Vencimento Real
							{	"E2_VALOR"		, 	Abs(nValPA - nValTit)	 ,	NIL},;	// Valor do Titulo
							{	"E2_HIST"		,	cHistorico				 , 	NIL},;	// Historico do titulo
							{	"E2_MOEDA"		,	1						 ,	NIL} }	// Moeda
							
				aReturn := U_SCIF050( aCab )	// Executa a rotina automatica
				
				If aReturn[1] // Sucesso
					
					cLog := "Sucesso "
					cLog += aReturn[2]

					
				Else // Erro
					
					cLog := "Erro "
					cLog += aReturn[2]

					
					lOk := .F.
					aLog := {}
					AADD(aLog,cLog)
					aEval( aLog, {|x| AutoGrLog( x ) } )
					MostraErro()
					
				EndIf
			EndIf
			
		Else
			

			Help( ,, "HELP","MDMVlPos", "Processo de compensação não efetuado", 1, 0)
			//DisarmTransaction()
		EndIf
	EndIf
	
ElseIf ( cOrig == '1' .and. &(cCampoTp) == 'D2' ) .or. cOrig == '3' //Ressarcimento -Só precisa verificar o valor do titulo para devolver ao titular.



	
	nSumTot := 0
	
	If cOrig $ '2/3'

		//If Z02->Z02_STATUS == '1' //Se o Processo ainda está bloqueado

		//	Help( ,, "HELP","MDMVlPos", "Processo ainda bloqueado. Efetue desbloqueio pelo Compras", 1, 0)
		//	Return()
		//EndIf
		
		dbSelectArea("Z02")
		dbSetOrder(1)
		dbSeek(xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES),.f.)
		cChave := xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
		While !EOF() .and. cChave == xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
			nSumTot += Z02->Z02_VALOR
			Z02->(dbSkip())
		End
		RestArea(aAreaZ02)
		
	Else
		nSumTot := SCR->CR_TOTAL
	EndIf
	



	//Pegar dados do titular - Fornecedor
	dbSelectArea('Z03')
	dbSetOrder(1)
	dbSeek(xFilial('Z03')+Z02->Z02_CODUSR,.f.)
	
	//Inclui o Pgto ao Titular
	cHistorico := "Incl Pgto Ressar"
	
	aCab := {	{	"E2_FILIAL"		,	xFilial("SE2")						,	NIL},;	// Filial do Sistema
				{	"E2_PREFIXO"	,	"RES"								,	NIL},;	// Prefixo do Titulo
				{	"E2_NUM"		,	Z02->Z02_NUMRES						,	NIL},;	// Numero do Titulo
				{	"E2_PARCELA"	,	""									,	NIL},;	// Parcela do Titulo
				{	"E2_TIPO"		,	"NF"								,	NIL},;	// Tipo do Titulo
				{	"E2_FORNECE"	,	Z03->Z03_FOR						,	NIL},; 	// Fornecedor
				{	"E2_LOJA"		,	Z03->Z03_FORLJ						,	NIL},;	// Loja do Fornecedor
				{	"E2_NATUREZ"	,	GetMv("ES_NATRES")         			,	NIL},;	// Natureza do Titulo
				{	"E2_EMISSAO"	,	dDataBase							,	NIL},;	// Data de Emissao
				{	"E2_VENCTO"		,	dDataBase							,	NIL},;	// Data de Vencimento
				{	"E2_VENCREA"	,	DataValida(dDataBase,.T.)			,	NIL},;	// Data de Vencimento Real
				{	"E2_VALOR"		, 	nSumTot					 			,	NIL},;	// Valor do Titulo
				{	"E2_HIST"		,	cHistorico							,	NIL},;	// Historico do titulo
				{	"E2_MOEDA"		,	1									,	NIL} }	// Moeda
				



	
	aReturn := U_SCIF050( aCab )	// Executa a rotina automatica
	
	If aReturn[1] // Sucesso
		
		cLog := "Sucesso "
		cLog += aReturn[2]
		
		RecLock("Z02",.f.)
		Z02->Z02_RTINCR := 'Incluido em ' + DtoC( Date() ) + ' as ' + Time()
		Z02->(MsUnlock())
		
	Else // Erro
		
		cLog := "Erro "
		cLog += aReturn[2]
		
		lOk := .F.
		aLog := {}
		AADD(aLog,cLog)
		aEval( aLog, {|x| AutoGrLog( x ) } )
		MostraErro()
		
		RecLock("Z02",.f.)
		Z02->Z02_RTINCR := 'Erro em ' + DtoC( Date() ) + ' as ' + Time() + ' Log ' + cLog
		Z02->(MsUnlock())
		
	EndIf
	
EndIf

//End Transaction

RestArea(aArea)
RestArea(aAreaSE1)
RestArea(aAreaSE2)
RestArea(aAreaSA2)
RestArea(aAreaZ02)
RestArea(aAreaSX6)
Return()