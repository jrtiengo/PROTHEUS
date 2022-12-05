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
// Referencia: AUTOM666.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 04/01/2018                                                                ##
// Objetivo..: Programa que gera OS Agrupadas                                            ##
// Parâmetros: Sem parâmetros                                                            ##
// ########################################################################################

User Function AUTOM666()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas   := U_AUTOM539(1, "")
   Private aFiliais    := U_AUTOM539(2, cEmpAnt)
   Private aContatos   := {}
   Private aConsulta   := {}
   Private cCliente    := Space(06)
   Private cLoja       := Space(03)
   Private cNomeCli    := Space(60)
   Private aFabricante := {}
   Private cCondicao   := Space(03)
   Private cNomeCond   := Space(60)
   Private aPosicao    := {}
   Private cAprovada   := Space(01)
   Private cTabela     := Space(03)
   Private cMoeda      := 1
   Private cEntrada    := Space(12)
   Private cPedido     := Space(06)
   Private cNota       := Space(06)

   Private cComboBx1 
   Private cComboBx2 
   Private oGet1     
   Private oGet2     
   Private oGet3     
   Private cComboBx3 
   Private oGet4     
   Private oGet5     
   Private cComboBx4 
   Private cComboBx5 
   Private oGet6     
   Private oGet7     
   Private oGet8     
   Private oGet9     
   Private oGet10    
   Private oGet11    
   Private oGet12    
   Private oGet13    

   Private aBrowse := {}

   Private oDlg

   // ##############################
   // Carrega o Array aFabricante ##
   // ##############################
   aAdd( aFabricante, "SELECIONE")  
   aAdd( aFabricante, "ZEBRA")
   aAdd( aFabricante, "HONEYWELL")
   aAdd( aFabricante, "GERTEC")
   aAdd( aFabricante, "INGENICO")
   aAdd( aFabricante, "M.KELLER")
   aAdd( aFabricante, "CONQ.")
   aAdd( aFabricante, "BR TOUCH")
   aAdd( aFabricante, "ELGIN")
   aAdd( aFabricante, "BEMATECH")
   aAdd( aFabricante, "ZPM")
   aAdd( aFabricante, "PSI")
   aAdd( aFabricante, "VERIFONE")
   aAdd( aFabricante, "PRIME")
   aAdd( aFabricante, "PERTO")
   aAdd( aFabricante, "SAMSUNG")
   aAdd( aFabricante, "APPLE")
   aAdd( aFabricante, "EPSON")
   aAdd( aFabricante, "DARUMA")
   
   // ###########################
   // Carrega o Array aPosicao ##
   // ###########################
   aAdd( aPosicao, "SELECIONE") 
   aAdd( aPosicao, "F=Fab Ag Orc")
   aAdd( aPosicao, "P=Ag Pecas")
   aAdd( aPosicao, "A=Ag Aprov")
   aAdd( aPosicao, "B=Em Banc")
   aAdd( aPosicao, "D=Ag RMA")
   aAdd( aPosicao, "E=Enc")
   aAdd( aPosicao, "M=Aprov")
   aAdd( aPosicao, "N=Reprov")
   aAdd( aPosicao, "C=Ag NF")
   aAdd( aPosicao, "G=Fab Ag Aprov")
   aAdd( aPosicao, "H=Ag Ret Fab")
   aAdd( aPosicao, "I=Entr")
   aAdd( aPosicao, "S=Atest ")

   // ##################################################################
   // Posiciona na Empresa Logada para posicionar o combo de Empresas ##
   // ##################################################################
   Do Case 
      Case cEmpAnt == "01"
           kEmpresa := "01 - AUTOMATECH"

           Do Case
              Case cFilAnt == "01"
                   kFilial := "01 - Porto Alegre"
              Case cFilAnt == "02"
                   kFilial := "02 - Caxias do Sul"
              Case cFilAnt == "03"
                   kFilial := "03 - Pelotas"
              Case cFilAnt == "04"
                   kFilial := "04 - Suprimentos"
              Case cFilAnt == "05"
                   kFilial := "05 - São Paulo"
              Case cFilAnt == "06"
                   kFilial := "06 - Espirito Santo"
              Case cFilAnt == "07"
                   kFilial := "07 - Suprimentos(Novo)"
           EndCase        
      Case cEmpAnt == "02"
           kEmpresa := "02 - TI AUTOMAÇÃO"
           kFilial  := "01 - Curitiba"
      Case cEmpAnt == "03"
           kEmpresa := "03 - ATECH"
           kFilial  := "06 - Porto Alegre"
      Case cEmpAnt == "04"
           kEmpresa := "04 - ATECHPEL"
           kFilial  := "01 - Pelotas"
   EndCase         
           
   DEFINE MSDIALOG oDlg TITLE "Abertura Agrupada de Ordens de Serviço por Cliente/Nota Fiscal de Entrada" FROM C(178),C(181) TO C(552),C(960) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Empresa"                 Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(082) Say "Filiais"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(160) Say "Cliente"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Fabricante"              Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(082) Say "Cond.Pgtº"               Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(214) Say "Posição"                 Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(293) Say "Aprovada?"               Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(330) Say "Tabela"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(361) Say "Moeda"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(078),C(005) Say "Contato WF"              Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(078),C(214) Say "NF Entrada"              Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(005) Say "Produtos da Nota Fiscal" Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(044),C(005) MsGet    oGet14    Var   kEmpresa    Size C(071),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(044),C(082) MsGet    oGet15    Var   kFilial     Size C(071),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(044),C(160) MsGet    oGet1     Var   cCliente    Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(044),C(193) MsGet    oGet2     Var   cLoja       Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( cNomeCli := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_NOME"), PsqContato() )
   @ C(044),C(214) MsGet    oGet3     Var   cNomeCli    Size C(173),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(065),C(005) ComboBox cComboBx3 Items aFabricante Size C(072),C(010)                              PIXEL OF oDlg
   @ C(065),C(082) MsGet    oGet4     Var   cCondicao   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SE4") VALID( cNomeCond := Posicione( "SE4", 1, xFilial("SE4") + cCondicao, "E4_DESCRI" ) )
   @ C(065),C(109) MsGet    oGet5     Var   cNomeCond   Size C(101),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(065),C(214) ComboBox cComboBx4 Items aPosicao    Size C(072),C(010)                              PIXEL OF oDlg
   @ C(065),C(293) MsGet    oGet6     Var   cAprovada   Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SX5", "ZZ")
   @ C(065),C(330) MsGet    oGet7     Var   cTabela     Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(065),C(361) MsGet    oGet8     Var   cMoeda      Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(088),C(005) ComboBox cComboBx5 Items aContatos   Size C(206),C(010)                              PIXEL OF oDlg ON CHANGE PsqContato()
   @ C(088),C(214) MsGet    oGet11    Var   cEntrada    Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(171),C(005) Button "Incluir"   Size C(037),C(012) PIXEL OF oDlg ACTION( MntEquipa("I") )
   @ C(171),C(043) Button "Alterar"   Size C(037),C(012) PIXEL OF oDlg ACTION( MntEquipa("A") )
   @ C(171),C(081) Button "Excluir"   Size C(037),C(012) PIXEL OF oDlg ACTION( MntEquipa("E") )
   @ C(171),C(311) Button "Gerar OSs" Size C(037),C(012) PIXEL OF oDlg ACTION( GERAOSERVICO() )
   @ C(171),C(350) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 138, 005, 490, 075,,{'Produto/Equipamento'  ,; // 01
                                                   'Nº de Séries'         ,; // 02
                                                   'Descrição'            ,; // 03
                                                   'Ocorrência'           ,; // 04
                                                   'Obs. Ocorrência'      ,; // 05
                                                   'Data Garantia'        ,; // 06
                                                   'Nº OS'               },; // 07
                                                   {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(044),C(082) ComboBox cComboBx2 Items aFiliais Size C(072),C(010) PIXEL OF oDlg

Return(.T.)

// #####################################################
// Função que pesquisa o contato do cliente informado ##
// #####################################################
Static Function PsqContato()

   If Empty(AlltriM(cCliente))
      MsgAlert("Cliente não informado. Verifique!")
      Return(.T.)
   Endif
   
   If Empty(AlltriM(cLoja))
      MsgAlert("Cliente não informado. Verifique!")
      Return(.T.)
   Endif

   aContatos := {}

   If Select("T_CONTATOS") > 0
      T_CONTATOS->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql := "SELECT AC8.AC8_CODENT, "
   cSql += "       AC8.AC8_CODCON, "
   cSql += " 	   SU5.U5_CODCONT, "
   cSql += " 	   SU5.U5_CONTAT   "
   cSql += "  FROM " + RetSqlName("AC8") + " AC8, "
   cSql += "       " + RetSqlName("SU5") + " SU5  "
   cSql += " WHERE AC8.AC8_CODENT = '" + Alltrim(cCliente) + Alltrim(cLoja) + "'"
   cSql += "   AND AC8.D_E_L_E_T_ = ''"
   cSql += "   AND SU5.U5_CODCONT = AC8.AC8_CODCON"
   cSql += "   AND SU5.D_E_L_E_T_ = ''"
   cSql += "   AND SU5.U5_CONTAT <> ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATOS", .T., .T. )

   T_CONTATOS->( DbGoTop() )
   
   WHILE !T_CONTATOS->( EOF() )
      aAdd( aContatos, T_CONTATOS->U5_CODCONT + " - " + Alltrim(T_CONTATOS->U5_CONTAT) )
      T_CONTATOS->( DbSkip() )
   Enddo

   @ C(088),C(005) ComboBox cComboBx5 Items aContatos   Size C(206),C(010)                              PIXEL OF oDlg
   
Return(.T.)

// ############################################################
// Função que abre a janela para informação dos equipamentos ##
// ############################################################
Static Function MntEquipa( kTipo )

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private cProduto	   := Space(30)
   Private cNomePro	   := Space(60)
   Private cSerie	   := Space(30)
   Private cOcorrencia := ""
   Private aOcorrencia := {}

   Private cComboBx100
   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo2
   
   Private oDlgPro

   If Empty(AlltriM(cCliente))
      MsgAlert("Cliente não informado. Verifique!")
      Return(.T.)
   Endif
   
   If Empty(AlltriM(cLoja))
      MsgAlert("Cliente não informado. Verifique!")
      Return(.T.)
   Endif

   If Select("T_OCORRENCIA") > 0
      T_OCORRENCIA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AAG_CODPRB,"
   cSql += "       AAG_DESCRI "
   cSql += "  FROM " + RetSqlName("AAG") 
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY AAG_CODPRB  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCORRENCIA", .T., .T. )

   T_OCORRENCIA->( DbGoTop() )

   aAdd( aOcorrencia, "000000 - SELECIONE" )
   
   WHILE !T_OCORRENCIA->( EOF() )

      aAdd( aOcorrencia, T_OCORRENCIA->AAG_CODPRB + " - " + Alltrim(T_OCORRENCIA->AAG_DESCRI) )   

      If kTipo == "I"
      Else
         If Alltrim(aBrowse[oBrowse:nAt,04]) == Alltrim(T_OCORRENCIA->AAG_CODPRB)
            cComboBx100 := T_OCORRENCIA->AAG_CODPRB + " - " + Alltrim(T_OCORRENCIA->AAG_DESCRI)
         Endif
      Endif   

      T_OCORRENCIA->( DbSkip() )

   ENDDO   

   If kTipo == "I"
   Else
      cProduto	  := aBrowse[oBrowse:nAt,01]
      cNomePro	  := aBrowse[oBrowse:nAt,03]
      cSerie	  := aBrowse[oBrowse:nAt,02]
      cOcorrencia := aBrowse[oBrowse:nAt,05]
   Endif   

   // ###########################################
   // Deenha atela para visualização dos dados ##
   // ###########################################
   DEFINE MSDIALOG oDlgPro TITLE "Inclusão de Equipamento" FROM C(178),C(181) TO C(500),C(645) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgPro

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(226),C(001) PIXEL OF oDlgPro

   @ C(033),C(005) Say "Produto/Equipamento"   Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   @ C(033),C(081) Say "Descrição"             Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   @ C(054),C(005) Say "Nº de Série"           Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   @ C(054),C(081) Say "Ocorrência"            Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   @ C(077),C(005) Say "Observação Ocorrência" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   
   If kTipo == "E"
      @ C(042),C(005) MsGet    oGet1       Var   cProduto         Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro When lChumba
      @ C(042),C(081) MsGet    oGet2       Var   cNomePro         Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro When lChumba
      @ C(064),C(005) MsGet    oGet3       Var   cSerie           Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro When lChumba
      @ C(064),C(081) ComboBox cComboBx100 Items aOcorrencia      Size C(148),C(010)                              PIXEL OF oDlgPro When lChumba
      @ C(086),C(005) GET      oMemo2      Var   cOcorrencia MEMO Size C(223),C(054)                              PIXEL OF oDlgPro When lChumba

      @ C(145),C(152) Button "Excluir"     Size C(037),C(012) PIXEL OF oDlgPro ACTION( SALVAEQUI(kTipo) )
      @ C(145),C(191) Button "Voltar"      Size C(037),C(012) PIXEL OF oDlgPro ACTION( OdlgPro:End() )
   Else

      @ C(042),C(005) MsGet    oGet1       Var   cProduto         Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro F3("SB1") VALID( cNomePro := Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC") + " " + Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DAUX") )
      @ C(042),C(081) MsGet    oGet2       Var   cNomePro         Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro When lChumba
      @ C(064),C(005) MsGet    oGet3       Var   cSerie           Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro VALID( VERSERIE() )
      @ C(064),C(081) ComboBox cComboBx100 Items aOcorrencia      Size C(148),C(010)                              PIXEL OF oDlgPro
      @ C(086),C(005) GET      oMemo2      Var   cOcorrencia MEMO Size C(223),C(054)                              PIXEL OF oDlgPro

      @ C(145),C(005) Button "Consulta Base Instalada" Size C(057),C(012) PIXEL OF oDlgPro ACTION( BUSCAAA3() )
      @ C(145),C(064) Button "Base Instalada"          Size C(054),C(012) PIXEL OF oDlgPro ACTION( TECA040() )
      @ C(145),C(152) Button "Salvar"                  Size C(037),C(012) PIXEL OF oDlgPro ACTION( SALVAEQUI(kTipo) )
      @ C(145),C(191) Button "Voltar"                  Size C(037),C(012) PIXEL OF oDlgPro ACTION( OdlgPro:End() )
   Endif   

   ACTIVATE MSDIALOG oDlgPro CENTERED 

