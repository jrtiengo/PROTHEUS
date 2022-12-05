#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MS520VLD.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/08/2012                                                          *
// Objetivo..: Ponto  de  Entrada  que  verifica  se a nota fiscal que  está sendo *
//             excluída pertence a um  pedido de intermediação. Se  for,  verifica *
//             se já existe alguma parcela paga.Caso já tenha,não permite realizar *
//             a exclusão da nota fiscal. Caso permita,  na  sequencia  elimina os *
//             lançamentos de comissões da tabela SE3.                             *
//**********************************************************************************

User Function MS520VLD()

   U_AUTOM628("MS520VLD")

   // #######################################################################
   // Envia para a função que verifica se a nota fiscal é de intermediação ##
   // #######################################################################
   ElmPrcNfInt()

   // ###############################################################################################
   // Envia para a função que verifica se a nota fiscal a ser excluída possui teckt a ser fechado. ##
   // ###############################################################################################
   ElmTcktDemo()

Return(.T.)

// ###########################################################
// Função que trata nota fiscal de pedidos de intermediação ##
// ###########################################################
Static Function ElmPrcNfInt()

   Local cSql    := ""
   Local lPago   := .F.
   Local nContar := 0

   // ######################################################
   // Se série do documento for diferente de P1, P2 ou P3 ##
   // ######################################################
   If Alltrim(SF2->F2_SERIE) <> 'P1' .And. Alltrim(SF2->F2_SERIE) <> 'P2' .And. Alltrim(SF2->F2_SERIE) <> 'P3'
      Return .T.
   Endif

   // ##################################################################
   // Verifica se existe pelo menos uma parcela de comissões quitada. ##
   // Caso exista, não permite realizar a exclusão da nota fiscal.    ##
   // ##################################################################
   If Select("T_COMISSAO") > 0
      T_COMISSAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E3_FILIAL ,"
   cSql += "       E3_NUM    ,"
   cSql += "       E3_DATA   ,"
   cSql += "       E3_PREFIXO,"
   cSql += "       E3_PARCELA,"
   cSql += "       E3_SEQ    ,"
   cSql += "       E3_VEND    "
   cSql += "  FROM " + RetSqlName("SE3")
   cSql += " WHERE E3_FILIAL  = '" + Alltrim(SF2->F2_FILIAL) + "'"
   cSql += "   AND E3_NUM     = '" + Alltrim(SF2->F2_DOC)    + "'"
   cSql += "   AND E3_PREFIXO = '" + Alltrim(SF2->F2_SERIE)  + "'" 
   cSql += "   AND D_E_L_E_T_ = ''"
         
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
      MsgAlert("Nota Fiscal (Intermediação) não poderá ser excluida pois existem parcelas de comissões já pagas. Verifique!")
      Return .F.
   Endif

   // #####################################################################
   // Exclui os registros das comissões da Nota Fiscal de Intermediação. ##
   // #####################################################################
   T_COMISSAO->( DbGoTop() )
   WHILE !T_COMISSAO->( EOF() )
      DbSelectArea("SE3")
      DbSetOrder(1)
      If DbSeek(xfilial("SE3") + T_COMISSAO->E3_PREFIXO + T_COMISSAO->E3_NUM + T_COMISSAO->E3_PARCELA + T_COMISSAO->E3_SEQ + T_COMISSAO->E3_VEND)   
         RecLock("SE3",.F.)
         DbDelete()        
         MsUnLock()              
      Endif
      T_COMISSAO->( DbSkip() )
   ENDDO      

Return .T.

// #############################################################################
// Função que realiza o fechamento de nota fidscal que possui tickt associado ##
// #############################################################################
Static Function ElmTcktDemo()

   Local cSql := ""

   // #########################################
   // Pesquisa se a nf possui um nº de tickt ##
   // #########################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql := "SELECT SF2.F2_ZTICK,"
   cSql += "      (SELECT TOP(1) D2_PEDIDO"
   cSql += "	     FROM " + RetSqlName("SD2")
   cSql += "		WHERE D2_FILIAL  = SF2.F2_FILIAL "
   cSql += "		  AND D2_DOC     = SF2.F2_DOC    "
   cSql += "		  AND D2_SERIE   = SF2.F2_SERIE  "
   cSql += "		  AND D2_CLIENTE = SF2.F2_CLIENTE"
   cSql += "		  AND D2_LOJA    = SF2.F2_LOJA   "
   cSql += "		  AND D_E_L_E_T_ = '') AS PEDIDO "
   cSql += "  FROM " + RetSqlName("SF2") + " SF2 "
   cSql += " WHERE SF2.F2_FILIAL  = '" + Alltrim(SF2->F2_FILIAL)  + "'" 
   cSql += "   AND SF2.F2_DOC     = '" + Alltrim(SF2->F2_DOC)     + "'" 
   cSql += "   AND SF2.F2_SERIE   = '" + Alltrim(SF2->F2_SERIE)   + "'" 
   cSql += "   AND SF2.F2_CLIENTE = '" + Alltrim(SF2->F2_CLIENTE) + "'" 
   cSql += "   AND SF2.F2_LOJA    = '" + Alltrim(SF2->F2_LOJA)    + "'"
   cSql += "   AND SF2.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   If T_CONSULTA->( EOF() )
      Return(.T.)
   Else
   
      If Empty(Alltrim(T_CONSULTA->F2_ZTICK))
         Return(.T.)
      Else
         U_AUTOM595( "E", T_CONSULTA->PEDIDO, SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, T_CONSULTA->F2_ZTICK)   
      Endif
   Endif      

Return(.T.)