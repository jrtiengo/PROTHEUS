#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#define Crlf Chr(13) + Chr(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณinfa139       บ Autor ณ Luiz Neves     บ Data ณ  20/01/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera Tํtulos tipo "RA", apartir de arquivo de Importa็ใo   บฑฑ
ฑฑบ          ณ Excel (CSV).   			                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Infoar                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function infa139()

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

	Private oOk				:= LoadBitmap(GetResources(), "BR_VERDE")
	Private oErro   		:= LoadBitmap(GetResources(), "BR_VERMELHO")

	Define MSDIALOG oDlg Title OemToAnsi( "Gera็ใo de Titulos RA" ) From 000,000 To 0710,1550 Pixel

	@ 008,010 Button "&Seleciona Arquivo"  Size 70,10 OF oDlg Pixel Action SelCsv()
	@ 008,100 Button "&Processa"           Size 70,10 OF oDlg Pixel Action Processa({||fProcArq()},"Processando arquivo")
	@ 008,190 Button "&Legenda"    		   Size 70,10 OF oDlg Pixel Action (fLegenda()) Size 54, 25 Of oDlg Pixel
	@ 008,280 Button "&Sair"      		   Size 70,10 OF oDlg Pixel Action oDlg:end()

	@ 030,002 ListBox oLstBx;
	          Fields Header " ",;
	                        "Data Emissใo",;
	                        "Prefixo",;
	                        "Nro. Titulo",;
	                        "Parcela",;
	                        "Filial",;
	                        "Banco",;
	                        "Agencia",;
	                        "Conta",;
	                        "Cliente",;
	                        "Loja",;
	                        "Natureza",;
	                        "Vencimento",;
	                        "Vlr.Titulo",;
	                        "Hist๓rico",;
	                        "Nr.Pedido",;
	                        "Nr.Ped.Site",;
							"Cod.Mkp",;
	                        "Fil.Origem",;
							"Id.Trans",;
	                        "Forma Pagto.",;
	                        "Nro.Documento",;
	                        "Valida็ใo";
	          Size 770,320;
	          Pixel;
	          Of oDlg 

	oLstBx:SetArray(aTitulos)

    //--              1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22    23
	aAdd (aListBox, {oOk, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',  '                                                         ' } )
	MontLstBx()

	ACTIVATE MSDIALOG oDlg CENTERED

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ SelCSV        บ Autor ณ Luiz Neves      บ Data ณ 20/01/2020บฑฑ
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
Static Function SelCsv()

	Local cPathOri  := GetTempPath()

	_cPath   := cGetFile('*.csv*|*.csv*', "Selecione o arquivo a ser importado", 1, cPathOri, .T., , .F. )
	cArquivo := Alltrim(_cPath)
	SplitPath( cArquivo, cDrive, cDir, cNome, cExt )

	If !Empty(cArquivo)
		Processa ({||fCarrega()},"Lendo arquivo" )
	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ fCarrega      บ Autor ณ Luiz Neves      บ Data ณ 20/01/2020บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ l๊ o arquivo selecionado e carrega dados em Array          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
pฑบSintaxe   ณ fCarrega                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                            								  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fCarrega()

    Local nLinhas    := 0
    Local nCont      := 0
    Local aLinha     := {}
	Local oFile
	Local cCabLin    := 'DATA EMISSAO;PREFIXO;PARCELA;FILIAL;BANCO;AG;CONTA;CLIENTE;LOJA;NATUREZA;VENCIMENTO;VLR. TITULO;HISTORICO;No.Pedido ;NR. DOCUMENTO'
	Local cLinha     := ''
	Local cObs       := ''
	Local _cTitulo   := ''
	Local _cCli      := ''
	Local _cLoja     := ''
	Local _cPedSite  := ''
	Local _cIdTrans  := ''
	Local _cFormaPg  := ''
	Local _cPedMkp   := ''
	Local _cFilOrig  := ''
	Local _nValor    := 0

    If Empty(cArquivo)
    	DirCsv()
    EndIf

    nHandle := FT_FUse(cArquivo)
    If nHandle == -1
       Return(Nil)
    EndIf

    nLinhas  := FT_FLastRec() // Verifica quantas linhas deve ler no arquivo.
    aTitulos := {}

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

                     _cCli      := StrZero(Val(aLinha[nCont,08]),9)  // C๓digo do Cliente
                     _cLoja     := StrZero(Val(aLinha[nCont,09]),4)  // Loja do Cliente
					 _cPedSite  := ''
					 _cIdTrans  := ''
					 _cFormaPg  := ''
					 _cTitulo   := ''
                     cObs       := ''
					 _cPedMkp   := ''
					 _cFilOrig  := ''
                     _nValor    := 0

                     // Valida Emissใo
                     If Empty(aLinha[nCont, 01])
                        cObs += "Emissใo invแlida;"
                     EndIf

                     // Valida Filial
                     If Empty(aLinha[nCont,04])
                        cObs += "Filial Invแlida;"
                     EndIf

                     // Valida Nro da Parcela
                     If Empty(aLinha[nCont,03]) .Or. Val(aLinha[nCont,03]) = 0
                        cObs += "parcela invalida;"
                     EndIf

                     // Valida Nro. do Pedido
                     dbSelectArea("SC5")
 					 SC5->(dbSetOrder(1)) // Filial + Pedido
					 If SC5->(! MsSeek(StrZero(Val(aLinha[nCont,04]),2) + AllTrim(aLinha[nCont,14]) ))
					    cObs += "Pedido nใo encontrado;"
					 Else
	 				 	 _cTitulo   := StrZero(SC5->(Recno()),9) 
						 _cPedSite  := SC5->C5_PEDSITE	
						 _cPedMkp   := SC5->C5_PEDMKP
						 _cFilOrig  := SC5->C5_FILIAL
					     If SC5->C5_CLIENTE <> _cCli
					        cObs += "Cliente informado diferente do pedido;"
						 EndIf
					 EndIf		

					 // Valida forma de pagto
                     dbSelectArea("SCV")
                     SCV->(dbSetOrder(2)) // Filial  + Pedido  +  Parcela
                     If SCV->(! MsSeek(StrZero(Val(aLinha[nCont,04]),2) + AllTrim(aLinha[nCont,14]) +  StrZero(Val(aLinha[nCont,03]),2) ))
                        cObs += "Forma de pagamento nใo encontrada;"
                     Else
                        _cIdTrans  := scv->cv_IdTrans
                        _cFormaPg  := scv->cv_formapg
					 EndIf

                     If _cFormaPg = 'CC'
                     	_nValor := scv->cv_valor
                     Else
                        _nValor := Val(StrTran(StrTran(aLinha[nCont, 12], ".", ""),",", "."))
                     EndIf

                     // Valida Valor
                   	 If _nValor = 0
                     	cObs += "Valor invแlido;"
                     EndIf

                     // Valida Prefixo
                     If Empty(aLinha[nCont, 02])
                        cObs += "Prefixo invแlido;"
                     EndIf

                     // Valida Nr. do Tํtulo
                     DbSelectArea("SE1")
                     SE1->(dbSetOrder(1)) //E1_filial +  E1_prefixo + E1_num + E1_parcela + E1_tipo
                     If DbSeek( xFilial("SE1") + aLinha[nCont, 02] + _cTitulo + StrZero(Val(aLinha[nCont,03]),2) + 'RA' )
                     	cObs += 'Tํtulo jแ existe;'
                     Else
                     	If Empty(_cTitulo) 
                     	   cObs += "Tํtulo invแlido;"
                     	EndIf
                     EndIf

                     // Valida Banco Agencia e Conta
                     DbSelectArea("SA6")
                     SA6->(dbSetOrder(1)) // A6_Filial + A6_Cod + A6_Agencia + A6_Numcon
                     If SA6->(! MsSeek( xFilial("SA6") + AllTrim(aLinha[nCont,05]) + PadR(aLinha[nCont,06],5) + PadR(aLinha[nCont,07],10) ) )
                   		cObs += 'Banco/Agencia/Conta invแlido(s);'
                     ElseIf sa6->a6_blocked = '1'
                   	    cObs += 'Conta bancแria bloqueada;'
                     EndIf

 			         // Valida Cliente
			         DbSelectArea( "SA1" )
			         SA1->(dbSetOrder(1))
			         If SA1->(! MsSeek(xFilial("SA1") + _cCli + _cLoja ) )
			            cObs += "Cliente Invalido;"
			         EndIf

                     // Valida Natureza
                     dbSelectArea("SED")
                     SED->(dbSetOrder(1))
                     If SED->(! MsSeek(xFilial("SED") + AllTrim(aLinha[nCont,10])) )
                        cObs += "Natureza Invalida;"
                     EndIf

                     // Valida Vencimento
                     If Empty(aLinha[nCont, 11]) .or. ( cToD(aLinha[nCont,11]) < cToD(aLinha[nCont,01]) )
                        cObs += "Vencimento menor que emissใo;"
                     EndIf

                     // Valida Hist๓rico
                     If Empty(aLinha[nCont, 13])
                        cObs += "Hist๓rico invแlido;"
                     EndIf

                     // Valida Nro. Documento
                     If Empty(aLinha[nCont, 15])
                        cObs += "Nro. Documento invแlido;"
                     EndIf

                     aAdd(aTitulos, { If(Empty(cObs), oOk, oErro),;			// 1- Legenda
                     				 dToC( cToD(aLinha[nCont,01]) ),;       // 2- Data de Emissใo
                     				 aLinha[nCont,02],;		                // 3- Prefixo
                     				 _cTitulo,;								// 4- Nro. do Tํtulo ้ o mesmo do pedido
                     				 StrZero(Val(aLinha[nCont,03]),2),;		// 5- Nro. Parcela
                                     StrZero(Val(aLinha[nCont,04]),2),;		// 6- Filial
                                     aLinha[nCont,05],; 					// 7- Banco
                                     aLinha[nCont,06],;                    	// 8- Agencia
                                     aLinha[nCont,07],;                    	// 9- Conta
                                     _cCli,;			 					// 10-Cliente
                                     _cLoja,;								// 11-Loja do Cliente
                                     aLinha[nCont,10],; 					// 12-Natureza
                                     dToC( cToD(aLinha[nCont,11]) ),;       // 13-Vencimento
                                     _nValor,;  							// 14-Valor do Tํtulo
                                     aLinha[nCont,13],;                    	// 15-Hist๓rico
                                     aLinha[nCont,14],;                    	// 16-Nro do Pedido
                                     _cPedSite,;                            // 17-Nro. PedSite
									 _cPedMkp,;                             // 18-Nro Pedido MKP
									 _cFilOrig,;                            // 19-Filal de Origem do Pedido
                                     _cIdTrans,;        					// 20-IdTrans
                                     _cFormaPg,;                    		// 21-Forma de Pagamento
                                     aLinha[nCont,15],;                    	// 22-Nro. do Documento
                                     cObs }) 								// 23-Status da Importa็ใo
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
ฑฑบPrograma  ณ fProcArq()    บ Autor ณ Luiz Neves    บ Data ณ    20/01/20 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para incluir tํtulos tipo RA              		  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Infoar                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fProcArq()

	Local   nIx 	 	:= 0
	Local 	aErr   	 	:= {}
	Local   aTit        := {}
	Local   nTitulos    := 0

	Private lMsErroAuto := .F.

    If Len(aTitulos) = 0
       MsgStop('Nใo hแ tํtulos para incluir.','Erro')
       Return()
    EndIf

    For nIx := 1 To Len(aTitulos)

       If Empty(aTitulos[nIx, 23])  // Verifica se hแ inconsist๊ncias

		   aTit     := {}

   		   DbSelectArea("SE1")
		   se1->(DbSetOrder(1))
		   // Gera o tํtulo de adiantamento (RA)
		   lMsErroAuto:= .F.
		   aTit := {	{"E1_FILIAL"    , aTitulos[nIx, 06]         , NIL},;
			 			{"E1_PREFIXO"   , aTitulos[nIx, 03] 		, NIL},;
						{"E1_NUM"       , aTitulos[nIx, 04]         , NIL},;
						{"E1_PARCELA"   , aTitulos[nIx, 05]         , NIL},;
						{"E1_TIPO"      , "RA "                     , NIL},;
						{"E1_CLIENTE"   , aTitulos[nIx, 10]    		, NIl},;
						{"E1_LOJA"      , aTitulos[nIx, 11]         , NIL},;
						{"E1_NATUREZ"   , aTitulos[nIx, 12]         , NIL},;
				       	{"E1_EMISSAO"   , CtoD(aTitulos[nIx, 02])   , NIL},;
						{"E1_CONEMP"    , "INFA139"					, NIL},;
						{"E1_ORIGEM"    , "FINA040"                 , NIL},;
						{"E1_FLUXO"     , "S"                       , NIL},;
						{"E1_FILORIG"   , aTitulos[nIx, 06]         , NIL},;
						{"E1_MSFIL"     , aTitulos[nIx, 06]         , NIL},;
				   		{"E1_VENCTO"    , CtoD(aTitulos[nIx, 13])   , NIL},;
				   		{"E1_VENCREA"   , CtoD(aTitulos[nIx, 13])   , NIL},;
						{"E1_EMIS1"     , CtoD(aTitulos[nIx, 13])   , NIL},;
						{"E1_HIST"      , aTitulos[nIx, 15]			, NIL},;
						{"CBCOAUTO"     , aTitulos[nIx, 07]         , NIL},;
						{"CAGEAUTO"     , aTitulos[nIx, 08]         , NIL},;
						{"CCTAAUTO"     , aTitulos[nIx, 09]         , NIL},;
						{"E1_MOEDA"     , 1                         , NIL},;
						{"E1_VALOR"     , aTitulos[nIx, 14]			, NIL},;
						{"E1_PEDIDO"    , aTitulos[nIx, 16]         , NIL},;
						{"E1_PEDSITE"   , aTitulos[nIx, 17]         , NIL},;
						{"E1_PEDMKP"    , aTitulos[nIx, 18]         , NIL},;
                        {"E1_FILORIG"   , aTitulos[nIx, 19]         , NIL},;
						{"E1_IDTRANS"   , aTitulos[nIx, 20]         , NIL},;
						{"E1_FORMAPG"   , aTitulos[nIx, 21]         , NIL},;
						{"E1_NRDOC"     , aTitulos[nIx, 22]         , NIL}} 

		   MsExecAuto({|x,y| FINA040(x,y)}, aTit, 3)		//  3 - Inclusao
		   If lMsErroAuto
			  aErr   := GetAutoGrLog()
			  MostraErro()
		      Exit
		   EndIf

       EndIf

       nTitulos ++

	Next nIx

	MsgInfo("Foram inseridos " + cValToChar(nTitulos) + " Titulo(s).", "Mensagem")

	// Limpa ListBox
	aTitulos := {}
    aListBox := aTitulos
    oLstBx:SetArray(aListBox)
    Montlstbx()
	oLstBx:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MontLstBx()   บ Autor ณ Luiz Neves    บ Data ณ 20/01/2020  บฑฑ
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
	                     ,aListBox[oLstBx:nAt,10];
	                     ,aListBox[oLstBx:nAt,11];
	                     ,aListBox[oLstBx:nAt,12];
	                     ,aListBox[oLstBx:nAt,13];
	                     ,("R$ " + PADL(Alltrim(Transform(aListBox[oLstBx:nAt,14],"@E 999,999,999.99")),14));
	                     ,aListBox[oLstBx:nAt,15];
	                     ,aListBox[oLstBx:nAt,16];
	                     ,aListBox[oLstBx:nAt,17];
	                     ,aListBox[oLstBx:nAt,18];
	                     ,aListBox[oLstBx:nAt,19];
	                     ,aListBox[oLstBx:nAt,20];
						 ,aListBox[oLstBx:nAt,21];
	                     ,aListBox[oLstBx:nAt,22];
	                     ,aListBox[oLstBx:nAt,23];
	                     }}

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณfLegenda   ณ Autor ณ Luiz A. Neves              ณ Data ณ20/01/2020ณฑฑ
ฑฑณ          ณ           ณ                                                       ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUSO       ณINFOAR             ณ	                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Mostra Tela de Legendas                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณModulo    ณSIGAFIN                                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fLegenda()

	Local _aLegenda := {}

	aAdd(_aLegenda, {"BR_VERDE",		'Tํtulo OK'       				} )
	aAdd(_aLegenda, {"BR_VERMELHO",		'Tํtulo com dados incorretos'   } )

	BrwLegenda ( "Importa็ใo de Tํtulos tipo RA", "LEGENDA", _aLegenda )

Return()
