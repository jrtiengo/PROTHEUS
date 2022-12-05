#include "rwmake.ch"
#include "topconn.ch" 

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: PE_MATA650.PRW                                                          ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Cesar Mussi                                                             ##
// Data......: 11/07/2011                                                              ##
// Objetivo..: Criação da OP - Traz campos do SC5                                      ##
// Parâmetros: Sem Parâmetros                                                          ##
// ######################################################################################

User Function MTA650I()

   Local cSql := ""

   Ant_Area  := GetArea()

   IF !empty(SC2->C2_PEDIDO)

      dbSelectArea("SC5")
      dbSetOrder(1)
      dbSeek(xFilial('SC5') + SC2->C2_PEDIDO )
 
      If Found()
         _cObs := SC5->C5_OBSI
         DbSelectArea("SC2")
         RecLock("SC2",.f.)
         SC2->C2_OBSI  := _cObs
         MsUnlock()
         
         // ########################################
         // Posiciona os itens da pedido de venda ##
         // ########################################
//         SC6->(dbSetOrder(2))
//         SC6->(DbSeek(Xfilial("SC6") + SC5->C5_NUM + SC2->C2_PRODUTO))


// Trexo eliminado em razão do PCP e Reservas.
/*
         // #########################
         // Atualiza o saldo da C2 ##
         // ######################### 
         If Select("T_SALDOC2") > 0 
            T_SALDOC2->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT SUM(B2_QATU) AS SOMA"
         cSql += "  FROM " + RetSqlName("SB2") 
         cSql += " WHERE D_E_L_E_T_ = ''"
         cSql += "   AND B2_COD     = '" + Alltrim(SC6->C6_PRODUTO) + "'"
   
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDOC2", .T., .T. )

         If T_SALDOC2->( EOF() )
            cSaldo := 0
         Else   
            cSaldo := T_SALDOC2->soma
         Endif   
          
         DbSelectArea("SC2")
         RecLock("SC2",.f.)
         SC2->C2_QUANT :=  SC2->C2_QUANT - cSaldo
         MsUnlock()

*/


      Endif

   Endif
 
Return(.T.)