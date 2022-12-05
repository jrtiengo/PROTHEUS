#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    
#Include "Rwmake.ch"
#Include "TopConn.ch"
#Define ENTER CHR(13)+CHR(10)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: PE_TECA450.PRW                                                           ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Lucas Moresco                                                            ##
// Data......: 14/06/2011                                                               ##
// Autor.....: Pietro Lopes                                                             ##
// Data......: 03/07/2018                                                               ##
// Objetivo..: {Protheus.doc} PE_TECA450                                                ##
//              P.E. na Ordem de Servico.                                               ##
// ------------------------------------------------------------------------------------ ##
//             {Protheus.doc} AT450GRV                                                  ##
//              P.E. na gravacao da Ordem de Servico.                                   ##
// #######################################################################################
User Function AT450GRV()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local _aArea       := GetArea()
   Local _aAreaSC5    := GetArea()
   Local _aAreaAB6    := GetArea("AB6")
   Local _aAreaAB7    := GetArea("AB7")
   Local _aAreaAB8    := GetArea("AB8")
   Local _aAreaAA3    := GetArea("AA3")
   Local _nPosMemo    := GdFieldPos("AB7_MEMO2")
   Local cSql         := ""
   Local cCodPV       := ""
   Local cCodFL       := ""
   Local lEncerra     := .F.
   Local lContrEnd    := .F.
   Local nLaco        := 0
   Local lApontamento := CheckAB8()
   Local lTroca       := .F.
   Local ix

   Private lMsHelpAuto 	  := .T.
   Private lMsErroAuto 	  := .F.
   Private lAutoErrNoFile := .T.
   Private lEnvEmail      := !Empty(AllTrim(Posicione('SU5',1,xFilial('SU5')+AB6_CONTWF,'U5_EMAIL')))
   Private _Email 	     := AllTrim(Posicione('SU5',1,xFilial('SU5')+AB6->AB6_CONTWF,'U5_EMAIL'))
   Private _cNomeCli      := AllTrim(Posicione("SA1",1,xFilial("SA1")+AB6_CODCLI+AB6_LOJA,"A1_NOME"))
   Private cCodMen7       := ""
   Private cCodMen5       := ""
   Private _cMemoV        :=""

   Private yNumOS	        := AllTrim(M->AB6_NUMOS) + AllTrim(cFilAnt)
   Private yACliente      := AB6_CODCLI
   Private yALoja	        := AB6_LOJA
   Private yANome         := AllTrim(Posicione("SA1",1, xFilial("SA1") + AB6_CODCLI + AB6_LOJA,"A1_NOME"))

   Private aNovoCliente   := {}
   Private cComboBx1

   Private kk_Cliente     := Space(06)
   Private kk_Loja        := Space(03)
   Private cInfoFat       := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oMemo3

   Private oDlg

   U_AUTOM628("PE_TECA450")

   // ####################################################################
   // Pesquisa as informações de faturamento do cliente do cadastro SA1 ##
   // ####################################################################
   If Select("T_FATURAR") > 0
 	  T_FATURAR->( dbCloseArea() )
   EndIf
                                                                                  
   cSql := ""
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA,"
   cSql += "       A1_NOME,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A1_IFAT )) AS INFOFATURAR "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += "  WHERE A1_COD     = '" + Alltrim(AB6_CODCLI) + "'"
   cSql += "    AND A1_LOJA    = '" + Alltrim(AB6_LOJA)   + "'"
   cSql += "    AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY A1_COD, A1_LOJA"
	 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FATURAR", .T., .T. )

   cInfoFat := IIF(Empty(Alltrim(T_FATURAR->INFOFATURAR)), "", T_FATURAR->INFOFATURAR)

   // ############################################################################
   // Carrega o combo aClientes com as lojas do raiz do código do cliente da OS ##
   // ############################################################################
   If Select("T_CLIENTE") > 0
 	  T_CLIENTE->( dbCloseArea() )
   EndIf
                                                                                  
   cSql := ""
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA,"
   cSql += "       A1_NOME "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += "  WHERE A1_COD     = '" + Alltrim(AB6_CODCLI) + "'"
   cSql += "    AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY A1_COD, A1_LOJA"
	 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   T_CLIENTE->( DbGoTop() )
   
   WHILE !T_CLIENTE->( EOF() )
      aAdd( aNovoCliente, T_CLIENTE->A1_COD + "." + T_CLIENTE->A1_LOJA + " - " + Alltrim(T_CLIENTE->A1_NOME) )

      If Alltrim(T_CLIENTE->A1_LOJA) == Alltrim(AB6_LOJA)
         cComboBx1 := T_CLIENTE->A1_COD + "." + T_CLIENTE->A1_LOJA + " - " + Alltrim(T_CLIENTE->A1_NOME)
      Endif

      T_CLIENTE->( DbSkip() )
   ENDDO   

   // ############################################################################################################
   // Em caso de efetivação da Ordem de Servico, processo verifica se existe a informação do codigo do vendedor ##
   // Se nao existir, vai gravar (hardcode) o codigo do vendedor conforme a filial da OS.                       ##
   // ############################################################################################################
   If FunName() == "TECA450" .And. !Inclui
	
	   cNumOs := AllTrim(M->AB6_NUMOS) && + AllTrim(cFilAnt)
	
      // ######################################################################################################################
      // Solicita a troca do cnpj do cliente para o pedido de venda pois o mesmo ode ser faturado para outra loja do cliente ##
      // ######################################################################################################################
      // If procname(7) == "AT450GRVPV"
      If procname(10) == "AT450GRVPV"

         If _Lefetiva == .T.

            // ##################################################################################################
            // Verifica se existe regra para baixa de consumo na OS. Se tiver, não pergunta se troca o cliente ##
            // ##################################################################################################
            If Select("T_SERVICOS") > 0
               T_SERVICOS->( dbCloseArea() )
            EndIf

            cSql := ""                                                                                                    
            cSql := "SELECT AB8.AB8_FILIAL,"
            cSql += "       AB8.AB8_NUMOS ,"
            cSql += "       AB8.AB8_CODSER,"
            cSql += "       AB8.AB8_CODPRO,"
            cSql += "       AB8.AB8_CODCLI," 
            cSql += "       AB8.AB8_LOJA  ," 
            cSql += "       AB8.AB8_NUMPV ,"
            cSql += "       SA1.A1_EST    ,"
            cSql += "       SB1.B1_GRTRIB ,"
            cSql += "       ZP6.ZP6_TES   ,"
            cSql += "       ZP6.ZP6_TES2  ,"
            cSql += "       ZP6.ZP6_FATU   "
            cSql += "  FROM " + RetSqlName("AB8") + " AB8 (NOLOCK), " 
            cSql += "       " + RetSqlName("SB1") + " SB1 (NOLOCK), "
            cSql += "       " + RetSqlName("ZP6") + " ZP6 (NOLOCK), "
            cSql += "       " + RetSqlName("SA1") + " SA1 (NOLOCK)  "
            cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(cFilAnt)      + "'"
            cSql += "   AND AB8.AB8_NUMOS  = '" + ALLTRIM(M->AB6_NUMOS) + "'"
            cSql += "   AND AB8.D_E_L_E_T_ = ''            "
            cSql += "   AND SB1.B1_COD     = AB8.AB8_CODPRO"
            cSql += "   AND SB1.D_E_L_E_T_ = ''            "
            cSql += "   AND ZP6.ZP6_SERV   = AB8.AB8_CODSER"
            cSql += "   AND ZP6.ZP6_GRUP   = SB1.B1_GRTRIB "
            cSql += "   AND AB8.AB8_CODCLI = SA1.A1_COD    "
            cSql += "   AND AB8.AB8_LOJA   = SA1.A1_LOJA   "
            cSql += "   AND SA1.D_E_L_E_T_ = ''            "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICOS", .T., .T. )
           
            // ############################################################################################################
            // Verifica se há a necessidade de trocar o código do cliente no pedido de venda para o código da Automatech ##
            // Se pelo menos um dos serviços estiver marcado para faturar como Automatech, não solicita troca de loja.   ##
            // ############################################################################################################

            T_SERVICOS->( DbGoTop() )

            lTroca := .F.
   
            // ----------------------------------------------------------------------------- //
            // Card 3010 -  AUTOMATECH - Alteração de Regra Cliente no Pedido de Venda da OS //
            // Alterado por Harald Hans Löschenkohl em 18/05/2021.                           // 
            // ----------------------------------------------------------------------------- //
            // Conforme solicitação do Cliente, não será mais utilizado o faturamento contra //
            // a Automatech em caso de localização de parametrização de TEs na tabela ZP6.   //
            // ----------------------------------------------------------------------------- //
            // WHILE !T_SERVICOS->( EOF() )
            //
            //   If T_SERVICOS->ZP6_FATU == "1"
            //      lTroca := .T.
            //      Exit
            //   Endif
            //
            //   T_SERVICOS->( DbSkip() )
            //
            // ENDDO
            //
            // If lTroca == .T.
            //
            //   kk_Cliente := AB6_CODCLI
            //   kk_Loja    := AB6_LOJA
            //
            //Else
               DEFINE MSDIALOG oDlg TITLE "Efetivação de Ordem de Serviço" FROM C(176),C(180) TO C(619),C(652) PIXEL Style DS_MODALFRAME
               oDlg:lEscClose := .F.
               @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg
               @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(232),C(001) PIXEL OF oDlg
               @ C(202),C(002) GET oMemo2 Var cMemo2 MEMO Size C(230),C(001) PIXEL OF oDlg
               @ C(037),C(005) Say "OS Nº" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
               @ C(046),C(145) Say "Alteração de CNPJ para faturamento" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlg
               @ C(059),C(005) Say "Pedido de Venda será faturado para:" Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlg
               @ C(083),C(005) Say "Trocar Loja de Faturamento do Pedido de Venda para:" Size C(132),C(008) COLOR CLR_BLACK PIXEL OF oDlg
               @ C(106),C(005) Say "INFORMAÇÕES IMPORTANTES PARA O FATURAMENTO DA OS" Size C(164),C(008) COLOR CLR_BLACK PIXEL OF oDlg
               @ C(046),C(005) MsGet    oGet1     Var   yNumOS       Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
               @ C(069),C(005) MsGet    oGet2     Var   yACliente    Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
               @ C(069),C(032) MsGet    oGet3     Var   yALoja       Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
               @ C(069),C(057) MsGet    oGet4     Var   yANome       Size C(175),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
               @ C(092),C(005) ComboBox cComboBx1 Items aNovoCLiente Size C(227),C(010) PIXEL OF oDlg
               @ C(115),C(005) GET oMemo3 Var cInfoFat MEMO Size C(227),C(083) PIXEL OF oDlg
               @ C(205),C(195) Button "Confirma"  Size C(037),C(012) PIXEL OF oDlg ACTION( kk_Cliente := Substr(cComboBx1,01,06), kk_Loja := Substr(cComboBx1,08,03), oDlg:End() )
               ACTIVATE MSDIALOG oDlg CENTERED 
            // Endif   
         
         Else
      
            kk_Cliente := AB6_CODCLI
            kk_Loja    := AB6_LOJA
      
         Endif   
         
      Endif   

	  If Select("T_PEDIDO") > 0
		 T_PEDIDO->( dbCloseArea() )
	  EndIf
	
	  cSql := ""
	  cSql := "SELECT C6_FILIAL ,"
	  cSql += "       C6_NUM    ,"
	  cSql += "       C6_NUMOS  ,"
     cSql += "       C6_ITEM   ,"
	  cSql += "       C6_PRODUTO "
	  cSql += "  FROM " + RetSqlName("SC6")
	  cSql += " WHERE SUBSTRING(C6_NUMOS,01,06) = '" + Alltrim(cNumOs) + "'"
     cSql += "   AND C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
     cSql += "   AND D_E_L_E_T_ = ''
	 
	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )
	
	  T_PEDIDO->( DbGoTop() )
	
	  If !T_PEDIDO->( Eof() )
		
	     cCodPV := T_PEDIDO->C6_NUM
		  cCodFL := T_PEDIDO->C6_FILIAL
		
		  DbSelectArea("SC5")
		  DbSetOrder(1)
		
		  If DbSeek(cCodFL + cCodPV)
			
			Reclock("SC5", .F.)
			
			DO CASE
				CASE SC5->C5_FILIAL == "01"
				   	 SC5->C5_VEND1 := "000084"
				CASE SC5->C5_FILIAL == "02"
					 SC5->C5_VEND1 := "000085"
				CASE SC5->C5_FILIAL == "03"
					 SC5->C5_VEND1 := "000086"
			ENDCASE
			
            // ###############################
            // Atualiza o código do cliente ##
            // ###############################
            //If lTroca == .F.
               SC5->C5_CLIENTE := kk_Cliente
               SC5->C5_LOJACLI := kk_Loja
               SC5->C5_CLIENT  := kk_Cliente
               SC5->C5_LOJAENT := kk_Loja
            //Endif   

			MsunLock()
			
		 Endif

         // ########################################################################
         // Atualiza o código do cliente na tabela de produtos do pedido de venda ##
         // ########################################################################
   	     T_PEDIDO->( DbGoTop() )
     	 
     	 WHILE !T_PEDIDO->( EOF() )
 		    
 		    DbSelectArea("SC6")
    		DbSetOrder(1)
 		
 		    If DbSeek(cCodFL + cCodPV + T_PEDIDO->C6_ITEM + T_PEDIDO->C6_PRODUTO)

 			   Reclock("SC6", .F.)

               //If ltroca == .F.
                  SC6->C6_CLI  := kk_Cliente
                  SC6->C6_LOJA := kk_Loja			
               //Endif   

               // ##########################################################################################################
               // Foi inserido aqui este teste porque a prefeitura de Caxias do Sul não aceita o código do Iss com ponto. ##
               // O gatilho C6_PRODUTO (007) não está sendo executado no processo da efetivação de OS                     ##
               // ##########################################################################################################
               If cEmpAnt == "01" .AND. cFilAnt == "02"

                  k_Grupo        := Posicione("SA1", 1, xFilial("SA1") + kk_Cliente + kk_Loja, "A1_GRPTRIB")
                  SC6->C6_CODISS := STRTRAN(SC6->C6_CODISS, ".", "")

                  If Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_TIPO") == "MO"
                     k_Operacao  := "06"
                  Else
                     k_Operacao  := IIF(k_Grupo == "002", "03", "02")                  
                  Endif
                  
