#INCLUDE 'PROTHEUS.CH'

#DEFINE DEF_SCANC '01' //Cancelado
#DEFINE DEF_SELAB '02' //Em Elaboração
#DEFINE DEF_SEMIT '03' //Emitido
#DEFINE DEF_SAPRO '04' //Em Aprovação
#DEFINE DEF_SVIGE '05' //Vigente
#DEFINE DEF_SPARA '06' //Paralisado
#DEFINE DEF_SSPAR '07' //Sol Fina.
#DEFINE DEF_SFINA '08' //Finalizado
#DEFINE DEF_SREVS '09' //Revisão
#DEFINE DEF_SREVD '10' //Revisado


/*/{Protheus.doc} CN100SIT
É executado após a alteração da situação do contrato, quando é definido que o contrato passará de uma situação para outra. Sua execução ocorre após o processamento interno do sistema.
@type function
@version 1.0 
@author Tiengo Jr.
@since 05/05/2025
@Obs PARAMIXB[1] Contém informações sobre a situação atual do contrato.
@Obs PARAMIXB[2] Contém informações sobre a nova situação do contrato.
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6089554
/*/

User Function CN100SIT()

	//Local cAtual := PARAMIXB[1]
	//Local cNova  := PARAMIXB[2] 


Return()
