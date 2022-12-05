#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM561.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 17/04/2017                                                           *
// Objetivo..: Cadastro de Campanhas de Venda - AtechInfo                           *
//***********************************************************************************

User Function AUTOM561()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aBrowse := {}

   // #############################
   // Cores das legendas do grid ##
   // #############################
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

   Private oDlg

   // ##################################################
   // Função que carrega o grid com dados do cadastro ##
   // ##################################################
   CarregaZSH(0)

   DEFINE MSDIALOG oDlg TITLE "Cadastro Campanhia de Vendas" FROM C(178),C(181) TO C(557),C(818) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg
   @ C(161),C(005) Jpeg FILE "br_verde.bmp"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(161),C(061) Jpeg FILE "br_vermelho.bmp" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(311),C(001) PIXEL OF oDlg
   @ C(169),C(002) GET oMemo2 Var cMemo2 MEMO Size C(311),C(001) PIXEL OF oDlg

   @ C(161),C(017) Say "Campanha Ativa"   Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(161),C(074) Say "Campanha Inativa" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(173),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManCampanha("I", "") )
   @ C(173),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( ManCampanha("A", aBrowse[oBrowse:nAt,02]) )
   @ C(173),C(081) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManCampanha("E", aBrowse[oBrowse:nAt,02]) )
   @ C(173),C(276) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 050 , 005, 395, 153,,{'Lg', 'Código', 'Descrição das Campanhas', 'Válida De', 'Válida Até'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###############################################################
// Função que carrega o grid com dados do cadastro de campanhas ##
// ###############################################################
Static Function CarregaZSH(kTipo)

   Local cSql := ""
   
   aBrowse := {}
   
   If Select("T_CAMPANHA") > 0
      T_CAMPANHA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSH_CODI,"
   cSql += "       ZSH_NOME,"
   cSql += "       ZSH_DINI,"
   cSql += "       ZSH_DFIM,"
   cSql += "       ZSH_ATIV "
   cSql += "  FROM " + RetSqlName("ZSH")
   cSql += " WHERE ZSH_DELE = ''"
   cSql += " ORDER BY ZSH_CODI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CAMPANHA", .T., .T. )
   
   T_CAMPANHA->( DbGoTop() )
   
   WHILE !T_CAMPANHA->( EOF() )
      aAdd( aBrowse, { IIF(T_CAMPANHA->ZSH_ATIV == "N", "8", "2"),;
                       T_CAMPANHA->ZSH_CODI,;
                       T_CAMPANHA->ZSH_NOME,;
                       substr(T_CAMPANHA->ZSH_DINI,07,02) + "/" +substr(T_CAMPANHA->ZSH_DINI,05,02) + "/" +substr(T_CAMPANHA->ZSH_DINI,01,04) ,;
                       substr(T_CAMPANHA->ZSH_DFIM,07,02) + "/" +substr(T_CAMPANHA->ZSH_DFIM,05,02) + "/" +substr(T_CAMPANHA->ZSH_DFIM,01,04)})
      T_CAMPANHA->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "7", "", "", "", "" })
   Endif   
   
   If kTipo == 0
      Return(.T.)
   Endif
   
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               }}

Return(.T.)      

