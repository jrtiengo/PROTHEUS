#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDevFuncoesณ HELITOM SILVA              บ Data ณ  05/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณNeste arquivo sao armazenadas funcoes genericas para uso da บฑฑ
ฑฑบ          ณFabrica Totvs Mato Grosso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fabrica Totvs Mato Grosso                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


/*{ProtheusDoc} HSoNumeros()

	@developer	helitom.silva
	@data		05/06/2012


    ****Funcao para validacao de string com apenas numeros***
    Esta funcao tem o objetivo de validar uma string que tenha apenas numeros

    Parametros:
    pString - String a ser validada.

    Retorno:
    .t. - Se a string contem apenas numeros
    .f. - Se a string contem letras ou caracteres especiais

    Obs: Quando o retorno for .f. sera exibida a seguinte mensagem
         'Informa็ใo invalida, por favor, informe  apenas numeros!'

*/
User Function HSoNumeros(pString)

     Local lRet := .t.
     Local __h	 := 0

     pString := alltrim(pString)

     If .Not. Empty(pString)
        For __h := 1 to Len(pString)
            If ! Substr(pString, __h, 1) $ '0123456789'
               lRet := .f.

               MsgInfo('Informa็ใo invalida, por favor, informe apenas n๚meros!')
               Return lRet
            EndIf
        Next
     EndIf

Return lRet

