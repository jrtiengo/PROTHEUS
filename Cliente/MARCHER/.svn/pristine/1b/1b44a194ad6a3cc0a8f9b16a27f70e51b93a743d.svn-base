#include 'totvs.ch'

//-- User para aparecer no inspetor de objetos
User Function MSCBPrinter() ; Return

/*/{Protheus.doc} MSCBPrinter 
Classe cuja os metodos representam as funcoes MSCB(s) para impressao de etiquetas.
	Criada exclusivamente para obter os recursos das classes filhas como a MSCBZPL, MSCBEPL
	e entre outras que são instanciadas pela funcao MSCBPrinter.
	Também foi adicionado um novo metodo de finalização que impede a impressão da etiqueta e
	gera apenas os codidos ZPL,EPL... 
	https://github.com/lucasbrustolin/Protheus-Etiqueta-Zebra
@type class
@Sample MSCBPrinter():New()
@author Lucas.Brustolin
@since 14/10/2019
@version 12.1.27
/*/
	CLASS  MSCBPrinter From LongClassName

		Data oMSCB	As Object
		Data cType	As String

		Method New() CONSTRUCTOR
		Method MSCBPrinter(ModelPrt,cPorta,nDensidade,nTamanho,lSrv,nPorta,cServer,cEnv,nMemoria,cFila,lDrvWin,cPathIni) CONSTRUCTOR
		Method GetType() // Retorna o modelo de impressora
		Method MSCBBEGIN(nxQtde,nVeloc,nTamanho,lSalva)
		Method MSCBEND()
		Method MSCBEND2()
		Method MSCBWrite(cConteudo,cModo)
		Method MSCBIsPrinter()
		Method MSCBClosePrinter()
		Method MSCBCHKStatus(lStatus)
		Method MSCBSAY(nXmm,nYmm,cTexto,cRotacao,cFonte,cTam,lReverso,lSerial,cIncr,lZerosL,lNoAlltrim)
		Method MSCBVar(cVar,cDados)
		Method MSCBSAYMEMO(nXmm,nYmm,nLMemomm,nQLinhas,cTexto,cRotacao,cFonte,cTam,lReverso,cAlign)
		Method MSCBSAYBAR(nXmm,nYmm,cConteudo,cRotacao,cTypePrt,nAltura,lDigVer,lLinha,lLinBaixo,cSubSetIni,nLargura,nRelacao,lCompacta,lSerial,cIncr,lZerosL)
		Method MSCBBOX(nX1mm,nY1mm,nX2mm,nY2mm,nExpessura,cCor)
		Method MSCBLineH(nX1mm,nY1mm,nX2mm,nExpessura,cCor)
		Method MSCBLineV(nX1mm,nY1mm,nY2mm,nExpessura,cCor)
		Method MSCBGRAFIC(nXmm,nYmm,cArquivo,lReverso)
		Method MSCBLOADGRF(cImagem)

	ENDCLASS


/*/{Protheus.doc} New
Construtor da classe
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method New() CLASS MSCBPrinter

	Self:oMSCB	:= Nil
	Self:cType	:= ""

Return( Self )


/*/{Protheus.doc} MSCBPrinter
Inicializa os dados de conexão com a impressora
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBPrinter(ModelPrt,cPorta,nDensidade,nTamanho,lSrv,nPorta,cServer,cEnv,nMemoria,cFila,lDrvWin,cPathIni) CLASS MSCBPrinter

	Local aArea:= GetArea()

	If MSCbModelo('ZPL',ModelPrt)
		Self:cType := 'ZPL'
		Self:oMSCB := MSCBZPL():New(ModelPrt,cPorta,nDensidade,nTamanho,lSrv,nPorta,cServer,cEnv,nMemoria,cFila,lDrvWin,cPathIni)
	ElseIf MSCbModelo('DPL',ModelPrt)
		Self:oMSCB := MSCBDPL():New(ModelPrt,cPorta,nDensidade,nTamanho,lSrv,nPorta,cServer,cEnv,nMemoria,cFila,lDrvWin,cPathIni)
		Self:cType := 'DPL'
	ElseIf MSCbModelo('EPL',ModelPrt)
		Self:oMSCB := MSCBEPL():New(ModelPrt,cPorta,nDensidade,nTamanho,lSrv,nPorta,cServer,cEnv,nMemoria,cFila,lDrvWin,cPathIni)
		Self:cType := 'EPL'
	ElseIf MSCbModelo('IPL',ModelPrt)
		Self:oMSCB := MSCBIPL():New(ModelPrt,cPorta,nDensidade,nTamanho,lSrv,nPorta,cServer,cEnv,nMemoria,cFila,lDrvWin,cPathIni)
		Self:cType := 'IPL'
	Else
		// modelo nao encontado, portanto default zebra com densidade 6
		Self:oMSCB := MSCBZPL():New("S500-6",cPorta,nDensidade,nTamanho,lSrv,nPorta,cServer,cEnv,nMemoria,cFila,lDrvWin,cPathIni)
		Self:cType := 'ZPL'
	EndIf

	Self:oMSCB:Setup()

	RestArea(aArea)

Return( Self )


/*/{Protheus.doc} GetType
Retorna o Tipo do modelo da impressora
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method GetType() CLASS MSCBPrinter
Return(Self:cType)


/*/{Protheus.doc} MSCBBEGIN
Configuração inicial da impressão
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBBEGIN(nxQtde,nVeloc,nTamanho,lSalva) Class MSCBPrinter
	Self:oMSCB:CBBegin(nxQtde,nVeloc,nTamanho,lSalva)