Return(.T.)

// ############################################################
// Função que busca os produtos da base instalada do cliente ##
// ############################################################
Static Function BUSCAAA3()

   MsgRun("Aguarde! Pesquisando Base Instalada do Cliente ...", "Base Instalada",{|| xBUSCAAA3() })

Return(.T.)

// ############################################################
// Função que busca os produtos da base instalada do cliente ##
// ############################################################
Static Function xBUSCAAA3()

   Local cSql := ""

   Private oDlgConsulta

   aConsulta := {}

   If Select("T_EQUIPAMENTOS") > 0
      T_EQUIPAMENTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT AA3.AA3_FILIAL,"
   cSql += "       AA3.AA3_CODCLI,"
   cSql += "       AA3.AA3_LOJA  ,"
   cSql += "       AA3.AA3_CODPRO,"
   cSql += "       SB1.B1_DESC + ' ' + SB1.B1_DAUX AS DESCRICAO,"
   cSql += "       AA3.AA3_NUMSER"
   cSql += "  FROM " + RetSqlName("AA3") + " AA3, "                
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE AA3.AA3_FILIAL = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND AA3.AA3_CODCLI = '" + Alltrim(cCliente) + "'"
   cSql += "   AND AA3.AA3_LOJA   = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND AA3.D_E_L_E_T_ = ''"
 
   If Empty(Alltrim(cProduto))
   Else
      cSql += " AND AA3.AA3_CODPRO = '" + Alltrim(cProduto) + "'"
   Endif   

   cSql += "   AND SB1.B1_COD     = AA3.AA3_CODPRO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EQUIPAMENTOS", .T., .T. )

   T_EQUIPAMENTOS->( DbGoTop() )
   
   WHILE !T_EQUIPAMENTOS->( EOF() )
      aAdd( aConsulta, { T_EQUIPAMENTOS->AA3_CODPRO,;
                         T_EQUIPAMENTOS->DESCRICAO ,;
                         T_EQUIPAMENTOS->AA3_NUMSER})
      T_EQUIPAMENTOS->( DbSkip() )
   ENDDO   

   If Len(aConsulta) == 0
      MsgAlert("Não existem dados a serem visualizados para este cliente.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgConsulta TITLE "Produtos/Equiapamentos" FROM C(178),C(181) TO C(535),C(751) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(022) PIXEL NOBORDER OF oDlgConsulta

   @ C(163),C(204) Button "Selecionar" Size C(037),C(012) PIXEL OF oDlgConsulta ACTION( SELPRODUTO(aConsulta[oConsulta:nAt,01], aConsulta[oConsulta:nAt,02], aConsulta[oConsulta:nAt,03]) )
   @ C(163),C(243) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlgConsulta ACTION( oDlgConsulta:End() )

   oConsulta := TCBrowse():New( 040, 005, 354, 163,,{'Produto/Equipamento'   ,; // 01
                                                     'Descrição'             ,; // 02
                                                     'Nº de Séries'         },; // 03
                                                   {20,50,50,50},oDlgConsulta,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oConsulta:SetArray(aConsulta)
    
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01],;
                           aConsulta[oConsulta:nAt,02],;
                           aConsulta[oConsulta:nAt,03]}}

   ACTIVATE MSDIALOG oDlgConsulta CENTERED 
   
