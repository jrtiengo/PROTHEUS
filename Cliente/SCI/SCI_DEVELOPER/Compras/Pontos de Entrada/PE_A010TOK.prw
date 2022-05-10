#include 'totvs.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Funcao: A010TOk      || Autor: Marcelo Tarasconi   || Data: 24/04/20   ||
||-------------------------------------------------------------------------||
|| Descricao: PE chamado para validar inclusao/alteracao de Produtos       ||
||-------------------------------------------------------------------------||
|| Uso: MP 12                                                              ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
User Function A010TOk()

Local lTudoOk	:= .t.
Local aArea := GetArea()
Local aAreaSB1 := SB1->(GetArea())

dbSelectArea("SB1")
dbSetOrder(5) //Filial + codbar 
If !Empty(M->B1_CODBAR) .and. dbSeek(xFilial("SB1")+M->B1_CODBAR,.f.) .and. M->B1_COD <> SB1->B1_COD
	
	Help(NIL, NIL, "Validacao, atencao", NIL, "Codigo de Barras ja existente", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o codigo de barras"}) 
	lTudoOk	:= .f.
EndIf

RestArea(aAreaSB1)
RestArea(aArea)
Return( lTudoOk )