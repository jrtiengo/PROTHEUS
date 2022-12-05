#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#include "rwmake.ch"
#include "TbiConn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM264.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/11/2014                                                          *
// Objetivo..: Programa de Solicitação de Transferència de Mercadorias             *
//**********************************************************************************

User Function AUTOM264()

   Local lChumba        := .F.
   Local lAprova        := .F.
   Local cSql           := ""

   Private aStatus      := {"00 - Todos Status", "02 - Solicitação", "04 - Empréstimo", "08 - Reprovada", "03 - Dev.Sinalizada", "05 - Dev.Confirmada", "06 - Pendentes"}
   Private aSolicitante := {}
   Private aSetFiltro   := {}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx20
   Private cSolicitante := Space(25)
   Private cProduto	    := Space(06)
   Private cDescricao   := Space(60)
   Private cCodigo	    := Space(09)
   Private cSerie	    := Space(30)
   Private nVerde       := 0
   Private nAmarelo     := 0
   Private nVermelho    := 0
   Private nRosa        := 0
   Private nAzul        := 0
   Private nTotalC      := 0
   Private cMemo1	    := ""
   Private cMemo2       := ""
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
   Private oMemo1
   Private oMemo2

   Private kTipoMov := ""
   
   Private aBrowsek := {}

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

   U_AUTOM628("AUTOM264")

   // ######################################################################
   // Carrega combo de setores para ser utilizado nos filtros de pesquisa ##
   // ######################################################################
   If Select("T_SETORES") > 0
      T_SETORES->( dbCloseArea() )
   EndIf
    
   cSql := ""
   cSql := "SELECT ZZ4_SETO "
   cSql += "  FROM " + RetSqlName("ZZ4")
 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SETORES", .T., .T. )
      
   aAdd( aSetFiltro, "TTT - Todos Setores" )

   For nContar = 1 to U_P_OCCURS(T_SETORES->ZZ4_SETO, "|", 1)
       aAdd( aSetFiltro, U_P_CORTA(T_SETORES->ZZ4_SETO, "|", nContar) )
   Next nContar   

   // #######################################################################################
   // Verifica se o usuário logado é aporvador/reprovador de Solicitação de Transferências ##
   // #######################################################################################
   lAprova := VerAproUsua()

   // #################################################
   // Carrega informações dos usuários para listagem ##
   // #################################################
   aSolicitante := {"TODOS SOLIC."}
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZP2_SOLI"
   cSql += "  FROM " + RetSqlName("ZP2")
   cSql += " GROUP BY ZP2_SOLI"
   cSql += " ORDER BY ZP2_SOLI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   If T_USUARIOS->( EOF() )
      aAdd(aSolicitante, Alltrim(Upper(cUserName)) )
   Else
      lUsuario := .F.
      WHILE !T_USUARIOS->( EOF() )
         aAdd(aSolicitante, T_USUARIOS->ZP2_SOLI)
         If Alltrim(Upper(T_USUARIOS->ZP2_SOLI)) == Alltrim(Upper(cUserName))
            lUsuario := .T.
         Endif
         T_USUARIOS->( DbSkip() )
      ENDDO
      If lUsuario == .F.
         aAdd(aSolicitante, Alltrim(Upper(cUserName)) )
      Endif
   Endif

   // ##############################
   // Posiciona no usuário logado ##
   // ##############################
   For nContar = 1 to Len(aSolicitante)
       If Alltrim(Upper(aSolicitante[nContar])) == Alltrim(Upper(cUserName))
          cComboBx2 := Alltrim(Upper(aSolicitante[nContar]))
          Exit
       Endif
   Next nContar       

   // ################################
   // Carrega o grid mas não mostra ##
   // ################################
   CarregaGridSol(1)

   // ################################################################
   // Desenha a tela da solicitação de transferência de mercadorias ##
   // ################################################################
   DEFINE MSDIALOG oDlg TITLE "Solicitação de Transferência de Mercadorias" FROM C(178),C(181) TO C(627),C(961) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlg
   @ C(192),C(005) Jpeg FILE "br_verde"        Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(192),C(047) Jpeg FILE "br_amarelo"      Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(192),C(089) Jpeg FILE "br_vermelho"     Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(192),C(131) Jpeg FILE "br_pink"         Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(192),C(170) Jpeg FILE "br_azul"         Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(380),C(001) PIXEL OF oDlg
   @ C(203),C(005) GET oMemo2 Var cMemo2 MEMO Size C(379),C(001) PIXEL OF oDlg
   
   @ C(015),C(272) Say "Setor"          Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(040),C(312) Say "Status"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(005) Say "Produto"        Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(143) Say "Nº de Série"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(207) Say "Solicitante"    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(272) Say "Nº Solicitação" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(063),C(005) Say "Solicitações"   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(192),C(210) Say "=="             Size C(006),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   // ###############
   // Estatísticas ##
   // ###############
   @ C(190),C(018) MsGet oGet6  Var nVerde    Size C(022),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg When lChumba
   @ C(190),C(060) MsGet oGet7  Var nAmarelo  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg When lChumba
   @ C(190),C(102) MsGet oGet8  Var nVermelho Size C(022),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg When lChumba
   @ C(190),C(144) MsGet oGet9  Var nRosa     Size C(022),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg When lChumba
   @ C(190),C(183) MsGet oGet10 Var nAzul     Size C(022),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg When lChumba
   @ C(190),C(222) MsGet oGet11 Var nTotalC   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg When lChumba

   @ C(023),C(272) ComboBox cComboBx20 Items aSetFiltro Size C(112),C(010) PIXEL OF oDlg

   @ C(050),C(005) MsGet    oGet2     Var   cProduto     Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( PesqProSol(cProduto, 1) )
   @ C(050),C(036) MsGet    oGet3     Var   cDescricao   Size C(103),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(050),C(143) MsGet    oGet5     Var   cSerie       Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
// @ C(050),C(207) MsGet    oGet1     Var   cSolicitante Size C(062),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(050),C(207) ComboBox cComboBx2 Items aSolicitante Size C(059),C(010) PIXEL OF oDlg

   @ C(050),C(272) MsGet    oGet4     Var   cCodigo      Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(050),C(312) ComboBox cComboBx1 Items aStatus      Size C(053),C(010)                              PIXEL OF oDlg
   @ C(048),C(367) Button ". . ."                        Size C(018),C(012)                              PIXEL OF oDlg ACTION( CarregaGridSol(2) )

   @ C(189),C(245) Button "Encerra Solicitação" Size C(069),C(012) PIXEL OF oDlg ACTION( EncerStatusRMA() ) When lAprova
   @ C(189),C(316) Button "Trocar Status"       Size C(069),C(012) PIXEL OF oDlg ACTION( TrocaStatusRMA() ) When lAprova
   
   @ C(208),C(005) Button "Incluir"             Size C(030),C(012) PIXEL OF oDlg ACTION( ManuTransfe("I", 0, cFilAnt) )
   @ C(208),C(036) Button "Alterar"             Size C(030),C(012) PIXEL OF oDlg ACTION( ManuTransfe("A", aBrowsek[oBrowsek:nAt,06], aBrowsek[oBrowsek:nAt,10] ) )
   @ C(208),C(067) Button "Visualizar"          Size C(030),C(012) PIXEL OF oDlg ACTION( ManuTransfe("V", aBrowsek[oBrowsek:nAt,06], aBrowsek[oBrowsek:nAt,10] ) )
   @ C(208),C(098) Button "Excluir"             Size C(030),C(012) PIXEL OF oDlg ACTION( ManuTransfe("E", aBrowsek[oBrowsek:nAt,06], aBrowsek[oBrowsek:nAt,10] ) )
   @ C(208),C(132) Button "Legenda"             Size C(030),C(012) PIXEL OF oDlg ACTION( MostraLegSol() )
   @ C(208),C(164) Button "Aprovar/Reprovar"    Size C(056),C(012) PIXEL OF oDlg ACTION( ManuTransfe("P", aBrowsek[oBrowsek:nAt,06], aBrowsek[oBrowsek:nAt,10] ) ) When lAprova
   @ C(208),C(222) Button "Dev. Sinalizada"     Size C(045),C(012) PIXEL OF oDlg ACTION( DevoSinal( aBrowsek[oBrowsek:nAt,01], aBrowsek[oBrowsek:nAt,06], aBrowsek[oBrowsek:nAt,10] ) )
   @ C(208),C(268) Button "Dev. Confirmada"     Size C(045),C(012) PIXEL OF oDlg ACTION( DevoConfirma( aBrowsek[oBrowsek:nAt,01], aBrowsek[oBrowsek:nAt,06], aBrowsek[oBrowsek:nAt,10] ) )
   @ C(208),C(316) Button "Parâmetros"          Size C(034),C(012) PIXEL OF oDlg ACTION( AbreParam() ) When __CUserID == "000000"
   @ C(208),C(354) Button "Voltar"              Size C(030),C(012) PIXEL OF oDlg ACTION( oDlg:End() )       

   oBrowsek := TCBrowse():New( 090 , 005, 490, 148,,{'Lg', 'Produto' + Space(06), 'Descrição dos Produtos' + Space(30), 'Nº de Série', 'Qtd', 'Solicitação', 'Data', 'Hora', 'Solicitante', 'Filial'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowsek:SetArray(aBrowsek) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowsek:bLine := {||{ If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "1", oBranco  ,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "2", oVerde   ,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "3", oPink    ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "4", oAmarelo ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "7", oPreto   ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "8", oVermelho,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                          aBrowsek[oBrowsek:nAt,02],;
                          aBrowsek[oBrowsek:nAt,03],;
                          aBrowsek[oBrowsek:nAt,04],;
                          aBrowsek[oBrowsek:nAt,05],;
                          aBrowsek[oBrowsek:nAt,06],;
                          aBrowsek[oBrowsek:nAt,07],;
                          aBrowsek[oBrowsek:nAt,08],;
                          aBrowsek[oBrowsek:nAt,09],;
                          aBrowsek[oBrowsek:nAt,10]} }

   oBrowsek:bHeaderClick := {|oObj,nCol| oBrowsek:aArray := Ordenar(nCol,oBrowsek:aArray),oBrowsek:Refresh()}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################
// Função que Ordena a coluna selecionada no grid ##
// #################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   // ###################
   // Ordenando Arrays ##
   // ###################
   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  })
   Endif   

Return(_aOrdena)

