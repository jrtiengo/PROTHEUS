// Programa...: GDUtil
// Autor......: Robert Koch
// Data.......: 13/08/2004
// Descricao..: Utilitarios para trabalhar com GetDados
// Cliente....: Generico
//
// Historico de alteracoes:
// 02/02/2005 - Robert - Trata aCols e aHeader genericos (uso em MsNewGetDados)
// 06/07/2005 - Robert - Possibilidade de executar gatilhos ao gerar aCols
// 20/07/2005 - Robert - Nao salvava areas de trabalho no inicio e fim das funcoes.
// 01/08/2005 - Robert - Implementada funcao LinVazia.
// 12/08/2005 - Robert - Tratamento campos virtuais na geracao do aCols
// 19/08/2005 - Robert - Funcao ObrCols salvava area em duplicidade por nada.
// 26/10/2005 - Robert - Possibilidade de informar campos que nao devem paricipar do aHeader.
// 05/12/2005 - Robert - Possibilidade de nao gerar linha vazia inicial no aCols.
// 14/01/2006 - Robert - Possibilidade de informar os unicos campos que devem paricipar do aHeader.
//                     - Possibilidade de executar SoftLock nos registros do aCols.
//                     - Testava pelo SX3 se um campo eh virtual, mas, as vezes, o SX3 estah vazio.
// 16/01/2006 - Robert - Nao verificava corretamente a existencia de campos.
// 15/03/2006 - Robert - Confundia campos com inicio igual, no parametro 'campos sim'.
// 28/07/2006 - Robert - Nao respeitava parametro CamposSim na geracao do aHeader.
// 08/09/2006 - Robert - Criada funcao GrvACols
// 29/09/2006 - Robert - Testa se o campo existe antes de gravar na funcao GrvACols.
// 14/04/2009 - Diego  - Nao verificava corretamente a existencia de campos quando informado o parametro 'campos sim'.
//

#include "rwmake.ch"

// --------------------------------------------------------------------------
// Gera aHeader do arquivo especificado.
user function GeraHead (_sAlias, _lNew, _aCposNao, _aCposSim, _lOrdem)
	local _aAreaAnt := U_ML_SRArea ()  // Salva todas as areas de trabalho
	local aHeader := {}

	Local _cSX3 	:= GetNextAlias()

// Prepara defaults
	_lNew     := iif (_lNew     == NIL, .F., _lNew)
	_aCposNao := iif (_aCposNao == NIL, {},  _aCposNao)
	_aCposSim := iif (_aCposSim == NIL, {},  _aCposSim)
	_lOrdem   := iif (_lOrdem   == NIL, .F.,  _lOrdem)

// Preenche nomes de campos com espacos para ficar igual ao x3_campo e evitar
// confusao entre H6_OP e H6_OPERADO, por exemplo.
	for _nLinha = 1 to len (_aCposNao)
		_aCposNao [_nLinha] = upper (padr (_aCposNao [_nLinha], 10, " "))
	next
	for _nLinha = 1 to len (_aCposSim)
		_aCposSim [_nLinha] = upper (padr (_aCposSim [_nLinha], 10, " "))
	next

// Se deve respeitar a ordem que foi passada para a criação do aHeader
	IF _lOrdem
		IF Len(_aCposSim) > 0
			aHeader := Array(Len(_aCposSim))
		else
			_lOrdem := .F.
		endif
	endif


