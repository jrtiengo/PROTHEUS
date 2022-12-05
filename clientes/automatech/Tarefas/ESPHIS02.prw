#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPHIS02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/01/2012                                                          *
// Objetivo..: Programa de Manutenção da Alteração do Status da Tarefa             *
// Parâmetros: Código da Tarefa                                                    *
//**********************************************************************************

User Function ESPHIS02(_Tipo, _Codigo, _Registro, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo)

   Local nContar       := 0

   Private aStatus     := {}
   Private oGet1       := Ctod("  /  /    ")
   Private dData01     := Ctod("  /  /    ")

   Private cDono       := ""
   Private cCodigo     := ""
   Private cTitulo     := Space(25)
   Private cStatus
   Private cObservacao := ""
   Private lLibera  := .F.

   If _Tipo == "A"
      Private lEdita := .T.
   Else
      Private lEdita := .F.      
   Endif   

   Private oGet1
   Private oGet2
   Private oMemo1

   Private oDlg

   // Captura os dados da tarefa para display
   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       ZZG_TITU  ,"
   cSql += "       ZZG_STAT  ,"
   cSql += "       ZZG_PREV  ,"
   cSql += "       ZZG_USUA   "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Substr(_Codigo,01,06) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Substr(_Codigo,08,02) + "'"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )
   
   cCodigo := Alltrim(T_TAREFA->ZZG_CODI) + "." + Alltrim(T_TAREFA->ZZG_SEQU)
   cTitulo := T_TAREFA->ZZG_TITU
   dData01 := Ctod(Substr(T_TAREFA->ZZG_PREV,07,02) + "/" + Substr(T_TAREFA->ZZG_PREV,05,02) + "/" + Substr(T_TAREFA->ZZG_PREV,01,04))
   cDono   := T_TAREFA->ZZG_USUA

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZC_CODIGO, "
   cSql += "       ZZC_NOME  , "
   cSql += "       ZZC_LEGE    "
   cSql += "  FROM " + RetSqlName("ZZC")
   cSql += " WHERE ZZC_DELETE = ''"
   cSql += " ORDER BY ZZC_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      aStatus := {}
   Else
      WHILE !T_STATUS->( EOF() )
         aAdd( aStatus, STR(INT(VAL(T_STATUS->ZZC_CODIGO)),1) + " - " + T_STATUS->ZZC_NOME )
         T_STATUS->( DbSkip() )
      ENDDO
   Endif

   // Pesquisa a possível observações para display
   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZH_OBS2, "
   cSql += "       ZZH_STAT  "
   cSql += "  FROM " + RetSqlName("ZZH")
   cSql += " WHERE ZZH_DELE   = ''"
   cSql += "   AND ZZH_CODI   = '" + Substr(_Codigo,01,06) + "'"
   cSql += "   AND ZZH_SEQU   = '" + Substr(_Codigo,08,02) + "'"
   cSql += "   AND R_E_C_N_O_ = "  + Alltrim(Str(_Registro))

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )
   
   IF !T_NOTA->( EOF() )

      //Posiciona o status da tarefa
      For nContar = 1 to Len(aStatus)
          If Alltrim(Substr(aStatus[nContar],1,1)) == Alltrim(T_NOTA->ZZH_STAT)
             cStatus := aStatus[nContar]
             Exit
          Endif
      Next nContar

      cObservacao := MSMM(T_NOTA->ZZH_OBS2)

      // Carrega o campo cTexto
      If !Empty(Alltrim(T_NOTA->ZZH_OBS2))
      
         If Select("T_TEXTO") > 0
            T_TEXTO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT YP_TEXTO "
         cSql += "  FROM " + RetSqlName("SYP")
         cSql += " WHERE YP_CHAVE = '" + ALLTRIM(T_NOTA->ZZH_OBS2) + "'"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEXTO", .T., .T. )

         If T_TEXTO->( EOF() )
            cObservacao := ""
         Else
            T_TEXTO->( DbGoTop() )
            WHILE !T_TEXTO->( EOF() )
               cObservacao := cObservacao + Alltrim(STRTRAN(T_TEXTO->YP_TEXTO, "\13\10", chr(13) + chr(10)))
               T_TEXTO->( DbSkip() )
            ENDDO
         Endif
      
      Endif

   Endif   

   DEFINE MSDIALOG oDlg TITLE "Alteração Status Tarefa" FROM C(178),C(181) TO C(426),C(611) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(003),C(006) Say "Tarefa"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(035) Say "Título da Tarefa"                 Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(007) Say "Status"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(168) Say "Data Enc."                        Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(007) Say "Considerações a serem Observadas" Size C(091),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(013),C(007) MsGet oGet1 Var cCodigo When lLibera Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(035) MsGet oGet2 Var cTitulo When lLibera Size C(172),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(035),C(007) ComboBox cStatus Items aStatus          When lEdita Size C(150),C(010) PIXEL OF oDlg
   @ C(035),C(168) MsGet    oGet1   Var   dData01          When Substr(cStatus,01,01)$("5#6#7#8#9") Size C(038),C(009) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(059),C(007) GET      oMemo1  Var   cObservacao MEMO When lEdita Size C(201),C(043) PIXEL OF oDlg

   @ C(106),C(129) Button "Salvar" When _Tipo == "A" Size C(037),C(012) PIXEL OF oDlg ACTION( GravaSt(_Codigo, dData01, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo) )
   @ C(106),C(171) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava os dados
