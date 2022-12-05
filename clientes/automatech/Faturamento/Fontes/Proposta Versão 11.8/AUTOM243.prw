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

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM243.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/07/2014                                                          *
// Objetivo..: Novo programa de inclusão de Oportunidade e Proposta Comercial.     *
//**********************************************************************************

User Function AUTOM243()

   Local lvendedor      := .F.
   Local lChumba        := .F.
   Local lAgrid         := .F.
   Local lAbreGrid      := .F.
   Local lFechGrid      := .F.
   Local cWhere         := ""
   Local nContar        := 0
   
// Private ___Filial    := cFilAnt

   Private AAA_Abertura := 1

   Private lFechaCli    := .F.
   Private lAbrBotao    := .F.
   Private aVendedores  := {""}
   Private aStatus	    := {"0-Todos", "1-Aberto", "2-Perdido", "3-Suspenso", "9-Encerrado"}
   Private aFiliais	    := {}
   Private aOrdenacao   := {"01 - Oportunidade", "02 - Proposta Comercial", "03 - Cliente", "04 - Descrição Oportunidade", "05 - Data Inclusão"}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private __cBkpAnt  := cFilAnt //Armazena a Filial - Michel aoki 23/09/2014
   
   Private dInicial	     := Ctod("01/01/" + Strzero(Year(Date()),4))
   Private dFinal   	 := Ctod("31/12/" + Strzero(Year(Date()),4))
   Private cCliente      := Space(100)
   Private xDolar        := 0
   Private xOportunidade := Space(06)
   Private xProposta 	 := Space(06)
   Private xPedido   	 := Space(06)
   Private cPedido 	     := Space(06)
   Private cNFiscal	     := Space(10)
   Private cSerie	     := Space(03)
   Private cLembrete     := ""

   Private cMemo1	 := ""
   Private cMemo2	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10

   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private aBrowsex   := {}
   Private oBrowsex

   Private aLista     := {}
   Private oList

   Private nMeter1	  := 0
   Private oMeter1

   Private aTipoC     := {}

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

   // Array para encerramento da oportunidade
   Private aHeader5     := {}
   Private aCols5       := {}
   Private oGetDad5
   Private cNumProposta := ""

   Private lConcidera   := .F.
   Private oCheckBox1

   Private oDlg

   // Verifica se existe a pasta ATECHPORTAL

   If !ExistDir( "C:\ATECHPORTAL" )

      nRet := MakeDir( "C:\ATECHPORTAL" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta ATECHPORTAL. Entre em contato com a área de projetos. Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Endif
   
   Endif

   // Carrega o array aTipoC com os códigos dos tipo de movimentos parametrizados
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TPOA, ZZ4_TCUR, ZZ4_TATE  "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção! Não existe parametrizador para esta Empresa/Filial. Entre em contato com o Administrador do Sistema reportando esta mensagem.")
      Return(.T.)
   Endif
   
   // Carrega o array aTipoC com os dados parametrizados para a Empresa/Filial logados
   Do Case
      // Carrega os tipo de contrato para o Grupo de Empresa 01
      Case cEmpAnt == "01"
           For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TPOA, "|", 1)
               aAdd( aTipoC, { "01", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TPOA, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TPOA, "|", nContar), "#", 2) } )
           Next nContar

      // Carrega os tipo de contrato para o Grupo de Empresa 02
      Case cEmpAnt == "02"
           For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TCUR, "|", 1)
               aAdd( aTipoC, { "02", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TCUR, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TCUR, "|", nContar), "#", 2) } )
           Next nContar

      // Carrega os tipo de contrato para o Grupo de Empresa 03
      Case cEmpAnt == "03"
           For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TATE, "|", 1)
               aAdd( aTipoC, { "03", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TATE, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TATE, "|", nContar), "#", 2) } )
           Next nContar
              
   EndCase
   
   If Len(aTipoC) == 0
      MsgAlert("Atenção! Entre em contato com o administrador do sistema informando que o parâmetro (Tipo de Contrato para Grupo de Empresa 01) não está parametrizado.")
      Return(.T.)
   Endif

   // Inicializa a data inicial e final de pesquisa com as data do mês vigente
   dInicial	:= Ctod("01/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
   dFinal   := Ctod(Strzero(Day(Date()),2) + "/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))

   // Carrega o Array aFiliais conforme a Empresa logada
   do Case
      Case cEmpAnt == "01"
           aFiliais := {"01 - POA", "02 - CXS", "03 - PEL", "04 - SUP"}
      Case cEmpAnt == "02"
           aFiliais := {"01 - TI"}      
      Case cEmpAnt == "03"
           aFiliais := {"01 - ATECH"}      
   EndCase

   // Inicializa o Combo dos Status
   cComboBx2 := "0-Todos"

   // Inicializa o Combo de Filiais
   cComboBx3 := "01 - POA"

   // Inicializa o Combo da Ordenação
   cComboBx4 := "01 - Oportunidade"

   // Verifica o tipo de usuário.
   If Select("T_TIPOVENDE") > 0
      T_TIPOVENDE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A3_COD   ,"
   cSql += "       A3_NOME  ,"
   cSql += "       A3_CODUSR,"
   cSql += "       A3_TSTAT ,"
   cSql += "       A3_OUTR   "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A3_CODUSR  = '" + Alltrim(__cUserID) + "'"
   cSql += " ORDER BY A3_NOME     "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPOVENDE", .T., .T. )
   
   If T_TIPOVENDE->( EOF() )
      MsgAlert("Usuário não configurado como Vendedor. Entre em contato com o seu supervisor de área.")
      Return(.T.)
   Endif

   // Carrega o combobox de vendedores
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

   If T_TIPOVENDE->A3_TSTAT == '1'

      If Empty(Alltrim(T_TIPOVENDE->A3_OUTR))
         cSql += " AND A.A3_CODUSR = '" + Alltrim(__cUserID) + "'"
      Else
         cWhere := " IN ('" + Alltrim(__cUserID) + "',"
         For nContar = 1 to U_P_OCCURS(T_TIPOVENDE->A3_OUTR, "|", 1)
             cWhere := cWhere + "'" + U_P_CORTA(T_TIPOVENDE->A3_OUTR, "|", nContar) + "',"
         Next nContar
         cWhere := Substr(cWhere,01,Len(Alltrim(cWhere)) - 1) + "')"
         cSql += " AND A.A3_CODUSR " + cWhere 
      Endif

   Endif

   cSql += " ORDER BY A.A3_NOME"     

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDORES", .T., .T. )

   aVendedores := {}

   If T_TIPOVENDE->A3_TSTAT = '2' .OR. Alltrim(__cUserID) == "000000"
      aAdd( aVendedores, "000000 - Selecione um Vendedor" )
      aAdd( aVendedores, "000087 - AutomatechShop" )
   Endif   

   T_VENDEDORES->( DbGoTop() )
   WHILE !T_VENDEDORES->( EOF() )
      If Empty(Alltrim(T_VENDEDORES->A3_NOME))
         T_VENDEDORES->( DbSkip() )         
         Loop
      Endif   

      If T_TIPOVENDE->A3_TSTAT = '1'
         If Empty(Alltrim(T_TIPOVENDE->A3_OUTR))
            If T_VENDEDORES->A3_CODUSR == __CuserID
               aAdd( aVendedores, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )
               Exit
            endif
         Else
            aAdd( aVendedores, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )           
         Endif   
      Else
         aAdd( aVendedores, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )            
      Endif
      T_VENDEDORES->( DbSkip() )
   ENDDO

   xxx_Vendedor := Substr(aVendedores[01],01,06)
   
   cLembrete := ""

   If T_TIPOVENDE->A3_TSTAT = '2'
      cComboBx1 := "000000 - Selecione um Vendedor"
      cComboBx1 := "000087 - AutomatechShop"
      lVendedor := .T.
   Else
      cComboBx1 := aVendedores[1]

      If Select("T_LEMBRETE") > 0
         T_LEMBRETE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A3_LEMB)) AS LEMBRETE "
      cSql += "  FROM " + RetSqlName("SA3") 
      cSql += " WHERE A3_COD     = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LEMBRETE", .T., .T. )

      If T_LEMBRETE->( EOF() )
         cLembrete := ""
      Else
         cLembrete := T_LEMBRETE->LEMBRETE
      Endif

   Endif

   // Prepara a variável AAA_Abertura. Esta variável controla o tipo de visualização do Grid
   DbSelectArea("ZZI")
   DbSetOrder(1)
   If DbSeek(Alltrim(cUserName))
      AAA_Abertura := ZZI_APRO
   Else
      AAA_Abertura := 1
   Endif

   If AAA_Abertura == 1
      lAbreGrid := .F.
      lFechGrid := .T.
   Else
      lAbreGrid := .T.
      lFechGrid := .F.
   Endif

   // Envia para a função que carrega o array aBrowse
   If __CuserID <> "000000"
      ImpaBrowse(1, "")
   Endif

   // Pesquisa a faxa do dolar do dia atual
   xDolar := Posicione("SM2", 1, DATE(), "M2_MOEDA2")

   // Carrega o array aLista com, os filtros do vendedor selecionado
   If Select("T_FILTROS") > 0
      T_FILTROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT2_CODI,"
   cSql += "       ZT2_NOME "
   cSql += "  FROM ZT2010"
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZT2_VEND   = '" + Alltrim(xxx_Vendedor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FILTROS", .T., .T. )

   T_FILTROS->( DbGoTop() )
   
   WHILE !T_FILTROS->( EOF() )
      aAdd( aLista, { T_FILTROS->ZT2_CODI + " - " + T_FILTROS->ZT2_NOME } )
      T_FILTROS->( DbSkip() )
   ENDDO

   If Len(aLista) == 0
      aAdd( aLista, { "              " } )
   Endif   

   // Desenha a Janela do programa
   DEFINE MSDIALOG oDlg TITLE "Proposta Comercial" FROM C(183),C(002) TO C(620),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"      Size C(134),C(026) PIXEL NOBORDER OF oDlg

   @ C(010),C(200) Jpeg FILE "dolar.png"           Size C(134),C(028) PIXEL NOBORDER OF oDlg
   @ C(005),C(280) Jpeg FILE "carrinho.png"        Size C(134),C(028) PIXEL NOBORDER OF oDlg
   @ C(004),C(352) Jpeg FILE "incclie.bmp"         Size C(134),C(028) PIXEL NOBORDER OF oDlg
   @ C(009),C(420) Jpeg FILE "shop.png"            Size C(134),C(028) PIXEL NOBORDER OF oDlg   

   @ C(035),C(005) Say "Filial"                    Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(044) Say "Dta Inicial"               Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(084) Say "Dta Final"                 Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(123) Say "Cliente"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(031),C(352) Say "FILTROS DE PESQUISA"       Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(013),C(311) Button "Todas Vendas"           Size C(037),C(009) PIXEL OF oDlg ACTION( TodasAsVendas( aBrowsex[oBrowsex:nAt,08], aBrowsex[oBrowsex:nAt,09], aBrowsex[oBrowsex:nAt,10] ) )
   @ C(013),C(375) Button "Inc.Cliente"            Size C(040),C(008) PIXEL OF oDlg ACTION( IncNovCli() )
   
   
   //ACTION( U_AUTOM246() )   && ACTION( ShellExecute("open","www.sintegra.gov.br","","",5) )
   
   
///   @ C(013),C(455) Button "Automatech Shop"        Size C(040),C(009) PIXEL OF oDlg ACTION( ShellExecute("open","www.automatechshop.com.br","","",5) )

   @ C(013),C(455) Button "Atech Portal"        Size C(040),C(009) PIXEL OF oDlg ACTION( ChamaAtech() )


   @ C(055),C(005) Say "Oportunidade"              Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(044) Say "Prop.Comercial"            Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(084) Say "Pedido Venda"              Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(123) Say "Vendedor"                  Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(203) Say "Legenda"                   Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(238) Say "Ordenação Visualização"    Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(082),C(005) Say "Oportunidades / Propostas Comerciais" Size C(143),C(008) COLOR CLR_BLACK PIXEL OF oDlg
                                                    
   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(305),C(001) PIXEL OF oDlg
   @ C(077),C(002) GET oMemo2 Var cMemo2 MEMO Size C(305),C(001) PIXEL OF oDlg

   @ C(198),C(005) METER    oMeter1   VAR   nMeter1       Size C(493),C(008) NOPERCENTAGE                 PIXEL OF oDlg
   
   @ C(044),C(005) ComboBox cComboBx3 Items aFiliais      Size C(033),C(010)                              PIXEL OF oDlg
   @ C(044),C(044) MsGet    oGet1     Var   dInicial      Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(084) MsGet    oGet2     Var   dFinal        Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(044),C(123) MsGet    oGet3     Var   cCliente      Size C(184),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(032),C(311) Button "Pesq. Cliente"                 Size C(037),C(009)                              PIXEL OF oDlg ACTION( pRapidaCli(1) )
   @ C(043),C(311) Button "Limpa Cliente"                 Size C(037),C(009)                              PIXEL OF oDlg ACTION( pRapidaLmp() )

   @ C(012),C(238) MsGet    oGet9      Var   xDolar         Size C(033),C(009) COLOR CLR_BLACK Picture "@E 99.9999" PIXEL OF oDlg When lChumba
   @ C(035),C(238) CheckBox oCheckBox1 Var   lConcidera     Prompt "Considerar Loja do Cliente" Size C(073),C(008) PIXEL OF oDlg
   @ C(064),C(123) ComboBox cComboBx1  Items aVendedores    Size C(077),C(010)                              PIXEL OF oDlg ON CHANGE CARGALEMBRETE(cComboBx1)  && When lVendedor
   @ C(064),C(005) MsGet    oGet4      Var   xOportunidade  Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(064),C(044) MsGet    oGet5      Var   xProposta      Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(064),C(084) MsGet    oGet10     Var   xPedido        Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(064),C(203) ComboBox cComboBx2  Items aStatus        Size C(030),C(010)                              PIXEL OF oDlg
   @ C(064),C(238) ComboBox cComboBx4  Items aOrdenacao     Size C(070),C(010)                              PIXEL OF oDlg

   @ C(090),C(352) GET      oMemo3     Var   cLembrete MEMO Size C(144),C(092)                              PIXEL OF oDlg && When lAbrBotao 

   @ C(054),C(311) Button "Atualizar"            Size C(037),C(009)                                       PIXEL OF oDlg ACTION( ImpaBrowse(2, "") )

   @ C(065),C(311) Button "H O J E"              Size C(037),C(009)                                       PIXEL OF oDlg ACTION( ImpaBrowse(3, "") )
   @ C(076),C(311) Button "M Ê S"                Size C(018),C(009)                                       PIXEL OF oDlg ACTION( ImpaBrowse(5, "") )
   @ C(076),C(331) Button "A N O"                Size C(018),C(009)                                       PIXEL OF oDlg ACTION( ImpaBrowse(6, "") )   

   @ C(079),C(084) Button "<<"                   Size C(018),C(009)                                       PIXEL OF oDlg ACTION( expandetel(1)  ) When lAbreGrid
   @ C(079),C(104) Button ">>"                   Size C(018),C(009)                                       PIXEL OF oDlg ACTION( expandetel(2)  ) When lFechGrid

   @ C(079),C(238) Button "Observações PC"       Size C(048),C(009)                                       PIXEL OF oDlg ACTION( U_AUTOMR83( aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,04] ) )

   @ C(076),C(352) Button "Executar Filtro"      Size C(076),C(009) PIXEL OF oDlg ACTION( ImpaBrowse(4, aLista[oList:nAt,01]) )
   @ C(076),C(429) Button "Editar Filtros"       Size C(067),C(009) PIXEL OF oDlg ACTION( AbreFiltro() )

   @ C(183),C(352) Button "Editar Lembrete"      Size C(048),C(012) PIXEL OF oDlg When !lAbrBotao ACTION( AbreLembrete(1) )
   @ C(183),C(401) Button "Salvar Lembrete"      Size C(048),C(012) PIXEL OF oDlg When  lAbrBotao ACTION( AbreLembrete(2) )
   @ C(183),C(450) Button "ZOOM"                 Size C(045),C(012) PIXEL OF oDlg When !lAbrBotao ACTION( AbreLembrete(3) )

   @ C(204),C(005) Button "Incluir"              Size C(032),C(012) PIXEL OF oDlg ACTION( ManuOportu( "I", Space(06), Space(02), "", "" ) )
   @ C(204),C(038) Button "Alterar"              Size C(032),C(012) PIXEL OF oDlg ACTION( ManuOportu( "A", aBrowsex[oBrowsex:nAt,04], aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,01], aBrowsex[oBrowsex:nAt,05] ) )
   @ C(204),C(070) Button "Visualizar"           Size C(032),C(012) PIXEL OF oDlg ACTION( ManuOportu( "V", aBrowsex[oBrowsex:nAt,04], aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,01], aBrowsex[oBrowsex:nAt,05] ) )

   @ C(204),C(110) Button "Call Center"          Size C(030),C(012) PIXEL OF oDlg ACTION( U_AUTOM245() )
   @ C(204),C(142) Button "Duplicar"             Size C(030),C(012) PIXEL OF oDlg ACTION( DuplicaOport( aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,04], aBrowsex[oBrowsex:nAt,08], aBrowsex[oBrowsex:nAt,09], aBrowsex[oBrowsex:nAt,10], aBrowsex[oBrowsex:nAt,05] ) ) 
   @ C(204),C(174) Button "Pesq.Preços"          Size C(030),C(012) PIXEL OF oDlg ACTION( U_AUTOM184() )     && ACTION( EnvMailCli( Substr(cComboBx1,10) ) )

   @ C(204),C(206) Button "Impressão"            Size C(027),C(012) PIXEL OF oDlg ACTION( ImpProCom(aBrowsex[oBrowsex:nAt,04], aBrowsex[oBrowsex:nAt,05], aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,18] ) )

   @ C(204),C(238) Button "Expedições"           Size C(027),C(012) PIXEL OF oDlg ACTION( U_AUTOM206() )

   @ C(204),C(268) Button "X M L"                Size C(027),C(012) PIXEL OF oDlg ACTION( TIPO_DE_XML() )      && ACTION( XSTSDANFE() )   && ACTION( U_AUTOM163() )
   @ C(204),C(298) Button "DANFE"                Size C(027),C(012) PIXEL OF oDlg ACTION( TIPO_DE_DANFE() )      && ACTION( XSTSDANFE() )   && ACTION( U_AUTOM163() )

   @ C(204),C(328) Button "Boleto"               Size C(027),C(012) PIXEL OF oDlg ACTION( EBOLETOS( aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,06] ) )
   @ C(204),C(357) Button "Tracker"              Size C(027),C(012) PIXEL OF oDlg ACTION( U_AUTOMR80( aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,04], 1 ) )
   @ C(204),C(386) Button "Ped/NFiscal"          Size C(027),C(012) PIXEL OF oDlg ACTION( PedidoNF( aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,04], aBrowsex[oBrowsex:nAt,05], aBrowsex[oBrowsex:nAt,10], aBrowsex[oBrowsex:nAt,08], aBrowsex[oBrowsex:nAt,09] ) )
   @ C(204),C(415) Button "Acomp. Pedidos"       Size C(040),C(012) PIXEL OF oDlg ACTION( ACOMPAPV( aBrowsex[oBrowsex:nAt,03], aBrowsex[oBrowsex:nAt,06], Substr(cCombobx1,01,06), aBrowsex[oBrowsex:nAt,08], aBrowsex[oBrowsex:nAt,09] ) )

   @ C(204),C(461) Button "Voltar"               Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Régua de prograssão de pesquisa
   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   // ListBox com os filtros do vendedor selecionado - Tamanho Original - (185,077)
   @ 048,450 LISTBOX oList FIELDS HEADER "Descrição dos Filtros" PIXEL SIZE 185,047 OF oDlg ON dblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aLista )
   oList:bLine := {||     {aLista[oList:nAt,01]}}

   // Inicializa o browse 
   __Largura := IIF(AAA_Abertura == 1, 440, 630)

   oBrowsex := TCBrowse():New( 115 , 005, __Largura, 135,,{'Lg'                 ,; // 01
                                                           'Status'             ,; // 02
                                                           'Filial'             ,; // 03
                                                           'Oportunidade'       ,; // 04
                                                           'Prop.Comercial'     ,; // 05
                                                           'Pedido(s) Venda(s)' ,; // 06
                                                           'Descrição'          ,; // 07
                                                           'Cliente'            ,; // 08
                                                           'Loja'               ,; // 09
                                                           'Descrição Clientes' ,; // 10
                                                           'Dt.Inclusão'        ,; // 11
                                                           'Dt.Inicio'          ,; // 12
                                                           'Dt. Término'        ,; // 13
                                                           'Vendedor 1'         ,; // 14
                                                           'Nome Vendedor 1'    ,; // 15
                                                           'Vendedor 2'         ,; // 16
                                                           'Nome Vendedor 2'    ,; // 17
                                                           'Revisão'          } ,; // 18
                                                           {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowsex:SetArray(aBrowsex) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowsex) == 0
      aAdd( aBrowsex, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   oBrowsex:bLine := {||{ If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "7", oBranco  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "1", oVerde   ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "4", oPink    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "3", oAmarelo ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "2", oPreto   ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "9", oVermelho,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                          aBrowsex[oBrowsex:nAt,02]               ,;
                          aBrowsex[oBrowsex:nAt,03]               ,;
                          aBrowsex[oBrowsex:nAt,04]               ,;                         
                          aBrowsex[oBrowsex:nAt,05]               ,;                         
                          aBrowsex[oBrowsex:nAt,06]               ,;                         
                          aBrowsex[oBrowsex:nAt,07]               ,;                         
                          aBrowsex[oBrowsex:nAt,08]               ,;                         
                          aBrowsex[oBrowsex:nAt,09]               ,;                         
                          aBrowsex[oBrowsex:nAt,10]               ,;                                                     
                          aBrowsex[oBrowsex:nAt,11]               ,;                         
                          aBrowsex[oBrowsex:nAt,12]               ,;
                          aBrowsex[oBrowsex:nAt,13]               ,;
                          aBrowsex[oBrowsex:nAt,14]               ,;
                          aBrowsex[oBrowsex:nAt,15]               ,;
                          aBrowsex[oBrowsex:nAt,16]               ,;
                          aBrowsex[oBrowsex:nAt,17]               ,;
                          aBrowsex[oBrowsex:nAt,18]               }}
      
   oBrowsex:Refresh()

   oBrowsex:bHeaderClick := {|oObj,nCol| oBrowsex:aArray := Ordenar(nCol,oBrowsex:aArray),oBrowsex:Refresh()}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Ordena a coluna selecionada no grid
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// Função que expande ou contrai o tamanho do grid
Static Function ExpandeTel(_AbreFecha)

   If _AbreFecha == 1
      AAA_Abertura := 1   
      lAbreGrid    := .F.
      lFechGrid    := .T.
   Endif
   
   If _AbreFecha == 2
      AAA_Abertura := 2      
      lAbreGrid    := .T.
      lFechGrid    := .F.
   Endif

   // Atualiza a tabela ZZI com os dados de pesquisa do usuário logado
   DbSelectArea("ZZI")
   DbSetOrder(1)
   If DbSeek(Alltrim(cUserName))
      RecLock("ZZI",.F.)
      ZZI_APRO := AAA_Abertura
      MsUnLock()              
   Else
      aArea := GetArea()
      dbSelectArea("ZZI")
      RecLock("ZZI",.T.)
      ZZI_USUA := cUserName
      ZZI_APRO := AAA_Abertura
      MsUnLock()
   Endif

   oDlg:End()
   
   U_AUTOM243()

Return(.T.)   

// Função que abre o programa de edição de filtros do vendedor
Static Function AbreFiltro()
   
   // Chama o programa de edição de filtros do vendedor
   U_AUTOM250()

   aLista := {}

   // Atualiza o array aLista para novo display
   If Select("T_FILTROS") > 0
      T_FILTROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT2_CODI,"
   cSql += "       ZT2_NOME "
   cSql += "  FROM ZT2010"
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZT2_VEND   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FILTROS", .T., .T. )

   T_FILTROS->( DbGoTop() )
   
   WHILE !T_FILTROS->( EOF() )
      aAdd( aLista, { T_FILTROS->ZT2_CODI + " - " + T_FILTROS->ZT2_NOME } )
      T_FILTROS->( DbSkip() )
   ENDDO

   If Len(aLista) == 0
      aAdd( aLista, { "" } )
   Endif   

   oList:SetArray( aLista )
   oList:bLine := {||     {aLista[oList:nAt,01]}}
   
Return(.T.)

// Função que imprime a proposta comercial
Static Function ImpProCom(w_Oportunidade, w_Proposta, w_filial, w_Revisao)

   Local cSql       := ""
   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local oMemo1
   Local oMemo2
   
   Private oDlgXXX

// ___Filial := cFilAnt
// cFilAnt   := w_Filial
   
   // Pesquisa a oportunidade e verifica se a mesma é uma proposta de locação. Se for, imprime o contrato.
   dbSelectArea("AD1")
   DbSetOrder(1)
   If DbSeek( w_Filial + w_Oportunidade + w_Revisao) 

      If AD1_ZTIP == "2"

         U_AUTOM254(w_Filial, w_Oportunidade, w_Proposta)
         Return(.T.)         

      Else
         
         DEFINE MSDIALOG oDlgXXX TITLE "Impressão" FROM C(178),C(181) TO C(401),C(623) PIXEL

         @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(028) PIXEL NOBORDER OF oDlgXXX
         @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(211),C(001) PIXEL OF oDlgXXX
         @ C(087),C(005) GET oMemo2 Var cMemo2 MEMO Size C(211),C(001) PIXEL OF oDlgXXX
 	     @ C(034),C(005) Say "Selecione o tipo de impressão a ser realizada" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgXXX
         @ C(055),C(005) Button "Impressão Projeto"                          Size C(080),C(012) PIXEL OF oDlgXXX ACTION( U_AUTOM258(w_Filial, w_Oportunidade, w_Proposta) )
         @ C(044),C(095) Button "Prop. Comercial com Observações do Cliente" Size C(118),C(012) PIXEL OF oDlgXXX ACTION( U_AUTR002( w_Oportunidade, w_Proposta, w_Filial, 1) )
         @ C(058),C(095) Button "Prop. Comercial com Observações Internas"   Size C(118),C(012) PIXEL OF oDlgXXX ACTION( U_AUTR002( w_Oportunidade, w_Proposta, w_Filial, 2) )
         @ C(072),C(095) Button "Prop. Comercial sem Observações"            Size C(118),C(012) PIXEL OF oDlgXXX ACTION( U_AUTR002( w_Oportunidade, w_Proposta, w_Filial, 3) )
         @ C(094),C(091) Button "Voltar"                                     Size C(037),C(012) PIXEL OF oDlgXXX ACTION( oDlgXXX:End() )

         ACTIVATE MSDIALOG oDlgXXX CENTERED 

      Endif

   Endif
         

// U_AUTR002( w_Oportunidade, w_Proposta, w_Filial )

// cFilAnt   := ___Filial

Return(.T.)

// Função que carrega o lembrete pra o vendedor selecionado
Static Function CargaLembrete(xxxVendedor)

   Local cSql := ""

   If Select("T_LEMBRETE") > 0
      T_LEMBRETE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A3_LEMB)) AS LEMBRETE "
   cSql += "  FROM " + RetSqlName("SA3") 
   cSql += " WHERE A3_COD     = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LEMBRETE", .T., .T. )

   If T_LEMBRETE->( EOF() )
      cLembrete := ""
   Else
      cLembrete := T_LEMBRETE->LEMBRETE
   Endif

   oMemo3:Refresh()

   // Carrega o array aLista com, os filtros do vendedor selecionado
   If Select("T_FILTROS") > 0
      T_FILTROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT2_CODI,"
   cSql += "       ZT2_NOME "
   cSql += "  FROM ZT2010"
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZT2_VEND   = '" + Alltrim(Substr(xxxVendedor,01,06)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FILTROS", .T., .T. )

   aLista := {}

   T_FILTROS->( DbGoTop() )
   
   WHILE !T_FILTROS->( EOF() )
      aAdd( aLista, { T_FILTROS->ZT2_CODI + " - " + T_FILTROS->ZT2_NOME } )
      T_FILTROS->( DbSkip() )
   ENDDO

   If Len(aLista) == 0
      aAdd( aLista, { "             " } )
   Endif

   oList:SetArray( aLista )
   oList:bLine := {||     {aLista[oList:nAt,01]}}
   oList:Refresh()

    // Envia para a função que atualiza a tela com os dados do vendedor selecionado
   ImpaBrowse(2, "")

   cFilAnt:= __cBkpAnt //Restaura o cFilant - Michel Aoki 23/09/2014  
   
Return(.T.)

// Função que abre e salva os lembretes
Static Function AbreLembrete(_Botao)

   Private cZoom	 := cLembrete
   Private oZoom
   Private oDlgZoom
   Private DlgZoom

   If _Botao == 1
      lAbrBotao := .T.
   Endif
   
   If _Botao == 2

      lAbrBotao := .F.      
      
      // Grava o conteúdo para o vendedor selecionado
      DbSelectArea("SA3")
      DbSetorder(1)
      If DbSeek(xFilial("SA3") + Substr(cComboBx1,01,06))
         RecLock("SA3",.F.)
         A3_LEMB := cLembrete
         MsUnLock()           
      Endif   

   Endif
   
   If _Botao == 3

      DEFINE MSDIALOG oDlgZoom TITLE "Lembretes" FROM C(178),C(181) TO C(593),C(630) PIXEL

      @ C(002),C(002) Jpeg FILE "nota.bmp"    Size C(028),C(038)                 PIXEL NOBORDER OF oDlgZoom
      @ C(018),C(039) Say "L E M B R E T E S" Size C(046),C(008) COLOR CLR_BLACK PIXEL          OF oDlgZoom

      @ C(043),C(005) GET oZoom Var cZoom MEMO Size C(215),C(145) PIXEL OF oDlgZoom

      @ C(191),C(145) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgZoom ACTION( SALVA_LMBT(1, cZoom ) )
      @ C(191),C(183) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgZoom ACTION( SALVA_LMBT(2, cZoom ) )

      ACTIVATE MSDIALOG oDlgZoom CENTERED 

   Endif

Return(.T.)

// Função que salva o lembre pela tela de zoom de lembretes
Static Function SALVA_LMBT(__Botao, __Lembrete)

   // Acionado botão Voltar
   If __Botao == 2
      oDlgZoom:End() 
      Return(.T.)
   Endif
         
   // Acionado botão Salvar
   // Grava o conteúdo para o vendedor selecionado
   DbSelectArea("SA3")
   DbSetorder(1)
   If DbSeek(xFilial("SA3") + Substr(cComboBx1,01,06))
      RecLock("SA3",.F.)
      A3_LEMB := __Lembrete
      MsUnLock()           
   Endif   

   oDlgZoom:End() 

   cLembrete := cZoom
   oMemo3:Refresh()

Return(.T.)

