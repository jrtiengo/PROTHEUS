#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM622.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 31/08/2017                                                          ##
// Objetivo..: Programa que verifica se existem notas fiscais não enviadas a Terca ##
//             Pesquisa pelo dois últimos meses                                    ##
// ##################################################################################

User Function AUTOM622()

   Local cSql   := ""
   Local cDataI := ""
   Local cDataF := ""

   U_AUTOM628("AUTOM622")

   // ################################
   // Prepara as data para pesquisa ##
   // ################################
   cDiaI := Day(Date())
   cMesI := Month(Date())
   cAnoI := Year(Date())

   cMesI := cMesI - 1
   
   If cMesI == 0
      cMesI := 12
      cAnoI := cAnoI -1
   Endif

   cDataI := Ctod(Strzero(cDiaI,2) + "/" + Strzero(cMesI,2) + "/" + Strzero(cAnoI,4))
   
   _Mes := Month(Date())
   _Ano := Year(Date())

   Do Case
      Case _Mes == 1
           kDia := 31
      Case _Mes == 2
           If Mod(_Ano,4) == 0
              kDia := 29
           Else
              kDia := 28
           Endif   
      Case _Mes == 3
           kDia := 31
      Case _Mes == 4
           kDia := 30
      Case _Mes == 5
           kDia := 31
      Case _Mes == 6
           kDia := 30
      Case _Mes == 7
           kDia := 31
      Case _Mes == 8
           kDia := 31
      Case _Mes == 9
           kDia := 30
      Case _Mes == 10
           kDia := 31
      Case _Mes == 11
           kDia := 30
      Case _Mes == 12
           kDia := 31
   EndCase
         
   cDataF := Ctod(Strzero(kDia,02) + "/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))

   // ###########################################################
   // Pesquisa as notas fiscais a serem enviados os documentos ##
   // ###########################################################
   If Select("T_NOTAS") > 0                                           
      T_NOTAS->( dbCloseArea() )
   EndIf
 
   cSql := ""
   cSql := "SELECT SF2.F2_FILIAL ," + CHR(13)
   cSql += "       SF2.F2_DOC    ," + CHR(13)
   cSql += "       SF2.F2_SERIE  ," + CHR(13)
   cSql += "       SF2.F2_EMISSAO," + CHR(13)
   cSql += "       SF2.F2_CLIENTE," + CHR(13)
   cSql += "       SF2.F2_LOJA   ," + CHR(13)
   cSql += "       SA1.A1_NOME   ," + CHR(13)
   cSql += "       SA1.A1_EMAIL  ," + CHR(13)
   cSql += "       SF2.F2_ZEEN   ," + CHR(13)
   cSql += "       SF2.F2_ZDEN   ," + CHR(13)
   cSql += "       SF2.F2_ZHEN   ," + CHR(13)
   cSql += "       SF2.F2_ZUEN   ," + CHR(13)
   cSql += "       SF2.F2_ZXML   ," + CHR(13)
   cSql += "       SF2.F2_ZDNF   ," + CHR(13)
   cSql += "       SF2.F2_ZBLT   ," + CHR(13)
   cSql += "       SF2.F2_TRANSP ," + CHR(13)
   cSql += "       SA4.A4_NOME    " + CHR(13)
   cSql += "  FROM " + RetSqlName("SF2") + " SF2, "                                 + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " SA1, "                                 + CHR(13)
   cSql += "       " + RetSqlName("SA4") + " SA4  "                                 + CHR(13)
   cSql += " WHERE SF2.F2_FILIAL   = '" + Alltrim(cFilAnt) + "'"                    + CHR(13)
   cSql += "   AND SF2.F2_EMISSAO >= '" + Dtoc(cDataI) + "'" + CHR(13)
   cSql += "   AND SF2.F2_EMISSAO <= '" + Dtoc(cDataF) + "'" + CHR(13)
   cSql += "   AND SF2.F2_ZEEN    <> '1'"                                           + CHR(13)
   cSql += "   AND SF2.D_E_L_E_T_  = ''"                                            + CHR(13)
   cSql += "   AND SA1.A1_COD      = SF2.F2_CLIENTE"                                + CHR(13)
   cSql += "   AND SA1.A1_LOJA     = SF2.F2_LOJA   "                                + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_  = ''"                                            + CHR(13)
   cSql += "   AND SA4.A4_COD      = SF2.F2_TRANSP "                                + CHR(13)
   cSql += "   AND SA4.D_E_L_E_T_  = ''"                                            + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   If !T_NOTAS->( EOF() )
      MsgAlert("Atenção!"                                      + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Existem Documentos ainda não enviados a TERCA" + chr(13) + chr(10) + ;
               "para o período de " + Dtoc(cDataI) + " a " + Dtoc(cDataF))
   Endif
               
   _RunTerca := .T.

Return(.T.)