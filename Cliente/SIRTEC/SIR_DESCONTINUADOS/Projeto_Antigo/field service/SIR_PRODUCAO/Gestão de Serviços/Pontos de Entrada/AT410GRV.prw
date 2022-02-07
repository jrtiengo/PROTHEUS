#include 'totvs.ch'

/*/{Protheus.doc} AT410GRV
Ponto de entrada na efetivação do Pedido de venda na rotina TECA450 (Ordens de Serviço)
@type function
@author Bruno Silva
@since 25/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function AT410GRV()

	Local cTipo := PARAMIXB[1] // 1=Inclusao, 2=Alteracao
	/*
	M->C5_SDESCNF := AB7->AB7_SDESNF
 	M->C5_SMUNIC  := AB7->AB7_SMUNIC
 	M->C5_SSETOR  := AB7->AB7_SSETOR
 	M->C5_SNFOLH  := AB7->AB7_SNFOLH  	
 	M->C5_SOBSER  := AB7->AB7_SOBSER 
 	M->C5_SUNIDA  := AB7->AB7_SUNIDA
 	M->C5_SPEDID  := AB7->AB7_SPEDID
	M->C5_SOBRA   := AB7->AB7_SOBRA
	M->C5_SNUMOS  := AB7->AB7_NUMOS
	*/
Return