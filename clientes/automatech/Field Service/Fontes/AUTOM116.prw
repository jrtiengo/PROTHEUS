#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM116.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/06/2012                                                          *
// Objetivo..: Este probrama tem a finalidade de listar em relatório a rastreabi-  *
//             lidade de produtos constante em Ordem  de  Serviço, suas entradas   *
//             bem como o envio e retorno do poduto que é mandado para conserto.   *
// Parâmetros: Nenhum                                                              *
//**********************************************************************************

User Function AUTOM116()

   Local lChumba     := .F.

   Private cdInicial := Ctod("  /  /    ")
   Private cdFinal   := Ctod("  /  /    ")
   Private cProduto  := Space(06)
   Private cNProduto := Space(100)
   Private cSerie    := Space(20)
   Private cCliente  := Space(06)
   Private cLoja     := Space(03)
   Private cNCliente := Space(40)
   Private aComboBx1 := { "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas" }

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4 
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private cComboBx1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Porder de/em Terceiros (Assistência Técnica)" FROM C(178),C(182) TO C(381),C(690) PIXEL

   @ C(004),C(005) Say "Data Inicial" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(005) Say "Data Final"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(005) Say "Produto"      Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(044),C(005) Say "Nº de Série"  Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Cliente"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(005) Say "Filial"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(004),C(038) MsGet oGet1 Var cdInicial              Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(017),C(038) MsGet oGet2 Var cdFinal                Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(038) MsGet oGet3 Var cProduto               Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( PsqProduto(cProduto) )
   @ C(030),C(090) MsGet oGet4 Var cNProduto When lChumba Size C(158),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(038) MsGet oGet5 Var cSerie                 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(056),C(038) MsGet oGet6 Var cCliente               Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3('SA1')
   @ C(056),C(068) MsGet oGet7 Var cLoja                  Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(PsqCliente( cCliente, cLoja))
   @ C(056),C(090) MsGet oGet8 Var cNCliente When lChumba Size C(158),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(069),C(038) ComboBox cComboBx1 Items aComboBx1     Size C(129),C(010) PIXEL OF oDlg

   @ C(084),C(090) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( GeraRela() )
   @ C(084),C(129) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa a descrição do produto informado
Static Function PsqProduto( cProduto )

   Local cSql := ""
   
   If Empty(cProduto)
      cProduto  := Space(06)
      cnProduto := Space(100)
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
       cNProduto := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
    Else
       MsgAlert("Produto informado inexistente.")
       cProduto  := Space(06)
       cNProduto := Space(100)
    Endif

Return .T.

// Função que pesquisa o cliente informado
Static Function PsqCliente( _Cliente, _Loja )

   Local cSql := ""
   
   If Empty(_Cliente)
      cCliente  := Space(06)
      cLoja     := Space(03)
      cNCliente := Space(40)
      Return .T.
   Endif   

   If Select("T_CLIENTE") > 0
   	  T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, " 
   cSql += "       A1_NOME  "
   cSql += "  FROM " + RetSqlName("SA1010")
   cSql += " WHERE A1_COD  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(_Loja)    + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
	
    If !T_CLIENTE->( EOF() )
       cCliente  := T_CLIENTE->A1_COD
       cLoja     := T_CLIENTE->A1_LOJA
       cNCliente := Alltrim(T_CLIENTE->A1_NOME)
    Else
       MsgAlert("Cliente informado inexistente.")
       cCliente  := Space(06)
       cLoja     := Space(03)
       cNCliente := Space(40)
    Endif

Return .T.

// Função que prepara a impressão do relatório
Static Function GERARELA()

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
   Local cCaminho       := ""
   
   _Filial := Substr(cComboBx1,01,02)

   Private aConsulta    := {}

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""
   Private limite       := 220
   Private tamanho      := "G"
   Private nomeprog     := "Poder de/em Terceiros"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Demonstrações"
   Private cString      := "SC5"
   Private aDevolucao   := {}
   Private nDevolve     := 0

   Private nHdl
   Private cLinha       := ""
   