// Função que envia xml a clientes
Static Function TIPO_DE_XML()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private XML_cliente := Space(06)
   Private XML_loja    := Space(03)
   Private XML_nome    := Space(60)
   Private XML_email   := Space(250)
   Private XML_arquivo := Space(250)
   Private XML_filtros := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oMemo2

   Public lUsaColab := .F.

   Private oDlgxml

   oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

   // Verifica se o usuário logado é um vendedor Assistente de Vendas (Se não for não permite gerar XML. Soliictação do Roger)
   If __cUserID == "000000"
   Else
      If Select("T_ASSISTENTE") > 0
         T_ASSISTENTE->( dbCloseArea() )
      EndIf

      cSql := "SELECT A3_CODUSR,"
      cSql += "       A3_TSTAT  "
      cSql += "  FROM " + RetSqlName("SA3")
      cSql += " WHERE A3_CODUSR  = '" + Alltrim(__cUserID) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ASSISTENTE", .T., .T. )

      If T_ASSISTENTE->( EOF() )
         MsgAlert("Atenção!" + chr(13) + chr(13) + "Usuário sem permissão para executar este procedimento.")
         Return(.T.)
      Endif
      
      If T_ASSISTENTE->A3_TSTAT <> "2"
         MsgAlert("Atenção!" + chr(13) + chr(13) + "Usuário sem permissão para executar este procedimento.")
         Return(.T.)
      Endif
   Endif

   // Envia para a função que gera o xml
   // GeraXMLCli("000001","1","050661","050661","e:\aaaa\",.F., "20140101","20151231","","ZZZZZZZZZZZZZZ", 1, .F.)
   // GeraXMLCli(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd, dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe
   SpedExport()

   If MV_PAR02 <> MV_PAR03
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Somente permitido gerar XML de uma em uma nota fiscal." + chr(13) + "Geração de XML abortada.")
      Return(.T.)
   Endif

   // Carrega o memo de filtro realizado para display
   XML_FILTROS := ""
   XML_FILTROS := "Série..........: " + Alltrim(MV_PAR01)       + chr(13) + ;
                  "Nota Inicial...: " + Alltrim(MV_PAR02)       + chr(13) + ;
                  "Nota Final.....: " + Alltrim(MV_PAR03)       + chr(13) + ;
                  "Dir. de Destino: " + Alltrim(MV_PAR04)       + chr(13) + ;
                  "Data Inicial...: " + Alltrim(Dtoc(MV_PAR05)) + chr(13) + ;
                  "Data Final.....: " + Alltrim(Dtoc(MV_PAR06)) + chr(13) + ;
                  "CNPJ Inicial...: " + Alltrim(MV_PAR07)       + chr(13) + ;
                  "CNPJ Final.....: " + Alltrim(MV_PAR08)       + chr(13)

   // Verifica se o XML está no diretório indicado no filtro
   If Select("T_NOTAXML") > 0
      T_NOTAXML->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT F2_FILIAL ,"
   csql += "       F2_DOC    ,"
   csql += "       F2_SERIE  ,"
   csql += "       F2_CLIENTE,"
   csql += "       F2_LOJA   ,"
   csql += "       F2_CHVNFE  "
   csql += "  FROM " + RetSqlName("SF2")
   csql += " WHERE F2_FILIAL  = '" + Alltrim(Substr(cComboBx3,01,02)) + "'"
   csql += "   AND F2_SERIE   = '" + Alltrim(MV_PAR01) + "'"
   csql += "   AND F2_DOC     = '" + Alltrim(MV_PAR02) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAXML", .T., .T. )

   If T_NOTAXML->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(13) + "XML não localizado." + chr(13) + "Verifique por exemplo a filial selecionada.")
      Return(.T.)
   Endif
      
   // Carrega a variável com o arquivo XML
   XML_ARQUIVO := Alltrim(MV_PAR04) + Alltrim(T_NOTAXML->F2_CHVNFE) + "-nfe.xml"

   // Verifica se o XML está contido no diretório apontado no filtro
   If !File(Alltrim(XML_ARQUIVO))
      MsgAlert("Atenção!" + chr(13) + chr(13) + "XML não localizado no diretório apontado no filtro de geração do XML." + chr(13) + "Verifique!")
      Return(.T.)
   Endif

   // Copia o arquivo XML para a pasta do servidor para poder ser enviado o arquivo como anexo
   __CopyFile( XML_ARQUIVO, "\\SRVERP\D$\Protheus\Protheus11\Protheus_data\XML_TMP\" + Alltrim(T_NOTAXML->F2_CHVNFE) + "-nfe.xml" ) 

   // Desenha a tela de envio de XML a Clientes
   DEFINE MSDIALOG oDlgXML TITLE "Envio de XML a Clientes" FROM C(178),C(181) TO C(431),C(912) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgXML

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(358),C(001) PIXEL OF oDlgXML

   @ C(023),C(301) Say "Envio de XML a Clientes."           Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
   @ C(037),C(005) Say "Filtro realizado"                   Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
   @ C(037),C(138) Say "Enviar XML ao Cliente"              Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
   @ C(060),C(138) Say "E-mail a ser utilizado para envio." Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
   @ C(083),C(138) Say "XML Gerado"                         Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML

   @ C(047),C(005) GET   oMemo2 Var XML_filtros MEMO Size C(127),C(073) Font oFont01                 PIXEL OF oDlgXML When lChumba
   @ C(047),C(138) MsGet oGet1  Var XML_CLIENTE      Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXML When lChumba
   @ C(047),C(350) Button "..."                      Size C(010),C(010)                              PIXEL OF oDlgXML ACTION( pRapidaCli(30) )
   @ C(070),C(138) MsGet oGet4  Var XML_email        Size C(222),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXML
   @ C(092),C(138) MsGet oGet5  Var XML_arquivo      Size C(222),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXML When lChumba

   @ C(108),C(212) Button "Enviar XML" Size C(037),C(012) PIXEL OF oDlgXML ACTION( Envia_XML(Alltrim(T_NOTAXML->F2_CHVNFE) + "-nfe.xml") )
   @ C(108),C(251) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlgXML ACTION( oDlgXML:End() )

   ACTIVATE MSDIALOG oDlgXML CENTERED 

Return(.T.)

// Função que envia o XML ao Cliente selecionado
Static Function Envia_XML(___Arquivo)

   Local cCorpo := ""

   If Empty(Alltrim(XML_Cliente))
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Cliente não selecionado para o envio do XML.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(XML_email))
      MsgAlert("Atenção!" + chr(13) + chr(13) + "E-mail não informado para o envio do XML.")
      Return(.T.)
   Endif

   // Elabora o texto do corpo do e-mail a ser enviado ao Cliente
   cCorpo := ""
   cCorpo := "Prezado(a)"                    + chr(13) + chr(10) + chr(13) + chr(10)
   cCorpo += Alltrim(Substr(XML_cliente,13)) + chr(13) + chr(10) + chr(13) + chr(10)
   cCorpo += "Em anexo, estamos lhe enviando o XML da Nota Fiscal Nº " + Alltrim(MV_PAR02) + ", Série " + Alltrim(MV_PAR01) + chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10)
   cCorpo += "Att."  + chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10)
   
   Do Case
      Case cEmpAnt == "01"
           cCorpo += "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
      Case cEmpAnt == "02"
           cCorpo += "TI AUTOMAÇÃO"
      Case cEmpAnt == "03"
           cCorpo += "ATECH"
   EndCase

   // Envia o e-mail ao Cliente
   U_AUTOMR20(cCorpo, Alltrim(XML_EMAIL), "\XML_TMP\" + Alltrim(___Arquivo), "XML Nf Nº " + Alltrim(MV_PAR02) + " - Série " + Alltrim(MV_PAR01) )

   // Elimina o arquivo do diretório de origem
   FERASE(Alltrim(XML_ARQUIVO))
   
   // Elimina o arquivo do diretório de destino 
   FERASE("\XML_TMP\" + Alltrim(___Arquivo))

   // Fecha a tela de envio de XML a Cliente
   oDlgXML:End() 
   
Return(.T.)                 

// Função que pergunta o tipo de DANFE a ser impressa
Static Function TIPO_DE_DANFE()

   DEFINE MSDIALOG oDlgDNF TITLE "Impressão Proposta Comercial" FROM C(178),C(181) TO C(330),C(462) PIXEL

   @ C(002),C(005) Jpeg FILE "nlogoautoma.bmp"                 Size C(130),C(026) PIXEL NOBORDER OF oDlgDNF
   @ C(033),C(005) Button "DANFE pelo programa do Sistema"    Size C(130),C(012) PIXEL OF oDlgDNF ACTION( XSTSDANFE() )
   @ C(046),C(005) Button "DANFE pelo Web Service (Gratuíto)" Size C(130),C(012) PIXEL OF oDlgDNF ACTION( U_AUTOM163() )      && ACTION( MsgAlert("Procedimento não disponível.") )  && U_AUTOM163() )
   @ C(060),C(005) Button "Voltar"                            Size C(130),C(012) PIXEL OF oDlgDNF ACTION( oDlgDNF:End() )

   ACTIVATE MSDIALOG oDlgDNF CENTERED 

Return(.T.)

// Função que Imprime a Danfe do Sistema
Static Function XSTSDANFE()

   Local cFil := aBrowsex[oBrowsex:nAt,03]

   Private aFilBrw := {"SF2","F2_FILIAL == '" + cFil + "'.And. F2_SERIE == '1 '"}

//   Private aFilBrw := {"SF2","F2_FILIAL == '" + cFil + "'.And. F2_SERIE == '" + SubStr( '1, 2 ) +"'"}
   
   SPEDDANFE()                                             
   
Return(.T.)

// Função que abre a tela da proposta comercial
//Static Function AbrePC(_kFilial, _Proposta)
//
//   Private INCLUI
//   Private ALTERA
//
//   DbSelectArea("ADY")
//   DbSetorder(1)
//   DbSeek(_kFilial + _Proposta)
//   
//   A600Mnt("ADY", ADY->( Recno() ), 4, _Proposta, AAQUI)
//
//Return(.T.)

// Função que carrega o array aBrowse
Static Function ImpaBrowse(_Tipo, _Filtro)

   Local cSql         := ""
   Local _PVenda      := ""
   Local _PNota       := ""
   Local _PSerie      := ""
   Local cFiltro      := ""
   Local cPedidoStr   := ""
   Local cNotaFiscal  := ""
   Local cSerieNota   := ""
   Local cSeqPedido   := ""
   Local aArea        := GetArea()
   Local LinhaComando := ""
   Local ped_pedidos  := ""
   Local cClausula    := ""
   
   If _Tipo == 4
      If Empty(Alltrim(_Filtro))
         MsgAlert("Não existem dados a serem visualizados para este filtro.")
         Return(.T.)
      Endif

      // Captura o comando a ser executado
      If Select("T_EXPRESSAO") > 0
         T_EXPRESSAO->( dbCloseArea() )
      EndIf
      
      cSql := "SELECT ZT2_FILIAL,"
      cSql += "       ZT2_VEND  ,"
      cSql += "       ZT2_CODI  ,"
      cSql += "       ZT2_NOME  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT2_COMA)) AS EXPRESSAO,"
      cSql += "       ZT2_TIPO  ,"
      cSql += "       ZT2_DDAT  ,"
      cSql += "       ZT2_ADAT  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT2_SDAT)) AS STRDATAS,"      
      cSql += "       ZT2_DELE   "
      cSql += "  FROM ZT2010"
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += "   AND ZT2_CODI   = '" + Substr(_Filtro,01,06)   + "'"
      cSql += "   AND ZT2_VEND   = '" + Substr(cComboBx1,01,06) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXPRESSAO", .T., .T. )

      LinhaComando := T_EXPRESSAO->EXPRESSAO

      // Cabeçalho das Propostas Comerciais
      If T_EXPRESSAO->ZT2_TIPO == "01"
//       cClausula := cClausula + "'" + Alltrim(T_EXPRESSAO->EXPRESSAO) + "'," 
         cClausula := cClausula + Alltrim(T_EXPRESSAO->EXPRESSAO)
      Endif

      // Cabeçalho das Propostas Comerciais
      If T_EXPRESSAO->ZT2_TIPO == "02"

         If Select("T_WHERE") > 0
            T_WHERE->( dbCloseArea() )
         EndIf

         cSql := "SELECT A.ADY_FILIAL,"
         cSql += "       A.ADY_OPORTU,"
         cSql += "       B.AD1_VEND  ,"
         cSql += "       B.AD1_VEND2  "
         cSql += "  FROM " + RetSqlName("ADY") + " A, "
         cSql += "       " + RetSqlName("AD1") + " B  ""
         cSql += " WHERE " + Alltrim(LinhaComando)
         cSql += "   AND A.ADY_FILIAL = B.AD1_FILIAL"
         cSql += "   AND A.ADY_OPORTU = B.AD1_NROPOR"
         cSql += "   AND A.D_E_L_E_T_ = ''"
         cSql += "   AND B.D_E_L_E_T_ = ''"
         cSql += "   AND (B.AD1_VEND   = '" + Alltrim(T_EXPRESSAO->ZT2_VEND) + "' OR B.AD1_VEND2 = '" + Alltrim(T_EXPRESSAO->ZT2_VEND) + "')"
         
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_WHERE", .T., .T. )
         
         If T_WHERE->( EOF() )
            MsgAlert("Não existem dados a serem visualizados.")
            Return(.T.)
         Endif

         cClausula := "("
         WHILE !T_WHERE->( EOF() )
            cClausula := cClausula + "'" + Alltrim(T_WHERE->ADY_OPORTU) + "',"
            T_WHERE->( DbSkip() )
         ENDDO
         
         // Elimina a última vírgula e fecha o comando para ser utilizado
         cClausula := Substr(cClausula,01, Len(Alltrim(cClausula)) - 1) + ")"

      Endif

      // Produtos das Propostas Comerciais
      If T_EXPRESSAO->ZT2_TIPO == "03"

         If Select("T_WHERE") > 0
            T_WHERE->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.ADZ_FILIAL,"
         cSql += "       A.ADZ_PROPOS,"
         cSql += "       B.ADY_OPORTU,"
         cSql += "       C.AD1_VEND  ,"
         cSql += "       C.AD1_VEND2  "
         cSql += "  FROM " + RetSqlName("ADZ") + " A , "
 
         // ATENÇÃO!! NUNCA TIRAR A TABELA ADY DO ALIAS B. ISSO É NECESSÁRIO EM FUNÇÃO DO PROGRAMA DE FILTROS DA PROPOSTA COMERCIAL
                      // QUANDO DA UTILIZAÇÃO DE FILTRO TIPO 03 (PRODUTOS DE PROPOSTA COMERCIAL) COM UTILIZAÇÃO DE DATAS.

         cSql += "       " + RetSqlName("ADY") + " B , "
         cSql += "       " + RetSqlName("AD1") + " C   "
         cSql += " WHERE A.ADZ_FILIAL = B.ADY_FILIAL"
         cSql += "   AND A.ADZ_PROPOS = B.ADY_PROPOS" 
         cSql += "   AND A.D_E_L_E_T_ = ''          "
         cSql += "   AND B.D_E_L_E_T_ = ''          "
         cSql += "   AND C.AD1_FILIAL = A.ADZ_FILIAL"
         cSql += "   AND C.AD1_NROPOR = B.ADY_OPORTU"
         cSql += "   AND C.D_E_L_E_T_ = ''          "
         cSql += "   AND (C.AD1_VEND   = '" + Alltrim(T_EXPRESSAO->ZT2_VEND) + "' OR C.AD1_VEND2 = '" + Alltrim(T_EXPRESSAO->ZT2_VEND) + "')"
         cSql += "   AND " + Alltrim(LinhaComando)

         If Empty(Alltrim(T_EXPRESSAO->STRDATAS))
         Else
            cSql += " " + Alltrim(T_EXPRESSAO->STRDATAS)
         Endif

         TcQuery cSql NEW ALIAS "T_WHERE"  
         
          If T_WHERE->( EOF() )
            MsgAlert("Não existem dados a serem visualizados.")
            Return(.T.)
         Endif

         cClausula := "("
         WHILE !T_WHERE->( EOF() )
            cClausula := cClausula + "'" + Alltrim(T_WHERE->ADY_OPORTU) + "',"
            T_WHERE->( DbSkip() )
         ENDDO
         
         // Elimina a última vírgula e fecha o comando para ser utilizado
         cClausula := Substr(cClausula,01, Len(Alltrim(cClausula)) - 1) + ")"

      Endif

   Endif

   // Se tipo == 3, Selecionado botão H O J E
   If _Tipo == 3
      dInicial := Date()
      dFinal   := Date()
   Endif

   // Se tipo == 5, Selecionado botão M Ê S
   If _Tipo == 5
      dInicial := Ctod("01/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      dFinal   := Date()
   Endif

   // Se tipo == 6, Selecionado botão A N O
   If _Tipo == 6
      dInicial := Ctod("01/01/" + Strzero(Year(Date()),4))
      dFinal   := Ctod("31/12/" + Strzero(Year(Date()),4))
   Endif

   // Gera consistência para pesquisa
   If _Tipo == 2

      // Consiste o Vendedor
      If Substr(cComboBx1,01,06) == "000000"
         MsgAlert("Vendedor para pesquisa não selecionado.")
         Return(.T.)
      Endif

   Endif

   // Limpa o array aBrowsex
   aBrowsex := {}

   If _Tipo == 2

      If Len(aBrowsex) == 0
         aAdd( aBrowsex, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
      Endif
    
      // Seta vetor para a browse                            
      oBrowsex:SetArray(aBrowsex)                                                
    
      // Monta a linha a ser exibina no Browse
      oBrowsex:bLine := {||{ If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "7", oBranco  ,;
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "1", oVerde   ,;
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "4", oPi4nk    ,;                         
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "3", oAmarelo ,;                         
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "5", oAzul    ,;                         
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "6", oLaranja ,;                         
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "2", oPreto   ,;                         
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "9", oVermelho,;
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "X", oCancel  ,;
                             If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                             aBrowsex[oBrowsex:nAt,02]               ,;
                             aBrowsex[oBrowsex:nAt,03]               ,;
                             aBrowsex[oBrowsex:nAt,04]               ,;                         
                             aBrowsex[oBrowsex:nAt,05]               ,;                         
                             aBrowsex[oBrowsex:nAt,06]               ,;                         
                             aBrowsex[oBrowsex:nAt,07]               ,;                         
                             aBrowsex[oBrowsex:nAt,08]               ,;                         
                             aBrowsex[oBrowsex:nAt,09]               ,;                         
                             aBrowsex[oBrowsex:nAt,10]               ,;                                                     
                             aBrowsex[oBrowsex:nAt,11]               ,;                         
                             aBrowsex[oBrowsex:nAt,12]               ,;
                             aBrowsex[oBrowsex:nAt,13]               ,;
                             aBrowsex[oBrowsex:nAt,14]               ,;
                             aBrowsex[oBrowsex:nAt,15]               ,;
                             aBrowsex[oBrowsex:nAt,16]               ,;
                             aBrowsex[oBrowsex:nAt,17]               ,;
                             aBrowsex[oBrowsex:nAt,18]               }}
                                                    
   Endif

   // Se for a entrada, recupera o último filtro para realizar a pesquisa
   If _Tipo == 1
      
      // Pesquisa o último filtro do Vendedor
      If Select("T_FILTRO") > 0
         T_FILTRO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_COD   ,"
      cSql += "       A3_FILTRO "
      cSql += "  FROM " + RetSqlName("SA3")
      cSql += " WHERE A3_CODUSR  = '" + Alltrim(__cUserID) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FILTRO", .T., .T. )
      
      If !Empty(Alltrim(T_FILTRO->A3_FILTRO))
         cComboBx3     := U_P_CORTA(T_FILTRO->A3_FILTRO     , "|" , 01)
         dInicial      := Ctod(U_P_CORTA(T_FILTRO->A3_FILTRO, "|" , 02))
         dFinal        := Ctod(U_P_CORTA(T_FILTRO->A3_FILTRO, "|" , 03))
         cCliente      := U_P_CORTA(T_FILTRO->A3_FILTRO     , "|" , 04)
         xOportunidade := U_P_CORTA(T_FILTRO->A3_FILTRO     , "|" , 05)
         xProposta     := U_P_CORTA(T_FILTRO->A3_FILTRO     , "|" , 06)
         cComboBx2     := U_P_CORTA(T_FILTRO->A3_FILTRO     , "|" , 07)
         cComboBx4     := U_P_CORTA(T_FILTRO->A3_FILTRO     , "|" , 08)
         xPedido       := Space(06)
      Endif   

   Endif

   If !Empty(Alltrim(xPedido))
      xOportunidade := Space(06)
      xProposta     := Space(06)
      oGet4:Refresh()
      oGet5:Refresh()
  
      // Pesquisa o nº da oportunidade e ou proposta para pesquisa dos dados do pedido de venda
      If Select("T_PELOPEDIDO") > 0
         T_PELOPEDIDO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT CK_FILIAL ,"
      cSql += "       CK_NUMPV  ,"
      cSql += "       CK_PROPOST "
      cSql += "  FROM " + RetSqlName("SCK")
      cSql += " WHERE CK_FILIAL  = '" + Alltrim(Substr(cComboBx3,01,02)) + "'"
      cSql += "   AND CK_NUMPV   = '" + Alltrim(xPedido) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PELOPEDIDO", .T., .T. )

      If T_PELOPEDIDO->( EOF() )

         MsgAlert("Não existem dados a serem visualizados para este pedido de venda.")

         If Len(aBrowsex) == 0
            aAdd( aBrowsex, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
         Endif
    
         // Seta vetor para a browse                            
         oBrowsex:SetArray(aBrowsex) 
    
         // Monta a linha a ser exibina no Browse
         oBrowsex:bLine := {||{ If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "7", oBranco  ,;
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "1", oVerde   ,;
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "4", oPink    ,;                         
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "3", oAmarelo ,;                         
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "5", oAzul    ,;                         
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "6", oLaranja ,;                         
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "2", oPreto   ,;                         
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "9", oVermelho,;
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "X", oCancel  ,;
                                If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                                aBrowsex[oBrowsex:nAt,02]               ,;
                                aBrowsex[oBrowsex:nAt,03]               ,;
                                aBrowsex[oBrowsex:nAt,04]               ,;                         
                                aBrowsex[oBrowsex:nAt,05]               ,;                         
                                aBrowsex[oBrowsex:nAt,06]               ,;                         
                                aBrowsex[oBrowsex:nAt,07]               ,;                         
                                aBrowsex[oBrowsex:nAt,08]               ,;                         
                                aBrowsex[oBrowsex:nAt,09]               ,;                         
                                aBrowsex[oBrowsex:nAt,10]               ,;                                                     
                                aBrowsex[oBrowsex:nAt,11]               ,;                         
                                aBrowsex[oBrowsex:nAt,12]               ,;
                                aBrowsex[oBrowsex:nAt,13]               ,;
                                aBrowsex[oBrowsex:nAt,14]               ,;
                                aBrowsex[oBrowsex:nAt,15]               ,;
                                aBrowsex[oBrowsex:nAt,16]               ,;
                                aBrowsex[oBrowsex:nAt,17]               ,;
                                aBrowsex[oBrowsex:nAt,18]               }}

         Return(.T.)

      Else

         xProposta := T_PELOPEDIDO->CK_PROPOST
      
      Endif

   Endif

   // Pesquisa registros para carregar o array aBrowse
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.AD1_STATUS," + CHR(13)
   cSql += "       A.AD1_FILIAL," + CHR(13)
   cSql += "       A.AD1_NROPOR," + CHR(13)
   cSql += "       B.ADY_PROPOS," + CHR(13)
   cSql += "       A.AD1_DESCRI," + CHR(13)
   cSql += "       A.AD1_CODCLI," + CHR(13)
   cSql += "       A.AD1_LOJCLI," + CHR(13)
   cSql += "       A.AD1_REVISA," + CHR(13)
   cSql += "       E.A1_NOME   ," + CHR(13) 
   cSql += "       A.AD1_DATA  ," + CHR(13)
   cSql += "       SUBSTRING(AD1_DTINI,07,02) + '/' + SUBSTRING(AD1_DTINI,05,02) + '/' + SUBSTRING(AD1_DTINI,01,04) AS INICIO ," + CHR(13)
   cSql += "       SUBSTRING(AD1_DTFIM,07,02) + '/' + SUBSTRING(AD1_DTFIM,05,02) + '/' + SUBSTRING(AD1_DTFIM,01,04) AS TERMINO," + CHR(13)
   cSql += "       A.AD1_VEND AS VENDEDOR_1,"    + CHR(13)
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = A.AD1_VEND AND D_E_L_E_T_ = '') AS NOME_VED1, " + CHR(13)
   cSql += "       A.AD1_VEND2 AS VENDEDOR_2,"   + CHR(13)
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = A.AD1_VEND2 AND D_E_L_E_T_ = '') AS NOME_VED2 " + CHR(13)
   cSql += "  FROM " + RetSqlName("AD1") + " A," + CHR(13)
   cSql += "       " + RetSqlName("ADY") + " B," + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " E " + CHR(13)
   cSql += " WHERE B.ADY_FILIAL = A.AD1_FILIAL " + CHR(13)
   cSql += "   AND B.ADY_OPORTU = A.AD1_NROPOR " + CHR(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"            + CHR(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"            + CHR(13)
   cSql += "   AND E.A1_COD     = A.AD1_CODCLI"  + CHR(13)
   cSql += "   AND E.A1_LOJA    = A.AD1_LOJCLI"  + CHR(13)

   If _Tipo == 4
                                   
      If T_EXPRESSAO->ZT2_TIPO == "03"
         cSql += " AND A.AD1_NROPOR IN " + Alltrim(cClausula)
      Else   
         cSql += " AND " + Alltrim(cClausula) + chr(13) 
      Endif
      
   Else

      // Filtra pela Filial selecionada
      Do Case
         Case Substr(cComboBx3,01,02) == "01"
              cSql += " AND A.AD1_FILIAL = '01'" + CHR(13)
         Case Substr(cComboBx3,01,02) == "02"
              cSql += " AND A.AD1_FILIAL = '02'" + CHR(13)
         Case Substr(cComboBx3,01,02) == "03"
              cSql += " AND A.AD1_FILIAL = '03'" + CHR(13)
         Case Substr(cComboBx3,01,02) == "04"
              cSql += " AND A.AD1_FILIAL = '04'" + CHR(13)
         Case Substr(cComboBx3,01,02) == "05"
              cSql += " AND A.AD1_FILIAL = '01'" + CHR(13)
      EndCase

      // Filtra pela data Inicial e Final
      cSql += " AND A.AD1_DATA >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13) + CHR(13)
      cSql += " AND A.AD1_DATA <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13) + CHR(13)
  
      // Filtra pelo Cliente informado
      If !Empty(Alltrim(cCliente))
         cSql += " AND A.AD1_CODCLI = '" + Substr(cCliente,01,06) + "'" + CHR(13)
         If lConcidera
            cSql += " AND A.AD1_LOJCLI = '" + Substr(cCliente,08,03) + "'" + CHR(13)
         Endif   
      Endif
      
      // Filtra pelo Vendedor
      cSql += " AND (A.AD1_VEND = '" + Substr(cComboBx1,01,06) + "' OR A.AD1_VEND2 = '" + Substr(cComboBx1,01,06) + "')" + CHR(13)

      // Filtra Pelo nº da Oportunidade
      If !Empty(Alltrim(xOportunidade))
         cSql += " AND A.AD1_NROPOR = '" + Alltrim(xOportunidade) + "'" + CHR(13)
      Endif
      
      // Filtra pelo nº da proposta comercial
      If !Empty(Alltrim(xProposta))
         cSql += " AND B.ADY_PROPOS = '" + Alltrim(xProposta) + "'" + CHR(13)
      Endif

      // Filtra pelo Status da Oportunidade
      If Substr(cComboBx2,01,01) <> "0"
         cSql += " AND A.AD1_STATUS = '" + Substr(cComboBx2,01,01) + "'" + CHR(13)
      Endif
      
   Endif   

   // Ordenação do Select
   Do Case
      Case Substr(cComboBx4,01,02) == "01"
           cSql += " ORDER BY A.AD1_FILIAL, A.AD1_NROPOR"
      Case Substr(cComboBx4,01,02) == "02"
           cSql += " ORDER BY A.AD1_FILIAL, B.ADY_PROPOS"
      Case Substr(cComboBx4,01,02) == "03"
           cSql += " ORDER BY A.AD1_FILIAL, E.A1_NOME"
      Case Substr(cComboBx4,01,02) == "04"
           cSql += " ORDER BY A.AD1_FILIAL, A.AD1_DESCRI"
      Case Substr(cComboBx4,01,02) == "05"
           cSql += " ORDER BY A.AD1_FILIAL, A.AD1_DATA"
   EndCase

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   aBrowsex := {}
   nRegua   := 0

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
              
      If _Tipo == 2
         nRegua := nRegua + 1
         oMeter1:Set(nRegua)
         oMeter1:Refresh()
      Endif   

      Do Case
         Case T_CONSULTA->AD1_STATUS == "1"
              __Legenda := "Aberta"
         Case T_CONSULTA->AD1_STATUS == "2"
              __Legenda := "Enc. s/Sucesso"
         Case T_CONSULTA->AD1_STATUS == "3"
              __Legenda := "Suspensa"
         Case T_CONSULTA->AD1_STATUS == "9"
              __Legenda := "Enc. c/Sucesso"
      EndCase

      // Carrega o array aBrowse
      aAdd( aBrowsex, { T_CONSULTA->AD1_STATUS         ,; // 01
                        __Legenda                      ,; // 02
                        Alltrim(T_CONSULTA->AD1_FILIAL),; // 03
                        T_CONSULTA->AD1_NROPOR         ,; // 04
                        T_CONSULTA->ADY_PROPOS         ,; // 05
                        ""                             ,; // 06
                        T_CONSULTA->AD1_DESCRI         ,; // 07
                        T_CONSULTA->AD1_CODCLI         ,; // 08
                        T_CONSULTA->AD1_LOJCLI         ,; // 09
                        T_CONSULTA->A1_NOME            ,; // 10
                        Substr(T_CONSULTA->AD1_DATA,07,02) + "/" +Substr(T_CONSULTA->AD1_DATA,05,02) + "/" + Substr(T_CONSULTA->AD1_DATA,01,04) ,; // 11
                        T_CONSULTA->INICIO             ,; // 12
                        T_CONSULTA->TERMINO            ,; // 13
                        T_CONSULTA->VENDEDOR_1         ,; // 14
                        T_CONSULTA->NOME_VED1          ,; // 15
                        T_CONSULTA->VENDEDOR_2         ,; // 16
                        T_CONSULTA->NOME_VED2          ,; // 17
                        T_CONSULTA->AD1_REVISA         }) // 18


       T_CONSULTA->( DbSkip() )

   ENDDO

   If _Tipo == 2
      oMeter1:Set(0)
      oMeter1:Refresh()
   Endif

   If Len(aBrowsex) == 0
      aAdd( aBrowsex, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif
    
   If _Tipo == 1
      Return(.T.)
   Endif

   // Pesquisa os nºs dos pedidos de vendas das oportunidades
   For nContar = 1 to Len(aBrowsex)

       ped_pedidos := ""

       DbSelectArea("SCK")
       DbSetorder(5)
       If DbSeek(aBrowsex[nContar,3] + aBrowsex[nContar,5])
       
          WHILE CK_FILIAL == aBrowsex[nContar,3] .And. CK_PROPOST == aBrowsex[nContar,5]

             If U_P_OCCURS(ped_pedidos, SCK->CK_NUMPV, 1) == 0
                If !Empty(Alltrim(SCK->CK_NUMPV))
                   ped_pedidos := ped_pedidos + Alltrim(SCK->CK_NUMPV) + ", "
                Endif   
             Endif

    		 DbSelectArea("SCK")
	         DBSKIP()

          ENDDO

          ped_pedidos := Substr(ped_pedidos,01,Len(Alltrim(ped_pedidos)) - 1)

       Endif

       aBrowsex[nContar,06] := ped_pedidos             
       
   Next nContar   

   // Seta vetor para a browse                            
   oBrowsex:SetArray(aBrowsex) 
          
   // Monta a linha a ser exibina no Browse
   oBrowsex:bLine := {||{ If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "7", oBranco  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "1", oVerde   ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "4", oPink    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "3", oAmarelo ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "2", oPreto   ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "9", oVermelho,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                          aBrowsex[oBrowsex:nAt,02]               ,;
                          aBrowsex[oBrowsex:nAt,03]               ,;
                          aBrowsex[oBrowsex:nAt,04]               ,;                         
                          aBrowsex[oBrowsex:nAt,05]               ,;                         
                          aBrowsex[oBrowsex:nAt,06]               ,;                         
                          aBrowsex[oBrowsex:nAt,07]               ,;                         
                          aBrowsex[oBrowsex:nAt,08]               ,;                         
                          aBrowsex[oBrowsex:nAt,09]               ,;                         
                          aBrowsex[oBrowsex:nAt,10]               ,;                                                     
                          aBrowsex[oBrowsex:nAt,11]               ,;                         
                          aBrowsex[oBrowsex:nAt,12]               ,;
                          aBrowsex[oBrowsex:nAt,13]               ,;
                          aBrowsex[oBrowsex:nAt,14]               ,;
                          aBrowsex[oBrowsex:nAt,15]               ,;
                          aBrowsex[oBrowsex:nAt,16]               ,;
                          aBrowsex[oBrowsex:nAt,17]               ,;
                          aBrowsex[oBrowsex:nAt,18]               }}

   oBrowsex:Refresh()

   // Atualiza o campo de filtro do vendedor selecionado
   cFiltro := Substr(cComboBx1,01,06) + "|" + ; // 01 - Filial
              Dtoc(dInicial)          + "|" + ; // 02 - Data inicial de pesquisa
              Dtoc(dFinal)            + "|" + ; // 03 - Data final de pesquisa
              Substr(cCliente,01,06)  + "|" + ; // 04 - Cliente
              xOportunidade           + "|" + ; // 05 - Oportunidade
              xProposta               + "|" + ; // 06 - Proposta Comercial
              cComboBx2               + "|" + ; // 07 - Status
              cComboBx4               + "|" + ; // 08 - Ordenação
              xPedido                 + "|"     // 09 - Pedido de Venda

   DbSelectArea("SA3")
   DbSetorder(1)
   If DbSeek(xFilial("SA3") + Substr(cComboBx1,01,06))
      RecLock("SA3",.F.)
      A3_FILTRO := cFiltro
      MsUnLock()           
   Endif   

Return(.T.)

// Função de Manutenção das Oportunidades I
Static Function ManuOportu(_Operacao, _Codigo, _Filial, _Legenda, _PropostaK)

   Local lChumbado := .F.
   Local aComboBx1 := {}
   Local cComboBx1
   Local cMemo1	   := ""
   Local oMemo1

   Private oDlgO

   If _Operacao == "I"

      // Carrega o combo de Filiais
      Do Case 
         Case cEmpAnt == "01"
              aComboBx1 := {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
               Do Case
                  Case cFilAnt == "01"
                       cComboBx1 := "01 - Porto Alegre"
                  Case cFilAnt == "02"
                       cComboBx1 := "02 - Caxias do Sul"
                  Case cFilAnt == "03"
                       cComboBx1 := "03 - Pelotas"
                  Case cFilAnt == "04"
                       cComboBx1 := "04 - Suprimentos"
               EndCase        
         Case cEmpAnt == "02"
              aComboBx1 := {"01 - TI - Curitiba"}
              cComboBx1 := "01 - TI - Curitiba"
         Case cEmpAnt == "03"
              aComboBx1 := {"01 - Atech - Porto Alegre"}
              cComboBx1 := "01 - Atech - Porto Alegre"
      EndCase      

      DEFINE MSDIALOG oDlgO TITLE "Inclusão de Oportunidade de Venda" FROM C(178),C(181) TO C(339),C(475) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(140),C(026) PIXEL NOBORDER OF oDlgO

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(140),C(001) PIXEL OF oDlgO

//    @ C(037),C(005) Say "INDIQUE A FILIAL DE ABERTURA DA OPORTUNIDADE"    Size C(135),C(008) COLOR CLR_BLACK PIXEL OF oDlgO
      @ C(037),C(005) Say "ATENÇÃO! OPORTUNIDADE SERÁ ABERTA PARA A FILIAL ABAIXO"   Size C(135),C(008) COLOR CLR_BLACK PIXEL OF oDlgO

      @ C(047),C(005) ComboBox cComboBx1 Items aComboBx1 Size C(135),C(010) PIXEL OF oDlgO When lChumbado
 
      @ C(062),C(035) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgO ACTION( AbreOportunidade( 1, _Operacao, _Codigo, Substr(cComboBx1,01,02), _Legenda, _PropostaK ) )
      @ C(062),C(073) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgO ACTION( AbreOportunidade( 2, _Operacao, _Codigo, Substr(cComboBx1,01,02), _Legenda, _PropostaK ) )

      ACTIVATE MSDIALOG oDlgO CENTERED 

   Else

      AbreOportunidade( 3, _Operacao, _Codigo, _Filial, _Legenda, _PropostaK )

   Endif

Return(.T.)

// Manutenção de Oprotunidades II
Static Function AbreOportunidade(_Tipo, _Operacao, _Codigo, _Filial, _Legenda, _PropostaK)

   Local lChumba         := .F.
   Local lAlterar        := .F.
   Local nVezes          := 0
   Local cParametros     := ""

   Private lSalvar       := .F.
   Private aLocacao      := {}
   Private _Imagem       := "br_branco"
   Private lStatus       := .F.
   Private aUnidade      := {"00 - Selecionar", "01 - POA", "02 - CXA", "03 - PEL", "04 - SUP", "05 - CUR"}
   Private aLegenda      := {"1 - Aberto", "2 - Perdido", "3 - Suspenso", "9 - Encerrado"}
   Private aTipoProp     := {"1 - Proposta Comercial", "2 - Proposta de Locação"}
   Private cComboBx5
   Private cComboBx6
   Private cComboBx7
   Private xOportunidade := Space(06)
   Private cRevisao  	 := Space(02)
   Private cData	     := Ctod("  /  /    ")
   Private cHora  	     := Space(10)
   Private cInicio       := IIF(_Operacao == "I", Date(), Ctod("  /  /    "))
   Private cTermino      := Ctod("  /  /    ")
   Private cDescricao 	 := Space(30)
   Private cCliente	     := Space(06)
   Private cLojacli	     := Space(03)
   Private cNomeCli  	 := Space(60)
   Private cVendedor1	 := Space(06)
   Private cVendedor2 	 := Space(06)
   Private cNomeVend1	 := Space(30)
   Private cNomeVend2	 := Space(30)
   Private cComissao1	 := 0
   Private cComissao2	 := 0
   Private cMoeda	     := 1
   Private cVerba   	 := 0
   Private cFCS	         := Space(06)
   Private cFCI 	     := Space(06)

   Private cMemo1	 := ""
   Private cMemo2	 := ""

   Private oGet1
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet16
   Private oGet17
   Private oGet18
   Private oGet19
   Private oGet2
   Private oGet20
   Private oGet21
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet8
   Private oGet9
   Private oMemo1
   Private oMemo2

   Private oDlgA

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

   // Habilita ou não o botão Salvar Oportunidade conforme Operação
   Do Case
      // Inclusão
      Case _Operacao == "I"
           lSalvar := .F.
      // Alteração
      Case _Operacao == "A"
           lSalvar := .T.
      // Visualização
      Case _Operacao == "V"
           lSalvar := .F.
   EndCase        

   // Verifica se permite realiza alteração da oportunidade
   If _Operacao == "A"
      If _Legenda <> "1"
         If _Legenda == "2"
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Operação não permitida." + chr(13) + chr(10) + "Oportunidade P e r d i  d a." + Chr(13) + Chr(10) + "Utilize a opção Visualização.")
         Endif 
         If _Legenda == "3"
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Operação não permitida." + chr(13) + chr(10) + "Oportunidade S u s p e n s a." + Chr(13) + Chr(10) + "Utilize a opção Visualização.")
         Endif 
         If _Legenda == "9"
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Operação não permitida." + chr(13) + chr(10) + "Oportunidade já E n c e r r a d a." + Chr(13) + Chr(10) + "Utilize a opção Visualização.")
         Endif 
         Return(.T.)
      Endif
   Endif

   // I N C L U S Ã O
   If _Operacao == "I"

      lAlterar := .T.

      // Se inclusão, verifica se usuário acionou o botão de Voltar
      OdlgO:End()

      // Indica que usuário acionou o botão Voltar
      If _Tipo == 2
         Return(.T.)
      Endif

      cFilAnt := _Filial

      // Se inclusão, captura o novo código da oportunidade para inclusão
      xOportunidade := Ft300Num() //GetSXENum( "AD1", "AD1_NROPOR" ) 
      cRevisao      := "01"
      cData         := Date()
      cHora         := Time()

   Endif

   // Carrega o Combo de Filiais conforme a Empresa e Filial indicadas
   Do Case

      Case cEmpAnt == "01"
           Do Case
              Case _Filial == "01"
                   aUnidade := {"01-PORTO ALEGRE"}
              Case _Filial == "02"
                   aUnidade := {"02-CAXIAS DO SUL"}
              Case _Filial == "03"
                   aUnidade := {"03-PELOTAS"}
              Case _Filial == "04"
                   aUnidade := {"04-SUPRIMENTOS"}
           EndCase

      Case cEmpAnt == "02"
           aUnidade := {"01-TI"}
                  
      Case cEmpAnt == "03"
           aUnidade := {"01-ATECH"}

   EndCase                  

   If _Operacao == "A" .Or. _Operacao == "V"

      lAlterar := IIF(_Operacao == "A", .T., .F.)

      If Select("T_VENDA") > 0
         T_VENDA->( dbCloseArea() )
      EndIf

      cSql := "SELECT AD1_FILIAL,"
      cSql += "       AD1_NROPOR,"
      cSql += "       AD1_REVISA,"
      cSql += "       AD1_DESCRI,"
      cSql += "       AD1_DTINI ,"
      cSql += "       AD1_DTFIM ,"
      cSql += "       AD1_VEND  ,"
      cSql += "       AD1_VEND2 ,"
      cSql += "       AD1_DATA  ,"
      cSql += "       AD1_HORA  ,"
      cSql += "       AD1_CODCLI,"
      cSql += "       AD1_LOJCLI,"
      cSql += "       AD1_MOEDA ,"
      cSql += "       AD1_PROVEN,"
      cSql += "       AD1_STAGE ,"
      cSql += "       AD1_PRIOR ,"
      cSql += "       AD1_STATUS,"
      cSql += "       AD1_USER  ,"
      cSql += "       AD1_VERBA ,"
      cSql += "       AD1_MODO  ,"
      cSql += "       AD1_COMIS1,"
      cSql += "       AD1_COMIS2,"
      cSql += "       AD1_FCS   ,"
      cSql += "       AD1_FCI   ,"
      cSql += "       AD1_ZTIP  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AD1_ZLOC)) AS PARAMETROS"
      cSql += " FROM " + RetSqlName("AD1")
      cSql += " WHERE AD1_FILIAL = '" + Alltrim(_Filial) + "'"
      cSql += "   AND AD1_NROPOR = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDA", .T., .T. )

      If !T_VENDA->( EOF() )

         Do Case
            Case cEmpAnt == "01"         
                 Do Case
                    Case AD1_FILIAL  == "01"
                         cComboBx5 := "01-Porto Alegre"
                    Case AD1_FILIAL  == "02"
                         cComboBx5 := "02-Caxias do Sul"
                    Case AD1_FILIAL  == "03"
                         cComboBx5 := "03-Pelotas"
                    Case AD1_FILIAL  == "04"
                         cComboBx5 := "04-Suprimentos"
                 EndCase        
            Case cEmpAnt == "02"
                 cComboBx5 := "01-TI"
            Case cEmpAnt == "03"
                 cComboBx5 := "01-ATECH"
         EndCase

         xOportunidade := AD1_NROPOR  
         cRevisao      := AD1_REVISA 
         cDescricao    := AD1_DESCRI 
         cInicio       := Ctod(Substr(AD1_DTINI,07,02) + "/" + Substr(AD1_DTINI,05,02) + "/" + Substr(AD1_DTINI,01,04))
         cTermino      := Ctod(Substr(AD1_DTFIM,07,02) + "/" + Substr(AD1_DTFIM,05,02) + "/" + Substr(AD1_DTFIM,01,04))
         cVendedor1    := AD1_VEND   
         cNomeVend1    := Posicione("SA3", 1, xFilial("SA3") + cVendedor1, "A3_NOME")
         cVendedor2    := AD1_VEND2
         cNomeVend2    := Posicione("SA3", 1, xFilial("SA3") + cVendedor2, "A3_NOME")
         cData         := Ctod(Substr(AD1_DATA,07,02)  + "/" + Substr(AD1_DATA,05,02)  + "/" + Substr(AD1_DATA,01,04))
         cHora         := AD1_HORA   
         cCliente      := AD1_CODCLI 
         cLojaCli      := AD1_LOJCLI 
         cNomeCli      := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLojaCli, "A1_NOME")
         cMoeda        := AD1_MOEDA  

         Do Case
            Case AD1_STATUS == "1"
                 cComboBx6 := "1 - Aberto"
            Case AD1_STATUS == "2"
                 cComboBx6 := "2 - Perdido"
            Case AD1_STATUS == "3"
                 cComboBx6 := "3 - Suspenso"
            Case AD1_STATUS == "9"
                 cComboBx6 := "9 - Encerrado"
         EndCase

         cVerba        := AD1_VERBA  
         cComissao1    := AD1_COMIS1 
         cComissao2    := AD1_COMIS2 
         cFCS          := AD1_FCS
         cFCI          := AD1_FCI
         lStatus       := !Empty(cFCS) .Or. !Empty(cFCI)

         // Carrega o combox de Tipo de Proposta Comercial
         If AD1_ZTIP == "1"
            cCombobx7 := "1 - Proposta Comercial"
         Else
            cCombobx7 := "2 - Proposta de Locação"
         Endif
         
         // Carrega o array aLocacao. Array que contém os parâmetros da proposta de locação
         If U_P_OCCURS(T_VENDA->PARAMETROS, "|", 1)  == 20
            nVezes      := U_P_OCCURS(T_VENDA->PARAMETROS, "|", 1) + 1
            cParametros := T_VENDA->PARAMETROS + "1|"
         Else
            nVezes      := U_P_OCCURS(T_VENDA->PARAMETROS, "|", 1)
            cParametros := T_VENDA->PARAMETROS
         Endif
         
         For nContar = 1 to nVezes
             aAdd( aLocacao, U_P_CORTA(cParametros, "|", nContar) )
         Next nContar    

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
         cSql += "   AND A.E1_CLIENTE = '" + Alltrim(cCliente) + "'"
         cSql += "   AND A.E1_LOJA    = '" + Alltrim(cLojaCli) + "'"
         cSql += "   AND A.E1_VENCTO < CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
         cSql += "   AND (A.E1_TIPO   <> 'RA' AND A.E1_TIPO <> 'NCC')"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

         If T_PARCELAS->( EOF() )
            _Imagem := "br_verde"
         Else
            _Imagem := "br_vermelho"         
         Endif

      Endif
      
   Endif

   // Desenha a tela de manutenção de oprotunidades
   DEFINE MSDIALOG oDlgA TITLE "Proposta Comercial" FROM C(178),C(181) TO C(530),C(729) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgA

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(264),C(001) PIXEL OF oDlgA
   @ C(155),C(005) GET oMemo2 Var cMemo2 MEMO Size C(264),C(001) PIXEL OF oDlgA
      
   @ C(023),C(207) Say "PROPOSTA COMERCIAL" Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(035),C(005) Say "Filial"                  Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(035),C(060) Say "Oportunidade"            Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(035),C(099) Say "Revisão"                 Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(035),C(125) Say "Data"                    Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(035),C(165) Say "Hora"                    Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(035),C(196) Say "Dta.Início"              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(035),C(236) Say "Dta Término"             Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(056),C(005) Say "Descrição"               Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(077),C(005) Say "Cliente"                 Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(098),C(005) Say "Vendedores"              Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(056),C(165) Say "Tipo Proposta Comercial" Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(132),C(005) Say "Moeda"                   Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(132),C(035) Say "Verba"                   Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(132),C(090) Say "F.C.S."                  Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(132),C(124) Say "F.C.I."                  Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(132),C(157) Say "Status"                  Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(108),C(240) Say "Auxilio"                 Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(044),C(005) ComboBox cComboBx5 Items aUnidade      Size C(049),C(010)                                             PIXEL OF oDlgA When lChumba
   @ C(044),C(060) MsGet    oGet1     Var   xOportunidade Size C(033),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(044),C(099) MsGet    oGet2     Var   cRevisao      Size C(020),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(044),C(125) MsGet    oGet21    Var   cData         Size C(033),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(044),C(165) MsGet    oGet6     Var   cHora         Size C(025),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(044),C(196) MsGet    oGet5     Var   cInicio       Size C(033),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lAlterar
   @ C(044),C(236) MsGet    oGet4     Var   cTermino      Size C(033),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(065),C(005) MsGet    oGet3     Var   cDescricao    Size C(154),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lAlterar
   @ C(065),C(165) ComboBox cComboBx7 Items aTipoProp     Size C(058),C(010)                                             PIXEL OF oDlgA When lAlterar
   @ C(062),C(227) Button "Dados Locação"                 Size C(042),C(012)                                             PIXEL OF oDlgA ACTION( PedeLoca( cComboBx7, xOportunidade, _PropostaK, cCliente + "." + cLojaCli + " - " + Alltrim(cNomeCli), _Operacao ) ) && When lAlterar
   @ C(086),C(005) MsGet    oGet8     Var   cCliente      Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(086),C(035) MsGet    oGet9     Var   cLojaCli      Size C(019),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(086),C(057) MsGet    oGet10    Var   cNomeCli      Size C(179),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba
   @ C(086),C(239) Button "..."                           Size C(010),C(009)                                             PIXEL OF oDlgA ACTION( pRapidaCli(2) ) When lAlterar
   @ C(088),C(255) Jpeg FILE _Imagem                      Size C(009),C(009)                                             PIXEL NOBORDER OF oDlgA
   @ C(107),C(005) MsGet    oGet11    Var   cVendedor1    Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA F3("SA3") VALID( trazvende(1, cVendedor1 ) ) When Substr(cComboBx7,01,01) == "1" When lAlterar 

   @ C(107),C(035) MsGet    oGet12    Var   cNomeVend1    Size C(201),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba

   @ C(119),C(005) MsGet    oGet13    Var   cVendedor2    Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA F3("SA3") VALID( trazvende(2, cVendedor2 ) ) When Substr(cComboBx7,01,01) == "1" When lAlterar 

   @ C(119),C(035) MsGet    oGet14    Var   cNomeVend2    Size C(201),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lChumba

   @ C(141),C(005) MsGet    oGet17    Var   cMoeda        Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA When lAlterar
   @ C(141),C(035) MsGet    oGet18    Var   cVerba        Size C(049),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgA When lAlterar

   If _Operacao == "I"
      @ C(141),C(090) MsGet    oGet19    Var   cFCS          Size C(027),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA F3("SX5","A6") When lChumba
      @ C(141),C(124) MsGet    oGet20    Var   cFCI          Size C(027),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA F3("SX5","A6") When lChumba
      @ C(141),C(157) ComboBox cComboBx6 Items aLegenda      Size C(112),C(010)                                             PIXEL OF oDlgA                When lChumba
   Else
      @ C(141),C(090) MsGet    oGet19    Var   cFCS          Size C(027),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA F3("SX5","A6") VALID(LibStatus()) When lAlterar
      @ C(141),C(124) MsGet    oGet20    Var   cFCI          Size C(027),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgA F3("SX5","A6") VALID(LibStatus()) When lAlterar
      @ C(141),C(157) ComboBox cComboBx6 Items aLegenda      Size C(112),C(010)                                             PIXEL OF oDlgA When lStatus When lAlterar
   Endif

   @ C(117),C(239) Button "Pré-Venda"          Size C(030),C(012) PIXEL OF oDlgA ACTION( AbrAuxilio(cComboBx5, _Operacao, xOportunidade, cCliente, cLojaCli, cNomeCli, cVendedor1, cNomeVend1, cComboBx6 ) )
   @ C(160),C(005) Button "Proposta Comercial" Size C(052),C(012) PIXEL OF oDlgA ACTION( AbrPComercial(_Operacao, xOportunidade, Substr(cComboBx5,01,02), "A", cComboBx6 ) )
   @ C(160),C(058) Button "Contatos"           Size C(037),C(012) PIXEL OF oDlgA ACTION( U_AUTOMR60() )
   @ C(160),C(097) Button "Cliente X Contatos" Size C(056),C(012) PIXEL OF oDlgA ACTION( U_AUTOMR61(cCliente, cLojaCli) )
   @ C(160),C(193) Button "Salvar Oport."      Size C(037),C(012) PIXEL OF oDlgA ACTION( AbrPComercial(_Operacao, xOportunidade, Substr(cComboBx5,01,02), "S", cComboBx6, _PropostaK ) ) When lSalvar
   @ C(160),C(232) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlgA ACTION( FechTelOpor(_Operacao, Substr(cComboBx5,01,02), xOportunidade, cCliente, cLojaCli))

   ACTIVATE MSDIALOG oDlgA CENTERED 

   cFilAnt:= __cBkpAnt //Restaura o cFilant - Michel Aoki 23/09/2014  
   
Return(.T.)

// Função que Volta a Filial padrão e encerra a janela das oportunidades
Static Function FechTelOpor(_Operacao, ww_Filial, xOportunidade, xCliente, xLojaCli)

   Local cSql := ""

   // Em caso de inclusão, retorna a filial padrão
// If _Operacao == "I"
//    cFilAnt := ___Filial
// Endif

   If MsgYesNo("Deseja realmente sair?")
   Else
      Return(.T.)      
   Endif

   // Verifica se existe solicitação de auxilio a área de projetos.
   // Caso exista e não estiver a oportunidade gravada na tabela AD1, exlui a solicitação
   // Se sim, abre a tarefa no portal
   If Select("T_EXISTEOPOR") > 0
      T_EXISTEOPOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AD1_FILIAL, "
   cSql += "       AD1_NROPOR  "
   cSql += "  FROM " + RetSqlName("AD1")
   cSql += " WHERE AD1_FILIAL = '" + Alltrim(ww_Filial)     + "'"
   cSql += "   AND AD1_NROPOR = '" + Alltrim(xOportunidade) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXISTEOPOR", .T., .T. )

   // Se não existe a oprotunidade gravada, exclui a solicitação de auxílio a área de projetos
   If T_EXISTEOPOR->( EOF() )

      If Select("T_PORTAL") > 0
         T_PORTAL->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTH_FILIAL,"
      cSql += "       ZTH_CODI  ,"
      cSql += "       ZTH_DATA  ,"
      cSql += "       ZTH_HORA  ,"
      cSql += "       ZTH_USUA  ,"
      cSql += "       ZTH_PORT  ,"
      cSql += "       ZTH_CFIL  ,"
      cSql += "       ZTH_OPOR  ,"
      cSql += "       ZTH_CLIE  ,"
      cSql += "       ZTH_LOJA  ,"
      cSql += "       ZTH_TITU  ,"
      cSql += "       ZTH_DETA  ,"
      cSql += "       ZTH_STAT   "
      cSql += "  FROM " + "ZTH010"
      cSql += " WHERE ZTH_OPOR = '" + Alltrim(xOportunidade) + "'"
      cSql += "   AND ZTH_CLIE = '" + Alltrim(xCliente)      + "'"
      cSql += "   AND ZTH_LOJA = '" + Alltrim(xLojaCli)      + "'"
      cSql += "   AND ZTH_DELE = ''"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTAL", .T., .T. )
      
      If T_PORTAL->( EOF() )
      Else

         WHILE !T_PORTAL->( EOF() )
            
            DbSelectArea("ZTH")
            DbSetOrder(1)
            If DbSeek(xFilial("ZTH") + T_PORTAL->ZTH_CODI + T_PORTAL->ZTH_CLIE + T_PORTAL->ZTH_LOJA)
               RecLock("ZTH",.F.)
               ZTH_DELE := "X"
               MsUnLock()              
            Endif
               
            T_PORTAL->( DbSkip() )

         ENDDO   

      Endif
      
   Endif

   oDlgA:End()

Return(.T.)   

// Função que Libera ou não o combobox do Status da Oportunidade
Static Function LibStatus()
                          
   If Empty(Alltrim(cFCS)) .And. Empty(Alltrim(cFCI))
      lStatus := .F.
   Endif
      
   If !Empty(Alltrim(cFCS)) .And. Empty(Alltrim(cFCI))
      lStatus := .T.
   Endif

   If Empty(Alltrim(cFCS)) .And. !Empty(Alltrim(cFCI))
      lStatus := .T.
   Endif

   If !Empty(Alltrim(cFCS)) .And. !Empty(Alltrim(cFCI))
      lStatus := .T.
   Endif

Return(.T.)

// Função que pesquisa os vendedores informados
Static Function trazvende(_posicao, _CodVende)
      
   If _posicao == 1
      If Empty(Alltrim(_CodVende))
         cNomeVend1 := Space(30)
         cComissao1 := 0
         Return(.T.)   
      Endif
   Else
      If Empty(Alltrim(_CodVende))
         cNomeVend2 := Space(30)
         cComissao2 := 0
         Return(.T.)   
      Endif
   Endif

   // Pesquisa o vendedor
   DbSelectArea("SA3")
   DbSetorder(1)
   If DbSeek(xFilial("SA3") + _Codvende)
      If _Posicao == 1
         cNomevend1 := SA3->A3_NOME
      Else
         cNomevend2 := SA3->A3_NOME         
      Endif
   Else
      If _Posicao == 1
         cNomevend1 := Space(30)
         cComissao1 := 0
      Else
         cNomevend2 := Space(30)
         cComissao2 := 0
      Endif
   Endif
            
Return(.T.)            

// Função: PRAPIDALmp - Função que limpa o campo Cliente
Static Function pRapidaLmp()

   lConcidera := .F.
   cCliente := Space(100)
   oGet3:Refresh()
   ImpaBrowse(2, "")

Return(.T.)

// Função: PRAPIDACLI - Função que pesquisa clientes
Static Function pRapidaCli(_Tela)

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

   Private oDlg

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
   
   DEFINE MSDIALOG oDlg TITLE "Pesquisa Cadastro de Entidades" FROM C(178),C(181) TO C(602),C(909) PIXEL

   @ C(008),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg
   @ C(187),C(005) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(187),C(074) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(043),C(002) GET oMemo1 Var cMemo1 MEMO Size C(357),C(001) PIXEL OF oDlg
   
   @ C(006),C(138) Say "String a Pesquisar"   Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(138) Say "Ordenação Pesquisa"   Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(019),C(138) Say "Pesquisar pelo Campo" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(269) Say "Operação"             Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(188),C(017) Say "Sem pendências financeiras" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(086) Say "Com pendências financeiras" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(193) MsGet oGet1 Var cString  Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(003),C(323) Button "Pesquisar"       Size C(037),C(012) PIXEL OF oDlg ACTION( xbuscaCli() )

   @ C(018),C(193) ComboBox cComboBx2 Items aCampo     Size C(071),C(010) PIXEL OF oDlg
   @ C(018),C(295) ComboBox cComboBx3 Items aOperador  Size C(065),C(010) PIXEL OF oDlg
   @ C(029),C(193) ComboBox cComboBx4 Items aOrdenacao Size C(168),C(010) PIXEL OF oDlg

   @ C(195),C(005) Button "Dados do Cadastro"   Size C(063),C(012) PIXEL OF oDlg ACTION( xCadCliente( _Tela, aCliente[oCliente:nAt,02], aCliente[oCliente:nAt,03], "", aCliente[oCliente:nAt,01]) )
   @ C(195),C(074) Button "Contatos"            Size C(063),C(012) PIXEL OF oDlg ACTION( U_AUTOMR60() )
   @ C(195),C(143) Button "Contato X Cliente "  Size C(063),C(012) PIXEL OF oDlg ACTION( U_AUTOMR61(aCliente[oCliente:nAt,02], aCliente[oCliente:nAt,03]) )
   @ C(195),C(283) Button "Selecionar"          Size C(037),C(012) PIXEL OF oDlg ACTION( xSelCliente( _Tela, aCliente[oCliente:nAt,02], aCliente[oCliente:nAt,03], aCliente[oCliente:nAt,04], aCliente[oCliente:nAt,01]) )
   @ C(195),C(322) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( xSelCliente( _Tela, "", "", "", "") )

   aAdd( aCliente, { "1", "", "", "", "", "", "" })

   oCliente := TCBrowse():New( 062 , 005, 456, 175,,{"LG", "Código", "Loja", "Descrição", "CNPJ/CPF", "Município", "UF"}, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que fecha a janela pelo botão selecionar e transfere código e loja selecionados
Static Function xSelCliente(_xTela, _Codigo, _Loja, _NomeCli, _Legenda)
   
   Local lVoltar  := .F.
   Local nPosicao := 0

   oDlg:End()

   // Tela == 30 - Tela de envio de XML a Clientes
   If _xTela == 30
      If Empty(Alltrim(_Codigo))
         XML_Cliente := Space(06)
         XML_Email   := Space(250)
         Return(.T.)
      Else
         XML_Cliente := Alltrim(_Codigo) + "." + Alltrim(_Loja) + " - " + Alltrim(_NomeCli)
         XML_Email   := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_EMAIL")
         Return(.T.)
      Endif
   Endif

   If Empty(Alltrim(_Codigo))
      If _xTela == 1
         cCliente := "                    "
      Else
         cCLiente := Space(06)
         cLojaCli := Space(03)
         cNomeCli := Space(40)
         _Imagem  := "br_branco"
         If _xTela == 2
            @ C(088),C(255) Jpeg FILE _Imagem Size C(009),C(009) PIXEL NOBORDER OF oDlgA
         Endif   
      Endif

   Else 
   
      // ------------------------------------------------------------------------------------------------------------------------------------- //
      // Verifica se é possível a troca do cliente em razão da seguinte regra:                                                                 //
      // Se Grupo Tributário do cliente for = 002 - IE Ativa  e se os produtos da proposta comercial tiverem o Tipo de Operação 02 não permite //
      // Se Grupo Tributário do cliente for = 003 - IE Isenta e se os produtos da proposta comercial tiverem o Tipo de Operação 03 não permite //
      // Isso porque se a IE do Cliente for IE Ativa , somente deve aceitar o Tipo de Operação = 03                                            //
      //             se a IE do Cliente for IE Isenta, somente deve aceitar o Tipo de Operação = 02                                            //
      // ------------------------------------------------------------------------------------------------------------------------------------- //
      If _xTela == 2

         If Select("T_OPERACAO") > 0
            T_OPERACAO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ADY.ADY_PROPOS,"
         cSql += "       ADY.ADY_OPORTU,"
    	 cSql += "       ADZ.ADZ_PRODUT,"
    	 cSql += "       ADZ.ADZ_TES   ,"
         cSql += "       SB1.B1_GRTRIB ,"
    	 cSql += "       SFM.FM_TIPO   ,"
    	 cSql += "       SFM.FM_TS      "
         cSql += "  FROM " + RetSqlName("ADY") + " ADY, "
         cSql += "       " + RetSqlName("ADZ") + " ADZ, "
         cSql += "	      " + RetSqlName("SFM") + " SFM, "
   	     cSql += "       " + RetSqlName("SB1") + " SB1  "
         cSql += " WHERE ADY.ADY_FILIAL = '" + Alltrim(cFilAnt)       + "'"
         cSql += "   AND ADY.ADY_OPORTU = '" + Alltrim(xOportunidade) + "'"
         cSql += "   AND ADY.D_E_L_E_T_ = ''            "
         cSql += "   AND ADZ.ADZ_FILIAL = ADY.ADY_FILIAL"
         cSql += "   AND ADZ.ADZ_PROPOS = ADY.ADY_PROPOS"
         cSql += "   AND ADZ.D_E_L_E_T_ = ''            "
         cSql += "   AND SB1.B1_COD     = ADZ.ADZ_PRODUT"
         cSql += "   AND SB1.D_E_L_E_T_ = ''            "
         cSql += "   AND SFM.FM_TS      = ADZ.ADZ_TES   "
         cSql += "   AND SFM.FM_EST     = '" + Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_EST") + "'"
         cSql += "   AND SFM.D_E_L_E_T_ = ''            "
      
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OPERACAO", .T., .T. )

         lVoltar  := .F.
         nPosicao := 0

         If T_OPERACAO->( EOF() )
         Else

            T_OPERACAO->( DbGoTop() )
         
            WHILE !T_OPERACAO->( EOF() )
         
               If Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_GRPTRIB") == "002"
                  If T_OPERACAO->FM_TIPO <> "03"
                     nPosicao := 1
                     lVoltar  := .T.
                     Exit
                  Endif
               Endif
                  
               If Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_GRPTRIB") == "003"
                  If T_OPERACAO->FM_TIPO <> "02"
                     nPosicao := 2
                     lVoltar  := .T.
                     Exit
                  Endif
               Endif
            
               T_OPERACAO->( DbSkip() )
            
            ENDDO
         Endif

         If lVoltar == .T.
            If nPosicao == 1
               MsgAlert("Atenção!"                                                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                        "O Cliente selecionado está configurado como 002 - IE ATIVA, porém, na proposta comercial "  + chr(13) + chr(10) + ;
                        "foi informado o tipo de operação = 03 onde o correto é 02."                                 + chr(13) + chr(10) + ;
                        "Você deve alterar na proposta comercial o tipo de operação para 02.")
            Else
               MsgAlert("Atenção!"                                                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                        "O Cliente selecionado está configurado como 003 - IE ISENTA, porém, na proposta comercial " + chr(13) + chr(10) + ;
                        "foi informado o tipo de operação = 02 onde o correto é 03."                                 + chr(13) + chr(10) + ;
                        "Você deve alterar na proposta comercial o tipo de operação para 03.")
            Endif

            // Fecha o botão Salvar da tela de Oportunidade caso validação estiver incorreta
            lSalvar := .F.
            oDlgA:Refresh()

         Endif
      Endif   
   
      If _xTela == 1
         cCliente := _Codigo + "." + _Loja + " - " + Alltrim(_NomeCli)
         _Imagem   := "br_branco"
      Else
         cCLiente := _Codigo
         cLojaCli := _Loja
         cNomeCli := _NomeCli
         If _Legenda == "2"
            _Imagem := "br_verde"
         Else
            _Imagem := "br_vermelho"
         Endif
         If _xTela == 2
            @ C(088),C(255) Jpeg FILE _Imagem Size C(009),C(009) PIXEL NOBORDER OF oDlgA
         Endif
      Endif
   
      // Pesquisa o vendedor e tráz como sugestão
      DbSelectArea("SA1")
      DbSetorder(1)
      If DbSeek(xFilial("SA1") + _Codigo + _Loja)
         cVendedor1 := SA1->A1_VEND
         trazvende(1, cVendedor1)
         MsUnLock()           
      Endif   

   Endif   

Return(.T.)

// Função que pesquisa o cliente informado
Static Function xbuscaCli()

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

// Função que visualiza o cadastro do cliente selecionado
Static Function xCadCliente(_Tela, _Codigo, _Loja)

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

// ------------------------------------------------------------------------------- //
// Função que salva a oportunidade em caso de Inclusão e abre a proposta comercial //
//                                                                                 // 
// Parâmetro _PorOnde = A - Pelo botão de Inclusão de Proposta Comercial           //
//                      S - Pelo Botão Salvar Oportunidade                         //
// ------------------------------------------------------------------------------- //
Static Function AbrPComercial(_Operacao, _Oportunidade, _xFilial, _PorOnde, _aAlegenda, _PropostaK )

   MsgRun("Favor Aguarde! Salvando Proposta Comercial ...", "Atenção!",{|| xAbrPComercial(_Operacao, _Oportunidade, _xFilial, _PorOnde, _aAlegenda, _PropostaK ) })

Return(.T.)

Static Function xAbrPComercial(_Operacao, _Oportunidade, _xFilial, _PorOnde, _aAlegenda, _PropostaK )
                                                                                                    
   Local cSql           := ""
   Local cMsg           := ""
   Local TContrato      := ""
   Local __Parametros   := ""
   Local cTexto         := ""
   Local xProposta      := ""
   Local cAcessos       := ""
   Local _Foi_Encerrada := .F.
   Local nContar        := 0
   Local lBxTodos       := .T. 
   Local nContaItem     := 0
   Local aRecOrc        := {}
   Local aMotivoEnc     := {}
   Local cMotivoEnc  
   Local cAcionado      := 0
   Local cPerdido       := ""
   Local cMemo50        := ""
   Local oMemo50
   Local oMemo51

   Private INCLUI
   Private ALTERA

   Private cMemo11 := ""
   Private oMemo11

   Private __Tem_Auxilio := .F. // Variável utilizada para verificar se oportunidade de venda possui solicitação de auxlio da área de projetos
   Private __Pode_Seguir := .F. // Variável que indica se questinário da solicitação de auxilio da área de projeto foi respondida ou não

   Private oDlgBol
   Private oDlgC
   Private oDlgEnc

   cFilAnt := Substr(cComboBx5,01,02)//Michel Aoki 23/09/2014
	
   If _Operacao == "A"
      INCLUI := .T.
      ALTERA := .T.

      If _PorOnde == "A"
         If Substr(_aAlegenda,01,01) == "9"
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + Chr(10) + "Você está querendo Encerrar a Oportunidade, para isso, você deve selecionar o botão Salvar Oportunidade.")
            Return(.T.)
         Endif
      Endif

   Else
      INCLUI := .F.
      ALTERA := .F.
   Endif   

   cTexto := ""
   
   // Consistência dos dados da tela antes da gravação
   If Substr(cComboBx5,01,02) == "00"
      cTexto += "Filial de inclusão não informada." + chr(13) + chr(10)
   Endif      

   If Empty(Alltrim(xOportunidade))
      cTexto += "Nº da Oportunidade não gerado." + chr(13) + chr(10)
   Endif         
   
   If Empty(Alltrim(cRevisao))
      cTexto += "Nº da Revisao não gerada." + chr(13) + chr(10)
   Endif         
   
   If Empty(cData)
      cTexto += "Data de Inclusão não informada." + chr(13) + chr(10)
   Endif         

   If Empty(cHora)
      cTexto += "Hora de Inclusão não informada." + chr(13) + chr(10)
   Endif         

   If Empty(cInicio)
      cTexto += "Data de início não informada." + chr(13) + chr(10)
   Endif         

   If Empty(Alltrim(cDescricao))
      cTexto += "Descricao da oportunidade não informada." + chr(13) + chr(10)
   Endif         

   If Empty(Alltrim(cCliente))
      cTexto += "Cliente da oportunidade não informado." + chr(13) + chr(10)
   Endif         

   If Empty(Alltrim(cVendedor1))
      cTexto += "Vendedor 1 não informado." + chr(13) + chr(10)
   Endif         

   If cMoeda == 0
      cTexto += "Moeda não informada." + chr(13) + chr(10)
   Else
      If cMoeda <> 1 .And. cMoeda <> 2
         cTexto += "Moeda informada é inválida. Tipo aceitos: 1 - R$ ou 2 - US$" + chr(13) + chr(10)      
      Endif
   Endif         
   
   If _Operacao == "V"
   Else
      If cVerba == 0
         cTexto += "Verba não informada." + chr(13) + chr(10)
      Endif         
   Endif

   // Abre tela de Inconsistência
   If !Empty(Alltrim(cTexto))

      DEFINE MSDIALOG oDlgC TITLE "Inconsistência para Gravação" FROM C(178),C(181) TO C(461),C(713) PIXEL

	  @ C(023),C(169) Say "INCONSISTÊNCIA PARA GRAVAÇÃO"                                       Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   	  @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"                                              Size C(130),C(026)                 PIXEL NOBORDER OF oDlgC
	  @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO                                               Size C(258),C(001)                 PIXEL OF oDlgC
	  @ C(034),C(005) Say "Inconsistências encontradas para gravação da oportunidade de venda" Size C(169),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
	  @ C(043),C(005) GET oMemo2 Var cTexto MEMO                                               Size C(255),C(081)                 PIXEL OF oDlgC
	  @ C(125),C(223) Button "Voltar"                                                          Size C(037),C(012)                 PIXEL OF oDlgC ACTION( oDlgC:End() )

      ACTIVATE MSDIALOG oDlgC CENTERED 

      Return(.T.)
      
   Endif

   // I N C L U S Ã O 
   If _Operacao == "I"
   
      BEGIN TRANSACTION
      
      // Inclui a Oportunidade na Tabela AD1
      aArea := GetArea()
      dbSelectArea("AD1")
      RecLock("AD1",.T.)
      AD1_FILIAL := Substr(cComboBx5,01,02)
      AD1_NROPOR := xOportunidade
      AD1_REVISA := cRevisao
      AD1_DESCRI := cDescricao
      AD1_DTINI  := cInicio

      If Substr(cComboBx6,01,01) == "9"
         AD1_DTFIM  := Date()
      Endif   

      AD1_VEND   := cVendedor1
      AD1_VEND2  := cVendedor2
      AD1_DATA   := cData
      AD1_HORA   := cHora
      AD1_CODCLI := cCliente
      AD1_LOJCLI := cLojaCli
      AD1_MOEDA  := cMoeda
      AD1_PROVEN := "000001"
      AD1_STAGE  := "000001"
      AD1_PRIOR  := "1"
      AD1_STATUS := Substr(cComboBx6,01,01)
      AD1_USER   := __CUSERID
      AD1_VERBA  := cVerba
      AD1_MODO   := "1"
      AD1_COMIS1 := cComissao1
      AD1_COMIS2 := cComissao2
      AD1_ZTIP   := Substr(cComboBx7,01,01)
      AD1_VISTEC := "2"
      AD1_SITVIS := "4"

      // Carrega a string __Parametros com os dados da proposta de locação
      __Parametros := ""
      For nContar = 1 to Len(aLocacao)
          __parametros := __parametros + aLocacao[nContar] + "|"
      Next nContar              

      AD1_ZLOC   := __Parametros

      // Cria variáveis de memória com a tabela AD1 - Oportunidade Comercial
      RegToMemory( "AD1" ,  .T. , .T. )

      // Carrega o conteúdo das variáveis criadas
      M->AD1_FILIAL := Substr(cComboBx5,01,02)
      M->AD1_NROPOR := xOportunidade
      M->AD1_REVISA := cRevisao
      M->AD1_DESCRI := cDescricao
      M->AD1_DTINI  := cInicio
      M->AD1_DTFIM  := cTermino
      M->AD1_VEND   := cVendedor1
      M->AD1_VEND2  := cVendedor2
      M->AD1_DATA   := cData
      M->AD1_HORA   := cHora
      M->AD1_CODCLI := cCliente
      M->AD1_LOJCLI := cLojaCli
      M->AD1_MOEDA  := cMoeda
      M->AD1_PROVEN := "000001"
      M->AD1_STAGE  := "000001"
      M->AD1_PRIOR  := "1"
      M->AD1_STATUS := Substr(cComboBx6,01,01)
      M->AD1_USER   := __CUSERID
      M->AD1_VERBA  := cVerba
      M->AD1_MODO   := "1"
      M->AD1_COMIS1 := cComissao1
      M->AD1_COMIS2 := cComissao2
      M->AD1_ZTIP   := Substr(cComboBx7,01,01)
      M->AD1_ZLOC   := __Parametros
      M->AD1_VISTEC := "2"
      M->AD1_SITVIS := "4"

      MsUnLock()
      
      xProposta := GetSXENum( "ADY", "ADY_PROPOS" ) 

      // Inclui a proposta Comercial na tabela ADY
      aArea := GetArea()
      dbSelectArea("ADY")
      RecLock("ADY",.T.)
      ADY_FILIAL := Substr(cComboBx5,01,02)
      ADY_PROPOS := xProposta
      ADY_OPORTU := xOportunidade
      ADY_REVISA := cRevisao
      ADY_ENTIDA := "1"
      ADY_CODIGO := cCliente
      ADY_LOJA   := cLojaCli
      ADY_TABELA := "500"         
      ADY_STATUS := "A"
      ADY_DATA   := cData
      ADY_VAL    := cData
      ADY_FORMA  := "1"
      ADY_PREVIS := "01"
      ADY_CLIENT := cCliente
      ADY_LOJENT := cLojaCli
      ADY_VEND   := cVendedor1
      ADY_TPCONT := "1"
      ADY_VISTEC := "2"
      ADY_SITVIS := "4"
      ADY_QEXAT  := "N"
      MsUnLock()
      
      // Confirma o número alocado através do último comando GETSXENUM()
      ConfirmSX8(.T.) // Se o parâmetro for passado como (.T.) verifica se o número já existe na base de dados.
      
      END TRANSACTION
      
      // ---------------------------------------------------------------------------------------------------------------------------------------- //
      // Campos da Proposta Comercial que não são gravados nesta rotina                                                                           //
      // ADY_TRANSP, ADY_TPFRET, ADY_PARAQ, ADY_ENTREG, ADY_FRETE, ADY_OC, ADY_FCOR, ADY_TSRV, ADY_FORMA, ADY_ADM, ADY_ORCAME, ADY_OBSP, ADY_OBSI //
      // ---------------------------------------------------------------------------------------------------------------------------------------- //

      // Abre a tela da proposta comercial incluída
      DbSelectArea("ADY")
      DbSetorder(1)
      DbSeek(Substr(cComboBx5,01,02) + xProposta)
   
     A600Mnt("ADY", ADY->( Recno() ), 4)
  
      // Atualiza o pecentual de comissão na tabela SCK para que o Sistema leve este percentual para o pedido de venda
      If Select("T_COMISSAO") > 0
         T_COMISSAO->( dbCloseArea() )
      EndIf
      
      cSql := "SELECT A.ADY_FILIAL,"
      cSql += "       A.ADY_PROPOS,"
      cSql += "       A.ADY_OPORTU,"
      cSql += "       B.*          "
      cSql += "  FROM " + RetSqlName("ADY") + " A, " 
      cSql += "       " + RetSqlName("ADZ") + " B  " 
      cSql += " WHERE A.ADY_FILIAL = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
      cSql += "   AND A.ADY_OPORTU = '" + Alltrim(xOportunidade)           + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
      cSql += "   AND A.ADY_FILIAL = B.ADZ_FILIAL"
      cSql += "   AND A.ADY_PROPOS = B.ADZ_PROPOS"
      cSql += "   AND B.D_E_L_E_T_ = ''          "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

      If !T_COMISSAO->( EOF() )

         WHILE !T_COMISSAO->( EOF() )
         
            DbSelectArea("SCK")
            DbSetorder(5)
            If DbSeek(T_COMISSAO->ADY_FILIAL + T_COMISSAO->ADY_PROPOS + T_COMISSAO->ADZ_ITEM)
               RecLock("SCK",.F.)            
               CK_COMIS1 := T_COMISSAO->ADZ_COMIS1
               CK_COMIS2 := T_COMISSAO->ADZ_COMIS2
               CK_ENTREG := Ctod(Substr(T_COMISSAO->ADZ_DTENTR,07,02) + "/" + Substr(T_COMISSAO->ADZ_DTENTR,05,02) + "/" + Substr(T_COMISSAO->ADZ_DTENTR,01,04))
               MsUnLock()            
            Endif
            
            T_COMISSAO->( DbSkip() )
            
         ENDDO
         
      Endif

      // Envia para a função que verifica se há solicitação de auxílio ao departamento de projetos pendente de abertura da tarefa no AtechPortal
      VerAberturaAuxilio(Alltrim(xOportunidade), Alltrim(cCliente), Alltrim(cLojaCli))

   Endif

   // A L T E R A Ç Ã O
   If _Operacao == "A"

      // Envia para a função que verifica se há solicitação de auxílio ao departamento de projetos pendente de abertura da tarefa no AtechPortal
      If Substr(cComboBx6,01,01) == "2" .Or. Substr(cComboBx6,01,01) == "3"
      Else
         VerAberturaAuxilio(Alltrim(xOportunidade), Alltrim(cCliente), Alltrim(cLojaCli))
      Endif   

      // Se foi solicitado encerramento de oportunidade, verifica primeiro se existe proposta com informação de produtos.
      // Caso não encontre os produtos da proposta comercial, não permite o encerramento da mesma.
      If _PorOnde == "S"

         If Substr(cComboBx6,01,01) == "9"

            // ---------------------------------------------------------------------------------------------- //
            // Antes de encerrar a oportunidade de venda, realiza uma consistência dos dados                  //
            // Se houver alguma inconsistência, o processo de encerramento da oportunidade não será efetivado //
            // até que o vendedor resolva as pendêencias apresentadas.                                        //
            // ---------------------------------------------------------------------------------------------- //

            // Consiste Condição de Pagamento Negociável Valor
            If U_AUTOM341(2, Alltrim(Substr(cComboBx5,01,02)) + "|" + xOportunidade + "|") == .F.
               Return(.T.)
            Endif

            // Consiste dados do cadastro do cliente da oportundiade de venda
            If U_AUTOM341(3, cCliente + "|" + cLojaCli + "|") == .F.
               Return(.T.)
            Endif

            // Consiste NCM dos Produtos da Proposta Comercial
            If U_AUTOM341(4, Alltrim(Substr(cComboBx5,01,02)) + "|" + xOportunidade + "|") == .F.
               Return(.T.)
            Endif

         Endif

         // Em caso de oportunidade Suspensa
         If Substr(cComboBx6,01,01) == "3"

            // Envia para a função que faz a 3ª pergunta em caso de oportunidade com solicitação de auxilio ao setor projetos
            __Tem_Auxilio := .F.
            __Pode_Seguir := .F.

            VerificaAuxilio(xOportunidade, cCliente, cLojaCli, 3)

            If __Tem_Auxilio == .T.

               If __Pode_Seguir == .F.
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Questionário não respondido." + chr(13) + chr(10) + "Encerramento não permitido.")
                  Return(.T.)
               Endif
               
            Endif   
            
         Endif

         // Se oportunidade Perdida, abre janela solicitando o motivo do encerramento. 
         If Substr(cComboBx6,01,01) == "2"

            // Envia para a função que faz a 3ª pergunta em caso de oportunidade com solicitação de auxilio ao setor projetos
            __Tem_Auxilio := .F.
            __Pode_Seguir := .F.

            VerificaAuxilio(xOportunidade, cCliente, cLojaCli, 3)

            If __Tem_Auxilio == .T.

               If __Pode_Seguir == .F.
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Questionário não respondido." + chr(13) + chr(10) + "Encerramento não permitido.")
                  Return(.T.)
               Endif
               
            Endif   

            // Verifica se tabela de motivos está preenchida
            If Select("T_MOTIVOS") > 0
               T_MOTIVOS->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT UN_ENCERR,"
            cSql += "       UN_DESC   "
            cSql += "  FROM " + RetSqlName("SUN")
            cSql += " WHERE UN_FILIAL  = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
            cSql += "   AND D_E_L_E_T_ = ''" 

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVOS", .T., .T. )

            If T_MOTIVOS->( EOF() )
               MsgAlert("Atenção! Tabela de motivos de encrramento de Oportunidades está vazia. Entre em contato com o Administrador do Sistema.")
               Return(.T.)
            Endif
            
            aMotivosEnc := {}

            T_MOTIVOS->( DbGoTop() )
            
            WHILE !T_MOTIVOS->( EOF() )
               aAdd(aMotivoEnc, T_MOTIVOS->UN_ENCERR + " - " + T_MOTIVOS->UN_DESC )
               T_MOTIVOS->( DbSkip() )
            ENDDO      

            DEFINE MSDIALOG oDlgEnc TITLE "Status de Encerramento" FROM C(178),C(181) TO C(491),C(600) PIXEL
  
    	    @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgEnc

  	        @ C(032),C(002) GET oMemo50 Var cMemo50 MEMO      Size C(201),C(001) PIXEL OF oDlgEnc
  	        
	        @ C(036),C(005) Say "Motivo do Encerramento"    Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnc
	        @ C(059),C(005) Say "Descrição do Encerramento" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnc
	        	        
	        @ C(045),C(005) ComboBox cMotivoEnc Items aMotivoEnc Size C(200),C(010) PIXEL OF oDlgEnc

	        @ C(069),C(005) GET oMemo51 Var cPerdido  MEMO Size C(200),C(067) PIXEL OF oDlgEnc

	        @ C(140),C(129) Button "O K"      Size C(037),C(012) PIXEL OF oDlgEnc ACTION( cAcionado := 1, oDlgEnc:End() )
	        @ C(140),C(168) Button "Cancelar" Size C(037),C(012) PIXEL OF oDlgEnc ACTION( cAcionado := 2, oDlgEnc:End() )

            ACTIVATE MSDIALOG oDlgEnc CENTERED 

            If cAcionado == 1

               If Empty(Alltrim(cMotivoEnc))
                  MsgAlert("Motivo do Encerramento não informado.")
                  Return(.T.)
               Endif
                                    
               If Empty(Alltrim(cPerdido))
                  MsgAlert("Descrição do Encerramento não informado.")
                  Return(.T.)
               Endif
               
            Else

               MsgAlert("Atenção! Encerramento por perda da oportunidade foi cancelada.")
                           
               Return(.T.)
              
            Endif
            
         Endif

         // Encerramento da Oportunidade de Venda
         If Substr(cComboBx6,01,01) == "9"
         
            // Consistência antes do Encerramento
            If Select("T_TEMPROPOSTA") > 0
               T_TEMPROPOSTA->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.ADY_FILIAL,"
            cSql += "       A.ADY_PROPOS,"
            cSql += "       A.ADY_OPORTU"
            cSql += "  FROM " + RetSqlName("ADY") + " A, "
            cSql += "       " + RetSqlName("ADZ") + " B  "
            cSql += " WHERE A.ADY_FILIAL = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
            cSql += "   AND A.ADY_OPORTU = '" + Alltrim(xOportunidade)           + "'"
            cSql += "   AND A.D_E_L_E_T_ = ''"
            cSql += "   AND A.ADY_FILIAL = B.ADZ_FILIAL"
            cSql += "   AND A.ADY_PROPOS = B.ADZ_PROPOS"
            cSql += "   AND B.D_E_L_E_T_ = ''"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEMPROPOSTA", .T., .T. )

            If T_TEMPROPOSTA->( EOF() )
               MsgAlert("Proposta Comercial sem informação de produtos. Verifique antes de encerrá-la.")
               Return(.T.)
            Endif

            // Verifica se houve informação de TES nos produtos. Isso é necessario pois a proposta comercial pode ter sido incluída pela
            // integração da Loja Virtual.
            If Select("T_TEMTES") > 0
               T_TEMTES->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.ADY_PROPOS,"
            cSql += "       A.ADY_CODIGO,"
 	        cSql += "       A.ADY_LOJA  ,"
            cSql += "       B.ADZ_TES    "
            cSql += "  FROM " + RetSqlName("ADY") + " A, "
            cSql += "       " + RetSqlName("ADZ") + " B  "
            cSql += " WHERE A.ADY_FILIAL = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
            cSql += "   AND A.ADY_OPORTU = '" + Alltrim(xOportunidade)           + "'"
            cSql += "    AND A.D_E_L_E_T_ = ''"
            cSql += "    AND B.ADZ_FILIAL = A.ADY_FILIAL"
            cSql += "    AND B.ADZ_PROPOS = A.ADY_PROPOS"
            cSql += "    AND B.D_E_L_E_T_ = ''"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEMTES", .T., .T. )

            If T_TEMTES->( EOF() )
               MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Proposta Comercial para esta oportunidade não localizada." + chr(13) + chr(10) + "Verifique!")
               Return(.T.)
            Endif
            
            T_TEMTES->( DbGoTop() )
            
            lTemTes := .T.

            WHILE T_TEMTES->( EOF() )
               
               If Empty(Alltrim(T_TEMTES->ADZ_TES))
                  lTesTes := .F.
                  Exit
               Endif
               
               T_TEMTES->( DbSkip() )
               
            ENDDO
            
            If lTemTes == .F.
               MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Proposta Comercial sem informação de Tipo de Saída/TES." + chr(13) + chr(10) + "Verifique Proposta Comercial.")
               Return(.T.)
            Endif
                  
            // Verifica se existe registro da oprotunidade/proposta comercial na tabela SCJ (Orçamento)
            // Se existir, verifica se o código do cliente está coerente entre as tabelas de proposta e orçamento            
            If Select("T_TEMORCAMENTO") > 0
               T_TEMORCAMENTO->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.ADY_PROPOS,"
            cSql += "       A.ADY_CODIGO,"
   	        cSql += "       A.ADY_LOJA  ,"
         	cSql += "       B.CJ_CLIENTE,"
	        cSql += "       B.CJ_LOJA   ,"
	        cSql += "       B.CJ_CLIENT ,"
	        cSql += "       B.CJ_LOJAENT "
            cSql += "  FROM " + RetSqlName("ADY") + " A, "
            cSql += "       " + RetSqlName("SCJ") + " B  "
            cSql += " WHERE A.ADY_FILIAL = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
            cSql += "   AND A.ADY_OPORTU = '" + Alltrim(xOportunidade)           + "'"
            cSql += "   AND A.D_E_L_E_T_ = ''"
            cSql += "   AND B.CJ_FILIAL  = A.ADY_FILIAL"
            cSql += "   AND B.CJ_PROPOST = A.ADY_PROPOS"
            cSql += "   AND B.D_E_L_E_T_ = ''"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEMORCAMENTO", .T., .T. )

            If T_TEMORCAMENTO->( EOF() )
               cmsg := ""
               cmsg := "Atenção!" + chr(13) + chr(10) + Chr(13) + chr(10)
               cmsg += "Registro de Orçamento para a Proposta Comercial inexistente na base de dados do Sistema." + chr(13) + chr(10) 
               cmsg += "Selecione a opção de Proposta Comercial e salve-a novamente." + chr(13) + chr(10) 
               cmsg += "Isso fará com que o Sistema gere o registro na tabela de orçamento. " + chr(13) + chr(10) 
               cmsg += "Após este procedimento, tente encerrar novamente a oprotunidade." + chr(13) + chr(10) 
               cmsg += "Caso esta mensagem persistir, entre em contato com a área de desenvolvimento para análise." + chr(13) + chr(10) 
               MsgAlert(cmsg)
               Return(.T.)
            Else
            
               If (T_TEMORCAMENTO->ADY_CODIGO + T_TEMORCAMENTO->ADY_LOJA) <> (T_TEMORCAMENTO->CJ_CLIENTE + T_TEMORCAMENTO->CJ_LOJA)

                  DbSelectArea("SCJ")
                  DbSetOrder(4)
                  If DbSeek(xfilial("SCJ") + T_TEMORCAMENTO->ADY_PROPOS )
                     RecLock("SCJ",.F.)
                     SCJ->CJ_CLIENTE := T_TEMORCAMENTO->ADY_CODIGO 
                     SCJ->CJ_LOJA    := T_TEMORCAMENTO->ADY_LOJA
                     SCJ->CJ_CLIENT  := T_TEMORCAMENTO->ADY_CODIGO 
                     SCJ->CJ_LOJAENT := T_TEMORCAMENTO->ADY_LOJA
                     MsUnLock()              
                  Endif

               Endif
                  
               If (T_TEMORCAMENTO->ADY_CODIGO + T_TEMORCAMENTO->ADY_LOJA) <> (T_TEMORCAMENTO->CJ_CLIENT + T_TEMORCAMENTO->CJ_LOJAENT)

                  DbSelectArea("SCJ")
                  DbSetOrder(4)
                  If DbSeek(xfilial("SCJ") + T_TEMORCAMENTO->ADY_PROPOS )
                     RecLock("SCJ",.F.)
                     SCJ->CJ_CLIENTE := T_TEMORCAMENTO->ADY_CODIGO 
                     SCJ->CJ_LOJA    := T_TEMORCAMENTO->ADY_LOJA
                     SCJ->CJ_CLIENT  := T_TEMORCAMENTO->ADY_CODIGO 
                     SCJ->CJ_LOJAENT := T_TEMORCAMENTO->ADY_LOJA
                     MsUnLock()              
                  Endif

               Endif

            Endif

            // Verifica se o cliente da oportunidade é o cliente DASS NORDESTE CALÇADOS.
            // Se for este cliente, verifica se a ordem de compra e sequencia do produto foram informados.
            // Se não, não permite o encerramento da oprotunidade de venda
            If cCliente == "008752"

               If Select("T_OCOMPRA") > 0
                  T_OCOMPRA->( dbCloseArea() )
               EndIf
            
               cSql := "SELECT ADZ.ADZ_FILIAL,"
               cSql += "       ADZ.ADZ_PROPOS," 
       	       cSql += "       ADZ.ADZ_ORDC  ,"
    	       cSql += "       ADZ.ADZ_ORDA  ,"
    	       cSql += "       ADZ.ADZ_ORDS   "
               cSql += "  FROM " + RetSqlName("ADZ") + " ADZ, "
               cSql += "       " + RetSqlName("ADY") + " ADY  "
               cSql += " WHERE ADZ.D_E_L_E_T_ = ''"
               cSql += "   AND ADY.ADY_FILIAL = ADZ.ADZ_FILIAL "
               cSql += "   AND ADY.ADY_PROPOS = ADZ.ADZ_PROPOS "
               cSql += "   AND ADY.D_E_L_E_T_ = ''             "
               cSql += "   AND ADY.ADY_FILIAL = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
               cSql += "   AND ADY.ADY_OPORTU = '" + Alltrim(xOportunidade)           + "'"

               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCOMPRA", .T., .T. )

               If T_OCOMPRA->( EOF() )
                  MsgAlert("Atenção!" + chr(13) + chr(13) + "Oportunidade de venda com problema de encerramento pela validação do nº da ordem de compra e sequencial de produto.")
                  Return(.T.)
               Endif
            
               lTemOrdem := .T.
               WHILE !T_OCOMPRA->( EOF() )
                  If Empty(Alltrim(T_OCOMPRA->ADZ_ORDC))
                     lTemOrdem := .F.
                     Exit
                  Endif
                  If Empty(Alltrim(T_OCOMPRA->ADZ_ORDS))
                     lTemOrdem := .F.
                     Exit
                  Endif
                  T_OCOMPRA->( DbSkip() )
               ENDDO
            
               If !lTemOrdem   
                  MsgAlert("Atenção!" + chr(13) + chr(13) + "Não foram informados os nº das ordens de compra ou sequenciais de ítens na proposta comercial do cliente. Verifique!") 
                  Return(.T.)
               Endif

            Endif
               
         Endif

      Endif         

      BEGIN TRANSACTION

      // Altera a Oportunidade na Tabela AD1
      aArea := GetArea()
      dbSelectArea("AD1")
      DbSetOrder(1)
      If DbSeek( Substr(cComboBx5,01,02) + xOportunidade + cRevisao)
         RecLock("AD1",.F.)
         AD1_DESCRI := cDescricao
         AD1_DTINI  := cInicio

         If Substr(cComboBx6,01,01) == "9"
            AD1_DTFIM  := Date()
         Endif   

         AD1_VEND   := cVendedor1
         AD1_VEND2  := cVendedor2
         AD1_DATA   := cData
         AD1_HORA   := cHora
         AD1_CODCLI := cCliente
         AD1_LOJCLI := cLojaCli
         AD1_MOEDA  := cMoeda
         AD1_PROVEN := "000001"
         AD1_STAGE  := "000001"
         AD1_PRIOR  := "1"
         AD1_FCS    := cFCS
         AD1_FCI    := cFCI
         AD1_STATUS := Substr(cComboBx6,01,01)
         AD1_USER   := __CUSERID
         AD1_VERBA  := cVerba
         AD1_MODO   := "1"
         AD1_COMIS1 := cComissao1
         AD1_COMIS2 := cComissao2
         AD1_ZTIP   := Substr(cComboBx7,01,01)
         
         // Carrega a string __Parametros com os dados da proposta de locação
         __Parametros := ""
         For nContar = 1 to Len(aLocacao)
             __parametros := __parametros + aLocacao[nContar] + "|"
         Next nContar              

         AD1_ZLOC   := __Parametros

         // Em caso de Oportunidade perdida, grava o código do motivo e descrição da perda da oportunidade (estatística)
         If Substr(cComboBx6,01,01) == "2"
            AD1_ENCERR := Substr(cMotivoEnc,01,06)
            AD1_MEMENC := Alltrim(cPerdido)
         Endif

         // Cria variáveis de memória com a tabela AD1 - Oportunidade Comercial
         RegToMemory( "AD1" ,  .T. , .T. )

         // Carrega o conteúdo das variáveis criadas
         M->AD1_FILIAL := Substr(cComboBx5,01,02)
         M->AD1_NROPOR := xOportunidade
         M->AD1_REVISA := cRevisao
         M->AD1_DESCRI := cDescricao
         M->AD1_DTINI  := cInicio
         M->AD1_DTFIM  := cTermino
         M->AD1_VEND   := cVendedor1
         M->AD1_VEND2  := cVendedor2
         M->AD1_DATA   := cData
         M->AD1_HORA   := cHora
         M->AD1_CODCLI := cCliente
         M->AD1_LOJCLI := cLojaCli
         M->AD1_MOEDA  := cMoeda
         M->AD1_PROVEN := "000001"
         M->AD1_STAGE  := "000001"
         M->AD1_PRIOR  := "1"
         M->AD1_STATUS := Substr(cComboBx6,01,01)
         M->AD1_USER   := __CUSERID
         M->AD1_VERBA  := cVerba
         M->AD1_MODO   := "1"
         M->AD1_COMIS1 := cComissao1
         M->AD1_COMIS2 := cComissao2
         M->AD1_ZTIP   := Substr(cComboBx7,01,01)
         M->AD1_ZLOC   := __Parametros

         MsUnLock()

         // Altera a proposta Comercial na tabela ADY
         aArea := GetArea()
         dbSelectArea("ADY")
         DbSetOrder(2)   
         If DbSeek( Substr(cComboBx5,01,02) + xOportunidade)
            RecLock("ADY",.F.)
            ADY_CODIGO := cCliente
            ADY_LOJA   := cLojaCli
            MsUnLock()
         Endif   

         // Altera o código do Cliente na tabela SCJ. Isso serve para manter a integridade entre a porposta e tabela do orçamento.
         dbSelectArea("SCJ")
         DbSetOrder(5)
         If DbSeek(Alltrim(Substr(cComboBx5,01,02)) + xOportunidade)
            While !SCJ->(Eof()) .AND. SCJ->CJ_FILIAL == Alltrim(Substr(cComboBx5,01,02)) .AND. SCJ->CJ_NROPOR == xOportunidade
               If (SCJ->CJ_PROPOST == ADY->ADY_PROPOS) 
                  If SCJ->CJ_STATUS == "A"
                     Reclock("SCJ",.F.)
                     SCJ->CJ_CLIENTE := cCliente
                     SCJ->CJ_LOJA    := cLojaCli
                     SCJ->CJ_CLIENT  := cCliente
                     SCJ->CJ_LOJAent := cLojaCli
                     SCJ->( MsUnlock() )
                  EndIf
               EndIf
               SCJ->(DbSkip())
            Enddo
         Endif
         
         // Altera o código do Cliente na tabela SCK. Isso serve para manter a integridade entre a porposta e tabela do orçamento.
         If Select("T_ALTERACLI") > 0
            T_ALTERACLI->( dbCloseArea() )
         EndIf
      
         cSql := "SELECT A.ADY_FILIAL,"
         cSql += "       A.ADY_PROPOS,"
         cSql += "       A.ADY_OPORTU,"
         cSql += "       B.*          "
         cSql += "  FROM " + RetSqlName("ADY") + " A, " 
         cSql += "       " + RetSqlName("ADZ") + " B  " 
         cSql += " WHERE A.ADY_FILIAL = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
         cSql += "   AND A.ADY_OPORTU = '" + Alltrim(xOportunidade)           + "'"
         cSql += "   AND A.D_E_L_E_T_ = ''"
         cSql += "   AND A.ADY_FILIAL = B.ADZ_FILIAL"
         cSql += "   AND A.ADY_PROPOS = B.ADZ_PROPOS"
         cSql += "   AND B.D_E_L_E_T_ = ''          "
      
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALTERACLI", .T., .T. )

         If !T_ALTERACLI->( EOF() )

            WHILE !T_ALTERACLI->( EOF() )
         
               DbSelectArea("SCK")
               DbSetorder(5)
               If DbSeek(T_ALTERACLI->ADY_FILIAL + T_ALTERACLI->ADY_PROPOS + T_ALTERACLI->ADZ_ITEM)
                  RecLock("SCK",.F.)            
                  CK_CLIENTE := cCliente
                  CK_LOJA    := cLojaCli
                  MsUnLock()            
               Endif
            
               T_ALTERACLI->( DbSkip() )
            
            ENDDO
         
         Endif

      Endif
      
      // Abre a tela da proposta comercial Alterada
      If _PorOnde == "A"
         DbSelectArea("ADY")
         DbSetorder(2)
         DbSeek(Substr(cComboBx5,01,02) + xOportunidade)
         A600Mnt("ADY", ADY->( Recno() ), 4 )

         // Atualiza o pecentual de comissão na tabela SCK para que o Sistema leve este percentual para o pedido de venda
         If Select("T_COMISSAO") > 0
            T_COMISSAO->( dbCloseArea() )
         EndIf
      
         cSql := "SELECT A.ADY_FILIAL,"
         cSql += "       A.ADY_PROPOS,"
         cSql += "       A.ADY_OPORTU,"
         cSql += "       B.*          "
         cSql += "  FROM " + RetSqlName("ADY") + " A, " 
         cSql += "       " + RetSqlName("ADZ") + " B  " 
         cSql += " WHERE A.ADY_FILIAL = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
         cSql += "   AND A.ADY_OPORTU = '" + Alltrim(xOportunidade)           + "'"
         cSql += "   AND A.D_E_L_E_T_ = ''"
         cSql += "   AND A.ADY_FILIAL = B.ADZ_FILIAL"
         cSql += "   AND A.ADY_PROPOS = B.ADZ_PROPOS"
         cSql += "   AND B.D_E_L_E_T_ = ''          "
      
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

         If !T_COMISSAO->( EOF() )

            WHILE !T_COMISSAO->( EOF() )
         
               DbSelectArea("SCK")
               DbSetorder(5)
               If DbSeek(T_COMISSAO->ADY_FILIAL + T_COMISSAO->ADY_PROPOS + T_COMISSAO->ADZ_ITEM)
                  RecLock("SCK",.F.)            
                  CK_COMIS1 := T_COMISSAO->ADZ_COMIS1
                  CK_COMIS2 := T_COMISSAO->ADZ_COMIS2
                  CK_ENTREG := Ctod(Substr(T_COMISSAO->ADZ_DTENTR,07,02) + "/" + Substr(T_COMISSAO->ADZ_DTENTR,05,02) + "/" + Substr(T_COMISSAO->ADZ_DTENTR,01,04))
                  CK_PRUNIT := 0 && Zera o preço unitário vindo da tabela de preço para evitar problema de dar desconto em nota fiscal
                  MsUnLock()            
               Endif
            
               T_COMISSAO->( DbSkip() )
            
            ENDDO
         
         Endif

      ElseIf _PorOnde == "S"

         If Substr(cComboBx6,01,01) == "9"

            // Envia para a função que verifica se a oportunidade, proposta comercial possui solicitação de auxilio da área de projetos.
            // Se existir vínculo, abre tela de pergunta e respostas
            __Tem_Auxilio := .F.
            __Pode_Seguir := .F.

            VerificaAuxilio(xOportunidade, cCliente, cLojaCli, 1)

            If __Tem_Auxilio == .T.

               If __Pode_Seguir == .F.
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Questionário não respondido." + chr(13) + chr(10) + "Encerramento não permitido.")
                  Return(.T.)
               Endif
               
            Endif   
      
            // Inicializa os array aHeader5 e aCols5
            aHeader5 := {}
            aCols5   := {}

            // Encerra oportunidade e cria o pedido
            If !Ft300ADJFG( 4, @aHeader5, @aCols5, xOportunidade , cRevisao, {}, .F.)  &&, T_MOEDAS->ADZ_MOEDA)
               Return(.T.)
            Endif

            oGetDad5 := MsNewGetDados():New(10,10,10,10,GD_INSERT+GD_UPDATE+GD_DELETE,{||.T.},,"+ADJ_ITEM",,,,,,,oDlgA,aHeader5,aCols5)
            oGetDad5:oBrowse:lDisablePaint := .T.
            oGetDad5:oBrowse:lVisible := .F.

            A300ChkPro(oGetDad5, @cNumProposta)
               
            // Indica se todos os orcamentos serao baixados
            lBxTodos  := .T. 

            // Array para armazenar os RECNOS dos orçamentos                                                                   
            aRecOrc := {}

            // Realiza a baixa dos orçamentos de uma mesma proposta. (verificar no CJ_STATUS se já está fazendo)
            SCJ->(DbSetOrder(5)) // CJ_FILIAL+CJ_PROPOST
            SCJ->(DbSeek(Alltrim(Substr(cComboBx5,01,02)) + xOportunidade))

            While !SCJ->(Eof()) .AND. SCJ->CJ_FILIAL == Alltrim(Substr(cComboBx5,01,02)) .AND. SCJ->CJ_NROPOR == xOportunidade
               If (SCJ->CJ_PROPOST == ADY->ADY_PROPOS) 
                  If SCJ->CJ_STATUS == "A"
                     // Aqui guardo o RECNO do CJ para posicionar depois na hora de baixar o orçamento e criar o pedido de vendas
                     AAdd(aRecOrc,SCJ->(Recno())) 
                     Reclock("SCJ",.F.)
                     SCJ->CJ_STATUS := "F"
                     SCJ->( MsUnlock() )
                  Else
                     lBxTodos := .F.
                  EndIf
               EndIf
               SCJ->(DbSkip())
            Enddo

            // Pega a posição da coluna ADJ_PROPOS do aHeader5
            nPosProp := aScan( aHeader5, { |x| AllTrim(x[2]) == "ADJ_PROPOS" } )

            // Realiza o cancelamento dos orçamentos de outras propostas da mesma oportunidade.
            For nContar := 1 To Len(aCols5)

                If !Empty(aCols5[nContar,nPosProp]) .AND. aCols5[nContar,nPosProp] <> ADY->ADY_PROPOS

                   SCJ->(DbSetOrder(4)) //CJ_FILIAL+CJ_PROPOST
                   SCJ->(DbSeek(Alltrim(Substr(cComboBx5,01,02)) + aCols5[nContar,nPosProp]))
                               
                   While !SCJ->(Eof()) .AND. SCJ->CJ_FILIAL == Alltrim(Substr(cComboBx5,01,02)) .AND. SCJ->CJ_PROPOST == aCols5[nContar,nPosProp]
                      If SCJ->CJ_STATUS == "A"
                         Reclock("SCJ",.F.)
                         SCJ->CJ_STATUS := "C"
                         SCJ->( MsUnlock() )
                      EndIf
                      SCJ->(DbSkip())
                   Enddo

                Endif
            Next nContar

            cCodCliente := ADY->ADY_CODIGO   && M->AD1_CODCLI
            cLojCliente := ADY->ADY_LOJA     && M->AD1_LOJCLI

            // Atualiza os dados na tabela AD1
            SCJ->(DbSetOrder(4)) 
            If SCJ->(DbSeek(xFilial("SCJ")+cNumProposta))
               RecLock("AD1",.F.)
               AD1->AD1_PROPOS := cNumProposta
               M->AD1_PROPOS   := cNumProposta
               AD1_NUMORC      := SCJ->CJ_NUM
               MsUnLock()  
            Endif   

            If lBxTodos .AND. !Empty(cCodCliente)

               For nContar := 1 to Len(aRecOrc)

                   SCJ->(DbGoTo(aRecOrc[nContar]))
                   If SCJ->CJ_CLIENTE <> cCodCliente
                      RecLock("SCJ",.F.)
                      SCJ->CJ_CLIENTE := cCodCliente
                      SCJ->CJ_LOJA    := cLojCliente
                      MsUnLock()
                   EndIf

                   MaBxOrc(SCJ->CJ_NUM,.F.,.F.,.T.,.F.)

                   _Foi_Encerrada := .T.

                   // Envia para o Ponto de Entrada da gravação da proposta comercial
                   U_FT300GRA()

               Next nCntFor

            EndIf

            // Caso for uma proposta comercial de locação, gera o contrato no módulo de contrato
            If Substr(cComboBx7,01,01) == "2"       
            
               // Captura o código do tipo de movimento para gravação conforme a Empresa/Filial logada
               For nContar = 1 to Len(aTipoC)
                   If Alltrim(aTipoC[nContar,02]) == Alltrim(cFilAnt)
                      TContrato := aTipoC[nContar,03]
                      Exit
                   Endif
               Next nContar

               // Captura o próximo código de contrato                                                                                                
               nProximoContrato := GetSXENum( "CN9", "CN9_NUMERO" ) 

               // Grava o cabeçalho do Contrato
               aArea := GetArea()
               dbSelectArea("CN9")
               RecLock("CN9",.T.)
               CN9->CN9_FILIAL   := Alltrim(Substr(cComboBx5,01,02))
               CN9->CN9_NUMERO   := nProximoContrato
               CN9->CN9_DTINIC   := Ctod(aLocacao[6])
               CN9->CN9_UNVIGE   := aLocacao[8]
               CN9->CN9_VIGE     := int(val(aLocacao[9]))
               CN9->CN9_DTFIM    := Ctod(aLocacao[7])
               CN9->CN9_CLIENT   := aLocacao[3]
               CN9->CN9_LOJACL   := aLocacao[4]
               CN9->CN9_MOEDA    := Int(Val(aLocacao[10]))
               CN9->CN9_CONDPG   := aLocacao[11]
               CN9->CN9_TPCTO    := TContrato
               CN9->CN9_VLINI    := Val(aLocacao[19])
               CN9->CN9_VLATU    := Val(aLocacao[19])
               CN9->CN9_SALDO    := Val(aLocacao[19])
               CN9->CN9_INDICE   := "001"
               CN9->CN9_FLGREJ   := "2"
               CN9->CN9_FLGCAU   := "2"
               CN9->CN9_TPCAUC   := "2"
               CN9->CN9_SITUAC   := "02"
               MsUnLock()

               // Confirma a utilização do código do contrato
               ConfirmSX8(.T.)
                 
               // Atualiza a tabela de acesso ao contrato por usuário
               If Select("T_PARAMETROS") > 0
                  T_PARAMETROS->( dbCloseArea() )
               EndIf
   
               cSql := ""
               cSql := "SELECT ZZ4_ACON FROM " + RetSqlName("ZZ4")

               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

               If T_PARAMETROS->( EOF() )
                  cAcessos := "000000|"
               Else
                  If Empty(Alltrim(T_PARAMETROS->ZZ4_ACON))
                     cAcessos := "000000|"
                  Else
                     cAcessos := Alltrim(T_PARAMETROS->ZZ4_ACON)
                  Endif
               Endif

               For nContar = 1 to U_P_OCCURS(cAcessos, "|", 1)
                   aArea := GetArea()
                   dbSelectArea("CNN")
                   RecLock("CNN",.T.)      
                   CNN->CNN_FILIAL := Substr(cComboBx5,01,02)
                   CNN->CNN_CONTRA := nProximoContrato
                   CNN->CNN_USRCOD := U_P_CORTA(cAcessos, "|", nContar)
                   CNN->CNN_TRACOD := "001"
                   MsUnLock()
               Next nContar    

               // Inclui dados do comicionamento dos vendedores
               If !Empty(Alltrim(aLocacao[13]))
                  aArea := GetArea()
                  dbSelectArea("CNU")
                  RecLock("CNU",.T.)      
                  CNU->CNU_FILIAL := Substr(cComboBx5,01,02)
                  CNU->CNU_CONTRA := nProximoContrato
                  CNU->CNU_CODVD  := aLocacao[13]
                  CNU->CNU_PERCCM := Val(aLocacao[15])
                  MsUnLock()
               Endif

               If !Empty(Alltrim(aLocacao[16]))
                  aArea := GetArea()
                  dbSelectArea("CNU")
                  RecLock("CNU",.T.)      
                  CNU->CNU_FILIAL := Substr(cComboBx5,01,02)
                  CNU->CNU_CONTRA := nProximoContrato
                  CNU->CNU_CODVD  := aLocacao[16]
                  CNU->CNU_PERCCM := Val(aLocacao[18])
                  MsUnLock()
               Endif

               // Cria o cabeçalho da Planilha
               aArea := GetArea()
               dbSelectArea("CNA")
               RecLock("CNA",.T.)      
               CNA->CNA_FILIAL := Substr(cComboBx5,01,02)
               CNA->CNA_CONTRA := nProximoContrato
               CNA->CNA_NUMERO := "000001"	
               CNA->CNA_CLIENT := aLocacao[03]
               CNA->CNA_LOJACL := aLocacao[04]
               CNA->CNA_DTINI  := Ctod(aLocacao[06])
               CNA->CNA_VLTOT  := Val(aLocacao[19])
               CNA->CNA_SALDO  := Val(aLocacao[19])
               CNA->CNA_TIPPLA := "004"
               CNA->CNA_DTFIM  := Ctod(aLocacao[07])
               CNA->CNA_FLREAJ := "2"
               CNA->CNA_VLCOMS := Val(aLocacao[19])
               MsUnLock()

               // Carrega a tabela CNB (Ítens da Planilha)

               If Select("T_PARAMETROS") > 0
                  T_PARAMETROS->( dbCloseArea() )
               EndIf
   
               cSql := ""
               cSql := "SELECT ZZ4_LPRO, ZZ4_LTES "
               cSql += "  FROM " + RetSqlName("ZZ4")

               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

               // Carrega a tabela de ítens da planilha do contrato
               aArea := GetArea()
               dbSelectArea("CNB")
               RecLock("CNB",.T.)      
               CNB->CNB_FILIAL := Substr(cComboBx5,01,02)
               CNB->CNB_NUMERO := "000001"	
               CNB->CNB_ITEM   := "001"
               CNB->CNB_PRODUT := T_PARAMETROS->ZZ4_LPRO
               CNB->CNB_DESCRI := Posicione("SB1",1,xFilial("SB1") + T_PARAMETROS->ZZ4_LPRO + Space(24),'B1_DESC')
               CNB->CNB_UM	   := "UM"
               CNB->CNB_QUANT  := Int(Val(aLocacao[09]))
               CNB->CNB_VLUNIT := Val(aLocacao[19]) / Int(Val(aLocacao[09]))
               CNB->CNB_VLTOT  := Val(aLocacao[19])
               CNB->CNB_CONTRA := nProximoContrato
               CNB->CNB_DTCAD  := Ctod(aLocacao[06])
               CNB->CNB_SLDMED := Int(Val(aLocacao[09]))
               CNB->CNB_SLDREC := Int(Val(aLocacao[09]))
               CNB->CNB_FLGCMS := "1"
               CNB->CNB_TS	   := T_PARAMETROS->ZZ4_LTES
               MsUnLock()

               // Altera a Oportunidade na Tabela AD1
               aArea := GetArea()
               dbSelectArea("AD1")
               DbSetOrder(1)
               If DbSeek( Substr(cComboBx5,01,02) + xOportunidade + cRevisao)
                  RecLock("AD1",.F.)
                  AD1_ZCONTR := nProximoContrato
                  MsUnLock()
               Endif   

            Endif
            
         Else
         
            _Foi_Encerrada := .F.
         
         EndIf

      Else

         oDlgA:End()

      Endif

      END TRANSACTION

      // Se oportunidade foi encerrada, verifica se condição de pagamento permite que seja impresso Boleto Bancário
      If _Foi_Encerrada

         // Pesquisa a condição de pagamento e verifica se é permitido impressão de Boleto Bancário no encerramento da Proposta Comercial
         If Select("T_CONDICAO") > 0
            T_CONDICAO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT E4_CODIGO,"
         cSql += "       E4_BVDA   "
         cSql += "  FROM " + RetSqlName("SE4")
         cSql += " WHERE E4_CODIGO  = '" + Alltrim(SCJ->CJ_CONDPAG) + "'"
         cSql += "   AND E4_FILIAL  = ''"
         cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
         
         If !T_CONDICAO->( EOF() )
         
            If T_CONDICAO->E4_BVDA == "S"

               // Pesquisa a Filial e o nº do pedido de venda
               If Select("T_DADOSPEDIDO") > 0
                  T_DADOSPEDIDO->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT A.CJ_FILIAL,"
               cSql += "       A.CJ_NUM   ,"
               cSql += "       B.C6_NUM    "
               cSql += "  FROM " + RetSqlName("SCJ") + " A, "
               cSql += "       " + RetSqlName("SC6") + " B  "
               cSql += " WHERE A.CJ_FILIAL  = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
               cSql += "   AND A.CJ_PROPOST = '" + Alltrim(cNumProposta)    + "'"
               cSql += "   AND A.D_E_L_E_T_ = ''"
               cSql += "   AND B.C6_FILIAL  = A.CJ_FILIAL"
               cSql += "   AND SUBSTRING(B.C6_NUMORC,01,06) = A.CJ_NUM"
               cSql += "   AND B.D_E_L_E_T_ = ''"
   
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOSPEDIDO", .T., .T. )

               // Verifica se o pedido em questão está em DOLAR.
               // Se estiver em DOLAR, não permite que seha impresso o boleto mancário.
               // Pesquisa a Filial e o nº do pedido de venda
               If Select("T_EMDOLAR") > 0
                  T_EMDOLAR->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT C5_FILIAL,"
               cSql += "       C5_NUM   ,"
               cSql += "       C5_MOEDA  "
               cSql += "  FROM " + RetSqlName("SC5")
               cSql += " WHERE C5_FILIAL  = '" + Alltrim(Substr(cComboBx5,01,02)) + "'"
               cSql += "   AND C5_NUM     = '" + Alltrim(T_DADOSPEDIDO->C6_NUM)   + "'"
               cSql += "   AND D_E_L_E_T_ = ''"

               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMDOLAR", .T., .T. )

               If T_EMDOLAR->C5_MOEDA == 2
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) +  ;
                           "A condição de pagamento utilizada nesta proposta comercial permite que seja emitido o boleto bancário de cobrança, porém, este não será impresso em função do pedido de venda ser em D O L A R.")
               Else
                  DEFINE MSDIALOG oDlgBol TITLE "Emissão de Boleto Bancario" FROM C(178),C(181) TO C(315),C(634) PIXEL

                  @ C(005),C(005) Say "Atenção!"                                                                                                 Size C(023),C(008) COLOR CLR_RED PIXEL OF oDlgBol
                  @ C(017),C(005) Say "A Condição de Pagamento utilizada nesta Proposta Comercial permite que seja emitido o Boleto Bancário de" Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol
                  @ C(026),C(005) Say "cobrança para envio ao Cliente. Salve o(s) Boleto(s) em PDF e envie-os por e-mail ao Cliente."            Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol

                  @ C(045),C(005) GET oMemo11 Var cMemo11 MEMO Size C(216),C(001) PIXEL OF oDlgBol

                  @ C(051),C(005) Button "Gerar Boleto(s)"             Size C(077),C(012) PIXEL OF oDlgBol ACTION(U_AUTOM186( T_DADOSPEDIDO->CJ_FILIAL, T_DADOSPEDIDO->C6_NUM, "I"))
                  @ C(051),C(143) Button "Continuar s/Gerar Boleto(s)" Size C(077),C(012) PIXEL OF oDlgBol ACTION( oDlgBol:End() )

                  ACTIVATE MSDIALOG oDlgBol CENTERED 
               Endif   

            Endif
            
         Endif

      Endif

   Endif
      
   // V I S U A L I Z A Ç Ã O
   If _Operacao == "V"

      // Abre a tela da proposta comercial incluída
      DbSelectArea("ADY")
      DbSetorder(2)
      DbSeek(Substr(cComboBx5,01,02) + xOportunidade)
   
      A600Mnt("ADY", ADY->( Recno() ), 2)

   Endif

   // Fecha a janela de manutenção da oportunidade
   oDlgA:End() 

   xOportunidade := Space(06)
   xProposta     := Space(06)
   cCliente      := Space(100)

   ImpaBrowse(2, "")

   cFilAnt:= __cBkpAnt //Restaura o cFilant - Michel Aoki 23/09/2014  
         
