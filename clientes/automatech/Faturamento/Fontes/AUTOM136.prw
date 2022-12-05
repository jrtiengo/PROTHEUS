#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM136.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 17/10/2012                                                          ##
// Objetivo..: Programa que abre janela com grid de produtos em demonstração que   ##
//             estão com a data de retorno vencidos por vendedor logado.           ##
// Parâmetros: kEntrada. Se 0 é pelo login do Sistema                              ##
//                       Se 1 é pela chamada do Menu                               ## 
// ##################################################################################

User Function AUTOM136(kEntrada)

   Local lChumba     := ""
   Local cSql        := ""
   Local cDataHoje   := ""
   Local cAtraso     := ""
   Local nContar     := 0
   Local cMemo1      := ""
   Local oMemo1
   
   Private aBrowse   := {}
   Private cVendedor := ""
   Private lGeral    := .T.
   Private xEntrada  := kEntrada

   Private aVendedor := {}
   Private aStatus   := {}
   Private cComboBx1
   Private cComboBx2
  
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

   U_AUTOM628("AUTOM136")

   aAdd( aBrowse, { '1', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' } )
   
   // ################################
   // Carrega o combo de vendedores ##
   // ################################
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD   ,"
   cSql += "       A3_NOME  ,"
   cSql += "       A3_CODUSR "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE A3_CODUSR  <> ''"
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += " ORDER BY A3_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   T_VENDEDOR->( DbGoTop() )

   aAdd( aVendedor, "000000 - Todos os Vendedores" )
   
   WHILE !T_VENDEDOR->( EOF() )
      aAdd( aVendedor, T_VENDEDOR->A3_COD + " - " + T_VENDEDOR->A3_NOME )
      T_VENDEDOR->( DbSkip() )
   ENDDO

   // #######################################################################################################
   // Verifica se o vendedor logado é um dos vendedores. Se fo posiciona e chumba o comboBoc de vendedores ##
   // #######################################################################################################
   If Alltrim(__CUSERID) == "000000"
      lGeral  := .T.
      lChumba := .T.      
   Else
      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_COD   ,"
      cSql += "       A3_NOME  ,"
      cSql += "       A3_CODUSR "
      cSql += "  FROM " + RetSqlName("SA3")
      cSql += " WHERE A3_CODUSR  = '" + Alltrim(__CUSERID) + "'"
      cSql += "   AND D_E_L_E_T_ = ''        "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

      T_VENDEDOR->( DbGoTop() )

      If T_VENDEDOR->( EOF() )
         lChumba := .T. 
         lGeral  := .T.
      Else   

         For nContar = 1 to Len(aVendedor)
             If Alltrim(Substr(aVendedor[nContar],01,06)) == Alltrim(T_VENDEDOR->A3_COD)
               cComboBx1 := T_VENDEDOR->A3_COD + " - " + Alltrim(T_VENDEDOR->A3_NOME)
                lChumba   := .F.
                lGeral    := .F.
                Exit
             Endif
         Next nContar
      
      Endif

   Endif

   // ##########################
   // Carrega o array aStatus ##
   // ##########################
   aAdd( aStatus, "1 - Em demonstração de 0  até 20 dias (A Devolver)"  )
   aAdd( aStatus, "2 - Em demonstração de 21 até 25 dias (A Devolver)"  )
   aAdd( aStatus, "3 - Em demonstração de 26 até 30 dias (A Devolver)"  )
   aAdd( aStatus, "4 - Em demonstração de 0  até 20 dias (Devolvidos)"  )
   aAdd( aStatus, "5 - Em demonstração de 21 até 25 dias (Devolvidos)"  )
   aAdd( aStatus, "6 - Em demonstração de 26 até 30 dias (Devolvidos)"  )
   aAdd( aStatus, "7 - Devolvidos no prazo"                             )
   aAdd( aStatus, "8 - Devolvidos fora do prazo"                        )
   aAdd( aStatus, "9 - A Devolver (Todos)"                              )   
   aAdd( aStatus, "0 - Devolvidos (Todos)"                              )   
   aAdd( aStatus, "X - Todos os Status"                                 )

   cComboBx2 := "9 - A Devolver (Todos)"

   // ########################################################################
   // Na entrada do Sistema se for pesquisa geral, retorna sem mostrar nada ##
   // ########################################################################
   If lGeral == .T.
      If xEntrada == 0
         If _Rodar <> nil
            _Rodar := .T.
            Return(.T.)
         Endif   
      Endif   
   Else
      PsqDemoVend(0)
   Endif

   If xEntrada == 0
      If Len(aBrowse) == 0
         Return(.T.)
      Else
         If Empty(Alltrim(aBrowse[01,02]))
            If _Rodar <> nil
               _Rodar := .T.
            Endif   
            Return(.T.)
         Endif   
      Endif
   Endif

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Produtos em Demonstração" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO  Size C(495),C(001) PIXEL OF oDlg

   @ C(211),C(005) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(085) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(167) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(251) Jpeg FILE "br_preto.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(326) Jpeg FILE "br_azul.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(036),C(005) Say "Vendedor"                  Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(115) Say "Status"                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(018) Say "Em Demo de 0 até 20 dias"  Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(098) Say "Em Demo de 21 até 25 dias" Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(182) Say "Em Demo de 26 até 30 dias" Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(264) Say "Devolvidos fora do prazo"  Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(339) Say "Devolvidos no prazo"       Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) ComboBox cComboBx1 Items aVendedor Size C(105),C(010) PIXEL OF oDlg When lChumba
   @ C(045),C(115) ComboBox cComboBx2 Items aStatus   Size C(150),C(010) PIXEL OF oDlg

   @ C(042),C(270) Button "Pesquisar"      Size C(037),C(012) PIXEL OF oDlg ACTION( PsqDemoVend(1) )
// @ C(210),C(422) Button "Alterar Prazo"  Size C(037),C(012) PIXEL OF oDlg ACTION( AlteraData() )

   If xEntrada == 0
   Else
      @ C(210),C(422) Button "Exportar Excel" Size C(037),C(012) PIXEL OF oDlg ACTION( kkGeraRESCSV() ) When !Empty(aBrowse[oBrowse:nAt,02])
   Endif
      
   @ C(210),C(461) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { '1', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' } )

   oBrowse := TCBrowse():New( 075 , 005, 630, 185,,{'LG'                    ,; // 01
                                                    'FL'                    ,; // 02
                                                    'Vendedor'              ,; // 03
                                                    'Cliente'               ,; // 04
                                                    'Loja'                  ,; // 05
                                                    'Descrição dos Clientes',; // 06
                                                    'Nº PV'                 ,; // 07
                                                    'Item PV'               ,; // 08
                                                    'Produto'               ,; // 09
                                                    'Descrição dos Produtos',; // 10
                                                    'NF Remessa'            ,; // 11
                                                    'Série'                 ,; // 12
                                                    'Data Emissão'          ,; // 13
                                                    'Nf Retorno'            ,; // 14
                                                    'Série'                 ,; // 15
                                                    'Data Emissão'          ,; // 16
                                                    'Dias Atraso'           },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // 17 
   
   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
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
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;
                         aBrowse[oBrowse:nAt,14],;
                         aBrowse[oBrowse:nAt,15],;
                         aBrowse[oBrowse:nAt,16],;
                         aBrowse[oBrowse:nAt,17]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a janela de alteração da data prevista de retorno
Static Function AlteraData()

   Local lChumba     := .F.

   Private cCliente  := aBrowse[oBrowse:nAt,01]
   Private cLoja 	 := aBrowse[oBrowse:nAt,02]
   Private cNcliente := aBrowse[oBrowse:nAt,03]
   Private cPedido 	 := aBrowse[oBrowse:nAt,04]
   Private cNota	 := aBrowse[oBrowse:nAt,09]
   Private cSerie 	 := aBrowse[oBrowse:nAt,10]
   Private cProduto	 := aBrowse[oBrowse:nAt,05]
   Private cNproduto := aBrowse[oBrowse:nAt,06]
   Private cItem     := aBrowse[oBrowse:nAt,11]
   Private cPrevista := Ctod(aBrowse[oBrowse:nAt,07])
   Private cMotivo 	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet11
   Private oMemo1

   Private oDlgA

   DEFINE MSDIALOG oDlgA TITLE "Alteração Data de Retorno NF Demonstração" FROM C(178),C(181) TO C(508),C(591) PIXEL

   @ C(006),C(005) Say "Cliente"                                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(028),C(005) Say "Nº P.Venda"                                      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(028),C(048) Say "Nota Fiscal"                                     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(028),C(090) Say "Série"                                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(049),C(005) Say "Produto"                                         Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(049),C(183) Say "Item"                                            Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(071),C(005) Say "Data Prevista de Retorno"                        Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(092),C(005) Say "Motivo da alteração da data prevista de retorno" Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(015),C(005) MsGet oGet1  Var cCliente       Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(015),C(029) MsGet oGet2  Var cLoja          Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(015),C(048) MsGet oGet3  Var cNcliente      Size C(151),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(036),C(005) MsGet oGet4  Var cPedido        Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(036),C(048) MsGet oGet5  Var cNota          Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(036),C(090) MsGet oGet6  Var cSerie         Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(058),C(005) MsGet oGet7  Var cProduto       Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(058),C(048) MsGet oGet8  Var cNproduto      Size C(132),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(058),C(183) MsGet oGet11 Var cItem          Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba 
   @ C(079),C(005) MsGet oGet9  Var cPrevista      Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(101),C(005) GET   oMemo1 Var cMotivo   MEMO Size C(194),C(044) PIXEL OF oDlgA

   @ C(148),C(123) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgA ACTION( SalvaMoti() )
   @ C(148),C(162) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgA ACTION( oDlgA:End() )

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Função que salva a alteração da data prevista de retorno de produtos em demonstração
Static Function SalvaMoti()

   Local cSql     := ""
   Local _Proximo := ""
   
   If cPrevista == Ctod("  /  /    ")
      MsgAlert("Data prevsita de retorno não informada.")
      Return .T.
   Endif
      
   If cPrevista < Date()
      MsgAlert("Data prevsita de retorno não pode ser menor que a data atual.")
      Return .T.
   Endif

   If Empty(Alltrim(cMotivo))
      MsgAlert("Necessário informar o motivo da alteração da data prevista de retorno deste produto.")
      Return .T.
   Endif
             
   // Pesquisa o próximo código para inclusão da alteração da data prevista de devolução
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ3_CONT "
   cSql += "  FROM " + RetSqlName("ZZ3")
   cSql += " ORDER BY ZZ3_CONT DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )
   
   If T_PROXIMO->( EOF() )
      _Proximo := "000001"
   Else
      _Proximo := Strzero((INT(VAL(T_PROXIMO->ZZ3_CONT)) + 1),6)
   Endif   
  
   // Insere os dados na Tabela ZZ3
   dbSelectArea("ZZ3")
   RecLock("ZZ3",.T.)
   ZZ3_FILIAL = aBrowse[oBrowse:nAt,12]
   ZZ3_CONT   = _Proximo
   ZZ3_CLIE   = aBrowse[oBrowse:nAt,01]
   ZZ3_LOJA   = aBrowse[oBrowse:nAt,02]
   ZZ3_PEDI   = aBrowse[oBrowse:nAt,04]
   ZZ3_NOTA   = aBrowse[oBrowse:nAt,09]
   ZZ3_SERI   = aBrowse[oBrowse:nAt,10]
   ZZ3_PROD   = aBrowse[oBrowse:nAt,05]
   ZZ3_DATA   = cPrevista
   ZZ3_MOTI   = cMotivo
   ZZ3_VEND   = cVendedor
   MsUnLock()

   // Altera a data no registro da Tabela SC6 - Produtos do Pedido de Venda
   DbSelectArea("SC6")
   DbSetOrder(1)
   If DbSeek(aBrowse[oBrowse:nAt,12] + aBrowse[oBrowse:nAt,04] + aBrowse[oBrowse:nAt,11] + aBrowse[oBrowse:nAt,05] )
      RecLock("SC6",.F.)
      C6_DTADEV := cPrevista
      MsUnLock()              
   Endif

   oDlgA:End() 

Return .T.   

// ###############################################################
// Função que realiza a pesquisa conforme parâmetros informados ##
// ###############################################################
Static Function PsqDemoVend(kTipo)

   MsgRun("Aguarde! Selecionando registros ...", "Seleção de Registros", {|| xPsqDemoVend(kTipo) })

Return(.T.)

// ###############################################################
// Função que realiza a pesquisa conforme parâmetros informados ##
// ###############################################################
Static Function xPsqDemoVend(kTipo)

   Local cVendedor := ""
   Local cDataHoje := Date()                        

   cVendedor := Substr(cComboBx1,01,06)

   cDataHoje := Date()

   aBrowse   := {}
      
   // ###########################################
   // Pesquisa registros para popular o browse ##
   // ###########################################
   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT A.C6_FILIAL ," + chr(13)
   cSql += "       A.C6_NUM    ," + chr(13)
   cSql += "       A.C6_CLI    ," + chr(13)
   cSql += "       A.C6_LOJA   ," + chr(13)
   cSql += "       D.A1_NOME   ," + chr(13)
   cSql += "       A.C6_ITEM   ," + chr(13)
   cSql += "       A.C6_PRODUTO," + chr(13)
   cSql += "       A.C6_DESCRI ," + chr(13)
   cSql += "       A.C6_DTADEV ," + chr(13)
   cSql += "       A.C6_NOTA   ," + chr(13)
   cSql += "       A.C6_SERIE  ," + chr(13)
   cSql += "       A.C6_DATFAT ," + chr(13)
   cSql += "       B.C5_VEND1  ," + chr(13)
   cSql += "       E.A3_NOME   ," + chr(13)
   cSql += "       C.D1_DOC    ," + chr(13)
   cSql += "       C.D1_SERIE  ," + chr(13)
   cSql += "       C.D1_EMISSAO," + chr(13)
   cSql += "       C.D1_NFORI  ," + chr(13)
   cSql += "       C.D1_SERIORI " + chr(13)
   cSql += "  FROM " + RetSqlName("SC6") + " A "                                         + chr(13)
   cSql += "           LEFT OUTER JOIN SD1010 C ON C.D1_NFORI   = A.C6_NOTA    "         + chr(13)
   cSql += "                                   AND C.D1_SERIORI = A.C6_SERIE   "         + chr(13)
   cSql += "                                   AND C.D1_FILIAL  = A.C6_FILIAL  "         + chr(13)
   cSql += " 								   AND C.D1_FORNECE = A.C6_CLI     "         + chr(13)
   cSql += "								   AND C.D1_LOJA    = A.C6_LOJA    "         + Chr(13)
   cSql += "                                   AND C.D1_COD     = A.C6_PRODUTO,"         + Chr(13)
   cSql += "       " + RetSqlName("SC5") + " B, "                                        + chr(13)
   cSql += "       " + RetSqlName("SA1") + " D, "                                        + chr(13)
   cSql += "       " + RetSqlName("SA3") + " E  "                                        + chr(13) 
   cSql += " WHERE A.C6_TES IN ('523', '542', '732', '720', '721', '731', '732', '778')" + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"                                                    + chr(13)
   cSql += "   AND A.C6_NOTA   <> ''"                                                    + chr(13)
   cSql += "   AND A.C6_NUM     = B.C5_NUM   "                                           + chr(13)
   cSql += "   AND A.C6_FILIAL  = B.C5_FILIAL"                                           + chr(13)

   If Substr(cComboBx1,01,06) == "000000"
   Else
      cSql += "   AND B.C5_VEND1   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"         + chr(13)
   Endif   

   cSql += "   AND B.D_E_L_E_T_ = '' "                                                   + chr(13)
   cSql += "   AND A.C6_CLI     = D.A1_COD "                                             + chr(13)
   cSql += "   AND A.C6_LOJA    = D.A1_LOJA"                                             + chr(13)
   cSql += "   AND E.A3_COD     = B.C5_VEND1"                                            + chr(13)
   cSql += "   AND E.D_E_L_E_T_ = '' "                                                   + chr(13)
   cSql += " ORDER BY E.A3_NOME, A.C6_DATFAT, A.C6_NOTA, A.C6_SERIE"                     + Chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   If lGeral
   Else
      If T_NOTA->( EOF() )
         Return .T.
      Endif
   Endif   
   
   WHILE !T_NOTA->( EOF() )
       
      dEmisRem := Substr(T_NOTA->C6_DATFAT ,07,02) + "/" + Substr(T_NOTA->C6_DATFAT ,05,02) + "/" + Substr(T_NOTA->C6_DATFAT ,01,04)
      dEmisRet := Substr(T_NOTA->D1_EMISSAO,07,02) + "/" + Substr(T_NOTA->D1_EMISSAO,05,02) + "/" + Substr(T_NOTA->D1_EMISSAO,01,04)

      If Empty(Ctod(dEmisRet))
         Atraso := Date() - Ctod(dEmisRem)
      Else
         Atraso := Ctod(dEmisRet) - Ctod(dEmisRem)
      Endif

      // ###############################
      // Trata a Legenda os registros ##
      // ###############################
      
      If Empty(Ctod(dEmisRet))

         Do Case
         
            Case Atraso <= 20
                 xLegenda := "2"

            Case Atraso >= 21 .And. Atraso <= 25
                 xLegenda := "4"

            Case Atraso >= 26
                 xLegenda := "8"
                 
         EndCase
         
      Else
                 
         Do Case
         
            Case Atraso <= 30
                 xLegenda := "5"

            Case Atraso >  30
                 xLegenda := "7"

         EndCase

      Endif

      Do Case
         Case Substr(cComboBx2,01,01) == "1"
         
              If !Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
              
                 If Atraso < 20
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              
              Endif
              
         Case Substr(cComboBx2,01,01) == "2"
         
              If !Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
              
                 If Atraso >= 21 .And. Atraso <= 25
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              
              Endif

         Case Substr(cComboBx2,01,01) == "3"
         
              If !Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
              
                 If Atraso >= 26 .And. Atraso <= 30
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              
              Endif

         Case Substr(cComboBx2,01,01) == "4"
         
             If Empty(Ctod(dEmisRet))
                T_NOTA->( DbSkip() )
                Loop
             Else
                 If Atraso < 20
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              Endif
              
         Case Substr(cComboBx2,01,01) == "5"
         
              If Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
                 If Atraso >= 21 .And. Atraso <= 25
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              Endif

         Case Substr(cComboBx2,01,01) == "6"
         
              If !Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
                 If Atraso >= 26 .And. Atraso <= 30
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              Endif

         // ######################
         // Devolvidos no prazo ##
         // ######################
         Case Substr(cComboBx2,01,01) == "7"
         
              If Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
                 If Atraso <= 30
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              Endif

         // ###########################
         // Devolvidos dora do prazo ##
         // ###########################
         Case Substr(cComboBx2,01,01) == "8"
         
              If Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
                 If Atraso > 30
                 Else
                    T_NOTA->( DbSkip() )
                    Loop
                 Endif   
              Endif

         // #######################################
         // Todos os Status 1, 2, 3 (A Devolver) ##
         // #######################################
         Case Substr(cComboBx2,01,01) == "9"
         
              If !Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
//                 If Atraso <= 30
//                 Else
//                    T_NOTA->( DbSkip() )
//                    Loop
//                 Endif   
              Endif

         // #######################################
         // Todos os Status 1, 2, 3 (Devolvidos) ##
         // #######################################
         Case Substr(cComboBx2,01,01) == "0"
         
              If Empty(Ctod(dEmisRet))
                 T_NOTA->( DbSkip() )
                 Loop
              Else
//                 If Atraso <= 30
//                 Else
//                    T_NOTA->( DbSkip() )
//                    Loop
//                 Endif   
              Endif

      EndCase           

      // #######################################################
      // Alimenta o array aBrowse para popular o grid da tela ##
      // #######################################################
      aAdd( aBrowse, { xLegenda          ,;
                       T_NOTA->C6_FILIAL ,;
                       T_NOTA->A3_NOME   ,;
                       T_NOTA->C6_CLI    ,;
                       T_NOTA->C6_LOJA   ,;
                       T_NOTA->A1_NOME   ,;
                       T_NOTA->C6_NUM    ,;                                               
                       T_NOTA->C6_ITEM   ,;
                       T_NOTA->C6_PRODUTO,;
                       T_NOTA->C6_DESCRI ,;
                       T_NOTA->C6_NOTA   ,;
                       T_NOTA->C6_SERIE  ,;
                       dEmisRem          ,;
                       T_NOTA->D1_DOC    ,;
                       T_NOTA->D1_SERIE  ,;
                       dEmisRet          ,;
                       ATRASO            }) 

      T_NOTA->( DbSkip() )                        
       
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { '1', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' } )
   Endif   

   If kTipo == 0
   Else
   
      // ###########################
      // Seta vetor para a browse ##
      // ###########################                           
      oBrowse:SetArray(aBrowse) 
    
      // ########################################
      // Monta a linha a ser exibida no Browse ##
      // ########################################
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
                            aBrowse[oBrowse:nAt,02],;
                            aBrowse[oBrowse:nAt,03],;
                            aBrowse[oBrowse:nAt,04],;
                            aBrowse[oBrowse:nAt,05],;
                            aBrowse[oBrowse:nAt,06],;
                            aBrowse[oBrowse:nAt,07],;
                            aBrowse[oBrowse:nAt,08],;
                            aBrowse[oBrowse:nAt,09],;
                            aBrowse[oBrowse:nAt,10],;
                            aBrowse[oBrowse:nAt,11],;
                            aBrowse[oBrowse:nAt,12],;
                            aBrowse[oBrowse:nAt,13],;
                            aBrowse[oBrowse:nAt,14],;
                            aBrowse[oBrowse:nAt,15],;
                            aBrowse[oBrowse:nAt,16],;
                            aBrowse[oBrowse:nAt,17]}}

   Endif

   If lGeral == .T.
   Else
      If xEntrada == 0
         If _Rodar <> nil
            _Rodar := .T.
         Endif   
      Endif   
   Endif   

Return(.T.)

// #######################################
// Função que gera o resultado em Excel ##
// #######################################
Static Function kkGeraRESCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}
   
   // AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
   AADD(aCabExcel, {"FILIAL"    , "C", 02, 00 })
   AADD(aCabExcel, {"VENDEDOR"  , "C", 40, 00 })
   AADD(aCabExcel, {"CLIENTE"   , "C", 06, 00 })
   AADD(aCabExcel, {"LOJA"      , "C", 03, 00 })
   AADD(aCabExcel, {"DESCRIÇÃO" , "C", 60, 00 })
   AADD(aCabExcel, {"PEDIDO"    , "C", 06, 00 })
   AADD(aCabExcel, {"ITEMPV"    , "C", 03, 00 })
   AADD(aCabExcel, {"PRODUTO"   , "C", 30, 00 })
   AADD(aCabExcel, {"DESCRIÇÃO" , "C", 60, 00 })
   AADD(aCabExcel, {"NF_REMESSA", "C", 10, 00 })
   AADD(aCabExcel, {"SÉRIE"     , "C", 03, 00 })
   AADD(aCabExcel, {"EMISSÃO"   , "C", 10, 00 })
   AADD(aCabExcel, {"NF_RETORNO", "C", 10, 00 })
   AADD(aCabExcel, {"SÉRIE"     , "C", 03, 00 })
   AADD(aCabExcel, {"EMISSÃO"   , "C", 10, 00 })
   AADD(aCabExcel, {"ATRASO"    , "N", 05, 00 })
   AADD(aCabExcel, {""          , "C", 01, 00 })
   
   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| kProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","RELAÇÃO DE PRODUTOS EM DEMONSTRAÇÃO", aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aBrowse)

       aAdd( aCols, { aBrowse[nContar,02] ,;
                      aBrowse[nContar,03] ,;
                      aBrowse[nContar,04] ,;
                      aBrowse[nContar,05] ,;
                      aBrowse[nContar,06] ,;
                      aBrowse[nContar,07] ,;
                      aBrowse[nContar,08] ,;
                      aBrowse[nContar,09] ,;
                      aBrowse[nContar,10] ,;
                      aBrowse[nContar,11] ,;
                      aBrowse[nContar,12] ,;
                      aBrowse[nContar,13] ,;
                      aBrowse[nContar,14] ,;
                      aBrowse[nContar,15] ,;
                      aBrowse[nContar,16] ,;
                      aBrowse[nContar,17] ,;
                      ""                 })
   Next nContar

Return(.T.)