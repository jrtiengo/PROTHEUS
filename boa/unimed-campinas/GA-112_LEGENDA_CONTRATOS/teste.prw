/*O exemplo abaixo cria uma mensagem após alteração da situação do contrato que passará de “Em elaboração” para “Vigente”:*/ 


// Possíveis situações do contrato

#DEFINE DEF_SCANC '01' //Cancelado
#DEFINE DEF_SELAB '02' //Em Elaboração
#DEFINE DEF_SEMIT '03' //Emitido
#DEFINE DEF_SAPRO '04' //Em Aprovação
#DEFINE DEF_SVIGE '05' //Vigente
#DEFINE DEF_SPARA '06' //Paralisado
#DEFINE DEF_SSPAR '07' //Sol Fina.
#DEFINE DEF_SFINA '08' //Finalizado
#DEFINE DEF_SREVS '09' //Revisão  
#DEFINE DEF_SREVD '10'//Revisado

User Function CN100SIT()
Local cAtu := PARAMIXB[1]
Local cDst := PARAMIXB[2]// Situação atual do contrato.

If cAtu == DEF_SELAB    

msgAlert ('Situacao alterada de 'Em Elaboracao'')

EndIf 

// Nova situação do contrato;

If cDst == DEF_SVIGE    

MsgAlert ('Situacao alterada para 'Vigente'')

EndIf

Return
