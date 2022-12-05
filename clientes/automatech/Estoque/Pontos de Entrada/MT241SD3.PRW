#Include "Protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MT241SD3.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/10/2016                                                          *
// Objetivo..: PE disparado logo após a gravação da movimentação interna.(2)       *
//**********************************************************************************

User Function MT241SD3()

   Local csql   := ""

   U_AUTOM628("MT241SD3")

   If Select("T_AJUSTE") > 0
      T_AJUSTE->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT D3_FILIAL,"
   cSql += "       D3_TM    ,"
   cSql += "       D3_DOC   ,"
   cSql += "       D3_COD    "
   cSql += "  FROM " + RetSqlName("SD3")
   cSql += " WHERE D3_FILIAL  = '" + Alltrim(SD3->D3_FILIAL) + "'"
   cSql += "   AND D3_DOC     = '" + Alltrim(SD3->D3_DOC)    + "'"
   cSql += "   AND D3_TM IN ('200', '300', '400', '410')"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AJUSTE", .T., .T. )

   If T_AJUSTE->( EOF() )
      Return .T.
   Endif
   
   T_AJUSTE->( DbGoTop() )

   WHILE !T_AJUSTE->( EOF() )
   
   	  dbSelectArea("SD3")
	  dbSetOrder(2)
	  If dbSeek( T_AJUSTE->D3_FILIAL + T_AJUSTE->D3_DOC + T_AJUSTE->D3_COD )
         RecLock("SD3",.F.)
          SD3->D3_OPEN := "1"
         MsUnLock()              
      Endif   
      
      T_AJUSTE->( DbSkip() )
      
   ENDDO

Return(.T.)