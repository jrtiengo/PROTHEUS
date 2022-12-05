#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM193.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/10/2013                                                          *
// Objetivo..: Manutenção Tabela de Preço                                          *
//**********************************************************************************

User Function AUTOM193()

   Local cSql        := ""

   Private aPrecos   := {}
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

   Private oDlgXXX

   U_AUTOM628("AUTOM193")
   
   If Select("T_TABELA") > 0
      T_TABELA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA0_CODTAB,"
   cSql += "       DA0_DESCRI,"
   cSql += "       DA0_DATDE ,"
   cSql += "       DA0_DATATE,"
   cSql += "       DA0_CONDPG,"
   cSql += "       DA0_TPHORA,"
   cSql += "       DA0_ATIVO  "
   cSql += "  FROM " + RetSqlName("DA0")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY DA0_CODTAB  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

   If T_TABELA->( EOF() )
      aAdd( aPrecos, { "1", "", "", "", "", "", "", "" } )
   Else
   
      T_TABELA->( DbGoTop() )
      
      WHILE !T_TABELA->( EOF() )
         
         dInicial := Ctod(Substr(T_TABELA->DA0_DATDE ,07,02) + "/" + Substr(T_TABELA->DA0_DATDE ,05,02) + "/" + Substr(T_TABELA->DA0_DATDE ,01,04))
         dFinal   := Ctod(Substr(T_TABELA->DA0_DATATE,07,02) + "/" + Substr(T_TABELA->DA0_DATATE,05,02) + "/" + Substr(T_TABELA->DA0_DATATE,01,04))

         Do Case
            Case Date() > dFinal
                 cLegenda := "8"
            Case Date() >= dInicial .And. Date() <= dFinal .And. T_TABELA->DA0_ATIVO == "2"
                 cLegenda := "6"
            Case Date() >= dInicial .And. Date() <= dFinal .And. T_TABELA->DA0_ATIVO == "1"
                 cLegenda := "2"
            OTHERWISE
                 cLegenda := "1"                             
         EndCase

         aAdd( aPrecos, { cLegenda             ,;
                          T_TABELA->DA0_CODTAB ,;
                          T_TABELA->DA0_DESCRI ,;
                          Dtoc(dInicial)       ,;
                          Dtoc(dFinal)         ,;
                          ""                   ,;
                          IIF(T_TABELA->DA0_TPHORA == "1", "UNICO", "RECORRENTE") ,;
                          IIF(T_TABELA->DA0_ATIVO  == "1", "SIM"  , "NÃO")        })
                          
         T_TABELA->( DbSkip() )

      ENDDO
      
   Endif

   DEFINE MSDIALOG oDlgXXX TITLE "Tabelas de Preços" FROM C(178),C(181) TO C(511),C(906) PIXEL

   @ C(153),C(016) Say "Tabela Inativa"        Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgXXX
   @ C(153),C(073) Say "Tabela Ativa"          Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgXXX
   @ C(153),C(125) Say "Tabela Ativa Especial" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgXXX

   @ C(153),C(005) Jpeg FILE "br_vermelho" Size C(008),C(008) PIXEL NOBORDER OF oDlgXXX
   @ C(153),C(060) Jpeg FILE "br_verde"    Size C(008),C(008) PIXEL NOBORDER OF oDlgXXX
   @ C(153),C(112) Jpeg FILE "br_laranja"  Size C(008),C(008) PIXEL NOBORDER OF oDlgXXX

   @ C(151),C(261) Button "Visualizar"                    Size C(047),C(012) PIXEL OF oDlgXXX ACTION( Abre_Lista(aPrecos[oPrecos:nAt,02]) )
   @ C(151),C(309) Button "Voltar"                        Size C(047),C(012) PIXEL OF oDlgXXX ACTION( oDlgXXX:End() )

   oPrecos := TCBrowse():New( 005 , 005, 455, 185,,{'Lg ', 'Código', 'Descrição', 'Data Inicial', 'Data Final', 'Cond. Pagtº', 'Tipo Horário', 'Tab. Ativa'},{20,50,50,50},oDlgXXX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oPrecos:SetArray(aPrecos) 
    
   // Monta a linha a ser exibina no Browse
   oPrecos:bLine := {||{ If(aPrecos[oPrecos:nAt,01] == "1", oBranco   ,;
                         If(aPrecos[oPrecos:nAt,01] == "2", oVerde    ,;
                         If(aPrecos[oPrecos:nAt,01] == "3", oPink     ,;                         
                         If(aPrecos[oPrecos:nAt,01] == "4", oAmarelo  ,;                         
                         If(aPrecos[oPrecos:nAt,01] == "5", oAzul     ,;                         
                         If(aPrecos[oPrecos:nAt,01] == "6", oLaranja  ,;                         
                         If(aPrecos[oPrecos:nAt,01] == "7", oPreto    ,;                         
                         If(aPrecos[oPrecos:nAt,01] == "8", oVermelho ,;
                         If(aPrecos[oPrecos:nAt,01] == "9", oEncerra, ""))))))))),;                         
                         aPrecos[oPrecos:nAt,02]            ,;
                         aPrecos[oPrecos:nAt,03]            ,;
                         aPrecos[oPrecos:nAt,04]            ,;
                         aPrecos[oPrecos:nAt,05]            ,;
                         aPrecos[oPrecos:nAt,06]            ,;
                         aPrecos[oPrecos:nAt,07]            ,;                                                                                                    
                         aPrecos[oPrecos:nAt,08]           } }

   ACTIVATE MSDIALOG oDlgXXX CENTERED 

Return(.T.)

// Função que abre a tela com os produtos da lista de preço selecionada
Static Function Abre_Lista(_Codigo)

   Local cSql          := ""

   Private lChumba     := .F.
   Private lDeAte      := .F.
   Private lString     := .F.
   Private lMargem     := .F.
   Private lImporta    := .F.

   Private aOrdenacao  := {"1 - Descrição", "2 - Código", "3 - Grupo + Descrição", "4 - Promotipo + Descrição", "5 - Margem Bruta %", "6 - Part Number + Descrição", "7 - Data de Alteração + Descrição", "8 - Item", "9 - Tipo de Registro + Descrição" }
   Private aFiltro     := {"0 - Nenhum Filtro", "1 - Código Produto", "2 - Grupo", "3 - Promotipo", "4 - Descrição", "5 - Margem Bruta", "6 - Part Number", "7 - Data de Alteração", "8 - Tipo de Registro" }
   Private aSinal      := {"1 - Igual", "2 - Maior Igual", "3 - Menor", "4 - Menor Igual", "5 - Diferente" }

   Private cCodigo	   := Space(03)
   Private cDescricao  := Space(40)
   Private dInicial    := Space(10)
   Private dFinal      := Space(10)
   Private cCondicao   := Space(03)
   Private cHorario    := Space(25)
   Private cAtiva	   := Space(03)
   Private cTaxa       := 0
   Private cImportacao := ""
   Private cTotal      := 0

   Private cDe	       := Space(20)
   Private cAte	       := Space(20)
   Private cString	   := Space(100)
   Private cMargem     := 0
   Private dImportacao := cTod("  /  /    ")

   Private cMemo1	   := ""
   Private cMemo2	   := ""
   Private cMemo3	   := ""
   Private cMemo4	   := ""
   Private cMemo5	   := ""
   Private cMemo6	   := ""
   Private cMemo7	   := ""            

   Private cOrdenacao
   Private cFiltro
   Private cSinal

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

   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4
   Private oMemo5
   Private oMemo6
   Private oMemo7               

   Private aLista := {}

   Private oDlgL

   // Pesquisa o Cabeçalho da tabela de preço selecionada
   If Empty(Alltrim(_Codigo))
      Return(.T.)
   Endif

   // pesquisa a taxa do dolar do dia atual
   If Select("T_TAXA") > 0
      T_TAXA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT M2_DATA  , "
   cSql += "       M2_MOEDA2  "
   cSql += "  FROM " + RetSqlName("SM2")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND M2_DATA    = '" + Strzero(Year(Date()),4) + Strzero(Month(Date()),2) + Strzero(Day(Date()),2) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAXA", .T., .T. )

   If T_TAXA->( EOF() )
      cTaxa := 0
   Else
      cTaxa := T_TAXA->M2_MOEDA2
   Endif

   // Pesquisa a Data de Importação da Tabela de Preço
   If Select("T_IMPORTACAO") > 0
      T_IMPORTACAO->( dbCloseArea() )
   EndIf

   cSql := "SELECT DA1_DIMPO"
   cSql += "  FROM " + RetSqlName("DA1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND DA1_CODTAB = '" + Alltrim(_Codigo) + "'"
   cSql += " GROUP BY DA1_DIMPO"
   cSql += " ORDER BY DA1_DIMPO DESC"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IMPORTACAO", .T., .T. )

   If T_IMPORTACAO->( EOF() )
      cImportacao := "  /  /    "
   Else
      cImportacao := Substr(T_IMPORTACAO->DA1_DIMPO,07,02) + "/" + Substr(T_IMPORTACAO->DA1_DIMPO,05,02) + "/" + Substr(T_IMPORTACAO->DA1_DIMPO,01,04)
   Endif

   // Pesquisa os dados do cabeçalho da tabela de preço selecionada      
   If Select("T_TABELA") > 0
      T_TABELA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA0_CODTAB,"
   cSql += "       DA0_DESCRI,"
   cSql += "       DA0_DATDE ,"
   cSql += "       DA0_DATATE,"
   cSql += "       DA0_CONDPG,"
   cSql += "       DA0_TPHORA,"
   cSql += "       DA0_ATIVO  "
   cSql += "  FROM " + RetSqlName("DA0")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND DA0_CODTAB = '" + Alltrim(_Codigo) + "'"
   cSql += " ORDER BY DA0_CODTAB  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

   If T_TABELA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para esta Tabela de Preço.")
      Return(.T.)
   Endif
      
   cCodigo	   := T_TABELA->DA0_CODTAB
   cDescricao  := T_TABELA->DA0_DESCRI
   dInicial    := Substr(T_TABELA->DA0_DATDE,07,02)  + "/" + Substr(T_TABELA->DA0_DATDE,05,02) + "/"  + Substr(T_TABELA->DA0_DATDE,01,04)
   dFinal      := Substr(T_TABELA->DA0_DATATE,07,02) + "/" + Substr(T_TABELA->DA0_DATATE,05,02) + "/" + Substr(T_TABELA->DA0_DATATE,01,04)
   cCondicao   := T_TABELA->DA0_CONDPG
   cHorario    := IIF(T_TABELA->DA0_TPHORA == "1", "UNICO", "RECORRENTE")
   cAtiva      := IIF(T_TABELA->DA0_ATIVO  == "1", "SIM"  , "NÃO")

   // Envia para a função que carrega o array aLista para display
   Pesquisa_Filtro(cCodigo,0)

   DEFINE MSDIALOG oDlgL TITLE "Lista de Preços" FROM C(178),C(181) TO C(609),C(1150) PIXEL

   @ C(005),C(005) Say "Cod. Tabela"         Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(040) Say "Descrição da Tabela" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(133) Say "Dta Inicial"         Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(169) Say "Dta Final"           Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(204) Say "Cond.Pgtº"           Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(231) Say "Tipo Horário"        Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(279) Say "Tab. Ativa"          Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(309) Say "Taxa U$"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(339) Say "Data Alteração"      Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(031),C(005) Say "Ordenação"           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(043),C(005) Say "Filtro"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(031),C(133) Say "De"                  Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(043),C(133) Say "Até"                 Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(031),C(175) Say "String de Pesquisa"  Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(031),C(244) Say "Sinal"               Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(043),C(244) Say "M.Bruta"             Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(031),C(304) Say "Data Alteração"      Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(202),C(154) Say "Total"               Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(001),C(400) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlgL

   @ C(028),C(005) GET oMemo1 Var cMemo1 MEMO Size C(480),C(001) PIXEL OF oDlgL
   @ C(055),C(005) GET oMemo2 Var cMemo2 MEMO Size C(480),C(001) PIXEL OF oDlgL
   @ C(030),C(129) GET oMemo3 Var cMemo3 MEMO Size C(001),C(023) PIXEL OF oDlgL
   @ C(030),C(171) GET oMemo4 Var cMemo4 MEMO Size C(001),C(023) PIXEL OF oDlgL
   @ C(030),C(240) GET oMemo5 Var cMemo5 MEMO Size C(001),C(023) PIXEL OF oDlgL
   @ C(030),C(300) GET oMemo6 Var cMemo6 MEMO Size C(001),C(023) PIXEL OF oDlgL
   @ C(030),C(353) GET oMemo7 Var cMemo7 MEMO Size C(001),C(023) PIXEL OF oDlgL

   @ C(014),C(005) MsGet    oGet1      Var cCodigo      When lChumba Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(040) MsGet    oGet2      Var cDescricao   When lChumba Size C(089),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(133) MsGet    oGet3      Var dInicial     When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(169) MsGet    oGet4      Var dFinal       When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(204) MsGet    oGet5      Var cCondicao    When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(231) MsGet    oGet6      Var cHorario     When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(279) MsGet    oGet7      Var cAtiva       When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(308) MsGet    oGet13     Var cTaxa        When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@E 9.9999" PIXEL OF oDlgL
   @ C(014),C(339) MsGet    oGet14     Var cImportacao  When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL

   @ C(030),C(036) ComboBox cOrdenacao Items aOrdenacao                Size C(090),C(010) PIXEL OF oDlgL
   @ C(042),C(036) ComboBox cFiltro    Items aFiltro                   Size C(090),C(010) PIXEL OF oDlgL VALID(Liga_Desliga())
   @ C(031),C(144) MsGet    oGet9      Var   cDe         When lDeAte   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(043),C(144) MsGet    oGet10     Var   cAte        When lDeAte   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(043),C(175) MsGet    oGet8      Var   cString     When lString  Size C(061),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(031),C(260) ComboBox cSinal     Items aSinal      When lMargem  Size C(038),C(010) PIXEL OF oDlgL
   @ C(043),C(268) MsGet    oGet11     Var   cMargem     When lMargem  Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(043),C(304) MsGet    oGet12     Var   dImportacao When lImporta Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(201),C(171) MsGet    oGet15     Var   cTotal      When lChumba  Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL

   @ C(030),C(356) Button "Pesquisar"                    Size C(028),C(011) PIXEL OF oDlgL ACTION( Pesquisa_Filtro(cCodigo,1) )
   @ C(042),C(356) Button "Default"                      Size C(028),C(011) PIXEL OF oDlgL ACTION( Pesquisa_Filtro(cCodigo,3) )

   @ C(030),C(385) Button "Apaga Dta Alteração"          Size C(048),C(008) PIXEL OF oDlgL ACTION( LimpaData(cCodigo) )
   @ C(038),C(385) Button "Imp. Lista Fornecedor"        Size C(048),C(008) PIXEL OF oDlgL ACTION( AbreImpPreco(_Codigo) )
   @ C(046),C(385) Button "Importa Estoque"              Size C(048),C(008) PIXEL OF oDlgL ACTION( ImpEstoque(_Codigo) )

   @ C(030),C(434) Button "Atual.Prç.Vda Tipo I"         Size C(050),C(008) PIXEL OF oDlgL ACTION( AtuPrcVda(_Codigo, 1) )
   @ C(038),C(434) Button "Atual.Prç.Vda Tipo E"         Size C(050),C(008) PIXEL OF oDlgL ACTION( AtuPrcVda(_Codigo, 2) )
// @ C(046),C(434) Button "Recalcula Margem Geral"       Size C(050),C(008) PIXEL OF oDlgL ACTION( RecalculoCM(_Codigo)  )

   @ C(200),C(005) Button "Incluir"                       Size C(047),C(012) PIXEL OF oDlgL ACTION( Edita_Lista("I", _Codigo, "", "" ) )
   @ C(200),C(053) Button "Editar"                        Size C(047),C(012) PIXEL OF oDlgL ACTION( Edita_Lista("A", _Codigo, aLista[oLista:nAt,02], aLista[oLista:nAt,03]) )
   @ C(200),C(101) Button "Excluir"                       Size C(047),C(012) PIXEL OF oDlgL ACTION( Edita_Lista("E", _Codigo, aLista[oLista:nAt,02], aLista[oLista:nAt,03]) )
   @ C(200),C(202) Button "Consulta Saldos Fora da Lista" Size C(079),C(012) PIXEL OF oDlgL ACTION( ConSaldos(_Codigo) )
   @ C(200),C(311) Button "Hist. Produto"                 Size C(037),C(012) PIXEL OF oDlgL ACTION( Hist_Produto(aLista[oLista:nAt,03]) )
   @ C(200),C(353) Button "Saldo"                         Size C(037),C(012) PIXEL OF oDlgL ACTION(xSaldoLista(aLista[oLista:nAt,03]) )
   @ C(200),C(395) Button "Legenda"                       Size C(037),C(012) PIXEL OF oDlgL ACTION( xLegendaPq() )
   @ C(200),C(437) Button "Voltar"                        Size C(047),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   oLista := TCBrowse():New( 075 , 005, 613, 177,,{'Lg ', 'Item', 'Código', 'Grupo', 'Descrição Produtos', 'Part Number', 'Moeda', 'Vlr Vda Moeda', 'Vlr Vda Conv.', 'Fator', 'CM(POA)',  'Custo STD', 'Moeda Custo STD', 'Margem Bruta (%)', 'Desconto', 'PromoTipo', 'Tipo Reg', 'Data Alteração'},{20,50,50,50},oDlgL,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oLista:SetArray(aLista) 
    
   // Monta a linha a ser exibina no Browse
   oLista:bLine := {||{ If(aLista[oLista:nAt,01] == "1", oBranco   ,;
                        If(aLista[oLista:nAt,01] == "2", oVerde    ,;
                        If(aLista[oLista:nAt,01] == "3", oPink     ,;                         
                        If(aLista[oLista:nAt,01] == "4", oAmarelo  ,;                         
                        If(aLista[oLista:nAt,01] == "5", oAzul     ,;                         
                        If(aLista[oLista:nAt,01] == "6", oLaranja  ,;                         
                        If(aLista[oLista:nAt,01] == "7", oPreto    ,;                         
                        If(aLista[oLista:nAt,01] == "8", oVermelho ,;
                        If(aLista[oLista:nAt,01] == "9", oEncerra, ""))))))))),;                         
                        Alltrim(aLista[oLista:nAt,02])   ,;
                        Alltrim(aLista[oLista:nAt,03])   ,;
                        Alltrim(aLista[oLista:nAt,04])   ,;
                        Alltrim(aLista[oLista:nAt,05])   ,;
                        Alltrim(aLista[oLista:nAt,06])   ,;
                        aLista[oLista:nAt,07]            ,;
                        aLista[oLista:nAt,08]            ,;                                                                                                    
                        aLista[oLista:nAt,09]            ,;                                                                                                    
                        aLista[oLista:nAt,10]            ,;                                                                                                    
                        aLista[oLista:nAt,11]            ,;                                                                                                    
                        aLista[oLista:nAt,12]            ,;
                        aLista[oLista:nAt,13]            ,;
                        aLista[oLista:nAt,14]            ,;
                        aLista[oLista:nAt,15]            ,;
                        aLista[oLista:nAt,16]            ,;
                        aLista[oLista:nAt,17]            ,;
                        aLista[oLista:nAt,18]            }}

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// Função que liga/desliga campos
Static Function Liga_Desliga()

   cDe	       := Space(20)
   cAte	       := Space(20)
   cString	   := Space(100)
   cMargem     := 0
   dImportacao := Ctod("  /  /    ")

   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()

   If Substr(cFiltro,01,01) == "0"
      lDeAte   := .F.
      lString  := .F.
      lMargem  := .F.
      lImporta := .F.
      Return(.T.)
   Endif
   
   If Substr(cFiltro,01,01) == "1" 
      lDeAte   := .T.
      lString  := .F.
      lMargem  := .F.
      lImporta := .F.
      Return(.T.)
   Endif

   If Substr(cFiltro,01,01) == "2" 
      lDeAte   := .T.
      lString  := .F.
      lMargem  := .F.
      lImporta := .F.
      Return(.T.)
   Endif

   If Substr(cFiltro,01,01) == "3" 
      lDeAte   := .F.
      lString  := .T.
      lMargem  := .F.
      lImporta := .F.
      Return(.T.)
   Endif

   If Substr(cFiltro,01,01) == "4" 
      lDeAte   := .F.
      lString  := .T.
      lMargem  := .F.
      lImporta := .F.
      Return(.T.)
   Endif

   If Substr(cFiltro,01,01) == "5" 
      lDeAte   := .F.
      lString  := .F.
      lMargem  := .T.
      lImporta := .F.
      Return(.T.)
   Endif

   If Substr(cFiltro,01,01) == "6" 
      lDeAte   := .F.
      lString  := .T.
      lMargem  := .F.
      lImporta := .F.
      Return(.T.)
   Endif

   If Substr(cFiltro,01,01) == "7" 
      lDeAte   := .F.
      lString  := .F.
      lMargem  := .F.
      lImporta := .T.
      Return(.T.)
   Endif

   If Substr(cFiltro,01,01) == "8" 
      lDeAte   := .F.
      lString  := .T.
      lMargem  := .F.
      lImporta := .F.
      Return(.T.)
   Endif

Return(.T.)

// Função que pesquisa os dados pelo filtro
Static Function Pesquisa_Filtro(_Codigo, _Tipo)

   Local cSql       := ""
   Local nCor       := ""
   Local nDias      := 0
   Local nRegistros := 0

   // Pesquisa abertura do formulário
   If _Tipo == 0
      cFiltro    := "0"
      cOrdenacao := "1"
   Endif

   // Pesquisa Default
   If _Tipo == 3
      cDe	      := Space(20)
      cAte	      := Space(20)
      cString     := Space(100)
      cMargem     := 0
      dImportacao := cTod("  /  /    ")

      lDeAte      := .F.
      lString     := .F.
      lMargem     := .F.
      lImporta    := .F.

   Endif

   // Pesquisa o Parâmetro de Dias para Leganda Vermelha
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_DIAS" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      nDias := 999
   Else   
      nDias := T_PARAMETROS->ZZ4_DIAS
   Endif

   // Pesquisa os Produtos da Tabela de Preço selecionada
   If Select("T_PRECOS") > 0
      T_PRECOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT S.DA1_ITEM  ," + CHR(13)
   cSql += "       S.DA1_CODPRO," + CHR(13)
   cSql += "	   S.PRODUTO   ," + CHR(13)
   cSql += "	   S.B1_GRUPO  ," + CHR(13)
   cSql += "	   S.B1_PARNUM ," + CHR(13)
   cSql += "       S.B1_UCOM   ," + CHR(13)
   cSql += "       S.B1_CUSTD  ," + CHR(13)
   cSql += "	   S.DA1_MOEDA ," + CHR(13)
   cSql += "       S.TAXA      ," + CHR(13)
   cSql += "	   S.DA1_PRCVEN," + CHR(13)
   cSql += "       CASE S.DA1_MOEDA" + CHR(13)
   cSql += "            WHEN 1 THEN S.DA1_PRCVEN" + CHR(13)
   cSql += "            ELSE ROUND((S.DA1_PRCVEN * S.TAXA),2)" + CHR(13)
   cSql += "       END AS CONVERTIDO," + CHR(13)
   cSql += "	   S.DA1_PROMO ," + CHR(13)
   cSql += "	   S.DA1_PERDES," + CHR(13)
   cSql += "       S.DA1_DIMPO ," + CHR(13)
   cSql += "       S.DA1_TREG  ," + CHR(13)
   cSql += "       S.CUSTO     ," + CHR(13)
   cSql += "       S.DA1_FATOR ," + CHR(13)
   cSql += "       S.DA1_CUSTD ," + CHR(13)
   cSql += "       S.DA1_MCUST ," + CHR(13)
   cSql += "       ISNULL(
   cSql += "              CASE S.DA1_MOEDA" + CHR(13)
   cSql += "                   WHEN 1 THEN"  + CHR(13)
   cSql += "                      CASE"  + CHR(13)
   cSql += "                         WHEN CUSTO = 0 THEN 0.00" + CHR(13)
   cSql += "                         WHEN CUSTO <> 0 THEN ROUND((S.DA1_PRCVEN / S.CUSTO - 1) * 100,2)" + CHR(13)
   cSql += "                      END" + CHR(13)
   cSql += "                   ELSE" + CHR(13)
   cSql += "                      CASE" + CHR(13)
   cSql += "                         WHEN CUSTO = 0 THEN 0.00" + CHR(13)
   cSql += "                         WHEN CUSTO <> 0 THEN ROUND(((S.DA1_PRCVEN * S.TAXA)/ S.CUSTO - 1) * 100,2)" + CHR(13)
   cSql += "                   END" + CHR(13)
   cSql += "              END,0) AS MARGEM," + CHR(13)
   cSql += "	   S.DISPONIVEL ," + CHR(13)
   cSql += " 	   S.SAIDA       " + CHR(13)
   cSql += "  FROM" + CHR(13)
   cSql += "     (" + CHR(13)
   cSql += "	     SELECT DA1.DA1_ITEM  ," + CHR(13)
   cSql += "		        DA1.DA1_CODPRO," + CHR(13)
   cSql += "		        SB1.B1_DESC + ' ' + SB1.B1_DAUX AS PRODUTO," + CHR(13)
   cSql += "		        SB1.B1_GRUPO  ," + CHR(13)
   cSql += "		        SB1.B1_PARNUM ," + CHR(13)
   cSql += "                SB1.B1_UCOM   ," + CHR(13)
   cSql += "                SB1.B1_CUSTD  ," + CHR(13)
   cSql += "		        DA1.DA1_MOEDA ," + CHR(13)
   cSql += "		        DA1.DA1_PRCVEN," + CHR(13)
   cSql += "		        DA1.DA1_PROMO ," + CHR(13)
   cSql += "		        DA1.DA1_PERDES," + CHR(13)
   cSql += "                DA1.DA1_DIMPO ," + CHR(13)
   cSql += "                DA1.DA1_TREG  ," + CHR(13)
   cSql += "                DA1.DA1_FATOR ," + CHR(13)
   cSql += "                DA1.DA1_CUSTD ," + CHR(13)
   cSql += "                DA1.DA1_MCUST ," + CHR(13)
   cSql += "               ("                            + CHR(13)
   cSql += "                SELECT M2_MOEDA2"            + CHR(13)
   cSql += "                  FROM " + RetSqlName("SM2") + CHR(13)
   cSql += "                 WHERE M2_DATA    = '"  + Strzero(year(Date()),4) + Strzero(month(Date()),2) + Strzero(day(Date()),2) + "'" + CHR(13)
   cSql += "                   AND D_E_L_E_T_ = ''"      + CHR(13)
   cSql += "               ) AS TAXA,"                   + CHR(13)
   cSql += "                (" + CHR(13)
   cSql += "                 SELECT SUM(B2_QATU)" + CHR(13)
   cSql += "                   FROM " + RetSqlName("SB2") + CHR(13)
   cSql += "                  WHERE B2_COD = DA1.DA1_CODPRO" + CHR(13)
   cSql += "                    AND D_E_L_E_T_ = ''"  + CHR(13)
   cSql += "                  GROUP BY B2_COD" + CHR(13)
   cSql += "                ) AS DISPONIVEL," + CHR(13)
   cSql += "               (" + CHR(13)
   cSql += "                SELECT B2_USAI "               + CHR(13)
   cSql += "                  FROM " + RetSqlName("SB2")         + CHR(13)
   cSql += "                 WHERE B2_COD     = DA1.DA1_CODPRO"  + CHR(13)
   cSql += "                   AND D_E_L_E_T_ = '' "             + CHR(13)
   cSql += "                   AND B2_FILIAL  = '01'"            + CHR(13)
   cSql += "                   AND B2_LOCAL   = '01'"            + CHR(13)
   cSql += "                ) AS SAIDA," + CHR(13)
   cSql += "	           (" + CHR(13)
   cSql += "	            SELECT B2_CM1 " + CHR(13)
   cSql += "	              FROM " + RetSqlName("SB2") + CHR(13)
   cSql += "	             WHERE B2_FILIAL  = '01'" + CHR(13)
   cSql += "  	               AND B2_LOCAL   = '01'" + CHR(13)
   cSql += "	      		   AND B2_COD     = DA1.DA1_CODPRO" + CHR(13)
   cSql += "	      		   AND D_E_L_E_T_ = ''  " + CHR(13)
   cSql	+= "	            ) AS CUSTO" + CHR(13)
   cSql	+= "       FROM " + RetSqlName("DA1") + " DA1, " + CHR(13)
   cSql	+= "	        " + RetSqlName("SB1") + " SB1  " + CHR(13)
   cSql	+= "      WHERE DA1.DA1_CODTAB = '" + Alltrim(_Codigo) + "'" + CHR(13)
   cSql	+= "        AND DA1.DA1_CODPRO = SB1.B1_COD" + CHR(13)
   cSql	+= "        AND DA1.D_E_L_E_T_ = ''        " + CHR(13)
   cSql	+= "        AND SB1.D_E_L_E_T_ = ''        " + CHR(13)
   cSql += "     ) S" + CHR(13)
   
   // Aplica Filtro de pesquisa se solicitado
   If Substr(cFiltro,01,01) <> "0"

      // Filtro pelo código do produto
      If Substr(cFiltro,01,01) == "1"
         cSql += " WHERE S.DA1_CODPRO >= '" + Alltrim(cDe)  + "'" + CHR(13)
         cSql += "   AND S.DA1_CODPRO <= '" + Alltrim(cAte) + "'" + CHR(13)
      Endif
               
      // Filtro pelo código do grupo de produtos
      If Substr(cFiltro,01,01) == "2"
         cSql += " WHERE S.B1_GRUPO >= '" + Alltrim(cDe)  + "'" + CHR(13)
         cSql += "   AND S.B1_GRUPO <= '" + Alltrim(cAte) + "'" + CHR(13)
      Endif

      // Filtro pelo campo PromoTipo
      If Substr(cFiltro,01,01) == "3"
         cSql += " WHERE S.DA1_PROMO LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
      Endif

      // Filtro pelo campo Descrição do Produto
      If Substr(cFiltro,01,01) == "4"
         cSql += " WHERE S.PRODUTO LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
      Endif

      // Filtro pelo campo Margem Bruta
      If Substr(cFiltro,01,01) == "5"

         cSql += " WHERE ISNULL(CASE S.DA1_MOEDA"                                                                      + CHR(13)
         cSql += "                   WHEN 1 THEN"                                                                      + CHR(13)
         cSql += "                      CASE"                                                                          + CHR(13)
         cSql += "                         WHEN CUSTO = 0 THEN 0.00"                                                   + CHR(13)
         cSql += "                         WHEN CUSTO <> 0 THEN ROUND((S.DA1_PRCVEN / S.CUSTO - 1) * 100,2)"           + CHR(13)
         cSql += "                      END"                                                                           + CHR(13)
         cSql += "                   ELSE"                                                                             + CHR(13)
         cSql += "                      CASE"                                                                          + CHR(13)
         cSql += "                         WHEN CUSTO = 0 THEN 0.00"                                                   + CHR(13)
         cSql += "                         WHEN CUSTO <> 0 THEN ROUND(((S.DA1_PRCVEN * S.TAXA)/ S.CUSTO - 1) * 100,2)" + CHR(13)
         cSql += "                      END,0)"                                                                        + CHR(13)

         Do Case
            Case Substr(cSinal,01,01) == "1"
                 cSql += " END = " + Alltrim(str(cMargem/100))    + CHR(13)
            Case Substr(cSinal,01,01) == "2"
                 cSql += " END  >=  " + Alltrim(str(cMargem/100)) + CHR(13)
            Case Substr(cSinal,01,01) == "3"
                 cSql += " END  <  " + Alltrim(str(cMargem/100))  + CHR(13)
            Case Substr(cSinal,01,01) == "4"
                 cSql += " END  <=  " + Alltrim(str(cMargem/100)) + CHR(13)
            Case Substr(cSinal,01,01) == "5"
                 cSql += " END  <>  " + Alltrim(str(cMargem/100)) + CHR(13)
         EndCase                 

      Endif

      // Filtro pelo campo Part Number
      If Substr(cFiltro,01,01) == "6"
         cSql += " WHERE S.B1_PARNUM LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
      Endif

      // Filtro pela Data de Importação da Tabela de Preço
      If Substr(cFiltro,01,01) == "7"
         cSql += " WHERE S.DA1_DIMPO = '" + Dtoc(dImportacao) + "'" + CHR(13)
      Endif

      // Filtro pelo Tipo de Registro
      If Substr(cFiltro,01,01) == "8"
         cSql += " WHERE S.DA1_TREG = '" + Alltrim(cString) + "'" + CHR(13)
      Endif

   Endif

   // Ordenação da Pesquisa
   Do Case
      Case Substr(cOrdenacao,01,01) == "1"
           cSql += " ORDER BY S.PRODUTO" + chr(13)
      Case Substr(cOrdenacao,01,01) == "2"
           cSql += " ORDER BY S.DA1_CODPRO" + chr(13)
      Case Substr(cOrdenacao,01,01) == "3"
           cSql += " ORDER BY S.B1_GRUPO, S.PRODUTO" + chr(13)
      Case Substr(cOrdenacao,01,01) == "4"
           cSql += " ORDER BY S.DA1_PROMO, S.PRODUTO" + chr(13)
      Case Substr(cOrdenacao,01,01) == "5"
           cSql += " ORDER BY ISNULL(CASE S.DA1_MOEDA"                                                                 + CHR(13)
           cSql += "                    WHEN 1 THEN"                                                                   + CHR(13)
           cSql += "                       CASE"                                                                       + CHR(13)
           cSql += "                          WHEN CUSTO = 0 THEN 0.00"                                                + CHR(13)
           cSql += "                          WHEN CUSTO <> 0 THEN ROUND((S.DA1_PRCVEN / S.CUSTO - 1) * 100,2)"        + CHR(13)
           cSql += "                       END"                                                                        + CHR(13)
           cSql += "                 ELSE"                                                                             + CHR(13)
           cSql += "                    CASE"                                                                          + CHR(13)
           cSql += "                       WHEN CUSTO = 0 THEN 0.00"                                                   + CHR(13)
           cSql += "                       WHEN CUSTO <> 0 THEN ROUND(((S.DA1_PRCVEN * S.TAXA)/ S.CUSTO - 1) * 100,2)" + CHR(13)
           cSql += "                    END"                                                                           + CHR(13)
           cSql += "                 END, 0)"                                                                          + CHR(13)
      Case Substr(cOrdenacao,01,01) == "6"
           cSql += " ORDER BY S.B1_PARNUM, S.PRODUTO" + chr(13)
      Case Substr(cOrdenacao,01,01) == "7"
           cSql += " ORDER BY S.DA1_DIMPO, S.PRODUTO" + chr(13)
      Case Substr(cOrdenacao,01,01) == "8"
           cSql += " ORDER BY S.DA1_ITEM"  + chr(13)
      Case Substr(cOrdenacao,01,01) == "9"
           cSql += " ORDER BY S.DA1_TREG, S.PRODUTO" + chr(13)
   EndCase

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRECOS", .T., .T. )

   aLista     := {}
   nregsitros := 0

   If T_PRECOS->( EOF() )

      aAdd( aLista, { "1", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   Else

      T_PRECOS->( DbGoTop() )
      
      WHILE !T_PRECOS->( EOF() )

         // Pesquisa a cor da Legenda a ser mostrada
         If T_PRECOS->DISPONIVEL = 0
            nCor   := '1'
         Else
            nCor   := '2'

            If T_PRECOS->DA1_PROMO == "P"
               nCor := '5'
            Endif

         Endif

         // Aplica a legenda Vermelha conforme parâmetro de Dias
         If T_PRECOS->DISPONIVEL <> 0
 
            If T_PRECOS->B1_UCOM = Nil
               ULTIMA_ENTRADA := Ctod("  /  /    ")
            Else   
               ULTIMA_ENTRADA := Ctod(Substr(T_PRECOS->B1_UCOM,07,02) + "/" + ;
                                      Substr(T_PRECOS->B1_UCOM,05,02) + "/" + ;
                                      Substr(T_PRECOS->B1_UCOM,01,04))
            Endif
               
            If T_PRECOS->SAIDA = Nil
               ULTIMA_SAIDA := Ctod("  /  /    ")
            Else   
               ULTIMA_SAIDA := Ctod(Substr(T_PRECOS->SAIDA,07,02) + "/" + ;
                                    Substr(T_PRECOS->SAIDA,05,02) + "/" + ;
                                    Substr(T_PRECOS->SAIDA,01,04))
            Endif

            If EMPTY(ULTIMA_SAIDA) .And. EMPTY(ULTIMA_ENTRADA)
               nCor := '8'
            Else   
               If !EMPTY(ULTIMA_SAIDA)
                  If ULTIMA_SAIDA < (Date() - nDias)
                     nCor := '8'
                  Endif
               Else
                  If !EMPTY(ULTIMA_ENTRADA)
                     If ULTIMA_ENTRADA < (Date() - nDias)
                        nCor := '8'
                     Endif
                  Endif
               Endif
            Endif
         Endif

         If T_PRECOS->DA1_PROMO == "L"
            nCor := '4'
         Endif

         // Pesquisa o custo standart do cadastro de produtos
         If T_PRECOS->DA1_CUSTD == 0
            cStandart := T_PRECOS->B1_CUSTD
         Else
            cStandart := T_PRECOS->DA1_CUSTD
         Endif

         // Calcula a Margem conforme o tipo de registro
         If T_PRECOS->DA1_TREG == "I"
            cCusto_Usado := cStandart
         Endif
            
         If T_PRECOS->DA1_TREG == "E"
            cCusto_Usado := T_PRECOS->CUSTO
         Endif

         If T_PRECOS->DA1_TREG == "M"
            cCusto_Usado := T_PRECOS->CUSTO
         Endif

         If T_PRECOS->DA1_TREG == " "
            cCusto_Usado := 0
         Endif

         If T_PRECOS->DA1_MOEDA == 1
            If T_PRECOS->CUSTO = 0
               cMargemBruta := 0
            Else
               cMargemBruta := ROUND((T_PRECOS->DA1_PRCVEN / cCusto_Usado - 1) * 100,2)
            Endif
         Else
            If T_PRECOS->CUSTO = 0
               cMargemBruta := 0
            Else

               xCusto := IIF(T_PRECOS->DA1_MCUST == 1, cCusto_Usado, (cCusto_Usado * T_PRECOS->TAXA))
               cMargemBruta := ROUND((((T_PRECOS->DA1_PRCVEN * T_PRECOS->TAXA) / xCusto) - 1) * 100,2)

            Endif
         Endif
            
         // Carrega o array aLista
         aAdd( aLista, { nCor                               ,;
                         Alltrim(T_PRECOS->DA1_ITEM)        ,;
                         Substr(T_PRECOS->DA1_CODPRO,01,06) ,;
                         Alltrim(T_PRECOS->B1_GRUPO)        ,;
                         Alltrim(T_PRECOS->PRODUTO)         ,;
                         Alltrim(T_PRECOS->B1_PARNUM)       ,;
                         T_PRECOS->DA1_MOEDA  ,;
                         T_PRECOS->DA1_PRCVEN ,;
                         T_PRECOS->CONVERTIDO ,;
                         T_PRECOS->DA1_FATOR  ,;
                         T_PRECOS->CUSTO      ,;
                         cStandart            ,;
                         T_PRECOS->DA1_MCUST  ,;
                         cMargemBruta         ,;
                         T_PRECOS->DA1_PERDES ,;
                         T_PRECOS->DA1_PROMO  ,;
                         T_PRECOS->DA1_TREG   ,;
                         Substr(T_PRECOS->DA1_DIMPO,07,02) + "/" + Substr(T_PRECOS->DA1_DIMPO,05,02) + "/" + Substr(T_PRECOS->DA1_DIMPO,01,04)})

//       T_PRECOS->DA1_CUSTD  ,;
//       T_PRECOS->MARGEM     ,;

         nRegistros += 1

         T_PRECOS->( DbSkip() )
         
      ENDDO

   Endif

   cTotal := nRegistros

   If _Tipo == 0
      Return(.T.)
   Endif

   // Seta vetor para a browse                            
   oLista:SetArray(aLista) 
    
   // Monta a linha a ser exibina no Browse
   oLista:bLine := {||{ If(aLista[oLista:nAt,01] == "1", oBranco   ,;
                        If(aLista[oLista:nAt,01] == "2", oVerde    ,;
                        If(aLista[oLista:nAt,01] == "3", oPink     ,;                         
                        If(aLista[oLista:nAt,01] == "4", oAmarelo  ,;                         
                        If(aLista[oLista:nAt,01] == "5", oAzul     ,;                         
                        If(aLista[oLista:nAt,01] == "6", oLaranja  ,;                         
                        If(aLista[oLista:nAt,01] == "7", oPreto    ,;                         
                        If(aLista[oLista:nAt,01] == "8", oVermelho ,;
                        If(aLista[oLista:nAt,01] == "9", oEncerra, ""))))))))),;                         
                        aLista[oLista:nAt,02]            ,;
                        aLista[oLista:nAt,03]            ,;
                        aLista[oLista:nAt,04]            ,;
                        aLista[oLista:nAt,05]            ,;
                        aLista[oLista:nAt,06]            ,;
                        aLista[oLista:nAt,07]            ,;
                        aLista[oLista:nAt,08]            ,;                                                                                                    
                        aLista[oLista:nAt,09]            ,;                                                                                                    
                        aLista[oLista:nAt,10]            ,;                                                                                                    
                        aLista[oLista:nAt,11]            ,;                                                                                                    
                        aLista[oLista:nAt,12]            ,;
                        aLista[oLista:nAt,13]            ,;
                        aLista[oLista:nAt,14]            ,;
                        aLista[oLista:nAt,15]            ,;
                        aLista[oLista:nAt,16]            ,;
                        aLista[oLista:nAt,17]            ,;
                        aLista[oLista:nAt,18]            }}
Return(.T.)

// Função que permite manipular a lista de preço selecionada
Static Function Edita_Lista(_Operacao, _Codigo, _Item, _CodProduto)

   Local cSql    := ""
   Local ncontar := 0
   Local lChumba := .F.
   Local lAbre   := .F.

   Private aDA1_ATIVO  := {"1 - Sim"      , "2 - Não"}
   Private aDA1_TPOPER := {"1 - Estadual" , "2 - InterEstadual", "3 - Norte/Nordeste", "4 - Todos"}
   Private aDA1_TREG   := {" ", "I - Importado", "E - Atualizado a partir Custo Estoque", "M - Alterado Manualmente"}
   Private aDA1_PROMO  := {" ", "P - Promoção" , "L - Liquidação"}
   Private aDA1_ESTADO := {}

   Private cDA1_ATIVO
   Private cDA1_PROMO
   Private cDA1_TPOPER
   Private cDA1_ESTADO
   Private cDA1_TREG

   Private cDA1_FATOR  := 0
   Private cDA1_ITEM   := Space(04)
   Private cDA1_CODPRO := Space(30)
   Private cDA1_DESCRI := Space(60)
   Private cDA1_GRUPO  := Space(04)
   Private cNOMEGRUPO  := Space(40)
   Private cDA1_PRCVEN := 0
   Private cDA1_VLRDES := 0
   Private cDA1_PERDES := 0
   Private cDA1_QTDLOT := 99999.99
   Private cDA1_MOEDA  := 0
   Private cDA1_DATVIG := Ctod("  /  /    ")
   Private cDA1_DIMPO  := Ctod("  /  /    ")
   Private cDA1_PRCMAX := 0
   Private cDescricao1 := Space(30)
   Private cDescricao2 := Space(30)
   Private cCMEDIO     := 0
   Private cDA1_CUSTD  := 0
   Private cDA1_MCUST  := 0

   Private cMemo1	 := ""
   Private cMemo2	 := ""
   Private cMemo3	 := ""
   Private cMemo4	 := ""
   Private cMemo5	 := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet16
   Private oGet17
   Private oGet18
   Private oGet19      
   Private oGet20         

   Private oMemo1
   Private oMemo2
   Private oMemo3   
   Private oMemo4   
   Private oMemo5   

   Private oDlgD

   Private aDA1_ESTADO := { "                        " ,;
                            "AC - ACRE               " ,;
                            "AL - ALAGOAS            " ,;
                            "AM - AMAZONAS           " ,;
                            "AP - AMAPA              " ,;
                            "BA - BAHIA              " ,;
                            "CE - CEARA              " ,;
                            "DF - DISTRITO FEDERAL   " ,;
                            "ES - ESPIRITO SANTO     " ,;
                            "GO - GOIAS              " ,;
                            "MA - MARANHAO           " ,;
                            "MG - MINAS GERAIS       " ,;
                            "MS - MATO GROSSO DO SUL " ,;
                            "MT - MATO GROSSO        " ,;
                            "PA - PARA               " ,;
                            "PB - PARAIBA            " ,;
                            "PE - PERNAMBUCO         " ,;
                            "PI - PIAUI              " ,;
                            "PR - PARANA             " ,;
                            "RJ - RIO DE JANEIRO     " ,;
                            "RN - RIO GRANDE DO NORTE" ,;
                            "RO - RONDONIA           " ,;
                            "RR - RORAIMA            " ,;
                            "RS - RIO GRANDE DO SUL  " ,;
                            "SC - SANTA CATARINA     " ,;
                            "SE - SERGIPE            " ,;
                            "SP - SAO PAULO          " ,;
                            "TO - TOCANTINS          " }

   // Prepara os campos para edição conforme a operação selecionada
   If _Operacao == "I"

      lAbre       := .T.
      cDA1_ATIVO  := "1 - Sim"
      cDA1_TPOPER := "4 - Todos"
      cDA1_DIMPO  := Date()
      cDA1_PROMO  := " "
      cDA1_ESTADO := " "
      cDA1_TREG   := " "
      
   Else

      lAbre := .F.

      If Select("T_DETALHE") > 0
         T_DETALHE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DA1.DA1_ITEM  ,"
      cSql += "       DA1.DA1_CODTAB,"
      cSql += "       DA1.DA1_CODPRO,"
      cSql += "       LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX) AS DESCRICAO,"
      cSql += "       SB1.B1_CUSTD  ,"
      cSql += "       DA1.DA1_GRUPO ,"
      cSql += "       DA1.DA1_PRCVEN,"
      cSql += "       DA1.DA1_VLRDES,"
      cSql += "       DA1.DA1_PERDES,"
      cSql += "       DA1.DA1_PROMO ,"
      cSql += "       DA1.DA1_ATIVO ,"
      cSql += "       DA1.DA1_ESTADO,"
      cSql += "       DA1.DA1_TPOPER,"
      cSql += "       DA1.DA1_QTDLOT,"
      cSql += "       DA1.DA1_MOEDA ,"
      cSql += "       DA1.DA1_DATVIG,"
      cSql += "       DA1.DA1_PRCMAX,"
      cSql += "       DA1.DA1_TREG  ,"
      cSql += "       DA1.DA1_FATOR ,"
      cSql += "       DA1.DA1_DIMPO ,"
      cSql += "       DA1.DA1_CUSTD ,"
      cSql += "       DA1.DA1_MCUST  "
      cSql += "  FROM " + RetSqlName("DA1") + " DA1, "
      cSql += "       " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE DA1.DA1_CODTAB = '" + Alltrim(_Codigo)     + "'"
      cSql += "   AND DA1.DA1_ITEM   = '" + Alltrim(_Item)       + "'"
      cSql += "   AND DA1.DA1_CODPRO = '" + Alltrim(_CodProduto) + "'"
      cSql += "   AND DA1.D_E_L_E_T_ = '' "
      cSql += "   AND DA1.DA1_CODPRO = SB1.B1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = '' "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

      cDA1_ITEM	  := T_DETALHE->DA1_ITEM
      cDA1_CODPRO := T_DETALHE->DA1_CODPRO
      cDA1_DESCRI := T_DETALHE->DESCRICAO
      cDA1_GRUPO  := T_DETALHE->DA1_GRUPO

      // Pesquisa o nome do grupo do produto
      If Select("T_GRUPO") > 0
         T_GRUPO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT BM_DESC"
      cSql += "  FROM " + RetSqlName("SBM")
      cSql += " WHERE BM_GRUPO   = '" + Alltrim(T_DETALHE->DA1_GRUPO) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

      If T_GRUPO->( EOF() )
         cNOMEGRUPO := ""
      Else
         cNOMEGRUPO := T_GRUPO->BM_DESC
      Endif

      cDA1_PRCVEN := T_DETALHE->DA1_PRCVEN
      cDA1_VLRDES := T_DETALHE->DA1_VLRDES
      cDA1_PERDES := T_DETALHE->DA1_PERDES
      cDA1_PROMO  := T_DETALHE->DA1_PROMO
      cDA1_ESTADO := T_DETALHE->DA1_ESTADO
      cNOMEESTADO := ""
      cDA1_QTDLOT := T_DETALHE->DA1_QTDLOT
      cDA1_MOEDA  := T_DETALHE->DA1_MOEDA
      cDA1_DATVIG := Ctod(Substr(T_DETALHE->DA1_DATVIG,07,02) + "/" + Substr(T_DETALHE->DA1_DATVIG,05,02) + "/" + Substr(T_DETALHE->DA1_DATVIG,01,04))
      cDA1_PRCMAX := T_DETALHE->DA1_PRCMAX
      cDA1_FATOR  := T_DETALHE->DA1_FATOR
      cDA1_DIMPO  := Ctod(Substr(T_DETALHE->DA1_DIMPO,07,02) + "/" + Substr(T_DETALHE->DA1_DIMPO,05,02) + "/" + Substr(T_DETALHE->DA1_DIMPO,01,04))
      cDA1_CUSTD  := T_DETALHE->DA1_CUSTD
      cDA1_MCUST  := T_DETALHE->DA1_MCUST

      // Carrega o Custo Standart
      If cDA1_CUSTD == 0
         If T_DETALHE->B1_CUSTD <> 0
            cDA1_CUSTD := T_DETALHE->B1_CUSTD
         Endif
      Endif

      // Pesquisa o Custo Médio do produto
      If Select("T_CMEDIO") > 0
         T_CMEDIO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql += "SELECT B2_CM1 "
      cSql += "  FROM " + RetSqlName("SB2")
      cSql += " WHERE B2_FILIAL  = '01'"
      cSql += "   AND B2_LOCAL   = '01'"
      cSql += "   AND B2_COD     = '" + Alltrim(T_DETALHE->DA1_CODPRO) + "'"
      cSql += "	  AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CMEDIO", .T., .T. )

      If T_CMEDIO->( EOF() )
         cCMEDIO := 0
      Else
         cCMEDIO := T_CMEDIO->B2_CM1
      Endif

      // Posiciona no Combo de Tipo de Operação
      For nContar = 1 to Len(aDA1_TPOPER)
          If Substr(aDA1_TPOPER[nContar],01,01) == T_DETALHE->DA1_TPOPER
             cDA1_TPOPER := nContar 
             Exit
          Endif
      Next nContar        

      // Posiciona o Combo de Ativo
      For nContar = 1 to Len(aDA1_ATIVO)
          If Substr(aDA1_ATIVO[nContar],01,01) == T_DETALHE->DA1_ATIVO
             cDA1_ATIVO := nContar 
             Exit
          Endif
      Next nContar        

      // Posiciona o Combo dos Estados
      For nContar = 1 to Len(aDA1_ESTADO)
          If Substr(aDA1_ESTADO[nContar],01,02) == Alltrim(T_DETALHE->DA1_ESTADO)
             cDA1_ESTADO := aDA1_ESTADO[nContar]  
             Exit
          Endif
      Next nContar        

      // Posiciona o Tipo de Registro
      For nContar = 1 to Len(aDA1_TREG)
          If Substr(aDA1_TREG[nContar],01,01) == Alltrim(T_DETALHE->DA1_TREG)
             cDA1_TREG := aDA1_TREG[nContar]  
             Exit
          Endif
      Next nContar        

      // Posiciona o OPromoTipo
      For nContar = 1 to Len(aDA1_PROMO)
          If Substr(aDA1_PROMO[nContar],01,01) == Alltrim(T_DETALHE->DA1_PROMO)
             cDA1_PROMO := aDA1_PROMO[nContar]  
             Exit
          Endif
      Next nContar        

   Endif

   DEFINE MSDIALOG oDlgD TITLE "Manutenção Lista de Preço" FROM C(178),C(181) TO C(587),C(656) PIXEL

   @ C(005),C(005) Say "Item"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(005),C(028) Say "Código"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(005),C(074) Say "Descrição do Produto" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(005) Say "Preço Venda"          Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(074) Say "Moeda"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(104) Say "PromoTipo"            Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(197) Say "Ativo"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(055),C(043) Say "Fator"                Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(055),C(092) Say "Tipo Registro"        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(086),C(005) Say "Custo Médio"          Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(086),C(092) Say "Custo Standart"       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(086),C(186) Say "Moeda"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(115),C(005) Say "Vlr Desconto"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(115),C(062) Say "Fator"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(115),C(112) Say "Faixa"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(115),C(168) Say "Preço Máximo"         Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(136),C(005) Say "Estado"               Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(136),C(091) Say "Vigência"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(136),C(156) Say "Tipo de Operação"     Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(168),C(078) Say "Data Alteração"       Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgD

   @ C(052),C(005) GET oMemo1 Var cMemo1 MEMO Size C(227),C(001) PIXEL OF oDlgD
   @ C(160),C(005) GET oMemo2 Var cMemo2 MEMO Size C(227),C(001) PIXEL OF oDlgD
   @ C(080),C(005) GET oMemo3 Var cMemo3 MEMO Size C(227),C(001) PIXEL OF oDlgD
   @ C(109),C(005) GET oMemo4 Var cMemo4 MEMO Size C(227),C(001) PIXEL OF oDlgD
   @ C(182),C(005) GET oMemo5 Var cMemo5 MEMO Size C(227),C(001) PIXEL OF oDlgD

   If _Operacao == "E"
      @ C(014),C(005) MsGet    oGet1       Var   cDA1_ITEM   When lChumba Size C(017),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlgD
      @ C(014),C(028) MsGet    oGet2       Var   cDA1_CODPRO When lChumba Size C(040),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlgD
      @ C(014),C(074) MsGet    oGet3       Var   cDA1_DESCRI When lChumba Size C(158),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlgD
      @ C(036),C(005) MsGet    oGet6       Var   cDA1_PRCVEN When lChumba Size C(063),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"       PIXEL OF oDlgD
      @ C(036),C(074) MsGet    oGet13      Var   cDA1_MOEDA  When lChumba Size C(013),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlgD
      @ C(036),C(104) ComboBox cDA1_PROMO  Items aDA1_PROMO  When lChumba Size C(080),C(010)                                              PIXEL OF oDlgD
      @ C(036),C(197) ComboBox cDA1_ATIVO  Items aDA1_ATIVO  When lChumba Size C(035),C(010)                                              PIXEL OF oDlgD
      @ C(064),C(043) MsGet    oGet16      Var   cDA1_FATOR  When lChumba Size C(028),C(009) COLOR CLR_BLACK Picture "@E 999.99"          PIXEL OF oDlgD
      @ C(064),C(092) ComboBox cDA1_TREG   Items aDA1_TREG   When lChumba Size C(110),C(010)                                              PIXEL OF oDlgD
      @ C(095),C(005) MsGet    oGet17      Var   cCMEDIO     When lChumba Size C(063),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"       PIXEL OF oDlgD
      @ C(095),C(092) MsGet    oGet18      Var   cDA1_CUSTD  When lChumba Size C(063),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"       PIXEL OF oDlgD
      @ C(095),C(186) MsGet    oGet19      Var   cDA1_MCUST  When lChumba Size C(013),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlgD
      @ C(124),C(005) MsGet    oGet7       Var   cDA1_VLRDES When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"      PIXEL OF oDlgD
      @ C(124),C(062) MsGet    oGet8       Var   cDA1_PERDES When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9.9999"         PIXEL OF oDlgD
      @ C(124),C(112) MsGet    oGet12      Var   cDA1_QTDLOT When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"     PIXEL OF oDlgD
      @ C(124),C(168) MsGet    oGet15      Var   cDA1_PRCMAX When lChumba Size C(063),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgD
      @ C(145),C(005) ComboBox cDA1_ESTADO Items aDA1_ESTADO When lChumba Size C(062),C(010)                                             PIXEL OF oDlgD
      @ C(145),C(091) MsGet    oGet14      Var   cDA1_DATVIG When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
      @ C(145),C(156) ComboBox cDA1_TPOPER Items aDA1_TPOPER When lChumba Size C(077),C(010)                                             PIXEL OF oDlgD
      @ C(167),C(117) MsGet    oGet20      Var   cDA1_DIMPO  When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
   Else
      @ C(014),C(005) MsGet    oGet1       Var   cDA1_ITEM   When lChumba Size C(017),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
      @ C(014),C(028) MsGet    oGet2       Var   cDA1_CODPRO When lAbre   Size C(040),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD F3("SB1") VALID( BuscaProdu( cDA1_CODPRO, _Codigo) )
      @ C(014),C(074) MsGet    oGet3       Var   cDA1_DESCRI When lChumba Size C(158),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
      @ C(036),C(005) MsGet    oGet6       Var   cDA1_PRCVEN              Size C(063),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"      PIXEL OF oDlgD
      @ C(036),C(074) MsGet    oGet13      Var   cDA1_MOEDA               Size C(013),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
      @ C(036),C(104) ComboBox cDA1_PROMO  Items aDA1_PROMO               Size C(080),C(010)                                             PIXEL OF oDlgD
      @ C(036),C(197) ComboBox cDA1_ATIVO  Items aDA1_ATIVO               Size C(035),C(010)                                             PIXEL OF oDlgD
      @ C(064),C(043) MsGet    oGet16      Var   cDA1_FATOR               Size C(028),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgD
      @ C(064),C(092) ComboBox cDA1_TREG   Items aDA1_TREG                Size C(110),C(010)                                             PIXEL OF oDlgD
      @ C(095),C(005) MsGet    oGet17      Var   cCMEDIO     When lChumba Size C(063),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"      PIXEL OF oDlgD
      @ C(095),C(092) MsGet    oGet18      Var   cDA1_CUSTD               Size C(063),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"      PIXEL OF oDlgD
      @ C(095),C(186) MsGet    oGet19      Var   cDA1_MCUST               Size C(013),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
      @ C(124),C(005) MsGet    oGet7       Var   cDA1_VLRDES              Size C(044),C(009) COLOR CLR_BLACK Picture "@E 99,999.99"      PIXEL OF oDlgD
      @ C(124),C(062) MsGet    oGet8       Var   cDA1_PERDES              Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9.9999"         PIXEL OF oDlgD
      @ C(124),C(112) MsGet    oGet12      Var   cDA1_QTDLOT              Size C(044),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"     PIXEL OF oDlgD
      @ C(124),C(168) MsGet    oGet15      Var   cDA1_PRCMAX              Size C(063),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgD
      @ C(145),C(005) ComboBox cDA1_ESTADO Items aDA1_ESTADO              Size C(062),C(010)                                             PIXEL OF oDlgD
      @ C(145),C(091) MsGet    oGet14      Var   cDA1_DATVIG              Size C(043),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
      @ C(145),C(156) ComboBox cDA1_TPOPER Items aDA1_TPOPER              Size C(077),C(010)                                             PIXEL OF oDlgD
      @ C(167),C(117) MsGet    oGet20      Var   cDA1_DIMPO               Size C(037),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgD
   Endif
 
   If _Operacao == "E"
      @ C(188),C(080) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgD ACTION( SalvaLista(_Operacao, _Codigo, _Item, _CodProduto) )
   Else
      @ C(188),C(080) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlgD ACTION( SalvaLista(_Operacao, _Codigo, _Item, _CodProduto) )
   Endif
            
   @ C(188),C(119) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End()  )

   ACTIVATE MSDIALOG oDlgD CENTERED 

Return(.T.)

// Função que pesquisa o grupo informado
Static Function BuscaGrupo(_Grupo)

   Local cSql := ""
   
   If Empty(Alltrim(_Grupo))
      cDA1_GRUPO := Space(04)
      cNOMEGRUPO := ""
      Return(.T.)
   Endif

   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_DESC"
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE BM_GRUPO   = '" + Alltrim(_Grupo) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   If T_GRUPO->( EOF() )
      cDA1_GRUPO := Space(04)
      cNOMEGRUPO := ""
   Else
      cNOMEGRUPO := T_GRUPO->BM_DESC
   Endif
      
Return(.T.)

// Função que pesquisa o produto informado
Static Function BuscaProdu(_Produto, _Codigo)

   Local cSql := ""
   
   If Empty(Alltrim(_Produto))
      cDA1_CODPRO := Space(30)
      cDA1_DESCRI := Space(60)
      cDescricao1 := Space(30)
      cDescricao2 := Space(30)
      Return(.T.)
   Endif

   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_DESC,"
   cSql += "       B1_DAUX "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD = '" + Alltrim(_Produto) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If T_PRODUTO->( EOF() )
      cDA1_CODPRO := Space(30)
      cDA1_DESCRI := Space(60)
      cDescricao1 := Space(30)
      cDescricao2 := Space(30)
   Else

      // Verifica se produto pesquisado já pertence a lista de preço selecionada
      If Select("T_JAEXISTE") > 0
         T_JAEXISTE->( dbCloseArea() )
      EndIf

      cSql := "SELECT DA1_CODTAB,"
      cSql += "       DA1_ITEM  ,"
      cSql += "       DA1_CODPRO "
      cSql += "  FROM " + RetSqlName("DA1")
      cSql += " WHERE DA1_CODTAB = '" + Alltrim(_Codigo)  + "'"
      cSql += "   AND DA1_CODPRO = '" + Alltrim(_Produto) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

      If !T_JAEXISTE->( EOF() )
         MsgAlert("Atenção!" + chr(13) + chr(13) + "Produto informado já consta nesta lista de preço." + chr(13) + "Item: " + Alltrim(T_JAEXISTE->DA1_ITEM))
         cDA1_CODPRO := Space(30)
         cDA1_DESCRI := Space(60)
         cDescricao1 := Space(30)
         cDescricao2 := Space(30)
      Else
         cDA1_DESCRI := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
         cDescricao1 := Alltrim(T_PRODUTO->B1_DESC) 
         cDescricao2 := Alltrim(T_PRODUTO->B1_DAUX)
      Endif
   Endif

   If !Empty(Alltrim(cDA1_CODPRO))
      If Select("T_CMEDIO") > 0
         T_CMEDIO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql += "SELECT B2_CM1 "
      cSql += "  FROM " + RetSqlName("SB2")
      cSql += " WHERE B2_FILIAL  = '01'"
      cSql += "   AND B2_LOCAL   = '01'"
      cSql += "   AND B2_COD     = '" + Alltrim(_Produto) + "'"
      cSql += "	  AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CMEDIO", .T., .T. )

      If T_CMEDIO->( EOF() )
         cCMEDIO := 0
      Else
         cCMEDIO := T_CMEDIO->B2_CM1
      Endif
   Endif
      
Return(.T.)

// Função que salva os dados da tela
Static Function SalvaLista(_Operacao, _Codigo, _Item, _CodProduto)

   Local cSql   := ""
   Local _nErro := 0

   If Empty(Alltrim(cDA1_CODPRO))
      MsgAlert("Produto não informado.")
      Return(.T.)
   Endif
      
   If _Operacao <> "E"
      If cDA1_DIMPO == Ctod("  /  /    ")
         MsgAlert("Data de alteração não informada.")
         Return(.T.)
      Endif
   Endif

   // I N C L U S Ã O
   If _Operacao == "I"

      If Empty(Alltrim(cDA1_CODPRO))
         MsgAlert("Código do produto não informado.")
         Return(.T.)
      Endif   

      // Pesquisa o Próximo código de Item a ser utilizado para a inclusão
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DA1_ITEM "
      cSql += "  FROM " + RetSqlName("DA1")
      cSql += " WHERE DA1_CODTAB = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY DA1_ITEM DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

      If T_NOVO->( EOF() )
         cCodItem := '0001'
      Else
         cCodItem := Strzero((INT(VAL(T_NOVO->DA1_ITEM)) + 1),4)      
      Endif

      // Inseri os dados na Tabela
      dbSelectArea("DA1")
      RecLock("DA1",.T.)
      DA1->DA1_FILIAL := "  "
      DA1->DA1_ITEM   := cCodItem
      DA1->DA1_CODPRO := cDA1_CODPRO
      DA1->DA1_CODTAB := _Codigo
//    DA1->DA1_GRUPO  := cDA1_GRUPO
      DA1->DA1_PRCVEN := cDA1_PRCVEN
      DA1->DA1_VLRDES := cDA1_VLRDES
      DA1->DA1_PERDES := cDA1_PERDES
      DA1->DA1_PROMO  := Substr(cDA1_PROMO,01,01)

      If cDA1_ESTADO = Nil
      Else
         DA1->DA1_ESTADO := Substr(cDA1_ESTADO,01,02)
      Endif
        
      If cDA1_TREG = Nil
      Else
         DA1->DA1_TREG   := Substr(cDA1_TREG,01,01)
      Endif
         
      DA1->DA1_FATOR  := cDA1_FATOR
      DA1->DA1_QTDLOT := 999999.99
      DA1->DA1_INDLOT := "000000000999999.99"
      DA1->DA1_MOEDA  := cDA1_MOEDA
//    DA1->DA1_DATVIG := cDA1_DATVIG
      DA1->DA1_PRCMAX := cDA1_PRCMAX
      DA1->DA1_ATIVO  := Substr(cDA1_ATIVO,01,01)
      DA1->DA1_TPOPER := Substr(cDA1_TPOPER,01,01)
      DA1->DA1_DIMPO  := cDA1_DIMPO
      DA1->DA1_CUSTD  := cDA1_CUSTD
      DA1->DA1_MCUST  := cDA1_MCUST

      MsUnLock()
   Endif
   
   // A L T E R A Ç Ã O
   If _Operacao == "A"
   
      // Posiciona no registro para atualização
      DbSelectArea( "DA1" )
      DbSetOrder(2)
      If DbSeek( xFilial("DA1") + STRZERO(INT(VAL(_CodProduto)),6) + SPACE(24) + _Codigo + _Item )
         RecLock("DA1",.F.)
//       DA1->DA1_GRUPO  := cDA1_GRUPO
         DA1->DA1_PRCVEN := cDA1_PRCVEN
         DA1->DA1_VLRDES := cDA1_VLRDES
         DA1->DA1_PERDES := cDA1_PERDES
         DA1->DA1_PROMO  := Substr(cDA1_PROMO,01,01)

         If cDA1_ESTADO = Nil
         Else
            DA1->DA1_ESTADO := Substr(cDA1_ESTADO,01,02)
         Endif

         If cDA1_TREG = Nil
         Else
            DA1->DA1_TREG   := Substr(cDA1_TREG,01,01)
         Endif

         DA1->DA1_FATOR  := cDA1_FATOR
         DA1->DA1_QTDLOT := 999999.99
         DA1->DA1_INDLOT := "000000000999999.99"
         DA1->DA1_MOEDA  := cDA1_MOEDA
         DA1->DA1_DATVIG := cDA1_DATVIG
         DA1->DA1_PRCMAX := cDA1_PRCMAX
         DA1->DA1_ATIVO  := Alltrim(Str(cDA1_ATIVO))
         DA1->DA1_TPOPER := Alltrim(Str(cDA1_TPOPER))
         DA1->DA1_DIMPO  := cDA1_DIMPO
         DA1->DA1_CUSTD  := cDA1_CUSTD
         DA1->DA1_MCUST  := cDA1_MCUST
         
         MsUnLock()              
      Endif
   Endif

   // E X C L U S Ã O
   If _Operacao == "E"

      cSql := ""
      cSql := "DELETE FROM " + RetSqlName("DA1")
      cSql += " WHERE DA1_FILIAL = '" + Alltrim(xFilial("DA1")) + "'"
      cSql += "   AND DA1_CODPRO = '" + Alltrim(STRZERO(INT(VAL(_CodProduto)),6) + SPACE(24)) + "'"
      cSql += "   AND DA1_CODTAB = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND DA1_ITEM   = '" + Alltrim(_Item)   + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
      Endif

   Endif

   oDlgD:End()
   
   Pesquisa_Filtro(_Codigo,1)
         
Return(.T.)

// Função que apresenta a janela de legendas de pesquisa de produtos
Static Function xLegendaPq()

   Local cSql  := ""
   Local nDias := 0

   Private oDlgL

   // Pesquisa o Parâmetro de Dias para Leganda Vermelha
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_DIAS" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      nDias := 999
   Else   
      nDias := T_PARAMETROS->ZZ4_DIAS
   Endif

   DEFINE MSDIALOG oDlgLG TITLE "Legenda Pesquisa" FROM C(178),C(181) TO C(341),C(711) PIXEL

   @ C(005),C(018) Say "Outros"                                                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(017),C(018) Say "Produtos com estoque em toda a Companhia"                         Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(028),C(018) Say "Produtos com estoque em toda a Companhia e que estão em PROMOÇÂO" Size C(177),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(041),C(018) Say "Tem estoque disponivel para venda na Companhia e que não tem giro de estoque na Matriz a mais de " + Alltrim(Str(nDias)) + " dias." Size C(240),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(053),C(018) Say "Produtos em Liquidação"                                           Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
      
   @ C(003),C(003) Jpeg FILE "br_branco"   Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(015),C(003) Jpeg FILE "br_verde"    Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(027),C(003) Jpeg FILE "br_azul"     Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(039),C(003) Jpeg FILE "br_vermelho" Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(051),C(003) Jpeg FILE "br_amarelo"  Size C(010),C(011) PIXEL NOBORDER OF oDlgLG

   @ C(064),C(116) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLG ACTION( oDlgLG:End() )

   ACTIVATE MSDIALOG oDlgLG CENTERED 

Return(.T.)

// Função que apresenta os produtos com saldos que não estão presentes em nenhuma lista de preços
Static Function ConSaldos(_Tabela)

   Private cTotProd := 0
   Private cGrupo01 := Space(04)
   Private cNgrupo1 := Space(40)
   Private cGrupo02 := Space(04)
   Private cNgrupo2 := Space(40)
   Private lChumba  := .F.

   Private oGet1                                                                       
   Private oGet2 
   Private oGet3 
   Private oGet4 
   Private oGet5 

   Private oDlgC

   Private aSaldos := {}

   If Select("T_SEMLISTA") > 0
      T_SEMLISTA->( dbCloseArea() )
   EndIf

   cSql := "SELECT SB2.B2_COD ,"
   cSql += "       LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX) AS DESCRICAO ,"
   cSql += "       SUM(SB2.B2_QATU) AS SALDO"
   cSql += "  FROM " + RetSqlName("SB2") + " SB2, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SB2.D_E_L_E_T_ = '' "
   cSql += "   AND SB2.B2_COD     = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_GRUPO  < '0200'"
   cSql += "   AND SB1.B1_MSBLQL <> '1'"
   cSql += "   AND SB2.B2_QATU   <> 0"
   cSql += "   AND SB2.B2_COD NOT IN (SELECT DA1_CODPRO FROM DA1010 WHERE DA1_CODPRO = SB2.B2_COD AND D_E_L_E_T_ = '' AND DA1_CODTAB = '" + Alltrim(_Tabela) + "')"
   cSql += " GROUP BY SB2.B2_COD, LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX)"
   cSql += " ORDER BY LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX)"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEMLISTA", .T., .T. )

   cTotProd := 0

   If T_SEMLISTA->( EOF() )
      aAdd( aSaldos, { "", "", "" } )
   Else
   
      T_SEMLISTA->( DbGoTop() )
      
      WHILE !T_SEMLISTA->( EOF() )
         aAdd( aSaldos, { T_SEMLISTA->B2_COD, T_SEMLISTA->DESCRICAO, T_SEMLISTA->SALDO } )
         cTotProd := cTotProd + 1
         T_SEMLISTA->( DbSkip() )
      ENDDO   
   Endif

   DEFINE MSDIALOG oDlgC TITLE "Consulta Saldos Fora da Lista de Preço" FROM C(178),C(181) TO C(559),C(906) PIXEL

   @ C(170),C(005) Say "Total de Produtos" Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(165),C(082) Say "Grupo Inicial"     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(177),C(082) Say "Grupo Final"       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
         
   @ C(169),C(051) MsGet oGet1 Var cTotProd When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(164),C(116) MsGet oGet2 Var cGrupo01              Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("SBM") VALID( BscGrupo( cGrupo01, 1) )
   @ C(164),C(147) MsGet oGet3 Var cNgrupo1 When lChumba Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(176),C(116) MsGet oGet4 Var cGrupo02              Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("SBM") VALID( BscGrupo( cGrupo02, 2) )
   @ C(176),C(147) MsGet oGet5 Var cNgrupo2 When lChumba Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC

   @ C(162),C(303) Button "Pesquisar" Size C(047),C(012) PIXEL OF oDlgC ACTION( PsqSldLst( _Tabela, cGrupo01, cGrupo02 ) )
   @ C(176),C(303) Button "Voltar"    Size C(047),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() ) 

   oSaldos := TCBrowse():New( 005 , 005, 455, 200,,{'Código', 'Descrição dos Produtos', 'Saldo'},{20,50,50,50},oDlgC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oSaldos:SetArray(aSaldos) 
    
   // Monta a linha a ser exibina no Browse
   oSaldos:bLine := {||{ aSaldos[oSaldos:nAt,01],;
                         aSaldos[oSaldos:nAt,02],;
                         aSaldos[oSaldos:nAt,03]} }

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que pesquisa os grupos da tela de consulta saldo fora da lista
Static Function BscGrupo(_Grupo, _Tipo)

   Local cSql := ""
   
   If Empty(Alltrim(_Grupo))
      If _Tipo == 1
         cGrupo01 := Space(04)
         cNgrupo1 := Space(40)
      Else
         cGrupo02 := Space(04)
         cNgrupo2 := Space(40)
      Endif
      Return(.T.)
   Endif

   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_DESC"
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE BM_GRUPO   = '" + Alltrim(_Grupo) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   If T_GRUPO->( EOF() )
      If _Tipo == 1
         cGrupo01 := Space(04)
         cNgrupo1 := Space(40)
      Else
         cGrupo02 := Space(04)
         cNgrupo2 := Space(40)
      Endif
   Else
      If _Tipo == 1
         cNgrupo1 := T_GRUPO->BM_DESC
      Else
         cNgrupo2 := T_GRUPO->BM_DESC
      Endif
   Endif
      
Return(.T.)

// Função que pesquisa os produtos com saldo e que não estão na lista selecionada
Static Function PsqSldLst(_Tabela, _Grupo1, _Grupo2)

   If Select("T_SEMLISTA") > 0
      T_SEMLISTA->( dbCloseArea() )
   EndIf

   cSql := "SELECT SB2.B2_COD ,"
   cSql += "       LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX) AS DESCRICAO ,"
   cSql += "       SUM(SB2.B2_QATU) AS SALDO"
   cSql += "  FROM " + RetSqlName("SB2") + " SB2, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SB2.D_E_L_E_T_ = '' "
   cSql += "   AND SB2.B2_COD     = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
  
   Do Case
      case !Empty(Alltrim(_Grupo1)) .And. Empty(Alltrim(_Grupo2))
           cSql += "   AND SB1.B1_GRUPO  = '" + Alltrim(_Grupo1) + "'"
      case Empty(Alltrim(_Grupo1)) .And. !Empty(Alltrim(_Grupo2))
           cSql += "   AND SB1.B1_GRUPO  = '" + Alltrim(_Grupo2) + "'"
      case !Empty(Alltrim(_Grupo1)) .And. !Empty(Alltrim(_Grupo2))
           cSql += "   AND SB1.B1_GRUPO  >= '" + Alltrim(_Grupo1) + "'"
           cSql += "   AND SB1.B1_GRUPO  <= '" + Alltrim(_Grupo2) + "'"
   EndCase

   cSql += "   AND SB2.B2_QATU   <> 0"
   cSql += "   AND SB2.B2_COD NOT IN (SELECT DA1_CODPRO FROM DA1010 WHERE DA1_CODPRO = SB2.B2_COD AND D_E_L_E_T_ = '' AND DA1_CODTAB = '" + Alltrim(_Tabela) + "')"
   cSql += " GROUP BY SB2.B2_COD, LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX)"
   cSql += " ORDER BY LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX)"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEMLISTA", .T., .T. )

   cTotProd := 0

   aSaldos  := {}

   If T_SEMLISTA->( EOF() )
      aAdd( aSaldos, { "", "", "" } )
   Else
   
      T_SEMLISTA->( DbGoTop() )
      
      WHILE !T_SEMLISTA->( EOF() )
         aAdd( aSaldos, { T_SEMLISTA->B2_COD, T_SEMLISTA->DESCRICAO, T_SEMLISTA->SALDO } )
         cTotProd := cTotProd + 1
         T_SEMLISTA->( DbSkip() )
      ENDDO   
   Endif

   // Seta vetor para a browse                            
   oSaldos:SetArray(aSaldos) 
    
   // Monta a linha a ser exibina no Browse
   oSaldos:bLine := {||{ aSaldos[oSaldos:nAt,01],;
                         aSaldos[oSaldos:nAt,02],;
                         aSaldos[oSaldos:nAt,03]} }

Return(.T.)

// Função que limpa a data de alteração
Static Function LimpaData(_Codigo)

   If !MsgYesNo("Confirma a execução deste procedimento?")
      Return(.T.)
   Endif

   ConfLimpaData(_Codigo)

Return(.T.)

// Função Confirma limpeza de data de alteração
Static Function ConfLimpaData(_Codigo)

   Local cSlq   := ""
   Local _nErro := 0
         
   cSql := "UPDATE " + RetSqlName("DA1")
   cSql += "   SET "
   cSql += "   DA1_TREG  = ' ',"
   cSql += "   DA1_DIMPO = ''  "
   cSql += " WHERE  DA1_CODTAB = '" + Alltrim(_codigo) + "'"
   cSql += "   AND (DA1_TREG   = 'I' OR DA1_TREG = 'E')"
   cSql += "   AND D_E_L_E_T_  = ''"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
   else
      Msgalert("Limpeza efetuada com sucesso.")
   Endif

   Pesquisa_Filtro(_Codigo,1)
   
Return(.T.)

// Função que abre o programa de imortação da lista de preços
Static Function AbreImpPreco(_Codigo)

   U_AUTOM173()
             
   Pesquisa_Filtro(_Codigo,1)
   
Return(.T.)

// Função que Importa dados do Estoque conforme regra
// Regra de Importação do Estoque
// --------------------------------------------------
// Produto tem estoque
// Não foi importado (Se DA1_TREG = " "
// Custo médio * Fator da DA1
// Grava o preço de venda pelo cálculo
//
Static Function ImpEstoque(_Codigo)

   Local cSql       := ""
   
   Private oOk      := LoadBitmap( GetResources(), "LBOK" )
   Private oNo      := LoadBitmap( GetResources(), "LBNO" )
   Private aEstoque := {}
   Private oEstoque
   Private oDlgX

   If MsgYesNo("Confirma a Importação do Estoque?")
   Else
      Return(.T.)
   Endif
   
   // Pesquisa os produtos da lista de preço selecionada      
   If Select("T_ESTOQUE") > 0
      T_ESTOQUE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA1.DA1_ITEM  ,"                              + CHR(13)
   cSql += "       DA1.DA1_CODPRO,"                              + CHR(13)
   cSql += "       LTRIM(SB1.B1_DESC) + ' ' + LTRIM(SB1.B1_DAUX) AS PRODUTO," + CHR(13)
   cSql += "       DA1.DA1_CODTAB,"                              + CHR(13)
   cSql += "       DA1.DA1_TREG  ,"                              + CHR(13)
   cSql += "       DA1.DA1_DIMPO ,"                              + CHR(13)
   cSql += "       DA1.DA1_FATOR ,"                              + CHR(13)
   cSql += "       ISNULL((SELECT SUM(B2_QATU) "                 + CHR(13)
   cSql += "                 FROM " + RetSqlName("SB2")          + CHR(13)
   cSql += "                WHERE B2_COD     = DA1.DA1_CODPRO"   + CHR(13)
   cSql += "                  AND D_E_L_E_T_ = ''  "             + CHR(13)
   cSql += "                GROUP BY B2_COD),0.00) AS QTD,"      + CHR(13)
   cSql += "       ISNULL((SELECT B2_CM1"                        + CHR(13)
   cSql += "                 FROM " + RetSqlName("SB2")          + CHR(13)
   cSql += "                WHERE B2_COD     = DA1.DA1_CODPRO"   + CHR(13)
// cSql += "                  AND B2_QATU   <> 0   "             + CHR(13)
   cSql += "                  AND B2_LOCAL   = '01'"             + CHR(13)
   cSql += "                  AND B2_FILIAL  = '01'"             + CHR(13)
   cSql += "                  AND D_E_L_E_T_ = ''  "             + CHR(13)
   cSql += "                GROUP BY B2_CM1),0.00) AS CUSTO,"    + CHR(13)
   cSql += "       ROUND((DA1.DA1_FATOR * ISNULL((SELECT B2_CM1" + CHR(13)
   cSql += "                                        FROM " + RetSqlName("SB2")                + CHR(13)
   cSql += "                                        WHERE B2_COD     = DA1.DA1_CODPRO"        + CHR(13)
// cSql += "                                          AND B2_QATU   <> 0   "                  + CHR(13)
   cSql += "                                          AND B2_LOCAL   = '01'"                  + CHR(13)
   cSql += "                                          AND B2_FILIAL  = '01'"                  + CHR(13)
   cSql += "                                          AND D_E_L_E_T_ = ''  "                  + CHR(13)
   cSql += "                                        GROUP BY B2_CM1),0.00)),2) AS CUSTOFINAL" + CHR(13)
   cSql += "  FROM " + RetSqlName("DA1") + " DA1, "               + CHR(13)
   cSql += "       " + RetSqlName("SB1") + " SB1  "               + CHR(13)
   cSql += " WHERE (DA1.DA1_TREG   = ' ' OR DA1.DA1_TREG = 'E')"  + CHR(13)
   cSql += "   AND  DA1.DA1_CODTAB = '" + Alltrim(_Codigo) + "'"  + CHR(13)
   cSql += "   AND  DA1.D_E_L_E_T_ = ''"                          + CHR(13)
   cSql += "   AND  DA1.DA1_CODPRO = SB1.B1_COD"                  + CHR(13)
   cSql += "   AND  SB1.B1_MSBLQL <> '1'"                         + CHR(13)
   cSql += "   AND  SB1.D_E_L_E_T_ = '' "                         + CHR(13)
   cSql += "   AND (SELECT SUM(B2_QATU) "                         + CHR(13)
   cSql += "                 FROM " + RetSqlName("SB2")           + CHR(13)
   cSql += "                WHERE B2_COD     = DA1.DA1_CODPRO"    + CHR(13)
   cSql += "                  AND D_E_L_E_T_ = ''  "              + CHR(13)
   cSql += "                GROUP BY B2_COD) <> 0"                + CHR(13)
   cSql += " ORDER BY DA1.DA1_CODPRO"                             + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTOQUE", .T., .T. )

   If T_ESTOQUE->( EOF() )
      MsgAlert("Não existem produtos a serem importados para esta lista de preço.")
      Return(.T.)
   Endif

   T_ESTOQUE->( DbGoTop() )

   WHILE !T_ESTOQUE->( EOF() )
      aAdd( aEstoque, { .T.                           ,;
                        T_ESTOQUE->DA1_ITEM           ,;
                        ALLTRIM(T_ESTOQUE->DA1_CODPRO),;
                        ALLTRIM(T_ESTOQUE->PRODUTO)   ,;
                        T_ESTOQUE->QTD                ,;                        
                        T_ESTOQUE->CUSTO              ,;
                        T_ESTOQUE->DA1_FATOR          ,;
                        T_ESTOQUE->CUSTOFINAL})
      T_ESTOQUE->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgX TITLE "Importação de Estoque" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(005),C(005) Say "Relação de produtos importados" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"    Size C(055),C(012) PIXEL OF oDlgX ACTION( McTodos(1) )
   @ C(203),C(062) Button "Desmarca Todos" Size C(055),C(012) PIXEL OF oDlgX ACTION( McTodos(2) )
   @ C(203),C(280) Button "Confirmar"      Size C(037),C(012) PIXEL OF oDlgX ACTION( SlvAtuSqt(_Codigo) )
   @ C(203),C(319) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgX ACTION( FechaImpStq(_Codigo) )

   // Cria Componentes Padroes do Sistema
   @ 15,05 LISTBOX oEstoque FIELDS HEADER "", "Item", "Código" ,"Descrição dos Produtos", "Qtd Estoque", "Custo Médio", "Fator", "Preço de Venda" PIXEL SIZE 460,240 OF oDlgX ;
                            ON dblClick(aEstoque[oEstoque:nAt,1] := !aEstoque[oEstoque:nAt,1],oEstoque:Refresh())     
   oEstoque:SetArray( aEstoque )
   oEstoque:bLine := {||     {Iif(aEstoque[oEstoque:nAt,01],oOk,oNo),;
             					  aEstoque[oEstoque:nAt,02],;
         	        	          aEstoque[oEstoque:nAt,03],;
         	        	          aEstoque[oEstoque:nAt,04],;
         	        	          aEstoque[oEstoque:nAt,05],;
         	        	          aEstoque[oEstoque:nAt,06],;
         	        	          aEstoque[oEstoque:nAt,07],;
         	        	          aEstoque[oEstoque:nAt,08]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que fecha a janela da Importação de Estoque
Static Function FechaImpStq(_Codigo)
   
   oDlgX:End() 

   Pesquisa_Filtro(_Codigo,1)

Return(.T.)

// Função que marca ou desmarca todos os registros pesquisados
Static Function McTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aEstoque)
       aEstoque[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oEstoque:Refresh()
   
Return(.T.)         

// Função que atualiza a Importação por Estoque
Static Function SlvAtuSqt(_Codigo)

   Local cSql     := ""
   Local _nErro   := 0
   Local dImporta := Strzero(year(date()),4) + Strzero(month(date()),2) + Strzero(day(date()),2)
   Local nContar  := 0
         
   For nContar = 1 to Len(aEstoque)
      
       If aEstoque[nContar,01] == .F.
          Loop
       Endif

       cSql := ""
       cSql := "UPDATE " + RetSqlName("DA1")
       cSql += "   SET "
       cSql += "   DA1_TREG       = 'E'"                 + " , "
       cSql += "   DA1_DIMPO      = '" + dImporta        + "', "
       cSql += "   DA1_MOEDA      =  " + Alltrim(str(1)) + " , "
       cSql += "   DA1_PRCVEN     =  " + Alltrim(str(aEstoque[nContar,08])) 
       cSql += " WHERE DA1_CODTAB = '" + Alltrim(_codigo)              + "'"
       cSql += "   AND DA1_CODPRO = '" + Alltrim(aEstoque[nContar,03]) + "'"
       cSql += "   AND DA1_ITEM   = '" + Alltrim(aEstoque[nContar,02]) + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
       Endif
       
   Next nContar

   MsgAlert("Importação realizada com sucesso.")  
 
   oDlgX:End()

   Pesquisa_Filtro(_Codigo,1)
       
Return(.T.)

// Função que atualiza o Preço de Venda para os Registros do Tipo I e E.
Static Function AtuPrcVda(_Codigo, _Tipo)

   Local cSql       := ""
   Local cTexto     := ""
   Local CustoFinal := 0

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   Private aAtualiza := {}
   Private oAtualiza

   // Monta o texto da mensagem a ser apresentada   
   cTexto := ""
   cTexto := "Atenção!" + chr(13) + chr(13)

   If _Tipo == 1
      cTexto += "Este procedimento tem por finalidade de realizar a atualização do preço de venda para os registros do Tipo I utilizando a seguinte regra:" + chr(13) + chr(13) 
      cTexto += "PREÇO DE VENDA = CUSTO STANDART * FATOR"+ chr(13) + chr(13) 
      ctexto += "Deseja executar este procedimento?"
   Else
      cTexto += "Este procedimento tem por finalidade de realizar a atualização do preço de venda para os registros do Tipo E utilizando a seguinte regra:" + chr(13) + chr(13) 
      cTexto += "PREÇO DE VENDA = CUSTO MÉDIO * FATOR"+ chr(13) + chr(13) 
      ctexto += "Deseja executar este procedimento?"
   Endif

   If !MsgYesNo(cTexto)
      Return(.T.)
   Endif
  
   // Pesquisa os produtos da tabela de preço selecionada conforme botão selecionado
   If Select("T_ATUALIZA") > 0
      T_ATUALIZA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA1.DA1_CODTAB,"
   cSql += "       DA1.DA1_ITEM  ,"
   cSql += "       DA1.DA1_CODPRO,"
   cSql += "       SB1.B1_DESC + ' ' + SB1.B1_DAUX AS PRODUTO,"
   cSql += "       SB1.B1_CUSTD  ,"
   cSql += "       DA1.DA1_PRCVEN,"
   cSql += "       DA1.DA1_FATOR ,"
   cSql += "       DA1.DA1_TREG  ,"
   cSql += "       DA1.DA1_MOEDA ,"
   cSql += "       DA1.DA1_CUSTD ,"
   cSql += "       DA1.DA1_MCUST ,"
   cSql += "       SB1.B1_CUSTD  ,"
   cSql += " ISNULL(              "
   cSql += "      (SELECT B2_CM1  "
   cSql += "         FROM " + RetSqlName("SB2")
   cSql += "        WHERE B2_FILIAL  = '01'"
   cSql += "          AND B2_LOCAL   = '01'"
   cSql += "          AND B2_COD     = DA1.DA1_CODPRO"
   cSql += "          AND D_E_L_E_T_ = ''"
   cSql += "       ), 0.00) AS CUSTO"
   cSql += "  FROM " + RetSqlName("DA1") + " DA1, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE DA1.DA1_CODTAB = '" + Alltrim(_Codigo) + "'"

   If _Tipo == 1
      cSql += "   AND DA1.DA1_TREG   = 'I'"
   Else
      cSql += "   AND DA1.DA1_TREG   = 'E'"
   Endif
            
   cSql += "   AND DA1.D_E_L_E_T_ = ''"
   cSql += "   AND DA1.DA1_CODPRO = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += " ORDER BY SB1.B1_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATUALIZA", .T., .T. )

   If T_ATUALIZA->( EOF() ) 
      MsgAlert("Não existem dados a serem atualizados.")
      Return(.T.)
   Endif
   
   T_ATUALIZA->( DbGoTop() )

   CustoFinal := 0

   WHILE !T_ATUALIZA->( EOF() )

      If _Tipo == 1

         // Carrega o Custo Standart
         If T_ATUALIZA->DA1_CUSTD == 0
            If T_ATUALIZA->B1_CUSTD <> 0
               __Custo := T_ATUALIZA->B1_CUSTD
            Else
               __Custo := T_ATUALIZA->DA1_CUSTD
            Endif
         Else
            __Custo := T_ATUALIZA->DA1_CUSTD         
         Endif

         CustoFinal := ROUND(__Custo * T_ATUALIZA->DA1_FATOR,2)

//         If T_ATUALIZA->DA1_PRCVEN <> 0 .And. T_ATUALIZA->DA1_CUSTD <> 0
//            CustoFinal := ROUND(T_ATUALIZA->DA1_CUSTD * T_ATUALIZA->DA1_FATOR,2)
//         Else
//            CustoFinal := 0
//         Endif

//         If T_ATUALIZA->DA1_PRCVEN <> 0 .And. T_ATUALIZA->B1_CUSTD <> 0
//---->           CustoFinal := ROUND(T_ATUALIZA->B1_CUSTD * T_ATUALIZA->DA1_FATOR,2)
//         Else
//            CustoFinal := 0
//         Endif


      Else
         If T_ATUALIZA->DA1_PRCVEN <> 0 .And. T_ATUALIZA->CUSTO <> 0
            CustoFinal := ROUND(T_ATUALIZA->CUSTO * T_ATUALIZA->DA1_FATOR,2)
         Else
            CustoFinal := 0
         Endif
      Endif

      // Atualiza o array para o display
      aAdd( aAtualiza, { IIF(CustoFinal = 0, .F., .T.)   ,;
                         T_ATUALIZA->DA1_ITEM            ,;
                         ALLTRIM(T_ATUALIZA->DA1_CODPRO) ,;
                         ALLTRIM(T_ATUALIZA->PRODUTO)    ,;
                         T_ATUALIZA->DA1_MOEDA           ,;
                         T_ATUALIZA->DA1_PRCVEN          ,;                        
                         T_ATUALIZA->DA1_FATOR           ,;
                         IIF(_Tipo == 1, ROUND(__Custo,2), ROUND(T_ATUALIZA->CUSTO,2)) ,;
                         CUSTOFINAL                      })
      T_ATUALIZA->( DbSkip() )

//                         IIF(_Tipo == 1, ROUND(T_ATUALIZA->B1_CUSTD,2), ROUND(T_ATUALIZA->CUSTO,2)) ,;

//                         IIF(_Tipo == 1, ROUND(T_ATUALIZA->DA1_CUSTD,2), ROUND(T_ATUALIZA->CUSTO,2)) ,;

   ENDDO

   If _Tipo == 1
      DEFINE MSDIALOG oDlgX TITLE "Atualização Preço de Venda Registros do Tipo I" FROM C(178),C(181) TO C(618),C(908) PIXEL
   Else
      DEFINE MSDIALOG oDlgX TITLE "Atualização Preço de Venda Registros do Tipo E" FROM C(178),C(181) TO C(618),C(908) PIXEL
   Endif

   @ C(005),C(005) Say "Relação de produtos a serem atualizados os Preços de Venda." Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"    Size C(055),C(012) PIXEL OF oDlgX ACTION( MaTodos(1) )
   @ C(203),C(062) Button "Desmarca Todos" Size C(055),C(012) PIXEL OF oDlgX ACTION( MaTodos(2) )
   @ C(203),C(280) Button "Confirmar"      Size C(037),C(012) PIXEL OF oDlgX ACTION( GrvAtuPrc(_Codigo) )
   @ C(203),C(319) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgX ACTION( FechaImpStq(_Codigo) )

   // Cria Componentes Padroes do Sistema
   @ 15,05 LISTBOX oAtualiza FIELDS HEADER "", "Item", "Código" ,"Descrição dos Produtos", "Moeda", "Vld.Vda.Moeda", "Fator", IIF(_Tipo == 1, "Custo Standart", "Custo Médio (POA)"), "Novo Prç.Vda." PIXEL SIZE 460,240 OF oDlgX ;
                            ON dblClick(aAtualiza[oAtualiza:nAt,1] := !aAtualiza[oAtualiza:nAt,1],oAtualiza:Refresh())     
   oAtualiza:SetArray( aAtualiza )
   oAtualiza:bLine := {||     {Iif(aAtualiza[oAtualiza:nAt,01],oOk,oNo),;
             		    		   aAtualiza[oAtualiza:nAt,02],;
         	         	           aAtualiza[oAtualiza:nAt,03],;
         	        	           aAtualiza[oAtualiza:nAt,04],;
         	        	           aAtualiza[oAtualiza:nAt,05],;
         	        	           aAtualiza[oAtualiza:nAt,06],;
         	        	           aAtualiza[oAtualiza:nAt,07],;
         	        	           aAtualiza[oAtualiza:nAt,08],;
         	        	           aAtualiza[oAtualiza:nAt,09]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que marca ou desmarca todos os registros pesquisados
Static Function MaTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aAtualiza)
       aAtualiza[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oAtualiza:Refresh()
   
Return(.T.)         

// Função que atualiza a Atualização do Preço de Venda para as opções dos botões de Atualização de preço de Venda de registros I e E.
Static Function GrvAtuPrc(_Codigo)

   Local cSql      := ""
   Local _nErro    := 0
   Local nContar   := 0
   Local xMarcados := .F.
         
   // Verifica se houve pelo menos um regsitro marcado para atualização
   xMarcados := .F.
   For nContar = 1 to Len(aAtualiza)
       If aAtualiza[nContar,01] == .T.
          xMarcados := .T.
          Exit
       Endif
   Next nContar
   
   If xMarcados == .F.
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Atualização não será realizada pois nenhum registro foi indicado para atualização."  + chr(13) + chr(13) + "Verique!")
      Return(.T.)
   Endif

   // Atualiza os registros indicados para atualização
   For nContar = 1 to Len(aAtualiza)
      
       If aAtualiza[nContar,01] == .F.
          Loop
       Endif

       cSql := ""
       cSql := "UPDATE " + RetSqlName("DA1")
       cSql += "   SET "
       cSql += "   DA1_PRCVEN     =  " + Alltrim(str(aAtualiza[nContar,09])) 
       cSql += " WHERE DA1_CODTAB = '" + Alltrim(_codigo)               + "'"
       cSql += "   AND DA1_CODPRO = '" + Alltrim(aAtualiza[nContar,03]) + "'"
       cSql += "   AND DA1_ITEM   = '" + Alltrim(aAtualiza[nContar,02]) + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
       Endif
       
   Next nContar

   MsgAlert("Atualização de Preço de Venda realizada com sucesso.")  
 
   oDlgX:End()

   Pesquisa_Filtro(_Codigo,1)
       
Return(.T.)

// Função que abre tela de histórico do produto selecionado
Static Function Hist_Produto(_Produto)

   Private aRotina := {}
   
   aAdd (aRotina, { _Produto, 0, 0, 0, 0 } )

   aArea := GetArea()

   MaComView(_Produto)

   RestArea( aArea )

Return(.T.)

// Função que pesquisa o saldo do produto selecionado
Static Function xSaldoLista(_Produto)

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return .T.
