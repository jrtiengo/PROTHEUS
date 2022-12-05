#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#include "TOTVS.CH"
#include "fileio.ch"

// ##########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                   ##
// --------------------------------------------------------------------------------------- ##
// Referencia: AUTOM670.PRW                                                                ##
// Parâmetros: Nenhum                                                                      ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                             ##
// --------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                     ##
// Data......: 11/01/2018                                                                  ##
// Objetivo..: Programa que gera a correção do campo IDENT entre as Tabelas SD1, SD2 e SB6 ##
// Parâmetros: Sem parâmetros                                                              ##
// ##########################################################################################

User Function AUTOM670()
   
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Local cSql := ""

   Private aEmpresas := U_AUTOM539(1, "")     
   Private aFiliais  := U_AUTOM539(2, cEmpAnt)
   Private aTES    	 := {}
   Private aIdenti   := {"1 - Diferente", "2 - Igual", "3 - Em Branco"}
   Private aEmissao  := {"1 - Emissão", "2 - Digitação"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5

   Private dInicial	 := Ctod("01/01/2010")
   Private dFinal 	 := Ctod("31/12/" + Strzero(Year(Date()),4))

   Private oGet1
   Private oGet2

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}

   Private oDlg

   // ###########################################################
   // Carrega o combo de Tes com as Tes de porder de terceiros ##
   // ###########################################################                         
   If Select("T_TES") > 0
      T_TES->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql := "SELECT F4_CODIGO,"
   cSql += "       F4_TEXTO ,"
   cSql += "       F4_PODER3 "
   cSql += "  FROM " + RetSqlName("SF4")
   cSql += " WHERE F4_PODER3 <> 'N'"
   cSql += "   AND F4_MSBLQL <> '1'"
   cSql += "   AND D_E_L_E_T_ = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TES", .T., .T. )

   aTES := {}
   aAdd( aTES, "000 - Todas as TES" )
   
   T_TES->( DbGoTop() )
   
   WHILE !T_TES->( EOF() )
      aAdd( ATES, T_TES->F4_CODIGO + " - " + Alltrim(T_TES->F4_TEXTO) )  
      T_TES->( DbSkip() )
   ENDDO   

   aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   DEFINE MSDIALOG oDlg TITLE "Inconsistências Poder de Tereceiros" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Empresa"      Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(066) Say "Filiais"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(142) Say "Dta Inicial"  Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(182) Say "Dta Final"    Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(223) Say "Data a Pesq." Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(273) Say "TES"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(378) Say "Ident"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) ComboBox cComboBx1 Items aEmpresas Size C(059),C(010)                              PIXEL OF oDlg ON CHANGE ALTERACOMBO() When lChumba
   @ C(044),C(066) ComboBox cComboBx2 Items aFiliais  Size C(072),C(010)                              PIXEL OF oDlg
   @ C(044),C(142) MsGet    oGet1     Var   dInicial  Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(182) MsGet    oGet2     Var   dFinal    Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(223) ComboBox cComboBx5 Items aEmissao  Size C(040),C(010)                              PIXEL OF oDlg
   @ C(044),C(273) ComboBox cComboBx3 Items aTES      Size C(102),C(010)                              PIXEL OF oDlg
   @ C(043),C(378) ComboBox cComboBx4 Items aIdenti   Size C(059),C(010)                              PIXEL OF oDlg
   
   @ C(043),C(461) Button "Pesquisar"         Size C(037),C(012) PIXEL OF oDlg ACTION( PsqPoder3() )
   @ C(210),C(005) Button "Marca Todos"       Size C(037),C(012) PIXEL OF oDlg ACTION( MrkReg(1) )
   @ C(210),C(043) Button "Desmar Todos"      Size C(037),C(012) PIXEL OF oDlg ACTION( MrkReg(2) )
   @ C(210),C(103) Button "Detalhes Registro" Size C(056),C(012) PIXEL OF oDlg ACTION( mRegistro() )
   @ C(210),C(160) Button "Gerar em Excel"    Size C(056),C(012) PIXEL OF oDlg ACTION( TGPCSV() )
