#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM225.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 31/03/2014                                                          *
// Objetivo..: Programa que abre o aviso de Solicitação de Liberação de RMA's      *
//**********************************************************************************

User Function AUTOM225()

   Local cSql        := ""
   Local lEaprovador := .F.

   _AvisoRMA := .T.

   // Verifica se o usuário logado é um aprovador de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_NRMA1 ,"
   cSql += "       ZZ4_NRMA2 ,"
   cSql += "       ZZ4_NRMA3 ,"
   cSql += "       ZZ4_NRMA4 ,"
   cSql += "       ZZ4_NRMA5 ,"
   cSql += "       ZZ4_NRMA6 ,"
   cSql += "       ZZ4_NRMA7 ,"
   cSql += "       ZZ4_NRMA8 ,"
   cSql += "       ZZ4_NRMA9 ,"
   cSql += "       ZZ4_NRMA10,"            
   cSql += "       ZZ4_VRMA   "
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return(.T.)
   Endif
   
   If Alltrim(T_PARAMETROS->ZZ4_NRMA1) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA2) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA3) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA4) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA5) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA6) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA7) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA8) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA9) + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA10) == ""
      Return(.T.)
   Endif

   lEaprovador := .F.

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA1)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif
   
   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA2)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA3)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA4)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA5)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA6)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA7)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA8)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA9)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA10)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If lEaprovador == .F.       
      Return(.T.)
   Endif

   // Pesquisa RMA pendentes de Aprovação
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT DISTINCT   "
   cSql += "       A.ZS4_NRMA,"
   cSql += "       A.ZS4_ANO ,"
   cSql += "       A.ZS4_STAT,"
   cSql += "       A.ZS4_ABER,"
   cSql += "       A.ZS4_HORA,"
   cSql += "       A.ZS4_CLIE,"
   cSql += "       A.ZS4_LOJA,"
   cSql += "       B.A1_NOME ,"
   cSql += "       A.ZS4_VEND,"
   cSql += "       C.A3_NOME ,"
   cSql += "       A.ZS4_DLIB,"
   cSql += "       A.ZS4_HLIB,"
   cSql += "       A.ZS4_APRO "
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C  "
   cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND A.ZS4_STAT   = '1'" 
   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "
   cSql += " ORDER BY A.ZS4_NRMA, A.ZS4_ANO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If !T_DADOS->( EOF() )
      MsgAlert("ATENÇÃO!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existem RMA(s) emcaminhada(s) pelo(s) vendedor(es) para aprovação." + chr(13) + chr(10) + "Agilize a aprovação pois a(s) RMA(s) possuem prazo de validade.")
      Return(.T.)
   Endif

Return(.T.)