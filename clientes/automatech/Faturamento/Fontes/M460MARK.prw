#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    
#include "RWMAKE.CH"
#include "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M460MARK.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 20/03/2012                                                          ##
// Objetivo..: Em 27/01/2016,foi verificado a necessidade de incluir consistências ##
//             antes de preparar o documento de saída em razão de muitos problemas ##
//             que estão sendo encontrados no faturamento das notas fiacais. O ob- ##
//             jetivo destas consistências é antecipar  possíveis  problemas antes ##
//             do envio do documento ao Sefaz ou Prefeituras.                      ##
//             A medida que forem surgindo novas necessidades, estas serão incluí- ##
//             das neste fonte.                                                    ##
// ##################################################################################

User Function M460MARK()

   Local cSql    := ""
   Local cMarca  := ""                                                     

   Local cCon00  := ""
   Local cCon01  := ""
   Local cCon02  := ""
   Local cCon03  := ""
   Local cCon04  := ""
   Local cCon05  := ""
   Local cCon06  := ""
   Local cCon07  := ""
   Local cCon08  := ""
   Local cCon09  := ""
   Local cCon10  := ""
   Local cCon11  := ""

   Local cMemo1	 := ""
   Local aSaldos := {}

   Local oMemo1
   Local oSaldos

   Private oFont10c := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

   Private oDlgSaldos

   Private lContinuar  := .F.
   Private lVaiAdiante := .T.
 
   // ##############################################################
   // Envia para o programa que contabiliza o acesso de programas ##
   // ##############################################################
   U_AUTOM628("M460MARK")

