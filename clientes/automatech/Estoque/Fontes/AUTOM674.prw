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
// Referencia: AUTOM674.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 07/02/2018                                                                ##
// Objetivo..: Nova consulta de saldos de produtos                                       ##
// Parâmetros: Sem parâmetros                                                            ##
// ########################################################################################

User Function AUTOM674()

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

   Private nDispo   := 0
   Private nSatual  := 0
   Private nPvenda  := 0
   Private nEmpsa   := 0
   Private nNter    := 0
   Private nEmnf    := 0
   Private nEmpj    := 0
   Private nEtiq    := 0
   Private nEmpen   := 0
   Private nQentr   := 0
   Private nReserva := 0
   Private nCter    := 0
   Private nSpod3   := 0
   Private nEnder   := 0
   Private nEmpp    := 0
   Private nMlin    := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10                      
   Private oGet11                     
   Private oGet12                     
   Private oGet13                     
   Private oGet14                     
   Private oGet15                     
   Private oGet16                                       
   Private oGet17                                       

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
   @ C(152),C(005) Jpeg FILE "br_branco.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(152),C(069) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlg
   @ C(062),C(261) GET oMemo2 Var cMemo2 MEMO Size C(126),C(001) PIXEL OF oDlg

   @ C(031),C(005) Say "Empresa"               Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(051) Say "Filial"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(120) Say "Armazém"               Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(170) Say "String a Pesquisar"    Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(264) Say "Pesquisar por"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(314) Say "Operação"              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(052),C(005) Say "Resultado da Pesquisa" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(052),C(261) Say "TOTAL"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg Font oFont12cb 
   @ C(068),C(261) Say "Qtd Disponível"        Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(068),C(328) Say "Qtd Empenhada"         Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(088),C(261) Say "Saldo Atual"           Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(088),C(328) Say "Qtd Entrada Prevista"  Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(108),C(261) Say "Qtd. Pedido de Venda"  Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(108),C(328) Say "Qtd Reservada"         Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(127),C(261) Say "Qtd Empenhada S.A."    Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(127),C(328) Say "Qtd Ter. Ns. Pd."      Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(147),C(261) Say "Qtd. Ms. Pd. Ter."     Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(147),C(328) Say "Saldo Pod. 3"          Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(160),C(005) Say "Saldo por Armazém"     Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(166),C(261) Say "Qtd Emp. NF"           Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(166),C(328) Say "Qtd. a Endereçar"      Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(261) Say "Qtd. Emp. Prj."        Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(328) Say "Empen. Previ"          Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(261) Say "Qtd de Etiquetas"      Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(328) Say "Qtd Metros Lineares"   Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(152),C(018) Say "Produtos sem saldo"    Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(152),C(082) Say "Produtos com saldo"    Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(152),C(149) Say "Duplo Click no produto para visualizar saldos" Size C(107),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(040),C(005) ComboBox cComboBx1  Items aEmpresa   Size C(041),C(010) PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(040),C(051) ComboBox cComboBx2  Items aFilial    Size C(064),C(010) PIXEL OF oDlg
   @ C(040),C(120) ComboBox cComboBx3  Items aArmazem   Size C(045),C(010) PIXEL OF oDlg
   @ C(039),C(261) ComboBox cComboBx4  Items aCampos    Size C(046),C(010) PIXEL OF oDlg
   @ C(039),C(314) ComboBox cComboBx5  Items aOperacao  Size C(036),C(010) PIXEL OF oDlg
   @ C(040),C(170) MsGet    oGet1      Var   cString    Size C(084),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   
   @ C(038),C(353) Button "Pesquisar" Size C(035),C(011) PIXEL OF oDlg ACTION( xbuscapro() )

   @ C(052),C(120) CheckBox oCheckBox2 Var lSomente   Prompt "Pesquisar somente produtos com saldo" Size C(102),C(008) PIXEL OF oDlg
