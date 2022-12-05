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
Local _nItem     := ""
Local _cMsgPar   := ""

Local __Lacre    := ""
Local __Corpo    := ""
Local __Filial   := ""

Local lChumba    := .F.
Local nContar    := 0

Private _cTitulo  := "JPCACD01 - Conferencia de Separacao"
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

Private oCodPedido 
Private oCodPedido := Space(06)

Private _nQCodP := 0	// JPC Gerson - 16.06.11

Private cPedAtu := "S"
Private oPedAtu

Private oDlgBrw
Private aRet  := {}
Private aType := {}
Private aFile := {}
Private aLine := {}
Private aDate := {}
Private aTime := {}

Private lLibera := .F.

// Jean Rehermann - 31/01/2012 - Verificar parametros, se nใo estiverem OK nao deixa separar
If GetMv("MV_AVALEST") != 3
	_cMsgPar := "Verificar o parametro MV_AVALEST, o conteudo deve ser 3" +CHR(13)
EndIf
If GetMv("MV_SELLOTE") != "1"
	_cMsgPar += "Verificar o parametro MV_SELLOTE, o conteudo deve ser 1" +CHR(13)
EndIf
If GetMv("MV_GERABLQ") != "S"
	_cMsgPar += "Verificar o parametro MV_GERABLQ, o conteudo deve ser S"
EndIf

If Len( _cMsgPar ) > 0
	MsgStop(_cMsgPar)
	Return
EndIf

If SC5->(FieldPos("C5_JPCSEP")) == 0
	MsgStop("Falta criar o campo C5_JPCSEP C 1 !")
Else
	Do While .t.
		
		IF GeraArq() // Gera Arquivo Temporario
			
			//=============================================================
			
			DEFINE MSDIALOG oDlgBrw TITLE _cTitulo From 140,0 To 645,1078 OF oMainWnd PIXEL Style DS_MODALFRAME
			oGetDb1 := MsGetDB():New(05,05,235,530,1,"U_SEPTDOK","U_SEPTDOK","",.F., aAlter, ,.T., ,"SEPARA",Nil,Nil,Nil,oDlgBrw)
			// MsGetDb():New( nSuperior, nEsquerda, nInferior, nDireita,
			//     nOpc, [ cLinhaOk ], [ cTudoOk ], [ cIniCpos ], [ lApagar ], [ aAlter ],
			// [ nCongelar ], [ lVazio ], [ uPar1 ], cTRB, [ cCampoOk ], [ lCondicional ], [ lAdicionar ], [ oWnd ], [ lDisparos ], [ uPar2 ], [ cApagarOk ], [ cSuperApagar ] ) -> objeto

// ---------------------------------------------------------------------------------------------------------------------------
// Altera็ใo do formato dos bot๕es em 26/10/2011 - Solicita็ใo do Roger
// ---------------------------------------------------------------------------------------------------------------------------
//			DEFINE SBUTTON FROM 237,040 TYPE 06 ACTION (nOca:=2,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
//			@247,040 Say OemtoAnsi("Lista Sep.") SIZE 40,10 OF oDlgBrw PIXEL
//			DEFINE SBUTTON FROM 237,070 TYPE 11 ACTION (nOca:=3,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
//			@247,070 Say OemtoAnsi("Leitura")    SIZE 40,10 OF oDlgBrw PIXEL
//			DEFINE SBUTTON FROM 237,100 TYPE 15 ACTION (U_PsqaLst()) Of oDlgBrw PIXEL ENABLE
//			@247,100 Say OemtoAnsi("Pesquisa")    SIZE 40,10 OF oDlgBrw PIXEL
//			DEFINE SBUTTON FROM 237,130 TYPE 05 ACTION (U_Embala()) Of oDlgBrw PIXEL ENABLE
//			@247,130 Say OemtoAnsi("Embalagem")    SIZE 40,10 OF oDlgBrw PIXEL
//			DEFINE SBUTTON FROM 237,160 TYPE 09 ACTION (U_Embarque()) Of oDlgBrw PIXEL ENABLE
//			@247,160 Say OemtoAnsi("Embarque")    SIZE 40,10 OF oDlgBrw PIXEL
//			DEFINE SBUTTON FROM 237,190 TYPE 05 ACTION (StsDoc()) OF oDlgBrw PIXEL ENABLE
//			@247,190 Say OemtoAnsi("Documento")    SIZE 40,10 OF oDlgBrw PIXEL
//			@ 237,365 ComboBox oPedAtu Var cPedAtu ITEMS { "S=Sem Filtro","T=Total","P=Parcial"} SIZE 040,010 OF oDlgBrw Pixel
//			DEFINE SBUTTON FROM 237,405 TYPE 01 ACTION ( AtuArq() ) OF oDlgBrw ENABLE Pixel
//			@ 247,365 Say OemtoAnsi("Selecione Filtro") SIZE 40, 20 OF oDlgBrw PIXEL
//			//DEFINE SBUTTON FROM 237,160 TYPE 06 ACTION (U_VerPv()) Of oDlgBrw PIXEL ENABLE
//			//@247,160 Say OemtoAnsi("Ver PV")    SIZE 40,10 OF oDlgBrw PIXEL
//			DEFINE SBUTTON FROM 237,400 TYPE 02 ACTION (nOca:=0,oDlgBrw:End()) OF oDlgBrw PIXEL ENABLE
//			@247,400 Say OemtoAnsi("Saida")    SIZE 40,10 OF oDlgBrw PIXEL
// ---------------------------------------------------------------------------------------------------------------------------
			
            @ 237,005 BUTTON "Lista Sep."  Size 40,12 ACTION (nOca:=2,oDlgBrw:End())      Of oDlgBrw PIXEL
            @ 237,045 BUTTON "Leitura"     Size 40,12 ACTION (nOca:=3,oDlgBrw:End())      Of oDlgBrw PIXEL
            @ 237,085 BUTTON "Pesquisa"    Size 40,12 ACTION (U_PsqaLst())                Of oDlgBrw PIXEL
            @ 237,125 BUTTON "Embalagem"   Size 40,12 ACTION (U_Embala("      "))         Of oDlgBrw PIXEL
            @ 237,165 BUTTON "Embarque"    Size 40,12 ACTION (U_Embarque())               Of oDlgBrw PIXEL
            @ 237,205 BUTTON "Documento"   Size 40,12 ACTION (StsDoc())                   OF oDlgBrw PIXEL
            @ 237,245 BUTTON "Obs.Interna" Size 40,12 ACTION (OBSINTERNA(SEPARA->C5_NUM)) OF oDlgBrw PIXEL
            @ 237,285 BUTTON "Log Sep."    Size 40,12 ACTION (U_ZZQBROWSE())              OF oDlgBrw PIXEL

			@ 240,360 Say OemtoAnsi("Selecione Filtro") SIZE 40, 20 OF oDlgBrw PIXEL
			@ 238,400 ComboBox oPedAtu Var cPedAtu ITEMS { "S=Sem Filtro","T=Total","P=Parcial"} SIZE 040,010 OF oDlgBrw Pixel
			DEFINE SBUTTON FROM 237,440 TYPE 01 ACTION ( AtuArq() ) OF oDlgBrw ENABLE Pixel

            @ 237,480 BUTTON "Saํda"  Size 50,12 ACTION (nOca:=0,oDlgBrw:End()) OF oDlgBrw PIXEL

			aRet  := GetFuncArray('U_JPCACD01*', aType,@aFile,aLine,@aDate,@aTime)
			SetKey( VK_F11, { || APMSGINFO("Arquivo: "+aFile[1]+CHR(13)+CHR(10)+"Versao: 1.2.1"+CHR(13)+CHR(10)+"Data: "+DtoC(aDate[1]),"About:")})
			
			ACTIVATE MSDIALOG oDlgBrw Valid lClose
			
			If nOca == 0
				// ok
				DbSelectArea("SEPARA")
				DbCloseArea()
				Exit
			ElseIf nOca == 2
				// Imprime Lista Separacao
                U_AUTOMR23(SEPARA->C5_NUM)

//				If _cTipoSep == "G"   // Grafica
//					U_JPCSEPGRF()
//				Else //Matricial
//					U_JPCSEPMAT()
//				Endif
				
			ElseIf nOca == 3
				// Conferencia
				IF U_MtaConf()
					aHeadBkp := aClone(aHeader)
					aHeader  := aClone(aHeade2)
					
					DEFINE MSDIALOG oDlgConf TITLE _cTitulo From 100,0 To 660,1200 OF oMainWnd PIXEL Style DS_MODALFRAME

					@ 003,010 SAY OemToAnsi("Lote/Ender./No.Serie ") SIZE 100,008 OF oDlgConf PIXEL
					//@ 003,060 MSGET oCodBarr VAR cCodBarr PICTURE "@X" VALID(U_VldCdBr(cCodBarr)) SIZE 060,008 OF oDlgConf PIXEL

					@ 003,080 MSGET oCodLote VAR cCodLote PICTURE "@X" VALID(U_VldLote(cCodLote)) SIZE 060,008 OF oDlgConf PIXEL
					@ 003,210 SAY OemToAnsi("Cod.Barras ") SIZE 060,008 OF oDlgConf PIXEL

					@ 003,260 SAY cDescProd SIZE 300,10 OF oDlgConf PIXEL
					oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)

                    // Define o ListBox da Tela
					@ 020,120 LISTBOX oLbx FIELDS HEADER "Item"        ,;
					                                     "Cod.Produto" ,; 
					                                     "Descricao"   ,;
					                                     "Qtd.PV"      ,;
					                                     "Separado"    ,;
					                                     "Diferenca"   ,;
					                                     "Lote/Sublote",;
					                                     "Num.Serie"   ,;
					                                     "Local"       ,;
					                                     "."  SIZE 460,240 OF oDlgConf PIXEL
					
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
					
					@ 266,450 SAY OemToAnsi("Nบ Pedido: ") SIZE 060,008 OF oDlgConf PIXEL
                    cCodPedido := SEPARA->C5_NUM
					@ 265,480 MSGET oCodPedido VAR cCodPedido PICTURE "@X" When lChumba SIZE 029,009 OF oDlgConf PIXEL

					DEFINE SBUTTON FROM 265,510 TYPE 15 OF oDlgConf PIXEL ENABLE ACTION( ABRE_PEDIDO( SEPARA->C5_NUM ) )
					
                    @ 265,280 BUTTON "Saldo"       Size 40,12 ACTION (U_SALDOS(aLstBox[oLbx:nAt,2])) Of oDlgConf PIXEL
                    @ 265,325 BUTTON "Embalagem"   Size 40,12 ACTION (U_Embala(SEPARA->C5_NUM))   Of oDlgConf PIXEL
                    @ 265,370 BUTTON "Obs.Interna" Size 40,12 ACTION (OBSINTERNA(SEPARA->C5_NUM)) OF oDlgConf PIXEL

					DEFINE SBUTTON FROM 265,040 TYPE 01 WHEN lLibera ACTION (nOcb := 2 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE
					DEFINE SBUTTON FROM 265,070 TYPE 02              ACTION (nOcb := 0 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE

					ACTIVATE MSDIALOG oDlgConf Valid lClose CENTER
					
					If nOcb == 0
					   lLibera := .F.
					Endif   					
					
					If nOcb == 2

                        lLibera := .F.

					    DbSelectArea("CONF")
						DbGoTop()

						_cTipoC5  := "T"
						_cTipoCod := "U"
                        __Lacre   := ""
                        __Filial  := ""
                        						
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
							  DbSeek( xFilial("SC9") + SEPARA->C5_CLIENTE + SEPARA->C5_LOJACLI + SEPARA->C5_NUM + aLstBox[ _n, 1 ] )
							  IF EOF()
							 	ALERT("SC9 - Entre em contato com o Administrador ! Problema: Produto "+Alltrim( CONF->B1_COD )+" na rotina JPCACD01")
							 	Exit
							  ENDIF
							  Reclock( "SC9", .F. )
							  C9_BLEST := "  "
							  C9_BLWMS := "  "
							  MsUnlock()         
							  
							  // Jean Rehermann - Atualiza o Status do item no SC6
							  dbSelectArea("SC6")
							  dbSetOrder(1)
							  If dbSeek( xFilial("SC6") + SEPARA->C5_NUM + aLstBox[ _n, 1 ] )
							 	 RecLock("SC6",.F.)
                                    
                                 // A partir de 01/08/2012, se o produto vai ser lacrado na Automatech, passa para o status 09 tamb้m
                                 If (SC6->C6_TEMDOC == "S" .OR. SC6->C6_LACRE = "S") .And. SC6->C6_STATUS != "09"

								    SC6->C6_STATUS := "09" // Ag. Documenta็ใo cliente

								    U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "09", "JPCACD01(DOC)" ) // Gravo o log de atualiza็ใo de status na tabela ZZ0

                                    If Alltrim(SC6->C6_LACRE) == "S"                                            
                                       __Lacre += CONF->B1_CODBAR + " - " + Alltrim(SB1->B1_COD) + " - " + Alltrim(SB1->B1_DESC) + Alltrim(SB1->B1_DAUX) + chr(13) + chr(10)
                                       __Filial := xFilial("SC6")
                                    Endif   

								 ElseIf SC6->C6_TEMDOC != "S" .And. SC6->C6_STATUS != "10"

                                    If Alltrim(SC6->C6_LACRE) == "S"                                            

								 	   SC6->C6_TEMDOC := "S" // Jean Rehermann - 09/04/2013
								 	   SC6->C6_STATUS := "09" // Ag.cliente
									   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "09", "JPCACD01-LACRE" ) // Gravo o log de atualiza็ใo de status na tabela ZZ0

                                       // Carrega o nบ de s้rie para envio do e=mail ao vendedor
                                       __Lacre += CONF->B1_CODBAR + " - " + Alltrim(SB1->B1_COD) + " - " + Alltrim(SB1->B1_DESC) + Alltrim(SB1->B1_DAUX) + chr(13) + chr(10)
                                       __Filial := xFilial("SC6")

                                    Else

   								 	   SC6->C6_STATUS := "10" // Ag. Faturamento
									   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "10", "JPCACD01" ) // Gravo o log de atualiza็ใo de status na tabela ZZ0

                                    Endif   

								 EndIf

								 MsUnLock()

							  EndIf
						   Else
						 	  _cTipoC5 := "P"
						   Endif
							
						   // Jean Rehermann - Solutio IT - 25/07/2012 | Grava็ใo de Log da separa็ใo
						   GravaLogSep("S",_cTipoCod)
							
						   DbSelectArea("CONF")
						   DbSkip()
							
					    Enddo
						
                        // Se programa encontrou algum produto com Lacre == "S", envia e-mail ao vendedor
                        If !Empty(Alltrim(__Lacre))

                           // Pesquisa o e-mail do vendedor
                           If Select("T_EMAIL") > 0
                              T_EMAIL->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT A.C5_NUM  ,"
                           cSql += "       A.C5_VEND1,"
                           cSql += "       B.A3_NOME ,"
                           cSql += "       B.A3_EMAIL"
                           cSql += "  FROM " + RetSqlName("SC5") + " A, "
                           cSql += "       " + RetSqlName("SA3") + " B  "
                           cSql += " WHERE A.C5_NUM     = '" + Alltrim(SEPARA->C5_NUM) + "'"
                           cSql += "   AND A.C5_FILIAL  = '" + Alltrim(__Filial)       + "'"
                           cSql += "   AND A.D_E_L_E_T_ = ''"
                           cSql += "   AND A.C5_VEND1   = B.A3_COD"
                           cSql += "   AND B.D_E_L_E_T_ = ''"

                           cSql := ChangeQuery( cSql )
                           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMAIL", .T., .T. )

                           // Prepara o Corpo da mensagem do E-Mail
                           __Corpo := ""
                           __Corpo += "Prezado(a) " + Alltrim(T_EMAIL->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                                      "Abaixo segue rela็ใo do(s) nบ de Serie(s) do(s) produto(s) que serใo lacrado(s) na Automatech" + chr(13) + chr(10) + ;
                                      "referente ao seu Pedido de Venda Nบ " + Alltrim(SEPARA->C5_NUM) + " do Cliente " + ALLTRIM(SEPARA->A1_NREDUZ) + "." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                                      Alltrim(__Lacre) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                                      "Atenciosamente" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                                      "Departamento de Estoque"

                           U_AUTOMR20(__Corpo, Alltrim(T_EMAIL->A3_EMAIL),"", "Nบ de S้rie para produtos que serใo lacrados na Automatech" )

                        Endif

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
						
						// Jean Rehermann - Solutio IT - 25/07/2012 | Grava็ใo de Log do Update do C5_JPCSEP
						GravaLogSep("A","",SC5->C5_JPCSEP,_cTipoC5)
						
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
aAdd( aRotina, { "Visualizar", "A410Visual", 0, 2 } )

	
PRIVATE cCadastro := OemToAnsi("Atualiza็ใo de Pedidos de Venda")

DbSelectArea("SC5")
DbSeek( xFilial("SC5") + SEPARA->C5_NUM )
A410Visual()

RestArea(_aArea)
Return

// Pesquisa o Saldo do produto selecionado (F4)
User Function Saldos(_Codigo)

   MaViewSB2(_Codigo)
   
Return .T.   
User Function Embala(_Pedido)

   Private cPedVen := _Pedido
   Private oPedVen

   DEFINE MSDIALOG FASPedA TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 00,000 TO 100,230 OF oMainWnd Pixel Style DS_MODALFRAME
   
   @ 10,005 Say "Nr.do Pedido de Venda:"   OF FASPedA Pixel
   @ 10,070 MsGet oPedVen Var cPedVen F3 "SC5" PICTURE "@X" SIZE 040,010 OF FASPedA VALID ExistCpo("SC5",cPedVen) .and. empty(Posicione("SC5",1,xFilial("SC5")+cPedVen,"C5_NOTA"))  Pixel

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

   dEmissao  := SC5->C5_EMISSAO
   nPbruto 	 := SC5->C5_PBRUTO
   nPliq   	 := SC5->C5_PESOL 
   cEspecie	 := SC5->C5_ESPECI1
   cVolume 	 := SC5->C5_VOLUME1
   cTransp 	 := SC5->C5_TRANSP
   cCliente	 := SC5->C5_CLIENTE+SC5->C5_LOJACLI
   nValNot   := 0 //SC5->C5_VALBRUT
   cTpFrete  := SC5->C5_TPFRETE
// cObsNota  := SC5->C5_OBSNT
   cObsNota  := SC5->C5_MENNOTA
   cJpcSep   := IIF(EMPTY(SC5->C5_JPCSEP),"N",SC5->C5_JPCSEP)

   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek( xFilial("SA1") + cCliente)

   cCGC := ""
   cIE 	:= ""

   If !EOF()
      cCliente 	:= cCliente+" - "+SA1->A1_Nome
 	  cCGC 		:= SA1->A1_CGC
	  cIE 		:= SA1->A1_INSCR
   Endif

   DbSelectArea("SC5")

   DEFINE MSDIALOG FASPedB TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 000,000 TO 300,450 OF oMainWnd Pixel Style DS_MODALFRAME

   @ 010,010 Say "Nr.do Ped.Venda :" 			OF FASPedB	Pixel
   @ 010,070 say cPedVen						OF FASPedB	Pixel
   @ 010,095 SAY 'em '							OF FASPedB	Pixel
   @ 010,104 SAY dEmissao Picture '99/99/99' 	OF FASPedB	Pixel
   @ 017,010 Say "Cliente :"					OF FASPedB	Pixel
   @ 017,070 Say cCliente						OF FASPedB	Pixel
   @ 024,010 say "CGC-MF/IE : "				    OF FASPedB	Pixel
   @ 024,070 say cCGC+" / "+cIE				    OF FASPedB	Pixel
// @ 31,010 say "Valor da Nota : "+TRANSFORM(nValNot,"@e R$9,999,999.99")
   @ 042,010 Say "Peso Br: "					OF FASPedB	Pixel
   @ 042,070 MsGet nPbruto picture "@E 99999.99" SIZE 040,010 OF FASPedB	Pixel
   @ 054,010 Say "Peso Lq: "		   			OF FASPedB	Pixel
   @ 054,070 MsGet nPliq picture "@E 99999.99"	SIZE 040,010 OF FASPedB	Pixel
   @ 066,010 Say "Especie: "					OF FASPedB	Pixel
   @ 066,070 MsGet cEspecie					    SIZE 040,010 OF FASPedB	Pixel
   @ 078,010 Say "Volume.: "					OF FASPedB	Pixel
   @ 078,070 MsGet cVolume Picture "999999"		SIZE 040,010 OF FASPedB	Pixel
   @ 090,010 Say "Transpor.: "					OF FASPedB	Pixel
   @ 090,070 MsGet cTransp SIZE 040,010         VALID ExistCpo("SA4",cTransp) F3 "SA4" 	OF FASPedB	Pixel
   @ 102,010 Say "Tipo Frete:"					OF FASPedB	Pixel
   @ 102,070 COMBOBOX oCombo VAR cTpFrete       ITEMS { "C=CIF","F=FOB"} SIZE 40,7 OF FASPedB PIXEL
   @ 114,010 Say "Flag Separacao:"	 			OF FASPedB	Pixel
   @ 114,070 COMBOBOX oCombo VAR cJpcSep        ITEMS { "T=Total","P=Parcial","N=Nao Separado"} SIZE 80,7 OF FASPedB PIXEL

// @ 126,010 Say "Obs.DANFE"					OF FASPedB	Pixel
// @ 126,070 GET oMemo VAR cObsNota MEMO SIZE 205,100 PIXEL OF FASPedB VALID oMemo:Refresh()
   @ 126,010 Say "Msg. Nota"					OF FASPedB	Pixel
   @ 126,070 MsGet cObsNota Picture "@S60"		SIZE 120,010 OF FASPedB	Pixel

   @ 045,160  BUTTON "Gravar"   Size 50,12 ACTION FGrava()		                OF FASPedB	Pixel
   @ 060,160  BUTTON "Abandona" Size 50,12 ACTION close(FasPedb)               OF FASPedB	Pixel
   @ 075,160  BUTTON "Etiqueta" Size 50,12 ACTION U_AUTOMR13(cPedVen, cVolume) OF FASPedB	Pixel

   ACTIVATE DIALOG FasPedb CENTER

Return

// Fun็ใo que grava dos dados da tela de embalagem
Static Function FGrava()
    
	local _cJPCSEP := SC5->C5_JPCSEP

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
	
	// Jean Rehermann - Solutio IT - 25/07/2012 | Criado log para altera็ใo do C5_JPCSEP
	If cJpcSep != _cJPCSEP // Se foi alterado

		GravaLogSep("M", "", _cJPCSEP, cJpcSep)

	EndIf
	
	// Jean Rehermann - Se cancela a separa็ใo volta o status para 08-Aguardando Separa็ใo (verificando se item jแ nใo foi faturado)
	If cJpcSep == "N"
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek( SC5->C5_FILIAL + SC5->C5_NUM )
			While !Eof() .And. SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
				/*
				If !( SC6->C6_STATUS $ "08,11,12,13,14" ) .And. !U_Servico()
					RecLock("SC6",.F.)
						SC6->C6_STATUS := "08" // Ag. Sep. Estoque
						U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "08", "JPCACD01 (FGrava)" ) // Gravo o log de atualiza็ใo de status na tabela ZZ0
					MsUnLock()
				EndIf
				*/
				// Jean Rehermann - 26/11/2012 - Alterado avaliar apenas os itens que jแ estใo na loista de faturamento
				If SC6->C6_STATUS == "10" .And. !U_Servico()
					U_GravaSts("JPCACD01 (FGrava)")
				EndIf
				
				SC6->( dbSkip() )
			End
		EndIf
	EndIf

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
   Local cMsg        := "Problema no Codigo Lote/SLote/NSerie : '"+cCodLote+"'"+chr(13)+chr(10)

   Private lRetorno  := .t.
   Private _cTipoCod := "U"  //Undeffined
   Private _Botao    := 0

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
			Alert("Produto " + Alltrim(_cCodProd) + " com Controle de Enderecamento, mas Numero de Serie lido nใo ้ desse produto !")
		 Else
			lRetorno := .t.
		 Endif

         If Select("T_ARMAZEM") > 0
            T_ARMAZEM->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT BF_FILIAL ,"
         cSql += "       BF_PRODUTO,"
         cSql += "       BF_LOCAL  ,"
         cSql += "       BF_NUMSERI,"
         cSql += "       BF_QUANT  ,"
         cSql += "       BF_EMPENHO "
         cSql += "  FROM " + RetSqlName("SBF")
         cSql += " WHERE BF_NUMSERI = '" + Alltrim(cCodLote) + "'"
         cSql += "   AND BF_LOCAL   = '01'"
         cSql += "   AND BF_EMPENHO = 0   "
         cSql += "   AND D_E_L_E_T_ = ''  "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ARMAZEM", .T., .T. )

         If T_ARMAZEM->( EOF() )
            MsgAlert("Endere็amento nใo encontrado para este Nบ de S้rie/Armaz้m.")
			lRetorno := .F.
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
			   //IF (SB2->B2_QATU - SB2->B2_QEMP) <= 0
			   //	lRetorno := .f.
			   //	cMsg += "Produto "+cCodLote+" sem Saldo Disponivel "+chr(13)+chr(10)
			   //ELSE
					cDescProd := SB1->B1_COD + " : " + SB1->B1_DESC
					cCodProd  := SB1->B1_COD
			   //ENDIF
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
				Else
 				   _nQCodP := 1
				   _Botao  := _JPCGQTD()

                   If _Botao == 2
 				      _nQCodP := 0                   
 				   Endif   
				Endif
		        _XFor := _nQCodP
//		        _XFor := iif(_nQCodP>0,_nQCodP,1) // Gerson - _nQCodP alimentado em GetlBox(p1)p/produtos _cTipoCod == "P"
				For _nX := 1 to _XFor
					Reclock("CONF",.t.)
					CONF->B1_CODBAR := cCodLote
					CONF->B1_COD    := _cCodProd
					CONF->(MsUnlock())
				Next
				DbGoTop()
				oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
				//@ 015,010 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL
			    If _XFor > 0
				U_GetlBox("ATUAL")	// Atualiza o ListBox
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

   cCodLote := Space(20)
   oLbx:Refresh()

   DbSelectArea("CONF")

   // ------------------------------------------ //
   // Regra para liberar o botใo OK na Separa็ใo //
   // Se Diferen็a  == 0, Libera                 //
   // Se Qtd. do PV == Diferen็a, Libera         //
   // ------------------------------------------ //
//   If Type("_nPosAlst") <> "U"
//      If aLstBox[_nPosAlst,6] == 0 .OR. (aLstBox[_nPosAlst,4] == aLstBox[_nPosAlst,6])
//         lLibera := .T.
//      Else
//         lLibera := .F.   
//      Endif   
//   Endif   

   // Verifica se pode liberar o botใo de OK da tela de separa็ใo
   lLibera := .T.

   For nContar = 1 to Len(aLstBox)
       If aLstBox[nContar,04] <> aLstBox[nContar,05]
          lLibera := .F.
          Exit
       Endif
   Next nContar      

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

   Local lRet     := .t.
   Local _nQtd    := 0	// JPC Gerson - 16.06.11
   Local _xpedido := Space(06)   

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
Static Function GeraArq()

	Local lRetorno  := .t.
	Local cQuery    := ""
	Local _cArqC1   := ""
    Local cTranspo  := ""
	
	_aArqC1   := {}
	aHeader   := {}
	
	cQuery := " SELECT SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA1.A1_NREDUZ, SA1.A1_MUNE, SA1.A1_BAIRRO, SA1.A1_TEL, SC5.C5_TRANSP "+CHR(13)
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "+CHR(13)
	cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA "+CHR(13)
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO <>'B' "+CHR(13)
	cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' '  OR SC5.C5_JPCSEP = 'P') "+CHR(13)
	//Jean Rehermann - Inserida a condi็ใo de s๓ aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens
	If cPedAtu == "P"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') <> "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	ElseIf cPedAtu == "T"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') = "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	Else
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	EndIf
	
	cQuery += " UNION "+CHR(13)
	
	cQuery += " SELECT SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA2.A2_NREDUZ, SA2.A2_MUN, SA2.A2_BAIRRO, SA2.A2_TEL, SC5.C5_TRANSP  "+CHR(13)
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA2")+" SA2 "+CHR(13)
	cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA2.A2_COD AND SC5.C5_LOJACLI = SA2.A2_LOJA "+CHR(13)
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO = 'B' "+CHR(13)
	cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' ' OR SC5.C5_JPCSEP = 'P')"+CHR(13)
	//Jean Rehermann - Inserida a condi็ใo de s๓ aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens
	If cPedAtu == "P"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') <> "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	ElseIf cPedAtu == "T"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') = "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	Else
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	EndIf
	
	Memowrite("JPCACD01.SQL", cQuery)
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	
	If !TRB->( Eof() )
	
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
//		AADD(aHeader,{"Mun.Entrega" 	,"A1_MUNE"   ,"@X" ,30,0,".t.",USADO,"C","",""})
 		AADD(aHeader,{"Transportada" 	,"A1_MUNE"   ,"@X" ,30,0,".t.",USADO,"C","",""})
		AADD(aHeader,{"Bairro"     		,"A1_BAIRRO" ,"@X" ,30,0,".t.",USADO,"C","",""})
		AADD(aHeader,{"Telefone"  		,"A1_TEL"	 ,"@X" ,15,0,".t.",USADO,"C","",""})

		// Arquivo Auxiliar para Consultas
		_cArqC1 := CriaTrab(_aArqC1,.T.)
		dbUseArea(.T.,,_cArqC1,"SEPARA")
		Index on C5_NUM to &_cArqC1
	
		nPosic := 1
		Do While !TRB->( EOF() )
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

                // Pesquisa a Transportadora
                DbSelectArea("SA4")
                DbSetOrder(1)
                If DbSeek( xFilial("SA4") + TRB->C5_TRANSP )
                   cTranspo := SA4->A4_NOME
                Else
                   cTranspo := ""
                Endif

				RecLock("SEPARA",.T.)
				C5_NUM 		:= TRB->C5_NUM
				C5_CLIENTE  := TRB->C5_CLIENTE
				C5_LOJACLI 	:= TRB->C5_LOJACLI
				A1_NREDUZ	:= TRB->A1_NREDUZ
