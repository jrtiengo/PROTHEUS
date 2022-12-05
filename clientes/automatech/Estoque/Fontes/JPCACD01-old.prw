#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ JPCACD01 บAutor  ณ Cesar M.Mussi      บ Data ณ  29/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Conferencia de Separacao                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSerie     ณ Alpha# - Materiais                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function JPCACD01

// Variaveis Locais .. depois passar para parametros

Private _cTitulo  := "Alpha#JPCACD01 - Conferencia de Separacao"
Private _cTipoSep := GetNewPar("JPCACD0100","G")

Private aRotina 	:= {{"","",0,4}}
Private nOca 		:= 0
Private cQuery 		:= ""
Private lClose 		:= .t.
Private lRefresh	:= .t.
Private aHeader 	:= {}
Private aAlter  	:= {}
Private _aArqC1 	:= {}
Private oGetDb1
Private oGetDb2

Private _cTipo  	:= "1"    // por pedido de Venda
Private nOcb 		:= 1
Private oCodBarr
Private cCodBarr 	:= Space(15)

Private aHeade2 := {}
Private aAlter2 := {}
Private _aArqC2 := {}

Private aLstBox := {}
Private oLbx

Private cDescProd := ""
Private cCodProd  := ""

Private oCodLote
Private cCodLote := Space(20)

Private _nQCodP := 0	// JPC Gerson - 16.06.11

If SC5->(FieldPos("C5_JPCSEP")) == 0
	MsgStop("Falta criar o campo C5_JPCSEP C 1 !")
