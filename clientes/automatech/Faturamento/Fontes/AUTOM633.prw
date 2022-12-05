#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOMR08.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 24/08/2011                                                          ##
// Objetivo..: Relatório de Faturamento por Grupo/Produto	                       ##
// ##################################################################################

User Function AUTOM633()
 
   Local lchumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private dData01  := Ctod("  /  /    ")
   Private dData02  := Ctod("  /  /    ")
   Private cGrupo   := Space(25)
   Private cNomeG   := Space(25)
   Private cProduto := Space(25)
   Private cNomeP   := Space(25)
   Private aTIPOREG := {"00 - Selecione", "01 - Notas Pendentes", "02 - Notas Atendidas", "03 - Ambas"}
   Private aVisual  := {"ANALÍTICO", "SINTÉTICO"}

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private cComboBx1
   Private cComboBx2

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Faturamento por Grupo de produtos - COMPRAS" FROM C(178),C(181) TO C(515),C(573) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(190),C(001) PIXEL OF oDlg
   @ C(145),C(002) GET oMemo2 Var cMemo2 MEMO Size C(190),C(001) PIXEL OF oDlg

   @ C(033),C(005) Say "Emissão Inicial"      Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(033),C(048) Say "Emissão Final"        Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Grupo"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(078),C(005) Say "Produto"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(100),C(005) Say "Tipo de Pesquisa"     Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(122),C(005) Say "Tipo de Visualização" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		   
   @ C(043),C(005) MsGet    oGet1     Var   dData01   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(048) MsGet    oGet2     Var   dData02   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(065),C(005) MsGet    oGet3     Var   cGrupo    Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SBM") VALID( BuscaNomeGrupo() )
   @ C(065),C(032) MsGet    oGet4     Var   cNomeG    Size C(160),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(087),C(005) MsGet    oGet5     Var   cProduto  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNomeProd() )
   @ C(087),C(069) MsGet    oGet6     Var   cNomeP    Size C(123),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(109),C(005) ComboBox cComboBx1 Items aTIPOREG  Size C(188),C(010)                              PIXEL OF oDlg
   @ C(132),C(005) ComboBox cComboBx2 Items aVISUAL   Size C(188),C(010)                              PIXEL OF oDlg

   @ C(152),C(059) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( FATUPER() )
   @ C(152),C(098) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #########################################################
// Função que pesquisa a descrição do produto selecionado ##
// #########################################################
Static Function BuscaNomeProd()

   Local cSql := ""
   
   If Empty(Alltrim(cProduto))
      cProduto := Space(30)
      cNomeP   := ""
      oGet5:Refresh()
      oGet6:Refresh()
      Return(.T.)
   Endif
      
   cNomeP := Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC" )
   
   If Empty(Alltrim(cNomeP))
      MsgAlert("Produto não cadastrado. Verifique!")
      cProduto := Space(30)
      cNomeP   := ""
      oGet5:Refresh()
      oGet6:Refresh()
      Return(.T.)
   Endif

   oGet5:Refresh()
   oGet6:Refresh()

Return .T.

// #######################################################
// Função que pesquisa a descrição do grupo selecionado ##
// #######################################################
Static Function BuscaNomeGrupo()

   Local cSql := ""
   
   If Empty(Alltrim(cGrupo))
      cGrupo  := Space(30)
      cNomeG  := ""
      oGet3:Refresh()
      oGet4:Refresh()
      Return(.T.)
   Endif
      
   cNomeG := Posicione( "SBM", 1, xFilial("SBM") + cGrupo, "BM_DESC" )
   
   If Empty(Alltrim(cNomeg))
      MsgAlert("Grupo não cadastrado. Verifique!")
      cGrupo := Space(04)
      cNomeG   := ""
      oGet3:Refresh()
      oGet4:Refresh()
      Return(.T.)
   Endif

   oGet3:Refresh()
   oGet4:Refresh()

Return .T.

// ##############################################
// Função que prepara a impressão do relatório ##
// ##############################################
Static Function FATUPER()

   MsgRun("Aguarde! Gerando Relatório de Fauramento ...", "Faturamento por Grupo de Produtos",{|| xFATUPER() })

Return(.T.)

// ##############################################
// Função que prepara a impressão do relatório ##
// ##############################################
Static Function xFATUPER()

   // ##########################
   // Declaracao de Variaveis ##
   // ##########################
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Vendedor"
   Local cPict          := ""
   Local titulo         := "Vendas por Vendedor"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}
   Local _Filial        := ""
   
   _Filial              := cFilAnt

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""

   If Alltrim(cComboBx2) == "ANALÍTICO"
      Private limite  := 220
      Private tamanho := "G"
   Else   
      Private limite  := 80
      Private tamanho := "P"
   Endif   

   Private nomeprog     := "Faturamento-Produto"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Faturamento-Produto"
   Private cString      := "SC5"
   Private aDevolucao   := {}
   Private nDevolve     := 0

   // #########################
   // Consistência dos Dados ##
   // #########################
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Tipo de pesquisa não selecionada.")
      Return .T.
   Endif

   // ###################################################
   // Pesquisa as devoluções ref. ao período informado ##
   // ###################################################
   If Select("T_DEVOLUCAO") > 0
      T_DEVOLUCAO->( dbCloseArea() )
   EndIf

   csql = ""
   csql += "SELECT A.D1_FILIAL  ,"                                                  + CHR(13)
   csql += "       A.D1_TOTAL   ,"                                                  + CHR(13)
   csql += "       A.D1_EMISSAO ,"                                                  + CHR(13)
   csql += "       A.D1_NFORI   ,"                                                  + CHR(13)
   csql += "       A.D1_SERIORI ,"                                                  + CHR(13)
   csql += "       A.D1_ITEMORI ,"                                                  + CHR(13)
   cSql += "       A.D1_COD     ,"                                                  + CHR(13)
   cSql += "       C.B1_GRUPO    "                                                  + CHR(13)
   csql += "  FROM " + RetSqlName("SD1") + " A, "                                   + CHR(13)
   cSql += "       " + RetSqlName("SF4") + " B, "                                   + CHR(13)
   cSql += "       " + RetSqlName("SB1") + " C  "                                   + CHR(13)
   cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + CHR(13)
   cSql += "   AND A.D1_DTDIGIT  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + CHR(13)
   cSql += "   AND A.D1_COD       = C.B1_COD "                                      + CHR(13)
   cSql += "   AND A.D1_FILIAL    = '" + Alltrim(cFilAnt) + "'"                     + CHR(13)