// @ C(210),C(229) Button "Pesquisa Avançada" Size C(065),C(012) PIXEL OF oDlg ACTION( PAvancada() )
   @ C(210),C(308) Button "Corrigir IDENT"    Size C(056),C(012) PIXEL OF oDlg ACTION( CorrigeIDent() )
   @ C(210),C(461) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ 080,005 LISTBOX oLista FIELDS HEADER "Mrc"          ,; // 01 
                                          "Filial"       ,; // 02
                                          "Documento"    ,; // 03
                                          "Série"        ,; // 04
                                          "Fornecedor"   ,; // 05
                                          "Loja"         ,; // 06
                                          "TES"          ,; // 07
                                          "Item"         ,; // 08
                                          "Produto"      ,; // 09
                                          "NF Origem"    ,; // 10
                                          "Série Origem" ,; // 11
                                          "Item Origem"  ,; // 12
                                          "Ident D1"     ,; // 13
                                          "NF Saída"     ,; // 14
                                          "Série Saída"  ,; // 15
                                          "Cliente Saída",; // 16
                                          "Ident D2"      ; // 17
                                          PIXEL SIZE 633,185 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),; 
                                aLista[oLista:nAt,02]         ,;
                                aLista[oLista:nAt,03]         ,;
                                aLista[oLista:nAt,04]         ,;
                                aLista[oLista:nAt,05]         ,;                                                                
                                aLista[oLista:nAt,06]         ,;
                                aLista[oLista:nAt,07]         ,;
                                aLista[oLista:nAt,08]         ,;
                                aLista[oLista:nAt,09]         ,;
                                aLista[oLista:nAt,10]         ,;                                                                
                                aLista[oLista:nAt,11]         ,;
                                aLista[oLista:nAt,12]         ,;
                                aLista[oLista:nAt,13]         ,;
                                aLista[oLista:nAt,14]         ,;
                                aLista[oLista:nAt,15]         ,;                                                                
                                aLista[oLista:nAt,16]         ,;
                                aLista[oLista:nAt,17]}}

   oLista:bHeaderClick := {|oObj,nCol| oLista:aArray := Ordenar(nCol,oLista:aArray),oLista:Refresh()}
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################
// Função que Ordena a coluna selecionada no grid ##
// #################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// ##############################################################
// Função que carrega as filiais conforme a seleção da Empresa ##
// ##############################################################
Static Function AlteraCombo()

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(044),C(066) ComboBox cComboBx2 Items aFiliais  Size C(072),C(010) PIXEL OF oDlg

Return(.T.)

// #########################################################
// Função que pesquisa os lançamentos conforme parâmetros ##
// #########################################################
Static Function PsqPoder3()

   MsgRun("Aguarde! Pesquisando informações ...", "Selecionando os Registros", {|| xPsqPoder3() })

