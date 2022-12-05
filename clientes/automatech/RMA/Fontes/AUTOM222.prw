#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM222.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/03/2014                                                          *
// Objetivo..: Programa que realiza o encerramento automático de RMA pelo Módulo   *
//             de Estoque.                                                         *
//**********************************************************************************

User Function AUTOM222()

   Local cSql        := ""
   Local cTexto      := ""
   Local _nErro      := 0
   Local nContar     := 0
   Local lMarcado    := .F.

   Private cEncerrar := 0
   Private cAviso    := 0
   Private aLista    := {}
   Private oLista

   _EncerraRma := .T.

   // Pesquisa os parâmetros para encerramento automático de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_VRMA," 
   cSql += "       ZZ4_ERMA,"
   cSql += "       ZZ4_AVIS "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cEncerrar := T_PARAMETROS->ZZ4_ERMA
   Endif
   
   If cEncerrar == 0
      Return(.T.)
   Endif

   cAviso := T_PARAMETROS->ZZ4_AVIS

   // Pesquisa as RMA's vencidas para encerramento
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf
  
   cSql := ""
   cSql += "SELECT A.ZS4_NRMA,"
   cSql += "       A.ZS4_ANO ,"
   cSql += "       A.ZS4_STAT,"
   cSql += "       A.ZS4_ABER,"
   cSql += "       A.ZS4_HORA,"
   cSql += "       A.ZS4_CLIE,"
   cSql += "       A.ZS4_LOJA,"
   cSql += "       A.ZS4_TELE,"
   cSql += "       A.ZS4_EMAI,"
   cSql += "       A.ZS4_NFIL,"
   cSql += "       A.ZS4_NOTA,"
   cSql += "       A.ZS4_SERI,"
   cSql += "       A.ZS4_CRED,"
   cSql += "       A.ZS4_CREF,"
   cSql += "       A.ZS4_CREN,"
   cSql += "       A.ZS4_CRES,"
   cSql += "       B.A1_NOME ,"
   cSql += "       A.ZS4_VEND,"
   cSql += "       C.A3_NOME ,"
   cSql += "       C.A3_EMAIL,"
   cSql += "       A.ZS4_DLIB,"
   cSql += "       A.ZS4_HLIB,"
   cSql += "       A.ZS4_APRO,"
   cSql += "       A.ZS4_CONT,"
   cSql += "       A.ZS4_CHEK,"
   cSql += "       A.ZS4_ITEM,"
   cSql += "       A.ZS4_PROD,"
   cSql += "       A.ZS4_QUAN,"
   cSql += "       A.ZS4_UNIT,"
   cSql += "       A.ZS4_TOTA,"
   cSql += "       A.ZS4_CMOT,"
   cSql += "       A.ZS4_CMTA,"
   cSql += "       A.ZS4_VALI,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_MOTI)) AS MOTIVO,"
   cSql += "       D.U5_CONTAT,"
   cSql += "       E.B1_DESC  ,"
   cSql += "       E.B1_DAUX  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)) AS SERIES, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_CONS)) AS OBSERVACAO "
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C, "
   cSql += "       " + RetSqlName("SU5") + " D, "
   cSql += "       " + RetSqlName("SB1") + " E  "
   cSql += " WHERE A.ZS4_NRET   = ''"
   cSql += "   AND A.ZS4_DLIB  <> ''"
   cSql += "   AND A.ZS4_DENC   = ''"
   cSql += "   AND A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_CONT   = D.U5_CODCONT"
   cSql += "   AND D.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_PROD   = E.B1_COD "
   cSql += "   AND E.D_E_L_E_T_ = ''       "
   cSql += " ORDER BY A.ZS4_NRMA, A.ZS4_ANO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      Return(.T.)
   Endif
   
   T_DADOS->( DbGoTop() )
   WHILE !T_DADOS->( EOF() )

      // Prepara as data para verificação
      dValidade := Ctod(Substr(T_DADOS->ZS4_VALI,07,02) + "/" + Substr(T_DADOS->ZS4_VALI,05,02) + "/" + Substr(T_DADOS->ZS4_VALI,01,04))
     
      If dValidade >= Date()
         T_DADOS->( DbSkip() )         
         Loop
      Endif
     
      If (Date() - dValidade) < cEncerrar
         T_DADOS->( DbSkip() )         
         Loop
      Endif

      // Envia o aviso ao vendedor
      If (Date() - dValidade) <= cAviso

         If !Empty(Alltrim(T_DADOS->A3_EMAIXL))
            cTexto := ""
            cTexto := "Prezado(a) Vendedor(a)" + chr(13) + chr(10) + chr(13) + chr(10)
            cTexto += "Informados que a RMA de nº " + Alltrim(T_DADOS->ZS4_NRMA) + "/" + Alltrim(T_DADOS->ZS4_ANO) + "será encerrada" + chr(13) + chr(10)
            cTexto += "automaticamente em " + Alltrim(str((Date() - dValidade))) + " dia(s)." + chr(13) + chr(10) + chr(13) + chr(10)
            cTexto += "Mensagem disparada automaticamente pelo Sistema de Controle de RMA"

            U_AUTOMR20(cTexto, Alltrim(T_VENDEDOR->A3_EMAIL), "", "Aviso de Encerramento Automático de RMA" )   

         Endif
         
      Endif
        
      // Carrega o array para encerramento das RMA vencidas
      aAdd( aLista, { .T.              ,;
                      T_DADOS->ZS4_NRMA,;
                      T_DADOS->ZS4_ANO ,;
                      Substr(T_DADOS->ZS4_DLIB,07,02) + "/" + Substr(T_DADOS->ZS4_DLIB,05,02) + "/" + Substr(T_DADOS->ZS4_DLIB,01,04) ,;
                      T_DADOS->ZS4_HLIB,;
                      Substr(T_DADOS->ZS4_VALI,07,02) + "/" + Substr(T_DADOS->ZS4_VALI,05,02) + "/" + Substr(T_DADOS->ZS4_VALI,01,04) ,;
                      T_DADOS->ZS4_CLIE,;
                      T_DADOS->ZS4_LOJA,;
                      T_DADOS->A1_NOME ,;
                      T_DADOS->ZS4_VEND,;
                      T_DADOS->A3_NOME })
      T_DADOS->( DbSkip() )

   ENDDO

   If Len(aLista) == 0
      Return(.T.)
   Endif

   // Encerra as RMA's selecionadas
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif   

       // Canecala o registro para nova gravação
       cSql := ""
       cSql := "UPDATE " + RetSqlName("ZS4")
       cSql += "   SET "
       cSql += "   ZS4_STAT = '3',"
       cSql += "   ZS4_DENC = '"  + Strzero(year(Date()),4) + Strzero(month(Date()),2) + Strzero(day(Date()),2) + "', "
       cSql += "   ZS4_UENC = '"  + Alltrim(CUSERNAME)      + "'"
       cSql += " WHERE ZS4_NRMA = '" + Alltrim(aLista[nContar,02]) + "'"
       cSql += "   AND ZS4_ANO  = '" + Alltrim(aLista[nContar,03]) + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
          Return(.T.)
       Endif

   Next nContar
   
Return(.T.)   