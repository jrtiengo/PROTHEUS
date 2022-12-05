#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

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
// Referencia: AUTOM647.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 11/10/2017                                                          ##
// Objetivo..: Programa que permite usuários verificarem pedidos de venda que ti-  ##
//             veram erro ao consultar o Web Service do SimFrete do Sale Machine.  ##
// ##################################################################################

User Function AUTOM647()

   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas   := U_AUTOM539(1, "")
   Private aFiliais    := U_AUTOM539(2, cEmpAnt)
   Private aVendedores := {}
   Private aStatus     := {"1 - A Resolver", "2 - Resolvidos", "3 - Ambos"}

   Private cInicial    := Ctod("01/01/" + Strzero(YEAR(DATE(),4)))
   Private cFinal      := Ctod("31/12/" + Strzero(YEAR(DATE(),4)))

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private oGet1
   Private oGet2

   Private oDlg

   Private aBrowse := {}

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

   U_AUTOM628("AUTOM288")

   // ###################################
   // Inicializa o array de vendedores ##
   // ###################################
   aAdd( aVendedores, "000000 - Todos os Vendedores" )

   If Select("T_VENDEDORES") > 0
      T_VENDEDORES->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT A.A3_COD   ,"
   cSql += "       A.A3_NOME  ,"
   cSql += "       A.A3_CODUSR,"
   cSql += "       A.A3_TSTAT  "
   cSql += "  FROM " + RetSqlName("SA3") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.A3_CODUSR <> ''"
   cSql += "   AND A.A3_NREDUZ <> ''"
   cSql += " ORDER BY A.A3_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDORES", .T., .T. )

   T_VENDEDORES->( DbGoTop() )

   WHILE !T_VENDEDORES->( EOF() )
      If Empty(Alltrim(T_VENDEDORES->A3_NOME))
         T_VENDEDORES->( DbSkip() )         
         Loop
      Endif   
      aAdd( aVendedores, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )
      T_VENDEDORES->( DbSkip() )
   ENDDO

   // #########################################################################################################################
   // Envia para a função que mostra os pedidos de venda com problema na consulta do web service do simfrete do sale machine ##
   // #########################################################################################################################
   ErroWSSFSM(0)

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Pedidos de Venda com erro na consulta do web service - SIMFRETE SM" FROM C(178),C(181) TO C(593),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg
   @ C(194),C(005) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(194),C(048) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO  Size C(385),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Empresa"      Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(064) Say "Filial"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(124) Say "Data Inicial" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(167) Say "Data Final"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(211) Say "Vendedor"     Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(308) Say "Status"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(195),C(018) Say "A Resolver"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(195),C(061) Say "Resolvidos"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) ComboBox cComboBx1 Items aEmpresas   Size C(054),C(010)                              PIXEL OF oDlg  ON CHANGE ALTERACOMBO()
   @ C(045),C(064) ComboBox cComboBx2 Items aFiliais    Size C(054),C(010)                              PIXEL OF oDlg
   @ C(045),C(124) MsGet    oGet1     Var   cInicial    Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(167) MsGet    oGet2     Var   cFinal      Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(211) ComboBox cComboBx3 Items aVendedores Size C(094),C(010)                              PIXEL OF oDlg
   @ C(045),C(308) ComboBox cComboBx4 Items aStatus     Size C(039),C(010)                              PIXEL OF oDlg

   @ C(042),C(351) Button "Pesquisar"                      Size C(037),C(012) PIXEL OF oDlg ACTION( ErroWSSFSM(1) )
   @ C(192),C(095) Button "Visualizar Retorno"             Size C(051),C(012) PIXEL OF oDlg ACTION( VerDetalhe() )
   @ C(192),C(147) Button "Pedido de Venda"                Size C(051),C(012) PIXEL OF oDlg ACTION( AbrePVSF() )
   @ C(192),C(199) Button "Consultar Web Service SimFrete" Size C(089),C(012) PIXEL OF oDlg ACTION( BuscaSFWSSM() )
   @ C(192),C(289) Button "Solucionar Ped.Venda"           Size C(060),C(012) PIXEL OF oDlg
   @ C(192),C(351) Button "Voltar"                         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ 075,005 LISTBOX oBrowse FIELDS HEADER "Leg"                      ,; // 01
                                           "Nº Ped.Venda"             ,; // 02
                                           "Seq"                      ,; // 03
                                           "Dta Emissão"              ,; // 04
                                           "Cliente"                  ,; // 05
                                           "Loja"                     ,; // 06
                                           "Descrição dos Clientes"   ,; // 07
                                           "Vendedor"                 ,; // 08
                                           "Descrição dos Vendedores" ,; // 09  
                                           "Erro Web Service"          ; // 10
                                           PIXEL SIZE 493,167 OF oDlg ON LEFT DBLCLICK ( TrocaCor()), ON RIGHT CLICK (TrocaCor())

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||    {If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                            If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                            If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                            If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                            If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
          					   aBrowse[oBrowse:nAt,02],;
          					   aBrowse[oBrowse:nAt,03],;
          					   aBrowse[oBrowse:nAt,04],;
          					   aBrowse[oBrowse:nAt,05],;
          					   aBrowse[oBrowse:nAt,06],;          					             					   
         	        	       aBrowse[oBrowse:nAt,07],;
         	        	       aBrowse[oBrowse:nAt,08],;
         	        	       aBrowse[oBrowse:nAt,09],;
         	        	       aBrowse[oBrowse:nAt,10]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################
// Função que abre o pedido de venda para análise ##
// #################################################
Static Function AbrePVSF()

   MsgRun("Aguarde! Abrindo Pedido de Venda selecionado ...", "pedido de Venda",{|| xAbrePVSF() })


// #################################################
// Função que abre o pedido de venda para análise ##
// #################################################
Static Function xAbrePVSF()

   DbSelectArea("SC5")
   DbSetorder(1)
   If DbSeek(Substr(cComboBx2,01,02) + aBrowse[oBrowse:nAt,02])
  	  MatA410(Nil, Nil, Nil, Nil, "A410ALtera")
   Endif

Return(.T.)

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(045),C(064) ComboBox cComboBx2 Items aFiliais Size C(054),C(010) PIXEL OF oDlg

Return(.T.)

// ####################################################
// Função que pesquisa os pedidos a serem resolvidos ##
// ####################################################
Static Function ErroWSSFSM(kTipo)

   Local cSql := ""

   If cInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial de emissão para pesquisa não informada. Verifique!")
      Return(.T.)
   Endif
      
   If cFinal == Ctod("  /  /    ")
      MsgAlert("Data final de emissão para pesquisa não informada. Verifique!")
      Return(.T.)
   Endif

   // ###############################
   // Pesquisa os pedidos de venda ##
   // ###############################
   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZPL.ZPL_FILIAL,"
   cSql += "       ZPL.ZPL_PEDI  ,"
   cSql += "	   ZPL.R_E_C_N_O_,"
   cSql += "       ZPL.ZPL_STAT  ,"
   cSql += "	   SC5.C5_EMISSAO,"
   cSql += "	   SC5.C5_CLIENTE,"
   cSql += "	   SC5.C5_LOJACLI,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "       SC5.C5_VEND1  ,"
   cSql += "       SA3.A3_NOME   ,"
   cSql += "       CAST (CAST (ZPL.ZPL_RETO AS VARBINARY (4000)) AS VARCHAR (4000)) RETORNO"

   If kTipo == 0
      cSql += "  FROM " + RetSqlName("ZPL") + " ZPL,"
      cSql += "       " + RetSqlName("SC5") + " SC5,"
   Else
      cSql += "  FROM ZPL" + Substr(cComboBx1,01,02) + "0 ZPL,"
      cSql += "       SC5" + Substr(cComboBx1,01,02) + "0 SC5,"
   Endif      

   cSql += "	   " + RetSqlName("SA1")          + "  SA1,"
   cSql += "       " + RetSqlName("SA3")          + "  SA3 "

   If kTipo == 0
      cSql += " WHERE ZPL.ZPL_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   Else
      cSql += " WHERE ZPL.ZPL_FILIAL  = '" + Substr(cComboBx2,01,02) + "'"
   Endif         

   cSql += "   AND ZPL.D_E_L_E_T_  = ''"
   cSql += "   AND SC5.C5_FILIAL   = ZPL.ZPL_FILIAL"
   cSql += "   AND SC5.C5_NUM      = ZPL.ZPL_PEDI  "
   cSql += "   AND SC5.D_E_L_E_T_  = ''            "
   cSql += "   AND SA1.A1_COD      = SC5.C5_CLIENTE"
   cSql += "   AND SA1.A1_LOJA     = SC5.C5_LOJACLI"
   cSql += "   AND SA1.D_E_L_E_T_  = ''            "
   cSql += "   AND SA3.A3_COD      = SC5.C5_VEND1  "
   cSql += "   AND SA3.D_E_L_E_T_  = ''            "
   cSql += "   AND SC5.C5_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)" + CHR(13)
   cSql += "   AND SC5.C5_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)" + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )
   
   T_PEDIDOS->( DbGoTop() )
   
   WHILE !T_PEDIDOS->( EOF() )
   
      kLegenda := IIF(Empty(Alltrim(T_PEDIDOS->ZPL_STAT)), "8", T_PEDIDOS->ZPL_STAT)

      aAdd( aBrowse, { kLegenda             ,; // 01
                       T_PEDIDOS->ZPL_PEDI  ,; // 02
                       T_PEDIDOS->R_E_C_N_O_,; // 03
                       T_PEDIDOS->C5_EMISSAO,; // 04
                       T_PEDIDOS->C5_CLIENTE,; // 05
                       T_PEDIDOS->C5_LOJACLI,; // 06
                       T_PEDIDOS->A1_NOME   ,; // 07
                       T_PEDIDOS->C5_VEND1  ,; // 08
                       T_PEDIDOS->A3_NOME   ,; // 09
                       T_PEDIDOS->RETORNO   }) // 10
                       
      T_PEDIDOS->( DbSkip() )
      
   ENDDO
                             
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "" } )
   Endif
   
   If kTipo == 0
      Return(.T.)
   Endif
         
   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||    {If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                            If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                            If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                            If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                            If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
          					   aBrowse[oBrowse:nAt,02],;
          					   aBrowse[oBrowse:nAt,03],;
          					   aBrowse[oBrowse:nAt,04],;
          					   aBrowse[oBrowse:nAt,05],;
          					   aBrowse[oBrowse:nAt,06],;          					             					   
         	        	       aBrowse[oBrowse:nAt,07],;
         	        	       aBrowse[oBrowse:nAt,08],;
         	        	       aBrowse[oBrowse:nAt,09],;
         	        	       aBrowse[oBrowse:nAt,10]}}

