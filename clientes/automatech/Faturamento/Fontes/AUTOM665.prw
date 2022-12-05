#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM163.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/03/2013                                                          *
// Objetivo..: Programa que pesquisa a chave da NFe através da informação do nº da *
//             nota fiscal e nº de série.                                          *
//**********************************************************************************

User Function AUTOM665()

   Local cSql := ""

   If Select("T_CONSULTA") > 0                                           
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD  ,"
   cSql += "       A2_LOJA  "
   cSql += "  FROM SA2010   "
   cSql += " WHERE LEN(LTRIM(RTRIM(A2_CGC))) > 11"
   cSql += "   AND A2_TIPO = 'F'                 "
   cSql += "   AND D_E_L_E_T_ = ''               "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
	  DbSelectArea("SA2")
	  DbSetOrder(1)
  	  If DbSeek(xFilial("SA2") + T_CONSULTA->A2_COD + T_CONSULTA->A2_LOJA)
         RecLock("SA2",.F.)
         SA2->A2_TIPO := "J"
		 MsUnlock()
      Endif
      
      T_CONSULTA->( DbSkip() )
      
   ENDDO

Return(.T.)