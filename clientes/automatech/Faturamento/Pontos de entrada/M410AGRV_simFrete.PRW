#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

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

   U_AUTOM628("M410AGRV")

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

   // ################################################
   // Pesquisa dados do vendedor para aplicar regra ##
   // ################################################
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

   If T_VENDEDOR->A3_TIPOV == '1'
      Return(.T.)
   Endif

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
           EndCase
      Case cEmpAnt == "02"
           cOrigem := "CURITIBA / PR"
      Case cEmpAnt == "03"
           cOrigem := "PORTO ALEGRE / PR"
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
   If _FreteGratis == 0

      // ########################################################
      // Carrega as variáveis do pedido de venda para gravação ##
      // ########################################################
      If aLista[01,01] == .T.

   	     For nContar = 1 To Len(aCols)
   	 	     aCols[nContar][nPosGratuito] := "S"
     	 Next nContar

         // ###################################################################################################
         // Tarefa # 4344 - Quando frete for gratuito, grava a transportadora mais barata no pedido de venda ##
         // ###################################################################################################
         If Len(aLista) > 1
            M->C5_TRANSP := aLista[02,07]
         Endif   
      
      Else

         M->C5_FRETE  := Val(aLista[oLista:nAt,03])
         M->C5_TRANSP := aLista[oLista:nAt,07]

         // ###########################################################################################################################
         // Se o código da transportadora selecionada for 000008 (Correio), atualiza os campos necessário para esta transportadora   ##
         // e abre a tela para confirmação do endereço de entrega das mercadorias. (Serve para a impressão da etiqueta dos correios. ##
         // ###########################################################################################################################
         If aLista[oLista:nAt,07] == "000008"
            M->C5_TSRV := aLista[oLista:nAt,08]
            U_AUTOM617(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_TRANSP)
         Endif   

   	     For nContar = 1 To Len(aCols)
   	 	     aCols[nContar][nPosGratuito] := "N"
     	 Next nContar
     	 
      Endif 	 

   Else

      M->C5_TRANSP := aLista[oLista:nAt,07]

      // ###########################################################################################################################
      // Se o código da transportadora selecionada for 000008 (Correio), atualiza os campos necessário para esta transportadora   ##
      // e abre a tela para confirmação do endereço de entrega das mercadorias. (Serve para a impressão da etiqueta dos correios. ##
      // ###########################################################################################################################
      If aLista[oLista:nAt,07] == "000008"
         M->C5_TSRV := aLista[oLista:nAt,08]
         U_AUTOM617(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_TRANSP)
      Endif   

   Endif

   oDlg:End()
   
Return(.T.)   

