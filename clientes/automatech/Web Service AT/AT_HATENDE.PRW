#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_HATENDE.PRW                                                      ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 08/12/2016                                                          ##
// Objetivo..: Web Service que trata horas trabalhadas por ordem de serviço        ##
// Parâmetros: cParametros                                                         ##
//             01 - Filial                                                         ##
//             02 - Ordem de Serviço                                               ##
//             03 - Técnico                                                        ##
//             04 - Operação                                                       ##
//                  I - Inclusão                                                   ##
//                  A - Alteração                                                  ##
//                  E - Exclusão                                                   ##
//                  V - Visualização                                               ##
//             05 - Data Inicial                                                   ##
//             06 - Hora Inicial                                                   ##
//             07 - Data Final                                                     ##
//             08 - Hora Final                                                     ##
//             09 - Nº do Controle                                                 ##
//             10 - Empresa                                                        ##
//             11 - 0 = Pesquisa para a Lista                                      ##
//                  1 = Pesquisa para Detalhe                                      ##
//                  2 = Pesquisa o total de horas para a tela principal            ##
// ##################################################################################
WSRESTFUL AT_HATENDE DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_HATENDE || /AT_HATENDE/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_HATENDE

   Local cSql      := ""
   Local cRetorno  := ""
   Local cString   := ""
   Local xControle := ""

   Local cCodFil  := U_P_CORTA(Self:cCodPar, "|", 01) 
   Local cCodOrd  := U_P_CORTA(Self:cCodPar, "|", 02) 
   Local cCodTec  := U_P_CORTA(Self:cCodPar, "|", 03) 
   Local cCodOpe  := U_P_CORTA(Self:cCodPar, "|", 04) 
   Local cDtaIni  := U_P_CORTA(Self:cCodPar, "|", 05) 
   Local cHorIni  := U_P_CORTA(Self:cCodPar, "|", 06) 
   Local cDtaFim  := U_P_CORTA(Self:cCodPar, "|", 07) 
   Local cHorFim  := U_P_CORTA(Self:cCodPar, "|", 08) 
   Local cCodCon  := U_P_CORTA(Self:cCodPar, "|", 09) 
   Local cCodEmp  := U_P_CORTA(Self:cCodPar, "|", 10) 
   Local cVisual  := U_P_CORTA(Self:cCodPar, "|", 11) 

   Private cHorTot  := "  : ""

   // #######################
   // Inclusão do Registro ##
   // #######################
   If cCodOpe == "I"

      cString := ""
      cString := "9|999999|"

      // #################################################################
      // Pesquisa o próximo código de controle para realizar a inclusão ##
      // #################################################################
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT TOP(1) ZTU_CONT"
      cSql += "  FROM " + RetSqlName("ZTU")
      cSql += " WHERE ZTU_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZTU_DELE   = '' "
      cSql += " ORDER BY ZTU_CONT DESC"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      xControle := IIF(T_PROXIMO->( EOF() ), "000001", Strzero((INT(VAL(T_PROXIMO->ZTU_CONT)) + 1),6))

      cDtaIni := Substr(Dtoc(Date()),01,02) + "/" + Substr(Dtoc(Date()),04,02) + "/" + Substr(Dtoc(Date()),07,04)
      
      dbSelectArea("ZTU")
      RecLock("ZTU",.T.)
      ZTU_FILIAL := cCodFil
      ZTU_CONT   := xControle
      ZTU_NUMOS  := cCodOrd
      ZTU_TECN   := cCodTec
      ZTU_DINI   := Ctod(cDtaIni)
      ZTU_HINI   := Time()
      ZTU_DELE   := ""
      MsUnLock()

      cString := "0|" + xControle + "|"
      
   Endif   

   // ########################
   // Alteração do Registro ##
   // ########################
   If cCodOpe == "A"

      If cVisual == "0"
         cDtaFim := Ctod(Substr(Dtoc(Date()),01,02) + "/" + Substr(Dtoc(Date()),04,02) + "/" + Substr(Dtoc(Date()),07,04))
         cHorFim := Time()

         DbSelectArea("ZTU")
         DbSetOrder(1)
         If DbSeek(cCodFil + cCodCon)
            RecLock("ZTU",.F.)
            ZTU_DFIM   := cDtaFim
            ZTU_HFIM   := cHorFim
            ZTU_HTOT   := ElapTime( ZTU_HINI + ":00", cHorFim ) 
            MsUnLock()
            cString := "0|ATUALIZOU|"
         Else
            cString := "9|999999|"
         Endif
         
      Else

         xDtaIni := Ctod(U_P_CORTA((cDtaIni + "/"), "/", 1) + "/" + ;
                         U_P_CORTA((cDtaIni + "/"), "/", 2) + "/" + ;
                         U_P_CORTA((cDtaIni + "/"), "/", 3))

         xDtaFim := Ctod(U_P_CORTA((cDtaFim + "/"), "/", 1) + "/" + ;
                         U_P_CORTA((cDtaFim + "/"), "/", 2) + "/" + ;
                         U_P_CORTA((cDtaFim + "/"), "/", 3))

         DbSelectArea("ZTU")
         DbSetOrder(1)
         If DbSeek(cCodFil + cCodCon)
            RecLock("ZTU",.F.)
            ZTU_DINI := xDtaIni
            ZTU_HINI := cHorIni
            ZTU_DFIM := xDtaFim
            ZTU_HFIM := cHorFim
            ZTU_HTOT := ElapTime( cHorIni + ":00", cHorFim + ":00" ) 
            MsUnLock()
            cString := "0|ATUALIZOU|"
         Else
            cString := "9|999999|"
         Endif

      Endif
         

   Endif
     
   // #######################
   // Exclusão do Registro ##
   // #######################
   If cCodOpe == "E"

      DbSelectArea("ZTU")
      DbSetOrder(1)
      If DbSeek(cCodFil + cCodCon)
         RecLock("ZTU",.F.)
         ZTU_DELE   := "X"
         MsUnLock()
         cString := "0|" + cCodCon + "|"
      Else
         cString := "9|999999|"         
      Endif
      
   Endif

   // ###########################################
   // Visualização de horários de atendimentos ##
   // ###########################################
   If cCodOpe == "V"
   
      If (Select( "T_CONSULTA" ) != 0 )
         T_CONSULTA->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTU_FILIAL,"
      cSql += "       ZTU_CONT  ,"
      cSql += "       ZTU_NUMOS ,"
      cSql += "       ZTU_TECN  ,"
      cSql += "       ZTU_DINI  ,"
      cSql += "       SUBSTRING(ZTU_DINI,07,02) + '/' + SUBSTRING(ZTU_DINI,05,02) + '/' + SUBSTRING(ZTU_DINI,01,04) AS DTA_INICIAL,"
      cSql += "       ZTU_HINI  ,"
      cSql += "       ZTU_DFIM  ,"
      cSql += "       SUBSTRING(ZTU_DFIM,07,02) + '/' + SUBSTRING(ZTU_DFIM,05,02) + '/' + SUBSTRING(ZTU_DFIM,01,04) AS DTA_FINAL,"
      cSql += "       ZTU_HFIM  ,"
      cSql += "       ZTU_HTOT  ,"
      cSql += "       ZTU_DELE   "
      cSql += "  FROM " + RetSqlName("ZTU")
      cSql += " WHERE ZTU_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZTU_NUMOS  = '" + Alltrim(cCodOrd) + "'"

      If cVisual == "0"
      Else
         If cVisual = "1" 
            cSql += "   AND ZTU_CONT  = '" + Alltrim(cCodCon) + "'"
         Endif   
      Endif
         
      cSql += "   AND ZTU_TECN   = '" + Alltrim(cCodTec) + "'"
      cSql += "   AND ZTU_DELE   = ''"
      cSql += " ORDER BY ZTU_DINI, ZTU_HINI"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CONSULTA",.T.,.T.)

      // ##############################################################################
      // Pesquisa o total de horas para display na tela principal da Ordemde Serviço ##
      // ##############################################################################
      If cVisual == "2"
      
         T_CONSULTA->( DbGoTop() )

         cString     := ""

         __PriData   := DTA_INICIAL
         __PriHora   := T_CONSULTA->ZTU_HINI 
         __UltData   := "  /  /    "
         __UltHora   := "  :  "
         __SomaHoras := 0
         __aSomar    := 0
         __Minutos   := 0
   
         WHILE !T_CONSULTA->( EOF() )

            __SomaHoras := __SomaHoras + INT(VAL(Substr(T_CONSULTA->ZTU_HTOT,01,02)))
            __Minutos   := __Minutos   + INT(VAL(Substr(T_CONSULTA->ZTU_HTOT,04,02)))
         
            If __Minutos >= 60
               __aSomar    := __Minutos - 60
               __SomaHoras := __SomaHoras + 1
               __Minutos   := __aSomar
            Endif
            
            __UltData   := DTA_INICIAL
            __UltHora   := T_CONSULTA->ZTU_HFIM

            T_CONSULTA->( DbSkip() )
            
         ENDDO   

         cString := "0"         + "|" + ;
                    __PriData   + "|" + ;
                    __PriHora   + "|" + ;
                    __UltData   + "|" + ;
                    __UltHora   + "|" + ;
                    Strzero(__SomaHoras,2) + ":" + Strzero(__Minutos,2) + "|#"

      Else

         If T_CONSULTA->( EOF() )
            cString := "999999|"
         Else
      
            T_CONSULTA->( DbGoTop() )

            cImagem   := ""
            cString   := ""
            nQuantReg := 0
      
            WHILE !T_CONSULTA->( EOF() )
               nQuantReg := nQuantReg + 1
               T_CONSULTA->( DbSkip() )
            ENDDO

            T_CONSULTA->( DbGoTop() )

            WHILE !T_CONSULTA->( EOF() )

               cString := cString + Alltrim(Str(nQuantReg)) + "|" + ;
                                    T_CONSULTA->ZTU_FILIAL  + "|" + ;
                                    T_CONSULTA->ZTU_CONT    + "|" + ;
                                    T_CONSULTA->ZTU_NUMOS   + "|" + ;
                                    T_CONSULTA->ZTU_TECN    + "|" + ;
                                    T_CONSULTA->DTA_INICIAL + "|" + ;
                                    T_CONSULTA->ZTU_HINI    + "|" + ;
                                    T_CONSULTA->DTA_FINAL   + "|" + ;
                                    T_CONSULTA->ZTU_HFIM    + "|" + ;
                                    T_CONSULTA->ZTU_HTOT    + "|#"
                              
               T_CONSULTA->( DbSkip() )
         
            ENDDO

         Endif

      Endif

   Endif   

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)

// #######################################################################
// Função que calcula a direfença de horas entre a hora inicial e final ##
// #######################################################################
Static Function xDifHoras(cHorIni, cHorFim)

    If cHorIni == "  :  "
       cHorTot := "  :  "
       Return(.T.)
    Endif
       
    If cHorFim == "  :  "
       cHorTot := "  :  "
       Return(.T.)
    Endif

    If cHorIni > cHorFim
       cHorTot := "  :  "
       Return(.T.)
    Endif

    cHorTot := ElapTime( cHorIni + ":00", cHorFim + ":00" ) 

Return(.T.)