// ##################################################################################################################
// Função que pesquisa os dados da tabela ZP2 - Solicitação de Transferência para carregar o grid da primeira tela ##
// ##################################################################################################################
Static Function CarregaGridSol(_PorOnde)

   Local cSql := ""

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZP2.ZP2_FILIAL,"
   cSql += "       ZP2.ZP2_CODI  ,"
   cSql += "       ZP2.ZP2_SOLI  ,"
   cSql += "       ZP2.ZP2_EMIS  ,"
   cSql += "       ZP2.ZP2_HEMI  ,"
   cSql += "       ZP2.ZP2_STAT  ,"
   cSql += "       ZP2.ZP2_PROD  ,"
   cSql += "       ZP2.ZP2_QUAN  ,"
   cSql += "       ZP2.ZP2_SERI  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZP2.ZP2_NOT1)) AS OBS01,"
   cSql += "       ZP2.ZP2_DTAA  ,"
   cSql += "       ZP2.ZP2_HORA  ,"
   cSql += "       ZP2.ZP2_APRO  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZP2.ZP2_NOT2)) AS OBS02,"
   cSql += "       ZP2.ZP2_DELE  ,"     
   cSql += "       SB1.B1_DESC    "
   cSql += "  FROM " + RetSqlName("ZP2") + " ZP2 (NoLock), "
   cSql += "       " + RetSqlName("SB1") + " SB1 (NoLock)  "
   cSql += " WHERE ZP2.ZP2_DELE  = ''"
   cSql += "   AND SB1.B1_FILIAL = ''"
   cSql += "   AND SB1.B1_COD    = ZP2.ZP2_PROD"

   If _PorOnde == 2

      // ################################## 
      // Filtra por produto se informado ##
      // ##################################
      If !Empty(Alltrim(cProduto))
         cSql += "  AND ZP2.ZP2_PROD = '" + Alltrim(cProduto) + "'"
      Endif

      // ######################################
      // Filtra por nº de série se informado ##
      // ######################################
      If !Empty(Alltrim(cSerie))
         cSql += "  AND ZP2.ZP2_SERI = '" + Alltrim(cSerie) + "'"
      Endif
  
      // ################################# 
      // Filtra por nome de solicitante ##
      // #################################
      If !Empty(Alltrim(cComboBx2))

         If Alltrim(Upper(cComboBx2)) == "TODOS SOLIC."
         Else
            cSql += "  AND ZP2.ZP2_SOLI = '" + Alltrim(UPPER(cComboBx2)) + "'"
         Endif
      Endif

      // ###################################
      // Filtra por código de solicitante ##
      // ###################################
      If !Empty(Alltrim(cCodigo))
         cSql += "  AND ZP2.ZP2_CODI= '" + Alltrim(cCodigo) + "'"
      Endif

      // ####################
      // Filtra por Status ##
      // ####################
      If Substr(cComboBx1,01,02) <> "00"
         If Substr(cComboBx1,01,02) <> "06"
            cSql += "  AND ZP2.ZP2_STAT = '" + Substr(cComboBx1,02,01) + "'"
         Else
            cSql += "  AND ZP2.ZP2_STAT IN ('2', '4', '3')"
         Endif
      Endif

   Else
   
      // #################################
      // Filtra por nome de solicitante ##
      // #################################
      If !Empty(Alltrim(cComboBx2))

         If Alltrim(Upper(cComboBx2)) == "TODOS SOLIC."
         Else
            cSql += "  AND ZP2.ZP2_SOLI = '" + Alltrim(UPPER(cComboBx2)) + "'"
         Endif
      Endif
   
   Endif   

   cSql += " ORDER BY ZP2.ZP2_EMIS, ZP2.ZP2_HEMI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   aBrowsek := {}

   nVerde    := 0
   nAmarelo  := 0
   nVermelho := 0
   nRosa     := 0
   nAzul     := 0
   nTotalC   := 0

   WHILE !T_CONSULTA->( EOF() )

      If _PorOnde == 2     
         If Substr(cComboBx20,01,03) == "TTT"
         Else
            If Substr(T_CONSULTA->ZP2_CODI,07,03) == Substr(cComboBx20,01,03)
            Else
               T_CONSULTA->( DbSkip() )         
               Loop
            Endif
         Endif
      Endif   

      Do Case
         Case T_CONSULTA->ZP2_STAT == "2"
              _Status := '2'
              nVerde := nVerde + 1
         Case T_CONSULTA->ZP2_STAT == "4"
              _Status := '4'
              nAmarelo := nAmarelo + 1
         Case T_CONSULTA->ZP2_STAT == "8"
              _Status := '8'
              nVermelho := nVermelho + 1
         Case T_CONSULTA->ZP2_STAT == "5"
              _Status := '5'
              nAzul := nAzul + 1
         Case T_CONSULTA->ZP2_STAT == "3"
              _Status := '3'
              nRosa := nRosa + 1
         Otherwise
              _Status := '1'                       
      EndCase              

      nTotalC := nVerde + nAmarelo + nVermelho + nAzul + nRosa
   
      // ##########################
      // Carrega o Array aBrowse ##
      // ##########################
      aAdd(aBrowsek, { T_CONSULTA->ZP2_STAT,;
                      T_CONSULTA->ZP2_PROD,;
                      T_CONSULTA->B1_DESC ,;
                      T_CONSULTA->ZP2_SERI,;
                      T_CONSULTA->ZP2_QUAN,;
                      T_CONSULTA->ZP2_CODI,;
                      Substr(T_CONSULTA->ZP2_EMIS,07,02) + "/" + Substr(T_CONSULTA->ZP2_EMIS,05,02) + "/" + Substr(T_CONSULTA->ZP2_EMIS,01,04),; 
                      T_CONSULTA->ZP2_HEMI,;
                      T_CONSULTA->ZP2_SOLI,;
                      T_CONSULTA->ZP2_FILIAL})
                      
      T_CONSULTA->( DbSkip() )
      
   ENDDO
                            
   If Len(aBrowsek) == 0
      aAdd( aBrowsek, { '1', '', '', '', '', '', '', '', '', '' } )      
   Endif   

   If _PorOnde == 1
      Return(.T.)
   Endif

   // ############################################
   // Atualiza as estatística da tela principal ##
   // ############################################
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowsek:SetArray(aBrowsek) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowsek:bLine := {||{ If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowsek[oBrowsek:nAt,02],;
                         aBrowsek[oBrowsek:nAt,03],;
                         aBrowsek[oBrowsek:nAt,04],;
                         aBrowsek[oBrowsek:nAt,05],;
                         aBrowsek[oBrowsek:nAt,06],;
                         aBrowsek[oBrowsek:nAt,07],;
                         aBrowsek[oBrowsek:nAt,08],;
                         aBrowsek[oBrowsek:nAt,09],;
                         aBrowsek[oBrowsek:nAt,10]} }

Return(.T.)       

// ######################################################################
// Função que pesquisa produtos através da tela de PESQUISA AUTOMATECH ##
// ######################################################################
Static Function PesqAutom()

   Private k_Produto := Space(06)

   U_AUTOM184()                   
   
   If Empty(Alltrim(k_Produto))
      Return(.T.)
   Endif

   cProduto   := k_Produto
   cDescricao := Posicione("SB1", 1, xFilial("SB1") + k_Produto + Space(24), "B1_DESC")   
   oGet11:Refresh()
   oGet12:Refresh()
   
Return(.T.)   

// #####################################################################
// Função que pesquisa a descrição do produto informado ou pesquisado ##
// #####################################################################
Static Function PesqProSol(_Produto, _Tela)

   If Empty(Alltrim(_Produto))
      If _Tela == 1
         cDescricao := Space(60)
         oGet3:Refresh()
      Else
         cDescricao := Space(60)
         oGet12:Refresh()
      Endif
      Return(.T.)
   Endif

   cDescricao := Posicione("SB1", 1, xFilial("SB1") + _Produto + Space(24), "B1_DESC")   

   If _Tela == 1
      oGet3:Refresh()
   Else
      oGet12:Refresh()      
   Endif
   
Return(.T.)

