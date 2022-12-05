#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPBCO01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/05/2012                                                          *
// Objetivo..: Banco de Conhecimento - Atualização Sistema Protheus                *
//**********************************************************************************

User Function ESPBCO01()   

   Local cSql      := ""

   Private aBrowse := {}
   Private oDlg

   aBrowse := {}

   // Carrega o grid com os dados do Banco de Conhecimento
   If Select("T_BANCO") > 0
	  T_BANCO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZK_CODI,"
   cSql += "       ZZK_NOME "
   cSql += "  FROM " + RetSqlName("ZZK")
   cSql += " WHERE ZZK_DELE <> 'X'"
   cSql += " ORDER BY ZZK_CODI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANCO", .T., .T. )

   If T_BANCO->( EOF() )
      aAdd(aBrowse, { '', '' } )
   Else
      T_BANCO->( DbGoTop() )
      WHILE !T_BANCO->( EOF() )
         aAdd( aBrowse, { T_BANCO->ZZK_CODI, T_BANCO->ZZK_NOME } )
         T_BANCO->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlg TITLE "Banco de Conhecimento - Atualização Sistema Protheus" FROM C(178),C(181) TO C(581),C(834) PIXEL

   @ C(004),C(004) Say "A finalidade deste Banco de Conhecimento é permitir que se deixe registrado toda e qualquer observação que se faça necessário sempre que for feita uma atualização"  Size C(319),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(012),C(004) Say "geral do sistema Protheus. Após a atuliação,deverá ser executado ou parametrizado os procedimentos aqui relacionados."                       Size C(311),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(184),C(165) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION ( CONHECIMENTO("I", "") )
   @ C(184),C(204) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION ( CONHECIMENTO("A", aBrowse[oBrowse:nAt,01]) )
   @ C(184),C(244) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION ( CONHECIMENTO("E", aBrowse[oBrowse:nAt,01]) )
   @ C(184),C(283) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 025 , 004, 410, 205,,{'Código', 'Descrição dos Apontamentos' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse)
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a janela de digitação dos dados do Banco de Conhecimento
Static Function Conhecimento( _Operacao, _Codigo)

   Local   lChumba    := .F. 
   Local   cSql       := ""

   Private cCodigo    := Space(006)
   Private cDescricao := Space(100)
   Private cAponta    := ""
   
   Private oGet1
   Private oGet2
   Private oMemo1

   Private cChaveNota := ""

   Private oDlgx

   // Em caso de alteração ou exclusão, pesquisa os dados para display
   If _Operacao == "I"
   Else
      If Select("T_BANCO") > 0
         T_BANCO->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZZK_CODI,"
      cSql += "       ZZK_NOME,"
      cSql += "       ZZK_NOT1,"
      cSql += "       ZZK_NOT2 "
      cSql += "  FROM " + RetSqlName("ZZK")
      cSql += " WHERE ZZK_CODI = '" + Alltrim(_codigo) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANCO", .T., .T. )
      
      cCodigo    := T_BANCO->ZZK_CODI
      cDescricao := T_BANCO->ZZK_NOME
      cChaveNota := T_BANCO->ZZK_NOT2
      
      // Pesquisa o apontamento do Banco de Conhecimento
      If Select("T_APONTA") > 0
         T_APONTA->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT YP_TEXTO"
      cSql += "  FROM " + RetSqlName("SYP")
      cSql += " WHERE YP_CHAVE = '" + Alltrim(cChaveNota) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTA", .T., .T. )

      If T_APONTA->( EOF() )
         cAponta := ""
      Else
         cAponta := ""
         T_APONTA->( DbGoTop() )
         WHILE !T_APONTA->( EOF() )
            cAponta := cAponta + Alltrim(STRTRAN(T_APONTA->YP_TEXTO, "\13\10", chr(13) + chr(10)))
            T_APONTA->( DbSkip() )
         ENDDO
      Endif
   Endif

   DEFINE MSDIALOG oDlgx TITLE "Banco de Conhecimento - Atualização Sistema Protheus" FROM C(178),C(181) TO C(465),C(737) PIXEL

   @ C(003),C(005) Say "Código"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(003),C(034) Say "Descrição do Apontamento" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(025),C(005) Say "Detalhe do Apontamento"   Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgx

   @ C(013),C(005) MsGet oGet1 Var cCodigo     When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(013),C(034) MsGet oGet2 Var cDescricao  Size C(237),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(035),C(005) GET oMemo1 Var cAponta MEMO Size C(266),C(089) PIXEL OF oDlgx

   @ C(127),C(195) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgx ACTION ( SalvaBco(_Operacao, cCodigo, cChaveNota) )
   @ C(127),C(234) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgx ACTION ( oDlgx:End() )

   ACTIVATE MSDIALOG oDlgx CENTERED 

