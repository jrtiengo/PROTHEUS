#Include "Protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT450OKE.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/10/2011                                                          *
// Objetivo..: Ponto de Entrada que verifica se a OS selecionada poderá se efeti-  *
//             vada conforme regra abaixo:                                         *
//             ------------------------------------------------------------------  *
//             1º) Somente poderá ser efetivada OS que possuirem pelo menos um a-  *
//                 pontamento realizado.                                           *
//             2º) Somente poderá ser efetivada OS que estiverem  com  o campo da  *
//                 tabela AB6 (AB6_STATUS) com o conteúdo B - OS Atendida.         *
//**********************************************************************************

User Function AT450TOK()

   Local _aArea    := GetArea()
   Local _aAreaSC5 := GetArea("SC5")
   
   Local _aAreaAB6 := GetArea("AB6")
   Local _aAreaAB7 := GetArea("AB7")
   Local _aAreaAB8 := GetArea("AB8")
   Local _aAreaAA3 := GetArea("AA3")
   
   Local cSql      := ""
   Local cCodPV    := ""
   Local cCodFL    := ""

   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB9_FILIAL,"
   cSql += "       AB9_ETIQUE "
   cSql += "  FROM " + RetSqlName("AB9") + "(NOLOCK)"
   cSql += " WHERE SUBSTRING(AB9_NUMOS,01,06)  = '" + Alltrim(AB7->AB7_NUMOS) + "'"                           
   cSql += "   AND AB9_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'"                           
   cSql += "   AND D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   T_STATUS->( DbGoTop() )

   If T_STATUS->( Eof() )

      MsgAlert("ATENÇÃO !!" + chr(13) + chr(13) + "O.S. não poderá ser efetivada pois a mesma ainda não foi ATENDIDA.")
      Return .F.
      
   Endif

   RestArea(_aArea)
   RestArea(_aAreaSC5)

   Restarea(_aAreaAB6)
   Restarea(_aAreaAB7)
   Restarea(_aAreaAB8)
   Restarea(_aAreaAA3)
 
Return()

