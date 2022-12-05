#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR40.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/11/2011                                                          *
// Objetivo..: Programa que importa e mostra notas fiscais dos arquivos vindos da  *
//             Aprove                                                              *
//**********************************************************************************

User Function AUTOMR40()

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	     := {}
   Local _aAlias  	     := {}
   Local lAbre           := .F.

   // Variáveis Locais da Função
   Private dData01       := Ctod("  /  /    ")
   Private dData02       := Ctod("  /  /    ")
   Private cCaminho01    := Space(100)
   Private cCaminho02    := Space(100)
   Private cCaminho03    := Space(100)
   Private aLeitura      := {}
   Private aServicos     := {}

   // Totalizadores da Contabilidade
   Private nProdutoV     := 0
   Private nServicoV     := 0
   Private nDevolveV     := 0
   Private nTotalV       := 0

   // Totalizadores da Aprove
   Private nProdutoA     := 0
   Private nServicoA     := 0
   Private nDevolveA     := 0
   Private nTotalA       := 0

   // Totalizadores das Diferenças
   Private nProdutoD     := 0
   Private nServicoD     := 0
   Private nDevolveD     := 0
   Private nTotalD       := 0

   Private nDiferenca    := 0
   Private nLeiProduto   := 0
   Private nLeiServico   := 0
   Private nLeiDevolucao := 0

   Private nMaiorAut   := 0
   Private nMaiorApr   := 0
   Private NomeCam1    := Space(100)
   Private NomeCam2    := Space(100)
   Private NomeCam3    := Space(100)

   Private oCheckBox1
   Private lCheckBox1

   NomeCam1 := Replicate("_", 100)
   NomeCam2 := Replicate("_", 100)
   NomeCam3 := Replicate("_", 100)

   Private nGet1	   := Ctod("  /  /    ")
   Private nGet2	   := Ctod("  /  /    ")
   Private nGet3	   := Space(100)
   Private nGet4	   := Space(100)
   Private nGet5	   := 0
   Private nGet6	   := 0
   Private nGet7	   := 0
   Private nGet8	   := 0
   Private nGet9	   := 0
   Private nGet10	   := 0
   Private nGet11      := 0      
   Private nGet12      := 0      
   Private nGet13      := 0      
   Private nGet14      := 0      
   Private nGet15      := 0      
   Private nGet16      := 0      
   Private nGet17      := 0         
   Private nGet18      := Space(100)

   Private aBrowse     := {}
   Private aTransito   := {}
   
   // Variáveis Private da Função
   Private cCliente      := Space(06)
   Private cLoja         := Space(03)
   Private cProduto      := Space(30)
   Private cProducao     := Space(06)
   Private cPedido       := Space(06)
   Private cAtendimento  := Space(06)
   Private cNomeCliente  := Space(60)
   Private cNomeProduto  := Space(60)
   Private oFont12b

   // Diálogo Principal
   Private oDlg

   DEFINE FONT oFont   Name "Arial" Size 0, -10 BOLD

   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )

   U_AUTOM628("AUTOMR40")

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg TITLE "Comparativo APROVE X AUTOMATECH" FROM C(000),C(000) TO C(470),C(1000) PIXEL

   // Solicita os Parâmetros para impressão das Ordens de Produção
   @ C(008),C(005) Say "Data Inicial:"                  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(005) Say "Data Final:  "                  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(008),C(100) Say "Produtos: "                     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(100) Say "Serviços:"                      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

// @ C(036),C(100) Say "Devoluções:"                    Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(011),C(300) Say "Total Leitura Arquivo:"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(027),C(300) Say "Total Leitura Arquivo:"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg


   @ C(164),C(005) Say "TOTAIS DA CONTABILIDADE" Size C(050),C(020) FONT oFont12b COLOR CLR_BLACK PIXEL OF oDlg
   @ C(175),C(005) Say "Total Produtos"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(005) Say "Total Serviços"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(005) Say "Total Devoluções"        Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(223),C(005) Say "Total"                   Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(164),C(110) Say "TOTAIS DA AUTOMATECH"   Size C(100),C(020) FONT oFont12b COLOR CLR_BLACK PIXEL OF oDlg
   @ C(175),C(110) Say "Total Produtos"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(110) Say "Total Serviços"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(191),C(150) Say "Total Devoluções AUTOMATECH:"   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(110) Say "Total Devoluções"       Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(223),C(110) Say "Total"                  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(164),C(220) Say "DIFERENÇAS CONTABILIDADE X AUTOMATECH"   Size C(100),C(020) FONT oFont12b COLOR CLR_BLACK PIXEL OF oDlg
   @ C(175),C(220) Say "Total Produtos"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(220) Say "Total Serviços"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(191),C(150) Say "Total Devoluções AUTOMATECH:"   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(220) Say "Total Devoluções"       Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(223),C(220) Say "Total"                  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(175),C(360) Say "Valor A MAIOR na AUTOMATECH" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(360) Say "Valor A MAIOR na APROVE"     Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg   

// @ C(223),C(300) Say "Diferença APROVE X AUTOMATECH:" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(007),C(035) MsGet oGet1  Var dData01             Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(020),C(035) MsGet oGet2  Var dData02             Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   @ C(008),C(130) Say NomeCam1 Size C(140),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(130) Say NomeCam2 Size C(140),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg

// @ C(036),C(130) Say NomeCam3 Size C(140),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg

   // Totalizadores da Contabilidade
   @ C(172),C(040) MsGet oGet5  Var nProdutoV   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(040) MsGet oGet6  Var nServicoV   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(040) MsGet oGet15 Var nDevolveV   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(220),C(040) MsGet oGet7  Var nTotalV     When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   // Totalizadores da Automatech
   @ C(172),C(150) MsGet oGet8  Var nProdutoA   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(150) MsGet oGet9  Var nServicoA   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(150) MsGet oGet15 Var nDevolveA   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(220),C(150) MsGet oGet11 Var nTotalA     When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   // Totalizadores das Diferenças
   @ C(172),C(260) MsGet oGet8  Var nProdutoD   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(260) MsGet oGet9  Var nServicoD   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(260) MsGet oGet15 Var nDevolveD   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(220),C(260) MsGet oGet11 Var nTotalD     When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

// @ C(220),C(400) MsGet oGet12 Var nDiferenca  When lAbre Size C(060),C(010) PICTURE "@EZ 999,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   @ C(172),C(430) MsGet oGet16 Var nMaiorAut   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(430) MsGet oGet17 Var nMaiorApr   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

//   @ C(010),C(350) MsGet oGet13 Var nLeiProduto When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
//   @ C(023),C(350) MsGet oGet14 Var nLeiServico When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   @ C(008),C(320) CHECKBOX oCheckBox1 VAR lCheckBox1 PROMPT "Visualizar Somente Registros com Diferenças" SIZE 150, 014 OF oDlg COLORS 0, 16777215 PIXEL

   @ C(007),C(080) Button "..." Size C(015),C(010) PIXEL OF oDlg ACTION( PESQARQ1(1) )
   @ C(020),C(080) Button "..." Size C(015),C(010) PIXEL OF oDlg ACTION( PESQARQ1(2) )

// @ C(033),C(080) Button "..." Size C(015),C(010) PIXEL OF oDlg ACTION( PESQARQ1(3) )

   @ C(007),C(450) Button "Pesquisar"       Size C(037),C(012) PIXEL OF oDlg ACTION( CAPTURADADOS( dData01, dData02, cCaminho01, cCaminho02) )
   @ C(020),C(320) Button "Produtos/Devol." Size C(037),C(012) PIXEL OF oDlg ACTION( MOSTRAAQ1(aLeitura) )
   @ C(020),C(360) Button "Serviços"        Size C(037),C(012) PIXEL OF oDlg ACTION( MOSTRAAQS(aServicos) )
   @ C(020),C(450) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end()  )

   oBrowse := TSBrowse():New(045,005,630,160,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('FL'        ,,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Nº NF'     ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Série'     ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Cliente'   ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New("Prod. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Serv. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Dev.  Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Total Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Prod. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Serv. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Dev.  Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Total Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Diferença"   ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED  

Return .T.

// Função que abre diálogo de pesquisa dos arquivos a serem lidos
Static Function PESQARQ1( _Botao )

   Do Case
      Case _Botao == 1
           cCaminho01 := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)
           NomeCam1   := Upper(cCaminho01)
      Case _Botao == 2
           cCaminho02 := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)
           NomeCam2   := Upper(cCaminho02)
      Case _Botao == 3
           cCaminho03 := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)
           NomeCam3   := Upper(cCaminho03)
   EndCase

Return .T. 

// Função que define a Window
Static Function CAPTURADADOS( dData01, dData02, cCaminho01, cCaminho02 )

     Local nLidos
     Local nTamArq
     Local aCNPJ 
     Local nContar    := 0
     Local nAlen
     Local cSql 
     Local nReg
     Local cProduto   := space(30)
     Local nPosicao
     Local nPipe      := 1
     Local cLinha     := ""
     Local _Codigo    := ""
     Local _PartNum   := ""
     Local _Nome01    := ""
     Local _Nome02    := ""
     Local _Ativo     := ""
     Local aProdutos  := {}
     Local nProduto   := 0
     Local nServico   := 0
     Local nFilial    := ""
     Local nDocumento := ""
     Local nSerie     := ""
     Local nCliente   := ""
     Local aNotas     := {}
     Local nProcura   := 0
     Local lAchei     := .F.
     Local nNovoValor := ""
     Local nTotDevolu := 0
     Local nTabs      := 0
     Local _Valor01   := ""
     Local aLinhas    := {}
     Local aFiltrados := {}
     Local _TotalNF   := ""
     Local _Limpado   := ""
     Local _LimpaNF   := ""

