#INCLUDE "rwmake.ch"


/*/
Programa:		MT100GE2
Objetivo:		Ponto de entrada - Executado apos a gravacao do titulo a pagar quando gerado pela
nota fiscal de entrada de mercadorias.
Programador:	Jean Rehermann - SigaSul
Data:			11/06/2007 13:24
/*/

User Function MT100GE2()

	Local nOpc:= PARAMIXB[2]


	Local _lOk := .T.
	//Incluir sempre o mesmo bloco de código, substituindo somente o nome da função.

	// 1 *******************************************************************************************************
	If( _lOk )
		/*/
		F1-Fazer a validacao das divergencias entre NFE e PC.
		F2-Altera as naturezas dos títulos de impostos(PIS/COFINS/CSLL), gerados a partir da nota fiscal de entrada
		/*/
		_lOk := U_PETG040()
	Endif

	// 2 *******************************************************************************************************
	If( _lOk )
		/*/
		Descrição: Alimenta as variaveis M->E2_BCOFOR, M->E2_AGENFOR, M->E2_DVAGEN, M->E2_CONTAFO e M->E2_DVCONTA
		na gravação do titulo quando do lançamento de uma nota fiscal. Traz os dados do SA2 (Fornecedores).
		Programador:	Jean Rehermann - SigaSul
		Data:			11/06/2007 11:24
		/*/
		_lOk := U_PETG020()
	Endif

	// 3 *******************************************************************************************************
	If( _lOk )
		/*/
		Descrição  : Gravar o centro de custo de débito nas pacelas referente às taxas (IR, ISS, INSS, ...)
		Programador: Jean Rehermann
		Data: 26/06/2007 16:08
		/*/
		_lOk := U_PETG021()
	Endif

    /*
    PE para complementar a gravacao do titulos no contas a pagar
    Ezequiel Pianegonda
    23/11/2020
    */

	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN
	end

	If nOpc == 1    //inclusao
		SZ1->(dbSetOrder(1))
		If SZ1->(dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			//SE2->E2_VENCORI:= StoD(aVcto[nParc])
			//SE2->E2_VENCTO:= StoD(aVcto[nParc])
			//SE2->E2_VENCREA:= DataValida(StoD(aVcto[nParc]), .T.)
			//SE2->E2_CCUSTO      := SZ1->Z1_CC
			SE2->E2_CNPJRET     := SZ1->Z1_CNPJ
			SE2->E2_BCOFOR      := SZ1->Z1_BANCO
			SE2->E2_AGENFOR     := SZ1->Z1_AG
			SE2->E2_CONTAFO     := SZ1->Z1_CONTA
		EndIf
	EndIf

Return
