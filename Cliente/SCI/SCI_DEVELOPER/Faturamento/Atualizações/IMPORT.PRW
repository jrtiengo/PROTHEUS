#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImport    บAutor  ณJonas L. Souza Jr   บ Data ณ  02/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de importacao de tabelas                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Import()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oWizard
Local nMetGlob
Local nMetParc
Local oRadioArq
Local nRadioArq		:= 1

Local cText
Local cFile			:= replicate( " ", 80 )
Local cHeader 		:= "Importa็ใo de dados"
Local cTpArq		:= "Delimitado (*.csv)|*.CSV|"
Local cDelim		:= AllTrim(SuperGetMV("MV_TPDELI",.F.,';'))
Local nLinCabec		:= 1 // Padrใo sem linha de cabe็alho
Local cCabec		:= "" // String com o cabe็alho do arquivo original, se houver
Local nQtdCab		:= 1 // String com o cabe็alho do arquivo original, se houver
Local cNmAlias		:= "Clientes (SA1)"
Local cTipo			:= "1"

Private INCLUI	:= .T.
Private ALTERA	:= .F.

cText 	:= 	 "Esta rotina tem por objetivo importar registros, atrav้s " + ; 
			 "de um arquivo padrใo CSV (delimitado) , e armazena-los na tabela "+ ; 
			 "correspondente do sistema."+ CRLF + ; 
			 "Os nomes das colunas devem ser os mesmos nomes de campos a serem atualizados."+ CRLF + CRLF + ; 
			 "Ao final da importa็ใo serแ gerado um arquivo de log contendo as "+ ; 
			 "inconsist๊ncias."

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPrimeiro Painel - Abertura     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE WIZARD oWizard 	TITLE "Import็ใo de dados" ;
							HEADER cHeader ; 
							MESSAGE "Apresenta็ใo." ;
							TEXT cText ;
							NEXT { || .T. } ;
							FINISH {|| .T.} PANEL
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSegundo Painel - Arquivo e Contrato ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Selecione os tabela que deseja importar" ;
							BACK {|| .T. } ;
							NEXT {|| .T. } ;
							FINISH {|| .F. } ;
							PANEL         
	
	oPanel := oWizard:GetPanel( 2 )
	
	@ 15, 08 GROUP oGrpCon 	TO 120, 230 LABEL "Cadastro a ser importado" OF oPanel PIXEL DESIGN
	     
	@ 25,35 Radio oRadioArq Var nRadioArq Items "Clientes (SA1)",;
												"Produtos (SB1)",;
												"Fornecedores (SA2)",;
												"Vendedores (SA3)",;
												"Contas a Receber - em aberto (SE1)",;
												"Contas a Pagar - em aberto (SE2)",;
												"Saldos Iniciais - Estoque (SB9)",;
												"Saldos Lote/SubLote (SD5)" ;
												3D 	Size 170,10 Of oPanel PIXEL DESIGN ;
												ON CHANGE ImpChgRadio(nRadioArq,@cNmAlias)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSegundo Painel - Arquivo e Contrato ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Selecione o arquivo para importa็ใo." ;
							BACK {|| .T. } ;
							NEXT {|| ! empty( cDelim ) .and. ! empty( cFile ) } ;
							FINISH {|| .F. } ;
							PANEL         
	
	oPanel := oWizard:GetPanel( 3 )
	
	@ 10, 08 GROUP oGrpCon 	TO 40, 280 LABEL "Selecione um arquivo." ; 
							OF oPanel ;
							PIXEL ;
	     					DESIGN

	@ 20, 15 MSGET oArq 	VAR cFile WHEN .F. OF oPanel SIZE 140, 10 PIXEL ;
							MESSAGE "Utilize o botใo ao lado para selecionar" ; 

	DEFINE SBUTTON oButArq 	FROM 21, 160 ;
					 		TYPE 14 ;
					 		ACTION cFile := cGetFile(cTpArq, , 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) ; 
					 		OF oPanel ;
					 		ENABLE
	
	@ 50, 08 GROUP oGrpCon 	TO 130, 280 LABEL "Informe as configura็๕es do arquivo." ; 
							OF oPanel ;
							PIXEL ;
	     					DESIGN
	     
  	@ 60,20 SAY "Delimitador" OF oPanel SIZE 35,8 PIXEL   
	@ 60,60 MSGET oDelim	VAR cDelim  ;
							PICTURE "@!" ;
							VALID !empty(cDelim) ;
							MESSAGE "Informe um delimitador de campo." ; 
							OF oPanel SIZE 10,8 PIXEL 
                         	
  	@ 80,20 SAY "Tipo" OF oPanel SIZE 35,8 PIXEL   
	@ 80,60 COMBOBOX oTipo  Var cTipo ITEMS {"1=Somente Log","2=Log + Importa็ใo"} 	SIZE 200,010 OF oPanel PIXEL  

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTerceiro Painel - Confirmacao  / Processamento ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Confirma็ใo dos dados e inํcio de processamento." ; 
							BACK {|| .T. } ;
							NEXT {|| .T. } ;
							FINISH {|| .F. } ;
							PANEL         
							
	oPanel := oWizard:GetPanel( 4 )

	@ 010, 010 SAY "Arquivo" OF oPanel SIZE 140, 8 PIXEL   
	@ 010, 050 SAY cFile  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL  
	
	@ 030, 010 SAY  "Delimitador" OF oPanel SIZE 140, 8 PIXEL   
	@ 030, 050 SAY  cDelim  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	


	@ 050, 010 SAY  "Alias" OF oPanel SIZE 140, 8 PIXEL   
	@ 050, 050 SAY  cNmAlias  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	


	@ 070, 010 SAY  "Tipo Proc.:" OF oPanel SIZE 140, 8 PIXEL   
	@ 070, 050 SAY  IIf(cTipo=="1","Somente Log","Log+Importa็ใo")  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	
                                      

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuarto Painel - Processamento                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Processamento da Importa็ใo." ; 
							BACK {|| .F. } ;
							NEXT {|| .T. } ;
							FINISH {|| .T. } ;
							EXEC {|| CursorWait(), IMPCADPro( oMetGlob, nRadioArq, cFile, cDelim, cTipo ), CursorArrow() } ;
							PANEL 
							        
	oPanel := oWizard:GetPanel( 5 )

	@ 25, 30 SAY "Importa็ใo" OF oPanel SIZE 140, 8 PIXEL   
	@ 40, 30 METER oMetGlob 	VAR nMetGlob ;
								TOTAL 100 ;
								SIZE 224,10 OF oPanel PIXEL UPDATE DESIGN ;
								BARCOLOR CLR_BLACK,CLR_WHITE ;
								COLOR CLR_WHITE,CLR_BLACK ;
							 	NOPERCENTAGE 

	