// @ C(052),C(314) CheckBox oCheckBox1 Var lConsolida Prompt "Consolidar Resultados"                Size C(064),C(008) PIXEL OF oDlg
   
   @ C(077),C(261) MsGet oGet2  Var Transform(nDispo  , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(096),C(261) MsGet oGet3  Var Transform(nSatual , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(116),C(261) MsGet oGet4  Var Transform(nPvenda , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(135),C(261) MsGet oGet5  Var Transform(nEmpsa  , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(154),C(261) MsGet oGet6  Var Transform(nNter   , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(173),C(261) MsGet oGet7  Var Transform(nEmnf   , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(192),C(261) MsGet oGet8  Var Transform(nEmpj   , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(212),C(261) MsGet oGet16 Var Transform(nEtiq   , "@E 999,9999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
         
   @ C(077),C(328) MsGet oGet9  Var Transform(nEmpen  , "@E 99,999,999.9999") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(096),C(328) MsGet oGet10 Var Transform(nQentr  , "@E 99,999,999.9999") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(116),C(328) MsGet oGet11 Var Transform(nReserva, "@E 9999,999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(135),C(328) MsGet oGet12 Var Transform(nCter   , "@E 9999,999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(154),C(328) MsGet oGet13 Var Transform(nSpod3  , "@E 9999,999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(173),C(328) MsGet oGet14 Var Transform(nEnder  , "@E 9999,999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(192),C(328) MsGet oGet15 Var Transform(nEmpp   , "@E 99,999,999.9999") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba
   @ C(212),C(328) MsGet oGet17 Var Transform(nMlin   , "@E 9999,999,999.99") Size C(051),C(009) COLOR CLR_BLACK Font oFont12cb PIXEL OF oDlg When lChumba

   @ C(077),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nDispo   <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(096),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nSatual  <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(116),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nPvenda  <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(135),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nEmpsa   <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(154),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nNter    <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(173),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nEmnf    <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(192),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nEmpj    <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(212),C(312) Button "..." Size C(009),C(009) PIXEL OF oDlg When nEtiq    <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )

   @ C(077),C(379) Button "..." Size C(009),C(009) PIXEL OF oDlg When nEmpen   <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(096),C(379) Button "..." Size C(009),C(009) PIXEL OF oDlg When nQentr   <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(116),C(379) Button "..." Size C(009),C(008) PIXEL OF oDlg When nReserva <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(135),C(379) Button "..." Size C(009),C(009) PIXEL OF oDlg When nCter    <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(154),C(379) Button "..." Size C(009),C(009) PIXEL OF oDlg When nSpod3   <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(173),C(379) Button "..." Size C(009),C(009) PIXEL OF oDlg When nEnder   <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(192),C(379) Button "..." Size C(009),C(009) PIXEL OF oDlg When nEmpp    <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )
   @ C(212),C(379) Button "..." Size C(009),C(009) PIXEL OF oDlg When nMlin    <> 0 ACTION( MsgAlert("Aguarde! Em construção.") )

   @ C(210),C(005) Button "Cad.Produto"  Size C(037),C(012) PIXEL OF oDlg ACTION( xCadProd(axBrowse[oxBrowse:nAt,02]) )      When !Empty(Alltrim(axBrowse[oxBrowse:nAt,02]))
   @ C(210),C(043) Button "Sld X End."   Size C(037),C(012) PIXEL OF oDlg ACTION( MATA226() )
   @ C(210),C(082) Button "Kardex"       Size C(037),C(012) PIXEL OF oDlg ACTION( AbreKardexP(axBrowse[oxBrowse:nAt,02]) )   When !Empty(Alltrim(axBrowse[oxBrowse:nAt,02]))
   @ C(210),C(120) Button "Hist.Produto" Size C(037),C(012) PIXEL OF oDlg ACTION( xOpcaoHistorico() )                        When !Empty(Alltrim(axBrowse[oxBrowse:nAt,02]))
   @ C(210),C(159) Button "Embalagem"    Size C(037),C(012) PIXEL OF oDlg ACTION( AbreEmbalagem(axBrowse[oxBrowse:nAt,02]) ) When !Empty(Alltrim(axBrowse[oxBrowse:nAt,02]))
   @ C(210),C(217) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
 
   // ############################################
   // Desenha o Browse dos Produtos Pesquisados ##
   // ############################################
   aAdd( axBrowse, { "1", "", "", "", "", "" } )

   oxBrowse := TCBrowse():New( 075 , 005, 320, 117,,{"LG"                    ,; // 01 - Legenda
                                                    "Código"                 ,; // 02 - Código do Produto
                                                    "Descrição dos Produtos" ,; // 03 - Descrição dos Produtos
                                                    "Etq p/Rolo"             ,; // 04 - Quantidade de Etiquetas por Rolo
                                                    "Part Number"            ,; // 05 - Part Number
                                                    "N.C.M."               } ,; // 06 - NCM
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
                          axBrowse[oxBrowse:nAt,06]               }}

   oxBrowse:bLDblClick := {|| BuscaSB2() }

   // #########################################
   // Desenha a Lista de Saldos por Armazens ##
   // #########################################
   aAdd( aLista, { "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )

   oLista := TCBrowse():New( 215 , 005, 320, 050,,{"Armazém"              ,; // 01
                                                   "Qtd. Disponível"      ,; // 02
                                                   "Sld. Atual"           ,; // 03
                                                   "Qtd. Pedido de Venda" ,; // 04
                                                   "Qtd. Empenhada"       ,; // 05
                                                   "Qtd. Prev.Entrada"    ,; // 06
                                                   "Qtd. Emp. SA"         ,; // 07
                                                   "Qtd. Reserva"         ,; // 08
                                                   "Qtd. Ter.Ns.Pd."      ,; // 09
                                                   "Qtd. Ns.Pd.Ter."      ,; // 10
                                                   "Sld. Poder 3"         ,; // 11
                                                   "Qtd. Emp. NF."        ,; // 12
                                                   "Qtd. A Endereçar"     ,; // 13
                                                   "Qtd. Emp. Prj."       ,; // 14
                                                   "Qtd. Emp. Prevista"   ,; // 15
                                                   "Qtd. Rolos"           ,; // 16
                                                   "Qtd. Mts Lineares" }  ,; // 17
                                                   {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oLista:SetArray(aLista) 
    
   oLista:bLine := {||{ aLista[oLista:nAt,01],;
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
                        aLista[oLista:nAt,17]}}

   oLista:bLDblClick := {|| BuscaArmazem() }

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

   Local cGramat := 	''
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

   aArea := GetArea()
   
   axBrowse := {}

   // ###########################################
   // Carrega o Array com os dados pesquisados ##
   // ###########################################
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.B1_COD   ," + CHR(13)
   cSql += "       A.B1_PARNUM," + CHR(13)
   cSql += "       A.B1_DESC  ," + CHR(13)
   cSql += "       A.B1_DAUX  ," + CHR(13)
   cSql += "       A.B1_POSIPI," + CHR(13)
   cSql += "       A.B1_QROLOS," + CHR(13)
   cSql += "      (SELECT SUM((SB2.B2_QFIM    + " + CHR(13)
   cSql += "                   SB2.B2_QATU    + " + CHR(13)
   cSql += "                   SB2.B2_QPEDVEN + " + CHR(13)
   cSql += "                   SB2.B2_QEMP    + " + CHR(13)
   cSql += "                   SB2.B2_SALPEDI + " + CHR(13)
   cSql += "                   SB2.B2_QEMPSA  + " + CHR(13)
   cSql += "                   SB2.B2_RESERVA + " + CHR(13)
   cSql += "                   SB2.B2_QTNP    + " + CHR(13)
   cSql += "                   SB2.B2_QNPT    + " + CHR(13)
   cSql += "                   SB2.B2_QTER    + " + CHR(13)
   cSql += "                   SB2.B2_QEMPN   + " + CHR(13)
   cSql += "                   SB2.B2_QACLASS + " + CHR(13)
   cSql += "                   SB2.B2_QEMPPRJ + " + CHR(13)
   cSql += "                   SB2.B2_QEMPPRE)) " + CHR(13)
   cSql += "         FROM SB2" + Substr(cCombobx1,01,02) + "0 SB2 "           + CHR(13)
   cSql += "        WHERE SB2.B2_FILIAL  = '" + Substr(cComboBx2,01,02) + "'" + CHR(13)

   If Substr(cComboBx3,01,02) == "##"
   Else
      cSql += " AND SB2.B2_LOCAL = '" + Alltrim(Substr(cComboBx3,01,02)) + "'"
   Endif   

   cSql += "          AND SB2.B2_COD     = A.B1_COD"                          + CHR(13)
   cSql += "          AND SB2.D_E_L_E_T_ = ''"                                + CHR(13)
   cSql += "        GROUP BY SB2.B2_FILIAL, SB2.B2_COD) AS SALDOS "
   cSql += "  FROM " + RetSqlName("SB1") + " A " + CHR(13)
   cSql += " WHERE A.B1_MSBLQL <> '1'" + CHR(13)
   cSql += "   AND A.D_E_L_E_T_ = '' " + CHR(13)

   Do Case
      Case Substr(cComboBx4,01,01) = "1" // Descrição
           Do Case
              Case Substr(cComboBx5,01,01) == "3" // Igual
                   cSql += " AND A.B1_DESC = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "2" // Iniciando
                   cSql += " AND A.B1_DESC  LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "1" // Contendo
                   cSql += " AND A.B1_DESC  LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   
  
      Case Substr(cComboBx4,01,01) = "2" // Código
           Do Case
              Case Substr(cComboBx5,01,01) == "3" // Igual
                   cSql += " AND A.B1_COD = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "2" // Iniciando
                   cSql += " AND A.B1_COD LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "1" // Contendo
                   cSql += " AND A.B1_COD LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      Case Substr(cComboBx4,01,01) = "3" // Part Number
           Do Case
              Case Substr(cComboBx5,01,01) == "3" // Igual
                   cSql += " AND A.B1_PARNUM = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "2" // Iniciando
                   cSql += " AND A.B1_PARNUM LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "1" // Contendo
                   cSql += " AND A.B1_PARNUM LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      Case Substr(cComboBx4,01,01) = "4" // NCM
           Do Case
              Case Substr(cComboBx5,01,01) == "3" // Igual
                   cSql += " AND A.B1_POSIPI = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "2" // Inicando
                   cSql += " AND A.B1_POSIPI LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx5,01,01) == "1" // Contendo
                   cSql += " AND A.B1_POSIPI LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

   EndCase

   cSql += " ORDER BY A.B1_DESC, A.B1_DAUX" + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If T_PRODUTO->( EOF() )
      aLista := {}
      aAdd( aLista , { "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
   Endif   

   T_PRODUTO->( DbGoTop() )

   WHILE !T_PRODUTO->( EOF() )

      If T_PRODUTO->SALDOS == 0
         kLegenda := "1"
      Else
         kLegenda := "2"                        
      Endif

      If lSomente == .F.
      Else
         If kLegenda == "1"
            T_PRODUTO->( DbSkip() )            
            Loop
         Endif
      Endif      

      // ##########################
      // Carrega o Array axBrowse ##
      // ##########################
      aAdd( axBrowse, { kLegenda            , ;
                       T_PRODUTO->B1_COD    , ;
                       Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX) + Space(40) ,;
                       T_PRODUTO->B1_QROLOS , ;
                       T_PRODUTO->B1_PARNUM , ;
                       Substr(T_PRODUTO->B1_POSIPI,01,04) + "." + Substr(T_PRODUTO->B1_POSIPI,05,02) + "." + Substr(T_PRODUTO->B1_POSIPI,07,02)})

      T_PRODUTO->( DbSkip() )

   ENDDO

   If Len(axBrowse) == 0

      aAdd( axBrowse, { "1", "", "", "", "", "" } )
      aLista := {}
      aAdd( aLista , { "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )

   Else

      BuscaSb2()   
      BuscaArmazem()
      QtdEtqLinear()

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
                          axBrowse[oxBrowse:nAt,06]               }}

   RestArea( aArea )

Return(.T.)

// #############################################################
// Função que pesquisa o saldo da SB2 e popula o array aLista ##
// #############################################################
Static Function BuscaSb2()

   Local cSql := ""

   aLista := {}

   If Len(aLista) == 0
      aAdd( aLista, { "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )   
   Endif   

   oLista:SetArray(aLista) 
    
   oLista:bLine := {||{ aLista[oLista:nAt,01],;
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
                        aLista[oLista:nAt,17]}}

   oLista:Refresh()

   aLista := {}

   If Select("T_SALDOS") > 0
      T_SALDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SB2.B2_FILIAL ," + chr(13)
   cSql += "       SB2.B2_COD    ," + chr(13)
   cSql += "	   SB2.B2_LOCAL  ," + chr(13)
   cSql += "       SB2.B2_QFIM   ," + chr(13)
   cSql += "       SB2.B2_QATU   ," + chr(13)
   cSql += "	   SB2.B2_QPEDVEN," + chr(13)
   cSql += "	   SB2.B2_QEMP   ," + chr(13)
   cSql += "	   SB2.B2_SALPEDI," + chr(13)
   cSql += "	   SB2.B2_QEMPSA ," + chr(13)
   cSql += "	   SB2.B2_RESERVA," + chr(13)
   cSql += "	   SB2.B2_QTNP   ," + chr(13)
   cSql += "	   SB2.B2_QNPT   ," + chr(13)
   cSql += "	   SB2.B2_QTER   ," + chr(13)
   cSql += "	   SB2.B2_QEMPN  ," + chr(13)
   cSql += "	   SB2.B2_QACLASS," + chr(13)
   cSql += "	   SB2.B2_QEMPPRJ," + chr(13)
   cSql += "	   SB2.B2_QEMPPRE " + chr(13)
   cSql += "  FROM SB2" + Substr(cCombobx1,01,02) + "0 SB2 " + chr(13)
   cSql += " WHERE SB2.B2_FILIAL  = '" + Substr(cCombobx2,01,02) + "'" + chr(13)
   cSql += "   AND SB2.B2_COD     = '" + Alltrim(axBrowse[oxBrowse:nAt,02]) + "'" + chr(13)
   cSql += "   AND SB2.D_E_L_E_T_ = ''" + chr(13)
 
   If Substr(cComboBx3,01,02) == "##"
   Else
      cSql += " AND SB2.B2_LOCAL = '" + Alltrim(Substr(cComboBx3,01,02)) + "'" + chr(13)
   Endif   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDOS", .T., .T. )
                                                         
   T_SALDOS->( DbGoTop() )
   
   WHILE !T_SALDOS->( EOF() )
   
      aAdd( aLista, { T_SALDOS->B2_LOCAL  ,; // 01
                      T_SALDOS->B2_QFIM   ,; // 02
                      T_SALDOS->B2_QATU   ,; // 03
                      T_SALDOS->B2_QPEDVEN,; // 04
                      T_SALDOS->B2_QEMP   ,; // 05
                      T_SALDOS->B2_SALPEDI,; // 06
                      T_SALDOS->B2_QEMPSA ,; // 07
                      T_SALDOS->B2_RESERVA,; // 08
                      T_SALDOS->B2_QTNP   ,; // 09
                      T_SALDOS->B2_QNPT   ,; // 10
                      T_SALDOS->B2_QTER   ,; // 11
                      T_SALDOS->B2_QEMPN  ,; // 12
                      T_SALDOS->B2_QACLASS,; // 13
                      T_SALDOS->B2_QEMPPRJ,; // 14
                      T_SALDOS->B2_QEMPPRE,; // 15
                      0                   ,; // 16
                      0                   }) // 17
                      
       T_SALDOS->( DbSkip() )
       
   ENDDO

   If Len(aLista) == 0
      aAdd( aLista, { "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )   
   Endif   

   oLista:SetArray(aLista) 
    
   oLista:bLine := {||{ aLista[oLista:nAt,01],;
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
                        aLista[oLista:nAt,17]}}

   oLista:Refresh()

   // ################################################
   // Limpa as variáveis para receber novos valores ##
   // ################################################
   nDispo   := 0
   nSatual  := 0
   nPvenda  := 0
   nEmpsa   := 0
   nNter    := 0
   nEmnf    := 0
   nEmpj    := 0
   nEtiq    := 0
         
   nEmpen   := 0
   nQentr   := 0
   nReserva := 0
   nCter    := 0
   nSpod3   := 0
   nEnder   := 0
   nEmpp    := 0
   nMlin    := 0

   // #############################################################
   // Carrega as variáveis com os valores posicionados no aLista ##
   // #############################################################
// nDispo   := aLista[oLista:nAt,02]
   nDispo   := aLista[oLista:nAt,03] - aLista[oLista:nAt,08] - aLista[oLista:nAt,10] - aLista[oLista:nAt,11]
   nSatual  := aLista[oLista:nAt,03]
   nPvenda  := aLista[oLista:nAt,04]
   nEmpsa   := aLista[oLista:nAt,07]
   nNter    := aLista[oLista:nAt,09]
   nEmnf    := aLista[oLista:nAt,12]
   nEmpj    := aLista[oLista:nAt,14]
   nEtiq    := aLista[oLista:nAt,16]
         
   nEmpen   := aLista[oLista:nAt,05]
   nQentr   := aLista[oLista:nAt,06]
   nReserva := aLista[oLista:nAt,08]
   nCter    := aLista[oLista:nAt,10]
   nSpod3   := aLista[oLista:nAt,11]
   nEnder   := aLista[oLista:nAt,13]
   nEmpp    := aLista[oLista:nAt,15]
   nMlin    := aLista[oLista:nAt,17]

   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet16:Refresh()
         
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()
   oGet12:Refresh()
   oGet13:Refresh()
   oGet14:Refresh()
   oGet15:Refresh()
   oGet17:Refresh()
   
Return(.T.)

// ###################################################################################
// Função que pesquisa os saldos na tabela SB2 para o armazém selecionado no aLista ##
// ###################################################################################
Static Function BuscaArmazem()

   // ################################################
   // Limpa as variáveis para receber novos valores ##
   // ################################################
   nDispo   := 0
   nSatual  := 0
   nPvenda  := 0
   nEmpsa   := 0
   nNter    := 0
   nEmnf    := 0
   nEmpj    := 0
   nEtiq    := 0
         
   nEmpen   := 0
   nQentr   := 0
   nReserva := 0
   nCter    := 0
   nSpod3   := 0
   nEnder   := 0
   nEmpp    := 0
   nMlin    := 0

   // #############################################################
   // Carrega as variáveis com os valores posicionados no aLista ##
   // #############################################################
   nDispo   := aLista[oLista:nAt,03] - aLista[oLista:nAt,08] -aLista[oLista:nAt,10] - aLista[oLista:nAt,11]
   nSatual  := aLista[oLista:nAt,03]
   nPvenda  := aLista[oLista:nAt,04]
   nEmpsa   := aLista[oLista:nAt,07]
   nNter    := aLista[oLista:nAt,09]
   nEmnf    := aLista[oLista:nAt,12]
   nEmpj    := aLista[oLista:nAt,14]
   nEtiq    := aLista[oLista:nAt,16]
         
   nEmpen   := aLista[oLista:nAt,05]
   nQentr   := aLista[oLista:nAt,06]
   nReserva := aLista[oLista:nAt,08]
   nCter    := aLista[oLista:nAt,10]
   nSpod3   := aLista[oLista:nAt,11]
   nEnder   := aLista[oLista:nAt,13]
   nEmpp    := aLista[oLista:nAt,15]
   nMlin    := aLista[oLista:nAt,17]

   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet16:Refresh()
         
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()
   oGet12:Refresh()
   oGet13:Refresh()
   oGet14:Refresh()
   oGet15:Refresh()
   oGet17:Refresh()

Return(.T.)

// ########################################################
// Função que pesquisa o cadastro do produto selecionado ##
// ########################################################
Static Function xCadProd(_Produto)

   MsgAlert("Aguarde! Em Construção.")
   
   Return(.T.)

   MsgRun("Aguarde! Abrindo a consulta do produto selecionado ...", "Consulta Saldos",{|| yCadProd(_Produto) })

Return(.T.)

// ########################################################
// Função que pesquisa o cadastro do produto selecionado ##
// ########################################################
Static Function yCadProd(_Produto)

   aArea := GetArea()
   
   // ####################################################
   // Posiciona no produto a ser pesquisado o seu saldo ##
   // ####################################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   AxVisual("SB1", SB1->( Recno() ), 2)

   RestArea( aArea )

Return .T.

// ##################################################
// Função que abre o kardex do produto selecionado ##
// ##################################################
Static Function AbreKardexP(kProduto)

   MsgRun("Aguarde! Abrindo o Kardex do produto selecionado ...", "Consulta Saldos",{|| xAbreKardexP(kProduto) })

Return(.T.)

// ##################################################
// Função que abre o kardex do produto selecionado ##
// ##################################################
Static Function xAbreKardexP(kProduto)

   Private cCadastro := "Cadastro de Produtos"
   
   If Empty(Alltrim(kProduto))
      MsgAlert("Produto não selecionado para realizar a consulta do Kardex.")
      Return(.T.)
   Endif
          
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbSeek( xFilial("SB1") + kProduto )
   
   U_AUTOM181()
   
Return(.T.)

// ####################################################
// Função que abre as opções do Histórico do Produto ##
// ####################################################
Static Function xOpcaoHistorico()

   Private oDlgHIST

   DEFINE MSDIALOG oDlgHIST TITLE "Historico do Produto" FROM C(178),C(181) TO C(502),C(445) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp"            Size C(126),C(022) PIXEL NOBORDER OF oDlgHIST

   @ C(027),C(004) Button "Últimos Pedidos de Compra"     Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(1, axBrowse[oxBrowse:nAt,02], "") )
   @ C(046),C(004) Button "Últimas Notas Fiscais"         Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(2, axBrowse[oxBrowse:nAt,02], "") )
   @ C(065),C(004) Button "Consumo / Vendas"              Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(3, axBrowse[oxBrowse:nAt,02], "") )
   @ C(084),C(004) Button "Estoque Empresa/Filial Logada" Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(4, axBrowse[oxBrowse:nAt,02], "") )
   @ C(103),C(004) Button "Estoque Consolidado"           Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(5, axBrowse[oxBrowse:nAt,02], axBrowse[oxBrowse:nAt,03]))
   @ C(122),C(004) Button "Custo Sale Machine"            Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(6, axBrowse[oxBrowse:nAt,02], "") )
   @ C(141),C(004) Button "Voltar"                        Size C(126),C(018) PIXEL OF oDlgHIST ACTION( oDlgHIST:End() )

   ACTIVATE MSDIALOG oDlgHIST CENTERED 

Return(.T.)

// ##########################################################################
// Função que direciona ao programa relacionado conforme seleção das oções ##
// ##########################################################################
Static Function DisparaOPC(DOpcao, DProduto, dDescricao)

   Do Case

      // ###############################
      // Pedidos de Compra do Produto ##
      // ###############################
      Case dOpcao == 1
           U_AUTOM639(dProduto)

      // ######################################
      // Notas Fiscais de Entrada do produto ##
      // ######################################
      Case dOpcao == 2
           U_AUTOM640(dProduto)

           cEmpAnt := aVoltaFil[1,1]
           cFilAnt := aVoltaFil[1,2]           

      // ###########################
      // Consumo/Venda do produto ##
      // ###########################
      Case dOpcao == 3
           U_AUTOM598(dProduto)

      // ################################
      // Estoque Empresa/Filial Logada ##
      // ################################
      Case dOpcao == 4
           xSaldoProd(dProduto)

      // ######################
      // Estoque Consolidado ##
      // ######################
      Case dOpcao == 5
           U_AUTOM291(dProduto, dDescricao)

      // #####################
      // Custo Sale Machine ##
      // #####################
      Case dOpcao == 6
           U_AUTOM537(dProduto)

   EndCase

Return(.T.)

// #####################################################
// Função que pesquisa o saldo do produto selecionado ##
// #####################################################
Static Function xSaldoProd(_Produto)

   aArea := GetArea()

   // ####################################################
   // Posiciona no produto a ser pesquisado o seu saldo ##
   // ####################################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return(.T.)

// ####################################################
// Função que abre a embalagm do produto selecionado ##
// ####################################################
Static Function AbreEmbalagem(kProduto)

   Private cCadastro := "Cadastro de Produtos"
   
   If Empty(Alltrim(kProduto))
      MsgAlert("Produto não selecionado para realizar a consulta do Kardex.")
      Return(.T.)
   Endif
          
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbSeek( xFilial("SB1") + kProduto )
   
   U_AUTOM631()
   
Return(.T.)

// ##################################################################################
// Função que calcula a quantidade de etiquetas e metros lineares abre a embalagem ##
// ##################################################################################
Static Function QtdEtqLinear()

   Local cSql       := ""
   Local kEtiquetas := 0 
   Local __nQtdLin  := 0
   Local __nQtdM2   := 0    
   Local nVezes     := 0
   Local cGramat 	:= 	''
   Local cMetr		:=	''
   Local cEtqRol	:=	''                
   Local cRolos	    :=	''
   Local nMetr      := 0
   Local nEtqRol    := 0
   Local nRolos     := 0
   
   Private aComp	:= {}

   // ########################################################
   // Pesquisa as OP em produção para o produto selecionado ##
   // ########################################################
   If Select("T_SALDOS") > 0
      T_SALDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC2.C2_NUM    ,"
   cSql += "       SC2.C2_ITEM   ,"
   cSql += "       SC2.C2_SEQUEN ,"
   cSql += "       SC2.C2_PRODUTO,"
   cSql += "       SC2.C2_QUANT  ,"         
   cSql += "       SC2.C2_QUJE   ,"
   cSql += "      (SC2.C2_QUJE + SC2.C2_PERDA) AS PRODUZIDO"
   cSql += "  FROM SC2" + Substr(cComboBx1,01,02) + "0 SC2 " 
   cSql += " WHERE SC2.C2_FILIAL  = '" + Substr(cComboBx2,01,02) + "'"
   cSql += "   AND SC2.C2_PRODUTO = '" + Alltrim(axBrowse[oxBrowse:nAt,02]) + "'"
   cSql += "   AND SC2.D_E_L_E_T_ = ''"   
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDOS", .T., .T. )
   
   If T_SALDOS->( EOF() )
   
      nEtiq := 0
      nMlin := 0         
      
   Else
               
      T_SALDOS->( DbGoTop() )
      
      kEtiquetas := 0 
      
      WHILE !T_SALDOS->( EOF() )

         If T_SALDOS->PRODUZIDO <> 0
            T_SALDOS->( DbSkip() )
            LOOP
         Endif   

         DbSelectArea('SB1')
         DbSetOrder(1)
         DbGoTop()

         If DbSeek(xFilial('SB1') + SC2->C2_PRODUTO, .F.)
	        _aRet1 := U_CALCMETR(SC2->C2_PRODUTO)
	
	        // 1 = Metragem Linear por rolo
	        // 2 = Qtd Etoquetas por rolo
	        // 3= Tubete
	        cGramat	:=	TABELA("ZP",SB1->B1_MPCLAS,.f.)
	        nMetr	:=	_aRet1[1]
	        nEtqRol	:=	_aRet1[2]
	
	        IF SB1->B1_UM == "MI"
               nRolos	:= (SC2->C2_QUANT*1000)/nEtqRol
        //     nRolos	:= (SC2->C2_ZQTD*1000)/nEtqRol
	        ELSE
	           nRolos	:=	SC2->C2_QUANT
        // 	   nRolos	:=	SC2->C2_ZQTD
	        ENDIF
         EndIf

         kEtiquetas := kEtiquetas + (T_SALDOS->C2_QUANT * nEtqRol)
         
         // ###############################
         // Calcula dados para impressão ##
         // ###############################
         DbSelectArea("SC2")
         DBSEEK(xFilial("SC2") + T_SALDOS->C2_NUM) 
         
         // ######################################
         // Carrega o array aComp - Componentes ##
         // ######################################
         aComp     := U_xBuscaComp()
                                                     
         nVezes := 2

         For nComponente = 1 to Len(aComp)

             // ###############################
             // Calcula dados para impressão ##
             // ###############################
             __nQtdLin := U_CalcPerda("OP", SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN,SC2->C2_PRODUTO,.F.)
	         __nQtdM2  := IIF(Len(aComp)>0,__nQtdLin * aComp[nComponente][8],0)
             nMlin     := nMlin + __nQtdLin

             nVezes := nVezes - 1
   
             If nVezes == 0
                Exit
             Endif   

         Next nComponente

         T_SALDOS->( DbSkip() )

      ENDDO

      nEtiq := kEtiquetas
      
   Endif

Return(.T.)      