// csql += "   AND A.D1_NFORI    <> ''"                                             + CHR(13)
   csql += "   AND A.R_E_C_D_E_L_ = ''"                                             + CHR(13)
   cSql += "   AND A.D1_TES       = B.F4_CODIGO "                                   + CHR(13)
   cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "                      + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

   T_DEVOLUCAO->( DbGoTop() )

   While !T_DEVOLUCAO->( EOF() )
     aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,;
                         T_DEVOLUCAO->D1_TOTAL  ,;
                         T_DEVOLUCAO->D1_EMISSAO,;
                         T_DEVOLUCAO->D1_NFORI  ,;
                         T_DEVOLUCAO->D1_SERIORI,;
                         T_DEVOLUCAO->D1_ITEMORI,;
                         .F.                    ,;
                         ""                     ,;
                         T_DEVOLUCAO->D1_COD    ,;
                         T_DEVOLUCAO->B1_GRUPO})
     T_DEVOLUCAO->( DbSkip() )
   Enddo

   // ############################################## 
   // Pesquisa os dados para emissão do relatório ##
   // ##############################################
   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.D2_FILIAL , "                  + chr(13)
   cSql += "       A.D2_DOC    , "                  + chr(13)
   cSql += "       A.D2_SERIE  , "                  + chr(13)
   cSql += "       A.D2_EMISSAO, "                  + chr(13)
   cSql += "       A.D2_TES    , "                  + chr(13)
   cSql += "       A.D2_QUANT  , "                  + chr(13)
   cSql += "       A.D2_UM     , "                  + chr(13)
   cSql += "       G.F4_DUPLIC , "                  + chr(13)
   cSql += "       A.D2_CF     , "                  + chr(13)
   cSql += "       A.D2_PEDIDO , "                  + chr(13)
   cSql += "       A.D2_ITEMPV , "                  + Chr(13) 
   cSql += "      (SELECT C6_PCOMPRA "              + Chr(13)
   cSql += "         FROM " + RetSqlName("SC6")     + Chr(13)
   cSql += "        WHERE C6_FILIAL  = A.D2_FILIAL" + Chr(13)
   cSql += "          AND C6_NUM     = A.D2_PEDIDO" + Chr(13)
   cSql += "          AND C6_PRODUTO = A.D2_COD   " + Chr(13)
   cSql += "          AND C6_ITEM    = A.D2_ITEMPV" + Chr(13)
   cSql += "          AND D_E_L_E_T_ = '')"         + Chr(13)
   cSql += "       AS P_COMPRA,"                    + Chr(13)  
   cSql += "      (SELECT C6_ITEMPC "               + Chr(13)
   cSql += "         FROM " + RetSqlName("SC6")     + Chr(13)
   cSql += "        WHERE C6_FILIAL  = A.D2_FILIAL" + Chr(13)
   cSql += "          AND C6_NUM     = A.D2_PEDIDO" + Chr(13)
   cSql += "          AND C6_PRODUTO = A.D2_COD   " + Chr(13)
   cSql += "          AND C6_ITEM    = A.D2_ITEMPV" + Chr(13)
   cSql += "          AND D_E_L_E_T_ = '')"         + Chr(13)
   cSql += "       AS P_ITEMPC,"                    + Chr(13)  
   cSql += "       F.C5_FRETE  , "                  + chr(13)
   cSql += "       A.D2_CLIENTE, "                  + chr(13)
   cSql += "       A.D2_LOJA   , "                  + chr(13)
   cSql += "       C.A1_NOME   , "                  + chr(13)
   cSql += "       C.A1_MUN    , "                  + chr(13)
   cSql += "       C.A1_EST    , "                  + chr(13)
   cSql += "       A.D2_ITEM   , "                  + chr(13)
   cSql += "       A.D2_COD    , "                  + chr(13)
   cSql += "       D.B1_COD    , "                  + chr(13)
   cSql += "       D.B1_DESC   , "                  + chr(13)
   cSql += "       D.B1_DAUX   , "                  + chr(13)
   cSql += "       D.B1_TIPO   , "                  + chr(13)
   cSql += "       D.B1_GRUPO  , "                  + chr(13)
   cSql += "       A.D2_UM     , "                  + chr(13)
   cSql += "       A.D2_QUANT  , "                  + chr(13)
   cSql += "       A.D2_TOTAL  , "                  + chr(13)
   cSql += "       A.D2_VALFRE , "                  + chr(13)
   cSql += "       F.C5_FORNEXT, "                  + chr(13)
   cSql += "       H.BM_GRUPO  , "                  + chr(13)
   cSql += "       H.BM_DESC     "                  + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " A, "   + chr(13)
   cSql += "       " + RetSqlName("SF2") + " B, "   + chr(13)
   cSql += "       " + RetSqlName("SA1") + " C, "   + chr(13)
   cSql += "       " + RetSqlName("SB1") + " D, "   + chr(13)
   cSql += "       " + RetSqlName("SC5") + " F, "   + chr(13)
   cSql += "       " + RetSqlName("SF4") + " G, "   + chr(13)
   cSql += "       " + RetSqlName("SBM") + " H  "   + chr(13)
   cSql += " WHERE B.F2_DOC       = A.D2_DOC    "   + chr(13)
   cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL "   + chr(13)
   cSql += "   AND B.F2_SERIE     = A.D2_SERIE  "   + chr(13)
   csql += "   AND B.F2_TIPO      = 'N'         "   + chr(13)
   cSql += "   AND A.D2_CLIENTE   = C.A1_COD    "   + chr(13)
   cSql += "   AND A.D2_LOJA      = C.A1_LOJA   "   + chr(13)
   cSql += "   AND A.D2_COD       = D.B1_COD    "   + chr(13)
   cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    "   + chr(13)
   cSql += "   AND A.D2_TES       = '717'       "   + Chr(13)
   cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL "   + chr(13)
   cSql += "   AND F.R_E_C_D_E_L_ = ''          "   + chr(13)
   cSql += "   AND A.D2_TES       = G.F4_CODIGO "   + chr(13)
   cSql += "   AND G.F4_DUPLIC    = 'S'         "   + chr(13)
   cSql += "   AND A.R_E_C_D_E_L_ = ''          "   + chr(13)
   cSql += "   AND B.R_E_C_D_E_L_ = ''          "   + chr(13)
   cSql += "   AND D.B1_GRUPO     = H.BM_GRUPO  "   + chr(13)
   cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + chr(13)
   cSql += "   AND A.D2_EMISSAO  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)
   cSql += "   AND A.D2_FILIAL    = '" + Alltrim(cFilAnt) + "'"                     + chr(13)

   If Empty(Alltrim(cGrupo))
   Else
      cSql += "  AND D.B1_GRUPO = '" + Alltrim(cGrupo) + "'" + chr(13)
   Endif

   If !Empty(Alltrim(cProduto))
      cSql += "  AND D.B1_COD   = '" + Alltrim(cProduto)  + "'" + chr(13)
   Endif

   cSql += " ORDER BY A.D2_FILIAL, D.B1_GRUPO, D.B1_COD" + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

   RESULTADO->( DbGoTop() )

   If RESULTADO->( Eof() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   pergunte(cPerg,.F.)

   // #########################################
   // Monta a interface padrao com o usuario ##
   // #########################################
   wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // ######################################################################
   // Processamento. RPTSTATUS monta janela com a regua de processamento. ##
   // ######################################################################
   RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return .T.

// ##############################
// Função que gera o relatório ##
// ##############################
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
   Local nPagina   := 0
   Local aPesquisa := {}

   // ################################
   // Imprime o relatório analítico ##
   // ################################
   If Alltrim(cComboBx2) == "ANALÍTICO"

      cEmpFil   := Resultado->D2_FILIAL
      cGrupo    := Resultado->BM_GRUPO
      cMaterial := Resultado->B1_COD

      // #############################
      // Totalizadores dos produtos ##
      // #############################
      nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
      nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

      // ###########################
      // Totalizadores dos grupos ##
      // ###########################
      nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
      nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

      // ############################
      // Totalizadores das filiais ##
      // ############################
      nQuaFInte := 0; nProFInte := 0; nSerFInte := 0; nFreFInte := 0; nTotFInte := 0; nDevFInte := 0
      nQuaFExte := 0; nProFExte := 0; nSerFExte := 0; nFreFExte := 0; nTotFExte := 0; nDevFExte := 0

      // ############################
      // Totalizadores das filiais ##
      // ############################
      nQuaAInte := 0; nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
      nQuaAExte := 0; nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

      // ################################
      // Controle numeração de páginas ##
      // ################################
      nPagina  := 0

      While !Resultado->( EOF() )

         // ####################################################################
         // Pesquisa a nota fiscal de entrada relacionada ao pedido de compra ##
         // ####################################################################
         If Select("T_PCOMPRA") > 0
            T_PCOMPRA->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql += "SELECT D1_DOC"
         cSql += "  FROM " + RetSqlName("SD1") 
         cSql += " WHERE D1_FILIAL  = '" + Alltrim(Resultado->D2_FILIAL) + "'"
         cSql += "   AND D1_COD     = '" + Alltrim(Resultado->B1_COD)    + "'"
         cSql += "   AND D1_PEDIDO  = '" + Alltrim(Resultado->P_COMPRA)  + "'"
         cSql += "   AND D1_ITEMPC  = '" + Alltrim(Resultado->P_ITEMPC)  + "'"
         cSql += "   AND D_E_L_E_T_ = ''"
 
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PCOMPRA", .T., .T. )

         kNFEntrada := IIF(T_PCOMPRA->( EOF() ), "", T_PCOMPRA->D1_DOC) 

         If Substr(cComboBx1,01,02) == "01"
            If Empty(Alltrim(kNFEntrada))
            Else
               Resultado->( DbSkip() )
               Loop
            Endif
         Endif
               
         If Substr(cComboBx1,01,02) == "02"
            If Empty(Alltrim(kNFEntrada))
               Resultado->( DbSkip() )
               Loop
            Endif
         Endif

         If Alltrim(Resultado->D2_FILIAL) == Alltrim(cEmpFil)

            If Alltrim(Resultado->BM_GRUPO) == Alltrim(cGrupo)

               If Alltrim(Resultado->B1_COD) == Alltrim(cMaterial)

                  // #######################################
                  // Verifica o cancelamento pelo usuario ##
                  // #######################################
                  If lAbortPrint
                     @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                     Exit
                  Endif

                  // ######################################
                  // Impressao do cabecalho do relatorio ##
                  // ######################################
                  If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                     nPagina := nPagina + 1
                     nLin    := 1
       
                     @ nLin,001 PSAY "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
                     @ nLin,084 PSAY "FATURAMENTO POR GRUPO DE PRODUTOS"
                     @ nLin,180 PSAY dtoc(DATE()) + " - " + TIME()
                     nLin := nLin + 1
                     @ nLin,001 PSAY "AUTOM633.PRW"
                     @ nLin,084 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
                     @ nLin,180 PSAY "PÁGINA:"
                     @ nLin,195 PSAY Strzero(nPagina,6)
                     nLin = nLin + 1
                     @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
                     nLin := nLin + 1
                     @ nLin,001 PSAY "TES CFOP  DATA       NF     SER NR.PV  Nº PC   Nº NF ENT. DESCRIÇÃO DOS CLIENTES         CIDADE                UF      QUANT UND    VLR PRODUTO   VLR SERVICO      VLR FRETE    DEVOLUÇÕES     VLR TOTAL"
                     nLin := nLin + 1
                     @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
                     nLin := nLin + 2

                     Do Case
                        Case Alltrim(Resultado->D2_FILIAL) == "01"
                             @ nLin,059 PSAY "FILIAL.:     " + "01 - PORTO ALEGRE"
                        Case Alltrim(Resultado->D2_FILIAL) == "02"
                             @ nLin,059 PSAY "FILIAL.:     " + "02 - CAXIAS DO SUL"
                        Case Alltrim(Resultado->D2_FILIAL) == "03"
                             @ nLin,059 PSAY "FILIAL.:     " + "03 - PELOTAS"
                     EndCase        

                     nLin = nLin + 1
                     @ nLin,059 PSAY "GRUPO..:   " + Resultado->BM_GRUPO + " - " + Alltrim(Resultado->BM_DESC)
                     nLin = nLin + 1
                     @ nLin,059 PSAY "PRODUTO: " + Substr(Resultado->B1_COD,01,06) + " - " + Alltrim(Resultado->B1_DESC) + " " + Alltrim(Resultado->B1_DAUX)
                     nLin = nLin + 2

                  Endif

                  // ######################
                  // Impressão dos dados ##
                  // ######################
                  @ nLin,001 PSAY Resultado->D2_TES
                  @ nLin,005 PSAY Substr(Resultado->D2_CF,01,01) + "." + Substr(Alltrim(Resultado->D2_CF),02,03)
                  @ nLin,011 PSAY Substr(Resultado->D2_EMISSAO,07,02) + "/" + Substr(Resultado->D2_EMISSAO,05,02) + "/" + Substr(Resultado->D2_EMISSAO,01,04)
                  @ nLin,022 PSAY Substr(Resultado->D2_DOC,01,06)
                  @ nLin,029 PSAY Resultado->D2_SERIE
                  @ nLin,033 PSAY Resultado->D2_PEDIDO
                  @ nLin,040 PSAY Substr(Resultado->P_COMPRA,01,06)
                  @ nLin,048 PSAY kNFEntrada
                  @ nLin,059 PSAY Substr(Resultado->A1_NOME,01,30)
                  @ nLin,090 PSAY Substr(Resultado->A1_MUN,01,20)
                  @ nLin,112 PSAY Resultado->A1_EST
                  @ nLin,115 PSAY Str(Resultado->D2_QUANT,10,02)
                  @ nLin,126 PSAY Resultado->D2_UM

                  If Alltrim(Resultado->B1_TIPO) == "MO"
                     nValPro := 0
                     nValSer := Resultado->D2_TOTAL
                  Else
                     nValPro := Resultado->D2_TOTAL
                     nValSer := 0
                  Endif
               
                  nValFre := Resultado->D2_VALFRE
                  nValTot := nValPro + nValSer + nValFre 
               
                  @ nLin,130 PSAY Str(nValPro,14,02)
                  @ nLin,145 PSAY Str(nValSer,13,02)
                  @ nLin,159 PSAY Str(nValFre,14,02)

                  // ##############################################################
                  // Verifica se existe devolução para a nota fiscal selecionada ##
                  // ##############################################################
                  nDevolucao := 0
                  For nDevolve = 1 to Len(aDevolucao)
                      If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(Resultado->D2_DOC,01,06)) .And. ;
                         Alltrim(aDevolucao[nDevolve,05]) == Alltrim(Resultado->D2_SERIE)             .And. ;
                         Alltrim(aDevolucao[nDevolve,01]) == Alltrim(Resultado->D2_FILIAL)            .And. ;
                         Alltrim(aDevolucao[nDevolve,09]) == Alltrim(Resultado->D2_COD)               .And. ;
                         Alltrim(aDevolucao[nDevolve,06]) == Alltrim(Resultado->D2_ITEM)
                         aDevolucao[nDevolve,07] := .T.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                  Next nDevolve

                  @ nLin,174 PSAY Str(nDevolucao,13,02)                              
                  @ nLin,188 PSAY Str((nValTot - nDevolucao),13,02)                              

                  If Empty(Alltrim(Resultado->C5_FORNEXT))

                     // #################### 
				     // Totaliza Produtos ##
				     // ####################
                     nQuaPInte := nQuaPInte + Resultado->D2_QUANT
                     nProPInte := nProPInte + nValPro
                     nSerPInte := nSerPInte + nValSer
                     nFrePInte := nFrePInte + nValFre
                     nDevPInte := nDevPInte + nDevolucao
                     nTotPInte := nTotPInte + nValTot - nDevolucao

                     // ##################
	                 // Totaliza Grupos ##
	                 // ##################
                     nQuaGInte := nQuaGInte + Resultado->D2_QUANT
                     nProGInte := nProGInte + nValPro
                     nSerGInte := nSerGInte + nValSer
                     nFreGInte := nFreGInte + nValFre
                     nDevGInte := nDevGInte + nDevolucao
                     nTotGInte := nTotGInte + nValTot - nDevolucao

                     // ###################
	                 // Totaliza Filiais ##
	                 // ###################
                     nQuaFInte := nQuaFInte + Resultado->D2_QUANT
                     nProFInte := nProFInte + nValPro
                     nSerFInte := nSerFInte + nValSer
                     nFreFInte := nFreFInte + nValFre
                     nDevFInte := nDevFInte + nDevolucao
                     nTotFInte := nTotFInte + nValTot - nDevolucao

                     // ############################
	                 // Totaliza Acumulador Total ##
	                 // ############################
                     nQuaAInte := nQuaAInte + Resultado->D2_QUANT
                     nProAInte := nProAInte + nValPro
                     nSerAInte := nSerAInte + nValSer
                     nFreAInte := nFreAInte + nValFre
                     nDevAInte := nDevAInte + nDevolucao
                     nTotAInte := nTotAInte + nValTot - nDevolucao

                  Else
 
                     // ####################
                     // Totaliza Produtos ##
                     // ####################
                     nQuaPExte := nQuaPExte + Resultado->D2_QUANT
                     nProPExte := nProPExte + nValPro
                     nSerPExte := nSerPExte + nValSer
                     nFrePExte := nFrePExte + nValFre
                     nDevPExte := nDevPExte + nDevolucao
                     nTotPExte := nTotPExte + nValTot - nDevolucao

                     // ################## 
                     // Totaliza Grupos ##
                     // ##################
                     nQuaGExte := nQuaGExte + Resultado->D2_QUANT
                     nProGExte := nProGExte + nValPro
                     nSerGExte := nSerGExte + nValSer
                     nFreGExte := nFreGExte + nValFre
                     nDevGExte := nDevGExte + nDevolucao
                     nTotGExte := nTotGExte + nValTot - nDevolucao

                     // ###################
                     // Totaliza Filiais ##
                     // ###################
                     nQuaFExte := nQuaFExte + Resultado->D2_QUANT
                     nProFExte := nProFExte + nValPro
                     nSerFExte := nSerFExte + nValSer
                     nFreFExte := nFreFExte + nValFre
                     nDevFExte := nDevFExte + nDevolucao
                     nTotFExte := nTotFExte + nValTot - nDevolucao

                     // ############################
	                 // Totaliza Acumulador Total ##
                     // ############################    
                     nQuaAExte := nQuaAExte + Resultado->D2_QUANT
                     nProAExte := nProAExte + nValPro
                     nSerAExte := nSerAExte + nValSer
                     nFreAExte := nFreAExte + nValFre
                     nDevAExte := nDevAExte + nDevolucao
                     nTotAExte := nTotAExte + nValTot - nDevolucao

                  Endif

                  nLin = nLin + 1

                  Resultado->( DbSkip() )

                  Loop
            
               Else
   
                  // #####################
                  // Totaliza o Produto ##
                  // #####################
                  nLin := nLin + 1
                  @ nLin,090 PSAY "Total Produtos Internos:"
                  @ nLin,115 PSAY Str(nQuaPInte,10,02)
                  @ nLin,130 PSAY Str(nProPInte,14,02)
                  @ nLin,145 PSAY Str(nSerPInte,13,02)
                  @ nLin,159 PSAY Str(nFrePInte,14,02)
                  @ nLin,174 PSAY Str(nDevPInte,13,02)
                  nLin := nLin + 1

                  // #####################################
                  // Pesquisa Outras Devoluções na Data ##
                  // #####################################
                  nDevolucao := 0
                  For nDevolve = 1 to Len(aDevolucao)
                      If aDevolucao[nDevolve,09] == cMaterial
                         If aDevolucao[nDevolve,07] == .F.
                            nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                         Endif
                      Endif
                  Next nDevolve

                  @ nLin,090 PSAY "Total Outras Devoluções:"
                  @ nLin,174 PSAY Str((nDevolucao),13,02)
                  @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
                  nLin = nLin + 1

                  @ nLin,090 PSAY "Total Produtos Externos:"
                  @ nLin,115 PSAY Str(nQuaPExte,10,02)
                  @ nLin,130 PSAY Str(nProPExte,14,02)
                  @ nLin,145 PSAY Str(nSerPExte,13,02)
                  @ nLin,159 PSAY Str(nFrePExte,14,02)
                  @ nLin,174 PSAY Str(nDevPExte,13,02)
                  @ nLin,188 PSAY Str(nTotPExte,13,02)                              
                  nLin := nLin + 1

                  @ nLin,090 PSAY "Total dos Produtos.....:"
                  @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
                  @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
                  @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
                  @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
                  @ nLin,174 PSAY Str(nDevPInte + nDevPExte,13,02)
                  @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
                  nLin := nLin + 2

                  cMaterial := Resultado->B1_COD                  

                  // #####################################
                  // Zera os totalizadores dos produtos ##
                  // #####################################
                  nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
                  nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

                  @ nLin,059 PSAY "PRODUTO: " + Substr(Resultado->B1_COD,01,06) + " - " + Alltrim(Resultado->B1_DESC) + " " + Alltrim(Resultado->B1_DAUX)
                  nLin = nLin + 2

               Endif
         
            Else            
            
               // #####################
               // Totaliza o Produto ##
               // #####################
               nLin := nLin + 1
               @ nLin,090 PSAY "Total Produtos Internos:"
               @ nLin,115 PSAY Str(nQuaPInte,10,02)
               @ nLin,130 PSAY Str(nProPInte,14,02)
               @ nLin,145 PSAY Str(nSerPInte,13,02)
               @ nLin,159 PSAY Str(nFrePInte,14,02)
               @ nLin,174 PSAY Str(nDevPInte,13,02)
               nLin := nLin + 1

               // #####################################
               // Pesquisa Outras Devoluções na Data ##
               // #####################################
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,09] == cMaterial
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                   Endif
               Next nDevolve

               @ nLin,090 PSAY "Total Outras Devoluções:"
               @ nLin,174 PSAY Str((nDevolucao),13,02)
               @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
               nLin = nLin + 1

               @ nLin,090 PSAY "Total Produtos Externos:"
               @ nLin,115 PSAY Str(nQuaPExte,10,02)
               @ nLin,130 PSAY Str(nProPExte,14,02)
               @ nLin,145 PSAY Str(nSerPExte,13,02)
               @ nLin,159 PSAY Str(nFrePExte,14,02)
               @ nLin,174 PSAY Str(nDevPExte,13,02)
               @ nLin,188 PSAY Str(nTotPExte,13,02)                              
               nLin := nLin + 1

               @ nLin,090 PSAY "Total dos Produtos.....:"
               @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
               @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
               @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
               @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
               @ nLin,174 PSAY Str(nDevPInte + nDevPExte,13,02)
               @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
               nLin := nLin + 2

               // ###################
               // Totaliza o Grupo ##
               // ###################
               @ nLin,090 PSAY "Total Grupos Internos..:"
               @ nLin,115 PSAY Str(nQuaGInte,10,02)
               @ nLin,130 PSAY Str(nProGInte,14,02)
               @ nLin,145 PSAY Str(nSerGInte,13,02)
               @ nLin,159 PSAY Str(nFreGInte,14,02)
               @ nLin,174 PSAY Str(nDevGInte,13,02)
               nLin := nLin + 1

               // #####################################
               // Pesquisa Outras Devoluções na Data ##
               // #####################################
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,10] == cGrupo
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                   Endif
               Next nDevolve

               @ nLin,090 PSAY "Total Outras Devoluções:"
               @ nLin,174 PSAY Str((nDevolucao),13,02)
               @ nLin,188 PSAY Str((nTotGInte - nDevolucao),13,02)
               nLin = nLin + 1

               @ nLin,090 PSAY "Total Grupos Externos..:"
               @ nLin,115 PSAY Str(nQuaGExte,10,02)
               @ nLin,130 PSAY Str(nProGExte,14,02)
               @ nLin,145 PSAY Str(nSerGExte,13,02)
               @ nLin,159 PSAY Str(nFreGExte,14,02)
               @ nLin,174 PSAY Str(nDevGExte,13,02)
               @ nLin,188 PSAY Str(nTotGExte,13,02)                              
               nLin := nLin + 1

               @ nLin,090 PSAY "Total do Grupo.........:"
               @ nLin,115 PSAY Str(nQuaGInte + nQuaGExte,10,02)
               @ nLin,130 PSAY Str(nProGInte + nProGExte,14,02)
               @ nLin,145 PSAY Str(nSerGInte + nSerGExte,13,02)
               @ nLin,159 PSAY Str(nFreGInte + nFreGExte,14,02)
               @ nLin,174 PSAY Str(nDevGInte + nDevGExte,13,02)
               @ nLin,188 PSAY Str(nTotGInte + nTotGExte - nDevolucao,13,02)                              
               nLin := nLin + 2

               cGrupo    := Resultado->BM_GRUPO
               cMaterial := Resultado->B1_COD                  

               // #####################################
               // Zera os totalizadores dos produtos ##
               // #####################################
               nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
               nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

               // ###########################
               // Totalizadores dos grupos ##
               // ###########################
               nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
               nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

               nLin = nLin + 1
               @ nLin,059 PSAY "GRUPO..:   " + Resultado->BM_GRUPO + " - " + Alltrim(Resultado->BM_DESC)      
               nLin = nLin + 2

            Endif
            
         Else   

            // #####################
            // Totaliza o Produto ##
            // #####################
            nLin := nLin + 1
            @ nLin,090 PSAY "Total Produtos Internos:"
            @ nLin,115 PSAY Str(nQuaPInte,10,02)
            @ nLin,130 PSAY Str(nProPInte,14,02)
            @ nLin,145 PSAY Str(nSerPInte,13,02)
            @ nLin,159 PSAY Str(nFrePInte,14,02)
            @ nLin,174 PSAY Str(nDevPInte,13,02)
            nLin := nLin + 1

            // #####################################
            // Pesquisa Outras Devoluções na Data ##
            // #####################################
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,09] == cMaterial
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,090 PSAY "Total Outras Devoluções:"
            @ nLin,174 PSAY Str((nDevolucao),13,02)
            @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
            nLin = nLin + 1

            @ nLin,090 PSAY "Total Produtos Externos:"
            @ nLin,115 PSAY Str(nQuaPExte,10,02)
            @ nLin,130 PSAY Str(nProPExte,14,02)
            @ nLin,145 PSAY Str(nSerPExte,13,02)
            @ nLin,159 PSAY Str(nFrePExte,14,02)
            @ nLin,174 PSAY Str(nDevPExte,13,02)
            @ nLin,188 PSAY Str(nTotPExte,13,02)                              
            nLin := nLin + 1

            @ nLin,090 PSAY "Total dos Produtos.....:"
            @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
            @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
            @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
            @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
            @ nLin,174 PSAY Str(nDevPInte + nDevPExte,13,02)
            @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
            nLin := nLin + 2

            // ###################
            // Totaliza o Grupo ##
            // ###################
            @ nLin,090 PSAY "Total Grupos Internos..:"
            @ nLin,115 PSAY Str(nQuaGInte,10,02)
            @ nLin,130 PSAY Str(nProGInte,14,02)
            @ nLin,145 PSAY Str(nSerGInte,13,02)
            @ nLin,159 PSAY Str(nFreGInte,14,02)
            @ nLin,174 PSAY Str(nDevGInte,13,02)
            nLin := nLin + 1

            // #####################################
            // Pesquisa Outras Devoluções na Data ##
            // #####################################
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,10] == cGrupo
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,090 PSAY "Total Outras Devoluções:"
            @ nLin,174 PSAY Str((nDevolucao),13,02)
            @ nLin,188 PSAY Str((nTotGInte - nDevolucao),13,02)
            nLin = nLin + 1

            @ nLin,090 PSAY "Total Grupos Externos..:"
            @ nLin,115 PSAY Str(nQuaGExte,10,02)
            @ nLin,130 PSAY Str(nProGExte,14,02)
            @ nLin,145 PSAY Str(nSerGExte,13,02)
            @ nLin,159 PSAY Str(nFreGExte,14,02)
            @ nLin,174 PSAY Str(nDevGExte,13,02)
            @ nLin,188 PSAY Str(nTotGExte,13,02)                              
            nLin := nLin + 1

            @ nLin,090 PSAY "Total do Grupo.........:"
            @ nLin,115 PSAY Str(nQuaGInte + nQuaGExte,10,02)
            @ nLin,130 PSAY Str(nProGInte + nProGExte,14,02)
            @ nLin,145 PSAY Str(nSerGInte + nSerGExte,13,02)
            @ nLin,159 PSAY Str(nFreGInte + nFreGExte,14,02)
            @ nLin,174 PSAY Str(nDevGInte + nDevGExte,13,02)
            @ nLin,188 PSAY Str(nTotGInte + nTotGExte,13,02)                              
            nLin := nLin + 2

            // ####################
            // Totaliza a Filial ##
            // ####################
            @ nLin,090 PSAY "Total Filial Internos..:"
            @ nLin,115 PSAY Str(nQuaFInte,10,02)
            @ nLin,130 PSAY Str(nProFInte,14,02)
            @ nLin,145 PSAY Str(nSerFInte,13,02)
            @ nLin,159 PSAY Str(nFreFInte,14,02)
            @ nLin,174 PSAY Str(nDevFInte,13,02)
            nLin := nLin + 1

            // #####################################
            // Pesquisa Outras Devoluções na Data ##
            // #####################################
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,01] == cEmpFil
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,090 PSAY "Total Outras Devoluções:"
            @ nLin,174 PSAY Str((nDevolucao),13,02)
            @ nLin,188 PSAY Str((nTotFInte - nDevolucao),13,02)
            nLin = nLin + 1

            @ nLin,090 PSAY "Total Filial Externos..:"
            @ nLin,115 PSAY Str(nQuaFExte,10,02)
            @ nLin,130 PSAY Str(nProFExte,14,02)
            @ nLin,145 PSAY Str(nSerFExte,13,02)
            @ nLin,159 PSAY Str(nFreFExte,14,02)
            @ nLin,174 PSAY Str(nDevFExte,13,02)
            @ nLin,188 PSAY Str(nTotFExte,13,02)                              
            nLin := nLin + 1

            @ nLin,090 PSAY "Total da Filial........:"
            @ nLin,115 PSAY Str(nQuaFInte + nQuaFExte,10,02)
            @ nLin,130 PSAY Str(nProFInte + nProFExte,14,02)
            @ nLin,145 PSAY Str(nSerFInte + nSerFExte,13,02)
            @ nLin,159 PSAY Str(nFreFInte + nFreFExte,14,02)
            @ nLin,174 PSAY Str(nDevFInte + nDevFExte,13,02)
            @ nLin,188 PSAY Str(nTotFInte + nTotFExte - nDevolucao,13,02)                              
            nLin := nLin + 2

            @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

            nLin := nLin + 2

            cEmpFil   := Resultado->D2_FILIAL
            cGrupo    := Resultado->BM_GRUPO
            cMaterial := Resultado->B1_COD                  

            // ############################# 
            // Totalizadores dos produtos ##
            // #############################
            nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
            nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

            // ###########################
            // Totalizadores dos grupos ##
            // ###########################
            nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
            nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

            // ############################
            // Totalizadores das filiais ##
            // ############################
            nQuaFInte := 0; nProFInte := 0; nSerFInte := 0; nFreFInte := 0; nTotFInte := 0; nDevFInte := 0
            nQuaFExte := 0; nProFExte := 0; nSerFExte := 0; nFreFExte := 0; nTotFExte := 0; nDevFExte := 0

            Do Case
               Case Alltrim(Resultado->D2_FILIAL) == "01"
                    @ nLin,059 PSAY "FILIAL.:     " + "01 - PORTO ALEGRE"
               Case Alltrim(Resultado->D2_FILIAL) == "02"
                    @ nLin,059 PSAY "FILIAL.:     " + "02 - CAXIAS DO SUL"
               Case Alltrim(Resultado->D2_FILIAL) == "03"
                    @ nLin,059 PSAY "FILIAL.:     " + "03 - PELOTAS"
            EndCase        

            nLin = nLin + 1
            @ nLin,059 PSAY "GRUPO..:   " + Resultado->BM_GRUPO + " - " + Alltrim(Resultado->BM_DESC)
            nLin = nLin + 1
            @ nLin,059 PSAY "PRODUTO: " + Substr(Resultado->B1_COD,01,06) + " - " + Alltrim(Resultado->B1_DESC) + " " + Alltrim(Resultado->B1_DAUX)
            nLin = nLin + 2

         Endif

      Enddo

      // #####################
      // Totaliza o Produto ##
      // #####################
      nLin := nLin + 1
      @ nLin,090 PSAY "Total Produtos Internos:"
      @ nLin,115 PSAY Str(nQuaPInte,10,02)
      @ nLin,130 PSAY Str(nProPInte,14,02)
      @ nLin,145 PSAY Str(nSerPInte,13,02)
      @ nLin,159 PSAY Str(nFrePInte,14,02)
      @ nLin,174 PSAY Str(nDevPInte,13,02)
      nLin := nLin + 1

      // #####################################
      // Pesquisa Outras Devoluções na Data ##
      // #####################################
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cMaterial
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,090 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,090 PSAY "Total Produtos Externos:"
      @ nLin,115 PSAY Str(nQuaPExte,10,02)
      @ nLin,130 PSAY Str(nProPExte,14,02)
      @ nLin,145 PSAY Str(nSerPExte,13,02)
      @ nLin,159 PSAY Str(nFrePExte,14,02)
      @ nLin,174 PSAY Str(nDevPExte,13,02)
      @ nLin,188 PSAY Str(nTotPExte,13,02)                              
      nLin := nLin + 1

      @ nLin,090 PSAY "Total dos Produtos.....:"
      @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
      @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
      @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
      @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
      @ nLin,174 PSAY Str(nDevPInte + nFrePExte,13,02)
      @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
      nLin := nLin + 2

      // ###################
      // Totaliza o Grupo ##
      // ###################
      @ nLin,090 PSAY "Total Grupos Internos..:"
      @ nLin,115 PSAY Str(nQuaGInte,10,02)
      @ nLin,130 PSAY Str(nProGInte,14,02)
      @ nLin,145 PSAY Str(nSerGInte,13,02)
      @ nLin,159 PSAY Str(nFreGInte,14,02)
      @ nLin,174 PSAY Str(nDevGInte,13,02)
      nLin := nLin + 1

      // #####################################
      // Pesquisa Outras Devoluções na Data ##
      // #####################################
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cGrupo
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,090 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,090 PSAY "Total Grupos Externos..:"
      @ nLin,115 PSAY Str(nQuaGExte,10,02)
      @ nLin,130 PSAY Str(nProGExte,14,02)
      @ nLin,145 PSAY Str(nSerGExte,13,02)
      @ nLin,159 PSAY Str(nFreGExte,14,02)
      @ nLin,174 PSAY Str(nDevGExte,13,02)
      @ nLin,188 PSAY Str(nTotGExte,13,02)                              
      nLin := nLin + 1

      @ nLin,090 PSAY "Total do Grupo.........:"
      @ nLin,115 PSAY Str(nQuaGInte + nQuaGExte,10,02)
      @ nLin,130 PSAY Str(nProGInte + nProGExte,14,02)
      @ nLin,145 PSAY Str(nSerGInte + nSerGExte,13,02)
      @ nLin,159 PSAY Str(nFreGInte + nFreGExte,14,02)
      @ nLin,174 PSAY Str(nDevGInte + nDevGExte,13,02)
      @ nLin,188 PSAY Str(nTotGInte + nTotGExte - nDevolucao,13,02)                              
      nLin := nLin + 2

      // ####################
      // Totaliza a Filial ##
      // ####################
      @ nLin,090 PSAY "Total Filial Internos..:"
      @ nLin,115 PSAY Str(nQuaFInte,10,02)
      @ nLin,130 PSAY Str(nProFInte,14,02)
      @ nLin,145 PSAY Str(nSerFInte,13,02)
      @ nLin,159 PSAY Str(nFreFInte,14,02)
      @ nLin,174 PSAY Str(nDevFInte,13,02)
      nLin := nLin + 1

      // #####################################
      // Pesquisa Outras Devoluções na Data ##
      // #####################################
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cEmpFil
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,090 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotFInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,090 PSAY "Total Filial Externos..:"
      @ nLin,115 PSAY Str(nQuaFExte,10,02)
      @ nLin,130 PSAY Str(nProFExte,14,02)
      @ nLin,145 PSAY Str(nSerFExte,13,02)
      @ nLin,159 PSAY Str(nFreFExte,14,02)
      @ nLin,174 PSAY Str(nDevFExte,13,02)
      @ nLin,188 PSAY Str(nTotFExte,13,02)                              
      nLin := nLin + 1

      @ nLin,090 PSAY "Total da Filial........:"
      @ nLin,115 PSAY Str(nQuaFInte + nQuaFExte,10,02)
      @ nLin,130 PSAY Str(nProFInte + nProFExte,14,02)
      @ nLin,145 PSAY Str(nSerFInte + nSerFExte,13,02)
      @ nLin,159 PSAY Str(nFreFInte + nFreFExte,14,02)
      @ nLin,174 PSAY Str(nDevFInte + nDevFExte + nDevolucao,13,02)
      @ nLin,188 PSAY Str(nTotFInte + nTotFExte - nDevolucao,13,02)                              
      nLin := nLin + 2

      @ nLin,090 PSAY "--------------------------------------------------------------------------------------------------------------"

      nLin := nLin + 2

      // #######################
      // Totaliza o Acumulado ##
      // #######################
      @ nLin,090 PSAY "Total Pedidos Internos.:"
      @ nLin,115 PSAY Str(nQuaAInte,10,02)
      @ nLin,130 PSAY Str(nProAInte,14,02)
      @ nLin,145 PSAY Str(nSerAInte,13,02)
      @ nLin,159 PSAY Str(nFreAInte,14,02)
      @ nLin,174 PSAY Str(nDevAInte,13,02)
      nLin := nLin + 1

      // #####################################
      // Pesquisa Outras Devoluções na Data ##
      // #####################################
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      @ nLin,090 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotAInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,090 PSAY "Total Pedidos Externos.:"
      @ nLin,115 PSAY Str(nQuaAExte,10,02)
      @ nLin,130 PSAY Str(nProAExte,14,02)
      @ nLin,145 PSAY Str(nSerAExte,13,02)
      @ nLin,159 PSAY Str(nFreAExte,14,02)
      @ nLin,174 PSAY Str(nDevAExte,13,02)
      @ nLin,188 PSAY Str(nTotAExte,13,02)                              
      nLin := nLin + 1

      @ nLin,090 PSAY "Total do Período.......:"
      @ nLin,115 PSAY Str(nQuaAInte + nQuaAExte,10,02)
      @ nLin,130 PSAY Str(nProAInte + nProAExte,14,02)
      @ nLin,145 PSAY Str(nSerAInte + nSerAExte,13,02)
      @ nLin,159 PSAY Str(nFreAInte + nFreAExte,14,02)
      @ nLin,174 PSAY Str(nDevAInte + nDevAExte + nDevolucao,13,02)
      @ nLin,188 PSAY Str(nTotAInte + nTotAExte - nDevolucao,13,02)                              
      nLin := nLin + 2

   Else

      // SINTÉTICO
      cEmpFil   := Resultado->D2_FILIAL
      cGrupo    := Resultado->BM_GRUPO
      nGrupo    := Resultado->BM_DESC

      // Totalizador dos Grupos
      nQuaInte := 0; nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
      nQuaExte := 0; nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

      // Totalizador das Filiais
      nQuaAInte := 0; nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
      nQuaAExte := 0; nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

      // Totalizador Geral
      nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
      nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

      nPagina  := 0

      While !Resultado->( EOF() )

         If Alltrim(Resultado->D2_FILIAL) == Alltrim(cEmpFil)

            If Alltrim(Resultado->BM_GRUPO) == Alltrim(cGrupo)

               // Verifica o cancelamento pelo usuario...
               If lAbortPrint
                  @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                  Exit
               Endif

               // Impressao do cabecalho do relatorio
               If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                  nPagina := nPagina + 1
                  nLin    := 1

                  @ nLin,001 PSAY "AUTOMATECH"
                  @ nLin,022 PSAY "FATURAMENTO POR GRUPO/PRODUTO"
                  @ nLin,060 PSAY dtoc(DATE()) + " - " + TIME()
                  nLin := nLin + 1
                  @ nLin,001 PSAY "AUTOMR09.PRW"
                  @ nLin,022 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
                  @ nLin,060 PSAY "PÁGINA:"
                  @ nLin,075 PSAY Strzero(nPagina,6)
                  nLin = nLin + 1
                  @ nLin,001 PSAY "--------------------------------------------------------------------------------"
                  nLin := nLin + 1
                  @ nLin,001 PSAY "DESCRIÇÃO GRUPOS  T   QTD   VLR PROD   VLR SERV  VLR FRETE DEVOLUÇÕES  VLR TOTAL"
                  nLin := nLin + 1
                  @ nLin,001 PSAY "--------------------------------------------------------------------------------"
                  nLin := nLin + 2

                  Do Case
                     Case Alltrim(cEmpFil) == "01"
                          @ nLin,023 PSAY "FILIAL: " + "01 - PORTO ALEGRE"
                     Case Alltrim(cEmpFil) == "02"
                          @ nLin,023 PSAY "FILIAL: " + "02 - CAXIAS DO SUL"
                     Case Alltrim(cEmpFil) == "03"
                          @ nLin,023 PSAY "FILIAL: " + "03 - PELOTAS"
                  EndCase        

                  nLin := nLin + 2

               Endif

               // Acumula os Valores da Data para Impressão
               If Empty(Alltrim(Resultado->C5_FORNEXT))

                  // Verifica se existe devolução para a nota fiscal selecionada
                  nDevolucao := 0
                  For nDevolve = 1 to Len(aDevolucao)
                      If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(Resultado->D2_DOC,01,06)) .And. ;
                         Alltrim(aDevolucao[nDevolve,05]) == Alltrim(Resultado->D2_SERIE)             .And. ;
                         Alltrim(aDevolucao[nDevolve,01]) == Alltrim(Resultado->D2_FILIAL)            .And. ;
                         Alltrim(aDevolucao[nDevolve,09]) == Alltrim(Resultado->D2_COD)               .And. ;
                         Alltrim(aDevolucao[nDevolve,06]) == Alltrim(Resultado->D2_ITEM)
                         aDevolucao[nDevolve,07] := .T.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                  Next nDevolve

                  nDevInte  := nDevInte + nDevolucao

                  // Totalizador do Grupo
                  nQuaInte  := nQuaInte  + Resultado->D2_QUANT

                  If Alltrim(Resultado->B1_TIPO) == "MO"
                     nSerInte := nSerInte  + Resultado->D2_TOTAL
                  Else
                     nProInte := nProInte  + Resultado->D2_TOTAL
                  Endif

                  nFreInte  := nFreInte + Resultado->D2_VALFRE

                  nTotInte  := nProInte + nSerInte + nFreInte - nDevInte

                  // Totalizador da Filial
                  nQuaAInte  := nQuaAInte  + Resultado->D2_QUANT

                  If Alltrim(Resultado->B1_TIPO) == "MO"
                     nSerAInte := nSerAInte  + Resultado->D2_TOTAL
                  Else
                     nProAInte := nProAInte  + Resultado->D2_TOTAL
                  Endif

                  nFreAInte  := nFreAInte + Resultado->D2_VALFRE
                  nDevAInte  := nDevAInte + nDevolucao
                  nTotAInte  := nProAInte + nSerAInte + nFreAInte

                  // Totalizador do Período
                  nQuaGInte  := nQuaGInte  + Resultado->D2_QUANT

                  If Alltrim(Resultado->B1_TIPO) == "MO"
                     nSerGInte := nSerGInte  + Resultado->D2_TOTAL
                  Else
                     nProGInte := nProGInte  + Resultado->D2_TOTAL
                  Endif

                  nFreGInte  := nFreGInte + Resultado->D2_VALFRE
                  nDevGInte  := nDevGInte + nDevolucao
                  nTotGInte  := nProGInte + nSerGInte + nFreGInte - nDevGInte - nDevolucao

               Else   

                  // Verifica se existe devolução para a nota fiscal selecionada
                  nDevolucao := 0
                  For nDevolve = 1 to Len(aDevolucao)
                      If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(Resultado->D2_DOC,01,06)) .And. ;
                         Alltrim(aDevolucao[nDevolve,05]) == Alltrim(Resultado->D2_SERIE)             .And. ;
                         Alltrim(aDevolucao[nDevolve,01]) == Alltrim(Resultado->D2_FILIAL)            .And. ;
                         Alltrim(aDevolucao[nDevolve,09]) == Alltrim(Resultado->D2_COD)               .And. ;
                         Alltrim(aDevolucao[nDevolve,06]) == Alltrim(Resultado->D2_ITEM)
                         aDevolucao[nDevolve,07] := .T.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                  Next nDevolve

                  nDevExte  := nDevExte + nDevolucao

                  // Totalizador do Grupo
                  nQuaExte := nQuaExte  + Resultado->D2_QUANT

                  If Alltrim(Resultado->B1_TIPO) == "MO"
                     nSerExte := nSerExte  + Resultado->D2_TOTAL
                  Else
                     nProExte := nProExte  + Resultado->D2_TOTAL
                  Endif

                  nFreExte  := nFreExte + Resultado->D2_VALFRE

                  nTotExte  := nProExte + nSerExte + nFreExte - nDevExte

                  // Totalizador da Filial
                  nQuaAExte := nQuaAExte  + Resultado->D2_QUANT

                  If Alltrim(Resultado->B1_TIPO) == "MO"
                     nSerAExte := nSerAExte  + Resultado->D2_TOTAL
                  Else
                     nProAExte := nProAExte  + Resultado->D2_TOTAL
                  Endif

                  nFreAExte  := nFreAExte + Resultado->D2_VALFRE
                  nDevAExte  := nDevAExte + nDevolucao
                  nTotAExte  := nProAExte + nSerAExte + nFreAExte

                  // Totalizador do Período
                  nQuaGExte := nQuaGExte  + Resultado->D2_QUANT

                  If Alltrim(Resultado->B1_TIPO) == "MO"
                     nSerGExte := nSerGExte  + Resultado->D2_TOTAL
                  Else
                     nProGExte := nProGExte  + Resultado->D2_TOTAL
                  Endif

                  nFreGExte  := nFreGExte + Resultado->D2_VALFRE

                  nDevGExte  := nDevGExte + nDevolucao

                  nTotGExte  := nProGExte + nSerGExte + nFreGExte - nDevGExte - nDevolucao

               Endif

               Resultado->( DbSkip() )
            
               Loop
            
            Else

               @ nLin,001 PSAY Substr(nGrupo,01,17) 
               @ nLin,019 PSAY "I"
               @ nLin,021 PSAY Str(nQuaInte,05)
               @ nLin,027 PSAY Str(nProInte,10,02)
               @ nLin,038 PSAY Str(nSerInte,10,02)
               @ nLin,049 PSAY Str(nFreInte,10,02)                                             
               @ nLin,060 PSAY Str(nDevInte,10,02)                                             
               @ nLin,071 PSAY Str(nTotInte,10,02)                                             

               nLin := nLin + 1

               @ nLin,019 PSAY "E"
               @ nLin,021 PSAY Str(nQuaExte,05)
               @ nLin,027 PSAY Str(nProExte,10,02)
               @ nLin,038 PSAY Str(nSerExte,10,02)
               @ nLin,049 PSAY Str(nFreExte,10,02)                                             
               @ nLin,060 PSAY Str(nDevExte,10,02)                                             
               @ nLin,071 PSAY Str(nTotExte,10,02)                                             
               
               nLin := nLin + 1

               @ nLin,019 PSAY "T"
               @ nLin,021 PSAY Str(nQuaInte + nQuaExte,05)
               @ nLin,027 PSAY Str(nProInte + nProExte,10,02)
               @ nLin,038 PSAY Str(nSerInte + nSerExte,10,02)
               @ nLin,049 PSAY Str(nFreInte + nFreExte,10,02)                                             
               @ nLin,060 PSAY Str(nDevInte + nDevExte,10,02)                                             
               @ nLin,071 PSAY Str(nTotInte + nTotExte,10,02)                                             

               nLin := nLin + 2

               nQuaInte := 0; nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
               nQuaExte := 0; nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

               cGrupo := Resultado->BM_GRUPO
               nGrupo := Resultado->BM_DESC

               Loop

            Endif
         
         Else            
      
            // Totaliza a última data
            @ nLin,001 PSAY Substr(nGrupo,01,17) 
            @ nLin,019 PSAY "I"
            @ nLin,021 PSAY Str(nQuaInte,05)
            @ nLin,027 PSAY Str(nProInte,10,02)
            @ nLin,038 PSAY Str(nSerInte,10,02)
            @ nLin,049 PSAY Str(nFreInte,10,02)                                             
            @ nLin,060 PSAY Str(nDevInte,10,02)                                             
            @ nLin,071 PSAY Str(nTotInte,10,02)                                             

            nLin := nLin + 1

            @ nLin,019 PSAY "E"
            @ nLin,021 PSAY Str(nQuaExte,05)
            @ nLin,027 PSAY Str(nProExte,10,02)
            @ nLin,038 PSAY Str(nSerExte,10,02)
            @ nLin,049 PSAY Str(nFreExte,10,02)                                             
            @ nLin,060 PSAY Str(nDevExte,10,02)                                             
            @ nLin,071 PSAY Str(nTotExte,10,02)                                             
               
            nLin := nLin + 1

            @ nLin,019 PSAY "T"
            @ nLin,021 PSAY Str(nQuaInte + nQuaExte,05)
            @ nLin,027 PSAY Str(nProInte + nProExte,10,02)
            @ nLin,038 PSAY Str(nSerInte + nSerExte,10,02)
            @ nLin,049 PSAY Str(nFreInte + nFreExte,10,02)                                             
            @ nLin,060 PSAY Str(nDevInte + nDevExte,10,02)                                             
            @ nLin,071 PSAY Str(nTotInte + nTotExte,10,02)                                             

            // Totaliza a Filial
            nLin := nLin + 2
            @ nLin,001 PSAY "TOTAL DA FILIAL"
            @ nLin,019 PSAY "I"
            @ nLin,021 PSAY Str(nQuaAInte,05)
            @ nLin,027 PSAY Str(nProAInte,10,02)
            @ nLin,038 PSAY Str(nSerAInte,10,02)
            @ nLin,049 PSAY Str(nFreAInte,10,02)                                             
            @ nLin,060 PSAY Str(nDevAInte,10,02)                                             
