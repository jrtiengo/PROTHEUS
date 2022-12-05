#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM177.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/06/2013                                                          *
// Objetivo..: Programa que permite tratar opções de Embalagem e Embarque. Isso é  *
//             para quando não existem pedidos a serem visualizados pela tela  de  *
//             separação.                                                          *
//**********************************************************************************

User Function AUTOM177()

   Private oDlg

   U_AUTOM628("AUTOM177")

   DEFINE MSDIALOG oDlg TITLE "Embarque/Embalagem" FROM C(178),C(181) TO C(280),C(364) PIXEL

   @ C(005),C(005) Button "Embalagem" Size C(079),C(012) PIXEL OF oDlg ACTION (ABRE_EMBA("      "))
   @ C(018),C(005) Button "Embarque"  Size C(079),C(012) PIXEL OF oDlg ACTION (EMBARQUEQ("      "))
   @ C(032),C(005) Button "Voltar"    Size C(079),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Sub-função que abre a janela dos dados de Embalagem
Static Function ABRE_EMBA()

   Private cPedidoB := Space(06)
   Private oGet1

   Private oDlgB

   DEFINE MSDIALOG oDlgB TITLE "Embalagem" FROM C(178),C(181) TO C(288),C(453) PIXEL

   @ C(005),C(005) Say "Informe o Nº do Pedido de Venda a ser pesquisado" Size C(123),C(008) COLOR CLR_BLACK PIXEL OF oDlgB
   @ C(017),C(030) Say "Nº PV"                                            Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgB

   @ C(016),C(049) MsGet oGet1 Var cPedidoB Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgB

   @ C(034),C(022) Button "OK"     Size C(037),C(012) PIXEL OF oDlgB ACTION( BConfirma() )
   @ C(034),C(061) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgB ACTION( oDlgB:End() )

   ACTIVATE MSDIALOG oDlgB CENTERED 

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

   DbSelectArea("SC5")
   DbSetOrder(1)
   DbSeek( xFilial("SC5") + cPedidoB)

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

		kGravaLogSep("M", "", _cJPCSEP, cJpcSep)

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

// ------------------------------------------- *
// Função que trata os dados da opção Embarque *
// ------------------------------------------- *
Static Function EmbarqueQ()

	Private cNumNF := Space(9)
	Private oNumNf
	Private cSerNF := Space(3)
	Private oSerNf
	
	DEFINE MSDIALOG FASPedA TITLE "Expedição de Mercadoria" From 00,000 TO 100,220 OF oMainWnd Pixel Style DS_MODALFRAME

    @ 030,065 BUTTON "Consulta"  Size 40,11 ACTION (MostraQ()) OF FasPedA PIXEL
	@ 10,005 Say "Nota Fiscal:"   OF FASPedA Pixel

	@ 10,040 MsGet oNumNf Var cNumNF PICTURE "@X" SIZE 040,010 OF FASPedA Pixel F3 "SF2EMB" VALID !Empty( cNumNF )
	@ 10,085 MsGet oSerNf Var cSerNF PICTURE "@X" SIZE 020,010 OF FASPedA Pixel

	DEFINE SBUTTON FROM 30,005 TYPE 01 ACTION (FConfEmbq())	  OF FasPedA ENABLE Pixel
	DEFINE SBUTTON FROM 30,035 TYPE 02 ACTION (FasPedA:End()) OF FasPedA ENABLE Pixel

	ACTIVATE DIALOG FasPedA CENTER

Return

// Inserir os dados do embarque
Static Function FConfEmbq()

	Private _cHora    := Time()
	Private _cNumF    := Space(90)
//  Private _aAreaSEP := SEPARA->( GetArea() )
	
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
		  @ 049,070 MsGet _cNumF Picture "!@"	 SIZE 070,010 OF FASPedB Pixel
		
		  @ 005,145  BUTTON "Etiqueta" Size 50,12 ACTION Q_Etiqueta(SC5->C5_VOLUME1, SD2->D2_PEDIDO, cNumNF, cSerNF) OF FASPedB Pixel
		
		  @ 033,145  BUTTON "Gravar"   Size 50,12 ACTION FGravaQ()      OF FASPedB Pixel
		  @ 048,145  BUTTON "Abandona" Size 50,12 ACTION (FasPedb:End()) OF FASPedB Pixel
		
		  ACTIVATE DIALOG FasPedb CENTER

 	   Else

 	      MsgAlert("Nota fiscal já expedida!" + chr(13) + "Horas: " + SF2->F2_HREXPED + CHR(13) + "Conhecimento: " + Alltrim(SF2->F2_CONHECI))
  	  
  	  EndIf
 	
// 	  RestArea( _aAreaSEP )
 	  
   Else
   
      MsgAlert("Nota Fiscal inexistente.")
   
   Endif	  
 	
Return

// Jean Rehermann - Grava os dados de embarque
Static Function FGravaQ()

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
					U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "12", "JPCACD01", 0 ) // Gravo o log de atualização de status na tabela ZZ0
					_cItens += SC6->C6_ITEM + "|"
				MsUnLock()
			EndIf

			SD2->( dbSkip() )
		End

		If !Empty( AllTrim( _cItens ) )
			U_MailSts( SC5->C5_NUM, SubStr( _cItens, 1, Len( _cItens ) - 1 ), "E" ) // Envio de e-mail
		EndIf

	EndIf
	
	FasPedb:End()
	
Return

// Harald Hans Löschnekohl - Emissão de Etiquetas
Static Function Q_Etiqueta(_Volumes, _Pedido, _cNumNF, _cSerNF)

   // Variaveis Locais da Funcao
   Local oGet1

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}
   
   // Variaveis Private da Função

   Private aComboBx1 := {,"LPT1","LPT2","COM1","COM2","COM3","COM4","COM5","COM6"}
   Private cComboBx1 := "LPT1"
   Private nGet1	 := Alltrim(Str(_Volumes))

   // Diálogo Princial
   Private oDlg_E

   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG oDlg_E TITLE "Automatech - Impressão de Etiqueta Expedição" FROM C(178),C(181) TO C(300),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(012),C(010) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg_E
   @ C(027),C(010) Say "Porta de Impressão:"      Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg_E

   @ C(010),C(060) MsGet oGet1 Var nGet1          Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg_E
   @ C(026),C(060) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg_E

   DEFINE SBUTTON FROM C(40),C(010) TYPE 6  ENABLE OF oDlg_E ACTION( QQQ_EXPEDICAO(nGet1,cCombobx1,_Pedido,_cNumNF, _cSerNF)  )
   DEFINE SBUTTON FROM C(40),C(035) TYPE 20 ENABLE OF oDlg_E ACTION( odlg_E:end() )

   ACTIVATE MSDIALOG oDlg_E CENTERED  

Return(.T.)

// Função que Imprime a Etiqueta de Expedição
Static Function QQQ_EXPEDICAO(nGet1, cPorta, _Pedido, _cNumNF, _cSerNF)

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
       
   // Pesquisa O tipo de pedido de venda
   If Select("T_TIPOPV") > 0
      T_TIPOPV->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C5_TIPO"
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_NUM       = '" + Alltrim(_Pedido) + "'"
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

//Harald Hans Löschenkohl - Realiza a Consulta das Expedições
Static Function MostraQ()

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

   @ 007,250 BUTTON "Pesquisar" Size 40,11 ACTION( BuscaQQQ( dData01, dData02 ) ) OF DLG_Exp PIXEL
   @ 007,300 BUTTON "Voltar"    Size 40,11 ACTION( DLG_Exp:end() )                OF DLG_Exp PIXEL

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

//Harald Hans Löschenkohl - Resaliza a pesquisa das expedições
Static Function BuscaQQQ( dData01, dData02 )

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
   cSql += "   AND A.F2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)"
   cSql += "   AND A.F2_FILIAL    = '" + Alltrim(cFilant) + "'"
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

// ######################################################################################################################### 
// Jean Rehermann - Solutio IT - 25/07/2012 | Gravação de Log da separação                                                ##
// Parâmetro 1: cTipo  => S - Separação | M - Alteração Manual do C5_JPCSEP | A - Alteração automatica do campo C5_JPCSEP ##
// Parâmetro 2: cTpCod => S - Seriado | P - Não Seriado (apenas código de produto)                                        ##
// Parâmetro 3: cSepA  => Conteudo atual do C5_JPCSEP (P,T ou Branco)                                                     ##
// Parâmetro 4: cSepN  => Conteudo a ser gravado no C5_JPCSEP (P,T ou Branco)                                             ##
// #########################################################################################################################
Static Function kGravaLogSep(cTipo, cTpCod, cSepA, cSepN)
	
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
