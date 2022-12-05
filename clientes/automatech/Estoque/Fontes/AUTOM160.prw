#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM160.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/07/2012                                                          *
// Objetivo..: Programa que permite a usuários alterarrem alguns campos do cadas-  *
//             tro de produtos                                                     *
//**********************************************************************************

User Function AUTOM160()

   Local lChumba      := .F.
   Local cSql         := ""

   Private cProduto   := Space(30)
   Private cDescricao := Space(60)
   Private cGrupo 	  := Space(04)
   Private cNomeGrupo := Space(40)
   Private cBarras    := Space(30)
   Private cFornece	  := Space(06)
   Private cLojaFor	  := Space(03)
   Private cNomeFor   := Space(40)
   Private cNCM  	  := Space(10)
   Private cOrigem 	  := Space(01)
   Private cNomeOri   := Space(40)
   Private cTributa   := Space(06)
   Private cNomeTri   := Space(40)
   Private cEndereco  := Space(01)
   Private cEndAnte   := Space(01)
   Private lAbre      := .T.
   Private lFecha     := .F.

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

   Private oDlg

   U_AUTOM628("AUTOM160")

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Produtos" FROM C(178),C(181) TO C(570),C(570) PIXEL

   @ C(005),C(005) Say "Código"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Descrição do Produto"       Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(047),C(005) Say "Grupo"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(068),C(005) Say "Código de Barras"           Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(089),C(005) Say "Fornecedor Padrão"          Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(109),C(005) Say "Controle Endereço"          Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(109),C(094) Say "N C M"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(131),C(005) Say "Grupo Tributário"           Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(152),C(005) Say "Origem"                     Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(119),C(020) Say "[ S ] - Sim    [ N ] - Não" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet1     Var   cProduto                Size C(099),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1")

   @ C(012),C(107) Button "Pesquisar"     When lAbre  Size C(037),C(012) PIXEL OF oDlg ACTION( Buscaprod() )
   @ C(012),C(146) Button "Nova Pesquisa" When lFecha Size C(042),C(012) PIXEL OF oDlg ACTION( Limpaprod() )

   @ C(035),C(005) MsGet    oGet2     Var cDescricao When lChumba Size C(183),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(056),C(005) MsGet    oGet3     Var cGrupo     When lFecha  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SBM") VALID( TrazGrupo() )
   @ C(056),C(035) MsGet    oGet4     Var cNomeGrupo When lChumba Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(077),C(005) MsGet    oGet5     Var cBarras    When lFecha  Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(097),C(005) MsGet    oGet6     Var cFornece   When lFecha  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA2") 
   @ C(097),C(032) MsGet    oGet7     Var cLojaFor   When lFecha  Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TrazForP() )
   @ C(097),C(051) MsGet    oGet8     Var cNomeFor   When lChumba Size C(137),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(118),C(005) MsGet    oGet14    Var cEndereco  When lFecha  Size C(011),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( VeEndereco() )
   @ C(118),C(094) MsGet    oGet9     Var cNCM       When lFecha  Size C(045),C(009) COLOR CLR_BLACK Picture "@R 9999.99.99" PIXEL OF oDlg
   @ C(140),C(005) MsGet    oGet12    Var cTributa   When lFecha  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("21") VALID( TrazTributa() )
   @ C(140),C(032) MsGet    oGet13    Var cNomeTri   When lChumba Size C(156),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(161),C(005) MsGet    oGet10    Var cOrigem    When lFecha  Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("S0") VALID( TrazOrigem() )
   @ C(161),C(025) MsGet    oGet11    Var cNomeOri   When lChumba Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(177),C(059) Button "Salvar" When lFecha Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaProduto() )

   @ C(177),C(098) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que salva os dados do produto selecionado
