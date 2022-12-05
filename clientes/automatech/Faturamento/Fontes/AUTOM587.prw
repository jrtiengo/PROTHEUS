#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM587.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 26/06/2017                                                          ##
// Objetivo..: PAINEL COMERCIAL                                                    ##
// Parâmetros: Sem Parâmnetros                                                     ##
// ##################################################################################

User Function AUTOM587()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aFiliais	   := U_AUTOM539(2, cEmpAnt)
   Private aVendedor2  := {}
   Private dInicial    := Ctod("01/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
   Private dFinal      := Date()
   Private cCliente	   := Space(100)
   Private cPVenda 	   := Space(006)
   Private cOCompra	   := Space(006)
   Private cCotacao	   := 0
   Private lTodasLojas := .F.
   Private lVend1      := .T.
   Private lvend2      := .F.

   Private cComboBx1
   Private cComboBx2
   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3   
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet6
   Private oGet7
   Private oGet8

   Private aBrowsePC := {}
   Private aDetalhePC  := {}

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

   Private oDlgXX

   U_AUTOM628("AUTOM587")

   // ################################
   // Carrega o combo de Vendedores ##
   // ################################
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.A3_COD   ,"
   cSql += "       A.A3_NOME  ,"
   cSql += "       A.A3_CODUSR,"
   cSql += "       A.A3_TSTAT  "
   cSql += "  FROM " + RetSqlName("SA3") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.A3_CODUSR <> ''"
   cSql += " ORDER BY A.A3_NOME"     
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   aVendedor := {}
   aAdd( aVendedor, "000000 - Todos os Vendedores" ) 

   T_VENDEDOR->( DbGoTop() )
   WHILE !T_VENDEDOR->( EOF() )
      aAdd( aVendedor, Alltrim(T_VENDEDOR->A3_COD) + " - " + Alltrim(T_VENDEDOR->A3_NOME) ) 
      T_VENDEDOR->( DbSkip() )
   ENDDO

   // ###################################################
   // Pesquisa a cotação da segunda moeda para display ##
   // ###################################################
   cCotacao := Posicione("SM2", 1, DATE(), "M2_MOEDA2")

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlgXX TITLE "PAINE COMERCIAL" FROM C(183),C(002) TO C(620),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgXX
   @ C(007),C(264) Jpeg FILE "dolar.png"       Size C(040),C(016) PIXEL NOBORDER OF oDlgXX
   @ C(004),C(345) Jpeg FILE "carrinho.png"    Size C(030),C(023) PIXEL NOBORDER OF oDlgXX
   @ C(004),C(430) Jpeg FILE "incclie.bmp"     Size C(030),C(023) PIXEL NOBORDER OF oDlgXX

   @ C(010),C(306) MsGet oGet7 Var cCotacao    Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX When lChumba

   @ C(032),C(000) GET oMemo1 Var cMemo1 MEMO Size C(498),C(001) PIXEL OF oDlgXX
   @ C(057),C(000) GET oMemo2 Var cMemo2 MEMO Size C(498),C(001) PIXEL OF oDlgXX

   @ C(035),C(002) Say "Filiais"                                 Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(035),C(057) Say "Dta Inicial"                             Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(035),C(094) Say "Dta Final"                               Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(035),C(200) Say "Cliente"                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(035),C(321) Say "Vendedor"                                Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(035),C(406) Say "P.Venda"                                 Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(035),C(438) Say "O.Compra"                                Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(061),C(002) Say "Pedidos de Venda"                        Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(130),C(002) Say "Produtos do Pedido de Venda selecionado" Size C(103),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX

   @ C(044),C(002) ComboBox cComboBx1   Items aFiliais  Size C(052),C(010)                              PIXEL OF oDlgXX
   @ C(044),C(057) MsGet    oGet1       Var   dInicial  Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(044),C(094) MsGet    oGet2       Var   dFinal    Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(044),C(131) Button   "Hoje"                      Size C(019),C(009)                              PIXEL OF oDlgXX ACTION( AltDataIniFim(3) )
   @ C(044),C(154) Button   "Mês"                       Size C(019),C(009)                              PIXEL OF oDlgXX ACTION( AltDataIniFim(5) )
   @ C(044),C(177) Button   "Ano"                       Size C(019),C(009)                              PIXEL OF oDlgXX ACTION( AltDataIniFim(6) )

   @ C(044),C(200) MsGet    oGet3       Var   cCliente  Size C(093),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX When lChumba
   @ C(034),C(295) Button   "Lmp Cli"                   Size C(023),C(009)                              PIXEL OF oDlgXX ACTION( cCliente := Space(100), oGet3:Refresh() )
   @ C(044),C(295) Button   "Clientes"                  Size C(023),C(009)                              PIXEL OF oDlgXX ACTION( xxpRapidaCli() )
   @ C(044),C(321) ComboBox cComboBx2   Items aVendedor Size C(082),C(010)                              PIXEL OF oDlgXX
   @ C(044),C(406) MsGet    oGet6       Var   cPVenda   Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(044),C(438) MsGet    oGet8       Var   cOCompra  Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(041),C(471) Button   "Atualizar"                 Size C(026),C(012)                              PIXEL OF oDlgXX ACTION( AtualizaTelaPV() )

   @ C(034),C(220) CheckBox oCheckBox1  Var   lTodaslojas Prompt "Considerar Todas Lojas" Size C(074),C(008) PIXEL OF oDlgXX
   @ C(034),C(359) CheckBox oCheckBox2  Var   lVend1      Prompt "VD 1"                   Size C(022),C(008) PIXEL OF oDlgXX
   @ C(034),C(383) CheckBox oCheckBox3  Var   lVend2      Prompt "VD 2"                   Size C(022),C(008) PIXEL OF oDlgXX

   @ C(010),C(376) Button "Todas as Vendas" Size C(048),C(012) PIXEL OF oDlgXX ACTION( xTodasAsVendas( aBrowsepc[oBrowsepc:nAt,06], aBrowsepc[oBrowsepc:nAt,07], aBrowsepc[oBrowsepc:nAt,08] ) )
   @ C(010),C(459) Button "Inclui Cliente"  Size C(037),C(012) PIXEL OF oDlgXX ACTION( xIncNovCli() )
   @ C(205),C(002) Button "P.Venda"         Size C(037),C(012) PIXEL OF oDlgXX ACTION( AcessaPV( aBrowsepc[obrowsepc:nAt,02], aBrowsepc[obrowsepc:nAt,04] ) )
   @ C(205),C(043) Button "Duplicar"        Size C(037),C(012) PIXEL OF oDlgXX ACTION( ChamaTPV () )
   @ C(205),C(084) Button "Obs. PV"         Size C(037),C(012) PIXEL OF oDlgXX ACTION( ObsIntPV( aBrowsepc[obrowsepc:nAt,02], aBrowsepc[obrowsepc:nAt,04] ) )
   @ C(205),C(125) Button "Preço Venda"     Size C(037),C(012) PIXEL OF oDlgXX ACTION( U_AUTOM184() )
   @ C(205),C(166) Button "Expedições"      Size C(037),C(012) PIXEL OF oDlgXX ACTION( U_AUTOM206() )
   @ C(205),C(210) Button "Acomp.PV"        Size C(037),C(012) PIXEL OF oDlgXX ACTION( U_AUTOM216() )
   @ C(205),C(251) Button "Legenda"         Size C(037),C(012) PIXEL OF oDlgXX ACTION( LGndPV() )
   @ C(205),C(292) Button "Status"          Size C(037),C(012) PIXEL OF oDlgXX ACTION( xMostraDStatus() )
   @ C(205),C(333) Button "Nº Serie"        Size C(037),C(012) PIXEL OF oDlgXX ACTION( xPegaNrSerie() )
   @ C(205),C(374) Button "LOG"             Size C(037),C(012) PIXEL OF oDlgXX ACTION( xMostraLog(Substr(aBrowsepc[obrowsepc:nAt,02],01,02), aBrowsepc[obrowsepc:nAt,04], aDetalhePC[oDetalhePC:nAt,04]) )
   @ C(205),C(374) Button "Emite DOCs."     Size C(037),C(012) PIXEL OF oDlgXX ACTION( U_AUTOM347() )

   @ C(205),C(459) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgXX ACTION( oDlgXX:End() )

   If Len(aBrowsepc) == 0
      aAdd( aBrowsepc, { "8", "", "", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif   

   obrowsepc := TCBrowse():New( 087 , 002, 635, 075,,{'LG'            , ; // 01
                                                    'Filial'          , ; // 02
                                                    'Tipo PV'         , ; // 03
                                                    'Nº P.Venda'      , ; // 04
                                                    'Dta Emissão'     , ; // 05
                                                    'Cliente'         , ; // 06
                                                    'Loja'            , ; // 07
                                                    'Nome Cliente'    , ; // 08
                                                    'Município'       , ; // 09
                                                    'UF'              , ; // 10
                                                    'Vendedor 1'      , ; // 11
                                                    'Nome Vendedor 1' , ; // 12
                                                    'Vendedor 2'      , ; // 13
                                                    'Nome Vendedor 2'}, ; // 14
                                                    {20,50,50,50},oDlgXX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   obrowsepc:SetArray(aBrowsepc) 
    
   obrowsepc:bLine := {||{ If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowsepc[obrowsepc:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowsepc[obrowsepc:nAt,02],;
                         aBrowsepc[obrowsepc:nAt,03],;
                         aBrowsepc[obrowsepc:nAt,04],;
                         aBrowsepc[obrowsepc:nAt,05],;
                         aBrowsepc[obrowsepc:nAt,06],;
                         aBrowsepc[obrowsepc:nAt,07],;
                         aBrowsepc[obrowsepc:nAt,08],;
                         aBrowsepc[obrowsepc:nAt,09],;
                         aBrowsepc[obrowsepc:nAt,10],;
                         aBrowsepc[obrowsepc:nAt,11],;
                         aBrowsepc[obrowsepc:nAt,12],;
                         aBrowsepc[obrowsepc:nAt,13],;
                         aBrowsepc[obrowsepc:nAt,14]}}

   obrowsepc:bLDblClick := {|| XQUEPRODUTO(Substr(aBrowsepc[obrowsepc:nAt,02],01,02), aBrowsepc[obrowsepc:nAt,04]) } 
   
   // Desenha o List de produtos para o pedido de venda selecionado
   If Len(aDetalhePC) == 0
      aAdd( aDetalhePC, { "","","","","","","","","","","","","","","","","","","","","","","","","","" })
   Endif   

   @ 175,002 LISTBOX oDetalhePC FIELDS HEADER 'Status', 'Descrição Status', 'Nº PV', 'Item', 'Produtos', 'Descrição dos Produtos', 'Qtd', 'Unitário', 'Vlr Total', 'Lacre', 'Nº Série', 'Dta Entrega PC', 'Dta Entrega PV', 'N.Fiscal', 'Série', 'Dta Fat.', 'Transp.', 'Descrição Transportadoras', 'Espécie', 'Volume', 'Peso Liquido', 'Pedo Bruto', 'Hora Expedição', 'Conhecimento', 'Nº OC', 'Código Postal' PIXEL SIZE 635,083 OF oDlgXX 

   oDetalhePC:SetArray( aDetalhePC )
   oDetalhePC:bLine := {||     {aDetalhePC[oDetalhePC:nAt,01],;
         		    		  aDetalhePC[oDetalhePC:nAt,02],;
          		    		  aDetalhePC[oDetalhePC:nAt,03],;
          		    		  aDetalhePC[oDetalhePC:nAt,04],;
          		    		  aDetalhePC[oDetalhePC:nAt,05],;
          		    		  aDetalhePC[oDetalhePC:nAt,06],;
          		    		  aDetalhePC[oDetalhePC:nAt,07],;
          		    		  aDetalhePC[oDetalhePC:nAt,08],;
          		    		  aDetalhePC[oDetalhePC:nAt,09],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,10],;
          		    		  aDetalhePC[oDetalhePC:nAt,11],;
          		    		  aDetalhePC[oDetalhePC:nAt,12],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,13],;
          		    		  aDetalhePC[oDetalhePC:nAt,14],;
          		    		  aDetalhePC[oDetalhePC:nAt,15],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,16],;
          		    		  aDetalhePC[oDetalhePC:nAt,17],;
          		    		  aDetalhePC[oDetalhePC:nAt,18],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,19],;
          		    		  aDetalhePC[oDetalhePC:nAt,20],;
          		    		  aDetalhePC[oDetalhePC:nAt,21],;
          		    		  aDetalhePC[oDetalhePC:nAt,22],;
          		    		  aDetalhePC[oDetalhePC:nAt,23],;
          		    		  aDetalhePC[oDetalhePC:nAt,24],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,25],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,26]}}

   oDetalhePC:Refresh()

   ACTIVATE MSDIALOG oDlgXX CENTERED 

