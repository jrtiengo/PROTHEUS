#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM593.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 10/07/2017                                                          ##
// Objetivo..: Programa que mostra produtos diferente de RunRate e que tenham sua  ##
//             última entrada entre um range de dias.                              ##
// ##################################################################################

User Function AUTOM593()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aConsolida := {"S-Sim", "N-Não"} 
   Private aEmpresas  := U_AUTOM539(1, "")      
   Private aFiliais   := U_AUTOM539(2, cEmpAnt) 
   Private cDias01	  := 7
   Private cDias02	  := 30
   Private cFiltro    := Space(200)

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg

   Private aBrowse := {}
   Private aLista  := {}

   Private oBrowse
   Private oLista

   U_AUTOM628("AUTOM593")

   _RunRate := .T.

   // ##############################################
   // Pesquisa os parâmetros de range de pesquisa ##
   // ##############################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL, "
   cSql += "       ZZ4_RK01  , "
   cSql += "       ZZ4_RK02  , "
   cSql += "       ZZ4_RELI    "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      cDias01 := 7
      cDias02 := 30
      cFiltro := ""
   Else
      cDias01 := T_PARAMETROS->ZZ4_RK01
      cDias02 := T_PARAMETROS->ZZ4_RK02
      cFiltro := T_PARAMETROS->ZZ4_RELI
   Endif

   // ############################################################
   // Somente poderá ser executado pelo Administrador e Evandro ##
   // ############################################################
   If Alltrim(Upper(cUserName))$("ADMINISTRADOR#EVANDRO")
   Else
      Return .T.
   Endif

   // ###########################################################################
   // Envia para a função que pesquisa os produtos para popular o grid aBrowse ##
   // ###########################################################################
   PesqRunRate(0)
   
   If Empty(Alltrim(aBrowse[01,01]))
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlg TITLE "Análise de Estoque para Produtos com Tipo Diferente de R (RunRate)" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(059),C(002) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Consolidado"                                             Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(042) Say "Empresas"                                                Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(119) Say "Filiais"                                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(197) Say "Última Entrada (Em Dias)"                                Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(064),C(005) Say "Produtos com tipo diferente de R (RunRate)"              Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(035),C(263) Say "Desconsiderar produtos que iniciem com (separar com | )" Size C(127),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) ComboBox cComboBx3 Items aConsolida Size C(032),C(010)                                 PIXEL OF oDlg
   @ C(044),C(042) ComboBox cComboBx1 Items aEmpresas  Size C(072),C(010)                                 PIXEL OF oDlg ON CHANGE ALTERACOMBO() When Substr(cComboBx3,01,01) == "N"
   @ C(044),C(119) ComboBox cComboBx2 Items aFiliais   Size C(072),C(010)                                 PIXEL OF oDlg When Substr(cComboBx3,01,01) == "N"
   @ C(044),C(206) MsGet    oGet1     Var   cDias01    Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlg
   @ C(044),C(238) MsGet    oGet2     Var   cDias02    Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlg
// @ C(044),C(263) MsGet    oGet3     Var   cFiltro    Size C(146),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg

   @ C(044),C(461) Button "Pesquisar"           Size C(037),C(010) PIXEL OF oDlg ACTION( PesqRunRate(1) ) 
   @ C(210),C(005) Button "Visualizar Saldos"   Size C(060),C(012) PIXEL OF oDlg ACTION( xSaldoProd(aBrowse[oBrowse:nAt,05]) )
   @ C(210),C(068) Button "Gera Consulta (CSV)" Size C(065),C(012) PIXEL OF oDlg ACTION( xGeraCSV() ) 
   @ C(210),C(461) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 092 , 005, 633, 170,,{'Empresa'                ,; // 01 
                                                    'Filial'                 ,; // 02
                                                    'Última Entrada'         ,; // 03
                                                    'Dias'                   ,; // 04
                                                    'Produto'                ,; // 05
                                                    'PartNumber'             ,; // 06
                                                    'Grupo'                  ,; // 07
                                                    'Descrição dos Produtos' ,; // 08
                                                    'Saldo'                  ,; // 09
                                                    'Custo Médio'           },; // 10
                                                    {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10]} }

   oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################
