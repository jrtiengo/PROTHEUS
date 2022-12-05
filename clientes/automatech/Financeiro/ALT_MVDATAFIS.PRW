#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// Alteração do parametro MV_DATAFIS - Data de fechamento do módulo fiscal
//************************************************************************
User Function ALT_MVDATAFIS() 

   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local lChumba    := .F.

   Local oMemo1
   Local oMemo2

   Private cDataAtual := Ctod("  /  /    ")
   Private cDataNova  := Ctod("  /  /    ")

   Private oGet1
   Private oGet2

   Private oDlg

   // ##########################################################
   // Pesquisa os usuários que possuem acesso a este programa ##
   // ##########################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_XFIN, ZZ4_XFIS FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_XFIS))
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif
   
   If U_P_OCCURS(T_PARAMETROS->ZZ4_XFIS, UPPER(ALLTRIM(cUserName)), 1 ) == 0 
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif

   // Pesquisa a data atual do parâmetro MV_DATAFIS
   cDataAtual := Dtoc(getmv("MV_DATAFIS"))
   cDataNova  := Dtoc(getmv("MV_DATAFIS"))

   DEFINE MSDIALOG oDlg TITLE "Alteração parâmetro fechameto fiscal" FROM C(178),C(181) TO C(437),C(455) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(129),C(001) PIXEL OF oDlg
   @ C(104),C(003) GET oMemo2 Var cMemo2 MEMO Size C(129),C(001) PIXEL OF oDlg

   @ C(042),C(005) Say "Informe a data do Fechamento de Movimentações Fiscais" Size C(140),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(045) Say "Data de Fechamento Atual"                              Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(045) Say "Nova Data de Fechamento"                               Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(066),C(050) MsGet oGet1 Var cDataAtual Size C(042),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
   @ C(089),C(050) MsGet oGet2 Var cDataNova  Size C(042),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg

   @ C(111),C(030) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( GrvVariavel() )
   @ C(111),C(069) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava a informação da data no parâmetro MV_DATAFIN
Static Function GrvVariavel()

   // Valida se a nova data foi informada
   If Empty(cDataNova) .OR. cDataNova == "  /  /    "
      MsgAlert("Data não informada.")
      Return(.T.)
   Endif
      
   If Alltrim(__cUserID) == "000000"
   Else
      If Ctod(cDataNova) < Ctod(cDataAtual)
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada não pode ser menor que a data anterior. Verifique!")
         Return(.T.)
      Endif

      If Ctod(cDataNova) > Date()     
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada somente poderá ser entre " + cDataNova + " e " + Dtoc(Date()) + ". Verifique!")
         Return(.T.)
      Endif               

   Endif   

   // Grava a nova data
   putmv("MV_DATAFIS",Substr(cDataNova,07,04) + Substr(cDataNova,04,02) + Substr(cDataNova,01,02))

   oDlg:End()
   
Return(.T.)