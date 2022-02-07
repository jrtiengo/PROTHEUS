#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TEDXFUN   ºAutor  ³MarcioQuevedoBorges          º Data ³  05/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Propósito:Bibliotecas de User Functions ADVPL                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±

±±º          ³ Funcao:  fExecCT5()                                                 º±±
±±º          ³ Propósito:Ao contabilizar permite que seja verificado o contaudo    º±±
±±º          ³           de outro campo da tabela CT5  - Lançamento Padrao         º±±
±±º          ³ Sintaxe:u_fExecCT5(campo,lanpad,sequen,[posiciona_CT1]) -> retorno  º±±
±±º          ³---------------------------------------------------------------------º±
*/




/*/{Protheus.doc} fExecCT5
Ao contabilizar permite que seja verificado o conteúdo de outro campo da tabela CT5  - Lançamento Padrao         
Sintaxe= u_fExecCT5(campo,lanpad,sequen,[posiciona_CT1]) -> retorno
Exemplo= IF(substr(u_fExecCT5("P01","004","CT5_CREDIT"),1,1) $ "1#2","n.preenche","preenche")
@type function
@version 
@author solutio
@since 26/11/2020
@param _cCT5Campo, param_type, Informe o campo do lançamento padrão a ser rodado
@param _clanpad, param_type, Informe o código do lançamento padrão
@param _csequen, param_type, Informe a sequencia do lançamento padrão
@param _lPosCT1, param_type, [opcional][pad .F.] Se .T. posiciona no CT1 quando campo de debito e credito 
@param _cCpoRet, param_type, [opcional] Informe o campo de retorno da tabela CT1, caso não preenchido irá retornar a conta contabil
@return return_type, Retorna execução do CT5Campo informado
/*/
USER FUNCTION fExecCT5(_cCT5Campo,_clanpad,_csequen,_lPosCT1,_cCpoRet)

	Local cResult := " "  // Resultado a ser retornado
	Local cContCpo := " " //Conteudo do campo
	LOCAL aArea	  := GetArea()

	Default _lPosCT1 := .F.
	Default _cCpoRet := " "
	IF !_lPosCT1 .AND. !Empty(_cCpoRet) // Se espera retorno de um campo da CT1 então posiciona sempre
		_lPosCT1 := .T.
	ENDIF

	IF _lPosCT1
		DbSelectArea("CT1");DBSetOrder(1)
	ENDIF
	DBSelectArea("CT5")
//ALERT("RODOU " + _clanpad + "-" + _csequen + ": " + _cCT5Campo)

	IF _cCT5Campo <> Nil .AND. _clanpad <> Nil .AND. _csequen <> Nil

		//Verifica se está posicionado
		IF CT5->(CT5_LANPAD + CT5_SEQUEN) == _clanpad + _csequen
			cContCpo := &("CT5->"+_cCT5Campo)
			// Validação ciclica de redundancia
			IF "fExecCT5" $ cContCpo
				Return "nao use fExecCT5"
			ENDIF
		ELSE
			cContCpo := Posicione("CT5",1,xFilial("CT5")+ _clanpad + _csequen ,_cCT5Campo)
			// Validação ciclica de redundancia
			IF "fExecCT5" $ cContCpo
				Return "nao use fExecCT5"
			ENDIF
		ENDIF

		cResult   := &(cContCpo)
		cResult   := cvaltochar(cResult)
	ENDIF

	RestArea( aArea)

// Posiciona nas contas contabeis, quando parametrizado
	IF _lPosCT1 .AND. _cCT5Campo $ 'CT5_DEBITO/CT5_CREDIT'
		nRecCt1:= CT1->(Recno())
		IF cResult <> CT1->CT1_CONTA //Só reposiciona se estiver desposicionado no CT1
			IF !CT1->(MsSeek(xFilial("CT1")+cResult))
				// Se não encontrar conta, volta para posicão anterior
				ct1->(DBGoto(nRecCt1))
			ENDIF
		ENDIF
	ENDIF

	IF !Empty(_cCpoRet)
		cResult := &("CT1->"+_cCpoRet)
	ENDIF

Return cResult