Return(.T.)

// ###########################################################################
// Função que atualiza a tela com os pedidos conforme parâmetros informados ##
// ###########################################################################
Static Function AtualizaTelaPV()

   MsgRun("Aguarde! Pesquisando Pedidos de Venda ...", "Painel Comercial",{|| xAtualizaTelaPV() })

Return(.T.)

// ###########################################################################
// Função que atualiza a tela com os pedidos conforme parâmetros informados ##
// ###########################################################################
Static Function xAtualizaTelaPV()

   Local cSql := ""

   If dInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial de emissão dos pedidos de venda não informada para pesquisa.")
      Return(.T.)
   Endif
        
   If dFinal == Ctod("  /  /    ")
      MsgAlert("Data final de emissão dos pedidos de venda não informada para pesquisa.")
      Return(.T.)
   Endif

   If lVend1 == .T. .And. lVend2 == .T.
      MsgAlert("Informe somente vendedor 1 ou vendedor 2 para pesquisa.")
      Return(.T.)
   Endif   

   If lVend1 == .F. .And. lVend2 == .T.
      lVend1 := .T.
      lVend2 := .F.
   Endif   

   // #########################################################
   // Limpa o grid para receber novos resultados da pesquisa ##
   // #########################################################
   aBrowsepc := {}

   // ##############################################################
   // Pesquisa os pedidos de venda conforme parâmetros informados ##
   // ##############################################################
   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_EXTERNO," 
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_EMISSAO,"
   cSql += "       SC5.C5_CLIENTE,"
   cSql += "       SC5.C5_LOJACLI,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SA1.A1_MUN    ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SC5.C5_VEND1  ,"
   cSql += "       SC5.C5_LIBEROK,"
   cSql += "       SC5.C5_NOTA   ,"
   cSql += "       SC5.C5_BLQ    ,"
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = SC5.C5_VEND1 AND D_E_L_E_T_ = '') AS NVEND1,"
   cSql += " 	  SC5.C5_VEND2  ,"
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = SC5.C5_VEND2 AND D_E_L_E_T_ = '') AS NVEND2"
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SC5.C5_FILIAL   = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND SC5.C5_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
   cSql += "   AND SC5.C5_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
   cSql += "   AND SC5.D_E_L_E_T_  = ''"

   If Substr(cComboBx2,01,06) == "000000"
   Else
      If lVend1 == .T.
         cSql += "   AND SC5.C5_VEND1    = '" +  Substr(cComboBx2,01,06) + "'"
      Endif   
      If lVend2 == .T.
         cSql += "   AND SC5.C5_VEND2    = '" +  Substr(cComboBx2,01,06) + "'"
      Endif   
   Endif   

   If Empty(Alltrim(cCliente))
   Else
      If lTodasLojas == .F.
         cSql += " AND SC5.C5_CLIENTE = '" + Substr(cCliente,01,06) + "'"
         cSql += " AND SC5.C5_LOJACLI = '" + Substr(cCliente,08,03) + "'"
      Else
         cSql += " AND SC5.C5_CLIENTE = '" + Substr(cCliente,01,06) + "'"
      Endif            
   Endif

   If Empty(Alltrim(cPVenda))
   Else
      cSql += " AND SC5.C5_NUM = '" + Alltrim(cPVenda) + "'"
   Endif
   
   cSql += "   AND SA1.A1_COD      = SC5.C5_CLIENTE"
   cSql += "   AND SA1.A1_LOJA     = SC5.C5_LOJACLI"
   cSql += "   AND SA1.D_E_L_E_T_  = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )

   T_PEDIDOS->( DbGoTop() )
   
   WHILE !T_PEDIDOS->( EOF() )
   
      Do Case
         Case cEmpAnt == "01"
              Do Case 
                 Case T_PEDIDOS->C5_FILIAL == "01"
                      kFilial := "01 - AUTOMATECH POA"
                 Case T_PEDIDOS->C5_FILIAL == "02"
                      kFilial := "02 - AUTOMATECH CAXIAS DO SUL"
                 Case T_PEDIDOS->C5_FILIAL == "03"
                      kFilial := "03 - AUTOMATECH PELOTAS"
                 Case T_PEDIDOS->C5_FILIAL == "04"
                      kFilial := "04 - AUTOMATECH SUPRIMENTOS"
                 Case T_PEDIDOS->C5_FILIAL == "05"
                      kFilial := "05 - AUTOMATECH SÃO PAULO"
                 Case T_PEDIDOS->C5_FILIAL == "06"
                      kFilial := "06 - AUTOMATECH ESPIRITO SANTO"
                 Case T_PEDIDOS->C5_FILIAL == "07"
                      kFilial := "07 - AUTOMATECH SUPRIMENTOS"
               EndCase
                                     
         Case cEmpAnt == "02"
              kFilial := "01 - TI AUTOMAÇÃO"

         Case cEmpAnt == "03"
              kFilial := "01 - ATECH POA"

         Case cEmpAnt == "04"
              kFilial := "01 - ATECHPEL PELOTAS"
       
      EndCase

      kTipoPV  := IIF(T_PEDIDOS->C5_EXTERNO == "1", "INTERMEDIAÇÃO", "NORMAL")
      kEmissao := Substr(T_PEDIDOS->C5_EMISSAO,07,02) + "/" + Substr(T_PEDIDOS->C5_EMISSAO,05,02) + "/" + Substr(T_PEDIDOS->C5_EMISSAO,01,04)

      Do Case 
         Case Empty(T_PEDIDOS->C5_LIBEROK) .And. Empty(T_PEDIDOS->C5_NOTA) .And. Empty(T_PEDIDOS->C5_BLQ)         //Pedido em Aberto
              kLegenda := "2"

         Case !Empty(T_PEDIDOS->C5_NOTA) .Or. T_PEDIDOS->C5_LIBEROK == "E" .And. Empty(T_PEDIDOS->C5_BLQ)
              kLegenda := "8"
              
         Case !Empty(T_PEDIDOS->C5_LIBEROK) .And. Empty(T_PEDIDOS->C5_NOTA) .And. Empty(T_PEDIDOS->C5_BLQ)
              kLegenda := "4"                    

         Case T_PEDIDOS->C5_BLQ == "1" 
              kLegenda := "5"                    

         Case T_PEDIDOS->C5_BLQ == "2" 
              kLegenda := "6"                    

         Case T_PEDIDOS->C5_BLQ == "3" 
              kLegenda := "7"                    
              
         Otherwise
              kLegenda := "0"
                            
      EndCase
      
      aAdd( aBrowsepc, { kLegenda             ,; // 01
                       kFilial              ,; // 02
                       kTipoPV              ,; // 03
                       T_PEDIDOS->C5_NUM    ,; // 04
                       kEmissao             ,; // 05
                       T_PEDIDOS->C5_CLIENTE,; // 06
                       T_PEDIDOS->C5_LOJACLI,; // 07
                       T_PEDIDOS->A1_NOME   ,; // 08
                       T_PEDIDOS->A1_MUN    ,; // 09
                       T_PEDIDOS->A1_EST    ,; // 10
                       T_PEDIDOS->C5_VEND1  ,; // 11
                       T_PEDIDOS->NVEND1    ,; // 12
                       T_PEDIDOS->C5_VEND2  ,; // 13
                       T_PEDIDOS->NVEND2    }) // 14
                       
      T_PEDIDOS->( DbSkip() )
      
   Enddo
   
   If Len(aBrowsepc) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aBrowsepc, { "0", "", "", "", "", "", "", "", "", "", "", "", "", "" } )     
   Endif
      
   obrowsepc:SetArray(aBrowsepc) 
    
   obrowsepc:bLine := {||{ If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(abrowsepc[obrowsepc:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         abrowsepc[obrowsepc:nAt,02],;
                         abrowsepc[obrowsepc:nAt,03],;
                         abrowsepc[obrowsepc:nAt,04],;
                         abrowsepc[obrowsepc:nAt,05],;
                         abrowsepc[obrowsepc:nAt,06],;
                         abrowsepc[obrowsepc:nAt,07],;
                         abrowsepc[obrowsepc:nAt,08],;
                         abrowsepc[obrowsepc:nAt,09],;
                         abrowsepc[obrowsepc:nAt,10],;
                         abrowsepc[obrowsepc:nAt,11],;
                         abrowsepc[obrowsepc:nAt,12],;
                         abrowsepc[obrowsepc:nAt,13],;
                         abrowsepc[obrowsepc:nAt,14]}}

    // #################################################################################
    // Chama a função que pesquisa os produtos do primeiro pedido de venda se existir ##
    // #################################################################################
    
    xqueproduto(Substr(abrowsepc[obrowsepc:nAt,02],01,02), abrowsepc[obrowsepc:nAt,04])

Return(.T.)

// ################################################################################
// Função que altera a data inicial e data final e dispara a consulta novamebnte ##
// ################################################################################
Static Function AltDataIniFim(_TipoData)

   // ##########################################
   // Se tipo == 3, Selecionado botão H O J E ##
   // ##########################################
   If _TipoData == 3
      dInicial := Date()
      dFinal   := Date()
   Endif

   // ########################################
   // Se tipo == 5, Selecionado botão M Ê S ##
   // ########################################
   If _TipoData == 5
      dInicial := Ctod("01/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      dFinal   := Date()
   Endif

   // ########################################
   // Se tipo == 6, Selecionado botão A N O ##
   // ########################################
   If _TipoData == 6
      dInicial := Ctod("01/01/" + Strzero(Year(Date()),4))
      dFinal   := Ctod("31/12/" + Strzero(Year(Date()),4))
   Endif

   // ###########################################################################
   // Função que atualiza a tela com os pedidos conforme parâmetros informados ##
   // ###########################################################################
   AtualizaTelaPV()
   
Return(.T.)

// ################################################################
// Função que abre a janela com as legendas dos pedidos de venda ##
// ################################################################
Static Function LGndPV()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private oDlgLG

   DEFINE MSDIALOG oDlgLG TITLE "Legenda" FROM C(178),C(181) TO C(461),C(475) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgLG

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(141),C(001) PIXEL OF oDlgLG
   @ C(119),C(002) GET oMemo2 Var cMemo2 MEMO Size C(141),C(001) PIXEL OF oDlgLG
   
   @ C(042),C(020) Say "Pedidos de Venda em Aberto"                     Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(055),C(020) Say "Pedidos de Venda Encerrados"                    Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(068),C(020) Say "Pedidos de Venda Liberados"                     Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(081),C(020) Say "Pedidos de Venda Bloqueados por Regra"          Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(093),C(020) Say "Pedidos de Venda Bloqueados por Venda"          Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(105),C(020) Say "Pedidos de Venda Bloqueados por Preço de Venda" Size C(125),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
			   
   @ C(041),C(007) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgLG
   @ C(053),C(007) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlgLG
   @ C(066),C(007) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgLG
   @ C(079),C(007) Jpeg FILE "br_azul.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlgLG
   @ C(091),C(007) Jpeg FILE "br_laranja.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgLG
   @ C(103),C(007) Jpeg FILE "br_preto.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgLG

   @ C(125),C(054) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLG ACTION( oDlgLG:End() )

   ACTIVATE MSDIALOG oDlgLG CENTERED 

Return(.T.)

// #############################################################################
// Função que abre janela mostrando descrição dos Status dos Pedidos de Venda ##
// #############################################################################
Static Function xMostraDStatus()

   Private oDlgLegenda

   DEFINE MSDIALOG oDlgLegenda TITLE "Status dos Pedidos" FROM C(178),C(181) TO C(490),C(875) PIXEL

   @ C(004),C(005) Say "01-Aguardando Liberação - Significa que o pedido está aguardando início do processo (verificação do pedido por parte da área de estoque)"  Size C(332),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(013),C(005) Say "02-Aguardando Liberação Margem - Pedido com margem abaixo do mínimo "                                                                      Size C(181),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(022),C(005) Say "03-Aguardando Liberação de Credito - O pedido está aguardando análise de credito (liberação a ser realizada pelo departamento financeiro)" Size C(332),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(031),C(005) Say "04-Aguardando Liberação de Estoque - Avaliação por parte da área de estoque (itens que não possuem estoque e que devem ser adquiridos)"    Size C(335),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(040),C(005) Say "05-Aguardando data de entrega - Pedido está aguardando para ser faturado (exemplo programação de entrega de ribbons/etiquetas)"            Size C(332),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(049),C(005) Say "06-Em compra - Pedido está aguardando o fornecedor"                                                                                        Size C(131),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(058),C(005) Say "07-Em produção - Pedido está aguardando ser produzido"                                                                                     Size C(136),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(067),C(005) Say "08-Aguardando separação estoque - Pedido está sendo separado / liberação dos itens e números seriais"                                      Size C(251),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(076),C(005) Say "09-Aguardando cliente - Aguardando documentação de lacre e ou comprovante de deposito em caso de pagamento a vista"                        Size C(298),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(085),C(005) Say "10-Aguardando faturamento - Pedido já foi separado e está aguardando emissão da NF"                                                        Size C(208),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(094),C(005) Say "11-Item faturado - Já emitimos a NF"                                                                                                       Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(103),C(005) Say "12-Item expedido - Item já foi liberado para transportadora/cliente"                                                                       Size C(157),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(112),C(005) Say "13-Aguardando distribuidor - Em caso de pedido de intermediação, pedido ficará pendente em função do faturamento do distribuidor"          Size C(313),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(121),C(005) Say "14-Pedido cancelado"                                                                                                                       Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(130),C(005) Say "15-Pedido Com Análise de Crédito Rejeitado"                                                                                                Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda

   @ C(139),C(153) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgLegenda ACTION( oDlgLegenda:End() )

   ACTIVATE MSDIALOG oDlgLegenda CENTERED 

Return(.T.)

// #########################################################################
// Função que mostra todas as vendas efetuadas para o Cliente selecionado ##
// #########################################################################
Static Function xTodasAsVendas( xx_Cliente, xx_Loja, xx_Nome )

   Local cSql      := ""
   Local lChumba   := .F.
   Local cDadosCli := xx_cliente + "." + xx_Loja + " - " + Alltrim(xx_Nome)
   Local cMemo1	   := ""
   Local oGet1
   Local oMemo1
   
   Private aVendas := {}

   Private oDlgVDA

   If Empty(Alltrim(xx_Cliente))
      MsgAlert("Nenhum pedido de venda selecionado para realizar a pesquisa.")
      Return(.T.)
   Endif

   If Select("T_VENDAS") > 0
  	  T_VENDAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C6_FILIAL ,"
   cSql += "       B.C5_EMISSAO,"
   cSql += "       SUBSTRING(B.C5_EMISSAO,07,02) + '/' + "
   cSql += "       SUBSTRING(B.C5_EMISSAO,05,02) + '/' + "
   cSql += "       SUBSTRING(B.C5_EMISSAO,01,04) AS EMISSAO,"
   cSql += "       A.C6_NUM    ,"
   cSql += "       A.C6_NOTA   ,"
   cSql += "       A.C6_SERIE  ,"
   cSql += "       A.C6_ITEM   ,"
   cSql += "       A.C6_PRODUTO,"
   cSql += "       RTRIM(LTRIM(C.B1_DESC)) + ' ' + RTRIM(LTRIM(C.B1_DAUX)) AS DESCRICAO,"
   cSql += "       A.C6_QTDVEN ,"
   cSql += "       A.C6_PRCVEN ,"
   cSql += "       A.C6_VALOR  ,"
   cSql += "       B.C5_VEND1  ,"
   cSql += "       D.A3_NOME    "
   cSql += "  FROM " + RetSqlName("SC6") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B,
   cSql += "       " + RetSqlName("SB1") + " C,
   cSql += "       " + RetSqlName("SA3") + " D
   cSql += " WHERE A.C6_CLI     = '" + Alltrim(xx_cliente) + "'"
   cSql += "   AND A.C6_LOJA    = '" + Alltrim(xx_loja)    + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND B.C5_FILIAL  = A.C6_FILIAL"
   cSql += "   AND B.C5_NUM     = A.C6_NUM"
   cSql += "   AND B.C5_CLIENTE = A.C6_CLI"
   cSql += "   AND B.C5_LOJACLI = A.C6_LOJA"
   cSql += "   AND B.D_E_L_E_T_ = ''"
   cSql += "   AND C.B1_FILIAL  = ''"
   cSql += "   AND C.B1_COD     = A.C6_PRODUTO"
   cSql += "   AND C.D_E_L_E_T_ = ''"
   cSql += "   AND D.A3_FILIAL  = ''"
   cSql += "   AND D.A3_COD     = B.C5_VEND1"
   cSql += "   AND D.D_E_L_E_T_ = ''"
   cSql += " ORDER BY A.C6_FILIAL, B.C5_EMISSAO, A.C6_NUM, A.C6_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDAS", .T., .T. )

   aVendas := {}
   
   T_VENDAS->( DbGoTop() )
   
   WHILE !T_VENDAS->( EOF() )
   
      aAdd( aVendas, {T_VENDAS->C6_FILIAL ,;
                      T_VENDAS->EMISSAO   ,;
                      T_VENDAS->C6_NUM    ,;
                      T_VENDAS->C6_NOTA   ,;
                      T_VENDAS->C6_SERIE  ,;
                      T_VENDAS->C6_ITEM   ,;
                      T_VENDAS->C6_PRODUTO,;
                      T_VENDAS->DESCRICAO ,;
                      T_VENDAS->C6_QTDVEN ,;
                      T_VENDAS->C6_PRCVEN ,;
                      T_VENDAS->C6_VALOR  ,;
                      T_VENDAS->C5_VEND1  ,;
                      T_VENDAS->A3_NOME } )                      
                      
      T_VENDAS->( DbSkip() )
      
   ENDDO
  
   DEFINE MSDIALOG oDlgVDA TITLE "Relação de vendas efetuadas a Cliente" FROM C(178),C(181) TO C(603),C(967) PIXEL

   @ C(002),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgVDA

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlgVDA

   @ C(034),C(005) Say "Relação de todas as vendas efetuadas para o cliente" Size C(129),C(008) COLOR CLR_BLACK PIXEL OF oDlgVDA

   @ C(043),C(005) MsGet oGet1 Var cDadosCli Size C(383),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgVDA When lChumba

   @ C(196),C(351) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgVDA ACTION( oDlgVDA:End() )

   // Inicializa o browse 
   oVendas := TCBrowse():New( 075 , 005, 490, 170,,{'Fl', 'Data', 'Nº PV', 'N.Fiscal', 'Série', 'Item', 'Código', 'Descrição dos Produtos', 'Qtd', 'Unitário', 'Total', 'Vendedor', 'Descrição Vendedores'}, {20,50,50,50},oDlgVDA,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oVendas:SetArray(aVendas) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aVendas) == 0
      aAdd( aVendas, { "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   oVendas:bLine := {||{aVendas[oVendas:nAt,01],;
                        aVendas[oVendas:nAt,02],;
                        aVendas[oVendas:nAt,03],;
                        aVendas[oVendas:nAt,04],;
                        aVendas[oVendas:nAt,05],;
                        aVendas[oVendas:nAt,06],;
                        aVendas[oVendas:nAt,07],;
                        aVendas[oVendas:nAt,08],;
                        aVendas[oVendas:nAt,09],;
                        aVendas[oVendas:nAt,10],;
                        aVendas[oVendas:nAt,11],;
                        aVendas[oVendas:nAt,12],;                                                
                        aVendas[oVendas:nAt,13]}}
      
   oVendas:Refresh()

   ACTIVATE MSDIALOG oDlgVDA CENTERED 

Return(.T.)

// ####################################################################
// Função que solicita o tipo de inclusão de cliente a ser realizado ##
// ####################################################################
Static Function xIncNovCli()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgNcli

   DEFINE MSDIALOG oDlgNcli TITLE "Novo Formulário" FROM C(178),C(181) TO C(387),C(447) PIXEL

   @ C(002),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgNcli
   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(123),C(001) PIXEL OF oDlgNcli
   @ C(037),C(005) Say "Selecione o tipo de inclusão de cliente a ser utilizada" Size C(127),C(008) COLOR CLR_BLACK PIXEL OF oDlgNcli
   @ C(047),C(005) Button "Pelo Site do Sefaz" Size C(123),C(017) PIXEL OF oDlgNcli ACTION( oDlgNcli:End(), U_AUTOM246() )
   @ C(065),C(005) Button "Inclusão Manual"    Size C(123),C(017) PIXEL OF oDlgNcli ACTION( xAbreTelIncCli() )
   @ C(083),C(005) Button "Voltar"             Size C(123),C(017) PIXEL OF oDlgNcli ACTION( oDlgNcli:End() )

   ACTIVATE MSDIALOG oDlgNcli CENTERED 

Return(.T.)

// ####################################################################
// Função que solicita o tipo de inclusão de cliente a ser realizado ##
// ####################################################################
Static Function xAbreTelIncCli()

   Private cCadastro := "Inclusão Cadastro de Clientes"
   
   Inclui := .T.

   // Posiciona no cliente a ser pesquisado
   DbSelectArea("SA1")
   AxInclui("SA1", 0, 3)

   oDlgNcli:End()

Return(.T.)

// #####################################################
// Função: xPRAPIDACLI - Função que pesquisa clientes ##
// #####################################################
Static Function xxpRapidaCli()

   Local cMemo1	      := ""
   Local oMemo1

   Private cString	  := Space(100)
   Private cCadastro  := ""
   Private cCampo     := ReadVar()
   Private cCodLoja   := ReadVar()

   Private aCampo  	  := {"01 - Nome", "02 - Código", "03 - CNPJ/CPF", "04 - Município", "05 - E-Mail"}
   Private aOperador  := {"01 - Igual", "02 - Iniciando", "03 - Contendo"}
   Private aOrdenacao := {"01 - Por Código", "02 - Por Nome", "03 - Por CNPJ/CPF", "04 - Município"}

   Private oGet1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private aCliente   := {}

   Private oDlgCLI

   // Declara as Legendas
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

   // Limpa a variável que recebe o código do cliente
   cCliente := ""

   // Inicializa o conteúdo do combo
   cComboBx3 := "03 - Contendo"
   cComboBx4 := "02 - Por Nome"
   
   DEFINE MSDIALOG oDlgCLI TITLE "Pesquisa Cadastro de Entidades" FROM C(178),C(181) TO C(602),C(909) PIXEL

   @ C(008),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgCLI
   @ C(187),C(005) Jpeg FILE "br_verde"        Size C(009),C(009) PIXEL NOBORDER OF oDlgCLI
   @ C(187),C(074) Jpeg FILE "br_vermelho"     Size C(009),C(009) PIXEL NOBORDER OF oDlgCLI

   @ C(043),C(002) GET oMemo1 Var cMemo1 MEMO Size C(357),C(001) PIXEL OF oDlgCLI
   
   @ C(006),C(138) Say "String a Pesquisar"   Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgCLI
   @ C(030),C(138) Say "Ordenação Pesquisa"   Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgCLI
   @ C(019),C(138) Say "Pesquisar pelo Campo" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgCLI
   @ C(018),C(269) Say "Operação"             Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgCLI

   @ C(188),C(017) Say "Sem pendências financeiras" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgCLI
   @ C(188),C(086) Say "Com pendências financeiras" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlgCLI

   @ C(005),C(193) MsGet oGet1 Var cString  Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCLI
   @ C(003),C(323) Button "Pesquisar"       Size C(037),C(012) PIXEL OF oDlgCLI ACTION( xxbuscaCli() )

   @ C(018),C(193) ComboBox cComboBx2 Items aCampo     Size C(071),C(010) PIXEL OF oDlgCLI
   @ C(018),C(295) ComboBox cComboBx3 Items aOperador  Size C(065),C(010) PIXEL OF oDlgCLI
   @ C(029),C(193) ComboBox cComboBx4 Items aOrdenacao Size C(168),C(010) PIXEL OF oDlgCLI

   @ C(195),C(005) Button "Dados do Cadastro"   Size C(063),C(012) PIXEL OF oDlgCLI ACTION( xxCadCliente( aCliente[oCliente:nAt,02], aCliente[oCliente:nAt,03], "", aCliente[oCliente:nAt,01]) )
   @ C(195),C(074) Button "Contatos"            Size C(063),C(012) PIXEL OF oDlgCLI ACTION( U_AUTOMR60() )
   @ C(195),C(143) Button "Contato X Cliente "  Size C(063),C(012) PIXEL OF oDlgCLI ACTION( U_AUTOMR61(aCliente[oCliente:nAt,02], aCliente[oCliente:nAt,03]) )
   @ C(195),C(283) Button "Selecionar"          Size C(037),C(012) PIXEL OF oDlgCLI ACTION( xxSelCliente( aCliente[oCliente:nAt,02], aCliente[oCliente:nAt,03], aCliente[oCliente:nAt,04], aCliente[oCliente:nAt,01]) )
   @ C(195),C(322) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlgCLI ACTION( xxSelCliente( "", "", "", "") )

   aAdd( aCliente, { "1", "", "", "", "", "", "" })

   oCliente := TCBrowse():New( 062 , 005, 456, 175,,{"LG", "Código", "Loja", "Descrição", "CNPJ/CPF", "Município", "UF"}, {20,50,50,50},oDlgCLI,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oCliente:SetArray(aCliente) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aCliente) == 0
   Else
      oCliente:bLine := {||{ If(Alltrim(aCliente[oCliente:nAt,01]) == "1", oBranco  ,;
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "2", oVerde   ,;
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "3", oPink    ,;                         
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "4", oAmarelo ,;                         
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "5", oAzul    ,;                         
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "6", oLaranja ,;                         
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "7", oPreto   ,;                         
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "8", oVermelho,;
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "X", oCancel  ,;
                             If(Alltrim(aCliente[oCliente:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                             aCliente[oCliente:nAt,02]               ,;
                             aCliente[oCliente:nAt,03]               ,;
                             aCliente[oCliente:nAt,04]               ,;
                             aCliente[oCliente:nAt,05]               ,;
                             aCliente[oCliente:nAt,06]               }}

   Endif   
             
   oGet1:SetFocus()

   ACTIVATE MSDIALOG oDlgCLI CENTERED 

Return(.T.)

// #########################################################################################
// Função que fecha a janela pelo botão selecionar e transfere código e loja selecionados ##
// #########################################################################################
Static Function xxSelCliente(_Codigo, _Loja, _NomeCli, _Legenda)
   
   Local lVoltar  := .F.
   Local nPosicao := 0

   oDlgCLI:End()

   If Empty(Alltrim(_Codigo))
      cCliente := Space(100)
   Else
      cCliente := Alltrim(_Codigo) + "." + Alltrim(_Loja) + " - " + Alltrim(_NomeCli)
      Return(.T.)
   Endif
  
   oGet3:Refresh()
   
Return(.T.)

// ##########################################
// Função que pesquisa o cliente informado ##
// ##########################################
Static Function xxbuscaCli()

   Local cSql   := ""

   aArea := GetArea()
   
   aCliente := {}

   If Len(Alltrim(cString)) == 0
      aAdd( aCliente, { '1', '', '', '', '', '', '' } )
      oCliente:SetArray(aCliente) 
      Return .T.
   Endif   

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.A1_COD ," + chr(13)
   cSql += "       A.A1_LOJA," + chr(13)
   cSql += "       A.A1_NOME," + chr(13)
   cSql += "       CASE WHEN LEN(A.A1_CGC) = 14  THEN SUBSTRING(A.A1_CGC,01,02) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,03,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,06,03) + '/' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,09,04) + '-' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,13,02)        " + chr(13)
   cSql += "            WHEN LEN(A.A1_CGC) <> 14 THEN SUBSTRING(A.A1_CGC,01,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,04,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,07,03) + '-' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,10,02)        " + chr(13)
   cSql += "       END AS CGC," + chr(13)
   cSql += "       A.A1_MUN  ," + chr(13)
   cSql += "       A.A1_EST   " + chr(13)
   cSql += "  FROM " + RetSqlName("SA1") + " A " + chr(13)
   cSql += " WHERE A.D_E_L_E_T_ = ''"   + chr(13)
   cSql += "   AND A.A1_MSBLQL <> '1'"

   Do Case

      // Nome
      Case Substr(cComboBx2,01,02) = "01"
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND UPPER(A.A1_NOME) = '" + Alltrim(cString) + "'" + CHR(13)
              // Iniciando
              Case Substr(cComboBx3,01,02) == "02" 
                   cSql += " AND UPPER(A.A1_NOME) LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND UPPER(A.A1_NOME) LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // Código
      Case Substr(cComboBx2,01,02) = "02"
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND A.A1_COD = '" + Alltrim(cString) + "'" + CHR(13)
              // Iniciando
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += " AND A.A1_COD  LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND A.A1_COD  LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // CNPJ/CPF
      Case Substr(cComboBx2,01,02) = "03"
           Do Case
              Case Substr(cComboBx3,01,02) == "01" // Igual
                   cSql += " AND A.A1_CGC = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx3,01,02) == "02" // Iniciando
                   cSql += " AND A.A1_CGC LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx3,01,02) == "03" // Contendo
                   cSql += " AND A.A1_CGC LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // Município
      Case Substr(cComboBx2,01,02) = "04" 
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND UPPER(A.A1_MUN) = '" + Alltrim(cString) + "'" + CHR(13)
              // Inicando
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += " AND UPPER(A.A1_MUN) LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND UPPER(A.A1_MUN) LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // E-Mail
      Case Substr(cComboBx2,01,02) = "05" 
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND UPPER(A.A1_EMAIL) = '" + upper(Alltrim(cString)) + "'" + CHR(13)
              // Inicando
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += " AND UPPER(A.A1_EMAIL) LIKE '" + upper(Alltrim(cString)) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND UPPER(A.A1_EMAIL) LIKE '%" + upper(Alltrim(cString)) + "%'" + CHR(13)
           EndCase                   

   EndCase

   // Ordenação
   Do Case
      // Código
      Case Substr(cComboBx4,01,02) == "01"
           cSql += " ORDER BY A.A1_COD, A.A1_LOJA" + CHR(13)
      // Descrição
      Case Substr(cComboBx4,01,02) == "02" 
           cSql += " ORDER BY A.A1_NOME" + CHR(13)
      // Part Number
      Case Substr(cComboBx4,01,02) == "03" 
           cSql += " ORDER BY A.A1_CGC" + CHR(13)
      // NCM
      Case Substr(cComboBx4,01,02) == "04" 
           cSql += " ORDER BY A.A1_MUN" + CHR(13)
   EndCase                   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aCliente, { '1', '', '', '', '', '', '' } )
   Else

      T_CLIENTE->( DbGoTop() )

      WHILE !T_CLIENTE->( EOF() )

         // Pesquisa possíveis parcelas em atraso
         If Select("T_PARCELAS") > 0
            T_PARCELAS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.E1_CLIENTE ,"
         cSql += "       A.E1_LOJA    ,"
         cSql += "       A.E1_PREFIXO ,"
         cSql += "       A.E1_NUM     ,"
         cSql += "       A.E1_PARCELA ,"
         cSql += "       A.E1_EMISSAO ,"
         cSql += "       A.E1_VENCTO  ,"
         cSql += "       A.E1_BAIXA   ,"
         cSql += "       A.E1_VALOR   ,"
         cSql += "       A.E1_SALDO    "
         cSql += "  FROM " + RetSqlName("SE1") + " A "
         cSql += " WHERE A.D_E_L_E_T_ = ''"
         cSql += "   AND A.E1_SALDO  <> 0 "
         cSql += "   AND A.E1_CLIENTE = '" + Alltrim(T_CLIENTE->A1_COD)   + "'"
         cSql += "   AND A.E1_LOJA    = '" + Alltrim(T_CLIENTE->A1_LOJA)  + "'"
         cSql += "   AND A.E1_VENCTO < CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
         cSql += "   AND (A.E1_TIPO   <> 'RA' AND A.E1_TIPO <> 'NCC')"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

         If T_PARCELAS->( EOF() )
            _Devedor := "2"
         Else
            _Devedor := "8"         
         Endif

         aAdd( aCliente, { _Devedor                      ,;
                          T_CLIENTE->A1_COD             ,;
                          T_CLIENTE->A1_LOJA            ,;
                          T_CLIENTE->A1_NOME + Space(50),;
                          T_CLIENTE->CGC     + Space(10),;
                          T_CLIENTE->A1_MUN  + Space(30),;
                          T_CLIENTE->A1_EST             })

         T_CLIENTE->( DbSkip() )

      ENDDO

   Endif

   // Seta vetor para a browse                            
   oCliente:SetArray(aCliente) 
    
   oCliente:bLine := {||{ If(Alltrim(aCliente[oCliente:nAt,01]) == "1", oBranco  ,;
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "2", oVerde   ,;
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "3", oPink    ,;                         
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "4", oAmarelo ,;                         
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "7", oPreto   ,;                         
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "8", oVermelho,;
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(aCliente[oCliente:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                          aCliente[oCliente:nAt,02]               ,;
                          aCliente[oCliente:nAt,03]               ,;
                          aCliente[oCliente:nAt,04]               ,;
                          aCliente[oCliente:nAt,05]               ,;
                          aCliente[oCliente:nAt,06]               }}

   RestArea( aArea )

Return(.T.)

// #########################################################
// Função que visualiza o cadastro do cliente selecionado ##
// #########################################################
Static Function xxCadCliente(_Codigo, _Loja)
                           
   Private Inclui := .F.

   If Empty(Alltrim(_Codigo))
      MsgAlert("Necessário selecione um cliente para realizar esta operação.")
      Return(.T.)
   Endif

   aArea := GetArea()
   
   // Posiciona no cliente a ser pesquisado
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1") + _Codigo + _Loja)

// AxVisual("SA1", SA1->( Recno() ), 1)
   AxAltera("SA1", SA1->( Recno() ), 4)

   RestArea( aArea )

Return(.T.)

// #####################################################
// Função que pesquisa os dados do pedido selecionado ##
// #####################################################
Static Function xqueproduto(_Filial, _Pedido)

   Local cSql 

   If Empty(Alltrim(_Pedido))
      Return(.T.)
   Endif
      
   aDetalhePC := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT SC6.C6_STATUS ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_PRCVEN ,"
   cSql += "       SC6.C6_PRVCOMP,"
   cSql += "       SC6.C6_VALOR  ,"
   cSql += "       SC6.C6_LACRE  ,"
   cSql += "       SC6.C6_ORDC   ,"
   cSql += "       SB1.B1_LOCALIZ,"
   cSql += "       ' ' AS LOG    ,"
   cSql += "       SC6.C6_NOTA   ,"
   cSql += "       SC6.C6_SERIE  ,"
   cSql += "       SC6.C6_DATFAT ,"
   cSql += "       SC6.C6_ENTREG ,"
   cSql += "       SC6.C6_SUGENTR,"
   cSql += "      (SELECT C5_TRANSP  FROM " + RetSqlName("SC5") + " WHERE C5_FILIAL = SC6.C6_FILIAL AND C5_NUM = SC6.C6_NUM AND D_E_L_E_T_ = '') AS TRANSPO,"
   cSql += "      (SELECT F2_ESPECI1 FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS ESPECIE ,"
   cSql += "      (SELECT F2_VOLUME1 FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS VOLUME  ,"
   cSql += "      (SELECT F2_PLIQUI  FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS PLIQUIDO,"
   cSql += "      (SELECT F2_PBRUTO  FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS PBRUTO  ,"
   cSql += "      (SELECT F2_HREXPED FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS HORA    ,"
   cSql += "      (SELECT F2_CONHECI FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS CONHECIMENTO,"
   cSql += "      (SELECT F2_POSTAL  FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS COD_POSTAL"   
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SB1.B1_FILIAL  = ''            "
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
   cSql += "   AND SC6.D_E_L_E_T_ = ''            "
   cSql += "   AND SC6.C6_FILIAL  = '" + Alltrim(_Filial) + "'"
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   If T_DETALHE->( EOF() )
      aAdd( aDetalhePC, { "","","","","","","","","","","","","","","","","","","","","","","","","","" })
   Else
      WHILE !T_DETALHE->( EOF() )
      
         Do Case
            Case T_DETALHE->C6_STATUS == "01"
                 nStatus := "Aguardando Liberação"
            Case T_DETALHE->C6_STATUS == "02"
                 nStatus := "Aguardando Liberação Margem"
            Case T_DETALHE->C6_STATUS == "03"
                 nStatus := "03-Aguardando Liberação de Credito"
            Case T_DETALHE->C6_STATUS == "04"
                 nStatus := "04-Aguardando Liberação de Estoque"
            Case T_DETALHE->C6_STATUS == "05"
                 nStatus := "05-Aguardando data de entrega"
            Case T_DETALHE->C6_STATUS == "06"
                 nStatus := "06-Em compra"
            Case T_DETALHE->C6_STATUS == "07"
                 nStatus := "07-Em produção"
            Case T_DETALHE->C6_STATUS == "08"
                 nStatus := "08-Aguardando separação estoque"
            Case T_DETALHE->C6_STATUS == "09"
                 nStatus := "09-Aguardando cliente"
            Case T_DETALHE->C6_STATUS == "10"
                 nStatus := "10-Aguardando faturamento"
            Case T_DETALHE->C6_STATUS == "11"
                 nStatus := "11-Item faturado"
            Case T_DETALHE->C6_STATUS == "12"
                 nStatus := "12-Item expedido"
            Case T_DETALHE->C6_STATUS == "13"
                 nStatus := "13-Aguardando distribuidor"
            Case T_DETALHE->C6_STATUS == "14"
                 nStatus := "14-Pedido cancelado"
            Case T_DETALHE->C6_STATUS == "15"
                 nStatus := "15-Análise de Crédito Rejeitado"
            Otherwise
                 nStatus := "Status Indefinido"
         EndCase         

         // Pesquisa a data de entrega de produtos se houver
         If Select("T_PREVISTO") > 0
            T_PREVISTO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
         cSql += "  FROM " + RetSqlName("SC7")
         cSql += " WHERE C7_FILIAL  = '01'"
         cSql += "   AND C7_PRODUTO = '" + Alltrim(T_DETALHE->C6_PRODUTO) + "'"
         cSql += "   AND C7_QUANT <> C7_QUJE"
         cSql += "   AND D_E_L_E_T_ = ''"
         cSql += " ORDER BY C7_DATPRF DESC"
      
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

         cDatPrevista := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

         // Carrega o Grid com os dados dos produtos do pedido selecionado
         aAdd( aDetalhePC, { T_DETALHE->C6_STATUS                           ,;
                           nStatus                                        ,;
                           T_DETALHE->C6_NUM                              ,;
                           T_DETALHE->C6_ITEM                             ,;
                           T_DETALHE->C6_PRODUTO                          ,;
                           T_DETALHE->B1_DESC                             ,;
                           T_DETALHE->C6_QTDVEN                           ,;         
                           T_DETALHE->C6_PRCVEN                           ,;
                           T_DETALHE->C6_VALOR                            ,;
                           IIF(T_DETALHE->C6_LACRE   == "S", "SIM", "NÃO"),;
                           IIF(T_DETALHE->B1_LOCALIZ == "S", "SIM", "NÃO"),;
                           cDatPrevista                                   ,;
                           Substr(T_DETALHE->C6_ENTREG,07,02) + "/" + Substr(T_DETALHE->C6_ENTREG,05,02) + "/" + Substr(T_DETALHE->C6_ENTREG,01,04) ,;
                           T_DETALHE->C6_NOTA                             ,;
                           T_DETALHE->C6_SERIE                            ,;
                           Substr(T_DETALHE->C6_DATFAT,07,02) + "/" + Substr(T_DETALHE->C6_DATFAT,05,02) + "/" + Substr(T_DETALHE->C6_DATFAT,01,04) ,;
                           T_DETALHE->TRANSPO                             ,;
     			           IIF(T_DETALHE->TRANSPO <> '', Posicione( "SA4", 1, xFilial("SA4") + T_DETALHE->TRANSPO, "A4_NOME" ), ''),;
                           T_DETALHE->ESPECIE                             ,;
                           T_DETALHE->VOLUME                              ,;
                           T_DETALHE->PLIQUIDO                            ,;
                           T_DETALHE->PBRUTO                              ,;
                           T_DETALHE->HORA                                ,;
                           T_DETALHE->CONHECIMENTO                        ,;
                           T_DETALHE->C6_ORDC                             ,;
                           T_DETALHE->COD_POSTAL                          })
         T_DETALHE->( DbSkip() )                           

      ENDDO   

   Endif
      
   oDetalhePC:SetArray( aDetalhePC )
   oDetalhePC:bLine := {||     {aDetalhePC[oDetalhePC:nAt,01],;
         		    		  aDetalhePC[oDetalhePC:nAt,02],;
           		    		  aDetalhePC[oDetalhePC:nAt,03],;
           		    		  aDetalhePC[oDetalhePC:nAt,04],;
          		    		  aDetalhePC[oDetalhePC:nAt,05],;
          		    		  aDetalhePC[oDetalhePC:nAt,06],;
          		    		  aDetalhePC[oDetalhePC:nAt,07],;
          		    		  aDetalhePC[oDetalhePC:nAt,08],;
          		    		  aDetalhePC[oDetalhePC:nAt,09],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,10],;
          		    		  aDetalhePC[oDetalhePC:nAt,11],;
          		    		  aDetalhePC[oDetalhePC:nAt,12],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,13],;
          		    		  aDetalhePC[oDetalhePC:nAt,14],;
          		    		  aDetalhePC[oDetalhePC:nAt,15],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,16],;
          		    		  aDetalhePC[oDetalhePC:nAt,17],;
          		    		  aDetalhePC[oDetalhePC:nAt,18],;          		    		  
          		    		  aDetalhePC[oDetalhePC:nAt,19],;
          		    		  aDetalhePC[oDetalhePC:nAt,20],;
          		    		  aDetalhePC[oDetalhePC:nAt,21],;
          		    		  aDetalhePC[oDetalhePC:nAt,22],;
          		    		  aDetalhePC[oDetalhePC:nAt,23],;
          		    		  aDetalhePC[oDetalhePC:nAt,24],;
          		    		  aDetalhePC[oDetalhePC:nAt,25],;
          		    		  aDetalhePC[oDetalhePC:nAt,26]}}
   oDetalhePC:Refresh()
  
Return(.T.)

// ###############################################################
// Tela para exibir a sequencia de logs para o item selecionado ##
// ###############################################################
Static Function xMostraLog( _Filial, _Pedido, _Item )
	
	Local _cTitle := "Log de Status - PV: " + _Pedido +" Item: " + _Item
	Local cQuery := ""
	Local aStru  := {}
	Local aMlog  := {}
	Local oMlog
	
	If Select("T_ZZ0") > 0
		T_ZZ0->( dbCloseArea() )
	EndIf

	cQuery := " SELECT * "
	cQuery += "   FROM "+ RetSqlName("ZZ0")
	cQuery += "  WHERE ZZ0_PEDIDO = '" + Alltrim(_Pedido) + "'"
	cQuery += "    AND ZZ0_ITEMPV = '" + Alltrim(_Item)   + "'"
	cQuery += "    AND ZZ0_FILIAL = '" + Alltrim(_Filial) + "'"
	cQuery += "    AND D_E_L_E_T_ = '' "
	cQuery += "  ORDER BY ZZ0_DATA, ZZ0_HORA "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_ZZ0",.T.,.T.)
	
    // ##############################
	// Formatar os campos para uso ##
	// ##############################
	aStru := T_ZZ0->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_ZZ0->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_ZZ0", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )

	T_ZZ0->( dbGoTop() )

    // ################################
    // Vetor com elementos do Browse ##
    // ################################
	While !T_ZZ0->( Eof() )
		aAdd( aMlog, { Padr( Iif( T_ZZ0->ZZ0_STATUS <> '  ', T_ZZ0->ZZ0_STATUS+"-"+ Tabela( "Z0", T_ZZ0->ZZ0_STATUS ), "SEM STATUS" ),60 ),;
					   PadR( T_ZZ0->ZZ0_USER+"-"+ Upper( UsrRetName( T_ZZ0->ZZ0_USER ) ), 30 ),;
					   PadR( DtoC( StoD( T_ZZ0->ZZ0_DATA ) ), 10 ),;
					   PadR( T_ZZ0->ZZ0_HORA, 10 ),;
					   Padr( T_ZZ0->ZZ0_ORIGEM, 20 ) } )
		T_ZZ0->( dbSkip() )
	End
       
	T_ZZ0->( dbCloseArea() )

	If Len( aMlog ) > 0

		DEFINE DIALOG oDlg2 TITLE _cTitle FROM 180,180 TO 500,800 PIXEL
		                 
        // ##############
		// Cria Browse ##
		// ##############
		oMlog := TCBrowse():New( 01, 01, 310, 156,, {PadR('Status',60),PadR('Usuário',30),PadR('Data',10),PadR('Hora',10),PadR('Origem',25) },{20,50,50,50},oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
		// Seta vetor para a browse
		oMlog:SetArray(aMlog) 
	
        // ######################################## 
		// Monta a linha a ser exibida no Browse ##
		// ########################################
		oMlog:bLine := {||{ aMlog[ oMlog:nAt, 01 ], aMlog[ oMlog:nAt, 02 ], aMlog[ oMlog:nAT, 03 ], aMlog[ oMlog:nAT, 04 ], aMlog[ oMlog:nAT, 05 ] } }
	
        // ##########################################
		// Evento de clique no cabeçalho da browse ##
		// ##########################################
		oMlog:bHeaderClick := {|| Nil } 
	
        // ##################################
		// Evento de duplo click na celula ##
		// ##################################
		oMlog:bLDblClick   := {|| Nil }
	
		ACTIVATE DIALOG oDlg2 CENTERED 

	Else                
	
		MsgAlert( "Nenhum log registrado para o PV: " + Alltrim(_Pedido) + " Item: " + Alltrim(_Item) )
	EndIf

Return(.T.)

// ##############################################################
// Função que pesquisa os nºs de séries do produto selecionado ##
// ##############################################################
Static Function xPegaNrSerie()

   Private oDlgS

   Private aSeries := {}
   Private oSeries

   If Alltrim(aDetalhePC[oDetalhePC:nAt,11]) <> "SIM"
      MsgAlert("Produto não tem seu controle por nº de série.")
      Return(.T.)
   Endif

   If Empty(Alltrim(aDetalhePC[oDetalhePC:nAt,13]))
      MsgAlert("Produto ainda não faturado. Aguarde Faturamento para pesquisa dos nºs de séries.")
      Return(.T.)
   Endif

   If Select("T_SERIES") > 0
      T_SERIES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DB_NUMSERI"
   cSql += "  FROM " + RetSqlName("SDB")
   cSql += " WHERE DB_FILIAL  = '" + Alltrim(Substr(abrowsepc[obrowsepc:nAt,02],01,02))   + "'"
   cSql += "   AND DB_PRODUTO = '" + Alltrim(aDetalhePC[oDetalhePC:nAt,05]) + "'"
   cSql += "   AND DB_DOC     = '" + Alltrim(aDetalhePC[oDetalhePC:nAt,13]) + "'"
   cSql += "   AND DB_SERIE   = '" + Alltrim(aDetalhePC[oDetalhePC:nAt,14]) + "'"
   cSql += "   AND DB_CLIFOR  = '" + Alltrim(abrowsepc[obrowsepc:nAt,06])   + "'"
   cSql += "   AND DB_LOJA    = '" + Alltrim(abrowsepc[obrowsepc:nAt,07])   + "'"
   cSql += "   AND D_E_L_E_T_ = ''
   cSql += " ORDER BY DB_NUMSERI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

   If T_SERIES->( EOF() )
      aAdd( aSeries, { "" } )
   Else
      T_SERIES->( DbGoTop() )
      WHILE !T_SERIES->( EOF() )
         aAdd( aSeries, { T_SERIES->DB_NUMSERI })
         T_SERIES->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgS TITLE "Nºs de Séries" FROM C(178),C(181) TO C(534),C(450) PIXEL

   @ C(005),C(005) Say "Nº de Séries do produto selecionado" Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

   @ C(162),C(091) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgS ACTION( oDlgs:End() )

   // ######################################
   // Cria Componentes Padroes do Sistema ##
   // ######################################
   @ 015,005 LISTBOX oSeries FIELDS HEADER "Nºs de Séries" PIXEL SIZE 160,188 OF oDlgS ;
                            ON dblClick(aSeries[oSeries:nAt,1] := !aSeries[oSeries:nAt,1],oSeries:Refresh())     
   oSeries:SetArray( aSeries )
   oSeries:bLine := {||     {aSeries[oSeries:nAt,01]}}

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)

// ##############################################
// Função que abre a tela dos pedidos de venda ##
// ##############################################
Static Function ChamaTPV()

   // ####################################################################################
   // Altera a variável para T para poder permitir realizar a copia de pedido de venda  ##
   // ####################################################################################
   putmv("MV_VEXE", .T.)

   // ######################################
   // Abre o programa de pedidos de venda ##
   // ######################################
   MATA410()

   // ###################################### 
   // Atualiza a tela do Painel Comercial ##
   // ######################################
   AtualizaTelaPV()                         
   
Return(.T.)

// ###############################################################
// Função que permite visualizar observações do pedido de venda ##
// ###############################################################
Static Function ObsIntPV(_Filial, _Pedido)

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2
   Local cSql    := ""

   Private oDlgOBS

   If Select("T_OBSERVA") > 0
      T_OBSERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C5_MENNOTA)) AS OBS01, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C5_OBSI))    AS OBS02  "
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_FILIAL = '" + Substr(_Filial,01,02) + "'"
   cSql += "   AND C5_NUM    = '" + Alltrim(_Pedido)      + "'"
   cSql += "   AND D_E_L_E_T_ = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )

   If T_OBSERVA->( EOF() )
      cMemo1 := ""
      cMemo2 := ""
   Else
      cMemo1 := T_OBSERVA->OBS01
      cMemo2 := T_OBSERVA->OBS02
   Endif      

   // ###############################################
   // Desenha a tela para verificar as observações ##
   // ###############################################
   DEFINE MSDIALOG oDlgOBS TITLE "Observações Pedido de Venda" FROM C(178),C(181) TO C(484),C(713) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlgOBS

   @ C(033),C(005) Say "Observações p/Nota Fiscal"  Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgOBS
   @ C(083),C(005) Say "Observações Internas"       Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgOBS

   @ C(041),C(005) GET oMemo1 Var cMemo1 MEMO Size C(256),C(041) PIXEL OF oDlgOBS
   @ C(092),C(005) GET oMemo2 Var cMemo2 MEMO Size C(256),C(041) PIXEL OF oDlgOBS

   @ C(137),C(224) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgOBS ACTION( oDlgOBS:End() )

   ACTIVATE MSDIALOG oDlgOBS CENTERED 

Return(.T.)

// ###################################################
// Função que abre o pedido de venda conforme opção ##
// ###################################################
Static Function AcessaPV(kFilial, kPedido)

   Private oDlgAbrPV
   
   DEFINE MSDIALOG oDlgAbrPV TITLE "Pedido de Venda" FROM C(178),C(181) TO C(352),C(428) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgAbrPV

   @ C(031),C(002) Button "Incluir Pedido de Venda"    Size C(118),C(017) PIXEL OF oDlgAbrPV ACTION( AbrePVPAR("I", kFilial, kPedido) )
   @ C(049),C(002) Button "Visualizar Pedido de Venda" Size C(118),C(017) PIXEL OF oDlgAbrPV ACTION( AbrePVPAR("V", kFilial, kPedido) )
   @ C(067),C(002) Button "Voltar"                     Size C(118),C(017) PIXEL OF oDlgAbrPV ACTION( oDlgAbrPV:eND() )

   ACTIVATE MSDIALOG oDlgAbrPV CENTERED 

Return(.T.)

// ###################################################
// Função que abre o pedido de venda conforme opção ##
// ###################################################
Static Function AbrePVPAR(kTipo, kFilial, kPedido)

   Local aArea       := GetArea() //Irei gravar a are3a atual

   Private Inclui    := IIF(kTipo == "I", .T., .F.)
   Private Altera    := .F.
   Private VISUAL    := IIF(kTipo == "V", .T., .F.)
   Private nOpca     := 1                  
   Private cCadastro := "Pedido de Vendas" 
   Private aRotina   := {}                 

   If kTipo == "I"
  	  MatA410(Nil, Nil, Nil, Nil, "A410Inclui") //executo a função padrão MatA410
   Endif
   	  
   If kTipo == "V"

      If Empty(Alltrim(kPedido))
         MsgAlert("Pedido de venda não selecionado para ser visualizado.")
         Return(.T.)
      Endif   

      DbSelectArea("SC5")
      DbSetorder(1)
      If DbSeek(Substr(kFilial,01,02) + kPedido)
   	     MatA410(Nil, Nil, Nil, Nil, "A410Visual")
      Endif
   Endif

   RestArea(aArea)

Return