// #####################################################################
// Função que pesquisa a descrição do produto informado ou pesquisado ##
// #####################################################################
Static Function ManuTransfe(_Operacao, _Solicitacao, _Filial)

   Local lChumba     := .F.
   Local lLiberar    := .F.
   Local lNrSerie    := .F.
   Local cMemo1	     := ""
   Local oMemo1
   Local lConfirma   := .F.

   Private aSetores	 := {}
   Private cSetores

   Private aStatusM  := {"00 - Todos Status", "02 - Solicitação", "04 - Empréstimo", "08 - Reprovada", "03 - Devolução Sinalizada", "05 - Devolução Confirmada", "06 - Pendentes"}
   Private aStatusA  := {"00 - Selecione", "04 - Aprova/Empréstimo" , "08 - Reprovado"}
   Private cComboBx1
   Private cComboBx2

   Private aSolicitante := {}
   Private cSolicitante := Space(20)
   Private cSerie	    := Space(30)
   Private cProduto	    := Space(06)
   Private cDescricao   := Space(60)
   Private cCodigo      := Space(09)
   Private cEmissao     := Ctod("  /  /    ")
   Private cData	    := Ctod("  /  /    ")
   Private cHora	    := Space(10)
   Private cAprovador   := Space(20)
   Private cQuantidade  := 1
   Private cSetor       := Space(03)
   Private cMemo1	    := ""
   Private cNota01      := ""
   Private cMemo3	    := ""
   Private cNota02	    := ""
   Private oGet1
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet2
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4

   Private oDlgM
   Private oDlgS
   
   // ################################################################################
   // Inicializa a variável boleana de liberarção de campos da aprovação/reprovação ##
   // ################################################################################
   Do Case
      Case _Operacao == "I"

           // ###############################################
           // Pesquisa os Cfops para carregas as variáveis ##
           // ###############################################
           If Select("T_SETORES") > 0
              T_SETORES->( dbCloseArea() )
           EndIf
    
           cSql := ""
           cSql := "SELECT ZZ4_SETO "
           cSql += "  FROM " + RetSqlName("ZZ4") + " (NoLock)"
 
           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SETORES", .T., .T. )
      
           If T_SETORES->( EOF() )
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando que não há setores paramentrizados.")
              Return(.T.)
           Endif
                            
           If Empty(Alltrim(T_SETORES->ZZ4_SETO))
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando que não há setores paramentrizados.")
              Return(.T.)
           Endif

           aAdd( aSetores, "XXX - Selecione o Setor" )

           For nContar = 1 to U_P_OCCURS(T_SETORES->ZZ4_SETO, "|", 1)
              aAdd( aSetores, U_P_CORTA(T_SETORES->ZZ4_SETO, "|", nContar) )
           Next nContar   

           DEFINE MSDIALOG oDlgS TITLE "Inclusão de Solicitação de Transferência" FROM C(178),C(181) TO C(351),C(471) PIXEL

           @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"                             Size C(138),C(030)                 PIXEL NOBORDER OF oDlgS
           @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO                              Size C(137),C(001)                 PIXEL OF oDlgS
           @ C(041),C(005) Say "Indique o setor que está abrindo esta solicitação" Size C(115),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
           @ C(051),C(005) ComboBox cSetores Items aSetores                        Size C(135),C(010)                 PIXEL OF oDlgS
           @ C(067),C(033) Button "Continuar"                                      Size C(037),C(012)                 PIXEL OF oDlgS ACTION( lConfirma := .F., oDlgS:End() )
           @ C(067),C(071) Button "Voltar"                                         Size C(037),C(012)                 PIXEL OF oDlgS ACTION( lConfirma := .T., oDlgS:End() )

           ACTIVATE MSDIALOG oDlgS CENTERED 

           If lConfirma == .T.
              Return(.T.)
           Endif

           // ########################################################################
           // Verifica se usuário selecionou um setor para continuar com a inclusão ##
           // ########################################################################
           If Substr(cSetores,01,03) == "XXX"
              MsgAlert("Nenhum setor foi selecionado. Inclusão não permitida.")
              Return(.T.)
           Endif

           lLiberar     := .F.
           cComboBx1    := "02 - Solicitação"
           cEmissao     := Date()
           cSolicitante := Alltrim(Upper(cUserName))
           cSetor       := Substr(cSetores,01,03) 

      Case _Operacao == "A" .Or. _Operacao == "E" .Or. _Operacao == "V" .Or. _Operacao == "P"

           If Select("T_ALTERACAO") > 0
              T_ALTERACAO->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT ZP2.ZP2_FILIAL,"
           cSql += "       ZP2.ZP2_CODI  ,"
           cSql += "       ZP2.ZP2_SOLI  ,"
           cSql += "       ZP2.ZP2_EMIS  ,"
           cSql += "       ZP2.ZP2_HEMI  ,"
           cSql += "       ZP2.ZP2_STAT  ,"
           cSql += "       ZP2.ZP2_PROD  ,"
           cSql += "       ZP2.ZP2_QUAN  ,"
           cSql += "       ZP2.ZP2_SERI  ,"
           cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZP2.ZP2_NOT1)) AS OBS01,"
           cSql += "       ZP2.ZP2_DTAA  ,"
           cSql += "       ZP2.ZP2_HORA  ,"
           cSql += "       ZP2.ZP2_APRO  ,"
           cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZP2.ZP2_NOT2)) AS OBS02,"
           cSql += "       ZP2.ZP2_DELE  ,"
           cSql += "       SB1.B1_DESC    "
           cSql += "  FROM " + RetSqlName("ZP2") + " ZP2 (NoLock), "
           cSql += "       " + RetSqlName("SB1") + " SB1 (NoLock)  "
           cSql += " WHERE ZP2.ZP2_FILIAL = '" + Alltrim(_Filial)      + "'"
           cSql += "   AND ZP2.ZP2_CODI   = '" + Alltrim(_Solicitacao) + "'"
           cSql += "   AND SB1.B1_COD     = ZP2.ZP2_PROD"
           cSql += "   AND SB1.B1_FILIAL  = ''"

           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALTERACAO", .T., .T. )

           If T_ALTERACAO->( EOF() )
              MsgAlert("Solicitação informada não cdastrada. Verifique!")
              Return(.T.)
           Endif
           
           If T_ALTERACAO->ZP2_DELE == "X"
              MsgAlert("Solicitação informada foi excluída. Verifique!")
              Return(.T.)
           Endif
                 
           If _Operacao <> "V"
              If !Empty(Alltrim(T_ALTERACAO->ZP2_APRO))
                 MsgAlert("Solicitação informada já foi Aprovada/Reprovada. Utilize opção de Visualização.")
                 Return(.T.)
              Endif
           Endif   
              
           // #####################################
           // Carrega as variáveis para trabalho ##
           // #####################################          
           cCodigo      := T_ALTERACAO->ZP2_CODI
           cSolicitante := T_ALTERACAO->ZP2_SOLI
           cEmissao     := Substr(T_ALTERACAO->ZP2_EMIS,07,02) + "/" + Substr(T_ALTERACAO->ZP2_EMIS,05,02) + "/" + Substr(T_ALTERACAO->ZP2_EMIS,01,04)
      
           Do Case
              Case T_ALTERACAO->ZP2_STAT == "2"
                   cComboBx1 := "02 - Solicitação"
              Case T_ALTERACAO->ZP2_STAT == "4"
                   cComboBx1 := "04 - Empréstimo"
              Case T_ALTERACAO->ZP2_STAT == "8"
                   cComboBx1 := "08 - Reprovado"
           EndCase

           cProduto    := T_ALTERACAO->ZP2_PROD
           cDescricao  := T_ALTERACAO->B1_DESC
           cQuantidade := T_ALTERACAO->ZP2_QUAN
           cSerie      := T_ALTERACAO->ZP2_SERI
           cNota01     := T_ALTERACAO->OBS01
           cData       := Substr(T_ALTERACAO->ZP2_DTAA,07,02) + "/" + Substr(T_ALTERACAO->ZP2_DTAA,05,02) + "/" + Substr(T_ALTERACAO->ZP2_DTAA,01,04)
           cHora       := T_ALTERACAO->ZP2_HORA
           cAprovador  := T_ALTERACAO->ZP2_APRO
           cNota02     := T_ALTERACAO->OBS02

           // ############################################################################
           // Carrega variáveis da Aprovação/Reprovação de Solicitação de Transferência ##
           // ############################################################################
           If _Operacao == "P"
              If Empty(T_ALTERACAO->ZP2_DTAA)
                 cData := Date()
                 cHora := Time()
              Else
                 cData := Substr(T_ALTERACAO->ZP2_DTAA,07,02) + "/" + Substr(T_ALTERACAO->ZP2_DTAA,05,02) + "/" + Substr(T_ALTERACAO->ZP2_DTAA,01,04)
                 cHora := T_ALTERACAO->ZP2_HORA
              Endif
                 
              cNota02     := Alltrim(T_ALTERACAO->OBS02)
              cSerie      := T_ALTERACAO->ZP2_SERI
              
              cAprovador := Alltrim(Upper(cUserName))

              // ####################################################################################
              // Verifica se o produto da solicitação é controlado por nº de série.                ##
              // Isso serve para abrir ou não o campo nº de série da tela de aprovação/reporvação. ##
              // ####################################################################################
              If Posicione("SB1", 1, xFilial("SB1") + Alltrim(cProduto) + Space(24), "B1_LOCALIZ") == "S"
                 lNrSerie := .T.
              Else
                 lNrSerie := .F.                 
              Endif

           Endif
           
   EndCase        

   // ##############################################
   // Desenha a tela de manutenção da solicitação ##
   // ##############################################
   DEFINE MSDIALOG oDlgM TITLE "Solicitação de Transferência de Mercadorias" FROM C(178),C(181) TO C(638),C(737) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlgM

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(268),C(001) PIXEL OF oDlgM
   @ C(128),C(005) GET oMemo3 Var cMemo3 MEMO Size C(268),C(001) PIXEL OF oDlgM
   
   @ C(041),C(005) Say "Nº Solicitação"                      Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(041),C(050) Say "Solicitante"                         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(041),C(132) Say "Data Emissão"                        Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(041),C(177) Say "Status"                              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(064),C(178) Say "Qtd"                                 Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(064),C(204) Say "Nº de Série"                         Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(065),C(005) Say "Produto"                             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(087),C(005) Say "Observações"                         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(133),C(005) Say "APROVAÇÃO / REPROVAÇÃO"              Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(145),C(005) Say "Data"                                Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(145),C(046) Say "Hora"                                Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(145),C(088) Say "Observações da Aprovação/Reprovação" Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(168),C(005) Say "Status"                              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(189),C(005) Say "Aprovado Por"                        Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   If _Operacao <> "P"
      If _Operacao == "I" .Or. _Operacao == "A"
         @ C(050),C(005) MsGet    oGet2     Var   cCodigo      Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(050),C(050) MsGet    oGet1     Var   cSolicitante Size C(071),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM F3("US3") When lChumba
         @ C(050),C(132) MsGet    oGet4     Var   cEmissao     Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(050),C(177) ComboBox cComboBx1 Items aStatusM     Size C(096),C(010)                              PIXEL OF oDlgM When lChumba
         @ C(074),C(005) MsGet    oGet11    Var   cProduto     Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM VALID( PesqProSol(cProduto, 2) )
         @ C(074),C(037) Button "..."                          Size C(008),C(009)                              PIXEL OF oDlgM ACTION( PesqAutom() )
         @ C(074),C(050) MsGet    oGet12    Var   cDescricao   Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(074),C(177) MsGet    oGet8     Var   cQuantidade  Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(074),C(204) MsGet    oGet10    Var   cSerie       Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lLiberar
  	     @ C(074),C(261) Button "..."                          Size C(010),C(009)                              PIXEL OF oDlgM When lChumba
         @ C(096),C(005) GET      oMemo2    Var   cNota01 MEMO Size C(228),C(028)                              PIXEL OF oDlgM
      Else
         @ C(050),C(005) MsGet    oGet2     Var   cCodigo      Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(050),C(050) MsGet    oGet1     Var   cSolicitante Size C(071),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(050),C(132) MsGet    oGet4     Var   cEmissao     Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(050),C(177) ComboBox cComboBx1 Items aStatusM     Size C(096),C(010)                              PIXEL OF oDlgM When lChumba
         @ C(074),C(005) MsGet    oGet11    Var   cProduto     Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(074),C(037) Button "..."                          Size C(008),C(009)                              PIXEL OF oDlgM When lChumba
         @ C(074),C(050) MsGet    oGet12    Var   cDescricao   Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(074),C(177) MsGet    oGet8     Var   cQuantidade  Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
         @ C(074),C(204) MsGet    oGet10    Var   cSerie       Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
  	     @ C(074),C(261) Button "..."                          Size C(010),C(009)                              PIXEL OF oDlgM When lChumba
         @ C(096),C(005) GET      oMemo2    Var   cNota01 MEMO Size C(228),C(028)                              PIXEL OF oDlgM When lChumba
      Endif      

      Do Case 
         Case _Operacao == "I"
              @ C(098),C(235) Button "Salvar"                       Size C(037),C(012)                              PIXEL OF oDlgM ACTION( GravaTransfe(_Operacao, cCodigo, _Filial) )
         Case _Operacao == "A"
              @ C(098),C(235) Button "Salvar"                       Size C(037),C(012)                              PIXEL OF oDlgM ACTION( GravaTransfe(_Operacao, cCodigo, _Filial) )
         Case _Operacao == "V"
              @ C(098),C(235) Button "Salvar"                       Size C(037),C(012)                              PIXEL OF oDlgM When lChumba
         Case _Operacao == "E"
              @ C(098),C(235) Button "Excluir"                      Size C(037),C(012)                              PIXEL OF oDlgM ACTION( GravaTransfe(_Operacao, cCodigo, _Filial) )
      EndCase

      @ C(112),C(235) Button "Voltar"                       Size C(037),C(012)                              PIXEL OF oDlgM ACTION( oDlgM:End() )
      @ C(155),C(005) MsGet    oGet5     Var   cData        Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lLiberar
      @ C(155),C(046) MsGet    oGet6     Var   cHora        Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lLiberar
      @ C(155),C(088) GET oMemo4         Var   cNota02 MEMO Size C(184),C(053)                              PIXEL OF oDlgM When lLiberar
      @ C(177),C(005) ComboBox cComboBx2 Items aStatusA     Size C(077),C(010)                              PIXEL OF oDlgM When lLiberar
      @ C(199),C(005) MsGet    oGet7     Var   cAprovador   Size C(077),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lLiberar
      @ C(213),C(102) Button "Salvar"                       Size C(037),C(012)                              PIXEL OF oDlgM When lLiberar
      @ C(213),C(141) Button "Voltar"                       Size C(037),C(012)                              PIXEL OF oDlgM When lLiberar
   Else
      @ C(050),C(005) MsGet    oGet2     Var   cCodigo      Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(050),C(050) MsGet    oGet1     Var   cSolicitante Size C(071),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(050),C(132) MsGet    oGet4     Var   cEmissao     Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(050),C(177) ComboBox cComboBx1 Items aStatusM     Size C(096),C(010)                              PIXEL OF oDlgM When lChumba
      @ C(074),C(005) MsGet    oGet11    Var   cProduto     Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(074),C(037) Button "..."                          Size C(008),C(009)                              PIXEL OF oDlgM When lChumba
      @ C(074),C(050) MsGet    oGet12    Var   cDescricao   Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(074),C(177) MsGet    oGet8     Var   cQuantidade  Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(074),C(204) MsGet    oGet10    Var   cSerie       Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM VALID( VeSeriePro( cProduto, cSerie, _Filial ) ) When lNrSerie
      @ C(074),C(261) Button "..."                          Size C(010),C(009)                              PIXEL OF oDlgM ACTION( VeNumSerie( cProduto, _Filial ) )        When lNrSerie
      @ C(096),C(005) GET      oMemo2    Var   cNota01 MEMO Size C(228),C(028)                              PIXEL OF oDlgM When lChumba

      Do Case 
         Case _Operacao == "I"
              @ C(098),C(235) Button "Salvar"               Size C(037),C(012)                              PIXEL OF oDlgM ACTION( GravaTransfe(_Operacao, cCodigo, _Filial) )
         Case _Operacao == "A"
              @ C(098),C(235) Button "Salvar"               Size C(037),C(012)                              PIXEL OF oDlgM ACTION( GravaTransfe(_Operacao, cCodigo, _Filial) )
         Case _Operacao == "V"
              @ C(098),C(235) Button "Salvar"               Size C(037),C(012)                              PIXEL OF oDlgM When lChumba
         Case _Operacao == "E"
              @ C(098),C(235) Button "Excluir"              Size C(037),C(012)                              PIXEL OF oDlgM ACTION( GravaTransfe(_Operacao, cCodigo, _Filial) )
      EndCase

      @ C(112),C(235) Button "Voltar"                       Size C(037),C(012)                              PIXEL OF oDlgM When lChumba
      @ C(155),C(005) MsGet    oGet5     Var   cData        Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(155),C(046) MsGet    oGet6     Var   cHora        Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(155),C(088) GET oMemo4         Var   cNota02 MEMO Size C(184),C(053)                              PIXEL OF oDlgM
      @ C(177),C(005) ComboBox cComboBx2 Items aStatusA     Size C(077),C(010)                              PIXEL OF oDlgM
      @ C(199),C(005) MsGet    oGet7     Var   cAprovador   Size C(077),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(213),C(102) Button "Salvar"                       Size C(037),C(012)                              PIXEL OF oDlgM ACTION( GravaTransfe(_Operacao, cCodigo, _Filial) )
      @ C(213),C(141) Button "Voltar"                       Size C(037),C(012)                              PIXEL OF oDlgM ACTION( oDlgM:End() )
   Endif      

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// ################################################################
// Função que realiza a gravação da solicitação de transferência ##
// ################################################################
Static Function GravaTransfe(_Operacao, _Codigo, _Filial)

   Local cSql     := ""
   Local aAuto    := {}
   Local aItem    := {}
   Local _xDOCx   := ""
   Local cLote    := "   "
   Local dDataVl  := ""
   Local nQuant   := 1
   Local nOpcAuto := 3 // Indica qual tipo de ação será tomada (Inclusão/Exclusão)

   PRIVATE lMsHelpAuto := .T.
   PRIVATE lMsErroAuto := .F.

   // #####################################################
   // Realiza a consistência dos dados antes da gravação ##
   // #####################################################
   If Empty(Alltrim(cSolicitante))
      MsgAlert("Solicitante não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cProduto))
      MsgAlert("Produto não informado.")
      Return(.T.)
   Endif
       
   // #######################
   // Aprovação/Reprovação ##
   // #######################
   If _Operacao == "P"

      If Substr(cComboBx2,01,02) == "00"
         MsgAlert("Status de Aprovação/Reprovação não indicado. Verifique!")
         Return(.T.)
      Endif

      If Substr(cComboBx2,01,02) == "08"
      Else
         If Posicione("SB1", 1, xFilial("SB1") + Alltrim(cProduto) + Space(24), "B1_LOCALIZ") == "S"
            If Empty(Alltrim(cSerie))
               MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Produto da solicitação possui controle de localização." + chr(13) + chr(10) + "O nº de série do produto não foi informado." + chr(13) + chr(10) + "Verifique!")
               Return(.T.)
            Endif
         Endif
      Endif
      
   Endif

   // ##########################
   // Inclusão de Solicitação ##
   // ##########################
   If _Operacao == "I"

      // ##########################################
      // Pesquisa o próximo código para inclusão ##
      // ##########################################
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZP2_CODI"
      cSql += "  FROM " + RetSqlName("ZP2") + " (NoLock)"
      cSql += " ORDER BY ZP2_CODI DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         cCodigo := "000001" + cSetor
      Else
         cCodigo := STRZERO(INT(VAL(T_PROXIMO->ZP2_CODI)) + 1,6) + cSetor
      Endif

      aArea := GetArea()
      dbSelectArea("ZP2")
      RecLock("ZP2",.T.)
      ZP2_FILIAL := cFilAnt
      ZP2_CODI   := cCodigo
      ZP2_SOLI   := cSolicitante
      ZP2_EMIS   := cEmissao
      ZP2_HEMI   := Time()
      ZP2_STAT   := Substr(cComboBx1,02,01)
      ZP2_PROD   := cProduto
      ZP2_UNID   := Posicione("SB1", 1, xFilial("SB1") + Alltrim(cProduto) + Space(24), "B1_UM")
      ZP2_QUAN   := cQuantidade
      ZP2_SERI   := cSerie
      ZP2_ENDE   := ""
      ZP2_NOT1   := cNota01
      ZP2_DTAA   := cData
      ZP2_HORA   := cHora
      ZP2_APRO   := cAprovador
      ZP2_NOT2   := cNota02
      ZP2_ALM1   := '01'
      ZP2_ALM2   := ''
      ZP2_IDSO   := __CUserID
      MsUnLock()

      // ############################################
      // Envia e-mail ao departamento de logística ##
      // ############################################
      EnviaEmailSol(1, "", "")

   Endif

   // ###########################
   // Aletração de Solicitação ##
   // ###########################
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZP2")
      DbSetOrder(1)
      If DbSeek(_Filial + _Codigo)
         RecLock("ZP2",.F.)
         ZP2_SOLI   := cSolicitante
         ZP2_PROD   := cProduto
         ZP2_NOT1   := cNota01
         ZP2_ALM1   := '01'
         MsUnLock()
      Endif
   
   Endif

   // ######################################################################
   // Aprovação/Reprovação de Solicitação de Transferência de Mercadorias ##
   // ######################################################################
   If _Operacao == "P"

      // ####################################################################
      // Pesquisa o endereço do nº de série para gravação na tabela ZP2010 ##
      // ####################################################################
      If !Empty(Alltrim(cSerie))
         DbSelectArea("SBF")
         DbSetOrder(4)
         If DbSeek(xFilial("SBF") + (Alltrim(cProduto) + Space(24)) +( Alltrim(cSerie) + Space(20 - Len(Alltrim(cSerie)))) )
            __Endereco := SBF->BF_LOCALIZ
         Else
            __Endereco := SBF->BF_LOCALIZ         
         Endif
      Else
         __Endereco := Space(15)
      Endif

      // ###########################################################################
      // Em caso de Aprovação, realiza o registro da transferência entre armazéns ##
      // ###########################################################################
      If Substr(cComboBx2,01,02) == "04"         

         // ###########################
         // Captura dados do produto ##
         // ###########################
         DbSelectArea("SB1")
         DbSetOrder(1)

         If SB1->(MsSeek(xFilial("SB1")+Alltrim(cProduto) + Space(24)))
            cProd   := B1_COD
            cDescri := B1_DESC
            cUM     := B1_UM
            cLocal  := B1_LOCPAD
         Else
            MsgAlert("Dados do produto informado não localizado.")
            Return(.T.)
         EndIf

         _UnidadeMed := Posicione("SB1", 1, xFilial("SB1") + Alltrim(cProduto) + Space(24), "B1_UM")
         _xDOCx      := GetSxENum("SD3","D3_DOC",1)
         cLote       := "   "
         dDataVl     := CTOD("  /  /    ")
         nQuant      := 1
         nOpcAuto    := 3
            
         // ###############################################################
         // Verifica se existe local de origem para o produto de origem  ##
         // ###############################################################
         DbSelectArea("SB2")
         DbSetOrder(1)
         IF !SB2->(DBSEEK(xFilial("SB2") + Alltrim(cProduto) + Space(24) + "01" ))      
            CriaSB2( cProduto, "01")
         ENDIF     

         // ###############################################################
         // Verifica se existe local de destino para o produto de origem ##
         // ###############################################################
         Do Case
            Case Substr(_Codigo,07,03) == "PRJ"
                 IF !SB2->(DBSEEK(xFilial("SB2") + Alltrim(cProduto) + Space(24) + "98" ))      
                    CriaSB2( cProduto, "98")
                 ENDIF     
            Case Substr(_Codigo,07,03) == "AST"
                 IF !SB2->(DBSEEK(xFilial("SB2") + Alltrim(cProduto) + Space(24) + "99" ))      
                    CriaSB2( cProduto, "99")
                 ENDIF     
         EndCase                 

         // ###########################################################################################
         // Realiza a transferência do armazém 01 para o armazém 98 ou 99 conforme setor selecionado ##
         // ###########################################################################################
         Begin Transaction

            // ######################
            // Cabecalho a Incluir ##
            // ###################### 
            aAuto := {}
            aadd(aAuto,{_xDOCx,dDataBase}) //Cabecalho

            // ##################################
            // Dados do item a ser transferido ##
            // ##################################
            aadd(aItem,cProd)         // 01 - D3_COD  
            aadd(aItem,cDescri)       // 02 - D3_DESCRI
            aadd(aItem,cUM)           // 03 - D3_UM
            aadd(aItem,"01")          // 04 - D3_LOCAL

            If Empty(Alltrim(cSerie)) 
               aadd(aItem,"")         // 05 - D3_LOCALIZ DE ORIGEM
            Else
               aadd(aItem,"GENERICO") // 05 - D3_LOCALIZ DE ORIGEM               
            Endif   

            aadd(aItem,cProd)         // 06 - D3_COD
            aadd(aItem,cDescri)       // 07 - D3_DESCRI
            aadd(aItem,cUM)           // 08 - D3_UM

            Do Case
               Case Substr(_Codigo,07,03) == "PRJ" 
                    aadd(aItem,"98")          // 09 - D3_LOCAL
               Case Substr(_Codigo,07,03) == "AST" 
                    aadd(aItem,"99")          // 09 - D3_LOCAL
            EndCase                   
            
            // ##########################################################################
            // Localização do produto se este tiver controle de endereçamento indicado ##
            // ##########################################################################
            If Empty(Alltrim(cSerie)) 
               aadd(aItem,"")         // 10 - D3_LOCALIZ
            Else   
               Do Case
                  Case Substr(_Codigo,07,03) == "PRJ" 
                       aadd(aItem,"PROJETOS") // 10 - D3_LOCALIZ
                  Case Substr(_Codigo,07,03) == "AST" 
                       aadd(aItem,"TECNICA")  // 10 - D3_LOCALIZ
               EndCase
            Endif   

            // #######################################################
            // Nº de Série se produto com controle de endereçamento ##
            // #######################################################
            If Empty(Alltrim(cSerie)) 
               aadd(aItem,"")         // 11 - D3_NUMSERI
            Else   
               aadd(aItem,cSerie)     // 11 - D3_NUMSERI
            Endif   

            aadd(aItem,cLote)    // 12 - D3_LOTECTL
            aadd(aItem,"")       // 13 - D3_NUMLOTE
            aadd(aItem,dDataVl)  // 14 - D3_DTVALID
            aadd(aItem,0)        // 15 - D3_POTENCI
            aadd(aItem,nQuant)   // 16 - D3_QUANT
            aadd(aItem,0)        // 17 - D3_QTSEGUM
            aadd(aItem,"")       // 18 - D3_ESTORNO
            aadd(aItem,"")       // 19 - D3_NUMSEQ
            aadd(aItem,cLote)    // 20 - D3_LOTECTL
            aadd(aItem,dDataVl)  // 21 - D3_DTVALID
            aadd(aItem,"")       // 22 - D3_ITEMGRD
            aadd(aAuto,aItem)
  
            MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

            If !lMsErroAuto
               MsgAlert("Transferência entre o armazém 01 para o armazém 98 realizada com sucesso.")
            Else
               MostraErro()
            EndIf

         End Transaction

      Endif

      // ########################
      // Grava a tabela ZP2010 ##
      // ########################
      aArea := GetArea()

      DbSelectArea("ZP2")
      DbSetOrder(1)
      If DbSeek(_Filial + _Codigo)
         RecLock("ZP2",.F.)
         ZP2_DTAA := cData
         ZP2_HORA := cHora
         ZP2_APRO := cAprovador
         ZP2_SERI := cSerie
         ZP2_ENDE := __Endereco
         ZP2_NOT2 := cNota02
         ZP2_STAT := Substr(cComboBx2,02,01)
         MsUnLock()

         // ############################################
         // Envia e-mail ao departamento de logística ##
         // ############################################
         EnviaEmailSol(2, cSerie, Substr(cComboBx2,01,02))

      Endif

   Endif

   // ##########################
   // Exclusão de Solicitação ##
   // ##########################
   If _Operacao == "E"

      If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente cancelar esta solicitação de transferência?")

         aArea := GetArea()

         DbSelectArea("ZP2")
         DbSetOrder(1)
         If DbSeek(_Filial + _Codigo)
            RecLock("ZP2",.F.)
            ZP2_DELE   := "X"
            MsUnLock()
         Endif
   
      Else
      
         Return(.T.)
      
      Endif
      
   Endif   

   oDlgM:End()

   cProduto     := Space(06)
   cDescricao   := Space(60)
   cSerie       := Space(30)
   cSolicitante := Space(25)
   cCodigo      := Space(30)
   cComboBx1    := "00 - Todos Status"

   oGet2:Refresh()
   oGet3:Refresh()
   oGet5:Refresh()
   oGet1:Refresh()
   oGet4:Refresh()

   CarregaGridSol(2)

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowsek:SetArray(aBrowsek) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowsek:bLine := {||{ If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "1", oBranco  ,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "2", oVerde   ,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "3", oPink    ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "4", oAmarelo ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "7", oPreto   ,;                         
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "8", oVermelho,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(aBrowsek[oBrowsek:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                          aBrowsek[oBrowsek:nAt,02],;
                          aBrowsek[oBrowsek:nAt,03],;
                          aBrowsek[oBrowsek:nAt,04],;
                          aBrowsek[oBrowsek:nAt,05],;
                          aBrowsek[oBrowsek:nAt,06],;
                          aBrowsek[oBrowsek:nAt,07],;
                          aBrowsek[oBrowsek:nAt,08],;
                          aBrowsek[oBrowsek:nAt,09],;
                          aBrowsek[oBrowsek:nAt,10]} }

Return(.T.)

// ########################################
// Função que abre a janela das legendas ##
// ########################################
Static Function MostraLegSol()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo6	 := ""
   Local cMemo7	 := ""
   Local cMemo8	 := ""
   Local cMemo9	 := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo6
   Local oMemo7
   Local oMemo8
   Local oMemo9

   Private oDlgL

   DEFINE MSDIALOG oDlgL TITLE "Solicitação de Transferência de Mercadorias" FROM C(178),C(181) TO C(601),C(598) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlgL
   @ C(045),C(125) Jpeg FILE "br_verde"        Size C(009),C(009) PIXEL NOBORDER OF oDlgL
   @ C(111),C(067) Jpeg FILE "br_amarelo"      Size C(009),C(009) PIXEL NOBORDER OF oDlgL
   @ C(111),C(187) Jpeg FILE "br_vermelho"     Size C(009),C(009) PIXEL NOBORDER OF oDlgL
   @ C(139),C(067) Jpeg FILE "br_pink"         Size C(009),C(009) PIXEL NOBORDER OF oDlgL
   @ C(168),C(067) Jpeg FILE "br_azul"         Size C(009),C(009) PIXEL NOBORDER OF oDlgL

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(200),C(001) PIXEL OF oDlgL
   @ C(057),C(094) GET oMemo3 Var cMemo3 MEMO Size C(001),C(014) PIXEL OF oDlgL
   @ C(083),C(094) GET oMemo4 Var cMemo4 MEMO Size C(001),C(012) PIXEL OF oDlgL
   @ C(096),C(034) GET oMemo5 Var cMemo5 MEMO Size C(120),C(001) PIXEL OF oDlgL
   @ C(096),C(034) GET oMemo6 Var cMemo6 MEMO Size C(001),C(013) PIXEL OF oDlgL
   @ C(096),C(153) GET oMemo7 Var cMemo7 MEMO Size C(001),C(013) PIXEL OF oDlgL
   @ C(122),C(034) GET oMemo8 Var cMemo8 MEMO Size C(001),C(016) PIXEL OF oDlgL
   @ C(151),C(034) GET oMemo9 Var cMemo9 MEMO Size C(001),C(016) PIXEL OF oDlgL
   @ C(188),C(003) GET oMemo2 Var cMemo2 MEMO Size C(200),C(001) PIXEL OF oDlgL

   @ C(044),C(067) Button "Solicitação"     Size C(055),C(012) PIXEL OF oDlgL
   @ C(071),C(067) Button "Aprova/Reprova"  Size C(055),C(012) PIXEL OF oDlgL
   @ C(110),C(006) Button "Aprovado"        Size C(055),C(012) PIXEL OF oDlgL
   @ C(110),C(126) Button "Reprovado"       Size C(055),C(012) PIXEL OF oDlgL
   @ C(138),C(006) Button "Dev.Sinalizada"  Size C(055),C(012) PIXEL OF oDlgL
   @ C(167),C(006) Button "Dev. Confirmada" Size C(055),C(012) PIXEL OF oDlgL
   @ C(194),C(085) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// ###########################################
// Função que abre a janela dos Parâmetros  ##
// ###########################################
Static Function AbreParam()

   Local cUsua01 := Space(20)
   Local cUsua02 := Space(20)
   Local cUsua03 := Space(20)
   Local cEmai01 := Space(250)
   Local cEmai02 := Space(250)
   Local cEmai03 := Space(250)
   Local cSiglas := Space(250)
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oMemo1
   Local oMemo2

   Private oDlgP

   // ###############################################
   // Pesquisa os Cfops para carregas as variáveis ##
   // ###############################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ST01, "
   cSql += "       ZZ4_ST02, "
   cSql += "       ZZ4_ST03, "
   cSql += "       ZZ4_EM01, "
   cSql += "       ZZ4_EM02, "
   cSql += "       ZZ4_EM03, "   
   cSql += "       ZZ4_SETO  "
   cSql += "  FROM " + RetSqlName("ZZ4") + " (NoLock)"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cUsua01 := T_PARAMETROS->ZZ4_ST01
      cUsua02 := T_PARAMETROS->ZZ4_ST02
      cUsua03 := T_PARAMETROS->ZZ4_ST03
      cEmai01 := T_PARAMETROS->ZZ4_EM01
      cEmai02 := T_PARAMETROS->ZZ4_EM02
      cEmai03 := T_PARAMETROS->ZZ4_EM03      
      cSiglas := T_PARAMETROS->ZZ4_SETO
   Endif

   DEFINE MSDIALOG oDlgP TITLE "Solicitação de Transferência de Mercadorias" FROM C(178),C(181) TO C(499),C(743) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlgP

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(273),C(001) PIXEL OF oDlgP
   @ C(108),C(003) GET oMemo2 Var cMemo2 MEMO Size C(273),C(001) PIXEL OF oDlgP

   @ C(043),C(005) Say "Informe os usuário que possuem autorização para Aprovar/Reprovar Solicitação de Transferência de Mercadorias." Size C(272),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(058),C(005) Say "APROVADOR /  REPROVADOR"                                                                                       Size C(082),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(058),C(126) Say "E-MAIL"                                                                                                        Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(112),C(005) Say "Siglas de Setores (Utilizar três caracteres para identificação dos setores - Exemplo: Projetos = PRJ)"         Size C(236),C(008) COLOR CLR_BLACK PIXEL OF oDlgP  
   @ C(120),C(005) Say "A informação dos setores deve necessariamente serem separados por Pipe ( | )"                                  Size C(189),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
 	
   @ C(068),C(005) MsGet oGet1 Var cUsua01 Size C(115),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(068),C(126) MsGet oGet4 Var cEmai01 Size C(149),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(081),C(005) MsGet oGet2 Var cUsua02 Size C(115),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(081),C(126) MsGet oGet5 Var cEmai02 Size C(149),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(094),C(005) MsGet oGet3 Var cUsua03 Size C(115),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(094),C(126) MsGet oGet6 Var cEmai03 Size C(149),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(130),C(005) MsGet oGet7 Var cSiglas Size C(271),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP

   @ C(144),C(121) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( GravaParSol(cUsua01, cUsua02, cUsua03, cEmai01, cEmai02, cEmai03, cSiglas) )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// #################################
// Função que grava os parâmetros ##
// #################################
Static Function GravaParSol(_cUsua01, _cUsua02, _cUsua03, _cEmai01, _cEmai02, _cEmai03, _Siglas)

   Local cSql := ""
   
   // ######################################################
   // Verifica se existe algum registro na Tabela ZZ4010. ##
   // Se não existir, inclui senão altera                 ##
   // ######################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " (NoLock) WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif
   
   ZZ4_ST01 := _cUsua01
   ZZ4_ST02 := _cUsua02
   ZZ4_ST03 := _cUsua03
   ZZ4_EM01 := _cEmai01
   ZZ4_EM02 := _cEmai02
   ZZ4_EM03 := _cEmai03
   ZZ4_SETO := _Siglas

   MsUnLock()

   oDlgP:End() 

   // ###########################################
   // Envia para a função que valida aprovador ##
   // ###########################################
   VerAproUsua()

   oDlg:End()
   
   U_AUTOM264()
   
Return(.T.)

// #######################################################
// Função que retorna .T./.F. para o usuário aprovador  ##
// #######################################################
Static Function VerAproUsua()

   Local cSql     := ""
   Local lRetorno := .F.

   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ST01, "
   cSql += "       ZZ4_ST02, "
   cSql += "       ZZ4_ST03  "
   cSql += "  FROM " + RetSqlName("ZZ4") + " (NoLock)"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      lRetorno := .F.
   Else

      lAprova := .F.
      
      If Alltrim(Upper(cUserName)) == Alltrim(Upper(T_PARAMETROS->ZZ4_ST01))
         lRetorno := .T.
      Endif
         
      If Alltrim(Upper(cUserName)) == Alltrim(Upper(T_PARAMETROS->ZZ4_ST02))
         lRetorno := .T.
      Endif

      If Alltrim(Upper(cUserName)) == Alltrim(Upper(T_PARAMETROS->ZZ4_ST03))
         lRetorno := .T.
      Endif

   Endif

Return lRetorno

// ###########################################################
// Função que verifica se nº de série existe para o produto ##
// ###########################################################
Static Function VeSeriePro( _cProduto, _cSerie, _cFilial )

   Local cSql := ""

   If Empty(Alltrim(_cSerie))
      Return(.T.)
   Endif

   If Select("T_SERIE") > 0
      T_SERIE->( dbCloseArea() )
   EndIf

   cSql := "SELECT BF_NUMSERI"
   cSql += "  FROM " + RetSqlName("SBF") + " (NoLock)"
   cSql += " WHERE BF_FILIAL  = '" + Alltrim(_cFilial)  + "'"
   cSql += "   AND BF_LOCAL   = '01'"
   cSql += "   AND BF_PRODUTO = '" + Alltrim(_cProduto) + "'"
   cSql += "   AND BF_NUMSERI = '" + Alltrim(_cSerie)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )
   
   If T_SERIE->( EOF() )
      MsgAlert("Nº de série informado inexistente.")
      cSerie := Space(30)
      oGet10:Refresh()
      Return(.T.)
   Endif
               
   If Empty(Alltrim(T_SERIE->BF_NUMSERI))
      MsgAlert("Nº de série informado inexistente.")
      cSerie := Space(30)
      oGet10:Refresh()
      Return(.T.)
   Endif

Return(.T.)

// ################################################################################
// Função que mostra os nºs de séries do produto da solicitação de transferência ##
// ################################################################################
Static Function VeNumSerie( _cProduto, _cFilial)

   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1
   Local oOk     := LoadBitmap( GetResources(), "LBOK" )
   Local oNo     := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgSer

   Private aLista := {}
   Private oLista

   If Select("T_SERIE") > 0
      T_SERIE->( dbCloseArea() )
   EndIf

   cSql := "SELECT BF_NUMSERI"
   cSql += "  FROM " + RetSqlName("SBF") + " (NoLock)"
   cSql += " WHERE BF_FILIAL  = '" + Alltrim(_cFilial)  + "'"
   cSql += "   AND BF_LOCAL   = '01'"
   cSql += "   AND BF_PRODUTO = '" + Alltrim(_cProduto) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

   aLista := {}

   WHILE !T_SERIE->( EOF() )
      If Empty(Alltrim(cSerie))
         aAdd( aLista, { .F., T_SERIE->BF_NUMSERI } )
      Else   
         If Alltrim(T_SERIE->BF_NUMSERI) == Alltrim(cSerie)
            aAdd( aLista, { .T., T_SERIE->BF_NUMSERI } )            
         Else
            aAdd( aLista, { .F., T_SERIE->BF_NUMSERI } )
         Endif
      Endif
      T_SERIE->( DbSkip() )
   ENDDO
            
   If Len(aLista) == 0
      aAdd( aLista, { .F., "" } )
   Endif

   // #####################################################
   // Desenha a tela para visualização dos nºs de séries ##
   // #####################################################
   DEFINE MSDIALOG oDlgSer TITLE "Solicitação de Transferência de Mercadorias" FROM C(178),C(181) TO C(640),C(471) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlgSer

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(136),C(001) PIXEL OF oDlgSer

   @ C(041),C(005) Say "Nºs de Séries do Produto" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgSer

   @ C(217),C(053) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgSer ACTION( FechaLista() )

   @ 065,005 LISTBOX oLista FIELDS HEADER "M", "Nºs de Séries" PIXEL SIZE 170,205 OF oDlgSer ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )
   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo), aLista[oLista:nAt,02]}}

   ACTIVATE MSDIALOG oDlgSer CENTERED 

