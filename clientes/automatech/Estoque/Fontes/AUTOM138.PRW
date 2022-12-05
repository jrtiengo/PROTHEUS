#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM138.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/10/2012                                                          *
// Objetivo..: Programa que abre janela de informação das exceções das comissões   *
//             do Cadastro de Grupo de Produtos.                                   *
// Parâmetros: BM_GRUPO -> Código do Grupo de Produtos                             *
//             BM_DESC  -> Descrição do Grupo de Produtos                          *
//             BM_COMIS -> % Padrão de Comissão da Grupo de Produtos               *
//**********************************************************************************

User Function AUTOM138(_Grupo, _Descricao, _Comissao)

   Local lChumba     := .F.

   Private cGrupo    := _Grupo
   Private cNome     := _Descricao
   Private cComissao := _Comissao

   Private aBrowse   := {}
   
   Private oGet1
   Private oGet2
   Private oGet3

   U_AUTOM628("AUTOM138")

   // Pesquisa as exceções para o grupo selecionado
   If Select("T_COMISSAO") > 0
      T_COMISSAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZ5_GRUPO , "
   cSql += "       A.ZZ5_PRODUT, "
   cSql += "       B.B1_DESC   , "
   cSql += "       B.B1_DAUX   , "
   cSql += "       A.ZZ5_COMIS   "
   cSql += "  FROM " + RetSqlName("ZZ5") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.ZZ5_GRUPO  = '" + Alltrim(_Grupo)   + "'"
   cSql += "   AND A.ZZ5_DELETE = ''"
   cSql += "   AND A.ZZ5_PRODUT = B.B1_COD"
   cSql += " ORDER BY A.ZZ5_PRODUT  "
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )
   
   T_COMISSAO->( DbGoTop() )
      
   WHILE !T_COMISSAO->( EOF() )
      aAdd( aBrowse, { T_COMISSAO->ZZ5_PRODUT,;
                       Alltrim(T_COMISSAO->B1_DESC) + " " + Alltrim(T_COMISSAO->B1_DAUX),;
                       T_COMISSAO->ZZ5_COMIS } )
      T_COMISSAO->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { '','','' } )
   Endif

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Exceções de Comissões por Grupo de Produtos" FROM C(178),C(181) TO C(481),C(719) PIXEL

   @ C(005),C(005) Say "Grupo"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(030) Say "Descrição do Grupo de Produtos" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(220) Say "Comissão Padrão(%)"             Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Relação de Produtos do referido grupo de produtos com exceção na Comissão" Size C(203),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(015),C(005) MsGet oGet1 Var cGrupo    Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(015),C(029) MsGet oGet2 Var cNome     Size C(185),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(015),C(230) MsGet oGet3 Var cComissao Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(135),C(107) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION(OperacaoCom("I", _Grupo, _Descricao, Space(06), Space(60), 0) )
   @ C(135),C(147) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION(OperacaoCom("A", _Grupo, _Descricao, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]))
   @ C(135),C(187) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION(OperacaoCom("E", _Grupo, _Descricao, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]))
   @ C(135),C(227) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 045 , 005, 330, 120,,{'Código', 'Descrição dos Produtos', '% Comissao'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                       } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza as opreções da tela de exceções de comissões para o grupo de produtos
Static Function OperacaoCom(_Operacao, _Grupo, _Ngrupo, _Codigo, _Produto, _Percentual)
                      
   Local lFechar   := .F.

   Private xGrupo    := _Grupo
   Private xNgrupo   := _nGrupo
   Private xProduto  := _Codigo
   Private xNproduto := _Produto
   Private xComissao := _Percentual

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlgX

   DEFINE MSDIALOG oDlgX TITLE "Cadastro de Exceção de COmissão para Grupo de Produto" FROM C(178),C(181) TO C(366),C(563) PIXEL

   @ C(005),C(005) Say "Grupo"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(005),C(036) Say "Descrição do Grupo de Produto" Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(028),C(005) Say "Produto"                       Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(028),C(036) Say "Descrição do Produto"          Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(054),C(037) Say "% Comissão para o Produto"     Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   
   @ C(015),C(005) MsGet oGet1 Var xGrupo              Size C(025),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgX When lFechar
   @ C(015),C(036) MsGet oGet2 Var xNgrupo             Size C(148),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgX When lFechar
   @ C(037),C(005) MsGet oGet3 Var xProduto  F3("SB1") Size C(025),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgX VALID ( _PsqProduto(xProduto, xGrupo) )
   @ C(037),C(036) MsGet oGet4 Var xNproduto           Size C(148),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgX When lFechar
   @ C(053),C(105) MsGet oGet5 Var xComissao           Size C(023),C(009) COLOR CLR_BLACK Picture "999.99" PIXEL OF oDlgX

   @ C(076),C(106) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgX ACTION( SalvaExcecao(_Operacao, xGrupo, xProduto, xComissao) )
   @ C(076),C(147) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que pesquisa o nome do produto informado
Static Function _PsqProduto(__Codigo, __Grupo)

   Local cSql := ""
   
   If Empty(Alltrim(__Codigo))
      xProduto  := Space(20)
      xNProduto := Space(60)
      Return .T.
   Endif
     
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD , "
   cSql += "       B1_DESC, "
   cSql += "       B1_DAUX, "
   cSql += "       B1_GRUPO "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD     = '" + Alltrim(__Codigo) + "'"
   cSql += "   AND B1_GRUPO   = '" + Alltrim(__Grupo)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )
   
   If T_PRODUTO->( EOF() )
      MsgAlert("Produto inexistente ou não pertence ao grupo selecionado. Verifique !")
      xProduto  := Space(20)
      xNproduto := Space(60)
   Else
      xNproduto := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
   Endif

Return(.T.)

// Função que realiza a gravação das Exceções de Comissões por Grupo de Produtos
Static Function SalvaExcecao(_Operacao, xGrupo, xProduto, xComissao)

   Local cSql := ""

   If Empty(Alltrim(xGrupo))
      MsgAlert("Grupo de Produto não selecionado.")
      Return .T.
   Endif
   
   If Empty(Alltrim(xProduto))
      MsgAlert("Produto não informado.")
      Return .T.
   Endif
   
   If xComissao == 0
      MsgAlert("Comissão não informada.")
      Return .T.
   Endif

   // Operação de Inclusão
   If _Operacao == "I"

      // Verifica se o produto do grupo já está cadastrado na tabela ZZ5010
	      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZ5_GRUPO , "
      cSql += "       ZZ5_PRODUT, "
      cSql += "       ZZ5_COMIS   "
      cSql += "  FROM " + RetSqlName("ZZ5")
      cSql += " WHERE ZZ5_GRUPO  = '" + Alltrim(xGrupo)   + "'"
      cSql += "   AND ZZ5_PRODUT = '" + Alltrim(xProduto) + "'"
      cSql += "   AND ZZ5_DELETE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Produto já cadatsrado na exceção. Verifique !")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZ5")
      RecLock("ZZ5",.T.)
      ZZ5_FILIAL := cFilAnt
      ZZ5_GRUPO  := xGrupo
      ZZ5_PRODUT := xProduto
      ZZ5_COMIS  := xComissao
      ZZ5_DELETE := "" 
      MsUnLock()

   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZ5")
      DbSetOrder(1)
      If DbSeek(cFilAnt + xGrupo + xProduto)
         RecLock("ZZ5",.F.)
         ZZ5_COMIS := xComissao
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZ5")
         DbSetOrder(1)
         If DbSeek(cFilAnt + xGrupo + xProduto)
            RecLock("ZZ5",.F.)
            ZZ5_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   // Pesquisa as exceções para o grupo selecionado
   If Select("T_COMISSAO") > 0
      T_COMISSAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZ5_GRUPO , "
   cSql += "       A.ZZ5_PRODUT, "
   cSql += "       B.B1_DESC   , "
   cSql += "       B.B1_DAUX   , "
   cSql += "       A.ZZ5_COMIS   "
   cSql += "  FROM " + RetSqlName("ZZ5") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.ZZ5_GRUPO  = '" + Alltrim(xGrupo)   + "'"
   cSql += "   AND A.ZZ5_DELETE = ''"
   cSql += "   AND A.ZZ5_PRODUT = B.B1_COD"
   cSql += " ORDER BY A.ZZ5_PRODUT  "
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )
   
   aBrowse := {}

   T_COMISSAO->( DbGoTop() )
      
   WHILE !T_COMISSAO->( EOF() )
      aAdd( aBrowse, { T_COMISSAO->ZZ5_PRODUT,;
                       Alltrim(T_COMISSAO->B1_DESC) + " " + Alltrim(T_COMISSAO->B1_DAUX),;
                       T_COMISSAO->ZZ5_COMIS } )
      T_COMISSAO->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { '','','' } )
   Endif

   ODlgX:End()

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                       } }

Return Nil