Else
	Do While .t.
		
		IF GeraArq()	// Gera Arquivo Temporario
			
			//=============================================================
			
			DEFINE MSDIALOG oDlgBrw TITLE _cTitulo From 140,0 To 645,1078 OF oMainWnd PIXEL Style DS_MODALFRAME
			oGetDb1 := MsGetDB():New(10,10,230,520,1,"U_SEPTDOK","U_SEPTDOK","",.F., aAlter, ,.T., ,"SEPARA",Nil,Nil,Nil,oDlgBrw)
			// MsGetDb():New( nSuperior, nEsquerda, nInferior, nDireita,
			//     nOpc, [ cLinhaOk ], [ cTudoOk ], [ cIniCpos ], [ lApagar ], [ aAlter ],
			// [ nCongelar ], [ lVazio ], [ uPar1 ], cTRB, [ cCampoOk ], [ lCondicional ], [ lAdicionar ], [ oWnd ], [ lDisparos ], [ uPar2 ], [ cApagarOk ], [ cSuperApagar ] ) -> objeto
			DEFINE SBUTTON FROM 237,040 TYPE 06 ACTION (nOca:=2,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
			@247,040 Say OemtoAnsi("Lista Sep.") SIZE 40,10 OF oDlgBrw PIXEL
			DEFINE SBUTTON FROM 237,070 TYPE 11 ACTION (nOca:=3,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
			@247,070 Say OemtoAnsi("Leitura")    SIZE 40,10 OF oDlgBrw PIXEL
			DEFINE SBUTTON FROM 237,100 TYPE 15 ACTION (U_PsqaLst()) Of oDlgBrw PIXEL ENABLE
			@247,100 Say OemtoAnsi("Pesquisa")    SIZE 40,10 OF oDlgBrw PIXEL
			DEFINE SBUTTON FROM 237,130 TYPE 05 ACTION (U_Embala()) Of oDlgBrw PIXEL ENABLE
			@247,130 Say OemtoAnsi("Embalagem")    SIZE 40,10 OF oDlgBrw PIXEL
			//DEFINE SBUTTON FROM 237,160 TYPE 06 ACTION (U_VerPv()) Of oDlgBrw PIXEL ENABLE
			//@247,160 Say OemtoAnsi("Ver PV")    SIZE 40,10 OF oDlgBrw PIXEL
			DEFINE SBUTTON FROM 237,378 TYPE 02 ACTION (nOca:=0,oDlgBrw:End()) OF oDlgBrw PIXEL ENABLE
			@247,378 Say OemtoAnsi("Saida")    SIZE 40,10 OF oDlgBrw PIXEL
			
			ACTIVATE MSDIALOG oDlgBrw Valid lClose
			
			If nOca == 0
				// ok
				DbSelectArea("SEPARA")
				DbCloseArea()
				Exit
			ElseIf nOca == 2
				// Imprime Lista Separacao
				If _cTipoSep == "G"   // Grafica
					U_JPCSEPGRF()
				Else //Matricial
					U_JPCSEPMAT()
				Endif
				
			ElseIf nOca == 3
				// Conferencia
				IF U_MtaConf()
					aHeadBkp := aClone(aHeader)
					aHeader  := aClone(aHeade2)
					
					DEFINE MSDIALOG oDlgConf TITLE _cTitulo From 100,0 To 650,1200 OF oMainWnd PIXEL Style DS_MODALFRAME
					@ 003,010 SAY OemToAnsi("Lote/Ender./No.Serie ") SIZE 100,008 OF oDlgConf PIXEL
					//@ 003,060 MSGET oCodBarr VAR cCodBarr PICTURE "@X" VALID(U_VldCdBr(cCodBarr)) SIZE 060,008 OF oDlgConf PIXEL
					@ 003,080 MSGET oCodLote VAR cCodLote PICTURE "@X" VALID(U_VldLote(cCodLote)) SIZE 060,008 OF oDlgConf PIXEL
					@ 003,210 SAY OemToAnsi("Cod.Barras ") SIZE 060,008 OF oDlgConf PIXEL
					@ 003,260 SAY cDescProd SIZE 300,10 OF oDlgConf PIXEL
					oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
					@ 020,120 LISTBOX oLbx FIELDS HEADER "Item", "Cod.Produto", "Descricao", "Qtd.PV", "Separado", ;
					"Diferenca","Lote/Sublote", "Num.Serie", "Local", "." SIZE 460,240 OF oDlgConf PIXEL
					
					oLbx:SetArray( aLstBox )
					oLbx:bLine := {|| {aLstBox[oLbx:nAt,1],;
					aLstBox[oLbx:nAt,2],;
					aLstBox[oLbx:nAt,3],;
					aLstBox[oLbx:nAt,4],;
					aLstBox[oLbx:nAt,5],;
					aLstBox[oLbx:nAt,6],;
					aLstBox[oLbx:nAt,7],;
					aLstBox[oLbx:nAt,8],;
					aLstBox[oLbx:nAt,9],;
					aLstBox[oLbx:nAt,10]}}
					
					DEFINE SBUTTON FROM 265,040 TYPE 01 ACTION (nOcb := 2 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE
					DEFINE SBUTTON FROM 265,070 TYPE 02 ACTION (nOcb := 0 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE
					ACTIVATE MSDIALOG oDlgConf Valid lClose CENTER
					
					If nOcb == 2
						DbSelectArea("CONF")
						DbGoTop()
						_cTipoC5 := "T"
						_cTipoCod:= "U"
						
						Do While !Eof()
							
							//Procuro o produto para ver se tem controle de Localizacao
							_cTipoCod:= IIF(Localiza(CONF->B1_COD),"S","P")
							
							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+CONF->B1_COD)
							
							IF EOF()
								ALERT("SB1 - Entre em contato com o Administrador ! Problema: Produto "+Alltrim(CONF->B1_COD)+" na rotina JPCACD01")
								Exit
							ENDIF
							_n := ASCAN(aLstBox, {|aVal| Alltrim(aVal[2]) == Alltrim(CONF->B1_COD)})
							
							IF _n <= 0
								ALERT("aLstBox - Entre em contato com o Administrador ! Problema: Produto "+Alltrim(CONF->B1_COD)+" na rotina JPCACD01")
								Exit
							ENDIF
							
							IF aLstBox[_n, 5] > 0
								// Grava SDC
								IF _cTipoCod=="S"

									DbSelectArea("SBF")
									DbSetOrder(4)   //BF_FILIAL+BF_PRODUTO+BF_NUMSERI
									DbSeek(xFilial("SBF")+CONF->B1_COD+CONF->B1_CODBAR)
									
									IF EOF()
										ALERT("SBF - Entre em contato com o Administrador ! Problema: Produto "+Alltrim(CONF->B1_COD)+" na rotina JPCACD01")
										Exit
									ENDIF

									DbSelectArea("SDC")
									RecLock("SDC",.t.)
									DC_FILIAL	:= xFilial("SDC")
									DC_ORIGEM	:= "SC6"
									DC_PRODUTO	:= SB1->B1_COD
									DC_LOCAL	:= SBF->BF_LOCAL
									DC_LOCALIZ	:= SBF->BF_LOCALIZ
									DC_NUMSERI	:= CONF->B1_CODBAR
									DC_LOTECTL	:= SBF->BF_LOTECTL
									DC_NUMLOTE	:= SBF->BF_NUMLOTE
									DC_QUANT	:= SBF->BF_QUANT
									DC_TRT		:= "01"
									DC_PEDIDO	:= SEPARA->C5_NUM
									DC_ITEM		:= aLstBox[_n,1]
									DC_QTDORIG	:= aLstBox[_n,4]
									DC_SEQ      := "01"
									MsUnlock()
									
									DbSelectArea("SBF")
									// Atualizar SBF
									Reclock("SBF",.f.)
									BF_EMPENHO := 1
									MsUnlock()

								ENDIF
								
								DbSelectArea("SB2")
								// Atualizar SB2
								DbSetorder(1)
								DbSeek(xFilial("SB2")+SB1->B1_COD+IIF(_cTipoCod=="P",SB1->B1_LOCPAD,SBF->BF_LOCAL))    //B2_FILIAL+B2_COD+B2_LOCAL

								IF EOF()
									ALERT("SB2 - Entre em contato com o Administrador ! Problema: Produto "+Alltrim(CONF->B1_COD)+" na rotina JPCACD01")
									Exit
								ENDIF
								
								Reclock("SB2",.F.)
								B2_RESERVA := B2_RESERVA + 1
								B2_QPEDVEN := B2_QPEDVEN - 1
								MsUnlock()
								
								DbSelectArea("SC9")
								// Atualizar SC9
								DbSetOrder(2) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
								DbSeek(xFilial("SC9")+SEPARA->C5_CLIENTE+SEPARA->C5_LOJACLI+SEPARA->C5_NUM+aLstBox[_n,1])
								IF EOF()
									ALERT("SC9 - Entre em contato com o Administrador ! Problema: Produto "+Alltrim(CONF->B1_COD)+" na rotina JPCACD01")
									Exit
								ENDIF
								Reclock("SC9",.f.)
								C9_BLEST := "  "
								C9_BLWMS := "  "
								MsUnlock()         
							Else
								_cTipoC5 := "P"
							Endif
							
							DbSelectArea("CONF")
							DbSkip()
							
						Enddo
						
						// Atualizar SC5
						// Verifica o SC9
						DbSelectArea("SC9")
						DbSetOrder(2) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
						DbSeek(xFilial("SC9")+SEPARA->C5_CLIENTE+SEPARA->C5_LOJACLI+SEPARA->C5_NUM)
						_cChave := C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO
						Do While !eof() .and. _cChave == SC9->C9_FILIAL+SC9->C9_CLIENTE+SC9->C9_LOJA+SC9->C9_PEDIDO
							IF 	SC9->C9_BLEST <> "  " .OR. SC9->C9_BLWMS <> "  "
								IF ALLTRIM(SC9->C9_AGREG) == ""
								   _cTipoC5 := "P"
								   Exit
								ElseIf ALLTRIM(SC9->C9_AGREG) == "SRV"
								   Reclock("SC9",.f.)
								   C9_BLEST := ""
								   C9_BLWMS := ""
								   MsUnlock()
								Endif
							ENDIF
							DbSelectArea("SC9")
							DbSkip()
						Enddo
						DbSelectArea("SC5")
						DbSetorder(1)
						DbSeek(xFilial("SC5")+SEPARA->C5_NUM)
						Reclock("SC5",.f.)
						C5_JPCSEP := _cTipoC5
						MsUnlock()
						
					Endif
					
				Else
					MsgBox("Verifique C9_BLEST")
				Endif
				
				DbSelectArea("CONF")
				DbCloseArea()
				aHeader  := aClone(aHeadBkp)
				
			Endif
			
			DbSelectArea("SEPARA")
			DbCloseArea()
			
		Else
			Exit
		Endif
		
	Enddo
Endif


Return

User Function PsqaLst
Local oPed
Local cPed := Space(6)
Local nPed := 0
DEFINE MSDIALOG oDlgPesq TITLE "Pesquisa" From 100,0 To 150,250 OF oMainWnd PIXEL Style DS_MODALFRAME
@ 003,010 SAY OemToAnsi("Pedido ") SIZE 030,008 OF oDlgPesq PIXEL
@ 003,070 MSGET oPed VAR cPed PICTURE "@X" SIZE 060,010 OF oDlgPesq PIXEL

DEFINE SBUTTON FROM 265,010 TYPE 01 ACTION (nPed := 2 , oDlgPesq:End())	OF oDlgPesq PIXEL ENABLE
DEFINE SBUTTON FROM 265,040 TYPE 02 ACTION (nPed := 0 , oDlgPesq:End())	OF oDlgPesq PIXEL ENABLE
ACTIVATE MSDIALOG oDlgPesq Valid lClose CENTER

IF nPed == 2
   DbSelectArea("SEPARA")
   DbSetOrder(1)
   DbSeek(cPed)
   oGetDb1:ForceRefresh()
ENDIF

RETURN(.T.)

User Function VerPV()
Local cPedVen := SEPARA->C5_NUM
Local _aArea  := GetArea()
Local aCores   := {}
Local cRoda    := ""
Local bRoda    := {|| .T.}
Local xRet     := Nil
Local nPos	   := 0

PRIVATE lOnUpdate  := .T.	
PRIVATE l410Auto   := .f.
PRIVATE aRotina    := {}
aAdd(aRotina,{ "Visualizar"  , "A410Visual"                    	, 0, 2})

	
PRIVATE cCadastro := OemToAnsi("Atualizao de Pedidos de Venda")

DbSelectArea("SC5")
DbSeek(xFilial("SC5")+SEPARA->C5_NUM)
A410Visual()

RestArea(_aArea)
Return

User Function Embala()
Private cPedVen := Space(6)
Private oPedVen

DEFINE MSDIALOG FASPedA TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 00,000 TO 100,230 OF oMainWnd Pixel Style DS_MODALFRAME
@ 10,005 Say "Nr.do Pedido de Venda:"   OF FASPedA Pixel
@ 10,070 MsGet oPedVen Var cPedVen F3 "SC5" PICTURE "@X" SIZE 040,010 OF FASPedA VALID ExistCpo("SC5",cPedVen) .and. ;
		 empty(Posicione("SC5",1,xFilial("SC5")+cPedVen,"C5_NOTA"))  Pixel
DEFINE SBUTTON FROM 30,005 TYPE 01 ACTION (FConfirma())	    OF FasPedA ENABLE Pixel
DEFINE SBUTTON FROM 30,060 TYPE 02 ACTION (Close(FasPedA))	OF FasPedA ENABLE Pixel
ACTIVATE DIALOG FasPedA CENTER
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FCONFIRMAบAutor  ณ Cesar Mussi        บ Data ณ  20/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FConfirma()

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

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek( xFilial("SC5") + cPedVen)
dEmissao 	:= SC5->C5_EMISSAO
nPbruto 	:= SC5->C5_PBRUTO
nPliq   	:= SC5->C5_PESOL 
cEspecie	:= SC5->C5_ESPECI1
cVolume 	:= SC5->C5_VOLUME1
cTransp 	:= SC5->C5_TRANSP
cCliente	:= SC5->C5_CLIENTE+SC5->C5_LOJACLI
nValNot 	:= 0 //SC5->C5_VALBRUT
cTpFrete    := SC5->C5_TPFRETE
//cObsNota    := SC5->C5_OBSNT
cObsNota    := SC5->C5_MENNOTA
cJpcSep     := IIF(EMPTY(SC5->C5_JPCSEP),"N",SC5->C5_JPCSEP)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + cCliente)

If !EOF()
	cCliente 	:= cCliente+" - "+SA1->A1_Nome
	cCGC 		:= SA1->A1_CGC
	cIE 		:= SA1->A1_INSCR
Endif
DbSelectArea("SC5")
DEFINE MSDIALOG FASPedB TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 000,000 TO 600,650 OF oMainWnd Pixel Style DS_MODALFRAME
@ 010,010 Say "Nr.do Ped.Venda :" 			OF FASPedB	Pixel
@ 010,070 say cPedVen						OF FASPedB	Pixel
@ 010,095 SAY 'em '							OF FASPedB	Pixel
@ 010,104 SAY dEmissao Picture '99/99/99' 	OF FASPedB	Pixel
@ 017,010 Say "Cliente :"					OF FASPedB	Pixel
@ 017,070 Say cCliente						OF FASPedB	Pixel
@ 024,010 say "CGC-MF/IE : "				OF FASPedB	Pixel
@ 024,070 say cCGC+" / "+cIE				OF FASPedB	Pixel
//@ 31,010 say "Valor da Nota : "+TRANSFORM(nValNot,"@e R$9,999,999.99")
@ 042,010 Say "Peso Br: "					OF FASPedB	Pixel
@ 042,070 MsGet nPbruto picture "@E 99999.99" SIZE 040,010 OF FASPedB	Pixel
@ 054,010 Say "Peso Lq: "		   			OF FASPedB	Pixel
@ 054,070 MsGet nPliq picture "@E 99999.99"	SIZE 040,010 OF FASPedB	Pixel
@ 066,010 Say "Especie: "					OF FASPedB	Pixel
@ 066,070 MsGet cEspecie					SIZE 040,010 OF FASPedB	Pixel
@ 078,010 Say "Volume.: "					OF FASPedB	Pixel
@ 078,070 MsGet cVolume Picture "999999"		SIZE 040,010 OF FASPedB	Pixel
@ 090,010 Say "Transpor.: "					OF FASPedB	Pixel
@ 090,070 MsGet cTransp SIZE 040,010 VALID ExistCpo("SA4",cTransp) F3 "SA4" 	OF FASPedB	Pixel
@ 102,010 Say "Tipo Frete:"					OF FASPedB	Pixel
@ 102,070 COMBOBOX oCombo VAR cTpFrete ITEMS { "C=CIF","F=FOB"} SIZE 40,7 OF FASPedB PIXEL
@ 114,010 Say "Flag Separacao:"	 			OF FASPedB	Pixel
@ 114,070 COMBOBOX oCombo VAR cJpcSep ITEMS { "T=Total","P=Parcial","N=Nao Separado"} SIZE 80,7 OF FASPedB PIXEL

//@ 126,010 Say "Obs.DANFE"					OF FASPedB	Pixel
//@ 126,070 GET oMemo VAR cObsNota MEMO SIZE 205,100 PIXEL OF FASPedB VALID oMemo:Refresh()
@ 126,010 Say "Msg. Nota"					OF FASPedB	Pixel
@ 126,070 MsGet cObsNota Picture "@S60"		SIZE 120,010 OF FASPedB	Pixel

@ 045,160  BUTTON "Gravar"   Size 50,12 ACTION FGrava()		OF FASPedB	Pixel
@ 060,160  BUTTON "Abandona" Size 50,12 ACTION close(FasPedb)	OF FASPedB	Pixel
ACTIVATE DIALOG FasPedb CENTER
Return

Static Function FGrava()
DbSelectArea("SC5")
RecLock("SC5",.f.)
C5_PBRUTO  := nPbruto
C5_PESOL   := nPliq
C5_ESPECI1 := cEspecie
C5_VOLUME1 := cVolume
C5_TRANSP  := cTransp
C5_TPFRETE := cTpFrete
//C5_OBSNT   := cObsNota
C5_MENNOTA := cObsNota
C5_JPCSEP  := IIF(cJpcSep == "N"," ",cJpcSep)
MsUnlock()
DbSelectArea("SC5")
Close( FasPedb)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VLDLOTE  บAutor  ณMicrosiga           บ Data ณ  04/16/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function VldLote(p1)


// Valida a digitacao de cada etiqueta do pacote
Local cMsg := "Problema no Codigo Lote/SLote/NSerie : '"+cCodLote+"'"+chr(13)+chr(10)
Private lRetorno  := .t.
Private _cTipoCod := "U"  //Undeffined

cMsg += "---------------------------------------"+chr(13)+chr(10)

If ! Empty(cCodLote)
	// Obrigo o Posicionamento do aLstBox
	_nPosAlst := oLbx:nAt
	_cCodProd := aLstBox[_nPosAlst,2]
	
	//Procuro o produto para ver se tem controle de Localizacao
	_cTipoCod:= IIF(Localiza(_cCodProd),"S","P")
						
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+aLstBox[_nPosAlst,2])

	IF _cTipoCod == "S"
	   // Numero de serie
		DbSelectArea("SBF")
		DbSetOrder(4)   //BF_FILIAL+BF_PRODUTO+BF_NUMSERI
		DbSeek(xFilial("SBF")+_cCodProd+cCodLote)
		IF eof()
			//ops.... nao eh codigo de numero de serie
			lRetorno := .f.
			Alert("Produto "+_cCodProd+" com Controle de Enderecamento, mas Numero de Serie lido nใo ้ desse produto !")
		Else
			lRetorno := .t.
		Endif
	
	ElseIf _cTipoCod == "P"
        // Codigo de barras normal
		DbSelectArea("SB1")
		DbSetOrder(5)		// B1_FILIAL, B1_CODBAR
		DbSeek(xFilial("SB1")+cCodLote)
		IF eof()
			//ops.. nem codigo de barras de produto eh
			ALERT("Codigo Invalido, nao identificado como numero de serie, nem como Codigo de barras do produto "+_cCodProd)
			lRetorno := .f.
		Else
			lRetorno := .t.
		ENDIF
	Endif   

	//Verifica se o Codigo ja nao foi "bipado"
	IF lRetorno .and. _cTipoCod == "S"  //numero de serie
		DbSelectArea("CONF")
		DbGoTop()
		Do While !eof()
			IF Alltrim(CONF->B1_CODBAR) == Alltrim(cCodLote)
				lRetorno := .f.
			Endif
			DbSelectArea("CONF")
			DbSkip()
		Enddo
	Endif
	
	DbSelectArea("CONF")
	DbGoTop()
	
	IF lRetorno
		IF _cTipoCod == "S"  //numero de serie
			
			// Valida o codigo de barras do NUMERO DE SERIE e o produto e abate da pendencia
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+SBF->BF_PRODUTO)
			
			DbSelectArea("SBF")
			IF FOUND()
				IF (SBF->BF_QUANT - SBF->BF_EMPENHO) <= 0
					lRetorno := .f.
					cMsg += "Lote "+cCodLote+" sem Saldo Disponivel "+chr(13)+chr(10)
				ELSE
					cDescProd := SB1->B1_COD + " : " + SB1->B1_DESC
					cCodProd  := SBF->BF_PRODUTO
				ENDIF
			Else
				lRetorno := .f.
				cMsg += "Lote "+cCodLote+" nao Disponivel "+chr(13)+chr(10)
			ENDIF
		Else
			// Valida o Codigo de barras do PRODUTO e abate da pendencia
			DbSelectArea("SB2")
			DbSetorder(1)
			DbSeek(xFilial("SB2")+SB1->B1_COD)
			IF FOUND()
				IF (SB2->B2_QATU - SB2->B2_QEMP) <= 0
					lRetorno := .f.
					cMsg += "Produto "+cCodLote+" sem Saldo Disponivel "+chr(13)+chr(10)
				ELSE
					cDescProd := SB1->B1_COD + " : " + SB1->B1_DESC
					cCodProd  := SB1->B1_COD
				ENDIF
			Else
				lRetorno := .f.
				cMsg += "Produto "+cCodLote+" nao Disponivel "+chr(13)+chr(10)
			ENDIF
			
		ENDIF
		If lRetorno
			lRet2 := U_GETLBOX("ACONF")
			IF !lRet2
				cMsg += "O produto "+ALLTRIM(SB1->B1_DESC)+chr(13)+chr(10)
				cMsg += "ja tem a quantidade completa separada !"+chr(13)+chr(10)
				cMsg += "---------------------------------------"+chr(13)+chr(10)
			Else
				DbSelectArea("CONF")
				_nQCodP   := 0
				IF _cTipoCod == "P"
					_nQCodP := JPCGQTD()
				Endif
				_XFor := iif(_nQCodP>0,_nQCodP,1) // Gerson - _nQCodP alimentado em GetlBox(p1)p/produtos _cTipoCod == "P"
				For _nX := 1 to _XFor
					Reclock("CONF",.t.)
					CONF->B1_CODBAR := cCodLote
					CONF->B1_COD    := _cCodProd
					CONF->(MsUnlock())
				Next
				DbGoTop()
				oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
				//@ 015,010 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL
				U_GetlBox("ATUAL")	// Atualiza o ListBox
			Endif
		Else
			cMsg += ""+chr(13)+chr(10)
			MsgAlert(cMsg,ProcName())
			cMsg := ""
		EndIf
		
	Endif
	
	oGetDb2:ForceRefresh()
	//oLbx:Refresh()
	
	// Caso o produto possua RASTRO, exige a leitura do Lote/Sublote
	oCodLote:Refresh()
	oCodLote:SetFocus()
	
