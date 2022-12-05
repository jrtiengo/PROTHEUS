#INCLUDE "protheus.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"    
#INCLUDE "Font.ch"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*

ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFINR99   บAutor  ณFlavio Macieira     บ Data ณ  26/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de impressใo de Boletos                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Taimin                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AUTOM563(cPrefixo,cNumero,cParcela,cCliente,cLoja,cBanco,cAgencia,cConta)

   Local aRegs		:= {}
 //Local aLst		:= {}
   Local aTamSX3	:= {}
   Local lEnd		:= .F.
   Local lAuto		:= .F.
   Local nLastKey	:= 0
   Local Tamanho	:= "P"
   Local cDesc1		:= "Este programa tem como objetivo efetuar a impressใo do"
   Local cDesc2		:= "Boleto de Cobran็a com c๓digo de barras, conforme os"
   Local cDesc3		:= "parโmetros definidos pelo usuแrio."
   Local cString	:= "SE1"
   Local wnrel		:= "RFINR99"
   Local cPerg		:= PADR("BOLSANT",LEN (SX1->X1_GRUPO))

   Private Titulo		:= "Boleto de Cobran็a com C๓digo de Barras"
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
   aAdd(aRegs,{cPerg,"14","Carteira Cobran็a"    ,	"","","mv_chE",aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,"G","","MV_PAR14","",	  			"",	  			"",				"",						"","",	 			"",	  			"",	  			"","","",		"","","","","","","","","","","","","","",		"","",		"",""})
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
		 Aviso("Impressao de Boletos","Configura็ao de banco nao encontrada para o banco "+Alltrim(cbanco)+", agencia "+Alltrim(cAgencia)+", conta "+Alltrim(cConta)+" do cliente "+Alltrim(SA1->A1_NOME)+". Verifique o cadastro de parametros de bancos para que a rotina possa ser gerada.",{"OK"},,"Atencao:")
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
      // Chama a pergunte para definir os parโmetros iniciais ##
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
   // Verifica se hแ dados a serem exibidos ##
   // ########################################
   If Len(aLst) > 0
	  Processa( { |lEnd| CallMark(aLst) }, "Selecionando dados a processar", Titulo )
   Else
	  Aviso(Titulo,;
			"Nใo existem dados a serem impressos. Verifique os parโmetros.",;
			{"&Continua"},,;
			"Sem Dados" )
   EndIf

Return(Nil)

// ##################################################################################
// Fun็ใo que carrega os registros a serem processados (Tํtulo a serem impressoas) ##
// ##################################################################################
Static Function CallLst()

   Local aAreaAtu := GetArea()
   Local aTamSX3  := {}
   Local nCnt	  := 0
   Local cQuery	  := ""
 //Local cPgtVista := GetMV("MV_#AVISTA",,)

   // ###########################
   // Monta a query de sele็ใo ##
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
   // Se existir o alias temporแrio, fecha para nใo dar erro ##
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
   // Alimenta array com os dados a serem exibidos na tela de marca็ใo ##
   // ###################################################################
   dbSelectArea("SC5")
   SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM

   dbSelectArea("RFINR99A")
   dbGoTop()
   ProcRegua( nCnt )

   While !Eof()
   
      // ###############################
	  // Movimenta regua de Impressใo ##
	  // ###############################
      IncProc( "Tํtulo: " + RFINR99A->E1_PREFIXO +"/"+ RFINR99A->E1_NUM +"/"+ RFINR99A->E1_PARCELA ) 
	
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
   // Fecha a แrea de trabalho ##
   // ###########################
   dbSelectArea("RFINR99A")
   dbCloseArea()

   // #########################
   // Restaura แrea original ##
   // #########################
   RestArea(aAreaAtu)

Return(Nil)

// ######################################################################################
// Fun็ใo que abre atela de sele็ใo dos tํtulos a serem impressos os boletos bancแrios ##
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
   // Monta interface com usuแrio para efetuar a marca็ใo dos tํtulos ##
   // ##################################################################
   DEFINE MSDIALOG oDlg TITLE "Sele็ใo de Tํtulos" FROM 000,000 TO 400,780 OF oDlg PIXEL
   
   @ 005,003 LISTBOX oLst FIELDS HEADER	" ", " ", "Prefixo", "N๚mero", "Parc.", "Tipo", "Cliente", "Loja", "Nome", "Emissใo", "Vencto.", "Venc.Real", "Valor", "Portador" ;
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
						DToC(aLst[oLst:nAt,09])                          ,;	// Emissใo
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
   // Verifica se teclou no botใo confirma ##
   // #######################################
   If nBotao == 1

	  // #######################################
	  // Verifica se tem algum tํtulo marcado ##
	  // #######################################
	  For nLoop := 1 To Len(aLst)
	   	  If aLst[nLoop,1]
			 lProc	:= .T.
			 Exit
		  EndIf
	  Next nLoop

	  // ##########################################
	  // Avisa usuแrio que nใo hแ tํtulo marcado ##
	  // ##########################################
	  If !lProc
		 Aviso(	Titulo,;
				"Nenhum tํtulo foi marcado. Nใo hแ dados a serem impressos.",;
				{"&Continua"},,;
				"Sem Dados" )

	     // #######################################################
	     // Chama a rotina que irแ montar e imprimir o relat๓rio ##
	     // #######################################################
 	  Else
		 Processa( { |lEnd| MontaRel() }, "Montando Imagem do Relat๓rio.", Titulo )
	  Endif
   EndIf

Return(Nil)

// #############################################
// Fun็ใo que visualiza o cadastro do cliente ##
// #############################################
user Function VisCli( cCliente, cLoja )

   Local aAreaAtu := GetArea()
   Local aAreaSA1 := SA1->( GetArea() )

   Private cCadastro := Titulo

   dbSelectArea( "SA1" )
   dbSetOrder( 1 )
   
   If !MsSeek( xFilial( "SA1" ) + cCliente + cLoja )
	  Aviso(Titulo,;
			"Cliente nใo localizado no cadastro. Contate o Administrador.",;
			{ "&Continua" },,;
			"Cliente: " + cCliente + "/" + cLoja )
   Else
	  AxVisual( "SA1", Recno() , 2 )
   EndIf

   RestArea( aAreaSA1 )
   RestArea( aAreaAtu )

Return( Nil )

