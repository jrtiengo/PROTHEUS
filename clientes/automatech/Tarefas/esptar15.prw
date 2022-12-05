#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "prtopdef.ch" 
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR15.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/09/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Tarefas de Projetos           *
//**********************************************************************************

User Function ESPTAR15(__xTipo)

   Local lChumba := .F.

   Private aComboBx1	 := {}                     // Projetos
   Private aComboBx2	 := {}                     // Usuários
   Private aComboBx3	 := {}                     // Status da Tarefa
   Private aComboBx4	 := {}                     // Prioridade
   Private aComboBx5	 := {}                     // Tipo de Tarefa
   Private aComboBx6	 := {}                     // Responsável
   Private aComboBx7	 := {"1 - Sim", "2 - Não"} // Contrato
   Private aComboBx8	 := {"0 - Informe", "1 - Serviço Cobrado", "2 - Investimento em Produto/Cliente", "3 - Suporte Interno", "4 - Outras"} // Categoria
   Private aComboBx9	 := {"A - Aberta" , "E - Encerrada" }
   Private aComboBx10    := {"S - Software" , "P - Pré-Venda" }
   Private cProjeto      := ""
   Private cCliente
   Private cUsuario
   Private cStatus  
   Private cPrioridade
   Private cTipos
   Private cResponsavel
   Private cEquipe
   Private cContrato
   Private cCategoria
   Private cSituacao 
   Private cCliente1     := Space(06)
   Private cLoja1        := Space(03)
   Private cNomeCli      := Space(60)

   Private lHoras     := .T.
   Private lContrato  := .F.

   Private cCodigo	  := Space(06)
   Private cSequencia := Space(02)
   Private cCliente   := Space(40)
   Private cTitulo	  := Space(40)
   Private cData	  := Date()
   Private cHora	  := Time()
   Private cTempo	  := Space(03)
   Private cTexto	  := ""
   Private Modalidade := "" 
   Private cInicio    := Ctod("  /  /    ")
   Private cTermino   := Ctod("  /  /    ")
   Private cCobrado   := Space(06)
   Private cMemo2

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8   
   Private oGet10   
   Private oGet11   
   Private oGet12   
   Private oGet13         

   Private oMemo1
   Private oMemo2

   Default __xTipo := "N"

   Modalidade := __xTipo

   cContrato := "2 - Não"

   Private oDlg

   If UPPER(ALLTRIM(cUserName)) = "GUSTAVO" .Or. UPPER(ALLTRIM(cUserName)) == "ADMINISTRADOR"
   Else
      cCobrado := "0"
   Endif         

   // Carrega o Combo de Usuários
   Carga_Usuario()

   // Carrega o Combo de Projetos
   Carga_Projetos()

   // Carrega o Combo de Tipo de Tarefa
   Carga_Tipos()

   // Carrega o combo do Status da Tarefa
   aComboBx3 := {}
   If Modalidade == "N"
      aAdd( aComboBx3, "2 - Aprovada" )
   Else
      aAdd( aComboBx3, "2 - Aprovada" )
   Endif

   // Carrega o combo de Prioridade
   Carga_Prioridade()

   // Carrega o combo de Responsável
   Carga_Responsavel()

   // Desenha a tela 
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Tarefas - PROJETOS" FROM C(178),C(181) TO C(581),C(888) PIXEL

   @ C(010),C(010) Jpeg FILE "logoautoma.bmp" Size C(162),C(040) PIXEL NOBORDER OF oDlg

   @ C(023),C(276) Say "Situação"            Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Código"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(033) Say "Projeto"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(167) Say "Cliente"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(274) Say "Data Inc."           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(320) Say "Hora Inc."           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(073),C(005) Say "Título da Tarefa"    Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(073),C(139) Say "Tipo de Tarefa"      Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(073),C(276) Say "Incluída por"        Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(095),C(005) Say "Prioridade"          Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(095),C(139) Say "Responsável"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(005) Say "Tarefa de Contrato"  Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(060) Say "Data Inicio"         Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(099) Say "Data Término"        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(139) Say "Categoria"           Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(276) Say "Previsão(Hrs)"       Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(316) Say "Hrs Cobradas"        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(005) Say "Descrição da Tarefa" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(174) Say "Equipe" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(163),C(174) Say "Cliente (+)" Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(002) GET oMemo2 Var cMemo2 MEMO Size C(345),C(001) PIXEL OF oDlg

   @ C(031),C(276) ComboBox cSituacao    Items aComboBx9   Size C(074),C(010) PIXEL OF oDlg
   @ C(059),C(005) MsGet    oGet1        Var   cCodigo     Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(059),C(033) ComboBox cProjeto     Items aComboBx1   Size C(128),C(010) PIXEL OF oDlg VALID(__trazCliente( cProjeto ) )
   @ C(059),C(167) MsGet    oGet6        Var   cCliente    Size C(101),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(059),C(274) MsGet    oGet3        Var   cData       Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(059),C(320) MsGet    oGet4        Var   cHora       Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(083),C(005) MsGet    oGet2        Var   cTitulo     Size C(128),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(083),C(139) ComboBox cTipos       Items aComboBx5   Size C(130),C(010) PIXEL OF oDlg
   @ C(082),C(276) ComboBox cUsuario     Items aComboBx2   Size C(074),C(010) PIXEL OF oDlg When lChumba
   @ C(105),C(005) ComboBox cPrioridade  Items aComboBx4   Size C(128),C(010) PIXEL OF oDlg
   @ C(105),C(139) ComboBox cResponsavel Items aComboBx6   Size C(210),C(010) PIXEL OF oDlg
   @ C(127),C(005) ComboBox cContrato    Items aComboBx7   Size C(045),C(010) PIXEL OF oDlg   VALID(__Contrato() )
   @ C(127),C(060) MsGet    oGet7        Var   cInicio     Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lContrato
   @ C(127),C(099) MsGet    oGet8        Var   cTermino    Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lContrato
   @ C(127),C(139) ComboBox cCategoria   Items aComboBx8   Size C(132),C(010) PIXEL OF oDlg && ON CHANge CargaHora()
   @ C(127),C(276) MsGet    oGet5        Var   cTempo      Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When !lContrato

   If UPPER(ALLTRIM(cUserName)) = "GUSTAVO" .Or. UPPER(ALLTRIM(cUserName)) == "ADMINISTRADOR"
      @ C(127),C(317) MsGet    oGet10       Var   cCobrado    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( BotaPonto15() )
   Else
      @ C(127),C(317) MsGet    oGet10       Var   cCobrado    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   Endif         

   @ C(150),C(005) GET      oMemo1  Var   cTexto MEMO Size C(163),C(032) PIXEL OF oDlg
   @ C(150),C(174) ComboBox cEquipe Items aComboBx10  Size C(072),C(010) PIXEL OF oDlg
   @ C(172),C(174) MsGet    oGet11  Var   cCliente1   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(172),C(200) MsGet    oGet12  Var   cLoja1      Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( __psqcliente(cCliente1, cLoja1) )
   @ C(172),C(221) MsGet    oGet13  Var   cNomeCli    Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(185),C(005) Button "Visão Geral do Projeto" Size C(080),C(012) PIXEL OF oDlg ACTION( U_ESPARV01(Substr(cProjeto,01,06), lHoras) )
   @ C(187),C(090) CheckBox oCheckBox1 Var lHoras  Prompt "Visualizar com Horas" Size C(060),C(008) PIXEL OF oDlg

   @ C(185),C(269) Button "Salvar"                 Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaTarefa("I") )
   @ C(185),C(311) Button "Voltar"                 Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o campo cCobrado com 0 no caso de tipo de serviço ser = a Serviço Cobrado
