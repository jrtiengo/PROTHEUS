#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: MT680VAL.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 15/02/2018                                                                ##
// Objetivo..: Ponto de Entrada disparado no processo de Apontamento de Produção Mod 2.  ##
// Parâmetros: Sem parâmetros                                                            ##
// ########################################################################################

User Function MT680VAL()

   Local cSql        := ""
   Local nOriginal   := 0
   Local nQuantidade := 0                                                
   Local nProducao   := ""
   Local nItem       := ""
   Local nSequencia  := ""
                        
   If Empty(Alltrim(M->H6_OP))
      Return(.T.)
   Endif
      
   nProducao  := Substr(M->H6_OP,01,06)
   nItem      := Substr(M->H6_OP,07,02)
   nSequencia := Substr(M->H6_OP,09,03)

   // #########################################################################################################
   // Pesquisa a ordem de produção informada/selecionada para capturar a quantidade para troca se necessário ##
   // #########################################################################################################
   DbSelectArea("SC2")

   If DBSEEK(xFilial("SC2") + nProducao + nItem + nSequencia)

      If SC2->C2_ZQTD == 0
      Else
                      
         // ################################################
         // Calcula o H6_QTDPROD quando a operação for 04 ##
         // ################################################
         If M->H6_OPERAC == "04"

            M->H6_QTDPROD := ROUND((SC2->C2_ZQTD * ROUND(((M->H6_QTDPROD * 100) / SC2->C2_QUANT),2)) / 100,2)

            // ########################################################
            // Verifica se o total dos apontamentos foram encerrados ##
            // ########################################################
            If Select("T_SALDO") > 0
               T_SALDO->( dbCloseArea() )
            EndIf
                      
            cSql := ""
            cSql := "SELECT H6_FILIAL ,"
            cSql += "       H6_OP     ,"
	        cSql += "       H6_PRODUTO,"
	        cSql += "       H6_OPERAC ,"
	        cSql += "       SUM(H6_QTDPROD) AS OPERACAO_01"
            cSql += "  FROM " + RetSqlName("SH6")
            cSql += " WHERE H6_FILIAL  = '" + Alltrim(cFilAnt)         + "'"
            cSql += "   AND H6_OP      = '" + Alltrim(M->H6_OP)        + "'"
            cSql += "   AND H6_PRODUTO = '" + Alltrim(SC2->C2_PRODUTO) + "'"
            cSql += "   AND H6_OPERAC  = '01'"
            cSql += "   AND D_E_L_E_T_ = ''"
            cSql += " GROUP BY H6_FILIAL, H6_OP, H6_PRODUTO, H6_OPERAC "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDO", .T., .T. )
                                                                 
            If T_SALDO->OPERACAO_01 >= SC2->C2_QUANT

               nQuan := SC2->C2_QUANT
               nZqtd := SC2->C2_ZQTD
 
               RecLock("SC2",.F.)
               SC2->C2_QUANT:= nZqtd
               SC2->C2_ZQTD := nQuan
               SC2->C2_QUJE := nZqtd 
               MsUnLock()             

            Endif   
               
         Endif
         
      Endif
         
   Endif
   
Return(.T.)




//         If M->H6_OPERAC == "03" .OR. M->H6_OPERAC == "04"
//            nQuan := SC2->C2_ZQTD
//            nZqtd := SC2->C2_QUANT
//         Else   
//            nQuan := SC2->C2_QUANT
//            nZqtd := SC2->C2_ZQTD
//                                  
//            If M->H6_OPERAC == "02"
//               M->H6_QTDPROD:= nZqtd 
//            Endif
//               
//         Endif   
// 
//         If M->H6_OPERAC == "03"
//            RecLock("SC2",.F.)
//            SC2->C2_QUANT:= nZqtd
//            SC2->C2_ZQTD := nQuan
//            SC2->C2_QUJE := nZqtd 
//            MsUnLock()             
//         Endif   
//
//      Endif   
//
//   Endif                     