// ################################################################
// Função que abre janela de manutenção do cadastro de campanhas ##
// ################################################################
Static Function ManCampanha(kOperacao, kCodigo)

   Local cSql    := ""
   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cCodigo   := Space(06)
   Private cNome	 := Space(60)
   Private cDInicial := Ctod("  /  /    ")
   Private cDFinal   := Ctod("  /  /    ")
   Private lAtivo	 := .F.

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oCheckBox1

   Private oDlgC

   If KOperacao == "I"
      cCodigo   := Space(06)
      cNome	    := Space(60)
      cDInicial := Ctod("  /  /    ")
      cDFinal   := Ctod("  /  /    ")
      lAtivo	:= .F.
   Else
   
      If Select("T_CAMPANHA") > 0
         T_CAMPANHA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZSH_FILIAL,"
      cSql += "       ZSH_CODI  ,"
	  cSql += "       ZSH_NOME  ,"
	  cSql += "       ZSH_DINI  ,"
	  cSql += "       ZSH_DFIM  ,"
	  cSql += "       ZSH_ATIV,  "
	  cSql += "       ZSH_DELE   "
      cSql += "  FROM " + RetSqlName("ZSH")
      cSql += " WHERE ZSH_FILIAL = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND ZSH_CODI   = '" + Alltrim(kCodigo) + "'"
      cSql += "   AND ZSH_DELE   = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CAMPANHA", .T., .T. )

      If T_CAMPANHA->( EOF() )
         MsgAlert("Campanha não localizada.")
         Return(.T.)
      Else
         cCodigo   := T_CAMPANHA->ZSH_CODI
         cNome	   := T_CAMPANHA->ZSH_NOME
         cDInicial := Ctod(Substr(T_CAMPANHA->ZSH_DINI,07,02) + "/" + Substr(T_CAMPANHA->ZSH_DINI,05,02) + "/" + Substr(T_CAMPANHA->ZSH_DINI,01,04))
         cDFinal   := Ctod(Substr(T_CAMPANHA->ZSH_DFIM,07,02) + "/" + Substr(T_CAMPANHA->ZSH_DFIM,05,02) + "/" + Substr(T_CAMPANHA->ZSH_DFIM,01,04))
         lAtivo	   := IIF( T_CAMPANHA->ZSH_ATIV == "S", .T., .F.)
      Endif
      
   Endif

   // ##############################
   // Desneha a tela para display ##
   // ##############################
   DEFINE MSDIALOG oDlgC TITLE "Cadastro Campanha de Vendas" FROM C(178),C(181) TO C(434),C(515) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(161),C(001) PIXEL OF oDlgC
   @ C(108),C(002) GET oMemo2 Var cMemo2 MEMO Size C(160),C(001) PIXEL OF oDlgC

   @ C(037),C(005) Say "Código"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(059),C(005) Say "Nome da Campanha" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(082),C(005) Say "Válida De"        Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(083),C(043) Say "Válida Até"       Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(046),C(005) MsGet    oGet1      Var cCodigo   Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC When lChumba
   @ C(069),C(005) MsGet    oGet2      Var cNome     Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC When IIF(kOperacao == "E", .F., .T.)
   @ C(091),C(005) MsGet    oGet3      Var cDInicial Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC When IIF(kOperacao == "E", .F., .T.)
   @ C(091),C(043) MsGet    oGet4      Var cDFinal   Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC When IIF(kOperacao == "E", .F., .T.)
   @ C(092),C(087) CheckBox oCheckBox1 Var lAtivo    Prompt "Campanha de Vendas Ativa" Size C(077),C(008) PIXEL OF oDlgC When IIF(kOperacao == "E", .F., .T.)

   @ C(112),C(071) Button IIF(kOperacao == "E", "Excluir", "Salvar") Size C(045),C(012) PIXEL OF oDlgC ACTION( SalvaCabCpn(kOperacao, cCodigo) )
   @ C(112),C(118) Button "Voltar"                                   Size C(045),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// ###############################################################
