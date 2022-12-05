#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM192.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/09/2013                                                          *
// Objetivo..: Emissão Relatório de Movimentação Financeira - Contas a Receber     *
//**********************************************************************************

User Function AUTOM192()

   Local lChumba     := .F.  
                     
   Private aTipo     := {"A - Analítico","S - Sintético"}
   Private aOrdem    := {"C - Cliente"  , "F - Fornecedor", "V - Valor"}
   Private aSituacao := {"A - A Receber", "P - Pagas"     , "B - Ambos"}
   Private dInicial	 := Ctod("  /  /    ")
   Private dFinal 	 := Ctod("  /  /    ")
   Private vInicial	 := Ctod("  /  /    ")
   Private vFinal	 := Ctod("  /  /    ")
   Private cCliente	 := Space(06)
   Private cLoja	 := Space(03)
   Private cNomeCli	 := Space(40)
   Private cExterno	 := Space(06)
   Private cLojaE	 := Space(03)
   Private cNomeExt	 := Space(40)
   Private aSaida    := {}
   Private lExterno  := .F.

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private oGet1
   Private oGet10
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oCheckBox1

   Private oDlg

   U_AUTOM628("AUTOM192")

   DEFINE MSDIALOG oDlg TITLE "Relatório Contas a Receber" FROM C(178),C(181) TO C(379),C(676) PIXEL

   @ C(005),C(005) Say "Data Inicial"  Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(005) Say "Data Final"    Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(005) Say "Cliente"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(043),C(005) Say "Forn. Externo" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Tipo"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(071),C(005) Say "Ordenação"     Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(085),C(005) Say "Situação"      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(004),C(042) MsGet oGet1  Var dInicial             Size C(048),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(017),C(042) MsGet oGet2  Var dFinal               Size C(048),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(042) MsGet oGet3 Var cCliente              Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1") VALID( BuscaCliAut("C", cCliente, cLoja) )
   @ C(030),C(072) MsGet oGet4 Var cLoja                 Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg           VALID( BuscaCliAut("C", cCliente, cLoja) )
   @ C(030),C(094) MsGet oGet5 Var cNomeCli When lChumba Size C(145),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(042) MsGet oGet6 Var cExterno              Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA2") VALID( BuscaCliAut("E", cExterno, cLojaE) )
   @ C(043),C(072) MsGet oGet7 Var cLojaE                Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg           VALID( BuscaCliAut("E", cExterno, cLojaE) )
   @ C(043),C(094) MsGet oGet8 Var cNomeExt When lChumba Size C(145),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(056),C(041) ComboBox cComboBx1 Items aTipo        Size C(072),C(010) PIXEL OF oDlg
   @ C(070),C(041) ComboBox cComboBx2 Items aOrdem       Size C(072),C(010) PIXEL OF oDlg
   @ C(084),C(041) ComboBox cComboBx3 Items aSituacao    Size C(072),C(010) PIXEL OF oDlg
   @ C(064),C(156) CheckBox oCheckBox1 Var lExterno      Prompt "Layout - Externo" Size C(050),C(008) PIXEL OF oDlg
	
   @ C(081),C(144) Button "O K"    Size C(037),C(012) PIXEL OF oDlg ACTION( GeraPesquisa() )
   @ C(081),C(182) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return(.T.)