//                k_Grupo     := Posicione("SA1", 1, xFilial("SA1") + kk_Cliente + kk_Loja, "A1_GRPTRIB")
                  K_TES := MaTesInt(2, k_Operacao, kk_Cliente, kk_loja, "C", T_PEDIDO->C6_PRODUTO)
                  SC6->C6_TES := k_TES

               Endif

    		   MsunLock()
               
            Endif
             
            T_PEDIDO->( DbSkip() )
 
         ENDDO            

         // ##################################################
         // Tarefa #2943 - Envio de E-mail de OS encerrada  ##
         // ##################################################
         U_AUTOM350(cFilAnt, M->AB6_NUMOS)
		
  	  Endif

      // ######################################################################################
      // Envia para a função que avalia a informação do código do cliente no pedido de venda ##
      // ########################################################################################
      FaltaCliente(cNumOs)
         
      // #############################################################################
      // Grava na tabela ZZZ o Nº e a Filial do pedido de venda para a OS efetivada ##
      // #############################################################################
	  T_PEDIDO->( DbGoTop() )
	
	  WHILE !T_PEDIDO->( Eof() )

		 DbSelectArea("ZZZ")
		 DbSetOrder(1)
		
		 If DbSeek(T_PEDIDO->C6_FILIAL + M->AB6_NUMOS + T_PEDIDO->C6_PRODUTO)
			
			Reclock("ZZZ", .F.)
		    ZZZ->ZZZ_NUMPV := T_PEDIDO->C6_NUM
		    ZZZ->ZZZ_NUMFL := T_PEDIDO->C6_FILIAL
			MsunLock()
			
		 Endif
		 
		 T_PEDIDO->( DbSkip() )
		 
	  ENDDO	 
	
      // ##########################################################################################################
      // Envia para o programa que libera o produtos de serviços do pedido de venda da OS da Assistência Técnica ##
      // ##########################################################################################################
	  If Select("T_CONSULTA") > 0
		 T_CONSULTA->( dbCloseArea() )
	  EndIf
	
	  cSql := ""
	  cSql := "SELECT TOP(1) C6_FILIAL ,"
 	  cSql += "              C6_NUM     "
	  cSql += "  FROM " + RetSqlName("SC6")
	  cSql += " WHERE SUBSTRING(C6_NUMOS,01,06) = '" + Alltrim(cNumOs) + "'"
	  cSql += "   AND C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND D_E_L_E_T_ = ''

	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      U_AUTOM618(T_CONSULTA->C6_FILIAL, T_CONSULTA->C6_NUM, 1)

   Endif

   // ###########################
   // Atualiza a tabela de log ##
   // ###########################
   dbSelectArea("ZS1")
   RecLock("ZS1",.T.)
   ZS1_FILIAL := cFilAnt
   ZS1_TECN   := Alltrim(cUserName)
   ZS1_DATA   := DATE()
   ZS1_HORA   := TIME()
   ZS1_OPER   := IIF(INCLUI, "I", "A")
   ZS1_TIPO   := "S"
   ZS1_ETIQ   := M->AB6_ETIQUE
   ZS1_NUMOS  := M->AB6_NUMOS
   MsUnLock()

   // ##################
   // Fabiano Pereira ##
   // ##################   
   If ((Inclui .Or. Altera) .And. ProcName(4)  == "EXECUTE")

	   For ix := 1 To Len(aColsAb8[1])
		
		  DbSelectArea("ZZZ")
		  DbSetOrder(2)
		
		  If ( DbSeek(xFilial("ZZZ")+AB6->AB6_NUMOS+aColsAb8[1][ix][GdFieldPos("AB8_SUBITE",aHeaderAb8)]) .And. Altera)
				
			 If(ZZZ->ZZZ_PRODUT  <> aColsAb8[1][ix][GdFieldPos("AB8_CODPRO",aHeaderAb8)] .Or. ;
			 	ZZZ->ZZZ_LOCAL   <> aColsAb8[1][ix][GdFieldPos("AB8_LOCAL",aHeaderAb8)]  .Or. ;
	  		    ZZZ->ZZZ_QTDORI  <> aColsAb8[1][ix][GdFieldPos("AB8_QUANT",aHeaderAb8)] ) 
				       
			    ExcluiZZZ(ZZZ->ZZZ_ITAB8)
				    
			 ElseIf (aColsAb8[1][ix][GdFieldPos("AB8_REC_WT",aHeaderAb8) + 1]) 
					  	ExcluiZZZ(ZZZ->ZZZ_ITAB8)
			 EndIf
		
		  EndIf
			
	  Next ix
	
	  If (lApontamento)
		 GeraRequPeca()
	  Else
		 If (Inclui)
			M->AB6_APROV := "A"	
		 ElseIf (Altera)
			AB6->AB6_APROV := "A"	
		 EndIf
	 EndIf
	
	 If Inclui

	 	TcCommit(2,ProcName())    //Commit
	 	TcCommit(1,ProcName())    //Begin Tran novamente pois ao executar o commit ele finaliza o begin tran, e ocorre erro de end tran?
	
        // ####################################################################
        // Envia para o programa que grava a tabela ZTJ (Log para AtechInfo) ##
        // ####################################################################
        U_AUTOM322(1, "I", "PE_TECA450.PRW")

        // ############################################################### 
		// ENVIAR E-MAIL PARA O CLIENTE DA ABERTURA DA ORDEM DE SERVICO ##
		// ###############################################################
		If MsgYesNo("Deseja enviar e-mail de abertura da O.S. para o cliente?")      
	
	 	   If lEnvEmail
			  MsAguarde( {|| OpenOSCli()},'Envio E-mail','E-mail ABERTURA da OS - Cliente...' )
		   Else
			  MsgAlert("Cliente nao possui e-mail cadastrado. Verifique!"+ENTER+'E-mail Nao sera enviado!'+ENTER)
			  *********************************************************************
			  CliSemEmail(AB6->AB6_CODCLI, AB6->AB6_LOJA, _cNomeCli)
			  *********************************************************************
		   EndIf
		EndIf
			
        // #####################################################
		// IMPRESSAO DO COMPROVANTE DE ENTREGA DO EQUIPAMENTO ##
		// #####################################################
		ExecBlock('AUTOM109', .F., .F., {AB6->AB6_NUMOS} )

        // ########################################################
		// IMPRESSAO DA ETIQUETA NA ABERTURA DA ORDEM DE SERVICO ##
		// ########################################################
		U_AUTOMR55()

	 ElseIf Altera
		TcCommit(2,ProcName())    //Commit
		TcCommit(1,ProcName())    //Begin Tran novamente pois ao executar o commit ele finaliza o begin tran, e ocorre erro de end tran?

        // ####################################################################
        // Envia para o programa que grava a tabela ZTJ (Log para AtechInfo) ##
        // ####################################################################
        U_AUTOM322(1, "A", "PE_TECA450.PRW")

		//  VERIFICA SE EXISTE TECNICO ALOCADO PARA ATENDER A OS 								|
		//| VERIFICA TEMPO INICIO\FIM DA ABERTURA DA OS e GERA AUTOMATICAMENTE UM ATENDIMENTO OS|
		//| VIA EXECAUTO																		|
		//|																						|
		//| OBS.: CAMPO AB6_HORA GRAVA HORA DA ABERTURA DA OS									|
		//|		  CAMPO AB6_HORAI GRAVA INICIO DA ABERTURA DA OS (QDO. EXISTE TECNICO ALOCADO)	|
		//|		  CAMPO AB6_HORAF GRAVA FIM DA ABERTURA DA OS (QDO. EXISTE TECNICO ALOCADO)		|
		//|																						|
		//|	ENVIA WORKFLOW PARA CLIENTE PARA APROVACAO\REPROVACAO DA ORDEM DE SERVICO			|
		//|	IMPRIME RELATORIO DA OS																|
		//|																						|

		//If !Empty(Posicione("ABB",3,xFilial("ABB")+AB6->AB6_NUMOS,"ABB_NUMOS")) //TODO Lucas temporário para atender o desligue do agendamento automático

			If !lApontamento
				MsgAlert("Ordem de Servico sem informacao de Apontamento." +ENTER+ "Verifique os apontamentos !!!")
			EndIf
	
			//  VERIFICA TEMPO TOTAL DE ATENDIMENTO 
			cHoraI	  	:= 	AB6->AB6_HORAI					//	HORA INI ATENDIEMTNO - ANTES DE ABRIR A TELA PARA ALTERACAO EH GRAVADO TIME()
			cHoraF 	  	:=	Left(Time(),05)					//	HORA FIM ATENDIMENTO
			nHrAtend 	:= 	SubHoras(cHoraF,cHoraI)			//	TOTAL TEMPO ATENDIMENTO
			nTotalHr	:=	TotalHrAB9(nHrAtend)

			DbSelectArea('AB6')
			RecLock('AB6', .F.)
				AB6->AB6_HORAF  := StrTran(cHoraF, '.', ':')	//  AO CONFIRMAR OS GRAVA HORA FINAL
				AB6->AB6_TOTALH := nTotalHr						//	CHECA O TOTAL DE HORAS NOS ATENDIMENTOS DA OS - AB9
			MsUnLock()

			cCodPrb  := ''
			If ( (AB6->AB6_APROV == "L" .Or. AB6_APROV == "S" .Or. AB6_APROV == "N") .And. AB6_STATUS == "A" .And. lApontamento) 
				lEncerra := MsgYesNo("Deseja Finalizar a O.S. ?")
			EndIf
			
			//If !lApontamento
			//	Alert('Essa Ordem de Produção nao contem Apontamentos e nao sere fechada!')
			//	lEncerra := .F.
			//EndIf

            // Tarefa #2668 - Alterada por Harald Hans Löschenkohl em 09/06/2016
            // Envia e-mail ao cliente informando do encerramento da OS caso AB6_POSI == "E" e AB6_APROV == "S"
            // -------------------------------------------------------------------------------------------------------------------------------------
            // Em 16/08/2016 a chamada do programa AUTOM350 foi retirado deste ponto por solicitação do Sr. Ricardo Masiel conforme
            // Tarefa do Portal de nº #2943: E-mail de OS encerrada
            // Esta chamada foi colocada no ponto de entrada da efetivação da ordem de serviço e não mais no momento em que a OS é trocada de status
