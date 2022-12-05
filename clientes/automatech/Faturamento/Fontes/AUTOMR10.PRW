#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR10.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/08/2011                                                          *
// Objetivo..: Tela Gerencial de Faturamento                                       *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR10()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	  := {}
   Local _aAlias  	  := {}
   Local cSql         := ""
   Local cNomeProduto := ""
   Local cProduto     := Space(30)

   // Fonte
   Local oFont
   
   DEFINE FONT oFont Name "Courier New" Size 0, -14 BOLD

   // Variáveis Private da Função
   Private cMes       := 0
   Private cAno       := 0

   // Faturamento Porto Alegre
   Private nProIVende := 0
   Private nSerIVende := 0
   Private nFreIVende := 0
   Private nDevIVende := 0
   Private nDevIPorto := 0
   Private nTotIVende := 0

   Private nProEVende := 0
   Private nSerEVende := 0
   Private nFreEVende := 0
   Private nDevEVende := 0
   Private nTotEVende := 0

   Private nProTVende := 0
   Private nSerTVende := 0
   Private nFreTVende := 0
   Private nDevTVende := 0
   Private nDevTPorto := 0
   Private nTotTVende := 0

   // Faturamento Caixas do Sul
   Private nProIPerio := 0
   Private nSerIPerio := 0
   Private nFreIPerio := 0
   Private nDevIPerio := 0
   Private nDevICaxia := 0
   Private nTotIPerio := 0

   Private nProEPerio := 0
   Private nSerEPerio := 0
   Private nFreEPerio := 0
   Private nDevEPerio := 0
   Private nTotEPerio := 0

   Private nProTPerio := 0
   Private nSerTPerio := 0
   Private nFreTPerio := 0
   Private nDevTPerio := 0
   Private nDevTCaixa := 0
   Private nTotTPerio := 0

   // Faturamento Pelotas
   Private nProIProdu := 0
   Private nSerIProdu := 0
   Private nFreIProdu := 0
   Private nDevIProdu := 0
   Private nDevIPelot := 0
   Private nTotIProdu := 0

   Private nProEProdu := 0
   Private nSerEProdu := 0
   Private nFreEProdu := 0
   Private nDevEProdu := 0
   Private nTotEProdu := 0

   Private nProTProdu := 0
   Private nSerTProdu := 0
   Private nFreTProdu := 0
   Private nDevTProdu := 0
   Private nDevTPelot := 0
   Private nTotTProdu := 0

   // Faturamento Suprimentos
   Private nProISupri := 0
   Private nSerISupri := 0
   Private nFreISupri := 0
   Private nDevISupri := 0
   Private nDevIFabri := 0
   Private nTotISupri := 0

   Private nProESupri := 0
   Private nSerESupri := 0
   Private nFreESupri := 0
   Private nDevESupri := 0
   Private nTotESupri := 0

   Private nProTSupri := 0
   Private nSerTSupri := 0
   Private nFreTSupri := 0
   Private nDevTSupri := 0
   Private nDevTFabri := 0
   Private nTotTSupri := 0

   // Total geral
   Private nProIGeral := 0
   Private nSerIGeral := 0
   Private nFreIGeral := 0
   Private nDevIGeral := 0
   Private nDevIOutra := 0
   Private nTotIGeral := 0

   Private nProEGeral := 0
   Private nSerEGeral := 0
   Private nFreEGeral := 0
   Private nDevEGeral := 0
   Private nTotEGeral := 0

   Private nProTGeral := 0
   Private nSerTGeral := 0
   Private nFreTGeral := 0
   Private nDevTGeral := 0
   Private nDevTOutra := 0
   Private nTotTGeral := 0

   Private cWait := ""

   Private nGet1	  := 0
   Private nGet2	  := 0

   cMes := Month(Date())
   cAno := Year(Date())

   // Diálogo Principal
   Private oDlg

   Private __Empresa := ""

   U_AUTOM628("AUTOMR10")

   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )
   
   __Empresa := SM0->M0_CODIGO

   // Desenha o diálogo
   DEFINE MSDIALOG oDlg TITLE "Consulta Gerencial" FROM C(178),C(181) TO C(605),C(850) PIXEL

   @ C(010),C(005) Say "Mês / Ano:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(007),C(030) MsGet oGet1 Var cMes Size C(013),C(010) COLOR CLR_BLACK Picture "99"   PIXEL OF oDlg
   @ C(007),C(045) MsGet oGet2 Var cAno Size C(020),C(010) COLOR CLR_BLACK Picture "9999" PIXEL OF oDlg

   @ C(018),C(005) Say Replicate("-", 3400) Size C(325),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(025),C(005) Say "FATURAMENTO"  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(050) Say "PV"           Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(100) Say "VLR PRODUTOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(150) Say "VLR SERVIÇOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(200) Say "   VLR FRETE" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(250) Say "DEVOLUÇÕES"   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(302) Say "   VLR TOTAL" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   // Faturamento - Vendedores
   @ C(032),C(005) Say Replicate("-", 3400) Size C(325),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   Do Case
      Case __Empresa == "01"
           @ C(039),C(005) Say "PORTO ALEGRE"  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      Case __Empresa == "02"
           @ C(039),C(005) Say "TI - CURITIBA" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      Case __Empresa == "03"
           @ C(039),C(005) Say "ATECH"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   EndCase           

   @ C(039),C(050) Say "INTERNOS"     Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(087) Say nProIVende     Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(039),C(137) Say nSerIVende     Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(039),C(181) Say nFreIVende     Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(039),C(233) Say nDevIVende     Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