// Função que pesquisa o nome do cliente selecionado
Static Function BuscaCliAut(_Tipo, _Cliente, _Loja)

   Local cSql := ""
   
   If Empty(Alltrim(_Cliente))
      IIF(_Tipo == "C", cNomeCli := Space(60), cNomeExt := Space(60)) 
      Return .T.
   Endif
      
   If Empty(Alltrim(_Loja))
      IIF(_Tipo == "C", cNomeCli := Space(60), cNomeExt := Space(60)) 
      Return .T.
   Endif
   
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   If _Tipo == "C"
      cSql := "SELECT A1_NOME"
      cSql += "  FROM " + RetSqlName("SA1")
      cSql += " WHERE A1_COD     = '" + Alltrim(_Cliente) + "'"
      cSql += "   AND A1_LOJA    = '" + Alltrim(_Loja)    + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
   Else
      cSql := "SELECT A2_NOME"
      cSql += "  FROM " + RetSqlName("SA2")
      cSql += " WHERE A2_COD     = '" + Alltrim(_Cliente) + "'"
      cSql += "   AND A2_LOJA    = '" + Alltrim(_Loja)    + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
   Endif      

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este Código/Loja.")
      IIF(_Tipo == "C", cCliente := Space(06), cExterno := Space(06)) 
      IIF(_Tipo == "C", cLoja    := Space(03), cLojaE   := Space(03))
      IIF(_Tipo == "C", cNomeCli := Space(60), cNomeExt := Space(60))
   Else
      IIF(_Tipo == "C", cNomeCli := T_CLIENTE->A1_NOME, cNomeExt := T_CLIENTE->A2_NOME)
   Endif
   
Return(.T.)

// Função que gera a pesquisa para emissão do relatório
Static Function GeraPesquisa()

   Local   cSql    := ""
   
   Private cDesc1  := "Este programa tem como objetivo imprimir relatorio "
   Private cDesc2  := "de acordo com os parametros informados pelo usuario."
   Private cDesc3  := ""
   Private cPict   := ""
   Private titulo  := ""
   Private nLin    := 80
   Private nPagina := 0
   Private Cabec1  := ""
   Private Cabec2  := ""
   Private imprime := .T.
   Private aOrd    := {}

   Private lEnd        := .F.
   Private lAbortPrint := .F.
   Private CbTxt       := ""
   Private limite      := 80
   Private tamanho     := "P"
   Private nomeprog    := "AUTOM192"
   Private nTipo       := 18
   Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey    := 0
   Private cbtxt       := Space(10)
   Private cbcont      := 00
   Private CONTFL      := 01
   Private m_pag       := 01
   Private wnrel       := "AUTOM192"
   Private cString     := "SE4"

   dbSelectArea("SE4")
   dbSetOrder(1)

   // Consistência dos Dados
   If Empty(dInicial)
      MsgAlert("Data inicial para pesquisa não informada.")
      Return .T.
   Endif
      
   If Empty(dFinal)
      MsgAlert("Data final para pesquisa não informada.")
      Return .T.
   Endif

   If dFinal < dInicial
      MsgAlert("Datas Inconsistentes.")
      Return .T.
   Endif
      
   wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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

Return(.T.)

