#INCLUDE "rwmake.ch"
#INCLUDE "jpeg.ch"    
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM597.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 08/08/2017                                                          ##
// Objetivo..: Realiza o recálculo físico do produto passado no parâmetro          ##
// Parâmetros: Pedido, Filial, Código do Produto, Item PV                          ##
// ##################################################################################

User Function AUTOM597(kPedido, kFilial, kProduto, kItemPv)

   Local cSql := ""

   U_AUTOM628("AUTOM597")

   // #####################################################
   // Recálculo campo B2_RESERVA (Quantidade da reserva) ##
   // #####################################################
   If Select("T_RESERVA") > 0
      T_RESERVA->( dbCloseArea() )
   EndIf
 
   cSql := ""
   cSql := "SELECT SUM(SC6.C6_QTDVEN) AS RESERVA"  
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SF4") + " SF4  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(kFilial)  + "'"
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(kPedido)  + "'"
   cSql += "   AND SC6.C6_PRODUTO = '" + Alltrim(kProduto) + "'"
   cSql += "   AND SC6.C6_ITEM    = '" + Alltrim(kItemPV)  + "'"
   cSql += "   AND SC6.C6_STATUS  = '08'"
// cSql += "   AND SC6.C6_ENTREG  = CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
   cSql += "   AND SC6.C6_NOTA    = ''"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SF4.F4_FILIAL  = ''"
   cSql += "   AND SC6.C6_TES     = SF4.F4_CODIGO"
   cSql += "   AND SF4.F4_ESTOQUE = 'S'"
   cSql += "   AND SF4.D_E_L_E_T_ = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESERVA", .T., .T. )

   If T_RESERVA->( EOF() )
   Else
      dbSelectArea("SB2")
      dbSetOrder(1)
      If DbSeek(kFilial + Alltrim(kProduto) + Space(30 - Len(Alltrim(kProduto))) + "01")
         Reclock("SB2",.F.)
         SB2->B2_RESERVA := SB2->B2_RESERVA - T_RESERVA->RESERVA
  	     MsUnlock()          
  	  Endif
  Endif

Return(.T.)

/*
update sb2010 set                  
       b2_naoclas = nvl((select sum(d1_quant) 
                           from sd1010 
                          where d1_filial=b2_filial 
                            and d1_cod=b2_cod 
                            and d1_tes=' ' 
                            and sd1010.d_e_l_e_t_=' ' 
                         ),0),

       b2_qpedven = nvl((Select sum(c6_qtdven) 
                           from sc6010, sf4010 
                          where c6_filial=b2_filial 
                            and c6_produto=b2_cod 
                            and c6_tes=f4_codigo
                            and f4_filial= ' '
                            and f4_estoque='S'
                            and sf4010.d_e_l_e_t_=' '
                            and sc6010.d_e_l_e_t_=' '
                            and c6_nota=' '
                        ),0),
                        
       b2_salpedi = nvl((select sum(c7_quant-c7_quje)
                          from sc7010
                         where c7_filial=b2_filial
                           and c7_produto=b2_cod
                           and c7_encer != 'E'
                           and c7_residuo != 'S'
                           and sc7010.d_e_l_e_t_=' '),0)
                           
   where b2_filial='00' and b2_local='01' and d_e_l_e_t_=' ';

*/