//          If AB6->AB6_POSI == "E" .And. AB6->AB6_APROV == "S"
//             U_AUTOM350(AB6->AB6_FILIAL, AB6->AB6_NUMOS)
//          Endif

			//   ARRAY PARA GERAR O EXECAUTO - TECA460
			DbSelectArea('AB6')
			DbSelectArea('AB7');DbSetOrder(1);DbGoTop() // AB7_FILIAL+AB7_NUMOS+AB7_ITEM
			If DbSeek(xFilial('AB7') + AB6->AB6_NUMOS, .F.)
				cCodPrb := AB7->AB7_CODPRB
			EndIf
	
			aCabec 	:= {}
			aItens	:= {}
		
			Aadd(aCabec,{'AB9_NUMOS' ,	AB6->AB6_NUMOS+'01'		 , Nil })
			Aadd(aCabec,{'AB9_SEQ'   ,  CheckSeqAB9()			 , Nil })
			Aadd(aCabec,{'AB9_CODTEC', 	ABB->ABB_CODTEC   	  	 , Nil })
	
			Aadd(aCabec,{'AB9_DTCHEG',  Date()					 , Nil })	//	DATA - INI
			Aadd(aCabec,{'AB9_HRCHEG',  StrTran(cHoraI, '.', ':'), Nil })	//	HORA - INI
			Aadd(aCabec,{'AB9_DTSAID',  Date()					 , Nil })	//	DATA + FIM
			Aadd(aCabec,{'AB9_HRSAID',  StrTran(cHoraF, '.', ':'), Nil })	//  HORA + FIM
	
			Aadd(aCabec,{'AB9_DTINI' ,  Date()					 , Nil })	// 	DATA - INI
			Aadd(aCabec,{'AB9_HRINI' ,  StrTran(cHoraI, '.', ':'), Nil })	//	HORA - INI
	      Aadd(aCabec,{'AB9_DTFIM' ,  Date()					 , Nil })	//	DATA + FIM
		  	Aadd(aCabec,{'AB9_HRFIM' ,  StrTran(cHoraF, '.', ':'), Nil })	//	HORA + FIM	
	
			Aadd(aCabec,{'AB9_CODPRB',  cCodPrb					 , Nil })
			Aadd(aCabec,{'AB9_TIPO'  ,  IIF(lEncerra, '1', '2')	 , Nil })	//	Status      1=Encerrado;2=Em Aberto

			Aadd(aCabec,{'AB9_RLAUDO',  AB6->AB6_RLAUDO   		 , Nil })	// 	Responsavel pelo Laudo   
			Aadd(aCabec,{'AB9_STATAR',  IIF(lEncerra, '1', '2')  , Nil })	// 	Status da Tarefa  - 1=Encerrado;2=Em Aberto

			// Aadd(aCabec,{'AB9_ENVIOA',  IIF(lEncerra, Date(), StoD('  \  \  ') )	 , Nil })
			// Aadd(aCabec,{AB9_MEMO1 ,      	, Nil })					

			// Aadd(aCabec,{'AB9_TOTFAT',	AB6->AB6_TOTALH		 , Nil })  	//  Horas Faturadas - Sistema cria automaticamente esse campo
			// Aadd(aCabec,{'AB9_ETIQUE',  	AB6->AB6_NUMOS		 , Nil })   //	Sistema cria automaticamente esse campo
			// Aadd(aCabec,{'AB9_CODCLI',  	AB6->AB6_CODCLI   	 , Nil })	//	Sistema cria automaticamente esse campo
			// Aadd(aCabec,{'AB9_LOJA'  ,  	AB6->AB6_LOJA   	 , Nil })	//	Sistema cria automaticamente esse campo
			

		    If (AB6->AB6_STATUS <> "B" .And. (! Empty(aItens) .Or. lEncerra))
				DbSelectArea('AB9')
				MsAguarde( {|| MSExecAuto( {|x, y, z| TECA460(x, y, z)}, aCabec,  aItens, 3)},'Processando','Gerando Apontamento de OS '+IIF(lEncerra,'-Fechamento','...'))

				// TECA460(aCabec,  aItens, 3)
				// At900IncAt(aCabec,  aItens, 3)
		
			  	If lMsErroAuto
					MostraErro()        
		        EndIf
			EndIf
	        
	        /*
	        If (! Empty(M->AB6_MEMO8))
				AB6->AB6_MEMO7 := cCodMen7
			Else
				AB6->AB6_MEMO7 := ""
			EndIf
		
			If (! Empty(M->AB6_MEMO6))
	   			AB6->AB6_MEMO5 := cCodMen5
	  		Else
				AB6->AB6_MEMO5 := ""
	  		EndIf
	  		*/
	 
			//If lEncerra
		
				//  WF PARA CLIENTE COM APROV\REPROVACAO DA ORDEM DE SERVICO
				 
			If (lApontamento .And. ! lEncerra .And. !(AB6->AB6_APROV $ "SP"))
				If ( MsgYesNo("Deseja enviar o Orcamento para o cliente?") )
				 	ExecBlock('AUTOMWFOS', .F., .F.)
				EndIf
			EndIf
	    		
			//  IMPRESSAO DO RELATORIO DA OS
			// ExecBlock('SOL1AUTOMR01', .F., .F., {'OS'} )

			//EndIf

		//EndIf //TODO Lucas temporário para atender o desligue do agendamento automático.

   	EndIf

   EndIf

   //If procname(7) == "AT450GRVPV" //AP PONTO DE ENTRADA AT450OKE

   If procname(10) == "AT450GRVPV" //AP PONTO DE ENTRADA AT450OKE
	   If _lEfetiva == .T. // EFETIVANDO A OS QUANDO CONTER SERVICO 0% CLIENTE E 0% FABRICANTE - AT450OKE 
		   DBSelectArea("AB6")     
		   DbSetOrder(1)
		   If DbSeek(xFilial("AB6")+M->AB6_NUMOS) // Adicionado Michel Aoki
			   RecLock("AB6",.F.)
			   AB6->AB6_STATUS := "E"
			   AB6->(MsUnlock())
		   EndIF
		   DBSelectArea("AB7")
		   DbSetOrder(1)
		   If DbSeek(xFilial("AB7")+M->AB6_NUMOS) // Adicionado Michel Aoki
			   RecLock("AB7",.F.)
			   AB7->AB7_TIPO := "5"
			   AB7->(MsUnlock())
		   EndIf	

         // Em caso se efetivação de ordem de serviço, verifica se os serviços do apontamento são serviços parametrizados para serem transferidos do
         // armazém do técnico para o armazém 01 - Estoque Geral
         Trans_Armazem(AllTrim(cFilAnt), M->AB6_NUMOS)

		   _lEfetiva:= .F.

	   EndIf
   EndIf	
		
	//AB2->(FKCommit()) 
	//AB4->(FKCommit()) 
	//AB5->(FKCommit()) 
	//AB9->(FKCommit())

	RestArea(_aArea)
	RestArea(_aAreaSC5)
	Restarea(_aAreaAB6)
	Restarea(_aAreaAB7)
	Restarea(_aAreaAB8)
	Restarea(_aAreaAA3)

Return()

/*/{Protheus.doc} AT450ALT
P.E. na gravacao da Ordem de Servico. Executado na alteracao da O.S.  
@author Gilmar Silva
@since 28/10/13
/*/
******************************************************************************
User Function AT450ALT()
******************************************************************************

Local cAgCodTec  	:= 	Posicione('ABB',3,xFilial("ABB")+AB6->AB6_NUMOS,"ABB_CODTEC")

	DbSelectArea('AB6')
	RecLock("AB6", .F.)
		AB6->AB6_HORAI 	:=	Time()
		AB6->AB6_HORAF	:=	'00:00'
		//AB6->AB6_RLAUDO	:=	cAgCodTec
	MsUnLock()


Return()

/*/{Protheus.doc} AT450OKA
P.E. na gravacao da Ordem de Servico. Bloqueio de alteracao em O.S. com AB6_STATUS ==E   
@author Gilmar Silva
@since 28/10/13
/*/
******************************************************************************
User Function AT450OKA()
******************************************************************************
Local aAliasAB6 :=	GetArea()
Local _lRet 	:=	.T.

	If AB6->AB6_STATUS == "E"
		_lRet := .F.
		MsgAlert("Atencao, esta ordem de servico encontra-se encerrada. Nao deve ser alterada." )
	EndIf
	
	RestArea(aAliasAB6)
	
Return(_lRet)

/*/{Protheus.doc} TC450ROT
Inclusao de informacao interna nas O.S. ja encerradas com AB6_STATUS==E ou B  
@author Gilmar Silva
@since 08/11/13
/*/
******************************************************************************
User Function TC450ROT()
******************************************************************************
Local aRotAdic:= {}

	aAdd(aRotAdic, { 'Informação Interna'   ,'U_AUTA013' , 0 , 2})
	aAdd(aRotAdic, { 'Devolução Equip.'     ,'U_AUTOM568', 0 , 2})
	aAdd(aRotAdic, { 'Pedidos/Notas Fiscais','U_AUTOM693', 0 , 2})                                                               

Return(aRotAdic)

// ##########################################################################################                                                 
// Função que incluí novas opções nas Ações Relacionadas da Ordem de Serviço - Protheus 12 ##
// ##########################################################################################
User Function OM010AROT()

   aRotina := ParamIxb[1]

   aadd(aRotina,\{"Informação Interna", "U_AUTA013" ,0,4\}) 
   aadd(aRotina,\{"Devolução Equip."  , "U_AUTOM568",0,4\}) 

Return(aRotina)


/*/{Protheus.doc} TC450LEG
Adiciona Legenda (Ordem.Ser Aprovador).
@author Lucas Moresco
@since 01/07/11
/*/
******************************************************************************
User Function TC450LEG()
******************************************************************************
Local aCores := ParamIxb

	aAdd(aCores,{'BR_AMARELO' ,'Atendida' })
	aAdd(aCores,{'BR_MARROM'  ,'O.S. Req. de Pecas - Aguardando' })
	aAdd(aCores,{'BR_LARANJA' ,'O.S. Req. de Pecas - Atendido'   })
	aAdd(aCores,{'BR_BRANCO'  ,'O.S. Aprov. Cliente - Aguardando Pecas' })
	aAdd(aCores,{'BR_AZUL'    ,'Ordem de Servico Aprovada'       })
	aAdd(aCores,{'BR_PINK' ,'Ordem de Servico Reprovada'     })

Return(aCores)                                

/*/{Protheus.doc} AT450OKI
P.E. na confirmacao da O.S. . 
@author Fabiano Pereira
@since 14/05/14
/*/
******************************************************************************
User Function AT450OKI()
******************************************************************************

   Local aAliasAB6 := GetArea()
   Local lRet	   := .T.

   RestArea(aAliasAB6)

Return(lRet)

/*/{Protheus.doc} TC450COR
Adiciona o novo status ao Browse da visualizacao da O.S. Utilizado devido ao status da resposta do workflow. 
@author Lucas Moresco 
@since 01/07/11
/*/
******************************************************************************
User Function TC450COR()
******************************************************************************
Local nX := 0
Local aCores := ParamIxb

	For nX := 1 To Len(aCores)
		If (aCores[nX][2] == 'ENABLE')
			aCores[nX][1] := aCores[nX][1]+' .And. AB6_APROV == "A" '
		ElseIf (aCores[nX][2] == 'DISABLE')
			aCores[nX][1] := aCores[nX][1]+' .And. AB6_APROV == "E" ' /**/ 
		Endif
	Next
	
	Aadd(aCores,{" AB6_STATUS == 'A' .And. EMPTY(AB6_APROV) ", "ENABLE"})
	Aadd(aCores,{" AB6_STATUS == 'E'                        ", "DISABLE"})
	
	Aadd(aCores,{" AB6_STATUS == 'A' .And. AB6_APROV == 'R' ", "BR_MARROM"}) 
	Aadd(aCores,{" AB6_STATUS == 'A' .And. AB6_APROV == 'L' ", "BR_LARANJA"})
	Aadd(aCores,{" AB6_STATUS == 'A' .And. AB6_APROV == 'P' ", "BR_BRANCO"})
	 
	Aadd(aCores,{" AB6_STATUS == 'A' .And. AB6_APROV == 'S' ", "BR_AZUL"})
	Aadd(aCores,{" AB6_STATUS == 'A' .And. AB6_APROV == 'N' ", "BR_PINK"})
	
	Aadd(aCores,{" AB6_STATUS == 'B' ", "BR_AMARELO"})
	
	Aadd(aCores,{" AB6_STATUS == 'D' ", "BR_PRETO"})	

Return(aCores)

// ################################################## 
// Função que valida dados antes da gravação da OS ##
// ##################################################
User Function AT450VLD()

   Local lRet     := .T.
   Local cQry     := ""
   Local aArea    := GetArea()
   Local ix       := 0

   If M->AB6_APROV $ "SP"                                        
   	  MsgAlert("Impossivel incluir ou alterar Apontamentos já aprovados.","O.S. ja Aprovada")
	  lRet:= .F.
   EndIf 
	
   If lRet == .T.
 	  //Controla SubItem
	  For ix := 1 To Len(aCols)
		  If Empty(aCols[ix][GdFieldPos("AB8_SUBITE",aHeader)])
		 	 aCols[ix][GdFieldPos("AB8_SUBITE",aHeader)] := "01"
		  EndIf			
 	  Next
   EndIf
	
   // ###########################################################################################################
   // Nao permitir a alteração do item, solicitar a exclusao, verificar se precisa extornar o movimento antes. ##
   // ###########################################################################################################
   If (Altera)
  	  For ix := 1 To Len(aCols)
	      
          // ###########################
	      // Se for exclusao de linha ##
	      // ###########################
	   	  If ( aCols[ix][GdFieldPos("AB8_REC_WT",aHeader) + 1])
				
		     If Select("STATZZZ") > 0
		   	    STATZZZ->( dbCloseArea() )
		     EndIf
				
             // ######################################################################################################################
		     // Verifica se existe algum registro diferente de "Aberto" para este produto, se sim, nao permite a exclusao da linha. ##
		     // ######################################################################################################################				
		     cQry := "Select ZZZ_STATUS From " + RetSqlName("ZZZ") + " ZZZ(NoLock) " + chr(13)
		     cQry += "Where ZZZ_NUMOS = '"+AB6->AB6_NUMOS+"' And ZZZ_STATUS <> 'A' And "+chr(13) 
		     cQry += "ZZZ_PRODUT = '"+aCols[ix][GdFieldPos("AB8_CODPRO",aHeader)]+"' And "+chr(13)
		     cQry += "ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "+chr(13)
		     cQry += "D_E_L_E_T_ <> '*' "
		     cQry := ChangeQuery(cQry)
				
		     dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "STATZZZ", .T., .T. )
		     STATZZZ->( DbGoTop() )
				
		     If !Eof()
		 	    lRet := .F.
			    MsgAlert("Atencao, Nao e permitido a exclusao de item que ja tenha movimento de requisição, e necessario o estorno do movimento antes.")
			    Exit
		     Else
			    lRet := .T.
		     EndIf
			
		     STATZZZ->( dbCloseArea() )
			
             // #####################
		     // Caso for alteracao ##
		     // #####################
		  Else
				
		     If Select("ALTZZZ") > 0
		        ALTZZZ->( dbCloseArea() )
		     EndIf
			
		     cQry := "Select ZZZ_STATUS From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
		     cQry += "Where ZZZ_NUMOS = '"+AB6->AB6_NUMOS+"' And ZZZ_STATUS <> 'A' And "+chr(13)
		     cQry += "ZZZ_ITAB8 = '"+aCols[ix][GdFieldPos("AB8_SUBITE",aHeader)]+"' And "+chr(13)
		     cQry += "(ZZZ_PRODUT <> '"+aCols[ix][GdFieldPos("AB8_CODPRO",aHeader)]+"' Or "+chr(13)
		     cQry += "ZZZ_LOCAL <> '"+aCols[ix][GdFieldPos("AB8_LOCAL",aHeader)]+"'Or "+chr(13)
		     cQry += "ZZZ_QUANT <> '"+cValToChar(aCols[ix][GdFieldPos("AB8_QUANT",aHeader)])+"' ) And "+chr(13)
		     cQry += "ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "+chr(13)
		     cQry += "D_E_L_E_T_ <> '*' "
		     cQry := ChangeQuery(cQry)
				
		     dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "ALTZZZ", .T., .T. )
		     ALTZZZ->( DbGoTop() )
				
		     If !Eof()
			    lRet := .F.
			    MsgAlert("Atenção, Nao e permitido a alteracao de item que ja tenha movimento de requisicao, remova este item e adicione um novo.")
			    Exit
		     Else
		        lRet := .T.
		     EndIf
			
		     ALTZZZ->( dbCloseArea() )
							
		  Endif
				
	  Next

   EndIf

   RestArea(aArea)
	
