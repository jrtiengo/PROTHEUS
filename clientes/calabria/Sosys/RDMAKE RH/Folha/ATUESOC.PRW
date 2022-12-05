#INCLUDE "TOTVS.CH"
//#INCLUDE "ATUESOC.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    	³ ATUESOC    ³ Autor ³ Marcia Moura            	      ³ Data ³05/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o 	³ Atualização dos campos SRA                                  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ ATUESOC( )                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      	³ Generico                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ FNC			³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Glaucia M.   ³29/01/14  ³                ³Preparacao fase2 com novos campos          ³±±
±±³Marcia Moura ³31/01/14  ³TIHG12          ³Inclusão do campo cargo, carga automatica  ³±±
±±³             ³          ³                ³pois passa a ser obrigatorio sera carrega  ³±±
±±³             ³          ³                ³do a partir da função                      ³±±
±±³Glaucia M.   ³21/02/2014³TIIL14          ³Inclusao de nova pergunta no conversor     ³±±
±±³             ³          ³00000004960/2014³eSocial.                                   ³±±
±±³Mariana M.   ³23/06/14  ³TII100          ³Ajuste para que o campo RA_CATEFD seja pre-³±±
±±³             ³          ³                ³enchido corretamente                       ³±±
±±|Claudinei S. |04/09/2017|DRHESOCP-876    |Disponibilizado o fonte para a versão 12.  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function ATUESOC()

	Local aSays			:= {}
	Local aButtons		:= {}

	Local bProcesso		:= { |oSelf| GPMProcessa(oSelf)}

	Local cPerg
	Local cCadastro		:= OemToAnsi("Conversão de novos campos SRA - eSocial")	//"Conversão de novos campos SRA - eSocial"
	Local cDescricao	:= OemToAnsi("Este Programa efetuará a conversão dos novos campos criados para o eSocial" )	//"Este Programa efetuará a conversão dos novos campos criados para o eSocial"

	Local nOpca			:= 0

	Private aLog		:= {}
	Private aRoteiro 	:= {}
	Private aTitle		:= {}

	Private lAbortPrint := .F.

	Static     aEfd                      := If( cPaisLoc == 'BRA', If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.}), {.F.,.F.,.F.} )

 //	// Var utilizada para forcar a Carga da Tabela a cada processamento. Eh necessaria para
 //	// que aTab_Fol seja atualizada conforme as tabelas de cada empresa na funcao fPosTab.
 //	Private lCarTabFol := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica existencia dos novos campos na SRA                      		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cPaisLoc == 'BRA' .AND.  aEfd[1])

		If Empty( RetTableName( "RFX" ) )
			Aviso( "Atenção", "Execute a opção do compatibilizador referente ao eSocial. Para maiores informações, verifique respectivo Boletim Técnico.", { "OK" } ) // "Atenção"## "Execute a opção do compatibilizador referente ao eSocial. Para maiores informações, verifique respectivo Boletim Técnico." ## "OK"
			Return
		EndIf

		cPerg 	:= "GPESOC"

		ValidPerg(cPerg)

		Pergunte(cPerg,.F.)

		tNewProcess():New( "ATUESOC", "Atualização dos novos campos eSocial - SRA", bProcesso, "    Esta rotina tem por objetivo alimentar automaticamente os campos novos do Cadastro de Funcionários, criados para o eSocial  ", cPerg, , , , , .T., .T. )
	EndIf
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ GPMProcessa	³Autor³  Marcia Moura      Data ³05/09/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Rotina de Processamento.                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ATUESOC                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function GPMProcessa(oSelf)

	Local cFilDe
	Local cFilAte
	Local cMatrDe
	Local cMatrAte
	Local cSituacao
	Local aLogr			:= {}
	Local _aArea		:= GetArea()
	Local cAcessaSRA	:= &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "ATUESOC" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
	Local cAliasSRA		:= "SRA"
	Local lRet
	Local lHasDep
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
	Local lOfusca		:= Len(aFldRel) > 0

	cFilDe		:=	mv_par01	//	Filial De
	cFilAte 	:=	mv_par02	//	Filial Ate
	cMatrDe 	:=	mv_par03	//	Matricula De
	cMatrAte	:=	mv_par04	//	Matricula Ate
	cSituacao	:=  mv_par05	//  Situacoes a serem calculadas
	nLogrTp		:=  mv_par06	//  1-So preenche RA_LOGRTP vazio / 2-Altera o campo RA_LOGRTP vazio ou não

	oSelf:SetRegua1(SRA->(RecCount()))
	oSelf:SaveLog( "Conversão do SRA - eSocial" + " - " + "Inicio do processamento") //"Conversão do SRA - eSocial"##"Inicio do processamento"

	// Filtrar os funcionarios que serao processados //
	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( cFilDe + cMatrDe , .T. )

	While (cAliasSRA)->( !Eof() )

		If oSelf:lEnd
			Break
		EndIf

		If Eof() .Or. ( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT > cFilAte + cMatrAte )
			Exit
		Endif

		If ( (cAliasSRA)->RA_MAT < cMatrDe .or. (cAliasSRA)->RA_MAT > cMatrAte ) .or. !( (cAliasSRA)->RA_SITFOLH $ cSituacao )
				dbSelectArea(cAliasSRA)
				dbSkip()
				Loop
		EndIf

		oSelf:IncRegua1(OemToAnsi("Convertendo Dados") + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + If(lOfusca, "", " - " + SRA->RA_NOME) )//

		Begin Transaction
		       //Categoria eSocial
		    RecLock("SRA",.F.)

			If FieldPos( "RA_CATEFD" ) # 0  .AND. EMPTY((cAliasSRA)->RA_CATEFD)
			   if (cAliasSRA)->RA_CATFUNC == "E" .OR.(cAliasSRA)->RA_CATFUNC == "G"
			   		(cAliasSRA)->RA_CATEFD := "901"
			   Else
			   		if (cAliasSRA)->RA_CATEG == "  "
			   			(cAliasSRA)->RA_CATEFD := "101"
			   		Else
				   		(cAliasSRA)->RA_CATEFD := fDescRCC('S049',(cAliasSRA)->(RA_CATEG),4,2,1,3)
			   		endif
			   Endif
			Endif

			//se deficiencia Fisica eSocial estiver vazio
			If FieldPos( "RA_PORTDEF" ) # 0 .AND. EMPTY((cAliasSRA)->RA_PORTDEF)
				If TAMSX3("RA_PORTDEF")[1] == 4
					If (cAliasSRA)->RA_TPDEFFI == "1"
						(cAliasSRA)->RA_PORTDEF := "1***"
					elseif (cAliasSRA)->RA_TPDEFFI == "2"
						(cAliasSRA)->RA_PORTDEF := "*2**"
					elseif (cAliasSRA)->RA_TPDEFFI == "3"
						(cAliasSRA)->RA_PORTDEF := "**3*"
					elseif (cAliasSRA)->RA_TPDEFFI == "6"
						(cAliasSRA)->RA_PORTDEF := "***4"
					endif
				ElseIf TAMSX3("RA_PORTDEF")[1] == 6
					If (cAliasSRA)->RA_TPDEFFI == "1"
						(cAliasSRA)->RA_PORTDEF := "1*****"
					elseif (cAliasSRA)->RA_TPDEFFI == "2"
						(cAliasSRA)->RA_PORTDEF := "*2****"
					elseif (cAliasSRA)->RA_TPDEFFI == "3"
						(cAliasSRA)->RA_PORTDEF := "**3***"
					elseif (cAliasSRA)->RA_TPDEFFI == "6"
						(cAliasSRA)->RA_PORTDEF := "*****6"
					endif
				EndIf
	        Endif

	       	//tipo de conta, so sera preenchido se os campos banco e conta estiverem preenchidos
   			If !Empty((cAliasSRA)->RA_BCDEPSA) .AND. !Empty((cAliasSRA)->RA_CTDEPSA)
   				If FieldPos( "RA_TPCTSAL" ) # 0 .AND. Empty((cAliasSRA)->RA_TPCTSAL)
               		(cAliasSRA)->RA_TPCTSAL := "1"
	       		ElseIf FieldPos( "RA_TPCTDEP" ) # 0 .AND. Empty((cAliasSRA)->RA_TPCTDEP)
					(cAliasSRA)->RA_TPCTDEP := "1"
				EndIf
   			EndIf

           //tipo de previdencia
   			If FieldPos( "RA_TPPREVI" ) # 0 .AND. Empty((cAliasSRA)->RA_TPPREVI)
				(cAliasSRA)->RA_TPPREVI := "1"
			EndIf

			//Informação de aposentadoria
   			If FieldPos( "RA_EAPOSEN" ) # 0 .AND. Empty((cAliasSRA)->RA_EAPOSEN)
				(cAliasSRA)->RA_EAPOSEN := "2"
			EndIf

           //Emissor do RG
   			If FieldPos( "RA_RGEXP" ) # 0
           	If empty((cAliasSRA)->RA_RGEXP)
              		If !(empty((cAliasSRA)->RA_RGORG))
	          			(cAliasSRA)->RA_RGEXP := (cAliasSRA)->RA_RGORG
	          		Else
	          			(cAliasSRA)->RA_RGEXP := (cAliasSRA)->RA_ORGEMRG
	          		Endif
	          	Endif
	        endif


			dbSelectArea(cAliasSRA)


            //Cargo
   			If FieldPos( "RA_CARGO" ) # 0
	           	If empty((cAliasSRA)->RA_CARGO)
        	   		dbSelectArea("SRJ")
   	  				If dbSeek(fwxFilial("SRJ") + (cAliasSRA)->RA_CODFUNC)
   						(cAliasSRA)->RA_CARGO := SRJ->RJ_CARGO
   					Endif
					dbSelectArea(cAliasSRA)
				Endif
	        Endif


			// Nacionalidade
			If FieldPos( "RA_NACIONC" ) # 0 .AND. Empty((cAliasSRA)->RA_NACIONC)
               If (cAliasSRA)->RA_NACIONA == "10" .OR.(cAliasSRA)->RA_NACIONA == "20"
               		(cAliasSRA)->RA_NACIONC := "01058"
               Elseif (cAliasSRA)->RA_NACIONA == "21"
               		(cAliasSRA)->RA_NACIONC := "00639"
               Elseif (cAliasSRA)->RA_NACIONA == "22"
               		(cAliasSRA)->RA_NACIONC := "00973"
               Elseif (cAliasSRA)->RA_NACIONA == "23"
               		(cAliasSRA)->RA_NACIONC := "01589"
               Elseif (cAliasSRA)->RA_NACIONA == "24"
               		(cAliasSRA)->RA_NACIONC := "05860"
               Elseif (cAliasSRA)->RA_NACIONA == "25"
               		(cAliasSRA)->RA_NACIONC := "08451"
               Elseif (cAliasSRA)->RA_NACIONA == "26"
               		(cAliasSRA)->RA_NACIONC := "06475"
               Elseif (cAliasSRA)->RA_NACIONA == "27"
               		(cAliasSRA)->RA_NACIONC := "04936"
               Elseif (cAliasSRA)->RA_NACIONA == "28"
               		(cAliasSRA)->RA_NACIONC := "05894"
               Elseif (cAliasSRA)->RA_NACIONA == "29"
               		(cAliasSRA)->RA_NACIONC := "02399"
               Elseif (cAliasSRA)->RA_NACIONA == "30"
               		(cAliasSRA)->RA_NACIONC := "00230"
               Elseif (cAliasSRA)->RA_NACIONA == "31"
               		(cAliasSRA)->RA_NACIONC := "00876"
               Elseif (cAliasSRA)->RA_NACIONA == "32"
               		(cAliasSRA)->RA_NACIONC := "06289"
               Elseif (cAliasSRA)->RA_NACIONA == "34"
               		(cAliasSRA)->RA_NACIONC := "01490"
               Elseif (cAliasSRA)->RA_NACIONA == "35"
               		(cAliasSRA)->RA_NACIONC := "02453"
               Elseif (cAliasSRA)->RA_NACIONA == "36"
               		(cAliasSRA)->RA_NACIONC := "02496"
               Elseif (cAliasSRA)->RA_NACIONA == "37"
               		(cAliasSRA)->RA_NACIONC := "02755"
               Elseif (cAliasSRA)->RA_NACIONA == "38"
               		(cAliasSRA)->RA_NACIONC := "07676"
               Elseif (cAliasSRA)->RA_NACIONA == "39"
               		(cAliasSRA)->RA_NACIONC := "03867"
               Elseif (cAliasSRA)->RA_NACIONA == "40"
               		(cAliasSRA)->RA_NACIONC := "03417"
               Elseif (cAliasSRA)->RA_NACIONA == "41"
               		(cAliasSRA)->RA_NACIONC := "03999"
               Elseif (cAliasSRA)->RA_NACIONA == "42"
               		(cAliasSRA)->RA_NACIONC := "01600"
               Elseif (cAliasSRA)->RA_NACIONA == "43"
               		(cAliasSRA)->RA_NACIONC := "01872"
               Elseif (cAliasSRA)->RA_NACIONA == "44"
               		(cAliasSRA)->RA_NACIONC := "06769"
               Elseif (cAliasSRA)->RA_NACIONA == "45"
               		(cAliasSRA)->RA_NACIONC := "06076"
               Elseif (cAliasSRA)->RA_NACIONA == "46"
               		(cAliasSRA)->RA_NACIONC := "05762"
               Elseif (cAliasSRA)->RA_NACIONA == "47"
               		(cAliasSRA)->RA_NACIONC := "03611"
               Elseif (cAliasSRA)->RA_NACIONA == "60"
               		(cAliasSRA)->RA_NACIONC := "00400"
               Elseif (cAliasSRA)->RA_NACIONA == "61"
               		(cAliasSRA)->RA_NACIONC := "01775"
               Elseif (cAliasSRA)->RA_NACIONA == "62"
               		(cAliasSRA)->RA_NACIONC := "07560"
               Elseif (cAliasSRA)->RA_NACIONA == "96"
               		(cAliasSRA)->RA_NACIONC := "08508"
               Elseif (cAliasSRA)->RA_NACIONA == "97"
               		(cAliasSRA)->RA_NACIONC := "01694"
			   Endif
			Endif

			//Tipo de Logradouro, logradouro e Numero
			If FieldPos( "RA_LOGRTP" ) # 0
				If (nLogrTp == 1 .AND. EMPTY((cAliasSRA)->RA_LOGRTP)) .OR. (nLogrTp == 2)
					aLogr := {}
					aLogr := fCargaLogr((cAliasSRA)->RA_ENDEREC,(cAliasSRA)->RA_NUMENDE)
					(cAliasSRA)->RA_LOGRTP := aLogr[1]
					(cAliasSRA)->RA_LOGRDSC := aLogr[2]
					(cAliasSRA)->RA_LOGRNUM := aLogr[3]
				EndIf
			endif

			//Municipio Endereco
			DbSelectArea( "CC2" )
			DbSetOrder(2)
			MsSeek(fwxFilial("CC2")+ (cAliasSRA)->RA_MUNICIP)
			While CC2->(!Eof())
				if CC2->CC2_EST == (cAliasSRA)->RA_ESTADO
					(cAliasSRA)->RA_CODMUN := CC2->CC2_CODMUN
					exit
				else
					DbSelectArea( "CC2" )
					CC2->(dbSkip())
				Endif
			end

			//Municipio Nascimento
			DbSelectArea( "CC2" )
			DbSetOrder(2)
			MsSeek(fwxFilial("CC2")+ (cAliasSRA)->RA_MUNNASC)
			While CC2->(!Eof())
				if CC2->CC2_EST == (cAliasSRA)->RA_NATURAL
					(cAliasSRA)->RA_CODMUNN := CC2->CC2_CODMUN
					exit
				else
					DbSelectArea( "CC2" )
					CC2->(dbSkip())
				Endif
			end

			dbSelectArea(cAliasSRA)
			MsUnLock()

		End Transaction

       dbSelectArea(cAliasSRA)
		(cAliasSRA)->(DbSkip())
	EndDo

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Apresenta com Log de erros                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fMakeLog(aLog,aTitle,,.T.,"ATUESOC","LOG de Atualização registros SRA" ,"M","P",,.F.)  //

