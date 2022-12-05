#INCLUDE "rwmake.ch"
#include "TbiConn.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM337.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/04/2016                                                          *
// Objetivo..: Programa que executa o programa Saldo Atual Automaticamente.        *
//**********************************************************************************

User Function AUTOM337()                                                            

   Local PARAMIXB     := .T.                      // Caso a rotina seja rodada em batch(.T.), senão (.F.)     
   Local aEmpSaldo    := {"01"}                   // "Empresa","Filial"
   Local aFilSaldo    := {"01", "02", "03", "04"}
   Local cString      := ""
   Local cDtaInicial  := Date()
   Local cHoraInicial := Time()

   U_AUTOM628("AUTOM337")
   
   //PREPARE ENVIRONMENT EMPRESA aemp[1] Filial aemp[2] USER 'Administrador' PASSWORD '@tech15001' TABLES  "SB1","SB2","SB9","SD1","SD2","SD3","SF4" MODULO "EST"

   // Calcula o saldos atuais da Empresa 01 - Automatech para a Fialial 01 - Porto Alegre
   cDtaInicial  := Date()
   cHoraInicial := Time()

   PREPARE ENVIRONMENT EMPRESA "01" Filial "01" USER 'Administrador' PASSWORD '@tech15001' TABLES  "SB1","SB2","SB9","SD1","SD2","SD3","SF4" MODULO "EST"
   MSExecAuto({|x| mata300(x)},PARAMIXB)
   
   // Cria o arquivo de log de execução do recalculo para Empresa 01 Filial 03
   cString := ""
   cString := "Empresa.....: 01 - Automatech"      + chr(13) + chr(10) 
   cString += "Filial......: 01 - Porto Alegre"    + chr(13) + chr(10) 
   cString += "Data Inicial: " + Dtoc(cDtaInicial) + chr(13) + chr(10) 
   cString += "Hora Inicial: " + cHoraInicial      + chr(13) + chr(10) 
   cString += "Data Final..: " + Dtoc(Date())      + chr(13) + chr(10) 
   cString += "Hora Final..: " + Time()            + chr(13) + chr(10) 
   
   nHdl := fCreate("C:\RECSALDOS\SLD_PORTO.TXT")
   fWrite (nHdl, cString)
   fClose(nHdl)

   // Calcula o saldos atuais da Empresa 01 - Automatech para a Fialial 02 - Caxias do Sul
   cDtaInicial  := Date()
   cHoraInicial := Time()

   PREPARE ENVIRONMENT EMPRESA "01" Filial "02" USER 'Administrador' PASSWORD '@tech15001' TABLES  "SB1","SB2","SB9","SD1","SD2","SD3","SF4" MODULO "EST"
   MSExecAuto({|x| mata300(x)},PARAMIXB)
   
   // Cria o arquivo de log de execução do recalculo para Empresa 01 Filial 03
   cString := ""
   cString := "Empresa.....: 01 - Porto Alegre"    + chr(13) + chr(10) 
   cString += "Filial......: 02 - Caxias do Sul"   + chr(13) + chr(10) 
   cString += "Data Inicial: " + Dtoc(cDtaInicial) + chr(13) + chr(10) 
   cString += "Hora Inicial: " + CHoraInicial      + chr(13) + chr(10) 
   cString += "Data Final..: " + Dtoc(Date())      + chr(13) + chr(10) 
   cString += "Hora Final..: " + Time()            + chr(13) + chr(10) 
   
   nHdl := fCreate("C:\RECSALDOS\SLD_CAXIAS.TXT")
   fWrite (nHdl, cString)
   fClose(nHdl)

   // Calcula o saldos atuais da Empresa 01 - Automatech para a Fialial 03 - Pelotas
   cDtaInicial  := Date()
   cHoraInicial := Time()

   PREPARE ENVIRONMENT EMPRESA "01" Filial "03" USER 'Administrador' PASSWORD '@tech15001' TABLES  "SB1","SB2","SB9","SD1","SD2","SD3","SF4" MODULO "EST"
   MSExecAuto({|x| mata300(x)},PARAMIXB)
   
   // Cria o arquivo de log de execução do recalculo para Empresa 01 Filial 03
   cString := ""
   cString := "Empresa.....: 01 - Porto Alegre"    + chr(13) + chr(10) 
   cString += "Filial......: 03 - Pelotas"         + chr(13) + chr(10) 
   cString += "Data Inicial: " + Dtoc(cDtaInicial) + chr(13) + chr(10) 
   cString += "Hora Inicial: " + CHoraInicial      + chr(13) + chr(10) 
   cString += "Data Final..: " + Dtoc(Date())      + chr(13) + chr(10) 
   cString += "Hora Final..: " + Time()            + chr(13) + chr(10) 
   
   nHdl := fCreate("C:\RECSALDOS\SLD_PELOTAS.TXT")
   fWrite (nHdl, cString)
   fClose(nHdl)

   // Calcula o saldos atuais da Empresa 01 - Automatech para a Fialial 04 - Suprimentos
   cDtaInicial  := Date()
   cHoraInicial := Time()

   PREPARE ENVIRONMENT EMPRESA "01" Filial "04" USER 'Administrador' PASSWORD '@tech15001' TABLES  "SB1","SB2","SB9","SD1","SD2","SD3","SF4" MODULO "EST"
   MSExecAuto({|x| mata300(x)},PARAMIXB)
   
   // Cria o arquivo de log de execução do recalculo para Empresa 01 Filial 03
   cString := ""
   cString := "Empresa.....: 01 - Porto Alegre"    + chr(13) + chr(10) 
   cString += "Filial......: 04 - Suprimentos"     + chr(13) + chr(10) 
   cString += "Data Inicial: " + Dtoc(cDtaInicial) + chr(13) + chr(10) 
   cString += "Hora Inicial: " + CHoraInicial      + chr(13) + chr(10) 
   cString += "Data Final..: " + Dtoc(Date())      + chr(13) + chr(10) 
   cString += "Hora Final..: " + Time()            + chr(13) + chr(10) 
   
   nHdl := fCreate("C:\RECSALDOS\SLD_SUPRI.TXT")
   fWrite (nHdl, cString)
   fClose(nHdl)

   RESET ENVIRONMENT

Return Nil