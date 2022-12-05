#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE11.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 10/10/2012                                                          *
// Objetivo..: Programa de Agendamento de Eventos por Usu�rio (Manuten��o)         *
//**********************************************************************************

User Function ESPEVE11(_Operacao, _Codigo, _Usuario, _Ano, _Evento)
                      
   Local cSql        := ""
   Local lChumba     := .F.

   Private aEventos  := {}
   Private cComboBx1

   Private cUsuario  := _Usuario
   Private cAno      := _Ano
   Private cCodigo   := _Codigo
   Private cData     := Ctod("  /  /    ")
   Private cTexto    := ""
   Private cTempo    := Space(02)
   Private cEvento   := _Evento

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oMemo1

   Private oDlg
 
   If _Operacao <> "I"
      If Empty(Alltrim(_Codigo))
         Return .T.
      Endif
   Endif

   // Carrega o ComboBox de Eventos
   // -----------------------------
   If Select("T_EVENTOS") > 0
      T_EVENTOS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZS_CODIGO,"
   cSql += "       ZZS_NOME   "
   cSql += "  FROM " + RetSqlName("ZZS")
   cSql += " WHERE ZZS_TIPO   = 'O'"
   cSql += "   AND ZZS_DELETE = '' " 
   cSql += " ORDER BY ZZS_NOME     "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

   aEventos := {}
   WHILE !T_EVENTOS->( EOF() )
      aAdd( aEventos, Alltrim(T_EVENTOS->ZZS_CODIGO) + " - " + Alltrim(T_EVENTOS->ZZS_NOME) )
      T_EVENTOS->( DbSkip() )
   ENDDO

   // Carrega os dados da agenda do evento em caso se Altera��o/Exclus�o
   If _Operacao <> "I"
   
      If Select("T_AGENDA") > 0
         T_AGENDA->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZZ2_CODIGO,"
      cSql += "       ZZ2_DATA  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ2_NOTA)) AS DESCRICAO,"
      cSql += "       ZZ2_TEMPO  "
      cSql += "  FROM " + RetSqlName("ZZ2")
      cSql += " WHERE ZZ2_CODIGO = '" + Alltrim(cCodigo) + "'"
      cSql += "   AND ZZ2_DELETE = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDA", .T., .T. )
   
      cData  := cTod(Substr(T_AGENDA->ZZ2_DATA,07,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,05,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,01,04))
      cTexto := T_AGENDA->DESCRICAO
      cTempo := T_AGENDA->ZZ2_TEMPO
   
   Endif

   DEFINE MSDIALOG oDlg TITLE "Agendamento de Eventos" FROM C(184),C(187) TO C(441),C(582) PIXEL

   @ C(005),C(005) Say "C�digo"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(033) Say "Usu�rios"       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(173) Say "Ano"            Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Eventos"        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(160) Say "Data Evento"    Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(005) Say "Observa��es"    Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(114),C(005) Say "Tempo Estimado" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet3     Var   cCodigo     Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(014),C(033) MsGet    oGet1     Var   cUsuario    Size C(134),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(014),C(173) MsGet    oGet2     Var   cAno        Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   If _Operacao == "I"
      @ C(036),C(005) ComboBox cComboBx1 Items aEventos    Size C(151),C(010) PIXEL OF oDlg
   Else
      @ C(036),C(005) MsGet oGet6 Var cEvento Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   Endif
      
   @ C(036),C(161) MsGet    oGet4     Var   cData       Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(058),C(005) GET      oMemo1    Var   cTexto MEMO Size C(187),C(050) PIXEL OF oDlg
   @ C(113),C(050) MsGet    oGet5     Var   cTempo      Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
	
   @ C(112),C(116) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION(_SalvaAgenda(_Operacao, cCodigo, cUsuario, cAno, cComboBx1, cData, cTexto, cTempo))
   @ C(112),C(155) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que realiza a grava��o dos dados