Static Function CargaHora()

   If Substr(cCategoria,01,01) == "1"
      If UPPER(ALLTRIM(cUserName)) = "GUSTAVO" .Or. UPPER(ALLTRIM(cUserName)) == "ADMINISTRADOR"
      Else
         cCobrado := "0"
         oGet10:Refresh()
      Endif
   Endif
   
Return(.T.)

// Função que verifica se campo cobrado possui caracteres diferentes de dígito e ponto
Static Function BotaPonto15()

   Local nContar     := 0
   Local nOcorrencia := 0

   If Empty(Alltrim(cCobrado))
      Return(.T.)
   Endif

   // Verifica quantas ocorrências de caracter diferente de dígito existem na string
   For nContar = 1 to Len(cCobrado)
       If Substr(cCobrado, nContar, 1) = " "
          Loop
       Endif
       If IsDigit(Substr(cCobrado, nContar, 1)) 
       Else
          nOcorrencia := nOcorrencia + 1
       Endif
   Next nContar

   // Indica que só foi informado dígitos
   If nOcorrencia == 0
      Return(.T.)
   Endif

   // Indica que foi informado mais do que um caracter do tipo String
   If nOcorrencia > 1
      MsgAlert("Informação inválida. Verifique!")
      cCobrado := Space(06)
      oGet10:Refresh()      
      Return(.T.)
   Endif
   
   If U_P_OCCURS(cCobrado, ".", 1) == 0      
      MsgAlert("Informação inválida. Verifique!")
      cCobrado := Space(06)
      oGet10:Refresh()      
      Return(.T.)
   Endif
   
