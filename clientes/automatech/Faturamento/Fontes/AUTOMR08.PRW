#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR08.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/08/2011                                                          *
// Objetivo..: Relatório de Faturamento por Período	                               *
// Parâmetros: _Tipo -> Se = A, chamado pelo menu                                  *
//                      Se = B, chamado pela Consulta Gerencial                    *
//                      Se = C, chamado pelo Schedule                              *
//             _Mes  -> Mês de pesquisa                                            *
//             _Ano  -> Ano de Pesquisa                                            *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR08(_Tipo, _Mes, _Ano)
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private dData01   := Ctod("  /  /    ")
   Private dData02   := Ctod("  /  /    ")
   Private aComboBx1 := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS"}
   Private aComboBx2 := {"ANALÍTICO", "SINTÉTICO"}

   Private nGet1	 := Ctod("  /  /    ")
   Private nGet2	 := Ctod("  /  /    ")
   Private cComboBx1
   Private cComboBx2   

   Private xTipo := "A"

   If _Tipo == "B"
      xTipo := _Tipo
   Endif   

   If xTipo == "B"
      // Porto Alegre
      Private nACIPROP := 0
      Private nACISERP := 0
      Private nACIFREP := 0
      Private nACIDEVP := 0
      Private nACITOTP := 0

      Private nACEPROP := 0
      Private nACESERP := 0
      Private nACEFREP := 0
      Private nACEDEVP := 0
      Private nACETOTP := 0

      // Caxias do Sul
      Private nACIPROC := 0
      Private nACISERC := 0
      Private nACIFREC := 0
      Private nACIDEVC := 0
      Private nACITOTC := 0

      Private nACEPROC := 0
      Private nACESERC := 0
      Private nACEFREC := 0
      Private nACEDEVC := 0
      Private nACETOTC := 0

      // Pelotas
      Private nACIPROL := 0
      Private nACISERL := 0
      Private nACIFREL := 0
      Private nACIDEVL := 0
      Private nACITOTL := 0

      Private nACEPROL := 0
      Private nACESERL := 0
      Private nACEFREL := 0
      Private nACEDEVL := 0
      Private nACETOTL := 0

      Private nOutraPOA := 0
      Private nOutraCXS := 0
      Private nOutraPEL := 0

   Endif

   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTOMR08")

   // Variáveis que definem a Ação do Formulário

   If xTipo == "A"
      DEFINE MSDIALOG oDlg TITLE "Faturamento por Período" FROM C(178),C(181) TO C(360),C(550) PIXEL

      // Solicita o nº da etiqueta a ser impressa
      @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(040),C(005) Say "Filial:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(055),C(005) Say "Tipo:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(009),C(035) MsGet oGet1 Var dData01   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
      @ C(023),C(035) MsGet oGet2 Var dData02   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
      @ C(040),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(090),C(010) PIXEL OF oDlg
      @ C(055),C(035) ComboBox cComboBx2 Items aComboBx2 Size C(090),C(010) PIXEL OF oDlg

      DEFINE SBUTTON FROM C(75),C(155) TYPE  6 ENABLE OF oDlg ACTION( FATUPER( dData01, dData02, cComboBx1, cComboBx2 ))
      DEFINE SBUTTON FROM C(75),C(132) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

      ACTIVATE MSDIALOG oDlg CENTERED  
   Else
   
      dData01 := Ctod("01/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))

      Do Case
         Case _Mes == 1
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 2
              If Mod(_Ano,4) == 0
                 dData02 := Ctod("29/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
              Else
                 dData02 := Ctod("28/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))                 
              Endif   
         Case _Mes == 3
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 4
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 5
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 6
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 7
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 8
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 9
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 10
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 11
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 12
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
      EndCase

      FATUPER( dData01, dData02, "00 - CONSOLIDADO", "ANALÍTICO" )

      Return nACIPROP + nACISERP + nACIFREP + nACITOTP + nACEPROP + nACESERP + nACEFREP + nACETOTP + nACIPROC + nACISERC + nACIFREC + ;
             nACITOTC + nACEPROC + nACESERC + nACEFREC + nACETOTC + nACIPROL + nACISERL + nACIFREL + nACITOTL + nACEPROL + nACESERL + ;
             nACEFREL + nACETOTL + ;
             nACIDEVP + nACEDEVP + nACIDEVC + nACEDEVC + nACIDEVL + nACEDEVL + ;
             nOutraPOA + nOutraCXS + nOutraPEL
   Endif
      
Return(.T.)

// Função que prepara a impressão do relatório
Static Function FATUPER( dData01, dData02, cComboBx1, cComboBx2)

   // Declaracao de Variaveis
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Período"
   Local cPict          := ""
   Local titulo         := "Vendas por Período"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}
   Local _Filial        := ""
   
   If xTipo == "A"
      _Filial := Substr(cComboBx1,01,02)
   Else
      _Filial := "00"
   Endif
   
   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""

   If xTipo == "A"
      If Alltrim(cComboBx2) == "ANALÍTICO"
         Private limite  := 220
         Private tamanho := "G"
      Else   
         Private limite  := 80
         Private tamanho := "P"
      Endif   
   Else
      Private limite  := 220
      Private tamanho := "G"
   Endif

   Private nomeprog     := "Faturamento-Periodo"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Faturamento-Periodo"
   Private cString      := "SC5"
   Private xComboBx1
   Private xComboBx2

   Private aDevolucao   := {}
   Private nDevolve     := 0

   xComboBx1 := cComboBx1
   xComboBx2 := cComboBx2

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
   csql += "       A.D1_ITEMORI  "
   csql += "  FROM " + RetSqlName("SD1010") + " A, "
   cSql += "       " + RetSqlName("SF4010") + " B  "
   cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)

   If _Filial <> "00"
     cSql += " AND A.D1_FILIAL = '" + Alltrim(_Filial) + "'" 
   Endif

   csql += "   AND A.D1_NFORI    <> ''"
   csql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.D1_TES       = B.F4_CODIGO "
   cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

   T_DEVOLUCAO->( DbGoTop() )

   While !T_DEVOLUCAO->( EOF() )
     aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL, T_DEVOLUCAO->D1_TOTAL, T_DEVOLUCAO->D1_EMISSAO, T_DEVOLUCAO->D1_NFORI, T_DEVOLUCAO->D1_SERIORI, T_DEVOLUCAO->D1_ITEMORI, .F., "" } )
     T_DEVOLUCAO->( DbSkip() )
   Enddo

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

   If _Filial <> "00"
     cSql += " AND A.D2_FILIAL = '" + Alltrim(_Filial) + "'" 
   Endif
  
   cSql += " ORDER BY A.D2_FILIAL, A.D2_EMISSAO, A.D2_DOC, A.D2_CLIENTE, A.D2_LOJA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

   RESULTADO->( DbGoTop() )

   If RESULTADO->( Eof() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   pergunte(cPerg,.F.)

   // Monta a interface padrao com o usuario
   If xTipo == "A"

      wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
 
      If nLastKey == 27
         Return
      Endif

      SetDefault(aReturn,cString)

   Endif

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // Processamento. RPTSTATUS monta janela com a regua de processamento.
   If xTipo == "A"
      RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
   Else
      RunReport(Cabec1,Cabec2,Titulo,nLin)
   Endif

Return .T.

// Função que gera o relatório
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa   := ""
   Local cData      := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local nPagina    := 0
   Local aPesquisa  := {}

   // Carrega o Array aPesquisa com os dados acumulados por nota fiscal de cliente
   xVLR_SERVICO := 0
   xVLR_PRODUTO := 0
   xVLR_FRETE   := 0
   xVLR_TOTAL   := 0

   Resultado->( DbGoTop() )

   cEmpFil  := RESULTADO->D2_FILIAL
   cEmissao := RESULTADO->D2_EMISSAO
   cNotaF   := RESULTADO->D2_DOC
   cCliente := RESULTADO->D2_CLIENTE
   cLojaCli := RESULTADO->D2_LOJA

   While !Resultado->( EOF() )
   
      If Resultado->D2_FILIAL  == cEmpFil  .And. ;
         Resultado->D2_Emissao == cEmissao .And. ;
         Resultado->D2_DOC     == cNotaF   .And. ;
         Resultado->D2_CLIENTE == cCliente .And. ;
         Resultado->D2_LOJA    == cLojaCli
         
         xTES         := Resultado->D2_TES
         xCFOP        := Resultado->D2_CF
         xNF          := Resultado->D2_DOC
         xSERIE       := Resultado->D2_SERIE  
         xNUMPV       := Resultado->D2_PEDIDO
         xTIPOx       := IIF(Empty(Alltrim(Resultado->C5_FORNEXT)), "INTERNO", "EXTERNO")
         xCODIGO      := Resultado->D2_CLIENTE
         xLoja        := Resultado->D2_LOJA
         xNOME        := Resultado->A1_NOME
         xCIDADE      := Resultado->A1_MUN
         xUF          := Resultado->A1_EST

         If Alltrim(Resultado->B1_TIPO) == "MO"
            xVLR_SERVICO := xVLR_SERVICO + Resultado->D2_TOTAL
         Else
            xVLR_PRODUTO := xVLR_PRODUTO + Resultado->D2_TOTAL
         Endif     

         xVLR_FRETE   := xVLR_FRETE + Resultado->D2_VALFRE  
         xVLR_TOTAL   := xVLR_PRODUTO + xVLR_SERVICO + xVLR_FRETE

         Resultado->( DbSkip() )
         
         Loop
         
      Else

         // Carrega o Array
         aPesq := {cEmpFil      ,; // 01 - Filial
                   cEmissao     ,; // 02 - Data de Emissão
                   xTES         ,; // 03 - TES
                   xCFOP        ,; // 04 - CFOP
                   xNF          ,; // 05 - Nº Nota Fiscal
                   xSERIE       ,; // 06 - Nº de Série
                   xNUMPV       ,; // 07 - Nº do Pedido de Venda
                   xTIPOx       ,; // 08 - Tipo (PV Interno/Externo)
                   xCODIGO      ,; // 09 - Código do Cliente
                   xLoja        ,; // 10 - Loja do Cliente
                   xNOME        ,; // 11 - Nome do Cliente
                   xCIDADE      ,; // 12 - Cidade do Cliente
                   xUF          ,; // 13 - Estado do Cliente
                   xVLR_PRODUTO ,; // 14 - Valor Total dos Produtos
                   xVLR_SERVICO ,; // 15 - Valor Total dos Serviços
                   xVLR_FRETE   ,; // 16 - Valor Total dos Frete
                   xVLR_TOTAL}     // 17 - Valor Total da Nota Fiscal
       
  	     aAdd( aPesquisa, aPesq )

         cEmpFil  := RESULTADO->D2_FILIAL
         cEmissao := RESULTADO->D2_EMISSAO
         cNotaF   := RESULTADO->D2_DOC
         cCliente := RESULTADO->D2_CLIENTE
         cLojaCli := RESULTADO->D2_LOJA

         xVLR_SERVICO := 0
         xVLR_PRODUTO := 0
         xVLR_FRETE   := 0
         xVLR_TOTAL   := 0
         
      Endif
         
   Enddo
   
   // Carrega o Array
   aPesq := {cEmpFil      ,; // 01 - Filial
             cEmissao     ,; // 02 - Data de Emissão
             xTES         ,; // 03 - TES
             xCFOP        ,; // 04 - CFOP
             xNF          ,; // 05 - Nº Nota Fiscal
             xSERIE       ,; // 06 - Nº de Série
             xNUMPV       ,; // 07 - Nº do Pedido de Venda
             xTIPOx       ,; // 08 - Tipo (PV Interno/Externo)
             xCODIGO      ,; // 09 - Código do Cliente
             xLoja        ,; // 10 - Loja do Cliente
             xNOME        ,; // 11 - Nome do Cliente
             xCIDADE      ,; // 12 - Cidade do Cliente
             xUF          ,; // 13 - Estado do Cliente
             xVLR_PRODUTO ,; // 14 - Valor Total dos Produtos
             xVLR_SERVICO ,; // 15 - Valor Total dos Serviços
             xVLR_FRETE   ,; // 16 - Valor Total dos Frete
             xVLR_TOTAL}     // 17 - Valor Total da Nota Fiscal
                          
   aAdd( aPesquisa, aPesq )

   // Ordena o Array para Impressão
   ASORT(aPesquisa,,,{ | x,y | x[1] + x[2] < y[1] + y[2] } )
   
   // Imprime o relatório analítico

   If Alltrim(xComboBx2) == "ANALÍTICO"

      cEmpFil := aPesquisa[01,01]
      cData   := aPesquisa[01,02]

      nProID := 0; nSerID := 0; nFreID := 0; nTotID := 0; nDevID := 0
      nProED := 0; nSerED := 0; nFreED := 0; nTotED := 0; nDevED := 0

      nProIV := 0; nSerIV := 0; nFreIV := 0; nTotIV := 0; nDevIV := 0
      nProEV := 0; nSerEV := 0; nFreEV := 0; nTotEV := 0; nDevEV := 0

      nProIA := 0; nSerIA := 0; nFreIA := 0; nTotIA := 0; nDevIA := 0
      nProEA := 0; nSerEA := 0; nFreEA := 0; nTotEA := 0; nDevEA := 0

      // Acumuladores
      nPagina  := 0
      
	  ProcRegua( Len(aPesquisa) )
      
      For nContar = 1 to Len(aPesquisa)
   
         IncProc("Aguarde, pesquisando ...")
         
         If Alltrim(aPesquisa[nContar,01]) == Alltrim(cEmpFil)

            If Alltrim(aPesquisa[nContar,02]) == Alltrim(cData)

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
                  @ nLin,084 PSAY "RELAÇÃO DE FATURAMENTO POR PERÍODO"
                  @ nLin,180 PSAY dtoc(DATE()) + " - " + TIME()
                  nLin := nLin + 1
                  @ nLin,001 PSAY "AUTOMR08.PRW"
                  @ nLin,084 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
                  @ nLin,180 PSAY "PÁGINA:"
                  @ nLin,195 PSAY Strzero(nPagina,6)
                  nLin = nLin + 1
                  @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
                  nLin := nLin + 1
                  @ nLin,001 PSAY "NF     SR  NR.PV  TIPO    CODIGO     DESCRIÇÃO DOS CLIENTES                                      CIDADE                         UF    VLR PRODUTO   VLR SERVICO     VLR FRETE    DEVOLUÇÕES    VLR TOTAL"
                  nLin := nLin + 1                           
                  @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
                  nLin := nLin + 2

                  Do Case
                     Case Alltrim(aPesquisa[nContar,01]) == "01"
                          @ nLin,061 PSAY "FILIAL: " + "01 - PORTO ALEGRE"
                     Case Alltrim(aPesquisa[nContar,01]) == "02"
                          @ nLin,061 PSAY "FILIAL: " + "02 - CAXIAS DO SUL"
                     Case Alltrim(aPesquisa[nContar,01]) == "03"
                          @ nLin,061 PSAY "FILIAL: " + "03 - PELOTAS"
                  EndCase        

                  nLin = nLin + 2
                  @ nLin,061 PSAY "DATA..: " + Substr(aPesquisa[nContar,02],07,02) + "/" + Substr(aPesquisa[nContar,02],05,02) + "/" + Substr(aPesquisa[nContar,02],01,04)
                  nLin = nLin + 2

               Endif

               // Impressão dos dados
               @ nLin,001 PSAY Substr(aPesquisa[nContar,05],01,06)
               @ nLin,008 PSAY aPesquisa[nContar,06]
               @ nLin,012 PSAY aPesquisa[nContar,07]
               @ nLin,019 PSAY aPesquisa[nContar,08]
               @ nLin,027 PSAY aPesquisa[nContar,09] + "." + aPesquisa[nContar,10]
               @ nLin,038 PSAY aPesquisa[nContar,11]
               @ nLin,098 PSAY aPesquisa[nContar,12]
               @ nLin,129 PSAY aPesquisa[nContar,13]
               @ nLin,134 PSAY Str(aPesquisa[nContar,14],12,02)
               @ nLin,148 PSAY Str(aPesquisa[nContar,15],12,02)
               @ nLin,162 PSAY Str(aPesquisa[nContar,16],12,02)

               // Verifica se existe devolução para a nota fiscal selecionada
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(aPesquisa[nContar,05],01,06)) .And. ;
                      Alltrim(aDevolucao[nDevolve,05]) == Alltrim(aPesquisa[nContar,06])               .And. ;
                      Alltrim(aDevolucao[nDevolve,01]) == Alltrim(aPesquisa[nContar,01])
                      aDevolucao[nDevolve,07] := .T.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
               Next nDevolve

               @ nLin,176 PSAY Str(nDevolucao,12,02)
               @ nLin,189 PSAY Str((aPesquisa[nContar,17] - nDevolucao),12,02)

               nLin = nLin + 1

               If Alltrim(aPesquisa[nContar,08]) == "INTERNO"

                  nProID := nProID + aPesquisa[nContar,14]
                  nSerID := nSerID + aPesquisa[nContar,15]
                  nFreID := nFreID + aPesquisa[nContar,16]
                  nDevID := nDevID + nDevolucao
                  nTotID := nTotID + aPesquisa[nContar,17] - nDevolucao

                  nProIV := nProIV + aPesquisa[nContar,14]
                  nSerIV := nSerIV + aPesquisa[nContar,15]
                  nFreIV := nFreIV + aPesquisa[nContar,16]
                  nDevIV := nDevIV + nDevolucao
                  nTotIV := nTotIV + aPesquisa[nContar,17] - nDevolucao

                  nProIA := nProIA + aPesquisa[nContar,14]
                  nSerIA := nSerIA + aPesquisa[nContar,15]
                  nFreIA := nFreIA + aPesquisa[nContar,16]
                  nDevIA := nDevIA + nDevolucao
                  nTotIA := nTotIA + aPesquisa[nContar,17] - nDevolucao

               Else

                  nProED := nProED + aPesquisa[nContar,14]
                  nSerED := nSerED + aPesquisa[nContar,15]
                  nFreED := nFreED + aPesquisa[nContar,16]
                  nDevED := nDevED + nDevolucao
                  nTotED := nTotED + aPesquisa[nContar,17] - nDevolucao

                  nProEV := nProEV + aPesquisa[nContar,14]
                  nSerEV := nSerEV + aPesquisa[nContar,15]
                  nFreEV := nFreEV + aPesquisa[nContar,16]
                  nDevEV := nDevEV + nDevolucao
                  nTotEV := nTotEV + aPesquisa[nContar,17] - nDevolucao

                  nProEA := nProEA + aPesquisa[nContar,14]
                  nSerEA := nSerEA + aPesquisa[nContar,15]
                  nFreEA := nFreEA + aPesquisa[nContar,16]
                  nDevEA := nDevEA + nDevolucao
                  nTotEA := nTotEA + aPesquisa[nContar,17] - nDevolucao

               Endif               

               Loop
            
            Else

               nLin = nLin + 1

               @ nLin,098 PSAY "TOTAL PEDIDOS INTERNOS NA DATA:"
               @ nLin,134 PSAY Str(nProID,12,02)
               @ nLin,148 PSAY Str(nSerID,12,02)
               @ nLin,162 PSAY Str(nFreID,12,02)
               @ nLin,176 PSAY Str(nDevID,12,02)
