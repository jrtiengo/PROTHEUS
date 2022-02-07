#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"    
#INCLUDE 'TOTVS.CH'   
#Define CRLF  CHR(13)+CHR(10)

//STATIC __cFilePath  := '\UFO_NFE\'
//STATIC __cLogsPath	:= 'log\'

//------------------------------------------------------------------- 
/*/{Protheus.doc} MTUFOPRO

Programa utilizado para realizar a integração entre os sistemas
UFO X Protheus. Integração será realizada atraves da tabela Z01
Rotina responsavel pela geração das Notas Fiscais de Entrada.
@author 	Helder Santos
@since		31.03.2014
@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
SmartNFE       20/08/2015  Criado váriável nTotItem para contar quantos itens a Nota Possui  
Linhas 170,193 e 222.       

Inserido no array o campo F1_USUSMAR para que se possa identificar, 
notas importadas pelo SmartNFE. Linha 207. 
Deverá ser criado o campo abaixo:
Campo      Tipo  Tamanho  Label
F1_USUSMAR  C      10     Usuário SmartNFE.	          

Incluído os campos D1_BASEIPI,D1_IPI, D1_VALIPI e D1_ICMSRET no array 	_aLinha
sendo preenchidos respectivamente pelos campos ZNF_BSIPI, ZNF_PIPI,ZNF_VALIPI 
e ZNF_VALST. Linhas 242, 243, 244 e 242.
Deverão ser criados os campos abaixo:
Campo       Tipo    Tamanho Decimais Label
ZNF_BSIPI    N         14      2     Vlr.Base IPI
ZNF_PIPI     N          2      0     Perc IPI
ZNF_VALIPI   N         14      2     Vlr. IPI
ZNF_VALST    N         14      2     Vlr. ICMS Solidario

SmartNFe 01/02/2016        Criação de parametros para ser informados usuário e senha do Protheus para que
o Exectauto seja executado por autenticação, caso os parametros estejam vazios,
o programa será executado sem a autenticação.
MA_USUSMA = Usuário Protheus SmartNFE
MA_PASSMA = Senha usuário Protheus SmartNFE

/*/

User Function MTUFOPRO(cEmpAbx, cFilAbx, cIdAbx)

	//Local cAlias   := ' '
	Local aEmpSmar := {}
	//Local aEmpNFe  := {}
	Local aInfo   := {}
	Local aTables := {"SA1","SA2","SF1","SD1","SF2","SD2","CTT","ZNF", "SF4","SB6","SB1","CT1",'SX6','SE2'}//seta as tabelas que serão abertas no rpcsetenv
	//Local Hora_I  := time()
	//Local Hora_f  := ""
	Local n, nI
	Private cEmpABax
	cError        := "" // Tratamento para erros não amigaveis finalizar a tela.
	oLastError    := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
	
	If (!IsBlind()) // COM INTERFACE GRÁFICA
	 	// MsgInfo("Função MTUFOPRO Iniciando Execução " ,"Start Assis")
    EndIf

	If Empty(cIdAbx)
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//->Leonardo Perrella Validação para verificar se já tem uma instancia rodando a rotina.                                 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		aInfo := GetUserInfoArray()
		For nI := 1 to Len(aInfo)
			If aInfo[nI][5] == "U_MTUFOPRO" .And. aInfo[nI][3] <> Threadid()
				 FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "Função MTUFOPRO sendo Utilizada!")
                 MEMOWRITE("C:\temp\LEEF_MTUFOPRO_EMUSO"+dtoc(date())+"_"+substr(time(),';','')+".TXT", "Função MTUFOPRO sendo Utilizada! Em execução por  "+aInfo[nI][1]+" / "+aInfo[nI][2])   
				 If (!IsBlind()) // COM INTERFACE GRÁFICA
				 //	MsgInfo("Função MTUFOPRO sendo Utilizada! Em execução por  "+aInfo[nI][1]+" / "+aInfo[nI][2] ,"Rotina já em Execução")
				 EndIf
 				Return      
			EndIf
		Next nI

		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//<-Leonardo Perrella Validação para verificar se já tem uma instancia rodando a rotina.                                 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		lthread := .T. 
		RpcSetType(3)
		RpcClearEnv()   
		//Não colocar o segundo parametro, pois cada cliente possui um código de empresa diferente 
		//Leonardo Vasco 20170606                
		RpcSetEnv( '01',, " ", " ", "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/

		cUsuSm := Alltrim(SuperGetMV("MA_USUSMA"))
		cSenSm := Alltrim(SuperGetMV("MA_PASSMA"))  //Abax@vaccinar1                                                                     
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//->Leonardo Vasco - Define se os valores dos impostos serão enviados zerados, .T. Envia .F. Não envia; 
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|		
		lVlZero:= SuperGetMV("MA_VLZERO",.F.,.F.) 
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//<-Leonardo Vasco - Define se os valores dos impostos serão enviados zerados, .T. Envia .F. Não envia; 
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|

		//Conout('---------------------------------------------------------------------------------------------')
		//Conout('INICIO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO')
		//Conout('---------------------------------------------------------------------------------------------')
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "INICIO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO")

		//Função busca as Filiais cadastradas no sigamat.emp Leo Viana 26/10/2015
		dbSelectarea('SM0')
		SM0->(dbGotop())

		Do While SM0->(!Eof())	    			
			Aadd(aEmpSmar,{SM0->M0_CODIGO,SM0->M0_CODFIL})		  			
			SM0->(dbSkip())			
		Enddo		

		RpcClearEnv() //RESET ENVIRONMENT //->[CRITICA] - Remover o RESET ENVIRONMENT desse ponto	   	

		cEmpABax := aEmpSmar[1][1]     
		RpcSetEnv( aEmpSmar[1][1],aEmpSmar[1][2]," " ," " , "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/


		For n:=1 to Len(aEmpSmar)

			If cEmpABax = aEmpSmar[n][1]
				cFilAnt := aEmpSmar[n][2]
				cEmpABax := aEmpSmar[n][1]
			Else
				RpcClearEnv() //RESET ENVIRONMENT //->[CRITICA] - Remover o RESET ENVIRONMENT desse ponto	   	                                     
				cEmpABax := aEmpSmar[n][1]
				cFilAnt := aEmpSmar[n][2]
				RpcSetEnv( aEmpSmar[n][1],aEmpSmar[n][2]," " ," ", "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/			
			Endif

			If Select('ZNF') > 0
				U_MImpNFs(aEmpSmar[n][1],aEmpSmar[n][2],cUsuSm,cSenSm)			   
			Else
				FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "EMPRESA SEM ZNF" + aEmpSmar[n][1])
				//Conout('EMPRESA SEM ZNF' + aEmpSmar[n][1] )
			Endif

		Next	

		//Conout('---------------------------------------------------------------------------------------------')
		//Conout('FIM IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO')
		//Conout('---------------------------------------------------------------------------------------------')	
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "FIM IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO")
		RpcClearEnv()
	Else	
		RpcSetEnv( cEmpAbx,cFilAbx," " ," ", "COM", "MATA103", aTables, , , ,  ) 
		cUsuSm := Alltrim(SuperGetMV("MA_USUSMA"))
		cSenSm := Alltrim(SuperGetMV("MA_PASSMA"))                                        
		U_MImpNFs(cEmpAbx,cFilAbx,cUsuSm,cSenSm)			   
		RpcClearEnv()
	Endif

	U_MTCTEPRO() // Execução de importação de CTE pela rotina MATA116 Voltar Leo Viana 20170419
	If (!IsBlind()) // COM INTERFACE GRÁFICA
	 	// MsgInfo("Função MTUFOPRO Final de Execução  " ,"Assis")
    EndIf

Return

User Function MImpNFs(cEmpMa,cFilMa,cUsusm,cSenSm)
	******************************************************************************
	* Função para importar  notas para o Protheus. Foi desmembrado a função devido
	* a empresas que possuem muitas empresas e filiais.
	******************************************************************************

	//Conout('---------------------------------------------------------------------------------------------')
	//Conout('PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa ) 
	//Conout ('SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL)
	//Conout('---------------------------------------------------------------------------------------------')
	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL )

	cAlias:= FSBusDados(cFilMa)

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop()) 

	If !Empty((cAlias)->ZNF_DOC+(cAlias)->ZNF_SERIE+(cAlias)->ZNF_FORNEC+  (cAlias)->ZNF_LOJA)
		/* Função Gera NF de Entrada dentro do sistema Protheus*/
		FSGeraNFE(cAlias)
		//Conout('---------------------------------------------------------------------------------------------')
		///Conout('FIM PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
		//Conout('---------------------------------------------------------------------------------------------')
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'FIM PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
	Else
		//Conout('---------------------------------------------------------------------------------------------')
		//Conout('FIM PROCESSO SEM MOVIMENTO - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
		//Conout('---------------------------------------------------------------------------------------------')
		//MEMOWRITE("C:\temp\MTUFOPRO_SEMMOV.TXT", "Sem movimento  ")   
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'FIM PROCESSO SEM MOVIMENTO - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )		 
	Endif		 				  						 					

	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif

Return    


//------------------------------------------------------------------- 
/*/{Protheus.doc} FBusFil

Função responsavel por verificar quais filiais possuem notas a serem processadas.
@author 	Leonardo Viana
@since		16.07.2015
@Return		cTotFilArquivo com as Filiais a serem processadas.
@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
/*
Static Function FBusFil(cEmpMA) //Parametro para pegar só dados da 

	Local cFile
	Local cQryExc	:= ''
	Local aFilFoun  := {} 

	cQryExc += CRLF +" SELECT DISTINCT ZNF_FILIAL "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_STATUS <> '2' "     
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "      
	cQryExc += CRLF +" GROUP BY ZNF_FILIAL " 
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL "      

	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cFile := GetNextAlias() , .F. , .F. )

	dbSelectArea(cFile)
	dbGotop()
	Do While !Eof()  
		Aadd(aFilFoun,(cFile)->ZNF_FILIAL)
		dbSkip()
	Enddo	             
	dbSelectArea(cFile)
	dbCloseArea()                       

Return(aFilFoun)   
*/

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSBusDados

Função responsavel por buscar os dados a serem integrados
Informações originadas diretamente do Sistema UFO
@author 	Helder Santos
@since		31.03.2014
@Return		cPrefix - Alias carregado com as informações
@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/

