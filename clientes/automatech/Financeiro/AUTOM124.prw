#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM124.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/07/2012                                                          *
// Objetivo..: Relação de Títulos por Situação                                     * 
//**********************************************************************************

User Function AUTOM124()

   Local lChumba     := .F.
   Local cSql        := ""

   Private aConsulta := {}

   Private aComboBx1 := {"0 - Todos","1 - Pago", "2 - Negociado", "3 - Cartório", "4 - Baixa", "5 - Abatimento", "6 - Externo", "7 - Outros"}
   Private aComboBx2 := {"A - Analítico","S - Sintético"}
   Private aComboBx3 := {"C - Conta Corrente","U - Última Lista de Cobrança"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private cInicial	 := Ctod("  /  /    ")
   Private cFinal  	 := Ctod("  /  /    ")
   Private cCliente  := Space(06)
   Private cLoja 	 := Space(03)
   Private cNomeCli  := Space(40)
   Private cVendedor := Space(06)
   Private cNomeVen	 := Space(40)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlg

   U_AUTOM628("AUTOM124")

   DEFINE MSDIALOG oDlg TITLE "Relação de Títulos por Situação" FROM C(178),C(181) TO C(335),C(548) PIXEL

   @ C(005),C(005) Say "Vencimento Inicial" Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(005) Say "Vencimento Final"   Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(005) Say "Status"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(005) Say "Tipo Visualização"  Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(004),C(055) MsGet oGet1 Var cInicial Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(017),C(055) MsGet oGet2 Var cFinal   Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(030),C(054) ComboBox cComboBx1 Items aComboBx1 Size C(111),C(010) PIXEL OF oDlg
   @ C(044),C(054) ComboBox cComboBx2 Items aComboBx2 Size C(111),C(010) PIXEL OF oDlg

   @ C(060),C(055) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( GERAPESQ() )
   @ C(060),C(093) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o cliente informado
Static Function PEGACLIENTE()

   Local cSql := ""
   
   If Empty(Alltrim(cCliente))
      Return .T.
   Endif
   
   If Select("T_CLIENTE") > 0
   	  T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_NOME  "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(cCliente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(cLoja)    + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := ""
   Else
      cNomeCli := T_CLIENTE->A1_NOME
   Endif
   
Return .T.

// Função que pesquisa o Vendedor informado
Static Function PEGAVENDEDOR()

   Local cSql := ""
   
   If Empty(Alltrim(cVendedor))
      Return .T.
   Endif
   
   If Select("T_VENDEDOR") > 0
   	  T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD , "
   cSql += "       A3_NOME  "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE A3_COD  = '" + Alltrim(cVendedor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      cVendedor := Space(06)
      cNomeven  := ""
   Else
      cNomeVen := T_VENDEDOR->A3_NOME
   Endif
   
Return .T.

// Função que gera a pesquisa conforme parâmetros informados
Static Function GERAPESQ()

   Local cSql           := ""
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
   Private nomeprog     := "Relação de Títulos por Status"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Titulos-Status"
   Private cString      := "SC5"

   aConsulta := {}

   If Empty(cInicial)
      MsgAlert("Data inicial de pesquisa não informada.")
      Return .T.
   Endif
     
   If Empty(cFinal)
      MsgAlert("Data final de pesquisa não informada.")
      Return .T.
   Endif

   If cFinal < cInicial
      MsgAlert("Datas informadas são inválidas.")
      Return .T.
   Endif
   
   If Substr(cComboBx2,01,01) == "A"
      // Realiza a pesquisa para emissão do relatório
      If Select("T_TITULOS") > 0
         T_TITULOS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT DISTINCT       " + CHR(13)
      cSql += "       ACG.ACG_PREFIX," + CHR(13)
      cSql += "       ACG.ACG_TITULO," + CHR(13)
      cSql += "       ACG.ACG_PARCEL," + CHR(13)
      cSql += "       ACG.ACG_STATUS," + CHR(13)
      cSql += "       ACG.ACG_VALOR ," + CHR(13)
      cSql += "       ACG.ACG_DTVENC," + CHR(13)
      cSql += "       ACG.ACG_TIPO  ," + CHR(13)
      cSql += "       ACF.ACF_FILIAL," + CHR(13)
      cSql += "       ACF.ACF_CODIGO," + CHR(13)
      cSql += "       ACF.ACF_CLIENT," + CHR(13)
      cSql += "       ACF.ACF_LOJA  ," + CHR(13)
      cSql += "       SA1.A1_NOME    " + CHR(13)
      cSql += "  FROM " + RetSqlName("ACG") + " ACG, " + CHR(13)
      cSql += "       " + RetSqlName("ACF") + " ACF, " + CHR(13)
      cSql += "       " + RetSqlName("SA1") + " SA1  " + CHR(13)
      cSql += " WHERE ACG_DTVENC     >= '"  + Dtos(cInicial) + "'" + CHR(13)
      cSql += "   AND ACG_DTVENC     <= '"  + Dtos(cFinal)   + "'" + CHR(13)
      cSql += "   AND ACG.D_E_L_E_T_  = ''" + CHR(13)
      cSql += "   AND ACG.ACG_FILIAL  = ACF.ACF_FILIAL" + CHR(13)
      cSql += "   AND ACG.ACG_CODIGO  = ACF.ACF_CODIGO" + CHR(13)
      cSql += "   AND ACF.ACF_CLIENT  = SA1.A1_COD    " + CHR(13)
      cSql += "   AND ACF.ACF_LOJA    = SA1.A1_LOJA   " + CHR(13)

      If Substr(cComboBx1,01,01) == "0"
      Else
         Do Case
            Case Substr(cComboBx1,01,01) == "1"
                 cSql += "  AND ACG.ACG_STATUS = '1'"  + CHR(13)
            Case Substr(cComboBx1,01,01) == "2"
                 cSql += "  AND ACG.ACG_STATUS = '2'"  + CHR(13)
            Case Substr(cComboBx1,01,01) == "3"
                 cSql += "  AND ACG.ACG_STATUS = '3'"  + CHR(13)
            Case Substr(cComboBx1,01,01) == "4"
                 cSql += "  AND ACG.ACG_STATUS = '4'"  + CHR(13)
            Case Substr(cComboBx1,01,01) == "5"
                 cSql += "  AND ACG.ACG_STATUS = '5'"  + CHR(13)
            Case Substr(cComboBx1,01,01) == "6"
                 cSql += "  AND ACG.ACG_STATUS = '6'"  + CHR(13)
            Case Substr(cComboBx1,01,01) == "7"
                 cSql += "  AND ACG.ACG_STATUS = '7'"  + CHR(13)
         EndCase        
      Endif

      cSql += "   AND ACG.ACG_CODIGO  = " + CHR(13)
      cSql += "       (" + CHR(13)
      cSql += "        SELECT MAX(U.ACG_CODIGO)" + CHR(13)
      cSql += "          FROM " + RetSqlName("ACG") + " U  " + CHR(13)
      cSql += "         WHERE U.ACG_PREFIX = ACG.ACG_PREFIX" + CHR(13)
      cSql += "           AND U.ACG_TITULO = ACG.ACG_TITULO" + CHR(13)
      cSql += "           AND U.ACG_PARCEL = ACG.ACG_PARCEL" + CHR(13)
      cSql += "           AND U.ACG_TIPO = ACG.ACG_TIPO    " + CHR(13)
      cSql += "       )" + CHR(13)
      cSql += " GROUP BY ACG.ACG_PREFIX, ACG.ACG_TITULO, ACG.ACG_PARCEL, ACG.ACG_STATUS, " + CHR(13)
      cSql += "          ACG.ACG_VALOR , ACG.ACG_DTVENC, ACG.ACG_TIPO  , ACF.ACF_FILIAL, " + CHR(13)
      cSql += "          ACF.ACF_CODIGO, ACF.ACF_CLIENT, ACF.ACF_LOJA  , SA1.A1_NOME     " + CHR(13)
      cSql += " ORDER BY ACG.ACG_STATUS, SA1.A1_NOME                                     " + CHR(13)
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TITULOS", .T., .T. )

      If T_TITULOS->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif
      
      // Carrega o array aConsulta com os dados a serem impressos
      T_TITULOS->( DbGoTop() )
    
      WHILE !T_TITULOS->( EOF() )

         // Posiciona o título para capturar dados complementares para gravação
         DbSelectArea("SE1")
         DbSetOrder(1)
         If DbSeek(xfilial("SE1") + T_TITULOS->ACG_PREFIX + T_TITULOS->ACG_TITULO + T_TITULOS->ACG_PARCEL + T_TITULOS->ACG_TIPO)
            __xEmissao  := SE1->E1_EMISSAO
            __xVendedor := SE1->E1_VEND1

            // Filtra o registro em caso de Status 0, 1 ou 4
            If Empty(Alltrim(T_TITULOS->ACG_STATUS))
               If !Empty(SE1->E1_BAIXA)
                  T_TITULOS->( DbSkip() )                  
                  Loop
               Endif
            Endif
         Else
            __xEmissao  := ""
            __xVendedor := ""
         Endif
         
         // Pesquisa o nome do Vendedor
         DbSelectArea("SA3")
         DbSetOrder(1)
         If DbSeek(xfilial("SA3") + __xVendedor)
            __nVendedor := SA3->A3_NOME
         Else
            __nVendedor := ""
         Endif

         // Inclui no Array aConsulta
         aAdd( aConsulta, { T_TITULOS->ACG_STATUS ,; // 01
                            T_TITULOS->ACF_CLIENT ,; // 02
                            T_TITULOS->ACF_LOJA   ,; // 03
                            T_TITULOS->A1_NOME    ,; // 04
                            T_TITULOS->ACG_TITULO ,; // 05
                            T_TITULOS->ACG_PREFIX ,; // 06
                            T_TITULOS->ACG_PARCEL ,; // 07
                            __xEmissao            ,; // 08
                            T_TITULOS->ACG_DTVENC ,; // 09
                            T_TITULOS->ACG_VALOR  ,; // 10
                            __nVendedor           }) // 11
           
         T_TITULOS->( DbSkip() )
      Enddo
   Else
      
      // Realiza a pesquisa para emissão do relatório sintético
      If Select("T_TITULOS") > 0
         T_TITULOS->( dbCloseArea() )
      EndIf
   
      cSql := ""

      cSql := "SELECT ACG.ACG_STATUS             ,"
      cSql += "       SUM(ACG.ACG_VALOR) AS VALOR,"
      cSql += "       COUNT(DISTINCT ACG.ACG_PREFIX + ACG.ACG_TITULO + ACG.ACG_PARCEL + ACG.ACG_TIPO) AS QTD"
      cSql += "  FROM " + RetSqlName("ACG") + " ACG "
      cSql += " WHERE ACG_DTVENC         >= '" + Dtos(cInicial) + "'"
      cSql += "   AND ACG_DTVENC         <= '" + Dtos(cFinal)   + "'"
      cSql += "       AND ACG.D_E_L_E_T_  = ''

      If Substr(cComboBx1,01,01) == "0"
      Else
         Do Case
            Case Substr(cComboBx1,01,01) == "1"
                 cSql += "  AND ACG.ACG_STATUS = '1'" 
            Case Substr(cComboBx1,01,01) == "2"
                 cSql += "  AND ACG.ACG_STATUS = '2'" 
            Case Substr(cComboBx1,01,01) == "3"
                 cSql += "  AND ACG.ACG_STATUS = '3'" 
            Case Substr(cComboBx1,01,01) == "4"
                 cSql += "  AND ACG.ACG_STATUS = '4'" 
            Case Substr(cComboBx1,01,01) == "5"
                 cSql += "  AND ACG.ACG_STATUS = '5'" 
            Case Substr(cComboBx1,01,01) == "6"
                 cSql += "  AND ACG.ACG_STATUS = '6'" 
            Case Substr(cComboBx1,01,01) == "7"
                 cSql += "  AND ACG.ACG_STATUS = '7'" 
         EndCase        
      Endif

      cSql += "       AND ACG.ACG_CODIGO  = "
      cSql += "      ("
      cSql += "       SELECT MAX(U.ACG_CODIGO)"
      cSql += "         FROM " + RetSqlName("ACG") + " U "
      cSql += "        WHERE U.ACG_PREFIX = ACG.ACG_PREFIX"
      cSql += "          AND U.ACG_TITULO = ACG.ACG_TITULO"
      cSql += "          AND U.ACG_PARCEL = ACG.ACG_PARCEL"
      cSql += "          AND U.ACG_TIPO = ACG.ACG_TIPO    "
      cSql += "      )"
      cSql += " GROUP BY ACG.ACG_STATUS"
      cSql += " ORDER BY ACG.ACG_STATUS"
 
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TITULOS", .T., .T. )

      If T_TITULOS->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif
      
      // Carrega o array aConsulta com os dados a serem impressos
      T_TITULOS->( DbGoTop() )
    
      WHILE !T_TITULOS->( EOF() )
         // Inclui no Array aConsulta
         aAdd( aConsulta, { T_TITULOS->ACG_STATUS ,; // 01
                            T_TITULOS->VALOR      ,; // 02
                            T_TITULOS->QTD        }) // 03

         T_TITULOS->( DbSkip() )

      ENDDO   
   
   ENDIF

   // Envia para a função que imprime o relatório
   Processa( {|| GTITULOREL(Cabec1,Cabec2,cVendedor,nLin) }, "Aguarde...", "Gerando Relatório",.F.)

Return .T.

// Função que gera o relatório
Static Function GTITULOREL(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor  := ""
   Local cCliente   := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local _Vendedor  := ""
   Local xContar    := 0
   Local nContar    := 0
   Local nOutrasDev := 0
   Local xVendedor  := ""
   Local xVendAnte  := ""

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   Private aSintetico := {}
   Private nT_Geral   := 0

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

   // Ordena o Array aConsulta por Status
   If Substr(cComboBx2,01,01) == "A"
      ASORT(aConsulta,,,{ | x,y | x[1] + x[4] < y[1] + y[4] } )
   Endif   
  
   // Início da impressão do relatório
   If Substr(cComboBx2,01,01) == "A"
      cStatus   := aConsulta[01,01]
      cCliente  := aConsulta[01,04]
   Endif   

   nSubCli   := 0
   nTotSta   := 0

   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( RecCount() )

   // Envia para a função que imprime o cabeçalho do relatório
   If Substr(cComboBx2,01,01) == "A"

      CABECASTA(cStatus)

      For nContar = 1 to Len(aConsulta)

         If aConsulta[nContar,01] == cStatus

            If Alltrim(aConsulta[nContar,04]) == Alltrim(cCliente)

               oPrint:Say(_nLin, 0100, Alltrim(aConsulta[nContar,02]) + "." + Alltrim(aConsulta[nContar,03]), oFont5)  
               oPrint:Say(_nLin, 0300, Alltrim(aConsulta[nContar,04])         , oFont5)  
               oPrint:Say(_nLin, 1010, aConsulta[nContar,05]                  , oFont5)  
               oPrint:Say(_nLin, 1200, aConsulta[nContar,06]                  , oFont5)  
               oPrint:Say(_nLin, 1350, aConsulta[nContar,07]                  , oFont5)  

               If !Empty(aConsulta[nContar,08])
                  oPrint:Say(_nLin, 1500, Dtoc(aConsulta[nContar,08])            , oFont5)  
               Endif
                  
               If !Empty(aConsulta[nContar,09])
                  oPrint:Say(_nLin, 1800, SUBSTR(aConsulta[nContar,09],07,02) + "/" + SUBSTR(aConsulta[nContar,09],05,02) + "/" + SUBSTR(aConsulta[nContar,09],01,04), oFont5)  
               Endif   

               oPrint:Say(_nLin, 2120, TRANSFORM(aConsulta[nContar,10],"@E 999,999,999.99")   , oFont5)  
               oPrint:Say(_nLin, 2450, Alltrim(aConsulta[nContar,11]), oFont5)  

               nSubCli := nSubCli + aConsulta[nContar,10]
               nTotSta := nTotSta + aConsulta[nContar,10]

               SomaLinhaVen(50,cStatus)

               T_TITULOS->( DbSkip() )

               Loop
            
            Else
         
               oPrint:Say(_nLin, 1710, "Total do Cliente:"                   , oFont21)  
               oPrint:Say(_nLin, 2120, TRANSFORM(nSubCli,"@E 999,999,999.99"), oFont21)  

               SomaLinhaVen(100,cStatus)

               cCliente := aConsulta[nContar,04]
               nSubCli  := 0
                                                
               nContar := nContar - 1

            Endif

         Else

            SomaLinhaVen(50,cStatus)
         
            oPrint:Say(_nLin, 1710, "Total do Cliente:"                   , oFont21)  
            oPrint:Say(_nLin, 2120, TRANSFORM(nSubCli,"@E 999,999,999.99"), oFont21)  

            SomaLinhaVen(50,cStatus)

            Do case
               Case Empty(Alltrim(cStatus)) 
                    oPrint:Say(_nLin, 1710, "Total Status (Sem Status):" , oFont21)  
               Case Alltrim(cStatus) == "1" 
                    oPrint:Say(_nLin, 1710, "Total Status (PAGO):"       , oFont21)  
               Case Alltrim(cStatus) == "2" 
                    oPrint:Say(_nLin, 1710, "Total Status (NEGOCIADO):"  , oFont21)  
               Case Alltrim(cStatus) == "3" 
                    oPrint:Say(_nLin, 1710, "Total Status (CARTÓRIO):"   , oFont21)  
               Case Alltrim(cStatus) == "4" 
                    oPrint:Say(_nLin, 1710, "Total Status (BAIXA):"      , oFont21)  
               Case Alltrim(cStatus) == "5" 
                    oPrint:Say(_nLin, 1710, "Total Status (ABATIMENTO):" , oFont21)  
               Case Alltrim(cStatus) == "6" 
                    oPrint:Say(_nLin, 1710, "Total Status (EXTERNO):"    , oFont21)  
               Case Alltrim(cStatus) == "7" 
                    oPrint:Say(_nLin, 1710, "Total Status (OUTROS):"     , oFont21)  
            EndCase

            oPrint:Say(_nLin, 2120, TRANSFORM(nTotSta,"@E 999,999,999.99"), oFont21)  

            cStatus  := aConsulta[nContar,01]
            cCliente := aConsulta[nContar,04]
            nSubCli  := 0  
            ntotsta := 0

            SomaLinhaVen(100,cStatus)
            
            Do Case
               Case Empty(Alltrim(cStatus))
                    oPrint:Say(_nLin, 1400, "STATUS: Sem Indicação de Status", oFont10b)  
               Case Alltrim(cStatus) == "1"
                    oPrint:Say(_nLin, 1400, "STATUS: 1 - PAGO"      , oFont10b)  
               Case Alltrim(cStatus) == "2"
                    oPrint:Say(_nLin, 1400, "STATUS: 2 - NEGOCIADO" , oFont10b)  
               Case Alltrim(cStatus) == "3"
                    oPrint:Say(_nLin, 1400, "STATUS: 3 - CARTÓRIO"  , oFont10b)  
               Case Alltrim(cStatus) == "4"
                    oPrint:Say(_nLin, 1400, "STATUS: 4 - BAIXA"     , oFont10b)  
               Case Alltrim(cStatus) == "5"
                    oPrint:Say(_nLin, 1400, "STATUS: 5 - ABATIMENTO", oFont10b)  
               Case Alltrim(cStatus) == "6"
                    oPrint:Say(_nLin, 1400, "STATUS: 6 - EXTERNO"   , oFont10b)  
               Case Alltrim(cStatus) == "7"
                    oPrint:Say(_nLin, 1400, "STATUS: 7 - OUTROS"    , oFont10b)  
            EndCase

            SomaLinhaVen(100,cStatus)

            nContar := nContar - 1

         Endif
         
      Next nContar

      // Imprime o total do último Cliente
      SomaLinhaVen(50,cStatus)
      oPrint:Say(_nLin, 1710, "Total do Cliente:"                   , oFont21)  
      oPrint:Say(_nLin, 2120, TRANSFORM(nSubCli,"@E 999,999,999.99"), oFont21)  

      // Imprime o total do Status
      SomaLinhaVen(50,cStatus)

      Do case
         Case Empty(Alltrim(cStatus)) 
              oPrint:Say(_nLin, 1710, "Total Status (Sem Status):", oFont21)  
         Case Alltrim(cStatus) == "1" 
              oPrint:Say(_nLin, 1710, "Total Status (PAGO):"      , oFont21)  
         Case Alltrim(cStatus) == "2" 
              oPrint:Say(_nLin, 1710, "Total Status (NEGOCIADO):" , oFont21)  
         Case Alltrim(cStatus) == "3" 
              oPrint:Say(_nLin, 1710, "Total Status (CARTÓRIO):"  , oFont21)  
         Case Alltrim(cStatus) == "4" 
              oPrint:Say(_nLin, 1710, "Total Status (BAIXA):"     , oFont21)  
         Case Alltrim(cStatus) == "5" 
              oPrint:Say(_nLin, 1710, "Total Status (ABATIMENTO):", oFont21)  
         Case Alltrim(cStatus) == "6" 
              oPrint:Say(_nLin, 1710, "Total Status (EXTERNO):"   , oFont21)  
         Case Alltrim(cStatus) == "7" 
              oPrint:Say(_nLin, 1710, "Total Status (OUTROS):"     , oFont21)  
      EndCase

      oPrint:Say(_nLin, 2120, TRANSFORM(nTotSta,"@E 999,999,999.99"), oFont21)  
      
   Else   

      cStatus := aConsulta[01,01]
      nTotSta := aConsulta[01,02]

      CABECASTA(cStatus)

      // Imprime o Relatorio Sintético

      nT_Geral := 0

      For nContar = 1 to Len(aConsulta)
          Do case
             Case Empty(Alltrim(aConsulta[nContar,01]))
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " SEM STATUS" , oFont21)  
             Case aConsulta[nContar,01] == "1"
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " PAGOS"      , oFont21)  
             Case aConsulta[nContar,01] == "2"
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " NEGOCIADOS" , oFont21)  
             Case aConsulta[nContar,01] == "3"
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " EM CARTÓRIO", oFont21)  
             Case aConsulta[nContar,01] == "4"
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " BAIXADOS"   , oFont21)  
             Case aConsulta[nContar,01] == "5"
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " ABATIMENTOS", oFont21)  
             Case aConsulta[nContar,01] == "6"
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " EXTERNOS"   , oFont21)  
             Case aConsulta[nContar,01] == "7"
                  oPrint:Say(_nLin, 1350, TRANSFORM(aConsulta[nContar,03],"99999") + " OUTROS"     , oFont21)  
          EndCase

          oPrint:Say(_nLin, 1700, TRANSFORM(aConsulta[nContar,02],"@E 999,999,999.99"), oFont21)  
          SomaLinhaVen(50,cStatus)

          nT_Geral := nT_Geral + aConsulta[nContar,02]

      Next nContar    

      SomaLinhaVen(50,cStatus)
      oPrint:Say(_nLin, 1350, "TOTAL STATIS"                         , oFont21)  
      oPrint:Say(_nLin, 1700, TRANSFORM(nT_Geral,"@E 999,999,999.99"), oFont21)  

   Endif

   If Select("T_TITULOS") > 0
      T_TITULOS->( dbCloseArea() )
   Endif

   oPrint:EndPage()
   
   MS_FLUSH()

   oPrint:Preview()

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por Vendedor
Static Function CABECASTA(cStatus)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "TÍTULOS EM COBRANÇA POR STATUS"       , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM124", oFont09  )

   If Substr(cComboBx2,01,01) == "A"
      oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(cInicial) + " A " + Dtoc(cFinal) + " - ANALÍTICO", oFont09)
   Else   
      oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(cInicial) + " A " + Dtoc(cFinal) + " - SINTÉTICO", oFont09)
   Endif         
      
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   If Substr(cComboBx2,01,01) == "A"   
      oPrint:Say( _nLin, 0100, "COD/LOJA"              , oFont21)  
      oPrint:Say( _nLin, 0300, "DESCRIÇÃO DOS CLIENTES", oFont21)  
      oPrint:Say( _nLin, 1010, "Nº TÍTULO"             , oFont21)  
      oPrint:Say( _nLin, 1200, "PREFIXO"               , oFont21)  
      oPrint:Say( _nLin, 1350, "PARCELA"               , oFont21)  
      oPrint:Say( _nLin, 1500, "EMISSÃO"               , oFont21)  
      oPrint:Say( _nLin, 1800, "VCTº REAL"             , oFont21)  
//    oPrint:Say( _nLin, 1900, "ATRASO"                , oFont21)  
      oPrint:Say( _nLin, 2140, "VALOR TÍTULO"          , oFont21)  
      oPrint:Say( _nLin, 2450, "VENDEDOR"              , oFont21)  
//    oPrint:Say( _nLin, 2800, "LISTA Nº"              , oFont21)  
//    oPrint:Say( _nLin, 3000, "OPERADOR"              , oFont21)  
      _nLin += 50
      oPrint:Line( _nLin, 0100, _nLin, 3350 )
      _nLin += 50

      Do Case
         Case Empty(Alltrim(cStatus))
              oPrint:Say(_nLin, 1400, "STATUS: Sem Indicação de Status", oFont10b)  
         Case Alltrim(cStatus) == "1"
              oPrint:Say(_nLin, 1400, "STATUS: 1 - PAGO"      , oFont10b)  
         Case Alltrim(cStatus) == "2"
              oPrint:Say(_nLin, 1400, "STATUS: 2 - NEGOCIADO" , oFont10b)  
         Case Alltrim(cStatus) == "3"
              oPrint:Say(_nLin, 1400, "STATUS: 3 - CARTÓRIO"  , oFont10b)  
         Case Alltrim(cStatus) == "4"
              oPrint:Say(_nLin, 1400, "STATUS: 4 - BAIXA"     , oFont10b)  
         Case Alltrim(cStatus) == "5"
              oPrint:Say(_nLin, 1400, "STATUS: 5 - ABATIMENTO", oFont10b)  
         Case Alltrim(cStatus) == "6"
              oPrint:Say(_nLin, 1400, "STATUS: 6 - EXTERNO"   , oFont10b)  
         Case Alltrim(cStatus) == "7"
              oPrint:Say(_nLin, 1400, "STATUS: 7 - OUTROS"    , oFont10b)  
      EndCase

    Endif

   _nLin += 100
   
Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaVen(nLinhas, cStatus)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECASTA(cStatus)
   Endif
   
Return .T.