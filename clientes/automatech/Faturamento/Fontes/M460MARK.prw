#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    
#include "RWMAKE.CH"
#include "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M460MARK.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 20/03/2012                                                          ##
// Objetivo..: Em 27/01/2016,foi verificado a necessidade de incluir consist�ncias ##
//             antes de preparar o documento de sa�da em raz�o de muitos problemas ##
//             que est�o sendo encontrados no faturamento das notas fiacais. O ob- ##
//             jetivo destas consist�ncias � antecipar  poss�veis  problemas antes ##
//             do envio do documento ao Sefaz ou Prefeituras.                      ##
//             A medida que forem surgindo novas necessidades, estas ser�o inclu�- ##
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
//   // Verifica se existem produtos de pedidos de venda marcados que n�o possuem saldo. ##
//   // Se n�o houve saldo para um dos produtos do pedido de venda, n�o permite elaborar ##
//   // o Documento de Sa�da. D� mensagem ao usu�rio atrav�s de verifica��o dos pedidos/ ##
//   // produtos em tela admin	de visualiza��o.                                       ##
//   // ###################################################################################
//   cMarca := PARAMIXB[1]
//   
//   // #######################################################################################
//   // Pesquisa os Produtos dos Pedidos de Venda para verifica��o de saldo para atendimento ##
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
//      DEFINE MSDIALOG oDlgSaldos TITLE "Inconsist�ncia de Saldos de Produtos para Faturamento" FROM C(178),C(181) TO C(613),C(759) PIXEL Style DS_MODALFRAME
//
//      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(022) PIXEL NOBORDER OF oDlgSaldos
//
//      @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(283),C(001) PIXEL OF oDlgSaldos
//
//      @ C(033),C(005) Say "ATEN��O!"                                                                                                               Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgSaldos
//      @ C(042),C(005) Say "O(s) produto(s) do(s) pedido(s) de venda abaixo n�o possuem saldo suficiente para realizar seu faturamento. Verifique!" Size C(280),C(008) COLOR CLR_BLACK PIXEL OF oDlgSaldos
//
//      @ C(201),C(106) Button "Ver Saldo" Size C(037),C(012) PIXEL OF oDlgSaldos ACTION( kSaldoProd(aSaldos[oSaldos:nAt,03]) )
//      @ C(201),C(145) Button "Retornar"  Size C(037),C(012) PIXEL OF oDlgSaldos ACTION( oDlgSaldos:End() )
//
//      oSaldos := TCBrowse():New( 67 , 005,362, 185,,{'N� PV'                   ,; // 01 
//                                                     'Item'                    ,; // 02
//                                                     'C�digo Produto'          ,; // 03
//                                                     'Descri��o dos Produtos'  ,; // 04
//                                                     'Quant� a Faturar'        ,; // 05
//                                                     'Saldo Dispon�vel'       },; // 06
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
   // Envia para a fun��o que permite o usu�rio visualizar as observa��es internas antes da prepara��o do documento de sa�da ##
   // #########################################################################################################################
   OlhaInternas()

   If lContinuar == .F.
      Return(.F.)
   Endif

   // #############################################################################################################
   // Chamada da fun��o tempor�ria do Paulo e do Harald para verifica��o de CFOP dos produtos do pedido de venda ##
   // #############################################################################################################
   VerCFOPTemp()

   If lVaiAdiante == .F.
      Return(.F.)
   Endif

   // ##################################################################
   // Carrega os par�metros de Consist�ncia para o Documento de Sa�da ##
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
   // Verifica se realiza a consist�ncia dos dados do documento de sa�da ##
   // #####################################################################
   If cCon00 == "0"
      Return(.T.)
   Endif   

   // ###############################################################################
   // Realiza a consist�ncias de dados antes da prepara��o dos documentos de sa�da ##
   // ###############################################################################
   cMarca := PARAMIXB[1]
   
   // ##########################################################
   // Pesquisa os Pedidos que est�o marcados para faturamento ##
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
      // Verifica se o pedido selecionado � um pedido de venda vinculado a contrato de loca��o ##
      // ########################################################################################
      If cCon02 == "1"
         If U_AUTOM341(1, T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
            Return(.F.)
         Endif
      Endif   

      // ##################################################################################################################
      // Verifica se todos os n�s de s�ries dos produtos foram informado em caso de produtos com controle de n� de s�rie ##
      // ##################################################################################################################
      If cCon03 == "1"
         If U_AUTOM341(5, T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
            Return(.F.)
         Endif
      Endif   
      
      // ########################################################################################
      // Verifica se pedido de venda � de Caxias do Sul/RS e se tem servi�o no pedido de venda ##
      // ########################################################################################
      If cCon04 == "1"
         If U_AUTOM341(6, T_MARCADOS->C9_FILIAL + "|" + T_MARCADOS->C9_PEDIDO + "|") == .F.
            Return(.F.)
         Endif
      Endif   

      // ##################################################################
      // Verifica a classifica��o fiscal dos produtos do pedido de venda ##
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
// Fun��o que abre janela para visualizar observa��es internas antes da prepra��o dos doscumentos de sa�das ##
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
   // Pesquisa os Pedidos que est�o marcados para faturamento ##
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

   DEFINE MSDIALOG oDlgOlha TITLE "Prepara��o de Documento de Sa�da" FROM C(178),C(181) TO C(563),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp"                               Size C(138),C(030)                 PIXEL NOBORDER OF oDlgOlha

   @ C(035),C(003) GET oMemo1 Var cMemo1 MEMO                                Size C(384),C(001)                 PIXEL OF oDlgOlha

   @ C(039),C(005) Say "Pedidos Selecionados"                                Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha
   @ C(038),C(063) Say "Observa��es internas do pedido de venda selecionado" Size C(134),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha

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
// Fun��o que mostra a observa��o interna do pedido de venda selecionados ##
// #########################################################################
Static Function MOSTRAOBS(_Pedido, _Filial, _Onde)

   Local cSql := ""

   // Pesquisa os Pedidos que est�o marcados para faturamento
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
// Fun��o que fecha a janela de visualiza��o das observa��es internas dos pedidos de venda selecionados ##
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
// Fun��o tempor�ria inclu�da em 19/10/2016 para verifica��o de CFOP de produtos ##
// ################################################################################
Static Function VerCFOPTemp()

   Local cSql   := ""
   Local cmarca := ""

   lVaiAdiante == .T.

   // ###############################################################################
   // Realiza a consist�ncias de dados antes da prepara��o dos documentos de sa�da ##
   // ###############################################################################
   cMarca := PARAMIXB[1]

   // ##########################################################
   // Pesquisa os Pedidos que est�o marcados para faturamento ##
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
// Fun��o que pesquisa o saldo do produto selecionado no grid ##
// #############################################################
Static Function kSaldoProd(_Produto)

   If Empty(Alltrim(_Produto))
      MsgAlert("Produto a ser pesquisado n�o selecionado.")
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

   // Envia para a fun��o que permite o usu�rio visualizar as observa��es internas antes da prepara��o do documento de sa�da
   OlhaInternas()

   If lContinuar == .F.
      Return(.F.)
   Endif













   // Carrega os par�metros de Consist�ncia
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

   // Veridica se realiza a consist�ncia dos dados
   If cCon00 == "0"
      Return(.T.)
   Endif   

   // Captura a marca dos pedidos
   cMarca := PARAMIXB[1]
   
   // Pesquisa os Pedidos que est�o marcados para faturamento
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

   // Verifica se algum dos pedidos de venda selecionados s�o pedidos de loca��o
   If cCon02 == "1"
 
      T_MARCADOS->( DbGoTop() )

      WHILE !T_MARCADOS->( EOF() )

         // Verifica se o pedido selecionado � um pedido vinculado ao m�dulo de contrato.
         // Se for, verifica se o contrato j� est� no status 05 - Em Vig�ncia
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
                              "Pedido de venda refere-se a um pedido de venda vinculado a um contrato de loca��o, por�m, este contrato ainda est� aguardando libera��o do departamento financeiro. Aguarde libera��o do financeiro." ,;
                              "1", ;
                              "REPORTAR: Entre em conttao com o financeiro para verificar a situa��o deste pedido."})
            Endif
         Endif
      
         T_MARCADOS->( DbSkip() )
   
      ENDDO   
      
   Endif   

   // --------------------------------------------------------------------------- //
   // Verifica se a condi��o de pagamento dos pedidos � Condi��o Negoci�vel Valor //
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
   // Consiste dados para prepara��o do documento de sa�da. // 
   // ----------------------------------------------------- //
   T_MARCADOS->( DbGoTop() )

   WHILE !T_MARCADOS->( EOF() )

      // Verifica o Grupo Tribut�rio do Cliente
      If cCon03 == "1"

         If POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_GRPTRIB") == "002"

            If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_INSCR")))
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "Grupo Tribut�rio do cliente est� configurado como IE ATIVA por�m, a IE n�o foi informada em seu cadastro.",;
                              "1" ,;
                              "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})
            Endif

            If Substr(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_INSCR")),01,04) == "ISEN" 
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "Grupo Tribut�rio do cliente est� configurado como IE ATIVA por�m, a IE est� inconsistente em seu cadastro.",;
                              "1" ,;
                              "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
            Endif

         Else

            If Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_INSCR")) <> "ISENTO"
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "Grupo Tribut�rio do cliente est� configurado como IE INATIVA por�m, a IE est� inconsistente em seu cadastro." ,;
                              "1",;
                              "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
            Endif

         Endif
         
      Endif   

      // Verifica se o Endere�o do Cliente foi informado
      If cCon04 == "1"
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_END")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "Cliente sem informa��o do endere�o em seu cadastro." ,;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif
      
         // Verifica se no Endere�o existe pelo menos um caracter = a d�gito (Num�rico)
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
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "Endere�o do cliente deve conter pelo menu um caracter Num�rico." ,;
                           "1",;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         // Verifica se no Endere�o do Cliente consta uma v�rgula
         If U_P_OCCURS(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_END"),",",1) == 0
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "Endere�o do cliente sem separador ( , - V�rgula ) entre o endere�o e o n� do logradouro." ,;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

      Endif   

      // Verifica se o CEP do Endere�o
      If cCon05 == "1"
         If Len(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_CEP"))) <> 8
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "CEP do endere�o � inv�lido." ,;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         If POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_CEP") == "00000000"
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "CEP do endere�o � inv�lido.",;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_CEP")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "CEP do endere�o n�o informado.",;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif
   
      Endif

      // Verifica se o DDD do telefone do cliente
      If cCon06 == "1"
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")  + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_DDD")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "DDD do telefone do cliente inv�lido.",;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         // Verifica se o Telefone do cliente
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")  + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_TEL")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "Telefone do cliente � inv�lido.",;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

      Endif
   
      // Verifica o e-mail do cliente
      If cCon07 == "1"
         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL")))
            aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                           "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                           "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                           "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "E-mail do cliente inexistente.",;
                           "1" ,;
                           "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
         Endif

         // Verifica se o e-mail � v�lido
         If U_P_OCCURS(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL"),";",1) == 0
            If !ISEMAIL(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL")))
               aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                              "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                              "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                              "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "E-mail do Cliente � inv�lido.",;
                              "1" ,;
                              "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
            Endif
         
         Else
      
            __nEmail := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_EMAIL")) + ";"
        
            For nContar = 1 to U_P_OCCURS(__nEmail,";",1)
    
                __email := U_P_CORTA(  __nEmail, ";", ncontar)
         
                If !ISEMAIL(Alltrim(__email))
                   aAdd( aErros, {"FILIAL: "         + T_MARCADOS->C9_FILIAL ,;
                                  "N� PED.VENDA: "   + T_MARCADOS->C9_PEDIDO ,;
                                  "CLIENTE: "        + T_MARCADOS->C5_CLIENTE,;
                                  "LOJA: "           + T_MARCADOS->C5_LOJACLI,;
                                  "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_MARCADOS->C5_CLIENTE + T_MARCADOS->C5_LOJACLI, "A1_NOME")),;
                                  "INCONSIST�NCIA: " + "E-mail do Cliente � inv�lido.",;
                                  "1" ,;
                                  "SOLU��O: Solicite ao vendedor para corrir o cadatro do cliente."})                           
                Endif
             
            Next nContar    
      
         Endif      
         
      Endif   

      // Pesquisa os produtos para an�lise
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
      
            // Se produto do tipo MO = M�o - de - Obra, desconsidera a consist�ncia
            If Alltrim(T_PRODUTOS->B1_TIPO) == "MO"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif

            // Verifica se produto tem a informa��o do NCM
            If Empty(Alltrim(T_PRODUTOS->B1_POSIPI))
               lTemProblema := .T.
               Exit
            Endif
         
            // Verifica se a informa��o do NCM � menor que 8 d�gitos
            If Len(T_PRODUTOS->B1_POSIPI) < 8
               lTemProblema := .T.
               Exit
            Endif
            
            // Verifica se a informa��o do NCM � igual a 00000000
            If Alltrim(T_PRODUTOS->B1_POSIPI) == "00000000"
               lTemProblema := .T.
               Exit
            Endif
         
            // Verifica se a informa��o do NCM � igual a 99999999
            If Alltrim(T_PRODUTOS->B1_POSIPI) == "99999999"
               lTemProblema := .T.
               Exit
            Endif

            T_PRODUTOS->( DbSkip() )
         
         ENDDO
         
         If lTemProblema == .T.           

            aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                           "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                           "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                           "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                           "INCONSIST�NCIA: " + "Pededo de Venda possui produtos com NCM inv�lidos. Redefina.",;
                           "2" ,;
                           "SOLU��O: Entre em contato com Andr�ia Forte informando esta mensagem para que ela possa corrir o NCM deste produto."})
         Endif
         
      Endif   

      // Verifica os produtos do pedido de venda quais s�o os produtos que s�o controlados por n� de s�rie.
      // Se existir produtos com controle de n� de s�rie, verifica na Tabela SDC de os lan�amentos est�o coerentes.
      If cCon09 == "1"
         lTemProblema := .F.
         aSeries      := {}

         T_PRODUTOS->( DbGoTop() )
      
         WHILE !T_PRODUTOS->( EOF() )
      
            If Alltrim(T_PRODUTOS->B1_LOCALIZ) <> "S"
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif
           
            // Verifica a tabela SDB se quantidade de n� de s�ries est� consistente
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
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " sem informa��o do(s) N�(s) de S�rie(s).",;
                              "3" ,;
                              "SOLU��O: Entre em contato com a Log�stica informando esta mensagem para a corre��o."})
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif

            // Verifica se quantidade de n�s de s�ries confere com a quantidade total do produto do pedido de venda
            T_NUMSERIE->( DbGoTop() )
         
            Count To nLancamentos

            If nLancamentos <> T_PRODUTOS->C6_QTDVEN
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "Qtd de N�(s) de S�rie(s) do produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " n�o conferem com a qtd total do pedido de venda.",;
                              "3" ,;
                              "SOLU��O: Entre em contato com a Log�stica informando esta mensagem para a corre��o."})
            Endif

            // Verifica se todos os n�s de s�ries foram informados
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
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "Qtd de N�(s) de S�rie(s) do produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " n�o conferem com a qtd total do pedido de venda.",;
                              "3" ,;
                              "SOLU��O: Entre em contato com a Log�stica informando esta mensagem para a corre��o."})
            Endif

            T_PRODUTOS->( DbSkip() )
         
         ENDDO
         
      Endif   
         
      // Verifica se a filial do pedido de venda � 02 - Caxias do Sul.
      // Sendo 02 - Caxias do Sul, verifica se os produtos do pedido s�o de servi�o (Unidade MO - M�p-de-Obra).
      // Se forem, verifica se os mesmos est�o cadastrados no Indicador de Produtos e se est�o, se os dados est�o corretos.
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
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " n�o cadastrado no Cadastro de Indicador de Produto.",;
                              "4" ,;
                              "SOLU��O: Entre em contato com a Controladoria informando esta mensagem para a corre��o."})
            Endif

            // Verifica se o campo BZ_CODISS est� preenchido
            If Empty(Alltrim(T_INDICADOR->BZ_CODISS))
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "C�digo do ISS do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " n�o informado no Cadastrado de Indicador de Produto.",;
                              "4" ,;
                              "SOLU��O: Entre em contato com a Controladoria informando esta mensagem para a corre��o."})
            Endif

            // Verifica se existe (.) na informa��o o campo BZ_CODISS
            If U_P_OCCURS(T_INDICADOR->BZ_CODISS, ".", 1) <> 0
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "C�digo do ISS do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " n�o pode ter informa��o de PONTO (.) em seu conte�do.",;
                              "4" ,;
                              "SOLU��O: Entre em contato com a Controladoria informando esta mensagem para a corre��o."})
            Endif

            // Verifica se o campo BZ_TRIBMUN est� preenchido
            If Empty(Alltrim(T_INDICADOR->BZ_TRIBMUN))
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "C�digo Tribut�rio do Munic�pio do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " n�o informado no Cadastrado de Indicador de Produto.",;
                              "4" ,;
                              "SOLU��O: Entre em contato com a Controladoria informando esta mensagem para a corre��o."})
            Endif

            // Verifica se o campo BZ_TRIBMUN � <> de 131
            If Alltrim(T_INDICADOR->BZ_TRIBMUN) <> "131"
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "C�digo Tribut�rio do Munic�pio do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " � inconsistente para Caxias do Sul. Correto 131.",;
                              "4" ,;
                              "SOLU��O: Entre em contato com a Controladoria informando esta mensagem para a corre��o."})
            Endif

            // Verifica se o campo BZ_CNAE
            If Empty(Alltrim(T_INDICADOR->BZ_CNAE))
               aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                              "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                              "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                              "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                              "INCONSIST�NCIA: " + "C�digo CNAE do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " n�o informado no Cadastro de Indicador de Produto.",;
                              "4" ,;
                              "SOLU��O: Entre em contato com a Controladoria informando esta mensagem para a corre��o."})
            Endif

            T_PRODUTOS->( DbSkip() )
         
         ENDDO
         
      Endif   

      // ----------------------------------------------------------------------------------------------------------------------------------- //
      // Consiste CFOP dos produtos dopedido de venda                                                                                        //
      // Regra:                                                                                                                              //
      // 1�) Pedido de Venda deve ser do tipo N - Normal                                                                                     //
      // 2�) O TES do produto lido deve gerar duplicata (F4_DUPLIC = S)                                                                      //
      // 3�) Se o Grupo Tribut�rio do produto (B1_GRTRIB) for igual a 001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016 e 018, //
      //     CFOP n�o pode ser os CFOP's 5102 e 6102.                                                                                        //         
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
                                 "N� PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                                 "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                                 "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                                 "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                                 "INCONSIST�NCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - CFOP de Mercadoria Tributada com produto com grupo Tribut�rio de Substitui��o Tribut�ria.",;
                                 "4" ,;
                                 "SOLU��O: Entre em contato com a Controladoria informando esta mensagem para a corre��o."})
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
      
   // Prepara a vari�vel cString para display do(s) erro(s) encontrado(s)
   vErros := ""
   For nContar = 1 to Len(aErros)
       vErros += aErros[nContar,01] + chr(13) + chr(10) + ;
                 aErros[nContar,02] + chr(13) + chr(10) + ;
                 aErros[nContar,03] + chr(13) + chr(10) + ;
                 aErros[nContar,04] + chr(13) + chr(10) + ;                                    
                 aErros[nContar,05] + chr(13) + chr(10) + ;
                 aErros[nContar,06] + chr(13) + chr(10) + chr(13) + chr(10)
   Next nContar

   // Desenha a tela para visualiza��o do(s) erro(s) encontrado(s) no pedido de venda
   DEFINE MSDIALOG oDlgErro TITLE "Valida��o de Emiss�o de Documento Fiscal" FROM C(178),C(181) TO C(635),C(967) PIXEL

   @ C(005),C(003) Jpeg FILE "logoautoma.bmp" Size C(137),C(029) PIXEL NOBORDER OF oDlgErro

   @ C(039),C(003) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlgErro
   @ C(052),C(003) GET oMemo3 Var cMemo3 MEMO Size C(384),C(001) PIXEL OF oDlgErro

   @ C(027),C(145) Say "Inconsist�ncias encontradas no Pedido de Venda antes da Prepara��o do Documento de Sa�da"    Size C(229),C(008) COLOR CLR_BLACK PIXEL OF oDlgErro
   @ C(042),C(005) Say "DOCUMENTO DE SA�DA NAO SER� GERADO ANTES QUE AS INCONSIST�NCIA(S) ABAIXO SEJAM RESOLVIDA(S)" Size C(293),C(008) COLOR CLR_RED   PIXEL OF oDlgErro

   @ C(054),C(005) Say "Inconsist�ncias Encontradas" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgErro

   @ C(064),C(005) GET oMemo4 Var vErros MEMO Size C(383),C(144) PIXEL OF oDlgErro

   @ C(212),C(351) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgErro ACTION( RespIncon(aErros) )

   ACTIVATE MSDIALOG oDlgErro CENTERED 

