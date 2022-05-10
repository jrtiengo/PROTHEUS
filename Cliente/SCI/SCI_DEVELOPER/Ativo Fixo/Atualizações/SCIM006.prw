#Include "Totvs.ch"
#Include "Fileio.ch"

//Colunas ARQUIVO TXT
#Define C_N1_CHAPA		01
//#Define C_N1_DESCRIC	02
#Define C_N1_QUANTD		02
#Define C_N1_LOCAL		03
#Define C_N1_DATAINV	04
#Define SEPARADOR		";"

#Define TAM_LINHA 		04

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIM006  ³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Importacao de Bens Inventariados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³u_SciM006()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especifico Sport Club Internacional                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SCIM006()

	Local oProcess
	Local cCadastro		:= "Importacao de Bens Inventariados"
	Local cDescRot		:= ""
	Local cDirOrigem	:= ""
	Local aInfoCustom	:= {}
	Local aTabelas		:= { "SN1","SN3","SNL" }
	Local bProcess		:= {||}
	Local cPerg			:= PadR( "SCIM006", 10 /*TamSx3("X1_GRUPO")[1]*/ , "" )           
	
	CriaSx1(cPerg)

	Pergunte(cPerg,.F.)

	aAdd( aInfoCustom, { "Cancelar",            	{ |oPanelCenter| oPanelCenter:oWnd:End() }, "CANCEL"	})

	bProcess := { |oProcess| M06Executa(oProcess, AllTrim( MV_PAR01 )) }

	cDescRot := " Este programa tem por objetivo importar bens inventariados"
	cDescRot += " apartir de um arquivo texto."

	oProcess := tNewProcess():New( "SCIM006",cCadastro,bProcess,cDescRot,cPerg,aInfoCustom, .T.,5, "", .T. )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M06Executa³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa o processo de importacao em arquivo texto           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M06Executa(ExpO1, ExpC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto regua de processamento                        ³±±
±±³          ³ExpC1: Diretorio informado na tela de parametros            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M06Executa( oProcess, cDir )

	Local aArq      := {}
	Local aRet      := {}
	Local cArq      := ""
	Local cDirArq   := ""
	Local cTrbSn1	:= ""
	Local cAliasSN1	:= GetNextAlias()
	Local dDataInv	:= Date()
	Local nArq      := 0
	Local nPosBarra := 0
	Local nLinha    := 0
	Local lOk       := .T.

	If Empty(cDir) // campo do arquivo vazio

		cMsg := "O parametro 'Pasta ou Arquivo' precisa ser informado." + CRLF
		cMsg += "Verifique seus parametros e execute novamente a rotina."		
		Aviso( "M06EXECUTA",cMsg,{"Ok"},1 )
		
		lOk := .F.
		
	EndIf
	
	If lOk
		
		cDir := Upper( cDir )
	
		If Right( cDir,1 ) != "\" // nao e um diretorio
		
			aArq := Directory( cDir ) // [1]=cNome, [2]=nTamanho, [3]=dData, [4]=cHora, [5]=cAtributos		
			nPosBarra := RAt( "\",cDir ) // pega a posicao da ultima barra
			cDirArq := SubStr( cDir, 1, nPosBarra ) // pega o diretorio, sem o arquivo
			
		Else
		
			aArq := Directory(cDir + "*.txt")
			cDirArq := cDir
			
		EndIf
		
		If Len( aArq ) = 0 // diretorio inconsistente
		
			cMsg := "Nao ha arquivo a importar." + CRLF
			cMsg += "Verifique seus parametros e execute novamente a rotina."		
			Aviso( "M06EXECUTA",cMsg,{"Ok"},1 )
		
			lOk = .F.
		
		EndIf
		
	EndIf
	
	// se for arquivo unico e nao for ".txt"...
	If Len( aArq ) = 1 .And. RAt( ".TXT",aArq[1,1] ) <= 0
		aSize( aArq, 0 )
	EndIf
	
	If lOk
	
		cTrbSn1 := M06CriaTrb( "SN1" ) // Criacao do arquivo temporario da tabela SN1
		
		//dbUseArea( .T.,"DBFCDX",cTrbSn1,cAliasSN1,.T.,.F. )
		dbUseArea( .T.,"TOPCONN",cTrbSn1,cAliasSN1,.T.,.F. )
		
		dbSelectArea( cAliasSN1 )
		( cAliasSN1 )->( dbGoTop() )
		
		oProcess:SaveLog( "Inicio da Execucao" )
		oProcess:SetRegua1( Len(aArq) )
		
		For nArq := 1 To Len( aArq )
			
			cArq := cDirArq + aArq[nArq,1]
			
			oProcess:IncRegua1( "Arquivo... " + aArq[nArq,1] )
			
			If FT_FUse(cArq) >= 0 // se abriu o arquivo sem falhas
			
				oProcess:SetRegua2( FT_FLastRec() )
			
				FT_FGoTop() // posiciona a linha do arquivo no inicio
				
				While ! FT_FEof()
					
					nLinha++
					
					oProcess:SaveLog( "Leitura do Arquivo" )
					oProcess:IncRegua2( "Lendo linha... " + cValToChar(nLinha) )
					
					aLinha := Separa( AllTrim( Ft_FReadLn() ),SEPARADOR,.T. ) // divide os registros da linha em um array

					aRet := M06ValLin(aLinha, nLinha)
					
					// Aqui so ira gravar se todos os campos na linha atual foram informados
					If aRet[1]
						
						dDataInv := Iif( At("/",aLinha[C_N1_DATAINV]) > 0,CToD(aLinha[C_N1_DATAINV]), SToD(aLinha[C_N1_DATAINV]) )						
						
						RecLock( cAliasSN1 ,.T.) 
						( cAliasSN1 )->N1_CHAPA		:= aLinha[C_N1_CHAPA]
						//( cAliasSN1 )->N1_DESCRIC	:= aLinha[C_N1_DESCRIC]
						( cAliasSN1 )->N1_QUANTD	:= Val( aLinha[C_N1_QUANTD] )
						( cAliasSN1 )->N1_LOCAL		:= aLinha[C_N1_LOCAL]
						( cAliasSN1 )->N1_DATAINV	:= dDataInv
						MsUnLock()
						
					Else
						// Para a execucao no primeiro erro de estrutura					
						oProcess:SaveLog( aRet[2] )
						Aviso("M06EXECUTA",aRet[2],{"Ok"},1)
						Exit
										
					EndIf
					
					FT_FSkip()
					
				EndDo
				
				FT_FUse() // fecha o arquivo
				
			EndIf
		
		Next nArq	
		
		If Len( aArq ) <= 0
		
			cMsg := "Não foi possivel ler o arquivo txt." + CRLF
			cMsg += "Verifique seus parametros e execute novamente a rotina."
			Aviso("M06EXECUTA",cMsg,{"Ok"},1)
			
			oProcess:SaveLog( cMsg )
			
			lOk := .F.
			
		EndIf	
			
		If lOk
			
			M06Importa( oProcess, cAliasSN1 )
			
		EndIf
		
		( cAliasSN1 )->( dbCloseArea() )
		
		oProcess:SaveLog("Fim da Execucao")
		
		//MsErase( AllTrim(cTrbSn1) + GetDbExtension(),,"DBFCDX" )
		MsErase( AllTrim(cTrbSn1) + GetDbExtension(),,"TOPCONN" )
		
	EndIf	
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M06Importa³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza a importacao dos bens                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M06Importa(ExpO1, ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto regua de processamento                        ³±±
±±³          ³ExpC2: Area temporaria em uso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M06Importa(oProcess, cAliasSN1)

	Local cTrbLog	:= M06CriaTrb( "LOG" ) // Criacao do arquivo temporario de Logs
	Local cAliasLog	:= GetNextAlias()
	Local aLog		:= {"","","",Date(),"",""}
	Local lImprime	:= .F.
	Local lExec		:= .T.

	Private lMsErroAuto := .F.

	( cAliasSN1 )->( dbGoTop() )

	//dbUseArea( .T.,"DBFCDX",cTrbLog,cAliasLog,.T.,.F. )
	dbUseArea( .T.,"TOPCONN",cTrbLog,cAliasLog,.T.,.F. )
	dbSelectArea( cAliasLog )
	( cAliasLog )->( dbGoTop() )

	While ( cAliasSN1 )->( !EoF() )
	
		oProcess:SaveLog("Importando inventário...")
	
		// Guarda as informacoes para registrar o log
		aLog[1] := ( cAliasSN1 )->N1_CHAPA
	   //	aLog[2] := ( cAliasSN1 )->N1_DESCRIC
		aLog[3] := ( cAliasSN1 )->N1_LOCAL	
		aLog[4] := ( cAliasSN1 )->N1_DATAINV	
		aLog[5] := ""
		aLog[6] := ""
		
		dbSelectArea("SN1")
		dbSetOrder(2) // N1_FILIAL+N1_CHAPA		
		If dbSeek( xFilial("SN1") + ( cAliasSN1 )->N1_CHAPA )
			
			dbSelectArea("SN3")
			dbSetOrder(1) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
			dbSeek( xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM )
			
			If !( cAliasSN1 )->N1_LOCAL $ SN1->N1_LOCAL
				
				dbSelectArea("SNL")
				dbSetOrder(1) // NL_FILIAL+NL_CODIGO
				dbSeek( xFilial("SNL") + ( cAliasSN1 )->N1_LOCAL )
				
				If SNL->NL_CODCC == SN3->N3_CCUSTO
					aLog[6] := "LO"	// Alterado Somente Local			
				Else
					aLog[6] := "LC" // Alterado Local e CC		
				EndIf
				
				lExec := M06Transf( ( cAliasSN1 )->N1_LOCAL, SNL->NL_CODCC )
				
				aLog[5] := SNL->NL_CODCC			
				SNL->( dbCloseArea() )
				
				lImprime := .T.
				
			EndIf
			
			If lExec
				
				RecLock( "SN1" ,.F.)
					SN1->N1_DATAINV	:= ( cAliasSN1 )->N1_DATAINV
				MsUnLock()
				
				While SN3->( !EoF() ) .And. SN3->N3_FILIAL == xFilial("SN3") .And. ;
					  						SN3->N3_CBASE  == SN1->N1_CBASE	 .And. ;
					  						SN3->N3_ITEM   == SN1->N1_ITEM
				
					RecLock( "SN3" ,.F.)
						SN3->N3_DATAINV	:= ( cAliasSN1 )->N1_DATAINV
					MsUnLock()				
					
					SN3->( dbSkip() )
				
				EndDo
			
			EndIf
			
			SN3->( dbCloseArea() )
			
		Else
		
			oProcess:SaveLog("Imobilizado com chapa " + ( cAliasSN1 )->N1_CHAPA + " não cadastrado.")
			aLog[6] := "NA" // Nao Alterado
			lImprime := .T.
			
		EndIf
		
		// Apenas grava log se ha status registrado
		If aLog[6] != ""
			M06GravLog( cAliasLog, aLog )
		EndIf
		
		( cAliasSN1 )->( dbSkip() )
	
	EndDo
	
	SN1->( dbCloseArea() )

	If lMsErroAuto
		MostraErro()
		RollbackSX8()
	Else
		If lImprime // se ha log a ser impresso
			If MsgYesNo( "Processamento concluído." + CRLF + "Deseja imprimir o relatorio de Itens a transferir?", "Impressão de Itens a Transferir" )
				M06ImprLog( cAliasLog )
			EndIf
		Else	
			If lExec // se nao ha log, mas gravou data de inventario
				cMsg := "Não há bens a serem transferidos."
				Aviso("M06IMPORTA",cMsg,{"Ok"},1)
				
				oProcess:SaveLog( cMsg )
			EndIf
		EndIf	
	EndIf
	
	( cAliasLog )->( dbCloseArea() )
	//MsErase( AllTrim(cTrbLog) + GetDbExtension(),,"DBFCDX" )
	MsErase( AllTrim(cTrbLog) + GetDbExtension(),,"TOPCONN" )
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M06Transf ³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Transfere o bem pela rotina automatica ATFA060              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M06Transf(ExpC1, ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: local do bem, informada no arquivo                   ³±±
±±³          ³ExpC2: centro de custo contido na tabela SNL                ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M06Transf( cLocal, cCCusto )

	Local aDadosAuto := {}
	Local lRetorno	 := .T.   
		Local aParam060   := {}
	AADD(aParam060, { "MV_PAR01", 2                                                                    , Nil } )
	AADD(aParam060, { "MV_PAR02", 2                                                                    , Nil } )
	AADD(aParam060, { "MV_PAR03", 2                                                                    , Nil } )
	AADD(aParam060, { "MV_PAR04", 2                                                                    , Nil } )
	AADD(aParam060, { "MV_PAR05", 1                                                                    , Nil } )

	 //Forca atualizacao do campo N1_LOCAL
	//RecLock( "SN1" ,.F.)
	  //	SN1->N1_LOCAL := cLocal
	//MsUnLock()	

   //	aDadosAuto:= {	{"N3_CBASE"		, SN1->N1_CBASE		, Nil},; // Codigo base do ativo //"0000000002"
//					{"N3_ITEM"    	, SN1->N1_ITEM 		, Nil},; // Item sequencial do codigo bas do ativo //"0001"
 //					{"N3_TIPO"    	, SN3->N3_TIPO 		, Nil},; // Item sequencial do codigo bas do ativo //"0001"
 //					{"N3_BAIXA"    	, SN3->N3_BAIXA		, Nil},; // Item sequencial do codigo bas do ativo //"0001"
 //					{"N4_DATA" 	  	, dDataBase			, Nil},; // Data de aquisicao do ativo
 //					{"N3_CCUSTO"  	, cCCusto			, Nil},; // Centro de Custo de Despesa
 //					{"N3_CUSTBEM" 	, cCCusto			, Nil},; // Centro de Custo da Conta do Bem
 //					{"N1_LOCAL"   	, cLocal		  	, Nil},; // Localizacao do Bem
 //					{"N1_GRUPO"   	, SN1->N1_GRUPO	  	, Nil},; // Localizacao do Bem
 //					{"N3_FILIAL"  	, xFilial("SN3") 	, Nil}}

  //	MSExecAuto({|x, y, z| AtfA060(x, y, z)},aDadosAuto, "A", aParam060)

	If lMsErroAuto
		lRetorno := .F.
	EndIf

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M06ValLin ³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida a estrutura e os campos informados na linha do txt   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A12ValLin(ExpA1, ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array contendo os campos da linha no arquivo         ³±±
±±³          ³ExpN1: Controlador da linha posicionada no arquivo          ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: [1] - .T. Linha com estrutura valida                 ³±±
±±³          ³             .F. Linha com estrutura invalida               ³±±
±±³          ³       [2] - Mensagem de retorno da validacao               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M06ValLin( aLinha, nLinha )

	Local aRet   := { .T.,"" }

	If Len( aLinha ) = TAM_LINHA
		
		If Empty( aLinha[C_N1_CHAPA		] )	.Or.;
		   Empty( aLinha[C_N1_QUANTD	] ) .Or.;
		   Empty( aLinha[C_N1_LOCAL		] )	.Or.;
		   Empty( aLinha[C_N1_DATAINV	] )	   
		   
		   aRet[2] := "Existem campos obrigatorios que nao foram informados na linha " + CValToChar(nLinha) + "." + CRLF +;
		              "Verifique os campos que faltam no arquivo."
		   
		   aRet[1] := .F.
		    
		EndIf
	
	Else
	
		   aRet[2] := "Estrutura inconsistente na linha " + CValToChar(nLinha) + "." + CRLF +;
		              "Verifique o layout do arquivo."
		   
		   aRet[1] := .F.	
		
	EndIf
	
Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M06CriaTrb³ Autor ³Giovanni Melo          ³ Data ³12/05/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma area temporaria                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M06CriaTrb( ExpC1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Prefixo do Arquivo Temporario                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Arquivo temporario criado                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M06CriaTrb( cPrefixo )

	Local cArqTrab	:= ""
	Local aCabec	:= {}
	
	If "SN1" $ cPrefixo
	
		aAdd( aCabec,{ "N1_CHAPA"	, TamSx3( "N1_CHAPA" )	[3]	, TamSx3( "N1_CHAPA" )	[1]	, TamSx3( "N1_CHAPA" )	[2]})
	   //	aAdd( aCabec,{ "N1_DESCRIC"	, TamSx3( "N1_DESCRIC" )[3]	, TamSx3( "N1_DESCRIC" )[1]	, TamSx3( "N1_DESCRIC" )[2]})
		aAdd( aCabec,{ "N1_QUANTD"	, TamSx3( "N1_QUANTD" )	[3]	, TamSx3( "N1_QUANTD" )	[1]	, TamSx3( "N1_QUANTD" )	[2]})
		aAdd( aCabec,{ "N1_LOCAL"	, TamSx3( "N1_LOCAL" )	[3]	, TamSx3( "N1_LOCAL" )	[1]	, TamSx3( "N1_LOCAL" )	[2]})
		aAdd( aCabec,{ "N1_DATAINV"	, TamSx3( "N1_DATAINV" )[3]	, TamSx3( "N1_DATAINV" )[1]	, TamSx3( "N1_DATAINV" )[2]})	
	
	ElseIf "LOG" $ cPrefixo

		aAdd( aCabec,{ "N1_CHAPA"	, TamSx3( "N1_CHAPA" )	[3]	, TamSx3( "N1_CHAPA" )	[1]	, TamSx3( "N1_CHAPA" )	[2]})
	   //	aAdd( aCabec,{ "N1_DESCRIC"	, TamSx3( "N1_DESCRIC" )[3]	, TamSx3( "N1_DESCRIC" )[1]	, TamSx3( "N1_DESCRIC" )[2]})
		aAdd( aCabec,{ "N1_LOCAL"	, TamSx3( "N1_LOCAL" )	[3]	, TamSx3( "N1_LOCAL" )	[1]	, TamSx3( "N1_LOCAL" )	[2]})
		aAdd( aCabec,{ "N1_DATAINV"	, TamSx3( "N1_DATAINV" )[3]	, TamSx3( "N1_DATAINV" )[1]	, TamSx3( "N1_DATAINV" )[2]})		
		aAdd( aCabec,{ "NL_CODCC"	, TamSx3( "NL_CODCC" )[3]	, TamSx3( "NL_CODCC" )	[1] , TamSx3( "NL_CODCC" )	[2]})
		aAdd( aCabec,{ "STATUS"		,"C", 02, 00})
		
	EndIf	
	
	cArqTrab := cPrefixo + "_" + CriaTrab(,.F.)
	//MsCreate( cArqTrab,aCabec,"DBFCDX" )
	MsCreate( cArqTrab,aCabec,"TOPCONN" )

Return( cArqTrab )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M06GravLog³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava o log de processos em uma area temporaria             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M06GravLog(ExpC1, ExpA2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Area temporaria em uso                               ³±± 
±±³          ³ExpA2: Array com informacoes do log                         ³±±
±±³          ³       [1] - Chapa do Bem                                   ³±±
±±³          ³       [2] - Descricao do Bem                               ³±±
±±³          ³       [3] - Local do Bem                                   ³±±
±±³          ³       [4] - Data do Inventario                             ³±±
±±³          ³       [5] - Codigo do Centro de Custo                      ³±±
±±³          ³       [6] - Status de Importacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M06GravLog( cAliasLog, aLog )

	RecLock( cAliasLog ,.T.)						
		( cAliasLog )->N1_CHAPA		:= aLog[1] // Chapa do bem
	   //	( cAliasLog )->N1_DESCRIC	:= aLog[2] // Descricao do bem
		( cAliasLog )->N1_LOCAL		:= aLog[3] // Local
		( cAliasLog )->N1_DATAINV	:= aLog[4] // Data do Inventario
		( cAliasLog )->NL_CODCC		:= aLog[5] // Centro de Custo
		( cAliasLog )->STATUS		:= aLog[6] // Status da importacao
	MsUnLock()	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M06ImprLog³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Emite um relatorio com o log de processos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M06ImprLog(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Aream temporaria em uso                              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M06ImprLog( cAliasLog )

	Local oReport
	
	oReport := ReportDef(cAliasLog)
	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ReportDef ³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Definicoes do relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportDef(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Aream temporaria em uso                              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef( cAliasLog )

	Local oReport
	Local aOrdem  := {}
	Local cTitulo := "Impressão de Itens a Transferir"
	Local cDescri := "Este relatório tem a finalidade de imprimir o Itens a Transferir."
	Local cReport := "SCIM006"
	
	oReport := TReport():New( cReport, cTitulo, /*cPerg*/, { |oReport| Imprime( oReport, cAliasLog ) }, cDescri )
	oReport:SetPortrait()
	oReport:DisableOrientation()
	oReport:HideParamPage()
	oReport:SetTotalInLine(.F.)
	oReport:SetLineHeight(50)
	oReport:nFontBody := 09
	oReport:lBold := .F.
	
	oSection := TRSection():New( oReport, "Campos SN1", { "SN1" }, aOrdem )
	oSection:SetLeftMargin(2)
	
	TRCell():New(oSection,"N1_CHAPA"  	,"SN1"	,"Chapa"		,PesqPict("SN1","N1_CHAPA")		,TamSx3( "N1_CHAPA" )	[1]+1,,)
   //	TRCell():New(oSection,"N1_DESCRIC" 	,"SN1"	,"Descrição"	,PesqPict("SN1","N1_DESCRIC")	,TamSx3( "N1_DESCRIC" )	[1]+1,,)
	TRCell():New(oSection,"N1_LOCAL"	,"SN1"	,"Local"		,PesqPict("SN1","N1_LOCAL")		,TamSx3( "N1_LOCAL" )	[1]+3,,)
	TRCell():New(oSection,"N1_DATAINV"	,"SN1"	,"Dt.Invent."	,PesqPict("SN1","N1_DATAINV")	,TamSx3( "N1_DATAINV" )	[1]+5,,)
	TRCell():New(oSection,"NL_CODCC"   	,"SNL"	,"C/C"			,PesqPict("SNL","NL_CODCC")		,TamSx3( "NL_CODCC" )	[1]+1,,)
	TRCell():New(oSection,"STATUS" 		,""		,"Alteração"	,								,20						   	 ,,)
	
Return( oReport )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Imprime   ³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao do relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Imprime(ExpO1, ExpC2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto relatorio                                     ³±± 
±±³          ³ExpC2: Area temporaria em uso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imprime( oReport, cAliasLog )

	Local oSection := oReport:Section(1)
	Local cStatus  := ""

	dbSelectArea( cAliasLog )
	( cAliasLog )->( dbGoTop() )	
	
	oSection:Init()
	
	While ( cAliasLog )->( !EoF() )
		
		Do Case
			Case "NA" $ ( cAliasLog )->STATUS
				cStatus := "Não Alterado"
			Case "LO" $ ( cAliasLog )->STATUS
				cStatus := "Somente Local"
			Case "LC" $ ( cAliasLog )->STATUS
				cStatus := "Local e C/C"
		EndCase	
			
		oSection:Cell("N1_CHAPA")	:SetBlock({ || AllTrim(( cAliasLog )->N1_CHAPA) } )
	   //	oSection:Cell("N1_DESCRIC") :SetBlock({ || AllTrim(( cAliasLog )->N1_DESCRIC) } )
		oSection:Cell("N1_LOCAL")	:SetBlock({ || AllTrim(( cAliasLog )->N1_LOCAL) } )
		oSection:Cell("N1_DATAINV")	:SetBlock({ ||    DToC(( cAliasLog )->N1_DATAINV) } )
		oSection:Cell("NL_CODCC")	:SetBlock({ || AllTrim(( cAliasLog )->NL_CODCC) } )
		oSection:Cell("STATUS")		:SetBlock({ || cStatus } )
		oSection:PrintLine()
		
		oReport:SkipLine()
		
		( cAliasLog )->( dbSkip() )
				
	EndDo

	oSection:Finish()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaSx1   ³ Autor ³Giovanni Melo          ³ Data ³23/10/2015³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Criacao do grupo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CriaSx1(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Grupo de perguntas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaSx1( cPerg )

	Local aP      := {}
	Local aHelp   := {}
	Local nI      := 0
	Local cSeq    := ""
	Local cMvCh   := ""
	Local cMvPar  := ""
	
	//			Texto Pergunta	       Tipo 	Tam 	  Dec  	G=get ou C=Choice  	Val   	F3		Def01 	  Def02 	 Def03   Def04   Def05
	aAdd( aP,{	"Pasta ou Arquivo ?",	"C",	99,			0,		"G",			"",	 "DIR",		   "",		"",			"",		"",		""})
	
    //           012345678912345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890 
    //                    1         2         3         4         5         6         7         8         9        10        11        12   
	aAdd( aHelp,{"Informe a pasta ou apenas o arquivo,","para importacao."                          ,"Ex.: c:\TXT\ ou c:\TXT\bens_atf.txt"})

	For nI := 1 To Len( aP )
	
		cSeq	:= StrZero( nI,2,0 )
		cMvPar	:= "mv_par" + cSeq
		cMvCh	:= "mv_ch" + IiF( nI<=9,Chr(nI+48),Chr(nI+87) )
		/*
		PutSx1(cPerg,;
		cSeq,;
		aP[nI,1],aP[nI,1],aP[nI,1],;
		cMvCh,;
		aP[nI,2],;
		aP[nI,3],;
		aP[nI,4],;
		1,;
		aP[nI,5],;
		aP[nI,6],;
		aP[nI,7],;
		"",;
		"",;
		cMvPar,;
		aP[nI,8],aP[nI,8],aP[nI,8],;
		"",;
		aP[nI,9],aP[nI,9],aP[nI,9],;
		aP[nI,10],aP[nI,10],aP[nI,10],;
		aP[nI,11],aP[nI,11],aP[nI,11],;
		aP[nI,12],aP[nI,12],aP[nI,12],;
		aHelp[nI],;
		{},;
		{},;
		"")
		*/
	Next nI	
	
Return
