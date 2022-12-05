#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR03.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/02/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Tarefas                       *
//             Este programa é o que o usuário irá utilizar para inclusão de tare- *
//             fas.                                                                *
//**********************************************************************************

User Function ESPTAR03()

   Local lChumba := .F.

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea  := {}
   Local _aAlias := {}

   // Variaveis Locais da Funcao
   Private aComboBx1	 := {} // Usuários
   Private aComboBx2	 := {} // Status
   Private aComboBx3	 := {} // Prioridade
   Private aComboBx4	 := {} // Responsável
   Private aComboBx5	 := {} // Componente
   Private aComboBx6	 := {} // Programador
   Private cUsuario
   Private cStatus
   Private cPrioridade
   Private cOrigem     
   Private cComponente 
   Private cProgramador 
   Private cCodigo	     := Space(06)
   Private cSequencia    := Space(02)
   Private cTitulo	     := Space(60)
   Private dData01       := Ctod("  /  /    ")
   Private cHora         := Space(10)
   Private dPrevisto     := Ctod("  /  /    ")
   Private dTermino      := Ctod("  /  /    ")
   Private dProducao     := Ctod("  /  /    ")
   Private cChamado      := Space(50)
   Private cChaveTex     := Space(06)
   Private cChaveNot     := Space(06)
   Private cChaveSol     := Space(06)
   Private cTexto	     := ""
   Private cNota	     := ""
   Private cSolucao      := ""
   Private oGet1
   Private oGet2
   Private oGet3         := Ctod("  /  /    ")
   Private oGet4         := Ctod("  /  /    ")
   Private oGet5         := Ctod("  /  /    ")
   Private oGet6         := Ctod("  /  /    ")
   Private oGet7         := Ctod("  /  /    ")
   Private oGet8         := Space(50)
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private nContar := 0

   Private cCaminho := ""

   // Variaveis Private da Funcao
   Private oDlg				// Dialog Principal
   
   // Variaveis que definem a Acao do Formulario
   Private VISUAL := .F.                        
   Private INCLUI := .F.                        
   Private ALTERA := .F.                        
   Private DELETA := .F.                        

   // Carrega o combo de usuarios
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      MsgAlert("Cadastro de Usuários está vazio.")
      Return .T.
   Endif

   // Carrega o Combo dos Usuários do Sistema
   aComboBx1 := {}
   aAdd( aComboBx1, "          " )
   T_USUARIO->( EOF() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aComboBx1, Lower(T_USUARIO->ZZA_NOME) )
      T_USUARIO->( DbSkip() )
   ENDDO
 
   // Posiciona o usuário logado
   For nContar = 1 to Len(aComboBX1)
       If Alltrim(aComboBx1[nContar]) == Alltrim(cUserName)
          cUsuario = cUserName
          Exit
       Endif
   Next nContar       

   dData01 := Date()
   cHora   := Time()

   // Carrega o Combo de Origem
   aComboBx4 := {}
   aAdd( aComboBx4, "000001 - PROTHEUS" )
   cOrigem := "000001 - PROTHEUS"

   // Carrega o Combo de Componentes
   If Select("T_COMPO") > 0
      T_COMPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZB_CODIGO, "
   cSql += "       ZZB_NOME    "
   cSql += "  FROM " + RetSqlName("ZZB")
   cSql += " WHERE ZZB_DELETE = ''"
   cSql += " ORDER BY ZZB_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPO", .T., .T. )

   aComboBx5 := {}

   If !T_COMPO->( EOF() )
      aAdd( aComboBx5, "              " )
      WHILE !T_COMPO->( EOF() )
         aAdd( aComboBx5, T_COMPO->ZZB_CODIGO + " - " + T_COMPO->ZZB_NOME )
         T_COMPO->( DbSkip() )
      ENDDO
   Endif

   // Carrega o Combo de Desenvolvedores
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   aComboBx6 := {}

   If !T_DESENVE->( EOF() )
      aAdd( aComboBx6, "              " )
      WHILE !T_DESENVE->( EOF() )
         aAdd( aComboBx6, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )
         T_DESENVE->( DbSkip() )
      ENDDO
   Endif

   // Status das Tarefas
   //
   // 01 - Abertura de Tarefa - Aguardando Aprovação
   // 02 - Tarefa Aprovada
   // 03 - Tarefa Não Aprovada
   // 04 - Em Desenvolvimento
   // 05 - Em Validação
   // 06 - Validação Aprovada
   // 07 - Validação Reprovada
   // 08 - Encerrada (Em Produção)

   aComboBx2 := {}
   aAdd( aComboBx2, "1 - Abertura de Tarefa" )

   // Carrega o Combo de Prioidades
   If Select("T_PRIORI") > 0
      T_PRIORI->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZD_CODIGO, "
   cSql += "       ZZD_NOME    "
   cSql += "  FROM " + RetSqlName("ZZD")
   cSql += " WHERE ZZD_DELETE = ''"
   cSql += " ORDER BY ZZD_CODIGO  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORI", .T., .T. )

   aComboBx3 := {}

   If !T_PRIORI->( EOF() )
      aAdd( aComboBx3, "" )
      WHILE !T_PRIORI->( EOF() )
         aAdd( aComboBx3, T_PRIORI->ZZD_CODIGO + " - " + T_PRIORI->ZZD_NOME )
         T_PRIORI->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Tarefas" FROM C(178),C(181) TO C(440),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026)                 PIXEL NOBORDER OF oDlg

   @ C(030),C(006) Say "Tarefa"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(039) Say "Título"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(146) Say "Usuáio"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(214) Say "Data"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(259) Say "Hora"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(299) Say "Status"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(053),C(007) Say "Descrição da Tarefa"  Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(109),C(006) Say "Prioidade"            Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(109),C(085) Say "Responsável"          Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(109),C(150) Say "Componente"           Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(039),C(006) MsGet oGet1           Var   cCodigo       When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(039),C(039) MsGet oGet2           Var   cTitulo       Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   If __cUserID == "000000"
      @ C(039),C(145) ComboBox cUsuario     Items aComboBx1                  Size C(064),C(010) PIXEL OF oDlg
   Else
      @ C(039),C(145) ComboBox cUsuario     Items aComboBx1     When lChumba Size C(064),C(010) PIXEL OF oDlg
   Endif          

   @ C(039),C(214) MsGet oGet3           Var   dData01       When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(039),C(258) MsGet oGet4           Var   cHora         When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(039),C(299) ComboBox cStatus      Items aComboBx2     When lChumba Size C(087),C(010) PIXEL OF oDlg
   @ C(061),C(006) GET oMemo1            Var   cTexto MEMO   Size C(379),C(044) PIXEL OF oDlg
   @ C(118),C(006) ComboBox cPrioridade  Items aComboBx3     Size C(070),C(010) PIXEL OF oDlg
   @ C(118),C(085) ComboBox cOrigem      Items aComboBx4     When lChumba Size C(060),C(010) PIXEL OF oDlg
   @ C(118),C(150) ComboBox cComponente  Items aComboBx5     Size C(080),C(010) PIXEL OF oDlg

