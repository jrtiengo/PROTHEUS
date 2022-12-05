#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGAFIN.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 25/01/2012                                                          *
// Objetivo..: Ponto de Entrada que verifica se deve ser aberto a tela de estatis- *
//             tica de cobran�a.                                                   *
//**********************************************************************************

User Function SIGAFIN()

   Local cSql    := ""
   Local cCodigo := RetCodUsr()

   Public _Intermediacao
   Public _VeMensagem
   Public _Rodar
   Public _Rodar1
   Public _Rodar2
   Public _RodaCont
   Public _News
   Public _Ativi
   Public _Medicao
   Public _Validacao

   Default _Intermediacao := .F.
   Default _VeMensagem    := .F.
   Default _Rodar         := .F.
   Default _Rodar1        := .F.
   Default _Rodar2        := .F.                           
   Default _RodaCont      := .F.                           
   Default _News          := .F.
   Default _Ativi         := .F.                           
   Default _Medicao       := .F.
   Default _Validacao     := .F.

   // #########################################################
   // Bloqueia produtos que deixaram de ser de intermedia��o ##
   // #########################################################
   If !_Intermediacao
      U_AUTOM689()
   Endif

   // Prothelito News
   If _VeMensagem
   Else
      U_AUTOM338()
   Endif

   // Verifica a exist�ncia de oiportunidades aguardando libera��o de contrato de loca��o
   If _RodaCont
   Else
      U_AUTOM255()
   Endif

   // Verifica a exist�ncia de tarefas a serem validadas
   If _Validacao
   Else
      U_ESPVAL02()
   Endif

   // Verifica se o usu�rio que se logou � cobrador
   If Select("T_COBRADOR") > 0
      T_COBRADOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT U7_COD    ,"
   cSql += "       U7_CODUSU ,"
   cSql += "       U7_TIPOATE,"
   cSql += "       U7_TIPO    "
   cSql += "  FROM " + RetSqlName("SU7") 
   cSql += " WHERE U7_CODUSU  = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND U7_TIPOATE = '3'"
   cSql += "   AND U7_TIPO    = '1'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COBRADOR", .T., .T. )

   If !T_COBRADOR->( EOF() ) .AND. !_Rodar
      U_AUTOMR84(T_COBRADOR->U7_COD)
   Endif

   // Mostra grid com as NCC de Clientes
   If (cCodigo == "000086" .OR. cCodigo == "000099") .AND. !_Rodar1
      U_AUTOM106()
   Endif   

   If cCodigo == "000029" .AND. !_Rodar2
      U_AUTOM107()
   Endif   
          
   // Verifica se existem atividades pendentes de execu��o
   If _Ativi
   Else
      U_ATVATI15()
   Endif

   // Verifica se j� foi executada a medi��o para a data base
//   If !_Medicao
//
//      If Select("T_PARAMETROS") > 0
//         T_PARAMETROS->( dbCloseArea() )
//      EndIf
//   
//      cSql := ""
//      cSql := "SELECT A.ZZ4_MEDI"
//      cSql += "  FROM " + RetSqlName("ZZ4") + " A "
//
//      cSql := ChangeQuery( cSql )
//      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
//
//      If Ctod(Substr(T_PARAMETROS->ZZ4_MEDI,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_MEDI,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_MEDI,01,04)) == dDataBase
//         Return .T.
//      Else
//         MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
//                  "Medi��o de Contratos para esta data est� pendente de execu��o." + chr(13) + chr(10) + ;
//                  "N�o cancele a execu��o deste procedimento." + chr(13) + chr(10) + ;
//                  "Procedimento ser� executado neste momento.")         
//         _Medicao := .T.
//         lContrato := CNTA260()               
//
//         // Atualiza o Parametrizador
//         dbSelectArea("ZZ4")
//
//         If T_PARAMETROS->( EOF() )
//            RecLock("ZZ4",.T.)
//            ZZ4_FILIAL := cFilAnt
//            ZZ4_CODI   := "000001"
//            ZZ4_COND   := cCondicao
//         Else
//            RecLock("ZZ4",.F.)     
//            ZZ4_MEDI   := dDataBase
//         Endif
//
//         MsUnLock()
//
//      Endif
//
//   Endif   

   // Automatech News
   If _News
   Else
      U_AUTOM171()
   Endif

Return .F.