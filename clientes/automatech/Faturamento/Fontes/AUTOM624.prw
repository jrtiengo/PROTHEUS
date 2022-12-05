#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativa��o
#define SW_SHOW             5 // Mostra na posi��o mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posi��o anterior
#define SW_SHOWDEFAULT      10// Posi��o padr�o da aplica��o
#define SW_FORCEMINIMIZE    11// For�a minimiza��o independente da aplica��o executada
#define SW_MAX              11// Maximizada

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM624.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 05/09/2017                                                          ##
// Objetivo..: Dados Pedido de Venda de Loca��o                                    ##
// ##################################################################################

User Function AUTOM624()

   Local lChumba        := .F.

   Local cMemo1	        := ""
   Local cMemo2 	    := ""

   Local nPosTES        := aScan( aHeader, { |x| x[2] == 'C6_TES    ' } )
   Local nPosCm1        := aScan( aHeader, { |x| x[2] == 'C6_COMIS1 ' } )
   Local nPosCm2        := aScan( aHeader, { |x| x[2] == 'C6_COMIS2 ' } )
   Local lLocacao       := .F.

   Private oMemo1
   Private oMemo2

   Private aVigencia    := {"0 - Seleciona a Vig�ncia", "1 - Dias", "2 - Meses", "3 - Anos", "4 - Indeterminado"}
   Private aMoeda       := {"0 - Selecione a Moeda", "1 - Real", "2 - Dolar"}
   Private aAtendimento := {"0 - Selecione Tipo Atendimento", "1 - ON SITE", "2 - BALC�O"}
   Private aTipocontra  := {"0 - Selecione Tipo Contrato"   , "1 - Tradicional", "2 - Longo Prazo"}
   Private Loc_Pedi     := M->C5_NUM
   Private Loc_clie     := Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_NOME")         
   Private Loc_Cont     := U_P_CORTA(M->C5_ZLOC,"|",8)
   Private cDinicial    := Ctod(U_P_CORTA(M->C5_ZLOC,"|",1))
   Private cDfinal	    := Ctod(U_P_CORTA(M->C5_ZLOC,"|",2))
   Private cVigencia    := INT(VAL(U_P_CORTA(M->C5_ZLOC,"|",4)))
   Private cCondicao    := M->C5_CONDPAG
   Private cNomeCondi   := Posicione("SE4", 1, xFilial("SE4") + M->C5_CONDPAG, "E4_DESCRI")         
   Private cVende01     := M->C5_VEND1
   Private cNomeV01     := Posicione("SA3", 1, xFilial("SA3") + M->C5_VEND1, "A3_NOME")         
   Private cPercV01     := aCols[ 01, nPosCm1   ] 
   Private cVende02     := M->C5_VEND2
   Private cNomeV02     := Posicione("SA3", 1, xFilial("SA3") + M->C5_VEND2, "A3_NOME")         
   Private cPercV02     := aCols[ 01, nPosCm2   ] 
   Private nValTotal    := VAL(U_P_CORTA(M->C5_ZLOC,"|",7))
   Private nContrato    := U_P_CORTA(M->C5_ZLOC,"|",8)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9 
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet16
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private oDlgLoc

   U_AUTOM628("AUTOM624")

   // ##############################################################################
   // Verifica se o pedido de venda � um pedido de Loca��o. Verifica pela TES 728 ##
   // ##############################################################################   
   lLocacao := .F.
   For nContar = 1 to Len(aCols)
       If aCols[nContar, nPosTES] == "728"
          lLocacao := .T.
          Exit
       Endif
   Next nContar
   
   If lLocacao == .F.
      MsgAlert("Pedido de Venda n�o � um Pedido de Loca��o. Verifique!")       
      Return(.T.)
   Endif   

   // #################################
   // Posiciona a Unidade de Loca��o ##
   // #################################
   Do Case 
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "0"
           cComboBx1 := "0 - Seleciona a Vig�ncia"
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "1"
           cComboBx1 := "1 - Dias"
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "2"
           cComboBx1 := "2 - Meses"
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "3"
           cComboBx1 := "3 - Anos"
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "4"
           cComboBx1 := "4 - Indeterminado"
      Otherwise
           cComboBx1 := "0 - Seleciona a Vig�ncia"
   EndCase        

   // ####################
   // Posiciona a Moeda ##
   // ####################
   Do Case
      Case M->C5_MOEDA == 1
           cComboBx2 := "1 - Real"
      Case M->C5_MOEDA == 2
           cComboBx2 := "2 - Dolar"
      Otherwise
           cComboBx2 := "0 - Selecione a Moeda"
   EndCase
              
   // ##########################
   // Posiciona o Atendimento ##
   // ##########################
   Do Case
      Case U_P_CORTA(M->C5_ZLOC, "|", 5) == "0"
           cComboBx3 := "0 - Selecione Tipo Atendimento"
      Case U_P_CORTA(M->C5_ZLOC, "|", 5) == "1"
           cComboBx3 := "1 - ON SITE"
      Case U_P_CORTA(M->C5_ZLOC, "|", 5) == "2"
           cComboBx3 := "2 - BALC�O"
      Otherwise
           cComboBx3 := "0 - Selecione Tipo Atendimento"
   EndCase                         
           
   // ###############################
   // Posiciona o Tipo de Contrato ##
   // ###############################
   Do Case
      Case U_P_CORTA(M->C5_ZLOC, "|", 6) == "0"
           cComboBx4 := "0 - Selecione Tipo Contrato"
      Case U_P_CORTA(M->C5_ZLOC, "|", 6) == "1"
           cComboBx4 := "1 - Tradicional"
      Case U_P_CORTA(M->C5_ZLOC, "|", 6) == "2"
           cComboBx4 := "2 - Longo Prazo"
      Otherwise
           cComboBx4 := "0 - Selecione Tipo Contrato"
   EndCase                   

   // ##########################################
   // Verifica se houve informa��o de Cliente ##
   // ##########################################
   If Empty(Alltrim(M->C5_CLIENTE))
      MsgAlert("Aten��o! Cliente ainda n�o informado. Opera��o n�o permitida.")
      Return(.T.)
   Endif

   // ##########################################
   // Verifica se houve informa��o de Cliente ##
   // ##########################################
   If Empty(Alltrim(M->C5_LOJACLI))
      MsgAlert("Aten��o! Cliente ainda n�o informado. Opera��o n�o permitida.")
      Return(.T.)
   Endif

   // ####################################################
   // Verifica se a condi��o de pagamento foi informada ##
   // ####################################################
   If Empty(Alltrim(M->C5_CONDPAG))
      MsgAlert("Aten��o! Condi��o de Pagamento ainda n�o informada. Opera��o n�o permitida.")
      Return(.T.)
   Endif

   // ######################################
   // Verifica se a moeda foi selecionada ##
   // ######################################
   If M->C5_MOEDA == 0
      MsgAlert("Aten��o! Moeda ainda n�o selecionada. Opera��o n�o permitida.")
      Return(.T.)
   Endif

   // #######################################
   // Verifica se o vendedor foi informado ##
   // #######################################
   If Empty(Alltrim(M->C5_VEND1))
      MsgAlert("Aten��o! Vendedor 1 ainda n�o informado. Opera��o n�o permitida.")
      Return(.T.)
   Endif

   // ######################################################
   // Desenha a tela para informa��o dos dados de Loca��o ##
   // ######################################################
   DEFINE MSDIALOG oDlgLoc TITLE "Contrato de Loca��o" FROM C(178),C(181) TO C(512),C(698) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlgLoc

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(249),C(001) PIXEL OF oDlgLoc
   @ C(059),C(005) GET oMemo2 Var cMemo2 MEMO Size C(249),C(001) PIXEL OF oDlgLoc
   
   @ C(021),C(149) Say "DADOS CONTRATO LOCA��O"          Size C(106),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(035),C(005) Say "N� Pedido Venda"                 Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(035),C(043) Say "Cliente"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(035),C(194) Say "N� Contrato"                     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(005) Say "Dt.Inicial"                      Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(047) Say "Dt.Final"                        Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(089) Say "Un. Vig�ncia"                    Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(166) Say "Vig�ncia"                        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(064),C(194) Say "Moeda"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(086),C(005) Say "Valor Total Contrato"            Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(086),C(072) Say "Cond.Pgt�"                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(086),C(105) Say "Descri��o Condi��o de Pagamento" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(107),C(005) Say "Vendedores"                      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(107),C(224) Say "% Comiss�o"                      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(142),C(005) Say "Tipo de Atendimento"             Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(142),C(100) Say "Tipo de Contrato"                Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   
   @ C(044),C(005) MsGet oGet1  Var Loc_Pedi Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba
   @ C(044),C(043) MsGet oGet3  Var Loc_Clie Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba
   @ C(044),C(194) MsGet oGet16 Var Loc_Cont Size C(059),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba

   If INCLUI == .T. .OR. ALTERA == .T.
      @ C(073),C(005) MsGet    oGet4     Var   cDinicial    Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc
      @ C(073),C(047) MsGet    oGet5     Var   cDFinal      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc
      @ C(073),C(089) ComboBox cComboBx1 Items aVigencia    Size C(072),C(010)                                             PIXEL OF oDlgLoc
      @ C(074),C(166) MsGet    oGet6     Var   cVigencia    Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999999"         PIXEL OF oDlgLoc
      @ C(074),C(194) ComboBox cComboBx2 Items aMoeda       Size C(060),C(010)                                             PIXEL OF oDlgLoc When lchumba
      @ C(095),C(005) MsGet    oGet15    Var   nValTotal    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgLoc
      @ C(095),C(072) MsGet    oGet7     Var   cCondicao    Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba && F3("SE4") VALID( CapCodPaga(cCondicao) )
      @ C(095),C(105) MsGet    oGet8     Var   cNomeCondi   Size C(148),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(005) MsGet    oGet9     Var   cVende01     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba && F3("SA3") VALID( BscLocVende(1) )
      @ C(117),C(037) MsGet    oGet10    Var   cNomeV01     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(226) MsGet    oGet11    Var   cPercV01     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc When lChumba
      @ C(129),C(005) MsGet    oGet12    Var   cVende02     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba && F3("SA3") VALID( BscLocVende(2) )
      @ C(129),C(037) MsGet    oGet13    Var   cNomeV02     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(130),C(226) MsGet    oGet14    Var   cPercV02     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc When lChumba
      @ C(151),C(005) ComboBox cComboBx3 Items aAtendimento Size C(092),C(010)                                             PIXEL OF oDlgLoc
      @ C(151),C(100) ComboBox cComboBx4 Items aTipoContra  Size C(072),C(010)                                             PIXEL OF oDlgLoc

      @ C(149),C(177) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgLoc ACTION( CfmeLocacao() )
      @ C(149),C(216) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgLoc ACTION( oDlgLoc:End() )
      
   Else

      @ C(073),C(005) MsGet    oGet4     Var   cDinicial    Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lchumba
      @ C(073),C(047) MsGet    oGet5     Var   cDFinal      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lchumba
      @ C(073),C(089) ComboBox cComboBx1 Items aVigencia    Size C(072),C(010)                                             PIXEL OF oDlgLoc When lchumba
      @ C(074),C(166) MsGet    oGet6     Var   cVigencia    Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999999"         PIXEL OF oDlgLoc When lchumba
      @ C(074),C(194) ComboBox cComboBx2 Items aMoeda       Size C(060),C(010)                                             PIXEL OF oDlgLoc When lchumba
      @ C(095),C(005) MsGet    oGet15    Var   nValTotal    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgLoc When lchumba
      @ C(095),C(072) MsGet    oGet7     Var   cCondicao    Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(095),C(105) MsGet    oGet8     Var   cNomeCondi   Size C(148),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(005) MsGet    oGet9     Var   cVende01     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(037) MsGet    oGet10    Var   cNomeV01     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(117),C(226) MsGet    oGet11    Var   cPercV01     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc When lChumba
      @ C(129),C(005) MsGet    oGet12    Var   cVende02     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(129),C(037) MsGet    oGet13    Var   cNomeV02     Size C(183),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgLoc When lChumba
      @ C(130),C(226) MsGet    oGet14    Var   cPercV02     Size C(027),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgLoc When lChumba
      @ C(151),C(005) ComboBox cComboBx3 Items aAtendimento Size C(092),C(010)                                             PIXEL OF oDlgLoc When lChumba
      @ C(151),C(100) ComboBox cComboBx4 Items aTipoContra  Size C(072),C(010)                                             PIXEL OF oDlgLoc When lChumba

      @ C(149),C(177) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgLoc ACTION( CfmeLocacao() ) When lChumba
      @ C(149),C(216) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgLoc ACTION( oDlgLoc:End() )

   Endif    
  
   ACTIVATE MSDIALOG oDlgLoc CENTERED 