//   // ###################################################################################
//   // Verifica se existem produtos de pedidos de venda marcados que não possuem saldo. ##
//   // Se não houve saldo para um dos produtos do pedido de venda, não permite elaborar ##
//   // o Documento de Saída. Dã mensagem ao usuário através de verificação dos pedidos/ ##
//   // produtos em tela admin	de visualização.                                       ##
//   // ###################################################################################
//   cMarca := PARAMIXB[1]
//   
//   // #######################################################################################
//   // Pesquisa os Produtos dos Pedidos de Venda para verificação de saldo para atendimento ##
//   // #######################################################################################
//   If Select("T_SALDOS") > 0
//      T_SALDOS->( dbCloseArea() )
//   EndIf
//
//   cSql := ""
//   cSql := "SELECT SC9.C9_OK     ,"                                     + chr(13)
//   cSql += "       SC9.C9_FILIAL ,"                                     + chr(13)
//   cSql += "	   SC9.C9_PEDIDO ,"                                     + chr(13)
//   cSql += "       SC9.C9_ITEM   ,"                                     + chr(13)
//   cSql += "	   SC9.C9_PRODUTO,"                                     + chr(13)
//   cSql += "      (SELECT B1_DESC + B1_DAUX"                            + chr(13)
//   cSql += "         FROM " + RetSqlName("SB1")                         + chr(13)
//   cSql += "        WHERE B1_COD     = SC9.C9_PRODUTO   "               + chr(13)
//   cSql += "          AND D_E_L_E_T_ = '') AS DESCRICAO,"               + chr(13)
//   cSql += "       SC9.C9_QTDLIB ,"                                     + chr(13)
//   cSql += "      (SELECT B2_QATU "                                     + chr(13)
//   cSql += "         FROM " + RetSqlName("SB2")                         + chr(13)
//   cSql += "        WHERE B2_FILIAL  = SC9.C9_FILIAL "                  + chr(13)
//   cSql += "          AND B2_COD     = SC9.C9_PRODUTO"                  + chr(13)
//   cSql += "          AND B2_LOCAL   = '01'"                            + chr(13)
//   cSql += "          AND D_E_L_E_T_ = '') AS SALDO"                    + chr(13)
//   cSql += "  FROM " + RetSqlName("SC9") + " SC9 "                      + chr(13)
//   cSql += " WHERE SC9.D_E_L_E_T_  = ''"                                + chr(13)
//   cSql += "   AND RTRIM(LTRIM(SC9.C9_OK)) = '" + Alltrim(cMarca) + "'" + chr(13)
//   cSql += "   AND SC9.C9_NFISCAL  = ''"                                + chr(13)
//   cSql += "   AND SC9.C9_FILIAL   = '" + Alltrim(cFilAnt) + "'"        + chr(13)
//
//   cSql := ChangeQuery( cSql )
//   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDOS", .T., .T. )
//
//   T_SALDOS->( DbGoTop() )
//   
//   WHILE !T_SALDOS->( EOF() )
//   
//      If T_SALDOS->C9_QTDLIB < T_SALDOS->SALDO
//         
//         aAdd( aSaldos, { T_SALDOS->C9_PEDIDO ,;
//                          T_SALDOS->C9_ITEM   ,;
//                          T_SALDOS->C9_PRODUTO,;
//                          T_SALDOS->DESCRICAO ,;
//                          T_SALDOS->C9_QTDLIB ,;
//                          T_SALDOS->SALDO     })
//         
//      Endif
//      
//      T_SALDOS->( DbSkip() )
//      
//   ENDDO
//      
//   If Len(aSaldos) == 0
//   Else
//
//      DEFINE MSDIALOG oDlgSaldos TITLE "Inconsistência de Saldos de Produtos para Faturamento" FROM C(178),C(181) TO C(613),C(759) PIXEL Style DS_MODALFRAME
//
//      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(022) PIXEL NOBORDER OF oDlgSaldos
//
//      @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(283),C(001) PIXEL OF oDlgSaldos
//
//      @ C(033),C(005) Say "ATENÇÃO!"                                                                                                               Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgSaldos
//      @ C(042),C(005) Say "O(s) produto(s) do(s) pedido(s) de venda abaixo não possuem saldo suficiente para realizar seu faturamento. Verifique!" Size C(280),C(008) COLOR CLR_BLACK PIXEL OF oDlgSaldos
//
//      @ C(201),C(106) Button "Ver Saldo" Size C(037),C(012) PIXEL OF oDlgSaldos ACTION( kSaldoProd(aSaldos[oSaldos:nAt,03]) )
//      @ C(201),C(145) Button "Retornar"  Size C(037),C(012) PIXEL OF oDlgSaldos ACTION( oDlgSaldos:End() )
//
//      oSaldos := TCBrowse():New( 67 , 005,362, 185,,{'Nº PV'                   ,; // 01 
//                                                     'Item'                    ,; // 02
//                                                     'Código Produto'          ,; // 03
//                                                     'Descrição dos Produtos'  ,; // 04
//                                                     'Quantª a Faturar'        ,; // 05
//                                                     'Saldo Disponível'       },; // 06
//                                                     {20,50,50,50},oDlgSaldos,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
//
//      oSaldos:SetArray(aSaldos) 
//    
//      oSaldos:bLine := {||{ aSaldos[oSaldos:nAt,01],;
//                            aSaldos[oSaldos:nAt,02],;
//                            aSaldos[oSaldos:nAt,03],;
//                            aSaldos[oSaldos:nAt,04],;
//                            aSaldos[oSaldos:nAt,05],;
//                            aSaldos[oSaldos:nAt,06]}}
//
//      ACTIVATE MSDIALOG oDlgSaldos CENTERED 
//
//      Return(.F.)
//
//   Endif   

   // #########################################################################################################################
   // Envia para a função que permite o usuário visualizar as observações internas antes da preparação do documento de saída ##
   // #########################################################################################################################
   OlhaInternas()

   If lContinuar == .F.
      Return(.F.)
   Endif

   // #############################################################################################################
   // Chamada da função temporária do Paulo e do Harald para verificação de CFOP dos produtos do pedido de venda ##
   // #############################################################################################################
   VerCFOPTemp()

   If lVaiAdiante == .F.
      Return(.F.)
   Endif

   // ##################################################################
   // Carrega os parâmetros de Consistência para o Documento de Saída ##
   // ##################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL,"
   cSql += "       ZZ4_CONC  ,"
   cSql += "       ZZ4_CONS  ,"
   cSql += "       ZZ4_GTRI  ,"
   cSql += "       ZZ4_CFOP   "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      cCon00 := ""
      cCon01 := ""
      cCon02 := ""
      cCon03 := ""
      cCon04 := ""
      cCon05 := ""
   Else
      cCon00 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",   1), "|", 2)
      cCon01 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",   2), "|", 2)
      cCon02 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",   3), "|", 2)
      cCon03 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",   4), "|", 2)
      cCon04 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",   5), "|", 2)
      cCon05 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",   6), "|", 2)
   Endif          

   // #####################################################################
   // Verifica se realiza a consistência dos dados do documento de saída ##
   // #####################################################################
   If cCon00 == "0"
      Return(.T.)
   Endif   

   // ###############################################################################
   // Realiza a consistências de dados antes da preparação dos documentos de saída ##
   // ###############################################################################
   cMarca := PARAMIXB[1]
   
   // ##########################################################
   // Pesquisa os Pedidos que estão marcados para faturamento ##
   // ##########################################################
   If Select("T_MARCADOS") > 0
      T_MARCADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C9_OK     ,"
   cSql += "       A.C9_FILIAL ,"
   cSql += "       A.C9_PEDIDO ,"
   cSql += "       B.C5_CONDPAG,"
   cSql += "       C.E4_TIPO   ,"
   cSql += "       B.C5_DATA1  ,"
   cSql += "       B.C5_DATA2  ,"
   cSql += "       B.C5_DATA3  ,"
   cSql += "       B.C5_DATA4  ,"
   cSql += "       B.C5_PARC1  ,"
   cSql += "       B.C5_PARC2  ,"
   cSql += "       B.C5_PARC3  ,"
   cSql += "       B.C5_PARC4  ,"
   cSql += "       B.C5_CLIENTE,"
   cSql += "       B.C5_LOJACLI,"
   cSql += "       B.C5_FILIAL ,"
   cSql += "       B.C5_NUM     "
   cSql += "  FROM " + RetSqlName("SC9") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B, "
   cSql += "       " + RetSqlName("SE4") + " C  "   
   cSql += " WHERE A.C9_OK        = '" + Alltrim(cMarca) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.C9_NFISCAL   = ''"
   cSql += "   AND A.C9_FILIAL    = B.C5_FILIAL"
   cSql += "   AND A.C9_PEDIDO    = B.C5_NUM   "
   cSql += "   AND B.C5_CONDPAG   = C.E4_CODIGO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MARCADOS", .T., .T. )
   
   If T_MARCADOS->( EOF() )
      Return .T.
   Endif

   T_MARCADOS->( DbGoTop() )

   WHILE !T_MARCADOS->( EOF() )
   
      // ########################################################################################
      // Verifica se o pedido selecionado é um pedido de venda vinculado a contrato de locação ##
      // ########################################################################################
      If cCon02 == "1"
         If U_AUTOM341(1, T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
            Return(.F.)
         Endif
      Endif   

      // ##################################################################################################################
      // Verifica se todos os nºs de séries dos produtos foram informado em caso de produtos com controle de nº de série ##
      // ##################################################################################################################
      If cCon03 == "1"
         If U_AUTOM341(5, T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
            Return(.F.)
         Endif
      Endif   
      
      // ########################################################################################
      // Verifica se pedido de venda é de Caxias do Sul/RS e se tem serviço no pedido de venda ##
      // ########################################################################################
      If cCon04 == "1"
         If U_AUTOM341(6, T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
            Return(.F.)
         Endif
      Endif   

      // ##################################################################
      // Verifica a classificação fiscal dos produtos do pedido de venda ##
      // ##################################################################
      If cCon05 == "1"
         If U_AUTOM341(7, T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
            Return(.F.)
         Endif
      Endif

      T_MARCADOS->( DbSkip() )
      
   ENDDO
   
Return(.T.)

// ###########################################################################################################
// Função que abre janela para visualizar observações internas antes da prepração dos doscumentos de saídas ##
// ###########################################################################################################
Static Function OlhaInternas()

   Local cSql       := ""
   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1
   Local xMarca     := ""

   Private cInterna := ""
   Private oMemo2

   Private aSelecionados := {}

   // ##############################
   // Captura a marca dos pedidos ##
   // ##############################
   xMarca := PARAMIXB[1]
   
   // ##########################################################
   // Pesquisa os Pedidos que estão marcados para faturamento ##
   // ##########################################################
   If Select("T_OBSERVACAO") > 0
      T_OBSERVACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C9_FILIAL,"
   cSql += "   	   A.C9_PEDIDO "       
   cSql += "  FROM " + RetSqlName("SC9") + " A "
   cSql += " WHERE RTRIM(LTRIM(A.C9_OK)) = '" + Alltrim(xMarca) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.C9_NFISCAL   = ''"   
   cSql += " GROUP BY A.C9_FILIAL, A.C9_PEDIDO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVACAO", .T., .T. )
   
   If T_OBSERVACAO->( EOF() )
      lContinuar := .F.
      Return(.T.)
   Endif

   T_OBSERVACAO->( DbGoTop() )
   
   WHILE !T_OBSERVACAO->( EOF() )
   
      aAdd( aSelecionados, { T_OBSERVACAO->C9_PEDIDO, T_OBSERVACAO->C9_FILIAL })
      
      T_OBSERVACAO->( DbSkip() )
      
   ENDDO

   If Len(aSelecionados) == 0
      aAdd( aSelecionados, { "", "" } )
   Else
      MOSTRAOBS(aSelecionados[01,01], aSelecionados[01,02], 0)      
   Endif

   Private oDlgOlha

   DEFINE MSDIALOG oDlgOlha TITLE "Preparação de Documento de Saída" FROM C(178),C(181) TO C(563),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp"                               Size C(138),C(030)                 PIXEL NOBORDER OF oDlgOlha

   @ C(035),C(003) GET oMemo1 Var cMemo1 MEMO                                Size C(384),C(001)                 PIXEL OF oDlgOlha

   @ C(039),C(005) Say "Pedidos Selecionados"                                Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha
   @ C(038),C(063) Say "Observações internas do pedido de venda selecionado" Size C(134),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha

   @ C(046),C(063) GET oMemo2 Var cInterna MEMO                              Size C(325),C(127)                 PIXEL OF oDlgOlha When lChumba

   @ C(176),C(312) Button "Prep.Doc"                                         Size C(037),C(012)                 PIXEL OF oDlgOlha ACTION(FechaOlha(1))
   @ C(176),C(351) Button "Voltar"                                           Size C(037),C(012)                 PIXEL OF oDlgOlha ACTION(FechaOlha(2))

   oSelecionados := TCBrowse():New( 050 , 005, 072, 170,,{'Pedidos' + Space(50), 'Filial'}, {20,50,50,50},oDlgOlha,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oSelecionados:SetArray(aSelecionados) 
   
   oSelecionados:bLine := {||{ aSelecionados[oSelecionados:nAt,01], aSelecionados[oSelecionados:nAt,02]}}

   oSelecionados:bLDblClick := {|| MOSTRAOBS(aSelecionados[oSelecionados:nAt,01], aSelecionados[oSelecionados:nAt,02], 1) } 

   ACTIVATE MSDIALOG oDlgOlha CENTERED 

Return(.T.)

// ######################################################################### 
// Função que mostra a observação interna do pedido de venda selecionados ##
// #########################################################################
Static Function MOSTRAOBS(_Pedido, _Filial, _Onde)

   Local cSql := ""

   // Pesquisa os Pedidos que estão marcados para faturamento
   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), B.C5_OBSI)) AS INTERNA"
   cSql += "  FROM " + RetSqlName("SC5") + " B "
   cSql += " WHERE B.C5_FILIAL  = '" + Alltrim(_Filial) + "'"
   cSql += "   AND B.C5_NUM     = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND B.D_E_L_E_T_ = ''" 
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )
  
   If T_NOTA->( EOF() )
      cInterna := ""
   Else
      cInterna := T_NOTA->INTERNA
   Endif
   
   If _Onde == 1
      oMemo2:Refresh()
   Endif   

