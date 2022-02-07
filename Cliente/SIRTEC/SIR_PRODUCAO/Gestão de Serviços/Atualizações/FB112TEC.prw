#include "totvs.ch"
#include "protheus.ch"
#include "fileio.ch"
#INCLUDE "RWMake.ch"
#include "TBIConn.ch"
#Include "TopConn.ch"


/*/{Protheus.doc} FB112TEC
Rotina de importação de arquivo CSV - Faturamento OS
@type function
@author Bruno Silva
@since 25/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

//**** OBS: a cada alteração do fonte, aplicar tbm no ambiente SCHEDULE ***

User Function FB112TEC()
	Local lGo := .T.
	Local _cEmpLog := '04'
	Private _cRotina := "Importação OS - SIRTEC"
	Private _lAuto
	Private _nRegs := 0
	
	If 'SCHEDULE' $ Upper(Alltrim(GetEnvServer()))
		_lAuto := .T.
	ENdIf
	
	If _lAuto
		ConOut('--> FB112TEC: PREPARANDO AMBIENTE |')
		PREPARE ENVIRONMENT EMPRESA "04" FILIAL "01" MODULO "TEC" TABLES "SA1,SE4,DA0,AA3,AAG,AA5,SB1,AA5,AB6,AB7,AB8"
		
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' USER 'Administrador' PASSWORD 'sucodemanga' MODULO 'FIN'  TABLES 'SE1,SE2'
	EndIf
	
	If ! ExistDir( "\OS_SIGATEC\")
		If _lAuto
			ConOut('--> FB112TEC: A Pasta Protheus_Data/OS_SIGATEC não foi encontrada. | '+ DTOC(dDataBase) + ' '+ Time() )		
		Else
			MsgAlert('A Pasta Protheus_Data/OS_SIGATEC nÃ£o foi encontrada.',_cRotina)
		EndIf	
		Return
	EndIf	
	
	// Cria pastas no servidor
	If ! ExistDir( "\OS_SIGATEC\Processados")
			MakeDir( "\OS_SIGATEC\Processados")
	EndIf
	If ! ExistDir( "\OS_SIGATEC\Nao_Processados")
		MakeDir( "\OS_SIGATEC\Nao_Processados")
	EndIf	

	If ! _lAuto // Execucao manual
		lGo := MsgYesNo("Confirmar a importação dos arquivos contidos na pasta 'Protheus_Data/OS_SIGATEC'?",_cRotina)
	EndIf
	
	If lGo	
		Processa({ || fImporta(_lAuto)}, "Aguarde...", "Importando" )
		//fImporta(_lAuto)
	EndIf	
	
	If _lAuto
		RESET ENVIRONMENT
	EndIf
Return

// Busca arquivos contidos na pasta 'Protheus_Data/OS_SIGATEC' e apÃ³s move para 'Processados' ou 'Nao_Processados'
/*/{Protheus.doc} fImporta
 Busca arquivos contidos na pasta 'Protheus_Data/OS_SIGATEC' e apos move para 'Processados' ou 'Nao_Processados'