Return('')


/*/{Protheus.doc} MSCBEND
Finaliza a impressão
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBEND() Class MSCBPrinter
Return (Self:oMSCB:CBEnd() )


/*/{Protheus.doc} MSCBWrite
Impressão dos dados 
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBWrite(cConteudo,cModo) CLASS MSCBPrinter

	cModo := If(cModo==NIL,"WRITE",cModo)

	If (cModo=="ABRE")
		Self:oMSCB:cResult :=''
	ElseIf (cModo=="WRITE")
		Self:oMSCB:cResult +=cConteudo
	ElseIf (cModo=="FECHA")
		Self:oMSCB:Envia()
	EndIf

Return('')


/*/{Protheus.doc} MSCBIsPrinter
Verifica se o objeto foi inicializado
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBIsPrinter() CLASS MSCBPrinter

	If ValType(Self:oMSCB) <> "O"
		Return .F.
	EndIf

Return( Self:oMSCB:IsPrinted )


/*/{Protheus.doc} MSCBClosePrinter
Fecha a impressão
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBClosePrinter() CLASS MSCBPrinter
Return( Self:oMSCB:Close() )


/*/{Protheus.doc} MSCBCHKStatus
Verifica o Status da Impressão
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBCHKStatus(lStatus) CLASS MSCBPrinter

	If lStatus <> NIL
		Self:oMSCB:lCHKStatus := lStatus
	EndIf

	If  Self:oMSCB:lDrvWin
		Self:oMSCB:lCHKStatus := .F.
	EndIf

	If Self:oMSCB:lSpool
		MSCBGrvSpool(5,,Self:oMSCB)
	EndIf

Return( Self:oMSCB:lCHKStatus )


/*/{Protheus.doc} MSCBSAY
Imprime um texto
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBSAY(nXmm,nYmm,cTexto,cRotacao,cFonte,cTam,lReverso,lSerial,cIncr,lZerosL,lNoAlltrim) CLASS MSCBPrinter
	Self:oMSCB:Say(nXmm,nYmm,cTexto,cRotacao,cFonte,cTam,lReverso,lSerial,cIncr,lZerosL,lNoAlltrim)
Return('')


/*/{Protheus.doc} MSCBVar
Imprime um texto
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBVar(cVar,cDados) CLASS MSCBPrinter
	Self:oMSCB:Var(cVar,cDados)
RETURN('')


/*/{Protheus.doc} MSCBSAYMEMO
Imprime um Memo
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBSAYMEMO(nXmm,nYmm,nLMemomm,nQLinhas,cTexto,cRotacao,cFonte,cTam,lReverso,cAlign) CLASS MSCBPrinter
	Self:oMSCB:Memo(nXmm,nYmm,nLMemomm,nQLinhas,cTexto,cRotacao,cFonte,cTam,lReverso,cAlign)
Return('')


/*/{Protheus.doc} MSCBSAYBAR
Imprime o Código de Barras
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBSAYBAR(nXmm,nYmm,cConteudo,cRotacao,cTypePrt,nAltura,lDigVer,lLinha,lLinBaixo,cSubSetIni,nLargura,nRelacao,lCompacta,lSerial,cIncr,lZerosL) CLASS MSCBPrinter
	Self:oMSCB:Bar(nXmm,nYmm,cConteudo,cRotacao,cTypePrt,nAltura,lDigVer,lLinha,lLinBaixo,cSubSetIni,nLargura,nRelacao,lCompacta,lSerial,cIncr,lZerosL)
Return('')


/*/{Protheus.doc} MSCBBOX
Imprime uma caixa de texto
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBBOX(nX1mm,nY1mm,nX2mm,nY2mm,nExpessura,cCor) CLASS MSCBPrinter
	Self:oMSCB:Box(nX1mm,nY1mm,nX2mm,nY2mm,nExpessura,cCor)
Return('')


/*/{Protheus.doc} MSCBLineH
Imprime uma linha Horizontal
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBLineH(nX1mm,nY1mm,nX2mm,nExpessura,cCor) CLASS MSCBPrinter
	Self:oMSCB:LineH(nX1mm,nY1mm,nX2mm,nExpessura,cCor)
Return('')


/*/{Protheus.doc} MSCBLineV
Imprime uma linha vertical
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBLineV(nX1mm,nY1mm,nY2mm,nExpessura,cCor) CLASS MSCBPrinter
	Self:oMSCB:LineV(nX1mm,nY1mm,nY2mm,nExpessura,cCor)
Return('')


/*/{Protheus.doc} MSCBGRAFIC
Realiza a impressão gráfica
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBGRAFIC(nXmm,nYmm,cArquivo,lReverso) CLASS MSCBPrinter
	Self:oMSCB:GRAFIC(nXmm,nYmm,cArquivo,lReverso)
Return('')


/*/{Protheus.doc} MSCBLOADGRF
Carregar a imagem
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBLOADGRF(cImagem) CLASS MSCBPrinter
Return( Self:oMSCB:LOADGRF(cImagem) )


/*/{Protheus.doc} MSCBEND2
Finalização da impressão
@type method
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/03/2022
/*/
Method MSCBEND2() CLASS MSCBPrinter

	Local cConteudo := ""

	Self:oMSCB:cResult += "^XZ" + CRLF

	If Len(Self:oMSCB:cResult) > Self:oMSCB:nMemory
		cConteudo := Self:oMSCB:cResult
	EndIF

Return cConteudo