ACTIVATE WIZARD oWizard CENTER

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPCADPro บAutor  ณJonas L. Souza Jr   บ Data ณ  02/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImportacao do arquivo selecionado                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IMPCADPro( oMetGlob, nRadioArq, cFile, cDelim,cTipo )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aArea		:= GetArea()
Local lFirst	:= .T.
Local cLinha 	:= ""
Local aHeader	:= {}
Local nHdl    	:= 	0
Local cEnvServ	:= GetEnvServer()
Local cIniFile	:= GetADV97()
Local cEnd		:= GetPvProfString(cEnvServ,"StartPath","",cIniFile)   
Local cDtHr 	:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath		:= "\IMPORT\"
Local cTipoLog	:= "Import_"
Local cNomeLog	:=	cPath+cTipoLog+cDtHr+"_Log.txt"
Local cArq		:=	cEnd+cNomeLog              
Local cLin		:= ""   
Local cCdAlias	:= ""
Local nQtReg	:= 0
Local nQtNOk	:= 0
Local nQtOk		:= 0
Local aLog		:= {}
Local lGrava	:= (cTipo == "2")   
Local cRotina	:= ""
Local nCont		:= 0

MAKEDIR(cEnd+cPath)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao do arquivo para importacao             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !File(cFile) .OR. Empty(cFile)
	ApMsgStop("Problemas com arquivo informado!")
	RestArea(aArea)
	Return
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIdentifica Alias de importacao                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case nRadioArq == 1		// "Clientes (SA1)",;
		cCdAlias	:= "SA1"
		cRotina		:= "MATA030"

	Case nRadioArq == 2		// "Produtos (SB1)",;
		cCdAlias	:= "SB1"
		cRotina		:= "MATA010"

	Case nRadioArq == 3		// "Fornecedores (SA2)",;
		cCdAlias	:= "SA2"
		cRotina		:= "MATA020"

	Case nRadioArq == 4		// "Vendedores (SA3)",;
		cCdAlias	:= "SA3"
		cRotina		:= "MATA040"

	Case nRadioArq == 5		// "Contas a Receber - em aberto (SE1)",;
		cCdAlias	:= "SE1"
		cRotina		:= "FINA040"

	Case nRadioArq == 6		// "Contas a Pagar - em aberto (SE2)" 
		cCdAlias	:= "SE2"
		cRotina		:= "FINA050"

	Case nRadioArq == 7		// "Saldos Iniciais - Estoque (SB9)"
		cCdAlias	:= "SB9"
		cRotina		:= "MATA220"

	Case nRadioArq == 8		// "Saldos Lote/SubLote (SD5)"
		cCdAlias	:= "SD5"
		cRotina		:= "MATA390"

	OtherWise
		ApMsgStop("Nao existe tratamento para importa็ใo deste tipo de arquivo!")
		Return
