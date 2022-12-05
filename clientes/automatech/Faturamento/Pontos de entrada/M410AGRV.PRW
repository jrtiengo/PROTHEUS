#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#include "shell.ch"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada  
#DEFINE  ENTER CHR(13)+CHR(10)

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: M410AGRV.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 05/12/2016                                                               ##
// Objetivo..: Ponto de Entrada disparado logo após a gravação do Pedido de Venda       ##
// ------------------------------------------------------------------------------------ ##
// Observações originais da criação do ponto de entrada.                                ##
//                                                                                      ##
// {Protheus.doc} M410AGRV                                                              ##
// P.E. acionado após a geração de Pedido de Venda, Utilizado para gravação do armazém  ##
// e endereço dos Pedidos gerados pelo Field Service.                                   ##
// @author Lucas Moresco                                                                ##
// @since 30/06/2014                                                                    ##
// @version 1.0                                                                         ##
// #######################################################################################

User Function M410AGRV()
 
   Local aArea     := GetArea()
   Local aAreaSC6  := GetArea("SC6")
   Local nPosOS    := 0
   Local nPosLcliz := 0		
   Local nPosNS    := 0		
   Local nPosLocal := 0	
   Local aReturn   := {}
   Local nPosItem  := aScan( aHeader, { |x| x[2] == 'C6_ITEM   ' } )
   Local nPosProd  := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
   Local nPosMar   := aScan( aHeader, { |x| x[2] == 'C6_QTGMRG ' } )
   Local nPosVlMar := aScan( aHeader, { |x| x[2] == 'C6_MARGEM ' } )

   Private aParametros := {}
   Private kString     := ""

   U_AUTOM628("M410AGRV")

   // ##############################################################################################
   // Verifica se existe a pasta SIMFRETE no equipamento do usuário. Caso não exista, será criada ##
   // ##############################################################################################
   If !ExistDir( "C:\SIMFRETE" )

      nRet := MakeDir( "C:\SIMFRETE" )
   
   Endif

   // ################################################################################
   // Envia para função que pesquisa a melhor opção de frete para o pedido de venda ##
   // ################################################################################
   If (FunName() == "MATA410") .OR. (FunName() == "AUTOM587")

      If inclui .Or. Altera

         // #####################################################
         // Calcula as margens dos produtos do pedido de venda ##
         // #####################################################
    	 If M->C5_TIPO == "N"

    	    For nContar := 1 To Len(aCols)
                K_Margem := 0
                K_Margem := U_AUTOM524(2                                                       ,; // 01 - Indica a chamada pelo Pedido de Venda
                                       IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL),; // 02 - Filial
                                       M->C5_NUM                                               ,; // 03 - Nº do Pedido de Venda
                                       aCols[ nContar, nPosItem ]                              ,; // 04 - Posição do Item no Pedido de Venda
                                       aCols[ nContar, nPosProd ]                              ,; // 05 - Código do Produto
                                       nContar                                                 ,; // 06 - Posição do Produto no Acols
                                       "R")                                                       // 07 -Indica tipo de retorno

                aCols[ nContar, nPosMar ]   := K_Margem

   	        Next nContar
   	        
   	     Endif

         // ################################################################################
         // Dispara a pesquisa no SIMFRETE                                                ##
         // Em 22/09/2017 foi definido que a pesquisa do SIMFRETE deve ser aberta a todos ##
         // ################################################################################

         // #####################################################################################################
         // Pesquisa se o usuário precisa visuzalizar a validação da tela de condição de pagamento do SimFrete ##
         // #####################################################################################################
         If Select("T_ACESSO") > 0
            T_ACESSO->( dbCloseArea() )
         EndIf
         
         cSql := ""
         cSql := "SELECT ZZ4_UCOT FROM ZZ4010"
        
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSO", .T., .T. )
         
         If U_P_OCCURS(T_ACESSO->ZZ4_UCOT, Alltrim(Upper(cUserName)), 1) == 0
            MelhorOpcaoFrete(0)
         Endif   

/*
         // ###################################################################################
         // Pesquisa parâmetros do parametrizador Automatech para liberar acesso ao SimFrete ##
         // ###################################################################################
         If Select("T_PARAMETROS") > 0
            T_PARAMETROS->( dbCloseArea() )
         EndIf
   
         cSql := ""
         cSql := "SELECT ZZ4_TGRU, "
         cSql += "       ZZ4_AGRU, "
         cSql += "       ZZ4_NGRU  "
         cSql += "  FROM " + RetSqlName("ZZ4")

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

         // #############################################################################
         // Dispara a pesquisa do simfrete somente para o grupo de vendedores (000011) ##
         // #############################################################################
         If T_PARAMETROS->ZZ4_TGRU == "S"
         
            // ########################################################
            // Verifica se o usuário logado precisa fazer a pesquisa ##
            // ########################################################
            If U_P_OCCURS(Alltrim(Upper(T_PARAMETROS->ZZ4_NGRU)), Alltrim(Upper(cUserName)), 1) == 0
               MelhorOpcaoFrete(0)
            Endif

         Else

            PswOrder(1)

            If PswSeek(__cUserId,.T.)

               aReturn := PswRet()

               // ##############################################################################
               // Se grupo de usuários 000011 - Vendedores ou 000028 - Compras, abre SimFrete ##
               // ##############################################################################
               // Liberação do grupo 000026 - Assistente Comercial autorizado por Maurílio em ##
               // 27/01/2017 por telefone juntamente com Thais Ogawa                          ## 
               // Inicialmente os grupos que podiam fazer pesquisas eram:                     ##
               // 000011, 000026, 000028 e 000000                                             ##
               // A partir do dia 31/01/2017, passa a ser lido o prâmetro ZZ4_AGRU do parame- ##
               // trizador do Sistema Automatech.                                             ##
               // ##############################################################################
               If U_P_OCCURS(Alltrim(Upper(T_PARAMETROS->ZZ4_AGRU)), Alltrim(Upper(aReturn[1][10][1])), 1) <> 0

                  If U_P_OCCURS(Alltrim(Upper(T_PARAMETROS->ZZ4_NGRU)), Alltrim(Upper(cUserName)), 1) == 0
                     MelhorOpcaoFrete(0)
                  Endif

               Else

                  // #################################################################################
                  // Verifica se pedido de venda possui frete liberado. Neste caso, abre o simfrete ##
                  // #################################################################################
           	      nPosFGratis := GdFieldPos("C6_ZGRA")		

                  lTemFreteGratuito := .F.

     	          For ix:= 1 To Len(aCols)
	  	  
	  	              If aCols[ix][nPosFGratis] == "L"
                         lTemFreteGratuito := .T.
                         Exit
                      Endif
                   
   	              Next ix

                  If lTemFreteGratuito == .T.

                     If U_P_OCCURS(Alltrim(Upper(T_PARAMETROS->ZZ4_NGRU)), Alltrim(Upper(cUserName)), 1) == 0
                        If MsgYesNo("Deseja realizar a pesquisa SimFrete?")
                           MelhorOpcaoFrete(1)               
                        Endif                                
                     Endif

                  Endif   
            
               Endif   
            
            Endif   

         Endif
*/         
         
         
      Endif   

   Endif

   If (FunName() == "TECA450")
		
      nPosOS    := GdFieldPos("C6_NUMOS")
	  nPosLocal := GdFieldPos("C6_LOCAL")	
	  nPosLcliz := GdFieldPos("C6_LOCALIZ")		
	  nPosNS    := GdFieldPos("C6_NUMSERI")		
		
      DbSelectArea("ZZZ");DbSetOrder(2)
		
	  For ix:= 1 To Len(aCols)
	  	  If (DbSeek(xFilial("SC6")+SubStr(Acols[ix][nPosOS],1,6)+SubStr(Acols[ix][nPosOS],9,2)))
		 	 aCols[ix][nPosLocal] := Posicione("AA1",1,xFilial("AA1")+ZZZ->ZZZ_TECNIC,"AA1_LOCAL") 
		   	 If (AllTrim(ZZZ->ZZZ_LOCALI) <> "Não Controla")
		   	 	aCols[ix][nPosLcliz] := ZZZ->ZZZ_LOCALI
		   		aCols[ix][nPosNS]    := ZZZ->ZZZ_NUMSER
		     EndIf
  	      EndIf
   	  Next ix
	
   EndIf
	        
   RestArea(aAreaSC6)
   RestArea(aArea)
	             