Return(.T.)

// Função que realiza a duplicação da oportunidade selecionada
Static Function DuplicaOport( _tFilial, _tOportunidade, _tCliente, _tLoja, _tNomeCli, ___Proposta)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private hFilial	     := _tFilial
   Private hOportunidade := _tOportunidade
   Private hCliente      := _tCliente + "." + _tLoja + " - " + Alltrim(_tNomeCli)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgU

   DEFINE MSDIALOG oDlgU TITLE "Cópia de Oportunidade" FROM C(178),C(181) TO C(411),C(622) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgU

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(213),C(001) PIXEL OF oDlgU
   @ C(096),C(002) GET oMemo2 Var cMemo2 MEMO Size C(213),C(001) PIXEL OF oDlgU

   @ C(038),C(005) Say "Este processo tem por finalidade de realizar a duplicação de uma oportunidade de venda." Size C(212),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(054),C(005) Say "Conforme os dados para duplicação" Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(071),C(005) Say "Filial"                            Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(071),C(025) Say "Oportunidade"                      Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(071),C(063) Say "Cliente"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgU

   @ C(080),C(005) MsGet oGet1 Var hFilial       Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgU When lChumba
   @ C(080),C(025) MsGet oGet2 Var hOportunidade Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgU When lChumba
   @ C(080),C(063) MsGet oGet3 Var hCliente      Size C(152),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgU When lChumba

   @ C(100),C(138) Button "Confimar" Size C(037),C(012) PIXEL OF oDlgU ACTION( COPIAOPOR(hFilial, hOportunidade, hCliente, ___Proposta) )
   @ C(100),C(177) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgU ACTION( oDlgU:End() )

   ACTIVATE MSDIALOG oDlgU CENTERED 

