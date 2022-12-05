#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TRM060.CH"
#INCLUDE "REPORT.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ TRM060   ³ Autor ³ Eduardo Ju              ³ Data ³ 02.06.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Treinamentos Solicitados ou Baixados                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRM060                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ BOPS ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv.³31/07/2014³TPZWAO³AIncluido o fonte da 11 para a 12 e efetuada ³±±
±±³             ³          ³      ³a limpeza.                                   ³±±
±±³Raquel Hager ³09/06/2016³TVEK53³Ajuste para atualizar o status como AUSENTE 	³±±
±±³             ³          ³      ³para funcionario que não teve presença.      ³±±
±±³Isabel N.  ³01/08/2017³DRHPONTP³Ajuste p/considerar data final do treinamento³±±
±±³           ³          ³    -807³ao filtrar funcionário demitido no relatório ³±±
±±³           ³          ³        ³e data do treinamento ao invés da solicitação³±±
±±³           ³          ³        ³ao buscar situação do funcionário.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function TRM060()
	Local oReport
	Local aArea			:= GetArea()
	Private cPerg		:= "TRR60A"
	Private cTitulo		:=	OemToAnsi(STR0010)  //-- Treinamentos Solicitados ou Baixados     Periodo:

	Private aFldRot 	:= {'RA_NOME'}
	Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
	Private lOfuscaNom 	:= .F. //RA_NOME
	Private aFldOfusca	:= {}

	If aOfusca[2]
		aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
			lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
		ENDIF
	EndIf

	Pergunte(cPerg,.F.)			//-- Usara o mesmo grupo de perguntas 
	oReport := ReportDef()
	oReport:PrintDialog()
	RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Microsiga           º Data ³  10/25/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local aOrdem    := {}
Local cAliasQry := GetNextAlias()
Local lRet		:= .T.
Local cIndCond	:= ""
Local nTamDesc  := TamSX3("RA1_DESC")[1]
Private oReport
Private oSection1
Private oSection2
Private oSection3

Aadd( aOrdem, OemToAnsi(STR0004))	// "Matricula"
Aadd( aOrdem, OemToAnsi(STR0005))	// "Centro de Custo"
Aadd( aOrdem, OemToAnsi(STR0006))	// "Nome" 
Aadd( aOrdem, OemToAnsi(STR0016)) 	// "Data"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "TRM060" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| TRM060Imp(oReport)} DESCRIPTION OemToAnsi(STR0039)   //-- "Este relatorio efetua a impressao  dos treinamentos que foram solicitados ou Baixados"
oReport:SetTotalInLine(.F.) //Totaliza em linha

DEFINE SECTION oSection1 OF oReport TITLE  oemtoAnsi(STR0040) TABLES "TRA","RA1","RA2","RA3","SRA","RA4","SQ0","SQ3","SQB" ORDERS aOrdem   //-- Treinamento

	DEFINE CELL NAME "CURSO" 	OF oSection1 TITLE OemToAnsi(STR0027)	SIZE 06 BLOCK{||cCurso}		//Curso
	DEFINE CELL NAME "DESCCUR"	OF oSection1 TITLE "-"					SIZE nTamDesc BLOCK{||cDescCur} CELL BREAK	//Descricao do Curso
	DEFINE CELL NAME "SINON" 	OF oSection1 TITLE OemToAnsi(STR0028)	SIZE 06 BLOCK{||cSinon}		//Sinonimo do Curso
	DEFINE CELL NAME "DESCSIN"	OF oSection1 TITLE "-"	                SIZE 20 BLOCK{||cDescSi}	//Descr. Sinonimo
	DEFINE CELL NAME "CALEND" 	OF oSection1 TITLE OemToAnsi(STR0032)	SIZE 06 BLOCK{||cCalend}	//Calendario do Curso
	DEFINE CELL NAME "DESCCAL"	OF oSection1 TITLE "-"					SIZE 20 BLOCK{||cDescCal} CELL BREAK	//Descr. Calendario
	DEFINE CELL NAME "TURMA" 	OF oSection1 TITLE OemToAnsi(STR0033)	SIZE 06 BLOCK{||cTurma}		//Turma
	DEFINE CELL NAME "DATAIN"	OF oSection1 TITLE OemToAnsi(STR0029)	SIZE 10 BLOCK{||DTOC(dDataIni)}//Periodo: Data Inicio do Curso
	DEFINE CELL NAME "DATAFI" 	OF oSection1 TITLE "-"					SIZE 10 BLOCK{||DTOC(dDataFim)}//Periodo: Data Final do Curso
	
	//Posicionamenro das tabelas
	TRPosition():New(oSection1,"RA1",1,{|| xfilial("RA1",TRA->TR_FILIAL)+TRA->TR_CURSO},.T.)
	TRPosition():New(oSection1,"RA2",1,{|| xfilial("RA2",TRA->TR_FILIAL)+TRA->TR_CALEND+TRA->TR_CURSO+TRA->TR_TURMA},.T.)	
	TRPosition():New(oSection1,"RA4",3,{|| xfilial("RA4",TRA->TR_FILIAL)+TRA->TR_CALEND+TRA->TR_CURSO+TRA->TR_TURMA+TRA->TR_MAT},.T.)



