#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR17.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 03/10/2011                                                          *
// Objetivo..: Vendas por Vendedor - Impressão Gráfica                             *
// Parâmetros: _Mes, _Ano	                                                       *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR17(_Mes, _Ano)
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}
   Local _Grupo         := ""

   // Variáveis Private da Função
   Private dData01       := Ctod("  /  /    ")
   Private dData02       := Ctod("  /  /    ")
   Private cVendedor     := Space(06)
   Private cNomeVendedor := Space(30)
   Private cEnderecos    := Space(200)
   Private nVias         := 1
   Private nGet1	     := Ctod("  /  /    ")
   Private nGet2	     := Ctod("  /  /    ")
   Private nGet3	     := Space(06)
   Private nGet4         := Space(100)
   Private nGet5         := Space(200)
   Private cRetorno      := Space(500)
   Private aComboBx1     := {"VIDEO", "E-MAIL"}
   Private aComboBx2     := {"NORMAL", "COMO SCHEDULE"}
   Private aComboBx3     := {"ANALÍTICO", "SINTÉTICO"}
   Private cComboBx1   
   Private cComboBx2   
   Private cComboBx3   
   Private _FlAtuacao     := ""

   Private aConsulta     := {}
   
   aConsulta := {}

   Private lWorkflow := ( dDataBase == Nil )

   U_AUTOM628("AUTOMR17")

   If lWorkflow

      If Select("SX6") > 0
         RESET ENVIRONMENT
      ENDIF

      PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'
   Endif
 
//   // Pesquisa o Grupo do usuário logado
//   If __CuserId == "000000"
//      _FlAtuacao := ""
//   Else
//      PswOrder(2)
//      If PswSeek(cUserName,.F.)
//
//         // Obtem o resultado conforme vetor
//         _aRetUser := PswRet(1)
//
//         // Carrega o código do grupo do usuário
//         If Len(_aRetUser[1][10]) <> 0
//            If Len(_aRetUser[1][10]) == 0
//               _Grupo := ""
//            Else   
//               _Grupo := _aRetUser[1][10][1]
//            Endif    
//         Else
//            _Grupo := ""       
//         Endif
//      Else
//         MsgAlert("Atenção! Você não tem permissão para emitir este relatório.")
//         Return .T.
//      Endif      
//
//      If Empty(Alltrim(_Grupo))
//         MsgAlert("Atenção! Você não tem permissão para emitir este relatório.")
//         Return .T.
//      Endif      
//
//      // Verifica se o grupo do usuárioPesquisa os valores para display
//      If Select("T_PARAMETROS") > 0
//         T_PARAMETROS->( dbCloseArea() )
//      EndIf
//   
//      cSql := ""
//      cSql := "SELECT ZZ4_SVEN" 
//      cSql += "  FROM " + RetSqlName("ZZ4")
//
//      cSql := ChangeQuery( cSql )
//      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
//
//      If !T_PARAMETROS->( EOF() )
//         cSupervisor := T_PARAMETROS->ZZ4_SVEN
//      Endif
//   
//      If U_P_OCCURS(T_PARAMETROS->ZZ4_SVEN, ALLTRIM(_GRUPO), 1) == 0
//         MsgAlert("Atenção! Você não tem permissão para emitir este relatório.")
//         Return .T.
//      Endif      
//
//      // Verifica a Fialial de Atuação do Usuário logado
//      If Select("T_ATUACAO") > 0
//         T_ATUACAO->( dbCloseArea() )
//      EndIf
//   
//      cSql := ""
//      cSql := "SELECT A3_FATU" 
//      cSql += "  FROM " + RetSqlName("SA3")
//      cSql += " WHERE A3_CODUSR  = '" + Alltrim(__CuserId) + "'"
//      cSql += "   AND A3_FILIAL  = ''"
//      cSql += "   AND D_E_L_E_T_ = ''"
//
//      cSql := ChangeQuery( cSql )
//      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATUACAO", .T., .T. )
//
//      If T_ATUACAO->( EOF() )
//         MsgAlert("Filial de atuação não encontrada. Entre em contato com o Administrador do Sistema.")
//         Return .T.
//      Else
//         If Empty(Alltrim(T_ATUACAO->A3_FATU))
//            MsgAlert("Filial de atuação não encontrada. Entre em contato com o Administrador do Sistema.")
//            Return .T.
//         Else
//            Do Case
//               Case T_ATUACAO->A3_FATU == '1'
//                    _FlAtuacao := "01"
//               Case T_ATUACAO->A3_FATU == '2'
//                    _FlAtuacao := "02"
//               Case T_ATUACAO->A3_FATU == '3'
//                    _FlAtuacao := "03"
//               Case T_ATUACAO->A3_FATU == '4'
//                    _FlAtuacao := "04"
//               Case T_ATUACAO->A3_FATU == '5'
//                    _FlAtuacao := "01"
//               Case T_ATUACAO->A3_FATU == '6'
//                    _FlAtuacao := "01"
//            EndCase                    
//         Endif
//      Endif      
//   Endif   

   // Diálogo Principal
   Private oDlg

   // Variáveis que definem a Ação do Formulário
   If lWorkflow

