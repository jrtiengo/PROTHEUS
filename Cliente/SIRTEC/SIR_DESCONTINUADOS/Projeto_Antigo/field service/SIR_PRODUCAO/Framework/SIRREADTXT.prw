#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIRREADTXTบAutor  ณMicrosiga           บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIRREADTXT

Local   nCount  := 0
Local   lExist  := .F.
Private aFiles  := {} 

_cPath := "C:\Temp\Liga"

aFiles := Directory(_cPath+"\*.*", "D") 

If Empty(aFiles)
	MsgAlert("Nใo foi possivel localizar os arquivos para leitura. Verifique o parametro MV_LOCTXT.")
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
	MsgAlert("Nใo existem arquivos disponiveis para importa็ใo.","Aten็ใo")
	Return
EndIf 

Processa({|| ImpDados() },"Importando arquivos para o protheus, Aguarde...")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpDados  บAutor  ณMicrosiga           บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpDados

Local   _cFNewext := ""
Local   _cDatTr   := DtoS(Date())
Local   cEOL      := "CHR(13)+CHR(10)"
Local   nHdl      := 0
Private _cFile    := "C:\Temp\Liga"
Private _cIdArq   := ""
Private _cQuery   := ""
Private _cAlias   := GetNextAlias()
Private _cLIndent := ""
Private lBairro   := .F.
Private lCabObs   := .F.
Private lSubCat   := .F.
Private lEnd      := .F.
Private lInst     := .F. 
Private lVenc2    := .F.
Private _cSubCat  := ""
Private _cInst    := "" 
Private _cSubCat  := ""
Private _cEnd     := ""
Private _cMunicip := ""
Private _cMltGet  := ""
Private _cTel     := "" 
Private _cProtI   := ""
Private _cNeutro  := ""
Private _cCliente := ""
Private _nContArq := 0  
Private _aDadArq  := {} 
Private	_cStatus2 := "ABERTA"
Private	_cLib     := "NAO"
Private	_cArea2   := ""
Private _cArea    := ""
Private _cMedida  := ""
Private _cComp    := ""
Private _cBair    := ""
Private _cVenc2   := ""
Private _cData    := ""
Private _cClasse  := ""
Private _cPrazo   := ""
Private _cNota    := ""
Private _cServic  := "" 
Private _cCarga   := ""
Private _cUndConta:= ""
Private _cProtE   := ""
Private _cFase    := ""
Private _cCoord   := ""
Private _cLong    := ""
Private _cLat     := ""
Private _nRegs    := Len(aFiles)