oSection1:SetLineStyle()
oSection1:SetCharSeparator("")


DEFINE SECTION oSection2 OF oSection1 TITLE oemtoAnsi(STR0038)  TABLES "TRA","RA2"												//-- Participantes 

	DEFINE CELL NAME "FIL" 			OF oSection2 TITLE OemToAnsi(STR0041) 	SIZE 12 BLOCK{||TR_FILIAL}									//Filial do Funcionario
	DEFINE CELL NAME "MATR" 		OF oSection2 TITLE OemToAnsi(STR0004)	BLOCK{||TRA->TR_MAT}								//Matricula do Funcionario
	DEFINE CELL NAME "NOME"	 		OF oSection2 TITLE OemToAnsi(STR0006)	SIZE 35 BLOCK{||TRA->TR_NOME}						//Nome do Funcionario 
	DEFINE CELL NAME "GRUPO"		OF oSection2 TITLE OemToAnsi(STR0034)	SIZE 15 BLOCK{||PadR(TrmDesc("SQ0",TRA->TR_GRUPO,"SQ0->Q0_DESCRIC",TRA->TR_FILIAL ),15)}	//Descricao do Grupo
	DEFINE CELL NAME "DEPTO"		OF oSection2 TITLE OemToAnsi(STR0035)	SIZE 20 BLOCK{||PadR(TrmDesc("SQB",TRA->TR_DEPTO,"SQB->QB_DESCRIC",TRA->TR_FILIAL ),20)}	//Descricao do Depto
	DEFINE CELL NAME "CARGO"		OF oSection2 TITLE OemToAnsi(STR0036)	SIZE 30 BLOCK{||PadR(TrmDesc("SQ3",TRA->TR_CARGO,"SQ3->Q3_DESCSUM",TRA->TR_FILIAL ),30)}	//Descricao do Cargo
	DEFINE CELL NAME "SITUACAO"		OF oSection2 TITLE OemToAnsi(STR0037)	SIZE 12 BLOCK{||TRA->TR_SITUAC}						//Status da Reserva (Reservado)

	TRPosition():New(oSection2,"SRA",1,{|| xfilial("SRA",TRA->TR_FILIAL)+TRA->TR_MAT},.T.)
	TRPosition():New(oSection2,"SQ0",1,{|| xfilial("SQ0",TRA->TR_FILIAL)+TRA->TR_GRUPO},.T.)
	TRPosition():New(oSection2,"SQ3",1,{|| xfilial("SQ3",TRA->TR_FILIAL)+TRA->TR_CARGO+TRA->TR_CC},.T.)
	TRPosition():New(oSection2,"SQB",1,{|| xfilial("SQB",TRA->TR_FILIAL)+TRA->TR_DEPTO},.T.)	
	TRPosition():New(oSection1,"RA3",1,{|| xfilial("RA3",TRA->TR_FILIAL)+TRA->TR_MAT+TRA->TR_CURSO},.T.)

oSection2:SetLeftMargin(07)

DEFINE SECTION oSection3 OF oReport TITLE oemtoAnsi(STR0005) TABLES "CTT", "TRA" 	//--Centro Custo 

	DEFINE CELL NAME "CENTROCUSTO"	OF oSection3 TITLE OemToAnsi(STR0005)	SIZE TamSx3("CTT_CUSTO")[1] BLOCK{||TRA->TR_CC}		//Centro de Custo
	DEFINE CELL NAME "DESCCCUSTO"	OF oSection3 TITLE "-"					SIZE 30 BLOCK{||Fdesc("CTT",TRA->TR_CC,"CTT_DESC01")}	//Descr. Centro de Custo