//     _Mes := 7
//     _Ano := 2011
      
      dData01 := Ctod("01/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))

      Do Case
         Case _Mes == 1
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 2
              If Mod(_Ano,4) == 0
                 dData02 := Ctod("29/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
              Else
                 dData02 := Ctod("28/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))                 
              Endif   
         Case _Mes == 3
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 4
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 5
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 6
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 7
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 8
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 9
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 10
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 11
              dData02 := Ctod("30/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
         Case _Mes == 12
              dData02 := Ctod("31/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
      EndCase

      cVendedor := ""
      cComboBx1 := ""

      // Pesquisa os vendedores que possuem informação de e-mail para realizar a pesquisa das vendas
      If Select("T_PESQUISA") > 0
         T_PESQUISA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_NOME  , "
      cSql += "       A3_NREDUZ, "
      cSql += "       A3_EMAIL , "
      cSql += "       A3_COD     "
      cSql += "  FROM " + RetSqlName("SA3010")
      cSql += " WHERE A3_EMAIL <> ''    "
      cSql += "   AND R_E_C_D_E_L_ = '' "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )

      If !T_PESQUISA->( Eof() )

         While !T_PESQUISA->( EOF() )
            cComboBx1 := ""
            I_VENDAS02( dData01, dData02, T_PESQUISA->A3_COD, cComboBx1)
            T_PESQUISA->( DbSkip() )
         Enddo   

         RESET ENVIRONMENT

         Return .T.
         
      Endif

   Else

      DEFINE MSDIALOG oDlg TITLE "Vendas por Vendedor - Analítico por Cliente" FROM C(178),C(181) TO C(465),C(550) PIXEL

      // Solicita o nº da etiqueta a ser impressa
      @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(040),C(005) Say "Vendedor  :  " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(040),C(075) Say cNomeVendedor   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(055),C(005) Say "Visualização:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(070),C(005) Say "Execusão:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(085),C(005) Say "Tipo:"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      
      @ C(100),C(005) Say "Enviar e-mail para os seguintes endereços (Separe os endereços com ;)" Size C(150),C(020) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(009),C(035) MsGet oGet1 Var dData01   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
      @ C(023),C(035) MsGet oGet2 Var dData02   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
      @ C(038),C(035) MsGet oGet3 Var cVendedor F3("SA3") Size C(035),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( BuscaVend(cVendedor) )
      @ C(055),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(090),C(010) PIXEL OF oDlg
      @ C(070),C(035) ComboBox cComboBx2 Items aComboBx2 Size C(090),C(010) PIXEL OF oDlg
      @ C(085),C(035) ComboBox cComboBx3 Items aComboBx3 Size C(090),C(010) PIXEL OF oDlg
      @ C(110),C(005) MsGet oGet5 Var cEnderecos when Alltrim(cComboBx1) == "E-MAIL" Size C(175),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

      DEFINE SBUTTON FROM C(128),C(132) TYPE  6 ENABLE OF oDlg ACTION( I_COMOSCHEDULE( dData01, dData02, cVendedor, cComboBx1, cComboBx2, cComboBx3))
      DEFINE SBUTTON FROM C(128),C(155) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

      ACTIVATE MSDIALOG oDlg CENTERED  

   Endif

Return(.T.)

// Função que pesquisa o vendedor informado
Static Function BuscaVend(cVendedor)

   Local cSql := ""
   
   If Empty(Alltrim(cVendedor))
      cNomeVendedor := ""
      Return .T.
   Endif
   
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_NOME "
   cSql += "  FROM " + RetSqlName("SA3010")
   cSql += " WHERE A3_COD = '" + Alltrim(cVendedor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If !T_VENDEDOR->( Eof() )
      cNomeVendedor := T_VENDEDOR->A3_NOME
   Else
      cNomeVendedor := ""
   Endif

Return .T.         

// Função que imprime o relatório como se fosse Schedule
Static Function I_COMOSCHEDULE( dData01, dData02, cVendedor, cComboBx1, cComboBx2, cComboBx3)

   Local cSql := ""

   If Alltrim(Upper(cComboBx3)) == "ANALÍTICO"

      If Empty(cVendedor)
         Msgalert("Necessario informar o vendedor a ser pesquisado.")
         Return .T.
      Endif

//      // Verifica se a filial de atuação do supervisor é igual a filial de atuação do vendedor
//      If Select("T_VENDEDOR") > 0
//         T_VENDEDOR->( dbCloseArea() )
//      EndIf
//
//      cSql := ""
//      cSql := "SELECT A3_FATU"
//      cSql += "  FROM " + RetSqlName("SA3")
//      cSql += " WHERE A3_COD     = '" + Alltrim(cVendedor) + "'"
//      cSql += "   AND A3_FILIAL  = ''"
//      cSql += "   AND D_E_L_E_T_ = ''"      
//      
//      cSql := ChangeQuery( cSql )
//      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
//      
//      If T_VENDEDOR->( EOF() )
//         MsgAlert("Vendedor não pertence a sua filial de atuação.")
//         Return .T.
//      Else
//
//         Do Case
//            Case T_VENDEDOR->A3_FATU == '1'
//                 If _FlAtuacao <> '01'
//                    MsgAlert("Vendedor não pertence a sua filial de atuação.")
//                    Return .T.
//                 Endif
//            Case T_VENDEDOR->A3_FATU == '2'
//                 If _FlAtuacao <> '02'
//                    MsgAlert("Vendedor não pertence a sua filial de atuação.")
//                    Return .T.
//                 Endif
//            Case T_VENDEDOR->A3_FATU == '3'
//                 If _FlAtuacao <> '03'
//                    MsgAlert("Vendedor não pertence a sua filial de atuação.")
//                    Return .T.
//                 Endif
//            Case T_VENDEDOR->A3_FATU == '4'
//                 If _FlAtuacao <> '04'
//                    MsgAlert("Vendedor não pertence a sua filial de atuação.")
//                    Return .T.
//                 Endif
//            Case T_VENDEDOR->A3_FATU == '5'
//                 If _FlAtuacao <> '01'
//                    MsgAlert("Vendedor não pertence a sua filial de atuação.")
//                    Return .T.
//                 Endif
//            Case T_VENDEDOR->A3_FATU == '6'
//                 If _FlAtuacao <> '01'
//                    MsgAlert("Vendedor não pertence a sua filial de atuação.")
//                    Return .T.
//                 Endif
//            OtherWise     
//                 If _FlAtuacao <> '01'
//                    MsgAlert("Vendedor não pertence a sua filial de atuação.")
//                    Return .T.
//                 Endif
//         EndCase
//
//      Endif

   Endif

   // Caso usuário selecionou "COMO SCHEDULE", alerta antes da execusão
   If Alltrim(Upper(cComboBx2)) == "COMO SCHEDULE"
      If !MsgYesNo("Atenção! Você selecionou a opção de execusão do relatório COMO SCHEDULE. Isso fará com que o relatório seja enviado via e-mail a Direção da Empresa. Deseja continuar?")
         Return .T.
      Endif
   Endif

   If Alltrim(Upper(cComboBx2)) == "NORMAL"
     
      I_VENDAS02( dData01, dData02, cVendedor, cComboBx1, cComboBx2, cComboBx3)
      
   Else

      // Pesquisa os vendedores que possuem informação de e-mail para realizar a pesquisa das vendas
      If Select("T_PESQUISA") > 0
         T_PESQUISA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_NOME  , "
      cSql += "       A3_NREDUZ, "
      cSql += "       A3_EMAIL , "
      cSql += "       A3_COD     "
      cSql += "  FROM " + RetSqlName("SA3010")
      cSql += " WHERE A3_EMAIL <> ''    "
      cSql += "   AND R_E_C_D_E_L_ = '' "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )

      If !T_PESQUISA->( Eof() )

         While !T_PESQUISA->( EOF() )
            cComboBx1 := ""
            I_VENDAS02( dData01, dData02, T_PESQUISA->A3_COD, cComboBx1)
            T_PESQUISA->( DbSkip() )
         Enddo   
         
      Endif
     
   Endif

Return .T.

// Função que prepara a impressão do relatório
Static Function I_VENDAS02( dData01, dData02, cVendedor, cComboBx1, cComboBx2, cComboBx3)

   // Declaracao de Variaveis
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Vendedor"
   Local cPict          := ""
   Local titulo         := "Vendas por Vendedor"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""
   Private limite       := 220
   Private tamanho      := "G"
   Private nomeprog     := "Faturamento-Vendedor"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Faturamento-Vendedor"
   Private cString      := "SC5"

   Private aDevolucao   := {}
   Private nDevolve     := 0

   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

   If Alltrim(cComboBx1) == "E-MAIL"
      If Empty(Alltrim(cEnderecos))
         MsgAlert("Endereços de envio de e-mail não informados.")
         Return .T.
      Endif
   Endif   

   If Alltrim(Upper(cComboBx3)) == "ANALÍTICO"

      // Pesquisa as devoluções ref. ao período informado
      If Select("T_DEVOLUCAO") > 0
         T_DEVOLUCAO->( dbCloseArea() )
      EndIf

      cSql := "" 
      cSql := "SELECT A.D1_FILIAL ," + chr(13)
      cSql += "       A.D1_DOC    ," + chr(13)
      cSql += "       A.D1_NFORI  ," + chr(13)
      cSql += "       A.D1_SERIORI," + chr(13)
      cSql += "       A.D1_EMISSAO," + chr(13)
      cSql += "       A.D1_DATORI ," + chr(13)
      cSql += "       A.D1_ITEMORI," + chr(13)
      cSql += "       A.D1_COD    ," + chr(13)
      cSql += "       A.D1_TOTAL  ," + chr(13)
      cSql += "       A.D1_TES    ," + chr(13)
      cSql += "       B.F2_EMISSAO," + chr(13)
      cSql += "       B.F2_VEND1  ," + chr(13)
      cSql += "       B.F2_VEND1  ," + chr(13)
      cSql += "       B.F2_VEND2  ," + chr(13)
      cSql += "       B.F2_VEND3  ," + chr(13)
      cSql += "       B.F2_VEND4  ," + chr(13)
      cSql += "       B.F2_VEND5   " + chr(13)
      cSql += "  FROM " + RetSqlName("SD1") + " A, " + chr(13)
      cSql += "       " + RetSqlName("SF2") + " B, " + chr(13)
      cSql += "       " + RetSqlName("SF4") + " C  " + chr(13)
      cSql += " WHERE A.D1_NFORI    <> ''"  + chr(13)
      cSql += "   AND A.R_E_C_D_E_L_ = ''"  + chr(13)
      cSql += "   AND B.R_E_C_D_E_L_ = ''"  + chr(13)
      cSql += "   AND A.D1_FILIAL = B.F2_FILIAL" + chr(13)
      cSql += "   AND A.D1_NFORI  = B.F2_DOC   " + chr(13)
      cSql += "   AND (B.F2_VEND1 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND2 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND3 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND4 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND5 = '" + Alltrim(cVendedor) + "')"                   
      cSql += "   AND A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)
      cSql += "   AND A.D1_TES      = C.F4_CODIGO " + chr(13)
      cSql += "   AND (C.F4_DUPLIC  = 'S' OR A.D1_TES = '543') " + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

      T_DEVOLUCAO->( DbGoTop() )

      While !T_DEVOLUCAO->( EOF() )

         If T_DEVOLUCAO->F2_VEND1 == cVendedor
            aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,T_DEVOLUCAO->D1_TOTAL  ,T_DEVOLUCAO->D1_EMISSAO,T_DEVOLUCAO->D1_NFORI  ,T_DEVOLUCAO->D1_SERIORI,T_DEVOLUCAO->D1_ITEMORI,.F.,"",T_DEVOLUCAO->D1_COD,T_DEVOLUCAO->F2_VEND1} )
         Endif

         If T_DEVOLUCAO->F2_VEND2 == cVendedor
            aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,T_DEVOLUCAO->D1_TOTAL  ,T_DEVOLUCAO->D1_EMISSAO,T_DEVOLUCAO->D1_NFORI  ,T_DEVOLUCAO->D1_SERIORI,T_DEVOLUCAO->D1_ITEMORI,.F.,"",T_DEVOLUCAO->D1_COD,T_DEVOLUCAO->F2_VEND1} )
         Endif
      
         If T_DEVOLUCAO->F2_VEND3 == cVendedor
            aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,T_DEVOLUCAO->D1_TOTAL  ,T_DEVOLUCAO->D1_EMISSAO,T_DEVOLUCAO->D1_NFORI  ,T_DEVOLUCAO->D1_SERIORI,T_DEVOLUCAO->D1_ITEMORI,.F.,"",T_DEVOLUCAO->D1_COD,T_DEVOLUCAO->F2_VEND1} )
         Endif

         If T_DEVOLUCAO->F2_VEND4 == cVendedor
            aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,T_DEVOLUCAO->D1_TOTAL  ,T_DEVOLUCAO->D1_EMISSAO,T_DEVOLUCAO->D1_NFORI  ,T_DEVOLUCAO->D1_SERIORI,T_DEVOLUCAO->D1_ITEMORI,.F.,"",T_DEVOLUCAO->D1_COD,T_DEVOLUCAO->F2_VEND1} )
         Endif

         If T_DEVOLUCAO->F2_VEND5 == cVendedor
            aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,T_DEVOLUCAO->D1_TOTAL  ,T_DEVOLUCAO->D1_EMISSAO,T_DEVOLUCAO->D1_NFORI  ,T_DEVOLUCAO->D1_SERIORI,T_DEVOLUCAO->D1_ITEMORI,.F.,"",T_DEVOLUCAO->D1_COD,T_DEVOLUCAO->F2_VEND1} )
         Endif

         T_DEVOLUCAO->( DbSkip() )

      Enddo

      // Pesquisa os dados para emissão do relatório
      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf

      cSql := ""   
      cSql := "SELECT A.D2_FILIAL , "
      cSql += "       B.F2_VEND1  , "
      cSql += "       B.F2_VEND2  , "
      cSql += "       B.F2_VEND3  , "
      cSql += "       B.F2_VEND4  , "
      cSql += "       B.F2_VEND5  , "        
      cSql += "       A.D2_DOC    , "
      cSql += "       A.D2_SERIE  , "
      cSql += "       A.D2_EMISSAO, "
      cSql += "       A.D2_TES    , "
      cSql += "       G.F4_DUPLIC , "
      cSql += "       G.F4_ISS    , "
      cSql += "       A.D2_CF     , "
      cSql += "       A.D2_PEDIDO , "
      cSql += "       F.C5_FRETE  , "
      cSql += "       A.D2_CLIENTE, "
      cSql += "       A.D2_LOJA   , "
      cSql += "       C.A1_NOME   , "
      cSql += "       A.D2_ITEM   , "
      cSql += "       A.D2_COD    , "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "       A.D2_UM     , "
      cSql += "       A.D2_QUANT  , "
      cSql += "       A.D2_TOTAL  , "
      cSql += "       A.D2_VALFRE , "
      cSql += "       F.C5_FORNEXT  "
      cSql += "  FROM " + RetSqlName("SD2010") + " A, "
      cSql += "       " + RetSqlName("SF2010") + " B, "
      cSql += "       " + RetSqlName("SA1010") + " C, "
      cSql += "       " + RetSqlName("SB1010") + " D, "
      cSql += "       " + RetSqlName("SC5010") + " F, "
      cSql += "       " + RetSqlName("SF4010") + " G  "
      cSql += " WHERE B.F2_DOC       = A.D2_DOC    "
      cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL "
      cSql += "   AND B.F2_SERIE     = A.D2_SERIE  "
      csql += "   AND B.F2_TIPO      = 'N'         "
      cSql += "   AND A.D2_CLIENTE   = C.A1_COD    "
      cSql += "   AND A.D2_LOJA      = C.A1_LOJA   "
      cSql += "   AND A.D2_COD       = D.B1_COD    "
      cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    "
      cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL "
      cSql += "   AND F.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.D2_TES       = G.F4_CODIGO "
      cSql += "   AND (G.F4_DUPLIC   = 'S' OR A.D2_TES = '543')"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND B.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
      cSql += "   AND (B.F2_VEND1 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND2 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND3 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND4 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND5 = '" + Alltrim(cVendedor) + "')"                   

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

      RESULTADO->( DbGoTop() )

      If RESULTADO->( Eof() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif

      // Envia para a função que imprime o relatório
      If lWorkflow
         IVENDEDORES(Cabec1,Cabec2,cVendedor,nLin)
      Else   
         Processa( {|| IVENDEDORES(Cabec1,Cabec2,cVendedor,nLin) }, "Aguarde...", "Gerando Relatório",.F.)
      Endif
      
   Else

      // Pesquisa as devoluções ref. ao período informado
      If Select("T_DEVOLUCAO") > 0
         T_DEVOLUCAO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.D1_FILIAL ,"                 + chr(13)
      cSql += "       A.D1_DOC    ,"                 + chr(13)
      cSql += "       A.D1_NFORI  ,"                 + chr(13)
      cSql += "       A.D1_SERIORI,"                 + chr(13)
      cSql += "       A.D1_EMISSAO,"                 + chr(13)
      cSql += "       A.D1_DATORI ,"                 + chr(13)
      cSql += "       A.D1_ITEMORI,"                 + chr(13)
      cSql += "       A.D1_COD    ,"                 + chr(13)
      cSql += "       A.D1_TOTAL  ,"                 + chr(13)
      cSql += "       A.D1_TES    ,"                 + chr(13)
      cSql += "       B.F2_EMISSAO,"                 + chr(13)
      cSql += "       B.F2_VEND1  ,"                 + chr(13)
      cSql += "       B.F2_VEND1  ,"                 + chr(13)
      cSql += "       B.F2_VEND2  ,"                 + chr(13)
      cSql += "       B.F2_VEND3  ,"                 + chr(13)
      cSql += "       B.F2_VEND4  ,"                 + chr(13)
      cSql += "       B.F2_VEND5  ,"                 + chr(13)
      cSql += "       D.A3_NOME   ,"                 + chr(13)
      cSql += "       D.A3_FATU    "                 + chr(13)
      cSql += "  FROM " + RetSqlName("SD1") + " A, " + chr(13)
      cSql += "       " + RetSqlName("SF2") + " B, " + chr(13)
      cSql += "       " + RetSqlName("SF4") + " C, " + chr(13)
      cSql += "       " + RetSqlName("SA3") + " D  " + chr(13)
      cSql += " WHERE A.D1_NFORI    <> ''"           + chr(13)
      cSql += "   AND A.R_E_C_D_E_L_ = ''"           + chr(13)
      cSql += "   AND B.R_E_C_D_E_L_ = ''"           + chr(13)
      cSql += "   AND A.D1_FILIAL    = B.F2_FILIAL"  + chr(13)
      cSql += "   AND A.D1_NFORI     = B.F2_DOC   "  + chr(13)
      cSql += "   AND B.F2_VEND1     = D.A3_COD   "  + chr(13)
      cSql += "   AND D.A3_FILIAL    = ''"           + chr(13)

      If !Empty(Alltrim(cVendedor))
         cSql += "   AND B.F2_VEND1 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
   //    cSql += "    OR  B.F2_VEND2 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
   //    cSql += "    OR  B.F2_VEND3 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
   //    cSql += "    OR  B.F2_VEND4 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
   //    cSql += "    OR  B.F2_VEND5 = '" + Alltrim(cVendedor) + "')" + chr(13)                 
      Endif
      
      cSql += "   AND A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)
      cSql += "   AND A.D1_TES      = C.F4_CODIGO "              + chr(13)
      cSql += "   AND (C.F4_DUPLIC  = 'S' OR A.D1_TES = '543') " + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

      // Pesquisa os dados para emissão do relatório
      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf

      cSql := ""   
      cSql := "SELECT A.D2_FILIAL , " + chr(13)
      cSql += "       B.F2_VEND1  , " + chr(13)
      cSql += "       B.F2_VEND2  , " + chr(13)
      cSql += "       B.F2_VEND3  , " + chr(13)
      cSql += "       B.F2_VEND4  , " + chr(13)
      cSql += "       B.F2_VEND5  , " + chr(13)
      cSql += "       A.D2_DOC    , " + chr(13)
      cSql += "       A.D2_SERIE  , " + chr(13)
      cSql += "       A.D2_EMISSAO, " + chr(13)
      cSql += "       A.D2_TES    , " + chr(13)
      cSql += "       G.F4_DUPLIC , " + chr(13)
      cSql += "       G.F4_ISS    , " + chr(13)
      cSql += "       A.D2_CF     , " + chr(13)
      cSql += "       A.D2_PEDIDO , " + chr(13)
      cSql += "       F.C5_FRETE  , " + chr(13)
      cSql += "       A.D2_CLIENTE, " + chr(13)
      cSql += "       A.D2_LOJA   , " + chr(13)
      cSql += "       C.A1_NOME   , " + chr(13)
      cSql += "       A.D2_ITEM   , " + chr(13)
      cSql += "       A.D2_COD    , " + chr(13)
      cSql += "       D.B1_DESC   , " + chr(13)
      cSql += "       D.B1_DAUX   , " + chr(13)
      cSql += "       A.D2_UM     , " + chr(13)
      cSql += "       A.D2_QUANT  , " + chr(13)
      cSql += "       A.D2_TOTAL  , " + chr(13)
      cSql += "       A.D2_VALFRE , " + chr(13)
      cSql += "       F.C5_FORNEXT, " + chr(13)
      cSql += "       H.A3_NOME   , " + chr(13)
      cSql += "       H.A3_FATU     " + chr(13)
      cSql += "  FROM " + RetSqlName("SD2010") + " A, " + chr(13)
      cSql += "       " + RetSqlName("SF2010") + " B, " + chr(13)
      cSql += "       " + RetSqlName("SA1010") + " C, " + chr(13)
      cSql += "       " + RetSqlName("SB1010") + " D, " + chr(13)
      cSql += "       " + RetSqlName("SC5010") + " F, " + chr(13)
      cSql += "       " + RetSqlName("SF4010") + " G, " + chr(13)
      cSql += "       " + RetSqlName("SA3010") + " H  " + chr(13)
      cSql += " WHERE B.F2_DOC       = A.D2_DOC    " + chr(13)
      cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL " + chr(13)
      cSql += "   AND B.F2_SERIE     = A.D2_SERIE  " + chr(13)
      csql += "   AND B.F2_TIPO      = 'N'         " + chr(13)
      cSql += "   AND A.D2_CLIENTE   = C.A1_COD    " + chr(13)
      cSql += "   AND A.D2_LOJA      = C.A1_LOJA   " + chr(13)
      cSql += "   AND A.D2_COD       = D.B1_COD    " + chr(13)
      cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    " + chr(13)
      cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL " + chr(13)
      cSql += "   AND F.R_E_C_D_E_L_ = ''          " + chr(13)
      cSql += "   AND A.D2_TES       = G.F4_CODIGO " + chr(13)
      cSql += "   AND (G.F4_DUPLIC   = 'S' OR A.D2_TES = '543')" + chr(13)
      cSql += "   AND A.R_E_C_D_E_L_ = ''          " + chr(13)
      cSql += "   AND B.R_E_C_D_E_L_ = ''          " + chr(13)
      cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)"
      cSql += "   AND B.F2_VEND1     = H.A3_COD    " + chr(13)
      cSql += "   AND H.A3_FILIAL    = ''"           + chr(13)

      If !Empty(Alltrim(cVendedor))
         cSql += "   AND B.F2_VEND1 = '" + Alltrim(cVendedor) + "'"  + chr(13)
   //    cSql += "   AND (B.F2_VEND1 = '" + Alltrim(cVendedor) + "'" 
   //    cSql += "    OR  B.F2_VEND2 = '" + Alltrim(cVendedor) + "'" 
   //    cSql += "    OR  B.F2_VEND3 = '" + Alltrim(cVendedor) + "'" 
   //    cSql += "    OR  B.F2_VEND4 = '" + Alltrim(cVendedor) + "'" 
   //    cSql += "    OR  B.F2_VEND5 = '" + Alltrim(cVendedor) + "')"                   
      Endif   

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

      RESULTADO->( DbGoTop() )

      If RESULTADO->( Eof() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif

      aConsulta := {}

      // Carrega o array aConsulta com os dados a serem impressos
      RESULTADO->( DbGoTop() )
      WHILE !RESULTADO->( EOF() )
   
         // Verifica se o vendedor pertence a filial de atuação do Supervisor
         If Empty(Alltrim(_FlAtuacao))
         Else
            Do Case
               Case RESULTADO->A3_FATU == "1"
                    If _FlAtuacao <> "01"
                       RESULTADO->( DbSkip() )                       
                       Loop
                    Endif
               Case RESULTADO->A3_FATU == "2"
                    If _FlAtuacao <> "02"
                       RESULTADO->( DbSkip() )                       
                       Loop
                    Endif
               Case RESULTADO->A3_FATU == "3"
                    If _FlAtuacao <> "03"
                       RESULTADO->( DbSkip() )                       
                       Loop
                    Endif
               Case RESULTADO->A3_FATU == "4"
                    If _FlAtuacao <> "04"
                       RESULTADO->( DbSkip() )                       
                       Loop
                    Endif
               Case RESULTADO->A3_FATU == "5"
                    If _FlAtuacao <> "01"
                       RESULTADO->( DbSkip() )                       
                       Loop
                    Endif
               Case RESULTADO->A3_FATU == "6"
                    If _FlAtuacao <> "01"
                       RESULTADO->( DbSkip() )                       
                       Loop
                    Endif
               Otherwise
                    RESULTADO->( DbSkip() )                       
                    Loop
            EndCase
         Endif

         // Verifica se o vendedor já está no array
         lJaExiste := .F.
         For nContar = 1 to Len(aConsulta)
             If Alltrim(aConsulta[nContar,01]) == Alltrim(RESULTADO->F2_VEND1)
                lJaExiste := .T.
                Exit
             Endif
         Next nContar
      
         If lJaExiste
         
            Do Case

               Case RESULTADO->D2_FILIAL == "01"
                    If Empty(Alltrim(RESULTADO->C5_FORNEXT))
                       aConsulta[nContar,03] := aConsulta[nContar,03] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                    Else
                       aConsulta[nContar,08] := aConsulta[nContar,08] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                    Endif
                    
               Case RESULTADO->D2_FILIAL == "02"
                    If Empty(Alltrim(RESULTADO->C5_FORNEXT))
                       aConsulta[nContar,04] := aConsulta[nContar,04] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                    Else
                       aConsulta[nContar,09] := aConsulta[nContar,09] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                    Endif
                                        
               Case RESULTADO->D2_FILIAL == "03"
                    If Empty(Alltrim(RESULTADO->C5_FORNEXT))
                       aConsulta[nContar,05] := aConsulta[nContar,05] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                    Else
                       aConsulta[nContar,10] := aConsulta[nContar,10] + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                    Endif
                                        
            EndCase
         
         Else
      
            aAdd( aConsulta, { RESULTADO->F2_VEND1, "I", 0, 0, 0, 0, "E", 0, 0, 0, 0, RESULTADO->A3_NOME } )
            Loop
         
         Endif
      
         RESULTADO->( DbSkip() )
      
      Enddo

      // Desconta os valores de Devoluções por Vendedor
      T_DEVOLUCAO->( DbGoTop() )

      While !T_DEVOLUCAO->( EOF() )

         // Localiza o vendedor no Array aConsulta
         For nContar = 1 to Len(aconsulta)

             If Alltrim(aConsulta[nContar,01]) == Alltrim(T_DEVOLUCAO->F2_VEND1)

                Do Case

                   Case T_DEVOLUCAO->D1_FILIAL == "01"
                        If Alltrim(T_DEVOLUCAO->D1_TES) <> "543"
                           aConsulta[nContar,03] := aConsulta[nContar,03] - T_DEVOLUCAO->D1_TOTAL
                        Else
                           aConsulta[nContar,08] := aConsulta[nContar,08] - T_DEVOLUCAO->D1_TOTAL
                        Endif
                    
                   Case T_DEVOLUCAO->D1_FILIAL == "02"
                        If Alltrim(T_DEVOLUCAO->D1_TES) <> "543"
                           aConsulta[nContar,04] := aConsulta[nContar,04] - T_DEVOLUCAO->D1_TOTAL
                        Else                                             
                           aConsulta[nContar,09] := aConsulta[nContar,09] - T_DEVOLUCAO->D1_TOTAL
                        Endif
                                        
                   Case T_DEVOLUCAO->D1_FILIAL == "03"
                        If Alltrim(T_DEVOLUCAO->D1_TES) <> "543"
                           aConsulta[nContar,05] := aConsulta[nContar,05] - T_DEVOLUCAO->D1_TOTAL
                        Else
                           aConsulta[nContar,10] := aConsulta[nContar,10] - T_DEVOLUCAO->D1_TOTAL
                        Endif
                                        
                EndCase
             
                Exit
             
             Endif
          
         Next nContar       

         T_DEVOLUCAO->( DbSkip() )
      
      Enddo

      // Envia para a função que imprime o relatório
      Processa( {|| LISTAVENSIN(Cabec1,Cabec2,cVendedor,nLin) }, "Aguarde...", "Gerando Relatório",.F.)
      
   Endif   

Return .T.

// Função que gera o relatório
Static Function IVENDEDORES(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor  := ""
   Local cCliente   := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local _Vendedor  := ""
   Local xContar    := 0
   Local nContar    := 0
   Local nOutrasDev := 0
   Local xVendedor  := ""
   Local xVendAnte  := ""

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape()  // Para Paisagem
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont5    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Carrega o Array aPesquisa com os dados dos 5 possíveis vendedores
   Resultado->( DbGoTop() )
   While !Resultado->( EOF() )

       For nContar = 1 to 5
           
           Do Case
              Case nContar = 1
                   If Empty(Resultado->F2_vend1)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend1) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend1
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado->F2_Vend1
                      Endif
                   Endif

              Case nContar = 2
                   If Empty(Resultado->F2_vend2)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend2) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend2
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado->F2_Vend2
                      Endif
                   Endif

              Case nContar = 3
                   If Empty(Resultado->F2_vend3)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend3) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend3
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado-F2_Vend3
                      Endif
                   Endif

              Case nContar = 4
                   If Empty(Resultado->F2_vend4)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend4) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend4
                         Else
                            Loop
                         Endif
                      Else
                         xvendedor := Resultado-F2_Vend4
                      Endif
                   Endif

              Case nContar = 5
                   If Empty(Resultado->F2_vend5)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(Resultado->F2_Vend5) == Alltrim(titulo)
                            xVendedor := Resultado->F2_vend5
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := Resultado-F2_Vend5
                      Endif
                   Endif

           EndCase
                         
           // Pesquisa o Nome do Vendedor
           If Select("T_VENDEDOR") > 0
              T_VENDEDOR->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT A3_NOME  , "
           cSql += "       A3_NREDUZ, "
           cSql += "       A3_EMAIL   "
           cSql += "  FROM " + RetSqlName("SA3010")
           cSql += " WHERE A3_COD = '" + Alltrim(xVendedor) + "'"

           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

           If !T_VENDEDOR->( Eof() )
              cNomeVendedor := T_VENDEDOR->A3_NOME
           Else
              cNomeVendedor := ""
           Endif

           T_VENDEDOR->( dbCloseArea() )

           // Verifica se existe devolução para a nota fiscal selecionada
           nDevolucao := 0
           For nDevolve = 1 to Len(aDevolucao)
               If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(Resultado->D2_DOC,01,06)) .And. ;
                  Alltrim(aDevolucao[nDevolve,05]) == Alltrim(Resultado->D2_SERIE)             .And. ;
                  Alltrim(aDevolucao[nDevolve,01]) == Alltrim(Resultado->D2_FILIAL)            .And. ;
                  Alltrim(aDevolucao[nDevolve,06]) == Alltrim(Resultado->D2_ITEM)              .And. ;
                  Alltrim(aDevolucao[nDevolve,09]) == Alltrim(Resultado->D2_COD)               

                  //.And. ;
                  //Alltrim(aDevolucao[nDevolve,10]) == Alltrim(Resultado->F2_VEND1)
                  
                  aDevolucao[nDevolve,07] := .T.
                  nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
               Endif
           Next nDevolve

           // Carrega o Array
           aPesq := {Resultado->D2_FILIAL ,; // 01
                     xVendedor            ,; // 02
                     cNomeVendedor        ,; // 03
                     Resultado->D2_DOC    ,; // 04
                     Resultado->D2_SERIE  ,; // 05
                     Resultado->D2_EMISSAO,; // 06
                     Resultado->D2_TES    ,; // 07
                     Resultado->F4_DUPLIC ,; // 08
                     Resultado->D2_CF     ,; // 09
                     Resultado->D2_PEDIDO ,; // 10
                     Resultado->C5_FRETE  ,; // 11
                     Resultado->D2_CLIENTE,; // 12
                     Resultado->D2_LOJA   ,; // 13
                     Resultado->A1_NOME   ,; // 14
                     Resultado->D2_ITEM   ,; // 15
                     Resultado->D2_COD    ,; // 16
                     Resultado->B1_DESC   ,; // 17
                     Resultado->B1_DAUX   ,; // 18
                     Resultado->D2_UM     ,; // 19
                     Resultado->D2_QUANT  ,; // 20
                     Resultado->D2_TOTAL  ,; // 21
                     Resultado->D2_VALFRE ,; // 22
                     Resultado->C5_FORNEXT,; // 23
                     nDevolucao           ,; // 24
                     Resultado->F4_ISS}      // 25
       
    	   aAdd( aPesquisa, aPesq )
       
       Next nContar
       
       Resultado->( DbSkip() )
       
   Enddo

   // Pesquisa as vendas sem vendedores
   If Empty(titulo)

      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.D2_FILIAL , "
      cSql += "       B.F2_VEND1  , "
      cSql += "       B.F2_VEND2  , "
      cSql += "       B.F2_VEND3  , "
      cSql += "       B.F2_VEND4  , "
      cSql += "       B.F2_VEND5  , "        
      cSql += "       A.D2_DOC    , "
      cSql += "       A.D2_SERIE  , "
      cSql += "       A.D2_EMISSAO, "
      cSql += "       A.D2_TES    , "
      cSql += "       G.F4_DUPLIC , "
      cSql += "       G.F4_ISS    , "
      cSql += "       A.D2_CF     , "
      cSql += "       A.D2_PEDIDO , "
      cSql += "       F.C5_FRETE  , "
      cSql += "       A.D2_CLIENTE, "
      cSql += "       A.D2_LOJA   , "
      cSql += "       C.A1_NOME   , "
      cSql += "       A.D2_ITEM   , "
      cSql += "       A.D2_COD    , "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "       A.D2_UM     , "
      cSql += "       A.D2_QUANT  , "
      cSql += "       A.D2_TOTAL  , "
      cSql += "       A.D2_VALFRE , "
      cSql += "       F.C5_FORNEXT  "
      cSql += "  FROM " + RetSqlName("SD2010") + " A, "
      cSql += "       " + RetSqlName("SF2010") + " B, "
      cSql += "       " + RetSqlName("SA1010") + " C, "
      cSql += "       " + RetSqlName("SB1010") + " D, " 
      cSql += "       " + RetSqlName("SC5010") + " F, " 
      cSql += "       " + RetSqlName("SF4010") + " G  " 
      cSql += " WHERE B.F2_DOC       = A.D2_DOC    "
      cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL "
      cSql += "   AND B.F2_SERIE     = A.D2_SERIE  "
      csql += "   AND B.F2_TIPO      = 'N'         "
      cSql += "   AND A.D2_CLIENTE   = C.A1_COD    "
      cSql += "   AND A.D2_LOJA      = C.A1_LOJA   "
      cSql += "   AND A.D2_COD       = D.B1_COD    "
      cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    "
      cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL "
      cSql += "   AND F.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.D2_TES       = G.F4_CODIGO "
      cSql += "   AND (G.F4_DUPLIC   = 'S' OR A.D2_TES = '543')"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND B.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
      cSql += "   AND B.F2_VEND1     = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

      RESULTADO->( DbGoTop() )

      While !Resultado->( EOF() )

           // Verifica se existe devolução para a nota fiscal selecionada
           nDevolucao := 0
           For nDevolve = 1 to Len(aDevolucao)
               If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(Resultado->D2_DOC,01,06)) .And. ;
                  Alltrim(aDevolucao[nDevolve,05]) == Alltrim(Resultado->D2_SERIE)             .And. ;
                  Alltrim(aDevolucao[nDevolve,01]) == Alltrim(Resultado->D2_FILIAL)            .And. ;
                  Alltrim(aDevolucao[nDevolve,06]) == Alltrim(Resultado->D2_ITEM)              .And. ;
                  Alltrim(aDevolucao[nDevolve,09]) == Alltrim(Resultado->D2_COD) 

