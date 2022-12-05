#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR21.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/04/2015                                                          *
// Objetivo..: Tela de manutenção do cadastro de reuniões por tarefa.              *
//**********************************************************************************

User Function ESPTAR21(_Operacao, _Tarefa, _Codigo)

   Local lChumba     := .F.

   Private cCodigo	   := _Codigo
   Private cData	   := Date()
   Private cHora	   := Time()
   Private cTarefa	   := _Tarefa
   Private cMemo1	   := ""
   Private cEnvolvidos := ""
   Private cAssunto    := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private oDlgXX

   If _Operacao == "I"
   Else
   
      If Select("T_ALTERACAO") > 0
         T_ALTERACAO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZT7_FILIAL,"
      cSql += "       ZT7_TARE  ,"
      cSql += "       ZT7_SEQU  ,"
      cSql += "       ZT7_CODI  ,"
      cSql += "       ZT7_DATA  ,"
      cSql += "       ZT7_HORA  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT7_ENVO)) AS ENVOLVIDOS,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT7_ASSU)) AS ASSUNTOS  ,"
      cSql += "       ZT7_DELE   "
      cSql += "  FROM " + RetSqlName("ZT7")
      cSql += " WHERE ZT7_TARE = '" + Alltrim(Substr(_Tarefa,01,06)) + "'"
      cSql += "   AND ZT7_SEQU = '" + Alltrim(Substr(_Tarefa,08,02)) + "'"
      cSql += "   AND ZT7_CODI = '" + Alltrim(_Codigo)               + "'"
      cSql += "   AND ZT7_DELE = ''"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALTERACAO", .T., .T. )
   
      If T_ALTERACAO->( EOF() )
         cCodigo     := _Codigo
         cData	     := Date()
         cHora	     := Time()
         cTarefa     := _Tarefa
         cEnvolvidos := ""
         cAssunto    := ""
      Else
         cCodigo     := _Codigo
         cData	     := T_ALTERACAO->ZT7_DATA
         cHora	     := T_ALTERACAO->ZT7_HORA
         cTarefa     := _Tarefa
         cEnvolvidos := T_ALTERACAO->ENVOLVIDOS
         cAssunto    := T_ALTERACAO->ASSUNTOS
      Endif
      
   Endif

   // Desenha atela de visualização
   DEFINE MSDIALOG oDlgXX TITLE "Controle de Reuniões" FROM C(178),C(181) TO C(564),C(663) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgXX

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(234),C(001) PIXEL OF oDlgXX

   @ C(037),C(005) Say "Código"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(037),C(034) Say "Data"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(037),C(076) Say "Hora"                  Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(059),C(005) Say "Envolvidos na Reunião" Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(094),C(005) Say "Assunto Abordado"      Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(037),C(205) Say "Tarefa"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
      
   @ C(046),C(005) MsGet oGet1  Var cCodigo          Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX When lChumba
   @ C(046),C(034) MsGet oGet2  Var cData            Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX 
   @ C(046),C(076) MsGet oGet3  Var cHora            Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX
   @ C(046),C(205) MsGet oGet4  Var cTarefa          Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX When lChumba
   @ C(068),C(005) GET   oMemo2 Var cEnvolvidos MEMO Size C(231),C(024)                              PIXEL OF oDlgXX
   @ C(103),C(005) GET   oMemo3 Var cAssunto    MEMO Size C(231),C(069)                              PIXEL OF oDlgXX

   @ C(176),C(160) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgXX ACTION( GrvReuniao(_Operacao) )
   @ C(176),C(199) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgXX ACTION( oDlgXX:End() )

   ACTIVATE MSDIALOG oDlgXX CENTERED 

Return(.T.)

// Função que grava os dados da reunião
Static Function GrvReuniao(_Operacao)

   // Inclusão
   If _Operacao == "I"

      // Pesquisa o próximo código para inclusão
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT MAX(ZT7_CODI) AS PROXIMO"
      cSql += "  FROM " + RetSqlName("ZT7")
      cSql += " WHERE ZT7_DELE = ''"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         nCodigoR := "000001"
      Else
         nCodigoR := Strzero(INT(VAL(T_PROXIMO->PROXIMO)) + 1,6)
      Endif

      // Grava dados da reunião
      DbSelectArea("ZT7")
      RecLock("ZT7",.T.)
      ZT7_FILIAL := ""
      ZT7_TARE   := Substr(cTarefa,01,06)
      ZT7_SEQU   := Substr(cTarefa,08,02)
      ZT7_CODI   := nCodigoR
      ZT7_DATA   := cData
      ZT7_HORA   := cHora
      ZT7_ENVO   := cEnvolvidos
      ZT7_ASSU   := cAssunto
      ZT7_DELE   := ""
      MsUnLock()  
      
   Endif

   // Alteração
   If _Operacao == "A"

      // Grava a regra na tabela de tarefas
      DbSelectArea("ZT7")
      DbSetOrder(1)
      If DbSeek(xfilial("ZT7") + Substr(cTarefa,01,06) + Substr(cTarefa,08,02))
         RecLock("ZT7",.F.)
         ZT7_ENVO   := cEnvolvidos
         ZT7_ASSU   := cAssunto
         MsUnLock()              
      Endif
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZT7")
         DbSetOrder(1)
         If DbSeek(xfilial("ZT7") + Substr(cTarefa,01,06) + Substr(cTarefa,08,02))
            RecLock("ZT7",.F.)
            ZT7_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   oDlgXX:End() 

Return(.T.)   
