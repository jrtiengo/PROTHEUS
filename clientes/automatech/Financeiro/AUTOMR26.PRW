#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR26.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/10/2011                                                          *
// Objetivo..: Programa que verifica a duplicidade do NOSSO NÚMERO                 *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR26()
 
   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea    := {}
   Local _aAlias   := {}

   Private dData01 := Ctod("  /  /    ")
   Private dData02 := Ctod("  /  /    ")
   Private nGet1   := Ctod("  /  /    ")
   Private nGet2   := Ctod("  /  /    ")

   // Diálogo Principal
   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Verificador NOSSO NÚMERO" FROM C(178),C(181) TO C(400),C(630) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(009),C(008) Say "Este procedimento tem por finalidade de verificar duplicidade/Sem Informação do NOSSO NÚMERO."                  Size C(258),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(019),C(008) Say "Após a verificação, caso haja duplicidade/Sem informação, o sistema emitirá um relatório  com  as informações " Size C(260),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(008) Say "dos números encontrados. NÃO SÃO LISTADOS REGISTRO DE PREFIXO I."                                               Size C(260),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(008) Say "Indique abaixo o período a ser considerado para emissão do relatório de Nosso Número em branco."  Size C(260),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(062),C(070) Say "Período Inicial:"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(077),C(070) Say "Período Final:"    Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(060),C(100) MsGet oGet1 Var dData01   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(075),C(100) MsGet oGet2 Var dData02   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   @ C(095),C(070) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( VERDUPLOS( dData01, dData02 ) )
   @ C(095),C(110) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end()  )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return .T.

// Função que verifica a duplicidade do campo NOSSO NÚMERO
Static Function VERDUPLOS( dData01, dData02 )

   Local cSql        := ""
   Local nContar     := 0
   Local cVerifica   := ""
   Local _Titulo     := ""
   Local _Emissao    := ""
   Local _Vencimento := ""
   Local _Valor      := ""
   Local _Cliente    := ""
   Local _Loja       := ""
   Local _Nome       := ""
   Local _Numbco     := ""
   Local _Prefixo    := ""
   Local nQuanti     := 0

   Local lDuplo      := .F.

   Private aDuplos   := {}
   Private aBrancos  := {}

   If Empty(dData01)
      MsgAlert("Data inicial não informada.")
      Return .T.
   Endif
   
   If Empty(dData02)
      MsgAlert("Data final não informada.")
      Return .T.
   Endif

   If dData02 < dData01
      MsgAlert("Datas inconsistentes.")
      Return .T.
   Endif

   If Select("T_COMPARA") > 0
      T_COMPARA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E1_NUMBCO "
   cSql += "  FROM " + RetSqlName("SE1010")
   cSql += " WHERE E1_NUMBCO   <> ''       "
   cSql += "   AND E1_NUMBCO   <> '0'      "
   cSql += "   AND E1_PREFIXO  <> 'I  '    "     
   cSql += "   AND E1_SALDO    <> 0        "
   cSql += "   AND R_E_C_D_E_L_ = ''       "
   cSql += " GROUP BY E1_NUMBCO            " 
   cSql += " ORDER BY E1_NUMBCO            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPARA", .T., .T. )

   If !T_COMPARA->( EOF() )

      T_COMPARA->( DbGoTop() )

      While !T_COMPARA->( EOF() )

         // Se Result Set do select abaixo for maior que 1, atualiza o array aDuplos

         If Select("T_DUPLOS") > 0
            T_DUPLOS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.E1_NUM    ,"
         cSql += "       A.E1_CLIENTE,"
         cSql += "       A.E1_LOJA   ,"
         cSql += "       A.E1_NOMCLI ,"
         cSql += "       A.E1_EMISSAO,"
         cSql += "       A.E1_VENCTO ,"
         cSql += "       A.E1_VALOR  ,"
         cSql += "       A.E1_NUMBCO ,"
         cSql += "       B.A1_NOME   ,"
         csql += "       A.E1_PREFIXO "
         csql += "  FROM " + RetSqlName("SE1010") + " A, "
         csql += "       " + RetSqlName("SA1010") + " B  "
         cSql += " WHERE A.E1_NUMBCO = '" + Alltrim(T_COMPARA->E1_NUMBCO) + "'"
         cSql += "   AND A.R_E_C_D_E_L_ = ''        "
         csql += "   AND A.E1_CLIENTE   = B.A1_COD  "
         cSql += "   AND A.E1_LOJA      = B.A1_LOJA "
         cSql += "   AND A.E1_SALDO    <> 0         "
         cSql += " ORDER BY A.E1_NUMBCO             "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DUPLOS", .T., .T. )

         If !T_DUPLOS->( EOF() )      

            nQuanti := 0
            While !T_DUPLOS->( EOF() )
               nQuanti := nQuanti + 1
               T_DUPLOS->( DbSkip() )
            Enddo   

            If nQuanti > 1

               T_DUPLOS->( DbGoTop() )

               While !T_DUPLOS->( EOF() )

                  aAdd( aDuplos, { T_DUPLOS->E1_NUM    , ;
                                   T_DUPLOS->E1_EMISSAO, ;
                                   T_DUPLOS->E1_VENCTO , ;
                                   T_DUPLOS->E1_VALOR  , ;
                                   T_DUPLOS->E1_CLIENTE, ;
                                   T_DUPLOS->E1_LOJA   , ;
                                   T_DUPLOS->A1_NOME   , ;
                                   T_DUPLOS->E1_NUMBCO , ;
                                   T_DUPLOS->E1_PREFIXO} )

                   T_DUPLOS->( DbSkip() )                              
 
               Enddo
               
            Endif
            
         Endif   
               
         T_COMPARA->( DbSkip() )
         
      Enddo
               
   Endif

   // Pesquisa os titulos que não possuem o NOSSO NÚMERO
   If Select("T_DUPLOS") > 0
      T_DUPLOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.E1_NUM    ,"
   cSql += "       A.E1_CLIENTE,"
   cSql += "       A.E1_LOJA   ,"
   cSql += "       A.E1_NOMCLI ,"
   cSql += "       A.E1_EMISSAO,"
   cSql += "       A.E1_VENCTO ,"
   cSql += "       A.E1_VALOR  ,"
   cSql += "       A.E1_NUMBCO ,"
   cSql += "       B.A1_NOME   ,"
   csql += "       A.E1_PREFIXO "
   csql += "  FROM " + RetSqlName("SE1010") + " A, "
   csql += "       " + RetSqlName("SA1010") + " B  "
   cSql += " WHERE (A.E1_NUMBCO   = '' OR A.E1_NUMBCO = '0') "
   csql += "   AND A.E1_PREFIXO  <> 'I  '     "     
   csql += "   AND A.E1_SALDO    <> 0         "
   cSql += "   AND A.E1_TIPO     <> 'NCC'     "
   cSql += "   AND A.R_E_C_D_E_L_ = ''        "
   csql += "   AND A.E1_CLIENTE   = B.A1_COD  "
   cSql += "   AND A.E1_LOJA      = B.A1_LOJA "
   cSql += "   AND A.E1_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.E1_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
   cSql += " ORDER BY A.E1_EMISSAO            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DUPLOS", .T., .T. )

   If !T_DUPLOS->( EOF() )

      T_DUPLOS->( DbGotop() )

      While !T_DUPLOS->( EOF() )
   
         // Verifica se a condição de pagamento do título é de cartão de crédito.
         // Se for, não considera.
         If Select("T_CONDICAO") > 0
            T_CONDICAO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.D2_DOC    , "
         cSql += "       A.D2_PEDIDO , "
         cSql += "       B.C5_CONDPAG  "
         cSql += "  FROM " + RetSqlName("SD2010") + " A, "
         cSql += "       " + RetSqlName("SC5010") + " B  "
         cSql += " WHERE A.D2_DOC       = '" + Alltrim(T_DUPLOS->E1_NUM) + "'"
         cSql += "   AND A.D2_PEDIDO    = B.C5_NUM "
         cSql += "   AND B.C5_CONDPAG IN ('108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118') "          

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
         
         If !T_CONDICAO->( EOF() )
         Else   
            aAdd( aBrancos, { T_DUPLOS->E1_NUM    , ;
                              T_DUPLOS->E1_EMISSAO, ;
                              T_DUPLOS->E1_VENCTO , ;
                              T_DUPLOS->E1_VALOR  , ;
                              T_DUPLOS->E1_CLIENTE, ;
                              T_DUPLOS->E1_LOJA   , ;
                              T_DUPLOS->A1_NOME   , ;
                              T_DUPLOS->E1_NUMBCO , ;
                              T_DUPLOS->E1_PREFIXO} )
         Endif

         T_DUPLOS->( DbSkip() )
      
      Enddo      
      
   Endif

   // Envia para a função que imprime o relatório

   If Len(aDuplos) <> 0
      If MsgYesNo("Deseja Visualizar o relatorio de NOSSO NÚMERO Duplicados?")
         Processa( {|| LISTADUPLOS() }, "Aguarde...", "Gerando Relatório",.F.)
      Endif
   Endif
         
   If Len(aBrancos) <> 0
      If MsgYesNo("Deseja Visualizar o relatorio de Registros do Contas a Receber sem a informação do NOSSO NÚMERO?")
         Processa( {|| LISTABRANCOS() }, "Aguarde...", "Gerando Relatório",.F.)
      Endif
   Endif

