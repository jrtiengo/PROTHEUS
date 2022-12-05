#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM155.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/02/2012                                                          *
// Objetivo..: Programa que carrega o campo virtual da tabela UA - Pedidos Call    *
//             Center com o nº do Pedido de Venda gerado para o Atendimento.       *
//             Visualização do nº do pedido de venda no grid da tela de atendimen- *
//             tos do Call Center.                                                 * 
// Parãmetros: Filial, Nº Atendimento                                              *
//**********************************************************************************

User Function AUTOM155( _Filial, _Codigo)

   Local cSql   := ""
   Local cTexto := ""
                   
   If Select("T_CENTER") > 0
      T_CENTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UA_FILIAL , "
   cSql += "       A.UA_NUM    , "
   cSql += "       B.UB_NUMPV    "
   cSql += "  FROM " + RetSqlName("SUA") + " A, "
   cSql += "       " + RetSqlName("SUB") + " B  "
   cSql += " WHERE A.UA_FILIAL  = '" + Alltrim(_Filial) + "'"
   cSql += "   AND A.UA_NUM     = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND B.UB_FILIAL  = A.UA_FILIAL"
   cSql += "   AND B.UB_NUM     = A.UA_NUM"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND B.D_E_L_E_T_ = ''"
   cSql += " GROUP BY A.UA_FILIAL, A.UA_NUM, B.UB_NUMPV "
   cSql += " ORDER BY A.UA_FILIAL, A.UA_NUM, B.UB_NUMPV "  

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CENTER", .T., .T. )
   
   If T_CENTER->( EOF() )
      Return ""
   Endif
   
   cTexto := ""

   WHILE !T_CENTER->( EOF() )
      cTexto := cTexto + T_CENTER->UB_NUMPV + "     "
      T_CENTER->( DbSkip() )
   ENDDO
   
//   cTexto := Substr(cTexto, 1, Len(Alltrim(cTexto)) - 2)
   
Return cTexto