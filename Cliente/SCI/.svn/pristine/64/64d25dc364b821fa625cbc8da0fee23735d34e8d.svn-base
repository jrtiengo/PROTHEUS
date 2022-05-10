#include "Totvs.ch"
/*
|============================================================================|
|============================================================================|
|||-----------+---------+--------------------------------+------+----------|||
||| Funcao    | MT110VLD| Joao Mattos                    | Data |05/04/2019|||
|||-----------+---------+--------------------------------+------+----------|||
||| Descricao | Ponto de entrada para validar se a solicitacao de compra   |||
|||           | pode ser alterada ou excluida                              |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | MT110VLD()                                                 |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|||  Uso      | Especifico Sport Clube Internacional                       |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function MT110VLD()

	Local aArea     := GetArea()	
	Local nOpcao    := PARAMIXB[1]
	Local lReturn   := .T.
	Local cProblema := ""
	Local aSolucao  := {}

	If SC1->C1_POSPAGO == "1" .AND. nOpcao <> 3.AND. !ISINCALLSTACK("U_SCIA120") 
	
		cProblema := "Solicitação incluida pela Rotina Pos Pago, não poderá ser efetuada a manutenção nesta rotina."
		aSolucao  := {}
		AADD ( aSolucao, "Acesse a rotina de Pos Pago para efetuar a manutenção desta solicitação." )
		Help( Nil, Nil, "MT110VLD_01", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
		lReturn := .F.
	EndIf

	RestArea( aArea )

Return ( lReturn )