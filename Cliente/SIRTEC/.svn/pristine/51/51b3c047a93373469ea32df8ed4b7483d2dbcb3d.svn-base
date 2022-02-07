#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIRCORT   ºAutor  ³Microsiga           º Data ³  01/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SIRCORT

Local   nCount  := 0
Local   lExist  := .F.
Private aFiles  := {} 

_cPath := "C:\Temp\Corte"

aFiles := Directory(_cPath+"\*.*", "D") 

If Empty(aFiles)
	MsgAlert("Não foi possivel localizar os arquivos para leitura. Verifique o parametro MV_LOCTXT.")
	Return
EndIf

For nX := 1 To Len(aFiles)

	If aFiles[nX,2] > 0
	
		If !(AT(".",aFiles[nX,1])>0)		
			lExist := .T.
			Exit	
		EndIf

	EndIf

Next nX

If !lExist                                                      
	MsgAlert("Não existem arquivos disponiveis para importação.","Atenção")
	Return
EndIf 

Processa({|| ImpDados() },"Importando arquivos para o protheus, Aguarde...")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpDados  ºAutor  ³Microsiga           º Data ³  01/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpDados

Local   _cFNewext  := ""
Local   _cDatTr    := DtoS(Date())
Local   cEOL       := "CHR(13)+CHR(10)"
Local   nHdl       := 0
Private _cQuery    := ""
Private _cAlias    := GetNextAlias()
Private _cNota     := "" 	
Private _cServic   := ""
Private _cSubCat   := ""
Private _cMedida   := ""
Private _cCentTrb  := ""	
Private _cCliente  := ""
Private _cTel      := ""
Private _cEnd      := ""
Private _cComp     := ""
Private _cBairro   := ""
Private _cMunicip  := ""
Private _cUndConta := ""
Private _cData     := ""
Private _cDataLim  := ""
Private _cAgenda   := ""
Private _cInst     := ""
Private _cCliCob   := ""
Private _cEndCob   := ""
Private _cBairMun  := ""
Private _cDocDb1   := ""
Private _cVenc1    := ""
Private _cValDb1   := ""
Private _cDocDb2   := ""
Private _cVenc2    := ""
Private _cValDb2   := ""
Private _cDocDb3   := ""
Private _cVenc3    := ""
Private _cValDb3   := ""   	
Private _cDocDb4   := ""
Private _cVenc4    := ""
Private _cValDb4   := ""
Private _cOutDeb   := ""
Private _cClasse   := ""
Private _cCoord    := ""
Private _cCarga    := ""
Private _cFase     := ""
Private _cMedidor  := ""
Private _cPrefixo  := ""
Private _cSelo1    := ""
Private _cSelo2    := ""
Private _cSelo3    := ""
Private _cTotDeb   := ""
Private _nContArq  := 0
Private _aDadArq   := {} 
Private lCabObs    := .F.
Private _cMltGet   := ""
Private _cNeutro   := "" 
Private	_cProtEnd  := ""
Private	_cProtInd  := ""
Private	_cSolAte   := "" 
Private	_cPref2    := ""
Private _cLong     := ""
Private _cLat      := "" 
Private _cFile     := "C:\Temp\Corte"
Private _nRegs     := Len(aFiles)

cEOL               := Trim(cEOL)
cEOL               := &cEOL 

ProcRegua(_nRegs)

