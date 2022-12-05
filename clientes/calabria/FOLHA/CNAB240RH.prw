#include "rwmake.ch"
#include "totvs.ch"        
#include "protheus.ch"        
                  
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯送屯屯屯屯屯淹屯屯屯屯屯屯屯屯送屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯槐�
北篜rograma  � CNAB240RH  篈utor  � Reiner    � Data �  17/06/19   罕�
北掏屯屯屯屯屯屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯释屯屯屯贤屯屯释屯屯拖屯屯屯屯贡蓖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯 罕�
北篋esc.     �  Cnab unificado da folha                                            罕�
北�             �                                                                                罕�
北掏屯屯屯屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯凸北
北篣so       � Calabria                                                                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/

User Function CNAB240RH()
                
SetPrvt("DTEMP,CNOMARQ,NARQ,NTOT,CAGENCIA,CCTACOR,cBanco,cCodConv")
SetPrvt("CRAZSOC,CDATAGRV,CDTTIME,CDATACRD,DDATFOL,cEndEmp,cMunEmp,cCEPEmp,cEstEmp")
SetPrvt("NSEQUEN,CSEQUEN,NSEQLOTE,CSEQLOTE,nQtdLotes,CSEQHDR,NTOTAL,CREG,WFILIAL,NTIPO,CTIPO,")
SetPrvt("cNomeBco,oTipo,cMatIni,cMatFim,cCCIni,cCCFim,cCCConv")


If ! ( cEmpAnt $ "10/14" )
   Msgstop("Funcao habilitada apenas para as empresas 10 e 14.")
   Return
Endif

DEFINE MSDIALOG oDlg1 TITLE "Tipo de Pagamento" FROM 0,0 TO 250,300 PIXEL
@ 010, 050 RADIO oTipo VAR nTipo 3D SIZE 90,10 PROMPT 'Folha Mensal','Adiant.Quinzenal','1a Parc.Decimo','2a Parc.Decimo','Autonomo','Ferias','Rescisao' OF oDlg1 PIXEL
@ 090, 050 BUTTON "Confirma" SIZE 40,10 PIXEL ACTION (lOk:=.T.,oDlg1:End())
@ 090, 095 BUTTON "Cancela"  SIZE 40,10 PIXEL ACTION (lOk:=.F.,oDlg1:End())
ACTIVATE DIALOG oDlg1 CENTERED 

If !lOk
   Return
Endif   

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Parametros da rotina.                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cPerg := Padr("CNAB240RH",10)
AjustaSX1(cPerg)
Pergunte(cPerg)    

cTipo    := Str(nTipo,1)
cMatIni  := MV_PAR03
cMatFim  := MV_PAR04
cCCIni   := MV_PAR05
cCCFim   := MV_PAR06
cBanco   := MV_PAR07                      // COD. DO BANCO
cAgencia := MV_PAR08                      // COD. DA AGENCIA DA EMPRESA
cCtaCor  := MV_PAR09                      // COD. DA CONTA CORRENTE   
cCodConv := MV_PAR10                      // CODIGO DO CONVENIO
cCCConv  := MV_PAR11                      // Filtro por CCusto ou Conv阯io
cRazSoc  := SUBS( SM0->M0_NOME,1,30 )     // RAZAO SOCIAL DA EMPRESA 
cEndEmp  := SUBS( SM0->M0_ENDCOB,1,30 )   // ENDERECO EMPRESA
cMunEmp  := SUBS( SM0->M0_CIDCOB,1,20 )   // CIDADE
cCEPEmp  := SM0->M0_CEPCOB                // CEP
cEstEmp  := SM0->M0_ESTCOB                // UF  

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Acessar o dados do Arquivo de Empresa SM0.   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cAlias := Alias()
dbSelectArea("SM0")
dbSetOrder(1)   // forca o indice na ordem certa
nRegistro := Recno()
dbSeek(SUBS(cNumEmp,1,2)+cFilAnt)

If !( cBanco $ "041" )
   Msgstop("Este layout � de exclusividade do Banco 041 - BANRISUL.")
   Return
Endif

If nTipo = 1 // Folha Mensal                                      
   cNomArq := "\RH\FM" + cNumEmp + cCodConv + STRZERO(DAY(DATE()),2) + STRZERO(MONTH(DATE()),2) + ".REM"
