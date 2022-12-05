#INCLUDE "PROTHEUS.CH"

/* Jean Rehermann - 04-02-2012 - Ponto de entrada na exclusão da nota fiscal de saída */
// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: M521CART.PRW                                                                                     ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Jean Rehermann e Harald Hans Löschenkohl                                                         ##
// Data......: 04/02/2012                                                                                       ##
// Objetivo..: Ponto de entrada na exclusão da nota fiscal de saída                                             ##
// Parâmetros: Sem Parâmetros                                                                                   ##
// Alterações: 29/03/2017 - Quando da exclu~so ade uma nota fiscal, programa deverá verificar se existe regis-  ##
//                          tro referente ao item da nota fiscal na tabela ZSA. Se existir, elimina o registro  ##
//                          desta tabela. (Tabela ZSA -> Variáveis de Cálculo da Margem dos produtos)           ##
// ###############################################################################################################

User Function M521CART

   Local _lRet     := .T.
   Local _lServ    := .F.
   Local _aAreaSD2 := SD2->( GetArea() )
   Local cSql      := ""

   U_AUTOM628("PE_M521CART")

   dbSelectArea("SC6")
   dbSetOrder(1)
   If dbSeek( SD2->D2_FILIAL + SD2->D2_PEDIDO + SD2->D2_ITEMPV )
	
	  //_lServ := U_Servico()
	  RecLock("SC6",.F.)
	  //SC6->C6_STATUS := Iif( _lServ, "10", "01" )
	  SC6->C6_STATUS := "01"
	  MsUnLock()
	  
	  //U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, Iif( _lServ, "10", "01" ), "PE_M521CART") // Gravo o log de atualização de status na tabela ZZ0
	  U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "01", "PE_M521CART") // Gravo o log de atualização de status na tabela ZZ0
	
      // ###################################################################
      // Envia e-mail ao vendedor informando-o da exclusão da Nota Fiscal ##
      // ###################################################################
      If Select("T_CABECALHO") > 0
         T_CABECALHO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.C5_VEND1,"
      cSql += "       A.C5_CNOT ,"
      cSql += "       B.A3_NOME ,"
      cSql += "       B.A3_EMAIL,"
      cSql += "       C.A1_NOME  "
      cSql += "  FROM " + RetSqlName("SC5") + " A, "
      cSql += "       " + RetSqlName("SA3") + " B, "
      cSql += "       " + RetSqlName("SA1") + " C  "
      cSql += " WHERE A.C5_FILIAL  = '" + Alltrim(SD2->D2_FILIAL) + "'"
      cSql += "   AND A.C5_NUM     = '" + Alltrim(SD2->D2_PEDIDO) + "'"
      cSql += "   AND A.C5_CNOT    = 'S'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
      cSql += "   AND A.C5_VEND1   = B.A3_COD"
      cSql += "   AND B.D_E_L_E_T_ = ''"            
      cSql += "   AND A.C5_CLIENTE = C.A1_COD"
      cSql += "   AND A.C5_LOJACLI = C.A1_LOJA"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CABECALHO", .T., .T. )

      If !T_CABECALHO->( EOF() )
        
         If !Empty(Alltrim(T_CABECALHO->A3_EMAIL))
           
            cEmail := ""
            cEmail := "Prezado(a) " + Alltrim(T_CABECALHO->A3_NOME) + Chr(13) + chr(10) + chr(13) + chr(10)
            cEmail += "Viemos lhe informar que a Nota Fiscal nº "   + Alltrim(SC6->C6_NOTA) + " do Cliente " + Alltrim(T_CABECALHO->A1_NOME) + chr(13) + chr(10)
            cEmail += "foi Cancelada nesta data."                   + Chr(13) + chr(10) + Chr(13) + chr(10)
            cEmail += "Att."                                        + Chr(13) + chr(10) + Chr(13) + chr(10)
            cEmail += "Automatech Sistema de Automação Ltda"        + Chr(13) + chr(10)
            cEmail += "Departamento de Faturamento"                 + Chr(13) + chr(10)

            // #################
            // Envia o e-mail ##
            // #################
            U_AUTOMR20(cEmail, Alltrim(T_CABECALHO->A3_EMAIL), "", "Aviso de Cancelamento de Nota Fiscal" )
            
            // ######################################################################################
            // Atualiza o cabeçalho do pedido de venda indicando que o e-mail de aviso foi enviado ##
            // ######################################################################################
            dbSelectArea("SC5")
            dbSetOrder(1)
            If dbSeek( SD2->D2_FILIAL + SD2->D2_PEDIDO)
	           RecLock("SC5",.F.)
		       SC5->C5_CNOT := "S"
	           MsUnLock()
		    Endif

		 Endif

	  Endif

   EndIf
	
   // #######################################################################
   // Elimina da tabela ZSA o resgistro referente aos itens da nota fiscal ##
   // #######################################################################
   cSql := ""
   cSql := "DELETE FROM " + RetSqlName("ZSA")
   cSql += " WHERE ZSA_EMPR   = '" + Alltrim(cEmpAnt)         + "'"
   cSql += "   AND ZSA_FILIAL = '" + Alltrim(SD2->D2_FILIAL)  + "'"
   cSql += "   AND ZSA_NOTA   = '" + Alltrim(SD2->D2_DOC)     + "'"
   cSql += "   AND ZSA_SERI   = '" + Alltrim(SD2->D2_SERIE)   + "'"
   cSql += "   AND ZSA_CLIE   = '" + Alltrim(SD2->D2_CLIENTE) + "'"
   cSql += "   AND ZSA_LOJA   = '" + Alltrim(SD2->D2_LOJA)    + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
   Endif

   RestArea( _aAreaSD2 )

Return _lRet