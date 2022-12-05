#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "TOTVS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##                                         
// ------------------------------------------------------------------------------- ##
// Referencia: JPCACD01.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 12/03/2015                                                          ##
// Objetivo..: Tela de Separação de Pedidos de Venda                               ##
// ##################################################################################

User Function JPCACD01

   // ####################################################
   // Variaveis Locais .. depois passar para parametros ##
   // ####################################################
   Local _nItem     := ""
   Local _cMsgPar   := ""

   Local __Lacre    := ""
   Local __Corpo    := ""
   Local __Filial   := ""

   Local lChumba    := .F.
   Local nContar    := 0

   Local cMemo1     := ""
   Local oMemo1 

   Local cMemo10    := ""
   Local cMemo11    := ""
   Local oMemo10
   Local oMemo11

   Local aComboBx1	 := {"Item01","Item02"}
   Local cComboBx1

   Private nTVideo   := oMainWnd:nClientWidth

   Private _cTitulo  := "JPCACD01 - Conferencia de Separacao"
   Private _cTipoSep := GetNewPar("JPCACD0100","G")

   Private aRotina 	 := {{"","",0,4}}
   Private nOca 	 := 0
   Private cQuery 	 := ""
   Private lClose 	 := .t.
   Private lRefresh	 := .t.
   Private aHeader 	 := {}
   Private aAlter  	 := {}
   Private _aArqC1 	 := {}
   Private oGetDb1
   Private oGetDb2

   Private _cTipo  	 := "1"    // por pedido de Venda
   Private nOcb 	 := 1
   Private oCodBarr
   Private cCodBarr  := Space(15)

   Private aHeade2   := {}
   Private aAlter2   := {}
   Private _aArqC2   := {}

   Private aLstBox   := {}
   Private oLbx

   Private cDescProd := ""
   Private cCodProd  := ""

   Private oCodLote
   Private cCodLote  := Space(20)

   Private oCodDuplo 
   Private cCodDuplo := Space(20) 

   Private oCodPedido 
   Private oCodPedido := Space(06)

   Private _nQCodP    := 0	// JPC Gerson - 16.06.11

   Private cPedAtu    := "S"
   Private oPedAtu

   Private oDlgBrw
   Private aRet       := {}
   Private aType      := {}
   Private aFile      := {}
   Private aLine      := {}
   Private aDate      := {}
   Private aTime      := {}
   Private oAux 
   Private cAux
   Private lLibera    := .F.

   Private MsgTotal   := ""

   Private kVoltaPrd  := .F.

   Private lAlerta    := .T.
   Private oAlerta
   
   Private aProcura   := {}

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   U_AUTOM628("JPCACD01")

   // ############################################################################################
   // Jean Rehermann - 31/01/2012 - Verificar parametros, se não estiverem OK nao deixa separar ##
   // ############################################################################################
   If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilant == "07")
   Else
      If GetMv("MV_AVALEST") != 3
         _cMsgPar := "Verificar o parametro MV_AVALEST, o conteudo deve ser 3" +CHR(13)
      EndIf
   Endif   
   
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
		
        // ##########################
        // Gera Arquivo Temporario ##
        // ##########################
		IF GeraArq() 
			
           If nTVideo == 970

 		      DEFINE MSDIALOG oDlgBrw TITLE _cTitulo From 140,0 To 645,950 OF oMainWnd PIXEL Style DS_MODALFRAME

              @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlgBrw

		      oGetDb1 := MsGetDB():New(35,05,235,475,1,"U_SEPTDOK","U_SEPTDOK","",.F., aAlter, ,.T., ,"SEPARA",Nil,Nil,Nil,oDlgBrw)

		      // MsGetDb():New( nSuperior, nEsquerda, nInferior, nDireita,
  		      //     nOpc, [ cLinhaOk ], [ cTudoOk ], [ cIniCpos ], [ lApagar ], [ aAlter ],
		      // [ nCongelar ], [ lVazio ], [ uPar1 ], cTRB, [ cCampoOk ], [ lCondicional ], [ lAdicionar ], [ oWnd ], [ lDisparos ], [ uPar2 ], [ cApagarOk ], [ cSuperApagar ] ) -> objeto

              @ 237,005 BUTTON "Lista Sep."  Size 40,12 ACTION (nOca:=2,oDlgBrw:End())      Of oDlgBrw PIXEL
              @ 237,045 BUTTON "Leitura"     Size 40,12 ACTION (nOca:=3,oDlgBrw:End())      Of oDlgBrw PIXEL
              @ 237,085 BUTTON "Pesquisa"    Size 40,12 ACTION (U_PsqaLst())                Of oDlgBrw PIXEL
              @ 237,125 BUTTON "Embalagem"   Size 40,12 ACTION (U_Embala("      "))         Of oDlgBrw PIXEL
              @ 237,165 BUTTON "Embarque"    Size 40,12 ACTION (U_Embarque())               Of oDlgBrw PIXEL
              @ 237,205 BUTTON "Documento"   Size 40,12 ACTION (StsDoc())                   OF oDlgBrw PIXEL
              @ 237,245 BUTTON "Obs.Interna" Size 40,12 ACTION (OBSINTERNA(SEPARA->C5_NUM)) OF oDlgBrw PIXEL
              @ 237,285 BUTTON "Log Sep."    Size 40,12 ACTION (U_ZZQBROWSE())              OF oDlgBrw PIXEL
              @ 237,325 BUTTON "Dta.Ent."    Size 40,12 ACTION (U_AUTOM663())               OF oDlgBrw PIXEL

		      @ 240,340 Say OemtoAnsi("Sel. Filtro") SIZE 40, 20 OF oDlgBrw PIXEL
		      @ 238,370 ComboBox oPedAtu Var cPedAtu ITEMS { "S=Sem Filtro","T=Total","P=Parcial"} SIZE 040,010 OF oDlgBrw Pixel

		      DEFINE SBUTTON FROM 237,415 TYPE 01 ACTION ( AtuArq() ) OF oDlgBrw ENABLE Pixel

              @ 237,445 BUTTON "Saída"  Size 30,12 ACTION (nOca:=0,oDlgBrw:End()) OF oDlgBrw PIXEL

		      aRet  := GetFuncArray('U_JPCACD01*', aType,@aFile,aLine,@aDate,@aTime)
		      SetKey( VK_F11, { || APMSGINFO("Arquivo: "+aFile[1]+CHR(13)+CHR(10)+"Versao: 1.2.1"+CHR(13)+CHR(10)+"Data: "+DtoC(aDate[1]),"About:")})

           Else

		      DEFINE MSDIALOG oDlgBrw TITLE _cTitulo From 140,0 To 645,1078 OF oMainWnd PIXEL Style DS_MODALFRAME
              
              @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlgBrw

		      oGetDb1 := MsGetDB():New(35,05,235,530,1,"U_SEPTDOK","U_SEPTDOK","",.F., aAlter, ,.T., ,"SEPARA",Nil,Nil,Nil,oDlgBrw)

		      // MsGetDb():New( nSuperior, nEsquerda, nInferior, nDireita,
  		      //     nOpc, [ cLinhaOk ], [ cTudoOk ], [ cIniCpos ], [ lApagar ], [ aAlter ],
		      // [ nCongelar ], [ lVazio ], [ uPar1 ], cTRB, [ cCampoOk ], [ lCondicional ], [ lAdicionar ], [ oWnd ], [ lDisparos ], [ uPar2 ], [ cApagarOk ], [ cSuperApagar ] ) -> objeto

              @ 237,005 BUTTON "Lista Sep."  Size 40,12 ACTION (nOca:=2,oDlgBrw:End())      Of oDlgBrw PIXEL
              @ 237,045 BUTTON "Leitura"     Size 40,12 ACTION (nOca:=3,oDlgBrw:End())      Of oDlgBrw PIXEL
              @ 237,085 BUTTON "Pesquisa"    Size 40,12 ACTION (U_PsqaLst())                Of oDlgBrw PIXEL
              @ 237,125 BUTTON "Embalagem"   Size 40,12 ACTION (U_Embala("      "))         Of oDlgBrw PIXEL
              @ 237,165 BUTTON "Embarque"    Size 40,12 ACTION (U_Embarque())               Of oDlgBrw PIXEL
              @ 237,205 BUTTON "Documento"   Size 40,12 ACTION (StsDoc())                   OF oDlgBrw PIXEL
              @ 237,245 BUTTON "Obs.Interna" Size 40,12 ACTION (OBSINTERNA(SEPARA->C5_NUM)) OF oDlgBrw PIXEL
              @ 237,285 BUTTON "Log Sep."    Size 40,12 ACTION (U_ZZQBROWSE())              OF oDlgBrw PIXEL
              @ 237,325 BUTTON "Dta.Ent."    Size 40,12 ACTION (U_AUTOM663())               OF oDlgBrw PIXEL

		      @ 240,370 Say OemtoAnsi("Sel. Filtro") SIZE 40, 20 OF oDlgBrw PIXEL

		      @ 238,400 ComboBox oPedAtu Var cPedAtu ITEMS { "S=Sem Filtro","T=Total","P=Parcial"} SIZE 040,010 OF oDlgBrw Pixel

		      DEFINE SBUTTON FROM 237,440 TYPE 01 ACTION ( AtuArq() ) OF oDlgBrw ENABLE Pixel

              @ 237,480 BUTTON "Saída"  Size 50,12 ACTION (nOca:=0,oDlgBrw:End()) OF oDlgBrw PIXEL

		      aRet  := GetFuncArray('U_JPCACD01*', aType,@aFile,aLine,@aDate,@aTime)
		      SetKey( VK_F11, { || APMSGINFO("Arquivo: " + aFile[1] + CHR(13) + CHR(10) + "Versao: 1.2.1" + CHR(13) + CHR(10) + "Data: " + DtoC(aDate[1]),"About:")})
		      
           Endif		                                         

		   ACTIVATE MSDIALOG oDlgBrw Valid lClose

		   If nOca == 0

		 	  // ok
			  DbSelectArea("SEPARA")
			  DbCloseArea()
			  Exit

		   ElseIf nOca == 2

              // ##########################
			  // Imprime Lista Separacao ##
			  // ##########################
              U_AUTOMR23(SEPARA->C5_NUM)

              //If _cTipoSep == "G"   // Grafica
              //   U_JPCSEPGRF()
              //Else //Matricial
              //   U_JPCSEPMAT()
              //Endif
				
           // ######################
           // Leitura do Produtos ##
           // ######################
		   ElseIf nOca == 3

              // ##########################################################################################
              // Se Empresa logada for a 03 - Atech (Produção), envia para a função que verifica         ##
              // se existe produtos com produção diferente da quantidade do pedido de venda selecionado. ##
              // ##########################################################################################
//            If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")

                 kVoltaPrd := .F.
                 MtrProducao(xFilial("SC5"), SEPARA->C5_NUM)   
                 If kVoltaPrd == .T.
                    Loop
                 Endif

