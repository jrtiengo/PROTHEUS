#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM165.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/04/2013                                                          *
// Objetivo..: Relatório de Faturamento por Grupo/Produto - AST                    *
//**********************************************************************************

// Função que define a Window
User Function AUTOM165()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	  := {}
   Local _aAlias  	  := {}
   Local cSql         := ""
   Local cNomeProduto := ""
   Local cProduto     := Space(30)
// Local nUsuario     := RETCODUSR()

   // Variáveis Private da Função
   Private dData01    := Ctod("  /  /    ")
   Private dData02    := Ctod("  /  /    ")
   Private __Empresa  := ""
   Private aComboBx1  := {}
   Private aComboBx2  := {"ANALÍTICO", "SINTÉTICO"}
   Private aComboBx3  := {}
   Private aComboBx4  := {"VIDEO" , "E-MAIL"}
   Private aComboBx5  := {"NORMAL", "COMO SCHEDULE"}
   Private aComboBx6  := {"1 - INDIVIDUAL", "2 - CONSOLIDADO"}
   Private cEnderecos := Space(200)         

   Private nGet1	 := Ctod("  /  /    ")
   Private nGet2	 := Ctod("  /  /    ")
   Private nGet3	 := Space(30)
   Private nGet4	 := Space(200)
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   Private cComboBx6

   U_AUTOM628("AUTOM165")

   // Carrega o Combo de Filiais
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   __Empresa := SM0->M0_CODIGO

   Do Case
      Case __Empresa == "01"
           aComboBx1  := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS"}
      Case __Empresa == "02"
           aComboBx1  := {"01 - TI CURITIBA"}
      Case __Empresa == "03"
           aComboBx1  := {"01 - ATECH"}
   EndCase

   // Diálogo Principal
   Private oDlg

   Private lWorkflow := ( dDataBase == Nil )

   If lWorkflow

      If Select("SX6") > 0
         RESET ENVIRONMENT
      ENDIF

      PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'
   Endif

   // Carrega o combo de grupos de produtos
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM010")
   cSql += " WHERE BM_GRUPO = '0410'"
   cSql += " ORDER BY BM_GRUPO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   T_GRUPO->( DbGoTop() )

   While !T_GRUPO->( EOF() )
      aAdd( aComboBx3, Alltrim(T_GRUPO->BM_GRUPO) + " - " + Alltrim(T_GRUPO->BM_DESC) )
      T_GRUPO->( DBSKIP() )
   Enddo

   // Variáveis que definem a Ação do Formulário

   DEFINE MSDIALOG oDlg TITLE "Faturamento por Grupo/Produto" FROM C(178),C(181) TO C(520),C(550) PIXEL

   // Solicita o nº da etiqueta a ser impressa
   @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(005) Say "Grupo:       " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(005) Say "Produto:     " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(100) Say cNomeProduto    Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(005) Say "Filial:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(085),C(005) Say "Tipo:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(085),C(095) Say "Totalizador:"  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(100),C(005) Say "Visualização:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(115),C(005) Say "Execusão:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(127),C(005) Say "Enviar e-mail para os seguintes endereços (Separe os endereços com ;)" Size C(150),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(009),C(035) MsGet oGet1 Var dData01            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(023),C(035) MsGet oGet2 Var dData02            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(040),C(035) ComboBox cComboBx3 Items aComboBx3 Size C(140),C(010) PIXEL OF oDlg
   @ C(055),C(035) MsGet oGet3 Var cProduto           Size C(055),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNomeProd(cProduto) )
   @ C(070),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(140),C(010) PIXEL OF oDlg
   @ C(085),C(035) ComboBox cComboBx2 Items aComboBx2 Size C(055),C(010) PIXEL OF oDlg
   @ C(085),C(120) ComboBox cComboBx6 Items aComboBx6 When Alltrim(cCombobx2) == "SINTÉTICO" Size C(055),C(010) PIXEL OF oDlg
   @ C(100),C(035) ComboBox cComboBx4 Items aComboBx4 Size C(140),C(010) PIXEL OF oDlg
   @ C(115),C(035) ComboBox cComboBx5 Items aComboBx5 Size C(140),C(010) PIXEL OF oDlg
   @ C(138),C(005) MsGet oGet4 Var cEnderecos when Alltrim(cComboBx4) == "E-MAIL" Size C(175),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   DEFINE SBUTTON FROM C(155),C(132) TYPE  6 ENABLE OF oDlg ACTION( I_FATUPER( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cProduto, cComboBx4 ))
   DEFINE SBUTTON FROM C(155),C(155) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

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
Static Function I_FATUPER( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cProduto, cComboBx4)

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
   Private xComboBx4
   Private xComboBx5
   
   xComboBx1 := cComboBx1
   xComboBx2 := cComboBx2
   xComboBx3 := Substr(cComboBx3,01,04)
   xComboBx4 := cComboBx4   
   xComboBx5 := cComboBx5   
   
   // Caso usuário selecionou "COMO SCHEDULE", alerta antes da execusão
   If Alltrim(Upper(xComboBx5)) == "COMO SCHEDULE"
      If !MsgYesNo("Atenção! Você selecionou a opção de execusão do relatório COMO SCHEDULE. Isso fará com que o relatório seja enviado via e-mail a Direção da Empresa. Deseja continuar?")
         Return .T.
      Endif
   Endif

   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

   If Alltrim(xComboBx4) == "E-MAIL"
      If Empty(Alltrim(cEnderecos))
         MsgAlert("Endereços de envio de e-mail não informados.")
         Return .T.
      Endif
   Endif   

   // Verifica se o campo produto foi preenchido. Se foi, verifica se o produto informado pertence ao grupo 0410
   If !Empty(Alltrim(cProduto))

      If Select("T_PERTENCE") > 0
         T_PERTENCE->( dbCloseArea() )
      EndIf

      csql = ""
      csql += "SELECT B1_GRUPO "
      csql += "  FROM " + RetSqlName("SB1")
      cSql += " WHERE B1_COD = '" + Alltrim(cProduto) + "'"
      cSql += "   AND D_E_L_E_T_ = ''

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PERTENCE", .T., .T. )

      If T_PERTENCE->B1_GRUPO <> "0410"
         MsgAlert("Atenção! Produto informado não pertence ao grupo 0410 - SERV ASSISTÊNCIA TÉCNICA")
         Return(.T.)
      Endif
         
   Endif

   // Pesquisa as devoluções ref. ao período informado
   If Select("T_DEVOLUCAO") > 0
      T_DEVOLUCAO->( dbCloseArea() )
   EndIf

   csql = ""
   csql += "SELECT A.D1_FILIAL  ,"
   csql += "       A.D1_TOTAL   ,"
   csql += "       A.D1_EMISSAO ,"
   csql += "       A.D1_NFORI   ,"
   csql += "       A.D1_SERIORI ," 
   csql += "       A.D1_ITEMORI ,"
   cSql += "       A.D1_COD     ,"
   cSql += "       C.B1_GRUPO   ,"
// cSql += "       D.F2_EMISSAO ,"
   cSql += "       A.D1_TES      "
   csql += "  FROM " + RetSqlName("SD1010") + " A, "
   cSql += "       " + RetSqlName("SF4010") + " B, "
   cSql += "       " + RetSqlName("SB1010") + " C  "
// cSql += "       " + RetSqlName("SF2010") + " D  "
   cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
   cSql += "   AND A.D1_COD       = C.B1_COD "

   If _Filial <> "00"
     cSql += " AND A.D1_FILIAL = '" + Alltrim(_Filial) + "'" 
   Endif

   cSql += "   AND C.B1_GRUPO     = '" + Alltrim(xComboBx3) + "'"
   csql += "   AND A.D1_NFORI    <> ''"
   csql += "   AND A.R_E_C_D_E_L_ = ''"
// cSql += "   AND A.D1_SERIORI   = D.F2_SERIE"
// cSql += "   AND A.D1_NFORI     = D.F2_DOC  "
   cSql += "   AND A.D1_TES       = B.F4_CODIGO "
   cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

   T_DEVOLUCAO->( DbGoTop() )

   While !T_DEVOLUCAO->( EOF() )
