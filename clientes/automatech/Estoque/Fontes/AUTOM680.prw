#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: AUTOM680.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 27/02/2018                                                                ##
// Objetivo..: Programa que realiza a consulta de saldos de produtos na tabela SB2       ##
// Parâmetros: Sem parâmetros                                                            ##
// ########################################################################################

User Function AUTOM680()

   Local cSql        := ""
   Local lChumba     := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private oDlg

   Private lConsolida   := .F.
   Private lSomente     := .F.
   Private oCheckBox1
   Private oCheckBox2   

   Private aEmpresa     := U_AUTOM539(1, "")      
   Private aFilial      := U_AUTOM539(2, cEmpAnt) 
   Private aArmazem     := {}
   Private aCampos      := {"1 - Descrição", "2 - Código", "3 - Part Number", "4 - NCM"}
   Private aOperacao    := {"1 - Contendo", "2 - Iniciando", "3 - Igual"}
   
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   
   Private cString      := Space(30)

   Private oGet1


   Private oGet1

   Private axBrowse     := {}
   Private oxBrowse
   
   Private aLista       := {}
   Private oLista

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

   Private oFont12cb  := TFont():New( "Courier New",,18,,.t.,,,,.f.,.f. )

   Private cCadastro  := ""

   Private aRotina    := {}

   Private aVoltaFil  := {}

   aAdd( aVoltaFil, { cEmpAnt, cFilAnt } )
   
   // ##############################
   // Carrega o combo de armazens ##
   // ##############################
   If Select("T_ARMAZEM") > 0
      T_ARMAZEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT NNR_CODIGO,"
   cSql += "       NNR_DESCRI "
   cSql += "  FROM NNR" + Alltrim(cEmpAnt) + "0"
   cSql += " WHERE NNR_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ARMAZEM", .T., .T. )

   T_ARMAZEM->( DbGoTop() )

   aArmazem := {}

   aAdd( aArmazem, "## - Todos Armazens" )   

   WHILE !T_ARMAZEM->( EOF() )
      aAdd( aArmazem, T_ARMAZEM->NNR_CODIGO + " - " + Alltrim(T_ARMAZEM->NNR_DESCRI) )
      T_ARMAZEM->( DbSkip() )
   ENDDO
                                                              
   // ########################################################
   // Posiciona na Empresa/Filial logada na entrada da tela ##
   // ########################################################
   Do Case
      Case cEmpAnt == "01"
           cComboBx1 := "01 - AUTOMTECH"
           Do Case
              Case cFilAnt == "01"
                   cComboBx2 := "01 - AUTOMATECH"
              Case cFilAnt == "02"
                   cComboBx2 := "02 - AUTOMATECH CAXI"
              Case cFilAnt == "03"
                   cComboBx2 := "01 - AUTOMATECH PELO"
              Case cFilAnt == "04"
                   cComboBx2 := "01 - AUTOMATECH SUPR"
              Case cFilAnt == "05"
                   cComboBx2 := "01 - AUTOMATECH SAO PAULO"
              Case cFilAnt == "06"
                   cComboBx2 := "01 - AUTOMATECH ESPIRITO SANTO"
              Case cFilAnt == "07"
                   cComboBx2 := "07 - AUTOMATECH SUPR(NOVO)"
           EndCase
      Case cEmpAnt == "02"
           cComboBx1 := "02 - TI AUTOMACAO"
           cComboBx2 := "01 - TI AUTOMACAO"
      Case cEmpAnt == "03"
           cComboBx1 := "03 - ATECH"
           cComboBx2 := "01 - ATECH"
      Case cEmpAnt == "04"         
           cComboBx1 := "04 - ATECHPEL"
           cComboBx2 := "01 - ATECHPEL"                              
   EndCase         

   // ###################################
   // Desenha a tela para visualização ##
   // ###################################
   DEFINE MSDIALOG oDlg TITLE "Saldo em Estoque" FROM C(178),C(181) TO C(627),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(023) PIXEL NOBORDER OF oDlg
   @ C(211),C(005) Jpeg FILE "br_branco.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(069) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlg

   @ C(031),C(005) Say "Empresa"               Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(051) Say "Filial"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(120) Say "Armazém"               Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(170) Say "String a Pesquisar"    Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(264) Say "Pesquisar por"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(314) Say "Operação"              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(052),C(005) Say "Resultado da Pesquisa" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(211),C(018) Say "Produtos sem saldo"    Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(082) Say "Produtos com saldo"    Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(040),C(005) ComboBox cComboBx1  Items aEmpresa   Size C(041),C(010) PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(040),C(051) ComboBox cComboBx2  Items aFilial    Size C(064),C(010) PIXEL OF oDlg
   @ C(040),C(120) ComboBox cComboBx3  Items aArmazem   Size C(045),C(010) PIXEL OF oDlg
   @ C(039),C(261) ComboBox cComboBx4  Items aCampos    Size C(046),C(010) PIXEL OF oDlg
   @ C(039),C(314) ComboBox cComboBx5  Items aOperacao  Size C(036),C(010) PIXEL OF oDlg
   @ C(040),C(170) MsGet    oGet1      Var   cString    Size C(084),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   
   @ C(038),C(353) Button "Pesquisar" Size C(035),C(011) PIXEL OF oDlg ACTION( xbuscapro() )

   @ C(052),C(120) CheckBox oCheckBox2 Var lSomente   Prompt "Pesquisar somente produtos com saldo" Size C(102),C(008) PIXEL OF oDlg

   @ C(210),C(314) Button "Excel"    Size C(037),C(012) PIXEL OF oDlg ACTION( kSaidaExcel() )  When !Empty(Alltrim(axBrowse[oxBrowse:nAt,02]))
   @ C(210),C(353) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
 
   // ############################################
   // Desenha o Browse dos Produtos Pesquisados ##
   // ############################################
   aAdd( axBrowse, { "1", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )

   oxBrowse := TCBrowse():New( 075 , 005, 495, 188,,{"LG"                     ,; // 01
                                                     "Código"                 ,; // 02
                                                     "Descrição dos Produtos" ,; // 03
                                                     "Und"                    ,; // 04
                                                     "Qtd. Disponível"        ,; // 05
                                                     "Sld. Atual"             ,; // 06
                                                     "Qtd. Pedido de Venda"   ,; // 07
                                                     "Qtd. Empenhada"         ,; // 08
                                                     "Qtd. Prev.Entrada"      ,; // 09
                                                     "Qtd. Emp. SA"           ,; // 10
                                                     "Qtd. Reserva"           ,; // 11
                                                     "Qtd. Ter.Ns.Pd."        ,; // 12
                                                     "Qtd. Ns.Pd.Ter."        ,; // 13
                                                     "Sld. Poder 3"           ,; // 14
                                                     "Qtd. Emp. NF."          ,; // 15
                                                     "Qtd. A Endereçar"       ,; // 16
                                                     "Qtd. Emp. Prj."         ,; // 17
                                                     "Qtd. Emp. Prevista"     ,; // 18
                                                     "Qtd. Rolos"        }    ,; // 19
                                                   {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oxBrowse:SetArray( axBrowse )
   
   oxBrowse:bLine := {||{ If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "1", oBranco  ,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "2", oVerde   ,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "3", oPink    ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "4", oAmarelo ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "7", oPreto   ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "8", oVermelho,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                          axBrowse[oxBrowse:nAt,02]               ,;
                          axBrowse[oxBrowse:nAt,03]               ,;
                          axBrowse[oxBrowse:nAt,04]               ,;                         
                          axBrowse[oxBrowse:nAt,05]               ,;                         
                          axBrowse[oxBrowse:nAt,06]               ,;                         
                          axBrowse[oxBrowse:nAt,07]               ,;                         
                          axBrowse[oxBrowse:nAt,08]               ,;                         
                          axBrowse[oxBrowse:nAt,09]               ,;                         
                          axBrowse[oxBrowse:nAt,10]               ,;                         
                          axBrowse[oxBrowse:nAt,11]               ,;                         
                          axBrowse[oxBrowse:nAt,12]               ,;                         
                          axBrowse[oxBrowse:nAt,13]               ,;                         
                          axBrowse[oxBrowse:nAt,14]               ,;                         
                          axBrowse[oxBrowse:nAt,15]               ,;                         
                          axBrowse[oxBrowse:nAt,16]               ,;                         
                          axBrowse[oxBrowse:nAt,17]               ,;                         
                          axBrowse[oxBrowse:nAt,18]               ,;                         
                          axBrowse[oxBrowse:nAt,19]               }}

   oxBrowse:bLDblClick := {|| BuscaSB2() }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo()

   aFilial := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(040),C(051) ComboBox cComboBx2  Items aFilial   Size C(064),C(010) PIXEL OF oDlg

   // ##############################
   // Carrega o combo de armazens ##
   // ##############################
   If Select("T_ARMAZEM") > 0
      T_ARMAZEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT NNR_CODIGO,"
   cSql += "       NNR_DESCRI "
   cSql += "  FROM NNR" + Substr(cComboBx1,01,02)+ "0"
   cSql += " WHERE NNR_FILIAL = '" + Substr(cComboBx2,01,02) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ARMAZEM", .T., .T. )

   T_ARMAZEM->( DbGoTop() )

   aArmazem := {}

   aAdd( aArmazem, "## - Todos Armazens" )   

   WHILE !T_ARMAZEM->( EOF() )
      aAdd( aArmazem, T_ARMAZEM->NNR_CODIGO + " - " + Alltrim(T_ARMAZEM->NNR_DESCRI) )
      T_ARMAZEM->( DbSkip() )
   ENDDO

   @ C(040),C(120) ComboBox cComboBx3  Items aArmazem  Size C(045),C(010) PIXEL OF oDlg

Return(.T.)

// #####################################################################
// Função que pesquisa o produto a medida que o usuário vai digitando ##
// #####################################################################
Static Function xbuscapro()

   MsgRun("Aguarde! Pesquisando produtos conforme parâmetros ...", "Pesquisa de Produtos",{|| kbuscapro() })

Return(.T.)

// #####################################################################
// Função que pesquisa o produto a medida que o usuário vai digitando ##
// #####################################################################
Static Function kbuscapro()

   Local cSql   := ""
   Local nSaldo := 0
   Local nCor   := ""
   Local nDias  := 0

   Local cGramat := ''
   Local cMetr	 :=	''
   Local cEtqRol :=	''
   Local cRolos	 :=	''
   Local nMetr   := 0
   Local nEtqRol := 0
   Local nRolos  := 0

   If Empty(Alltrim(cString))
      MsgAlert("String a ser pesquisada não informada. Verifique!")
      Return(.T.)
   Endif   

   If Substr(cComboBx3,01,02) == "##"
      MsgAlert("Armazém a ser pesquisado não selecionado. Verifique!")
      Return(.T.)
   Endif   

   aArea := GetArea()
   
   axBrowse := {}

   // ###########################################
   // Carrega o Array com os dados pesquisados ##
   // ###########################################
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""

   cSql := "SELECT SB1.B1_COD     ,"
   cSql += "       SB1.B1_DESC    ,"
   cSql += "       SB1.B1_DAUX    ,"
   cSql += "       SB1.B1_UM      ,"
   cSql += "       SB1.B1_QROLOS  ,"
   cSql += "      (SELECT B2_QFIM     FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QFIM   ,"
   cSql += "      (SELECT B2_QATU     FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QQTU   ,"
   cSql += "      (SELECT B2_QPEDVEN  FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QPEDVEN,"
   cSql += "      (SELECT B2_QEMP     FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QEMP   ,"
   cSql += "      (SELECT B2_SALPEDI  FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_SALPEDI,"
   cSql += "      (SELECT B2_QEMPSA   FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QEMPSA ,"
   cSql += "      (SELECT B2_RESERVA  FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_RESERVA,"
   cSql += "      (SELECT B2_QTNP     FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QTNP   ,"
   cSql += "      (SELECT B2_QNPT     FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QNPT   ,"
   cSql += "      (SELECT B2_QTER     FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QTER   ,"
   cSql += "      (SELECT B2_QEMPN    FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QEMPN  ,"
   cSql += "      (SELECT B2_QACLASS  FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QACLASS,"
   cSql += "      (SELECT B2_QEMPPRJ  FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QEMPPRJ,"
   cSql += "      (SELECT B2_QEMPPRE  FROM SB2030 WHERE B2_FILIAL = '01' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '" + Substr(cComboBx3,01,02) + "' AND D_E_L_E_T_ = '') AS B2_QEMPPRE "
   cSql += "  FROM SB1" + Substr(cComboBx1,01,02) + "0 SB1"
   cSql += " WHERE SB1.B1_MSBLQL <> '1'"
   cSql += "   AND SB1.D_E_L_E_T_ = '' "

   Do Case

      // #########################
      // Pesquisa por Descrição ##
      // #########################
      Case Substr(cComboBx4,01,01) = "1"
           Do Case
              Case Substr(cComboBx5,01,01) == "3" // Igual
                   cSql += " AND SB1.B1_DESC = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "2" // Iniciando
                   cSql += " AND SB1.B1_DESC  LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "1" // Contendo
                   cSql += " AND SB1.B1_DESC  LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   
  
      // ######################
      // Pesquisa por Código ##
      // ######################
      Case Substr(cComboBx4,01,01) = "2"
           Do Case
              Case Substr(cComboBx5,01,01) == "3" // Igual
                   cSql += " AND SB1.B1_COD = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "2" // Iniciando
                   cSql += " AND SB1.B1_COD LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "1" // Contendo
                   cSql += " AND SB1.B1_COD LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

   EndCase

   cSql += " ORDER BY SB1.B1_DESC, SB1.B1_DAUX"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   axBrowse := {}

   T_PRODUTO->( DbGoTop() )

   WHILE !T_PRODUTO->( EOF() )

      // #################################
      // Carrega a legenda para display ##
      // #################################
      If (T_PRODUTO->B2_QFIM    + T_PRODUTO->B2_QQTU    + T_PRODUTO->B2_QPEDVEN + T_PRODUTO->B2_QEMP    +;
          T_PRODUTO->B2_SALPEDI + T_PRODUTO->B2_QEMPSA  + T_PRODUTO->B2_RESERVA + T_PRODUTO->B2_QTNP    +;
          T_PRODUTO->B2_QNPT    + T_PRODUTO->B2_QTER    + T_PRODUTO->B2_QEMPN   + T_PRODUTO->B2_QACLASS +;
          T_PRODUTO->B2_QEMPPRJ + T_PRODUTO->B2_QEMPPRE) == 0 
         kLegenda := "1"
      Else
         kLegenda := "2"
      Endif   

      // ###########################################################      
      // Considera somente produtos com saldos conforme parâmetro ##
      // ###########################################################
      If lSomente == .F.
      Else
         If kLegenda == "1"
            T_PRODUTO->( DbSkip() )            
            Loop
         Endif
      Endif      

      // #######################################################
      // Carrega a descrição completa do produto para display ##
      // #######################################################
      kDescricao := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)

      // ##########################
      // Carrega o Array axBrowse ##
      // ##########################
      aAdd( axBrowse, {kLegenda              ,; // 01
                       T_PRODUTO->B1_COD     ,; // 02
                       kDescricao            ,; // 03
                       T_PRODUTO->B1_UM      ,; // 04
                       T_PRODUTO->B2_QFIM    ,; // 05
                       T_PRODUTO->B2_QQTU    ,; // 06
                       T_PRODUTO->B2_QPEDVEN ,; // 07
                       T_PRODUTO->B2_QEMP    ,; // 08
                       T_PRODUTO->B2_SALPEDI ,; // 09
                       T_PRODUTO->B2_QEMPSA  ,; // 10
                       T_PRODUTO->B2_RESERVA ,; // 11
                       T_PRODUTO->B2_QTNP    ,; // 12
                       T_PRODUTO->B2_QNPT    ,; // 13
                       T_PRODUTO->B2_QTER    ,; // 14
                       T_PRODUTO->B2_QEMPN   ,; // 15
                       T_PRODUTO->B2_QACLASS ,; // 16
                       T_PRODUTO->B2_QEMPPRJ ,; // 17
                       T_PRODUTO->B2_QEMPPRE ,; // 18
                       T_PRODUTO->B1_QROLOS  }) // 20

      T_PRODUTO->( DbSkip() )

   ENDDO

   If Len(axBrowse) == 0
      aAdd( axBrowse, { "1", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
   Endif

   oxBrowse:SetArray( axBrowse )

   oxBrowse:bLine := {||{ If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "1", oBranco  ,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "2", oVerde   ,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "3", oPink    ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "4", oAmarelo ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "7", oPreto   ,;                         
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "8", oVermelho,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                          axBrowse[oxBrowse:nAt,02]               ,;
                          axBrowse[oxBrowse:nAt,03]               ,;
                          axBrowse[oxBrowse:nAt,04]               ,;                         
                          axBrowse[oxBrowse:nAt,05]               ,;                         
                          axBrowse[oxBrowse:nAt,06]               ,;                         
                          axBrowse[oxBrowse:nAt,07]               ,;                         
                          axBrowse[oxBrowse:nAt,08]               ,;                         
                          axBrowse[oxBrowse:nAt,09]               ,;                         
                          axBrowse[oxBrowse:nAt,10]               ,;                         
                          axBrowse[oxBrowse:nAt,11]               ,;                         
                          axBrowse[oxBrowse:nAt,12]               ,;                         
                          axBrowse[oxBrowse:nAt,13]               ,;                         
                          axBrowse[oxBrowse:nAt,14]               ,;                         
                          axBrowse[oxBrowse:nAt,15]               ,;                         
                          axBrowse[oxBrowse:nAt,16]               ,;                         
                          axBrowse[oxBrowse:nAt,17]               ,;                         
                          axBrowse[oxBrowse:nAt,18]               ,;                         
                          axBrowse[oxBrowse:nAt,19]               }}

   RestArea( aArea )

Return(.T.)

// #######################################
// Função que gera o resultado em Excel ##
// #######################################
Static Function kSaidaExcel()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   AADD(aCabExcel, {"Código"                 , "C", 30, 00 })
   AADD(aCabExcel, {"Descrição dos Produtos" , "C", 60, 00 })
   AADD(aCabExcel, {"Und"                    , "C", 02, 00 })
   AADD(aCabExcel, {"Qtd. Disponível"        , "N", 10, 02 })
   AADD(aCabExcel, {"Sld. Atual"             , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Pedido de Venda"   , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Empenhada"         , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Prev.Entrada"      , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Emp. SA"           , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Reserva"           , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Ter.Ns.Pd."        , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Ns.Pd.Ter."        , "N", 10, 02 })
   AADD(aCabExcel, {"Sld. Poder 3"           , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Emp. NF."          , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. A Endereçar"       , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Emp. Prj."         , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Emp. Prevista"     , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd. Rolos"             , "N", 10, 00 })

   cTitulo := "RELAÇÃO DE SALDOS DE PRODUTOS DA EMPRESA " + Alltrim(cCombobx1) + " DA FILIAL " + Alltrim(cComboBx2) + " DO ARMAZÉM: " + Substr(cComboBx3,01,02)

   MsgRun("Aguarde! Preparando Dados ..."     , "Selecionando os Registros", {|| kkSaidaExcel(aCabExcel, @aItensExcel)})
   MsgRun("Aguarde! Gerando Arquivo Excel ...", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS", cTitulo, aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kkSaidaExcel(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(axBrowse)

       aAdd( aCols, {axBrowse[nContar,02] ,;       
                     axBrowse[nContar,03] ,;       
                     axBrowse[nContar,04] ,;       
                     axBrowse[nContar,05] ,;       
                     axBrowse[nContar,06] ,;       
                     axBrowse[nContar,07] ,;       
                     axBrowse[nContar,08] ,;       
                     axBrowse[nContar,09] ,;       
                     axBrowse[nContar,10] ,;       
                     axBrowse[nContar,11] ,;       
                     axBrowse[nContar,12] ,;       
                     axBrowse[nContar,13] ,;       
                     axBrowse[nContar,14] ,;       
                     axBrowse[nContar,15] ,;       
                     axBrowse[nContar,16] ,;       
                     axBrowse[nContar,17] ,;       
                     axBrowse[nContar,18] ,;       
                     axBrowse[nContar,19] ,;       
                     ""                 })                                                                                                                                                                                                                                                                                                                                                                                                                                           
   Next nContar

Return(.T.)