Return(lRet)

******************************************************************************
Static Function CheckSeqAB9()	//	VERIFICA SEQUENCIA DO ATENDIMENTO OS
******************************************************************************
Local cRetorno := ''
IIF(Select("TMP")!=0, TMP->(DbCloseArea()), )

cSql := " SELECT MAX(AB9_SEQ) AS  SEQ"
cSql += " FROM " + RetSqlName("AB9")
cSql += " WHERE LEFT(AB9_NUMOS, 06) = '" + AllTrim(AB6->AB6_NUMOS)+ "'"
cSql += " AND D_E_L_E_T_ = '' "

cSql := ChangeQuery( cSql )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "TMP", .T., .T. )

DbSelectArea('TMP');DbGoTop()
cRetorno := Soma1(TMP->SEQ)
                                     
IIF(Select("TMP")!=0, TMP->(DbCloseArea()), )
Return(cRetorno)
******************************************************************************
Static Function TotalHrAB9(nTotHrAB6) // VERIFICA TOTAL DE HORAS DOS ATENDIMENTOS
******************************************************************************
Local nHorasAB9 := 0

IIF( Select('QUERY_AB9')  !=0, QUERY_AB9->(DbCLoseArea()  ), )
cQuery := "	SELECT AB9_FILIAL, AB9_NUMOS, AB9_SEQ, AB9_HRINI, AB9_HRFIM, AB9_TRASLA, AB9_TOTFAT "
cQuery += " FROM " +RetSqlName('AB9') +" AB9 (NOLOCK)  		 	"+ENTER 
cQuery += "	WHERE	AB9.AB9_FILIAL 	 =	'"+xFilial('AB9')+"' 	"+ENTER
cQuery += "	AND		Left(AB9.AB9_NUMOS, 06)	 =	'"+AB6->AB6_NUMOS+"'	"+ENTER	
cQuery += "	AND		AB9.D_E_L_E_T_	!=	'*'						"+ENTER
cQuery += "	ORDER BY AB9_NUMOS, AB9_SEQ							"+ENTER
		 
MemoWrit(__RelDir+'AtuHorasOS.TXT', cQuery)   
DbUseArea(.t.,'TOPCONN',TcGenQry(,,cQuery),'QUERY_AB9',.f.,.f.)
 

DbSelectArea('QUERY_AB9');DbGoTop()
Do While !Eof()   
	
	nHorasAB9 := SomaHoras(nHorasAB9, QUERY_AB9->AB9_TOTFAT)
	                        
	DbSelectArea('QUERY_AB9')
	DbSkip()			
EndDo

nHrTotal  := SomaHoras(nHorasAB9, nTotHrAB6)


//    HORAS:MINUTOS - NUMERICO
nHoras		:=	Int(nHrTotal)
cMinutos	:=	AllTrim(Str((nHrTotal - nHoras)))
cHoras		:=	AllTrim(Str(nHoras))

//   MINUTOS

nPonto		:=	AT('.', cMinutos ) - IIF(Len(cMinutos)==3, 1, 0 )
cMinutos	:=	Right(cMinutos, nPonto)

cHrTotal :=  PadL(cHoras,2,"0")+':'+ PadR(cMinutos, 2, "0" )
                                                              

IIF( Select('QUERY_AB9')  !=0, QUERY_AB9->(DbCLoseArea()  ), )
Return(cHrTotal)
*****************************************************************************
Static Function CheckAB8()	//	VERIFICA SE HOUVE APONTAMENTO
*****************************************************************************
Local lRetorno := .F.
Local aProd	   := {}
Local aMO 	   := {}

DbSelectArea('AB8');DbSetOrder(1);DbGoTop()	//	AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE
If DbSeek(xFilial('AB8')+ AB6->AB6_NUMOS, .F.)
	Do While AB8->AB8_NUMOS == AB6->AB6_NUMOS

		lMaoObra := AllTrim(Posicione('SB1',1,xFilial('SB1')+AB8->AB8_CODPRO,'B1_TIPO')) == 'MO'
		lProduto :=	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB8->AB8_CODPRO,'B1_TIPO')) != 'MO'
		
		If lMaoObra
			Aadd(aMO, .T.)
		ElseIf lProduto
			Aadd(aProd, .T.)		
		EndIf

		DbSelectArea('AB8')
		DbSkip()

		If Len(aProd) > 0 .And. Len(aMO) > 0
			Exit
		EndIf

	EndDo
	
	lRetorno := IIF(Len(aProd)>0.Or.Len(aMO)>0, .T., .F.)
	
EndIf             

Return(lRetorno)    

// #########################################################
// Envia e-mail para o cliente informado a abertura da OS ##
// #########################################################
Static Function OpenOSCli()

   Local aAliasAB6   := GetArea()
   Local cNumOSAB6   :=	M->AB6_NUMOS   &&AB6->AB6_NUMOS
   Local aProduto    := 	{}
   Local nX          := 0
   Local nValReprova := 0
   Local nContar     := 0
   Local xPreco      := 0
	                                                                                               
   DbSelectArea("AB6")
   _Email := AllTrim(Posicione('SU5',1,xFilial('SU5')+M->AB6_CONTWF,'U5_EMAIL')) 

   //DbSelectArea('AB7');DbSetOrder(1);DbGoTop()
   //If DbSeek(xFilial('AB7')+cNumOSAB6, .F.)
   //	Do While !Eof() .And. AB7->AB7_NUMOS == cNumOSAB6
   //		
   //		cDescProd := 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DESC'))
   //		cDAux 	:= 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DAUX'))
   //		cDescProd := 	cDescProd + IIF(!Empty(cDAux), +cDAux, '')
   //		
   //		Aadd(aProduto, { AllTrim(AB7->AB7_CODPRO), cDescProd, AB7->AB7_NUMSER } )
   //		
   //		DbSelectArea('AB7')
   //		DbSkip()
   //	EndDo
   //EndIf

   // #########################################################
   // Capta o pocionamento dos campos denbtro do array aCols ##
   // #########################################################
   kCodProduto := aScan(aHeader,{|x| AllTrim(x[2])=="AB7_CODPRO"})    
   kNumSerie   := aScan(aHeader,{|x| AllTrim(x[2])=="AB7_NUMSER"})    
   kNomeCli    := AllTrim(Posicione("SA1",1,xFilial("SA1") + M->AB6_CODCLI + M->AB6_LOJA,"A1_NOME"))

   For nContar = 1 to Len(aCols)

       cDescProd :=	AllTrim(Posicione('SB1',1,xFilial('SB1') + aCols[nContar,kCodProduto],'B1_DESC'))
	   cDAux 	 :=	AllTrim(Posicione('SB1',1,xFilial('SB1') + aCols[nContar,kCodProduto],'B1_DAUX'))
	   cDescProd :=	cDescProd + IIF(!Empty(cDAux), + cDAux, '')
		
	   Aadd(aProduto, { aCols[nContar,kCodProduto], cDescProd, aCols[nContar,kNumSerie] } )

   Next nContar
                         
   // ######################
   // Cabeçalho do e-mail ##
   // ######################
   cHtml := '<html>'
   cHtml += '<head>'
   cHtml += '<h3 align = Left><font size="3" color="#0000FF" face="Verdana"> ABERTURA ORDEM DE SERVICO</h3></font>'
   cHtml += '<br></br>'
   cHtml += '<br></br>'                          
   cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">Prezado(a) </h3></font>'
   cHtml += '<br></br>' 
   cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">' + kNomeCli + '</h3></font>'
   cHtml += '<br></br>'
   cHtml += '<br></br>'
   cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">Informamos que foi aberta a Ordem de Servico na '+cNumOSAB6+' </h3></font>'
   cHtml += '<h3 align = Left><font size="3" color="#000000" face="Verdana">para o(s) equipamento(s):</h3></font>'
   cHtml += '</head>'
   cHtml += '<br></br>'
   cHtml += '<br></br>'

   // ####################
   // Cabeçalho do grid ##
   // ####################
   cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#CCCCCC" BGCOLOR=#EEE9E9 CELLPADDING=2 CELLSPACING=0 STYLE="page-break-before: always">'
   cHtml += '	<TR ALIGN=TOP>'
   cHtml += '		<TD ALIGN=LEFT WIDTH=60 >'
   cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>PRODUTO</P></font>'
   cHtml += '		</TD>'
   cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>DESCRIÇÃO</P></font>'
   cHtml += '		</TD>'
   cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>NUM.SERIE</P></font>'
   cHtml += '		</TD>'
   cHtml += '	</TR>'

   // Aadd(aProduto, { AllTrim(AB7->AB7_CODPRB) , AllTrim(AB7->AB7_DESCPR)+IIF(!Empty(cDAux), +cDAux, ''), AB7->AB7_NUMSER } )
   For nX := 1 To Len(aProduto)
	
	   cHtml += '<TR ALIGN=TOP>'
	   cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
	   cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][01]+'</P></font>'
	   cHtml += '		</TD>'
	   cHtml += '		<TD ALIGN=LEFT bgcolor=#FFFFFF>'
	   cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][02]+'</P></font>'
	   cHtml += '		</TD>'
	   cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
	   cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][03]+'</P></font>'
	   cHtml += '		</TD>'
	   cHtml += '</TR>'	
   Next

   cHtml 	+= '</TABLE>'
   cHtml	+= '<br></br>'
   cHtml	+= '<br></br>' 

   // ######################################################################################################
   // Tarefa #3685 - Retirar observação de cobraça da tarefa de reprovação para Empresa 02 - TI Automação ##
   // ######################################################################################################
   If cEmpAnt == "02"
   Else

      nValReprova := 0

      DbSelectArea('AB7')
      DbSetOrder(1)
      If DbSeek(xFilial('AB7') + AB6->AB6_NUMOS, .F.)
	     kCodPrb := AB7->AB7_CODPRB
      Else
	     kCodPrb := ""
      EndIf

      If kCodPrb$("000028#000038#000002")
      Else

         // ############################################################################################
         // Pesquisa no parametrizador o valor a ser cobrado em caso de reprovação do orçamento da OS ##
         // ############################################################################################
         If Select("T_REPROVA") > 0
            T_REPROVA->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZ4_TREP FROM " + RetSqlName("ZZ4")
   
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REPROVA", .T., .T. )

         nValReprova := 0

         For xPreco := 1 to U_P_OCCURS(T_REPROVA->ZZ4_TREP, "#", 1)
      
             xSepara := U_P_CORTA(T_REPROVA->ZZ4_TREP, "#", xPreco)
          
             If Substr(U_P_CORTA(xSepara,"|",1),01,02) == cEmpAnt
                If Substr(U_P_CORTA(xSepara,"|",2),01,02) == cFilAnt
                   nValReprova := VAL(U_P_CORTA(xSepara,"|",3))
                   Exit
                Endif
             Endif      
                    
         Next xPreco
                  
         If nValReprova == 0
         Else
            cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">Obs.: Caso o Orçamento enviado venha a nao ser aprovado, informamos que podera </h3></font>'
            cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">ocorrer uma cobranca de uma taxa de reprovacao no valor de R$ ' + Transform(nValReprova, "@E 9999999.99") + ' decorrente do </h3></font>'
            cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">tempo de analise do tecnico.</h3></font>'
         Endif
            
      Endif   

   Endif

   cHtml	+= '<br></br>'
   cHtml	+= '<br></br>'
   cHtml 	+= '<P STYLE="margin-bottom: 0cm"><BR></P>'
   cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> Att. </font></b>'
   cHtml	+= '<br></br>'
   cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> Automatech Sistemas de Automação Ltda </font></b>'
   cHtml	+= '<br></br>'
   cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> Fone: (51) - 3017-8300 </font></b>'
   cHtml	+= '<br></br>'
   cHtml 	+= '<b><font size="2" color=#FFFFFF face="Verdana"> www.automatech.com.br </font></b>'
   cHtml	+= '<br></br>'
   cHtml	+= '<br></br>'
   cHtml 	+= '<b><font size="1" color=#696969 face="Verdana"> E-mail enviado automaticamente, nao responda este e-mail </font></b>'
   cHtml	+= '<br></br>'
   cHtml	+= '<br></br>'
   cHtml 	+= '</head>'
   cHtml 	+= '</html>'
   
   // ###############################
   // Envia o relatorio via e-mail ##
   // ###############################
   MemoWrit(GetTempPath() + 'EMAIL_PE_TECA460.html', cHtml)
   cErroEnvio := U_AUTOMR20(cHtml, Alltrim(_Email), "", "Aviso de Abertura da Ordem de Servico - Automatech.")

   If Empty(cErroEnvio)
	  
	  // ###############################
	  // GRAVA DATA DE ENVIO DO EMAIL ##
	  // ###############################
	  /*
	  DbSelectArea('AB9')
	  RecLock("AB9",.F.)
	  AB9->AB9_ENVIOA := Date()
	  MsUnlock()
	  */

   EndIf

   RestArea(aAliasAB6)

Return()

*****************************************************************************
Static Function CliSemEmail(cCodigo, cLoja, _cNomeCli)
*****************************************************************************
cCnpj := AllTrim(Posicione("SA1",1,xFilial("SA1")+cCodigo+cLoja,"A1_CGC"))

//   CABEC DO E-MAIL
cHtml	:= '<html>'
cHtml	+= '<head>'

cHtml	+= '<h3 align = Left><font size="3" color="#0000FF" face="Verdana"> CLIENTE SEM CADASTRO DE E-MAIL</h3></font>'
cHtml	+= '<br></br>'
cHtml	+= '<br></br>'
cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">CODIGO: '+cCodigo+' - '+cLoja+'</h3></font>'
cHtml	+= '<br></br>'                                                                                                 
cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">CNPJ\CPF: '+cCnpj+'</h3></font>'
cHtml	+= '<br></br>'                    
cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">NOME: '+_cNomeCli+'</h3></font>'
cHtml	+= '<br></br>'
cHtml	+= '<br></br>'
cHtml	+= '<br></br>'
cHtml 	+= '</head>'
cHtml 	+= '</html>'

// Chama o programa que envia o e-mail
//U_AUTA007(cHtml,"")
U_AUTOMR20(cHtml, "", "", "")

Return()    

*****************************************************************************
Static Function GeraRequPeca()
*****************************************************************************

Local aAreaZZZ  := GetArea("ZZZ")
Local aAreaSB1  := GetArea("SB1")
Local cItem     := "00"
Local ix        := 0	
Local iy        := 0
Local iz        := 0
Local lContrEnd := .F.
Local cQry      := ""
Local lOk       := .T.
Local lAltApont := .F.
Local lDeletou  := .F.
	
		
		cItem := UltimoItem(AB6->AB6_NUMOS)
		
		//Valida se tecnico ja esta alocado.
		If (!Empty(AB6->AB6_RLAUDO))
		
			For ix := 1 To Len(aColsAb8[1])
				
            If Alltrim(aColsAb8[1][ix][GdFieldPos("AB8_CODPRO",aHeaderAb8)]) == '004581' .OR. ;
               Alltrim(aColsAb8[1][ix][GdFieldPos("AB8_CODPRO",aHeaderAb8)]) == '004571'
               Loop
            Endif   

				lContrEnd := .F.
				
				//Se nao eh registro deletado.
				If (! aColsAb8[1][ix][GdFieldPos("AB8_REC_WT",aHeaderAb8) + 1])
					
					lContrEnd:= CheckProdEnd(aColsAb8[1][ix][GdFieldPos("AB8_CODPRO",aHeaderAb8)])
					
					DbSelectArea("ZZZ")
					DbSetOrder(2)
					
					If (! DbSeek(xFilial("ZZZ")+AB6->AB6_NUMOS+aColsAb8[1][ix][GdFieldPos("AB8_SUBITE",aHeaderAb8)]) .And.;
								 U_CheckGrpProd(aColsAb8[1][ix][GdFieldPos("AB8_CODPRO",aHeaderAb8)]))	
						
						nLoop := Iif(lContrEnd,aColsAb8[1][ix][GdFieldPos("AB8_QUANT" ,aHeaderAb8)],1)
						
						For iy:= 1 to nLoop
							
							RecLock("ZZZ",.T.)
								ZZZ->ZZZ_FILIAL := xFilial("ZZZ")
								ZZZ->ZZZ_NUMOS  := AB6->AB6_NUMOS
								ZZZ->ZZZ_TECNIC := AB6->AB6_RLAUDO
								ZZZ->ZZZ_EMISSA := Date()
								ZZZ->ZZZ_ITEM   := cItem
								ZZZ->ZZZ_ITAB8  := aColsAb8[1][ix][GdFieldPos("AB8_SUBITE",aHeaderAb8)]
							    ZZZ->ZZZ_LOCAL  := aColsAb8[1][ix][GdFieldPos("AB8_LOCAL"  ,aHeaderAb8)]
								ZZZ->ZZZ_PRODUT := aColsAb8[1][ix][GdFieldPos("AB8_CODPRO",aHeaderAb8)]
								ZZZ->ZZZ_QUANT  := Iif(lContrEnd,1,aColsAb8[1][ix][GdFieldPos("AB8_QUANT" ,aHeaderAb8)])
								ZZZ->ZZZ_QTDORI := aColsAb8[1][ix][GdFieldPos("AB8_QUANT" ,aHeaderAb8)]
								ZZZ->ZZZ_SALDO  := Iif(lContrEnd,1,aColsAb8[1][ix][GdFieldPos("AB8_QUANT" ,aHeaderAb8)])
				 				ZZZ->ZZZ_STATUS := "A"
							MsUnlock()
						
							cItem:= Soma1(cItem)
							lAltApont := .T.	    	
						Next
									 
					EndIf	
				EndIf
			Next
				    
				For iz:= 1 To Len(aColsAb8[1])
					If (aColsAb8[1][iz][GdFieldPos("AB8_REC_WT",aHeaderAb8) + 1])
						lDeletou := .T.
						Exit
					EndIf
				Next
				   
				                         
				If (lAltApont .Or. lDeletou) 
					
					If Select("ZZZTMP2") > 0
						ZZZTMP2->(dbCloseArea())
					EndIf
	
					cQry := "Select ZZZ_NUMOS From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
					cQry += "Where "+chr(13) 
					cQry += "ZZZ_NUMOS = '"+AB6->AB6_NUMOS+"' And ZZZ_STATUS <> 'E' And "+chr(13)
					cQry += "ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "+chr(13)
					cQry += "D_E_L_E_T_ <> '*' "
					cQry := ChangeQuery(cQry)
					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "ZZZTMP2", .T., .T. )
	           
					ZZZTMP2->( DbGoTop() )
					RecLock("AB6",.F.)                
						If (ZZZTMP2->(Eof()))
							If (AB6->AB6_APROV == "R") 
								AB6->AB6_APROV := "L"
							Else
								AB6->AB6_APROV := "A"
							EndIf
						Else
							AB6->AB6_APROV := "R"
						EndIf
                    MsUnlock()
                    
					ZZZTMP2->(dbCloseArea())
				EndIf				 
				
					
		Else
			MsgAlert("Nao foi possivel gerar a Requisicao de Pecas, O.S. Sem Tenico Alocado")
		EndIf

	RestArea(aAreaZZZ)
	RestArea(aAreaSB1)
	
Return()                 
/*
User Function AT450BUT()

Public nItensApont := 0

Return()
  */
******************************************************************************
Static Function ExcluiZZZ(cCodItem)
******************************************************************************
Local aAreaZZZ  := GetArea("ZZZ")
Local aAreaSB1  := GetArea("SB1")
Local ix        := 0	
Local cQry      := ""
Local nLaco     := 0	

	cQry := "Update "+RetSqlName("ZZZ")+" Set D_E_L_E_T_ = '*' "+chr(13)
	cQry += "Where ZZZ_NUMOS = '"+AB6->AB6_NUMOS+"' And ZZZ_STATUS <> 'E' And "+chr(13) 
	cQry += "ZZZ_ITAB8 = '"+cCodItem+"' And "+chr(13)
	cQry += "ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "+chr(13)
	cQry += "D_E_L_E_T_ <> '*' "

	If TcSqlExec(cQry) < 0
		UserException("Erro na exclusao dos itens da tabela ZZZ (Req. de Pecas)")
	EndIf

	RestArea(aAreaZZZ)
	RestArea(aAreaSB1)

Return()

******************************************************************************
User Function CheckGrpProd(cProduto)
******************************************************************************
Local lRet := .F.

	DbSelectArea("SB1")
	DbSetOrder(1)
	
	If (DbSeek(xFilial("SB1")+cProduto))
		If (SB1->B1_TIPO $ "AI;BN;EM;GG;MC;MO;OI;PP;PV;SL;SP;SV")
			lRet := .F.
		Else
			lRet := .T.
		EndIf	
	EndIf

Return(lRet)

******************************************************************************
Static Function UltimoItem(cNumOs)
******************************************************************************
Local cQry  := ""
Local cItem := "01"

	Iif(Select("ZZZITEM")!=0, ZZZITEM->(DbCloseArea()),)
	
	cQry := "Select Max(ZZZ_ITEM) ULTIT From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
	cQry += "Where ZZZ_NUMOS = '"+cNumOs+"' And "+chr(13)
	cQry += "ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "+chr(13)
	cQry += "D_E_L_E_T_ <> '*' "+chr(13)
	cQry := ChangeQuery(cQry)
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "ZZZITEM", .T., .T. )
	
		DbSelectArea("ZZZITEM"); DbGoTop()
		
		While ! Eof()
			cItem := Soma1(ZZZITEM->ULTIT)
			DbSkip()
		EndDo

Return(cItem)

******************************************************************************
Static Function CheckProdEnd(cProduto)
******************************************************************************
Local lRet := .F.

	DbSelectArea("SB1")
	DbSetOrder(1)
	
	If (DbSeek(xFilial("SB1")+cProduto))
		If (SB1->B1_LOCALIZ == "S")
			lRet := .T.
		EndIf	
	EndIf	
					
Return(lRet)			

//
// Função Trans_Armazem()
// Esta função tem por objetivo de realizar as transgerências entre o armazém do técnico para o armazém 01 para os serviços
// que estão parametrizados como Serviços em garantia.
Static Function Trans_Armazem(__Filial, __Ordem)

   Local cSql          := ""
   Local _ChavePesqPro := ""
   Local cProduto      := ""
   Local cProd         := ""
   Local cDescri       := ""
   Local cUM           := ""
   Local cLocal        := ""
   Local cLocaliz      := "N"
   Local nQuant        := ""
   Local aItem         := {}
   Local aAuto         := {}
   Local aErroProd     := {}
   Local emails        := ""
   Local nContar       := 0
   Local cString       := ""

   // Pesquisa a lista de serviços de garantia a serem utilizados para transferência entra armazéns
   If Select("T_LISTAGAR") > 0
      T_LISTAGAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_TGAR, ZZ4_EGAR FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LISTAGAR", .T., .T. )

   cEmails := T_LISTAGAR->ZZ4_EGAR
   
   // Pesquisa os apontamentos da ordem de serviço para verificar se os serviços estão parametrizados como serviços de garantia
   If Empty(Alltrim(T_LISTAGAR->ZZ4_TGAR))
   Else
      If Select("T_GARANTIAS") > 0
	     T_GARANTIAS->( dbCloseArea() )
	  EndIf

      cSql := ""
      cSql := "SELECT AB8.AB8_FILIAL,"
      cSql += "       AB8.AB8_NUMOS ,"
   	  cSql += "       AB8.AB8_CODSER,"
      cSql += "       AB8.AB8_CODPRO,"
      cSql += "	      AB8.AB8_QUANT ,"
      cSql += "	      AB8.AB8_NUMSER,"
  	  cSql += "       AB6.AB6_RLAUDO,"
      cSql += "       AA1.AA1_NOMTEC,"
  	  cSql += "       AA1.AA1_LOCAL  "
      cSql += "  FROM " + RetSqlName("AB8") + " AB8, "
      cSql += "       " + RetSqlName("AB6") + " AB6, "
      cSql += "       " + RetSqlName("AA1") + " AA1  "
      cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(__Filial) + "'"
      cSql += "   AND AB8.AB8_NUMOS  = '" + Alltrim(__Ordem)  + "'"
      cSql += "   AND AB8.D_E_L_E_T_ = ''            "
      cSql += "   AND AB6.AB6_FILIAL = AB8.AB8_FILIAL"
      cSql += "   AND AB6.AB6_NUMOS  = AB8.AB8_NUMOS "
      cSql += "   AND AB6.D_E_L_E_T_ = ''            "
      cSql += "   AND AA1.AA1_CODTEC = AB6.AB6_RLAUDO"

  	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GARANTIAS", .T., .T. )

      T_GARANTIAS->( DbGoTop() )
         
      WHILE !T_GARANTIAS->( EOF() )
            
         If U_P_OCCURS(T_LISTAGAR->ZZ4_TGAR, Alltrim(T_GARANTIAS->AB8_CODSER), 1) <> 0

                 
            // Prepara o código do produto para leitura       
            _ChavePesqPro := "  " + Strzero(Int(val(Alltrim(T_GARANTIAS->AB8_CODPRO))),6)
            cProduto      := Strzero(Int(val(Alltrim(Alltrim(T_GARANTIAS->AB8_CODPRO)))),6)
            _xDOCx      := GetSxENum("SD3","D3_DOC",1)
            cLote       := "   "
            dDataVl     := CTOD("  /  /    ")
            nQuant      := T_GARANTIAS->AB8_QUANT
            cSerie      := T_GARANTIAS->AB8_NUMSER
            nOpcAuto    := 3            

            // Captura dados do produto
            DbSelectArea("SB1")
            DbSetOrder(1)

            If SB1->(MsSeek(_ChavePesqPro))
               cProd      := B1_COD
               cDescri    := B1_DESC
               cUM        := B1_UM
               cLocal     := B1_LOCPAD
               cControleS := B1_LOCALIZ
            Else

               aAdd( aErroProd, {Alltrim(T_GARANTIAS->AB8_NUMOS) ,;
                                 Alltrim(T_GARANTIAS->AB8_CODSER),;
                                 Alltrim(T_GARANTIAS->AB8_CODPRO),;
                                 Alltrim(T_GARANTIAS->AB8_DESPRO),;
                                 Alltrim(T_GARANTIAS->AA1_LOCAL) ,;
                                 ""                              ,;
                                 Alltrim(T_GARANTIAS->AB6_RLAUDO),;
                                 Alltrim(T_GARANTIAS->AA1_NOMTEC),;
                                 nQuant                          })

               T_GARANTIAS->( DbSkip() )
               Loop
            Endif

            // Se produto tem controle por nº de série, localiza o nº de série para cada armazém
            If cControleS == "N"
            
               cSerie      := ""

               // Armazém de Destino
               cArmDestino := "01"
               cEndDestino := "               "

               // Armazém de Origem
               cArmOrigem  := Alltrim(T_GARANTIAS->AA1_LOCAL)
               cEndOrigem  := "               "

            Else
            
               If Select("T_NUMSERIES") > 0
     	          T_NUMSERIES->( dbCloseArea() )
	           EndIf
            
               cSql := ""
               cSql := "SELECT ZZZ.ZZZ_FILIAL,"
               cSql += "       ZZZ.ZZZ_NUMOS ,"
	           cSql += "       ZZZ.ZZZ_TECNIC,"
	           cSql += "       ZZZ.ZZZ_PRODUT,"
	           cSql += "       ZZZ.ZZZ_LOCAL ,"
	           cSql += "       ZZZ.ZZZ_LOCALI,"
	           cSql += "       ZZZ.ZZZ_NUMSER,"
	           cSql += "       ZZZ.ZZZ_DOCSD3,"
	           cSql += "       SDB.DB_LOCAL  ,"   
	           cSql += "       SDB.DB_LOCALIZ "
               cSql += "  FROM " + RetSqlName("ZZZ") + " ZZZ, "
               cSql += "       " + RetSqlName("SDB") + " SDB  "
               cSql += " WHERE ZZZ.ZZZ_FILIAL = '" + Alltrim(__Filial) + "'"
               cSql += "   AND ZZZ.ZZZ_NUMOS  = '" + Alltrim(__Ordem)  + "'"
               cSql += "   AND ZZZ.D_E_L_E_T_ = ''
               cSql += "   AND SDB.DB_FILIAL  = ZZZ.ZZZ_FILIAL
               cSql += "   AND SDB.DB_DOC     = ZZZ.ZZZ_DOCSD3
               cSql += "   AND SDB.D_E_L_E_T_ = ''
               cSql += " ORDER BY SDB.DB_LOCAL"
            
   	           cSql := ChangeQuery( cSql )
   	           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMSERIES", .T., .T. )

               T_NUMSERIES->( DbGoTop() )
               
               cSerie      := T_NUMSERIES->ZZZ_NUMSER

               cArmDestino := T_NUMSERIES->DB_LOCAL
               cEndDestino := T_NUMSERIES->DB_LOCALIZ

               T_NUMSERIES->( DbSkip() )
               
               cArmOrigem  := T_NUMSERIES->DB_LOCAL
               cEndOrigem  := T_NUMSERIES->DB_LOCALIZ
               
            Endif

            // Realiza a transferência do armazém 01 para o armazém 98
            Begin Transaction

               // Cabecalho a Incluir
               aAuto := {}
               aItem := {}
               
               aadd(aAuto,{_xDOCx,dDataBase}) //Cabecalho

               // Dados do itema ser transferido
               aadd(aItem,cProd)                           // 01 - D3_COD  
               aadd(aItem,cDescri)                         // 02 - D3_DESCRI
               aadd(aItem,cUM)                             // 03 - D3_UM
               aadd(aItem,cArmOrigem)                      // 04 - D3_LOCAL
               aadd(aItem,cEndOrigem)                      // 05 - D3_LOCALIZ            
               aadd(aItem,cProd)                           // 06 - D3_COD
               aadd(aItem,cDescri)                         // 07 - D3_DESCRI
               aadd(aItem,cUM)                             // 08 - D3_UM
               aadd(aItem,cArmDestino)                     // 09 - D3_LOCAL
               aadd(aItem,cEndDestino)                     // 10 - D3_LOCALIZ
               aadd(aItem,cSerie)                          // 11 - D3_NUMSERI
               aadd(aItem,cLote)                           // 12 - D3_LOTECTL
               aadd(aItem,"")                              // 13 - D3_NUMLOTE
               aadd(aItem,dDataVl)                         // 14 - D3_DTVALID
               aadd(aItem,0)                               // 15 - D3_POTENCI
               aadd(aItem,nQuant)                          // 16 - D3_QUANT
               aadd(aItem,0)                               // 17 - D3_QTSEGUM
               aadd(aItem,"")                              // 18 - D3_ESTORNO
               aadd(aItem,"")                              // 19 - D3_NUMSEQ
               aadd(aItem,cLote)                           // 20 - D3_LOTECTL
               aadd(aItem,dDataVl)                         // 21 - D3_DTVALID
               aadd(aItem,"")                              // 22 - D3_ITEMGRD
               aadd(aAuto,aItem)
  
               MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

               If !lMsErroAuto
               Else
                  aAdd( aErroProd, {Alltrim(T_GARANTIAS->AB8_NUMOS) ,;
                                    Alltrim(T_GARANTIAS->AB8_CODSER),;
                                    cProd                           ,;
                                    cDescri                         ,;            
                                    Alltrim(T_GARANTIAS->AA1_LOCAL) ,;
                                    cSerie                          ,;
                                    Alltrim(T_GARANTIAS->AB6_RLAUDO),;
                                    Alltrim(T_GARANTIAS->AA1_NOMTEC),;
                                    nQuant                          })
               EndIf

            End Transaction
         
         Endif

         T_GARANTIAS->( DbSkip() )         
         
      Enddo   
         
      // Verifica se há a necessidade de enviar e-mail ao ricardo sobre os possíveis erros de transferências em armazéns
      If Len(aErroProd) == 0
      Else
            
         If Empty(Alltrim(cEmails))
         Else
         
            cString := ""
            cString := "Sistema Protheus informa abaixo o(s) produto(s) que apontaram problemas no processo de transferência entre armazéns no momento da efetivação da ordem de serviço."
            cString += chr(13) + chr(10) + chr(13) + chr(10)

            For nContar = 1 to Len(aErroProd)   

                cString += "Ordem de Serviço Nº " + aErroProd[nContar,01] + chr(13) + chr(10) 
                cString += "Código Serviço: "     + aErroProd[nContar,02] + chr(13) + chr(10) 
                cString += "Código Técnico: "     + aErroProd[nContar,07] + chr(13) + chr(10)       
                cString += "Nome do Técnico: "    + aErroProd[nContar,08] + chr(13) + chr(10)       
                cString += "Armazém do Técnico: " + aErroProd[nContar,05] + chr(13) + chr(10)       
                cString += "Código Produto: "     + aErroProd[nContar,03] + chr(13) + chr(10) 
                cString += "Descrição Produto: "  + aErroProd[nContar,04] + chr(13) + chr(10)       
                cString += "Nº de Série: "        + aErroProd[nContar,06] + chr(13) + chr(10)       
                cString += "Quantidade: "         + Alltrim(str(aErroProd[nContar,09])) + chr(13) + chr(10) + chr(13) + chr(10)       
                
            Next nContar    
      
            cErroEnvio := U_AUTOMR20(cString, Alltrim(cEmails), "", "Erro Processo Garantia.")      
            
         Endif
      
      Endif
            
   Endif
   
