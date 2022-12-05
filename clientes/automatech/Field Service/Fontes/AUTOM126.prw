#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM126.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/07/2012                                                          *
// Objetivo..: Programa que ealiza pesquisa de preço por produto verificando se    *
//             produto está contido em um atabela de preço.                        *
// Parâmetros: Sem parãmetros                                                      *
//**********************************************************************************

// Função que define a Window
User Function AUTOM126()

   Local cSql        := ""
   Local lChumba     := .F.

   Private cCodigo   := Space(06)
   Private cProduto  := Space(60)
   Private cTabela   := Space(03)
   Private cDataI    := Ctod("  /  /    ")
   Private cDataF    := Ctod("  /  /    ")
   Private cMoeda    := 0
   Private cNmoeda   := Space(40)
   Private cTaxa	   := 0
   Private cReal     := 0
   Private cDolar    := 0
   Private cCadastro := 0

   Private aTabela	 := {}
   Private cComboBx1

   Private cMemo1	   := ""
   Private cMemo2	   := ""
   
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

   Private oDlg

   // Carrega o combo de Tabela de Preços
   If Select("T_TABELA") > 0
      T_TABELA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA0_CODTAB,"
   cSql += "       DA0_DESCRI"
   cSql += "  FROM " + RetSqlName("DA0")
   cSql += " WHERE DA0_ATIVO  = '1'"  
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += " ORDER BY DA0_CODTAB   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

   WHILE !T_TABELA->( EOF() )
      aAdd( aTabela, T_TABELA->DA0_CODTAB + " - " + T_TABELA->DA0_DESCRI )
      T_TABELA->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Pesquisa Preço de Produtos" FROM C(178),C(181) TO C(478),C(605) PIXEL

   @ C(004),C(005) Say "Produto"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(035) Say "Tabela de Preço"        Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(044),C(035) Say "Vigência de"            Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(044),C(119) Say "Até"                    Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(035) Say "Moeda"                  Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(072),C(035) Say "Taxa Moeda 2"           Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(092),C(035) Say "Valor em R$"            Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(092),C(115) Say "Valor em U$"            Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(115),C(062) Say "Preço do Cadastro (R$)" Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(014),C(005) MsGet oGet1  Var cCodigo                  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( TRAZNPRO(cCodigo) )
   @ C(014),C(035) MsGet oGet2  Var cProduto    When lChumba Size C(169),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
// @ C(029),C(079) MsGet oGet3  Var cTabela     When lChumba Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(028),C(079) ComboBox cComboBx1 Items aTabela Size C(126),C(010) PIXEL OF oDlg

   @ C(043),C(079) MsGet oGet4  Var cDataI      When lChumba Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(133) MsGet oGet5  Var cDataF      When lChumba Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(057),C(079) MsGet oGet6  Var cMoeda      When lChumba Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(057),C(095) MsGet oGet7  Var cNmoeda     When lChumba Size C(073),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(071),C(079) MsGet oGet8  Var cTaxa       When lChumba Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(084),C(035) GET oMemo1   Var cMemo1 MEMO When lChumba Size C(169),C(001) PIXEL OF oDlg
   @ C(091),C(069) MsGet oGet9  Var cReal       When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
   @ C(091),C(150) MsGet oGet10 Var cDolar      When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
   @ C(106),C(035) GET oMemo2   Var cMemo2 MEMO When lChumba Size C(169),C(001) PIXEL OF oDlg
// @ C(114),C(112) MsGet oGet11 Var cCadastro   When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg

   @ C(132),C(069) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PEGAPRECOPRD() )
   @ C(132),C(108) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o nome do produto a ser pesquisado
Static Function TRAZNPRO(cCodigo)

   Local cSql := ""
   
   If Empty(Alltrim(cCodigo))
      Return(.T.)
   Endif

   cProduto  := Space(60)
   cDataI    := Ctod("  /  /    ")
   cDataF    := Ctod("  /  /    ")
   cMoeda    := 0
   cNmoeda   := Space(40)
   cTaxa	 := 0
   cReal     := 0
   cDolar    := 0
   cCadastro := 0

   oGet2:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()

   // Pesquisa a descrição do produto informado/pesquisado
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD , "
   cSql += "       B1_DESC, "
   cSql += "       B1_DAUX  "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD = '" + Alltrim(cCodigo) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If !T_PRODUTO->( Eof() )
      cProduto := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
   Else
      cProduto := ""
   Endif

   If Empty(Alltrim(cProduto))
      Msgalert("Produto informado inexistente.")
      Return .T.
   Endif

