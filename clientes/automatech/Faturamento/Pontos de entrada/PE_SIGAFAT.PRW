#include "PROTHEUS.CH"
#include "Inkey.ch"
 
// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: SIGAFAT.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 26/09/2017                                                          ##
// Objetivo..: Ponto de Entrada SIGAFAT - 05 - Módulo de Faturamento               ##
// Jean Rehermann | JPC - SIGAFAT.PRW - Executa a ação logo na entrada do módulo   ##
// Verifica os itens de PV com data de entrega vencidas (hoje ou menor) e atualiza ##
// o status.                                                                       ##  
// ##################################################################################

User Function SIGAFAT()

   Local  _cQuery := ""
   Local  _aArea  := GetArea()

   Public _Intermediacao
   Public _VeMensagem
   Public _Rodar
   Public _News
   Public _lPrecos
   Public _lEstoque
   Public _Ativi
   Public _Validacao
   Public _RunRate
   Public _RunTerca
   Public _CadEmpresa
   Public _TaxaDolar

   Default _Intermediacao := .F.
   Default _VeMensagem    := .F.
   Default _Rodar         := .F.
   Default _News          := .F.
   Default _lPrecos       := .F.
   Default _lEstoque      := .F.
   Default _Ativi         := .F.
   Default _Validacao     := .F.
   Default _RunRate       := .F.   
   Default _RunTerca      := .F.      
   Default _CadEmpresa    := .F.         
   Default _TaxaDolar     := .F.            

   SetKey(K_CTRL_S, { || U_AUTOM674() })

   // ######################################################################################################
   // Envia para o programa que carrega a taxa do dolar automaticamente pelo web service do banco Central ##
   // ######################################################################################################
   If _TaxaDolar
   ElSe
      If Alltrim(Upper(cUserName)) == "FATURAMENTO"
         U_AUTOM645()   
      Endif   
   Endif   

   // #########################################################
   // Bloqueia produtos que deixaram de ser de intermediação ##
   // #########################################################
   If !_Intermediacao
      U_AUTOM689()
   Endif

   // ###########################
   // Rotina do Jena - Solutio ##
   // ###########################
   If Select("T_PEDIDOS") > 0
   	  T_PEDIDOS->( dbCloseArea() )
   EndIf

   _cQuery := ""
   _cQuery := "SELECT C6_FILIAL, "
   _cQuery += "       C6_NUM   , "
   _cQuery += "       C6_ITEM    "
   _cQuery += "  FROM " + RetSqlName("SC6") 
   _cQuery += " WHERE C6_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
   _cQuery += "   AND C6_STATUS  = '05'"
   _cQuery += "   AND C6_ENTREG <= '" + DtoS( dDataBase ) + "'"
   _cQuery += "   AND D_E_L_E_T_ = ''"

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_PEDIDOS",.T.,.T.)

   While !T_PEDIDOS->( Eof() )
	
      dbSelectArea("SC6")
	  dbSetOrder(1)
	  dbSeek( T_PEDIDOS->C6_FILIAL + T_PEDIDOS->C6_NUM + T_PEDIDOS->C6_ITEM )

	  U_GravaSts("PE_SIGAFAT")
		
	  T_PEDIDOS->( dbSkip() )
	
   Enddo
	
   T_PEDIDOS->( dbCloseArea() )
   RestArea( _aArea )

   // ############################################################################################################
   // Verifica se existem clientes com indicação de emissão de boleto em branco. Se tiver, atualiza com S - Sim ##
   // ############################################################################################################
   If Select("T_BOLETOS") > 0
   	  T_BOLETOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, "
   cSql += "       A1_BOLET "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_BOLET   = ''" 
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BOLETOS", .T., .T. )

   T_BOLETOS->( DbGoTop() )
   
   WHILE !T_BOLETOS->( EOF() )

      dbSelectArea("SA1")
      dbSetOrder(1)
	  If DbSeek(xFilial("SA1") + T_BOLETOS->A1_COD + T_BOLETOS->A1_LOJA)
         RecLock("SA1", .F.)
  	     SA1->A1_BOLET := "S"
         MsUnlock()
      Endif
      
      T_BOLETOS->( DbSkip() )
      
   ENDDO      

   // ##########################################################################################
   // Envia para o programa que verifica se existem novas notícias a serem lidas pelo usuário ##
   // ##########################################################################################
   If _VeMensagem
   Else
      U_AUTOM338()
   Endif   
	
   // ##########################################################################################################################
   // Envia para o programa que verifica se o usuário logado é vendedor.                                                      ##
   // Se for vendedor, verifica se existe algum pedido de demonstração que ainda não teve devolução e que já esteja em atraso ##
   // pela verificação da data prevista de devolução informada na proposta comercial e pedido de venda.                       ##
   // ##########################################################################################################################
   If _Rodar
   ElSe
      U_AUTOM136(0)
   Endif   

   // ####################################################################################
   // Envia para o programa que verifica se existem atividades pendentes para o usuário ##
   // ####################################################################################
   If _Ativi
   Else
      U_ATVATI15()
   Endif   
   
   // ###############################################################################################
   // Envia para o programa que verifica se existe mensagens do Automatech News a ser visualizadas ##
   // ###############################################################################################
   If _News
   ElSe
      U_AUTOM171()   
   Endif   
   
   // #######################################################################################################################################
   // Envia para o programa que verifica se existem produtos em lista de preço que estão em liquidação porém não existe saldo na companhia ##
   // #######################################################################################################################################
   If _Lprecos
   ElSe
      U_AUTOM195()   
   Endif   

   // ########################################################################################################################################
   // Envia para o programa que verifica se existem produtos em lista de preço que estão com Tipo Registro = "E" e sem estoque na Companhia ##
   // ########################################################################################################################################
   If _lEstoque
   ElSe
      U_AUTOM196()
   Endif   

   // #####################################################
   // Verifica a existência de tarefas a serem validadas ##
   // #####################################################
   If _Validacao
   ElSe
      U_ESPVAL02()
   Endif   

   // ########################################################################################################################################
   // Envia para o programa que verifica se existem produtos Diferente de R (RunRate) e que a última entrada esteja entre o range informado ##
   // ########################################################################################################################################
   If _RunRate
   ElSe
      U_AUTOM593(0)   
   Endif   

   // #########################################################################################
   // Envia para o programa que verifica se existem notas fiscais ainda não enviadas a TERCA ##
   // #########################################################################################
   If _RunTerca
   ElSe
      If cEmpAnt == "01" .And. cFilAnt == "06"
         U_AUTOM622(0)   
      Else
         _RunTerca := .T.
      Endif   
   Endif   

   // ##############################################################################################
   // Envia para o programa que carrega a tabela ZPK - Cadastro de Empresas SIMFRETE Sale Machine ##
   // ##############################################################################################
   If _CadEmpresa
   ElSe
      U_AUTOM644()   
   Endif   

Return( .F. )