Return(.T.)

// ############################################################################
// Função que consiste e fecha a tela de lista dos nºs de séries pesquisados ##
// ############################################################################
Static Function FechaLista()

   Local nContar   := 0
   Local nMarcados := 0
   
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          cSerie    := aLista[nContar,02]
          nMarcados := nMarcados + 1
       Endif
   Next nContar
   
   If nMarcados == 0
      cSerie := Space(30)
      oGet10:Refresh()
      Return(.T.)
   Endif
   
   If nMarcados > 1
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Permitido a marcado de somente um nº de série para o produto informado." + chr(13) + chr(10) + "Verifique!")
      cSerie := Space(30)
      oGet10:Refresh()
      Return(.T.)
   Endif

   oGet10:Refresh()

   oDlgSer:End()
      
Return(.T.)

// ########################################################################################
// Função que envia e-mail ao solicitante ou para o grupo de aprovadores                 ##
//                                                                                       ##
// _TipoEmail = 1 - Indica envio de e-mail pela abertura de solicitação de transferência ##
//              2 - Indica que a solicitação foi aprovada ou reprovada pela logística    ##
// Nº de Série: Em caso de Aprovação ou Reporovação, é passado o nº de série.            ##
// Status: Em caso de Aprovação ou Reporovação, é passado o Status Aprovado ou Reprovado ##
// ########################################################################################
Static Function EnviaEmailSol(_TipoEmail, _Serie, _Status)

   Local cTexto    := ""
   Local cId       := ""
   Local aUsuarios := {}
   Local cEmail    := ""
   Local cEndereco := Space(250)
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oGet1
   Local oMemo1
   Local oMemo2

   Private oDlgEmail
   
   If _TipoEmail == 1

      // ########################################################
      // Pesquisa o endereço de e-mail do aprovador/reprovador ##
      // ########################################################
      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT A.ZZ4_ST01, "
      cSql += "       A.ZZ4_ST02, "
      cSql += "       A.ZZ4_ST03, "
      cSql += "       A.ZZ4_EM01, "
      cSql += "       A.ZZ4_EM02, "
      cSql += "       A.ZZ4_EM03  "
      cSql += "  FROM " + RetSqlName("ZZ4") + " A (NoLock) "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      cEmail := ""

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_EM01))
         cEmail := Alltrim(T_PARAMETROS->ZZ4_EM01) + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_EM02))
         cEmail := Alltrim(T_PARAMETROS->ZZ4_EM02) + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_EM03))
         cEmail := Alltrim(T_PARAMETROS->ZZ4_EM03) + ";"
      Endif

      // ###################################
      // Elimina o último ponto e vírgula ##
      // ###################################
      cEmail := Substr(cEmail,01, (Len(Alltrim(cEmail)) - 1))

   Else
   
      // ########################################
      // Catura o e-mail do usuário para envio ##
      // ########################################
      cId := __cUserID

      PswOrder(1)

      If PswSeek(cId,.T.)

         aReturn := PswRet()

         aAdd( aUsuarios, { aReturn[1][1]  , ;                                              // 01 - Código do Usuário
                            aReturn[1][2]  , ;                                              // 02 - Login do Usuário
                            aReturn[1][4]  , ;                                              // 03 - Nome completo do usuário
                            IIF(len(aReturn[1][10]) <> 0, aReturn[1][10][1], "000000"),;    // 04 - Código do grupo
                            ''             , ;                                              // 05 - Descrição do grupo do usuário
                            aReturn[1][6]  , ;                                              // 06 - Data de validade da senha
                            aReturn[1][11] , ;                                              // 07 - Código do Supervisor
                            aReturn[1][12] , ;                                              // 08 - Departamento
                            aReturn[1][13] , ;                                              // 09 - Cargo
                            aReturn[1][14] , ;                                              // 10 - E-mail do usuário
                            aReturn[1][15] , ;                                              // 11 - Nº de acessos simultâneos
                            aReturn[1][17] })                                               // 12 - Usuário Bloqueado (.T./.F.)
      Endif

      If Len(aUsuarios) == 0
         cEmail := ""
      Endif
   
      If Empty(Alltrim(aUsuarios[01,10]))
         cEmail := ""
      Else
         cEmail := Alltrim(aUsuarios[01,10])
      Endif
      
      // ##############################################
      // Abre janela solicitando o e-mail para envio ##
      // ##############################################
      If Empty(Alltrim(cEmail))
         Return(.T.)
      Endif
      
   Endif

   // #################################
   // Elabora o e-mail a ser enviado ##
   // #################################
   If _TipoEmail == 1
      cTexto := ""
      cTexto := "Ao Departamento de Logística"
      cTexto += chr(13) + chr(10)
      cTexto += chr(13) + chr(10)
      cTexto += "Venho informar que realizei a inclusão de uma Solicitação de Transferência de Mercadorias."
      cTexto += chr(13) + chr(10)
      cTexto += "Aguardo a sua Aprovação conforme dados abaixo:"
      cTexto += chr(13) + chr(10)
      cTexto += chr(13) + chr(10)
      cTexto += "Nº da Solicitação: " + cCodigo
      cTexto += chr(13) + chr(10)
      cTexto += "Data Solicitação: "  + Dtoc(cEmissao)
      cTexto += chr(13) + chr(10)
      cTexto += "Solicitante: " + Alltrim(cSolicitante)
      cTexto += chr(13) + chr(10)
      cTexto += chr(13) + chr(10)

      If !Empty(Alltrim(cNota01))
         cTexto += "Observações"
         cTexto += chr(13) + chr(10)
         cTexto += Alltrim(cNota01)
         cTexto += chr(13) + chr(10)
         cTexto += chr(13) + chr(10)                                                                                      
      Endif
         
      cTexto += "Atenciosamente"
      cTexto += chr(13) + chr(10)                                                                                      
      cTexto += chr(13) + chr(10)                                                                                                  
      cTexto += Alltrim(cSolicitante)
      cTexto += chr(13) + chr(10)                                                                                                  
      cTexto += "Departamento de Projetos"
   Else
      cTexto := ""
      cTexto := "Prezado " + Alltrim(cSolicitante)
      cTexto += chr(13) + chr(10)
      cTexto += chr(13) + chr(10)

      // #######################
      // Solicitação Aprovada ##
      // #######################
      If _Status == "04"
         cTexto += "Informamos que sua Solicitação de Transferência de Mercadorias foi Aprovada."
         cTexto += chr(13) + chr(10)
         cTexto += "Solicitamos que você faça a retirada do equipamento em nosso departamento o mais breve possível."

         // ####################################################
         // Envia a observação caso esta tenha sido informada ##
         // ####################################################
         If !Empty(Alltrim(cNota02))
            cTexto += chr(13) + chr(10)
            cTexto += chr(13) + chr(10)
            cTexto += "Observações"
            cTexto += chr(13) + chr(10)
            cTexto += chr(13) + chr(10)
            cTexto += Alltrim(cNota02)
         Endif

      Endif
      
      // ########################
      // Solicitação Reprovada ##
      // ########################
      If _Status == "08"
         cTexto += "Informamos que sua Solicitação de Transferência de Mercadorias foi Reprovada pelo seguinte motivo:"
         cTexto += chr(13) + chr(10)         
         cTexto += chr(13) + chr(10)         
         cTexto += Alltrim(cNota02)
      Endif
      
      cTexto += chr(13) + chr(10)         
      cTexto += chr(13) + chr(10)         
      cTexto += "Atenciosamente"
      cTexto += chr(13) + chr(10)                                                                                      
      cTexto += chr(13) + chr(10)                                                                                                  
      cTexto += Alltrim(cSolicitante)
      cTexto += chr(13) + chr(10)                                                                                                  
      cTexto += "Departamento de Logítica"
   Endif
      
   // ############################
   // Envia e-mail ao Aprovador ##
   // ############################
   If _TipoEmail == 1
      U_AUTOMR20(cTexto, Alltrim(cEmail), "", "Aviso de Solicitação de Transferência de Mercadoria" )
   Else
      U_AUTOMR20(cTexto, Alltrim(cEmail), "", "Aviso de Aprovação/Reprovação de Solicitação de Transferência de Mercadoria")
   Endif
  
