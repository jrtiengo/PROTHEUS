#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPNEW02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/04/2013                                                          *
// Objetivo..: Programa de Manutenção do Automatech News                           *
//**********************************************************************************

User Function ESPNEW02(_Operacao, _Codigo, _Descricao)

   Private cCodigo := Space(06)
   Private cNome   := Space(100)
   Private cDataI  := Ctod("  /  /    ")
   Private cDataF  := Ctod("  /  /    ")
   Private cHoraI  := Space(10)
   Private cHoraF  := Space(10)
   Private cTexto  := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oMemo1

   Private oDlg

   If _Operacao <> "I"

      If Select("T_AUTOMATECH") > 0
         T_AUTOMATECH->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZ9_CODI  , "
      cSql += "       ZZ9_NOME  , "
      cSql += "       ZZ9_TEXT  , "
      cSql += "       ZZ9_DATI  , "
      cSql += "       ZZ9_DATF  , "
      csql += "       ZZ9_HORI  , "
      csql += "       ZZ9_HORF  , "
      csql += "       ZZ9_USUA  , "
      csql += "       ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),ZZ9_TEXT)),'') AS TEXTO,"
      csql += "       ZZ9_DELE    "
      cSql += "  FROM " + RetSqlName("ZZ9")
      cSql += " WHERE ZZ9_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZZ9_DELE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AUTOMATECH", .T., .T. )

      cCodigo  := T_AUTOMATECH->ZZ9_CODI
      cNome	   := T_AUTOMATECH->ZZ9_NOME
      cDataI   := Ctod(Substr(T_AUTOMATECH->ZZ9_DATI,07,02) + "/" + Substr(T_AUTOMATECH->ZZ9_DATI,05,02) + "/"  + Substr(T_AUTOMATECH->ZZ9_DATI,01,04))
      cDataF   := Ctod(Substr(T_AUTOMATECH->ZZ9_DATF,07,02) + "/" + Substr(T_AUTOMATECH->ZZ9_DATF,05,02) + "/"  + Substr(T_AUTOMATECH->ZZ9_DATF,01,04))
      cHoraI   := T_AUTOMATECH->ZZ9_HORI
      cHoraF   := T_AUTOMATECH->ZZ9_HORF
      cTexto   := T_AUTOMATECH->TEXTO
   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Automatech News" FROM C(178),C(181) TO C(621),C(805) PIXEL

   @ C(005),C(005) Say "Código"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(036) Say "Descrição do Evento"      Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(005) Say "Mensagem a ser disparada" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(005) Say "Do dia"                   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(049) Say "até o dia"                Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(103) Say "No horário das"           Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(149) Say "até as"                   Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1  Var cCodigo     Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(036) MsGet oGet2  Var cNome       Size C(268),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(033),C(005) GET   oMemo1 Var cTexto MEMO Size C(301),C(163) PIXEL OF oDlg
   @ C(207),C(005) MsGet oGet3  Var cDataI      Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(207),C(049) MsGet oGet4  Var cDataF      Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(207),C(103) MsGet oGet5  Var cHoraI      Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(207),C(149) MsGet oGet6  Var cHoraF      Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(204),C(211) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaNews( _Operacao ) )
   @ C(204),C(249) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaNews(_Operacao)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(cCodigo))
         MsgAlert("Código não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cNome))
         MsgAlert("Nome do evento não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cTexto))
         MsgAlert("Texto a ser visualizado não informado. Verique !!")
         Return .T.
      Endif   

      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZ9_CODI, "
      cSql += "       ZZ9_NOME  "
      cSql += "  FROM " + RetSqlName("ZZ9")
      cSql += " WHERE ZZ9_CODI = '" + Alltrim(cCodigo) + "'"
      cSql += "   AND ZZ9_DELE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Código já cadastrado. Verique!!")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZ9")
      RecLock("ZZ9",.T.)
      ZZ9_CODI := cCodigo
      ZZ9_NOME := cNome
      ZZ9_DATI := cDataI
      ZZ9_DATF := cDataF
      ZZ9_HORI := CHoraI
      ZZ9_HORF := cHoraF
      ZZ9_TEXT := ctexto
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZ9")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZ9") + cCodigo)
         RecLock("ZZ9",.F.)
         ZZ9_NOME := cNome
         ZZ9_DATI := cDataI
         ZZ9_DATF := cDataF
         ZZ9_HORI := CHoraI
         ZZ9_HORF := cHoraF
         ZZ9_TEXT := ctexto
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZ9")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZ9") + cCodigo)
            RecLock("ZZ9",.F.)
            ZZ9_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil