#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM288.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 04/05/2015                                                          *
// Objetivo..: Programa Validador de Documentos entre BI X AtechInfo               *
//**********************************************************************************

User Function AUTOM288()
                      
   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1
   Local lChumba := .F.

   Private dInicial     := Ctod("  /  /    ")
   Private dFinal       := Ctod("  /  /    ")
   Private aVendedor    := {}
   Private aEmpresa     := U_AUTOM539(1, "")      // {"00 - Selecione", "01 - Automatech", "02 - TI Automação", "03 - Atech"}
   Private aFilial      := U_AUTOM539(2, cEmpAnt) // {"00 - Selecione", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "TI - TI Automação", "AT - Atech"}      
   Private cLocaliza    := ""
   Private nTotal_NF    := 0
   Private nTotal_Valor := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4   
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3   
   Private oMemo2

   Private aBrowse := {}

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oDlg

   U_AUTOM628("AUTOM288")

   // Inicializa o array de vendedores
   aAdd( aVendedor, "000000 - Selecione um Vendedor para pesquisa" )

   // Carrega o combobox de vendedores
   If Select("T_VENDEDORES") > 0
      T_VENDEDORES->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT A.A3_COD   ,"
   cSql += "       A.A3_NOME  ,"
   cSql += "       A.A3_CODUSR,"
   cSql += "       A.A3_TSTAT  "
   cSql += "  FROM " + RetSqlName("SA3") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.A3_CODUSR <> ''"
   cSql += "   AND A.A3_NREDUZ <> ''"
   cSql += " ORDER BY A.A3_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDORES", .T., .T. )

   T_VENDEDORES->( DbGoTop() )

   WHILE !T_VENDEDORES->( EOF() )
      If Empty(Alltrim(T_VENDEDORES->A3_NOME))
         T_VENDEDORES->( DbSkip() )         
         Loop
      Endif   
      aAdd( aVendedor, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )
      T_VENDEDORES->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Validador BI X AtechInfo" FROM C(178),C(181) TO C(620),C(1150) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlg
   @ C(208),C(005) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(208),C(062) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(500),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Período Inicial"           Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(054) Say "Período Final"             Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(103) Say "Empresa"                   Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(180) Say "Filial"                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(258) Say "Vendedor"                  Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Validação de Documentos"   Size C(065),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(425) Say "NF não Localizadas"        Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(209),C(018) Say "Documentos OK"             Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(209),C(077) Say "Documentos Inconsistentes" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(209),C(165) Say "Total NF"                  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(209),C(218) Say "Valor Total"               Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(044),C(005) MsGet    oGet1     Var   dInicial       Size C(043),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg
   @ C(044),C(054) MsGet    oGet2     Var   dFinal         Size C(043),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg
   @ C(044),C(103) ComboBox cComboBx2 Items aEmpresa       Size C(072),C(010)                                             PIXEL OF oDlg When lChumba
   @ C(044),C(180) ComboBox cComboBx3 Items aFilial        Size C(072),C(010)                                             PIXEL OF oDlg
   @ C(044),C(258) ComboBox cComboBx1 Items aVendedor      Size C(157),C(010)                                             PIXEL OF oDlg
   @ C(063),C(425) GET      oMemo2    Var   cLocaliza MEMO Size C(060),C(140)                                             PIXEL OF oDlg
   @ C(208),C(190) MsGet    oGet3     Var   nTotal_NF      Size C(021),C(009) COLOR CLR_BLACK Picture "@E 99999"          PIXEL OF oDlg When lChumba
   @ C(208),C(247) MsGet    oGet4     Var   nTotal_Valor   Size C(060),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg When lChumba
	
   @ C(042),C(444) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( MsgRun("Favor Aguarde! Pesquisando registros ...", "Pesquisando Registros",{|| Pesq_Vendas() }) )

   @ C(206),C(405) Button "Detalhes"  Size C(037),C(012) PIXEL OF oDlg
   @ C(206),C(444) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "2", "", "", "", "", "", "", "", "", "", "", "" } )

   // Desenha o aBrowse na tela
   oBrowse := TCBrowse():New( 080 , 005, 535, 180,,{"Lg"              ,; // 01 - Legenda
                                                    "FL"              ,; // 02 - Filial
                                                    "N.Fiscal"        ,; // 03 - Nº Nota Fiscal
                                                    "Série"           ,; // 04 - Série Nota Fiscal
                                                    "Dt Dig."         ,; // 05 - Data de Digitação
                                                    "Sub-Total"       ,; // 06 - Sub Total BI
                                                    "Devolução"       ,; // 07 - Devolução BI
                                                    "Total"           ,; // 08 - Total do BI
                                                    "Vlr. AtechInfo"  ,; // 09 - Sub-Total AtechInfo
                                                    "Devolução"       ,; // 10 - Devolução AtehcInfo
                                                    "Total AtechInfo" ,; // 11 - Total AtehInfo
                                                    "Diferença"      },; // 12 - Diferença BI X AtechInfo
                                                    {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               ,;                         
                         aBrowse[oBrowse:nAt,09]               ,;                         
                         aBrowse[oBrowse:nAt,10]               ,;                                                     
                         aBrowse[oBrowse:nAt,11]               ,;                         
                         aBrowse[oBrowse:nAt,12]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa as vendas conforme dados informados
Static Function Pesq_Vendas()
                           
   Local cSql    := ""
   Local nContar := 0
   Local lExiste := .F.
   Local cTexto  := ""
   Local nQtd_NF := 0
   Local nVal_NF := 0

   If Empty(dInicial)
      MsgAlert("Data inicial de pesquisa não informada.")
      Return(.T.)
   Endif
      
   If Empty(dFinal)
      MsgAlert("Data final de pesquisa não informada.")
      Return(.T.)
   Endif

   If Substr(cComboBx2,01,02) == "00"
      MsgAlert("Empresa não selecionada.")
      Return(.T.)
   Endif
   
   If Substr(cComboBx3,01,02) == "00"
      MsgAlert("Filial não selecionada.")
      Return(.T.)
   Endif

   If Substr(cComboBx1,01,06) == "000000"
      MsgAlert("Vendedor não indicado.")
      Return(.T.)
   Endif

   // Limpa o artray para receber novas informações
   aBrowse := {}

   // Pesquisa os dados conforme parâmetros
   If Select("T_VENDAS") > 0
      T_VENDAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT  A.D2_FILIAL                    as FILIAL       ," + chr(13) 
   cSql += "        A.D2_DOC                       as NUM_NOTA_D2  ," + chr(13) 
   cSql += "        A.D2_SERIE                     as SERIE_D2     ," + chr(13) 
   cSql += "        CAST(A.D2_EMISSAO AS DATETIME) AS DATADIGI     ," + chr(13) 
   cSql += "        A.D2_TES                       as TES_D2       ," + chr(13) 
   cSql += "        G.F4_DUPLIC                    as GER_DUPLI_D2 ," + chr(13) 
   cSql += "        G.F4_ISS                       as ISS_D2       ," + chr(13) 
   cSql += "        A.D2_CF                        as CFOP_D2      ," + chr(13) 
   cSql += "        A.D2_PEDIDO                    as NUM_PEDIDO_D2," + chr(13) 
   cSql += "        F.C5_FRETE                     as FRETE_D2     ," + chr(13) 
   cSql += "        A.D2_CLIENTE                   as COD_CLI_D2   ," + chr(13) 
   cSql += "        A.D2_LOJA                      as COD_LOJA_D2  ," + chr(13) 

   Do Case
      Case Substr(cComboBx2,01,02) == "01"
           cSql += "       (SELECT TOP 1 F2_VEND1 FROM SF2010 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') COD_VEND," + chr(13)

      Case Substr(cComboBx2,01,02) == "02"
           cSql += "       (SELECT TOP 1 F2_VEND1 FROM SF2020 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') COD_VEND," + chr(13)

      Case Substr(cComboBx2,01,02) == "03"
           cSql += "       (SELECT TOP 1 F2_VEND1 FROM SF2030 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') COD_VEND," + chr(13)

   EndCase           
           
   cSql += "       (SELECT  A3_NOME       FROM SA3010 SA3 WHERE SA3.D_E_L_E_T_ = ''       AND A3_COD = (SELECT TOP 1 F2_VEND1 FROM SF2010 SF2 WHERE SF2.F2_DOC = A.D2_DOC AND SF2.F2_SERIE = A.D2_SERIE AND SF2.F2_FILIAL = A.D2_FILIAL AND SF2.D_E_L_E_T_ = '')) NOME_VEND," + chr(13)
   cSql += "        C.A1_NOME                      as NOME_CLIENTE," + chr(13) 
   cSql += "        C.A1_MUN                       as MUN_CLI_D2  ," + chr(13) 
   cSql += "        C.A1_EST                       as EST_CLI_D2  ," + chr(13) 
   cSql += "        C.A1_PESSOA                    as PESSOA_J_F  ," + chr(13) 
   cSql += "        A.D2_ITEM                      as NUM_ITEM_D2 ," + chr(13) 
   cSql += "        A.D2_COD                       as COD_PROD_D2 ," + chr(13) 
   cSql += "        D.B1_DESC                      as DESC_PROD   ," + chr(13) 
   cSql += "        D.B1_DAUX                      as DESC_AUX    ," + chr(13) 
   cSql += "       (SELECT TOP 1 H.BM_DESC FROM SBM010 H WHERE A.D2_GRUPO = H.BM_GRUPO) GRUPO  ," + chr(13) 
   cSql += "       (SELECT TOP 1 H.BM_DIVI FROM SBM010 H WHERE A.D2_GRUPO = H.BM_GRUPO) DIVISAO," + chr(13) 
   cSql += "        D.B1_TIPO                      as TIPO_D2     ," + chr(13) 
   cSql += "        A.D2_UM                        as UN          ," + chr(13) 
   cSql += "        A.D2_QUANT                     as QUANT_D2    ," + chr(13) 
   cSql += "        A.D2_TOTAL                     as TOTAL_D2    ," + chr(13) 
   cSql += "        A.D2_VALFRE                    as VALFRETE_D2 ," + chr(13) 
   cSql += "        F.C5_FORNEXT                   as C5_FORNEXT  ," + chr(13) 
   cSql += "        A.D2_QTGMRG                    as MARGEM      ," + chr(13) 

   Do Case
      Case Substr(cComboBx2,01,02) == "01"
           cSql += "       (SELECT TOP 1 F2_ZTVD FROM SF2010 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') TIPO_VENDEDOR  ," + chr(13) 
           cSql += "       (SELECT TOP 1 F2_ZTCL FROM SF2010 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') TIPO_CLIENTE   ," + chr(13) 
           cSql += "       (SELECT TOP 1 F2_ZFPG FROM SF2010 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') FORMA_PAGAMENTO," + chr(13) 

      Case Substr(cComboBx2,01,02) == "02"
           cSql += "       (SELECT TOP 1 F2_ZTVD FROM SF2020 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') TIPO_VENDEDOR  ," + chr(13) 
           cSql += "       (SELECT TOP 1 F2_ZTCL FROM SF2020 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') TIPO_CLIENTE   ," + chr(13) 
           cSql += "       (SELECT TOP 1 F2_ZFPG FROM SF2020 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') FORMA_PAGAMENTO," + chr(13) 

      Case Substr(cComboBx2,01,02) == "03"
           cSql += "       (SELECT TOP 1 F2_ZTVD FROM SF2030 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') TIPO_VENDEDOR  ," + chr(13) 
           cSql += "       (SELECT TOP 1 F2_ZTCL FROM SF2030 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') TIPO_CLIENTE   ," + chr(13) 
           cSql += "       (SELECT TOP 1 F2_ZFPG FROM SF2030 B WHERE B.F2_DOC = A.D2_DOC AND B.F2_SERIE = A.D2_SERIE AND B.F2_FILIAL = A.D2_FILIAL AND B.D_E_L_E_T_ = '') FORMA_PAGAMENTO," + chr(13) 

   EndCase

   cSql += "        CASE A.D2_ZTGP                        " + chr(13)
   cSql += "             WHEN 1 THEN 'SUPRIMENTOS'        " + chr(13)
   cSql += "             WHEN 2 THEN 'ASSISTENCIA TECNICA'" + chr(13)
   cSql += "             WHEN 3 THEN 'PROJETOS'           " + chr(13)
   cSql += "             WHEN 4 THEN 'EQUIPAMENTOS'       " + chr(13)
   cSql += "             WHEN 5 THEN 'OUTROS'             " + chr(13)
   cSql += "             ELSE 'NAO DEFINIDO'              " + chr(13)
   cSql += "        END AS GRUPO_PRODUTO                  " + chr(13)

   Do Case
      Case Substr(cComboBx2,01,02) == "01"
           cSql += "   FROM SD2010 AS A INNER JOIN" + chr(13)
           cSql += "        SF2010 AS B ON A.D2_DOC     = B.F2_DOC AND A.D2_FILIAL = B.F2_FILIAL AND A.D2_SERIE = B.F2_SERIE INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SA1") + " AS C ON A.D2_CLIENTE = C.A1_COD AND A.D2_LOJA   = C.A1_LOJA INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SB1") + " AS D ON A.D2_COD     = D.B1_COD INNER JOIN" + chr(13)
           cSql += "        SC5010 AS F ON A.D2_PEDIDO  = F.C5_NUM AND A.D2_FILIAL = F.C5_FILIAL INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SF4") + " AS G ON A.D2_TES     = G.F4_CODIGO" + chr(13)

      Case Substr(cComboBx2,01,02) == "02"
           cSql += "   FROM SD2020 AS A INNER JOIN" + chr(13)
           cSql += "        SF2020 AS B ON A.D2_DOC     = B.F2_DOC AND A.D2_FILIAL = B.F2_FILIAL AND A.D2_SERIE = B.F2_SERIE INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SA1") + " AS C ON A.D2_CLIENTE = C.A1_COD AND A.D2_LOJA   = C.A1_LOJA INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SB1") + " AS D ON A.D2_COD     = D.B1_COD INNER JOIN" + chr(13)
           cSql += "        SC5020 AS F ON A.D2_PEDIDO  = F.C5_NUM AND A.D2_FILIAL = F.C5_FILIAL INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SF4") + " AS G ON A.D2_TES     = G.F4_CODIGO" + chr(13)
           
      Case Substr(cComboBx2,01,02) == "03"
           cSql += "   FROM SD2030 AS A INNER JOIN" + chr(13)
           cSql += "        SF2030 AS B ON A.D2_DOC     = B.F2_DOC AND A.D2_FILIAL = B.F2_FILIAL AND A.D2_SERIE = B.F2_SERIE INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SA1") + " AS C ON A.D2_CLIENTE = C.A1_COD AND A.D2_LOJA   = C.A1_LOJA INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SB1") + " AS D ON A.D2_COD     = D.B1_COD INNER JOIN" + chr(13)
           cSql += "        SC5030 AS F ON A.D2_PEDIDO  = F.C5_NUM AND A.D2_FILIAL = F.C5_FILIAL INNER JOIN" + chr(13)
           cSql += "        " + RetSqlName("SF4") + " AS G ON A.D2_TES     = G.F4_CODIGO" + chr(13)
   Endcase
           
   cSql += "  WHERE"  + chr(13)
   cSql += "    (B.F2_TIPO)           = 'N'" + chr(13)
   cSql += "    AND (F.R_E_C_D_E_L_)  = '' " + chr(13)
   cSql += "    AND (A.R_E_C_D_E_L_)  = '' " + chr(13)
   cSql += "    AND (B.R_E_C_D_E_L_)  = '' " + chr(13)
   cSql += "    AND (A.D2_EMISSAO    <= GETDATE())" + chr(13)

   Do Case
      Case Substr(cComboBx3,01,02) == "01"
          cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
      Case Substr(cComboBx3,01,02) == "02"
          cSql += "	AND B.F2_FILIAL = '02'" + chr(13)
      Case Substr(cComboBx3,01,02) == "03"
          cSql += "	AND B.F2_FILIAL = '03'" + chr(13)
      Case Substr(cComboBx3,01,02) == "04"
          cSql += "	AND B.F2_FILIAL = '04'" + chr(13)
      Case Substr(cComboBx3,01,02) == "TI"
          cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
      Case Substr(cComboBx3,01,02) == "AT"
          cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
   EndCase

   cSql += "	AND B.F2_VEND1        = '" + Substr(cComboBx1,01,06) + "'"
   cSql += "    AND B.F2_EMISSAO     >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
   cSql += "    AND B.F2_EMISSAO     <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
   cSql += "    AND ((G.F4_DUPLIC)    = 'S' OR (A.D2_TES = '543'))" + chr(13)
   cSql += "  ORDER BY B.F2_FILIAL, B.F2_DOC, B.F2_SERIE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDAS", .T., .T. )

   T_VENDAS->( DbGoTop() )
   
   WHILE !T_VENDAS->( EOF() )

      // Verifica se Filial/Documento/Série já está contido no array aBrowse
      lExiste := .F.
      For nContar = 1 to Len(aBrowse)
          If Alltrim(aBrowse[nContar,02]) == Alltrim(T_VENDAS->FILIAL)      .And. ;
             Alltrim(aBrowse[nContar,03]) == Alltrim(T_VENDAS->NUM_NOTA_D2) .And. ;
             Alltrim(aBrowse[nContar,04]) == Alltrim(T_VENDAS->SERIE_D2)
             lExiste := .T.
             aBrowse[nContar,06] := aBrowse[nContar,06] + (T_VENDAS->TOTAL_D2 + T_VENDAS->VALFRETE_D2)
             aBrowse[nContar,08] := aBrowse[nContar,06] - aBrowse[nContar,07]
             Exit
          Endif
      Next nContar
      
      If lExiste == .T.
         T_VENDAS->( DbSkip() )                
         Loop
      Endif
         
      aAdd( aBrowse, { "2"                                         ,; // 01 - Legenda
                       T_VENDAS->FILIAL                            ,; // 02 - Filial 
                       T_VENDAS->NUM_NOTA_D2                       ,; // 03 - Nota Fiscal
                       T_VENDAS->SERIE_D2                          ,; // 04 - Série Nota Fiscal
                       T_VENDAS->DATADIGI                          ,; // 05 - Data de Digitação
                      (T_VENDAS->TOTAL_D2 + T_VENDAS->VALFRETE_D2) ,; // 06 - Sub-Total da Nota Fiscal
                       0                                           ,; // 07 - Desconto Nota Fiscal
                      (T_VENDAS->TOTAL_D2 + T_VENDAS->VALFRETE_D2) ,; // 08 - Total Nota Fiscal BI
                       0                                           ,; // 09 - Sub-Total AtechInfo
                       0                                           ,; // 10 - Devolução AtechInfo
                       0                                           ,; // 11 - Total AtechInfo
                       0                                           }) // 12 - Diferença

      T_VENDAS->( DbSkip() )
      
   ENDDO
   
   // Pesquisa as devoluções do BI para as notas fiscais do array aBrowse
   For nContar = 1 to Len(aBrowse)
   
       If Select("T_DEVOLUCAO") > 0
          T_DEVOLUCAO->( dbCloseArea() )
       EndIf

       cSql := "SELECT SUM(SD1.D1_TOTAL) AS DEVOLUCAO"                            + chr(13)

       Do Case
          Case Substr(cComboBx2,01,02) == "01"
               cSql += "  FROM SD1010 SD1, "                           + chr(13)
          Case Substr(cComboBx2,01,02) == "02"
               cSql += "  FROM SD1020 SD1, "                           + chr(13)
          Case Substr(cComboBx2,01,02) == "03"
               cSql += "  FROM SD1030 SD1, "                           + chr(13)
       EndCase

       cSql += "       " + RetSqlName("SF4") + " SF4  "                           + chr(13)
       cSql += " WHERE SD1.D1_NFORI   = '"   + Alltrim(aBrowse[nContar,03]) + "'" + chr(13)
       cSql += "   AND SD1.D1_SERIORI = '"   + Alltrim(aBrowse[nContar,04]) + "'" + chr(13)
       cSql += "   AND SD1.D_E_L_E_T_ = ''"                                       + chr(13)
       cSql += "   AND SD1.D1_TES     = SF4.F4_CODIGO"                            + chr(13)
       cSql += "   AND (SF4.F4_DUPLIC = 'S' OR SD1.D1_TES = '543')"               + chr(13)

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

       If !T_DEVOLUCAO->( EOF() )
          aBrowse[nContar,07] := T_DEVOLUCAO->DEVOLUCAO
          aBrowse[nContar,08] := aBrowse[nContar,06] - aBrowse[nContar,07]
       Endif

   Next nContar

   // ------------------------------------ //                                     
   // Pesquisa os lançamentos do AtechInfo //
   // ------------------------------------ //                                          
   If Select("T_ATECHINFO") > 0
      T_ATECHINFO->( dbCloseArea() )
   EndIf

   cSql := "SELECT B.F2_FILIAL,"                                   + chr(13)
   cSql += "       B.F2_DOC   ,"                                   + chr(13)
   cSql += "       B.F2_SERIE ,"                                   + chr(13)
   cSql += "       B.F2_VEND1 ,"                                   + chr(13)
   cSql += "      (A.D2_TOTAL + A.D2_VALFRE) AS TOTAL,           " + chr(13)
   cSql += "      (SELECT CASE WHEN SUM(D1_TOTAL) IS NULL THEN 0 " + chr(13)
   cSql += "                   ELSE SUM(D1_TOTAL) END AS Expr1   " + chr(13)

   Do Case
      Case Substr(cComboBx2,01,02) == "01"
           cSql += "         FROM SD1010" + chr(13)
      Case Substr(cComboBx2,01,02) == "02"
           cSql += "         FROM SD1020" + chr(13)
      Case Substr(cComboBx2,01,02) == "03"
           cSql += "         FROM SD1030" + chr(13)
   EndCase

   cSql += "        WHERE (D1_NFORI     = A.D2_DOC)         "      + chr(13)
   cSql += "  	      AND (D1_SERIORI   = A.D2_SERIE)       "      + chr(13)
   cSql += "	      AND (D1_FILIAL    = A.D2_FILIAL)      "      + chr(13)
   cSql += "	      AND (D1_ITEMORI   = A.D2_ITEM)        "      + chr(13)
   cSql += "	      AND (R_E_C_D_E_L_ = '')) AS DEVOLUCAO,"      + chr(13)
   cSql += "       A.D2_EMISSAO"                                   + chr(13)

   Do Case
      Case Substr(cComboBx2,01,02) == "01"
           cSql += "  FROM SD2010 AS A INNER JOIN"      + chr(13)
           cSql += "       SF2010 AS B ON A.D2_DOC = B.F2_DOC   " + chr(13)
           cSql += "                  AND A.D2_FILIAL             = B.F2_FILIAL" + chr(13)
           cSql += "                  AND A.D2_SERIE              = B.F2_SERIE " + chr(13)
           cSql += "                  AND B.F2_EMISSAO           >= CONVERT(DATETIME,'" + Dtoc(dInicial)  + "', 103)"      + CHR(13)
           cSql += "                  AND B.F2_EMISSAO           <= CONVERT(DATETIME,'" + Dtoc(dFinal)    + "', 103)"      + CHR(13)

           Do Case
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += "	AND B.F2_FILIAL = '02'" + chr(13)
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += "	AND B.F2_FILIAL = '03'" + chr(13)
              Case Substr(cComboBx3,01,02) == "04"
                   cSql += "	AND B.F2_FILIAL = '04'" + chr(13)
              Case Substr(cComboBx3,01,02) == "TI"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
              Case Substr(cComboBx3,01,02) == "AT"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
           EndCase

           cSql += "                  AND B.F2_VEND1              = '" + Alltrim(Substr(cComboBx1,01,06)) + "' INNER JOIN" + chr(13)
           cSql += "       " + RetSqlName("SA1") + " AS C ON A.D2_CLIENTE = C.A1_COD AND A.D2_LOJA = C.A1_LOJA INNER JOIN"     + chr(13)
           cSql += "       " + RetSqlName("SB1") + " AS D ON A.D2_COD     = D .B1_COD INNER JOIN"                              + chr(13)
           cSql += "       SC5010 AS F ON A.D2_PEDIDO  = F.C5_NUM AND A.D2_FILIAL = F.C5_FILIAL INNER JOIN" + chr(13)
           cSql += "       " + RetSqlName("SF4") + " AS G ON A.D2_TES     = G.F4_CODIGO"                                       + chr(13)

      Case Substr(cComboBx2,01,02) == "02"
           cSql += "  FROM SD2020 AS A INNER JOIN"      + chr(13)
           cSql += "       SF2020 AS B ON A.D2_DOC = B.F2_DOC   " + chr(13)
           cSql += "                  AND A.D2_FILIAL             = B.F2_FILIAL" + chr(13)
           cSql += "                  AND A.D2_SERIE              = B.F2_SERIE " + chr(13)
           cSql += "                  AND B.F2_EMISSAO           >= CONVERT(DATETIME,'" + Dtoc(dInicial)  + "', 103)"      + CHR(13)
           cSql += "                  AND B.F2_EMISSAO           <= CONVERT(DATETIME,'" + Dtoc(dFinal)    + "', 103)"      + CHR(13)

           Do Case
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += "	AND B.F2_FILIAL = '02'" + chr(13)
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += "	AND B.F2_FILIAL = '03'" + chr(13)
              Case Substr(cComboBx3,01,02) == "04"
                   cSql += "	AND B.F2_FILIAL = '04'" + chr(13)
              Case Substr(cComboBx3,01,02) == "TI"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
              Case Substr(cComboBx3,01,02) == "AT"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
           EndCase

           cSql += "                  AND B.F2_VEND1              = '" + Alltrim(Substr(cComboBx1,01,06)) + "' INNER JOIN" + chr(13)
           cSql += "       " + RetSqlName("SA1") + " AS C ON A.D2_CLIENTE = C.A1_COD AND A.D2_LOJA = C.A1_LOJA INNER JOIN"     + chr(13)
           cSql += "       " + RetSqlName("SB1") + " AS D ON A.D2_COD     = D .B1_COD INNER JOIN"                              + chr(13)
           cSql += "       SC5020 AS F ON A.D2_PEDIDO  = F.C5_NUM AND A.D2_FILIAL = F.C5_FILIAL INNER JOIN" + chr(13)
           cSql += "       " + RetSqlName("SF4") + " AS G ON A.D2_TES     = G.F4_CODIGO"                                       + chr(13)

      Case Substr(cComboBx2,01,02) == "03"
           cSql += "  FROM SD2030 AS A INNER JOIN"      + chr(13)
           cSql += "       SF2030 AS B ON A.D2_DOC = B.F2_DOC   " + chr(13)
           cSql += "                  AND A.D2_FILIAL             = B.F2_FILIAL" + chr(13)
           cSql += "                  AND A.D2_SERIE              = B.F2_SERIE " + chr(13)
           cSql += "                  AND B.F2_EMISSAO           >= CONVERT(DATETIME,'" + Dtoc(dInicial)  + "', 103)"      + CHR(13)
           cSql += "                  AND B.F2_EMISSAO           <= CONVERT(DATETIME,'" + Dtoc(dFinal)    + "', 103)"      + CHR(13)

           Do Case
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += "	AND B.F2_FILIAL = '02'" + chr(13)
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += "	AND B.F2_FILIAL = '03'" + chr(13)
              Case Substr(cComboBx3,01,02) == "04"
                   cSql += "	AND B.F2_FILIAL = '04'" + chr(13)
              Case Substr(cComboBx3,01,02) == "TI"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
              Case Substr(cComboBx3,01,02) == "AT"
                   cSql += "	AND B.F2_FILIAL = '01'" + chr(13)
           EndCase

           cSql += "                  AND B.F2_VEND1              = '" + Alltrim(Substr(cComboBx1,01,06)) + "' INNER JOIN" + chr(13)
           cSql += "       " + RetSqlName("SA1") + " AS C ON A.D2_CLIENTE = C.A1_COD AND A.D2_LOJA = C.A1_LOJA INNER JOIN"     + chr(13)
           cSql += "       " + RetSqlName("SB1") + " AS D ON A.D2_COD     = D .B1_COD INNER JOIN"                              + chr(13)
           cSql += "       SC5030 AS F ON A.D2_PEDIDO  = F.C5_NUM AND A.D2_FILIAL = F.C5_FILIAL INNER JOIN" + chr(13)
           cSql += "       " + RetSqlName("SF4") + " AS G ON A.D2_TES     = G.F4_CODIGO"                                       + chr(13)

   EndCase
   
   cSql += " WHERE (B.F2_TIPO = 'N')    "                     + chr(13)
   cSql += "   AND (F.R_E_C_D_E_L_ = '')"                     + chr(13)
   cSql += "   AND (A.R_E_C_D_E_L_ = '')"                     + chr(13)
   cSql += "   AND (B.R_E_C_D_E_L_ = '')"                     + chr(13)
   cSql += "   AND (G.F4_DUPLIC = 'S') OR (B.F2_TIPO = 'N') " + chr(13)
   cSql += "   AND (F.R_E_C_D_E_L_ = '')"                     + chr(13)
   cSql += "   AND (A.R_E_C_D_E_L_ = '')"                     + chr(13)
   cSql += "   AND (B.R_E_C_D_E_L_ = '')"                     + chr(13)
   cSql += "   AND (A.D2_TES = '543')   "                     + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATECHINFO", .T., .T. )
   
   T_ATECHINFO->( DbGoTop() )
   
   WHILE !T_ATECHINFO->( EOF() )
   
      // Verifica se Filial/Documento/Série já está contido no array aBrowse
      lExiste := .F.
      For nContar = 1 to Len(aBrowse)
          If Alltrim(aBrowse[nContar,02]) == Alltrim(T_ATECHINFO->F2_FILIAL) .And. ;
             Alltrim(aBrowse[nContar,03]) == Alltrim(T_ATECHINFO->F2_DOC)    .And. ;
             Alltrim(aBrowse[nContar,04]) == Alltrim(T_ATECHINFO->F2_SERIE)
             lExiste := .T.
             aBrowse[nContar,09] := aBrowse[nContar,09] + (T_ATECHINFO->TOTAL)
             aBrowse[nContar,10] := 0
             aBrowse[nContar,11] := aBrowse[nContar,09] - aBrowse[nContar,10]
             Exit
          Endif
      Next nContar

      If lExiste == .T.
         T_ATECHINFO->( DbSkip() )                
         Loop
      Endif

      cTexto := cTexto + T_ATECHINFO->F2_FILIAL + " - NF: " + T_ATECHINFO->F2_DOC + " - Série: " + T_ATECHINFO->F2_SERIE + CHR(13)
      
      T_ATECHINFO->( DbSkip() )                
      
   Enddo

   // Display das notas fiscais não localizadas
   cLocaliza := cTexto
   oMemo2:Refresh()

   // Pesquisa as devoluções do BI para as notas fiscais do array aBrowse
   For nContar = 1 to Len(aBrowse)
   
       If Select("T_DEVOLUCAO") > 0
          T_DEVOLUCAO->( dbCloseArea() )
       EndIf

       cSql := "SELECT A.F2_VEND1  ," + chr(13)
       cSql += "       A.F2_VEND2  ," + chr(13)
       cSql += "       A.F2_VEND3  ," + chr(13)
       cSql += "       A.F2_VEND4  ," + chr(13)
       cSql += "       A.F2_VEND5  ," + chr(13)
       cSql += "       B.D1_TOTAL  ," + chr(13)
       cSql += "       B.D1_EMISSAO," + chr(13)
       cSql += "       B.D1_DTDIGIT " + chr(13)

       Do Case
          Case Substr(cComboBx2,01,02) == "01"
               cSql += "  FROM SD1010 AS B INNER JOIN"                                               + chr(13)
               cSql += "       SF2010 AS A ON B.D1_NFORI   = '" + Alltrim(aBrowse[nContar,03]) + "'" + chr(13)
               cSql += "                  AND B.D1_FILIAL  = '" + Alltrim(aBrowse[nContar,02]) + "'" + chr(13)
               cSql += "                  AND B.D1_SERIORI = '" + Alltrim(aBrowse[nContar,04]) + "'" + chr(13)

          Case Substr(cComboBx2,01,02) == "02"
               cSql += "  FROM SD1020 AS B INNER JOIN"                                               + chr(13)
               cSql += "       SF2020 AS A ON B.D1_NFORI   = '" + Alltrim(aBrowse[nContar,03]) + "'" + chr(13)
               cSql += "                  AND B.D1_FILIAL  = '" + Alltrim(aBrowse[nContar,02]) + "'" + chr(13)
               cSql += "                  AND B.D1_SERIORI = '" + Alltrim(aBrowse[nContar,04]) + "'" + chr(13)

          Case Substr(cComboBx2,01,02) == "03"
               cSql += "  FROM SD1030 AS B INNER JOIN"                                               + chr(13)
               cSql += "       SF2030 AS A ON B.D1_NFORI   = '" + Alltrim(aBrowse[nContar,03]) + "'" + chr(13)
               cSql += "                  AND B.D1_FILIAL  = '" + Alltrim(aBrowse[nContar,02]) + "'" + chr(13)
               cSql += "                  AND B.D1_SERIORI = '" + Alltrim(aBrowse[nContar,04]) + "'" + chr(13)
               
       EndCase               
               
       cSql += "  WHERE (B.R_E_C_D_E_L_ = '') AND (B.D1_TIPO = 'D' OR B.D1_TIPO = 'N')"                         + chr(13)

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

       If !T_DEVOLUCAO->( EOF() )
          aBrowse[nContar,10] := T_DEVOLUCAO->D1_TOTAL
          aBrowse[nContar,11] := aBrowse[nContar,09] - aBrowse[nContar,10]
       Endif

   Next nContar

   // Calcula a diferença e acerta a legenda dos registros
   nQtd_NF := 0
   nVal_NF := 0

   For nContar = 1 to Len(aBrowse)

       nQtd_NF := nQtd_NF + 1
       nVal_NF := nVal_NF + aBrowse[nContar,08]

       aBrowse[nContar,08] := aBrowse[nContar,06] - aBrowse[nContar,07]
       aBrowse[nContar,11] := aBrowse[nContar,09] - aBrowse[nContar,10]
       aBrowse[nContar,12] := aBrowse[nContar,08] - aBrowse[nContar,11]

       If aBrowse[nContar,12] == 0
          aBrowse[nContar,01] := "2"
       Else
          aBrowse[nContar,01] := "8"          
       Endif
       
   Next nContar       

   nTotal_NF    := nQtd_NF
   nTotal_Valor := nVal_NF
   
   oGet3:Refresh()
   oGet4:Refresh()

   // Verifica se array está zerado
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "1", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif

   // Refresh dos dados do grid na tela
   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               ,;                         
                         aBrowse[oBrowse:nAt,09]               ,;                         
                         aBrowse[oBrowse:nAt,10]               ,;                                                     
                         aBrowse[oBrowse:nAt,11]               ,;                         
                         aBrowse[oBrowse:nAt,12]               }}

Return(.T.)