// ########################################################
// Fun็ใo que monta a imagem do relat๓rio a ser impresso ##
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
   // Define o tipo de configura็ใo a ser utilizado na MSBAR ##
   // 1 = Polegadas, 2 = Centํmetros                         ##
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
			"Banco/Ag๊ncia/Conta: "+ AllTrim(mv_par11) +"/"+ AllTrim(mv_par12) +"/"+ AllTrim(mv_par13) +Chr(13)+Chr(10)+;
			"O registro nใo foi localizado no arquivo. Serแ desconsiderado.",;
			{"&Continua"},2,;
			"Registro Invแlido" )
	  Return(Nil)
   EndIf

   // ##################################
   // Posiciona no Parโmetro do Banco ##
   // ##################################
   dbSelectArea("SEE")
   dbSetOrder(1)
   If !MsSeek(xFilial("SEE")+mv_par11+mv_par12+mv_par13+mv_par14)
	  Aviso(Titulo,;
			"Banco/Ag๊ncia/Conta/Carteira: "+ AllTrim(mv_par11) +"/"+ AllTrim(mv_par12) +"/"+ AllTrim(mv_par13) +"/"+ AllTrim(mv_par14) + Chr(13) + Chr(10) +;
			"Os parโmetros do banco nใo foram localizados. Serแ desconsiderado.",;
			{"&Continua"},2,;
			"Registro Invแlido" )
	  Return(Nil)
   EndIf

   // ####################################################
   // Chama rotina que pega os dados do banco e empresa ##
   // ####################################################
   If !U_xTCDadBco(aDadEmp, aDadBco)
	  Aviso(Titulo,;
			"Banco/Ag๊ncia/Conta: "+ AllTrim(mv_par11) +"/"+ AllTrim(mv_par12) +"/"+ AllTrim(mv_par13) +"/"+ Chr(13) + Chr(10) +;
			"Banco do cliente: "+ SA1->A1_BCO1 + Chr(13) + Chr(10) + ;
			"Nใo foi possํvel obter os dados do banco.",;
			{"&Continua"},2,;
			"Registro Invแlido" )
	  Return(Nil)
   EndIf

   ProcRegua(Len(aLst))

   For nLoop := 1 To Len(aLst)
	   
	   // ###############################
	   // Movimenta r้gua de impressใo ##
	   // ###############################
   	   IncProc( "Tํtulo: " + aLst[nLoop,02] + "/" + aLst[nLoop,03] )

       // #################################
	   // S๓ processa se estiver marcado ##
	   // #################################
	   If aLst[nLoop,01]

	      // ######################
		  // Posiciona no tํtulo ##
		  // ######################
		  dbSelectArea("SE1")
		  dbSetOrder(1)
		  dbGoTo(aLst[nLoop,14])
		  If Eof() .Or. Bof()
			 Aviso(	Titulo,;
					"Tํtulo :"+ aLst[nLoop,02] +"/"+ aLst[nLoop,03] +"/"+ aLst[nLoop,04] +"/"+ aLst[nLoop,05] +Chr(13)+Chr(10)+;
					"O tํtulo nใo foi localizado no arquivo. Serแ desconsiderado.",;
					{"&Continua"},2,;
					"Registro Invแlido" )
			 Loop
		  EndIf

		  // #######################
		  // Posiciona no Cliente ##
		  // #######################
 		  dbSelectArea("SA1")
		  dbSetOrder(1)
		  If !MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			 Aviso(	Titulo,;
					"Tํtulo :"+ aLst[nLoop,02] +"/"+ aLst[nLoop,03] +"/"+ aLst[nLoop,04] +"/"+ aLst[nLoop,05] +Chr(13)+Chr(10)+;
					"Cliente/Loja: "+ SE1->E1_CLIENTE +"/"+ SE1->E1_LOJA +Chr(13)+Chr(10)+;
					"O cliente nใo foi localizado no arquivo. Serแ desconsiderado.",;
					{"&Continua"},2,;
					"Registro Invแlido" )
			 Loop
		  EndIf

		  // ######################
		  // Posiciona no Tํtulo ##
		  // ######################
		  dbSelectArea("SE1")

		  // #####################################################
		  // Chama rotina que pega os dados do tํtulo e cliente ##
		  // #####################################################
		  If !U_TCDadTit(aDadTit, aDadCli, aBarra, aDadBco)
			 Aviso(	Titulo,;
					"Tํtulo :"+ aLst[nLoop,02] +"/"+ aLst[nLoop,03] +"/"+ aLst[nLoop,04] +"/"+ aLst[nLoop,05] +Chr(13)+Chr(10)+;
					"Nใo foi possํvel obter os dados do tํtulo. serแ desconsiderado.",;
					{"&Continua"},2,;
					"Registro Invแlido" )
			 Loop
		  EndIf

		  // ########################################
		  // Chama a fun็ใo de impressใo do boleto ##
	  	  // ########################################
		  U_TCImpBol(oPrint,aDadEmp,aDadBco,aDadTit,aDadCli,aBarra,nTpImp)

		  // ############################################################
		  // Grava o arquivo com a imagem do boleto se for via correio ##
		  // ############################################################
		  //If !( aLst[nLoop,15] )
		  //	oPrint:SaveAllAsJPEG( cStartPath + "Boleto" + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA), 870, 1200, 105 )
		  //EndIf

		  // #######################################
		  // Atualiza o tํtulo com o nosso n๚mero ##
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
// Fun็ใo que cria um novo grupo de perguntas ##
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
//  Programa    ณTOPCONCNABณ Biblioteca de fun็๕es gen้ricas para utiliza็ใo na gera็ใo de ##
//              ณ          ณ boleto de cobran็a em formato grแfico, e nos arquivos de      ##
//              ณ          ณ comunica็ใo bancแria (remessa e retorno) do Cnab              ##
// ----------------------------------------------------------------------------------------##
//  Autor       ณ Flแvio Macieira                                                26.08.13ณ ##
// อออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ##
//  Observa็๕es ณ Os arquivos SE1, SA1 e SA6 devem estar posicionados no registro a ser    ##
//              ณ impresso                                                                 ##
//              ณ                                                                          ##
//              ณ         ANTES DE QUALQUER PROCESSAMENTO CRIAR CAMPOS/PARยMETROS          ##
//              ณ ***************************** CAMPOS NOVOS ****************************  ##
//              ณ A6_DIGBCO  - C - 01,0 - OBRIGATำRIO - Dํgito do banco perante a cโmara   ##
//              ณ              de compensa็ใo (FEBRABAN).                                  ##
//              ณ A6_ARQLOG  - C - 15,0 - OPCIONAL - Nome do arquivo com o logotipo do     ##
//              ณ              banco que deve obrigatoriamente estar no diret๓rio \SYSTEM\ ##
//              ณ              se nใo existir, colocarแ no lugar do logo o nome reduzido   ##
//              ณ              do cadastro de bancos.                                      ##
//              ณ ****************************** PARยMETROS *****************************  ##
//              ณ TC_TXJBOL - Taxa de juros de mora ao m๊s por atraso no pagamento, se nใo ##
//              ณ             existir nใo irแ colocar a mensagem com o valor dos juros que ##
//              ณ             deverแ ser cobrado por dia de atraso.                        ##
//             ณ TC_TXMBOL - Taxa de multa por atraso no pagamento, se nใo existir nใo     ##
//             ณ             irแ colocar a mensagem com o percentual de multa a ser que    ##
//             ณ             deverแ ser cobrado por atraso no pagamento                    ##
//             ณ TC_DIABOL - N๚mero de dias para envio do tํtulo ao cart๓rio, se nใo       ##
//             ณ             existir nใo irแ colocar a mensagem com o prazo de envio do    ##
//             ณ             tํtulo ao cart๓rio                                            ##
//             ณ MC_BCEDEN - Parametro que indica se o Banco serแ o Cedente do Boleto.     ##
//             ณ                   CAMPOS ATUALIZADOS NA ROTINA                            ##
//             ณ E1_PORTADO - com o banco selecionado no parโmetro da rotina               ##
//             ณ E1_AGENCIA - com a ag๊ncia selecionada no parโmetro da rotina             ##
//             ณ E1_CONTA   - com a conta selecionada no parโmetro da rotina               ##
//             ณ EE_FAXATU  - com ๓ pr๓ximo n๚mero disponํvel para utiliza็ใo              ##
//             ณ ******************************* DIVERSOS ******************************   ##
//             ณ 1. O campo EE_FAXATU deve conter o pr๓ximo n๚mero do boleto SEM o dํgito  ##
//             ณ    verificador e no tamanho exato do n๚mero definido no manual do banco,  ##
//             ณ    NรO deve haver caracteres separadores (.;,-etc...)                     ##
//             ณ    Citibank  - 11 posi็oes                                                ##
//             ณ    Ita๚      - 08 Posi็๕es                                                ##
//             ณ    Brasil    - 10 Posi็๕es                                                ##
//             ณ    Bradesco  - 11 Posi็๕es                                                ##
//             ณ    Santander - 11 Posi็๕es                                                ##
//             ณ 2. Carteira  - para defini็ใo do c๓digo da carteira ้ utilizado o campo   ##
//             ณ    EE_SUBCTA                                                              ##
//             ณ                                                                           ##
// ##########################################################################################