Return(.T.)

// ################################################################################## 
// Função que sinaliza a Devolução do Solicitante para o Departamento de Logística ##
// ##################################################################################
Static Function DevoSinal(_Status, _Codigo, _Filial)

   Local cSql         := ""
   Local cTexto       := ""
   Local cEmail       := ""
   Local xSolicitante := ""
   Local xEmissao     := ""

   If _Status <> "4"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Sinalização de devolução não permitida. Verifica Status.")
      Return(.T.)
   Endif
   
   // #####################################################
   // Atualiza o Status para Devolução Sinalizada (Rosa) ##
   // #####################################################
   If MsgYesNo("Confirma a sinalização de devolução para a solicitação selecionada?")

      aArea := GetArea()
      DbSelectArea("ZP2")
      DbSetOrder(1)

      If DbSeek(_Filial + _Codigo)

         RecLock("ZP2",.F.)
         ZP2_STAT := "3"

         // ########################################
         // Carrega os dados para envio do e-mail ##
         // ########################################
         xSolicitante := ZP2_SOLI
         xEmissao     := Dtoc(ZP2_EMIS)

         MsUnLock()

      Endif

      // #########################################################################################################
      // Envia e-mail avisando o Departamento de Logística que houve uma sinalização de devolução de mercadoria ##
      // #########################################################################################################
      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT A.ZZ4_ST01, "
      cSql += "       A.ZZ4_ST02, "
      cSql += "       A.ZZ4_ST03, "
      cSql += "       A.ZZ4_EM01, "
      cSql += "       A.ZZ4_EM02, "
      cSql += "       A.ZZ4_EM03  "
      cSql += "  FROM " + RetSqlName("ZZ4") + " A (NoLock) "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      cEmail := ""

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_EM01))
         cEmail := Alltrim(T_PARAMETROS->ZZ4_EM01) + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_EM02))
         cEmail := Alltrim(T_PARAMETROS->ZZ4_EM02) + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_EM03))
         cEmail := Alltrim(T_PARAMETROS->ZZ4_EM03) + ";"
      Endif
     
      // ###################################
      // Elimina o último ponto e vírgula ##
      // ###################################
      cEmail := Substr(cEmail,01, (Len(Alltrim(cEmail)) - 1))

      // #######################################################################     
      // Elabora o texto do e-mail a ser enviado ao Departamento de Logística ##
      // #######################################################################
      cTexto := ""
      cTexto := "Ao Departamento de Logística"
      cTexto += chr(13) + chr(10)
      cTexto += chr(13) + chr(10)
      cTexto += "Foi indicado uma Sinalização de Devolução de empréstimo de mercadoria conforme dados abaixo:"
      cTexto += chr(13) + chr(10)
      cTexto += chr(13) + chr(10)
      cTexto += "Nº da Solicitação: " + _Codigo
      cTexto += chr(13) + chr(10)
      cTexto += "Data Solicitação: "  + xEmissao
      cTexto += chr(13) + chr(10)
      cTexto += "Solicitante: " + Alltrim(xSolicitante)
      cTexto += chr(13) + chr(10)
      cTexto += chr(13) + chr(10)
      cTexto += "Atenciosamente"
      cTexto += chr(13) + chr(10)                                                                                      
      cTexto += chr(13) + chr(10)                                                                                                  
      cTexto += "Departamento de Projetos"

      U_AUTOMR20(cTexto, Alltrim(cEmail), "", "Aviso de Sinalização de Devolução de Mercadorias" )

      // ##################
      // Atualiza o grid ##
      // ##################
      CarregaGridSol(2)

   Endif