Return


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ValidPerg ³ Autor ³Equipe RH              ³ Data ³02/04/2012³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Ajusta Perguntas 											³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ValidPerg(cPerg)
Local _aArea	:= GetArea()
Local aRegs		:= {}
Local i, j		:= 0

cPerg			:= "GPESOC    "
cPerg			:= PADR(cPerg, 6)
aHelpPor:= {"1-Sim: Somente se o campo RA_LOGRTP ",;
			"estiver vazio, o mesmo será ",;
			"preenchido baseado no campo ",;
			"RA_ENDEREC.                     ",;
			" /                               ",;
			"2-Não: O campo RA_LOGRTP será ",;
			"preenchido ou substituído com base",;
			" no conteúdo do campo RA_ENDEREC"}

aHelpEng:= {"Sim - Somente se o campo RA_LOGRTP ",;
			"estiver vazio, o mesmo será ",;
			"preenchido baseado no campo ",;
			"'RA_ENDEREC' ",;
			"Não - O campo RA_LOGRTP será ",;
			"preenchido ou substituído com base",;
			" no conteúdo do campo RA_ENDEREC"}

aHelpSpa:= {"Sim - Somente se o campo RA_LOGRTP ",;
			"estiver vazio, o mesmo será ",;
			"preenchido baseado no campo ",;
			"'RA_ENDEREC' ",;
			"Não - O campo RA_LOGRTP será ",;
			"preenchido ou substituído com base",;
			" no conteúdo do campo RA_ENDEREC"}