cEOL              := Trim(cEOL)
cEOL              := &cEOL 

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
			
					//-> Arquivo de modifica็ใo/religa็ใo
					Case SubStr(Memoline(AllTrim(cLinha),107,j),3,5) == "a681V"			
						ReadArMod(cLinha,nLinhas)
					
					//-> Arquivo de desligamento	
					Case SubStr(Memoline(AllTrim(cLinha),107,j),3,5) == "a642V"
						ReadArDes(cLinha,nLinhas)
					
					//-> Arquivo de liga็ใo	
					Case SubStr(Memoline(AllTrim(cLinha),107,j),3,5) == "a791V"
						ReadArLig(cLinha,nLinhas)
						
				EndCase
				
			Next j
            
			nTam      := Len(_cInst)
			nCaracter := AT("-",_cInst)
			
			If AT("-",_cInst)>0
				_cInst := SubStr(TRIM(_cInst),1,AT("-",_cInst)-1)
				_cInst += SubStr(TRIM(_cInst),nCaracter+1,nTam)
			EndIf
			
			DbSelectArea("ZZT")			
			
			If Select("_cAlias") > 0
				("_cAlias")->(DbCloseArea())
			EndIf
			
			_cQuery := " SELECT MAX(ZZT_CODIGO) AS ZZT_CODIGO FROM "+RETSQLNAME("ZZT") 
			
			TcQuery _cQuery New Alias _cAlias
			
			_cCodigo := Iif(Empty(("_cAlias")->ZZT_CODIGO),"000001", Soma1(("_cAlias")->ZZT_CODIGO))
			
			_cDiaV := SubStr(_cVenc2,01,2) 
			_cMesV := SubStr(_cVenc2,04,2)
			_cAnoV := SubStr(_cVenc2,07,4)
			
			_cDiaD := SubStr(_cData,01,2)
			_cMesD := SubStr(_cData,04,2)
			_cAnoD := SubStr(_cData,07,4)

			//-> Medi็ใo
			If  _cComp  $ "CONDO|COND|CASTELO|ADM"  .Or.  ; 
			    _cCarga $ "41"                   // .Or.;
			    //-> _cPref $ "27"		
				_cMedi := "INDIRETA"
			Else
				_cMedi := "DIRETA"
			EndIf
			
			If Empty(_cUndConta)
			
				_cAlUnd := GetNextAlias()
			
				If Select("_cAlUnd") > 0
					("_cAlUnd")->(DbCloseArea())
				EndIf
			
				_cQuery := ""
				
				_cQuery := " SELECT ZZT_UNDCON        "
				_cQuery += " FROM "+RetSqlName("ZZT")
				_cQuery += " WHERE  D_E_L_E_T_ != '*' "
				_cQuery += " AND    ZZT_INSTAL  = '"+AllTrim(SubStr(_cInst,1,15))+"'"
				
				TcQuery _cQuery New Alias _cAlUnd
				
				_cUndConta := ("_cAlUnd")->ZZT_UNDCON 
				
				_cQuery := ""
				_cAlUnd := ""	
			
			EndIf						
			
			DbSelectArea("ZZT")
			If RecLock("ZZT",.T.)
			
				ZZT->ZZT_FILIAL  := xFilial("ZZT")  
				ZZT->ZZT_CODIGO  := _cCodigo
				ZZT->ZZT_MEDICA  := _cMedi  
				ZZT->ZZT_FILE    := _cNomArq 
				ZZT->ZZT_COMP    := _cComp   
				ZZT->ZZT_VENC    := SToD(AllTrim(_cAnoD+_cMesD+_cDiaD)) 
				ZZT->ZZT_HORVEN  := AllTrim(SubStr(_cData,13,12)) 
				ZZT->ZZT_PRAZO   := cValToChar(_cPrazo)
				ZZT->ZZT_STATUS  := _cStatus2    
				ZZT->ZZT_LIBERA  := AllTrim(_cLib) 
				ZZT->ZZT_NOTA    := AllTrim(_cNota)     
				ZZT->ZZT_DATA    := SToD(AllTrim(_cAnoV+_cMesV+_cDiaV))
				ZZT->ZZT_HORDAT  := AllTrim(SubStr(_cVenc2,13,12)) 
				ZZT->ZZT_DATLEI  := dDataBase 				
				ZZT->ZZT_IDUSER  := __cUserID
				ZZT->ZZT_USER    := cUserName
			    ZZT->ZZT_SERVIC  := AllTrim(_cServic)                                                             
				ZZT->ZZT_SUBCAT  := AllTrim(_cSubCat)				
				ZZT->ZZT_MEDIDA  := AllTrim(_cMedida)				                                                           
				ZZT->ZZT_INSTAL  := AllTrim(SubStr(_cInst,1,15)) 
				ZZT->ZZT_CLIENT  := AllTrim(_cCliente)                        
				ZZT->ZZT_TEL     := AllTrim(_cTel)
				ZZT->ZZT_MUN     := AllTrim(Substr(AllTrim(_cMunicip),1,30))             
				ZZT->ZZT_BAIRRO  := AllTrim(_cBair) 
				ZZT->ZZT_COORD   := AllTrim(_cCoord)          
				ZZT->ZZT_END     := NoAspas(AllTrim(_cEnd))
				ZZT->ZZT_CLASSE  := AllTrim(_cClasse)
				ZZT->ZZT_CARGA   := AllTrim(_cCarga)
				ZZT->ZZT_UNDCON  := AllTrim(_cUndConta)
			    ZZT->ZZT_PROTIN  := AllTrim(_cProtI)
				ZZT->ZZT_PROTEN  := AllTrim(_cProtE)
				ZZT->ZZT_FASE    := AllTrim(_cFase)
				ZZT->ZZT_LAT     := AllTrim(_cLat)
				ZZT->ZZT_LONG    := AllTrim(_cLong)
				ZZT->ZZT_NEUTRO  := AllTrim(_cNeutro)
				ZZT->ZZT_OBS     := AllTrim(_cMltGet)
				
				MsUnlock()
			
			EndIf
			
			FClose(nHdl)
			
			_cCodigo   := ""
			_cMedi     := ""
			_cNomArq   := ""
			_cVenc2    := ""
			_cLib      := ""
			_cNota     := ""
			_cDatTr    := ""
			_cServic   := ""                                                         
			_cSubCat   := ""                                                  
			_cInst     := ""
			_cCliente  := ""                     
			_cTel      := ""
			_cMunicip  := ""            
			_cBair     := ""  
			_cEnd      := ""              
			_cCarga    := ""
			_cLIndent  := ""
			_cUndConta := ""
			_cProtI    := ""
			_cProtE    := ""
			_cFase     := ""
			_cNeutro   := ""
			_cMltGet   := ""
			_cClasse   := ""
			_cMedida   := ""
			_cLong     := ""
			_cLat      := ""
			_cCoord    := ""
			lBairro    := .F.
			lCabObs    := .F.
			lSubCat    := .F.
			lEnd       := .F.
			lInst      := .F. 
			lVenc2     := .F.
		
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIRMON    บAutor  ณMicrosiga           บ Data ณ  01/13/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIRMON

Local _cMltGet := ""

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Declara็ใo de Variaveis Private dos Objetos                          ฑฑ
ฑฑภภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

SetPrvt("oDlg1","oGrp1","oMGet1")

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Definicao do Dialog e todos os seus componentes.                     ฑฑ
ฑฑฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

_cMltGet += "Quantidade de arquivos: "+cValToChar(_nContArq)+Chr(10)+Chr(13)
_cMltGet += "Diretorio de origem dos arquivos: "+_cFile+Chr(10)+Chr(13)
_cMltGet += "Arquivos Importados: "+Chr(10)+Chr(13)

For i := 1 To Len(_aDadArq)
	_cMltGet += _aDadArq[i,1]+Chr(10)+Chr(13)
Next i	

oMon       := MSDialog():New(092,232,592,927,"Monitor arquivos txt",,,.F.,,,,,,.T.,,,.T.)
oMon:bInit := {||EnchoiceBar(oMon  ,{|| oMon:End()},{|| oMon:End()},.F.,{})}
oGrpMon    := TGroup():New(016,004,240,336," Arquivos de importa็ใo ",oMon,CLR_BLACK,CLR_WHITE,.T.,.F.)
oMGet1     := TMultiGet():New(032,008,{|u| If(PCount()>0 , _cMltGet := u,_cMltGet)},oGrpMon,320,200,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,)

oMon:Activate(,,,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReadArMod  บAutor  ณMicrosiga          บ Data ณ  01/31/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReadArMod(pcLinha,pnLinha)

Local _cLinha := pcLinha
Local _nLinha := pnLinha 
Local lBairro := .F.
Local lCabObs := .F.
Local lSubCat := .F.
Local lMedida := .F.
Local lEnd    := .F.
Local lInst   := .F. 
Local lVenc2  := .F.
Local lPrazo  := .F.

ChkStatus()	

For _i := 1 to _nLinha

	Do Case
	
		//-> Nota
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a681V"		    
			_cNota := RetNota(Memoline(AllTrim(cLinha),107,_i))
			
			//-> Servi็o
			_cServic := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),50,107))
			
		//-> Sub.Cat.	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a795V"
			_cLIndent := SubStr(Memoline(AllTrim(cLinha),107,_i),15,1)		
					
			_cSubCat += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107))
				
		//-> Medida	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a909V"
		
			If !lMedida
				_cMedida += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107)) 
				lMedida  := .T.			
			EndIf
			
		//-> Cliente
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1023V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a836H"		 
			_cCliente := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),27,107))			
	
		//-> Telefone
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1023V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a3997H"
			_cTel := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
	
		//-> Endere็o
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1137V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a836H"
			If !lEnd 
				_cEnd += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i) ,16,107))
				lEnd := .T.
			Else
				_cEnd += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i) ,17,107)) 			
			EndIf
			
		//-> Complemento
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1137V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4068H"
			_cComp := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
	
		//-> Bairro	     
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1251V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a836H"
		   	_cBair  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
		
		//-> Municipio
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1251V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2664H"
		   	_cMunicip += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,30))	    	
		   	
		//-> Coordenada
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1626V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a822H" 
			_cString := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),18,20))
						
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
	                                                 
		//-> Vencimento
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a464V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a2939H"			
	    	_cVenc2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))

		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a464V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4195H"			
 			_cData  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
	
				_cDt    := StoD(SubStr(_cData,7,4) + SubStr(_cData,4,2) + SubStr(_cData,1,2)) 
				_cDias  := _cDt - dDataBase 
				_cPrazo := _cDias 				

		//-> Carga                                                       
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,4) == "a510" 
			_cCarga := RetCarga(Memoline(AllTrim(cLinha),107,_i))
			
		//-> Unidade/conta   	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1251V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4195H"   		    	
 			_cUndConta := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
				
		//-> Fase
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a1644"  
			_cFase := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,3))
	
		//-> Neutro
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a2319"  
			_cNeutro := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,3))
	
		//-> Prot.Entrada
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a3231"  
			_cProtE := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))			
			
		//-> Prot.Individual
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2054V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a4365"  
			_cProtI := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
		
		//-> Instala็ใo
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1506V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a822H"
			_cInst := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))
	
		//-> Classe
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1506V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1899H"
			_cClasse := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
						
	    //-> Observa็ใo	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2342V" .Or. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1077H" 	
	   		If !lCabObs
	    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),40,107))
	    		lCabObs := .T.                      
	    	Else                                        
	    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
	    	EndIf
	     
	EndCase
	
