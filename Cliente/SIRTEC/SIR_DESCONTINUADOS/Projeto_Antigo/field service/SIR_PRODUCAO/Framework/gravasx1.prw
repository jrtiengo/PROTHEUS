// Programa...: GravaSX1
// Autor......: Robert Koch
// Data.......: 13/02/2002
// Cliente....: Generico
// Descricao..: Atualiza respostas das perguntas no SX1

#include "rwmake.ch"

// --------------------------------------------------------------------------
// Parametros:
// 1 - Grupo de perguntas a atualizar
// 2 - Codigo (ordem) da pergunta
// 3 - Dado a ser gravado
User function GravaSX1 (_sGrupo, _sPerg, _xValor)

Local _aAreaAnt  := GetArea()
Local _sUserName := ""
Local _sMemoProf := ""
Local _nTamanho  := 0
Local _nLinha    := 0
Local _aLinhas   := {}

// Parametro Flag que identifica Atualiza ou nao o SX1
If GetNewPar("ML_GRVPSX1","S") <> "S"
	RestArea(_aAreaAnt)
	Return(.T.)
Endif


/*
If sx1 -> (dbseek (_sGrupo + _sPerg, .F.))
	
	// Atualizarei sempre no SX1. Depois vou ver se tem profile de usuario.
	do case
		case sx1 -> x1_gsc == "C"
			reclock ("SX1", .F.)
			sx1 -> x1_presel = _xValor
			sx1 -> x1_cnt01  = ""
			sx1 -> (msunlock ())
		case sx1 -> x1_gsc == "G"
			reclock ("SX1", .F.)
			sx1 -> x1_presel = 0
			if sx1 -> x1_tipo == "D"
				sx1 -> x1_cnt01 = "'" + dtoc (_xValor) + "'"
			elseif sx1 -> x1_tipo == "N"
				sx1 -> x1_cnt01 = str (_xValor, sx1 -> x1_tamanho, sx1 -> x1_decimal)
			elseif sx1 -> x1_tipo == "C"
				sx1 -> x1_cnt01 = _xValor
			endif
			sx1 -> (msunlock ())
		otherwise
			msgbox ("Tipo " + sx1 -> x1_gsc + " ainda nao implementado na funcao _GravaSX1", "Erro")
	endcase
	
	// Antes da versao 8.11 nao havia profile de usuario. Na versao 9 nao sei como serah...
	If "P10" $ cVersao
		psworder (1)  // Ordena arquivo de senhas por ID do usuario
		PswSeek(__cUserID)  // Pesquisa usuario corrente
		_sUserName := PswRet(1) [1, 2]
		
		// Encontra e atualiza profile deste usuario para a rotina / pergunta atual.
		// Enquanto o usuario nao alterar nenhuma pergunta, ficarah usando do SX1 e
		// seu profile nao serah criado.
		If FindProfDef (_sUserName, _sGrupo, "PERGUNTE", "MV_PAR")
			
			// Carrega memo com o profile do usuario (o profile fica gravado
			// em um campo memo)
			_sMemoProf := RetProfDef (_sUserName, _sGrupo, "PERGUNTE", "MV_PAR")
			
			// Monta array com as linhas do memo (tem uma pergunta por linha)
			_aLinhas = {}
			for _nLinha = 1 to MLCount (_sMemoProf)
				aadd (_aLinhas, alltrim (MemoLine (_sMemoProf,, _nLinha)) + chr (13) + chr (10))
			next
			
			// Monta uma linha com o novo conteudo do parametro atual.
			// Pos 1 = tipo (numerico/data/caracter...)
			// Pos 2 = '#'
			// Pos 3 = GSC
			// Pos 4 = '#'
			// Pos 5 em diante = conteudo.
			_sLinha = sx1 -> x1_tipo + "#" + sx1 -> x1_gsc + "#" + iif (sx1 -> x1_gsc == "C", cValToChar (sx1 -> x1_presel), sx1 -> x1_cnt01) + chr (13) + chr (10)
			
			// Se foi passada uma pergunta que nao consta no profile, deve tratar-se
			// de uma pergunta nova, pois jah encontrei-a no SX1. Entao vou criar uma
			// linha para ela na array. Senao, basta regravar na array.
			if val(_sPerg) > len (_aLinhas)
				aadd (_aLinhas, _sLinha)
			else
				// Grava a linha de volta na array de linhas
				_aLinhas [val (_sPerg)] = _sLinha
			endif
			
			// Remonta memo para gravar no profile
			_sMemoProf = ""
			for _nLinha = 1 to len (_aLinhas)
				_sMemoProf += _aLinhas [_nLinha]
			next
			
			// Grava o memo no profile
			WriteProfDef(_sUserName, _sGrupo, "PERGUNTE", "MV_PAR", ;  // Chave antiga
			_sUserName, _sGrupo, "PERGUNTE", "MV_PAR", ;  // Chave nova
			_sMemoProf)  // Novo conteudo do memo.
		endif
	Else
                //msgbox ("Versao nova.... Revisar Rotina de Gravacao do SX1 -> GRAVASX1.PRW", "Revisar Programa")
	Endif
Else
	msgbox ("Funcao " + procname () + ": grupo de perguntas " + _sGrupo + "/" + _sPerg + " nao encontrado no SX1", "Erro")
Endif
*/

RestArea(_aAreaAnt)

Return(.T.)
