#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOBR01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/08/2011                                                          *
// Objetivo..: Programa que carrega a descrição do produto e o número de série nos *
//             grid's dos Chamado Técnico, Orçamento e Ordem de Serviço.           *
//**********************************************************************************
// Função que define a Window
User Function AUTOB01(_Filial, _Codigo, _Tipo)
 
   // _Filial -> Código da Filial
   // _Codigo -> Cópdigo a ser pesquisado (Chamado Técnico, Orçamento, Ordem de Serviço)
   // _Tipo   -> A - Chamado Técnico, B - Orçameto, C - Tipo de Pesquisa

   // Declara as variáveis locais
   Local cSql := ""

   // _Tipo == A -> Chamado Técnico
   If _Tipo == "A"

      If Select("T_BROWSE") > 0
         T_BROWSE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB2_CODPRO,"
      cSql += "       A.AB2_NUMSER,"
      cSql += "       B.B1_DESC   ,"
      cSql += "       B.B1_DAUX    "
      cSql += "  FROM " + RetSqlName("AB2010") + " A, "
      cSql += "       " + RetSqlName("SB1010") + " B  "
      cSql += " WHERE A.AB2_CODPRO = B.B1_COD "
      cSql += "   AND A.AB2_FILIAL = '" + Alltrim(_Filial) + "'"
      cSql += "   AND A.AB2_NRCHAM = '" + Alltrim(_Codigo) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BROWSE", .T., .T. )

      If !T_BROWSE->( Eof() )
         Return Alltrim(T_BROWSE->B1_DESC) + " " + Alltrim(T_BROWSE->B1_DAUX)
      Else
         Return ""
      Endif
   Endif

   // _Tipo == B -> Orçamento
   If _Tipo == "B"

      If Select("T_BROWSE") > 0
         T_BROWSE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB4_CODPRO,"
      cSql += "       A.AB4_NUMSER,"
      cSql += "       B.B1_DESC   ,"
      cSql += "       B.B1_DAUX    "
      cSql += "  FROM " + RetSqlName("AB4010") + " A, "
      cSql += "       " + RetSqlName("SB1010") + " B  "
      cSql += " WHERE A.AB4_CODPRO = B.B1_COD "
      cSql += "   AND A.AB4_FILIAL = '" + Alltrim(_Filial) + "'"
      cSql += "   AND A.AB4_NUMORC = '" + Alltrim(_Codigo) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BROWSE", .T., .T. )

      If !T_BROWSE->( Eof() )
         Return Alltrim(T_BROWSE->B1_DESC) + " " + Alltrim(T_BROWSE->B1_DAUX)
      Else
         Return ""
      Endif
   Endif

   // _Tipo == C -> Ordem de Serviço
   If _Tipo == "C"

      If Select("T_BROWSE") > 0
         T_BROWSE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB7_CODPRO,"
      cSql += "       A.AB7_NUMSER,"
      cSql += "       B.B1_DESC   ,"
      cSql += "       B.B1_DAUX    "
      cSql += "  FROM " + RetSqlName("AB7010") + " A, "
      cSql += "       " + RetSqlName("SB1010") + " B  "
      cSql += " WHERE A.AB7_CODPRO = B.B1_COD "
      cSql += "   AND A.AB7_FILIAL = '" + Alltrim(_Filial) + "'"
      cSql += "   AND A.AB7_NUMOS  = '" + Alltrim(_Codigo) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BROWSE", .T., .T. )

      If !T_BROWSE->( Eof() )
         Return Alltrim(T_BROWSE->B1_DESC) + " " + Alltrim(T_BROWSE->B1_DAUX)
      Else
         Return ""
      Endif
   Endif

Return(.T.)
