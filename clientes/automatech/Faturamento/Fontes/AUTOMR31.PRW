#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR31.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/10/2011                                                          *
// Objetivo..: Notas Fiscais Canceladas por Vendedor                               * 
// Parâmetros: Sem parâmetros                                                      *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR31()
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local lChumba        := .F.
   Local _aArea   		:= {}
   Local _aAlias  		:= {}
   Local cMemo1	        := ""
   Local oMemo1

   // Variáveis Private da Função
   Private dData01      := Ctod("  /  /    ")
   Private dData02      := Ctod("  /  /    ")
   Private cVendedor    := Space(06)
   Private xNomeVende   := Space(30)
   Private cEnderecos   := Space(200)
   Private cNota        := Space(10)
   Private cSerie       := Space(03)
   Private lQuebra      := .T.
   Private nVias        := 1
   Private nGet1	    := Ctod("  /  /    ")
   Private nGet2	    := Ctod("  /  /    ")
   Private nGet3	    := Space(06)
   Private nGet4        := Space(100)
   Private nGet5        := Space(200)
   Private oGet6
   Private cRetorno     := Space(500)
   Private aComboBx1    := {"VIDEO", "E-MAIL"}
   Private cComboBx1   

   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTOMR31")

   DEFINE MSDIALOG oDlg TITLE "Notas Fiscais Canceladas por Vendedor" FROM C(178),C(181) TO C(432),C(567) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(184),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Data Inicial" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(051) Say "Data Final"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(005) Say "Vendedor"     Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(005) Say "Nota Fiscal"  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(051) Say "Série"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(048),C(005) MsGet    oGet1      Var dData01    Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(048),C(051) MsGet    oGet2      Var dData02    Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(070),C(005) MsGet    oGet3      Var cVendedor  Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA3") VALID( xBuscaVend(cVendedor) )
   @ C(070),C(051) MsGet    oGet4      Var xNomeVende Size C(136),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(092),C(005) MsGet    oGet5      Var cNota      Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(092),C(051) MsGet    oGet6      Var cSerie     Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(093),C(085) CheckBox oCheckBox1 Var lQuebra    Prompt "Quebra por Vendedor" Size C(064),C(008) PIXEL OF oDlg

   @ C(109),C(056) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( I_NFCANCELADA( dData01, dData02, cVendedor, cComboBx1, cSerie))
   @ C(109),C(094) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que pesquisa o vendedor informado
Static Function xBuscaVend(cVendedor)

   Local cSql := ""
   
   If Empty(Alltrim(cVendedor))
      xNomeVende := ""
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
      xNomeVende := T_VENDEDOR->A3_NOME
   Else
      xNomeVende := ""
   Endif

   oGet4:Refresh()

Return .T.         