EndIf
DbSelectArea("CONF")
DbGoTop()
oGetDb2:oBrowse:Refresh()

cCodLote := Space(20)
oLbx:Refresh()

DbSelectArea("CONF")

Return(lRetorno)


User Function VldCdBr(p1)

// Valida a digitacao de cada etiqueta do pacote
Local cMsg := "Problema no Codigo de Barras : '"+cCodBarr+"'"+chr(13)+chr(10)
//MsgAlert(cCodBarr,ProcName())
Private lRetorno := .t.

cMsg += "---------------------------------------"+chr(13)+chr(10)

If ! Empty(cCodBarr)
	
	// Valida o codigo de barras e o produto e abate da pendencia
	
	DbSelectArea("SB1")
	DbSetOrder(5)   //B1_FILIAL+B1_CODBAR
	DbSeek(xFilial("SB1")+cCodBarr)
	IF FOUND()
		cDescProd := SB1->B1_COD + " : " + SB1->B1_DESC
		cCodProd  := SB1->B1_COD
	ENDIF
	
	// Testa se ja conferi toda a quantidade disponivel
	lRetorno := U_GETLBOX("ACONF")
	IF !lRetorno
		cMsg += "O produto "+ALLTRIM(SB1->B1_DESC)+chr(13)+chr(10)
		cMsg += "ja tem a quantidade completa separada !"+chr(13)+chr(10)
		cMsg += "---------------------------------------"+chr(13)+chr(10)
	Endif
	
	If lRetorno
		DbSelectArea("CONF")
		Reclock("CONF",.t.)
		CONF->B1_CODBAR := cCodBarr
		CONF->(MsUnlock())
		
		oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
		//@ 015,010 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL
		
		U_GetlBox("ATUAL")	// Atualiza o ListBox
		
	Else
		cMsg += ""+chr(13)+chr(10)
		MsgAlert(cMsg,ProcName())
		cMsg := ""
	EndIf
	
	
	oGetDb2:ForceRefresh()
	oLbx:Refresh()
	
	// Caso o produto possua RASTRO, exige a leitura do Lote/Sublote
	IF SB1->B1_RASTRO $ "L|S" .OR. SB1->B1_LOCALIZ == "S"
		oCodLote:Refresh()
		oCodLote:SetFocus()
	ELSE
		oCodBarr:Refresh()
		oCodBarr:SetFocus()
	ENDIF
	