/*{ProtheusDoc} HSeleArq()

	@developer	helitom.silva
	@data		   21/08/2012


    ****Funcao para selecionar aquivos e retornar o caminho***
    Esta funcao tem o objetivo de retornar um caminho do arquivo selecionado ou para ser salvo.

    Parametros:
    pTitulo - Titulo da janela.

    pMasc   - Default: "Arquivos Texto (*.TXT) |*.txt|"
              Mascara para aparecer apenas arquivo com extencao especifica.
              Exemplo: Arquivos csv (*.csv) |*.csv| ou "Arquivos Texto (*.TXT) |*.txt|

    lSalva  - Default: .f.
              Se .T. mostra botao de salvar senao mostra botao de abrir para selecionar o arquivo.


    Retorno:
    Retorna o caminho do arquivo a ser lido ou salvo.

*/
User Function HSeleArq(pTitulo, pMasc, lSalva)

	Local cCaminho := ""

	Default pMasc  := "Arquivos Texto (*.TXT) |*.txt|"
	Default lSalva := .f.

	// Declara็ใo de Variaveis Private dos Objetos
	SetPrvt("oDlg1","oPanel1","oSay1","oGet1","oSBtn1","oBtn1")

	// Definicao do Dialog e todos os seus componentes.

	oDlg1      := MSDialog():New( 091,232,161,694,pTitulo,,,.F.,,,,,,.T.,,,.T. )
	oPanel1    := TPanel():New( 000,000,"",oDlg1,,.F.,.F.,,,226,029,.T.,.F. )

	oSay1      := TSay():New( 004,004,{||"Informe o Caminho do Arquivo"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oGet1      := TGet():New( 012,004,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oPanel1,144,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

	oSBtn1     := SButton():New( 011,152,iif(lSalva,13,14),{|| (cCaminho:=cGetFile(pMasc,""),oGet1:Refresh())},oPanel1,,"", )
	oBtn1      := TButton():New( 011,188,"OK",oPanel1,{|| oDlg1:End()},030,011,,,,.T.,,"",,,,.F. )

	oDlg1:Activate(,,,.T.)

Return (cCaminho)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()   ณ Autores ณ Norbert/Ernani/Mansano ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _C(nTam)

	Local nHResH	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	Local nHResV	:=	oMainWnd:nClientHeight	// Resolucao vertical   do monitor

	If (nHResH == 776)	//Resolucao 800x600
		nTam *= 0.68
	ElseIf (nHResH == 1000)	//Resolucao 1024x768
		nTam *= 0.89
	ElseIf (nHResH == 1128)	//Resolucao 1152x864
		nTam *= 1
	ElseIf (nHResH == 1256 .And. nHResV == 453)	//Resolucao 1280x600
		nTam *= 0.68
	ElseIf (nHResH == 1256 .And. nHResV == 573)	//Resolucao 1280x720
		nTam *= 0.88
	ElseIf (nHResH == 1256 .And. nHResV == 621)	//Resolucao 1280x768
		nTam *= 0.96
	ElseIf (nHResH == 1256 .And. nHResV == 813)	//Resolucao 1280x960
		nTam *= 1
	Else	//Resolucao 1280x1024
		nTam *= 1
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento para tema "Flat"ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*{ProtheusDoc} ADVParSQL()

	@developer	helitom.silva
	@data		   21/08/2012


    ****Funcao para retornar um filtro SQL***

    Parametros:
    cFilADV - String com Filtro de sintaxe ADVPL.


    Retorno:
    Retorna o string com filtro de Sintaxe SQL.

*/
User Function ADVParSQL(cFilADV)
	cFilADV := StrTran(Upper(cFilADV)	,".AND."  ," AND ")
	cFilADV := StrTran(Upper(cFilADV)	,".OR."   ," OR ")
	cFilADV := StrTran(cFilADV       	,"=="     ," = ")
	cFilADV := StrTran(cFilADV       	,"!="     ,"<>")
	cFilADV := StrTran(cFilADV       	,'"'      ,"'")
	cFilADV := StrTran(Upper(cFilADV)	,"ALLTRIM"," ")
	cFilADV := StrTran(cFilADV       	,'$'      ," IN ")
	cFilADV := StrTran(Upper(cFilADV)	,"DTOS"   ,"")
	cFilADV := StrTran(cFilADV				,"->"   ,".")
Return(cFilADV)

/*{ProtheusDoc} HDataExt()

	@developer	helitom.silva
	@data		   21/07/2013


    ****Funcao para retornar uma data por extenso***

    Parametros:
    dData - Informa็ใo no formato data


    Retorno:
    Retorna o string com filtro de Sintaxe SQL.

*/
User Function HDataExt(dData)

	Local cData 	  := DtoS(dData)	
	Local cDataExt   := ''	
	Local cDia 	  	  := ''
	Local cMes 	  	  := ''
	Local cAno 	  	  := ''
	Local nMes 	  	  := 0
		
	cDia := Extenso(Val(SubStr(cData, 7, 2)), .t.)
	nMes := Val(SubStr(cData, 5, 2))
	cAno := Extenso(Val(SubStr(cData, 1, 4)), .t.)	

	Do Case
		Case nMes == 1
			cMes := "Janeiro"
		Case nMes == 2
			cMes := "Fevereiro"
		Case nMes == 3
			cMes := "Mar็o"
		Case nMes == 4
			cMes := "Abril"
		Case nMes == 5
			cMes := "Maio"
		Case nMes == 6
			cMes := "Junho"
		Case nMes == 7
			cMes := "Julho"
		Case nMes == 8
			cMes := "Agosto"
		Case nMes == 9
			cMes := "Setembro"
		Case nMes == 10
			cMes := "Outubro"
		Case nMes == 11
			cMes := "Novembro"
		Case nMes == 12
			cMes := "Dezembro"
	EndCase

	cDataExt := Upper(cDia + ' de ' + cMes + ' de ' + cAno)
	
Return (cDataExt)

/*{ProtheusDoc} HDataExt()

	@developer	helitom.silva
	@data		   03/08/2013


    ****Funcao para retornar o codigo de uma cor***
	 
	 Use o software (RGB Flop) baixe o no baixa aqui para configurar uma cor e saber a quantidade de cada uma das cores Vermelho, Verde e Azul.
	 
    Parametros:
    nRed   - Quantidade de Vermelho (0..255)
	 nGreen - Quantidade de Verde (0..255)
	 nBlue  - Quantidade de Azul (0..255)
	 
    Retorno:
    Retorna o codigo da cor com base na mistura informada nos parametros.

*/
User Function HRetColor(nRed, nGreen, nBlue)

	Local	nColor := 255
	
	Default nRed 	:= 0
	Default nGreen := 0
   Default nBlue  := 0
   
   If ((nRed > 0) .or. (nGreen > 0) .or. (nBlue > 0))
   	nColor := nRed + (nGreen * 256) + (nBlue * 65536)
   EndIf
   
Return (nColor)

/*{ProtheusDoc} HDataExt()

	@developer	helitom.silva
	@data		   03/08/2013


    **** Funcao para arrendodar valor para acima ***
	 
    Parametros:
    nValor   - Valor
    nCasDec	 - Casas decimais
	 
    Retorno:
    Retorna o valor arredondado para cima, conforme casas decimais.

*/
User Function HArVlCima(nValor, nCasDec)
	
	Local cValor 	:= Str(nValor)
	Local cInteiro := Substr(cValor, 1, At('.', cValor) - 1)
	Local cDecimal	:= Substr(cValor, At('.', cValor) + 1)
	
	If Val(cDecimal) > 0
			
		If Len(cDecimal) > nCasDec
			cDecimal := If(Val(Substr(cDecimal, nCasDec)) > 0, cValToChar(Val(cDecimal) + 1), cValToChar(Val(cDecimal)))
		Else
			cDecimal := Substr(cDecimal, 1, nCasDec)
		EndIf
		
	Else
	
		cDecimal := Replicate('0', nCasDec)
		
	EndIf
	
	If Val(cDecimal) > Val(Replicate('9', nCasDec))		
		cInteiro := cValToChar(Val(cInteiro) + 1)
		cDecimal := Replicate('0', nCasDec)
			
		cValor := cInteiro + '.' + cDecimal
	Else
		cValor := cInteiro + '.' + cDecimal
	EndIf
	
Return (Val(cValor))


/*{ProtheusDoc} HConfirm()

	@developer	helitom.silva
	@data		   22/08/2013


    ****Funcao para Mensagem de Confirmacao***
    	 
    Parametros:
    p_cMsg    - Mensagem
	 p_cTitulo - Titulo da Tela
	 p_aOpc    - Array com dois itens, para identificar os nomes dos botoes exemplo: {'Sim', 'Nใo'}
	 p_nFocus  - Qual opcao terแ o foco
	 
    Retorno:
    Retorna se .t. se confirmou e .f. se nao confirmou

*/
User Function HConfirm(p_cMsg, p_cTitulo, p_aOpc, p_nFocus)
	
	Local lRet 	  := .F. 
	Local lSelect := .F.
	
	Default p_cMsg 	:= 'Confirma esta a็ใo?'
	Default p_cTitulo := 'Confirma็ใo'
	Default p_aOpc    := {'&Sim', '&Nใo'}
	Default p_nFocus  := 1	
		
	// Declara็ใo de Variaveis Private dos Objetos                            
	SetPrvt("oDlgConf","oPanConf","oSayConf","oBtnSim","oBtnNao")
	
	// Definicao do Dialog e todos os seus componentes.                        
	oDlgConf := MSDialog():New( 091, 233, 201, 544, p_cTitulo,,,.F.,,,,,,.T.,,,.T. )
	oPanConf := TPanel():New( 000, 000, "", oDlgConf,,.F.,.F.,,,158,053,.F.,.F. )
	oSayConf := TSay():New( 012 ,008, {|| p_cMsg},oPanConf,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,140,020)
	oBtnSim  := TButton():New( 037, 032, p_aOpc[1], oPanConf, {|| lRet:= .T., lSelect := .T.,oDlgConf:End()},045,012,,,,.T.,,"",,,,.F. )
	oBtnNao  := TButton():New( 037, 080, p_aOpc[2], oPanConf, {|| lRet:= .F., lSelect := .T.,oDlgConf:End()},045,012,,,,.T.,,"",,,,.F. )
	
	If p_nFocus == 1
		oBtnSim:SetFocus()
	Else
		oBtnNao:SetFocus()
	EndIf
	
	oDlgConf:Activate(,,,.T., {|| If(!lSelect, (MsgInfo('Selecione uma das duas op็๕es!'), lSelect), lSelect)})

Return (lRet)

/*{ProtheusDoc} TimeExec()

	@developer	helitom.silva
	@data		   27/08/2013


    ****Funcao para Demonstra็ใo de Tempo de Execu็ใo***
	 
	 Esta funcao poderแ ser usada para medir o tempo de execu็ใo de determinada Rotina, Consulta SQL, calculo e etc..
	 
    Parametros:
    p_nSegIni - Informe o tempo inicial por meio da fun็ใo "Seconds()"
	 p_nSegFim - Informe o tempo final por meio da fun็ใo "Seconds()"
	 
	 Saiba mais sobre a fun็ใo "Seconds()" em http://tdn.totvs.com.br/display/tec/Seconds
	 
    Retorno:
    Retorna se Tempo no formato HH:MM:SS.MS (MS - MiliSegundos)

*/
User Function HTimeExec(p_nSegIni, p_nSegFim) 

	Local nHH, nMM , nSS, nMS := (p_nSegFim - p_nSegIni)
	Local cRet := ''
	
	nHH := int(nMS/3600) 
	nMS -= (nHH*3600) 
	nMM := int(nMS/60) 
	nMS -= (nMM*60) 
	nSS := int(nMS) 
	nMS := (nMs - nSS)*1000 
	
	cRet := (StrZero(nHH,2) + ":" + StrZero(nMM,2) + ":" + StrZero(nSS, 2) + "." + StrZero(nMS, 3))
	
Return (cRet)

/*{ProtheusDoc} IsProcCall()

	@developer	Marcelo.Camper
	@data		   02/09/2013


    ****Funcao para retornar se uma determinada funcao esta na pilha de Execu็ใo***
	 
	 Esta funcao poderแ ser usada para checar se uma funcao esta na pilha de execucao.
	 
    Parametros:
    cRotina = Informe a funcao que deseja verificar
	 
    Retorno:
    Retorna se True se a funcao esta na pilha, senao False.  

*/
User Function IsProcCall(cRotina)

	Local _n      := 1
	Local _lRet   := .F.
	Local _cVazio := AllTrim(ProcName(_n))
	
	While !Empty(_cVazio)
	   If AllTrim(ProcName(_n))=cRotina
	      _cVazio:=''
	      _lRet:=.T.
	      Return (_lRet)
	   Else
	      _n:=_n+1
	      _cVazio:=alltrim(ProcName(_n))
	   EndIf
	End
	
Return (_lRet)

/*{ProtheusDoc} OpenURLP()

	@developer	Helitom Silva 
	@data		   16/09/2013
	 
    **** Funcao para abrir um URL numa tela de browser de Internet dentro do Protheus ***
	 
	 Esta funcao poderแ ser usada para Visualizar uma pagina WEB dentro do protheus como Manual e etc..
	 
	 Obs.: S๓ funciona se o Browser do Protheus estiver habilitado.	
	 Alguns Metodos:
		
	 //oTIBrowser:Navigate( cURL )  Ir a pagina da URL especificada.   
    //oTIBrowser:GoHome() //Ir na pagina de inicio.	
    Fonte: http://tdn.totvs.com/display/tec/TIBrowser
    	  
    Parametros:
    p_cURL = Informe a URL a ser acessada e aberta no Browse.
	 
    Retorno:
    Retorna uma tela de Browse dentro do Protheus com a URL passada por parametro. 

*/
User Function OpenURLP(p_cURL)
 	
 	 Local _aSize := MsAdvSize() 
 	 
 	 /*
	 	 1 -> Linha inicial แrea trabalho.
	    2 -> Coluna inicial แrea trabalho.
		 3 -> Linha final แrea trabalho.
		 4 -> Coluna final แrea trabalho.
		 5 -> Coluna final dialog (janela).
		 6 -> Linha final dialog (janela).
		 7 -> Linha inicial dialog (janela).
	 */	
 
    oDlgURL := MSDialog():New( _aSize[7], 0, _aSize[6], _aSize[5], "Protheus Browser",,,.F.,,,,,,.T.,,,.T. )
     
    oTIBrowser := TIBrowser():New(0, 0, _aSize[5] - 640, 262, p_cURL, oDlgURL )
  
    TButton():New( oDlgURL:nHeight - 20, 10, "Imprimir", oDlgURL, {|| oTIBrowser:Print()}, 40, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
             
    oDlgURL:Activate(,,,.T.)

Return

/*{ProtheusDoc} OpenURLB()

	@developer	Helitom Silva 
	@data		   16/09/2013
	 
    **** Funcao para abrir um URL numa tela de browser de Internet dentro do Protheus ***
	 
	 Esta funcao poderแ ser usada para abrir uma pagina Web no navegador padrao do Windows.
    	  
    Parametros:
    p_cURL = Informe a URL a ser aberta no navegador.
	 
    Retorno:
    Nenhum 

*/
User Function OpenURLB(p_cURL)
 	
 	WinExec('CMD /C START ' + p_cURL)
 	 
Return

/*{ProtheusDoc} XPUTMV()

	@developer	Julio Storino  
	@data		   28/03/2012
	 
    **** Funcao para VERIFICAR UM PARAMETRO - ATUALIZA E CRIA SE NECESSARIO. ***
	 
	 Esta funcao poderแ ser usada para alterar o valor de um parametro do sistema
    	  
    Parametros:
	 
    Retorno:
    Nenhum 

*/
User Function HPutMv(xcMvPar, xcValor, xcFilial, xcDesc)

	Local lExist		:= .F.
	
	Local _nRecSX6		:= 0
	Local _nOrdSX6		:= 0
	
	Default xcFilial	:= cFilAnt			// Sempre tento encontrar primeiro pela filial
	Default xcDesc		:= "Atualizar este descricao !"
	
	If Select("SX6") = 0
		DbSelectArea("SX6")
	EndIf
	
	_nRecSX6		:= SX6->(Recno())
	_nOrdSX6		:= SX6->(IndexOrd())
	
	If Empty(xcMvPar)
		Return( .F. )
	EndIf
	
	SX6->(DbSetOrder(1))
	SX6->(DbGoTop())
	
	//Verifico se existe o parametro para a Filial passada ou sem filial
	If !SX6->(MsSeek( xcFilial + Substr(xcMvPar,1,10)))
		If SX6->(MsSeek( Space(Len(AllTrim(cFilAnt))) + Substr(xcMvPar,1,10)))
			lExist := .T.
		EndIf
	Else
		lExist := .T.
	EndIf
	
	If ( ValType(xcValor) == 'D' )
		xcValor 	:= DtoC(xcValor)
	ElseIf ( ValType(xcValor) == 'N' )
		xValor	:= cValToChar(xcValor)
	ElseIf ( ValType(xcValor) == 'L' )
		xValor	:= If(xcValor,'.T.','.F.')
	EndIf
	
	If ( lExist )
	
		RecLock('SX6', .F. )
		FieldPut( FieldPos('X6_CONTEUD'), xcValor ) 
		FieldPut( FieldPos('X6_CONTSPA'), xcValor ) 
		FieldPut( FieldPos('X6_CONTENG'), xcValor ) 
		SX6->(MsUnlock())
	
		//Volta o ponteiro para o local original
		SX6->(DbSetOrder(_nOrdSX6))
		SX6->(DbGoTo(_nRecSX6))
	
	Else	
	
		//Volta o ponteiro para o local original
		SX6->(DbSetOrder(_nOrdSX6))
		SX6->(DbGoTo(_nRecSX6))
	
		RecLock('SX6', .T. )
	
		FieldPut( FieldPos('X6_FIL'), xcFilial ) 
		FieldPut( FieldPos('X6_VAR'), xcMvPar ) 
		FieldPut( FieldPos('X6_TIPO'), ValType(xcValor) ) 
		FieldPut( FieldPos('X6_DESCRIC'), Substr(xcDesc,1,50) ) 
		FieldPut( FieldPos('X6_DESC1'), Substr(xcDesc,51,50) ) 
		FieldPut( FieldPos('X6_DESC2'), Substr(xcDesc,101,50) ) 
		FieldPut( FieldPos('X6_DSCSPA'), Substr(xcDesc,1,50) ) 
		FieldPut( FieldPos('X6_DSCSPA1'), Substr(xcDesc,51,50) ) 
		FieldPut( FieldPos('X6_DSCSPA2'), Substr(xcDesc,101,50) ) 
		FieldPut( FieldPos('X6_DSCENG'), Substr(xcDesc,1,50) ) 
		FieldPut( FieldPos('X6_DSCENG1'), Substr(xcDesc,51,50) ) 
		FieldPut( FieldPos('X6_DSCENG2'), Substr(xcDesc,101,50) ) 
		FieldPut( FieldPos('X6_CONTEUD'), xcValor ) 
		FieldPut( FieldPos('X6_CONTSPA'), xcValor ) 
		FieldPut( FieldPos('X6_CONTENG'), xcValor ) 
		FieldPut( FieldPos('X6_PROPRI'), "U" ) 
		FieldPut( FieldPos('X6_PYME'), "S" ) 
		FieldPut( FieldPos('X6_VALID'), "" ) 	
		FieldPut( FieldPos('X6_INIT'), "" ) 
	
		SX6->(MsUnlock())
	
	EndIf

Return( .T. )

/*{ProtheusDoc} xGetMV()

	@developer	Julio Storino  
	@data		   28/03/2012
	 
    **** Funcao para PESQUISAR UM PARAMETRO, SEMPRE BUSCANDO NA TABELA SX6 ***
	 
	 Esta funcao poderแ ser usada para pesquisar o valor de um parametro do sistema
    	  
    Parametros:
	 
    Retorno:
    PESQUISA UM PARAMETRO, SEMPRE BUSCANDO NA TABEL SX6 OU
    RETORNA UM VALOR PADRAO. 

*/
User Function HGetMV(cMvPar, _cDef)

	Local lExist		:= .F.
	
	Local _nRecSX6		:= 0
	Local _nOrdSX6		:= 0
	
	Local xConteud		:= ""
	Local xTipo			:= ""
	
	Default _cDef		:= ""
	
	If Select("SX6") = 0
		DbSelectArea("SX6")
	EndIf
	
	_nRecSX6		:= SX6->(Recno())
	_nOrdSX6		:= SX6->(IndexOrd())
	
	SX6->(DbSetOrder(1))
	SX6->(DbGoTop())
	
	If !SX6->(MsSeek(cFilAnt + Subs( cMvPar, 1, 10)))
		If SX6->(MsSeek( Space(Len(AllTrim(cFilAnt)))+Subs(cMvPar,1,10)))
			lExist	:= .T.
		EndIf
	Else
		lExist := .T.
	EndIf
	
	If lExist
	
		xConteud := StrTran(StrTran(SX6->X6_CONTEUD,'"',''),"'","")
		xTipo		:= SX6->X6_TIPO
	
		//Volta o ponteiro para o local original
		SX6->(DbSetOrder(_nOrdSX6))
		SX6->(DbGoTo(_nRecSX6))
	
		Do Case
			Case xTipo = 'C'
				Return( AllTrim(xConteud) )
	
			Case xTipo = 'N'
				If Empty(xConteud)
					Return( 0 )
				Else
					Return( Val(AllTrim(xConteud)) )
				EndIf
	
			Case xTipo = 'L'
				If Upper(AllTrim(xConteud)) $ '.T.|S|VERDADEIRO|TRUE'
					Return( .T. )
				ElseIf Upper(AllTrim(xConteud)) $ '.F.|N|FALSO|FALSE'
					Return( .F. )
				Else
					Return( Nil )
				EndIf
	
			Case xTipo = 'D'
				If Empty(xConteud)
					Return( CtoD("  /  /    ") )
				ElseIf '/' $ xConteud
					Return( CtoD(AllTrim(xConteud)) )
				Else
					Return( StoD(AllTrim(xConteud)) )
				EndIf
	
			OtherWise
				Return( Nil )
	
		EndCase			
	
	Else
	
		//Volta o ponteiro para o local original
		SX6->(DbSetOrder(_nOrdSX6))
		SX6->(DbGoTo(_nRecSX6))
	
		Return( _cDef )
	
	EndIf

Return( Nil )

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ   Fonte  ณ   RetABox    บAutor  ณ Helitom Silva      บ Data ณ 29/12/2013    บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ User Function que converte CBox (SX3) em Array                   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HRetABox(cBox)
	
	Local aBox 		:= {}
	Local cItens 		:= "'"
	Local nX			:= 0
	Local cCaracter	:= 0
	
	If !Empty(AllTrim(cBox))
		
		For nX := 1 To Len(cBox)
			cItens += Iif((cCaracter := SubStr(cBox, nX, 1)) = ";", "','", cCaracter)
		Next
		
		cItens += "'"
		
		aBox := &('{' + cItens + '}')
		
	EndIf
	
Return aBox