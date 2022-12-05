#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPENCEMP.CH"

/*/{Protheus.doc}GpEncEmp()
- Gera encargos empresa analiticamente para bases migradas da P11 que usavam MV_ENCINSS = N.
@Type User Function
@author:	Jônatas Alves	
@since:		20/06/2017
@param:		
@version 1.0
@return
/*/
User Function GpEncEmp()

	Local aArea 		:= GetArea()

	Private cAliasSM0	:= GetNextAlias()
	Private cMark    	:= GetMark()
	Private cMesDe		:= Space( 2 )
	Private cMesAte		:= Space( 2 )
	Private cAnoDe		:= Space( 4 )
	Private cAnoAte		:= Space( 4 )
	
	Private lGpeConv	:= IsInCallStack( "GPECONV" )
	
	If !lGpeConv
		Private cDataDe		:= Space( 8 )
		Private cDataAte	:= Space( 8 )
		
		Private oTmpTbl  	:= FWTemporaryTable():New( cAliasSM0 )
		Private oMsSelect
	EndIf
	
	If !lGpeConv
		fMontaWiz()
	Else
		fGerEnc()
	EndIf
	
	If !lGpeConv .And. oTmpTbl <> Nil
		oTmpTbl:Delete()
		oTmpTbl := Nil
	EndIf
	
	RestArea( aArea )
Return

