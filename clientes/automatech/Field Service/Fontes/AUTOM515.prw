#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM515.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 22/11/2016                                                               ##
// Objetivo..: Consulta Movimentações de Produtos                                       ##
// #######################################################################################

User Function AUTOM515()

   Local cSql          := ""

   Local cMemo1	       := ""
   Local oMemo1

   Private aTipoMov	   := {"T - Todas", "C - Compras", "V - Vendas", "A - Ajuste de Entradas", "D - Ajustes de Saídas"}
   Private cComboBx1

   Private cFilialDe   := "  "
   Private cFilialAte  := "ZZ"
   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private cGrupoDe	   := "    "
   Private cGrupoAte   := "ZZZZ"

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private aBrowse := {}
   
   // ######################
   // Declara as Legendas ##
   // ######################
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

   DEFINE MSDIALOG oDlg TITLE "Consulta Movimentações de Produtos" FROM C(183),C(002) TO C(632),C(1000) PIXEL
   
   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg
   @ C(212),C(005) Jpeg FILE "br_verde"    Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(087) Jpeg FILE "br_vermelho" Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(170) Jpeg FILE "br_amarelo"  Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(240) Jpeg FILE "br_laranja"  Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Filial De"              Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(031) Say "Filial Até"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(057) Say "Data Inicial"           Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(099) Say "Data Final"             Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(142) Say "Grp Inicial"            Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(174) Say "Grp Final"              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(206) Say "Tipo"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(018) Say "Lançamentos de Compras" Size C(063),C(007) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(103) Say "Lançamentos de Vendas"  Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(186) Say "Ajustes de Entradas"    Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(256) Say "Ajustes de Saídas"      Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) MsGet    oGet1     Var   cFilialDe   Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(031) MsGet    oGet2     Var   cFilialAte  Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(057) MsGet    oGet3     Var   cDtaInicial Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(099) MsGet    oGet4     Var   cDtaFinal   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(142) MsGet    oGet5     Var   cGrupoDe    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(174) MsGet    oGet6     Var   cGrupoAte   Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(206) ComboBox cComboBx1 Items aTipoMov    Size C(081),C(010)                              PIXEL OF oDlg

   @ C(043),C(292) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PsqMovimentos() )
   @ C(043),C(336) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'Lg'                       ,; // 01
                                                    'Filial'                   ,; // 02
                                                    'Arm.'                     ,; // 03
                                                    'Doc.'                     ,; // 04
                                                    'Série'                    ,; // 05
                                                    'Dta Emissão'              ,; // 06
                                                    'Dta Digitação'            ,; // 07
                                                    'Cliente'                  ,; // 08
                                                    'Loja'                     ,; // 09
                                                    'Descrição dos Clientes'   ,; // 10
                                                    'Produto'                  ,; // 11
                                                    'Descrição dos Produtos'   ,; // 12
                                                    'Grupo'                    ,; // 13
                                                    'Quantidade'             } ,; // 14
                                       {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
   
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
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
                          aBrowse[oBrowse:nAt,12]               ,;
                          aBrowse[oBrowse:nAt,13]               ,;
                          aBrowse[oBrowse:nAt,14]               }}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###################################################################
// Função que realiza a pesquisa dos movimentos conforme parâmetros ##
// ###################################################################
Static Function PsqMovimentos()

   MsgRun("Favor Aguarde! Pesquisando Movimentos ...", "Pesquisando Movimentos ...",{|| xPsqMovimentos() })

Return(.T.)

