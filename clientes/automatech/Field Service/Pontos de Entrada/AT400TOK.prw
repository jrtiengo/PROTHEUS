#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT400TOK.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 21/02/2014                                                          *
// Objetivo..: Ponto de Entrada Disparado na Grava��o do Or�amento Field Service.  *   
//**********************************************************************************

User Function AT400TOK()

   Local cSql := ""

   If M->AB3_CONPAG == "107"
      If (M->AB3_PARC1 + M->AB3_PARC2 + M->AB3_PARC3 + M->AB3_PARC4) == 0
         MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Condi��o de Pagamento do Or�amento informada 107 - Negoci�vel Valor." + chr(13) + chr(10) + ;
                  "N�o foram informados vencimentos e valores." + chr(13) + chr(10) + ;
                  "Informe estes dados para prosseguir.")
         Return(.F.)
      Endif
   Endif

   
/*   
   // Pesquisa se o Or�amento selecionado possui informa��o de apontamento.
   // Se n�o possuir, n�o permite a altera��o do combo do produto
     
   For nContar = 1 to Len(aCols)
       If aCols[nContar][2] == "2"       
          If Select("T_APONTAMENTO") > 0
             T_APONTAMENTO->( dbCloseArea() )
          EndIf
       
          cSql := ""
          cSql := "SELECT AB5_NUMORC,"
          cSql += "       AB5_ITEM   "
          cSql += "  FROM " + RetSqlName("AB5")
          cSql += " WHERE AB5_FILIAL = '" + Alltrim(AB3_FILIAL) + "'"
          cSql += "   AND AB5_NUMORC = '" + Alltrim(AB3_NUMORC) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTAMENTO", .T., .T. )

          If T_APONTAMENTO->( EOF() )
             MsgAlert("Aten��o!" + chr(13) + Chr(10) + chr(13) + Chr(10) + "Or�amento sem informa��o de apontamentos." + chr(13) + Chr(10) + "Verifique!")
             Return(.F.)
          Endif
       Endif
   Next nContar
   
   */    
        
Return(.T.)