Return(.T.)

// #####################################################################
// Função que mostra o detalhe do erro do pedido de venda selecionado ##
// #####################################################################
Static Function VerDetalhe()

   Local cMemo1	 := ""
   Local cMemo2	 := aBrowse[oBrowse:nAt,10]
   Local oMemo1
   Local oMemo2

   Private oDlgDET

   DEFINE MSDIALOG oDlgDET TITLE "Detalhes Erro Web Service" FROM C(178),C(181) TO C(596),C(693) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgDET

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(249),C(001) PIXEL OF oDlgDET

   @ C(036),C(005) GET oMemo2 Var cMemo2 MEMO Size C(247),C(152) PIXEL OF oDlgDET

   @ C(193),C(110) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDET ACTION( oDlgDET:End() )

   ACTIVATE MSDIALOG oDlgDET CENTERED 

Return(.T.)

// #########################################################
// Função que consome web service de consulta do SimFrete ##
// #########################################################
Static Function BuscaSFWSSM()

   Local cSql     := ""
   Local cString  := Space(254)
   Local cSURL    := ""
   Local cMemo1	  := ""
   Local lTipoCon := .T.

   Local oCheckBox1
   Local oGet1
   Local oMemo1

   Private oDlgCOTAR

   DEFINE MSDIALOG oDlgCOTAR TITLE "Cotação de Frete" FROM C(178),C(181) TO C(363),C(894) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgCOTAR

   @ C(050),C(005) Say "Cole aqui a string a ser pesquisada" Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOTAR

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(350),C(001) PIXEL OF oDlgCOTAR

   @ C(037),C(005) CheckBox oCheckBox1 Var lTipoCon Prompt "Utilizar dados do Pedido de Venda para consulta do SimFrete" Size C(156),C(008) PIXEL OF oDlgCOTAR
   @ C(059),C(005) MsGet    oGet1      Var cString  Size C(347),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCOTAR

   @ C(076),C(141) Button "Consultar" Size C(037),C(012) PIXEL OF oDlgCOTAR ACTION( kBuscaSFWSSM(lTipoCon, cString) )
   @ C(076),C(179) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgCOTAR ACTION( oDlgCOTAR:End() )

   ACTIVATE MSDIALOG oDlgCOTAR CENTERED 

