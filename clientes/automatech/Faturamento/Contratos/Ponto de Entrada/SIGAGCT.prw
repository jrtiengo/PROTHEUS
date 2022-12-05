#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGAGCT.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 30/10/2012                                                          *
// Objetivo..: Ponto de Entrada no login do M�dulo de Contratos.                   *
//**********************************************************************************

User Function SIGAGCT()

   Local cSql := ""
   Local lContrato

   Public _Ativi
   Public _News
   Public _Medicao
   Public _Validacao

   Default _Ativi     := .F.
   Default _News      := .F.
   Default _Medicao   := .F.
   Default _Validacao := .F.

   // Verifica se existem atividades a ser executadas
   If !_Ativi
      U_ATVATI15()
   Endif

   // Verifica a exist�ncia de tarefas a serem validadas
   If !_Validacao
      U_ESPVAL02()
   Endif

   // Verifica se j� foi executada a medi��o para a data base
   If !_Medicao

      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT A.ZZ4_MEDI"
      cSql += "  FROM " + RetSqlName("ZZ4") + " A "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      If Ctod(Substr(T_PARAMETROS->ZZ4_MEDI,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_MEDI,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_MEDI,01,04)) == dDataBase
         Return .T.
      Else

//       MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
//                "Medi��o de Contratos para esta data est� pendente de execu��o." + chr(13) + chr(10) + ;
//                "N�o cancele a execu��o deste procedimento." + chr(13) + chr(10) + ;
//                "Procedimento ser� executado neste momento.")         
  
         _Medicao  := .T.
         lContrato := CNTA260()               

         // Atualiza o Parametrizador
         dbSelectArea("ZZ4")

         If T_PARAMETROS->( EOF() )
            RecLock("ZZ4",.T.)
            ZZ4_FILIAL := cFilAnt
            ZZ4_CODI   := "000001"
            ZZ4_COND   := cCondicao
         Else
            RecLock("ZZ4",.F.)     
            ZZ4_MEDI   := dDataBase
         Endif

         MsUnLock()

      Endif

   Endif   

   // Automatech News
   If !_News
      U_AUTOM171()
   Endif

Return .T.