Return(.F.)

// Fun��o que envia e-mail ao respons�vel da inconsist�ncia
Static Function RespIncon(aMensagens)

   Local nContar   := 0
   Local cEmail    := ""
   Local cEndereco := ""
   
   For nContar = 1 to Len(aMensagens)

       // Pesquisa o e-mail do respons�vel a receber o e-mail
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
          
          // Andr�ia Fortes
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
       cEmail := "Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += "O Sistema Protheus encontrou uma inconsist�ncia em seu Pedido de Venda no momento de seu faturamento." + chr(13) + chr(10) 
       cEmail += "Favor avaliar e sanar a inconsist�ncia abaixo para que o Pedido de Venda possa ser faturado."          + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += aMensagens[nContar,01] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,02] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,03] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,04] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,05] + chr(13) + chr(10)
       cEmail += aMensagens[nContar,06] + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += "Att." + chr(13) + chr(10) + chr(13) + chr(10)
       cEmail += "Departamento de Faturamento"
         
       // Envia e-mail ao Aprovador
//     U_AUTOMR20(cEmail, Alltrim(cEndereco), "", "Aviso de Inconsist�ncia de Faturamento de Pedido de Venda" )

   Next nContar

   oDlgErro:End() 
   
Return(.F.)   

// Fun��o que abre a janela para digita��o dos novos vencimentos
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

   DEFINE MSDIALOG oDlg    TITLE "Altera��o de Vencimento - Condi��o Pagt� Tipo 9" FROM C(178),C(181) TO C(445),C(615) PIXEL Style DS_MODALFRAME

   oDlg:lEscClose := .F.

   @ C(006),C(006) Say "Pedido de Venda" Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(020),C(007) Say "Aten��o! Este Pedido de Venda possui a condi��o de pagamento - Negoci�vel Valor" Size C(204),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(007) Say "por�m, um ou mais vencimentos est�o inconsistentes com a data de hoje." Size C(205),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(007) Say "Favor informar vencimentos v�lidos." Size C(203),C(008) COLOR CLR_BLACK PIXEL OF oDlg
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