//             @ nLin,189 PSAY Str(nTotID,12,02)
               nLin = nLin + 1

               // Pesquisa Outras Devoluções na Data
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If aDevolucao[nDevolve,03] == cData
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
                   Endif
               Next nDevolve

               @ nLin,098 PSAY "TOTAL OUTRAS DEVOLUÇÕES.......: "
               @ nLin,176 PSAY Str((nDevolucao),12,02)
               @ nLin,189 PSAY Str((nTotID - nDevolucao),12,02)
               nLin = nLin + 1

               @ nLin,098 PSAY "TOTAL PEDIDOS EXTERNOS NA DATA:"
               @ nLin,134 PSAY Str(nProED,12,02)
               @ nLin,148 PSAY Str(nSerED,12,02)
               @ nLin,162 PSAY Str(nFreED,12,02)
               @ nLin,176 PSAY Str(nDevED,12,02)
               @ nLin,189 PSAY Str(nTotED,12,02)
               nLin = nLin + 1

               @ nLin,098 PSAY "TOTAL GERAL DA DATA...........:"
               @ nLin,134 PSAY Str((nProID + nProED),12,02)
               @ nLin,148 PSAY Str((nSerID + nSerED),12,02)
               @ nLin,162 PSAY Str((nFreID + nFreED),12,02)
               @ nLin,176 PSAY Str((nDevID + nDevED + nDevolucao),12,02)
               @ nLin,189 PSAY Str((nTotID + nTotED - nDevolucao),12,02)
               nLin = nLin + 2

               nProID := 0; nSerID := 0; nFreID := 0; nTotID := 0; nDevID := 0
               nProED := 0; nSerED := 0; nFreED := 0; nTotED := 0; nDevED := 0

               cData := aPesquisa[nContar,02]

               @ nLin,061 PSAY "DATA..: " + Substr(aPesquisa[nContar,02],07,02) + "/" + Substr(aPesquisa[nContar,02],05,02) + "/" + Substr(aPesquisa[nContar,02],01,04)
    
               nLin = nLin + 2

               nContar := nContar - 1

            Endif
         
         Else            
      
            nLin = nLin + 2

            // Totaliza a Data
            @ nLin,098 PSAY "TOTAL PEDIDOS INTERNOS NA DATA:"
            @ nLin,134 PSAY Str(nProID,12,02)
            @ nLin,148 PSAY Str(nSerID,12,02)
            @ nLin,162 PSAY Str(nFreID,12,02)
            @ nLin,176 PSAY Str(nDevID,12,02)