//                Alltrim(aDevolucao[nDevolve,10]) == Alltrim(Resultado->F2_VEND1)         

                  aDevolucao[nDevolve,07] := .T.
                  nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
               Endif
           Next nDevolve

           // Carrega o Array
           aPesq := {Resultado->D2_FILIAL ,; // 01
                     "999999"             ,; // 02
                     "VENDAS SEM VENDEDOR",; // 03
                     Resultado->D2_DOC    ,; // 04
                     Resultado->D2_SERIE  ,; // 05
                     Resultado->D2_EMISSAO,; // 06
                     Resultado->D2_TES    ,; // 07
                     Resultado->F4_DUPLIC ,; // 08
                     Resultado->D2_CF     ,; // 09
                     Resultado->D2_PEDIDO ,; // 10
                     Resultado->C5_FRETE  ,; // 11
                     Resultado->D2_CLIENTE,; // 12
                     Resultado->D2_LOJA   ,; // 13
                     Resultado->A1_NOME   ,; // 14
                     Resultado->D2_ITEM   ,; // 15
                     Resultado->D2_COD    ,; // 16
                     Resultado->B1_DESC   ,; // 17
                     Resultado->B1_DAUX   ,; // 18
                     Resultado->D2_UM     ,; // 19
                     Resultado->D2_QUANT  ,; // 20
                     Resultado->D2_TOTAL  ,; // 21
                     Resultado->D2_VALFRE ,; // 22
                     Resultado->C5_FORNEXT,; // 23
                     nDevolucao           ,; // 24
                     Resultado->F4_ISS}      // 25
       
    	   aAdd( aPesquisa, aPesq )
       
           Resultado->( DbSkip() )
       
      Enddo
      
   Endif

   // Ordena o Array para Impressão
   ASORT(aPesquisa,,,{ | x,y | x[3] + x[14] < y[3] + y[14] } )

  If Len(aPesquisa) == 0
      Msgalert("Não existem dados a serem visualizadas.")
      Return .T.
   Endif

   cVendedor := aPesquisa[01,03]
   xVendAnte := aPesquisa[01,02]
   cCliente  := aPesquisa[01,14]

   // Acumuladores
   nVende01I := 0
   nVende02I := 0
   nVende03I := 0
   nDevol01I := 0
   nVende04I := 0   

   nVende01E := 0
   nVende02E := 0
   nVende03E := 0
   nDevol01E := 0
   nVende04E := 0   

   nClien01 := 0
   nClien02 := 0
   nClien03 := 0
   nClien04 := 0      
   nClien05 := 0      

   nAcumu01I := 0
   nAcumu02I := 0
   nAcumu03I := 0
   nAcumu04I := 0      
   nAcDev01I := 0

   nAcumu01E := 0
   nAcumu02E := 0
   nAcumu03E := 0
   nAcumu04E := 0      
   nAcDev01E := 0

   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( Len(aPesquisa) )

   // Envia para a função que imprime o cabeçalho dp relatório
   CABECAVEN(cVendedor, cCliente, nPagina)

   For nContar = 1 to Len(aPesquisa)
   
      If Alltrim(aPesquisa[nContar,3]) == Alltrim(cVendedor)

         If Alltrim(aPesquisa[nContar,14]) == Alltrim(cCliente)

            // Prepara o valor dos produtos e serviços a serem impressos
            If aPesquisa[nContar,08] = "S" .AND. aPesquisa[nContar,25] == "S"
               nProduto := 0
               nServico := aPesquisa[nContar,21]
            Else
               nProduto := aPesquisa[nContar,21]
               nServico := 0
            Endif

            // Impressão dos dados
            oPrint:Say(_nLin, 0100, aPesquisa[nContar,01], oFont5)  
            oPrint:Say(_nLin, 0160, Substr(aPesquisa[nContar,07],01,03), oFont5)  
            oPrint:Say(_nLin, 0220, Substr(aPesquisa[nContar,09],01,01) + "." + Substr(aPesquisa[nContar,09],02,03), oFont5)  
            oPrint:Say(_nLin, 0330, Substr(aPesquisa[nContar,04],01,06), oFont5)  
            oPrint:Say(_nLin, 0450, Substr(aPesquisa[nContar,06],07,02) + "/" + Substr(aPesquisa[nContar,06],05,02) + "/" + Substr(aPesquisa[nContar,06],01,04), oFont5)  
            oPrint:Say(_nLin, 0650, aPesquisa[nContar,10], oFont5)  
            
            If Alltrim(aPesquisa[nContar,07]) <> "543"
               oPrint:Say(_nLin, 0770, "INTERNO", oFont5)  
            Else
               oPrint:Say(_nLin, 0770, "EXTERNO", oFont5)  
            Endif

            oPrint:Say(_nLin, 0910, Substr(Alltrim(aPesquisa[nContar,17]),01,40), oFont5)  
            oPrint:Say(_nLin, 1600, Str(aPesquisa[nContar,20],10,02), oFont5)  
            oPrint:Say(_nLin, 1800, aPesquisa[nContar,19], oFont5)  
            oPrint:Say(_nLin, 2130, str(nProduto,12,02), oFont5)  
            oPrint:Say(_nLin, 2340, str(nServico,12,02), oFont5)  
            oPrint:Say(_nLin, 2560, str(aPesquisa[nContar,22],12,02), oFont5)  
            oPrint:Say(_nLin, 2780, str(aPesquisa[nContar,24],12,02), oFont5)  

            oPrint:Say(_nLin, 3000, Str((nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]),12,02), oFont5)              

            SomaLinhaVen(50,cVendedor, cCliente)

            If Alltrim(aPesquisa[nContar,07]) <> "543"            

               nVende01I := nVende01I + nProduto 
               nVende02I := nVende02I + nServico
               nVende03I := nVende03I + aPesquisa[nContar,22]
               nVende04I := nvende04I + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
               nDevol01I := nDevol01I + aPesquisa[nContar,24]

               nAcumu01I := nAcumu01I + nProduto 
               nAcumu02I := nAcumu02I + nServico
               nAcumu03I := nAcumu03I + aPesquisa[nContar,22]
               nAcumu04I := nAcumu04I + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
               nAcDev01I := nAcDev01I + aPesquisa[nContar,24]

            Else

               nVende01E := nVende01E + nProduto 
               nVende02E := nVende02E + nServico
               nVende03E := nVende03E + aPesquisa[nContar,22]
               nVende04E := nvende04E + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
               nDevol01E := nDevol01E + aPesquisa[nContar,24]
               
               nAcumu01E := nAcumu01E + nProduto 
               nAcumu02E := nAcumu02E + nServico
               nAcumu03E := nAcumu03E + aPesquisa[nContar,22]
               nAcumu04E := nAcumu04E + nProduto + nServico + aPesquisa[nContar,22]  - aPesquisa[nContar,24]
               nAcDev01E := nAcDev01E + aPesquisa[nContar,24]

            Endif               

            nClien01 := nClien01 + nProduto 
            nClien02 := nClien02 + nServico
            nClien03 := nClien03 + aPesquisa[nContar,22]
            nClien04 := nClien04 + nProduto + nServico + aPesquisa[nContar,22] - aPesquisa[nContar,24]
            nClien05 := nClien05 + aPesquisa[nContar,24]

            Loop

         Else

            SomaLinhaVen(50,cVendedor, cCliente)            
                                                                                                       
            oPrint:Say(_nLin, 1100, "TOTAL DO CLIENTE:", oFont5)
            oPrint:Say(_nLin, 2130, Str(nClien01,12,02), oFont5)
            oPrint:Say(_nLin, 2340, Str(nClien02,12,02), oFont5)
            oPrint:Say(_nLin, 2560, Str(nClien03,12,02), oFont5)
            oPrint:Say(_nLin, 2780, Str(nClien05,12,02), oFont5)
            oPrint:Say(_nLin, 3000, Str(nClien04,12,02), oFont5)
            
            nClien01 := 0
            nClien02 := 0
            nClien03 := 0
            nClien04 := 0
            nClien05 := 0

            cCliente := aPesquisa[nContar,14]

            SomaLinhaVen(100,cVendedor, cCliente)            
            
            oPrint:Say(_nLin, 1100, "CLIENTE.: " + Alltrim(aPesquisa[nContar,14]), oFont10b)  

            SomaLinhaVen(100,cVendedor, cCliente)            

            nContar := nContar - 1

         Endif
         
      Else            
      
         SomaLinhaVen(100,cVendedor, cCliente)            
            
         oPrint:Say(_nLin, 1100, "TOTAL DO CLIENTE:", oFont5)
         oPrint:Say(_nLin, 2130, Str(nClien01,12,02), oFont5)
         oPrint:Say(_nLin, 2340, Str(nClien02,12,02), oFont5)
         oPrint:Say(_nLin, 2560, Str(nClien03,12,02), oFont5)
         oPrint:Say(_nLin, 2780, Str(nClien05,12,02), oFont5)
         oPrint:Say(_nLin, 3000, Str(nClien04,12,02), oFont5)

         SomaLinhaVen(100,cVendedor, cCliente)            

         oPrint:Say(_nLin, 1100, "TOTAL DO VENDEDOR - INTERNAS:", oFont5)
         oPrint:Say(_nLin, 2130, Str(nVende01I,12,02), oFont5)
         oPrint:Say(_nLin, 2340, Str(nVende02I,12,02), oFont5)
         oPrint:Say(_nLin, 2560, Str(nVende03I,12,02), oFont5)
         oPrint:Say(_nLin, 2780, Str(nDevol01I,12,02), oFont5)
         oPrint:Say(_nLin, 3000, Str(nVende04I,12,02), oFont5)

         SomaLinhaVen(100,cVendedor, cCliente)            

         // Outras Devoluções do Vendedor
         oPrint:Say(_nLin, 1100, "TOTAL OUTRAS DEVOLUÇÕES:", oFont5)

         nOutrasDev := 0
         
         For nContar = 1 to Len(aDevolucao)