Static Function FSBusDados(cFilImp)

	Local cPrefix  
	Local cPreWMS                                                                          
	Local cQryExc := ''                                                                   
	Local cFilWms, cDocWMS, cSerWMS, cForWMS,cLojWMS,cCodWms,cTesWms, cNatWMS := ''
	Local nRecWMS	
	/*----------------------------------------------------------------------------------------------
	Tratamento para igualar ZNF com SD1
	------------------------------------------------------------------------------------------------*/
	//ZNF_FILIAL,ZNF_DOC, ZNF_SERIE, ZNF_FORNEC, ZNF_LOJA, ZNF_COD,ZNF_TES, ZNF_NATUR,
	cQryExc := CRLF +" SELECT  * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " ZNF " 
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + Alltrim(cFilImp) +"' and "    
	cQryExc += CRLF +" ZNF_TPLANC = 'W' "	
	cQryExc += CRLF +" AND ZNF_STATUS <> '2' "                                             
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "      
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cPreWMS := GetNextAlias() , .F. , .F. )

	dbSelectArea(cPreWMS)

	If !Empty(Alltrim((cPreWMS)->ZNF_DOC))

		cIteSD1 := ' '//nTotItem := (cPreWMS)->ZNF_QUANT                            

		Do While !Eof()

			cFilWms := (cPreWMS)->ZNF_FILIAL
			cDocWMS := (cPreWMS)->ZNF_DOC 
			cSerWMS := (cPreWMS)->ZNF_SERIE
			cForWMS := (cPreWMS)->ZNF_FORNEC
			cLojWMS := (cPreWMS)->ZNF_LOJA
			cCodWms := (cPreWMS)->ZNF_COD
			nRecWMS := (cPreWMS)->R_E_C_N_O_
			cTesWms := (cPreWMS)->ZNF_TES 
			cNatWMS := (cPreWMS)->ZNF_NATUR
			cDtWMS  := (cPreWMS)->ZNF_DTDIGIT
			cUseWMS := (cPreWMS)->ZNF_USERLG
			cStWMS  := (cPreWMS)->ZNF_STATUS
			cConWMS := (cPreWMS)->ZNF_COND
			cChvWMS := (cPreWMS)->ZNF_CHVNFE
			cEspWMS := (cPreWMS)->ZNF_ESPEC
			nPBrWMS := (cPreWMS)->ZNF_PBRUTO
			nPLWMS  := (cPreWMS)->ZNF_PLIQUI
			dReWMS  := (cPreWMS)->ZNF_RECBMT      
			nVolWMS := (cPreWMS)->ZNF_VOLUME
			nVBWMS  := (cPreWMS)->ZNF_VLBRUT
			cTPWMS  := (cPreWMS)->ZNF_TPLANC

			dbSelectArea('SD1')
			dbsetOrder(11)
			dbSeek(xFilial('SD1')+(cPreWMS)->ZNF_DOC+(cPreWMS)->ZNF_SERIE+(cPreWMS)->ZNF_FORNEC+(cPreWMS)->ZNF_LOJA+Alltrim((cPreWMS)->ZNF_COD)) // Chave Indice //

			//cIteSD1 := SD1_D1_ITEM			
			Do While !eof() .and. ( SD1->D1_FILIAL == cFilWms .and. SD1->D1_DOC == cDocWMS .and. SD1->D1_SERIE == cSerWMS .and. SD1->D1_FORNECE == cForWMS .and. SD1->D1_LOJA == cLojWMS .and. Alltrim(SD1->D1_COD) == Alltrim(cCodWMS) )                                                                                                         

				If !SD1->D1_ITEM $ cIteSD1        		  			
					dbSelectArea('ZNF')
					RecLock('ZNF',.T.)	
					ZNF_FILIAL	:=	SD1->D1_FILIAL 
					ZNF_ITEM    :=	SD1->D1_ITEM      
					ZNF_COD		:=	SD1->D1_COD       
					ZNF_PEDIDO	:=	SD1->D1_PEDIDO    
					ZNF_ITEMPC 	:=	SD1->D1_ITEMPC    
					ZNF_QUANT   :=	SD1->D1_QUANT     
					ZNF_VUNIT   :=	SD1->D1_VUNIT     
					ZNF_TOTAL   :=	SD1->D1_TOTAL 
					ZNF_TPLANC  := cTPWMS
					ZNF_TES     :=	cTesWms       
					ZNF_DTDIGIT := Stod(cDtWMS)
					ZNF_USERLG  := cUseWMS
					ZNF_STATUS  := cStWMS
					ZNF_COND    := cConWMS
					ZNF_CHVNFE  := cChvWMS
					ZNF_ESPEC	:= cEspWMS
					ZNF_PBRUTO  := nPBrWMS
					ZNF_PLIQUI  := nPLWMS
					//ZNF_RECBMT  := Stod(dReWMS)
					ZNF_VOLUME  := nVolWMS
					ZNF_VLBRUT	:= nVBWMS
					ZNF_LOTEFO	:=	SD1->D1_LOTEFOR     
					ZNF_LOTECT	:=	SD1->D1_LOTECTL     
					ZNF_DTVALI	:=	SD1->D1_DTVALID     
					ZNF_DFABRI	:=	SD1->D1_DFABRIC     
					//ZNF_DOC 	   :=	SD1->D1_NFORI   
					ZNF_SERIE 	:=	SD1->D1_SERIORI 
					ZNF_LOCAL 	:=	SD1->D1_LOCAL   
					ZNF_FORNEC  :=	SD1->D1_FORNECE   
					ZNF_LOJA    :=	SD1->D1_LOJA      
					ZNF_DOC     :=	SD1->D1_DOC       
					ZNF_EMISSA	:=	SD1->D1_EMISSAO   
					ZNF_SERIE   :=	SD1->D1_SERIE     
					ZNF_TIPO    :=	SD1->D1_TIPO      
					ZNF_VALDES	:=	SD1->D1_VALDESC 
					ZNF_VALICM  :=	SD1->D1_VALICM  
					ZNF_PICM    :=	SD1->D1_PICM   
					ZNF_BSICM   :=	SD1->D1_BASEICM   
					ZNF_ICMSCO  :=	SD1->D1_ICMSCOM   
					ZNF_BSIPI 	:=	SD1->D1_BASEIPI   
					ZNF_PIPI	   :=	SD1->D1_IPI  
					ZNF_VALIPI  :=	SD1->D1_VALIPI  
					ZNF_ALQPIS	:=	SD1->D1_ALQPIS  
					ZNF_ALQCOF	:=	SD1->D1_ALQCOF  
					ZNF_ALQCSL	:=	SD1->D1_ALQCSL  
					ZNF_VALPIS	:=	SD1->D1_VALPIS  
					ZNF_VALCSL	:=	SD1->D1_VALCSL  
					ZNF_VALCOF	:=	SD1->D1_VALCOF  
					ZNF_BASPIS	:=	SD1->D1_BASEPIS 
					ZNF_BASCOF	:=	SD1->D1_BASECOF 
					ZNF_BASCSL	:=	SD1->D1_BASECSL 
					ZNF_BASIRR	:=	SD1->D1_BASEIRR 
					ZNF_ALIIRR	:=	SD1->D1_ALIQIRR 
					ZNF_VALIRR	:=	SD1->D1_VALIRR  
					ZNF_BASISS	:=	SD1->D1_BASEISS 
					ZNF_BRICMS	:=	SD1->D1_BRICMS  
					ZNF_BRICMS	:=	SD1->D1_BRICMS  
					ZNF_ALISOL	:=	SD1->D1_ALIQSOL  
					ZNF_ALISOL	:=	SD1->D1_ALIQSOL  
					ZNF_ICMRET	:=	SD1->D1_ICMSRET  
					ZNF_CONTA	:=	SD1->D1_CONTA  
					ZNF_ABATMA  :=	SD1->D1_ABATMAT   
					ZNF_BASEIN  :=	SD1->D1_BASEINS   
					ZNF_ALIQIN  :=	SD1->D1_ALIQINS   
					ZNF_VALIN   :=	SD1->D1_VALINS   
					ZNF_ALIISS	:=	SD1->D1_ALIQISS 
					ZNF_VALISS  :=	SD1->D1_VALISS  
					ZNF_CFOP 	:=	SD1->D1_CF  
					ZNF_CC	   :=	SD1->D1_CC  
					ZNF_NATUR   := cNatWMS
					MsUnlock()
				Endif	
				cIteSD1 += '_'+SD1->D1_ITEM
				dbSelectArea('SD1')
				DBskip()

			Enddo

			//Deletar registro na ZNF
			cQryDel := " UPDATE "+RetSqlName("ZNF") 
			cQryDel += " SET ZNF_STATUS = '2' WHERE R_E_C_N_O_  = '"+Alltrim(STR(nRecWMS))+"' "

			If (TCSQLExec(cQryDel) < 0)
				//conout("NÃO AJUSTOU ZNF - ERRO AJUSTES WMS - TCSQLError() " + TCSQLError())
				FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "NÃO AJUSTOU ZNF - ERRO AJUSTES WMS - TCSQLError() " + TCSQLError() )		 
			EndIf

			dbSelectArea(cPreWMS)
			dbSkip()
			//Povar novamente variáveis
			cFilWms := (cPreWMS)->ZNF_FILIAL
			cDocWMS := (cPreWMS)->ZNF_DOC 
			cSerWMS := (cPreWMS)->ZNF_SERIE
			cForWMS := (cPreWMS)->ZNF_FORNEC
			cLojWMS := (cPreWMS)->ZNF_LOJA
			cCodWms := (cPreWMS)->ZNF_COD
			nRecWMS := (cPreWMS)->R_E_C_N_O_
			cTesWms := (cPreWMS)->ZNF_TES 
			cNatWMS := (cPreWMS)->ZNF_NATUR

		Enddo

		dbSelectArea(cPreWMS)
		dbCloseArea()
	Else
		dbSelectArea(cPreWMS)
		dbCloseArea()   
	Endif

	cQryExc	:= '' 

	cQryExc := CRLF +" SELECT * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + Alltrim(cFilImp) +"' and "    
	//Leonardo Viana - Incluído filtro para escolher somente notas que deverão ser inseridas pela rotina MATA103 - ZNF_TPLANC <> 2 - 	TPLANC = VAZIO NOTA FISCAL MATA103; 	TPLANC = P PRÉ NOTA MATA103; TPLANC = 2 CTE COM NF VINCULADA MATA116
	cQryExc += CRLF +" ZNF_TPLANC <> '2' "	 
	cQryExc += CRLF +" AND ZNF_STATUS <> '2' "                                                                 
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "      
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cPrefix := GetNextAlias() , .F. , .F. )

Return(cPrefix)   