// #########################################################
// Função que consome web service de consulta do SimFrete ##
// #########################################################
Static Function BuscaSimFrete(_FreteGratis)

   Local cSql             := ""
   Local cComando         := ""
   Local cURLSimFrete     := Space(250)
   Local cEmpresaSimFrete := Space(050)
   Local cLoginSimFrete   := Space(020)
   Local cSenhaSimfrete   := Space(020)
   Local cEmailSimFrete   := Space(250)
   Local cCaminhoRetorno  := Space(250)
   Local cConteudo        := ""
   Local cString          := ""
   Local nContar          := 0
   Local xContar          := 0
   Local aDados           := {}
   Local cSTIM            := 500000
   Local nRet
   Local xPosItem  := aScan( aHeader, { |x| x[2] == 'C6_ITEM   ' } )
   Local xPosProd  := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
   Local xPosValor := aScan( aHeader, { |x| x[2] == 'C6_VALOR  ' } )
   Local xPosQuant := aScan( aHeader, { |x| x[2] == 'C6_QTDVEN ' } )
   
   // ################################################################# 
   // Pesquisa os parâmetros para consumo do web service do SimFrete ##
   // #################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_SFRE)) AS SIMFRETE"    
   cSql += "  FROM " + RetSqlName("ZZ4")

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
   nTotalPedido := 0
   nPesoTotal   := 0
   nVolumeTotal := 0
   nQtdVenda    := 0

   For xContar = 1 to Len(aCols)

	   _nDel := Len( aHeader ) + 1 

	   If _nDel == Nil
	      Loop
       Endif

	   _lDel := aCols[ xContar, _nDel ] // Verificando última posição do acols para verificar deleção da linha
	
	   If _nDel == Nil
	      Loop
	   Endif

	   If _lDel // Se estiver deletado
	      Loop
	   EndIf

       // ########################################
       // Pesquisa dados do produto selecionado ##
       // ########################################
       If Select("T_PRODUTOS") > 0
          T_PRODUTOS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT SB1.B1_GRUPO  ,"
       cSql += "       SB1.B1_PESC   ,"
       cSql += "       SB1.B1_COMP   ,"
       cSql += "       SB1.B1_ALTU   ,"
       cSql += "       SB1.B1_LARG   ,"
       cSql += "      (SB1.B1_COMP * SB1.B1_ALTU * SB1.B1_LARG) AS VOLUME"
       cSql += "  FROM " + RetSqlName("SB1") + " SB1  "
       cSql += " WHERE SB1.B1_COD     = '" + Alltrim(aCols[xContar, xPosProd]) + "'"
       cSql += "   AND SB1.D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

       T_PRODUTOS->( DbGoTop() )
   
       WHILE !T_PRODUTOS->( EOF() )
 
         nTotalPedido := nTotalpedido + aCols[xContar, xPosValor]
         nPesoTotal   := nPesoTotal   + T_PRODUTOS->B1_PESC

         // ####################################################################################################################
         // Conforme instruções do Sr. Maurilio em 23/01/2017, para produtos de suprimentos o cálculo é único conforme abaixo ##
         // ####################################################################################################################
         If T_PRODUTOS->B1_GRUPO$("0201#0202")
            nVolumeTotal := 0.005
         Else
            nVolumeTotal := nVolumeTotal + ((T_PRODUTOS->VOLUME / 1000000) * aCols[xContar, xPosQuant])
         Endif
            
         nQtdVenda    := nQtdVenda    + aCols[xContar, xPosQuant]

         T_PRODUTOS->( DbSkip() )
      
       ENDDO   
       
   Next xContar   

   nTotalPedido := IIF(nTotalPedido == 0, "0.00"    , Alltrim(Str(nTotalPedido,10,02)))
   nPesoTotal   := IIF(nPesoTotal   == 0, "0.000000", Alltrim(Str(nPesoTotal,10,06)))
   nVolumeTotal := IIF(nVolumeTotal == 0, "0.000000", Alltrim(Str(nVolumeTotal,10,06)))
   nQtdVenda    := IIF(nQtdVenda    == 0, "0"       , Alltrim(Str(nQtdVenda)))
   
   // ######################################################################
   // Elabora a string de solicitação de pesquisa do Web Service SimFrete ##
   // ######################################################################
   cComando := ""
   cComando := Alltrim(cURLSimFrete)                                       + ;
               "wsemp="    + Alltrim(cEmpresaSimFrete)                     + ;
               "&wsusr="   + Alltrim(cLoginSimFrete)                       + ;
               "&wspwd="   + Alltrim(cSenhaSimfrete)                       + ;
               "&origem="  + Alltrim(cCEPOrigem)                           + ;
               "&destino=" + Alltrim(cCEPDestino)                          + ;
               "&ciffob=C"                                                 + ;
               "&remCNPJ=" + Alltrim(cCGCOrigem)                           + ;
               "&remNome=" + Alltrim(cNomeOrigem)                          + ;
               "&desCNPJ=" + Alltrim(cCNPJDestino)                         + ;
               "&desNome=" + Alltrim(cNomeDestino)                         + ;
               "&totalNF=" + Alltrim(nTotalPedido)                         + ;
               "&pesoNF="  + Alltrim(nPesoTotal)                           + ;
               "&volNF="   + Alltrim(nVolumeTotal)                         + ;
               "&qtdNF="   + Alltrim(nQtdVenda)                            + ;
               "&tipooperacao=0"

   // #######################################################################################
   // Cria nome do arquivo de retorno                                                      ##
   // Variável do parametrizador Automatech deve estar gravada com - Exemplo  C:\SIMFRETE\ ##
   // O Comando abaixo acrescenta a esta camilho a estrutura:                              ##
   // C:\SIMFRETE\FilialNúmeroPedido.TXT                                                   ##
   //                                                                                      ##
   // C:\SIMFRETE\01095796.TXT                                                             ##
   //                                                                                      ##
   // #######################################################################################
   cRetorno := Alltrim(cCaminhoRetorno) + Alltrim(M->C5_FILIAL) + Alltrim(M->C5_NUM) + ".TXT"

   // #############################################
   // Fecha o arquivo de retorno para eliminação ##
   // #############################################
   FCLOSE(cRetorno)

   // ###################################################################
   // Elimina o Arquivo para receber nova cotação de frete do SimFrete ##
   // ###################################################################
   FERASE(cRetorno)

   // #############################################
   // Envia a solicitação de cotação ao SimFrete ##
   // #############################################
   WaitRun('AtechHttpget.exe' + ' "' + cComando + '" ' + cRetorno, SW_SHOWNORMAL )

   // Lê o retorno da consulta
   lExiste     := .F.
   nTentativas := 0

   while nTentativas < cSTIM

      If File(cRetorno)
         lExiste := .T.
         Exit
      Endif

      nTentativas := nTentativas + 1

   Enddo

   // #########################################################
   // Verifica se há arquivo de retorno de coptação de frete ##
   // #########################################################
   If lExiste == .F.

      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo de retorno de cotação de frete inexistente." + chr(13) + chr(10) + "Tente novamente.")

      // ###############################################################################################
      // Verifica se existe o arquivo de retorno no diretório. Se existir, tenta fechá-lo e excluí-lo ##
      // ###############################################################################################
      If File(cRetorno)

         // ##################
         // Fecha o arquivo ##
         // ##################
         FCLOSE(cRetorno)

         // #################
         // Fecha o Handle ##
         // #################
         FCLOSE(nHandle)

         // ########################################################
         // Elimina o Arquivo para receber nova coptação de frete ##
         // ########################################################
         FERASE(cRetorno)

      Endif

      Return(.T.)

   Endif

   // ####################################################
   // Abre o arquivo selecionado para pesquisa de dados ##
   // ####################################################
   nHandle := FOPEN(Alltrim(cRetorno), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0

      MsgAlert("Erro ao abrir o arquivo.")

      // ###############################################################################################
      // Verifica se existe o arquivo de retorno no diretório. Se existir, tenta fechá-lo e excluí-lo ##
      // ###############################################################################################
      If File(cRetorno)

         // ##################
         // Fecha o arquivo ##
         // ##################
         FCLOSE(cRetorno)

         // #################
         // Fecha o Handle ##
         // #################
         FCLOSE(nHandle)

         // ########################################################
         // Elimina o Arquivo para receber nova coptação de frete ##
         // ########################################################
         FERASE(cRetorno)

      Endif

      Return(.T.)

   Endif

   // ################################
   // Lê o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // Lê todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
   
   cString := xBuffer

   // ##################
   // Fecha o arquivo ##
   // ##################
   FCLOSE(nHandle)

   // ##################
   // Fecha o arquivo ##
   // ##################
   FCLOSE(cRetorno)

   // ########################################################
   // Elimina o Arquivo para receber nova coptação de frete ##
   // ########################################################
   FERASE(cRetorno)

   // ##################################################
   // Carrega os dados do retorno para o array aDados ##
   // ##################################################

   // #######################################
   // Separa os campos e os grava no array ##
   // #######################################
   aLista := {}

   If _FreteGratis == 0
      aAdd( aLista, { .F., "FRETE GRATUÍTO", "", "", "", "", "", "" } )
   Endif   

   For nContar = 1 to U_P_OCCURS(cString, CHR(10), 1)

       cConteudo := U_P_CORTA(cString, CHR(10), nContar)
       
       If Empty(Alltrim(cConteudo))
          Loop
       Endif   

       // ###############################################
       // Separa os campos para carrega o array aLista ##
       // ###############################################
       c_Origem   := U_P_CORTA(cConteudo, ",", 1)
       c_Destino  := U_P_CORTA(cConteudo, ",", 2)
       c_Posicao  := U_P_CORTA(cConteudo, ",", 3)
       c_ValFrete := U_P_CORTA(cConteudo, ",", 4)
       c_Prazo    := U_P_CORTA(cConteudo, ",", 5)
       c_Menor_Vl := IIF(U_P_CORTA(cConteudo, ",", 6) == "true", "Sim", "Não")
       c_Menor_Pz := IIF(U_P_CORTA(cConteudo, ",", 7) == "true", "Sim", "Não")
       c_CNPJ     := SUBSTR(U_P_CORTA(cConteudo, ",", 8),01,14)
       c_Nometran := SUBSTR(U_P_CORTA(cConteudo, ",", 8),16)
       
       // ######################################
       // Pesquisa a transportadora pelo cnpj ##
       // ######################################
       If Select("T_TRANSPORTADORA") > 0
          T_TRANSPORTADORA->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A4_COD ,"
       cSql += "       A4_NOME "
       cSql += "  FROM " + RetSqlName("SA4")

       If Substr(c_CNPJ,01,08) == "34028316"
          cSql += " WHERE SUBSTRING(A4_CGC,01,08) = '" + Substr(c_CNPJ,01,08) + "'"
       Else   
          cSql += " WHERE A4_CGC  = '" + Alltrim(c_CNPJ) + "'"
       Endif

       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTADORA", .T., .T. )

       If T_TRANSPORTADORA->( EOF() )
          Loop
       Endif   

       cCodTransp := IIF(T_TRANSPORTADORA->( EOF() ), "000000", T_TRANSPORTADORA->A4_COD )
//     cNomTransp := IIF(T_TRANSPORTADORA->( EOF() ), "      ", T_TRANSPORTADORA->A4_NOME)          
       cNomTransp := IIF(T_TRANSPORTADORA->( EOF() ), "      ", c_NomeTran)

       aAdd( aLista, { .F.         ,; // 01 - Marcação da Cotação
                       c_Posicao   ,; // 02 - Posição da Cotação
                       c_ValFrete  ,; // 03 - Valor do Frete
                       c_Prazo     ,; // 04 - Prazo dias
                       c_Menor_Vl  ,; // 05 - Menor Valor
                       c_Menor_Pz  ,; // 06 - Menor Prazo
                       cCodTransp  ,; // 07 - Código Transportadora
                       cNomTransp  }) // 08 - Nome da Transportadora

   Next nContar    

/*


   For nContar = 1 to U_P_OCCURS(cString, CHR(10), 1)
       If U_P_OCCURS(U_P_CORTA(cString, CHR(10), nContar), ",", 1) == 0
       Else

          If Substr(cString,01,47) == "NÃ£o hÃ¡ resultado disponÃ­vel para a cotaÃ§Ã£o"
             Exit
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
          cSql += "  FROM " + RetSqlName("SA4")
          cSql += " WHERE A4_CGC     = '" + Alltrim(Substr(U_P_CORTA(cString, ",", 8),01,14)) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"
   
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTADORA", .T., .T. )

          cCodTransp := IIF(T_TRANSPORTADORA->( EOF() ), "000000", T_TRANSPORTADORA->A4_COD )
          cNomTransp := IIF(T_TRANSPORTADORA->( EOF() ), "      ", T_TRANSPORTADORA->A4_NOME)          

          aAdd( aLista, { .F.                                                     ,; // 01 - Marcação da Cotação
                          U_P_CORTA(cString, ",", 3)                              ,; // 02 - Posição da Cotação
                          U_P_CORTA(cString, ",", 4)                              ,; // 03 - Valor do Frete
                          U_P_CORTA(cString, ",", 5)                              ,; // 04 - Prazo dias
                          IIF(U_P_CORTA(cString, ",", 6) == "true", "Sim", "Não") ,; // 05 - Menor Valor
                          IIF(U_P_CORTA(cString, ",", 7) == "true", "Sim", "Não") ,; // 06 - Menor Prazo
                          cCodTransp                                              ,; // 07 - Código Transportadora
                          cNomTransp                                              }) // 08 - Nome da Transportadora
       Endif

   Next nContar    

*/

   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "" } )
   Endif   
           
Return(.T.)