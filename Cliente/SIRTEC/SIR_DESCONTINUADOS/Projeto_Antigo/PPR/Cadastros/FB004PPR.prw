#Include "rwmake.ch"

/*??????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  ? FB004PPR ? Autor ? Felipe S. Raota             ? Data ? 05/04/13  ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Unidade   ? TRS              ?Contato ? felipe.raota@totvs.com.br             ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ? Cadastro de Fun??es de Busca.                                     ???
???          ?                                                                   ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Especifico para cliente Sirtec - Projeto PPR                      ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Analista  ?  Data  ? Manutencao Efetuada                                      ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???          ?  /  /  ?                                                          ???
?????????????????????????????????????????????????????????????????????????????????ٱ?
????????????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????????*/

User Function FB004PPR()

Local cVldAlt := ".T." // Operacao: ALTERACAO
Local cVldExc := ".T." // Operacao: EXCLUSAO

dbSelectArea("SZ8")
SZ8->(dbSetOrder(1))

AxCadastro("SZ8", "Cadastro de Fun??es de Busca", cVldExc, cVldAlt)

Return