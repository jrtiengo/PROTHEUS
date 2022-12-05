#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FT300ABR.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/12/2012                                                          *
// Objetivo..: Ponto de Entrada disparado na seleção dos botões Incluir, Alterar,  *    
//             Excluir e Visualizar da tela de Oportunidades.                      *
//**********************************************************************************

User Function FT300ABR()

   Local cSql := ""
   
   U_AUTOM628("FT300ABR")

   // Se for usuário Administrador, permite todas as operações
//   If Alltrim(Upper(cUserName)) == "ADMINISTRADOR"
//      Return .T.
//   Endif
 
   // Se for inclusão, permite para todos os vendedores
   If Inclui()
      Return .T.
   Endif   
   
   // Pesquisa dados do vendedor pelo código do usuário logado
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
   
   // Se não encontrar registro de vendedor para o usuário logado, não permite nenhuma operação
   If T_VENDEDOR->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Vendedor sem autorização para realizar esta operação.")
      Return .F.
   Endif

   // Se A3_TSTAT = 2 permite realizar todas as operações
   If T_VENDEDOR->A3_TSTAT == "2"
      Return .T.
   Endif

   // Se A3_TSTAT == 1, verifica se o vendedor da oportunidade selecionada é o mesmo que está logado.
   // Se não for, não permite a operação.
   If Alltrim(T_VENDEDOR->A3_COD) <> Alltrim(AD1->AD1_VEND)
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você não tem autorização para efetuar esta operação para esta oportunidade.")
      Return .F.
   Endif
   
Return(.T.)