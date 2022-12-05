#INCLUDE "PROTHEUS.CH"

//************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             *
// --------------------------------------------------------------------------------- *
// Referencia: A010TOK.PRW                                                           *
// Parâmetros: Nenhum                                                                *
// Tipo......: ( ) Programa  ( ) Gatilho  ( X ) Ponto de Entrada                     *
// --------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                               *
// Data......: 05/01/2016                                                            *
// Objetivo..: Ponto de Entrada que valida o cadastro de produtos antes da gravação  *
//             1º) Verifica se existe saldo na Companhia antes de permitir a inati-  *
//                 vação do produto.                                                 *
//************************************************************************************

User Function A010TOK()
 
   Local cSql      := ""
   Local lExecuta  := .T. 
   Local cSql      := ""
   Local nSaldo_01 := 0
   Local nSaldo_02 := 0
   Local nSaldo_03 := 0   
   Local lMostra   := .F.

   U_AUTOM628("A010TOK")

   // ####################################################################################
   // Consiste os dados de volumetria do produto para cálculo de volume para o SIMFRETE ##
   // ####################################################################################
   If !M->B1_EMBA$("0#1#2#3#4#5#6#7")
      MsgAlert("Atenção! Tipo de embalagem do produto não informada. Verifique!")
      Return(.F.)
   Else

      Do Case
      
         Case M->B1_EMBA == "0"

              Return(.T.)

         Case M->B1_EMBA == "1"

              If M->B1_LARG == 0; lMostra := .T.; Endif
              If M->B1_ALTU == 0; lMostra := .T.; Endif
              If M->B1_COMP == 0; lMostra := .T.; Endif

              If lMostra == .T.
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Largura, Altura e Comprimento do produto não informado para o tipo de embalagem CUBO." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
                 Return(.F.)
              Endif
                 
         Case M->B1_EMBA == "2"

              If M->B1_LARG == 0; lMostra := .T.; Endif
              If M->B1_ALTU == 0; lMostra := .T.; Endif
              If M->B1_COMP == 0; lMostra := .T.; Endif

              If lMostra == .T.
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Largura, Altura e Comprimento do produto não informado para o tipo de embalagem RETÂNGULO." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
                 Return(.F.)
              Endif
                 
         Case M->B1_EMBA == "3"

              If M->B1_ALTU == 0; lMostra := .T.; Endif
              If M->B1_RAIO == 0; lMostra := .T.; Endif

              If lMostra == .T.
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Raio do produto não informado para o tipo de embalagem CILINDRO." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
                 Return(.F.)
              Endif
                  
         Case M->B1_EMBA == "4"

              If M->B1_ALTU == 0; lMostra := .T.; Endif
              If M->B1_ZBAS == 0; lMostra := .T.; Endif

              If lMostra == .T.
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Base do produto não informado para o tipo de embalagem PRISMA." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
                 Return(.F.)
              Endif
   
         Case M->B1_EMBA == "5"

              If M->B1_ALTU == 0; lMostra := .T.; Endif
              If M->B1_LADO == 0; lMostra := .T.; Endif

              If lMostra == .T.
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Lado do produto não informado para o tipo de embalagem PIRAMIDE" + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
                 Return(.F.)
              Endif
   
         Case M->B1_EMBA == "6"
              
              If M->B1_ALTU == 0; lMostra := .T.; Endif
              If M->B1_RAIO == 0; lMostra := .T.; Endif

              If lMostra == .T.
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura e Raio do produto não informado para o tipo de embalagem CONE." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
                 Return(.F.)
              Endif
   
         Case M->B1_EMBA == "7"

              If M->B1_RAIO == 0; lMostra := .T.; Endif

              If lMostra == .T.
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Raio do produto não informado para o tipo de embalagem ESFERA." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
                 Return(.F.)
              Endif

      EndCase        
   
   Endif

   // ##############################################################
   // Verifica se o produto pertence ao grupo de produtos da AST. ##
   // Se for, verifica se a descrição B1_GDES foi informada.      ##
   // ##############################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GDES FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If Empty(Alltrim(T_PARAMETROS->ZZ4_GDES))
   Else
      If U_P_OCCURS(T_PARAMETROS->ZZ4_GDES, M->B1_GRUPO, 1) == 1
         If Empty(Alltrim(M->B1_GDES))
            MsgAlert("Descrição do produto para Assistência Técnica não preenchido na última aba do cadastro.")
            lExecuta  := .F. 
            Return(lExecuta)
         Endif   
      Endif
   Endif

   // ######################################################
   // Se for inclusão de produtos, despreza a verificação ##
   // ######################################################
   If Inclui == .T.
      Return(lExecuta)
   Endif

   // ###################################################################
   // Verifica se tem saldo na Empresa 01 - Autuomatech Automação Ltda ##
   // ###################################################################
   If (Select( "T_SALDO01" ) != 0 )
      T_SALDO01->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SUM((B2_QATU    + "
   cSql += "            B2_QPEDVEN + "
   cSql += "            B2_QEMPSA  + "
   cSql += "            B2_QNPT    + "
   cSql += "            B2_QEMPN   + "
   cSql += "            B2_QEMPPRJ + "
   cSql += "            B2_QEMP    + "
   cSql += "            B2_SALPEDI + "
   cSql += "            B2_RESERVA + "
   cSql += "            B2_QTNP    + "
   cSql += "            B2_QTER    + "
   cSql += "            B2_QACLASS + "
   cSql += "            B2_QEMPPRE)) AS SALDO_01"
   cSql += "  FROM SB2010"
   cSql += " WHERE B2_COD = '" + Alltrim(M->B1_COD) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDO01",.T.,.T.)

   nSaldo_01 := IIF(T_SALDO01->( EOF() ), 0, T_SALDO01->SALDO_01)

   // #####################################################
   // Verifica se tem saldo na Empresa 02 - TI Automação ##
   // #####################################################
   If (Select( "T_SALDO02" ) != 0 )
      T_SALDO02->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SUM((B2_QATU    + "
   cSql += "            B2_QPEDVEN + "
   cSql += "            B2_QEMPSA  + "
   cSql += "            B2_QNPT    + "
   cSql += "            B2_QEMPN   + "
   cSql += "            B2_QEMPPRJ + "
   cSql += "            B2_QEMP    + "
   cSql += "            B2_SALPEDI + "
   cSql += "            B2_RESERVA + "
   cSql += "            B2_QTNP    + "
   cSql += "            B2_QTER    + "
   cSql += "            B2_QACLASS + "
   cSql += "            B2_QEMPPRE)) AS SALDO_02"
   cSql += "  FROM SB2020"
   cSql += " WHERE B2_COD = '" + Alltrim(M->B1_COD) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDO02",.T.,.T.)

   nSaldo_02 := IIF(T_SALDO02->( EOF() ), 0, T_SALDO02->SALDO_02)

   // ##############################################
   // Verifica se tem saldo na Empresa 03 - Atech ##
   // ############################################## 
   If (Select( "T_SALDO03" ) != 0 )
      T_SALDO03->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SUM((B2_QATU    + "
   cSql += "            B2_QPEDVEN + "
   cSql += "            B2_QEMPSA  + "
   cSql += "            B2_QNPT    + "
   cSql += "            B2_QEMPN   + "
   cSql += "            B2_QEMPPRJ + "
   cSql += "            B2_QEMP    + "
   cSql += "            B2_SALPEDI + "
   cSql += "            B2_RESERVA + "
   cSql += "            B2_QTNP    + "
   cSql += "            B2_QTER    + "
   cSql += "            B2_QACLASS + "
   cSql += "            B2_QEMPPRE)) AS SALDO_03"
   cSql += "  FROM SB2030"
   cSql += " WHERE B2_COD = '" + Alltrim(M->B1_COD) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDO03",.T.,.T.)

   nSaldo_03 := IIF(T_SALDO03->( EOF() ), 0, T_SALDO03->SALDO_03)

   If M->B1_MSBLQL == "1"
      If (nSaldo_01 + nSaldo_02 + nSaldo_03) <> 0
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Produto não poderá ser inativado porque o mesmo ainda possui saldo na Companhia. Verifique!")
         lExecuta := .F.
      Endif
   Endif
   
Return (lExecuta)