//          @ nLin,189 PSAY Str(nTotID,12,02)
            nLin = nLin + 1

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,03] == cData
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,098 PSAY "OUTRAS DEVOLUÇÕES.............:"
            @ nLin,176 PSAY Str((nDevolucao),12,02)
            @ nLin,189 PSAY Str((nTotID - nDevolucao),12,02)
            nLin = nLin + 1

            @ nLin,098 PSAY "TOTAL PEDIDOS EXTERNOS NA DATA:"
            @ nLin,134 PSAY Str(nProED,12,02)
            @ nLin,148 PSAY Str(nSerED,12,02)
            @ nLin,162 PSAY Str(nFreED,12,02)
            @ nLin,176 PSAY Str(nDevED,12,02)
            @ nLin,189 PSAY Str(nTotED,12,02)
            nLin = nLin + 1

            @ nLin,098 PSAY "TOTAL GERAL DA DATA...........:"
            @ nLin,134 PSAY Str((nProID + nProED),12,02)
            @ nLin,148 PSAY Str((nSerID + nSerED),12,02)
            @ nLin,162 PSAY Str((nFreID + nFreED),12,02)
            @ nLin,176 PSAY Str((nDevID + nDevED + nDevolucao),12,02)
            @ nLin,189 PSAY Str((nTotID + nTotED - nDevolucao),12,02)
            nLin = nLin + 2

            @ nLin,098 PSAY "-------------------------------------------------------------------------------------------------------"  

            nLin = nLin + 2

            // Totaliza da Filial
            @ nLin,098 PSAY "TOTAL PEDIDOS INTERNOS FILIAL.:"
            @ nLin,134 PSAY Str(nProIV,12,02)
            @ nLin,148 PSAY Str(nSerIV,12,02)
            @ nLin,162 PSAY Str(nFreIV,12,02)
            @ nLin,176 PSAY Str(nDevIV,12,02)