EndCase



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicia Log                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aLog, Replicate( '=', 80 ) )
AAdd(aLog, 'INICIANDO O LOG - I M P O R T A C A O   D E   D A D O S' )
AAdd(aLog, Replicate( '-', 80 ) )
AAdd(aLog, 'DATABASE...........: ' + DtoC( dDataBase ) )
AAdd(aLog, 'DATA...............: ' + DtoC( Date() ) )
AAdd(aLog, 'HORA...............: ' + Time() )
AAdd(aLog, 'ENVIRONMENT........: ' + GetEnvServer() )
AAdd(aLog, 'PATCH..............: ' + GetSrvProfString( 'StartPath', '' ) )
AAdd(aLog, 'ROOT...............: ' + GetSrvProfString( 'RootPath', '' ) )
AAdd(aLog, 'VERSรO.............: ' + GetVersao() )
AAdd(aLog, 'MำDULO.............: ' + 'SIGA' + cModulo )
AAdd(aLog, 'EMPRESA / FILIAL...: ' + SM0->M0_CODIGO + '/' + SM0->M0_CODFIL )
AAdd(aLog, 'NOME EMPRESA.......: ' + Capital( Trim( SM0->M0_NOME ) ) )
AAdd(aLog, 'NOME FILIAL........: ' + Capital( Trim( SM0->M0_FILIAL ) ) )
AAdd(aLog, 'USUมRIO............: ' + SubStr( cUsuario, 7, 15 ) )
AAdd(aLog, 'TABELA IMPORT......: ' + cCdAlias )
AAdd(aLog, 'ARQUIVO IMPORT.....: ' + cFile )
AAdd(aLog, 'DELIMITADOR........: ' + cDelim )
AAdd(aLog, 'MODO PROCESSAMENTO.: ' + IIf(lGrava,"Atualizacao","Simulacao") )
AAdd(aLog, Replicate( ':', 80 ) )
AAdd(aLog, '' )

AAdd(aLog, "Import = INICIO - Data "+DtoC(dDataBase)+ " as "+Time() )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLeitura do arquivo                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FT_FUSE(cFile)
nTot := FT_FLASTREC()
nAtu := 0

oMetGlob:SetTotal(nTot)
CursorWait()     