// Função que Ordena a coluna selecionada no grid ##
// #################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays

Return(_aOrdena)

// ##########################################################################
// Função que pesquisa o saldo do produto ou componente conforme parâmetro ##
// ##########################################################################
Static Function xSaldoProd(_Produto)

   If Empty(Alltrim(_Produto))
      MsgAlert("Produto a ser pesquisado inexistente.")
      Return(.T.)
   Endif

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

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(044),C(119) ComboBox cComboBx2 Items aFiliais Size C(072),C(010) PIXEL OF oDlg
   
Return(.T.)

// ##############################################################
// Função que realiza a pesquisa dos dados para popular o grid ##
// ##############################################################
Static Function PesqRunRate(kTipo)

   Local cSql := ""

   If kTipo = 00
      TipoPesquisa := "S"
   Else
      TipoPesquisa := Substr(cComboBx3,01,01)
   Endif   

   aBrowse := {}

   If TipoPesquisa == "N"
 
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""	
      cSql := "SELECT '" + Substr(cComboBx1,01,02) + "' AS EMPRESA,"
      cSql += "       SD1.D1_FILIAL  ,"
      cSql += "       SD1.D1_COD     ,"
      cSql += "       SB1.B1_PARNUM  ,"
      cSql += "       SB1.B1_DESC + '' + SB1.B1_DAUX AS DESCRICAO,"
      cSql += "       SB1.B1_GRUPO   ,"
      cSql += "       SD1.D1_EMISSAO,"
      cSql += "       CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) AS DIAS,"
      cSql += "	   SB2.B2_QATU  ,"
      cSql += "	   SB2.B2_CM1    "
      cSql += "  FROM SD1" + Substr(cComboBx1,01,02) + "0" + " SD1, "
      cSql += "          " + RetSqlName("SB1") + " SB1, "
      cSql += "       SB2" + Substr(cComboBx1,01,02) + "0" + " SB2  "
      cSql += " WHERE SD1.D1_FILIAL = '" + Substr(cComboBx2,01,02) + "'"
      cSql += "   AND CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) >= " + Alltrim(str(cDias01)) 
      cSql += "   AND CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) <= " + Alltrim(str(cDias02)) 
      cSql += "   AND SD1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SD1.D1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_ZAPR   <> 'R'" 
      cSql += "   AND SB1.B1_GRUPO >= '0100'"
      cSql += "   AND SB1.B1_GRUPO <= '0199'" 
      cSql += "   AND SB2.B2_FILIAL  = SD1.D1_FILIAL"
      cSql += "   AND SB2.B2_COD     = SD1.D1_COD   "
      cSql += "   AND SB2.B2_LOCAL   = '01'         "
      cSql += " GROUP BY SD1.D1_FILIAL, SD1.D1_COD, SB1.B1_PARNUM, SB1.B1_DESC + '' + SB1.B1_DAUX, SB1.B1_GRUPO, SD1.D1_EMISSAO, CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())), SB2.B2_QATU, SB2.B2_CM1"
      cSql += " ORDER BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SB1.B1_DESC + '' + SB1.B1_DAUX"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
      
      T_PRODUTOS->( DbGoTop() )
   
      WHILE !T_PRODUTOS->( EOF() )
   
         aAdd( aBrowse, { T_PRODUTOS->EMPRESA    ,;
                          T_PRODUTOS->D1_FILIAL  ,;
                          Substr(T_PRODUTOS->D1_EMISSAO,07,02) + "/" + Substr(T_PRODUTOS->D1_EMISSAO,05,02) + "/" + Substr(T_PRODUTOS->D1_EMISSAO,01,04),;
                          T_PRODUTOS->DIAS       ,;
                          T_PRODUTOS->D1_COD     ,;
                          T_PRODUTOS->B1_PARNUM  ,;
                          T_PRODUTOS->DESCRICAO  ,;
                          T_PRODUTOS->B2_QATU    ,;
                          T_PRODUTOS->B2_CM1     })

         T_PRODUTOS->( DbSkip() )
      
      ENDDO
      
   Else
   
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := "SELECT '01' AS EMPRESA,"
      cSql += "       SD1.D1_FILIAL  ,"
      cSql += "       SD1.D1_COD     ,"
      cSql += "       SB1.B1_PARNUM  ,"
      cSql += "       SB1.B1_DESC + '' + SB1.B1_DAUX AS DESCRICAO,"
      cSql += "       SB1.B1_GRUPO   ,"
      cSql += "       SD1.D1_EMISSAO,"
      cSql += "       CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) AS DIAS,"
      cSql += "	   SB2.B2_QATU  ,"
      cSql += "	   SB2.B2_CM1    "
      cSql += "  FROM SD1010 SD1," 
      cSql += "       SB1010 SB1," 
      cSql += "       SB2010 SB2 " 
      cSql += " WHERE CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) >= " + Alltrim(str(cDias01)) 
      cSql += "   AND CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) <= " + Alltrim(str(cDias02)) 
      cSql += "   AND SD1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SD1.D1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_ZAPR   <> 'R'" 
      cSql += "   AND SB1.B1_GRUPO >= '0100'"
      cSql += "   AND SB1.B1_GRUPO <= '0199'" 
      cSql += "   AND SB2.B2_FILIAL  = SD1.D1_FILIAL"
      cSql += "   AND SB2.B2_COD     = SD1.D1_COD   "
      cSql += "   AND SB2.B2_LOCAL   = '01'"         
      cSql += " UNION "
      cSql += "SELECT '02' AS EMPRESA,"
      cSql += "       SD1.D1_FILIAL  ,"
      cSql += "       SD1.D1_COD     ,"
      cSql += "       SB1.B1_PARNUM  ,"
      cSql += "       SB1.B1_DESC + '' + SB1.B1_DAUX AS DESCRICAO,"
      cSql += "       SB1.B1_GRUPO   ,"
      cSql += "       SD1.D1_EMISSAO,"
      cSql += "       CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) AS DIAS,"
      cSql += "	   SB2.B2_QATU  ,"
      cSql += "	   SB2.B2_CM1    "
      cSql += "  FROM SD1020 SD1," 
      cSql += "       SB1010 SB1," 
      cSql += "       SB2020 SB2 " 
      cSql += " WHERE CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) >= " + Alltrim(str(cDias01)) 
      cSql += "   AND CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) <= " + Alltrim(str(cDias02)) 
      cSql += "   AND SD1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SD1.D1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_ZAPR   <> 'R'" 
      cSql += "   AND SB1.B1_GRUPO >= '0100'"
      cSql += "   AND SB1.B1_GRUPO <= '0199'" 
      cSql += "   AND SB2.B2_FILIAL  = SD1.D1_FILIAL"
      cSql += "   AND SB2.B2_COD     = SD1.D1_COD   "
      cSql += "   AND SB2.B2_LOCAL   = '01'         "
      cSql += " UNION "
      cSql += "SELECT '03' AS EMPRESA,"
      cSql += "       SD1.D1_FILIAL  ,"
      cSql += "       SD1.D1_COD     ,"
      cSql += "       SB1.B1_PARNUM  ,"
      cSql += "       SB1.B1_DESC + '' + SB1.B1_DAUX AS DESCRICAO,"
      cSql += "       SB1.B1_GRUPO   ,"
      cSql += "       SD1.D1_EMISSAO,"
      cSql += "       CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) AS DIAS,"
      cSql += "	   SB2.B2_QATU  ,"
      cSql += "	   SB2.B2_CM1    "
      cSql += "  FROM SD1030 SD1," 
      cSql += "       SB1010 SB1," 
      cSql += "       SB2030 SB2 " 
      cSql += " WHERE CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) >= " + Alltrim(str(cDias01)) 
      cSql += "   AND CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) <= " + Alltrim(str(cDias02)) 
      cSql += "   AND SD1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SD1.D1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_ZAPR   <> 'R'" 
      cSql += "   AND SB1.B1_GRUPO >= '0100'"
      cSql += "   AND SB1.B1_GRUPO <= '0199'" 
      cSql += "   AND SB2.B2_FILIAL  = SD1.D1_FILIAL"
      cSql += "   AND SB2.B2_COD     = SD1.D1_COD   "
      cSql += "   AND SB2.B2_LOCAL   = '01'         "

      //cSql += " UNION "
      //cSql += "SELECT '04' AS EMPRESA,"
      //cSql += "       SD1.D1_FILIAL  ,"
      //cSql += "       SD1.D1_COD     ,"
      //cSql += "       SB1.B1_PARNUM  ,"
      //cSql += "       SB1.B1_DESC + '' + SB1.B1_DAUX AS DESCRICAO,"
      //cSql += "       SB1.B1_GRUPO   ,"
      //cSql += "       SD1.D1_EMISSAO, "
      //cSql += "       CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) AS DIAS,"
      //cSql += "	   SB2.B2_QATU  ,"
      //cSql += "	   SB2.B2_CM1    "
      //cSql += "  FROM SD1040 SD1," 
      //cSql += "       SB1010 SB1," 
      //cSql += "       SB2040 SB2 " 
      //cSql += " WHERE CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) >= " + Alltrim(str(cDias01)) 
      //cSql += "   AND CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())) <= " + Alltrim(str(cDias02))       
      //cSql += "   AND SD1.D_E_L_E_T_ = ''"
      //cSql += "   AND SB1.B1_COD     = SD1.D1_COD"
      //cSql += "   AND SB1.D_E_L_E_T_ = ''"
      //cSql += "   AND SB1.B1_ZAPR   <> 'R'" 
      //cSql += "   AND SB1.B1_GRUPO >= '0100'"
      //cSql += "   AND SB1.B1_GRUPO <= '0199'" 
      //cSql += "   AND SB2.B2_FILIAL  = SD1.D1_FILIAL"
      //cSql += "   AND SB2.B2_COD     = SD1.D1_COD   "
      //cSql += "   AND SB2.B2_LOCAL   = '01'         "

      cSql += " GROUP BY SD1.D1_FILIAL, SD1.D1_COD, SB1.B1_PARNUM, SB1.B1_DESC + '' + SB1.B1_DAUX, SB1.B1_GRUPO, SD1.D1_EMISSAO, CONVERT(VARCHAR, DATEDIFF(DAY, SD1.D1_EMISSAO, GETDATE())), SB2.B2_QATU, SB2.B2_CM1"
      cSql += " ORDER BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SB1.B1_DESC + '' + SB1.B1_DAUX"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
      
      T_PRODUTOS->( DbGoTop() )
   
      WHILE !T_PRODUTOS->( EOF() )

         If T_PRODUTOS->B1_GRUPO$("0119#0122")
         Else

            aAdd( aBrowse, { T_PRODUTOS->EMPRESA    ,;
                             T_PRODUTOS->D1_FILIAL  ,;
                             Substr(T_PRODUTOS->D1_EMISSAO,07,02) + "/" + Substr(T_PRODUTOS->D1_EMISSAO,05,02) + "/" + Substr(T_PRODUTOS->D1_EMISSAO,01,04),;
                             T_PRODUTOS->DIAS       ,;
                             T_PRODUTOS->D1_COD     ,;
                             T_PRODUTOS->B1_PARNUM  ,;
                             T_PRODUTOS->B1_GRUPO   ,;
                             T_PRODUTOS->DESCRICAO  ,;
                             T_PRODUTOS->B2_QATU    ,;
                             T_PRODUTOS->B2_CM1     })
         Endif                              
                             
         T_PRODUTOS->( DbSkip() )
      
      ENDDO
   
   Endif   
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "" })
   Endif

   If kTipo == 0
      Return(.T.)
   Endif   

   // ##########################
   // Atualiza o grid na tela ##
   // ##########################
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10]} }

   // ##################################################################### 
   // Atualiza o parametrizador do sistema com os parâmetros da consulta ##
   // #####################################################################
   RecLock("ZZ4",.F.)   
   ZZ4->ZZ4_RK01 := cDias01
   ZZ4->ZZ4_RK02 := cDias02
   ZZ4->ZZ4_RELI := "" 
   MsUnLock()

Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function xGeraCSV()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private cCaminho := Space(250)
   Private cArquivo := Space(060)

   Private oGet1
   Private oGet2

   Private oDlgCSV

   DEFINE MSDIALOG oDlgCSV TITLE "Gera consulat em CSV" FROM C(178),C(181) TO C(338),C(542) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlgCSV

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(172),C(001) PIXEL OF oDlgCSV

   @ C(033),C(005) Say "Inorme o caminho a ser salvo o arquivo CSV" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV
   @ C(056),C(005) Say "Nome do arquivo a ser salvo"                Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV

   @ C(043),C(005) MsGet oGet1 Var cCaminho Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV When lChumba
   @ C(065),C(005) MsGet oGet2 Var cArquivo Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV
   
   @ C(043),C(161) Button "..."    Size C(014),C(009) PIXEL OF oDlgCSV ACTION( xCaptaCaminho() )
   @ C(062),C(097) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( xGravaCSV() )
   @ C(062),C(137) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( oDlgCSV:End() )

   ACTIVATE MSDIALOG oDlgCSV CENTERED 