// Função que imprime o relatório
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local nAcumulado  := 0
   Local _Sinal      := ""
   Local _Diferenca  := 0
   Local _Condicao   := ""
   Local _Prestacao  := 0
   Local _TotalParc  := 0
   Local lPrimeiro   := .F.
   Local __Valor     := 0
   Local __Acumulado := 0
   Local xAcumulado  := 0
   Local xData       := 0
   Local aSintetico  := {}

   Private dVencimento := Ctod("  /  /    ")

   aSaida     := {}
   aSintetico := {}

   dbSelectArea(cString)
   dbSetOrder(1)

   // SETREGUA -> Indica quantos registros serao processados para a regua
   SetRegua(RecCount())

   If lExterno == .F.

      // Imprime o relatório Analítico
      If Select("T_DADOS") > 0
         T_DADOS->( dbCloseArea() )
      EndIf

      cSql := "SELECT SE3.E3_FILIAL ," + CHR(13)
      cSql += "       SE3.E3_PEDIDO ," + CHR(13)
      cSql += "       SE3.E3_PVORIG ," + CHR(13)
      cSql += "       SE3.E3_EMISSAO," + CHR(13)
      cSql += "       SE3.E3_VENCTO ," + CHR(13)
      cSql += "       SE3.E3_NUM    ," + CHR(13)
      cSql += "       SE3.E3_SERIE  ," + CHR(13)
      cSql += "       SE3.E3_CODCLI ," + CHR(13)
      cSql += "       SE3.E3_LOJA   ," + CHR(13)
      cSql += "       SE3.E3_DATA   ," + CHR(13)
      cSql += "       SA1.A1_NOME   ," + CHR(13)
      cSql += "       SA1.A1_DDD    ," + CHR(13)
      cSql += "       SA1.A1_TEL    ," + CHR(13)
      cSql += "       SC5.C5_EXTERNO," + CHR(13)
      cSql += "       SC5.C5_FORNEXT," + CHR(13)
      cSql += "       SC5.C5_LOJAEXT," + CHR(13)
      cSql += "       SC5.C5_CONDPAG," + CHR(13)
      cSql += "       SE4.E4_COND   ," + CHR(13)
      cSql += "   ISNULL((SELECT C6_NOTA" + CHR(13)
      cSql += "             FROM " + RetSqlName("SC6") + CHR(13)
      cSql += "            WHERE C6_NUM     = SE3.E3_PEDIDO"
      cSql += "              AND C6_FILIAL  = SE3.E3_FILIAL"
      cSql += "              AND D_E_L_E_T_ = ''"   
      cSql += "            GROUP BY C6_NOTA),'') AS NFSAIDA,"
      cSql += "   ISNULL((SELECT C6_DATFAT"
      cSql += "             FROM " + RetSqlName("SC6")
      cSql += "            WHERE C6_NUM     = SE3.E3_PEDIDO"
      cSql += "              AND C6_FILIAL  = SE3.E3_FILIAL"
      cSql += "              AND D_E_L_E_T_ = ''"
      cSql += "            GROUP BY C6_DATFAT),'') AS DATAFAT,"
      cSql += "      (SELECT SUM(C6_COMIAUT) AS VALOR" + CHR(13)
      cSql += "         FROM " + RetSqlName("SC6") + CHR(13)
      cSql += "        WHERE C6_NUM     = SE3.E3_PVORIG" + CHR(13)
      cSql += "          AND C6_FILIAL  = SE3.E3_FILIAL" + CHR(13)
      cSql += "          AND D_E_L_E_T_ = ''" + CHR(13)
      cSql += "        GROUP BY C6_NUM) AS VALOR," + CHR(13)
      cSql += "       SA2.A2_NOME"  + CHR(13)
      cSql += "  FROM " + RetSqlName("SE3") + " SE3 , " + CHR(13)
      cSql += "       " + RetSqlName("SA1") + " SA1 , " + CHR(13)
      cSql += "       " + RetSqlName("SC5") + " SC5 , " + CHR(13)
      cSql += "       " + RetSqlName("SE4") + " SE4 , " + CHR(13)
      cSql += "       " + RetSqlName("SA2") + " SA2   " + CHR(13)
      cSql += " WHERE SE3.D_E_L_E_T_ = ''"  + CHR(13)
      cSql += "   AND SC5.C5_EXTERNO = '1'" + CHR(13)
      cSql += "   AND SE3.E3_CODCLI  = SA1.A1_COD"  + CHR(13)
      cSql += "   AND SE3.E3_LOJA    = SA1.A1_LOJA" + CHR(13)
      cSql += "   AND SA1.D_E_L_E_T_ = ''"  + CHR(13)
      cSql += "   AND SE3.E3_VENCTO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
      cSql += "   AND SE3.E3_VENCTO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
      cSql += "   AND SC5.C5_NUM     = SE3.E3_PVORIG " + CHR(13)
      cSql += "   AND SC5.C5_FILIAL  = SE3.E3_FILIAL " + CHR(13)
      cSql += "   AND SC5.C5_CLIENTE = SE3.E3_CODCLI " + CHR(13)
      cSql += "   AND SC5.C5_LOJACLI = SE3.E3_LOJA   " + CHR(13)
      cSql += "   AND SC5.D_E_L_E_T_ = ''            " + CHR(13)
      cSql += "   AND SE4.E4_CODIGO  = SC5.C5_CONDPAG" + CHR(13)
      cSql += "   AND SE4.D_E_L_E_T_ = ''            " + CHR(13)
      cSql += "   AND SA2.A2_COD     = SC5.C5_FORNEXT" + CHR(13)
      cSql += "   AND SA2.A2_LOJA    = SC5.C5_LOJAEXT" + CHR(13)

      Do Case
         Case Substr(cComboBx2,01,01) == "C"
              cSql += " ORDER BY SE3.E3_VENCTO, SA1.A1_NOME" + CHR(13)
         Case Substr(cComboBx2,01,01) == "F"
              cSql += " ORDER BY SE3.E3_VENCTO, SA2.A2_NOME" + CHR(13)
         Case Substr(cComboBx2,01,01) == "V"
              cSql += " ORDER BY SE3.E3_VENCTO, VALOR" + CHR(13)
      EndCase

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

      If T_DADOS->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif

      // Carrega os dados para array para poder ordenar
      T_DADOS->( DbGoTop() )

      While !T_DADOS->(EOF())

         // Seleciona A Receber, pagas ou Ambas
         Do Case
            Case Substr(cComboBx3,01,01) == "A"
                 If !Empty(Alltrim(T_DADOS->NFSAIDA))
                    T_DADOS->( DbSkip() )                 
                    Loop
                 Endif

            Case Substr(cComboBx3,01,01) == "P"
                 If Empty(Alltrim(T_DADOS->NFSAIDA))
                    T_DADOS->( DbSkip() )                 
                    Loop
                 Endif

         EndCase

         // Verifica se o pedido lido foi excluído (C6_BLQ = 'R')
         If Select("T_RESIDUO") > 0
            T_RESIDUO->( dbCloseArea() )
         EndIf
      
         cSql := ""
         cSql := "SELECT C6_FILIAL,"
         cSql += "       C6_NUM   ,"
         cSql += "       C6_BLQ    "
         cSql += "  FROM " + RetSqlName("SC6")
         cSql += " WHERE C6_NUM     = '" + Alltrim(T_DADOS->E3_PEDIDO) + "'"
         cSql += "   AND C6_FILIAL  = '" + Alltrim(T_DADOS->E3_FILIAL) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"
         cSql += " GROUP BY C6_FILIAL, C6_NUM, C6_BLQ"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESIDUO", .T., .T. )

         If T_RESIDUO->( EOF() )
            T_DADOS->( DbSkip() )
            Loop
         Endif
      
         If Alltrim(T_RESIDUO->C6_BLQ) == "R"
            T_DADOS->( DbSkip() )
            Loop
         Endif

         // Prepara os dados para gravação
         lPrimeiro  := .T.
         _Condicao  := ALLTRIM(T_DADOS->E4_COND) + ","
         _Prestacao := Round(T_DADOS->VALOR / U_P_OCCURS(_Condicao, ",", 1),2)
         _TotalParc := _Prestacao * U_P_OCCURS(_Condicao, ",", 1)
         _Sinal     := ""      

         If _TotalParc <> T_DADOS->VALOR
            If _TotalParc > T_DADOS->VALOR
               _Sinal     := "-"
               _Diferenca := _TotalParc - T_DADOS->VALOR
            Else
               _Sinal     := "+"
               _Diferenca := T_DADOS->VALOR - _TotalParc
            Endif
         Endif

         cTelefone := StrTran(T_DADOS->A1_TEL, "-", "")

         nAcumualdo := nAcumulado + _Prestacao

         aAdd( aSaida, {T_DADOS->E3_PVORIG                                                                                                   ,; // 01
                        Substr(T_DADOS->E3_EMISSAO,07,02) + "/" + Substr(T_DADOS->E3_EMISSAO,05,02) + "/" + Substr(T_DADOS->E3_EMISSAO,01,04),; // 02
                        T_DADOS->E3_NUM                                                                                                      ,; // 03
                        T_DADOS->E3_SERIE                                                                                                    ,; // 04
                        ALLTRIM(T_DADOS->E3_CODCLI) + "." + ALLTRIM(T_DADOS->E3_LOJA)                                                        ,; // 05
                        SUBSTR(T_DADOS->A1_NOME,01,35)                                                                                       ,; // 06
                        ALLTRIM(T_DADOS->C5_FORNEXT)   + "." + ALLTRIM(T_DADOS->C5_LOJAEXT)                                                  ,; // 07
                        SUBSTR(T_DADOS->A2_NOME,01,35)                                                                                       ,; // 08
                        Strzero(U_P_OCCURS(_Condicao, ",", 1),3)                                                                             ,; // 09
                        Substr(T_DADOS->E3_VENCTO,07,02) + "/" + Substr(T_DADOS->E3_VENCTO,05,02) + "/" + Substr(T_DADOS->E3_VENCTO,01,04)   ,; // 10
                        _Prestacao                                                                                                           ,; // 11
                        nAcumulado                                                                                                           ,; // 12
                        "(" + ALLTRIM(T_DADOS->A1_DDD) + ") " + SUBSTR(cTelefone,01,04) + "-" + SUBSTR(cTelefone,05)                         ,; // 13
                        Substr(T_DADOS->E3_DATA,07,02) + "/"  + Substr(T_DADOS->E3_DATA,05,02) + "/" + Substr(T_DADOS->E3_DATA,01,04)        ,; // 14
                        T_DADOS->E3_PEDIDO                                                                                                   ,; // 15
                        Substr(T_DADOS->DATAFAT,07,02) + "/" + Substr(T_DADOS->DATAFAT,05,02) + "/" + Substr(T_DADOS->DATAFAT,01,04)         ,; // 16
                        T_DADOS->NFSAIDA                                                                                                     }) // 17
      
         T_DADOS->( DbSkip() )
   
      EndDo

      If Len(aSaida) == 0
         MsgAlert("Não existem dados a serem visualizados para este período.")
         Return(.T.)
      Endif

      // Relatório Analítico
      If Substr(cComboBx1,01,01) == "A"

         dVencimento := aSaida[1,10]

         xAcumulado  := 0
         xData       := 0

         // Imprime o relatório
         For nContar = 1 to Len(aSaida)

             // Impressao do cabecalho do relatorio.
             If nLin > 55
                CabecaFinanceiro(dVencimento)
                nLin := 9
             Endif

             If aSaida[nContar,10] == dVencimento
                @ nLin,001 psay aSaida[nContar,01]
                @ nLin,014 psay aSaida[nContar,15]
                @ nLin,027 psay aSaida[nContar,16]
                @ nLin,040 psay aSaida[nContar,17]
                @ nLin,053 psay aSaida[nContar,05]
                @ nLin,066 psay aSaida[nContar,06]
                @ nLin,109 psay aSaida[nContar,07]
                @ nLin,122 psay aSaida[nContar,08]
                @ nLin,176 psay aSaida[nContar,11] picture "@E 9,999,999,999.99"

                xAcumulado := xAcumulado + aSaida[nContar,11]
                xData      := xData      + aSaida[nContar,11]

                @ nLin,197 psay xAcumulado picture "@E 9,999,999,999.99"

                nLin := nLin + 1
          
             Else
       
                dVencimento := aSaida[nContar,10]
                nContar     := nContar - 1

                nLin := nLin + 1

                If nLin > 55
                   CabecaFinanceiro(dVencimento)
                   nLin := 9
                Else
                   nLin := nLin + 1

                   If nLin > 55
                      CabecaFinanceiro(dVencimento)
                      nLin := 9
                   Endif

                   @ nLin,144 psay "TOTAL DA DATA ............:"
                   @ nLin,176 psay xData picture "@E 9,999,999,999.99"
                   nLin := nLin + 2

                   If nLin > 55
                      CabecaFinanceiro(dVencimento)
                      nLin := 9
                   Endif

                   @ nLin,085 psay "Vencimento: " + dVencimento
                   nLin := nLin + 2

                   If nLin > 55
                      CabecaFinanceiro(dVencimento)
                      nLin := 9
                   Endif

                Endif

                xData := 0
                                   
             Endif
          
         Next nContar

         nLin := nLin + 1
          
         // Impressao do cabecalho do relatorio.
         If nLin > 55
            CabecaFinanceiro(dVencimento)
            nLin := 9
         Endif

         nLin := nLin + 1
         @ nLin,144 psay "TOTAL DA DATA ............:"
         @ nLin,176 psay xData      PICTURE "@E 9,999,999,999.99"

         nLin := nLin + 2
         @ nLin,144 psay "TOTAL GERAL ..............:"
         @ nLin,197 psay xAcumulado PICTURE "@E 9,999,999,999.99"
      
      Else

         // Ordena o Array para Impressão
         ASORT(aSaida,,,{ | x,y | x[5] + x[6] < y[5] + y[6] } )
      
         yCliente   := aSaida[1][5]
         cNomeCli   := aSaida[1][6]
         xAcumulado := 0

         For nContar = 1 to Len(aSaida)
      
             If aSaida[ncontar,5] == yCliente
          
                xAcumulado := xAcumulado + aSaida[nContar,11]

             Else

                aAdd( aSintetico, { yCliente, cNomeCli, xAcumulado } )

                yCliente   := aSaida[nContar,05]
                cNomeCli   := aSaida[nContar,06]
                xAcumulado := aSaida[nContar,11]

             Endif

         Next nContar
                       
         // Atualiza o último acumulador para impressão
         aAdd( aSintetico, { yCliente, cNomeCli, xAcumulado } )                 
      
         // Imprime o relatório
         nAcumulado := 0

         For nContar = 1 to Len(aSintetico)

             // Impressao do cabecalho do relatorio.
             If nLin > 55
                CabecaSintetica()
                nLin := 8
             Endif

             @ nLin,057 psay aSintetico[nContar,01]
             @ nLin,068 psay aSintetico[nContar,02]
             @ nLin,128 psay aSintetico[nContar,03] PICTURE "@E 999,999,999.99"

             nAcumulado := nAcumulado + aSintetico[nContar,03]
             nLin       := nLin + 1

         Next nContar

         nLin := nLin + 1

         If nLin > 55
            CabecaSintetica()
            nLin := 8
         Endif

         @ nLin,068 psay "Total Geral"
         @ nLin,128 psay nAcumulado PICTURE "@E 999,999,999.99"

      Endif
      
   Else
   
      If Select("T_DADOS") > 0
         T_DADOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC5.C5_FILIAL ,"                   + CHR(13)
      cSql += "       SC5.C5_NUM    ,"                   + CHR(13)
      cSql += "       SC5.C5_EMISSAO,"                   + CHR(13)
      cSql += "       SC5.C5_EXTERNO,"                   + CHR(13)
      cSql += "       SC5.C5_FORNEXT,"                   + CHR(13)
      cSql += "       SC5.C5_LOJAEXT,"                   + CHR(13)
      cSql += "       SA2.A2_NOME   ,"                   + CHR(13)
      cSql += "      (SELECT SUM(C6_VALOR)"              + CHR(13)
      cSql += "         FROM " + RetSqlName("SC6")       + CHR(13)
      cSql += "        WHERE C6_FILIAL  = SC5.C5_FILIAL" + CHR(13)
      cSql += "          AND C6_NUM     = SC5.C5_NUM   " + CHR(13)
      cSql += "          AND D_E_L_E_T_ = '') AS VALOR " + CHR(13)
      cSql += "  FROM " + RetSqlName("SC5") + " SC5, "   + CHR(13)
      cSql += "       " + RetSqlName("SA2") + " SA2  "   + CHR(13)
      cSql += " WHERE SC5.C5_EXTERNO = '1'"              + CHR(13)
      cSql += "   AND SC5.D_E_L_E_T_ = '' "              + CHR(13)
      cSql += "   AND SC5.C5_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
      cSql += "   AND SC5.C5_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
      cSql += "   AND SC5.C5_FORNEXT  = SA2.A2_COD "     + CHR(13)
      cSql += "   AND SC5.C5_LOJAEXT  = SA2.A2_LOJA"     + CHR(13)
      cSql += " ORDER BY SA2.A2_NOME"                    + CHR(13)
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

      If T_DADOS->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
      
      // Carrega os dados para array para poder ordenar
      T_DADOS->( DbGoTop() )

      While !T_DADOS->(EOF())

         // Verifica se o pedido lido foi excluído (C6_BLQ = 'R')
         If Select("T_RESIDUO") > 0
            T_RESIDUO->( dbCloseArea() )
         EndIf
      
         cSql := ""
         cSql := "SELECT C6_FILIAL,"
         cSql += "       C6_NUM   ,"
         cSql += "       C6_BLQ    "
         cSql += "  FROM " + RetSqlName("SC6")
         cSql += " WHERE C6_NUM     = '" + Alltrim(T_DADOS->C5_NUM)    + "'"
         cSql += "   AND C6_FILIAL  = '" + Alltrim(T_DADOS->C5_FILIAL) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"
         cSql += " GROUP BY C6_FILIAL, C6_NUM, C6_BLQ"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESIDUO", .T., .T. )

         If T_RESIDUO->( EOF() )
            T_DADOS->( DbSkip() )
            Loop
         Endif
      
         If T_RESIDUO->C6_BLQ == "R"
            T_DADOS->( DbSkip() )
            Loop
         Endif

         // Carrega o Array para Impressão
         aAdd( aSaida, {T_DADOS->C5_NUM                                                                                                      ,; // 01
                        Substr(T_DADOS->C5_EMISSAO,07,02) + "/" + Substr(T_DADOS->C5_EMISSAO,05,02) + "/" + Substr(T_DADOS->C5_EMISSAO,01,04),; // 02
                        ALLTRIM(T_DADOS->C5_FORNEXT)   + "." + ALLTRIM(T_DADOS->C5_LOJAEXT)                                                  ,; // 03
                        SUBSTR(T_DADOS->A2_NOME,01,35)                                                                                       ,; // 04
                        T_DADOS->VALOR                                                                                                       }) // 05
      
         T_DADOS->( DbSkip() )
   
      EndDo

      // Impressão do Rlatório
      yCliente   := aSaida[01,03]
      cNomeCli   := aSaida[01,04]
      nAcumulado := 0
      nPeriodo   := 0

      For nContar = 1 to Len(aSaida)
      
          // Impressao do cabecalho do relatorio.
          If nLin > 55
             CabecaExterno()
             nLin := 8
          Endif

          If cNomeCli = aSaida[ncontar,04]

             @ nLin,028 psay aSaida[nContar,01]
             @ nLin,049 psay aSaida[nContar,02]
             @ nLin,070 psay aSaida[nContar,03]
             @ nLin,081 psay aSaida[nContar,04]
             @ nLin,162 psay aSaida[nContar,05] PICTURE "@E 9,999,999,999.99"

             nAcumulado := nAcumulado + aSaida[nContar,05]
             nPeriodo   := nPeriodo   + aSaida[nContar,05]
             nLin       := nLin + 1
             
          Else

             nLin := nLin + 1

             If nLin > 55
                CabecaExterno()
                nLin := 8
             Endif

             @ nLin,136 psay "TOTAL DO FORNECEDOR:"
             @ nLin,162 psay nAcumulado PICTURE "@E 9,999,999,999.99"

             nLin := nLin + 2

             If nLin > 55
                CabecaExterno()
                nLin := 8
             Endif
          
             yCliente   := aSaida[nContar,03]
             cNomeCli   := aSaida[nContar,04]
             nAcumulado := 0

             nContar := nContar - 1
             
          Endif   

      Next nContar

      nLin := nLin + 1

      If nLin > 55
         CabecaExterno()
         nLin := 8
      Endif

      @ nLin,136 psay "TOTAL DO FORNECEDOR:"
      @ nLin,162 psay nAcumulado PICTURE "@E 9,999,999,999.99"
   
      nLin := nLin + 2

      If nLin > 55
         CabecaExterno()
         nLin := 8
      Endif

      @ nLin,136 psay "TOTAL DO PERÍODO:"
      @ nLin,162 psay nPeriodo PICTURE "@E 9,999,999,999.99"

   Endif
      
   SET DEVICE TO SCREEN
 
   If aReturn[5]==1
      dbCommitAll()
      SET PRINTER TO
      OurSpool(wnrel)
   Endif

   MS_FLUSH()