// ##########################################################################################
// Fun็ใo que retorna array com os dados do banco e da empresa                             ##
// --------------------------------------------------------------------------------------- ##
// Autor       ณ Flแvio Macieira                                        26.08.13 ณ         ##
// --------------------------------------------------------------------------------------- ##
// Parโmetros  ณ ExpA1 = Array vazio passado por refer๊ncia para ser atualizado com os     ##
//             ณ         dados do cadastro de empresa (SigaMat)                            ##
//             ณ ExpA2 = Array Vazio passado por refer๊ncia para ser atualizado com os     ##
//             ณ         dados so cadastro do banco (SA6)                                  ##
// --------------------------------------------------------------------------------------- ##
// Retorno     ณ ExpL1 = .T. montou os arrays corretamento, .F. nใo montou os arrays       ##
// --------------------------------------------------------------------------------------- ##
// Observa็๕es ณ Os arquivos devem estar posicionados SM0, SA6, SEE                        ##
// --------------------------------------------------------------------------------------- ##
// Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                             ##
//             ณ                                                                           ##
// ##########################################################################################
User Function xTCDadBco(aDadEmp, aDadBco)

   Local aAreaAtu := GetArea()
   Local lRet	  := .T.     

   // ##################################################################################
   // Parametro que verifica se o Banco serแ o Cedente do Titulo, atrav้s dos campos  ##
   // Cod. Banco, Ag๊ncia e N๚mero de conta, que devem ser informados sequencialmente ##
   // no parametro.                                                                   ##
   // ##################################################################################
   Local cCedente  := ''//IF(ValType(GetMv("MC_BCEDEN")) <> "C","",ALLTRIM(GetMv("MC_BCEDEN")))   

   // #################################################
   // Verifica se passou os parโmetros para a fun็ใo ##
   // #################################################
   If (aDadEmp == Nil .Or. ValType(aDadEmp) <> "A") .Or. (aDadBco == Nil .Or. ValType(aDadBco) <> "A")
	  Aviso("Biblioteca de Fun็๕es",;
			"Os parโmetros passados por refer๊ncia estใo fora dos padr๕es."+Chr(13)+Chr(10)+;
			"Verifique a chamada da fun็ใo no programa de origem.",;
			{"&Continua"},2,;
			"Chamada Invแlida" )
	  lRet	:= .F.
   EndIf

   // #############################################
   // Verifica se os arquivos estใo posicionados ##
   // #############################################
   If SM0->(Eof()) .Or. SM0->(Bof())
      Aviso("Biblioteca de Fun็๕es",;
			"O arquivo de Empresas nใo esta posicionado.",;
			{"&Continua"},,;
			"Registro Invแlido" )
	  lRet	:= .F.
   EndIf 
   
   If SA6->(Eof()) .Or. SA6->(Bof())
	  Aviso("Biblioteca de Fun็๕es",;
			"O arquivo de Bancos nใo esta posicionado.",;
			{"&Continua"},,;
			"Registro Invแlido" )
	  lRet	:= .F.
   EndIf

   // ###############################################################
   // Cria array vazio para que nใo d๊ erro se nใo encontrar dados ##
   // ###############################################################
   aDadEmp	:= {"",;	// [1] Nome da Empresa
				"",;	// [2] Endere็o
				"",;	// [3] Bairro
				"",;	// [4] Cidade
				"",;	// [5] Estado
				"",;	// [6] Cep
				"",;	// [7] Telefone
				"",;	// [8] Fax
				"",;	// [9] CNPJ
				"" ;	// [10]Inscri็ใo Estadual
				}

   aDadBco	:= {"",;	// [1] C๓digo do Banco
				"",;	// [2] Dํgito do Banco
				"",;	// [3] C๓digo da Ag๊ncia
				"",;	// [4] Dํgito da Ag๊ncia
				"",;	// [5] N๚mero da Conta Corrente
				"",;	// [6] Dํgito da Conta Corrente
				"",;	// [7] Nome Completo do Banco
				"",;	// [8] Nome Reduzido do Banco
				"",;	// [9] Nome do Arquivo com o Logotipo do Banco
				0,;		// [10]Taxa de juros a ser utilizado no cแlculo de juros de mora
				0,;		// [11]Taxa de multa a ser impressa no boleto
				0,;		// [12]N๚mero de dias para envio do tํtulo ao cart๓rio
				"",;	// [13]Dado para o campo "Uso do Banco"
				"",;	// [14]Dado para o campo "Esp้cie do Documento"
				"",;	// [15]C๓digo do Cedente
				"" ;    // [16]Contrato banco\Conv๊nio
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
		aDadBco[8]  := "BANCO ITAฺ S.A." 
		
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
	 // Define as taxas a serem utilizadas nos cแlculos das mensagens ##
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
	 // Define o campo Esp้cio do Documento do boleto ##
	 // ################################################
	 If SA6->A6_COD $ "745#"
	 	aDadBco[14]	:= "DMI"
	 ElseIf SA6->A6_COD $ "001#|033"
	 	aDadBco[14]	:= "DM"
	 Else
	 	aDadBco[14]	:= "NF"
	 EndIf
    

// aaqui

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define o campo da Conta/Cedente do boleto ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If SA6->A6_COD $ "745#"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Ag๊ncia + Conta Cosmos (C๓digo Empresa) ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aDadBco[15]	:= AllTrim(aDadBco[3])
		If !Empty(aDadBco[4])
			aDadBco[15]	+= "-"+Alltrim(aDadBco[4])
		EndIf
		If !Empty(SEE->EE_CODEMP)
			aDadBco[15]	+= "/"+StrZero(Val(EE_CODEMP),10)
		EndIf
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Ag๊ncia + Conta Corrente ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ TCDadTit ณ Retorna array com os dados do tํtulo e do cliente            บฑฑ
ฑฑบ             ณ          ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 20.01.07 ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpA1 = Array vazio passado por refer๊ncia para ser atualizado com os   บฑฑ
ฑฑบ             ณ         dados do cadastro do tํtulo (SE1)                               บฑฑ
ฑฑบ             ณ ExpA2 = Array Vazio passado por refer๊ncia para ser atualizado com os   บฑฑ
ฑฑบ             ณ         dados so cadastro do cliente (SA1)                              บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpL1 = .T. montou os arrays corretamento, .F. nใo montou os arrays     บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
	cMensag4    := "Titulo entregue em cessใo fiduciแria em favor do beneficiแrio acima."
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se passou os parโmetros para a fun็ใo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (aDadTit == Nil .Or. ValType(aDadTit) <> "A") .Or.;
	(aDadCli == Nil .Or. ValType(aDadCli) <> "A") .Or.;
	(aBarra == Nil .Or. ValType(aBarra) <> "A")
	Aviso(	"Biblioteca de Fun็๕es",;
			"Os parโmetros passados por refer๊ncia estใo fora dos padr๕es."+Chr(13)+Chr(10)+;
			"Verifique a chamada da fun็ใo no programa de origem.",;
			{"&Continua"},2,;
			"Chamada Invแlida" )
	lRet	:= .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se os arquivos estใo posicionados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SE1->(Eof()) .Or. SE1->(Bof())
	Aviso(	"Biblioteca de Fun็๕es",;
			"O arquivo de Tํtulos a Receber nใo esta posicionado.",;
			{"&Continua"},,;
			"Registro Invแlido" )
	lRet	:= .F.
EndIf
If SA1->(Eof()) .Or. SA1->(Bof())
	Aviso(	"Biblioteca de Fun็๕es",;
			"O arquivo de Clientes nใo esta posicionado.",;
			{"&Continua"},,;
			"Registro Invแlido" )
	lRet	:= .F.
EndIf

aDadTit	:= {	"",;					// [1] Prefixo do Tํtulo
				"",;					// [2] N๚mero do Tํtulo
				"",;					// [3] Parcela do Tํtulo
				"",;					// [4] Tipo do tํtulo
				CToD("  /  /  "),;		// [5] Data de Emissใo do tํtulo
				CToD("  /  /  "),;		// [6] Data de Vencimento do Tํtulo
				CToD("  /  /  "),;		// [7] Data de Vencimento Real
				0,;						// [8] Valor Lํquido do Tํtulo
				"",;					// [9] C๓digo do Barras Formatado
				"",;					// [10]Carteira de Cobran็a
				"",;					// [11]1.a Linha de Mensagens Diversas
				"",;					// [12]2.a Linha de Mensagens Diversas
				"",;					// [13]3.a Linha de Mensagens Diversas
				"",;					// [14]4.a Linha de Mensagens Diversas
				"",;					// [15]5.a Linha de Mensagens Diversas
				"" ;					// [16]6.a Linha de Mensagens Diversas
				}
aDadCli	:= {	"",;					// [1] C๓digo do cliente
				"",;					// [2] Loja do Cliente
				"",;					// [3] Nome Completo do Cliente
				"",;					// [4] CNPJ do Cliente
				"",;					// [5] Inscri็ใo Estadual do cliente
				"",;					// [6] Tipo de Pessoa do Cliente
				"",;					// [7] Endere็o
				"",;					// [8] Bairro
				"",;					// [9] Municํpio
				"",;					// [10] Estado
				"",;					// [11] Cep
				"" ;					// [12] Via de entrega (Correio/Nota)
				}
aBarra	:= {	"",;					// [1] C๓digo de barras (Banco+"9"+Dํgito+Fator+Valor+Campo Livre
				"",;					// [2] Linha Digitแvel
				"",;					// [3] Nosso N๚mero sem formata็ใo
				"" ;					// [4] Nosso N๚mero Formatado
				}

If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Alimenta array com os dados do cliente ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
			aDadCli[12]	:= ""//"CAMINHรO"

		EndIf
	Else
		aDadCli[7]	:= SA1->A1_END
		aDadCli[8]	:= SA1->A1_BAIRRO
		aDadCli[9]	:= SA1->A1_MUN
		aDadCli[10]	:= SA1->A1_EST
		aDadCli[11]	:= SA1->A1_CEP
		aDadCli[12]	:= ""//"CORREIO"
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta o saldo do tํtulo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lSaldo
		nSaldo	:= SE1->E1_SALDO
	Else
		nSaldo	:= SE1->E1_VALOR
	EndIf    
//	nSaldo  := SALDOTIT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,1,DDatabase,,SE1->E1_LOJA)
	nSaldo	-= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nSaldo	-= SE1->E1_DECRESC
	nSaldo	+= SE1->E1_ACRESC

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Pega ou monta o nosso n๚mero ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define a carteira de cobran็a ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//	If Empty(SEE->EE_SUBCTA)
	If Empty(SEE->EE_CODCART)
		cCarteira	:= "101"
	Else
//		cCarteira	:= SEE->EE_SUBCTA
		cCarteira	:= SEE->EE_CODCART
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta o C๓digo de Barras e Linha Digitแvel ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Taxa de juros a ser utilizado no cแlculo de juros de mora ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*
	If !Empty(aDadBco[10])
		cMensag1	:= "Mora Diแria de R$ "+AllTrim(Transform( Round( ( nSaldo * (aDadBco[10]/100) ) / 30, 2), "@E 999,999,999.99"))
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Taxa de multa a ser impressa no boleto ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(aDadBco[11])
		cMensag2	:= "Multa por atraso no pagamento - " + AllTrim(Transform( aDadBco[11], "@E 999,999.99%"))
	EndIf
	*/
/*
	
	cMensag1 := "Multa de 10% ap๓s o vencimento."
	cMensag2 := "Juros de 5% ao m๊s pro rata ap๓s o vencimento."
*/

//	cMensag1 := "Multa de 2% ap๓s o vencimento."
//	cMensag1 := "Cobrar Mora diแria de "   + AllTrim(Transform( Round ( nSaldo * 0.01 / 30, 2 ) , "@E 999,999,999.99"))
//	cMensag2 := "Cobrar 5% de multa ap๓s o vencimento."
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ N๚mero de dias para envio do tํtulo ao cart๓rio ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*
	If !Empty(aDadBco[12]) .AND. SA1->A1_PROTEST <> '2' 
		cMensag3	:= "Protestar ap๓s " + StrZero(aDadBco[12], 2) + " (" + AllTrim(Extenso(aDadBco[12],.T.)) + ") dias ๙teis"
	EndIf
    */
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Alimenta array com os dados do tํtulo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aDadTit[1]	:= SE1->E1_PREFIXO		// [1] Prefixo do Tํtulo
	aDadTit[2]	:= SE1->E1_NUM			// [2] N๚mero do Tํtulo
	aDadTit[3]	:= SE1->E1_PARCELA		// [3] Parcela do Tํtulo
	aDadTit[4]	:= SE1->E1_TIPO			// [4] Tipo do tํtulo
	aDadTit[5]	:= SE1->E1_EMISSAO		// [5] Data de Emissใo do tํtulo
	aDadTit[6]	:= SE1->E1_VENCREA  	// [6] Data de Vencimento do Tํtulo
	aDadTit[7]	:= SE1->E1_VENCREA		// [7] Data de Vencimento Real
	aDadTit[8]	:= nSaldo				// [8] Valor Lํquido do Tํtulo
	aDadTit[9]	:= aBarra[4]			// [9] C๓digo do Barras Formatado
	aDadTit[10]	:= cCarteira			// [10]Carteira de Cobran็a
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ GetBarra ณ Cแlcula o c๓digo de barras, linha digitแvel e dํgito do      บฑฑ
ฑฑบ             ณ          ณ nosso n๚mero                                                 บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 20.01.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpC1 = C๓digo do Banco                                                 บฑฑ
ฑฑบ             ณ ExpC2 = N๚mero da Ag๊ncia                                               บฑฑ
ฑฑบ             ณ ExpC3 = Dํgito da Ag๊ncia                                               บฑฑ
ฑฑบ             ณ ExpC4 = N๚mero da Conta Corrente                                        บฑฑ
ฑฑบ             ณ ExpC5 = Dํgito da Conta Corrente                                        บฑฑ
ฑฑบ             ณ ExpC6 = Carteira                                                        บฑฑ
ฑฑบ             ณ ExpC7 = Nosso N๚mero sem dํgito                                         บฑฑ
ฑฑบ             ณ ExpN1 = Valor do Tํtulo                                                 บฑฑ
ฑฑบ             ณ ExpD1 = Data de Vencimento                                              บฑฑ
ฑฑบ             ณ ExpC8 = N๚mero do Contrato                                              บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpL1 = .T. montou os arrays corretamento, .F. nใo montou os arrays     บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                 Definicao do NOSSO NฺMERO E CAMPO LIVRE                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ BRASIL                                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cBanco $ "001"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao do Campo Livre (25 posi็๕es)                              ณ
	//ณ                                                                     ณ
	//ณSOMENTE PARA AS CARTEIRAS 16/18 (com conv๊nios de 6 posi็๕es)        ณ
	//ณ20 a 25 - (06) - N๚mero do Conv๊nio                                  ณ
	//ณ26 a 42 - (17) - Nosso N๚mero                                        ณ
	//ณ43 a 44 - (02) - Carteira de cobran็a                                ณ
	//ณ                                                                     ณ
	//ณSOMENTE PARA AS CARTEIRAS 17/18                                      ณ
	//ณ20 a 25 - (06) - Fixo 0                                              ณ
	//ณ26 a 32 - (07) - N๚mero do conv๊nio                                  ณ
	//ณ33 a 42 - (10) - Nosso Numero (sem o digito verificador)             ณ
	//ณ43 a 44 - (02) - Carteira de cobran็a                                ณ
	//ณ                                                                     ณ
	//ณComposicao do Nosso N๚mero                                           ณ
	//ณ01 a 06 - (06) - N๚mero do Conv๊nio (SEE->EE_CODEMP)                 ณ
	//ณ07 a 11 - (05) - Nosso N๚mero (SEE->EE_FAXATU)                       ณ
	//ณ12 a 12 - (01) - Dํgito do Nosso N๚mero (Modulo 11)                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carteira 16/18 - Conv๊nio com 6 posi็oes                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(AllTrim(cContrato)) > 6
		Cs		:= AllTrim(cContrato) + cNNum + cCarteira
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carteira 17/18 - Conv๊nio com mais de 6 posi็oes                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else
		Cs		:= "000000" + AllTrim(cContrato) + cNNum + cCarteira
	EndIf
	cDvNN		:= U_TCCalcDV( cBanco, cS )		//Modulo11(cS)
	cNN			:= AllTrim(cContrato) + cNNum + cDvNN
	cNNForm		:= AllTrim(cContrato) + cNNum
//	cNNForm		:= AllTrim(cContrato) + cNNum + "-" + cDvNN
	cCpoLivre	:= ""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ BRADESCO                                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf 	cBanco $ "237"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao do Campo Livre (25 posi็๕es)                              ณ
	//ณ                                                                     ณ
	//ณ20 a 23 - (04) - Agencia cedente (sem o digito), completar com zeros ณ
	//ณ                 a esquerda se necessario	                        ณ
	//ณ24 a 25 - (02) - Carteira                                            ณ
	//ณ26 a 36 - (11) - Nosso Numero (sem o digito verificador)             ณ
	//ณ37 a 43 - (07) - Conta do cedente, sem o digito verificador, completeณ
	//ณ                 com zeros a esquerda, se necessario                 ณ
	//ณ44 a 44 - (01) - Fixo "0"                                            ณ
	//ณ                                                                     ณ
	//ณComposicao do Nosso N๚mero                                           ณ
	//ณ01 a 02 - (02) - N๚mero da Carteira (SEE->EE_SUBCTA)                 ณ
	//ณ                 06 para Sem Registro 19 para Com Registro           ณ
	//ณ03 a 13 - (11) - Nosso N๚mero (SEE->EE_FAXATU)                       ณ
	//ณ04 a 14 - (01) - Dํgito do Nosso N๚mero (Modulo 11)                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cS			:= AllTrim(cCarteira) + cNNum
	cDvNN		:= U_TCCalcDV( cBanco, cS )			//Mod11237(cS)
	cNN			:= AllTrim(cCarteira) + cNNum + cDvNN
//	cNNForm		:= AllTrim(cCarteira) + "/"+ Substr(cNNum,1,2)+"/"+Substr(cNNum,3,9) + "-" + cDvnn
	cNNForm		:= AllTrim(cCarteira) + "/"+ Substr(cNNum,1,2)+Substr(cNNum,3,9) + "-" + cDvnn
	cCpoLivre	:= StrZero(Val(AllTrim(cAgencia)),4)+StrZero(Val(AllTrim(cCarteira)),2)+cNNum+StrZero(Val(AllTrim(cConta)),7)+"0"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ ITAฺ                                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf cBanco $ "341"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao do Campo Livre (25 posi็๕es)                              ณ
	//ณ                                                                     ณ
	//ณ20 a 22 - (03) - Carteira                                            ณ
	//ณ23 a 30 - (08) - Nosso N๚mero (sem o dํgito verificador)             ณ
	//ณ31 a 31 - (01) - Digito verificador                                  ณ
	//ณ32 a 35 - (04) - Ag๊ncia                                             ณ
	//ณ36 a 40 - (05) - Conta (sem o dํgito verificador                     ณ
	//ณ41 a 41 - (01) - Dํgito verificador da conta                         ณ
	//ณ42 a 44 - (03) - Fixo "000"                                          ณ
	//ณ                                                                     ณ
	//ณComposicao do Nosso N๚mero                                           ณ
	//ณSe carteira for 126/131/146/150/168                                  ณ
	//ณ01 a 03 - (03) - Carteira                                            ณ
	//ณ04 a 11 - (08) - Nosso N๚mero (EE_FAXATU)                            ณ
	//ณDemais carteiras                                                     ณ
	//ณ01 a 04 - (04) - Ag๊ncia sem dํgito verificador                      ณ
	//ณ05 a 09 - (05) - Conta Corrente sem dํgito verificador               ณ
	//ณ10 a 12 - (03) - Carteira                                            ณ
	//ณ13 a 20 - (08) - Nosso N๚mero (EE_FAXATU)                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ CITIBANK                                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf cBanco $ "745"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao do Campo Livre (25 posi็๕es)                              ณ
	//ณ                                                                     ณ
	//ณ20 a 20 - (01) - C๓digo do Produto (3=Cobran็a com/sem registro      ณ
	//ณ                 4=Cobran็a de seguro sem registro)                  ณ
	//ณ21 a 23 - (03) - Portif๓lio 3 ๚ltimos dํgitos do campo c๓digo Empresaณ
	//ณ                 Segundo Douglas (Citigroup) enviar neste campo o    ณ
	//ณ                 n๚mero da carteira.                                 ณ
	//ณ                 O n๚mero do contrato ้ chamado de Conta Cosmos e ้  ณ
	//ณ                 formado por 10 posi็๕es com A.BBBBBB.CC.D, onde     ณ
	//ณ                 A      = Nใo utilizado                              ณ
	//ณ                 BBBBBB = Base                                       ณ
	//ณ                 CC     = Sequencia                                  ณ
	//ณ                 D      = Dํgito                                     ณ
	//ณ24 a 29 - (06) - Base (Contrato)                                     ณ
	//ณ30 a 31 - (02) - Sequencia (Contrato)                                ณ
	//ณ32 a 32 - (01) - Dํgito da conta Cosmos (Contrato)                   ณ
	//ณ33 a 44 - (12) - Nosso N๚mero com dํgito verificador                 ณ
	//ณ                                                                     ณ
	//ณComposicao do Nosso N๚mero                                           ณ
	//ณ01 a 11 - (11) - Nosso N๚mero (EE_FAXATU)                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cS			:= cNNum
	cDvNN		:= U_TCCalcDV( cBanco, cS )			//modulo11(cS)
	cNN			:= cNNum + cDvNN
	cNNForm		:= cNNum + "-" + cDvNN
	cCpoLivre	:= "3" + StrZero(Val(cCarteira),3) + SubStr(AllTrim(cContrato), 2, 9) + cNN  
	  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Santander                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
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
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                  Definicao do DอGITO CODIGO DE BARRAS                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                  Definicao da LINHA DIGITมVEL                           ณ
//ณ Campo 1       Campo 2        Campo 3        Campo 4   Campo 5           ณ
//ณ AAABC.CCCCX   CCCCC.CCCCCY   CCCCC.CCCCCZ   W	      UUUUVVVVVVVVVV    ณ
//ณฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤณ
//ณ AAA                       = C๓digo do Banco na Cโmara de Compensa็ใo    ณ
//ณ B                         = C๓digo da Moeda, sempre 9                   ณ
//ณ CCCCCCCCCCCCCCCCCCCCCCCCC = Campo Livre                                 ณ
//ณ X                         = Digito Verificador do Campo 1               ณ
//ณ Y                         = Digito Verificador do Campo 2               ณ
//ณ Z                         = Digito Verificador do Campo 3               ณ
//ณ W                         = Digito Verificador do Codigo de Barras      ณ
//ณ UUUU                      = Fator de Vencimento                         ณ
//ณ VVVVVVVVVV                = Valor do Tํtulo                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ CALCULO DO DอGITO VERIFICADOR DO CAMPO 1                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cBanco $ "001|033"
	cS		:= cBanco + "9" +"9"  +Substr(cCB,20,5)
	cDv		:= modulo10(cS)
	cRN1	:= SubStr(cS, 1, 5) + "." + SubStr(cS, 7, 4) + cDv  
Else
	cS		:= cBanco + "9" +Substr(cCpoLivre,1,5)
	cDv		:= modulo10(cS)
	cRN1	:= SubStr(cS, 1, 5) + "." + SubStr(cS, 6, 4) + cDv
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ CALCULO DO DอGITO VERIFICADOR DO CAMPO 2                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ CALCULO DO DอGITO VERIFICADOR DO CAMPO 3                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ CALCULO DO CAMPO 4                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cBanco $ "033"
	cRN4   := Substr(cCb,5,1)
Else	
	cRN4	:= cDvCB
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ CALCULO DO CAMPO 5                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cRN5	:= cFator + cValorFinal

cRN		:= cRN1 + " " + cRN2 + ' '+ cRN3 + ' ' + cRN4 + ' ' + cRN5

Return({cCB,cRN,cNNum,cNNForm,cDvNN})



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ TCCalcDV ณ Efetua o cแlculo do dํgito verificador do nosso n๚mero       บฑฑ
ฑฑบ             ณ          ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 08.02.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpC1 = C๓digo do Banco                                                 บฑฑ
ฑฑบ             ณ ExpC2 = Nosso N๚mero                                                    บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpC3 = Dํgito Verificador                                              บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ                                                                         บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ Modulo10 ณ Efetua o cแlculo do dํgito veririficador com base 10         บฑฑ
ฑฑบ             ณ          ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 23.01.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpC1 = String com o c๓digo a ser calculado                             บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpC1 = String com o Dํgito Verificador                                 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ                                                                         บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ Modulo11 ณ Efetua o cแlculo do dํgito veririficador com base 11         บฑฑ
ฑฑบ             ณ          ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 23.01.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpC1 = String com o c๓digo a ser calculado                             บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpC1 = String com o Dํgito Verificador                                 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ                                                                         บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ Mod11237 ณ Efetua o cแlculo do dํgito veririficador com base 7 Bradesco บฑฑ
ฑฑบ             ณ          ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 23.01.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpC1 = String com o c๓digo a ser calculado                             บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpC1 = String com o Dํgito Verificador                                 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ                                                                         บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  Modulo11a  ณ         Flแvio Macieira    บ Data ณ  09/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Dig codigo barra Santander                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  Mod11033           ณFlแvio Macieira     บ Data ณ  09/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ modulo 11 com base 7 para Santander                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ TCImpBol ณ Efetua a impressใo do boleto bancแrio                        บฑฑ
ฑฑบ             ณ          ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 20.01.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpO1 = Objeto print                                                    บฑฑ
ฑฑบ             ณ ExpA1 = Array com os dados da Empresa                                   บฑฑ
ฑฑบ             ณ ExpA2 = Array com os dados do Banco                                     บฑฑ
ฑฑบ             ณ ExpA3 = Array com os dados do Tํtulo                                    บฑฑ
ฑฑบ             ณ ExpA4 = Array com os dados do Cliente                                   บฑฑ
ฑฑบ             ณ ExpA5 = Array com os dados do C๓digo de Barras                          บฑฑ
ฑฑบ             ณ ExpN1 = Tipo de configura็ใo a ser utilizado (1=Polegadas/2=Centํmetros)บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ Nil                                                                     บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ                                                                         บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro que verifica se o Banco serแ o Cedente do Titulo, atrav้s dos campos  ณ
//ณCod. Banco, Ag๊ncia e N๚mero de conta, que devem ser informados sequencialmente ณ
//ณno parametro.                                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู          
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
	oPrint:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressใo em IMP_PDF 
	cDiretorio := oPrint:cPathPDF

If ALLTRIM( SA6->A6_COD + alltrim(SA6->A6_AGENCIA) + SA6->A6_NUMCON ) $ cCedente
	cAvalista := SM0->M0_NOMECOM
Endif

If Right(cStartPath,1) <> "\"
	cStartPath+= "\"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta string com o caminho do logotipo do banco ณ
//ณ O Tamanho da figura tem que ser 381 x 68 pixel  ณ
//ณ para que a impressใi sai correta                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cBmp	:= cStartPath+'logosant.bmp' //aDadBco[9]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define as fontes a serem utilizadas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia uma nova pแgina ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
oPrint:StartPage()

nLin:= nLin - 620

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o Segundo Bloco - Recibo do Sacado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrint:Line (nLin+0690,0100,nLin+0690,2300)														// Quadro
oPrint:Line (nLin+0690,0500,nLin+0610,0500)														// Quadro
oPrint:Line (nLin+0690,0710,nLin+0610,0710)														// Quadro

//If !Empty(aDadBco[9])
	oPrint:SayBitMap(nLin+0624,0100,cBmp,350,060)													// Logotipo do Banco
//Else
//	oPrint:Say  (nLin+0644,0100,	aDadBco[8],											oFont14)	// Nome do Banco
//EndIf
oPrint:Say  (nLin+0655,0513,	aDadBco[1]+"-"+aDadBco[2],								oFont21)	// Numero do Banco + Dํgito
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
	oPrint:Say  (nLin+0725,0400 ,	"Pagแvel em qualquer banco at้ o vencimento.", oFont10)
Else																		
	oPrint:Say  (nLin+0725,0400 ,	"ATษ O VENCIMENTO, PREFERENCIALMENTE NO "+Upper(aDadBco[8]),;
																						oFont10)	// 1a. Linha de Local Pagamento
	oPrint:Say  (nLin+0765,0400 ,	"APำS O VENCIMENTO, SOMENTE NO "+Upper(aDadBco[8]),;
																			 			oFont10)	// 2a. Linha de Local Pagamento    
EndIf																			 			

oPrint:Say  (nLin+0710,1810,	"Vencimento",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0750,2000,	StrZero(Day(aDadTit[6]),2) +"/"+;
								StrZero(Month(aDadTit[6]),2) +"/"+; 
								StrZero(Year(aDadTit[6]),4),					 		oFont11c)	// Vencimento

oPrint:Say  (nLin+0810,0100,	"Beneficiแrio",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0850,0100,	AllTrim(aDadEmp[1])+If(!Empty(cAvalista),""," - CNPJ: "+Transform(aDadEmp[9], "@R 99.999.999/9999-99")),;
																						oFont10)	// Nome + CNPJ

oPrint:Say  (nLin+0810,1810,	"Ag๊ncia/C๓digo Beneficiแrio",     						oFont8)		// Texto Fixo
oPrint:Say  (nLin+0850,1900,	AllTrim(aDadBco[15]),									oFont11c)	// Agencia + C๓d.Cedente + Dํgito


oPrint:Say  (nLin+0910,0100,	"Data do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,0150,	StrZero(Day(aDadTit[5]),2)+"/"+ ;
								StrZero(Month(aDadTit[5]),2)+"/"+ ;
								Right(Str(Year(aDadTit[5])),4),						oFont10)	// Data do Documento

oPrint:Say  (nLin+0910,0505,	"Nro.Documento",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,0605,	aDadTit[1]+aDadTit[2]+"/"+aDadTit[3],					oFont10)	// Prefixo + Numero + Parcela

oPrint:Say  (nLin+0910,1005,	"Esp้cie Doc.",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,1055,	aDadBco[14],											oFont10)	// Tipo do Titulo

oPrint:Say  (nLin+0910,1305,	"Aceite",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,1400,	"N",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+0910,1485,	"Data do Processamento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+0940,1550,	StrZero(Day(dDataBase),2)+"/"+ ;
								StrZero(Month(dDataBase),2)+"/"+ ;
								StrZero(Year(dDataBase),4),								oFont10)	// Data impressao

oPrint:Say  (nLin+0910,1810,	"Nosso N๚mero",											oFont8)		// Texto Fixo 
  
//If Alltrim(SA6->A6_COD)$ "033"
//	oPrint:Say  (nLin+0940,1900,	SubStr(aBarra[4],5,9),								oFont11c)	// Nosso N๚mero  
//Else	
	oPrint:Say  (nLin+0940,1900,	aBarra[4],											oFont11c)	// Nosso N๚mero
//EndIf 

oPrint:Say  (nLin+0980,0100,	"Uso do Banco",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+1010,0150,	aDadBco[13],											oFont10)	// Texto Fixo

oPrint:Say  (nLin+0980,0505,	"Carteira",												oFont8)		// Texto Fixo  

If Alltrim(SA6->A6_COD)$ "033"
   oPrint:Say  (nLin+1010,0555,	aDadTit[10]+" - RCR",											oFont10)	// Carteira  
Else	
	oPrint:Say  (nLin+1010,0555,	aDadTit[10],											oFont10)	// Carteira
EndIf	

oPrint:Say  (nLin+0980,0755,	"Esp้cie",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+1010,0805,	"R$",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+0980,1005,	"Quantidade",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+0980,1485,	"Valor",											 	oFont8)		// Texto Fixo

oPrint:Say  (nLin+0980,1810,	"Valor do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+1010,1900,	Transform(aDadTit[8],"@E 9999,999,999.99"),				oFont11c)	// Valor do Tํtulo

oPrint:Say  (nLin+1050,0100,	"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do beneficiแrio)",;
																						oFont8)		// Texto Fixo
oPrint:Say  (nLin+1100,0100,	"Juros / Mora por dia : 0,33%,  R$ "+  alltrim(	Transform((0.0033*aDadTit[8]),"@E 9999,999,999.99"))+" ao dia ",	oFont10)	// 1a Linha Instru็ใo
oPrint:Say  (nLin+1150,0100,	"Protesto Automแtico ap๓s 5 dias de atraso",											oFont10)	// 2a. Linha Instru็ใo
oPrint:Say  (nLin+1200,0100,	"Dep๓sito em conta nใo quita o boleto.",											oFont10)	// 3a. Linha Instru็ใo
oPrint:Say  (nLin+1250,0100,	"D๚vidas: envie e-mail para contasareceber@vitasons.com.br"	 ,										oFont10)	// 4a. Linha Instru็ใo
//oPrint:Say  (nLin+1300,0100,	aDadTit[15],											oFont10)	// 5a. Linha Instru็ใo
//oPrint:Say  (nLin+1350,0100,	aDadTit[16],											oFont10)	// 6a. Linha Instru็ใo

oPrint:Say  (nLin+1050,1810,	"(-)Desconto/Abatimento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+1120,1810,	"(-)Outras Dedu็๕es",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+1190,1810,	"(+)Mora/Multa",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+1260,1810,	"(+)Outros Acr้scimos",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+1330,1810,	"(=)Valor Cobrado",										oFont8)		// Texto Fixo

oPrint:Say  (nLin+1400,0100,	"Pagador",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+1430,0200,	aDadCli[3],												oFont10)	// Nome do Cliente
//oPrint:Say  (nLin+1430,0200,	" ("+aDaDCli[1]+"-"+aDadCli[2]+") "+aDadCli[3],		oFont10)	// C๓digo + Nome do Cliente

If aDadCli[6] = "J"
	oPrint:Say  (nLin+1430,1850,"CNPJ: "+Transform(aDadCli[4],"@R 99.999.999/9999-99"),;
																				  		oFont10)	// CGC
Else
	oPrint:Say  (nLin+1430,1850,"CPF: "+Transform(aDadCli[4],"@R 999.999.999-99"),;
																						oFont10)	// CPF
EndIf

oPrint:Say  (nLin+1483,0200,	AllTrim(aDadCli[7])+" "+AllTrim(aDadCli[8]),			oFont10)	// Endere็o + Bairro
//oPrint:Say	(nLin+1483,1850,	"Entrega: "+aDadCli[12],								oFont10)	// Forma de Envio do Boleto

oPrint:Say  (nLin+1536,0200,	Transform(aDadCli[11],"@R 99999-999")+" - "+ ;
										AllTrim(aDadCli[9])+" - "+ ;
										AllTrim(aDadCli[10]),							oFont10)	// CEP + Cidade + Estado

oPrint:Say  (nLin+1589,1850,	aBarra[4],												oFont10)	// Nosso N๚mero

oPrint:Say  (nLin+1605,0100,	"Pagador/Avalista"+ if( !empty(cAvalista)," - " + Rtrim(cAvalista),""),						oFont8)		// Texto Fixo
oPrint:Say  (nLin+1645,1500,	"Autentica็ใo Mecโnica",								oFont8)		// Texto Fixo

oPrint:Line (nLin+0690,1800,nLin+1380,1800)														// Quadro
oPrint:Line (nLin+1100,1800,nLin+1100,2300)														// Quadro
oPrint:Line (nLin+1170,1800,nLin+1170,2300)														// Quadro
oPrint:Line (nLin+1240,1800,nLin+1240,2300)														// Quadro
oPrint:Line (nLin+1310,1800,nLin+1310,2300)														// Quadro
oPrint:Line (nLin+1380,0100,nLin+1380,2300)														// Quadro
oPrint:Line (nLin+1620,0100,nLin+1620,2300)														// Quadro

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Pontilhado separador ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//nLin	:= 100
nLin	:= 010

nLin:= nLin - 740

For nLoop := 100 To 2300 Step 50
	oPrint:Line(nLin+1860, nLoop, nLin+1860, nLoop+30)												// Linha Pontilhada
Next nI
                 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o Terceiro Bloco - Ficha de Compensa็ใo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrint:Line (nLin+1980,0100,nLin+1980,2300)														// Quadro
oPrint:Line (nLin+1980,0500,nLin+1900,0500)														// Quadro
oPrint:Line (nLin+1980,0710,nLin+1900,0710)														// Quadro

//If !Empty(aDadBco[9])
	oPrint:SayBitMap(nLin+1914,0100,cBmp,350,060)													// Logotipo do Banco 	
//Else
//	oPrint:Say  (nLin+1934,100,	aDadBco[8],												oFont14)	// Nome do Banco
//EndIf
oPrint:Say  (nLin+1945,0533,	aDadBco[1]+"-"+aDadBco[2],								oFont21)	// Numero do Banco + Dํgito
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
	oPrint:Say  (nLin+2015,0400,	"Pagแvel em qualquer banco at้ o vencimento.",  	oFont10)	// Texto Fixo 
Else 	
	oPrint:Say  (nLin+2015,0400,	"ATษ O VENCIMENTO, PREFERENCIALMENTE NO "+aDadBco[8],	oFont10)	// Texto Fixo
	oPrint:Say  (nLin+2055,0400 ,	"APำS O VENCIMENTO, SOMENTE NO "+aDadBco[8],			oFont10)	// Texto Fixo 

EndIf
           
oPrint:Say  (nLin+2000,1810,	"Vencimento",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2040,1900,	StrZero(Day(aDadTit[6]),2)+"/"+;
								StrZero(Month(aDadTit[6]),2)+"/"+;
								StrZero(Year(aDadTit[6]),4), 							oFont11c)	// Vencimento
                                                 
oPrint:Say  (nLin+2100,0100,	"Beneficiแrio",   											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2140,0100,	AllTrim(aDadEmp[1])+If(!Empty(cAvalista),""," - CNPJ: "+Transform(aDadEmp[9], "@R 99.999.999/9999-99")),;
																						oFont10)	// Nome + CNPJ

oPrint:Say  (nLin+2100,1810,	"Ag๊ncia/C๓digo Beneficiแrio",   							oFont8)		// Texto Fixo
oPrint:Say  (nLin+2140,1900,	AllTrim(aDadBco[15]),									oFont11c)	// Agencia + C๓d.Cedente + Dํgito


oPrint:Say  (nLin+2200,0100,	"Data do Documento",									oFont8)		// Texto Fixo
oPrint:Say	(nLin+2230,0100, 	StrZero(Day(aDadTit[5]),2)+"/"+ ;
								StrZero(Month(aDadTit[5]),2)+"/"+ ;
								StrZero(Year(aDadTit[5]),4),		 					oFont10)	// Vencimento

oPrint:Say  (nLin+2200,0505,	"Nro.Documento",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,0605,	aDadTit[1]+aDadTit[2]+aDadTit[3],						oFont10)	// Prefixo + Numero + Parcela

oPrint:Say  (nLin+2200,1005,	"Esp้cie Doc.",						   					oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,1050,	aDadBco[14],											oFont10)	//Tipo do Titulo

oPrint:Say  (nLin+2200,1305,	"Aceite",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,1400,	"N",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+2200,1485,	"Data do Processamento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+2230,1550,	StrZero(Day(dDataBase),2)+"/"+ ;
								StrZero(Month(dDataBase),2)+"/"+ ;
								StrZero(Year(dDataBase),4),								oFont10)	// Data impressao

oPrint:Say  (nLin+2200,1810,	"Nosso N๚mero",											oFont8)		// Texto Fixo   

//If Alltrim(SA6->A6_COD)$ "033"
//	oPrint:Say  (nLin+2230,1900,	SubStr(aBarra[4],5,9),								oFont11c)	// Nosso N๚mero  
//Else	
	oPrint:Say  (nLin+2230,1900,	aBarra[4],											oFont11c)	// Nosso N๚mero
//EndIf

oPrint:Say  (nLin+2270,0100,	"Uso do Banco",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2300,0150,	aDadBco[13],											oFont10)	// Texto Fixo

oPrint:Say  (nLin+2270,0505,	"Carteira",												oFont8)		// Texto Fixo 

If Alltrim(SA6->A6_COD)$ "033"
	oPrint:Say  (nLin+2300,0555,	aDadTit[10]+" - RCR",								oFont10)
Else	
	oPrint:Say  (nLin+2300,0555,	aDadTit[10],										oFont10) 
EndIf	

oPrint:Say  (nLin+2270,0755,	"Esp้cie",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+2300,0805,	"R$",													oFont10)	// Texto Fixo

oPrint:Say  (nLin+2270,1005,	"Quantidade",											oFont8)		// Texto Fixo
oPrint:Say  (nLin+2270,1485,	"Valor",												oFont8)		// Texto Fixo

oPrint:Say  (nLin+2270,1810,	"Valor do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+2300,1900,	Transform(aDadTit[8], "@E 9999,999,999.99"),			oFont11c)	// Valor do Documento

oPrint:Say  (nLin+2340,0100,	"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do beneficiแrio)",;
																						oFont8)		// Texto Fixo
oPrint:Say  (nLin+1100,0100,	"Juros / Mora por dia : 0,33%,  R$ "+  alltrim(	Transform((0.0033*aDadTit[8]),"@E 9999,999,999.99"))+" ao dia ",	oFont10)	// 1a Linha Instru็ใo
oPrint:Say  (nLin+1150,0100,	"Protesto Automแtico ap๓s 5 dias de atraso",											oFont10)	// 2a. Linha Instru็ใo
oPrint:Say  (nLin+1200,0100,	"Dep๓sito em conta nใo quita o boleto.",											oFont10)	// 3a. Linha Instru็ใo
oPrint:Say  (nLin+1250,0100,	"D๚vidas: envie e-mail para contasareceber@vitasons.com.br"	,										oFont10)	// 4a. Linha Instru็ใo
//oPrint:Say  (nLin+2550,0100,	aDadTit[14],											oFont10)	// 4a. Linha Instru็ใo
//oPrint:Say  (nLin+2600,0100,	aDadTit[15],											oFont10)	// 5a. Linha Instru็ใo
//oPrint:Say  (nLin+2650,0100,	aDadTit[16],											oFont10)	// 6a. Linha Instru็ใo

oPrint:Say  (nLin+2340,1810,	"(-)Desconto/Abatimento",								oFont8)		// Texto Fixo
oPrint:Say  (nLin+2410,1810,	"(-)Outras Dedu็๕es",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+2480,1810,	"(+)Mora/Multa",										oFont8)		// Texto Fixo
oPrint:Say  (nLin+2550,1810,	"(+)Outros Acr้scimos",									oFont8)		// Texto Fixo
oPrint:Say  (nLin+2620,1810,	"(=)Valor Cobrado",										oFont8)		// Texto Fixo

oPrint:Say  (nLin+2690,0100,	"Pagador",												oFont8)		// Texto Fixo
oPrint:Say  (nLin+2700,0200,	aDadCli[3],												oFont10)	// Nome Cliente 
//oPrint:Say  (nLin+2700,0200,	" ("+aDadCli[1]+"-"+aDadCli[2]+") "+aDadCli[3],		oFont10)	// Nome Cliente + C๓digo

If aDadCli[6] = "J"
	oPrint:Say  (nLin+2700,1850,	"CNPJ: "+Transform(aDadCli[4],"@R 99.999.999/9999-99"),			oFont10)	// Endere็o
Else
	oPrint:Say  (nLin+2700,1850,	"CPF: "+Transform(aDadCli[4],"@R 999.999.999-99"),			oFont10)	// Endere็o
EndIf

oPrint:Say  (nLin+2753,0200,	Alltrim(aDadCli[7])+" "+AllTrim(aDadCli[8]),			oFont10)	// Endere็o
oPrint:Say  (nLin+2806,0200,	Transform(aDadCli[11],"@R 99999-999")+" - "+;
								AllTrim(aDadCli[9])+" - "+AllTrim(aDadCli[10]),		oFont10)	// CEP + Cidade + Estado

oPrint:Say  (nLin+2806,1850,	aBarra[4],												oFont10)	// Carteira + Nosso N๚mero

oPrint:Say  (nLin+2855,0100,	"Pagador/Avalista" + if( !empty(cAvalista)," - " + Rtrim(cAvalista),""), oFont8)		// Texto Fixo + Sacador Avalista
oPrint:Say  (nLin+2895,1500,	"Autentica็ใo Mecโnica - Ficha de Compensa็ใo",			oFont8)		// Texto Fixo

oPrint:Line (nLin+1980,1800,nLin+2670,1800)														// Quadro
oPrint:Line (nLin+2390,1800,nLin+2390,2300)														// Quadro
oPrint:Line (nLin+2460,1800,nLin+2460,2300)														// Quadro
oPrint:Line (nLin+2530,1800,nLin+2530,2300)														// Quadro
oPrint:Line (nLin+2600,1800,nLin+2600,2300)														// Quadro
oPrint:Line (nLin+2670,0100,nLin+2670,2300)														// Quadro
oPrint:Line (nLin+2870,0100,nLin+2870,2300)														// Quadro

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se Impressใo em polegadas ณ
//ณ Guarabira                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTpImp == 1
	oPrint:FwMSBAR("INT25" ,52,1   ,aBarra[1],oPrint,.F.   ,Nil  ,Nil  ,0.017     ,1   ,Nil    ,Nil,"A"  ,.F. ) //datasupri
Else        
	oPrint:FwMSBAR("INT25" ,52,1   ,aBarra[1],oPrint,.F.   ,Nil  ,Nil  ,0.017     ,1   ,Nil    ,Nil,"A"  ,.F. ) //datasupri
EndIf

oPrint:EndPage() // Finaliza a pแgina
oPrint:Preview()     // Visualiza antes de imprimir

SE1->(dbSetOrder(1), dbSeek(xFilial("SE1")+aDadTit[1]+aDadTit[2]+aDadTit[3]))
SA1->(dbSetOrder(1), dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

cArquivo := 'C:\TEMP\'+cFilename+'.PDF' //AllTrim('\system\bol'+SE1->E1_NUM+"_pag1.jpg")
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ TCArqRem ณ Retorna conte๚dos para o arquivo de remessa dos bancos       บฑฑ
ฑฑบ             ณ          ณ                                                              บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 08.02.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpC1 = nome do campo que deverแ ser retornado                          บฑฑ
ฑฑบ             ณ ExpN1 = Tamanho do campo                                                บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpC1 = String para preenchimento do campo                              บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
	cMensag4    := "Titulo entregue em cessใo fiduciแria em favor do beneficiแrio acima."
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se passou os parโmetros para a fun็ใo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (aDadTit == Nil .Or. ValType(aDadTit) <> "A") .Or.;
	(aDadCli == Nil .Or. ValType(aDadCli) <> "A") .Or.;
	(aBarra == Nil .Or. ValType(aBarra) <> "A")
	Aviso(	"Biblioteca de Fun็๕es",;
			"Os parโmetros passados por refer๊ncia estใo fora dos padr๕es."+Chr(13)+Chr(10)+;
			"Verifique a chamada da fun็ใo no programa de origem.",;
			{"&Continua"},2,;
			"Chamada Invแlida" )
	lRet	:= .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se os arquivos estใo posicionados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SE1->(Eof()) .Or. SE1->(Bof())
	Aviso(	"Biblioteca de Fun็๕es",;
			"O arquivo de Tํtulos a Receber nใo esta posicionado.",;
			{"&Continua"},,;
			"Registro Invแlido" )
	lRet	:= .F.
EndIf
If SA1->(Eof()) .Or. SA1->(Bof())
	Aviso(	"Biblioteca de Fun็๕es",;
			"O arquivo de Clientes nใo esta posicionado.",;
			{"&Continua"},,;
			"Registro Invแlido" )
	lRet	:= .F.
EndIf

aDadTit	:= {	"",;					// [1] Prefixo do Tํtulo
				"",;					// [2] N๚mero do Tํtulo
				"",;					// [3] Parcela do Tํtulo
				"",;					// [4] Tipo do tํtulo
				CToD("  /  /  "),;		// [5] Data de Emissใo do tํtulo
				CToD("  /  /  "),;		// [6] Data de Vencimento do Tํtulo
				CToD("  /  /  "),;		// [7] Data de Vencimento Real
				0,;						// [8] Valor Lํquido do Tํtulo
				"",;					// [9] C๓digo do Barras Formatado
				"",;					// [10]Carteira de Cobran็a
				"",;					// [11]1.a Linha de Mensagens Diversas
				"",;					// [12]2.a Linha de Mensagens Diversas
				"",;					// [13]3.a Linha de Mensagens Diversas
				"",;					// [14]4.a Linha de Mensagens Diversas
				"",;					// [15]5.a Linha de Mensagens Diversas
				"" ;					// [16]6.a Linha de Mensagens Diversas
				}
aDadCli	:= {	"",;					// [1] C๓digo do cliente
				"",;					// [2] Loja do Cliente
				"",;					// [3] Nome Completo do Cliente
				"",;					// [4] CNPJ do Cliente
				"",;					// [5] Inscri็ใo Estadual do cliente
				"",;					// [6] Tipo de Pessoa do Cliente
				"",;					// [7] Endere็o
				"",;					// [8] Bairro
				"",;					// [9] Municํpio
				"",;					// [10] Estado
				"",;					// [11] Cep
				"" ;					// [12] Via de entrega (Correio/Nota)
				}
aBarra	:= {	"",;					// [1] C๓digo de barras (Banco+"9"+Dํgito+Fator+Valor+Campo Livre
				"",;					// [2] Linha Digitแvel
				"",;					// [3] Nosso N๚mero sem formata็ใo
				"" ;					// [4] Nosso N๚mero Formatado
				}

If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Alimenta array com os dados do cliente ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
			aDadCli[12]	:= ""//"CAMINHรO"

		EndIf
	Else
		aDadCli[7]	:= SA1->A1_END
		aDadCli[8]	:= SA1->A1_BAIRRO
		aDadCli[9]	:= SA1->A1_MUN
		aDadCli[10]	:= SA1->A1_EST
		aDadCli[11]	:= SA1->A1_CEP
		aDadCli[12]	:= ""//"CORREIO"
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta o saldo do tํtulo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lSaldo
		nSaldo	:= SE1->E1_SALDO
	Else
		nSaldo	:= SE1->E1_VALOR
	EndIf    
//	nSaldo  := SALDOTIT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,1,DDatabase,,SE1->E1_LOJA)
	nSaldo	-= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nSaldo	-= SE1->E1_DECRESC
	nSaldo	+= SE1->E1_ACRESC

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Pega ou monta o nosso n๚mero ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define a carteira de cobran็a ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//	If Empty(SEE->EE_SUBCTA)
	If Empty(SEE->EE_CODCART)
		cCarteira	:= "101"
	Else
//		cCarteira	:= SEE->EE_SUBCTA
		cCarteira	:= SEE->EE_CODCART
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta o C๓digo de Barras e Linha Digitแvel ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Taxa de juros a ser utilizado no cแlculo de juros de mora ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*
	If !Empty(aDadBco[10])
		cMensag1	:= "Mora Diแria de R$ "+AllTrim(Transform( Round( ( nSaldo * (aDadBco[10]/100) ) / 30, 2), "@E 999,999,999.99"))
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Taxa de multa a ser impressa no boleto ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(aDadBco[11])
		cMensag2	:= "Multa por atraso no pagamento - " + AllTrim(Transform( aDadBco[11], "@E 999,999.99%"))
	EndIf
	*/
/*
	
	cMensag1 := "Multa de 10% ap๓s o vencimento."
	cMensag2 := "Juros de 5% ao m๊s pro rata ap๓s o vencimento."
*/

//	cMensag1 := "Multa de 2% ap๓s o vencimento."
//	cMensag1 := "Cobrar Mora diแria de "   + AllTrim(Transform( Round ( nSaldo * 0.01 / 30, 2 ) , "@E 999,999,999.99"))
//	cMensag2 := "Cobrar 5% de multa ap๓s o vencimento."
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ N๚mero de dias para envio do tํtulo ao cart๓rio ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*
	If !Empty(aDadBco[12]) .AND. SA1->A1_PROTEST <> '2' 
		cMensag3	:= "Protestar ap๓s " + StrZero(aDadBco[12], 2) + " (" + AllTrim(Extenso(aDadBco[12],.T.)) + ") dias ๙teis"
	EndIf
    */
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Alimenta array com os dados do tํtulo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//	aDadTit[1]	:= SE1->E1_PREFIXO		// [1] Prefixo do Tํtulo
//	aDadTit[2]	:= SE1->E1_NUM			// [2] N๚mero do Tํtulo
//	aDadTit[3]	:= SE1->E1_PARCELA		// [3] Parcela do Tํtulo
//	aDadTit[4]	:= SE1->E1_TIPO			// [4] Tipo do tํtulo
//	aDadTit[5]	:= SE1->E1_EMISSAO		// [5] Data de Emissใo do tํtulo
//	aDadTit[6]	:= SE1->E1_VENCREA  	// [6] Data de Vencimento do Tํtulo
//	aDadTit[7]	:= SE1->E1_VENCREA		// [7] Data de Vencimento Real
//	aDadTit[8]	:= nSaldo				// [8] Valor Lํquido do Tํtulo
//	aDadTit[9]	:= aBarra[4]			// [9] C๓digo do Barras Formatado
//	aDadTit[10]	:= cCarteira			// [10]Carteira de Cobran็a
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa    ณ GetBarra ณ Cแlcula o c๓digo de barras, linha digitแvel e dํgito do      บฑฑ
ฑฑบ             ณ          ณ nosso n๚mero                                                 บฑฑ
ฑฑฬอออออออออออออุออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Autor       ณ 20.01.07 ณ                                                          บฑฑ
ฑฑฬอออออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parโmetros  ณ ExpC1 = C๓digo do Banco                                                 บฑฑ
ฑฑบ             ณ ExpC2 = N๚mero da Ag๊ncia                                               บฑฑ
ฑฑบ             ณ ExpC3 = Dํgito da Ag๊ncia                                               บฑฑ
ฑฑบ             ณ ExpC4 = N๚mero da Conta Corrente                                        บฑฑ
ฑฑบ             ณ ExpC5 = Dํgito da Conta Corrente                                        บฑฑ
ฑฑบ             ณ ExpC6 = Carteira                                                        บฑฑ
ฑฑบ             ณ ExpC7 = Nosso N๚mero sem dํgito                                         บฑฑ
ฑฑบ             ณ ExpN1 = Valor do Tํtulo                                                 บฑฑ
ฑฑบ             ณ ExpD1 = Data de Vencimento                                              บฑฑ
ฑฑบ             ณ ExpC8 = N๚mero do Contrato                                              บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno     ณ ExpL1 = .T. montou os arrays corretamento, .F. nใo montou os arrays     บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Observa็๕es ณ Os arquivos devem estar posicionados SE1, SA1, SEE, SA6                 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Altera็๕es  ณ 99.99.99 - Consultor - Descri็ใo da altera็ใo                           บฑฑ
ฑฑบ             ณ                                                                         บฑฑ
ฑฑศอออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                 Definicao do NOSSO NฺMERO E CAMPO LIVRE                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ BRASIL                                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cBanco $ "001"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao do Campo Livre (25 posi็๕es)                              ณ
	//ณ                                                                     ณ
	//ณSOMENTE PARA AS CARTEIRAS 16/18 (com conv๊nios de 6 posi็๕es)        ณ
	//ณ20 a 25 - (06) - N๚mero do Conv๊nio                                  ณ
	//ณ26 a 42 - (17) - Nosso N๚mero                                        ณ
	//ณ43 a 44 - (02) - Carteira de cobran็a                                ณ
	//ณ                                                                     ณ
	//ณSOMENTE PARA AS CARTEIRAS 17/18                                      ณ
	//ณ20 a 25 - (06) - Fixo 0                                              ณ
	//ณ26 a 32 - (07) - N๚mero do conv๊nio                                  ณ
	//ณ33 a 42 - (10) - Nosso Numero (sem o digito verificador)             ณ
	//ณ43 a 44 - (02) - Carteira de cobran็a                                ณ
	//ณ                                                                     ณ
	//ณComposicao do Nosso N๚mero                                           ณ
	//ณ01 a 06 - (06) - N๚mero do Conv๊nio (SEE->EE_CODEMP)                 ณ
	//ณ07 a 11 - (05) - Nosso N๚mero (SEE->EE_FAXATU)                       ณ
	//ณ12 a 12 - (01) - Dํgito do Nosso N๚mero (Modulo 11)                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carteira 16/18 - Conv๊nio com 6 posi็oes                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(AllTrim(cContrato)) > 6
		Cs		:= AllTrim(cContrato) + cNNum + cCarteira
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carteira 17/18 - Conv๊nio com mais de 6 posi็oes                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else
		Cs		:= "000000" + AllTrim(cContrato) + cNNum + cCarteira
	EndIf
	cDvNN		:= U_TCCalcDV( cBanco, cS )		//Modulo11(cS)
	cNN			:= AllTrim(cContrato) + cNNum + cDvNN
	cNNForm		:= AllTrim(cContrato) + cNNum
//	cNNForm		:= AllTrim(cContrato) + cNNum + "-" + cDvNN
	cCpoLivre	:= ""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ BRADESCO                                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf 	cBanco $ "237"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao do Campo Livre (25 posi็๕es)                              ณ
	//ณ                                                                     ณ
	//ณ
	
	
*/	