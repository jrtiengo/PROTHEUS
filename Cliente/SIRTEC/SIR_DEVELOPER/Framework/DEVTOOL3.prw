#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} DEVTOOL3

	Executa a lista de ferramentas passado por paramêtro

	@param	  aTools, formato {VERSÃO, DESCRICAO, FUNCAO}
	@author  Fernando Alencar
	@version P11 e P10
	@since   13/11/2011
	@return
	@obs

/*/
User Function DEVTOOL3(aTools)

	Local aEtapa := {1,Len(aTools)}
	Local i		 := 0

	For i := 1 To Len(aTools)

		If xExistB(aTools[I][3]) // criada static funcion "xExistB" para testar funcao fora do Loop //ExistBlock(aTools[I][3])
			aTools := ExecBlock(aTools[I][3],.F.,.F.,{aEtapa})
		Else
			_ShowMsg(aTools[I][2])
		EndIf

	Next

Return Nil

Static Function _ShowMsg(cTool)

	Local cTitulo := "Ferramenta não encontrada"
	Local cTexto := "Não foi possível executar a ferramenta: "+cTool+", pois a mesma não encontra-se compilada, contate o administrador ou leia o manual técnico!"
	Local aBotoes := {{2,.t.,{||  .f.}}}
	Local nTamanho := 1

	AVISO(cTitulo, cTexto, aBotoes, nTamanho)

Return()


//ExistBlock - funcionalidade nao funciona em Loop
Static Function xExistB(_cParam)
 
Local _lRet := .F.

If (ExistBlock(_cParam))
	_lRet := .T.
EndIf

Return(_lRet)
