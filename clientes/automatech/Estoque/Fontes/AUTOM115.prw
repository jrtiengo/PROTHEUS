#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM115.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/06/2012                                                          *
// Objetivo..: Gatilho que pesquisa a descrição do produto informado na tela de    *
//             Ajuste de Empenho de Produção.                                      *
// Parâmetros: << _Producao >> - Código da Ordem de Produção                       *
//**********************************************************************************

User Function AUTOM115(_Funcao)

   Local cSql      := ""
   Local cProducao := ""
   Local cItem     := ""
   Local cSequen   := ""

   U_AUTOM628("AUTOM115")

   If Alltrim(_Funcao) == "A381MANUT"
      cProducao := Substr(COP,01,06)
      cItem     := Substr(COP,07,02)
      cSequen   := Substr(COP,09,03)
   Else
      If Empty(Alltrim(SD4->D4_OP))
         Return ""
      Endif   
      cProducao := Substr(SD4->D4_OP,01,06)
      cItem     := Substr(SD4->D4_OP,07,02)
      cSequen   := Substr(SD4->D4_OP,09,03)
   Endif   

   // Pesquisa a descrição do Produto informada
   If Select("T_PRODUTO") <>  0
      T_PRODUTO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT A.C2_PRODUTO,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX    "
   cSql += "  FROM " + RetSqlName("SC2") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.C2_NUM     = '" + Alltrim(cProducao) + "'"
   cSql += "   AND A.C2_FILIAL  = '" + Alltrim(cFilant)   + "'"
   cSql += "   AND A.C2_ITEM    = '" + Alltrim(cItem)     + "'"
   cSql += "   AND A.C2_SEQUEN  = '" + alltrim(cSequen)   + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.C2_PRODUTO = B.B1_COD"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)

   If T_PRODUTO->( EOF() )
      Return ""
   Endif

Return  ALLTRIM(T_PRODUTO->B1_DESC) + " " + ALLTRIM(T_PRODUTO->B1_DAUX)