// Fun��o do bot�o Confirmar
Static Function GravaVcto(_Pedido, _Filial, cData1, cData2, cData3, cData4, _Valor1, _Valor2, _Valor3, _Valor4)

   // Consiste a datas antes da grava��o
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
   
   // Grava os novos vencimentos na tabela SC5 - Cabe�alho do Pedido de Venda
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

// Fun��o que realiza v�rias consist�ncias sobre o documebnto que ser� gerado
Static Function ConsRetorno(_Pedido, _Filial)

   Local cSql      := ""
   Local cMarca    := ""
   Local nContar   := 0
   Local nVerifica := 0
   Local cAbre     := .F.

   // Captura a marca dos pedidos
   cMarca := PARAMIXB[1]
   
   // Pesquisa os Pedidos que est�o marcados para faturamento
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

   // Verifica se algum dos pedidos de venda selecionados s�o pedidos de loca��o
   T_MARCADOS->( DbGoTop() )

   WHILE !T_MARCADOS->( EOF() )

      // Verifica se o pedido selecionado � um pedido vinculado ao m�dulo de contrato.
      // Se for, verifica se o contrato j� est� no status 05 - Em Vig�ncia
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
            MsgAlert("Aten��o! O pedido de venda n� " + Alltrim(T_MARCADOS->C9_PEDIDO) + " refere-se a um pedido de venda vinculado a um contrato de loca��o, por�m, este contrato ainda est� aguardando libera��o do departamento financeiro. Procedimento de separa��o n�o permitido. Aguarde libera��o do financeiro.")
            Return(.F.)
         Endif
      Endif
      
      T_MARCADOS->( DbSkip() )
   
   ENDDO   

   // Verifica se a condi��o de pagamento dos pedidos � Condi��o Negoci�vel Valor
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