// ###################################################################
// Função que realiza a pesquisa dos movimentos conforme parâmetros ##
// ###################################################################
Static Function xPsqMovimentos()

   Local cSql := ""

   // ################################################
   // Gera consistência dos dados antes da pesquisa ##
   // ################################################
   If Empty(Alltrim(cFilialDe)) .And. Empty(Alltrim(cFilialAte))
      cFilialDe  := "  "
      cFilialAte := "ZZ"
   Endif
   
   If cDtaInicial == CTOD("  /  /    ")
      MsgAlert("Data inicial de pesquisa não informada.")
      Return(.T.)
   Endif
      
   If cDtaFinal == CTOD("  /  /    ")
      MsgAlert("Data final de pesquisa não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cGrupoDe)) .And. Empty(Alltrim(cGrupoAte))
      cGrupoDe  := "    "
      cGrupoAte := "ZZZZ"
   Endif

   aBrowse := {}

   // ##########################################
   // Pesquisa as compras conforme parâmetros ##
   // ##########################################
   If Substr(cComboBx1,01,01) == "T" .Or. Substr(cComboBx1,01,01) == "C"

      If Select("T_COMPRAS") > 0
         T_COMPRAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SD1.D1_FILIAL ,"
      cSql += "       SD1.D1_LOCAL  ,"
   	  cSql += "       SD1.D1_DOC    ,"
   	  cSql += "       SD1.D1_SERIE  ,"
   	  cSql += "       SD1.D1_EMISSAO,"
   	  cSql += "       SD1.D1_DTDIGIT,"
   	  cSql += "       SD1.D1_FORNECE,"
   	  cSql += "       SD1.D1_LOJA   ,"
   	  cSql += "       SA2.A2_NOME   ,"
   	  cSql += "       SD1.D1_COD    ,"
   	  cSql += "       SB1.B1_DESC   ,"
   	  cSql += "       SB1.B1_GRUPO  ,"
   	  cSql += "       SD1.D1_QUANT   "
      cSql += "  FROM " + RetSqlName("SD1") + " SD1, "
      cSql += "       " + RetSqlName("SA2") + " SA2, "
 	  cSql += "       " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE SD1.D1_FILIAL  >= '" + Alltrim(cFilialDe)  + "'"
      cSql += "   AND SD1.D1_FILIAL  <= '" + Alltrim(cFilialAte) + "'"
      cSql += "   AND SD1.D1_DTDIGIT >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "   AND SD1.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
      cSql += "   AND SB1.B1_GRUPO   >= '" +  Alltrim(cGrupoDe)  + "'"
      cSql += "   AND SB1.B1_GRUPO   <= '" +  Alltrim(cGrupoAte) + "'"
      cSql += "   AND SD1.D_E_L_E_T_  = ''"
      cSql += "   AND SA2.A2_COD      = SD1.D1_FORNECE"
      cSql += "   AND SA2.A2_LOJA     = SD1.D1_LOJA   "
      cSql += "   AND SA2.D_E_L_E_T_  = ''            "
      cSql += "   AND SB1.B1_COD      = SD1.D1_COD    "
      cSql += "   AND SB1.D_E_L_E_T_  = ''            "
      cSql += " ORDER BY SD1.D1_FILIAL, SD1.D1_DTDIGIT"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPRAS", .T., .T. )

      T_COMPRAS->( DbGoTop() )

      WHILE !T_COMPRAS->( EOF() )

         aAdd( aBrowse, {"1"     ,;
   	                     T_COMPRAS->D1_FILIAL       ,;
                         T_COMPRAS->D1_LOCAL        ,;
   	                     T_COMPRAS->D1_DOC          ,;
   	                     T_COMPRAS->D1_SERIE        ,;
   	                     T_COMPRAS->D1_EMISSAO      ,;
   	                     T_COMPRAS->D1_DTDIGIT      ,;
   	                     T_COMPRAS->D1_FORNECE      ,;
   	                     T_COMPRAS->D1_LOJA         ,;
   	                     T_COMPRAS->A2_NOME         ,;
   	                     T_COMPRAS->D1_COD          ,;
   	                     T_COMPRAS->B1_DESC         ,;
   	                     T_COMPRAS->B1_GRUPO        ,;
   	                     Str(T_COMPRAS->D1_QUANT,10)})
                              
         T_COMPRAS->( DbSkip() )
         
      ENDDO   

      // ###########################
      // Abre uma Linha em Branco ##
      // ###########################
      If Len(aBrowse) == 0
      Else
         aAdd( aBrowse, {"" ,;
   	                     "" ,;
                         "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" })
   	   Endif                  
      
   Endif

   // #########################################
   // Pesquisa as vendas conforme parâmetros ##
   // #########################################
   If Substr(cComboBx1,01,01) == "T" .Or. Substr(cComboBx1,01,01) == "V"

      If Select("T_VENDAS") > 0
         T_VENDAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SD2.D2_FILIAL ,"
      cSql += "       SD2.D2_LOCAL  ,"
   	  cSql += "       SD2.D2_DOC    ,"
   	  cSql += "       SD2.D2_SERIE  ,"
   	  cSql += "       SD2.D2_EMISSAO,"
   	  cSql += "       SD2.D2_EMISSAO,"
   	  cSql += "       SD2.D2_CLIENTE,"
   	  cSql += "       SD2.D2_LOJA   ,"
   	  cSql += "       SA1.A1_NOME   ,"
   	  cSql += "       SD2.D2_COD    ,"
   	  cSql += "       SB1.B1_DESC   ,"
   	  cSql += "       SB1.B1_GRUPO  ,"
   	  cSql += "       SD2.D2_QUANT   "
      cSql += "  FROM " + RetSqlName("SD2") + " SD2, "
      cSql += "       " + RetSqlName("SA1") + " SA1, "
 	  cSql += "       " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE SD2.D2_FILIAL  >= '" + Alltrim(cFilialDe)  + "'"
      cSql += "   AND SD2.D2_FILIAL  <= '" + Alltrim(cFilialAte) + "'"
      cSql += "   AND SD2.D2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "   AND SD2.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
      cSql += "   AND SB1.B1_GRUPO   >= '" +  Alltrim(cGrupoDe)  + "'"
      cSql += "   AND SB1.B1_GRUPO   <= '" +  Alltrim(cGrupoAte) + "'"
      cSql += "   AND SD2.D_E_L_E_T_  = ''"
      cSql += "   AND SA1.A1_COD      = SD2.D2_CLIENTE"
      cSql += "   AND SA1.A1_LOJA     = SD2.D2_LOJA   "
      cSql += "   AND SA1.D_E_L_E_T_  = ''            "
      cSql += "   AND SB1.B1_COD      = SD2.D2_COD    "
      cSql += "   AND SB1.D_E_L_E_T_  = ''            "
      cSql += " ORDER BY SD2.D2_FILIAL, SD2.D2_EMISSAO"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDAS", .T., .T. )

      T_VENDAS->( DbGoTop() )

      WHILE !T_VENDAS->( EOF() )

         aAdd( aBrowse, {"9"                       ,;
   	                     T_VENDAS->D2_FILIAL       ,;
                         T_VENDAS->D2_LOCAL        ,;
   	                     T_VENDAS->D2_DOC          ,;
   	                     T_VENDAS->D2_SERIE        ,;
   	                     T_VENDAS->D2_EMISSAO      ,;
   	                     T_VENDAS->D2_EMISSAO      ,;
   	                     T_VENDAS->D2_CLIENTE      ,;
   	                     T_VENDAS->D2_LOJA         ,;
   	                     T_VENDAS->A1_NOME         ,;
   	                     T_VENDAS->D2_COD          ,;
   	                     T_VENDAS->B1_DESC         ,;
   	                     T_VENDAS->B1_GRUPO        ,;
   	                     Str(T_VENDAS->D2_QUANT,10)})
                              
         T_VENDAS->( DbSkip() )
         
      ENDDO   

      // ###########################
      // Abre uma Linha em Branco ##
      // ###########################
      If Len(aBrowse) == 0
      Else
         aAdd( aBrowse, {"" ,;
   	                     "" ,;
                         "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" })
   	   Endif                  
      
   Endif
      
   // #####################################################
   // Pesquisa os ajustes de entrada conforme parâmetros ##
   // #####################################################
   If Substr(cComboBx1,01,01) == "T" .Or. Substr(cComboBx1,01,01) == "A"

      If Select("T_ENTRADAS") > 0
         T_ENTRADAS->( dbCloseArea() )
      EndIf

      cSql := "SELECT SD3.D3_FILIAL ,"
      cSql += "       SD3.D3_LOCAL  ,"
 	  cSql += "       SD3.D3_DOC    ,"
 	  cSql += "       SD3.D3_TM     ,"
 	  cSql += "       SD3.D3_EMISSAO,"
 	  cSql += "       SD3.D3_EMISSAO,"
	  cSql += "       '' AS CODIGO  ,"
	  cSql += "       '' AS LOJA    ,"
   	  cSql += "       'AJUSTE DE ENTRADA' AS NOME,"
	  cSql += "       SD3.D3_COD    ,"
	  cSql += "       SB1.B1_DESC   ,"
	  cSql += "       SB1.B1_GRUPO  ,"
	  cSql += "       SD3.D3_QUANT   "
      cSql += "  FROM " + RetSqlName("SD3") + " SD3, "
      cSql += "	      " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE SD3.D3_FILIAL  >= '" + Alltrim(cFilialDe)  + "'"
      cSql += "   AND SD3.D3_FILIAL  <= '" + Alltrim(cFilialAte) + "'"
      cSql += "   AND SD3.D3_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "   AND SD3.D3_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
      cSql += "   AND SD3.D3_TM IN ('200', '300', '400', '410')"
      cSql += "   AND SB1.B1_COD      = SD3.D3_COD    "
      cSql += "   AND SB1.D_E_L_E_T_  = ''            "
      cSql += "   AND SB1.B1_GRUPO   >= '" +  Alltrim(cGrupoDe)  + "'"
      cSql += "   AND SB1.B1_GRUPO   <= '" +  Alltrim(cGrupoAte) + "'"
      cSql += "   AND SD3.D_E_L_E_T_  = ''"
      cSql += " ORDER BY SD3.D3_FILIAL, SD3.D3_EMISSAO   

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENTRADAS", .T., .T. )

      T_ENTRADAS->( DbGoTop() )

      WHILE !T_ENTRADAS->( EOF() )

         aAdd( aBrowse, {"3"                         ,;
   	                     T_ENTRADAS->D3_FILIAL       ,;
                         T_ENTRADAS->D3_LOCAL        ,;
   	                     T_ENTRADAS->D3_DOC          ,;
   	                     T_ENTRADAS->D3_TM           ,;
   	                     T_ENTRADAS->D3_EMISSAO      ,;
   	                     T_ENTRADAS->D3_EMISSAO      ,;
   	                     T_ENTRADAS->CODIGO          ,;
   	                     T_ENTRADAS->LOJA            ,;
   	                     T_ENTRADAS->NOME            ,;
   	                     T_ENTRADAS->D3_COD          ,;
   	                     T_ENTRADAS->B1_DESC         ,;
   	                     T_ENTRADAS->B1_GRUPO        ,;
   	                     Str(T_ENTRADAS->D3_QUANT,10)})
                              
         T_ENTRADAS->( DbSkip() )

      ENDDO   

      // ###########################
      // Abre uma Linha em Branco ##
      // ###########################
      If Len(aBrowse) == 0
      Else
         aAdd( aBrowse, {"" ,;
   	                     "" ,;
                         "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" })
   	   Endif                  
      
   Endif

   // ####################################################
   // Pesquisa os ajustes de saídas conforme parâmetros ##
   // ####################################################
   If Substr(cComboBx1,01,01) == "T" .Or. Substr(cComboBx1,01,01) == "D"

      If Select("T_SAIDAS") > 0
         T_SAIDAS->( dbCloseArea() )
      EndIf

      cSql := "SELECT SD3.D3_FILIAL ,"
      cSql += "       SD3.D3_LOCAL  ,"
 	  cSql += "       SD3.D3_DOC    ,"
 	  cSql += "       SD3.D3_TM     ,"
 	  cSql += "       SD3.D3_EMISSAO,"
 	  cSql += "       SD3.D3_EMISSAO,"
	  cSql += "       '' AS CODIGO  ,"
	  cSql += "       '' AS LOJA    ,"
   	  cSql += "       'AJUSTE DE SAIDAS' AS NOME,"
	  cSql += "       SD3.D3_COD    ,"
	  cSql += "       SB1.B1_DESC   ,"
	  cSql += "       SB1.B1_GRUPO  ,"
	  cSql += "       SD3.D3_QUANT   "
      cSql += "  FROM " + RetSqlName("SD3") + " SD3, "
      cSql += "	      " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE SD3.D3_FILIAL  >= '" + Alltrim(cFilialDe)  + "'"
      cSql += "   AND SD3.D3_FILIAL  <= '" + Alltrim(cFilialAte) + "'"
      cSql += "   AND SD3.D3_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "   AND SD3.D3_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
      cSql += "   AND SD3.D3_TM IN ('600', '700', '800', '998')"
      cSql += "   AND SB1.B1_COD      = SD3.D3_COD    "
      cSql += "   AND SB1.D_E_L_E_T_  = ''            "
      cSql += "   AND SB1.B1_GRUPO   >= '" +  Alltrim(cGrupoDe)  + "'"
      cSql += "   AND SB1.B1_GRUPO   <= '" +  Alltrim(cGrupoAte) + "'"
      cSql += "   AND SD3.D_E_L_E_T_  = ''"
      cSql += " ORDER BY SD3.D3_FILIAL, SD3.D3_EMISSAO   

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SAIDAS", .T., .T. )

      T_SAIDAS->( DbGoTop() )

      WHILE !T_SAIDAS->( EOF() )

         aAdd( aBrowse, {"6"                       ,;
   	                     T_SAIDAS->D3_FILIAL       ,;
                         T_SAIDAS->D3_LOCAL        ,;
   	                     T_SAIDAS->D3_DOC          ,;
   	                     T_SAIDAS->D3_TM           ,;
   	                     T_SAIDAS->D3_EMISSAO      ,;
   	                     T_SAIDAS->D3_EMISSAO      ,;
   	                     T_SAIDAS->CODIGO          ,;
   	                     T_SAIDAS->LOJA            ,;
   	                     T_SAIDAS->NOME            ,;
   	                     T_SAIDAS->D3_COD          ,;
   	                     T_SAIDAS->B1_DESC         ,;
   	                     T_SAIDAS->B1_GRUPO        ,;
   	                     Str(T_SAIDAS->D3_QUANT,10)})
                              
         T_SAIDAS->( DbSkip() )

      ENDDO   

      // ###########################
      // Abre uma Linha em Branco ##
      // ###########################
      If Len(aBrowse) == 0
      Else
         aAdd( aBrowse, {"" ,;
   	                     "" ,;
                         "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" ,;
   	                     "" })
   	   Endif                  
      
   Endif

   If Len(aBrowse) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
   
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
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
                          aBrowse[oBrowse:nAt,12]               ,;                                                   
                          aBrowse[oBrowse:nAt,13]               ,;                                                   
                          aBrowse[oBrowse:nAt,14]               }}

Return(.T.)