//          @ nLin,071 PSAY Str(nTotAInte,10,02)                                             
            nLin := nLin + 1

            // Verifica se existe devolução para a nota fiscal selecionada
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,07] == .F.
                   nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                Endif
            Next nDevolve

            @ nLin,019 PSAY "O"
            @ nLin,060 PSAY Str(nDevolucao,10,02)                                             
            @ nLin,071 PSAY Str(nTotAInte - nDevolucao,10,02)                                             
            nLin := nLin + 1

            @ nLin,019 PSAY "E"
            @ nLin,021 PSAY Str(nQuaAExte,05)
            @ nLin,027 PSAY Str(nProAExte,10,02)
            @ nLin,038 PSAY Str(nSerAExte,10,02)
            @ nLin,049 PSAY Str(nFreAExte,10,02)                                             
            @ nLin,060 PSAY Str(nDevAExte,10,02)                                             
            @ nLin,071 PSAY Str(nTotAExte,10,02)                                             
               
            nLin := nLin + 1

            @ nLin,019 PSAY "T"
            @ nLin,021 PSAY Str(nQuaAInte + nQuaAExte,05)
            @ nLin,027 PSAY Str(nProAInte + nProAExte,10,02)
            @ nLin,038 PSAY Str(nSerAInte + nSerAExte,10,02)
            @ nLin,049 PSAY Str(nFreAInte + nFreAExte,10,02)                                             
            @ nLin,060 PSAY Str(nDevAInte + nDevAExte,10,02)                                             
            @ nLin,071 PSAY Str(nTotAInte + nTotAExte,10,02)                                             

            nLin := nLin + 2

            @ nLin,001 PSAY "--------------------------------------------------------------------------------"

            nLin := nLin + 2

            cEmpFil  := Resultado->D2_FILIAL
            cGrupo   := Resultado->BM_GRUPO
            nGrupo   := Resultado->BM_DESC

            // Zera os totalizadores do Grupo
            nQuaInte := 0; nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
            nQuaExte := 0; nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

            // Zera os totalizadores da Filial
            nQuaAInte := 0; nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
            nQuaAExte := 0; nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

            Do Case
               Case Alltrim(cEmpFil) == "01"
                    @ nLin,023 PSAY "FILIAL: " + "01 - PORTO ALEGRE"
               Case Alltrim(cEmpFil) == "02"
                    @ nLin,023 PSAY "FILIAL: " + "02 - CAXIAS DO SUL"
               Case Alltrim(cEmpFil) == "03"
                    @ nLin,023 PSAY "FILIAL: " + "03 - PELOTAS"
            EndCase        

            nLin = nLin + 2

         Endif

      Enddo

      // Totaliza a última data
      @ nLin,001 PSAY Substr(cGrupo,01,17) 
      @ nLin,019 PSAY "I"
      @ nLin,021 PSAY Str(nQuaInte,05)
      @ nLin,027 PSAY Str(nProInte,10,02)
      @ nLin,038 PSAY Str(nSerInte,10,02)
      @ nLin,049 PSAY Str(nFreInte,10,02)                                             
      @ nLin,060 PSAY Str(nDevInte,10,02)                                             