FT_FGOTOP()
While !FT_FEOF()
	nAtu++
	oMetGlob:Set(nAtu)

	cLinha := LeLinha() //FT_FREADLN()
	
	If Empty(cLinha)
		FT_FSKIP()
		Loop
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento de colunas                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols := {}
	aCols := TrataCols(cLinha,cDelim)
	If lFirst
		aHeader := aClone(aCols)
		lFirst := .F.

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida nomes das colunas                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cCpos := ImpVldCols(cCdAlias,aHeader)
		If !Empty(cCpos)
			ApMsgStop("Problemas na estrutura do arquivo, faltam as seguintes colunas "+cCpos)
			Return
		EndIf

	Else

		nQtReg++


		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValidacao de campos obrigatorios                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cMsg := ImpObrigat(cCdAlias,aCols,aHeader)
		If !Empty(cMsg)
			AtuLog("NO MOT: CAMPOS OBRIGATORIOS - REGISTRO IGNORADO - "+cMsg,@aLog,nAtu)
			nQtNOk++
			FT_FSKIP()
			Loop
		EndIf
	
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณChamada de rotina automatica de inclusao                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lGrava
			aRet := {}
			aRet := ImpGrava(cCdAlias,cRotina,aCols,aHeader)
			If aRet[1]
				nQtOk++
				AtuLog("OK MOT:REGISTRO INCLUIDO"+aRet[2],@aLog,nAtu)
			
			Else
				AtuLog("NO MOT: PROBLEMAS NA GRAVACAO ROTINA AUTOMATICA - "+cRotina+" - "+aRet[2],@aLog,nAtu)
				nQtNOk++
			
			EndIF
		Else
			nQtOk++
			AtuLog("OK MOT:REGISTRO INCLUIDO",@aLog,nAtu)
		EndIf
	EndIf
	
	FT_FSKIP()
End
FT_FUSE()

AAdd(aLog, "Import = Total de Registros = "+ Alltrim(Str(nQtReg)))
AAdd(aLog, "Import = Registros Nao importados = "+ Alltrim(Str(nQtNOk)))
AAdd(aLog, "Import = Registros importados = "+ Alltrim(Str(nQtOk)))


AAdd(aLog, "Import = FIM Data "+DtoC(dDataBase)+ " as "+Time() )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFinaliza arquivo de Log                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHdl  := 	fCreate(cArq)
If nHdl == -1
	MsgAlert("O arquivo  "+cArq+" nao pode ser criado!","Atencao!")
	fClose(nHdl)
	fErase(cArq)
	RestArea(aArea)
 	Return()
EndIf

For nCont:=1 to Len(aLog)
	
	cLin += aLog[nCont] + CHR(13)+CHR(10)
	
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		fClose(nHdl)
	    fErase(cArq)
	    cLin:=""
		RestArea(aArea)
	    Return()
	EndIf
	
	cLin:=""
Next

fClose(nHdl)

ApMsgInfo("Verifique arquivo de log "+cArq)

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuLog    บAutor  ณJonas L. Souza Jr   บ Data ณ  07/20/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza Array de Log                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuLog(cMsg,aLog,nAtu)

AAdd(aLog, " Import = Linha "+StrZero(nAtu,12)+" = "+;
			" LOG = "+cMsg )
Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeLinha   บAutor  ณJonas L. Souza Jr   บ Data ณ  02/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento de leitura de linha TXT, principalmente para     บฑฑ
ฑฑบ          ณcasos de ultrapassar 1Kb por linha                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeLinha()
Local cLinhaTmp := ""
Local cLinhaM100 := ""

cLinhaTmp := FT_FReadLN()

If !Empty(cLinhaTmp)
	cIdent:= Substr(cLinhaTmp,1,1)
	If Len(cLinhaTmp) < 1023
		cLinhaM100 := cLinhaTmp
	Else
		cLinAnt := cLinhaTmp
		cLinhaM100 += cLinAnt
		Ft_FSkip()
		cLinProx:= Ft_FReadLN()
		If Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent
			While Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent .and. !Ft_fEof()
				cLinhaM100 += cLinProx
				Ft_FSkip()
				cLinProx := Ft_fReadLn()
				If Len(cLinProx) < 1023 .and. Substr(cLinProx,1,1) <> cIdent
					cLinhaM100 += cLinProx
				Endif
			Enddo
		Else
			cLinhaM100 += cLinProx
		Endif
	Endif