ElseIf nTipo = 2  // Adiantamento Quinzenal
   cNomArq := "\RH\AQ" + cNumEmp + cCodConv + STRZERO(DAY(DATE()),2) + STRZERO(MONTH(DATE()),2) + ".REM"
ElseIf nTipo = 3  // 1� parcela
   cNomArq := "\RH\1P" + cNumEmp + cCodConv + STRZERO(DAY(DATE()),2) + STRZERO(MONTH(DATE()),2) + ".REM"
ElseIf nTipo = 4 // 2� parcela
   cNomArq := "\RH\2P" + cNumEmp + cCodConv + STRZERO(DAY(DATE()),2) + STRZERO(MONTH(DATE()),2) + ".REM"
ElseIf nTipo = 5 // Autonomo
   cNomArq := "\RH\AU" + cNumEmp + cCodConv + STRZERO(DAY(DATE()),2) + STRZERO(MONTH(DATE()),2) + ".REM"
ElseIf nTipo = 6  // Ferias
   cNomArq := "\RH\FR" + cNumEmp + cCodConv + STRZERO(DAY(DATE()),2) + STRZERO(MONTH(DATE()),2) + ".REM"
ElseIf nTipo = 7  // Recisao
   cNomArq := "\RH\RS" + Ctipo + cNumEmp + cCodConv + STRZERO(DAY(DATE()),2) + STRZERO(MONTH(DATE()),2) + ".REM"
Endif   
		
If !( MsgYesNo("Confirma geracao dos arquivos?") )
    Msgstop(" Rotina cancelada.")
	Return
EndIf
	
GeraCNAB()

Return

                        
//--------------------------------//
// Funcao que gera TXT            //
//--------------------------------//
Static FuncTion GeraCNAB()
nArq := FCreate(cNomArq)
 
DbSelectARea("SA6")
DbSetOrder(1)
If dbSeek(xFilial("SA6")+cBanco)
   cNomeBco := SUBS( SA6->A6_NOME,1,30) 
Else
   Msgstop("Banco "+cBanco+" n鉶 encontrado.")
   Return
EndIf

DbSelectARea("SRA")
DbSetOrder(1)

DbSelectARea("SRC")
DbSetOrder(1)
nTot := RecCount()

DbSelectARea("SRR")
DbSetOrder(1)

Processa( {|| GeraArq() } , "Gerando o Arquivo .." , "Aguarde....." )

Return

Static Function GeraArq()

  cDataGrv := STRZERO(DAY(DATE()),2)+STRZERO(MONTH(DATE()),2)+STR(YEAR(DATE()),4)        // DATA DE GRAVACAO
  cDataCrd := STRZERO(DAY(mv_par01),2)+STRZERO(MONTH(mv_par01),2)+STR(YEAR(mv_par01),4)     // DATA DO CREDITO
  cDtTime  := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2)
   
  cParHdr  := "'MV_"+cBanco+"SEQ'"
  cSeqHdrDt:= Substr(GETMV(&cParHdr),1,8)
  cSeqHdrSq:= Substr(GETMV(&cParHdr),9,6) 
  
  If cSeqHdrDt <> cDataGrv 
     cSeqHdr  := "000001"
     cHdrDtSq := cDataGrv+cSeqHdr 
  Else
     cSeqHdr  := StrZero(Val(cSeqHdrSq)+1,6)
     cHdrDtSq := cDataGrv+cSeqHdr
  EndIf 
  
  dDatFol   := mv_par02 
  nSeqLote  := 0 
  nQtdLotes := 2
  nSequen   := 1
  nTotal    := 0   
         
  // GRAVAR NOVA SEQUENCIA NO PARAMETRO
  PutMV(&cParHdr,cHdrDtSq)
  
  ProcRegua( nTot )
          
  // Header do Arquivo - Registro Tipo 0
  cReg := cBanco+"0000"+"0"+SPACE(9)+"2"+SUBST(SM0->M0_CGC,1,14)+MV_PAR10+SPACE(15)+"0"+cAgencia+"0"+"000"+cCtaCor+"0"+cRazSoc+cNomeBco  
  cReg := cReg+SPACE(10)+"1"+cDataGrv+cDtTime+cSeqHdr+"020"+"00000"+SPACE(69)+CHR(13)+CHR(10)   
  FWrite(nArq , cReg)
  nSequen := nSequen + 1   
                           
  // Header de Lote - Registro Tipo 1
  cReg := cBanco+"0001"+"1"+"C"+"30"+"01"+"020"+SPACE(1)+"2"+SUBST(SM0->M0_CGC,1,14)+cCodConv+SPACE(15)+"0"+cAgencia+"0000"+cCtaCor+SPACE(1)+cRazSoc
  cReg := cReg  + SPACE(40)+cEndEmp+SPACE(5)+SPACE(15)+cMunEmp+cCEPEmp+cEstEmp+"VA"+SPACE(6)+SPACE(10)+CHR(13)+CHR(10)   
  FWrite(nArq , cReg)
  nSequen := nSequen + 1   
  
  // Folha, adiantamento, 1a e 2a parc decimo, autonomo
  If nTipo <= 5
     LeSRC()
  Endif
  
  // Ferias ou rescisao
  If nTipo >= 6
     LeSRR()
  Endif  
  
  // Monta Registro Trailer do Lote - Registro Tipo 5
  cReg := cBanco+"0001"+"5"+SPACE(9)+STRZERO(nSeqLote+nQtdLotes,6)+STRZERO(nTotal*100,18)+"000000000000000000"+SPACE(171)+SPACE(10)+CHR(13)+CHR(10)
  FWrite(nArq , cReg)
  nSequen := nSequen + 1
    
  // Monta Registro Trailer do Arquivo - Registro Tipo 9
  cReg := cBanco+"9999"+"9"+SPACE(9)+"000001"+STRZERO(nSequen,6)+"000000"+SPACE(205)+CHR(13)+CHR(10)
  FWrite(nArq , cReg)

  // Fecha o Arquivo
  FClose( nArq )

  MsgBox( " Arquivo de envio ao Banrisul, Criado ...","Informacao...","INFO") 
  
  If CpyS2T( cNomArq, "C:\CNAB\RH", .F. )
     Conout( 'Arquivo copiado para a sua m醧uina com Sucesso!' )
  Else
     Conout( 'N鉶 foi poss韛el copiar o arquivo para a sua m醧uina, verifique com o administrador.' )
  Endif 
  