// Fun��o que abre janela para visualizar observa��es internas antes da prepra��o dos doscumentos de sa�das
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
   
   // Pesquisa os Pedidos que est�o marcados para faturamento
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

   DEFINE MSDIALOG oDlgOlha TITLE "Prepara��o de Documento de Sa�da" FROM C(178),C(181) TO C(563),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp"                               Size C(138),C(030)                 PIXEL NOBORDER OF oDlgOlha

   @ C(035),C(003) GET oMemo1 Var cMemo1 MEMO                                Size C(384),C(001)                 PIXEL OF oDlgOlha

   @ C(039),C(005) Say "Pedidos Selecionados"                                Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha
   @ C(038),C(063) Say "Observa��es internas do pedido de venda selecionado" Size C(134),C(008) COLOR CLR_BLACK PIXEL OF oDlgOlha

   @ C(046),C(063) GET oMemo2 Var cInterna MEMO                              Size C(325),C(127)                 PIXEL OF oDlgOlha When lChumba

   @ C(176),C(312) Button "Prep.Doc"                                         Size C(037),C(012)                 PIXEL OF oDlgOlha ACTION(FechaOlha(1))
   @ C(176),C(351) Button "Voltar"                                           Size C(037),C(012)                 PIXEL OF oDlgOlha ACTION(FechaOlha(2))

   oSelecionados := TCBrowse():New( 050 , 005, 072, 170,,{'Pedidos' + Space(50), 'Filial'}, {20,50,50,50},oDlgOlha,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oSelecionados:SetArray(aSelecionados) 
   
   oSelecionados:bLine := {||{ aSelecionados[oSelecionados:nAt,01], aSelecionados[oSelecionados:nAt,02]}}

   oSelecionados:bLDblClick := {|| MOSTRAOBS(aSelecionados[oSelecionados:nAt,01], aSelecionados[oSelecionados:nAt,02], 1) } 

   ACTIVATE MSDIALOG oDlgOlha CENTERED 

Return(.T.)

// Fun��o que mostra a observa��o interna do pedido de venda selecionados
Static Function MOSTRAOBS(_Pedido, _Filial, _Onde)

   Local cSql := ""

   // Pesquisa os Pedidos que est�o marcados para faturamento
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

// Fun��o que fecha a janela de cisualiza��o das observa��es internas dos pedidos de venda selecionados
Static Function FechaOlha(_BotaoAcionado)

   If _BotaoAcionado == 1
      lContinuar := .T.
   Else
      lContinuar := .F.
   Endif

   oDlgOlha:End() 
   
Return(.T.)      

*/


