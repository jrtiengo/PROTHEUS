#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: AUTOM631.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 13/09/2017                                                                ##
// Objetivo..: Programa que solicita as dimensões da embalagem do produto.               ##
// ########################################################################################

User Function AUTOM631()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private lEAltura      := .F.
   Private lELargura     := .F.
   Private lEComprimento := .F.
   Private lEBase        := .F.
   Private lERaio        := .F.
   Private lELado        := .F.

   Private lLiberaBnt    := .F.

   Private aFormato     := {"X - Selecione o Formato", "0 - NÃO SE APLICA", "1 - CUBO", "2 - RETÂNGULO", "3 - CILINDRO", "4 - PRISMA", "5 - PIRÂMIDE", "6 - CONE", "7 - ESFERA"}
   Private aIndividual  := {"0 - Selecione", "N - Não", "S - Sim"}

   Private kProduto	    := Alltrim(SB1->B1_COD)                                                   + " - " + ;
                           Alltrim(Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_DESC")) + " "   + ;
                           Alltrim(Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_DAUX"))
   Private kAltura 	    := Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_ALTU")
   Private kLargura 	:= Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_LARG")
   Private kComprimento := Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_COMP")
   Private kBase   	    := Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_ZBAS")
   Private kRaio    	:= Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_RAIO")
   Private kLado    	:= Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_LADO")
   Private kPeso  	    := Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_PESC")
   Private kEmbalagem   := Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_EMBA")
   Private kIndividual  := Posicione( "SB1", 1, xFilial("SB1") + SB1->B1_COD, "B1_ZVIN")
   Private kCubagem	    := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private cComboBx1
   Private cComboBx2
   
   Private oDlgCBG

   Do Case

      Case kEmbalagem == "0"
           cComboBx1    := "0 - NÃO SE APLICA"
           lEAltura     := .F.; lELargura := .F.; lEComprimento := .F.; lEBase := .F.; lERaio := .F.; lELado := .F.
           kAltura 	    := 0
           kLargura 	:= 0
           kComprimento := 0
           kBase   	    := 0
           kRaio    	:= 0
           kLado    	:= 0
           kPeso  	    := 0
           kEmbalagem   := "0"
           kIndividual  := ""
           kCubagem	    := 0

      Case kEmbalagem == "1"
           cComboBx1 := "1 - CUBO"
           lEAltura  := .T.; lELargura := .T.; lEComprimento := .T.; lEBase := .F.; lERaio := .F.; lELado := .F.

      Case kEmbalagem == "2"
           cComboBx1 := "2 - RETÂNGULO" 
           lEAltura  := .T.; lELargura := .T.; lEComprimento := .T.; lEBase := .F.; lERaio := .F.; lELado := .F.

      Case kEmbalagem == "3"
           cComboBx1 := "3 - CILINDRO" 
           lEAltura  := .T.; lELargura := .F.; lEComprimento := .F.; lEBase := .F.; lERaio := .T.; lELado := .F.

      Case kEmbalagem == "4"
           cComboBx1 := "4 - PRISMA" 
           lEAltura  := .T.; lELargura := .F.; lEComprimento := .F.; lEBase := .T.; lERaio := .F.; lELado := .F.

      Case kEmbalagem == "5"
           cComboBx1 := "5 - PIRÂMIDE"
           lEAltura  := .T.; lELargura := .F.; lEComprimento := .F.; lEBase := .F.; lERaio := .F.; lELado := .T.

      Case kEmbalagem == "6"
           cComboBx1 := "6 - CONE" 
           lEAltura  := .T.; lELargura := .F.; lEComprimento := .F.; lEBase := .F.; lERaio := .T.; lELado := .F.

      Case kEmbalagem == "7"
           cComboBx1 := "7 - ESFERA"
           lEAltura  := .F.; lELargura := .F.; lEComprimento := .F.; lEBase := .F.; lERaio := .T.; lELado := .F.

      OtherWise
           cComboBx1 := "0 - Selecione o Formato"
           lEAltura  := .F.; lELargura := .F.; lEComprimento := .F.; lEBase := .F.;  lERaio := .T.; lELado := .F.

   EndCase

   Do Case
      Case kIndividual == "S"
           cComboBx2 := "S - Sim"
           
      Case kIndividual == "N"
           cComboBx2 := "N - Não"
           
      OtherWise
           cComboBx2 := "0 - Selecione"
   EndCase        

   CalcVolTotal(0)

   // ##################################################
   // Verifica se usuário pode executar este programa ##
   // ##################################################
   If Alltrim(Upper(cUserName)) == "ADMINISTRADOR"
      lLiberaBnt := .T.
   Else

      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZZ4_ADIM" 
      cSql += "  FROM " + RetSqlName("ZZ4")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      If T_PARAMETROS->( EOF() )
         lLiberaBnt := .F.
      Endif

      If U_P_OCCURS(T_PARAMETROS->ZZ4_ADIM, "|", 1) == 0
         lLiberaBnt := .F.
      Else
         lLiberaBnt := .T.      
      Endif
 
   Endif

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlgCBG TITLE "Dimensões do Produto" FROM C(178),C(181) TO C(579),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgCBG
   @ C(068),C(005) Jpeg FILE "CUBO.PNG"        Size C(050),C(060) PIXEL NOBORDER OF oDlgCBG
   @ C(068),C(059) Jpeg FILE "RETANGULO.PNG"   Size C(050),C(060) PIXEL NOBORDER OF oDlgCBG
   @ C(068),C(114) Jpeg FILE "CILINDRO.PNG"    Size C(050),C(060) PIXEL NOBORDER OF oDlgCBG
   @ C(068),C(168) Jpeg FILE "PRISMA.PNG"      Size C(050),C(060) PIXEL NOBORDER OF oDlgCBG
   @ C(068),C(223) Jpeg FILE "PIRAMIDE.PNG"    Size C(050),C(060) PIXEL NOBORDER OF oDlgCBG
   @ C(068),C(277) Jpeg FILE "CONE.PNG"        Size C(050),C(060) PIXEL NOBORDER OF oDlgCBG
   @ C(068),C(332) Jpeg FILE "ESFERA.PNG"      Size C(050),C(060) PIXEL NOBORDER OF oDlgCBG

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlgCBG
   @ C(144),C(002) GET oMemo2 Var cMemo2 MEMO Size C(385),C(001) PIXEL OF oDlgCBG
   @ C(175),C(002) GET oMemo3 Var cMemo3 MEMO Size C(385),C(001) PIXEL OF oDlgCBG
   
   @ C(058),C(005) Say "Informe abaixo tipo do formato da embalagem do produto bem como suas dimensões"                    Size C(201),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(133),C(005) Say "Formato da embalagem ou do produto:"                                                               Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(180),C(005) Say "ATENÇÃO!"                                                                                          Size C(028),C(008) COLOR CLR_RED   PIXEL OF oDlgCBG
   @ C(188),C(005) Say "ESTAS INFORMAÇÕES SÃO DE SUMA IMPORTÂNCIA PARA O CÁLCULO DO SIMFRETE. TENHA CAUTELA EM ALTERÁ-LOS" Size C(312),C(008) COLOR CLR_RED   PIXEL OF oDlgCBG

   @ C(036),C(005) Say "Produto"           Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(005) Say "Altura(cm)"        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(037) Say "Largura(cm)"       Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(069) Say "Comprim.(cm)"      Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(101) Say "Base(cm)"          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(137) Say "Raio(cm)"          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(173) Say "Lado(cm)"          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(255) Say "Volume Total(cm3)" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(150),C(332) Say "Peso"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG
   @ C(133),C(223) Say "Volume Individual" Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgCBG

   @ C(045),C(005) MsGet    oGet1     Var   kProduto     Size C(384),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgCBG When lChumba
   @ C(131),C(099) ComboBox cComboBx1 Items aFormato     Size C(120),C(010)                                     PIXEL OF oDlgCBG ON CHANGE TROCAEMBALAGEM()
   @ C(131),C(268) ComboBox cComboBx2 Items aIndividual  Size C(037),C(010)                                     PIXEL OF oDlgCBG
   @ C(159),C(005) MsGet    oGet2     Var   kAltura      Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lEAltura      
   @ C(159),C(037) MsGet    oGet3     Var   kLargura     Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lELargura
   @ C(159),C(069) MsGet    oGet4     Var   kComprimento Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lEComprimento
   @ C(159),C(101) MsGet    oGet5     Var   kBase        Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lEBase
   @ C(159),C(137) MsGet    oGet6     Var   kRaio        Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lERaio
   @ C(159),C(173) MsGet    oGet7     Var   kLado        Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lELado
   @ C(157),C(201) Button "Calcular Volume"              Size C(047),C(012)                                     PIXEL OF oDlgCBG ACTION( CalcVolTotal(1) ) 
   @ C(159),C(255) MsGet    oGet8     Var   kCubagem     Size C(035),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgCBG When lChumba
   @ C(159),C(332) MsGet    oGet9     Var   kPeso        Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99.999" PIXEL OF oDlgCBG

   @ C(183),C(311) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgCBG ACTION( GravaDimensoes() ) When lLiberaBnt
   @ C(183),C(350) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgCBG ACTION( oDlgCBG:End() )

   ACTIVATE MSDIALOG oDlgCBG CENTERED 

Return(.T.)

// ####################################
// Função que calcula o volume total ##
// ####################################
Static Function CalcVolTotal( _Mostra )

   Local kTipoEmba := Substr(cComboBx1,01,01)

   If Substr(cComboBx1,01,01)$("X#0")
      kCubagem := 0
   Else
      kCubagem := U_AUTOM630(Substr(cComboBx1,01,01), kAltura, kLargura, kComprimento, kBase, kRaio, kLado, 1)
   Endif   
   
   If _Mostra == 1
      oGet8:Refresh()
   Endif   
   
Return(.T.)   

// #######################################
// Função que troca o tipo de embalagem ##
// #######################################
Static Function TrocaEmbalagem()

   Local lchumba := .F.

   If Substr(cComboBx1,01,01) == "X"
      MsgAlert("Formato da embalagem do produto não selecionada. Verifique!")
      Return(.T.)
   Endif   

   Do Case
      Case Substr(cComboBx1,01,01) == "0"
           lEAltura      := .F.
           lELargura     := .F.
           lEComprimento := .F.
           lEBase        := .F.
           lERaio        := .F.
           lELado        := .F.

      Case Substr(cComboBx1,01,01) == "1"
           lEAltura      := .T.
           lELargura     := .T.
           lEComprimento := .T.
           lEBase        := .F.
           lERaio        := .F.
           lELado        := .F.

      Case Substr(cComboBx1,01,01) == "2"
           lEAltura      := .T.
           lELargura     := .T.
           lEComprimento := .T.
           lEBase        := .F.
           lERaio        := .F.
           lELado        := .F.

      Case Substr(cComboBx1,01,01) == "3"
           lEAltura      := .T.
           lELargura     := .F.
           lEComprimento := .F.
           lEBase        := .F.
           lERaio        := .T.
           lELado        := .F.

      Case Substr(cComboBx1,01,01) == "4"
           lEAltura      := .T.
           lELargura     := .F.
           lEComprimento := .F.
           lEBase        := .T.
           lERaio        := .F.
           lELado        := .F.

      Case Substr(cComboBx1,01,01) == "5"
           lEAltura      := .T.
           lELargura     := .F.
           lEComprimento := .F.
           lEBase        := .F.
           lERaio        := .F.
           lELado        := .T.

      Case Substr(cComboBx1,01,01) == "6"
           lEAltura      := .T.
           lELargura     := .F.
           lEComprimento := .F.
           lEBase        := .F.
           lERaio        := .T.
           lELado        := .F.

      Case Substr(cComboBx1,01,01) == "7"
           lEAltura      := .F.
           lELargura     := .F.
           lEComprimento := .F.
           lEBase        := .F.
           lERaio        := .T.
           lELado        := .F.

   EndCase

   kAltura      := 0
   kLargura     := 0
   kComprimento := 0
   kBase        := 0
   kRaio        := 0
   kLado        := 0
   kCubagem     := 0

   @ C(159),C(005) MsGet oGet2 Var kAltura      Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lEAltura      
   @ C(159),C(037) MsGet oGet3 Var kLargura     Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lELargura
   @ C(159),C(069) MsGet oGet4 Var kComprimento Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lEComprimento
   @ C(159),C(101) MsGet oGet5 Var kBase        Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lEBase
   @ C(159),C(137) MsGet oGet6 Var kRaio        Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lERaio
   @ C(159),C(173) MsGet oGet7 Var kLado        Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCBG When lELado
   @ C(159),C(255) MsGet oGet8 Var kCubagem     Size C(035),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgCBG When lChumba

Return(.T.)

// #################################################
// Função que grava as novas dimensões do produto ##
// #################################################
Static Function GravaDimensoes()

   Local lMostra := .F.

   // ####################################################################################
   // Consiste os dados de volumetria do produto para cálculo de volume para o SIMFRETE ##
   // ####################################################################################
   Do Case
      
      Case Substr(cComboBx1,01,01) == "X"

           MsgAlert("Atenção! Tipo de embalagem do produto não selecionada. Verifique!")
           Return(.F.)

      Case Substr(cComboBx1,01,01) == "0"
           lEAltura     := .F.; lELargura := .F.; lEComprimento := .F.; lEBase := .F.; lERaio := .F.; lELado := .F.
           kAltura 	    := 0
           kLargura 	:= 0
           kComprimento := 0
           kBase   	    := 0
           kRaio    	:= 0
           kLado    	:= 0
           kPeso  	    := 0
           kEmbalagem   := "0"
           kIndividual  := ""
           kCubagem	    := 0

      Case Substr(cComboBx1,01,01) == "1"

           If kLargura     == 0; lMostra := .T.; Endif
           If kAltura      == 0; lMostra := .T.; Endif
           If kComprimento == 0; lMostra := .T.; Endif

           If lMostra == .T.
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Largura, Altura e Comprimento do produto não informado para o tipo de embalagem CUBO." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
              Return(.F.)
           Endif
                 
      Case Substr(cComboBx1,01,01) == "2"

           If kLargura     == 0; lMostra := .T.; Endif
           If kAltura      == 0; lMostra := .T.; Endif
           If kComprimento == 0; lMostra := .T.; Endif

           If lMostra == .T.
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Largura, Altura e Comprimento do produto não informado para o tipo de embalagem RETÂNGULO." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
              Return(.F.)
           Endif
                 
      Case Substr(cComboBx1,01,01) == "3"

           If kAltura == 0; lMostra := .T.; Endif
           If kRaio   == 0; lMostra := .T.; Endif

           If lMostra == .T.
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Raio do produto não informado para o tipo de embalagem CILINDRO." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
              Return(.F.)
           Endif
                  
      Case Substr(cComboBx1,01,01) == "4"

           If kAltura == 0; lMostra := .T.; Endif
           If kBase   == 0; lMostra := .T.; Endif

           If lMostra == .T.
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Base do produto não informado para o tipo de embalagem PRISMA." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
              Return(.F.)
           Endif
   
      Case Substr(cComboBx1,01,01) == "5"

           If kAltura == 0; lMostra := .T.; Endif
           If kLado   == 0; lMostra := .T.; Endif

           If lMostra == .T.
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Lado do produto não informado para o tipo de embalagem PIRAMIDE" + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
              Return(.F.)
           Endif
   
      Case Substr(cComboBx1,01,01) == "6"
              
           If kAltura == 0; lMostra := .T.; Endif
           If kRaio   == 0; lMostra := .T.; Endif

           If lMostra == .T.
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Raio do produto não informado para o tipo de embalagem CONE." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
              Return(.F.)
           Endif
   
      Case Substr(cComboBx1,01,01) == "7"

           If kRaio == 0; lMostra := .T.; Endif

           If lMostra == .T.
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Raio do produto não informado para o tipo de embalagem ESFERA." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
              Return(.F.)
           Endif

   EndCase        

   If Substr(cComboBx1,01,01) == "0"
   Else
      If Substr(cComboBx2,01,01) == "0"
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Indicação de Volume Individual não selecionado." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
         Return(.F.)
      Endif
   Endif   

   // ####################################################################
   // Atualiza os campos no cadastro de produtos do produto selecionado ##
   // ####################################################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   If DbSeek( xFilial("SB1") + Alltrim(U_P_CORTA(kproduto, "-", 1)) + Space(30 - Len(Alltrim(U_P_CORTA(kproduto, "-", 1)))))
      Reclock("SB1",.F.)
      SB1->B1_EMBA := Substr(cComboBx1,01,01)
      SB1->B1_ALTU := kAltura
      SB1->B1_LARG := kLargura
      SB1->B1_COMP := kComprimento
      SB1->B1_ZBAS := kBase
      SB1->B1_RAIO := kRaio
      SB1->B1_LADO := kLado
      SB1->B1_PESC := kPeso
      SB1->B1_ZVIN := Substr(cComboBx2,01,01)
      MsUnLock()
   Endif   

   oDlgCBG:End()
   
Return(.T.)