For nX := 1 To Len(aFiles)

	IncProc()
	If aFiles[nX,2] > 0

		If !(AT(".",aFiles[nX,1])>0)
		
			nHdl    := FOpen(_cFile+"\"+aFiles[nX,1], 64)
			
			If nHdl == -1
				MsgAlert("O arquivo de nome "+_cFile+"\"+aFiles[nX,1]+ " nao pode ser aberto!", "Atencao!")
				Return
			EndIf
			
			_cNomArq    := AllTrim(aFiles[nX,1])   
			
			nTamArq     := FSeek(nHdl, 0, 2)              // Posiciona o ponteiro no final do arquivo.
			FSeek(nHdl, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
			cLinha      := Space(nTamArq) 
			nBytes      := FRead(nHdl, @cLinha, nTamArq)  // Le uma linha.
			nLinhas     := MLCount(cLinha,81)             // Variavel que contera a linha lida.
			_nContArq++
			
			_cFNewext   := _cFile+"\"+aFiles[nX,1]+".lido"
			
			aAdd(_aDadArq,{aFiles[nX,1]+".lido"})
		
			For j := 1 to nLinhas // Passa por todas as linhas
			
				Do Case
			
					//-> Arquivo de corte - Suspensão
					Case SubStr(Memoline(AllTrim(cLinha),107,j),3,5) == "a642V"			
						ReadSusp(cLinha,nLinhas)
					
					//-> Arquivo de corte - Religação
					Case SubStr(Memoline(AllTrim(cLinha),107,j),3,5) == "a681V"			
						ReadReli(cLinha,nLinhas)
						
				EndCase
				
			Next j
            
			nTam      := Len(_cInst)
			nCaracter := AT("-",_cInst)
			
			If AT("-",_cInst)>0
				_cInst := SubStr(TRIM(_cInst),1,AT("-",_cInst)-1)
				_cInst += SubStr(TRIM(_cInst),nCaracter+1,nTam)
			EndIf
			
			DbSelectArea("ZZV")			
			
			If Select("_cAlias") > 0
				("_cAlias")->(DbCloseArea())
			EndIf
			
			_cQuery := " SELECT MAX(ZZV_CODIGO) AS ZZV_CODIGO FROM "+RETSQLNAME("ZZV") 
			
			TcQuery _cQuery New Alias _cAlias
			
			_cCodigo := Iif(Empty(("_cAlias")->ZZV_CODIGO),"000001", Soma1(("_cAlias")->ZZV_CODIGO))
			
			DbSelectArea("ZZV")
			If RecLock("ZZV",.T.)
			
				ZZV->ZZV_FILIAL := xFilial("ZZV") 
				ZZV->ZZV_CODIGO := _cCodigo
				ZZV->ZZV_NOTA   := _cNota 
				ZZV->ZZV_FILE   := _cNomArq
				ZZV->ZZV_SERVIC := _cServic
				ZZV->ZZV_SUBCAT := _cSubCat
				ZZV->ZZV_MEDIDA := _cMedida
				ZZV->ZZV_CENTTR := _cCentTrb
				ZZV->ZZV_CLIENT := NoAspas(_cCliente)
				ZZV->ZZV_TEL    := _cTel
				ZZV->ZZV_END    := _cEnd
				ZZV->ZZV_COMP   := _cComp
				ZZV->ZZV_BAIRRO := _cBairro
				ZZV->ZZV_MUN    := _cMunicip 
				ZZV->ZZV_EST    := 'ES'
				ZZV->ZZV_UNDCON := _cUndConta
				ZZV->ZZV_DATIMP := dDataBase				
				ZZV->ZZV_DATA   := SToD(Substr(_cData,7,4)+Substr(_cData,4,2)+Substr(_cData,1,2))
				ZZV->ZZV_HORDAT := StrTran(SubStr(_cData,12,8),":","") 				
				ZZV->ZZV_DATLIM := SToD(Substr(_cDataLim,7,4)+Substr(_cDataLim,4,2)+Substr(_cDataLim,1,2))
				ZZV->ZZV_HORLIM := StrTran(SubStr(_cDataLim,12,8),":","")				
				ZZV->ZZV_AGEND  := _cAgenda
				ZZV->ZZV_INSTAL := _cInst
				ZZV->ZZV_ENDCOB := _cEndCob
				ZZV->ZZV_BAIRMU := _cBairMun
				ZZV->ZZV_DOCDB1 := _cDocDb1
				ZZV->ZZV_VENC1  := SToD(Substr(_cVenc1,7,4)+Substr(_cVenc1,4,2)+Substr(_cVenc1,1,2))
				ZZV->ZZV_VALDB1 := GETDTOVAL(_cValDb1)
				ZZV->ZZV_DOCDB2 := _cDocDb2
				ZZV->ZZV_VENC2  := SToD(Substr(_cVenc2,7,4)+Substr(_cVenc2,4,2)+Substr(_cVenc2,1,2))
				ZZV->ZZV_VALDB2 := GETDTOVAL(_cValDb2)
				ZZV->ZZV_DOCDB3 := _cDocDb3                                                     
				ZZV->ZZV_VENC3  := SToD(Substr(_cVenc3,7,4)+Substr(_cVenc3,4,2)+Substr(_cVenc3,1,2))
				ZZV->ZZV_VALDB3 := GETDTOVAL(_cValDb3)
				ZZV->ZZV_DOCDB4 := _cDocDb4
				ZZV->ZZV_VENC4  := SToD(Substr(_cVenc4,7,4)+Substr(_cVenc4,4,2)+Substr(_cVenc4,1,2))
				ZZV->ZZV_VALDB4 := GETDTOVAL(_cValDb4)
				ZZV->ZZV_OUTDEB := GETDTOVAL(_cOutDeb)*1000
				ZZV->ZZV_CLASSE := _cClasse
				ZZV->ZZV_COORD  := _cCoord
				ZZV->ZZV_CARGA  := _cCarga
				ZZV->ZZV_FASE   := _cFase
				ZZV->ZZV_MEDID  := _cMedidor
				ZZV->ZZV_PREFIX := _cPrefixo
				ZZV->ZZV_SELO1  := _cSelo1
				ZZV->ZZV_SELO2  := _cSelo2
				ZZV->ZZV_SELO3  := _cSelo3
				ZZV->ZZV_STATUS := "A"
				ZZV->ZZV_TOTDEB	:= GETDTOVAL(_cTotDeb)*1000
				ZZV->ZZV_LAT    := AllTrim(_cLat)
				ZZV->ZZV_LONG   := AllTrim(_cLong)				
				ZZV->ZZV_OBS    := _cMltGet
				 
							
				MsUnlock()
			
			EndIf
			
			_cNota     := "" 	
			_cServic   := ""
			_cSubCat   := ""
			_cMedida   := ""
			_cCentTrb  := ""	
			_cCliente  := ""
			_cTel      := "" 
			_cEnd      := ""
			_cComp     := ""
			_cBairro   := ""
			_cMunicip  := ""
			_cUndConta := ""
			_cData     := ""
			_cDataLim  := ""
			_cAgenda   := ""
			_cInst     := ""
			_cCliCob   := ""
			_cEndCob   := ""
			_cBairMun  := ""
			_cDocDb1   := ""
			_cLat      := ""
			_cLong     := ""
			_cVenc1    := ""
			_cValDb1   := ""
			_cDocDb2   := ""
			_cVenc2    := ""
			_cValDb2   := ""
			_cDocDb3   := ""
			_cVenc3    := ""
			_cValDb3   := ""   	
			_cDocDb4   := ""
			_cVenc4    := ""
			_cValDb4   := ""
			_cOutDeb   := ""
			_cClasse   := ""
			_cCoord    := ""
			_cCarga    := ""
			_cFase     := ""
			_cMedidor  := ""
			_cPrefixo  := ""
			_cSelo1    := ""
			_cSelo2    := ""
			_cSelo3    := ""
			_cTotDeb   := ""
			lCabObs    := .F.
			_cMltGet   := ""
			_cNeutro   := ""
			_cProtEnd  := ""
			_cProtInd  := ""
			_cSolAte   := "" 
			_cPref2    := ""
			
			FClose(nHdl)
			
		EndIf
		
		If FRENAME(_cFile+"\"+aFiles[nX,1],_cFNewext) != -1 
			Conout("Arquivo renomeado com sucesso.")	
		Else 
			Conout('Problemas ao renomear arquivo.Verifique!') 
		EndIf 
		
	EndIf	

Next _nI

SIRMON()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIRCORT   ºAutor  ³Microsiga           º Data ³  03/18/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReadSusp(pcLinha,pnLinha)

Local _cLinha := pcLinha
Local _nLinha := pnLinha 

For _i := 1 to _nLinha

	Do Case
	
		//-> Nota
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a642V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,5) == "a652H"
			_cNota   := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),43,12))
			
			//-> Serviço
			_cServic := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),55,107))
			
		//-> Sub.Cat.	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a738V"					
			_cSubCat := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107)) 
				
		//-> Medida	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a858V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,5) == "a652H"
			_cMedida := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107)) 
		
		//-> Centro de trabalho responsavel 	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a858V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4875H"
			_cCentTrb := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,10))   	
			
		//-> Cliente
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a978V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,5) == "a652H"		 
			_cCliente := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),26,107))

		//-> Telefone
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a978V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4535H"		 
			_cTel := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))						
	
		//-> Endereço
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1110V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a652H"
			_cEnd := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i) ,16,107)) 
			
		//-> Complemento
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1110V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4535H"
			_cComp := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
	
		//-> Bairro	     
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1230V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a652H"
			_cBairro := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
		
		//-> Municipio   		 
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1230V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2522H"
		   	_cMunicip := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
		   	
		//-> Unidade/conta   	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1230V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4535H"   		    	
	    	_cUndConta := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
	
		//-> Data Emissao
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a409V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a2951H"			
	    	_cData  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))
	    	
		//-> Data Limite
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a409V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4337H"			
			_cDataLim := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
	    
		//-> Agendada sim/nao
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a535V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4337H"			
			_cAgenda  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
			
		//-> Instalação
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a6289V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4898H"
			_cInst := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),40,107))
			
		//-> Cliente  Cobrança
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a6379V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a141H"
			_cCliCob := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),28,107))
			
		//-> Endereço Cobrança
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a6469V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a141H"
			_cEndCob := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
		
		//-> Bairro/Municipio
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a6559V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a141H"
			_cBairMun := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
		
		//-> Numero do documento debito 1
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7296V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a907H"
        	_cDocDb1 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))
        	
  		//-> Vencimento 1
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7296V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1899H"
        	_cVenc1 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 
	 
  		//-> Valor debito 1
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7296V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2998H"
        	_cValDb1 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 

		//-> Numero do documento debito 2
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7392V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a907H"
        	_cDocDb2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
        	
  		//-> Vencimento 2
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7392V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1899H"
        	_cVenc2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 
	 
  		//-> Valor debito 2
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7392V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2998H"
        	_cValDb2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
 
		//-> Numero do documento debito 3
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7488V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a907H"
        	_cDocDb3 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
        	
  		//-> Vencimento 3
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7488V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1899H"
        	_cVenc3 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 
	 
  		//-> Valor debito 3
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7488V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2998H"
        	_cValDb3 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 

		//-> Numero do documento debito 4
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7584V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a907H"
        	_cDocDb4 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
        	
  		//-> Vencimento 4
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7584V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1899H"
        	_cVenc4 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 
	 
  		//-> Valor debito 4
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7584V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2998H"
        	_cValDb4 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 

 		//-> Outros debitos
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a7680V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2998H"
        	_cOutDeb := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107)) 
  
		//-> Classe
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1531V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1672H"
			_cClasse := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
			
		//-> Unidade/conta   	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1251V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4195H"   		    	
 			_cUndConta := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Coordenadas
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1651V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a566H"
			_cString := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
						
			For _nD := 1 To Len(_cString)
			
				If !(Substr(_cString,_nD,1)) $ "-" 
					_cLat  += Substr(_cString,_nD,1)
				Else
					_nLPos := _nD+1
					
					For _nE := _nLPos To Len(_cString)
					
						If !(Substr(_cString,_nE,1)) $ "-"
							_cLong += Substr(_cString,_nE,1)
						Else
							Exit
						EndIf		
					
					Next _nE
					                                    
					Exit
							
				EndIf
			
			Next _nD
	
		//-> Carga                                                       
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1651V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a3253H" 
			_cCarga := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
				
		//-> Fase
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1651V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4677H"  
			_cFase := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Medidor
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2428V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a680H"  
			_cMedidor := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))

		//-> Prefixo
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2428V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1700H"  
			_cPrefixo := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Selo 1
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2888V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1275H"  
			_cSelo1 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),40,107))

		//-> Selo 2
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2984V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1275H"  
			_cSelo2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Selo 3
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a3094V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1275H"  
			_cSelo3 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Total debitos 
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a8019V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2912H"
        	_cTotDeb := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),40,16)) 
        	
	    //-> Observação	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1813V" 	
    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),60,107))
    		
	    //-> Observação	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1897V" 	
    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),18,107))
    		
	    //-> Observação	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1981V" 	
    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),18,107))
	     
	EndCase
	