Return(.T.)

// #################################################################################
// Função que Confirma a Devolução da Solicitação de Transferência de Mervadorias ##
// #################################################################################
Static Function DevoConfirma(_Status, _Codigo, _Filial)

   Local xProduto
   Local xSerie         := Space(20)
   Local cProd          := Space(06)
   Local aAuto          := {}
   Local aItem          := {}
   Local _xDOCx         := ""
   Local cLote          := "   "
   Local dDataVl        := ""
   Local nQuant         := 1
   Local nOpcAuto       := 3 // Indica qual tipo de ação será tomada (Inclusão/Exclusão)
   Local cEmail         := ""
   Local cSql           := ""
   Local cTexto         := ""
   Local cId            := ""
   Local xSolicitante   := ""
   Local xIdSolicitante := ""
   Local aUsuarios      := {}

   PRIVATE lMsHelpAuto := .T.
   PRIVATE lMsErroAuto := .F.

   If _Status <> "3"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Operação inválida para este Status. Verifique os Status.")
      Return(.T.)
   Endif
   
   // #####################################################
   // Atualiza o Status para Devolução Sinalizada (Rosa) ##
   // #####################################################
   If MsgYesNo("Confirma a devolução sinalizada para a solicitação de transferência selecionada?")

      // ###########################################################################
      // Realiza a transferência de retorno do armazém 98 ou 99 para o armazém 01 ##
      // ###########################################################################

      // ##########################################################################################
      // Posiciona no registro de transferência para captuar código do produto a ser transferido ##
      // ##########################################################################################
      aArea := GetArea()
      DbSelectArea("ZP2")
      DbSetOrder(1)
      If DbSeek(_Filial + _Codigo)
         xProduto := ZP2_PROD
         xSerie   := ZP2_SERI
      Endif

      // ###########################
      // Captura dados do produto ##
      // ###########################
      DbSelectArea("SB1")
      DbSetOrder(1)

      If SB1->(MsSeek(xFilial("SB1")+Alltrim(xProduto) + Space(24)))
         cProd   := B1_COD
         cDescri := B1_DESC
         cUM     := B1_UM
         cLocal  := B1_LOCPAD
      Else
         MsgAlert("Dados do produto informado não localizado.")
         Return(.T.)
      EndIf

      _UnidadeMed := Posicione("SB1", 1, xFilial("SB1") + Alltrim(cProduto) + Space(24), "B1_UM")
      _xDOCx      := GetSxENum("SD3","D3_DOC",1)
      cLote       := "   "
      dDataVl     := CTOD("  /  /    ")
      nQuant      := 1
      nOpcAuto    := 3
            
      // ##############################################################
      // Verifica se existe local de origem para o produto de origem ##
      // ##############################################################
      DbSelectArea("SB2")
      DbSetOrder(1)
      IF !SB2->(DBSEEK(xFilial("SB2") + Alltrim(cProd) + Space(24) + "01" ))      
         CriaSB2( cProd, "01")
      ENDIF     

      // ###############################################################
      // Verifica se existe local de destino para o produto de origem ##
      // ###############################################################
      Do Case
         Case Substr(_Codigo,07,03) == "PRJ"
              IF !SB2->(DBSEEK(xFilial("SB2") + Alltrim(cProd) + Space(24) + "98" ))      
                 CriaSB2( cProd, "98")
              ENDIF     
         Case Substr(_Codigo,07,03) == "AST"
              IF !SB2->(DBSEEK(xFilial("SB2") + Alltrim(cProd) + Space(24) + "99" ))      
                 CriaSB2( cProd, "99")
              ENDIF     
      EndCase
      
      // ###############################################################################
      // Realiza a transferência do armazém 01 para o armazém 98 ou 99 conforme Setor ##
      // ###############################################################################
      Begin Transaction

         // ###################### 
         // Cabecalho a Incluir ##
         // ######################
         aAuto := {}
         aadd(aAuto,{_xDOCx,dDataBase}) //Cabecalho

         // ##################################
         // Dados do item a ser transferido ##
         // ##################################
         aadd(aItem,cProd)    // 01 - D3_COD  
         aadd(aItem,cDescri)  // 02 - D3_DESCRI
         aadd(aItem,cUM)      // 03 - D3_UM

         Do Case
            Case Substr(_Codigo,07,03) == "PRJ"
                 aadd(aItem,"98")     // 04 - D3_LOCAL
            Case Substr(_Codigo,07,03) == "AST"
                 aadd(aItem,"98")     // 04 - D3_LOCAL
         EndCase                 

         If Empty(Alltrim(xSerie))      
            aadd(aItem,"")         // 05 - D3_LOCALIZ
         Else
            Do Case
               Case Substr(_Codigo,07,03) == "PRJ"
                    aadd(aItem,"PROJETOS") // 05 - D3_LOCALIZ            
               Case Substr(_Codigo,07,03) == "AST"
                    aadd(aItem,"TECNICA") // 05 - D3_LOCALIZ            
            EndCase
         Endif

         aadd(aItem,cProd)         // 06 - D3_COD
         aadd(aItem,cDescri)       // 07 - D3_DESCRI
         aadd(aItem,cUM)           // 08 - D3_UM
         aadd(aItem,"01")          // 09 - D3_LOCAL

         If Empty(Alltrim(xSerie))
            aadd(aItem,"")         // 10 - D3_LOCALIZ
         Else
            aadd(aItem,"GENERICO") // 10 - D3_LOCALIZ
         Endif

         If Empty(Alltrim(xSerie))
            aadd(aItem,"")         // 11 - D3_NUMSERI
         Else   
            aadd(aItem,xSerie)     // 11 - D3_NUMSERI
         Endif

         aadd(aItem,cLote)         // 12 - D3_LOTECTL
         aadd(aItem,"")            // 13 - D3_NUMLOTE
         aadd(aItem,dDataVl)       // 14 - D3_DTVALID
         aadd(aItem,0)             // 15 - D3_POTENCI
         aadd(aItem,nQuant)        // 16 - D3_QUANT
         aadd(aItem,0)             // 17 - D3_QTSEGUM
         aadd(aItem,"")            // 18 - D3_ESTORNO
         aadd(aItem,"")            // 19 - D3_NUMSEQ
         aadd(aItem,cLote)         // 20 - D3_LOTECTL
         aadd(aItem,dDataVl)       // 21 - D3_DTVALID
         aadd(aItem,"")            // 22 - D3_ITEMGRD
         aadd(aAuto,aItem)
  
         MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

         If !lMsErroAuto
            MsgAlert("Encerramento e transferência entre o armazém 98 para o armazém 01 realizada com sucesso.")
         Else
            MostraErro()
            Return(.T.)
         EndIf

      End Transaction

      aArea := GetArea()
      DbSelectArea("ZP2")
      DbSetOrder(1)

      If DbSeek(_Filial + _Codigo)

         RecLock("ZP2",.F.)
         ZP2_STAT := "5"

         xSolicitante   := ZP2_SOLI
         xIdSolicitante := ZP2_IDSO

         MsUnLock()

      Endif

      // ########################################
      // Catura o e-mail do usuário para envio ##
      // ########################################
      cId := xIdSolicitante

      PswOrder(1)

      If PswSeek(cId,.T.)

         aReturn := PswRet()

         aAdd( aUsuarios, { aReturn[1][1]  , ;                                              // 01 - Código do Usuário
                            aReturn[1][2]  , ;                                              // 02 - Login do Usuário
                            aReturn[1][4]  , ;                                              // 03 - Nome completo do usuário
                            IIF(len(aReturn[1][10]) <> 0, aReturn[1][10][1], "000000"),;    // 04 - Código do grupo
                            ''             , ;                                              // 05 - Descrição do grupo do usuário
                            aReturn[1][6]  , ;                                              // 06 - Data de validade da senha
                            aReturn[1][11] , ;                                              // 07 - Código do Supervisor
                            aReturn[1][12] , ;                                              // 08 - Departamento
                            aReturn[1][13] , ;                                              // 09 - Cargo
                            aReturn[1][14] , ;                                              // 10 - E-mail do usuário
                            aReturn[1][15] , ;                                              // 11 - Nº de acessos simultâneos
                            aReturn[1][17] })                                               // 12 - Usuário Bloqueado (.T./.F.)
      Endif

      If Len(aUsuarios) == 0
         cEmail := ""
      Endif
   
      If Empty(Alltrim(aUsuarios[01,10]))
         cEmail := ""
      Else
         cEmail := Alltrim(aUsuarios[01,10])
      Endif
      
      // ###############################################################################
      // Se não existir e-mail para o usuário solicitante, despresa o envio do e-mail ##
      // ###############################################################################
      If !Empty(Alltrim(cEmail))

         // #################################################################
         // Elabora o texto do e-mail a ser enviado ao Usuário Solicitante ##
         // #################################################################
         cTexto := ""
         cTexto := "Prezado Usuário " + Alltrim(xSolicitante)
         cTexto += chr(13) + chr(10)
         cTexto += chr(13) + chr(10)
         cTexto += "Informamos que seu processo de empréstimo de mercadorias de nº " + Alltrim(_Codigo) + " foi finalizado com sucesso."
         cTexto += chr(13) + chr(10)
         cTexto += chr(13) + chr(10)
         cTexto += "Atenciosamente"
         cTexto += chr(13) + chr(10)                                                                                      
         cTexto += chr(13) + chr(10)                                                                                                  
         cTexto += "Departamento de Logística"

         U_AUTOMR20(cTexto, Alltrim(cEmail), "", "Aviso de Confirmação de Devolução de Empréstimo de Mercadorias" )

      Endif
      
      // ##################
      // Atualiza o grid ##
      // ##################
      CarregaGridSol(2)

   Endif

