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
// Referencia: AUTOMR16.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/09/2011                                                          *
// Objetivo..: Relatório de Faturamento por Período - GRÁFICO                      *
// Parâmetros: _Tipo -> Se = A, chamado pelo menu                                  *
//                      Se = B, chamado pela Consulta Gerencial                    *
//                      Se = X, Chamado pelo Schedule                              *
//             _Mes  -> Mês de pesquisa                                            *
//             _Ano  -> Ano de Pesquisa                                            *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR16(_Tipo, _Mes, _Ano)
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private dData01    := Ctod("  /  /    ")
   Private dData02    := Ctod("  /  /    ")
   Private cEnderecos := Space(200)
   Private __Empresa  := ""
   Private aComboBx1  := {}
   Private aComboBx2  := {"ANALÍTICO", "SINTÉTICO"}
   Private aComboBx3  := {"VIDEO", "E-MAIL"}
   Private aComboBx4  := {"NORMAL", "COMO SCHEDULE"}

   Private nGet1	  := Ctod("  /  /    ")
   Private nGet2	  := Ctod("  /  /    ")
   Private nGet3	  := Space(200)
   Private lCheck     := .F.
   Private cComboBx1
   Private cComboBx2   
   Private cComboBx3   
   Private cComboBx4   

   U_AUTOM628("AUTOMR16")
   
   // Carrega o Combo de Filiais
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   __Empresa := SM0->M0_CODIGO
 
   // #######################################################
   // Carrega o combo de filiais conforme a empresa setada ##
   // #######################################################
   aComboBx1  := U_AUTOM539(2, __Empresa)


//   Do Case
//      Case __Empresa == "01"
//           aComboBx1  := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS", "04 - SUPRIMENTOS"}
//      Case __Empresa == "02"
//           aComboBx1  := {"01 - TI CURITIBA"}
//      Case __Empresa == "03"
//           aComboBx1  := {"01 - ATECH"}
//   EndCase

// Private nUsuario := RETCODUSR()

   Private xTipo := IIF(_Tipo = "X", "X", "A")

   Private lWorkflow := ( dDataBase == Nil )

   If lWorkflow

      If Select("SX6") > 0
         RESET ENVIRONMENT
      Endif

      PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'

   Endif

   If _Tipo == "B"
      xTipo := _Tipo
   Endif   

   If xTipo == "B"

      // Porto Alegre
      Private nACIPROP := 0
      Private nACISERP := 0
      Private nACIFREP := 0
      Private nACIDEVP := 0
      Private nACITOTP := 0

      Private nACEPROP := 0
      Private nACESERP := 0
      Private nACEFREP := 0
      Private nACEDEVP := 0
      Private nACETOTP := 0

      // Caxias do Sul
      Private nACIPROC := 0
      Private nACISERC := 0
      Private nACIFREC := 0
      Private nACIDEVC := 0
      Private nACITOTC := 0

      Private nACEPROC := 0
      Private nACESERC := 0
      Private nACEFREC := 0
      Private nACEDEVC := 0
      Private nACETOTC := 0

      // Pelotas
      Private nACIPROL := 0
      Private nACISERL := 0
      Private nACIFREL := 0
      Private nACIDEVL := 0
      Private nACITOTL := 0

      Private nACEPROL := 0
      Private nACESERL := 0
      Private nACEFREL := 0
      Private nACEDEVL := 0
      Private nACETOTL := 0

      // Suprimentos
      Private nACIPROS := 0
      Private nACISERS := 0
      Private nACIFRES := 0
      Private nACIDEVS := 0
      Private nACITOTS := 0

      Private nACEPROS := 0
      Private nACESERS := 0
      Private nACEFRES := 0
      Private nACEDEVS := 0
      Private nACETOTS := 0

      Private nOutraPOA := 0
      Private nOutraCXS := 0
      Private nOutraPEL := 0
      Private nOutraSUP := 0

   Endif

   // Diálogo Principal
   Private oDlg

   // Variáveis que definem a Ação do Formulário
   If xTipo == "X"

      If lWorkflow
      
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

         FATUPER( dData01, dData02, "00 - CONSOLIDADO", "ANALÍTICO" )
         
      Endif

      RESET ENVIRONMENT      

      Return .T.
         
   Endif

   If xTipo == "A"

      DEFINE MSDIALOG oDlg TITLE "Faturamento por Período" FROM C(178),C(181) TO C(460),C(550) PIXEL

      // Solicita o nº da etiqueta a ser impressa
      @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(040),C(005) Say "Filial:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(055),C(005) Say "Tipo:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(070),C(005) Say "Visualização:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(085),C(005) Say "Execusão:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(100),C(005) Say "Enviar e-mail para os seguintes endereços (Separe os endereços com ;)" Size C(150),C(020) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(009),C(035) MsGet oGet1 Var dData01   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
      @ C(023),C(035) MsGet oGet2 Var dData02   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
      @ C(040),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(090),C(010) PIXEL OF oDlg
      @ C(055),C(035) ComboBox cComboBx2 Items aComboBx2 Size C(090),C(010) PIXEL OF oDlg
      @ C(070),C(035) ComboBox cComboBx3 Items aComboBx3 Size C(090),C(010) PIXEL OF oDlg
      @ C(085),C(035) ComboBox cComboBx4 Items aComboBx4 Size C(090),C(010) PIXEL OF oDlg
      @ C(110),C(005) MsGet oGet3 Var cEnderecos when Alltrim(cComboBx3) == "E-MAIL" Size C(175),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

      DEFINE SBUTTON FROM C(125),C(132) TYPE  6 ENABLE OF oDlg ACTION( FATUPER( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cComboBx4 ))
      DEFINE SBUTTON FROM C(125),C(155) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

      ACTIVATE MSDIALOG oDlg CENTERED  
         
   Else
   
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

      FATUPER( dData01, dData02, "00 - CONSOLIDADO", "ANALÍTICO" )

      Return nACIPROP  + nACISERP  + nACIFREP  + nACITOTP + nACEPROP + nACESERP + nACEFREP + nACETOTP + nACIPROC + nACISERC + nACIFREC + ;
             nACITOTC  + nACEPROC  + nACESERC  + nACEFREC + nACETOTC + nACIPROL + nACISERL + nACIFREL + nACITOTL + nACEPROL + nACESERL + ;
             nACEFREL  + nACETOTL  + ;
             nACIDEVP  + nACEDEVP  + nACIDEVC  + nACEDEVC + nACIDEVL + nACEDEVL + ;
             nOutraPOA + nOutraCXS + nOutraPEL + ;
             nACIPROS  + nACISERS  + nACIFRES  + nACIDEVS + nACITOTS + nACEPROS + nACESERS + nACEFRES + nACEDEVS + nACETOTS + nOutraSUP
   Endif
      
Return(.T.)

// Função que prepara a impressão do relatório
Static Function FATUPER( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cComboBx4)

   // Declaracao de Variaveis
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Período"
   Local cPict          := ""
   Local titulo         := "Vendas por Período"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}
   Local _Filial        := ""
   
   If xTipo == "A"
      _Filial := Substr(cComboBx1,01,02)
   Else
      _Filial := "00"
   Endif
   
   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""

   If xTipo == "A"
      If Alltrim(cComboBx2) == "ANALÍTICO"
         Private limite  := 220
         Private tamanho := "G"
      Else   
         Private limite  := 80
         Private tamanho := "P"
      Endif   
   Else
      Private limite  := 220
      Private tamanho := "G"
   Endif

   Private nomeprog     := "Faturamento-Periodo"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Faturamento-Periodo"
   Private cString      := "SC5"
   Private xComboBx1
   Private xComboBx2
   Private xComboBx3
   Private xComboBx4

   Private aDevolucao   := {}
   Private nDevolve     := 0

   xComboBx1 := cComboBx1
   xComboBx2 := cComboBx2
   xComboBx3 := cComboBx3
   xComboBx4 := cComboBx4

   // Caso usuário selecionou "COMO SCHEDULE", alerta antes da execusão
   If xTipo == "A"
      If Alltrim(Upper(xComboBx4)) == "COMO SCHEDULE"
         If !MsgYesNo("Atenção! Você selecionou a opção de execusão do relatório COMO SCHEDULE. Isso fará com que o relatório seja enviado via e-mail a Direção da Empresa. Deseja continuar?")
            Return .T.
         Endif
      Endif
   Endif

   // Consistência dos Dados
   If !lWorkflow
      If Empty(dData01)
         MsgAlert("Data inicial de faturamento não informada.")
         Return .T.
      Endif
      
      If Empty(dData02)
         MsgAlert("Data final de faturamento não informada.")
         Return .T.
      Endif

      If Alltrim(xComboBx3) == "E-MAIL"
         If Empty(Alltrim(cEnderecos))
            MsgAlert("Endereços de envio de e-mail não informados.")
            Return .T.
         Endif
      Endif   

   Endif

   // Pesquisa as devoluções ref. ao período informado
   If Select("T_DEVOLUCAO") > 0
      T_DEVOLUCAO->( dbCloseArea() )
   EndIf

   csql = ""
   csql += "SELECT A.D1_FILIAL  ,"
   csql += "       A.D1_TOTAL   ,"
   csql += "       A.D1_EMISSAO ,"
   csql += "       A.D1_NFORI   ,"
   csql += "       A.D1_SERIORI ," 
   csql += "       A.D1_ITEMORI ,"
   csql += "       C.F2_EMISSAO  "
   csql += "  FROM " + RetSqlName("SD1010") + " A, "
   cSql += "       " + RetSqlName("SF4010") + " B, "
   cSql += "       " + retSqlName("SF2010") + " C  "
   cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)"

   If _Filial <> "00"
     cSql += " AND A.D1_FILIAL = '" + Alltrim(_Filial) + "'" 
   Endif

   csql += "   AND A.D1_NFORI    <> ''"
   csql += "   AND A.R_E_C_D_E_L_ = ''"
   csql += "   AND A.D1_SERIORI = C.F2_SERIE"
   csql += "   AND A.D1_NFORI   = C.F2_DOC  "
   cSql += "   AND A.D1_TES       = B.F4_CODIGO "

   cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "

   cSql += "   AND A.D1_CF IN ('1201','1202','1411','2201','2202','2411')"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

   T_DEVOLUCAO->( DbGoTop() )

   While !T_DEVOLUCAO->( EOF() )

//     If Substr(T_DEVOLUCAO->F2_EMISSAO,01,06) == Substr(Dtoc(dData01),07,04) + Substr(Dtoc(dData01),04,02)

        aAdd( aDevolucao, { T_DEVOLUCAO->D1_FILIAL ,;
                            T_DEVOLUCAO->D1_TOTAL  ,;
                            T_DEVOLUCAO->D1_EMISSAO,;
                            T_DEVOLUCAO->D1_NFORI  ,;
                            T_DEVOLUCAO->D1_SERIORI,;
                            T_DEVOLUCAO->D1_ITEMORI,;
                            .F.                    ,;
                            "" } )

//     Endif
                                 
     T_DEVOLUCAO->( DbSkip() )

   Enddo

   // Pesquisa os dados para emissão do relatório
   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.D2_FILIAL , " + CHR(13)
   cSql += "       A.D2_DOC    , " + CHR(13)
   cSql += "       A.D2_SERIE  , " + CHR(13)
   cSql += "       A.D2_EMISSAO, " + CHR(13)
   cSql += "       A.D2_TES    , " + CHR(13)
   cSql += "       G.F4_DUPLIC , " + CHR(13)
   cSql += "       G.F4_ISS    , " + CHR(13)
   cSql += "       A.D2_CF     , " + CHR(13)
   cSql += "       A.D2_PEDIDO , " + CHR(13)
   cSql += "       F.C5_FRETE  , " + CHR(13)
   cSql += "       A.D2_CLIENTE, " + CHR(13)
   cSql += "       A.D2_LOJA   , " + CHR(13)
   cSql += "       C.A1_NOME   , " + CHR(13)
   cSql += "       C.A1_MUN    , " + CHR(13)
   cSql += "       C.A1_EST    , " + CHR(13)
   cSql += "       A.D2_ITEM   , " + CHR(13)
   cSql += "       A.D2_COD    , " + CHR(13)
   cSql += "       D.B1_DESC   , " + CHR(13)
   cSql += "       D.B1_DAUX   , " + CHR(13)
   cSql += "       D.B1_TIPO   , " + CHR(13)
   cSql += "       A.D2_UM     , " + CHR(13)
   cSql += "       A.D2_QUANT  , " + CHR(13)
   cSql += "      (A.D2_TOTAL + A.D2_ICMSRET) AS TOTAL_NF, " + CHR(13)
   cSql += "       A.D2_VALFRE , " + CHR(13)
   cSql += "       F.C5_FORNEXT  " + CHR(13)
   cSql += "  FROM " + RetSqlName("SD2010") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("SF2010") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("SA1010") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("SB1010") + " D, " + CHR(13)
   cSql += "       " + RetSqlName("SC5010") + " F, " + CHR(13)
   cSql += "       " + RetSqlName("SF4010") + " G  " + CHR(13)
   cSql += " WHERE B.F2_DOC       = A.D2_DOC    " + CHR(13)
   cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL " + CHR(13)
   cSql += "   AND B.F2_SERIE     = A.D2_SERIE  " + CHR(13)
   csql += "   AND B.F2_TIPO      = 'N'         " + CHR(13)
   cSql += "   AND A.D2_CLIENTE   = C.A1_COD    " + CHR(13)
   cSql += "   AND A.D2_LOJA      = C.A1_LOJA   " + CHR(13)
   cSql += "   AND A.D2_COD       = D.B1_COD    " + CHR(13)
   cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    " + CHR(13)
   cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL " + CHR(13)
   cSql += "   AND F.R_E_C_D_E_L_ = ''          " + CHR(13)
   cSql += "   AND A.D2_TES       = G.F4_CODIGO " + CHR(13)

   cSql += "   AND (G.F4_DUPLIC   = 'S' OR A.D2_TES = '543')" + CHR(13)