Static Function GravaST(_Codigo, dData01, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo)

   Local c_Email    := ""
   Local lMarketing := .F.
   Local lEnviar	:= .F.
   Local oMarketing
   Local oEnviar

   Private oDlgFim

   // Valida a data de encerramento
   If Substr(cStatus,01,01)$("5#6#7#8#9")
      If Empty(dData01)
         MsgAlert("Data de encerramento da tarefa não informada. Verifique!")
         Return(.T.)
      Endif
   Endif      

//   If Substr(cStatus,01,01) == '4'
//      If Empty(dData01)
//         MsgAlert("Data prevista de entrega da tarefa não informada.")
//         Return .T.
//      Endif
//   Endif

   // Se Status == 7 (Encerrada), solicita ao usuário se envia e-mail e se quer marcar para mail marketing
   If Substr(cStatus,01,01) == '7'

      DEFINE MSDIALOG oDlgFim TITLE "Encerramento de Tarefa" FROM C(178),C(181) TO C(292),C(468) PIXEL

      @ C(005),C(005) CheckBox oEnviar    Var lEnviar    Prompt "Envia e-mail de aviso de encerramento de Tarefa" Size C(134),C(008) PIXEL OF oDlgFim
      @ C(017),C(005) CheckBox oMarketing Var lMarketing Prompt "Marca Tarefa para envio de e-mail Marketing"     Size C(120),C(008) PIXEL OF oDlgFim
      @ C(034),C(052) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgFim ACTION( ODlgFim:End() )

      ACTIVATE MSDIALOG oDlgFim CENTERED 
      
   Endif   

   // Atualiza a tabela da Tarefa
   DbSelectArea("ZZG")
   DbSetOrder(1)

   If DbSeek(xfilial("ZZG") + Substr(_Codigo,01,06) + Substr(_Codigo,08,02))

      RecLock("ZZG",.F.)
      ZZG_STAT := Substr(cStatus,01,01)
      ZZG_MARK := IIF(lMarketing == .T., "X", "")

      If Substr(cStatus,01,01)$("5#6#7#8#9")
         ZZG_APAR := Ctod(__Apartir)
         ZZG_ESTI := __Estima
         ZZG_PREV := Ctod(__Previsto)
         ZZG_THOR := __Thoras
         ZZG_TDES := __Tdesen
         ZZG_TATR := __Tatraso
         ZZG_TSAL := __Tsaldo
      Endif   

      If Substr(cStatus,01,01) == '7'
         ZZG_PROD := Date()
      Endif   

      MsUnLock()                 

      // Inseri os dados na Tabela de Históricos de Tarefas
      aArea := GetArea()

      // Atualiza a tabela de histórico de tarefa
      dbSelectArea("ZZH")
      RecLock("ZZH",.T.)
      ZZH_CODI := Substr(cCodigo,01,06)
      ZZH_SEQU := Substr(cCodigo,08,02)
      ZZH_DATA := Date() && dData01
      ZZH_HORA := Time()
      ZZH_STAT := Substr(cStatus,01,01)
      ZZH_DELE := " "

      If Substr(cStatus,01,01)$("5#6#7#8#9")
         ZZH_APAR := Ctod(__Apartir)
         ZZH_ESTI := __Estima
         ZZH_PREV := Ctod(__Previsto)
         ZZH_DIFE := dData01 - Ctod(__Previsto)
      Endif   

      MsUnLock()

      // Grava o campo memo da Descrição da Solução
      MSMM(,80,,cObservacao,1,,,"ZZH","ZZH_OBS2")

      // Altera o Status da tarefa principal
      DbSelectArea("ZZG")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZG") + Substr(_Codigo,01,06) + Substr(_Codigo,08,02))
         RecLock("ZZG",.F.)
         ZZG_STAT := Substr(cStatus,01,01)
         MsUnLock()              
      Endif

      // Captura o e-mail do administrador para dar ciência
      If Select("T_MASTER") > 0
         T_MASTER->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZJ_EMAI"
      cSql += "  FROM " + RetSqlName("ZZJ")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

      If T_MASTER->( EOF() )
         c_Email := ""
      Else
         c_Email := T_MASTER->ZZJ_EMAI
      Endif

      // Envia e-mail conforme Status
      If !Empty(Alltrim(c_Email))
         cEmail := ""
         cEmail := "Prezado Roger,"
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "A Tarefa de nº " + Substr(cCodigo,01,06) + "." + Substr(cCodigo,08,02) + " " + Alltrim(cTitulo)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)      

         Do Case
            Case Substr(cStatus,01,01) == '4'
                 cEmail += "entrou em DESENVOLVIMENTO."
            Case Substr(cStatus,01,01) == '5'
                 cEmail += "entrou em VALIDAÇÃO."
            Case Substr(cStatus,01,01) == '6'
                 cEmail += "teve sua VALIDAÇÃO REPROVADA necessitando de novo desenvolvimento."
            Case Substr(cStatus,01,01) == '7'
                 cEmail += "foi APLICADA EM PRODUÇÃO."
            Case Substr(cStatus,01,01) == '8'
                 cEmail += "foi LIBERADA a ser aplicada em produção."
         EndCase              
              
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         
         // Envia e-mail ao Aprovador
         If Substr(cStatus,01,01) == '7'        
            If lEnviar == .T.
