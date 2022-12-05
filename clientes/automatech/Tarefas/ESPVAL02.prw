#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPVAL02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/03/2014                                                          *
// Objetivo..: Programa que informa ao usuário quando existem tarefas pendentes de *
//             validação.                                                          *
//**********************************************************************************

User Function ESPVAL02()

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

   _Validacao := .T.

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
   cSql += "       A.ZZG_TITU, "
   cSql += "       B.ZZC_LEGE  "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZC") + " B  "
   cSql += " WHERE UPPER(A.ZZG_USUA) = '" + Alltrim(Upper(aUsuarios[1])) + "'"
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
                          T_VALIDACAO->ZZG_CODI,;
                          T_VALIDACAO->ZZG_TITU })
         T_VALIDACAO->( DbSkip() )
      ENDDO
   Endif

   If Len(aBrowse) == 0
      Return(.T.)
//    aAdd( aBrowse, { "", "", "" } )
   Endif   

   DEFINE MSDIALOG oDlgX TITLE "Relação de tarefas pendentes de validação." FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(004),C(005) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlgX

   @ C(015),C(165) Say "RELAÇÃO DE TAREFAS EM SEU NOME QUE ESTÃO AGUARDANDO VALIDAÇÃO." Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   
   @ C(203),C(319) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema

   oBrowse := TCBrowse():New( 040 , 005, 460, 215,,{'','Codigo', 'Título da Tarefa'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

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

   ACTIVATE MSDIALOG oDlgX CENTERED 

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
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + _Codigo + "'"

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
                          T_VALIDACAO->ZZG_CODI,;
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

   Local aStatus     := {"000006 - Retorno para Desenvolvimento", "000008 - Liberado para Produção"}
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

   If DbSeek(xfilial("ZZG") + __Codigo)

      RecLock("ZZG",.F.)
      ZZG_STAT := Substr(__Status,06,01)
      MsUnLock()                 

      // Inseri os dados na Tabela de Históricos de Tarefas
      aArea := GetArea()

      // Atualiza a tabela de histórico de tarefa
      dbSelectArea("ZZH")
      RecLock("ZZH",.T.)
      ZZH_CODI := Strzero(int(val(__Codigo)),6)
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
      cSql += "       A.ZZG_TITU  ,"
      cSql += "       A.ZZG_PROG  ,"
      cSql += "       B.ZZE_NOME  ,"
      cSql += "       B.ZZE_EMAIL  "
      cSql += "  FROM " + RetSqlName("ZZG") + " A, "
      cSql += "       " + RetSqlName("ZZE") + " B  "
      cSql += " WHERE A.ZZG_DELE   = ''"
      cSql += "   AND A.ZZG_CODI   = '" + Alltrim(__Codigo) + "'"
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
         cEmail += "A Tarefa de nº " + Strzero(int(val(__Codigo)),6) + " " + Alltrim(T_PROGRAMADOR->ZZG_TITU)
         cEmail += chr(13) + chr(10)

         If Substr(__Status,06,01) == "6"
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

   Endif      

   oDlgST:End()

   // Carrega o grid
   COMUSUARIOS(cComboBx1)

Return .T.