//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1)) //X3_CAMPO
		(_cSX3)->(dbSeek(_sALias))
		If (Found())
			While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == _sALias )
				if ascan (_aCposNao, &("(_cSX3)->x3_campo")) == 0
					If ascan (_aCposSim, &("(_cSX3)->x3_campo")) > 0 .or. (len (_aCposSim) == 0 .and. X3USO (&("(_cSX3)->X3_USADO")) .And. cNivel >= &("(_cSX3)->X3_NIVEL"))
						if _lNew  // Usado quando MsNewGetDados
							IF _lOrdem
								aHeader[ascan (_aCposSim, &("(_cSX3)->x3_campo"))] := {TRIM(&("(_cSX3)->X3_TITULO")), &("(_cSX3)->X3_CAMPO"), &("(_cSX3)->X3_PICTURE"), &("(_cSX3)->X3_TAMANHO"), &("(_cSX3)->X3_DECIMAL"), &("(_cSX3)->x3_valid"), &("(_cSX3)->X3_USADO") , &("(_cSX3)->X3_TIPO"), &("(_cSX3)->x3_f3"), &("(_cSX3)->X3_CONTEXT"), &("(_cSX3)->x3_cbox"), &("(_cSX3)->x3_relacao"), &("(_cSX3)->x3_when")}
							else
								AADD (aHeader, {TRIM(&("(_cSX3)->X3_TITULO")), &("(_cSX3)->X3_CAMPO"), &("(_cSX3)->X3_PICTURE"), &("(_cSX3)->X3_TAMANHO"), &("(_cSX3)->X3_DECIMAL"), &("(_cSX3)->x3_valid"), &("(_cSX3)->X3_USADO"), &("(_cSX3)->X3_TIPO"), &("(_cSX3)->x3_f3"), &("(_cSX3)->X3_CONTEXT"), &("(_cSX3)->x3_cbox"), &("(_cSX3)->x3_relacao"), &("(_cSX3)->x3_when")})
							endif
						else  // GetDados tradicional
							IF _lOrdem
								aHeader[ascan (_aCposSim, &("(_cSX3)->x3_campo"))] := {TRIM(&("(_cSX3)->X3_TITULO")), &("(_cSX3)->X3_CAMPO"), &("(_cSX3)->X3_PICTURE"), &("(_cSX3)->X3_TAMANHO"), &("(_cSX3)->X3_DECIMAL"), "", &("(_cSX3)->X3_USADO"), &("(_cSX3)->X3_TIPO"), &("(_cSX3)->X3_ARQUIVO"), &("(_cSX3)->X3_CONTEXT")}
							else
								AADD (aHeader, {TRIM(&("(_cSX3)->X3_TITULO")), &("(_cSX3)->X3_CAMPO"), &("(_cSX3)->X3_PICTURE"), &("(_cSX3)->X3_TAMANHO"), &("(_cSX3)->X3_DECIMAL"), "", &("(_cSX3)->X3_USADO"), &("(_cSX3)->X3_TIPO"), &("(_cSX3)->X3_ARQUIVO"), &("(_cSX3)->X3_CONTEXT")})
							endif
						endif
					endif
				Endif
				(_cSX3)->(DBSkip())
			EndDo
		EndIf
	Endif
	(_cSX3)->(dbCloseArea())



/*
sx3 -> (DbSetOrder (1))
sx3 -> (DbSeek (_sAlias))
	Do While ! sx3 -> (Eof ()) .And. (sx3 -> X3_ARQUIVO == _sALias)
	//If X3USO (sx3 -> X3_USADO) .And. cNivel >= sx3 -> X3_NIVEL .and. ascan (_aCposNao, sx3->x3_campo) == 0 .and. (len (_aCposSim) == 0 .or. ascan (_aCposSim, sx3->x3_campo) > 0)
	// Decidir se o campo deve ir para o aHeader ou nao eh uma tarefa complicada...
		if ascan (_aCposNao, sx3->x3_campo) == 0
			If ascan (_aCposSim, sx3->x3_campo) > 0 .or. (len (_aCposSim) == 0 .and. X3USO (sx3 -> X3_USADO) .And. cNivel >= sx3 -> X3_NIVEL)
				if _lNew  // Usado quando MsNewGetDados
					IF _lOrdem
					aHeader[ascan (_aCposSim, sx3->x3_campo)] := {TRIM(sx3->X3_TITULO), sx3->X3_CAMPO, sx3->X3_PICTURE, sx3->X3_TAMANHO, sx3->X3_DECIMAL, sx3 -> x3_valid, sx3->X3_USADO, sx3->X3_TIPO, sx3 -> x3_f3,      sx3->X3_CONTEXT, sx3->x3_cbox, sx3->x3_relacao, sx3->x3_when}
					else
					AADD (aHeader, {TRIM(sx3->X3_TITULO), sx3->X3_CAMPO, sx3->X3_PICTURE, sx3->X3_TAMANHO, sx3->X3_DECIMAL, sx3 -> x3_valid, sx3->X3_USADO, sx3->X3_TIPO, sx3 -> x3_f3,      sx3->X3_CONTEXT, sx3->x3_cbox, sx3->x3_relacao, sx3->x3_when})
					endif
				else  // GetDados tradicional
					IF _lOrdem
					aHeader[ascan (_aCposSim, sx3->x3_campo)] := {TRIM(sx3->X3_TITULO), sx3->X3_CAMPO, sx3->X3_PICTURE, sx3->X3_TAMANHO, sx3->X3_DECIMAL, "",              sx3->X3_USADO, sx3->X3_TIPO, sx3 -> X3_ARQUIVO, sx3->X3_CONTEXT}
					else
					AADD (aHeader, {TRIM(sx3->X3_TITULO), sx3->X3_CAMPO, sx3->X3_PICTURE, sx3->X3_TAMANHO, sx3->X3_DECIMAL, "",              sx3->X3_USADO, sx3->X3_TIPO, sx3 -> X3_ARQUIVO, sx3->X3_CONTEXT})
					endif
				endif
			endif
		Endif
	sx3 -> (DbSkip())
	Enddo
*/


	U_ML_SRArea (_aAreaAnt)

