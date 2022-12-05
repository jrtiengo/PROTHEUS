#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPREL10.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 03/07/2014                                                          *
// Objetivo..: Relação de Tarefas por Data Prevista de Entrega                     * 
//**********************************************************************************

User Function ESPREL10(__Programador)

   Local cSql     := ""
  
   Private cMemo1 := ""
   Private cMemo2 := ""

   Private oMemo1
   Private oMemo2

   Private oDlgR

   // Pesquisa as tarefas para serem listadas
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL," + CHR(13)
   cSql += "       A.ZZG_CODI  ," + CHR(13)
   cSql += "       A.ZZG_SEQU  ," + CHR(13)
   cSql += "       A.ZZG_TITU  ," + CHR(13)
   cSql += "       A.ZZG_USUA  ," + CHR(13)
   cSql += "       A.ZZG_DATA  ," + CHR(13)
   cSql += "       A.ZZG_HORA  ," + CHR(13)
   cSql += "       A.ZZG_STAT  ," + CHR(13)
   cSql += "       A.ZZG_DES1  ," + CHR(13)
   cSql += "       A.ZZG_PRIO  ," + CHR(13)
   cSql += "       A.ZZG_NOT1  ," + CHR(13)
   cSql += "       A.ZZG_PREV  ," + CHR(13)
   cSql += "       A.ZZG_TERM  ," + CHR(13)
   cSql += "       A.ZZG_PROD  ," + CHR(13)
   cSql += "       A.ZZG_SOL1  ," + CHR(13)
   cSql += "       A.ZZG_DELE  ," + CHR(13)
   cSql += "       A.ZZG_ORIG  ," + CHR(13)
   cSql += "       A.ZZG_CHAM  ," + CHR(13)
   cSql += "       A.ZZG_COMP  ," + CHR(13)
   cSql += "       A.ZZG_PROG  ," + CHR(13)
   cSql += "       A.ZZG_PROJ  ," + CHR(13)
   cSql += "       B.ZZD_NOME  ," + CHR(13)
   cSql += "       C.ZZF_NOME  ," + CHR(13)
   cSql += "       D.ZZB_NOME  ," + CHR(13)
   cSql += "       E.ZZC_LEGE  ," + CHR(13)
   cSql += "       A.ZZG_TTAR  ," + CHR(13)
   cSql += "       A.ZZG_ESTI  ," + CHR(13)
   cSql += "       A.ZZG_XHOR  ," + CHR(13)
   cSql += "       A.ZZG_XDIA  ," + CHR(13)
   cSql += "       A.ZZG_DEBI  ," + CHR(13)
   cSql += "       A.ZZG_CRED  ," + CHR(13)
   cSql += "       A.ZZG_ORDE  ," + CHR(13)
   cSql += "       A.ZZG_APAR   " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "                    + CHR(13)
   cSql += "       " + RetSqlName("ZZD") + " B, "                    + CHR(13)
   cSql += "       " + RetSqlName("ZZF") + " C, "                    + CHR(13)
   cSql += "       " + RetSqlName("ZZB") + " D, "                    + CHR(13)
   cSql += "       " + RetSqlName("ZZC") + " E  "                    + CHR(13)
   cSql += " WHERE A.ZZG_DELE   = ''"                                + CHR(13)
   cSql += "   AND A.ZZG_STAT  <> '1'"                               + CHR(13)
   cSql += "   AND '00000' + A.ZZG_STAT = E.ZZC_CODIGO "             + CHR(13)
   cSql += "   AND A.ZZG_PRIO   = B.ZZD_CODIGO "                     + CHR(13)
   cSql += "   AND A.ZZG_ORIG   = C.ZZF_CODIGO "                     + CHR(13)
   cSql += "   AND C.ZZF_DELETE = ''"                                + CHR(13)
   cSql += "   AND A.ZZG_COMP   = D.ZZB_CODIGO "                     + CHR(13)
   cSql += " AND A.ZZG_STAT IN ('2','4','5','6','8','0')"            + CHR(13)

   If Substr(__Programador,01,06) == "000000"
   Else
      cSql += " AND A.ZZG_PROG = '" + Substr(__Programador,01,06) + "'" + CHR(13)
   Endif   

   cSql += " ORDER BY A.ZZG_ORDE "                                   + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      Msgalert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif
   
   cMemo2    := ""
   Quebra    := T_STATUS->ZZG_PREV
   lPrimeiro := .T.
      
   WHILE !T_STATUS->( EOF() )

      If T_STATUS->ZZG_PREV == Quebra

         If lPrimeiro
            cMemo2    := cMemo2 + "Previsto para o dia " + Substr(T_STATUS->ZZG_PREV,07,02) + "/"   + ;
                                                           Substr(T_STATUS->ZZG_PREV,05,02) + "/"   + ;
                                                           Substr(T_STATUS->ZZG_PREV,01,04) + " - " + ;
                                                           Alltrim(T_STATUS->ZZG_CODI) + "." + Alltrim(T_STATUS->ZZG_SEQU) + " - " + ;
                                                           T_STATUS->ZZG_TITU + CHR(13) + CHR(10)                                                           
            lPrimeiro := .F.         
         Else
            cMemo2 := cMemo2 + Space(52) + Alltrim(T_STATUS->ZZG_CODI) + "." + Alltrim(T_STATUS->ZZG_SEQU) + " - " + T_STATUS->ZZG_TITU + CHR(13) + CHR(10)
         Endif   
         
      Else
         
         cMemo2    := cMemo2 + chr(13) + Chr(10)
         Quebra    := T_STATUS->ZZG_PREV
         lPrimeiro := .T.         
         Loop
            
      Endif

      T_STATUS->( DbSkip() )

   ENDDO

   DEFINE MSDIALOG oDlgR TITLE "Relação de Tarefas por Data Prevista de Entrega" FROM C(178),C(181) TO C(592),C(967) PIXEL

   @ C(001),C(001) Jpeg FILE "logoautoma.bmp" Size C(175),C(031) PIXEL NOBORDER OF oDlgR

   @ C(027),C(275) Say "Relação de tarefas por data prevista de entrega" Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(036),C(001) GET oMemo1 Var cMemo1 MEMO Size C(387),C(001) PIXEL OF oDlgR

   @ C(040),C(001) GET oMemo2 Var cMemo2 MEMO Size C(387),C(148) PIXEL OF oDlgR

   @ C(191),C(350) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgR ACTION( oDlgR:End() )

   ACTIVATE MSDIALOG oDlgR CENTERED 

Return(.T.)