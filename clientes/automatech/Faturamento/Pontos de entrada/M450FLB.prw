#include "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M450FLB.PRW                                                         ##
// Par�metros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Cesar Mussi                                                         ##
// Data......: 21/08/2015                                                          ##
// Objetivo..: Tratamento do BLCRED =06 no filtro da lib pedidos                   ##
// Par�metros: Sem Par�metros                                                      ##
// ##################################################################################

User Function M450FLB()

   Local _cret := ""
   Local cSql  := ""
   
   U_AUTOM628("M450FLB")

   // #############################################################################
   // Verifica se o usu�rio possui permiss�o para realizar an�lise de cr�dito.   ##
   // Se tiver, verifica quais as condi��es de pagamentos que ele pode analisar. ##
   // Se todas ou determinadas condi��es de pagamentos.                          ## 
   // #############################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LCRE1,"
   cSql += "       ZZ4_LCRE2 "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   
   If T_PARAMETROS->( EOF() )
      cString := ""
   Else
      cString := Alltrim(T_PARAMETROS->ZZ4_LCRE1) + Alltrim(T_PARAMETROS->ZZ4_LCRE2)   
   Endif
 
   nVezes := U_P_OCCURS(cString, "|", 1)

   // ##################################
   // Se n�o houve par�metros setados ##
   // ##################################
   If nVezes == 0
      MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "N�o existem par�metros configurados para an�lise de cr�dito." + chr(13) + chr(10) + "Entre em contato com o administrador do sistema.")
      _cret := "C9_FILIAL == '" + xFilial("SC9") + "' .And. (C9_BLCRED=='XX' .or. C9_BLCRED=='YY' .or. C9_BLCRED == 'ZZ' )"  
      Return(_cRet)   
   Endif
   





   
   

   If ( mv_par01 == 1 )
      _cret := "C9_FILIAL == '" + xFilial("SC9") + "' .And. (C9_BLCRED=='01' .or. C9_BLCRED=='04' .or. C9_BLCRED == '06' )"  
   ElseIf (mv_par01 == 3)
      _cret := "C9_FILIAL == '" + xFilial("SC9") + "' .And. (C9_BLCRED=='01' .or. C9_BLCRED=='04' .or. C9_BLCRED == '06' .or. C9_BLCRED == '09' )"  
   Endif

Return(_cRet)