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

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM564.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 03/05/2017                                                          ##
// Objetivo..: Programa que realiza consulta utilizando o SIMFRETE                 ##
// ##################################################################################

User Function AUTOM564()

   Local lChumba      := .F.
   Local cSql         := ""
   Local cMemo1	      := ""
   Local oMemo1
   Local _FreteGratis := 0
   Local nRet         := MakeDir( "C:\SIMFRETE" )   

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

   U_AUTOM628("AUTOM564")

   // ###############################################
   // Verifica se conseguiu criar a pasta SIMFRETE ##
   // ###############################################
   If FILE("C:\SIMFRETE")
   Else
      If nRet != 0
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não foi possível criar o diretório C:\SIMFRETE." + CHR(13) + CHR(10) + "Crie o diretório para realizar a pesquisa.")
         Return(.T.)
      Endif
   Endif   

   // ################################################
   // Verifica o tipo de frete para aplicar a regra ##
   // ################################################
   If M->C5_TPFRETE == "C"
   Else
      MsgAlert("Pesquisa permitida somente para tipo C - CIF")
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

// If T_VENDEDOR->A3_TIPOV == '1'
//    Return(.T.)
// Endif

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
                   cOrigem := "PORTO ALEGRE / RS"
           EndCase
      Case cEmpAnt == "02"
           cOrigem := "CURITIBA / PR"
      Case cEmpAnt == "03"
           cOrigem := "PORTO ALEGRE / RS"
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
      xkBuscaSimFrete(_FreteGratis)
             
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

         @ C(196),C(339) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

         // Lista com os produtos do pedido selecionado
         @ 155,005 LISTBOX oLista FIELDS HEADER "Posição", "Valor Frete", "Prazo Dias", "Menor Valor", "Menor Prazo", "Código", "Transportadora" PIXEL SIZE 474,090 OF oDlg ;
                   ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

         oLista:SetArray( aLista )

         oLista:bLine := {||     {aLista[oLista:nAt,01],;
          					      aLista[oLista:nAt,02],;
          					      aLista[oLista:nAt,03],;
          					      aLista[oLista:nAt,04],;
          					      aLista[oLista:nAt,05],;
          					      aLista[oLista:nAt,06],;          					    
          					      aLista[oLista:nAt,07]}}

         oDlg:lEscClose := .F.

         ACTIVATE MSDIALOG oDlg CENTERED 
         
      Endif   
      
   Endif   

Return(.T.)

// #########################################################
// Função que consome web service de consulta do SimFrete ##
// #########################################################
Static Function xkBuscaSimFrete(_FreteGratis)

   MsgRun("Aguarde! Pesquisando Cotação de Frete ...", "Cotação de Frete",{|| hkBuscaSimFrete(_FreteGratis) })

Return(.T.)

