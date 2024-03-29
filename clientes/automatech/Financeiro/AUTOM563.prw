#INCLUDE "protheus.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"    
#INCLUDE "Font.ch"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*

北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砇FINR99   篈utor  矲lavio Macieira     � Data �  26/08/13   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Rotina de impress鉶 de Boletos                             罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Taimin                                                     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

User Function AUTOM563(cPrefixo,cNumero,cParcela,cCliente,cLoja,cBanco,cAgencia,cConta)

   Local aRegs		:= {}
 //Local aLst		:= {}
   Local aTamSX3	:= {}
   Local lEnd		:= .F.
   Local lAuto		:= .F.
   Local nLastKey	:= 0
   Local Tamanho	:= "P"
   Local cDesc1		:= "Este programa tem como objetivo efetuar a impress鉶 do"
   Local cDesc2		:= "Boleto de Cobran鏰 com c骴igo de barras, conforme os"
   Local cDesc3		:= "par鈓etros definidos pelo usu醨io."
   Local cString	:= "SE1"
   Local wnrel		:= "RFINR99"
   Local cPerg		:= PADR("BOLSANT",LEN (SX1->X1_GRUPO))

   Private Titulo		:= "Boleto de Cobran鏰 com C骴igo de Barras"
   Private aReturn		:= {"Banco", 1,"Financeiro", 2, 2, 1, "",1 }
   Private aLst		:= {}

   // #####################################################
   // Verifica se a chamada foi feita por outro programa ##
   // #####################################################
   If ValType(cPrefixo) == "C" .And.;
 	  ValType(cNumero)  == "C" .And.;
	  ValType(cParcela) == "C" .And.;
	  ValType(cCliente) == "C" .And.;
	  ValType(cLoja)    == "C" .And.;
	  ValType(cBanco)   == "C" .And.;
	  ValType(cAgencia) == "C" .And.;
	  ValType(cConta)   == "C"
	  lAuto	     := .T.
   EndIf

   // ########################################
   // Cria array com as perguntas da rotina ##
   // ########################################
   aTamSX3	:= TAMSX3("E1_PREFIXO")
   aAdd(aRegs,{cPerg,"01","Do Prefixo" , "", "", "mv_ch1",aTamSX3[3], aTamSx3[1], aTamSX3[2], 0,"G","","MV_PAR01","", "", "", "",						"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})
   aAdd(aRegs,{cPerg,"02","Ate Prefixo", "", "", "mv_ch2",aTamSX3[3], aTamSx3[1], aTamSX3[2], 0,"G","","MV_PAR02","", "", "", Replic('z',aTamSX3[1]),	"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})

   aTamSX3	:= TAMSX3("E1_NUM")
   aAdd(aRegs,{cPerg,"03","Do Numero" , "", "", "mv_ch3", aTamSX3[3], aTamSx3[1], aTamSX3[2], 0,"G","","MV_PAR03","", "", "", "",						"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})
   aAdd(aRegs,{cPerg,"04","Ate Numero", "", "", "mv_ch4", aTamSX3[3], aTamSx3[1], aTamSX3[2], 0,"G","","MV_PAR04","", "", "", Replic('z',aTamSX3[1]),	"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})

   aTamSX3	:= TAMSX3("E1_PARCELA")
   aAdd(aRegs,{cPerg,"05","Da Parcela" , "","","mv_ch5",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR05","",	 			"",	  			"",				"",						"","",	 			"",				"",				"","","",		"","","","","","","","","","","","","","",		"","011",	"",""})
   aAdd(aRegs,{cPerg,"06","Ate Parcela", "","","mv_ch6",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR06","",	 			"",	  			"",				Replic('z',aTamSX3[1]),	"","",	 			"",				"",				"","","",		"","","","","","","","","","","","","","",		"","011",	"",""})

   aTamSX3	:= TAMSX3("E1_CLIENTE")
   aAdd(aRegs,{cPerg,"07","Do Cliente" , "","","mv_ch7",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR07","",	 			"",	  			"",				"",						"","",	 			"",				"",	 			"","","",		"","","","","","","","","","","","","","SA1",	"","001",	"",""})
   aAdd(aRegs,{cPerg,"08","Ate Cliente", "","","mv_ch8",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR08","",	 			"",	  			"",				Replic('z',aTamSX3[1]),	"","",	 			"",				"",	 			"","","",		"","","","","","","","","","","","","","SA1",	"","001",	"",""})

   aTamSX3	:= TAMSX3("E1_LOJA")
   aAdd(aRegs,{cPerg,"09","Da Loja" , "","","mv_ch9",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR09","",	  			"",	  			"",				"",						"","",	 			"",				"",	 			"","","",		"","","","","","","","","","","","","","",		"","002",	"",""})
   aAdd(aRegs,{cPerg,"10","Ate Loja", "","","mv_chA",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR10","",	  			"",	  			"",				Replic('z',aTamSX3[1]),	"","",	 			"",				"",	 			"","","",		"","","","","","","","","","","","","","",		"","002",	"",""})

   aTamSX3	:= TAMSX3("EE_CODIGO")
   aAdd(aRegs,{cPerg,"11","Banco Cobranca", "","","mv_chB",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR11","",	  			"",	  			"",				"",						"","",	 			"",				"",	 			"","","",		"","","","","","","","","","","","","","SA6",	"","007",	"",""})

   aTamSX3	:= TAMSX3("EE_AGENCIA")                                                                                                                                                                                                              
   aAdd(aRegs,{cPerg,"12","Agencia Cobranca", "","","mv_chC",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR12","",	  			"",	  			"",				"",						"","",	 			"",	  			"",	  			"","","",		"","","","","","","","","","","","","","",		"","008",	"",""})

   aTamSX3	:= TAMSX3("EE_CONTA")
   aAdd(aRegs,{cPerg,"13","Conta Cobranca", "","","mv_chD",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR13","",	  			"",	  			"",				"",						"","",	 			"",	  			"",	  			"","","",		"","","","","","","","","","","","","","",		"","009",	"",""})

   aTamSX3	:= TAMSX3("EE_SUBCTA")
   aAdd(aRegs,{cPerg,"14","Carteira Cobran鏰"    ,	"","","mv_chE",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR14","",	  			"",	  			"",				"",						"","",	 			"",	  			"",	  			"","","",		"","","","","","","","","","","","","","",		"","",		"",""})
   aAdd(aRegs,{cPerg,"15","Re-Impressao"         ,	"","","mv_chF","N",			01,			00,			2,"C","","MV_PAR15","Sim",			"Sim",			"Sim",			"",						"","Nao",			"Nao",			"Nao",			"","","",		"","","","","","","","","","","","","","",		"","",		"",""})
   aAdd(aRegs,{cPerg,"16","Traz Titulos Marcados",	"","","mv_chH","N",			01,			00,			2,"C","","MV_PAR16","Sim",			"Sim",			"Sim",			"",						"","Nao",			"Nao",			"Nao",			"","","",		"","","","","","","","","","","","","","",		"","",		"",""})

   aTamSX3	:= TAMSX3("E1_EMISSAO")
   aAdd(aRegs,{cPerg,"17","Dt.Emiss Inicial", "","","mv_chJ",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR17","",				"",				"",				"31/12/49",				"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})
   aAdd(aRegs,{cPerg,"18","Dt.Emiss Final"  , "","","mv_chK",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR18","",				"",				"",				"31/12/49",				"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})

   aTamSX3	:= TAMSX3("E1_VENCREA")
   aAdd(aRegs,{cPerg,"19","Vencto Real Inicial", "","","mv_chM",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR19","",				"",				"",				"31/12/49",				"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})
   aAdd(aRegs,{cPerg,"20","Vencto Real Final"  , "","","mv_chN",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR20","",				"",				"",				"31/12/49",				"","",				"",				"",				"","","",		"","","","","","","","","","","","","","",		"","",		"",""})

   aTamSX3 := TAMSX3("E1_NUMBOR")
   aAdd(aRegs,{cPerg,"21","Bordero", "","","mv_cho",aTamSX3[3],  aTamSx3[1], aTamSX3[2], 0,"G","","MV_PAR21","",             "",             "",             "        ",             "","",              "",             "",             "","","",       "","","","","","","","","","","","","","",      "","",      "",""}) 

   CriaSx1(aRegs)

   // ###########################################################
   // Atualiza o SX1 se a chamada foi feita por outro programa ##
   // ###########################################################
   If lAuto

	  dbSelectArea("SA6")
	  dbSetOrder(1)
	  If !dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta,.f.)
		 Aviso("Impressao de Boletos","Configura鏰o de banco nao encontrada para o banco "+Alltrim(cbanco)+", agencia "+Alltrim(cAgencia)+", conta "+Alltrim(cConta)+" do cliente "+Alltrim(SA1->A1_NOME)+". Verifique o cadastro de parametros de bancos para que a rotina possa ser gerada.",{"OK"},,"Atencao:")
		 DbSelectArea("QUERY")
		 Return(Nil)
	  EndIf
	
	  cCarteira := SEE->EE_SUBCTA
	  cConvenio := Alltrim(SEE->EE_CODEMP)
	
	  dbSelectArea("SX1")
	  dbSeTorder(1)
	  MsSeek(cPerg)
	  While !Eof() .and. SX1->X1_GRUPO == cPerg
	     Reclock("SX1",.F.)
		 If SX1->X1_ORDEM == "01"
			SX1->X1_CNT01	:= cPrefixo
		 ElseIf SX1->X1_ORDEM == "02"
			SX1->X1_CNT01	:= cPrefixo
		 ElseIf SX1->X1_ORDEM == "03"
			SX1->X1_CNT01	:= cNumero
		 ElseIf SX1->X1_ORDEM == "04"
			SX1->X1_CNT01	:= cNumero
		 ElseIf SX1->X1_ORDEM == "05"
			SX1->X1_CNT01	:= cParcela
		 ElseIf SX1->X1_ORDEM == "06"
			SX1->X1_CNT01	:= cParcela
		 ElseIf SX1->X1_ORDEM == "07"
			SX1->X1_CNT01	:= cCliente
		 ElseIf SX1->X1_ORDEM == "08"
			SX1->X1_CNT01	:= cCliente
		 ElseIf SX1->X1_ORDEM == "09"
			SX1->X1_CNT01	:= cLoja
		 ElseIf SX1->X1_ORDEM == "10"
			SX1->X1_CNT01	:= cLoja
		 ElseIf SX1->X1_ORDEM == "11"
			SX1->X1_CNT01	:= SA6->A6_BANCO
		 ElseIf SX1->X1_ORDEM == "12"
			SX1->X1_CNT01	:= SA6->A6_AGENCIA
		 ElseIf SX1->X1_ORDEM == "13"
			SX1->X1_CNT01	:= SA6->A6_CONTA
		 ElseIf SX1->X1_ORDEM == "14"
			SX1->X1_CNT01	:= SA6->A6_SUBCTA
		 ElseIf SX1->X1_ORDEM == "15"
			SX1->X1_PRESEL	:= 2
		 ElseIf SX1->X1_ORDEM == "16'"
			SX1->X1_PRESEL	:= 2
		 ElseIf SX1->X1_ORDEM == "17"
			SX1->X1_PRESEL	:= 1
		 EndIf
		 MsUnLock()
		 dbSkip()
	  EndDo

  	  Pergunte(cPerg,.F.)

      // #######################################################
      // Chama a pergunte para definir os par鈓etros iniciais ##
      // #######################################################
   Else
	  If !Pergunte(cPerg, .T.)
		 Return(Nil)
	  EndIf
   EndIf

   // ############################################################
   // Chama a rotina para carregar os dados a serem processados ##
   // ############################################################
   Processa( { |lEnd| CallLst() }, "Selecionando dados a processar", Titulo )

   // ########################################
   // Verifica se h� dados a serem exibidos ##
   // ########################################
   If Len(aLst) > 0
	  Processa( { |lEnd| CallMark(aLst) }, "Selecionando dados a processar", Titulo )
   Else
	  Aviso(Titulo,;
			"N鉶 existem dados a serem impressos. Verifique os par鈓etros.",;
			{"&Continua"},,;
			"Sem Dados" )
   EndIf

Return(Nil)

// ##################################################################################
// Fun玢o que carrega os registros a serem processados (T韙ulo a serem impressoas) ##
// ##################################################################################
Static Function CallLst()

   Local aAreaAtu := GetArea()
   Local aTamSX3  := {}
   Local nCnt	  := 0
   Local cQuery	  := ""
 //Local cPgtVista := GetMV("MV_#AVISTA",,)

   // ###########################
   // Monta a query de sele玢o ##
   // ###########################
   cQry	:= " SELECT SE1.R_E_C_N_O_ AS REGSE1,"
   cQry	+= "        SE1.E1_PREFIXO          ,"
   cQry	+= "        SE1.E1_NUM              ,"
   cQry	+= "        SE1.E1_PARCELA          ,"
   cQry	+= "        SE1.E1_TIPO             ,"
   cQry	+= "        SE1.E1_CLIENTE          ,"
   cQry	+= "        SE1.E1_LOJA             ,"
   cQry	+= "        SE1.E1_NOMCLI           ,"
   cQry	+= "        SE1.E1_EMISSAO          ,"
   cQry	+= "        SE1.E1_VENCTO           ,"
   cQry	+= "        SE1.E1_VENCREA          ,"
   cQry	+= "        SE1.E1_VALOR            ,"
   cQry	+= "        SE1.E1_PORTADO          ,"
   cQry	+= "        SE1.E1_NUMBCO           ,"
   cQry	+= "        SA1.A1_ENDCOB           ,"
   cQry	+= "        SA1.A1_CEP              ,"
   cQry	+= "        SA1.A1_CEPC             ,"
   cQry	+= "        SE1.E1_PEDIDO           ,"
   cQry	+= "        SA1.A1_CGC               "
   cQry	+= "   FROM " + RetSqlName("SE1") + " SE1 (NOLOCK),"
   cQry	+= "        " + RetSqlName("SA1") + " SA1 (NOLOCK) "
   cQry	+= "  WHERE SE1.E1_FILIAL = '" + Alltrim(xFilial("SE1")) + "'"
   cQry	+= " AND SE1.E1_SALDO     > 0"
   cQry	+= " AND SE1.E1_EMISSAO BETWEEN '" + DToS(mv_par17) + "' AND '" + DToS(mv_par18) + "'"
   cQry	+= " AND SE1.E1_VENCREA BETWEEN '" + DToS(mv_par19) + "' AND '" + DToS(mv_par20) + "'"
   cQry	+= " AND SE1.E1_PREFIXO BETWEEN '" + mv_par01       + "' AND '" + mv_par02       + "'"
   cQry	+= " AND SE1.E1_NUM BETWEEN     '" + mv_par03       + "' AND '" + mv_par04       + "'"
   cQry	+= " AND SE1.E1_PARCELA BETWEEN '" + mv_par05       + "' AND '" + mv_par06       + "'"
   cQry	+= " AND SE1.E1_TIPO IN('NF ','DP ','FT ','BOL ')"
   cQry	+= " AND SE1.E1_CLIENTE BETWEEN '" + mv_par07       + "' AND '" + mv_par08       + "'"
   cQry	+= " AND SE1.E1_LOJA BETWEEN '"    + mv_par09       + "' AND '" + mv_par10       + "'"
 //If !Empty(mv_par21)
 //	  cQry    += "AND SE1.E1_NUMBOR = '"+mv_par21+"'"
 //Endif
 //cQry	+= " AND SE1.E1_NUMBCO <> '"+Space(TAMSX3("E1_NUMBCO")[1])+"'"
   cQry	+= " AND SE1.E1_PORTADO = '" + mv_par11 + "'"
   cQry	+= " AND SE1.D_E_L_E_T_ = ' '"
   cQry	+= " AND SA1.A1_FILIAL  = '" + Alltrim(xFilial("SA1")) + "'"
   cQry	+= " AND SA1.A1_COD     = SE1.E1_CLIENTE"
   cQry	+= " AND SA1.A1_LOJA    = SE1.E1_LOJA"
   cQry	+= " AND SA1.D_E_L_E_T_ = ' '"
   cQry	+= " ORDER BY SE1.E1_NUM,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_PREFIXO,SE1.E1_PARCELA,SE1.E1_TIPO"

   // #########################################################
   // Se existir o alias tempor醨io, fecha para n鉶 dar erro ##
   // #########################################################
   If Select("RFINR99A") > 0                                     
 	  dbSelectArea("RFINR99A")
	  dbCloseArea()
   EndIf

   // ################################################################
   // Executa a select no banco para pegar os registros a processar ##
   // ################################################################
   TCQUERY cQry NEW ALIAS "RFINR99A"
   dbSelectArea("RFINR99A")
   dbGoTop()

   // #########################################
   // Compatibiliza os campos com a TopField ##
   // #########################################
   aTamSX3	:= TAMSX3("E1_EMISSAO")
   TCSETFIELD("RFINR99A", "E1_EMISSAO",	aTamSX3[3], aTamSX3[1], aTamSX3[2])

   aTamSX3	:= TAMSX3("E1_VENCTO")
   TCSETFIELD("RFINR99A", "E1_VENCREA",	aTamSX3[3], aTamSX3[1], aTamSX3[2])

   aTamSX3	:= TAMSX3("E1_VENCREA")
   TCSETFIELD("RFINR99A", "E1_VENCREA",	aTamSX3[3], aTamSX3[1], aTamSX3[2])

   aTamSX3	:= TAMSX3("E1_VALOR")
   TCSETFIELD("RFINR99A", "E1_VALOR"  , aTamSX3[3], aTamSX3[1], aTamSX3[2])

   // #########################################
   // Conta os registros a serem processados ##
   // #########################################
   RFINR99A->( dbEval( { || nCnt++ },,{ || !Eof() } ) )
   dbGoTop()

   // ###################################################################
   // Alimenta array com os dados a serem exibidos na tela de marca玢o ##
   // ###################################################################
   dbSelectArea("SC5")
   SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM

   dbSelectArea("RFINR99A")
   dbGoTop()
   ProcRegua( nCnt )

   While !Eof()
   
      // ###############################
	  // Movimenta regua de Impress鉶 ##
	  // ###############################
      IncProc( "T韙ulo: " + RFINR99A->E1_PREFIXO +"/"+ RFINR99A->E1_NUM +"/"+ RFINR99A->E1_PARCELA ) 
	
	  // ###########################
  	  // Cria o elemento no array ##
	  // ###########################
	  aAdd(aLst, {	(mv_par16 == 1)      ,;
					 RFINR99A->E1_PREFIXO,;
					 RFINR99A->E1_NUM    ,;
					 RFINR99A->E1_PARCELA,;
					 RFINR99A->E1_TIPO   ,;
					 RFINR99A->E1_CLIENTE,;
					 RFINR99A->E1_LOJA   ,;
					 RFINR99A->E1_NOMCLI ,;
					 RFINR99A->E1_EMISSAO,;
					 RFINR99A->E1_VENCREA,;
					 RFINR99A->E1_VENCREA,;
					 RFINR99A->E1_VALOR  ,;
					 RFINR99A->E1_PORTADO,;
					 RFINR99A->REGSE1    ,;
					 If( "MESMO" $ RFINR99A->A1_ENDCOB, .T., .F. ),;
					 If( !Empty( RFINR99A->A1_CEP + RFINR99A->A1_CEPC ), .T., .F. ) ;
					})
	  dbSelectArea("RFINR99A")
	  dbSkip()
   EndDo

   // ###########################
   // Fecha a 醨ea de trabalho ##
   // ###########################
   dbSelectArea("RFINR99A")
   dbCloseArea()

   // #########################
   // Restaura 醨ea original ##
   // #########################
   RestArea(aAreaAtu)

Return(Nil)

// ######################################################################################
// Fun玢o que abre atela de sele玢o dos t韙ulos a serem impressos os boletos banc醨ios ##
// ######################################################################################
Static Function CallMark()
   
   Local oLst
   Local oDlg
   Local oOk	   := LoadBitMap(GetResources(), "LBTIK")
   Local oNo	   := LoadBitMap(GetResources(), "LBNO")
   Local oAzul	   := LoadBitMap(GetResources(), "BR_AZUL")
   Local oAmarelo  := LoadBitMap(GetResources(), "BR_AMARELO")
   Local oVermelho := LoadBitMap(GetResources(), "BR_VERMELHO")
   Local lProc	   := .F.
   Local nLoop	   := 0
   Local nBotao	   := 0

   // ##################################################################
   // Monta interface com usu醨io para efetuar a marca玢o dos t韙ulos ##
   // ##################################################################
   DEFINE MSDIALOG oDlg TITLE "Sele玢o de T韙ulos" FROM 000,000 TO 400,780 OF oDlg PIXEL
   
   @ 005,003 LISTBOX oLst FIELDS HEADER	" ", " ", "Prefixo", "N鷐ero", "Parc.", "Tipo", "Cliente", "Loja", "Nome", "Emiss鉶", "Vencto.", "Venc.Real", "Valor", "Portador" ;
			COLSIZES GetTextWidth(0,"BB")         ,;
					 GetTextWidth(0,"BB")         ,;
					 GetTextWidth(0,"BBB")        ,;
					 GetTextWidth(0,"BBB")        ,;
					 GetTextWidth(0,"BB")         ,;
					 GetTextWidth(0,"BB")         ,;
					 GetTextWidth(0,"BBBB")       ,;
					 GetTextWidth(0,"BB")         ,;
					 GetTextWidth(0,"BBBBBBBBBBB"),;
					 GetTextWidth(0,"BBBB")       ,;
					 GetTextWidth(0,"BBBB")       ,;
					 GetTextWidth(0,"BBBB")       ,;
					 GetTextWidth(0,"BBBBBBBBB")  ,;
					 GetTextWidth(0,"BBB")         ;
			ON DBLCLICK(aLst[oLst:nAt,1] := !aLst[oLst:nAt,1],oLst:Refresh() ) SIZE 385,170 OF oDlg PIXEL

   oLst:SetArray(aLst)

   oLst:bLine := { || {	If(aLst[oLst:nAt,01] , oOk, oNo)                 ,;	// Marca
						If(!aLst[oLst:nAt,16], oVermelho, oAzul)         ,;	// Led - Envia com NF/Via Correio
						aLst[oLst:nAt,02]                                ,;	// Prefixo
						aLst[oLst:nAt,03]                                ,;	// Numero
						aLst[oLst:nAt,04]                                ,;	// parcela
						aLst[oLst:nAt,05]                                ,;	// Tipo
						aLst[oLst:nAt,06]                                ,;	// Cliente
						aLst[oLst:nAt,07]                                ,;	// Loja
						aLst[oLst:nAt,08]                                ,;	// Nome
						DToC(aLst[oLst:nAt,09])                          ,;	// Emiss鉶
						DToC(aLst[oLst:nAt,10])                          ,;	// Vencimento
						DToC(aLst[oLst:nAt,11])                          ,;	// Vencimento real
						Transform(aLst[oLst:nAt,12], "@E 999,999,999.99"),;	// Valor 
						aLst[oLst:nAt,13]                                 ; // Portador
						} }

   //@ 180,005 BITMAP oBmp RESNAME "BR_AZUL"			SIZE 16,16 NOBORDER	PIXEL
   //@ 180,015 SAY "Boleto junto com a nota fiscal"	OF oDlg				PIXEL COLOR CLR_HBLUE
   //@ 189,005 BITMAP oBmp RESNAME "BR_AMARELO"		SIZE 16,16 NOBORDER	PIXEL
   //@ 189,015 SAY "Boleto via correio"				OF oDlg				PIXEL COLOR CLR_HBLUE
   @ 180,005 BITMAP oBmp RESNAME "BR_VERMELHO"		SIZE 16,16 NOBORDER	PIXEL
   @ 180,015 SAY "Cliente Sem CEP"					OF oDlg				PIXEL COLOR CLR_HBLUE

   DEFINE SBUTTON oBtnOk	FROM 180,350 TYPE 1		ACTION(nBotao := 1, oDlg:End())	ENABLE OF oDlg
   DEFINE SBUTTON oBtnCan	FROM 180,315 TYPE 2		ACTION(nBotao := 2, oDlg:End())	ENABLE OF oDlg
// DEFINE SBUTTON oBtnVis	FROM 180,280 TYPE 15	ACTION(nBotao := 3, u_VisCli( aLst[oLst:nAt,06], aLst[oLst:nAt,07] ) )	ENABLE OF oDlg

   ACTIVATE DIALOG oDlg CENTERED

   // #######################################
   // Verifica se teclou no bot鉶 confirma ##
   // #######################################
   If nBotao == 1

	  // #######################################
	  // Verifica se tem algum t韙ulo marcado ##
	  // #######################################
	  For nLoop := 1 To Len(aLst)
	   	  If aLst[nLoop,1]
			 lProc	:= .T.
			 Exit
		  EndIf
	  Next nLoop

	  // ##########################################
	  // Avisa usu醨io que n鉶 h� t韙ulo marcado ##
	  // ##########################################
	  If !lProc
		 Aviso(	Titulo,;
				"Nenhum t韙ulo foi marcado. N鉶 h� dados a serem impressos.",;
				{"&Continua"},,;
				"Sem Dados" )

	     // #######################################################
	     // Chama a rotina que ir� montar e imprimir o relat髍io ##
	     // #######################################################
 	  Else
		 Processa( { |lEnd| MontaRel() }, "Montando Imagem do Relat髍io.", Titulo )
	  Endif
   EndIf

Return(Nil)

// #############################################
// Fun玢o que visualiza o cadastro do cliente ##
// #############################################
user Function VisCli( cCliente, cLoja )

   Local aAreaAtu := GetArea()
   Local aAreaSA1 := SA1->( GetArea() )

   Private cCadastro := Titulo

   dbSelectArea( "SA1" )
   dbSetOrder( 1 )
   
   If !MsSeek( xFilial( "SA1" ) + cCliente + cLoja )
	  Aviso(Titulo,;
			"Cliente n鉶 localizado no cadastro. Contate o Administrador.",;
			{ "&Continua" },,;
			"Cliente: " + cCliente + "/" + cLoja )
   Else
	  AxVisual( "SA1", Recno() , 2 )
   EndIf

   RestArea( aAreaSA1 )
   RestArea( aAreaAtu )

Return( Nil )

// ########################################################
// Fun玢o que monta a imagem do relat髍io a ser impresso ##
// ########################################################
Static Function MontaRel()

   Local oPrint
   Local aDadEmp    := {}
   Local aDadBco    := {}
   Local aDadCli    := {}
   Local nLoop	    := 0
   Local nTpImp	    := 0
   Local cStartPath := GetSrvProfString( "StartPath", "" )

   Private aDadTit	:= {}
   Private aBarra	:= {}

   // #########################################################
   // Define o tipo de configura玢o a ser utilizado na MSBAR ##
   // 1 = Polegadas, 2 = Cent韒etros                         ##
   // #########################################################
   nTpImp	:= 2          

   Private cFilename := Criatrab(Nil,.F.)

   // #####################
   // Posiciona no Banco ##
   // #####################
   dbSelectArea("SA6")
   dbSetOrder(1)
   If !MsSeek(xFilial("SA6")+mv_par11+mv_par12+mv_par13)
	  Aviso(Titulo,;
			"Banco/Ag阯cia/Conta: "+ AllTrim(mv_par11) +"/"+ AllTrim(mv_par12) +"/"+ AllTrim(mv_par13) +Chr(13)+Chr(10)+;
			"O registro n鉶 foi localizado no arquivo. Ser� desconsiderado.",;
			{"&Continua"},2,;
			"Registro Inv醠ido" )
	  Return(Nil)
   EndIf

   // ##################################
   // Posiciona no Par鈓etro do Banco ##
   // ##################################
   dbSelectArea("SEE")
   dbSetOrder(1)
   If !MsSeek(xFilial("SEE")+mv_par11+mv_par12+mv_par13+mv_par14)
	  Aviso(Titulo,;
			"Banco/Ag阯cia/Conta/Carteira: "+ AllTrim(mv_par11) +"/"+ AllTrim(mv_par12) +"/"+ AllTrim(mv_par13) +"/"+ AllTrim(mv_par14) + Chr(13) + Chr(10) +;
			"Os par鈓etros do banco n鉶 foram localizados. Ser� desconsiderado.",;
			{"&Continua"},2,;
			"Registro Inv醠ido" )
	  Return(Nil)
   EndIf

   // ####################################################
   // Chama rotina que pega os dados do banco e empresa ##
   // ####################################################
   If !U_xTCDadBco(aDadEmp, aDadBco)
	  Aviso(Titulo,;
			"Banco/Ag阯cia/Conta: "+ AllTrim(mv_par11) +"/"+ AllTrim(mv_par12) +"/"+ AllTrim(mv_par13) +"/"+ Chr(13) + Chr(10) +;
			"Banco do cliente: "+ SA1->A1_BCO1 + Chr(13) + Chr(10) + ;
			"N鉶 foi poss韛el obter os dados do banco.",;
			{"&Continua"},2,;
			"Registro Inv醠ido" )
	  Return(Nil)
   EndIf

   ProcRegua(Len(aLst))

   For nLoop := 1 To Len(aLst)
	   
	   // ###############################
	   // Movimenta r間ua de impress鉶 ##
	   // ###############################
   	   IncProc( "T韙ulo: " + aLst[nLoop,02] + "/" + aLst[nLoop,03] )

       // #################################
	   // S� processa se estiver marcado ##
	   // #################################
	   If aLst[nLoop,01]

	      // ######################
		  // Posiciona no t韙ulo ##
		  // ######################
		  dbSelectArea("SE1")
		  dbSetOrder(1)
		  dbGoTo(aLst[nLoop,14])
		  If Eof() .Or. Bof()
			 Aviso(	Titulo,;
					"T韙ulo :"+ aLst[nLoop,02] +"/"+ aLst[nLoop,03] +"/"+ aLst[nLoop,04] +"/"+ aLst[nLoop,05] +Chr(13)+Chr(10)+;
					"O t韙ulo n鉶 foi localizado no arquivo. Ser� desconsiderado.",;
					{"&Continua"},2,;
					"Registro Inv醠ido" )
			 Loop
		  EndIf

		  // #######################
		  // Posiciona no Cliente ##
		  // #######################
 		  dbSelectArea("SA1")
		  dbSetOrder(1)
		  If !MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			 Aviso(	Titulo,;
					"T韙ulo :"+ aLst[nLoop,02] +"/"+ aLst[nLoop,03] +"/"+ aLst[nLoop,04] +"/"+ aLst[nLoop,05] +Chr(13)+Chr(10)+;
					"Cliente/Loja: "+ SE1->E1_CLIENTE +"/"+ SE1->E1_LOJA +Chr(13)+Chr(10)+;
					"O cliente n鉶 foi localizado no arquivo. Ser� desconsiderado.",;
					{"&Continua"},2,;
					"Registro Inv醠ido" )
			 Loop
		  EndIf

		  // ######################
		  // Posiciona no T韙ulo ##
		  // ######################
		  dbSelectArea("SE1")

		  // #####################################################
		  // Chama rotina que pega os dados do t韙ulo e cliente ##
		  // #####################################################
		  If !U_TCDadTit(aDadTit, aDadCli, aBarra, aDadBco)
			 Aviso(	Titulo,;
					"T韙ulo :"+ aLst[nLoop,02] +"/"+ aLst[nLoop,03] +"/"+ aLst[nLoop,04] +"/"+ aLst[nLoop,05] +Chr(13)+Chr(10)+;
					"N鉶 foi poss韛el obter os dados do t韙ulo. ser� desconsiderado.",;
					{"&Continua"},2,;
					"Registro Inv醠ido" )
			 Loop
		  EndIf

		  // ########################################
		  // Chama a fun玢o de impress鉶 do boleto ##
	  	  // ########################################
		  U_TCImpBol(oPrint,aDadEmp,aDadBco,aDadTit,aDadCli,aBarra,nTpImp)

		  // ############################################################
		  // Grava o arquivo com a imagem do boleto se for via correio ##
		  // ############################################################
		  //If !( aLst[nLoop,15] )
		  //	oPrint:SaveAllAsJPEG( cStartPath + "Boleto" + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA), 870, 1200, 105 )
		  //EndIf

		  // #######################################
		  // Atualiza o t韙ulo com o nosso n鷐ero ##
		  // #######################################
		  DbSelectArea("SE1")
		  RecLock("SE1",.F.)
		  If Empty(SE1->E1_NUMBCO)
			 SE1->E1_NUMBCO	:= "0"+alltrim(aBarra[3])+alltrim(aBarra[5])+modulo11("0"+alltrim(aBarra[3])+alltrim(aBarra[5])) //Dema
		  Endif
		  If FieldPos("E1_BCOBOL") > 0
			 SE1->E1_BCOBOL	:= aDadBco[1]
		  Else
			 SE1->E1_PORTADO	:= aDadBco[1]
			 SE1->E1_AGEDEP	:= aDadBco[3]
			 SE1->E1_CONTA	:= aDadBco[5]
		  EndIf
		  MsUnlock()
	   EndIf
   Next nLoop

Return(Nil)

// #############################################
// Fun玢o que cria um novo grupo de perguntas ##
// #############################################
Static Function CriaSx1(aRegs)

   Local aAreaAnt	:= GetArea()
   Local aAreaSX1	:= SX1->(GetArea())
   Local nJ			:= 0
   Local nY			:= 0

   dbSelectArea("SX1")
   dbSetOrder(1)

   For nY := 1 To Len(aRegs)
	   If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
		  RecLock("SX1",.T.)
		  For nJ := 1 To FCount()
			  If nJ <= Len(aRegs[nY])
				 FieldPut(nJ,aRegs[nY,nJ])
			  EndIf
		  Next nJ
		  MsUnlock()
	   EndIf
   Next nY

   RestArea(aAreaSX1)
   RestArea(aAreaAnt)

Return(Nil)

// ##########################################################################################
//  Programa    砊OPCONCNAB� Biblioteca de fun珲es gen閞icas para utiliza玢o na gera玢o de ##
//              �          � boleto de cobran鏰 em formato gr醘ico, e nos arquivos de      ##
//              �          � comunica玢o banc醨ia (remessa e retorno) do Cnab              ##
// ----------------------------------------------------------------------------------------##
//  Autor       � Fl醰io Macieira                                                26.08.13� ##
// 屯屯屯屯屯屯拓屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯� ##
//  Observa珲es � Os arquivos SE1, SA1 e SA6 devem estar posicionados no registro a ser    ##
//              � impresso                                                                 ##
//              �                                                                          ##
//              �         ANTES DE QUALQUER PROCESSAMENTO CRIAR CAMPOS/PAR翸ETROS          ##
//              � ***************************** CAMPOS NOVOS ****************************  ##
//              � A6_DIGBCO  - C - 01,0 - OBRIGAT覴IO - D韌ito do banco perante a c鈓ara   ##
//              �              de compensa玢o (FEBRABAN).                                  ##
//              � A6_ARQLOG  - C - 15,0 - OPCIONAL - Nome do arquivo com o logotipo do     ##
//              �              banco que deve obrigatoriamente estar no diret髍io \SYSTEM\ ##
//              �              se n鉶 existir, colocar� no lugar do logo o nome reduzido   ##
//              �              do cadastro de bancos.                                      ##
//              � ****************************** PAR翸ETROS *****************************  ##
//              � TC_TXJBOL - Taxa de juros de mora ao m阺 por atraso no pagamento, se n鉶 ##
//              �             existir n鉶 ir� colocar a mensagem com o valor dos juros que ##
//              �             dever� ser cobrado por dia de atraso.                        ##
//             � TC_TXMBOL - Taxa de multa por atraso no pagamento, se n鉶 existir n鉶     ##
//             �             ir� colocar a mensagem com o percentual de multa a ser que    ##
//             �             dever� ser cobrado por atraso no pagamento                    ##
//             � TC_DIABOL - N鷐ero de dias para envio do t韙ulo ao cart髍io, se n鉶       ##
//             �             existir n鉶 ir� colocar a mensagem com o prazo de envio do    ##
//             �             t韙ulo ao cart髍io                                            ##
//             � MC_BCEDEN - Parametro que indica se o Banco ser� o Cedente do Boleto.     ##
//             �                   CAMPOS ATUALIZADOS NA ROTINA                            ##
//             � E1_PORTADO - com o banco selecionado no par鈓etro da rotina               ##
//             � E1_AGENCIA - com a ag阯cia selecionada no par鈓etro da rotina             ##
//             � E1_CONTA   - com a conta selecionada no par鈓etro da rotina               ##
//             � EE_FAXATU  - com � pr髕imo n鷐ero dispon韛el para utiliza玢o              ##
//             � ******************************* DIVERSOS ******************************   ##
//             � 1. O campo EE_FAXATU deve conter o pr髕imo n鷐ero do boleto SEM o d韌ito  ##
//             �    verificador e no tamanho exato do n鷐ero definido no manual do banco,  ##
//             �    N肙 deve haver caracteres separadores (.;,-etc...)                     ##
//             �    Citibank  - 11 posi鏾es                                                ##
//             �    Ita�      - 08 Posi珲es                                                ##
//             �    Brasil    - 10 Posi珲es                                                ##
//             �    Bradesco  - 11 Posi珲es                                                ##
//             �    Santander - 11 Posi珲es                                                ##
//             � 2. Carteira  - para defini玢o do c骴igo da carteira � utilizado o campo   ##
//             �    EE_SUBCTA                                                              ##
//             �                                                                           ##
// ##########################################################################################

// ##########################################################################################
// Fun玢o que retorna array com os dados do banco e da empresa                             ##
// --------------------------------------------------------------------------------------- ##
// Autor       � Fl醰io Macieira                                        26.08.13 �         ##
// --------------------------------------------------------------------------------------- ##
// Par鈓etros  � ExpA1 = Array vazio passado por refer阯cia para ser atualizado com os     ##
//             �         dados do cadastro de empresa (SigaMat)                            ##
//             � ExpA2 = Array Vazio passado por refer阯cia para ser atualizado com os     ##
//             �         dados so cadastro do banco (SA6)                                  ##
// --------------------------------------------------------------------------------------- ##
// Retorno     � ExpL1 = .T. montou os arrays corretamento, .F. n鉶 montou os arrays       ##
// --------------------------------------------------------------------------------------- ##
// Observa珲es � Os arquivos devem estar posicionados SM0, SA6, SEE                        ##
// --------------------------------------------------------------------------------------- ##
// Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                             ##
//             �                                                                           ##
// ##########################################################################################
User Function xTCDadBco(aDadEmp, aDadBco)

   Local aAreaAtu := GetArea()
   Local lRet	  := .T.     

   // ##################################################################################
   // Parametro que verifica se o Banco ser� o Cedente do Titulo, atrav閟 dos campos  ##
   // Cod. Banco, Ag阯cia e N鷐ero de conta, que devem ser informados sequencialmente ##
   // no parametro.                                                                   ##
   // ##################################################################################
   Local cCedente  := ''//IF(ValType(GetMv("MC_BCEDEN")) <> "C","",ALLTRIM(GetMv("MC_BCEDEN")))   

   // #################################################
   // Verifica se passou os par鈓etros para a fun玢o ##
   // #################################################
   If (aDadEmp == Nil .Or. ValType(aDadEmp) <> "A") .Or. (aDadBco == Nil .Or. ValType(aDadBco) <> "A")
	  Aviso("Biblioteca de Fun珲es",;
			"Os par鈓etros passados por refer阯cia est鉶 fora dos padr鮡s."+Chr(13)+Chr(10)+;
			"Verifique a chamada da fun玢o no programa de origem.",;
			{"&Continua"},2,;
			"Chamada Inv醠ida" )
	  lRet	:= .F.
   EndIf

   // #############################################
   // Verifica se os arquivos est鉶 posicionados ##
   // #############################################
   If SM0->(Eof()) .Or. SM0->(Bof())
      Aviso("Biblioteca de Fun珲es",;
			"O arquivo de Empresas n鉶 esta posicionado.",;
			{"&Continua"},,;
			"Registro Inv醠ido" )
	  lRet	:= .F.
   EndIf 
   
   If SA6->(Eof()) .Or. SA6->(Bof())
	  Aviso("Biblioteca de Fun珲es",;
			"O arquivo de Bancos n鉶 esta posicionado.",;
			{"&Continua"},,;
			"Registro Inv醠ido" )
	  lRet	:= .F.
   EndIf

   // ###############################################################
   // Cria array vazio para que n鉶 d� erro se n鉶 encontrar dados ##
   // ###############################################################
   aDadEmp	:= {"",;	// [1] Nome da Empresa
				"",;	// [2] Endere鏾
				"",;	// [3] Bairro
				"",;	// [4] Cidade
				"",;	// [5] Estado
				"",;	// [6] Cep
				"",;	// [7] Telefone
				"",;	// [8] Fax
				"",;	// [9] CNPJ
				"" ;	// [10]Inscri玢o Estadual
				}

   aDadBco	:= {"",;	// [1] C骴igo do Banco
				"",;	// [2] D韌ito do Banco
				"",;	// [3] C骴igo da Ag阯cia
				"",;	// [4] D韌ito da Ag阯cia
				"",;	// [5] N鷐ero da Conta Corrente
				"",;	// [6] D韌ito da Conta Corrente
				"",;	// [7] Nome Completo do Banco
				"",;	// [8] Nome Reduzido do Banco
				"",;	// [9] Nome do Arquivo com o Logotipo do Banco
				0,;		// [10]Taxa de juros a ser utilizado no c醠culo de juros de mora
				0,;		// [11]Taxa de multa a ser impressa no boleto
				0,;		// [12]N鷐ero de dias para envio do t韙ulo ao cart髍io
				"",;	// [13]Dado para o campo "Uso do Banco"
				"",;	// [14]Dado para o campo "Esp閏ie do Documento"
				"",;	// [15]C骴igo do Cedente
				"" ;    // [16]Contrato banco\Conv阯io
				}

   If lRet			 
      // #########################################
	  // Alimenta array com os dados da Empresa ##
	  // #########################################
	 If !Empty(SM0->M0_ENDCOB)
		aDadEmp[2]	:= SM0->M0_ENDCOB
		aDadEmp[3]	:= SM0->M0_BAIRCOB
		aDadEmp[4]	:= SM0->M0_CIDCOB
		aDadEmp[5]	:= SM0->M0_ESTCOB
		aDadEmp[6]	:= SM0->M0_CEPCOB
	 Else
		aDadEmp[2]	:= SM0->M0_ENDENT
		aDadEmp[3]	:= SM0->M0_BAIRENT
		aDadEmp[4]	:= SM0->M0_CIDENT
		aDadEmp[5]	:= SM0->M0_ESTENT
		aDadEmp[6]	:= SM0->M0_CEPENT
	 EndIf

	 If ALLTRIM( SA6->A6_COD + alltrim(SA6->A6_AGENCIA) + SA6->A6_NUMCON ) $ cCedente
		aDadEmp[1]	:= SA6->A6_CEDENTE
	 Else
		aDadEmp[1]	:= SM0->M0_NOMECOM
		aDadEmp[7]	:= SM0->M0_TEL
		aDadEmp[8]	:= SM0->M0_FAX
		aDadEmp[9]	:= SM0->M0_CGC
		aDadEmp[10]	:= SM0->M0_INSC
	 Endif
	
	 // #######################################
	 // Alimenta array com os dados do Banco ##
	 // #######################################
     If SA6->(FieldPos("A6_DIGBCO")) > 0
		aDadBco[1]	:= SA6->A6_COD
		aDadBco[2]	:= SA6->A6_DIGBCO
	 Else
		aDadBco[1]	:= SA6->A6_COD
		aDadBco[2]	:= '7'
	 EndIf
	
	 If SA6->(FieldPos("A6_DVAGE")) > 0
		aDadBco[3]	:= SA6->A6_AGENCIA
		aDadBco[4]	:= SA6->A6_DVAGE //SA6->A6_DIGAGE
	 Else
		If At( "-", SA6->A6_AGENCIA ) > 1
		   aDadBco[3]	:= SubStr( SA6->A6_AGENCIA, 1, At( "-", SA6->A6_AGENCIA ) - 1 )
		   aDadBco[4]	:= SubStr( SA6->A6_AGENCIA, At( "-", SA6->A6_AGENCIA ) + 1, 1 )
		Else
		   aDadBco[3]	:= Alltrim(	SA6->A6_AGENCIA	)
		   aDadBco[4]	:= ""
		EndIf
	 EndIf
	
	 If SA6->(FieldPos("A6_DVCTA")) > 0 
		If At( "-", SA6->A6_NUMCON ) > 1   
	       aDadBco[5]	:= SubStr( SA6->A6_NUMCON, 1, At( "-", SA6->A6_NUMCON ) - 1)   
	 	   aDadBco[6]	:= SubStr( SA6->A6_NUMCON, At( "-", SA6->A6_NUMCON ) + 1, 1)   
		Else	    
		   aDadBco[5]	:= SA6->A6_NUMCON
		   aDadBco[6]	:= SA6->A6_DVCTA  //SA6->A6_DIGCON
		EndIf
	 Else
		If At( "-", SA6->A6_NUMCON ) > 1
	   	   aDadBco[5]	:= SubStr( SA6->A6_NUMCON, 1, At( "-", SA6->A6_NUMCON ) - 1)
		   aDadBco[6]	:= SubStr( SA6->A6_NUMCON, At( "-", SA6->A6_NUMCON ) + 1, 1)
		Else
		   aDadBco[5]	:= AllTrim( SA6->A6_NUMCON )
		   aDadBco[6]	:= ""
		EndIf
	 EndIf

	 aDadBco[7]	:= SA6->A6_NOME

     If AllTrim(SA6->A6_COD) == "001"
		aDadBco[8]	:= "BANCO DO BRASIL SA"   
		
	 ElseIf AllTrim(SA6->A6_COD) == "341"
		aDadBco[8]  := "BANCO ITA� S.A." 
		
 	 ElseIf	AllTrim(SA6->A6_COD) == "237"
		aDadBco[8]  := "BRADESCO"  
		
	 ElseIf AllTrim(SA6->A6_COD) == "033" 
		aDadBco[8]	:= "SANTANDER" 
				
	 EndIf
			
	 If SA6->(FieldPos("A6_ARQLOG")) > 0
	 	aDadBco[9]	:= SA6->A6_ARQLOG                      
	 Else
	 	aDadBco[9]	:= ""
	 EndIf

	 // ################################################################
	 // Define as taxas a serem utilizadas nos c醠culos das mensagens ##
	 // ################################################################
	 aDadBco[10]	:= SuperGetMv("TC_TXJBOL", .F., 0.00)
	 aDadBco[11]	:= SuperGetMv("TC_TXMBOL", .F., 0.00)
	 aDadBco[12]	:= SuperGetMv("TC_DIABOL", .F., 1)

 	 // #############################################
	 // Define o campo Para Uso do Banco do boleto ##
	 // #############################################
	 If SA6->A6_COD $ "745#"
	 	aDadBco[13]	:= "CLIENTE"
	 EndIf

	 // ################################################
	 // Define o campo Esp閏io do Documento do boleto ##
	 // ################################################
	 If SA6->A6_COD $ "745#"
	 	aDadBco[14]	:= "DMI"
	 ElseIf SA6->A6_COD $ "001#|033"
	 	aDadBco[14]	:= "DM"
	 Else
	 	aDadBco[14]	:= "NF"
	 EndIf
    

// aaqui

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Define o campo da Conta/Cedente do boleto �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If SA6->A6_COD $ "745#"
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Ag阯cia + Conta Cosmos (C骴igo Empresa) �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		aDadBco[15]	:= AllTrim(aDadBco[3])
		If !Empty(aDadBco[4])
			aDadBco[15]	+= "-"+Alltrim(aDadBco[4])
		EndIf
		If !Empty(SEE->EE_CODEMP)
			aDadBco[15]	+= "/"+StrZero(Val(EE_CODEMP),10)
		EndIf
	Else
		//谀哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Ag阯cia + Conta Corrente �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪馁
		aDadBco[15]	:= AllTrim(aDadBco[3])
		aDadBco[16] := SEE->EE_CODEMP
		If !Empty(aDadBco[4])
			aDadBco[15]	+= "-"+Alltrim(aDadBco[4])
		EndIf
		//If !Empty(aDadBco[5]) .AND. !SA6->A6_COD $ "033"
		aDadBco[15] += "/"+alltrim(right(SEE->EE_CODEMP,7))
			//If !Empty(aDadBco[6])
				//aDadBco[15] += "-"+AllTrim(aDadBco[6])
			//EndIf
		//Else
			//aDadBco[15] += "/"+AllTrim(aDadBco[16])	
		//EndIf
	EndIf

EndIf


RestArea(aAreaAtu)

Return(lRet)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � TCDadTit � Retorna array com os dados do t韙ulo e do cliente            罕�
北�             �          �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 20.01.07 �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpA1 = Array vazio passado por refer阯cia para ser atualizado com os   罕�
北�             �         dados do cadastro do t韙ulo (SE1)                               罕�
北�             � ExpA2 = Array Vazio passado por refer阯cia para ser atualizado com os   罕�
北�             �         dados so cadastro do cliente (SA1)                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpL1 = .T. montou os arrays corretamento, .F. n鉶 montou os arrays     罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es � Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
User Function TCDadTit(aDadTit, aDadCli, aBarra, aDadBco)

Local aAreaAtu	:= GetArea()
Local lRet		:= .T.
Local nSaldo	:= 0
Local cNumDoc	:= ""
Local cCarteira	:= ""
Local cMensag1	:= ""
Local cMensag2	:= ""
Local cMensag3	:= ""
Local cMensag4	:= ""
Local cMensag5	:= ""
Local cMensag6	:= ""
Local lSaldo	:= SuperGetMV( "TC_VLRBOL", .F., .T. )
Local cCedente  := '' //IF(ValType(GetMv("MC_BCEDEN")) <> "C","",ALLTRIM(GetMv("MC_BCEDEN")))   

If ALLTRIM( SA6->A6_COD + alltrim(SA6->A6_AGENCIA) + SA6->A6_NUMCON ) $ cCedente
	cMensag4    := "Titulo entregue em cess鉶 fiduci醨ia em favor do benefici醨io acima."
Endif


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se passou os par鈓etros para a fun玢o �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If (aDadTit == Nil .Or. ValType(aDadTit) <> "A") .Or.;
	(aDadCli == Nil .Or. ValType(aDadCli) <> "A") .Or.;
	(aBarra == Nil .Or. ValType(aBarra) <> "A")
	Aviso(	"Biblioteca de Fun珲es",;
			"Os par鈓etros passados por refer阯cia est鉶 fora dos padr鮡s."+Chr(13)+Chr(10)+;
			"Verifique a chamada da fun玢o no programa de origem.",;
			{"&Continua"},2,;
			"Chamada Inv醠ida" )
	lRet	:= .F.
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se os arquivos est鉶 posicionados �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If SE1->(Eof()) .Or. SE1->(Bof())
	Aviso(	"Biblioteca de Fun珲es",;
			"O arquivo de T韙ulos a Receber n鉶 esta posicionado.",;
			{"&Continua"},,;
			"Registro Inv醠ido" )
	lRet	:= .F.
EndIf
If SA1->(Eof()) .Or. SA1->(Bof())
	Aviso(	"Biblioteca de Fun珲es",;
			"O arquivo de Clientes n鉶 esta posicionado.",;
			{"&Continua"},,;
			"Registro Inv醠ido" )
	lRet	:= .F.
EndIf

aDadTit	:= {	"",;					// [1] Prefixo do T韙ulo
				"",;					// [2] N鷐ero do T韙ulo
				"",;					// [3] Parcela do T韙ulo
				"",;					// [4] Tipo do t韙ulo
				CToD("  /  /  "),;		// [5] Data de Emiss鉶 do t韙ulo
				CToD("  /  /  "),;		// [6] Data de Vencimento do T韙ulo
				CToD("  /  /  "),;		// [7] Data de Vencimento Real
				0,;						// [8] Valor L韖uido do T韙ulo
				"",;					// [9] C骴igo do Barras Formatado
				"",;					// [10]Carteira de Cobran鏰
				"",;					// [11]1.a Linha de Mensagens Diversas
				"",;					// [12]2.a Linha de Mensagens Diversas
				"",;					// [13]3.a Linha de Mensagens Diversas
				"",;					// [14]4.a Linha de Mensagens Diversas
				"",;					// [15]5.a Linha de Mensagens Diversas
				"" ;					// [16]6.a Linha de Mensagens Diversas
				}
aDadCli	:= {	"",;					// [1] C骴igo do cliente
				"",;					// [2] Loja do Cliente
				"",;					// [3] Nome Completo do Cliente
				"",;					// [4] CNPJ do Cliente
				"",;					// [5] Inscri玢o Estadual do cliente
				"",;					// [6] Tipo de Pessoa do Cliente
				"",;					// [7] Endere鏾
				"",;					// [8] Bairro
				"",;					// [9] Munic韕io
				"",;					// [10] Estado
				"",;					// [11] Cep
				"" ;					// [12] Via de entrega (Correio/Nota)
				}
aBarra	:= {	"",;					// [1] C骴igo de barras (Banco+"9"+D韌ito+Fator+Valor+Campo Livre
				"",;					// [2] Linha Digit醰el
				"",;					// [3] Nosso N鷐ero sem formata玢o
				"" ;					// [4] Nosso N鷐ero Formatado
				}

If lRet
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Alimenta array com os dados do cliente �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	aDadCli[1]	:= SA1->A1_COD
	aDadCli[2]	:= SA1->A1_LOJA
	aDadCli[3]	:= SA1->A1_NOME
	aDadCli[4]	:= SA1->A1_CGC
	aDadCli[5]	:= SA1->A1_INSCR
	aDadCli[6]	:= SA1->A1_PESSOA
	If !Empty(SA1->A1_ENDCOB)
		If !( "MESMO" $ UPPER( SA1->A1_ENDCOB ) )
			aDadCli[7]	:= SA1->A1_ENDCOB
			aDadCli[8]	:= SA1->A1_BAIRROC
			aDadCli[9]	:= SA1->A1_MUNC
			aDadCli[10]	:= SA1->A1_ESTC
			aDadCli[11]	:= SA1->A1_CEPC
			aDadCli[12]	:= ""//"CORREIO"
		Else
			aDadCli[7]	:= SA1->A1_END
			aDadCli[8]	:= SA1->A1_BAIRRO
			aDadCli[9]	:= SA1->A1_MUN
			aDadCli[10]	:= SA1->A1_EST
			aDadCli[11]	:= SA1->A1_CEP
			aDadCli[12]	:= ""//"CAMINH肙"

		EndIf
	Else
		aDadCli[7]	:= SA1->A1_END
		aDadCli[8]	:= SA1->A1_BAIRRO
		aDadCli[9]	:= SA1->A1_MUN
		aDadCli[10]	:= SA1->A1_EST
		aDadCli[11]	:= SA1->A1_CEP
		aDadCli[12]	:= ""//"CORREIO"
	Endif

	//谀哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Monta o saldo do t韙ulo �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪�
	If lSaldo
		nSaldo	:= SE1->E1_SALDO
	Else
		nSaldo	:= SE1->E1_VALOR
	EndIf    
//	nSaldo  := SALDOTIT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,1,DDatabase,,SE1->E1_LOJA)
	nSaldo	-= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nSaldo	-= SE1->E1_DECRESC
	nSaldo	+= SE1->E1_ACRESC

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Pega ou monta o nosso n鷐ero �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If !Empty(SE1->E1_NUMBCO)
		cNumDoc	:= left(alltrim(SE1->E1_NUMBCO),12)
	Else
		dbSelectArea("SEE")
		RecLock("SEE",.F.)
		nTamFax	:= Len(AllTrim(SEE->EE_FAXATU))
		cNumDoc	:= StrZero(Val(Alltrim(SEE->EE_FAXATU)),nTamFax)
		SEE->EE_FAXATU	:= Soma1(cNumDoc,nTamFax)
		MsUnLock()
	EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Define a carteira de cobran鏰 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//	If Empty(SEE->EE_SUBCTA)
	If Empty(SEE->EE_CODCART)
		cCarteira	:= "101"
	Else
//		cCarteira	:= SEE->EE_SUBCTA
		cCarteira	:= SEE->EE_CODCART
	EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta o C骴igo de Barras e Linha Digit醰el �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	aBarra	:= GetBarra(	aDadBco[1],;
							aDadBco[3],;
							aDadBco[4],;
							aDadBco[5],;
							aDadBco[6],;
							cCarteira,;
							cNumDoc,;
							nSaldo,;
							SE1->E1_VENCREA,;
							SEE->EE_CODEMP ;
							)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Taxa de juros a ser utilizado no c醠culo de juros de mora �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	/*
	If !Empty(aDadBco[10])
		cMensag1	:= "Mora Di醨ia de R$ "+AllTrim(Transform( Round( ( nSaldo * (aDadBco[10]/100) ) / 30, 2), "@E 999,999,999.99"))
	Endif
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Taxa de multa a ser impressa no boleto �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If !Empty(aDadBco[11])
		cMensag2	:= "Multa por atraso no pagamento - " + AllTrim(Transform( aDadBco[11], "@E 999,999.99%"))
	EndIf
	*/
/*
	
	cMensag1 := "Multa de 10% ap髎 o vencimento."
	cMensag2 := "Juros de 5% ao m阺 pro rata ap髎 o vencimento."
*/

//	cMensag1 := "Multa de 2% ap髎 o vencimento."
//	cMensag1 := "Cobrar Mora di醨ia de "   + AllTrim(Transform( Round ( nSaldo * 0.01 / 30, 2 ) , "@E 999,999,999.99"))
//	cMensag2 := "Cobrar 5% de multa ap髎 o vencimento."
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� N鷐ero de dias para envio do t韙ulo ao cart髍io �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	/*
	If !Empty(aDadBco[12]) .AND. SA1->A1_PROTEST <> '2' 
		cMensag3	:= "Protestar ap髎 " + StrZero(aDadBco[12], 2) + " (" + AllTrim(Extenso(aDadBco[12],.T.)) + ") dias 鵷eis"
	EndIf
    */
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Alimenta array com os dados do t韙ulo �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	aDadTit[1]	:= SE1->E1_PREFIXO		// [1] Prefixo do T韙ulo
	aDadTit[2]	:= SE1->E1_NUM			// [2] N鷐ero do T韙ulo
	aDadTit[3]	:= SE1->E1_PARCELA		// [3] Parcela do T韙ulo
	aDadTit[4]	:= SE1->E1_TIPO			// [4] Tipo do t韙ulo
	aDadTit[5]	:= SE1->E1_EMISSAO		// [5] Data de Emiss鉶 do t韙ulo
	aDadTit[6]	:= SE1->E1_VENCREA  	// [6] Data de Vencimento do T韙ulo
	aDadTit[7]	:= SE1->E1_VENCREA		// [7] Data de Vencimento Real
	aDadTit[8]	:= nSaldo				// [8] Valor L韖uido do T韙ulo
	aDadTit[9]	:= aBarra[4]			// [9] C骴igo do Barras Formatado
	aDadTit[10]	:= cCarteira			// [10]Carteira de Cobran鏰
	aDadTit[11]	:= cMensag1				// [11]1a. Linha de Mensagem diversas
	aDadTit[12]	:= cMensag2				// [11]2a. Linha de Mensagem diversas
	aDadTit[13]	:= cMensag3				// [11]3a. Linha de Mensagem diversas
	aDadTit[14]	:= cMensag4				// [11]4a. Linha de Mensagem diversas
	aDadTit[15]	:= cMensag5				// [11]5a. Linha de Mensagem diversas
	aDadTit[16]	:= cMensag6				// [11]6a. Linha de Mensagem diversas
EndIf							
							
RestArea(aAreaAtu)

Return(lRet)



/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � GetBarra � C醠cula o c骴igo de barras, linha digit醰el e d韌ito do      罕�
北�             �          � nosso n鷐ero                                                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 20.01.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpC1 = C骴igo do Banco                                                 罕�
北�             � ExpC2 = N鷐ero da Ag阯cia                                               罕�
北�             � ExpC3 = D韌ito da Ag阯cia                                               罕�
北�             � ExpC4 = N鷐ero da Conta Corrente                                        罕�
北�             � ExpC5 = D韌ito da Conta Corrente                                        罕�
北�             � ExpC6 = Carteira                                                        罕�
北�             � ExpC7 = Nosso N鷐ero sem d韌ito                                         罕�
北�             � ExpN1 = Valor do T韙ulo                                                 罕�
北�             � ExpD1 = Data de Vencimento                                              罕�
北�             � ExpC8 = N鷐ero do Contrato                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpL1 = .T. montou os arrays corretamento, .F. n鉶 montou os arrays     罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es � Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function GetBarra(cBanco,cAgencia,cDigAgencia,cConta,cDigConta,cCarteira,cNNum,nValor,dVencto,cContrato)

Local cValorFinal	:= StrZero(Int(NoRound(nValor*100)),10)
Local cDvCB			:= 0
Local cDv			:= 0
Local cNN			:= ""
Local cNNForm		:= ""
Local cRN			:= ""
Local cCB			:= ""
Local cS			:= ""
Local cDvNN			:= "" 
Local cContra		:= "" 
Local cFator		:= StrZero(dVencto - CToD("07/10/97"),4)
Local cCpoLivre		:= Space(25)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//�                 Definicao do NOSSO N贛ERO E CAMPO LIVRE                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� BRASIL                                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If cBanco $ "001"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矯omposicao do Campo Livre (25 posi珲es)                              �
	//�                                                                     �
	//砈OMENTE PARA AS CARTEIRAS 16/18 (com conv阯ios de 6 posi珲es)        �
	//�20 a 25 - (06) - N鷐ero do Conv阯io                                  �
	//�26 a 42 - (17) - Nosso N鷐ero                                        �
	//�43 a 44 - (02) - Carteira de cobran鏰                                �
	//�                                                                     �
	//砈OMENTE PARA AS CARTEIRAS 17/18                                      �
	//�20 a 25 - (06) - Fixo 0                                              �
	//�26 a 32 - (07) - N鷐ero do conv阯io                                  �
	//�33 a 42 - (10) - Nosso Numero (sem o digito verificador)             �
	//�43 a 44 - (02) - Carteira de cobran鏰                                �
	//�                                                                     �
	//矯omposicao do Nosso N鷐ero                                           �
	//�01 a 06 - (06) - N鷐ero do Conv阯io (SEE->EE_CODEMP)                 �
	//�07 a 11 - (05) - Nosso N鷐ero (SEE->EE_FAXATU)                       �
	//�12 a 12 - (01) - D韌ito do Nosso N鷐ero (Modulo 11)                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Carteira 16/18 - Conv阯io com 6 posi鏾es                                �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If Len(AllTrim(cContrato)) > 6
		Cs		:= AllTrim(cContrato) + cNNum + cCarteira
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Carteira 17/18 - Conv阯io com mais de 6 posi鏾es                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Else
		Cs		:= "000000" + AllTrim(cContrato) + cNNum + cCarteira
	EndIf
	cDvNN		:= U_TCCalcDV( cBanco, cS )		//Modulo11(cS)
	cNN			:= AllTrim(cContrato) + cNNum + cDvNN
	cNNForm		:= AllTrim(cContrato) + cNNum
//	cNNForm		:= AllTrim(cContrato) + cNNum + "-" + cDvNN
	cCpoLivre	:= ""
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� BRADESCO                                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ElseIf 	cBanco $ "237"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矯omposicao do Campo Livre (25 posi珲es)                              �
	//�                                                                     �
	//�20 a 23 - (04) - Agencia cedente (sem o digito), completar com zeros �
	//�                 a esquerda se necessario	                        �
	//�24 a 25 - (02) - Carteira                                            �
	//�26 a 36 - (11) - Nosso Numero (sem o digito verificador)             �
	//�37 a 43 - (07) - Conta do cedente, sem o digito verificador, complete�
	//�                 com zeros a esquerda, se necessario                 �
	//�44 a 44 - (01) - Fixo "0"                                            �
	//�                                                                     �
	//矯omposicao do Nosso N鷐ero                                           �
	//�01 a 02 - (02) - N鷐ero da Carteira (SEE->EE_SUBCTA)                 �
	//�                 06 para Sem Registro 19 para Com Registro           �
	//�03 a 13 - (11) - Nosso N鷐ero (SEE->EE_FAXATU)                       �
	//�04 a 14 - (01) - D韌ito do Nosso N鷐ero (Modulo 11)                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cS			:= AllTrim(cCarteira) + cNNum
	cDvNN		:= U_TCCalcDV( cBanco, cS )			//Mod11237(cS)
	cNN			:= AllTrim(cCarteira) + cNNum + cDvNN
//	cNNForm		:= AllTrim(cCarteira) + "/"+ Substr(cNNum,1,2)+"/"+Substr(cNNum,3,9) + "-" + cDvnn
	cNNForm		:= AllTrim(cCarteira) + "/"+ Substr(cNNum,1,2)+Substr(cNNum,3,9) + "-" + cDvnn
	cCpoLivre	:= StrZero(Val(AllTrim(cAgencia)),4)+StrZero(Val(AllTrim(cCarteira)),2)+cNNum+StrZero(Val(AllTrim(cConta)),7)+"0"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� ITA�                                                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ElseIf cBanco $ "341"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矯omposicao do Campo Livre (25 posi珲es)                              �
	//�                                                                     �
	//�20 a 22 - (03) - Carteira                                            �
	//�23 a 30 - (08) - Nosso N鷐ero (sem o d韌ito verificador)             �
	//�31 a 31 - (01) - Digito verificador                                  �
	//�32 a 35 - (04) - Ag阯cia                                             �
	//�36 a 40 - (05) - Conta (sem o d韌ito verificador                     �
	//�41 a 41 - (01) - D韌ito verificador da conta                         �
	//�42 a 44 - (03) - Fixo "000"                                          �
	//�                                                                     �
	//矯omposicao do Nosso N鷐ero                                           �
	//砈e carteira for 126/131/146/150/168                                  �
	//�01 a 03 - (03) - Carteira                                            �
	//�04 a 11 - (08) - Nosso N鷐ero (EE_FAXATU)                            �
	//矰emais carteiras                                                     �
	//�01 a 04 - (04) - Ag阯cia sem d韌ito verificador                      �
	//�05 a 09 - (05) - Conta Corrente sem d韌ito verificador               �
	//�10 a 12 - (03) - Carteira                                            �
	//�13 a 20 - (08) - Nosso N鷐ero (EE_FAXATU)                            �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If cCarteira $ "126/131/146/150/168"
		cS			:=  AllTrim(cCarteira) + cNNum
	Else
		cS			:=  AllTrim(cAgencia) + AllTrim(cConta) + AllTrim(cCarteira) + cNNum
	EndIf
	If Mv_PAR15 == 2
		cDvNN		:= U_TCCalcDV( cBanco, cS )			//Modulo10(cS)
		cNN			:= AllTrim(cCarteira) + cNNum + cDvNN
	Else
		cDvNN		:= SubStr(cNNum,9,1)			//Modulo10(cS)
		cNNum		:= SubStr(cNNum,1,8)
		cNN			:= AllTrim(cCarteira) + cNNum + cDvNN
	EndIf	
	cNNForm		:= AllTrim(cCarteira) + "/"+ cNNum + "-" + cDvNN
	cCpoLivre	:= StrZero(Val(AllTrim(cCarteira)),3)+cNNum+cDvNN+StrZero(Val(Alltrim(cAgencia)),4)+StrZero(Val(AllTrim(cConta)),5)+cDigConta+"000"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� CITIBANK                                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ElseIf cBanco $ "745"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矯omposicao do Campo Livre (25 posi珲es)                              �
	//�                                                                     �
	//�20 a 20 - (01) - C骴igo do Produto (3=Cobran鏰 com/sem registro      �
	//�                 4=Cobran鏰 de seguro sem registro)                  �
	//�21 a 23 - (03) - Portif髄io 3 鷏timos d韌itos do campo c骴igo Empresa�
	//�                 Segundo Douglas (Citigroup) enviar neste campo o    �
	//�                 n鷐ero da carteira.                                 �
	//�                 O n鷐ero do contrato � chamado de Conta Cosmos e �  �
	//�                 formado por 10 posi珲es com A.BBBBBB.CC.D, onde     �
	//�                 A      = N鉶 utilizado                              �
	//�                 BBBBBB = Base                                       �
	//�                 CC     = Sequencia                                  �
	//�                 D      = D韌ito                                     �
	//�24 a 29 - (06) - Base (Contrato)                                     �
	//�30 a 31 - (02) - Sequencia (Contrato)                                �
	//�32 a 32 - (01) - D韌ito da conta Cosmos (Contrato)                   �
	//�33 a 44 - (12) - Nosso N鷐ero com d韌ito verificador                 �
	//�                                                                     �
	//矯omposicao do Nosso N鷐ero                                           �
	//�01 a 11 - (11) - Nosso N鷐ero (EE_FAXATU)                            �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cS			:= cNNum
	cDvNN		:= U_TCCalcDV( cBanco, cS )			//modulo11(cS)
	cNN			:= cNNum + cDvNN
	cNNForm		:= cNNum + "-" + cDvNN
	cCpoLivre	:= "3" + StrZero(Val(cCarteira),3) + SubStr(AllTrim(cContrato), 2, 9) + cNN  
	  
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Santander                                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�	
ElseIf cBanco $ "033"
	cCart	:= Alltrim(SEE->EE_CODCART)
	cContra	:= Alltrim(SEE->EE_CODEMP)
	If Mv_Par15 == 2 .Or. Len(AllTrim(cNNum)) < 8
		cS		:=  cCart + cNNum  
		cS		:=  cNNum  
	 	cDvnn	:= modulo11(cS)
		cNN		:= cCart + cNNum + '-' + cDvnn  
		cNNForm	:= cNNum + "-" +cDvnn 	//cCart + "/"+ 
	Else
	 	cDvnn	:= SubStr(cNNum,8,1)
	 	cNNum	:= SubStr(cNNum,1,7)
		cNN		:= cCart + cNNum + '-' + cDvnn  
		cNNForm	:= cNNum + "-" +cDvnn 	//cCart + "/"+ 
	EndIf
EndIf
	
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//�                  Definicao do D虶ITO CODIGO DE BARRAS                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If cBanco $ "001"
	cS		:= cBanco+"9"+cFator+cValorFinal+"000000"+Left(AllTrim(cNN),17)+AllTrim(cCarteira)
	cDvCB	:= Modulo11(cS) 
	
ElseIf cBanco $ "033"
                                                                                                                               
	cCpoLivre	:= "9"+alltrim(right(SEE->EE_CODEMP,7))+Strzero(val(cNNum),12)+AllTrim(cDvnn)+"0101"
//	cCpoLivre	:= "91327283"+Strzero(val(cNNum),12)+AllTrim(cDvnn)+"0101"
	
Else
	cS		:= cBanco+"9"+cFator+cValorFinal+cCpoLivre
	cDvCB	:= Modulo11(cS)
EndIf

If cBanco $ "001"
	cCB	:= cBanco+"9"+cDVCB+cFator+cValorFinal+"000000"+Left(AllTrim(cNN),17)+AllTrim(cCarteira) 

ElseIf cBanco $ "033"
	cS	:= cBanco+"9"+"8"+cFator+cValorFinal+cCpoLivre
	nDvCb   := Modulo11a(Substr(cS,1,4)+Substr(cS,6,39))
	cCB	:= cBanco+"9"+STR(nDVCb,1)+cFator+cValorFinal+cCpoLivre
Else
	cCB	:= cBanco+"9"+cDVCB+cFator+cValorFinal+cCpoLivre
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//�                  Definicao da LINHA DIGIT罺EL                           �
//� Campo 1       Campo 2        Campo 3        Campo 4   Campo 5           �
//� AAABC.CCCCX   CCCCC.CCCCCY   CCCCC.CCCCCZ   W	      UUUUVVVVVVVVVV    �
//衬哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� AAA                       = C骴igo do Banco na C鈓ara de Compensa玢o    �
//� B                         = C骴igo da Moeda, sempre 9                   �
//� CCCCCCCCCCCCCCCCCCCCCCCCC = Campo Livre                                 �
//� X                         = Digito Verificador do Campo 1               �
//� Y                         = Digito Verificador do Campo 2               �
//� Z                         = Digito Verificador do Campo 3               �
//� W                         = Digito Verificador do Codigo de Barras      �
//� UUUU                      = Fator de Vencimento                         �
//� VVVVVVVVVV                = Valor do T韙ulo                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� CALCULO DO D虶ITO VERIFICADOR DO CAMPO 1                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If cBanco $ "001|033"
	cS		:= cBanco + "9" +"9"  +Substr(cCB,20,5)
	cDv		:= modulo10(cS)
	cRN1	:= SubStr(cS, 1, 5) + "." + SubStr(cS, 7, 4) + cDv  
Else
	cS		:= cBanco + "9" +Substr(cCpoLivre,1,5)
	cDv		:= modulo10(cS)
	cRN1	:= SubStr(cS, 1, 5) + "." + SubStr(cS, 6, 4) + cDv
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� CALCULO DO D虶ITO VERIFICADOR DO CAMPO 2                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If cBanco $ "001"
	cS		:= Substr(cCB,25,10)
	cDv		:= modulo10(cS)
	cRN2	:= cS + cDv
	cRN2	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + cDv 
ElseIf cBanco $ "033"
	cS   := Substr(cCpoLivre,6,10)
	cDv  := modulo10(cS)
	cRN2 := cS + Alltrim(cDv)
	cRN2 := Substr(cRN2,1,3)+" "+Substr(cCpoLivre,9,7)+cDv
Else
	cS		:= Substr(cCpoLivre,6,10)
	cDv		:= modulo10(cS)
	cRN2	:= cS + cDv
	cRN2	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + cDv
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� CALCULO DO D虶ITO VERIFICADOR DO CAMPO 3                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If cBanco $ "001"
	cS		:= Substr(cCB,35,10)
	cDv		:= modulo10(cS)
	cRN3	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + cDv 
ElseIf cBanco $ "033"
	cS    := Substr(cCpoLivre,17,5)
	cDv   := modulo10(cS)
	cRN3  := cS + Alltrim(cDv)              
	cRN3  := Substr(cS,1,5)+" 0 "+"101" 
	cRN3  :=cRN3+modulo10(cRN3) 
Else
	cS		:= Substr(cCpoLivre,16,10)
	cDv		:= modulo10(cS)
	cRN3	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + cDv
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� CALCULO DO CAMPO 4                                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If cBanco $ "033"
	cRN4   := Substr(cCb,5,1)
Else	
	cRN4	:= cDvCB
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� CALCULO DO CAMPO 5                                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
cRN5	:= cFator + cValorFinal

cRN		:= cRN1 + " " + cRN2 + ' '+ cRN3 + ' ' + cRN4 + ' ' + cRN5

Return({cCB,cRN,cNNum,cNNForm,cDvNN})



/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � TCCalcDV � Efetua o c醠culo do d韌ito verificador do nosso n鷐ero       罕�
北�             �          �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 08.02.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpC1 = C骴igo do Banco                                                 罕�
北�             � ExpC2 = Nosso N鷐ero                                                    罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpC3 = D韌ito Verificador                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es �                                                                         罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
User Function TCCalcDV( cBanco, cNNum )

cRetorno	:= ""

If cBanco $ "001#745"
	cRetorno	:= Modulo11( cNNum )
ElseIf cBanco $ "237"
	cRetorno	:= Mod11237( cNNum )
ElseIf cBanco $ "341"
	cRetorno	:= Modulo10( cNNum ) 
ElseIf cBanco $ "033"
	cRetorno    := Mod11033( cNNum )	
EndIf

Return( cRetorno )




/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � Modulo10 � Efetua o c醠culo do d韌ito veririficador com base 10         罕�
北�             �          �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 23.01.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpC1 = String com o c骴igo a ser calculado                             罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpC1 = String com o D韌ito Verificador                                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es �                                                                         罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Modulo10(cData)

Local L	:= Len(cData)
Local D	:= 0
Local P := 0
Local B	:= .T.

While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		EndIf
	EndIf
	D := D + P
	L := L - 1
	B := !B
EndDo
D := 10 - (Mod(D,10))
If D = 10
	D := 0
EndIf

Return(AllTrim(Str(D,1)))



/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � Modulo11 � Efetua o c醠culo do d韌ito veririficador com base 11         罕�
北�             �          �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 23.01.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpC1 = String com o c骴igo a ser calculado                             罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpC1 = String com o D韌ito Verificador                                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es �                                                                         罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Modulo11(cData)

Local L	:= Len(cData)
Local D	:= 0
Local P	:= 1

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	EndIf
	L := L - 1
EndDo
If mod(D,11) == 10
	D := 1
ElseIf mod(D,11) == 0 .OR. mod(D,11) == 1
	D := 0
Else
	D := 11 - (mod(D,11))
EndIf

Return(AllTrim(Str(D,1)))



/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � Mod11237 � Efetua o c醠culo do d韌ito veririficador com base 7 Bradesco 罕�
北�             �          �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 23.01.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpC1 = String com o c骴igo a ser calculado                             罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpC1 = String com o D韌ito Verificador                                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es �                                                                         罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Mod11237(cData)

Local nResult	:= 0
Local nSoma		:= 0
Local i			:= 0
Local nTam		:= 13
Local nDc		:= 0
Local nAlg		:= 2
Local nCalNum	:= space(13)

nCalNum:= cData

For i  := nTam To 1 Step -1
	nSoma   := Val(Substr(nCalNum,i,1))*nAlg
	nResult := nResult + nSoma
	nAlg    := nAlg + 1   
	If nAlg > 7
		nAlg := 2
	Endif
Next i

nDC  := MOD(nResult,11)   
cDig := 11 - nDc

IF nDC == 1
	cDig := "P"
ElseIf nDC == 0
   cDig := 0
   cDig := STR(cDig,1) 	
Else
	cDig := STR(cDig,1)
EndIF
  
Return(Alltrim(cDig))  


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  Modulo11a  �         Fl醰io Macieira    � Data �  09/05/13   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �  Dig codigo barra Santander                                罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Modulo11a(cData)  

Local nResult:= 0
Local nSoma  := 0
Local cDc    := ""
Local i      := 0
Local nTam   := Len(cData)
Local nDc    := 0
Local nAlg   := 2

nCalNum:= cData

For i  := nTam To 1 Step -1
	nSoma   := Val(Substr(nCalNum,i,1))*nAlg
	nResult := nResult + nSoma
	nAlg    := nAlg + 1   
	If nAlg > 9
		nAlg := 2
	Endif
Next i

nResult = nResult*10

nDC  := MOD(nResult,11)   
cDig := nDc

If cDig == 0 .Or. cDig == 1 .or. cDig > 9   
   cDig := 1
EndIf

Return(cDig)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  Mod11033           矲l醰io Macieira     � Data �  09/05/13   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � modulo 11 com base 7 para Santander                        罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
User Function Mod11033(cData) // modulo 11 com base 7 para Santander              

Local nResult:= 0
Local nSoma  := 0
Local cDc    := ""
Local i      := 0
Local nTam   := 13
Local nDc    := 0
Local nAlg   := 2
Local nCalNum:= space(13)

nCalNum:= cData

For i  := nTam To 1 Step -1
	nSoma   := Val(Substr(nCalNum,i,1))*nAlg
	nResult := nResult + nSoma
	nAlg    := nAlg + 1   
	If nAlg > 7
		nAlg := 2
	Endif
Next i

nDC  := MOD(nResult,11)   
cDig := 11 - nDc

IF nDC == 1
	cDig := "P"
ElseIf nDC == 0
   cDig := 0
   cDig := STR(cDig,1) 	
Else
	cDig := STR(cDig,1)
EndIF
  
Return(Alltrim(cDig))  

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � TCImpBol � Efetua a impress鉶 do boleto banc醨io                        罕�
北�             �          �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 20.01.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpO1 = Objeto print                                                    罕�
北�             � ExpA1 = Array com os dados da Empresa                                   罕�
北�             � ExpA2 = Array com os dados do Banco                                     罕�
北�             � ExpA3 = Array com os dados do T韙ulo                                    罕�
北�             � ExpA4 = Array com os dados do Cliente                                   罕�
北�             � ExpA5 = Array com os dados do C骴igo de Barras                          罕�
北�             � ExpN1 = Tipo de configura玢o a ser utilizado (1=Polegadas/2=Cent韒etros)罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � Nil                                                                     罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es �                                                                         罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
User Function TCImpBol(oPrint,aDadEmp,aDadBco,aDadTit,aDadCli,aBarra,nTpImp)

Local oFont8
Local oFont10
Local oFont11c
Local oFont14
Local oFont14n
Local oFont15
Local oFont15n
Local oFont16n
Local oFont20
Local oFont21
Local oFont24
Local nLin			:= 0
Local nLoop			:= 0
Local cBmp			:= ""
Local cStartPath	:= AllTrim(GetSrvProfString("StartPath",""))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砅arametro que verifica se o Banco ser� o Cedente do Titulo, atrav閟 dos campos  �
//矯od. Banco, Ag阯cia e N鷐ero de conta, que devem ser informados sequencialmente �
//硁o parametro.                                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁          
Local cCedente  := ''//IF(ValType(GetMv("MC_BCEDEN")) <> "C","",ALLTRIM(GetMv("MC_BCEDEN")))   
Local cAvalista := ""

SE1->(dbSetOrder(1), dbSeek(xFilial("SE1")+aDadTit[1]+aDadTit[2]+aDadTit[3]))
SA1->(dbSetOrder(1), dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

Private cFilename := 'BOL'+AllTrim(SE1->E1_NUM)+AllTrim(E1_PARCELA)	//Criatrab(Nil,.F.)

MAKEDIR('C:\TEMP')
	lAdjustToLegacy := .T.   //.F.
	lDisableSetup  := .T.
	oPrint := FWMSPrinter():New(cFilename, IMP_PDF, lAdjustToLegacy, , lDisableSetup)
	oPrint:Setup()
	oPrint:SetResolution(78)
	//oPrint:SetPortrait() // ou SetLandscape()
	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4) 
	oPrint:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior 
	oPrint:cPathPDF := "C:\TEMP\" // Caso seja utilizada impress鉶 em IMP_PDF 
	cDiretorio := oPrint:cPathPDF

If ALLTRIM( SA6->A6_COD + alltrim(SA6->A6_AGENCIA) + SA6->A6_NUMCON ) $ cCedente
	cAvalista := SM0->M0_NOMECOM
Endif

If Right(cStartPath,1) <> "\"
	cStartPath+= "\"
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta string com o caminho do logotipo do banco �
//� O Tamanho da figura tem que ser 381 x 68 pixel  �
//� para que a impress鉯 sai correta                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
cBmp	:= cStartPath+'logosant.bmp' //aDadBco[9]

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define as fontes a serem utilizadas �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oFont8		:= TFont():New("Arial",			9,08,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10		:= TFont():New("Arial",			9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11c	:= TFont():New("Courier New",	9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14		:= TFont():New("Arial",			9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n	:= TFont():New("Arial",			9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15		:= TFont():New("Arial",			9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n	:= TFont():New("Arial",			9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16n	:= TFont():New("Arial",			9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont20		:= TFont():New("Arial",			9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21		:= TFont():New("Arial",			9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24		:= TFont():New("Arial",			9,24,.T.,.T.,5,.T.,5,.T.,.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪目
//� Inicia uma nova p醙ina �
//滥哪哪哪哪哪哪哪哪哪哪哪馁 
oPrint:StartPage()

nLin:= nLin - 620

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define o Segundo Bloco - Recibo do Sacado �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oPrint:Line (nLin+0690,0100,nLin+0690,2300)														// Quadro
oPrint:Line (nLin+0690,0500,nLin+0610,0500)														// Quadro
oPrint:Line (nLin+0690,0710,nLin+0610,0710)														// Quadro

//If !Empty(aDadBco[9])
	oPrint:SayBitMap(nLin+0624,0100,cBmp,350,060)													// Logotipo do Banco
//Else
//	oPrint:Say  (nLin+0644,0100,	aDadBco[8],											oFont14)	// Nome do Banco
//EndIf
oPrint:Say  (nLin+0655,0513,	aDadBco[1]+"-"+aDadBco[2],								oFont21)	// Numero do Banco + D韌ito
//oPrint:Say  (nLin+0644,0755,	aBarra[2],												oFont15n)	// Linha Digitavel do Codigo de Barras
oPrint:Say  (nLin+0664,1900,	"Recibo do Pagador",									oFont10)	// Texto Fixo

oPrint:Line (nLin+0790,0100,nLin+0790,2300)														// Quadro
oPrint:Line (nLin+0890,0100,nLin+0890,2300)														// Quadro
oPrint:Line (nLin+0960,0100,nLin+0960,2300)														// Quadro
oPrint:Line (nLin+1030,0100,nLin+1030,2300)														// Quadro

oPrint:Line (nLin+0890,0500,nLin+1030,0500)														// Quadro
oPrint:Line (nLin+0960,0750,nLin+1030,0750)														// Quadro
oPrint:Line (nLin+0890,1000,nLin+1030,1000)														// Quadro
oPrint:Line (nLin+0890,1300,nLin+0960,1300)														// Quadro
oPrint:Line (nLin+0890,1480,nLin+1030,1480)														// Quadro

oPrint:Say  (nLin+0710,0100 ,	"Local de Pagamento",									oFont8)		// Texto Fixo  

If Alltrim(SA6->A6_COD) == "001"
	oPrint:Say  (nLin+0725,0400 ,	"Pag醰el em qualquer banco at� o vencimento.", oFont10)
Else																		
	oPrint:Say  (nLin+0725,0400 ,	"AT� O VENCIMENTO, PREFERENCIALMENTE NO "+Upper(aDadBco[8]),;
																						oFont10)	// 1a. Linha de Local Pagamento
	oPrint:Say  (nLin+0765,0400 ,	"AP覵 O VENCIMENTO, SOMENTE NO "+Upper(aDadBco[8]),;
																			 			oFont10)	// 2a. Linha de Local Pagamento    
EndIf																			 			

oPrint:Say  (nLin+0710,1810,	"Vencimento",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0750,2000,	StrZero(Day(aDadTit[6]),2) +"/"+;
								StrZero(Month(aDadTit[6]),2) +"/"+; 
								StrZero(Year(aDadTit[6]),4),					 		oFont11c)	// Vencimento

oPrint:Say  (nLin+0810,0100,	"Benefici醨io",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0850,0100,	AllTrim(aDadEmp[1])+If(!Empty(cAvalista),""," - CNPJ: "+Transform(aDadEmp[9], "@R 99.999.999/9999-99")),;
																						oFont10)	// Nome + CNPJ

oPrint:Say  (nLin+0810,1810,	"Ag阯cia/C骴igo Benefici醨io",     						oFont8)		// Texto Fixo
oPrint:Say  (nLin+0850,1900,	AllTrim(aDadBco[15]),									oFont11c)	// Agencia + C骴.Cedente + D韌ito


oPrint:Say  (nLin+0910,0100,	"Data do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,0150,	StrZero(Day(aDadTit[5]),2)+"/"+ ;
								StrZero(Month(aDadTit[5]),2)+"/"+ ;
								Right(Str(Year(aDadTit[5])),4),						oFont10)	// Data do Documento

oPrint:Say  (nLin+0910,0505,	"Nro.Documento",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,0605,	aDadTit[1]+aDadTit[2]+"/"+aDadTit[3],					oFont10)	// Prefixo + Numero + Parcela

oPrint:Say  (nLin+0910,1005,	"Esp閏ie Doc.",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,1055,	aDadBco[14],											oFont10)	// Tipo do Titulo

oPrint:Say  (nLin+0910,1305,	"Aceite",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,1400,	"N",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+0910,1485,	"Data do Processamento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,1550,	StrZero(Day(dDataBase),2)+"/"+ ;
								StrZero(Month(dDataBase),2)+"/"+ ;
								StrZero(Year(dDataBase),4),								oFont10)	// Data impressao

oPrint:Say  (nLin+0910,1810,	"Nosso N鷐ero",											oFont8)		// Texto Fixo 
  
//If Alltrim(SA6->A6_COD)$ "033"
//	oPrint:Say  (nLin+0940,1900,	SubStr(aBarra[4],5,9),								oFont11c)	// Nosso N鷐ero  
//Else	
	oPrint:Say  (nLin+0940,1900,	aBarra[4],											oFont11c)	// Nosso N鷐ero
//EndIf 

oPrint:Say  (nLin+0980,0100,	"Uso do Banco",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+1010,0150,	aDadBco[13],											oFont10)	// Texto Fixo

oPrint:Say  (nLin+0980,0505,	"Carteira",												oFont8)		// Texto Fixo  

If Alltrim(SA6->A6_COD)$ "033"
   oPrint:Say  (nLin+1010,0555,	aDadTit[10]+" - RCR",											oFont10)	// Carteira  
Else	
	oPrint:Say  (nLin+1010,0555,	aDadTit[10],											oFont10)	// Carteira
EndIf	

oPrint:Say  (nLin+0980,0755,	"Esp閏ie",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+1010,0805,	"R$",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+0980,1005,	"Quantidade",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0980,1485,	"Valor",											 	oFont8)		// Texto Fixo

oPrint:Say  (nLin+0980,1810,	"Valor do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+1010,1900,	Transform(aDadTit[8],"@E 9999,999,999.99"),				oFont11c)	// Valor do T韙ulo

oPrint:Say  (nLin+1050,0100,	"Instru珲es (Todas informa珲es deste bloqueto s鉶 de exclusiva responsabilidade do benefici醨io)",;
																						oFont8)		// Texto Fixo
oPrint:Say  (nLin+1100,0100,	"Juros / Mora por dia : 0,33%,  R$ "+  alltrim(	Transform((0.0033*aDadTit[8]),"@E 9999,999,999.99"))+" ao dia ",	oFont10)	// 1a Linha Instru玢o
oPrint:Say  (nLin+1150,0100,	"Protesto Autom醫ico ap髎 5 dias de atraso",											oFont10)	// 2a. Linha Instru玢o
oPrint:Say  (nLin+1200,0100,	"Dep髎ito em conta n鉶 quita o boleto.",											oFont10)	// 3a. Linha Instru玢o
oPrint:Say  (nLin+1250,0100,	"D鷙idas: envie e-mail para contasareceber@vitasons.com.br"	 ,										oFont10)	// 4a. Linha Instru玢o
//oPrint:Say  (nLin+1300,0100,	aDadTit[15],											oFont10)	// 5a. Linha Instru玢o
//oPrint:Say  (nLin+1350,0100,	aDadTit[16],											oFont10)	// 6a. Linha Instru玢o

oPrint:Say  (nLin+1050,1810,	"(-)Desconto/Abatimento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+1120,1810,	"(-)Outras Dedu珲es",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+1190,1810,	"(+)Mora/Multa",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+1260,1810,	"(+)Outros Acr閟cimos",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+1330,1810,	"(=)Valor Cobrado",										oFont8)		// Texto Fixo

oPrint:Say  (nLin+1400,0100,	"Pagador",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+1430,0200,	aDadCli[3],												oFont10)	// Nome do Cliente
//oPrint:Say  (nLin+1430,0200,	" ("+aDaDCli[1]+"-"+aDadCli[2]+") "+aDadCli[3],		oFont10)	// C骴igo + Nome do Cliente

If aDadCli[6] = "J"
	oPrint:Say  (nLin+1430,1850,"CNPJ: "+Transform(aDadCli[4],"@R 99.999.999/9999-99"),;
																				  		oFont10)	// CGC
Else
	oPrint:Say  (nLin+1430,1850,"CPF: "+Transform(aDadCli[4],"@R 999.999.999-99"),;
																						oFont10)	// CPF
EndIf

oPrint:Say  (nLin+1483,0200,	AllTrim(aDadCli[7])+" "+AllTrim(aDadCli[8]),			oFont10)	// Endere鏾 + Bairro
//oPrint:Say	(nLin+1483,1850,	"Entrega: "+aDadCli[12],								oFont10)	// Forma de Envio do Boleto

oPrint:Say  (nLin+1536,0200,	Transform(aDadCli[11],"@R 99999-999")+" - "+ ;
										AllTrim(aDadCli[9])+" - "+ ;
										AllTrim(aDadCli[10]),							oFont10)	// CEP + Cidade + Estado

oPrint:Say  (nLin+1589,1850,	aBarra[4],												oFont10)	// Nosso N鷐ero

oPrint:Say  (nLin+1605,0100,	"Pagador/Avalista"+ if( !empty(cAvalista)," - " + Rtrim(cAvalista),""),						oFont8)		// Texto Fixo
oPrint:Say  (nLin+1645,1500,	"Autentica玢o Mec鈔ica",								oFont8)		// Texto Fixo

oPrint:Line (nLin+0690,1800,nLin+1380,1800)														// Quadro
oPrint:Line (nLin+1100,1800,nLin+1100,2300)														// Quadro
oPrint:Line (nLin+1170,1800,nLin+1170,2300)														// Quadro
oPrint:Line (nLin+1240,1800,nLin+1240,2300)														// Quadro
oPrint:Line (nLin+1310,1800,nLin+1310,2300)														// Quadro
oPrint:Line (nLin+1380,0100,nLin+1380,2300)														// Quadro
oPrint:Line (nLin+1620,0100,nLin+1620,2300)														// Quadro

//谀哪哪哪哪哪哪哪哪哪哪目
//� Pontilhado separador �
//滥哪哪哪哪哪哪哪哪哪哪馁
//nLin	:= 100
nLin	:= 010

nLin:= nLin - 740

For nLoop := 100 To 2300 Step 50
	oPrint:Line(nLin+1860, nLoop, nLin+1860, nLoop+30)												// Linha Pontilhada
Next nI
                 

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define o Terceiro Bloco - Ficha de Compensa玢o �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oPrint:Line (nLin+1980,0100,nLin+1980,2300)														// Quadro
oPrint:Line (nLin+1980,0500,nLin+1900,0500)														// Quadro
oPrint:Line (nLin+1980,0710,nLin+1900,0710)														// Quadro

//If !Empty(aDadBco[9])
	oPrint:SayBitMap(nLin+1914,0100,cBmp,350,060)													// Logotipo do Banco 	
//Else
//	oPrint:Say  (nLin+1934,100,	aDadBco[8],												oFont14)	// Nome do Banco
//EndIf
oPrint:Say  (nLin+1945,0533,	aDadBco[1]+"-"+aDadBco[2],								oFont21)	// Numero do Banco + D韌ito
oPrint:Say  (nLin+1954,0755,	aBarra[2],												oFont15n)	// Linha Digitavel do Codigo de Barras

oPrint:Line (nLin+2080,100,nLin+2080,2300 )														// Quadro
oPrint:Line (nLin+2180,100,nLin+2180,2300 )														// Quadro
oPrint:Line (nLin+2250,100,nLin+2250,2300 )														// Quadro
oPrint:Line (nLin+2320,100,nLin+2320,2300 )														// Quadro

oPrint:Line (nLin+2180,0500,nLin+2320,0500)														// Quadro
oPrint:Line (nLin+2250,0750,nLin+2320,0750)														// Quadro
oPrint:Line (nLin+2180,1000,nLin+2320,1000)														// Quadro
oPrint:Line (nLin+2180,1300,nLin+2250,1300)														// Quadro
oPrint:Line (nLin+2180,1480,nLin+2320,1480)														// Quadro

oPrint:Say  (nLin+2000,0100,	"Local de Pagamento",									oFont8)		// Texto Fixo  

If Alltrim(SA6->A6_COD) == "001"
	oPrint:Say  (nLin+2015,0400,	"Pag醰el em qualquer banco at� o vencimento.",  	oFont10)	// Texto Fixo 
Else 	
	oPrint:Say  (nLin+2015,0400,	"AT� O VENCIMENTO, PREFERENCIALMENTE NO "+aDadBco[8],	oFont10)	// Texto Fixo
	oPrint:Say  (nLin+2055,0400 ,	"AP覵 O VENCIMENTO, SOMENTE NO "+aDadBco[8],			oFont10)	// Texto Fixo 

EndIf
           
oPrint:Say  (nLin+2000,1810,	"Vencimento",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2040,1900,	StrZero(Day(aDadTit[6]),2)+"/"+;
								StrZero(Month(aDadTit[6]),2)+"/"+;
								StrZero(Year(aDadTit[6]),4), 							oFont11c)	// Vencimento
                                                 
oPrint:Say  (nLin+2100,0100,	"Benefici醨io",   											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2140,0100,	AllTrim(aDadEmp[1])+If(!Empty(cAvalista),""," - CNPJ: "+Transform(aDadEmp[9], "@R 99.999.999/9999-99")),;
																						oFont10)	// Nome + CNPJ

oPrint:Say  (nLin+2100,1810,	"Ag阯cia/C骴igo Benefici醨io",   							oFont8)		// Texto Fixo
oPrint:Say  (nLin+2140,1900,	AllTrim(aDadBco[15]),									oFont11c)	// Agencia + C骴.Cedente + D韌ito


oPrint:Say  (nLin+2200,0100,	"Data do Documento",									oFont8)		// Texto Fixo
oPrint:Say	(nLin+2230,0100, 	StrZero(Day(aDadTit[5]),2)+"/"+ ;
								StrZero(Month(aDadTit[5]),2)+"/"+ ;
								StrZero(Year(aDadTit[5]),4),		 					oFont10)	// Vencimento

oPrint:Say  (nLin+2200,0505,	"Nro.Documento",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,0605,	aDadTit[1]+aDadTit[2]+aDadTit[3],						oFont10)	// Prefixo + Numero + Parcela

oPrint:Say  (nLin+2200,1005,	"Esp閏ie Doc.",						   					oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,1050,	aDadBco[14],											oFont10)	//Tipo do Titulo

oPrint:Say  (nLin+2200,1305,	"Aceite",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,1400,	"N",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+2200,1485,	"Data do Processamento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,1550,	StrZero(Day(dDataBase),2)+"/"+ ;
								StrZero(Month(dDataBase),2)+"/"+ ;
								StrZero(Year(dDataBase),4),								oFont10)	// Data impressao

oPrint:Say  (nLin+2200,1810,	"Nosso N鷐ero",											oFont8)		// Texto Fixo   

//If Alltrim(SA6->A6_COD)$ "033"
//	oPrint:Say  (nLin+2230,1900,	SubStr(aBarra[4],5,9),								oFont11c)	// Nosso N鷐ero  
//Else	
	oPrint:Say  (nLin+2230,1900,	aBarra[4],											oFont11c)	// Nosso N鷐ero
//EndIf

oPrint:Say  (nLin+2270,0100,	"Uso do Banco",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2300,0150,	aDadBco[13],											oFont10)	// Texto Fixo

oPrint:Say  (nLin+2270,0505,	"Carteira",												oFont8)		// Texto Fixo 

If Alltrim(SA6->A6_COD)$ "033"
	oPrint:Say  (nLin+2300,0555,	aDadTit[10]+" - RCR",								oFont10)
Else	
	oPrint:Say  (nLin+2300,0555,	aDadTit[10],										oFont10) 
EndIf	

oPrint:Say  (nLin+2270,0755,	"Esp閏ie",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+2300,0805,	"R$",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+2270,1005,	"Quantidade",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2270,1485,	"Valor",												oFont8)		// Texto Fixo

oPrint:Say  (nLin+2270,1810,	"Valor do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+2300,1900,	Transform(aDadTit[8], "@E 9999,999,999.99"),			oFont11c)	// Valor do Documento

oPrint:Say  (nLin+2340,0100,	"Instru珲es (Todas informa珲es deste bloqueto s鉶 de exclusiva responsabilidade do benefici醨io)",;
																						oFont8)		// Texto Fixo
oPrint:Say  (nLin+1100,0100,	"Juros / Mora por dia : 0,33%,  R$ "+  alltrim(	Transform((0.0033*aDadTit[8]),"@E 9999,999,999.99"))+" ao dia ",	oFont10)	// 1a Linha Instru玢o
oPrint:Say  (nLin+1150,0100,	"Protesto Autom醫ico ap髎 5 dias de atraso",											oFont10)	// 2a. Linha Instru玢o
oPrint:Say  (nLin+1200,0100,	"Dep髎ito em conta n鉶 quita o boleto.",											oFont10)	// 3a. Linha Instru玢o
oPrint:Say  (nLin+1250,0100,	"D鷙idas: envie e-mail para contasareceber@vitasons.com.br"	,										oFont10)	// 4a. Linha Instru玢o
//oPrint:Say  (nLin+2550,0100,	aDadTit[14],											oFont10)	// 4a. Linha Instru玢o
//oPrint:Say  (nLin+2600,0100,	aDadTit[15],											oFont10)	// 5a. Linha Instru玢o
//oPrint:Say  (nLin+2650,0100,	aDadTit[16],											oFont10)	// 6a. Linha Instru玢o

oPrint:Say  (nLin+2340,1810,	"(-)Desconto/Abatimento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+2410,1810,	"(-)Outras Dedu珲es",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+2480,1810,	"(+)Mora/Multa",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+2550,1810,	"(+)Outros Acr閟cimos",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+2620,1810,	"(=)Valor Cobrado",										oFont8)		// Texto Fixo

oPrint:Say  (nLin+2690,0100,	"Pagador",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+2700,0200,	aDadCli[3],												oFont10)	// Nome Cliente 
//oPrint:Say  (nLin+2700,0200,	" ("+aDadCli[1]+"-"+aDadCli[2]+") "+aDadCli[3],		oFont10)	// Nome Cliente + C骴igo

If aDadCli[6] = "J"
	oPrint:Say  (nLin+2700,1850,	"CNPJ: "+Transform(aDadCli[4],"@R 99.999.999/9999-99"),			oFont10)	// Endere鏾
Else
	oPrint:Say  (nLin+2700,1850,	"CPF: "+Transform(aDadCli[4],"@R 999.999.999-99"),			oFont10)	// Endere鏾
EndIf

oPrint:Say  (nLin+2753,0200,	Alltrim(aDadCli[7])+" "+AllTrim(aDadCli[8]),			oFont10)	// Endere鏾
oPrint:Say  (nLin+2806,0200,	Transform(aDadCli[11],"@R 99999-999")+" - "+;
								AllTrim(aDadCli[9])+" - "+AllTrim(aDadCli[10]),		oFont10)	// CEP + Cidade + Estado

oPrint:Say  (nLin+2806,1850,	aBarra[4],												oFont10)	// Carteira + Nosso N鷐ero

oPrint:Say  (nLin+2855,0100,	"Pagador/Avalista" + if( !empty(cAvalista)," - " + Rtrim(cAvalista),""), oFont8)		// Texto Fixo + Sacador Avalista
oPrint:Say  (nLin+2895,1500,	"Autentica玢o Mec鈔ica - Ficha de Compensa玢o",			oFont8)		// Texto Fixo

oPrint:Line (nLin+1980,1800,nLin+2670,1800)														// Quadro
oPrint:Line (nLin+2390,1800,nLin+2390,2300)														// Quadro
oPrint:Line (nLin+2460,1800,nLin+2460,2300)														// Quadro
oPrint:Line (nLin+2530,1800,nLin+2530,2300)														// Quadro
oPrint:Line (nLin+2600,1800,nLin+2600,2300)														// Quadro
oPrint:Line (nLin+2670,0100,nLin+2670,2300)														// Quadro
oPrint:Line (nLin+2870,0100,nLin+2870,2300)														// Quadro

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Se Impress鉶 em polegadas �
//� Guarabira                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nTpImp == 1
	oPrint:FwMSBAR("INT25" ,52,1   ,aBarra[1],oPrint,.F.   ,Nil  ,Nil  ,0.017     ,1   ,Nil    ,Nil,"A"  ,.F. ) //datasupri
Else        
	oPrint:FwMSBAR("INT25" ,52,1   ,aBarra[1],oPrint,.F.   ,Nil  ,Nil  ,0.017     ,1   ,Nil    ,Nil,"A"  ,.F. ) //datasupri
EndIf

oPrint:EndPage() // Finaliza a p醙ina
oPrint:Preview()     // Visualiza antes de imprimir

SE1->(dbSetOrder(1), dbSeek(xFilial("SE1")+aDadTit[1]+aDadTit[2]+aDadTit[3]))
SA1->(dbSetOrder(1), dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

cArquivo := 'C:\TEMP\'+cFilename+'.PDF' //AllTrim('\system\bol'+SE1->E1_NUM+"_pag1.jpg")
Return(Nil)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � TCArqRem � Retorna conte鷇os para o arquivo de remessa dos bancos       罕�
北�             �          �                                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 08.02.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpC1 = nome do campo que dever� ser retornado                          罕�
北�             � ExpN1 = Tamanho do campo                                                罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpC1 = String para preenchimento do campo                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es � Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
User Function TCCobRem( cBanco, cCampo, nTamanho )

Local cRetorno	:= Space(nTamanho)
Local nAbatim	:= 0
Local nValLiq	:= 0

Do Case
	Case cCampo == "IDEMPRESA"
		If cBanco == "745"
			cRetorno	:= SubStr(SEE->EE_CODEMP,2,7)
			cRetorno	+= SubStr(SEE->EE_CODEMP,3,6)
			cRetorno	+= SubStr(SEE->EE_CODEMP,8,3)
			cRetorno	+= "0"
			cRetorno	+= SEE->EE_SUBCTA
		EndIf
	Case cCampo == "VLRLIQ"
		nAbatim		:= SomaAbat(	SE1->E1_PREFIXO,;
									SE1->E1_NUM,;
									SE1->E1_PARCELA,;
									"R",;
									SE1->E1_MOEDA,;
									dDataBase,;
									SE1->E1_CLIENTE,;
									SE1->E1_LOJA )
		nValLiq		:= SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE - nAbatim
		cRetorno	:= StrZero( ( nValLiq * 100 ), nTamanho )
	Case cCampo == "VLRJUR"
		nValLiq		:= SE1->E1_VALJUR
		cRetorno	:= StrZero( ( nValLiq * 100 ), nTamanho )
	Case cCampo == "NNUMERO"
		cRetorno	:= AllTrim(SE1->E1_NUMBCO)
		cRetorno	+= U_TCCalcDV( cBanco, AllTrim( SE1->E1_NUMBCO ) )
	Case cCampo == "RAZAO"
		cRetorno	:= AllTrim( U_RetAcent( SA1->A1_NOME ) )
		cRetorno	:= cRetorno + Space( nTamanho - Len( cRetorno ) )
		cRetorno	:= Left( cRetorno, nTamanho )
	Case cCampo == "ENDERECO"
		If !Empty(SA1->A1_ENDCOB) .And. !( "O MESMO" $ SA1->A1_ENDCOB )
			cRetorno	:= AllTrim( U_RetAcent( SA1->A1_ENDCOB ) )
		Else
			cRetorno	:= AllTrim( U_RetAcent( SA1->A1_END ) )
		EndIf
		cRetorno	:= cRetorno + Space( nTamanho - Len( cRetorno ) )
		cRetorno	:= Left( cRetorno, nTamanho )
	Case cCampo == "BAIRRO"
		If !Empty(SA1->A1_BAIRROC)
			cRetorno	:= AllTrim( U_RetAcent( SA1->A1_BAIRROC ) )
		Else
			cRetorno	:= AllTrim( U_RetAcent( SA1->A1_BAIRRO ) )
		EndIf
		cRetorno	:= cRetorno + Space( nTamanho - Len( cRetorno ) )
		cRetorno	:= Left( cRetorno, nTamanho )
	Case cCampo == "CEP"
		If !Empty(SA1->A1_CEPC)
			cRetorno	:= AllTrim( SA1->A1_CEPC )
		Else
			cRetorno	:= AllTrim( SA1->A1_CEP )
		EndIf
		cRetorno	:= cRetorno + Space( nTamanho - Len( cRetorno ) )
		cRetorno	:= Left( cRetorno, nTamanho )
	Case cCampo == "CIDADE"
		If !Empty(SA1->A1_MUNC)
			cRetorno	:= AllTrim( U_RetAcent( SA1->A1_MUNC ) )
		Else
			cRetorno	:= AllTrim( U_RetAcent( SA1->A1_MUN ) )
		EndIf
		cRetorno	:= cRetorno + Space( nTamanho - Len( cRetorno ) )
		cRetorno	:= Left( cRetorno, nTamanho )
	Case cCampo == "ESTADO"
		If !Empty(SA1->A1_ESTC)
			cRetorno	:= AllTrim( SA1->A1_ESTC )
		Else
			cRetorno	:= AllTrim( SA1->A1_EST )
		EndIf
		cRetorno	:= cRetorno + Space( nTamanho - Len( cRetorno ) )
		cRetorno	:= Left( cRetorno, nTamanho )
	OtherWise
		cRetorno	:= Space(nTamanho)
EndCase

Return( cRetorno )


/*


al cMensag1	:= ""
Local cMensag2	:= ""
Local cMensag3	:= ""
Local cMensag4	:= ""
Local cMensag5	:= ""
Local cMensag6	:= ""
Local lSaldo	:= SuperGetMV( "TC_VLRBOL", .F., .T. )
Local cCedente  := '' //IF(ValType(GetMv("MC_BCEDEN")) <> "C","",ALLTRIM(GetMv("MC_BCEDEN")))   

If ALLTRIM( SA6->A6_COD + alltrim(SA6->A6_AGENCIA) + SA6->A6_NUMCON ) $ cCedente
	cMensag4    := "Titulo entregue em cess鉶 fiduci醨ia em favor do benefici醨io acima."
Endif


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se passou os par鈓etros para a fun玢o �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If (aDadTit == Nil .Or. ValType(aDadTit) <> "A") .Or.;
	(aDadCli == Nil .Or. ValType(aDadCli) <> "A") .Or.;
	(aBarra == Nil .Or. ValType(aBarra) <> "A")
	Aviso(	"Biblioteca de Fun珲es",;
			"Os par鈓etros passados por refer阯cia est鉶 fora dos padr鮡s."+Chr(13)+Chr(10)+;
			"Verifique a chamada da fun玢o no programa de origem.",;
			{"&Continua"},2,;
			"Chamada Inv醠ida" )
	lRet	:= .F.
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se os arquivos est鉶 posicionados �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If SE1->(Eof()) .Or. SE1->(Bof())
	Aviso(	"Biblioteca de Fun珲es",;
			"O arquivo de T韙ulos a Receber n鉶 esta posicionado.",;
			{"&Continua"},,;
			"Registro Inv醠ido" )
	lRet	:= .F.
EndIf
If SA1->(Eof()) .Or. SA1->(Bof())
	Aviso(	"Biblioteca de Fun珲es",;
			"O arquivo de Clientes n鉶 esta posicionado.",;
			{"&Continua"},,;
			"Registro Inv醠ido" )
	lRet	:= .F.
EndIf

aDadTit	:= {	"",;					// [1] Prefixo do T韙ulo
				"",;					// [2] N鷐ero do T韙ulo
				"",;					// [3] Parcela do T韙ulo
				"",;					// [4] Tipo do t韙ulo
				CToD("  /  /  "),;		// [5] Data de Emiss鉶 do t韙ulo
				CToD("  /  /  "),;		// [6] Data de Vencimento do T韙ulo
				CToD("  /  /  "),;		// [7] Data de Vencimento Real
				0,;						// [8] Valor L韖uido do T韙ulo
				"",;					// [9] C骴igo do Barras Formatado
				"",;					// [10]Carteira de Cobran鏰
				"",;					// [11]1.a Linha de Mensagens Diversas
				"",;					// [12]2.a Linha de Mensagens Diversas
				"",;					// [13]3.a Linha de Mensagens Diversas
				"",;					// [14]4.a Linha de Mensagens Diversas
				"",;					// [15]5.a Linha de Mensagens Diversas
				"" ;					// [16]6.a Linha de Mensagens Diversas
				}
aDadCli	:= {	"",;					// [1] C骴igo do cliente
				"",;					// [2] Loja do Cliente
				"",;					// [3] Nome Completo do Cliente
				"",;					// [4] CNPJ do Cliente
				"",;					// [5] Inscri玢o Estadual do cliente
				"",;					// [6] Tipo de Pessoa do Cliente
				"",;					// [7] Endere鏾
				"",;					// [8] Bairro
				"",;					// [9] Munic韕io
				"",;					// [10] Estado
				"",;					// [11] Cep
				"" ;					// [12] Via de entrega (Correio/Nota)
				}
aBarra	:= {	"",;					// [1] C骴igo de barras (Banco+"9"+D韌ito+Fator+Valor+Campo Livre
				"",;					// [2] Linha Digit醰el
				"",;					// [3] Nosso N鷐ero sem formata玢o
				"" ;					// [4] Nosso N鷐ero Formatado
				}

If lRet
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Alimenta array com os dados do cliente �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	aDadCli[1]	:= SA1->A1_COD
	aDadCli[2]	:= SA1->A1_LOJA
	aDadCli[3]	:= SA1->A1_NOME
	aDadCli[4]	:= SA1->A1_CGC
	aDadCli[5]	:= SA1->A1_INSCR
	aDadCli[6]	:= SA1->A1_PESSOA
	If !Empty(SA1->A1_ENDCOB)
		If !( "MESMO" $ UPPER( SA1->A1_ENDCOB ) )
			aDadCli[7]	:= SA1->A1_ENDCOB
			aDadCli[8]	:= SA1->A1_BAIRROC
			aDadCli[9]	:= SA1->A1_MUNC
			aDadCli[10]	:= SA1->A1_ESTC
			aDadCli[11]	:= SA1->A1_CEPC
			aDadCli[12]	:= ""//"CORREIO"
		Else
			aDadCli[7]	:= SA1->A1_END
			aDadCli[8]	:= SA1->A1_BAIRRO
			aDadCli[9]	:= SA1->A1_MUN
			aDadCli[10]	:= SA1->A1_EST
			aDadCli[11]	:= SA1->A1_CEP
			aDadCli[12]	:= ""//"CAMINH肙"

		EndIf
	Else
		aDadCli[7]	:= SA1->A1_END
		aDadCli[8]	:= SA1->A1_BAIRRO
		aDadCli[9]	:= SA1->A1_MUN
		aDadCli[10]	:= SA1->A1_EST
		aDadCli[11]	:= SA1->A1_CEP
		aDadCli[12]	:= ""//"CORREIO"
	Endif

	//谀哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Monta o saldo do t韙ulo �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪�
	If lSaldo
		nSaldo	:= SE1->E1_SALDO
	Else
		nSaldo	:= SE1->E1_VALOR
	EndIf    
//	nSaldo  := SALDOTIT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,1,DDatabase,,SE1->E1_LOJA)
	nSaldo	-= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nSaldo	-= SE1->E1_DECRESC
	nSaldo	+= SE1->E1_ACRESC

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Pega ou monta o nosso n鷐ero �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If !Empty(SE1->E1_NUMBCO)
		cNumDoc	:= left(alltrim(SE1->E1_NUMBCO),12)
	Else
		dbSelectArea("SEE")
		RecLock("SEE",.F.)
		nTamFax	:= Len(AllTrim(SEE->EE_FAXATU))
		cNumDoc	:= StrZero(Val(Alltrim(SEE->EE_FAXATU)),nTamFax)
		SEE->EE_FAXATU	:= Soma1(cNumDoc,nTamFax)
		MsUnLock()
	EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Define a carteira de cobran鏰 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//	If Empty(SEE->EE_SUBCTA)
	If Empty(SEE->EE_CODCART)
		cCarteira	:= "101"
	Else
//		cCarteira	:= SEE->EE_SUBCTA
		cCarteira	:= SEE->EE_CODCART
	EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta o C骴igo de Barras e Linha Digit醰el �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	aBarra	:= GetBarra(	aDadBco[1],;
							aDadBco[3],;
							aDadBco[4],;
							aDadBco[5],;
							aDadBco[6],;
							cCarteira,;
							cNumDoc,;
							nSaldo,;
							SE1->E1_VENCREA,;
							SEE->EE_CODEMP ;
							)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Taxa de juros a ser utilizado no c醠culo de juros de mora �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	/*
	If !Empty(aDadBco[10])
		cMensag1	:= "Mora Di醨ia de R$ "+AllTrim(Transform( Round( ( nSaldo * (aDadBco[10]/100) ) / 30, 2), "@E 999,999,999.99"))
	Endif
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Taxa de multa a ser impressa no boleto �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If !Empty(aDadBco[11])
		cMensag2	:= "Multa por atraso no pagamento - " + AllTrim(Transform( aDadBco[11], "@E 999,999.99%"))
	EndIf
	*/
/*
	
	cMensag1 := "Multa de 10% ap髎 o vencimento."
	cMensag2 := "Juros de 5% ao m阺 pro rata ap髎 o vencimento."
*/

//	cMensag1 := "Multa de 2% ap髎 o vencimento."
//	cMensag1 := "Cobrar Mora di醨ia de "   + AllTrim(Transform( Round ( nSaldo * 0.01 / 30, 2 ) , "@E 999,999,999.99"))
//	cMensag2 := "Cobrar 5% de multa ap髎 o vencimento."
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� N鷐ero de dias para envio do t韙ulo ao cart髍io �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	/*
	If !Empty(aDadBco[12]) .AND. SA1->A1_PROTEST <> '2' 
		cMensag3	:= "Protestar ap髎 " + StrZero(aDadBco[12], 2) + " (" + AllTrim(Extenso(aDadBco[12],.T.)) + ") dias 鵷eis"
	EndIf
    */
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Alimenta array com os dados do t韙ulo �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

//	aDadTit[1]	:= SE1->E1_PREFIXO		// [1] Prefixo do T韙ulo
//	aDadTit[2]	:= SE1->E1_NUM			// [2] N鷐ero do T韙ulo
//	aDadTit[3]	:= SE1->E1_PARCELA		// [3] Parcela do T韙ulo
//	aDadTit[4]	:= SE1->E1_TIPO			// [4] Tipo do t韙ulo
//	aDadTit[5]	:= SE1->E1_EMISSAO		// [5] Data de Emiss鉶 do t韙ulo
//	aDadTit[6]	:= SE1->E1_VENCREA  	// [6] Data de Vencimento do T韙ulo
//	aDadTit[7]	:= SE1->E1_VENCREA		// [7] Data de Vencimento Real
//	aDadTit[8]	:= nSaldo				// [8] Valor L韖uido do T韙ulo
//	aDadTit[9]	:= aBarra[4]			// [9] C骴igo do Barras Formatado
//	aDadTit[10]	:= cCarteira			// [10]Carteira de Cobran鏰
//	aDadTit[11]	:= cMensag1				// [11]1a. Linha de Mensagem diversas
//	aDadTit[12]	:= cMensag2				// [11]2a. Linha de Mensagem diversas
//	aDadTit[13]	:= cMensag3				// [11]3a. Linha de Mensagem diversas
//	aDadTit[14]	:= cMensag4				// [11]4a. Linha de Mensagem diversas
//	aDadTit[15]	:= cMensag5				// [11]5a. Linha de Mensagem diversas
//	aDadTit[16]	:= cMensag6				// [11]6a. Linha de Mensagem diversas
//EndIf							
//							
//RestArea(aAreaAtu)
//
//Return(lRet)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯屯屯淹屯屯屯屯脱屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯槐�
北� Programa    � GetBarra � C醠cula o c骴igo de barras, linha digit醰el e d韌ito do      罕�
北�             �          � nosso n鷐ero                                                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Autor       � 20.01.07 �                                                          罕�
北掏屯屯屯屯屯屯赝屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Par鈓etros  � ExpC1 = C骴igo do Banco                                                 罕�
北�             � ExpC2 = N鷐ero da Ag阯cia                                               罕�
北�             � ExpC3 = D韌ito da Ag阯cia                                               罕�
北�             � ExpC4 = N鷐ero da Conta Corrente                                        罕�
北�             � ExpC5 = D韌ito da Conta Corrente                                        罕�
北�             � ExpC6 = Carteira                                                        罕�
北�             � ExpC7 = Nosso N鷐ero sem d韌ito                                         罕�
北�             � ExpN1 = Valor do T韙ulo                                                 罕�
北�             � ExpD1 = Data de Vencimento                                              罕�
北�             � ExpC8 = N鷐ero do Contrato                                              罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Retorno     � ExpL1 = .T. montou os arrays corretamento, .F. n鉶 montou os arrays     罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Observa珲es � Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 罕�
北掏屯屯屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北� Altera珲es  � 99.99.99 - Consultor - Descri玢o da altera玢o                           罕�
北�             �                                                                         罕�
北韧屯屯屯屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
/*

Static Function XXGetBarra(cBanco,cAgencia,cDigAgencia,cConta,cDigConta,cCarteira,cNNum,nValor,dVencto,cContrato)

Local cValorFinal	:= StrZero(Int(NoRound(nValor*100)),10)
Local cDvCB			:= 0
Local cDv			:= 0
Local cNN			:= ""
Local cNNForm		:= ""
Local cRN			:= ""
Local cCB			:= ""
Local cS			:= ""
Local cDvNN			:= "" 
Local cContra		:= "" 
Local cFator		:= StrZero(dVencto - CToD("07/10/97"),4)
Local cCpoLivre		:= Space(25)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//�                 Definicao do NOSSO N贛ERO E CAMPO LIVRE                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� BRASIL                                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If cBanco $ "001"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矯omposicao do Campo Livre (25 posi珲es)                              �
	//�                                                                     �
	//砈OMENTE PARA AS CARTEIRAS 16/18 (com conv阯ios de 6 posi珲es)        �
	//�20 a 25 - (06) - N鷐ero do Conv阯io                                  �
	//�26 a 42 - (17) - Nosso N鷐ero                                        �
	//�43 a 44 - (02) - Carteira de cobran鏰                                �
	//�                                                                     �
	//砈OMENTE PARA AS CARTEIRAS 17/18                                      �
	//�20 a 25 - (06) - Fixo 0                                              �
	//�26 a 32 - (07) - N鷐ero do conv阯io                                  �
	//�33 a 42 - (10) - Nosso Numero (sem o digito verificador)             �
	//�43 a 44 - (02) - Carteira de cobran鏰                                �
	//�                                                                     �
	//矯omposicao do Nosso N鷐ero                                           �
	//�01 a 06 - (06) - N鷐ero do Conv阯io (SEE->EE_CODEMP)                 �
	//�07 a 11 - (05) - Nosso N鷐ero (SEE->EE_FAXATU)                       �
	//�12 a 12 - (01) - D韌ito do Nosso N鷐ero (Modulo 11)                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Carteira 16/18 - Conv阯io com 6 posi鏾es                                �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If Len(AllTrim(cContrato)) > 6
		Cs		:= AllTrim(cContrato) + cNNum + cCarteira
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Carteira 17/18 - Conv阯io com mais de 6 posi鏾es                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Else
		Cs		:= "000000" + AllTrim(cContrato) + cNNum + cCarteira
	EndIf
	cDvNN		:= U_TCCalcDV( cBanco, cS )		//Modulo11(cS)
	cNN			:= AllTrim(cContrato) + cNNum + cDvNN
	cNNForm		:= AllTrim(cContrato) + cNNum
//	cNNForm		:= AllTrim(cContrato) + cNNum + "-" + cDvNN
	cCpoLivre	:= ""
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� BRADESCO                                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ElseIf 	cBanco $ "237"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矯omposicao do Campo Livre (25 posi珲es)                              �
	//�                                                                     �
	//�
	
	
*/	