Return(.T.)

// Função que pesquisa o cliente informado
Static Function __psqcliente(__Cliente, __cLoja)

   If Empty(Alltrim(__Cliente))
      Return(.T.)
   Endif
   
   If Empty(Alltrim(__cLoja))
      Return(.T.)
   Endif
      
   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + __Cliente + __cLoja, "A1_NOME")
   
Return(.T.)   

// Função que abre ou fecha os campos data inicio e data término conforme seleção do combo Contrato
Static Function __Contrato()

   Do Case
      Case Substr(cContrato,01,01) == "0"
           lContrato := .F.
           cInicio   := Ctod("  /  /    ")
           cTermino  := Ctod("  /  /    ")
      Case Substr(cContrato,01,01) == "1"
           lContrato := .T.
      Case Substr(cContrato,01,01) == "2"
           lContrato := .F.
           cInicio   := Ctod("  /  /    ")
           cTermino  := Ctod("  /  /    ")
   EndCase
   
   oGet7:Refresh()
   oGet8:Refresh()
   
Return(.T.)                             

// Função que pesquisa o nome do cliente para o projeto selecionado
Static Function __trazCliente( cProjeto )
 
   If Empty(cProjeto)
      cCliente := space(40)
   Endif
      
   // Pesquisa o cliente do projeto selecionado
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZY_CODIGO, "
   cSql += "       A.ZZY_CLIENT, "
   cSql += "       A.ZZY_LOJA  , "
   cSql += "       B.A1_NOME     "
   cSql += "  FROM " + RetSqlName("ZZY") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.ZZY_DELETE = ''"
   cSql += "   AND A.ZZY_CODIGO = '" + Substr(cProjeto,01,06) + "'"
   cSql += "   AND A.ZZY_DELETE = ''"
   cSql += "   AND A.ZZY_CLIENT = B.A1_COD  "
   cSql += "   AND A.ZZY_LOJA   = B.A1_LOJA "
   cSql += "   AND B.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )
   
   If T_PROJETO->( eof() )
      cCliente := Space(40)
   Else
      cCLiente := T_PROJETO->A1_NOME
   Endif
   
Return .T.         

// Altera Valor da Variável lLibera e lChumba
Static Function SalvaTarefa( _Operacao )

   Local cSql    := ""
   Local cEmail  := ""
   Local c_email := ""

   // Operação de Inclusão
   If Empty(Alltrim(cProjeto))
      MsgAlert("Projeto não informado. Verique !!")
      Return .T.
   Endif   

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

   If Empty(Alltrim(cResponsavel))
      MsgAlert("Responsável pela Tarefa não informada. Verique !!")
      Return .T.
   Endif   

   If Empty(Alltrim(cTipos))
      MsgAlert("Tipo da Tarefa não informada. Verique !!")
      Return .T.
   Endif   