// Função que salva os dadso do cabeçalho da Campanha de vendas ##
// ###############################################################
Static Function SalvaCabCpn(kOperacao, kkCodigo)

   Local cSql := ""

   // ###########################################
   // Consistência dos Dados antes da gravação ##
   // ###########################################
   If Empty(Alltrim(cNome))
      MsgAlert("Nome da campanha não informada.")
      Return(.T.)
   Endif
      
   If cDInicial == Ctod("  /  /    ")
      MsgAlert("Data de vigência inicial da campnha não informada.")
      Return(.T.)
   Endif
   
   If cDFinal == Ctod("  /  /    ")
      MsgAlert("Data de vigência final da campnha não informada.")
      Return(.T.)
   Endif
   
   // ##############################################################################################
   // Verifica se já existe alguma campanha ativa. Somente permite uma campanha ativa de cada vez ##
   // ##############################################################################################
   If kOperacao == "E"
   Else

      If Select("T_QUANTAS") > 0
         T_QUANTAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT COUNT(*) AS QTD_ATIVAS"
      cSql += "  FROM " + RetSqlName("ZSH")
      cSql += " WHERE ZSH_DELE = ''"
      cSql += "   AND ZSH_CODI <> '" + Alltrim(kkCodigo) + "'"
      cSql += "   AND ZSH_ATIV = 'S'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QUANTAS", .T., .T. )

      If T_QUANTAS->( EOF() )
      Else
         If lAtivo == .T.
            If T_QUANTAS->QTD_ATIVAS <> 0
               MsgAlert("Atenção!" + chr(13) + chr(10) + Chr(13) + chr(10) + "Somente permitida uma campanha ativa por vez." + chr(13) + chr(10) + "Indicação de Campanha ativa será desmarcada.")
               lAtivo := .F.
            Endif
         Endif
      Endif   
   Endif            

   // ####################
   // Inclui a campanha ##
   // ####################
   If kOperacao == "I"

      // ##############################################################
      // Pesquisa o próximo código para inclusão de campnha de venda ##
      // ##############################################################
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT MAX(ZSH_CODI) AS PROXIMO FROM " + RetSqlName("ZSH")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      IF T_PROXIMO->( EOF() )
         xProximo := "000001"
      Else
         xProximo := Strzero(INT(VAL(T_PROXIMO->PROXIMO)) + 1,6)
      Endif   
   
      dbSelectArea("ZSH")
      RecLock("ZSH",.T.)
      ZSH_FILIAL := cFilAnt
      ZSH_CODI   := xProximo
      ZSH_NOME   := cNome
      ZSH_DINI   := cDInicial
      ZSH_DFIM   := cDFinal
      ZSH_ATIV   := IIF(lAtivo == .T., "S", "N")
      ZSH_DELE   := ""
      MsUnLock()

   Endif
      
   // ####################
   // Altera a campanha ##
   // ####################
   If kOperacao == "A"
   
      dbSelectArea("ZSH")
      dbSetOrder(1)
      If DbSeek( cFilAnt + kkCodigo)
         RecLock("ZSH",.F.)
         ZSH_NOME   := cNome
         ZSH_DINI   := cDInicial
         ZSH_DFIM   := cDFinal
         ZSH_ATIV   := IIF(lAtivo == .T., "S", "N")
         ZSH_DELE   := ""
         MsUnLock()
      Endif   

      xProximo := kkCodigo
      
   Endif

   // ####################
   // Exclui a campanha ##
   // ####################
   If kOperacao == "E"
   
      If MsgYesNo("Desenha realmente excluir este registro?")

         // ##################################
         // Elimina o cabeçalho da campanha ##
         // ##################################
         dbSelectArea("ZSH")
         dbSetOrder(1)
         If DbSeek( cFilAnt + kkCodigo)
            RecLock("ZSH",.F.)
            ZSH_DELE   := "X"
            MsUnLock()
         Endif   

         // ##################################
         // Elimina os produtos da campanha ##
         // ##################################
         cSql := ""
         cSql := "UPDATE " + RetSqlName("ZSI")
         cSql += "  SET"
         cSql += "  ZSI_DELE = 'X'"
         cSql += "WHERE ZSI_CODI = '" + Alltrim(kkCodigo) + "'"
            
         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
            Return(.T.)
         Endif

         oDlgC:End() 
         
         // ##################################################
         // Função que carrega o grid com dados do cadastro ##
         // ##################################################
         CarregaZSH(1)

         Return(.T.)

      Else

         // ##################################################
         // Função que carrega o grid com dados do cadastro ##
         // ##################################################
         CarregaZSH(1)

         Return(.T.)
      
      Endif
      
   Endif

   oDlgC:End() 
           
   // ############################################################################
   // Abre a tela de informação dos produtos que pertencem a campanha de vendas ##
   // ############################################################################
   AbreProCpn("I", xProximo, cNome, cDInicial, cDFinal, lAtivo)
   