Return(.T.)

// ################################### 
// Função que troca o status da RMA ##
// ###################################
Static Function TrocaStatusRMA()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private xCodRMA	  := aBrowsek[oBrowsek:nAt,06]
   Private xSolici 	  := aBrowsek[oBrowsek:nAt,09]
   Private xProduto   := aBrowsek[oBrowsek:nAt,02]
   Private xNomePro   := aBrowsek[oBrowsek:nAt,03]
   Private xMotivo 	  := ""
   Private lAprova	  := .F.
   Private lSinaliza  := .F.
   Private oCheckBox1
   Private oCheckBox2
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oMemo2

   Private oDlgT

   If aBrowsek[oBrowsek:nAt,01] <> "5"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para este Status.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgT TITLE "Alteração de Status de RMA" FROM C(178),C(181) TO C(498),C(801) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlgT
   @ C(073),C(039) Jpeg FILE "br_azul"        Size C(009),C(009) PIXEL NOBORDER OF oDlgT
   @ C(073),C(123) Jpeg FILE "br_amarelo"     Size C(009),C(009) PIXEL NOBORDER OF oDlgT
   @ C(073),C(179) Jpeg FILE "br_rosa"        Size C(009),C(009) PIXEL NOBORDER OF oDlgT

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(301),C(001) PIXEL OF oDlgT

   @ C(042),C(005) Say "Nº RMA"                               Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(042),C(039) Say "Solicitante"                          Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(042),C(142) Say "Produto"                              Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(065),C(039) Say "Status Atual"                         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(065),C(123) Say "Alterar Status para"                  Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(074),C(052) Say "Devolução Confirmada"                 Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(087),C(005) Say "Motivo da alteração do status da RMA" Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

   @ C(052),C(005) MsGet    oGet1      Var xCodRMA   Size C(028),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(052),C(039) MsGet    oGet2      Var xSolici   Size C(097),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(052),C(142) MsGet    oGet3      Var xProduto  Size C(027),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(052),C(172) MsGet    oGet4      Var xNomePro  Size C(132),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(074),C(138) CheckBox oCheckBox1 Var lAprova   Prompt "Aprovada"             Size C(036),C(008) PIXEL OF oDlgT
   @ C(074),C(194) CheckBox oCheckBox2 Var lSinaliza Prompt "Devolução Sinalizada" Size C(063),C(008) PIXEL OF oDlgT
   @ C(096),C(005) GET      oMemo2     Var xMotivo   MEMO Size C(299),C(044) PIXEL OF oDlgT

   @ C(144),C(228) Button "Gravar"   Size C(037),C(012) PIXEL OF oDlgT ACTION( GravaTroca() )
   @ C(144),C(267) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// ############################################
