#INCLUDE "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M410VRES.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho (X) Ponto de Entrada                      ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 05/04/2012                                                          ##
// Objetivo..: Ponto de Entrada que verifica se o Pedido de Venda pode ser Exclu�- ##
//             do. Neste ponto de entrada ser� verificado se o pedido de  venda  � ##
//             um pedido de intermedia��o. Caso  for, verifica  os  pagamentos  da ##
//             comiss�o. Se j� houver pelo  menos  uma  comiss�o paga, n�o permite ##
//             realizar a exclus�o do pedido.                                      ##
// ################################################################################## 

User Function M410VRES()

   Local cSql    := ""
   Local lPago   := .F.
   Local nContar := 0

   U_AUTOM628("M410VRES")

   // ###################################################################
   // Verifica se o pedido a ser excluido � um pedido de intermedia��o ##
   // ###################################################################
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C5_FILIAL  , "
   cSql += "       C5_NUM     , "
   cSql += "       C5_PVEXTER , "
   cSql += "       C5_EXTERNO , "
   cSql += "       C5_NOTA      "
   cSql += "  FROM " + RetSqlName("SC5") 
   cSql += " WHERE C5_PVEXTER = '" + Alltrim(SC5->C5_NUM)    + "'"
   cSql += "   AND C5_FILIAL  = '" + Alltrim(SC5->C5_FILIAL) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   // ###############################################################
   // Se n�o encontrou, indica que o pedido n�o � de intermedia��o ##
   // ###############################################################
   If T_PEDIDO->( EOF() )
      Return .T.
   Endif   

   If T_PEDIDO->C5_EXTERNO <> "1"
      Return .T.
   Endif
   
   // ###################################################################################################
   // Verifica se existe pelo menos uma parcela quitada das comiss�es do pedido de intermedia��o.      ##
   // Caso existir pelo menos uma quitada, n�o permite realizar a exclus�o do pedido de intermedia��o. ##
   // ###################################################################################################
   If Select("T_COMISSAO") > 0
      T_COMISSAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E3_FILIAL,"
   cSql += "       E3_NUM   ,"
   cSql += "       E3_DATA   "
   cSql += "  FROM " + RetSqlName("SE3")
   cSql += " WHERE E3_FILIAL = '" + Alltrim(T_PEDIDO->C5_FILIAL) + "'"
   cSql += "   AND E3_PEDIDO = '" + Alltrim(T_PEDIDO->C5_NUM)    + "'"
         
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

   If T_COMISSAO->( EOF() )
      Return .T.
   Endif
         
   T_COMISSAO->( DbGoTop() )
   WHILE !T_COMISSAO->( EOF() )
      If !Empty(Alltrim(T_COMISSAO->E3_DATA))
         lPago := .T.
         Exit
      Endif
      T_COMISSAO->( DbSkip() )
   ENDDO
   
   If lPago 
//    MsgAlert("Pedido de Intermedia��o n�o poder� ser excluido pois o mesmo possui parcelas de comiss�es j� pagas. Verifique!")
//    Return .F.
   Endif
   
Return .T.