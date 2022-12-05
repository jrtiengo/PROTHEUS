#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM104.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/04/2012                                                          *
// Objetivo..: Gatilho disparado no código do produto do Chamado Técnico, Orçamen- *
//             to e Ordem de Serviços e carrega a data de garantia da base  insta- *
//             lada.                                                               *
// Parâmetros: _Tipo    -> A - Chamado, O - Orçamento, S - Ordem de Serviço        *
//             _Cliente -> Código do Cliente                                       *
//             _Loja    -> Loja do Cliente                                         *
//             _Produto -> Código do Produto a ser pesquisado                      *
//**********************************************************************************

User Function AUTOM104(_Tipo, _Produto, _Serie)

   Local cSql      := ""
   Local dGarantia := Ctod("  /  /    ")
   
   If Empty(Alltrim(_Produto))
      Return Ctod("  /  /    ")
   Endif
  
   If Select("T_BASE") > 0
      T_BASE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA3_CODCLI,"
   cSql += "       AA3_LOJA  ,"
   cSql += "       AA3_CODPRO,"
   cSql += "       AA3_NUMSER,"
   cSql += "       AA3_DTGAR  "
   cSql += "  FROM " + RetSqlName("AA3")+ " WHERE "
   
   Do Case
      Case _Tipo == "A"
           cSql += " AA3_CODCLI = '" + Alltrim(m->ab1_codcli) + "'"
           cSql += "   AND AA3_LOJA   = '" + Alltrim(m->ab1_loja)   + "' AND "
      Case _Tipo == "O"
           cSql += " AA3_CODCLI = '" + Alltrim(m->ab4_codcli) + "'"
           cSql += "   AND AA3_LOJA   = '" + Alltrim(m->ab4_loja)   + "' AND "
   EndCase      
           
   cSql += "   AA3_FILIAL = '" + Alltrim(cFilAnt)       + "'"
   cSql += "   AND AA3_CODPRO = '" + Alltrim(_Produto)      + "'"
   cSql += "   AND AA3_NUMSER = '" + Alltrim(_Serie)        + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BASE", .T., .T. )

   If T_BASE->( EOF() )
      Return Ctod("  /  /    ")
   Endif

   dGarantia := Ctod(Substr(T_BASE->AA3_DTGAR,07,02) + "/" + Substr(T_BASE->AA3_DTGAR,05,02) + "/" + Substr(T_BASE->AA3_DTGAR,01,04))
  
Return dGarantia