Return()

// ####################################################################################
// Função que abre janela de seleção de melhor opção de frete para o pedido de venda ##
// ####################################################################################
Static Function MelhorOpcaoFrete(_FreteGratis)

   Local lChumba      := .F.
   Local cSql         := ""
   Local cMemo1	      := ""
   Local oMemo1

   Private cOrigem    := Space(25)
   Private cDestino   := Space(25)
   Private cDadosPV   := ""
   Private oGet1
   Private oGet2
   Private oMemo2

   Private oDlg

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   // ################################################
   // Verifica o tipo de frete para aplicar a regra ##
   // ################################################
   If M->C5_TPFRETE == "C"
   Else
      Return(.T.)
   Endif

   // #####################################################################################################
   // Pesquisa dados do vendedor para aplicar regra - O Select abaixo verifica se o vendedor é executivo ##
   // #####################################################################################################
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SA3.A3_TIPOV "
   cSql += "  FROM " + RetSqlName("SA3") + " SA3 "
   cSql += " WHERE SA3.A3_COD     = '" + Alltrim(M->C5_VEND1) + "'"
   cSql += "   AND SA3.D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

//   If T_VENDEDOR->A3_TIPOV == '1'
//      Return(.T.)
//   Endif

   // #################################################
   // Pesquisa dados do pedido de venda para display ##
   // #################################################                                                       
   cDadosPV := cDadosPV + "FILIAL..: " + alltrim(cFilAnt)                    + Chr(13) + chr(10)
   cDadosPV := cDadosPV + "Nº P.V..: " + M->C5_NUM                           + Chr(13) + chr(10)
   cDadosPV := cDadosPV + "CLIENTE.: " + M->C5_CLIENTE + "." + M->C5_LOJACLI + Chr(13) + chr(10)
   cDadosPV := cDadosPV + "NOME....: " + POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_NOME") + Chr(13) + chr(10)
   cDadosPV := cDadosPV + "ENDEREÇO: " + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_BAIRRO")) + " - " + ;
                                          Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_MUN")) + "/" + ;   
                                          Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_EST"))
   Do Case
      Case cEmpAnt == "01"
           Do Case
              Case cFilAnt == "01"
                   cOrigem := "PORTO ALEGRE / RS"
              Case cFilAnt == "02"
                   cOrigem := "CAXIAS DO SUL / RS"
              Case cFilAnt == "03"
                   cOrigem := "PELOTAS / RS"
              Case cFilAnt == "04"
                   cOrigem := "PORTO ALEGRE / RS"
              Case cFilAnt == "05"
                   cOrigem := "SAO PAULO / SP"
              Case cFilAnt == "06"
                   cOrigem := "CARIACICA / ES"
              Case cFilAnt == "07"
                   cOrigem := "PORTO ALEGRE / ES"
           EndCase
      Case cEmpAnt == "02"
           cOrigem := "CURITIBA / PR"
      Case cEmpAnt == "03"
           cOrigem := "PORTO ALEGRE / PR"
      Case cEmpAnt == "04"
           cOrigem := "PELOTAS / RS"
   EndCase                         

   cDestino := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_MUN")) + "/" + ;   
               Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_EST"))

   // ###############################################
   // Limpa o campo de indicação de frete gratuito ##
   // ###############################################
   nPosGratuito := GdFieldPos("C6_ZGRA")
		
   If _FreteGratis == 0
      For nContar = 1 To Len(aCols)
          aCols[nContar][nPosGratuito] := "N"
      Next nContar
   Endif

   // ############################################################
   // Envia para a função que consome o web service do SimFrete ##
   // ############################################################
   If M->C5_EXTERNO == "1"
   Else
      
      BuscaSimFrete(_FreteGratis)
             
      If Len(aLista) == 0

//         // ########################################################
//         // Carrega as variáveis do pedido de venda para gravação ##
//         // ########################################################
//         nPosGratuito := GdFieldPos("C6_ZGRA")
//
//         If _FreteGratis == 0
//  	        For nContar = 1 To Len(aCols)
//   	 	        aCols[nContar][nPosGratuito] := "S"
//     	    Next nContar
//     	 Endif   

      Else   

         // #############################################
         // Desenha a tela para visualização dos dados ##
         // #############################################
         DEFINE MSDIALOG oDlg TITLE "Cotação de Frete" FROM C(178),C(181) TO C(601),C(942) PIXEL Style DS_MODALFRAME

         @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(030) PIXEL NOBORDER OF oDlg

         @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(374),C(001) PIXEL OF oDlg

         @ C(041),C(005) Say "Dados Pedido de Venda"                  Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
         @ C(092),C(005) Say "Origem"                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
         @ C(092),C(196) Say "Destino"                                Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
         @ C(114),C(005) Say "Selecione a melhor opção de transporte" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlg

         @ C(050),C(005) GET      oMemo2     Var cDadosPV  MEMO                    Size C(371),C(038)                              PIXEL OF oDlg When lChumba
         @ C(101),C(005) MsGet    oGet1      Var cOrigem                           Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
         @ C(101),C(196) MsGet    oGet2      Var cDestino                          Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

         @ C(196),C(339) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( ValidaSimFrete(_FreteGratis) )

         // Lista com os produtos do pedido selecionado
         @ 155,005 LISTBOX oLista FIELDS HEADER "Mrc", "Posição", "Valor Frete", "Prazo Dias", "Menor Valor", "Menor Prazo", "Código", "Transportadora" PIXEL SIZE 474,090 OF oDlg ;
                   ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

         oLista:SetArray( aLista )

         oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                					  aLista[oLista:nAt,02],;
          					          aLista[oLista:nAt,03],;
          					          aLista[oLista:nAt,04],;
          					          aLista[oLista:nAt,05],;
          					          aLista[oLista:nAt,06],;
          					          aLista[oLista:nAt,07],;          					    
          					          aLista[oLista:nAt,08]}}

         oDlg:lEscClose := .F.

         ACTIVATE MSDIALOG oDlg CENTERED 
         
      Endif   
      
   Endif   

