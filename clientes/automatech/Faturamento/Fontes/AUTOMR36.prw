#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR36.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/11/2011                                                          *
// Objetivo..: Processo que retorna o código do Pedido de Venda                    *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR36()

   Local cSql    := ""
   Local cPedido := ""
   Local aArea   := GetArea()

   U_AUTOM628("AUTOMR36")

// _Oportunidade, _Filial)

   DbSelectArea("AD1")   

   If Select("T_RETPEDIDO") > 0
   	  T_RETPEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.CJ_NUM   , "
   cSql += "       A.CJ_FILIAL, "
   cSql += "       B.C6_NUM     "
   cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
   cSql += "       " + RetSqlName("SC6010") + " B  "
// cSql += " WHERE A.CJ_NROPOR    = '" + Alltrim(_Oportunidade) + "'"
// cSql += "   AND A.CJ_FILIAL    = '" + Alltrim(_Filial)       + "'"
   cSql += " WHERE A.CJ_NROPOR    = '" + Alltrim(AD1_NROPOR)    + "'"
   cSql += "   AND A.CJ_FILIAL    = '" + Alltrim(AD1_FILIAL)    + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND B.C6_NUMORC = A.CJ_NUM + A.CJ_FILIAL "
   cSql += "   AND B.C6_FILIAL = A.CJ_FILIAL "
   
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )
	
   If !T_RETPEDIDO->( EOF() )
      cPedido := ""
      WHILE !T_RETPEDIDO->( EOF() )
         If Alltrim(cPedido) == "000000"
            T_RETPEDIDO->( DbSkip() )            
            Loop
         Endif
         cPedido := cPedido + T_RETPEDIDO->C6_NUM + ", "
         T_RETPEDIDO->( DbSkip() )
      ENDDO
     
      // Elimina a última vírgula
      cPedido := Substr(cPedido,01, Len(Alltrim(cPedido)) - 1)

   Endif

   If Select("T_RETPEDIDO") > 0
   	  T_RETPEDIDO->( dbCloseArea() )
   EndIf

   RestArea( aArea )

Return cPedido