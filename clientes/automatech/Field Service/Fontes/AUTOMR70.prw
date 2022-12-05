#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

// #####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              ##
// ---------------------------------------------------------------------------------- ##
// Referencia: AUTOMR70.PRW                                                           ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Gatilho                                              ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 26/12/2011                                                             ##
// Objetivo..: Programa que carrega o nº do pedido de venda e o nº da nota fiscal de  ##
//             faturamento da ordem de serviço lida.                                  ##
// #####################################################################################

User Function AUTOMR70(_NumeroOs, _Filial, _Tipo)

   Local cSql    := "" 
   Local cString := ""

   If Select("T_ORDEM") > 0
      T_ORDEM->( dbCloseArea() )
   EndIf

   csql := ""
   csql += "SELECT C6_NUM ,"
   csql += "       C6_NOTA "
   csql += "  FROM " + RetSqlName("SC6")
   csql += " WHERE SUBSTRING(C6_NUMOS,01,06) = '" + Alltrim(_NumeroOS) + "'"
   csql += "   AND C6_FILIAL  =  '" + Alltrim(_Filial)   + "'"
   csql += "   AND D_E_L_E_T_ = ''"  
   
   If _Tipo == 1
   Else
      cSql += " GROUP BY C6_NUM, C6_NOTA"
   Endif   
                                       
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDEM", .T., .T. )

   DbSelectArea("T_ORDEM")

   If !T_ORDEM->( EOF() )
      If _Tipo == 1
         Return T_ORDEM->C6_NUM
      Else
         
         T_ORDEM->( DbGoTop() )
         
         WHILE !T_ORDEM->( EOF() )
            cString := cString + Alltrim(T_ORDEM->C6_NOTA) + "-"
            T_ORDEM->( DbSkip() )
         ENDDO
         
         cString := Substr(cString,01, Len(Alltrim(cString)) - 1)
        
         Return cString
         
      Endif
   Else
      Return ""   
   Endif

Return ""