//            Endif      

              // ###############################################################
              // Limpa o array de verificação de produtos com número de série ##
              // Preparando o array para novas leituras.                      ##
              // ###############################################################
              aProcura := {}

			  // Conferencia
			  IF U_MtaConf()
			 	 aHeadBkp := aClone(aHeader)
				 aHeader  := aClone(aHeade2)

                 // Captura as mensagens de erro já registradas para o pedido de venda
			     DbSelectArea("SC5")
				 DbSetorder(1)
				 If DbSeek(xFilial("SC5") + SEPARA->C5_NUM)
                    MsgTotal := SC5->C5_ZMSP + Chr(13) + Chr(10) + chr(13) + chr(10)
                    MsgTotal := MsgTotal + "Data: " + Dtoc(Date()) + chr(13) + chr(10) + "Hora: " + Time() + chr(13) + chr(10) + "Usuário: " + Alltrim(cUserName) + chr(13) + chr(10)
                 Else
                    MsgTotal := "Data: " + Dtoc(Date()) + chr(13) + chr(10) + "Hora: " + Time() + chr(13) + chr(10) + "Usuário: " + Alltrim(cUserName) + chr(13) + chr(10)
                 Endif

                 // Desenha a tela conforme configuração do vídeo do equipamento
                 If nTVideo == 970

				    DEFINE MSDIALOG oDlgConf TITLE _cTitulo From 100,0 To 660,950 OF oMainWnd PIXEL Style DS_MODALFRAME

                    @ C(085),C(002) Jpeg FILE "logoautomav.bmp"    Size C(040),C(300) PIXEL NOBORDER OF oDlgConf

    	            @ C(003),C(028) GET oMemo1 Var cMemo1 MEMO Size C(001),C(236) PIXEL OF oDlgConf

				    @ 005,040 SAY OemToAnsi("Lote/Ender./Nº Serie ")                                SIZE 100,008 OF oDlgConf PIXEL
				    //@ 003,060 MSGET oCodBarr VAR cCodBarr PICTURE "@X" VALID(U_VldCdBr(cCodBarr)) SIZE 060,008 OF oDlgConf PIXEL

                    If cEmpAnt == "01" .And. cFilAnt == "06"
                       @ C(003),C(075) Button "NS Esp.Santo"   Size C(037),C(012) PIXEL OF oDlgConf ACTION (NSESanto())
                    Else
 				       @ 003,090 MSGET oCodLote VAR cCodLote  PICTURE "@X" VALID(U_VldLote(cCodLote))  SIZE 060,008 OF oDlgConf PIXEL
                    Endif   

				    @ 003,210 SAY OemToAnsi("Cod.Barras ")                                          SIZE 060,008 OF oDlgConf PIXEL
				    @ 003,200 MSGET oAux VAR cAux          PICTURE "@X"                             SIZE 001,001 OF oDlgConf PIXEL
					
				    @ 003,260 SAY cDescProd SIZE 300,10 OF oDlgConf PIXEL

				    @ 239,040 SAY OemToAnsi("Ultimo produto lido em duplicidade") SIZE 100,008 OF oDlgConf PIXEL
				    @ 249,040 MSGET oCodDuplo VAR cCodDuplo  PICTURE "@X"         SIZE 110,008 OF oDlgConf PIXEL When lChumba

				    oGetDb2 := MsGetDB():New(20,40,235,150,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)

                    // ###########################
                    // Define o ListBox da Tela ##
                    // ###########################
    			    @ 020,155 LISTBOX oLbx FIELDS HEADER "Item", "Cod.Produto", "Descricao", "Qtd.PV", "Separado", "Diferenca", "Lote/Sublote", "Num.Serie", "Local", "."  SIZE 317,240 OF oDlgConf PIXEL
					
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
					

				    @ 266,290 SAY OemToAnsi("Nº Pedido: ") SIZE 060,008 OF oDlgConf PIXEL
                    cCodPedido := SEPARA->C5_NUM
				    @ 265,320 MSGET oCodPedido VAR cCodPedido PICTURE "@X" When lChumba SIZE 029,009 OF oDlgConf PIXEL

				    DEFINE SBUTTON FROM 265,350 TYPE 15 OF oDlgConf PIXEL ENABLE ACTION( ABRE_PEDIDO( SEPARA->C5_NUM ) )
					
                    @ 265,155 BUTTON "Saldo"       Size 40,12 ACTION (U_SALDOS(aLstBox[oLbx:nAt,2])) Of oDlgConf PIXEL
                    @ 265,200 BUTTON "Embalagem"   Size 40,12 ACTION (U_Embala(SEPARA->C5_NUM))      Of oDlgConf PIXEL
                    @ 265,245 BUTTON "Obs.Interna" Size 40,12 ACTION (OBSINTERNA(SEPARA->C5_NUM))    OF oDlgConf PIXEL

                    @ 265,432 BUTTON "Alarme"      Size 40,12 ACTION (AlertaOnOff())  Of oDlgConf PIXEL

				    DEFINE SBUTTON FROM 265,040 TYPE 01 WHEN lLibera ACTION (nOcb := 2 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE
				    DEFINE SBUTTON FROM 265,070 TYPE 02              ACTION (nOcb := 0 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE

                 Else

    			    DEFINE MSDIALOG oDlgConf TITLE _cTitulo From 100,0 To 660,1200 OF oMainWnd PIXEL Style DS_MODALFRAME

                    @ C(085),C(002) Jpeg FILE "logoautomav.bmp"    Size C(040),C(300) PIXEL NOBORDER OF oDlgConf

    	            @ C(003),C(028) GET oMemo1 Var cMemo1 MEMO Size C(001),C(236) PIXEL OF oDlgConf

				    @ 005,040 SAY OemToAnsi("Lote/Ender./Nº Serie ")                                SIZE 100,008 OF oDlgConf PIXEL

				    //@ 003,060 MSGET oCodBarr VAR cCodBarr PICTURE "@X" VALID(U_VldCdBr(cCodBarr)) SIZE 060,008 OF oDlgConf PIXEL

                    If cEmpAnt == "01" .And. cFilAnt == "06"
                       @ C(003),C(075) Button "NS Esp.Santo"   Size C(037),C(012) PIXEL OF oDlgConf ACTION (NSESanto())
                    Else
 				       @ 003,090 MSGET oCodLote VAR cCodLote  PICTURE "@X" VALID(U_VldLote(cCodLote))  SIZE 060,008 OF oDlgConf PIXEL
                    Endif   

				    @ 003,210 SAY OemToAnsi("Cod.Barras ")                                          SIZE 060,008 OF oDlgConf PIXEL
				    @ 003,200 MSGET oAux VAR cAux          PICTURE "@X"                             SIZE 001,001 OF oDlgConf PIXEL
					
				    @ 003,260 SAY cDescProd SIZE 300,10 OF oDlgConf PIXEL

				    @ 239,040 SAY OemToAnsi("Ultimo produto lido em duplicidade") SIZE 100,008 OF oDlgConf PIXEL
				    @ 249,040 MSGET oCodDuplo VAR cCodDuplo  PICTURE "@X"         SIZE 110,008 OF oDlgConf PIXEL When lChumba
				    
 				    oGetDb2 := MsGetDB():New(20,40,235,150,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)

                    // Define o ListBox da Tela
    			    @ 020,155 LISTBOX oLbx FIELDS HEADER "Item", "Cod.Produto", "Descricao", "Qtd.PV", "Separado", "Diferenca", "Lote/Sublote", "Num.Serie", "Local", "."  SIZE 440,240 OF oDlgConf PIXEL
					
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
					
				    @ 266,450 SAY OemToAnsi("Nº Pedido: ") SIZE 060,008 OF oDlgConf PIXEL
                    cCodPedido := SEPARA->C5_NUM
				    @ 265,480 MSGET oCodPedido VAR cCodPedido PICTURE "@X" When lChumba SIZE 029,009 OF oDlgConf PIXEL
				    DEFINE SBUTTON FROM 265,510 TYPE 15 OF oDlgConf PIXEL ENABLE ACTION( ABRE_PEDIDO( SEPARA->C5_NUM ) )
					
                    @ 265,280 BUTTON "Saldo"       Size 40,12 ACTION (U_SALDOS(aLstBox[oLbx:nAt,2])) Of oDlgConf PIXEL
                    @ 265,325 BUTTON "Embalagem"   Size 40,12 ACTION (U_Embala(SEPARA->C5_NUM))   Of oDlgConf PIXEL
                    @ 265,370 BUTTON "Obs.Interna" Size 40,12 ACTION (OBSINTERNA(SEPARA->C5_NUM)) OF oDlgConf PIXEL

                    @ 264,555 BUTTON "Alarme"      Size 40,12 ACTION (AlertaOnOff())         Of oDlgConf PIXEL

				    DEFINE SBUTTON FROM 265,040 TYPE 01 WHEN lLibera ACTION (nOcb := 2 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE
				    DEFINE SBUTTON FROM 265,070 TYPE 02              ACTION (nOcb := 0 , oDlgConf:End())	OF oDlgConf PIXEL ENABLE
                    
                 Endif
                 
				 ACTIVATE MSDIALOG oDlgConf Valid lClose CENTER
					
                 // ####################################
                 // Caso acionado o botão de CANCELAR ##
                 // ####################################
				 If nOcb == 0
				    lLibera := .F.

                    // ##############################################################
   			        // Atualiza o campo de mensagem de inconsistência da separação ##
   			        // ##############################################################
   			        DbSelectArea("SC5")
				    DbSetorder(1)
				    If DbSeek(xFilial("SC5") + SEPARA->C5_NUM)
   					   Reclock("SC5",.f.)
                       C5_ZMSP   := MsgTotal && Grava as mensagens de inconsitências encontradas na separação.
                                             && Servirá para relatório de análise de inconsistências da separação pela logística.
					   MsUnlock()
					Endif   
				 Endif   					
					
                 // ###########################
                 // Caso acionado o botão OK ##
                 // ###########################
				 If nOcb == 2

                    lLibera := .F.

				    DbSelectArea("CONF")
					DbGoTop()

					_cTipoC5  := "T"
					_cTipoCod := "U"
                    __Lacre   := ""
                    __Filial  := ""
                        						
				 	Do While !Eof()
							
                       // ############################################################
					   // Procuro o produto para ver se tem controle de Localizacao ##
					   // ############################################################
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

                          // ############
						  // Grava SDC ##
						  // ############
						  IF _cTipoCod=="S"

						 	 DbSelectArea("SBF")
							 DbSetOrder(4)   //BF_FILIAL+BF_PRODUTO+BF_NUMSERI
							 DbSeek(xFilial("SBF")+CONF->B1_COD+CONF->B1_CODBAR)
								 
						 	 lSBFLOC := .F.

							 While !SBF->( Eof() ) .And. BF_FILIAL + BF_PRODUTO + BF_NUMSERI == xFilial("SBF") + CONF->B1_COD + CONF->B1_CODBAR
							    If aLstBox[_n, 9] == SBF->BF_LOCAL
								   lSBFLOC := .T.
								   Exit
								EndIf
								SBF->( dbSkip() )
							 Enddo
								 
							 IF !lSBFLOC
								ALERT("SBF - Não encontrado produto/armazém/NS : "+ CONF->B1_COD +" | "+ CONF->B1_CODBAR +" | "+ aLstBox[_n, 9] )
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

                             // ################
							 // Atualizar SBF ##
							 // ################
							 Reclock("SBF",.f.)
							 BF_EMPENHO := 1
							 MsUnlock()
                                
						  ENDIF
								
						  DbSelectArea("SB2")
						
                          // ################
						  // Atualizar SB2 ##
						  // ################
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
							  
						  // Jean Rehermann - Atualiza o Status do item no SC6
						  dbSelectArea("SC6")
						  dbSetOrder(1)
						  If dbSeek( xFilial("SC6") + SEPARA->C5_NUM + aLstBox[ _n, 1 ] )
						 	 RecLock("SC6",.F.)
                                    
                             // A partir de 01/08/2012, se o produto vai ser lacrado na Automatech, passa para o status 09 também
                             If (SC6->C6_TEMDOC == "S" .OR. SC6->C6_LACRE = "S") .And. SC6->C6_STATUS != "09"

							    SC6->C6_STATUS := "09" // Ag. Documentação cliente

							    U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "09", "JPCACD01(DOC)" ) // Gravo o log de atualização de status na tabela ZZ0

                                If Alltrim(SC6->C6_LACRE) == "S"                                            
                                   __Lacre += CONF->B1_CODBAR + " - " + Alltrim(SB1->B1_COD) + " - " + Alltrim(SB1->B1_DESC) + Alltrim(SB1->B1_DAUX) + chr(13) + chr(10)
                                   __Filial := xFilial("SC6")
                                Endif   

							 ElseIf SC6->C6_TEMDOC != "S" .And. SC6->C6_STATUS != "10"

                                If Alltrim(SC6->C6_LACRE) == "S"                                            

							 	   SC6->C6_STATUS := "09" // Ag.cliente
								   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "09", "JPCACD01-LACRE" ) // Gravo o log de atualização de status na tabela ZZ0

                                   // Carrega o nº de série para envio do e=mail ao vendedor
                                   __Lacre += CONF->B1_CODBAR + " - " + Alltrim(SB1->B1_COD) + " - " + Alltrim(SB1->B1_DESC) + Alltrim(SB1->B1_DAUX) + chr(13) + chr(10)
                                   __Filial := xFilial("SC6")

                                 Else

   							 	   SC6->C6_STATUS := "10" // Ag. Faturamento
								   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "10", "JPCACD01" ) // Gravo o log de atualização de status na tabela ZZ0

                                 Endif   

							 EndIf

							 MsUnLock()

						  EndIf
					   Else
					 	  _cTipoC5 := "P"
					   Endif
							
					   // Jean Rehermann - Solutio IT - 25/07/2012 | Gravação de Log da separação
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
                                  "Abaixo segue relação do(s) nº de Serie(s) do(s) produto(s) que serão lacrado(s) na Automatech" + chr(13) + chr(10) + ;
                                  "referente ao seu Pedido de Venda Nº " + Alltrim(SEPARA->C5_NUM) + " do Cliente " + ALLTRIM(SEPARA->A1_NREDUZ) + "." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                                  Alltrim(__Lacre) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                                  "Atenciosamente" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                                  "Departamento de Estoque"

                       U_AUTOMR20(__Corpo, Alltrim(T_EMAIL->A3_EMAIL),"", "Nº de Série para produtos que serão lacrados na Automatech" )

                    Endif

  				    // Atualizar SC5
					// Verifica o SC9
					DbSelectArea("SC9")
					DbSetOrder(2) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
					DbSeek(xFilial("SC9")+SEPARA->C5_CLIENTE+SEPARA->C5_LOJACLI+SEPARA->C5_NUM)
					_cChave := C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO

					Do While !eof() .and. _cChave == SC9->C9_FILIAL+SC9->C9_CLIENTE+SC9->C9_LOJA+SC9->C9_PEDIDO
					   _aAreaSC6 := GetArea()
					   IF SC9->C9_BLEST <> "  " .OR. SC9->C9_BLWMS <> "  "
						  If Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_CF") $   "5933|6933|7933" //Adicionado Michel Aoki                              
						     Reclock("SC9",.f.)
						     C9_BLEST := ""
						     C9_BLWMS := ""
						     MsUnlock()
						  Else
						    _cTipoC5 := "P"
						    Exit
						  EndIf
								
						  /* Comentado Michel Aoki
						  IF ALLTRIM(SC9->C9_AGREG) == ""
						     _cTipoC5 := "P"
						     Exit
						  ElseIf ALLTRIM(SC9->C9_AGREG) == "SRV"
						     Reclock("SC9",.f.)
						     C9_BLEST := ""
						     C9_BLWMS := ""
						     MsUnlock()
					   	  Endif*/
  					   ENDIF    
							
					   ResTArea(_aAreaSC6)
					   DbSelectArea("SC9")
					   DbSkip()
					
					Enddo
						
					DbSelectArea("SC5")
					DbSetorder(1)
					DbSeek(xFilial("SC5")+SEPARA->C5_NUM)
						
					// Jean Rehermann - Solutio IT - 25/07/2012 | Gravação de Log do Update do C5_JPCSEP
					GravaLogSep("A","",SC5->C5_JPCSEP,_cTipoC5)
						
					Reclock("SC5",.f.)
					C5_JPCSEP := _cTipoC5
                    C5_ZMSP   := MsgTotal && Grava as mensagens de inconsitências encontradas na separação.
                                          && Servirá para relatório de análise de inconsistências da separação pela logística.
					MsUnlock()

/*
                        // --------------------------------------------------------------------------------------------------------- //
                        // Realiza a verificação se o pedido separado é proveniente de um pedido de venda referente a L O C A Ç Ã O. //
                        // Em caso afirmativo, é alterado o Status do pedido de venda para 09 Aguardando cliente.                    //
                        // Somente será passado para 09 se o pedido de venda for de Locação e o status neste ponto do programa for   //
                        // = a 10 - Aguarando Faturamento.                                                                           //
                        // Esta alteração foi necessária pois o faturamento do pedido de remessa de mercadoria para locação somente  //
                        // poderá ser efetuado após o faturamento do pedido referente a medição do contrato de locação.              //
                        // --------------------------------------------------------------------------------------------------------- //
                        If Select("T_LOCACAO") > 0
                           T_LOCACAO->( dbCloseArea() )
                        EndIf

                        cSql := ""
                        cSql := "SELECT SCK.CK_FILIAL ,"
                        cSql += "       SCK.CK_NUMPV  ,"
            	        cSql += "       SCK.CK_PROPOST,"
	                    cSql += "       ADY.ADY_OPORTU,"
	                    cSql += "       AD1.AD1_ZTIP  ,"
 	                    cSql += "       AD1.AD1_ZCONTR "
                        cSql += "  FROM " + RetSqlName("SCK") + " SCK, "
                        cSql += "       " + RetSqlName("ADY") + " ADY, "
	                    cSql += "       " + RetSqlName("AD1") + " AD1  "
                        cSql += " WHERE SCK.CK_FILIAL  = '" + Alltrim(cFilAnt)        + "'"
                        cSql += "   AND SCK.CK_NUMPV   = '" + Alltrim(SEPARA->C5_NUM) + "'"
                        cSql += "   AND SCK.D_E_L_E_T_ = ''"
                        cSql += "   AND ADY.ADY_FILIAL = SCK.CK_FILIAL "
                        cSql += "   AND ADY.ADY_PROPOS = SCK.CK_PROPOST"
                        cSql += "   AND ADY.D_E_L_E_T_ = ''            "
                        cSql += "   AND AD1.AD1_FILIAL = ADY.ADY_FILIAL"
                        cSql += "   AND AD1.AD1_NROPOR = ADY.ADY_OPORTU"
                        cSql += "   AND AD1.AD1_ZTIP   = '2'"
                        cSql += "   AND AD1.AD1_ZCONTR <> ''"
                        cSql += "   AND AD1.D_E_L_E_T_ = '' "  

                        cSql := ChangeQuery( cSql )
                        dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOCACAO", .T., .T. )
                         
                        If !T_LOCACAO->( EOF() )

                           If Select("T_PRODUTOS") > 0
                              T_PRODUTOS->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT C6_FILIAL ,"
                           cSql += "       C6_ITEM   ,"
                           cSql += "	   C6_PRODUTO,"
                           cSql += "       C6_STATUS  "
                           cSql += "   FROM " + RetSqlName("SC6")
                           cSql += "  WHERE C6_FILIAL = '" + Alltrim(cFilAnt)        + "'"
                           cSql += "    AND C6_NUM    = '" + Alltrim(SEPARA->C5_NUM) + "'"
                           cSql += "    AND D_E_L_E_T_= ''"

                           cSql := ChangeQuery( cSql )
                           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

                           If !T_PRODUTOS->( EOF() )                        

                              WHILE !T_PRODUTOS->( EOF() )

  							     dbSelectArea("SC6")
							     dbSetOrder(1)
							     If dbSeek( xFilial("SC6") + SEPARA->C5_NUM + T_PRODUTOS->C6_ITEM + T_PRODUTOS->C6_PRODUTO)
                                    If T_PRODUTOS->C6_STATUS == "10"
   							 	       RecLock("SC6",.F.)
								       SC6->C6_STATUS := "09" 

                                       // Gravo o log de atualização de status na tabela ZZ0
     							       U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "09", "JPCACD01(DOC)" ) 
  								       MsUnLock()
   								    Endif
   								 Endif
  								 T_PRODUTOS->( DbSkip() )
  							  ENDDO	 
  							  
  						   Endif

                        Endif

*/
						
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

// Função que pesquisa um determinado pedido de venda informado
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

// Função que realiza a visualização de pedido de venda
User Function VerPV()

   Local cPedVen := SEPARA->C5_NUM
   Local _aArea  := GetArea()
   Local aCores  := {}
   Local cRoda   := ""
   Local bRoda   := {|| .T.}
   Local xRet    := Nil
   Local nPos	 := 0

   PRIVATE lOnUpdate  := .T.	
   PRIVATE l410Auto   := .f.
   PRIVATE aRotina    := {}

   aAdd( aRotina, { "Visualizar", "A410Visual", 0, 2 } )

   PRIVATE cCadastro := OemToAnsi("Atualização de Pedidos de Venda")

   DbSelectArea("SC5")
   DbSeek( xFilial("SC5") + SEPARA->C5_NUM )
   A410Visual()

   RestArea(_aArea)

Return

// Pesquisa o Saldo do produto selecionado (F4)
User Function Saldos(_Codigo)

   MaViewSB2(_Codigo)
   
Return .T.   

// Função que abre tela de informação de embalagem do pedido de venda selecionado
User Function Embala(_Pedido)

   Private cPedVen := _Pedido
   Private oPedVen

   DEFINE MSDIALOG FASPedA TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 00,000 TO 100,230 OF oMainWnd Pixel Style DS_MODALFRAME
   
   @ 10,005 Say "Nr.do Pedido de Venda:"   OF FASPedA Pixel
   @ 10,070 MsGet oPedVen Var cPedVen F3 "SC5" PICTURE "@X" SIZE 040,010 OF FASPedA VALID ExistCpo("SC5",cPedVen) Pixel

   //    .and. empty(Posicione("SC5",1,xFilial("SC5")+cPedVen,"C5_NOTA"))  Pixel
   //   @ 10,070 MsGet oPedVen Var cPedVen F3 "SC5" PICTURE "@X" SIZE 040,010 OF FASPedA VALID ExistCpo("SC5",cPedVen) .and. empty(Posicione("SC5",1,xFilial("SC5")+cPedVen,"C5_NOTA"))  Pixel
   //   @ 10,070 MsGet oPedVen Var cPedVen F3 "SC5" PICTURE "@X" SIZE 040,010 OF FASPedA  Pixel

   DEFINE SBUTTON FROM 30,005 TYPE 01 ACTION (FConfirma())	    OF FasPedA ENABLE Pixel
   DEFINE SBUTTON FROM 30,060 TYPE 02 ACTION (Close(FasPedA))	OF FasPedA ENABLE Pixel

   ACTIVATE DIALOG FasPedA CENTER

Return