//          @ nLin,189 PSAY Str(nTotIV,12,02)
            nLin = nLin + 1

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,01] == cEmpFil
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            @ nLin,098 PSAY "OUTRAS DEVOLUÇÕES ............:"
            @ nLin,176 PSAY Str((nDevolucao),12,02)
            @ nLin,189 PSAY Str((nTotIV - nDevolucao),12,02)
            nLin = nLin + 1

            @ nLin,098 PSAY "TOTAL PEDIDOS EXTERNOS FILIAL.:"
            @ nLin,134 PSAY Str(nProEV,12,02)
            @ nLin,148 PSAY Str(nSerEV,12,02)
            @ nLin,162 PSAY Str(nFreEV,12,02)
            @ nLin,176 PSAY Str(nDevIV,12,02)
            @ nLin,189 PSAY Str(nTotEV,12,02)
            nLin = nLin + 1

            @ nLin,098 PSAY "TOTAL GERAL NA FILIAL.........:"
            @ nLin,134 PSAY Str((nProIV + nProEV),12,02)
            @ nLin,148 PSAY Str((nSerIV + nSerEV),12,02)
            @ nLin,162 PSAY Str((nFreIV + nFreEV),12,02)
            @ nLin,176 PSAY Str((nDevIV + nDevEV + nDevolucao),12,02)
            @ nLin,189 PSAY Str((nTotIV + nTotEV - nDevolucao),12,02)
            nLin = nLin + 2

            If xTipo == "B"
   	           // Porto Alegre
               If cEmpFil == "01"
                  nACIPROP := nProIV
                  nACISERP := nSerIV
                  nACIFREP := nFreIV
                  nACIDEVP := nDevIV
                  nACITOTP := nTotIV

                  nACEPROP := nProEV
                  nACESERP := nSerEV
                  nACEFREP := nFreEV
                  nACEDEVP := nDevEV
                  nACETOTP := nTotEV
               Endif
               
               // Caxias do Sul
               If cEmpFil == "02"
                  nACIPROC := nProIV
                  nACISERC := nSerIV
                  nACIFREC := nFreIV
                  nACIDEVC := nDevIV
                  nACITOTC := nTotIV

                  nACEPROC := nProEV
                  nACESERC := nSerEV
                  nACEFREC := nFreEV
                  nACEDEVC := nDevEV
                  nACETOTC := nTotEV
               Endif

               // Pelotas
               If cEmpFil == "03"
                  nACIPROL := nProIV
                  nACISERL := nSerIV
                  nACIFREL := nFreIV
                  nACIDEVL := nDevIV
                  nACITOTL := nTotIV

                  nACEPROL := nProEV
                  nACESERL := nSerEV
                  nACEFREL := nFreEV
                  nACEDEVL := nDevEV
                  nACETOTL := nTotEV
               Endif
            Endif   

            nProID := 0; nSerID := 0; nFreID := 0; nTotID := 0; nDevID := 0
            nProED := 0; nSerED := 0; nFreED := 0; nTotED := 0; nDevED := 0
    
            nProIV := 0; nSerIV := 0; nFreIV := 0; nTotIV := 0; nDevIV := 0
            nProEV := 0; nSerEV := 0; nFreEV := 0; nTotEV := 0; nDevEV := 0

            cEmpFil := aPesquisa[nContar,01]
            cData   := aPesquisa[nContar,02]

            Do Case
               Case Alltrim(aPesquisa[nContar,01]) == "01"
                    @ nLin,061 PSAY "FILIAL: " + "01 - PORTO ALEGRE"
               Case Alltrim(aPesquisa[nContar,01]) == "02"
                    @ nLin,061 PSAY "FILIAL: " + "02 - CAXIAS DO SUL"
               Case Alltrim(aPesquisa[nContar,01]) == "03"
                    @ nLin,061 PSAY "FILIAL: " + "03 - PELOTAS"
            EndCase        

            nLin = nLin + 2
            @ nLin,061 PSAY "DATA..: " + Substr(aPesquisa[nContar,02],07,02) + "/" + Substr(aPesquisa[nContar,02],05,02) + "/" + Substr(aPesquisa[nContar,02],01,04)
            nLin = nLin + 2

            nContar := nContar - 1

         Endif

      Next nContar

      nLin = nLin + 2

      // Totaliza a Data
      @ nLin,098 PSAY "TOTAL PEDIDOS INTERNOS DATA...:"
      @ nLin,134 PSAY Str(nProID,12,02) 
      @ nLin,148 PSAY Str(nSerID,12,02)
      @ nLin,162 PSAY Str(nFreID,12,02)
      @ nLin,176 PSAY Str(nDevID,12,02)
//    @ nLin,189 PSAY Str(nTotID,12,02)
      nLin = nLin + 1

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cData
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,098 PSAY "OUTRAS DEVOLUÇÕES ............:"
      @ nLin,176 PSAY Str((nDevolucao),12,02)
      @ nLin,189 PSAY Str((nTotID - nDevolucao),12,02)
      nLin = nLin + 1

      @ nLin,098 PSAY "TOTAL PEDIDOS EXTERNOS DATA...:"
      @ nLin,134 PSAY Str(nProED,12,02)
      @ nLin,148 PSAY Str(nSerED,12,02)
      @ nLin,162 PSAY Str(nFreED,12,02)
      @ nLin,176 PSAY Str(nDevED,12,02)
      @ nLin,189 PSAY Str(nTotED,12,02)
      nLin = nLin + 1

      @ nLin,098 PSAY "TOTAL GERAL DA DATA...........:"
      @ nLin,134 PSAY Str((nProID + nProED),12,02)
      @ nLin,148 PSAY Str((nSerID + nSerED),12,02)
      @ nLin,162 PSAY Str((nFreID + nFreED),12,02)
      @ nLin,176 PSAY Str((nDevID + nDevED + nDevolucao),12,02)
      @ nLin,189 PSAY Str((nTotID + nTotED - nDevolucao),12,02)
      nLin = nLin + 2

      @ nLin,098 PSAY "-------------------------------------------------------------------------------------------------------"  

      nLin = nLin + 2
   
      // Totaliza da Filial
      @ nLin,098 PSAY "TOTAL PEDIDOS INTERNOS FILIAL.:"
      @ nLin,134 PSAY Str(nProIV,12,02)
      @ nLin,148 PSAY Str(nSerIV,12,02)
      @ nLin,162 PSAY Str(nFreIV,12,02)
      @ nLin,176 PSAY Str(nDevIV,12,02)