// #########################################################
// Função que consome web service de consulta do SimFrete ##
// #########################################################
Static Function hkBuscaSimFrete(_FreteGratis)

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
   Local cSTIM            := 15000000
   Local nRet
   Local xPosItem  := aScan( aHeader, { |x| x[2] == 'C6_ITEM   ' } )
   Local xPosProd  := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
   Local xPosValor := aScan( aHeader, { |x| x[2] == 'C6_VALOR  ' } )
   Local xPosQuant := aScan( aHeader, { |x| x[2] == 'C6_QTDVEN ' } )

   Local aEmbalagem   := {}
   Local nQtdCaixas   := 0
   Local nQtdIndiv    := 0
   Local nQtdVolumes  := 0
   Local nVolumeIndiv := 0
   Local nTentativas  := 0
   
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
              Case cFilAnt == "07"
                   cCidadeOrigem  := "PORTO ALEGRE/RS"
                   cCEPOrigem     := Alltrim(SM0->M0_CEPENT)        
           EndCase
           cNomeOrigem := "AUTOMATECH SISTEMAS DE AUTOMACAO LTDA"
      Case cEmpAnt == "02"
           cCidadeOrigem := "CURITIBA/PR"   
           cCEPOrigem    := Alltrim(SM0->M0_CEPENT)           
           cNomeOrigem   := "TI AUTOMACAO E SERVICOS LTDA"
      Case cEmpAnt == "03"
           cCidadeOrigem := "PORTO ALEGRE/RS"
           cCEPOrigem    := Alltrim(SM0->M0_CEPENT)
    	   cNomeOrigem   := "ATECH SERVICOS DE AUTOMACAO LTDA"
      Case cEmpAnt == "04"
           cCidadeOrigem := "PELOTAS/RS"
           cCEPOrigem    := Alltrim(SM0->M0_CEPENT)
    	   cNomeOrigem   := "ATECHPEL AUTOMACAO E SERVICOS LTDA"
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

   cSURL   := 'http://sm.automatech.com.br/api/frete/consulta/v1'
    
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
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // Lê todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   FCLOSE(nHandle)

   If U_P_OCCURS(xBuffer, "(422)", 1) <> 0
      // Dar Mensagem de erro
      // Ver com Roger o que deve ser feito neste caso
   Endif
         
   // ##########################
   // Alimenta o array aLista ##
   // ##########################
   aLista := {}

   If _FreteGratis == 0
      aAdd( aLista, { .F., "FRETE GRATUÍTO", "", "", "", "", "", "" } )
   Endif   

   For nContar = 1 to U_P_OCCURS(xBuffer, "}", 1)

       cSepara := U_P_CORTA(xBuffer, "}", nContar)                                                        
       
       If nContar == 1
          cSepara := StrTran(cSepara, ",", "|") + "|"
          kValor := U_P_CORTA(U_P_CORTA(cSepara, "|", 1) + ":", ":", 4)          
          kPrazo := U_P_CORTA(U_P_CORTA(cSepara, "|", 2) + ":", ":", 2)          
          kBarato := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 3) + ":", ":", 2) == "true", "SIM", "NÃO")
          kRapido := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 4) + ":", ":", 2) == "true", "SIM", "NÃO")  
          kNomeT  := StrTran(U_P_CORTA(U_P_CORTA(CsEPARA, "|", 5) + ":", ":", 2), '"', "")        
          kCNPJ   := StrTran(U_P_CORTA(U_P_CORTA(cSepara, "|", 6) + ":", ":", 2), '"', "")                                                                                              
       Else
          cSepara := StrTran(cSepara, ",", "|")
          kValor  := U_P_CORTA(U_P_CORTA(cSepara, "|", 2) + ":", ":", 3)   
          kPrazo  := U_P_CORTA(U_P_CORTA(cSepara,"|", 3) + ":", ":",2)    
          kBarato := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 4) + ":", ":", 2) == "true", "SIM", "NÃO")   
          kRapido := IIF(U_P_CORTA(U_P_CORTA(cSepara, "|", 5) + ":", ":", 2) == "true", "SIM", "NÃO")          
          kNomeT  := StrTran(U_P_CORTA(U_P_CORTA(CsEPARA, "|", 6) + ":", ":", 2), '"', "")  
          kCNPJ   := StrTran(U_P_CORTA(U_P_CORTA(cSepara, "|", 7) + ":", ":", 2), '"', "")                                                                                                                        
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
       cSql += "  FROM " + RetSqlName("SA4")
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
       aAdd( aLista, { Alltrim(Str(nContar)),; // 01 - Posição da Cotação
                       Val(kValor)          ,; // 02 - Valor do Frete
                       kPrazo               ,; // 03 - Prazo dias
                       kBarato              ,; // 04 - Menor Valor
                       kRapido              ,; // 05 - Menor Prazo
                       cCodTransp           ,; // 06 - Código Transportadora
                       cNomTransp           }) // 07 - Nome da Transportadora

   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { "", "", "", "", "", "", "" } )
   Endif   

Return(.T.)