//------------------------------------------------------------------- 
/*/{Protheus.doc} FSGeraNFE

Função responsavel pela geração da NFE dentro do sistema Protheus
@author 	Helder Santos
@since		31.03.2014
@Parm1		cPrefix - Alias com as informaçoes da NFE		
@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/

Static Function FSGeraNFE(cPrefix)

	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	Local aAreaSF4	:= SF4->(GetArea())    
	//Local cFilAux	:= cFilAnt//Armazena Variavel publica em uma variavel auxiliar, necessario para assim que processo finalizar a mesma deve voltar com a informação inicial
	//Local __cLogFile:= ''   
	Local __cLogMsg	:= ''
	Local __cSeekNF	:= ''                
	Local lImport	:= .F. 
	Local cEspecie	:= ''  
	//Local cTipoNf	:= ''
	Local lOrigem	:= .F.
	Local aLog		:= {}
	Local cLocSB6	:= ''  
	Local cLocSC7	:= ''  //Declaração Variável.

	Private  cTpLanc   := ''
	Private _aCabSF1   		:= {}  
	Private _aLinha	   		:= {}   
	Private _aItensSD1		:= {}	
	Private lMsErroAuto		:= .F.  
	//-----------  
	Private lAutoErrNoFile  := .F. //<= para nao gerar arquivo e pegar o erro com a funcao GETAUTOGRLOG()
	//      alterado para falso machado 190820 - 1341hs
	//-------------
	Private nTotItem		:= 1 // 20/08/2015 -Criado váriável nTotItem para contar quantos itens a Nota Possui  
	Private nFretAbax		:= 0     //09/12/2016 - Criado para totalizar o frete do Pedido de Compra.
	Private nVBrtAbax		:= 0        //Valor Bruto Nota Fiscal
	Private cCondAbax    := Space(3) //Condicao de pagamento   
	Private dDtVAbax		:= dDatabase
	Private cMAVenc		:= Space(250) //String com dados do vencimento.
	Private cRecIss	   := Space(1) 
	Private cSerDES		:= Space(1) //06/10/2017 - Campo par fazer De Para da DESBH 
	Private nBolAbax		:= 1			// 27/09/2017 - Leonardo Vasco - Melhoria Oncoclinicas -   
	Private aBolAbax 		:= {}       // 27/09/2017 - Leonardo Vasco - Melhoria Oncoclinicas - Campo utilizado para gravar os códigos de barras dos boletos 
	Private nToItem      := 0 //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para só importar quando todos os itens forem enviados para a ZNF.
	Private nTotAbax     := 0  //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para só importar quando todos os itens forem enviados para a ZNF.
	Private lErroAba     := .F. //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Tratamento para não executar Execauto caso ocorra problema de exportação para a ZNF.	

	cProxSeq := Ver_DOCSEQ() // Retornar o D1_NUMSEQ para a tabela SD1 --cProx := Soma1(PadR(SuperGetMv("MV_DOCSEQ"),nTamSeq),,,.T.)
	//cProxAba :=Space(6)
	PutMV("MV_DOCSEQ",cProxSeq)

	_lVENABAX := SuperGetMV('MA_VENABAX',.F.,.T.)
	_lLOCSB6  := SuperGetMV('MA_LOCSB6',.F.,.T.)

	_cDiaIss := GetMV("MV_DIAISS")
	_cDiaAbx := 5 // GetMV("MV_STC0001") 
	nZ:=1
	dbSelectArea(cPrefix)
	(cPrefix)->(dbGoTop())		

	Do While (cPrefix)->(!Eof())


		//Conout('MTUFOPRO - IMPORTANDO NOTA  '+ (cPrefix)->ZNF_DOC+'-'+ (cPrefix)->ZNF_SERIE+'-'+(cPrefix)->ZNF_FORNEC+'-'+(cPrefix)->ZNF_LOJA)
		/* Atualiza Variavel Publica, assim será definido em qual filial deve ser gerado a Nota Fiscal */
		cFilAnt	:= (cPrefix)->ZNF_FILIAL

		nToItem++ //Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para só importar quando todos os itens forem enviados para a ZNF.
		/* Cria uma chave see de validação, caso a chave mude é o momento para importar a Nota Fiscal */ 
		__cSeekNF:=(cPrefix)->ZNF_DOC+(cPrefix)->ZNF_SERIE+(cPrefix)->ZNF_FORNEC+  (cPrefix)->ZNF_LOJA

		cDocSMA := 	(cPrefix)->ZNF_DOC
		cSerSMA :=  (cPrefix)->ZNF_SERIE
		cForSMA := (cPrefix)->ZNF_FORNEC			
		cLojSMA := (cPrefix)->ZNF_LOJA			  

		If (cPrefix)->ZNF_TIPO $ 'N_I_P_C'		
			SA2->(dbSetorder(01))
			SA2->(dbSeek(xFilial('SA2')+(cPrefix)->ZNF_FORNEC+(cPrefix)->ZNF_LOJA ))			
			cEstSM := SA2->A2_EST
			If Empty((cPrefix)->ZNF_COND)
				cConPAba := Alltrim(SA2->A2_COND)
			Else 
				cConPAba := (cPrefix)->ZNF_COND
			Endif   
		Else    //B ou D                                                                   
			SA1->(dbSetorder(01))
			SA1->(dbSeek(xFilial('SA1')+(cPrefix)->ZNF_FORNEC+(cPrefix)->ZNF_LOJA ))
			cEstSM := SA1->A1_EST  
			If Empty((cPrefix)->ZNF_COND)
				cConPAba := Alltrim(SA1->A1_COND)
			Else 
				cConPAba := (cPrefix)->ZNF_COND
			Endif  
		Endif
		

		/*N = Nf Normal
		D = Devolução
		I = NF Compl. ICMS
		P = NF Compl. IPI
		C = Complemento
		B = Beneficiamento.*/

		//Nunca tirar o campo pedido e item desta posição
		dbSelectArea('SC7')  
		SC7->(dbSetOrder(01))
		SC7->(dbSeek(xFilial('SC7')+(cPrefix)->ZNF_PEDIDO+Alltrim((cPrefix)->ZNF_ITEMPC)))
		// Daniel Assis  - Conferir se existe PEdido 
        if  SC7->(eof())		
		endif
		//Leonardo Viana - Pegar Lote do SC7 para as situações onde não existe Lote na ZNF
		cLocSC7 := SC7->C7_LOCAL
		cConPAba:= iif( !Empty(SC7->C7_COND), SC7->C7_COND, cConPAba)
		
		
		// Leef- Assis - 15/09/20 - 15:35 ---  22/09/20 17:31
		// Ajuste feito para ler parametro MV_STC0001
		aVenc	:= Condicao(100,cConPAba,,Stod((cPrefix)->ZNF_EMISSA))
		If Len(aVenc)>0 
			If(aVenc[1][1] < DATE())
                MEMOWRITE("MTUFOPRO_LEEF_VECTO_FORA_"+FWTimeStamp(1)+".TXT",'MTUFOPRO - VECTO TITULO  - Menor que hoje  '+ (cPrefix)->ZNF_DOC+'-'+ (cPrefix)->ZNF_SERIE+'-'+(cPrefix)->ZNF_FORNEC+'-'+(cPrefix)->ZNF_LOJA +" ## VECTO EM "+dtoc(aVenc[1][1])+" ### FORA DA DATA ->"+dtoc(Stod((cPrefix)->ZNF_EMISSA))+" ")   
				FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'MTUFOPRO - VECTO TITULO  - Menor que hoje  '+ (cPrefix)->ZNF_DOC+'-'+ (cPrefix)->ZNF_SERIE+'-'+(cPrefix)->ZNF_FORNEC+'-'+(cPrefix)->ZNF_LOJA +" ## VECTO EM "+dtoc(aVenc[1][1])+" ### FORA DA DATA ->"+dtoc(Stod((cPrefix)->ZNF_EMISSA))+" ")
				FAtuaStat(cDocSMA,cSerSMA,cForSMA, cLojSMA,.F., 'VECTO TITULO  - Menor que hoje - Data/hora ' + FWTimeStamp(1))
				(cPrefix)->(Dbskip()) 
				loop
			Endif
		EndIf
		
		dbSelectArea('SC7')  
		If !lImport		                                 
			//Trocado Log para mostrar só uma vez no console.log, da forma antiga a nota era grava para cada item da mesma.
			//Leonardo Vasco Viana 21/07/2017
			//Conout('MTUFOPRO - IMPORTANDO NOTA  '+ (cPrefix)->ZNF_DOC+'-'+ (cPrefix)->ZNF_SERIE+'-'+(cPrefix)->ZNF_FORNEC+'-'+(cPrefix)->ZNF_LOJA)
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'MTUFOPRO - IMPORTANDO NOTA  '+ (cPrefix)->ZNF_DOC+'-'+ (cPrefix)->ZNF_SERIE+'-'+(cPrefix)->ZNF_FORNEC+'-'+(cPrefix)->ZNF_LOJA)

			If (cPrefix)->ZNF_ESPEC == 'NFE' //			IIF((cPrefix)->ZNF_ESPECI == 'NFE', 'SPED','CTE') //cEspecie	:= 'SPED' 		//  Linha 270       04/09/2015
				cEspecie	:= 'SPED' 
			Else 
				cEspecie	:= (cPrefix)->ZNF_ESPEC			
			Endif

			nTotItem    := 1  
			/* Carrega informações do cabeçalho da Nota Fiscal*/
			Aadd(_aCabSF1,{"F1_FILIAL"   ,cFilAnt									,Nil}) 
			Aadd(_aCabSF1,{"F1_DOC"      ,(cPrefix)->ZNF_DOC    			   		,Nil})
			Aadd(_aCabSF1,{"F1_SERIE"    ,(cPrefix)->ZNF_SERIE  			   		,Nil})
			Aadd(_aCabSF1,{"F1_FORNECE"  ,(cPrefix)->ZNF_FORNEC 			  		,Nil})	//SA2->A2_COD	    	
			Aadd(_aCabSF1,{"F1_LOJA"     ,(cPrefix)->ZNF_LOJA   			 		,Nil})	//SA2->A2_LOJA    		,Nil})              
			Aadd(_aCabSF1,{"F1_COND"     ,cConPAba 			  			 		  ,Nil})  // Caso o campo ZNF_COND esteja vazio, pegará essa informação do cadastro do Cliente/Fornecedor
			If Alltrim(cEspecie) == 'CTE'       
				If Empty(Alltrim((cPrefix)->ZNF_TPCTE))
					Aadd(_aCabSF1,{"F1_TPCTE"    ,Alltrim((cPrefix)->ZNF_TIPO)   			,Nil}) 	//
				Else                                                                                             
					Aadd(_aCabSF1,{"F1_TPCTE"    ,(cPrefix)->ZNF_TPCTE             	   , Nil})//  - C - 1 - Tipo do CTE - N=Normal;C=Complem.Valores;A=Anula.Valores;S=Substituto	
				Endif 	
			Endif
			Aadd(_aCabSF1,{"F1_EMISSAO"  ,Stod((cPrefix)->ZNF_EMISSA) 	  			,Nil})
			Aadd(_aCabSF1,{"F1_EST"      ,cEstSM			    					,Nil})  //Estado do Cliente ou do Fornecedor     
			Aadd(_aCabSF1,{"F1_TIPO"     ,(cPrefix)->ZNF_TIPO				  		,Nil}) 	// Será buscado o tipo da ZNF e não mais como N
			//Tratamento data de digitação enviada pelo Ábax, 
			//07/08/2017 - Leonardo Vasco Viana de Oliveira
			If Empty((cPrefix)->ZNF_DTDIGI)
				Aadd(_aCabSF1,{"F1_DTDIGIT"  ,DDATABASE 								,Nil})    
			Else 
				Aadd(_aCabSF1,{"F1_DTDIGIT"  ,Stod((cPrefix)->ZNF_DTDIGI)		,Nil})    			
			Endif
			Aadd(_aCabSF1,{"F1_FORMUL"   ,"N" 		  								,Nil})
			Aadd(_aCabSF1,{"F1_ESPECIE"  ,cEspecie									,Nil})
			Aadd(_aCabSF1,{"F1_CHVNFE"   ,(cPrefix)->ZNF_CHVNFE   		   			,Nil})
			Aadd(_aCabSF1,{"F1_VOLUME1"  ,(cPrefix)->ZNF_VOLUME  		   			,Nil}) 	//Inclusão 12/05/2016
			Aadd(_aCabSF1,{"F1_USUSMAR"  ,(cPrefix)->ZNF_USERLG			   			,Nil})                 
			Aadd(_aCabSF1,{"F1_MODNF"    ,(cPrefix)->ZNF_MODNF			   			,Nil}) 	//DESBH       

			If Alltrim(cEspecie) = 'CTE'  
				Aadd(_aCabSF1,{"F1_TPCTE"    ,(cPrefix)->ZNF_TIPO		   			,Nil}) 	//

				//Envio dos novos campos de Municipio e Estado de Origem e Destino do Transporte.
				//Leonardo Vasco 26/06/2018
				cUsaCampo  := AllTrim(Posicione("SX3",2,"F1_MUORITR","X3_CAMPO"))		
				If !Empty(cUsaCampo) 
					Aadd(_aCabSF1,{"F1_MUORITR"    ,(cPrefix)->ZNF_MUORIT			   			,Nil}) 	//DESBH       
				Endif	

				cUsaCampo  := AllTrim(Posicione("SX3",2,"F1_UFORITR","X3_CAMPO"))		
				If !Empty(cUsaCampo) 
					Aadd(_aCabSF1,{"F1_UFORITR"    ,(cPrefix)->ZNF_UFORIT			   			,Nil}) 	//DESBH       
				Endif	    

				cUsaCampo  := AllTrim(Posicione("SX3",2,"F1_MUDESTR","X3_CAMPO"))		
				If !Empty(cUsaCampo) 
					Aadd(_aCabSF1,{"F1_MUDESTR"    ,(cPrefix)->ZNF_MUDEST			   			,Nil}) 	//DESBH       
				Endif 

				cUsaCampo  := AllTrim(Posicione("SX3",2,"F1_UFDESTR","X3_CAMPO"))		
				If !Empty(cUsaCampo) 
					Aadd(_aCabSF1,{"F1_UFDESTR"    ,(cPrefix)->ZNF_UFDEST			   			,Nil}) 	//DESBH       
				Endif 				
				//Aadd(_aCabSF1,{"F1_TPFRETE"  ,(cPrefix)->ZNF_TIPO		   			,Nil}) 	//   			
			Endif

			//Não enviar quando a chave da danfe ou do CTe estiver preenchida.
			If Empty((cPrefix)->ZNF_CHVNFE)                                                      
				Do Case
					Case Alltrim((cPrefix)->ZNF_SERIE) = '0'      
					cSerDES = '0'
					Case Alltrim((cPrefix)->ZNF_SERIE) = 'U'      
					cSerDES = '1'
					Case Alltrim((cPrefix)->ZNF_SERIE) = 'A'      
					cSerDES = '2'
					Case Alltrim((cPrefix)->ZNF_SERIE) = 'AA'      	
					cSerDES = '3'					
					Case Alltrim((cPrefix)->ZNF_SERIE) = 'B'      	
					cSerDES = '4'					
					Case Alltrim((cPrefix)->ZNF_SERIE) = 'C'      											
					cSerDES = '5'					
					Case Alltrim((cPrefix)->ZNF_SERIE) = 'E'					
					cSerDES = '7'
				Endcase

				Aadd(_aCabSF1,{"F1_SERIEDS"  ,cSerDES					,Nil}) 	//Série DES BH      
			Endif
			Aadd(_aCabSF1,{"F1_FRETE"    ,(cPrefix)->ZNF_FRETE						,Nil}) 	//Leonardo Viana 20161116 - Tratar Frete da Nota Fiscal.        			
			Aadd(_aCabSF1,{"F1_DESPESA"  ,(cPrefix)->ZNF_DESPES			   			,Nil})
			Aadd(_aCabSF1,{"F1_ZUSER"    ,Substr((cPrefix)->ZNF_USERLG,1,25)		,Nil})    
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			//->Leonardo Viana Incluido para tratar dos campos Peso Bruto, Peso Líquido e data do recebimento da mercadoria 16/02/2017  |
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			Aadd(_aCabSF1,{"F1_PBRUTO"   ,(cPrefix)->ZNF_PBRUTO					,Nil})
			Aadd(_aCabSF1,{"F1_PLIQUI"   ,(cPrefix)->ZNF_PLIQUI						,Nil})
			Aadd(_aCabSF1,{"F1_RECBMTO"  ,Stod((cPrefix)->ZNF_RECBMT)	   		,Nil})
			Aadd(_aCabSF1,{"F1_INCISS"   ,(cPrefix)->ZNF_INCISS				   		,Nil})  //Código do Municipio IBGE
			Aadd(_aCabSF1,{"F1_ESTPRES"  ,(cPrefix)->ZNF_ESTPRE				   		,Nil})  //Estado do Municipio 	   			              
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			//->Leonardo Viana Incluido para recolhimento do ISS sim ou não  Data: 16/05/2017
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			cRecIss := (cPrefix)->ZNF_RECISS
			If !empty((cPrefix)->ZNF_RECISS)
				Aadd(_aCabSF1,{"F1_RECISS"   ,(cPrefix)->ZNF_RECISS					,Nil})  	   			              
			Endif	

			If !Empty(Alltrim((cPrefix)->ZNF_DIRF))
				Aadd(_aCabSF1,{"E2_DIRF"    ,'1'									,Nil})
				Aadd(_aCabSF1,{"E2_CODRET"  ,Alltrim((cPrefix)->ZNF_DIRF)			,Nil})
			Else
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				//->Leonardo Viana Incluido para preencher o campo E2_DIRF com N quando o campo ZNF_DIRF estiver vazio  Data: 14/06/2017 
				// 1 Equivale ao SIM, 2 Equivale ao Não 
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				Aadd(_aCabSF1,{"E2_DIRF"    ,'2'									,Nil})			
			Endif
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			//<-Leonardo Viana Incluido para tratar dos campos Peso Bruto, Peso Líquido e data do recebimento da mercadoria 16/02/2017  |
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|              		
			//--Variaveis publicas
			nVBrtAbax	:=	(cPrefix)->ZNF_VLBRUT  		//Valor Bruto Nota Fiscal
			cCondAbax   := (cPrefix)->ZNF_COND    			//Condicao de pagamento			
			cMAVenc	   :=  Alltrim((cPrefix)->ZNF_MAVENC)  //String com alterações do vencimento.

			//Caso parametro não exista, será considerado .T. e pegará a data de emissão da nota fiscal.
			If (_lVENABAX == .T.) ////(SuperGetMV('MA_VENABAX',.F.,.T.)  //Se .T. ira considerar data de emissao
				dDtVAbax := Stod((cPrefix)->ZNF_EMISSA)
			Else 
				dDtVAbax := dDataBase //Se 2 ira considerar data base			
			Endif	                                                        

			cCondicao := (cPrefix)->ZNF_COND   
			If (cPrefix)->ZNF_TIPO $ 'N_I_P_C'
				If AllTrim((cPrefix)->ZNF_NATUR) == "000000"
					Aadd(_aCabSF1,{"E2_NATUREZ"  ,"      "  ,Nil})
				Else		         			
					Aadd(_aCabSF1,{"E2_NATUREZ"  ,(cPrefix)->ZNF_NATUR  ,Nil})  // Incluído tratamento Natureza Financeira 292 04/09/2015
				EndIf
			Endif	                                                                                                                  			
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			//->Leonardo Viana Incluido para tratar o campo E2_DIRF.  16/02/2017                               							 |
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			If !Empty((cPrefix)->ZNF_DIRF)
				Aadd(_aCabSF1,{"E2_DIRF",(cPrefix)->ZNF_DIRF ,Nil})
			Endif	
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			//->Leonardo Viana Incluido para tratar o campo E2_DIRF.  16/02/2017                               							 |
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			If (cPrefix)->ZNF_ESPEC = 'NFSE' // Incluído tratamento de Fornecedor de ISS e Loja ISS

				//cDiaIss := Alltrim(GetMV("MV_DIAISS"))
				cDiaIss := _cDiaIss
				cMesIss := alltrim(str(Month(dDataBase)+ 1))
				cAnoIss := alltrim(str(Year(dDataBase)))       



				If !Empty(cDiaIss)
					dDatISS := Ctod(cDiaIss+'/'+cMesIss+'/'+cAnoIss) 
				Else	                                             
					dDatISS := Ctod('10/'+cMesIss+'/'+cAnoIss) 
				Endif
				Aadd(_aCabSF1,{"E2_FORNISS"  ,(cPrefix)->ZNF_FORISS  ,Nil})
				Aadd(_aCabSF1,{"E2_LOJISS"   ,(cPrefix)->ZNF_LOJISS  ,Nil})
				Aadd(_aCabSF1,{"E2_VENISS"   ,dDatISS				 ,Nil})

			Endif
			//       
			If !Empty(Alltrim((cPrefix)->ZNF_BOLETO))
				aBolAbax := Strtokarr(Alltrim((cPrefix)->ZNF_BOLETO),'|')      
				//nBolAbax++
			Endif
			lImport:=.T.                                                                                                                

			/* Fim Cabeçalho Nota Fiscal */                            
		EndIf		    
		_aLinha:={}

		dbSelectArea('SB1')
		SB1->(dbSetOrder(01))
		SB1->(dbSeek(xFilial('SB1')+(cPrefix)->ZNF_COD))	    	    

		/* Inicio informações Itens da Nota Fiscal */           
		Aadd(_aLinha,{"D1_FILIAL"	,cFilAnt     			,Nil})
		Aadd(_aLinha,{"D1_ITEM"     ,STRZERO(nTotItem++,4)  ,Nil}) //	
		Aadd(_aLinha,{"D1_COD"      , SB1->B1_COD		    ,Nil}) //Alltrim((cPrefix)->ZNF_COD tIREI PEDIDOS DA LINHA DE BAIXO 
		//Se não for Beneficiamento
		If !((cPrefix)->ZNF_TIPO $ 'B/D')
			// Tratamento para verficiar se existe nota de origem
			If !Empty((cPrefix)->ZNF_NFORI)                      

				If !((cPrefix)->ZNF_TIPO $ 'I_P_C')                                                                                                         
					dbSelectArea('SD2')
					SD2->(dbSetOrder(03))
					SD2->(dbSeek(xFilial('SD2')+ALLTRIM((cPrefix)->ZNF_NFORI)+SUBSTR((cPrefix)->ZNF_SERORI,1,3)+SA2->A2_COD+SA2->A2_LOJA+Substr((cPrefix)->ZNF_COD,1,TamSX3("D2_COD")[1])+(cPrefix)->ZNF_ITEORI))

					If !Eof()                       
						Aadd(_aLinha,{"D1_NFORI"  	,SD2->D2_DOC		,Nil})
						Aadd(_aLinha,{"D1_SERIORI"	,SD2->D2_SERIE		,Nil})
						Aadd(_aLinha,{"D1_ITEMORI"	,SD2->D2_ITEM		,Nil})
						Aadd(_aLinha,{"D1_LOTECTL"	,SD2->D2_LOTECTL	,Nil})
						Aadd(_aLinha,{"D1_DTVALID"	,SD2->D2_DTVALID	,Nil})
						lOrigem := .T.
					Endif 

					dbSelectArea('SB6')
					SB6->(dbSetOrder(01))
					//B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_IDENT                                                                                                                 
					SB6->(dbSeek(xFilial('SB6')+Substr((cPrefix)->ZNF_COD,1,TamSX3("B6_PRODUTO")[1])+SA2->A2_COD+SA2->A2_LOJA+SD2->D2_IDENTB6))


					If !Eof()
						cLocSB6 := SB6->B6_LOCAL                       
						Aadd(_aLinha,{"D1_IDENTB6"  	,SB6->B6_IDENT		,Nil})
					Else
						//__cLogMsg := 'Não existe saldo em Poder de terceiro para esta nota.'
					Endif 
				Else 
					//Tratamento para vincular nota de origem para complemento de preço, ipi e icms
					//Leonardo Viana 29/05/2017.
					Aadd(_aLinha,{"D1_NFORI"  	,ALLTRIM((cPrefix)->ZNF_NFORI)		,Nil})
					Aadd(_aLinha,{"D1_SERIORI"	,SUBSTR((cPrefix)->ZNF_SERORI,1,3)		,Nil})				
				Endif

			Else
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				//->Leonardo Perrella Tratamento notas de TRANSF DE CRED ACUMUL. DE ICMS e Saldo.                                 						 |
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				If (cPrefix)->ZNF_TIPO == 'I' .And. Substr(Posicione("SF4",1,xFilial("SF4")+(cPrefix)->ZNF_TES,"F4_CF"),2,3) == '602'
					Aadd(_aLinha,{"D1_NFORI"  	,"999999999"		,Nil})
					Aadd(_aLinha,{"D1_SERIORI"  ,"   "		,Nil})
				EndIf
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				//<-Leonardo Perrella Tratamento notas de TRANSF DE CRED ACUMUL. DE ICMS e Saldo.                                 						 |
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|						
			Endif	
		Else
			If !Empty((cPrefix)->ZNF_NFORI)
				dbSelectArea('SD2')
				SD2->(dbSetOrder(03))
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				//->Leonardo Perrella Alterado para pegar o fornecedor SA2.                                 							 |
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|  
				aRet := TamSX3("D2_COD")
				nQtdAba := aRet[1]
				cCodAba := Substr((cPrefix)->ZNF_COD,1,	nQtdAba)
				//SD2->(dbSeek(xFilial('SD2')+ALLTRIM((cPrefix)->ZNF_NFORI)+SUBSTR((cPrefix)->ZNF_SERORI,1,3)+SA1->A1_COD+SA1->A1_LOJA+(cPrefix)->ZNF_COD+(cPrefix)->ZNF_ITEORI))
				SD2->(dbSeek(xFilial('SD2')+ALLTRIM((cPrefix)->ZNF_NFORI)+SUBSTR((cPrefix)->ZNF_SERORI,1,3)+SA1->A1_COD+SA1->A1_LOJA+cCodAba+(cPrefix)->ZNF_ITEORI))
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				//<-Leonardo Perrella Alterado para pegar o fornecedor SA2.                                 							 |
				//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
				If !Eof()                       
					Aadd(_aLinha,{"D1_NFORI"  	,SD2->D2_DOC		,Nil})
					Aadd(_aLinha,{"D1_SERIORI"	,SD2->D2_SERIE		,Nil})
					Aadd(_aLinha,{"D1_ITEMORI"	,SD2->D2_ITEM		,Nil})
					Aadd(_aLinha,{"D1_LOTECTL"	,SD2->D2_LOTECTL	,Nil})
					Aadd(_aLinha,{"D1_DTVALID"	,SD2->D2_DTVALID	,Nil})
					lOrigem := .T.
				Endif

				dbSelectArea('SB6')
				SB6->(dbSetOrder(01))
				//B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_IDENT   
				aRet := TamSX3("B6_PRODUTO")
				nQtdAba := aRet[1]                                                                                                              
				SB6->(dbSeek(xFilial('SB6')+Substr((cPrefix)->ZNF_COD,1,nQtdAba)+SA1->A1_COD+SA1->A1_LOJA+SD2->D2_IDENTB6))

				If !Eof()                       
					Aadd(_aLinha,{"D1_IDENTB6"  	,SB6->B6_IDENT		,Nil})
				Endif  
			EndIf
		Endif
		//Nunca tirar o campo pedido e item desta posição
		dbSelectArea('SC7')  
		SC7->(dbSetOrder(01))
		SC7->(dbSeek(xFilial('SC7')+(cPrefix)->ZNF_PEDIDO+Alltrim((cPrefix)->ZNF_ITEMPC)))
		If (cPrefix)->ZNF_TIPO $ 'N_I_P_C'		         
			If !Empty((cPrefix)->ZNF_PEDIDO)
				Aadd(_aLinha,{"D1_PEDIDO"   ,Alltrim((cPrefix)->ZNF_PEDIDO) ,Nil})
				Aadd(_aLinha,{"D1_ITEMPC"   ,Alltrim((cPrefix)->ZNF_ITEMPC) ,Nil})			
			Endif
		Endif						
		Aadd(_aLinha,{"D1_UM"       ,SB1->B1_UM     		   	,Nil})
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//->Leonardo Perrella Tratamento para complemento de icms, complemento de IPI e complemento de Preço. O campo não entra no array.                                 	 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		If !(cPrefix)->ZNF_TIPO $ 'I/P/C'
			Aadd(_aLinha,{"D1_QUANT"    ,(cPrefix)->ZNF_QUANT   ,Nil})
		EndIf
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//<-Leonardo Perrella Tratamento para complemento de icms. O campo não entra no array.                                 	 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|	                   		
		If !((cPrefix)->ZNF_TIPO $ 'I/P/C') .or. !(cPrefix)->ZNF_TIPO == 'P'  .or. !(cPrefix)->ZNF_TIPO == 'C'  
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			//->Leonardo Perrella Caso for contrado e a margem for até 0.09 centavos pega o valor unitário do pedido                 |
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			If SC7->C7_TIPO == 2 .And. SC7->C7_PRECO <> (cPrefix)->ZNF_VUNIT .And. ABS(SC7->C7_PRECO - (cPrefix)->ZNF_VUNIT ) <= 0.09
				Aadd(_aLinha,{"D1_VUNIT"    ,SC7->C7_PRECO   			,Nil})	
			Else
				Aadd(_aLinha,{"D1_VUNIT"    ,(cPrefix)->ZNF_VUNIT   	,Nil})                   		
			EndIf
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			//<-Leonardo Perrella Caso for contrado e a margem for até 0.09 centavos pega o valor unitário do pedido                 |
			//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
			Aadd(_aLinha,{"D1_TOTAL"    ,(cPrefix)->ZNF_TOTAL   	,Nil})
		Else
			Aadd(_aLinha,{"D1_VUNIT"    ,(cPrefix)->ZNF_TOTAL   	,Nil})                   		
			Aadd(_aLinha,{"D1_TOTAL"    ,(cPrefix)->ZNF_TOTAL   	,Nil})
		EndIf		
		//Gerar Pré Nota sem enviar a TES
		//Leonardo Vasco Viana de Oliveira
		//08/08/2017 
		If cTpLanc <> 'P'
			dbSelectArea('SF4')
			dbSetOrder(1)
			SF4->(dbSeek(xFilial('SF4')+(cPrefix)->ZNF_TES))	    	    
			Aadd(_aLinha,{"D1_TES"      ,(cPrefix)->ZNF_TES     	,Nil})
		Endif                                            
		//Leonardo Viana 20171218 - Inserir tratamento campo 
		//Criar cmapo ZNF_FCICOD Caracter de 100
		cUsaXoper  := AllTrim(Posicione("SX3",2,"ZNF_FCICOD","X3_CAMPO"))
		If !Empty(cUsaXoper)
			If !Empty((cPrefix)->ZNF_FCICOD)
				Aadd(_aLinha,{"D1_FCICOD" 	 ,(cPrefix)->ZNF_FCICOD 	,Nil}) 
			Endif	                                                        
		Endif	

		cUsaXoper  := AllTrim(Posicione("SX3",2,"D1_XOPER","X3_CAMPO"))		
		If !Empty(cUsaXoper)
			If Empty((cPrefix)->ZNF_PEDIDO)// Campo especifico Nepomuceno.
				Aadd(_aLinha,{"D1_XOPER" 	 ,(cPrefix)->ZNF_XOPER  	,Nil}) 
			Endif	                                                        
		Endif	

		If AllTrim(UPPER((cPrefix)->ZNF_LOTEFO)) != "ABAX" .And. !lOrigem
			Aadd(_aLinha,{"D1_LOTEFOR"    ,Alltrim(UPPER((cPrefix)->ZNF_LOTEFO))	,Nil}) 
			Aadd(_aLinha,{"D1_LOTECTL"    ,Alltrim(UPPER((cPrefix)->ZNF_LOTECT))	,Nil}) 
			Aadd(_aLinha,{"D1_DTVALID"    ,Stod((cPrefix)->ZNF_DTVALI)	,Nil}) 
			Aadd(_aLinha,{"D1_DFABRIC"    ,Stod((cPrefix)->ZNF_DFABRI)	,Nil}) 	
		EndIf	

		If SF4->F4_TRANFIL = 'S'
			Aadd(_aLinha,{"D1_NFORI"  	,(cPrefix)->ZNF_DOC,Nil})
			Aadd(_aLinha,{"D1_SERIORI"	,(cPrefix)->ZNF_SERIE,Nil})
		Endif

		//Tratamento Local de armazenamento: 
		//Leonardo Vasco Viana de Oliveira 06/06/2017.
		//Criação do parametro MA_LOCSB6, .T. busca o lote indicado na tabela SB6(Saldo Poder de Terceiros), .F. não envia nada referente a 
		//Local e o tratamento será o padrão do Protheus.  
		//Caso não exista lote na ZNF pegará o Lote do Pedido de Compras
		If !Empty((cPrefix)->ZNF_LOCAL)
			Aadd(_aLinha,{"D1_LOCAL"  ,(cPrefix)->ZNF_LOCAL 	 	,Nil})
		ElseIf !Empty(cLocSC7)
			//Aadd(_aLinha,{"D1_LOCAL"  ,cLocSC7					 	 	,Nil})		
		Else
			If !Empty(cLocSB6)
				If (_lLOCSB6 == .T.) /////SuperGetMV('MA_LOCSB6',.F.,.T.)	                               
					Aadd(_aLinha,{"D1_LOCAL"  ,cLocSB6 						 	,Nil})		
				Endif	
			Endif	
		Endif

		Aadd(_aLinha,{"D1_FORNECE"  ,(cPrefix)->ZNF_FORNEC 	 	,Nil})
		Aadd(_aLinha,{"D1_LOJA"     ,(cPrefix)->ZNF_LOJA     	,Nil})				
		Aadd(_aLinha,{"D1_DOC"      ,(cPrefix)->ZNF_DOC      	,Nil})
		Aadd(_aLinha,{"D1_EMISSAO"  ,Stod((cPrefix)->ZNF_EMISSA),Nil})		
		Aadd(_aLinha,{"D1_DTDIGIT"  ,DDATABASE 					,Nil})		
		Aadd(_aLinha,{"D1_SERIE"    ,(cPrefix)->ZNF_SERIE     	,Nil})										
		Aadd(_aLinha,{"D1_TIPO"     ,(cPrefix)->ZNF_TIPO      	,Nil}) 		
		Aadd(_aLinha,{"D1_VALDESC"	,(cPrefix)->ZNF_VALDES		,Nil}) 

		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//->Leonardo Perrella Tratamento para complemento de icms. O campo não entra no array.                                 	 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		If !(cPrefix)->ZNF_TIPO == 'I'
			If lVlZero // Tratamento valor zerado 07/04/2017 - Leonardo Viana
				If (cPrefix)->ZNF_VALICM > 0
					Aadd(_aLinha,{"D1_VALICM" ,(cPrefix)->ZNF_VALICM   ,Nil})
				Endif
			Else
				Aadd(_aLinha,{"D1_VALICM"    ,(cPrefix)->ZNF_VALICM   ,Nil})
			Endif
		Endif
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//<-Leonardo Perrella Tratamento para complemento de icms. O campo não entra no array.                                 	 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|	
		If lVlZero // Tratamento valor zerado 07/04/2017 - Leonardo Viana
			If (cPrefix)->ZNF_PICM > 0
				Aadd(_aLinha,{"D1_PICM"  ,(cPrefix)->ZNF_PICM     ,Nil})
			Endif
		Else
			Aadd(_aLinha,{"D1_PICM"     ,(cPrefix)->ZNF_PICM     ,Nil})  
		Endif
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//->Leonardo Perrella Tratamento para complemento de icms. O campo não entra no array.                                 	 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		If !(cPrefix)->ZNF_TIPO == 'I'	
			If lVlZero // Tratamento valor zerado 07/04/2017 - Leonardo Viana
				If (cPrefix)->ZNF_BSICM > 0
					Aadd(_aLinha,{"D1_BASEICM"  ,(cPrefix)->ZNF_BSICM    ,Nil})
				Endif	                                                        
			Else
				Aadd(_aLinha,{"D1_BASEICM"  ,(cPrefix)->ZNF_BSICM    ,Nil})
			Endif	
		Endif   
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//<-Leonardo Perrella Tratamento para complemento de icms. O campo não entra no array.                                 	 |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		If lVlZero // Tratamento valor zerado 07/04/2017 - Leonardo Viana		
			If (cPrefix)->ZNF_ICMSCO > 0		
				Aadd(_aLinha,{"D1_ICMSCOM"  ,(cPrefix)->ZNF_ICMSCO   	,Nil})	//ICMS COMPLEMENTAR
			Endif
		Else		
			Aadd(_aLinha,{"D1_ICMSCOM"  ,(cPrefix)->ZNF_ICMSCO   	,Nil})	//ICMS COMPLEMENTAR
		Endif

		Aadd(_aLinha,{"D1_BASEIPI"  ,(cPrefix)->ZNF_BSIPI 	 	,Nil})	//BASE DE CALCULO 242
		Aadd(_aLinha,{"D1_IPI" 		 ,(cPrefix)->ZNF_PIPI	 	,Nil})	//Valor do IPI - ALIQUOTA 243			
		Aadd(_aLinha,{"D1_VALIPI" 	 ,(cPrefix)->ZNF_VALIPI  	,Nil})	//- VALOR IPI 244

		If (cPrefix)->ZNF_ALQPIS > 0	
			Aadd(_aLinha,{"D1_ALQPIS" ,(cPrefix)->ZNF_ALQPIS	,Nil})
		Endif

		If (cPrefix)->ZNF_ALQCOF > 0	
			Aadd(_aLinha,{"D1_ALQCOF" ,(cPrefix)->ZNF_ALQCOF	,Nil})  //326 a 342 Tratamento para Impostos de Serviços 
		Endif

		If (cPrefix)->ZNF_ALQCSL > 0	
			Aadd(_aLinha,{"D1_ALQCSL" ,(cPrefix)->ZNF_ALQCSL	,Nil})
		Endif

		If	(cPrefix)->ZNF_VALPIS > 0
			Aadd(_aLinha,{"D1_VALPIS" ,(cPrefix)->ZNF_VALPIS	,Nil})
		Endif

		If (cPrefix)->ZNF_VALCSL > 0	
			Aadd(_aLinha,{"D1_VALCSL" 	 ,(cPrefix)->ZNF_VALCSL	,Nil})
		Endif

		If (cPrefix)->ZNF_VALCOF > 0	
			Aadd(_aLinha,{"D1_VALCOF" 	 ,(cPrefix)->ZNF_VALCOF		,Nil})
		Endif

		If (cPrefix)->ZNF_BASPIS > 0	
			Aadd(_aLinha,{"D1_BASEPIS"	 ,(cPrefix)->ZNF_BASPIS		,Nil})
		Endif

		If (cPrefix)->ZNF_BASCOF > 0	
			Aadd(_aLinha,{"D1_BASECOF"	,(cPrefix)->ZNF_BASCOF		,Nil})
		Endif

		If (cPrefix)->ZNF_BASCSL > 0	
			Aadd(_aLinha,{"D1_BASECSL"	,(cPrefix)->ZNF_BASCSL		,Nil}) 
		Endif	

		If	(cPrefix)->ZNF_BASIRR > 0
			Aadd(_aLinha,{"D1_BASEIRR"	,(cPrefix)->ZNF_BASIRR		,Nil})
		Endif

		If (cPrefix)->ZNF_ALIIRR > 0
			Aadd(_aLinha,{"D1_ALIQIRR"	,(cPrefix)->ZNF_ALIIRR		,Nil})
		Endif

		If (cPrefix)->ZNF_VALIRR > 0
			Aadd(_aLinha,{"D1_VALIRR" 	,(cPrefix)->ZNF_VALIRR		,Nil})
		Endif

		If (cPrefix)->ZNF_BASISS > 0	
			Aadd(_aLinha,{"D1_BASEISS"	,(cPrefix)->ZNF_BASISS		,Nil})
		Endif
		// Parametros para não enviar estes impostos
		If lVlZero // Tratamento valor zerado 07/04/2017 - Leonardo Viana		
			If (cPrefix)->ZNF_BRICMS > 0 //- N - 14 - 2 - Ret ICMS
				Aadd(_aLinha,{"D1_BRICMS" 	,(cPrefix)->ZNF_BRICMS		,Nil})
			Endif
		Else                                                              
			Aadd(_aLinha,{"D1_BRICMS" 	,(cPrefix)->ZNF_BRICMS		,Nil})
		Endif 

		If lVlZero // Tratamento valor zerado 07/04/2017 - Leonardo Viana				
			If (cPrefix)->ZNF_ALISOL > 0
				Aadd(_aLinha,{"D1_ALIQSOL" 	,(cPrefix)->ZNF_ALISOL		,Nil})
			Endif
		Else  
			Aadd(_aLinha,{"D1_ALIQSOL" 	,(cPrefix)->ZNF_ALISOL		,Nil})		
		Endif 	
		If (cPrefix)->ZNF_ICMRET > 0
			Aadd(_aLinha,{"D1_ICMSRET" 	,(cPrefix)->ZNF_ICMRET		,Nil})
		Endif
		//Tratamento para enviar a Conta Contábil do Pedido de Compras - 14/09/2017 - Leonardo Viana
		If  !Empty(Alltrim((cPrefix)->ZNF_CONTA)) // > 0 //- Conta Contábil
			Aadd(_aLinha,{"D1_CONTA" 	,(cPrefix)->ZNF_CONTA		,Nil})
		ElseIf !Empty(SC7->C7_CONTA)                                                          
			Aadd(_aLinha,{"D1_CONTA" 	,SC7->C7_CONTA		,Nil})				
		Endif		

		If !Empty(SC7->C7_ITEMCTA)
			Aadd(_aLinha,{"D1_ITEMCTA" 	,SC7->C7_ITEMCTA		,Nil})
		Endif               

		If (cPrefix)->ZNF_ABATMA > 0 //- N - 14 - 2 - Abatimento ISS material  
			Aadd(_aLinha,{"D1_ABATMAT"  ,(cPrefix)->ZNF_ABATMA  ,Nil})
		Endif

		If (cPrefix)->ZNF_BASEIN > 0 //- N - 14 - 2 - Abatimento ISS material  
			Aadd(_aLinha,{"D1_BASEINS"  ,(cPrefix)->ZNF_BASEIN  ,Nil})
		Endif

		If (cPrefix)->ZNF_ALIQIN > 0 //- N - 14 - 2 - Abatimento ISS material  
			Aadd(_aLinha,{"D1_ALIQINS"  ,(cPrefix)->ZNF_ALIQIN  ,Nil})
		Endif

		If (cPrefix)->ZNF_VALIN > 0 //- N - 14 - 2 - Abatimento ISS material  
			Aadd(_aLinha,{"D1_VALINS"  ,(cPrefix)->ZNF_VALIN  ,Nil})
		Endif      

		If (cPrefix)->ZNF_ALIISS > 0	
			Aadd(_aLinha,{"D1_ALIQISS"	,(cPrefix)->ZNF_ALIISS	,Nil})
		Endif

		If (cPrefix)->ZNF_VALISS > 0	
			Aadd(_aLinha,{"D1_VALISS" 	, (cPrefix)->ZNF_VALISS ,Nil})			
		Endif

		//Tratamento para CTe registrado pela Rotina MATA103. Leonardo Viana 23/03/2017
		//If !Empty(Alltrim((cPrefix)->ZNF_TPCTE))
		//Aadd(_aLinha,{"D1_TPCTE" 	, (cPrefix)->ZNF_TPCTE , Nil})//  - C - 1 - Tipo do CTE - N=Normal;C=Complem.Valores;A=Anula.Valores;S=Substituto	
		//Endif                                   

		If !Empty(Alltrim((cPrefix)->ZNF_CFOP))      
			Aadd(_aLinha,{"D1_CF" 	, (cPrefix)->ZNF_CFOP , Nil})
		Endif		

		If !Empty(Alltrim((cPrefix)->ZNF_CC))
			//Conout('MTUFOPRO - VERIFICAR CENTRO DE CUSTOS DA ZNF')
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'MTUFOPRO - VERIFICAR CENTRO DE CUSTOS DA ZNF')

			dbSelectArea('CTT')
			CTT->(dbSetOrder(01))
			CTT->(dbSeek(xFilial('CTT')+Alltrim((cPrefix)->ZNF_CC)))
			If !Eof()
				//Conout('MTUFOPRO - ACHOU O CENTRO DE CUSTOS DA ZNF')
				FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'MTUFOPRO - ACHOU O CENTRO DE CUSTOS DA ZNF')
				Aadd(_aLinha,{"D1_CC" 		,Alltrim((cPrefix)->ZNF_CC),Nil})
			Else
				FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'MTUFOPRO -NÃO ACHOU O CENTRO DE CUSTOS DA ZNF')
				//Conout('MTUFOPRO -NÃO ACHOU O CENTRO DE CUSTOS DA ZNF')				
			Endif	
		Else  //Tratamento para enviar Centro de Custo do Pedido de Compras 08/01/2018, caso não exista o CC no Pedido, manda o CC do Produto.
			If !Empty(Alltrim(SC7->C7_CC))
				Aadd(_aLinha,{"D1_CC" 		,SC7->C7_CC,Nil})
			Else
				Aadd(_aLinha,{"D1_CC" 		,SB1->B1_CC,Nil})   		
			Endif	
		Endif
		//Leonardo Vasco Viana 30/01/2018 - Levar Conta Contábil quando não estiver preenchida no pedido para o campo D1_CONTA.
		If !Empty(Alltrim(SC7->C7_CONTA))
			Aadd(_aLinha,{"D1_CONTA" 		,SC7->C7_CONTA,Nil})
		Else
			Aadd(_aLinha,{"D1_CONTA" 		,SB1->B1_CONTA,Nil})   		
		Endif

		//    ZNF_DIRF	C	10		Gera Dirf
		//		ZNF_INCISS	C	20		Mu Incid ISS
		//		ZNF_ESTPRE	C	2		Est Prestd
		//Aadd(_aLinha,{"D1_DOCSEQ" 		,Alltrim(cProxSeq),Nil})						       									
		Aadd(_aLinha,{"AUTDELETA"    ,"N"                    	,Nil})

		Aadd(_aItensSD1,_aLinha)
		dbSelectArea(cPrefix)
		cTpLanc := Alltrim((cPrefix)->ZNF_TPLANC)
		cLocSB6 := ""   
		nTotAbax := Val((cPrefix)->ZNF_ITEM) ////Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para só importar quando todos os itens forem enviados para a ZNF.
		(cPrefix)->(dbSkip())
		/* Verifica se proximo registro é outra Nota, se sim deve realizar a importaçao da nota*/
		If __cSeekNF != (cPrefix)->ZNF_DOC+(cPrefix)->ZNF_SERIE+(cPrefix)->ZNF_FORNEC+(cPrefix)->ZNF_LOJA		
			//ABAX_SX3(_aCabSF1,_aItensSD1) //Valida array de cabeçalho e itens de acordo com o SX3 do cliente.
			ABAX_SX3()
			////Leonardo Viana 09/01/2018 - Total de Itens a serem importados. Melhoria para só importar quando todos os itens forem enviados para a ZNF.
			If nTotAbax > 0
				If nTotAbax <> nToItem   
					lErroAba:= .T.  
					cError += ' Problema na Exportação da Nota Fiscal para a ZNF, favor exportar a Nota Fiscal Novamente.'
				Endif				
			Endif	  
			nToItem := 0
			lMsErroAuto:=.F.						

			If !lErroAba
				Begin transaction 
					//Tratamento para classificar Pre Nota enviadas pelo Ábax. 
					//Requisito integração com WMS.
					//14/08/2017 - Leonardo Vasco Viana de Oliveira.
					If cTpLanc = 'P'                                            
						//Inclusão de Pré-Nota
                        MEMOWRITE("MTUFOPRO_LEEF_INC_PRENOTA_"+cEmpABax+"_"+FWTimeStamp(1)+".TXT", varinfo('_aCabSF1', _aCabSF1) + CRLF + varinfo('_aItensSD1', _aItensSD1))   
						MSExecAuto({|x,y,z|Mata140(x,y,z)},_aCabSF1,_aItensSD1,3)	
					ElseIf cTpLanc = 'W'	
						//Classificação de Pré Nota
                        MEMOWRITE("MTUFOPRO_LEEF_CLA_PRENOTA_"+cEmpABax+"_"+FWTimeStamp(1)+".TXT", varinfo('_aCabSF1', _aCabSF1) + CRLF + varinfo('_aItensSD1', _aItensSD1))   
						MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,4)         			
					ElseIf  cTpLanc = 'E' 
						//Exclusão de Nota Fiscal                                                        
                        MEMOWRITE("MTUFOPRO_LEEF_EXCL_NF_"+cEmpABax+"_"+FWTimeStamp(1)+".TXT", varinfo('_aCabSF1', _aCabSF1) + CRLF + varinfo('_aItensSD1', _aItensSD1))   
						MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,4)         			
					Else                        
						//Inclusão de Nota Fiscal
                        MEMOWRITE("MTUFOPRO_LEEF_INC_NF_"+cEmpABax+"_"+FWTimeStamp(1)+".TXT", varinfo('_aCabSF1', _aCabSF1) + CRLF + varinfo('_aItensSD1', _aItensSD1))   
						MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,3)         								
					Endif

				End Transaction 
			Endif
			lErroAba:= .F.           
			cDataX  := DtoC(Date()) 
			cTimeX  := Time() 

			ErrorBlock(oLastError)			
			__cLogMsg := Space(1)
			If !empty(cError)
				__cLogMsg := cError
			Endif

			If lMsErroAuto	.Or. !Empty(cError)	        
				If Len(Alltrim(__cLogMsg)) = 0
					__cLogMsg:= " "
				Endif
				aLog := {}
				aLog := GetAutoGRLog()	
				cLogFile := ( 'LOG_' +  __cSeekNF + '_Dt' + DtoS( Date() ) + '_Hr' + StrTran( Time() , ':' , '' ) + '.TXT' )		
				//aEval(GetAutoGRLog(),{|BUFFER| __cLogMsg += (BUFFER + ' ') })//_CRLF) })	  	
                MEMOWRITE("C:\LEEF\ERRO_MTUFOPRO_"+cDocSMA+"_"+cSerSMA+"_"+cForSMA+"_"+cLojSMA+".TXT", varinfo('_aCabSF1', _aCabSF1) + CRLF + varinfo('_aItensSD1', _aItensSD1))   
				aEval(aLog,{|BUFFER| __cLogMsg += (BUFFER + CHR(13)+CHR(10)) })
				FAtuaStat(cDocSMA,cSerSMA,cForSMA, cLojSMA,.F., __cLogMsg+'- Data ' + cDataX+'- Hora '+cTimeX)
			Else                     
				/* Função utilizada para atualizar campo status da Nota, impossibilitando que a mesma seja importada novamente */				
                MEMOWRITE("C:\LEEF\MTUFOPRO_"+cDocSMA+"_"+cSerSMA+"_"+cForSMA+"_"+cLojSMA+".TXT", varinfo('_aCabSF1', _aCabSF1) + CRLF + varinfo('_aItensSD1', _aItensSD1))   
				FAtuaStat(cDocSMA,cSerSMA,cForSMA, cLojSMA,.T.,'Processado com Sucesso.'+'- Data ' + cDataX+'- Hora '+cTimeX+ '-' +Alltrim(__cLogMsg) )		
			Endif  
			/* Atualizar variaveis que são utilizada na definição para gerar a Nota na base */
			_aCabSF1	:= {}
			_aItensSD1	:={}
			lImport		:=.F.
			nVBrtAbax   := 0
			//cProxAba := SOMA1(PadR(cProxSeq,6),,,.T.) //
			//cProx := Soma1(PadR((cRetSEQ)->D1_NUMSEQ,6),,,.T.)
			//PutMV("MV_DOCSEQ",cProxAba)			
			cProxSeq := Ver_DOCSEQ() // Retornar o D1_NUMSEQ para a tabela SD1 --cProx := Soma1(PadR(SuperGetMv("MV_DOCSEQ"),nTamSeq),,,.T.)
			//cProxAba :=Space(6)
			PutMV("MV_DOCSEQ",cProxSeq)

		Endif
		nZ++				
	EndDo
	/* Restaura Area de todas as tabelas envolvidas */	 

	cProxSeq := Ver_DOCSEQ() // Retornar o D1_NUMSEQ para a tabela SD1 --cProx := Soma1(PadR(SuperGetMv("MV_DOCSEQ"),nTamSeq),,,.T.)
	PutMV("MV_DOCSEQ",cProxSeq)

	//Conout('TOTAL DE NOTAS PROCESSADAS ' + str(nZ))
	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'TOTAL DE NOTAS PROCESSADAS ' + str(nZ))
	dbSelectArea(cPrefix)
	dbCloseArea()

	RestArea(aAreaSB1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF4)