// #########################################################
// Função que pesquisa os lançamentos conforme parâmetros ##
// #########################################################
Static Function xPsqPoder3()

   Local cSql := ""

   If dInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial para pesquisa não informada.")
      Return(.T.)
   Endif
      
   If dFinal == Ctod("  /  /    ")
      MsgAlert("Data final para pesquisa não informada.")
      Return(.T.)
   Endif

   aLista := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SD1.D1_FILIAL ," + chr(13)
   cSql += "       SD1.D1_DOC    ," + chr(13)
   cSql += "       SD1.D1_SERIE  ," + chr(13)
   cSql += "       SD1.D1_FORNECE," + chr(13)
   cSql += "       SD1.D1_LOJA   ," + chr(13)
   cSql += "       SD1.D1_TES    ," + chr(13)
   cSql += "       SD1.D1_ITEM   ," + chr(13)
   cSql += "       SD1.D1_COD    ," + chr(13)
   cSql += "       SD1.D1_NFORI  ," + chr(13)
   cSql += "       SD1.D1_SERIORI," + chr(13)
   cSql += "       SD1.D1_ITEMORI," + chr(13)
   cSql += "       SD1.D1_IDENTB6 AS IDENT_D1," + chr(13)
   cSql += "      (SELECT D2_DOC " + chr(13)
   cSql += "         FROM " + RetSqlName("SD2") + chr(13)
   cSql += "        WHERE D2_FILIAL  = SD1.D1_FILIAL " + chr(13)
   cSql += "       	  AND D2_DOC     = SD1.D1_NFORI  " + chr(13)
   cSql += "       	  AND D2_SERIE   = SD1.D1_SERIORI" + chr(13)
   cSql += "       	  AND D2_ITEM    = SD1.D1_ITEMORI" + chr(13)
   cSql += "       	  AND D2_COD     = SD1.D1_COD    " + chr(13)
   cSql += "       	  AND D_E_L_E_T_ = '' ) AS NF_SAIDA," + chr(13)
   cSql += "      (SELECT D2_SERIE" + chr(13)
   cSql += "         FROM " + RetSqlName("SD2") + chr(13)
   cSql += "      	WHERE D2_FILIAL  = SD1.D1_FILIAL " + chr(13)
   cSql += "      	  AND D2_DOC     = SD1.D1_NFORI  " + chr(13)
   cSql += "      	  AND D2_SERIE   = SD1.D1_SERIORI" + chr(13)
   cSql += "      	  AND D2_ITEM    = SD1.D1_ITEMORI" + chr(13)
   cSql += "      	  AND D2_COD     = SD1.D1_COD    " + chr(13)
   cSql += "      	  AND D_E_L_E_T_ = '' ) AS SERIE_SAIDA," + chr(13)
   cSql += "      (SELECT D2_CLIENTE" + chr(13)
   cSql += "         FROM " + RetSqlName("SD2") + chr(13)
   cSql += "    	WHERE D2_FILIAL  = SD1.D1_FILIAL " + chr(13)
   cSql += "    	  AND D2_DOC     = SD1.D1_NFORI  " + chr(13)
   cSql += "    	  AND D2_SERIE   = SD1.D1_SERIORI" + chr(13)
   cSql += "    	  AND D2_ITEM    = SD1.D1_ITEMORI" + chr(13)
   cSql += "    	  AND D2_COD     = SD1.D1_COD    " + chr(13)
   cSql += "       	  AND D_E_L_E_T_ = '' ) AS CLIENTE_SAIDA," + chr(13)
   cSql += "      (SELECT D2_IDENTB6" + chr(13)
   cSql += "      	 FROM " + RetSqlName("SD2") + chr(13)
   cSql += "       	WHERE D2_FILIAL  = SD1.D1_FILIAL " + chr(13)
   cSql += "       	  AND D2_DOC     = SD1.D1_NFORI  " + chr(13)
   cSql += "       	  AND D2_SERIE   = SD1.D1_SERIORI" + chr(13)
   cSql += "       	  AND D2_ITEM    = SD1.D1_ITEMORI" + chr(13)
   cSql += "       	  AND D2_COD     = SD1.D1_COD    " + chr(13)
   cSql += "       	  AND D_E_L_E_T_ = '' ) AS IDENT_D2" + chr(13)
   cSql += "  FROM " + RetSqlName("SD1") + " SD1," + chr(13)
   cSql += "       " + RetSqlName("SF4") + " SF4 " + chr(13)
   cSql += " WHERE SD1.D1_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND SD1.D_E_L_E_T_  = '' " + chr(13)
   cSql += "   AND SD1.D1_NFORI   <> ''  " + chr(13)

   If Substr(cComboBx5,01,01) == "1"
      cSql += "   AND SD1.D1_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
      cSql += "   AND SD1.D1_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
   Else   
      cSql += "   AND SD1.D1_DTDIGIT >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
      cSql += "   AND SD1.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
   Endif   

   If Substr(cComboBx3,01,03) == "000"
      cSql += "   AND SF4.F4_PODER3 <> 'N'"        + chr(13)
      cSql += "   AND SF4.F4_CODIGO  = SD1.D1_TES" + chr(13)
      cSql += "   AND SF4.F4_PODER3 <> 'N'"        + chr(13)
      cSql += "   AND SF4.D_E_L_E_T_ = '' "        + chr(13)
   Else
      cSql += "   AND SD1.D1_TES     = '" + Alltrim(Substr(cComboBx3,01,03)) + "'"
      cSql += "   AND SF4.F4_CODIGO  = SD1.D1_TES" + chr(13)
      cSql += "   AND SF4.D_E_L_E_T_ = '' "        + chr(13)
   Endif   

   Do Case 
      Case Substr(cComboBx4,01,01) == "1"
           cSql += "   AND SD1.D1_IDENTB6 <> (SELECT D2_IDENTB6" + chr(13)
           cSql += "  	                        FROM " + RetSqlName("SD2") + chr(13)
           cSql += "                           WHERE D2_FILIAL  = SD1.D1_FILIAL " + chr(13)
           cSql += "       		                 AND D2_DOC     = SD1.D1_NFORI  " + chr(13)
           cSql += "       		                 AND D2_SERIE   = SD1.D1_SERIORI" + chr(13)
           cSql += "       		                 AND D2_ITEM    = SD1.D1_ITEMORI" + chr(13)
           cSql += "       		                 AND D2_COD     = SD1.D1_COD    " + chr(13)
           cSql += "       		                 AND D_E_L_E_T_ = '')           " + chr(13)

      Case Substr(cComboBx4,01,01) == "2"
           cSql += "   AND SD1.D1_IDENTB6 =  (SELECT D2_IDENTB6" + chr(13)
           cSql += "  	                        FROM " + RetSqlName("SD2") + chr(13)
           cSql += "                           WHERE D2_FILIAL  = SD1.D1_FILIAL " + chr(13)
           cSql += "       		                 AND D2_DOC     = SD1.D1_NFORI  " + chr(13)
           cSql += "       		                 AND D2_SERIE   = SD1.D1_SERIORI" + chr(13)
           cSql += "       		                 AND D2_ITEM    = SD1.D1_ITEMORI" + chr(13)
           cSql += "       		                 AND D2_COD     = SD1.D1_COD    " + chr(13)
           cSql += "       		                 AND D_E_L_E_T_ = '')           " + chr(13)

      Case Substr(cComboBx4,01,01) == "3"
           cSql += "   AND (SELECT D2_IDENTB6" + chr(13)
           cSql += "  	      FROM " + RetSqlName("SD2") + chr(13)
           cSql += "         WHERE D2_FILIAL  = SD1.D1_FILIAL " + chr(13)
           cSql += "           AND D2_DOC     = SD1.D1_NFORI  " + chr(13)
           cSql += "           AND D2_SERIE   = SD1.D1_SERIORI" + chr(13)
           cSql += "           AND D2_ITEM    = SD1.D1_ITEMORI" + chr(13)
           cSql += "           AND D2_COD     = SD1.D1_COD    " + chr(13)
           cSql += "           AND D_E_L_E_T_ = '') = ''      " + chr(13)
           
   EndCase

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      aAdd( aLista, { .F.                      ,; // 01
                      T_CONSULTA->D1_FILIAL    ,; // 02
                      T_CONSULTA->D1_DOC       ,; // 03
                      T_CONSULTA->D1_SERIE     ,; // 04
                      T_CONSULTA->D1_FORNECE   ,; // 05
                      T_CONSULTA->D1_LOJA      ,; // 06
                      T_CONSULTA->D1_TES       ,; // 07
                      T_CONSULTA->D1_ITEM      ,; // 08
                      T_CONSULTA->D1_COD       ,; // 09
                      T_CONSULTA->D1_NFORI     ,; // 10
                      T_CONSULTA->D1_SERIORI   ,; // 11
                      T_CONSULTA->D1_ITEMORI   ,; // 12
                      T_CONSULTA->IDENT_D1     ,; // 13
                      T_CONSULTA->NF_SAIDA     ,; // 14
                      T_CONSULTA->SERIE_SAIDA  ,; // 15
                      T_CONSULTA->CLIENTE_SAIDA,; // 16
                      T_CONSULTA->IDENT_D2     }) // 17

      T_CONSULTA->( DbSkip() )
      
   ENDDO

   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif       

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),; 
                                aLista[oLista:nAt,02]         ,;
                                aLista[oLista:nAt,03]         ,;
                                aLista[oLista:nAt,04]         ,;
                                aLista[oLista:nAt,05]         ,;                                                                
                                aLista[oLista:nAt,06]         ,;
                                aLista[oLista:nAt,07]         ,;
                                aLista[oLista:nAt,08]         ,;
                                aLista[oLista:nAt,09]         ,;
                                aLista[oLista:nAt,10]         ,;                                                                
                                aLista[oLista:nAt,11]         ,;
                                aLista[oLista:nAt,12]         ,;
                                aLista[oLista:nAt,13]         ,;
                                aLista[oLista:nAt,14]         ,;
                                aLista[oLista:nAt,15]         ,;                                                                
                                aLista[oLista:nAt,16]         ,;
                                aLista[oLista:nAt,17]}}