Return(.T.)

// ######################################################
// Função que seleciona o a base instalada selecionada ##
// ######################################################
Static Function SELPRODUTO(kProduto, kDescricao, kSerie)

   cProduto := kProduto
   cNomePro := kDescricao
   cSerie   := kSerie
   
   oDlgConsulta:End()
   
Return(.T.)

// ############################################################################################
// Função que verifica e o número de série informado pertence a base de instalada do cliente ##
// ############################################################################################
Static Function VERSERIE()

   If Empty(Alltrim(cProduto))
      MsgAlert("Produto não informado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cSerie))
      MsgAlert("Nº de série não informado. Verifique!")
      Return(.T.)
   Endif
   
   If Select("T_EQUIPAMENTOS") > 0
      T_EQUIPAMENTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT AA3.AA3_FILIAL,"
   cSql += "       AA3.AA3_CODCLI,"
   cSql += "       AA3.AA3_LOJA  ,"
   cSql += "       AA3.AA3_CODPRO,"
   cSql += "       SB1.B1_DESC + ' ' + SB1.B1_DAUX AS DESCRICAO,"
   cSql += "       AA3.AA3_NUMSER"
   cSql += "  FROM " + RetSqlName("AA3") + " AA3, "                
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE AA3.AA3_FILIAL = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND AA3.AA3_CODCLI = '" + Alltrim(cCliente) + "'"
   cSql += "   AND AA3.AA3_LOJA   = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND AA3.D_E_L_E_T_ = ''"
   cSql += "   AND AA3.AA3_CODPRO = '" + Alltrim(cProduto) + "'"
   cSql += "   AND AA3.AA3_NUMSER = '" + Alltrim(cSerie)   + "'"
   cSql += "   AND SB1.B1_COD     = AA3.AA3_CODPRO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EQUIPAMENTOS", .T., .T. )
   
   If T_EQUIPAMENTOS->( EOF() )
      MsgAlert("Nº de Série não pertence a base instalada para este Cliente. Verifique!")
      cSerie := Space(30)
      oGet3:Refresh()
      Return(.T.)
   Endif   
        
