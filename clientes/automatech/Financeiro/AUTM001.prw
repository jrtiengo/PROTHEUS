#INCLUDE "RWMAKE.ch"
#INCLUDE "PROTHEUS.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTM001.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 10/05/2011                                                          ##
// Objetivo..: Geração de Boletos através da NF de Saída                           ##
// ##################################################################################

User Function AUTM001(cNumNota,cNumSerie)

   Local cSql      := ""                                      
   Local lBord	   := .T.                          // Parâmetro enviado para o programa da geração do borderô. Para diferênciar se a chamada do borderô é pela nf.
   Local cNumBord  := Soma1(GetMV("MV_NUMBORR"),6) // Verifica o último numero de borderô e incrementa.
   Local cCBanco   := ""	                       // Banco do borderô
   Local cCAgen	   := ""	                       // Agência do borderô
   Local cCCont	   := ""	                       // Conta corrente do borderô
   Local nOpc	   := 0	                           // Seleção de ação. 1 continua, 2 cancela.
   Local aComboBx1 := {"Itau","Santander"}         // Informa quais bancos disponíveis para geração.   
   Local cComboBx1   

   Private cQuery := {}
   Private oDlg

   // ######################################
   // Campos que serão atualizados no SE1 ##
   // ######################################
   // E1_PORTADO - CODIGO DOBANCO
   // E1_AGEDEP - AGENCIA BANCARIA
   // E1_NUMBRO - NUMERO DO BORDERO
   // E1_DATABOR - DATA DO BORDERO
   // E1_MOVIMEN - DATA DO BORDERO
   // E1_SITUACA - 1 COBRANCA SIMPLES
   // E1_CONTA - NUMERO DA CONTA

   // ###########################################################################
   // Verifica se o cliente do resgitro deve ou não receber boleto de cobrança ##
   // ###########################################################################
   If Select("T_ENVIABOL") > 0
      T_ENVIABOL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.E1_CLIENTE, "
   cSql += "       A.E1_LOJA   , "
   cSql += "       B.A1_BOLET    "
   cSql += "  FROM " + RetSqlName("SE1010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B  "
   cSql += " WHERE A.E1_NUM     = '" + Alltrim(cNumNota)  + "' "
   cSql += "   AND A.E1_PREFIXO = '" + Alltrim(cNumSerie) + "' "
   cSql += "   AND B.A1_COD     = A.E1_CLIENTE "
   cSql += "   AND B.A1_LOJA    = A.E1_LOJA    "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENVIABOL", .T., .T. )

   If !T_ENVIABOL->( Eof() )

      If T_ENVIABOL->A1_BOLET == "N"

         If !MsgYesNo("Atenção! Este Cliente está indicado para não receber Boleto Bancário. Deseja emití-lo assim mesmo?")
            If Select("T_ENVIABOL") > 0
               T_ENVIABOL->( dbCloseArea() )
            EndIf
            Return .T.
         Endif

      Endif

   Endif

   If Select("T_ENVIABOL") > 0
      T_ENVIABOL->( dbCloseArea() )
   EndIf

   // ###############################################################################
   // Pesquisa o parâmetro automatech para ver em que banco o boleto será impresso ##
   // ###############################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TBOL FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   Do Case
      Case T_PARAMETROS->ZZ4_TBOL == "1"
           lSantander := .T.
           lItau      := .F.                  
      Case T_PARAMETROS->ZZ4_TBOL == "2"
           lSantander := .F.                                                
           lItau      := .T.                  
      Case T_PARAMETROS->ZZ4_TBOL == "3"                     
           lSantander := .F.
           lItau      := .F.                  
   EndCase

   If lItau == .T. .And. lSantander == .T.

      DEFINE MSDIALOG oDlg TITLE "Geração de Boletos" FROM C(242),C(378) TO C(509),C(914) PIXEL

      @ C(020),C(050) Say "INFORME O BANCO PARA O QUAL SERÁ GERADO O BOLETO" Size C(167),C(008) COLOR CLR_BLUE PIXEL OF oDlg

      @ C(055),C(095) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg

      @ C(104),C(050) Button "CONFIRMA" Size C(037),C(012) ACTION(oDlg:End(),nOpc:=1) PIXEL OF oDlg
      @ C(104),C(162) Button "CANCELA"  Size C(037),C(012) ACTION(oDlg:End())        PIXEL OF oDlg

      ACTIVATE MSDIALOG oDlg CENTERED
      
      // ###########################################################      
      // Realiza a impressão do boleto conforme banco selecionado ##
      // ###########################################################
      If nOpc == 1
   	     If cComboBx1	== "Itau"
		    U_BOLITAU(lBord,cNumNota,cNumSerie)
	     Elseif cComboBx1	== "Santander"
		    U_SANTANDER(lBord,cNumNota,cNumSerie)
	     EndIf
      EndIf

   Else

      Do Case 
      
         Case lSantander == .T. .And. lItau == .F.
		      U_SANTANDER(lBord,cNumNota,cNumSerie)

         Case lSantander == .F. .And. lItau == .T.
  		      U_BOLITAU(lBord,cNumNota,cNumSerie)

      EndCase
      
   Endif   

Return()

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTM001.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 10/05/2011                                                          ##
// Objetivo..: Funcao responsavel por manter o Layout independente da resolucao    ##
//             horizontal do Monitor do Usuario.                                   ##
// ##################################################################################

Static Function C(nTam)

   Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

   If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	  nTam *= 0.8
   ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
      nTam *= 1
   Else	// Resolucao 1024x768 e acima
	  nTam *= 1.28
   EndIf

   // ##############################
   // Tratamento para tema "Flat" ##
   // ############################## 
   If "MP8" $ oApp:cVersion
	  If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
	     nTam *= 0.90
	  EndIf
   EndIf
   
Return Int(nTam)