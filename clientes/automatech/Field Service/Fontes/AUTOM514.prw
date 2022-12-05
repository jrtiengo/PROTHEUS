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
// Referencia: AUTOM514.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 08/11/2016                                                               ##
// Objetivo..: Inconsistências de Ordens de Serviços conforme regra.                    ##
// #######################################################################################

User Function AUTOM514()

   Local cSql        := ""

   Local cMemo1	     := ""
   Local oMemo1

   Private aFiliais	 := {}
   Private aStatus 	 := {}
   Private aTecnicos := {}
   Private cNumeroOs := Space(06)
   Private cInicial  := Ctod("  /  /    ")
   Private cFinal    := Ctod("  /  /    ")

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private lRegra1	 := .F.
   Private lRegra2	 := .F.
   Private oCheckBox1
   Private oCheckBox2
   Private oGet1
   Private oGet2
   Private oGet3

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

   // #################################   
   // Carrega o combobox das filiais ##
   // #################################
   aFiliais := U_AUTOM539(2, cEmpAnt) 

   // #######################################
   // Carrega o combobox dos Status das OS ##
   // #######################################
   aStatus := {"X - Selecione", "T - Ambos", "A - Abertas", "E - Encerradas", "B - XXXXXXX"}
   
   // ##################################
   // Carrega o combobox dos Técnicos ##
   // ##################################
   If Select("T_TECNICOS") > 0
      T_TECNICOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_NOMTEC "
   cSql += "  FROM " + RetSqlName("AA1")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND AA1_CODUSR <> ''"
   cSql += " ORDER BY AA1_NOMTEC   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICOS", .T., .T. )

   aAdd( aTecnicos, "000000 - Todos os Técnicos" )
   
   T_TECNICOS->( DbGoTop() )
   
   WHILE !T_TECNICOS->( EOF() )
      aAdd( aTecnicos, T_TECNICOS->AA1_CODTEC + " - " + Alltrim(T_TECNICOS->AA1_NOMTEC) )
      T_TECNICOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Inconsistências em OS" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg
   @ C(212),C(005) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(043) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(090) Jpeg FILE "br_amarelo"      Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Filial"                                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(082) Say "Dta Inicial"                                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(128) Say "Dta Final"                                    Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(174) Say "Nº OS"                                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(211) Say "Técnicos"                                     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Selecione a regra a ser aplicada na pesquisa" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(019) Say "Aberta"                                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(058) Say "Encerrada"                                    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(105) Say "Atendida"                                     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(044),C(005) ComboBox cComboBx1 Items aFiliais  Size C(072),C(010)                              PIXEL OF oDlg
   @ C(044),C(082) MsGet    oGet2     Var   cInicial  Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(128) MsGet    oGet3     Var   cFinal    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(174) MsGet    oGet1     Var   cNumeroOS Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(211) ComboBox cComboBx3 Items aTecnicos Size C(133),C(010)                              PIXEL OF oDlg

   @ C(066),C(019) CheckBox oCheckBox1 Var lRegra1 Prompt "Status = E (Encerradas) e que armazém do técnico ainda possua peças" Size C(181),C(008) PIXEL OF oDlg
   @ C(075),C(019) CheckBox oCheckBox2 Var lRegra2 Prompt "Status = A ou B e que a data da requisição seja >= 30 Dias"          Size C(244),C(008) PIXEL OF oDlg
// @ C(075),C(019) CheckBox oCheckBox2 Var lRegra2 Prompt "Status = A ou B e que não tenham o par formado (SD3) e que a data da requisição seja >= 30 Dias" Size C(244),C(008) PIXEL OF oDlg

   @ C(043),C(351) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PesquisaDadosR() )

   If Upper(Alltrim(cUserName)) == "ADMINISTRADOR"
      @ C(043),C(460) Button "Atualiza PV/NF" Size C(037),C(012) PIXEL OF oDlg ACTION( AtualizaPVNF() )
   Endif   

   @ C(210),C(420) Button "Saldo Produto" Size C(037),C(012) PIXEL OF oDlg ACTION( ySaldoProd(aBrowse[oBrowse:nAt,02]) )
   @ C(210),C(460) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 110 , 005, 633, 155,,{'ST'                         ,; // 01
                                                    'Produto'                    ,; // 02
                                                    'Descrição dos Produtos'     ,; // 03
                                                    'Nº OS'                      ,; // 04
                                                    'Dta Requisição'             ,; // 05
                                                    'Nº Documento'               ,; // 06
                                                    'Armazém'                    ,; // 07
                                                    'Quantª'                     ,; // 08
                                                    'Ped.Venda'                  ,; // 09
                                                    'N.Fiscal'                   ,; // 10
                                                    'Série'                      ,; // 11                                                                                                        
                                                    'Ocorrência'                 ,; // 12
                                                    'Descrição das Ocorrências'} ,; // 13 
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
                          aBrowse[oBrowse:nAt,13]               }}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################
