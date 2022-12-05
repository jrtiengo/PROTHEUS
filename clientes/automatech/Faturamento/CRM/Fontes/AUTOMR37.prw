#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR37.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 01/11/2011                                                          *
// Objetivo..: Processo que retorna o c�digo da Proposta Comercial                 *
// Par�metros: < _Oportunidade > - C�digo da Oportunidade                          *
//**********************************************************************************

// Fun��o que define a Window
User Function AUTOMR37()

   Local cSql      := ""
   Local cProposta := ""
   Local aArea     := GetArea()

   U_AUTOM628("AUTOMR37")

// _Oportunidade, _Filial

   DbSelectArea("AD1")   

   If Select("T_RETPEDIDO") > 0
   	  T_RETPEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AD1_PROPOS "
   cSql += "  FROM " + RetSqlName("AD1010")
// cSql += " WHERE AD1_NROPOR   = '" + Alltrim(_Oportunidade) + "'"
// cSql += "   AND AD1_FILIAL   = '" + Alltrim(_Filial)       + "'"
   cSql += " WHERE AD1_NROPOR   = '" + Alltrim(AD1_NROPOR) + "'"
   cSql += "   AND AD1_FILIAL   = '" + Alltrim(AD1_FILIAL) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )
	
   If T_RETPEDIDO->( EOF() )
      cProposta := ""
   Else
      cProposta := T_RETPEDIDO->AD1_PROPOS
   Endif
      
   If Select("T_RETPEDIDO") > 0
   	  T_RETPEDIDO->( dbCloseArea() )
   EndIf
   
   RestArea( aArea )

Return cProposta