Next _i	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReadArDes บAutor  ณMicrosiga           บ Data ณ  01/31/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReadArDes(pcLinha,pnLinha)

Local _cLinha := pcLinha
Local _nLinha := pnLinha 
Local lBairro := .F.
Local lCabObs := .F.
Local lSubCat := .F.
Local lMedida := .F.
Local lEnd    := .F.
Local lInst   := .F. 
Local lVenc2  := .F.
Local lPrazo  := .F.

ChkStatus()

For _i := 1 To _nLinha

	Do Case
	
		//-> Nota
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a642V"
			_cNota := RetNota(Memoline(AllTrim(cLinha),107,_i))
			
			//-> Servi็o
			_cServic := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),50,107))

		//-> Medida	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a858V"		
			If !lMedida
				_cMedida += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107))
				lMedida  := .T.			
			EndIf

		//-> Sub.Cat.	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a738V"			
			If !lSubCat
				_cSubCat += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107))
				lSubCat  := .T.			
			Else
				_cSubCat += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
			EndIf	

		//-> Cliente
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a978V"			
			_cCliente := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),26,107))
			
	    //-> Endere็o
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a6469V" 
				_cEnd += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i) ,16,107))
			
	    //-> Complemento
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1110V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4535H"	
			_cComp := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i) ,17,107)) 				
		
		//-> Bairro/Municipio	     
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1230V"	    
	    	If !lBairro	    	
	    		_cBair  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
	    		lBairro := .T.    	    	
	    	Else	    		
	    		_cMunicip += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,30))	    	
	    	EndIf

		//-> Vencimento
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a409V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a2951H"			
    		_cVenc2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))

		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a409V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4337H"			
    		_cData  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
			_cDt    := StoD(SubStr(_cData,7,4) + SubStr(_cData,4,2) + SubStr(_cData,1,2)) 
			_cDias  := _cDt - dDataBase 
			_cPrazo := _cDias 				

		//-> Instala็ใo
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a6289V"
			_cInst += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),40,107))
			
		//-> Carga
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1651V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a3253H"  	
			_cCarga := RetCarga(Memoline(AllTrim(cLinha),107,_i))
			
		//-> Classe
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1531V"
			_cClasse := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

		//-> Fase 
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1651V"
			_cFase := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
	
	EndCase
	
Next _i	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReadArLig บAutor  ณMicrosiga           บ Data ณ  01/31/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReadArLig(pcLinha,pnLinha)

Local _cLinha := pcLinha
Local _nLinha := pnLinha 
Local lBairro := .F.
Local lCabObs := .F.
Local lSubCat := .F.
Local lMedida := .F.
Local lEnd    := .F.
Local lInst   := .F. 
Local lVenc2  := .F.
Local lPrazo  := .F.

