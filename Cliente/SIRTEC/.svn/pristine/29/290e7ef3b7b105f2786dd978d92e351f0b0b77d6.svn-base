#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SI001COM
Rotina de importacao de fornecedores atraves de arquivo TXT.
@author Bruno Silva
@since 02/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function SI001COM()
	//Variaveis publicas
	Private cPerg := Padr("SI001COM", LEN(SX1->X1_GRUPO), " ")
	Private _aLog := {}  
	Private _cRotina := "Importação Fornecedores TXT"
	
	/// Funcao que cria perguntas da rotina
	ValPerg()
	
	// Exibe perguntas
	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	// Chama funcao que faz a importacao do txt
	Processa({|| fImportTXT()})
	
Return

Static Function fImportTXT()

	Local cLinha  := ""
	Local lPrim   := .T.	
	Local aDados  := {}	
	Local nI
	// Caminho do arquivo txt
	Local cArqTxt    := Alltrim(MV_PAR01) + Alltrim(MV_PAR02)	
	Local nOpc
	Local oModel := Nil
	Local aErro	
	
	// Verifica se o aruivo txt existe
	If !File(cArqTxt)
		MsgStop("O arquivo " + cArqTxt + " não foi encontrado. A importação será abortada!",_cRotina)
		Return
	EndIf
	//Abre arquivo txt
	FT_FUSE(cArqTxt)	
	// Posiciona no inicio do arquivo txt
	FT_FGOTOP()
	While !FT_FEOF()	 
		IncProc("Lendo arquivo texto...")	 
		cLinha := FT_FREADLN()
		If lPrim
			//Pula primeira linha do arquivo txt
			lPrim := .F.
		Else
			// Adiciona ao array aDados as informações da linha
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf	 
		FT_FSKIP()
	EndDo
		
	//Begin Transaction
	ProcRegua(Len(aDados))
	//u_ShowArray(aDados)
	For nI := 1 to Len(aDados)
		IncProc()
		//      1;       2;         3;      4;         5;         6;      7;          8;      9;     10;
		//A2_LOJA; A2_NOME; A2_NREDUZ; A2_END; A2_NR_END; A2_BAIRRO; A2_EST; A2_COD_MUN; A2_MUN; A2_CEP;		
		//     11;     12;     13;     14;       15;         16;        17;        18;         19;         20; 
		//A2_TIPO; A2_CGC; A2_DDD; A2_TEL; A2_BANCO; A2_AGENCIA; A2_NUMCON; A2_TIPCTA; A2_TPESSOA; A2_CODPAIS; 		
		//        21;        22;       23;        24;      25;       26;       27;         28;       29;        30
		//A2_CALCIRF; A2_MINIRF; A2_INSCR; A2_INSCRM; A2_PAIS; A2_EMAIL; A2_SETOR; A2_COMPLEM; A2_HPAGE;A2_CELULAR
		//          31
		// [REC ou CAD]
		
		nOpc := IIF(Alltrim(aDados[nI,31]) == "C" ,3,4) // 3 Inclusao ; 4 Alteracao
		
		lContinua := nOpc == 3
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3)) // A2_FILIAL + A2_CGC
		If SA2->(dbSeek(xFilial("SA2") + Alltrim(aDados[nI,12])))
			If nOpc == 4
				lContinua := .T.
			Else
				aAdd(_aLog," - CNPJ/CPF ["+ Alltrim(aDados[nI,12]) +"] nao foi cadastrado pois já existe no sistema com o código ["+SA2->A2_COD+"] e loja ["+SA2->A2_LOJA+"].")
			EndIf 
		EndIf
		
		// Funcao que cria ou altera o fornecedor
		oModel := Nil					
		oModel := FWLoadModel('MATA020')							
		oModel:SetOperation(nOpc)
		oModel:Activate()						
					
		If nOpc == 4
			oModel:SetValue('SA2MASTER','A2_COD'  ,SA2->A2_COD)
			oModel:SetValue('SA2MASTER','A2_LOJA' ,SA2->A2_LOJA)
		Else
			oModel:SetValue('SA2MASTER','A2_COD' , GETSXENUM("SA2","A2_COD"))
			oModel:SetValue('SA2MASTER','A2_LOJA' ,aDados[nI,1])	
		EndIf		
		oModel:SetValue('SA2MASTER','A2_NOME' , Alltrim(aDados[nI,2]))
		oModel:SetValue('SA2MASTER','A2_NREDUZ' ,Alltrim(aDados[nI,3]))
		oModel:SetValue('SA2MASTER','A2_END' ,Alltrim(aDados[nI,4]))
		oModel:SetValue('SA2MASTER','A2_NR_END' ,Alltrim(aDados[nI,5]))
		oModel:SetValue('SA2MASTER','A2_BAIRRO' ,Alltrim(aDados[nI,6]))
		oModel:SetValue('SA2MASTER','A2_EST' ,Alltrim(aDados[nI,7]))
		oModel:SetValue('SA2MASTER','A2_COD_MUN',Alltrim(aDados[nI,8]))		
		//oModel:SetValue('SA2MASTER','A2_MUN' ,Alltrim(aDados[nI,9]))
		oModel:SetValue('SA2MASTER','A2_CEP' ,StrTRan(Alltrim(aDados[nI,10]),"-",""))
		oModel:SetValue('SA2MASTER','A2_TIPO' ,Alltrim(aDados[nI,11]))				
		oModel:SetValue('SA2MASTER','A2_CGC' ,Alltrim(aDados[nI,12]))
		oModel:SetValue('SA2MASTER','A2_DDD' ,Alltrim(aDados[nI,13]))
		oModel:SetValue('SA2MASTER','A2_TEL' ,Alltrim(aDados[nI,14]))
		oModel:SetValue('SA2MASTER','A2_BANCO' ,Alltrim(aDados[nI,15]))
		oModel:SetValue('SA2MASTER','A2_AGENCIA' ,Alltrim(aDados[nI,16]))
		oModel:SetValue('SA2MASTER','A2_NUMCON' ,Alltrim(aDados[nI,17]))
		oModel:SetValue('SA2MASTER','A2_TIPCTA' ,Alltrim(aDados[nI,18]))
		oModel:SetValue('SA2MASTER','A2_TPESSOA' ,Alltrim(aDados[nI,19]))
		oModel:SetValue('SA2MASTER','A2_CODPAIS' ,Alltrim(aDados[nI,20]))
		oModel:SetValue('SA2MASTER','A2_CALCIRF' ,Alltrim(aDados[nI,21]))
		oModel:SetValue('SA2MASTER','A2_MINIRF' ,Alltrim(aDados[nI,22]))
		oModel:SetValue('SA2MASTER','A2_INSCR' , Alltrim(aDados[nI,23]))
		oModel:SetValue('SA2MASTER','A2_INSCRM' ,Alltrim(aDados[nI,24]))
		oModel:SetValue('SA2MASTER','A2_PAIS' ,  Alltrim(aDados[nI,25]))
		oModel:SetValue('SA2MASTER','A2_EMAIL' , Alltrim(aDados[nI,26]))
		oModel:SetValue('SA2MASTER','A2_SETOR' , Alltrim(aDados[nI,27]))
		oModel:SetValue('SA2MASTER','A2_COMPLEM' ,Alltrim(aDados[nI,28]))
		oModel:SetValue('SA2MASTER','A2_HPAGE' ,Alltrim(aDados[nI,29]))
		oModel:SetValue('SA2MASTER','A2_CELULAR' ,Alltrim(aDados[nI,30]))
		
		//oModel:SetValue('SA2MASTER','A2_CPFRUR' ,"00000000")
		
		// Validcao dos campos informados				
		If oModel:VldData()
			// Efetica gravacao
		    oModel:CommitData()
			aAdd(_aLog," - CNPJ/CPF ["+ Alltrim(aDados[nI,12]) +"] foi cadastrado com sucesso.")
		Else
			aErro := oModel:GetErrorMessage()
		     
		    //Monta o Texto que será mostrado na tela
		    AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
		    AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
		    AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
		    AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
		    AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
		    AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
		    AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
		    AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
		    AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
		     
		    //Mostra a mensagem de Erro
		    //MostraErro()
		
		    VarInfo("Erro",oModel:GetErrorMessage()[6])
		    aAdd(_aLog," - CNPJ/CPF ["+ Alltrim(aDados[nI,12]) +"] erro no importação: ["+Alltrim(oModel:GetErrorMessage()[6])+"].")
		Endif
		
		oModel:DeActivate()		
		oModel:Destroy()
			
	Next nI
	
	//u_ShowArray(_aLog)
	
	// Gera arquivo de log
	fGeraLog()

Return

// Funcao que gera os arquivos de log apos a importacao
Static Function fGeraLog()
	Local lGerou := Len(_aLog) > 0
	Local nI
	Local cArqLog := Alltrim(MV_PAR01) + "log_"+DTOS(Date())+".txt"
	Local cLinha := ""
	
	For nI := 1 to Len(_aLog)
		cLinha += _aLog[nI] + CHR(13) + CHR(10)	
	Next nI
	
	If lGerou
		MemoWrite(cArqLog, cLinha)
		If File(cArqLog)
			MsgInfo("Importação concluída com sucesso, arquivo de log gerado na pasta ["+cArqLog+"].")
		EndIf
	EndIf

Return	


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao:  FUNCAO VALPERG()                                            ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ValPerg()
	Local i
	Local j
	aRegs :={}
	cPerg := PADR(cPerg,len(SX1->X1_GRUPO))
	
	aAdd(aRegs,{cPerg,"01","Diretorio ?"          ,"","","mv_ch1","C",30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","   "})
	aAdd(aRegs,{cPerg,"02","Nome do arquivo TXT ?","","","mv_ch2","C",20,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","   "})
	dbSelectArea("SX1")
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
Return 