Return(.T.)

// ###################################################
// Função que salva o produto/equipamento informado ##
// ###################################################
Static Function SALVAEQUI(kTipo)

   Local cSql      := ""
   Local cExcluir  := oBrowse:nAt
   Local aTransito := {}

   If Empty(Alltrim(cProduto))
      MsgAlert("Produto/Equipamento não informado. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cSerie))
      MsgAlert("Nº de Série Produto/Equipamento não informado. Verifique!")
      Return(.T.)
   Endif

   If Substr(cComboBx100,01,06) == "000000"
      MsgAlert("Ocorrência não selecionada. Verifique!")
      Return(.T.)
   Endif

   If Len(aBrowse) == 1
      If Empty(Alltrim(aBrowse[01,01]))
         aBrowse := {}
      Endif
   Endif
      
   // #####################################
   // Pesquisa a garantia do nº de série ##
   // #####################################
   If Select("T_GARANTIA") > 0
      T_GARANTIA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA3.AA3_DTGAR"
   cSql += "  FROM " + RetSqlName("AA3") + " AA3 "                
   cSql += " WHERE AA3.AA3_FILIAL = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND AA3.AA3_CODCLI = '" + Alltrim(cCliente) + "'"
   cSql += "   AND AA3.AA3_LOJA   = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND AA3.AA3_CODPRO = '" + Alltrim(cProduto) + "'"
   cSql += "   AND AA3.AA3_NUMSER = '" + Alltrim(cSerie)   + "'"
   cSql += "   AND AA3.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GARANTIA", .T., .T. )

   kGarantia := Substr(T_GARANTIA->AA3_DTGAR,07,02) + "/" + Substr(T_GARANTIA->AA3_DTGAR,05,02) + "/" + Substr(T_GARANTIA->AA3_DTGAR,01,04)

   Do Case

      // ###########
      // Inclusão ##
      // ###########
      Case kTipo == "I"

           aAdd ( aBrowse, { cProduto                  ,;
                             cSerie                    ,;
                             cNomePro                  ,;
                             Substr(cComboBx100,01,06) ,;
                             cOcorrencia               ,;
                             kGarantia                 ,;
                             ""                        })
                             
      // ############
      // Alteração ##
      // ############
      Case kTipo == "A"

           aBrowse[oBrowse:nAt,01] := cProduto
           aBrowse[oBrowse:nAt,02] := cSerie
           aBrowse[oBrowse:nAt,03] := cNomePro
           aBrowse[oBrowse:nAt,04] := Substr(cComboBx100,01,06)
           aBrowse[oBrowse:nAt,05] := cOcorrencia
           aBrowse[oBrowse:nAt,06] := kGarantia
           aBrowse[oBrowse:nAt,07] := ""
      
      // ###########
      // Exclusão ##
      // ###########
      Case kTipo == "E"

           For nContar = 1 to Len(aBrowse)
           
               If cExcluir == nContar
                  Loop
               Endif
               
               aAdd( aTransito, {aBrowse[nContar,01],;
                                 aBrowse[nContar,02],;
                                 aBrowse[nContar,03],;
                                 aBrowse[nContar,04],;
                                 aBrowse[nContar,05],;
                                 aBrowse[nContar,06],;
                                 aBrowse[nContar,07]})
                                 
           Next nContar
            
           aBrowse := {}
            
           For nContar = 1 to Len(aTransito)
                                                   
              aAdd( aBrowse, {aTransito[nContar,01],;
                              aTransito[nContar,02],;
                              aTransito[nContar,03],;
                              aTransito[nContar,04],;
                              aTransito[nContar,05],;
                              aTransito[nContar,06],;
                              aTransito[nContar,07]})
                               
           Next nContar
            
   EndCase            
   
   oDlgPro:End()

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "" })
   Endif   

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07]}}

Return(.T.)

