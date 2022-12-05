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
// Referencia: ESPTAR15.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/09/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Tarefas de Projetos           *
// Parâmetros: 1 - Código da Tarefa a ser pesquisada                               *
//             2 - Tipo de Operação onde A - Alteração, E - Exclusão               *
//**********************************************************************************

User Function ESPTAR19(__Codigo, __Operacao)

   Local lChumba := .F.
   Local lHoras  := .F.

   Private aComboBx1	 := {} // Projetos
   Private aComboBx2	 := {} // Usuários
   Private aComboBx3	 := {} // Status da Tarefa
   Private aComboBx4	 := {} // Prioridade
   Private aComboBx5	 := {} // Tipo de Tarefa
   Private aComboBx6	 := {} // Responsável
   Private aComboBx7	 := {"0 - Informe", "1 - Sim", "2 - Não"}                                                                              // Contrato
   Private aComboBx8	 := {"0 - Informe", "1 - Serviço Cobrado", "2 - Investimento em Produto/Cliente", "3 - Suporte Interno", "4 - Outras"} // Categoria
   Private aComboBx9	 := {"A - Aberta", "E - Encerrada"}                                                                                    // Situação
   Private aComboBx10    := {"S - Software" , "P - Pré-Venda" }                                                                                // Equipe
   
   Private cCobrado      := Space(06)
   Private cProjeto      := ""
   Private cCliente
   Private cUsuario
   Private cStatus
   Private cPrioridade
   Private cTipos
   Private cResponsavel
   Private cContrato
   Private cCategoria
   Private cSituacao
   Private lHoras     := .T.
   Private lContrato  := .F.
   Private cEquipe
   Private cCliente1  := Space(06)
   Private cLoja1     := Space(03)
   Private cNomeCli   := Space(60)

   Private cCodigo	  := Space(06)
   Private cCliente   := Space(40)
   Private cTitulo	  := Space(40)
   Private cData	  := Date()
   Private cHora	  := Time()
   Private cTempo	  := Space(03)
   Private cTexto	  := ""
   Private cMemo2

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet10
   Private oMemo1
   Private oMemo2

   Private oDlg

   cContrato := "2 - Não"

   If Select("T_HORAS") > 0
      T_HORAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_ADMIN"
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE LTRIM(ZZE_LOGIN) = '" + Alltrim(Upper(cUserName)) + "'"
   cSql += "   AND ZZE_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )

   If T_HORAS->( EOF() )
      lHoras := .F.
   Else
      lHoras := IIF(T_HORAS->ZZE_ADMIN == "T", .T., .F.)
   Endif

   // Carrega o código da Tarefa selecionada
   cCodigo := __Codigo

   // Carrega o Combo de Usuários
   Carga_Usuario()

   // Carrega o Combo de Projetos
   Carga_Projetos()

   // Carrega o Combo de Tipo de Tarefa
   Carga_Tipos()

   // Carrega o combo de Prioridade
   Carga_Prioridade()

   // Carrega o combo de Responsável
   Carga_Responsavel()

   // Carrega o combo de Status
   aAdd( aComboBx3, "1 - Abertura")
   aAdd( aComboBx3, "2 - Aprovada")
   aAdd( aComboBx3, "3 - Reprovada")
   aAdd( aComboBx3, "4 - Desenvolvimento")
   aAdd( aComboBx3, "5 - Validação")   
   aAdd( aComboBx3, "6 - Retorno para Desenvolvimento")   
   aAdd( aComboBx3, "7 - Em Produção")   
   aAdd( aComboBx3, "8 - Liberada para Produção")   

   // Em caso de alteração, captura os dados para manipulação
   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       ZZG_TITU  ,"
   cSql += "       ZZG_USUA  ,"
   cSql += "       ZZG_DATA  ,"
   cSql += "       ZZG_HORA  ,"
   cSql += "       ZZG_STAT  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO, "
   cSql += "       ZZG_DES2  ,"
   cSql += "       ZZG_PRIO  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_NOT1)) AS NOTAS, "
   cSql += "       ZZG_NOT2  ,"
   cSql += "       ZZG_PREV  ,"
   cSql += "       ZZG_TERM  ,"
   cSql += "       ZZG_PROD  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS SOLICITAS, "
   cSql += "       ZZG_SOL2  ,"
   cSql += "       ZZG_DELE  ,"
   cSql += "       ZZG_ORIG  ,"
   cSql += "       ZZG_COMP  ,"
   cSql += "       ZZG_PROG  ,"
   cSql += "       ZZG_CHAM  ,"
   cSql += "       ZZG_PROJ  ,"
   cSql += "       ZZG_HTOT  ,"
   cSql += "       ZZG_TRAT  ,"
   cSql += "       ZZG_DTAI  ,"
   cSql += "       ZZG_DTAT  ,"
   cSql += "       ZZG_HCOB  ,"
   cSql += "       ZZG_CATE  ,"
   cSql += "       ZZG_SITU  ,"
   cSql += "       ZZG_OCLI  ,"
   cSql += "       ZZG_OLOJ  ,"
   cSql += "       ZZG_EQUI   "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Substr(cCodigo,01,06) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Substr(cCodigo,08,02) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )

   If T_TAREFA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para a tarefa selecioada.")
      Return .T.
   Endif

   cCodigo   := Alltrim(T_TAREFA->ZZG_CODI) + "." + Alltrim(T_TAREFA->ZZG_SEQU)
   cTitulo   := T_TAREFA->ZZG_TITU
   dData01   := Substr(T_TAREFA->ZZG_DATA,07,02) + "/" + Substr(T_TAREFA->ZZG_DATA,05,02) + "/" + Substr(T_TAREFA->ZZG_DATA,01,04)
   cData     := Substr(T_TAREFA->ZZG_DATA,07,02) + "/" + Substr(T_TAREFA->ZZG_DATA,05,02) + "/" + Substr(T_TAREFA->ZZG_DATA,01,04)
   cHora     := T_TAREFA->ZZG_HORA
   dPrevisto := Substr(T_TAREFA->ZZG_PREV,07,02) + "/" + Substr(T_TAREFA->ZZG_PREV,05,02) + "/" + Substr(T_TAREFA->ZZG_PREV,01,04)
   dTermino  := Substr(T_TAREFA->ZZG_TERM,07,02) + "/" + Substr(T_TAREFA->ZZG_TERM,05,02) + "/" + Substr(T_TAREFA->ZZG_TERM,01,04)
   dProducao := Substr(T_TAREFA->ZZG_PROD,07,02) + "/" + Substr(T_TAREFA->ZZG_PROD,05,02) + "/" + Substr(T_TAREFA->ZZG_PROD,01,04)
   cChamado  := T_TAREFA->ZZG_CHAM
   cChaveTex := T_TAREFA->ZZG_DES2
   cChaveNot := T_TAREFA->ZZG_NOT2
   cChaveSol := T_TAREFA->ZZG_SOL2
   cTempo    := T_TAREFA->ZZG_HTOT
   cTexto    := T_TAREFA->DESCRICAO
   cInicio   := Ctod(Substr(T_TAREFA->ZZG_DTAI,07,02) + "/" + Substr(T_TAREFA->ZZG_DTAI,05,02) + "/" + Substr(T_TAREFA->ZZG_DTAI,01,04))
   cTermino  := Ctod(Substr(T_TAREFA->ZZG_DTAT,07,02) + "/" + Substr(T_TAREFA->ZZG_DTAT,05,02) + "/" + Substr(T_TAREFA->ZZG_DTAT,01,04))
   cCobrado  := T_TAREFA->ZZG_HCOB
   cSituacao := T_TAREFA->ZZG_SITU
   cEquipe   := IIF(T_TAREFA->ZZG_EQUI == "S", "S - Software", "P - Pré-Venda") 
   cCliente1 := T_TAREFA->ZZG_OCLI
   cLoja1    := T_TAREFA->ZZG_OLOJ
   cNomeCli  := POSICIONE("SA1",1,XFILIAL("SA1") + T_TAREFA->ZZG_OCLI + T_TAREFA->ZZG_OLOJ, "A1_NOME")

   If T_TAREFA->ZZG_TRAT == "1"
      lContrato := .T.
   Else
      lContrato := .F.      
   Endif   

   // Posiciona o combo se tarefa é contrato ou não
   For nContar = 1 to Len(aComboBx7)
       If Upper(Alltrim(Substr(aComboBx7[nContar],01,01))) == Upper(Alltrim(T_TAREFA->ZZG_TRAT)) 
          cContrato := aComboBx7[nContar]
          Exit
       Endif
   Next nContar       

   // Posiciona o combo de categoria
   For nContar = 1 to Len(aComboBx8)
       If Upper(Alltrim(Substr(aComboBx8[nContar],01,01))) == Upper(Alltrim(T_TAREFA->ZZG_CATE)) 
          cCategoria := aComboBx8[nContar]
          Exit
       Endif
   Next nContar       
 
   // Posiciona o Projeto
   For nContar = 1 to Len(aComboBx1)
       If Upper(Alltrim(Substr(aComboBx1[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_PROJ)) 
          cProjeto := aComboBx1[nContar]
          Exit
       Endif
   Next nContar       

   // Posiciona o combo da Situação da Tarefa
   For nContar = 1 to Len(aComboBx9)
       If Upper(Alltrim(Substr(aComboBx9[nContar],01,01))) == Upper(Alltrim(T_TAREFA->ZZG_SITU)) 
          cSituacao := aComboBx9[nContar]
          Exit
       Endif
   Next nContar       

   // Pesquisa o Nome do Cliente do Projeto
   __trazCliente( cProjeto )

   // Localiza o Tipo de Tarefa
   For nContar = 1 to Len(aComboBx5)
       If Upper(Alltrim(Substr(aComboBx5[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_COMP)) 
          cTipos := aComboBx5[nContar]
          Exit
       Endif
   Next nContar       

   // Localiza o Usuario para display
   For nContar = 1 to Len(aComboBx2)
       If Upper(Alltrim(aComboBx2[nContar])) == Upper(Alltrim(T_TAREFA->ZZG_USUA)) 
          cUsuario := T_TAREFA->ZZG_USUA
          Exit
       Endif
   Next nContar       

   // Localiza o Status para display
   For nContar = 1 to Len(aComboBx3)
       If Upper(Alltrim(Substr(aComboBx3[nContar],01,01))) == Upper(Alltrim(T_TAREFA->ZZG_STAT)) 
          cStatus := aComboBx3[nContar]
          Exit
       Endif
   Next nContar       

   // Localiza a Prioridade
   For nContar = 1 to Len(aComboBx4)
       If Upper(Alltrim(Substr(aComboBx4[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_PRIO)) 
          cPrioridade := aComboBx4[nContar]
          Exit
       Endif
   Next nContar       

   // Localiza o Programador para display
   For nContar = 1 to Len(aComboBx6)
       If Upper(Alltrim(Substr(aComboBx6[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_PROG)) 
          cResponsavel := aComboBx6[nContar]
          Exit
       Endif
   Next nContar       

   // Desenha a tela para display dos dados
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Tarefas - PROJETOS" FROM C(178),C(181) TO C(581),C(888) PIXEL

   @ C(010),C(010) Jpeg FILE "logoautoma.bmp" Size C(162),C(040) PIXEL NOBORDER OF oDlg

   @ C(023),C(276) Say "Situação"            Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Código"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(033) Say "Projeto"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(167) Say "Cliente"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(274) Say "Data Inc"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(320) Say "Hora Inc"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
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
   @ C(127),C(139) ComboBox cCategoria   Items aComboBx8   Size C(132),C(010) PIXEL OF oDlg
   @ C(127),C(276) MsGet    oGet5        Var   cTempo      Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When !lContrato

   If UPPER(ALLTRIM(cUserName)) = "GUSTAVO" .Or. UPPER(ALLTRIM(cUserName)) == "ADMINISTRADOR"
      @ C(127),C(317) MsGet    oGet10       Var   cCobrado    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( BotaPonto() )
   Else
      @ C(127),C(317) MsGet    oGet10       Var   cCobrado    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   Endif         

   @ C(150),C(005) GET      oMemo1  Var   cTexto MEMO Size C(163),C(032) PIXEL OF oDlg
   @ C(150),C(174) ComboBox cEquipe Items aComboBx10  Size C(072),C(010) PIXEL OF oDlg
   @ C(172),C(174) MsGet    oGet11  Var   cCliente1   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(172),C(200) MsGet    oGet12  Var   cLoja1      Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( __xpsqcliente(cCliente1, cLoja1) )
   @ C(172),C(221) MsGet    oGet13  Var   cNomeCli    Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(185),C(005) Button "Visão Geral do Projeto" Size C(080),C(012) PIXEL OF oDlg ACTION( U_ESPARV01(Substr(cProjeto,01,06), lHoras) )
   @ C(187),C(090) CheckBox oCheckBox1 Var lHoras  Prompt "Visualizar com Horas" Size C(060),C(008) PIXEL OF oDlg

   @ C(185),C(227) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaTarefa( "A" ) )
   @ C(185),C(269) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaTarefa( "E" ) )      
   @ C(185),C(311) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que verifica se campo cobrado possui caracteres diferentes de dígito e ponto
Static Function BotaPonto()

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
Static Function __xpsqcliente(__Cliente, __cLoja)

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

   // Se Operação == E, exclusão da tarefa
   If _Operacao == "E"
   
      If Select("T_TEMHORAS") > 0
         T_TEMHORAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZW_HORA"
      cSql += "  FROM " + RetSqlName("ZZW")
      cSql += " WHERE ZZW_PROJ = '" + Substr(cProjeto,01,06) + "'"
      cSql += "   AND ZZW_TARE = '" + Substr(cCodigo, 01,06) + "'"
      cSql += "   AND ZZW_SEQU = '" + Substr(cCodigo, 08,02) + "'"
      cSql += "   AND ZZW_DELE = ' '

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEMHORAS", .T., .T. )

      If !T_TEMHORAS->( EOF() )
         MsgAlert("Atenção! Exclusão não permitida pois a tarefa deste projeto já possui apontamento de horas informada para ela.")
         Return(.T.)
      Endif
         
      // Verifica se tarefa do projeto pertence ao usuário logado
      If UPPER(ALLTRIM(cUserName)) == "GUSTAVO" .Or. UPPER(ALLTRIM(cUserName)) == "ADMINISTRADOR"
      Else
         
         If Select("T_DONOTAREFA") > 0
            T_DONOTAREFA->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT RTRIM(LTRIM(UPPER(ZZG_USUA))) AS DONO"
         cSql += "  FROM " + RetSqlName("ZZG")
         cSql += " WHERE ZZG_CODI = '" + Substr(cCodigo,01,06)  + "'"
         cSql += "   AND ZZG_SEQU = '" + Substr(cCodigo,08,02)  + "'"
         cSql += "   AND ZZG_PROJ = '" + Substr(cProjeto,01,06) + "'"
         cSql += "   AND ZZG_DELE = ''"
               
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DONOTAREFA", .T., .T. )
      
         If T_DONOTAREFA->DONO <> UPPER(ALLTRIM(cUserName))
            MsgAlert("Atenção! Exclusão não permitida pois você não é o responsável por esta tarefa.")
            Return(.T.)
         Endif
         
      Endif

      If MsgYesNo("Atenção! Deseja realmente excluir esta tarefa deste projeto?")
         // Exclui a Tarefa
         aArea := GetArea()
         DbSelectArea("ZZG")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZG") + Substr(cCodigo,01,06) + Substr(cCodigo,08,02))
            RecLock("ZZG",.F.)
            ZZG_DELE := "X"
            MsUnLock()              
         Endif
      Endif

      ODlg:End()
   
      Return(.T.)
   
   Endif

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

   If Substr(cContrato,01,01) == "0"
      MsgAlert("Indicação de tarefa de Contrato não informada.")
      Return(.T.)
   Endif
   
   If Substr(cSituacao,01,01) == "0"
      MsgAlert("Situação da Tarefa não informada. Verique !!")
      Return .T.
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

   // Grava as alterações realizadas
   aArea := GetArea()

   DbSelectArea("ZZG")
   DbSetOrder(1)
   If DbSeek(xfilial("ZZG") + Substr(cCodigo,01,06) + Substr(cCodigo,08,02))
      RecLock("ZZG",.F.)
      ZZG_TITU := cTitulo
      ZZG_COMP := Substr(cTipos,01,06)
      ZZG_PRIO := Substr(cPrioridade,01,06)
      ZZG_PROG := Substr(cResponsavel,01,06)      
      ZZG_HTOT := cTempo
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

   // Carrega o combo de usuarios
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZY_CODIGO, "
   cSql += "       ZZY_TITULO  "
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
      aAdd( aComboBx1, T_PROJETO->ZZY_CODIGO + " - " + Alltrim(T_PROJETO->ZZY_TITULO) )
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