//           If aDevolucao[nContar,10] == xVendAnte
                If aDevolucao[nContar,07] == .F.
                   nOutrasDev := nOutrasDev + aDevolucao[nContar,02]
                Endif
//             Endif
         Next nContar          

         oPrint:Say(_nLin, 2780, Str(nOutrasDev,12,02), oFont5)
         oPrint:Say(_nLin, 3000, Str((nVende04I - nOutrasDev),12,02), oFont5)

         SomaLinhaVen(50,cVendedor, cCliente)            

         oPrint:Say(_nLin, 1100, "TOTAL DO VENDEDOR - EXTERNAS:", oFont5)
         oPrint:Say(_nLin, 2130, Str(nVende01E,12,02), oFont5)
         oPrint:Say(_nLin, 2340, Str(nVende02E,12,02), oFont5)
         oPrint:Say(_nLin, 2560, Str(nVende03E,12,02), oFont5)
         oPrint:Say(_nLin, 2780, Str(nDevol01E,12,02), oFont5)
         oPrint:Say(_nLin, 3000, Str(nVende04E,12,02), oFont5)
            
         SomaLinhaVen(50,cVendedor, cCliente)            

         oPrint:Say(_nLin, 1100, "TOTAL GERAL DO VENDEDOR:", oFont5)
         oPrint:Say(_nLin, 2130, Str((nVende01I + nVende01E),12,02), oFont5)
         oPrint:Say(_nLin, 2340, Str((nVende02I + nVende02E),12,02), oFont5)
         oPrint:Say(_nLin, 2560, Str((nVende03I + nVende03E),12,02), oFont5)
         oPrint:Say(_nLin, 2780, Str((nDevol01I + nDevol01E + nOutrasDev),12,02), oFont5)
         oPrint:Say(_nLin, 3000, Str((nVende04I + nVende04E - nOutrasDev),12,02), oFont5)
         
         nVende01I := 0
         nVende02I := 0
         nVende03I := 0
         nVende04I := 0
         nDevol01I := 0

         nVende01E := 0
         nVende02E := 0
         nVende03E := 0
         nVende04E := 0
         nDevol01E := 0

         nClien01 := 0
         nClien02 := 0
         nClien03 := 0
         nClien04 := 0
         nClien05 := 0

         cVendedor := aPesquisa[nContar,03]
         cVendAnte := aPesquisa[nContar,02]
         cCliente  := aPesquisa[nContar,14]

         oPrint:EndPage()

         // Limpa a página para impressão do nov ocabeçalho
         If lWorkflow .OR. Alltrim(UPPER(cComboBx2)) == "COMO SCHEDULE"
            nPagina := 0
         Endif
            
         _nLin   := 10

         CABECAVEN(cVendedor, cCliente, nPagina)

         nContar := nContar - 1

      Endif

   Next nContar

   SomaLinhaVen(100,cVendedor, cCliente)            

   oPrint:Say(_nLin, 1100, "TOTAL DO CLIENTE:", oFont5)
   oPrint:Say(_nLin, 2130, Str(nClien01,12,02), oFont5)
   oPrint:Say(_nLin, 2340, Str(nClien02,12,02), oFont5)
   oPrint:Say(_nLin, 2560, Str(nClien03,12,02), oFont5)
   oPrint:Say(_nLin, 2780, Str(nClien05,12,02), oFont5)
   oPrint:Say(_nLin, 3000, Str(nClien04,12,02), oFont5)

   SomaLinhaVen(100,cVendedor, cCliente)            

   oPrint:Say(_nLin, 1100, "TOTAL DO VENDEDOR - INTERNAS:", oFont5)
   oPrint:Say(_nLin, 2130, Str(nVende01I,12,02), oFont5)
   oPrint:Say(_nLin, 2340, Str(nVende02I,12,02), oFont5)
   oPrint:Say(_nLin, 2560, Str(nVende03I,12,02), oFont5)
   oPrint:Say(_nLin, 2780, Str(nDevol01I,12,02), oFont5)
   oPrint:Say(_nLin, 3000, Str(nVende04I,12,02), oFont5)

   SomaLinhaVen(50,cVendedor, cCliente)            

   // Outras Devoluções do Vendedor
   oPrint:Say(_nLin, 1100, "TOTAL OUTRAS DEVOLUÇÕES:", oFont5)

   nOutrasDev := 0

   For nContar = 1 to Len(aDevolucao)
