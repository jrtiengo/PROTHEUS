#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM335.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/03/2016                                                          *
// Objetivo..: Programa que gera o relatório de consulta do Relato.                *
//**********************************************************************************

User Function AUTOM335()

   Local cSql     := ""                         
   Local nContar  := 0
   Local cCliente := "000329'
   Local cLoja    := "001"
   Local cCodigo  := "000002"
   
   Private aConsulta := {}
   
   // Pesquisa os dados para o Cliente, Loja e Código da consulta selecionada pelo uusário   
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),02,02)  AS IDINF,"
   cSql += "       SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),04,02)  AS BCFIC,"
   cSql += "       SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),06,02)  AS TPINF,"
   cSql += "      (SELECT ZPD_TITU "
   cSql += "         FROM " + RetSqlName("ZPD")
   cSql += "		   WHERE ZPD_IDINF  = SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),02,02)"
   cSql += "	         AND ZPD_BCFIC  = SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),04,02)"
   cSql += "		     AND ZPD_TPINF  = SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),06,02)"
   cSql += "		     AND D_E_L_E_T_ = '') AS TITULO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)) AS RETORNO"
   cSql += "  FROM " + RetSqlName("ZPF") + " ZPF "
   cSql += " WHERE ZPF.ZPF_CODI = '" + Alltrim(cCodigo)  + "'"
   cSql += "   AND ZPF.ZPF_CLIE = '" + Alltrim(cCliente) + "'"
   cSql += "   AND ZPF.ZPF_LOJA = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND ZPF.ZPF_DELE = ''"
   cSql += "   AND SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),01,01) = 'L'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      nContar := nContar + 1
      
      aAdd(aConsulta, { T_CONUSLTA->IDINF ,;
                        T_CONSULTA->BCFIC ,;
                        T_CONSULTA->TPINF ,;
                        T_CONSULTA->TITULO,;
                        0                 ,;
                        ""})
                        
      // Pesquisa os detalhes da identificação
      
      T_CONSULTA->( DbSkip() )
      
   ENDDO
           
   msgalert("parei")
   
Return(.T.)                              
                        
                        
                        
                        
   
   
   
   
   
   



   
   