Return(.T.)

// ##################################################################################################################### 
// Função que  solicita a informação do código do cliente quando o pedido de venda foi gerado sem o código do cliente ##
// #####################################################################################################################
Static Function FaltaCliente(hOrdem)

   Local lChumba   := .F.
   Local cSql      := ""
   Local cMemo1	   := ""
   Local cMensagem := ""
   Local hFilial   := ""
   Local hPedido   := ""
   Local nContar   := 0

   Local oMemo1
   Local oMemo2

   Private hCliOS  := M->AB6_CODCLI
   Private hLojOS  := M->AB6_LOJA
   Private hNomOs  := AllTrim(Posicione('SA1',1, xFilial('SA1') + M->AB6_CODCLI + M->AB6_LOJA, 'A1_NOME'))
   Private hCliPV  := M->AB6_CODCLI
   Private hLojPV  := M->AB6_LOJA
   Private hNomPV  := AllTrim(Posicione('SA1',1, xFilial('SA1') + M->AB6_CODCLI + M->AB6_LOJA, 'A1_NOME'))

   Private oFont10 := TFont():New( "Courier New",,16,,.f.,,,,.f.,.f. )

   Private aSelecao    := aNovoCliente
   Private aClientesPV := {}

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private cComboBx10

   Private oDlgFCliente

   cMensagem := ""
   cMensagem += "Atenção!"                                                                + chr(13) + chr(10) + chr(13) + chr(10)
   cMensagem += "Houve problema na geração do pedido de venda para esta OS na informação" + chr(13) + chr(10)
   cMensagem += "do código do cliente, ou seja,pedido de venda não poderá ser gerado sem" + chr(13) + chr(10)
   cMensagem += "código de cliente.                                                     " + chr(13) + chr(10) + chr(13) + chr(10)
   cMensagem += "Confirme ou selecione abaixo o código do cliente a ser considerado para" + chr(13) + chr(10)
   cMensagem += "o Pedido de venda para esta Ordem de Serviço.                          "

   // ###########################
   // Carrega o combo aSelecao ##
   // ###########################
   aSelecao := {}
   aAdd( aSelecao, "000000.000 - Selecione o Cliente" )  

   For nContar = 1 to Len(aNovoCliente)
       aAdd( aSelecao, aNovoCliente[nContar] )       
   Next nContar    

   // #####################################################################################################
   // Selecione os produtos do pedido de venda gerado para verificar se o código do cliente está correto ##
   // #####################################################################################################
   If Select("T_PV_SEM_CLIENTE") > 0
      T_PV_SEM_CLIENTE->( dbCloseArea() )
   EndIf
	
   cSql := ""
   cSql := "SELECT C6_FILIAL ,"
   cSql += "       C6_NUM    ,"
   cSql += "       C6_NUMOS  ,"
   cSql += "       C6_ITEM   ,"
   cSql += "       C6_PRODUTO "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE SUBSTRING(C6_NUMOS,01,06) = '" + Alltrim(hOrdem) + "'"
   cSql += "   AND C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND C6_CLI     = ''"
   cSql += "   AND D_E_L_E_T_ = ''
	 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PV_SEM_CLIENTE", .T., .T. )

   If T_PV_SEM_CLIENTE->( EOF() )
      Return(.T.)
   Endif

   // ############################################################################################################
   // Atualiza o array para poteriormente ser tilizado para atualização do código do cliente no pedido de venda ##
   // ############################################################################################################
   T_PV_SEM_CLIENTE->( DbGoTop() )
   
   WHILE !T_PV_SEM_CLIENTE->( EOF() )

      hFilial   := T_PV_SEM_CLIENTE->C6_FILIAL
      hPedido   := T_PV_SEM_CLIENTE->C6_NUM
   
      aAdd( aClientesPV, {T_PV_SEM_CLIENTE->C6_FILIAL ,;
                          T_PV_SEM_CLIENTE->C6_NUM    ,;       
                          T_PV_SEM_CLIENTE->C6_NUMOS  ,;       
                          T_PV_SEM_CLIENTE->C6_ITEM   ,;             
                          T_PV_SEM_CLIENTE->C6_PRODUTO})

      T_PV_SEM_CLIENTE->( dbSkip() )
      
   ENDDO      

   // ###########################################################################################
   // Abre tela para usuário selecionar/confirmar o cliente para utilização no pedido de venda ##
   // ###########################################################################################
   DEFINE MSDIALOG oDlgCliente TITLE "Efetivação Ordem de Serviço" FROM C(178),C(181) TO C(519),C(613) PIXEL Style DS_MODALFRAME

   oDlgCliente:lEscClose := .F.

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgCliente

   @ C(032),C(002) GET oMemo1 Var cMemo1    MEMO Size C(211),C(001)              PIXEL OF oDlgCliente
   @ C(036),C(005) GET oMemo2 Var cMensagem MEMO Size C(207),C(068) Font oFont10 PIXEL OF oDlgCliente When lChumba

   @ C(108),C(005) Say "Cliente OS"                     Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgCliente
   @ C(108),C(039) Say "Loja"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgCliente
   @ C(130),C(005) Say "Cliente para o Pedido de Venda" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgCliente

   @ C(117),C(005) MsGet oGet1 Var hCliOS Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCliente When lChumba
   @ C(117),C(039) MsGet oGet2 Var hLojOS Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCliente When lChumba
   @ C(117),C(064) MsGet oGet3 Var hNomOS Size C(149),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCliente When lChumba

   @ C(139),C(005) ComboBox cComboBx10 Items aSelecao Size C(208),C(010) PIXEL OF oDlgCliente

   @ C(153),C(089) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgCliente ACTION( AltCliPV(hFilial, hPedido) )

   ACTIVATE MSDIALOG oDlgCliente CENTERED                                                         

Return(.T.)   
   
// ################################################################################
// Função que grava o código do cliente selecionado/informado no Pedido de Venda ##
// ################################################################################
Static Function AltCliPV(hFilial, hPedido)

   Local nContar := 0

   If Len(aClientesPV) == 0
      Msgalert("Pedido de venda não selecionado ou inválido. Verifiqeu!")
      Return(.T.)
   Endif

   If Substr(cComboBx10,01,06) == "000000"
      Msgalert("Cliente a ser utilizado para faturamento não selecionado. Verifique!")
      Return(.T.)
   Endif
          
   // ###############################################################
   // Atualiza o código do cliente no cabeçalho do pedido de venda ##
   // ###############################################################
   DbSelectArea("SC5")
   DbSetOrder(1)
		
   If DbSeek(hFilial + hPedido)
			
	  Reclock("SC5", .F.)
      SC5->C5_CLIENTE := Substr(cComboBx10,01,06)
      SC5->C5_LOJACLI := Substr(cComboBx10,08,03)
      SC5->C5_CLIENT  := Substr(cComboBx10,01,06)
      SC5->C5_LOJAENT := Substr(cComboBx10,08,03)
	  MsunLock()
			
   Endif

   // ########################################################################
   // Atualiza o código do cliente na tabela de produtos do pedido de venda ##
   // ########################################################################
   For nContar = 1 to Len(aClientesPV)
 		    
       DbSelectArea("SC6")
       DbSetOrder(1)
 		
	   If DbSeek(aClientesPV[nContar,01] + aClientesPV[nContar,02] + aClientesPV[nContar,04] + aClientesPV[nContar,05])
		  Reclock("SC6", .F.)
          SC6->C6_CLI  := Substr(cComboBx10,01,06)
          SC6->C6_LOJA := Substr(cComboBx10,08,03)
   		  MsunLock()         
   	   Endif	  
   	   
   Next nContar   	   

   oDlgCliente:End() 
   
Return(.T.)