Next _i	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIRCORT   ºAutor  ³Microsiga           º Data ³  03/19/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReadReli(pcLinha,pnLinha)

Local _cLinha := pcLinha
Local _nLinha := pnLinha 

For _i := 1 to _nLinha

	Do Case
	
		//-> Nota
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a681V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,5) == "a836H"
			_cNota   := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),43,11))
			
			//-> Serviço
			_cServic := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),55,107))
			
		//-> Sub.Cat.	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a795V"					
			_cSubCat := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107)) 
				
		//-> Medida	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a909V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,5) == "a836H"
			_cMedida := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107)) 
		
		//-> Centro de trabalho responsavel 	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a909V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4393H"
			_cCentTrb := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,10))   	
			
		//-> Cliente
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1023V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a836H"		 
			_cCliente := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),28,107))

		//-> Telefone
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a1023V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a3997H"		 
			_cTel := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))						
	
		//-> Endereço
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1137V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a836H"
			_cEnd := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i) ,16,107)) 
			
		//-> Complemento
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1137V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4068H"
			_cComp := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
	
		//-> Bairro	     
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1251V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a836H"
			_cBairro := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
		
		//-> Municipio   		 
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1251V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2664H"
		   	_cMunicip := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
		   	
		//-> Unidade/conta   	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1251V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4195H"   		    	
	    	_cUndConta := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
	
		//-> Data Emissao
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a464V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a2939H"			
	    	_cData  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))
	    	
		//-> Data Limite
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a464V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4195H"			
			_cDataLim := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
	    
		//-> Agendada sim/nao
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a560V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4195H"			
			_cAgenda  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
			
		//-> Carga                                                       
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a510H" 
			_cCarga := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))
			
		//-> Neutro                                                       
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a2319" 
			_cNeutro := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
			
		//-> Prot.Entrada
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a3231H" 
			_cProtEnd := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Prot.Ind.                                                       
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4365H" 
			_cProtInd := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
			
		//-> Instalação
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1506V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a822H"
			_cInst := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))
  
		//-> Classe
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1506V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1899H"
			_cClasse := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Coordenadas
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1626V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a822H"
			_cString := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
						
			For _nD := 1 To Len(_cString)
			
				If !(Substr(_cString,_nD,1)) $ "-" 
					_cLat  += Substr(_cString,_nD,1)
				Else
					_nLPos := _nD+1
					
					For _nE := _nLPos To Len(_cString)
					
						If !(Substr(_cString,_nE,1)) $ "-"
							_cLong += Substr(_cString,_nE,1)
						Else
							Exit
						EndIf		
					
					Next _nE
					                                    
					Exit
							
				EndIf
			
			Next _nD
			
		//-> Solicitação de atendimento
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1626V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a4535H"
			_cSolAte := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Medidor
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2817V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a935H"  
			_cMedidor := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))
			
		//-> Prefixo
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2817V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2097H"  
			_cPrefixo := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Prefixo 2
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a3480V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2097H"  
			_cPref2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Selo 1
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a4022V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1445H"  
			_cSelo1 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),40,107))

		//-> Selo 2
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a4118V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1445H"  
			_cSelo2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Selo 3
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a4214V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1445H"  
			_cSelo3 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
			
	    //-> Observação	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2342V" 	
    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),61,107))
    		
	    //-> Observação	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2402V" 	
    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),18,107))

	    //-> Observação	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2462V" 	
    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),18,107))
    		
	    //-> Observação	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2522V" 	
    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),18,107))
				     
	EndCase
	