EndIf

DbSelectArea("CONF")

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GETLBOX  บAutor  ณ Cesar Mussi        บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Centraliza o tratamento do array aLstBox                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GetlBox(p1)
Local lRet := .t.
Local _nQtd := 0	// JPC Gerson - 16.06.11

For _n := 1 to Len(aLstBox)
	
	IF p1 == "ATUAL"   // Atualiza o ListBox
		
		IF ALLTRIM(aLstBox[_n, 2]) == ALLTRIM(cCodProd)
			//lNewArray := .f.
			//IF SB1->B1_RASTRO $ "L|S"
			lNewArray :=  !(((empty(aLstBox[_n, 7])) .or. (ALLTRIM(aLstBox[_n, 7]) == cCodLote)))
			//                     .t.                              .t.   .t.   .f.
			//                     .f.                              .t.   .t.   .f.
			//                     .t.                              .f.   .t.   .f.
			//                     .f.                              .f.   .f.   .t.
			//            a posicao do array tem que estar vazia ou o array tem que ter o mesmo valor - ser o mesmo lote
			//ELSEIF SB1->B1_LOCALIZ == "S"
			//	lNewArray := !( empty(aLstBox[_n, 8]) )
			//ENDIF
			
			//If lNewArray
			//	aAdd(aLstBox,{aLstBox[_n, 1] , aLstBox[_n, 2] , aLstBox[_n, 3], aLstBox[_n, 4] , 1 , ;
			//	0 , IIF(SB1->B1_RASTRO $ "L|S",cCodLote,""),;
			//	IIF(SB1->B1_LOCALIZ == "S",cCodLote,""), "" })
			//Else

			// JPC Gerson - 16.06.11
			IF _cTipoCod == "P"
				_nQtd := iif(_nQCodP>0,_nQCodP,1)
			Else
			    _nQtd := 1
			Endif
			IF _nQtd >= 1  
				lRet := .t.
				aLstBox[_n, 5]+= _nQtd
				aLstBox[_n, 6]-= _nQtd
				
			Else
				lRet := .f.
			Endif
			
			//IF SB1->B1_RASTRO $ "L|S"
			//	aLstBox[_n, 7] := cCodLote
			//ELSEIF SB1->B1_LOCALIZ == "S"
			//	aLstBox[_n, 8] := cCodLote
			//ENDIF
			
			//Endif
			
		ENDIF
	ELSEIF p1 == "ACONF"    // Retorna se tem saldo a Conferir
		IF ALLTRIM(aLstBox[_n, 2]) == ALLTRIM(cCodProd)
			IF aLstBox[_n, 6] > 0
				lRet := .t.
			Else
				lRet := .f.
			Endif
		ENDIF
	ENDIF
	
