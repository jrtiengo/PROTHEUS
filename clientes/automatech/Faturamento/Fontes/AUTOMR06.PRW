#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR06.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/08/2011                                                          *
// Objetivo..: Vendas por Vendedor - Quebra por Vendedor/Cliente	               *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR06()
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private dData01       := Ctod("  /  /    ")
   Private dData02       := Ctod("  /  /    ")
   Private cVendedor     := Space(06)
   Private cNomeVendedor := Space(30)
   Private nVias         := 1
   Private nGet1	     := Ctod("  /  /    ")
   Private nGet2	     := Ctod("  /  /    ")
   Private nGet3	     := Space(06)
   Private nGet4         := Space(100)
   Private cRetorno      := Space(500)

   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTOMR06")

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg TITLE "Vendas por Vendedor - Analítico por Cliente" FROM C(178),C(181) TO C(340),C(550) PIXEL

   // Solicita o nº da etiqueta a ser impressa
   @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(005) Say "Vendedor  :  " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(075) Say cNomeVendedor   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(009),C(035) MsGet oGet1 Var dData01   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(023),C(035) MsGet oGet2 Var dData02   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(038),C(035) MsGet oGet3 Var cVendedor F3("SA3") Size C(035),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( BuscaVend(cVendedor) )

   DEFINE SBUTTON FROM C(60),C(155) TYPE  6 ENABLE OF oDlg ACTION( I_VENDAS02( dData01, dData02, cVendedor))
   DEFINE SBUTTON FROM C(60),C(132) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que pesquisa o vendedor informado
Static Function BuscaVend(cVendedor)

   Local cSql := ""
   
   If Empty(Alltrim(cVendedor))
      cNomeVendedor := ""
      Return .T.
   Endif
   
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_NOME "
   cSql += "  FROM " + RetSqlName("SA3010")
   cSql += " WHERE A3_COD = '" + Alltrim(cVendedor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If !T_VENDEDOR->( Eof() )
      cNomeVendedor := T_VENDEDOR->A3_NOME
   Else
      cNomeVendedor := ""
   Endif

Return .T.         

// Função que prepara a impressão do relatório
Static Function I_VENDAS02( dData01, dData02, cVendedor)

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

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""
   Private limite       := 220
   Private tamanho      := "G"
   Private nomeprog     := "Faturamento-Vendedor"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Faturamento-Vendedor"
   Private cString      := "SC5"

   Private aDevolucao   := {}
   Private nDevolve     := 0

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
   csql += "SELECT A.D1_FILIAL  ,"
   csql += "       A.D1_TOTAL   ,"
   csql += "       A.D1_EMISSAO ,"
   csql += "       A.D1_NFORI   ,"
   csql += "       A.D1_SERIORI ," 
   csql += "       A.D1_ITEMORI ,"
   cSql += "       A.D1_COD      " 
   csql += "  FROM " + RetSqlName("SD1010") + " A, "
   cSql += "       " + RetSqlName("SF4010") + " B  "
   cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)

//   If _Filial <> "00"
//     cSql += " AND A.D1_FILIAL = '" + Alltrim(_Filial) + "'" 
//   Endif

   csql += "   AND A.D1_NFORI    <> ''"
   csql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.D1_TES       = B.F4_CODIGO "
   cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "

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
                         T_DEVOLUCAO->D1_COD } )
     T_DEVOLUCAO->( DbSkip() )
   Enddo

   // Pesquisa os dados para emissão do relatório
   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.D2_FILIAL , "
   cSql += "       B.F2_VEND1  , "
   cSql += "       B.F2_VEND2  , "
   cSql += "       B.F2_VEND3  , "
   cSql += "       B.F2_VEND4  , "
   cSql += "       B.F2_VEND5  , "        
   cSql += "       A.D2_DOC    , "
   cSql += "       A.D2_SERIE  , "
   cSql += "       A.D2_EMISSAO, "
   cSql += "       A.D2_TES    , "
   cSql += "       G.F4_DUPLIC , "
   cSql += "       A.D2_CF     , "
   cSql += "       A.D2_PEDIDO , "
   cSql += "       F.C5_FRETE  , "
   cSql += "       A.D2_CLIENTE, "
   cSql += "       A.D2_LOJA   , "
   cSql += "       C.A1_NOME   , "
   cSql += "       A.D2_ITEM   , "
   cSql += "       A.D2_COD    , "
   cSql += "       D.B1_DESC   , "
   cSql += "       D.B1_DAUX   , "
   cSql += "       A.D2_UM     , "
   cSql += "       A.D2_QUANT  , "
   cSql += "       A.D2_TOTAL  , "
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

   If !Empty(cVendedor)
      cSql += " AND (B.F2_VEND1 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR B.F2_VEND2 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR B.F2_VEND3 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR B.F2_VEND4 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR B.F2_VEND5 = '" + Alltrim(cVendedor) + "')"                   
   Endif

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
   RptStatus({|| RunReport(Cabec1,Cabec2,cVendedor,nLin) },Titulo)