Return(.T.)

// #######################################################################################################
// Função que fecha a janela de visualização das observações internas dos pedidos de venda selecionados ##
// #######################################################################################################
Static Function FechaOlha(_BotaoAcionado)

   If _BotaoAcionado == 1
      lContinuar := .T.
   Else
      lContinuar := .F.
   Endif

   oDlgOlha:End() 
   
Return(.T.)      

// ################################################################################
// Função temporária incluída em 19/10/2016 para verificação de CFOP de produtos ##
// ################################################################################
Static Function VerCFOPTemp()

   Local cSql   := ""
   Local cmarca := ""

   lVaiAdiante == .T.

   // ###############################################################################
   // Realiza a consistências de dados antes da preparação dos documentos de saída ##
   // ###############################################################################
   cMarca := PARAMIXB[1]

   // ##########################################################
   // Pesquisa os Pedidos que estão marcados para faturamento ##
   // ##########################################################
   If Select("T_MARCADOS") > 0
      T_MARCADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C9_OK     ,"
   cSql += "       A.C9_FILIAL ,"
   cSql += "       A.C9_PEDIDO ,"
   cSql += "       B.C5_CONDPAG,"
   cSql += "       C.E4_TIPO   ,"
   cSql += "       B.C5_DATA1  ,"
   cSql += "       B.C5_DATA2  ,"
   cSql += "       B.C5_DATA3  ,"
   cSql += "       B.C5_DATA4  ,"
   cSql += "       B.C5_PARC1  ,"
   cSql += "       B.C5_PARC2  ,"
   cSql += "       B.C5_PARC3  ,"
   cSql += "       B.C5_PARC4  ,"
   cSql += "       B.C5_CLIENTE,"
   cSql += "       B.C5_LOJACLI,"
   cSql += "       B.C5_FILIAL ,"
   cSql += "       B.C5_NUM     "
   cSql += "  FROM " + RetSqlName("SC9") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B, "
   cSql += "       " + RetSqlName("SE4") + " C  "   
   cSql += " WHERE A.C9_OK        = '" + Alltrim(cMarca) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.C9_NFISCAL   = ''"
   cSql += "   AND A.C9_FILIAL    = B.C5_FILIAL"
   cSql += "   AND A.C9_PEDIDO    = B.C5_NUM   "
   cSql += "   AND B.C5_CONDPAG   = C.E4_CODIGO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MARCADOS", .T., .T. )
   
   If T_MARCADOS->( EOF() )
      Return .T.
   Endif

   T_MARCADOS->( DbGoTop() )

   WHILE !T_MARCADOS->( EOF() )
   
      // Verifica o CFOP dos produtos marcados
      If U_AUTOM508(T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
         lVaiAdiante := .F.
         Return(.F.)
      Endif

      T_MARCADOS->( DbSkip() )
      
   ENDDO
   
Return(.T.)

// #############################################################
// Função que pesquisa o saldo do produto selecionado no grid ##
// #############################################################
Static Function kSaldoProd(_Produto)

   If Empty(Alltrim(_Produto))
      MsgAlert("Produto a ser pesquisado não selecionado.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // ####################################################
   // Posiciona no produto a ser pesquisado o seu saldo ##
   // ####################################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return(.T.)





/*

   Local cSql         := ""
   Local cMarca       := ""                                                     
   Local nContar      := 0
   Local nVerifica    := 0
   Local cAbre        := .F.
   Local lTemProblema := .F.
   Local aErros       := {}
   Local lDigito      := .F.

   Local vPedido      := Space(006)
   Local vCliente     := Space(250)
   Local vVendedor    := Space(250)
   Local cMemo1	      := ""
   Local cMemo2	      := ""
   Local cMemo3	      := ""
   Local vErros       := ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4

   Local cCon00 := ""
   Local cCon01 := ""
   Local cCon02 := ""
   Local cCon03 := ""
   Local cCon04 := ""
   Local cCon05 := ""
   Local cCon06 := ""
   Local cCon07 := ""
   Local cCon08 := ""
   Local cCon09 := ""
   Local cCon10 := ""
   Local cCon11 := ""

   Private lContinuar := .F.

   // Envia para a função que permite o usuário visualizar as observações internas antes da preparação do documento de saída
   OlhaInternas()

   If lContinuar == .F.
      Return(.F.)
   Endif













   // Carrega os parâmetros de Consistência
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL,"
   cSql += "       ZZ4_CONS  ,"
   cSql += "       ZZ4_GTRI  ,"
   cSql += "       ZZ4_CFOP   "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      cCon00 := ""
      cCon01 := ""
      cCon02 := ""
      cCon03 := ""
      cCon04 := ""
      cCon05 := ""
      cCon06 := ""
      cCon07 := ""
      cCon08 := ""
      cCon09 := ""
      cCon10 := ""
      cCon11 := ""
   Else
      cCon00 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   1), "|", 2)
      cCon01 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   2), "|", 2)
      cCon02 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   3), "|", 2)
      cCon03 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   4), "|", 2)
      cCon04 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   5), "|", 2)
      cCon05 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   6), "|", 2)
      cCon06 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   7), "|", 2)
      cCon07 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   8), "|", 2)
      cCon08 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   9), "|", 2)
      cCon09 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",  10), "|", 2)
      cCon10 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",  11), "|", 2)
      cCon11 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",  12), "|", 2)
   Endif          

   Private oDlgErro

   // Veridica se realiza a consistência dos dados
   If cCon00 == "0"
      Return(.T.)
   Endif   

   // Captura a marca dos pedidos
   cMarca := PARAMIXB[1]
   
   // Pesquisa os Pedidos que estão marcados para faturamento
   If Select("T_MARCADOS") > 0
      T_MARCADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C9_OK     ,"
   cSql += "       A.C9_FILIAL ,"
   cSql += "       A.C9_PEDIDO ,"
   cSql += "       B.C5_CONDPAG,"
   cSql += "       C.E4_TIPO   ,"
   cSql += "       B.C5_DATA1  ,"
   cSql += "       B.C5_DATA2  ,"
   cSql += "       B.C5_DATA3  ,"
   cSql += "       B.C5_DATA4  ,"
   cSql += "       B.C5_PARC1  ,"
   cSql += "       B.C5_PARC2  ,"
   cSql += "       B.C5_PARC3  ,"
   cSql += "       B.C5_PARC4  ,"
   cSql += "       B.C5_CLIENTE,"
   cSql += "       B.C5_LOJACLI,"
   cSql += "       B.C5_FILIAL ,"
   cSql += "       B.C5_NUM     "
   cSql += "  FROM " + RetSqlName("SC9") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B, "
   cSql += "       " + RetSqlName("SE4") + " C  "   
   cSql += " WHERE A.C9_OK        = '" + Alltrim(cMarca) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.C9_NFISCAL   = ''"
   cSql += "   AND A.C9_FILIAL    = B.C5_FILIAL"
   cSql += "   AND A.C9_PEDIDO    = B.C5_NUM   "
   cSql += "   AND B.C5_CONDPAG   = C.E4_CODIGO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MARCADOS", .T., .T. )
   
   If T_MARCADOS->( EOF() )
      Return .T.
   Endif

   // Verifica se algum dos pedidos de venda selecionados são pedidos de locação
   If cCon02 == "1"
 
      T_MARCADOS->( DbGoTop() )

      WHILE !T_MARCADOS->( EOF() )

         // Verifica se o pedido selecionado é um pedido vinculado ao módulo de contrato.
         // Se for, verifica se o contrato já está no status 05 - Em Vigência
         If Select("T_CONTRATO") > 0
            T_CONTRATO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.CK_FILIAL ,"
         cSql += "       A.CK_NUMPV  ,"
         cSql += "       A.CK_PROPOST,"
         cSql += "       B.ADY_PROPOS,"
         cSql += "       B.ADY_OPORTU,"
         cSql += "       C.AD1_ZCONTR,"
         cSql += "       D.CN9_SITUAC,"
         cSql += "       B.ADY_CODIGO,"
         cSql += "       B.ADY_LOJA  ,"
         cSql += "       E.A1_NOME    "
         cSql += "  FROM " + RetSqlName("SCK") + " A, "
         cSql += "       " + RetSqlName("ADY") + " B, "
         cSql += "       " + RetSqlName("AD1") + " C, "
         cSql += "       " + RetSqlName("CN9") + " D, "
         cSql += "       " + RetSqlName("SA1") + " E  "
         cSql += " WHERE A.CK_FILIAL   = '" + Alltrim(T_MARCADOS->C9_FILIAL) + "'"
         cSql += "   AND A.CK_NUMPV    = '" + Alltrim(T_MARCADOS->C9_PEDIDO) + "'"
         cSql += "   AND A.D_E_L_E_T_  = ''          "
         cSql += "   AND B.ADY_FILIAL  = A.CK_FILIAL "
         cSql += "   AND B.ADY_PROPOS  = A.CK_PROPOST"
         cSql += "   AND B.D_E_L_E_T_  = ''          "
         cSql += "   AND C.AD1_FILIAL  = B.ADY_FILIAL"
         cSql += "   AND C.AD1_NROPOR  = B.ADY_OPORTU"
         cSql += "   AND C.D_E_L_E_T_  = ''          "
         cSql += "   AND C.AD1_ZCONTR <> ''          "
         cSql += "   AND D.CN9_FILIAL  = C.AD1_FILIAL"
         cSql += "   AND D.CN9_NUMERO  = C.AD1_ZCONTR"
         cSql += "   AND D.D_E_L_E_T_  = ''          "
         cSql += "   AND B.ADY_CODIGO  = E.A1_COD    "
         cSql += "   AND B.ADY_LOJA    = E.A1_LOJA   "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATO", .T., .T. )

         If T_CONTRATO->( EOF() )
         Else
            If T_CONTRATO->CN9_SITUAC <> "05"
               aAdd( aErros, {T_CONTRATO->CK_FILIAL ,;
                              T_CONTRATO->CK_NUMPV  ,;
                              T_MARCADOS->ADY_CODIGO,;
                              T_MARCADOS->ADY_LOJA  ,;
                              T_MARCADOS->A1_NOME   ,;
                              "Pedido de venda refere-se a um pedido de venda vinculado a um contrato de locação, porém, este contrato ainda está aguardando liberação do departamento financeiro. Aguarde liberação do financeiro." ,;
                              "1", ;
                              "REPORTAR: Entre em conttao com o financeiro para verificar a situação deste pedido."})
            Endif
         Endif
      
         T_MARCADOS->( DbSkip() )
   
      ENDDO   
      
   Endif   

   // --------------------------------------------------------------------------- //
   // Verifica se a condição de pagamento dos pedidos é Condição Negociável Valor //
   // --------------------------------------------------------------------------- //
   If cCon01 == "1"

      T_MARCADOS->( DbGoTop() )
   
      WHILE !T_MARCADOS->( EOF() )

         cAbre := .F.

         If Alltrim(T_MARCADOS->E4_TIPO) == "9"
         
            If CTOD(T_MARCADOS->C5_DATA1) < DATE() .OR. ;
               CTOD(T_MARCADOS->C5_DATA2) < DATE() .OR. ;
               CTOD(T_MARCADOS->C5_DATA3) < DATE() .OR. ;
               CTOD(T_MARCADOS->C5_DATA4) < DATE()
               ALTVENCI(T_MARCADOS->C9_PEDIDO, T_MARCADOS->C9_FILIAL)
            Endif
         
         Endif
      
         T_MARCADOS->( DbSkip() )
   
      ENDDO   
      
   Endif   

   // ----------------------------------------------------- //
   // Consiste dados para preparação do documento de saída. // 
   // ----------------------------------------------------- //
   T_MARCADOS->( DbGoTop() )

   WHILE !T_MARCADOS->( EOF() )

      // Verifica o Grupo Tributário do Cliente
      If cCon03 == "1"

         If POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_GRPTRIB") == "002"

            If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_INSCR")))
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Grupo Tributário do cliente está configurado como IE ATIVA porém, a IE não foi informada em seu cadastro.",;
                              "1" ,;
                              "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})
            Endif

            If Substr(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_INSCR")),01,04) == "ISEN" 
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Grupo Tributário do cliente está configurado como IE ATIVA porém, a IE está inconsistente em seu cadastro.",;
                              "1" ,;
                              "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
            Endif

         Else

            If Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_INSCR")) <> "ISENTO"
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Grupo Tributário do cliente está configurado como IE INATIVA porém, a IE está inconsistente em seu cadastro." ,;
                              "1",;
                              "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
            Endif

         Endif
         
      Endif   

      // Verifica se o Endereço do Cliente foi informado
      If cCon04 == "1"
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_END")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "Cliente sem informação do endereço em seu cadastro." ,;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif
      
         // Verifica se no Endereço existe pelo menos um caracter = a dígito (Numérico)
         xx_Endereco := POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_END")
         lDigito     := .F.
      
         For nContar = 1 to Len(xx_Endereco)
             If IsDigit(Substr(xx_Endereco,nContar,1))
                lDigito := .T.
                Exit
             Endif
         Next nContar       

         If lDigito == .F.      
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "Endereço do cliente deve conter pelo menu um caracter Numérico." ,;
                           "1",;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         // Verifica se no Endereço do Cliente consta uma vírgula
         If U_P_OCCURS(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_END"),",",1) == 0
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "Endereço do cliente sem separador ( , - Vírgula ) entre o endereço e o nº do logradouro." ,;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

      Endif   

      // Verifica se o CEP do Endereço
      If cCon05 == "1"
         If Len(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_CEP"))) <> 8
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "CEP do endereço é inválido." ,;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         If POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_CEP") == "00000000"
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "CEP do endereço é inválido.",;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_CEP")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "CEP do endereço não informado.",;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif
   
      Endif

      // Verifica se o DDD do telefone do cliente
      If cCon06 == "1"
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")  + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_DDD")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "DDD do telefone do cliente inválido.",;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         // Verifica se o Telefone do cliente
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")  + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_TEL")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "Telefone do cliente é inválido.",;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

      Endif
   
      // Verifica o e-mail do cliente
      If cCon07 == "1"
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "E-mail do cliente inexistente.",;
                           "1" ,;
                           "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         // Verifica se o e-mail é válido
         If U_P_OCCURS(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL"),";",1) == 0
            If !ISEMAIL(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL")))
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "E-mail do Cliente é inválido.",;
                              "1" ,;
                              "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
            Endif
         
         Else
      
            __nEmail := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL")) + ";"
        
            For nContar = 1 to U_P_OCCURS(__nEmail,";",1)
    
                __email := U_P_CORTA(  __nEmail, ";", ncontar)
         
                If !ISEMAIL(Alltrim(__email))
                   aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                                  "Nº PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                                  "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                                  "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                                  "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                                  "INCONSISTÊNCIA: " + "E-mail do Cliente é inválido.",;
                                  "1" ,;
                                  "SOLUÇÃO: Solicite ao vendedor para corrir o cadatro do cliente."})                           
                Endif
             
            Next nContar    
      
         Endif      
         
      Endif   

      // Pesquisa os produtos para análise
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "       SC6.C6_PRODUTO,"
      cSql += "       SB1.B1_TIPO   ,"
      cSql += "       SB1.B1_POSIPI ,"
  	  cSql += "       SB1.B1_LOCALIZ,"
      cSql += "       SB1.B1_DESC   ,"
  	  cSql += "       SB1.B1_UM     ,"
      cSql += "       SB1.B1_GRTRIB ,"
  	  cSql += "       SC6.C6_QTDVEN ,"
  	  cSql += "       SC6.C6_ITEM   ,"
  	  cSql += "       SC6.C6_CLI    ," 
  	  cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SC6.C6_TES    ,"
      cSql += "       SC6.C6_CF     ,"
  	  cSql += "       SC5.C5_TIPO   ,"
      cSql += "       SF4.F4_DUPLIC  "
      cSql += "  FROM " + RetSqlName("SC5") + " SC5, " 
      cSql += "       " + RetSqlName("SC6") + " SC6, "
      cSql += "       " + RetSqlName("SB1") + " SB1, "
      cSql += "       " + RetSqlName("SF4") + " SF4  "
      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(T_MARCADOS->C5_FILIAL) + "'"
      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(T_MARCADOS->C5_NUM)    + "'"
      cSql += "   AND SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SC6.C6_PRODUTO = SB1.B1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
      cSql += "   AND LTRIM(RTRIM(SB1.B1_UM)) <> 'MO'"
      cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL "
      cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM    "
      cSql += "   AND SC5.D_E_L_E_T_ = ''"
      cSql += "   AND SF4.F4_CODIGO  = SC6.C6_TES
      cSql += "   AND SF4.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      // Verifica se o NCM dos produtos do pedido de venda foram informados
      If cCon08 == "1"

         lTemProblema := .F.

         T_PRODUTOS->( DbGoTop() )
      
         WHILE !T_PRODUTOS->( EOF() )
      
            // Se produto do tipo MO = Mão - de - Obra, desconsidera a consistência
            If Alltrim(T_PRODUTOS->B1_TIPO) == "MO"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif

            // Verifica se produto tem a informação do NCM
            If Empty(Alltrim(T_PRODUTOS->B1_POSIPI))
               lTemProblema := .T.
               Exit
            Endif
         
            // Verifica se a informação do NCM é menor que 8 dígitos
            If Len(T_PRODUTOS->B1_POSIPI) < 8
               lTemProblema := .T.
               Exit
            Endif
            
            // Verifica se a informação do NCM é igual a 00000000
            If Alltrim(T_PRODUTOS->B1_POSIPI) == "00000000"
               lTemProblema := .T.
               Exit
            Endif
         
            // Verifica se a informação do NCM é igual a 99999999
            If Alltrim(T_PRODUTOS->B1_POSIPI) == "99999999"
               lTemProblema := .T.
               Exit
            Endif

            T_PRODUTOS->( DbSkip() )
         
         ENDDO
         
         If lTemProblema == .T.           

            aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                           "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                           "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                           "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "Pededo de Venda possui produtos com NCM inválidos. Redefina.",;
                           "2" ,;
                           "SOLUÇÃO: Entre em contato com Andréia Forte informando esta mensagem para que ela possa corrir o NCM deste produto."})
         Endif
         
      Endif   

      // Verifica os produtos do pedido de venda quais são os produtos que são controlados por nº de série.
      // Se existir produtos com controle de nº de série, verifica na Tabela SDC de os lançamentos estão coerentes.
      If cCon09 == "1"
         lTemProblema := .F.
         aSeries      := {}

         T_PRODUTOS->( DbGoTop() )
      
         WHILE !T_PRODUTOS->( EOF() )
      
            If Alltrim(T_PRODUTOS->B1_LOCALIZ) <> "S"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif
           
            // Verifica a tabela SDB se quantidade de nº de séries está consistente
            If Select("T_NUMSERIE") > 0
               T_NUMSERIE->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT DC_FILIAL ,"
            cSql += "       DC_PEDIDO ,"
            cSql += "       DC_ITEM   ,"
	        cSql += "       DC_PRODUTO,"
	        cSql += "       DC_NUMSERI "
            cSql += "  FROM " + RetSqlName("SDC")
            cSql += " WHERE DC_FILIAL  = '" + Alltrim(T_PRODUTOS->C6_FILIAL)  + "'"
            cSql += "   AND DC_PEDIDO  = '" + Alltrim(T_PRODUTOS->C6_NUM)     + "'"
            cSql += "   AND DC_ITEM    = '" + Alltrim(T_PRODUTOS->C6_ITEM)    + "'"
            cSql += "   AND DC_PRODUTO = '" + Alltrim(T_PRODUTOS->C6_PRODUTO) + "'"
            cSql += "   AND D_E_L_E_T_ = ''"
         
            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMSERIE", .T., .T. )
         
            If T_NUMSERIE->( EOF() )
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " sem informação do(s) Nº(s) de Série(s).",;
                              "3" ,;
                              "SOLUÇÃO: Entre em contato com a Logística informando esta mensagem para a correção."})
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif

            // Verifica se quantidade de nºs de séries confere com a quantidade total do produto do pedido de venda
            T_NUMSERIE->( DbGoTop() )
         
            Count To nLancamentos

            If nLancamentos <> T_PRODUTOS->C6_QTDVEN
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Qtd de Nº(s) de Série(s) do produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " não conferem com a qtd total do pedido de venda.",;
                              "3" ,;
                              "SOLUÇÃO: Entre em contato com a Logística informando esta mensagem para a correção."})
            Endif

            // Verifica se todos os nºs de séries foram informados
            T_NUMSERIE->( DbGoTop() )
              
            nLancamentos := 0

            WHILE !T_NUMSERIE->( EOF() )
               If Empty(Alltrim(T_NUMSERIE->DC_NUMSERI))
               Else
                  nLancamentos := nLancamentos + 1
               Endif
               T_NUMSERIE->( DbSkip() )
            ENDDO
            
            If nLancamentos <> T_PRODUTOS->C6_QTDVEN
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Qtd de Nº(s) de Série(s) do produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " não conferem com a qtd total do pedido de venda.",;
                              "3" ,;
                              "SOLUÇÃO: Entre em contato com a Logística informando esta mensagem para a correção."})
            Endif

            T_PRODUTOS->( DbSkip() )
         
         ENDDO
         
      Endif   
         
      // Verifica se a filial do pedido de venda é 02 - Caxias do Sul.
      // Sendo 02 - Caxias do Sul, verifica se os produtos do pedido são de serviço (Unidade MO - Mãp-de-Obra).
      // Se forem, verifica se os mesmos estão cadastrados no Indicador de Produtos e se estão, se os dados estão corretos.
      If cCon10 == "1"

         lTemProblema := .F.

         T_PRODUTOS->( DbGoTop() )
      
         WHILE !T_PRODUTOS->( EOF() )
      
            If Alltrim(T_PRODUTOS->C6_FILIAL) <> "02"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif
           
            If Alltrim(T_PRODUTOS->B1_TIPO) <> "MO"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif

            // Pesquisa a tabela no Indicador de Produtos
            If Select("T_INDICADOR") > 0
               T_INDICADOR->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT BZ_FILIAL ,"
            cSql += "       BZ_COD    ,"
        	cSql += "       BZ_CODISS ,"
   	        cSql += "       BZ_TRIBMUN,"
   	        cSql += "       BZ_CNAE    "
            cSql += "  FROM " + RetSqlName("SBZ")
            cSql += " WHERE D_E_L_E_T_ = ''"
            cSql += "   AND BZ_FILIAL  = '02'"
            cSql += "   AND BZ_COD     = '" + Alltrim(T_PRODUTOS->C6_PRODUTO) + "'"
         
            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_INDICADOR", .T., .T. )

            If T_INDICADOR->( EOF() )
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não cadastrado no Cadastro de Indicador de Produto.",;
                              "4" ,;
                              "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
            Endif

            // Verifica se o campo BZ_CODISS está preenchido
            If Empty(Alltrim(T_INDICADOR->BZ_CODISS))
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Código do ISS do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não informado no Cadastrado de Indicador de Produto.",;
                              "4" ,;
                              "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
            Endif

            // Verifica se existe (.) na informação o campo BZ_CODISS
            If U_P_OCCURS(T_INDICADOR->BZ_CODISS, ".", 1) <> 0
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Código do ISS do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não pode ter informação de PONTO (.) em seu conteúdo.",;
                              "4" ,;
                              "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
            Endif

            // Verifica se o campo BZ_TRIBMUN está preenchido
            If Empty(Alltrim(T_INDICADOR->BZ_TRIBMUN))
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Código Tributário do Município do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não informado no Cadastrado de Indicador de Produto.",;
                              "4" ,;
                              "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
            Endif

            // Verifica se o campo BZ_TRIBMUN é <> de 131
            If Alltrim(T_INDICADOR->BZ_TRIBMUN) <> "131"
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Código Tributário do Município do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " é inconsistente para Caxias do Sul. Correto 131.",;
                              "4" ,;
                              "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
            Endif

            // Verifica se o campo BZ_CNAE
            If Empty(Alltrim(T_INDICADOR->BZ_CNAE))
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Código CNAE do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não informado no Cadastro de Indicador de Produto.",;
                              "4" ,;
                              "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
            Endif

            T_PRODUTOS->( DbSkip() )
         
         ENDDO
         
      Endif   

      // ----------------------------------------------------------------------------------------------------------------------------------- //
      // Consiste CFOP dos produtos dopedido de venda                                                                                        //
      // Regra:                                                                                                                              //
      // 1º) Pedido de Venda deve ser do tipo N - Normal                                                                                     //
      // 2º) O TES do produto lido deve gerar duplicata (F4_DUPLIC = S)                                                                      //
      // 3º) Se o Grupo Tributário do produto (B1_GRTRIB) for igual a 001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016 e 018, //
      //     CFOP não pode ser os CFOP's 5102 e 6102.                                                                                        //         
      // ----------------------------------------------------------------------------------------------------------------------------------- //
      If cCon11 == "1"
         lTemProblema := .F.

         T_PRODUTOS->( DbGoTop() )
       
         WHILE !T_PRODUTOS->( EOF() )
      
            If Alltrim(T_PRODUTOS->C5_TIPO) <> "N"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif         

            If Alltrim(T_PRODUTOS->F4_DUPLIC) <> "S"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif
           
            If Alltrim(T_PRODUTOS->B1_GRTRIB)$("001#002#003#004#005#006#007#008#009#010#011#012#013#014#015#016#018")

               If Alltrim(T_PRODUTOS->C6_CF)$("5102#6102")
                  aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                                 "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                                 "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                                 "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                                 "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                                 "INCONSISTÊNCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - CFOP de Mercadoria Tributada com produto com grupo Tributário de Substituição Tributária.",;
                                 "4" ,;
                                 "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
               Endif                  
            
            Endif
            
            T_PRODUTOS->( DbSkip() )
         
         ENDDO
         
      Endif   

      T_MARCADOS->( DbSkip() )
   
   ENDDO   

   If Len(aErros) == 0
      Return(.T.)
   Endif
      
   // Prepara a variável cString para display do(s) erro(s) encontrado(s)
   vErros := ""
   For nContar = 1 to Len(aErros)
       vErros += aErros[nContar,01] + chr(13) + chr(10) + ;
                 aErros[nContar,02] + chr(13) + chr(10) + ;
                 aErros[nContar,03] + chr(13) + chr(10) + ;
                 aErros[nContar,04] + chr(13) + chr(10) + ;                                    
                 aErros[nContar,05] + chr(13) + chr(10) + ;
                 aErros[nContar,06] + chr(13) + chr(10) + chr(13) + chr(10)
   Next nContar

   // Desenha a tela para visualização do(s) erro(s) encontrado(s) no pedido de venda
   DEFINE MSDIALOG oDlgErro TITLE "Validação de Emissão de Documento Fiscal" FROM C(178),C(181) TO C(635),C(967) PIXEL

   @ C(005),C(003) Jpeg FILE "logoautoma.bmp" Size C(137),C(029) PIXEL NOBORDER OF oDlgErro

   @ C(039),C(003) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlgErro
   @ C(052),C(003) GET oMemo3 Var cMemo3 MEMO Size C(384),C(001) PIXEL OF oDlgErro

   @ C(027),C(145) Say "Inconsistências encontradas no Pedido de Venda antes da Preparação do Documento de Saída"    Size C(229),C(008) COLOR CLR_BLACK PIXEL OF oDlgErro
   @ C(042),C(005) Say "DOCUMENTO DE SAÍDA NAO SERÁ GERADO ANTES QUE AS INCONSISTÊNCIA(S) ABAIXO SEJAM RESOLVIDA(S)" Size C(293),C(008) COLOR CLR_RED   PIXEL OF oDlgErro

   @ C(054),C(005) Say "Inconsistências Encontradas" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgErro

   @ C(064),C(005) GET oMemo4 Var vErros MEMO Size C(383),C(144) PIXEL OF oDlgErro

   @ C(212),C(351) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgErro ACTION( RespIncon(aErros) )

   ACTIVATE MSDIALOG oDlgErro CENTERED 

Return(.F.)

// Função que envia e-mail ao responsável da inconsistência
Static Function RespIncon(aMensagens)

   Local nContar   := 0
   Local cEmail    := ""
   Local cEndereco := ""
   
   For nContar = 1 to Len(aMensagens)

       // Pesquisa o e-mail do responsável a receber o e-mail
       Do Case
          Case aMensagens[nContar,07] == "1"
       
               If Select("T_ENVIAR") > 0
                  T_ENVIAR->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT SC5.C5_FILIAL,"
               cSql += "       SC5.C5_NUM   ,"
  	           cSql += "       SC5.C5_VEND1 ,"
               cSql += "      (SELECT A3_EMAIL FROM SA3010 WHERE A3_COD = SC5.C5_VEND1 AND D_E_L_E_T_ = '') AS EMAIL_VEND1,"
  	           cSql += "       SC5.C5_VEND2 ,"
               cSql += "      (SELECT A3_EMAIL FROM SA3010 WHERE A3_COD = SC5.C5_VEND2 AND D_E_L_E_T_ = '') AS EMAIL_VEND2 "
               cSql += "  FROM " + RetSqlName("SC5") + " SC5 "
               cSql += " WHERE SC5.C5_FILIAL  = '" + Substr(aMensagens[nContar,01],09,02) + "'"
               cSql += "   AND SC5.C5_NUM     = '" + Substr(aMensagens[nContar,02],14,06) + "'"
               cSql += "   AND SC5.D_E_L_E_T_ = ''"

               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENVIAR", .T., .T. )

               If T_ENVIAR->( EOF() )
                  Loop
               Endif
           
               cEndereco := ""

               // Carrega e-mail primeiro vendedor
               If Empty(Alltrim(T_ENVIAR->EMAIL_VEND1))
               Else
                  cEndereco := Alltrim(T_ENVIAR->EMAIL_VEND1)
               Endif
             
               // Carrega e-mail segundo vendedor
               If Empty(Alltrim(T_ENVIAR->EMAIL_VEND2))
               Else
                  If Empty(Alltrim(cEndereco))
                     cEndereco := Alltrim(T_ENVIAR->EMAIL_VEND2)
                  Else
                     cEndereco := cEndereco + ", " + Alltrim(T_ENVIAR->EMAIL_VEND2)                
                  Endif   
               Endif
          
          // Andréia Fortes
          Case aMensagens[nContar,07] == "2"
               cEndereco := "andreia@automatech.com.br"
               
          // Logistica
          Case aMensagens[nContar,07] == "3"
               cEndereco := "marcos.barboza@automatech.com.br, estoque01@automatech.com.br"
       
          // Controladoria
          Case aMensagens[nContar,07] == "4"
               cEndereco := "administrativo@automatech.com.br"

       EndCase        
       
       If Empty(Alltrim(cEndereco))
          Loop
       Endif
       
       cEmail := ""          
       cEmail := "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += "O Sistema Protheus encontrou uma inconsistência em seu Pedido de Venda no momento de seu faturamento." + chr(13) + chr(10) 
       cEmail += "Favor avaliar e sanar a inconsistência abaixo para que o Pedido de Venda possa ser faturado."          + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += aMensagens[nContar,01] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,02] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,03] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,04] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,05] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,06] + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += "Att." + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += "Departamento de Faturamento"
         
       // Envia e-mail ao Aprovador
//     U_AUTOMR20(cEmail, Alltrim(cEndereco), "", "Aviso de Inconsistência de Faturamento de Pedido de Venda" )

   Next nContar

   oDlgErro:End() 
   
Return(.F.)   

// Função que abre a janela para digitação dos novos vencimentos
Static Function ALTVENCI(_Pedido, _Filial)

   Local lAberto := .F.

   Local cData1	 := CTOD("  /  /    ")
   Local cData2	 := CTOD("  /  /    ")
   Local cData3  := CTOD("  /  /    ")
   Local cData4	 := CTOD("  /  /    ")

   Local cValor1 := 0
   Local cValor2 := 0
   Local cValor3 := 0
   Local cValor4 := 0

   Local cPedido := Space(06)
   
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9

   // Pesquisa dados do Pedido de venda
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C5_DATA1  ,"
   cSql += "       C5_DATA2  ,"
   cSql += "       C5_DATA3  ,"
   cSql += "       C5_DATA4  ,"
   cSql += "       C5_PARC1  ,"
   cSql += "       C5_PARC2  ,"
   cSql += "       C5_PARC3  ,"
   cSql += "       C5_PARC4   "
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_NUM       = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND C5_FILIAL    = '" + Alltrim(_Filial) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   cPedido := _Pedido

   cData1  := Ctod(Substr(T_PEDIDO->C5_DATA1,07,02) + "/" + Substr(T_PEDIDO->C5_DATA1,05,02) + "/" + Substr(T_PEDIDO->C5_DATA1,01,04))
   cData2  := Ctod(Substr(T_PEDIDO->C5_DATA2,07,02) + "/" + Substr(T_PEDIDO->C5_DATA2,05,02) + "/" + Substr(T_PEDIDO->C5_DATA2,01,04))
   cData3  := Ctod(Substr(T_PEDIDO->C5_DATA3,07,02) + "/" + Substr(T_PEDIDO->C5_DATA3,05,02) + "/" + Substr(T_PEDIDO->C5_DATA3,01,04))
   cData4  := Ctod(Substr(T_PEDIDO->C5_DATA4,07,02) + "/" + Substr(T_PEDIDO->C5_DATA4,05,02) + "/" + Substr(T_PEDIDO->C5_DATA4,01,04))

   cValor1 := T_PEDIDO->C5_PARC1
   cValor2 := T_PEDIDO->C5_PARC2
   cValor3 := T_PEDIDO->C5_PARC3
   cValor4 := T_PEDIDO->C5_PARC4

   DEFINE MSDIALOG oDlg    TITLE "Alteração de Vencimento - Condição Pagtº Tipo 9" FROM C(178),C(181) TO C(445),C(615) PIXEL Style DS_MODALFRAME

   oDlg:lEscClose := .F.

   @ C(006),C(006) Say "Pedido de Venda" Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(020),C(007) Say "Atenção! Este Pedido de Venda possui a condição de pagamento - Negociável Valor" Size C(204),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(007) Say "porém, um ou mais vencimentos estão inconsistentes com a data de hoje." Size C(205),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(007) Say "Favor informar vencimentos válidos." Size C(203),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(068) Say "Vencimentos"   Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(120) Say "Valor Parcela" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(051) MsGet oGet9 Var cPedido When lAberto Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(060),C(063) MsGet oGet1 Var cData1  When cData1 < Date() Size C(035),C(009) COLOR CLR_BLACK Picture "@d"         PIXEL OF oDlg
   @ C(060),C(109) MsGet oGet5 Var cValor1 When lAberto         Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlg

   @ C(073),C(063) MsGet oGet2 Var cData2  When cData2 < Date() Size C(035),C(009) COLOR CLR_BLACK Picture "@d"         PIXEL OF oDlg
   @ C(073),C(109) MsGet oGet6 Var cValor2 When lAberto         Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlg

   @ C(086),C(063) MsGet oGet3 Var cData3  When cData3 < Date() Size C(035),C(009) COLOR CLR_BLACK Picture "@d"         PIXEL OF oDlg
   @ C(086),C(109) MsGet oGet7 Var cValor3 When lAberto         Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlg

   @ C(099),C(063) MsGet oGet4 Var cData4  When cData4 < Date() Size C(035),C(009) COLOR CLR_BLACK Picture "@d"         PIXEL OF oDlg
   @ C(099),C(109) MsGet oGet8 Var cValor4 When lAberto         Size C(041),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlg

   @ C(115),C(107) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( GravaVcto(_Pedido, _Filial, cData1, cData2, cData3, cData4, cValor1, cValor2, cValor3, cValor4) )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função do botão Confirmar
Static Function GravaVcto(_Pedido, _Filial, cData1, cData2, cData3, cData4, _Valor1, _Valor2, _Valor3, _Valor4)

   // Consiste a datas antes da gravação
   If _Valor1 <> 0
      If cData1 < Date()
         MsgAlert("Data de vencimento 1 invalida.")
         Return .T.
      Endif
   Endif
      
   If _Valor2 <> 0
      If cData2 < Date()
         MsgAlert("Data de vencimento 2 invalida.")
         Return .T.
      Endif
   Endif   
   
   If _Valor3 <> 0
      If cData3 < Date()
         MsgAlert("Data de vencimento 3 invalida.")
         Return .T.
      Endif
   Endif   

   If _Valor4 <> 0
      If cData4 < Date()
         MsgAlert("Data de vencimento 4 invalida.")
         Return .T.
      Endif
   Endif
   
   // Grava os novos vencimentos na tabela SC5 - Cabeçalho do Pedido de Venda
   DbSelectArea("SC5")
   DbSetOrder(1)
   If DbSeek( _Filial + _Pedido)
      Reclock("SC5",.f.)
      C5_DATA1 := cData1
      C5_DATA2 := cData2
      C5_DATA3 := cData3
      C5_DATA4 := cData4
      Msunlock()      
   Endif

   oDlg:End()

Return .T.

// Função que realiza várias consistências sobre o documebnto que será gerado
Static Function ConsRetorno(_Pedido, _Filial)

   Local cSql      := ""
   Local cMarca    := ""
   Local nContar   := 0
   Local nVerifica := 0
   Local cAbre     := .F.

   // Captura a marca dos pedidos
   cMarca := PARAMIXB[1]
   
   // Pesquisa os Pedidos que estão marcados para faturamento
   If Select("T_MARCADOS") > 0
      T_MARCADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C9_OK     ,"
   cSql += "       A.C9_FILIAL ,"
   cSql += "       A.C9_PEDIDO ,"
   cSql += "       B.C5_CONDPAG,"
   cSql += "       C.E4_TIPO   ,"
   cSql += "       B.C5_DATA1  ,"
   cSql += "       B.C5_DATA2  ,"
   cSql += "       B.C5_DATA3  ,"
   cSql += "       B.C5_DATA4  ,"
   cSql += "       B.C5_PARC1  ,"
   cSql += "       B.C5_PARC2  ,"
   cSql += "       B.C5_PARC3  ,"
   cSql += "       B.C5_PARC4   "
   cSql += "  FROM " + RetSqlName("SC9") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B, "
   cSql += "       " + RetSqlName("SE4") + " C  "   
   cSql += " WHERE A.C9_OK        = '" + Alltrim(cMarca) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.C9_FILIAL    = B.C5_FILIAL"
   cSql += "   AND A.C9_PEDIDO    = B.C5_NUM   "
   cSql += "   AND B.C5_CONDPAG   = C.E4_CODIGO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MARCADOS", .T., .T. )
   
   If T_MARCADOS->( EOF() )
      Return .T.
   Endif

   // Verifica se algum dos pedidos de venda selecionados são pedidos de locação
   T_MARCADOS->( DbGoTop() )

   WHILE !T_MARCADOS->( EOF() )

      // Verifica se o pedido selecionado é um pedido vinculado ao módulo de contrato.
      // Se for, verifica se o contrato já está no status 05 - Em Vigência
      If Select("T_CONTRATO") > 0
         T_CONTRATO->( dbCloseArea() )
      EndIf

      cSql := "SELECT A.CK_FILIAL ,"
      cSql += "       A.CK_NUMPV  ,"
      cSql += "       A.CK_PROPOST,"
      cSql += "       B.ADY_PROPOS,"
      cSql += "       B.ADY_OPORTU,"
      cSql += "       C.AD1_ZCONTR,"
      cSql += "       D.CN9_SITUAC "
      cSql += "  FROM " + RetSqlName("SCK") + " A, "
      cSql += "       " + RetSqlName("ADY") + " B, "
      cSql += "       " + RetSqlName("AD1") + " C, "
      cSql += "       " + RetSqlName("CN9") + " D  "
      cSql += " WHERE A.CK_FILIAL   = '" + Alltrim(T_MARCADOS->C9_FILIAL) + "'"
      cSql += "   AND A.CK_NUMPV    = '" + Alltrim(T_MARCADOS->C9_PEDIDO) + "'"
      cSql += "   AND A.D_E_L_E_T_  = ''          "
      cSql += "   AND B.ADY_FILIAL  = A.CK_FILIAL "
      cSql += "   AND B.ADY_PROPOS  = A.CK_PROPOST"
      cSql += "   AND B.D_E_L_E_T_  = ''          "
      cSql += "   AND C.AD1_FILIAL  = B.ADY_FILIAL"
      cSql += "   AND C.AD1_NROPOR  = B.ADY_OPORTU"
      cSql += "   AND C.D_E_L_E_T_  = ''          "
      cSql += "   AND C.AD1_ZCONTR <> ''          "
      cSql += "   AND D.CN9_FILIAL  = C.AD1_FILIAL"
      cSql += "   AND D.CN9_NUMERO  = C.AD1_ZCONTR"
      cSql += "   AND D.D_E_L_E_T_  = ''          "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATO", .T., .T. )

      If T_CONTRATO->( EOF() )
      Else
         If T_CONTRATO->CN9_SITUAC <> "05"
            MsgAlert("Atenção! O pedido de venda nº " + Alltrim(T_MARCADOS->C9_PEDIDO) + " refere-se a um pedido de venda vinculado a um contrato de locação, porém, este contrato ainda está aguardando liberação do departamento financeiro. Procedimento de separação não permitido. Aguarde liberação do financeiro.")
            Return(.F.)
         Endif
      Endif
      
      T_MARCADOS->( DbSkip() )
   
   ENDDO   

   // Verifica se a condição de pagamento dos pedidos é Condição Negociável Valor
   T_MARCADOS->( DbGoTop() )

   WHILE !T_MARCADOS->( EOF() )

      cAbre := .F.

      If Alltrim(T_MARCADOS->E4_TIPO) == "9"
         
         If CTOD(T_MARCADOS->C5_DATA1) < DATE() .OR. ;
            CTOD(T_MARCADOS->C5_DATA2) < DATE() .OR. ;
            CTOD(T_MARCADOS->C5_DATA3) < DATE() .OR. ;
            CTOD(T_MARCADOS->C5_DATA4) < DATE()
            ALTVENCI(T_MARCADOS->C9_PEDIDO, T_MARCADOS->C9_FILIAL)
         Endif
         
      Endif
      
      T_MARCADOS->( DbSkip() )
   
   ENDDO   

Return .T.

// Função que abre janela para visualizar observações internas antes da prepração dos doscumentos de saídas
Static Function OlhaInternas()

   Local cSql       := ""
   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1
   Local xMarca     := ""

   Private cInterna := ""
   Private oMemo2

   Private aSelecionados := {}

   // Captura a marca dos pedidos
   xMarca := PARAMIXB[1]
   
   // Pesquisa os Pedidos que estão marcados para faturamento
   If Select("T_OBSERVACAO") > 0
      T_OBSERVACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C9_FILIAL,"
   cSql += "   	   A.C9_PEDIDO "       
   cSql += "  FROM " + RetSqlName("SC9") + " A "
   cSql += " WHERE RTRIM(LTRIM(A.C9_OK)) = '" + Alltrim(xMarca) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.C9_NFISCAL   = ''"   
   cSql += " GROUP BY A.C9_FILIAL, A.C9_PEDIDO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVACAO", .T., .T. )
   
   If T_OBSERVACAO->( EOF() )
      lContinuar := .F.
      Return(.T.)
   Endif

   T_OBSERVACAO->( DbGoTop() )
   
   WHILE !T_OBSERVACAO->( EOF() )
   
      aAdd( aSelecionados, { T_OBSERVACAO->C9_PEDIDO, T_OBSERVACAO->C9_FILIAL })
      
      T_OBSERVACAO->( DbSkip() )
      
   ENDDO

   If Len(aSelecionados) == 0
      aAdd( aSelecionados, { "", "" } )
   Else
      MOSTRAOBS(aSelecionados[01,01], aSelecionados[01,02], 0)      
   Endif

   Private oDlgOlha

   DEFINE MSDIALOG oDlgOlha TITLE "Preparação de Documento de Saída" FROM C(178),C(181) TO C(563),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp"                               Size C(138),C(030)                 PIXEL NOBORDER OF oDlgOlha

   @ C(035),C(003) GET oMemo1 Var cMemo1 MEMO                                Size C(384),C(001)                 PIXEL OF oDlgOlha

   @ C(039),C(005) Say "Pedidos Selecionados"                                Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha
   @ C(038),C(063) Say "Observações internas do pedido de venda selecionado" Size C(134),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha

   @ C(046),C(063) GET oMemo2 Var cInterna MEMO                              Size C(325),C(127)                 PIXEL OF oDlgOlha When lChumba

   @ C(176),C(312) Button "Prep.Doc"                                         Size C(037),C(012)                 PIXEL OF oDlgOlha ACTION(FechaOlha(1))
   @ C(176),C(351) Button "Voltar"                                           Size C(037),C(012)                 PIXEL OF oDlgOlha ACTION(FechaOlha(2))

   oSelecionados := TCBrowse():New( 050 , 005, 072, 170,,{'Pedidos' + Space(50), 'Filial'}, {20,50,50,50},oDlgOlha,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oSelecionados:SetArray(aSelecionados) 
   
   oSelecionados:bLine := {||{ aSelecionados[oSelecionados:nAt,01], aSelecionados[oSelecionados:nAt,02]}}

   oSelecionados:bLDblClick := {|| MOSTRAOBS(aSelecionados[oSelecionados:nAt,01], aSelecionados[oSelecionados:nAt,02], 1) } 

   ACTIVATE MSDIALOG oDlgOlha CENTERED 

Return(.T.)

// Função que mostra a observação interna do pedido de venda selecionados
Static Function MOSTRAOBS(_Pedido, _Filial, _Onde)

   Local cSql := ""

   // Pesquisa os Pedidos que estão marcados para faturamento
   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), B.C5_OBSI)) AS INTERNA"
   cSql += "  FROM " + RetSqlName("SC5") + " B "
   cSql += " WHERE B.C5_FILIAL  = '" + Alltrim(_Filial) + "'"
   cSql += "   AND B.C5_NUM     = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND B.D_E_L_E_T_ = ''" 
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )
  
   If T_NOTA->( EOF() )
      cInterna := ""
   Else
      cInterna := T_NOTA->INTERNA
   Endif
   
   If _Onde == 1
      oMemo2:Refresh()
   Endif   

Return(.T.)

// Função que fecha a janela de cisualização das observações internas dos pedidos de venda selecionados
Static Function FechaOlha(_BotaoAcionado)

   If _BotaoAcionado == 1
      lContinuar := .T.
   Else
      lContinuar := .F.
   Endif

   oDlgOlha:End() 
   
Return(.T.)      

*/