//				A1_MUNE 	:= TRB->A1_MUNE
				A1_MUNE 	:= cTranspo
				A1_BAIRRO	:= TRB->A1_BAIRRO
				A1_TEL      := TRB->A1_TEL
				MsUnlock()
			ENDIF
			dbSelectArea("TRB")
			dbSkip()
		Enddo
		
	Else
		MsgStop(" Nao foram encontrados mais pedidos para Separacao ! ")
		lRetorno := .f.
	Endif
	
	TRB->(dbCloseArea())

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
    // Jean Rehermann | JPC - Apenas aparece para separar o item que tiver status 08-Aguardando Separa็ใo de Estoque
    IF SF4->F4_ESTOQUE == "S" .And. SC6->C6_STATUS == "08"
	   aAdd(aLstBox,{PEDSEP->C9_ITEM,PEDSEP->C9_PRODUTO, PEDSEP->B1_DESC   , PEDSEP->C9_QTDLIB , 0 , ;
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
Static Function JPCGQTD(_nQtd, _xPedido)

   DEFAULT _nQtd	:= 1.00
   DEFAULT _xPedido := Space(06)

   DEFINE MSDIALOG oDlg1 TITLE "Informe a quantidade" FROM 33,25 TO 110,349 PIXEL  

   @ 01,05 TO 033, 128 OF oDlg1 PIXEL

//   @ 08,08 SAY "Quantidade" SIZE 55, 7 OF oDlg1 PIXEL  
//   @ 08,80 SAY "Nบ Pedido"  SIZE 55, 7 OF oDlg1 PIXEL  
//   @ 18,80 MSGET _xPedido SIZE 40, 11 OF oDlg1 PIXEL Picture "@!"
//   @ 18,08 MSGET _nQtd SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15) VALID ;
//                 !empty(iif(_nQtd > SaldoSb2() .or. _nQtd <> aLstBox[_nPosAlst,4]  ,eval({|| Help ( " ", 1, "SLDSB2/SALDO A SEPARAR" ),0}),_nQtd))

   @ 08,08 SAY "Nบ Pedido"  SIZE 55, 7 OF oDlg1 PIXEL  
   @ 08,60 SAY "Quantidade" SIZE 55, 7 OF oDlg1 PIXEL  

   @ 18,08 MSGET _xPedido SIZE 40, 11 OF oDlg1 PIXEL Picture "@!" VALID CONFPEDIDO(_xPedido)
   @ 18,60 MSGET _nQtd    SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15) VALID ;
                          !empty(iif(_nQtd > SaldoSb2() .or. _nQtd <> aLstBox[_nPosAlst,4]  ,eval({|| Help ( " ", 1, "SLDSB2/SALDO A SEPARAR" ),0}),_nQtd))

   // aLstBox[_nPosAlst,4] eh a posicao da quantidade a ser separada, nao permite digitar quantidade maior que o solicitado, tambem valida o saldosb2	

   DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End())            ENABLE OF oDlg1
   DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End(),_nQtd := 0) ENABLE OF oDlg1                                                                                                

   ACTIVATE MSDIALOG oDlg1 CENTERED
		
Return _nQtd

// Fun็ใo que abre Janela para informa็ใo do nบ do pedido de venda na separa็ใo para produto com nบ de s้rie
Static Function _JPCGQTD(_xPedido)

   DEFAULT _xPedido := Space(06)

   DEFINE MSDIALOG oDlg1 TITLE "Informe o Nบ do Pedido de Venda" FROM 33,25 TO 110,349 PIXEL  

   @ 01,05 TO 033, 128 OF oDlg1 PIXEL

   @ 08,08 SAY "Nบ Pedido"  SIZE 55, 7 OF oDlg1 PIXEL  

   @ 18,08 MSGET _xPedido SIZE 40, 11 OF oDlg1 PIXEL Picture "@!" VALID CONFPEDIDO(_xPedido)

   DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1, _Botao := 1, oDlg1:End()) ENABLE OF oDlg1
   DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0, _Botao := 2, oDlg1:End()) ENABLE OF oDlg1

   ACTIVATE MSDIALOG oDlg1 CENTERED
		
Return _Botao

// Harald Hans L๖schenkohl - Verifica se o produto pertence ao pedido lido pelo c๓digo de barras
Static Function CONFPEDIDO(___Pedido)

   If Empty(Alltrim(___Pedido))
      Return .F.
   Endif
   
   If Alltrim(___Pedido) <> Alltrim(SEPARA->C5_NUM)
      MsgAlert("Pedido Invแlido.")
      Return .F.
   Endif
   
Return .T.

// Jean Rehermann - Acionado pelo botใo Parโmetros na tela da separa็ใo
// Serve para atualizar o campo C6_TEMDOC, controla necessidade de recebimento de documento antes de liberar o item
Static Function StsDoc()

	Local cFiltros := "C6_TEMDOC<>'R' AND C6_STATUS NOT IN ('11','12')"
	
	Local aCores := {{"C6_TEMDOC=='S'",'ENABLE' },; // Aguardando cliente
					{ "C6_TEMDOC$' N'",'DISABLE'}}  // Nใo aguarda cliente

	Private cCadastro := "Libera็ใo de documenta็ใo"
	Private cAlias1   := "SC6"
	Private aCampos   := {{"Pedido","C6_NUM"},;
						  {"Item","C6_ITEM"},;
						  {"Status","C6_STATUS"},;
						  {"Produto","C6_PRODUTO"},;
						  {"Descri็ใo","C6_DESCRI"},;
						  {"Quantidade","C6_QTDVEN"},;
						  {"Unitแrio","C6_PRCVEN"},;
						  {"Total","C6_VALOR"} }

	Private aHeader := {}, aCols := {}
	
	Private aRotina   := {	{ "Pesquisar", "AxPesqui" , 0, 1 },;
							{ "Documento", "U_StsDocL", 0, 2 },;
	                        { "Lengenda" , "U_LegDoc" , 0, 2 } }

	Private cDelFunc := ".T." // Criar rotina para validar a exclusao (locacao em aberto nใo pode ser excluida)

	mBrowse( 06, 01, 22, 75, "SC6",aCampos,,,,,aCores,,,,,.F.,,,cFiltros)

Return

// Programa para mostrar a legenda de cores (status)
User Function LegDoc()
	BrwLegenda(cCadastro, 'Legenda', {{'ENABLE' ,    'Aguardando documenta็ใo do cliente'},;
        	                          {'DISABLE',    'Nใo aguarda documenta็ใo do cliente'}})
Return( nil )

// Jean Rehermann - Efetua a altera็ใo do status, se necesแrio
User Function StsDocL()

	Private cDoc := Iif( Empty( AllTrim( SC6->C6_TEMDOC ) ), "N", SC6->C6_TEMDOC )
	Private oDoc
	
	DEFINE MSDIALOG oDlgStsDoc TITLE "Aguarda documenta็ใo do cliente?" From 00,000 TO 100,230 OF oMainWnd Pixel Style DS_MODALFRAME
		@ 12,010 Say "Documenta็ใo:" OF oDlgStsDoc Pixel
		@ 10,050 ComboBox oDoc Var cDoc ITEMS { "N=Nใo","S=Sim","R=Recebido"} SIZE 040,010 OF oDlgStsDoc Pixel
		DEFINE SBUTTON FROM 30,010 TYPE 01 ACTION (GrvStsDoc())	    OF oDlgStsDoc ENABLE Pixel
		DEFINE SBUTTON FROM 30,040 TYPE 02 ACTION (Close(oDlgStsDoc))	OF oDlgStsDoc ENABLE Pixel
	ACTIVATE DIALOG oDlgStsDoc CENTER

Return()

// Jean Rehermann - Grava a op็ใo no item do pedido e altera o status se necessแrio
Static Function GrvStsDoc()

	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek( xFilial("SC6") + SC6->C6_NUM + SC6->C6_ITEM )
	
	dbSelectArea("SC6")
	
	RecLock("SC6", .F.)
		SC6->C6_TEMDOC := cDoc
	
		If cDoc == "S"
			// Jean Rehermann - 16/07/2012 - Independente de qual status sempre fica aguardando o cliente
			//If SC6->C6_STATUS == "10"  // Aguardando Faturamento
				SC6->C6_STATUS := "09" // Aguardando Documenta็ใo cliente
				U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "09", "JPCACD01-DOC" ) // Gravo o log de atualiza็ใo de status na tabela ZZ0
			//EndIf
		ElseIf cDoc $ "NR "
			If SC6->C6_STATUS == "09"  // Aguardando Documenta็ใo cliente
				// Jean Rehermann - 16/07/2012 - Atualiza o status analisando a situa็ใo atual do pedido
				//SC6->C6_STATUS := "10" // Aguardando Faturamento
				//U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "10", "JPCACD01" ) // Gravo o log de atualiza็ใo de status na tabela ZZ0
				U_GravaSts("JPCACD01-DOC")
			EndIf
		EndIf
	MsUnLock()
	Close(oDlgStsDoc)
	
Return()

//Jean Rehermann - Seleciona o PV para gravar dados do embarque
User Function Embarque()

	Private cNumNF := Space(9)
	Private oNumNf
	Private cSerNF := Space(3)
	Private oSerNf
	
	DEFINE MSDIALOG FASPedA TITLE "Expedi็ใo de Mercadoria" From 00,000 TO 100,220 OF oMainWnd Pixel Style DS_MODALFRAME

    @ 030,065 BUTTON "Consulta"  Size 40,11 ACTION (MostraCan()) OF FasPedA PIXEL
	@ 10,005 Say "Nota Fiscal:"   OF FASPedA Pixel
	@ 10,040 MsGet oNumNf Var cNumNF PICTURE "@X" SIZE 040,010 OF FASPedA Pixel F3 "SF2EMB" VALID !Empty( cNumNF )
	@ 10,085 MsGet oSerNf Var cSerNF PICTURE "@X" SIZE 020,010 OF FASPedA Pixel

	DEFINE SBUTTON FROM 30,005 TYPE 01 ACTION (FConfEmb())	    OF FasPedA ENABLE Pixel
	DEFINE SBUTTON FROM 30,035 TYPE 02 ACTION (Close(FasPedA))	OF FasPedA ENABLE Pixel

	ACTIVATE DIALOG FasPedA CENTER

Return

// Jean Rehermann - Inserir os dados do embarque
Static Function FConfEmb()

	Private _cHora := Time()
	Private _cNumF := Space(90)
	Private _aAreaSEP := SEPARA->( GetArea() )
	
	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek( xFilial("SF2") + cNumNF + cSerNF )

   	   If Empty( AllTrim( SF2->F2_CONHECI ) )

          _cHora := SF2->F2_HREXPED
          _cNumF := SF2->F2_CONHECI

		  DbSelectArea("SD2")
		  DbSetOrder(3)
		  DbSeek( xFilial("SD2") + cNumNF + cSerNF )
		
		  DbSelectArea("SC5")
		  DbSetOrder(1)
		  DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

		  DEFINE MSDIALOG FASPedB TITLE "Dados de Expedi็ใo" From 000,000 TO 150,400 OF oMainWnd Pixel Style DS_MODALFRAME

		  @ 010,010 Say "Nr.do Ped.Venda :"                   OF FASPedB Pixel
		  @ 010,070 say SD2->D2_PEDIDO                        OF FASPedB Pixel
		  @ 020,010 Say "Nr. Nota Fiscal :"                   OF FASPedB Pixel
		  @ 020,070 say cNumNF +"/"+ cSerNf                   OF FASPedB Pixel
		  @ 037,010 Say "Hora: "                              OF FASPedB Pixel
		  @ 037,070 MsGet _cHora Picture "99:99" SIZE 040,010 OF FASPedB Pixel
		  @ 049,010 Say "Nบ Conhecimento: "                   OF FASPedB Pixel
		  @ 049,070 MsGet _cNumF Picture "!@"	   SIZE 070,010 OF FASPedB Pixel
		
		  @ 005,145  BUTTON "Etiqueta" Size 50,12 ACTION E_Etiqueta(SC5->C5_VOLUME1, SD2->D2_PEDIDO, cNumNF, cSerNF) OF FASPedB Pixel
		
		  @ 033,145  BUTTON "Gravar"   Size 50,12 ACTION FGravaJ()      OF FASPedB Pixel
		  @ 048,145  BUTTON "Abandona" Size 50,12 ACTION close(FasPedb) OF FASPedB Pixel
		
		  ACTIVATE DIALOG FasPedb CENTER

 	   Else

 	      MsgAlert("Nota fiscal jแ expedida!" + chr(13) + "Horas: " + SF2->F2_HREXPED + CHR(13) + "Conhecimento: " + Alltrim(SF2->F2_CONHECI))
  	  
  	  EndIf
 	
 	  RestArea( _aAreaSEP )
 	  
   Else
   
      MsgAlert("Nota Fiscal inexistente.")
   
   Endif	  
 	
Return

// Jean Rehermann - Grava os dados de embarque
Static Function FGravaJ()

	Local _cItens := ""

	RecLock("SF2",.F.)
		F2_HREXPED := _cHora
		F2_CONHECI := _cNumF
	MsUnlock()
	
	dbSelectArea("SD2")
	dbSetOrder(3)
	If dbSeek( xFilial("SD2") + cNumNF + cSerNF )
		While !SD2->( Eof() ) .And. xFilial("SD2") == SD2->D2_FILIAL .And. SD2->D2_DOC == cNumNF .And. SD2->D2_SERIE == cSerNf
			
			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek( xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV )
				RecLock("SC6",.F.)
					C6_STATUS := "12" // Expedido
					U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "12", "JPCACD01") // Gravo o log de atualiza็ใo de status na tabela ZZ0
					_cItens += SC6->C6_ITEM + "|"
				MsUnLock()
			EndIf

			SD2->( dbSkip() )
		End

		If !Empty( AllTrim( _cItens ) )
			U_MailSts( SC5->C5_NUM, SubStr( _cItens, 1, Len( _cItens ) - 1 ), "E" ) // Envio de e-mail
		EndIf

	EndIf
	
	Close( FasPedb )
	
Return

/*
Jean Rehermann - Atualiza o arquivo de trabalho da tela principal
*/
Static Function AtuArq()

	Local cQuery    := ""
	Local nRecCount := 0
	
	DbSelectArea("SEPARA")
	dbGoTop()
	While !Eof()
		RecLock("SEPARA",.F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	End
	
	cQuery := " SELECT SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA1.A1_NREDUZ, SA1.A1_MUNE, SA1.A1_BAIRRO, SA1.A1_TEL, SC5.C5_TRANSP "+CHR(13)
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "+CHR(13)
	cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA "+CHR(13)
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO <>'B' "+CHR(13)
	cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' '  OR SC5.C5_JPCSEP = 'P') "+CHR(13)
	//Jean Rehermann - Inserida a condi็ใo de s๓ aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens
	If cPedAtu == "P"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') <> "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	ElseIf cPedAtu == "T"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') = "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	Else
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	EndIf
	
	cQuery += " UNION "+CHR(13)

	cQuery += " SELECT SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA2.A2_NREDUZ, SA2.A2_MUN, SA2.A2_BAIRRO, SA2.A2_TEL, SC5.C5_TRANSP  "+CHR(13)
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA2")+" SA2 "+CHR(13)
	cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA2.A2_COD AND SC5.C5_LOJACLI = SA2.A2_LOJA "+CHR(13)
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO = 'B' "+CHR(13)
	cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' ' OR SC5.C5_JPCSEP = 'P')"+CHR(13)
	//Jean Rehermann - Inserida a condi็ใo de s๓ aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens
	If cPedAtu == "P"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') <> "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	ElseIf cPedAtu == "T"
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ') = "+CHR(13)
		cQuery += " ( (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') + "+CHR(13)
		cQuery += " (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS IN ('10','11','12','13') ) )"+CHR(13)
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	Else
		cQuery += " AND (SELECT COUNT(*) TOT FROM "+ RetSqlName("SC6") +" WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND D_E_L_E_T_ = ' ' AND C6_STATUS = '08') > 0 "+CHR(13)
	EndIf

	Memowrite("JPCACD01.SQL", cQuery)
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"T_C5", .F., .T.)

	If !T_C5->( Eof() )
	
		Do While !T_C5->( Eof() )
			DbSelectArea("SC9")
			DbSetOrder(1)
			DbSeek( xFilial("SC9") + T_C5->C5_NUM )
			lTemCred := .F.
			Do While !Eof() .And. xFilial("SC9") + T_C5->C5_NUM == SC9->C9_FILIAL + SC9->C9_PEDIDO
			    If AllTrim( SC9->C9_BLCRED ) == ""
			       lTemCred := .T.
			    EndIf
				SC9->( dbSkip() )
			Enddo   

			If lTemCred

                // Pesquisa a Transportadora
                DbSelectArea("SA4")
                DbSetOrder(1)
                If DbSeek( xFilial("SA4") + T_C5->C5_TRANSP )
                   cTranspo := SA4->A4_NOME
                Else
                   cTranspo := ""
                Endif

				RecLock( "SEPARA", .T. )
					SEPARA->C5_NUM 		:= T_C5->C5_NUM
					SEPARA->C5_CLIENTE  := T_C5->C5_CLIENTE
					SEPARA->C5_LOJACLI 	:= T_C5->C5_LOJACLI
					SEPARA->A1_NREDUZ	:= T_C5->A1_NREDUZ
//  				SEPARA->A1_MUNE 	:= T_C5->A1_MUNE
    				SEPARA->A1_MUNE 	:= cTranspo
					SEPARA->A1_BAIRRO	:= T_C5->A1_BAIRRO
					SEPARA->A1_TEL      := T_C5->A1_TEL
				MsUnlock()
			EndIf
			T_C5->( dbSkip() )
		Enddo

	Else
		RecLock( "SEPARA", .T. )
			SEPARA->C5_NUM 		:= ""
			SEPARA->C5_CLIENTE  := ""
			SEPARA->C5_LOJACLI 	:= ""
			SEPARA->A1_NREDUZ	:= ""
			SEPARA->A1_MUNE 	:= ""
			SEPARA->A1_BAIRRO	:= ""
			SEPARA->A1_TEL      := ""
		MsUnlock()

		MsgStop(" Nao foram encontrados mais pedidos para Separacao ! ")
	Endif

	DbSelectArea("SEPARA")
	dbGoTop()
	oGetDb1:Refresh()
	T_C5->( dbCloseArea() )

Return

// Harald Hans L๖schnekohl - Emissใo de Etiquetas
Static Function E_Etiqueta(_Volumes, _Pedido, _cNumNF, _cSerNF)

   // Variaveis Locais da Funcao
   Local oGet1

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}
   
   // Variaveis Private da Fun็ใo

   Private aComboBx1 := {,"LPT1","LPT2","COM1","COM2","COM3","COM4","COM5","COM6"}
   Private cComboBx1 := "LPT1"
   Private nGet1	 := Alltrim(Str(_Volumes))

   // Diแlogo Princial
   Private oDlg_E

   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG oDlg_E TITLE "Automatech - Impressใo de Etiqueta Expedi็ใo" FROM C(178),C(181) TO C(300),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(012),C(010) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg_E
   @ C(027),C(010) Say "Porta de Impressใo:"      Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg_E

   @ C(010),C(060) MsGet oGet1 Var nGet1          Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg_E
   @ C(026),C(060) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg_E

   DEFINE SBUTTON FROM C(40),C(010) TYPE 6  ENABLE OF oDlg_E ACTION( ETQ_EXPEDICAO(nGet1,cCombobx1,_Pedido,_cNumNF, _cSerNF)  )
   DEFINE SBUTTON FROM C(40),C(035) TYPE 20 ENABLE OF oDlg_E ACTION( odlg_E:end() )

   ACTIVATE MSDIALOG oDlg_E CENTERED  

Return(.T.)

