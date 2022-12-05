#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#Include "fileio.ch"
#define Crlf Chr(13) + Chr(10)                                                                      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInfa089       บ Autor ณ Luiz Neves     บ Data ณ  17/08/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera Titulos a Receber a partir de arquivo de importa็ใo   บฑฑ
ฑฑบ          ณ Excel.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Infoar                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function infa089()

	Private oDlg
	Private oLstBx
	Private oArquivo   
	Private cArquivo    := ""      
	Private cDrive    	:= ""
	Private cDir      	:= ""
	Private cNome     	:= ""
	Private cExt      	:= ""	
	Private aListBox    := {}
    Private aTitulos    := {}
	Private	nAt			:= 0
	Private oFont3      := TFont():New("Arial Narrow",,016,,.F.,,,,,.F.,.F.)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Gera็ใo de Titulos a Receber" ) FROM 000,000 TO 580,1230 PIXEL

	@ 008,010 Button "&Seleciona Arquivo"  SIZE 70,15 OF oDlg Pixel Action DirCsv()
	@ 008,100 Button "&Processa"           SIZE 70,15 OF oDlg Pixel Action Processa({||fProcArq()},"Processando arquivo")   
	@ 008,190 Button "&Sair"      		   SIZE 70,15 OF oDlg Pixel Action oDlg:end() 
	
	@ 030,002 LISTBOX oLstBx;
	          FIELDS HEADER "Prefixo","Nr.Titulo", "Tipo", "Natureza", "Fornecedor", "Emissใo", "Vencimento", "Vencimento Real", "Valor", "Observa็ใo";
	          SIZE 614,235;
	          PIXEL;
	          OF oDlg;
	          On DblClick( (aListBox[oLstBx:nAt,1]:=!aListBox[oLstBx:nAt,1]) ,(oLstBx:Refresh()))  

	oLstBx:SetArray(aListBox)
	
	        //--     1   2   3   4   5   6   7   8   9  10 
	aAdd (aListBox,{' ',' ',' ',' ',' ',' ',' ',' ',' ',' '})
	MontLstBx()
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ Infa089       บ Autor ณ Luiz Neves      บ Data ณ 17/08/2018บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ     Seleciona Arquivo de Importa็ใo .CSV                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
pฑบSintaxe   ณ DirCsv()                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                            								  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function DirCsv()

	Local cPathOri  := GetTempPath()
	
	_cPath   := cGetFile('*.csv*|*.csv*', "Selecione o arquivo a ser importado", 1, cPathOri, .T., , .F. )
	cArquivo := Alltrim(_cPath)
	SplitPath( cArquivo, cDrive, cDir, cNome, cExt )
	
	If !Empty(cArquivo)
		Processa ({||fLeArq()},"Lendo arquivo" )
	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ fLeArq        บ Autor ณ Luiz Neves      บ Data ณ 15/03/2018บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ l๊ o arquivo selecionado e carrega dados em Array          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