// Função que abre a tela do F4 - Consulta de Saldos ##
// ####################################################
Static Function ySaldoProd(cProduto)

   If Empty(Alltrim(cProduto))
      MsgAlert("Produto não selecionado. Pesquisa não será realizada.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + cProduto)

   MaViewSB2(cProduto)

   RestArea( aArea )

Return .T.

// ######################################################################
// Função que realiza a pesquisa dos dado conforme parâmertos passados ##
// ######################################################################
Static Function PesquisaDadosR()

   MsgRun("Favor Aguarde! Pesquisando dados ...", "Pesquisando dados ...",{|| xPesquisaDados() })

Return(.T.)

// ######################################################################
// Função que realiza a pesquisa dos dado conforme parâmertos passados ##
// ######################################################################
Static Function xPesquisaDados()

   // ################################################
   // Gera consistência dos dados antes da pesquisa ##
   // ################################################
   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Necessário selecionar a filial a ser pesquisada.")
      Return(.T.)
   Endif
      
   If Empty(cInicial)
      MsgAlert("Necessário informar data inicial para pesquisa.")
      Return(.T.)
   Endif

   If Empty(cFinal)
      MsgAlert("Necessário informar data final para pesquisa.")
      Return(.T.)
   Endif

   If lRegra1 == .F. .And. lRegra2 == .F.
      MsgAlert("Necessário indicar a regra de pesquisa.")
      Return(.T.)
   Endif
   
   If lRegra1 == .T. .And. lRegra2 == .T.
      MsgAlert("Somente permitido informar uma regra para realizar a pesquisa.")
      Return(.T.)
   Endif

   aBrowse := {}

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
                          aBrowse[oBrowse:nAt,13]               }}

   oBrowse:Refresh()

   // #############################################
   // Pesquisa conforme os parâmetros informados ##
   // #############################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB8.AB8_FILIAL,"
   cSql += "       AB8.AB8_NUMOS ,"
   cSql += "       ZZZ.ZZZ_EMISSA,"
   cSql += "       SUBSTRING(ZZZ.ZZZ_EMISSA,07,02) + '/' + SUBSTRING(ZZZ.ZZZ_EMISSA,05,02) + '/' + SUBSTRING(ZZZ.ZZZ_EMISSA,01,04) AS EMISSAO,"
   cSql += "	   AB8.AB8_ITEM  ,"
   cSql += "	   AB8.AB8_CODPRO,"
   cSql += "	   AB8.AB8_DESPRO,"
   cSql += "	   AB6.AB6_STATUS,"
   cSql += "	   AB6.AB6_RLAUDO,"
   cSql += "       AB7.AB7_CODPRB,"
   cSql += "       ZZZ.ZZZ_FILIAL,"
   cSql += "	   ZZZ.ZZZ_STATUS,"
   cSql += "	   ZZZ.ZZZ_LOCAL ,"
   cSql += "       ZZZ.ZZZ_PRODUT,"
   cSql += "	   ZZZ.ZZZ_QUANT ,"
   cSql += "       ZZZ.ZZZ_NUMPV ,"
   cSql += "       ZZZ.ZZZ_DOCSD3,"
   cSql += "       ZZZ.ZZZ_NOTA  ,"
   cSql += "       ZZZ.ZZZ_SERIE ,"
   cSql += "  	   AB7.AB7_CODPRB,"
   cSql += "	   AAG.AAG_DESCRI "
   cSql += "  FROM " + RetSqlName("AB8") + " AB8, "
   cSql += "       " + RetSqlName("AB6") + " AB6, " 
   cSql += "	   " + RetSqlName("ZZZ") + " ZZZ, "
   cSql += "       " + RetSqlName("AB7") + " AB7, "
   cSql += "	   " + RetSqlName("AAG") + " AAG  "
   cSql += " WHERE AB8.AB8_FILIAL  = '" + Alltrim(Substr(cCombobx1,01,02)) + "'"
   cSql += "   AND AB8.D_E_L_E_T_  = ''"
   cSql += "   AND AB6.AB6_FILIAL  = AB8.AB8_FILIAL"
   cSql += "   AND AB6.AB6_NUMOS   = AB8.AB8_NUMOS "
   cSql += "   AND AB6.D_E_L_E_T_  = ''"

   If Substr(cCombobx3,01,06) == "000000"
   Else
      cSql += "   AND AB6.AB6_RLAUDO  = '" + Alltrim(Substr(cCombobx3,01,06)) + "'"
   Endif

   If lRegra1 == .T.
      cSql += "   AND AB6.AB6_STATUS  = 'E'"
   Endif
   
   If lRegra2 == .T.
      cSql += "   AND AB6.AB6_STATUS  IN ('A', 'B')"
   Endif
   
   If Empty(Alltrim(cNumeroOS))
   Else
      cSql += "  AND AB6.AB6_NUMOS = '" + Alltrim(cNumeroOS) + "'"
   Endif

   cSql += "   AND ZZZ.ZZZ_FILIAL  = AB8.AB8_FILIAL"
   cSql += "   AND ZZZ.ZZZ_NUMOS   = AB8.AB8_NUMOS "
   cSql += "   AND ZZZ.ZZZ_PRODUT  = AB8.AB8_CODPRO"
   cSql += "   AND ZZZ.ZZZ_STATUS  = 'E'           "
   cSql += "   AND ZZZ.D_E_L_E_T_  = ''            "
   cSql += "   AND ZZZ.ZZZ_EMISSA >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"
   cSql += "   AND ZZZ.ZZZ_EMISSA <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"
   cSql += "   AND AB7.AB7_FILIAL  = AB6.AB6_FILIAL"
   cSql += "   AND AB7.AB7_NUMOS   = AB6.AB6_NUMOS "
   cSql += "   AND AB7.D_E_L_E_T_  = ''            "
   cSql += "   AND AAG.AAG_CODPRB  = AB7.AB7_CODPRB"
   cSql += "   AND AAG.D_E_L_E_T_  = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   If T_CONSULTA->( EOF() )

      MsgAlert("Não existem dados a serem visualizados.")

      aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "" })

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
                             aBrowse[oBrowse:nAt,13]               }}

      oBrowse:Refresh()

      Return(.T.)

   Endif
   
   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      // ###################################
      // Aplica a regra conforme selecção ##
      // ###################################
      If lRegra1 == .T.

         lVolta := .F.
      
         If T_CONSULTA->AB7_CODPRB == "000029"
            T_CONSULTA->( DbSkip() )
            Loop
         Endif
         
         If Empty(Alltrim(T_CONSULTA->ZZZ_NUMPV)) 
            If Empty(Alltrim(T_CONSULTA->ZZZ_NOTA))  
               lVolta := .F.
            Else
               lVolta := .T.
            Endif
         Else
            lVolta := .T.
         Endif
                     
         If lVolta == .T.
            T_CONSULTA->( DbSkip() )
            Loop
         Endif
         
      Endif
      
      If lRegra2 == .T.
      
         If T_CONSULTA->AB7_CODPRB == "000029"
            T_CONSULTA->( DbSkip() )
            Loop
         Endif
         
         If Empty(Alltrim(T_CONSULTA->ZZZ_NUMPV)) .AND. Empty(Alltrim(T_CONSULTA->ZZZ_NOTA))

            If (DATE() - CTOD(T_CONSULTA->ZZZ_EMISSA)) > 30
               T_CONSULTA->( DbSkip() )
               Loop
            Endif
            
         Endif
            
      Endif
         
      // ###################################
      // Pesquisa o lançamento de destino ##
      // ###################################
      If Select("T_DESTINO") > 0
         T_DESTINO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql += "SELECT SUBSTRING(D3_EMISSAO,07,02) + '/' + SUBSTRING(D3_EMISSAO,05,02) + '/' + SUBSTRING(D3_EMISSAO,01,04) AS EMISSAO,"
      cSql += "       D3_USUARIO,"
      cSql += "       D3_LOCAL  ,"
      cSql += "       D3_QUANT   "
      cSql += "  FROM " + RetSqlName("SD3") 
      cSql += " WHERE D3_FILIAL  = '" + Alltrim(T_CONSULTA->ZZZ_FILIAL) + "'"
      cSql += "   AND D3_COD     = '" + Alltrim(T_CONSULTA->ZZZ_PRODUT) + "'"