//   If Empty(Alltrim(cTempo))
//      MsgAlert("Tempo Total da tarefa não informado. Verique !!")
//      Return .T.
//   Endif   

   If Substr(cContrato,01,01) == "0"
      MsgAlert("Indicação de tarefa de Contrato não informada.")
      Return(.T.)
   Endif
   
   If Substr(cContrato,01,01) == "1"

      If Empty(cInicio)
         MsgAlert("Data de Início do Contrato não informada.")
         Return(.T.)
      Endif
         
      If Empty(cTermino)
         MsgAlert("Data de Término do Contrato não informada.")
         Return(.T.)
      Endif

      If cTermino < cInicio 
         MsgAlert("Datas estão inconsistentes.")
         Return(.T.)
      Endif

   Endif
      
   If Substr(cCategoria,01,01) == "0"  
      MsgAlert("Categoria da tarefa não informada.")
      Return(.T.)
   Endif

   If Substr(cCategoria,01,01) == "1"  
      If Empty(Alltrim(cCobrado))
         MsgAlert("Horas Cobrada não informada.")
         Return(.T.)
      Endif   
   Endif

   // Pesquisa o Próximo número para inclusão
   If Select("T_NOVO") > 0
      T_NOVO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI, "
   cSql += "       ZZG_SEQU  "
   cSql += "  FROM " + RetSqlName("ZZG")
// cSql += " WHERE ZZG_DELE = ''"
   cSql += " ORDER BY ZZG_CODI DESC"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

   If T_NOVO->( EOF() )
      cCodigo    := "000001"
      cSequencia := "00"
   Else
      cCodigo    := Strzero((INT(VAL(T_NOVO->ZZG_CODI)) + 1),6)      
      cSequencia := "00"
   Endif

   // Inseri os dados na Tabela
   aArea := GetArea()
   dbSelectArea("ZZG")
   RecLock("ZZG",.T.)
   ZZG_CODI := cCodigo
   ZZG_SEQU := cSequencia
   ZZG_SITU := Substr(cSituacao,01,01)
   ZZG_PROJ := Substr(cProjeto,01,06)
   ZZG_DATA := cData
   ZZG_HORA := cHora
   ZZG_TITU := cTitulo
   ZZG_ORIG := "000002"
   ZZG_COMP := Substr(cTipos,01,06)
   ZZG_USUA := cUsuario
   ZZG_STAT := "2"
   ZZG_PRIO := Substr(cPrioridade,01,06)
   ZZG_HTOT := cTempo
   ZZG_PROG := Substr(cResponsavel,01,06)
   ZZG_DES1 := cTexto
   ZZG_TRAT := Substr(cContrato,01,01)
   ZZG_CATE := Substr(cCategoria,01,01)
   ZZG_DTAI := cInicio
   ZZG_DTAT := cTermino
   ZZG_HCOB := cCobrado
   ZZG_SITU := Substr(cSituacao,01,01)
   ZZG_EQUI := cEquipe
   ZZG_OCLI := cCliente1
   ZZG_OLOJ := cLoja1
   MsUnLock()

   // Inseri os dados na Tabela de Históricos de Tarefas
   aArea := GetArea()

   dbSelectArea("ZZH")
   RecLock("ZZH",.T.)
   ZZH_CODI := cCodigo
   ZZH_SEQU := cSequencia
   ZZH_DATA := cData
   ZZH_HORA := cHora
   ZZH_STAT := '2"
   ZZH_DELE := " "
   MsUnLock()

   cEmail := ""
   cEmail := "Prezado Roger,"
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)   
   cEmail += "Para o seu conhecimento, o usuário " + Alltrim(cUsuario) + " abriu uma nova tarefa anexada ao Projeto abaixo:"
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)
   cEmail += "Nº da Tarefa: " + cCodigo + "." + cSequencia
   cEmail += chr(13) + chr(10)
   cEmail += "Data Abertura: " + Dtoc(cData) + "/" + cHora 
   cEmail += chr(13) + chr(10)
   cEmail += "Projeto: " + SubSTr(cProjeto,10) 
   cEmail += chr(13) + chr(10)
   cEmail += "Cliente: " + Alltrim(cCliente)
   cEmail += chr(13) + chr(10)
   cEmail += "Titulo Tarefa: " + Alltrim(cTitulo) 
   cEmail += chr(13) + chr(10)
   cEmail += "Prioridade: " + SubSTr(cPrioridade,10) 
   cEmail += chr(13) + chr(10)
   cEmail += "Tipo de Tarefa: " + SubSTr(cTipos,10) 
   cEmail += chr(13) + chr(10) 
   cEmail += chr(13) + chr(10)
   cEmail += "Descrição da Tarefa:" 
   cEmail += chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += Alltrim(cTexto)
   cEmail += chr(13) + chr(10)

   MsgAlert("Tarefa gravada com o codigo: " + cCodigo + "." + cSequencia)

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
      If Modalidade == "N"      
         //U_AUTOMR20(cEmail , c_email, "", "Solicitação de Aprovação de Tarefa" )
      Endif
   Endif
   
   ODlg:End()