return aHeader



// --------------------------------------------------------------------------
// Gera aCols do arquivo especificado.
user function GeraCols (_sAlias, _nOrdem, _sSeekIni, _sWhile, aHeader, _lGatilh, _lVazia, _lLock, _sCond)
	local _nCampo := 0
	local aCols   := {}
	local _aAreaAnt := U_ML_SRArea ()  // Salva todas as areas de trabalho

	_lGatilh := iif (_lGatilh == NIL, .F., _lGatilh)
	_lVazia  := iif (_lVazia  == NIL, .T., _lVazia)
	_lLock   := iif (_lLock   == NIL, .F., _lLock)
	_sCond   := iif (_sCond   == NIL, ".T.", _sCond)


// Tento ler os registros do arquivo.
	(_sAlias) -> (dbsetorder (_nOrdem))
	(_sAlias) -> (dbgotop ())
	(_sAlias) -> (dbSeek (_sSeekIni, .t.))
	do while ! (_sAlias) -> (eof ()) .and. &_sWhile
		if _lLock .and. ! SoftLock (_sAlias)
			exit
		endif
		// Testa a condição do registro
		if !(&_sCond)
			(_sAlias) -> (dbSkip ())
			loop
		endif

		AADD (aCols, Array (len (aHeader) + 1))
		For _nCampo = 1 to len (aHeader)
			if (_sAlias) -> (FieldPos (aHeader [_nCampo, 2])) > 0  // Campo real. Nao testar pelo SX3 por que as vezes estah em branco!
				aCols [Len (aCols), _nCampo] := (_sAlias) -> (FieldGet (FieldPos (aHeader [_nCampo, 2])))
			else  // Campo virtual
				aCols [Len (aCols), _nCampo] := CriaVar (aHeader [_nCampo, 2])
			endif
		Next
		aCols [len (aCols), len (aCols [1])] = .F.  // Linha nao deletada
		(_sAlias) -> (dbSkip ())
	End

// Se aCols estiver vazio, tenho que inicializar com uma linha em branco
	if len (aCols) == 0 .and. _lVazia
		aCols := {array (len (aHeader) + 1)}
		For _nCampo = 1 to len (aHeader)
			aCols [1, _nCampo] := CriaVar (aHeader [_nCampo, 2])
		Next
		aCols [1, len (aCols [1])] := .F.  // Linha nao deletada
	endif


// Percorre todas as linhas de aCols executando gatilhos
	if _lGatilh
		for _nLinha = 1 to len (aCols)
			private N := _nLinha  // Algum gatilho pode estar usando N.

			// Percorre todos os campos da linha atual
			for _nCol = 1 to len (aHeader)

				// Se tem gatilho no campo atual, executa-o.
				RunTrigger (2, _nLinha, , , aHeader [_nCol, 2])
			next
		next
	endif

	U_ML_SRArea (_aAreaAnt)
return aCols



// --------------------------------------------------------------------------
// Verifica se ha campos obrigatorios nao preenchidos no aCols
user function ObrCols (_nLinha, _sMsg)
	local _nCampo 	:= 0
	local _aAreaAnt := {}
	local _aAreaSX3 := {}
	local _lRet 	:= .T.
	Local _cSX3 	:= GetNextAlias()

	_nLinha := iif (_nLinha == NIL, N, _nLinha)

	if ! GDDeleted (_nLinha)

		//SX3
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
		lOpen := Select(_cSX3) > 0
		If (lOpen)
			for _nCampo = 1 to len (aHeader)
				if (empty (aCols [_nLinha, _nCampo]))
					dbSelectArea(_cSX3)
					(_cSX3)->(dbSetOrder(2)) //X3_CAMPO
					(_cSX3)->(dbSeek(aHeader [_nCampo, 2]))
					If (Found())
						if (x3uso(&("(_cSX3)->X3_USADO")) .and. ((SubStr(BIN2STR(&("(_cSX3)->X3_OBRIGAT")),1,1) == "x") .or. VerByte(&("(_cSX3)->x3_reserv"),7)))
							msgalert (iif (_sMsg == NIL, "", _sMsg + chr (13) + chr (10)) + "Campo " + alltrim (aHeader [_nCampo, 1]) + " deve ser informado", aHeader [_nCampo, 2])
							_lRet = .F.
							exit
						endif
					EndIf
				EndIf
			next
		Endif
		(_cSX3)->(dbCloseArea())


	endif

	/*if ! GDDeleted (_nLinha)
		_aAreaAnt := getarea ()
		_aAreaSX3 := sx3 -> (getarea ())
		sx3 -> (dbsetorder (2))  // Por nome de campo
	for _nCampo = 1 to len (aHeader)
		if empty (aCols [_nLinha, _nCampo])
			if sx3 -> (dbseek (aHeader [_nCampo, 2], .F.))
				if (x3uso(SX3->X3_USADO) .and. ((SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == "x") .or. VerByte(SX3->x3_reserv,7)))
						msgalert (iif (_sMsg == NIL, "", _sMsg + chr (13) + chr (10)) + "Campo " + alltrim (aHeader [_nCampo, 1]) + " deve ser informado", aHeader [_nCampo, 2])
						_lRet = .F.
						exit
				endif
			endif
		endif
	next
		sx3 -> (restarea (_aAreaSX3))
		restarea (_aAreaAnt)
endif
	*/

return _lRet



// --------------------------------------------------------------------------
// Gera linha vazia para aCols.
user function LinVazia (aHeader)
	local _nCampo   := 0
	local _aLinha   := {}
	local _xCampo   := NIL
	local _sTipo    := ""
	local _aAreaAnt := U_ML_SRArea ()  // Salva todas as areas de trabalho
	Local _cSX3 	:= GetNextAlias()

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		for _nCampo = 1 to len (aHeader)
			dbSelectArea(_cSX3)
			(_cSX3)->(dbSetOrder(2)) //X3_CAMPO
			(_cSX3)->(dbSeek(aHeader[_nCampo, 2]))
			If (Found())
				_xCampo = CriaVar (aHeader [_nCampo, 2])
			Else
				_sTipo = aHeader [_nCampo, 8]
				do case
					case _sTipo $ "C/M"
						_xCampo = space (aHeader [_nCampo, 4])
					case _sTipo == "N"
						_xCampo = 0
					case _sTipo == "D"
						_xCampo = ctod ("")
					case _sTipo == "L"
						_xCampo = .F.
				endcase				
			EndIf
			aadd (_aLinha, _xCampo)
		next
	Endif
	(_cSX3)->(dbCloseArea())


	/*sx3 -> (dbsetorder (2))
	for _nCampo = 1 to len (aHeader)
		if sx3 -> (dbseek (aHeader [_nCampo, 2], .F.))  // Campo do dic. de dados
			_xCampo = CriaVar (aHeader [_nCampo, 2])
		else  // Campo generico
			_sTipo = aHeader [_nCampo, 8]
			do case
			case _sTipo $ "C/M"
				_xCampo = space (aHeader [_nCampo, 4])
			case _sTipo == "N"
				_xCampo = 0
			case _sTipo == "D"
				_xCampo = ctod ("")
			case _sTipo == "L"
				_xCampo = .F.
			endcase
		endif
		aadd (_aLinha, _xCampo)
	next
	*/

	aadd (_aLinha, .F.)  // Linha nao deletada

	U_ML_SRArea (_aAreaAnt)

return _aLinha


// --------------------------------------------------------------------------
// Grava em arquivo os campos do aCols.
// Parametros: - Alias do arquivo onde gravar
//             - Numero da linha do aCols a ser gravada
//             - se .T. cria novo registro no arquivo; se .F. regrava registro posicionado
//             - Array com campos adicionais a gravar (que nao estao no aCols), no formato {<nome_do_campo>, <conteudo>}
user function GrvACols (_sAlias, _nLinha, _aCpos)
	local _nCampo  := 0
	local _sCampo  := ""
	local _nposCpo := 0

	for _nCampo = 1 to len (aHeader)
		_sCampo = aHeader [_nCampo, 2]
		_nPosCpo = (_sAlias) -> (fieldpos (_sCampo))
		if _nPosCpo > 0
			(_sAlias) -> (fieldput (_nPosCpo, aCols [_nLinha, _nCampo]))
		endif
	next

// Grava campos que nao esta no aCols
	for _nCampo = 1 to len (_aCpos)
		(_sAlias) -> &(_aCpos [_nCampo, 1]) = _aCpos [_nCampo, 2]
	next
return