Return(.T.)

// Função que pesquisa o preço conforme tabela de preço informada
Static Function PEGAPRECOPRD()

   Local cSql := ""
   
   If Empty(Alltrim(cCodigo))
      cProduto := ""
      Return(.T.)
   Endif
   
   // Verifica se o produto informado está em alguma tabela de preço
   If Select("T_TABELA") > 0
      T_TABELA->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.DA1_CODTAB,"
   cSql += "       A.DA1_CODPRO,"
   cSql += "       A.DA1_MOEDA ,"
   cSql += "       A.DA1_PRCVEN,"
   cSql += "       B.DA0_DATDE ,"
   cSql += "       B.DA0_DATATE,"
   cSql += "       B.DA0_ATIVO ,"
   cSql += "       C.B1_UPRC    "
   cSql += "  FROM " + RetSqlName("DA1") + " A, "
   cSql += "       " + RetSqlName("DA0") + " B, "
   cSql += "       " + RetSqlName("SB1") + " C  "
   cSql += " WHERE B.DA0_CODTAB = '" + Substr(cComboBx1,01,03) + "'"	
   cSql += "   AND A.DA1_CODPRO = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND A.D_E_L_E_T_ = '' "
   cSql += "   AND A.DA1_CODTAB = B.DA0_CODTAB"
   cSql += "   AND B.DA0_ATIVO  = '1'"
   cSql += "   AND B.D_E_L_E_T_ = '' "
   cSql += "   AND A.DA1_CODPRO = C.B1_COD"
// cSql += "   AND '20120723' BETWEEN B.DA0_DATDE AND B.DA0_DATATE"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )
   
   cDataI    := Ctod("  /  /    ")
   cDataF    := Ctod("  /  /    ")
   cMoeda    := 0
   cNmoeda   := Space(40)
   cTaxa	 := 0
   cReal     := 0
   cDolar    := 0
   cCadastro := 0

   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()

   If !T_TABELA->( EOF() )

      cTabela   := T_TABELA->DA1_CODTAB
      cDataI    := Substr(T_TABELA->DA0_DATDE,07,02)  + "/" + Substr(T_TABELA->DA0_DATDE,05,02)  + "/" + Substr(T_TABELA->DA0_DATDE,01,04)
      cDataF    := Substr(T_TABELA->DA0_DATATE,07,02) + "/" + Substr(T_TABELA->DA0_DATATE,05,02) + "/" + Substr(T_TABELA->DA0_DATATE,01,04)
      cMoeda    := T_TABELA->DA1_MOEDA
      cNmoeda   := Iif(T_TABELA->DA1_MOEDA == 1, "REAL", "DOLAR")

      If T_TABELA->DA1_MOEDA == 1
         cTaxa	:= 0
         cReal  := T_TABELA->DA1_PRCVEN
         cDolar := 0                   
      Else
         cTaxa	:= 0
         cReal  := 0
         cDolar := T_TABELA->DA1_PRCVEN                   
      Endif

      cCadastro := T_TABELA->B1_UPRC

      // Pesquisa a taxa da moeda 2 para a data atual
      If Select("T_TAXA") > 0
         T_TAXA->( dbCloseArea() )
      EndIf

      cSql := ""      
      cSql := "SELECT M2_MOEDA2"
      cSql += "  FROM " + RetSqlName("SM2")
      cSql += " WHERE M2_DATA    = '" + Dtos(Date()) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAXA", .T., .T. )

      If T_TAXA->( EOF() )
         cTaxa := 0
      Else
         cTaxa := T_TAXA->M2_MOEDA2   
      Endif

      If T_TABELA->DA1_MOEDA == 1
         If ctaxa <> 0
            cDolar := T_TABELA->DA1_PRCVEN / cTaxa
         Endif
      Else
         If ctaxa <> 0
            cReal := T_TABELA->DA1_PRCVEN * cTaxa            
         Endif
      Endif

   Else
      
      If Select("T_TABELA") > 0
         T_TABELA->( dbCloseArea() )
      EndIf

      cSql := "SELECT B1_UPRC "
      cSql += "  FROM " + RetSqlName("SB1")
      cSql += " WHERE B1_COD = '" + Alltrim(cCodigo) + "'"
      cSql += "   AND D_E_L_E_T_ = '' "
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

      If !T_TABELA->( EOF() )
         cCadastro := T_TABELA->B1_UPRC
      Else
         cCadastro := 0
      Endif
      
   Endif

Return .T.