Return(.T.)

// ################################################################
// Função que seleciona o diretório para gravação do arquivo CSV ##
// ################################################################
Static Function xCaptaCaminho()

   cCaminho := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
   
Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function xGravaCSV()

   Local nContar   := 0
   Local cString   := ""
   Local lPrimeiro := .T.

   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho para gravação do arquivo CSV não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cArquivo))
      MsgAlert("Nome do arquivo para gravação não informado.")
      Return(.T.)
   Endif

   If U_P_OCCURS(cArquivo, ".CSV", 1) == 0
      cArquivo := Alltrim(cArquivo) + ".CSV"
   Endif   

   cString := ""

   For nContar = 1 to Len(aBrowse)
      
       If lPrimeiro == .T.
          cString += 'EMPRESA'                + ";" + ;
                     'FILIAL'                 + ";" + ;
                     'ULTIMA ENTRADA'         + ";" + ;
                     'DIAS'                   + ";" + ;
                     'PRODUTO'                + ";" + ;
                     'PARTNUMBER'             + ";" + ;
                     'GRUPO'                  + ";" + ;
                     'DESCRICAO DOS PRODUTOS' + ";" + ;
                     'SALDO'                  + ";" + ;
                     'CUSTO MEDIO'            + chr(13)
          lPrimeiro := .F.
       Endif
       
       cString += aBrowse[nContar,01]           + ";" + ;
                  aBrowse[nContar,02]           + ";" + ;
                  aBrowse[nContar,03]           + ";" + ;
                  Alltrim(aBrowse[nContar,04])  + ";" + ;
                  Alltrim(aBrowse[nContar,05])  + ";" + ;
                  Alltrim(aBrowse[nContar,06] ) + ";" + ;
                  aBrowse[nContar,07]           + ";" + ;
                  Alltrim(aBrowse[nContar,08] ) + ";" + ;
                  str(aBrowse[nContar,09] )     + ";" + ;
                  Str(aBrowse[nContar,10] )     + chr(13)

   Next nContar

   If File(Alltrim(cCaminho) + Alltrim(cArquivo))
      
      If (MsgYesNo("Arquivo já existe na pasta selecionada. Deseja sobrescrever o arquivo?","Atenção!"))

         nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
         fWrite (nHdl, cString ) 
         fClose(nHdl)
         
         MsgAlert("Arquivo gerado com sucesso.")
         
      Endif
         
   Else
         
      nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      MsgAlert("Arquivo gerado com sucesso.")

   Endif            

   oDlgCSV:End()
   
Return(.T.)