Return(lMsErroAuto) //Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FAtuaStat

Função utilizada para atualizar status das Notas apos importação
futuros problemas na UFO
@author 	Helder Santos
@Paramt		cCodNota - Codigo da Nota Fiscal
@Paramt		cCodSer - Codigo da Serie
@Paramt		cCGCFor - CNPJ do fornecedor
@since		04.04.2014
@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
Static Function FAtuaStat(cCodNota, cCodSer, cCodFor, cLojFor,lOk,cMsg)

	Local cQryExc	:= ''  
	//Local lUpOk		:= .F.
	Local cDbase   := Alltrim(TCGetDB()) //Verificar qual é o Banco de Dados do cliente.
	Local cRetZNF :=  GetNextAlias()
	Local aAreaZ   := GetArea()  

	If lOk
		cStatus := '2'
	Else	              
		cStatus := '3'
	Endif   	
	//Leonardo Vasco Viana de Oliveira
	//03/08/2017
	//Alteração para alterar modo de gravação na ZNF, de Update direto no banco para Replace seguindo o padrão do Protheus

	If cDbase <> 'ORACLE'   

		cQryExc := " SELECT R_E_C_N_O_ FROM "+ RetSqlName("ZNF")
		cQryExc += " WHERE ZNF_DOC = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERIE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORNEC = '"+cCodFor+"' "   
		cQryExc += " AND ZNF_LOJA = '"+	cLojFor+"' "

		dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cRetZNF   , .F. , .F. )

		dbSelectArea(cRetZNF)
		dbGotop()            

		Do While !Eof()  

			dbSelectArea('ZNF')
			dbGoto((cRetZNF)->R_E_C_N_O_)
			If !Eof()
				RecLock("ZNF",.F.)		      
				Replace ZNF_STATUS With Alltrim(cStatus)
				Replace ZNF_LOG    With Alltrim(cMsg)
				Replace ZNF_DATA   With dDataBase
				MsUnLock()
			EndIf

			dbSelectArea(cRetZNF)
			dbSkip()
		Enddo	             
		dbSelectArea(cRetZNF)
		dbCloseArea()                       

		/*     Código comentado em 03/08/2017 por Leonardo Vasco Viana de Oliveira
		cQryExc += " UPDATE "+RetSqlName("ZNF") +" SET ZNF_STATUS = '"+Alltrim(cStatus)+"' , ZNF_LOG = '"+cMsg+"', ZNF_DATA = '" +DTOS(dDataBase)+"' "
		cQryExc += " WHERE ZNF_DOC = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERIE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORNEC = '"+cCodFor+"' "   
		cQryExc += " AND ZNF_LOJA = '"+	cLojFor+"' "

		If (TCSQLExec(cQryExc) < 0)
		conout("TCSQLError() " + TCSQLError())
		EndIf*/
	Else // Tratamento para Oracle
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//->Leonardo Perrella Alterado a query para preencher o campo memo com todos os caracaters. A função RAWTOHEX estava     |
		//limitando.                                                                                                             |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		/*                                                                                                             
		cQryExc += " UPDATE "+RetSqlName("ZNF") +" SET ZNF_STATUS = '"+Alltrim(cStatus)+"' , ZNF_LOG = RAWTOHEX('" +cMsg+"'), ZNF_DATA = '" +DTOS(dDataBase)+"' "
		cQryExc += " WHERE ZNF_DOC = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERIE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORNEC = '"+cCodFor+"' "   
		cQryExc += " AND ZNF_LOJA = '"+	cLojFor+"' "
		*/

		cQryExc +="DECLARE"+CHR(13)+CHR(10)
		cQryExc +="LONGLITERAL RAW(32767) := UTL_RAW.CAST_TO_RAW('" +cMsg+"');"+CHR(13)+CHR(10)
		cQryExc +="BEGIN"+CHR(13)+CHR(10)
		cQryExc +="EXECUTE IMMEDIATE"+CHR(13)+CHR(10)
		cQryExc +="'UPDATE "+RetSqlName("ZNF")+""+CHR(13)+CHR(10)
		cQryExc +="SET ZNF_STATUS = "+Alltrim(cStatus)+" ,"+CHR(13)+CHR(10) 
		cQryExc +="ZNF_DATA = " +DTOS(dDataBase)+","+CHR(13)+CHR(10)
		cQryExc +="ZNF_LOG = :1"+CHR(13)+CHR(10) 
		cQryExc +="WHERE ZNF_DOC = "+cCodNota+""+CHR(13)+CHR(10)
		cQryExc +="AND ZNF_SERIE = ''' || '"+cCodSer+"' || '''"+CHR(13)+CHR(10)
		cQryExc +="AND ZNF_FORNEC = "+cCodFor+""+CHR(13)+CHR(10)
		cQryExc +="AND ZNF_LOJA = "+cLojFor+"'"+CHR(13)+CHR(10) 
		cQryExc +="USING LONGLITERAL;"+CHR(13)+CHR(10)
		cQryExc +="COMMIT;"+CHR(13)+CHR(10)
		cQryExc +="END;"+CHR(13)+CHR(10)
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
		//<-Leonardo Perrella Alterado a query para preencher o campo memo com todos os caracaters. A função RAWTOHEX estava     |
		//limitando.                                                                                                             |
		//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|

		If (TCSQLExec(cQryExc) < 0)
			//conout("TCSQLError() " + TCSQLError())
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "TCSQLError() " + TCSQLError())
		EndIf

		If (TCSQLExec('commit') < 0)           
			//conout("TCSQLError() " + TCSQLError())
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "TCSQLError() " + TCSQLError())
		endif		
	Endif		
	RestArea(aAreaZ)