// #########################################################################################
// Função que confirma a informação dos dados da embalagem do pedido de venda selecionado ##
// #########################################################################################
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

   // #########################################################################
   // Verifica se o cliente do pedido de venda é GKN.                        ##
   // Se for, somente permite proceguir se o pedido de venda já foi faturado ##
   // #########################################################################
   If Posicione("SC5",1, xFilial("SC5") + cPedVen, "C5_CLIENT") == "000859"
   Else
      If !Empty(Posicione("SC5",1, xFilial("SC5") + cPedVen, "C5_NOTA"))
         Return(.T.)
      Endif
   Endif

   DbSelectArea("SC5")
   DbSetOrder(1)
   DbSeek( xFilial("SC5") + cPedVen)

   dEmissao   := SC5->C5_EMISSAO
   nPbruto 	  := SC5->C5_PBRUTO
   nPliq   	  := SC5->C5_PESOL 
   cEspecie	  := SC5->C5_ESPECI1
   cVolume 	  := SC5->C5_VOLUME1
   cTransp 	  := SC5->C5_TRANSP
   cCliente	  := SC5->C5_CLIENTE+SC5->C5_LOJACLI
   nValNot    := 0 //SC5->C5_VALBRUT
   cTpFrete   := SC5->C5_TPFRETE
   //cObsNota := SC5->C5_OBSNT
   cObsNota   := SC5->C5_MENNOTA
   cJpcSep    := IIF(EMPTY(SC5->C5_JPCSEP),"N",SC5->C5_JPCSEP)

   If SC5->C5_TIPO == "N"
      DbSelectArea("SA1")
      DbSetOrder(1)
      DbSeek( xFilial("SA1") + cCliente)

      If !EOF()
         cCliente 	:= cCliente + " - " + SA1->A1_Nome
    	 cCGC 		:= SA1->A1_CGC
	     cIE 		:= SA1->A1_INSCR
      Endif
   Else
      DbSelectArea("SA2")
      DbSetOrder(1)
      DbSeek( xFilial("SA2") + cCliente)

      If !EOF()
         cCliente 	:= cCliente + " - " + SA2->A2_Nome
    	 cCGC 		:= SA2->A2_CGC
	     cIE 		:= SA2->A2_INSCR
      Endif
   Endif   

   DbSelectArea("SC5")

   DEFINE MSDIALOG FASPedB TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 000,000 TO 500,450 OF oMainWnd Pixel Style DS_MODALFRAME
// DEFINE MSDIALOG FASPedB TITLE "Alteracao dos dados de Embarque dos Pedidos de Venda" From 000,000 TO 300,450 OF oMainWnd Pixel Style DS_MODALFRAME

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
// @ 126,070 MsGet cObsNota Picture "@S60"		SIZE 120,010 OF FASPedB	Pixel
   @ 126,070 GET oMemo1 VAR cObsNota MEMO SIZE 150,115 PIXEL  OF FASPedB

   @ 045,160  BUTTON "Gravar"   Size 50,12 ACTION FGrava()		               OF FASPedB	Pixel
   @ 060,160  BUTTON "Abandona" Size 50,12 ACTION close(FasPedb)               OF FASPedB	Pixel
   @ 075,160  BUTTON "Etiqueta" Size 50,12 ACTION U_AUTOMR13(cPedVen, cVolume) OF FASPedB	Pixel

   ACTIVATE DIALOG FasPedb CENTER

Return

// ##################################################
// Função que grava dos dados da tela de embalagem ##
// ##################################################
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
	
	// Jean Rehermann - Solutio IT - 25/07/2012 | Criado log para alteração do C5_JPCSEP
	If cJpcSep != _cJPCSEP // Se foi alterado

		GravaLogSep("M", "", _cJPCSEP, cJpcSep)


	EndIf
	
    // ################################################################################################################################
	// Jean Rehermann - Se cancela a separação volta o status para 08-Aguardando Separação (verificando se item já não foi faturado) ##
	// ################################################################################################################################
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

/*
				If SC6->C6_STATUS == "08"

                   // ################################################################## 
                   // Altera o campo C5_LIBEROK liberando p pedido de venda novamente ##
                   // ##################################################################
			       DbSelectArea("SC5")
				   DbSetorder(1)
				   If DbSeek(xFilial("SC5") + SC6->C6_NUM)
    				  RecLock("SC5",.F.)
                      SC5->C5_LIBEROK := ""
  				      MsUnLock()                      
  				   Endif

                   // #######################################################
                   // Altera o Status do Pedido de venda para 01 novamente ##
                   // #######################################################
   				   RecLock("SC6",.F.)
				   SC6->C6_STATUS  := "01"
//				   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "01", "JPCACD01 (FGrava)" )
				   MsUnLock()                                              

                   // ######################################################################
                   // Elimina da tabela SC9 os registros referente ao pedido não separado ##
                   // ######################################################################
                   cSql := ""
                   cSql := "DELETE FROM " + RetSqlName("SC9")
                   cSql += " WHERE C9_FILIAL  = '" + Alltrim(SC6->C6_FILIAL)  + "'"
                   cSql += "   AND C9_CLIENTE = '" + Alltrim(SC6->C6_CLI)     + "'"
                   cSql += "   AND C9_LOJA    = '" + Alltrim(SC6->C6_LOJA)    + "'"
                   cSql += "   AND C9_PEDIDO  = '" + Alltrim(SC6->C6_NUM)     + "'"
//                 cSql += "   AND C9_PRODUTO = '" + Alltrim(SC6->C6_PRODUTO) + "'"
//                 cSql += "   AND C9_ITEM    = '" + Alltrim(SC6->C6_ITEM)    + "'"

                   _nErro := TcSqlExec(cSql) 

                   If TCSQLExec(cSql) < 0 
                      Alert(TCSQLERROR())
                   Endif


				EndIf

*/


                // ##########################################################################################################
				// Jean Rehermann - 26/11/2012 - Alterado avaliar apenas os itens que já estão na lojistica de faturamento ##
				// ##########################################################################################################
				If SC6->C6_STATUS == "10" .And. !U_Servico()

   				   RecLock("SC6",.F.)
				   SC6->C6_STATUS := "08"
				   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "08", "JPCACD01 (FGrava)" )
				   MsUnLock()


//					U_GravaSts("JPCACD01 (FGrava)")
				EndIf

                // #######################################################################
                // Se Status = 13 -> Aguardando Distribuidor, retornar para o Status 01 ##
                // #######################################################################
				If SC6->C6_STATUS == "13"

                   // #######################################################
                   // Altera o Status do Pedido de venda para 01 novamente ##
                   // #######################################################
   				   RecLock("SC6",.F.)
				   SC6->C6_STATUS := "01"
				   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "01", "JPCACD01 (FGrava)" )
				   MsUnLock()

				EndIf

				SC6->( dbSkip() )
			End
		EndIf
	EndIf

    // Se cliente for GKN, abre tela de divisão dos volumes por produtos
    //  If SC5->C5_CLIENTE == "000859"
    //     U_AUTOM270(SC5->C5_NUM, SC5->C5_CLIENTE, SC5->C5_LOJACLI)
    //  Endif

	DbSelectArea("SC5")
	Close( FasPedb)

Return

// ######################################################################################
// Funcao que realiza a verificacao da informacao do codigo ou nao de serie do produto ##
// ######################################################################################
User Function VldLote(p1)

   // ################################################
   // Valida a digitação de cada etiqueta do pacote ##
   // ################################################
   Local cMsg         := "Problema no Codigo Lote/SLote/NSerie : '" + cCodLote + "'" + chr(13) + chr(10)
   Local nContar      := 0
   Local lEstaContido := .F.

   Private lRetorno  := .t.
   Private _cTipoCod := "U"  //Undeffined
   Private _Botao    := 0
   
   If Empty(Alltrim(cCodLote))
      Return(.T.)
   Endif

   // ###########################################################################
   // Verifica se existe saldo a ser separado ainda para o produto selecionado ##
   // ###########################################################################
   If aLstBox[oLbx:nAt,6] == 0

      If lAlerta == .F.
   	     MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O produto " + ALLTRIM(aLstBox[oLbx:nAt,3]) + chr(13) + chr(10) + "já tem a quantidade completa separada !" + chr(13) + chr(10))
         cCodLote := Space(20)
	     oCodLote:Refresh()
      Else
         k_Mensagem := "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O produto " + ALLTRIM(aLstBox[oLbx:nAt,3]) + chr(13) + chr(10) + "já tem a quantidade completa separada !" + chr(13) + chr(10)
         SetaAlarme("S", ALLTRIM(cCodLote), k_Mensagem)
      Endif

      MsgTotal := MsgTotal + "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O produto " + ALLTRIM(aLstBox[oLbx:nAt,3]) + chr(13) + chr(10) + "já tem a quantidade completa separada !" + chr(13) + chr(10)
      Return(.F.)

   Endif

   // #############################################################################
   // Verifica se o nr. de serie informado ja esta contido na lista de separacao ##
   // #############################################################################
   If Posicione("SB1", 1, xFilial("SB1") + aLstBox[oLbx:nAt,2], "B1_LOCALIZ") == "S"

      lEstaContido := .F.

// 	  DbSelectArea("CONF")
//	  DbGoTop()
//	  Do While !eof()
//		 IF Alltrim(CONF->B1_CODBAR) == Alltrim(cCodLote)
//			lEstaContido := .T.
//            Exit
//		 Endif
//		 DbSelectArea("CONF")
//		 DbSkip()
//	  Enddo

      For nContar = 1 to Len(aProcura)
          If Alltrim(aProcura[nContar,01]) == Alltrim(aLstBox[oLbx:nAt,1]) .And. ;
             Alltrim(aProcura[nContar,02]) == Alltrim(aLstBox[oLbx:nAt,2])
             If Alltrim(aProcura[nContar,03]) == Alltrim(cCodLote)
                lEstaContido := .T.
                Exit
             Endif
          Endif
      Next nContar          

      If lEstaContido == .F.
         aAdd( aProcura, { Alltrim(aLstBox[oLbx:nAt,1]), Alltrim(aLstBox[oLbx:nAt,2]), Alltrim(cCodLote) } )
      Endif

      If lEstaContido

         If lAlerta == .F.
     	    MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O nº de série informado já está contido na lista de separação." + chr(13) + chr(10) + "Verifique nº de série informado!")
            cCodLote := Space(20)
            oCodLote:Refresh()
         Else            
            k_Mensagem := "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O nº de série informado já está contido na lista de separação." + chr(13) + chr(10) + "Verifique nº de série informado!"
            SetaAlarme("S", Alltrim(cCodLote), k_Mensagem)
         Endif

         MsgTotal := MsgTotal + "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O nº de série informado já está contido na lista de separação." + chr(13) + chr(10) + "Verifique nº de série informado!" + chr(13) + chr(10) 
         Return(.F.)

      Endif

   Endif

   cMsg += Replicate("-",39) + chr(13) + chr(10)

   If ! Empty(cCodLote)
      // #####################################
	  // Obrigo o Posicionamento do aLstBox ##
	  // #####################################
	  _nPosAlst := oLbx:nAt
	  _cCodProd := aLstBox[_nPosAlst,2]
	  _cLocProd := aLstBox[_nPosAlst,9] // Jean Rehermann - 21/08/2014 - Pego o armazém do produto no item selecionado da listbox
	
      // ############################################################
	  // Procuro o produto para ver se tem controle de Localizacao ##
	  // ############################################################
	  _cTipoCod:= IIF(Localiza(_cCodProd),"S","P")
						
	  DbSelectArea("SB1")
	  DbSetOrder(1)
	  DbSeek(xFilial("SB1") + _cCodProd)

	  IF _cTipoCod == "S"

         If Select("T_ARMAZEM") > 0
            T_ARMAZEM->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT BF_FILIAL ,"
         cSql += "       BF_PRODUTO,"
         cSql += "       BF_LOCAL  ,"
         cSql += "       BF_NUMSERI,"
         cSql += "       BF_QUANT  ,"
         cSql += "       BF_EMPENHO,"
         cSql += "       R_E_C_N_O_ "
         cSql += "  FROM " + RetSqlName("SBF")
         cSql += " WHERE BF_NUMSERI = '" + Alltrim(cCodLote) + "'"
         cSql += "   AND BF_LOCAL   = '"+ _cLocProd +"'" // Jean Rehermann - 22/08/2014 - Ajustado para considerar o armazém do item do pedido
         cSql += "   AND BF_PRODUTO = '" + Alltrim(_cCodProd) + "'"
         cSql += "   AND BF_EMPENHO = 0   "
         cSql += "   AND D_E_L_E_T_ = ''  "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ARMAZEM", .T., .T. )

         If T_ARMAZEM->( EOF() )

            If lAlerta == .F.
   			   Alert("Produto " + Alltrim(_cCodProd) + " com Controle de Enderecamento, mas Numero de Serie lido não é desse produto ou não tem saldo neste armazém !")
               cCodLote := Space(20)
               oCodLote:Refresh()
            Else
               k_Mensagem := "Produto " + Alltrim(_cCodProd) + " com Controle de Enderecamento, mas Numero de Serie lido não é desse produto ou não tem saldo neste armazém !"
               SetaAlarme("S", Alltrim(cCodLote), k_Mensagem)
            Endif   

            MsgTotal := MsgTotal + "Produto " + Alltrim(_cCodProd) + " com Controle de Enderecamento, mas Numero de Serie lido não é desse produto ou não tem saldo neste armazém !" + chr(10) + chr(10)
			lRetorno := .F.

		 Else
			dbSelectArea("SBF")
			SBF->( dbGoTo( T_ARMAZEM->R_E_C_N_O_ ) )
			T_ARMAZEM->( dbCloseArea() )
			lRetorno := .t.
		 Endif
	
	  ElseIf _cTipoCod == "P"
         // ##########################
         // Codigo de barras normal ##
         // ##########################
         If cEmpAnt == "01" .And. cFilAnt == "06"
   		    DbSelectArea("SB1")
		    DbSetOrder(1)		// B1_FILIAL, B1_CODBAR
		    DbSeek(xFilial("SB1") + cCodLote)
         Else            
   		    DbSelectArea("SB1")
		    DbSetOrder(5)		// B1_FILIAL, B1_CODBAR
		    DbSeek(xFilial("SB1") + cCodLote)
		 Endif

		 IF eof()

            // ###########################################
			// ops.. nem codigo de barras de produto eh ##
			// ###########################################
            If lAlerta == .F.
   			   ALERT("Codigo Invalido, nao identificado como numero de serie, nem como Codigo de barras do produto " + _cCodProd)
               cCodLote := Space(20)
               oCodLote:Refresh()
            Else
               k_Mensagem := "Codigo Invalido, nao identificado como numero de serie, nem como Codigo de barras do produto " + _cCodProd
               SetaAlarme("S", Alltrim(_cCodProd), k_Mensagem)
            Endif

            MsgTotal := MsgTotal + "Codigo Invalido, nao identificado como numero de serie, nem como Codigo de barras do produto " + _cCodProd + chr(13) + chr(10)

			lRetorno := .f.

		 Else

			lRetorno := .t.

		 ENDIF

	  Endif   

      // ###########################################
	  // Verifica se o Codigo ja nao foi "bipado" ##
	  // ###########################################
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
			
            // ################################################################################
			// Valida o codigo de barras do NUMERO DE SERIE e o produto e abate da pendencia ##
			// ################################################################################
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1") + SBF->BF_PRODUTO)
			
			IF FOUND()
				IF (SBF->BF_QUANT - SBF->BF_EMPENHO) <= 0
					lRetorno := .f.
					cMsg += "Lote "+cCodLote+" sem Saldo Disponivel " + chr(13) + chr(10)
                    MsgTotal := MsgTotal + "Lote " + cCodLote+" sem Saldo Disponível " + chr(13) + chr(10)
				ELSE
					cDescProd := SB1->B1_COD + " : " + SB1->B1_DESC
					cCodProd  := SBF->BF_PRODUTO
				ENDIF
			Else
				lRetorno := .f.
				cMsg += "Lote "+cCodLote+" nao Disponivel "+chr(13)+chr(10)
                MsgTotal := MsgTotal + "Lote " + cCodLote+" não Disponível " + chr(13) + chr(10)
			ENDIF

		 Else

            // ############################################################
			// Valida o Codigo de barras do PRODUTO e abate da pendencia ##
			// ############################################################
			DbSelectArea("SB2")
			DbSetorder(1)
//			DbSeek(xFilial("SB2")+SB1->B1_COD)
			DbSeek(xFilial("SB2")+SB1->B1_COD+_cLocProd) // Jean Rehermann - 21/08/2014 - Alterado para considerar o armazém no seek do SB2
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
				cMsg += "Produto " + cCodLote + " não Disponível " + chr(13) + chr(10)
                MsgTotal := MsgTotal + "Produto "+cCodLote+" não Disponível " + chr(13) + chr(10)
			ENDIF
 		 ENDIF

		 If lRetorno
			lRet2 := U_GETLBOX("ACONF")
			IF !lRet2
				cMsg += "O produto "+ALLTRIM(SB1->B1_DESC)+chr(13)+chr(10)
				cMsg += "ja tem a quantidade completa separada !"+chr(13)+chr(10)
				cMsg += "---------------------------------------"+chr(13)+chr(10)
                MsgTotal := MsgTotal + "O produto " + ALLTRIM(SB1->B1_DESC) + " já tem a quantidade completa separada !" + chr(13) + chr(10)
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
  
                // #############################################
                // Verifica se quantidade e igual a zero.     ##
                // Se for, para o processo por aqui e retorna ##
                // #############################################
                If _nQCodP == 0
                   cCodLote := Space(20)
                   If cEmpAnt = "01" .And. cFilAnt == "06"
                   Else
                      oCodLote:SetFocus()
                      oCodLote:Refresh()
                   Endif   
                   Return(.F.)
                Endif

 		        _XFor := _nQCodP

                // ############################################################################################
                // Este teste foi colocado pois existem pedidos de etiquetas com quantidade entre 0,1 a 0,9. ##
                // Com esta verificação, o Sistema permite separar quantidades fracionadas.                  ##
                // ############################################################################################
                If U_P_CORTA(Alltrim(Str(_nQCodP)) + ".",".", 1) == "0" .And. ;
                   U_P_CORTA(Alltrim(Str(_nQCodP)) + ".",".", 2) <> "0"
		           _XFor := 1
		        Endif   

