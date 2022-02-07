#INCLUDE "protheus.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BFPC005D  ³ Autor ³ Sande Ribeiro        ³ Data ³09/05/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exporta dados para o Excel							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa  ³GENERICO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Analista  ³ Data   ³CYCLE ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sande      ³15/07/11³      ³	Tratamento do cabecalho da exportacao ³±±
±±³Ribeiro     ³        ³      ³ 								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sande      ³18/08/11³      ³ Tratamento da Operação na exportacao da³   ±±
±±³Ribeiro     ³        ³      ³ planilha						          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BFPC005D
Local	_aArea		:= GetArea()
Local	_aCampos	:=	{"AK3_ORCAME","AK3_VERSAO","AK3_CO","AK3_NIVEL","AK2_CC","AK2_ITCTB","AK2_CLVLR","AK2_DESCRI","AK2_DATAI","AK2_DATAF","AK2_VALOR","AK3_DESCRI","AK2_OPER"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sande Ribeiro 15/07/11 09:40:00hrs            ³
//³Verificacao de Necessidade                     ³
//³Tratamento do nome do cabecalho para exportacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local	_aCabec	:=	{"PLANILHA","VERSAO","CONTA","NIVEL","CCUSTO","ITEMC","CLASSE","COMPL","DATAINI","DATAFIM","VALOR","NOMECONTA","OPERACAO"}
Local	__x		:=	0
Private lEnd		:=	.f.
Private aHeader	:=	{}
Private aCols		:=	{}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a aHeader para utilizacao na exportacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
sx3->(DbSetOrder(2)) 
For __x := 1 to Len(_aCampos)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encontra os campos conforme definicao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SX3->(DbSeek(_aCampos[__x]))
		Aadd(aHeader,{ AllTrim(_aCabec[__X])	,;
									sx3->x3_campo		,;
									sx3->x3_picture	,;
									sx3->x3_tamanho	,;
									sx3->x3_decimal	,;
									sx3->x3_valid		,;
									sx3->x3_usado		,;
									sx3->x3_tipo		,;
									sx3->x3_f3 			,;
									sx3->x3_context	,;
									sx3->x3_cbox		,;
									sx3->x3_relacao})
	Endif
Next __x	
If (Aviso("ATENCAO!!!",Alltrim(cUserName)+", Confirma a Exportação da Planilha?",{"Sim","Não"}))==1
	Processa({||FUPCRUN()},"Verificando estrutura e Exportando...","Aguarde, por favor...",@lEnd)
	DlgToExcel({{"GETDADOS",nil,aHeader,aCols}})
Endif
RestArea(_aArea)
Return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FUPCRUN   ºAutor  ³Sande Ribeiro      º Data ³  05/10/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa a Exportacao do Arquivo                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³BFPC004D                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FUPCRUN()
DbSelectArea("AK3")
ak3->(DbSetOrder(1))
ProcRegua(RecCount())
If ak3->(DbSeek(xFilial("AK3")+ak1->ak1_codigo+ak1->ak1_versao))
	While ak3->(!Eof()) .And. ak3->ak3_filial==xFilial("AK3") 		.And.;
										ak3->ak3_orcame==ak1->ak1_codigo		.And.;
										ak3->ak3_versao==ak1->ak1_versao 

		DbSelectArea("AK2")
		ak2->(DbSetOrder(1))
		If ak2->(DbSeek(xFilial("AK2")+ak3->ak3_orcame+ak3->ak3_versao+ak3->ak3_co))
			While ak2->(!Eof()) .And. ak2->ak2_filial==xFilial("AK2") 		.And.	;
												ak2->ak2_orcame==ak3->ak3_orcame 	.And.	;
												ak2->ak2_versao==ak3->ak3_versao 	.And.	;
												ak2->ak2_co==ak3->ak3_co
				IncProc("Exportando Cta.:"+ak2->ak2_co)
				Aadd(aCols,{ak2->ak2_orcame,ak2->ak2_versao,ak2->ak2_co,ak3->ak3_nivel,ak2->ak2_cc,ak2->ak2_itctb,ak2->ak2_clvlr,ak2->ak2_descri,ak2->ak2_datai,ak2->ak2_dataf,ak2->ak2_valor,ak3->ak3_descri,ak2->ak2_oper,.f.})					
				ak2->(DbSkip())
			EndDo
		Else
			IncProc("Exportando Cta.:"+ak3->ak3_co)
			Aadd(aCols,{ak3->ak3_orcame,ak3->ak3_versao,ak3->ak3_co,ak3->ak3_nivel,,,,,,,,ak3->ak3_descri,,.f.})					
		Endif
		ak3->(DbSkip())
	EndDo
Endif
Return nil