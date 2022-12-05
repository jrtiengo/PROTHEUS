#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_UTILCARRO.PRW                                                    ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 11/12/2016                                                          ##
// Objetivo..: Web Service que trata utilização de veículo pelo App At Automatech  ##
// Parâmetros: cParametros                                                         ##
//             01 - Empresa                                                        ##
//             02 - Filial                                                         ##
//             03 - Código do Técnico                                              ##
//             04 - Nº de Controle                                                 ##
//             05 - Data (Utilização/Devolução)                                    ##
//             06 - KM (Utilização/Devolução)                                      ##
//             07 - Operacao                                                       ##
//                  0 - Pesquisa se existe registro em aberto para o técnico       ##
//                  1 - Salva a KM de utilização do veículo                        ##
//                  2 - Salva a KM de devolução do veículo                         ##
// ##################################################################################
WSRESTFUL AT_UTILCARRO DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_UTILCARRO || /AT_UTILCARRO/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_UTILCARRO

   Local cSql      := ""
   Local cRetorno  := ""
   Local cString   := ""
   Local xControle := ""

   Local cCodEmp  := U_P_CORTA(Self:cCodPar, "|", 01) 
   Local cCodFil  := U_P_CORTA(Self:cCodPar, "|", 02) 
   Local cCodTec  := U_P_CORTA(Self:cCodPar, "|", 03) 
   Local cCodCon  := U_P_CORTA(Self:cCodPar, "|", 04) 
   Local cDataKM  := U_P_CORTA(Self:cCodPar, "|", 05) 
   Local cKMCarro := U_P_CORTA(Self:cCodPar, "|", 06) 
   Local cCodOpe  := U_P_CORTA(Self:cCodPar, "|", 07) 

   Conout("Codigo da Empresa...: " + cCodEmp)
   Conout("Codigo da Filial....: " + cCodFil) 
   Conout("Codigo do Tecnico...: " + cCodTec)
   Conout("Codigo de Controle..: " + cCodCon)
   Conout("Data KM ............: " + cDataKM)
   Conout("KM .................: " + cKMCarro)
   Conout("Operacao............: " + cCodOpe)

   // #######################################################################################
   // Pesquisa se existe registro de empréstimo de veículo em aberto para a Filial/Técnico ##
   // #######################################################################################
   If cCodOpe == "0"

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTT.ZTT_FILIAL," 
      cSql += "	      ZTT.ZTT_CONT  ,"
      cSql += "       ZTT.ZTT_TECN  ,"
      cSql += "       ZTT.ZTT_PLACA ,"
      cSql += "	      ZTT.ZTT_DINI  ,"
      cSql += "       SUBSTRING(ZTT.ZTT_DINI,07,02) + '/' + SUBSTRING(ZTT.ZTT_DINI,05,02) + '/' + SUBSTRING(ZTT.ZTT_DINI,01,04) AS DTA_EMPRESTIMO,"
      cSql += "	      ZTT.ZTT_HINI  ,"
      cSql += "	      ZTT.ZTT_DUTI  ,"
      cSql += "       SUBSTRING(ZTT.ZTT_DUTI,07,02) + '/' + SUBSTRING(ZTT.ZTT_DUTI,05,02) + '/' + SUBSTRING(ZTT.ZTT_DUTI,01,04) AS DTA_UTILIZACAO,"
      cSql += "	      ZTT.ZTT_HUTI  ,"
      cSql += "	      ZTT.ZTT_DFIM  ,"
      cSql += "       SUBSTRING(ZTT.ZTT_DFIM,07,02) + '/' + SUBSTRING(ZTT.ZTT_DFIM,05,02) + '/' + SUBSTRING(ZTT.ZTT_DFIM,01,04) AS DTA_DEVOLUCAO,"
      cSql += "	      ZTT.ZTT_HFIM  ,"      
      cSql += "	      ZTT.ZTT_KINI  ,"
      cSql += "	      ZTT.ZTT_KFIM  ,"
      cSql += "	      ZTT.ZTT_KTOT  ,"
      cSql += "       ZTT.ZTT_DELE  ,"
      cSql += "       AA1.AA1_NOMTEC "

      Do Case
         Case Alltrim(cCodEmp) == "01"
              cSql += "  FROM ZTT010 ZTT, "
              cSql += "      " + RetSqlName("AA1") + " AA1 "              
         Case Alltrim(cCodEmp) == "02"
              cSql += "  FROM ZTT020 ZTT, "
              cSql += "      " + RetSqlName("AA1") + " AA1 "              
         Case Alltrim(cCodEmp) == "03"
              cSql += "  FROM ZTT030 ZTT, "
              cSql += "      " + RetSqlName("AA1") + " AA1 "              
      EndCase

      cSql += " WHERE ZTT.ZTT_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZTT.ZTT_TECN   = '" + Alltrim(cCodTec) + "'"
      cSql += "   AND ZTT.ZTT_KTOT   =  " + Alltrim(Str(0))  
      cSql += "   AND ZTT.ZTT_DELE   = ''"
      cSql += "   AND AA1.AA1_CODTEC = ZTT.ZTT_TECN"
      cSql += "   AND AA1.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
      
      If T_CONSULTA->( EOF() )
         cString := "9|Não existe veículo disponível para utilização para este técnico.|#"
      Else
      
         cString := "0"                                   + "|" + ; // 01
                    T_CONSULTA->AA1_NOMTEC                + "|" + ; // 02
                    T_CONSULTA->ZTT_PLACA                 + "|" + ; // 03
                    T_CONSULTA->DTA_EMPRESTIMO            + "|" + ; // 04
                    T_CONSULTA->ZTT_HINI                  + "|" + ; // 05
                    T_CONSULTA->DTA_UTILIZACAO            + "|" + ; // 06
                    Alltrim(Str(T_CONSULTA->ZTT_KINI,10)) + "|" + ; // 07
                    T_CONSULTA->DTA_DEVOLUCAO             + "|" + ; // 08
                    Alltrim(Str(T_CONSULTA->ZTT_KFIM,10)) + "|" + ; // 09
                    T_CONSULTA->ZTT_CONT                  + "|#"    // 10
                                                                    
      Endif
      
   Endif

   // #######################################################
   // Reliza a gravação dos dadso de utilização de veículo ##
   // #######################################################
   If cCodOpe == "1"

      xDataKM := cDataKM + "/"
      xDiaKM  := Strzero(Int(Val(U_P_CORTA(xDataKM, "/", 1))),2)
      xMesKM  := Strzero(Int(Val(U_P_CORTA(xDataKM, "/", 2))),2)
      xAnoKM  := Strzero(Int(Val(U_P_CORTA(xDataKM, "/", 3))),4)

      xDtaIni := Ctod(xDiaKM + "/" + xMesKM + "/" + xAnoKM)

      // ################################################
      // Altera o registro conforme código de controle ##
      // ################################################
      cSql := ""      
      Do Case
         Case cCodEmp == "01"
              cSql := "UPDATE ZTT010 "
         Case cCodEmp == "02"
              cSql := "UPDATE ZTT020 "
         Case cCodEmp == "03"
              cSql := "UPDATE ZTT030 "
      EndCase           

      cSql += "  SET "
      cSql += "      ZTT_DUTI = '" + Dtoc(xDtaIni)        + "',"
      cSql += "      ZTT_HUTI = '" + Substr(Time(),01,05) + "',"
      cSql += "      ZTT_KINI =  " + Str(INT(VAL(cKMCarro)))
 	  cSql += "WHERE ZTT_FILIAL  = '" + Alltrim(cCodFil) + "'"
      cSql += "  AND ZTT_CONT    = '" + Alltrim(cCodCon) + "'"

   	  If TcSqlExec(cSql) < 0
         cString := "9|999999|"
	  Else
         cString := "0|OK|"
      Endif

   Endif

   // #######################################################
   // Reliza a gravação dos dadso de utilização de veículo ##
   // #######################################################
   If cCodOpe == "2"

      xDataKM := cDataKM + "/"
      xDiaKM  := Strzero(Int(Val(U_P_CORTA(xDataKM, "/", 1))),2)
      xMesKM  := Strzero(Int(Val(U_P_CORTA(xDataKM, "/", 2))),2)
      xAnoKM  := Strzero(Int(Val(U_P_CORTA(xDataKM, "/", 3))),4)

      xDtaFim := Ctod(xDiaKM + "/" + xMesKM + "/" + xAnoKM)

      // #################################################
      // Pesquisa a KM Inicial para calcular a KM final ##
      // #################################################
      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTT.ZTT_KINI  "

      Do Case
         Case Alltrim(cCodEmp) == "01"
              cSql += "  FROM ZTT010 ZTT (Nolock) "
         Case Alltrim(cCodEmp) == "02"
              cSql += "  FROM ZTT020 ZTT (NoLock) "
         Case Alltrim(cCodEmp) == "03"
              cSql += "  FROM ZTT030 ZTT (NoLock) "
      EndCase

      cSql += " WHERE ZTT.ZTT_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZTT.ZTT_TECN   = '" + Alltrim(cCodTec) + "'"
      cSql += "   AND ZTT.ZTT_CONT   = '" + Alltrim(cCodCon) + "'"
      cSql += "   AND ZTT.ZTT_DELE   = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      If T_CONSULTA->( EOF() )
         nKMInicial := 0
      Else
         nKMInicial := T_CONSULTA->ZTT_KINI
      Endif
      
      nKMTotal := INT(VAL(cKMCarro))  - nKMInicial

      // ################################################
      // Altera o registro conforme código de controle ##
      // ################################################
      cSql := ""      
      Do Case
         Case cCodEmp == "01"
              cSql := "UPDATE ZTT010 "
         Case cCodEmp == "02"
              cSql := "UPDATE ZTT020 "
         Case cCodEmp == "03"
              cSql := "UPDATE ZTT030 "
      EndCase           

      cSql += "  SET "
      cSql += "       ZTT_DFIM = '" + Dtoc(xDtaFim)           + "',"
      cSql += "       ZTT_HFIM = '" + Substr(Time(),01,05)    + "',"
      cSql += "       ZTT_KFIM =  " + Str(INT(VAL(cKMCarro))) + " ,"
      cSql += "       ZTT_KTOT =  " + Str(nKMTotal)
 	  cSql += " WHERE ZTT_FILIAL  = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZTT_CONT    = '" + Alltrim(cCodCon) + "'"

   	  If TcSqlExec(cSql) < 0
         cString := "9|999999|"
	  Else
         cString := "0|OK|"
      Endif

   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)