//		        _XFor := iif(_nQCodP>0,_nQCodP,1) // Gerson - _nQCodP alimentado em GetlBox(p1)p/produtos _cTipoCod == "P"

				For _nX := 1 to _XFor
					Reclock("CONF",.t.)
					CONF->B1_CODBAR := cCodLote
					CONF->B1_COD    := _cCodProd
					CONF->(MsUnlock())
				Next

				DbGoTop()

                // #####################################################################################################################
                // Atualiza o List da tela                                                                                            ##
                // oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf) ##
                // #####################################################################################################################
			    oGetDb2 := MsGetDB():New(20,40,235,150,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)

				//@ 015,010 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL

			    If _XFor > 0            
  			       // Atualiza o ListBox
				   U_GetlBox("ATUAL")	
			    Endif   
			Endif

		 Else

			cMsg += "" + chr(13)+chr(10)
		 
			If lAlerta ==.F.
   			   MsgAlert(cMsg,ProcName())
               cCodLote := Space(20)
               oCodLote:Refresh()
   			Else
               k_Mensagem := cMsg
               SetaAlarme("S", Alltrim(cCodLote), k_Mensagem)
            Endif
			cMsg := ""
		 EndIf
		
	  Endif
	
	  oGetDb2:ForceRefresh()

	  //oLbx:Refresh()
	
      // ################################################################
	  // Caso o produto possua RASTRO, exige a leitura do Lote/Sublote ##
	  // ################################################################
      If cEmpAnt == "01" .And. cFilAnt == "06"
      Else
         oCodLote:SetFocus()
	     oCodLote:Disable() 
	     oCodLote:Enable() 
         //cCodLote := Space(10)
         cCodLote := Space(20)
         oCodLote:Refresh()
	  Endif
	  
      oDlgConf:Refresh()                                                            
	 
   EndIf

   DbSelectArea("CONF")
   DbGoTop()

   If cEmpAnt == "01" .And. cFilAnt == "06"
   Else
      // oGetDb2:oBrowse:Refresh()
      cCodLote := Space(20)
      oCodLote:SetFocus()
      oCodLote:Refresh()
   Endif   
      
   oLbx:Refresh()

   DbSelectArea("CONF")

   // ------------------------------------------ //
   // Regra para liberar o botão OK na Separação //
   // Se Diferença  == 0, Libera                 //
   // Se Qtd. do PV == Diferença, Libera         //
   // ------------------------------------------ //
   //   If Type("_nPosAlst") <> "U"
   //      If aLstBox[_nPosAlst,6] == 0 .OR. (aLstBox[_nPosAlst,4] == aLstBox[_nPosAlst,6])
   //         lLibera := .T.
   //      Else
   //         lLibera := .F.   
   //      Endif   
   //   Endif   

   // ##############################################################
   // Verifica se pode liberar o botão de OK da tela de separação ##
   // ##############################################################
   lLibera := .T.

   For nContar = 1 to Len(aLstBox)
       If aLstBox[nContar,04] <> aLstBox[nContar,05]
          lLibera := .F.
          Exit
       Endif
   Next nContar           

   // Refresca a tela
   oLbx:Refresh()
   oLbx:SetFocus()

   If cEmpAnt == "01" .And. cFilAnt == "06"
   Else
      //oGetDb2:oBrowse:Refresh()
      cCodLote := Space(20)
      oCodLote:Refresh()
      oCodLote:SetFocus()
   Endif   

Return(lRetorno)

// ###################################################
// Função que verifica o código de barras informado ##
// ###################################################
User Function VldCdBr(p1)

   // ################################################
   // Valida a digitacao de cada etiqueta do pacote ##
   // ################################################
   Local cMsg := "Problema no Codigo de Barras : '"+cCodBarr+"'"+chr(13)+chr(10)

   //MsgAlert(cCodBarr,ProcName())
   Private lRetorno := .t.

   cMsg += Replicate("-",39) + chr(13) + chr(10)

   If ! Empty(cCodBarr)
	
      // #############################################################
      // Valida o codigo de barras e o produto e abate da pendencia ##
      // #############################################################
	   DbSelectArea("SB1")
	   DbSetOrder(5)   //B1_FILIAL+B1_CODBAR
	   DbSeek(xFilial("SB1") + cCodBarr)

   	   IF FOUND()
		  cDescProd := SB1->B1_COD + " : " + SB1->B1_DESC
	      cCodProd  := SB1->B1_COD
	   ENDIF
	
       // ###################################################
	   // Testa se ja conferi toda a quantidade disponivel ##
	   // ###################################################
	   lRetorno := U_GETLBOX("ACONF")
	   IF !lRetorno
		  cMsg += "O produto " + ALLTRIM(SB1->B1_DESC)      + chr(13) + chr(10)
		  cMsg += "ja tem a quantidade completa separada !" + chr(13) + chr(10)
		  cMsg += "---------------------------------------" + chr(13) + chr(10)
	   Endif
	
	   If lRetorno
		  DbSelectArea("CONF")
		  Reclock("CONF",.t.)
		  CONF->B1_CODBAR := cCodBarr
		  CONF->(MsUnlock())
		
		  //oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
	      oGetDb2 := MsGetDB():New(20,40,235,150,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)
		  //@ 015,010 SAY cDescProd SIZE 100,10 OF oDlgConf PIXEL
		
		  U_GetlBox("ATUAL")	// Atualiza o ListBox
		
	   Else
		  cMsg += ""+chr(13)+chr(10)

          If lAlerta == .F.
   		     MsgAlert(cMsg,ProcName())
             cCodLote := Space(20)
             oCodLote:Refresh()
          Else
             k_Mensagem := cMsg
             SetaAlarme("S", Alltrim(cCodBarr), k_Mensagem)
          Endif   
		  cMsg := ""
	   EndIf
	
	   oGetDb2:ForceRefresh()
	   oLbx:Refresh()
	
       // ################################################################
	   // Caso o produto possua RASTRO, exige a leitura do Lote/Sublote ##
	   // ################################################################
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

// ## ###################################################
// Função que centraliza o tratamento do array aLstBox ##
// ######################################################
User Function GetlBox(p1)

   Local lRet     := .t.
   Local _nQtd    := 0	// JPC Gerson - 16.06.11
   Local _xpedido := Space(06)   

   For _n := 1 to Len(aLstBox)
       
       // #####################
       // Atualiza o ListBox ##
       // #####################	
	   IF p1 == "ATUAL"   
		
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

             // #############################################################################
             // Alteração realizada em 16/12/2014 por Harald Hans Löschenkohl              ##
             // Existem pedidos de etiquetas que são de quantidade 0.5 milheiros           ##
             // Com o teste abaixo, nunca era possível de ser separado quantidades < que 1 ##
             // IF _nQtd >= 1                                                              ##
             // #############################################################################
        	 IF _nQtd <> 0  
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

// ################
// Função CFTDOK ##
// ################
User Function CFTDOK

Return(.t.)

// ######################################################
// Função que realiza a impressão gráfica da separação ##
// ######################################################
User Function JPCSEPGRF

   LOCAL oFont8 , oFont9 , oFont10 , oFont11 , oFont12 , oFont14 , oFont16 , oFont24, oBrush, nCnt
   LOCAL oFont8N, oFont9N, oFont10N, oFont11N, oFont12N, oFont14N, oFont16n, oFont26
   LOCAL cTitl  , cCart  , cFato   , nValr   , cValr   , cNBco   , cDBco   , cCont  , cBole , cNNum
   LOCAL cDNum  , cNoss  , cBarr   , cDBar   , cLinh   , cAgen   , cDcAg   , cNmCC  , cDcNc
   LOCAL cSql

   // ############################
   // Parâmetros de TFont.New() ##
   // 1.Nome da Fonte (Windows) ##
   // 3.Tamanho em Pixels       ##
   // 5.Bold (T/F)              ##
   // ############################

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
   oPrint:StartPage()   // Inicia uma nova página

   oPrint:Box  (0050, 0200, 3140, 2400)    	// Box da borda da página
   oPrint:Line (0240, 0200, 0240, 2400)        // Linha do Topo
   oPrint:Line (0320, 0200, 0320, 2400)        // Linha do Topo
   oPrint:Line (0240, 2200, 3140, 2200)    	// Linha Coluna 3
   oPrint:Line (0240, 2000, 3140, 2000)    	// Linha Coluna 2
   oPrint:Line (0240, 1800, 3140, 1800)    	// Linha Coluna 1

   //oPrint:SayBitmap (0052, 0205, "LogoJPC.bmp", 0240, 0180)  //logo da Empresa

   oPrint:Say  (0090, 0800, " Lista de Separação - PV "+SEPARA->C5_NUM , oFont24)
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
		 oPrint:EndPage()   // Inicia uma nova página
		 oPrint:StartPage()   // Inicia uma nova página
		 oPrint:Box  (0050, 0200, 3140, 2400)    	// Box da borda da página
		 oPrint:Line (0240, 0200, 0240, 2400)        // Linha do Topo
		 oPrint:Line (0320, 0200, 0320, 2400)        // Linha do Topo
		 oPrint:Line (0240, 2200, 3140, 2200)    	// Linha Coluna 3
		 oPrint:Line (0240, 2000, 3140, 2000)    	// Linha Coluna 2
		 oPrint:Line (0240, 1800, 3140, 1800)    	// Linha Coluna 1
		
		 //oPrint:SayBitmap (0052, 0205, "LogoJPC.bmp", 0240, 0180)  //logo da Empresa
		
		 oPrint:Say  (0090, 0800, " Lista de Separação - PV "+SEPARA->C5_NUM, oFont24)
		 oPrint:Say  (0170, 0820, ALLTRIM(SEPARA->A1_NREDUZ), oFont12)
		
		 oPrint:Say  (0260, 0800, " Item + Produto    ", oFont12N )
		 oPrint:Say  (0260, 1850, " Quant "            , oFont12N )
		 oPrint:Say  (0260, 2050, " Lote " 			  , oFont12N )
		 oPrint:Say  (0260, 2200, " Num.Serie "        , oFont12N )
		
	  Endif
	
   Enddo

   oPrint:EndPage()   	// Finaliza página
   oPrint:Preview()    // Visualiza antes de imprimir

   DbSelectArea("PEDSEP")
   DbCloseArea()

Return(.t.)

// #################################################
// Função que imprime lista de sepração matricial ##
// #################################################
User Function JPCSEPMAT

   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Lista de Separacao"
   Local titulo         := "Lista de Separacao - PV "+SEPARA->C5_NUM+" / "+SEPARA->A1_NREDUZ
   Local nLin           := 80					// Numero maximo de linhas
   Local cOrd           := ""					// Ordem selecionada
   Local Cabec1         := " Item + Produto                                                                        Quant     Lote            Num.Serie  "
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

   // #########################################
   // Monta a interface padrao com o usuario ##
   // #########################################
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

   // #########################
   // Impressao do relatorio ##
   // #########################
   RptStatus({|| MATRICIAL(	Cabec1		, Cabec2, Titulo, nLin ) } ,Titulo)

Return

// #########################################
// Função que imprime relatório matricial ##
// #########################################
Static Function MATRICIAL(Cabec1 ,Cabec2 ,Titulo,	nLin)

   LOCAL cSql

   cSql := ""
   cSql += " SELECT SC9.*, SB1.B1_CODBAR, SB1.B1_DESC "
   cSql += " FROM " + RetSqlName("SC9") +" SC9, " + RetSqlName("SB1") + " SB1 "
   cSql += " WHERE SC9.C9_PEDIDO = '" + SEPARA->C5_NUM + "' AND "
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
	
	  @ nLin,001 PSAY PEDSEP->C9_ITEM + "-" + PEDSEP->B1_DESC + " - "+PEDSEP->B1_CODBAR+" | "+;
	  TRANSFORM(PEDSEP->C9_QTDLIB  ,"@E 999,999.99"    )+" | "+;
	  PEDSEP->C9_LOTECTL+" | "+PEDSEP->C9_NUMSERI
	
	  DbSelectArea("PEDSEP")
	  DbSkip()
	
   Enddo

   DbSelectArea("PEDSEP")
   DbCloseArea()
 
   // ##########################################################
   // Se impressao em disco, chama o gerenciador de impressao ##
   // ##########################################################
   If aReturn[5]==1
  	  dbCommitAll()
	  SET PRINTER TO
	  OurSpool(wnrel)
   Endif

   // #############################################################
   // Descarrega o Cache armazenado na memoria para a impressora ##
   // #############################################################
   MS_FLUSH()

Return(.t.)

// #################
// Função SFPTDOK ##
// #################
User Function SEPTDOK

Return(.t.)

// #########################################
// Função que carrega o grid de separação ##
// #########################################
Static Function GeraArq()

   Local lRetorno  := .t.
   Local cQuery    := ""
   Local _cArqC1   := ""
   Local cTranspo  := ""
	
   _aArqC1   := {}
   aHeader   := {}
	
   cQuery := " SELECT SC5.C5_NUM, SC5.C5_VEND1 ,SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA1.A1_NREDUZ, SA1.A1_MUNE, SA1.A1_BAIRRO, SA1.A1_MUN, SA1.A1_EST, SA1.A1_TEL, SC5.C5_TRANSP "+CHR(13)
   cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "+CHR(13)
   cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA "+CHR(13)
   cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO <>'B' "+CHR(13)
   cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' '  OR SC5.C5_JPCSEP = 'P') "+CHR(13)

   // ########################################################################################################################################## 
   // Jean Rehermann - Inserida a condição de só aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens ##
   // ##########################################################################################################################################
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
	
   cQuery += " SELECT SC5.C5_NUM, SC5.C5_VEND1, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA2.A2_NREDUZ, SA2.A2_MUN, SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST, SA2.A2_TEL, SC5.C5_TRANSP  "+CHR(13)
   cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA2")+" SA2 "+CHR(13)
   cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA2.A2_COD AND SC5.C5_LOJACLI = SA2.A2_LOJA "+CHR(13)
   cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO = 'B' "+CHR(13)
   cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' ' OR SC5.C5_JPCSEP = 'P')"+CHR(13)

   // ##########################################################################################################################################
   // Jean Rehermann - Inserida a condição de só aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens ##
   // ##########################################################################################################################################
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
	
      // ########################################################
	  // CRIA ARQUIVO TEMPORARIO - Declara Arrays p/ Consultas ##
	  // ########################################################
	  AADD(_aArqC1,{"C5_NUM" 	, "C",  6, 0})
	  AADD(_aArqC1,{"C5_CLIENTE", "C",  6, 0})
	  AADD(_aArqC1,{"C5_LOJACLI", "C",  3, 0})
	  AADD(_aArqC1,{"C5_TIPO"	, "C",  1, 0})
	  AADD(_aArqC1,{"A1_NREDUZ"	, "C", 30, 0})
	  AADD(_aArqC1,{"A1_MUNE"	, "C", 30, 0})
	  AADD(_aArqC1,{"A1_BAIRRO"	, "C", 30, 0})
	  AADD(_aArqC1,{"A1_MUN"	, "C", 30, 0})
	  AADD(_aArqC1,{"A1_EST"	, "C",  2, 0})	  
	  AADD(_aArqC1,{"A1_TEL"	, "C", 15, 0})
	  AADD(_aArqC1,{"LEXCL"		, "L",  1, 0})
	  nUsado := LEN(_aArqC1) - 1
	  	
	  AADD(aHeader,{"Pedido"    	, "C5_NUM"	  , "@X" ,  6, 0, ".T.", USADO, "C", "", ""})
	  AADD(aHeader,{"Cliente"   	, "C5_CLIENTE", "@X" ,  6, 0, ".t.", USADO, "C", "", ""})
	  AADD(aHeader,{"Loja"      	, "C5_LOJACLI", "@X" ,  3, 0, ".t.", USADO, "C", "", ""})
	  AADD(aHeader,{"Nome Reduzido"	, "A1_NREDUZ" , "@X" , 30, 0, ".T.", USADO, "C", "", ""})
    //AADD(aHeader,{"Mun.Entrega"	, "A1_MUNE"   , "@X" , 30, 0, ".t.", USADO, "C", "", ""})
 	  AADD(aHeader,{"Transportada" 	,"A1_MUNE"    , "@X" , 30, 0, ".t.", USADO, "C", "", ""})
	  AADD(aHeader,{"Bairro"     	,"A1_BAIRRO"  , "@X" , 30, 0, ".t.", USADO, "C", "", ""})
	  AADD(aHeader,{"Cidade"     	,"A1_MUN"     , "@X" , 30, 0, ".t.", USADO, "C", "", ""})
	  AADD(aHeader,{"UF"        	,"A1_EST"     , "@X" ,  2, 0, ".t.", USADO, "C", "", ""})
	  AADD(aHeader,{"Telefone"  	,"A1_TEL"	  , "@X" , 15, 0, ".t.", USADO, "C", "", ""})

      // ##################################
	  // Arquivo Auxiliar para Consultas ##
	  // ##################################
	  _cArqC1 := CriaTrab(_aArqC1,.T.)

      If Select("SEPARA") > 0
         SEPARA->( dbCloseArea() )
      EndIf

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

            // ############################
            // Pesquisa a Transportadora ##
            // ############################
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
			A1_NREDUZ	:= IIF(TRB->C5_VEND1 == "000119", "***** " + Alltrim(TRB->A1_NREDUZ) + " *****", Alltrim(TRB->A1_NREDUZ))
          //A1_MUNE 	:= TRB->A1_MUNE
			A1_MUNE 	:= cTranspo
			A1_BAIRRO	:= TRB->A1_BAIRRO
            A1_MUN      := TRB->A1_MUN
            A1_EST      := TRB->A1_EST
			A1_TEL      := TRB->A1_TEL
			MsUnlock()
		 ENDIF
		 dbSelectArea("TRB")
		 dbSkip()
  	  Enddo
		
   Else

  	  MsgStop(" Não foram encontrados mais pedidos para Separação ! ")
	  lRetorno := .f.

   Endif
	
   TRB->(dbCloseArea())