//    cSql += "   AND D3_TM      = '499'"
//    cSql += "   AND D3_CF      = 'DE4'"
      cSql += "   AND D3_DOC     = '" + Alltrim(T_CONSULTA->ZZZ_DOCSD3) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESTINO", .T., .T. )

      T_DESTINO->( DbGoTop() )

      WHILE !T_DESTINO->( EOF() )

         If lRegra1 == .T.
            cLegenda := "9"
         Endif   

         If lRegra2 == .T.
            cLegenda := IIF(T_CONSULTA->ZZZ_STATUS == "A", "1", "3")
         Endif   

         // ############################
         // Abre o Registro de Origem ##
         // ############################      
         aAdd( aBrowse, { cLegenda  ,;    
                          T_CONSULTA->AB8_CODPRO ,;
                          T_CONSULTA->AB8_DESPRO ,;
                          T_CONSULTA->AB8_NUMOS  ,;
                          T_CONSULTA->EMISSAO    ,;
                          T_CONSULTA->ZZZ_DOCSD3 ,;
                          T_DESTINO->D3_LOCAL    ,;        
                          Transform(T_DESTINO->D3_QUANT, "@E 9999999999") ,;
                          T_CONSULTA->ZZZ_NUMPV  ,;
                          T_CONSULTA->ZZZ_NOTA   ,;
                          T_CONSULTA->ZZZ_SERIE  ,;
                          T_CONSULTA->AB7_CODPRB ,;
                          T_CONSULTA->AAG_DESCRI })
                              
          T_DESTINO->( DbSkip() )

         // #################
         // Abre o Destino ##
         // #################
         aAdd( aBrowse, { "" ,;    
                          "" ,;
                          "" ,;
                          "" ,;
                          T_DESTINO->EMISSAO     ,;
                          T_CONSULTA->ZZZ_DOCSD3 ,;
                          T_DESTINO->D3_LOCAL    ,;        
                          Transform(T_DESTINO->D3_QUANT, "@E 9999999999") ,;
                          ""                     ,;
                          ""                     ,;
                          ""                     ,;
                          ""                     ,;                          
                          ""                     })

         // #######################
         // Abre Linha em Branco ##
         // #######################
         aAdd( aBrowse, { "" ,;    
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
                          

         T_DESTINO->( DbSkip() )
         
      ENDDO   
      
      T_CONSULTA->( DbSkip() )
      
   ENDDO
      
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
                          aBrowse[oBrowse:nAt,13]               }}

