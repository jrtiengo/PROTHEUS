#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPVAL01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/05/2012                                                          *
// Objetivo..: Programa que visualiza as tarefas disponíveis para validação.       *
//**********************************************************************************

User Function ESPVAL01()

   Local cSql        := ""
   Local lChumbaU    := .T.

   Private cTexto	 := ""
   Private cSolucao  := ""
   Private oMemo1
   Private oMemo2

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

   // Verifica se existe parametrização de ordenação para proseguir no programa
   If Select("T_INTERVALO") > 0
      T_INTERVALO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_ORDE,"
   cSql += "       ZZJ_INTE "
   cSql += "  FROM " + RetSqlName("ZZJ")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_INTERVALO", .T., .T. )
         
   If T_INTERVALO->( EOF() )
      MsgAlert("Atenção! Parametrização de intervalo de ordenação não configurada. Verifique parametrizador.")
      Return(.T.)
   Endif

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
   cSql += " WHERE UPPER(A.ZZG_USUA) = '" + Alltrim(Upper(aUsuarios[1])) + "'"
   cSql += "    AND A.ZZG_STAT = '5'"
   cSql += "   AND A.ZZG_DELE  = '' "
   cSql += "   AND '00000' + A.ZZG_STAT = B.ZZC_CODIGO "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VALIDACAO", .T., .T. )

   If T_VALIDACAO->( Eof() )
      aBrowse := {}
   Else
   
      T_VALIDACAO->( DbGoTop() )
      WHILE !T_VALIDACAO->( EOF() )
         aAdd( aBrowse, { T_VALIDACAO->ZZC_LEGE                                                 ,;
                          Alltrim(T_VALIDACAO->ZZG_CODI) + "." + Alltrim(T_VALIDACAO->ZZG_SEQU) ,;
                          T_VALIDACAO->ZZG_TITU })
         T_VALIDACAO->( DbSkip() )
      ENDDO
   Endif

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "" } )
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Validação de Tarefas" FROM C(178),C(181) TO C(626),C(769) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(033),C(005) Say "Solicitante"                                                    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(044),C(005) Say "Relação de tarefas liberadas para Validação (VALIDAÇÃO DEVERÁ SER REALIZADA NO AMBIENTE DEVELOPER)" Size C(285),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(110),C(005) Say "Descrição da solicitação da tarefa"                             Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(157),C(005) Say "Solução Adotada"                                                Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(210),C(086) Say "Dupli Click sobre a tarefa, visualiza descrição da solicitação" Size C(141),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(032),C(034) ComboBox cComboBx1 Items aUsuarios When lChumbaU Size C(121),C(010) PIXEL OF oDlg VALID(COMUSUARIOS(cComboBx1))

   @ C(119),C(005) GET oMemo1 Var cTexto   MEMO Size C(283),C(036) PIXEL OF oDlg
   @ C(166),C(005) GET oMemo2 Var cSolucao MEMO Size C(283),C(036) PIXEL OF oDlg

   @ C(207),C(005) Button "Alterar Status" Size C(060),C(012) PIXEL OF oDlg ACTION( TROCASTATUS(aBrowse[oBrowse:nAt,02]) )
   @ C(207),C(251) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 064 , 005, 370, 75,,{'','Codigo', 'Título da Tarefa'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS SOLUCAO    "
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
      cTarefa  := "TAREFA Nº " + Alltrim(_Codigo) + chr(13) + chr(10)
      cTexto   := cTarefa + Chr(13) + Alltrim(T_MOSTRA->DESCRICAO)
      cSolucao := Alltrim(T_MOSTRA->SOLUCAO)
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
   cSql += "    AND A.ZZG_STAT = '5'"
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
                          Alltrim(T_VALIDACAO->ZZG_CODI) + "." + Alltrim(T_VALIDACAO->ZZG_SEQU) ,;
                          T_VALIDACAO->ZZG_TITU })
         T_VALIDACAO->( DbSkip() )
      ENDDO
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   If Len(aBrowse) == 0

   Else

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

   Endif
   