Return(lRetorno)

// ##################################################################### 
// Função que dá refresh da tela do list de separação (Atualiza List) ##
// #####################################################################
User Function MtaConf

   aLstBox := {}
   lret    := .t.

   // ########################################################
   // CRIA ARQUIVO TEMPORARIO - Declara Arrays p/ Consultas ##
   // ########################################################
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

   // ##################################
   // Arquivo Auxiliar para Consultas ##
   // ##################################
   _cArqC2 := CriaTrab(_aArqC2,.T.)
   dbUseArea(.T.,,_cArqC2,"CONF")
    
   // #################################
   // Index on B1_CODBAR to &_cArqC2 ##
   // #################################
   cSql := ""
   cSql += " SELECT SC9.*         ,"
   cSql += "        SB1.B1_CODBAR ,"
   cSql += "        SB1.B1_DESC   ," 
   cSql += "        SB1.B1_LOCALIZ," 
   cSql += "        SB1.B1_RASTRO  "
   cSql += "   FROM " + RetSqlName("SC9") + " SC9, "
   cSql += "        " + RetSqlName("SB1") + " SB1  "
   cSql += "  WHERE SC9.C9_PEDIDO   = '" + SEPARA->C5_NUM +"'"
   cSql += "    AND SC9.D_E_L_E_T_  = ' ' "

   /*If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")
   Else
       cSql += "    AND SC9.C9_BLEST   <> '  '"
   Endif
   */
   cSql += "    AND SC9.C9_BLCRED   = ' ' "
   cSql += "    AND SB1.B1_COD      = SC9.C9_PRODUTO"
   cSql += "    AND SB1.D_E_L_E_T_  = ' ' "
   cSql += "  ORDER BY C9_ITEM"

   dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"PEDSEP", .F., .T.)

   DbSelectArea("PEDSEP")
   DbGoTop()
   
   Do While !eof()
   	  If U_PrdEhEtq(PEDSEP->C9_PRODUTO)
      Else
         If Alltrim(PEDSEP->C9_BLEST) == "" 
            DbSelectArea("PEDSEP")
            DbSkip()
            Loop
         Endif
      Endif 
   		
      DbSelectArea("SC6")
      DbSetOrder(1)
      DbSeek(xFilial("SC6") + SEPARA->C5_NUM + PEDSEP->C9_ITEM + PEDSEP->C9_PRODUTO)

      cTes := SC6->C6_TES
    
      DbSelectArea("SF4")
      DbSetOrder(1)
      DbSeek(xFilial("SF4")+cTes)
  
      // ################################################################################################################
      // Jean Rehermann | JPC - Apenas aparece para separar o item que tiver status 08-Aguardando Separação de Estoque ##
      // ################################################################################################################
      IF SF4->F4_ESTOQUE == "S" .And. SC6->C6_STATUS == "08"

	     aAdd(aLstBox,{PEDSEP->C9_ITEM   ,;
	                   PEDSEP->C9_PRODUTO,;
	                   PEDSEP->B1_DESC   ,;
	                   PEDSEP->C9_QTDLIB ,;
	                   0                 ,;
           	           PEDSEP->C9_QTDLIB ,;
           	           PEDSEP->C9_LOTECTL + PEDSEP->C9_NUMLOTE,;
           	           PEDSEP->C9_NUMSERI,;
           	           PEDSEP->C9_LOCAL  ,;
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

// #####################################################################################################################
// Função que abre tela de informação do nº do pedido de venda e quantidade para produtos sem controle de nº de série ##
// #####################################################################################################################
Static Function JPCGQTD(_nQtd, _xPedido)

   DEFAULT _nQtd	:= 1.00
   DEFAULT _xPedido := Space(06)

   // ####################################################################################
   // Verifica se o código do produto informado é o mesmo que está seleciionado no list ##
   // ####################################################################################
   DbSelectArea("SB1")
   If cEmpAnt == "01" .And. cFilAnt == "06"
      DbSetOrder(1)
   Else
      DbSetOrder(5)      
   Endif   
   If DbSeek(xFilial("SB1") + cCodLote)
      If cEmpAnt == "01" .And. cFilAnt == "06"
      Else 
         If Alltrim(cCodLote) <> Alltrim(SB1->B1_CODBAR)
            //Alltrim(aLstBox[oLbx:nAt,2])
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código do produto informado não corresponde ao código do produto selecionado na lista. Verifique!" + chr(13) + chr(10))
            MsgTotal := MsgTotal + "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código do produto informado não corresponde ao código do produto selecionado na lista. Verifique!" + chr(13) + chr(10)
            nOpca := 0
            Return 0
         Endif
      Endif   
   Else
      MsgAlert("Produto " + Alltrim(cCodLote) + " não localizado na base de dados do Sistema. Verifique digitação!")
      MsgTotal := MsgTotal + "Produto " + Alltrim(cCodLote) + " não localizado na base de dados do Sistema. Verifique digitação!" + chr(13) + chr(10)
      nOpca := 0
      Return 0
   Endif
      
   // ######################################################
   // Desenha atela par informação do pedido + quantidade ##
   // ######################################################
   DEFINE MSDIALOG oDlg1 TITLE "Informe a quantidade" FROM 33,25 TO 110,349 PIXEL Style DS_MODALFRAME

   oDlg1:lEscClose := .F.

   @ 01,05 TO 033, 128 OF oDlg1 PIXEL

   @ 08,08 SAY "Nº Pedido"  SIZE 55, 7 OF oDlg1 PIXEL  
   @ 08,60 SAY "Quantidade" SIZE 55, 7 OF oDlg1 PIXEL  

   @ 18,08 MSGET _xPedido SIZE 40, 11 OF oDlg1 PIXEL Picture "@!" VALID CONFPEDIDO(_xPedido)

// If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilant == "07")

   If (LEFT(SB1->B1_COD,2) == "02" .Or. LEFT(SB1->B1_COD,2) == "03")

   	  DbSelectArea("SB2")
      DbSetorder(1)
      If DbSeek(xFilial("SB2") + SB1->B1_COD + "01")
         kSaldoProd := SB2->B2_QATU - SB2->B2_QACLASS - SB2->B2_QTNP
      Else
         kSaldoProd := 0
      Endif

//      @ 18,60 MSGET _nQtd    SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15) VALID ;
//                             !empty(iif(_nQtd > kSaldoProd .or. _nQtd <> aLstBox[_nPosAlst,4]  ,eval({|| Help ( " ", 1, "SLDSB2/SALDO A SEPARAR" ),0}),_nQtd))

      @ 18,60 MSGET _nQtd    SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15)

   Else

//      @ 18,60 MSGET _nQtd    SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15) VALID ;
//                             !empty(iif(_nQtd > SaldoSb2() .or. _nQtd <> aLstBox[_nPosAlst,4]  ,eval({|| Help ( " ", 1, "SLDSB2/SALDO A SEPARAR" ),0}),_nQtd))

      @ 18,60 MSGET _nQtd    SIZE 57, 11 OF oDlg1 PIXEL Picture PesqPict("SB2","B2_QATU",15) 

   Endif

   // aLstBox[_nPosAlst,4] eh a posicao da quantidade a ser separada, nao permite digitar quantidade maior que o solicitado, tambem valida o saldosb2	

// DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End())            ENABLE OF oDlg1

   DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION ( CHECASALDO(_nQtd) )            ENABLE OF oDlg1
   DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End(),_nQtd := 0) ENABLE OF oDlg1                                                                                                

   ACTIVATE MSDIALOG oDlg1 CENTERED
		
Return _nQtd

// #######################################################################################################################
// Função que valida a quantidade informada do produto. Verifica se produto pode ser separado pela qunatidade informada ##
// #######################################################################################################################
Static Function ChecaSaldo(_nQtd)

   If _nQtd == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidade não informada." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif   

// If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilant == "07")

   If (LEFT(SB1->B1_COD,2) == "02" .Or. LEFT(SB1->B1_COD,2) == "03")

      If _nQtd > kSaldoProd .Or. _nQtd <> aLstBox[_nPosAlst,4]
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidade a ser separada inconsistente com a quantidade do pedido de venda." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif   

   Else   

      If _nQtd > SaldoSb2() .Or. _nQtd <> aLstBox[_nPosAlst,4]
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidade a ser separada inconsistente com a quantidade do pedido de venda." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif   
      
   Endif
   
   nOpca := 1
   
   oDlg1:End()      

Return _nQtd


// ############################################################################################################
// Função que abre Janela para informação do nº do pedido de venda na separação para produto com nº de série ##
// ############################################################################################################
Static Function _JPCGQTD(_xPedido)

   DEFAULT _xPedido := Space(06)
  
   _xPedido := cCodPedido  // Adicionado Michel Aoki
   nOpca := 1
   _Botao := 1

  //Comentado Michel Aoki                     
  //DEFINE MSDIALOG oDlg1 TITLE "Informe o Nº do Pedido de Venda" FROM 33,25 TO 110,349 PIXEL  
  //
  //@ 01,05 TO 033, 128 OF oDlg1 PIXEL
  //
  //@ 08,08 SAY "Nº Pedido"  SIZE 55, 7 OF oDlg1 PIXEL  
  //
  //@ 18,08 MSGET _xPedido SIZE 40, 11 OF oDlg1 PIXEL Picture "@!" VALID CONFPEDIDO(_xPedido)
  //
  //DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1, _Botao := 1, oDlg1:End()) ENABLE OF oDlg1
  //DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0, _Botao := 2, oDlg1:End()) ENABLE OF oDlg1
  //
  //ACTIVATE MSDIALOG oDlg1 CENTERED

Return _Botao

// ################################################################################################
// Harald Hans Löschenkohl - Verifica se o produto pertence ao pedido lido pelo código de barras ##
// ################################################################################################
Static Function CONFPEDIDO(___Pedido)

   If Empty(Alltrim(___Pedido))
      Return .F.
   Endif
   
   If Alltrim(___Pedido) <> Alltrim(SEPARA->C5_NUM)
      MsgAlert("Pedido Inválido.")
      MsgTotal := MsgTotal + "Pedido Inválido." + chr(13) + chr(10)
      Return .F.
   Endif
   
Return .T.

// ###################################################################################################################
// Jean Rehermann - Acionado pelo botão Parâmetros na tela da separação                                             ##
// Serve para atualizar o campo C6_TEMDOC, controla necessidade de recebimento de documento antes de liberar o item ##
// ###################################################################################################################
Static Function StsDoc()                                                                                           

	Local cFiltros := "C6_TEMDOC<>'R' AND C6_STATUS NOT IN ('11','12')"
	
	Local aCores := {{"C6_TEMDOC=='S'",'ENABLE' },; // Aguardando cliente
					{ "C6_TEMDOC$' N'",'DISABLE'}}  // Não aguarda cliente

	Private cCadastro := "Liberação de documentação"
	Private cAlias1   := "SC6"
	Private aCampos   := {{"Pedido","C6_NUM"},;
						  {"Item","C6_ITEM"},;
						  {"Status","C6_STATUS"},;
						  {"Produto","C6_PRODUTO"},;
						  {"Descrição","C6_DESCRI"},;
						  {"Quantidade","C6_QTDVEN"},;
						  {"Unitário","C6_PRCVEN"},;
						  {"Total","C6_VALOR"} }

	Private aHeader := {}, aCols := {}
	
	Private aRotina   := {	{ "Pesquisar", "AxPesqui" , 0, 1 },;
							{ "Documento", "U_StsDocL", 0, 2 },;
	                        { "Lengenda" , "U_LegDoc" , 0, 2 } }

	Private cDelFunc := ".T." // Criar rotina para validar a exclusao (locacao em aberto não pode ser excluida)

	mBrowse( 06, 01, 22, 75, "SC6",aCampos,,,,,aCores,,,,,.F.,,,cFiltros)

Return

// ####################################################
// Programa para mostrar a legenda de cores (status) ##
// ####################################################
User Function LegDoc()
	BrwLegenda(cCadastro, 'Legenda', {{'ENABLE' ,    'Aguardando documentação do cliente'},;
        	                          {'DISABLE',    'Não aguarda documentação do cliente'}})
Return( nil )

// ##############################################################
// Jean Rehermann - Efetua a alteração do status, se necesário ##
// ##############################################################
User Function StsDocL()

	Private cDoc := Iif( Empty( AllTrim( SC6->C6_TEMDOC ) ), "N", SC6->C6_TEMDOC )
	Private oDoc
	
	DEFINE MSDIALOG oDlgStsDoc TITLE "Aguarda documentação do cliente?" From 00,000 TO 100,230 OF oMainWnd Pixel Style DS_MODALFRAME
		@ 12,010 Say "Documentação:" OF oDlgStsDoc Pixel
		@ 10,050 ComboBox oDoc Var cDoc ITEMS { "N=Não","S=Sim","R=Recebido"} SIZE 040,010 OF oDlgStsDoc Pixel
		DEFINE SBUTTON FROM 30,010 TYPE 01 ACTION (GrvStsDoc())	    OF oDlgStsDoc ENABLE Pixel
		DEFINE SBUTTON FROM 30,040 TYPE 02 ACTION (Close(oDlgStsDoc))	OF oDlgStsDoc ENABLE Pixel
	ACTIVATE DIALOG oDlgStsDoc CENTER

Return()

// ###################################################################################
// Jean Rehermann - Grava a opção no item do pedido e altera o status se necessário ##
// ###################################################################################
Static Function GrvStsDoc()

	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek( xFilial("SC6") + SC6->C6_NUM + SC6->C6_ITEM )
	
	dbSelectArea("SC6")
	
	RecLock("SC6", .F.)
	SC6->C6_TEMDOC := cDoc
	
	If cDoc == "S"
       // #############################################################################################
	   // Jean Rehermann - 16/07/2012 - Independente de qual status sempre fica aguardando o cliente ##
	   // If SC6->C6_STATUS == "10"  // Aguardando Faturamento                                       ##
	   // #############################################################################################
	   SC6->C6_STATUS := "09" // Aguardando Documentação cliente
	   U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "09", "JPCACD01-DOC" ) // Gravo o log de atualização de status na tabela ZZ0
	   //EndIf
	ElseIf cDoc $ "NR "
	   If SC6->C6_STATUS == "09"  // Aguardando Documentação cliente
          // ###################################################################################################################################
	   	  // Jean Rehermann - 16/07/2012 - Atualiza o status analisando a situação atual do pedido                                            ##
		  // SC6->C6_STATUS := "10" // Aguardando Faturamento                                                                                 ##
		  // U_GrvLogSts( SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "10", "JPCACD01" ) // Gravo o log de atualização de status na tabela ZZ0 ##
		  // ###################################################################################################################################
		  U_GravaSts("JPCACD01-DOC")
	   EndIf
	EndIf
	MsUnLock()
	Close(oDlgStsDoc)
	
Return()

// ################################################################
// Jean Rehermann - Seleciona o PV para gravar dados do embarque ##
// ################################################################
User Function xxxxxxEmbarque()

	Private cNumNF := Space(9)
	Private oNumNf
	Private cSerNF := Space(3)
	Private oSerNf
	
	DEFINE MSDIALOG FASPedA TITLE "Expedição de Mercadoria" From 00,000 TO 100,220 OF oMainWnd Pixel Style DS_MODALFRAME

    @ 030,065 BUTTON "Consulta"  Size 40,11 ACTION (MostraCan()) OF FasPedA PIXEL
	@ 10,005 Say "Nota Fiscal:"   OF FASPedA Pixel
	@ 10,040 MsGet oNumNf Var cNumNF PICTURE "@X" SIZE 040,010 OF FASPedA Pixel F3 "SF2EMB" VALID !Empty( cNumNF )
	@ 10,085 MsGet oSerNf Var cSerNF PICTURE "@X" SIZE 020,010 OF FASPedA Pixel

	DEFINE SBUTTON FROM 30,005 TYPE 01 ACTION (FConfEmb())	    OF FasPedA ENABLE Pixel
	DEFINE SBUTTON FROM 30,035 TYPE 02 ACTION (Close(FasPedA))	OF FasPedA ENABLE Pixel

	ACTIVATE DIALOG FasPedA CENTER

Return

// ################################################
// Jean Rehermann - Inserir os dados do embarque ##
// ################################################
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

		  DEFINE MSDIALOG FASPedB TITLE "Dados de Expedição" From 000,000 TO 150,400 OF oMainWnd Pixel Style DS_MODALFRAME

		  @ 010,010 Say "Nr.do Ped.Venda :"                   OF FASPedB Pixel
		  @ 010,070 say SD2->D2_PEDIDO                        OF FASPedB Pixel
		  @ 020,010 Say "Nr. Nota Fiscal :"                   OF FASPedB Pixel
		  @ 020,070 say cNumNF +"/"+ cSerNf                   OF FASPedB Pixel
		  @ 037,010 Say "Hora: "                              OF FASPedB Pixel
		  @ 037,070 MsGet _cHora Picture "99:99" SIZE 040,010 OF FASPedB Pixel
		  @ 049,010 Say "Nº Conhecimento: "                   OF FASPedB Pixel
		  @ 049,070 MsGet _cNumF Picture "!@"	   SIZE 070,010 OF FASPedB Pixel
		
		  @ 005,145  BUTTON "Etiqueta" Size 50,12 ACTION E_Etiqueta(SC5->C5_VOLUME1, SD2->D2_PEDIDO, cNumNF, cSerNF) OF FASPedB Pixel
		
		  @ 033,145  BUTTON "Gravar"   Size 50,12 ACTION FGravaJ()      OF FASPedB Pixel
		  @ 048,145  BUTTON "Abandona" Size 50,12 ACTION close(FasPedb) OF FASPedB Pixel
		
		  ACTIVATE DIALOG FasPedb CENTER

 	   Else

 	      MsgAlert("Nota fiscal já expedida!" + chr(13) + "Horas: " + SF2->F2_HREXPED + CHR(13) + "Conhecimento: " + Alltrim(SF2->F2_CONHECI))
  	  
  	  EndIf
 	
 	  RestArea( _aAreaSEP )
 	  
   Else
   
      MsgAlert("Nota Fiscal inexistente.")
   
   Endif	  
 	
Return

// ####################################
// Funcao de Embarque de Mercadorias ##
// ####################################
User Function Embarque()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private lEditar  := .F.
   Private lSenha   := .F.
   Private cNumNF	:= Space(09)
   Private cSerNF	:= Space(03)
   Private xCliente := Space(80)
   Private cPedido  := Space(25)
   Private _cHora   := Time()
   Private _cNumF   := Space(90)
   Private _cPostal := Space(50)
   Private cVolumes := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8

   Private oDlgPEDa

   DEFINE MSDIALOG oDlgPEDa TITLE "Alteração Envio Produto para F1" FROM C(178),C(181) TO C(497),C(664) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(146),C(030) PIXEL NOBORDER OF oDlgPEDa

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(231),C(001) PIXEL OF oDlgPEDa
   @ C(135),C(005) GET oMemo2 Var cMemo2 MEMO Size C(231),C(001) PIXEL OF oDlgPEDa
   
   @ C(044),C(005) Say "Nº N.Fiscal"     Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPEDa
   @ C(044),C(051) Say "Série"           Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgPEDa
   @ C(044),C(076) Say "Cliente"         Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgPEDa
   @ C(087),C(005) Say "Nº Pedido"       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPEDa
   @ C(087),C(051) Say "Hora"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPEDa
   @ C(087),C(095) Say "Nº Conhecimento" Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgPEDa
   @ C(110),C(005) Say "Código Postal"   Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgPEDa
   
   @ C(054),C(005) MsGet oGet1 Var cNumNf   Size C(040),C(009) COLOR CLR_BLACK Picture "@X" PIXEL OF oDlgPEDa F3 "SF2EMB"
   @ C(054),C(051) MsGet oGet2 Var cSerNF   Size C(019),C(009) COLOR CLR_BLACK Picture "@X" PIXEL OF oDlgPEDa
   @ C(054),C(076) MsGet oGet3 Var xCliente Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPEDa When lChumba

   @ C(097),C(005) MsGet oGet4 Var cPedido  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgPEDa When lChumba
   @ C(097),C(051) MsGet oGet5 Var _cHora   Size C(037),C(009) COLOR CLR_BLACK Picture "99:99" PIXEL OF oDlgPEDa When lEditar
   @ C(097),C(095) MsGet oGet6 Var _cNumF   Size C(105),C(009) COLOR CLR_BLACK Picture "!@"    PIXEL OF oDlgPEDa When lEditar
   @ C(120),C(005) MsGet oGet7 Var _cPostal Size C(231),C(009) COLOR CLR_BLACK Picture "!@"    PIXEL OF oDlgPEDa When lEditar
   @ C(097),C(205) MsGet oGet8 Var cVolumes Size C(030),C(009) COLOR CLR_BLACK Picture "99999" PIXEL OF oDlgPEDa When lChumba

   @ C(068),C(081) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgPEDa ACTION( BscDsNf() )      When !lEditar
   @ C(068),C(119) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgPEDa ACTION( oDlgPEDa:End() ) When !lEditar

   @ C(142),C(050) Button "Etiqueta"  Size C(037),C(012) PIXEL OF oDlgPEDa When lEditar ACTION( E_Etiqueta(cVolumes, cPedido, cNumNF, cSerNF) )
   @ C(142),C(089) Button "Alterar"   Size C(037),C(012) PIXEL OF oDlgPEDa When lSenha  ACTION( AbrCamposDig() )
   @ C(142),C(128) Button "Gravar"    Size C(037),C(012) PIXEL OF oDlgPEDa When lEditar ACTION( FGravaJ() )
   @ C(142),C(167) Button "Abandonar" Size C(037),C(012) PIXEL OF oDlgPEDa When lEditar ACTION( oDlgPEDa:End() )

   ACTIVATE MSDIALOG oDlgPEDa CENTERED 

Return(.T.)

// #############################################################################
// Função que abre os campos para alteração somente para usuários autorizados ##
// #############################################################################
Static Function AbrCamposDig()

   lEditar := .T.
   
Return(.T.)   

// #########################################################################
// Função que pesquisa dados da nota fiscal informada na tela de Embarque ##
// #########################################################################
Static Function BscDsNf()

	Private _aAreaSEP := SEPARA->( GetArea() )

    // ########################################
    // Verifica se nota fiscal foi informada ##
    // ######################################## 
    If Empty(Alltrim(cNumNF))
       MsgAlert("Nota Fiscal não informada para pesquisa.")
       Return(.T.)
    Endif
       
    // ################################################# 
    // Verifica se série da nota fiscal foi informada ##
    // #################################################
    If Empty(Alltrim(cSerNF))
       MsgAlert("Série da Nota Fiscal não informada para pesquisa.")
       Return(.T.)
    Endif

    // ###################################
    // Pesquisa a nota fiscal informada ##
    // ###################################
	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek( xFilial("SF2") + cNumNF + cSerNF )

       // #########################################################################
       // Habilita a digitação dos campos se nota fiscal ainda não foi embarcada ##
       // #########################################################################
       lEditar := IIF(Empty( AllTrim( SF2->F2_CONHECI ) ), .T., .F.)

       // #####################################################################
       // Habilita condição de alteração de campos para usuários aitorizados ##
       // #####################################################################
       If lEditar == .T.
          lSenha := .F.
       Else   
          lSenha := IIf(Alltrim(Upper(cUserName))$("ADMINISTRADOR#RHAGIN#RHAGIN.MACHADO#MARCOS.BARBOZA#EXPEDICAO"), .T., .F.)
       Endif   

       // #############################################
       // Carrega os dados para os campo de trabalho ##
       // #############################################
       _cHora   := SF2->F2_HREXPED
       _cNumF   := SF2->F2_CONHECI
       _cPostal := SF2->F2_POSTAL

       // #############################
       // Pesquisa o nome do cliente ##
       // #############################
   	   xCliente := POSICIONE("SA1",1, XFILIAL("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_NOME")
       oGet3:Refresh()
       
       // ###################################
	   // Pesquisa o nº do pedido de venda ##
	   // ###################################
	   DbSelectArea("SD2")
	   DbSetOrder(3)
	   DbSeek( xFilial("SD2") + cNumNF + cSerNF )
		
       DbSelectArea("SC5")
	   DbSetOrder(1)
	   DbSeek( xFilial("SC5") + SD2->D2_PEDIDO )

       cPedido  := SD2->D2_PEDIDO
       cVolumes := SC5->C5_VOLUME1
       
    Else
       
       MsgAlert("Nota Fiscal/Série informada não localizada.")
       
    Endif
    
Return(.T.)       

// ##############################################
// Jean Rehermann - Grava os dados de embarque ##
// ##############################################
Static Function FGravaJ()

	Local _cItens := ""

    // ###############################################################
	// Atualiza os campos na Tabela F2 - Cabeçalho de Notas Fiscais ##
	// ###############################################################
	RecLock("SF2",.F.)
    F2_HREXPED := _cHora
	F2_CONHECI := _cNumF
    F2_POSTAL  := _cPostal
	MsUnlock()

    // Se alteração foi realizada pelo notão Alterar, somente atualiza os dados nos campos e retorna
    If lSenha == .T.
       oDlgPEDa:End() 
       Return(.T.)
    Else
	
       // #####################
       // Atualiza os status ##
       // #####################
       dbSelectArea("SD2")
   	   dbSetOrder(3)
	   If dbSeek( xFilial("SD2") + cNumNF + cSerNF )
		  While !SD2->( Eof() ) .And. xFilial("SD2") == SD2->D2_FILIAL .And. SD2->D2_DOC == cNumNF .And. SD2->D2_SERIE == cSerNf
			
		     dbSelectArea("SC6")
			 dbSetOrder(1)
			 If dbSeek( xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV )
				RecLock("SC6",.F.)
				C6_STATUS := "12" // Expedido
				U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "12", "JPCACD01") // Gravo o log de atualização de status na tabela ZZ0
				_cItens += SC6->C6_ITEM + "|"
				MsUnLock()
			 EndIf

			 SD2->( dbSkip() )
	      Enddo

		  If !Empty( AllTrim( _cItens ) )
			 U_MailSts( SC5->C5_NUM, SubStr( _cItens, 1, Len( _cItens ) - 1 ), "E" ) // Envio de e-mail
		  EndIf

	   EndIf
	   
	Endif   

    oDlgPEDa:End() 
    	
Return

// ####################################################################
// Jean Rehermann - Atualiza o arquivo de trabalho da tela principal ##
// ####################################################################
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
	
	cQuery := " SELECT SC5.C5_NUM, SC5.C5_VEND1, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA1.A1_NREDUZ, SA1.A1_MUNE, SA1.A1_BAIRRO, SA1.A1_TEL, SC5.C5_TRANSP "+CHR(13)
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "+CHR(13)
	cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA "+CHR(13)
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO <>'B' "+CHR(13)
	cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' '  OR SC5.C5_JPCSEP = 'P') "+CHR(13)

    // ##########################################################################################################################################
	// Jean Rehermann - Inserida a condição de só aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens ##
	// ##########################################################################################################################################
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

	cQuery += " SELECT SC5.C5_NUM, SC5.C5_VEND1, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_TIPO, SA2.A2_NREDUZ, SA2.A2_MUN, SA2.A2_BAIRRO, SA2.A2_TEL, SC5.C5_TRANSP  "+CHR(13)
	cQuery += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA2")+" SA2 "+CHR(13)
	cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_CLIENTE = SA2.A2_COD AND SC5.C5_LOJACLI = SA2.A2_LOJA "+CHR(13)
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' AND SC5.C5_TIPO = 'B' "+CHR(13)
	cQuery += " AND SC5.C5_LIBEROK <> '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND (SC5.C5_JPCSEP = ' ' OR SC5.C5_JPCSEP = 'P')"+CHR(13)

    // ##########################################################################################################################################
	// Jean Rehermann - Inserida a condição de só aparecer o PV na tela se algum item tiver status = 08-Aguard. Sep. Estoque ou todos os itens ##
	// ##########################################################################################################################################
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
					SEPARA->A1_NREDUZ	:= IIF(T_C5->C5_VEND1 == "000119", "***** " + Alltrim(T_C5->A1_NREDUZ) + " *****", Alltrim(T_C5->A1_NREDUZ))
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

// #################################################
// Harald Hans Löschnekohl - Emissão de Etiquetas ##
// #################################################
Static Function E_Etiqueta(_Volumes, _Pedido, _cNumNF, _cSerNF)

   // #############################
   // Variaveis Locais da Funcao ##
   // #############################
   Local oGet1

   // ######################################################
   // Variaveis da Funcao de Controle e GertArea/RestArea ##
   // ######################################################
   Local _aArea   		:= {}
   Local _aAlias  		:= {}
   
   // ##############################
   // Variaveis Private da Função ##
   // ##############################
   Private aComboBx1 := {,"LPT1","LPT2","COM1","COM2","COM3","COM4","COM5","COM6"}
   Private cComboBx1 := "LPT1"
   Private nGet1	 := Alltrim(Str(_Volumes))

   // ###################
   // Diálogo Princial ##
   // ###################
   Private oDlg_E

   // ##########################################################################################
   // Se cliente for GKN, envia para a tela de informação de volumes e impressão de etiquetas ##
   // ##########################################################################################
   If Posicione("SC5", 1, xFilial("SC5") + _Pedido, "C5_CLIENTE") == "000859"
      U_AUTOM270(SC5->C5_NUM, SC5->C5_CLIENTE, SC5->C5_LOJACLI)
      Return(.T.)
   Endif

   // #############################################
   // Variaveis que definem a Acao do Formulario ##
   // #############################################
   DEFINE MSDIALOG oDlg_E TITLE "Automatech - Impressão de Etiqueta Expedição" FROM C(178),C(181) TO C(300),C(450) PIXEL

   // ######################################
   // Cria Componentes Padroes do Sistema ##
   // ######################################
   @ C(012),C(010) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg_E
   @ C(027),C(010) Say "Porta de Impressão:"      Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg_E

   @ C(010),C(060) MsGet oGet1 Var nGet1          Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg_E
   @ C(026),C(060) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg_E

   DEFINE SBUTTON FROM C(40),C(010) TYPE 6  ENABLE OF oDlg_E ACTION( ETQ_EXPEDICAO(nGet1,cCombobx1,_Pedido,_cNumNF, _cSerNF)  )
   DEFINE SBUTTON FROM C(40),C(035) TYPE 20 ENABLE OF oDlg_E ACTION( odlg_E:end() )

   ACTIVATE MSDIALOG oDlg_E CENTERED  

Return(.T.)

// #############################################
// Função que Imprime a Etiqueta de Expedição ##
// #############################################
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
      MsgAlert("Quantidade de Etiquetas a serem impressas não informada.")
      Return .T.
   Endif
       
   // #####################################
   // Pesquisa O tipo de pedido de venda ##
   // #####################################
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

   // ######################################
   // Pesquisa os dados a serem impressos ##
   // ######################################
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
       MSCBWRITE("^FO10,159^BY4,3.0^BCR,83,N,N,N,N^FD" + Alltrim(cNota) + _Serie + Alltrim(Strzero(nEt,2)) + "^FS" + chr(13))
       MSCBWRITE("^FO128,500^AGR,120,40^FD" + Strzero(nEt,3) + "/" + Strzero(nQtetq,3) + "^FS"  + chr(13))//Volume
       MSCBWRITE("^FO128,80^AGR,120,40^FD" + Alltrim(cNota) + "^FS"  + chr(13))
       MSCBWRITE("^FO256,500^ACR,18,10^FDVOLUMES:^FS"  + chr(13))
       MSCBWRITE("^FO238,690^ACR,18,10^FD^FS"  + chr(13))
       MSCBWRITE("^FO257,50^ACR,18,10^FDNOTA FISCAL:^FS"  + chr(13))
       MSCBWRITE("^FO295,48^ACR,18,10^FD^FS"  + chr(13))
       MSCBWRITE("^FO480,50^ABR,11,7^FDTRANSP.:^FS"  + chr(13))
       MSCBWRITE("^FO313,50^ACR,18,10^FDCLIENTE:^FS" + chr(13))
       MSCBWRITE("^FO382,50^ABR,11,7^FDCIDADE:^FS"   + chr(13))
       MSCBWRITE("^FO429,50^ABR,11,7^FD^FS"  + chr(13))

       If Empty(Alltrim(cFantasia))
          MSCBWRITE("^FO416,30^AUR,40,80^FD" + Alltrim(Substr(cTransporte,01,28)) + "^FS" + CHR(13))
       Else
          MSCBWRITE("^FO416,30^AUR,40,80^FD" + Alltrim(Substr(cFantasia,01,28))   + "^FS" + CHR(13))
       Endif
                    
       MSCBWRITE("^FO294,157^ACR,36,20^FD" + Alltrim(Substr(cCliente,01,28))    + "^FS" + chr(13))
       MSCBWRITE("^FO355,157^ACR,36,20^FD" + Alltrim(cCidade)                   + "^FS" + chr(13))       
       MSCBWRITE("^FO475,30^XGR:DB15,1,1^FS" + CHR(13))
       MSCBWRITE("^FO510,250^ARR,18,10^FDAutomatech Sistemas de Automacao Ltda^FS" + CHR(13))
       MSCBWRITE("^FO480,347^ARR,18,10^FDwww.automatech.com.br^FS" + CHR(13))
       MSCBWRITE("^PQ1,1,0,Y^FS" + CHR(13))
       MSCBWRITE("^XZ" + CHR(13))
       MSCBEND()
       MSCBCLOSEPRINTER()

   Next nEtq
   
Return .T.

// ##############################################################
// Harald Hans Löschenkohl - Realiza a Consulta das Expedições ##
// ##############################################################
Static Function MostraCan()

   Private dData01 := Ctod("  /  /    ")
   Private dData02 := Ctod("  /  /    ")
   Private nGet1   := Ctod("  /  /    ")                                       
   Private nGet2   := Ctod("  /  /    ")

   Private aBrowse := {}

   DEFINE MSDIALOG DLG_Exp TITLE "Automatech - Impressão de Etiqueta Expedição" FROM C(005),C(060) TO C(300),C(670) PIXEL

   @ C(007),C(010) Say "Data de Emissão de" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF DLG_Exp
   @ C(007),C(090) Say "Até"                Size C(050),C(020) COLOR CLR_BLACK PIXEL OF DLG_Exp

   @ C(005),C(050) MsGet oGet1  Var dData01 Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF Dlg_Exp
   @ C(005),C(100) MsGet oGet2  Var dData02 Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF Dlg_Exp

   @ 007,250 BUTTON "Pesquisar" Size 40,11 ACTION( BuscaExpedicao( dData01, dData02 ) )OF DLG_Exp PIXEL
   @ 007,300 BUTTON "Voltar"    Size 40,11 ACTION( DLG_Exp:end() )   OF DLG_Exp PIXEL

   oBrowse := TSBrowse():New(030,005,380,150,Dlg_Exp,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Pedido',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Clientes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Emissão',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('N.Fiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Série',,,{|| },{|| }) )   
   oBrowse:AddColumn( TCColumn():New('Vendedor Principal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Transportadora',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora',,,{|| },{|| }) )   
   oBrowse:SetArray(aBrowse)

   ACTIVATE DIALOG DLG_Exp CENTER

Return

// ###############################################################
// Harald Hans Löschenkohl - Resaliza a pesquisa das expedições ##
// ###############################################################
Static Function BuscaExpedicao( dData01, dData02 )

   Private aBrowse := {}
   
   If Empty(dData01)
      MsgAlert("Data inicial de Emissão não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de Emissão não informada.")
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
   oBrowse:AddColumn( TCColumn():New('Emissão',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('N.Fiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Série',,,{|| },{|| }) )   
   oBrowse:AddColumn( TCColumn():New('Vendedor Principal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Transportadora',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora',,,{|| },{|| }) )   
   oBrowse:SetArray(aBrowse)
 
   // #######################################
   // Pesquisa os dados para popular o gid ##
   // #######################################
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
   oBrowse:AddColumn( TCColumn():New('Emissão',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('N.Fiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Série',,,{|| },{|| }) )   
   oBrowse:AddColumn( TCColumn():New('Vendedor Principal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Transportadora',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora',,,{|| },{|| }) )   
   oBrowse:SetArray(aBrowse)

Return .T.

// #############################################################################
// Função que pesquisa as observações internas do pedido de venda selecionado ##
// #############################################################################
Static Function OBSINTERNA( _Pedido )

   Local cSql    := ""
   Local lChumba := .F.
   Local cGet1	 := _Pedido
   Local oGet1
   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgXX

   // #####################
   // Posiciona o Pedido ##
   // #####################		
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
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   cMemo1 := T_OBSERVA->OBSERVA

   DEFINE MSDIALOG oDlgXX TITLE "Observações Internas do Pedido de Venda" FROM C(178),C(181) TO C(487),C(683) PIXEL

   @ C(006),C(004) Say "Nº Pedido:"                             Size C(026),C(009) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(019),C(004) Say "Observações Interna do Pedido de Venda" Size C(102),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX

   @ C(004),C(034) MsGet oGet1 Var cGet1      When lChumba Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(029),C(003) GET oMemo1 Var cMemo1 MEMO              Size C(242),C(105) PIXEL OF oDlgXX

   @ C(137),C(208) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgXX ACTION( oDlgXX:End() )

   ACTIVATE MSDIALOG oDlgXX CENTERED 

Return(.T.)

// ##########################################################################################
// Função que abre a tela de consulta do pedido de venda solicitada pela tela da Separação ##
// ##########################################################################################
Static Function ABRE_PEDIDO( _Pedido )

   // #################################################################
   // Exemplo de chamada somente da visualização de uma tela         ##
   // Não apagar                                                     ##
   //   Private aRotina := {;                                        ##
   //                      { "Pesquisar"  , ""         , 0 , 1 },;   ##
   //                      { "Visualizar" , "AxVisual" , 0 , 2 },;   ##
   //                      { "Incluir"    , ""         , 0 , 3 },;   ##
   //                      { "Alterar"    , ""         , 0 , 4 },;   ##
   //                      { "Excluir"    , ""         , 0 , 5 } ;   ##
   //                      }                                         ##
   //                                                                ##
   //  Private cCadastro := "Consulta de Pedido de venda"            ##
   //                                                                ##
   //  dbSelectArea("SC5")                                           ##
   //  dbSetOrder(1)                                                 ##
   //  dbSeek( xFilial("SC5") + _Pedido )                            ##
   //                                                                ##
   //  AxVisual("SC5", SC5->( Recno() ), 2)                          ##
   // #################################################################

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
   Local cLacre		:= ""

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
   
   // #################################
   // Pesquisa os dados para display ##
   // #################################
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
      MsgAlert("Não existem dados a serem visualizados.")
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

   // ####################################
   // Pesquisa o nome da Transportadora ##
   // ####################################
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

   // ##########################################
   // Pesquisa os produtos do pedido de venda ##
   // ##########################################  
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.C6_ITEM   ,"
   cSql += "       A.C6_PRODUTO,"
   cSql += "       B.B1_PARNUM ,"
   cSql += "       A.C6_DESCRI ,"
   cSql += "       A.C6_UM     ,"
   cSql += "       A.C6_LACRE  ,"  //Adicionado Diego Franco - Solutio - 23/01/14 - Tarefa 8450
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
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.C6_PRODUTO = B.B1_COD"
   cSql += " ORDER BY A.C6_ITEM "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   WHILE !T_PRODUTOS->( EOF() )
   
	   If(T_PRODUTOS->C6_LACRE == 'S')
	   	cLacre	:= "Sim"
	   	Elseif(T_PRODUTOS->C6_LACRE == 'N')
	   	cLacre	:= "Não"
	   	Else
	   	cLacre	:= ""
	   EndIf
   
      aAdd(aConsulta, { T_PRODUTOS->C6_ITEM   ,;
                        T_PRODUTOS->C6_PRODUTO,;
                        T_PRODUTOS->B1_PARNUM ,;
                        T_PRODUTOS->C6_DESCRI ,;
                        T_PRODUTOS->C6_UM     ,;
                        cLacre				  ,; //Adicionado Diego Franco - Solutio - 23/01/14 - Tarefa 8450
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

   // #####################################
   // Abre janela para display dos dados ##
   // #####################################
   DEFINE MSDIALOG oDlgV TITLE "Consulta Pedido de Venda" FROM C(178),C(181) TO C(553),C(725) PIXEL

   @ C(006),C(008) Say "Cliente"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(060),C(007) Say "Vendedor"                    Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(074),C(214) Say "Tipo Frete"                  Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(075),C(007) Say "Transportadora"              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(088),C(007) Say "Cond. Pagtº"                 Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
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

   // ###################
   // Desenha o Browse ##
   // ###################
   oConsulta := TCBrowse():New( 145 , 005, 335, 070,,{'Item','Produto','Part Number','Descrição dos Produtos', 'Und', 'Lacre','Qtd','Unitário','Total', 'TES', 'Cod.Fiscal', 'Entrega', 'Status', 'N.Fiscal', 'Série', 'Data' },{20,50,50,50},oDlgV,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oConsulta:SetArray(aConsulta) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
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
                          aConsulta[oConsulta:nAt,15],;
                          aConsulta[oConsulta:nAt,16]} }

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return( NIL )

// ######################################################################################################################### 
// Jean Rehermann - Solutio IT - 25/07/2012 | Gravação de Log da separação                                                ##
// Parâmetro 1: cTipo  => S - Separação | M - Alteração Manual do C5_JPCSEP | A - Alteração automatica do campo C5_JPCSEP ##
// Parâmetro 2: cTpCod => S - Seriado | P - Não Seriado (apenas código de produto)                                        ##
// Parâmetro 3: cSepA  => Conteudo atual do C5_JPCSEP (P,T ou Branco)                                                     ##
// Parâmetro 4: cSepN  => Conteudo a ser gravado no C5_JPCSEP (P,T ou Branco)                                             ##
// #########################################################################################################################
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

// ###########################################################################################################################
// Função que possibilita o usuário a paramertizar o som a ser utilizado como alerta em caso de produto lido em duplicidade ##
// ###########################################################################################################################
Static Function SetaAlarme(_AbreMensagem, _CodProduto, _Mensagem)

   Local nLeft   := 1
   Local nTopBtn := 202
   Local showBar := .F.
   Local isMute  := .F.
   Local nVolume := 100
 
   Private oDlgSom

   SetStyle(5)

   If lAlerta == .F.
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlgSom TITLE "TMediaPlayer" FROM 0,0 TO 424,510 PIXEL
 
   oMedia := TMediaPlayer():New(1,nLeft,255,200,oDlgSom,"c:\Alarme_Sonoro.mp3",nVolume,showBar)

   If _AbreMensagem == "S"
      MsgAlert(_Mensagem)
      cCodLote := Space(20)
      oCodLote:Refresh()
      cCodDuplo  := _CodProduto
      oCodDuplo:Refresh()
      oDlgSom:End()
   Endif    

//   TButton():New( nTopBtn, nLeft    , "Abrir"     , oDlgSom , {|| oMedia:openFile( FWInputBox("Escolha o arquivo", "c:/garbage/") ) }    , 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "Play"      , oDlgSom , {|| oMedia:play() }                                                        , 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "Pause"     , oDlgSom , {|| oMedia:pause() }                                                       , 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "Stop"      , oDlgSom , {|| oMedia:stop() }                                                        , 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "SetVolume" , oDlgSom , {|| oMedia:setVolume( Val( FWInputBox("Escolha a altura do volume [0-100]" , cValToChar(oMedia:nVolume)) ) ) }, 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "GetVolume" , oDlgSom , {|| MsgAlert( oMedia:nVolume ) }                                           , 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "ShowBar"   , oDlgSom , {|| showBar:=!showBar, oMedia:setShowBar( showBar ) }                      , 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "nPlayCount", oDlgSom , {|| oMedia:nPlayCount := ( Val( FWInputBox("Escolha o numero de repetições", cValToChar(oMedia:nPlayCount)) ) ) }, 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
//   TButton():New( nTopBtn, nLeft+=28, "SetMute"   , oDlgSom , {|| isMute:=!isMute, oMedia:setMute( isMute ) }                            , 28,010,,,.F.,.T.,.F.,,.F.,,,.F. )
 
   ACTIVATE MSDIALOG oDlgSom CENTERED
 
RETURN(.T.)

// #################################################
// Funcao que abre/fecha o botao de alerta sonoro ##
// #################################################
Static Function AlertaOnOff()

   Local cMemo1	   := ""
   Local oMemo1

   Private oDlgAlarme

   DEFINE MSDIALOG oDlgAlarme TITLE "Configuração do Alarme de Separação" FROM C(178),C(181) TO C(344),C(478) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"      Size C(109),C(026) PIXEL NOBORDER OF oDlgAlarme

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO       Size C(141),C(001) PIXEL OF oDlgAlarme

   @ C(037),C(005) Say "Arquivo em C:\Alarme_Sonoro.mp3" Size C(086),C(008) COLOR CLR_RED PIXEL OF oDlgaLARME

   @ C(049),C(024) CheckBox oAlerta Var lAlerta Prompt "Aviso sonoro (Alarme) da separação " Size C(096),C(008) PIXEL OF oDlgAlarme

   @ C(064),C(034) Button "Testar Alarme" Size C(037),C(012) PIXEL OF oDlgAlarme ACTION( IIF(lAlerta == .T., SetaAlarme("N", "", ""), MsgAlert("Alerta esta desligado.")) )
   @ C(064),C(073) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlgAlarme ACTION( EncerraAlarme() )

   ACTIVATE MSDIALOG oDlgAlarme CENTERED 

Return(.T.)

// #############################################################
// Funcao que fecha a tela de parametrizacao do alarme sonoro ##
// #############################################################
Static Function EncerraAlarme()

   oDlgAlarme:End()
   
Return(.T.)


// Função que troca a cor da linha conforme prioridade
Static Function TrocaCorLinha(nLinha,nCor)

   Local cSql := ""
   Local nRet := 16777215

   If Len(aBrowse) == 0
      Return nRet
   Endif

//   Do Case
//      Case Alltrim(aBrowse[nLinha,01]) == "ABERTURA"
           nRet := 65535
//      Case Alltrim(aBrowse[nLinha,01]) == "APROVADA"
//           nRet := 65535
//      Case Alltrim(aBrowse[nLinha,01]) == "REPORVADA"
//           nRet := 8421504
//      Case Alltrim(aBrowse[nLinha,01]) == "DESENVOLVIMENTO"
//           nRet := 16776960
//      Case Alltrim(aBrowse[nLinha,01]) == "AGUARDANDO VAL."
//           nRet := 16711935
//      Case Alltrim(aBrowse[nLinha,01]) == "INCONFORME"
//           nRet := 255
//      Case Alltrim(aBrowse[nLinha,01]) == "VALIDAÇÃO OK"
//           nRet := 65280
//      Case Alltrim(aBrowse[nLinha,01]) == "LIBERADA PRO"
//           nRet := 16711680
//      Case Alltrim(aBrowse[nLinha,01]) == "TAREFA ENC."
//           nRet := 32896
//      Case Alltrim(aBrowse[nLinha,01]) == "AGUARDANDO EST."
//           nRet := 0
//   EndCase

Return nRet

// ##################################################
// Função que Ordena a coluna selecionada no grid  ##
// ##################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// ###############################################################################################################
// Função que abre janela com os números de séries disponíveis para utilização para a Unidade de Espirito Santo ##
// ###############################################################################################################
Static Function NSESanto()

   MsgRun("Aguarde! Pesquisando nºs de séries do produto selecionado ...", "Nºs de Séries",{|| xNSESanto() })

Return(.T.)

// ###############################################################################################################
// Função que abre janela com os números de séries disponíveis para utilização para a Unidade de Espirito Santo ##
// ###############################################################################################################
Static Function xNSESanto()

   Local lChumba := .F.

   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1

   Private kProduto	  := Alltrim(aLstBox[oLbx:nAt,2]) + Space(30 - Len(Alltrim(aLstBox[oLbx:nAt,2])))
   Private kDescricao := aLstBox[oLbx:nAt,3]
   Private kVendido   := aLstBox[oLbx:nAt,4]
   Private kSeparado  := aLstBox[oLbx:nAt,5]

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgES

   Private aMarcados := {}
   Private oMarcados

   // #####################################################################
   // Verifica se o produto selecionado tem seu controle por nº de série ##
   // #####################################################################
   
   If Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_LOCALIZ" ) == "S"
   Else        
      cCodLote := kproduto
      U_VLDLOTE(cCodLote)
      Return(.T.)
   Endif   

   // ###########################################
   // Pesquisa os nºs de séries para o produto ##
   // ###########################################
   If Select("T_SELECAO") > 0
      T_SELECAO->( dbCloseArea() )
   EndIf
                                                           
   cSql := ""
   cSql := "SELECT SBF.BF_NUMSERI,"
   cSql += "      (SELECT TOP(1) DC_NUMSERI" 
   cSql += "	     FROM " + RetSqlName("SDC")
   cSql += "   	    WHERE DC_FILIAL  = SBF.BF_FILIAL "
   cSql += "		  AND DC_PRODUTO = SBF.BF_PRODUTO"
   cSql += "		  AND DC_NUMSERI = SBF.BF_NUMSERI"
   cSql += "		  AND D_E_L_E_T_ = '') AS DC_SERIE"
   cSql += "  FROM " + RetSqlName("SBF") + " SBF "
   cSql += " WHERE SBF.BF_FILIAL   = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND SBF.BF_PRODUTO  = '" + Alltrim(kProduto) + "'"
   cSql += "   AND SBF.BF_QUANT    > 0 "
   cSql += "   AND SBF.BF_NUMSERI <> ''"
   cSql += "   AND SBF.D_E_L_E_T_  = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SELECAO", .T., .T. )

   T_SELECAO->( DbGoTop() )
   WHILE !T_SELECAO->( EOF() )
      If Empty(Alltrim(T_SELECAO->DC_SERIE))
         aAdd( aMarcados, { .F., T_SELECAO->BF_NUMSERI } )
      Endif   
      T_SELECAO->( DbSkip() )
   ENDDO   

   DEFINE MSDIALOG oDlgES TITLE "Separação - Seleção Nº de Séries" FROM C(178),C(181) TO C(567),C(621) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgES

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(213),C(001) PIXEL OF oDlgES

   @ C(036),C(005) Say "Produto selecionado"       Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgES
   @ C(036),C(183) Say "Qtd Total"                 Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgES
   @ C(058),C(005) Say "Nºs de Séries disponíveis" Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlgES
   @ C(182),C(060) Say "Marcados"                  Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgES
   
   @ C(045),C(005) MsGet oGet1 Var kProduto   Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgES When lChumba
   @ C(045),C(043) MsGet oGet2 Var kDescricao Size C(135),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgES When lChumba
   @ C(045),C(181) MsGet oGet3 Var kVendido   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgES When lChumba
   @ C(181),C(087) MsGet oGet4 Var kSeparado  Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgES When lChumba

   @ C(179),C(005) Button "MT"       Size C(017),C(012) PIXEL OF oDlgES ACTION( XXMRCTT(1) )
   @ C(179),C(023) Button "DT"       Size C(017),C(012) PIXEL OF oDlgES ACTION( XXMRCTT(0) )
   @ C(179),C(140) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgES ACTION( XXMRCONF() )
   @ C(179),C(179) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgES ACTION( oDlgES:End() )

   // #################
   // Desenha aLista ##
   // #################
   If Len(aMarcados) == 0
      aAdd( aMarcados, { .F., "" } )
   Endif   

   @ 085,005 LISTBOX oMarcados FIELDS HEADER "M"            ,; // 01  
                                             "Nº de Séries"  ; // 02
                               PIXEL SIZE 270,140 OF oDlgES ON dblClick(aMarcados[oMarcados:nAt,1] := !aMarcados[oMarcados:nAt,1],oMarcados:Refresh())     
   oMarcados:SetArray( aMarcados )

   oMarcados:bLine := {||{Iif(aMarcados[oMarcados:nAt,01],oOk,oNo),;
                              aMarcados[oMarcados:nAt,02]         }}

   oMarcados:bLDblClick   := {|| AtualizaSel( ) }

   ACTIVATE MSDIALOG oDlgES CENTERED 

Return(.T.)

// ############################################
// Função que marca/desmarca os nº de séries ##
// ############################################
Static Function XXMRCTT(kTipoMarca)

   Local nContar := 0
   
   kSeparado := 0

   For nContar = 1 to Len(aMarcados)
       If kTipoMarca == 1
          aMarcados[nContar,01] := .T.       
          kSeparado += 1
       Else
          aMarcados[nContar,01] := .F.       
       Endif
   Next nContar
          
   oGet4:Refresh()

Return(.T.)

// ###############################################
// Função que atualiza o totalizador da seleção ##
// ###############################################
Static Function AtualizaSel()

   Local nContar := 0
   
   kSeparado := 0

   If aMarcados[oMarcados:nAt,01] == .F.
      aMarcados[oMarcados:nAt,01] := .T.
   Else
      aMarcados[oMarcados:nAt,01] := .F.      
   Endif   

   For nContar = 1 to Len(aMarcados)
       If aMarcados[nContar,01] == .T.       
          kSeparado += 1
       Endif
   Next nContar
          
   oGet4:Refresh()
   
Return(.T.)

// ###############################################################
// Função que consiste nºs de séries marcados antes de retornar ##
// ###############################################################
Static Function XXMRCONF()

   Local nContar := 0
   
   If kVendido <> kSeparado
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "A quantdiade de nºs de séries selecionado não confere com a quantidade do pedido de vedna. Verifique!")
      Return(.T.)
   Endif

   // #######################################
   // Atualiza o Grid com o total separado ##
   // #######################################
   aLstBox[oLbx:nAt,05] := kSeparado
   aLstBox[oLbx:nAt,06] := 0

   For nContar = 1 to Len(aMarcados)
       If aMarcados[nContar,01] == .F.
          Loop
       Endif      

       Reclock("CONF",.t.)
  	   CONF->B1_CODBAR := aMarcados[nContar,02]
	   CONF->B1_COD    := kProduto
	   CONF->(MsUnlock())

   Next nContar

   DbGoTop()

   // #####################################################################################################################
   // Atualiza o List da tela                                                                                            ##
   // oGetDb2 := MsGetDB():New(20,10,260,110,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf) ##
   // #####################################################################################################################
   oGetDb2 := MsGetDB():New(20,40,235,150,1,"U_CFTDOK","U_CFTDOK","",.F., aAlter, ,.F., ,"CONF",Nil,Nil,Nil,oDlgConf)

   oDlgES:End()

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
   
   // ##############################################################
   // Verifica se pode liberar o botão de OK da tela de separação ##
   // ##############################################################
   lLibera := .T.

   For nContar = 1 to Len(aLstBox)
       If aLstBox[nContar,04] <> aLstBox[nContar,05]
          lLibera := .F.
          Exit
       Endif
   Next nContar           

Return(.T.)

// #######################################################################################
// Função que verifica se deve ser mostrado a tela de diferença de produção de produtos ##
// #######################################################################################
Static Function MtrProducao(kFilial, kPedido)

   Local lChumba   := .F.
   Local cSql      := ""
   Local cMemo1	   := ""
   Local oMemo1
   
   Private yPedido := Space(250)
   Private oGet1

   Private aProducao := {}
   Private oProducao

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgPrd

   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_CLIENTE," + CHR(13)
   cSql += "       SC5.C5_LOJACLI," + CHR(13)
   cSql += "       SA1.A1_NOME   ," + CHR(13)
   cSql += "       SC6.C6_NUM    ," + CHR(13)
   cSql += "       SC6.C6_ITEM   ," + CHR(13)
   cSql += "       SC6.C6_PRODUTO," + CHR(13)
   cSql += "       SC6.C6_NUMOP  ," + CHR(13)
   cSql += "       RTRIM(LTRIM(SB1.B1_DESC)) + ' ' + RTRIM(LTRIM(SB1.B1_DAUX)) AS DESCRICAO," + CHR(13)
   cSql += "       SB1.B1_UM     ," + CHR(13)
   cSql += "       SC5.C5_QEXAT  ," + CHR(13)
   cSql += "       SC6.C6_QTDVEN ," + CHR(13)                  
   cSql += "       SC2.C2_QUANT  ," + CHR(13)
   cSql += "       SC2.C2_QUJE   ," + CHR(13)
   cSql += "       SC6.C6_NUMOP + SC6.C6_ITEMOP AS ORDEMPRD" + CHR(13)
   cSql += "  FROM " + RetSqlName("SC6") + " SC6 , " + CHR(13)
   cSql += "       " + RetSqlName("SB1") + " SB1 , " + CHR(13)
   cSql += "       " + RetSqlName("SC5") + " SC5 , " + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " SA1 , " + CHR(13)
   cSql += "       " + RetSqlName("SC2") + " SC2   " + CHR(13)
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(kFilial) + "'" + CHR(13)
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(kPedido) + "'" + CHR(13)
   cSql += "   AND SC6.D_E_L_E_T_ = ''             " + CHR(13)
   cSql += "   AND SC6.C6_STATUS  = '08'           " + CHR(13)
   cSql += "   AND SC6.C6_NUMOP  <> ''             " + CHR(13)                                          
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO " + CHR(13)
   cSql += "   AND SB1.D_E_L_E_T_ = ''             " + CHR(13)
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL  " + CHR(13)
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM     " + CHR(13)
   cSql += "   AND SC5.D_E_L_E_T_ = ''             " + CHR(13)
   cSql += "   AND SA1.A1_COD     = SC5.C5_CLIENTE " + CHR(13)
   cSql += "   AND SA1.A1_LOJA    = SC5.C5_LOJACLI " + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''             " + CHR(13)
   cSql += "   AND SC2.C2_FILIAL  = SC6.C6_FILIAL  " + CHR(13)
   cSql += "   AND SC2.C2_NUM + SC2.C2_ITEM = SC6.C6_NUMOP + SC6.C6_ITEMOP" + CHR(13)
   cSql += "   AND SC2.D_E_L_E_T_ = ''             " + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   T_PRODUCAO->( DbGoTop() )

   WHILE !T_PRODUCAO->( EOF() )
   
      If T_PRODUCAO->C6_QTDVEN == T_PRODUCAO->C2_QUJE
         kLegenda := "1"
      Else
         kLegenda := "9"
      Endif   

      If T_PRODUCAO->C6_QTDVEN < T_PRODUCAO->C2_QUJE
         kDiferenca := T_PRODUCAO->C2_QUJE - T_PRODUCAO->C6_QTDVEN
         kAtender   := T_PRODUCAO->C2_QUJE
      Else
         kDiferenca := T_PRODUCAO->C6_QTDVEN - T_PRODUCAO->C2_QUJE
         kAtender   := T_PRODUCAO->C6_QTDVEN
      Endif   

      aAdd( aProducao, { kLegenda                       ,; // 01
                         .F.                            ,; // 02
                         Alltrim(T_PRODUCAO->C6_ITEM)   ,; // 03
                         Alltrim(T_PRODUCAO->C6_PRODUTO),; // 04
                         Alltrim(T_PRODUCAO->DESCRICAO) ,; // 05
                         T_PRODUCAO->B1_UM              ,; // 06
                         Alltrim(T_PRODUCAO->C5_QEXAT)  ,; // 07
                         T_PRODUCAO->ORDEMPRD           ,; // 08
                         T_PRODUCAO->C6_QTDVEN          ,; // 09
                         kDiferenca                     ,; // 10
                         kAtender                       }) // 11

      T_PRODUCAO->( DbSkip() )
      
   ENDDO   

   If Len(aProducao) == 0
      kVoltaPrd := .F.
      Return(.T.)
   Endif
   
   // ################################
   // Verifica se existe diferenças ##
   // ################################
   lDeveVoltar := .T.
   For nContar = 1 to Len(aProducao)
       If aProducao[nContar,10] <> 0
          lDeveVoltar := .F.
          Exit
       Endif
   Next nContar
   
   If lDeveVoltar == .T.
      kVoltaPrd := .F.
      Return(.T.)
   Endif             
   
   T_PRODUCAO->( DbGoTop() )
   yPedido := "Pedido nº " + Alltrim(T_PRODUCAO->C6_NUM) + " Cliente: " + T_PRODUCAO->C5_CLIENTE + "." + T_PRODUCAO->C5_LOJACLI + " - " + ;
                             Alltrim(T_PRODUCAO->A1_NOME)

   // ###################################
   // Desenha a tela para visualização ##
   // ###################################                                                       
   DEFINE MSDIALOG oDlgPrd TITLE "Aletração Quantidade Pedido de Venda" FROM C(178),C(181) TO C(453),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(022) PIXEL NOBORDER OF oDlgPrd

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlgPrd

   @ C(034),C(005) Say "Pedido de Venda" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgPrd

   @ C(043),C(005) MsGet oGet1 Var yPedido     Size C(383),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPrd When lChumba

   @ C(122),C(005) Button "Marca Todos"        Size C(044),C(012) PIXEL OF oDlgPrd ACTION( mmrrdd(1) )
   @ C(122),C(050) Button "Desmarca Todos"     Size C(044),C(012) PIXEL OF oDlgPrd ACTION( mmrrdd(2) )
   @ C(122),C(096) Button "Alterar Quantidade" Size C(058),C(012) PIXEL OF oDlgPrd ACTION( AltQtdPVOP(kFilial, kPedido) )
   @ C(122),C(295) Button "Iniciar Separação"  Size C(055),C(012) PIXEL OF oDlgPrd ACTION( kVoltaPrd := .F., oDlgPrd:End() )
   @ C(122),C(351) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlgPrd ACTION( kVoltaPrd := .T., oDlgPrd:End() )

   // ##################
   // Desenha a Lista ##
   // ##################
   @ 073,005 LISTBOX oProducao FIELDS HEADER "LG"                     ,; // 01
                                             "M"                      ,; // 02
                                             "Item"                   ,; // 03
                                             "Produto"                ,; // 04
                                             "Descrição dos Produtos" ,; // 05
                                             "Un"                     ,; // 06
                                             "Q.Ext."                 ,; // 07
                                             "O.Prod."                ,; // 09
                                             "Qtd PV"                 ,; // 08
                                             "Diferença"              ,; // 10
                                             "Atender"                 ; // 11
                                             PIXEL SIZE 490,080 OF oDlgPrd ON dblClick(aProducao[oProducao:nAt,2] := !aProducao[oProducao:nAt,2],oProducao:Refresh())     

   oProducao:SetArray( aProducao )

   oProducao:bLine := {||{ If(Alltrim(aProducao[oProducao:nAt,01]) == "7", oBranco  ,;
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "1", oVerde   ,;
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "4", oPink    ,;                         
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "3", oAmarelo ,;                         
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "5", oAzul    ,;                         
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "6", oLaranja ,;                         
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "2", oPreto   ,;                         
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "9", oVermelho,;
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "X", oCancel  ,;
                           If(Alltrim(aProducao[oProducao:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                           Iif(aProducao[oProducao:nAt,02],oOk,oNo),;
                               aProducao[oProducao:nAt,03]         ,;
                               aProducao[oProducao:nAt,04]         ,;
                               aProducao[oProducao:nAt,05]         ,;
                               aProducao[oProducao:nAt,06]         ,;
                               aProducao[oProducao:nAt,07]         ,;
                               aProducao[oProducao:nAt,08]         ,;
                               aProducao[oProducao:nAt,09]         ,;
                               aProducao[oProducao:nAt,10]         ,;
                               aProducao[oProducao:nAt,11]         }}

   ACTIVATE MSDIALOG oDlgPrd CENTERED 

Return(.T.)

// ########################################################
// Função que marca/desmarca os registros com diferenças ##
// ########################################################
Static Function mmrrdd(yTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aProducao)
       If aProducao[nContar,01] == "1"
          Loop
       Else
          aProducao[nContar,02] := IIF(yTipo == 1, .T., .F.)
       Endif
   Next nContar

Return(.T.)

// ########################################################
// Função que marca/desmarca os registros com diferenças ##
// ########################################################
Static Function AltQtdPVOP(kkFilial, kkPedido)

   Local nContar     := 0
   Local lTemMarcado := .F.   
   
   For nContar = 1 to Len(aProducao)
       If aProducao[nContar,02] == .T.
          lTemMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lTemMarcado == .F.
      MsgAlert("Nenhum registro foi marcado para realizar a alteração de quantidade. Verifique!")
      Return(.T.)
   Endif

   For nContar = 1 to Len(aProducao)
       
       If aProducao[nContar,02] == .T.
        
          If aProducao[nContar,01] == "1"
             Loop
          Endif
          
          // #########################################
          // Altera a quantidade no pedido de venda ##
          // ######################################### 
          dbSelectArea("SC6")
          DBSetOrder(1)
          If DbSeek ( kkFilial + kkPedido + aProducao[nContar,03] + aProducao[nContar,04])
             RecLock("SC6",.F.)
             If aProducao[nContar,11] > 0
     	        SC6->C6_QTDVEN :=  aProducao[nContar,11]
                SC6->C6_VALOR  := aProducao[nContar,11] * SC6->C6_PRCVEN
     	     Else                                        
     	        If SC6->C6_QTDVEN > (aProducao[nContar,11] * -1)
       	           SC6->C6_QTDVEN := (aProducao[nContar,11] * -1)
                   SC6->C6_VALOR  := (aProducao[nContar,11] * -1) * SC6->C6_PRCVEN
       	        Else
       	           SC6->C6_QTDVEN := (aProducao[nContar,11] * -1)
                   SC6->C6_VALOR  := (aProducao[nContar,11] * -1) * SC6->C6_PRCVEN
       	        Endif   
     	     Endif
             MsUnLock()
          Endif
          
          // ####################################
          // Altera a quantidade na tabela SC9 ##
          // ####################################
          dbSelectArea("SC9")
          DBSetOrder(1)
          If DbSeek ( kkFilial + kkPedido + aProducao[nContar,03])
             RecLock("SC9",.F.)
             If aProducao[nContar,11] > 0
     	        SC9->C9_QTDLIB :=  aProducao[nContar,11]
     	     Else
   	            SC9->C9_QTDLIB :=  (aProducao[nContar,11] * -1)
     	     Endif
             MsUnLock()
          Endif
          
       Endif
             
   Next nContar
   
   kVoltaPrd := .F.
   
   oDlgPrd:End()   
   
Return(.T.)