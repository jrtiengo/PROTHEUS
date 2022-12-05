#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRJ02.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 26/09/2012                                                          *
// Objetivo..: Programa de Manuten��o do Cadastro de Projetos                      *
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

   @ C(006),C(006) Say "C�digo"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(020),C(006) Say "Cliente"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(034),C(006) Say "T�tulo"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(006) Say "Apelido"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(006) Say "Descri��o do Projeto" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlg

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

// Fun��o que pesquisa o cliente informado
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
      msgalert("Cliente informado n�o cadastrado.")
      _Cliente := Space(06)
      _Loja    := Space(02)
      cNomeCli := Space(40)
      Return .T.
   Else
      cNomeCli := T_CLIENTE->A1_NOME
   Endif
   
Return .T.   

// Fun��o que realiza a grava��o dos dados
Static Function _SalvaProjeto(_Operacao, _Codigo, _Cliente, _Loja, _Titulo, _Descricao, _Apelido)

   Local cSql := ""

   // Opera��o de Inclus�o
   If _Operacao == "I"

      If Empty(Alltrim(_Cliente))
         MsgAlert("Cliente n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Loja))
         MsgAlert("Loja do Cliente n�o informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Titulo))
         MsgAlert("T�tulo do Projeto n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descri��o do Projeto n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Apelido))
         MsgAlert("Apelido do Projeto n�o informado. Verique !!")
         Return .T.
      Endif   

      // Pesquisa se j� existe o projeto a ser inclu�do
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
         MsgAlert("C�digo de Projeto j� cadastrado. Verique!!")
         Return .T.
      Endif

      // Verifica se o apelido j� foi utilizado anteriormente
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
         MsgAlert("Aten��o! Apelido j� utilizado no Projeto: " + Alltrim(T_APELIDO->ZZY_CODIGO))
         Return .T.
      Endif

      // Pesquisa o pr�ximo c�digo para inclus�o 
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

   // Opera��o de Altera��o
   If _Operacao == "A"

      If Empty(Alltrim(_Codigo))
         MsgAlert("C�digo n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Cliente))
         MsgAlert("Cliente n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Loja))
         MsgAlert("Loja do Cliente n�o informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Titulo))
         MsgAlert("T�tulo do Projeto n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descri��o do Projeto n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Apelido))
         MsgAlert("Apelido do Projeto n�o informado. Verique !!")
         Return .T.
      Endif   

      // Verifica se o apelido j� foi utilizado anteriormente
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
         MsgAlert("Aten��o! Apelido j� utilizado no Projeto: " + Alltrim(T_APELIDO->ZZY_CODIGO))
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

   // Opera��o de Exclus�o
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclus�o deste registro?")

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