//    @ nLin,189 PSAY Str(nTotIV,12,02)
      nLin = nLin + 1

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cEmpFil
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      @ nLin,098 PSAY "OUTRAS DEVOLUÇÕES.............:"
      @ nLin,176 PSAY Str((nDevolucao),12,02)
      @ nLin,189 PSAY Str((nTotIV - nDevolucao),12,02)
      nLin = nLin + 1

      @ nLin,098 PSAY "TOTAL PEDIDOS EXTERNOS FILIAL.:"
      @ nLin,134 PSAY Str(nProEV,12,02)
      @ nLin,148 PSAY Str(nSerEV,12,02)
      @ nLin,162 PSAY Str(nFreEV,12,02)
      @ nLin,176 PSAY Str(nDevEV,12,02)
      @ nLin,189 PSAY Str(nTotEV,12,02)
      nLin = nLin + 1

      @ nLin,098 PSAY "TOTAL GERAL NA FILIAL.........:"
      @ nLin,134 PSAY Str((nProIV + nProEV),12,02)
      @ nLin,148 PSAY Str((nSerIV + nSerEV),12,02)
      @ nLin,162 PSAY Str((nFreIV + nFreEV),12,02)
      @ nLin,176 PSAY Str((nDevIV + nDevEV + nDevolucao),12,02)
      @ nLin,189 PSAY Str((nTotIV + nTotEV - nDevolucao),12,02)
      nLin = nLin + 2

      If xTipo == "B"
         // Porto Alegre
         If cEmpFil == "01"
            nACIPROP := nProIV
            nACISERP := nSerIV
            nACIFREP := nFreIV
            nACIDEVP := nDevIV
            nACITOTP := nTotIV

            nACEPROP := nProEV
            nACESERP := nSerEV
            nACEFREP := nFreEV
            nACEDEVP := nDevEV
            nACETOTP := nTotEV
         Endif
               
         // Caxias do Sul
         If cEmpFil == "02"
            nACIPROC := nProIV
            nACISERC := nSerIV
            nACIFREC := nFreIV
            nACIDEVC := nDevIV
            nACITOTC := nTotIV

            nACEPROC := nProEV
            nACESERC := nSerEV
            nACEFREC := nFreEV
            nACEDEVC := nDevEV
            nACETOTC := nTotEV
         Endif

         // Pelotas
         If cEmpFil == "03"
            nACIPROL := nProIV
            nACISERL := nSerIV
            nACIFREL := nFreIV
            nACIDEVL := nDevIV
            nACITOTL := nTotIV

            nACEPROL := nProEV
            nACESERL := nSerEV
            nACEFREL := nFreEV
            nACEDEVL := nDevEV
            nACETOTL := nTotEV
         Endif
      Endif   

      @ nLin,098 PSAY "-------------------------------------------------------------------------------------------------------"  

      nLin = nLin + 2

      // Total Geral do Período
      @ nLin,098 PSAY "TOTAL PEDIDOS INTERNOS PERÍODO:"
      @ nLin,134 PSAY Str(nProIA,12,02)
      @ nLin,148 PSAY Str(nSerIA,12,02)
      @ nLin,162 PSAY Str(nFreIA,12,02)
      @ nLin,176 PSAY Str(nDevIA,12,02)
      nLin = nLin + 1

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      @ nLin,098 PSAY "OUTRAS DEVOLUÇÕES.............:"
      @ nLin,176 PSAY Str((nDevolucao),12,02)
      @ nLin,189 PSAY Str((nTotIA - nDevolucao),12,02)
      nLin = nLin + 1

      @ nLin,098 PSAY "TOTAL PEDIDOS EXTERNOS PERÍODO:"
      @ nLin,134 PSAY Str(nProEA,12,02)
      @ nLin,148 PSAY Str(nSerEA,12,02)
      @ nLin,162 PSAY Str(nFreEA,12,02)
      @ nLin,176 PSAY Str(nDevEA,12,02)
      @ nLin,189 PSAY Str(nTotEA,12,02)
      nLin = nLin + 1

      @ nLin,098 PSAY "TOTAL GERAL DO PERÍODO........:"
      @ nLin,134 PSAY Str((nProIA + nProEA),12,02)
      @ nLin,148 PSAY Str((nSerIA + nSerEA),12,02)
      @ nLin,162 PSAY Str((nFreIA + nFreEA),12,02)
      @ nLin,176 PSAY Str((nDevIA + nDevEA + nDevolucao),12,02)
      @ nLin,189 PSAY Str((nTotIA + nTotEA - nDevolucao),12,02)

   Else

      // SINTÉTICO
      
      cEmpFil   := aPesquisa[01,01]
      cData     := aPesquisa[01,02]

      nProInte  := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
      nProExte  := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

      nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
      nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

      nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
      nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

      nPagina  := 0

      For nContar = 1 to Len(aPesquisa)
   
         If Alltrim(aPesquisa[nContar,01]) == Alltrim(cEmpFil)

            If Alltrim(aPesquisa[nContar,02]) == Alltrim(cData)

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
                  @ nLin,020 PSAY "FATURAMENTO POR PERÍODO - SINTÉTICO"
                  @ nLin,061 PSAY dtoc(DATE()) + " - " + TIME()
                  nLin := nLin + 1
                  @ nLin,001 PSAY "AUTOMR08.PRW"
                  @ nLin,020 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
                  @ nLin,061 PSAY "PÁGINA:"
                  @ nLin,076 PSAY Strzero(nPagina,6)
                  nLin = nLin + 1
                  @ nLin,001 PSAY "---------------------------------------------------------------------------------"
                  nLin := nLin + 1
                  @ nLin,001 PSAY "DATA       T  VLR PRODUTO   VLR SERVICO     VLR FRETE    DEVOLUÇÕES     VLR TOTAL"
                  nLin := nLin + 1
                  @ nLin,001 PSAY "---------------------------------------------------------------------------------"
                  nLin := nLin + 2

                  Do Case
                     Case Alltrim(aPesquisa[nContar,01]) == "01"
                          @ nLin,012 PSAY "FILIAL: " + "01 - PORTO ALEGRE"
                     Case Alltrim(aPesquisa[nContar,01]) == "02"
                          @ nLin,012 PSAY "FILIAL: " + "02 - CAXIAS DO SUL"
                     Case Alltrim(aPesquisa[nContar,01]) == "03"
                          @ nLin,012 PSAY "FILIAL: " + "03 - PELOTAS"
                  EndCase        

                  nLin := nLin + 2

               Endif

               // Verifica se existe devolução para a nota fiscal selecionada
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(aPesquisa[nContar,05],01,06)) .And. ;
                      Alltrim(aDevolucao[nDevolve,05]) == Alltrim(aPesquisa[nContar,06])               .And. ;
                      Alltrim(aDevolucao[nDevolve,01]) == Alltrim(aPesquisa[nContar,01])
                      aDevolucao[nDevolve,07] := .T.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
               Next nDevolve

               // Acumula os Valores da Data para Impressão
               If Alltrim(aPesquisa[nContar,08]) == "INTERNO"

                  nProInte  := nProInte  + aPesquisa[nContar,14]
                  nSerInte  := nSerInte  + aPesquisa[nContar,15]
                  nFreInte  := nFreInte  + aPesquisa[nContar,16]
                  nDevInte  := nDevInte  + nDevolucao
                  nTotInte  := nTotInte  + aPesquisa[nContar,17] - nDevolucao

                  nProAInte := nProAInte + aPesquisa[nContar,14]
                  nSerAInte := nSerAInte + aPesquisa[nContar,15]
                  nFreAInte := nFreAInte + aPesquisa[nContar,16]
                  nDevAInte := nDevAInte + nDevolucao
                  nTotAInte := nTotAInte + aPesquisa[nContar,17] - nDevolucao

                  nProGInte := nProGInte + aPesquisa[nContar,14]
                  nSerGInte := nSerGInte + aPesquisa[nContar,15]
                  nFreGInte := nFreGInte + aPesquisa[nContar,16]
                  nDevGInte := nDevGInte + nDevolucao
                  nTotGInte := nTotGInte + aPesquisa[nContar,17] - nDevolucao

               Else   

                  nProExte  := nProExte  + aPesquisa[nContar,14]
                  nSerExte  := nSerExte  + aPesquisa[nContar,15]
                  nFreExte  := nFreExte  + aPesquisa[nContar,16]
                  nDevExte  := nDevExte  + nDevolucao
                  nTotExte  := nTotExte  + aPesquisa[nContar,17] - nDevolucao

                  nProAExte := nProAExte + aPesquisa[nContar,14]
                  nSerAExte := nSerAExte + aPesquisa[nContar,15]
                  nFreAExte := nFreAExte + aPesquisa[nContar,16]
                  nDevAExte := nDevAExte + nDevolucao
                  nTotAExte := nTotAExte + aPesquisa[nContar,17] - nDevolucao

                  nProGExte := nProGExte + aPesquisa[nContar,14]
                  nSerGExte := nSerGExte + aPesquisa[nContar,15]
                  nFreGExte := nFreGExte + aPesquisa[nContar,16]
                  nDevGExte := nDevGExte + nDevolucao
                  nTotGExte := nTotGExte + aPesquisa[nContar,17] - nDevolucao

               Endif

               Loop
            
            Else

               @ nLin,001 PSAY Substr(cData,07,02) + "/" + Substr(cData,05,02) + "/" + Substr(cData,01,04)
               @ nLin,012 PSAY "I"
               @ nLin,014 PSAY Str(nProInte,12,02)
               @ nLin,028 PSAY Str(nSerInte,12,02)
               @ nLin,042 PSAY Str(nFreInte,12,02)
               @ nLin,056 PSAY Str(nDevInte,12,02)
               @ nLin,070 PSAY Str(nTotInte,12,02)                                             

               nLin := nLin + 1

               @ nLin,012 PSAY "E"
               @ nLin,014 PSAY Str(nProExte,12,02)
               @ nLin,028 PSAY Str(nSerExte,12,02)
               @ nLin,042 PSAY Str(nFreExte,12,02)
               @ nLin,056 PSAY Str(nDevExte,12,02)
               @ nLin,070 PSAY Str(nTotExte,12,02)                                             
               
               nLin := nLin + 1

               @ nLin,008 PSAY "TOTAL"
               @ nLin,014 PSAY Str((nProInte + nProExte),12,02)
               @ nLin,028 PSAY Str((nSerInte + nSerExte),12,02)
               @ nLin,042 PSAY Str((nFreInte + nFreExte),12,02)
               @ nLin,056 PSAY Str((nDevInte + nDevExte),12,02)
               @ nLin,070 PSAY Str((nTotInte + nTotExte),12,02)                                             

               nLin := nLin + 2

               nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
               nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

               cData := aPesquisa[nContar,02]

               nContar := nContar - 1

            Endif
         
         Else            
      
            // Totaliza a última data
            @ nLin,001 PSAY Substr(cData,07,02) + "/" + Substr(cData,05,02) + "/" + Substr(cData,01,04)
            @ nLin,012 PSAY "I"
            @ nLin,014 PSAY Str(nProInte,12,02)
            @ nLin,028 PSAY Str(nSerInte,12,02)
            @ nLin,042 PSAY Str(nFreInte,12,02)
            @ nLin,056 PSAY Str(nDevInte,12,02)
            @ nLin,070 PSAY Str(nTotInte,12,02)                                             

            nLin := nLin + 1

            @ nLin,012 PSAY "E"
            @ nLin,014 PSAY Str(nProExte,12,02)
            @ nLin,028 PSAY Str(nSerExte,12,02)
            @ nLin,042 PSAY Str(nFreExte,12,02)
            @ nLin,056 PSAY Str(nDevExte,12,02)
            @ nLin,070 PSAY Str(nTotExte,12,02)                                             
               
            nLin := nLin + 1

            @ nLin,008 PSAY "TOTAL"
            @ nLin,014 PSAY Str((nProInte + nProExte),12,02)
            @ nLin,028 PSAY Str((nSerInte + nSerExte),12,02)
            @ nLin,042 PSAY Str((nFreInte + nFreExte),12,02)
            @ nLin,056 PSAY Str((nDevInte + nDevExte),12,02)
            @ nLin,070 PSAY Str((nTotInte + nTotExte),12,02)                                             

            nLin := nLin + 2

            // Zera os totalizadores da data
            nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
            nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

	        // Totaliza a Filial
            @ nLin,001 PSAY "TOTAL DA"
            @ nLin,012 PSAY "I"
            @ nLin,014 PSAY Str(nProAInte,12,02)
            @ nLin,028 PSAY Str(nSerAInte,12,02)
            @ nLin,042 PSAY Str(nFreAInte,12,02)
            @ nLin,056 PSAY Str(nDevAInte,12,02)
            @ nLin,070 PSAY Str(nTotAInte,12,02)                                             

            nLin := nLin + 1

            @ nLin,001 PSAY "FILIAL"
            @ nLin,012 PSAY "E"
            @ nLin,014 PSAY Str(nProAExte,12,02)
            @ nLin,028 PSAY Str(nSerAExte,12,02)
            @ nLin,042 PSAY Str(nFreAExte,12,02)
            @ nLin,056 PSAY Str(nDevAExte,12,02)
            @ nLin,070 PSAY Str(nTotAExte,12,02)                                             
               
            nLin := nLin + 1

            @ nLin,008 PSAY "TOTAL"
            @ nLin,014 PSAY Str((nProAInte + nProAExte),12,02)
            @ nLin,028 PSAY Str((nSerAInte + nSerAExte),12,02)
            @ nLin,042 PSAY Str((nFreAInte + nFreAExte),12,02)
            @ nLin,056 PSAY Str((nDevAInte + nDevAExte),12,02)
            @ nLin,070 PSAY Str((nTotAInte + nTotAExte),12,02)                                             

            nLin := nLin + 1

            @ nLin,001 PSAY "---------------------------------------------------------------------------------"

            nLin := nLin + 2

            cEmpFil := aPesquisa[nContar,01]
            cData   := aPesquisa[nContar,02]

            nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
            nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

            Do Case
               Case Alltrim(aPesquisa[nContar,01]) == "01"
                    @ nLin,012 PSAY "FILIAL: " + "01 - PORTO ALEGRE"
               Case Alltrim(aPesquisa[nContar,01]) == "02"
                    @ nLin,012 PSAY "FILIAL: " + "02 - CAXIAS DO SUL"
               Case Alltrim(aPesquisa[nContar,01]) == "03"
                    @ nLin,012 PSAY "FILIAL: " + "03 - PELOTAS"
            EndCase        

            nLin = nLin + 2

            nContar := nContar - 1

         Endif

      Next nContar

      // Totaliza a última data
      @ nLin,001 PSAY Substr(cData,07,02) + "/" + Substr(cData,05,02) + "/" + Substr(cData,01,04)
      @ nLin,012 PSAY "I"
      @ nLin,014 PSAY Str(nProInte,12,02)
      @ nLin,028 PSAY Str(nSerInte,12,02)
      @ nLin,042 PSAY Str(nFreInte,12,02)
      @ nLin,056 PSAY Str(nDevInte,12,02)
      @ nLin,070 PSAY Str(nTotInte,12,02)                                             

      nLin := nLin + 1

      @ nLin,012 PSAY "E"
      @ nLin,014 PSAY Str(nProExte,12,02)
      @ nLin,028 PSAY Str(nSerExte,12,02)
      @ nLin,042 PSAY Str(nFreExte,12,02)
      @ nLin,056 PSAY Str(nDevExte,12,02)
      @ nLin,070 PSAY Str(nTotExte,12,02)                                             
               
      nLin := nLin + 1

      @ nLin,008 PSAY "TOTAL"
      @ nLin,014 PSAY Str((nProInte + nProExte),12,02)
      @ nLin,028 PSAY Str((nSerInte + nSerExte),12,02)
      @ nLin,042 PSAY Str((nFreInte + nFreExte),12,02)
      @ nLin,056 PSAY Str((nDevInte + nDevExte),12,02)
      @ nLin,070 PSAY Str((nTotInte + nTotExte),12,02)                                             

      nLin := nLin + 2

      // Totaliza a Filial
      @ nLin,001 PSAY "TOTAL DA"
      @ nLin,012 PSAY "I"
      @ nLin,014 PSAY Str(nProAInte,12,02)
      @ nLin,028 PSAY Str(nSerAInte,12,02)
      @ nLin,042 PSAY Str(nFreAInte,12,02)
      @ nLin,056 PSAY Str(nDevAInte,12,02)
      @ nLin,070 PSAY Str(nTotAInte,12,02)                                             

      nLin := nLin + 1

      @ nLin,001 PSAY "FILIAL"
      @ nLin,012 PSAY "E"
      @ nLin,014 PSAY Str(nProAExte,12,02)
      @ nLin,028 PSAY Str(nSerAExte,12,02)
      @ nLin,042 PSAY Str(nFreAExte,12,02)
      @ nLin,056 PSAY Str(nDevAExte,12,02)
      @ nLin,070 PSAY Str(nTotAExte,12,02)                                             
               
      nLin := nLin + 1

      @ nLin,008 PSAY "TOTAL"
      @ nLin,014 PSAY Str((nProAInte + nProAExte),12,02)
      @ nLin,028 PSAY Str((nSerAInte + nSerAExte),12,02)
      @ nLin,042 PSAY Str((nFreAInte + nFreAExte),12,02)
      @ nLin,056 PSAY Str((nDevAInte + nDevAExte),12,02)
      @ nLin,070 PSAY Str((nTotAInte + nTotAExte),12,02)                                             

      nLin := nLin + 1

      @ nLin,001 PSAY "---------------------------------------------------------------------------------"

      nLin = nLin + 2

      // Totaliza o Período
      @ nLin,001 PSAY "TOTAL DO"
      @ nLin,012 PSAY "I"
      @ nLin,014 PSAY Str(nProGInte,12,02)
      @ nLin,028 PSAY Str(nSerGInte,12,02)
      @ nLin,042 PSAY Str(nFreGInte,12,02)
      @ nLin,056 PSAY Str(nDevGInte,12,02)