Return(.T.)

// ########################################################
// Fun��o que pesquisa a condi��o de pagamento informada ##
// ########################################################
Static Function CapCodPaga( __Condicao )

   Local cSql := ""
   
   If Empty(Alltrim(__Condicao))
      cCondicao  := Space(06)
      cNomeCondi := Space(60)
      oGet7:Refresh()
      oGet8:Refresh()
      Return(.T.)
   Endif

   cNomeCondi := Posicione("SE4", 1, xFilial("SE4") + __Condicao, "E4_DESCRI")         
   oGet8:Refresh()
   
Return(.T.)

// ##########################################################################
// Fun��o que pesquisa o vendedor informado na tela de loca��o de produtos ##
// ##########################################################################
Static Function BscLocVende(_____Tipo)

   If _____Tipo == 1
      cNomeV01 := Posicione("SA3", 1, xFilial("SA3") + cVende01, "A3_NOME")         
      If Empty(Alltrim(cNomeV01))
         cVende01 := Space(06)      
      Endif   
      oGet9:Refresh()
   Else
      cNomeV02 := Posicione("SA3", 1, xFilial("SA3") + cVende02, "A3_NOME")         
      If Empty(Alltrim(cNomeV02))
         cVende02 := Space(06)      
      Endif   
      oGet10:Refresh()
   Endif