// @ C(039),C(285) Say nTotIVende     Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   @ C(046),C(050) Say "OUTRAS DEV." Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg     
   @ C(046),C(233) Say nDevIPorto    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(046),C(285) Say nTotIVende - nDevIPorto Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   @ C(053),C(050) Say "EXTERNOS"  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg 
   @ C(053),C(087) Say nProEVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(053),C(137) Say nSerEVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(053),C(181) Say nFreEVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(053),C(233) Say nDevEVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(053),C(285) Say nTotEVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   @ C(060),C(050) Say "TOTAL"     Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg 
   @ C(060),C(087) Say nProTVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(060),C(137) Say nSerTVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(060),C(181) Say nFreTVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(060),C(233) Say nDevTVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(060),C(285) Say nTotTVende  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   @ C(067),C(005) Say Replicate("-", 3400) Size C(325),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   If __Empresa == "01"
      // Faturamento - Período
      @ C(074),C(005) Say "CAXIAS DO SUL" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(074),C(050) Say "INTERNOS"      Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(074),C(087) Say nProIPerio      Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(074),C(137) Say nSerIPerio      Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(074),C(181) Say nFreIPerio      Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(074),C(233) Say nDevIPerio      Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   // @ C(074),C(285) Say nTotIPerio      Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(081),C(050) Say "OUTRAS DEV."  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg     
      @ C(081),C(233) Say nDevICaxia     Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(081),C(285) Say nTotIPerio - nDevICaxia Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(088),C(050) Say "EXTERNOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(088),C(087) Say nProEPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(088),C(137) Say nSerEPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(088),C(181) Say nFreEPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(088),C(233) Say nDevEPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(088),C(285) Say nTotEPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   
      @ C(095),C(050) Say "TOTAL"    Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(095),C(087) Say nProTperio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(095),C(137) Say nSerTPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(095),C(181) Say nFreTPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(095),C(233) Say nDevTPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(095),C(285) Say nTotTPerio Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(102),C(005) Say Replicate("-", 3400) Size C(325),C(020) COLOR CLR_BLACK PIXEL OF oDlg

      // Faturamento - Produtos
      @ C(109),C(005) Say "PELOTAS"  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(109),C(050) Say "INTERNOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(109),C(087) Say nProIProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(109),C(137) Say nSerIProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(109),C(181) Say nFreIProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(109),C(233) Say nDevIProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   // @ C(109),C(285) Say nTotIProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(116),C(050) Say "OUTRAS DEV." Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(116),C(233) Say nDevIPelot    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(116),C(285) Say nTotIProdu - nDevIPelot Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(123),C(050) Say "EXTERNOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(123),C(087) Say nProEProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(123),C(137) Say nSerEProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(123),C(181) Say nFreEProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(123),C(233) Say nDevEProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(123),C(285) Say nTotEProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(130),C(050) Say "TOTAL"    Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(130),C(087) Say nProTProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(130),C(137) Say nSerTProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(130),C(181) Say nFreTProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(130),C(233) Say nDevTProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(130),C(285) Say nTotTProdu Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   
      @ C(137),C(005) Say Replicate("-", 3400) Size C(325),C(020) COLOR CLR_BLACK PIXEL OF oDlg

      // Faturamento - Produtos
      @ C(144),C(005) Say "SUPRIMENTOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(144),C(050) Say "INTERNOS"    Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(144),C(087) Say nProISupri    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(144),C(137) Say nSerISupri    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(144),C(181) Say nFreISupri    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(144),C(233) Say nDevISupri    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   // @ C(144),C(285) Say nTotISupri    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(151),C(050) Say "OUTRAS DEV." Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(151),C(233) Say nDevIFabri    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(151),C(285) Say nTotISupri - nDevIFabri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(158),C(050) Say "EXTERNOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(158),C(087) Say nProESupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(158),C(137) Say nSerESupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(158),C(181) Say nFreESupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(158),C(233) Say nDevESupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(158),C(285) Say nTotESupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

      @ C(165),C(050) Say "TOTAL"    Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(165),C(087) Say nProTSupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(165),C(137) Say nSerTSupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(165),C(181) Say nFreTSupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(165),C(233) Say nDevTSupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      @ C(165),C(285) Say nTotTSupri Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
      
   Endif   

   @ C(172),C(005) Say Replicate("-", 3400) Size C(325),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   // Faturamento - Produtos
   @ C(179),C(005) Say "T O T A L" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(179),C(050) Say "INTERNOS"  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(179),C(087) Say nProIGeral  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(179),C(137) Say nSerIGeral  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(179),C(181) Say nFreIGeral  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(179),C(233) Say nDevIGeral  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