//    @ nLin,071 PSAY Str(nTotInte,10,02)                                             
      nLin := nLin + 1

      // Verifica se existe devolução para a nota fiscal selecionada
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      @ nLin,019 PSAY "O"
      @ nLin,060 PSAY Str(nDevolucao,10,02)                                             
      @ nLin,071 PSAY Str(nTotInte - nDevolucao,10,02)                                             
      nLin := nLin + 1

      @ nLin,019 PSAY "E"
      @ nLin,021 PSAY Str(nQuaExte,05)
      @ nLin,027 PSAY Str(nProExte,10,02)
      @ nLin,038 PSAY Str(nSerExte,10,02)
      @ nLin,049 PSAY Str(nFreExte,10,02)                                             
      @ nLin,060 PSAY Str(nDevExte,10,02)                                             
      @ nLin,071 PSAY Str(nTotExte,10,02)                                             
               
      nLin := nLin + 1

      @ nLin,019 PSAY "T"
      @ nLin,021 PSAY Str(nQuaInte + nQuaExte,05)
      @ nLin,027 PSAY Str(nProInte + nProExte,10,02)
      @ nLin,038 PSAY Str(nSerInte + nSerExte,10,02)
      @ nLin,049 PSAY Str(nFreInte + nFreExte,10,02)                                             
      @ nLin,060 PSAY Str(nDevInte + nDevExte,10,02)                                             
      @ nLin,071 PSAY Str(nTotInte + nTotExte,10,02)                                             

      // Totaliza a Filial
      nLin := nLin + 2
      @ nLin,001 PSAY "TOTAL DA FILIAL"
      @ nLin,019 PSAY "I"
      @ nLin,021 PSAY Str(nQuaAInte,05)
      @ nLin,027 PSAY Str(nProAInte,10,02)
      @ nLin,038 PSAY Str(nSerAInte,10,02)
      @ nLin,049 PSAY Str(nFreAInte,10,02)                                             
      @ nLin,060 PSAY Str(nDevAInte,10,02)                                             
      nLin := nLin + 1

      // Verifica se existe devolução para a nota fiscal selecionada
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      @ nLin,019 PSAY "O"
      @ nLin,060 PSAY Str(nDevolucao,10,02)                                             
      @ nLin,071 PSAY Str(nTotAInte - nDevAInte - nDevolucao,10,02)                                             
      nLin := nLin + 1

      @ nLin,019 PSAY "E"
      @ nLin,021 PSAY Str(nQuaAExte,05)
      @ nLin,027 PSAY Str(nProAExte,10,02)
      @ nLin,038 PSAY Str(nSerAExte,10,02)
      @ nLin,049 PSAY Str(nFreAExte,10,02)                                             
      @ nLin,060 PSAY Str(nDevAExte,10,02)                                             
      @ nLin,071 PSAY Str(nTotAExte,10,02)                                             
               
      nLin := nLin + 1

      @ nLin,019 PSAY "T"
      @ nLin,021 PSAY Str(nQuaAInte + nQuaAExte,05)
      @ nLin,027 PSAY Str(nProAInte + nProAExte,10,02)
      @ nLin,038 PSAY Str(nSerAInte + nSerAExte,10,02)
      @ nLin,049 PSAY Str(nFreAInte + nFreAExte,10,02)                                             
      @ nLin,060 PSAY Str(nDevAInte + nDevAExte + nDevolucao,10,02)                                             
      @ nLin,071 PSAY Str(nTotAInte + nTotAExte - nDevAInte - nDevolucao,10,02)                                             

      nLin := nLin + 2

      @ nLin,001 PSAY "--------------------------------------------------------------------------------"

      nLin = nLin + 2

      // Totaliza o Período
      @ nLin,001 PSAY "TOTAL DO PERÍODO"
      @ nLin,019 PSAY "I"
      @ nLin,021 PSAY Str(nQuaGInte,05)
      @ nLin,027 PSAY Str(nProGInte,10,02)
      @ nLin,038 PSAY Str(nSerGInte,10,02)
      @ nLin,049 PSAY Str(nFreGInte,10,02)                                             
      @ nLin,060 PSAY Str(nDevGInte,10,02)                                             