Return(.T.)

// ########################################################
// Fun��o que gera as consist�ncias dos dados informados ##
// ########################################################
Static Function CfmeLocacao()
           
   // ######################
   // Consiste a Vig�ncia ##
   // ######################
   If Substr(cComboBx1,01,01) == "0"
      MsgAlert("Vig�ncia do Contrato n�o selecionado.")
      Return(.T.)
   Endif   

   // ###################################
   // Consiste data inicial da loca��o ##
   // ###################################
   If Empty(cDinicial)
      MsgAlert("Data inicial do contrato n�o informada.")
      Return(.T.)
   Endif   
   
   // #################################
   // Consiste data final da loca��o ##
   // #################################
   If Empty(cDfinal)
      MsgAlert("Data final do contrato n�o informada.")
      Return(.T.)
   Endif   
   
   // ########################################
   // Consiste tempo de vig�ncia da loca��o ##
   // ########################################
   If cVigencia == 0
      MsgAlert("Vig�ncia n�o informada.")
      Return(.T.)
   Endif   

   // ####################################
   // Consiste o valor total da loca��o ##
   // ####################################
   If nValTotal == 0
      MsgAlert("Valor Total do Contrato de Loca��o n�o informado.")
      Return(.T.)
   Endif

   // ##################################
   // Consiste do Tipo de Atendimento ##
   // ##################################
   If Substr(cComboBx3,01,01) == "0"
      MsgAlert("Tipo de Atendimento n�o informado.")
      Return(.T.)
   Endif   

   // ###############################
   // Consiste do Tipo de Contrato ##
   // ###############################
   If Substr(cComboBx4,01,01) == "0"
      MsgAlert("Tipo de Contrato n�o informado.")
      Return(.T.)
   Endif   

   // ###################################
   // Guarda os dados no campo C5_ZLOC ##
   // ###################################
   M->C5_ZLOC := Dtoc(cDinicial)         + "|" + ; // 01 - Data inicial de vig�ncia do contrato de Loca��o
                 Dtoc(cDfinal)           + "|" + ; // 02 - Data final   de vig�ncia do contrato de Loca��o
                 Substr(cComboBx1,01,01) + "|" + ; // 03 - Unidade da Vig�ncia do COntrato de Loca��o
                 Alltrim(Str(cVigencia)) + "|" + ; // 04 - Dias de Vig�ncia do contrato de Loca��o
                 Substr(cComboBx3,01,01) + "|" + ; // 05 - Tipo de Atendimento do Contrato de Loca��o
                 Substr(cComboBx4,01,01) + "|" + ; // 06 - Tipo de Contrato de Loca��o
                 Str(nValTotal,12,02)    + "|" + ; // 07 - Valor Total do Contrato de Loca��o
                 nContrato               + "|" + ; // 08 - N� do Contrato de Loca��o
                 Str(cPercV01,06,02)     + "|" + ; // 09 - % Comiss�o Vendedor 1
                 Str(cPercV02,06,02)     + ""      // 10 - % Comiss�o Vendedor 2                 
                 
   oDlgLoc:End()

Return(.T.)