// @ C(179),C(285) Say nTotIGeral  Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   @ C(186),C(050) Say "OUTRAS DEV." Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(186),C(233) Say nDevIOutra    Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(186),C(285) Say nTotIGeral - nDevIOutra Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   @ C(193),C(050) Say "EXTERNOS" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(193),C(087) Say nProEGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(193),C(137) Say nSerEGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(193),C(181) Say nFreEGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(193),C(233) Say nDevEGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(193),C(285) Say nTotEGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   @ C(200),C(050) Say "TOTAL"    Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(200),C(087) Say nProTGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(200),C(137) Say nSerTGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(200),C(181) Say nFreTGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(200),C(233) Say nDevTGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"
   @ C(200),C(285) Say nTotTGeral Size C(100),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg picture "@E 999,999,999.99"

   DEFINE SBUTTON FROM C(009),C(285) TYPE  1 ENABLE OF oDlg ACTION( RODAFATU(cMes, cAno ))
   DEFINE SBUTTON FROM C(009),C(310) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que dispara as pesquisas para popular as variáveis da tela
Static Function RodaFatu( _Mes, _Ano )

   Private cRetorno := ""

   // Pesquisa valores do Faturamento por Vendedores
// cRetorno := U_AUTOMR08("B", _Mes, _Ano)   
   cRetorno := U_AUTOMR16("B", _Mes, _Ano)   

   // Faturamento Porto Alegre
   nProIVende := Val(Substr(cRetorno,001,14))
   nSerIVende := Val(Substr(cRetorno,015,14))
   nFreIVende := Val(Substr(cRetorno,029,14))
   nDevIVende := Val(Substr(cRetorno,337,14))
   nTotIVende := Val(Substr(cRetorno,043,14))

   nProEVende := Val(Substr(cRetorno,057,14))
   nSerEVende := Val(Substr(cRetorno,071,14))
   nFreEVende := Val(Substr(cRetorno,085,14))
   nDevEVende := Val(Substr(cRetorno,351,14))
   nTotEVende := Val(Substr(cRetorno,099,14))

   nProTVende := nProIVende + nProEVende
   nSerTVende := nSerIVende + nSerEVende
   nFreTVende := nFreIVende + nFreEVende
   nDevTVende := nDevIVende + nDevEVende
   nTotTVende := nTotIVende + nTotEVende

   // Faturamento Caxias do Sul
   nProIPerio := Val(Substr(cRetorno,113,14))
   nSerIPerio := Val(Substr(cRetorno,127,14))
   nFreIPerio := Val(Substr(cRetorno,141,14))
   nDevIPerio := Val(Substr(cRetorno,365,14))
   nTotIPerio := Val(Substr(cRetorno,155,14))

   nProEPerio := Val(Substr(cRetorno,169,14))
   nSerEPerio := Val(Substr(cRetorno,183,14))
   nFreEPerio := Val(Substr(cRetorno,197,14))
   nDevEPerio := Val(Substr(cRetorno,379,14))
   nTotEPerio := Val(Substr(cRetorno,211,14))
   
   nProTPerio := nProIPerio + nProEPerio
   nSerTPerio := nSerIPerio + nSerEPerio
   nFreTPerio := nFreIPerio + nFreEPerio
   nDevTPerio := nDevIPerio + nDevEPerio
   nTotTPerio := nTotIPerio + nTotEPerio

   // Faturamento Pelotas
   nProIProdu := Val(Substr(cRetorno,225,14))
   nSerIProdu := Val(Substr(cRetorno,239,14))
   nFreIProdu := Val(Substr(cRetorno,253,14))
   nDevIProdu := Val(Substr(cRetorno,393,14))
   nTotIProdu := Val(Substr(cRetorno,267,14))

   nProEProdu := Val(Substr(cRetorno,281,14))
   nSerEProdu := Val(Substr(cRetorno,295,14))
   nFreEProdu := Val(Substr(cRetorno,309,14))
   nDevEProdu := Val(Substr(cRetorno,407,14))
   nTotEProdu := Val(Substr(cRetorno,323,14))

   nProTProdu := nProIProdu + nProEProdu
   nSerTProdu := nSerIProdu + nSerEProdu
   nFreTProdu := nFreIProdu + nFreEProdu
   nDevTProdu := nDevIProdu + nDevEProdu
   nTotTProdu := nTotIProdu + nTotEProdu

   // Faturamento Suprimentos
   nProISupri := Val(Substr(cRetorno,463,14))
   nSerISupri := Val(Substr(cRetorno,477,14))
   nFreISupri := Val(Substr(cRetorno,491,14))
   nDevISupri := Val(Substr(cRetorno,505,14))
   nTotISupri := Val(Substr(cRetorno,519,14))

   nProESupri := Val(Substr(cRetorno,533,14))
   nSerESupri := Val(Substr(cRetorno,547,14))
   nFreESupri := Val(Substr(cRetorno,561,14))
   nDevESupri := Val(Substr(cRetorno,575,14))
   nTotESupri := Val(Substr(cRetorno,589,14))

   nProTSupri := nProISupri + nProESupri
   nSerTSupri := nSerISupri + nSerESupri
   nFreTSupri := nFreISupri + nFreESupri
   nDevTSupri := nDevISupri + nDevESupri
   nTotTSupri := nTotISupri + nTotESupri

   // Outras Devoluções
   nDevIPorto := Val(Substr(cRetorno,421,14))
   nDevICaxia := Val(Substr(cRetorno,435,14))
   nDevIPelot := Val(Substr(cRetorno,449,14))
   nDevIOutra := Val(Substr(cRetorno,463,14))
   nDevIFabri := Val(Substr(cRetorno,603,14))

