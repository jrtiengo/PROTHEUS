/*O exemplo abaixo cria uma mensagem ap�s altera��o da situa��o do contrato que passar� de �Em elabora��o� para �Vigente�:*/ 


// Poss�veis situa��es do contrato

#DEFINE DEF_SCANC '01' //Cancelado
#DEFINE DEF_SELAB '02' //Em Elabora��o
#DEFINE DEF_SEMIT '03' //Emitido
#DEFINE DEF_SAPRO '04' //Em Aprova��o
#DEFINE DEF_SVIGE '05' //Vigente
#DEFINE DEF_SPARA '06' //Paralisado
#DEFINE DEF_SSPAR '07' //Sol Fina.
#DEFINE DEF_SFINA '08' //Finalizado
#DEFINE DEF_SREVS '09' //Revis�o  
#DEFINE DEF_SREVD '10'//Revisado

User Function CN100SIT()
Local cAtu := PARAMIXB[1]
Local cDst := PARAMIXB[2]// Situa��o atual do contrato.

If cAtu == DEF_SELAB    

msgAlert ('Situacao alterada de 'Em Elaboracao'')

EndIf 

// Nova situa��o do contrato;

If cDst == DEF_SVIGE    

MsgAlert ('Situacao alterada para 'Vigente'')

EndIf

Return