pฑบSintaxe   ณ fLeArq                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                            								  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fLeArq()

    Local nLinhas    := 0
    Local nCont      := 0
    Local aLinha     := {}
	Local oFile                                                        
	Local cCabLin    := 'Prefixo;Numero do Titulo;Fornecedor;Emissao;Vencimento;Vcto Real;Vlr. Do Titulo'
	Local cCodFor    := ''
	Local cNomFor    := ''
	Local cLoja      := ''
	Local cNaturez   := ''
	Local cObs       := ''
	Local cLinha     := ''

    If Empty(cArquivo)
    	DirCsv()
    EndIf
    
    nHandle := FT_FUse(cArquivo)
    If nHandle == -1
       Return(Nil)
    EndIf

    nLinhas := FT_FLastRec() // Verifica quantas linhas deve ler no arquivo.

    FT_FUse() // Fecha o Arquivo

    //-- Definindo o arquivo a ser lido
    oFile := FWFileReader():New(cArquivo)
    If (oFile:Open())
            oFile:setBufferSize(5000)
            While nCont < nLinhas
  			      If nCont = 0
  			         cLinha := oFile:GetLine()
  			         cLinha := FwNoAccent(cLinha)
  			         If cLinha <> cCabLin
  			            MsgStop('Arquivo de Importa็ใo Invแlido. Verifique !', 'Erro')
  			            Return()
  			         EndIf
  			      Else
  			      	 aAdd(aLinha, Separa(oFile:GetLine(),";"))

                     cObs    := ''
                     cNomFor := ''

                     cCodFor := Posicione("SA2",3,xFilial("SA2") + StrZero( Val(aLinha[nCont][3]) ,14), "A2_COD")
                     cNaturez:= Posicione("SA2",3,xFilial("SA2") + StrZero( Val(aLinha[nCont][3]) ,14), "A2_NATUREZ")
                     cNomFor := Posicione("SA2",3,xFilial("SA2") + StrZero( Val(aLinha[nCont][3]) ,14), "A2_NREDUZ")
                     cLoja   := Posicione("SA2",3,xFilial("SA2") + StrZero( Val(aLinha[nCont][3]) ,14), "A2_LOJA")

                     If Empty(cCodFor)
                        cObs := 'Fornecedor Invแlido, tํtulo nใo serแ processado'
                     Else
                     	If cNaturez <> '2013'
                     		cObs := 'Natureza Invแlida, tํtulo nใo serแ processado'
                     	Else	
                     		dbSelectArea("SE2")
                     		dbSetOrder(6)
                     		If dbseek( xfilial("SE2") + cCodFor + cLoja + aLinha[nCont][1] + '  ' + aLinha[nCont][2] )
                     			cObs := 'Tํtulo jแ existe cadastrado e nใo serแ processado'
                     		EndIf
                     	EndIf	
                     EndIf		
            
                     aAdd(aTitulos, {aLinha[nCont][1],;  									// 1-  Prefixo
                     				 aLinha[nCont][2],;  									// 2-  Nr. do Tํtulo
                                     'NFP',;             									// 3-  Tipo
                                     cNaturez,;          				 					// 4-  Natureza
                                     StrZero( Val(aLinha[nCont][3]) ,14) + "-" + cNomFor,;	// 5-  Fornecedor
                                     aLinha[nCont][4],;  									// 6-  Dt.Emissใo
                                     aLinha[nCont][5],;  									// 7-  Dt.Vencto
                                     aLinha[nCont][6],;  									// 8-  Dt.Vcto.Real
                                     aLinha[nCont][7],;         							// 9-  Valor do Tํtulo
                                     cObs }) 			 									// 10- Observa็ใo
  			      EndIf
  			      nCont ++
            EndDo
            oFile:Close()
    EndIf

    If Len(aTitulos) > 0
       aListBox := aTitulos       
       oLstBx:SetArray(aListBox)
	   Montlstbx()
	   oLstBx:Refresh()           
    EndIf

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fProcArq()    บ Autor ณ Luiz Neves    บ Data ณ    20/08/18 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Gerar Ctas a Pagar                   		  บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Infoar                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fProcArq()

	Local   nIx 	 	:= 0
	Local   aArray 		:= {}
	Local 	aErr   	 	:= {}
	Local   cRetErr     := '' 
	Local   nXErr       := 0
	Local   cCodFor     := ''
	Local   cLoja       := ''

	Private nLin  		:= 80
	Private nPag  		:= 0
	Private nOk         := 0
	Private lMsErroAuto := .F. 
	Private lAutoErrNoFile := .T. 

    If Len(aTitulos) = 0
       MsgStop('Nใo hแ tํtulos para gerar.','Erro')
       Return()
    EndIf   
	
	For nIx := 1 To Len(aTitulos)
 
	    aArray   := {}
	    cCodFor  := ''
	    cLoja    := ''
	    cCodFor  := Posicione("SA2",3,xFilial("SA2") + Substr(aTitulos[nIx][5],1, At("-", aTitulos[nIx][5])- 1), "A2_COD")
	    
	    If  Empty(aTitulos[nIx][10])
	    	cLoja  := Posicione("SA2",3,xFilial("SA2") + Substr(aTitulos[nIx][5],1, At("-", aTitulos[nIx][5])- 1), "A2_LOJA")
	    	aArray := { { "E2_PREFIXO"  , aTitulos[nIx][1]          				, NIL },;
	    				{ "E2_NUM"      , aTitulos[nIx][2]          				, NIL },;
	    				{ "E2_TIPO"     , aTitulos[nIx][3]          				, NIL },;
	    				{ "E2_NATUREZ"  , aTitulos[nIx][4]          				, NIL },;
	    				{ "E2_FORNECE"  , cCodFor                                   , NIL },;
	    				{ "E2_LOJA"     , cLoja                                     , NIL },;
	    				{ "E2_EMISSAO"  , cToD(aTitulos[nIx][6])    				, NIL },;
	    				{ "E2_VENCTO"   , cToD(aTitulos[nIx][7])    				, NIL },;
	    				{ "E2_VENCREA"  , CtoD(aTitulos[nIx][8])    				, NIL },;
	    				{ "E2_VALOR"    , Val(StrTran(aTitulos[nIx][9],",", "."))  	, NIL } }
	 
  	    	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Altera็ใo, 5 - Exclusใo
	    	If lMSErroAuto
				aErr    := GetAutoGrLog()   
				cRetErr := ''  
				For nXErr := 1 To Len(aErr)
					cRetErr += aErr[nXErr] + Crlf
				Next nXErr
				aTitulos[nIx, 10] := cRetErr
			Else
                aTitulos[nIx, 10] := 'Titulo gerado Ok'
				nOk ++
			EndIf 
	    EndIf	
	Next nIx

    aListBox := aTitulos       
    oLstBx:SetArray(aListBox)
	Montlstbx()
	oLstBx:Refresh()       
	fGeraRel()  // Gera relat๓rio dos status da gera็ใo dos tํtulos.

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณfGeraRel   ณ Autor ณ Luiz A. Neves              ณ Data  07/06/2021ณฑฑ
ฑฑณ          ณ           ณ                                                       ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUSO       ณINFOAR             ณ	                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gera Relat๓rio dos Status das Baixas                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณModulo    ณSIGAFIN                                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fGeraRel()

	Local cLin    := ''  
	Local nIx     := 0
	Local nOk     := 0

	Private nLin  := 80
	Private nPag  := 0
	Private nHdl  

	If Len(aTitulos) > 0

		nHdl  := fCreate("\spool\" + cNome + ".rel")
	
		For nIx := 1 To Len(aTitulos)

			If nLin > 56
				fImpCab() 
			Endif

			cLin := PadL(aTitulos[nIx, 01],3,' ') + '     ' ;  						 			// Prefixo
				+ PadL(aTitulos[nIx, 03],3,' ') + ' ' ;         					 			// Tipo
				+ PadR(aTitulos[nIx, 02],9,' ') + ' ' ;          					 			// Nro. do Tํtulo
				+ PadL(aTitulos[nIx, 04],4,' ') + '      ' ;                         			// Natureza
				+ Substr(aTitulos[nIx, 05],1,37) + '  ' ;    						 			// Cliente
				+ aTitulos[nIx, 06] + '  ' ;   	   		 						 	 			// Data de Emissใo       
				+ aTitulos[nIx, 07] + '  ' ;        								 			// Data de Vencimento 
				+ aTitulos[nIx, 08] + '  ' ;        		 						 			// Data de Vencimento Real     
				+ Transform(Val(StrTran(aTitulos[nIx][9],",", ".")), "@E 99,999.99") + '  ' ; 	// Valor                     
				+ aTitulos[nIx, 10]  + Crlf 										 			// Descri็ใo do Status
	
			fWrite(nHdl,cLin, Len(cLin))
			nLin ++
			If 'Ok' $ cLin
			   nOk ++
			EndIf
		
		Next nIx

		If nLin > 56
			fImpCab() 
		Endif

		cLin := Replicate("-",167) + Crlf
		fWrite(nHdl,cLin, Len(cLin))
		cLin := 'Qtde linhas do arquivo......: ' + Transform(Len(aTitulos), "@E 999.999") + Crlf
		fWrite(nHdl,cLin, Len(cLin))
		cLin := 'Qtde de titulos gerados.....: ' + Transform(nOk, "@E 999.999") + Crlf
		fWrite(nHdl,cLin, Len(cLin))	
			
		fClose(nHdl)
		fEnvMail() // Envia email do arquivo do processamento das baixas.
		Sleep(4000)
		Erase("\spool\" + cNome + ".rel")

	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ fImpCab   ณ Autor ณ  Luiz Neves          ณ Data ณ11/06/2021ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Imprime Cabecalho do relat๓rio de status da Gera็ใo de     ณฑฑ
ฑฑณ          ณ Tํtulos.                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ fImpCab()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ NIL                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Grupo Infoar                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ                          ULTIMAS ALTERACOES                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ Motivo da Alteracao                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/
Static Function fImpCab()
    nPag ++
    cLin := "INFA089 - Arquivo Processado : " + cNome + cExt + Crlf
    cLin += "Emissใo: " + DtoC(Date()) + " Hora: " + Time() + Replicate(" ",32) + 'Listagem de Status Gera็ใo de Tํtulos' + Replicate(" ",47) + "Pagina:    " + Transform(nPag, "@E 999") + Crlf
    cLin += Replicate("-",167) + Crlf
    cLin += 'Prefixo Titulo        Natureza  Cliente                              Emissao     Vencimento  Vcto.Real       Valor  Status                   ' + Crlf
    cLin += Replicate("-",167) + Crlf

    fWrite(nHdl,cLin,Len(cLin)) 
    nLin := 09

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ fEnvMail    บ Autor ณ Luiz Neves       บ Data ณ 11/06/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ     Envia Email do Arquivo de Status da Gera็ใo de         บฑฑ
ฑฑบ          ณ     Tํtulos.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ fEnvMail                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                   						  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fEnvMail()

	Local cUser := "", cPass := "", cSendSrv := "", cMetauth:= ""
	Local cBody := ""
	Local nSendPort := 0, nTimeout := 0
	Local oServer, oMessage

	Local cNomeUsr  := Lower( AllTrim( UsrRetName( RetCodUsr() )))
	Local cCompName := GetComputerName()

	cUser       := AllTrim(GetNewPar("IN_USRMAIL"," ")) // define the e-mail account username
	cPass       := AllTrim(GetNewPar("IN_PASMAIL"," ")) // define the e-mail account password
	cSendSrv    := AllTrim(GetNewPar("IN_SRV_END"," ")) // define the send server
	cMetauth    := AllTrim(GetNewPar("IN_SSL_TLS"," ")) // define the server protocol
	nSendPort   := GetNewPar("IN_SRV_POR", 25)  // define the server port
	nTimeout    := 60 // define the timout to 60 seconds

	oServer := TMailManager():New()

	Do Case
		Case AllTrim( cMetauth ) == "TLS"
			oServer:SetUseSSL( .F. )
			oServer:SetUseTLS( .T. )
		Case AllTrim( cMetauth ) == "SSL"
			oServer:SetUseSSL( .T. )
			oServer:SetUseTLS( .F. )
	EndCase

	oServer:Init( "", cSendSrv, cUser, cPass, , nSendPort )
	// the method set the timout for the SMTP server
	oServer:SetSMTPTimeout( nTimeout )
	// estabilish the connection with the SMTP server
	oServer:SMTPConnect()
	// authenticate on the SMTP server (if needed)
	oServer:SmtpAuth( cUser, cPass )

	cBody := "<html>"
	cBody += "<body>"
	cBody += 'Relat๓rio status da gera็ใo de tํtulos - INFA089 ' + ' processado em ' + DtoC( Date() ) + ' เs ' + Time() + ' hs. '
	cBody += 'Pelo operador ' + cNomeUsr + ', mแquina ' + cCompName + '.' 
	cBody += '<br>'
	cBody += '<br>'
	cBody += '<br>'
	cBody += '<br>'
	cBody += 'E-mail enviado automaticamente, favor nใo responder.' 
	cBody += '<br>' 
	cBody +="</body>"
	cBody += "</html>"

	//Envia o email
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate    := cValToChar( Date() )
	oMessage:cFrom    := "workflow@infoar.com.br"
	oMessage:cTo      := SuperGetMV( "ES_INFA089",, "" )
	oMessage:cSubject := 'Relat๓rio status da gera็ใo de tํtulos - INFA089'
	oMessage:cBody    := cBody
	oMessage:AttachFile("\spool\" + cNome + ".rel")

	oMessage:Send( oServer )
	oServer:SMTPDisconnect()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MontLstBx()   บ Autor ณ Luiz Neves    บ Data ณ    17/08/18 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Montar a Listbox                     		  บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Infoar                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MontLstBx()

	oLstBx:bLine:={||{    aListBox[oLstBx:nAt,1];
	                     ,aListBox[oLstBx:nAt,2];
	                     ,aListBox[oLstBx:nAt,3];
	                     ,aListBox[oLstBx:nAt,4];
	                     ,aListBox[oLstBx:nAt,5];
	                     ,aListBox[oLstBx:nAt,6];
	                     ,aListBox[oLstBx:nAt,7];
	                     ,aListBox[oLstBx:nAt,8];
	                     ,aListBox[oLstBx:nAt,9];
	                     ,aListBox[oLstBx:nAt,10]}}

Return()