//     If aDevolucao[nContar,10] == xVendAnte
          If aDevolucao[nContar,07] == .F.
             nOutrasDev := nOutrasDev + aDevolucao[nContar,02]
          Endif
//     Endif
   Next nContar          

   oPrint:Say(_nLin, 2780, Str(nOutrasDev,12,02), oFont5)
   oPrint:Say(_nLin, 3000, Str((nVende04I - nOutrasDev),12,02), oFont5)

   SomaLinhaVen(50,cVendedor, cCliente)            

   oPrint:Say(_nLin, 1100, "TOTAL DO VENDEDOR - EXTERNAS:", oFont5)
   oPrint:Say(_nLin, 2130, Str(nVende01E,12,02), oFont5)
   oPrint:Say(_nLin, 2340, Str(nVende02E,12,02), oFont5)
   oPrint:Say(_nLin, 2560, Str(nVende03E,12,02), oFont5)
   oPrint:Say(_nLin, 2780, Str(nDevol01E,12,02), oFont5)
   oPrint:Say(_nLin, 3000, Str(nVende04E,12,02), oFont5)

   SomaLinhaVen(50,cVendedor, cCliente)            

   oPrint:Say(_nLin, 1100, "TOTAL GERAL DO VENDEDOR:", oFont5)
   oPrint:Say(_nLin, 2130, Str((nVende01I + nVende01E),12,02), oFont5)
   oPrint:Say(_nLin, 2340, Str((nVende02I + nVende02E),12,02), oFont5)
   oPrint:Say(_nLin, 2560, Str((nVende03I + nVende03E),12,02), oFont5)
   oPrint:Say(_nLin, 2780, Str((nDevol01I + nDevol01E + nOutrasDev),12,02), oFont5)
   oPrint:Say(_nLin, 3000, Str((nVende04I + nVende04E - nOutrasDev),12,02), oFont5)

   SomaLinhaVen(100,cVendedor, cCliente)            
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   SomaLinhaVen(100,cVendedor, cCliente)            

   // Envia o e-mail ao vendedor
   If lWorkflow .or. Alltrim(Upper(cComboBx2)) = "COMO SCHEDULE"

      oPrint:Say(_nLin, 0100, "FIM DO RELATÓRIO", oFont5)

      oPrint:EndPage()
      
      // Gera Array com a quantidade de páginas a serem salvas em HTML
      For xContar = 1 to nPagina
          Aadd( aPaginas, xContar )
      Next xContar    

      If Empty(Alltrim(cvendedor)) .OR. Alltrim(cVendedor) == "VENDAS SEM VENDEDOR"
      Else

         // Pesquisa dados para envio de e-mail
         cEmail    := ""
         cReduzido := ""

         If Select("T_EMAIL") > 0
            T_EMAIL->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A3_NOME  , "
         cSql += "       A3_NREDUZ, "
         cSql += "       A3_EMAIL , "
         cSql += "       A3_COD     "
         cSql += "  FROM " + RetSqlName("SA3010")
         cSql += " WHERE A3_NOME = '" + ALLTRIM(cVendedor) + "'"
         cSql += "   AND R_E_C_D_E_L_ = '' "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMAIL", .T., .T. )

         If !T_EMAIL->( Eof() )
       
            cEmail    := Alltrim(T_EMAIL->A3_EMAIL)
            cReduzido := Alltrim(T_EMAIL->A3_COD)

            If !Empty(cEmail)       

               // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
               If File("\TREPORT\FAT-" + Alltrim(cReduzido)   + "-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
                  Ferase("\TREPORT\FAT-" + Alltrim(cReduzido) + "-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Endif

               cFileHTML := "\TREPORT\FAT-" + Alltrim(cReduzido) + "-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

               // Salva o relatório em HTML
               oPrint:SaveAsHtml(cFileHTML, aPaginas )

               // Envia o relatório via e-mail
               cErroEnvio := U_AUTOMR20("Em anexo, segue sua Relação de Faturamento referente ao período de " + ;
                                        Dtoc(dData01) + " a " + Dtoc(dData02)                                 , ;
                                        Alltrim(cEmail)                                                       , ;
                                        cFileHTML                                                             , ;
                                        "Relaçao de Faturamento por Vendedor referente ao período de "        + ;
                                        Dtoc(dData01) + " a " + Dtoc(dData02))
            Endif
               
         Endif

      Endif   

   Else

      oPrint:Say(_nLin, 1100, "TOTAL PERÍODO - PVS INTERNOS:", oFont5)
      oPrint:Say(_nLin, 2130, Str(nAcumu01I,12,02), oFont5)
      oPrint:Say(_nLin, 2340, Str(nAcumu02I,12,02), oFont5)
      oPrint:Say(_nLin, 2560, Str(nAcumu03I,12,02), oFont5)
      oPrint:Say(_nLin, 2780, Str(nAcDev01I,12,02), oFont5)
      oPrint:Say(_nLin, 3000, Str(nAcumu04I,12,02), oFont5)
   
      SomaLinhaVen(50,cVendedor, cCliente)            

      // Outras Devoluções do Vendedor
      oPrint:Say(_nLin, 1100, "TOTAL OUTRAS DEVOLUÇÕES:", oFont5)

      nOutrasDev := 0

      For nContar = 1 to Len(aDevolucao)
          If aDevolucao[nContar,07] == .F.
             nOutrasDev := nOutrasDev + aDevolucao[nContar,02]
          Endif
      Next nContar          

      oPrint:Say(_nLin, 2780, Str(nOutrasDev,12,02), oFont5)
      oPrint:Say(_nLin, 3000, Str((nAcumu04I - nOutrasDev),12,02), oFont5)

      SomaLinhaVen(50,cVendedor, cCliente)            

      oPrint:Say(_nLin, 1100, "TOTAL PERÍODO - PVS EXTERNOS:", oFont5)
      oPrint:Say(_nLin, 2130, Str(nAcumu01E,12,02)           , oFont5)
      oPrint:Say(_nLin, 2350, Str(nAcumu02E,12,02)           , oFont5)
      oPrint:Say(_nLin, 2560, Str(nAcumu03E,12,02)           , oFont5)
      oPrint:Say(_nLin, 2780, Str(nAcDev01E,12,02)           , oFont5)
      oPrint:Say(_nLin, 3000, Str(nAcumu04E,12,02)           , oFont5)

      SomaLinhaVen(50,cVendedor, cCliente)            

      oPrint:Say(_nLin, 1100, "TOTAL GERAL DO PERÍODO:"                      , oFont5)
      oPrint:Say(_nLin, 2130, Str((nAcumu01I + nAcumu01E),12,02)             , oFont5)
      oPrint:Say(_nLin, 2350, Str((nAcumu02I + nAcumu02E),12,02)             , oFont5)
      oPrint:Say(_nLin, 2560, Str((nAcumu03I + nAcumu03E),12,02)             , oFont5)
      oPrint:Say(_nLin, 2780, Str((nAcDev01I + nAcDev01E + nDevolucao),12,02), oFont5)
      oPrint:Say(_nLin, 3000, Str((nAcumu04I + nAcumu04E - nDevolucao),12,02), oFont5)

      SomaLinhaVen(50,cVendedor, cCliente)            
      oPrint:Line( _nLin, 0100, _nLin, 3350 )
      SomaLinhaVen(50,cVendedor, cCliente)            
      
      If Alltrim(cComboBx1) == "E-MAIL"
         oPrint:Say(_nLin, 0100, "FIM DO RELATÓRIO", oFont5)
      Endif
      
      oPrint:EndPage()

   Endif

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   Endif
   
   MS_FLUSH()

   // Envia o relatório via e-mail
   If !lWorkflow

      If Alltrim(Upper(cComboBx2)) == "NORMAL"

         If Alltrim(cComboBx1) == "E-MAIL"

            // Gera Array com a quantidade de páginas a serem salvas em HTML
            For xContar = 1 to nPagina
                Aadd( aPaginas, xContar )
            Next xContar    

            // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
            If File("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Ferase("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Endif

            cFileHTML := "\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

            // Salva o relatório em HTML
            oPrint:SaveAsHtml(cFileHTML, aPaginas )

            // Envia o relatório via e-mail
            cErroEnvio := U_AUTOMR20("Em anexo, segue Relação de Faturamento por Vendedores referente ao período de " + ;
                                     Dtoc(dData01) + " a " + Dtoc(dData02)                                            , ;
                                     Alltrim(cEnderecos)                                                              , ;
                                     cFileHTML                                                                        , ;
                                     "Relaçao de Faturamento por Vendedor referente ao período de "                   + ;
                                     Dtoc(dData01) + " a " + Dtoc(dData02))

            cVendedor     := ""
            cNomeVendedor := ""

         Else

            oPrint:Preview()
   
         Endif   
         
      Else 
      
         // Gera Array com a quantidade de páginas a serem salvas em HTML
         For xContar = 1 to nPagina
             Aadd( aPaginas, xContar )
         Next xContar    

         // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
         If File("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Ferase("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
         Endif

         cFileHTML := "\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

         // Salva o relatório em HTML
         oPrint:SaveAsHtml(cFileHTML, aPaginas )

         // Envia o relatório via e-mail
         cErroEnvio := U_AUTOMR20("Em anexo, segue Relação de Faturamento por Vendedores referente a " + ;
                                  Dtoc(dData01) + " a " + Dtoc(dData02)                                , ;
                                  "roger@automatech.com.br;evandro@automatech.com.br"                  , ;
                                  cFileHTML                                                            , ;
                                  "Relaçao de Faturamento por Vendedor referente ao período de "       + ;
                                  Dtoc(dData01) + " a " + Dtoc(dData02))

         cVendedor     := ""
         cNomeVendedor := ""
      
      Endif

   Endif

Return .T.

// Função que gera o relatório
Static Function LISTAVENSIN(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor  := ""
   Local cCliente   := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local _Vendedor  := ""
   Local xContar    := 0
   Local nContar    := 0
   Local nOutrasDev := 0
   Local xVendedor  := ""
   Local xVendAnte  := ""
   Local nGeral     := 0

   Local nPoaInt    := 0
   Local nCxsInt    := 0
   Local nPelInt    := 0
   Local nPoaExt    := 0
   Local nCxsExt    := 0
   Local nPelExt    := 0

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape()  // Para Paisagem
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont5    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   If Len(aConsulta) == 0
      Msgalert("Não existem dados a serem visualizadas.")
      Return .T.
   Endif

   // Ordena o Array para Impressão
   ASORT(aConsulta,,,{ | x,y | x[12] < y[12] } )

   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( Len(aConsulta) )

   // Envia para a função que imprime o cabeçalho dp relatório
   CABVENSIN()

   For nContar = 1 to Len(aConsulta)

       If Empty(Alltrim(aConsulta[nContar,12]))
          oPrint:Say(_nLin, 0100, "000000"                     , oFont5)  
          oPrint:Say(_nLin, 0220, "SEM VENDEDOR"               , oFont5)     
       Else
          oPrint:Say(_nLin, 0100, aConsulta[nContar,01]        , oFont5)            
          oPrint:Say(_nLin, 0220, aConsulta[nContar,12]        , oFont5)  
       Endif
       
       oPrint:Say(_nLin, 1800, "INTERNOS"                      , oFont5)  
       oPrint:Say(_nLin, 2350, Str(aConsulta[nContar,03],12,02), oFont5)  
       oPrint:Say(_nLin, 2600, Str(aConsulta[nContar,04],12,02), oFont5)  
       oPrint:Say(_nLin, 2810, Str(aConsulta[nContar,05],12,02), oFont5)  
       oPrint:Say(_nLin, 3040, Str((aConsulta[nContar,03] + aConsulta[nContar,04] + aConsulta[nContar,05]),12,02), oFont5)  

       SomaVen(40)

       oPrint:Say(_nLin, 1800, "EXTERNOS"                      , oFont5)  
       oPrint:Say(_nLin, 2350, Str(aConsulta[nContar,08],12,02), oFont5)  
       oPrint:Say(_nLin, 2600, Str(aConsulta[nContar,09],12,02), oFont5)  
       oPrint:Say(_nLin, 2810, Str(aConsulta[nContar,10],12,02), oFont5)  
       oPrint:Say(_nLin, 3040, Str((aConsulta[nContar,08] + aConsulta[nContar,09] + aConsulta[nContar,10]),12,02), oFont5)  

       SomaVen(40)

       oPrint:Say(_nLin, 1800, "TOTAL DO VENDEDOR"             , oFont5)  
       oPrint:Say(_nLin, 2350, Str((aConsulta[nContar,03] + aConsulta[nContar,08]),12,02), oFont5)  
       oPrint:Say(_nLin, 2600, Str((aConsulta[nContar,04] + aConsulta[nContar,09]),12,02), oFont5)  
       oPrint:Say(_nLin, 2810, Str((aConsulta[nContar,05] + aConsulta[nContar,10]),12,02), oFont5)  

       ngeral := 0
       nGeral := aConsulta[nContar,03] + aConsulta[nContar,04] + ;
                 aConsulta[nContar,05] + aConsulta[nContar,08] + ;
                 aConsulta[nContar,09] + aConsulta[nContar,10]

       oPrint:Say(_nLin, 3040, Str(nGeral,12,02), oFont5)  

       nPoaInt = nPoaInt + aConsulta[nContar,03]
       nCxsInt = nCxsInt + aConsulta[nContar,04]
       nPelInt = nPelInt + aConsulta[nContar,05]
       nPoaExt = nPoaExt + aConsulta[nContar,08]
       nCxsExt = nCxsExt + aConsulta[nContar,09]
       nPelExt = nPelExt + aConsulta[nContar,10]

       SomaVen(60)
       
   Next nContar

   SomaVen(40)

   oPrint:Say(_nLin, 1800, "TOTAL INTERNOS DO PERIODO", oFont5)  
   oPrint:Say(_nLin, 2350, Str(nPoaInt,12,02), oFont5)
   oPrint:Say(_nLin, 2600, Str(nCxsInt,12,02), oFont5)
   oPrint:Say(_nLin, 2810, Str(nPelInt,12,02), oFont5)
   oPrint:Say(_nLin, 3040, Str((nPoaInt + nCxsInt + nPelInt),12,02), oFont5)  

   SomaVen(40)

   oPrint:Say(_nLin, 1800, "TOTAL EXTERNOS DO PERIODO", oFont5)  
   oPrint:Say(_nLin, 2350, Str(nPoaExt,12,02), oFont5)
   oPrint:Say(_nLin, 2600, Str(nCxsExt,12,02), oFont5)
   oPrint:Say(_nLin, 2810, Str(nPelExt,12,02), oFont5)
   oPrint:Say(_nLin, 3040, Str((nPoaExt + nCxsExt + nPelExt),12,02), oFont5)  
   
   SomaVen(40)

   oPrint:Say(_nLin, 1800, "TOTAL DO PERIODO"            , oFont5)  
   oPrint:Say(_nLin, 2350, Str((nPoaInt + nPoaExt),12,02), oFont5)  
   oPrint:Say(_nLin, 2600, Str((nCxsInt + nCxsExt),12,02), oFont5)  
   oPrint:Say(_nLin, 2810, Str((nPelInt + nPelExt),12,02), oFont5)  

   ngeral := 0
   nGeral := nPoaInt + nCxsInt + nPelInt + nPoaExt + nCxsExt + nPelExt

   oPrint:Say(_nLin, 3040, Str(nGeral,12,02), oFont5)  

   SomaVen(50)
      
   oPrint:EndPage()

// oPrint:Preview()
   
   MS_FLUSH()

   // Envia o relatório via e-mail
   If !lWorkflow

      If Alltrim(Upper(cComboBx2)) == "NORMAL"

         If Alltrim(cComboBx1) == "E-MAIL"

            // Gera Array com a quantidade de páginas a serem salvas em HTML
            For xContar = 1 to nPagina
                Aadd( aPaginas, xContar )
            Next xContar    

            // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
            If File("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Ferase("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Endif

            cFileHTML := "\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

            // Salva o relatório em HTML
            oPrint:SaveAsHtml(cFileHTML, aPaginas )

            // Envia o relatório via e-mail
            cErroEnvio := U_AUTOMR20("Em anexo, segue Relação de Faturamento Sintetico por Vendedores referente ao período de " + ;
                                     Dtoc(dData01) + " a " + Dtoc(dData02)                                                      , ;
                                     Alltrim(cEnderecos)                                                                        , ;
                                     cFileHTML                                                                                  , ;
                                     "Relaçao de Faturamento Sintético por Vendedor referente ao período de "                   + ;
                                     Dtoc(dData01) + " a " + Dtoc(dData02))

            cVendedor     := ""
            cNomeVendedor := ""

         Else

            oPrint:Preview()
   
         Endif   
         
      Else 
      
         // Gera Array com a quantidade de páginas a serem salvas em HTML
         For xContar = 1 to nPagina
             Aadd( aPaginas, xContar )
         Next xContar    

         // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
         If File("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Ferase("\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
         Endif

         cFileHTML := "\TREPORT\FAT-VENDEDOR-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"

         // Salva o relatório em HTML
         oPrint:SaveAsHtml(cFileHTML, aPaginas )

         // Envia o relatório via e-mail
         cErroEnvio := U_AUTOMR20("Em anexo, segue Relação de Faturamento Sintético por Vendedores referente a " + ;
                                  Dtoc(dData01) + " a " + Dtoc(dData02)                                          , ;
                                  "roger@automatech.com.br;evandro@automatech.com.br"                            , ;
                                  cFileHTML                                                                      , ;
                                  "Relaçao de Faturamento Sintetico por Vendedor referente ao período de "       + ;
                                  Dtoc(dData01) + " a " + Dtoc(dData02))

         cVendedor     := ""
         cNomeVendedor := ""
      
      Endif

   Endif

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por Vendedor
Static Function CABECAVEN(cVendedor, cCliente)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "FATURAMENTO POR VENDEDOR"             , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR17", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "FL"                    , oFont21)  
   oPrint:Say( _nLin, 0160, "TES"                   , oFont21)  
   oPrint:Say( _nLin, 0220, "CFOP"                  , oFont21)  
   oPrint:Say( _nLin, 0330, "NF"                    , oFont21)  
   oPrint:Say( _nLin, 0450, "DT.EMISSAO"            , oFont21)  
   oPrint:Say( _nLin, 0650, "NR.PV"                 , oFont21)  
   oPrint:Say( _nLin, 0770, "TIPO"                  , oFont21)  
   oPrint:Say( _nLin, 0910, "DESCRICAO DOS PRODUTOS", oFont21)  
   oPrint:Say( _nLin, 1600, "QTD"                   , oFont21)  
   oPrint:Say( _nLin, 1800, "UM"                    , oFont21)  
   oPrint:Say( _nLin, 2130, "VLR PRODUTO"           , oFont21)  
   oPrint:Say( _nLin, 2350, "VLR SERVICO"           , oFont21)  
   oPrint:Say( _nLin, 2600, "VLR FRETE"             , oFont21)  
   oPrint:Say( _nLin, 2810, "DEVOLUÇÃO"             , oFont21)  
   oPrint:Say( _nLin, 3040, "VLR TOTAL"             , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50
   oPrint:Say( _nLin, 1100, "VENDEDOR: " + Alltrim(cVendedor), oFont10b)
   _nLin += 50
   oPrint:Say( _nLin, 1100, "CLIENTE.: " + Alltrim(cCliente), oFont10b)

   _nLin += 60

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaVen(nLinhas,cVendedor, cCliente)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAVEN(cVendedor, cCliente)
   Endif
   
Return .T.      

// Imprime o cabeçalho do relatório de Faturamento por Vendedor
Static Function CABVENSIN()

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "FATURAMENTO POR VENDEDOR - SINTÉTICO" , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM131", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "CÓDIGO"                , oFont21)  
   oPrint:Say( _nLin, 0220, "NOME DOS VENDEDORES"   , oFont21)  
   oPrint:Say( _nLin, 1800, "TIPO"                  , oFont21)  
   oPrint:Say( _nLin, 2360, "POTO ALEGRE"           , oFont21)  
   oPrint:Say( _nLin, 2590, "CAIXAS DO SUL"         , oFont21)  
   oPrint:Say( _nLin, 2870, "PELOTAS"               , oFont21)  
   oPrint:Say( _nLin, 3125, "TOTAL"                 , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

Return .T.

// Função que soma linhas para impressão
Static Function SomaVen(nLinhas)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABVENSIN()
   Endif
   
Return .T.