Return(.T.)

// Função que duplica a oportunidade selecionada
Static Function CopiaOpor( _hFilial, _hOportunidade, _hCliente, ___Proposta)

   Local cSql := ""
 
   Private INCLUI
   Private ALTERA

   If _hFilial <> cFilAnt
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você está tentando duplicar uma oportunidade de venda em uma filial diferente da filial de origem da oportunidade. Você deve logar-se na mesma filial da oprotunidade que será duplicata.")
      Return(.T.)
   Endif

   If !MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente duplicar a oportunidade selecionada?")
      Return(.T.)
   Endif
   
   // Pesquisa os dados a serem utilizados para duplicação
   If Select("T_OPORTUNIDADE") > 0
      T_OPORTUNIDADE->( dbCloseArea() )
   EndIf
        
   // Pesquisa a oportunidade a ser utilizada para a duplicação
   cSql := ""
   cSql := "SELECT AD1_FILIAL,"
   cSql += "       AD1_NROPOR,"
   cSql += "       AD1_REVISA,"
   cSql += "       AD1_DESCRI,"
   cSql += "       AD1_DTINI ,"
   cSql += "       AD1_DTFIM ,"
   cSql += "       AD1_VEND  ,"
   cSql += "       AD1_VEND2 ,"
   cSql += "       AD1_DATA  ,"
   cSql += "       AD1_HORA  ,"
   cSql += "       AD1_CODCLI,"
   cSql += "       AD1_LOJCLI,"
   cSql += "       AD1_MOEDA ,"
   cSql += "       AD1_PROVEN,"
   cSql += "       AD1_STAGE ,"
   cSql += "       AD1_PRIOR ,"
   cSql += "       AD1_STATUS,"
   cSql += "       AD1_USER  ,"
   cSql += "       AD1_VERBA ,"
   cSql += "       AD1_MODO  ,"
   cSql += "       AD1_COMIS1,"
   cSql += "       AD1_COMIS2,"
   cSql += "       AD1_ZTIP  ," 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AD1_ZLOC)) AS PARAMETROS,"
   cSql += "       AD1_VISTEC,"
   cSql += "       AD1_SITVIS "
   cSql += "  FROM " + RetSqlName("AD1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND AD1_FILIAL = '" + Alltrim(_hFilial)       + "'"
   cSql += "   AND AD1_NROPOR = '" + Alltrim(_hOportunidade) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OPORTUNIDADE", .T., .T. )

   If T_OPORTUNIDADE->( EOF() )
      MsgAlert("Não existem dados a serem utilizados para duplicação.")
      Return(.T.)
   Endif
       
   Num_Proposta     := T_OPORTUNIDADE->AD1_NROPOR
   Num_Oportunidade := Ft300Num()

   BEGIN TRANSACTION
   
   // ----------------------------- //
   // Duplicação proposta comercial //
   // ----------------------------- // 
   k_Proposta := GetSXENum( "ADY", "ADY_PROPOS" ) 

   // Inclui a nova opotunidade
   aArea := GetArea()
   dbSelectArea("AD1")
   RecLock("AD1",.T.)
   AD1_FILIAL := T_OPORTUNIDADE->AD1_FILIAL
   AD1_NROPOR := Num_Oportunidade
   AD1_REVISA := "01"
   AD1_DESCRI := T_OPORTUNIDADE->AD1_DESCRI
   AD1_DTINI  := DATE()
   AD1_DTFIM  := DATE()
   AD1_VEND   := T_OPORTUNIDADE->AD1_VEND
   AD1_VEND2  := T_OPORTUNIDADE->AD1_VEND2
   AD1_DATA   := DATE()
   AD1_HORA   := TIME()
   AD1_CODCLI := T_OPORTUNIDADE->AD1_CODCLI
   AD1_LOJCLI := T_OPORTUNIDADE->AD1_LOJCLI
   AD1_MOEDA  := T_OPORTUNIDADE->AD1_MOEDA
   AD1_PROVEN := T_OPORTUNIDADE->AD1_PROVEN
   AD1_STAGE  := T_OPORTUNIDADE->AD1_STAGE
   AD1_PRIOR  := T_OPORTUNIDADE->AD1_PRIOR
   AD1_STATUS := "1"
   AD1_USER   := T_OPORTUNIDADE->AD1_USER
   AD1_VERBA  := T_OPORTUNIDADE->AD1_VERBA
   AD1_MODO   := T_OPORTUNIDADE->AD1_MODO
   AD1_COMIS1 := T_OPORTUNIDADE->AD1_COMIS1
   AD1_COMIS2 := T_OPORTUNIDADE->AD1_COMIS2
   AD1_PROPOS := k_Proposta
   AD1_ZTIP   := T_OPORTUNIDADE->AD1_ZTIP
   AD1_ZLOC   := T_OPORTUNIDADE->PARAMETROS
   AD1_VISTEC := T_OPORTUNIDADE->AD1_VISTEC
   AD1_SITVIS := T_OPORTUNIDADE->AD1_SITVIS
   MsUnLock()    

   // Cria variáveis de memória com a tabela ADY - Proposta Comercial
   DbSelectArea("ADY")
   DbSetorder(2)
   If !DbSeek(_hFilial + _hOportunidade)
      Return(.T.)   
   Else
      xADY_FILIAL := ADY->ADY_FILIAL
      xADY_PROPOS := k_Proposta
      xADY_OPORTU := Num_Oportunidade
      xADY_REVISA := ADY->ADY_REVISA
      xADY_ENTIDA := ADY->ADY_ENTIDA
      xADY_CODIGO := ADY->ADY_CODIGO
      xADY_LOJA   := ADY->ADY_LOJA
      xADY_TABELA := ADY->ADY_TABELA
      xADY_ORCAME := ADY->ADY_ORCAME
      xADY_STATUS := ADY->ADY_STATUS
      xADY_DATA   := ADY->ADY_DATA
      xADY_VAL    := ADY->ADY_VAL
      xADY_OBSP   := ADY->ADY_OBSP
      xADY_OBSI   := ADY->ADY_OBSI
      xADY_TRANSP := ADY->ADY_TRANSP
      xADY_TPFRET := ADY->ADY_TPFRET
      xADY_PARAQ  := ADY->ADY_PARAQ
      xADY_ENTREG := ADY->ADY_ENTREG
      xADY_FRETE  := ADY->ADY_FRETE
      xADY_OC     := ADY->ADY_OC
      xADY_FCOR   := ADY->ADY_FCOR
      xADY_TSRV   := ADY->ADY_TSRV
      xADY_ADM    := ADY->ADY_ADM
   Endif

   // Inclui a Proposta Comercial
   aArea := GetArea()
   dbSelectArea("ADY")
   RecLock("ADY",.T.)
   ADY_FILIAL := xADY_FILIAL
   ADY_PROPOS := k_Proposta
   ADY_OPORTU := Num_Oportunidade
   ADY_REVISA := xADY_REVISA
   ADY_ENTIDA := xADY_ENTIDA
   ADY_CODIGO := xADY_CODIGO
   ADY_LOJA   := xADY_LOJA
   ADY_TABELA := xADY_TABELA
   ADY_ORCAME := xADY_ORCAME
   ADY_STATUS := xADY_STATUS
   ADY_DATA   := xADY_DATA
   ADY_VAL    := xADY_VAL
   ADY_OBSP   := xADY_OBSP
   ADY_OBSI   := xADY_OBSI
   ADY_TRANSP := xADY_TRANSP
   ADY_TPFRET := xADY_TPFRET
   ADY_PARAQ  := xADY_PARAQ
   ADY_ENTREG := xADY_ENTREG
   ADY_FRETE  := xADY_FRETE
   ADY_OC     := xADY_OC
   ADY_FCOR   := xADY_FCOR
   ADY_TSRV   := xADY_TSRV
   ADY_ADM    := xADY_ADM
   ADY_FORMA  := "1"
   ADY_PREVIS := "01"
   ADY_CLIENT := xADY_CODIGO
   ADY_LOJENT := xADY_LOJA
   ADY_VEND   := T_OPORTUNIDADE->AD1_VEND
   ADY_TPCONT := "1"
   ADY_VISTEC := "2"
   ADY_SITVIS := "4"
   ADY_QEXAT  := "N"
   MsUnLock()    

   // Confirma o número alocado através do último comando 6XENUM()
   ConfirmSX8(.T.) // Se o parâmetro for passado como (.T.) verifica se o número já existe na base de dados.
      
   // Pesquisa a última revisão a ser pesquisada
   If Select("T_REVISAO") > 0
      T_REVISAO->( dbCloseArea() )
   EndIf

   cSql := "SELECT TOP(1) ADZ_REVISA"
   cSql += "  FROM " + RetSqlName("ADZ")
   cSql += " WHERE ADZ_FILIAL = '" + Alltrim(_hFilial)    + "'"
   cSql += "   AND ADZ_PROPOS = '" + Alltrim(___Proposta) + "'"
   cSql += "   AND D_E_L_E_T_ = '' 
   cSql += " ORDER BY ADZ_REVISA DESC

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REVISAO", .T., .T. )

   If T_REVISAO->( EOF() )
      MsgStop("Produtos da proposta comercial não localizados. Entre em contato com o administrador do sistema informando esta mensagem juntamente com o nº da proposta comercial para análise.")
      Return(.T.)
   Else
      cRevisao := T_REVISAO->ADZ_REVISA
   Endif   

   // Inclui os produtos da Proposta Comercial
   If Select("T_MATERIAL") > 0
  	  T_MATERIAL->( dbCloseArea() )
   EndIf

   cSql := "SELECT ADZ_FILIAL,"
   cSql += "       ADZ_ITEM	 ,"
   cSql += "       ADZ_PRODUT,"
   cSql += "       ADZ_DESCRI,"
   cSql += "       ADZ_UM	 ,"
   cSql += "       ADZ_MOEDA ,"
   cSql += "       ADZ_CONDPG,"
   cSql += "       ADZ_QTDVEN,"
   cSql += "       ADZ_PRCVEN,"
   cSql += "       ADZ_PRCTAB,"
   cSql += "       ADZ_TOTAL ,"
   cSql += "       ADZ_DESCON,"
   cSql += "       ADZ_VALDES,"
   cSql += "       ADZ_PROPOS,"
   cSql += "       ADZ_TES	 ,"
   cSql += "       ADZ_COMIS1,"
   cSql += "       ADZ_COMIS2,"
   cSql += "       ADZ_FOLDER,"
   cSql += "       ADZ_REVISA "
   cSql += "  FROM " + RetSqlName("ADZ")
   cSql += " WHERE ADZ_FILIAL = '" + Alltrim(_hFilial)    + "'"
   cSql += "   AND ADZ_PROPOS = '" + Alltrim(___Proposta) + "'"
   cSql += "   AND ADZ_REVISA = '" + Alltrim(cRevisao)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MATERIAL", .T., .T. )

   T_MATERIAL->( DbGoTop() )
   
   WHILE !T_MATERIAL->( EOF() )
   
      // Inclui nova proposta comercial
      aArea := GetArea()
      dbSelectArea("ADZ")
      RecLock("ADZ",.T.)
      ADZ_FILIAL  := T_MATERIAL->ADZ_FILIAL 
      ADZ_ITEM	  := T_MATERIAL->ADZ_ITEM
      ADZ_PRODUT  := T_MATERIAL->ADZ_PRODUT
      ADZ_DESCRI  := T_MATERIAL->ADZ_DESCRI
      ADZ_UM	  := T_MATERIAL->ADZ_UM
      ADZ_MOEDA   := T_MATERIAL->ADZ_MOEDA
      ADZ_CONDPG  := T_MATERIAL->ADZ_CONDPG
      ADZ_QTDVEN  := T_MATERIAL->ADZ_QTDVEN
      ADZ_PRCVEN  := T_MATERIAL->ADZ_PRCVEN
      ADZ_PRCTAB  := T_MATERIAL->ADZ_PRCTAB
      ADZ_TOTAL   := T_MATERIAL->ADZ_TOTAL
      ADZ_DESCON  := T_MATERIAL->ADZ_DESCON
      ADZ_VALDES  := T_MATERIAL->ADZ_VALDES
      ADZ_PROPOS  := k_Proposta
      ADZ_TES	  := T_MATERIAL->ADZ_TES
      ADZ_COMIS1  := T_MATERIAL->ADZ_COMIS1
      ADZ_COMIS2  := T_MATERIAL->ADZ_COMIS2
      ADZ_FOLDER  := T_MATERIAL->ADZ_FOLDER
      ADZ_REVISA  := "01"
      MsUnLock()    
      
      T_MATERIAL->( DbSkip() )
      
   ENDDO   

   // Pesquisa a tabela SCJ para duplicação
   If Select("T_ORCAMENTO") > 0
  	  T_ORCAMENTO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CJ_FILIAL  ,"	
   cSql += "       CJ_NUM	  ,"
   cSql += "	   CJ_EMISSAO ,"	
   cSql += "	   CJ_PROSPE  ,"	
   cSql += "	   CJ_LOJPRO  ,"
   cSql += "	   CJ_CLIENTE ,"
   cSql += "	   CJ_LOJA	  ,"
   cSql += "	   CJ_CLIENT  ,"	
   cSql += "	   CJ_LOJAENT ,"	
   cSql += "	   CJ_CONDPAG ,"	
   cSql += "	   CJ_DESC3	  ,"
   cSql += "	   CJ_DESC4	  ,"
   cSql += "	   CJ_TABELA  ,"	
   cSql += "	   CJ_DESC1	  ,"
   cSql += "	   CJ_PARC1	  ,"
   cSql += "	   CJ_DESC2	  ,"
   cSql += "	   CJ_DATA1	  ,"
   cSql += "	   CJ_PARC2	  ,"
   cSql += "       CJ_DATA2	  ,"
   cSql += "	   CJ_PARC3	  ,"
   cSql += "	   CJ_DATA3	  ,"
   cSql += "	   CJ_PARC4	  ,"
   cSql += "	   CJ_DATA4	  ,"
   cSql += "	   CJ_STATUS  ,"	
   cSql += "	   CJ_COTCLI  ,"	
   cSql += "	   CJ_FRETE	  ,"
   cSql += "	   CJ_SEGURO  ,"	
   cSql += "	   CJ_DESPESA ,"	
   cSql += "	   CJ_FRETAUT ,"	
   cSql += "	   CJ_VALIDA  ,"	
   cSql += "	   CJ_TIPO	  ,"
   cSql += "	   CJ_MOEDA	  ,"
   cSql += "	   CJ_TIPLIB  ,"
   cSql += " 	   CJ_TPCARGA ,"	
   cSql	+= "       CJ_DESCONT ,"	
   cSql	+= "       CJ_PDESCAB ,"	
   cSql	+= "       CJ_PROPOST ,"	
   cSql	+= "       CJ_NROPOR  ,"	
   cSql	+= "       CJ_REVISA  ,"	
   cSql	+= "       CJ_TXMOEDA  "
   cSql += "   FROM " + RetSqlName("SCJ")
   cSql += "  WHERE CJ_FILIAL  = '" + Alltrim(_hFilial)    + "'"
   cSql += "    AND CJ_PROPOST = '" + Alltrim(___Proposta) + "'"
   cSql += "    AND D_E_L_E_T_ = ''"
                                                          
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORCAMENTO", .T., .T. )

   T_ORCAMENTO->( DbGoTop() )

   kk_NumSCJ := GETSX8NUM("SCJ","CJ_NUM")   

   WHILE !T_ORCAMENTO->( EOF() )
   
      // Inclui nova SCJ para a duplicação da proposta comercial
      aArea := GetArea()
      dbSelectArea("SCJ")
      RecLock("SCJ",.T.)

      CJ_FILIAL  := T_ORCAMENTO->CJ_FILIAL
      CJ_NUM	 := kk_NumSCJ
      CJ_EMISSAO := CTOD(T_ORCAMENTO->CJ_EMISSAO)
      CJ_PROSPE  := T_ORCAMENTO->CJ_PROSPE
      CJ_LOJPRO  := T_ORCAMENTO->CJ_LOJPRO
      CJ_CLIENTE := T_ORCAMENTO->CJ_CLIENTE
      CJ_LOJA	 := T_ORCAMENTO->CJ_LOJA
      CJ_CLIENT  := T_ORCAMENTO->CJ_CLIENT
      CJ_LOJAENT := T_ORCAMENTO->CJ_LOJAENT
      CJ_CONDPAG := T_ORCAMENTO->CJ_CONDPAG
      CJ_DESC3	 := T_ORCAMENTO->CJ_DESC3
      CJ_DESC4	 := T_ORCAMENTO->CJ_DESC4
      CJ_TABELA  := T_ORCAMENTO->CJ_TABELA
      CJ_DESC1	 := T_ORCAMENTO->CJ_DESC1
      CJ_PARC1	 := T_ORCAMENTO->CJ_PARC1
      CJ_DESC2	 := T_ORCAMENTO->CJ_DESC2
      CJ_DATA1	 := CTOD(T_ORCAMENTO->CJ_DATA1)
      CJ_PARC2	 := T_ORCAMENTO->CJ_PARC2
      CJ_DATA2	 := CTOD(T_ORCAMENTO->CJ_DATA2)
      CJ_PARC3	 := T_ORCAMENTO->CJ_PARC3
      CJ_DATA3	 := CTOD(T_ORCAMENTO->CJ_DATA3)
      CJ_PARC4	 := T_ORCAMENTO->CJ_PARC4
      CJ_DATA4	 := CTOD(T_ORCAMENTO->CJ_DATA4)
      CJ_STATUS  := "A"
      CJ_COTCLI  := T_ORCAMENTO->CJ_COTCLI
      CJ_FRETE	 := T_ORCAMENTO->CJ_FRETE
      CJ_SEGURO  := T_ORCAMENTO->CJ_SEGURO
      CJ_DESPESA := T_ORCAMENTO->CJ_DESPESA
      CJ_FRETAUT := T_ORCAMENTO->CJ_FRETAUT
      CJ_VALIDA  := CTOD(T_ORCAMENTO->CJ_VALIDA)
      CJ_TIPO	 := T_ORCAMENTO->CJ_TIPO
      CJ_MOEDA	 := T_ORCAMENTO->CJ_MOEDA
      CJ_TIPLIB  := T_ORCAMENTO->CJ_TIPLIB
      CJ_TPCARGA := T_ORCAMENTO->CJ_TPCARGA
      CJ_DESCONT := T_ORCAMENTO->CJ_DESCONT
      CJ_PDESCAB := T_ORCAMENTO->CJ_PDESCAB
      CJ_PROPOST := k_Proposta
      CJ_NROPOR  := Num_Oportunidade
      CJ_REVISA  := T_ORCAMENTO->CJ_REVISA
      CJ_TXMOEDA := T_ORCAMENTO->CJ_TXMOEDA
      MsUnLock()    
      
      T_ORCAMENTO->( DbSkip() )
      
   ENDDO   

   // ########################################
   // Pesquisa a tabela SCk para duplicação ##
   // ########################################
   If Select("T_ORCAMENTO") > 0
  	  T_ORCAMENTO->( dbCloseArea() )
   EndIf

   cSql := "SELECT CK_FILIAL	,"
   cSql += "       CK_ITEM	    ,"
   cSql += "       CK_PRODUTO	,"
   cSql += "       CK_UM	    ,"
   cSql += "       CK_QTDVEN	,"
   cSql += "       CK_PRCVEN	,"
   cSql += "       CK_VALOR	    ,"
   cSql += "       CK_TES	    ,"
   cSql += "       CK_LOCAL	    ,"
   cSql += "       CK_CLIENTE	,"
   cSql += "       CK_LOJA	    ,"
   cSql += "       CK_DESCONT	,"
   cSql += "       CK_VALDESC	,"
   cSql += "       CK_PEDCLI	,"
   cSql += "       CK_NUM	    ,"
   cSql += "       CK_DESCRI	,"
   cSql += "       CK_PRUNIT	,"
   cSql += "       CK_NUMPV	    ,"
   cSql += "       CK_NUMOP	    ,"
   cSql += "       CK_OBS	    ,"
   cSql += "       CK_ENTREG	,"
   cSql += "       CK_COTCLI	,"
   cSql += "       CK_ITECLI	,"
   cSql += "       CK_OPC	    ,"
   cSql += "       CK_CLASFIS	,"
   cSql += "       CK_FILVEN	,"
   cSql += "       CK_FILENT	,"
   cSql += "       CK_CONTRAT	,"
   cSql += "       CK_ITEMCON	,"
   cSql += "       CK_PROJPMS	,"
   cSql += "       CK_EDTPMS	,"
   cSql += "       CK_TASKPMS	,"
   cSql += "       CK_COMIS1	,"
   cSql += "       CK_PROPOST	,"
   cSql += "       CK_ITEMPRO	,"
   cSql += "       CK_NORCPMS	,"
   cSql += "       CK_DT1VEN	,"
   cSql += "       CK_ITEMGRD	,"
   cSql += "       CK_VLIMPOR	,"
   cSql += "       CK_FCICOD	 "
   cSql += "  FROM " + RetSqlName("SCK")
   cSql += " WHERE CK_FILIAL  = '" + Alltrim(_hFilial)    + "'"
   cSql += "   AND CK_PROPOST = '" + Alltrim(___Proposta) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORCAMENTO", .T., .T. )

   T_ORCAMENTO->( DbGoTop() )

   WHILE !T_ORCAMENTO->( EOF() )
   
      // Inclui nova SCJ para a duplicação da proposta comercial
      aArea := GetArea()
      dbSelectArea("SCK")
      RecLock("SCK",.T.)
  
      CK_FILIAL	 := T_ORCAMENTO->CK_FILIAL
      CK_ITEM	 := T_ORCAMENTO->CK_ITEM
      CK_PRODUTO := T_ORCAMENTO->CK_PRODUTO
      CK_UM	     := T_ORCAMENTO->CK_UM
      CK_QTDVEN	 := T_ORCAMENTO->CK_QTDVEN
      CK_PRCVEN	 := T_ORCAMENTO->CK_PRCVEN
      CK_VALOR	 := T_ORCAMENTO->CK_VALOR
      CK_TES	 := T_ORCAMENTO->CK_TES
      CK_LOCAL	 := T_ORCAMENTO->CK_LOCAL
      CK_CLIENTE := T_ORCAMENTO->CK_CLIENTE
      CK_LOJA	 := T_ORCAMENTO->CK_LOJA
      CK_DESCONT := T_ORCAMENTO->CK_DESCONT
      CK_VALDESC := T_ORCAMENTO->CK_VALDESC
      CK_PEDCLI	 := T_ORCAMENTO->CK_PEDCLI
      CK_NUM	 := kk_NumSCJ
      CK_DESCRI	 := T_ORCAMENTO->CK_DESCRI
      CK_PRUNIT	 := T_ORCAMENTO->CK_PRUNIT
      CK_NUMPV	 := T_ORCAMENTO->CK_NUMPV
      CK_NUMOP	 := T_ORCAMENTO->CK_NUMOP
      CK_OBS	 := T_ORCAMENTO->CK_OBS
      CK_ENTREG	 := CTOD(T_ORCAMENTO->CK_ENTREG)
      CK_COTCLI	 := T_ORCAMENTO->CK_COTCLI
      CK_ITECLI	 := T_ORCAMENTO->CK_ITECLI
      CK_OPC	 := T_ORCAMENTO->CK_OPC
      CK_CLASFIS := T_ORCAMENTO->CK_CLASFIS
      CK_FILVEN	 := T_ORCAMENTO->CK_FILVEN
      CK_FILENT	 := T_ORCAMENTO->CK_FILENT
      CK_CONTRAT := T_ORCAMENTO->CK_CONTRAT
      CK_ITEMCON := T_ORCAMENTO->CK_ITEMCON
      CK_PROJPMS := T_ORCAMENTO->CK_PROJPMS
      CK_EDTPMS	 := T_ORCAMENTO->CK_EDTPMS
      CK_TASKPMS := T_ORCAMENTO->CK_TASKPMS
      CK_COMIS1	 := T_ORCAMENTO->CK_COMIS1
      CK_PROPOST := k_Proposta
      CK_ITEMPRO := T_ORCAMENTO->CK_ITEMPRO
      CK_NORCPMS := T_ORCAMENTO->CK_NORCPMS
      CK_DT1VEN	 := CTOD(T_ORCAMENTO->CK_DT1VEN)
      CK_ITEMGRD := T_ORCAMENTO->CK_ITEMGRD
      CK_VLIMPOR := T_ORCAMENTO->CK_VLIMPOR    
      CK_FCICOD	 := T_ORCAMENTO->CK_FCICOD
 
      MsUnLock()    
      
      T_ORCAMENTO->( DbSkip() )
      
   ENDDO   

   END TRANSACTION

   // Confirma o número alocado através do último comando GETSXENUM()
   ConfirmSX8(.T.) // Se o parâmetro for passado como (.T.) verifica se o número já existe na base de dados.

   MsgAlert("Duplicação da Oportunidade realizada com sucesso." + chr(13) + chr(10) + chr(13) + chr(10) + "Nº Oportunidade: " + Alltrim(Num_Oportunidade) + chr(13) + Chr(10) + "Nº Proposta Comercial: " + Alltrim(K_Proposta))
 
   oDlgU:End()

   ImpaBrowse(2, "")

Return(.T.)

// Função que envia e-mail
Static Function EnvMailCli(__Vendedor)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cEmailde   := __Vendedor
   Private cEmailPara := Space(25)
   Private cAssunto   := Space(25)
   Private cTexto     := ""
   Private oGet1
   Private oGet2
   Private oGet3

   Private oMemo3

   Private oDlgMail

   DEFINE MSDIALOG oDlgMail TITLE "Envio de e-mail a cliente" FROM C(178),C(181) TO C(554),C(730) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgMail

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(269),C(001) PIXEL OF oDlgMail
   @ C(063),C(003) GET oMemo2 Var cMemo2 MEMO Size C(269),C(001) PIXEL OF oDlgMail
   
   @ C(023),C(225) Say "ENVIO DE E-MAIL" Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgMail
   @ C(037),C(005) Say "Para:"           Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgMail
   @ C(050),C(005) Say "Assunto:"        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgMail
   @ C(066),C(005) Say "Mensagem"        Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgMail
            
   @ C(037),C(028) MsGet oGet2  Var cEmailPara  Size C(240),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMail
   @ C(050),C(028) MsGet oGet3  Var cAssunto    Size C(240),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMail
   @ C(075),C(005) GET   oMemo3 Var cTexto MEMO Size C(263),C(094)                              PIXEL OF oDlgMail

   @ C(172),C(192) Button "Enviar" Size C(037),C(012) PIXEL OF oDlgMail ACTION( MandaOemail() )
   @ C(172),C(231) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMail ACTION( oDlgMail:End() )

   ACTIVATE MSDIALOG oDlgMail CENTERED 

Return(.T.)

// Função que envia e-mail
Static Function MandaOemail()

   If Empty(Alltrim(cEmailDe))
      MsgAlert("Emitente do e-mail não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cEmailPara))
      MsgAlert("Email de destino não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cAssunto))
      MsgAlert("Assunto não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTexto))
      MsgAlert("Texto no e-mail não informado.")
      Return(.T.)
   Endif

   U_AUTOMR20(cTexto, Alltrim(cEmailPara), "", Alltrim(cAssunto) )
   
Return(.T.)

//
// ---------------------------------------------------------------------------- //
// Program    Ft300ADJFG  Autor  Vendas Clientes          Data  18.12.2007      //
// ---------------------------------------------------------------------------- //
// Descrição: Preenche o aHeader e aCols para tabela ADJ.                       //
// ---------------------------------------------------------------------------- //
// Retorno:   Nenhum                                                            //
// ---------------------------------------------------------------------------- //
// Parametros Ft300AD9FG(ExpN1, ExpA2, ExpA3, ExpC4, ExpC5)                     //
//            ExpN1 - Opcao Selecionada                                         //
//            ExpA2 - aHeader                                                   //
//            ExpA3 - aCols                                                     //
//            ExpC4 - NROPOR                                                    //
//            ExpC5 - Revisa                                                    //
//            ExpA6 - aCols contendo todos os produtos                          //
//            ExpL7 - Indica se todos os produtos serao colocados no aCols      //
//            _Moeda - Moeda a ser pesquisa para abertura de Pedido de venda    //
// ---------------------------------------------------------------------------- //
//
Static Function Ft300ADJFG( nOpc, aHead, aCols, cNRopor, cRevisa, aColsProd, lTodos)

   Local cSql      := ""
   Local aArea     := GetArea()
   Local cSeek     := ""       // Armazena a string de busca
   Local cWhile    := ""       // Armazena a condição de parada
   Local bCond                 // Armazena a condicao para validar os registros
   Local cQuery    := ""       // Armazena a query para TOP
   Local nX        := 0        // Auxiliar de Loop
   Local nY        := 0        // Auxiliar de Loop
   Local nPProd    := 0        // Posicao do campo produto
   Local nPDProd   := 0        // Posicao da descricao do produto
   Local nPCateg   := 0        // Posicao do campo categoria
   Local nPDCateg  := 0        // Posicao da descricao da categoria
   Local nPItem    := 0        // Posicao do campo Item 
   Local nPOrc     := 0        // Posicao do orcamento  
   Local lLinhaOk  := .T.      // Indica se a linha foi preenchida
   Local nOpcADJ   := 0        // Tratamento dado ao ADJ (ler documentacao abaixo)
   Local aColsSint := {}       // aCols sintetico utilizado para exibir apenas produtos sem proposta relacionada

   Default cNRopor := ""
   Default cRevisa := ""
   Default lTodos  := .F.

   // --------------------------------------------------------------------------------------- //
   // A variavel nOpcADJ, utilizada para  pode ter 3 valores:                                 //
   // 1 - Apaga registros manuais e considera somente os das propostas                        //
   // 2 - Mantem o registro lancado na ADJ manualmente e exibe os registros das propostas     //
   // 3 - Mantem os manuais e não exibe (apesar de gravar) os registros gerados por propostas //
   // --------------------------------------------------------------------------------------- //
   nOpcADJ := SuperGetMv("MV_FATMNTP",,1)

   If lTodos
      nOpcADJ := 2
   EndIf

   // Verifica se existe o registro dos produtos da proposta comercial na tabela ADJ
   If Select("T_TEMADJ") > 0
      T_TEMADJ->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ADJ.*"
   cSql += "  FROM " + RetSqlName("ADJ") + " ADJ "
   cSql += " WHERE ADJ.ADJ_FILIAL = '"   + xFilial("ADJ") + "'"
   cSql += "   AND ADJ.ADJ_NROPOR = '"   + cNRopor + "'"
   cSql += "   AND ADJ.ADJ_REVISA = '"   + cRevisa + "'"
   cSql += "   AND ADJ.D_E_L_E_T_ = '' "
   cSql += " ORDER BY " + SqlOrder(ADJ->(IndexKey()))

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEMADJ", .T., .T. )

   If T_TEMADJ->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existe inconsistência nos registros da tabela ADJ." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando-o" + chr(13) + chr(10) + "sobre este mensagem.")
      Return(.F.)
   Endif

   // Processo de encerramento da oportunidade de venda
   DbSelectArea("ADJ")
   DbSetOrder(3)

   #IFDEF TOP

          cQuery := ""
          cQuery := "SELECT ADJ.*"
          cQuery += "  FROM " + RetSqlName("ADJ") + " ADJ "
          cQuery += " WHERE ADJ.ADJ_FILIAL = '"   + xFilial("ADJ") + "'"
          cQuery += "   AND ADJ.ADJ_NROPOR = '"   + cNRopor + "'"
          cQuery += "   AND ADJ.ADJ_REVISA = '"   + cRevisa + "'"
          cQuery += "   AND ADJ.D_E_L_E_T_ = '' "
          cQuery += " ORDER BY " + SqlOrder(ADJ->(IndexKey()))

          cQuery := ChangeQuery(cQuery)

   #ENDIF

   DbSelectArea("ADJ")
   DbCloseArea()       

   cSeek  := xFilial("ADJ") + cNRopor + cRevisa
   cWhile := "ADJ->ADJ_FILIAL + ADJ->ADJ_NROPOR + ADJ->ADJ_REVISA"
   bCond  := {||    xFilial("ADJ")==ADJ->ADJ_FILIAL             .AND.;
                    cNRopor == ADJ->ADJ_NROPOR                  .AND.;
                    cRevisa == ADJ->ADJ_REVISA}    

   FillGetDados(    nOpc/*nOpcX*/, "ADJ"/*cAlias*/, 3/*nIndex*/, cSeek/*cSeek*/,; 
                                                               {||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
                                                               /*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, IIf(nOpc==3, .T., .F.)/*lEmpty*/,; 
                                                               @aHead/*aHeaderAux*/, @aCols/*aColsAux*/, /*bAfterCols*/          , /*bBeforeCols*/,;
                                                               /*bAfterHeader*/, "ADJ"/*cAliasQry*/, /*bCriaVar*/)

   nPProd   := aScan(aHead,{|x|AllTrim(x[2]) == "ADJ_PROD"})
   nPDProd  := aScan(aHead,{|x|AllTrim(x[2]) == "ADJ_DPROD"})
   nPCateg  := aScan(aHead,{|x|AllTrim(x[2]) == "ADJ_CATEG"})
   nPDCateg := aScan(aHead,{|x|AllTrim(x[2]) == "ADJ_DCATEG"})
   nPItem   := aScan(aHead,{|x|AllTrim(x[2]) == "ADJ_ITEM"})
   nPOrc    := aScan(aHead,{|x|AllTrim(x[2]) == "ADJ_NUMORC"})

   If Len(aCols) = 1 .AND. nPItem > 0 .AND. Empty(aCols[1][nPItem])
      lLinhaOk := .F.
      aCols[1][nPItem] := "001"           
   EndIf

   For nX := 1 to Len(aCols)
       If (nPProd > 0) .AND. (nPDProd > 0) .AND. (!Empty(aCols[nX][nPProd]))
           aCols[nX][nPDProd]      := Posicione("SB1",1,xFilial("SB1")+aCols[nX][nPProd],'B1_DESC')
       EndIf 
       If (nPCateg > 0) .AND. (nPDCateg > 0) .AND. (!Empty(aCols[nX][nPCateg]))
           aCols[nX][nPDCateg]    := Posicione("ACU",1,xFilial("ACU")+aCols[nX][nPCateg],'ACU_DESC')
       EndIf
   Next nX
                                                          
   // ---------------------------------------------------------------------- //
   // Cria aCols sintetico, contendo somente produtos sem proposta associada //
   // ---------------------------------------------------------------------- // 
   If nOpcADJ == 3

      aColsProd := {}

      For nX := 1 to Len(aCols)

          If lLinhaOk
             If Empty(aCols[nX][nPOrc])
                AAdd(aColsSint,aClone(aCols[nX]))
             EndIf
             If !Empty(aCols[nX][nPOrc])
                AAdd(aColsProd,aClone(aCols[nX]))
             EndIf
          EndIf
          lLinhaOk := .T.
      Next nX
                
      aCols := aClone(aColsSint)
                
   EndIf

   DbSelectArea("ADJ")
   DbCloseArea()

   RestArea(aArea)
   
Return (.T.)

// Função que mostra os pedidos e notas fiscais da proposta comercial
Static Function PedidoNF( _Filial, _Oportunidade, _Proposta, _NomeCliente, xx_Cliente, xx_Loja )

   Local lChumba       := .F.
   Local cOportunidade := _Oportunidade
   Local cProposta     := _Proposta
   Local cDestinatario := xx_Cliente + "." + xx_Loja + " - " + Alltrim(_NomeCLiente)
   Local cMemo1	       := ""
   Local cSeqPedido	   := ""
   Local cSeqNota      := ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private oDlgPed

   If Empty(Alltrim(_Oportunidade))
      Return(.T.)
   Endif   

   // Pesquisa o código do pedido de venda da oportunidade
   If Select("T_RETPEDIDO") > 0
  	  T_RETPEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CK_NUMPV"
   cSql += "  FROM " + RetSqlName("SCK")
   cSql += " WHERE CK_FILIAL  = '" + Alltrim(_Filial)    + "'"
   cSql += "   AND CK_PROPOST = '" + Alltrim(cProposta)  + "'"
   cSql += "   AND CK_CLIENTE = '" + Alltrim(xx_Cliente) + "'"
   cSql += "   AND CK_LOJA    = '" + Alltrim(xx_Loja)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )
	
   If !T_RETPEDIDO->( EOF() )

      cSeqPedido := ""
      cSeqNota   := ""

      WHILE !T_RETPEDIDO->( EOF() )

         If Alltrim(cPedido) == "000000"
            T_RETPEDIDO->( DbSkip() )            
            Loop
         Endif

         If U_P_OCCURS(cSeqPedido, T_RETPEDIDO->CK_NUMPV, 1) == 0
            cSeqPedido := cSeqPedido + T_RETPEDIDO->CK_NUMPV + ", "
            
            If Select("T_RETNOTA") > 0
        	   T_RETNOTA->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT DISTINCT C6_NOTA ,"
            cSql += "       C6_SERIE "
            cSql += "  FROM " + RetSqlName("SC6")
            cSql += " WHERE C6_FILIAL  = '" + Alltrim(_Filial)               + "'"
            cSql += "   AND C6_NUM     = '" + Alltrim(T_RETPEDIDO->CK_NUMPV) + "'"
            cSql += "   AND C6_NOTA   <> ''"
            cSql += "   AND D_E_L_E_T_ = ''"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETNOTA", .T., .T. )

            If !T_RETNOTA->( EOF() )
               WHILE !T_RETNOTA->( EOF() )
                  If U_P_OCCURS(cSeqNota, T_RETNOTA->C6_NOTA, 1) == 0               
                     cSeqNota := cSeqNota + Alltrim(T_RETNOTA->C6_NOTA) + "/" + Alltrim(T_RETNOTA->C6_SERIE) + ", "               
                  Endif
                  T_RETNOTA->( DbSkip() )
               ENDDO   
            Endif
         Endif

         T_RETPEDIDO->( DbSkip() )

      ENDDO
     
      // Elimina a última vírgula
      cSeqPedido := Substr(cSeqPedido,01, Len(Alltrim(cSeqPedido)) - 1)
      cSeqNota   := Substr(cSeqNota  ,01, Len(Alltrim(cSeqNota))   - 1)
           
   Endif

   DEFINE MSDIALOG oDlgPed TITLE "Pedidos de Venda/Notas Fiacais" FROM C(178),C(181) TO C(483),C(606) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlgPed

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(205),C(001) PIXEL OF oDlgPed

   @ C(041),C(005) Say "Oportunidade"                           Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgPed
   @ C(041),C(043) Say "Prop.Comercial"                         Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgPed
   @ C(041),C(086) Say "Cliente"                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPed
   @ C(063),C(005) Say "Pedidos de Venda da Proposta Comercial" Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgPed
   @ C(100),C(005) Say "Notas Fiscais da Proposta Comercial"    Size C(091),C(008) COLOR CLR_BLACK PIXEL OF oDlgPed
   
   @ C(050),C(005) MsGet oGet1 Var cOportunidade Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPed When lChumba
   @ C(050),C(043) MsGet oGet2 Var cProposta     Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPed When lChumba
   @ C(050),C(086) MsGet oGet3 Var cDestinatario Size C(121),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPed When lChumba

   @ C(073),C(005) GET oMemo2 Var cSeqPedido MEMO Size C(203),C(023) PIXEL OF oDlgPed When lChumba
   @ C(109),C(005) GET oMemo3 Var cSeqNota   MEMO Size C(203),C(023) PIXEL OF oDlgPed When lChumba

   @ C(136),C(170) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgPed ACTION( oDlgPed:End() )

   ACTIVATE MSDIALOG oDlgPed CENTERED 

Return(.T.)

// Função que mostra todas as vendas efetuadas para o Cliente selecionado
Static Function TodasAsVendas( xx_Cliente, xx_Loja, xx_Nome )

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

// Função que abre tela de complemento dos dados para proposta de locação
Static Function PedeLoca( __Loc_Tipo, __Loc_Opor, __Loc_Prop, __Loc_Clie, __Loc_Operacao)

   Local lChumba        := .F.
                       
   Private aVigencia    := {"0 - Seleciona a Vigência", "1 - Dias", "2 - Meses", "3 - Anos", "4 - Indeterminado"}
   Private aMoeda       := {"0 - Selecione a Moeda", "1 - Real", "2 - Dolar"}
   Private aAtendimento := {"0 - Selecione Tipo Atendimento", "1 - ON SITE", "2 - BALCÃO"}
   Private aTipocontra  := {"0 - Selecione Tipo Contrato"   , "1 - Tradicional", "2 - Longo Prazo"}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private Loc_Opor   := __Loc_Opor
   Private Loc_Prop   := __Loc_Prop
   Private Loc_clie   := __Loc_Clie
   Private cDinicial  := Ctod("  /  /    ")
   Private cDfinal	  := Ctod("  /  /    ")
   Private cVigencia  := 0
   Private cCondicao  := Space(06)
   Private cNomeCondi := Space(60)
   Private cMemo1	  := ""
   Private cMemo2 	  := ""
   Private cVende01   := Space(06)
   Private cNomeV01   := Space(60)
   Private cPercV01   := 0
   Private cVende02   := Space(06)
   Private cNomeV02   := Space(60)
   Private cPercV02   := 0
   Private nValTotal  := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9 
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oMemo1
   Private oMemo2

   Private oDlgLoc

   // Valida de é uma proposta de locação
   If Substr(__Loc_Tipo,01,01) <> "2"
      MsgAlert("Atenção! Proposta não é uma Proposta de Locação. Operação não permitida.")
      Return(.T.)
   Endif

   // Verifica se houve informação de Cliente
   If Empty(Alltrim(Substr(__Loc_Clie,01,06)))
      MsgAlert("Atenção! Cliente ainda não informado. Operação não permitida.")
      Return(.T.)
   Endif

   // Verifica se o array aLocacao está carregado. Se tiver, carrega as variáveis de trabalho, senão, somente inicializa as variáveis de trabalho
   If Len(aLocacao) == 0
      Loc_Opor   := __Loc_Opor
      Loc_Prop   := __Loc_Prop
      Loc_clie   := __Loc_Clie
      cDinicial  := Ctod("  /  /    ")
      cDfinal	 := Ctod("  /  /    ")
      cVigencia  := 0
      cCondicao  := Space(06)
      cNomeCondi := Space(60)
      cVende01   := Space(06)
      cNomeV01   := Space(60)
      cPercV01   := 0
      cVende02   := Space(06)
      cNomeV02   := Space(60)
      cPercV02   := 0
      nValTotal  := 0
   Else
      Loc_Opor   := aLocacao[01]
      Loc_Prop   := aLocacao[02]
      Loc_Clie   := aLocacao[03] + "." + aLocacao[04] + " - " + aLocacao[05]
      cDinicial  := Ctod(aLocacao[06])
      cDfinal    := Ctod(aLocacao[07])

      Do Case 
         Case aLocacao[08] == "1"
              cComboBx1 := "1 - Dias"
         Case aLocacao[08] == "2"
              cComboBx1 := "2 - Meses"
         Case aLocacao[08] == "3"
              cComboBx1 := "3 - Anos"
         Case aLocacao[08] == "4"
              cComboBx1 := "4 - Indeterminado"
         Otherwise
              cComboBx1 := "0 - Selecione a Vigência"
      EndCase

      cVigencia  := INT(VAL(aLocacao[09]))

      Do Case
         Case aLocacao[10] == "1"
              cComboBx2 := "1 - Real"
         Case aLocacao[10] == "2"
              cComboBx2 := "2 - Dolar"
         Otherwise
              cComboBx2 := "0 - Selecione a Moeda"
      EndCase

      cCondicao  := aLocacao[11]
      cNomeCondi := aLocacao[12]
      cVende01   := aLocacao[13]
      cNomeV01   := aLocacao[14]
      cPercV01   := Val(aLocacao[15])
      cVende02   := aLocacao[16]
      cNomeV02   := aLocacao[17]
      cPercV02   := Val(aLocacao[18])
      nValTotal  := Val(aLocacao[19])

      Do Case
         Case aLocacao[20] == "1"
              cComboBx3 := "1 - ON SITE"
         Case aLocacao[20] == "2"
              cComboBx3 := "2 - BALCÃO"
         Otherwise
              cComboBx3 := "0 - Selecione Tipo Atendimento"
      EndCase

      // Tipo de Contrato
      Do Case
         Case aLocacao[21] == "1"
              cComboBx4 := "1 - Tradicional"
         Case aLocacao[21] == "2"
              cComboBx4 := "2 - Longo Prazo"
         Otherwise
              cComboBx4 := "0 - Selecione Tipo Contrato"
      EndCase

   Endif                    

   DEFINE MSDIALOG oDlgLoc TITLE "Contrato de Locação" FROM C(178),C(181) TO C(512),C(698) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlgLoc

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(249),C(001) PIXEL OF oDlgLoc
   @ C(059),C(005) GET oMemo2 Var cMemo2 MEMO Size C(249),C(001) PIXEL OF oDlgLoc
   
   @ C(021),C(149) Say "DADOS INCLUSÃO CONTRATO LOCAÇÃO" Size C(106),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(035),C(005) Say "Oportunidade"                    Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(035),C(043) Say "Prop.Comercial"                  Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(035),C(084) Say "Cliente"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(005) Say "Dt.Inicial"                      Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(047) Say "Dt.Final"                        Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(089) Say "Un. Vigência"                    Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(166) Say "Vigência"                        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(194) Say "Moeda"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(086),C(005) Say "Valor Total Contrato"            Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(086),C(072) Say "Cond.Pgtº"                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(086),C(105) Say "Descrição Condição de Pagamento" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(107),C(005) Say "Vendedores"                      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(107),C(224) Say "% Comissão"                      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(142),C(005) Say "Tipo de Atendimento"             Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(142),C(100) Say "Tipo de Contrato"                Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   
   @ C(044),C(005) MsGet oGet1 Var Loc_Opor Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba
   @ C(044),C(043) MsGet oGet2 Var Loc_Prop Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba
   @ C(044),C(084) MsGet oGet3 Var Loc_Clie Size C(169),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba

   If __Loc_Operacao == "V"
      @ C(073),C(005) MsGet    oGet4     Var   cDinicial    Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(073),C(047) MsGet    oGet5     Var   cDFinal      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(073),C(089) ComboBox cComboBx1 Items aVigencia    Size C(072),C(010)                                             PIXEL OF oDlgLoc When lChumba
      @ C(074),C(166) MsGet    oGet6     Var   cVigencia    Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999999"         PIXEL OF oDlgLoc When lChumba
      @ C(074),C(194) ComboBox cComboBx2 Items aMoeda       Size C(060),C(010)                                             PIXEL OF oDlgLoc When lChumba
      @ C(095),C(005) MsGet    oGet15    Var   nValTotal    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgLoc When lChumba
      @ C(095),C(072) MsGet    oGet7     Var   cCondicao    Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(095),C(105) MsGet    oGet8     Var   cNomeCondi   Size C(148),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(005) MsGet    oGet9     Var   cVende01     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(037) MsGet    oGet10    Var   cNomeV01     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(226) MsGet    oGet11    Var   cPercV01     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc When lChumba
      @ C(129),C(005) MsGet    oGet12    Var   cVende02     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(129),C(037) MsGet    oGet13    Var   cNomeV02     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(130),C(226) MsGet    oGet14    Var   cPercV02     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc When lChumba
      @ C(151),C(005) ComboBox cComboBx3 Items aAtendimento Size C(092),C(010)                                             PIXEL OF oDlgLoc When lChumba
      @ C(151),C(100) ComboBox cComboBx4 Items aTipoContra  Size C(072),C(010)                                             PIXEL OF oDlgLoc When lChumba
      @ C(144),C(216) Button "Voltar"    Size C(037),C(012)                                                                PIXEL OF oDlgLoc ACTION( oDlgLoc:End() )
   Else
      @ C(073),C(005) MsGet    oGet4     Var   cDinicial    Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc
      @ C(073),C(047) MsGet    oGet5     Var   cDFinal      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc
      @ C(073),C(089) ComboBox cComboBx1 Items aVigencia    Size C(072),C(010)                                             PIXEL OF oDlgLoc
      @ C(074),C(166) MsGet    oGet6     Var   cVigencia    Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999999"         PIXEL OF oDlgLoc
      @ C(074),C(194) ComboBox cComboBx2 Items aMoeda       Size C(060),C(010)                                             PIXEL OF oDlgLoc
      @ C(095),C(005) MsGet    oGet15    Var   nValTotal    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgLoc
      @ C(095),C(072) MsGet    oGet7     Var   cCondicao    Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc F3("SE4") VALID( CapCodPaga(cCondicao) )
      @ C(095),C(105) MsGet    oGet8     Var   cNomeCondi   Size C(148),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(005) MsGet    oGet9     Var   cVende01     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc F3("SA3") VALID( BscLocVende(1) )
      @ C(117),C(037) MsGet    oGet10    Var   cNomeV01     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(226) MsGet    oGet11    Var   cPercV01     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc
      @ C(129),C(005) MsGet    oGet12    Var   cVende02     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc F3("SA3") VALID( BscLocVende(2) )
      @ C(129),C(037) MsGet    oGet13    Var   cNomeV02     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(130),C(226) MsGet    oGet14    Var   cPercV02     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc
      @ C(151),C(005) ComboBox cComboBx3 Items aAtendimento Size C(092),C(010)                                             PIXEL OF oDlgLoc
      @ C(151),C(100) ComboBox cComboBx4 Items aTipoContra  Size C(072),C(010)                                             PIXEL OF oDlgLoc

      @ C(149),C(177) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgLoc ACTION( CfmeLocacao() )
      @ C(149),C(216) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgLoc ACTION( oDlgLoc:End() )
   Endif   

   ACTIVATE MSDIALOG oDlgLoc CENTERED 

Return(.T.)

// Função que pesquisa a condição de pagamento informada
Static Function CapCodPaga( __Condicao )

   Local cSql := ""
   
   If Empty(Alltrim(__Condicao))
      cCondicao  := Space(06)
      cNomeCondi := Space(60)
      oGet7:Refresh()
      oGet8:Refresh()
      Return(.T.)
   Endif

   cNomeCondi := Posicione("SE4", 1, xFilial("SE4") + __Condicao, "E4_DESCRI")         
   oGet8:Refresh()
   
Return(.T.)

// Função que pesquisa o vendedor informado na tela de locação de produtos
Static Function BscLocVende(_____Tipo)

   If _____Tipo == 1
      cNomeV01 := Posicione("SA3", 1, xFilial("SA3") + cVende01, "A3_NOME")         
      If Empty(Alltrim(cNomeV01))
         cVende01 := Space(06)      
      Endif   
      oGet9:Refresh()
   Else
      cNomeV02 := Posicione("SA3", 1, xFilial("SA3") + cVende02, "A3_NOME")         
      If Empty(Alltrim(cNomeV02))
         cVende02 := Space(06)      
      Endif   
      oGet10:Refresh()
   Endif

Return(.T.)

// Função que gera as consistências dos dados informados
Static Function CfmeLocacao()
           
   // Consiste a Vigência
   If Substr(cComboBx1,01,01) == "0"
      MsgAlert("Vigência do Contrato não selecionado.")
      Return(.T.)
   Endif   

   // Consiste Moeda do Contrato
   If Substr(cComboBx2,01,01) == "0"
      MsgAlert("Moeda do Contrato não selecionada.")
      Return(.T.)
   Endif   

   If Empty(cDinicial)
      MsgAlert("Data inicial do contrato não informada.")
      Return(.T.)
   Endif   
   
   If Empty(cDfinal)
      MsgAlert("Data final do contrato não informada.")
      Return(.T.)
   Endif   
   
   If cVigencia == 0
      MsgAlert("Vigência não informada.")
      Return(.T.)
   Endif   

   If Empty(Alltrim(cCondicao))
      MsgAlert("Condição de Pagamento do Contrato não informada.")
      Return(.T.)
   Endif   

   If Empty(Alltrim(cVende01))
      MsgAlert("Necessário informar pelo menos um vendedor.")
      Return(.T.)
   Endif

   If nValTotal == 0
      MsgAlert("Valor Total do Contrato de Locação não informado.")
      Return(.T.)
   Endif

   // Consiste do Tipo de Atendimento
   If Substr(cComboBx3,01,01) == "0"
      MsgAlert("Tipo de Atendimento não informado.")
      Return(.T.)
   Endif   

   // Consiste do Tipo de Contrato
   If Substr(cComboBx4,01,01) == "0"
      MsgAlert("Tipo de Contrato não informado.")
      Return(.T.)
   Endif   

   // Crarega o array aLocacao. Array que guarda os dados da proposta de locação
   aLocacao := {}   
   aAdd( aLocacao, Loc_Opor )
   aAdd( aLocacao, Loc_Prop )
   aAdd( aLocacao, Substr(Loc_Clie,01,06) )
   aAdd( aLocacao, Substr(Loc_Clie,08,03) )
   aAdd( aLocacao, Substr(Loc_Clie,14) )
   aAdd( aLocacao, Dtoc(cDinicial) )
   aAdd( aLocacao, Dtoc(cDfinal) )
   aAdd( aLocacao, Substr(cComboBx1,01,01) )
   aAdd( aLocacao, Alltrim(Str(cVigencia)) )
   aAdd( aLocacao, Substr(cComboBx2,01,01) )
   aAdd( aLocacao, cCondicao )
   aAdd( aLocacao, cNomeCondi )
   aAdd( aLocacao, cVende01 )
   aAdd( aLocacao, cNomeV01 )
   aAdd( aLocacao, Str(cPercV01,06,02) )
   aAdd( aLocacao, cVende02 )
   aAdd( aLocacao, cNomeV02 )
   aAdd( aLocacao, Str(cPercV02,06,02) )
   aAdd( aLocacao, Str(nValTotal,12,02) )
   aAdd( aLocacao, Substr(cComboBx3,01,01) )
   aAdd( aLocacao, Substr(cComboBx4,01,01) )
   
   oDlgLoc:End()

   // Atualiza os dados dos vendedores
   cVendedor1 := aLocacao[13]
   cNomeVend1 := aLocacao[14]
   cVendedor2 := aLocacao[16]
   cNomeVend2 := aLocacao[17]
   
   oGet11:Refresh()
   oGet12:Refresh()
   oGet13:Refresh()
   oGet14:Refresh()
 
Return(.T.)

// Função que abre a tela de acompanhamento de pedidos passando os dados do pedido a ser visualizado
Static Function ACOMPAPV(ac_filial, ac_pedido, ac_vendedor, ac_cliente, ac_loja)

   Local nContar     := 0
   Local nMarcado    := 0
   Local cMemo1	     := ""
   Local oMemo1
   Local lRetorna    := .F.
   Local oOk         := LoadBitmap( GetResources(), "LBOK" )
   Local oNo         := LoadBitmap( GetResources(), "LBNO" )

   Private aListaPed := {}
   Private oListaPed
   Private oDlgAcom

   // Se não houve parâmetros, abre sem posicionar
   If Empty(Alltrim(ac_filial))
      U_AUTOM216()
      Return(.T.)
   Endif

   // Verifica se o parâmetro pedido possui mais do que um pedido de venda. Se tiver, abre janela solicitando ao usuário qual pedido será visualizado
   If U_P_OCCURS(ac_pedido, ",", 1) == 0
   
      aAdd( aListaPed, { .T., ac_pedido } )
      lRetorna := .T.
      
   Else

      // Separa os pedidos para popular a Lista para visualização
      ac_pedido := Alltrim(ac_pedido) + ","
      For nContar = 1 to U_P_OCCURS(ac_pedido, ",", 1)
          aAdd( aListaPed, { .F., Alltrim(U_P_CORTA(ac_pedido, ",", nContar)) } )
      Next nContar    

      DEFINE MSDIALOG oDlgAcom TITLE "Acompanhamento de Pedidos" FROM C(178),C(181) TO C(395),C(448) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgAcom

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(126),C(001) PIXEL OF oDlgAcom

      @ C(036),C(005) Say "Selecione o pedido de venda a ser visualizado" Size C(111),C(008) COLOR CLR_BLACK PIXEL OF oDlgAcom

      @ C(092),C(056) Button "Consultar" Size C(037),C(012) PIXEL OF oDlgAcom ACTION( lRetorna := .T., oDlgAcom:End() )
      @ C(092),C(094) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgAcom ACTION( lRetorna := .F., oDlgAcom:End() )
  
      @ 055,005 LISTBOX oListaPed FIELDS HEADER "M", "Pedidos de Venda" PIXEL SIZE 160,058 OF oDlgAcom ON dblClick(aListaPed[oListaPed:nAt,1] := !aListaPed[oListaPed:nAt,1],oListaPed:Refresh())     
      oListaPed:SetArray( aListaPed )
      oListaPed:bLine := {||{Iif(aListaPed[oListaPed:nAt,01],oOk,oNo), aListaPed[oListaPed:nAt,02]}}

      ACTIVATE MSDIALOG oDlgAcom CENTERED 
                                
   Endif

   If lRetorna == .F.
      Return(.T.)
   Else   

      // Verifica se houve marcação de um pedido para visualização
      For nContar = 1 to Len(aListaPed)
          If aListaPed[nContar,01] == .T.
             cPedido_Venda := aListaPed[nContar,02]
             nMarcado := nMarcado + 1
          Endif
      Next nContar       

      If nMarcado == 0
         MsgAlert("Atenção! Nenhum pedido de venda foi indicado para visualização.")
         Return(.T.)
      Endif
         
      If nMarcado > 1
         MsgAlert("Atenção! Somente é permitido indicar um pedido de venda de cada vez para visualização.")
         Return(.T.)
      Endif

      U_AUTOM216(ac_filial + "|" + cPedido_Venda + "|" + ac_vendedor + "|" + ac_cliente + "|" + ac_loja + "|")

   Endif   
   
Return(.T.)   

// Função que abre imprime o boleto bancário da nota fiscal selecionada
Static Function EBOLETOS(ac_filial, ac_pedido)

   Local ___Pedidos    := ""
   Local cNota_Fiscal  := ""
   Local cSerie_Fiscal := ""
   Local nContar       := 0
   Local nMarcado      := 0
   Local cMemo1	       := ""
   Local oMemo1
   Local lRetorna      := .F.
   Local oOk           := LoadBitmap( GetResources(), "LBOK" )
   Local oNo           := LoadBitmap( GetResources(), "LBNO" )

   Private aListaPed   := {}
   Private oListaPed
   Private oDlgAcom

   // Separa os pedidos para popular a Lista para visualização
   ac_pedido  := Alltrim(ac_pedido) + ","
   ___Pedidos := ""
   For nContar = 1 to U_P_OCCURS(ac_pedido, ",", 1)
       ___Pedidos := ___Pedidos + "'" + Alltrim(U_P_CORTA(ac_pedido, ",", nContar)) + "',"
   Next nContar
   
   // Elimina a última vírgula antes de utilizar a variável com os pedidos de venda
   ___Pedidos := Substr(___Pedidos,01, Len(Alltrim(___Pedidos)) - 1)

   // Pesquisa as notas fiscais dos pedidos selecionados
   If Select("T_EMITEBOLETO") > 0
      T_EMITEBOLETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT C6_NOTA ,"
   cSql += "                C6_SERIE "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(ac_filial)  + "'"
   cSql += "   AND C6_NUM    IN (" + Alltrim(___Pedidos) + ")"
   cSql += "   AND D_E_L_E_T_ = ''"   
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMITEBOLETO", .T., .T. )

   If T_EMITEBOLETO->( EOF() )
      MsGalert("Não existem boletos a serem impressos para este(s) pedido(s).")
      Return(.T.)
   Endif
   
   WHILE !T_EMITEBOLETO->( EOF() )
      aAdd( aListaPed, { .F., T_EMITEBOLETO->C6_NOTA, T_EMITEBOLETO->C6_SERIE } )
      T_EMITEBOLETO->( DbSkip() )
   ENDDO

   If Len(aListaPed) == 0
      MsGalert("Não existem boletos a serem impressos para este(s) pedido(s).")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgAcom TITLE "Emissão de Boletos" FROM C(178),C(181) TO C(395),C(448) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgAcom

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(126),C(001) PIXEL OF oDlgAcom

   @ C(036),C(005) Say "Selecione a Nota Fiscal p/impressão do boleto" Size C(111),C(008) COLOR CLR_BLACK PIXEL OF oDlgAcom

   @ C(092),C(056) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgAcom ACTION( lRetorna := .T., oDlgAcom:End() )
   @ C(092),C(094) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgAcom ACTION( lRetorna := .F., oDlgAcom:End() )
  
   @ 055,005 LISTBOX oListaPed FIELDS HEADER "M", "Notas Fiscais" PIXEL SIZE 160,058 OF oDlgAcom ON dblClick(aListaPed[oListaPed:nAt,1] := !aListaPed[oListaPed:nAt,1],oListaPed:Refresh())     
   oListaPed:SetArray( aListaPed )
   oListaPed:bLine := {||{Iif(aListaPed[oListaPed:nAt,01],oOk,oNo), aListaPed[oListaPed:nAt,02]}}

   ACTIVATE MSDIALOG oDlgAcom CENTERED 
                                
   If lRetorna == .F.
      Return(.T.)
   Else   

      // Verifica se houve marcação de um pedido para visualização
      For nContar = 1 to Len(aListaPed)
          If aListaPed[nContar,01] == .T.
             cNota_Fiscal  := aListaPed[nContar,02]
             cSerie_Fiscal := aListaPed[nContar,03]
             nMarcado := nMarcado + 1
          Endif
      Next nContar       

      If nMarcado == 0
         MsgAlert("Atenção! Nenhum pedido de venda foi indicado para visualização.")
         Return(.T.)
      Endif
         
      If nMarcado > 1
         MsgAlert("Atenção! Somente é permitido indicar um pedido de venda de cada vez para visualização.")
         Return(.T.)
      Endif

      U_BOLITAU(.T., cNota_Fiscal, cSerie_Fiscal )

   Endif   

Return(.T.)

// Função que solicita o tipo de inclusão de cliente a ser realizado
Static Function IncNovCli()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgNcli

   DEFINE MSDIALOG oDlgNcli TITLE "Novo Formulário" FROM C(178),C(181) TO C(387),C(447) PIXEL

   @ C(002),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgNcli
   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(123),C(001) PIXEL OF oDlgNcli
   @ C(037),C(005) Say "Selecione o tipo de inclusão de cliente a ser utilizada" Size C(127),C(008) COLOR CLR_BLACK PIXEL OF oDlgNcli
   @ C(047),C(005) Button "Pelo Site do Sefaz" Size C(123),C(017) PIXEL OF oDlgNcli ACTION( oDlgNcli:End(), U_AUTOM246() )
   @ C(065),C(005) Button "Inclusão Manual"    Size C(123),C(017) PIXEL OF oDlgNcli ACTION( AbreTelIncCli() )
   @ C(083),C(005) Button "Voltar"             Size C(123),C(017) PIXEL OF oDlgNcli ACTION( oDlgNcli:End() )

   ACTIVATE MSDIALOG oDlgNcli CENTERED 

Return(.T.)

// Função que solicita o tipo de inclusão de cliente a ser realizado
Static Function AbreTelIncCli()

   Private cCadastro := "Inclusão Cadastro de Clientes"
   
   Inclui := .T.

   // Posiciona no cliente a ser pesquisado
   DbSelectArea("SA1")
   AxInclui("SA1", 0, 3)

   oDlgNcli:End()

Return(.T.)



Static Function GeraXMLCli(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd, dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe) 

Local aDeleta  := {} 

Local cAlias    := GetNextAlias() 
Local cAnoInut  := "" 
Local cAnoInut1 := "" 
Local cCanc        := "" 
Local cChvIni      := "" 
Local cChvFin    := "" 
Local cChvNFe      := "" 
Local cCNPJDEST := Space(14) 
Local cCondicao    := "" 
Local cDestino     := "" 
Local cDrive       := "" 
Local cIdflush  := cSerie+cNotaIni 
Local cModelo      := "" 
Local cNFes     := "" 
Local cPrefixo     := "" 
Local cURL         := PadR(GetNewPar("MV_SPEDURL","http://"),250) 
Local cXmlInut  := "" 
Local cXml        := "" 
Local cWhere    := "" 
Local cXmlProt    := "" 
local cAviso    := "" 
local cErro     := "" 
local cTab          := "" 
local cCmpNum      := "" 
local cCmpSer      := "" 
local cCmpTipo  := "" 
local cCmpLoja  := "" 
local cCmpCliFor:= "" 
local cCnpj      := "" 

Local lOk          := .F. 
Local lFlush      := .T. 
Local lFinal       := .F. 
Local lClearFilter := .F. 
Local lExporta     := .F. 

Local nHandle      := 0 
Local nX        := 0 
Local nY        := 0 

Local aInfXml    := {} 

Local oRetorno 
Local oWS 
Local oXML 

mv_par02 := "000001"

Default nTipo    := 1 
Default cNotaIni:="" 
Default cNotaFim:="" 
Default dDataDe:=CtoD("  /  /  ") 
Default dDataAte:=CtoD("  /  /  ") 
Default lCTe    := .T. 

If nTipo == 3 
    If !Empty( GetNewPar("MV_NFCEURL","") ) 
        cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250) 
    Endif 
Endif 

If IntTMS() //Altera o conteúdo da variavel quando for carta de correção para o CTE 
    cTipoNfe := "SAIDA" 
EndIf 
ProcRegua(Val(cNotaFim)-Val(cNotaIni)) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
//³ Corrigi diretorio de destino                                           ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
SplitPath(cDirDest,@cDrive,@cDestino,"","") 
cDestino := cDrive+cDestino 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
//³ Inicia processamento                                                   ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Do While lFlush 

    If ( nTipo == 1 .And. !lUsaColab ).Or. nTipo == 3 
         oWS:= WSNFeSBRA():New()
         oWS:cUSERTOKEN        := "TOTVS"
         oWS:cID_ENT           := cIdEnt
         oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
         oWS:cIdInicial        := cIdflush // cNotaIni
         oWS:cIdFinal          := cSerie+cNotaFim
         oWS:dDataDe           := dDataDe
         oWS:dDataAte          := dDataAte
         oWS:cCNPJDESTInicial  := cCnpjDIni
         oWS:cCNPJDESTFinal    := cCnpjDFim
         oWS:nDiasparaExclusao := 0
         lOk := oWS:RETORNAFX()
         oRetorno := oWS:oWsRetornaFxResult

        If lOk 
            ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3)) 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
            //³ Exporta as notas                                                       ³ 
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

            For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3) 

                //Ponto de Entrada para permitir filtrar as NF 
                If ExistBlock("SPDNFE01") 
                   If !ExecBlock("SPDNFE01",.f.,.f.,{oRetorno:OWSNOTAS:OWSNFES3[nX]}) 
                      loop 
                   Endif 
                Endif 

                 oXml    := oRetorno:OWSNOTAS:OWSNFES3[nX] 
                oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","") 
                cXML    := "" 
                If Type("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U" 
                    cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) 
                ElseIF Type("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U" 
                    cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT) 
                Else 
                    cCNPJDEST := "" 
                EndIf 
                    cVerNfe := IIf(Type("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '') 
                      cVerCte := Iif(Type("oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT") <> "U", oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT, '') 
                 If !Empty(oXml:oWSNFe:cProtocolo) 
                    cNotaIni := oXml:cID 
                    cIdflush := cNotaIni 
                     cNFes := cNFes+cNotaIni+CRLF 
                     cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id") 
                    cModelo := cChvNFe 
                    cModelo := StrTran(cModelo,"NFe","") 
                    cModelo := StrTran(cModelo,"CTe","") 
                    cModelo := SubStr(cModelo,21,02) 

                    Do Case 
                        Case cModelo == "57" 
                            cPrefixo := "CTe" 
                        Case cModelo == "65" 
                            cPrefixo := "NFCe" 
                        OtherWise 
                            if '<cStat>302</cStat>' $ oXml:oWSNFe:cxmlPROT 
                                cPrefixo := "den" 
                            else 
                                cPrefixo := "NFe" 
                            endif 
                    EndCase 

                     nHandle := FCreate(cDestino+SubStr(cChvNFe,4,44)+"-"+cPrefixo+".xml") 
                     If nHandle > 0 
                         cCab1 := '<?xml version="1.0" encoding="UTF-8"?>' 
                         If cModelo == "57" 
                            //cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v'+cVerCte+'.xsd" versao="'+cVerCte+'">' 
                            cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">' 
                            cRodap := '</cteProc>' 
                        Else 
                            Do Case 
                                Case cVerNfe <= "1.07" 
                                    cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">' 
                                Case cVerNfe >= "2.00" .And. "cancNFe" $ oXml:oWSNFe:cXML 
                                    cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' 
                                OtherWise 
                                    cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' 
                            EndCase 
                            cRodap := '</nfeProc>' 
                        EndIf 
                        FWrite(nHandle,AllTrim(cCab1)) 
                         FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML)) 
 FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT)) 
                        FWrite(nHandle,AllTrim(cRodap)) 
                         FClose(nHandle) 
                         aadd(aDeleta,oXml:cID) 
                         cXML := AllTrim(cCab1)+AllTrim(oXml:oWSNFe:cXML)+AllTrim(cRodap) 
                         If !Empty(cXML) 
                             If ExistBlock("FISEXPNFE") 
 ExecBlock("FISEXPNFE",.f.,.f.,{cXML}) 
                               Endif 
                         EndIF 

                     EndIf 
                 EndIf 

                 If ( oXml:OWSNFECANCELADA <> Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo) ) 

                    cChave       := oXml:OWSNFECANCELADA:CXML 
                     cChaveCc1 := At("<chNFe>",cChave)+7 
                     cChaveCan := SubStr(cChave,cChaveCc1,44) 


                    oWS:= WSNFeSBRA():New() 
                    oWS:cUSERTOKEN    := "TOTVS" 
                    oWS:cID_ENT        := cIdEnt 
                    oWS:_URL        := AllTrim(cURL)+"/NFeSBRA.apw" 
                    oWS:cID_EVENTO    := "110111" 
                    oWS:cChvInicial    := cChaveCan 
                    oWS:cChvFinal    := cChaveCan 
                    lOk                := oWS:NFEEXPORTAEVENTO() 
                    oRetEvCanc     := oWS:oWSNFEEXPORTAEVENTORESULT 


                    if lOk 

                        ProcRegua(Len(oRetEvCanc:CSTRING)) 
 //--------------------------------------------------------------------------- 
                        //| Exporta Cancelamento do Evento da Nf-e                                  | 
 //--------------------------------------------------------------------------- 

                        For nY := 1 To Len(oRetEvCanc:CSTRING) 
                             cXml    := SpecCharc(oRetEvCanc:CSTRING[nY]) 
                             oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso) 
                            if Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U" 
                                cIdEven    := oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT 
                            else 
                                cIdEven  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT 
                            endif 
                             nHandle := FCreate(cDestino+SubStr(cIdEven,3)+"-Canc.xml") 
                             if nHandle > 0 
                                FWrite(nHandle,AllTrim(cXml)) 
                                 FClose(nHandle) 
                             endIf 
                        Next nY 
                    Else 
                        cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id") 
                         cNotaIni := oXml:cID 
                        cIdflush := cNotaIni 
                         cNFes := cNFes+cNotaIni+CRLF 
                         If !"INUT"$oXml:oWSNFeCancelada:cXML 
                             nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can.xml") 
                             If nHandle > 0 
                                 cCanc := oXml:oWSNFeCancelada:cXML 
                                 If cModelo == "57" 
                                     oXml:oWSNFeCancelada:cXML := '<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + oXml:oWSNFeCancelada:cXML + "</procCancCTe>" 
                                 Else 
                                     oXml:oWSNFeCancelada:cXML := '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + oXml:oWSNFeCancelada:cXML + "</procCancNFe>" 
                                 EndIf 
 FWrite(nHandle,oXml:oWSNFeCancelada:cXML) 
                                 FClose(nHandle) 
                                 aadd(aDeleta,oXml:cID) 
                             EndIf 
                             nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can.xml") 
                             If nHandle > 0 
                                 If cModelo == "57" 
                                     FWrite(nHandle,'<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancCTe>") 
                                 Else 
                                    FWrite(nHandle,'<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancNFe>") 
                                 EndIF 
                                 FClose(nHandle) 
                             EndIf 
                        Else 

    //                        If Type("oXml:OWSNFECANCELADA:CXML")<>"U" 
                                 cXmlInut  := oXml:OWSNFECANCELADA:CXML 
                                 cAnoInut1 := At("<ano>",cXmlInut)+5 
                                 cAnoInut  := SubStr(cXmlInut,cAnoInut1,2) 
                                 cXmlProt  := EncodeUtf8(oXml:oWSNFeCancelada:cXMLPROT) 
    //                         EndIf 
                             nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,39)+"-ped-inu.xml") 
                             If nHandle > 0 
 FWrite(nHandle,oXml:OWSNFECANCELADA:CXML) 
                                 FClose(nHandle) 
                                 aadd(aDeleta,oXml:cID) 
                             EndIf 
                             nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,39)+"-inu.xml") 
                             If nHandle > 0 
                                 FWrite(nHandle,cXmlProt) 
                                 FClose(nHandle) 
                             EndIf 
                         EndIf 
                    EndIf 
                EndIf 
                IncProc() 
            Next nX 

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
            //³ Exclui as notas                                                        ³ 
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
            If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0 
                oWS:= WSNFeSBRA():New() 
                oWS:cUSERTOKEN        := "TOTVS" 
                oWS:cID_ENT           := cIdEnt 
                oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0) 
                oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw" 
                oWS:oWSNFEID          := NFESBRA_NFES2():New() 
                oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New() 
                For nX := 1 To Len(aDeleta) 
 aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New()) 
                    Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX] 
                Next nX 
                If !oWS:RETORNANOTAS() 
// Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0046},3) 
                    lFlush := .F. 
                EndIf 
            EndIf 
            aDeleta  := {} 
            If ( Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .And. Empty(cNfes) ) 
//                   Aviso("SPED",STR0106,{"Ok"})    // "Não há dados" 
                lFlush := .F. 
            EndIf 
        Else 
// Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+STR0046,{"OK"},3) 
//            lFinal := .T. 
       EndIf 

        cIdflush := AllTrim(Substr(cIdflush,1,3) + StrZero((Val( Substr(cIdflush,4,Len(AllTrim(mv_par02))))) + 1 ,Len(AllTrim(mv_par02)))) 

        If lExporta 
            If lUsaColab 

                cCnpjDFim := iif(empty(cCnpjDFim),"99999999999999", cCnpjDFim) 

                (cAlias)->(dbGoTop()) 

                While !(cAlias)->(Eof()) 

                    if cTipoNfe == "SAIDA" 
                        cTab := 'F2_' 
                        cCmpCliFor := cTab+'CLIENTE' 
                    else 
                        cTab := 'F1_' 
                        cCmpCliFor := cTab+'FORNECE' 
                    endif 

                    cCmpNum     := cTab+'DOC' 
                    cCmpSer     := cTab+'SERIE' 
                    cCmpTipo    := cTab+'TIPO' 
                    cCmpLoja    := cTab+'LOJA' 
                    cPrefix := iif(nTipo == 1,IIF(lCTe,"CTe","NFe"),"CCe") 

                    //Tratamento para verificar se o CNPJ está no range inserido pelo usuário. 
                    lCnpj :=    .F. 

                    if cPrefix $ "CCe" 
                         lCnpj := .T. 
                    else 

                        If cTipoNfe == "SAIDA" 
                            if (cAlias)->&cCmpTipo $ 'D|B' 
                                cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC") 
                            else 
                                cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC") 
                            endif 
                        else 
                            if (cAlias)->&cCmpTipo $ 'D|B' 
                                cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC") 
                            else 
                                cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC") 
                            endif 
                        endif 

                        if cCnpj >= cCnpjDIni .And. cCnpj <= cCnpjDFim 
                            lCnpj := .T. 
                        endif 
                    endif 

                    If lCnpj 
                        cXML := "" 

                        aInfXml    := {} 
                        aInfXml := ColExpDoc((cAlias)->&cCmpSer,(cAlias)->&cCmpNum,iif(nTipo == 1,IIF(lCTe,"CTE","NFE"),"CCE"),@cXml) 
                         /* 
                             aInfXml 
                             [1] - Logico se encotra documento .T. 
                             [2] - Chave do documento 
                             [3] - XML autorização - someente se autorizado 
                             [4] - XML Cancelamento Evento- somente se autorizado 
                             [5] - XML Ped. Inutilização - somente se autorizado 
                             [6] - XML Prot. Inutilização - somente se autorizado 
                        */ 
                        //Ponto de Entrada para permitir filtrar as NF 
                        If ExistBlock("SPDNFE01") 
                            If !ExecBlock("SPDNFE01",.f.,.f.,{aInfXml}) 
                                (cAlias)->(dbSkip()) 
                                loop 
                            Endif 
                       Endif 
                        //Encontrou documento 
                        if aInfXMl[1] 

                            if cPrefix == "CCe" .And. !Empty( aInfXMl[3] ) 
                                nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-CCe.xml") 
                                cXML := aInfXMl[3] 

                                If nHandle > 0 
                                    FWrite(nHandle,AllTrim(cXml)) 
                                     FClose(nHandle) 
                                 EndIf 
 cNFes+=(cAlias)->&cCmpSer+"/"+(cAlias)->&cCmpNum+CRLF 

                            elseif cPrefix $ "NFe|CTe" 
                                //Iinutilização 
                                if !Empty( aInfXMl[5] ) 
                                    cXmlInut  := aInfXMl[5] 
                                    cAnoInut1 := At("<ano>",cXmlInut)+5 
                                    cAnoInut  := SubStr(cXmlInut,cAnoInut1,2) 
                                    cXmlProt  := aInfXMl[6] 


                                     nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3,2)+cAnoInut+SubStr(aInfXMl[2],5,39)+"-ped-inu.xml") 
                                     If nHandle > 0 
 FWrite(nHandle,oXml:OWSNFECANCELADA:CXML) 
                                         FClose(nHandle) 
                                         aadd(aDeleta,oXml:cID) 
                                     EndIf 
                                     nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(aInfXMl[2],5,39)+".xml") 
                                     If nHandle > 0 
                                         FWrite(nHandle,cXmlProt) 
                                         FClose(nHandle) 
                                     EndIf 
 cNFes+=(cAlias)->&cCmpSer+"/"+(cAlias)->&cCmpNum+CRLF 
                                endif 
                                //Cancelamento 
                                if !Empty( aInfXMl[4] ) 
                                    cXml    := SpecCharc(aInfXMl[4]) 
                                     nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-canc.xml") 
                                     if nHandle > 0 
 FWrite(nHandle,AllTrim(cXml)) 
                                         FClose(nHandle) 
                                     endIf 
 cNFes+=(cAlias)->&cCmpSer+"/"+(cAlias)->&cCmpNum+CRLF 
                                endif 

                                if !Empty( aInfXML[3] ) 
                                    cXml    := SpecCharc(aInfXMl[3]) 

                                     If ExistBlock("FISEXPNFE") 
 ExecBlock("FISEXPNFE",.f.,.f.,{cXML}) 
                                     EndIF 

                                     nHandle := FCreate(cDestino+SubStr(aInfXMl[2],4)+"-"+cPrefix+".xml") 
                                     if nHandle > 0 
 FWrite(nHandle,AllTrim(cXml)) 
                                         FClose(nHandle) 
                                     endIf 

 cNFes+=(cAlias)->&cCmpSer+"/"+(cAlias)->&cCmpNum+CRLF 
                                endif 
                            endif 
                            IncProc() 
                         endif 
                    endif 
                    (cAlias)->(dbSkip()) 
                enddo 
                If !Empty(cNfes) 