Return .T.

// Função que gera o relatório
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor := ""
   Local cCliente  := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
   Local nPagina   := 0
   Local aPesquisa := {}
   Local _Vendedor := ""

   // Carrega o Array aPesquisa com os dados dos 5 possíveis vendedores
   Resultado->( DbGoTop() )
   While !Resultado->( EOF() )

       For nContar = 1 to 5
           
           Do Case
              Case nContar = 1
                   If Empty(Resultado->F2_vend1)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend1) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend1
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado->F2_Vend1
                      Endif
                   Endif

              Case nContar = 2
                   If Empty(Resultado->F2_vend2)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend2) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend2
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado->F2_Vend2
                      Endif
                   Endif

              Case nContar = 3
                   If Empty(Resultado->F2_vend3)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend3) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend3
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado-F2_Vend3
                      Endif
                   Endif

              Case nContar = 4
                   If Empty(Resultado->F2_vend4)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend4) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend4
                         Else
                            Loop
                         Endif
                      Else
                         xvendedor := Resultado-F2_Vend4
                      Endif
                   Endif

              Case nContar = 5
                   If Empty(Resultado->F2_vend5)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend5) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend5
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado-F2_Vend5
                      Endif
                   Endif

           EndCase
                         
           // Pesquisa o Nome do Vendedor
           If Select("T_VENDEDOR") > 0
              T_VENDEDOR->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT A3_NOME "
           cSql += "  FROM " + RetSqlName("SA3010")
           cSql += " WHERE A3_COD = '" + Alltrim(xVendedor) + "'"

           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

           If !T_VENDEDOR->( Eof() )
              cNomeVendedor := T_VENDEDOR->A3_NOME
           Else
              cNomeVendedor := ""
           Endif

           T_VENDEDOR->( dbCloseArea() )

           // Verifica se existe devolução para a nota fiscal selecionada
           nDevolucao := 0
           For nDevolve = 1 to Len(aDevolucao)
               If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(Resultado->D2_DOC,01,06)) .And. ;
                  Alltrim(aDevolucao[nDevolve,05]) == Alltrim(Resultado->D2_SERIE)             .And. ;
                  Alltrim(aDevolucao[nDevolve,01]) == Alltrim(Resultado->D2_FILIAL)            .And. ;
                  Alltrim(aDevolucao[nDevolve,06]) == Alltrim(Resultado->D2_ITEM)              .And. ;
                  Alltrim(aDevolucao[nDevolve,09]) == Alltrim(Resultado->D2_COD) 
                  aDevolucao[nDevolve,07] := .T.
                  nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
               Endif
           Next nDevolve

           // Carrega o Array
           aPesq := {Resultado->D2_FILIAL ,; // 01
                     xVendedor            ,; // 02
                     cNomeVendedor        ,; // 03
                     Resultado->D2_DOC    ,; // 04
                     Resultado->D2_SERIE  ,; // 05
                     Resultado->D2_EMISSAO,; // 06
                     Resultado->D2_TES    ,; // 07
                     Resultado->F4_DUPLIC ,; // 08
                     Resultado->D2_CF     ,; // 09
                     Resultado->D2_PEDIDO ,; // 10
                     Resultado->C5_FRETE  ,; // 11
                     Resultado->D2_CLIENTE,; // 12
                     Resultado->D2_LOJA   ,; // 13
                     Resultado->A1_NOME   ,; // 14
                     Resultado->D2_ITEM   ,; // 15
                     Resultado->D2_COD    ,; // 16
                     Resultado->B1_DESC   ,; // 17
                     Resultado->B1_DAUX   ,; // 18
                     Resultado->D2_UM     ,; // 19
                     Resultado->D2_QUANT  ,; // 20
                     Resultado->D2_TOTAL  ,; // 21
                     Resultado->D2_VALFRE ,; // 22
                     Resultado->C5_FORNEXT,; // 23
                     nDevolucao}             // 24
       
    	   aAdd( aPesquisa, aPesq )
       
       Next nContar
       
       Resultado->( DbSkip() )
       
   Enddo

   // Pesquisa as vendas sem vendedores
   If Empty(titulo)

      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.D2_FILIAL , "
      cSql += "       B.F2_VEND1  , "
      cSql += "       B.F2_VEND2  , "
      cSql += "       B.F2_VEND3  , "
      cSql += "       B.F2_VEND4  , "
      cSql += "       B.F2_VEND5  , "        
      cSql += "       A.D2_DOC    , "
      cSql += "       A.D2_SERIE  , "
      cSql += "       A.D2_EMISSAO, "
      cSql += "       A.D2_TES    , "
      cSql += "       G.F4_DUPLIC , "
      cSql += "       A.D2_CF     , "
      cSql += "       A.D2_PEDIDO , "
      cSql += "       F.C5_FRETE  , "
      cSql += "       A.D2_CLIENTE, "
      cSql += "       A.D2_LOJA   , "
      cSql += "       C.A1_NOME   , "
      cSql += "       A.D2_ITEM   , "
      cSql += "       A.D2_COD    , "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "       A.D2_UM     , "
      cSql += "       A.D2_QUANT  , "
      cSql += "       A.D2_TOTAL  , "
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
      cSql += "   AND (B.F2_VEND1 = '' AND B.F2_VEND2 = '' AND B.F2_VEND3 = '' AND B.F2_VEND4 = '' AND B.F2_VEND5 = '')"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

      RESULTADO->( DbGoTop() )

      While !Resultado->( EOF() )

           // Verifica se existe devolução para a nota fiscal selecionada
           nDevolucao := 0
           For nDevolve = 1 to Len(aDevolucao)
               If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(Resultado->D2_DOC,01,06)) .And. ;
                  Alltrim(aDevolucao[nDevolve,05]) == Alltrim(Resultado->D2_SERIE)             .And. ;
                  Alltrim(aDevolucao[nDevolve,01]) == Alltrim(Resultado->D2_FILIAL)            .And. ;
                  Alltrim(aDevolucao[nDevolve,06]) == Alltrim(Resultado->D2_ITEM)              .And. ;
                  Alltrim(aDevolucao[nDevolve,09]) == Alltrim(Resultado->D2_COD) 
                  aDevolucao[nDevolve,07] := .T.
                  nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
               Endif
           Next nDevolve

           // Carrega o Array
           aPesq := {Resultado->D2_FILIAL ,; // 01
                     "999999"             ,; // 02
                     "VENDAS SEM VENDEDOR",; // 03
                     Resultado->D2_DOC    ,; // 04
                     Resultado->D2_SERIE  ,; // 05
                     Resultado->D2_EMISSAO,; // 06
                     Resultado->D2_TES    ,; // 07
                     Resultado->F4_DUPLIC ,; // 08
                     Resultado->D2_CF     ,; // 09
                     Resultado->D2_PEDIDO ,; // 10
                     Resultado->C5_FRETE  ,; // 11
                     Resultado->D2_CLIENTE,; // 12
                     Resultado->D2_LOJA   ,; // 13
                     Resultado->A1_NOME   ,; // 14
                     Resultado->D2_ITEM   ,; // 15
                     Resultado->D2_COD    ,; // 16
                     Resultado->B1_DESC   ,; // 17
                     Resultado->B1_DAUX   ,; // 18
                     Resultado->D2_UM     ,; // 19
                     Resultado->D2_QUANT  ,; // 20
                     Resultado->D2_TOTAL  ,; // 21
                     Resultado->D2_VALFRE ,; // 22
                     Resultado->C5_FORNEXT,; // 23
                     nDevolucao}             // 24
       
    	   aAdd( aPesquisa, aPesq )
       
           Resultado->( DbSkip() )
       
      Enddo
      
   Endif

   // Ordena o Array para Impressão
   ASORT(aPesquisa,,,{ | x,y | x[3] + x[14] < y[3] + y[14] } )
   
   cVendedor := aPesquisa[01,03]
   cCliente  := aPesquisa[01,14]

   // Acumuladores
   nVende01I := 0
   nVende02I := 0
   nVende03I := 0
   nDevol01I := 0
   nVende04I := 0   

   nVende01E := 0
   nVende02E := 0
   nVende03E := 0
   nDevol01E := 0
   nVende04E := 0   

   nClien01 := 0
   nClien02 := 0
   nClien03 := 0
   nClien04 := 0      
   nClien05 := 0      

   nAcumu01I := 0
   nAcumu02I := 0
   nAcumu03I := 0
   nAcumu04I := 0      
   nAcDev01I := 0

   nAcumu01E := 0
   nAcumu02E := 0
   nAcumu03E := 0
   nAcumu04E := 0      
   nAcDev01E := 0

   nPagina  := 0

   For nContar = 1 to Len(aPesquisa)
   
      If Alltrim(aPesquisa[nContar,3]) == Alltrim(cVendedor)

         If Alltrim(aPesquisa[nContar,14]) == Alltrim(cCliente)

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
               @ nLin,084 PSAY "RELAÇÃO DE VENDAS POR VENDEDOR"
               @ nLin,180 PSAY dtoc(DATE()) + " - " + TIME()
               nLin := nLin + 1
               @ nLin,001 PSAY "AUTOMR06.PRW"
               @ nLin,084 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
               @ nLin,180 PSAY "PÁGINA:"
               @ nLin,195 PSAY Strzero(nPagina,6)
               nLin = nLin + 1
               @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               nLin := nLin + 1
               @ nLin,001 PSAY "FL  TES  CFOP   NF      DT.EMISSAO   NR.PV  TIPO    DESCRICAO DOS PRODUTOS                                               QTD   UM    VLR PRODUTO   VLR SERVICO     VLR FRETE     DEVOLUÇÃO     VLR TOTAL"
               nLin := nLin + 1
               @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               nLin := nLin + 2
               @ nLin,061 PSAY "VENDEDOR: " + Alltrim(aPesquisa[nContar,03])
               nLin = nLin + 2
               @ nLin,061 PSAY "CLIENTE.: " + Alltrim(aPesquisa[nContar,14])
               nLin = nLin + 2
            Endif

            // Prepara o valor dos produtos e serviços a serem impressos
            If Substr(aPesquisa[nContar,17],01,03) == "AST"
               nProduto := 0
               nServico := aPesquisa[nContar,21]
            Else
               nProduto := aPesquisa[nContar,21]
               nServico := 0
            Endif

            // Impressão dos dados
            @ nLin,001 PSAY aPesquisa[nContar,01]
            @ nLin,005 PSAY Substr(aPesquisa[nContar,07],01,03)
            @ nLin,010 PSAY Substr(aPesquisa[nContar,09],01,01) + "." + Substr(aPesquisa[nContar,09],02,03)
            @ nLin,017 PSAY Substr(aPesquisa[nContar,04],01,06)
            @ nLin,025 PSAY Substr(aPesquisa[nContar,06],07,02) + "/" + Substr(aPesquisa[nContar,06],05,02) + "/" + Substr(aPesquisa[nContar,06],01,04)
            @ nLin,037 PSAY aPesquisa[nContar,10]

            If Empty(Alltrim(aPesquisa[nContar,23]))
               @ nLin,045 PSAY "INTERNO"
            Else
               @ nLin,045 PSAY "EXTERNO"
            Endif

