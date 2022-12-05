#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR67.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/12/2011                                                          *
// Objetivo..: Tracker Automatech - Call Center                                    *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR67()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea  := {}
   Local _aAlias := {}

   Local lLibera         := .F.

   Private oGet1         := Space(06)
   Private oGet2         := Space(06)
   Private oGet3         := Space(06)
   Private oGet4         := Space(06)
   Private oGet5         := Space(09)       
   Private oGet6         := Space(06)
   Private oGet7         := Space(40)
   Private oGet8         := Space(10)

   Private aBrowse       := {} 
   Private cProposta     := Space(06)
   Private cPedido       := Space(06)
   Private cProducao     := Space(06)
   Private cNota         := Space(10)

   Private cNomeCliente  := ""
   Private cNomeCondicao := ""
   Private cVendedor     := ""
   Private cTransporte   := ""
   Private aComboBx1     := U_AUTOM539(2, cEmpAnt) // {"", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas" }
   Private cComboBx1
      
   Private aComboBx2     := {"", "01 - Atendimento", "02 - Pedido de Venda", "03 - Ordem de Produção", "04 - Nota Fiscal"}
   Private cComboBx2

   U_AUTOM628("AUTOMR67")
   
   cCodigo             := Space(06)
   cProposta           := ""
   cPedido             := ""
   cProducao           := ""
   cNota               := ""
   cNomeCliente        := ""
   cNomeCondicao       := ""
   cNomeV01            := ""
   cNomeV02            := ""

   // Diálogo Principal
   Private oDlg

   DEFINE FONT oFont Name "Arial" Size 0, -14 BOLD

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg TITLE "Rastreabilidade de Atendimento Call Center" FROM C(178),C(181) TO C(550),C(700) PIXEL

   @ C(010),C(005) Say "CÓDIGO:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(045) Say "TIPO:"             Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(115) Say "FILIAL:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(007),C(024) MsGet oGet1 Var cCodigo Size C(015),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(008),C(058) ComboBox cComboBx2 Items aComboBx2 Size C(055),C(010) PIXEL OF oDlg
   @ C(008),C(130) ComboBox cComboBx1 Items aComboBx1 Size C(040),C(010) PIXEL OF oDlg

   @ C(020),C(005) Say Replicate("-",250) Size C(250),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg

   @ C(032),C(060) Say "ATENDIMENTO"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(110) Say "PEDIDO VENDA"        Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(160) Say "ORDEM PRODUÇÃO"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(210) Say "NOTA FISCAL"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(062),C(005) Say "CLIENTE:"            Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(077),C(005) Say "CONDIÇÃO PAGAMENTO:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(092),C(005) Say "VENDEDOR:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(107),C(005) Say "TRANSPORTADORA:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(120),C(005) Say "Produtos do Atendimento" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(040),C(060) MsGet oGet1 Var cProposta     when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(040),C(110) MsGet oGet2 Var cPedido       when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(040),C(160) MsGet oGet3 Var cProducao     when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(040),C(210) MsGet oGet8 Var cNota         when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(060),C(060) MsGet oGet4 Var cNomeCliente  when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(075),C(060) MsGet oGet5 Var cNomeCondicao when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(090),C(060) MsGet oGet6 Var cVendedor     when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(105),C(060) MsGet oGet7 Var cTransporte   when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

// @ 037,130  BUTTON "Visualizar" Size 40,12 when !Empty(cOportunidade) ACTION (Abre_Tela(1, cComboBx2, cOportunidade )) OF oDlg Pixel

   oBrowse := TSBrowse():New(165,005,324,070,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   @ 010,225  BUTTON "Pesquisar"  Size 50,12 when !Empty(cCodigo) ACTION( PESQCENTER( cCodigo, cComboBx1, cComboBx2 ) ) OF oDlg Pixel
   @ 010,280  BUTTON "Voltar"     Size 50,12 ACTION( odlg:end() ) OF oDlg Pixel

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que prepara a impressão do relatório
Static Function PESQCENTER( cCodigo, cComboBx1, cComboBx2 )

   Local cSql      := ""
   Private aBrowse := {}

   cProposta     := Space(06)
   cPedido       := Space(06)
   cProducao     := Space(06)
   cNomeCliente  := ""
   cNomeCondicao := ""
   cVendedor     := ""
   cTransporte   := ""

   oGet1         := Space(06)
   oGet2         := Space(06)
   oGet3         := Space(06)
   oGet4         := Space(06)
   oGet5         := Space(09)       
   oGet6         := Space(06)
   oGet7         := Space(40)

   // Valida os dados informados. Somente permite a informação de um dos campos para pesquisa.
   If Empty(Alltrim(cCodigo))
      MsgAlert("Código a ser pesquisado não foi informado.")
      Return .T.
   Endif
      
   If Empty(Alltrim(cComboBx2))
      MsgAlert("Tipo de Documento a ser pesquisado não informado.")
      Return .T.
   Endif

   If Empty(Alltrim(cComboBx1))
      MsgAlert("Filial não informada para pesquisa.")
      Return .T.
   Endif

   // Dispara a pesquisa dos dados da Oportunidade
   PESQ_CALLCENTER( cCodigo, cComboBx1, cComboBx2 )

Return .T.

// Função que pesquisa pela informação de Oportunidade, Proposta Comercial ou Orçamento
Static Function PESQ_CALLCENTER( cCodigo, cComboBx1, cComboBx2 )

   // Pesquisa por nº de Atendimento
   If Substr(cComboBx2,01,02) == "01"
      PESQ_ATENDE( cCodigo, cComboBx1, cComboBx2 )      
   Endif
   
   // Pesquisa por nº de Pedido de Venda
   If Substr(cComboBx2,01,02) == "02"
      PESQ_PEDIDO( cCodigo, cComboBx1, cComboBx2 )      
   Endif

   // Pesquisa por nº de Produção
   If Substr(cComboBx2,01,02) == "03"
      PESQ_PRODUCAO( cCodigo, cComboBx1, cComboBx2 )      
   Endif

   // Pesquisa por Nota Fiscal
   If Substr(cComboBx2,01,02) == "04"
      PESQ_NOTA( cCodigo, cComboBx1, cComboBx2 )      
   Endif

Return .T.      

// Função que pesquisa os dados pelo número do atendimento
Static Function PESQ_ATENDE( cCodigo, cComboBx1, cComboBx2 )

   Local nContar := 0
   Local nCodV01 := ""
   Local nCodV02 := ""
   Local nCodPag := ""

   // Pesquisa os dados do documento selecionado
   If Select("T_CONJUNTO") > 0
      T_CONJUNTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UA_NUM    , "
   cSql += "       A.UA_NUMSC5 , "
   cSql += "       A.UA_CLIENTE, "
   cSql += "       A.UA_LOJA   , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.UA_CONDPG , "
   cSql += "       C.E4_DESCRI , "
   cSql += "       A.UA_VEND   , "
   cSql += "       D.A3_NOME   , "
   cSql += "       A.UA_TRANSP , "
   cSql += "       E.A4_NOME     "
   cSql += "  FROM " + RetSqlName("SUA010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B, "
   cSql += "       " + RetSqlName("SE4010") + " C, "
   cSql += "       " + RetSqlName("SA3010") + " D, "
   cSql += "       " + RetSqlName("SA4010") + " E  "
   cSql += " WHERE A.UA_NUM       = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.UA_CLIENTE   = B.A1_COD   "
   cSql += "   AND A.UA_LOJA      = B.A1_LOJA  "
   cSql += "   AND A.UA_CONDPG    = C.E4_CODIGO"
   cSql += "   AND A.UA_VEND      = D.A3_COD   "
   cSql += "   AND A.UA_TRANSP    = E.A4_COD   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONJUNTO", .T., .T. )

   If T_CONJUNTO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este Atendimento.")
      Return .T.
   ENDIF

   T_CONJUNTO->( DbGoTop () )

   cProposta     := T_CONJUNTO->UA_NUM
   cPedido       := T_CONJUNTO->UA_NUMSC5
   cProducao     := ""
   cNomeCliente  := T_CONJUNTO->A1_NOME
   cNomeCondicao := T_CONJUNTO->E4_DESCRI
   cVendedor     := T_CONJUNTO->A3_NOME
   cTransporte   := T_CONJUNTO->A4_NOME

   // Pesquisa o nº da ordem de produção
   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_NUMOP,  "
   cSql += "       C6_NOTA    "
   cSql += "  FROM " + RetSqlName("SC6010")
   cSql += " WHERE C6_NUM       = '" + ALLTRIM(T_CONJUNTO->UA_NUMSC5)   + "'"
   cSql += "   AND C6_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'" 
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   IF T_PRODUCAO->( Eof() )
      cProducao := ""
      cNota     := ""
   Else
      cProducao := T_PRODUCAO->C6_NUMOP
      cNota     := T_PRODUCAO->C6_NOTA
   Endif

   // Pesquisa os produtos do Atendimento para display
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UB_NUM    ,"
   cSql += "       A.UB_PRODUTO,"
   cSql += "       A.UB_QUANT  ,"
   cSql += "       A.UB_VRUNIT ,"
   cSql += "       A.UB_VLRITEM,"
   cSql += "       B.B1_DESC    "
   cSql += "  FROM " + RetSqlName("SUB010") + " A, "
   cSql += "       " + RetSqlName("SB1010") + " B  "
   cSql += " WHERE A.UB_NUM       = '" + Alltrim(cCodigo)                 + "'"
   cSql += "   AND A.UB_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   cSql += "   AND A.UB_PRODUTO   = B.B1_COD " 
   cSql += "   AND A.R_E_C_D_E_L_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If !T_PRODUTOS->( Eof() )
            
      While !T_PRODUTOS->( EOF() )

  	     aAdd( aBrowse, { T_PRODUTOS->UB_PRODUTO            ,;
                          T_PRODUTOS->B1_DESC               ,;
                          STR(T_PRODUTOS->UB_QUANT,05)      ,;
                          STR(T_PRODUTOS->UB_VRUNIT,10,02)  ,;
                          STR(T_PRODUTOS->UB_VLRITEM,10,02) } )
         T_PRODUTOS->( DbSkip() )
               
      Enddo
      
   Endif   

   oBrowse := TSBrowse():New(165,005,324,070,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)
      
Return .T.

// Função que pesquisa os dados pelo número do atendimento
Static Function PESQ_PEDIDO( cCodigo, cComboBx1, cComboBx2 )

   Local nContar := 0
   Local nCodV01 := ""
   Local nCodV02 := ""
   Local nCodPag := ""

   // Pesquisa o nº da ordem de produção
   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_NUMOP,  "
   cSql += "       C6_NOTA ,  "
   cSql += "       C6_NUM     "
   cSql += "  FROM " + RetSqlName("SC6010")
   cSql += " WHERE C6_NUM       = '" + Alltrim(cCodigo)   + "'"
   cSql += "   AND C6_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'" 
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   If T_PRODUCAO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Else
      cProducao := T_PRODUCAO->C6_NUMOP
      cPedido   := T_PRODUCAO->C6_NUM
      cNota     := T_PRODUCAO->C6_NOTA
   Endif

   // Pesquisa os dados do documento selecionado
   If Select("T_CONJUNTO") > 0
      T_CONJUNTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UA_NUM    , "
   cSql += "       A.UA_NUMSC5 , "
   cSql += "       A.UA_CLIENTE, "
   cSql += "       A.UA_LOJA   , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.UA_CONDPG , "
   cSql += "       C.E4_DESCRI , "
   cSql += "       A.UA_VEND   , "
   cSql += "       D.A3_NOME   , "
   cSql += "       A.UA_TRANSP , "
   cSql += "       E.A4_NOME     "
   cSql += "  FROM " + RetSqlName("SUA010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B, "
   cSql += "       " + RetSqlName("SE4010") + " C, "
   cSql += "       " + RetSqlName("SA3010") + " D, "
   cSql += "       " + RetSqlName("SA4010") + " E  "
   cSql += " WHERE A.UA_NUMSC5    = '" + ALLTRIM(cPedido) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.UA_CLIENTE   = B.A1_COD   "
   cSql += "   AND A.UA_LOJA      = B.A1_LOJA  "
   cSql += "   AND A.UA_CONDPG    = C.E4_CODIGO"
   cSql += "   AND A.UA_VEND      = D.A3_COD   "
   cSql += "   AND A.UA_TRANSP    = E.A4_COD   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONJUNTO", .T., .T. )

   If T_CONJUNTO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este Atendimento.")
      Return .T.
   ENDIF

   T_CONJUNTO->( DbGoTop () )

   cProposta     := T_CONJUNTO->UA_NUM
   cPedido       := T_CONJUNTO->UA_NUMSC5
   cNomeCliente  := T_CONJUNTO->A1_NOME
   cNomeCondicao := T_CONJUNTO->E4_DESCRI
   cVendedor     := T_CONJUNTO->A3_NOME
   cTransporte   := T_CONJUNTO->A4_NOME

   // Pesquisa os produtos do Atendimento para display
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UB_NUM    ,"
   cSql += "       A.UB_PRODUTO,"
   cSql += "       A.UB_QUANT  ,"
   cSql += "       A.UB_VRUNIT ,"
   cSql += "       A.UB_VLRITEM,"
   cSql += "       B.B1_DESC    "
   cSql += "  FROM " + RetSqlName("SUB010") + " A, "
   cSql += "       " + RetSqlName("SB1010") + " B  "
   cSql += " WHERE A.UB_NUM       = '" + Alltrim(cProposta)               + "'"
   cSql += "   AND A.UB_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   cSql += "   AND A.UB_PRODUTO   = B.B1_COD " 
   cSql += "   AND A.R_E_C_D_E_L_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If !T_PRODUTOS->( Eof() )
            
      While !T_PRODUTOS->( EOF() )

  	     aAdd( aBrowse, { T_PRODUTOS->UB_PRODUTO            ,;
                          T_PRODUTOS->B1_DESC               ,;
                          STR(T_PRODUTOS->UB_QUANT,05)      ,;
                          STR(T_PRODUTOS->UB_VRUNIT,10,02)  ,;
                          STR(T_PRODUTOS->UB_VLRITEM,10,02) } )
         T_PRODUTOS->( DbSkip() )
               
      Enddo
      
   Endif   

   oBrowse := TSBrowse():New(165,005,324,070,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)
      
Return .T.

// Função que pesquisa os dados pelo número da Ordem de Produção
Static Function PESQ_PRODUCAO( cCodigo, cComboBx1, cComboBx2 )

   Local nContar := 0
   Local nCodV01 := ""
   Local nCodV02 := ""
   Local nCodPag := ""

   // Pesquisa o nº da ordem de produção
   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_NUMOP,  "
   cSql += "       C6_NOTA ,  "
   cSql += "       C6_NUM     "
   cSql += "  FROM " + RetSqlName("SC6010")
   cSql += " WHERE C6_NUMOP     = '" + Alltrim(cCodigo)   + "'"
   cSql += "   AND C6_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'" 
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   If T_PRODUCAO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Else
      cProducao := T_PRODUCAO->C6_NUMOP
      cPedido   := T_PRODUCAO->C6_NUM
      cNota     := T_PRODUCAO->C6_NOTA
   Endif

   // Pesquisa os dados do documento selecionado
   If Select("T_CONJUNTO") > 0
      T_CONJUNTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UA_NUM    , "
   cSql += "       A.UA_NUMSC5 , "
   cSql += "       A.UA_CLIENTE, "
   cSql += "       A.UA_LOJA   , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.UA_CONDPG , "
   cSql += "       C.E4_DESCRI , "
   cSql += "       A.UA_VEND   , "
   cSql += "       D.A3_NOME   , "
   cSql += "       A.UA_TRANSP , "
   cSql += "       E.A4_NOME     "
   cSql += "  FROM " + RetSqlName("SUA010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B, "
   cSql += "       " + RetSqlName("SE4010") + " C, "
   cSql += "       " + RetSqlName("SA3010") + " D, "
   cSql += "       " + RetSqlName("SA4010") + " E  "
   cSql += " WHERE A.UA_NUMSC5    = '" + ALLTRIM(cPedido) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.UA_CLIENTE   = B.A1_COD   "
   cSql += "   AND A.UA_LOJA      = B.A1_LOJA  "
   cSql += "   AND A.UA_CONDPG    = C.E4_CODIGO"
   cSql += "   AND A.UA_VEND      = D.A3_COD   "
   cSql += "   AND A.UA_TRANSP    = E.A4_COD   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONJUNTO", .T., .T. )

   If T_CONJUNTO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este Atendimento.")
      Return .T.
   ENDIF

   T_CONJUNTO->( DbGoTop () )

   cProposta     := T_CONJUNTO->UA_NUM
   cPedido       := T_CONJUNTO->UA_NUMSC5
   cNomeCliente  := T_CONJUNTO->A1_NOME
   cNomeCondicao := T_CONJUNTO->E4_DESCRI
   cVendedor     := T_CONJUNTO->A3_NOME
   cTransporte   := T_CONJUNTO->A4_NOME

   // Pesquisa os produtos do Atendimento para display
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UB_NUM    ,"
   cSql += "       A.UB_PRODUTO,"
   cSql += "       A.UB_QUANT  ,"
   cSql += "       A.UB_VRUNIT ,"
   cSql += "       A.UB_VLRITEM,"
   cSql += "       B.B1_DESC    "
   cSql += "  FROM " + RetSqlName("SUB010") + " A, "
   cSql += "       " + RetSqlName("SB1010") + " B  "
   cSql += " WHERE A.UB_NUM       = '" + Alltrim(cProposta)               + "'"
   cSql += "   AND A.UB_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   cSql += "   AND A.UB_PRODUTO   = B.B1_COD " 
   cSql += "   AND A.R_E_C_D_E_L_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If !T_PRODUTOS->( Eof() )
            
      While !T_PRODUTOS->( EOF() )

  	     aAdd( aBrowse, { T_PRODUTOS->UB_PRODUTO            ,;
                          T_PRODUTOS->B1_DESC               ,;
                          STR(T_PRODUTOS->UB_QUANT,05)      ,;
                          STR(T_PRODUTOS->UB_VRUNIT,10,02)  ,;
                          STR(T_PRODUTOS->UB_VLRITEM,10,02) } )
         T_PRODUTOS->( DbSkip() )
               
      Enddo
      
   Endif   

   oBrowse := TSBrowse():New(165,005,324,070,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)
      
Return .T.

// Função que pesquisa os dados pelo número da Nota Fiscal
Static Function PESQ_NOTA( cCodigo, cComboBx1, cComboBx2 )

   Local nContar := 0
   Local nCodV01 := ""
   Local nCodV02 := ""
   Local nCodPag := ""

   // Pesquisa o nº da ordem de produção
   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_NUMOP,  "
   cSql += "       C6_NOTA ,  "
   cSql += "       C6_NUM     " 
   cSql += "  FROM " + RetSqlName("SC6010")
   cSql += " WHERE C6_NOTA      = '" + ALLTRIM(cCodigo)                 + "'"
   cSql += "   AND C6_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'" 
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   If T_PRODUCAO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Else
      cProducao := T_PRODUCAO->C6_NUMOP
      cNota     := T_PRODUCAO->C6_NOTA
      cPedido   := T_PRODUCAO->C6_NUM
   Endif

   // Pesquisa os dados do documento selecionado
   If Select("T_CONJUNTO") > 0
      T_CONJUNTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UA_NUM    , "
   cSql += "       A.UA_NUMSC5 , "
   cSql += "       A.UA_CLIENTE, "
   cSql += "       A.UA_LOJA   , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.UA_CONDPG , "
   cSql += "       C.E4_DESCRI , "
   cSql += "       A.UA_VEND   , "
   cSql += "       D.A3_NOME   , "
   cSql += "       A.UA_TRANSP , "
   cSql += "       E.A4_NOME     "
   cSql += "  FROM " + RetSqlName("SUA010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B, "
   cSql += "       " + RetSqlName("SE4010") + " C, "
   cSql += "       " + RetSqlName("SA3010") + " D, "
   cSql += "       " + RetSqlName("SA4010") + " E  "
   cSql += " WHERE A.UA_NUMSC5    = '" + ALLTRIM(cPedido) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.UA_CLIENTE   = B.A1_COD   "
   cSql += "   AND A.UA_LOJA      = B.A1_LOJA  "
   cSql += "   AND A.UA_CONDPG    = C.E4_CODIGO"
   cSql += "   AND A.UA_VEND      = D.A3_COD   "
   cSql += "   AND A.UA_TRANSP    = E.A4_COD   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONJUNTO", .T., .T. )

   If T_CONJUNTO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este Atendimento.")
      Return .T.
   ENDIF

   T_CONJUNTO->( DbGoTop () )

   cProposta     := T_CONJUNTO->UA_NUM
   cPedido       := T_CONJUNTO->UA_NUMSC5
   cNomeCliente  := T_CONJUNTO->A1_NOME
   cNomeCondicao := T_CONJUNTO->E4_DESCRI
   cVendedor     := T_CONJUNTO->A3_NOME
   cTransporte   := T_CONJUNTO->A4_NOME

   // Pesquisa os produtos do Atendimento para display
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UB_NUM    ,"
   cSql += "       A.UB_PRODUTO,"
   cSql += "       A.UB_QUANT  ,"
   cSql += "       A.UB_VRUNIT ,"
   cSql += "       A.UB_VLRITEM,"
   cSql += "       B.B1_DESC    "
   cSql += "  FROM " + RetSqlName("SUB010") + " A, "
   cSql += "       " + RetSqlName("SB1010") + " B  "
   cSql += " WHERE A.UB_NUM       = '" + Alltrim(T_CONJUNTO->UA_NUM)      + "'"
   cSql += "   AND A.UB_FILIAL    = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   cSql += "   AND A.UB_PRODUTO   = B.B1_COD " 
   cSql += "   AND A.R_E_C_D_E_L_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If !T_PRODUTOS->( Eof() )
            
      While !T_PRODUTOS->( EOF() )

  	     aAdd( aBrowse, { T_PRODUTOS->UB_PRODUTO            ,;
                          T_PRODUTOS->B1_DESC               ,;
                          STR(T_PRODUTOS->UB_QUANT,05)      ,;
                          STR(T_PRODUTOS->UB_VRUNIT,10,02)  ,;
                          STR(T_PRODUTOS->UB_VLRITEM,10,02) } )
         T_PRODUTOS->( DbSkip() )
               
      Enddo
      
   Endif   

   oBrowse := TSBrowse():New(165,005,324,070,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)
      
Return .T.

// Função que abre a tela conforme o botão selecionado
Static Function ABRE_TELA( _Tipo, cComboBx2, _Codigo)

   Local aIndex   := {}
   Local cFiltro1 := "AD1_FILIAL == '" + Substr(cComboBx2,01,02) + "', AD1_NROPOR == '" + Alltrim(_Codigo) + "'"
   Local cFiltro2 := "C5_FILIAL  == '" + Substr(cComboBx2,01,02) + "', C5_NUM     == '" + Alltrim(_Codigo) + "'"
   Local cFiltro3 := "ADY_FILIAL == '" + Substr(cComboBx2,01,02) + "', ADY_PROPOS == '" + Alltrim(_Codigo) + "'"
   
   Private aRotina := {;
                      { "Pesquisar"  , ""         , 0 , 1 },;
                      { "Visualizar" , "AxVisual" , 0 , 2 },;
                      { "Incluir"    , ""         , 0 , 3 },;
                      { "Alterar"    , ""         , 0 , 4 },;
                      { "Excluir"    , ""         , 0 , 5 } ;
                      }

   //Determina a Expressão do Filtro
   Do Case
      Case _Tipo == 1
           Private bFiltraBrw := { || FilBrowse( "AD1" , @aIndex , @cFiltro1 ) } 
           Private cCadastro := "Consulta de Oprtunidades"
      Case _Tipo == 2
           Private bFiltraBrw := { || FilBrowse( "SC5" , @aIndex , @cFiltro2 ) } 
           Private cCadastro := "Consulta de Pedido de venda"
      Case _Tipo == 3
           Private bFiltraBrw := { || FilBrowse( "ADY" , @aIndex , @cFiltro3 ) } 
           Private cCadastro := "Consulta de Proposta Comercial"

   EndCase        

   //Efetiva o Filtro antes da Chamada a mBrowse
   Eval( bFiltraBrw )    

   Do Case
      Case _Tipo == 1
           mBrowse( 6 , 1 , 22 , 75 , "AD1" )
           EndFilBrw( "AD1" , @aIndex ) //Finaliza o Filtro

      Case _Tipo == 2
           mBrowse( 6 , 1 , 22 , 75 , "SC5", .f. )
           EndFilBrw( "SC5" , @aIndex ) //Finaliza o Filtro

      Case _Tipo == 3
           mBrowse( 6 , 1 , 22 , 75 , "ADY", .f. )
           EndFilBrw( "ADY" , @aIndex ) //Finaliza o Filtro

   EndCase        

Return( NIL )