// Fun็ใo que Imprime a Etiqueta de Expedi็ใo
Static Function ETQ_EXPEDICAO(nGet1, cPorta, _Pedido, _cNumNF, _cSerNF)

   Local cPorta      := cPorta
   Local nQtetq      := val(nGet1)
   Local cSql        := ""
   Local cCliente    := ""
   Local cCidade     := ""
   Local cTransporte := ""
   Local cFantasia   := ""
   Local nEt         := 0
   Local cNota       := _cNumNF
   Local cSerie      := _cSerNF

   IF nQtetq == 0
      MsgAlert("Quantidade de Etiquetas a serem impressas nใo informada.")
      Return .T.
   Endif
       
   // Pesquisa O tipo de pedido de venda
   If Select("T_TIPOPV") > 0
      T_TIPOPV->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C5_TIPO"
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_NUM       = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND C5_FILIAL    = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPOPV", .T., .T. )

   // Pesquisa os dados a serem impressos
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   If T_TIPOPV->C5_TIPO == "N"
      cSql := ""
      cSql := "SELECT A.C5_CLIENTE, A.C5_LOJACLI, A.C5_TRANSP , A.C5_TIPO   ,"
      cSql += "       B.A1_NOME   , B.A1_MUN    , B.A1_EST    , B.A1_NREDUZ ,"
      cSql += "       C.A4_NOME   , C.A4_NREDUZ "   
      cSql += "  FROM " + RetSqlName("SC5") + " A, "
      cSql += "       " + RetSqlName("SA1") + " B, " 
      cSql += "       " + RetSqlName("SA4") + " C  "
      cSql += " WHERE A.C5_NUM       = '" + Alltrim(_Pedido) + "'"
      cSql += "   AND A.C5_FILIAL    = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''"
      cSql += "   AND A.C5_CLIENTE   = B.A1_COD "
      cSql += "   AND A.C5_LOJACLI   = B.A1_LOJA"
      cSql += "   AND A.C5_TRANSP    = C.A4_COD "
   Else
      cSql := ""
      cSql := "SELECT A.C5_CLIENTE, A.C5_LOJACLI, A.C5_TRANSP , A.C5_TIPO   ,"
      cSql += "       B.A2_NOME   , B.A2_MUN    , B.A2_EST    , B.A2_NREDUZ ,"
      cSql += "       C.A4_NOME   , C.A4_NREDUZ "   
      cSql += "  FROM " + RetSqlName("SC5") + " A, "
      cSql += "       " + RetSqlName("SA2") + " B, " 
      cSql += "       " + RetSqlName("SA4") + " C  "
      cSql += " WHERE A.C5_NUM       = '" + Alltrim(_Pedido) + "'"
      cSql += "   AND A.C5_FILIAL    = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''"
      cSql += "   AND A.C5_CLIENTE   = B.A2_COD "
      cSql += "   AND A.C5_LOJACLI   = B.A2_LOJA"
      cSql += "   AND A.C5_TRANSP    = C.A4_COD "
   Endif      

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_TIPOPV->C5_TIPO == "N"
      cCliente    := Alltrim(T_DADOS->A1_NOME)
      cCidade     := Alltrim(T_DADOS->A1_MUN) + "/" + Alltrim(T_DADOS->A1_EST)
      cTransporte := Alltrim(T_DADOS->A4_NOME)
      cFantasia   := Alltrim(T_DADOS->A4_NREDUZ)
   Else
      cCliente    := Alltrim(T_DADOS->A2_NOME)
      cCidade     := Alltrim(T_DADOS->A2_MUN) + "/" + Alltrim(T_DADOS->A2_EST)
      cTransporte := Alltrim(T_DADOS->A4_NOME)
      cFantasia   := Alltrim(T_DADOS->A4_NREDUZ)
   Endif      

   // Tipo de Impressoras supotadas pelo comando MSCBPRINTER
   // Zebra: S400
   // Zebra: S600
   // Zebra: S500-6
   // Zebra: Z105S-6
   // Zebra: Z16S-6
   // Zebra: S300
   // Zebra: S500-8
   // Zebra: Z105S-8
   // Zebra: Z160S-8
   // Zebra: Z140XI
   // Zebra: Z90XI
   // Zebra: Z170ZI.
   // ALLEGRO
   // PRODIGY
   // DMX 
   // DESTINY
   // ELTRON 
   // ARGOX

   // Imprime as Etiquetas
   For nEt := 1 to nQtetq 

       _Serie := Alltrim(cSerie)

       Do Case
          Case Len(Alltrim(cSerie)) == 1
               _Serie := "00" + Alltrim(cSerie)
          Case Len(Alltrim(cSerie)) == 2
               _Serie := "0" + Alltrim(cSerie)
          OtherWise
               _Serie := Alltrim(cSerie)
       EndCase              

       MSCBPRINTER("S600",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE("^XA" + chr(13))
//     MSCBWRITE("~SD18" + chr(13))
       MSCBWRITE("^FT470,020^XGlogoe.GRF,1,1^FS" + chr(13))
       MSCBWRITE("^FO126,505^XGR:DB1,1,1^FS" + chr(13))
       MSCBWRITE("^FO282,30^XGR:DB2,1,1^FS"  + chr(13))
       MSCBWRITE("^FO122,28^XGR:DB3,1,1^FS"  + chr(13))
       MSCBWRITE("^FO10,162^BY4,3.0^BCR,83,N,N,N,N^FD" + Alltrim(cNota) + _Serie + Alltrim(Strzero(nEt,2)) + "^FS" + chr(13))
       MSCBWRITE("^FO128,632^AGR,120,40^FD" + Strzero(nEt,2) + "/" + Strzero(nQtetq,2) + "^FS"  + chr(13))
       MSCBWRITE("^FO128,102^AGR,120,40^FD" + Alltrim(cNota) + "^FS"  + chr(13))
       MSCBWRITE("^FO256,690^ACR,18,10^FDVOLUMES:^FS"  + chr(13))
       MSCBWRITE("^FO238,690^ACR,18,10^FD^FS"  + chr(13))
       MSCBWRITE("^FO257,184^ACR,18,10^FDNOTA FISCAL:^FS"  + chr(13))
       MSCBWRITE("^FO295,48^ACR,18,10^FD^FS"  + chr(13))

       MSCBWRITE("^FO442,50^ABR,11,7^FDTRANSP.:^FS"  + chr(13))
       MSCBWRITE("^FO313,48^ACR,18,10^FDCLIENTE:^FS" + chr(13))
       MSCBWRITE("^FO382,50^ABR,11,7^FDCIDADE:^FS"   + chr(13))

       MSCBWRITE("^FO429,50^ABR,11,7^FD^FS"  + chr(13))

       If Empty(Alltrim(cFantasia))
          MSCBWRITE("^FO416,157^AUR,52,80^FD" + Alltrim(Substr(cTransporte,01,28)) + "^FS" + CHR(13))
       Else
          MSCBWRITE("^FO416,157^AUR,52,80^FD" + Alltrim(Substr(cFantasia,01,28))   + "^FS" + CHR(13))
       Endif
                    
       MSCBWRITE("^FO294,157^ACR,36,20^FD" + Alltrim(Substr(cCliente,01,28))    + "^FS" + chr(13))
       MSCBWRITE("^FO355,157^ACR,36,20^FD" + Alltrim(cCidade)                   + "^FS" + chr(13))       
       MSCBWRITE("^FO475,30^XGR:DB15,1,1^FS" + CHR(13))
       MSCBWRITE("^FO510,465^ARR,18,10^FDAutomatech Sistemas de Automacao Ltda^FS" + CHR(13))
       MSCBWRITE("^FO480,562^ARR,18,10^FDwww.automatech.com.br^FS" + CHR(13))
       MSCBWRITE("^PQ1,1,0,Y^FS" + CHR(13))
       MSCBWRITE("^XZ" + CHR(13))
       MSCBEND()
       MSCBCLOSEPRINTER()

   Next nEtq
   
Return .T.

//Harald Hans L๖schenkohl - Realiza a Consulta das Expedi็๕es
Static Function MostraCan()

   Private dData01 := Ctod("  /  /    ")
   Private dData02 := Ctod("  /  /    ")
   Private nGet1   := Ctod("  /  /    ")                                       
   Private nGet2   := Ctod("  /  /    ")

   Private aBrowse := {}

   DEFINE MSDIALOG DLG_Exp TITLE "Automatech - Impressใo de Etiqueta Expedi็ใo" FROM C(005),C(060) TO C(300),C(670) PIXEL

   @ C(007),C(010) Say "Data de Emissใo de" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF DLG_Exp
   @ C(007),C(090) Say "At้"                Size C(050),C(020) COLOR CLR_BLACK PIXEL OF DLG_Exp

   @ C(005),C(050) MsGet oGet1  Var dData01 Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF Dlg_Exp
   @ C(005),C(100) MsGet oGet2  Var dData02 Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF Dlg_Exp

   @ 007,250 BUTTON "Pesquisar" Size 40,11 ACTION( BuscaExpedicao( dData01, dData02 ) )OF DLG_Exp PIXEL
   @ 007,300 BUTTON "Voltar"    Size 40,11 ACTION( DLG_Exp:end() )   OF DLG_Exp PIXEL

   oBrowse := TSBrowse():New(030,005,380,150,Dlg_Exp,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Pedido',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Clientes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Emissใo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('N.Fiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('S้rie',,,{|| },{|| }) )   
   oBrowse:AddColumn( TCColumn():New('Vendedor Principal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Transportadora',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora',,,{|| },{|| }) )   
   oBrowse:SetArray(aBrowse)

   ACTIVATE DIALOG DLG_Exp CENTER

Return

//Harald Hans L๖schenkohl - Resaliza a pesquisa das expedi็๕es
Static Function BuscaExpedicao( dData01, dData02 )

   Private aBrowse := {}
   
   If Empty(dData01)
      MsgAlert("Data inicial de Emissใo nใo informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de Emissใo nใo informada.")
      Return .T.
   Endif

   If dData01 > dData02
      MsgAlert("Datas inconsistentes.")
      Return .T.
   Endif

   // Limpa o Grid
   oBrowse := TSBrowse():New(030,005,380,150,Dlg_Exp,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Pedido',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Clientes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Emissใo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('N.Fiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('S้rie',,,{|| },{|| }) )   
   oBrowse:AddColumn( TCColumn():New('Vendedor Principal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Transportadora',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora',,,{|| },{|| }) )   
   oBrowse:SetArray(aBrowse)

   // Pesquisa os dados para popular o gid
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT E.C5_NUM    ,"
   csql += "       A.F2_FILIAL ,"
   csql += "       A.F2_DOC    ,"
   csql += "       A.F2_SERIE  ,"
   csql += "       A.F2_EMISSAO,"
   csql += "       A.F2_CLIENTE,"
   csql += "       A.F2_LOJA   ,"
   csql += "       B.A1_NOME   ,"
   csql += "       A.F2_VEND1  ,"
   csql += "       C.A3_NOME   ,"
   csql += "       A.F2_TRANSP ,"
   csql += "       D.A4_NOME   ,"
   csql += "       A.F2_HREXPED,"
   csql += "       A.F2_CONHECI "
   csql += " FROM " + RetSqlName("SF2010") + " A, "
   csql += "      " + RetSqlName("SA1010") + " B, "
   csql += "      " + RetSqlName("SA3010") + " C, "
   csql += "      " + RetSqlName("SA4010") + " D, "
   csql += "      " + RetSqlName("SC5010") + " E  "   
   csql += " WHERE A.F2_CLIENTE   = B.A1_COD  "
   csql += "   AND A.F2_LOJA      = B.A1_LOJA "
   csql += "   AND A.F2_VEND1     = C.A3_COD  "
   csql += "   AND A.F2_TRANSP    = D.A4_COD  "
   csql += "   AND A.F2_DOC       = E.C5_NOTA "
   cSql += "   AND A.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)"
   csql += "   AND A.R_E_C_D_E_L_ = ''        "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   T_DADOS->( DbGoTop() )

   While T_DADOS->( !Eof() )

      aAdd( aBrowse, { T_DADOS->C5_NUM    ,;
                       T_DADOS->A1_NOME   ,;
                       Substr(T_DADOS->F2_EMISSAO,07,02) + "/" + Substr(T_DADOS->F2_EMISSAO,05,02) + "/" + Substr(T_DADOS->F2_EMISSAO,01,04)  ,;
                       T_DADOS->F2_DOC    ,;
                       T_DADOS->F2_SERIE  ,;
                       T_DADOS->A3_NOME   ,;
                       T_DADOS->A4_NOME   ,;
                       T_DADOS->F2_HREXPED } )
      
      T_DADOS->( DbSkip() )
      
   Enddo

   oBrowse := TSBrowse():New(030,005,380,150,Dlg_Exp,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Pedido',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Clientes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Emissใo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('N.Fiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('S้rie',,,{|| },{|| }) )   
   oBrowse:AddColumn( TCColumn():New('Vendedor Principal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Transportadora',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora',,,{|| },{|| }) )   
   oBrowse:SetArray(aBrowse)

Return .T.

// Fun็ใo que pesquisa as observa็๕es internas do pedido de venda selecionado
Static Function OBSINTERNA( _Pedido )

   Local cSql    := ""
   Local lChumba := .F.
   Local cGet1	 := _Pedido
   Local oGet1
   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgXX

   // Posiciona o Pedido		
   DbSelectArea("SC5")
   DbSetOrder(1)
   DbSeek( xFilial("SC5") + _Pedido )

   If Select("T_OBSERVA") > 0
      T_OBSERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C5_OBSI)) AS OBSERVA "
   cSql += "  FROM " + RetSqlName("SC5") 
   cSql += " WHERE C5_NUM     = '" + Alltrim(_Pedido)        + "'"
   cSql += "   AND C5_FILIAL  = '" + Alltrim(SC5->C5_FILIAL) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )

   If T_OBSERVA->( EOF() )
      MsgAlert("Nใo existem dados a serem visualizados.")
      Return .T.
   Endif

   cMemo1 := T_OBSERVA->OBSERVA

   DEFINE MSDIALOG oDlgXX TITLE "Observa็๕es Internas do Pedido de Venda" FROM C(178),C(181) TO C(487),C(683) PIXEL

   @ C(006),C(004) Say "Nบ Pedido:"                             Size C(026),C(009) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(019),C(004) Say "Observa็๕es Interna do Pedido de Venda" Size C(102),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX

   @ C(004),C(034) MsGet oGet1 Var cGet1      When lChumba Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(029),C(003) GET oMemo1 Var cMemo1 MEMO              Size C(242),C(105) PIXEL OF oDlgXX

   @ C(137),C(208) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgXX ACTION( oDlgXX:End() )

   ACTIVATE MSDIALOG oDlgXX CENTERED 

Return(.T.)

// Fun็ใo que abre a tela de consulta do pedido de venda solicitada pela tela da Separa็ใo
Static Function ABRE_PEDIDO( _Pedido )

//--------------------------------------------------------------
// Exemplo de chamada somente da visualiza็ใo de uma tela
// Nใo apagar
//   Private aRotina := {;
//                      { "Pesquisar"  , ""         , 0 , 1 },;
//                      { "Visualizar" , "AxVisual" , 0 , 2 },;
//                      { "Incluir"    , ""         , 0 , 3 },;
//                      { "Alterar"    , ""         , 0 , 4 },;
//                      { "Excluir"    , ""         , 0 , 5 } ;
//                      }
//
//   Private cCadastro := "Consulta de Pedido de venda"
//
//   dbSelectArea("SC5")
//   dbSetOrder(1)
//   dbSeek( xFilial("SC5") + _Pedido )
//
//   AxVisual("SC5", SC5->( Recno() ), 2)
//--------------------------------------------------------------

   Local cSql       := ""
   Local lChumba    := .F.
   Local __Filial   := ""
   Local aConsulta  := {}
   Local cCliente   := Space(06)
   Local cLoja      := Space(03)
   Local cNcliente  := Space(40)
   Local cVendedor  := Space(06)
   Local cNvendedor := Space(40)
   Local cTransp    := Space(06)
   Local cNtransp   := Space(40)
   Local cCondicao  := Space(03)
   Local cNcondicao := Space(40)
   Local cTpFrete   := Space(03)
   Local cEndereco  := ""

   Local oGet1
   Local oGet10
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9
   Local oMemo1

   Private oDlgV
   
   dbSelectArea("SC5")
   dbSetOrder(1)

   __Filial := xFilial("SC5")
   
   // Pesquisa os dados para display
   If Select("T_CABECALHO") > 0
      T_CABECALHO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.C5_CLIENTE,"
   cSql += "       A.C5_LOJACLI,"
   cSql += "       B.A1_NOME   ,"
   cSql += "       B.A1_END    ,"
   cSql += "       B.A1_BAIRRO ,"
   cSql += "       B.A1_CEP    ,"
   cSql += "       B.A1_MUN    ,"
   cSql += "       B.A1_EST    ,"
   cSql += "       B.A1_CGC    ,"
   cSql += "       B.A1_INSCR  ,"
   cSql += "       A.C5_VEND1  ,"
   cSql += "       C.A3_NOME   ,"
   cSql += "       A.C5_TRANSP ,"
   cSql += "       A.C5_CONDPAG,"
   cSql += "       E.E4_DESCRI ,"
   cSql += "       A.C5_TPFRETE "
   cSql += " FROM " + RetSqlName("SC5") + " A, "
   cSql += "      " + RetSqlName("SA1") + " B, "
   cSql += "      " + RetSqlName("SA3") + " C, "
   cSql += "      " + RetSqlName("SE4") + " E  "
   cSql += "WHERE A.C5_FILIAL  = '" + Alltrim(__Filial) + "'"
   cSql += "  AND A.C5_NUM     = '" + Alltrim(_Pedido)  + "'"
   cSql += "  AND A.D_E_L_E_T_ = ''"
   cSql += "  AND A.C5_CLIENTE = B.A1_COD   "
   cSql += "  AND A.C5_LOJACLI = B.A1_LOJA  "
   cSql += "  AND A.C5_VEND1   = C.A3_COD   "
   cSql += "  AND C.D_E_L_E_T_ = ''         "
   cSql += "  AND A.C5_CONDPAG = E.E4_CODIGO"
   cSql += "  AND E.D_E_L_E_T_ = ''         "
   cSql += "  AND E.E4_FILIAL  = ''         "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CABECALHO", .T., .T. )

   If T_CABECALHO->( EOF() )
      MsgAlert("Nใo existem dados a serem visualizados.")
      Return .T.
   Endif
      
   cCliente   := T_CABECALHO->C5_CLIENTE
   cLoja      := T_CABECALHO->C5_LOJACLI
   cNcliente  := T_CABECALHO->A1_NOME

   cEndereco  := ""
   cEndereco  += T_CABECALHO->A1_END    + chr(13)  + chr(10) 
   cEndereco  += T_CABECALHO->A1_BAIRRO + chr(13)  + chr(10) 
   cEndereco  += Substr(T_CABECALHO->A1_CEP,01,02) + "."     + ;
                 Substr(T_CABECALHO->A1_CEP,03,03) + "-"     + ;
                 Substr(T_CABECALHO->A1_CEP,06,03) + " - "   + ;
                 Alltrim(T_CABECALHO->A1_MUN) + "/" +A1_EST  + ;
                 chr(13) + chr(10)                           

   If Len(Alltrim(T_CABECALHO->A1_CGC)) = 14
      cEndereco += "CNPJ/CPF:" + Substr(T_CABECALHO->A1_CGC,01,02)  + "." + ;
                                 Substr(T_CABECALHO->A1_CGC,03,03)  + "." + ;
                                 Substr(T_CABECALHO->A1_CGC,06,03)  + "/" + ;                                  
                                 Substr(T_CABECALHO->A1_CGC,09,04)  + "-" + ;                 
                                 Substr(T_CABECALHO->A1_CGC,13,02)  + chr(13) + chr(10)
   Else
      cEndereco += "CNPJ/CPF:" + Substr(T_CABECALHO->A1_CGC,01,03)  + "." + ;
                                 Substr(T_CABECALHO->A1_CGC,04,03)  + "." + ;
                                 Substr(T_CABECALHO->A1_CGC,07,03)  + "-" + ;                                  
                                 Substr(T_CABECALHO->A1_CGC,10,02)  + chr(13) + chr(10)
   Endif
                                                   
   cEndereco += "INSCR. ESTADUAL: " + Alltrim(T_CABECALHO->A1_INSCR)

   cVendedor  := T_CABECALHO->C5_VEND1
   cNvendedor := T_CABECALHO->A3_NOME

   // Pesquisa o nome da Transportadora
   If Empty(Alltrim(T_CABECALHO->C5_TRANSP))
      cTransp    := Space(06)
      cNtransp   := Space(40)
   Else   
      If Select("T_FRETE") > 0
         T_FRETE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A4_COD,"
      cSql += "       A4_NOME"
      cSql += "  FROM " + RetSqlName("SA4")
      cSql += " WHERE A4_COD     = '" + Alltrim(T_CABECALHO->C5_TRANSP) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FRETE", .T., .T. )
      
      cTransp    := T_FRETE->A4_COD
      cNtransp   := T_FRETE->A4_NOME
   Endif

   cCondicao  := T_CABECALHO->C5_CONDPAG
   cNcondicao := T_CABECALHO->E4_DESCRI
   Do Case
      Case T_CABECALHO->C5_TPFRETE == "C"
           cTpFrete := "CIF"
      Case T_CABECALHO->C5_TPFRETE == "F"
           cTpFrete := "FOB"
      Otherwise
           cTpFrete := "   "                 
   EndCase

   // Pesquisa os produtos do pedido de venda   
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.C6_ITEM   ,"
   cSql += "       A.C6_PRODUTO,"
   cSql += "       B.B1_PARNUM ,"
   cSql += "       A.C6_DESCRI ,"
   cSql += "       A.C6_UM     ,"
   cSql += "       A.C6_QTDVEN ,"
   cSql += "       A.C6_PRCVEN ,"
   cSql += "       A.C6_VALOR  ,"
   cSql += "       A.C6_TES    ,"
   cSql += "       A.C6_CF     ,"
   cSql += "       A.C6_ENTREG ,"
   cSql += "       A.C6_STATUS ,"
   cSql += "       A.C6_NOTA   ,"
   cSql += "       A.C6_SERIE  ,"
   cSql += "       A.C6_DATFAT  "
   cSql += "  FROM " + RetSqlName("SC6") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.C6_NUM     = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND A.C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.C6_PRODUTO = B.B1_COD"
   cSql += " ORDER BY A.C6_ITEM "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   WHILE !T_PRODUTOS->( EOF() )
      aAdd(aConsulta, { T_PRODUTOS->C6_ITEM   ,;
                        T_PRODUTOS->C6_PRODUTO,;
                        T_PRODUTOS->B1_PARNUM ,;
                        T_PRODUTOS->C6_DESCRI ,;
                        T_PRODUTOS->C6_UM     ,;
                        T_PRODUTOS->C6_QTDVEN ,;
                        T_PRODUTOS->C6_PRCVEN ,;
                        T_PRODUTOS->C6_VALOR  ,;
                        T_PRODUTOS->C6_TES    ,;
                        T_PRODUTOS->C6_CF     ,;
                        T_PRODUTOS->C6_ENTREG ,;
                        T_PRODUTOS->C6_STATUS ,;
                        T_PRODUTOS->C6_NOTA   ,;
                        T_PRODUTOS->C6_SERIE  ,;
                        T_PRODUTOS->C6_DATFAT }) 
      T_PRODUTOS->( DbSkip() )
   ENDDO   

   // Abre janela para display dos dados
   DEFINE MSDIALOG oDlgV TITLE "Consulta Pedido de Venda" FROM C(178),C(181) TO C(553),C(725) PIXEL

   @ C(006),C(008) Say "Cliente"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(060),C(007) Say "Vendedor"                    Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(074),C(214) Say "Tipo Frete"                  Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(075),C(007) Say "Transportadora"              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(088),C(007) Say "Cond. Pagtบ"                 Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(101),C(007) Say "Produtos do Pedido de Venda" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgV

   @ C(005),C(050) MsGet oGet1 Var cCliente  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(005),C(076) MsGet oGet2 Var cLoja     When lChumba Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(005),C(096) MsGet oGet3 Var cNcliente When lChumba Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV

   @ C(018),C(050) GET oMemo1 Var cEndereco  MEMO When lChumba Size C(216),C(038) PIXEL OF oDlgV

   @ C(060),C(050) MsGet oGet4  Var cVendedor  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(060),C(077) MsGet oGet5  Var cNvendedor When lChumba Size C(189),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(074),C(050) MsGet oGet6  Var cTransp    When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(073),C(077) MsGet oGet7  Var cNtransp   When lChumba Size C(131),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(073),C(242) MsGet oGet10 Var cTpFrete   When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(087),C(050) MsGet oGet8  Var cCondicao  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV
   @ C(087),C(077) MsGet oGet9  Var cNcondicao When lChumba Size C(189),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV

   @ C(171),C(229) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgV ACTION( oDlgV:End() )

   // Desenha o Browse
   oConsulta := TCBrowse():New( 145 , 005, 335, 070,,{'Item','Produto','Part Number','Descri็ใo dos Produtos', 'Und','Qtd','Unitแrio','Total', 'TES', 'Cod.Fiscal', 'Entrega', 'Status', 'N.Fiscal', 'S้rie', 'Data' },{20,50,50,50},oDlgV,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta) 
    
   // Monta a linha a ser exibina no Browse
   oConsulta:bLine := {||{aConsulta[oConsulta:nAt,01],;
                          aConsulta[oConsulta:nAt,02],;
                          aConsulta[oConsulta:nAt,03],;
                          aConsulta[oConsulta:nAt,04],;
                          aConsulta[oConsulta:nAt,05],;
                          aConsulta[oConsulta:nAt,06],;
                          aConsulta[oConsulta:nAt,07],;
                          aConsulta[oConsulta:nAt,08],;
                          aConsulta[oConsulta:nAt,09],;
                          aConsulta[oConsulta:nAt,10],;
                          aConsulta[oConsulta:nAt,11],;
                          aConsulta[oConsulta:nAt,12],;
                          aConsulta[oConsulta:nAt,13],;                                                                                                                                                      
                          aConsulta[oConsulta:nAt,14],;
                          aConsulta[oConsulta:nAt,15]} }

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return( NIL )

// Jean Rehermann - Solutio IT - 25/07/2012 | Grava็ใo de Log da separa็ใo
// Parโmetro 1: cTipo => S - Separa็ใo | M - Altera็ใo Manual do C5_JPCSEP | A - Altera็ใo automatica do campo C5_JPCSEP
// Parโmetro 2: cTpCod => S - Seriado | P - Nใo Seriado (apenas c๓digo de produto)
// Parโmetro 3: cSepA => Conteudo atual do C5_JPCSEP (P,T ou Branco)
// Parโmetro 4: cSepN => Conteudo a ser gravado no C5_JPCSEP (P,T ou Branco)
Static Function GravaLogSep(cTipo, cTpCod, cSepA, cSepN)
	
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
