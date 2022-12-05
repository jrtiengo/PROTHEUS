#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FT300ABR.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 19/12/2012                                                          *
// Objetivo..: Ponto de Entrada disparado na sele��o dos bot�es Incluir, Alterar,  *    
//             Excluir e Visualizar da tela de Oportunidades.                      *
//**********************************************************************************

User Function FT300ABR()

   Local cSql := ""
   
   U_AUTOM628("FT300ABR")

   // Se for usu�rio Administrador, permite todas as opera��es
//   If Alltrim(Upper(cUserName)) == "ADMINISTRADOR"
//      Return .T.
//   Endif
 
   // Se for inclus�o, permite para todos os vendedores
   If Inclui()
      Return .T.
   Endif   
   
   // Pesquisa dados do vendedor pelo c�digo do usu�rio logado
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql := "SELECT A3_COD   ,"
   cSql += "       A3_NOME  ,"
   cSql += "       A3_CODUSR,"
   cSql += "       A3_TSTAT ,"
   cSql += "       A3_TIPOV  "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE D_E_L_E_T_ = ''"
// cSql += "   AND A3_CODUSR  = '" + Alltrim(__CUSERID) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
   
   // Se n�o encontrar registro de vendedor para o usu�rio logado, n�o permite nenhuma opera��o
   If T_VENDEDOR->( EOF() )
      MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "Vendedor sem autoriza��o para realizar esta opera��o.")
      Return .F.
   Endif

   // Se A3_TSTAT = 2 permite realizar todas as opera��es
   If T_VENDEDOR->A3_TSTAT == "2"
      Return .T.
   Endif

   // Se A3_TSTAT == 1, verifica se o vendedor da oportunidade selecionada � o mesmo que est� logado.
   // Se n�o for, n�o permite a opera��o.
   If Alltrim(T_VENDEDOR->A3_COD) <> Alltrim(AD1->AD1_VEND)
      MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "Voc� n�o tem autoriza��o para efetuar esta opera��o para esta oportunidade.")
      Return .F.
   Endif
   
Return(.T.)