//    @ nLin,070 PSAY Str(nTotGInte,12,02)                                             
      nLin := nLin + 1

      // Verifica se existe devolução para a nota fiscal selecionada
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      @ nLin,008 PSAY "O.DEV.:"
      @ nLin,056 PSAY Str(nDevolucao,12,02)
      @ nLin,070 PSAY Str((nTotGInte + nTotGExte - nDevolucao),12,02)                                             
      nLin := nLin + 1

      @ nLin,001 PSAY "PERÍODO"
      @ nLin,012 PSAY "E"
      @ nLin,014 PSAY Str(nProGExte,12,02)
      @ nLin,028 PSAY Str(nSerGExte,12,02)
      @ nLin,042 PSAY Str(nFreGExte,12,02)
      @ nLin,056 PSAY Str(nDevGExte,12,02)
      @ nLin,070 PSAY Str(nTotGExte,12,02)                                             
      nLin := nLin + 1

      @ nLin,008 PSAY "TOTAL"
      @ nLin,014 PSAY Str((nProGInte + nProGExte),12,02)
      @ nLin,028 PSAY Str((nSerGInte + nSerGExte),12,02)
      @ nLin,042 PSAY Str((nFreGInte + nFreGExte),12,02)
      @ nLin,056 PSAY Str((nDevGInte + nDevGExte + nDevolucao),12,02)
      @ nLin,070 PSAY Str((nTotGInte + nTotGExte - nDevolucao),12,02)                                             
      nLin := nLin + 2

      @ nLin,001 PSAY "---------------------------------------------------------------------------------"

      nLin := nLin + 2

   Endif

   // Finaliza a execucao do relatorio
   SET DEVICE TO SCREEN

   // Se impressao em disco, chama o gerenciador de impressao
   If aReturn[5] == 1
      dbCommitAll()
      SET PRINTER TO
      If xTipo == "A"
         OurSpool(wnrel)
      Endif
   Endif

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

   If xTipo == "B"
      nACIPROP := Str(nACIPROP,14,02)
      nACISERP := Str(nACISERP,14,02)
      nACIFREP := Str(nACIFREP,14,02)
      nACIDEVP := Str(nACIDEVP,14,02)
      nACITOTP := Str(nACITOTP,14,02)

      nACEPROP := Str(nACEPROP,14,02)
      nACESERP := Str(nACESERP,14,02)
      nACEFREP := Str(nACEFREP,14,02)
      nACEDEVP := Str(nACEDEVP,14,02)
      nACETOTP := Str(nACETOTP,14,02)
               
      nACIPROC := Str(nACIPROC,14,02)
      nACISERC := Str(nACISERC,14,02)
      nACIFREC := Str(nACIFREC,14,02)
      nACIDEVC := Str(nACIDEVC,14,02)
      nACITOTC := Str(nACITOTC,14,02)

      nACEPROC := Str(nACEPROC,14,02)
      nACESERC := Str(nACESERC,14,02)
      nACEFREC := Str(nACEFREC,14,02)
      nACEDEVC := Str(nACEDEVC,14,02)
      nACETOTC := Str(nACETOTC,14,02)

      nACIPROL := Str(nACIPROL,14,02)
      nACISERL := Str(nACISERL,14,02)
      nACIFREL := Str(nACIFREL,14,02)
      nACIDEVL := Str(nACIDEVL,14,02)
      nACITOTL := Str(nACITOTL,14,02)

      nACEPROL := Str(nACEPROL,14,02)
      nACESERL := Str(nACESERL,14,02)
      nACEFREL := Str(nACEFREL,14,02)
      nACEDEVL := Str(nACEDEVL,14,02)
      nACETOTL := Str(nACETOTL,14,02)

      // Calcula Outras Devoluções para a Tela Gerencial
      nDevoPOA := 0
      nDevoCXS := 0
      nDevoPEL := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             If aDevolucao[nDevolve,01] == "01"
                nDevoPOA := nDevoPOA + aDevolucao[nDevolve,02]
             Endif
             If aDevolucao[nDevolve,01] == "02"
                nDevoCXS := nDevoCXS + aDevolucao[nDevolve,02]
             Endif
             If aDevolucao[nDevolve,01] == "03"
                nDevoPEL := nDevoPEL + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      nOutraPOA := Str(nDevoPOA,14,02)
      nOutraCXS := Str(nDevoCXS,14,02)
      nOutraPEL := Str(nDevoPEL,14,02)

   Endif

