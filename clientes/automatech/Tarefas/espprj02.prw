#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRJ02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/09/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Projetos                      *
//**********************************************************************************

User Function ESPPRJ02(_Operacao, _Codigo)

   Local lChumba      := .F.

   Private cCodigo	  := _Codigo
   Private cCliente	  := Space(06)
   Private cLoja	  := Space(03)
   Private cNomeCli	  := Space(40)
   Private cTitulo	  := Space(40)
   Private cApelido   := Space(40)
   Private cDescricao := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oMemo1

   Private oDlg

   If _Operacao <> "I"

      If Select("T_PROJETO") > 0
         T_PROJETO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZY_CODIGO,"  
      cSql += "       A.ZZY_CLIENT,"  
      cSql += "       A.ZZY_LOJA  ,"  
      cSql += "       A.ZZY_TITULO,"        
      cSql += "       A.ZZY_CHAVE ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZY_DESC)) AS DESCRICAO, "
      cSql += "       B.A1_NOME    "
      cSql += "  FROM " + RetSqlName("ZZY") + " A, "
      cSql += "       " + RetSqlName("SA1") + " B  "
      cSql += " WHERE A.ZZY_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND A.ZZY_DELETE = ''"
      cSql += "   AND A.ZZY_CLIENT = B.A1_COD "
      cSql += "   AND A.ZZY_LOJA   = B.A1_LOJA"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

      cCliente	 := T_PROJETO->ZZY_CLIENT
      cLoja	     := T_PROJETO->ZZY_LOJA
      cNomeCli	 := T_PROJETO->A1_NOME
      cTitulo	 := T_PROJETO->ZZY_TITULO
      cDescricao := T_PROJETO->DESCRICAO
      cApelido   := T_PROJETO->ZZY_CHAVE
                                       
   Endif

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Projetos" FROM C(178),C(181) TO C(472),C(679) PIXEL

   @ C(006),C(006) Say "Código"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(020),C(006) Say "Cliente"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(034),C(006) Say "Título"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(006) Say "Apelido"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(006) Say "Descrição do Projeto" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(006),C(028) MsGet oGet1  Var cCodigo    When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(019),C(028) MsGet oGet2  Var cCliente   F3("SA1")    Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(TRAZCLIE(cCliente, cLoja))
   @ C(019),C(055) MsGet oGet3  Var cLoja                   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(TRAZCLIE(cCliente, cLoja))
   @ C(019),C(074) MsGet oGet4  Var cNomeCli   When lChumba Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(033),C(028) MsGet oGet5  Var cTitulo                 Size C(217),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(047),C(028) MsGet oGet6  Var cApelido                Size C(109),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(071),C(006) GET   oMemo1 Var cDescricao MEMO         Size C(238),C(056) PIXEL OF oDlg

   @ C(130),C(168) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaProjeto( _Operacao, cCodigo, cCliente, cLoja, cTitulo, cDescricao, cApelido) )
   @ C(130),C(207) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o cliente informado
Static Function TRAZCLIE(_Cliente, _Loja)

   If Empty(Alltrim(_Cliente))
      _Cliente := Space(06)
      _Loja    := Space(02)
      cNomeCli := Space(40)
      Return .T.
   Endif
      
   If !Empty(Alltrim(_Cliente)) .And. Empty(Alltrim(_Loja))
      _Cliente := Space(06)
      _Loja    := Space(02)
      cNomeCli := Space(40)
      Return .T.
   Endif

   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME"
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(_Loja)    + "'"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( eof() )
      msgalert("Cliente informado não cadastrado.")
      _Cliente := Space(06)
      _Loja    := Space(02)
      cNomeCli := Space(40)
      Return .T.
   Else
      cNomeCli := T_CLIENTE->A1_NOME
   Endif
   
Return .T.   

