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
// Referencia: AUTOM131.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/08/2012                                                          *
// Objetivo..: Relação de Vendas por Vendedor Sintético                            *
// Parâmetros: Sem Parãmetros                                                      *
//**********************************************************************************

User Function AUTOM131()
 
   Local oGet1
   Local lChumba         := .F.
   Local _Grupo          := ""

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
   Private cComboBx1   
   Private cComboBx2   
   Private aConsulta     := {}
   Private _FlAtuacao    := ""

   // Pesquisa o Grupo do usuário logado
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

//      If Empty(Alltrim(_Grupo))
//         MsgAlert("Atenção! Você não tem permissão para emitir este relatório.")
//         Return .T.
//      Endif      

//      // Verifica se o grupo do usuárioPesquisa os valores para display
//      If Select("T_PARAMETROS") > 0
//         T_PARAMETROS->( dbCloseArea() )
//      EndIf
   
//      cSql := ""
//      cSql := "SELECT ZZ4_SVEN" 
//      cSql += "  FROM " + RetSqlName("ZZ4")

//      cSql := ChangeQuery( cSql )
//      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

//      If !T_PARAMETROS->( EOF() )
//         cSupervisor := T_PARAMETROS->ZZ4_SVEN
//      Endif
   
//      If U_P_OCCURS(T_PARAMETROS->ZZ4_SVEN, ALLTRIM(_GRUPO), 1) == 0
//         MsgAlert("Atenção! Você não tem permissão para emitir este relatório.")
//         Return .T.
//      Endif      

//      // Verifica a Fialial de Atuação do Usuário logado
//      If __CuserId == "000000"
//      Else
//         If U_P_OCCURS(T_PARAMETROS->ZZ4_SVEN, ALLTRIM(_GRUPO), 1) == 0
//            If Select("T_ATUACAO") > 0
//               T_ATUACAO->( dbCloseArea() )
//            EndIf
//   
//            cSql := ""
//            cSql := "SELECT A3_FATU" 
//            cSql += "  FROM " + RetSqlName("SA3")
//            cSql += " WHERE A3_CODUSR  = '" + Alltrim(__CuserId) + "'"
//            cSql += "   AND A3_FILIAL  = ''"
//            cSql += "   AND D_E_L_E_T_ = ''"
//
//            cSql := ChangeQuery( cSql )
//            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATUACAO", .T., .T. )
//
//            If T_ATUACAO->( EOF() )
//               MsgAlert("Filial de atuação não encontrada. Entre em contato com o Administrador do Sistema.")
//               Return .T.
//            Else
//               If Empty(Alltrim(T_ATUACAO->A3_FATU))
//                  MsgAlert("Filial de atuação não encontrada. Entre em contato com o Administrador do Sistema.")
//                  Return .T.
//               Else
//                  Do Case
//                     Case T_ATUACAO->A3_FATU == '1'
//                          _FlAtuacao := "01"
//                     Case T_ATUACAO->A3_FATU == '2'
//                          _FlAtuacao := "02"
//                     Case T_ATUACAO->A3_FATU == '3'
//                          _FlAtuacao := "03"
//                     Case T_ATUACAO->A3_FATU == '4'
//                          _FlAtuacao := "04"
//                     Case T_ATUACAO->A3_FATU == '5'
//                          _FlAtuacao := "01"
//                     Case T_ATUACAO->A3_FATU == '6'
//                          _FlAtuacao := "01"
//                  EndCase                    
//               Endif
//            Endif      
//         Endif   
//      Endif
//   Endif   

   Private oDlg

   U_AUTOM628("AUTOM131")

   DEFINE MSDIALOG oDlg TITLE "Vendas por Vendedor Sintético" FROM C(178),C(181) TO C(318),C(613) PIXEL

   @ C(004),C(005) Say "Data Inicial" Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(050) Say "Data Final"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Vendedor"     Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      
   @ C(013),C(004) MsGet oGet1 Var dData01                    Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(051) MsGet oGet2 Var dData02                    Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(036),C(004) MsGet oGet3 Var cVendedor                  Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA3") VALID( BuscaVend(cVendedor) )
   @ C(036),C(040) MsGet oGet4 Var cNomeVendedor When lChumba Size C(169),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(051),C(068) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( RODASINTE( dData01, dData02, cVendedor ) )
   @ C(051),C(107) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

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

// Função que pesquisa e emite o relatoio vendas por Vendedor - Sintético
Static Function RODASINTE( dData01, dData02, cVendedor)

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
   Local JaExiste       := .F.
   Local nContar        := 0

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

   If !Empty(Alltrim(cVendedor))
      cSql += "   AND (B.F2_VEND1 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
      cSql += "    OR B.F2_VEND2 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
      cSql += "    OR B.F2_VEND3 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
      cSql += "    OR B.F2_VEND4 = '" + Alltrim(cVendedor) + "'"  + chr(13)                 
      cSql += "    OR B.F2_VEND5 = '" + Alltrim(cVendedor) + "')" + chr(13)                 
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

   If !Empty(Alltrim(cVendedor))