Return(.T.)

// ###############################################################################
// Função que valida o frete e grava no pedido de venda os valores selecionados ##
// ###############################################################################
Static Function ValidaSimFrete(_FreteGratis)

   Local cSql         := ""
   Local nContar      := 0
   Local nQtdMarcados := 0
   Local lLiberado    := .F.   
   Local nDiaSFrete   := "0"

   Private lCotacao   := .F. // Trata se deve voltar a cotação de frete ou não
   Private cGravaVol  := ""

   // ###################################################################
   // Verifica se foi marcado mais do que uma opção. Permite somente 1 ##
   // ###################################################################
   nQtdMarcados := 0
   
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          nQtdMarcados := nQtdMarcados + 1
       Endif
   Next nContar
   
   If nQtdMarcados == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhuma opção foi selecionada." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   If nQtdMarcados > 1
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Permitido a marcação de apenas uma opção." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // ########################################
   // Atualiza os campos do pedido de venda ##
   // ########################################
   //É permitido frete gratuito?
   If _FreteGratis == 0

      // ########################################################
      // Carrega as variáveis do pedido de venda para gravação ##
      // ########################################################
      //A opção selecionada foi a primeira ("FRETE GRATUITO")?
      If aLista[01,01] == .T.

   	     For nContar = 1 To Len(aCols)
   	 	     aCols[nContar][nPosGratuito] := "S"
     	 Next nContar

         // ###################################################################################################
         // Tarefa # 4344 - Quando frete for gratuito, grava a transportadora mais barata no pedido de venda ##
         // ###################################################################################################
         If Len(aLista) > 1
            nDiaSfrete    := aLista[02,04]
            M->C5_TRANSP  := aLista[02,07]
            M->C5_MENNOTA := Alltrim(M->C5_MENNOTA) + CHR(13) + CHR(10) + "###" + aParametros[01,15] + "###"
            //M->C5_ZTCX    := aLista[02,09]

            // ###########################################################################################################################
            // Se o código da transportadora selecionada for 000008 (Correio), atualiza os campos necessário para esta transportadora   ##
            // e abre a tela para confirmação do endereço de entrega das mercadorias. (Serve para a impressão da etiqueta dos correios. ##
            // ###########################################################################################################################
            If aLista[02,07] == "000008"
               M->C5_TSRV    := aLista[02,08]
               M->C5_MENNOTA := Alltrim(M->C5_MENNOTA) + CHR(13) + CHR(10) + "###" + aParametros[01,15] + "###"
               //M->C5_ZTCX    := aLista[oLista:nAt,09]
               U_AUTOM617(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_TRANSP)
            Endif   
         Else
            nDiaSfrete := "0"
         Endif   
      
      Else

         nDiaSfrete    := aLista[oLista:nAt,04]
         M->C5_FRETE   := aLista[oLista:nAt,03]
         M->C5_TRANSP  := aLista[oLista:nAt,07]
         M->C5_MENNOTA := Alltrim(M->C5_MENNOTA) + CHR(13) + CHR(10) + "###" + aParametros[01,15] + "###"
         //M->C5_ZTCX    := aLista[oLista:nAt,09]

         // ###########################################################################################################################
         // Se o código da transportadora selecionada for 000008 (Correio), atualiza os campos necessário para esta transportadora   ##
         // e abre a tela para confirmação do endereço de entrega das mercadorias. (Serve para a impressão da etiqueta dos correios. ##
         // ###########################################################################################################################
         If aLista[oLista:nAt,07] == "000008"
            M->C5_TSRV    := aLista[oLista:nAt,08]
            M->C5_MENNOTA := Alltrim(M->C5_MENNOTA) + CHR(13) + CHR(10) + "###" + aParametros[01,15] + "###"
            //M->C5_ZTCX    := aLista[oLista:nAt,09]    
            U_AUTOM617(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_TRANSP)
         Endif   

   	     For nContar = 1 To Len(aCols)
   	 	     aCols[nContar][nPosGratuito] := "N"
     	 Next nContar
     	 
      Endif 	 

   Else

      M->C5_TRANSP  := aLista[oLista:nAt,07]
      M->C5_MENNOTA := Alltrim(M->C5_MENNOTA) + CHR(13) + CHR(10) + "###" + aParametros[01,15] + "###"
      //M->C5_ZTCX    := aLista[oLista:nAt,09]

      // ###########################################################################################################################
      // Se o código da transportadora selecionada for 000008 (Correio), atualiza os campos necessário para esta transportadora   ##
      // e abre a tela para confirmação do endereço de entrega das mercadorias. (Serve para a impressão da etiqueta dos correios. ##
      // ###########################################################################################################################
      If aLista[oLista:nAt,07] == "000008"
         M->C5_TSRV    := aLista[oLista:nAt,08]
         M->C5_MENNOTA := Alltrim(M->C5_MENNOTA) + CHR(13) + CHR(10) + "###" + aParametros[01,15] + "###"
         //M->C5_ZTCX    := aLista[oLista:nAt,09]
         U_AUTOM617(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_TRANSP)
      Endif   

   Endif

   // ###################################################################################################################
   // Atualiza o campo C5_ZRSM. Este campo guarda os comando de envio e retorno da consulta do Web Service do SimFrete ##
   // ###################################################################################################################
   kParaGravar := ""
   kParaGravar += "COMANDO EXECUTADO EM " + Dtoc(Date()) + " AS " + Time() + " USUÁRIO: " + Alltrim(cUserName)           + chr(13) + chr(10) + chr(13) + chr(10) 
   kParaGravar += "PARÂMETROS ENVIADOS:"                  + chr(13) + chr(10) + chr(13) + chr(10)
   kParaGravar += "LOGIN..........: " + aParametros[1,02] + chr(13) + chr(10)
   kParaGravar += "SENHA..........: " + aParametros[1,03] + chr(13) + chr(10)
   kParaGravar += "ORIGEM.........: " + aParametros[1,04] + chr(13) + chr(10)
   kParaGravar += "DESTINO........: " + aParametros[1,05] + chr(13) + chr(10)
   kParaGravar += "MODALIDADE.....: " + aParametros[1,06] + chr(13) + chr(10)
   kParaGravar += "TIPO FRETE.....: " + aParametros[1,07] + chr(13) + chr(10)
   kParaGravar += "TIPO OPERAÇÃO..: " + aParametros[1,08] + chr(13) + chr(10)
   kParaGravar += "CNPJ REMETENTE.: " + aParametros[1,09] + chr(13) + chr(10)
   kParaGravar += "NOME REMETENTE.: " + aParametros[1,10] + chr(13) + chr(10)
   kParaGravar += "CNPJ DESTINO...: " + aParametros[1,11] + chr(13) + chr(10)
   kParaGravar += "NOME DESTINO...: " + aParametros[1,12] + chr(13) + chr(10)
   kParaGravar += "TOTAL N.FISCAL.: " + aParametros[1,13] + chr(13) + chr(10)
   kParaGravar += "PESO  N.FISCAL.: " + aParametros[1,14] + chr(13) + chr(10)
   kParaGravar += "VOLUME N.FISCAL: " + aParametros[1,15] + chr(13) + chr(10)
   kParaGravar += "QTD N.FISCAL...: " + aParametros[1,16] + chr(13) + chr(10) + chr(13) + chr(10)
   kParaGravar += "PARÂMETROS RECEBIDOS"                  + chr(13) + chr(10) + chr(13) + chr(10)
   kParaGravar += Alltrim(kString)                        + chr(13) + chr(10) + chr(13) + chr(10)
   kParaGravar += Replicate("-", 118) + chr(13) + chr(10) + chr(13) + chr(10)
   
   M->C5_ZRSM  := M->C5_ZRSM + kParaGravar
   
   //ADICIONO OS VALORES PARA O QUOTEID E IPDELIVER
   M->C5_IPQID  := aLista[oLista:nAt,09]
   M->C5_IPDMID := aLista[oLista:nAt,10]
  
   
   // ##################################################################################
   // Verifica se a data de vencimento do simfrete for maior que a do pedido de venda ##
   // ##################################################################################

   // #####################################################################################################
   // Pesquisa se o usuário precisa visuzalizar a validação da tela de condição de pagamento do SimFrete ##
   // #####################################################################################################
   If Select("T_ACESSO") > 0
      T_ACESSO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_VUSU FROM ZZ4010"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSO", .T., .T. )

   If U_P_OCCURS(T_ACESSO->ZZ4_VUSU, Alltrim(Upper(cUserName)), 1) == 0

      lCotacao := .F.

      AltCPSimFrete(nDiaSfrete)
   
      If lCotacao == .T.
      Else   
         oDlg:End()
      Endif   

   Else

      oDlg:End()      
      
   Endif   
   