//             U_AUTOMR20(cEmail, Alltrim(c_Email), "" , "Aviso de Movimentação de Tarefa" )
            Endif
         Else
//          U_AUTOMR20(cEmail, Alltrim(c_Email), "", "Aviso de Movimentação de Tarefa" )
         Endif                          
      Endif           

      // Se Status 7, envia aviso ao usuário que a tarefa foi incluída em Produção
      If Substr(cStatus,01,01) == '7'

         // Pesquisa o e-mail do dono da tarefa para envio de e-mail
         If Select("T_USUARIO") > 0
            T_USUARIO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZA_CODI, "
         cSql += "       ZZA_NOME, "
         cSql += "       ZZA_EMAI  "
         cSql += "  FROM " + RetSqlName("ZZA")
         cSql += " WHERE RTRIM(LTRIM(ZZA_NOME)) = '" + Alltrim(cDono) + "'"
         cSql += " ORDER BY ZZA_NOME "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

         If T_USUARIO->( EOF() )
            lEnviar := .F.
            c_Email := ""
         Else
            lEnviar := .T.
            c_Email := T_USUARIO->ZZA_EMAI
         Endif      

         // Envia e-mail conforme Status
         cEmail := ""
         cEmail := "Prezado(a) " + Alltrim(T_USUARIO->ZZA_NOME)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "A Tarefa de nº " + Substr(cCodigo,01,06) + "." + Substr(cCodigo,08,02) + " " + Alltrim(cTitulo)
         cEmail += chr(13) + chr(10)
         cEmail += "foi atualizada em PRODUÇÃO podendo a mesma já ser utilizada."
         cEmail += chr(13) + chr(10)
         cEmail += "Favor verificar se sua tarefa foi corretamente aplicada em Produção."
         cEmail += chr(13) + chr(10)
         cEmail += "Após esta verificação, favor encerrá-la acessando o Módulo 97 - Controle de Tarefas -> Encerramento de Tarefas."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Att."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Depatamento de Desenvolvimento ADVPL - Automatech"

         // Envia e-mail ao Aprovador
         If lEnviar == .T.
            U_AUTOMR20(cEmail, Alltrim(c_Email), "", "Aviso de Movimentação de Tarefa" )
         Endif                       

      Endif

      // Se Status 5, envia aviso ao usuário que a tarefa foi enviada para Validação
      If Substr(cStatus,01,01) == '5'

         // Pesquisa o e-mail do dono da tarefa para envio de e-mail
         If Select("T_USUARIO") > 0
            T_USUARIO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZA_CODI, "
         cSql += "       ZZA_NOME, "
         cSql += "       ZZA_EMAI  "
         cSql += "  FROM " + RetSqlName("ZZA")
         cSql += " WHERE RTRIM(LTRIM(ZZA_NOME)) = '" + Alltrim(cDono) + "'"
         cSql += " ORDER BY ZZA_NOME "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

         If T_USUARIO->( EOF() )
            lEnviar := .F.
            c_Email := ""
         Else
            lEnviar := .T.
            c_Email := T_USUARIO->ZZA_EMAI
         Endif      

         // Envia e-mail conforme Status
         cEmail := ""
         cEmail := "Prezado(a) " + Alltrim(T_USUARIO->ZZA_NOME)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "A Tarefa de nº " + Substr(cCodigo,01,06) + "." + Substr(cCodigo,08,02) + " " + Alltrim(cTitulo)
         cEmail += chr(13) + chr(10)
         cEmail += "foi disponibilizada para Validação."
         cEmail += chr(13) + chr(10)
         cEmail += "Após os testes de verificação, favor alterar o Status da tarefa na opção Validação de Tarefas do seu Módulo 97 - Controle de Tarefas."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Att."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Departamento de Desenvolvimento ADVPL - Automatech"         

         // Envia e-mail ao Aprovador
         If lEnviar == .T.
            U_AUTOMR20(cEmail, Alltrim(c_Email), "", "Aviso de Movimentação de Tarefa" )
         Endif                       
      Endif

      oDlg:End()

   Endif

Return .T.