Return(.T.)

// Função que grava os dados informados
Static Function SalvaBco( _TipoSalva, _Codigo, _Chave)

   Local cSql := ""

   // Operação de Inclusão
   If _TipoSalva == "I"

      If Empty(Alltrim(cDescricao))
         MsgAlert("Descrição do Apontamento não informado. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o Próximo número para inclusão
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZK_CODI "
      cSql += "  FROM " + RetSqlName("ZZK")
//    cSql += " WHERE ZZK_DELE = ''"
      cSql += " ORDER BY ZZK_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

      If T_NOVO->( EOF() )
         cCodigo := '000001'
      Else
         cCodigo := Strzero((INT(VAL(T_NOVO->ZZK_CODI)) + 1),6)      
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZK")
      RecLock("ZZK",.T.)
      ZZK_CODI := cCodigo
      ZZK_NOME := cDescricao
      MsUnLock()

      // Grava o campo memo da Descrição do Apontamento do Banco de Conhecimento
      MSMM(,80,,cAponta,1,,,"ZZK","ZZK_NOT2")

      MsgAlert("Apontamento gravado com o codigo: " + Alltrim(cCodigo))

   Endif

   // Operação de Alteração
   If _TipoSalva == "A"

      aArea := GetArea()

      DbSelectArea("ZZK")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZK") + _Codigo)
         RecLock("ZZK",.F.)

         ZZK_CODI := _Codigo
         ZZG_NOME := cDescricao
   
         // Grava o campo memo da Descrição da Solução
         MSMM(,80,,cAponta,1,,,"ZZK","ZZK_NOT2")

         MsUnLock()              
      Endif

   Endif

   // Operação de Exclusão
   If _TipoSalva == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZK")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZK") + _Codigo)
            RecLock("ZZK",.F.)
            ZZK_DELE := "X"
            MsUnLock()              
         Endif

         // Elimina da tabela SYP os dados do Campo Texto
         dbSelectArea("SYP")
         dbSeek(xFilial("SYP")+_Chave)
         If found()
            While SYP->YP_CHAVE==_Chave
               Reclock("SYP",.F.)
               dbDelete()
               MsUnlock()
               dbSkip()
            Enddo
         Endif

      Endif   

   Endif

   ODlgx:End()

   aBrowse := {}

   // Carrega o grid com os dados do Banco de Conhecimento
   If Select("T_BANCO") > 0
	  T_BANCO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZK_CODI,"
   cSql += "       ZZK_NOME "
   cSql += "  FROM " + RetSqlName("ZZK")
   cSql += " WHERE ZZK_DELE <> 'X'"
   cSql += " ORDER BY ZZK_CODI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANCO", .T., .T. )

   If T_BANCO->( EOF() )
      aAdd(aBrowse, { '', '' } )
   Else
      T_BANCO->( DbGoTop() )
      WHILE !T_BANCO->( EOF() )
         aAdd( aBrowse, { T_BANCO->ZZK_CODI, T_BANCO->ZZK_NOME } )
         T_BANCO->( DbSkip() )
      ENDDO
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse)
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }

Return Nil