Return(.T.)   

// #######################################################################################
// Função que abre janela para manutenção dos produtos que compoem a campanha de vendas ##
// #######################################################################################
Static Function AbreProCpn(kOperacao, kCampanha)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local oMemo1
   
   Private cCodigo   := Space(06)
   Private cNome	 := Space(60)
   Private cDInicial := Ctod("  /  /    ")
   Private cDFinal   := Ctod("  /  /    ")
   Private lAtivo    := .F.

   Private oCheckBox1
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private aProdutos := {}

   Private oDlgCP

   // ###################################
   // Pesquisa a campanha para display ##
   // ###################################
   If Select("T_CAMPANHA") > 0
      T_CAMPANHA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSH_CODI,"
   cSql += "       ZSH_NOME,"
   cSql += "       ZSH_DINI,"
   cSql += "       ZSH_DFIM,"
   cSql += "       ZSH_ATIV "
   cSql += "  FROM " + RetSqlName("ZSH")
   cSql += " WHERE ZSH_DELE = ''"
   cSql += "   AND ZSH_CODI = '" + Alltrim(kCampanha) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CAMPANHA", .T., .T. )

   If T_CAMPANHA->( EOF() )
      MsgAlert("Campanha não localizada.")
      Return(.T.)
   Else
      cCodigo   := T_CAMPANHA->ZSH_CODI
      cNome	    := T_CAMPANHA->ZSH_NOME
      cDInicial := Substr(T_CAMPANHA->ZSH_DINI,07,02) + "/" + Substr(T_CAMPANHA->ZSH_DINI,05,02) + "/" + Substr(T_CAMPANHA->ZSH_DINI,01,04)
      cDFinal   := Substr(T_CAMPANHA->ZSH_DFIM,07,02) + "/" + Substr(T_CAMPANHA->ZSH_DFIM,05,02) + "/" + Substr(T_CAMPANHA->ZSH_DFIM,01,04)
      lAtivo    := IIF(T_CAMPANHA->ZSH_ATIV == "S", .T., .F.)
   Endif

   // #####################################################
   // Envia para a função que carrega o grid de produtos ##
   // #####################################################
   CargaProdutos(kCampanha, 0)

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlgCP TITLE "Cadastro Campanha de Vendas" FROM C(178),C(181) TO C(562),C(887) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgCP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(347),C(001) PIXEL OF oDlgCP

   @ C(037),C(005) Say "Código"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP
   @ C(037),C(036) Say "Nome da Campanha"               Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP
   @ C(037),C(198) Say "Válida De"                      Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP
   @ C(037),C(234) Say "Válida Até"                     Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP
   @ C(059),C(005) Say "Produtos pontuados na campanha" Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP
   
   @ C(046),C(005) MsGet    oGet1      Var cCodigo   Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCP When lChumba
   @ C(046),C(036) MsGet    oGet2      Var cNome     Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCP When lChumba
   @ C(046),C(198) MsGet    oGet3      Var cDInicial Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCP When lChumba
   @ C(046),C(234) MsGet    oGet4      Var cDFinal   Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCP When lChumba
   @ C(047),C(273) CheckBox oCheckBox1 Var lAtivo    Prompt "Campanha de Vendas Ativa" Size C(077),C(008) PIXEL OF oDlgCP When lChumba

   @ C(175),C(005) Button "Inclui Produto" Size C(045),C(012) PIXEL OF oDlgCP ACTION( SelPrdCmp(kCampanha) )
// @ C(175),C(005) Button "Inclui Produto" Size C(045),C(012) PIXEL OF oDlgCP ACTION( AbreProduto("I", kCampanha, "", "", 0) )
   @ C(175),C(053) Button "Altera Produto" Size C(045),C(012) PIXEL OF oDlgCP ACTION( AbreProduto("A", kCampanha, aProdutos[oProdutos:nAt,01], aProdutos[oProdutos:nAt,02], aProdutos[oProdutos:nAt,03]) )
   @ C(175),C(102) Button "Exclui Produto" Size C(045),C(012) PIXEL OF oDlgCP ACTION( AbreProduto("E", kCampanha, aProdutos[oProdutos:nAt,01], aProdutos[oProdutos:nAt,02], aProdutos[oProdutos:nAt,03]) )
   @ C(175),C(311) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgCP ACTION( FechaJanPro() )

   oProdutos := TCBrowse():New( 090 , 005, 440, 130,,{'Código', 'Descrição dos Produtos' + Space(30), 'Pontuação'},{20,50,50,50},oDlgCP,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oProdutos:SetArray(aProdutos) 
    
   oProdutos:bLine := {||{ aProdutos[oProdutos:nAt,01],;
                           aProdutos[oProdutos:nAt,02],;
                           aProdutos[oProdutos:nAt,03]}}

   ACTIVATE MSDIALOG oDlgCP CENTERED 

Return(.T.)

// ##################################################################
// Função que fecha a janela de informação de produtos da campanha ## 
// ##################################################################
Static Function FechaJanPro()

   oDlgCP:End()

   // ##################################################
   // Função que carrega o grid com dados do cadastro ##
   // ##################################################
   CarregaZSH(1)

Return(.T.)

// #######################################
// Função que carrega o array aProdutos ## 
// #######################################
Static Function CargaProdutos(kCampanha, kTipo)

   Local cSql := ""

   aProdutos  := {}

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSI.ZSI_FILIAL,"
   cSql += "       ZSI.ZSI_CODI  ,"
   cSql += "	   ZSI.ZSI_PROD  ,"
   cSql += "   	   SB1.B1_DESC   ,"
   cSql += "       SB1.B1_DAUX   ,"
   cSql += "       ZSI.ZSI_PONT  ,"
   cSql += "	   ZSI.ZSI_DELE   "
   cSql += "  FROM " + RetSqlName("ZSI") + " ZSI, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE ZSI.ZSI_DELE = ''"
   cSql += "   AND SB1.B1_COD   = ZSI.ZSI_PROD"
   cSql += "   AND ZSI.ZSI_CODI = '" + Alltrim(kCampanha) + "'"
   cSql += " ORDER BY ZSI_PONT, SB1.B1_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      aAdd( aProdutos, { T_PRODUTOS->ZSI_PROD                                             ,;
                         Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),;
                         T_PRODUTOS->ZSI_PONT})

      T_PRODUTOS->( DbSkip() )                         

   Enddo
   
   If Len(aProdutos) == 0
      aAdd( aProdutos, { "", "", "" })
   Endif
   
   If kTipo == 0
      Return(.T.)
   Endif
      
   oProdutos:SetArray(aProdutos) 
    
   oProdutos:bLine := {||{ aProdutos[oProdutos:nAt,01],;
                           aProdutos[oProdutos:nAt,02],;
                           aProdutos[oProdutos:nAt,03]}}

Return(.T.)      

// ################################################################
// Função que abre janela para informação do produto da campanha ##
// ################################################################
Static Function AbreProduto(kOperacao, kCampanha, kCodigo, kNome, kPontos)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private xCodigo := Space(30)
   Private xNome   := Space(60)
   Private xPontos := 0

   Private oGet1
   Private oGet2
   Private oGet3

   If kOperacao == "I"
      xCodigo := Space(30)
      xNome   := Space(60)
      xPontos := 0
   Else
      xCodigo := kCodigo
      xNome   := kNome
      xPontos := kPontos
   Endif   

   Private oDlgPRO

   DEFINE MSDIALOG oDlgPRO TITLE "Cadastro Campanha de Vendas" FROM C(178),C(181) TO C(426),C(516) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgPRO

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(161),C(001) PIXEL OF oDlgPRO             
   @ C(103),C(002) GET oMemo2 Var cMemo2 MEMO Size C(161),C(001) PIXEL OF oDlgPRO
   
   @ C(037),C(005) Say "Código Produto"       Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgPRO
   @ C(059),C(005) Say "Descrição do Produto" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgPRO
   @ C(081),C(005) Say "Pontos"               Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgPRO
   
   @ C(046),C(005) MsGet oGet1 Var xCodigo Size C(054),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgPRO When IIF(kOperacao == "I", .T., .F.) F3("SB1") VALID( CaptaPro(xCodigo) )
   @ C(068),C(005) MsGet oGet2 Var xNome   Size C(159),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgPRO When lChumba
   @ C(089),C(005) MsGet oGet3 Var xPontos Size C(032),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgPRO When IIF(kOperacao == "E", .F., .T.)

   @ C(107),C(072) Button "Salvar" Size C(045),C(012) PIXEL OF oDlgPRO ACTION( SalvaProduto(kOperacao, kCampanha, xCodigo, xNome, xPontos) )
   @ C(107),C(118) Button "Voltar" Size C(045),C(012) PIXEL OF oDlgPRO ACTION( oDlgPRO:End() )

   ACTIVATE MSDIALOG oDlgPRO CENTERED 

Return(.T.)

// #############################################################
// Função que pesquisa o nome do produto digitado/selecionado ##
// #############################################################
Static Function CaptaPro(kCodigo)

   Local nContar   := 0
   Local lJaExiste := .F.
   
   If Empty(Alltrim(kCodigo))
      xNome := Space(60)
      oGet2:Refresh()
      Return(.T.)
   Endif

   If Empty(Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kCodigo, "B1_DESC" )))
      MsgAlert("Produto inexistenet.")
      xCodigo := Space(30)
      xNome   := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      Return(.T.)
   Endif

   // ##############################################################################################
   // Verifica se o produto informado já está contido no array aProdutos. Se estiver, não permite ##
   // ##############################################################################################
   lJaExiste := .F.

   For nContar = 1 to Len(aProdutos)
       If Alltrim(aProdutos[nContar,01]) == Alltrim(xCodigo)
          lJaExiste := .T.
          Exit
       Endif
   Next nContar
 
   If lJaExiste == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Produto informado já está continudo na relação." + chr(13) + chr(10) + "Utilize a opção de alteração.")
      xCodigo := Space(30)
      oGet1:Refresh()      
      Return(.T.)
   Endif
  
   xNome := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kCodigo, "B1_DESC" )) + " " + ;
            Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kCodigo, "B1_DAUX" ))
   oGet2:Refresh()
   
Return(.T.)

// #########################################################################
// Função que salva o produto incluído/alterado ou excluído da tabela ZSI ##
// #########################################################################
Static Function SalvaProduto(kOperacao, kCampanha, xCodigo, xNome, xPontos)

   // ###############################
   // Consiste o código do produto ##
   // ###############################
   If Empty(Alltrim(xCodigo))
      MsgAlert("Produto não informado.")
      Return(.T.)
   Endif
      
   // #############################
   // Consiste o nome do produto ##
   // #############################
   If Empty(Alltrim(xNome))
      MsgAlert("Produto não informado.")
      Return(.T.)
   Endif

   // ##################################
   // Consiste a pontuação do produto ##
   // ##################################
   If xPontos == 0
      MsgAlert("Pontos não informados.")
      Return(.T.)
   Endif

   // #############################
   // Inclui registro do produto ##
   // #############################
   If kOperacao == "I"

      dbSelectArea("ZSI")
      RecLock("ZSI",.T.)
      ZSI_FILIAL := cFilAnt
      ZSI_CODI   := kCampanha
      ZSI_PROD   := xCodigo
      ZSI_PONT   := xPontos
      ZSI_DELE   := ""
      MsUnLock()
      
   Endif
      
   // ###############################
   // Altera o registro do produto ##
   // ###############################
   If kOperacao == "A"

      cSql := ""
      cSql := "UPDATE " + RetSqlName("ZSI")
      cSql += "  SET"
      cSql += "  ZSI_PONT = " + Alltrim(Str(xPontos,5))
      cSql += "WHERE ZSI_CODI = '" + Alltrim(kCampanha) + "'"
      cSql += "  AND ZSI_PROD = '" + Alltrim(xCodigo)   + "'"
      cSql += "  AND ZSI_DELE = ''"
            
      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif

   Endif
         
   // ###############################
   // Exclui o registro do produto ##
   // ###############################
   If kOperacao == "E"
  
      If MsgYesNo("Desenha realmente excluir este registro?")

         cSql := ""
         cSql := "UPDATE " + RetSqlName("ZSI")
         cSql += "  SET"
         cSql += "  ZSI_DELE = 'X'"
         cSql += "WHERE ZSI_CODI = '" + Alltrim(kCampanha) + "'"
         cSql += "  AND ZSI_PROD = '" + Alltrim(xCodigo)   + "'"
            
         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
            Return(.T.)
         Endif

      Endif
      
   Endif   

   // ######################################################
   // Fecha a janela de manutenção do produto da campanha ##
   // ######################################################
   oDlgPRO:End()

   // #####################################################
   // Envia para a função que carrega o grid de produtos ##
   // #####################################################
   CargaProdutos(kCampanha, 1)

Return(.T.)

// #######################################################################################
// Função que abre a tela de seleção e marcação de produtos que farão parte da campanha ##
// #######################################################################################
Static Function SelPrdCmp(kCampanha)

   Local cMemo1	 := ""
   Local oMemo1
   
   Private cString := Space(60)
   Private cPontos := 0

   Private oGet1
   Private oGet2

   Private oDlgINC

   Private aSelecao := {}
   Private oSelecao

   Private oOk := LoadBitmap( GetResources(), "LBOK" )
   Private oNo := LoadBitmap( GetResources(), "LBNO" )

   DEFINE MSDIALOG oDlgINC TITLE "Campanha de Vendas - Seleção de Produtos" FROM C(178),C(181) TO C(593),C(750) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgINC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(277),C(001) PIXEL OF oDlgINC

   @ C(036),C(005) Say "String a ser pesquisada"                                  Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgINC
   @ C(036),C(208) Say "Pontuação"                                                Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgINC
   @ C(057),C(005) Say "Selecione os produtos que serão considerados na campanha" Size C(147),C(008) COLOR CLR_BLACK PIXEL OF oDlgINC
   
   @ C(045),C(005) MsGet  oGet1 Var cString Size C(197),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgINC
   @ C(045),C(208) MsGet  oGet2 Var cPontos Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgINC
   @ C(042),C(241) Button "Pesquisar"     Size C(039),C(012)                                      PIXEL OF oDlgINC ACTION( PsqString(cString) )

   @ C(191),C(005) Button "Marca Todos"    Size C(050),C(012) PIXEL OF oDlgINC ACTION( MrcSel(1) )
   @ C(191),C(056) Button "Desmarca Todos" Size C(050),C(012) PIXEL OF oDlgINC ACTION( MrcSel(2) )
   @ C(191),C(132) Button "Saldo"          Size C(037),C(012) PIXEL OF oDlgINC ACTION( kSaldoProd(aSelecao[oSelecao:nAt,02]) )
   @ C(191),C(203) Button "Confirmar"      Size C(037),C(012) PIXEL OF oDlgINC ACTION( ConfirmaMrc(kCampanha) )
   @ C(191),C(243) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgINC ACTION( oDlgINC:End() )

   @ 083,005 LISTBOX oSelecao FIELDS HEADER "M", "Código", "Descrição dos Produtos" PIXEL SIZE 355,155 OF oDlgINC ON dblClick(aSelecao[oSelecao:nAt,1] := !aSelecao[oSelecao:nAt,1],oSelecao:Refresh())     

   aAdd( aSelecao, { .f., "", "" } )

   oSelecao:SetArray( aSelecao )

   oSelecao:bLine := {||{Iif(aSelecao[oSelecao:nAt,01],oOk,oNo),;
                             aSelecao[oSelecao:nAt,02]             ,;
                             aSelecao[oSelecao:nAt,03]             }}

   ACTIVATE MSDIALOG oDlgINC CENTERED 

Return(.T.)

// ############################################################
// Função que pesquisa os produtos pela informação da string ##
// ############################################################
Static Function PsqString(kString)

   If Empty(Alltrim(kString))
      Return(.T.)
   Endif

   aSelecao := {}
   
   oSelecao:SetArray( aSelecao )

   oSelecao:bLine := {||{Iif(aSelecao[oSelecao:nAt,01],oOk,oNo),;
                             aSelecao[oSelecao:nAt,02]         ,;
                             aSelecao[oSelecao:nAt,03]         }}

   If Select("T_PESQUISA") > 0
      T_PESQUISA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SB1.B1_COD,"
   cSql += "       LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS DESCRICAO"
   cSql += "  FROM " + RetSqlName("SB1") + " SB1 "
   cSql += " WHERE LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) LIKE '%" + Alltrim(kString) + "%'"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += " ORDER BY LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX))"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )
   
   T_PESQUISA->( DbGoTop() )
   
   WHILE !T_PESQUISA->( EOF() )
      aAdd( aSelecao, { .F.                   ,;
                        T_PESQUISA->B1_COD    ,;
                        T_PESQUISA->DESCRICAO })
      T_PESQUISA->( DbSkip() )
   ENDDO
   
   If Len(aSelecao) == 0
      aAdd( aSelecao, { .F., "", "" })
   Endif
      
   oSelecao:SetArray( aSelecao )

   oSelecao:bLine := {||{Iif(aSelecao[oSelecao:nAt,01],oOk,oNo),;
                             aSelecao[oSelecao:nAt,02]         ,;
                             aSelecao[oSelecao:nAt,03]         }}
   
Return(.T.)

// ######################################################
// Função que marca e desmarca os produtos pesquisados ##
// ######################################################
Static Function MrcSel( kTipo )

   Local nContar := 0
   
   For nContar = 1 to len(aSelecao)
       aSelecao[nContar,01] := IIF( kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)

// ################################################################
// Função que grava na tabela ZSI os produtos que foram marcados ##
// ################################################################
Static Function ConfirmaMrc(kCampanha)

   Local nContar   := 0
   Local kMarcados := .F.

   // #################################################################
   // Verifica se houve pelo menos um produto marcadoo para gravação ##
   // #################################################################
   lMarcados := .F.

   For nContar = 1 to Len(aSelecao)
       If aSelecao[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcados == .F.
      MsgAlert("Nenhum produto marcado. Verifique!")
      Return(.T.)
   Endif

   If cPontos == 0
      MsgAlert("Pontuação para os produtos não informada. Verifique!")
      Return(.T.)
   Endif
   
   For nContar = 1 to Len(aSelecao)

       If aSelecao[nContar,01] == .F.
          Loop
       ENdif
                
       dbSelectArea("ZSI")
       RecLock("ZSI",.T.)
       ZSI_FILIAL := cFilAnt
       ZSI_CODI   := kCampanha
       ZSI_PROD   := aSelecao[nContar,02]
       ZSI_PONT   := cPontos
       ZSI_DELE   := ""
       MsUnLock()
  
   Next nContar

   // ######################################################
   // Fecha a janela de manutenção do produto da campanha ##
   // ######################################################
   oDlgINC:End()

   // #####################################################
   // Envia para a função que carrega o grid de produtos ##
   // #####################################################
   CargaProdutos(kCampanha, 1)

Return(.T.)

// #####################################################
// Função que pesquisa o saldo do produto selecionado ##
// #####################################################
Static Function kSaldoProd(_Produto)

   If Empty(Alltrim(_Produto))
      MsgAlert("Produto a ser pesquisado inexistente.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // ####################################################
   // Posiciona no produto a ser pesquisado o seu saldo ##
   // ####################################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return .T.
