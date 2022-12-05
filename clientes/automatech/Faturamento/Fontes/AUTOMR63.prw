#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR63.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/12/2011                                                          *
// Objetivo..: Grava Contato Automatech para os clientes que não possuem contato   *
//             Vinculado.                                                          *   
//**********************************************************************************

// Função que define a Window
User Function AUTOMR63()   

   Local cSql := ""
   
   U_AUTOM628("AUTOMR63")
   
   // Pesquisa os Clientes para serem verificados com a tabela AC8 (Vínculo de Contatos de Clientes) 
   If Select("T_CLIENTES") > 0
      T_CLIENTES->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT SA1010.A1_COD    , "
   csql += "       SA1010.A1_LOJA   , "
   csql += "       AC8010.AC8_CODENT  "
   csql += "  FROM " + RetSqlName("SA1010") + " LEFT OUTER JOIN "  + RetSqlName("AC8010")
   csql += "    ON SA1010.A1_COD = SUBSTRING(AC8010.AC8_CODENT,1,6) "
   csql += " WHERE AC8010.AC8_CODENT IS NULL"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTES", .T., .T. )
   
   If T_CLIENTES->( EOF() )
      MsgAlert("Não existem dados a serem vizualizados.")
      If Select("T_CLIENTES") > 0
         T_CLIENTES->( dbCloseArea() )
      EndIf
      Return .T.
   Endif
   
   T_CLIENTES->( DbGoTop() )
   
   WHILE !T_CLIENTES->( EOF() )
 
      // Contato Tele-Atendimento
      DbSelectArea("AC8")
      DbAppend(.F.)
      AC8_ENTIDA := "SA1"
      AC8_CODENT := Alltrim(T_CLIENTES->A1_COD) + Alltrim(T_CLIENTES->A1_LOJA)
      AC8_CODCON := '069523'
      DbUnlock()
          
      // Contato Tele-Cobraça
      DbSelectArea("AC8")
      DbAppend(.F.)
      AC8_ENTIDA := "SA1"
      AC8_CODENT := Alltrim(T_CLIENTES->A1_COD) + Alltrim(T_CLIENTES->A1_LOJA)
      AC8_CODCON := '069524'
      DbUnlock()
         
      T_CLIENTES->( DbSkip() )
      
   ENDDO      
   
Return .T.