//                    If Aviso("SPED",STR0152,{"Sim","Não"}) == 1  //"Solicitação processada com sucesso." 
//                        Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{STR0114},3) 
//                    EndIf 
                endif 

            else 
                oWS:= WSNFeSBRA():New() 
                oWS:cUSERTOKEN    := "TOTVS" 
                oWS:cID_ENT        := cIdEnt 
                oWS:_URL        := AllTrim(cURL)+"/NFeSBRA.apw" 
                oWS:cChvInicial    := cChvIni 
                oWS:cChvFinal    := cChvFin 
                lOk:= oWS:NFEEXPORTAEVENTO() 
                oRetorno := oWS:oWSNFEEXPORTAEVENTORESULT 

                If lOk 

                    ProcRegua(Len(oRetorno:CSTRING)) 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
                    //³ Exporta as cartas                                                      ³ 
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

                    For nX := 1 To Len(oRetorno:CSTRING) 
                         cXml    := oRetorno:CSTRING[nX] 
                         cXml     := EncodeUTF8(cXml) 
                         oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso) 
                        If Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U" 
                            cIdCCe    := oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT 
                        Elseif Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT")<> "U" 
                            cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT 
                        Else 
                            cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_INFEVENTO:_ID:TEXT 
                        Endif 
                         nHandle := FCreate(cDestino+SubStr(cIdCCe,3)+"-CCe.xml") 
                         If nHandle > 0 
                            FWrite(nHandle,AllTrim(cXml)) 
                             FClose(nHandle) 
                         EndIf 
                        IncProc() 
