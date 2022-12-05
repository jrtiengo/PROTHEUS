#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch"    

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM581.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponto de Entrada                       ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 13/06/2017                                                           ##
// Objetivo..: Programa que permite o usuário tornar o pedido de venda não separado ##
// ###################################################################################

User Function AUTOM582()   

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cPedidoB := Space(06)
   Private oGet1
   
   Private oDlg

   U_AUTOM628("AUTOM582")

   DEFINE MSDIALOG oDlg TITLE "Tornar PV Não Separado" FROM C(178),C(181) TO C(345),C(433) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(117),C(001) PIXEL OF oDlg
   @ C(059),C(002) GET oMemo2 Var cMemo2 MEMO Size C(117),C(001) PIXEL OF oDlg

   @ C(034),C(005) Say "Nº Pedido de Venda a ser alterado" Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) MsGet oGet1 Var cPedidoB Size C(049),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(066),C(022) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( BConfirma() )
   @ C(066),C(061) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre janela com os dados do pedido de venda informado
Static Function BConfirma()

   Local oCombo
   Local oMemo

   Private dEmissao
   Private nPbruto
   Private nPliq
   Private cEspecie
   Private cVolume
   Private cTransp
   Private cCliente
   Private cTpFrete
   Private cObsNota
   Private cJpcSep
         
   Private cMemo1
   Private oMemo1

   If Empty(Alltrim(cPedidoB))
      MsgAlert("Pedido de Venda a ser pesquisado não informado.")
      Return(.T.)
   Endif   

   DbSelectArea("SC5")
   DbSetOrder(1)
   If !DbSeek( xFilial("SC5") + cPedidoB)
      MsgAlert("Pedido de Venda informado não localizado.")
      Return(.T.)
   Endif

   dEmissao  := SC5->C5_EMISSAO
   nPbruto 	 := SC5->C5_PBRUTO
   nPliq   	 := SC5->C5_PESOL 
   cEspecie	 := SC5->C5_ESPECI1
   cVolume 	 := SC5->C5_VOLUME1
   cTransp 	 := SC5->C5_TRANSP
   cCliente	 := SC5->C5_CLIENTE+SC5->C5_LOJACLI
   nValNot   := 0
   cTpFrete  := SC5->C5_TPFRETE
   cObsNota  := SC5->C5_MENNOTA
   cJpcSep   := IIF(EMPTY(SC5->C5_JPCSEP),"N",SC5->C5_JPCSEP)

   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek( xFilial("SA1") + cCliente)

   cCGC := ""
   cIE 	:= ""

   If !EOF()
      cCliente 	:= cCliente + " - " + SA1->A1_Nome
 	  cCGC 		:= SA1->A1_CGC
	  cIE 		:= SA1->A1_INSCR
   Endif

   DbSelectArea("SC5")

   DEFINE MSDIALOG FASPedB TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 000,000 TO 500,450 OF oMainWnd Pixel Style DS_MODALFRAME

   @ 010,010 Say "Nr.do Ped.Venda :" 			              OF FASPedB Pixel
   @ 010,070 say cPedidoB						              OF FASPedB Pixel
   @ 010,095 SAY 'em '							              OF FASPedB Pixel
   @ 010,104 SAY dEmissao Picture '99/99/99' 	              OF FASPedB Pixel
   @ 017,010 Say "Cliente :"					              OF FASPedB Pixel
   @ 017,070 Say cCliente						              OF FASPedB Pixel
   @ 024,010 say "CGC-MF/IE : "				                  OF FASPedB Pixel
   @ 024,070 say cCGC+" / "+cIE				                  OF FASPedB Pixel
   @ 042,010 Say "Peso Br: "					              OF FASPedB Pixel
   @ 042,070 MsGet nPbruto picture "@E 99999.99" SIZE 040,010 OF FASPedB Pixel
   @ 054,010 Say "Peso Lq: "		   			              OF FASPedB Pixel
   @ 054,070 MsGet nPliq picture "@E 99999.99"	SIZE 040,010  OF FASPedB Pixel
   @ 066,010 Say "Especie: "					              OF FASPedB Pixel
   @ 066,070 MsGet cEspecie					    SIZE 040,010  OF FASPedB Pixel
   @ 078,010 Say "Volume.: "					              OF FASPedB Pixel
   @ 078,070 MsGet cVolume Picture "999999"		SIZE 040,010  OF FASPedB Pixel
   @ 090,010 Say "Transpor.: "					              OF FASPedB Pixel
   @ 090,070 MsGet cTransp                      SIZE 040,010  VALID ExistCpo("SA4",cTransp) F3 "SA4" 	OF FASPedB	Pixel
   @ 102,010 Say "Tipo Frete:"					              OF FASPedB Pixel
   @ 102,070 COMBOBOX oCombo VAR cTpFrete       ITEMS { "C=CIF","F=FOB"} SIZE 40,7 OF FASPedB PIXEL
   @ 114,010 Say "Flag Separacao:"	 			              OF FASPedB Pixel
   @ 114,070 COMBOBOX oCombo VAR cJpcSep        ITEMS { "T=Total","P=Parcial","N=Nao Separado"} SIZE 80,7 OF FASPedB PIXEL
   @ 126,010 Say "Msg. Nota"					              OF FASPedB Pixel
   @ 126,070 GET oMemo1 VAR cObsNota MEMO SIZE 150,115 PIXEL  OF FASPedB

   @ 045,160  BUTTON "Gravar"   Size 50,12 ACTION BGrava()		                OF FASPedB Pixel
   @ 060,160  BUTTON "Abandona" Size 50,12 ACTION ( FasPedb:End() )             OF FASPedB Pixel
   @ 075,160  BUTTON "Etiqueta" Size 50,12 ACTION U_AUTOMR13(cPedidoB, cVolume) OF FASPedB Pixel

   ACTIVATE DIALOG FasPedb CENTER