Return


//------------------------------//
// Cria perguntas               //
//------------------------------//
Static Function AjustaSX1(cPerg)
DbSelectArea("SX1")
DbSetOrder(1)
If !DbSeek(cPerg + "01" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "01"
   SX1->X1_PERGUNT:= "Data Cr閐ito na C/C ?"
   SX1->X1_VARIAVL:= "mv_ch1"
   SX1->X1_TIPO   := "D"
   SX1->X1_TAMANHO:= 8
   SX1->X1_VAR01  := "mv_par01"
   SX1->X1_GSC    := "G"       
   SX1->X1_VALID:= "naovazio()"
   MsUnlock()
Endif

If !DbSeek(cPerg + "02" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "02"
   SX1->X1_PERGUNT:= "Data Pagto da Folha ?"
   SX1->X1_VARIAVL:= "mv_ch2"
   SX1->X1_TIPO   := "D"
   SX1->X1_TAMANHO:= 8
   SX1->X1_VAR01  := "mv_par02"
   SX1->X1_GSC    := "G"    
   SX1->X1_VALID := "naovazio()"
   MsUnlock()
EndIf
        
If !DbSeek(cPerg + "03" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "03"
   SX1->X1_PERGUNT:= "Matricula de ?"
   SX1->X1_VARIAVL:= "mv_ch3"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 6
   SX1->X1_VAR01  := "mv_par03"
   SX1->X1_GSC    := "G"
   SX1->X1_F3     := "SRA"
   MsUnlock()
EndIf
        
If !DbSeek(cPerg + "04" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "04"
   SX1->X1_PERGUNT:= "Matricula at� ?"
   SX1->X1_VARIAVL:= "mv_ch4"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 6
   SX1->X1_VAR01  := "mv_par04"
   SX1->X1_GSC    := "G"
   SX1->X1_F3     := "SRA"
   MsUnlock()
EndIf 

If !DbSeek(cPerg + "05" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "05"
   SX1->X1_PERGUNT:= "Centro Custo de ?"
   SX1->X1_VARIAVL:= "mv_ch5"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 9
   SX1->X1_VAR01  := "mv_par05"
   SX1->X1_GSC    := "G" 
   SX1->X1_VALID:= "naovazio()"
   SX1->X1_F3     := "CTT"
   MsUnlock()
EndIf
        
If !DbSeek(cPerg + "06" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "06"
   SX1->X1_PERGUNT:= "Centro de Custo at� ?"
   SX1->X1_VARIAVL:= "mv_ch6"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 9
   SX1->X1_VAR01  := "mv_par06"
   SX1->X1_GSC    := "G"   
   SX1->X1_VALID:= "naovazio()"
   SX1->X1_F3     := "CTT"
   MsUnlock()
EndIf  

If !DbSeek(cPerg + "07" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "07"
   SX1->X1_PERGUNT:= "Banco ?"
   SX1->X1_VARIAVL:= "mv_ch7"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 3
   SX1->X1_VAR01  := "mv_par07"
   SX1->X1_GSC    := "G"   
   SX1->X1_VALID  := "naovazio()"
   SX1->X1_F3     := "SA6"
   MsUnlock()
EndIf    

If !DbSeek(cPerg + "08" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "08"
   SX1->X1_PERGUNT:= "Ag阯cia ?"
   SX1->X1_VARIAVL:= "mv_ch8"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 4
   SX1->X1_VAR01  := "mv_par08"
   SX1->X1_GSC    := "G"
   SX1->X1_VALID:= "naovazio()"
   SX1->X1_F3     := ""
   MsUnlock()
EndIf
        
If !DbSeek(cPerg + "09" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "09"
   SX1->X1_PERGUNT:= "Conta Corrente ?"
   SX1->X1_VARIAVL:= "mv_ch9"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 10
   SX1->X1_VAR01  := "mv_par09"
   SX1->X1_GSC    := "G" 
   SX1->X1_VALID:= "naovazio()"
   SX1->X1_F3     := ""
   MsUnlock()
EndIf      

If !DbSeek(cPerg + "10" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "10"
   SX1->X1_PERGUNT:= "Conv阯io ?"
   SX1->X1_VARIAVL:= "mv_chA"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:= 5
   SX1->X1_VAR01  := "mv_par10"
   SX1->X1_GSC    := "G"
   SX1->X1_VALID:= "naovazio()"
   SX1->X1_F3     := ""
   MsUnlock()
EndIf

If !DbSeek(cPerg + "11" )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := cPerg
   SX1->X1_ORDEM  := "11"
   SX1->X1_PERGUNT:= "Selecionar por:"
   SX1->X1_VARIAVL:= "mv_chB"
   SX1->X1_TIPO   := "N"
   SX1->X1_TAMANHO:= 1
   SX1->X1_VAR01  := "mv_par11"
   SX1->X1_DEF01  := "Por C.Custo"
   SX1->X1_DEF02  := "Por Conv阯io"
   SX1->X1_GSC    := "C"
   SX1->X1_PRESEL := 1
   SX1->X1_VALID  := "naovazio()"
   SX1->X1_F3     := ""
   MsUnlock()
EndIf  

Return


//-----------------------------------------------------//
// Leitura da SRC                                      //
// Folha, adiantamento, 1a e 2a parc.decimo, autonomo  //
//-----------------------------------------------------//
Static Function LeSRC()
ccVerba := ""
If nTipo = 1
   ccVerba = "799" // 'Folha Mensal'
Endif
If nTipo = 2
   ccVerba = "095" // 'Adiant.Quinzenal'
Endif
If nTipo = 3 // '1a Parc.Decimo'
   ccVerba = "094"
Endif  
If nTipo = 4 // '2a Parc.Decimo'
   ccVerba = "796"
Endif 
If nTipo = 5 // 'Autonomo'
   ccVerba = "797"
Endif   

If cCCConv == 1 // por CCusto
   cCondicao := 'RC_FILIAL <> cFilAnt .or. RC_MAT > cMatFim .Or. RC_CC < cCCIni .or. RC_CC > cCCFim'
Else  // por conv阯io
   cCondicao := 'RC_FILIAL <> cFilAnt .or. RC_MAT > cMatFim .Or. RC_CC < cCCIni .or. RC_CC > cCCFim'
EndIf

DbSelectArea("SRC")
Dbsetorder(1)
nTot := RecCount()
DbSeek( cFilAnt + cMatIni,.T. )     
Do while .not. eof()
	If SRC->RC_FILIAL <> cFilAnt .or. SRC->RC_MAT > cMatFim .Or. SRC->RC_CC < cCCIni .or. SRC->RC_CC > cCCFim
		Dbskip()
		Loop
	Endif                   
	wFilial := SRC->RC_FILIAL
	If SRC->RC_PD = ccVerba .AND. Dtos(SRC->RC_DATA) = Dtos(dDatFol)
	
		DbSelectArea("SRA")
		DbSeek( wFilial + SRC->RC_MAT )
		If Found() .and. left(SRA->RA_BCDEPSA,3) == cBanco  
		
		    nSeqLote := nSeqLote + 1
		     
			cReg := cBanco+"0001"+"3"+STRZERO( nSeqLote , 5 )+"A"+"0"+"00"+"010"+SubStr(SRA->RA_BCDEPSA,1,3)+"0"+SubStr(SRA->RA_BCDEPSA,4,4)
			cReg := cReg+"0"+"000"+SubStr(SRA->RA_CTDEPSA,1,10)+"0"+SubStr(SRA->RA_NOME,1,30)+SRA->RA_MAT+SPACE(9)+"00110"+cDataCrd+"BRL" 
			cReg := cReg+Replicate("0",15)+STRZERO( SRC->RC_VALOR * 100 , 15 )+Space(20)+Space(8)+Space(15)+Space(5)+Space(20)+"1"+"000"
			cReg := cReg+SRA->RA_CIC+Space(2)+Space(10)+"0"+Space(10)+CHR(13)+CHR(10) 
			
			FWrite(nArq , cReg)
			
			nSequen  := nSequen + 1
			nTotal   := nTotal + SRC->RC_VALOR  
		Endif
		
		DbSelectArea("SRC")
	Endif 
		
	DbSkip() 
	IncProc()
Enddo

Return

//---------------------------------------//
// Leitura da SRR                        //
// Ferias ou rescisao                    //
//---------------------------------------//
Static Function LeSRR()
ccVerba := ""
If nTipo = 6   // 'Ferias'
   ccVerba = "495"
Endif
If nTipo = 7 // 'Rescisao'
   ccVerba = "496"
Endif                               

////////////////////////////////////

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta filtro para processar as verbas                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
/*DbSelectArea("SRR")
cFiltro := SRR->(dbFilter())
If Empty(cFiltro)
	bFiltro := { || .T. }
Else
	cFiltro := "{ || " + cFiltro + " }"
	bFiltro := &(cFiltro)
Endif  

cArqTrab  := CriaTrab( "" , .F. )

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Query para SQL                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁 

cSRR   := "SRRTMP"
aStru  := dbStruct()
cQuery := "SELECT * FROM "+RetSqlName("SRR")+" SRR ,"+RetSqlName("SRA")+" SRA "   
cQuery += "WHERE SRR.RR_FILIAL = '"+cFilAnt+"' AND "
cQuery += "SRR.RR_FILIAL = SRA.RA_FILIAL AND " 
cQuery += "SRR.RR_MAT BETWEEN '"+cMatIni+"' AND '"+cMatFim+"' AND "
cQuery += "SRR.RR_MAT = SRA.RA_MAT AND "
cQuery += "SRR.RR_CC BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' AND " 
cQuery += "SRR.RR_DATAPAG = '"+DTOS(dDatFol)+"' AND "
cQuary += "SRR.RR_PD = '"+ccVerba+"' AND "
cQuery += "SRR.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY SRR.RR_FILIAL,SRR.RR_MAT"

cQuery := ChangeQuery(cQuery)

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SRRTMP", .F., .T.)},OemToAnsi("Seleccionado registros")) //"Seleccionado registros"

For nj := 1 to Len(aStru)
    If aStru[nj,2] != 'C'
       TCSetField("SRRTMP", aStru[nj,1], aStru[nj,2],aStru[nj,3],aStru[nj,4])
    EndIf	
Next nj

xCNABCriaTmp(cArqTrab, aStru, cSRR, "SRRTMP")  

IndRegua(cSRR,cArqTrab,"RR_FILIAL+RR_MAT",,".T.","Selecionando Registros...")		//"Selecionando Registros..."

dbSetIndex(cArqTrab+ordBagExt())

SetRegua(RecCount())		// Total de Elementos da regua

DbSelectArea(cSRR)
Dbsetorder(1)
nTot := RecCount()
DbGoTop()    
Do while .not. eof()   
    If Left((cSRR)->RA_BCDEPSA) <> cBanco
		Dbskip()
		Loop
	Endif
	
		cReg := cBanco+"0001"+"3"+STRZERO( nSeqLote , 5 )+"A"+"0"+"00"+"010"+SubStr(SRA->RA_BCDEPSA,1,3)+"0"+SubStr(SRA->RA_BCDEPSA,4,4)
		cReg := cReg+"0"+"000"+SubStr(SRA->RA_CTDEPSA,1,10)+"0"+SubStr(SRA->RA_NOME,1,30)+SRA->RA_MAT+SPACE(9)+"00110"+cDataCrd+"BRL" 
		cReg := cReg+Replicate("0",15)+STRZERO( SRR->RR_VALOR * 100 , 15 )+Space(20)+Space(8)+Space(15)+Space(5)+Space(20)+"1"+"000"
		cReg := cReg+SRA->RA_CIC+Space(2)+Space(10)+"0"+Space(10)+CHR(13)+CHR(10)
	
		FWrite(nArq , cReg)
		
		nSequen  := nSequen + 1
		nSeqLote := nSeqLote + 1
		nTotal   := nTotal + SRC->RC_VALOR
		
	DbSkip()
	IncProc()
Enddo 

Return        
*/
DbSelectArea("SRR")
Dbsetorder(1)
nTot := RecCount()
DbSeek( cFilAnt + cMatIni,.T. )     
Do while .not. eof()
	If SRR->RR_FILIAL <> cFilAnt .or. SRR->RR_MAT > cMatFim .Or. SRR->RR_CC < cCCIni .or. SRR->RR_CC > cCCFim
		Dbskip()
		Loop
	Endif                   
	wFilial := SRR->RR_FILIAL
	If SRR->RR_PD = ccVerba .AND. Dtos(SRR->RR_DATAPAG) = Dtos(dDatFol)
        
        DbSelectArea("SRA")
		DbSeek( wFilial + SRR->RR_MAT )
		If Found() .and. left(SRA->RA_BCDEPSA,3) == cBanco 
		
			nSeqLote := nSeqLote + 1
		
			cReg := cBanco+"0001"+"3"+STRZERO( nSeqLote , 5 )+"A"+"0"+"00"+"010"+SubStr(SRA->RA_BCDEPSA,1,3)+"0"+SubStr(SRA->RA_BCDEPSA,4,4)
	   		cReg := cReg+"0"+"000"+SubStr(SRA->RA_CTDEPSA,1,10)+"0"+SubStr(SRA->RA_NOME,1,30)+SRA->RA_MAT+SPACE(9)+"00110"+cDataCrd+"BRL" 
	   		cReg := cReg+Replicate("0",15)+STRZERO( SRR->RR_VALOR * 100 , 15 )+Space(20)+Space(8)+Space(15)+Space(5)+Space(20)+"1"+"000"
	   		cReg := cReg+SRA->RA_CIC+Space(2)+Space(10)+"0"+Space(10)+CHR(13)+CHR(10)
	
	   		FWrite(nArq , cReg)
		
	   		nSequen  := nSequen + 1
			nTotal   := nTotal + SRR->RR_VALOR
		Endif
		
		DbSelectArea("SRR")
	Endif 
	
	DbSkip()
	IncProc()
Enddo 

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao    硏CNABCriaTmp� Autor � REINER TRENNEPOHL    � Data � 24/07/19 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o 矯ria temporario a partir da consulta corrente (TOP)          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso      矯NAB240RH (TOPCONNECT)                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/ 
 

Static Function xCNABCriaTm(cArqTmp, aStruTmp, cAliasTmp, cAlias) 

	Local nI, nF 
	
	nF := (cAlias)->(Fcount())
    dbCreate(cArqTmp,aStruTmp)
    DbUseArea(.T.,,cArqTmp,cAliasTmp,.T.,.F.)
	(cAlias)->(DbGoTop())
	While ! (cAlias)->(Eof())
        (cAliasTmp)->(DbAppend())
		For nI := 1 To nF 
		    If  (cAliasTmp)->(FieldPos((cAlias)->( FieldName( ni )))) > 0
		   		    (cAliasTmp)->(FieldPut(nI ,;
					(cAlias)->(FieldGet( ;
					(cAlias)->(FieldPos( ;
               		(cAliasTmp)->(FieldName( ni ))))))))
            EndIf   		
		Next
		(cAlias)->(DbSkip())
	End
	(cAlias)->(dbCloseArea())
    DbSelectArea(cAliasTmp)
    
Return Nil