Return

// Função que imprime o cabeçalho do relatório
Static Function CabecaFinanceiro(_Vencimento)
   nLin := 1
   nPagina := nPagina + 1
   @ nlin,001 psay "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO MOVIMENTO FINANCEIRO A RECEBER                                                                        " + dtoc(Date()) + "-" + time()
   nLin := nLin + 1
   @ nlin,001 psay "AUTOM192.PRW                                                                       PERÍODO DE " + Dtoc(dInicial) + " A " + Dtoc(dFinal) + "                                                                            PAGINA:       " + Strzero(npagina,5)
   nLin := nLin + 1
   @ nLin,001 psay "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   nLin := nLin + 1
   @ nLin,001 psay "Nº PV (P1)   Nº PV (51)     DTA FAT    Nº NFISCAL   CLIENTE      DESCRIÇÃO DOS CLIENTES                     EXTERNO      DESCRIÇÃO FORNECEDOR EXTERNO                                     VALOR            ACUMULADO"
   nLin := nLin + 1                                                                                                                                    
   @ nLin,001 psay "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   nLin := nLin + 2
   @ nLin,085 psay "Vencimento: " + _Vencimento
   nLin := nLin + 2
Return(.T.)

// Função que imprime o cabeçalho do relatório sintético
Static Function CabecaSintetico()
   nLin := 1
   nPagina := nPagina + 1
   @ nLin,001 psay "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO MOVIMENTO FINANCEIRO A RECEBER - SINTÉTICO                                                " + Dtoc(Date()) + "-" + time()
   nLin := nLin + 1
   @ nlin,001 psay "AUTOM192.PRW                                                                       PERÍODO DE " + Dtoc(dInicial) + " A " + Dtoc(dFinal) + "                                                                PAGINA:       " + Strzero(npagina,5)
   nLin := nLin + 1
   @ nlin,001 psay "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   nLin := nLin + 1
   @ nlin,001 psay "                                                        CLIENTE    DESCRICAO DOS CLIENTES                                               VALOR"
   nLin := nLin + 1                                                         
   @ nlin,001 psay "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   nLin := nLin + 2
Return(.T.)

// Função que imprime o cabeçalho do Layout Externo
Static Function CabecaExterno()
   nLin := 1
   nPagina := nPagina + 1
   @ nLin,001 psay "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO MOVIMENTO FINANCEIRO - FORNECEDOR EXTERNOS                                                " + Dtoc(Date()) + "-" + time()
   nLin := nLin + 1
   @ nlin,001 psay "AUTOM192.PRW                                                                       PERÍODO DE " + Dtoc(dInicial) + " A " + Dtoc(dFinal) + "                                                                PAGINA:       " + Strzero(npagina,5)
   nLin := nLin + 1
   @ nlin,001 psay "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   nLin := nLin + 1
   @ nLin,001 psay "                           Nº PEDIDO             EMISSAO             EXTERNO    DESCRIÇÃO FORNECEDORES EXTERNOS                                                             VALOR"             
   nLin := nLin + 1                                                         
   @ nLin,001 psay "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   nLin := nLin + 2                                                         
Return(.T.)