//    @ nLin,071 PSAY Str(nTotGInte,10,02)                                             
      nLin := nLin + 1

      // Verifica se existe devolução para a nota fiscal selecionada
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      @ nLin,019 PSAY "O"
      @ nLin,060 PSAY Str(nDevolucao,10,02)                                             
      @ nLin,071 PSAY Str(nTotGInte - nDevolucao,10,02)                                             
      nLin := nLin + 1

      @ nLin,019 PSAY "E"
      @ nLin,021 PSAY Str(nQuaGExte,05)
      @ nLin,027 PSAY Str(nProGExte,10,02)
      @ nLin,038 PSAY Str(nSerGExte,10,02)
      @ nLin,049 PSAY Str(nFreGExte,10,02)                                             
      @ nLin,060 PSAY Str(nDevGExte,10,02)                                             
      @ nLin,071 PSAY Str(nTotGExte,10,02)                                             
      nLin := nLin + 1

      @ nLin,019 PSAY "T"
      @ nLin,021 PSAY Str(nQuaGInte + nQuaGExte,05)
      @ nLin,027 PSAY Str(nProGInte + nProGExte,10,02)
      @ nLin,038 PSAY Str(nSerGInte + nSerGExte,10,02)
      @ nLin,049 PSAY Str(nFreGInte + nFreGExte,10,02)                                             
      @ nLin,060 PSAY Str(nDevGInte + nDevGExte + nDevolucao,10,02)                                             
      @ nLin,071 PSAY Str(nTotGInte + nTotGExte - nDevolucao,10,02)                                             

   Endif

   // Finaliza a execucao do relatorio
   SET DEVICE TO SCREEN

   // Se impressao em disco, chama o gerenciador de impressao

   If aReturn[5]==1
      dbCommitAll()
      SET PRINTER TO
      OurSpool(wnrel)
   Endif

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.

/*
         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO DE FATUMANETO POR PERIODO                                                                 XX/XX/XXXX-XX:XX:XX
AUTOMR06.PRW                                                                       PERIODO DE XX/XX/XXXX A XX/XX/XXXX                                                                PAGINA:       XXXXX 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TES CFOP  DATA       NF     SER NR.PV  TIPO    DESCRIÇÃO DOS CLIENTES              CIDADE                         UF      QUANT UND    VLR PRODUTO   VLR SERVICO      VLR FRETE     VLR TOTAL
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                          FILIAL.: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                          GRUPO..: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                          PRODUTO: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

TES CFOP  DATA       NF     SER NR.PV  TIPO    DESCRIÇÃO DOS CLIENTES              CIDADE                      UF      QUANT UND    VLR PRODUTO   VLR SERVICO      VLR FRETE    DEVOLUÇÕES     VLR TOTAL
XXX X.XXX XX/XX/XXXX XXXXXX XXX XXXXXX XXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXX XX XXXXXXX.XX XXX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXX.XX
XXX X.XXX XX/XX/XXXX XXXXXX XXX XXXXXX XXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXX XX XXXXXXX.XX XXX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXX.XX
XXX X.XXX XX/XX/XXXX XXXXXX XXX XXXXXX XXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXX XX XXXXXXX.XX XXX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXX.XX
XXX X.XXX XX/XX/XXXX XXXXXX XXX XXXXXX XXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXX XX XXXXXXX.XX XXX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXXX.XX XXXXXXXXXX.XX XXXXXXXXXX.XX

                                                                                          Total Pedidos Internos:
                                                                                          Total Pedidos Externos:
                                                                                          Total.................:
         1         2         3         4         5         6         7         8 
12345678901234567890123456789012345678901234567890123456789012345678901234567890
AUTOMATECH    FATURAMENTO POR GRUPO/PRODUTO - SINTETICO      XX/XX/XXXX-XX:XX:XX
AUTOMR09.PRW         PERÍODO DE XX/XX/XXXX A XX/XX/XXXX      PÁGINA:       XXXXX
--------------------------------------------------------------------------------"                                                                                                                                                                                                                     
DESCRIÇÃO GRUPOS  T   QTD   VLR PROD   VLR SERV  VLR FRETE  DEVLUÇÕES  VLR TOTAL
-------------------------------------------------------------------------------- 

                      FILIAL: 01 - PORTO ALEGRE

         1         2         3         4         5         6         7         8 
12345678901234567890123456789012345678901234567890123456789012345678901234567890
DESCRIÇÃO GRUPOS  T   QTD   VLR PROD   VLR SERV  VLR FRETE  DEVLUÇÕES  VLR TOTAL
xxxxxxxxxxxxxxxxx I xxxxx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx
                  E xxxxx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx
                  T xxxxx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx xxxxxxx.xx

TOTAL DA FILIAL   I

*/