Static Function SalvaProduto()

   If Empty(Alltrim(cProduto))
      MsgAlert("Código do produto não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cGrupo))
      MsgAlert("Grupo do produto não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cBarras))
      MsgAlert("Código de Barras do produto não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cFornece)) 
      MsgAlert("Fornecedor padrão do produto não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cLojaFor)) 
      MsgAlert("Fornecedor padrão do produto não informado.")
      Return(.T.)
   Endif

   if Empty(Alltrim(Substr(cNcm,01,04)))
      MsgAlert("N C M do produto não informado.")
      Return(.T.)
   Endif

   if Empty(Alltrim(cOrigem))
      MsgAlert("Origem do produto não informado.")
      Return(.T.)
   Endif

   if Empty(Alltrim(cTributa))
      MsgAlert("Grupo Tributário do produto não informado.")
      Return(.T.)
   Endif

   If cEndereco <> "S" .And. cEndereco <> "N"
      MsgAlert("Controla Endereço está incorreto.")
      Return(.F.)
   Endif

   // Atualiza os dados no cadastro de produtos
   DbSelectArea("SB1")
   DbSetOrder(1)
   If DbSeek(xfilial("SB1") + cProduto)
      RecLock("SB1",.F.)
      SB1->B1_GRUPO   := cGrupo
      SB1->B1_CODBAR  := cBarras
      SB1->B1_PROC    := cFornece
      SB1->B1_LOJPROC := cLojaFor
      SB1->B1_LOCALIZ := cEndereco
      SB1->B1_POSIPI  := cNCM
      SB1->B1_GRTRIB  := cTributa
      SB1->B1_ORIGEM  := cOrigem
      MsUnLock()              
   Endif

   Limpaprod()

Return(.T.)

// Função que pesquisa os dados do produto informado
Static Function Buscaprod()

   Local cSql := ""

   If Empty(Alltrim(cProduto))
      MsgAlert("Necessário informar o código do produto a ser pesquisado.")
      Return(.T.)
   Endif   

   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf                                     

   cSql := ""
   cSql := "SELECT B1_COD    ,"
   cSql += "       B1_DESC   ,"
   cSql += "       B1_DAUX   ,"
   cSql += "       B1_GRUPO  ,"
   cSql += "       B1_CODBAR ,"
   cSql += "       B1_PROC   ,"
   cSql += "       B1_LOJPROC,"
   cSql += "       B1_LOCALIZ,"
   cSql += "       B1_POSIPI ,"
   cSql += "       B1_GRTRIB ,"
   cSql += "       B1_ORIGEM  "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD     = '" + Alltrim(cProduto) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If T_PRODUTO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif
      
   cDescricao := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
   cGrupo     := T_PRODUTO->B1_GRUPO
   cBarras    := T_PRODUTO->B1_CODBAR
   cFornece   := T_PRODUTO->B1_PROC
   cLojaFor   := T_PRODUTO->B1_LOJPROC
   cNcm       := T_PRODUTO->B1_POSIPI
   cTributa   := T_PRODUTO->B1_GRTRIB
   cOrigem    := T_PRODUTO->B1_ORIGEM
   cEndereco  := T_PRODUTO->B1_LOCALIZ
   cEndAnte   := T_PRODUTO->B1_LOCALIZ

   // Traz as descrições dos códigos da tela
   TrazGrupo()
   TrazForP() 
   TrazTributa() 
   TrazOrigem()

   lAbre  := .F.
   lFecha := .T.

Return(.T.)   

// Função que pesquisa os dados do produto informado
Static Function Limpaprod()

   aComboBx1  := {"", "S - Sim","N - Não"}

   cProduto   := Space(30)
   cDescricao := Space(60)
   cGrupo 	  := Space(04)
   cNomeGrupo := Space(40)
   cBarras    := Space(30)
   cFornece	  := Space(06)
   cLojaFor	  := Space(03)
   cNomeFor   := Space(40)
   cNCM  	  := Space(10)
   cOrigem 	  := Space(01)
   cNomeOri   := Space(40)
   cTributa   := Space(06)
   cNomeTri   := Space(40)
   cEndereco  := Space(01)
   cEndAnte   := Space(01)

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()
   oGet12:Refresh()
   oGet13:Refresh()
   oGet14:Refresh()

   lAbre  := .T.
   lFecha := .F.

Return(.T.)

// Função que pesquisa o nome do grupo do produto
Static Function TrazGrupo()

   Local cSql := ""

   If Empty(Alltrim(cGrupo))
      cNomeGrupo := ""
      Return(.T.)     
   Endif
      
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf                                     

   cSql := ""
   cSql := "SELECT BM_GRUPO  ,"
   cSql += "       BM_DESC    "
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE BM_GRUPO   = '" + Alltrim(cGrupo) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )
   
   If T_GRUPO->( EOF() )
      cNomeGrupo := ""
      Return(.T.)
   Else
      cNomeGrupo := T_GRUPO->BM_DESC
   Endif
   
Return(.T.)

// Função que pesquisa o nome da origem
Static Function TrazOrigem()

   Local cSql := ""

   If Empty(Alltrim(cOrigem))
      cNomeOri := ""
      Return(.T.)     
   Endif

   cNomeOri := TABELA("S0", cOrigem)
   
Return(.T.)

// Função que pesquisa o nome do Grupo de Tributação
Static Function TrazTributa()

   Local cSql := ""

   If Empty(Alltrim(cTributa))
      cNomeTri := ""
      Return(.T.)     
   Endif

   cNomeTri := TABELA("21", cTributa)
   
Return(.T.)

// Função que pesquisa o nome do Fornecedor Fabricante
Static Function TrazForP()

   Local cSql := ""

   If Empty(Alltrim(cFornece)) .and. Empty(Alltrim(cLojaFor))
      cNomeFor := ""
      Return(.T.)     
   Endif

   cNomeFor := Alltrim(Posicione("SA2",1,xFilial("SA2") + cFornece + cLojaFor, "A2_NOME"))
   
Return(.T.)

// Função que valida a resposta dada para o campo endereçamento
Static Function VeEndereco()

   Local cSql := ""

   If Empty(Alltrim(cEndereco))
      Return(.T.)
   Endif
   
   If cEndereco <> "S" .And. cEndereco <> "N"
      MsgAlert("Informação incorreta. Responda S/N.")
      Return(.F.)
   Endif

   // Verifica se pode ou não alterar de Sim para Não ou de Não para Sim o endereçamento do produto.
   If Select("T_SALDO") > 0
      T_SALDO->( dbCloseArea() )
   EndIf                                     

   cSql := ""
   cSql := "SELECT SUM(B2_QATU) AS SALDO "
   cSql += "  FROM " + RetSqlName("SB2")
   cSql += " WHERE B2_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND B2_COD     = '" + Alltrim(cProduto) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDO", .T., .T. )
   
   If T_SALDO->( EOF() )
      Return(.T.)
   Endif
   
   If T_SALDO->SALDO == 0
      Return(.T.)
   Endif
      
   If Alltrim(cEndereco) == Alltrim(cEndAnte)
      Return(.T.)
   Endif

   If T_SALDO->SALDO <> 0
      MsgAlert("Alteração não permitida. Produto possui saldo.")
      cEndereco := cEndAnte
      Return(.T.)
   Endif

Return(.T.)  