Return(Nil)


//------------------------------------------------------------------- 
/*/{Protheus.doc} SCHVNFE

Função responsavel por importar Notas Fiscais para o Protheus individualmente
atráves da Chave da DANFE.
@author 	Leonardo Viana
@since		21.07.2015
@Return		
@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/


User Function SCHVNFE() // Processa chave da Danfe individualmente

	cSCHVDF := space(44)

	@ 0,0 to 200,400 Dialog oDlg1 Title " SMARTNFE- Processamento DANFE Individual "

	@ 10, 10 say oemtoansi("Insira Chave da DANFE ")

	@ 30, 10 get cSCHVDF size 140,200//F3 "SED"  70,200

	@ 75,55 Button "_Ok" Size 35,15 Action BuscaCHV(cSCHVDF)  //115

	Activate Dialog oDlg1 Center

Return                                  


//------------------------------------------------------------------- 
/*/{Protheus.doc} BuscaCHV

Função responsavel por importar Notas Fiscais para o Protheus individualmente
atráves da Chave da DANFE.
@author 	Leonardo Viana
@since		21.07.2015 
@Parameter  Chave da DANFE
@Return		
@version	P11

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
Static Function BuscaCHV(cChvDANFE)         

	Local cPrefix  
	Local cQryExc	:= '' 

	cQryExc += CRLF +" SELECT * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + xFilial('ZNF')+"'and "
	cQryExc += CRLF +" ZNF_STATUS <> '2' AND "     
	cQryExc += CRLF +" ZNF_CHVNFE = '" + cChvDANFE + "' AND "     
	cQryExc += CRLF +" D_E_L_E_T_ <> '*' "      
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "      

	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cPrefix := GetNextAlias() , .F. , .F. )

	dbSelectArea(cPrefix)
	dbGotop()

	If !empty((cPrefix)->ZNF_CHVNFE)

		If !FSGeraNFE(cPrefix)
			MsgStop("Nota Importada com Sucesso!" )
		Else
			MsgStop("Nota não Importada, verifique o Log no SmartNFE!")
		Endif
	Else
		MsgStop("Chave da DANFE não Consta no SmartNFE, Favor Verificar")
	Endif	

	dbSelectArea(cPrefix)
	dbCloseArea()

	Close(oDlg1)

