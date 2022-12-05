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

User Function AUTOMR09()   

   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	  := {}
   Local _aAlias  	  := {}
   Local cSql         := ""
   Local cNomeProduto := ""
   Local cProduto     := Space(30)

   // Variáveis Private da Função
   Private dData01   := Ctod("  /  /    ")
   Private dData02   := Ctod("  /  /    ")
   Private aComboBx1 := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS"}
   Private aComboBx2 := {"ANALÍTICO", "SINTÉTICO"}
   Private aComboBx3 := {}

   Private nGet1	 := Ctod("  /  /    ")
   Private nGet2	 := Ctod("  /  /    ")
   Private nGet3	 := Space(30)
   Private cComboBx1
   Private cComboBx2   
   Private cComboBx3   

   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTOMR09")

   // Carrega o combo de grupos de produtos
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM010")
   cSql += " ORDER BY BM_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   T_GRUPO->( DbGoTop() )

   aAdd( aComboBx3, "0000 - TODOS OS GRUPOS" )
   
   While !T_GRUPO->( EOF() )
      aAdd( aComboBx3, Alltrim(T_GRUPO->BM_GRUPO) + " - " + Alltrim(T_GRUPO->BM_DESC) )
      T_GRUPO->( DBSKIP() )
   Enddo

   // Variáveis que definem a Ação do Formulário

   DEFINE MSDIALOG oDlg TITLE "Faturamento por Grupo/Produto" FROM C(178),C(181) TO C(420),C(550) PIXEL

   // Solicita o nº da etiqueta a ser impressa
   @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(005) Say "Grupo:       " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(005) Say "Produto:     " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(100) Say cNomeProduto    Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(005) Say "Filial:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(085),C(005) Say "Tipo:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(009),C(035) MsGet oGet1 Var dData01            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(023),C(035) MsGet oGet2 Var dData02            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(040),C(035) ComboBox cComboBx3 Items aComboBx3 Size C(140),C(010) PIXEL OF oDlg
   @ C(055),C(035) MsGet oGet3 Var cProduto           Size C(055),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNomeProd(cProduto) )
   @ C(070),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(140),C(010) PIXEL OF oDlg
   @ C(085),C(035) ComboBox cComboBx2 Items aComboBx2 Size C(140),C(010) PIXEL OF oDlg

   DEFINE SBUTTON FROM C(100),C(155) TYPE  6 ENABLE OF oDlg ACTION( FATUPER( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cProduto ))
   DEFINE SBUTTON FROM C(100),C(132) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que trás a descrição do produto selecionado
Static Function BuscaNomeProd( cProduto )

   Local cSql := ""
   
   If Empty(cProduto)
      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf
      cNomeProduto := ""
      Return .T.
   Endif   

   If Select("T_PRODUTO") > 0
   	  T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := "SELECT B1_DESC, "
   cSql += "       B1_DAUX  "
   cSql += "  FROM " + RetSqlName("SB1010")
   cSql += " WHERE B1_COD = '" + Alltrim(cProduto) + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )
	
    If !T_PRODUTO->( EOF() )
       cNomeProduto := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
    Else
       MsgAlert("Produto informado inexistente.")
       cNomeProduto := ""
    Endif

    If Select("T_PRODUTO") > 0
   	   T_PRODUTO->( dbCloseArea() )
    EndIf

Return .T.

// Função que prepara a impressão do relatório
Static Function FATUPER( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cProduto)

   // Declaracao de Variaveis
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
   
   _Filial := Substr(cComboBx1,01,02)

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

//   Private nomeprog     := "AUTOMR08"
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

   Private xComboBx1
   Private xComboBx2
   Private xComboBx3
   
   xComboBx1 := cComboBx1
   xComboBx2 := cComboBx2
   xComboBx3 := Substr(cComboBx3,01,04)
   
   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

   // Pesquisa as devoluções ref. ao período informado
   If Select("T_DEVOLUCAO") > 0
      T_DEVOLUCAO->( dbCloseArea() )
   EndIf

   csql = ""
   csql += "SELECT A.D1_FILIAL  ," + CHR(13)
   csql += "       A.D1_TOTAL   ," + CHR(13)
   csql += "       A.D1_EMISSAO ," + CHR(13)
   csql += "       A.D1_NFORI   ," + CHR(13)
   csql += "       A.D1_SERIORI ,"  + CHR(13)
   csql += "       A.D1_ITEMORI ," + CHR(13)
   cSql += "       A.D1_COD     ," + CHR(13)
   cSql += "       C.B1_GRUPO    " + CHR(13)
   csql += "  FROM " + RetSqlName("SD1010") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("SF4010") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("SB1010") + " C  " + CHR(13)
   cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + CHR(13)
   cSql += "   AND A.D1_COD       = C.B1_COD " + CHR(13)

   If _Filial <> "00"
     cSql += " AND A.D1_FILIAL = '" + Alltrim(_Filial) + "'"  + CHR(13)
   Endif

   csql += "   AND A.D1_NFORI    <> ''" + CHR(13)
   csql += "   AND A.R_E_C_D_E_L_ = ''" + CHR(13)
   cSql += "   AND A.D1_TES       = B.F4_CODIGO " + CHR(13)
   cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') " + CHR(13)

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

   // Pesquisa os dados para emissão do relatório
   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.D2_FILIAL , " + chr(13)
   cSql += "       A.D2_DOC    , " + chr(13)
   cSql += "       A.D2_SERIE  , " + chr(13)
   cSql += "       A.D2_EMISSAO, " + chr(13)
   cSql += "       A.D2_TES    , " + chr(13)
   cSql += "       A.D2_QUANT  , " + chr(13)
   cSql += "       A.D2_UM     , " + chr(13)
   cSql += "       G.F4_DUPLIC , " + chr(13)
   cSql += "       A.D2_CF     , " + chr(13)
   cSql += "       A.D2_PEDIDO , " + chr(13)
   cSql += "       F.C5_FRETE  , " + chr(13)
   cSql += "       A.D2_CLIENTE, " + chr(13)
   cSql += "       A.D2_LOJA   , " + chr(13)
   cSql += "       C.A1_NOME   , " + chr(13)
   cSql += "       C.A1_MUN    , " + chr(13)
   cSql += "       C.A1_EST    , " + chr(13)
   cSql += "       A.D2_ITEM   , " + chr(13)
   cSql += "       A.D2_COD    , " + chr(13)
   cSql += "       D.B1_COD    , " + chr(13)
   cSql += "       D.B1_DESC   , " + chr(13)
   cSql += "       D.B1_DAUX   , " + chr(13)
   cSql += "       D.B1_TIPO   , " + chr(13)
   cSql += "       D.B1_GRUPO  , " + chr(13)
   cSql += "       A.D2_UM     , " + chr(13)
   cSql += "       A.D2_QUANT  , " + chr(13)
   cSql += "       A.D2_TOTAL  , " + chr(13)
   cSql += "       A.D2_VALFRE , " + chr(13)
   cSql += "       F.C5_FORNEXT, " + chr(13)
   cSql += "       H.BM_GRUPO  , " + chr(13)
   cSql += "       H.BM_DESC     " + chr(13)
   cSql += "  FROM " + RetSqlName("SD2010") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SF2010") + " B, " + chr(13)
   cSql += "       " + RetSqlName("SA1010") + " C, " + chr(13)
   cSql += "       " + RetSqlName("SB1010") + " D, " + chr(13)
   cSql += "       " + RetSqlName("SC5010") + " F, " + chr(13)
   cSql += "       " + RetSqlName("SF4010") + " G, " + chr(13)
   cSql += "       " + RetSqlName("SBM010") + " H  " + chr(13)
   cSql += " WHERE B.F2_DOC       = A.D2_DOC    " + chr(13)
   cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL " + chr(13)
   cSql += "   AND B.F2_SERIE     = A.D2_SERIE  " + chr(13)
   csql += "   AND B.F2_TIPO      = 'N'         " + chr(13)
   cSql += "   AND A.D2_CLIENTE   = C.A1_COD    " + chr(13)
   cSql += "   AND A.D2_LOJA      = C.A1_LOJA   " + chr(13)
   cSql += "   AND A.D2_COD       = D.B1_COD    " + chr(13)
   cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    " + chr(13)
   cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL " + chr(13)
   cSql += "   AND F.R_E_C_D_E_L_ = ''          " + chr(13)
   cSql += "   AND A.D2_TES       = G.F4_CODIGO " + chr(13)
   cSql += "   AND G.F4_DUPLIC    = 'S'         " + chr(13)
   cSql += "   AND A.R_E_C_D_E_L_ = ''          " + chr(13)
   cSql += "   AND B.R_E_C_D_E_L_ = ''          " + chr(13)
   cSql += "   AND D.B1_GRUPO     = H.BM_GRUPO  " + chr(13)
   cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)

   If _Filial <> "00"
     cSql += " AND A.D2_FILIAL = '" + Alltrim(_Filial) + "'"  + chr(13)
   Endif
  
   If xComboBx3 <> "0000"
      cSql += "  AND D.B1_GRUPO = '" + Alltrim(xComboBx3) + "'" + chr(13)
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

   // Monta a interface padrao com o usuario
   wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // Processamento. RPTSTATUS monta janela com a regua de processamento.
   RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return .T.

// Função que gera o relatório
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

   // Imprime o relatório analítico

   If Alltrim(xComboBx2) == "ANALÍTICO"

      cEmpFil   := Resultado->D2_FILIAL
      cGrupo    := Resultado->BM_GRUPO
      cMaterial := Resultado->B1_COD

      // Totalizadores dos produtos
      nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
      nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

      // Totalizadores dos grupos
      nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
      nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

      // Totalizadores das filiais
      nQuaFInte := 0; nProFInte := 0; nSerFInte := 0; nFreFInte := 0; nTotFInte := 0; nDevFInte := 0
      nQuaFExte := 0; nProFExte := 0; nSerFExte := 0; nFreFExte := 0; nTotFExte := 0; nDevFExte := 0

      // Totalizadores das filiais
      nQuaAInte := 0; nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
      nQuaAExte := 0; nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

      // Controle numeração de páginas
      nPagina  := 0

      While !Resultado->( EOF() )

         If Alltrim(Resultado->D2_FILIAL) == Alltrim(cEmpFil)

            If Alltrim(Resultado->BM_GRUPO) == Alltrim(cGrupo)

               If Alltrim(Resultado->B1_COD) == Alltrim(cMaterial)

                  // Verifica o cancelamento pelo usuario...
                  If lAbortPrint
                     @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                     Exit
                  Endif

                  // Impressao do cabecalho do relatorio
                  If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                     nPagina := nPagina + 1
                     nLin    := 1
       
                     @ nLin,001 PSAY "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
                     @ nLin,084 PSAY "FATURAMENTO POR GRUPO DE PRODUTOS"
                     @ nLin,180 PSAY dtoc(DATE()) + " - " + TIME()
                     nLin := nLin + 1
                     @ nLin,001 PSAY "AUTOMR09.PRW"
                     @ nLin,084 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
                     @ nLin,180 PSAY "PÁGINA:"
                     @ nLin,195 PSAY Strzero(nPagina,6)
                     nLin = nLin + 1
                     @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
                     nLin := nLin + 1
                     @ nLin,001 PSAY "TES CFOP  DATA       NF     SER NR.PV  TIPO    DESCRIÇÃO DOS CLIENTES              CIDADE                      UF      QUANT UND    VLR PRODUTO   VLR SERVICO      VLR FRETE    DEVOLUÇÕES     VLR TOTAL"
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

                  // Impressão dos dados
                  @ nLin,001 PSAY Resultado->D2_TES
                  @ nLin,005 PSAY Substr(Resultado->D2_CF,01,01) + "." + Substr(Alltrim(Resultado->D2_CF),02,03)
                  @ nLin,011 PSAY Substr(Resultado->D2_EMISSAO,07,02) + "/" + Substr(Resultado->D2_EMISSAO,05,02) + "/" + Substr(Resultado->D2_EMISSAO,01,04)
                  @ nLin,022 PSAY Substr(Resultado->D2_DOC,01,06)
                  @ nLin,029 PSAY Resultado->D2_SERIE
                  @ nLin,033 PSAY Resultado->D2_PEDIDO
                  @ nLin,040 PSAY IIF(Empty(Alltrim(Resultado->C5_FORNEXT)), "INTERNO", "EXTERNO")
                  @ nLin,048 PSAY Substr(Resultado->A1_NOME,01,35)
                  @ nLin,084 PSAY Substr(Resultado->A1_MUN,01,27)
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

                  @ nLin,174 PSAY Str(nDevolucao,13,02)                              
                  @ nLin,188 PSAY Str((nValTot - nDevolucao),13,02)                              

                  If Empty(Alltrim(Resultado->C5_FORNEXT))
				     // Totaliza Produtos
                     nQuaPInte := nQuaPInte + Resultado->D2_QUANT
                     nProPInte := nProPInte + nValPro
                     nSerPInte := nSerPInte + nValSer
                     nFrePInte := nFrePInte + nValFre
                     nDevPInte := nDevPInte + nDevolucao
                     nTotPInte := nTotPInte + nValTot - nDevolucao

	                 // Totaliza Grupos
                     nQuaGInte := nQuaGInte + Resultado->D2_QUANT
                     nProGInte := nProGInte + nValPro
                     nSerGInte := nSerGInte + nValSer
                     nFreGInte := nFreGInte + nValFre
                     nDevGInte := nDevGInte + nDevolucao
                     nTotGInte := nTotGInte + nValTot - nDevolucao

	                 // Totaliza Filiais
                     nQuaFInte := nQuaFInte + Resultado->D2_QUANT
                     nProFInte := nProFInte + nValPro
                     nSerFInte := nSerFInte + nValSer
                     nFreFInte := nFreFInte + nValFre
                     nDevFInte := nDevFInte + nDevolucao
                     nTotFInte := nTotFInte + nValTot - nDevolucao

	                 // Totaliza Acumulador Total
                     nQuaAInte := nQuaAInte + Resultado->D2_QUANT
                     nProAInte := nProAInte + nValPro
                     nSerAInte := nSerAInte + nValSer
                     nFreAInte := nFreAInte + nValFre
                     nDevAInte := nDevAInte + nDevolucao
                     nTotAInte := nTotAInte + nValTot - nDevolucao

                  Else
 
                     // Totaliza Produtos
                     nQuaPExte := nQuaPExte + Resultado->D2_QUANT
                     nProPExte := nProPExte + nValPro
                     nSerPExte := nSerPExte + nValSer
                     nFrePExte := nFrePExte + nValFre
                     nDevPExte := nDevPExte + nDevolucao
                     nTotPExte := nTotPExte + nValTot - nDevolucao


                     // Totaliza Grupos
                     nQuaGExte := nQuaGExte + Resultado->D2_QUANT
                     nProGExte := nProGExte + nValPro
                     nSerGExte := nSerGExte + nValSer
                     nFreGExte := nFreGExte + nValFre
                     nDevGExte := nDevGExte + nDevolucao
                     nTotGExte := nTotGExte + nValTot - nDevolucao

                     // Totaliza Filiais
                     nQuaFExte := nQuaFExte + Resultado->D2_QUANT
                     nProFExte := nProFExte + nValPro
                     nSerFExte := nSerFExte + nValSer
                     nFreFExte := nFreFExte + nValFre
                     nDevFExte := nDevFExte + nDevolucao
                     nTotFExte := nTotFExte + nValTot - nDevolucao

	                 // Totaliza Acumulador Total
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
   
                  // Totaliza o Produto
                  nLin := nLin + 1
                  @ nLin,091 PSAY "Total Produtos Internos:"
                  @ nLin,115 PSAY Str(nQuaPInte,10,02)
                  @ nLin,130 PSAY Str(nProPInte,14,02)
                  @ nLin,145 PSAY Str(nSerPInte,13,02)
                  @ nLin,159 PSAY Str(nFrePInte,14,02)
                  @ nLin,174 PSAY Str(nDevPInte,13,02)
                  nLin := nLin + 1

                  // Pesquisa Outras Devoluções na Data
                  nDevolucao := 0
                  For nDevolve = 1 to Len(aDevolucao)
                      If aDevolucao[nDevolve,09] == cMaterial
                         If aDevolucao[nDevolve,07] == .F.
                            nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                         Endif
                      Endif
                  Next nDevolve

                  @ nLin,091 PSAY "Total Outras Devoluções:"
                  @ nLin,174 PSAY Str((nDevolucao),13,02)
                  @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
                  nLin = nLin + 1

                  @ nLin,091 PSAY "Total Produtos Externos:"
                  @ nLin,115 PSAY Str(nQuaPExte,10,02)
                  @ nLin,130 PSAY Str(nProPExte,14,02)
                  @ nLin,145 PSAY Str(nSerPExte,13,02)
                  @ nLin,159 PSAY Str(nFrePExte,14,02)
                  @ nLin,174 PSAY Str(nDevPExte,13,02)
                  @ nLin,188 PSAY Str(nTotPExte,13,02)                              
                  nLin := nLin + 1

                  @ nLin,091 PSAY "Total dos Produtos.....:"
                  @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
                  @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
                  @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
                  @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
                  @ nLin,174 PSAY Str(nDevPInte + nDevPExte,13,02)
                  @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
                  nLin := nLin + 2

                  cMaterial := Resultado->B1_COD                  

                  // Zera os totalizadores dos produtos
                  nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
                  nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

                  @ nLin,059 PSAY "PRODUTO: " + Substr(Resultado->B1_COD,01,06) + " - " + Alltrim(Resultado->B1_DESC) + " " + Alltrim(Resultado->B1_DAUX)
                  nLin = nLin + 2

               Endif
         
            Else            
            
               // Totaliza o Produto
               nLin := nLin + 1
               @ nLin,091 PSAY "Total Produtos Internos:"
               @ nLin,115 PSAY Str(nQuaPInte,10,02)
               @ nLin,130 PSAY Str(nProPInte,14,02)
               @ nLin,145 PSAY Str(nSerPInte,13,02)
               @ nLin,159 PSAY Str(nFrePInte,14,02)
               @ nLin,174 PSAY Str(nDevPInte,13,02)
               nLin := nLin + 1

               // Pesquisa Outras Devoluções na Data
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,09] == cMaterial
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                   Endif
               Next nDevolve

               @ nLin,091 PSAY "Total Outras Devoluções:"
               @ nLin,174 PSAY Str((nDevolucao),13,02)
               @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
               nLin = nLin + 1

               @ nLin,091 PSAY "Total Produtos Externos:"
               @ nLin,115 PSAY Str(nQuaPExte,10,02)
               @ nLin,130 PSAY Str(nProPExte,14,02)
               @ nLin,145 PSAY Str(nSerPExte,13,02)
               @ nLin,159 PSAY Str(nFrePExte,14,02)
               @ nLin,174 PSAY Str(nDevPExte,13,02)
               @ nLin,188 PSAY Str(nTotPExte,13,02)                              
               nLin := nLin + 1

               @ nLin,091 PSAY "Total dos Produtos.....:"
               @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
               @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
               @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
               @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
               @ nLin,174 PSAY Str(nDevPInte + nDevPExte,13,02)
               @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
               nLin := nLin + 2

               // Totaliza o Grupo
               @ nLin,091 PSAY "Total Grupos Internos..:"
               @ nLin,115 PSAY Str(nQuaGInte,10,02)
               @ nLin,130 PSAY Str(nProGInte,14,02)
               @ nLin,145 PSAY Str(nSerGInte,13,02)
               @ nLin,159 PSAY Str(nFreGInte,14,02)
               @ nLin,174 PSAY Str(nDevGInte,13,02)
               nLin := nLin + 1

               // Pesquisa Outras Devoluções na Data
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,10] == cGrupo
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                   Endif
               Next nDevolve

               @ nLin,091 PSAY "Total Outras Devoluções:"
               @ nLin,174 PSAY Str((nDevolucao),13,02)
               @ nLin,188 PSAY Str((nTotGInte - nDevolucao),13,02)
               nLin = nLin + 1

               @ nLin,091 PSAY "Total Grupos Externos..:"
               @ nLin,115 PSAY Str(nQuaGExte,10,02)
               @ nLin,130 PSAY Str(nProGExte,14,02)
               @ nLin,145 PSAY Str(nSerGExte,13,02)
               @ nLin,159 PSAY Str(nFreGExte,14,02)
               @ nLin,174 PSAY Str(nDevGExte,13,02)
               @ nLin,188 PSAY Str(nTotGExte,13,02)                              
               nLin := nLin + 1

               @ nLin,091 PSAY "Total do Grupo.........:"
               @ nLin,115 PSAY Str(nQuaGInte + nQuaGExte,10,02)
               @ nLin,130 PSAY Str(nProGInte + nProGExte,14,02)
               @ nLin,145 PSAY Str(nSerGInte + nSerGExte,13,02)
               @ nLin,159 PSAY Str(nFreGInte + nFreGExte,14,02)
               @ nLin,174 PSAY Str(nDevGInte + nDevGExte,13,02)
               @ nLin,188 PSAY Str(nTotGInte + nTotGExte - nDevolucao,13,02)                              
               nLin := nLin + 2

               cGrupo    := Resultado->BM_GRUPO
               cMaterial := Resultado->B1_COD                  

               // Zera os totalizadores dos produtos
               nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
               nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

               // Totalizadores dos grupos
               nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
               nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

               nLin = nLin + 1
               @ nLin,059 PSAY "GRUPO..:   " + Resultado->BM_GRUPO + " - " + Alltrim(Resultado->BM_DESC)      
               nLin = nLin + 2

            Endif
            
         Else   

            // Totaliza o Produto
            nLin := nLin + 1
            @ nLin,091 PSAY "Total Produtos Internos:"
            @ nLin,115 PSAY Str(nQuaPInte,10,02)
            @ nLin,130 PSAY Str(nProPInte,14,02)
            @ nLin,145 PSAY Str(nSerPInte,13,02)
            @ nLin,159 PSAY Str(nFrePInte,14,02)
            @ nLin,174 PSAY Str(nDevPInte,13,02)
            nLin := nLin + 1

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,09] == cMaterial
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,091 PSAY "Total Outras Devoluções:"
            @ nLin,174 PSAY Str((nDevolucao),13,02)
            @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
            nLin = nLin + 1

            @ nLin,091 PSAY "Total Produtos Externos:"
            @ nLin,115 PSAY Str(nQuaPExte,10,02)
            @ nLin,130 PSAY Str(nProPExte,14,02)
            @ nLin,145 PSAY Str(nSerPExte,13,02)
            @ nLin,159 PSAY Str(nFrePExte,14,02)
            @ nLin,174 PSAY Str(nDevPExte,13,02)
            @ nLin,188 PSAY Str(nTotPExte,13,02)                              
            nLin := nLin + 1

            @ nLin,091 PSAY "Total dos Produtos.....:"
            @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
            @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
            @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
            @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
            @ nLin,174 PSAY Str(nDevPInte + nDevPExte,13,02)
            @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
            nLin := nLin + 2

            // Totaliza o Grupo
            @ nLin,091 PSAY "Total Grupos Internos..:"
            @ nLin,115 PSAY Str(nQuaGInte,10,02)
            @ nLin,130 PSAY Str(nProGInte,14,02)
            @ nLin,145 PSAY Str(nSerGInte,13,02)
            @ nLin,159 PSAY Str(nFreGInte,14,02)
            @ nLin,174 PSAY Str(nDevGInte,13,02)
            nLin := nLin + 1

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,10] == cGrupo
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,091 PSAY "Total Outras Devoluções:"
            @ nLin,174 PSAY Str((nDevolucao),13,02)
            @ nLin,188 PSAY Str((nTotGInte - nDevolucao),13,02)
            nLin = nLin + 1

            @ nLin,091 PSAY "Total Grupos Externos..:"
            @ nLin,115 PSAY Str(nQuaGExte,10,02)
            @ nLin,130 PSAY Str(nProGExte,14,02)
            @ nLin,145 PSAY Str(nSerGExte,13,02)
            @ nLin,159 PSAY Str(nFreGExte,14,02)
            @ nLin,174 PSAY Str(nDevGExte,13,02)
            @ nLin,188 PSAY Str(nTotGExte,13,02)                              
            nLin := nLin + 1

            @ nLin,091 PSAY "Total do Grupo.........:"
            @ nLin,115 PSAY Str(nQuaGInte + nQuaGExte,10,02)
            @ nLin,130 PSAY Str(nProGInte + nProGExte,14,02)
            @ nLin,145 PSAY Str(nSerGInte + nSerGExte,13,02)
            @ nLin,159 PSAY Str(nFreGInte + nFreGExte,14,02)
            @ nLin,174 PSAY Str(nDevGInte + nDevGExte,13,02)
            @ nLin,188 PSAY Str(nTotGInte + nTotGExte,13,02)                              
            nLin := nLin + 2

            // Totaliza a Filial
            @ nLin,091 PSAY "Total Filial Internos..:"
            @ nLin,115 PSAY Str(nQuaFInte,10,02)
            @ nLin,130 PSAY Str(nProFInte,14,02)
            @ nLin,145 PSAY Str(nSerFInte,13,02)
            @ nLin,159 PSAY Str(nFreFInte,14,02)
            @ nLin,174 PSAY Str(nDevFInte,13,02)
            nLin := nLin + 1

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,01] == cEmpFil
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,091 PSAY "Total Outras Devoluções:"
            @ nLin,174 PSAY Str((nDevolucao),13,02)
            @ nLin,188 PSAY Str((nTotFInte - nDevolucao),13,02)
            nLin = nLin + 1

            @ nLin,091 PSAY "Total Filial Externos..:"
            @ nLin,115 PSAY Str(nQuaFExte,10,02)
            @ nLin,130 PSAY Str(nProFExte,14,02)
            @ nLin,145 PSAY Str(nSerFExte,13,02)
            @ nLin,159 PSAY Str(nFreFExte,14,02)
            @ nLin,174 PSAY Str(nDevFExte,13,02)
            @ nLin,188 PSAY Str(nTotFExte,13,02)                              
            nLin := nLin + 1

            @ nLin,091 PSAY "Total da Filial........:"
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

            // Totalizadores dos produtos
            nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
            nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

            // Totalizadores dos grupos
            nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
            nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

            // Totalizadores das filiais
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

      // Totaliza o Produto
      nLin := nLin + 1
      @ nLin,091 PSAY "Total Produtos Internos:"
      @ nLin,115 PSAY Str(nQuaPInte,10,02)
      @ nLin,130 PSAY Str(nProPInte,14,02)
      @ nLin,145 PSAY Str(nSerPInte,13,02)
      @ nLin,159 PSAY Str(nFrePInte,14,02)
      @ nLin,174 PSAY Str(nDevPInte,13,02)
      nLin := nLin + 1

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cMaterial
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,091 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,091 PSAY "Total Produtos Externos:"
      @ nLin,115 PSAY Str(nQuaPExte,10,02)
      @ nLin,130 PSAY Str(nProPExte,14,02)
      @ nLin,145 PSAY Str(nSerPExte,13,02)
      @ nLin,159 PSAY Str(nFrePExte,14,02)
      @ nLin,174 PSAY Str(nDevPExte,13,02)
      @ nLin,188 PSAY Str(nTotPExte,13,02)                              
      nLin := nLin + 1

      @ nLin,091 PSAY "Total dos Produtos.....:"
      @ nLin,115 PSAY Str(nQuaPInte + nQuaPExte,10,02)
      @ nLin,130 PSAY Str(nProPInte + nProPExte,14,02)
      @ nLin,145 PSAY Str(nSerPInte + nSerPExte,13,02)
      @ nLin,159 PSAY Str(nFrePInte + nFrePExte,14,02)
      @ nLin,174 PSAY Str(nDevPInte + nFrePExte,13,02)
      @ nLin,188 PSAY Str(nTotPInte + nTotPExte - nDevolucao,13,02)                              
      nLin := nLin + 2

      // Totaliza o Grupo
      @ nLin,091 PSAY "Total Grupos Internos..:"
      @ nLin,115 PSAY Str(nQuaGInte,10,02)
      @ nLin,130 PSAY Str(nProGInte,14,02)
      @ nLin,145 PSAY Str(nSerGInte,13,02)
      @ nLin,159 PSAY Str(nFreGInte,14,02)
      @ nLin,174 PSAY Str(nDevGInte,13,02)
      nLin := nLin + 1

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cGrupo
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,091 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotPInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,091 PSAY "Total Grupos Externos..:"
      @ nLin,115 PSAY Str(nQuaGExte,10,02)
      @ nLin,130 PSAY Str(nProGExte,14,02)
      @ nLin,145 PSAY Str(nSerGExte,13,02)
      @ nLin,159 PSAY Str(nFreGExte,14,02)
      @ nLin,174 PSAY Str(nDevGExte,13,02)
      @ nLin,188 PSAY Str(nTotGExte,13,02)                              
      nLin := nLin + 1

      @ nLin,091 PSAY "Total do Grupo.........:"
      @ nLin,115 PSAY Str(nQuaGInte + nQuaGExte,10,02)
      @ nLin,130 PSAY Str(nProGInte + nProGExte,14,02)
      @ nLin,145 PSAY Str(nSerGInte + nSerGExte,13,02)
      @ nLin,159 PSAY Str(nFreGInte + nFreGExte,14,02)
      @ nLin,174 PSAY Str(nDevGInte + nDevGExte,13,02)
      @ nLin,188 PSAY Str(nTotGInte + nTotGExte - nDevolucao,13,02)                              
      nLin := nLin + 2

      // Totaliza a Filial
      @ nLin,091 PSAY "Total Filial Internos..:"
      @ nLin,115 PSAY Str(nQuaFInte,10,02)
      @ nLin,130 PSAY Str(nProFInte,14,02)
      @ nLin,145 PSAY Str(nSerFInte,13,02)
      @ nLin,159 PSAY Str(nFreFInte,14,02)
      @ nLin,174 PSAY Str(nDevFInte,13,02)
      nLin := nLin + 1

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cEmpFil
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,091 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotFInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,091 PSAY "Total Filial Externos..:"
      @ nLin,115 PSAY Str(nQuaFExte,10,02)
      @ nLin,130 PSAY Str(nProFExte,14,02)
      @ nLin,145 PSAY Str(nSerFExte,13,02)
      @ nLin,159 PSAY Str(nFreFExte,14,02)
      @ nLin,174 PSAY Str(nDevFExte,13,02)
      @ nLin,188 PSAY Str(nTotFExte,13,02)                              
      nLin := nLin + 1

      @ nLin,091 PSAY "Total da Filial........:"
      @ nLin,115 PSAY Str(nQuaFInte + nQuaFExte,10,02)
      @ nLin,130 PSAY Str(nProFInte + nProFExte,14,02)
      @ nLin,145 PSAY Str(nSerFInte + nSerFExte,13,02)
      @ nLin,159 PSAY Str(nFreFInte + nFreFExte,14,02)
      @ nLin,174 PSAY Str(nDevFInte + nDevFExte + nDevolucao,13,02)
      @ nLin,188 PSAY Str(nTotFInte + nTotFExte - nDevolucao,13,02)                              
      nLin := nLin + 2

      @ nLin,091 PSAY "--------------------------------------------------------------------------------------------------------------"

      nLin := nLin + 2

      // Totaliza o Acumulado
      @ nLin,091 PSAY "Total Pedidos Internos.:"
      @ nLin,115 PSAY Str(nQuaAInte,10,02)
      @ nLin,130 PSAY Str(nProAInte,14,02)
      @ nLin,145 PSAY Str(nSerAInte,13,02)
      @ nLin,159 PSAY Str(nFreAInte,14,02)
      @ nLin,174 PSAY Str(nDevAInte,13,02)
      nLin := nLin + 1

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      @ nLin,091 PSAY "Total Outras Devoluções:"
      @ nLin,174 PSAY Str((nDevolucao),13,02)
      @ nLin,188 PSAY Str((nTotAInte - nDevolucao),13,02)
      nLin = nLin + 1

      @ nLin,091 PSAY "Total Pedidos Externos.:"
      @ nLin,115 PSAY Str(nQuaAExte,10,02)
      @ nLin,130 PSAY Str(nProAExte,14,02)
      @ nLin,145 PSAY Str(nSerAExte,13,02)
      @ nLin,159 PSAY Str(nFreAExte,14,02)
      @ nLin,174 PSAY Str(nDevAExte,13,02)
      @ nLin,188 PSAY Str(nTotAExte,13,02)                              
      nLin := nLin + 1

      @ nLin,091 PSAY "Total do Período.......:"
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