//|=====================================================================|
//|Programa: F050IRF.PRW   |Autor: Marciane Gennari   | Data: 22/11/10  |
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar histórico no titulo de IRRF  |
//|           Código da Retenção e Gera Dirf SIM.                       |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA050                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function F050IRF()

Local _cRotina  := Alltrim(FunName())
Local _cCnpj    := ""
Local _cMes     := ""
Local _cAno     := ""

If _cRotina == "FINA050" .or. _cRotina == "MATA103" .or. _cRotina == "FINA750"

	_cMes     := Subs(Dtos(SE2->E2_VENCREA),5,2)
	_cAno     := Subs(Dtos(SE2->E2_VENCREA),1,4)

	//--- Retornar o CNPJ da Matriz - sempre 01 é Matriz.
	//Alteração efetuada por Rafael Scheibler - Não existe mais a função original.
	_cCnpj   :=  SM0->M0_CGC

	RECLOCK("SE2",.F.)
		If Empty(Alltrim(SE2->E2_CODRET))
			SE2->E2_CODRET  := "1708"
		EndIf
		SE2->E2_DIRF        := "1"
		SE2->E2_HIST       := _cRotina+" "+SE2->E2_CODRET
	MSUNLOCK()

Else

	RECLOCK("SE2",.F.)
		SE2->E2_HIST       := _cRotina+" "+SE2->E2_CODRET
	MSUNLOCK()

EndIf

RETURN