#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOMR29.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  (X) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 18/11/2011                                                          ##
// Objetivo..: Gatilho que verifica se o cliente informado na oportunidade e       ##
//             no pedido de venda possuem Contato Vinculado.                       ##
// Parãmetros: _Cliente -> Código do Cliente                                       ##
//             _Loja    -> Código da Loja                                          ##
//             _Tipo    -> 1 - Oportunidade                                        ##
//                         2 - Pedido de Venda                                     ##
// ################################################################################## 

User Function AUTOMR29( _Cliente, _Loja, _Tipo)

   Local cSql      := ""
   Local kkContato := ""

   U_AUTOM628("AUTOMR29")

   If Empty(_Cliente)   
      Return ""
   Endif
   
   // ##########################################################################
   // Não executar mais. Tudo é feito no final da gravação do pedido de venda ##
   // ##########################################################################
   Return _Loja

   // ###########################################################
   // Verifica se o cliente informado possui contato vinculado ##
   // ###########################################################
   If Select("T_CONTATO") > 0
      T_CONTATO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AC8_CODCON "
   cSql += "  FROM " + RetSqlName("AC8010")
   cSql += " WHERE AC8_CODENT   = '" + Alltrim(_Cliente) + Alltrim(_Loja) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"         

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )

   DbSelectArea("T_CONTATO")

   If EOF()

	  If MsgYesNo("ATENÇÃO!"                                                                     + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Cliente informado não possui indicação de Contato cadastrado."                + chr(13) + chr(10) + ;
                  "Necessário cadastrar um contato vinculado a este cliente antes de continuar." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Deseja cadastrar o contato agora?")
        
         kkContato := ""
         kkContato := U_AUTOM682(_Cliente, _Loja, POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja,"A1_NOME") )
         
         If Empty(Alltrim(kkContato))
         
            If _Tipo == 1
               AD1_CODCLI := Space(06)
               AD1_NOMCLI := Space(40)
               Return ""
            Else
               C5_CLIENTE := Space(06)
               C5_NOMCL   := Space(40)
               Return ""
            Endif
            
         Else
         
            If _Tipo == 1
               Return ""
            Else
               M->C5_ZIDC := U_P_CORTA(kkContato, "|", 01)
               M->C5_ZCON := U_P_CORTA(kkContato, "|", 02)
               M->C5_ZEMA := U_P_CORTA(kkContato, "|", 03)
               M->C5_ZDD1 := U_P_CORTA(kkContato, "|", 04)
               M->C5_ZTE1 := U_P_CORTA(kkContato, "|", 05)
               M->C5_ZTE2 := U_P_CORTA(kkContato, "|", 06)
               Return _Loja
            Endif
            
         Endif

      Else   

         If _Tipo == 1
            AD1_CODCLI := Space(06)
            AD1_NOMCLI := Space(40)
            Return ""
         Else
            C5_CLIENTE := Space(06)
            C5_NOMCL   := Space(40)
            Return ""
         Endif
         
      Endif

   Endif

Return _Loja