// @ C(115),C(260) Button "Imagem"  Size C(037),C(012) PIXEL OF oDlg ACTION( TrazImagem() )
   @ C(115),C(309) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaTarefa("I") )
   @ C(115),C(348) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION(oDlg:End() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Altera Valor da Variável lLibera e lChumba
Static Function SalvaTarefa( _Operacao )

   Local cSql    := ""
   Local cEmail  := ""
   Local c_email := ""

   // Operação de Inclusão
   If Empty(Alltrim(cUsuario))
      MsgAlert("Usuário não informado. Verique !!")
      Return .T.
   Endif   

   If Empty(Alltrim(cTitulo))
      MsgAlert("Título da Tarefa não informada. Verique !!")
      Return .T.
   Endif   

   If Empty(Alltrim(cTexto))
      MsgAlert("Descritivo da Tarefa não informada. Verique !!")
      Return .T.
   Endif   

   If Empty(Alltrim(cPrioridade))
      MsgAlert("Prioridade da Tarefa não informada. Verique !!")
      Return .T.
   Endif   

   If Empty(Alltrim(cOrigem))
      MsgAlert("Responsável pela Tarefa não informada. Verique !!")
      Return .T.
   Endif   

   If Empty(Alltrim(cComponente))
      MsgAlert("Componente da Tarefa não informada. Verique !!")
      Return .T.
   Endif   

   // Pesquisa o Próximo número para inclusão
   If Select("T_NOVO") > 0
      T_NOVO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE = ''"
   cSql += " ORDER BY ZZG_CODI DESC"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

   If T_NOVO->( EOF() )
      cCodigo    := "000001"
      cSequencia := "00"
   Else
      cCodigo := Strzero((INT(VAL(T_NOVO->ZZG_CODI)) + 1),6)      
      cSequencia := "00"
   Endif

   // Pesquisa o código de ordenação para gravação
   If Select("T_ORDENACAO") > 0
      T_ORDENACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_ORDE "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_PRIO = '" + Alltrim(Substr(cPrioridade,01,06)) + "'"
   cSql += " ORDER BY ZZG_ORDE DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDENACAO", .T., .T. )

   // Inseri os dados na Tabela
   aArea := GetArea()

   dbSelectArea("ZZG")
   RecLock("ZZG",.T.)
   ZZG_CODI := cCodigo
   ZZG_SEQU := cSequencia
   ZZG_TITU := cTitulo
   ZZG_USUA := cUsuario
   ZZG_DATA := dData01
   ZZG_HORA := cHora
   ZZG_STAT := Substr(cStatus,01,01)
   ZZG_PRIO := Substr(cPrioridade,01,06)
   ZZG_ORDE := T_ORDENACAO->ZZG_ORDE + 5
   ZZG_ORIG := Substr(cOrigem,01,06)
   ZZG_COMP := Substr(cComponente,01,06)
   ZZG_SOL1 := cSolucao
   ZZG_DES1 := cTexto
   ZZG_NOT1 := cNota

   MsUnLock()

   // Inseri os dados na Tabela de Históricos de Tarefas
   aArea := GetArea()

   dbSelectArea("ZZH")
   RecLock("ZZH",.T.)
   ZZH_CODI := cCodigo
   ZZH_SEQU := cSequencia
   ZZH_DATA := dData01
   ZZH_HORA := cHora
   ZZH_STAT := Substr(cStatus,01,01)
   ZZH_DELE := " "
   MsUnLock()

   cEmail := ""
   cEmail := "Prezado Roger,"
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)   
   cEmail += "O usuário " + Alltrim(cUsuario) + " abriu uma nova tarefa e solicita a sua aprovação."
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)
   cEmail += "Nº da Tarefa: " + cCodigo + "." + cSequencia
   cEmail += chr(13) + chr(10)
   cEmail += "Data Abertura: " + Dtoc(dData01) + "/" + cHora 
   cEmail += chr(13) + chr(10)
   cEmail += "Titulo Tarefa: " + Alltrim(cTitulo) 
   cEmail += chr(13) + chr(10)
   cEmail += "Prioridade: " + SubSTr(cPrioridade,10) 
   cEmail += chr(13) + chr(10)
   cEmail += "Componente: " + SubSTr(cComponente,10) 
   cEmail += chr(13) + chr(10) 
   cEmail += chr(13) + chr(10)
   cEmail += "Descrição da Tarefa:" 
   cEmail += chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += Alltrim(cTexto)
   cEmail += chr(13) + chr(10)

   MsgAlert("Tarefa gravada com o codigo: " + Alltrim(cCodigo) + "." + Alltrim(cSequencia))

   // Pesquisa o e-mail do aprovador
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_EMAI"
   cSql += "  FROM " + RetSqlName("ZZJ")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   If T_MASTER->( EOF() )
      c_email := ""
   Else
      c_email := T_MASTER->ZZJ_EMAI
   Endif
         
   If Empty(c_email)
   Else   
      // Envia e-mail ao Aprovador
      U_AUTOMR20(cEmail , ;
                 c_email                               , ;
                 ""                                    , ;
                 "Solicitação de Aprovação de Tarefa" )
   Endif
   
   ODlg:End()

Return Nil                                                                   

// Altera Valor da Variável lLibera e lChumba
Static Function TrazImagem()

   cCaminho := cGetFile('Imagem (*.jpg)|*.jpg| Imagem (*.png)|*.png', "Selecione a Imagem a ser Importada",1,"",.F.,16,.F.)
   
   msgalert(ccaminho)

Return .T. 