@type function
@author Bruno Silva
@since 25/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fImporta()
	Local nArq
	Local aFiles := Directory("\OS_SIGATEC\*.CSV", "D")
	
	If Len(aFiles) == 0 
		If _lAuto
			ConOut('--> FB112TEC: Nenhum arquivo encontrado na pasta Protheus_Data\OS_SIGATEC | '+ DTOC(dDataBase) +' '+ Time() )		
		Else
			
		EndIf
	EndIf	
	
	ProcRegua(Len(aFiles))
	For nArq := 1 To Len(aFiles)
		IncProc("Processando arquivo "+ Alltrim(aFiles[nArq,1])+"...")
		// Se o aquivo já existir na pasta OS_SIGATEC\processados não sera importado 
		If File("\OS_SIGATEC\Processados\"+ Alltrim(aFiles[nArq,1]))
			If _lAuto
				ConOut('--> FB112TEC: Arquivo: ' + aFiles[nArq,1] + ' ignorado, pois ja existe na pasta OS_SIGATEC\processados | '+ DTOC(dDataBase) +' '+ Time() )
			ELse
				MsgAlert('--> FB112TEC: Arquivo: ' + aFiles[nArq,1] + ' ignorado, pois ja existe na pasta OS_SIGATEC\processados | '+ DTOC(dDataBase) +' '+ Time(),_cRotina)
			EndIf	
			// Move para a pasta Nao_Processados				
			__CopyFile("\OS_SIGATEC\"+ Alltrim(aFiles[nArq,1]),"\OS_SIGATEC\Nao_Processados\"+ Alltrim(aFiles[nArq,1]))
			Sleep(1000)
			If File("\OS_SIGATEC\Nao_Processados\"+ Alltrim(aFiles[nArq,1]))
				fErase ("\OS_SIGATEC\"+ Alltrim(aFiles[nArq,1]))
			EndIf	
		Else			
			If _lAuto
				ConOut('--> FB112TEC: Iniciando importação do arquivo: ' + aFiles[nArq,1] + ' - Tamanho: ' + AllTrim(Str(aFiles[nArq,2])) +' | '+ DTOC(dDataBase) +' '+ Time() )		
			EndIf	
			If fProcArq(aFiles[nArq,1],_lAuto) // Faz a importacao do arquivo										
				If _lAuto
					ConOut('--> FB112TEC: Arquivo: ' + aFiles[nArq,1] + ' processado com sucesso. '+ cValToChar(_nRegs) +' registros importados. | '+ DTOC(dDataBase) +' '+ Time())
				Else
					MsgInfo('--> FB112TEC: Arquivo: ' + aFiles[nArq,1] + ' processado com sucesso. '+ cValToChar(_nRegs) +' registros importados. | '+ DTOC(dDataBase) +' '+ Time(),_cRotina)
				EndIf
			Else
				If _lAuto
					ConOut('--> FB112TEC: Arquivo: ' + aFiles[nArq,1] + ' nao importado, movido para a pasta Protheus_Data\OS_SIGATEC\Nao_Processados | '+ DTOC(dDataBase)+' '+ Time())
				Else				
					MsgInfo('--> FB112TEC: Arquivo: ' + aFiles[nArq,1] + ' naoo importado, movido para a pasta Protheus_Data\OS_SIGATEC\Nao_Processados | '+ DTOC(dDataBase) +' '+ Time() ,_cRotina)		
				EndIf	
			EndIf	
		EndIf		
	Next nArq

Return

/*/{Protheus.doc} fProcArq
Executa a importacaoo do arquivo. 
@type function
@author Bruno Silva
@since 25/01/2017
@version 1.0
@param _cArq, ${param_type}, Nome do arquivo
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fProcArq(_cArq)
	
	Local cLin := ""
	Local aLin := {}
	Local lContinua	:= .T.
	Local cNumOS := ""	
	LOcal cChaveSZV := ""
	Local cDescNF := ""
	Local cMunicipio := ""
	Local cSetor := ""
	Local cObserv :=  ""
	Local cUnidade := ""			
	Local cPedido := ""
	Local cNroFolha := ""
	Local cObra := ""
	Local nHandle
	
	Local aCabec := {}	
	Local aItem  := {}	
	Local aItens := {}	
	Local aApont := {}	
	Local aAponts:= {}
	//Local lDel := .F.
	dbSelectArea("AB7")
	AB7->(dbSetOrder(1))
		
	dbSelectArea("SZV")
	SZV->(dbSetOrder(1)) // ZV_OS + ZV_SPEDID + ZV_SNFOLH
		
	//FT_FUSE(_cArq)
	nHandle := FT_FUSE("\OS_SIGATEC\"+_cArq)
	//ProcRegua(FT_FLastRec())	
	FT_FGOTOP()	
//	L;Duplicidade;pedido;Numero Folha;Obra;Imposto;Cod. Servico;Data Folha;Data Recebimento;Descricao da nota;Municipio;Setor;Valor PDF;Valor ZFI282;Ord. Serv.;Diferenca;Observacoes;Ped. Ger.;NF;Unidade;
//  1;44292614434162;2667;4504429261;1004434162;B-0705963;YS;SERV 07.10;29/11/2016;30/12/2016;b0705963 UB-LOT. ALTO DO PANORAMA;VIToRIA DA CONQUISTA;CCM;R$ 1.197,24;R$ 1.197,24;00017403;R$ 0,00;;382801;2757;VitÃ³ria da Conquista;
	
	Begin Transaction	
	While !FT_FEOF() .And. lContinua	
		cLin := FT_FREADLN()	
		aLin := Separa(cLin,';',.T.)		
		If Len(aLin) >= 20 .And. UPPER(aLin[1]) != "L" .And. ! Empty(aLin[1])
			cNumOS     := PADR(aLin[16],TamSX3("ZV_OS")[01]) //Left(aLin[15],6)
			cPedido    := PADR(aLin[04],TamSX3("ZV_SPEDID")[01])
			cNroFolha  := PADR(aLin[05],TamSX3("ZV_SNFOLH")[01])
			
			cDescNF    := aLin[11]
			cMunicipio := aLin[12]
			cSetor     := aLin[13]
			cObserv    := aLin[18]
			cUnidade   := aLin[21]						
			cObra      := aLin[06]
			
			// Se houver registros com essa chave, apaga todos para a nova inclusão
			If SZV->(dbSeek(xFilial("SZV") + cNumOS + cPedido + cNroFolha )) .and. cChaveSZV != cNumOS + cPedido + cNroFolha	
				While ! SZV->(EOF()) .And. SZV->(ZV_FILIAL + ZV_OS + ZV_SPEDID + ZV_SNFOLH)  == xFilial("SZV") + cNumOS + cPedido + cNroFolha				 
					RecLock("SZV",.F.)
					dbDelete()
					MsUnlock()
					SZV->(dbSkip())
				EndDo	
			EndIf
			cChaveSZV := cNumOS + cPedido + cNroFolha					
			If RecLock("SZV",.T.)			
				SZV->ZV_OS     := cNumOS
				SZV->ZV_SPEDID := cPedido
				SZV->ZV_SNFOLH := cNroFolha								
				SZV->ZV_SOBRA   := cObra
				SZV->ZV_IMPOSTO := aLin[07]
				SZV->ZV_CODSERV := aLin[08]
				SZV->ZV_DTRECEB := CTOD(aLin[09])
				SZV->ZV_DTFOLHA := CTOD(aLin[10])
				SZV->ZV_SDESNF := cDescNF
				SZV->ZV_SMUNIC := cMunicipio
				SZV->ZV_SSETOR := cSetor
				SZV->ZV_VALPDF := fConvertN(aLin[14])
				SZV->ZV_VALSZI := fConvertN(aLin[15])
				SZV->ZV_VALDIF := fConvertN(aLin[17])				
				SZV->ZV_SOBSER := cObserv				
				SZV->ZV_PEDGER := aLin[19]
				SZV->ZV_NF     := aLin[20]
				SZV->ZV_SUNIDA := cUnidade
												
				SZV->ZV_SLOGIMP := "Arquivo importado: "+ Alltrim(_cArq) + " em " + DTOC(dDatabase) +  " " + Time() 
				MsUnlock()
				_nRegs ++
			EndIf	
			/*
			ZV_OS C 8  - OS
			ZV_SPEDID C 20 - Pedido
			ZV_SNFOLH C 30 - Nro Folha
			ZV_SOBRA C 30 - Obra
			ZV_IMPOSTO C 5 - Imposto
			ZV_CODSERV c 20 Cod Serviço
			ZV_DTRECEB D - Dt Recebim
			ZV_DTFOLHA D - Dt Folha
			ZV_SDESNF C 40 Descri NF
			ZV_SMUNIC C 40 Municipio
			ZV_SSETOR C 30 - Setor
			ZV_VALPDF N 14,2 Valor PDF
			ZV_VALSZI N 14,2 Valor SFI
			ZV_VALDIF N 14,2 DIferença
			ZV_SOBSER C 80 - Observ
			ZV_PEDGER C 30 - Ped Ger
			ZV_NF C 20 - NF
			ZV_SUNIDA C 40 - Unidade
			ZV_SLOGIMP - C40 - Log Importaçao			  
			*/			  						  	
			If AB7->(dbSeek(xFilial("AB7") + cNumOS))							
				If RecLock("AB7",.F.)			
					AB7->AB7_SPEDID := cPedido
					AB7->AB7_SNFOLH := cNroFolha																							
					AB7->AB7_SOBRA  := cObra												
					AB7->AB7_SDESNF := cDescNF
					AB7->AB7_SMUNIC := cMunicipio
					AB7->AB7_SSETOR := cSetor				
					AB7->AB7_SOBSER := cObserv								
					AB7->AB7_SUNIDA := cUnidade
					AB7->AB7_SLOGIM := "Arquivo importado: "+ Alltrim(_cArq) + " em " + DTOC(dDatabase) +  " " + Time()														
					MsUnlock()
				EndIf				
			Else
			//	lContinua := .F.
				ConOut('--> FB112TEC: OS: ' + cNumOS + ' nao encontrada. | '+ DTOC(dDataBase) +' '+ Time() )
			EndIf						
		EndIf	
		FT_FSKIP()				
	EndDo	
	FT_FUSE()
	If ! lContinua
		//Disarm Transaction
		// Move para a pasta Nao_Processados	
		__CopyFile("\OS_SIGATEC\"+ _cArq,"\OS_SIGATEC\Nao_Processados\"+ _cArq)
		Sleep(1000)
		If File("\OS_SIGATEC\Nao_Processados\"+ _cArq)
			fErase ("\OS_SIGATEC\"+ _cArq)
		EndIf		
	Else
			
		// Move para a pasta Processados	
		__CopyFile("\OS_SIGATEC\"+ _cArq,"\OS_SIGATEC\Processados\"+ _cArq)
		Sleep(1000)
		If File("\OS_SIGATEC\Processados\"+ _cArq)
			fErase("\OS_SIGATEC\"+ _cArq)
		EndIf		
	EndIf
	End Transaction		

Return lContinua


Static Function fConvertN(cNum)

//R$ 1.197,24
	cNum := StrTran(cNum,"R","")
	cNum := StrTran(cNum,"$","")
	cNum := StrTran(cNum,".","")
	cNum := StrTran(cNum,",",".")
	
Return Val(cNum)