Return		

//------------------------------------------------------------------- 
/*{Protheus.doc} Abax_SX3

Função responsavel por validar se todos os campos dos arrays de cabeçalho e itens estão no Sx3 do cliente.
@author 	Leonardo Viana
@since		16.11.2016 
@Parameter  Array com o cabeçalho e com os itens da nota fiscal.
@Return		
@version	P11

//---------------------------------------------------------------------
*/
Static Function Abax_SX3()
   local nAtual
   Local nx

	aCabAux := {}
	aIteAux := {}
	aItetot := {}           
	aIteOlds:=_aItensSD1 
	_aItensSD1 := {}

	dbSelectArea('SX3')
	aAreaSX3	:= SX3->(GetArea())
	//SX3->(DbGoTop()) //Teste de campos do cabeçalho da nota fiscal    
	SX3->(DBSETORDER(2))
	For nAtual := 1 To Len(_aCabSF1)
		//Se conseguir posicionar
		If SX3->(DbSeek(_aCabSF1[nAtual][1]))		
			Aadd(aCabAux,_aCabSF1[nAtual])
		Endif
	Next	

	SX3->(DbGoTop()) //Teste de campos do cabeçalho da nota fiscal        
	aAreaSX3	:= SX3->(GetArea())
	//dbsetorder(2)
	For nX := 1 To Len(aIteOlds)   

		For nAtual := 1 To Len(aIteOlds[nX])   
			//Se conseguir posicionar
			If SX3->(DbSeek(aIteOlds[nX][nAtual][1])) .or. aIteOlds[nX][nAtual][1] = "AUTDELETA" 		
				Aadd(aIteAux,aIteOlds[nX][nAtual])
			Endif
		Next                                        
		Aadd(_aItensSD1,aIteAux)
		aIteAux:={}
	Next    

	RestArea(aAreaSX3)
	_aCabSF1 := aCabAux

Return

