#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPENC01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/05/2012                                                          *
// Objetivo..: Programa que visualiza as tarefas disponíveis para encerramento.    *
//**********************************************************************************

User Function ESPENC01()

   Local cSql        := ""
   Local lChumbaU    := .T.

   Private cTexto	 := ""
   Private oMemo1

   Private aUsuarios := {}
   Private cComboBx1

   Private oDlg

   Private aBrowse   := {}
   Private oBrowse

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')

   // Crarega o combo de Usuários
   lChumbaU := .F.
   aAdd( aUsuarios, cUserName )

   aBrowse    := {}

   // Pesquisa as tarefas com Status de Validação para o usuário selecionado no combobox aUsuarios
   If Select("T_VALIDACAO") > 0
      T_VALIDACAO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZG_CODI, "
   cSql += "       A.ZZG_SEQU, "
   cSql += "       A.ZZG_TITU, "
   cSql += "       B.ZZC_LEGE  "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZC") + " B  "
   cSql += " WHERE UPPER(A.ZZG_USUA) = '" + UPPER(Alltrim(aUsuarios[1])) + "'"
   cSql += "    AND A.ZZG_STAT = '7'"
   cSql += "   AND A.ZZG_DELE = '' "
   cSql += "   AND '00000' + A.ZZG_STAT = B.ZZC_CODIGO "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VALIDACAO", .T., .T. )

   If T_VALIDACAO->( Eof() )
      aBrowse := {}
   Else
   
      T_VALIDACAO->( DbGoTop() )
      WHILE !T_VALIDACAO->( EOF() )
         aAdd( aBrowse, { T_VALIDACAO->ZZC_LEGE,;
                          Alltrim(T_VALIDACAO->ZZG_CODI) + "." + Alltrim(T_VALIDACAO->ZZG_SEQU),;
                          T_VALIDACAO->ZZG_TITU })
         T_VALIDACAO->( DbSkip() )
      ENDDO
   Endif

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "" } )
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Encerramento de Tarefas" FROM C(178),C(181) TO C(579),C(769) PIXEL

   @ C(005),C(005) Say "Solicitante"                                                    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(019),C(005) Say "Relação de tarefas liberadas para Encerramento"                 Size C(285),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(110),C(005) Say "Descrição da solicitação da tarefa"                             Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(186),C(086) Say "Duplo Click sobre a tarefa, visualiza descrição da solicitação" Size C(141),C(008) COLOR CLR_BLACK PIXEL OF oDlg	

   @ C(003),C(034) ComboBox cComboBx1 Items aUsuarios When lChumbaU Size C(121),C(010) PIXEL OF oDlg VALID(COMUSUARIOS(cComboBx1))

   @ C(119),C(005) GET oMemo1 Var cTexto MEMO Size C(283),C(061) PIXEL OF oDlg

   @ C(184),C(005) Button "Alterar Status"     Size C(058),C(012) PIXEL OF oDlg ACTION( TROCASTATUS(aBrowse[oBrowse:nAt,02]) )
   @ C(184),C(251) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 035 , 005, 370, 103,,{'','Codigo', 'Título da Tarefa'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   MOSTRADETX(aBrowse[01,02])
      
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               } }

   oBrowse:bLDblClick := {|| MOSTRADETX(aBrowse[oBrowse:nAt,02]) } 

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Sub-Função que mostra a Descrição da Tarefa e a Solução Adotada
Static Function MOSTRADETX(_Codigo)

   Local cSql     := ""
   Local cTarefa  := ""

   cTexto := ""

   If Empty(Alltrim(_Codigo))
      Return .T.
   Endif

   If Select("T_MOSTRA") > 0
      T_MOSTRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Substr(_Codigo,01,06) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Substr(_Codigo,08,02) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

   If T_MOSTRA->( EOF() )
      Return .T.
   Endif

   // Carrega o campo cTexto
   If !Empty(Alltrim(T_MOSTRA->DESCRICAO))
      cTarefa := "TAREFA Nº " + Alltrim(_Codigo) + chr(13) + chr(10)
      cTexto  := cTarefa + Chr(13) + Alltrim(T_MOSTRA->DESCRICAO)
   Endif

   oMemo1:Refresh()

Return .T.

// Função que carrega as tarefas a serem validadas conforme usuário selecionado no combo de usuários
Static Function COMUSUARIOS(XXUsuario)

   Local cSql := ""

   aBrowse    := {}
   cTexto     := ""
   oMemo1:Refresh()
   
   // Pesquisa as tarefas com Status de Validação para o usuário selecionado no combobox aUsuarios
   If Select("T_VALIDACAO") > 0
      T_VALIDACAO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZG_CODI, "
   cSql += "       A.ZZG_SEQU, "
   cSql += "       A.ZZG_TITU, "
   cSql += "       B.ZZC_LEGE  "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZC") + " B  "
   cSql += " WHERE UPPER(A.ZZG_USUA) = '" + UPPER(Alltrim(XXUsuario)) + "'"
   cSql += "    AND A.ZZG_STAT = '7'"
   cSql += "   AND A.ZZG_DELE = '' "
   cSql += "   AND '00000' + A.ZZG_STAT = B.ZZC_CODIGO "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VALIDACAO", .T., .T. )

   If T_VALIDACAO->( Eof() )
      aBrowse := {}
   Else
   
      T_VALIDACAO->( DbGoTop() )
      WHILE !T_VALIDACAO->( EOF() )
         aAdd( aBrowse, { T_VALIDACAO->ZZC_LEGE,;
                          Alltrim(T_VALIDACAO->ZZG_CODI) + "." + Alltrim(T_VALIDACAO->ZZG_SEQU),;
                          T_VALIDACAO->ZZG_TITU })
         T_VALIDACAO->( DbSkip() )
      ENDDO
   Endif

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "" } )
   Endif   

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               } }

   oBrowse:Refresh()

   MOSTRADETX(aBrowse[01,02])
   
