 #INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM251.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 15/09/2014                                                          *
// Objetivo..: Gatilho que verifica os produtos gen�ricos                          *
//             Gatilho disparado na tela de informa��o de apomtamentos das Ordens  *
//             de servi�o.                                                         *
//**********************************************************************************

User Function AUTOM251(_PGenerico)

   Local cSql    := ""
   Local lExiste := .F.

   // Carrega o combobox de vendedores
   If Select("T_GENERICO") > 0
      T_GENERICO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GENE"
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GENERICO", .T., .T. )

   If T_GENERICO->( EOF() )
      Return(_PGenerico)
   Endif

   If Empty(Alltrim(T_GENERICO->ZZ4_GENE))
      Return(_PGenerico)
   Endif
   
   // Compara o produto digitado com os parametrizados
   lExiste := .F.
   For nContar = 1 to U_P_OCCURS(T_GENERICO->ZZ4_GENE, "|", 1)
       If Alltrim(_PGenerico) == Alltrim(U_P_CORTA(T_GENERICO->ZZ4_GENE, "|", nContar))
          lExiste := .T.
          Exit
       Endif
   Next nContar
   
   If lExiste
      MsgAlert("Aten��o! N�o � permitido a utiliza��o de produto gen�rico nesta opera��o.")
      Return ""
   Endif

Return(_PGenerico)