/*/{Protheus.doc}fMontaWiz()
- Montagem de wizard para os casos em que a função não é chamada pelo GPECONV.
@Type Static Function
@author:	Jônatas Alves	
@since:		20/06/2017
@param:		lGpeConv - Chamada pelo GPEConv( .T. )
@version 1.0
@return
/*/
Static Function fMontaWiz()

	Local aStruct     	:= {}

	Local cValidFil   	:= fValidFil()		
		
	dbSelectArea( "SM0" )
	SM0->( dbGoTop() )
	
	aAdd( aStruct, { "EMPRESA" , "C", Len( SM0->M0_CODIGO ) , 0 } )
	aAdd( aStruct, { "CODFIL"  , "C", Len( SM0->M0_CODFIL ) , 0 } )
	aAdd( aStruct, { "FILIAL"  , "C", Len( SM0->M0_FILIAL ) , 0 } )
	aAdd( aStruct, { "MARK"    , "C", 02 	                , 0 } )
	
	oTmpTbl:SetFields( aStruct )
	oTmpTbl:AddIndex( "INDEX1", { "EMPRESA", "FILIAL" } )
	oTmpTbl:Create()
	
	If ( cAliasSM0 )->( Eof() )
		nRecSM0 := SM0->( Recno() )
		
		While SM0->( !Eof() )
			If AllTrim( SM0->M0_CODIGO ) == cEmpAnt .And. AllTrim( SM0->M0_CODFIL ) $ cValidFil
				RecLock( cAliasSM0, .T. )
				( cAliasSM0 )->EMPRESA := SM0->M0_CODIGO
				( cAliasSM0 )->CODFIL  := SM0->M0_CODFIL
				( cAliasSM0 )->FILIAL  := SM0->M0_FILIAL
				( cAliasSM0 )->MARK    := cMark
				( cAliasSM0 )->( MsUnLock() )
			EndIf
			
			SM0->( dbSkip() )
		EndDo
		
		SM0->( dbGoTo( nRecSM0 ) )
	EndIf

	// Painel 1 - Tela inicial do Wizard
	// "Geração analítica dos Encargos Empresa"
	// "Gera os lançamentos dos encargos empresa por funcionário"
	// "Geração de Lançamentos dos Encargos Empresa"
	// 		"Assistente para geração dos lançamentos das verbas que correspondem aos encargos empresa, para os acumulados anuais(SRD), de acordo à parametrização informada a seguir."
	//		"Essa opção deve ser utilizada apenas para os períodos em que os cálculos do Gestão de Pessoal foram realizados utilizando o parâmetro MV_ENCINSS com 'N'."
	//		"Uma vez realizado, esse processo não poderá ser desfeito."
	// "ATENÇÃO: Realize backup do ambiente antes de prosseguir."
	oWizard := APWizard():New( OemToAnsi( STR0001 ), OemToAnsi( STR0002 ), OemToAnsi( STR0003 ), OemToAnsi( STR0004 ) + CRLF + OemToAnsi( STR0005 ) + " " + OemToAnsi( STR0006 ) + CRLF + OemToAnsi( STR0007 ), {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )
	
	//Painel 2 - Seleção de Filiais
	oWizard:NewPanel(	OemToAnsi( STR0008 )	,;	// "Seleção de Período e Filiais"
						OemToAnsi( STR0009 )	,;	// "Selecione o período e as filiais para geração dos lançamentos"
						{ || .T. }				,;	// <bBack>
						{ || fVldNxt() }		,;	// <bNext>
						{ || .F. }				,;	// <bFinish>
						.T.						,;	// <.lPanel.>
						{ || GetPerFil() } ) 	 	// <bExecute>
						
	
	//Painel 3 - Acompanhamento do Processo
	oWizard:NewPanel(	OemToAnsi( STR0010 )		,;	// "Gerando lançamentos"
						OemToAnsi( STR0011 )		,;	// "Aguarde o Final do Processamento"
						{ || .F. }					,;	//	<bBack>
						{ || .F. }					,;	//	<bNext>
						{ || .T. }					,;	//	<bFinish>
						.T.							,;	// <.lPanel.>
						{ | lEnd | fProcEnc( @lEnd ) } )// <bExecute>
	
	
	oWizard:Activate( .T., { || .T. }, { || .T. }, { || .T. } )
Return

/*/{Protheus.doc} GetPerFil
Monta tela para seleção de filiais
@Type Static Function
@author Gabriel de Souza Almeida
@since 03/05/2017
@version 1.0
@return Nil
/*/
Static Function GetPerFil()
	
	Local aColumns	:= {}
	
	Local bMarkAll	:= { || RhMkAll( cAliasSM0 , .F., .T. , 'MARK', @cMarkAll ,cMark ) }
	
	Local cMarkAll	:= cMark

	Local oPanel	:= oWizard:oMPanel[ oWizard:nPanel ]

	oGroup1:= TGroup():New(10,10,40,90,OemToAnsi( STR0012 ),oPanel,,,.T.) // "Período De"
	TGet():New(20,015, { | u | If( PCount() == 0, cMesDe, cMesDe := u ) },oGroup1,2, 010, "@!",{|| If(( Empty(cMesDe)) .Or. (Val(cMesDe) <= 12 .and. Val(cMesDe) > 0),.T.,(MsgInfo(OemToAnsi( STR0013 )),.F.))}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMesDe",,,,,,,OemToAnsi( STR0014 )  ) // "Mês inválido!" # "Mês: "
	TGet():New(20,045, { | u | If( PCount() == 0, cAnoDe, cAnoDe := u ) },oGroup1,4, 010, "@!",{|| If(( Empty(cMesDe).and. Empty(cAnoDe) ) .Or. (Val(cAnoDe) >= 1000),(cDataDe := cAnoDe + cMesDe, .T.),(MsgInfo(OemToAnsi( STR0015 )),.F.))}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAnoDe",,,,,,,OemToAnsi( STR0016 )  ) // "Ano inválido!" # "Ano: "
	
	oGroup2:= TGroup():New(10,95,40,175,OemToAnsi( STR0017 ),oPanel,,,.T.) //"Período Até"
	TGet():New(20,100, { | u | If( PCount() == 0, cMesAte, cMesAte := u ) },oGroup2,2, 010, "@!",{|| If(( Empty(cMesAte) ) .Or. (Val(cMesAte) <= 12 .and. Val(cMesAte) > 0),.T.,(MsgInfo(OemToAnsi( STR0013 ))))}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMesAte",,,,,,,OemToAnsi( STR0014 )  ) // "Mês inválido!" # "Mês: "
	TGet():New(20,130, { | u | If( PCount() == 0, cAnoAte, cAnoAte := u ) },oGroup2,4, 010, "@!",{|| If(( Empty(cMesAte).and. Empty(cAnoAte) ) .Or. ((Val(cAnoAte) >= 1000) .and. (StoD(cAnoAte+cMesAte+"01") >= StoD(cAnoDe+cMesDe+"01"))),(cDataAte := cAnoAte + cMesAte, .T.),(MsgInfo(OemToAnsi( STR0018 ) + CRLF + OemToAnsi( STR0019 )),.F.))}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAnoAte",,,,,,,OemToAnsi( STR0016 ) ) // // "Dados inválidos!" # "Mês e ano final não podem ser menores que Mês e ano inicial. Para que todos os registros sejam convertidos, deixe todos os campos em branco." # "Ano: "

	( cAliasSM0 )->( dbGoTop() )
	
	While ( cAliasSM0 )-> (!Eof() )
		If !Empty( ( cAliasSM0 )->MARK )
			cMark := ( cAliasSM0 )->MARK
		EndIf
		( cAliasSM0 )->( dbSkip() )
	EndDo
	
	( cAliasSM0 )->( dbGoTop() )
	
	If oMsSelect == Nil
		aAdd( aColumns, { "MARK"    , ,''        , "@!" } )
		aAdd( aColumns, { "EMPRESA" , ,"Empresa" , "@!" } )
		aAdd( aColumns, { "FILIAL"  , ,"Filial"  , "@!" } )
		
		oMsSelect := MsSelect():New(;	
									cAliasSM0      ,; // Alias do Arquivo de Filtro
									"MARK"         ,; // Campo para controle do mark
									NIL            ,; // Condicao para o Mark
									aColumns       ,; // Array com os Campos para o Browse
									NIL            ,; //
									cMark          ,; // Conteudo a Ser Gravado no campo de controle do Mark
									{60,12,150,285},; // Coordenadas do Objeto
									NIL            ,; //
									NIL            ,; //
									oPanel          ; // Objeto Dialog
									)
		oMsSelect:oBrowse:lAllMark := .T.
		oMsSelect:oBrowse:bAllMark := bMarkAll
	EndIf
Return

/*/{Protheus.doc} RhMkAll
Marca todas as filiais
@author Gabriel de Souza Almeida
@since 03/05/2017
@version 1.0
@return Nil
/*/
Static Function RhMkAll( cAlias, lInverte, lTodos, cCpoCtrl, cMark, cMarkAux )
	
	Local nRecno := ( cAlias )->( Recno() )
	
	( cAlias )->( dbGoTop() )
	While ( cAlias )->( !Eof() )  
		RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark, {} )
		( cAlias )->( dbSkip() )
	End While
	( cAlias )->( MsGoTo( nRecno ) )
	
	If cMark == cMarkAux
		cMark := ""
	Else
		cMark := cMarkAux
	EndIf
Return

/*/{Protheus.doc}fProcEnc
Chama a função de execução principal
@author Jônatas Alves
@since 24/06/2017
@version 1.0
@return Nil
/*/
Static Function fProcEnc( lEnd )
	
	Private oProcess
	
	// Executa o processamento dos arquivos
	oProcess:=	MsNewProcess():New( { | lEnd | fGerEnc( oProcess ) }, OemToAnsi( STR0020 ), OemToAnsi( STR0020 ) )     // "Efetuando a geração dos lançamentos..." # "Efetuando a geração dos lançamentos..."
	oProcess:Activate()
Return

/*/{Protheus.doc}fVldNxt()
Valida informações antes de prosseguir geração
@author Jônatas Alves
@since 29/06/2017
@version 1.0
@return lRet - .T. prossegue com rotina
/*/
Static Function fVldNxt()

	Local lRet := .T.
	
	Begin Sequence
	
		If !( lRet := !Empty( cDataDe ) .And. !Empty( cDataAte ) )
			MsgAlert( OemToAnsi( STR0021 ) ) // "Preencha o período De/Ate para geração dos encargos." 
			Break
		EndIf
		
		If !( lRet := MsgNoYes( OemToAnsi( STR0022 ) + CRLF + OemToAnsi( STR0023 ) ) ) // "Esse procedimento não poderá ser desfeito. Prossiga apenas caso tenha realizado backup do seu ambiente." # "Deseja continuar?" 
			 Break
		EndIf
	
	End Sequence
	
Return( lRet )
/*/{Protheus.doc}fGerEnc()
- Cálculo e geração dos encargos analíticos.
@Type Static Function
@author:	Jônatas Alves	
@since:		21/06/2017
@param:
@version 1.0
@return
/*/
Static Function fGerEnc()

	Local aPerCal		:= {}
	Local cPerCal		:= cDataDe
	
	While cPerCal <= cDataAte
		aAdd( aPerCal, cPerCal )
		cPerCal := SomaMesAno( cPerCal )
	EndDo
	
	If !lGpeConv
		oProcess:SetRegua1( Len( aPerCal ) )
	EndIf

	//---------------------------------------------------------
	// Executa query de seleção de registros e gera lançamentos
	//---------------------------------------------------------
	fQryEnc()
Return

/*/{Protheus.doc} fGetFil
Pega filiais selecionadas
@author Gabriel de Souza Almeida
@since 03/05/2017
@version 1.0
@return Nil
/*/
Static Function fGetFil()

	Local aRet  := {}
	
	dbSelectArea( cAliasSM0 )
	( cAliasSM0 )->( dbGotop() )
	
	While ( cAliasSM0 )->( !Eof() )
		If !( Empty( ( cAliasSM0 )->MARK ) )
			aAdd( aRet , { ( cAliasSM0 )->EMPRESA, ( cAliasSM0 )->CODFIL, AllTrim( ( cAliasSM0 )->FILIAL ) } )
		EndIf
		
		( cAliasSM0 )->( dbSkip() )
	EndDo
Return aRet

/*/{Protheus.doc}fQryEnc()
- Cálculo e geração dos encargos analíticos.
@Type Static Function
@author:	Jônatas Alves	
@since:		21/06/2017
@param:
@version 1.0
@return
/*/
Static Function fQryEnc()
	
	//-------------------
	// Variáveis uso geral
	//-------------------
	Local aFil			:= {}
	Local aPerFOL		:= ""
	Local aPerAUT		:= ""

	Local cOrdSRD		:= ""
	Local cPdSalCon		:= ""
	Local cPdProAut		:= ""
	Local cPdBseAut		:= ""
	Local cPdBseSrvP	:= ""
	Local cRotQry		:= ""
	Local cFilProc		:= ""
	Local cFilMat		:= ""
	Local cOldFil		:= ""
	Local cDesFol		:= GetMvRH( "MV_DESFOL", , "" ) // O período de desoneração obrigou o uso do MV_ENCINSS com 'S', por isso será desprezado
	Local cDesFolQ		:= cDesFol
	Local cOneFol		:= ""
	Local cOneFolQ		:= ""
	Local cRotFOL		:= "FOL"
	Local cRotAUT		:= "AUT"
	Local cRot132		:= "132"
	Local cNameDB		:= Upper( TcGetDb() )
	Local cProcPer		:= ""
	local cProPerS		:= ""
	
	Local lUltSemF	:= .F.
	Local lUltSemA	:= .F.

	Local nOrdSRD		:= RetOrder( "SRD", "RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+DTOS(RD_DTREF)" )
	Local nFil			:= 0
	Local nPosSem		:= 0
	Local nPosFil		:= 0
	
	//-------------------
	//Variáveis query SRD
	//-------------------
	Local cFilSRD		:= ""
	Local cSelSRD		:= ""
	Local cSelSalCon	:= ""
	Local cSelProAut	:= ""
	Local cSelBseAut	:= ""
	Local cSelBseSrv	:= ""
	Local cSelPIS		:= ""
	Local cSelCusto		:= ""
	Local cSumPD		:= ""
	Local cJoinRDCTT	:= ""
	Local cJoinRDRV		:= ""
	Local cGrpSRD		:= ""
	
	Private aCodFol		:= {}
	Private aInssEmp	:= {}
	
	Private cAliasQry	:= GetNextAlias()
	Private cPeriodo	:= ""
	Private cSemana		:= ""
	
	Private lItemClVl	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "1*3"
	Private lResExt		:= .F.
	
	//-----------------
	// Filtros p/ query
	//-----------------
	If Empty( cDesFolQ )
		cDesFolQ := SomaMesAno( cDataAte )
	Else
		cDesFolQ := SomaMesAno( cDesFolQ )
	EndIf
	
	cDesFolQ := "% '" + cDesFolQ + "' %"
	
	cFilRCA	:= xFilial( "RCA" )
	nRCAOrd	:= RetOrder( "RCA" , "RCA_FILIAL+RCA_MNEMON" )
	dbSelectArea( "RCA" )
	dbSetOrder( nRCAOrd )

	If RCA->( dbSeek( cFilRCA + "P_FDESFOL", .F. ) ) // Foi utilizado mnemônico ao invés de parãmetro do SX6 para o fim da desoneração
		cOneFol	:= RCA->( If( Empty( RCA_CONTEU ) .Or. AllTrim( RCA_CONTEU ) == 'GetValType("C")', "", RCA_CONTEU ) )
		cOneFolQ := cOneFol
	EndIf
	
	If Empty( cOneFolQ )
		cOneFolQ := SubMesAno( cDataDe )
	Else
		cOneFolQ := SubMesAno( cOneFolQ )
	EndIf
	
	cOneFolQ := "% '" + cOneFolQ + "' %"
	
	If !lGpeConv
		aFil	:= fGetFil()
	Else
		aAdd( aFil, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
	EndIf
	
	For nFil := 1 To Len( aFil )
		aFil[ nFil, 2 ] := RTrim( aFil[ nFil, 2 ] )
		cFilSRD += "'" + aFil[ nFil, 2 ] + "', "
	Next
	
	cFilSRD := "% " + Left( cFilSRD, Len( cFilSRD ) - 2 ) + " %"
	
	cRotQry += "% '" + cRotFOL + "', '" + cRotAUT + "', '" + cRot132 + "' %"
	
	If cNameDB $ "INFORMIX"
		cRGDtGerar	:= " NVL( SRG.RG_DTGERAR, '' ) AS RG_DTGERAR, "
	Else
		cRGDtGerar	:= " COALESCE( SRG.RG_DTGERAR, '' ) AS RG_DTGERAR, "	
	EndIf
	
	//------------------------------------------------------
	// Define campos do Select de acordo a seção e movimento
	//------------------------------------------------------	
	cSelSRD		:= "% SRD.RD_PROCES, SRD.RD_ROTEIR, SRD.RD_PERIODO, SRD.RD_SEMANA, SRD.RD_FILIAL, SRD.RD_CC, SRD.RD_ITEM, SRD.RD_CLVL, SRD.RD_MAT, CTT.CTT_PERFPA, CTT.CTT_PEREMP, CTT_PERCAC, SRD.RD_DTREF, SRD.RD_DATPGT, " + cRGDtGerar
	
	cSelSalCon	:= cSelSRD + " SUM( SRD.RD_VALOR ) AS RD_VALOR, 'SALCON' AS BSENCARG %"
	cSelProAut	:= cSelSRD + " SUM( SRD.RD_VALOR ) AS RD_VALOR, 'PROAUT' AS BSENCARG %"
	cSelBseAut	:= cSelSRD + " SUM( SRD.RD_VALOR ) AS RD_VALOR, 'BSEAUT' AS BSENCARG %"
	cSelBseSrv	:= cSelSRD + " SUM( SRD.RD_VALOR ) AS RD_VALOR, 'SRVPRE' AS BSENCARG %"
	
	cSumPD		:= " SUM( SRD.RD_VALOR * ( CASE WHEN RV_TIPOCOD IN ( '1', '3' ) THEN 1 ELSE -1 END ) ) AS RD_VALOR, "
	cSelPIS		:= cSelSRD + cSumPD + " 'BSEPIS' AS BSENCARG %"
	cSelCusto	:= cSelSRD + cSumPD + " 'BSECUS' AS BSENCARG %"
	
	cGrpSRD		:= "% RD_PROCES, RD_PERIODO, RD_SEMANA, RD_ROTEIR, RD_FILIAL, RD_MAT, RD_CC, CTT_PERFPA, CTT_PEREMP, CTT_PERCAC, RD_ITEM, RD_CLVL, RD_DTREF, RD_DATPGT, RG_DTGERAR %"
	cOrdSRD		:= "% RD_FILIAL, RD_PROCES, RD_PERIODO, RD_SEMANA, RD_ROTEIR, RD_MAT, RD_CC, CTT_PERFPA, CTT_PEREMP, CTT_PERCAC, RD_ITEM, RD_CLVL, RD_DTREF, RD_DATPGT, RG_DTGERAR %"

	//------------------------
	// Cláusulas Join da query
	//------------------------
	cJoinRDCTT	:= "% " + FWJoinFilial( "SRD", "CTT" ) + " %"
	cJoinRDRV	:= "% " + FWJoinFilial( "SRD", "SRV" ) + " %"
		
	//----------------------------------
	// Id. de cálculo filtrados na query
	//----------------------------------
	cPdSalCon :=	"% '0013', '0019', '0014', '0020', '0338', '0399' %"
	cPdProAut :=	"% '0217', '0218', '1413' %"
	cPdBseAut :=	"% '0221', '1384' %"
	cPdBseSrvP :=	"% '0350', '0353' %"
	
	dbSelectArea( "SRD" )
	dbSetOrder( nOrdSRD )
	
	//-----------------------------
	// Seleção das bases de cálculo
	//-----------------------------
	BeginSql alias cAliasQry
		Column RD_DATPGT As Date
		Column RD_DTREF As Date
		Column RG_DTGERAR As Date
		SELECT %exp:Upper( cSelSalCon )%
		FROM %table:SRD% SRD
		INNER JOIN %table:SRA% SRA
		ON 	    	SRD.RD_FILIAL	= SRA.RA_FILIAL
				AND	SRD.RD_MAT		= SRA.RA_MAT
				AND SRA.%notDel%
		INNER JOIN %table:CTT% CTT
		ON			%exp:cJoinRDCTT%
				AND	SRA.RA_CC		= CTT.CTT_CUSTO
				AND CTT.%notDel%
		INNER JOIN %table:SRV% SRV
		ON			%exp:cJoinRDRV%
				AND	SRV.RV_CODFOL IN ( %exp:Upper( cPdSalCon )% )
				AND SRV.RV_COD = SRD.RD_PD
				AND SRV.%notDel%
		LEFT OUTER JOIN %table:SRG% SRG
		ON 	    	SRD.RD_FILIAL	= SRG.RG_FILIAL
				AND	SRD.RD_MAT		= SRG.RG_MAT
				AND SRD.RD_PERIODO	= SRG.RG_PERIODO
				AND	SRG.RG_RESCDIS	= %exp:( '2' )%
				AND SRG.%notDel%
		WHERE	SRD.RD_PERIODO	BETWEEN	%exp:Upper( cDataDe )% AND %exp:Upper( cDataAte )%
				AND SRD.RD_PERIODO < %exp:( cDesFolQ )%
				AND SRD.RD_PERIODO > %exp:( cOneFolQ )%
				AND SRD.RD_FILIAL IN ( %exp:Upper( cFilSRD )% )
				AND SRD.RD_ROTEIR IN ( %exp:Upper( cRotQry )% )
				AND SRD.%notDel%
		GROUP BY %exp:Upper( cGrpSRD )%
		
		UNION
		
		SELECT %exp:Upper( cSelProAut )%
		FROM %table:SRD% SRD
		INNER JOIN %table:SRA% SRA
		ON 	    	SRD.RD_FILIAL	= SRA.RA_FILIAL
				AND	SRD.RD_MAT		= SRA.RA_MAT
				AND SRA.%notDel%
		INNER JOIN %table:CTT% CTT
		ON			%exp:cJoinRDCTT%
				AND	SRA.RA_CC		= CTT.CTT_CUSTO
				AND CTT.%notDel%
		INNER JOIN %table:SRV% SRV
		ON			%exp:cJoinRDRV%
				AND	SRV.RV_CODFOL IN ( %exp:Upper( cPdProAut )% )
				AND SRV.RV_COD = SRD.RD_PD
				AND SRV.%notDel%
		LEFT OUTER JOIN %table:SRG% SRG
		ON 	    	SRD.RD_FILIAL	= SRG.RG_FILIAL
				AND	SRD.RD_MAT		= SRG.RG_MAT
				AND SRD.RD_PERIODO	= SRG.RG_PERIODO
				AND	SRG.RG_RESCDIS	= %exp:( '2' )%
				AND SRG.%notDel%
		WHERE	SRD.RD_PERIODO	BETWEEN	%exp:Upper( cDataDe )% AND %exp:Upper( cDataAte )%
				AND SRD.RD_PERIODO < %exp:( cDesFolQ )%
				AND SRD.RD_PERIODO > %exp:( cOneFolQ )%
				AND SRD.RD_FILIAL IN ( %exp:Upper( cFilSRD )% )
				AND SRD.RD_ROTEIR IN ( %exp:Upper( cRotQry )% )
				AND SRD.%notDel%
		GROUP BY %exp:Upper( cGrpSRD )%
		
		UNION
		
		SELECT %exp:Upper( cSelBseAut )%
		FROM %table:SRD% SRD
		INNER JOIN %table:SRA% SRA
		ON 	    	SRD.RD_FILIAL	= SRA.RA_FILIAL
				AND	SRD.RD_MAT		= SRA.RA_MAT
				AND SRA.%notDel%
		INNER JOIN %table:CTT% CTT
		ON			%exp:cJoinRDCTT%
				AND	SRA.RA_CC		= CTT.CTT_CUSTO
				AND CTT.%notDel%
		INNER JOIN %table:SRV% SRV
		ON			%exp:cJoinRDRV%
				AND	SRV.RV_CODFOL IN ( %exp:Upper( cPdBseAut )% )
				AND SRV.RV_COD = SRD.RD_PD
				AND SRV.%notDel%
		LEFT OUTER JOIN %table:SRG% SRG
		ON 	    	SRD.RD_FILIAL	= SRG.RG_FILIAL
				AND	SRD.RD_MAT		= SRG.RG_MAT
				AND SRD.RD_PERIODO	= SRG.RG_PERIODO
				AND	SRG.RG_RESCDIS	= %exp:( '2' )%
				AND SRG.%notDel%
		WHERE	SRD.RD_PERIODO	BETWEEN	%exp:Upper( cDataDe )% AND %exp:Upper( cDataAte )%
				AND SRD.RD_PERIODO < %exp:( cDesFolQ )%
				AND SRD.RD_PERIODO > %exp:( cOneFolQ )%
				AND SRD.RD_FILIAL IN ( %exp:Upper( cFilSRD )% )
				AND SRD.RD_ROTEIR IN ( %exp:Upper( cRotQry )% )
				AND SRD.%notDel%
		GROUP BY %exp:Upper( cGrpSRD )%
		
		UNION
		
		SELECT %exp:Upper( cSelBseSrv )%
		FROM %table:SRD% SRD
		INNER JOIN %table:SRA% SRA
		ON 	    	SRD.RD_FILIAL	= SRA.RA_FILIAL
				AND	SRD.RD_MAT		= SRA.RA_MAT
				AND SRA.%notDel%
		INNER JOIN %table:CTT% CTT
		ON			%exp:cJoinRDCTT%
				AND	SRA.RA_CC		= CTT.CTT_CUSTO
				AND CTT.%notDel%
		INNER JOIN %table:SRV% SRV
		ON			%exp:cJoinRDRV%
				AND	SRV.RV_CODFOL IN ( %exp:Upper( cPdBseSrvP )% )
				AND SRV.RV_COD = SRD.RD_PD
				AND SRV.%notDel%
		LEFT OUTER JOIN %table:SRG% SRG
		ON 	    	SRD.RD_FILIAL	= SRG.RG_FILIAL
				AND	SRD.RD_MAT		= SRG.RG_MAT
				AND SRD.RD_PERIODO	= SRG.RG_PERIODO
				AND	SRG.RG_RESCDIS	= %exp:( '2' )%
				AND SRG.%notDel%
		WHERE	SRD.RD_PERIODO	BETWEEN	%exp:Upper( cDataDe )% AND %exp:Upper( cDataAte )%
				AND SRD.RD_PERIODO < %exp:( cDesFolQ )%
				AND SRD.RD_PERIODO > %exp:( cOneFolQ )%
				AND SRD.RD_FILIAL IN ( %exp:Upper( cFilSRD )% )
				AND SRD.RD_ROTEIR IN ( %exp:Upper( cRotQry )% )
				AND SRD.%notDel%
		GROUP BY %exp:Upper( cGrpSRD )%
		
		UNION
		
		SELECT %exp:Upper( cSelPIS )%
		FROM %table:SRD% SRD
		INNER JOIN %table:SRA% SRA
		ON 	    	SRD.RD_FILIAL	= SRA.RA_FILIAL
				AND	SRD.RD_MAT		= SRA.RA_MAT
				AND SRA.%notDel%
		INNER JOIN %table:CTT% CTT
		ON			%exp:cJoinRDCTT%
				AND	SRA.RA_CC		= CTT.CTT_CUSTO
				AND CTT.%notDel%
		INNER JOIN %table:SRV% SRV
		ON			%exp:cJoinRDRV%
				AND	SRV.RV_PIS = %exp:Upper( 'S' )%
				AND SRV.RV_COD = SRD.RD_PD
				AND SRV.%notDel%
		LEFT OUTER JOIN %table:SRG% SRG
		ON 	    	SRD.RD_FILIAL	= SRG.RG_FILIAL
				AND	SRD.RD_MAT		= SRG.RG_MAT
				AND SRD.RD_PERIODO	= SRG.RG_PERIODO
				AND	SRG.RG_RESCDIS	= %exp:( '2' )%
				AND SRG.%notDel%
		WHERE	SRD.RD_PERIODO	BETWEEN	%exp:Upper( cDataDe )% AND %exp:Upper( cDataAte )%
				AND SRD.RD_PERIODO < %exp:( cDesFolQ )%
				AND SRD.RD_PERIODO > %exp:( cOneFolQ )%
				AND SRD.RD_FILIAL IN ( %exp:Upper( cFilSRD )% )
				AND SRD.RD_ROTEIR IN ( %exp:Upper( cRotQry )% )
				AND SRD.%notDel%
		GROUP BY %exp:Upper( cGrpSRD )%
		
		UNION
		
		SELECT %exp:Upper( cSelCusto )%
		FROM %table:SRD% SRD
		INNER JOIN %table:SRA% SRA
		ON 	    	SRD.RD_FILIAL	= SRA.RA_FILIAL
				AND	SRD.RD_MAT		= SRA.RA_MAT
				AND SRA.%notDel%
		INNER JOIN %table:CTT% CTT
		ON			%exp:cJoinRDCTT%
				AND	SRA.RA_CC		= CTT.CTT_CUSTO
				AND CTT.%notDel%
		INNER JOIN %table:SRV% SRV
		ON			%exp:cJoinRDRV%
				AND	SRV.RV_CUSTO = %exp:Upper( 'S' )%
				AND SRV.RV_COD = SRD.RD_PD
				AND SRV.%notDel%
		LEFT OUTER JOIN %table:SRG% SRG
		ON 	    	SRD.RD_FILIAL	= SRG.RG_FILIAL
				AND	SRD.RD_MAT		= SRG.RG_MAT
				AND SRD.RD_PERIODO	= SRG.RG_PERIODO
				AND	SRG.RG_RESCDIS	= %exp:( '2' )%
				AND SRG.%notDel%
		WHERE	SRD.RD_PERIODO	BETWEEN	%exp:Upper( cDataDe )% AND %exp:Upper( cDataAte )%
				AND SRD.RD_PERIODO < %exp:( cDesFolQ )%
				AND SRD.RD_PERIODO > %exp:( cOneFolQ )%
				AND SRD.RD_FILIAL IN ( %exp:Upper( cFilSRD )% )
				AND SRD.RD_ROTEIR IN ( %exp:Upper( cRotQry )% )
				AND SRD.%notDel%
		GROUP BY %exp:Upper( cGrpSRD )%
		ORDER BY %exp:Upper( cOrdSRD )%
	EndSql
	
	While ( cAliasQry )->( !Eof() )

		dbSelectArea( "SRA" )
		If cFilMat # ( cAliasQry )->( RD_FILIAL + RD_MAT )
			cOldFil:= SRA->RA_FILIAL
			cFilMat := ( cAliasQry )->( RD_FILIAL + RD_MAT )
			SRA->( dbSeek( cFilMat, .F. ) )
			
			lResExt := ( SRA->RA_RESEXT == "1" )
		EndIf
		
		dbSelectArea( cAliasQry )
		
		If cProPerS # ( cAliasQry )->( RD_FILIAL + RD_PROCES + RD_PERIODO + RD_SEMANA )

			cProcesso	:= ( cAliasQry )->RD_PROCES
			cPeriodo	:= ( cAliasQry )->RD_PERIODO
			cSemana		:= ( cAliasQry )->RD_SEMANA
			
			If cProcPer # ( cAliasQry )->( RD_FILIAL + RD_PROCES + RD_PERIODO )
				
				If cFilProc	# ( cAliasQry )->RD_FILIAL
					
					cFilProc	:= ( cAliasQry )->RD_FILIAL
					nPosFil 	:= aScan( aFil, { | x | x[ 2 ] == RTrim( cFilProc ) } )
					If !lGpeConv
						oProcess:IncRegua1( OemToAnsi( STR0024 ) + cFilProc + " " + aFil[ nPosFil, 3 ] ) // "Filial: "
					EndIf

					// Reset das statics
					RestXCIMP()
					
					If Empty( aCodFol ) .Or. ( xFilial( "SRV", cFilProc ) # xFilial( "SRV", cOldFil ) )
						RstaCodFol()
						
						aCodFol := {}
						Fp_CodFol( @aCodFol , cFilProc, .F., .F. )
					EndIf
				EndIf
				
				fCarPeriodo( cPeriodo , cRotFOL, @aPerFOL, @lUltSemF, @nPosSem, .F., cFilProc )
				fCarPeriodo( cPeriodo , cRotAUT, @aPerAUT, @lUltSemA, @nPosSem, .F., cFilProc )
				
				If !lGpeConv
					oProcess:IncRegua2( OemToAnsi( STR0025 ) + cProcesso + "  " + OemToAnsi( STR0014 ) + Right( cPeriodo, 2 ) + "  " + OemToAnsi( STR0016 ) + Left( cPeriodo, 4 ) ) // "Processo: " # "Mês: " # "Ano: "
				EndIf
				
				cProcPer := ( cAliasQry )->( RD_FILIAL + RD_PROCES + RD_PERIODO )
			EndIf
			
			cProPerS := ( cAliasQry )->( RD_FILIAL + RD_PROCES + RD_PERIODO + RD_SEMANA )
		EndIf
		
		dbSelectArea( cAliasQry )

		If SRA->RA_TIPOPGT == "S"
			If ( cAliasQry )->RD_ROTEIR == cRotAUT
				If Empty( aPerAUT ) .Or. cSemana # aPerAUT[ Len( aPerAUT ), 2 ]
					( cAliasQry )->( dbSkip() )
					Loop
				EndIf
			ElseIf ( cAliasQry )->RD_ROTEIR == cRotFOL
				If Empty( aPerFOL ) .Or. cSemana # aPerFOL[ Len( aPerFOL ), 2 ]
					( cAliasQry )->( dbSkip() )
					Loop
				EndIf
			EndIf
		EndIf
		
		fCalEncFun()

		( cAliasQry )->( dbSkip() )
	EndDo
	
	If Select( cAliasQry ) > 0
		( cAliasQry )->( dbCloseArea() )
	EndIf

Return

/*/{Protheus.doc}fRetAci( nPercAcTrab, lPercSRA )
- Retorna percentuais de Acid. Trab e Terc.
@Type Static Function
@author:	Jônatas Alves	
@since:		21/06/2017
@param:
@version 1.0
@return
/*/
Static Function fRetAci( nPercAcTrab, lPercSRA )

Local aArea := GetArea()

lPercSRA := .F.

//--------------------------------------------
// Garante os percentuais definidos na empresa
//--------------------------------------------
nPercAcTrab := If( SRA->RA_TPCONTR $ " *1", aInssEmp[ 3, 1 ], aInssEmp[ 3, 2 ] )

//---------------------------------------------------
// Verifica o % de Acidente e Terceiros do SRA ou CTT
//---------------------------------------------------
If SRA->RA_PERCSAT > 0
	nPercAcTrab := SRA->RA_PERCSAT / 100
	lPercSRA    := .T.
Else
	If ( cAliasQry )->CTT_PERCAC > 0
		nPercAcTrab := ( cAliasQry )->CTT_PERCAC / 100
	EndIf
EndIf

RestArea( aArea )

Return Nil

/*/{Protheus.doc}fCalEncFun()
- Calcula encargos empresa dos funcionários
@Type Static Function
@author:	Jônatas Alves	
@since:		21/06/2017
@param:
@version 1.0
@return
/*/
Static Function fCalEncFun()

	Local nValBInss1 	:= 0.00
	Local nValBInss2 	:= 0.00
	Local cTpc        	:= ""         
	Local nPercAcTrab 	:= 0.00
	Local nPercPro    	:= 0.00
	Local nPercAut    	:= 0.00
	Local nPercEmp    	:= 0.00
	Local nPercFPAS   	:= 0.00
	Local nDed        	:= 0.00
	Local nBasePis    	:= 0.00
	Local nBseProAut  	:= 0.00
	Local lPercSRA    	:= .F.
	Local nPerc		  	:= 0
	Local nValCus	  	:= 0.00
	Local nIdEnc	  	:= 0
	Local nBaseCalc		:= 0	
	
	Local aArea		  	:= GetArea()
	
	Private aInssEmp
	Private aGPSPer
	
	Static cFilInss 
	Static aInssEmpSt
	Static aGPSPerSt
	
	// Verifica tipo de contrato
	If SRA->RA_TPCONTR $ " *1"
		cTpC  := "1"
	Else	
		cTpC  := "2"
	EndIf
	
	// Carrega Array de Encargos da Empressa    
	If aInssEmpSt == Nil .or. Len( aInssEmpSt ) == 0 .Or. cFilInss # SRA->RA_FILIAL
		// Resgata os percentuais de terceiros armazenados na tabela S035
		fGPSVal( SRA->RA_FILIAL, cPeriodo, @aGPSPerSt, cTpC )
	
		cFilInss := SRA->RA_FILIAL
		If !fInssEmp( SRA->RA_FILIAL, @aInssEmpSt, , cPeriodo )
			Return                            
		EndIf                                 
	EndIf
	
	aInssEmp := aInssEmpSt
	aGPSPer  := aGPSPerSt
	
	lRescDis := !Empty( ( cAliasQry )->RG_DTGERAR )
	
	Do Case
		Case ( cAliasQry )->BSENCARG == "SALCON"
			nBaseCalc	:= ( cAliasQry )->RD_VALOR
		Case ( cAliasQry )->BSENCARG == "PROAUT"
			nBseProAut	:= ( cAliasQry )->RD_VALOR
		Case ( cAliasQry )->BSENCARG == "BSEAUT"
			nValBInss1	:= ( cAliasQry )->RD_VALOR
		Case ( cAliasQry )->BSENCARG == "SRVPRE"
			nValBInss2	:= ( cAliasQry )->RD_VALOR
		Case ( cAliasQry )->BSENCARG == "BSEPIS"
			nBasePis	:= ( cAliasQry )->RD_VALOR
		Case ( cAliasQry )->BSENCARG == "BSECUS"
			nValCus		:= ( cAliasQry )->RD_VALOR
	End Case
	
	If nBaseCalc > 0 .And. !( SRA->RA_CATFUNC $ "A*P" )
	
		If lRescDis
		   nIdEnc:= 945 // Percentual Acidente Trabalho Dissidio
		Else 
			nIdEnc:= 150 // Percentual Acidente Trabalho
		EndIf
	
		fRetAci( @nPercAcTrab )
		fGrvSRD( aCodfol[ nIdEnc, 1 ], Round( nBaseCalc * nPercAcTrab, 2 ) ) // Acidente Trabalho
	
		nPercFPAS	:= ( cAliasQry )->CTT_PERFPA / 100
		nPercEmp    := ( cAliasQry )->CTT_PEREMP / 100
		
		If nPercFPAS > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deducao do percentual pago por convenios                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDed := 0
			For nPerc = 9 TO 19
				nDed += aInssEmp[ nPerc, Val( cTpc ) ]
			Next
			
			nDed += aInssEmp[ 22, Val( cTpc ) ]
			nDed += aInssEmp[ 23, Val( cTpc) ]
			nDed += fP15Terc( SRA->RA_CC, aGPSPer, "*" ) //Deduzir o % de terceiros do parametro 15
		
			nPercFPAS -= nDed
		EndIf
		
		//-- Calcular Inss Empresa
		If !( SRA->RA_CATFUNC $ "A*P" ) 
		
			If lRescDis 
			   nIdEnc:= 943 // INSS Empresa Dissidio
			Else 
				nIdEnc:= 148 // INSS EMPRESA
			EndIf
	    
			fGrvSRD( aCodfol[ nIdEnc, 1 ], Round( nBaseCalc * If( nPercEmp > 0, nPercEmp, aInssEmp[ 1, Val( cTpc ) ] ), 2 ) )   // Empresa	    	
		    
	    	If !lResExt
	    		If lRescDis				
		    		fGrvSRD( aCodFol[ 944, 1 ], Round( nBaseCalc * If ( nPercFPAS > 0, nPercFPAS ,aInssemp[ 2, Val( cTpc ) ] ), 2 ) )   // Terceiros
					fGrvSRD( aCodFol[ 959, 1 ], Round( nBaseCalc * ( aInssemp[ 09, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 959,1 ] ) ), 2 ) )  // Sal.Educ.
					fGrvSRD( aCodFol[ 946, 1 ], Round( nBaseCalc * ( aInssemp[ 10, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 946,1 ] ) ), 2 ) )  // Incra
					fGrvSRD( aCodFol[ 947, 1 ], Round( nBaseCalc * ( aInssemp[ 11, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 947,1 ] ) ), 2 ) )  // Senai
					fGrvSRD( aCodFol[ 948, 1 ], Round( nBaseCalc * ( aInssemp[ 12, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 948,1 ] ) ), 2 ) )  // Sesi
					fGrvSRD( aCodFol[ 949, 1 ], Round( nBaseCalc * ( aInssemp[ 13, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 949,1 ] ) ), 2 ) )  // Senac
					fGrvSRD( aCodFol[ 950, 1 ], Round( nBaseCalc * ( aInssemp[ 14, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 950,1 ] ) ), 2 ) )  // Sesc
					fGrvSRD( aCodFol[ 951, 1 ], Round( nBaseCalc * ( aInssemp[ 15, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 951,1 ] ) ), 2 ) )  // Sebrae
					fGrvSRD( aCodFol[ 952, 1 ], Round( nBaseCalc * ( aInssemp[ 16, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 952,1 ] ) ), 2 ) )  // Dpc
					fGrvSRD( aCodFol[ 953, 1 ], Round( nBaseCalc * ( aInssemp[ 17, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 953,1 ] ) ), 2 ) )  // Faer
					fGrvSRD( aCodFol[ 954, 1 ], Round( nBaseCalc * ( aInssemp[ 18, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 954,1 ] ) ), 2 ) )  // Senab
					fGrvSRD( aCodFol[ 955, 1 ], Round( nBaseCalc * ( aInssemp[ 19, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 955,1 ] ) ), 2 ) )  // Seconc
					fGrvSRD( aCodFol[ 956, 1 ], Round( nBaseCalc * ( aInssemp[ 22, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 956,1 ] ) ), 2 ) )  // Sest
					fGrvSRD( aCodFol[ 957, 1 ], Round( nBaseCalc * ( aInssemp[ 23, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 957,1 ] ) ), 2 ) )  // Senat
					fGrvSRD( aCodFol[ 958, 1 ], Round( nBaseCalc * ( aInssemp[ 26, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 958,1 ] ) ), 2 ) )  // Sescoop		
					nValSENAI:= Round( nBaseCalc * ( aInssemp[ 11, Val( cTpc ) ] ), 2 )
					If Len( aCodFol ) > 1395
						fGrvSRD( aCodFol[ 1396, 1 ], Round( nValSENAI * ( aInssemp[ 30, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 1396, 1 ] ) ), 2 ) )	// Senai 500 funcionarios
					Endif
				Else
					fGrvSRD( aCodFol[ 149, 1 ], Round( nBaseCalc * If( nPercFPAS > 0, nPercFPAS, aInssEmp[ 2, Val( cTpc ) ] ), 2 ) )   // Terceiros
					fGrvSRD( aCodFol[ 204, 1 ], Round( nBaseCalc * ( aInssemp[ 09, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 204, 1 ] ) ), 2 ) )  // Sal.Educ.
					fGrvSRD( aCodFol[ 184, 1 ], Round( nBaseCalc * ( aInssemp[ 10, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 184, 1 ] ) ), 2 ) )  // Incra
					fGrvSRD( aCodFol[ 185, 1 ], Round( nBaseCalc * ( aInssemp[ 11, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 185, 1 ] ) ), 2 ) )  // Senai
					fGrvSRD( aCodFol[ 186, 1 ], Round( nBaseCalc * ( aInssemp[ 12, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 186, 1 ] ) ), 2 ) )  // Sesi
					fGrvSRD( aCodFol[ 187, 1 ], Round( nBaseCalc * ( aInssemp[ 13, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 187, 1 ] ) ), 2 ) )  // Senac
					fGrvSRD( aCodFol[ 188, 1 ], Round( nBaseCalc * ( aInssemp[ 14, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 188, 1 ] ) ), 2 ) )  // Sesc
					fGrvSRD( aCodFol[ 189, 1 ], Round( nBaseCalc * ( aInssemp[ 15, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 189, 1 ] ) ), 2 ) )  // Sebrae
					fGrvSRD( aCodFol[ 190, 1 ], Round( nBaseCalc * ( aInssemp[ 16, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 190, 1 ] ) ), 2 ) )  // Dpc
					fGrvSRD( aCodFol[ 191, 1 ], Round( nBaseCalc * ( aInssemp[ 17, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 191, 1 ] ) ), 2 ) )  // Faer
					fGrvSRD( aCodFol[ 192, 1 ], Round( nBaseCalc * ( aInssemp[ 18, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 192, 1 ] ) ), 2 ) )  // Senab
					fGrvSRD( aCodFol[ 193, 1 ], Round( nBaseCalc * ( aInssemp[ 19, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 193, 1 ] ) ), 2 ) )  // Seconc
					fGrvSRD( aCodFol[ 200, 1 ], Round( nBaseCalc * ( aInssemp[ 22, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 200, 1 ] ) ), 2 ) )  // Sest
					fGrvSRD( aCodFol[ 201, 1 ], Round( nBaseCalc * ( aInssemp[ 23, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 201, 1 ] ) ), 2 ) )  // Senat
					fGrvSRD( aCodFol[ 782, 1 ], Round( nBaseCalc * ( aInssemp[ 26, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 782, 1 ] ) ), 2 ) )  // Sescoop
 
					nValSENAI:= Round( nBaseCalc * ( aInssemp[ 11, Val( cTpc ) ] ), 2 )
					If Len( aCodFol ) > 1394
						fGrvSRD( aCodFol[ 1395, 1 ], Round( nValSENAI * ( aInssemp[ 30, Val( cTpc ) ] + fP15Terc( SRA->RA_CC, aGPSPer, aCodFol[ 1395, 1 ] ) ), 2 ) )	// Senai 500 funcionarios
					Endif
				EndIf	
			EndIf	
		EndIf
	Else
		//--Inss s/Prolabore e Autonomo
		fRetAci( @nPercAcTrab, @lPercSRA ) // Calcula valor do Acidente de Trabalho (Aposent. Especial)
		If nPercAcTrab > 0 .And. lPercSRA .And. nBseProAut > 0
		    fGrvSRD( aCodfol[ 150, 1 ], Round( nBseProAut * nPercAcTrab, 2 ) ) // Acidente Trabalho
		EndIf
	
		// Considera a ocorrência exclusiva do identificador 221 ou 1384 no movimento
		If ( aCodFol[ 221, 1 ] # Space( 3 ) .Or. aCodFol[ 1384, 1 ] # Space( 3 ) ) .And. !lResExt .And. nValBInss1 > 0
			If SRA->RA_CATEG $ "17|18"
				nPercPro := PosSrv( aCodFol[ 1384, 1 ], SRA->RA_FILIAL, "RV_PERC" ) / 100
				If nPercPro = 1.00 .Or. ( nPercPro = 0.00 .And. aInssemp[ 1, Val( cTpc ) ] # 0.00 )
					nPercPro := 0.15
				Endif
				fGrvSRD( aCodfol[ 148, 1 ], Round( nValBInss1 * nPercPro, 2 ) )   // Empresa
			Else
				nPercPro := PosSrv( aCodFol[221, 1 ], SRA->RA_FILIAL, "RV_PERC" ) / 100
				If nPercPro = 1.00 .Or. ( nPercPro = 0.00 .And. aInssemp[ 1, Val( cTpc ) ] # 0.00 )
					nPercPro := 0.20
				Endif
				fGrvSRD( aCodfol[ 148, 1 ], Round( nValBInss1 * nPercPro, 2 ) )   // Empresa
			Endif
		EndIf
	
		// Base INSS Ref. Servicos Prestados Pessoa Fisica e Juridica
		If aCodFol[ 350, 1 ] # Space( 3 ) .And. aCodFol[ 353, 1 ] # Space( 3 ) .And. nValBInss2 > 0
			nPercAut	 := PosSrv( aCodFol[ 350, 1 ], SRA->RA_FILIAL, "RV_PERC" ) / 100 // Considera os percentuais dos ids. 350 e 353 iguais
			If nPercAut = 1.00 .Or. ( nPercAut = 0.00  .And. aInssemp[ 1, Val( cTpc ) ] # 0.00 )
				nPercAut := 0.20
			EndIf
			
	    	fGrvSRD( aCodfol[ 148, 1 ], Round( nValBInss2 * nPercAut, 2 ) ) // Empresa
	    EndIf
	EndIf
	
	//-- Calculo do Pis Empresa
	If aCodFol[ 229, 1 ] # Space( 3 ) .And. nBasePis > 0
 		nPercPis  := PosSrv( aCodFol[ 229, 1 ], SRA->RA_FILIAL, "RV_PERC" ) / 100
    	fGrvSRD( aCodfol[ 229, 1 ], Round( nBasePis * nPercPis, 2 ) ) // PIS
    	if aCodFol[ 223, 1 ] # Space( 3 )
	    	fGrvSRD( aCodfol[ 223, 1 ], nBasePis ) // BASE PIS
	    EndIf
	EndIf
	
	// Montar Base Para Provisao Simplificada Ferias /  13o / Rescisao
	If ( aCodFol[ 194, 1 ] # Space( 3 ) .Or. aCodFol[ 195, 1 ] # Space( 3 ) .Or. aCodFol[ 196, 1 ] # Space( 3 ) ) .And. nValCus > 0.00
		// Calcular Provisao Simplificada
		fGrvSRD( aCodFol[ 194, 1 ], Round( nValCus * aInssemp[  6, Val( cTpc ) ], 2 ) ) // Prov. Ferias
		fGrvSRD( aCodFol[ 195, 1 ], Round( nValCus * aInssemp[  5, Val( cTpc ) ], 2 ) ) // Prov. 13o.
		fGrvSRD( aCodFol[ 196, 1 ], Round( nValCus * aInssemp[ 20, Val( cTpc ) ], 2 ) ) // Prov. Rescisao
	EndIf

	RestArea( aArea )
Return

/*/{Protheus.doc}fGrvSRD( cCodSRD, nValPd )
- Calcula encargos empresa dos funcionários
@Type Static Function
@author:	Jônatas Alves	
@since:		21/06/2017
@param: cCodSRD - Código da verba, nValPd - Valor do lançamento
@version 1.0
@return
/*/
Static Function fGrvSRD( cCodSRD, nValPd )

	Local lTemLct	:= .F.
	
	DEFAULT cCodSRD	:= ""
	DEFAULT nValPd	:= 0

	If Empty( cCodSRD ) .Or. nValPd == 0
		Return
	EndIf
	
	If SRD->( dbSeek( ( cAliasQry )->( RD_FILIAL + RD_MAT + RD_CC + RD_ITEM + RD_CLVL + cPeriodo + cCodSRD ) ) )
		While SRD->( !Eof() ) .And. ( cAliasQry )->( RD_FILIAL + RD_MAT + RD_CC + RD_ITEM + RD_CLVL + cPeriodo + cCodSRD ) == SRD->( RD_FILIAL + RD_MAT + RD_CC + RD_ITEM + RD_CLVL + RD_PERIODO + RD_PD )
			If cPeriodo == SRD->RD_PERIODO .And. cSemana == SRD->RD_SEMANA .And. ( cAliasQry )->RD_ROTEIR == SRD->RD_ROTEIR
				lTemLct := .T.
				Exit
			EndIf
			
			SRD->( dbSkip() )
		EndDo
	EndIf
	
	If !lTemLct
		RecLock( "SRD", .T., .T. )
		SRD->RD_FILIAL 	:= ( cAliasQry )->RD_FILIAL
		SRD->RD_MAT 	:= ( cAliasQry )->RD_MAT
		SRD->RD_PD		:= cCodSRD
		SRD->RD_CC		:= ( cAliasQry )->RD_CC
		SRD->RD_SEMANA 	:= cSemana
		SRD->RD_TIPO1	:= "V"
		SRD->RD_TIPO2	:= "C"
		SRD->RD_VALOR	:= nValPd
		SRD->RD_PROCES	:= cProcesso
		SRD->RD_PERIODO	:= cPeriodo
		SRD->RD_ROTEIR	:= ( cAliasQry )->RD_ROTEIR
		If lItemClVl
			SRD->RD_ITEM	:= ( cAliasQry )->RD_ITEM
			SRD->RD_CLVL	:= ( cAliasQry )->RD_CLVL
		EndIf
		SRD->RD_DTREF	:= ( cAliasQry )->RD_DTREF
		SRD->RD_DATARQ	:= cPeriodo
		SRD->RD_DATPGT	:= ( cAliasQry )->RD_DATPGT
		SRD->RD_MES		:= Right( cPeriodo, 2 )
		SRD->RD_STATUS	:= "A"
		SRD->RD_INSS	:= "N"
		SRD->RD_IR		:= "N"
		SRD->RD_FGTS	:= "N"
	EndIf
Return