//   // Envia o relatório via e-mail
//   If xTipo == "C"
//      U_AUTOMR20("Faturamento por Período ref. ao mês 07/2011","aline@automatech.com.br", wnrel)
//   Endif

Return .T.

/*

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO DE FATUMANETO POR PERIODO                                                                 XX/XX/XXXX-XX:XX:XX
AUTOMR06.PRW                                                                       PERIODO DE XX/XX/XXXX A XX/XX/XXXX                                                                PAGINA:       XXXXX 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
NF     SR  NR.PV  TIPO    CODIGO    DESCRIÇÃO DOS CLIENTES                                       CIDADE                         UF    VLR PRODUTO   VLR SERVICO     VLR FRETE    DEVOLUÇÕES    VLR TOTAL
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                            FILIAL: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                            DATA..: XX/XX/XXXX

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
XXXXXX XXX XXXXXX XXXXXXX xxxxxx.xx XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX   X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX X.XXX.XXX,XX 
                                                                                                 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
                                                                                                 TOTAL PEDIDOS INTERNOS NA DATA:
                                                                                                 TOTAL PEDIDOS EXTERNOS NA DATA:
                                                                                                 TOTAL OUTRAS DEVOLUÇÕES.......: 
                                                                                                 TOTAL GERAL DA DATA...........:

                                                                                                 TOTAL PEDIDOS INTERNOS FILIAL.:
                                                                                                 TOTAL PEDIDOS EXTERNOS FILIAL.:
                                                                                                 TOTAL OUTRAS DEVOLUÇÕES.......:
                                                                                                 TOTAL GERAL DA FILIAL.........:
                                                                                                          
                                                                                                 -------------------------------------------------------------------------------------------------------                    
                                                                                                 TOTAL PEDIDOS INTERNOS PERÍODO:
                                                                                                 TOTAL PEDIDOS EXTERNOS PERÍODO:
                                                                                                 TOTAL OUTRAS DEVOLUÇÕES.......:
                                                                                                 TOTAL GERAL DO PERÍODO........:



                                                            FILIAL: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                            DATA..: XX/XX/XXXX

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
XXX  X.XXX  XXXXXX  XX/XX/XXXX  XXXXXX  XXXXXXX XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXX.XX    XX    X.XXX.XXX,XX   X.XXX.XXX,XX    X.XXX.XXX,XX   X.XXX.XXX,XX 
                                                                                                       TOTAL PEDIDOS INTERNOS NA DATA:
                                                                                                       TOTAL PEDIDOS EXTERNOS NA DATA:
                                                                                                       TOTAL GERAL DA DATA...........:

AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA    FATURAMENTO POR PERÍODO - SINTÉTICO     XX/XX/XXXX-XX:XX:XX
AUTOMR08.PRW                             PERÍODO DE XX/XX/XXXX A XX/XX/XXXX      PAGINA:       XXXXX
----------------------------------------------------------------------------------------------------
DATA        TIPO         VLR PRODUTO     VLR SERVICO       VLR FRETE      DEVOLUÇÕES       VLR TOTAL
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------"

                                        FILIAL: 01 - PORTO ALEGRE

         1         2         3         4         5         6         7         8         9       100    
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
DATA       T  VLR PRODUTO   VLR SERVICO     VLR FRETE    DEVOLUÇÕES     VLR TOTAL
XX/XX/XXXX I X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX
           E X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX
       TOTAL X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX

XX/XX/XXXX  INTERNOS  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX
            EXTERNOS  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX
            TOTAL     XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX

*/