Return

// Função que grava dos dados da tela de embalagem
Static Function BGrava()
    
	local _cJPCSEP := SC5->C5_JPCSEP

	DbSelectArea("SC5")
	
	RecLock("SC5",.f.)
	C5_PBRUTO  := nPbruto
	C5_PESOL   := nPliq
	C5_ESPECI1 := cEspecie
	C5_VOLUME1 := cVolume
	C5_TRANSP  := cTransp
	C5_TPFRETE := cTpFrete
	C5_MENNOTA := cObsNota
	C5_JPCSEP  := IIF(cJpcSep == "N"," ",cJpcSep)
	MsUnlock()
	
	// Jean Rehermann - Solutio IT - 25/07/2012 | Criado log para alteração do C5_JPCSEP
	If cJpcSep != _cJPCSEP // Se foi alterado

		xGravaLogSep("M", "", _cJPCSEP, cJpcSep)

	EndIf
	
	// Jean Rehermann - Se cancela a separação volta o status para 08-Aguardando Separação (verificando se item já não foi faturado)
	If cJpcSep == "N"
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek( SC5->C5_FILIAL + SC5->C5_NUM )
			While !Eof() .And. SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
				/*
				If !( SC6->C6_STATUS $ "08,11,12,13,14" ) .And. !U_Servico()
					RecLock("SC6",.F.)
						SC6->C6_STATUS := "08" // Ag. Sep. Estoque
						U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "08", "JPCACD01 (FGrava)" ) // Gravo o log de atualização de status na tabela ZZ0
					MsUnLock()
				EndIf
				*/
				// Jean Rehermann - 26/11/2012 - Alterado avaliar apenas os itens que já estão na loista de faturamento
				If SC6->C6_STATUS == "10" .And. !U_Servico()
					U_GravaSts("JPCACD01 (FGrava)")
				EndIf
				
				SC6->( dbSkip() )
			End
		EndIf
	EndIf

	DbSelectArea("SC5")
	
	FasPedb:End()

Return

// ######################################################################################################################### 
// Jean Rehermann - Solutio IT - 25/07/2012 | Gravação de Log da separação                                                ##
// Parâmetro 1: cTipo  => S - Separação | M - Alteração Manual do C5_JPCSEP | A - Alteração automatica do campo C5_JPCSEP ##
// Parâmetro 2: cTpCod => S - Seriado | P - Não Seriado (apenas código de produto)                                        ##
// Parâmetro 3: cSepA  => Conteudo atual do C5_JPCSEP (P,T ou Branco)                                                     ##
// Parâmetro 4: cSepN  => Conteudo a ser gravado no C5_JPCSEP (P,T ou Branco)                                             ##
// #########################################################################################################################
Static Function xGravaLogSep(cTipo, cTpCod, cSepA, cSepN)
	
	dbSelectArea("ZZQ")
	RecLock( "ZZQ", .T. )
		ZZQ->ZZQ_FILIAL := xFilial("ZZQ")
		ZZQ->ZZQ_TPLOG  := cTipo
		ZZQ->ZZQ_DATA   := dDataBase
		ZZQ->ZZQ_HORA   := Time()
		ZZQ->ZZQ_USER   := RetCodUsr()
		ZZQ->ZZQ_PROD   := Iif( cTipo == "S", SC6->C6_PRODUTO, Space(30) )
		ZZQ->ZZQ_TPCOD  := Iif( cTipo == "S", cTpCod, Space(1) )
		ZZQ->ZZQ_PEDIDO := SC5->C5_NUM
		ZZQ->ZZQ_ITEMPV := Iif( cTipo == "S", SC6->C6_ITEM, Space(2) )
		ZZQ->ZZQ_QTDSEP := Iif( cTipo == "S", Iif( cTpCod == "S", SBF->BF_QUANT, 1 ), 0 )
		ZZQ->ZZQ_SEPANT := cSepA
		ZZQ->ZZQ_JPCSEP := cSepN
		ZZQ->ZZQ_NUMSER := Iif( cTpCod == "S", SDC->DC_NUMSERI, "" )
		ZZQ->ZZQ_QATU   := Iif( cTipo == "S", SB2->B2_QATU   , 0 )
		ZZQ->ZZQ_QEMP   := Iif( cTipo == "S", SB2->B2_QEMP   , 0 )
		ZZQ->ZZQ_QEMPN  := Iif( cTipo == "S", SB2->B2_QEMPN  , 0 )
		ZZQ->ZZQ_RESERV := Iif( cTipo == "S", SB2->B2_RESERVA, 0 )
		ZZQ->ZZQ_QPEDVE := Iif( cTipo == "S", SB2->B2_QPEDVEN, 0 )
		ZZQ->ZZQ_SALPED := Iif( cTipo == "S", SB2->B2_SALPEDI, 0 )
		ZZQ->ZZQ_QEMPSA := Iif( cTipo == "S", SB2->B2_QEMPSA , 0 ) 
		ZZQ->ZZQ_QEMPRE := Iif( cTipo == "S", SB2->B2_QEMPPRE, 0 )
		ZZQ->ZZQ_SALPRE := Iif( cTipo == "S", SB2->B2_SALPPRE, 0 )
	MsUnLock()
	
Return
