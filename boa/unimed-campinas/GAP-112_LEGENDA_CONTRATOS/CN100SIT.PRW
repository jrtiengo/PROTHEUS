#INCLUDE 'PROTHEUS.CH'

#DEFINE DEF_SCANC '01' //Cancelado
#DEFINE DEF_SELAB '02' //Em Elabora��o
#DEFINE DEF_SEMIT '03' //Emitido
#DEFINE DEF_SAPRO '04' //Em Aprova��o
#DEFINE DEF_SVIGE '05' //Vigente
#DEFINE DEF_SPARA '06' //Paralisado
#DEFINE DEF_SSPAR '07' //Sol Fina.
#DEFINE DEF_SFINA '08' //Finalizado
#DEFINE DEF_SREVS '09' //Revis�o
#DEFINE DEF_SREVD '10' //Revisado


/*/{Protheus.doc} CN100SIT
� executado ap�s a altera��o da situa��o do contrato, quando � definido que o contrato passar� de uma situa��o para outra. Sua execu��o ocorre ap�s o processamento interno do sistema.
@type function
@version 1.0 
@author Tiengo Jr.
@since 05/05/2025
@Obs PARAMIXB[1] Cont�m informa��es sobre a situa��o atual do contrato.
@Obs PARAMIXB[2] Cont�m informa��es sobre a nova situa��o do contrato.
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6089554
/*/

User Function CN100SIT()

	//Local cAtual := PARAMIXB[1]
	//Local cNova  := PARAMIXB[2] 


Return()