Next _n

Return(lRet)

User Function CFTDOK

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJPCSEPGRF บAutor  ณ CESAR MUSSI        บ Data ณ  31/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function JPCSEPGRF

LOCAL oFont8 , oFont9 , oFont10 , oFont11 , oFont12 , oFont14 , oFont16 , oFont24, oBrush, nCnt
LOCAL oFont8N, oFont9N, oFont10N, oFont11N, oFont12N, oFont14N, oFont16n, oFont26
LOCAL cTitl, cCart, cFato, nValr, cValr, cNBco, cDBco, cCont, cBole, cNNum
LOCAL cDNum, cNoss, cBarr, cDBar , cLinh, cAgen, cDcAg, cNmCC, cDcNc
LOCAL cSql
//Parโmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)

oFont8  := TFont():New("Arial", 9, 08, .F., .F., 5, .T., 5, .T., .F.)
oFont8N := TFont():New("Arial", 9, 08, .T., .T., 5, .T., 5, .T., .F.)
oFont09 := TFont():New("Arial", 9, 09, .F., .F., 5, .T., 5, .T., .F.)
oFont09N:= TFont():New("Arial", 9, 09, .T., .T., 5, .T., 5, .T., .F.)
oFont10 := TFont():New("Arial", 9, 10, .F., .F., 5, .T., 5, .T., .F.)
oFont10N:= TFont():New("Arial", 9, 10, .T., .T., 5, .T., 5, .T., .F.)
oFont11 := TFont():New("Arial", 9, 11, .F., .F., 5, .T., 5, .T., .F.)
oFont11N:= TFont():New("Arial", 9, 11, .T., .T., 5, .T., 5, .T., .F.)
oFont12 := TFont():New("Arial", 9, 12, .F., .F., 5, .T., 5, .T., .F.)
oFont12N:= TFont():New("Arial", 9, 12, .T., .T., 5, .T., 5, .T., .F.)
oFont14 := TFont():New("Arial", 9, 14, .T., .F., 5, .T., 5, .T., .F.)
oFont14n:= TFont():New("Arial", 9, 14, .T., .T., 5, .T., 5, .T., .F.)
oFont16 := TFont():New("Arial", 9, 16, .T., .F., 5, .T., 5, .T., .F.)
oFont16n:= TFont():New("Arial", 9, 16, .T., .T., 5, .T., 5, .T., .F.)
oFont24 := TFont():New("Arial", 9, 24, .T., .F., 5, .T., 2, .T., .F.)
oFont26 := TFont():New("Arial", 9, 26, .T., .F., 5, .T., 2, .T., .F.)

oBrush  := TBrush():New("", 4)
oBrush1 := TBrush():New("", 1)
oBrush2 := TBrush():New("", 2)
oBrush3 := TBrush():New("", 3)
oBrush5 := TBrush():New("", 5)
oBrush6 := TBrush():New("", 6)
oBrush8 := TBrush():New("", 8)
oBrush9 := TBrush():New("", 9)


oPrint:=TMSPrinter():New( "Lista de Separacao" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:Setup()
oPrint:StartPage()   // Inicia uma nova pแgina

oPrint:Box  (0050, 0200, 3140, 2400)    	// Box da borda da pแgina
oPrint:Line (0240, 0200, 0240, 2400)        // Linha do Topo
oPrint:Line (0320, 0200, 0320, 2400)        // Linha do Topo
oPrint:Line (0240, 2200, 3140, 2200)    	// Linha Coluna 3
oPrint:Line (0240, 2000, 3140, 2000)    	// Linha Coluna 2
oPrint:Line (0240, 1800, 3140, 1800)    	// Linha Coluna 1
//oPrint:Line (0490, 0100, 0490, 0630)
//oPrint:Line (0050, 0630, 0740, 0630)
//oPrint:Line (0050, 1800, 0740, 1800)

//oPrint:SayBitmap (0052, 0205, "LogoJPC.bmp", 0240, 0180)  //logo da Empresa

oPrint:Say  (0090, 0800, " Lista de Separa็ใo - PV "+SEPARA->C5_NUM , oFont24)
oPrint:Say  (0170, 0820, ALLTRIM(SEPARA->A1_NREDUZ), oFont12)

oPrint:Say  (0260, 0800, " Item + Produto    ", oFont12N )
oPrint:Say  (0260, 1850, " Quant "            , oFont12N )
oPrint:Say  (0260, 2050, " Lote " 			  , oFont12N )
oPrint:Say  (0260, 2200, " Num.Serie "        , oFont12N )

cSql := ""
cSql += " SELECT SC9.*, SB1.B1_CODBAR, SB1.B1_DESC "
cSql += " FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SB1")+" SB1 "
cSql += " WHERE SC9.C9_PEDIDO = '"+SEPARA->C5_NUM+"' AND "
cSql += "       SC9.D_E_L_E_T_ = ' ' AND "
cSql += "       SB1.B1_COD = SC9.C9_PRODUTO AND "
cSql += "       SB1.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY C9_ITEM           "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"PEDSEP", .F., .T.)

DbSelectArea("PEDSEP")
DbGoTop()

_nLin     := 30

Do While ! eof()
	
	_nLin += 60
	
	oPrint:Say  (0260+_nLin, 0220, PEDSEP->C9_ITEM + "-" + PEDSEP->B1_DESC + " - "+PEDSEP->B1_CODBAR , oFont10 )
	
	oPrint:Say  (0260+_nLin, 1960, TRANSFORM(PEDSEP->C9_QTDLIB  ,"@E 999,999.99"    ), oFont10,100,,,1 )
	oPrint:Say  (0260+_nLin, 2050, PEDSEP->C9_LOTECTL , oFont10,100,,,0 )
	oPrint:Say  (0260+_nLin, 2250, PEDSEP->C9_NUMSERI , oFont10,100,,,0 )
	
	DbSelectArea("PEDSEP")
	DbSkip()
	
	IF (260+_nLin+60) > 3140
		oPrint:EndPage()   // Inicia uma nova pแgina
		oPrint:StartPage()   // Inicia uma nova pแgina
		oPrint:Box  (0050, 0200, 3140, 2400)    	// Box da borda da pแgina
		oPrint:Line (0240, 0200, 0240, 2400)        // Linha do Topo
		oPrint:Line (0320, 0200, 0320, 2400)        // Linha do Topo
		oPrint:Line (0240, 2200, 3140, 2200)    	// Linha Coluna 3
		oPrint:Line (0240, 2000, 3140, 2000)    	// Linha Coluna 2
		oPrint:Line (0240, 1800, 3140, 1800)    	// Linha Coluna 1
		//oPrint:Line (0490, 0100, 0490, 0630)
		//oPrint:Line (0050, 0630, 0740, 0630)
		//oPrint:Line (0050, 1800, 0740, 1800)
		
		//oPrint:SayBitmap (0052, 0205, "LogoJPC.bmp", 0240, 0180)  //logo da Empresa
		
		oPrint:Say  (0090, 0800, " Lista de Separa็ใo - PV "+SEPARA->C5_NUM, oFont24)
		oPrint:Say  (0170, 0820, ALLTRIM(SEPARA->A1_NREDUZ), oFont12)
		
		oPrint:Say  (0260, 0800, " Item + Produto    ", oFont12N )
		oPrint:Say  (0260, 1850, " Quant "            , oFont12N )
		oPrint:Say  (0260, 2050, " Lote " 			  , oFont12N )
		oPrint:Say  (0260, 2200, " Num.Serie "        , oFont12N )
		
	Endif
	
Enddo
oPrint:EndPage()   	// Finaliza pแgina
oPrint:Preview()    // Visualiza antes de imprimir