// Private limite  := 80
// Private tamanho := "P"
// Private nomeprog     := "AUTOMR08"

   Private aSaida   := {}
   Private aFiltro  := {}

   Private xComboBx1
   Private xComboBx2
   Private xComboBx3
   Private xComboBx4
   Private xComboBx5

   // Consistência dos Dados
   If Empty(cdInicial)
      MsgAlert("Data inicial de pesquisa não informada.")
      Return .T.
   Endif
      
   If Empty(cDfinal)
      MsgAlert("Data final de pesquisa não informada.")
      Return .T.
   Endif

   // Pesquisa as OS conforme filtro informado
   If Select("T_ORDENS") > 0
      T_ORDENS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AB6_FILIAL,"
   cSql += "       A.AB6_NFENT ,"
   cSql += "       A.AB6_EMISSA,"
   cSql += "       A.AB6_NUMOS ,"
   cSql += "       A.AB6_ETIQUE,"
   cSql += "       A.AB6_CODCLI,"
   cSql += "       A.AB6_LOJA  ,"
   cSql += "       B.AB7_CODPRO,"
   cSql += "       B.AB7_NUMSER,"
   cSql += "       C.B1_DESC   ,"
   cSql += "       C.B1_DAUX   ,"
   cSql += "       D.A1_NOME    "
   cSql += "  FROM " + RetSqlName("AB6") + " A, "
   cSql += "       " + RetSqlName("AB7") + " B, "
   cSql += "       " + RetSqlName("SB1") + " C, "
   cSql += "       " + RetSqlName("SA1") + " D  "
   cSql += " WHERE A.AB6_FILIAL   = '" + Alltrim(_Filial) + "'"
   cSql += "   AND A.AB6_EMISSA  >= '" + Substr(Dtoc(cDInicial),07,04) + Substr(Dtoc(cDInicial),04,02) + Substr(Dtoc(cDInicial),01,02) + "'"
   cSql += "   AND A.AB6_EMISSA  <= '" + Substr(Dtoc(cDFinal)  ,07,04) + Substr(Dtoc(cDFinal)  ,04,02) + Substr(Dtoc(cDFinal)  ,01,02) + "'"

   If !Empty(cCliente)
      cSql += "   AND A.AB6_CODCLI   = '" + Alltrim(cCliente) + "'"
      cSql += "   AND A.AB6_LOJA     = '" + Alltrim(cLoja)    + "'"
   Endif
      
   cSql += "   AND A.R_E_C_D_E_L_ = ''
   cSql += "   AND A.AB6_FILIAL   = B.AB7_FILIAL
   cSql += "   AND A.AB6_NUMOS    = B.AB7_NUMOS
   cSql += "   AND B.R_E_C_D_E_L_ = ''

   If !Empty(cProduto)
      cSql += " AND B.AB7_CODPRO = '" + Alltrim(cProduto) + "'"
   Endif   

   If !Empty(cSerie)
      cSql += " AND B.AB7_NUMSER = '" + Alltrim(cSerie) + "'"
   Endif

   cSql += "   AND B.AB7_CODPRO   = C.B1_COD
   cSql += "   AND A.AB6_CODCLI   = D.A1_COD
   cSql += "   AND A.AB6_LOJA     = D.A1_LOJA
   cSql += " ORDER BY D.A1_NOME, C.B1_DESC, B.AB7_NUMSER "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDENS", .T., .T. )

   If T_ORDENS->( Eof() )
      MsgAlert("Não existem dados a serem visualizados para este filtro.")
      Return .T.
   Endif

   // Carrega o Array aSaida
   SELECT T_ORDENS->( DbGoTop() )

   While !T_ORDENS->( EOF() )
      // Carrega o array aConsulta com os dadso de entrada
      aAdd( aConsulta, { T_ORDENS->AB6_CODCLI,; // 01 - Código do Cliente
                         T_ORDENS->AB6_LOJA  ,; // 02 - Loja do Cliente
                         T_ORDENS->A1_NOME   ,; // 03 - Nome do Cliente
                         T_ORDENS->AB7_CODPRO,; // 04 - Código do Produto
                         T_ORDENS->B1_DESC   ,; // 05 - Descrição Principal do Produto
                         T_ORDENS->B1_DAUX   ,; // 06 - Descrição Auxiliar do Produto
                         T_ORDENS->AB6_FILIAL,; // 07 - Filial do Produto
                         "E"                 ,; // 08 - Tipo de Movimentação
                         T_ORDENS->AB6_NFENT ,; // 09 - Documento de Entrada
                         T_ORDENS->AB6_EMISSA,; // 10 - Data de Emissão/Inclusão
                         T_ORDENS->AB6_ETIQUE,; // 11 - Nº da Etiqueta
                         T_ORDENS->AB6_NUMOS ,; // 12 - Nº da Ordem de Serviço
                         ""                  ,; // 13 - Nº do Pedido de Venda
                         T_ORDENS->AB7_NUMSER}) // 14 - Nº de Série do Produto

      // Pesquisa o retorno da Ordem de Serviço
      If Select("T_RETORNO") > 0
         T_RETORNO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DISTINCT C6_FILIAL,"
      cSql += "       C6_NOTA  ,         "
      cSql += "       C6_DATFAT,         "
      cSql += "       C6_NUM             "
      cSql += "  FROM " + RetSqlName("SC6")
      cSql += " WHERE C6_FILIAL                 = '" + Alltrim(T_ORDENS->AB6_FILIAL) + "'"
      cSql += "   AND SUBSTRING(C6_NUMOS,01,06) = '" + Alltrim(T_ORDENS->AB6_NUMOS)  + "'"
      cSql += "   AND D_E_L_E_T_ = ''"          

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETORNO", .T., .T. )

      If !T_RETORNO->( EOF() )
      
         WHILE !T_RETORNO->( EOF() )
         
            aAdd( aConsulta, { T_ORDENS->AB6_CODCLI,;
                               T_ORDENS->AB6_LOJA  ,;
                               T_ORDENS->A1_NOME   ,;
                               T_ORDENS->AB7_CODPRO,;
                               T_ORDENS->B1_DESC   ,;
                               T_ORDENS->B1_DAUX   ,;                         
                               T_ORDENS->AB6_FILIAL,;
                               "S"                 ,;
                               T_RETORNO->C6_NOTA  ,;
                               T_RETORNO->C6_DATFAT,;
                               T_ORDENS->AB6_ETIQUE,;
                               T_ORDENS->AB6_NUMOS ,;
                               T_RETORNO->C6_NUM   ,;
                               T_ORDENS->AB7_NUMSER})

            T_RETORNO->( DbSkip() )

         ENDDO
         
      ENDIF

      T_ORDENS->( DbSkip() )

   Enddo                             

   If Len(aConsulta) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   Processa( {|| LISTACRIS(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Gerando Relatório",.F.)

Return .T.

// Função que gera o relatório
Static Function LISTACRIS(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
   Local nPosicao  := 0

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21
   Private nLimvert   := 3500
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0
   Private aTempo     := {}

   Private cRelSerie  := ""
   Private cRelNomeC  := ""
   Private cRelProdu  := ""
   Private cRelNomeP  := ""

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetPortrait()   // Para Retrato
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Imprime o relatório analítico
   cRelSerie  := Alltrim(aConsulta[01,14])
   cRelNomeC  := Alltrim(aConsulta[01,03])
   cRelNomeP  := Alltrim(aConsulta[01,05]) + " " + Alltrim(aConsulta[01,06])
   cRelProdu  := Alltrim(aConsulta[01,05])
   
   // Controle numeração de páginas
   nPagina  := 0
   _nLin    := 10
   nPosicao := 1

   ProcRegua( Len(aConsulta) )

   // Função que lista o cabeçalho do relatório
   CABECRIS(cRelSerie, cRelNomeC, cRelNomeP)

   For nContar = 1 to Len(aConsulta)

       If Alltrim(aConsulta[nContar,03]) + Alltrim(aConsulta[nContar,05]) + Alltrim(aConsulta[nContar,14]) == ;
          Alltrim(cRelNomeC)             + Alltrim(cRelProdu)             + Alltrim(cRelSerie)

          Do case
             case nPosicao == 1
                  oPrint:Say( _nLin, 0100, "CLIENTE.: " + Alltrim(cRelNomeC),oFont21)
                  nPosicao += 1
             case nPosicao == 2
                  oPrint:Say( _nLin, 0100, "PRODUTO.: " + Alltrim(cRelNomeP),oFont21)
                  nPosicao += 1
          EndCase

          oPrint:Say( _nLin, 1400, aConsulta[nContar,07] , oFont21)
          oPrint:Say( _nLin, 1500, aConsulta[nContar,08] , oFont21)
          oPrint:Say( _nLin, 1600, aConsulta[nContar,09] , oFont21)
          oPrint:Say( _nLin, 1800, Substr(aConsulta[nContar,10],07,02) + "/" + Substr(aConsulta[nContar,10],05,02) + "/" + Substr(aConsulta[nContar,10],01,04) , oFont21)
          oPrint:Say( _nLin, 2050, aConsulta[nContar,11] , oFont21)
          oPrint:Say( _nLin, 2250, aConsulta[nContar,13] , oFont21)

          SomaDemo(050,cRelSerie, cRelNomeC, cRelNomeP)

          If nPosicao == 3
             oPrint:Say( _nLin, 0100, "Nº SÉRIE: " + Alltrim(cRelSerie),oFont21)
             SomaDemo(050,cRelSerie, cRelNomeC, cRelNomeP)
             nPosicao := 1
          Endif
 
          Loop
            
       Else

          If nPosicao == 2
             oPrint:Say( _nLin, 0100, "PRODUTO.: " + Alltrim(cRelNomeP),oFont21)
             SomaDemo(050,cRelSerie, cRelNomeC, cRelNomeP)
             oPrint:Say( _nLin, 0100, "Nº SÉRIE: " + Alltrim(cRelSerie),oFont21)
             SomaDemo(050,cRelSerie, cRelNomeC, cRelNomeP)
          Endif   

          oPrint:Line( _nLin, 0100, _nLin, 2400 )

          cRelSerie  := Alltrim(aConsulta[nContar,14])
          cRelNomeC  := Alltrim(aConsulta[nContar,03])
          cRelNomeP  := Alltrim(aConsulta[nContar,05]) + " " + Alltrim(aConsulta[nContar,06])
          cRelProdu  := Alltrim(aConsulta[nContar,05])
          nPosicao   := 1

          SomaDemo(050,cRelSerie, cRelNomeC, cRelNomeP)

          nContar -= 1

       Endif
         
   Next nContar

   If nPosicao == 2
      oPrint:Say( _nLin, 0100, "PRODUTO.: " + Alltrim(cRelNomeP),oFont21)
      SomaDemo(050,cRelSerie, cRelNomeC, cRelNomeP)
      oPrint:Say( _nLin, 0100, "Nº SÉRIE: " + Alltrim(cRelSerie),oFont21)
      SomaDemo(050,cRelSerie, cRelNomeC, cRelNomeP)
   Endif   

   // Encerra Relatório
   oPrint:EndPage()

   // Preview do Relatório
   oPrint:Preview()

   MS_FLUSH()

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por VendedorGrupo de Produtos
Static Function CABECRIS(cRelSerie, cRelNomeC, cRelNomeP)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"  , oFont21)
   oPrint:Say( _nLin, 0950, "PORDER DE/EM TERCEIROS - TÉCNICA"       , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()              , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM116.PRW", oFont21)
   oPrint:Say( _nLin, 0950, "PERÍODO DE " + Dtoc(cdInicial) + " A " + Dtoc(cDfinal), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20
  
   oPrint:Say( _nLin, 1400, "FL"        , oFont21)  
   oPrint:Say( _nLin, 1500, "T"         , oFont21)  
   oPrint:Say( _nLin, 1600, "DOCUMENTO" , oFont21)  
   oPrint:Say( _nLin, 1800, "DATA"      , oFont21)  
   oPrint:Say( _nLin, 2050, "ETIQUETA"  , oFont21)  
   oPrint:Say( _nLin, 2250, "P.VENDA"   , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 50

Return .T.

// Função que soma linhas para impressão
Static Function SomaDemo(nLinhas, cRelSerie, cRelNomeC, cRelNomeP)

   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECRIS(cRelSerie, cRelNomeC, cRelNomeP)
   Endif
   
Return .T.