cNFes+=SubStr(cIdCCe,31,3)+"/"+SubStr(cIdCCe,34,9)+CRLF 
                    Next nX 

//                       If Aviso("SPED",STR0152,{"Sim","Não"}) == 1  //"Solicitação processada com sucesso." 
//                        Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{STR0114},3) 
//                    EndIf 
                Else 
// Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3) 
//                    lFinal := .T. 
                EndIF 
            endif 
        EndIf 
        #IFDEF TOP 
            If select (cAlias)>0 
                 (cAlias)->(dbCloseArea()) 
            EndIf 
        #ENDIF 
        lFlush := .F. 
    EndIF 
EndDo 

Return(.T.) 

// Função que abre tela de solicitação de auxilio ao departamento de projetos
Static Function AbrAuxilio(_AxFilial, _AxOperacao, _AxOportunidade, _AxCliente, _AxLojaCli, _AxNomeCliente, _AxVendedor, _AxNomeVendedor, _AxStatusProposta)

   Local cSql              := ""
   Local lChumbaX          := .F.
   Local cMemo1	           := ""
   Local oMemo1
   
   Private lPodeSeguir     := .F.

   Private cAxFilial       := _AxFilial
   Private cAxOportunidade := _AxOportunidade
   Private cAxCliente      := _AxCliente
   Private cAxLoja    	   := _AxLojaCli
   Private cAxNomeCli      := _AxNomeCliente
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private aPortal := {}

   Private oDlgPV

   // Verifica se existe  o arquivo AtechHttpPost.Exe no diretório SmartClient do equipamento do usuário
   If !File(GetClientDir() + "ATECHHTTPPOST.EXE")
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Arquivo AtechHttpPost.Exe não está presente no diretório SmartClient." + chr(13) + chr(10) + "Entre em contato com a área de projetos (Protheus) informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_AxCliente))
      MsgAlert("Necessário informar o Cliente antes de solicitar Auxilio Pré-Venda.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_AxVendedor))
      MsgAlert("Necessário informar o Vendedor antes de solicitar Auxilio Pré-Venda.")
      Return(.T.)
   Endif
   
   // Verifica se o vendedor selecionado passui informação da chave de acesso a API do AtechPortal
   If Select("T_ACESSOAPI") > 0
      T_ACESSOAPI->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZTI_FILIAL,"
   cSql += "       ZTI_IDCO  ,"
   cSql += "       ZTI_IDNO  ,"
   cSql += "       ZTI_IDCH  ,"
   cSql += "       ZTI_LPRO   "
   cSql += "  FROM " + RetSqlName("ZTI")
   cSql += " WHERE D_E_L_E_T_      = ''"
   cSql += "   AND UPPER(ZTI_LPRO) = '" + Alltrim(Upper(cUserName)) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSOAPI", .T., .T. )
   
   If T_ACESSOAPI->( EOF() )
      
      IncluiAcessoApi()      

      If lPodeSeguir == .F.
         MsgAlert("Atenção!"                                             + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Chave de Acesso ao API do Atechportal não informado." + chr(13) + chr(10)                     + ;
                  "Auxílio a Área de Projetos não permitida.")
         Return(.T.)
      Endif
      
   Endif

   // Envia para a função que carrega a lista de tarefas do portal para a oportunidade selecionada
   CarregaAtechPortal(1, _AxOportunidade, _AxCliente, _AxLojaCli)
   
   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgPV TITLE "Solicitação Auxilio Pré-Venda" FROM C(178),C(181) TO C(529),C(806) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgPV

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(304),C(001) PIXEL OF oDlgPV

   @ C(036),C(005) Say "Filial"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
   @ C(036),C(077) Say "Nº Oportunidade"      Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
   @ C(036),C(122) Say "Cliente"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
   @ C(057),C(005) Say "Terefas Relacionadas" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
   @ C(058),C(163) Say "Duplo Click no Nº Tarefa para visualiza tarefa no AtechPortal" Size C(146),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
   @ C(045),C(005) MsGet oGet1 Var _AxFilial       Size C(067),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPV When lChumbaX
   @ C(045),C(077) MsGet oGet2 Var _AxOportunidade Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPV When lChumbaX
   @ C(045),C(123) MsGet oGet3 Var _AxCliente      Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPV When lChumbaX
   @ C(045),C(151) MsGet oGet4 Var _AxLojaCli      Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPV When lChumbaX
   @ C(045),C(172) MsGet oGet5 Var _AxNomeCliente  Size C(136),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPV When lChumbaX

   If Substr(_AxStatusProposta,01,01) == "9"
      @ C(159),C(005) Button "Incluir Tarefa"             Size C(054),C(012) PIXEL OF oDlgPV ACTION( AbreTarefaAtech(_AxFilial, "I", _AxOportunidade, _AxCliente, _AxLojaCli, _AxNomeCliente, _AxVendedor, _AxNomeVendedor, aPortal[oPortal:nAt,05])) When lChumbaX
   Else
      @ C(159),C(005) Button "Incluir Tarefa"             Size C(054),C(012) PIXEL OF oDlgPV ACTION( AbreTarefaAtech(_AxFilial, "I", _AxOportunidade, _AxCliente, _AxLojaCli, _AxNomeCliente, _AxVendedor, _AxNomeVendedor, aPortal[oPortal:nAt,05]))
   Endif

   @ C(159),C(063) Button "Visualiza Lançamento"       Size C(062),C(012) PIXEL OF oDlgPV ACTION( AbreTarefaAtech(_AxFilial, "V", _AxOportunidade, _AxCliente, _AxLojaCli, _AxNomeCliente, _AxVendedor, _AxNomeVendedor, aPortal[oPortal:nAt,05]))
// @ C(159),C(129) Button "Visualiza Tarefa no Portal" Size C(085),C(012) PIXEL OF oDlgPV ACTION( AbreURLPortal(aPortal[oPortal:nAt,01]) )
   @ C(159),C(271) Button "Voltar"                     Size C(037),C(012) PIXEL OF oDlgPV ACTION( oDlgPV:End() )

   // Inicializa o browse 
   oPortal := TCBrowse():New( 082 , 005, 388, 115,,{'Nº Tarefa Portal' + Space(010)  ,; // 01 - Nº Tarefa do Portal
                                                    'Título'           + Space(150)  ,; // 02 - Título da Tarefa
                                                    'Situação'         + Space(005)  ,; // 03 - Situação da Tarefa
                                                    'Data'             + Space(010)  ,; // 04 - Data da Tarefa
                                                    'Nº Controle'      + Space(010)} ,; // 05 - Código de Controle
                                                    {20,50,50,50},oDlgPV,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oPortal:SetArray(aPortal) 
       
   oPortal:bLine := {||{ aPortal[oPortal:nAt,01],;
                         aPortal[oPortal:nAt,02],;
                         aPortal[oPortal:nAt,03],;
                         aPortal[oPortal:nAt,04],;
                         aPortal[oPortal:nAt,05]}}
      
   oPortal:Refresh()

   oPortal:bLDblClick := {|| AbreURLPortal(aPortal[oPortal:nAt,01]) } 

   ACTIVATE MSDIALOG oDlgPV CENTERED 

Return(.T.)

// Função que carrega o array aportal
Static Function CarregaAtechPortal(__Carga, _AxOportunidade, _AxCliente, _AxLojaCli)

   Local cSql := ""

   aPortal := {}

   If Select("T_PORTAL") > 0
      T_PORTAL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTH_FILIAL,"
   cSql += "       ZTH_CODI  ,"
   cSql += "       ZTH_DATA  ,"
   cSql += "       ZTH_HORA  ,"
   cSql += "       ZTH_USUA  ,"
   cSql += "       ZTH_PORT  ,"
   cSql += "       ZTH_CFIL  ,"
   cSql += "       ZTH_OPOR  ,"
   cSql += "       ZTH_CLIE  ,"
   cSql += "       ZTH_LOJA  ,"
   cSql += "       ZTH_TITU  ,"
   cSql += "       ZTH_DETA  ,"
   cSql += "       ZTH_STAT   "
   cSql += "  FROM " + "ZTH010"
   cSql += " WHERE ZTH_OPOR = '" + Alltrim(_AxOportunidade) + "'"
   cSql += "   AND ZTH_CLIE = '" + Alltrim(_AxCliente)      + "'"
   cSql += "   AND ZTH_LOJA = '" + Alltrim(_AxLojaCli)      + "'"
   cSql += "   AND ZTH_DELE = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTAL", .T., .T. )

   T_PORTAL->( DbGoTop() )
   
   WHILE !T_PORTAL->( EOF() )
      aAdd( aPortal, { T_PORTAL->ZTH_PORT ,;
                       T_PORTAL->ZTH_TITU ,;
                       T_PORTAL->ZTH_STAT ,;
                       Substr(T_PORTAL->ZTH_DATA,07,02) + "/" + Substr(T_PORTAL->ZTH_DATA,05,02) + "/" + Substr(T_PORTAL->ZTH_DATA,01,04) ,;
                       T_PORTAL->ZTH_CODI })
      T_PORTAL->( DbSkip() )
   ENDDO   

   If Len(aPortal) == 0
      aAdd( aPortal, { "", "", "", "", "" } )
   Endif

   If __Carga == 1
      Return(.T.)
   Endif
      
   // Seta vetor para a browse                            
   oPortal:SetArray(aPortal) 
       
   oPortal:bLine := {||{ aPortal[oPortal:nAt,01],;
                         aPortal[oPortal:nAt,02],;
                         aPortal[oPortal:nAt,03],;
                         aPortal[oPortal:nAt,04],;
                         aPortal[oPortal:nAt,05]}}
      
   oPortal:Refresh()
     
Return(.T.)

// Função que abre a tarefa no Portal Atech para a tarefa selecionada
Static Function AbreURLPortal(__URLPortal)
                                         
   If Empty(Alltrim(__URLPortal))
      MsgAlert("Visualização não permitida pois a tarefa no portal ainda não foi criada.")
      Return(.T.)
   Endif  
        
   // Abre a página do Atech Portal posicionado na tarefa selecionada
   winexec("C:\Program Files\Internet Explorer\IEXPLORE.EXE " + "http://automatechweb.cloudapp.net/redmine/issues/" + Alltrim(__URLPortal),3)
   
Return(.T.)

// Função que permite a abertura de chamado no Atechportal Automatech
Static Function AbreTarefaAtech(_AxFilial, _AxOperacao, _AxOportunidade, _AxCliente, _AxLojaCli, _AxNomeCliente, _AxVendedor, _AxNomeVendedor, _AxCodigo)
 
   Local lChumbaAA := .F.
   Local cMemo1	   := ""
   Local cMemo3	   := ""
   Local oMemo1
   Local oMemo3

   Private _AtechFilial   := Space(050)
   Private _AtechOportu   := Space(006)
   Private _AtechCliente  := Space(006)
   Private _AtechLoja 	  := Space(003)
   Private _AtechNcliente := Space(100)
   Private _AtechVendedor := Space(100)
   Private _AtechCodigo   := Space(005)
   Private _AtechData     := Ctod("  /  /    ")
   Private _AtechHora     := Space(010)
   Private _AtechUsuario  := Space(020)
   Private _AtechTitulo   := Space(100)
   Private _AtechDetalhe  := ""
   Private _AtechPortal   := Space(005)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12
   Private oMemo2

   Private oDlgAtech

   // Se solicitado visualização, pesquisa dados para visualizar
   If _AxOperacao == "I"

      _AtechFilial   := _AxFilial
      _AtechOportu   := _AxOportunidade
      _AtechCliente  := _AxCliente
      _AtechLoja 	 := _AxLojaCli
      _AtechNcliente := _AxNomeCliente
      _AtechVendedor := Alltrim(_AxVendedor) + " - " + Alltrim(_AxNomeVendedor)
      _AtechCodigo   := _AxCodigo
      _AtechData     := Date()
      _AtechHora     := Time()
      _AtechUsuario  := cUserName
      _AtechTitulo   := Space(100)
      _AtechDetalhe  := ""
      _AtechPortal   := Space(05)
   
   Else

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZTH.ZTH_CODI,"
      cSql += "       ZTH.ZTH_DATA,"
      cSql += "       ZTH.ZTH_HORA,"
      cSql += "       ZTH.ZTH_USUA,"
      cSql += "       ZTH.ZTH_PORT,"
      cSql += "       ZTH.ZTH_CFIL,"
      cSql += "       ZTH.ZTH_OPOR,"
      cSql += "       ZTH.ZTH_CLIE,"
      cSql += "       ZTH.ZTH_LOJA,"
      cSql += "       SA1.A1_NOME ,"
      cSql += "       ZTH.ZTH_TITU,"
      cSql += "       ZTH.ZTH_DETA,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZTH.ZTH_DETA)) AS DETALHE,"
      cSql += "       ZTH.ZTH_STAT,"
      cSql += "       ZTH.ZTH_VEND,"
	  cSql += "       SA3.A3_NOME  "
      cSql += "  FROM " + "ZTH010" + " ZTH, "
      cSql += "       " + RetSqlName("SA3") + " SA3, "
      cSql += "       " + RetSqlName("SA1") + " SA1  "
      cSql += " WHERE ZTH_CODI       = '" + Alltrim(_AxCodigo) + "'"
      cSql += "   AND ZTH_DELE       = ''"
      cSql += "   AND SA3.A3_COD     = ZTH.ZTH_VEND"
      cSql += "   AND SA3.D_E_L_E_T_ = ''"
      cSql += "   AND SA1.A1_COD     = ZTH.ZTH_CLIE"
      cSql += "   AND SA1.A1_LOJA    = ZTH.ZTH_LOJA"
      cSql += "   AND SA1.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      _AtechFilial   := T_CONSULTA->ZTH_CFIL
      _AtechOportu   := T_CONSULTA->ZTH_OPOR
      _AtechCliente  := T_CONSULTA->ZTH_CLIE
      _AtechLoja 	 := T_CONSULTA->ZTH_LOJA
      _AtechNcliente := T_CONSULTA->A1_NOME
      _AtechVendedor := Alltrim(T_CONSULTA->ZTH_VEND) + " - " + Alltrim(T_CONSULTA->A3_NOME)
      _AtechCodigo   := T_CONSULTA->ZTH_CODI
      _AtechData     := Substr(T_CONSULTA->ZTH_DATA,07,02) + "/" + Substr(T_CONSULTA->ZTH_DATA,05,02) + "/" + Substr(T_CONSULTA->ZTH_DATA,01,04)
      _AtechHora     := T_CONSULTA->ZTH_HORA
      _AtechUsuario  := T_CONSULTA->ZTH_USUA
      _AtechTitulo   := T_CONSULTA->ZTH_TITU
      _AtechDetalhe  := T_CONSULTA->DETALHE
      _AtechPortal   := T_CONSULTA->ZTH_PORT

   Endif

   DEFINE MSDIALOG oDlgAtech TITLE "Solicitação Auxilio Pré-Venda" FROM C(178),C(181) TO C(570),C(806) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgAtech

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(304),C(001) PIXEL OF oDlgAtech
   @ C(095),C(003) GET oMemo3 Var cMemo3 MEMO Size C(304),C(001) PIXEL OF oDlgAtech

   @ C(034),C(005) Say "Filial"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(034),C(077) Say "Nº Oportunidade"  Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(034),C(122) Say "Cliente"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(053),C(005) Say "Vendedor"         Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(072),C(005) Say "Código"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(072),C(032) Say "Data Abertura"    Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(072),C(077) Say "Hora"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(072),C(123) Say "Aberto por"       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(072),C(270) Say "Nº Tarefa Portal" Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(097),C(005) Say "Título da Tarefa" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech
   @ C(118),C(005) Say "Detalhes da Tarefa (Especifique o máximo possível para que a área de Projetos possa lhe ajudar com mais agilidade)." Size C(278),C(008) COLOR CLR_BLACK PIXEL OF oDlgAtech

   @ C(042),C(005) MsGet oGet1  Var _AtechFilial        Size C(067),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(042),C(077) MsGet oGet2  Var _AtechOportu        Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(042),C(123) MsGet oGet3  Var _AtechCliente       Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(042),C(151) MsGet oGet4  Var _AtechLoja          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(042),C(172) MsGet oGet5  Var _AtechNcliente      Size C(136),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA

   @ C(061),C(005) MsGet oGet12 Var _AtechVendedor      Size C(304),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(082),C(005) MsGet oGet7  Var _AtechCodigo        Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(082),C(032) MsGet oGet8  Var _AtechData          Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(082),C(077) MsGet oGet9  Var _AtechHora          Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(082),C(123) MsGet oGet10 Var _AtechUsuario       Size C(140),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
   @ C(082),C(270) MsGet oGet11 Var _AtechPortal        Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA

   If _AxOperacao == "I"
      @ C(107),C(005) MsGet oGet6  Var _AtechTitulo        Size C(304),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech
      @ C(128),C(005) GET   oMemo2 Var _AtechDetalhe  MEMO Size C(304),C(048)                              PIXEL OF oDlgAtech
   Else
      @ C(107),C(005) MsGet oGet6  Var _AtechTitulo        Size C(304),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAtech When lChumbaAA
      @ C(128),C(005) GET   oMemo2 Var _AtechDetalhe  MEMO Size C(304),C(048)                              PIXEL OF oDlgAtech When lChumbaAA
   Endif

   If _AxOperacao == "I"
      @ C(180),C(232) Button "Gravar" Size C(037),C(012) PIXEL OF oDlgAtech ACTION( GravaAtechPortal() )
   Endif

   @ C(180),C(271) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgAtech ACTION( oDlgAtech:End() )

   ACTIVATE MSDIALOG oDlgAtech CENTERED 

Return(.T.)

// Função que grava permite a abertura de chamado no Atechportal Automatech
Static Function GravaAtechPortal()

   If Empty(Alltrim(_AtechTitulo))
      MsgAlert("Título da Tarefa não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(_AtechDetalhe))
      MsgAlert("Detalhe da Tarefa não informado.")
      Return(.T.)
   Endif

   // Pesquisa o próximo código para inclusão
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql += "SELECT TOP(1) R_E_C_N_O_ AS PROXIMO FROM " + "ZTH010" + " ORDER BY R_E_C_N_O_ DESC"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )
   
   _Proximo := T_PROXIMO->PROXIMO + 1

   // Grava os dados na tebale ZTH -> Cadastro de Tarefas no Portal Atech
   RecLock("ZTH",.T.)
   ZTH_FILIAL := "" 
   ZTH_CODI   := Alltrim(STR(_PROXIMO))
   ZTH_DATA   := _AtechData
   ZTH_HORA   := _AtechHora
   ZTH_USUA   := _AtechUsuario
   ZTH_PORT   := Space(05)
   ZTH_CFIL   := _AtechFilial
   ZTH_OPOR   := _AtechOportu
   ZTH_CLIE   := _AtechCliente
   ZTH_LOJA   := _AtechLoja
   ZTH_TITU   := _AtechTitulo
// ZTH_DETA   := NOACENTO(_AtechDetalhe)
   ZTH_DETA   := _AtechDetalhe
   ZTH_STAT   := "A"
   ZTH_VEND   := Substr(_AtechVendedor,01,06)
   MsUnLock()              

   oDlgAtech:End()   

   CarregaAtechPortal(2, _AtechOportu, _AtechCliente, _AtechLoja)
   
Return(.T.)

// ------------------------------------------------------------------------------ //
// Função que abre o questionamento da solicitação de auxilio da área de projetos //
// ------------------------------------------------------------------------------ //
// _xVoportunidade = Código da Oportunidade de Venda                              //
// _xVcliente      = Código do Cliente                                            //
// _xVloja         = Loja do Cliente                                              //
// __TipoPergunta  = Indica o tipo de pergunta a ser realizada, sendo:            //
//                   1 - Pergunta em caso de suceeso, pergunta a 1 e a 2          //
//                   3 - Pergunta somente a pergunta do tipo 3                    //
// ------------------------------------------------------------------------------ //

Static Function VerificaAuxilio(_xVoportunidade, _xVcliente, _xVloja, __TipoPergunta)

   Local cSql       := ""
   Local nContar    := 0

   Local _AuxilioCod := Space(05)
   Local _AuxilioCli := Space(06)
   Local _AuxilioLoj := Space(03)

   Private aPergunta1 := {}
   Private aPergunta2 := {}
   Private aPergunta3 := {}   

   __Tem_Auxilio := .F.    
   __Pode_Seguir := .F.

   // Verifica se existe solicitação de auxilio a área de projetos
   If Select("T_AUXILIO") > 0
      T_AUXILIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTH_FILIAL,
   cSql += "       ZTH_CODI  ,
   cSql += "	   ZTH_DATA  ,
   cSql += "	   ZTH_HORA  ,
   cSql += "	   ZTH_USUA  ,
   cSql += "	   ZTH_PORT  ,
   cSql += "	   ZTH_CFIL  ,
   cSql += "	   ZTH_OPOR  ,
   cSql += "	   ZTH_CLIE  ,
   cSql += "	   ZTH_LOJA  ,
   cSql += "	   ZTH_TITU  ,
   cSql += "	   ZTH_DETA  ,
   cSql += "	   ZTH_DELE  ,
   cSql += "	   ZTH_STAT  ,
   cSql += "	   ZTH_VEND
   cSql += "     FROM " + "ZTH010"
   cSql += "    WHERE ZTH_DELE = ''"
   cSql += "      AND ZTH_OPOR = '" + Alltrim(_xVoportunidade) + "'"
   cSql += "      AND ZTH_CLIE = '" + Alltrim(_xVcliente)      + "'"
   cSql += "      AND ZTH_LOJA = '" + Alltrim(_xVloja)         + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AUXILIO", .T., .T. )

   If T_AUXILIO->( EOF() )
      __Tem_Auxilio := .F.
      Return(.T.)
   Else
      __Tem_Auxilio := .T.
   Endif

   // Carrega variáveis com os dados de chave da solicitação
   _AuxilioCod := T_AUXILIO->ZTH_OPOR
   _AuxilioCli := T_AUXILIO->ZTH_CLIE
   _AuxilioLoj := T_AUXILIO->ZTH_LOJA

   // Carrega os array aPergunta1, aPergunta2 e aPergunta3 com os dados do Parametrizador Automatech
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_PER1,"
   cSql += "       ZZ4_PER2,"
   cSql += "       ZZ4_PER3,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_RES1)) AS RESP1,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_RES2)) AS RESP2,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_RES3)) AS RESP3 "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
       __Pode_Seguir := .F.   
       Return(.T.)
   Endif
  
   // Carrega o array aPergunta1
   aAdd( aPergunta1, { _AuxilioCod, _AuxilioCli, _AuxilioLoj, T_PARAMETROS->ZZ4_PER1, T_PARAMETROS->RESP1, "" } )
                       
   // Carrega o array aPergunta2
   aAdd( aPergunta2, { _AuxilioCod, _AuxilioCli, _AuxilioLoj, T_PARAMETROS->ZZ4_PER2, T_PARAMETROS->RESP2, "" } )

   // Carrega o array aPergunta3
   aAdd( aPergunta3, { _AuxilioCod, _AuxilioCli, _AuxilioLoj, T_PARAMETROS->ZZ4_PER3, T_PARAMETROS->RESP3, "" } )

   // Envia para a função que abre a janela e mostra apergunta e solicita a resposta do usuário
   Do Case

      Case __TipoPergunta == 1

           // Solicita a Primeira resposta
           JANELAPERGUNTA(1)

           If Substr(aPergunta1[1][6],01,09) == "Selecione"           
              __Pode_Seguir == .F.              
              Return(.T.)
           Endif   
      
           // Solicita a Segunda resposta
           JANELAPERGUNTA(2)
           
      Case __TipoPergunta == 3
      
           // Solicita a Terceira resposta
           JANELAPERGUNTA(3)

   EndCase   

   // Verifica o retorno da resposta do usuário
   Do Case
      Case __TipoPergunta == 1
           If Substr(aPergunta1[1][6],01,09) == "Selecione" .Or. Substr(aPergunta2[1][6],01,09) == "Selecione"
              __Pode_Seguir := .F.   
           Else
              __Pode_Seguir := .T.   
           Endif   

      Case __TipoPergunta == 3
           If Substr(aPergunta3[1][6],01,09) == "Selecione"
              __Pode_Seguir := .F.   
           Else
              __Pode_Seguir := .T.   
           Endif   
   EndCase        

   // Verifica se pode proseguir com a gravação das perguntas e respoistas dadas pelo usuário
   If __Pode_Seguir == .F.   
      Return(.T.)
   Endif
      
   // Realiza a gravação dos dados

   // Caotura os auxilios para gravação das perguntas e respostas
   If Select("T_AUXILIO") > 0
      T_AUXILIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTH_FILIAL,"
   cSql += "       ZTH_CODI  ,"
   cSql += "	   ZTH_DATA  ,"
   cSql += "	   ZTH_HORA  ,"
   cSql += "	   ZTH_USUA  ,"
   cSql += "	   ZTH_PORT  ,"
   cSql += "	   ZTH_CFIL  ,"
   cSql += "	   ZTH_OPOR  ,"
   cSql += "	   ZTH_CLIE  ,"
   cSql += "	   ZTH_LOJA  ,"
   cSql += "	   ZTH_TITU  ,"
   cSql += "	   ZTH_DETA  ,"
   cSql += "	   ZTH_DELE  ,"
   cSql += "	   ZTH_STAT  ,"
   cSql += "	   ZTH_VEND   "
   cSql += "   FROM " + "ZTH010"
   cSql += "  WHERE ZTH_DELE = ''"
   cSql += "    AND ZTH_OPOR = '" + Alltrim(_AuxilioCod) + "'"
   cSql += "    AND ZTH_CLIE = '" + Alltrim(_AuxilioCli) + "'"
   cSql += "    AND ZTH_LOJA = '" + Alltrim(_AuxilioLoj) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AUXILIO", .T., .T. )

   T_AUXILIO->( DbGoTop() )
           
   WHILE !T_AUXILIO->( EOF() )
         
      // Atualiza  os dados da solicitação de auxilio a área de projetos
      DbSelectArea("ZTH")
      DbSetOrder(1)
            
      If DbSeek(xFilial("ZTH") + T_AUXILIO->ZTH_CODI + T_AUXILIO->ZTH_CLIE + T_AUXILIO->ZTH_LOJA)
           
         RecLock("ZTH",.F.)

         ZTH_STAT := "E"

         Do Case

            Case __TipoPergunta == 1

                 ZTH_PER1 := aPergunta1[1][4]
                 ZTH_TOD1 := aPergunta1[1][5]
                 ZTH_RES1 := aPergunta1[1][6]
                    
                 ZTH_PER2 := aPergunta2[1][4]
                 ZTH_TOD2 := aPergunta2[1][5]
                 ZTH_RES2 := aPergunta2[1][6]

            Case __TipoPergunta == 3

                 ZTH_PER3 := aPergunta3[1][4]
                 ZTH_TOD3 := aPergunta3[1][5]
                 ZTH_RES3 := aPergunta3[1][6]
                    
         EndCase        

         MsUnLock()              

      Endif
            
      T_AUXILIO->( DbSkip() )
        
   ENDDO

Return(.T.)

// Função que abre a janela para o usuário informar a resposta da pergunta conforme parâmetro
Static Function JANELAPERGUNTA(__TipoPergunta)

   Local nContar   := 0
   Local cPergunta := ""
   Local aResposta := {}
  
   Local cResposta

   Private oDlgPergunta

   Do Case
      Case __TipoPergunta == 1
           cPergunta := aPergunta1[1][4]
           aAdd( aResposta, "Selecione a resposta" )
           For nContar = 1 to 20
               If Empty(Alltrim(U_P_CORTA(aPergunta1[1][5], "|", nContar)))
               Else
                  aAdd( aResposta, U_P_CORTA(aPergunta1[1][5], "|", nContar) )
               Endif
           Next nContar       
      Case __TipoPergunta == 2
           cPergunta := aPergunta2[1][4]
           aAdd( aResposta, "Selecione a resposta" )
           For nContar = 1 to 20
               If Empty(Alltrim(U_P_CORTA(aPergunta2[1][5], "|", nContar)))
               Else
                  aAdd( aResposta, U_P_CORTA(aPergunta2[1][5], "|", nContar) )
               Endif
           Next nContar       
      Case __TipoPergunta == 3
           cPergunta := aPergunta3[1][4]
           aAdd( aResposta, "Selecione a resposta" )
           For nContar = 1 to 20
               If Empty(Alltrim(U_P_CORTA(aPergunta3[1][5], "|", nContar)))
               Else
                  aAdd( aResposta, U_P_CORTA(aPergunta3[1][5], "|", nContar) )
               Endif
           Next nContar       
   EndCase

   DEFINE MSDIALOG oDlgPergunta TITLE "Questionário" FROM C(178),C(181) TO C(351),C(717) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlgPergunta

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(256),C(001) PIXEL OF oDlgPergunta

   @ C(041),C(005) Say cPergunta Size C(300),C(009) COLOR CLR_BLACK PIXEL OF oDlgPergunta

   @ C(054),C(005) ComboBox cResposta Items aResposta Size C(255),C(010) PIXEL OF oDlgPergunta

   @ C(070),C(095) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgPergunta ACTION( FechaPer(1, cResposta, __TipoPergunta) )
   @ C(070),C(133) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgPergunta ACTION( FechaPer(2, cResposta, __TipoPergunta) )

   ACTIVATE MSDIALOG oDlgPergunta CENTERED 

Return(.T.)

// Função que fecha a janela de pergunta e resposta
Static Function FechaPer(__BotaoAcionado, __kResposta, __tPergunta)

   Do Case
      Case __tPergunta == 1
           aPergunta1[1][6] := __kResposta
      Case __tPergunta == 2
           aPergunta2[1][6] := __kResposta
      Case __tPergunta == 3
           aPergunta3[1][6] := __kResposta
   EndCase
              
   oDlgPergunta:End()
   
Return(.T.)   
















                                 
// ------------------------------------------------------------ // 
// Função que fecha a janela da pergunta validando o resultado  //
// -----------------------------------------------------------  //
// __VerTipo   = Botão acionado 1 - Confirma, 2 - Voltar        //
// __kPergunta = Pergunta realizada                             //
// __xResposta = Contém todas as possíveis resposta da pergunta //
// __kResposta = Resposta selecionada pelo usuário              //
// __KCodigo   = Código da oportunidade de venda                //
// __KCliente  = código do cliente                              //
// __KLoja     = loja do cliente                                //
// __tPergunta = Indica o tipo de pergunta realizada            //
// ------------------------------------------------------------ //
Static Function xFechaVerAuxilio(__VerTipo, __kPergunta, __xResposta,  __kResposta, __KCodigo,  __KCliente, __KLoja, __tPergunta)

   Private oDlgPergunta2

   // Em caso de botão cancelar acionado
   If __VerTipo == 2
      __Pode_Seguir := .F.   
   Endif

   // Em caso de botão confirmar acionado
   If __VerTipo == 1

      Do Case
      
         // Se Resposta estiver vazia
         Case Empty(Alltrim(__kResposta))
              __Pode_Seguir := .F.         

         // Se Resposta não foi selecionada
         Case Substr(__kResposta,01,09) == "Selecione"
              __Pode_Seguir := .F.         

         Otherwise
         
              __Pode_Seguir := .T.            

              // Se tipo de pergunta for do tipo 3, grava os dados diretamente.
              // Em caso de pergunta do tipo 1, indica encerramento com sucesso da oportunidade de venda. Neste caso, guarda os dados
              // da primeira pergunta e somente irá gravar os dados se a segunda pergunta for respondida.

              If __tPergunta == 3
                 // Pesquisa os auxilios a área de projetos para atualizar os dados
                 If Select("T_AUXILIO") > 0
                    T_AUXILIO->( dbCloseArea() )
                 EndIf

                 cSql := ""
                 cSql := "SELECT ZTH_FILIAL,
                 cSql += "       ZTH_CODI  ,
                 cSql += "	      ZTH_DATA  ,
                 cSql += "	      ZTH_HORA  ,
                 cSql += "	      ZTH_USUA  ,
                 cSql += "	      ZTH_PORT  ,
                 cSql += "	      ZTH_CFIL  ,
                 cSql += "	      ZTH_OPOR  ,
                 cSql += "	      ZTH_CLIE  ,
                 cSql += "	      ZTH_LOJA  ,
                 cSql += "	      ZTH_TITU  ,
                 cSql += "	      ZTH_DETA  ,
                 cSql += "	      ZTH_DELE  ,
                 cSql += "	      ZTH_STAT  ,
                 cSql += "	      ZTH_VEND
                 cSql += "   FROM " + "ZTH010"
                 cSql += "  WHERE ZTH_DELE = ''"
                 cSql += "    AND ZTH_OPOR = '" + Alltrim(__KCodigo)  + "'"
                 cSql += "    AND ZTH_CLIE = '" + Alltrim(__KCliente) + "'"
                 cSql += "    AND ZTH_LOJA = '" + Alltrim(__KLoja)    + "'"

                 cSql := ChangeQuery( cSql )
                 dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AUXILIO", .T., .T. )

                 T_AUXILIO->( DbGoTop() )
           
                 WHILE !T_AUXILIO->( EOF() )
         
                    // Atualiza  os dados da solicitação de auxilio a área de projetos
                    DbSelectArea("ZTH")
                    DbSetOrder(1)
            
                    If DbSeek(xFilial("ZTH") + T_AUXILIO->ZTH_CODI + T_AUXILIO->ZTH_CLIE + T_AUXILIO->ZTH_LOJA)
                
                       RecLock("ZTH",.F.)
                       ZTH_STAT := "E"
                       ZTH_PERG := __kPergunta
                       ZTH_XRES := __xResposta
                       ZTH_TPER := __tPergunta
                       ZTH_RESP := __kResposta
                       MsUnLock()              

                    Endif
            
                    T_AUXILIO->( DbSkip() )
            
                 ENDDO
              
              Else
              
                 // Abrirá a tela abaixo quando o tipo de perginta for == 1.
                 // A tela abaixo refere-se a segunda pergunta
                 DEFINE MSDIALOG oDlgPergunta2 TITLE "Questionário" FROM C(178),C(181) TO C(351),C(717) PIXEL

                 @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlgPergunta2

                 @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(256),C(001) PIXEL OF oDlgPergunta2

                 @ C(041),C(005) Say cPergunta Size C(255),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta2

                 @ C(052),C(005) ComboBox cResposta Items aResposta Size C(255),C(010) PIXEL OF oDlgPergunta2

                 @ C(068),C(095) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgPergunta2 ACTION( FechaVerAuxilio(1, cPergunta, xResposta, cResposta, _xVoportunidade, _xVcliente, _xVloja, __TipoPergunta, cResposta2) )
                 @ C(068),C(133) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgPergunta2 ACTION( FechaVerAuxilio(2, cPergunta, xResposta, cResposta, _xVoportunidade, _xVcliente, _xVloja, __TipoPergunta, cResposta2) )

                 ACTIVATE MSDIALOG oDlgPergunta2 CENTERED 






              
              Endif

         EndCase

   Endif

   oDlgPergunta:End()
   
Return(.T.)

// Função que inclui no atch portal
Static Function ChamaAtech()
            	
   Local cString  := ""
   Local cSURL    := "http://atechpoaprj01:81/redmine/"
   Local cRetorno := "E:\ATECH_PORTAL\RETORNO.TXT"

   cString := ""
// cString := "POST /issues.xml "

   cString := "key=755ec64118ca8aff4614f6636c2ad6c51403a66a "
   cString += "<?xml version='1.0'?> "
   cString += "<issue> "
   cString += "<project_id>9</project_id> "
   cString += "<subject>Tarefa de Teste do Harald</subject> "
   cString += "<description>Aqui deve ser colocado a descrição da tarefa</description> "
   cString += "<priority_id>4</priority_id> "
   cString += "<tracker_id>4</tracker_id> "
   cString += "<status_id>1</status_id> "
   cString += "<assigned_to_id>10</assigned_to_id> "


   // Abre aplicação em VB para transmissão do arquivo de produtos
   WinExec("AtechHttpPost.exe" + " " + Alltrim(cSURL) + " " + Alltrim(cRetorno) + " " + Alltrim(cString) + " " + "--ignore_remote_cert")

Return(.T.)

// Função que abre a janela de inclusão da chave de acesso API do AtechPortal
Static Function IncluiAcessoApi()

   Local cMemo1	 := ""
   Local oMemo1
      
   Private cAPIChave := Space(50)
   Private cAPILogin := Space(10)
   Private cAPINomeC := Space(40)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgAcessoApi

   lPodeSeguir := .F.

   DEFINE MSDIALOG oDlgAcessoApi TITLE "Chave de Acesso API AtechPortal" FROM C(178),C(181) TO C(650),C(670) PIXEL

   @ C(001),C(003) Say "Siga os passos abaxio e insira o seu código de acesso a API do AtechPortal." Size C(191),C(008) COLOR CLR_BLACK PIXEL OF oDlgAcessoApi
   
   @ C(009),C(000) Jpeg FILE "ChavePortalAPI.png" Size C(241),C(176) PIXEL NOBORDER OF oDlgAcessoApi

   @ C(188),C(001) GET oMemo1 Var cMemo1 MEMO Size C(238),C(001) PIXEL OF oDlgAcessoApi

   @ C(192),C(003) Say "Chave de Acesso a API" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgAcessoApi
// @ C(192),C(117) Say "Id AtechPortal"        Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgAcessoApi
// @ C(211),C(003) Say "Seu Nome Completo"     Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgAcessoApi
   
   @ C(201),C(003) MsGet oGet1 Var cAPIChave Size C(108),C(009) COLOR CLR_BLACK Picture "@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" PIXEL OF oDlgAcessoApi
// @ C(200),C(117) MsGet oGet2 Var cAPILogin Size C(047),C(009) COLOR CLR_BLACK Picture "@!!!!!!!!!!"                                         PIXEL OF oDlgAcessoApi
// @ C(221),C(003) MsGet oGet3 Var cAPINomeC Size C(161),C(009) COLOR CLR_BLACK Picture "@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"           PIXEL OF oDlgAcessoApi
   
   @ C(210),C(187) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgAcessoApi ACTION( GrvAcessoAPI() )

   ACTIVATE MSDIALOG oDlgAcessoApi CENTERED 

Return(.T.)

// Função que grava e sai da tela de Chave de Acesso a API do AtechPortal
Static Function GrvAcessoAPI()

   If Empty(Alltrim(cAPIChave))
      lPodeSeguir := .F.
      oDlgAcessoApi:End()
      Return(.T.)
   Endif
      
// If Empty(Alltrim(cAPILogin))
//    lPodeSeguir := .F.
//    oDlgAcessoApi:End()
//    Return(.T.)
// Endif

// If Empty(Alltrim(cAPINomeC))
//    lPodeSeguir := .F.
//    oDlgAcessoApi:End()
//    Return(.T.)
// Endif

   // Inclui os dados na tabela ZTI
   RecLock("ZTI",.T.)
   ZTI_FILIAL := ""
   ZTI_IDCO   := cAPILogin
   ZTI_IDNO   := cAPINomeC
   ZTI_IDCH   := Lower(cAPIChave)
   ZTI_DELE   := ""
   ZTI_LPRO   := cUserName
   MsUnLock()

   lPodeSeguir := .T.

   oDlgAcessoApi:End()

Return(.T.)

// Função que verifica se houve solicitação de abertura de tarefa para auxílio do departamento de projetos
Static Function VerAberturaAuxilio(Aux_Oportunidade, Aux_Cliente, Aux_Loja)

   Local cConteudo      := ""
   Local cAgravar       := ""
   Local aConsulta      := {}
   Local nContar        := 0
   Local nTentativas    := 0
   Local lExiste        := .F.
   Local cSTIM          := 0

   // Verifica se vendedor solicitou auxilio a área de projetos para a oportunidade. Se sim, abre a tarefa no portal
   If Select("T_PORTAL") > 0
      T_PORTAL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTH_FILIAL,"
   cSql += "       ZTH_CODI  ,"
   cSql += "       ZTH_DATA  ,"
   cSql += "       ZTH_HORA  ,"
   cSql += "       ZTH_USUA  ,"
   cSql += "       ZTH_PORT  ,"
   cSql += "       ZTH_CFIL  ,"
   cSql += "       ZTH_OPOR  ,"
   cSql += "       ZTH_CLIE  ,"
   cSql += "       ZTH_LOJA  ,"
   cSql += "       ZTH_TITU  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZTH_DETA)) AS DETALHE,"
   cSql += "       ZTH_STAT   "
   cSql += "  FROM " + "ZTH010"
   cSql += " WHERE ZTH_OPOR = '" + Alltrim(Aux_Oportunidade) + "'"
   cSql += "   AND ZTH_CLIE = '" + Alltrim(Aux_Cliente)      + "'"
   cSql += "   AND ZTH_LOJA = '" + Alltrim(Aux_Loja)         + "'"
   cSql += "   AND ZTH_PORT = ''"
   cSql += "   AND ZTH_DELE = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTAL", .T., .T. )
      
   If T_PORTAL->( EOF() )
      Return(.T.)
   Endif
      
   // ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
   // Modelo do comando de envio de abertura da tarefa no AtechPortal                                                                                                                          //            
   // E:\>E:\smartclientd\AtechHttpPost.exe "http://atechpoaprj01:81/redmine/issues.xml?key=755ec64118ca8aff4614f6636c2ad6c51403a66a" "e:\atechportal\retorno.txt" "e:\atechportal\tarefa.xml" //
   // <?xml version='1.0'?>                                                                                                                                                                    //
   // <issue>                                                                                                                                                                                  //
   // <project_id>9</project_id>                                                                                                                                                               //
   // <subject>Titulo da Tarefa</subject>                                                                                                                                                      //
   // <tracker_id>4</tracker_id>                                                                                                                                                               //
   // <status_id>1</status_id>                                                                                                                                                                 //
   // <description>Descricao que o usuario fez</description>                                                                                                                                   //
   // <assigned_to_id>10</assigned_to_id>                                                                                                                                                      //
   // <custom_fields>                                                                                                                                                                          //
   // <custom_field name="Oportunidade/Filial" id="14">000001/01</custom_field>                                                                                                                //
   // </custom_fields>                                                                                                                                                                         //
   // </issue>                                                                                                                                                                                 //
   // ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

   // Pesquisar aqui a Chave do portal do usuário que está abrirndo a tarefa
   If Select("T_CHAVEID") > 0
      T_CHAVEID->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4.ZZ4_APER,"
   cSql += "       ZZ4.ZZ4_PERG,"
   cSql += "       ZZ4.ZZ4_RES1,"
   cSql += "       ZZ4.ZZ4_RES2,"
   cSql += "       ZZ4.ZZ4_RES3,"
   cSql += "       ZZ4.ZZ4_UATH,"
   cSql += "       ZZ4.ZZ4_UATP,"
   cSql += "       ZZ4.ZZ4_ARRT,"
   cSql += "       ZZ4.ZZ4_ARXM,"
   cSql += "       ZZ4.ZZ4_STIM,"
   cSql += "       ZTI.ZTI_IDCO,"
   cSql += "       ZTI.ZTI_IDNO,"
   cSql += "       ZTI.ZTI_IDCH,"
   cSql += "       ZTI.ZTI_LPRO "
   cSql += "  FROM " + RetSqlName("ZZ4") + " ZZ4, "
   cSql += "       " + RetSqlName("ZTI") + " ZTI  "
   cSql += " WHERE UPPER(ZTI.ZTI_LPRO) = UPPER('" + Alltrim(cUserName) + "')"
   cSql += "   AND ZZ4.D_E_L_E_T_      = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAVEID", .T., .T. )

   If T_CHAVEID->( EOF() )
      MsgAlert("Atenção!"                                                                                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Não existe parametrização para este usuário para realizar abertura de tarefas no Atech Portal." + chr(13) + chr(10)                     + ;
               "Entre em contato com a área de projetos para regularizar seu cadastro.")
      Return(.T.)
   Endif

   // Carrega variável de TimeOut
   cSTIM := IIF(T_CHAVEID->( EOF() ), 0, T_CHAVEID->ZZ4_STIM)

   // Envia solicitação de abertura de tarefa no Atech Portal
   cString = ""

   // Envia para a função que elimina a acentuação
   ccdetalhe := retiraacento(Alltrim(T_PORTAL->DETALHE))
   WHILE !T_PORTAL->( EOF() )

      // Cria o XML de envio dos dados para abertura da tarefa no portal
      cString := ""
      cString += "<?xml version='1.0'?> "
      cString += "<issue> "
      cString += "<project_id>9</project_id> "
      cString += "<subject>" + "** " + Alltrim(T_PORTAL->ZTH_TITU) + "</subject> "
      cString += "<tracker_id>4</tracker_id> "
      cString += "<status_id>1</status_id> "