Return .T.

// Função que carrega as tarefas a serem validadas conforme usuário selecionado no combo de usuários
Static Function TROCASTATUS(__Tarefa)

   Local aStatus     := {"000006 - Inconforme", "000009 - Tarefa Encerrada"}
   Local cComboBx1

   Local cObservacao := ""
   Local oMemo1

   If Empty(Alltrim(__Tarefa))
      Return .T.
   Endif

   Private oDlgST

   DEFINE MSDIALOG oDlgST TITLE "Alteração Status - Encerramento de Tarefa" FROM C(178),C(181) TO C(425),C(562) PIXEL

   @ C(005),C(005) Say "Status"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgST
   @ C(028),C(005) Say "Considerações a serem observadas" Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlgST
   
   @ C(014),C(005) ComboBox cComboBx1 Items aStatus          Size C(179),C(010) PIXEL OF oDlgST
   @ C(037),C(005) GET      oMemo1    Var   cObservacao MEMO Size C(179),C(067) PIXEL OF oDlgST

   @ C(107),C(108) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgST ACTION( ALTVALIDA(__Tarefa, cComboBx1, cObservacao) )
   @ C(107),C(147) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgST ACTION( oDlgST:End() )

   ACTIVATE MSDIALOG oDlgST CENTERED 

Return(.T.)

// Função que grava a alteração do Status da Tarefa
Static Function ALTVALIDA( __Codigo, __Status, __Observa)

   Local c_Email    := ""
   Local lMarketing := .F.
   Local lEnviar	:= .F.
   Local oMarketing
   Local oEnviar

   // Atualiza a tabela da Tarefa
   DbSelectArea("ZZG")
   DbSetOrder(1)

   If DbSeek(xfilial("ZZG") + Substr(__Codigo,01,06) + Substr(__Codigo,08,02))

      RecLock("ZZG",.F.)
      ZZG_STAT := Substr(__Status,06,01)
      MsUnLock()                 

      // Inseri os dados na Tabela de Históricos de Tarefas
      aArea := GetArea()

      // Atualiza a tabela de histórico de tarefa
      dbSelectArea("ZZH")
      RecLock("ZZH",.T.)
      ZZH_CODI := Substr(__Codigo,01,06)
      ZZH_SEQU := Substr(__Codigo,08,02)
      ZZH_DATA := Date()
      ZZH_HORA := Time()
      ZZH_STAT := Substr(__Status,06,01)
      ZZH_DELE := " "
      MsUnLock()

      // Grava o campo memo da Descrição da Solução
      MSMM(,80,,__Observa,1,,,"ZZH","ZZH_OBS2")
      
      // Pesquisa o desenvolvedor da tarefa para envio do e-mail de aviso de movimentação de tarefa
      If Select("T_PROGRAMADOR") > 0
         T_PROGRAMADOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZG_FILIAL,"
      cSql += "       A.ZZG_CODI  ,"
      cSql += "       A.ZZG_SEQU  ,"
      cSql += "       A.ZZG_TITU  ,"
      cSql += "       A.ZZG_PROG  ,"
      cSql += "       B.ZZE_NOME  ,"
      cSql += "       B.ZZE_EMAIL  "
      cSql += "  FROM " + RetSqlName("ZZG") + " A, "
      cSql += "       " + RetSqlName("ZZE") + " B  "
      cSql += " WHERE A.ZZG_DELE   = ''"
      cSql += "   AND A.ZZG_CODI   = '" + Substr(__Codigo,01,06) + "'"
      cSql += "   AND A.ZZG_SEQU   = '" + Substr(__Codigo,08,02) + "'"
      cSql += "   AND A.ZZG_PROG   = B.ZZE_CODIGO"
      cSql += "   AND B.ZZE_DELETE = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROGRAMADOR", .T., .T. )

      If T_PROGRAMADOR->( EOF() )
         cProgramador := ""
      Else
         cProgramador := T_PROGRAMADOR->ZZE_EMAIL
      Endif

      If !Empty(Alltrim(cProgramador))

         // Envia e-mail conforme Status
         cEmail := ""
         cEmail := "Prezado(a) " + Alltrim(T_PROGRAMADOR->ZZE_NOME)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "A Tarefa de nº " + Alltrim(__Codigo) + " " + Alltrim(T_PROGRAMADOR->ZZG_TITU)
         cEmail += chr(13) + chr(10)

         If Substr(__Status,06,01) == "6"
            cEmail += "apresentou problemas após ter sido aplicada em produção."
            cEmail += chr(13) + chr(10)
            cEmail += "Favor observar o campo Observações deste Status para maiores orientações."
         Else
            cEmail += "foi encerrada com sucesso."
         Endif

         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Sistema de Controle de Tarefas Automatech"

         U_AUTOMR20(cEmail, Alltrim(cProgramador), "", "Aviso de Movimentação de Tarefa" )
         
      Endif

   Endif      

   oDlgST:End()

   // Carrega o grid
   COMUSUARIOS(cComboBx1)

Return .T.