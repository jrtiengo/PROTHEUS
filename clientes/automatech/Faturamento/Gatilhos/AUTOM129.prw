#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTUOM129.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/07/2012                                                          *
// Objetivo..: gatilho que limpa o campo Lacre da proposta comecial caso o produto *  
//             selecionado não tiver em seu grupo a indicação  de  solicitação  de *
//             lacre.                                                              *
// Parâmetros: < _Produto > - Código do Produto                                    *
//**********************************************************************************

User Function AUTOM129()
                       
   Local cSql   := ""
   Local _aArea := GetArea()
   Local cLacre := acols[n,6]
               
   U_AUTOM628("AUTOM129")
   
   If Empty(Alltrim(acols[n,2]))
      acols[n,6] := ""
      Return ""
   Endif

   // Verifica se existe algum produto que tenha no seu grupo a indicação de lacre
   If Select("T_LACRE") > 0
      T_LACRE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.B1_GRUPO,"
   cSql += "       B.BM_GRUPO,"
   cSql += "       B.BM_LACRE "
   cSql += "   FROM " + RetSqlName("SB1") + " A, "
   cSql += "        " + RetSqlName("SBM") + " B  "
   cSql += "  WHERE A.B1_COD     = '" + Alltrim(acols[n,2]) + "'"
   cSql += "    AND A.D_E_L_E_T_ = ''"
   cSql += "    AND A.B1_GRUPO   = B.BM_GRUPO"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LACRE", .T., .T. )

   If T_LACRE->( EOF() )
      acols[n,6] := ""
      Return ""
   Endif

   If T_LACRE->BM_LACRE <> "S"
      acols[n,6] := ""
      Return ""
   Endif

   RestArea( _aArea )

Return cLacre