PutSX1Help("P"+".GPESOC06.",aHelpPor,aHelpEng,aHelpSpa, .T.)


SX1->(dbSetOrder(1))

// Grupo/Ordem/Pergunta/Perg.SPA/Perg.ENG/Variavel/Tipo/Tamanho/Decimal/Presel														/GSC/Valid				/ Var01		/Def01/Def1.SPA/Def1.ENG	/Cnt01/ Var02/Def02/Def1.SPA/Def1.ENG/Cnt02/ Var03/Def03/Def1.SPA/Def1.ENG/Cnt03/ Var04/Def04/Def1.SPA/Def1.ENG/Cnt04/ Var05/Def05/Def1.SPA/Def1.ENG/Cnt05/ F3/PYME/GRPSXG/HELP/PICTURE/IDFIL
cHelp := ".RHFILDE."
aAdd(aRegs, {cPerg, "01", "Filial De                ", "Filial De                		", ".", "mv_ch1", "C", FWGETTAMFILIAL, 0, 0, "G", ""				, "mv_par01", "", "", "", "01"			, ""	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "XM0"	, "S", "033", cHelp, "", ""})
cHelp := ".RHFILAT."
aAdd(aRegs, {cPerg, "02", "Filial Ate               ", "Filial Ate               		", ".", "mv_ch2", "C", FWGETTAMFILIAL, 0, 0, "G", "NaoVazio()"		, "mv_par02", "", "", "", "01"			, ""	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "XM0"	, "S", "033", cHelp, "", ""})
cHelp := ".RHMATD."
aAdd(aRegs, {cPerg, "03", "Matricula De             ", "Matricula De             		", ".", "mv_ch3"			, "C", 06, 0, 0, "G", ""				, "mv_par03", "", "", "", "0"			, ""	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA"	, "S", ""	, cHelp, "", ""})
cHelp := ".RHMATA."
aAdd(aRegs, {cPerg, "04", "Matricula Ate            ", "Matricula Ate            		", ".", "mv_ch4"			, "C", 06, 0, 0, "G", "NaoVazio()"		, "mv_par04", "", "", "", "Z"			, ""	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA"	, "S", ""	, cHelp, "", ""})

aAdd(aRegs, {cPerg, "05", "Situação 	            ", "Situação                  		", ".", "mv_ch5"			, "C", 15, 0, 0, "G", "fSituacao()"		, "mv_par05", "", "", "", " "			, ""	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""	, "S", ""	, ".RHSITUA.", "", ""})
aAdd(aRegs, {cPerg, "06", "Preenche apenas TpLogr vazio?", "Converte apenas TpLogr vazio?", ".", "mv_ch6"			, "C", 01, 0, 0, "C", ""				, "mv_par06", "1-Sim", "1-Sim", "1-Sim", " "	, ""	, "2-Não", "2-Não", "2-Não", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""	, "S", ""	, ".GPESOC06.", "", ""})

dbSelectArea("SX1")
SX1->( DbSetorder(1) )

If !SX1->(dbSeek(cPerg))
	For i := 1 to Len(aRegs)
		If	!SX1->(dbSeek(cPerg + aRegs[i, 2]))
			RecLock("SX1", .T.)
			For j := 1 to FCount()
				FieldPut(j, aRegs[i, j])
			Next
			MsUnlock("SX1")
		endif
	Next
EndIf

If	!SX1->(dbSeek("GPESOC    06"))
	RecLock("SX1", .T.)
	For j := 1 to FCount()
		FieldPut(j, aRegs[6, j])
	Next
	MsUnlock("SX1")
EndIf

RestArea (_aArea)
Return Nil