Return .T.

// Função que gera o relatório
Static Function LISTADUPLOS()

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto    := 0
   Local nServico    := 0
   Local nContar     := 0
   Local nTotalgeral := 0

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
   oPrint:SetPaperSize(9)  // A4
	
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

   nPagina     := 0
   _nLin       := 10 
   nTotalgeral := 0
                   
   CABECADUPLO(1)
   
   For nContar = 1 to Len(aDuplos)

       oPrint:Say( _nLin, 0100, aDuplos[nContar,01]               + "     "  + ;
                                aDuplos[nContar,09]               + "     "  + ;
                                Substr(aDuplos[nContar,02],07,02) + "/"      + ;
                                Substr(aDuplos[nContar,02],05,02) + "/"      + ;
                                Substr(aDuplos[nContar,02],01,04) + "     "  + ; 
                                Substr(aDuplos[nContar,03],07,02) + "/"      + ;
                                Substr(aDuplos[nContar,03],05,02) + "/"      + ;
                                Substr(aDuplos[nContar,03],01,04) + "     "  + ; 
                                STR(aDuplos[nContar,04],12,02)    + "     "  + ;
                                aDuplos[nContar,07]               + "      " + ;
                                aDuplos[nContar,08], oFont21)

       nTotalGeral := nTotalGeral + aDuplos[nContar,04]

       SomaLinhaDup(50,1)

   Next nContar

   SomaLinhaDup(100,1)

   oPrint:Say( _nLin,0100, "Total Geral: " + str(nTotalGeral,12,02), oFont20b)

   oPrint:EndPage()

   oPrint:Preview()

   If Select("T_DUPLOS") > 0
      T_DUPLOS->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.

// Função que gera o relatório
Static Function LISTABRANCOS()

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
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
   oPrint:SetPaperSize(9)  // A4
	
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

   nPagina     := 0
   _nLin       := 10 
   nTotalGeral := 0

   CABECADUPLO(2)
   
   For nContar = 1 to Len(aBrancos)

       oPrint:Say( _nLin, 0100, aBrancos[nContar,01]               + "     "  + ;
                                aBrancos[nContar,09]               + "     "  + ;
                                Substr(aBrancos[nContar,02],07,02) + "/"      + ;
                                Substr(aBrancos[nContar,02],05,02) + "/"      + ;
                                Substr(aBrancos[nContar,02],01,04) + "     "  + ; 
                                Substr(aBrancos[nContar,03],07,02) + "/"      + ;
                                Substr(aBrancos[nContar,03],05,02) + "/"      + ;
                                Substr(aBrancos[nContar,03],01,04) + "     "  + ; 
                                STR(aBrancos[nContar,04],12,02)    + "     "  + ;
                                aBrancos[nContar,07]               + "      " + ;
                                aBrancos[nContar,08], oFont21)

       nTotalgeral := nTotalgeral + aBrancos[nContar,04]

       SomaLinhaDup(50,2)

   Next nContar

   SomaLinhaDup(100,1)

   oPrint:Say( _nLin,0100, "Total Geral: " + str(nTotalGeral,12,02), oFont20b)

   oPrint:EndPage()

   oPrint:Preview()

   If Select("T_DUPLOS") > 0
      T_DUPLOS->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.

// Imprime o cabeçalho do relatório
Static Function CABECADUPLO(_Tipo)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont21)

   If _Tipo == 1
      oPrint:Say( _nLin, 0950, "NOSSO NÚMERO DUPLICADOS"              , oFont21)
   Else
      oPrint:Say( _nLin, 0950, "NOSSO NÚMERO EM BRANCO OU = 0"        , oFont21)
   Endif
            
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()                      , oFont21)
   _nLin += 50
   oPrint:Say( _nLin, 0100, "AUTOMR26.PRW", oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20
  
   oPrint:Say( _nLin, 0100, "TITULO        PRF     EMISSAO        VENCIMENTO            VALOR     CLIENTE                                       NOSSO NR.", oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 50

Return .T.

// Função que soma linhas para impressão do relatório de faturamento por período sintético
Static Function SomaLinhaDup(nLinhas, _Tipo)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECADUPLO(_Tipo)
   Endif
   
Return .T.
