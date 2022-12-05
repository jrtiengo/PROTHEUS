#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM250.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/09/2014                                                          *
// Objetivo..: Programa do Cadastro de Filtros de Pesquisa Nova Proposta Comercial *
//**********************************************************************************

User Function AUTOM250()

   Private aLogado  := {}
   Private cMemo1   := ""

   Private oGet1
   Private oMemo1
   Private cComboBxA

   Private aFiltros := {}

   Private oDlg

   U_AUTOM628("AUTOM250")

   // Verifica o tipo de usuário.
   If Select("T_TIPOVENDE") > 0
      T_TIPOVENDE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A3_COD   ,"
   cSql += "       A3_NOME  ,"
   cSql += "       A3_CODUSR,"
   cSql += "       A3_TSTAT ,"
   cSql += "       A3_OUTR   "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A3_CODUSR  = '" + Alltrim(__cUserID) + "'"
   cSql += " ORDER BY A3_NOME     "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPOVENDE", .T., .T. )

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

   If __CuserID <> "000000"
      If T_TIPOVENDE->A3_TSTAT = '1'
         cSql += " AND A.A3_CODUSR = '" + Alltrim(__CuserID) + "'"
      Endif
   Endif
   
   cSql += " ORDER BY A.A3_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDORES", .T., .T. )

   aLogado := {}

   T_VENDEDORES->( DbGoTop() )
   WHILE !T_VENDEDORES->( EOF() )
      If Empty(Alltrim(T_VENDEDORES->A3_NOME))
         T_VENDEDORES->( DbSkip() )         
         Loop
      Endif   

      If T_TIPOVENDE->A3_TSTAT = '1'
         If Alltrim(T_VENDEDORES->A3_CODUSR) == Alltrim(__CuserID)
            aAdd( aLogado, T_VENDEDORES->A3_COD + " - " + Alltrim(UPPER(T_VENDEDORES->A3_NOME)) )
            Exit
         endif
      Else
         aAdd( aLogado, T_VENDEDORES->A3_COD + " - " + Alltrim(UPPER(T_VENDEDORES->A3_NOME)) )            
      Endif
      T_VENDEDORES->( DbSkip() )
   ENDDO

   // Carrega o array aFiltros
   cargafiltros(1, Substr(aLogado[1],01,06))

   // Desenha a tela
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Filtros de Pesquisa - Proposta Comercial" FROM C(178),C(181) TO C(446),C(617) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlg

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(209),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Vendedor" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(043),C(005) ComboBox cComboBxA Items aLogado Size C(207),C(010) PIXEL OF oDlg ON CHANGE carregafiltros(cCombobxA)

   @ C(118),C(060) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManFiltros("I", ccomboBxA, "") )
   @ C(118),C(098) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( ManFiltros("A", ccomboBxA, aFiltros[oFiltros:nAt,01] ) )
   @ C(118),C(136) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManFiltros("E", ccomboBxA, aFiltros[oFiltros:nAt,01] ) )
   @ C(118),C(175) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   If Len(aFiltros) == 0
      aAdd(aFiltros, { "", "" } )
   Endif

   oFiltros := TCBrowse():New( 073 , 005, 265, 070,,{'Codigo', 'Descrição dos Filtros',},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oFiltros:SetArray(aFiltros) 
    
   // Monta a linha a ser exibina no Browse
// oFiltros:bLine := {||{aFiltros[oFiltros:nAt,01], aFiltros[oFiltros:nAt,02]}}
   oFiltros:bLine := {||{aFiltros[oFiltros:nAt,01]}}
   oFiltros:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o lembrete pra o vendedor selecionado
Static Function CarregaFiltros(xxxVendedor)

   Local cSql := ""

   aFiltros := {}
   oFiltros:SetArray(aFiltros) 
   oFiltros:bLine := {||{aFiltros[oFiltros:nAt,01], aFiltros[oFiltros:nAt,02]}}
   oFiltros:Refresh()

   // Carrega o array aLista com, os filtros do vendedor selecionado
   If Select("T_FILTROS") > 0
      T_FILTROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT2_CODI,"
   cSql += "       ZT2_NOME "
   cSql += "  FROM " + RetSqlName("ZT2")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZT2_VEND   = '" + Alltrim(Substr(xxxVendedor,01,06)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FILTROS", .T., .T. )

   aFiltros := {}

   T_FILTROS->( DbGoTop() )
   
   WHILE !T_FILTROS->( EOF() )
      aAdd( aFiltros, { T_FILTROS->ZT2_CODI + " - " + T_FILTROS->ZT2_NOME } )
      T_FILTROS->( DbSkip() )
   ENDDO

   If Len(aFiltros) == 0
      aAdd( aFiltros, { "             " } )
   Endif

   oFiltros:SetArray(aFiltros) 
   oFiltros:bLine := {||{aFiltros[oFiltros:nAt,01]}}
   oFiltros:Refresh()
      
Return(.T.)

// Função de carrega o array aFiltros
Static Function CargaFiltros(_Tipo, xxxVendedor)

   Local cSql := ""

   aFiltros := {}

   // Pesquisa filtros do vendedor
   If Select("T_FILTROS") > 0
      T_FILTROS->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZT2_FILIAL,"
   cSql += "       ZT2_VEND  ,"
   cSql += "       ZT2_CODI  ,"
   cSql += "       ZT2_NOME  ,"
   cSql += "       ZT2_COMA  ,"
   cSql += "       ZT2_DELE   "
   cSql += "  FROM " + RetSqlName("ZT2")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZT2_VEND   = '" + Substr(xxxVendedor,01,06) + "'"
   cSql += " ORDER BY ZT2_CODI  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FILTROS", .T., .T. )

   T_FILTROS->( DbGoTop() )
   
   WHILE !T_FILTROS->( EOF() )
      aAdd( aFiltros, { T_FILTROS->ZT2_CODI + " - " + Alltrim(T_FILTROS->ZT2_NOME) } )
      T_FILTROS->( DbSkip() )
   ENDDO

   If _Tipo == 1
      Return(.T.)
   Endif

   If Len(aFiltros) == 0
      aAdd(aFiltros, { "                " } )
   Endif

   oFiltros:SetArray(aFiltros) 
   oFiltros:bLine := {||{aFiltros[oFiltros:nAt,01]}}
   oFiltros:Refresh()