//   nProTProdu := nProIProdu + nProEProdu
//   nSerTProdu := nSerIProdu + nSerEProdu
//   nFreTProdu := nFreIProdu + nFreEProdu
//   nDevTProdu := nDevIProdu + nDevEProdu
//   nTotTProdu := nTotIProdu + nTotEProdu

   // Total geral
   nProIGeral := nProIVende + nProIPerio + nProIProdu + nProISupri
   nSerIGeral := nSerIVende + nSerIPerio + nSerIProdu + nSerISupri
   nFreIGeral := nFreIVende + nFreIPerio + nFreIProdu + nFreISupri
   nDevIGeral := nDevIVende + nDevIPerio + nDevIProdu + nDevISupri
   nTotIGeral := nTotIVende + nTotIPerio + nTotIProdu + nTotISupri

   nProEGeral := nProEVende + nProEPerio + nProEProdu + nProESupri
   nSerEGeral := nSerEVende + nSerEPerio + nSerEProdu + nSerESupri
   nFreEGeral := nFreEVende + nFreEPerio + nFreEProdu + nFreESupri
   nDevEGeral := nDevEVende + nDevEPerio + nDevEProdu + nDevESupri
   nTotEGeral := nTotEVende + nTotEPerio + nTotEProdu + nTotESupri

   nProTGeral := nProIGeral + nProEGeral
   nSerTGeral := nSerIGeral + nSerEGeral
   nFreTGeral := nFreIGeral + nFreEGeral
   nDevTGeral := nDevIGeral + nDevEGeral
   nTotTGeral := nTotIGeral + nTotEGeral

   // Carrega os Valores das Outras Devoluções
   nDevTVende := nDevTVende + nDevIPorto
   nTotTVende := nTotTVende - nDevIPorto

   nDevTPerio := nDevTPerio + nDevICaxia
   nTotTPerio := nTotTPerio - nDevICaxia
   
   nDevTProdu := nDevTProdu + nDevIPelot
   nTotTProdu := nTotTProdu - nDevIPelot

   nDevTSupri := nDevTSupri + nDevIFabri
   nTotTSupri := nTotTSupri - nDevIFabri

   nDevIOutra := nDevIPorto + nDevICaxia + nDevIPelot + nDevIFabri
   
   nDevTGeral := nDevTGeral + (nDevIPorto + nDevICaxia + nDevIPelot + nDevIFabri)
   nTotTGeral := nTotTGeral - nDevIOutra

Return .T.