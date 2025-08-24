#Include 'Protheus.ch'

/*/{Protheus.doc} GP010AGRV
PE GP010AGRV
@version 1.0 
@author Tiengo Junior
@since 21/08/2025
@type function
@Param nOpc (3 - Incluir, 4 - Alterar, 5 - Excluir). 
@Param lGrava
https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020432511-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-GP010AGRV 
See 
/*/

User Function GP010AGRV()

	Local nOpc       :=Paramixb[1]           as Numeric
	//Local lGrava :=Paramixb[2]

	If cFilAnt == '0101' .and. (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5)
		If ! u_IntUsr(@cMsgErro)
			Aviso("Falha na integração com TracOS", cMsgErro, {"OK"}, 1, "Tractian")
		Endif
	Endif


Return()