Return(.T.)

// Função de manutenção do cadastro de filtros para o vendedor selecionado
Static Function ManFiltros(_Operacao, _Vendedor, _xFiltro)

   Local lChumba      := .F.
   Local lVoltar      := .F.
   Local nContar      := 0
   Local nAnoIni      := 0

   Private aCampos    := {}
   Private aEstrutura := {}

   Private aOperador  := {"01 - Igual a"           ,; 
                          "02 - Diferente de"      ,; 
                          "03 - Menor que"         ,; 
                          "04 - Menor ou Igual a"  ,; 
                          "05 - Maior que"         ,;
                          "06 - Maior ou Igual a"  ,;
                          "07 - Contém a Expressão",;
                          "08 - Não Contém"        ,;
                          "09 - Está Contido em"   ,;
                          "10 - Não está Contido em"}

   Private cComboBx1
   Private cComboBx2

   Private ckVendedor   := _Vendedor
   Private ckCodigo	    := Space(06)
   Private ckNome	    := Space(60)
   Private ckComando	:= Space(250)
   Private cDataDe      := Ctod("  /  /    ")
   Private cDataAte     := Ctod("  /  /    ")

   Private cMemo1	  := ""
   Private cExpressao := ""
   Private cStringD   := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6   

   Private oMemo1
   Private oMemo2
   Private oMemo3
   
   Private aOnde	 := {"01 - Oportunidades de Venda", "02 - Cabeçalho Proposta Comercial", "03 - Produtos Proposta Comercial"}
   Private cOnde
   Private cMemo100	 := ""
   Private oMemo100

   Private oDlgM
   Private oDlgOnde

   // Em caso de inclusão0, solicita em que tabela´será elaborado o filtro de pesquisa
   If _Operacao == "I"

      DEFINE MSDIALOG oDlgOnde TITLE "Elaboração de Filtro de Pesquisa" FROM C(178),C(181) TO C(341),C(498) PIXEL

      @ C(002),C(002) Jpeg FILE "logoautoma.bmp"     Size C(130),C(026) PIXEL NOBORDER OF oDlgOnde
      @ C(031),C(005) GET oMemo100 Var cMemo100 MEMO Size C(148),C(001) PIXEL OF oDlgOnde
      @ C(036),C(005) Say "Indique em qual tabela o filtro será elaborado" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgOnde
      @ C(046),C(005) ComboBox cOnde Items aOnde     Size C(148),C(010) PIXEL OF oDlgOnde
      @ C(062),C(075) Button "Confirmar"             Size C(037),C(012) PIXEL OF oDlgOnde ACTION(lVoltar := .F., oDlgOnde:End() )
      @ C(062),C(114) Button "Voltar"                Size C(037),C(012) PIXEL OF oDlgOnde ACTION(lVoltar := .T., oDlgOnde:End() )

      ACTIVATE MSDIALOG oDlgOnde CENTERED 
      
      If lVoltar 
         Return(.T.)
      Endif

      // Carrega o array aLista com as informações dos campos da tabela AD1
      Do Case
         Case Substr(cOnde,01,02) == "01"
              aCampos := { "Filial"     , "Oportunidade" , "Revisão" , "Descrição"   , "Dt.Abertura"  ,;   
                           "Dt.Iniício" , "Dt.Término"   , "Vendedor", "Prospect"    , "Loja Prosp."  ,;
                           "Hora"       , "Cliente"      , "Loja"    , "Moeda"       , "Processo"     ,;
                           "Estágio"    , "Prioridade"   , "Status"  , "Usuário"     , "Verba"        ,;
                           "Produto"    , "F.C.S."       , "F.C.I."  , "Orçamento"   , "Modo"         ,; 
                           "Comunicação", "Cod.Atend."   , "Canal"   , "Encerramento", "Tabela Preço" ,;
                           "Dt.Prev.Fim", "Registro SLA" , "Proposta", "Feeling"     , "Comis.Vend. 1",;
                           "Vendedor 2" , "Comis.Vend. 2", "Frete" }
                           
         Case Substr(cOnde,01,02) == "02"
              aCampos := { "Filial", "Proposta", "Oportunidade", "Cliente", "Loja", "Transportadora" }
                           
         Case Substr(cOnde,01,02) == "03"
              aCampos := { "Filial"    , "Proposta"  , "Produto"   , "Descrição"   ,;
                           "Moeda"     , "Cond.Pagtº", "Quantidade", "Prc Unitário",;
                           "Vlr Total" }
      EndCase

      // Carrega o array aLista com as informações dos campos da tabela AD1
      Do Case
         Case Substr(cOnde,01,02) == "01"
              aAdd( aEstrutura, { "Filial"       , "AD1_FILIAL", "C", "2"  , "0" } )
              aAdd( aEstrutura, { "Oportunidade" , "AD1_NROPOR", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Revisão"      , "AD1_REVISA", "C", "2"  , "0" } )   
              aAdd( aEstrutura, { "Descrição"    , "AD1_DESCRI", "C", "30" , "0" } )
              aAdd( aEstrutura, { "Dt.Abertura"  , "AD1_DATA"  , "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Dt.Iniício"   , "AD1_DTINI" , "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Dt.Término"   , "AD1_DTFIM" , "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Vendedor"     , "AD1_VEND"  , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Prospect"     , "AD1_PROSPE", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Loja Prosp."  , "AD1_LOJPRO", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Hora"         , "AD1_HORA"  , "C", "5"  , "0" } )
              aAdd( aEstrutura, { "Cliente"      , "AD1_CODCLI", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Loja"         , "AD1_LOJCLI", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Moeda"        , "AD1_MOEDA" , "N", "2"  , "0" } )
              aAdd( aEstrutura, { "Processo"     , "AD1_PROVEN", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Estágio"      , "AD1_STAGE" , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Prioridade"   , "AD1_PRIOR" , "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Status"       , "AD1_STATUS", "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Usuário"      , "AD1_USER"  , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Verba"        , "AD1_VERBA" , "N", "12" , "2" } )
              aAdd( aEstrutura, { "Produto"      , "AD1_CODPRO", "C", "30" , "0" } )
              aAdd( aEstrutura, { "F.C.S."       , "AD1_FCS"   , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "F.C.I."       , "AD1_FCI"   , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Orçamento"    , "AD1_NUMORC", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Modo"         , "AD1_MODO"  , "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Comunicação"  , "AD1_COMUNI", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Cod.Atend."   , "AD1_CODTMK", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Canal"        , "AD1_CANAL" , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Encerramento" , "AD1_ENCERR", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Tabela Preço" , "AD1_TABELA", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Dt.Prev.Fim"  , "AD1_DTPFIM", "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Registro SLA" , "AD1_REGSLA", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Proposta"     , "AD1_PROPOS", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Feeling"      , "AD1_FEELIN", "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Comis.Vend. 1", "AD1_COMIS1", "N", "6"  , "2" } )
              aAdd( aEstrutura, { "Vendedor 2"   , "AD1_VEND2" , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Comis.Vend. 2", "AD1_COMIS2", "N", "6"  , "2" } )
              aAdd( aEstrutura, { "Frete"        , "AD1_FRETE" , "N", "12" , "2" } )

         Case Substr(cOnde,01,02) == "02"
              aAdd( aEstrutura, { "Filial"        , "ADY_FILIAL", "C", "2"  , "0" } )
              aAdd( aEstrutura, { "Proposta No."  , "ADY_PROPOS", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Oportunidade"  , "ADY_OPORTU", "C", "6"  , "0" } )   
              aAdd( aEstrutura, { "Cliente"       , "ADY_CODIGO", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Loja"          , "ADY_LOJA"  , "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Transportadora", "ADY_TRANSP", "C", "6"  , "0" } )

         Case Substr(cOnde,01,02) == "03"
              aAdd( aEstrutura, { "Filial"       , "ADZ_FILIAL", "C", "2"  , "0" } )
              aAdd( aEstrutura, { "Proposta"     , "ADZ_PROPOS", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Produto"      , "ADZ_PRODUT", "C", "30" , "0" } )   
              aAdd( aEstrutura, { "Descrição"    , "ADZ_DESCRI", "C", "60" , "0" } )
              aAdd( aEstrutura, { "Moeda"        , "ADZ_MOEDA" , "N", "1"  , "0" } )
              aAdd( aEstrutura, { "Cond.Pagtº"   , "ADZ_CONDPG", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Quantidade"   , "ADZ_QTDVEN", "N", "10" , "2" } )
              aAdd( aEstrutura, { "Prc Unitário" , "ADZ_PRCVEN", "N", "10" , "2" } )
              aAdd( aEstrutura, { "Vlr Total"    , "ADZ_TOTAL" , "N", "10" , "2" } )

     EndCase

   Endif

   // Pesquisa os dados para display
   If _Operacao <> "I"

      If Select("T_EXCLUI") > 0
         T_EXCLUI->( dbCloseArea() )
      EndIf
      
      cSql := "SELECT ZT2_FILIAL,"
      cSql += "       ZT2_VEND  ,"
      cSql += "       ZT2_CODI  ,"
      cSql += "       ZT2_NOME  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT2_COMA)) AS EXPRESSAO,"
      cSql += "       ZT2_TIPO  ,"
      cSql += "       ZT2_DDAT  ,"
      cSql += "       ZT2_ADAT  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT2_SDAT)) AS STRDATAS,"
      cSql += "       ZT2_DELE   "
      cSql += "  FROM " + RetSqlName("ZT2")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += "   AND ZT2_CODI = '" + Alltrim(Substr(_xFiltro,01,06)) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXCLUI", .T., .T. )

      If T_EXCLUI->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
      
      ckCodigo   := T_EXCLUI->ZT2_CODI
      ckNome     := T_EXCLUI->ZT2_NOME
      cExpressao := T_EXCLUI->EXPRESSAO
      cOnde      := T_EXCLUI->ZT2_TIPO
      cDataDe    := Ctod(Substr(T_EXCLUI->ZT2_DDAT,07,02) + "/" + Substr(T_EXCLUI->ZT2_DDAT,05,02) + "/" + Substr(T_EXCLUI->ZT2_DDAT,01,04))
      cDataAte   := Ctod(Substr(T_EXCLUI->ZT2_ADAT,07,02) + "/" + Substr(T_EXCLUI->ZT2_ADAT,05,02) + "/" + Substr(T_EXCLUI->ZT2_ADAT,01,04))
      cStringD   := T_EXCLUI->STRDATAS

      // Carrega o array aLista com as informações dos campos da tabela AD1
      Do Case
         Case T_EXCLUI->ZT2_TIPO == "01"
              aCampos := { "Filial"     , "Oportunidade" , "Revisão" , "Descrição"   , "Dt.Abertura"  ,;   
                           "Dt.Iniício" , "Dt.Término"   , "Vendedor", "Prospect"    , "Loja Prosp."  ,;
                           "Hora"       , "Cliente"      , "Loja"    , "Moeda"       , "Processo"     ,;
                           "Estágio"    , "Prioridade"   , "Status"  , "Usuário"     , "Verba"        ,;
                           "Produto"    , "F.C.S."       , "F.C.I."  , "Orçamento"   , "Modo"         ,;
                           "Comunicação", "Cod.Atend."   , "Canal"   , "Encerramento", "Tabela Preço" ,;
                           "Dt.Prev.Fim", "Registro SLA" , "Proposta", "Feeling"     , "Comis.Vend. 1",;
                           "Vendedor 2" , "Comis.Vend. 2", "Frete" }
                           
         Case T_EXCLUI->ZT2_TIPO == "02"
              aCampos := { "Filial", "Proposta", "Oportunidade", "Cliente", "Loja", "Transportadora" }
                           
         Case T_EXCLUI->ZT2_TIPO == "03"
              aCampos := { "Filial"    , "Proposta"  , "Produto"   , "Descrição"   ,;
                           "Moeda"     , "Cond.Pagtº", "Quantidade", "Prc Unitário",;
                           "Vlr Total" }

      EndCase

      // Carrega o array aLista com as informações dos campos da tabela AD1
      Do Case
         Case T_EXCLUI->ZT2_TIPO == "01"
              aAdd( aEstrutura, { "Filial"       , "AD1_FILIAL", "C", "2"  , "0" } )
              aAdd( aEstrutura, { "Oportunidade" , "AD1_NROPOR", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Revisão"      , "AD1_REVISA", "C", "2"  , "0" } )   
              aAdd( aEstrutura, { "Descrição"    , "AD1_DESCRI", "C", "30" , "0" } )
              aAdd( aEstrutura, { "Dt.Abertura"  , "AD1_DATA"  , "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Dt.Iniício"   , "AD1_DTINI" , "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Dt.Término"   , "AD1_DTFIM" , "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Vendedor"     , "AD1_VEND"  , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Prospect"     , "AD1_PROSPE", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Loja Prosp."  , "AD1_LOJPRO", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Hora"         , "AD1_HORA"  , "C", "5"  , "0" } )
              aAdd( aEstrutura, { "Cliente"      , "AD1_CODCLI", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Loja"         , "AD1_LOJCLI", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Moeda"        , "AD1_MOEDA" , "N", "2"  , "0" } )
              aAdd( aEstrutura, { "Processo"     , "AD1_PROVEN", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Estágio"      , "AD1_STAGE" , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Prioridade"   , "AD1_PRIOR" , "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Status"       , "AD1_STATUS", "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Usuário"      , "AD1_USER"  , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Verba"        , "AD1_VERBA" , "N", "12" , "2" } )
              aAdd( aEstrutura, { "Produto"      , "AD1_CODPRO", "C", "30" , "0" } )
              aAdd( aEstrutura, { "F.C.S."       , "AD1_FCS"   , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "F.C.I."       , "AD1_FCI"   , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Orçamento"    , "AD1_NUMORC", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Modo"         , "AD1_MODO"  , "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Comunicação"  , "AD1_COMUNI", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Cod.Atend."   , "AD1_CODTMK", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Canal"        , "AD1_CANAL" , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Encerramento" , "AD1_ENCERR", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Tabela Preço" , "AD1_TABELA", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Dt.Prev.Fim"  , "AD1_DTPFIM", "D", "8"  , "0" } )
              aAdd( aEstrutura, { "Registro SLA" , "AD1_REGSLA", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Proposta"     , "AD1_PROPOS", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Feeling"      , "AD1_FEELIN", "C", "1"  , "0" } )
              aAdd( aEstrutura, { "Comis.Vend. 1", "AD1_COMIS1", "N", "6"  , "2" } )
              aAdd( aEstrutura, { "Vendedor 2"   , "AD1_VEND2" , "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Comis.Vend. 2", "AD1_COMIS2", "N", "6"  , "2" } )
              aAdd( aEstrutura, { "Frete"        , "AD1_FRETE" , "N", "12" , "2" } )

         Case T_EXCLUI->ZT2_TIPO == "02"
              aAdd( aEstrutura, { "Filial"        , "ADY_FILIAL", "C", "2"  , "0" } )
              aAdd( aEstrutura, { "Proposta No."  , "ADY_PROPOS", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Oportunidade"  , "ADY_OPORTU", "C", "6"  , "0" } )   
              aAdd( aEstrutura, { "Cliente"       , "ADY_CODIGO", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Loja"          , "ADY_LOJA"  , "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Transportadora", "ADY_TRANSP", "C", "6"  , "0" } )

         Case T_EXCLUI->ZT2_TIPO == "03"
              aAdd( aEstrutura, { "Filial"       , "ADZ_FILIAL", "C", "2"  , "0" } )
              aAdd( aEstrutura, { "Proposta"     , "ADZ_PROPOS", "C", "6"  , "0" } )
              aAdd( aEstrutura, { "Produto"      , "ADZ_PRODUT", "C", "30" , "0" } )   
              aAdd( aEstrutura, { "Descrição"    , "ADZ_DESCRI", "C", "60" , "0" } )
              aAdd( aEstrutura, { "Moeda"        , "ADZ_MOEDA" , "N", "1"  , "0" } )
              aAdd( aEstrutura, { "Cond.Pagtº"   , "ADZ_CONDPG", "C", "3"  , "0" } )
              aAdd( aEstrutura, { "Quantidade"   , "ADZ_QTDVEN", "N", "10" , "2" } )
              aAdd( aEstrutura, { "Prc Unitário" , "ADZ_PRCVEN", "N", "10" , "2" } )
              aAdd( aEstrutura, { "Vlr Total"    , "ADZ_TOTAL" , "N", "10" , "2" } )
      EndCase

   Endif

   // Desenha a tela para display
   DEFINE MSDIALOG oDlgM TITLE "Cadastro de Filtros de Pesquisa - Proposta Comercial" FROM C(178),C(181) TO C(615),C(614) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlgM

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(209),C(001) PIXEL OF oDlgM

   @ C(035),C(005) Say "Vendedor"            Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(060),C(005) Say "Código"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(060),C(036) Say "Descrição do Filtro" Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(082),C(005) Say "Campo"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(082),C(082) Say "Operador"            Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(103),C(005) Say "Expressão"           Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(164),C(005) Say "Filtro por data - Somente para tabela do tipo 03 - Produtos da Proposta Comercial" Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(176),C(027) Say "Data de"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(176),C(090) Say "até"                 Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   Do Case
      Case _Operacao == "I"
           @ C(044),C(005) MsGet    oGet1     Var   ckVendedor Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
           @ C(069),C(005) MsGet    oGet2     Var   ckCodigo   Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
           @ C(069),C(036) MsGet    oGet3     Var   ckNome     Size C(176),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM
           @ C(091),C(005) ComboBox cComboBx1 Items aCampos    Size C(072),C(010)                              PIXEL OF oDlgM
           @ C(091),C(082) ComboBox cComboBx2 Items aOperador  Size C(130),C(010)                              PIXEL OF oDlgM
           @ C(112),C(005) MsGet    oGet4     Var   ckComando  Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM

           @ C(124),C(063) Button "Adicionar"     Size C(027),C(008) PIXEL OF oDlgM ACTION( IncComando("A",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(096) Button "("             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("(",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(112) Button ")"             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando(")",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(128) Button "e"             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("e",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(144) Button "ou"            Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("o",cComboBx1, cComboBx2, ckComando) )

           @ C(136),C(005) GET oMemo2 Var cExpressao MEMO Size C(207),C(024) PIXEL OF oDlgM When lChumba
           
 	       @ C(174),C(050) MsGet    oGet5     Var   cDataDe     Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When Substr(cOnde,01,02) == "03"
	       @ C(174),C(101) MsGet    oGet6     Var   cDataAte    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When Substr(cOnde,01,02) == "03"
     	   @ C(175),C(143) Button   "Confirma"                  Size C(037),C(008)                              PIXEL OF oDlgM ACTION( ConfData(cDataDe, cDataAte ) ) When Substr(cOnde,01,02) == "03"
	       @ C(189),C(005) GET      oMemo3    Var cStringD MEMO Size C(207),C(009)                              PIXEL OF oDlgM When lChumba

           @ C(202),C(005) Button "Limpar Comando" Size C(052),C(012) PIXEL OF oDlgM ACTION( LimpaLinha() ) 
           @ C(202),C(136) Button "Salvar"         Size C(037),C(012) PIXEL OF oDlgM ACTION( SalvaFiltro(_Operacao) )

      Case _Operacao == "A"
           @ C(044),C(005) MsGet    oGet1     Var   ckVendedor Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
           @ C(069),C(005) MsGet    oGet2     Var   ckCodigo   Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
           @ C(069),C(036) MsGet    oGet3     Var   ckNome     Size C(176),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM
           @ C(091),C(005) ComboBox cComboBx1 Items aCampos    Size C(072),C(010)                              PIXEL OF oDlgM
           @ C(091),C(082) ComboBox cComboBx2 Items aOperador  Size C(130),C(010)                              PIXEL OF oDlgM
           @ C(112),C(005) MsGet    oGet4     Var   ckComando  Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM

           @ C(124),C(063) Button "Adicionar"     Size C(027),C(008) PIXEL OF oDlgM ACTION( IncComando("A",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(096) Button "("             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("(",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(112) Button ")"             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando(")",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(128) Button "e"             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("e",cComboBx1, cComboBx2, ckComando) )
           @ C(124),C(144) Button "ou"            Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("o",cComboBx1, cComboBx2, ckComando) )

           @ C(136),C(005) GET oMemo2 Var cExpressao MEMO Size C(207),C(024) PIXEL OF oDlgM When lChumba
           
 	       @ C(174),C(050) MsGet    oGet5     Var   cDataDe     Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When Substr(cOnde,01,02) == "03"
	       @ C(174),C(101) MsGet    oGet6     Var   cDataAte    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When Substr(cOnde,01,02) == "03"
     	   @ C(175),C(143) Button   "Confirma"                  Size C(037),C(008)                              PIXEL OF oDlgM ACTION( ConfData(cDataDe, cDataAte ) ) When Substr(cOnde,01,02) == "03"
	       @ C(189),C(005) GET      oMemo3    Var cStringD MEMO Size C(207),C(009)                              PIXEL OF oDlgM When lChumba

           @ C(202),C(005) Button "Limpar Comando" Size C(052),C(012) PIXEL OF oDlgM ACTION( LimpaLinha() ) 
           @ C(202),C(136) Button "Salvar"         Size C(037),C(012) PIXEL OF oDlgM ACTION( SalvaFiltro(_Operacao) )

      Case _Operacao == "E"
           @ C(044),C(005) MsGet    oGet1     Var   ckVendedor Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
           @ C(069),C(005) MsGet    oGet2     Var   ckCodigo   Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
           @ C(069),C(036) MsGet    oGet3     Var   ckNome     Size C(176),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
           @ C(091),C(005) ComboBox cComboBx1 Items aCampos    Size C(072),C(010)                              PIXEL OF oDlgM When lChumba
           @ C(091),C(082) ComboBox cComboBx2 Items aOperador  Size C(130),C(010)                              PIXEL OF oDlgM When lChumba

           @ C(112),C(005) MsGet    oGet4     Var   ckComando  Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba

           @ C(124),C(063) Button "Adicionar"     Size C(027),C(008) PIXEL OF oDlgM ACTION( IncComando("A",cComboBx1, cComboBx2, ckComando) ) When lChumba
           @ C(124),C(096) Button "("             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("(",cComboBx1, cComboBx2, ckComando) ) When lChumba
           @ C(124),C(112) Button ")"             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando(")",cComboBx1, cComboBx2, ckComando) ) When lChumba
           @ C(124),C(128) Button "e"             Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("e",cComboBx1, cComboBx2, ckComando) ) When lChumba
           @ C(124),C(144) Button "ou"            Size C(009),C(008) PIXEL OF oDlgM ACTION( IncComando("o",cComboBx1, cComboBx2, ckComando) ) When lChumba

           @ C(136),C(005) GET oMemo2 Var cExpressao MEMO Size C(207),C(024) PIXEL OF oDlgM When lChumba
           
 	       @ C(174),C(050) MsGet    oGet5      Var   cDataDe     Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
	       @ C(174),C(101) MsGet    oGet6      Var   cDataAte    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
     	   @ C(175),C(143) Button   "Confirma"                   Size C(037),C(008)                              PIXEL OF oDlgM ACTION( ConfData(cDataDe, cDataAte) ) When lChumba
	       @ C(189),C(005) GET      oMemo3     Var cStringD MEMO Size C(207),C(009)                              PIXEL OF oDlgM When lChumba

           @ C(202),C(136) Button "Excluir"  Size C(037),C(012) PIXEL OF oDlgM ACTION( SalvaFiltro(_Operacao) )
   EndCase
      
   @ C(202),C(175) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// Função que carrega o campo omemo3 com o período selecionado para tabelas do tipo 3 - produtos da proposta comercial
Static Function ConfData( _DataDe, _DataAte)

   If Empty(_DataDe)
      MsgAlert("Data De não informada.")
      Return(.T.)
   Endif
      
   If Empty(_DataAte)
      MsgAlert("Data Até não informada.")
      Return(.T.)
   Endif

   If _DataAte < _DataDe
      MsgAlert("Data até não pode ser menor que a Data de. Verifique!")
      Return(.T.)
   Endif
      
   cStringD := " AND B.ADY_DATA >= '" + Substr(Dtoc(_DataDe) ,07,04) + Substr(Dtoc(_DataDe) ,04,02) + Substr(Dtoc(_DataDe) ,01,02) + "' " + ;
               " AND B.ADY_DATA <= '" + Substr(Dtoc(_DataAte),07,04) + Substr(Dtoc(_DataAte),04,02) + Substr(Dtoc(_DataAte),01,02) + "' "
   oMemo3:Refresh()

Return(.T.)

// Função que Salva o Filtro
Static Function SalvaFiltro(_Operacao) 

   // Gera consistência dos dados antes de salvar
   If _Operacao == "I"
      If Empty(Alltrim(ckVendedor))
         MsgAlert("Vendedor não informado.")
         Return(.T.)
      Endif
   
      If Empty(Alltrim(ckNome))
         MsgAlert("Título do filtro não informado.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cExpressao))
         MsgAlert("Nenhum comando informado.")
         Return(.T.)
      Endif
   Endif

   // Inclusão
   If _Operacao == "I"

      // Pesquisa o próximo código para inclusão
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZT2_FILIAL,"
      cSql += "       ZT2_CODI   "
      cSql += "  FROM " + RetSqlName("ZT2")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += " ORDER BY ZT2_CODI DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         _Numero := '000001'
      Else
         _Numero := Strzero(INT(VAL(T_PROXIMO->ZT2_CODI)) + 1,6)
      Endif

      // Inclui o resgistro na tabela ZT2
      DbSelectArea("ZT2")
      RecLock("ZT2",.T.)
      ZT2_FILIAL := ""
      ZT2_VEND   := Substr(cKVendedor,01,06)
      ZT2_CODI   := _Numero
      ZT2_NOME   := ckNome
      ZT2_COMA   := cExpressao
      ZT2_TIPO   := Substr(cOnde,01,02)
      ZT2_DDAT   := cDataDe
      ZT2_ADAT   := cDataAte
      ZT2_SDAT   := cStringD
      ZT2_DELE   := ""
      Msunlock()
   Endif
      
   // Alteração
   If _Operacao == "A"

      DbSelectArea("ZT2")
      DbSetorder(2)
      If DbSeek(xFilial("ZT2") + ckCodigo)
         RecLock("ZT2",.F.)
         ZT2_NOME := ckNome
         ZT2_COMA := cExpressao
         ZT2_DDAT := cDataDe
         ZT2_ADAT := cDataAte
         ZT2_SDAT := cStringD
         MsUnLock()           
      Endif   

   Endif

   // Exclusão
   If _Operacao == "E"

      If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente excluir este filtro?")

         cSql := ""
         cSql := "DELETE FROM " + RetSqlName("ZT2")
         cSql += " WHERE ZT2_CODI = '" + Alltrim(ckCodigo) + "'"
          
         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
         Endif
         
      Endif
      
   Endif

   oDlgM:End()

   CargaFiltros(2, cKVendedor)
   
Return(.T.)   

// Função que limpa a linha de comando
Static Function LimpaLinha()

   If Empty(Alltrim(cExpressao))
      Return(.T.)
   Endif

   If MsgYesNo("Deseja realmente limpar a linha de comando?")
      cExpressao := ""
      oMemo2:Refresh()
      ckComando  := Space(250)
      oGet4:Refresh()
   Endif

Return(.T.)   

/*
// Função que testa a expressão informada
Static Function Testalinha(_Expressao)
                                     
   Local cSql := ""

   Local bError := { |oError| MyError( oError ) }
   Local oError
   
   If Empty(Alltrim(_Expressao))
      MsgAlert("Nenhuma expressão para filtro informada.")
      Return(.T.)
   Endif

   If Select("T_TESTE") > 0
      T_TESTE->( dbCloseArea() )
   EndIf

   cSql := ""
   csql := "SELECT *"
   cSql += "  FROM " + RetSqlName("AD1") 
   cSql += " WHERE D_E_L_E_T_ = ''   " 
   cSql += "   AND " + Alltrim(_Expressao)

   TRY EXCEPTION USING bError

      cSql := ChangeQuery( cSql )
//      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TESTE",.T.,.T.)

      __EXCEPTION__->ERROR := dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TESTE",.T.,.T.)
      
   CATCH EXCEPTION USING oError

      MsgInfo( "Atenção! Expressão contém erro de systaxe. Verifique!")

   END TRY

Return(.T.)
*/

// Função que adiciona a expressão ao comando
Static Function IncComando(_TipoOper, _Campo, _Operador, _Expressao)

   Local xOperador  := ""
   Local nContar    := 0
   Local _NomeCampo := ""
   Local _TipoCampo := ""
   Local _TamaCampo := 0
   Local _DeciCampo := 0

   If _TipoOper == "A"
      If Empty(Alltrim(ckComando))
         Return(.T.)
      Endif
   Endif   

   // Captura as características do campo selecionado
   For nContar = 1 to Len(aEstrutura)
       If Upper(Alltrim(_Campo)) == Upper(Alltrim(aEstrutura[nContar,01]))
          _NomeCampo := aEstrutura[nContar,02]
          _TipoCampo := aEstrutura[nContar,03]
          _TamaCampo := Int(Val(aEstrutura[nContar,04]))
          _DeciCampo := Int(Val(aEstrutura[nContar,05]))
          Exit
       Endif
   Next nContar       

   // Trata o Operador selecionado
   Do Case
      Case Substr(_Operador,01,02) == "01"
           xOperador := "="
      Case Substr(_Operador,01,02) == "02"
           xOperador := "<>"
      Case Substr(_Operador,01,02) == "03"
           xOperador := "<"
      Case Substr(_Operador,01,02) == "04"
           xOperador := "<="
      Case Substr(_Operador,01,02) == "05"
           xOperador := ">"
      Case Substr(_Operador,01,02) == "06"
           xOperador := ">="
      Case Substr(_Operador,01,02) == "07"
           xOperador := "LIKE '%"
      Case Substr(_Operador,01,02) == "08"
           xOperador := "NOT LIKE '%"
      Case Substr(_Operador,01,02) == "09"
           xOperador := "IN ("
      Case Substr(_Operador,01,02) == "10"
           xOperador := "NOT IN ("
   EndCase
   
   Do Case
      Case _TipoOper == "A"

           If _TipoCampo == "C"

              If Substr(_Operador,01,02) == "07" .Or. ;
                 Substr(_Operador,01,02) == "08" .Or. ;
                 Substr(_Operador,01,02) == "09" .Or. ;
                 Substr(_Operador,01,02) == "10"
                 cExpressao := cExpressao + "A." + Alltrim(_NomeCampo) + " " + xOperador + Alltrim(_Expressao)
              Else   
                 cExpressao := cExpressao + "A." + Alltrim(_NomeCampo) + " " + xOperador + " '" + Alltrim(_Expressao) + "' "
              Endif   

           Else

              If _TipoCampo == "D"
                 cExpressao := cExpressao + "A." + Alltrim(_NomeCampo) + " " + xOperador + " " + "CONVERT(DATETIME,'" + Alltrim(_Expressao) + "', 103)"
              Else
                 cExpressao := cExpressao + "A." + Alltrim(_NomeCampo) + " " + xOperador + " " + Alltrim(_Expressao) + " "
              Endif   
           Endif

           Do Case
              Case Substr(_Operador,01,02) == "07"
                   cExpressao := Alltrim(cExpressao) + "%'" + " " 
              Case Substr(_Operador,01,02) == "08"
                   cExpressao := Alltrim(cExpressao) + "%'" + " " 
              Case Substr(_Operador,01,02) == "09"
                   cExpressao := Alltrim(cExpressao) + ")" + " " 
              Case Substr(_Operador,01,02) == "10"
                   cExpressao := Alltrim(cExpressao) + ")" + " " 
           EndCase         

      Case _TipoOper == "("
           cExpressao := cExpressao + "( "
      Case _TipoOper == ")"
           cExpressao := cExpressao + ") "
      Case _TipoOper == "e"
           cExpressao := cExpressao + "and "
      Case _TipoOper == "o"
           cExpressao := cExpressao + "or "
   EndCase
   
   oMemo2:Refresh()

   ckComando := Space(250)
   oGet4:Refresh()
   
Return(.T.)