//          @ nLin,053 PSAY Substr(aPesquisa[nContar,16],01,06)
            @ nLin,053 PSAY Substr(Alltrim(aPesquisa[nContar,17]) + " " + Alltrim(aPesquisa[nContar,18]),01,60)
            @ nLin,115 PSAY Str(aPesquisa[nContar,20],10,02)
            @ nLin,128 PSAY aPesquisa[nContar,19]
            @ nLin,133 PSAY nProduto                                                                PICTURE "@E 9,999,999.99" 
            @ nLin,147 PSAY nServico                                                                PICTURE "@E 9,999,999.99" 
            @ nLin,161 PSAY aPesquisa[nContar,22]                                                   PICTURE "@E 9,999,999.99"             
            @ nLin,175 PSAY aPesquisa[nContar,24]                                                   PICTURE "@E 9,999,999.99"             
            @ nLin,189 PSAY (aPesquisa[nContar,21] + aPesquisa[nContar,22] - aPesquisa[nContar,24]) PICTURE "@E 9,999,999.99"             

            nLin = nLin + 1

            If Empty(Alltrim(aPesquisa[nContar,23]))            

               nVende01I := nVende01I + nProduto 
               nVende02I := nVende02I + nServico
               nVende03I := nVende03I + aPesquisa[nContar,22]
               nVende04I := nvende04I + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
               nDevol01I := nDevol01I + aPesquisa[nContar,24]

               nAcumu01I := nAcumu01I + nProduto 
               nAcumu02I := nAcumu02I + nServico
               nAcumu03I := nAcumu03I + aPesquisa[nContar,22]
               nAcumu04I := nAcumu04I + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
               nAcDev01I := nAcDev01I + aPesquisa[nContar,24]

            Else

               nVende01E := nVende01E + nProduto 
               nVende02E := nVende02E + nServico
               nVende03E := nVende03E + aPesquisa[nContar,22]
               nVende04E := nvende04E + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
               nDevol01E := nDevol01E + aPesquisa[nContar,24]
               
               nAcumu01E := nAcumu01E + nProduto 
               nAcumu02E := nAcumu02E + nServico
               nAcumu03E := nAcumu03E + aPesquisa[nContar,22]
               nAcumu04E := nAcumu04E + nProduto + nServico + aPesquisa[nContar,22]  - aPesquisa[nContar,24]
               nAcDev01E := nAcDev01E + aPesquisa[nContar,24]

            Endif               

            nClien01 := nClien01 + nProduto 
            nClien02 := nClien02 + nServico
            nClien03 := nClien03 + aPesquisa[nContar,22]
            nClien04 := nClien04 + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
            nClien05 := nClien05 + aPesquisa[nContar,24]

            Loop
            
         Else

            nLin = nLin + 1
            
                                                                                                       
            @ nLin,104 PSAY "TOTAL DO CLIENTE............:"
            @ nLin,133 PSAY nClien01 picture "@E 9,999,999.99"
            @ nLin,147 PSAY nClien02 picture "@E 9,999,999.99"
            @ nLin,161 PSAY nClien03 picture "@E 9,999,999.99"
            @ nLin,175 PSAY nClien05 picture "@E 9,999,999.99"
            @ nLin,189 PSAY nClien04 picture "@E 9,999,999.99"                        
            
            nClien01 := 0
            nClien02 := 0
            nClien03 := 0
            nClien04 := 0
            nClien05 := 0

            cCliente := aPesquisa[nContar,14]

            nLin = nLin + 2
            
            @ nLin,061 PSAY "CLIENTE.: " + Alltrim(aPesquisa[nContar,14])

            nLin = nLin + 2

            nContar := nContar - 1

         Endif
         
      Else            
      
         nLin = nLin + 2
            
         @ nLin,104 PSAY "TOTAL DO CLIENTE............:"
         @ nLin,133 PSAY nClien01 picture "@E 9,999,999.99"
         @ nLin,147 PSAY nClien02 picture "@E 9,999,999.99"
         @ nLin,161 PSAY nClien03 picture "@E 9,999,999.99"
         @ nLin,175 PSAY nClien05 picture "@E 9,999,999.99"
         @ nLin,189 PSAY nClien04 picture "@E 9,999,999.99"                        

         nLin = nLin + 2

         @ nLin,104 PSAY "TOTAL DO VENDEDOR - INTERNAS:"
         @ nLin,133 PSAY nVende01I picture "@E 9,999,999.99"
         @ nLin,147 PSAY nVende02I picture "@E 9,999,999.99"
         @ nLin,161 PSAY nVende03I picture "@E 9,999,999.99"
         @ nLin,175 PSAY nDevol01I picture "@E 9,999,999.99"
         @ nLin,189 PSAY nVende04I picture "@E 9,999,999.99"                        

         nLin = nLin + 1

         @ nLin,104 PSAY "TOTAL DO VENDEDOR - EXTERNAS:"
         @ nLin,133 PSAY nVende01E picture "@E 9,999,999.99"
         @ nLin,147 PSAY nVende02E picture "@E 9,999,999.99"
         @ nLin,161 PSAY nVende03E picture "@E 9,999,999.99"
         @ nLin,175 PSAY nDevol01E picture "@E 9,999,999.99"
         @ nLin,189 PSAY nVende04E picture "@E 9,999,999.99"                        
            
         nLin = nLin + 1

         @ nLin,104 PSAY "TOTAL GERAL DO VENDEDOR.....:"
         @ nLin,133 PSAY nVende01I + nVende01E picture "@E 9,999,999.99"
         @ nLin,147 PSAY nVende02I + nVende02E picture "@E 9,999,999.99"
         @ nLin,161 PSAY nVende03I + nVende03E picture "@E 9,999,999.99"
         @ nLin,175 PSAY nDevol01I + nDevol01E picture "@E 9,999,999.99"     
         @ nLin,189 PSAY nVende04I + nVende04E picture "@E 9,999,999.99"                        

         nVende01I := 0
         nVende02I := 0
         nVende03I := 0
         nVende04I := 0
         nDevol01I := 0

         nVende01E := 0
         nVende02E := 0
         nVende03E := 0
         nVende04E := 0
         nDevol01E := 0

         nClien01 := 0
         nClien02 := 0
         nClien03 := 0
         nClien04 := 0
         nClien05 := 0

         cVendedor := aPesquisa[nContar,03]
         cCliente  := aPesquisa[nContar,14]

         EJECT

         // Impressao do cabecalho do relatorio
         nPagina := nPagina + 1
         nLin    := 1
         @ nLin,001 PSAY "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
         @ nLin,084 PSAY "RELAÇÃO DE VENDAS POR VENDEDOR"
         @ nLin,180 PSAY dtoc(DATE()) + " - " + TIME()
         nLin := nLin + 1
         @ nLin,001 PSAY "AUTOMR06.PRW"
         @ nLin,084 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
         @ nLin,180 PSAY "PÁGINA:"
         @ nLin,195 PSAY Strzero(nPagina,6)
         nLin = nLin + 1
         @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         nLin := nLin + 1
         @ nLin,001 PSAY "FL  TES  CFOP   NF      DT.EMISSAO   NR.PV  TIPO    DESCRICAO DOS PRODUTOS                                               QTD   UM    VLR PRODUTO   VLR SERVICO     VLR FRETE     DEVOLUÇÃO     VLR TOTAL"
         nLin := nLin + 1
         @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         nLin := nLin + 2
         @ nLin,061 PSAY "VENDEDOR: " + Alltrim(aPesquisa[nContar,03])
         nLin = nLin + 2
         @ nLin,061 PSAY "CLIENTE.: " + Alltrim(aPesquisa[nContar,14])
         nLin = nLin + 2

         nContar := nContar - 1

      Endif

   Next nContar

   nLin = nLin + 2

   @ nLin,104 PSAY "TOTAL DO CLIENTE............:"
   @ nLin,133 PSAY nClien01 picture "@E 9,999,999.99"
   @ nLin,147 PSAY nClien02 picture "@E 9,999,999.99"
   @ nLin,161 PSAY nClien03 picture "@E 9,999,999.99"
   @ nLin,175 PSAY nClien05 picture "@E 9,999,999.99"
   @ nLin,189 PSAY nClien04 picture "@E 9,999,999.99"                        

   nLin = nLin + 2

   @ nLin,104 PSAY "TOTAL DO VENDEDOR - INTERNAS:"
   @ nLin,133 PSAY nVende01I picture "@E 9,999,999.99"
   @ nLin,147 PSAY nVende02I picture "@E 9,999,999.99"
   @ nLin,161 PSAY nVende03I picture "@E 9,999,999.99"
   @ nLin,175 PSAY nDevol01I picture "@E 9,999,999.99"
   @ nLin,189 PSAY nVende04I picture "@E 9,999,999.99"                        

   nLin = nLin + 1

   @ nLin,104 PSAY "TOTAL DO VENDEDOR - EXTERNAS:"
   @ nLin,133 PSAY nVende01E picture "@E 9,999,999.99"
   @ nLin,147 PSAY nVende02E picture "@E 9,999,999.99"
   @ nLin,161 PSAY nVende03E picture "@E 9,999,999.99"
   @ nLin,175 PSAY nDevol01E picture "@E 9,999,999.99"
   @ nLin,189 PSAY nVende04E picture "@E 9,999,999.99"                        

   nLin = nLin + 1

   @ nLin,104 PSAY "TOTAL GERAL DO VENDEDOR.....:"
   @ nLin,133 PSAY nVende01I + nVende01E picture "@E 9,999,999.99"
   @ nLin,147 PSAY nVende02I + nVende02E picture "@E 9,999,999.99"
   @ nLin,161 PSAY nVende03I + nVende03E picture "@E 9,999,999.99"
   @ nLin,175 PSAY nDevol01I + nDevol01E picture "@E 9,999,999.99"
   @ nLin,189 PSAY nVende04I + nVende04E picture "@E 9,999,999.99"                        

   nLin = nLin + 2

   @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

   nLin = nLin + 2

   @ nLin,104 PSAY "TOTAL PERÍODO - PVS INTERNOS:"
   @ nLin,133 PSAY nAcumu01I picture "@E 9,999,999.99"
   @ nLin,147 PSAY nAcumu02I picture "@E 9,999,999.99"
   @ nLin,161 PSAY nAcumu03I picture "@E 9,999,999.99"
   @ nLin,175 PSAY nAcDev01I picture "@E 9,999,999.99"

   If !Empty(Titulo)
      @ nLin,189 PSAY nAcumu04I picture "@E 9,999,999.99"                        
   Endif
   
   nLin = nLin + 1

   // Verifica se existe devolução para a nota fiscal selecionada
   If Empty(Titulo)
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve
   
      @ nLin,104 PSAY "TOTAL OUTRAS DEVOLUÇÕES.....:"
      @ nLin,175 PSAY nDevolucao             picture "@E 9,999,999.99"
      @ nLin,189 PSAY nAcumu04I - nDevolucao picture "@E 9,999,999.99"                        
      nLin = nLin + 1
   Else
      nDevolucao := 0
   Endif

   @ nLin,104 PSAY "TOTAL PERÍODO - PVS EXTERNOS:"
   @ nLin,133 PSAY nAcumu01E picture "@E 9,999,999.99"
   @ nLin,147 PSAY nAcumu02E picture "@E 9,999,999.99"
   @ nLin,161 PSAY nAcumu03E picture "@E 9,999,999.99"
   @ nLin,175 PSAY nAcDev01E picture "@E 9,999,999.99"
   @ nLin,189 PSAY nAcumu04E picture "@E 9,999,999.99"                        

   nLin = nLin + 1

   @ nLin,104 PSAY "TOTAL GERAL DO PERÍODO......:"
   @ nLin,133 PSAY nAcumu01I + nAcumu01E              picture "@E 9,999,999.99"
   @ nLin,147 PSAY nAcumu02I + nAcumu02E              picture "@E 9,999,999.99"
   @ nLin,161 PSAY nAcumu03I + nAcumu03E              picture "@E 9,999,999.99"
   @ nLin,175 PSAY nAcDev01I + nAcDev01E + nDevolucao picture "@E 9,999,999.99"
   @ nLin,189 PSAY nAcumu04I + nAcumu04E - nDevolucao picture "@E 9,999,999.99"                        

   nLin = nLin + 1   
                    
   @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

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
   Endif
   
   MS_FLUSH()

   cVendedor     := SPACE(06)
   cNomeVendedor := Space(30)

Return .T.

/*

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO DE VENDAS POR VENDEDOR                                                                    XX/XX/XXXX-XX:XX:XX
AUTOMR06.PRW                                                                       PERIODO DE XX/XX/XXXX A XX/XX/XXXX                                                                PAGINA:       XXXXX 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FL  TES  CFOP   NF      DT.EMISSAO   NR.PV  TIPO    DESCRICAO DOS PRODUTOS                                               QTD   UM    VLR PRODUTO   VLR SERVICO     VLR FRETE     DEVOLUÇÃO     VLR TOTAL
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                            VENDEDOR: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                            CLIENTE.: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
XX  XXX  X.XXX  XXXXXX  XX/XX/XXXX  XXXXXX  XXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXX.XX   XX   X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX

                                                                                                       TOTAL DO CLIENTE............:
                                                                                                       TOTAL DO VENDEDOR - INTERNAS:
                                                                                                       TOTAL DO VENDEDOR - EXTERNAS:
                                                                                                       TOTAL DO PERIODO  - INTERNAS:
                                                                                                       TOTAL DO PERIODO  - EXTERNAS:
*/
