#INCLUDE "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M410VRES.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho (X) Ponto de Entrada                      ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 05/04/2012                                                          ##
// Objetivo..: Ponto de Entrada que verifica se o Pedido de Venda pode ser Excluí- ##
//             do. Neste ponto de entrada será verificado se o pedido de  venda  é ##
//             um pedido de intermediação. Caso  for, verifica  os  pagamentos  da ##
//             comissão. Se já houver pelo  menos  uma  comissão paga, não permite ##
//             realizar a exclusão do pedido.                                      ##
// ################################################################################## 

User Function M410VRES()

   Local cSql    := ""
   Local lPago   := .F.
   Local nContar := 0

   U_AUTOM628("M410VRES")

   // ###################################################################
   // Verifica se o pedido a ser excluido é um pedido de intermediação ##
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
   // Se não encontrou, indica que o pedido não é de intermediação ##
   // ###############################################################
   If T_PEDIDO->( EOF() )
      Return .T.
   Endif   

   If T_PEDIDO->C5_EXTERNO <> "1"
      Return .T.
   Endif
   
   // ###################################################################################################
   // Verifica se existe pelo menos uma parcela quitada das comissões do pedido de intermediação.      ##
   // Caso existir pelo menos uma quitada, não permite realizar a exclusão do pedido de intermediação. ##
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
//    MsgAlert("Pedido de Intermediação não poderá ser excluido pois o mesmo possui parcelas de comissões já pagas. Verifique!")
//    Return .F.
   Endif
   
Return .T.