// Função que realiza a gravação dos dados
Static Function _SalvaProjeto(_Operacao, _Codigo, _Cliente, _Loja, _Titulo, _Descricao, _Apelido)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Cliente))
         MsgAlert("Cliente não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Loja))
         MsgAlert("Loja do Cliente não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Titulo))
         MsgAlert("Título do Projeto não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descrição do Projeto não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Apelido))
         MsgAlert("Apelido do Projeto não informado. Verique !!")
         Return .T.
      Endif   

      // Pesquisa se já existe o projeto a ser incluído
      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZY_CODIGO"  
      cSql += "  FROM " + RetSqlName("ZZY")
      cSql += " WHERE ZZY_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZZY_DELETE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Código de Projeto já cadastrado. Verique!!")
         Return .T.
      Endif

      // Verifica se o apelido já foi utilizado anteriormente
      If Select("T_APELIDO") > 0
         T_APELIDO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZY_CODIGO"  
      cSql += "  FROM " + RetSqlName("ZZY")
      cSql += " WHERE ZZY_CHAVE  = '" + Alltrim(_Apelido) + "'"
      cSql += "   AND ZZY_DELETE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APELIDO", .T., .T. )

      If T_APELIDO->( EOF() )
      Else
         MsgAlert("Atenção! Apelido já utilizado no Projeto: " + Alltrim(T_APELIDO->ZZY_CODIGO))
         Return .T.
      Endif

      // Pesquisa o próximo código para inclusão 
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZY_CODIGO"  
      cSql += "  FROM " + RetSqlName("ZZY")
      cSql += "  ORDER BY ZZY_CODIGO DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )
   
      If T_PROXIMO->( EOF() )
         _Codigo := "000001"
      Else
         _Codigo := STRZERO((INT(VAL(T_PROXIMO->ZZY_CODIGO)) + 1),6)
      Endif
         
      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZY")
      RecLock("ZZY",.T.)
      ZZY_FILIAL := cFilAnt
      ZZY_CODIGO := _Codigo
      ZZY_CLIENT := _Cliente
      ZZY_LOJA   := _Loja
      ZZY_TITULO := _Titulo
      ZZY_DESC   := _Descricao
      ZZY_CHAVE  := _Apelido
      ZZY_DELETE := ""
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      If Empty(Alltrim(_Codigo))
         MsgAlert("Código não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Cliente))
         MsgAlert("Cliente não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Loja))
         MsgAlert("Loja do Cliente não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Titulo))
         MsgAlert("Título do Projeto não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descrição do Projeto não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Apelido))
         MsgAlert("Apelido do Projeto não informado. Verique !!")
         Return .T.
      Endif   

      // Verifica se o apelido já foi utilizado anteriormente
      If Select("T_APELIDO") > 0
         T_APELIDO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZY_CODIGO"  
      cSql += "  FROM " + RetSqlName("ZZY")
      cSql += " WHERE ZZY_CHAVE   = '" + Alltrim(_Apelido) + "'"
      cSql += "   AND ZZY_CODIGO <> '" + Alltrim(_Codigo)  + "'"
      cSql += "   AND ZZY_DELETE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APELIDO", .T., .T. )

      If T_APELIDO->( EOF() )
      Else
         MsgAlert("Atenção! Apelido já utilizado no Projeto: " + Alltrim(T_APELIDO->ZZY_CODIGO))
         Return .T.
      Endif

      aArea := GetArea()

      DbSelectArea("ZZY")
      DbSetOrder(1)
      If DbSeek(cFilAnt + _Codigo)
         RecLock("ZZY",.F.)
         ZZY_CLIENT := _Cliente
         ZZY_LOJA   := _Loja
         ZZY_TITULO := _Titulo
         ZZY_DESC   := _Descricao
         ZZY_CHAVE  := _Apelido
         ZZY_DELETE := ""
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZY")
         DbSetOrder(1)
         If DbSeek(cFilAnt + _Codigo)
            RecLock("ZZY",.F.)
            ZZY_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil