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
// Referencia: AUTOM123.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/07/2012                                                          *
// Objetivo..: Programa que gera um relatório gráfico das Ordens de Serviços En-   *
//             cerradas porém que não foram faturadas ainda.                       *
//**********************************************************************************

User Function AUTOM123()
 
   Local cSql       := ""

   Private aBrowse  := {}

   // Verifica se é necessário envia o relatório
   Do Case
      Case cFilAnt == "01"
           If File("\TREPORT\PA" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
              Return .T.
           Endif
      Case cFilAnt == "02"
           If File("\TREPORT\CX" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
              Return .T.
           Endif
      Case cFilAnt == "03"
           If File("\TREPORT\PL" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
              Return .T.
           Endif
   EndCase           
      
   // Verifica se a data do sistema está entre o dia 5 a 10 do mês vigente
   // Somente envia o relatório via e-mail entre os dias 5 a 10 de cada mês
   If Day(date()) >= 5 .And. Day(Date()) <= 10
   Else
      Return .T.
   Endif
      
   // Pesquisa as Ordens de Serviço Encerradas e não faturadas
   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.AB7_NUMOS ,"
   cSql += "       A.AB7_FILIAL,"
   cSql += "       A.AB7_ITEM  ,"
   cSql += "       C.AB6_ETIQUE,"
   cSql += "       B.C6_NUMOS  ,"
   cSql += "       B.C6_NUM    ,"
   cSql += "       A.AB7_CODCLI,"
   cSql += "       A.AB7_LOJA  ,"
   cSql += "       D.A1_NOME   ,"
   cSql += "       A.AB7_CODPRO,"
   cSql += "       E.B1_DESC   ,"
   cSql += "       E.B1_DAUX    "
   cSql += "  FROM " + RetSqlName("AB7") + " A INNER JOIN "
   cSql += "       " + RetSqlName("SC6") + " B ON (A.AB7_NUMOS + A.AB7_FILIAL + A.AB7_ITEM) = B.C6_NUMOS"
   cSql += "       INNER JOIN " + RetSqlName("AB6") + " C ON A.AB7_FILIAL = C.AB6_FILIAL AND A.AB7_NUMOS = C.AB6_NUMOS ,"
   cSql += "       " + RetSqlName("SA1") + " D, "
   cSql += "       " + RetSqlName("SB1") + " E  "
   cSql += " WHERE C.AB6_STATUS   = 'E'"
   cSql += "   AND B.C6_NOTA      = '' "
   cSql += "   AND A.R_E_C_D_E_L_ = '' "
   cSql += "   AND C.R_E_C_D_E_L_ = '' "
   cSql += "   AND A.AB7_CODCLI   = D.A1_COD "
   cSql += "   AND A.AB7_LOJA     = D.A1_LOJA"
   cSql += "   AND A.AB7_CODPRO   = E.B1_COD "
   cSql += "   AND A.AB7_CODCLI <> '000329'  "
   cSql += "   AND A.AB7_CODCLI <> '016166'  "
   cSql += "   AND A.AB7_CODCLI <> '000374'  "
   cSql += "   AND A.AB7_FILIAL   = '" + Alltrim(cFilAnt) + "'"
   cSql += " ORDER BY A.AB7_FILIAL, D.A1_NOME"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )

   If T_PEDIDOS->( EOF() )
      Return .T.
   Endif
   
   T_PEDIDOS->( DbGoTop() )
   WHILE !T_PEDIDOS->( EOF() )
      aAdd( aBrowse, { T_PEDIDOS->AB7_FILIAL,;
                       T_PEDIDOS->AB6_ETIQUE,;
                       T_PEDIDOS->AB7_NUMOS ,;
                       T_PEDIDOS->C6_NUM    ,;
                       T_PEDIDOS->AB7_CODCLI,;
                       T_PEDIDOS->AB7_LOJA  ,;
                       T_PEDIDOS->A1_NOME   ,;
                       Alltrim(T_PEDIDOS->AB7_CODPRO),;
                       Alltrim(T_PEDIDOS->B1_DESC) + " " + Alltrim(T_PEDIDOS->B1_DAUX) } )
      T_PEDIDOS->( DbSkip() )
   ENDDO   

   If Len(aBrowse) == 0
      Return .T.
   Endif

   // Envia para função que imprime o relatório e o envia via e-mail
   OS_SEM_FATURA()

Return(.T.)

// Função que Imprime o relatório e o envia via e-mail
Static Function OS_SEM_FATURA()

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
   Private nomeprog     := "OS Sem Faturamento"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "OS Sem Faturamento"
   Private cString      := "SC5"

   Private aDevolucao   := {}
   Private nDevolve     := 0

   // Envia para a função que imprime o relatório
   IMPRELATORIO(Cabec1,Cabec2,"",nLin)

Return .T.

// Função que gera o relatório
Static Function IMPRELATORIO(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor  := ""
   Local cCliente   := ""
   Local cLoja      := ""
   Local cNomeCli   := ""
   Local nContar    := 0

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape()  // Para Paisagem
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont5    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
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

   cCliente  := aBrowse[01,05]
   cLoja     := aBrowse[01,06]
   cNomeCli  := aBrowse[01,07]

   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( Len(aBrowse) )

   // Envia para a função que imprime o cabeçalho dp relatório
   CABECAFAT(cCliente, cLoja, cNomeCli)

   For nContar = 1 to Len(aBrowse)
   
      If Alltrim(aBrowse[nContar,05]) == Alltrim(cCliente) .And. Alltrim(aBrowse[nContar,06]) == Alltrim(cLoja)

         oPrint:Say(_nLin, 0100, aBrowse[nContar,01], oFont5)  
         oPrint:Say(_nLin, 0160, aBrowse[nContar,02], oFont5)  
         oPrint:Say(_nLin, 0330, aBrowse[nContar,03], oFont5)  
         oPrint:Say(_nLin, 0450, aBrowse[nContar,04], oFont5)  
         oPrint:Say(_nLin, 0630, aBrowse[nContar,08], oFont5)  
         oPrint:Say(_nLin, 0750, aBrowse[nContar,09], oFont5)  

         SomaLinhaVen(50,cCliente, cLoja, cNomeCli)            

      Else

         cCliente := aBrowse[nContar,05]
         cLoja    := aBrowse[nContar,06]
         cNomeCli := aBrowse[nContar,07]

         oPrint:Say( _nLin, 0630, "CLIENTE.: " + Alltrim(cCliente) + "." + Alltrim(cLoja) + " - " + Alltrim(cNomeCli), oFont10b)

         SomaLinhaVen(060,cVendedor, cCliente)            

         nContar := nContar - 1

      Endif

   Next nContar

   oPrint:Say(_nLin, 0100, "FIM DO RELATÓRIO", oFont5)

   oPrint:EndPage()

   MS_FLUSH()

   // Gera Array com a quantidade de páginas a serem salvas em HTML
   For xContar = 1 to nPagina
       Aadd( aPaginas, xContar )
   Next xContar    

   // Pesquisa dados para envio de e-mail
   do case  
      case cFilant == "01"
           cEmail := 'admtecpoa@automatech.com.br'
      case cFilant == "02"
           cEmail := 'admteccax@automatech.com.br'
      case cFilant == "03"
           cEmail := 'admtecpel@automatech.com.br'
   endcase

   // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
   Do Case
      Case cFilAnt == "01"
           If File("\TREPORT\PA" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
              Ferase("\TREPORT\PA" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
           Endif
           cFileHTML := "\TREPORT\PA" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM"
           
      Case cFilAnt == "02"
           If File("\TREPORT\CX" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
              Ferase("\TREPORT\CX" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
           Endif
           cFileHTML := "\TREPORT\CX" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM"

      Case cFilAnt == "03"
           If File("\TREPORT\PL" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
              Ferase("\TREPORT\PL" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM")
           Endif
           cFileHTML := "\TREPORT\PL" + STRZERO(MONTH(DATE()),2) + STRZERO(YEAR(DATE()),4) + ".HTM"
   EndCase           

   // Salva o relatório em HTML
   oPrint:SaveAsHtml(cFileHTML, aPaginas )

   // Envia o relatório via e-mail
   cErroEnvio := U_AUTOMR20("Segue em anexo relação de Ordens de Serviços que foram encerradas porém ainda não foram faturadas para a sua análise.", ;
                             Alltrim(cEmail)                                          , ;
                             cFileHTML                                                , ;
                             "Relaçao de OS encerradas e não faturadas.")

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por Vendedor
Static Function CABECAFAT(cCliente, cLoja, cNomeCli)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"         , oFont21)
   oPrint:Say( _nLin, 0950, "ORDENS DE SERVIÇO ENCERRADAS E NÃO FATURADAS"  , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()                     , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM123.PRW", oFont21)
   oPrint:Say( _nLin, 0950, "PERÍODO: " + STRZERO(MONTH(DATE()),2) + "/" + STRZERO(YEAR(DATE()),4), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "  + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20
  
   oPrint:Say( _nLin, 0100, "FL"                    , oFont21)  
   oPrint:Say( _nLin, 0160, "ETIQUETA"              , oFont21)  
   oPrint:Say( _nLin, 0330, "Nº OS"                 , oFont21)  
   oPrint:Say( _nLin, 0450, "Nº PEDIDO"             , oFont21)  
   oPrint:Say( _nLin, 0630, "PRODUTO"               , oFont21)  
   oPrint:Say( _nLin, 0750, "DESCRICAO DOS PRODUTOS", oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 50
   oPrint:Say( _nLin, 0630, "CLIENTE.: " + Alltrim(cCliente) + "." + Alltrim(cLoja) + " - " + Alltrim(cNomeCli), oFont10b)
   _nLin += 60

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaVen(nLinhas,cCliente, cLoja, cNomeCli)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAFAT(cCliente, cLoja, cNomeCli)
   Endif
   
Return .T.