ChkStatus()

For _i := 1 To _nLinha

	Do Case

		//-> Nota
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a791V"
			_cNota := RetNota(Memoline(AllTrim(cLinha),107,_i))
		
			//-> Servi็o
			_cServic := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),50,107))

		//-> Medida	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1019V"		
			If !lMedida
				_cMedida += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107)) 
				lMedida  := .T.			
			EndIf 

		//-> Sub.Cat.	
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a905V"
			_cSubCat += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),15,107)) 
			
		//-> Cliente
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1129V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a595H"
			_cCliente := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),28,107))		
				
	    //-> Endere็o
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1240V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a595H"  			 
			_cEnd += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i) ,16,107))
			
		//-> Telefone
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1129V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4351H"
			_cTel := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))			 
			
		 //-> Complemento
		 Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1240V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4351H"
         	_cComp := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
         	
		//-> Bairro/Municipio	     
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1350V"	    
	    	If !lBairro	    	
	    		_cBair  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
	    		lBairro := .T.    	    	
	    	Else	    		
	    		_cMunicip += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,30))   	
	    	EndIf

		//-> Vencimento/Data
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a559V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a2851H" 			
	    	_cVenc2 := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))

		//-> Vencimento/Data
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,5) == "a559V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),10,6) == "a4223H" 			
	    	_cData  := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))	
	    	_cDt    := StoD(SubStr(_cData,7,4) + SubStr(_cData,4,2) + SubStr(_cData,1,2)) 
			_cDias  := _cDt - dDataBase 
			_cPrazo := _cDias 				
	    	
		//-> Instala็ใo
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1646V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a538H"
			_cInst += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),39,107))					
         
        //-> Classe
        Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a1646V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1814H"
        	_cClasse += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

	    //-> Observa็ใo	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2444V" .Or. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a737H"	    	
	    	If !lCabObs
	    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),40,107))
	    		lCabObs := .T.
	    	Else                                        
	    		_cMltGet += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),16,107))
	    	EndIf

		//-> Fase 
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2167V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a1474H"
			_cFase := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))
        
		//-> Prot.Individual
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2167V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a4705H"  
			_cProtI := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,107))

	    //-> Carga	
	    Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2167V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,5) == "a396H"
			_cCarga := RetCarga(Memoline(AllTrim(cLinha),107,_i))
			
		//-> Neutro
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2167V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a2296H"
			_cNeutro := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,3))
			
		//-> Prot.Entrada
		Case SubStr(Memoline(AllTrim(cLinha),107,_i),3,6) == "a2167V" .And. SubStr(Memoline(AllTrim(cLinha),107,_i),11,6) == "a3486H"
			_cProtE := AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),17,3))
	
	EndCase

Next _i

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChkStatus บAutor  ณMicrosiga           บ Data ณ  02/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ChkStatus
_cStatus2 := "A" //-> aberta
_cLib     := "NAO"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIRREADTXTบAutor  ณMicrosiga           บ Data ณ  05/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetNota(pLinha)

Local _cArqLin := pLinha
Local _cNotArq := ""

For _nB := 38 To Len(_cArqLin)

	If SubStr(_cArqLin,_nB,1) $ "0123456789"
	
		_cNotArq += SubStr(_cArqLin,_nB,1)
		
	ElseIf Empty(SubStr(_cArqLin,_nB,1))
	
		Exit	
	
	Else
	
		_cNotArq := ""	 
	
	EndIf

Next _nB

Return _cNotArq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIRREADTXTบAutor  ณMicrosiga           บ Data ณ  05/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetCarga(pLinha)

Local _cArqLin := pLinha
Local _cNotArq := ""

For _nC := 16 To Len(_cArqLin)

	If Empty(SubStr(_cArqLin,_nC,1)) 
	
		_cNotArq += AllTrim(SubStr(Memoline(AllTrim(cLinha),107,_i),_nC,107))
		Exit
	
	EndIf

Next _nC 

Return _cNotArq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoPontos  บAutor  ณAndre Godoi         บ Data ณ  20/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retira caracteres dIferentes de numero, como, ponto,       บฑฑ
ฑฑบ          ณvirgula, barra, traco                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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