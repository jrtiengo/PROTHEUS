#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM584.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 14/06/2017                                                           ##
// Objetivo..: Grava os dados do Contato do Cadastro de Pedido de Venda.            ## 
// ###################################################################################

User Function AUTOM584()

   U_AUTOM628("AUTOM584")

   If Empty(Alltrim(M->C5_ZIDC))
   
      // #######################################
      // Inclui o Contato de Venda - Nível 07 ##
      // #######################################
      Cod_Cnt_VDA := NEWNUMCONT()

      DbSelectArea("SU5")
      RecLock("SU5",.T.)
      U5_FILIAL  := ""
      U5_CODCONT := Cod_Cnt_VDA
      U5_CONTAT  := M->C5_ZCON
      U5_DDD     := M->C5_ZDD1
      U5_FONE    := M->C5_ZTE1
      U5_FCOM1   := M->C5_ZTE2
      U5_EMAIL   := M->C5_ZEMA
      U5_NIVEL   := "07"
      U5_ATIVO   := "1"
      U5_STATUS  := "2"
      U5_TIPO    := "2"
      Msunlock()

      // #######################################
      // Cadastra o Vínculo Contato X Cliente ##
      // #######################################
      DbSelectArea("AC8")
      RecLock("AC8",.T.)
      AC8_FILIAL  := ""
      AC8_FILENT := ""       
      AC8_ENTIDA := "SA1"
      AC8_CODENT := M->C5_CLIENTE + M->C5_LOJACLI
      AC8_CODCON := Cod_Cnt_VDA
      Msunlock()
   
      // ####################################################################################
      // Atualiza o cabeçalho do pedido de venda com o código do contato de venda incluído ##
      // ####################################################################################
      DbSelectArea("SC5")
      DbSetOrder(1)
      DbSeek( IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL) + M->C5_NUM )
      Reclock( "SC5", .F. )
      SC5->C5_ZIDC := Cod_Cnt_VDA
      SC5->( Msunlock() )

      // ##########################################
      // Inclui o Contato de Cobranca - Nível 08 ##
      // ##########################################
      Cod_Cnt_COB := NEWNUMCONT()

      DbSelectArea("SU5")
      RecLock("SU5",.T.)
      U5_FILIAL  := ""
      U5_CODCONT := Cod_Cnt_COB
      U5_CONTAT  := M->C5_ZCON
      U5_DDD     := M->C5_ZDD1
      U5_FONE    := M->C5_ZTE1
      U5_FCOM1   := M->C5_ZTE2
      U5_EMAIL   := M->C5_ZEMA
      U5_NIVEL   := "08"
      U5_ATIVO   := "1"
      U5_STATUS  := "2"
      U5_TIPO    := "3"
      Msunlock()

      // #######################################
      // Cadastra o Vínculo Contato X Cliente ##
      // #######################################
      DbSelectArea("AC8")
      RecLock("AC8",.T.)
      AC8_FILIAL  := ""
      AC8_FILENT := ""       
      AC8_ENTIDA := "SA1"
      AC8_CODENT := M->C5_CLIENTE + M->C5_LOJACLI
      AC8_CODCON := Cod_Cnt_COB
      Msunlock()
      
   Else      

      cSql := ""
      cSql := "UPDATE " + RetSqlName("SU5")
      cSql += "  SET U5_CONTAT  = '" + Alltrim(M->C5_ZCON) + "', "
      cSql += "      U5_DDD     = '" + Alltrim(M->C5_ZDD1) + "', "
      cSql += "      U5_FONE    = '" + Alltrim(M->C5_ZTE1) + "', "
      cSql += "      U5_FCOM1   = '" + Alltrim(M->C5_ZTE2) + "', "
      cSql += "      U5_EMAIL   = '" + Alltrim(M->C5_ZEMA) + "'  "
      cSql += "WHERE U5_CODCONT = '" + Alltrim(M->C5_ZIDC) + "'"
      cSql += "  AND D_E_L_E_T_ = ''"
            
      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif
      
   Endif

Return(.T.)