Endif

Return(cLinhaM100)





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTrataCols บAutor  ณJonas L. Souza Jr   บ Data ณ  07/20/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com as colunas da linha informada             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TrataCols(cLinha,cSep)
Local aRet 		:= {}
Local nPosSep	:= 0


nPosSep	:= At(cSep,cLinha)
While nPosSep <> 0
	AAdd(aRet, SubStr(cLinha,1,nPosSep-1)  )
	cLinha := SubStr(cLinha,nPosSep+1)
 	nPosSep	:= At(cSep,cLinha)
EndDo	
AAdd(aRet, cLinha )
Return aRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetCol    บAutor  ณJonas L. Souza Jr   บ Data ณ  07/20/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna conteudo de coluna especifica                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetCol(cCpo,aCols,aHeader)
Local cRet 	:= ""
Local nPos	:= 0
//Local aSX3Area	:= SX3->(GetArea())

nPos := AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim(cCpo)) })

If !Empty(nPos)
	If Upper(AllTrim(aCols[nPos])) <> "NULL"

		OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
		If Select("SX3TRB") > 0
			
			dbSelectArea('SX3TRB')
			SX3TRB->( dbSetOrder( 2 ) ) //ORDENA POR CAMPO
			SX3TRB->( dbGoTop(  ) )
			If SX3TRB->( dbSeek(cCpo) )
			
				If SX3TRB->&('X3_TIPO') == "D"
					cRet := StoD(AllTrim(aCols[nPos]))
				ElseIf SX3TRB->&('X3_TIPO') == "N"
					cRet := Val(AllTrim(aCols[nPos]))
				Else
					cRet := PadR(Upper(AllTrim(aCols[nPos])),TamSX3(cCpo)[1])
				EndIf
			Else
		   		cRet := Upper(AllTrim(aCols[nPos]))
			EndIf
						
			SX3TRB->( DbCloseArea() )
		EndIf
	EndIf
EndIf

//SX3->(RestArea(aSX3Area))
Return cRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpVldColsบAutor  ณJonas L. Souza Jr   บ Data ณ  02/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAnalise de colunas obrigatorias para cada alias             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpVldCols(cCdAlias,aHeader)
Local cRet 		:= ""
Local cFilSA1 	:= ""