Static Function _SalvaAgenda(_Operacao, cCodigo, cUsuario, cAno, cComboBx1, cData, cTexto, cTempo)

   Local cSql   := ""
   Local cEmail := "" 

   // Captura o e-mail do administrador para dar ci�ncia da soliciota��o do agendamento do evento
   // -------------------------------------------------------------------------------------------
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_AEVE"
   cSql += "  FROM " + RetSqlName("ZZJ")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   If T_MASTER->( EOF() )
      c_Email := ""
   Else
      c_Email := T_MASTER->ZZJ_AEVE
   Endif

   // Opera��o de Inclus�o
   If _Operacao == "I"

      If Empty(cData)
         MsgAlert("Data do Evento n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cTempo))
         MsgAlert("Tempo estimado n�o informado. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o pr�ximo c�digo para inclus�o 
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZ2_CODIGO"  
      cSql += "  FROM " + RetSqlName("ZZ2")
      cSql += "  ORDER BY ZZ2_CODIGO DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )
   
      If T_PROXIMO->( EOF() )
         cCodigo := "000001"
      Else
         cCodigo := STRZERO((INT(VAL(T_PROXIMO->ZZ2_CODIGO)) + 1),6)
      Endif
         
      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZ2")
      RecLock("ZZ2",.T.)
      ZZ2_FILIAL := cFilAnt
      ZZ2_CODIGO := cCodigo
      ZZ2_USUA   := Substr(cUsuario,01,06)
      ZZ2_ANO    := cAno
      ZZ2_EVEN   := Substr(cComboBx1,01,06)
      ZZ2_DATA   := cData
      ZZ2_NOTA   := ctexto
      ZZ2_ENVI   := Date()
      ZZ2_HORA   := Time()
      ZZ2_AUTO   := "N"
      ZZ2_DAUT   := Ctod("  /  /    ")
      ZZ2_HAUT   := ""
      ZZ2_QUEM   := ""
      ZZ2_TEMPO  := cTempo
      ZZ2_DELETE := "" 
      MsUnLock()

      // Envia e-mail conforme Status
      If !Empty(Alltrim(c_Email))

         cEmail := ""
         cEmail := "Prezado(a) Senhor(a),"
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "O usu�rio(a) " + Alltrim(Substr(cUsuario,10)) + " incluiu uma solicita��o de"
         cEmail += chr(13) + chr(10)
         cEmail += "Agendamento de Evento e aguarda a sua Aprova��o/Reprova��o."
         cEmail += chr(13) + chr(10)      
         cEmail += chr(13) + chr(10)      
         cEmail += "Evento: " + Substr(cComboBx1,10)
         cEmail += chr(13) + chr(10)      
         cEmail += "Para o dia: " + Dtoc(cData)
         cEmail += chr(13) + chr(10)                                                
         cEmail += "Tempo estimado: " + Alltrim(cTempo) + " Hrs"
         cEmail += chr(13) + chr(10)                                                
         cEmail += chr(13) + chr(10)                                                                  
         cEmail += "Att."
         cEmail += chr(13) + chr(10)                                                
         cEmail += chr(13) + chr(10)                                                                  
         cEmail += "Sistema de Controle de Tarefas"
         
         // Envia e-mail ao Aprovador
         U_AUTOMR20(cEmail , Alltrim(c_Email), "", "INCLUS�O de Solicita��o de Agendamento de Evento" )

      Endif           

   Endif

   // Opera��o de Altera��o
   If _Operacao == "A"

      If Empty(cData)
         MsgAlert("Data do Evento n�o infromado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cTempo))
         MsgAlert("Tempo estimado n�o informado. Verique !!")
         Return .T.
      Endif   

      aArea := GetArea()

      DbSelectArea("ZZ2")
      DbSetOrder(1)
      If DbSeek(cFilAnt + cCodigo)
         RecLock("ZZ2",.F.)
         ZZ2_DATA   := cData
         ZZ2_NOTA   := ctexto
         ZZ2_TEMPO  := cTempo
         ZZ2_ENVI   := Date()
         ZZ2_HORA   := Time()
         MsUnLock()              
      Endif

      // Envia e-mail conforme Status
      If !Empty(Alltrim(c_Email))

         cEmail := ""
         cEmail := "Prezado(a) Senhor(a),"
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "O usu�rio(a) " + Alltrim(Substr(cUsuario,10)) + " alterou uma solicita��o de"
         cEmail += chr(13) + chr(10)
         cEmail += "Agendamento de Evento e aguarda a sua Aprova��o/Reprova��o."
         cEmail += chr(13) + chr(10)      
         cEmail += chr(13) + chr(10)      
         cEmail += "Evento: " + Alltrim(cEvento)
         cEmail += chr(13) + chr(10)      
         cEmail += "Para o dia: " + Dtoc(cData)
         cEmail += chr(13) + chr(10)                                                
         cEmail += "Tempo estimado: " + Alltrim(cTempo) + " Hrs"
         cEmail += chr(13) + chr(10)                                                
         cEmail += chr(13) + chr(10)                                                                  
         cEmail += "Att."
         cEmail += chr(13) + chr(10)                                                
         cEmail += chr(13) + chr(10)                                                                  
         cEmail += "Sistema de Controle de Tarefas"
         
         // Envia e-mail ao Aprovador
         U_AUTOMR20(cEmail , Alltrim(c_Email), "", "ALTERA��O de Solicita��o de Agendamento de Evento" )

      Endif           
      
   Endif

   // Opera��o de Exclus�o
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclus�o deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZ2")
         DbSetOrder(1)
         If DbSeek(cFilAnt + cCodigo)
            RecLock("ZZ2",.F.)
            ZZ2_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil