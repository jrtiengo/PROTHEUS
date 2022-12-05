#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ JPCACDTR ºAutor  ³ Cesar M.Mussi      º Data ³  23/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Conferencia de Separacao                           º±±
±±º          ³ ajuste p/Transferencias entre filiais c/serie - Gerson     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSerie     ³ Alpha# - Materiais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function JPCACDTR(aItensTr)

// Variaveis Locais .. depois passar para parametros

Private _cTitulo  := "Alpha#JPCACDTR - Conferencia Itens de Transferencia"
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
Private cCodLote := Space(15)

Private _nQCodP := 0		// JPC Gerson - 16.06.11
Private _cListProd := ''	// JPC Gerson - 25.06.11
Private _aItensTr := aclone(aItensTr)	// JPC Gerson - 25.06.11

U_AUTOM628("JPCACDTR")

If SC5->(FieldPos("C5_JPCSEP")) == 0
	MsgStop("Falta criar o campo C5_JPCSEP C 1 !")
Else
	Do While .t.
		
		IF GeraArq()	// Gera Arquivo Temporario
			
			//=============================================================
			
			DEFINE MSDIALOG oDlgBrw TITLE _cTitulo From 140,0 To 645,1078 OF oMainWnd PIXEL Style DS_MODALFRAME
			oGetDb1 := MsGetDB():New(10,10,230,520,1,"SEPTDOK","SEPTDOK","",.F., aAlter, ,.T., ,"SEPARA",Nil,Nil,Nil,oDlgBrw)
			// MsGetDb():New( nSuperior, nEsquerda, nInferior, nDireita,
			//     nOpc, [ cLinhaOk ], [ cTudoOk ], [ cIniCpos ], [ lApagar ], [ aAlter ],
			// [ nCongelar ], [ lVazio ], [ uPar1 ], cTRB, [ cCampoOk ], [ lCondicional ], [ lAdicionar ], [ oWnd ], [ lDisparos ], [ uPar2 ], [ cApagarOk ], [ cSuperApagar ] ) -> objeto
			DEFINE SBUTTON FROM 237,040 TYPE 06 ACTION (nOca:=2,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
			@247,040 Say OemtoAnsi("Lista Sep.") SIZE 40,10 OF oDlgBrw PIXEL
			DEFINE SBUTTON FROM 237,070 TYPE 11 ACTION (nOca:=3,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
			@247,070 Say OemtoAnsi("Leitura")    SIZE 40,10 OF oDlgBrw PIXEL
			DEFINE SBUTTON FROM 237,100 TYPE 15 ACTION ( PsqaLst()) Of oDlgBrw PIXEL ENABLE
			@247,100 Say OemtoAnsi("Pesquisa")    SIZE 40,10 OF oDlgBrw PIXEL
			//DEFINE SBUTTON FROM 137,350 TYPE 01 ACTION (nOca:=1,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
			//@147,350 Say OemtoAnsi("Confirma")    SIZE 40,10 OF oDlgBrw PIXEL
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
					 JPCSEPGRF()
				Else //Matricial
					 JPCSEPMAT()
				Endif
				
			ElseIf nOca == 3
				// Conferencia
				IF  MtaConf()
					aHeadBkp := aClone(aHeader)
					aHeader  := aClone(aHeade2)
					
					DEFINE MSDIALOG oDlgConf TITLE _cTitulo From 100,0 To 650,1200 OF oMainWnd PIXEL Style DS_MODALFRAME
					@ 003,010 SAY OemToAnsi("Cod.Barras ") SIZE 060,008 OF oDlgConf PIXEL
					@ 003,060 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL
					@ 003,140 SAY OemToAnsi("Lote/Ender./No.Serie ") SIZE 100,008 OF oDlgConf PIXEL
					//@ 003,060 MSGET oCodBarr VAR cCodBarr PICTURE "@X" VALID( VldCdBr(cCodBarr)) SIZE 060,008 OF oDlgConf PIXEL
					@ 003,210 MSGET oCodLote VAR cCodLote PICTURE "@X" VALID( VldLote(cCodLote)) SIZE 060,008 OF oDlgConf PIXEL
					oGetDb2 := MsGetDB():New(20,10,260,110,1,"CFTDOK","CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
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
						
						While !Eof()
							
							//Procuro o produto para ver se tem controle de Localizacao
							_cTipoCod:= IIF(Localiza(CONF->B1_COD),"S","P")
							
							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+CONF->B1_COD)
							
							IF EOF()
								ALERT("SB1 - Entre em contato com o Administrador ! Problema: Produto "+Alltrim(CONF->B1_COD)+" na rotina JPCACD01")
								Exit
							ENDIF
							If _cTipoCod=="S" 
								_n := ASCAN(aLstBox, {|aVal| Alltrim(aVal[8]) == Alltrim(CONF->B1_CODBAR)})
							ElseIf _cTipoCod=="P" 
								_n := ASCAN(aLstBox, {|aVal| Alltrim(aVal[2]) == Alltrim(CONF->B1_COD)})
							Endif
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
								B2_QEMP := B2_QEMP + 1
								MsUnlock()
								/*
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
								MsUnlock()         */
							Else
								_cTipoC5 := "P"
							Endif
							
							DbSelectArea("CONF")
							DbSkip()
							
						Enddo
						
						// Atualizar SC5
						// Verifica o SC9
						/*
						DbSelectArea("SC9")
						DbSetOrder(2) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
						DbSeek(xFilial("SC9")+SEPARA->C5_CLIENTE+SEPARA->C5_LOJACLI+SEPARA->C5_NUM)
						_cChave := C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO
						Do While !eof() .and. _cChave == xFilial("SC9")+SC9->C9_FILIAL+SC9->C9_CLIENTE+SC9->C9_LOJA+SC9->C9_PEDIDO
							IF 	SC9->C9_BLEST <> "  " .OR. SC9->C9_BLWMS <> "  "
								_cTipoC5 := "P"
								Exit
							ENDIF
							DbSelectArea("SC9")
							DbSkip()
						Enddo
						DbSelectArea("SC5")
						DbSetorder(1)
						DbSeek(xFilial("SC5")+SEPARA->C5_NUM)
						Reclock("SC5",.f.)
						C5_JPCSEP := _cTipoC5
						MsUnlock() */
						
					Endif
					
				Else	// nao eh mostrado...
					MsgBox("Verifique SBF - Saldos por Endereco")
				Endif
				
				DbSelectArea("CONF")
				//DbCloseArea()	// nao fechar pois preciso dele para a litagem/impressao...
				aHeader  := aClone(aHeadBkp)
				
			Endif
			
			DbSelectArea("SEPARA")
			DbCloseArea()
			
		Else
			Exit
		Endif
		
	Enddo
Endif
If (Select("CONF") <> 0)
	DbSelectArea("CONF")
	DbCloseArea()
Endif

Return _aItensTr

Static function PsqaLst
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VLDLOTE  ºAutor  ³Microsiga           º Data ³  04/16/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function VldLote(p1)


// Valida a digitacao de cada etiqueta do pacote
Local cMsg := "Problema no Codigo Lote/SLote/NSerie : '"+cCodLote+"'"+chr(13)+chr(10)
Private lRetorno  := .t.
Private _cTipoCod := "U"  //Undeffined
Private _nPosAlst := 0
cMsg += "---------------------------------------"+chr(13)+chr(10)

If ! Empty(cCodLote)
	// Obrigo o Posicionamento do aLstBox
	_nPosAlst := ASCAN(aLstBox, {|aVal| Alltrim(aVal[8]) == Alltrim(cCodLote)})	// busca po num. serie
	_nPosAlst := iif(_nPosAlst==0,ASCAN(aLstBox, {|aVal| Alltrim(aVal[2]) == Alltrim(cCodLote)}),_nPosAlst)	// busca por cod barra do produto
	_cCodProd := aLstBox[_nPosAlst,2]
	
	//Procuro o produto para ver se tem controle de Localizacao
	_cTipoCod:= IIF(Localiza(_cCodProd),"S","P")
						
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cCodProd)

	IF _cTipoCod == "S"
	   // Numero de serie
		DbSelectArea("SBF")
		DbSetOrder(4)   //BF_FILIAL+BF_PRODUTO+BF_NUMSERI
		DbSeek(xFilial("SBF")+_cCodProd+cCodLote)
		IF eof()
			//ops.... nao eh codigo de numero de serie
			lRetorno := .f.
			Alert("Produto "+_cCodProd+" com Controle de Enderecamento, mas Numero de Serie lido não é desse produto !")
		Else
			lRetorno := .t.
		Endif
	
	ElseIf _cTipoCod == "P"
        // Codigo de barras normal
		DbSelectArea("SB1")
		DbSetOrder(5)		// B1_FILIAL, B1_CODBAR
		DbSeek(xFilial("SB1")+_cCodProd)
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
				//IF (SBF->BF_QUANT - SBF->BF_EMPENHO) <= 0
				//	lRetorno := .f.
				//	cMsg += "Lote "+cCodLote+" sem Saldo Disponivel "+chr(13)+chr(10)
				//ELSE
					cDescProd := SB1->B1_COD + " : " + SB1->B1_DESC
					cCodProd  := SBF->BF_PRODUTO
				//ENDIF
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
			lRet2 :=  GETLBOX("ACONF")
			IF !lRet2
				cMsg += "O produto "+ALLTRIM(SB1->B1_DESC)+chr(13)+chr(10)
				cMsg += "ja tem a quantidade completa separada !"+chr(13)+chr(10)
				cMsg += "---------------------------------------"+chr(13)+chr(10)
			Else
				DbSelectArea("CONF")
				_nQCodP   := 1
				IF _cTipoCod == "P"
					_nQCodP := JPCGQTD()
				Endif
				_XFor := _nQCodP	//iif(_nQCodP>0,_nQCodP,1) // Gerson - _nQCodP alimentado em GetlBox(p1)p/produtos _cTipoCod == "P"
				For _nX := 1 to _XFor
					Reclock("CONF",.t.)
					CONF->B1_CODBAR := cCodLote
					CONF->B1_COD    := _cCodProd
					CONF->(MsUnlock())
				Next
				DbGoTop()
				oGetDb2 := MsGetDB():New(20,10,260,110,1,"CFTDOK","CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
				If _nQCodP > 0 //@ 015,010 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL
				 	GetlBox("ATUAL")	// Atualiza o ListBox
				Endif
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

cCodLote := Space(15)
oLbx:Refresh()

DbSelectArea("CONF")

Return(lRetorno)


Static function VldCdBr(p1)

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
	lRetorno :=  GETLBOX("ACONF")
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
		
		oGetDb2 := MsGetDB():New(20,10,260,110,1,"CFTDOK","CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
		//@ 015,010 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL
		
		 GetlBox("ATUAL")	// Atualiza o ListBox
		
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GETLBOX  ºAutor  ³ Cesar Mussi        º Data ³  01/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Centraliza o tratamento do array aLstBox                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function GetlBox(p1)
Local lRet := .t.
Local _nQtd := 0	// JPC Gerson - 16.06.11
Local _nTLido := 0
Local _nTTrIt := 0

	IF p1 == "ATUAL"   // Atualiza o ListBox
		
		IF ALLTRIM(aLstBox[_nPosAlst, 2]) == ALLTRIM(cCodProd)
			IF _cTipoCod == "P"
				_nQtd := iif(_nQCodP>0,_nQCodP,1)
			Else
			    _nQtd := 1
			Endif
			IF _nQtd >= 1  
				lRet := .t.
				aLstBox[_nPosAlst, 5]+= _nQtd
				aLstBox[_nPosAlst, 6]-= _nQtd
				
			Else
				lRet := .f.
			Endif
			
		ENDIF
	ELSEIF p1 == "ACONF"    // Retorna se tem saldo a Conferir
		IF ALLTRIM(aLstBox[_nPosAlst, 2]) == ALLTRIM(cCodProd)
			aeval(aLstBox,{|aIt| _nTLido+=iif(aIt[2]==cCodProd,aIt[5],0)})	// confere se ja leu a qtd do produto selecionado aItensTr
			aeval(_aItensTr,{|aIt2| _nTTrIt+=iif(aIt2[2,2]==cCodProd,aIt2[4,2],0)})
			IF _nTLido < _nTTrIt
				lRet := .t.
			Else
				lRet := .f.
			Endif
		ENDIF
	ENDIF
	
Return(lRet)

Static function CFTDOK

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JPCSEPGRF ºAutor  ³ CESAR MUSSI        º Data ³  31/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function JPCSEPGRF

LOCAL oFont8 , oFont9 , oFont10 , oFont11 , oFont12 , oFont14 , oFont16 , oFont24, oBrush, nCnt
LOCAL oFont8N, oFont9N, oFont10N, oFont11N, oFont12N, oFont14N, oFont16n, oFont26
LOCAL cTitl, cCart, cFato, nValr, cValr, cNBco, cDBco, cCont, cBole, cNNum
LOCAL cDNum, cNoss, cBarr, cDBar , cLinh, cAgen, cDcAg, cNmCC, cDcNc
LOCAL cSql, _Item
//Parâmetros de TFont.New()
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


oPrint:=TMSPrinter():New( "Lista de Separacao - Transf. filiais" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:Setup()
oPrint:StartPage()   // Inicia uma nova página

oPrint:Box  (0050, 0200, 3140, 2400)    	// Box da borda da página
oPrint:Line (0240, 0200, 0240, 2400)        // Linha do Topo
oPrint:Line (0320, 0200, 0320, 2400)        // Linha do Topo
oPrint:Line (0240, 2200, 3140, 2200)    	// Linha Coluna 3
oPrint:Line (0240, 2000, 3140, 2000)    	// Linha Coluna 2
oPrint:Line (0240, 1800, 3140, 1800)    	// Linha Coluna 1
//oPrint:Line (0490, 0100, 0490, 0630)
//oPrint:Line (0050, 0630, 0740, 0630)
//oPrint:Line (0050, 1800, 0740, 1800)

//oPrint:SayBitmap (0052, 0205, "LogoJPC.bmp", 0240, 0180)  //logo da Empresa

oPrint:Say  (0090, 0800, " Lista de Separação - Transferencia entre Filiais" , oFont24)
//oPrint:Say  (0170, 0820, ALLTRIM(SEPARA->A1_NREDUZ), oFont12)
oPrint:Say  (0170, 0820, "Transf. p/filial: ", oFont12)

oPrint:Say  (0260, 0800, " Item + Produto    ", oFont12N )
oPrint:Say  (0260, 1850, " Quant "            , oFont12N )
oPrint:Say  (0260, 2050, " Lote " 			  , oFont12N )
oPrint:Say  (0260, 2200, " Num.Serie "        , oFont12N )
/*
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
*/

If( Select( "CONF" ) > 0 )

	DbSelectArea("CONF")
	DbGoTop()
	
	_nLin   := 30
	_Item 	:= 1
	While ! eof()
		
		_nLin += 60
		
	//					CONF->B1_CODBAR := cCodLote
	//					CONF->B1_COD    := _cCodProd
	
		oPrint:Say  (0260+_nLin, 0220, Strzero(_Item,3,0) + "-" + Posicione("SB1",1,xFilial("SB1")+CONF->B1_COD,"B1_DESC") + " - "+CONF->B1_COD , oFont10 )
		
		oPrint:Say  (0260+_nLin, 1960, TRANSFORM(1  ,"@E 999,999.99"    ), oFont10,100,,,1 )
		oPrint:Say  (0260+_nLin, 2050, CONF->B1_CODBAR , oFont10,100,,,0 )
		oPrint:Say  (0260+_nLin, 2250, CONF->B1_CODBAR , oFont10,100,,,0 )
		
		DbSelectArea("CONF")
		DbSkip()
		
		IF (260+_nLin+60) > 3140
			oPrint:EndPage()   // Inicia uma nova página
			oPrint:StartPage()   // Inicia uma nova página
			oPrint:Box  (0050, 0200, 3140, 2400)    	// Box da borda da página
			oPrint:Line (0240, 0200, 0240, 2400)        // Linha do Topo
			oPrint:Line (0320, 0200, 0320, 2400)        // Linha do Topo
			oPrint:Line (0240, 2200, 3140, 2200)    	// Linha Coluna 3
			oPrint:Line (0240, 2000, 3140, 2000)    	// Linha Coluna 2
			oPrint:Line (0240, 1800, 3140, 1800)    	// Linha Coluna 1
			//oPrint:Line (0490, 0100, 0490, 0630)
			//oPrint:Line (0050, 0630, 0740, 0630)
			//oPrint:Line (0050, 1800, 0740, 1800)
			
			//oPrint:SayBitmap (0052, 0205, "LogoJPC.bmp", 0240, 0180)  //logo da Empresa
			
			oPrint:Say  (0090, 0800, " Lista de Separação - Transf. filiais ", oFont24)
			//oPrint:Say  (0170, 0820, ALLTRIM(SEPARA->A1_NREDUZ), oFont12)
			oPrint:Say  (0170, 0820, "Transf. p/filial: ", oFont12)
			
			oPrint:Say  (0260, 0800, " Item + Produto    ", oFont12N )
			oPrint:Say  (0260, 1850, " Quant "            , oFont12N )
			oPrint:Say  (0260, 2050, " Lote " 			  , oFont12N )
			oPrint:Say  (0260, 2200, " Num.Serie "        , oFont12N )
			
		Endif
		
	Enddo
	DbSelectArea("CONF")
Endif	

oPrint:EndPage()   	// Finaliza página
oPrint:Preview()    // Visualiza antes de imprimir

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JPCSEPMAT ºAutor  ³ CESAR MUSSI        º Data ³  16/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao da Lista de Separacao em Matricial                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function JPCSEPMAT

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Lista de Transferencia entre filiais"
Local titulo         := "Lista de Transferencia - Filiais "
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
Private nomeprog     := "JPCACDTR"			// Nome do programa para impressao no cabecalho
Private nTipo        := 15					// Tipo do relatorio
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0					// Codigo ASCII da ultima tecla pressionada pelo usuario
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "JPCACDTR"			// Nome do arquivo usado para impressao em disco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do relatorio.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| MATRICIAL(	Cabec1		, Cabec2, Titulo, nLin ) } ,Titulo)

Return

Static Function MATRICIAL(Cabec1 ,Cabec2 ,Titulo,	nLin)
/*
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
*/
If( Select( "CONF" ) > 0 )

	DbSelectArea("CONF")
	DbGoTop()
	_Item 	:= 1
	While ! eof()
		
		If nLin > 60
			Cabec(	Titulo	, Cabec1	, Cabec2, NomeProg, Tamanho	, nTipo )
			nLin     := 8
		Endif
		
		@nLin,001 PSAY Strzero(_Item,3,0) + "-" + Posicione("SB1",1,xFilial("SB1")+CONF->B1_COD,"B1_DESC") + " - "+PEDSEP->B1_CODBAR+" | "+;
		TRANSFORM(1  ,"@E 999,999.99"    )+" | "+;
		CONF->B1_CODBAR+" | "+CONF->B1_CODBAR
		
		DbSelectArea("CONF")
		DbSkip()
		
	Enddo
	
	DbSelectArea("CONF")

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descarrega o Cache armazenado na memoria para a impressora.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MS_FLUSH()

Return(.t.)


Static function SEPTDOK

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraArq  ºAutor  ³ Gerson L Lage      º Data ³  23/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraArq()
Local lRetorno  := .t.

Local _cArqC1   := ""
Local nRecCount := 0
Local _nI 		:= 0

_aArqC1   := {}
aHeader   := {}

_cListProd := ''

	//CRIA ARQUIVO TEMPORARIO
	// Declara Arrays p/ Consultas
	AADD(_aArqC1,{"C6_ITEM" 	,"C", TamSX3("C6_ITEM")[1]   ,TamSX3("C6_ITEM")[2]})
	AADD(_aArqC1,{"C6_PRODUTO" 	,"C", TamSX3("C6_PRODUTO")[1],TamSX3("C6_PRODUTO")[2]})
	AADD(_aArqC1,{"C6_LOCAL" 	,"C", TamSX3("C6_LOCAL")[1]  ,TamSX3("C6_LOCAL")[2]})
	AADD(_aArqC1,{"C6_QTDVEN"	,"N", TamSX3("C6_QTDVEN")[1] ,TamSX3("C6_QTDVEN")[2]})
	AADD(_aArqC1,{"C6_PRCVEN"	,"N", TamSX3("C6_PRCVEN")[1] ,TamSX3("C6_PRCVEN")[2]})
	AADD(_aArqC1,{"C6_PRUNIT"	,"N", TamSX3("C6_PRUNIT")[1] ,TamSX3("C6_PRUNIT")[2]})
	AADD(_aArqC1,{"C6_VALOR"	,"N", TamSX3("C6_VALOR")[1]  ,TamSX3("C6_VALOR")[2]})
	AADD(_aArqC1,{"C6_TES"	    ,"C", TamSX3("C6_TES")[1]    ,TamSX3("C6_TES")[2]})
	//nUsado := LEN(_aArqC1) - 1
	
	//AADD(aHeader,{"Pedido"    		,"C5_NUM"	 ,"@X" , 6,0,".T.",USADO,"C","",""})
	AADD(aHeader,{"Item"      		,"C6_ITEM"	  ,"@X" ,TamSX3("C6_ITEM")[1]   ,TamSX3("C6_ITEM")[2]   ,".T.",USADO,"C","",""})
	AADD(aHeader,{"Produto"   		,"C6_PRODUTO" ,"@X" ,TamSX3("C6_PRODUTO")[1],TamSX3("C6_PRODUTO")[2],".t.",USADO,"C","",""})
	AADD(aHeader,{"Local"     		,"C6_LOCAL"   ,"@X" ,TamSX3("C6_LOCAL")[1]  ,TamSX3("C6_LOCAL")[2]  ,".t.",USADO,"C","",""})
	AADD(aHeader,{"Qtd. transf." 	,"C6_QTDVEN"  ,"@X" ,TamSX3("C6_QTDVEN")[1] ,TamSX3("C6_QTDVEN")[2] ,".T.",USADO,"N","",""})
	AADD(aHeader,{"Prc. venda"  	,"C6_PRCVEN"  ,"@X" ,TamSX3("C6_PRCVEN")[1] ,TamSX3("C6_PRCVEN")[2] ,".t.",USADO,"N","",""})
	AADD(aHeader,{"Prc. unit." 		,"C6_PRUNIT"  ,"@X" ,TamSX3("C6_PRUNIT")[1] ,TamSX3("C6_PRUNIT")[2] ,".t.",USADO,"N","",""})
	AADD(aHeader,{"Valor"     		,"C6_VALOR"	  ,"@X" ,TamSX3("C6_VALOR")[1]  ,TamSX3("C6_VALOR")[2]  ,".t.",USADO,"N","",""})
	AADD(aHeader,{"TES"        		,"C6_TES"	  ,"@X" ,TamSX3("C6_TES")[1]    ,TamSX3("C6_TES")[2]    ,".t.",USADO,"C","",""})
	
	// Arquivo Auxiliar para Consultas
	_cArqC1 := CriaTrab(_aArqC1,.T.)
	dbUseArea(.T.,,_cArqC1,"SEPARA")
	Index on C6_ITEM to &_cArqC1

	For _nI := 1 to len(_aItensTr) 
		RecLock("SEPARA",.T.)
		SEPARA->C6_ITEM 	:= _aItensTr[_nI,1,2]
		SEPARA->C6_PRODUTO  := _aItensTr[_nI,2,2]
		SEPARA->C6_LOCAL 	:= _aItensTr[_nI,3,2]
		SEPARA->C6_QTDVEN	:= _aItensTr[_nI,4,2]
		SEPARA->C6_PRCVEN 	:= _aItensTr[_nI,5,2]
		SEPARA->C6_PRUNIT	:= _aItensTr[_nI,6,2]
		SEPARA->C6_VALOR    := _aItensTr[_nI,7,2]
		SEPARA->C6_TES      := _aItensTr[_nI,8,2]
		MsUnlock()
		_cListProd += "'"+_aItensTr[_nI,2,2]+iif(_nI<len(_aItensTr),"',","'")	// carrega a lista de produtos p/MtaConf
	Next

	
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTACONF  ºAutor  ³ Gerson L Lage      º Data ³  25/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function MtaConf()
Local _nItem := 1
aLstBox := {}
lret    := .t.
//CRIA ARQUIVO TEMPORARIO
// Declara Arrays p/ Consultas
_aArqC2 := {}
AADD(_aArqC2,{"B1_CODBAR"	,"C",20,0})
AADD(_aArqC2,{"B1_COD   "	,"C",30,0})
AADD(_aArqC2,{"LEXCL"		,"L", 1,0})
//nUsado := LEN(_aArqC2) - 1

aHeade2 :={}
AADD(aHeade2,{"Cod.Barras"		,"B1_CODBAR" ,"@X" , 20,0,".T.",USADO,"C","",""})
AADD(aHeade2,{"Cod.Produto"		,"B1_COD"    ,"@X" , 30,0,".T.",USADO,"C","",""})
aAlter2 := {}
AADD(aAlter2,"B1_CODBAR")
// Arquivo Auxiliar para Consultas
_cArqC2 := CriaTrab(_aArqC2,.T.)
If Select("CONF") <> 0  
	CONF->(DbClosearea("CONF"))
Endif
dbUseArea(.T.,,_cArqC2,"CONF")
//Index on B1_CODBAR to &_cArqC2

cSql := ""
cSql += " SELECT BF_PRODUTO,BF_QUANT,BF_NUMSERI, BF_LOCAL, SB1.B1_CODBAR, SB1.B1_CODBAR, SB1.B1_DESC, SB1.B1_LOCALIZ, SB1.B1_RASTRO "
cSql += " FROM "+RetSqlName("SBF")+" SBF, "+RetSqlName("SB1")+" SB1 "
cSql += " WHERE  "
cSql += "       SB1.B1_COD = SBF.BF_PRODUTO AND "
cSql += "       SBF.BF_NUMSERI <> '  ' AND ((SBF.BF_QUANT-SBF.BF_EMPENHO) > 0)  AND SBF.D_E_L_E_T_ = ' ' AND "
cSql += "       SBF.BF_PRODUTO IN ("+_cListProd+") AND "
cSql += "       SB1.D_E_L_E_T_ = ' ' "
cSql += " UNION "                     
cSql += " SELECT SB2.B2_COD BF_PRODUTO,SB2.B2_QATU BF_QUANT,' ' BF_NUMSERI, SB2.B2_LOCAL BF_LOCAL, SB1.B1_CODBAR, SB1.B1_CODBAR, SB1.B1_DESC, SB1.B1_LOCALIZ, SB1.B1_RASTRO "
cSql += " FROM "+RetSqlName("SB2")+" SB2, "+RetSqlName("SB1")+" SB1 "
cSql += " WHERE  "
cSql += "       SB1.B1_COD = SB2.B2_COD AND "
cSql += "       (SB2.B2_QATU > 0)  AND SB2.D_E_L_E_T_ = ' ' AND "
cSql += "       SB2.B2_COD IN ("+_cListProd+") AND "
cSql += "       SB1.D_E_L_E_T_ = ' ' "

cSql += " ORDER BY BF_PRODUTO "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"PEDSEP", .F., .T.)

DbSelectArea("PEDSEP")
DbGoTop()

While !eof()
	aAdd(aLstBox,{strzero(_nItem++,3,0), PEDSEP->BF_PRODUTO, PEDSEP->B1_DESC   , PEDSEP->BF_QUANT , 0 , PEDSEP->BF_QUANT, "", PEDSEP->BF_NUMSERI, PEDSEP->BF_LOCAL,;
	IIF(LOCALIZA(PEDSEP->BF_PRODUTO),"NSERIE",IIF(RASTRO(PEDSEP->BF_PRODUTO),"LOTES ","CODBAR")) })
	DbSelectArea("PEDSEP")
	DbSkip()
End

IF Len(aLstBox) == 0
	aAdd(aLstBox,{"", "", "SEM ITENS LIBERADOS" , 0 , 0 , 0, "", "", "", "" })
	lret := .t.
Endif
DbSelectArea("PEDSEP")
DbCloseArea()

Return(lret)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JPCNSERIE ºAutor  ³ Gerson L Lage      º Data ³  09/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function JPCGQTD(_nQtd)
DEFAULT _nQtd		:= 1.00

DEFINE MSDIALOG oDlg1 TITLE "Informe a quantidade" FROM 33,25 TO 110,349 PIXEL  
@ 01,05 TO 032, 128 OF oDlg1 PIXEL
@ 08,08 SAY "Quantidade" SIZE 55, 7 OF oDlg1 PIXEL  
@ 18,08 MSGET _nQtd SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15) VALID !empty(iif(_nQtd>SaldoSb2(), eval({|| Help ( " ", 1, "SLDSB2" ),_nQtd:=0,0}), _nQtd))
	
DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End(),_nQtd := 0) ENABLE OF oDlg1
ACTIVATE MSDIALOG oDlg1 CENTERED
		
Return _nQtd