oSection3:SetLineStyle()
oSection3:SetCharSeparator("")

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Microsiga           º Data ³  10/25/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TRM060Imp(oReport)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01        //  Filial  De                               ³
//³ MV_PAR02        //  Filial  Ate                              ³
//³ MV_PAR03        //  Matricula De                             ³
//³ MV_PAR04        //  Matricula Ate                            ³
//³ MV_PAR05        //  Centro de Custo                          ³
//³ MV_PAR06        //  Centro de Custo                          ³
//³ MV_PAR07        //  Nome De                                  ³
//³ MV_PAR08        //  Nome Ate                                 ³
//³ MV_PAR09        //  Curso De                                 ³
//³ MV_PAR10        //  Curso Ate                                ³
//³ MV_PAR11        //  Grupo De                                 ³
//³ MV_PAR12        //  Grupo Ate                                ³
//³ MV_PAR13        //  Departamento De                          ³
//³ MV_PAR14        //  Departamento Ate                         ³
//³ MV_PAR15        //  Cargo De                                 ³
//³ MV_PAR16        //  Cargo Ate                                ³
//³ MV_PAR17        //  Periodo De                               ³
//³ MV_PAR18        //  Periodo Ate                              ³
//³ MV_PAR19        //  Treinamento 1-Aberto 2-Baixado 3-Ambos   ³
//³ MV_PAR20        //  Status Funcionario                       ³
//³ MV_PAR21        //  Ferias Programadas                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local oSection1		:= oReport:Section(1)
Local oSection2		:= oReport:Section(1):Section(1)  
Local oSection3		:= oReport:Section(2)
Local aOrdem		:= {}
Private oTempTable	:= Nil
Private nOrdem		:= oSection1:GetOrder()

aFields				:= {}
cAcessaRA3			:= &("{ || " + ChkRH("TRM060","RA3","2") + "}")
cAcessaRA4			:= &("{ || " + ChkRH("TRM060","RA4","2") + "}")
cSituacao			:= MV_PAR20
nFerProg			:= MV_PAR21
cSitFol				:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera Titulo do relatorio                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo 	:= If(AllTrim(oReport:Title())==AllTrim(cTitulo),cTitulo,oReport:Title()  )  + " "   //-- //-- Treinamentos Solicitados ou Baixados     Periodo:
cTitulo     += DtoC(MV_PAR17) + STR0011 + DtoC(MV_PAR18) 
oReport:SetTitle(cTitulo)

oSection1:Init()
oSection2:Init()
oSection3:Init()

AADD(aFields,{"TR_FILIAL",  "C", FWGETTAMFILIAL,          0                       } )
AADD(aFields,{"TR_CC",      "C", TamSx3("RA_CC")[1],      TamSx3("RA_CC")[2]      } )
AADD(aFields,{"TR_MAT",     "C", TamSx3("RA_MAT")[1],     TamSx3("RA_MAT")[2]     } )
AADD(aFields,{"TR_NOME",    "C", TamSx3("RA_NOME")[1],    TamSx3("RA_NOME")[2]    } )
AADD(aFields,{"TR_CURSO",   "C", TamSx3("RA3_CURSO")[1],  TamSx3("RA3_CURSO")[2]  } )
AADD(aFields,{"TR_DESCURS", "C", TamSx3("RA1_DESC")[1],   TamSx3("RA1_DESC")[2]   } )
AADD(aFields,{"TR_GRUPO",   "C", TamSx3("Q3_GRUPO")[1],   TamSx3("Q3_GRUPO")[2]   } )
AADD(aFields,{"TR_DEPTO",   "C", TamSx3("Q3_DEPTO")[1],   TamSx3("Q3_DEPTO")[2]   } )
AADD(aFields,{"TR_CARGO",   "C", TamSx3("Q3_CARGO")[1],   TamSx3("Q3_CARGO")[2]   } )
AADD(aFields,{"TR_DATAIN",  "D", TamSx3("RA3_DATA")[1],   TamSx3("RA3_DATA")[2]   } )
AADD(aFields,{"TR_DATAFI",  "D", TamSx3("RA3_DATA")[1],   TamSx3("RA3_DATA")[2]   } )
AADD(aFields,{"TR_CALEND",  "C", TamSx3("RA3_CALEND")[1], TamSx3("RA3_CALEND")[2] } )
AADD(aFields,{"TR_DESCCAL", "C", TamSx3("RA2_DESC")[1],   TamSx3("RA2_DESC")[2]   } )
AADD(aFields,{"TR_TURMA",   "C", TamSx3("RA3_TURMA")[1],  TamSx3("RA3_TURMA")[2]  } )
AADD(aFields,{"TR_SITUAC",  "C", 13,                      0                       } )
AADD(aFields,{"TR_SINON",   "C", TamSx3("RA2_SINON")[1],  TamSx3("RA2_SINON")[2]  } )
AADD(aFields,{"TR_DESCSI",  "C", TamSx3("RA9_DESCR")[1],  TamSx3("RA9_DESCR")[2]  } )