User FUNCTION MTCTEPRO(cEmpAbx, cFilAbx, cIdAbx)
	**********************************************************************************
	*Função que gera CTE através da rotina MATA116
	**********************************************************************************

	//Local cAlias   	:= ' '
	Local aEmpSmar 	:= {}
	//Local aEmpNFe  	:= {}
	Local aInfo   	:= {}
	Local Ni, n
	Local aTables 	:= {"SA1","SA2","SF1","SD1","SF2","SD2","CTT","ZNF", "SF4","SB6","SB1","CT1",'SX6'}//seta as tabelas que serão abertas no rpcsetenv

	Private cCondAbax   := Space(3) //Condicao de pagamento   
	Private dDtVAbax	:= date()
	Private cMAVenc		:= Space(250) //String com dados do vencimento.
	Private nVBrtAbax	:= 0        //Valor Bruto Nota Fiscal     
	Private cUserAbx	:= Space(30) //Gravar Usuário ábax      20170505 Leonardo Vasco Viana

	cError      := "" // Tratamento para erros não amigaveis finalizar a tela.
	oLastError 	:= ErrorBlock({|e| cError := e:Description + e:ErrorStack})

	If Empty(cIdAbx)

		aInfo := GetUserInfoArray()
		For nI := 1 to Len(aInfo)
			If aInfo[nI][5] == "U_MTCTEPRO" .And. aInfo[nI][3] <> Threadid()
				//Conout('---------------------------------------------------------------------------------------------')
				//Conout('Função MTCTEPRO sendo Utilizada! ')
				//Conout('---------------------------------------------------------------------------------------------')
				FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "Função MTCTEPRO sendo Utilizada!")
				Return      
			EndIf
		Next nI

		lthread := .T. 
		RpcSetType(3)
		RpcClearEnv()                  
		RpcSetEnv( '01',, " ", " ", "COM", "MATA116", aTables, , , ,  )/****** COMANDOS *************/

		cUsuSm := Alltrim(SuperGetMV("MA_USUSMA"))
		cSenSm := Alltrim(SuperGetMV("MA_PASSMA"))  //Abax@vaccinar1

		//Conout('---------------------------------------------------------------------------------------------')
		//Conout('INICIO IMPORTAÇÃO ÁBAX - FONTE MTCTEPRO')
		//Conout('---------------------------------------------------------------------------------------------')
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "INICIO IMPORTAÇÃO ÁBAX - FONTE MTCTEPRO")

		dbSelectarea('SM0')
		SM0->(dbGotop())

		Do While SM0->(!Eof())

			Aadd(aEmpSmar,{SM0->M0_CODIGO,SM0->M0_CODFIL})		  			
			SM0->(dbSkip())			

		Enddo		

		RpcClearEnv() //RESET ENVIRONMENT //->[CRITICA] - Remover o RESET ENVIRONMENT desse ponto	   	

		cEmpABax := aEmpSmar[1][1]     
		RpcSetEnv( aEmpSmar[1][1],aEmpSmar[1][2]," " ," " , "COM", "MATA116", aTables, , , ,  )/****** COMANDOS *************/         

		For n:=1 to Len(aEmpSmar)
			If cEmpABax = aEmpSmar[n][1]
				cFilAnt := aEmpSmar[n][2]
				cEmpABax := aEmpSmar[n][1]
			Else
				RpcClearEnv() //RESET ENVIRONMENT //->[CRITICA] - Remover o RESET ENVIRONMENT desse ponto	   	                                     
				cEmpABax := aEmpSmar[n][1]
				RpcSetEnv( aEmpSmar[n][1],aEmpSmar[n][2]," " ," ", "COM", "MATA116", aTables, , , ,  )/****** COMANDOS *************/			
			Endif
			If Select('ZNF') > 0
				U_MImpCTE(aEmpSmar[n][1],aEmpSmar[n][2],cUsuSm,cSenSm)			   
			Else
				//Conout('EMPRESA SEM ZNF' + aEmpSmar[n][1] )
				FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'EMPRESA SEM ZNF' + aEmpSmar[n][1])
			Endif
		Next	

		//Conout('---------------------------------------------------------------------------------------------')
		//Conout('FIM IMPORTAÇÃO SMARTNFE - FONTE MTCTEPRO')
		//Conout('---------------------------------------------------------------------------------------------')
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'FIM IMPORTAÇÃO SMARTNFE - FONTE MTCTEPRO' )

		RpcClearEnv()
	Else	
		RpcSetEnv( cEmpAbx,cFilAbx," " ," ", "COM", "MATA116", aTables, , , ,  ) 
		cUsuSm := Alltrim(SuperGetMV("MA_USUSMA"))
		cSenSm := Alltrim(SuperGetMV("MA_PASSMA"))  
		//cEmpAbx, cFilAbx, cIdAbx                                          
		U_MImpCTE(cEmpAbx,cFilAbx,cUsuSm,cSenSm)			   
	Endif

Return 

User Function MImpCTE(cEmpMa,cFilMa,cUsusm,cSenSm)
	******************************************************************************
	* Função para importar  notas para o Protheus. Foi desmembrado a função devido
	* a empresas que possuem muitas empresas e filiais.
	******************************************************************************

	//Conout('---------------------------------------------------------------------------------------------')
	//Conout('PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTCTEPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa ) 
	//Conout ('SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL)
	//Conout('---------------------------------------------------------------------------------------------')
	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTCTEPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'SIGAMAT.EMP ' + SM0->M0_CODIGO+'-'+SM0->M0_CODFIL )

	Private cPedAbax	 

	cAlias:= FSBusCTE(cFilMa)

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop()) 

	If !Empty((cAlias)->ZNF_DOC) //+(cAlias)->ZNF_SERIE+(cAlias)->ZNF_FORNEC+  (cAlias)->ZNF_LOJA)
		u_FSGeraCTE(cAlias)
		//Conout('---------------------------------------------------------------------------------------------')
		//Conout('FIM PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
		//Conout('---------------------------------------------------------------------------------------------')
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'FIM PROCESSO IMPORTAÇÃO SMARTNFE - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa)
	Else
		//Conout('---------------------------------------------------------------------------------------------')
		//Conout('FIM PROCESSO SEM MOVIMENTO - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
		//Conout('---------------------------------------------------------------------------------------------')		 
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'FIM PROCESSO SEM MOVIMENTO - FONTE MTUFOPRO - Empresa ' +cEmpMa + ' Filial '+cFilMa )
	Endif		 				  						 					

	dbCloseArea()

Return    


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSGeraCTE

Função responsavel pela geração do CTE pela rotina MATA116.
@author 	Leonardo Vasco Viana de Oliveira
@since	22.03.2017
@Parm1	cPrefix - Alias com as informaçoes da CTE
@version	P11