Return(.T.)

// #######################################################
// Função que atualiza o nº do PV e da NF na tabela ZZZ ##
// #######################################################
Static Function AtualizaPVNF()

   Local cSql   := ""
   Local cNumOS := ""
   
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZZ_FILIAL,"
   cSql += "       ZZZ_NUMOS ,"
   cSql += "       ZZZ_ITEM  ,"
   cSql += "       ZZZ_ITAB8 ,"
   cSql += "       ZZZ_PRODUT "
   cSql += "  FROM " + RetSqlName("ZZZ")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() ) 

      // ####################################################################################################
      // Pesquisa o Pedido de Venda e o nº da nota fiscal/Série da Nota Fiscal para gravação na tabela ZZZ ##
      // ####################################################################################################
	  cNumOs := AllTrim(T_CONSULTA->ZZZ_NUMOS) + AllTrim(T_CONSULTA->ZZZ_FILIAL) + AllTrim(T_CONSULTA->ZZZ_ITAB8)
	
	  If Select("T_PEDIDO") > 0
		 T_PEDIDO->( dbCloseArea() )
	  EndIf
	
	  cSql := ""
	  cSql := "SELECT C6_FILIAL ,"
	  cSql += "       C6_NUM    ,"
	  cSql += "       C6_NUMOS  ,"
	  cSql += "       C6_PRODUTO,"
	  cSql += "       C6_NOTA   ,"
	  cSql += "       C6_SERIE   "
	  cSql += "  FROM " + RetSqlName("SC6010")
	  cSql += " WHERE C6_NUMOS = '" + Alltrim(cNumOs) + "'"
	 
	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

      If T_PEDIDO->( EOF() )
         T_CONSULTA->( DbSkip() )
         Loop
      Endif

      DbSelectArea("ZZZ")
	  DbSetOrder(2)
		
   	  If DbSeek(T_CONSULTA->ZZZ_FILIAL + T_CONSULTA->ZZZ_NUMOS + T_CONSULTA->ZZZ_ITAB8)
			
	     Reclock("ZZZ", .F.)
         ZZZ->ZZZ_NUMFL := T_PEDIDO->C6_FILIAL
         ZZZ->ZZZ_NUMPV := T_PEDIDO->C6_NUM
	     ZZZ->ZZZ_NOTA  := T_PEDIDO->C6_NOTA
	     ZZZ->ZZZ_SERIE := T_PEDIDO->C6_SERIE
	     MsunLock()
			
  	  Endif

      T_CONSULTA->( DbSkip() )
      
   ENDDO
      
Return(.T.)