// #########################################################
// Função Gera as Ordens de Serviços conforme informações ##
// #########################################################
Static Function GERAOSERVICO()

   Local nContar := 0

   Local aCabec   := {}
   Local aItem    := {}
   Local aItens   := {}
   Local aApont   := {}
   Local aAponts  := {}
   Local cNumOS   := ""

   Private lMsErroAuto := .F.

   If Empty(Alltrim(cCliente))
      MsgAlert("Cliente não informado. Verifique!")
      Return(.T.)
   Endif
       
   If Empty(Alltrim(cLoja))
      MsgAlert("Cliente não informado. Verifique!")
      Return(.T.)
   Endif

   If cComboBx3 == "SELECIONE"
      MsgAlert("Fabricante não selecionado. Verifique!")
      Return(.T.)
   Endif
     
   If Empty(Alltrim(cCondicao))
      MsgAlert("Condição de Pagamento não informado. Verifique!")
      Return(.T.)
   Endif

   If cComboBx4 == "SELECIONE"
      MsgAlert("Posição não selecionada. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cAprovada))
      MsgAlert("Aprovada não informada. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTabela))
      MsgAlert("Tabela de Preço não informada. Verifique!")
      Return(.T.)
   Endif

   If cMoeda == 0
      MsgAlert("Moeda não informada. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cComboBx5))
      MsgAlert("Contato do oCliente não selecionado. Verifique!")
      Return(.T.)
   Endif
   
// If Empty(Alltrim(cEntrada))
//    MsgAlert("Nº nota fiscal de entrada não informada. Verifique!")
//    Return(.T.)
// Endif

   If Len(aBrowse) == 1
      If Empty(Alltrim(aBrowse[01,01]))
         MsgAlert("Nenhum Produto/Equipamento informado para abertura das OS's. Verifique!")
         Return(.T.)
      Endif
   Endif   
      
   For nContar = 1 to Len(aBrowse)
   
       // #################################################
       // Pesquisa o próximo número para inclusão das OS ##
       // #################################################

       BEGIN TRANSACTION  

 	      cNumOS := GetSXENum("AB6","AB6_NUMOS")	
          ConfirmSX8()

          // ########################################################################################
          // Carrega o nº da Ordem de Serviço no array aBrowse para ser utilizda nos sub processos ##
          // ########################################################################################
          aBrowse[nContar,07] := cNumOS

          // ########################################################
          // Pesquisa o próximo código para inclusão da tabela SYP ##
          // ########################################################
          cPrxSyp := GetSXENum("SYP","SY_CHAVE")
          ConfirmSX8()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "001"
          SYP->YP_TEXTO := Alltrim(aBrowse[oBrowse:nAt,05])
          SYP->YP_CAMPO := "AB7_MEMO1"
      	  MsUnlock()

          // #########################################
          // Inclui o cabeçalho da Ordem de Serviço ##
          // #########################################
          DbSelectArea("AB6")
          DbSetOrder(1)
          RecLock("AB6",.T.)
  	      AB6->AB6_FILIAL := cFilAnt                 
  	      AB6->AB6_NUMOS  := cNumOS                  
          AB6->AB6_ETIQUE := STRZERO(INT(VAL(cNumOS)),8)
          AB6->AB6_STATUS := "A"
  	      AB6->AB6_CODCLI := cCliente                
  	      AB6->AB6_LOJA   := cLoja                   
	      AB6->AB6_EMISSA := dDataBase               
	      AB6->AB6_ATEND  := cUserName               
	      AB6->AB6_CONPAG := cCondicao               
	      AB6->AB6_HORA   := Time()                  
	      AB6->AB6_FABR   := cComboBx3               
	      AB6->AB6_POSI   := cComboBx4               
	      AB6->AB6_APROV  := cAprovada               
	      AB6->AB6_TABELA := cTabela                 
	      AB6->AB6_MOEDA  := cMoeda                  
	      AB6->AB6_CONTWF := Substr(cComboBx5,01,06) 
	      AB6->AB6_NFENT  := cEntrada                
          MsUnLock()              

          // #######################################
          // Inclui o produto da Ordem de Serviço ##
          // #######################################
          DbSelectArea("AB7")
          DbSetOrder(1)
          RecLock("AB7",.T.)
  	      AB7->AB7_FILIAL := cFilAnt                  
  	      AB7->AB7_NUMOS  := cNumOS                   
 	      AB7->AB7_ITEM   := "01"                     
 	      AB7->AB7_TIPO   := "1"                      
	      AB7->AB7_CODPRO := aBrowse[nContar,01]      
	      AB7->AB7_NUMSER := aBrowse[nContar,02]      
	      AB7->AB7_CODPRB := aBrowse[nContar,04]      
 	      AB7->AB7_MEMO1  := cPrxSyp
 	      AB7->AB7_CODFAB := Posicione( "SB1", 1, xFilial("SB1") + aBrowse[nContar,04], "B1_PROC"    )
	      AB7->AB7_LOJAFA := Posicione( "SB1", 1, xFilial("SB1") + aBrowse[nContar,04], "B1_LOJPROC" )
	      AB7->AB7_CODCLI := cCliente                 
	      AB7->AB7_LOJA   := cLoja                    
	      AB7->AB7_EMISSA := dDataBase                
	      AB7->AB7_CODCON := Substr(cComboBx5,01,06)  
	      AB7->AB7_GARAN  := Ctod(aBrowse[nContar,06])
          MsUnLock()              

          // ##################################################################
          // Confirma o número alocado através do último comando GETSXENUM() ##
          // ##################################################################
          ConfirmSX8(.T.)

       END TRANSACTION

   Next nContar	   

   // #########################################
   // Verifica se houve geração de alguma OS ##
   // #########################################
   lTemOs := .F.
   For nContar = 1 to Len(aBrowse)
       If Empty(Alltrim(aBrowse[nContar,07]))
       Else
          lTemOs := .T.
          Exit
       Endif
   Next nContar       

   // ##################################################################################
   // Solicita se deseja enviar o e-mail de abertura das ordens de serviço ao Cliente ##
   // ##################################################################################
   If lTemOs := .T.
      If MsgYesNo("Deseja enviar e-mail(s) de abertura da O.S. para o cliente?")      
         EnviaOSCli()
      Endif
   Endif
	   
   // ##############################################################
   // Solicita se deseja imprimir o comprovante de entrega das os ##
   // ##############################################################
   If lTemOs := .T.
      If MsgYesNo("Deseja imprimir o(s) comprovante de Entrega do(s) Equipamento(s)?")      
         CompEntrega()
      Endif   
   Endif   

   // #############################################################################
   // Solicita se deseja imprimir as etiquetas de identificação dos equipamentos ##
   // #############################################################################
   If lTemOs := .T.
      If MsgYesNo("Deseja imprimir a(s) etiquetas de identificação do(s) Equipamento(s)?")      
         EtqCompEntrega()
      Endif   
   Endif   

Return(.T.)

// ####################################################################
// Função que envia e-mail para o cliente informado a abertura da OS ##
// ####################################################################
Static Function EnviaOSCli()

   Local nContar    := 0
   Local aProduto   := 	{}
   Local nX         := 0
   Local nValRepova := 0
	                                                                                               
   // ####################################################
   // Pesquisa o e-mail do Contato para envio do e-mail ##
   // ####################################################
   _Email   := AllTrim(Posicione('SU5',1, xFilial('SU5') + Substr(cComboBx5,01,06),'U5_EMAIL')) 
   kNomeCli := AllTrim(Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja        ,"A1_NOME" ))

   For nContar = 1 to Len(aBrowse)

       cDescProd :=	AllTrim(Posicione('SB1',1,xFilial('SB1') + aBrowse[nContar,01],'B1_DESC'))
	   cDAux 	 :=	AllTrim(Posicione('SB1',1,xFilial('SB1') + aBrowse[nContar,01],'B1_DAUX'))
	   cDescProd :=	cDescProd + IIF(!Empty(cDAux), + cDAux, '')
		
	   Aadd(aProduto, { aBrowse[nContar,01], cDescProd, aBrowse[nContar,02] } )

       // ######################
       // Cabeçalho do e-mail ##
       // ######################
       cHtml := '<html>'
       cHtml += '<head>'
       cHtml += '<h3 align = Left><font size="3" color="#0000FF" face="Verdana"> ABERTURA ORDEM DE SERVICO</h3></font>'
       cHtml += '<br></br>'
       cHtml += '<br></br>'                          
       cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">Prezado(a) </h3></font>'
       cHtml += '<br></br>' 
       cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">' + aBrowse[nContar,07] + '</h3></font>'
       cHtml += '<br></br>'
       cHtml += '<br></br>'

       cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">Informamos que foi aberta a Ordem de Servico na ' + aBrowse[nContar,07] + ' </h3></font>'
       cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">para o(s) equipamento(s):</h3></font>'
       cHtml += '</head>'
       cHtml += '<br></br>'
       cHtml += '<br></br>'

       // ####################
       // Cabeçalho do grid ##
       // ####################
       cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#CCCCCC" BGCOLOR=#EEE9E9 CELLPADDING=2 CELLSPACING=0 STYLE="page-break-before: always">'
       cHtml += '	<TR ALIGN=TOP>'
       cHtml += '		<TD ALIGN=LEFT WIDTH=60 >'
       cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>PRODUTO</P></font>'
       cHtml += '		</TD>'
       cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>DESCRIÇÃO</P></font>'
       cHtml += '		</TD>'
       cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>NUM.SERIE</P></font>'
       cHtml += '		</TD>'
       cHtml += '	</TR>'

       // Aadd(aProduto, { AllTrim(AB7->AB7_CODPRB) , AllTrim(AB7->AB7_DESCPR)+IIF(!Empty(cDAux), +cDAux, ''), AB7->AB7_NUMSER } )
	   cHtml += '<TR ALIGN=TOP>'
	   cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
	   cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+ aBrowse[nContar,01] +'</P></font>'
	   cHtml += '		</TD>'
	   cHtml += '		<TD ALIGN=LEFT bgcolor=#FFFFFF>'
	   cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+ aBrowse[nContar,03]+'</P></font>'
	   cHtml += '		</TD>'
	   cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
	   cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+ aBrowse[nContar,02]+'</P></font>'
	   cHtml += '		</TD>'
	   cHtml += '</TR>'	

       cHtml 	+= '</TABLE>'
       cHtml	+= '<br></br>'
       cHtml	+= '<br></br>' 

       // ######################################################################################################
       // Tarefa #3685 - Retirar observação de cobraça da tarefa de reprovação para Empresa 02 - TI Automação ##
       // ######################################################################################################
       If cEmpAnt == "02"
       Else

         If aBrowse[nContar,04]$("000028#000038#000002")
         Else

            // ############################################################################################
            // Pesquisa no parametrizador o valor a ser cobrado em caso de reprovação do orçamento da OS ##
            // ############################################################################################
            If Select("T_REPROVA") > 0
               T_REPROVA->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT ZZ4_TREP FROM " + RetSqlName("ZZ4")
   
            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REPROVA", .T., .T. )

            For xPreco = 1 to U_P_OCCURS(T_REPROVA->ZZ4_TREP, "#", 1)
      
                xSepara := U_P_CORTA(T_REPROVA->ZZ4_TREP, "#", xPreco)
          
                If Substr(U_P_CORTA(xSepara,"|",1),01,02) == cEmpAnt
                   If Substr(U_P_CORTA(xSepara,"|",2),01,02) == cFilAnt
                      nValReprova := VAL(U_P_CORTA(xSepara,"|",3))
                      Exit
                   Endif
                Endif      
                    
            Next xPreco
                  
            If nValReprova == 0
            Else
               cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">Obs.: Caso o Orçamento enviado venha a nao ser aprovado, informamos que podera </h3></font>'
               cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">ocorrer uma cobranca de uma taxa de reprovacao no valor de R$ ' + Transform(nValReprova, "@E 9999999.99") + ' decorrente do </h3></font>'
               cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">tempo de analise do tecnico.</h3></font>'
            Endif
            
         Endif   

       Endif

       cHtml	+= '<br></br>'
       cHtml	+= '<br></br>'
       cHtml 	+= '<P STYLE="margin-bottom: 0cm"><BR></P>'
       cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> Att. </font></b>'
       cHtml	+= '<br></br>'
       cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> Automatech Sistemas de Automação Ltda </font></b>'
       cHtml	+= '<br></br>'
       cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> Fone: (51) - 3017-8300 </font></b>'
       cHtml	+= '<br></br>'
       cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> www.automatech.com.br </font></b>'
       cHtml	+= '<br></br>'
       cHtml	+= '<br></br>'
       cHtml 	+= '<b><font size="1" color=#696969 face="Verdana"> E-mail enviado automaticamente, nao responda este e-mail </font></b>'
       cHtml	+= '<br></br>'
       cHtml	+= '<br></br>'
       cHtml 	+= '</head>'
       cHtml 	+= '</html>'
   
       // ###############################
       // Envia o relatorio via e-mail ##
       // ###############################
       MemoWrit(GetTempPath() + 'EMAIL_PE_TECA460.html', cHtml)
       cErroEnvio := U_AUTOMR20(cHtml, Alltrim(_Email), "", "Aviso de Abertura da Ordem de Servico - Automatech.")

       If Empty(cErroEnvio)
	  
	      // ###############################
	      // GRAVA DATA DE ENVIO DO EMAIL ##
	      // ###############################
	      /*
	      DbSelectArea('AB9')
	      RecLock("AB9",.F.)
	      AB9->AB9_ENVIOA := Date()
	      MsUnlock()
	      */

       EndIf

   Next nContar
   
Return(.T.)

// #############################################################
// Função que imprime o comprovante de entrega do equipamento ##
// #############################################################
Static Function CompEntrega()

   Local cSql    := ""
   Local nContar := 0

   // #####################################################
   // Pesquisa os dados da Etiqueta passada no parâmetro ##
   // #####################################################
   For nContar = 1 to Len(aBrowse)

       If Empty(Alltrim(aBrowse[nContar,07]))
          Loop
       Endif   

       If Select("SQL") > 0
          SQL->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT " + CHR(13)
       cSql += "       A.AB6_NUMOS ," + CHR(13)
       cSql += "       A.AB6_CODCLI," + CHR(13)
       cSql += "       A.AB6_LOJA  ," + CHR(13)
       cSql += "       B.A1_NOME   ," + CHR(13)
       cSql += "       C.AB7_CODPRO," + CHR(13)
       cSql += "       C.AB7_NUMSER," + CHR(13)
       cSql += "       C.AB7_MEMO1 ," + CHR(13)
       cSql += "       D.B1_DESC    " + CHR(13)
       cSql += "  FROM " + RetSqlName("AB6") + " A, " + CHR(13)
       cSql += "       " + RetSqlName("SA1") + " B, " + CHR(13)
       cSql += "       " + RetSqlName("AB7") + " C, " + CHR(13)
       cSql += "       " + RetSqlName("SB1") + " D  " + CHR(13)
       cSql += " WHERE A.AB6_FILIAL   = '" + XFILIAL("AB6")    + "'" + CHR(13)
       cSql += "   AND A.AB6_NUMOS    = '" + Alltrim(aBrowse[nContar,07]) + "'" + CHR(13)
       cSql += "   AND A.R_E_C_D_E_L_ = ''"           + CHR(13)
       cSql += "   AND A.AB6_NUMOS    = C.AB7_NUMOS " + CHR(13)
       cSql += "   AND A.AB6_FILIAL   = C.AB7_FILIAL" + CHR(13)
       cSql += "   AND C.R_E_C_D_E_L_ = ''"           + CHR(13)
       cSql += "   AND A.AB6_CODCLI   = B.A1_COD "    + CHR(13)
       cSql += "   AND A.AB6_LOJA     = B.A1_LOJA"    + CHR(13)    
       cSql  += "   AND C.AB7_CODPRO   = D.B1_COD "    + CHR(13)

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "SQL", .T., .T. )
 
       oPrint := TMSPrinter():New()
	   oPrint:SetPaperSize(9)
	   oPrint:SetPortrait()
	   oPrint:StartPage()

	   // ###########################################################################
	   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio ##
	   // ###########################################################################
	   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	   oFont09n  := TFont():New( "Arial",, 9,.T.,.T.,5,.T.,5,.T.,.F.)
	   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	   oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	   oFont11   := TFont():New( "Arial",,11,.T.,.F.,5,.T.,5,.T.,.F.)
	   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	   oFont12n  := TFont():New( "Arial",,12,.T.,.T.,5,.T.,5,.T.,.F.)
	   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	   oFont25   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	   oFont25b  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	   oFont30   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )
	   oFont50   := TFont():New( "FREE309",,12,,.t.,,,,.f.,.f. )

       _nLin := 0010

       _nLin := _nLin + 10
	
       // #####################################
       // Logotipo e identificação do pedido ##
       // #####################################
       oPrint:SayBitmap( _nLin, 0010, "logoautoma.bmp", 0700, 0200 )

       _nLin := _nLin + 230

       If cEmpAnt == "01"
          oPrint:Say( _nLin, 0010, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09b  )
       Endif   

       If cEmpAnt == "02"
          oPrint:Say( _nLin, 0010, "TI AUTOMAÇÃO E SERVIÇOS LTDA", oFont09b  )
       Endif   

       _nLin := _nLin + 50

       // ###################################
       // Grupo de Empresa 01 - Automatech ##
       // ###################################
       If cEmpAnt == "01"
          Do Case
             Case cFilAnt == "01"
                  oPrint:Say( _nLin, 0010, "RUA DR. JOAO INÁCIO, 1110 - CEP: 90.230-181", oFont09b  )
                  _nLin := _nLin + 50
                  oPrint:Say( _nLin, 0010, "FONE: (51)-3017-8300 - PORTO ALEGRE - RS", oFont09b  )
                  _nLin := _nLin + 50
                  oPrint:Say( _nLin, 0010, "CNPJ: 03.385.913/0001-61   IE: 096/2777447", oFont09b  )
                  _nLin := _nLin + 50
             Case cFilAnt == "02"
                  oPrint:Say( _nLin, 0010, "RUA SÃO JOSÉ, 1767 - CEP: 95.030-270", oFont09b  )
                  _nLin := _nLin + 50
                  oPrint:Say( _nLin, 0010, "FONE: (54)-3227-2333 - CAXIAS DO SUL - RS", oFont09b  )
                  _nLin := _nLin + 50
                  oPrint:Say( _nLin, 0010, "CNPJ: 03.385.913/0002-42   IE: 029/0448913", oFont09b  )
                  _nLin := _nLin + 50
             Case cFilAnt == "03"
                  oPrint:Say( _nLin, 0010, "RUA GENERAL NETO, 618 - CEP: 96.015-280", oFont09b  )
                  _nLin := _nLin + 50
                  oPrint:Say( _nLin, 0010, "FONE: (53)-3026-2802 - PELOTAS - RS", oFont09b  )
                  _nLin := _nLin + 50
                  oPrint:Say( _nLin, 0010, "CNPJ: 03.385.913/0004-04   IE: 093/0410289", oFont09b  )
                  _nLin := _nLin + 50
          EndCase

       Endif
       
       // #####################################
       // Grupo de Empresa 02 - TI Automação ##
       // #####################################
       If cEmpAnt == "02"
          oPrint:Say( _nLin, 0010, "RUA TEN.FRANCISCO FERREIRA DE SOUZA, 1052", oFont09b  )
          _nLin := _nLin + 50
          oPrint:Say( _nLin, 0010, "FONE: (41)-3024-6675 - CURITIBA - RS", oFont09b  )
          _nLin := _nLin + 50
          oPrint:Say( _nLin, 0010, "CNPJ: 12.757.071/0001-12   IE: 9053742146", oFont09b  )
          _nLin := _nLin + 50
       Endif

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, Dtoc(Date()) + " - " + Time(), oFont09  )
       oPrint:Say( _nLin, 0550, "NUM.OS "+ AllTrim(SQL->AB6_NUMOS) , oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )

       _nLin := _nLin + 50
       
       oPrint:Say( _nLin, 0030, "COMPROVANTE RECEBIMENTO EQUIPAMENTO", oFont09b  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "Recebemos de:", oFont09  )
       _nLin := _nLin + 50
     
       oPrint:Say( _nLin, 0010, Alltrim(SQL->A1_NOME), oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, "o equipamento abaixo discriminado:", oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, Alltrim(SQL->B1_DESC), oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, "Nº de Série: " + Alltrim(SQL->AB7_NUMSER), oFont09  )
       _nLin := _nLin + 100       

       oPrint:Say( _nLin, 0010, "---------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0200, "COMENTÁRIOS/ACESSORIOS", oFont09b  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              

       // ##########################################
       // Imprime o comentario do Chamado Técnico ##
       // ##########################################
       If Select("T_ACESSORIOS") > 0
          T_ACESSORIOS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT YP_TEXTO" 
       cSql += "  FROM " + RetSqlName("SYP")
       cSql += " WHERE YP_FILIAL  = ''"
       cSql += "   AND YP_CHAVE   = '" + Alltrim(SQL->AB7_MEMO1) + "'"
       cSql += "   AND YP_CAMPO   = 'AB7_MEMO1'
       cSql += "   AND YP_TEXTO  <> '\13\10'
       cSql += "   AND D_E_L_E_T_ = ''
       cSql += " ORDER BY YP_SEQ
 
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSORIOS", .T., .T. )

       cTexto := ""

       WHILE !T_ACESSORIOS->( EOF() )
          oPrint:Say( _nLin, 0010, StrTran(T_ACESSORIOS->YP_TEXTO, "\13\10", ""), oFont09  )                       
          _nLin := _nLin + 50   
          T_ACESSORIOS->( DbSkip() )
       ENDDO
          
       // ###############################################################################
       // Imprime a observação que será cobrado valor se ordem de serviço não aprovada ##
       // ###############################################################################
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0300, "OBSERVAÇÃO", oFont09b  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "Caso esta Ordem de Serviço venha a não ser aprova-", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "da, informamos que porderá ocorrer uma cobrança de", oFont09  )
       _nLin := _nLin + 50              

       If cFilAnt == "05"
          oPrint:Say( _nLin, 0010, "uma taxa de reprovação no valor de R$ 90,00 decor-", oFont09  )
       Else   
          oPrint:Say( _nLin, 0010, "uma taxa de reprovação no valor de R$ 75,00 decor-", oFont09  )
       Endif
       
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "rente do tempo de análise do técnico.             ", oFont09  )
       
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "Eu, em nome de", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, Alltrim(SQL->A1_NOME), oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "declaro que entreguei o equipamento do nº de serie", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "acima  mencionado  para conserto, e concordo com", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "o descritivo constante neste Comprovante.", oFont09  )
       _nLin := _nLin + 150              

       Do Case
          Case cEmpAnt == "01"
               oPrint:Say( _nLin, 0010, "Porto Alegre, " + Dtoc(Date()), oFont09  )
          Case cEmpAnt == "02"
               oPrint:Say( _nLin, 0010, "Caxias do Sul, " + Dtoc(Date()), oFont09  )
          Case cEmpAnt == "03"
               oPrint:Say( _nLin, 0010, "Pelotas, " + Dtoc(Date()), oFont09  )
          Case cEmpAnt == "05"
               oPrint:Say( _nLin, 0010, "São Paulo, " + Dtoc(Date()), oFont09  )
       EndCase               
               
       _nLin := _nLin + 200              
       oPrint:Say( _nLin, 0010, "---------------------------------------     ----------------------------------", oFont09  )
       _nLin := _nLin + 50                     
       oPrint:Say( _nLin, 0010, "Assinatura do Cliente          CPF/RG", oFont09  )
       _nLin := _nLin + 100                     
       oPrint:Say( _nLin, 0010, "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ", oFont09  )
       
       oPrint:Preview()

	   DbCommitAll()
  	   MS_FLUSH()
  	    
   Next nContar  	    