// Função que prepara a impressão do relatório
Static Function I_NFCANCELADA( dData01, dData02, cVendedor, cComboBx1, cSerie)

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

   Private aCanceladas  := {}

   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

   If Alltrim(cComboBx1) == "E-MAIL"
      If Empty(Alltrim(cEnderecos))
         MsgAlert("Endereços de envio de e-mail não informados.")
         Return .T.
      Endif
   Endif   

   // Pesquisa as notas fiscais canceladas
   If Select("T_CANCELADAS") > 0
      T_CANCELADAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.F2_FILIAL , "
   cSql += "       A.F2_DOC    , "
   cSql += "       A.F2_SERIE  , "
   cSql += "       A.F2_EMISSAO, "
   cSql += "       A.F2_CLIENTE, "
   cSql += "       A.F2_LOJA   , "
   cSql += "       A.F2_VALBRUT, "
   cSql += "       A.F2_VEND1  , "
   cSql += "       A.F2_VEND2  , "
   cSql += "       A.F2_VEND3  , "
   cSql += "       A.F2_VEND4  , "
   cSql += "       A.F2_VEND5  , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.F2_CHVNFE   "
   cSql += "  FROM " + RetSqlName("SF2010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B  "
   cSql += " WHERE A.F2_CLIENTE = B.A1_COD  "
   cSql += "   AND A.F2_LOJA    = B.A1_LOJA "
   cSql += "   AND A.R_E_C_D_E_L_ <> ''     "
   cSql += "   AND A.F2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)

   If !Empty(cVendedor)
      cSql += " AND (A.F2_VEND1 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR  A.F2_VEND2 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR  A.F2_VEND3 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR  A.F2_VEND4 = '" + Alltrim(cVendedor) + "'" 
      cSql += "  OR  A.F2_VEND5 = '" + Alltrim(cVendedor) + "')"                   
   Endif

   If !Empty(cNota)
      cSql += " AND A.F2_DOC = '" + Alltrim(cNota) + "'"
   Endif

   If !Empty(cSerie)
      cSql += " AND A.F2_SERIE = '" + Alltrim(cSerie) + "'"
   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CANCELADAS", .T., .T. )

   T_CANCELADAS->( DbGoTop() )

   If T_CANCELADAS->( Eof() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   // Envia para a função que imprime o relatório
   Processa( {|| INFCANCELADAS(Cabec1,Cabec2,cVendedor,nLin) }, "Aguarde...", "Gerando Relatório",.F.)

Return .T.

// Função que gera o relatório
Static Function INFCANCELADAS(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor := ""
   Local cCliente  := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
   Local _Vendedor := ""
   Local xContar   := 0
   Local nContar   := 0

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 3000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetPortrait()    // Para Retrato
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

   // Carrega o Array aPesquisa com os dados dos 5 possíveis vendedores
   T_CANCELADAS->( DbGoTop() )
   While !T_CANCELADAS->( EOF() )

       For nContar = 1 to 5
           
           xVendedor := "999999"

           Do Case
              Case nContar = 1
                   If Empty(t_canceladas->F2_vend1)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend1) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend1
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_canceladas->F2_Vend1
                      Endif
                   Endif

              Case nContar = 2
                   If Empty(t_canceladas->F2_vend2)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend2) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend2
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_canceladas->F2_Vend2
                      Endif
                   Endif

              Case nContar = 3
                   If Empty(t_canceladas->F2_vend3)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend3) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend3
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_cancealdas-F2_Vend3
                      Endif
                   Endif

              Case nContar = 4
                   If Empty(t_canceladas->F2_vend4)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(tcanceladas->F2_Vend4) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend4
                         Else
                            Loop
                         Endif
                      Else
                         xvendedor := t_canceladas->F2_Vend4
                      Endif
                   Endif

              Case nContar = 5
                   If Empty(t_canceladas->F2_vend5)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend5) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend5
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_cancealdas->F2_Vend5
                      Endif
                   Endif

           EndCase
                         
           // Pesquisa o Nome do Vendedor
           If xVendedor == "999999"
              cNomevendedor := "SEM VENDEDOR"
           Else   
              If Select("T_VENDEDOR") > 0
                 T_VENDEDOR->( dbCloseArea() )
              EndIf
   
              cSql := ""
              cSql := "SELECT A3_NOME  , "
              cSql += "       A3_NREDUZ, "
              cSql += "       A3_EMAIL   "
              cSql += "  FROM " + RetSqlName("SA3010")
              cSql += " WHERE A3_COD = '" + Alltrim(xVendedor) + "'"
                  
              cSql := ChangeQuery( cSql )
              dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
   
              If !T_VENDEDOR->( Eof() )
                 cNomeVendedor := T_VENDEDOR->A3_NOME
              Else
                 cNomeVendedor := Space(40)
              Endif
   
              T_VENDEDOR->( dbCloseArea() )
                    
           Endif   

           // Carrega o Array
           aPesq := {xVendedor                ,; // 01 - Código do vendedor
                     cNomeVendedor            ,; // 02 - Nome do Vendedor
                     T_CANCELADAS->F2_FILIAL  ,; // 03 - Filial
                     T_CANCELADAS->F2_DOC     ,; // 04 - Nº da Nota Fiscal
                     T_CANCELADAS->F2_SERIE   ,; // 05 - Nº de Série
                     T_CANCELADAS->F2_EMISSAO ,; // 06 - Data de Emissão
                     T_CANCELADAS->F2_CLIENTE ,; // 07 - Código do Cliente
                     T_CANCELADAS->F2_LOJA    ,; // 08 - Código da Loja
                     T_CANCELADAS->A1_NOME    ,; // 09 - Nome do Cliente
                     T_CANCELADAS->F2_VALBRUT ,; // 10 - Valor Bruto da Nota Fiscal
                     T_CANCELADAS->F2_CHVNFE}    // 11 - Chave de Acesso
       
           aAdd( aPesquisa, aPesq )
       
       Next nContar
       
       T_CANCELADAS->( DbSkip() )
       
   Enddo

   // Ordena o Array para Impressão
   ASORT(aPesquisa,,,{ | x,y | x[1] + x[3] + x[4] < y[1] + y[3] + y[4] } )

  If Len(aPesquisa) == 0
      Msgalert("Não existem dados a serem visualizadas.")
      Return .T.
   Endif

   cVendedor := aPesquisa[01,01]
   cNomeVend := aPesquisa[01,02]

   // Acumuladores
   nQtd      := 0
   nVendedor := 0
   nGeral    := 0
   nPagina   := 0
   _nLin     := 10
      
   ProcRegua( Len(aPesquisa) )

   // Envia para a função que imprime o cabeçalho dp relatório
   CABECACAN(cNomevend, nPagina)

   If lQuebra == .T.

      For nContar = 1 to Len(aPesquisa)
   
         If Alltrim(aPesquisa[nContar,1]) == Alltrim(cVendedor)

            // Impressão dos dados
            oPrint:Say(_nLin, 0100, aPesquisa[nContar,03]              , oFont21)  
            oPrint:Say(_nLin, 0230, Substr(aPesquisa[nContar,04],01,06), oFont21)  
            oPrint:Say(_nLin, 0400, aPesquisa[nContar,05]              , oFont21)  
            oPrint:Say(_nLin, 0550, Substr(aPesquisa[nContar,06],07,02) + "/" + Substr(aPesquisa[nContar,06],05,02) + "/" + Substr(aPesquisa[nContar,06],01,04), oFont21)  
            oPrint:Say(_nLin, 0800, aPesquisa[nContar,09], oFont21)  
            oPrint:Say(_nLin, 1440, Str(aPesquisa[nContar,10],12,02), oFont21)  
            oPrint:Say(_nLin, 1690, aPesquisa[nContar,11], oFont21)

            nQtd      := nQtd      + 1
            nVendedor := nVendedor + aPesquisa[nContar,10]
            nGeral    := nGeral    + aPesquisa[nContar,10]

            SomaLinhaCan(50,cVendedor)

            Loop

         Else

            SomaLinhaCan(50,cVendedor)
                                                                                                       
            oPrint:Say(_nLin, 0960, "QUANTIDADE DE NF CANCELADAS: ", oFont21)
            oPrint:Say(_nLin, 1440, Str(nQtd,12)                   , oFont21)  
            SomaLinhaCan(50,cVendedor)
            oPrint:Say(_nLin, 0960, "VALOR TOTAL DE NF CANCELADAS:", oFont21)
            oPrint:Say(_nLin, 1440, Str(nVendedor,12,02)           , oFont21)  
  
            nQtd      := 0
            nVendedor := 0

            cVendedor := aPesquisa[nContar,01]
            cNomeVend := aPesquisa[nContar,02]

            SomaLinhaCan(100,cVendedor)            
          
            oPrint:Say(_nLin, 0800, "VENDEDOR: " + Alltrim(cNomevend), oFont10b)  

            SomaLinhaCan(100,cVendedor)

            nContar := nContar - 1

         Endif

      Next nContar
      
   Else
      
      For nContar = 1 to Len(aPesquisa)
   
          // Impressão dos dados
          oPrint:Say(_nLin, 0100, aPesquisa[nContar,03]              , oFont21)  
          oPrint:Say(_nLin, 0230, Substr(aPesquisa[nContar,04],01,06), oFont21)  
          oPrint:Say(_nLin, 0400, aPesquisa[nContar,05]              , oFont21)  
          oPrint:Say(_nLin, 0550, Substr(aPesquisa[nContar,06],07,02) + "/" + Substr(aPesquisa[nContar,06],05,02) + "/" + Substr(aPesquisa[nContar,06],01,04), oFont21)  
          oPrint:Say(_nLin, 0800, aPesquisa[nContar,09], oFont21)  
          oPrint:Say(_nLin, 1440, Str(aPesquisa[nContar,10],12,02), oFont21)  
          oPrint:Say(_nLin, 1690, aPesquisa[nContar,11], oFont21)

          nQtd      := nQtd      + 1
          nVendedor := nVendedor + aPesquisa[nContar,10]
          nGeral    := nGeral    + aPesquisa[nContar,10]

          SomaLinhaCan(50,cVendedor)

      Next nContar

   Endif

   SomaLinhaCan(50,cVendedor)
                                                                                                       
   oPrint:Say(_nLin, 0960, "QUANTIDADE DE NF CANCELADAS: ", oFont21)
   oPrint:Say(_nLin, 1490, Str(nQtd,12)                   , oFont21)  
   SomaLinhaCan(50,cVendedor)
   oPrint:Say(_nLin, 0960, "VALOR TOTAL DE NF CANCELADAS:", oFont21)
   oPrint:Say(_nLin, 1490, Str(nVendedor,12,02)           , oFont21)  

   oPrint:EndPage()

   oPrint:Preview()

   If Select("T_CANCELADAS") > 0
      T_CANCELADAS->( dbCloseArea() )
   Endif
   
   MS_FLUSH()