//    cString += "<description>" + Alltrim(T_PORTAL->DETALHE) + "</description> "
      cString += "<description>" + Alltrim(ccDetalhe) + "</description> "
      cString += "<assigned_to_id>10</assigned_to_id> "

//      cString += '<custom_fields type="array">'
//      cString += "<custom_field name='Oportunidade/Filial' id='14'>" + Alltrim(T_PORTAL->ZTH_OPOR) + "/" + Substr(T_PORTAL->ZTH_CFIL,01,02) + "</custom_field> "


      cString += '<custom_fields type="array">'
      cString += '<custom_field id="14">'
      cString += '<value>' + Alltrim(T_PORTAL->ZTH_OPOR) + '/' + Substr(T_PORTAL->ZTH_CFIL,01,02) + '</value> '
      cString += "</custom_field>"

      cString += "</custom_fields> "
      cString += "</issue> "      
      
      
      For nContar = 1 to 150000
      Next nContar

      // Grava o arquivo XML na pasta/diretório parametrizado
      nHdl := fCreate(Alltrim(T_CHAVEID->ZZ4_ARXM))
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      // Elabora a URL para envio do comando de inclusão da tarefa
      cUrl := IIF(T_CHAVEID->ZZ4_APER == 1, Alltrim(T_CHAVEID->ZZ4_UATH), Alltrim(T_CHAVEID->ZZ4_UATP)) + Alltrim(T_CHAVEID->ZTI_IDCH) 

      // Executa o envio ao AtechPortal para incusão da tarefa
      // E:\>E:\smartclientd\AtechHttpPost.exe "http://atechpoaprj01:81/redmine/issues.xml?key=755ec64118ca8aff4614f6636c2ad6c51403a66a" "e:\atechportal\retorno.txt" "e:\atechportal\tarefa.xml"
      // cUrl    := "http://atechpoaprj01:81/redmine/issues.xml?key=" + Alltrim(T_CHAVEID->ZTI_IDCH) 
      // cArqRet := "e:\atechportal\retorno.txt" 
      // cArqXml := "e:\atechportal\tarefa.xml"
      // WinExec("AtechHttpPost.EXE" + " " + '"' + cUrl + '"' + " " + '"' + Alltrim(T_CHAVEID->ZZ4_ARRT) + '"' + " " + '"' + Alltrim(T_CHAVEID->ZZ4_ARXM) + '"')

      // Elabora a string para ser executada
      cLinhaComando := Lower("AtechHttpPost.EXE" + " " + cUrl + " " + Alltrim(T_CHAVEID->ZZ4_ARRT) + " " + Alltrim(T_CHAVEID->ZZ4_ARXM))

      // Executa o comando de criação da tarefa no AtechPortal
//    WinExec(cLinhaComando)

      WaitRun(cLinhaComando, SW_SHOWNORMAL )

      // Lê o retorno
      lExiste     := .F.
      nTentativas := 0

      while nTentativas < cSTIM

         If File(Alltrim(T_CHAVEID->ZZ4_ARRT))
            lExiste := .T.
            Exit
         Endif

         nTentativas := nTentativas + 1

      Enddo
                                       
      If lExiste == .F.
         MsgAlert("Atenção!"                                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Sua solicitação de abertura de Auxilio ao Departamento de Projetos falhou." + chr(13) + chr(10)                     + ;
                  "Tente enviar sua solicitação mais tarde."                                   + chr(13) + chr(10)                     + ;
                  "Caso o problema persistir, contate o Departamento de Projetos.")
      Else

         // Abre o arquivo selecionado para pesquisa de dados
         nHandle := FOPEN(Alltrim(T_CHAVEID->ZZ4_ARRT), FO_READWRITE + FO_SHARED)
     
         If FERROR() != 0
            MsgAlert("Atenção!"                                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Sua solicitação de abertura de Auxilio ao Departamento de Projetos falhou." + chr(13) + chr(10)                     + ;
                     "Tente enviar sua solicitação mais tarde."                                   + chr(13) + chr(10)                     + ;
                     "Caso o problema persistir, contate o Departamento de Projetos.")
         Else

            // Lê o tamanho total do arquivo
            nLidos := 0
            FSEEK(nHandle,0,0)
            nTamArq := FSEEK(nHandle,0,2)
            FSEEK(nHandle,0,0)

            // Lê todos os Registros
            xBuffer:=Space(nTamArq)
            FREAD(nHandle,@xBuffer,nTamArq)
 
            cConteudo := ""
            aConsulta := {}

            For nContar = 1 to Len(xBuffer)
                If Substr(xBuffer, nContar, 1) <> ">"
                   cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
                Else
                   cAgravar := ""
                   For nLimpa = 1 to Len(cConteudo)
                       If Substr(cConteudo, nLimpa, 2) == "</"
                          Exit
                       Else   
                          cAgravar := cAgravar + Substr(cConteudo, nLimpa, 1)
                       Endif
                   Next nLimpa
                   aAdd(aConsulta, { cAgravar } )
                   cConteudo := ""
                Endif
            Next nContar    

            // Fecha o arquivo de retorno para poder ser deletado
            FCLOSE(nHandle)

            // Exclui o arquivo de solicitação (XML)
            FERASE(Alltrim(T_CHAVEID->ZZ4_ARXM))

            // Exclui o arquivo de retorno
            FERASE(Alltrim(T_CHAVEID->ZZ4_ARRT))

            // Captura o Retorno do Status do Cartão Postagem
            _RetFechamento := ""
            _NumTarefa     := ""
            For nContar = 1 to Len(aConsulta)
   
                If aConsulta[nContar,01] == "<id"
                   _NumTarefa := aConsulta[(nContar + 01),01]
                   Exit
                Endif

            Next nContar

            If Empty(Alltrim(_NumTarefa)) .Or. _NumTarefa == Nil
               MsgAlert("Atenção! Houve erro na abertura da tarefa no portal. Tente novamente mais tarde.")
            Else
               // Atualiza o Código da tarefa criada na tabela ZTH
               DbSelectArea("ZTH")
               DbSetOrder(1)
               If DbSeek(xFilial("ZTH") + T_PORTAL->ZTH_CODI + T_PORTAL->ZTH_CLIE + T_PORTAL->ZTH_LOJA)
                  RecLock("ZTH",.F.)
                  ZTH_PORT := _NumTarefa
                  MsUnLock()              
               Endif

            Endif
            
         Endif   

      Endif

      // Verifica a próxima solicitação de abertura de tarefa
      T_PORTAL->( DbSkip() )

   ENDDO   

Return(.T.)
// Função que retira a acentuação da string da abertura da tarefa
Static Function RetiraAcento(_xTexto)

   Local aLetras     := {}
   Local nContar     := 0
   Local cNovaString := ""
   Local lLetra      := .F.

   If Empty(Alltrim(_xTexto))
      Return(.T.)
   Endif   

   aAdd( aLetras, { "À", "A" })
   aAdd( aLetras, { "Á", "A" })
   aAdd( aLetras, { "à", "a" })
   aAdd( aLetras, { "á", "a" })
   aAdd( aLetras, { "Ã", "a" })
   aAdd( aLetras, { "ã", "a" })
   aAdd( aLetras, { "Ä", "a" })
   aAdd( aLetras, { "ä", "a" })
   aAdd( aLetras, { "Â", "a" })
   aAdd( aLetras, { "â", "a" })
   aAdd( aLetras, { "È", "E" })
   aAdd( aLetras, { "É", "E" })
   aAdd( aLetras, { "è", "e" })
   aAdd( aLetras, { "é", "e" })
   aAdd( aLetras, { "Ê", "E" })
   aAdd( aLetras, { "ê", "e" })
   aAdd( aLetras, { "Ë", "E" })
   aAdd( aLetras, { "ë", "e" })
   aAdd( aLetras, { "Ì", "I" })
   aAdd( aLetras, { "Ì", "I" })
   aAdd( aLetras, { "ì", "i" })
   aAdd( aLetras, { "í", "i" })
   aAdd( aLetras, { "Ï", "I" })
   aAdd( aLetras, { "ï", "i" })
   aAdd( aLetras, { "Î", "I" })
   aAdd( aLetras, { "î", "i" })
   aAdd( aLetras, { "Ò", "O" })
   aAdd( aLetras, { "Ó", "O" })
   aAdd( aLetras, { "ò", "o" })
   aAdd( aLetras, { "ó", "o" })
   aAdd( aLetras, { "Õ", "O" })
   aAdd( aLetras, { "ô", "o" })
   aAdd( aLetras, { "Ö", "O" })
   aAdd( aLetras, { "ö", "o" })
   aAdd( aLetras, { "Ô", "O" })
   aAdd( aLetras, { "ô", "o" })
   aAdd( aLetras, { "Ù", "U" })
   aAdd( aLetras, { "Ú", "U" })
   aAdd( aLetras, { "ù", "u" })
   aAdd( aLetras, { "ú", "u" })
   aAdd( aLetras, { "Ü", "U" })
   aAdd( aLetras, { "ü", "u" })
   aAdd( aLetras, { "Û", "U" })
   aAdd( aLetras, { "û", "u" })
   aAdd( aLetras, { "Û", "U" })
   aAdd( aLetras, { "û", "u" })
   aAdd( aLetras, { "ý", "y" })
   aAdd( aLetras, { "Ý", "Y" })
   aAdd( aLetras, { "ñ", "n" })
   aAdd( aLetras, { "Ñ", "N" })
   aAdd( aLetras, { "Ç", "c" })
   aAdd( aLetras, { "ç", "c" })

   cNovaString := ""
   
   For nContar = 1 to Len(Alltrim(_xTexto))

       lLetra := .F.

       For nVerifica = 1 to Len(aLetras)
           If Substr(_xtexto,nContar,01) == aLetras[nVerifica,01]
              cNovaString := cNovaString + aLetras[nVerifica,02]
              lLetra := .T.
              Exit
           Endif
       Next nVerifica
       
       If lLetra == .T.
       Else
          cNovaString := cNovaString + Substr(_xtexto,nContar,01)
       Endif
          
   Next nContar       
   
Return cNovaString