Return(.T.)

// #########################################
// Função que marca/desmarca os registros ##
// #########################################
Static Function MrkReg(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar       

Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function TGPCSV()

   Local nContar     := 0
   Local aCabExcel   := {}
   Local aItensExcel := {}
   Local lExiste     := .F.

   Private aHead     := {}

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lExiste := .T.
          Exit
       Endif
   Next nContar       

   If lExiste == .F.
      MsgAlert("Atenção! Nenhum registro foi marcado para ser exportado. Verifique!")
      Return(.T.)
   Endif   

   // ######################################################
   // Carrega o array aHead com o cabeçalho para o execel ##
   // ######################################################
   aAdd( aHead, "Filial"       )
   aAdd( aHead, "Documento"    )
   aAdd( aHead, "Série"        )
   aAdd( aHead, "Fornecedor"   )
   aAdd( aHead, "Loja"         )
   aAdd( aHead, "TES"          )
   aAdd( aHead, "Item"         )
   aAdd( aHead, "Produto"      )
   aAdd( aHead, "NF Origem"    )
   aAdd( aHead, "Série Origem" )
   aAdd( aHead, "Item Origem"  )
   aAdd( aHead, "Ident D1"     )
   aAdd( aHead, "NF Saída"     )
   aAdd( aHead, "Série Saída"  )
   aAdd( aHead, "Cliente Saída")
   aAdd( aHead, "Ident D2"     )

   // ####################################################
   // Verifica se o excel está instalado no equipamento ##
   // ####################################################
   If ! ApOleClient( 'MsExcel' )
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
	  Return(Nil)
   EndIf

   AADD(aCabExcel, {"Filial"       , "C", 02, 00 })
   AADD(aCabExcel, {"Documento"    , "C", 09, 00 })
   AADD(aCabExcel, {"Série"        , "C", 03, 00 })
   AADD(aCabExcel, {"Fornecedor"   , "C", 06, 00 })
   AADD(aCabExcel, {"Loja"         , "C", 03, 00 })
   AADD(aCabExcel, {"TES"          , "C", 03, 00 })
   AADD(aCabExcel, {"Item"         , "C", 04, 00 })
   AADD(aCabExcel, {"Produto"      , "C", 30, 00 })
   AADD(aCabExcel, {"NF Origem"    , "C", 09, 00 })
   AADD(aCabExcel, {"Série Origem" , "C", 03, 00 })
   AADD(aCabExcel, {"Item Origem"  , "C", 04, 00 })
   AADD(aCabExcel, {"Ident D1"     , "N", 10, 00 })
   AADD(aCabExcel, {"NF Saída"     , "C", 09, 00 })
   AADD(aCabExcel, {"Série Saída"  , "C", 03, 00 })
   AADD(aCabExcel, {"Cliente Saída", "C", 06, 00 })
   AADD(aCabExcel, {"Ident D2"     , "N", 10, 00 })

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| xGProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","Relação de Produtos com inconsistência em Poder de Terceiros", aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function xGProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aLista)

       aAdd( aCols, {aLista[nContar,02],;
                     aLista[nContar,03],;
                     aLista[nContar,04],;
                     aLista[nContar,05],;
                     aLista[nContar,06],;
                     aLista[nContar,07],;
                     aLista[nContar,08],;
                     aLista[nContar,09],;
                     aLista[nContar,10],;
                     aLista[nContar,11],;
                     aLista[nContar,12],;
                     aLista[nContar,13],;
                     aLista[nContar,14],;
                     aLista[nContar,15],;
                     aLista[nContar,16],;
                     aLista[nContar,17],;
                     " "})

   Next nContar

Return(.T.)

// ########################################################
// Função que mostra os detalhes do regsitro selecionado ##
// ########################################################
Static Function mRegistro()

   Local lChumba  := .F.
   Local cDetalhe := ""
   Local oMemo1

   Local oFont10 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

   Private oDlgDetalhe

   If Len(aLista) == 1
      If Empty(Alltrim(aLista[01,02]))
         MsgAlert("Nenhum registro selecionado para visualizar detalhes.")
         Return(.T.)
      Endif
   Endif

   cDetalhe := "Filial........: " + aLista[oLista:nAt,02] + chr(13) + chr(10) + ;
               "Documento.....: " + aLista[oLista:nAt,03] + chr(13) + chr(10) + ;
               "Série.........: " + aLista[oLista:nAt,04] + chr(13) + chr(10) + ;
               "Fornecedor....: " + aLista[oLista:nAt,05] + chr(13) + chr(10) + ;
               "Loja..........: " + aLista[oLista:nAt,06] + chr(13) + chr(10) + ;
               "TES...........: " + aLista[oLista:nAt,07] + chr(13) + chr(10) + ;
               "Item..........: " + aLista[oLista:nAt,08] + chr(13) + chr(10) + ;
               "Produto.......: " + aLista[oLista:nAt,09] + chr(13) + chr(10) + ;
               "NF Origem.....: " + aLista[oLista:nAt,10] + chr(13) + chr(10) + ;
               "Série Origem..: " + aLista[oLista:nAt,11] + chr(13) + chr(10) + ;
               "Item Origem...: " + aLista[oLista:nAt,12] + chr(13) + chr(10) + ;
               "Ident D1......: " + aLista[oLista:nAt,13] + chr(13) + chr(10) + ;
               "NF Saída......: " + aLista[oLista:nAt,14] + chr(13) + chr(10) + ;
               "Série Saída...: " + aLista[oLista:nAt,15] + chr(13) + chr(10) + ;
               "Cliente Saída.: " + aLista[oLista:nAt,16] + chr(13) + chr(10) + ;
               "Ident D2......: " + aLista[oLista:nAt,17] + chr(13) + chr(10)

   DEFINE MSDIALOG oDlgDetalhe TITLE "Inconsistências Poder de Tereceiros" FROM C(178),C(181) TO C(533),C(718) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgDetalhe

   @ C(032),C(005) GET oMemo1 Var cDetalhe MEMO Size C(259),C(128) FONT oFont10 PIXEL OF oDlgDetalhe When lChumba

   @ C(161),C(227) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDetalhe ACTION( oDlgDetalhe:End() )

   ACTIVATE MSDIALOG oDlgDetalhe CENTERED 

Return(.T.)

// #########################################################
// Função que corrige os IDENT dos registros selecionados ##
// #########################################################
Static Function CorrigeIDent()

   MsgRun("Aguarde! Corrigindo IDENT dos registros ...", "Correção de IDENT", {|| xCorrigeIDent() })

Return(.T.)

// #########################################################
// Função que corrige os IDENT dos registros selecionados ##
// #########################################################
Static Function xCorrigeIDent()

   Local nContar    := 0
   Local lExiste    := .F.
   Local cString    := ""
   
   Private cCaminho := ""

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lExiste := .T.
          Exit
       Endif
   Next nContar       

   If lExiste == .F.
      MsgAlert("Atenção! Nenhum registro foi marcado para ser corrigido. Verifique!")
      Return(.T.)
   Endif   

   If MsgYesNo("Atenção!"                                                              + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Este procedimento irá atualizar o campo D1_IDENTB6 com a informação"   + chr(13) + chr(10)                     + ;
               "do campo D2_IDENTB6."                                                  + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Antes de executar este procedimento, é aconselhável que seja feito um" + chr(13) + chr(10)                     + ;
               "Backup da tabela SD1 (Ítens de Documento de Entrada)."                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Você deseja executar este procedimento?")
   
      // ################################################################################
      // Abre diálogo pata selecionar o caminho onde o arquivo de coreção será gravado ##
      // ################################################################################
      xCaptaCaminho()

      If Empty(Alltrim(cCaminho))
         MsgAlert("Diretório a ser salvo o arquivo de log não selecioando.")
         Return(.T.)
      Endif

      nContar := 0
      cString := ""
   
      For nContar = 1 to Len(aLista)

          If aLista[nContar,01] == .F.
             Loop
          Endif
       
          If Empty(Alltrim(aLista[nContar,17]))
             Loop
          Endif   

          DbSelectArea("SD1")
          DbSetOrder(1)
          If DbSeek(aLista[nContar,02] + aLista[nContar,03] + aLista[nContar,04] + aLista[nContar,05] + aLista[nContar,06] + aLista[nContar,09] + aLista[nContar,08])

             RecLock("SD1",.F.)
             SD1->D1_IDENTB6 := aLista[nContar,17]
             MsUnLock()              

             cString := cString + "Filial: "        + aLista[nContar,02] + " " + ;
                                  "Documento: "     + aLista[nContar,03] + " " + ;
                                  "Série: "         + aLista[nContar,04] + " " + ;
                                  "Fornecedor: "    + aLista[nContar,05] + " " + ;
                                  "Loja: "          + aLista[nContar,06] + " " + ;
                                  "TES: "           + aLista[nContar,07] + " " + ;
                                  "Item: "          + aLista[nContar,08] + " " + ;
                                  "Produto: "       + aLista[nContar,09] + " " + ;
                                  "NF Origem: "     + aLista[nContar,10] + " " + ;
                                  "Série Origem: "  + aLista[nContar,11] + " " + ;
                                  "Item Origem: "   + aLista[nContar,12] + " " + ;
                                  "Ident D1: "      + aLista[nContar,13] + " " + ;
                                  "NF Saída: "      + aLista[nContar,14] + " " + ;
                                  "Série Saída: "   + aLista[nContar,15] + " " + ;
                                  "Cliente Saída: " + aLista[nContar,16] + " " + ;
                                  "Ident D2: "      + aLista[nContar,17] + chr(13) + chr(10) 
          Endif
       
      Next nContar
 
      If Empty(Alltrim(cString))
      Else
  
         cCaminho := cCaminho + "\PODER3.TXT"

         nHdl := fCreate(cCaminho)
         fWrite (nHdl, cString ) 
         fClose(nHdl)
      Endif   

      MsgAlert("Correção realizada com sucesso." + chr(13) + chr(10) + chr(13) + chr(10) + "Log de atualização gerado com  o nome de PODER3.TXT no diretório selecionado.")
      
   Endif   
   
Return(.T.)

// ##########################################################################################################################
// Função que seleciona o diretório para gravação do arquivo sequenial com a gravação dos documentos que foram ataulizados ##
// ##########################################################################################################################
Static Function xCaptaCaminho()

   cCaminho := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
   
Return(.T.)

// ################################################
// Função que abre a janela da pesquisa avançada ##
// ################################################
Static Function PAvancada()

   Local nContar     := 0 
   
   Local cMemo1	     := ""
   Local oMemo1
   
   Private aTransito := {}
   Private aAvancada := {}
   Private cString   := Space(250)
   
   Private cComboBx200
   Private oGet1

   Private oDlgAV

   aAdd( aAvancada, "00 - Selecione"    )   
   aAdd( aAvancada, "01 - Documento"    )
   aAdd( aAvancada, "02 - Fornecedor"   )
   aAdd( aAvancada, "03 - TES"          )
   aAdd( aAvancada, "04 - NF Origem"    )
   aAdd( aAvancada, "05 - Ident D1"     )
   aAdd( aAvancada, "06 - NF Saída   "  )    
   aAdd( aAvancada, "07 - Cliente Saída")
   aAdd( aAvancada, "08 - Ident D2"     )

   // #############################
   // Alimenta o array atransito ##
   // #############################
   For nContar = 1 to Len(aLista) 
       aAdd( aTransito, { aLista[oLista:nAt,01],;
                          aLista[oLista:nAt,02],;
                          aLista[oLista:nAt,03],;
                          aLista[oLista:nAt,04],;
                          aLista[oLista:nAt,05],;
                          aLista[oLista:nAt,06],;
                          aLista[oLista:nAt,07],;
                          aLista[oLista:nAt,08],;
                          aLista[oLista:nAt,09],;
                          aLista[oLista:nAt,10],;
                          aLista[oLista:nAt,11],;
                          aLista[oLista:nAt,12],;
                          aLista[oLista:nAt,13],;
                          aLista[oLista:nAt,14],;
                          aLista[oLista:nAt,15],;
                          aLista[oLista:nAt,16],;
                          aLista[oLista:nAt,17]})
   Next nContar                          

   DEFINE MSDIALOG oDlgAV TITLE "Pesquisa Avançada" FROM C(178),C(181) TO C(328),C(643) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"   Size C(130),C(026) PIXEL NOBORDER OF oDlgAV

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO    Size C(225),C(001) PIXEL OF oDlgAV

   @ C(035),C(005) Say "Campo a ser pesquisado"  Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgAV
   @ C(035),C(083) Say "String a ser pesquisada" Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgAV

   @ C(044),C(005) ComboBox cComboBx200 Items aAvancada Size C(072),C(010) PIXEL OF oDlgAV
   @ C(044),C(085) MsGet    oGet1       Var   cString   Size C(143),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAV

   @ C(058),C(077) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgAV ACTION( BuscaAvanco() )
   @ C(058),C(115) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgAV ACTION( oDlgAV:End() )

   ACTIVATE MSDIALOG oDlgAV CENTERED 
   
Return(.T.)   

// ########################################
// Função que efetua a pesquisa avançada ##
// ########################################
Static Function BuscaAvanco()

   Local nContar := 0

   If Substr(cComboBx200,01,02) == "00"
      MsgAlert("Tipo de campo a ser pesquisado não selecionado. Verifica!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cString))
      MsgAlert("String a ser pesquisada não informada. Verifica!")
      Return(.T.)
   Endif

   aLista := {}
   
   For nContar = 1 to Len(aTransito)

       Do Case 
          Case Substr(cComboBx200,01,01) == "01" 
               If Alltrim(aLista[nContar,03]) <> Alltrim(cString)
                  Loop
               Endif   

          Case Substr(cComboBx200,01,01) == "02" 
               If Alltrim(aLista[nContar,05]) <> Alltrim(cString) 
                  Loop
               Endif   

          Case Substr(cComboBx200,01,01) == "03" 
               If Alltrim(aLista[nContar,07]) <> Alltrim(cString)
                  Loop
               Endif   

          Case Substr(cComboBx200,01,01) == "04" 
               If Alltrim(aLista[nContar,10]) <> Alltrim(cString)
                  Loop
               Endif   

          Case Substr(cComboBx200,01,01) == "05" 
               If Alltrim(aLista[nContar,13]) <> Alltrim(cString)
                  Loop
               Endif   

          Case Substr(cComboBx200,01,01) == "06" 
               If Alltrim(aLista[nContar,14]) <> Alltrim(cString)
                  Loop
               Endif   

          Case Substr(cComboBx200,01,01) == "07" 
               If Alltrim(aLista[nContar,16]) <> Alltrim(cString)
                  Loop
               Endif   

          Case Substr(cComboBx200,01,01) == "08" 
               If Alltrim(aLista[nContar,17]) <> Alltrim(cString)
                  Loop
               Endif   
       EndCase

       aAdd( aLista, { aTransito[nContar,01],;
                       aTransito[nContar,02],;
                       aTransito[nContar,03],;
                       aTransito[nContar,04],;
                       aTransito[nContar,05],;
                       aTransito[nContar,06],;
                       aTransito[nContar,07],;
                       aTransito[nContar,08],;
                       aTransito[nContar,09],;
                       aTransito[nContar,10],;
                       aTransito[nContar,11],;
                       aTransito[nContar,12],;
                       aTransito[nContar,13],;
                       aTransito[nContar,14],;
                       aTransito[nContar,15],;
                       aTransito[nContar,16],;
                       aTransito[nContar,17]})
                       
   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif  

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),; 
                                aLista[oLista:nAt,02]         ,;
                                aLista[oLista:nAt,03]         ,;
                                aLista[oLista:nAt,04]         ,;
                                aLista[oLista:nAt,05]         ,;                                                                
                                aLista[oLista:nAt,06]         ,;
                                aLista[oLista:nAt,07]         ,;
                                aLista[oLista:nAt,08]         ,;
                                aLista[oLista:nAt,09]         ,;
                                aLista[oLista:nAt,10]         ,;                                                                
                                aLista[oLista:nAt,11]         ,;
                                aLista[oLista:nAt,12]         ,;
                                aLista[oLista:nAt,13]         ,;
                                aLista[oLista:nAt,14]         ,;
                                aLista[oLista:nAt,15]         ,;                                                                
                                aLista[oLista:nAt,16]         ,;
                                aLista[oLista:nAt,17]}}

   oDlgAV:End()

Return(.T.)