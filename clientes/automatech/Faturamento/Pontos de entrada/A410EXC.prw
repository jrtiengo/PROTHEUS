#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    

// #####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              ##
// ---------------------------------------------------------------------------------- ##
// Referencia: A410EXC.PRW                                                            ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                        ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 30/05/2017                                                             ##
// Objetivo..: Ponto de Entrada que elimina da tabela ZPH os registro do PV excluído. ##
// ##################################################################################### 

User Function A410EXC()

   Local cSql := ""

   U_AUTOM628("A410EXC")

   If Select("T_TABELAZPH") > 0
      T_TABELAZPH->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZPH_EMPD,"
   cSql += "       ZPH_FILD,"
   cSql += "   	   ZPH_PEDD "
   cSql += "  FROM " + RetSqlName("ZPH")
   cSql += " WHERE ZPH_FILD = '" + Alltrim(SC5->C5_FILIAL) + "'"
   cSql += "   AND ZPH_PEDD = '" + Alltrim(SC5->C5_NUM)    + "'"
   cSql += "	  AND ZPH_DELE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELAZPH", .T., .T. )

   If T_TABELAZPH->( EOF() )
      Return(.T.)
   Endif
   
   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZPH")
   cSql += "   SET "
   cSql += "   ZPH_DELE = 'X'"
   cSql += " WHERE ZPH_FILD = '" + Alltrim(SC5->C5_FILIAL) + "'"
   cSql += "   AND ZPH_PEDD = '" + Alltrim(SC5->C5_NUM)    + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   // ###################################################################
   // Verifica se o pedido de venda tem uma OS vinculada.              ##
   // Se tiver, altera o status da os para deixá-la liberada novamente ##
   // ###################################################################
   If Select("T_TEMORDEM") > 0
      T_TEMORDEM->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT C6_FILIAL,"
   cSql += "       C6_NUM   ,"       
   cSql += "       C6_NUMOS  "  
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(SC5->C5_FILIAL) + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(SC5->C5_NUM)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEMORDEM", .T., .T. )
   
   If T_TEMORDEM->( EOF() )
   Else
      If Empty(Alltrim(T_TEMORDEM->C6_NUMOS))
      Else
		 DbSelectArea('AB6')
		 DbSetOrder(1)
		 If DbSeek(Filial('AB6') + Substr(T_TEMORDEM->C6_NUMOS,01,06))
			RecLock("AB6",.F.)
			AB6->AB6_STATUS := "B"
			MsUnlock()
		 Endif
      Endif
   Endif   		 	

Return(.T.)