------------------------------------------------------------------------------------------
Programador		Data		Motivo
------------------------------------------------------------------------------------------
/*/                 
User Function FSGeraCTE(cPrefix)


	LOCAL aCabec        := {}
	LOCAL aItens        := {}
	//LOCAL aLinha        := {}
	//Local nX            := 0
	//Local nY            := 0
	//Local nTamFilial       := 0
	//Local lOk           := .T.
	//Local cFilSF1      := ""
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	Local aAreaSF4	:= SF4->(GetArea())    
	//Local cFilAux	:= cFilAnt//Armazena Variavel publica em uma variavel auxiliar, necessario para assim que processo finalizar a mesma deve voltar com a informação inicial
	//Local __cLogFile:= ''   
	Local __cLogMsg	:= ''
	Local __cSeekCT	:= ''                
	Local lImport	:= .F. 
	//Local cEspecie	:= ''  
	//Local cTipoNf	:= ''

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Private cFornece     := ""
	Private cLoja        := ""    
	Private cCHVCTE		:= "" // Chave do CTE
	Private cTipCTE		:= ""// Tipo de CTe 
	Private cEstSM 		:= "" //Estado da Transportadora.s 

	dbSelectArea(cPrefix)
	(cPrefix)->(dbGoTop())		

	Do While (cPrefix)->(!Eof())

		__cSeekCT := (cPrefix)->ZNF_DOCCTE+(cPrefix)->ZNF_SERCTE+(cPrefix)->ZNF_FORCTE+(cPrefix)->ZNF_LOJCTE 

		cDocSMA := 	(cPrefix)->ZNF_DOCCTE
		cSerSMA :=  (cPrefix)->ZNF_SERCTE
		cForSMA := (cPrefix)->ZNF_FORCTE			
		cLojSMA := (cPrefix)->ZNF_LOJCTE			  

		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+(cPrefix)->ZNF_COD))  

		SA2->(dbSetorder(01))
		SA2->(dbSeek(xFilial('SA2')+(cPrefix)->ZNF_FORNEC+(cPrefix)->ZNF_LOJA ))			

		cFornece := SA2->A2_COD
		cLoja    := SA2->A2_LOJA   

		dbSelectArea('SF4')
		dbSetOrder(1)
		SF4->(dbSeek(xFilial('SF4')+(cPrefix)->ZNF_TES))	    	    

		If !lImport      

			aItens := U_Busca_NFs((cPrefix)->ZNF_FILIAL,(cPrefix)->ZNF_DOCCTE,(cPrefix)->ZNF_SERCTE,(cPrefix)->ZNF_FORCTE,(cPrefix)->ZNF_LOJCTE ) // Busca Notas Fiscais

			dbSelectArea("SA2")
			dbSetOrder(1)
			SA2->(dbSeek(xFilial('SA2')+(cPrefix)->ZNF_FORCTE+(cPrefix)->ZNF_LOJCTE))			

			dbSelectArea("SA2")
			dbSetOrder(1)
			SA2->(dbSeek(xFilial('SA2')+(cPrefix)->ZNF_FORNEC+(cPrefix)->ZNF_LOJA ))			
			cEstSM := SA2->A2_EST

			dbSelectArea("SF1")
			dbSetOrder(1)
			dbSeek(xFilial('ZNF')+(cPrefix)->ZNF_DOC+(cPrefix)->ZNF_SERIE+(cPrefix)->ZNF_FORNEC+(cPrefix)->ZNF_LOJA)

			aadd(aCabec,{""			,dDataBase-90})       		// 1 Data Inicial        
			aadd(aCabec,{""			,dDataBase})          		// 2 Data Final        
			aadd(aCabec,{""			,2})                  		// 3 2-Inclusao;1=Exclusao        
			aadd(aCabec,{""			,(cPrefix)->ZNF_FORNEC})  	// 4 Fornecedor do documento de Origem          
			aadd(aCabec,{""			,(cPrefix)->ZNF_LOJA})    	// 5 Loja de origem        
			aadd(aCabec,{""			,1})                      	// 6 Tipo da nota de origem: 1=Normal;2=Devol/Benef        
			aadd(aCabec,{""			,2})                      	// 7 1=Aglutina;2=Nao aglutina        
			aadd(aCabec,{"F1_EST"	   ,cEstSM})  				          // 8 Estado
			aadd(aCabec,{""			   ,(cPrefix)->ZNF_TOTAL})    // 9 Valor do conhecimento        
			aadd(aCabec,{"F1_FORMUL"   ,1})        	            // 10 Formulári/o
			aadd(aCabec,{"F1_DOC"		,(cPrefix)->ZNF_DOCCTE})// 11 Numero da NF de Conhecimento de Frete        
			aadd(aCabec,{"F1_SERIE"		,(cPrefix)->ZNF_SERCTE})// 12 Serie da NF do Conhecimento deFrete        
			aadd(aCabec,{"F1_FORNECE"	,(cPrefix)->ZNF_FORCTE})             // 13 Fornecedor do Frete
			aadd(aCabec,{"F1_LOJA"		,(cPrefix)->ZNF_LOJCTE})                // 14 Loja do Frete
			aadd(aCabec,{""				,(cPrefix)->ZNF_TES})   // 15 TES         '' 
			aadd(aCabec,{"F1_BASERET"	,0})                    // 16 Base Ret
			aadd(aCabec,{"F1_ICMRET"	,0})                    // 17 ICMS Retido
			aadd(aCabec,{"F1_COND"		,(cPrefix)->ZNF_COND})  // 18 Condição dePagametno     
			aadd(aCabec,{"F1_EMISSAO"	,Stod((cPrefix)->ZNF_EMISSA)}) // 19 Emissao       
			aadd(aCabec,{"F1_ESPECIE"	, (cPrefix)->ZNF_ESPEC})//19 Especie        
			aadd(aCabec,{"E2_NATUREZ"	,(cPrefix)->ZNF_NATUR}) //20 Natureza       
			aadd(acabec,{"F1_DESCONTO"	,0})                    //21 Desconto       
			Aadd(aCabec,{"F1_DESPESA"	,(cPrefix)->ZNF_DESPES				})  // 22 Despesas

			//	   	Aadd(aCabec,{"F1_VOLUME1"	,(cPrefix)->ZNF_VOLUME  			}) 	//Inclusão 12/05/2016
			//		Aadd(aCabec,{"F1_FRETE"  	,(cPrefix)->ZNF_FRETE				}) 	//Leonardo Viana 20161116 - Tratar Frete da Nota Fiscal.        			//		               
			//		Aadd(aCabec,{"F1_ZUSER"		,Substr((cPrefix)->ZNF_USERLG,1,25)})    
			//	   	Aadd(aCabec,{"F1_PBRUTO"	,(cPrefix)->ZNF_PBRUTO				})
			//	   	Aadd(aCabec,{"F1_PLIQUI"	,(cPrefix)->ZNF_PLIQUI				})

			lImport := .F.
			cCHVCTE := (cPrefix)->ZNF_CHVNFE
			cTipCTE := (cPrefix)->ZNF_TPCTE
			cPedAbax := (cPrefix)->ZNF_PEDIDO  
			cUserAbx := Substr((cPrefix)->ZNF_USERLG,1,25)
		Endif

		dbSelectArea(cPrefix)
		(cPrefix)->(dbSkip())

		If __cSeekCT != (cPrefix)->ZNF_DOCCTE+(cPrefix)->ZNF_SERCTE+(cPrefix)->ZNF_FORCTE+(cPrefix)->ZNF_LOJCTE 
			//Tratamento para não aparecer erro de nota duplicada Leonardo Vasco 20170505
			If Len(aItens)>0

				lMsErroAuto:=.F.     
				MATA116(aCabec,aItens)

			Endif

			cDataX := DtoC(Date()) 
			cTimeX := Time() 

			ErrorBlock(oLastError)			

			If !empty(cError)
				__cLogMsg := cError
			Endif

			If lMsErroAuto .OR. !Empty(cError)		        
				MostraErro()
				If Len(Alltrim(__cLogMsg)) = 0
					__cLogMsg:= " "
				Endif	                     
				aLog := {}
				aLog := GetAutoGRLog()	
				cLogFile := ( 'LOG_' +  __cSeekCT + '_Dt' + DtoS( Date() ) + '_Hr' + StrTran( Time() , ':' , '' ) + '.TXT' )		
				aEval(GetAutoGRLog(),{|BUFFER| __cLogMsg += (BUFFER + ' ') })//_CRLF) })	  	
				FAtuaCTE(cDocSMA,cSerSMA,cForSMA, cLojSMA,.F., __cLogMsg+'- Data ' + cDataX+'- Hora '+cTimeX)
			Else                     
				// Função utilizada para atualizar campo status da Nota, impossibilitando que a mesma seja importada novamente 
				//MSGSTOP('INCLUSÃO')
				FAtuaCTE(cDocSMA,cSerSMA,cForSMA, cLojSMA,.T.,'Processado com Sucesso.'+'- Data ' + cDataX+'- Hora '+cTimeX+ '-' +Alltrim(__cLogMsg) )		
			Endif  

			// Atualizar variaveis que são utilizada na definição para gerar a Nota na base 
			aCabec	:= {}
			aItens	:= {}
			lImport	:= .F.	   	

		EndIf   

	Enddo                         

	dbSelectArea(cPrefix)
	dbCloseArea()

	RestArea(aAreaSB1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF4)

	Return 

	********************************************************************************
	*Função que busca todas as Notas Fiscais que estão relacionadas para cada CTe
	*cDocCTe := Documento CTE
	*cSerCTe := Serie CTE
	*cForCTe := Fornecedor CTE
	*cLojCTe := Loja Fornecedor CTE
	********************************************************************************
User Function  Busca_NFs(cFilImp, cDocCTe, cSerCTe, cForCTe, cLojCTe)
	//(cPrefix)->ZNF_FILIAL,(cPrefix)->ZNF_DOCCTE,(cPrefix)->ZNF_SERCTE,(cPrefix)->ZNF_FORCTE,(cPrefix)->ZNF_LOJCTE 
	Local aAreaAll := {SB1->(GetArea()),ZNF->(GetArea()),SF1->(GetArea()),GetArea()} //Get Areas 
	//Local aAreaZNF	:= GetArea()
	Local cQryExc := ''
	aItens116:= {}

	cQryExc += CRLF +" SELECT * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + cFilImp +" ' and "    
	cQryExc += CRLF +" ZNF_STATUS <> '2' and "                                             
	cQryExc += CRLF +" ZNF_TPLANC = '2' and " // P-PRÉ-NOTA | VAZIO-MATA103 | 2-MATA116
	cQryExc += CRLF +" ZNF_DOCCTE = '"+cDocCTe+" ' and "    
	cQryExc += CRLF +" ZNF_SERCTE = '"+cSerCTe+" ' and "    
	cQryExc += CRLF +" ZNF_FORCTE = '"+cForCTe+" ' and "    
	cQryExc += CRLF +" ZNF_LOJCTE = '"+cLojCTe+" ' and "    
	cQryExc += CRLF +" D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "      
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cBusCTE := GetNextAlias() , .F. , .F. )

	dbSelectArea(cBusCTE)

	Do While !EOF() 

		dbSelectArea("SB1")
		dbSetOrder(1)
		If !SB1->(MsSeek(xFilial("SB1")+(cBusCTE)->ZNF_COD))  
			//ConOut("Cadastrar produto: " +(cBusCTE)->ZNF_COD)
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "Cadastrar produto: " +(cBusCTE)->ZNF_COD)

		EndIf                           

		dbSelectArea("SF1")
		dbSetOrder(1)
		dbSeek(xFilial('ZNF')+(cBusCTE)->ZNF_DOC+(cBusCTE)->ZNF_SERIE+(cBusCTE)->ZNF_FORNEC+(cBusCTE)->ZNF_LOJA)


		cFilSF1   	 := xFilial("SF1")
		nTamFilial   := Len(cFilSF1)
		aadd(aItens116,{{"PRIMARYKEY",AllTrim(SubStr(&(IndexKey()),nTamFilial + 1))}}) //Tratamento para Gestao Empresas

		//aadd(aItens116,{{"PRIMARYKEY",AllTrim(xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO)}})    
		dbSelectArea(cBusCTE)
		dbskip()
	Enddo

	dbSelectArea(cBusCTE)
	(dbCloseArea())
	//RestArea(aAreaZNF)
	aEval(aAreaAll,{|x| RestArea(x)}) // Restaurar tabelas.

Return(aItens116)


Static Function FSBusCTE(cFilImp)
	********************************************************************************
	*
	********************************************************************************
	Local cPrefix  
	Local cQryExc	:= '' 

	cQryExc += CRLF +" SELECT * "   	
	cQryExc += CRLF +" FROM " + RetSQLName('ZNF') + " "
	cQryExc += CRLF +" WHERE ZNF_FILIAL = '" + cFilImp +" ' and "
	cQryExc += CRLF +" ZNF_STATUS <> '2' "
	cQryExc += CRLF +" AND ZNF_TPLANC = '2' " // P-PRÉ-NOTA | VAZIO-MATA103 | 2-MATA116
	cQryExc += CRLF +" AND D_E_L_E_T_ <> '*' "
	cQryExc += CRLF +" ORDER BY ZNF_FILIAL, ZNF_DOC, ZNF_SERIE, ZNF_FORNEC "      
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cPrefix := GetNextAlias() , .F. , .F. )

Return(cPrefix)

Static Function FAtuaCTE(cCodNota, cCodSer, cCodFor, cLojFor,lOk,cMsg)
	********************************************************************************
	*
	********************************************************************************

	Local cQryExc	:= ''  
	//Local lUpOk		:= .F.
	Local cDbase   := Alltrim(TCGetDB()) //Verificar qual é o Banco de Dados do cliente.
	Local cRetZNF :=  GetNextAlias()
	Local aAreaZ   := GetArea() 

	If lOk
		cStatus := '2'
	Else	              
		cStatus := '3'
	Endif   	
	//Leonardo Vasco Viana de Oliveira
	//03/08/2017
	//Alteração para alterar modo de gravação na ZNF, de Update direto no banco para Replace seguindo o padrão do Protheus                        

	If cDbase <> 'ORACLE'   
		cQryExc += " SELECT R_E_C_N_O_ FROM "+ RetSqlName("ZNF")
		cQryExc += " WHERE ZNF_DOC = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERIE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORNEC = '"+cCodFor+"' "   
		cQryExc += " AND ZNF_LOJA = '"+	cLojFor+"' "

		dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cRetZNF   , .F. , .F. )

		dbSelectArea(cRetZNF)
		dbGotop()            

		Do While !Eof()  

			dbSelectArea('ZNF')
			dbGoto((cRetZNF)->R_E_C_N_O_)
			If !Eof()
				RecLock("ZNF",.F.)		      
				Replace ZNF_STATUS With Alltrim(cStatus)
				Replace ZNF_LOG    With Alltrim(cMsg)
				Replace ZNF_DATA   With dDataBase
				MsUnLock()
			EndIf

			dbSelectArea(cRetZNF)
			dbSkip()
		Enddo


		dbSelectArea(cRetZNF)
		dbCloseArea()
		/*     Código comentado em 03/08/2017 por Leonardo Vasco Viana de Oliveira
		cQryExc += " UPDATE "+RetSqlName("ZNF") +" SET ZNF_STATUS = '"+Alltrim(cStatus)+"' , ZNF_LOG = '"+cMsg+"', ZNF_DATA = '" +DTOS(dDataBase)+"' "
		cQryExc += " WHERE ZNF_DOCCTE = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERCTE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORCTE = '"+cCodFor+"' "   
		cQryExc += " AND ZNF_LOJCTE = '"+	cLojFor+"' "

		If (TCSQLExec(cQryExc) < 0)
		conout("TCSQLError() " + TCSQLError())
		EndIf*/
	Else // Tratamento para Oracle

		cQryExc += " UPDATE "+RetSqlName("ZNF") +" SET ZNF_STATUS = '"+Alltrim(cStatus)+"' , ZNF_LOG = RAWTOHEX('" +cMsg+"'), ZNF_DATA = '" +DTOS(dDataBase)+"' "
		cQryExc += " WHERE ZNF_DOCCTE = '"+cCodNota+"' "
		cQryExc += " AND ZNF_SERCTE = '"+cCodSer+"' "
		cQryExc += " AND ZNF_FORCTE = '"+cCodFor+"' "   
		cQryExc += " AND ZNF_LOJCTE = '"+cLojFor+"' "

		If (TCSQLExec(cQryExc) < 0)
			//conout("TCSQLError() " + TCSQLError())
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "TCSQLError() " + TCSQLError())
		EndIf

		If (TCSQLExec('commit') < 0)           
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "TCSQLError() " + TCSQLError())
			//conout("TCSQLError() " + TCSQLError())
		endif		
	Endif		              
	/* Tratamento para gravar o campo F1_ZUSER ou F1_USUSMAR quando a origem for CTe Vinculados - Mata116, com isso a atualização será feita por UPDATE.
	Data: 11/05/2017
	Desenvolvedor: Leonardo Vasco e Leonardo Perrella.
	*/
	cQryExc :="UPDATE "+RetSqlName("SF1")+""+CHR(13)+CHR(10)
	cQryExc +="SET F1_ZUSER = '"+cUserAbx+"'"+CHR(13)+CHR(10)
	cQryExc +="WHERE F1_DOC = '"+cCodNota+"'"+CHR(13)+CHR(10)
	cQryExc +="AND F1_SERIE = '"+cCodSer+"'"+CHR(13)+CHR(10)
	cQryExc +="AND F1_FORNECE = '"+cCodFor+"'"+CHR(13)+CHR(10)
	cQryExc +="AND F1_LOJA = '"+cLojFor+"'"+CHR(13)+CHR(10)
	cQryExc +="AND D_E_L_E_T_ <> '*'"+CHR(13)+CHR(10)

	If (TCSQLExec(cQryExc) < 0)
		//conout(" Erro Update F1_USER MATA116 ZUSER- TCSQLError() " + TCSQLError())
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , " Erro Update F1_USER MATA116 ZUSER- TCSQLError() " + TCSQLError())
	Else
		cQryExc :="UPDATE "+RetSqlName("SF1")+""+CHR(13)+CHR(10)
		cQryExc +="SET F1_USUSMAR = '"+cUserAbx+"'"+CHR(13)+CHR(10)
		cQryExc +="WHERE F1_DOC = '"+cCodNota+"'"+CHR(13)+CHR(10)
		cQryExc +="AND F1_SERIE = '"+cCodSer+"'"+CHR(13)+CHR(10)
		cQryExc +="AND F1_FORNECE = '"+cCodFor+"'"+CHR(13)+CHR(10)
		cQryExc +="AND F1_LOJA = '"+cLojFor+"'"+CHR(13)+CHR(10)
		cQryExc +="AND D_E_L_E_T_ <> '*'"+CHR(13)+CHR(10)
		If (TCSQLExec(cQryExc) < 0)
			FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , " Erro Update F1_USUSMAR MATA116 ZUSER- TCSQLError() " + TCSQLError())
			//conout(" Erro Update F1_USUSMAR MATA116 ZUSER- TCSQLError() " + TCSQLError())
		Endif				
	EndIf

	If (TCSQLExec('commit') < 0)           
		//conout("  Erro Update F1_USER MATA116 - TCSQLError() " + TCSQLError())
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "  Erro Update F1_USER MATA116 - TCSQLError() " + TCSQLError())
	Endif
	RestArea(aAreaZ)
Return(Nil)


Static Function Ver_DOCSEQ() 

	Local cQryExc	:= ''  
	//Local lUpOk		:= .F.
	//Local cDbase   := Alltrim(TCGetDB()) //Verificar qual é o Banco de Dados do cliente.
	Local cRetSEQ :=  GetNextAlias()
	Local aAreaZ   := GetArea()        
	Local cProxAba := '000000'
	Local cProxD1   := ' '
	Local cProxD2  := ' '
	Local cProxD3  := ' '
	nTamSeq	:= TamSx3("D3_NUMSEQ")[1]

	//select MAX(D1_NUMSEQ) as D1_NUMSEQ from SD1XXX
	//DOC -> SD1
	cQryExc := " select MAX(D1_NUMSEQ) as D1_NUMSEQ from  "+ RetSqlName("SD1")	 + "	 WHERE D_E_L_E_T_ <> '*' "
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cRetSEQ   , .F. , .F. )               
	cProxD1 := (cRetSEQ)->D1_NUMSEQ
	dbCloseArea()

	//DOC -> SD2
	cQryExc := " select MAX(D2_NUMSEQ) as D2_NUMSEQ from  "+ RetSqlName("SD2")	 + "	 WHERE D_E_L_E_T_ <> '*' "	
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cRetSEQ   , .F. , .F. )               
	cProxD2 := (cRetSEQ)->D2_NUMSEQ
	dbCloseArea()

	//DOC -> SD3
	cQryExc := " select MAX(D3_NUMSEQ) as D3_NUMSEQ from  "+ RetSqlName("SD3")	 + "	 WHERE D_E_L_E_T_ <> '*' "
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cRetSEQ   , .F. , .F. )               
	cProxD3 := (cRetSEQ)->D3_NUMSEQ
	dbCloseArea()       

	//DOC -> SD5
	cQryExc := " select MAX(D5_NUMSEQ) as D5_NUMSEQ from  "+ RetSqlName("SD5")	 + "	 WHERE D_E_L_E_T_ <> '*' "
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQryExc ) , cRetSEQ   , .F. , .F. )               
	cProxD5 := (cRetSEQ)->D5_NUMSEQ
	dbCloseArea()   

	If cProxD1 >= cProxAba
		cProxAba := cProxD1//Soma1(PadR(cProxD1,6),,,.T.) 	
	Endif

	If cProxD2 >= cProxAba
		cProxAba := cProxD2     
	Endif

	If cProxD3 >= cProxAba	
		cProxAba := cProxD3
	Endif	

	If cProxD5 >= cProxAba	
		cProxAba := cProxD5
	Endif	


	cProx := Soma1(PadR(cProxAba,6),,,.T.)		

	RestArea(aAreaZ)    
	conout("######### PASSOU PELO VER_DOCSEQ #######")

Return(cProx)