Return Nil                                                                   

// Função que carrega o combo de usuários
Static Function Carga_Usuario()
                  
   Local cSql := ""

   aComboBx2 := {}

   // Carrega o combo de usuarios
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, ZZA_NOME, ZZA_EMAI FROM " + RetSqlName("ZZA") + " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      MsgAlert("Cadastro de Usuários está vazio.")
      Return .T.
   Endif

   // Carrega o Combo dos Usuários do Sistema
   aComboBx2 := {}
   aAdd( aComboBx2, "          " )
   T_USUARIO->( EOF() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aComboBx2, T_USUARIO->ZZA_NOME )
      T_USUARIO->( DbSkip() )
   ENDDO
 
   // Posiciona o usuário logado
   For nContar = 1 to Len(aComboBX2)
       If Alltrim(aComboBx2[nContar]) == Alltrim(cUserName)
          cUsuario = cUserName
          Exit
       Endif
   Next nContar       
   
Return .T.

// Função que carrega o combo de projetos
Static Function Carga_Projetos()
                  
   Local cSql := ""

   aComboBx1 := {}

   // Carrega o combo de Projetos
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZY_CODIGO, "
   cSql += "       ZZY_CHAVE   "
   cSql += "  FROM " + RetSqlName("ZZY")
   cSql += " WHERE ZZY_DELETE = ''"
   cSql += " ORDER BY ZZY_CHAVE   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   If T_PROJETO->( EOF() )
      MsgAlert("Cadastro de Projetos está vazio.")
      Return .T.
   Endif

   // Carrega o Combo dos Projetos
   aComboBx1 := {}
   aAdd( aComboBx1, "          " )
   T_PROJETO->( EOF() )
   WHILE !T_PROJETO->( EOF() )
      aAdd( aComboBx1, T_PROJETO->ZZY_CODIGO + " - " + Alltrim(T_PROJETO->ZZY_CHAVE) )
      T_PROJETO->( DbSkip() )
   ENDDO
   
Return .T. 

// Função que carrega o combo de Tipos de Tarefas
Static Function Carga_Tipos()
                  
   Local cSql := ""

   aComboBx5 := {}

   // Carrega o combo de usuarios
   If Select("T_TIPOS") > 0
      T_TIPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZB_CODIGO, "
   cSql += "       ZZB_NOME    "
   cSql += "  FROM " + RetSqlName("ZZB")
   cSql += " WHERE ZZB_DELETE = '' "
   cSql += "   AND ZZB_TIPO   = 'S'"
   cSql += " ORDER BY ZZB_NOME     "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPOS", .T., .T. )

   If T_TIPOS->( EOF() )
      MsgAlert("Cadastro de Comp./Tipos de Tarefas está vazio.")
      Return .T.
   Endif

   // Carrega o Combo de Tipos de Tarefas
   aComboBx5 := {}
   aAdd( aComboBx5, "          " )
   T_TIPOS->( EOF() )
   WHILE !T_TIPOS->( EOF() )
      aAdd( aComboBx5, T_TIPOS->ZZB_CODIGO + " - " + Alltrim(T_TIPOS->ZZB_NOME) )
      T_TIPOS->( DbSkip() )
   ENDDO
   
Return .T.

// Função que carrega o combo de Prioridades
Static Function Carga_Prioridade()

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

   aComboBx4 := {}

   If !T_PRIORI->( EOF() )
      aAdd( aComboBx4, "" )
      WHILE !T_PRIORI->( EOF() )
         aAdd( aComboBx4, T_PRIORI->ZZD_CODIGO + " - " + T_PRIORI->ZZD_NOME )
         T_PRIORI->( DbSkip() )
      ENDDO
   Endif

   // Posiciona a prioridade
   For nContar = 1 to Len(aComboBX4)
       If Alltrim(Substr(aComboBx4[nContar],10)) == "MEDIA"
          cPrioridade := aComboBx4[nContar]
          Exit
       Endif
   Next nContar       

Return .T.

// Função que carrega o combo de Responsáveis
Static Function Carga_Responsavel()

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

Return .T.