Return(.T.)

// #########################################################
// Função que consome web service de consulta do SimFrete ##
// #########################################################
Static Function kBuscaSFWSSM(lTipoCon, cString)

   MsgRun("Aguarde! Pesquisando cotação de frete ...", "Cotação de Frete",{|| kkBuscaSFWSSM(lTipoCon, cString) })

Return(.T.)

// #########################################################
// Função que consome web service de consulta do SimFrete ##
// #########################################################
Static Function kkBuscaSFWSSM(lTipoCon, cString)

   Local cSql        := ""
   Local xString     := ""    
   Local nTentativas := 0
   Local cSTIM       := 15000000
   Local lChumba     := .F.
   Local cSql        := ""
   Local cMemo10     := ""
   Local oMemo10

   Private cOrigem    := Space(25)
   Private cDestino   := Space(25)
   Private cDadosPV   := ""
   Private oGet1
   Private oGet2
   Private oMemo20

   Private oDlgCOTACAO

   Private aLista := {}
   Private oLista

   If lTipoCon == .F.
      If Empty(Alltrim(cString))
         MsgAlert("String a ser pesquisada não informada. Verifique!")
         Return(.T.)
      Endif
   Endif

   // ##############################################################
   // Pesquisa dados do pedido de venda para pesquisar o Simfrete ##
   // ##############################################################
   If lTipoCon == .T.

      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
	  cSql += "       SC6.C6_PRODUTO,"
	  cSql += "       SC6.C6_QTDVEN ,"
	  cSql += "       SC6.C6_VALOR  ,"
      cSql += "       SC6.C6_CLI    ,"
      cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SA1.A1_COD    ,"
      cSql += "       SA1.A1_LOJA   ,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       SA1.A1_END    ,"
      cSql += "       SA1.A1_BAIRRO ,"
      cSql += "       SA1.A1_MUN    ,"
      cSql += "       SA1.A1_EST    ,"
	  cSql += "       SA1.A1_CEP     "
      cSql += "  FROM SC6" + Substr(cComboBx2,01,02) + "0 SC6, "
      cSql += "       " + RetSqlName("SA1") + " SA1 "
      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(aBrowse[oBrowse:nAt,02]) + "'"
      cSql += "   AND SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SA1.A1_COD     = SC6.C6_CLI "
      cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA"
      cSql += "   AND SA1.D_E_L_E_T_ = ''         "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      T_PRODUTOS->( DbGoTop() )
      
      kProdutos   := ""
      kQuantidade := ""
      kValorTotal := 0 
      kCEPDestino := T_PRODUTOS->A1_CEP

      // #################################################
      // Pesquisa dados do pedido de venda para display ##
      // #################################################                                                       
      cDadosPV := cDadosPV + "FILIAL..: " + Alltrim(Substr(cComboBx2,01,02))               + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "Nº P.V..: " + aBrowse[oBrowse:nAt,02]                        + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "CLIENTE.: " + T_PRODUTOS->C6_CLI + "." + T_PRODUTOS->C6_LOJA + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "NOME....: " + Alltrim(T_PRODUTOS->A1_NOME)                   + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "ENDEREÇO: " + Alltrim(T_PRODUTOS->A1_END)                    + " - " + ;
                                            Alltrim(T_PRODUTOS->A1_BAIRRO)                 + " - " + ;
                                            Alltrim(T_PRODUTOS->A1_MUN)                    + "/"   + ;   
                                            Alltrim(T_PRODUTOS->A1_EST)
      Do Case
         Case Substr(cComboBx1,01,02) == "01"
              Do Case
                 Case Substr(cComboBx2,01,02) == "01"
                      cOrigem := "PORTO ALEGRE / RS"
                 Case Substr(cComboBx2,01,02) == "02"
                      cOrigem := "CAXIAS DO SUL / RS"
                 Case Substr(cComboBx2,01,02) == "03"
                      cOrigem := "PELOTAS / RS"
                 Case Substr(cComboBx2,01,02) == "04"
                      cOrigem := "PORTO ALEGRE / RS"
                 Case Substr(cComboBx2,01,02) == "05"
                      cOrigem := "SAO PAULO / SP"
                 Case Substr(cComboBx2,01,02) == "06"
                      cOrigem := "CARIACICA / ES"
              EndCase
         Case Substr(cComboBx1,01,02) == "02"
              cOrigem := "CURITIBA / PR"
         Case Substr(cComboBx1,01,02) == "03"
              cOrigem := "PORTO ALEGRE / PR"
         Case Substr(cComboBx1,01,02) == "04"
              cOrigem := "PELOTAS / RS"
      EndCase                         

      cDestino := Alltrim(T_PRODUTOS->A1_MUN) + "/" + Alltrim(T_PRODUTOS->A1_EST)

      WHILE !T_PRODUTOS->( EOF() )
         kProdutos   := kProdutos   + Alltrim(T_PRODUTOS->C6_PRODUTO)     + "|"
         kQuantidade := kQuantidade + Alltrim(Str(T_PRODUTOS->C6_QTDVEN)) + "|"
         kValorTotal := kValorTotal + T_PRODUTOS->C6_VALOR
         T_PRODUTOS->( DbSkip() )
      ENDDO   

      // ################################################################################################
      // Elimina o último | da string dos códigos das strings de consumo do web service do SimFrete SM ##
      // ################################################################################################
      kProdutos   := Substr(kProdutos  , 01, Len(Alltrim(kProdutos)) - 1)
      kQuantidade := Substr(kQuantidade, 01, Len(Alltrim(kQuantidade)) - 1)
      kValorTotal := Alltrim(Str(kValorTotal))
      kEmpresa    := Substr(cComboBx1,01,02)
      kFilial     := Substr(cComboBx2,01,02)
      
   Else
   
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
	  cSql += "       SC6.C6_PRODUTO,"
	  cSql += "       SC6.C6_QTDVEN ,"
	  cSql += "       SC6.C6_VALOR  ,"
      cSql += "       SC6.C6_CLI    ,"
      cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SA1.A1_COD    ,"
      cSql += "       SA1.A1_LOJA   ,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       SA1.A1_END    ,"
      cSql += "       SA1.A1_BAIRRO ,"
      cSql += "       SA1.A1_MUN    ,"
      cSql += "       SA1.A1_EST    ,"
	  cSql += "       SA1.A1_CEP     "
      cSql += "  FROM SC6" + Substr(cComboBx2,01,02) + "0 SC6, "
      cSql += "       " + RetSqlName("SA1") + " SA1 "
      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(aBrowse[oBrowse:nAt,02]) + "'"
      cSql += "   AND SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SA1.A1_COD     = SC6.C6_CLI "
      cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA"
      cSql += "   AND SA1.D_E_L_E_T_ = ''         "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      T_PRODUTOS->( DbGoTop() )
      
      kCEPDestino := T_PRODUTOS->A1_CEP

      // #################################################
      // Pesquisa dados do pedido de venda para display ##
      // #################################################                                                       
      cDadosPV := cDadosPV + "FILIAL..: " + Alltrim(Substr(cComboBx2,01,02))               + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "Nº P.V..: " + aBrowse[oBrowse:nAt,02]                        + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "CLIENTE.: " + T_PRODUTOS->C6_CLI + "." + T_PRODUTOS->C6_LOJA + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "NOME....: " + Alltrim(T_PRODUTOS->A1_NOME)                   + Chr(13) + chr(10)
      cDadosPV := cDadosPV + "ENDEREÇO: " + Alltrim(T_PRODUTOS->A1_END)                    + " - " + ;
                                            Alltrim(T_PRODUTOS->A1_BAIRRO)                 + " - " + ;
                                            Alltrim(T_PRODUTOS->A1_MUN)                    + "/"   + ;   
                                            Alltrim(T_PRODUTOS->A1_EST)
      Do Case
         Case Substr(cComboBx1,01,02) == "01"
              Do Case
                 Case Substr(cComboBx2,01,02) == "01"
                      cOrigem := "PORTO ALEGRE / RS"
                 Case Substr(cComboBx2,01,02) == "02"
                      cOrigem := "CAXIAS DO SUL / RS"
                 Case Substr(cComboBx2,01,02) == "03"
                      cOrigem := "PELOTAS / RS"
                 Case Substr(cComboBx2,01,02) == "04"
                      cOrigem := "PORTO ALEGRE / RS"
                 Case Substr(cComboBx2,01,02) == "05"
                      cOrigem := "SAO PAULO / SP"
                 Case Substr(cComboBx2,01,02) == "06"
                      cOrigem := "CARIACICA / ES"
              EndCase
         Case Substr(cComboBx1,01,02) == "02"
              cOrigem := "CURITIBA / PR"
         Case Substr(cComboBx1,01,02) == "03"
              cOrigem := "PORTO ALEGRE / PR"
         Case Substr(cComboBx1,01,02) == "04"
              cOrigem := "PELOTAS / RS"
      EndCase                         

      cDestino := Alltrim(T_PRODUTOS->A1_MUN) + "/" + Alltrim(T_PRODUTOS->A1_EST)
   
   Endif

   cSURL   := 'http://sm.automatech.com.br/api/frete/consulta/v1'
    
   // ########################################### 
   // Monta String com os códigos dos produtos ##
   // ###########################################  
   If lTipoCon == .T.

      xString := ''
      xString := ' {' 
      xString += ' "empresa":'     + '"' + Substr(cComboBx1,01,02) + '"' + ', '
      xString += ' "filial":'      + '"' + Substr(cComboBx2,01,02) + '"' + ', '
      xString += ' "cep":'         + '"' + kCEPDestino             + '"' + ', '
      xString += ' "produtos":'    + '"' + kProdutos               + '"' + ', '
      xString += ' "quantidades":' + '"' + kQuantidade             + '"' + ', '
      xString += ' "total":'       + '"' + kValorTotal             + '"'
      xString += ' }'
      cString := xString

   Else
     
      cString := Lower(cString)
   
   Endif   

   // ########################################################################################
   // Elimina o arquivo de enviodemo.txt e retornodemo.txt antes de enviar nova solicitação ##
   // ########################################################################################
   If File("C:\SIMFRETE\ENVIOSM.TXT")
      fErase("C:\SIMFRETE\ENVIOSM.TXT")
   Endif

   If File("C:\SIMFRETE\RETORNOSM.TXT")
      fErase("C:\SIMFRETE\RETORNOSM.TXT")
   Endif   

   // ######################################################
   // Cria o arquivo de envio da solicitação ao FreshDesk ##
   // ######################################################
   nHdl := fCreate("C:\SIMFRETE\ENVIOSM.TXT")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   // ########################################################
   // Consome o Web Service do SM para consulta do SimFrete ##
   // ########################################################
   WaitRun('AtechHttpPost2.exe' + ' ' + Alltrim(cSURL) + ' ' + 'C:\SIMFRETE\RETORNOSM.TXT' + ' ' + 'C:\SIMFRETE\ENVIOSM.TXT' + ' ' + 'application/json' + ' ' + "--ignore_remote_cert")

   // ###########################################################
   // Verifica se o arquivo de retorno foi criado no diretório ##
   // ###########################################################
   WHILE nTentativas < cSTIM
      If File("C:\SIMFRETE\RETORNOSM.TXT")
         lExiste := .T.
         Exit
      Endif
      nTentativas := nTentativas + 1
   Enddo

   If lExiste == .F.
      Return(.T.)
   Endif
                                                  
   // ##########################################
   // Trata o retorno do envio da solicitação ##
   // ##########################################

   // #################################################################################
   // Abre o arquivo de retorno para capturar o código do ticket gerado no freshdesk ##
   // #################################################################################
   nHandle := FOPEN("C:\SIMFRETE\RETORNOSM.TXT", FO_READWRITE + FO_SHARED)
      
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de retorno da consulta SimFrete do SM em C:\SIMFRETE\RETORNOSM.TXT")
      Return .T.
   Endif

   // ################################
   // Lê o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // Lê todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   FCLOSE(nHandle)

   If U_P_OCCURS(xBuffer, "(422)", 1) <> 0
      MsgAlert("Erro no comando. Verifique String enviada.")
      Return(.T.)
   Endif
         
   // ##########################
   // Alimenta o array aLista ##
   // ##########################
   aLista := {}

   For nContar = 1 to U_P_OCCURS(xBuffer, "}", 1)

       cSepara := U_P_CORTA(xBuffer, "}", nContar)                                                        
       
       If nContar == 1
          cSepara := StrTran(cSepara, ",", "|") + "|"
          kValor := U_P_CORTA(U_P_CORTA(cSepara, "|", 1) + ":", ":", 4)          
          kPrazo := U_P_CORTA(U_P_CORTA(cSepara, "|", 2) + ":", ":", 2)          
          kBarato := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 3) + ":", ":", 2) == "true", "SIM", "NÃO")
          kRapido := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 4) + ":", ":", 2) == "true", "SIM", "NÃO")  
          kNomeT  := StrTran(U_P_CORTA(U_P_CORTA(CsEPARA, "|", 5) + ":", ":", 2), '"', "")        
          kCNPJ   := StrTran(U_P_CORTA(U_P_CORTA(cSepara, "|", 6) + ":", ":", 2), '"', "")                                                                                              
       Else
          cSepara := StrTran(cSepara, ",", "|")
          kValor  := U_P_CORTA(U_P_CORTA(cSepara, "|", 2) + ":", ":", 3)   
          kPrazo  := U_P_CORTA(U_P_CORTA(cSepara,"|", 3) + ":", ":",2)    
          kBarato := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 4) + ":", ":", 2) == "true", "SIM", "NÃO")   
          kRapido := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 5) + ":", ":", 2) == "true", "SIM", "NÃO")          
          kNomeT  := StrTran(U_P_CORTA(U_P_CORTA(CsEPARA, "|", 6) + ":", ":", 2), '"', "")  
          kCNPJ   := StrTran(U_P_CORTA(U_P_CORTA(cSepara, "|", 7) + ":", ":", 2), '"', "")                                                                                                                        
       Endif 
                                        
       If VAL(kValor) == 0
          Loop
       Endif   
       
       // ######################################
       // Pesquisa a transportadora pelo cnpj ##
       // ######################################
       If Select("T_TRANSPORTADORA") > 0
          T_TRANSPORTADORA->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A4_COD ,"
       cSql += "       A4_NOME "
       cSql += "  FROM " + RetSqlName("SA4")
       cSql += " WHERE SUBSTRING(A4_CGC,01,08) = '" + Substr(kCNPJ,01,08) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTADORA", .T., .T. )

       If T_TRANSPORTADORA->( EOF() )
          Loop
       Else
          cCodTransp := T_TRANSPORTADORA->A4_COD
          cNomTransp := T_TRANSPORTADORA->A4_NOME
       Endif   
       
       // ##################################################################
       // Alimenta o array aLista para visualização dos fretes retornados ##
       // ##################################################################
       aAdd( aLista, { Alltrim(Str(nContar)),; // 01 - Posição da Cotação
                       Val(kValor)          ,; // 02 - Valor do Frete
                       kPrazo               ,; // 03 - Prazo dias
                       kBarato              ,; // 04 - Menor Valor
                       kRapido              ,; // 05 - Menor Prazo
                       cCodTransp           ,; // 06 - Código Transportadora
                       cNomTransp           }) // 07 - Nome da Transportadora

   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { "", "", "", "", "", "", "" } )
   Endif   

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlgCOTACAO TITLE "Cotação de Frete" FROM C(178),C(181) TO C(601),C(942) PIXEL Style DS_MODALFRAME

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(030) PIXEL NOBORDER OF oDlgCOTACAO

   @ C(036),C(002) GET oMemo10 Var cMemo10 MEMO Size C(374),C(001) PIXEL OF oDlgCOTACAO

   @ C(041),C(005) Say "Dados Pedido de Venda"                  Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOTACAO
   @ C(092),C(005) Say "Origem"                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOTACAO
   @ C(092),C(196) Say "Destino"                                Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOTACAO
   @ C(114),C(005) Say "Selecione a melhor opção de transporte" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOTACAO

   @ C(050),C(005) GET      oMemo20    Var cDadosPV  MEMO                    Size C(371),C(038)                              PIXEL OF oDlgCOTACAO When lChumba
   @ C(101),C(005) MsGet    oGet1      Var cOrigem                           Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCOTACAO When lChumba
   @ C(101),C(196) MsGet    oGet2      Var cDestino                          Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCOTACAO When lChumba

   @ C(196),C(339) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCOTACAO ACTION( oDlgCOTACAO:End() )

   @ 155,005 LISTBOX oLista FIELDS HEADER "Posição", "Valor Frete", "Prazo Dias", "Menor Valor", "Menor Prazo", "Código", "Transportadora" PIXEL SIZE 474,090 OF oDlgCOTACAO ;
             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {aLista[oLista:nAt,01],;
          					aLista[oLista:nAt,02],;
          					aLista[oLista:nAt,03],;
          					aLista[oLista:nAt,04],;
          					aLista[oLista:nAt,05],;
          					aLista[oLista:nAt,06],;          					    
          					aLista[oLista:nAt,07]}}

   oDlgCOTACAO:lEscClose := .F.

   ACTIVATE MSDIALOG oDlgCOTACAO CENTERED 

Return(.T.)

// #####################################################
// Função que soluciona o problema do pedido de venda ##
// #####################################################
Static Function ResolvePV()

   DbSelectArea("ZPL")
   DbSetorder(1)
   If DbSeek(Substr(cComboBx2,01,02) + aBrowse[oBrowse:nAt,02] + aBrowse[oBrowse:nAt,03])
	  RecLock("SC6",.F.)
	  ZPL_ZPL_STAT := "2"
	  MsUnlock()
   Endif

   ErroWSSFSM(1)   	  
   
Return(.T.)