//   cSql += "   AND A.D2_CF IN ('5933','6933','5101','5102','5110','5405','5922','6101','6102','6108','6110','6403','6404','6922')"

   cSql += "   AND A.R_E_C_D_E_L_ = ''          " + CHR(13)
   cSql += "   AND B.R_E_C_D_E_L_ = ''          " + CHR(13)
   cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + CHR(13)

   If _Filial <> "00"
     cSql += " AND A.D2_FILIAL = '" + Alltrim(_Filial) + "'" + CHR(13)
   Endif
  
   cSql += " ORDER BY A.D2_FILIAL, A.D2_EMISSAO, A.D2_DOC, A.D2_CLIENTE, A.D2_LOJA" + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

   RESULTADO->( DbGoTop() )

   If RESULTADO->( Eof() )

      If !lWorkflow  
         MsgAlert("Não existem dados a serem visualizados.")
      Endif
         
      Return .T.
   Endif

   // Processamento. RPTSTATUS monta janela com a regua de processamento.
   
   //IRELGRAFICO(Cabec1,Cabec2,Titulo,nLin)
   If lWorkflow
      IRELGRAFICO(Cabec1,Cabec2,Titulo,nLin)
   Else
      Processa( {|| IRELGRAFICO(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Gerando Relatório",.F.)
   Endif

Return .T.

// Função que gera o relatório
Static Function IRELGRAFICO(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa   := ""
   Local cData      := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local aPesquisa  := {}
   Local aPaginas   := {}
   Local lPrimeira  := .T.

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   If Alltrim(xComboBx2) == "ANALÍTICO"
      Private nLimvert := 2000
   Else
      Private nLimvert := 3000      
   Endif
         
   Private nPagina  := 0
   Private _nLin    := 0

   // Carrega o Array aPesquisa com os dados acumulados por nota fiscal de cliente
   xVLR_SERVICO := 0
   xVLR_PRODUTO := 0
   xVLR_FRETE   := 0
   xVLR_TOTAL   := 0

   Resultado->( DbGoTop() )

   cEmpFil  := RESULTADO->D2_FILIAL
   cEmissao := RESULTADO->D2_EMISSAO
   cNotaF   := RESULTADO->D2_DOC
   cCliente := RESULTADO->D2_CLIENTE
   cLojaCli := RESULTADO->D2_LOJA

   While !Resultado->( EOF() )
   
      If Resultado->D2_FILIAL  == cEmpFil  .And. ;
         Resultado->D2_Emissao == cEmissao .And. ;
         Resultado->D2_DOC     == cNotaF   .And. ;
         Resultado->D2_CLIENTE == cCliente .And. ;
         Resultado->D2_LOJA    == cLojaCli
         
         xTES         := Resultado->D2_TES
         xCFOP        := Resultado->D2_CF
         xNF          := Resultado->D2_DOC
         xSERIE       := Resultado->D2_SERIE  
         xNUMPV       := Resultado->D2_PEDIDO
         xTIPOx       := IIF(Alltrim(Resultado->D2_TES) == "543", "EXTERNO", "INTERNO")
         xCODIGO      := Resultado->D2_CLIENTE
         xLoja        := Resultado->D2_LOJA
         xNOME        := Resultado->A1_NOME
         xCIDADE      := Resultado->A1_MUN
         xUF          := Resultado->A1_EST

         If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
            xVLR_SERVICO := xVLR_SERVICO + Resultado->TOTAL_NF
         Else
            xVLR_PRODUTO := xVLR_PRODUTO + Resultado->TOTAL_NF
         Endif     

         xVLR_FRETE   := xVLR_FRETE + Resultado->D2_VALFRE  
         xVLR_TOTAL   := xVLR_PRODUTO + xVLR_SERVICO + xVLR_FRETE

         Resultado->( DbSkip() )
         
         Loop
         
      Else

         // Carrega o Array
         aPesq := {cEmpFil      ,; // 01 - Filial
                   cEmissao     ,; // 02 - Data de Emissão
                   xTES         ,; // 03 - TES
                   xCFOP        ,; // 04 - CFOP
                   xNF          ,; // 05 - Nº Nota Fiscal
                   xSERIE       ,; // 06 - Nº de Série
                   xNUMPV       ,; // 07 - Nº do Pedido de Venda
                   xTIPOx       ,; // 08 - Tipo (PV Interno/Externo)
                   xCODIGO      ,; // 09 - Código do Cliente
                   xLoja        ,; // 10 - Loja do Cliente
                   xNOME        ,; // 11 - Nome do Cliente
                   xCIDADE      ,; // 12 - Cidade do Cliente
                   xUF          ,; // 13 - Estado do Cliente
                   xVLR_PRODUTO ,; // 14 - Valor Total dos Produtos
                   xVLR_SERVICO ,; // 15 - Valor Total dos Serviços
                   xVLR_FRETE   ,; // 16 - Valor Total dos Frete
                   xVLR_TOTAL}     // 17 - Valor Total da Nota Fiscal
       
  	     aAdd( aPesquisa, aPesq )

         cEmpFil  := RESULTADO->D2_FILIAL
         cEmissao := RESULTADO->D2_EMISSAO
         cNotaF   := RESULTADO->D2_DOC
         cCliente := RESULTADO->D2_CLIENTE
         cLojaCli := RESULTADO->D2_LOJA

         xVLR_SERVICO := 0
         xVLR_PRODUTO := 0
         xVLR_FRETE   := 0
         xVLR_TOTAL   := 0
         
      Endif
         
   Enddo
   
   // Carrega o Array
   aPesq := {cEmpFil      ,; // 01 - Filial
             cEmissao     ,; // 02 - Data de Emissão
             xTES         ,; // 03 - TES
             xCFOP        ,; // 04 - CFOP
             xNF          ,; // 05 - Nº Nota Fiscal
             xSERIE       ,; // 06 - Nº de Série
             xNUMPV       ,; // 07 - Nº do Pedido de Venda
             xTIPOx       ,; // 08 - Tipo (PV Interno/Externo)
             xCODIGO      ,; // 09 - Código do Cliente
             xLoja        ,; // 10 - Loja do Cliente
             xNOME        ,; // 11 - Nome do Cliente
             xCIDADE      ,; // 12 - Cidade do Cliente
             xUF          ,; // 13 - Estado do Cliente
             xVLR_PRODUTO ,; // 14 - Valor Total dos Produtos
             xVLR_SERVICO ,; // 15 - Valor Total dos Serviços
             xVLR_FRETE   ,; // 16 - Valor Total dos Frete
             xVLR_TOTAL}     // 17 - Valor Total da Nota Fiscal
                          
   aAdd( aPesquisa, aPesq )

   // Ordena o Array para Impressão
   ASORT(aPesquisa,,,{ | x,y | x[1] + x[2] < y[1] + y[2] } )
   
   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
	
   // Orientação da página
   
   If Alltrim(xComboBx2) == "ANALÍTICO"
      oPrint:SetLandScape() // Para Paisagem
   Else   
     oPrint:SetPortrait()    // Para Retrato
   Endif
	
   // Tamanho da página na impressão
   //oPrint:SetPaperSize(8) // A3
   //oPrint:SetPaperSize(1) // Carta
   oPrint:SetPaperSize(9)   // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )
   
   // Imprime o relatório analítico
   If Alltrim(xComboBx2) == "ANALÍTICO"

      cEmpFil := aPesquisa[01,01]
      cData   := aPesquisa[01,02]

      nProID := 0; nSerID := 0; nFreID := 0; nTotID := 0; nDevID := 0
      nProED := 0; nSerED := 0; nFreED := 0; nTotED := 0; nDevED := 0

      nProIV := 0; nSerIV := 0; nFreIV := 0; nTotIV := 0; nDevIV := 0
      nProEV := 0; nSerEV := 0; nFreEV := 0; nTotEV := 0; nDevEV := 0

      nProIA := 0; nSerIA := 0; nFreIA := 0; nTotIA := 0; nDevIA := 0
      nProEA := 0; nSerEA := 0; nFreEA := 0; nTotEA := 0; nDevEA := 0
      // Acumuladores
      nPagina  := 0
      _nLin    := 10
      
	  ProcRegua( Len(aPesquisa) )

      // Envia para a função que imprime o cabeçalho dp relatório
      CABECAANA(cEmpFil, cData, nPagina)
      
      For nContar = 1 to Len(aPesquisa)
   
         IncProc("Aguarde, pesquisando ...")
         
         If Alltrim(aPesquisa[nContar,01]) == Alltrim(cEmpFil)

            If Alltrim(aPesquisa[nContar,02]) == Alltrim(cData)

               // Impressão dos dados
               oPrint:Say(_nLin, 0100, Substr(aPesquisa[nContar,05],01,06), oFont21)
               oPrint:Say(_nLin, 0225, aPesquisa[nContar,06]              , oFont21) 
               oPrint:Say(_nLin, 0320, aPesquisa[nContar,07]              , oFont21) 
               oPrint:Say(_nLin, 0450, aPesquisa[nContar,08]              , oFont21) 
               oPrint:Say(_nLin, 0600, aPesquisa[nContar,09] + "." + aPesquisa[nContar,10], oFont21) 
               oPrint:Say(_nLin, 0780, aPesquisa[nContar,11]              , oFont21) 
               oPrint:Say(_nLin, 1550, aPesquisa[nContar,12]              , oFont21) 
               oPrint:Say(_nLin, 2000, aPesquisa[nContar,13]              , oFont21) 
               oPrint:Say(_nLin, 2120, Padl(Str(aPesquisa[nContar,14],12,02),12," ")    , oFont21) 
               oPrint:Say(_nLin, 2340, Transform(aPesquisa[nContar,15],"999999999.99")   , oFont21) 
               oPrint:Say(_nLin, 2560, Transform(aPesquisa[nContar,16],"999999999.99")   , oFont21) 

               // Verifica se existe devolução para a nota fiscal selecionada
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(aPesquisa[nContar,05],01,06)) .And. ;
                      Alltrim(aDevolucao[nDevolve,05]) == Alltrim(aPesquisa[nContar,06])               .And. ;
                      Alltrim(aDevolucao[nDevolve,01]) == Alltrim(aPesquisa[nContar,01])
                      aDevolucao[nDevolve,07] := .T.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
               Next nDevolve

               oPrint:Say(_nLin, 2780, Transform(nDevolucao,"999999999.99")                          , oFont21) 
               oPrint:Say(_nLin, 3000, Transform((aPesquisa[nContar,17] - nDevolucao),"999999999.99"), oFont21) 
 
               SomaLinhaAna(50,cEmpFil, cData)

               If Alltrim(aPesquisa[nContar,08]) == "INTERNO"

                  nProID := nProID + aPesquisa[nContar,14]
                  nSerID := nSerID + aPesquisa[nContar,15]
                  nFreID := nFreID + aPesquisa[nContar,16]
                  nDevID := nDevID + nDevolucao
                  nTotID := nTotID + aPesquisa[nContar,17] - nDevolucao

                  nProIV := nProIV + aPesquisa[nContar,14]
                  nSerIV := nSerIV + aPesquisa[nContar,15]
                  nFreIV := nFreIV + aPesquisa[nContar,16]
                  nDevIV := nDevIV + nDevolucao
                  nTotIV := nTotIV + aPesquisa[nContar,17] - nDevolucao

                  nProIA := nProIA + aPesquisa[nContar,14]
                  nSerIA := nSerIA + aPesquisa[nContar,15]
                  nFreIA := nFreIA + aPesquisa[nContar,16]
                  nDevIA := nDevIA + nDevolucao
                  nTotIA := nTotIA + aPesquisa[nContar,17] - nDevolucao

               Else

                  nProED := nProED + aPesquisa[nContar,14]
                  nSerED := nSerED + aPesquisa[nContar,15]
                  nFreED := nFreED + aPesquisa[nContar,16]
                  nDevED := nDevED + nDevolucao
                  nTotED := nTotED + aPesquisa[nContar,17] - nDevolucao

                  nProEV := nProEV + aPesquisa[nContar,14]
                  nSerEV := nSerEV + aPesquisa[nContar,15]
                  nFreEV := nFreEV + aPesquisa[nContar,16]
                  nDevEV := nDevEV + nDevolucao
                  nTotEV := nTotEV + aPesquisa[nContar,17] - nDevolucao

                  nProEA := nProEA + aPesquisa[nContar,14]
                  nSerEA := nSerEA + aPesquisa[nContar,15]
                  nFreEA := nFreEA + aPesquisa[nContar,16]
                  nDevEA := nDevEA + nDevolucao
                  nTotEA := nTotEA + aPesquisa[nContar,17] - nDevolucao

               Endif               

               Loop
            
            Else

               SomaLinhaAna(50,cEmpFil, cData)

               oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS INTERNOS NA DATA:" , oFont21) 
               oPrint:Say(_nLin, 2120, Str(nProID,12,02), oFont21) 
               oPrint:Say(_nLin, 2340, Str(nSerID,12,02), oFont21) 
               oPrint:Say(_nLin, 2560, Str(nFreID,12,02), oFont21) 
               oPrint:Say(_nLin, 2780, Str(nDevID,12,02), oFont21) 
               oPrint:Say(_nLin, 3000, Str((nProID + nSerID + nFreID - nDevID),12,02), oFont21) 

               SomaLinhaAna(50,cEmpFil, cData)

               // Pesquisa Outras Devoluções na Data
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
//                   If aDevolucao[nDevolve,03] == cData
                      If aDevolucao[nDevolve,07] == .F.
                         nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                      Endif
//                   Endif
               Next nDevolve
                                      
               oPrint:Say(_nLin, 1550, "TOTAL OUTRAS DEVOLUÇÕES.......:" , oFont21) 
               oPrint:Say(_nLin, 2780, Str(nDevolucao,12,02)             , oFont21) 
               oPrint:Say(_nLin, 3000, Str((nTotID - nDevolucao),12,02)  , oFont21) 

               SomaLinhaAna(50,cEmpFil, cData)

               oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS EXTERNOS NA DATA:" , oFont21) 
               oPrint:Say(_nLin, 2120, Str(nProED,12,02), oFont21) 
               oPrint:Say(_nLin, 2340, Str(nSerED,12,02), oFont21) 
               oPrint:Say(_nLin, 2560, Str(nFreED,12,02), oFont21) 
               oPrint:Say(_nLin, 2780, Str(nDevED,12,02), oFont21) 
               oPrint:Say(_nLin, 3000, Str(nTotED,12,02), oFont21) 

               SomaLinhaAna(50,cEmpFil, cData)

               oPrint:Say(_nLin, 1550, "TOTAL GERAL DA DATA...........:"        , oFont21) 
               oPrint:Say(_nLin, 2120, Str((nProID + nProED),12,02)             , oFont21) 
               oPrint:Say(_nLin, 2340, Str((nSerID + nSerED),12,02)             , oFont21) 
               oPrint:Say(_nLin, 2560, Str((nFreID + nFreED),12,02)             , oFont21) 
               oPrint:Say(_nLin, 2780, Str((nDevID + nDevED + nDevolucao),12,02), oFont21) 
               oPrint:Say(_nLin, 3000, Str((nTotID + nTotED - nDevolucao),12,02), oFont21) 

               SomaLinhaAna(100,cEmpFil, cData)

               nProID := 0; nSerID := 0; nFreID := 0; nTotID := 0; nDevID := 0
               nProED := 0; nSerED := 0; nFreED := 0; nTotED := 0; nDevED := 0

               cData := aPesquisa[nContar,02]

               oPrint:Say(  _nLin, 1550, "DATA..: " + Substr(aPesquisa[nContar,02],07,02) + "/" + ;
                                                      Substr(aPesquisa[nContar,02],05,02) + "/" + ;
                                                      Substr(aPesquisa[nContar,02],01,04), oFont10b) 

               SomaLinhaAna(100,cEmpFil, cData)

               nContar := nContar - 1

            Endif
         
         Else            
      
            SomaLinhaAna(50,cEmpFil, cData)

            // Totaliza a Data
            oPrint:Say(_nLin, 1550, "TOTAL PEDDIOS INTERNOS NA DATA:", oFont21) 
            oPrint:Say(_nLin, 2120, Str(nProID,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2340, Str(nSerID,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2560, Str(nFreID,12,02)                , oFont21) 

            oPrint:Say(_nLin, 3000, Str((nProID + nSerID + nFreID)  ,12,02)                , oFont21) 
            
            SomaLinhaAna(50,cEmpFil, cData)

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,03] == cData
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            oPrint:Say(_nLin, 1550, "OUTRAS DEVOLUÇÕES.............:", oFont21) 
            oPrint:Say(_nLin, 2780, Str((nDevolucao),12,02)          , oFont21) 
            oPrint:Say(_nLin, 3000, Str((nTotID - nDevolucao),12,02) , oFont21) 

            SomaLinhaAna(50,cEmpFil, cData)

            oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS EXTERNOS NA DATA:", oFont21) 
            oPrint:Say(_nLin, 2120, Str(nProED,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2340, Str(nSerED,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2560, Str(nFreED,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2780, Str(nDevED,12,02)                , oFont21) 
            oPrint:Say(_nLin, 3000, Str(nTotED,12,02)                , oFont21) 

            SomaLinhaAna(50,cEmpFil, cData)

            oPrint:Say(_nLin, 1550, "TOTAL GERAL NA DATA...........:"        , oFont21) 
            oPrint:Say(_nLin, 2120, Str((nProID + nProED),12,02)             , oFont21) 
            oPrint:Say(_nLin, 2340, Str((nSerID + nSerED),12,02)             , oFont21) 
            oPrint:Say(_nLin, 2560, Str((nFreID + nFreED),12,02)             , oFont21) 
            oPrint:Say(_nLin, 2780, Str((nDevID + nDevED + nDevolucao),12,02), oFont21) 
            oPrint:Say(_nLin, 3000, Str((nTotID + nTotED - nDevolucao),12,02), oFont21) 

            SomaLinhaAna(100,cEmpFil, cData)

            oPrint:Line( _nLin, 1550, _nLin, 3350 )

            SomaLinhaAna(100,cEmpFil, cData)

            // Totaliza da Filial
            oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS INTERNOS FILIAL.:", oFont21) 
            oPrint:Say(_nLin, 2120, Str(nProIV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2340, Str(nSerIV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2560, Str(nFreIV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2780, Str(nDevIV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 3000, Str((nProIV + nSerIV + nFreIV - nDevIV),12,02)                , oFont21) 
                        
            SomaLinhaAna(50,cEmpFil, cData)

            // Pesquisa Outras Devoluções na Data
            nDevolucao := 0
            For nDevolve = 1 to Len(aDevolucao)
                If aDevolucao[nDevolve,01] == cEmpFil
                   If aDevolucao[nDevolve,07] == .F.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
                Endif
            Next nDevolve

            oPrint:Say(_nLin, 1550, "OUTRAS DEVOLUÇÕES.............:", oFont21) 
            oPrint:Say(_nLin, 2780, Str((nDevolucao),12,02)          , oFont21) 
            oPrint:Say(_nLin, 3000, Str((nTotIV - nDevolucao),12,02) , oFont21) 

            SomaLinhaAna(50,cEmpFil, cData)

            oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS EXTERNOS FILIAL.:", oFont21) 
            oPrint:Say(_nLin, 2120, Str(nProEV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2340, Str(nSerEV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2560, Str(nFreEV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 2780, Str(nDevIV,12,02)                , oFont21) 
            oPrint:Say(_nLin, 3000, Str(nTotEV,12,02)                , oFont21) 

            SomaLinhaAna(50,cEmpFil, cData)

            oPrint:Say(_nLin, 1550, "TOTAL GERAL NA FILIAL.........:"        , oFont21) 
            oPrint:Say(_nLin, 2120, Str((nProIV + nProEV),12,02)             , oFont21) 
            oPrint:Say(_nLin, 2340, Str((nSerIV + nSerEV),12,02)             , oFont21) 
            oPrint:Say(_nLin, 2560, Str((nFreIV + nFreEV),12,02)             , oFont21) 
            oPrint:Say(_nLin, 2780, Str((nDevIV + nDevEV + nDevolucao),12,02), oFont21) 
            oPrint:Say(_nLin, 3000, Str((nTotIV + nTotEV - nDevolucao),12,02), oFont21) 

            SomaLinhaAna(50,cEmpFil, cData)

            If xTipo == "B"

   	           // Porto Alegre
               If cEmpFil == "01"
                  nACIPROP := nProIV
                  nACISERP := nSerIV
                  nACIFREP := nFreIV
                  nACIDEVP := nDevIV
                  nACITOTP := nTotIV

                  nACEPROP := nProEV
                  nACESERP := nSerEV
                  nACEFREP := nFreEV
                  nACEDEVP := nDevEV
                  nACETOTP := nTotEV
               Endif
               
               // Caxias do Sul
               If cEmpFil == "02"
                  nACIPROC := nProIV
                  nACISERC := nSerIV
                  nACIFREC := nFreIV
                  nACIDEVC := nDevIV
                  nACITOTC := nTotIV

                  nACEPROC := nProEV
                  nACESERC := nSerEV
                  nACEFREC := nFreEV
                  nACEDEVC := nDevEV
                  nACETOTC := nTotEV
               Endif

               // Pelotas
               If cEmpFil == "03"
                  nACIPROL := nProIV
                  nACISERL := nSerIV
                  nACIFREL := nFreIV
                  nACIDEVL := nDevIV
                  nACITOTL := nTotIV

                  nACEPROL := nProEV
                  nACESERL := nSerEV
                  nACEFREL := nFreEV
                  nACEDEVL := nDevEV
                  nACETOTL := nTotEV
               Endif

               // Suprimentos
               If cEmpFil == "04"
                  nACIPROS := nProIV
                  nACISERS := nSerIV
                  nACIFRES := nFreIV
                  nACIDEVS := nDevIV
                  nACITOTS := nTotIV

                  nACEPROS := nProEV
                  nACESERS := nSerEV
                  nACEFRES := nFreEV
                  nACEDEVS := nDevEV
                  nACETOTS := nTotEV
               Endif

            Endif   

            nProID := 0; nSerID := 0; nFreID := 0; nTotID := 0; nDevID := 0
            nProED := 0; nSerED := 0; nFreED := 0; nTotED := 0; nDevED := 0
    
            nProIV := 0; nSerIV := 0; nFreIV := 0; nTotIV := 0; nDevIV := 0
            nProEV := 0; nSerEV := 0; nFreEV := 0; nTotEV := 0; nDevEV := 0

            cEmpFil := aPesquisa[nContar,01]
            cData   := aPesquisa[nContar,02]

            oPrint:EndPage()

            // Envia para a função que imprime o cabeçalho dp relatório
            CABECAANA(cEmpFil, cData, nPagina)

            nContar := nContar - 1

         Endif

      Next nContar

      SomaLinhaAna(100,cEmpFil, cData)

      // Totaliza a Data
      oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS INTERNOS DATA...:", oFont21) 
      oPrint:Say(_nLin, 2120, Str(nProID,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2340, Str(nSerID,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2560, Str(nFreID,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2780, Str(nDevID,12,02)                , oFont21) 
      oPrint:Say(_nLin, 3000, Str((nProID + nSerID + nFreID - nDevID),12,02)                , oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cData
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      oPrint:Say(_nLin, 1550, "OUTRAS DEVOLUÇÕES.............:", oFont21) 
      oPrint:Say(_nLin, 2780, Str((nDevolucao),12,02)          , oFont21) 
      oPrint:Say(_nLin, 3000, Str((nTotID - nDevolucao),12,02) , oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS EXTERNOS DATA...:", oFont21) 
      oPrint:Say(_nLin, 2120, Str(nProED,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2340, Str(nSerED,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2560, Str(nFreED,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2780, Str(nDevED,12,02)                , oFont21) 
      oPrint:Say(_nLin, 3000, Str(nTotED,12,02)                , oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      oPrint:Say(_nLin, 1550, "TOTAL GERAL DA DATA...........:"        , oFont21) 
      oPrint:Say(_nLin, 2120, Str((nProID + nProED),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2340, Str((nSerID + nSerED),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2560, Str((nFreID + nFreED),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2780, Str((nDevID + nDevED + nDevolucao),12,02), oFont21) 
      oPrint:Say(_nLin, 3000, Str((nTotID + nTotED - nDevolucao),12,02), oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      oPrint:Line( _nLin, 1550, _nLin, 3350 )

      SomaLinhaAna(50,cEmpFil, cData)
   
      // Totaliza da Filial
      oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS INTERNOS FILIAL.:", oFont21) 
      oPrint:Say(_nLin, 2120, Str(nProIV,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2340, Str(nSerIV,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2560, Str(nFreIV,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2780, Str(nDevIV,12,02)                , oFont21) 
      oPrint:Say(_nLin, 3000, Str((nProIV + nSerIV + nFreIV - nDevIV),12,02), oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,01] == cEmpFil
             If aDevolucao[nDevolve,07] == .F.
                nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      oPrint:Say(_nLin, 1550, "OUTRAS DEVOLUÇÕES.............:", oFont21) 
      oPrint:Say(_nLin, 2780, Str((nDevolucao),12,02)          , oFont21) 
      oPrint:Say(_nLin, 3000, Str((nTotIV - nDevolucao),12,02) , oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS EXTERNOS FILIAL.:", oFont21) 
      oPrint:Say(_nLin, 2120, Str(nProEV,12,02), oFont21) 
      oPrint:Say(_nLin, 2340, Str(nSerEV,12,02), oFont21) 
      oPrint:Say(_nLin, 2560, Str(nFreEV,12,02), oFont21) 
      oPrint:Say(_nLin, 2780, Str(nDevEV,12,02), oFont21) 
      oPrint:Say(_nLin, 3000, Str(nTotEV,12,02), oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      oPrint:Say(_nLin, 1550, "TOTAL GERAL NA FILIAL.........:"        , oFont21) 
      oPrint:Say(_nLin, 2120, Str((nProIV + nProEV),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2340, Str((nSerIV + nSerEV),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2560, Str((nFreIV + nFreEV),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2780, Str((nDevIV + nDevEV + nDevolucao),12,02), oFont21) 
      oPrint:Say(_nLin, 3000, Str((nTotIV + nTotEV - nDevolucao),12,02), oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      If xTipo == "B"

         // Porto Alegre
         If cEmpFil == "01"
            nACIPROP := nProIV
            nACISERP := nSerIV
            nACIFREP := nFreIV
            nACIDEVP := nDevIV
            nACITOTP := nTotIV

            nACEPROP := nProEV
            nACESERP := nSerEV
            nACEFREP := nFreEV
            nACEDEVP := nDevEV
            nACETOTP := nTotEV
         Endif
               
         // Caxias do Sul
         If cEmpFil == "02"
            nACIPROC := nProIV
            nACISERC := nSerIV
            nACIFREC := nFreIV
            nACIDEVC := nDevIV
            nACITOTC := nTotIV

            nACEPROC := nProEV
            nACESERC := nSerEV
            nACEFREC := nFreEV
            nACEDEVC := nDevEV
            nACETOTC := nTotEV
         Endif

         // Pelotas
         If cEmpFil == "03"
            nACIPROL := nProIV
            nACISERL := nSerIV
            nACIFREL := nFreIV
            nACIDEVL := nDevIV
            nACITOTL := nTotIV

            nACEPROL := nProEV
            nACESERL := nSerEV
            nACEFREL := nFreEV
            nACEDEVL := nDevEV
            nACETOTL := nTotEV
         Endif

         // Suprimento
         If cEmpFil == "04"
            nACIPROS := nProIV
            nACISERS := nSerIV
            nACIFRES := nFreIV
            nACIDEVS := nDevIV
            nACITOTS := nTotIV

            nACEPROS := nProEV
            nACESERS := nSerEV
            nACEFRES := nFreEV
            nACEDEVS := nDevEV
            nACETOTS := nTotEV
         Endif

      Endif   

      oPrint:Line( _nLin, 1550, _nLin, 3350 )

      SomaLinhaAna(50,cEmpFil, cData)

      // Total Geral do Período
      oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS INTERNOS PERÍODO:", oFont21) 
      oPrint:Say(_nLin, 2120, Str(nProIA,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2340, Str(nSerIA,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2560, Str(nFreIA,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2780, Str(nDevIA,12,02)                , oFont21) 

      oPrint:Say(_nLin, 3000, Str((nProIA + nSerIA + nFreIA - nDevIA),12,02)                , oFont21) 


      SomaLinhaAna(50,cEmpFil, cData)

      // Pesquisa Outras Devoluções na Data
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      oPrint:Say(_nLin, 1550, "OUTRAS DEVOLUÇÕES.............:", oFont21) 
      oPrint:Say(_nLin, 2780, Str((nDevolucao),12,02)          , oFont21) 
      oPrint:Say(_nLin, 3000, Str((nTotIA - nDevolucao),12,02) , oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      oPrint:Say(_nLin, 1550, "TOTAL PEDIDOS EXTERNOS PERÍODO:", oFont21) 
      oPrint:Say(_nLin, 2120, Str(nProEA,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2340, Str(nSerEA,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2560, Str(nFreEA,12,02)                , oFont21) 
      oPrint:Say(_nLin, 2780, Str(nDevEA,12,02)                , oFont21) 
      oPrint:Say(_nLin, 3000, Str(nTotEA,12,02)                , oFont21) 

      SomaLinhaAna(50,cEmpFil, cData)

      oPrint:Say(_nLin, 1550, "TOTAL GERAL DO PERÍODO........:"        , oFont21) 
      oPrint:Say(_nLin, 2120, Str((nProIA + nProEA),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2340, Str((nSerIA + nSerEA),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2560, Str((nFreIA + nFreEA),12,02)             , oFont21) 
      oPrint:Say(_nLin, 2780, Str((nDevIA + nDevEA + nDevolucao),12,02), oFont21) 
      oPrint:Say(_nLin, 3000, Str((nTotIA + nTotEA - nDevolucao),12,02), oFont21) 

      oPrint:EndPage()

   Else

      // SINTÉTICO
      
      cEmpFil   := aPesquisa[01,01]
      cData     := aPesquisa[01,02]

      nProInte  := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
      nProExte  := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

      nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
      nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

      nProGInte := 0; nSerGInte := 0; nFreGInte := 0; nTotGInte := 0; nDevGInte := 0
      nProGExte := 0; nSerGExte := 0; nFreGExte := 0; nTotGExte := 0; nDevGExte := 0

      nPagina  := 0

      // Envia para a função que imprime o cabeçalho dp relatório
      CABECASIN(cEmpFil, cData, nPagina)

      For nContar = 1 to Len(aPesquisa)
   
         If Alltrim(aPesquisa[nContar,01]) == Alltrim(cEmpFil)

            If Alltrim(aPesquisa[nContar,02]) == Alltrim(cData)

               // Verifica se existe devolução para a nota fiscal selecionada
               nDevolucao := 0
               For nDevolve = 1 to Len(aDevolucao)
                   If Alltrim(aDevolucao[nDevolve,04]) == Alltrim(Substr(aPesquisa[nContar,05],01,06)) .And. ;
                      Alltrim(aDevolucao[nDevolve,05]) == Alltrim(aPesquisa[nContar,06])               .And. ;
                      Alltrim(aDevolucao[nDevolve,01]) == Alltrim(aPesquisa[nContar,01])
                      aDevolucao[nDevolve,07] := .T.
                      nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
                   Endif
               Next nDevolve

               // Acumula os Valores da Data para Impressão
               If Alltrim(aPesquisa[nContar,08]) == "INTERNO"

                  nProInte  := nProInte  + aPesquisa[nContar,14]
                  nSerInte  := nSerInte  + aPesquisa[nContar,15]
                  nFreInte  := nFreInte  + aPesquisa[nContar,16]
                  nDevInte  := nDevInte  + nDevolucao
                  nTotInte  := nTotInte  + aPesquisa[nContar,17] - nDevolucao

                  nProAInte := nProAInte + aPesquisa[nContar,14]
                  nSerAInte := nSerAInte + aPesquisa[nContar,15]
                  nFreAInte := nFreAInte + aPesquisa[nContar,16]
                  nDevAInte := nDevAInte + nDevolucao
                  nTotAInte := nTotAInte + aPesquisa[nContar,17] - nDevolucao

                  nProGInte := nProGInte + aPesquisa[nContar,14]
                  nSerGInte := nSerGInte + aPesquisa[nContar,15]
                  nFreGInte := nFreGInte + aPesquisa[nContar,16]
                  nDevGInte := nDevGInte + nDevolucao
                  nTotGInte := nTotGInte + aPesquisa[nContar,17] - nDevolucao

               Else   

                  nProExte  := nProExte  + aPesquisa[nContar,14]
                  nSerExte  := nSerExte  + aPesquisa[nContar,15]
                  nFreExte  := nFreExte  + aPesquisa[nContar,16]
                  nDevExte  := nDevExte  + nDevolucao
                  nTotExte  := nTotExte  + aPesquisa[nContar,17] - nDevolucao

                  nProAExte := nProAExte + aPesquisa[nContar,14]
                  nSerAExte := nSerAExte + aPesquisa[nContar,15]
                  nFreAExte := nFreAExte + aPesquisa[nContar,16]
                  nDevAExte := nDevAExte + nDevolucao
                  nTotAExte := nTotAExte + aPesquisa[nContar,17] - nDevolucao

                  nProGExte := nProGExte + aPesquisa[nContar,14]
                  nSerGExte := nSerGExte + aPesquisa[nContar,15]
                  nFreGExte := nFreGExte + aPesquisa[nContar,16]
                  nDevGExte := nDevGExte + nDevolucao
                  nTotGExte := nTotGExte + aPesquisa[nContar,17] - nDevolucao

               Endif

               Loop
            
            Else

               oPrint:Say( _nLin, 0100, Substr(cData,07,02) + "/" + Substr(cData,05,02) + "/" + Substr(cData,01,04), oFont21)
               oPrint:Say( _nLin, 0340, "INTERNOS", oFont21)
               oPrint:Say( _nLin, 0600, Str(nProInte,12,02), oFont21)
               oPrint:Say( _nLin, 1000, Str(nSerInte,12,02), oFont21)
               oPrint:Say( _nLin, 1400, Str(nFreInte,12,02), oFont21)
               oPrint:Say( _nLin, 1800, Str(nDevInte,12,02), oFont21)
               oPrint:Say( _nLin, 2100, Str(nTotInte,12,02), oFont21)
               SomaLinhaSin(50,cEmpFil, cData)

               oPrint:Say( _nLin, 0340, "EXTERNOS"         , oFont21)
               oPrint:Say( _nLin, 0600, Str(nProExte,12,02), oFont21)
               oPrint:Say( _nLin, 1000, Str(nSerExte,12,02), oFont21)
               oPrint:Say( _nLin, 1400, Str(nFreExte,12,02), oFont21)
               oPrint:Say( _nLin, 1800, Str(nDevExte,12,02), oFont21)
               oPrint:Say( _nLin, 2100, Str(nTotExte,12,02), oFont21)
               SomaLinhaSin(50,cEmpFil, cData)

               oPrint:Say( _nLin, 0340, "TOTAL"                         , oFont21)
               oPrint:Say( _nLin, 0600, Str((nProInte + nProExte),12,02), oFont21)
               oPrint:Say( _nLin, 1000, Str((nSerInte + nSerExte),12,02), oFont21)
               oPrint:Say( _nLin, 1400, Str((nFreInte + nFreExte),12,02), oFont21)
               oPrint:Say( _nLin, 1800, Str((nDevInte + nDevExte),12,02), oFont21)
               oPrint:Say( _nLin, 2100, Str((nTotInte + nTotExte),12,02), oFont21)
               SomaLinhaSin(100,cEmpFil, cData)

               nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
               nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

               cData := aPesquisa[nContar,02]

               nContar := nContar - 1

            Endif
         
         Else            

            // Totaliza a última data
            oPrint:Say( _nLin, 0100, Substr(cData,07,02) + "/" + Substr(cData,05,02) + "/" + Substr(cData,01,04), oFont21)
            oPrint:Say( _nLin, 0340, "INTERNOS", oFont21)
            oPrint:Say( _nLin, 0600, Str(nProInte,12,02), oFont21)
            oPrint:Say( _nLin, 1000, Str(nSerInte,12,02), oFont21)
            oPrint:Say( _nLin, 1400, Str(nFreInte,12,02), oFont21)
            oPrint:Say( _nLin, 1800, Str(nDevInte,12,02), oFont21)
            oPrint:Say( _nLin, 2100, Str(nTotInte,12,02), oFont21)
            SomaLinhaSin(50,cEmpFil, cData)

            oPrint:Say( _nLin, 0340, "EXTERNOS", oFont21)
            oPrint:Say( _nLin, 0600, Str(nProExte,12,02), oFont21)
            oPrint:Say( _nLin, 1000, Str(nSerExte,12,02), oFont21)
            oPrint:Say( _nLin, 1400, Str(nFreExte,12,02), oFont21)
            oPrint:Say( _nLin, 1800, Str(nDevExte,12,02), oFont21)
            oPrint:Say( _nLin, 2100, Str(nTotExte,12,02), oFont21)                                             
            SomaLinhaSin(50,cEmpFil, cData)               

            oPrint:Say( _nLin, 0340, "TOTAL", oFont21)
            oPrint:Say( _nLin, 0600, Str((nProInte + nProExte),12,02), oFont21)
            oPrint:Say( _nLin, 1000, Str((nSerInte + nSerExte),12,02), oFont21)
            oPrint:Say( _nLin, 1400, Str((nFreInte + nFreExte),12,02), oFont21)
            oPrint:Say( _nLin, 1800, Str((nDevInte + nDevExte),12,02), oFont21)
            oPrint:Say( _nLin, 2100, Str((nTotInte + nTotExte),12,02), oFont21)
            SomaLinhaSin(100,cEmpFil, cData)               

            // Zera os totalizadores da data
            nProInte := 0; nSerInte := 0; nFreInte := 0; nTotInte := 0; nDevInte := 0
            nProExte := 0; nSerExte := 0; nFreExte := 0; nTotExte := 0; nDevExte := 0

	        // Totaliza a Filial
            oPrint:Say( _nLin, 0100, "TOTAL DA", oFont21)
            oPrint:Say( _nLin, 0340, "INTERNOS", oFont21)
            oPrint:Say( _nLin, 0600, Str(nProAInte,12,02), oFont21)
            oPrint:Say( _nLin, 1000, Str(nSerAInte,12,02), oFont21)
            oPrint:Say( _nLin, 1400, Str(nFreAInte,12,02), oFont21)
            oPrint:Say( _nLin, 1800, Str(nDevAInte,12,02), oFont21)
            oPrint:Say( _nLin, 2100, Str(nTotAInte,12,02), oFont21)
            SomaLinhaSin(50,cEmpFil, cData)               

            oPrint:Say( _nLin, 0100, "FILIAL"  , oFont21)
            oPrint:Say( _nLin, 0340, "EXTERNOS", oFont21)
            oPrint:Say( _nLin, 0600, Str(nProAExte,12,02), oFont21)
            oPrint:Say( _nLin, 1000, Str(nSerAExte,12,02), oFont21)
            oPrint:Say( _nLin, 1400, Str(nFreAExte,12,02), oFont21)
            oPrint:Say( _nLin, 1800, Str(nDevAExte,12,02), oFont21)
            oPrint:Say( _nLin, 2100, Str(nTotAExte,12,02), oFont21)                                             
            SomaLinhaSin(50,cEmpFil, cData)               

            oPrint:Say( _nLin, 0340, "TOTAL", oFont21)
            oPrint:Say( _nLin, 0600, Str((nProAInte + nProAExte),12,02), oFont21)
            oPrint:Say( _nLin, 1000, Str((nSerAInte + nSerAExte),12,02), oFont21)
            oPrint:Say( _nLin, 1400, Str((nFreAInte + nFreAExte),12,02), oFont21)
            oPrint:Say( _nLin, 1800, Str((nDevAInte + nDevAExte),12,02), oFont21)
            oPrint:Say( _nLin, 2100, Str((nTotAInte + nTotAExte),12,02), oFont21)

            SomaLinhaSin(50,cEmpFil, cData)               
            oPrint:Line( _nLin, 0100, _nLin, 2400 )
            SomaLinhaSin(100,cEmpFil, cData)               

            cEmpFil := aPesquisa[nContar,01]
            cData   := aPesquisa[nContar,02]

            nProAInte := 0; nSerAInte := 0; nFreAInte := 0; nTotAInte := 0; nDevAInte := 0
            nProAExte := 0; nSerAExte := 0; nFreAExte := 0; nTotAExte := 0; nDevAExte := 0

            Do Case
               Case Alltrim(aPesquisa[nContar,01]) == "01"
                    Do Case 
                       Case __Empresa == "01"
                            oPrint:Say( _nLin, 0950, "FILIAL: 01 - PORTO ALEGRE", oFont10b)
                       Case __Empresa == "02"
                            oPrint:Say( _nLin, 0950, "FILIAL: 01 - TI CURITIBA" , oFont10b)
                       Case __Empresa == "03"
                            oPrint:Say( _nLin, 0950, "FILIAL: 01 - ATECH"       , oFont10b)
                    EndCase        
               Case Alltrim(aPesquisa[nContar,01]) == "02"
                    oPrint:Say( _nLin, 0950, "FILIAL: 02 - CAXIAS DO SUL", oFont10b)
               Case Alltrim(aPesquisa[nContar,01]) == "03"
                    oPrint:Say( _nLin, 0950, "FILIAL: 03 - PELOTAS", oFont10b)
            EndCase        

            SomaLinhaSin(100,cEmpFil, cData)               

            nContar := nContar - 1

         Endif

      Next nContar

      // Totaliza a última data
      oPrint:Say( _nLin, 0100, Substr(cData,07,02) + "/" + Substr(cData,05,02) + "/" + Substr(cData,01,04), oFont21)
      oPrint:Say( _nLin, 0340, "INTERNOS", oFont21)
      oPrint:Say( _nLin, 0600, Str(nProInte,12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str(nSerInte,12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str(nFreInte,12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str(nDevInte,12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str(nTotInte,12,02), oFont21)
      SomaLinhaSin(50,cEmpFil, cData)               

      oPrint:Say( _nLin, 0340, "EXTERNOS", oFont21)
      oPrint:Say( _nLin, 0600, Str(nProExte,12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str(nSerExte,12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str(nFreExte,12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str(nDevExte,12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str(nTotExte,12,02), oFont21)
      SomaLinhaSin(50,cEmpFil, cData)               

      oPrint:Say( _nLin, 0340, "TOTAL", oFont21)
      oPrint:Say( _nLin, 0600, Str((nProInte + nProExte),12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str((nSerInte + nSerExte),12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str((nFreInte + nFreExte),12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str((nDevInte + nDevExte),12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str((nTotInte + nTotExte),12,02), oFont21)
      SomaLinhaSin(100,cEmpFil, cData)               

      // Totaliza a Filial
      oPrint:Say( _nLin, 0100, "TOTAL DA", oFont21)
      oPrint:Say( _nLin, 0340, "INTERNOS", oFont21)
      oPrint:Say( _nLin, 0600, Str(nProAInte,12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str(nSerAInte,12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str(nFreAInte,12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str(nDevAInte,12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str(nTotAInte,12,02), oFont21)
      SomaLinhaSin(50,cEmpFil, cData)               

      oPrint:Say( _nLin, 0100, "FILIAL"  , oFont21)
      oPrint:Say( _nLin, 0340, "EXTERNOS", oFont21)
      oPrint:Say( _nLin, 0600, Str(nProAExte,12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str(nSerAExte,12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str(nFreAExte,12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str(nDevAExte,12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str(nTotAExte,12,02), oFont21)
      SomaLinhaSin(50,cEmpFil, cData)               

      oPrint:Say( _nLin, 0340, "TOTAL", oFont21)
      oPrint:Say( _nLin, 0600, Str((nProAInte + nProAExte),12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str((nSerAInte + nSerAExte),12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str((nFreAInte + nFreAExte),12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str((nDevAInte + nDevAExte),12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str((nTotAInte + nTotAExte),12,02), oFont21)

      SomaLinhaSin(50,cEmpFil, cData)               
      oPrint:Line( _nLin, 0100, _nLin, 2400 )
      SomaLinhaSin(100,cEmpFil, cData)               

      // Totaliza o Período
      oPrint:Say( _nLin, 0100, "TOTAL DO", oFont21)
      oPrint:Say( _nLin, 0340, "INTERNOS", oFont21)
      oPrint:Say( _nLin, 0600, Str(nProGInte,12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str(nSerGInte,12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str(nFreGInte,12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str(nDevGInte,12,02), oFont21)
      SomaLinhaSin(50,cEmpFil, cData)               

      // Verifica se existe devolução para a nota fiscal selecionada
      nDevolucao := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             nDevolucao := nDevolucao + aDevolucao[nDevolve,02]
          Endif
      Next nDevolve

      oPrint:Say( _nLin, 0340, "O.DEV.:", oFont21)
      oPrint:Say( _nLin, 1800, Str(nDevolucao,12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str((nTotGInte + nTotGExte - nDevolucao),12,02), oFont21)
      SomaLinhaSin(50,cEmpFil, cData)               

      oPrint:Say( _nLin, 0100, "PERÍODO" , oFont21)
      oPrint:Say( _nLin, 0340, "EXTERNOS", oFont21)
      oPrint:Say( _nLin, 0600, Str(nProGExte,12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str(nSerGExte,12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str(nFreGExte,12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str(nDevGExte,12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str(nTotGExte,12,02), oFont21)
      SomaLinhaSin(50,cEmpFil, cData)               

      oPrint:Say( _nLin, 0340, "TOTAL", oFont21)
      oPrint:Say( _nLin, 0600, Str((nProGInte + nProGExte),12,02), oFont21)
      oPrint:Say( _nLin, 1000, Str((nSerGInte + nSerGExte),12,02), oFont21)
      oPrint:Say( _nLin, 1400, Str((nFreGInte + nFreGExte),12,02), oFont21)
      oPrint:Say( _nLin, 1800, Str((nDevGInte + nDevGExte + nDevolucao),12,02), oFont21)
      oPrint:Say( _nLin, 2100, Str((nTotGInte + nTotGExte - nDevolucao),12,02), oFont21)

      SomaLinhaSin(100,cEmpFil, cData)               
      oPrint:Line( _nLin, 0100, _nLin, 2400 )

   Endif

   If lWorkflow

      // Gera Array com a quantidade de páginas a serem salvas em HTML
      For nContar = 1 to nPagina
          Aadd( aPaginas, nContar )
      Next nContar    

      // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
      If Alltrim(xComboBx2) == "ANALÍTICO"
         If File("\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Ferase("\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
         Endif
         cFileHTML := "\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"
      Else
         If File("\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
            Ferase("\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
         Endif
         cFileHTML := "\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"
      Endif
   
      // Salva o relatório em HTML
      oPrint:SaveAsHtml(cFileHTML, aPaginas )

      // Envia o relatório via e-mail
      If Alltrim(xComboBx2) == "ANALÍTICO"
         U_AUTOMR20("Faturamento por Período Analítico referente ao período de " + ;
                    Dtoc(dData01) + " a " + Dtoc(dData02)                        , ;
                    "haraldhans@gmail.com"                          , ;
                    cFileHTML                                                    , ;
                    "Faturamento por Período Analítico referente ao período de " + ;
                    Dtoc(dData01) + " a " + Dtoc(dData02))
      Else
         U_AUTOMR20("Faturamento por Período Sintético referente ao período de " + ;
                    Dtoc(dData01) + " a " + Dtoc(dData02)                        , ;
                    "haraldhans@gmail.com"          , ;
                    cFileHTML                                                    , ;
                    "Faturamento por período Sintético referente ao período de " + ;
                    Dtoc(dData01) + " a " + Dtoc(dData02))
      Endif
      
   Else

      If Alltrim(xComboBx3) == "VIDEO"

         If xComboBx4 == "NORMAL"

            oPrint:Preview()
            
         Else

            // Gera Array com a quantidade de páginas a serem salvas em HTML
            For nContar = 1 to nPagina
                Aadd( aPaginas, nContar )
            Next nContar    

            // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
            If Alltrim(xComboBx2) == "ANALÍTICO"
               If File("\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
                  Ferase("\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Endif
               cFileHTML := "\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"
            Else
               If File("\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
                  Ferase("\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Endif
               cFileHTML := "\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"
            Endif
   
            // Salva o relatório em HTML
            oPrint:SaveAsHtml(cFileHTML, aPaginas )

            // Envia o relatório via e-mail
            If Alltrim(xComboBx2) == "ANALÍTICO"
               U_AUTOMR20("Faturamento por Período Analítico referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02)                        , ;
                          "roger@automatech.com.br;evandro@automatech.com.br"          , ;  
                          cFileHTML                                                    , ;
                          "Faturamento por Período Analítico referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02))
            Else
               U_AUTOMR20("Faturamento por Período Sintético referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02)                        , ;
                          "roger@automatech.com.br;evandro@automatech.com.br"          , ;  
                          cFileHTML                                                    , ;
                          "Faturamento por período Sintético referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02))
            Endif
            
         Endif

      Else

         If xTipo == "B"
         Else
            // Gera Array com a quantidade de páginas a serem salvas em HTML
            For nContar = 1 to nPagina
                Aadd( aPaginas, nContar )
            Next nContar    

            // Verifica se o arquivo de destino já existe. Se existe, o elimina para nova gravação
            If Alltrim(xComboBx2) == "ANALÍTICO"
               If File("\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
                  Ferase("\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Endif
               cFileHTML := "\TREPORT\FAT-PERIODO-ANALITICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"
            Else
               If File("\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
                  Ferase("\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM")
               Endif
               cFileHTML := "\TREPORT\FAT-PERIODO-SINTETICO-" + Strzero(Month(dData01),2) + "-" + Strzero(Year(dData02),4) + ".HTM"
            Endif
   
            // Salva o relatório em HTML
            oPrint:SaveAsHtml(cFileHTML, aPaginas )

            // Envia o relatório via e-mail
            If Alltrim(xComboBx2) == "ANALÍTICO"
               U_AUTOMR20("Faturamento por Período Analítico referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02)                        , ;
                          Alltrim(cEnderecos)                                          , ;
                          cFileHTML                                                    , ;
                          "Faturamento por Período Analítico referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02))
            Else
               U_AUTOMR20("Faturamento por Período Sintético referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02)                        , ;
                          Alltrim(cEnderecos)                                          , ;
                          cFileHTML                                                    , ;
                          "Faturamento por período Sintético referente ao período de " + ;
                          Dtoc(dData01) + " a " + Dtoc(dData02))
            Endif
     
         Endif
         
      Endif   
      
   Endif

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

   If xTipo == "B"
      nACIPROP := Str(nACIPROP,14,02)
      nACISERP := Str(nACISERP,14,02)
      nACIFREP := Str(nACIFREP,14,02)
      nACIDEVP := Str(nACIDEVP,14,02)
      nACITOTP := Str(nACITOTP,14,02)

      nACEPROP := Str(nACEPROP,14,02)
      nACESERP := Str(nACESERP,14,02)
      nACEFREP := Str(nACEFREP,14,02)
      nACEDEVP := Str(nACEDEVP,14,02)
      nACETOTP := Str(nACETOTP,14,02)
               
      nACIPROC := Str(nACIPROC,14,02)
      nACISERC := Str(nACISERC,14,02)
      nACIFREC := Str(nACIFREC,14,02)
      nACIDEVC := Str(nACIDEVC,14,02)
      nACITOTC := Str(nACITOTC,14,02)

      nACEPROC := Str(nACEPROC,14,02)
      nACESERC := Str(nACESERC,14,02)
      nACEFREC := Str(nACEFREC,14,02)
      nACEDEVC := Str(nACEDEVC,14,02)
      nACETOTC := Str(nACETOTC,14,02)

      nACIPROL := Str(nACIPROL,14,02)
      nACISERL := Str(nACISERL,14,02)
      nACIFREL := Str(nACIFREL,14,02)
      nACIDEVL := Str(nACIDEVL,14,02)
      nACITOTL := Str(nACITOTL,14,02)

      nACEPROL := Str(nACEPROL,14,02)
      nACESERL := Str(nACESERL,14,02)
      nACEFREL := Str(nACEFREL,14,02)
      nACEDEVL := Str(nACEDEVL,14,02)
      nACETOTL := Str(nACETOTL,14,02)

      nACIPROS := Str(nACIPROS,14,02)
      nACISERS := Str(nACISERS,14,02)
      nACIFRES := Str(nACIFRES,14,02)
      nACIDEVS := Str(nACIDEVS,14,02)
      nACITOTS := Str(nACITOTS,14,02)

      nACEPROS := Str(nACEPROS,14,02)
      nACESERS := Str(nACESERS,14,02)
      nACEFRES := Str(nACEFRES,14,02)
      nACEDEVS := Str(nACEDEVS,14,02)
      nACETOTS := Str(nACETOTS,14,02)

      // Calcula Outras Devoluções para a Tela Gerencial
      nDevoPOA := 0
      nDevoCXS := 0
      nDevoPEL := 0
      nDevoSUP := 0
      For nDevolve = 1 to Len(aDevolucao)
          If aDevolucao[nDevolve,07] == .F.
             If aDevolucao[nDevolve,01] == "01"
                nDevoPOA := nDevoPOA + aDevolucao[nDevolve,02]
             Endif
             If aDevolucao[nDevolve,01] == "02"
                nDevoCXS := nDevoCXS + aDevolucao[nDevolve,02]
             Endif
             If aDevolucao[nDevolve,01] == "03"
                nDevoPEL := nDevoPEL + aDevolucao[nDevolve,02]
             Endif
             If aDevolucao[nDevolve,01] == "04"
                nDevoSUP := nDevoSUP + aDevolucao[nDevolve,02]
             Endif
          Endif
      Next nDevolve

      nOutraPOA := Str(nDevoPOA,14,02)
      nOutraCXS := Str(nDevoCXS,14,02)
      nOutraPEL := Str(nDevoPEL,14,02)
      nOutraSUP := Str(nDevoSUP,14,02)
   Endif

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por período Analítico
Static Function CABECAANA(cEmpFil, cData)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   // Logotipo 
// oPrint:SayBitmap( _nLin, 0100, "http://www.automatech.com.br/images/automatech_logo.jpg", 0700, 0200 )

// _nLin += 80

   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "RELAÇÃO DE FATURAMENTO POR PERÍODO"   , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR16", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 20

   oPrint:Say(_nLin, 0100, "NF"                    , oFont21)
   oPrint:Say(_nLin, 0225, "SR"                    , oFont21) 
   oPrint:Say(_nLin, 0320, "Nº PV"                 , oFont21) 
   oPrint:Say(_nLin, 0450, "TIPO"                  , oFont21) 
   oPrint:Say(_nLin, 0600, "CODIGO"                , oFont21) 
   oPrint:Say(_nLin, 0780, "DESCRIÇÃO DOS CLIENTES", oFont21) 
   oPrint:Say(_nLin, 1550, "CIDADE"                , oFont21) 
   oPrint:Say(_nLin, 2000, "UF"                    , oFont21) 
   oPrint:Say(_nLin, 2130, "VLR PRODUTO"           , oFont21) 
   oPrint:Say(_nLin, 2350, "VLR SERVIÇO"           , oFont21) 
   oPrint:Say(_nLin, 2600, "VLR FRETE"             , oFont21) 
   oPrint:Say(_nLin, 2810, "DEVOLUÇÕES"            , oFont21) 
   oPrint:Say(_nLin, 3040, "VLR TOTAL"             , oFont21) 

   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 40

   If __Empresa == "01"
      Do Case
         Case Alltrim(cEmpFil) == "01"
              oPrint:Say(_nLin, 1550, "FILIAL: 01 - PORTO ALEGRE"  , oFont10b) 
         Case Alltrim(cEmpFil) == "02"
              oPrint:Say(_nLin, 1550, "FILIAL: 02 - CAIXAS DO SUL" , oFont10b) 
         Case Alltrim(cEmpFil) == "03"
              oPrint:Say(_nLin, 1550, "FILIAL: 03 - PELOTAS"       , oFont10b) 
      EndCase        
   Else
      If __Empresa == "02"
         oPrint:Say(_nLin, 1550, "FILIAL: 02 - TI CURITIBA"  , oFont10b) 
      Else
         oPrint:Say(_nLin, 1550, "FILIAL: 03 - ATECH"  , oFont10b)          
      Endif
   Endif

   _nLin += 50

   oPrint:Say(  _nLin, 1550, "DATA..: " + Substr(cData,07,02) + "/" + Substr(cData,05,02) + "/" + Substr(cData,01,04), oFont10b) 

   _nLin += 60

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaAna(nLinhas,cEmpFil, cData)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAANA(cEmpFil, cData)
   Endif
   
Return .T.      

// Imprime o cabeçalho do relatório de Faturamento por período Sintético
Static Function CABECASIN(cEmpFil, cData)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont21)
   oPrint:Say( _nLin, 0950, "FATURAMENTO POR PERÍODO - SINTÉTICO"  , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()            , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR08.PRW", oFont21)
   oPrint:Say( _nLin, 0950, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "DATA"          , oFont21)  
   oPrint:Say( _nLin, 0340, "TIPO"          , oFont21)  
   oPrint:Say( _nLin, 0570, "VALOR PRODUTOS", oFont21)  
   oPrint:Say( _nLin, 0970, "VALOR SERVIÇOS", oFont21)  
   oPrint:Say( _nLin, 1370, "VALOR DO FRETE", oFont21)  
   oPrint:Say( _nLin, 1770, "VLR DEVOLUÇÕES", oFont21)  
   oPrint:Say( _nLin, 2130, "VALOR TOTAL"   , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 50

   If __Empresa == "01"
      Do Case
         Case Alltrim(cEmpFil) == "01"
              oPrint:Say(_nLin, 1550, "FILIAL: 01 - PORTO ALEGRE"  , oFont10b) 
         Case Alltrim(cEmpFil) == "02"
              oPrint:Say(_nLin, 1550, "FILIAL: 02 - CAIXAS DO SUL" , oFont10b) 
         Case Alltrim(cEmpFil) == "03"
              oPrint:Say(_nLin, 1550, "FILIAL: 03 - PELOTAS"       , oFont10b) 
      EndCase        
   Else
      If __Empresa == "02"
         oPrint:Say(_nLin, 1550, "FILIAL: 02 - TI CURITIBA"  , oFont10b) 
      Else
         oPrint:Say(_nLin, 1550, "FILIAL: 03 - ATECH"  , oFont10b)          
      Endif
   Endif

   _nLin += 60

Return .T.

// Função que soma linhas para impressão do relatório de faturamento por período sintético
Static Function SomaLinhaSin(nLinhas,cEmpFil, cData)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECASIN(cEmpFil, cData)
   Endif
   
Return .T.

/*
         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

A N A L I T I C O

AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO DE FATUMANETO POR PERIODO                                                                 XX/XX/XXXX-XX:XX:XX
AUTOMR06.PRW                                                                       PERIODO DE XX/XX/XXXX A XX/XX/XXXX                                                                PAGINA:       XXXXX 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
NF     SR  NR.PV  TIPO    CODIGO    DESCRIÇÃO DOS CLIENTES                                       CIDADE                         UF    VLR PRODUTO   VLR SERVICO     VLR FRETE    DEVOLUÇÕES    VLR TOTAL
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                            FILIAL: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                            DATA..: XX/XX/XXXX

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
XXXXXX XXX XXXXXX XXXXXXX xxxxxx.xx XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX   X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX X.XXX.XXX,XX 
                                                                                                 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
                                                                                                 TOTAL PEDIDOS INTERNOS NA DATA:
                                                                                                 TOTAL PEDIDOS EXTERNOS NA DATA:
                                                                                                 TOTAL OUTRAS DEVOLUÇÕES.......: 
                                                                                                 TOTAL GERAL DA DATA...........:

                                                                                                 TOTAL PEDIDOS INTERNOS FILIAL.:
                                                                                                 TOTAL PEDIDOS EXTERNOS FILIAL.:
                                                                                                 TOTAL OUTRAS DEVOLUÇÕES.......:
                                                                                                 TOTAL GERAL DA FILIAL.........:
                                                                                                          
                                                                                                 -------------------------------------------------------------------------------------------------------                    
                                                                                                 TOTAL PEDIDOS INTERNOS PERÍODO:
                                                                                                 TOTAL PEDIDOS EXTERNOS PERÍODO:
                                                                                                 TOTAL OUTRAS DEVOLUÇÕES.......:
                                                                                                 TOTAL GERAL DO PERÍODO........:



S I N T E T I C O


AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA    FATURAMENTO POR PERÍODO - SINTÉTICO     XX/XX/XXXX-XX:XX:XX
AUTOMR08.PRW                             PERÍODO DE XX/XX/XXXX A XX/XX/XXXX      PAGINA:       XXXXX
----------------------------------------------------------------------------------------------------
DATA        TIPO         VLR PRODUTO     VLR SERVICO       VLR FRETE      DEVOLUÇÕES       VLR TOTAL
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------"

                                        FILIAL: 01 - PORTO ALEGRE

         1         2         3         4         5         6         7         8         9       100    
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
DATA       T  VLR PRODUTO   VLR SERVICO     VLR FRETE    DEVOLUÇÕES     VLR TOTAL
XX/XX/XXXX I X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX
           E X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX
       TOTAL X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX  X.XXX.XXX,XX

XX/XX/XXXX  INTERNOS  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX
            EXTERNOS  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX
            TOTAL     XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX

*/