Return .T.

// Imprime o cabeçalho do relatório
Static Function CABECACAN(cNomeVend, nPagina)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60

   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont21)
   oPrint:Say( _nLin, 1000, "RELAÇÃO NF CANCELADAS POR VENDEDOR"   , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()            , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR31.PRW", oFont21)
   oPrint:Say( _nLin, 1000, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "FL"                    , oFont21)  
   oPrint:Say( _nLin, 0230, "NFISCAL"               , oFont21)  
   oPrint:Say( _nLin, 0400, "SEIRE"                 , oFont21)  
   oPrint:Say( _nLin, 0550, "EMISSÃO"               , oFont21)  
   oPrint:Say( _nLin, 0800, "DESCRIÇÃO DOS CLIENTES", oFont21)  
   oPrint:Say( _nLin, 1478, "VALOR TOTAL"           , oFont21)  
   oPrint:Say( _nLin, 1690, "CHAVE ACESSO"          , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 50

   If lQuebra == .T.
      oPrint:Say( _nLin, 0800, "VENDEDOR: " + Alltrim(cNomeVend), oFont10b)
      _nLin += 60
   Endif

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaCan(nLinhas,cVendedor)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:Line( _nLin, 0100, _nLin, 2400 )
      oPrint:EndPage()
      CABECACAN(cVendedor, nPagina)
   Endif
   
Return .T.      

/*

         1         2         3         4         5         6         7         8         9       100 
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA    RELAÇÃO DE NF CANCELADAS POR VENDEDOR    XX/XX/XXXX-XX:XX:XX
AUTOMR31.PRW                             PERIODO DE XX/XX/XXXX A XX/XX/XXXX       PAGINA:       XXXXX 
-----------------------------------------------------------------------------------------------------
FL NOTA FISCAL SERIE      EMISSAO    CODIGO     DESCRIÇÃO DOS CLIENTES                       VALOR NF
-----------------------------------------------------------------------------------------------------

                          VENDEDOR: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

01 XXXXXXXXXX  XXXXXXXXXX XX/XX/XXXX XXXXXX.XXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXX.XX

QUANTIDADE DE NF CANCELADAS: XXXXX                          VALOR TOTAL DE CANCELAMENTOS XXXXXXXXX.XX

*/