DbSelectArea("PEDSEP")
DbCloseArea()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJPCSEPMAT บAutor  ณ CESAR MUSSI        บ Data ณ  16/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao da Lista de Separacao em Matricial                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function JPCSEPMAT

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Lista de Separacao"
Local titulo         := "Lista de Separacao - PV "+SEPARA->C5_NUM+" / "+SEPARA->A1_NREDUZ
Local nLin           := 80					// Numero maximo de linhas
Local cOrd           := ""					// Ordem selecionada
Local Cabec1         := " Item + Produto                                                                        Quant     Lote            Num.Serie  "
//                        xx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 999999999  xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx
//                        01234567890123456789012345678901234567890123456789012345678901234567890123456789
//                                  1         2         3         4         5         6         7
Local Cabec2         := ""					// Cabecalho 2
Local cPerg          := "JPCACD01"			// Pergunte que eh chamado no relatorio

Private lEnd         := .F.					// Controle do termino do relatorio
Private lAbortPrint  := .F.					// Controle para interrupcao do relatorio
Private limite       := 132					// Limite de colunas (caracteres)
Private tamanho      := "M"					// Tamanho do relatorio
Private nomeprog     := "JPCACD01"			// Nome do programa para impressao no cabecalho
Private nTipo        := 15					// Tipo do relatorio
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0					// Codigo ASCII da ultima tecla pressionada pelo usuario
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "JPCACD01"			// Nome do arquivo usado para impressao em disco

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(	"SC9" , NomeProg, cPerg 	, @titulo, ;
cDesc1, cDesc2  , cDesc3	, .F.    , ;
cOrd  , .T.    	, Tamanho	,, .T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"SC9")

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao do relatorio.                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| MATRICIAL(	Cabec1		, Cabec2, Titulo, nLin ) } ,Titulo)

Return

Static Function MATRICIAL(Cabec1 ,Cabec2 ,Titulo,	nLin)

LOCAL cSql

cSql := ""
cSql += " SELECT SC9.*, SB1.B1_CODBAR, SB1.B1_DESC "
cSql += " FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SB1")+" SB1 "
cSql += " WHERE SC9.C9_PEDIDO = '"+SEPARA->C5_NUM+"' AND "
cSql += "       SC9.D_E_L_E_T_ = ' ' AND "
cSql += "       SB1.B1_COD = SC9.C9_PRODUTO AND "
cSql += "       SB1.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY C9_ITEM           "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"PEDSEP", .F., .T.)

DbSelectArea("PEDSEP")
DbGoTop()

Do While ! eof()
	
	If nLin > 60
		Cabec(	Titulo	, Cabec1	, Cabec2, NomeProg, Tamanho	, nTipo )
		nLin     := 8
	Endif
	
	@nLin,001 PSAY PEDSEP->C9_ITEM + "-" + PEDSEP->B1_DESC + " - "+PEDSEP->B1_CODBAR+" | "+;
	TRANSFORM(PEDSEP->C9_QTDLIB  ,"@E 999,999.99"    )+" | "+;
	PEDSEP->C9_LOTECTL+" | "+PEDSEP->C9_NUMSERI
	
	DbSelectArea("PEDSEP")
	DbSkip()
	
Enddo

DbSelectArea("PEDSEP")
DbCloseArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Descarrega o Cache armazenado na memoria para a impressora.         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

MS_FLUSH()

Return(.t.)


User Function SEPTDOK

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraArq  บAutor  ณ Cesar Mussi        บ Data ณ  07/31/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GeraArq
Local lRetorno  := .t.
Local cQuery    := ""
Local _cArqC1   := ""
Local nRecCount := 0

_aArqC1   := {}
aHeader   := {}

cQuery := " SELECT SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA1.A1_NREDUZ, SA1.A1_MUNE, SA1.A1_BAIRRO, SA1.A1_TEL "+CHR(13)
cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "+CHR(13)
cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA "+CHR(13)
cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO <>'B' "+CHR(13)
cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' '  OR SC5.C5_JPCSEP = 'P') "+CHR(13)
//cQuery += " AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' '  OR SC5.C5_JPCSEP = 'P') "+CHR(13)
cQuery += " UNION "+CHR(13)
cQuery += " SELECT SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA2.A2_NREDUZ, SA2.A2_MUN, SA2.A2_BAIRRO, SA2.A2_TEL  "+CHR(13)
cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA2")+" SA2 "+CHR(13)
cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA2.A2_COD AND SC5.C5_LOJACLI = SA2.A2_LOJA "+CHR(13)
cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO = 'B' "+CHR(13)
cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' ' OR SC5.C5_JPCSEP = 'P')"+CHR(13)
//cQuery += " AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' ' OR SC5.C5_JPCSEP = 'P')"+CHR(13)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
COUNT TO nRecCount

