#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#Include "fileio.ch"
#define Crlf Chr(13) + Chr(10)                                                                      
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Infa089       � Autor � Luiz Neves     � Data �  17/08/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Gera Titulos a Receber a partir de arquivo de importa��o   ���
���          � Excel.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Infoar                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

	DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Gera��o de Titulos a Receber" ) FROM 000,000 TO 580,1230 PIXEL

	@ 008,010 Button "&Seleciona Arquivo"  SIZE 70,15 OF oDlg Pixel Action DirCsv()
	@ 008,100 Button "&Processa"           SIZE 70,15 OF oDlg Pixel Action Processa({||fProcArq()},"Processando arquivo")   
	@ 008,190 Button "&Sair"      		   SIZE 70,15 OF oDlg Pixel Action oDlg:end() 
	
	@ 030,002 LISTBOX oLstBx;
	          FIELDS HEADER "Prefixo","Nr.Titulo", "Tipo", "Natureza", "Fornecedor", "Emiss�o", "Vencimento", "Vencimento Real", "Valor", "Observa��o";
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � Infa089       � Autor � Luiz Neves      � Data � 17/08/2018���
�������������������������������������������������������������������������͹��
���Descricao �     Seleciona Arquivo de Importa��o .CSV                   ���
�������������������������������������������������������������������������͹��
p��Sintaxe   � DirCsv()                                                   ���
�������������������������������������������������������������������������͹��
���Parametros�                            								  ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � fLeArq        � Autor � Luiz Neves      � Data � 15/03/2018���
�������������������������������������������������������������������������͹��
���Descricao � l� o arquivo selecionado e carrega dados em Array          ���
�������������������������������������������������������������������������͹��
p��Sintaxe   � fLeArq                                                     ���
�������������������������������������������������������������������������͹��
���Parametros�                            								  ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
  			            MsgStop('Arquivo de Importa��o Inv�lido. Verifique !', 'Erro')
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
                        cObs := 'Fornecedor Inv�lido, t�tulo n�o ser� processado'
                     Else
                     	If cNaturez <> '2013'
                     		cObs := 'Natureza Inv�lida, t�tulo n�o ser� processado'
                     	Else	
                     		dbSelectArea("SE2")
                     		dbSetOrder(6)
                     		If dbseek( xfilial("SE2") + cCodFor + cLoja + aLinha[nCont][1] + '  ' + aLinha[nCont][2] )
                     			cObs := 'T�tulo j� existe cadastrado e n�o ser� processado'
                     		EndIf
                     	EndIf	
                     EndIf		
            
                     aAdd(aTitulos, {aLinha[nCont][1],;  									// 1-  Prefixo
                     				 aLinha[nCont][2],;  									// 2-  Nr. do T�tulo
                                     'NFP',;             									// 3-  Tipo
                                     cNaturez,;          				 					// 4-  Natureza
                                     StrZero( Val(aLinha[nCont][3]) ,14) + "-" + cNomFor,;	// 5-  Fornecedor
                                     aLinha[nCont][4],;  									// 6-  Dt.Emiss�o
                                     aLinha[nCont][5],;  									// 7-  Dt.Vencto
                                     aLinha[nCont][6],;  									// 8-  Dt.Vcto.Real
                                     aLinha[nCont][7],;         							// 9-  Valor do T�tulo
                                     cObs }) 			 									// 10- Observa��o
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fProcArq()    � Autor � Luiz Neves    � Data �    20/08/18 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para Gerar Ctas a Pagar                   		  ��� 
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Infoar                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
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
       MsgStop('N�o h� t�tulos para gerar.','Erro')
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
	 
  	    	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
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
	fGeraRel()  // Gera relat�rio dos status da gera��o dos t�tulos.

Return()

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Programa  �fGeraRel   � Autor � Luiz A. Neves              � Data  07/06/2021���
���          �           �                                                       ��
�������������������������������������������������������������������������������Ĵ��
���USO       �INFOAR             �	                                            ���
�������������������������������������������������������������������������������Ĵ��
���Descricao � Gera Relat�rio dos Status das Baixas                             ���
�������������������������������������������������������������������������������Ĵ��
���Modulo    �SIGAFIN                                                           ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
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
				+ PadR(aTitulos[nIx, 02],9,' ') + ' ' ;          					 			// Nro. do T�tulo
				+ PadL(aTitulos[nIx, 04],4,' ') + '      ' ;                         			// Natureza
				+ Substr(aTitulos[nIx, 05],1,37) + '  ' ;    						 			// Cliente
				+ aTitulos[nIx, 06] + '  ' ;   	   		 						 	 			// Data de Emiss�o       
				+ aTitulos[nIx, 07] + '  ' ;        								 			// Data de Vencimento 
				+ aTitulos[nIx, 08] + '  ' ;        		 						 			// Data de Vencimento Real     
				+ Transform(Val(StrTran(aTitulos[nIx][9],",", ".")), "@E 99,999.99") + '  ' ; 	// Valor                     
				+ aTitulos[nIx, 10]  + Crlf 										 			// Descri��o do Status
	
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fImpCab   � Autor �  Luiz Neves          � Data �11/06/2021���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprime Cabecalho do relat�rio de status da Gera��o de     ���
���          � T�tulos.                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpCab()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Grupo Infoar                                               ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function fImpCab()
    nPag ++
    cLin := "INFA089 - Arquivo Processado : " + cNome + cExt + Crlf
    cLin += "Emiss�o: " + DtoC(Date()) + " Hora: " + Time() + Replicate(" ",32) + 'Listagem de Status Gera��o de T�tulos' + Replicate(" ",47) + "Pagina:    " + Transform(nPag, "@E 999") + Crlf
    cLin += Replicate("-",167) + Crlf
    cLin += 'Prefixo Titulo        Natureza  Cliente                              Emissao     Vencimento  Vcto.Real       Valor  Status                   ' + Crlf
    cLin += Replicate("-",167) + Crlf

    fWrite(nHdl,cLin,Len(cLin)) 
    nLin := 09

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � fEnvMail    � Autor � Luiz Neves       � Data � 11/06/2021 ���
�������������������������������������������������������������������������͹��
���Descricao �     Envia Email do Arquivo de Status da Gera��o de         ���
���          �     T�tulos.                                               ���
�������������������������������������������������������������������������͹��
���Sintaxe   � fEnvMail                                                   ���
�������������������������������������������������������������������������͹��
���Parametros�                                   						  ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	cBody += 'Relat�rio status da gera��o de t�tulos - INFA089 ' + ' processado em ' + DtoC( Date() ) + ' �s ' + Time() + ' hs. '
	cBody += 'Pelo operador ' + cNomeUsr + ', m�quina ' + cCompName + '.' 
	cBody += '<br>'
	cBody += '<br>'
	cBody += '<br>'
	cBody += '<br>'
	cBody += 'E-mail enviado automaticamente, favor n�o responder.' 
	cBody += '<br>' 
	cBody +="</body>"
	cBody += "</html>"

	//Envia o email
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate    := cValToChar( Date() )
	oMessage:cFrom    := "workflow@infoar.com.br"
	oMessage:cTo      := SuperGetMV( "ES_INFA089",, "" )
	oMessage:cSubject := 'Relat�rio status da gera��o de t�tulos - INFA089'
	oMessage:cBody    := cBody
	oMessage:AttachFile("\spool\" + cNome + ".rel")

	oMessage:Send( oServer )
	oServer:SMTPDisconnect()

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MontLstBx()   � Autor � Luiz Neves    � Data �    17/08/18 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para Montar a Listbox                     		  ��� 
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Infoar                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
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