Do Case
	Case cCdAlias == "SA1"
		
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_LOJA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_LOJA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_NOME")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_NOME"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_NREDUZ")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_NREDUZ"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_END")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_END"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_TIPO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_TIPO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_EST")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_EST"
		EndIf

	Case cCdAlias == "SB1"
		
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_COD")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"B1_COD"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_DESC")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"B1_DESC"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_TIPO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"B1_TIPO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_UM")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"B1_UM"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_LOCPAD")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"B1_LOCPAD"
		EndIf


	Case cCdAlias == "SA2"

		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A2_LOJA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A2_LOJA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A2_NOME")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A2_NOME"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A2_NREDUZ")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A2_NREDUZ"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A2_END")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"A2_END"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A2_EST")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"A2_EST"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A2_MUN")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"A2_MUN"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A2_TIPO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A2_TIPO"
		EndIf

	Case cCdAlias == "SA3"

		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A3_NOME")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A3_NOME"
		EndIf

	Case cCdAlias == "SE1"

		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_NUM")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_NUM"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_TIPO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_TIPO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_NATUREZ")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_NATUREZ"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_CLIENTE")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_CLIENTE"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_LOJA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_LOJA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_EMISSAO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_EMISSAO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VENCTO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_VENCTO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VENCREA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_VENCREA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VALOR")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_VALOR"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VLCRUZ")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E1_VLCRUZ"
		EndIf

	Case cCdAlias == "SE2"

		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_NUM")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_NUM"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_TIPO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_TIPO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_NATUREZ")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_NATUREZ"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_FORNECE")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_FORNECE"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_LOJA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_LOJA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_EMISSAO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_EMISSAO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VENCTO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_VENCTO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VENCREA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_VENCREA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VALOR")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_VALOR"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VLCRUZ")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"E2_VLCRUZ"
		EndIf

	Case cCdAlias == "SB9"

		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B9_COD")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"B9_COD"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B9_LOCAL")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"B9_LOCAL"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B9_QINI")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"B9_QINI"
		EndIf

	Case cCdAlias == "SD5"

		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("D5_PRODUTO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"D5_PRODUTO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("D5_LOCAL")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"D5_LOCAL"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("D5_DATA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"D5_DATA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("D5_QUANT")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"D5_QUANT"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("D5_LOTECTL")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"D5_LOTECTL"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("D5_DTVALID")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"D5_DTVALID"
		EndIf

EndCase

Return cRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpObrigatบAutor  ณJonas L. Souza JR   บ Data ณ  02/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida preenchimento/conteudo de campos obrigatorios        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpObrigat(cCdAlias,aCols,aHeader)
Local cRet 		:= ""

Do Case
	Case cCdAlias == "SA1"
		If Empty(RetCol("A1_LOJA",aCols,aHeader))
			cRet += " / Coluna A1_LOJA esta vazia! "
		EndIf
		If Empty(RetCol("A1_NOME",aCols,aHeader))
			cRet += " / Coluna A1_NOME esta vazia! "
		EndIf
		If Empty(RetCol("A1_NREDUZ",aCols,aHeader))
			cRet += " / Coluna A1_NREDUZ esta vazia! "
		EndIf
		If Empty(RetCol("A1_END",aCols,aHeader))
			cRet += " / Coluna A1_END esta vazia! "
		EndIf
		If Empty(RetCol("A1_TIPO",aCols,aHeader))
			cRet += " / Coluna A1_TIPO esta vazia! "
		EndIf
		If Empty(RetCol("A1_EST",aCols,aHeader))
			cRet += " / Coluna A1_EST esta vazia! "
		EndIf


	Case cCdAlias == "SB1"
		If Empty(RetCol("B1_COD",aCols,aHeader))
			cRet += " / Coluna B1_COD esta vazia! "
		EndIf
		If Empty(RetCol("B1_DESC",aCols,aHeader))
			cRet += " / Coluna B1_DESC esta vazia! "
		EndIf
		If Empty(RetCol("B1_TIPO",aCols,aHeader))
			cRet += " / Coluna B1_TIPO esta vazia! "
		EndIf
		If Empty(RetCol("B1_UM",aCols,aHeader))
			cRet += " / Coluna B1_UM esta vazia! "
		EndIf
		If Empty(RetCol("B1_LOCPAD",aCols,aHeader))
			cRet += " / Coluna B1_LOCPAD esta vazia! "
		EndIf


	Case cCdAlias == "SA2"
		If Empty(RetCol("A2_LOJA",aCols,aHeader))
			cRet += " / Coluna A2_LOJA esta vazia! "
		EndIf
		If Empty(RetCol("A2_NOME",aCols,aHeader))
			cRet += " / Coluna A2_NOME esta vazia! "
		EndIf
		If Empty(RetCol("A2_NREDUZ",aCols,aHeader))
			cRet += " / Coluna A2_NREDUZ esta vazia! "
		EndIf
		If Empty(RetCol("A2_END",aCols,aHeader))
			cRet += " / Coluna A2_END esta vazia! "
		EndIf
		If Empty(RetCol("A2_EST",aCols,aHeader))
			cRet += " / Coluna A2_EST esta vazia! "
		EndIf
		If Empty(RetCol("A2_MUN",aCols,aHeader))
			cRet += " / Coluna A2_MUN esta vazia! "
		EndIf
		If Empty(RetCol("A2_TIPO",aCols,aHeader))
			cRet += " / Coluna A2_TIPO esta vazia! "
		EndIf

	Case cCdAlias == "SA3"
		If Empty(RetCol("A3_NOME",aCols,aHeader))
			cRet += " / Coluna A3_NOME esta vazia! "
		EndIf


	Case cCdAlias == "SE1"

		If Empty(RetCol("E1_NUM",aCols,aHeader))
			cRet += " / Coluna E1_NUM esta vazia! "
		EndIf
		If Empty(RetCol("E1_TIPO",aCols,aHeader))
			cRet += " / Coluna E1_TIPO esta vazia! "
		EndIf
		If Empty(RetCol("E1_NATUREZ",aCols,aHeader))
			cRet += " / Coluna E1_NATUREZ esta vazia! "
		EndIf
		If Empty(RetCol("E1_CLIENTE",aCols,aHeader))
			cRet += " / Coluna E1_CLIENTE esta vazia! "
		EndIf
		If Empty(RetCol("E1_LOJA",aCols,aHeader))
			cRet += " / Coluna E1_LOJA esta vazia! "
		EndIf
		If Empty(RetCol("E1_EMISSAO",aCols,aHeader))
			cRet += " / Coluna E1_EMISSAO esta vazia! "
		EndIf
		If Empty(RetCol("E1_VENCTO",aCols,aHeader))
			cRet += " / Coluna E1_VENCTO esta vazia! "
		EndIf
		If Empty(RetCol("E1_VENCREA",aCols,aHeader))
			cRet += " / Coluna E1_VENCREA esta vazia! "
		EndIf
		If Empty(RetCol("E1_VALOR",aCols,aHeader))
			cRet += " / Coluna E1_VALOR esta vazia! "
		EndIf
		If Empty(RetCol("E1_VLCRUZ",aCols,aHeader))
			cRet += " / Coluna E1_VLCRUZ esta vazia! "
		EndIf


	Case cCdAlias == "SE2"
		If Empty(RetCol("E2_NUM",aCols,aHeader))
			cRet += " / Coluna E2_NUM esta vazia! "
		EndIf
		If Empty(RetCol("E2_TIPO",aCols,aHeader))
			cRet += " / Coluna E2_TIPO esta vazia! "
		EndIf
		If Empty(RetCol("E2_NATUREZ",aCols,aHeader))
			cRet += " / Coluna E2_NATUREZ esta vazia! "
		EndIf
		If Empty(RetCol("E2_FORNECE",aCols,aHeader))
			cRet += " / Coluna E2_FORNECE esta vazia! "
		EndIf
		If Empty(RetCol("E2_LOJA",aCols,aHeader))
			cRet += " / Coluna E2_LOJA esta vazia! "
		EndIf
		If Empty(RetCol("E2_EMISSAO",aCols,aHeader))
			cRet += " / Coluna E2_EMISSAO esta vazia! "
		EndIf
		If Empty(RetCol("E2_VENCTO",aCols,aHeader))
			cRet += " / Coluna E2_VENCTO esta vazia! "
		EndIf
		If Empty(RetCol("E2_VENCREA",aCols,aHeader))
			cRet += " / Coluna E2_VENCREA esta vazia! "
		EndIf
		If Empty(RetCol("E2_VALOR",aCols,aHeader))
			cRet += " / Coluna E2_VALOR esta vazia! "
		EndIf
		If Empty(RetCol("E2_VLCRUZ",aCols,aHeader))
			cRet += " / Coluna E2_VLCRUZ esta vazia! "
		EndIf


	Case cCdAlias == "SB9"                       
		If Empty(RetCol("B9_COD",aCols,aHeader))
			cRet += " / Coluna B9_COD esta vazia! "
		EndIf
		If Empty(RetCol("B9_LOCAL",aCols,aHeader))
			cRet += " / Coluna B9_LOCAL esta vazia! "
		EndIf

EndCase

Return cRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpGrava  บAutor  ณJonas L. Souza Jr   บ Data ณ  02/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada da rotina automatica de gravacao                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpGrava(cCdAlias,cRotina,aCols,aHeader)
Local nX			:= 0
Local cRotAuto		:= ""
Local lOk			:= .F.
Local cMsg			:= ""
Local lGeraNumSeq	:= .T.
Local cArqErro		:= "ERRO_AUTO.TXT"
Local lTemFilial	:= .F.
Local cCpoFilial 	:= IIf( SubStr(cCdAlias,1,1) == "S", SubStr(cCdAlias,2,2), cCdAlias) + "_FILIAL"
Local cFilAlias		:= xFilial(cCdAlias)
Private lMsHelpAuto := .T.                                         
Private lMsErroAuto := .F.    
Private aReg		:= {}


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta array com os campos do registro                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX:=1 to Len(aHeader)
	AAdd(aReg, {	Upper(Alltrim(aHeader[nX]))					    ,;
					RetCol(Alltrim(aHeader[nX]),aCols,aHeader)		,;
					Nil} )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se possui campo sequencial informado                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cCdAlias == "SA1" .AND. Upper(Alltrim(aHeader[nX])) == "A1_COD" .AND. !Empty(RetCol(Alltrim(aHeader[nX]),aCols,aHeader))
		lGeraNumSeq	:= .F.
	EndIf
	If cCdAlias == "SA2" .AND. Upper(Alltrim(aHeader[nX])) == "A2_COD" .AND. !Empty(RetCol(Alltrim(aHeader[nX]),aCols,aHeader))
		lGeraNumSeq	:= .F.
	EndIf
	If cCdAlias == "SA3" .AND. Upper(Alltrim(aHeader[nX])) == "A3_COD" .AND. !Empty(RetCol(Alltrim(aHeader[nX]),aCols,aHeader))
		lGeraNumSeq	:= .F.
	EndIf


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se informou filial no arquivo              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Upper(Alltrim(aHeader[nX])) == cCpoFilial
		lTemFilial := .T.
    EndIf
Next

If lGeraNumSeq
	If cCdAlias == "SA1"
		AAdd(aReg, {	"A1_COD"					    ,;
						GetSxeNum("SA1","A1_COD")		,;
						Nil} )
//		ConfirmSx8()
	EndIf
	If cCdAlias == "SA2"
		AAdd(aReg, {	"A2_COD"					    ,;
						GetSxeNum("SA2","A2_COD")		,;
						Nil} )
		ConfirmSx8()
	EndIf
	If cCdAlias == "SA3"
		AAdd(aReg, {	"A3_COD"					    ,;
						GetSxeNum("SA3","A3_COD")		,;
						Nil} )
		ConfirmSx8()
	EndIf
EndIf


If !lTemFilial
	DbSelectArea(cCdAlias)
	AAdd(aReg, {	cCpoFilial					    ,;
					cFilAlias						,;
					Nil} )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChamada da rotina automatica                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea(cCdAlias)

cRotAuto := "MSExecAuto({|x,y| "+cRotina+"(x,y)},aReg,3)"
&cRotAuto

If lMsErroAuto
	MostraErro( GetSrvProfString("Startpath","") , cArqErro )
	cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro )
Else
	lOk := .T.
EndIf

Return {lOk, cMsg }



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpChgRadioบAutor ณJonas L. Souza Jr   บ Data ณ  02/16/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณtratamento de mudanca to tipo de arquivo para importacao    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpChgRadio(nRadioArq,cNmAlias)
Do Case
	Case nRadioArq == 1		
		cNmAlias := "Clientes (SA1)"
	Case nRadioArq == 2		 
		cNmAlias := "Produtos (SB1)"
	Case nRadioArq == 3		 
		cNmAlias := "Fornecedores (SA2)"
	Case nRadioArq == 4		 
		cNmAlias := "Vendedores (SA3)"
	Case nRadioArq == 5		 
		cNmAlias := "Contas a Receber - em aberto (SE1)"
	Case nRadioArq == 6		 
		cNmAlias := "Contas a Pagar - em aberto (SE2)" 
	Case nRadioArq == 7
		cNmAlias := "Saldos Iniciais - Estoque (SB9)"
	Case nRadioArq == 8
		cNmAlias := "Saldos Lote/SubLote (SD5)"
	OtherWise	
		cNmAlias := "Processamento nao implementado" 
EndCase

Return