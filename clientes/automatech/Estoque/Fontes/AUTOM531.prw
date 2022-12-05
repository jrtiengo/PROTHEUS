#INCLUDE "AP5MAIL.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#DEFINE  ENTER CHR(13)+CHR(10)

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: AUTOM531.PRW                                                                                     ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                                          ##
// Data......: 18/01/2017                                                                                       ##
// Objetivo..: Programa que atualiza Peso, comprimento, altura e largura no cadastro de produtos para etiquetas ##
// ###############################################################################################################

User Function AUTOM531()

   Local cSql := ""

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD ,"
   cSql += "       B1_PESC,"
   cSql += "       B1_ALTU,"
   cSql += "   	   B1_COMP,"
   cSql += "	   B1_LARG "
   cSql += "  FROM " + RetSqlName("SB1") + "(Nolock)"
   cSql += " WHERE LEN(B1_COD) > 6"
   cSql += "   AND D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      If Substr(T_PRODUTOS->B1_COD,10,01) == "2"

		 DbSelectArea("SB1")
		 DbSetOrder(1) 
		 If DbSeek(xFilial("SB1") + T_PRODUTOS->B1_COD)
   	        RecLock("SB1",.F.)
            SB1->B1_PESC := 0.546 
            SB1->B1_ALTU := 10
            SB1->B1_COMP := 8
            SB1->B1_LARG := 8
   	        MsUnlock()
   	     Endif
   	    
   	  Endif
   	 
      If Substr(T_PRODUTOS->B1_COD,10,01) == "4"

		DbSelectArea("SB1")
		DbSetOrder(1) 
		If DbSeek(xFilial("SB1") + T_PRODUTOS->B1_COD)
   	       RecLock("SB1",.F.)
           SB1->B1_PESC := 1.4
           SB1->B1_ALTU := 10
           SB1->B1_COMP := 14
           SB1->B1_LARG := 14
           MsUnlock()
   	    Endif

      Endif
      
      T_PRODUTOS->( DbSkip() )
      
   ENDDO
      
Return(.T.)