#INCLUDE "rwmake.ch"

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?STCA025   ? Autor ? AP6 IDE            ? Data ?  29/11/07   ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Codigo gerado pelo AP6 IDE.                                ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? AP6 IDE                                                    ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/

User Function STCA025


//?????????????????????????????????????????????????????????????????????Ŀ
//? Declaracao de Variaveis                                             ?
//???????????????????????????????????????????????????????????????????????

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZZ2"

dbSelectArea("ZZ2")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Avaliacoes",cVldExc,cVldAlt)

Return