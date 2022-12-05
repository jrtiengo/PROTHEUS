#include "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR79.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/02/2012                                                          *
// Objetivo..: Carrega o nome da condição de pagamento do documento selecionado.   *
// Parâmetros: Prefixo, Titulo, Cliente, Loja Cliente                              *
//**********************************************************************************

USER FUNCTION AUTOMR79(_Prefixo, _Titulo, _Filial)

   Local cSql          := ""
   Local cNomeCondicao := ""

   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""         
   cSql := "SELECT A.F2_COND  ,"
   cSql += "       B.E4_COND  ,"
   cSql += "       B.E4_DESCRI "
   cSql += "  FROM " + RetSqlName("SF2") + " A, "
   cSql += "       " + RetSqlName("SE4") + " B  "
   cSql += " WHERE A.F2_DOC       = '" + Alltrim(_Titulo)  + "'"
   cSql += "   AND A.F2_SERIE     = '" + Alltrim(_Prefixo) + "'"
   cSql += "   AND A.F2_FILIAL    = '" + Alltrim(_Filial)  + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = '0'"
   cSql += "   AND A.F2_COND = B.E4_CODIGO"
   cSql += "   AND B.R_E_C_D_E_L_ = '0'"
   cSql += "   AND B.E4_FILIAL    = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   If T_CONDICAO->( EOF() )
      cNomeCondicao := ""
   Else
      cNomeCondicao := Alltrim(T_CONDICAO->E4_DESCRI)
   Endif
   
Return cNomeCondicao