// Função que grava a troca do status da RMA ##
// ############################################
Static Function GravaTroca()

   If lAprova == .F. .And. lSinaliza == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Novo status não indicado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif
      
   If lAprova == .T. .And. lSinaliza == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Somente é permitido indicar novo Status com APROVADO ou DEVOLUÇÃO SINALIZADA." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(xMotivo))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Necessário informar o motivo da troca de status da RMA.")
      Return(.T.)
   Endif

   DbSelectArea("ZP2")
   DbSetOrder(1)
   If DbSeek(cFilAnt + xCodRMA)
      RecLock("ZP2",.F.)
      If lAprova == .T.
         ZP2_STAT := "4"  
      Endif
      If lSinaliza == .T.
         ZP2_STAT := "3"  
      Endif
      ZP2_TROC := xMotivo
      MsUnLock()
   Endif

   oDlgT:End()

   CarregaGridSol(2)

Return(.T.)

// ##############################################################################################################
// Função que realiza o encerramento de solicitações (Somente para registros com status = Verde - Solicitação) ##
// ##############################################################################################################
Static Function EncerStatusRMA()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private xCodRMA	  := aBrowsek[oBrowsek:nAt,06]
   Private xSolici 	  := aBrowsek[oBrowsek:nAt,09]
   Private xProduto   := aBrowsek[oBrowsek:nAt,02]
   Private xNomePro   := aBrowsek[oBrowsek:nAt,03]
   Private xMotivo 	  := ""
   Private lAprova	  := .T.
   Private oCheckBox1
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oMemo2

   Private oDlgT

   If aBrowsek[oBrowsek:nAt,01] <> "2"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Procedimento somente permitido para Status 2 - Solicitação.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgT TITLE "Encerramento de Solicitação de RMA" FROM C(178),C(181) TO C(498),C(801) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlgT
   @ C(073),C(039) Jpeg FILE "br_verde"        Size C(009),C(009) PIXEL NOBORDER OF oDlgT
   @ C(073),C(123) Jpeg FILE "br_vermelho"     Size C(009),C(009) PIXEL NOBORDER OF oDlgT

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(301),C(001) PIXEL OF oDlgT

   @ C(042),C(005) Say "Nº RMA"                               Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(042),C(039) Say "Solicitante"                          Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(042),C(142) Say "Produto"                              Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(065),C(039) Say "Status Atual"                         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(065),C(123) Say "Alterar Status para"                  Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(074),C(052) Say "Solicitação"                          Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(087),C(005) Say "Motivo da alteração do status da RMA" Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

   @ C(052),C(005) MsGet    oGet1      Var xCodRMA   Size C(028),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(052),C(039) MsGet    oGet2      Var xSolici   Size C(097),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(052),C(142) MsGet    oGet3      Var xProduto  Size C(027),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(052),C(172) MsGet    oGet4      Var xNomePro  Size C(132),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgT When lChumba
   @ C(074),C(138) CheckBox oCheckBox1 Var lAprova   Prompt "Encerrada" Size C(036),C(008) PIXEL OF oDlgT When lChumba
   @ C(096),C(005) GET      oMemo2     Var xMotivo   MEMO               Size C(299),C(044) PIXEL OF oDlgT

   @ C(144),C(228) Button "Gravar"   Size C(037),C(012) PIXEL OF oDlgT ACTION( GravaEncerra() )
   @ C(144),C(267) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// ############################################
// Função que grava a troca do status da RMA ##
// ############################################
Static Function GravaEncerra()

   // ###################################################
   // Verifica se motivo do encerramento foi informado ##
   // ###################################################
   If Empty(Alltrim(xMotivo))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Necessário informar o motivo do encerramento da Solicitação da RMA.")
      Return(.T.)
   Endif

   DbSelectArea("ZP2")
   DbSetOrder(1)
   If DbSeek(cFilAnt + xCodRMA)
      RecLock("ZP2",.F.)
      ZP2_STAT := "8"  
      ZP2_TROC := xMotivo
      MsUnLock()
   Endif

   oDlgT:End()

   CarregaGridSol(2)

Return(.T.)