//      cSql += "   AND B.F2_VEND1 = '" + Alltrim(cVendedor) + "'"  + chr(13)
      cSql += "   AND (B.F2_VEND1 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND2 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND3 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND4 = '" + Alltrim(cVendedor) + "'" 
      cSql += "    OR  B.F2_VEND5 = '" + Alltrim(cVendedor) + "')"                   
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
//      If Empty(Alltrim(_FlAtuacao))
//      Else
//         Do Case
//            Case RESULTADO->A3_FATU == "1"
//                 If _FlAtuacao <> "01"
//                    RESULTADO->( DbSkip() )                       
//                    Loop
//                 Endif
//            Case RESULTADO->A3_FATU == "2"
//                 If _FlAtuacao <> "02"
//                    RESULTADO->( DbSkip() )                       
//                    Loop
//                 Endif
//            Case RESULTADO->A3_FATU == "3"
//                 If _FlAtuacao <> "03"
//                    RESULTADO->( DbSkip() )                       
//                    Loop
//                 Endif
//            Case RESULTADO->A3_FATU == "4"
//                 If _FlAtuacao <> "04"
//                    RESULTADO->( DbSkip() )                       
//                    Loop
//                 Endif
//            Case RESULTADO->A3_FATU == "5"
//                 If _FlAtuacao <> "01"
//                    RESULTADO->( DbSkip() )                       
//                    Loop
//                 Endif
//            Case RESULTADO->A3_FATU == "6"
//                 If _FlAtuacao <> "01"
//                    RESULTADO->( DbSkip() )                       
//                    Loop
//                 Endif
//            Otherwise
//                 RESULTADO->( DbSkip() )                       
//                 Loop
//         EndCase
//      Endif

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

       SomaLinhaVen(40)

       oPrint:Say(_nLin, 1800, "EXTERNOS"                      , oFont5)  
       oPrint:Say(_nLin, 2350, Str(aConsulta[nContar,08],12,02), oFont5)  
       oPrint:Say(_nLin, 2600, Str(aConsulta[nContar,09],12,02), oFont5)  
       oPrint:Say(_nLin, 2810, Str(aConsulta[nContar,10],12,02), oFont5)  
       oPrint:Say(_nLin, 3040, Str((aConsulta[nContar,08] + aConsulta[nContar,09] + aConsulta[nContar,10]),12,02), oFont5)  

       SomaLinhaVen(40)

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

       SomaLinhaVen(60)
       
   Next nContar

   SomaLinhaVen(40)

   oPrint:Say(_nLin, 1800, "TOTAL INTERNOS DO PERIODO", oFont5)  
   oPrint:Say(_nLin, 2350, Str(nPoaInt,12,02), oFont5)
   oPrint:Say(_nLin, 2600, Str(nCxsInt,12,02), oFont5)
   oPrint:Say(_nLin, 2810, Str(nPelInt,12,02), oFont5)
   oPrint:Say(_nLin, 3040, Str((nPoaInt + nCxsInt + nPelInt),12,02), oFont5)  

   SomaLinhaVen(40)

   oPrint:Say(_nLin, 1800, "TOTAL EXTERNOS DO PERIODO", oFont5)  
   oPrint:Say(_nLin, 2350, Str(nPoaExt,12,02), oFont5)
   oPrint:Say(_nLin, 2600, Str(nCxsExt,12,02), oFont5)
   oPrint:Say(_nLin, 2810, Str(nPelExt,12,02), oFont5)
   oPrint:Say(_nLin, 3040, Str((nPoaExt + nCxsExt + nPelExt),12,02), oFont5)  
   
   SomaLinhaVen(40)

   oPrint:Say(_nLin, 1800, "TOTAL DO PERIODO"            , oFont5)  
   oPrint:Say(_nLin, 2350, Str((nPoaInt + nPoaExt),12,02), oFont5)  
   oPrint:Say(_nLin, 2600, Str((nCxsInt + nCxsExt),12,02), oFont5)  
   oPrint:Say(_nLin, 2810, Str((nPelInt + nPelExt),12,02), oFont5)  

   ngeral := 0
   nGeral := nPoaInt + nCxsInt + nPelInt + nPoaExt + nCxsExt + nPelExt

   oPrint:Say(_nLin, 3040, Str(nGeral,12,02), oFont5)  

   SomaLinhaVen(50)
      
   oPrint:EndPage()

   oPrint:Preview()
   
   MS_FLUSH()

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
Static Function SomaLinhaVen(nLinhas)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABVENSIN()
   Endif
   
Return .T.      

/*

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO DE VENDAS POR VENDEDOR                                                                    XX/XX/XXXX-XX:XX:XX
AUTOMR06.PRW                                                                       PERIODO DE XX/XX/XXXX A XX/XX/XXXX                                                                PAGINA:       XXXXX 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FL  TES  CFOP   NF      DT.EMISSAO   NR.PV  TIPO    DESCRICAO DOS PRODUTOS                                               QTD   UM    VLR PRODUTO   VLR SERVICO     VLR FRETE     DEVOLUÇÃO     VLR TOTAL
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                            VENDEDOR: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                            CLIENTE.: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
XX  XXX  X.XXX  XXXXXX  XX/XX/XXXX  XXXXXX  XXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXX.XX   XX   X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX

                                                                                                       TOTAL DO CLIENTE............:
                                                                                                       TOTAL DO VENDEDOR - INTERNAS:
                                                                                                       TOTAL DO VENDEDOR - EXTERNAS:
                                                                                                       TOTAL DO PERIODO  - INTERNAS:
                                                                                                       TOTAL DO PERIODO  - EXTERNAS:
*/