Return(.T.)   

// #####################################################################################
// Função que gera o cálculo do SalesMachine para os produtos do documento de entrada ##
// #####################################################################################
Static Function BuscaSimFrete(_FreteGratis)

   MsgRun("Aguarde! Pesquisando Cotação de Frete ...", "Cotação de Frete",{|| xBuscaSimFrete(_FreteGratis) })

Return(.T.)

// #########################################################
// Função que consome web service de consulta do SimFrete ##
// #########################################################
Static Function xBuscaSimFrete(_FreteGratis)

   Local cSql             := ""
// Local cComando         := ""
   Local cURLSimFrete     := Space(250)
   Local cEmpresaSimFrete := Space(050)
   Local cLoginSimFrete   := Space(020)
   Local cSenhaSimfrete   := Space(020)
   Local cEmailSimFrete   := Space(250)
   Local cCaminhoRetorno  := Space(250)
// Local cConteudo        := ""
   Local cString          := ""
   Local nContar          := 0
   Local xContar          := 0
// Local aDados           := {}
   Local cSTIM            := 15000000
   Local nRet
// Local xPosItem  := aScan( aHeader, { |x| x[2] == 'C6_ITEM   ' } )
   Local xPosProd  := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
   Local xPosValor := aScan( aHeader, { |x| x[2] == 'C6_VALOR  ' } )
   Local xPosQuant := aScan( aHeader, { |x| x[2] == 'C6_QTDVEN ' } )

   Local aEmbalagem   := {}
   Local nQtdCaixas   := 0
   Local nQtdIndiv    := 0
   Local nQtdVolumes  := 0
   Local nVolumeIndiv := 0
   Local nTentativas  := 0

   Local nVolTotal      := ""
   Local kUltimaEmba    := .F.
   Local cCidadeDestino := ""
   Local cNomeDestino   := ""
   Local cCNPJDestino   := ""
   Local cCEPDestino    := ""
   Local cCGCOrigem     := ""
   
   Local nNCnpj     := 0
   
   // #############################
   // Carrega o array aEmbalagem ##
   // #############################
   If Select("T_EMBALAGEM") > 0
      T_EMBALAGEM->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZPJ_FILIAL,"
   cSql += "       ZPJ_CODI  ,"
   cSql += "	   ZPJ_NOME  ,"
   cSql += "	   ZPJ_VTOT   "
   cSql += "  FROM " + RetSqlName("ZPJ")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY ZPJ_VTOT"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMBALAGEM", .T., .T. )

   T_EMBALAGEM->( DbGoTop() )
   
   WHILE !T_EMBALAGEM->( EOF() )
      aAdd( aEmbalagem, { T_EMBALAGEM->ZPJ_CODI, T_EMBALAGEM->ZPJ_NOME, T_EMBALAGEM->ZPJ_VTOT })
      T_EMBALAGEM->( DbSkip() )
   ENDDO

   // ################################################################# 
   // Pesquisa os parâmetros para consumo do web service do SimFrete ##
   // #################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_SFRE)) AS SIMFRETE"    
   cSql += "  FROM ZZ4010"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Parâmetros do SimFrete não definidos." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   cURLSimFrete     := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1)))
   cEmpresaSimFrete := IIF(T_PARAMETROS->( EOF() ), Space(050), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2))), Space(050), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2)))
   cLoginSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3)))
   cSenhaSimfrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4)))
   cEmailSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5)))
   cCaminhoRetorno  := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6)))

   If Empty(Alltrim(cURLSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "URL do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif
            
   If Empty(Alltrim(cEmpresaSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Empresa de pesquisa do Web Service do Sim Frete não parametrizada." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cLoginSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Login de pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cSenhaSimfrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Senha de pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCaminhoRetorno))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Caminho para gravação retorno da pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   // ############################################################
   // Carrega variáveis necessárias para consumo do web service ##
   // ############################################################
   Do Case
      Case cEmpAnt == "01"
           Do Case 
              Case cFilAnt == "01"
                   cCidadeOrigem  := "PORTO ALEGRE/RS"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)
              Case cFilAnt == "02"
                   cCidadeOrigem  := "CAXIAS DO SUL/RS"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)
              Case cFilAnt == "03"
                   cCidadeOrigem  := "PELOTAS/RS"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)
              Case cFilAnt == "04"
                   cCidadeOrigem  := "PORTO ALEGRE/RS"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)
              Case cFilAnt == "05"
                   cCidadeOrigem  := "SÃO PAULO/SP"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)
              Case cFilAnt == "06"
                   cCidadeOrigem  := "CARIACICA/ES"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)        
              Case cFilAnt == "07"
                   cCidadeOrigem  := "PORTO ALEGRE/ES"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)        
           EndCase
           cNomeOrigem := "AUTOMATECH SISTEMAS DE AUTOMACAO LTDA"
      Case cEmpAnt == "02"
           cCidadeOrigem := "CURITIBA/PR"   
           cCEPOrigem    := Alltrim(SM0->M0_CEPENT)           
           cNomeOrigem   := "TI AUTOMACAO E SERVICOS LTDA"
      Case cEmpAnt == "03"
           cCidadeOrigem := "PORTO ALEGRE/RS"
           cCEPOrigem     := Alltrim(SM0->M0_CEPENT)
    	   cNomeOrigem   := "ATECH SERVICOS DE AUTOMACAO LTDA"
   EndCase

   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )
   cCGCOrigem := SM0->M0_CGC

   // ###################################################
   // Pesquisa dados do cliente para carga de variável ##
   // ###################################################
   cCidadeDestino := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_MUN")) + "/" + ;
                     Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_EST"))
   cNomeDestino   := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_NOME"))
   cCNPJDestino   := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_CGC" )
   cCEPDestino    := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_CEP" )

   // ###########################################
   // Captura o valor total do Pedido de Venda ##
   // ###########################################
   nTotalPedido   := 0
   nVolumeTotal   := 0
   nPesoTotal     := 0
   nQtdVenda      := 0
   kSeqProduto    := ""
   kSeqQuantidade := ""
   kSeqValor      := 0

   For xContar = 1 to Len(aCols)

	   _nDel := Len( aHeader ) + 1 

	   If _nDel == Nil
	      Loop
       Endif

       // ######################################################################
       // Verificando última posição do acols para verificar deleção da linha ##
       // ######################################################################
	   _lDel := aCols[ xContar, _nDel ] 
	
	   If _nDel == Nil
	      Loop
	   Endif

       // ################################
       // Se estiver deletado, despreza ##
       // ################################
	   If _lDel 
	      Loop
	   EndIf

       // #################################################################################################
       // Carrega a string com os códigos dos produtos a serem enviados ao Web Service do SimFrete do SM ##
       // #################################################################################################
       kSeqProduto := kSeqProduto + Alltrim(aCols[xContar,xPosProd]) + "|"

       // #####################################################################################################
       // Carrega a string com as quantidades dos produtos a serem enviados ao Web Service do SimFrete do SM ##
       // #####################################################################################################
       kSeqQuantidade := kSeqQuantidade + Alltrim(Str(aCols[xContar, xPosQuant])) + "|"

       // ######################################################################################################
       // Carrega a string com o valor total dos produtos (R$) a ser enviado ao Web Service do SimFrete do SM ##
       // ######################################################################################################
       kSeqValor := kSeqValor + aCols[xContar, xPosValor]

       // ################################################
       // Carrega o Valor Total (R$) do Pedido de Venda ##
       // ################################################
       nTotalPedido := nTotalpedido + aCols[xContar, xPosValor]

       // #######################################################
       // Carrega o Peso total dos produtos do pedido de venda ##
       // #######################################################
       nPesoTotal   := nPesoTotal   + (POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_PESC") * aCols[xContar, xPosQuant])

       // #############################################################
       // Carrega a quantidade total dos produtos do pedido de venda ##
       // #############################################################
       nQtdVenda    := nQtdVenda    + aCols[xContar, xPosQuant]

       // ######################################
       // Calcula o volume total dos produtos ##
       // ######################################
       If POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_EMBA")$("1#2#3#4#5#6#7")
          If POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_ZVIN") == "N"
             nVolumeIndiv := nVolumeIndiv + U_AUTOM630(POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_EMBA"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_ALTU"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_LARG"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_COMP"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_ZBAS"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_RAIO"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_LADO"),;
                                                       aCols[xContar, xPosQuant])   
          Else                                                     
             nQtdIndiv    := nQtdIndiv + 1
             nVolumeTotal := nVolumeTotal + U_AUTOM630(POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_EMBA"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_ALTU"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_LARG"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_COMP"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_ZBAS"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_RAIO"),;
                                                       POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_LADO"),;
                                                       aCols[xContar, xPosQuant])   
          Endif                                                    
       Endif   

   Next xContar    

   // ################################################################################################
   // Elimina o último | da string dos códigos das strings de consumo do web service do SimFrete SM ##
   // ################################################################################################
   kSeqProduto    := Substr(kSeqProduto   , 01, Len(Alltrim(kSeqProduto)) - 1)
   kSeqQuantidade := Substr(kSeqQuantidade, 01, Len(Alltrim(kSeqQuantidade)) - 1)
   kSeqValor      := Alltrim(Str(kSeqValor))

   // ##################################
   // Calcula a quantidade de volumes ##
   // ##################################
   nQtdCaixas    := 0
   nQtdVolumes   := 0
   nEmbalar      := nVolumeIndiv + nVolumeTotal    
   kUltimaEmba   := .F.
   cGravaVol     := ""

   While nEmbalar <> 0   

      For xContar = 1 to Len(aEmbalagem)
  
          If nEmbalar <= aEmbalagem[xContar,03]

             nQtdVolumes := nQtdVolumes + 1
             cGravaVol   := cGravaVol + "1 " + Alltrim(aEmbalagem[xContar,02]) + " - "

             nEmbalar := nEmbalar - aEmbalagem[xContar,03]

             If nEmbalar < 0
                nEmbalar := 0
             Endif   

             Exit
                            
          Else
          
             If xContar == Len(aEmbalagem)
                nQtdVolumes := nQtdVolumes + 1
                cGravaVol   := cGravaVol + "1 " + Alltrim(aEmbalagem[xContar,02]) + " - "
                nEmbalar    := (aEmbalagem[xContar,03] - nEmbalar) * -1
             Endif   
          
          Endif      

      Next xContar

   Enddo

   // #######################################################
   // Junta as Quantidades de Volumes + os Volumes Cúbicos ##
   // #######################################################
   nQtdVolumes  := nQtdVolumes  &&  + nQtdIndiv
   nVolumeTotal := nVolumeTotal + nVolumeIndiv
   nVolTotal    := ""
   nVolumeTotal := nQtdVolumes * nVolumeTotal

   // #############################
   // Trata o tipo de transporte ##
   // #############################
   If M->C5_ZROD == "R"
      kModal := "rod"
   Else
      kModal := "aer"
   Endif

   // ###############################################
   // Prepara as variáveis para enviá-las pela URL ##
   // ###############################################
   nTotalPedido := IIF(nTotalPedido == 0, "0.00"    , Alltrim(Str(nTotalPedido,10,02)))
   nPesoTotal   := IIF(nPesoTotal   == 0, "0.000000", Alltrim(Str(nPesoTotal,10,06)))
   nVolumeTotal := IIF(nVolumeTotal == 0, "0.000000", Alltrim(Str(nVolumeTotal,10,06)))
   nQtdVenda    := IIF(nQtdVenda    == 0, "0"       , Alltrim(Str(nQtdVenda)))
   
// ---------------------------------------------------------

   cSURL   := Alltrim(GETMV("MV_SMURLFR")) //Parametro contendo URL de consulta de frete
    
   // ########################################### 
   // Monta String com os códigos dos produtos ##
   // ###########################################  
   cString := ''
   cString := ' {' 
   cString += ' "empresa":'     + '"' + cEmpAnt        + '"' + ', '
   cString += ' "filial":'      + '"' + cFilAnt        + '"' + ', '
   cString += ' "cep":'         + '"' + cCEPDestino    + '"' + ', '
   cString += ' "produtos":'    + '"' + kSeqProduto    + '"' + ', '
   cString += ' "quantidades":' + '"' + kSeqQuantidade + '"' + ', '
   cString += ' "total":'       + '"' + kSeqValor      + '"'
   cString += ' }'

   // ########################################################################################
   // Elimina o arquivo de enviodemo.txt e retornodemo.txt antes de enviar nova solicitação ##
   // ########################################################################################
   If File("C:\SIMFRETE\ENVIOSM.TXT")
      fErase("C:\SIMFRETE\ENVIOSM.TXT")
   Endif

   If File("C:\SIMFRETE\RETORNOSM.TXT")
      fErase("C:\SIMFRETE\RETORNOSM.TXT")
   Endif   

   // ######################################################
   // Cria o arquivo de envio da solicitação ao FreshDesk ##
   // ######################################################
   nHdl := fCreate("C:\SIMFRETE\ENVIOSM.TXT")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   // ########################################################
   // Consome o Web Service do SM para consulta do SimFrete ##
   // ########################################################
   WaitRun('AtechHttpPost2.exe' + ' ' + Alltrim(cSURL) + ' ' + 'C:\SIMFRETE\RETORNOSM.TXT' + ' ' + 'C:\SIMFRETE\ENVIOSM.TXT' + ' ' + 'application/json' + ' ' + "--ignore_remote_cert")

   // ###########################################################
   // Verifica se o arquivo de retorno foi criado no diretório ##
   // ###########################################################
   WHILE nTentativas < cSTIM
      If File("C:\SIMFRETE\RETORNOSM.TXT")
         lExiste := .T.
         Exit
      Endif
      nTentativas := nTentativas + 1
   Enddo

   If lExiste == .F.
      Return(.T.)
   Endif
                                                  
   // ##########################################
   // Trata o retorno do envio da solicitação ##
   // ##########################################

   // #################################################################################
   // Abre o arquivo de retorno para capturar o código do ticket gerado no freshdesk ##
   // #################################################################################
   nHandle := FOPEN("C:\SIMFRETE\RETORNOSM.TXT", FO_READWRITE + FO_SHARED)
      
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de retorno da consulta SimFrete do SM em C:\SIMFRETE\RETORNOSM.TXT")
      Return .T.
   Endif

   // ################################
   // Lê o tamanho total do arquivo ##
   // ################################
// nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // Lê todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   FCLOSE(nHandle)

   // #############################################################
   // Se houve erro, avisa o usuário e grava dados na tebela ZPL ##
   // #############################################################
   If U_P_OCCURS(xBuffer, "(422)", 1) <> 0

      kErro := ""
      kErro := "Comando executado em " + Dtoc(Date()) + " as " + Time() + " Usuário: " + Alltrim(cUserName) + chr(13) + chr(10) + chr(13) + chr(10) 
      kErro += "Erro Retornado"        + chr(13) + chr(10) + chr(13) + chr(10) 
      kErro += Alltrim(xBuffer)        + chr(13) + chr(10) + chr(13) + chr(10) 
      kErro += "Parâmetros Enviados"   + chr(13) + chr(10) + chr(13) + chr(10)       
      kErro += Alltrim(cString)        + chr(13) + chr(10) + chr(13) + chr(10)

	  DbSelectArea("ZPL")
	  Reclock("ZPL",.T.)
      ZPL->ZPL_FILIAL := cFilAnt
      ZPL->ZPL_PEDI   := M->C5_NUM
      ZPL->ZPL_RETO   := kErro
	  MsUnlock()
    
      MsgAlert("ATENÇÃO!"                                                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Houve erro na consulta da cotação do Frete."                    + chr(13) + chr(10) + ;
               "Este aviso já foi enviado a logística para análise."            + chr(13) + chr(10) + ;
               "Favor entrar em contato com a logística para maiores detalhes.")

      Return(.T.)
   Endif
         
   // ################################################
   // Captura todo o retorno recebido pára gravação ##
   // ################################################
   kString := xBuffer

   // ##################################################################
   // Captura os parâmetros enviados para o web service para pesquisa ##
   // ##################################################################
   xParametros    := StrTran(SUBSTR(XBUFFER, VAL(U_P_OCCURS(XBUFFER, "request_simfrete", 0))), ",", "|")
   kLogin         := StrTran(u_p_corta(U_P_CORTA(xParametros, "|", 01) + ":", ":",3), '"', "")
   kSenha         := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 03) + ":", ":", 2), '"', "")   
   kOrigem        := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 04) + ":", ":", 2), '"', "") 
   kDestino       := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 05) + ":", ":", 2), '"', "")
   kModalidade    := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 06) + ":", ":", 2), '"', "")
   kTipoFrete     := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 07) + ":", ":", 2), '"', "") 
   kTipoOperacao  := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 08) + ":", ":", 2), '"', "")
   kCNPJRemetente := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 09) + ":", ":", 2), '"', "")
   kNomeRemetente := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 10) + ":", ":", 2), '"', "")
   kCNPJDestino   := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 11) + ":", ":", 2), '"', "")
   kNomeDestino   := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 12) + ":", ":", 2), '"', "")
   kTotalNFiscal  := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 13) + ":", ":", 2), '"', "")
   kPesoNFiscal   := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 14) + ":", ":", 2), '"', "")
   kVolumeNF      := StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 15) + ":", ":", 2), '"', "")
   kQtdNFiscal    := U_P_CORTA(StrTran(U_P_CORTA(U_P_CORTA(xParametros, "|", 16) + ":", ":", 2), '"', ""), "}", 1)

   aAdd( aParametros, {xParametros   ,; // 01
                       kLogin        ,; // 02
                       kSenha        ,; // 03
                       kOrigem       ,; // 04
                       kDestino      ,; // 05
                       kModalidade   ,; // 06
                       kTipoFrete    ,; // 07
                       kTipoOperacao ,; // 08
                       kCNPJRemetente,; // 09
                       kNomeRemetente,; // 10
                       kCNPJDestino  ,; // 11
                       kNomeDestino  ,; // 12
                       kTotalNFiscal ,; // 13
                       kPesoNFiscal  ,; // 14
                       kVolumeNF     ,; // 15
                       kQtdNFiscal   }) // 16

   // ##########################
   // Alimenta o array aLista ##
   // ##########################
   aLista := {}

   If _FreteGratis == 0
      aAdd( aLista, { .F., "FRETE GRATUÍTO", "", "", "", "", "", "","","" } )
   Endif   

   For nContar = 1 to U_P_OCCURS(xBuffer, "}", 1)

       cSepara := U_P_CORTA(xBuffer, "}", nContar)                                                        
       
       If nContar == 1
          cSepara := StrTran(cSepara, ",", "|") + "|"
          kIpQuoteId := U_P_CORTA(U_P_CORTA(cSepara, "|", 1) + ":", ":", 3)
          kIpDeliver := U_P_CORTA(U_P_CORTA(cSepara, "|", 2) + ":", ":", 2)
          kValor := U_P_CORTA(U_P_CORTA(cSepara, "|", 3) + ":", ":", 2)          
          kPrazo := U_P_CORTA(U_P_CORTA(cSepara, "|", 4) + ":", ":", 2)          
          kBarato := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 5) + ":", ":", 2) == "true", "SIM", "NÃO")
          kRapido := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 6) + ":", ":", 2) == "true", "SIM", "NÃO")  
          kNomeT  := StrTran(U_P_CORTA(U_P_CORTA(CsEPARA, "|", 7) + ":", ":", 2), '"', "")        
          kCNPJ   := StrTran(U_P_CORTA(U_P_CORTA(cSepara, "|", 8) + ":", ":", 2), '"', "")                                                                                              
       Else
          cSepara := StrTran(cSepara, ",", "|")
          kIpQuoteId := U_P_CORTA(U_P_CORTA(cSepara, "|", 2) + ":", ":", 2)
          kIpDeliver := U_P_CORTA(U_P_CORTA(cSepara, "|", 3) + ":", ":", 2)
          kValor  := U_P_CORTA(U_P_CORTA(cSepara, "|", 4) + ":", ":", 2)   
          kPrazo  := U_P_CORTA(U_P_CORTA(cSepara,"|", 5) + ":", ":",2)    
          kBarato := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 6) + ":", ":", 2) == "true", "SIM", "NÃO")   
          kRapido := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 7) + ":", ":", 2) == "true", "SIM", "NÃO")          
          kNomeT  := StrTran(U_P_CORTA(U_P_CORTA(CsEPARA, "|", 8) + ":", ":", 2), '"', "")  
          kCNPJ   := StrTran(U_P_CORTA(U_P_CORTA(cSepara, "|", 9) + ":", ":", 2), '"', "")                                                                                                                        
       Endif
       
       //Caso não contenha CNPJ na transportadora ele omite esta 
       If Empty(kCNPJ)
	      nNCnpj++
	 	  Loop
  	   Endif        
                                        
       If VAL(kValor) == 0
          Loop
       Endif   
       
       // ######################################
       // Pesquisa a transportadora pelo cnpj ##
       // ######################################
       If Select("T_TRANSPORTADORA") > 0
          T_TRANSPORTADORA->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A4_COD ,"
       cSql += "       A4_NOME "
       cSql += "  FROM SA4010 "
       cSql += " WHERE SUBSTRING(A4_CGC,01,08) = '" + Substr(kCNPJ,01,08) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTADORA", .T., .T. )

       If T_TRANSPORTADORA->( EOF() )
          Loop
       Else
          cCodTransp := T_TRANSPORTADORA->A4_COD
          cNomTransp := T_TRANSPORTADORA->A4_NOME
       Endif   
       
       // ##################################################################
       // Alimenta o array aLista para visualização dos fretes retornados ##
       // ##################################################################
       aAdd( aLista, { .F.                  ,; // 01 - Marcação da Cotação
                       Alltrim(Str(nContar)),; // 02 - Posição da Cotação
                       Val(kValor)          ,; // 03 - Valor do Frete
                       kPrazo               ,; // 04 - Prazo dias
                       kBarato              ,; // 05 - Menor Valor
                       kRapido              ,; // 06 - Menor Prazo
                       cCodTransp           ,; // 07 - Código Transportadora
                       cNomTransp           ,; // 08 - Nome da Transportadora
                       kIpQuoteId			,; // 09 - Quote Id
                       kIpDeliver			}) // 10 - IpDeliver

   Next nContar
   
   If nNCnpj>0 
      MsgAlert("Atenção, algumas opções de frete foram omitidas devido a uma inconsistência no cadastro da transportadora. "+ENTER+ENTER+"Favor entrar em contato com a área de Tecnologia.")      
   EndIf		
		
   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "" } )
   Endif   

Return(.T.)

// ###############################################################
// Função que valida o vencimento do SimFrete X Pedido de Venda ##
// ###############################################################
Static Function AltCPSimFrete(kDiaSfrete)

   Local cSql     := ""
   Local kPartida := 0
   Local kSDiasSF := 0
   Local kSDiasPV := 0
   Local cMemo1	  := ""
   Local oMemo1

   Local aParc    := {}

   Private aPagamentos := {}
   Private cComboBx1

   Private oDlgPgt

   // ###############################################################################################
   // Somente irá realizar esta consistência para pedidos de venda com forma de pagamento = BOLETO ##
   // ###############################################################################################
   If Posicione("SE4", 1, xFilial("SE4") + M->C5_CONDPAG, "E4_BOLET") == "S"
   Else
      Return(.T.)
   Endif

   // #################################################################################
   // Se condição de pagamento = 120 - 7 Dias antecipados, não realiza a verificação ##
   // #################################################################################
   If M->C5_CONDPAG == "120"
      Return(.T.)
   Endif

   // ###########################################################################################################
   // Lê os parâmetros do Paramereizador Automatech para validação da condição de pagamento do pedido de venda ##
   // ###########################################################################################################
   If Select("T_VENCIMENTO") > 0
      T_VENCIMENTO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_VCSF, "
   cSql += "       ZZ4_DDOM, "
   cSql += "       ZZ4_DSAB, "
   cSql += "       ZZ4_SDIA, "
   cSql += "       ZZ4_FNAC, "
   cSql += "       ZZ4_FREG, "
   cSql += "       ZZ4_VUSU  "
   cSql += "  FROM ZZ4010 "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENCIMENTO", .T., .T. )

   // ####################################################################
   // Verifica se a consistência é para ser aplicada conforme parâmetro ##
   // ####################################################################
   If T_VENCIMENTO->ZZ4_VCSF == "S"
   Else
      Return(.T.)
   Endif   

   // ##################################################################
   // Verifica se o usuário logado não precisa aplicar esta validação ##
   // ##################################################################
   If U_P_OCCURS(UPPER(ALLTRIM(T_VENCIMENTO->ZZ4_VUSU)), Upper(Alltrim(cUserName)), 1) == 0
   Else
      Return(.T.)
   Endif     

   // ###########################################
   // Após homologação, retirar esta validação ##
   // ###########################################