Next _i	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NoPontos  ºAutor  ³Andre Godoi         º Data ³  20/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retira caracteres dIferentes de numero, como, ponto,       º±±
±±º          ³virgula, barra, traco                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NoAspas(cString)

Local cChar   := ""
Local nX      := 0
Local _cAspas := "'"

For nX:= 1 To Len(cString)

	cChar := SubStr(cString, nX, 1)
	
 	If cChar $ _cAspas 
  		cString := StrTran(cString,cChar,"")
  		nX := nX - 1
 	EndIf
 	
Next

cString := AllTrim(_NoTags(cString))

Return cString

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIRMON    ºAutor  ³Microsiga           º Data ³  01/13/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SIRMON()

Local _cMltGet := ""

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                          ±±
±±ÀÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

SetPrvt("oDlg1","oGrp1","oMGet1")

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                     ±±
±±ÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

_cMltGet += "Quantidade de arquivos: "+cValToChar(_nContArq)+Chr(10)+Chr(13)
_cMltGet += "Diretorio de origem dos arquivos: "+_cFile+Chr(10)+Chr(13)
_cMltGet += "Arquivos Importados: "+Chr(10)+Chr(13)

For i := 1 To Len(_aDadArq)
	_cMltGet += _aDadArq[i,1]+Chr(10)+Chr(13)
Next i	

oMon       := MSDialog():New(092,232,592,927,"Monitor arquivos txt",,,.F.,,,,,,.T.,,,.T.)
oMon:bInit := {||EnchoiceBar(oMon  ,{|| oMon:End()},{|| oMon:End()},.F.,{})}
oGrpMon    := TGroup():New(016,004,240,336," Arquivos de importação ",oMon,CLR_BLACK,CLR_WHITE,.T.,.F.)
oMGet1     := TMultiGet():New(032,008,{|u| If(PCount()>0 , _cMltGet := u,_cMltGet)},oGrpMon,320,200,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,)

oMon:Activate(,,,.T.)

Return