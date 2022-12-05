#INCLUDE "TOTVS.CH"

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ## 
// Referencia: AUTOM683.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 20/03/2018                                                            ##
// Objetivo..: Programa que elimina reg. do Contas a Pagar para contratos cancelados ##
// Parâmetros: Sem Parâmetros                                                        ##
// Retorno...: Consulta Serasa                                                       ##
// ####################################################################################

User Function AUTOM683()

   Local cSql := ""

   If Select("T_CONTRATOS") > 0
      T_CONTRATOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SE2.E2_FILORIG," + CHR(13) 
   cSql	+= "       SE2.E2_NUM    ," + CHR(13) 
   cSql	+= "       SE2.E2_PREFIXO," + CHR(13) 
   cSql	+= "	   SE2.E2_TIPO   ," + CHR(13) 
   cSql += "       SE2.E2_PARCELA," + CHR(13)
   cSql	+= "	   SE2.E2_MDCONTR," + CHR(13) 
   cSql	+= "	   SE2.E2_FORNECE," + CHR(13) 
   cSql	+= "	   SE2.E2_LOJA   ," + CHR(13) 
   cSql	+= "	   CN9.CN9_NUMERO " + CHR(13) 
   cSql	+= "  FROM " + RetSqlName("SE2") + " SE2,  " + CHR(13) 
   cSql	+= "       " + RetSqlName("CN9") + " CN9   " + CHR(13) 
   cSql += " WHERE SE2.E2_MDCONTR <> ''            " + CHR(13) 
   cSql	+= "   AND SE2.D_E_L_E_T_  = ''            " + CHR(13) 
   cSql	+= "   AND CN9.CN9_FILIAL  = SE2.E2_FILORIG" + CHR(13) 
   cSql	+= "   AND CN9.CN9_NUMERO  = SE2.E2_MDCONTR" + CHR(13) 
   cSql	+= "   AND CN9.CN9_SITUAC  = '01'          " + CHR(13) 
   cSql	+= "   AND CN9.CN9_TPCTO   = '001'         " + CHR(13) 
   cSql	+= "   AND CN9.D_E_L_E_T_  = ''            " + CHR(13) 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATOS", .T., .T. )

   T_CONTRATOS->( DbGoTop() )
   
   WHILE !T_CONTRATOS->( EOF() )
   
      dbSelectArea("SE2")
	  dbSetOrder(1)
	  
	  If dbSeek( xFilial("SE2") + T_CONTRATOS->E2_PREFIXO + T_CONTRATOS->E2_NUM + T_CONTRATOS->E2_PARCELA + T_CONTRATOS->E2_TIPO + T_CONTRATOS->E2_FORNECE + T_CONTRATOS->E2_LOJA)
         RecLock("SE2",.F.)
         DbDelete()
         MsUnLock()        
      Endif               

      T_CONTRATOS->( DbSkip() )

   ENDDO
      
Return(.T.)