If !Empty(Select('TRA'))
	dbSelectArea('TRA')
	dbCloseArea()
EndIf

If nOrdem == 1 		// Matricula 
	aOrdem := {"TR_FILIAL", "TR_CURSO", "TR_CALEND", "TR_TURMA", "TR_MAT"}
ElseIf nOrdem == 2	// Centro de Custo + Matricula
	aOrdem := {"TR_FILIAL", "TR_CC", "TR_CURSO", "TR_CALEND", "TR_TURMA", "TR_MAT"}
ElseIf nOrdem == 3	// Nome	
	aOrdem := {"TR_FILIAL", "TR_CURSO", "TR_CALEND", "TR_TURMA", "TR_NOME"}
ElseIf nOrdem == 4	// Data
	aOrdem := {"TR_FILIAL", "TR_DATAIN", "TR_CURSO", "TR_CALEND", "TR_TURMA", "TR_MAT"}
EndIf

	oTempTable := FWTemporaryTable():New("TRA")
	oTempTable:SetFields( aFields )
	oTempTable:AddIndex( cValtoChar(nOrdem), aOrdem )
	oTempTable:Create()

oReport:SetMeter( 100 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Treinamentos Baixados ou Ambos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR19 == 2 .or. MV_PAR19 == 3 

	dbSelectArea("RA4")
	dbSetOrder(1)
	dbSeek(MV_PAR01+MV_PAR03+MV_PAR09,.T.)
	cInicio	:= "RA4->RA4_FILIAL + RA4->RA4_MAT + RA4->RA4_CURSO" 
	cFim	:= MV_PAR02 + MV_PAR04 + MV_PAR10

	While !Eof() .And. &cInicio <= cFim

		oReport:IncMeter( 1 )  

		If !Eval(cAcessaRA4)
			dbSkip()
			Loop
		EndIf

		If RA4->RA4_CURSO  < MV_PAR09 .Or. RA4->RA4_CURSO  > MV_PAR10 .Or.;
			RA4->RA4_DATAIN < MV_PAR17 .Or. RA4->RA4_DATAIN > MV_PAR18
			dbSkip()
			Loop
		EndIf
	
		dbSelectArea("RA2")
		dbSeek(xFilial("RA2")+RA4->RA4_CALEND+RA4->RA4_CURSO+RA4->RA4_TURMA)
	
		dbSelectArea("SRA")
		dbSetOrder(1)
	
		If dbSeek(RA4->RA4_FILIAL+RA4->RA4_MAT)
		
			//Situacao do Funcionario
			cSitFol := TrmSitFol(RA4->RA4_DATAIN, "B")
			cCargo 	:= fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)
			
			If !( Empty(SRA->RA_DEMISSA) )
				If ( SRA->RA_DEMISSA <= RA4->RA4_DATAFI )
					If SRA->RA_SITFOLH $ "D*T"
						cSitfol := SRA->RA_SITFOLH
					ElseIf AnoMes(dDatabase) == AnoMes(SRA->RA_DEMISSA) 
						cSitfol := "D"
					EndIf
				Else
					fChkAfas(RA4->RA4_FILIAL,RA4->RA4_MAT,RA4->RA4_DATAIN,,,@cSitFol,RA4->RA4_DATAIN,RA4->RA4_DATAFI)
				EndIf

				If Empty(cSitFol)
					cSitFol := SRA->RA_SITFOLH
				EndIf
			EndIf
			
			If 	(SRA->RA_MAT  	< MV_PAR03)	.Or. (SRA->RA_MAT 	> MV_PAR04)	.Or.;
				(SRA->RA_CC   	< MV_PAR05)	.Or. (SRA->RA_CC  	> MV_PAR06)	.Or.;
				(SRA->RA_NOME 	< MV_PAR07)	.Or. (SRA->RA_NOME 	> MV_PAR08)	.Or.;
				(cCargo 		< MV_PAR15) .Or. (cCargo 		> MV_PAR16)	.Or.;
				(!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P"))  		.Or.;
				(cSitfol == "P" .And. nFerProg == 2)
				
				dbSelectArea("RA4")
				dbSkip()
				Loop
			EndIf
				
			dbSelectArea( "SQ3" )
			dbSetOrder(1)
			cFil := xFilial("SQ3", SRA->RA_FILIAL)
			If dbSeek( cFil + cCargo + SRA->RA_CC ) .Or. dbSeek( cFil + cCargo )		
				If SQ3->Q3_GRUPO < MV_PAR11 .Or. SQ3->Q3_GRUPO > MV_PAR12 .Or.;
					SQ3->Q3_DEPTO < MV_PAR13 .Or. SQ3->Q3_DEPTO > MV_PAR14					
					dbSelectArea("RA4")
					dbSkip()
					Loop
				EndIf 
			EndIf
		
			dbSelectArea("RA1")
			dbSetOrder(1)
			cFil := xFilial("RA1", SRA->RA_FILIAL)
			dbSeek(cFil+RA4->RA4_CURSO)

			dbSelectArea("RA2")
			dbSetOrder(1)
			cFil := xFilial("RA2", SRA->RA_FILIAL)
			dbSeek(cFil+RA4->RA4_CALEND+RA4->RA4_CURSO+RA4->RA4_TURMA)
				
			RecLock("TRA",.T.)
				TRA->TR_FILIAL  	:= SRA->RA_FILIAL
				TRA->TR_CC      	:= SRA->RA_CC
				TRA->TR_MAT     	:= SRA->RA_MAT
				TRA->TR_NOME    	:= If(lOfuscaNom,Replicate('*',15),SRA->RA_NOME)
				TRA->TR_CURSO	 	:= RA4->RA4_CURSO
				TRA->TR_DESCURS 	:= RA1->RA1_DESC
				TRA->TR_GRUPO   	:= SQ3->Q3_GRUPO
				TRA->TR_DEPTO   	:= SQ3->Q3_DEPTO
				TRA->TR_CARGO   	:= SQ3->Q3_CARGO
				TRA->TR_DATAIN		:= RA4->RA4_DATAIN
				TRA->TR_DATAFI		:= RA4->RA4_DATAFI
				TRA->TR_CALEND		:= RA4->RA4_CALEND
				TRA->TR_DESCCAL		:= RA2->RA2_DESC
				TRA->TR_TURMA		:= RA4->RA4_TURMA			
				
				If RA4->RA4_PRESEN <> 0
					TRA->TR_SITUAC		:= STR0025 	//"CONCLUIDO"
				Else
					TRA->TR_SITUAC		:= STR0042 //"AUSENTE"
				EndIf
				
				TRA->TR_SINON		:= RA2->RA2_SINON
				TRA->TR_DESCSI		:= TrmDesc("RA9",RA2->RA2_SINON,"RA9->RA9_DESCR",SRA->RA_FILIAL)
			MsUnlock()
		EndIf		
		
		dbSelectArea("RA4")
		dbSkip()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Treinamentos em aberto ou Ambos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR19 == 1 .or. MV_PAR19 == 3 

	dbSelectArea("RA3")
	dbSetOrder(1)
	dbSeek(MV_PAR01+MV_PAR03+MV_PAR09,.T.)
	cInicio	:= "RA3->RA3_FILIAL + RA3->RA3_MAT + RA3->RA3_CURSO" 
	cFim	:= MV_PAR02 + MV_PAR04 + MV_PAR10

	While !Eof() .And. &cInicio <= cFim
            
		oReport:IncMeter(1)
		
		If !Eval(cAcessaRA3)
			dbSkip()
			Loop
		EndIf

		If RA3->RA3_CURSO  < MV_PAR09 .Or. RA3->RA3_CURSO  > MV_PAR10 .Or.;
			RA3->RA3_DATA < MV_PAR17 .Or. RA3->RA3_DATA > MV_PAR18
			dbSkip()
			Loop
		EndIf
	
	 	dbSelectArea("RA2")
		dbSeek(xFilial("RA2")+RA3->RA3_CALEND+RA3->RA3_CURSO+RA3->RA3_TURMA)
	
		dbSelectArea("SRA")
		dbSetOrder(1)
	
		If dbSeek(RA3->RA3_FILIAL+RA3->RA3_MAT)
			
			// Situacao do Funcionario
			cSitFol := TrmSitFol(RA2->RA2_DATAIN)
			cCargo 	:= fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)

			If !( Empty(SRA->RA_DEMISSA) )
				If ( SRA->RA_DEMISSA <= RA2->RA2_DATAFI )
					If SRA->RA_SITFOLH $ "D*T"
						cSitfol := SRA->RA_SITFOLH
					ElseIf AnoMes(dDatabase) == AnoMes(SRA->RA_DEMISSA) 
						cSitfol := "D"
					EndIf
				Else
					fChkAfas(RA3->RA3_FILIAL,RA3->RA3_MAT,RA2->RA2_DATAIN,,,@cSitFol,RA2->RA2_DATAIN,RA2->RA2_DATAFI)
				EndIf
				
				If Empty(cSitFol)
					cSitFol := SRA->RA_SITFOLH
				EndIf

			EndIf

			If 	(SRA->RA_MAT  	< MV_PAR03)	.Or. 	(SRA->RA_MAT 	> MV_PAR04)	.Or.;
				(SRA->RA_CC   	< MV_PAR05)	.Or. 	(SRA->RA_CC  	> MV_PAR06)	.Or.;
				(SRA->RA_NOME 	< MV_PAR07)	.Or. 	(SRA->RA_NOME 	> MV_PAR08)	.Or.;
				(cCargo			< MV_PAR15) .Or.	(cCargo 		> MV_PAR16)	.Or.;
				(!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P"))   		.Or.;
				(cSitfol == "P" .And. nFerProg == 2)
				
				dbSelectArea("RA3")
				dbSkip()
				Loop
			EndIf
				
			dbSelectArea( "SQ3" )
			dbSetOrder(1)
			cFil := xFilial("SQ3", SRA->RA_FILIAL)
			If dbSeek( cFil + cCargo + SRA->RA_CC ) .OR. dbSeek( cFil + cCargo )
				If SQ3->Q3_GRUPO < MV_PAR11 .Or. SQ3->Q3_GRUPO > MV_PAR12 .Or.;
					SQ3->Q3_DEPTO < MV_PAR13 .Or. SQ3->Q3_DEPTO > MV_PAR14
					
					dbSelectArea("RA3")
					dbSkip()
					Loop
				EndIf
			Else
				dbSelectArea("RA3")
				dbSkip()
				Loop	
			EndIf
		
			dbSelectArea("RA1")
			dbSetOrder(1)
			cFil := xFilial("RA1", SRA->RA_FILIAL)
			dbSeek(cFil+RA3->RA3_CURSO)

			dbSelectArea("RA2")
			dbSetOrder(1)
			cFil := xFilial("RA2", SRA->RA_FILIAL)
			dbSeek(cFil+RA3->RA3_CALEND+RA3->RA3_CURSO+RA3->RA3_TURMA)
				
			RecLock("TRA",.T.)
				TRA->TR_FILIAL  	:= SRA->RA_FILIAL
				TRA->TR_CC      	:= SRA->RA_CC
				TRA->TR_MAT     	:= SRA->RA_MAT
				TRA->TR_NOME    	:= If(lOfuscaNom,Replicate('*',15),SRA->RA_NOME)
				TRA->TR_CURSO	 	:= RA3->RA3_CURSO
				TRA->TR_DESCURS 	:= RA1->RA1_DESC
				TRA->TR_GRUPO   	:= SQ3->Q3_GRUPO
				TRA->TR_DEPTO   	:= SQ3->Q3_DEPTO
				TRA->TR_CARGO   	:= SQ3->Q3_CARGO
				TRA->TR_DATAIN		:= RA2->RA2_DATAIN
				TRA->TR_DATAFI		:= RA2->RA2_DATAFI
				TRA->TR_CALEND		:= RA3->RA3_CALEND
				TRA->TR_DESCCAL		:= RA2->RA2_DESC
				TRA->TR_TURMA		:= RA3->RA3_TURMA  
				TRA->TR_SINON		:= RA2->RA2_SINON						
				
				TRA->TR_DESCSI		:= TrmDesc("RA9",RA2->RA2_SINON,"RA9->RA9_DESCR",SRA->RA_FILIAL)
				
				cSituac := " "
				If RA3->RA3_RESERVA == "S"
				   cSituac := STR0022	//"Solicitacao"
				ElseIf RA3->RA3_RESERVA == "R"
				   cSituac := STR0023	//"Reserva"
				Else 
					cSituac := STR0024	//"Lista Espera" 
				EndIf
				TRA->TR_SITUAC		:= cSituac
			MsUnlock()
		EndIf		
		
		dbSelectArea("RA3")
		dbSkip()
	EndDo
EndIf

dbSelectArea("TRA")
dbGotop()

// Variaveis de totais da ordem selecionada
cAuxCurso	:= ""
cAuxTurma	:= ""
lRet		:= .T.
lOk			:= .F.
cCentro 	:= TRA->TR_CC
cCurso		:= TRA->TR_CURSO
cDescCur 	:= TRA->TR_DESCURS                  
cCalend		:= TRA->TR_CALEND
cDescCal	:= TRA->TR_DESCCAL
cTurma		:= TRA->TR_TURMA
cSinon 		:= TRA->TR_SINON
cDescSi		:= TRA->TR_DESCSI
dDataIni	:= TRA->TR_DATAIN
dDataFim	:= TRA->TR_DATAFI


While !Eof()

	oReport:IncMeter(1)
	
	If lRet
		If nOrdem == 2
			oReport:ThinLine()
			oReport:SkipLine()
			oSection3:PrintLine()
		EndIf
		lRet:= .F.
	EndIf		

	If !( cCurso+cCalend+cTurma == TRA->TR_CURSO+TRA->TR_CALEND+TRA->TR_TURMA ) .OR.;
		( !( dDataIni	== TRA->TR_DATAIN ) .OR. !( dDataFim == TRA->TR_DATAFI) )
		cAuxCurso	:= ""
		cAuxTurma	:= ""
		cCurso   	:= TRA->TR_CURSO
		cDescCur 	:= TRA->TR_DESCURS
		cCalend		:= TRA->TR_CALEND
		cDescCal	:= TRA->TR_DESCCAL
		cTurma		:= TRA->TR_TURMA
		cSinon 		:= TRA->TR_SINON
		cDescSi		:= TRA->TR_DESCSI
		dDataIni	:= TRA->TR_DATAIN
		dDataFim	:= TRA->TR_DATAFI
	EndIf
	If nOrdem == 2 .And. cCentro !=TRA->TR_CC
		oReport:ThinLine()       
		oReport:SkipLine()
		oSection3:PrintLine()
		cAuxCurso	:= ""
		cAuxTurma 	:= ""
		cCurso	 	:= TRA->TR_CURSO
		cDescCur	:= TRA->TR_DESCURS
		cCentro   	:= TRA->TR_CC  
		cCalend	 	:= TRA->TR_CALEND
		cDescCal	:= TRA->TR_DESCCAL
		cTurma	 	:= TRA->TR_TURMA
		cSinon 		:= TRA->TR_SINON
		cDescSi		:= TRA->TR_DESCSI		
		
	EndIf
	FImpDet(oReport,oSection1,oSection2)		

	dbSelectArea("TRA")
	dbSkip()
EndDo

If !lRet
	If nOrdem == 2
		FImpDet(oReport,oSection1,oSection2)
	EndIf	
	lOk := .T.
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do Relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRA")
dbCloseArea()
oTempTable:Delete()

dbSelectArea("SRA")
dbSetOrder(1)

dbSelectArea("RA3")
dbSetOrder(1)

dbSelectArea("RA4")
dbSetOrder(1)

dbSelectArea("SQ3") 
dbSetOrder(1)

dbSelectArea("RA1")
dbSetOrder(1)

Set Device To Screen

oSection1:Finish()
oSection2:Finish()
oSection3:Finish()

Return Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime as linhas de detalhe do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fImpDet(oReport,oSection1,oSection2)

cAuxDet := ""
DET :="   "

If cAuxCurso+cAuxTurma == cCurso+cTurma
	cCurso   := Space(05)
	cAuxDet 	:= ""
	cTurma	:= Space(03)
Else
	cAuxCurso := cCurso
	cAuxTurma := cTurma        
	oReport:ThinLine()
	oReport:SkipLine()    
	
	oSection2:Finish()                     
	
	oSection1:PrintLine()

	oSection2:Init()                     
		
EndIf	

cCurso := cAuxCurso								
cTurma := cAuxTurma

oSection2:PrintLine()

Return Nil
