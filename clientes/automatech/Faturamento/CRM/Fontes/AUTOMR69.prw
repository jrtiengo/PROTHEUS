#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR69.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/12/2011                                                          *
// Objetivo..: Programa que verifica se todos os clientes possui um lançamento de  *
//             contato. Se existe, verifica se o contato é um contato de cobrança. *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR69()
 
   Local cSql        := ""
   Local lSemContato := .F.
         
   U_AUTOM628("AUTOMR69")

   // Pesquisa os clientes
   If Select("T_CLIENTES") > 0
      T_CLIENTES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, "
   cSql += "       A1_NOME  "
   cSql += "  FROM " + RetSqlName("SA1010") 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTES", .T., .T. )

   T_CLIENTES->( DbGoTop() )

   While !T_CLIENTES->( EOF() )
               
      // Pesquisa o Vínculo do Contato do Cliente
      If Select("T_VINCULO") > 0
         T_VINCULO->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT AC8_CODENT, "
      cSql += "       AC8_CODCON  "
      cSql += "  FROM " + RetSqlName("AC8010")
      cSql += " WHERE AC8_CODENT = '" + Alltrim(T_CLIENTES->A1_COD) + Alltrim(T_CLIENTES->A1_LOJA) + "'"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VINCULO", .T., .T. )

      If T_VINCULO->( EOF() )

         // Contato Tele-Cobraça
//         DbSelectArea("AC8")
//         DbAppend(.F.)
//         AC8_ENTIDA := "SA1"
//         AC8_CODENT := Alltrim(T_CLIENTES->A1_COD) + Alltrim(T_CLIENTES->A1_LOJA)
//         AC8_CODCON := '104408'
//         DbUnlock()

       MsgAlert("Cliente: " + Alltrim(T_CLIENTES->A1_COD) + "." + Alltrim(T_CLIENTES->A1_LOJA) + " Sem vínculo de contato.")

         T_CLIENTES->( DbSkip() )
         Loop
      Endif
   
      // Verifica se os contatos do Cliente pelo menos um deles é contato de cliente
      T_VINCULO->( DbGoTop() )

      lSemContato := .F.

      While !T_VINCULO->( EOF() )

         If Select("T_CONTATO") > 0
            T_CONTATO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT U5_CODCONT, "
         cSql += "       U5_NIVEL    "
         cSql += "  FROM " + RetSqlName("SU5010")
         cSql += " WHERE U5_CODCONT = '" + Alltrim(T_VINCULO->AC8_CODCON) + "'"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )
         
         If Alltrim(T_CONTATO->U5_NIVEL) == "08"
            lSemContato := .T.
            Exit
         Endif
         
         T_VINCULO->( dBSkip() )
         
      Enddo
            
      If !lSemContato                          
       MsgAlert("Cliente: " + Alltrim(T_CLIENTES->A1_COD) + "." + Alltrim(T_CLIENTES->A1_LOJA) + " Com contato porém sem contato de cobrança.")
      Endif
      
      T_CLIENTES->( dBSkip() )
      
   Enddo

Return .T.