If nRecCount > 0
	//CRIA ARQUIVO TEMPORARIO
	// Declara Arrays p/ Consultas
	AADD(_aArqC1,{"C5_NUM" 		,"C", 6,0})
	AADD(_aArqC1,{"C5_CLIENTE" 	,"C", 6,0})
	AADD(_aArqC1,{"C5_LOJACLI" 	,"C", 3,0})
	AADD(_aArqC1,{"C5_TIPO"	    ,"C", 1,0})
	AADD(_aArqC1,{"A1_NREDUZ"	,"C",30,0})
	AADD(_aArqC1,{"A1_MUNE"		,"C",30,0})
	AADD(_aArqC1,{"A1_BAIRRO"	,"C",30,0})
	AADD(_aArqC1,{"A1_TEL"		,"C",15,0})
	AADD(_aArqC1,{"LEXCL"		,"L", 1,0})
	nUsado := LEN(_aArqC1) - 1
	
	AADD(aHeader,{"Pedido"    		,"C5_NUM"	 ,"@X" , 6,0,".T.",USADO,"C","",""})
	AADD(aHeader,{"Cliente"   		,"C5_CLIENTE","@X" , 6,0,".t.",USADO,"C","",""})
	AADD(aHeader,{"Loja"      		,"C5_LOJACLI","@X" , 3,0,".t.",USADO,"C","",""})
	AADD(aHeader,{"Nome Reduzido"	,"A1_NREDUZ" ,"@X" ,30,0,".T.",USADO,"C","",""})
	AADD(aHeader,{"Mun.Entrega" 	,"A1_MUNE"   ,"@X" ,30,0,".t.",USADO,"C","",""})
	AADD(aHeader,{"Bairro"     		,"A1_BAIRRO" ,"@X" ,30,0,".t.",USADO,"C","",""})
	AADD(aHeader,{"Telefone"  		,"A1_TEL"	 ,"@X" ,15,0,".t.",USADO,"C","",""})
	
	// Arquivo Auxiliar para Consultas
	_cArqC1 := CriaTrab(_aArqC1,.T.)
	dbUseArea(.T.,,_cArqC1,"SEPARA")
	Index on C5_NUM to &_cArqC1
	
	dbSelectArea("TRB")
	dbGoTop()
	nPosic := 1
	Do While !EOF()
		DbSelectArea("SC9")
		DbSetOrder(1)
		DbSeek(xFilial("SC9")+TRB->C5_NUM)
		lTemCred := .f.
		Do While !eof() .and. xFilial("SC9")+TRB->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO
		    IF ALLTRIM(SC9->C9_BLCRED) == ""
		       lTemCred := .t.
		    ENDIF		
			DbSelectArea("SC9")
		    DbSkip()
		Enddo   
		IF lTemCred
			RecLock("SEPARA",.T.)
			C5_NUM 		:= TRB->C5_NUM
			C5_CLIENTE  := TRB->C5_CLIENTE
			C5_LOJACLI 	:= TRB->C5_LOJACLI
			A1_NREDUZ	:= TRB->A1_NREDUZ
			A1_MUNE 	:= TRB->A1_MUNE
			A1_BAIRRO	:= TRB->A1_BAIRRO
			A1_TEL      := TRB->A1_TEL
			MsUnlock()
		ENDIF
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	dbSelectArea("TRB")
	dbCloseArea()
	
Else
	MsgStop(" Nao foram encontrados mais pedidos para Separacao ! ")
	TRB->(dbCloseArea())
	
	lRetorno := .f.
Endif
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MTACONF  บAutor  ณ Cesar Mussi        บ Data ณ  07/31/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MtaConf
aLstBox := {}
lret    := .t.
//CRIA ARQUIVO TEMPORARIO
// Declara Arrays p/ Consultas
_aArqC2 := {}
AADD(_aArqC2,{"B1_CODBAR"	,"C",20,0})
AADD(_aArqC2,{"B1_COD   "	,"C",30,0})
AADD(_aArqC2,{"LEXCL"		,"L", 1,0})
nUsado := LEN(_aArqC2) - 1

aHeade2 :={}
AADD(aHeade2,{"Cod.Barras"		,"B1_CODBAR" ,"@X" , 20,0,".T.",USADO,"C","",""})
AADD(aHeade2,{"Cod.Produto"		,"B1_COD"    ,"@X" , 30,0,".T.",USADO,"C","",""})
aAlter2 := {}
AADD(aAlter2,"B1_CODBAR")
// Arquivo Auxiliar para Consultas
_cArqC2 := CriaTrab(_aArqC2,.T.)
dbUseArea(.T.,,_cArqC2,"CONF")
//Index on B1_CODBAR to &_cArqC2

cSql := ""
cSql += " SELECT SC9.*, SB1.B1_CODBAR, SB1.B1_DESC, SB1.B1_LOCALIZ, SB1.B1_RASTRO "
cSql += " FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SB1")+" SB1 "
cSql += " WHERE SC9.C9_PEDIDO = '"+SEPARA->C5_NUM+"' AND "
cSql += "       SC9.D_E_L_E_T_ = ' ' AND SC9.C9_BLEST <> '  ' AND SC9.C9_BLCRED = ' ' AND "
cSql += "       SB1.B1_COD = SC9.C9_PRODUTO AND "
cSql += "       SB1.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY C9_ITEM           "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"PEDSEP", .F., .T.)

DbSelectArea("PEDSEP")
DbGoTop()
Do While !eof()
    DbSelectArea("SC6")
    DbSetOrder(1)
    DbSeek(xFilial("SC6") + SEPARA->C5_NUM + PEDSEP->C9_ITEM + PEDSEP->C9_PRODUTO)
    cTes := SC6->C6_TES
    DbSelectArea("SF4")
    DbSetOrder(1)
    DbSeek(xFilial("SF4")+cTes)
    
    IF SF4->F4_ESTOQUE == "S"
	   aAdd(aLstBox,{PEDSEP->C9_ITEM  , PEDSEP->C9_PRODUTO, PEDSEP->B1_DESC   , PEDSEP->C9_QTDLIB , 0 , ;
	   PEDSEP->C9_QTDLIB, PEDSEP->C9_LOTECTL+PEDSEP->C9_NUMLOTE, PEDSEP->C9_NUMSERI, PEDSEP->C9_LOCAL,;
	   IIF(LOCALIZA(PEDSEP->C9_PRODUTO),"NSERIE",IIF(RASTRO(PEDSEP->C9_PRODUTO),"LOTES ","CODBAR")) })
	ENDIF
	
	DbSelectArea("PEDSEP")
	DbSkip()
	lret := .t.
Enddo

IF Len(aLstBox) == 0
	aAdd(aLstBox,{"", "", "SEM ITENS LIBERADOS" , 0 , 0 , 0, "", "", "", "" })
	lret := .t.
Endif
DbSelectArea("PEDSEP")
DbCloseArea()

Return(lret)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJPCNSERIE บAutor  ณ Cesar Mussi        บ Data ณ  09/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function JPCGQTD(_nQtd)
DEFAULT _nQtd		:= 1.00

DEFINE MSDIALOG oDlg1 TITLE "Informe a quantidade" FROM 33,25 TO 110,349 PIXEL  
@ 01,05 TO 032, 128 OF oDlg1 PIXEL
@ 08,08 SAY "Quantidade" SIZE 55, 7 OF oDlg1 PIXEL  
@ 18,08 MSGET _nQtd SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15) VALID ;
       !empty(iif(_nQtd > SaldoSb2() .or. _nQtd <> aLstBox[_nPosAlst,4]  ,eval({|| Help ( " ", 1, "SLDSB2/SALDO A SEPARAR" ),0}),_nQtd))
// aLstBox[_nPosAlst,4] eh a posicao da quantidade a ser separada, nao permite digitar quantidade maior que o solicitado, tambem valida o saldosb2	
DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End(),_nQtd := 1) ENABLE OF oDlg1
ACTIVATE MSDIALOG oDlg1 CENTERED
		
Return _nQtd