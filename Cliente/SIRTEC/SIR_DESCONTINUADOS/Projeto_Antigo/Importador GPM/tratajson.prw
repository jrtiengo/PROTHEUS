#include "protheus.ch"
 
user function tratajson()

   local wrk
   local aNames := {}
   local nL := 0
   
   wrk := JsonObject():new()
   wrk:fromJson("D:\Clientes Solutio\Sirtec\Projeto Importa��o de Ordens de Servi�o\Planilha FTP\jsonsirtec.json") 
     
//   '{"name":"John", "age":31, "city":"New York"}') )
   
   aNames := wrk:GetNames()
 
   // Exibe as propriedades de wrk e seus respectivos conteudos
   For nL := 1 to len( aNames )
       ConOut ( aNames[nL] )
       Conout ( wrk:GetJsonText( aNames[nL] ) )
   Next nL
 
   FreeObj(wrk)

return