Return(.T.)

// ####################################################################
// Função que imprime as etiquetas de identificação dos equiapmentos ##
// ####################################################################
Static Function EtqCompEntrega()
 
   Local oGet1
   Local _aArea   		:= {}
   Local _aAlias  		:= {}
   
   Private aComboBx1 := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cComboBx1
   Private nGet1	 := space(4)

   Private oDlgXX

   DEFINE MSDIALOG oDlgXX TITLE "Automatech - Impressão de Etiqueta Chamado Tecnico" FROM C(178),C(181) TO C(350),C(450) PIXEL

   @ C(010),C(030) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(030),C(030) Say "Porta:"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   
   @ C(010),C(080) MsGet    oGet1     Var   nGet1     Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(030),C(050) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010)                              PIXEL OF oDlgXX
		                        
   DEFINE SBUTTON FROM C(50),C(080) TYPE 6  ENABLE OF oDlg  ACTION( KAUTRE03A(nGet1,cCombobx1)  )
   DEFINE SBUTTON FROM C(50),C(020) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlgXX CENTERED  

Return(.T.)

// ################################
// Função que imprime a etiqueta ##
// ################################
Static Function KAUTRE03A(nGet1,cPorta)

   Local nContar := 0
   Local cPorta  := cPorta
   Local nQtetq  := val(nGet1)
       
   For nContar = 1 to Len(aBrowse)

       If Empty(Alltrim(aBrowse[nContar,07]))
          Loop
       Endif   
 
       //  Jean Rehermann - Solutio IT - 02/06/2015 - Alterado para atender tarefa #9747 do portfólio
       // cCodcli := alltrim(Posicione("SA1",1,xFilial("SA1")+M->AB6_CODCLI+M->AB6_LOJA,"A1_NOME"))
       // cCodBar := AllTrim(M->AB6_NUMOS)
   	   // cDataem := dtoc(M->AB6_EMISSA)
   	   cCodcli := alltrim(Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja, "A1_NOME"))
   	   cCodBar := AllTrim(aBrowse[nContar,07])
   	   cDataem := dtoc(Date())
   	   cCodpro := aBrowse[nContar,01]
   	   cEquipo := aBrowse[nContar,03]
     
       For nEt := 1 to nQtetq 

           MSCBPRINTER("DATAMAX",cPorta)
           MSCBCHKSTATUS(.F.)
           MSCBBEGIN(2,6,) 
           MSCBWRITE(chr(002)+'L'+chr(13))  //inicio da progrmação
           MSCBWRITE('H15'+chr(13))
           MSCBWRITE('D11'+chr(13))
 
           // ####################################################################################
           // cOri 	:= "1"                                                                      ##
           // cFont:= "4" //"2"                                                                 ##
           // cLar	:= "1" //"3"                                                                ##
           // cAlt:= "0"                                                                        ##
           // cZero:= "000"                                                                     ##
           // cLin	:= "0310"                                                                   ##
           // cCol	:= "0030"                                                                   ##
           // cTexto:=cNomeCli                                                                  ##
           // cLinha	:= cOri + cFont + cLar + cAlt + cZero + cLin + cCol  + cTexto + chr(13) ##
           // ####################################################################################

           MSCBWRITE("191100100650010CLIENTE:"     + chr(13))
           MSCBWRITE("191100200650060"             + cCliente + chr(13))
           MSCBWRITE("191100100850010O.S.:"        + chr(13))
           MSCBWRITE("191100600800040"             + Alltrim(aBrowse[nContar,07]) + chr(13))
           MSCBWRITE("191100100400010EQUIPAMENTO:" + chr(13))
           MSCBWRITE("191100200400080"             + cEquipo+ chr(13))
           MSCBWRITE("191100100850150DATA:"        + chr(13))
           MSCBWRITE("191100400850180"             + Alltrim(cDataem)+ chr(13))
           MSCBWRITE("1a6302500070030"             + cCodBar+ chr(13))
           MSCBWRITE("Q0001"                       + chr(13))
           MSCBWRITE(chr(002)+"E"                  + chr(13))
           MSCBEND()
           MSCBCLOSEPRINTER()
                            
       Next nEtq
   
   Next nContar
   
Return(.T.)