//   Local cCaminho01 := "C:\AUTOMATECH\FONTES\APROVE - II\ARQUIVOS\ULTIMOS\VENDAS072011.TXT"
     Local cLinha     := ""
     Local nContar    := 0
     Local nSepara    := 0
     Local nQuebra    := 0
     Local cCodFil    := ""
     Local cNatureza  := ""
     Local cXNota     := ""
     Local cXSerie    := ""
     Local cXConta    := ""
     Local cXValor    := ""

     Local cCodFil    := ""
     Local cDado01    := ""                            
     Local cDado02    := ""
     Local cDado03    := ""
     Local cDado04    := ""
     Local cDado05    := ""                    
     Local cDado06    := ""
     Local cDado07    := ""
     Local cDado08    := ""
     Local cDado09    := ""
     Local cDado10    := ""                    
     Local cDado11    := ""
     Local cDado12    := ""                    
     Local cDado13    := ""
     Local cDado14    := ""
     Local cDado15    := ""
     Local cDado16    := ""
     Local cDado17    := ""                    
     Local cDado18    := ""
     Local cDado19    := ""
     Local cDado20    := ""
     Local cDado21    := ""
     Local cDado22    := ""                    
     Local cDado23    := ""
     Local cDado24    := ""                    

     Local aLinhas    := {}

     Private xBuffer

     aLeitura  := {}
     aServicos := {}

     If Empty(dData01)
        Msgalert("Data inicial de pesquisa não informada.")
        Return .T.
     Endif   

     If Empty(dData02)
        Msgalert("Data final de pesquisa não informada.")
        Return .T.
     Endif   

     If dData02 < dData01
        Msgalert("Datas inconsistentes.")
        Return .T.
     Endif   

     If Empty(Alltrim(cCaminho01)) .and. Empty(Alltrim(cCaminho02)) .and. Empty(Alltrim(cCaminho03))
        Msgalert("Necessario informar pelo menos um do(s) arquivo(s) a ser(em) importado(s).")
        Return .T.
     Endif   

     If !Empty(cCaminho01)
        If !File(Alltrim(cCaminho01))
           MsgAlert("Arquivo de importação de Produtos inexistente.")
           Return .T.
        Endif
     Endif
        
     If !Empty(cCaminho02)
        If !File(Alltrim(cCaminho02))
           MsgAlert("Arquivo de importação de Serviços inexistente.")
           Return .T.
        Endif
     Endif

     If !Empty(cCaminho03)
        If !File(Alltrim(cCaminho03))
           MsgAlert("Arquivo de importação de Devoluções inexistente.")
           Return .T.
        Endif
     Endif

     oBrowse := TSBrowse():New(045,005,630,160,oDlg,,1,,1)
     oBrowse:AddColumn( TCColumn():New('FL'        ,,,{|| },{|| }) ) 
     oBrowse:AddColumn( TCColumn():New('Nº NF'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Série'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Cliente'   ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New("Prod. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Prod. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Diferença"   ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:SetArray(aBrowse)

     // Pesquisa o faturamento do período

     // Pesquisa os dados para emissão do relatório
     If Select("RESULTADO") > 0
        RESULTADO->( dbCloseArea() )
     EndIf

     cSql := ""   
     cSql := "SELECT A.D2_FILIAL , "
     cSql += "       A.D2_DOC    , "
     cSql += "       A.D2_SERIE  , "
     cSql += "       A.D2_EMISSAO, "
     cSql += "       A.D2_TES    , "
     cSql += "       G.F4_DUPLIC , "
     cSql += "       G.F4_ISS    , "
     cSql += "       A.D2_CF     , "
     cSql += "       A.D2_PEDIDO , "
     cSql += "       F.C5_FRETE  , "
     cSql += "       A.D2_CLIENTE, "
     cSql += "       A.D2_LOJA   , "
     cSql += "       C.A1_NOME   , "
     cSql += "       C.A1_MUN    , "
     cSql += "       C.A1_EST    , "
     cSql += "       A.D2_ITEM   , "
     cSql += "       A.D2_COD    , "
     cSql += "       D.B1_DESC   , "
     cSql += "       D.B1_DAUX   , "
     cSql += "       D.B1_TIPO   , "
     cSql += "       A.D2_UM     , "
     cSql += "       A.D2_QUANT  , "
//   cSql += "       A.D2_TOTAL  , "
     cSql += "       A.D2_VALBRUT, "
     cSql += "       A.D2_VALFRE , "
     cSql += "       F.C5_FORNEXT  "
     cSql += "  FROM " + RetSqlName("SD2010") + " A, "
     cSql += "       " + RetSqlName("SF2010") + " B, "
     cSql += "       " + RetSqlName("SA1010") + " C, "
     cSql += "       " + RetSqlName("SB1010") + " D, "
     cSql += "       " + RetSqlName("SC5010") + " F, "
     cSql += "       " + RetSqlName("SF4010") + " G  "
     cSql += " WHERE B.F2_DOC       = A.D2_DOC    "
     cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL "
     cSql += "   AND B.F2_SERIE     = A.D2_SERIE  "
     csql += "   AND B.F2_TIPO      = 'N'         "
     cSql += "   AND A.D2_CLIENTE   = C.A1_COD    "
     cSql += "   AND A.D2_LOJA      = C.A1_LOJA   "
     cSql += "   AND A.D2_COD       = D.B1_COD    "
     cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    "
     cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL "
     cSql += "   AND F.R_E_C_D_E_L_ = ''          "
     cSql += "   AND A.D2_TES       = G.F4_CODIGO "
     cSql += "   AND (G.F4_DUPLIC   = 'S' OR A.D2_TES = '543')"
     cSql += "   AND A.R_E_C_D_E_L_ = ''          "
     cSql += "   AND B.R_E_C_D_E_L_ = ''          "
     cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
     cSql += " ORDER BY A.D2_FILIAL, A.D2_DOC, A.D2_SERIE, C.A1_NOME "

     cSql := ChangeQuery( cSql )
     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

     RESULTADO->( DbGoTop() )
     
     nFilial    := RESULTADO->D2_FILIAL
     nDocumento := RESULTADO->D2_DOC
     nSerie     := RESULTADO->D2_SERIE
     nCliente   := RESULTADO->A1_NOME

     While !RESULTADO->( EOF() )
 
        If RESULTADO->D2_TES == "543"
           RESULTADO->( DbSkip() )
           Loop
        Endif

        If Alltrim(RESULTADO->D2_SERIE) == "P1" .AND. ;
           Alltrim(RESULTADO->D2_SERIE) == "P2" .AND. ;
           Alltrim(RESULTADO->D2_SERIE) == "P3"
           RESULTADO->( DbSkip() )
           Loop
        Endif

        If RESULTADO->D2_FILIAL == nFilial    .AND. ;
           RESULTADO->D2_DOC    == nDocumento .AND. ;
           RESULTADO->D2_SERIE  == nSerie     .AND. ;
           RESULTADO->A1_NOME   == nCliente
           
           If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
              nServico := nServico + RESULTADO->D2_VALBRUT
           Else   
//              nProduto := nProduto + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                nProduto := nProduto + RESULTADO->D2_VALBRUT
           Endif   
           
           RESULTADO->( DbSkip() )
           
           Loop
           
        Else
     
           aAdd(aBrowse, { nFilial                        ,; // Código da Filial
                           nDocumento                     ,; // Nº da Nota Fiscal
                           nSerie                         ,; // Série da Nota Fiscal
                           nCliente                       ,; // Nome do Cliente
                           Str(0,10,02)                   ,; // Valor Totao dos Produtos da Aprove
                           Str(0,10,02)                   ,; // Valor Total dos Serviços da Aprove
                           Str(0,10,02)                   ,; // Valor Total das Devoluções da Aprove
                           Str(0,10,02)                   ,; // Valor Total da Aprove                          
                           Str(nProduto,10,02)            ,; // Valor Total dos Produtos da Automatech
                           Str(nServico,10,02)            ,; // Valor Total dos Serviços da Automatech
                           Str(0,10,02)                   ,; // Valor Total das Devoluções da Automatech
                           Str(nProduto + nServico,10,02) ,; // Valor Total da Automatech
                           Str(0,10,02) } )                  // Valor Total das Diferenças entre Aprove x Automatech

           nFilial    := RESULTADO->D2_FILIAL
           nDocumento := RESULTADO->D2_DOC
           nSerie     := RESULTADO->D2_SERIE
           nCliente   := RESULTADO->A1_NOME

           nProduto   := 0
           nServico   := 0
           
           If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
              nServico := nServico + RESULTADO->D2_VALBRUT
           Else   
//              nProduto := nProduto + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                nProduto := nProduto + RESULTADO->D2_VALBRUT
           Endif   

           RESULTADO->( DbSkip() )

        Endif   
        
     Enddo

     aAdd(aBrowse, { nFilial                        ,; // 01 - Código da Filial
                     nDocumento                     ,; // 02 - Nº da Nota Fiscal
                     nSerie                         ,; // 03 - Série da Nota Fiscal
                     nCliente                       ,; // 04 - Nome do Cliente
                     Str(0,10,02)                   ,; // 05 - Valor Total dos Produtos da Aprove
                     Str(0,10,02)                   ,; // 06 - Valor Total dos Serviços da Aprove
                     Str(0,10,02)                   ,; // 07 - Valor Total das Devoluções da Aprove
                     Str(0,10,02)                   ,; // 08 - Valor Total da Aprove                          
                     Str(nProduto,10,02)            ,; // 09 - Valor Total dos Produtos da Automatech
                     Str(nServico,10,02)            ,; // 10 - Valor Total dos Serviços da Automatech
                     Str(0,10,02)                   ,; // 11 - Valor Total das Devoluções da Automatech
                     Str(nProduto + nServico,10,02) ,; // 12 - Valor Total da Automatech
                     Str(0,10,02) } )                  // 13 - Valor Total das Diferenças entre Aprove x Automatech

     // Pesquisa as devoluções ref. ao período informado
     If Select("T_DEVOLUCAO") > 0
        T_DEVOLUCAO->( dbCloseArea() )
     EndIf

     csql = ""
     csql += "SELECT A.D1_FILIAL    ,"
     csql += "       A.D1_EMISSAO   ,"
     csql += "       A.D1_NFORI     ,"
     csql += "       A.D1_SERIORI   ," 
     csql += "       A.D1_TES       ,"
     csql += "       SUM(A.D1_TOTAL) AS DEVOLVE"
     csql += "  FROM " + RetSqlName("SD1010") + " A, "
     cSql += "       " + RetSqlName("SF4010") + " B  "
     cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
     csql += "   AND A.D1_NFORI    <> ''"
     csql += "   AND A.R_E_C_D_E_L_ = ''"
     cSql += "   AND A.D1_TES       = B.F4_CODIGO "
     cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "
     csql += " GROUP BY A.D1_FILIAL, A.D1_EMISSAO, A.D1_NFORI, A.D1_SERIORI, A.D1_TES"

     cSql := ChangeQuery( cSql )
     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

     nTotDevolu := 0
     T_DEVOLUCAO->( DbGoTop() )
     While !T_DEVOLUCAO->( EOF() )
        nTotDevolu := nTotDevolu + T_DEVOLUCAO->DEVOLVE
        T_DEVOLUCAO->( DbSkip() )
     Enddo    

     T_DEVOLUCAO->( DbGoTop() )

     While !T_DEVOLUCAO->( EOF() )
 
        If T_DEVOLUCAO->D1_TES == "543"
           T_DEVOLUCAO->( DbSkip() )
           Loop
        Endif   

        // Pesquisa no array aBrowse o laçamento referente a nota fiscal da devolução
        For nContar = 1 to Len(aBrowse)

            If Alltrim(aBrowse[nContar,01]) == Alltrim(T_DEVOLUCAO->D1_FILIAL) .AND. ;
               Alltrim(aBrowse[nContar,02]) == Alltrim(T_DEVOLUCAO->D1_NFORI)  .AND. ;
               Alltrim(aBrowse[nContar,03]) == Alltrim(T_DEVOLUCAO->D1_SERIORI)

               aBrowse[nContar,11] := Str(val(aBrowse[nContar,11]) + T_DEVOLUCAO->DEVOLVE,10,02)
               aBrowse[nContar,12] := Str(Val(aBrowse[nContar,09]) + Val(aBrowse[nContar,10]) - Val(aBrowse[nContar,11]),10,02)
               
               Exit
               
            Endif
            
        Next nContar       
        
        T_DEVOLUCAO->( DbSkip() )
        
     Enddo   

     // Carrega o arquivo da APROVE
     If !Empty(Alltrim(cCaminho01))

        nHandle := FOPEN(Alltrim(cCaminho01), FO_READWRITE + FO_SHARED)
     
        If FERROR() != 0
           MsgAlert("Erro ao abrir o arquivo de produtos da APROVE.")
           Return .T.
        Endif

        // Lê o tamanho total do arquivo
        nLidos :=0
  	    FSEEK(nHandle,0,0)
	    nTamArq:=FSEEK(nHandle,0,2)
	    FSEEK(nHandle,0,0)

        // Lê todos os Registros
        xBuffer:=Space(nTamArq)
        FREAD(nHandle,@xBuffer,nTamArq)

        // Carrega o Array aLinha separando linha a linha do arquivo aberto
        XBuffer := StrTran(xBuffer, chr(10), "|")

        cLinha := ""

        For nContar = 1 to Len(xBuffer)

            If Substr(xBuffer, nContar, 1) <> chr(13)
 
               cLinha := cLinha + Substr(xBuffer, nContar, 1)
                
            Else

               aAdd(aLinhas, { Alltrim(cLinha ) } )

               cLinha := ""

               If Substr(xBuffer, nContar, 1) == chr(10)
                  nContar += 1
               Endif   
            
            Endif

        Next nContar    

        For nContar = 1 to Len(aLinhas)

            aLinhas[nContar,01] := StrTran(aLinhas[nContar,01], CHR(9), "|")

            If Substr(aLinhas[nContar,01],01,04) == "0357"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,05) == "|CNPJ"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,08) == "|Nr Lcto"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,07) == "|Totais"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,06) == "|Total"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,11) == "|__________"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,09) == "|- Saídas"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,11) == "|- Entradas"
               Loop
            Endif
   
            If Substr(aLinhas[nContar,01],01,10) == "|Natureza:"
               cNatureza := aLinhas[nContar,01]
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,08) == "|Filial:"
               cCodFil := Substr(aLinhas[nContar,01],10,04) 
               Loop
            Endif

            cDado01 := ""
            cDado02 := ""
            cDado03 := ""
            cDado04 := ""
            cDado05 := ""                    
            cDado06 := ""
            cDado07 := ""
            cDado08 := ""
            cDado09 := ""
            cDado10 := ""                    
            cDado11 := ""
            cDado12 := ""                    
            cDado13 := ""
            cDado14 := ""
            cDado15 := ""
            cDado16 := ""
            cDado17 := ""                    
            cDado18 := ""
            cDado19 := ""
            cDado20 := ""
            cDado21 := ""
            cDado22 := ""                    
            cDado23 := ""
            cDado24 := ""                    
          
            nQuebra := 1

            For nSepara = 1 to Len(Alltrim(aLinhas[nContar,1]))
          
                If Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1) == " "
                   nQuebra := nQuebra + 1
                   Loop
                Endif   
              
                Do Case
                   Case nQuebra == 1
                        cDado01 := cDado01 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 2
                        cDado02 := cDado02 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 3
                        cDado03 := cDado03 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 4
                        cDado04 := cDado04 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 5
                        cDado05 := cDado05 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 6
                        cDado06 := cDado06 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 7
                        cDado07 := cDado07 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 8
                        cDado08 := cDado08 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 9
                        cDado09 := cDado09 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 10
                        cDado10 := cDado10 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 11
                        cDado11 := cDado11 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 12
                        cDado12 := cDado12 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 13
                        cDado13 := cDado13 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 14
                        cDado14 := cDado14 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 15
                        cDado15 := cDado15 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 16
                        cDado16 := cDado16 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 17
                        cDado17 := cDado17 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 18
                        cDado18 := cDado18 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 19
                        cDado19 := cDado19 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 20
                        cDado20 := cDado20 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 21     
                        cDado21 := cDado21 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 22
                        cDado22 := cDado22 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 23
                        cDado23 := cDado23 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 24
                        cDado24 := cDado24 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                EndCase        
            Next nSepara

            If Len(Alltrim(cDado05)) > 10
               cXNota  := Substr(cDado05,11)
               cXSerie := cDado07
               cXConta := cDado08
               cXValor := cDado09
            Else
               cXNota  := cDado06 
               cXSerie := cDado09 
               cXConta := cDado10
               cXValor := cDado11
            Endif

            _Valor := StrTran(cXValor, ".", "" )
            _Valor := StrTran(_Valor , ",", ".")

            If !Empty(Alltrim(cXNota) + Alltrim(cXSerie) + Alltrim(cXValor))
               If Alltrim(cXNota) == "AUTOMACAO" .OR. ;
                  Empty(Alltrim(cXNota))         .OR. ;
                  !ISDIGIT(Substr(cXNota,01,01))
               Else
                  aAdd(aLeitura, { cCodFil, cXNota, cXSerie, cXConta, _Valor, cNatureza  } )
               Endif   
            Endif   
  
        Next nContar    

     Endif

     // Localiza as notas fiscais da Aprove dentro nas notas fiscais da Automatech
     For nContar = 1 to Len(aLeitura)
                  
         // Trata Devoluções
         If Substr(aLeitura[nContar,04],01,01) == "1" .OR. Substr(aLeitura[nContar,04],01,01) == "2"
    
            // Pesquisa na tabela SD1 a nota fiscal de Origem para comparação
            If Select("T_DEVOLVE") > 0
               T_DEVOLVE->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT D1_NFORI  , "
            cSql += "       D1_SERIORI  "
            cSql += "  FROM " + RetSqlName("SD1")
            cSql += " WHERE D1_DOC   = '" + Alltrim(aLeitura[nContar,02]) + "'"
            cSql += "   AND D1_SERIE = '" + Alltrim(aLeitura[nContar,03]) + "'"
                   
            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLVE", .T., .T. )

            If T_DEVOLVE->( EOF() )
            
               If Select("T_DEVOLVE") > 0
                  T_DEVOLVE->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT D1_NFORI  , "
               cSql += "       D1_SERIORI  "
               cSql += "  FROM " + RetSqlName("SD1")
               cSql += " WHERE D1_DOC   = '" + Alltrim(Strzero(Int(Val(aLeitura[nContar,02])),6)) + "'"
               cSql += "   AND D1_SERIE = '" + Alltrim(aLeitura[nContar,03])                      + "'"
                   
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLVE", .T., .T. )

               If !T_DEVOLVE->( EOF() )

                  // Localiza no array aBrowse o possível lançamento do array aNotas - Série 1 - Porto Alegre
                  For nProcura = 1 to Len(aBrowse)

                      If Alltrim(Str(Int(Val(aBrowse[nProcura,02])))) == Alltrim(Str(Int(Val(T_DEVOLVE->D1_NFORI)))) .AND. ;
                         Alltrim(Str(Int(Val(aBrowse[nProcura,03])))) == Alltrim(Str(Int(Val(T_DEVOLVE->D1_SERIORI))))      
                         aBrowse[nProcura,07] := Alltrim(aLeitura[nContar,05])
                         Exit
                      Endif
                  
                  Next nProcura
                   
               Endif
               
            Endif
                   
         Endif
                   
         // Vendas
         If Substr(aLeitura[nContar,04],01,01) == "5" .OR. Substr(aLeitura[nContar,04],01,01) == "6"

            For nProcura = 1 to Len(aBrowse)

                If Alltrim(Str(Int(Val(aBrowse[nProcura,02])))) == Alltrim(aLeitura[nContar,02]) .AND. ; // Nota Fisca
                   Alltrim(Str(Int(Val(aBrowse[nProcura,03])))) == Alltrim(aLeitura[nContar,03])         // Série da Nota Fiscal
                   aBrowse[nProcura,05] := Alltrim(aLeitura[nContar,05])
                   Exit
                Endif   
                
            Next nProcura    
                   
         Endif

     Next nContar   

     // Carrega o arquivo da APROVE - SERVIÇOS
     If !Empty(Alltrim(cCaminho02))

        aLinhas := {}

        nHandle := FOPEN(Alltrim(cCaminho02), FO_READWRITE + FO_SHARED)
     
        If FERROR() != 0
           MsgAlert("Erro ao abrir o arquivo de produtos da APROVE.")
           Return .T.
        Endif

        // Lê o tamanho total do arquivo
        nLidos :=0
  	    FSEEK(nHandle,0,0)
	    nTamArq:=FSEEK(nHandle,0,2)
	    FSEEK(nHandle,0,0)

        // Lê todos os Registros
        xBuffer:=Space(nTamArq)
        FREAD(nHandle,@xBuffer,nTamArq)

        // Carrega o Array aLinha separando linha a linha do arquivo aberto
        XBuffer := StrTran(xBuffer, chr(10), "|")

        cLinha := ""

        For nContar = 1 to Len(xBuffer)

            If Substr(xBuffer, nContar, 1) <> chr(13)
 
               cLinha := cLinha + Substr(xBuffer, nContar, 1)
                
            Else

               aAdd(aLinhas, { Alltrim(cLinha ) } )

               cLinha := ""

               If Substr(xBuffer, nContar, 1) == chr(10)
                  nContar += 1
               Endif   
            
            Endif

        Next nContar    

        For nContar = 1 to Len(aLinhas)

            aLinhas[nContar,01] := StrTran(aLinhas[nContar,01], CHR(9), "|")

            If Substr(aLinhas[nContar,01],01,04) == "0357"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,05) == "|CNPJ"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,08) == "|Nr Lcto"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,07) == "|Totais"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,06) == "|Total"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,11) == "|__________"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,09) == "|- Saídas"
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,11) == "|- Entradas"
               Loop
            Endif
   
            If Substr(aLinhas[nContar,01],01,10) == "|Natureza:"
               cNatureza := aLinhas[nContar,01]
               Loop
            Endif

            If Substr(aLinhas[nContar,01],01,08) == "|Filial:"
               cCodFil := Substr(aLinhas[nContar,01],10,04) 
               Loop
            Endif

            cDado01 := ""
            cDado02 := ""
            cDado03 := ""
            cDado04 := ""
            cDado05 := ""                    
            cDado06 := ""
            cDado07 := ""
            cDado08 := ""
            cDado09 := ""
            cDado10 := ""                    
            cDado11 := ""
            cDado12 := ""                    
            cDado13 := ""
            cDado14 := ""
            cDado15 := ""
            cDado16 := ""
            cDado17 := ""                    
            cDado18 := ""
            cDado19 := ""
            cDado20 := ""
            cDado21 := ""
            cDado22 := ""                    
            cDado23 := ""
            cDado24 := ""                    
          
            nQuebra := 1

            For nSepara = 1 to Len(Alltrim(aLinhas[nContar,1]))
          
                If Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1) == " "
                   nQuebra := nQuebra + 1
                   Loop
                Endif   
              
                Do Case
                   Case nQuebra == 1
                        cDado01 := cDado01 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 2
                        cDado02 := cDado02 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 3
                        cDado03 := cDado03 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 4
                        cDado04 := cDado04 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 5
                        cDado05 := cDado05 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 6
                        cDado06 := cDado06 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 7
                        cDado07 := cDado07 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 8
                        cDado08 := cDado08 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 9
                        cDado09 := cDado09 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 10
                        cDado10 := cDado10 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 11
                        cDado11 := cDado11 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 12
                        cDado12 := cDado12 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 13
                        cDado13 := cDado13 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 14
                        cDado14 := cDado14 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 15
                        cDado15 := cDado15 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 16
                        cDado16 := cDado16 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 17
                        cDado17 := cDado17 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 18
                        cDado18 := cDado18 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 19
                        cDado19 := cDado19 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 20
                        cDado20 := cDado20 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 21     
                        cDado21 := cDado21 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 22
                        cDado22 := cDado22 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 23
                        cDado23 := cDado23 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                   Case nQuebra == 24
                        cDado24 := cDado24 + Substr(Alltrim(aLinhas[nContar,1]),nSepara, 1)
                EndCase        
            Next nSepara

            If Alltrim(cDado09) == "8.000.002"
               cXNota  := cDado06
               cXSerie := "U"
               cXConta := cDado09
               cXValor := cDado10
            Else
               cXNota  := cDado06 
               cXSerie := cDado09 
               cXConta := cDado10
               cXValor := cDado11
            Endif

            _Valor := StrTran(cXValor, ".", "" )
            _Valor := StrTran(_Valor , ",", ".")

            If !Empty(Alltrim(cXNota) + Alltrim(cXSerie) + Alltrim(cXValor))
               If Alltrim(cXNota) == "AUTOMACAO" .OR. ;
                  Empty(Alltrim(cXNota))         .OR. ;
                  !ISDIGIT(Substr(cXNota,01,01))
               Else

                  Do Case
                     Case cCodFil == "0001"
                          cXSerie := "51"
                     Case cCodFil == "0002"
                          cXSerie := "52"
                     Case cCodFil == "0003"
                          cXSerie := "53"
                  EndCase        

                  aAdd(aServicos, { cCodFil, cXNota, cXSerie, cXConta, _Valor, cNatureza  } )

               Endif   

            Endif   
  
        Next nContar    

     Endif

     // Localiza as notas fiscais da Aprove dentro nas notas fiscais da Automatech
     For nContar = 1 to Len(aServicos)
                  
         // Localiza no array aBrowse o possível lançamento do array aNotas - Série 1 - Porto Alegre
         For nProcura = 1 to Len(aBrowse)

             If Alltrim(Str(Int(Val(aBrowse[nProcura,02])))) == Alltrim(aServicos[nContar,02]) .AND. ; // Nota Fisca
                Alltrim(Str(Int(Val(aBrowse[nProcura,03])))) == Alltrim(aServicos[nContar,03])         // Série da Nota Fiscal
                aBrowse[nProcura,06] := Alltrim(aServicos[nContar,05])
                Exit
             Endif   
                   
         Next nProcura        

     Next nContar   

     // Atualiza os totalizadores da pesquisa
     nProdutoV  := 0
     nServicoV  := 0
     nDevolveV  := 0
     nTotalV    := 0
     nProdutoA  := 0
     nServicoA  := 0
     nDevolveA  := 0
     nTotalA    := 0
     nDiferenca := 0

     // Acerta os totais do browse
     For nContar = 1to Len(aBrowse)
         aBrowse[ncontar,08] := Str(Val(aBrowse[nContar,05]) + Val(aBrowse[nContar,06]) - Val(aBrowse[nContar,07]),10,02)
         aBrowse[nContar,12] := Str(Val(aBrowse[ncontar,09]) + Val(aBrowse[nContar,10]) - Val(aBrowse[nContar,11]),10,02)
         aBrowse[nContar,13] := Str(Val(aBrowse[nContar,08]) - Val(aBrowse[nContar,12]),10,02)

         // Acumula os totalizadores da consulta
         nProdutoV := nProdutoV + Val(aBrowse[nContar,05])
         nServicoV := nServicoV + Val(aBrowse[ncontar,06])
         nDevolveV := nDevolveV + Val(aBrowse[ncontar,07])
         nTotalV   := nTotalV   + Val(aBrowse[nContar,08])

         nProdutoA := nProdutoA + Val(aBrowse[nContar,09])
         nServicoA := nServicoA + Val(aBrowse[nContar,10])
         nDevolveA := nDevolveA + Val(aBrowse[nContar,11])
         nTotalA   := nTotalA   + Val(aBrowse[nContar,12])

     Next nContar     

     nProdutoD := nProdutoA - nprodutoV
     nServicoD := nServicoA - nServicoV  
     nDevolveD := nDevolveA - nDevolveV  
     nTotalD   := nTotalA   - nTotalV    

     If nTotDevolu <> 0
        If nDevolveA > nTotDevolu
           nTotalA  := nTotalA - (nDevolveA - nTotDevolu)
           nOutrasA := nDevolveA - nTotDevolu
        Else
           nTotalA  := nTotalA - (nTotDevolu - nDevolveA)
           nOutrasA := nTotDevolu - nDevolveA
        Endif
     Endif

     nDevolveA  := nDevolveA + nOutrasA

     nDiferenca := nTotalV - nTotalA

     nMaiorAut  := 0
     nMaiorApr  := 0

     For nContar = 1 to Len(aBrowse)

         If Val(aBrowse[nContar,13]) == 0
            Loop
         Endif
          
         If Val(aBrowse[nContar,13]) < 0
            nMaiorAut := nMaiorAut + Val(aBrowse[nContar,13]) 
         Else
            nMaiorApr := nMaiorApr + Val(aBrowse[nContar,13]) 
         Endif   
         
     Next nContar    

     If nMaiorAut < 0
        nMaiorAut := nMaiorAut * -1
     Endif   

     If nMaiorApr < 0
        nMaiorApr := nMaiorApr * -1
     Endif   

     If lCheckbox1 == .T.

        aTransito := {}

        For nContar = 1 to Len(aBrowse)

            aAdd( aTransito, { aBrowse[nContar,01],; 
                               aBrowse[nContar,02],;
                               aBrowse[nContar,03],;
                               aBrowse[nContar,04],;
                               aBrowse[nContar,05],;
                               aBrowse[nContar,06],;
                               aBrowse[nContar,07],;
                               aBrowse[nContar,08],;                                                                                                                            
                               aBrowse[nContar,09],;
                               aBrowse[nContar,10],;
                               aBrowse[nContar,11],;
                               aBrowse[nContar,12],;
                               aBrowse[nContar,13] } )

        Next nContar

        aBrowse := {}

        For nContar = 1 to Len(aTransito)

            If VAL(aTransito[nContar,13]) == 0
               Loop
            Endif

            aAdd( aBrowse, { aTransito[nContar,01],; 
                             aTransito[nContar,02],;
                             aTransito[nContar,03],;
                             aTransito[nContar,04],;
                             aTransito[nContar,05],;
                             aTransito[nContar,06],;
                             aTransito[nContar,07],;
                             aTransito[nContar,08],;                                                                                                                            
                             aTransito[nContar,09],;
                             aTransito[nContar,10],;
                             aTransito[nContar,11],;
                             aTransito[nContar,12],;
                             aTransito[nContar,13] } )
                             
         Next nContar                    

     Endif

     oBrowse := TSBrowse():New(045,005,630,160,oDlg,,1,,1)
     oBrowse:AddColumn( TCColumn():New('FL'        ,,,{|| },{|| }) ) 
     oBrowse:AddColumn( TCColumn():New('Nº NF'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Série'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Cliente'   ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New("Prod. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Prod. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Diferença"   ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:SetArray(aBrowse)

Return .T.

// Função que mostra os dados importados do arquivo da Aprove
Static Function MOSTRAAQ1(aLeitura)

   Local cMemo1  := ""
   Local oMemo1
   Local nTotal  := 0
   Local nContar := 0
   Local nGet1   := ""

   Private _xOdlg
   
   oFont21   := TFont():New( "Courier New",,16,,.t.,,,,.f.,.f. )

   For nContar = 1 to Len(aLeitura)
       cMemo1 := cMemo1 + "FILIAL: " + aLeitura[nContar,1] + " | " + "NOTA: "  + Alltrim(aLeitura[nContar,2]) + Space(10 - Len(Alltrim(aLeitura[nContar,2]))) + " | " + ;
                          "SERIE: "  + aLeitura[nContar,3] + " | " + ;
                          "CONTA: "  + aLeitura[nContar,4] + " | " + ;
                          "VALOR: "  + Space(15 - Len(Alltrim(aLeitura[nContar,5]))) + ;
                          Alltrim(aLeitura[nContar,5]) + " | " + ;
                          aLeitura[nContar,6] + chr(13) + chr(10)
        nTotal := nTotal + val(aLeitura[nContar,5])
   Next nContar

   // Mostra o resultado
   DEFINE MSDIALOG _xOdlg TITLE "Conteúdo Importado - PRODUTOS/DEVOLUÇÕES" FROM C(178),C(181) TO C(645),C(1150) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(007),C(009) GET oMemo1   Var cMemo1 MEMO Font oFont21 Size C(470),C(194) PIXEL OF _xOdlg 
   @ C(211),C(009) MsGet oGet1  Var nTotal Size C(050),C(010) COLOR CLR_BLACK Picture "9999999999.99" PIXEL OF _xOdlg
   @ C(211),C(434) Button "OK" Size C(037),C(012) PIXEL OF _xOdlg ACTION( _xOdlg:End() )

   ACTIVATE MSDIALOG _xOdlg CENTERED 
   
Return .T.

// Função que mostra os dados importados do arquivo da Aprove
Static Function MOSTRAAQS(aServicos)

   Local cMemo2  := ""
   Local oMemo2
   Local nTotSer := 0
   Local nContar := 0
   Local nGet10  := ""

   Private _yOdlg
   
   oFont21 := TFont():New( "Courier New",,16,,.t.,,,,.f.,.f. )

   nTotSer := 0

   For nContar = 1 to Len(aServicos)
       cMemo2 := cMemo2 + "FILIAL: " + aServicos[nContar,1] + " | " + "NOTA: "  + Alltrim(aServicos[nContar,2]) + Space(10 - Len(Alltrim(aServicos[nContar,2]))) + " | " + ;
                          "SERIE: "  + aServicos[nContar,3] + " | " + ;
                          "CONTA: "  + aServicos[nContar,4] + " | " + ;
                          "VALOR: "  + Space(15 - Len(Alltrim(aServicos[nContar,5]))) + ;
                          Alltrim(aServicos[nContar,5]) + " | " + ;
                          aServicos[nContar,6] + chr(13) + chr(10)
        nTotSer := nTotSer + val(aServicos[nContar,5])
   Next nContar

   // Mostra o resultado
   DEFINE MSDIALOG _yOdlg TITLE "Conteúdo Importado - SERVIÇOS" FROM C(178),C(181) TO C(645),C(1150) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(007),C(009) GET oMemo2   Var cMemo2  MEMO Font oFont21 Size C(470),C(194) PIXEL OF _yOdlg 
   @ C(211),C(009) MsGet oGet10 Var nTotSer Size C(050),C(010) COLOR CLR_BLACK Picture "9999999999.99" PIXEL OF _yOdlg
   @ C(211),C(434) Button "OK" Size C(037),C(012) PIXEL OF _yOdlg ACTION( _yOdlg:End() )

   ACTIVATE MSDIALOG _yOdlg CENTERED 
   
Return .T.