// If Upper(Alltrim(cUserName))$("MARCOS.BARBOZA#CAROLINE.MARTINS#ADMINISTRADOR")    
// Else
//    Return(.T.)
// Endif   
   
   // ###########################################
   // Captura os feriados nacionais e reginais ##
   // ###########################################
   pNacional := T_VENCIMENTO->ZZ4_FNAC
   pRegional := T_VENCIMENTO->ZZ4_FREG

   // ###################################
   // Calcula o vencimento do SimFrete ##
   // ###################################
   kSimFrete := Date()   

   For xx = 1 to (INT(VAL(kDiaSfrete)) + T_VENCIMENTO->ZZ4_SDIA)

       kSimFrete := Date() + xx
       
       // #################################
       // Verifica se a data é um sábado ##
       // #################################
       If T_VENCIMENTO->ZZ4_DSAB == "S"
       Else
          If Dow(kSimfrete) == 7
             kSimFrete := kSimfrete + 1
             Loop
          Endif   
       Endif   

       // ##################################
       // Verifica se a data é um domingo ##
       // ##################################
       If T_VENCIMENTO->ZZ4_DDOM == "S"
       Else
          If Dow(kSimfrete) == 1
             kSimFrete := kSimFrete + 1
             Loop
          Endif   
       Endif   

       // ###########################################
       // Verifica se a data é um feriado nacional ##
       // ###########################################
       kFeriado := Substr(Dtoc(kSimFrete),01,05)

       If U_P_OCCURS(pNacional, kFeriado, 1) > 0
          kSimFrete := kSimFrete + 1
          Loop
       Endif   
    
       // ###########################################
       // Verifica se a data é um feriado regional ##
       // ###########################################
       If U_P_OCCURS(pRegional, kFeriado, 1) > 0
          kSimFrete := kSimFrete + 1
          Loop
       Endif   

   Next xx    

   // #################################
   // Verifica se a data é um sábado ##
   // #################################
   If T_VENCIMENTO->ZZ4_DSAB == "S"
   Else
      If Dow(kSimFrete) == 7
         kSimFrete := kSimFrete + 1
      Endif   
   Endif   

   // ##################################
   // Verifica se a data é um domingo ##
   // ##################################
   If T_VENCIMENTO->ZZ4_DDOM == "S"
   Else
      If Dow(kSimFrete) == 1
         kSimFrete := kSimFrete + 1
      Endif   
   Endif   

   // ###########################################
   // Verifica se a data é um feriado nacional ##
   // ###########################################
   kFeriado := Substr(Dtoc(kSimFrete),01,05)

   If U_P_OCCURS(pNacional, kFeriado, 1) > 0
      kSimFrete := kSimFrete + 1
   Endif   

   kFeriado := Substr(Dtoc(kSimFrete),01,05)
       
   // ###########################################
   // Verifica se a data é um feriado regional ##
   // ###########################################
   If U_P_OCCURS(pRegional, kFeriado, 1) > 0
      kSimFrete := kSimFrete + 1
   Endif                         

   // ###########################################################################################################
   // Realiza o desdobramento doas parcelas para verificar se a data do Protheus está coerrente com o SimFrete ##
   // ###########################################################################################################
   aParc := Condicao(1000,M->C5_CONDPAG,,dDataBase)
              
   If !Empty(aParc) .AND.  M->C5_CONDPAG != "107"
	   If aParc[1][1] >= kSimfrete 
	      Return(.T.)
	   Endif 
   Else
      If M->C5_CONDPAG == "107"
      	  Return(.T.)
      EndIf
   EndIf 

   // #######################################################################################
   // Pesquisa todas as condições de pagamento que permitem imprimir boleto para validação ##
   // #######################################################################################
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E4_CODIGO,"
   cSql += "       E4_DESCRI,"
   cSql += "       E4_COND  ,"
   cSql += "       E4_BOLET  "
   cSql += "  FROM SE4010 "
   cSql += " WHERE D_E_L_E_T_ = '' "
   cSql += "   AND E4_BOLET   = 'S'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
           
   aParc := {}

   T_CONDICAO->( DbGoTop() )
   
   WHILE !T_CONDICAO->( EOF() )
   
      // ########################################################
      // Calcula as parcelas para a condição de pagamengo lida ##
      // ########################################################
      aParc := Condicao(1000,T_CONDICAO->E4_CODIGO,,dDataBase)

      If Len(aParc) == 0
      Else

         If U_P_CORTA(T_CONDICAO->E4_COND, ",", 1) == "00"
            dCompara := aParc[2][1]
         Else
            dCompara := aParc[1][1]
         Endif   

         If dCompara >= kSimfrete            
            aAdd( aPagamentos, T_CONDICAO->E4_CODIGO + " - " + Alltrim(T_CONDICAO->E4_DESCRI) )
         Endif

      Endif   
   
      T_CONDICAO->( DbSkip() )
      
   ENDDO

   // #############################################################
   // Desenha a tela para visualização das condições de paamento ##
   // #############################################################
   DEFINE MSDIALOG oDlgPgt TITLE "Cond. Pgtº Pedido de Venda X SimFrete" FROM C(178),C(181) TO C(403),C(693) PIXEL  Style DS_MODALFRAME 

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgPgt

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(249),C(001) PIXEL OF oDlgPgt

   @ C(039),C(005) Say "A T E N Ç Ã O !"                                                                                          Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgPgt
   @ C(050),C(005) Say "A Cond. Pgtº  utilizada neste pedido de venda é inferior ao prazo de entrega das mercadorias no Cliente." Size C(247),C(008) COLOR CLR_BLACK PIXEL OF oDlgPgt
   @ C(060),C(005) Say "Selecione outra Cond. Pgtº para atender a este Pedido de Venda."                                          Size C(157),C(008) COLOR CLR_BLACK PIXEL OF oDlgPgt
   @ C(071),C(005) Say "Condições de Pagamento"                                                                                   Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgPgt
      
   @ C(080),C(005) ComboBox cComboBx1 Items aPagamentos Size C(246),C(010) PIXEL OF oDlgPgt

   @ C(095),C(069) Button "Retornar a Cotação" Size C(059),C(012) PIXEL OF oDlgPgt ACTION( lCotacao := .T., oDlgPgt:End() )
   @ C(095),C(129) Button "Confirmar"          Size C(059),C(012) PIXEL OF oDlgPgt ACTION( VerEfechar(cComboBx1) )
      
   oDlgPgt:lEscClose := .F.
         
   ACTIVATE MSDIALOG oDlgPgt CENTERED 
      
Return(.T.)      

// #########################################################
// Função que valida a condição de pafgamento selecionada ##
// #########################################################
Static Function VerEfechar(kCondicao)

   If Substr(kCondicao,01,03) == "000"
      MsgAlert("Necessário selecionar uma condição de pagamento para continuar.")
      Return(.T.)
   Endif
   
   M->C5_CONDPAG := Substr(kCondicao,01,03)

   lCotacao := .F.

   oDlgPgt:End() 
  
Return(.T.)  