Return .T.

// Função que carrega as tarefas a serem validadas conforme usuário selecionado no combo de usuários
Static Function TROCASTATUS(__Tarefa)

   Local aStatus     := {"000006 - Inconforme", "000008 - Liberada para Produção"}
   Local cComboBx1

   Local cObservacao := ""
   Local oMemo1

   If Empty(Alltrim(__Tarefa))
      Return .T.
   Endif

   Private oDlgST

   DEFINE MSDIALOG oDlgST TITLE "Alteração Status - Validação de Tarefa" FROM C(178),C(181) TO C(425),C(562) PIXEL

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

   Local c_Email      := ""
   Local lMarketing   := .F.
   Local lEnviar	  := .F.
   Local oMarketing
   Local oEnviar
   Local cProgramador := ""

   // Atualiza a tabela da Tarefa
   DbSelectArea("ZZG")
   DbSetOrder(1)

   If DbSeek(xfilial("ZZG") + Substr(__Codigo,01,06) + Substr(__Codigo,08,02))

      RecLock("ZZG",.F.)

      If Alltrim(Str(Int(Val(__Status)))) == "6"
         ZZG_STAT := "6"

//         ZZG_PREV := Ctod("  /  /    ")
//         ZZG_ESTI := ""
//         ZZG_XHOR := Space(03)
//         ZZG_XDIA := Space(03)
//         ZZG_DEBI := 0
//         ZZG_CRED := 0
//         ZZG_APAR := Ctod("  /  /    ")

         // Abre nova tarefa com nova sequencia para a tarefa reprovada na validação pelo usuário.
         x_ZZG_FILIAL := ZZG->ZZG_FILIAL
         x_ZZG_CODI   := ZZG->ZZG_CODI  
         x_ZZG_SEQU   := ZZG->ZZG_SEQU  
         x_ZZG_TITU   := ZZG->ZZG_TITU  
         x_ZZG_USUA   := ZZG->ZZG_USUA  
         x_ZZG_DATA   := ZZG->ZZG_DATA  
         x_ZZG_HORA   := ZZG->ZZG_HORA  
         x_ZZG_STAT   := ZZG->ZZG_STAT  
         x_ZZG_DES2   := ZZG->ZZG_DES2  
         x_ZZG_PRIO   := ZZG->ZZG_PRIO  
         x_ZZG_DES1   := ZZG->ZZG_DES1
         x_ZZG_NOT1   := ZZG->ZZG_NOT1
         x_ZZG_SOL1   := ZZG->ZZG_SOL1
         x_ZZG_NOT2   := ZZG->ZZG_NOT2  
         x_ZZG_PREV   := ZZG->ZZG_PREV  
         x_ZZG_TERM   := ZZG->ZZG_TERM  
         x_ZZG_PROD   := ZZG->ZZG_PROD  
         x_ZZG_SOL2   := ZZG->ZZG_SOL2  
         x_ZZG_DELE   := ZZG->ZZG_DELE  
         x_ZZG_ORIG   := ZZG->ZZG_ORIG  
         x_ZZG_COMP   := ZZG->ZZG_COMP  
         x_ZZG_PROG   := ZZG->ZZG_PROG  
         x_ZZG_CHAM   := ZZG->ZZG_CHAM  
         x_ZZG_MARK   := ZZG->ZZG_MARK  
         x_ZZG_TTAR   := ZZG->ZZG_TTAR  
         x_ZZG_ESTI   := ZZG->ZZG_ESTI  
         x_ZZG_XHOR   := ZZG->ZZG_XHOR  
         x_ZZG_XDIA   := ZZG->ZZG_XDIA  
         x_ZZG_DEBI   := ZZG->ZZG_DEBI  
         x_ZZG_CRED   := ZZG->ZZG_CRED  
         x_ZZG_ORDE   := ZZG->ZZG_ORDE  
         x_ZZG_APAR   := ZZG->ZZG_APAR  
         x_ZZG_THOR   := ZZG->ZZG_THOR  
         x_ZZG_TDES   := ZZG->ZZG_TDES  
         x_ZZG_TATR   := ZZG->ZZG_TATR  
         x_ZZG_TSAL   := ZZG->ZZG_TSAL  
         x_ZZG_FONT   := ZZG->ZZG_FONT

         // Captura a nova sequencia para gravação
         If Select("T_SEQUENCIA") > 0
            T_SEQUENCIA->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZG_CODI,"
         cSql += "       ZZG_SEQU "
         cSql += "  FROM " + RetSqlName("ZZG")
         cSql += " WHERE ZZG_CODI = '" + Alltrim(ZZG->ZZG_CODI) + "'"
         cSql += "   AND ZZG_DELE = ''"
         cSql += " ORDER BY ZZG_CODI, ZZG_SEQU DESC"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEQUENCIA", .T., .T. )

         x_ZZG_SEQU := Strzero(INT(VAL(T_SEQUENCIA->ZZG_SEQU)) + 1,2)

         // Captura a ordenação da tarefa de origem para cálculo da nova ordenação
         nOrdem01 := ZZG->ZZG_ORDE

         // Pesquisa a parametrização do Incremento e Intervalo de ordenação
         If Select("T_MASTER") > 0
            T_MASTER->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZJ_ORDE,"
         cSql += "       ZZJ_INTE "
         cSql += "  FROM " + RetSqlName("ZZJ")

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

         If T_MASTER->( EOF() )
            nIncremento := 100
            nIntervalo  := 20
         Else
            nIncremento := IIF(T_MASTER->ZZJ_ORDE == 0, 100, T_MASTER->ZZJ_ORDE)
            nIntervalo  := IIF(T_MASTER->ZZJ_INTE == 0,  20, T_MASTER->ZZJ_INTE)
         Endif

         // Pesquisa as tarefas para localizar a posição de inclusão da nova tarefa
         If Select("T_POSICAO") > 0
            T_POSICAO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.ZZG_FILIAL,"
         cSql += "       A.ZZG_CODI  ,"
         cSql += "       A.ZZG_SEQU  ,"
         cSql += "       A.ZZG_STAT  ,"
         cSql += "       A.ZZG_ORDE   "
         cSql += "  FROM " + RetSqlName("ZZG") + " A "
         cSql += "  WHERE A.ZZG_FILIAL = ''"   
         cSql += "   AND A.ZZG_DELE    = ''"
         cSql += "  AND A.ZZG_STAT    <> '1'"
         cSql += "   AND A.ZZG_ORIG    = '000001'"
         cSql += "   AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','8','10')"
         cSql += " ORDER BY A.ZZG_ORDE"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_POSICAO", .T., .T. )

         T_POSICAO->( DbGoTop() )
         
         nOrdemPosi := 0

         WHILE !T_POSICAO->( EOF() )
          
            If Alltrim(T_POSICAO->ZZG_STAT) <> "2"
               T_POSICAO->( DbSkip() )
               Loop
            Endif
            
            nOrdemPosi := T_POSICAO->ZZG_ORDE

            // Vai um registro para frente. Se o registro não existir, a ordenação será a do primeiro mais intervalo.
            // Se existir, soma a ordem do primeiro + ordem do segundo e divide por dois.                            
            T_POSICAO->( DbSkip() )
            
            If T_POSICAO->( EOF() )
               nAgravar := nOrdemPosi + nIntervalo
            Else
               nAgravar := INT(((nOrdemPosi + T_POSICAO->ZZG_ORDE) / 2))
            Endif
            
            Exit
            
         ENDDO
         
         // Inseri nova tarefa com dados da tarefa de validação rejeitada
         aArea := GetArea()
         dbSelectArea("ZZG")
         RecLock("ZZG",.T.)
         ZZG_FILIAL := x_ZZG_FILIAL
         ZZG_CODI   := x_ZZG_CODI  
         ZZG_SEQU   := x_ZZG_SEQU  
         ZZG_TITU   := x_ZZG_TITU  
         ZZG_USUA   := x_ZZG_USUA  
         ZZG_DATA   := Date()
         ZZG_HORA   := Time()
         ZZG_STAT   := "10"
         ZZG_DES2   := x_ZZG_DES2  
         ZZG_PRIO   := x_ZZG_PRIO  
         ZZG_DES1   := x_ZZG_DES1
         ZZG_NOT1   := x_ZZG_NOT1
         ZZG_SOL1   := x_ZZG_SOL1
         ZZG_NOT2   := x_ZZG_NOT2  
         ZZG_TERM   := x_ZZG_TERM  
         ZZG_PROD   := x_ZZG_PROD  
         ZZG_SOL2   := x_ZZG_SOL2  
         ZZG_DELE   := x_ZZG_DELE  
         ZZG_ORIG   := x_ZZG_ORIG  
         ZZG_COMP   := x_ZZG_COMP  
         ZZG_PROG   := x_ZZG_PROG  
         ZZG_CHAM   := x_ZZG_CHAM  
         ZZG_MARK   := x_ZZG_MARK  
         ZZG_TTAR   := x_ZZG_TTAR  
         ZZG_FONT   := x_ZZG_FONT
         ZZG_ESTI   := "01"
         ZZG_ORDE   := nAgravar
         MsUnLock()              
         
         MsgAlert("Tarefa gravada com o codigo: " + Alltrim(x_ZZG_CODI) + "." + Alltrim(x_ZZG_SEQU))

      Else

         ZZG_STAT := Alltrim(Str(Int(Val(__Status))))

      Endif   

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
      ZZH_STAT := Alltrim(Str(Int(Val(__Status))))
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

         If Alltrim(Str(Int(Val(__Status)))) == "6"
            cEmail += "apresentou problemas em sua validação."
            cEmail += chr(13) + chr(10)
            cEmail += "Favor observar o campo Observações deste Status para maiores orientações."
         Else
            cEmail += "teve sua validação aprovada e está liberada para ser aplicada em produção."
         Endif

         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Sistema de Controle de Tarefas Automatech."

         U_AUTOMR20(cEmail, Alltrim(cProgramador), "", "Aviso de Movimentação de Tarefa" )
         
      Endif

      // Caso o Status for == 6 
      // O Status 6 indica que a tarefa foi encerrada por validação. Neste caso, será aberta uma nova tarefa com o mesmo número porém com sequencia diferente.
      // Envia e-mail ao gestor das tarefas informando que há necessidade de reordenação da nova tarefa.
      If Alltrim(Str(Int(Val(__Status)))) == "6"

         If Select("T_MASTER") > 0
            T_MASTER->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZJ_EMAI,"
         cSql += "       ZZJ_ACES,"
         cSql += "       ZZJ_APRO,"
         cSql += "       ZZJ_AEVE,"
         cSql += "       ZZJ_ORDE,"
         cSql += "       ZZJ_INTE,"
         cSql += "       ZZJ_REOR "
         cSql += "  FROM " + RetSqlName("ZZJ")

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

         // Elabora o e-mail
         If Empty(Alltrim(T_MASTER->ZZJ_REOR))
         Else
            cEmail := ""
            cEmail := "Prezado(a) Gestor(a)"
            cEmail += chr(13) + chr(10)
            cEmail += "A Tarefa de nº " + Alltrim(__Codigo) + " " + Alltrim(T_PROGRAMADOR->ZZG_TITU)
            cEmail += chr(13) + chr(10)
            cEmail += "foi reprovada na validação do usuário."
            cEmail += chr(13) + chr(10)   
            cEmail += "Favor verificar sua reordenação."
            cEmail += chr(13) + chr(10)
            cEmail += chr(13) + chr(10)
            cEmail += "Sistema de Controle de Tarefas Automatech."

            U_AUTOMR20(cEmail, Alltrim(T_MASTER->ZZJ_REOR), "", "Aviso de Movimentação de Tarefa" )
         Endif   

      Endif

   Endif      

   oDlgST:End()

   // Carrega o grid
   COMUSUARIOS(cComboBx1)

Return .T.