//   If Substr(T_DEVOLUCAO->F2_EMISSAO,01,06) == Substr(Dtoc(dData01),07,04) + Substr(Dtoc(dData01),04,02)
        aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,;
                            T_DEVOLUCAO->D1_TOTAL  ,;
                            T_DEVOLUCAO->D1_EMISSAO,;
                            T_DEVOLUCAO->D1_NFORI  ,;
                            T_DEVOLUCAO->D1_SERIORI,;
                            T_DEVOLUCAO->D1_ITEMORI,;
                            .F.                    ,;
                            ""                     ,;
                            T_DEVOLUCAO->D1_COD    ,;
                            T_DEVOLUCAO->B1_GRUPO  ,;
                            T_DEVOLUCAO->D1_TES    })
//   Endif                            
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
   cSql += "       G.F4_ISS    , " + chr(13)
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
   cSql += "   AND (G.F4_DUPLIC   = 'S' OR A.D2_TES = '543')" + chr(13)
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

   // Envia para a função que imprime o relatório
   If lWorkflow
      IPRODUTOSG(Cabec1,Cabec2,Titulo,nLin)
   Else   
      Processa( {|| IPRODUTOSG(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Gerando Relatório",.F.)
   Endif

Return .T.

// Função que gera o relatório
Static Function IPRODUTOSG(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
   Local nContar   := 0
   Local xDeve     := 0
   Local lExiste   := .F.
   Local nPoa      := 0
   Local nCxs      := 0
   Local nPel      := 0
   Local nTot      := 0
   Local xPoa      := 0
   Local xCxs      := 0
   Local xPel      := 0
   Local xTot      := 0

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private aConsulta := {}

   If Alltrim(xComboBx2) == "ANALÍTICO"
      Private nLimvert := 2000
   Else
      Private nLimvert := 3000      
   Endif

   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   If Alltrim(xComboBx2) == "ANALÍTICO"
      oPrint:SetLandScape() // Para Paisagem
   Else   
     oPrint:SetPortrait()    // Para Retrato
   Endif
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
      _nLin    := 10
      
      ProcRegua( Len(aPesquisa) )

      // Envia para a função que imprime o cabeçalho do relatório
      CABECAPRO(cEmpFil, cGrupo, cMaterial)

      While !Resultado->( EOF() )

         If Alltrim(Resultado->D2_FILIAL) == Alltrim(cEmpFil)

            If Alltrim(Resultado->BM_GRUPO) == Alltrim(cGrupo)

               If Alltrim(Resultado->B1_COD) == Alltrim(cMaterial)

                  // Impressão dos dados
                  oPrint:Say( _nLin, 0100, Resultado->D2_TES, oFont21)
                  oPrint:Say( _nLin, 0180, Substr(Resultado->D2_CF,01,01) + "." + Substr(Alltrim(Resultado->D2_CF),02,03), oFont21)
                  oPrint:Say( _nLin, 0290, Substr(Resultado->D2_EMISSAO,07,02) + "/" + Substr(Resultado->D2_EMISSAO,05,02) + "/" + Substr(Resultado->D2_EMISSAO,01,04), oFont21)
                  oPrint:Say( _nLin, 0480, Substr(Resultado->D2_DOC,01,06), oFont21)
                  oPrint:Say( _nLin, 0600, Resultado->D2_PEDIDO, oFont21)
                  oPrint:Say( _nLin, 0715, IIF(Alltrim(Resultado->D2_TES) == "543", "EXT", "INT"), oFont21)
                  oPrint:Say( _nLin, 0820, Substr(Resultado->A1_NOME,01,30), oFont21)
                  oPrint:Say( _nLin, 1330, Substr(Resultado->A1_MUN,01,27), oFont21)
                  oPrint:Say( _nLin, 1770, Resultado->A1_EST, oFont21)
                  oPrint:Say( _nLin, 1850, Str(Resultado->D2_QUANT,10,02), oFont21)
                  oPrint:Say( _nLin, 2050, Resultado->D2_UM, oFont21)

                  If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
                     nValPro := 0
                     nValSer := Resultado->D2_TOTAL
                  Else
                     nValPro := Resultado->D2_TOTAL
                     nValSer := 0
                  Endif
               
                  nValFre := Resultado->D2_VALFRE
                  nValTot := nValPro + nValSer + nValFre 
               
                  oPrint:Say( _nLin, 2160, Str(nValPro,12,02), oFont21)
                  oPrint:Say( _nLin, 2380, Str(nValSer,12,02), oFont21)
                  oPrint:Say( _nLin, 2650, Str(nValFre,12,02), oFont21)

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

                  oPrint:Say( _nLin, 2860, Str(nDevolucao,12,02), oFont21)
                  oPrint:Say( _nLin, 3090, Str((nValTot - nDevolucao),12,02), oFont21)                              
                  
                  If Alltrim(Resultado->D2_TES) <> "543"
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

                  SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

                  Resultado->( DbSkip() )

                  Loop
            
               Else

                  SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

                  // Totaliza o Produto
                  oPrint:Say( _nLin, 1330, "Total Produtos Internos:", oFont21)
                  oPrint:Say( _nLin, 1850, Str(nQuaPInte,12,02), oFont21)
                  oPrint:Say( _nLin, 2160, Str(nProPInte,12,02), oFont21)
                  oPrint:Say( _nLin, 2380, Str(nSerPInte,12,02), oFont21)
                  oPrint:Say( _nLin, 2650, Str(nFrePInte,12,02), oFont21)
                  oPrint:Say( _nLin, 2860, Str(nDevPInte,12,02), oFont21)

                  SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

                  // Pesquisa Outras Devoluções na Data
                  nDevolucao := 0
                  For nDevolve = 1 to Len(aDevolucao)
                      If aDevolucao[nDevolve,09] == cMaterial
                         If aDevolucao[nDevolve,07] == .F.
                            nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                         Endif
                      Endif
                  Next nDevolve

                  oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
                  oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
                  oPrint:Say( _nLin, 3090, Str((nTotPInte - nDevolucao),12,02), oFont21)

                  SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

                  oPrint:Say( _nLin, 1330, "Total Produtos Externos:", oFont21)
                  oPrint:Say( _nLin, 1850, Str(nQuaPExte,10,02), oFont21)
                  oPrint:Say( _nLin, 2160, Str(nProPExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2380, Str(nSerPExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2650, Str(nFrePExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2860, Str(nDevPExte,12,02), oFont21)
                  oPrint:Say( _nLin, 3090, Str(nTotPExte,12,02), oFont21)

                  SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

                  oPrint:Say( _nLin, 1330, "Total dos Produtos.....:", oFont21)
                  oPrint:Say( _nLin, 1850, Str(nQuaPInte + nQuaPExte,10,02), oFont21)
                  oPrint:Say( _nLin, 2160, Str(nProPInte + nProPExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2380, Str(nSerPInte + nSerPExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2650, Str(nFrePInte + nFrePExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2860, Str(nDevPInte + nDevPExte,12,02), oFont21)
                  oPrint:Say( _nLin, 3090, Str((nTotPInte + nTotPExte - nDevolucao),12,02), oFont21)

                  SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

                  cMaterial := Resultado->B1_COD                  

                  // Zera os totalizadores dos produtos
                  nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
                  nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

                  oPrint:Say( _nLin, 1330, "PRODUTO: " + Substr(Resultado->B1_COD,01,06),oFont10b)
                  oPrint:Say( _nLin, 1700, "- " + Alltrim(Resultado->B1_DESC) + " " + Alltrim(Resultado->B1_DAUX), oFont10b)

                  SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

               Endif

            Else            

               SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)
            
               // Totaliza o Produto
               oPrint:Say( _nLin, 1330, "Total Produtos Internos:", oFont21)
               oPrint:Say( _nLin, 1850, Str(nQuaPInte,10,02), oFont21)
               oPrint:Say( _nLin, 2160, Str(nProPInte,12,02), oFont21)
               oPrint:Say( _nLin, 2380, Str(nSerPInte,12,02), oFont21)
               oPrint:Say( _nLin, 2650, Str(nFrePInte,12,02), oFont21)
               oPrint:Say( _nLin, 2860, Str(nDevPInte,12,02), oFont21)

               SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

               // Pesquisa Outras Devoluções na Data
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,09] == cMaterial
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                   Endif
               Next nDevolve

               oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
               oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
               oPrint:Say( _nLin, 3090, Str((nTotPInte - nDevolucao),13,02), oFont21)

               SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

               oPrint:Say( _nLin, 1330, "Total Produtos Externos:", oFont21)
               oPrint:Say( _nLin, 1850, Str(nQuaPExte,10,02), oFont21)
               oPrint:Say( _nLin, 2160, Str(nProPExte,12,02), oFont21)
               oPrint:Say( _nLin, 2380, Str(nSerPExte,12,02), oFont21)
               oPrint:Say( _nLin, 2650, Str(nFrePExte,12,02), oFont21)
               oPrint:Say( _nLin, 2860, Str(nDevPExte,12,02), oFont21)
               oPrint:Say( _nLin, 3090, Str(nTotPExte,12,02), oFont21)

               SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

               oPrint:Say( _nLin, 1330, "Total dos Produtos.....:", oFont21)
               oPrint:Say( _nLin, 1850, Str(nQuaPInte + nQuaPExte,10,02), oFont21)
               oPrint:Say( _nLin, 2160, Str(nProPInte + nProPExte,12,02), oFont21)
               oPrint:Say( _nLin, 2380, Str(nSerPInte + nSerPExte,12,02), oFont21)
               oPrint:Say( _nLin, 2650, Str(nFrePInte + nFrePExte,12,02), oFont21)
               oPrint:Say( _nLin, 2860, Str(nDevPInte + nDevPExte,12,02), oFont21)
               oPrint:Say( _nLin, 3090, Str(nTotPInte + nTotPExte - nDevolucao,12,02), oFont21)

               SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

               // Totaliza o Grupo
               oPrint:Say( _nLin, 1330, "Total Grupos Internos..:", oFont21)
               oPrint:Say( _nLin, 1850, Str(nQuaGInte,10,02), oFont21)
               oPrint:Say( _nLin, 2160, Str(nProGInte,12,02), oFont21)
               oPrint:Say( _nLin, 2380, Str(nSerGInte,12,02), oFont21)
               oPrint:Say( _nLin, 2650, Str(nFreGInte,12,02), oFont21)
               oPrint:Say( _nLin, 2860, Str(nDevGInte,12,02), oFont21)

               SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

               // Pesquisa Outras Devoluções na Data
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,10] == cGrupo
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                   Endif
               Next nDevolve

               oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
               oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
               oPrint:Say( _nLin, 3090, Str((nTotGInte - nDevolucao),12,02), oFont21)

               SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

               oPrint:Say( _nLin, 1330, "Total Grupos Externos..:", oFont21)
               oPrint:Say( _nLin, 1850, Str(nQuaGExte,10,02), oFont21)
               oPrint:Say( _nLin, 2160, Str(nProGExte,12,02), oFont21)
               oPrint:Say( _nLin, 2380, Str(nSerGExte,12,02), oFont21)
               oPrint:Say( _nLin, 2650, Str(nFreGExte,12,02), oFont21)
               oPrint:Say( _nLin, 2860, Str(nDevGExte,12,02), oFont21)
               oPrint:Say( _nLin, 3090, Str(nTotGExte,12,02), oFont21)

               SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

               oPrint:Say( _nLin, 1330, "Total do Grupo.........:", oFont21)
               oPrint:Say( _nLin, 1850, Str(nQuaGInte + nQuaGExte,10,02), oFont21)
               oPrint:Say( _nLin, 2160, Str(nProGInte + nProGExte,12,02), oFont21)
               oPrint:Say( _nLin, 2380, Str(nSerGInte + nSerGExte,12,02), oFont21)
               oPrint:Say( _nLin, 2650, Str(nFreGInte + nFreGExte,12,02), oFont21)
               oPrint:Say( _nLin, 2860, Str(nDevGInte + nDevGExte,12,02), oFont21)
               oPrint:Say( _nLin, 3090, Str(nTotGInte + nTotGExte - nDevolucao,12,02), oFont21)

               SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

               cGrupo    := Resultado->BM_GRUPO
               cMaterial := Resultado->B1_COD                  

               // Zera os totalizadores dos produtos
               nQuaPInte := 0; nProPInte := 0; nSerPInte := 0; nFrePInte := 0; nTotPInte := 0; nDevPInte := 0
               nQuaPExte := 0; nProPExte := 0; nSerPExte := 0; nFrePExte := 0; nTotPExte := 0; nDevPExte := 0

               // Totalizadores dos grupos
               nQuaGInte := 0; nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
               nQuaGExte := 0; nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

               oPrint:Say( _nLin, 1330, "GRUPO..: " + Resultado->BM_GRUPO, oFont10b)
               oPrint:Say( _nLin, 1700, "- " + Alltrim(Resultado->BM_DESC), oFont10b)

               SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

            Endif
            
         Else   

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)
               
            // Totaliza o Produto
            oPrint:Say( _nLin, 1330, "Total Produtos Internos:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaPInte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProPInte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerPInte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFrePInte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevPInte,12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,09] == cMaterial
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
            oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str((nTotPInte - nDevolucao),12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "Total Produtos Externos:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaPExte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProPExte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerPExte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFrePExte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevPExte,12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str(nTotPExte,12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "Total dos Produtos.....:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaPInte + nQuaPExte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProPInte + nProPExte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerPInte + nSerPExte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFrePInte + nFrePExte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevPInte + nDevPExte,12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str(nTotPInte + nTotPExte - nDevolucao,13,02), oFont21)

            SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

            // Totaliza o Grupo
            oPrint:Say( _nLin, 1330, "Total Grupos Internos..:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaGInte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProGInte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerGInte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFreGInte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevGInte,12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,10] == cGrupo
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
            oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str((nTotGInte - nDevolucao),12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "Total Grupos Externos..:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaGExte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProGExte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerGExte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFreGExte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevGExte,12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str(nTotGExte,12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "Total do Grupo.........:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaGInte + nQuaGExte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProGInte + nProGExte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerGInte + nSerGExte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFreGInte + nFreGExte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevGInte + nDevGExte,12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str(nTotGInte + nTotGExte,12,02), oFont21)

            SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

            // Totaliza a Filial
            oPrint:Say( _nLin, 1330, "Total Filial Internos..:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaFInte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProFInte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerFInte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFreFInte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevFInte,12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,01] == cEmpFil
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
            oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str((nTotFInte - nDevolucao),12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "Total Filial Externos..:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaFExte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProFExte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerFExte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFreFExte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevFExte,12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str(nTotFExte,12,02), oFont21)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "Total da Filial........:", oFont21)
            oPrint:Say( _nLin, 1850, Str(nQuaFInte + nQuaFExte,10,02), oFont21)
            oPrint:Say( _nLin, 2160, Str(nProFInte + nProFExte,12,02), oFont21)
            oPrint:Say( _nLin, 2380, Str(nSerFInte + nSerFExte,12,02), oFont21)
            oPrint:Say( _nLin, 2650, Str(nFreFInte + nFreFExte,12,02), oFont21)
            oPrint:Say( _nLin, 2860, Str(nDevFInte + nDevFExte,12,02), oFont21)
            oPrint:Say( _nLin, 3090, Str(nTotFInte + nTotFExte - nDevolucao,12,02), oFont21)

            SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)
            oPrint:Line( _nLin, 0100, _nLin, 3350 )
            SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

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
               Case __Empresa == "01"
                    Do Case
                       Case Alltrim(Resultado->D2_FILIAL) == "01"
                            oPrint:Say( _nLin, 1330, "FILIAL.: 01"    , oFont10b)
                            oPrint:Say( _nLin, 1700, "- PORTO ALEGRE" , oFont10b)  
                       Case Alltrim(Resultado->D2_FILIAL) == "02"
                            oPrint:Say( _nLin, 1330, "FILIAL.: 02"    , oFont10b)
                            oPrint:Say( _nLin, 1700, "- CAXIAS DO SUL", oFont10b)  
                       Case Alltrim(Resultado->D2_FILIAL) == "03"
                            oPrint:Say( _nLin, 1330, "FILIAL.: 03"    , oFont10b)  
                            oPrint:Say( _nLin, 1700, "- PELOTAS"      , oFont10b)  
                    EndCase          
               Case __Empresa == "02"
                    oPrint:Say( _nLin, 1330, "FILIAL.: 01"   , oFont10b)
                    oPrint:Say( _nLin, 1700, "- TI CURITIBA" , oFont10b)  
               Case __Empresa == "03"
                    oPrint:Say( _nLin, 1330, "FILIAL.: 01"   , oFont10b)
                    oPrint:Say( _nLin, 1700, "- ATECH" , oFont10b)  
            EndCase                    

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "GRUPO..: " + Resultado->BM_GRUPO, oFont10b)
            oPrint:Say( _nLin, 1700, "- " + Alltrim(Resultado->BM_DESC), oFont10b)

            SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

            oPrint:Say( _nLin, 1330, "PRODUTO: " + Substr(Resultado->B1_COD,01,06),oFont10b)
            oPrint:Say( _nLin, 1700, "- " + Alltrim(Resultado->B1_DESC) + " " + Alltrim(Resultado->B1_DAUX), oFont10b)
 
            SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

         Endif

      Enddo

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      // Totaliza o Produto
      oPrint:Say( _nLin, 1330, "Total Produtos Internos:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaPInte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProPInte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerPInte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFrePInte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevPInte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cMaterial
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
      oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str((nTotPInte - nDevolucao),12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total Produtos Externos:", oFont21)
	  oPrint:Say( _nLin, 1850, Str(nQuaPExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProPExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerPExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFrePExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevPExte,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotPExte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total dos Produtos.....:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaPInte + nQuaPExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProPInte + nProPExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerPInte + nSerPExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFrePInte + nFrePExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevPInte + nFrePExte,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotPInte + nTotPExte - nDevolucao,12,02), oFont21)

      SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

      // Totaliza o Grupo
      oPrint:Say( _nLin, 1330, "Total Grupos Internos..:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaGInte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProGInte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerGInte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreGInte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevGInte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cGrupo
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
      oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str((nTotPInte - nDevolucao),12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total Grupos Externos..:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaGExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProGExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerGExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreGExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevGExte,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotGExte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total do Grupo.........:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaGInte + nQuaGExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProGInte + nProGExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerGInte + nSerGExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreGInte + nFreGExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevGInte + nDevGExte,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotGInte + nTotGExte - nDevolucao,12,02), oFont21)

      SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

      // Totaliza a Filial
      oPrint:Say( _nLin, 1330, "Total Filial Internos..:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaFInte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProFInte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerFInte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreFInte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevFInte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cEmpFil
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
      oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str((nTotFInte - nDevolucao),12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total Filial Externos..:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaFExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProFExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerFExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreFExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevFExte,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotFExte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total da Filial........:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaFInte + nQuaFExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProFInte + nProFExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerFInte + nSerFExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreFInte + nFreFExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevFInte + nDevFExte + nDevolucao,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotFInte + nTotFExte - nDevolucao,12,02), oFont21)

      SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)
      oPrint:Line( _nLin, 1330, _nLin, 3350 )
      SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

      // Totaliza o Acumulado
      oPrint:Say( _nLin, 1330, "Total Pedidos Internos.:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaAInte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProAInte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerAInte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreAInte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevAInte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      oPrint:Say( _nLin, 1330, "Total Outras Devoluções:", oFont21)
      oPrint:Say( _nLin, 2860, Str((nDevolucao),12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str((nTotAInte - nDevolucao),12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total Pedidos Externos.:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaAExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProAExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerAExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreAExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevAExte,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotAExte,12,02), oFont21)

      SomaLinhaPro(50,cEmpFil, cGrupo, cMaterial)

      oPrint:Say( _nLin, 1330, "Total do Período.......:", oFont21)
      oPrint:Say( _nLin, 1850, Str(nQuaAInte + nQuaAExte,10,02), oFont21)
      oPrint:Say( _nLin, 2160, Str(nProAInte + nProAExte,12,02), oFont21)
      oPrint:Say( _nLin, 2380, Str(nSerAInte + nSerAExte,12,02), oFont21)
      oPrint:Say( _nLin, 2650, Str(nFreAInte + nFreAExte,12,02), oFont21)
      oPrint:Say( _nLin, 2860, Str(nDevAInte + nDevAExte + nDevolucao,12,02), oFont21)
      oPrint:Say( _nLin, 3090, Str(nTotAInte + nTotAExte - nDevolucao,12,02), oFont21)

      SomaLinhaPro(100,cEmpFil, cGrupo, cMaterial)

   Else

      // SINTÉTICO - com totalizador individual
      If Substr(cComboBx6,01,01) == "1"
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

         nPagina := 0
         _nLin   := 10 
                   
         CABECAPSIN(cEmpFil, cGrupo)

         While !Resultado->( EOF() )

            If Alltrim(Resultado->D2_FILIAL) == Alltrim(cEmpFil)
       
               If Alltrim(Resultado->BM_GRUPO) == Alltrim(cGrupo)

                  // Acumula os Valores da Data para Impressão
                  If Alltrim(Resultado->D2_TES) <> "543"

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

                     If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
                        nSerInte := nSerInte  + Resultado->D2_TOTAL
                     Else
                        nProInte := nProInte  + Resultado->D2_TOTAL
                     Endif

                     nFreInte  := nFreInte + Resultado->D2_VALFRE

                     nTotInte  := nProInte + nSerInte + nFreInte - nDevInte

                     // Totalizador da Filial
                     nQuaAInte  := nQuaAInte  + Resultado->D2_QUANT

                     If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
                        nSerAInte := nSerAInte  + Resultado->D2_TOTAL
                     Else
                        nProAInte := nProAInte  + Resultado->D2_TOTAL
                     Endif

                     nFreAInte  := nFreAInte + Resultado->D2_VALFRE
                     nDevAInte  := nDevAInte + nDevolucao
                     nTotAInte  := nProAInte + nSerAInte + nFreAInte

                     // Totalizador do Período
                     nQuaGInte  := nQuaGInte  + Resultado->D2_QUANT

                     If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
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

                     If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
                        nSerExte := nSerExte  + Resultado->D2_TOTAL
                     Else
                        nProExte := nProExte  + Resultado->D2_TOTAL
                     Endif

                     nFreExte  := nFreExte + Resultado->D2_VALFRE

                     nTotExte  := nProExte + nSerExte + nFreExte - nDevExte

                     // Totalizador da Filial
                     nQuaAExte := nQuaAExte  + Resultado->D2_QUANT

                     If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
                        nSerAExte := nSerAExte  + Resultado->D2_TOTAL
                     Else
                        nProAExte := nProAExte  + Resultado->D2_TOTAL
                     Endif

                     nFreAExte  := nFreAExte + Resultado->D2_VALFRE
                     nDevAExte  := nDevAExte + nDevolucao
                     nTotAExte  := nProAExte + nSerAExte + nFreAExte

                     // Totalizador do Período
                     nQuaGExte := nQuaGExte  + Resultado->D2_QUANT

                     If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
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

                  __Grupo := Padr(nGrupo,51)


//                oPrint:Say( _nLin, 0100, Substr(nGrupo,01,17), oFont21)
                  oPrint:Say( _nLin, 0100, Alltrim(Substr(__Grupo,01,17)), oFont21)
                  oPrint:Say( _nLin, 0510, "INTERNOS"          , oFont21)
                  oPrint:Say( _nLin, 0650, Str(nQuaInte,05)    , oFont21)
                  oPrint:Say( _nLin, 0820, Str(nProInte,12,02) , oFont21)
                  oPrint:Say( _nLin, 1170, Str(nSerInte,12,02) , oFont21)
                  oPrint:Say( _nLin, 1520, Str(nFreInte,12,02) , oFont21)
                  oPrint:Say( _nLin, 1870, Str(nDevInte,12,02) , oFont21)
                  oPrint:Say( _nLin, 2110, Str(nTotInte,12,02) , oFont21)

                  SLPSin(50,cEmpFil, cGrupo)

                  oPrint:Say( _nLin, 0100, Alltrim(Substr(__Grupo,18,17)), oFont21)
                  oPrint:Say( _nLin, 0510, "EXTERNOS"         , oFont21)
                  oPrint:Say( _nLin, 0650, Str(nQuaExte,05)   , oFont21)
                  oPrint:Say( _nLin, 0820, Str(nProExte,12,02), oFont21)
                  oPrint:Say( _nLin, 1170, Str(nSerExte,12,02), oFont21)
                  oPrint:Say( _nLin, 1520, Str(nFreExte,12,02), oFont21)
                  oPrint:Say( _nLin, 1870, Str(nDevExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2110, Str(nTotExte,12,02), oFont21)
               
                  SLPSin(50,cEmpFil, cGrupo)

                  oPrint:Say( _nLin, 0100, Alltrim(Substr(__Grupo,35,17)), oFont21)
                  oPrint:Say( _nLin, 0510, "TOTAL"                       , oFont21)
                  oPrint:Say( _nLin, 0650, Str(nQuaInte + nQuaExte,05)   , oFont21)
                  oPrint:Say( _nLin, 0820, Str(nProInte + nProExte,12,02), oFont21)
                  oPrint:Say( _nLin, 1170, Str(nSerInte + nSerExte,12,02), oFont21)
                  oPrint:Say( _nLin, 1520, Str(nFreInte + nFreExte,12,02), oFont21)
                  oPrint:Say( _nLin, 1870, Str(nDevInte + nDevExte,12,02), oFont21)
                  oPrint:Say( _nLin, 2110, Str(nTotInte + nTotExte,12,02), oFont21)

                  SLPSin(100,cEmpFil, cGrupo)

                  nQuaInte := 0; nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
                  nQuaExte := 0; nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

                  cGrupo := Resultado->BM_GRUPO
                  nGrupo := Resultado->BM_DESC

                  Loop

               Endif
         
            Else            

               // Totaliza a última data
               oPrint:Say( _nLin, 0100, Substr(nGrupo,01,17), oFont21)
               oPrint:Say( _nLin, 0510, "INTERNOS"          , oFont21)
               oPrint:Say( _nLin, 0650, Str(nQuaInte,05)    , oFont21)
               oPrint:Say( _nLin, 0820, Str(nProInte,12,02) , oFont21)
               oPrint:Say( _nLin, 1170, Str(nSerInte,12,02) , oFont21)
               oPrint:Say( _nLin, 1520, Str(nFreInte,12,02) , oFont21)                                   
               oPrint:Say( _nLin, 1870, Str(nDevInte,12,02) , oFont21)                         
               oPrint:Say( _nLin, 2110, Str(nTotInte,12,02) , oFont21)               

               SLPSin(50,cEmpFil, cGrupo)

               oPrint:Say( _nLin, 0510, "EXTERNOS"         , oFont21)
               oPrint:Say( _nLin, 0650, Str(nQuaExte,05)   , oFont21)
               oPrint:Say( _nLin, 0820, Str(nProExte,12,02), oFont21)
               oPrint:Say( _nLin, 1170, Str(nSerExte,12,02), oFont21)
               oPrint:Say( _nLin, 1520, Str(nFreExte,12,02), oFont21)
               oPrint:Say( _nLin, 1870, Str(nDevExte,12,02), oFont21)
               oPrint:Say( _nLin, 2110, Str(nTotExte,12,02), oFont21)
               
               SLPSin(50,cEmpFil, cGrupo)

               oPrint:Say( _nLin, 0510, "TOTAL"                       , oFont21)
               oPrint:Say( _nLin, 0650, Str(nQuaInte + nQuaExte,05)   , oFont21)
               oPrint:Say( _nLin, 0820, Str(nProInte + nProExte,12,02), oFont21)
               oPrint:Say( _nLin, 1170, Str(nSerInte + nSerExte,12,02), oFont21)
               oPrint:Say( _nLin, 1520, Str(nFreInte + nFreExte,12,02), oFont21)
               oPrint:Say( _nLin, 1870, Str(nDevInte + nDevExte,12,02), oFont21)
               oPrint:Say( _nLin, 2110, Str(nTotInte + nTotExte,12,02), oFont21)

               SLPSin(100,cEmpFil, cGrupo)

               // Totaliza a Filial
               oPrint:Say( _nLin, 0100, "TOTAL DA FILIAL"   , oFont21)
               oPrint:Say( _nLin, 0510, "INTERNOS"          , oFont21)
               oPrint:Say( _nLin, 0650, Str(nQuaAInte,05)   , oFont21)
               oPrint:Say( _nLin, 0820, Str(nProAInte,12,02), oFont21)
               oPrint:Say( _nLin, 1170, Str(nSerAInte,12,02), oFont21)
               oPrint:Say( _nLin, 1520, Str(nFreAInte,12,02), oFont21)
               oPrint:Say( _nLin, 1870, Str(nDevAInte,12,02), oFont21)

               SLPSin(50,cEmpFil, cGrupo)

               // Verifica se existe devolução para a nota fiscal selecionada
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
               Next nDevolve

               oPrint:Say( _nLin, 0510, "O.DEVOL."                       , oFont21)
               oPrint:Say( _nLin, 1870, Str(nDevolucao,10,02)            , oFont21)
               oPrint:Say( _nLin, 2110, Str(nTotAInte - nDevolucao,12,02), oFont21)

               SLPSin(50,cEmpFil, cGrupo)

               oPrint:Say( _nLin, 0510, "EXTERNOS"          , oFont21)
               oPrint:Say( _nLin, 0650, Str(nQuaAExte,05)   , oFont21)
               oPrint:Say( _nLin, 0820, Str(nProAExte,12,02), oFont21)
               oPrint:Say( _nLin, 1170, Str(nSerAExte,12,02), oFont21)
               oPrint:Say( _nLin, 1520, Str(nFreAExte,12,02), oFont21)
               oPrint:Say( _nLin, 1870, Str(nDevAExte,12,02), oFont21)
               oPrint:Say( _nLin, 2110, Str(nTotAExte,12,02), oFont21)
               
               SLPSin(50,cEmpFil, cGrupo)

               oPrint:Say( _nLin, 0510, "TOTAL"                         , oFont21)
               oPrint:Say( _nLin, 0650, Str(nQuaAInte + nQuaAExte,05)   , oFont21)
               oPrint:Say( _nLin, 0820, Str(nProAInte + nProAExte,12,02), oFont21)
               oPrint:Say( _nLin, 1170, Str(nSerAInte + nSerAExte,12,02), oFont21)
               oPrint:Say( _nLin, 1520, Str(nFreAInte + nFreAExte,12,02), oFont21)
               oPrint:Say( _nLin, 1870, Str(nDevAInte + nDevAExte,12,02), oFont21)
               oPrint:Say( _nLin, 2110, Str(nTotAInte + nTotAExte,12,02), oFont21)

               SLPSin(100,cEmpFil, cGrupo)
               oPrint:Line( _nLin, 0450, _nLin, 2400 )   
               SLPSin(100,cEmpFil, cGrupo)

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
                  Case __Empresa == "01"
                       Do Case
                          Case Alltrim(cEmpFil) == "01"
                               oPrint:Say( _nLin, 0950, "FILIAL: 01 - PORTO ALEGRE", oFont10b)
                          Case Alltrim(cEmpFil) == "02"
                               oPrint:Say( _nLin, 0950, "FILIAL: 02 - CAXIAS DO SUL", oFont10b)
                          Case Alltrim(cEmpFil) == "03"
                               oPrint:Say( _nLin, 0950, "FILIAL: 03 - PELOTAS", oFont10b)
                       EndCase        
                  Case __Empresa == "02"
                       oPrint:Say( _nLin, 0950, "FILIAL: 01 - TI CURITIBA", oFont10b)
                  Case __Empresa == "03"
                       oPrint:Say( _nLin, 0950, "FILIAL: 01 - ATECH", oFont10b)
               EndCase

               SLPSin(100,cEmpFil, cGrupo)

            Endif

         Enddo

         // Totaliza a última data
         oPrint:Say( _nLin, 0100, Substr(cGrupo,01,17), oFont21)
         oPrint:Say( _nLin, 0510, "INTERNOS"          , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaInte,05)    , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProInte,12,02) , oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerInte,12,02) , oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreInte,12,02) , oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevInte,12,02) , oFont21)

         SLPSin(50,cEmpFil, cGrupo)

         // Verifica se existe devolução para a nota fiscal selecionada
         nDevolucao := 0
         For nDevolve = 1 to Len(aDevolucao)
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
         Next nDevolve

         oPrint:Say( _nLin, 0510, "O.DEVOL."                      , oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevolucao,12,02)           , oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotInte - nDevolucao,12,02), oFont21)                                             

         SLPSin(50,cEmpFil, cGrupo)

         oPrint:Say( _nLin, 0510, "EXTERNOS"         , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaExte,05)   , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProExte,12,02), oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerExte,12,02), oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreExte,12,02), oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevExte,12,02), oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotExte,12,02), oFont21)

         SLPSin(50,cEmpFil, cGrupo)               

         oPrint:Say( _nLin, 0510, "TOTAL"                       , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaInte + nQuaExte,05)   , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProInte + nProExte,12,02), oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerInte + nSerExte,12,02), oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreInte + nFreExte,12,02), oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevInte + nDevExte,12,02), oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotInte + nTotExte,12,02), oFont21)

         SLPSin(100,cEmpFil, cGrupo)               
      
         // Totaliza a Filial
         oPrint:Say( _nLin, 0100, "TOTAL DA FILIAL"   , oFont21)
         oPrint:Say( _nLin, 0510, "INTERNOS"          , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaAInte,05)   , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProAInte,12,02), oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerAInte,12,02), oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreAInte,12,02), oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevAInte,12,02), oFont21)

         SLPSin(50,cEmpFil, cGrupo)               

         // Verifica se existe devolução para a nota fiscal selecionada
         nDevolucao := 0
         For nDevolve = 1 to Len(aDevolucao)
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
         Next nDevolve

         oPrint:Say( _nLin, 0510, "O.DEVOL."                                   , oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevolucao,12,02)                        , oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotAInte - nDevAInte - nDevolucao,12,02), oFont21)

         SLPSin(50,cEmpFil, cGrupo)               

         oPrint:Say( _nLin, 0510, "EXTERNOS"          , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaAExte,05)   , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProAExte,12,02), oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerAExte,12,02), oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreAExte,12,02), oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevAExte,12,02), oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotAExte,12,02), oFont21)
               
         SLPSin(50,cEmpFil, cGrupo)               

         oPrint:Say( _nLin, 0510, "TOTAL"                                                  , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaAInte + nQuaAExte,05)                            , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProAInte + nProAExte,12,02)                         , oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerAInte + nSerAExte,12,02)                         , oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreAInte + nFreAExte,12,02)                         , oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevAInte + nDevAExte + nDevolucao,12,02)            , oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotAInte + nTotAExte - nDevAInte - nDevolucao,12,02), oFont21)

         SLPSin(100,cEmpFil, cGrupo)               
         oPrint:Line( _nLin, 0450, _nLin, 2400 )
         SLPSin(100,cEmpFil, cGrupo)               

         // Totaliza o Período
         oPrint:Say( _nLin, 0100, "TOTAL DO PERÍODO"  , oFont21)
         oPrint:Say( _nLin, 0510, "INTERNOS"          , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaGInte,05)   , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProGInte,12,02), oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerGInte,12,02), oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreGInte,12,02), oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevGInte,12,02), oFont21)

         SLPSin(50,cEmpFil, cGrupo)               

         // Verifica se existe devolução para a nota fiscal selecionada
         nDevolucao := 0
         For nDevolve = 1 to Len(aDevolucao)
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
         Next nDevolve

         oPrint:Say( _nLin, 0510, "O.DEVOL."                       , oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevolucao,12,02)            , oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotGInte - nDevolucao,12,02), oFont21)

         SLPSin(50,cEmpFil, cGrupo)               

         oPrint:Say( _nLin, 0510, "EXTERNOS"          , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaGExte,05)   , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProGExte,12,02), oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerGExte,12,02), oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreGExte,12,02), oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevGExte,12,02), oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotGExte,12,02), oFont21)

         SLPSin(50,cEmpFil, cGrupo)               

         oPrint:Say( _nLin, 0510, "TOTAL"                                      , oFont21)
         oPrint:Say( _nLin, 0650, Str(nQuaGInte + nQuaGExte,05)                , oFont21)
         oPrint:Say( _nLin, 0820, Str(nProGInte + nProGExte,12,02)             , oFont21)
         oPrint:Say( _nLin, 1170, Str(nSerGInte + nSerGExte,12,02)             , oFont21)
         oPrint:Say( _nLin, 1520, Str(nFreGInte + nFreGExte,12,02)             , oFont21)
         oPrint:Say( _nLin, 1870, Str(nDevGInte + nDevGExte + nDevolucao,12,02), oFont21)
         oPrint:Say( _nLin, 2110, Str(nTotGInte + nTotGExte - nDevolucao,12,02), oFont21)

      Else
      
         // Limpa o Array aConsulta
         aConsulta := {}
         
         RESULTADO->( DbGoTop() )

         // Internos
         aAdd( aConsulta, { RESULTADO->BM_GRUPO, RESULTADO->BM_DESC , "INTERNOS", 0, 0, 0,0 } )          

         // Externos
         aAdd( aConsulta, { RESULTADO->BM_GRUPO, RESULTADO->BM_DESC , "EXTERNOS", 0, 0, 0,0 } )          

         WHILE !RESULTADO->( EOF() )

            // Pesquisa no array aConsulta se já existe elemento para o grupo posicionado
            lExiste := .F.
            For nContar = 1 to Len(aConsulta)
                If Alltrim(aConsulta[nContar,01]) == Alltrim(RESULTADO->BM_GRUPO)
                   If RESULTADO->D2_TES == "543"
                      If Alltrim(aConsulta[nContar,03]) == "EXTERNOS"
                         lExiste := .T.
                         Exit
                      Endif
                   Else
                      If Alltrim(aConsulta[nContar,03]) == "INTERNOS"
                         lExiste := .T.
                         Exit
                      Endif
                   Endif
                Endif
            Next nContar
            
            // Se não Existe, cria os dois elementos para o grupo (Internos e Externos)
            If !lExiste
               // Internos
               aAdd( aConsulta, { RESULTADO->BM_GRUPO, ;
                                  RESULTADO->BM_DESC , ;
                                  "INTERNOS"         , ;
                                  0                  , ;
                                  0                  , ;
                                  0                  , ;
                                  0 } )          
               // Externos
               aAdd( aConsulta, { RESULTADO->BM_GRUPO, ;
                                  RESULTADO->BM_DESC , ;
                                  "EXTERNOS"         , ;
                                  0                  , ;
                                  0                  , ;
                                  0                  , ;
                                  0 } )          
            
               Loop
            
            Else
            
               Do Case
                  Case RESULTADO->D2_FILIAL == "01" // Porto Alegre
                       aConsulta[nContar,04] := aConsulta[nContar,04] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                  Case RESULTADO->D2_FILIAL == "02" // Caxias do Sul
                       aConsulta[nContar,05] := aConsulta[nContar,05] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                  Case RESULTADO->D2_FILIAL == "03" // Pelotas
                       aConsulta[nContar,06] := aConsulta[nContar,06] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
               EndCase         
            
            Endif
            
            RESULTADO->( DbSkip() )
            
         ENDDO   
      
         // Trata as Devoluções
         For xDeve = 1 to Len(aDevolucao)
             // Localiza o elemento do array aConsulta para descontar o valor da Devolução
             For nContar = 1 to Len(aConsulta)
                 If Alltrim(aConsulta[nContar,01]) == Alltrim(aDevolucao[xDeve,10])
                    If aDevolucao[xDeve,11] == "543"
                       If Alltrim(aConsulta[nContar,03]) == "EXTERNOS"
                          Do Case
                             Case aDevolucao[xDeve,01] == "01"
                                  aConsulta[nContar,04] := aConsulta[nContar,04] - aDevolucao[xDeve,02]
                             Case aDevolucao[xDeve,01] == "02"
                                  aConsulta[nContar,05] := aConsulta[nContar,05] - aDevolucao[xDeve,02]
                             Case aDevolucao[xDeve,01] == "03"
                                  aConsulta[nContar,06] := aConsulta[nContar,06] - aDevolucao[xDeve,02]
                          EndCase
                          Exit
                       Endif
                    Else
                       If Alltrim(aConsulta[nContar,03]) == "INTERNOS"
                          Do Case
                             Case aDevolucao[xDeve,01] == "01"
                                  aConsulta[nContar,04] := aConsulta[nContar,04] - aDevolucao[xDeve,02]
                             Case aDevolucao[xDeve,01] == "02"
                                  aConsulta[nContar,05] := aConsulta[nContar,05] - aDevolucao[xDeve,02]
                             Case aDevolucao[xDeve,01] == "03"
                                  aConsulta[nContar,06] := aConsulta[nContar,06] - aDevolucao[xDeve,02]
                          EndCase
                          Exit
                       Endif
                    Endif
                 Endif
             Next nContar       
         Next xDeve     

         // Atualiza os Totais dos elementos
         For nContar = 1 to Len(aconsulta)
             aConsulta[nContar,07] := aConsulta[nContar,04] + aConsulta[nContar,05] + aConsulta[nContar,06]
         Next nContar
         
         // Imprime o Relatório
         nPagina := 0
         _nLin   := 10 

         nPoa := 0
         nCxs := 0
         nPel := 0
         nTot := 0
                   
         // Imprime o Cabeçalho do Relatóio
         CABECAXXX()
        
         nQuebra := 0

         For nContar = 1 to Len(aConsulta)

             If aConsulta[nContar,03] == "INTERNOS"
                oPrint:Say( _nLin, 0100, aConsulta[nContar,01], oFont21)
                oPrint:Say( _nLin, 0180, aConsulta[nContar,02], oFont21)
             Endif   

             oPrint:Say( _nLin, 0820, aConsulta[nContar,03], oFont21)
             oPrint:Say( _nLin, 1200, TRANSFORM(aConsulta[nContar,04], "@E 999,999,999.99"), oFont21)
             oPrint:Say( _nLin, 1500, TRANSFORM(aConsulta[nContar,05], "@E 999,999,999.99"), oFont21)
             oPrint:Say( _nLin, 1800, TRANSFORM(aConsulta[nContar,06], "@E 999,999,999.99"), oFont21)
             oPrint:Say( _nLin, 2050, TRANSFORM(aConsulta[nContar,07], "@E 999,999,999.99"), oFont21)

             nPoa := nPoa + aConsulta[nContar,04]
             nCxs := nCxs + aConsulta[nContar,05]
             nPel := nPel + aConsulta[nContar,06]             
             nTot := nTot + aConsulta[nContar,07]             

             xPoa := xPoa + aConsulta[nContar,04]
             xCxs := xCxs + aConsulta[nContar,05]
             xPel := xPel + aConsulta[nContar,06]             
             xTot := xTot + aConsulta[nContar,07]             

             SomaXXX(50)
          
             nQuebra := nQuebra + 1

             If nQuebra == 2
                oPrint:Say( _nLin, 0820, "TOTAL", oFont21)
                oPrint:Say( _nLin, 1200, TRANSFORM(nPoa, "@E 999,999,999.99"), oFont21)
                oPrint:Say( _nLin, 1500, TRANSFORM(nCxs, "@E 999,999,999.99"), oFont21)
                oPrint:Say( _nLin, 1800, TRANSFORM(nPel, "@E 999,999,999.99"), oFont21)
                oPrint:Say( _nLin, 2050, TRANSFORM(nTot, "@E 999,999,999.99"), oFont21)

                nPoa := 0
                nCxs := 0
                nPel := 0
                nTot := 0

                SomaXXX(100)

                nQuebra := 0

             Endif
         
         Next nContar
                  
         SomaXXX(100)

         oPrint:Say( _nLin, 0820, "TOTAL DO PERÍODO", oFont21)
         oPrint:Say( _nLin, 1200, TRANSFORM(xPoa, "@E 999,999,999.99"), oFont21)
         oPrint:Say( _nLin, 1500, TRANSFORM(xCxs, "@E 999,999,999.99"), oFont21)
         oPrint:Say( _nLin, 1800, TRANSFORM(xPel, "@E 999,999,999.99"), oFont21)
         oPrint:Say( _nLin, 2050, TRANSFORM(xTot, "@E 999,999,999.99"), oFont21)
                                              
      Endif
      
   Endif

   oPrint:EndPage()

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

   // Envia o relatório via e-mail
   If !lWorkflow

      If Alltrim(cComboBx4) == "E-MAIL"

         // Gera Array com a quantidade de páginas a serem salvas em HTML
         For xContar = 1 to nPagina
             Aadd( aPaginas, xContar )
         Next xContar    

         // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
         If File("\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Ferase("\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
         Endif

         cFileHTML := "\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

         // Salva o relatório em HTML
         oPrint:SaveAsHtml(cFileHTML, aPaginas )

         // Envia o relatório via e-mail
         cErroEnvio := U_AUTOMR20("Em anexo, segue Relação de Faturamento por Produto referente ao período de " + ;
                                  Dtoc(dData01) + " a " + Dtoc(dData02)                                         , ;
                                  Alltrim(cEnderecos)                                                           , ;
                                  cFileHTML                                                                     , ;
                                  "Relaçao de Faturamento por Produto referente ao período de "                 + ;
                                  Dtoc(dData01) + " a " + Dtoc(dData02))

      Else

         If Alltrim(Upper(xComboBx5)) == "NORMAL"
         
            oPrint:Preview()
            
         Else

            // Gera Array com a quantidade de páginas a serem salvas em HTML
            For xContar = 1 to nPagina
                Aadd( aPaginas, xContar )
            Next xContar    

            // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
            If File("\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Ferase("\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Endif

            cFileHTML := "\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

            // Salva o relatório em HTML
            oPrint:SaveAsHtml(cFileHTML, aPaginas )

            // Envia o relatório via e-mail
            cErroEnvio := U_AUTOMR20("Em anexo, segue Relação de Faturamento por Produto referente ao período de " + ;
                                     Dtoc(dData01) + " a " + Dtoc(dData02)                                         , ;
                                     "roger@automatech.com.br;evandro@automatech.com.br"                           , ;
                                     cFileHTML                                                                     , ;
                                     "Relaçao de Faturamento por Produto referente ao período de "                 + ;
                                     Dtoc(dData01) + " a " + Dtoc(dData02))
         Endif
   
      Endif   

   Else
   
      // Gera Array com a quantidade de páginas a serem salvas em HTML
      For xContar = 1 to nPagina
          Aadd( aPaginas, xContar )
      Next xContar    

      // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
      If File("\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
         Ferase("\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
      Endif

      cFileHTML := "\TREPORT\FAT-PRODUTO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

      // Salva o relatório em HTML
      oPrint:SaveAsHtml(cFileHTML, aPaginas )

      // Envia o relatório via e-mail
      cErroEnvio := U_AUTOMR20("Em anexo, segue Relação de Faturamento por Produto referente ao período de " + ;
                               Dtoc(dData01) + " a " + Dtoc(dData02)                                         , ;
                               "roger@automatech.com.br;evandro@automatech.com.br"                           , ;
                               cFileHTML                                                                     , ;
                               "Relaçao de Faturamento por Produto referente ao período de "                 + ;
                               Dtoc(dData01) + " a " + Dtoc(dData02))
   
   Endif

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por VendedorGrupo de Produtos
Static Function CABECAPRO(xFilial, xGrupo, xProduto)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "FATURAMENTO POR GRUPO DE PRODUTOS"    , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR18", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "TES"                   , oFont21)  
   oPrint:Say( _nLin, 0180, "CFOP"                  , oFont21)  
   oPrint:Say( _nLin, 0290, "DATA"                  , oFont21)  
   oPrint:Say( _nLin, 0480, "NF"                    , oFont21)  
// oPrint:Say( _nLin, 0540, "SER"                   , oFont21)  
   oPrint:Say( _nLin, 0600, "NR.PV"                 , oFont21)  
   oPrint:Say( _nLin, 0715, "TIPO"                  , oFont21)  
   oPrint:Say( _nLin, 0820, "DESCRIÇÃO DOS CLIENTES", oFont21)  
   oPrint:Say( _nLin, 1330, "CIDADE"                , oFont21)  
   oPrint:Say( _nLin, 1770, "UF"                    , oFont21)  
   oPrint:Say( _nLin, 1930, "QTD"                   , oFont21)  
   oPrint:Say( _nLin, 2050, "UND"                   , oFont21)  
   oPrint:Say( _nLin, 2170, "VLR PRODUTO"           , oFont21)  
   oPrint:Say( _nLin, 2390, "VLR SERVICO"           , oFont21)  
   oPrint:Say( _nLin, 2690, "VLR FRETE"             , oFont21)  
   oPrint:Say( _nLin, 2900, "DEVOLUÇÃO"             , oFont21)  
   oPrint:Say( _nLin, 3140, "VLR TOTAL"             , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

   Do Case
      Case __Empresa == "01"
           Do Case
              Case Alltrim(Resultado->D2_FILIAL) == "01"
                   oPrint:Say( _nLin, 1330, "FILIAL.: 01"    , oFont10b)
                   oPrint:Say( _nLin, 1700, "- PORTO ALEGRE" , oFont10b)  
              Case Alltrim(Resultado->D2_FILIAL) == "02"
                   oPrint:Say( _nLin, 1330, "FILIAL.: 02"    , oFont10b)
                   oPrint:Say( _nLin, 1700, "- CAXIAS DO SUL", oFont10b)  
              Case Alltrim(Resultado->D2_FILIAL) == "03"
                   oPrint:Say( _nLin, 1330, "FILIAL.: 03"    , oFont10b)  
                   oPrint:Say( _nLin, 1700, "- PELOTAS"      , oFont10b)  
           EndCase        
      Case __Empresa == "02"
           oPrint:Say( _nLin, 1330, "FILIAL.: 01"   , oFont10b)
           oPrint:Say( _nLin, 1700, "- TI CURITIBA" , oFont10b)  
      Case __Empresa == "03"
           oPrint:Say( _nLin, 1330, "FILIAL.: 01"   , oFont10b)
           oPrint:Say( _nLin, 1700, "- ATECH" , oFont10b)  
   EndCase 
           
   _nLin += 50

   oPrint:Say( _nLin, 1330, "GRUPO..: " + Resultado->BM_GRUPO, oFont10b)
   oPrint:Say( _nLin, 1700, "- " + Alltrim(Resultado->BM_DESC), oFont10b)
   _nLin += 50
   oPrint:Say( _nLin, 1330, "PRODUTO: " + Substr(Resultado->B1_COD,01,06),oFont10b)
   oPrint:Say( _nLin, 1700, "- " + Alltrim(Resultado->B1_DESC) + " " + Alltrim(Resultado->B1_DAUX), oFont10b)

   _nLin += 100

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaPro(nLinhas,cEmpFil, cGrupo, cMaterial)   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAPRO(cEmpFil, cGrupo, cMaterial)
   Endif
   
Return .T.      

// Imprime o cabeçalho do relatório de Faturamento por período Sintético
Static Function CABECAPSIN(cEmpFil, cGrupo)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"          , oFont21)
   oPrint:Say( _nLin, 0950, "FATURAMENTO POR GRUPO DE PRODUTOS - SINTÉTICO"  , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()                      , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR18.PRW", oFont21)
   oPrint:Say( _nLin, 0950, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20
  
   oPrint:Say( _nLin, 0100, "DESCRIÇÃO DOS GRUPOS", oFont21)  
   oPrint:Say( _nLin, 0510, "TIPO"                , oFont21)  
   oPrint:Say( _nLin, 0700, "QTD"                 , oFont21)  
   oPrint:Say( _nLin, 0790, "VALOR PRODUTOS"      , oFont21)  
   oPrint:Say( _nLin, 1140, "VALOR SERVIÇOS"      , oFont21)  
   oPrint:Say( _nLin, 1490, "VALOR DO FRETE"      , oFont21)  
   oPrint:Say( _nLin, 1840, "VLR DEVOLUÇÕES"      , oFont21)  
   oPrint:Say( _nLin, 2130, "VALOR TOTAL"         , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 50

   Do Case
      Case __Empresa == "01"
           Do Case
              Case Alltrim(cEmpFil) == "01"
                   oPrint:Say( _nLin, 0950, "FILIAL: 01 - PORTO ALEGRE", oFont10b)
              Case Alltrim(cEmpFil) == "02"
                   oPrint:Say( _nLin, 0950, "FILIAL: 02 - CAXIAS DO SUL", oFont10b)
              Case Alltrim(cEmpFil) == "03"
                   oPrint:Say( _nLin, 0950, "FILIAL: 03 - PELOTAS", oFont10b)
           EndCase        
      Case __Empresa == "02"
           oPrint:Say( _nLin, 0950, "FILIAL: 01 - TI CURITIBA", oFont10b)
      Case __Empresa == "03"
           oPrint:Say( _nLin, 0950, "FILIAL: 01 - ATECH", oFont10b)
   EndCase           

   _nLin += 60

Return .T.

// Função que soma linhas para impressão do relatório de faturamento por período sintético
Static Function SLPSin(nLinhas,cEmpFil, cGrupo)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAPSIN(cEmpFil, cGrupo)
   Endif
   
Return .T.

// Imprime o cabeçalho do relatório de Faturamento por período Sintético Consolidado
Static Function CABECAXXX()

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"                      , oFont21)
   oPrint:Say( _nLin, 0950, "FATURAMENTO - GRUPO DE PRODUTOS - SINTÉTICO - CONSOLIDADO"  , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()                                  , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR18.PRW", oFont21)
   oPrint:Say( _nLin, 0950, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20
  
   oPrint:Say( _nLin, 0100, "GRUPO"               , oFont21)  
   oPrint:Say( _nLin, 0180, "DESCRIÇÃO DOS GRUPOS", oFont21)  
   oPrint:Say( _nLin, 0820, "TIPO"                , oFont21)  
   oPrint:Say( _nLin, 1225, "PORTO ALEGRE"        , oFont21)  
   oPrint:Say( _nLin, 1515, "CAXIAS DO SUL"       , oFont21)  
   oPrint:Say( _nLin, 1885, "PELOTAS"             , oFont21)  
   oPrint:Say( _nLin, 2160, "TOTAL"               , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 60

Return .T.

// Função que soma linhas para impressão do relatório de faturamento por período sintético
Static Function SomaXXX(nLinhas)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAXXX()
   Endif
   
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