#INCLUDE "rwmake.ch"

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?NOVO3     ? Autor ? AP6 IDE            ? Data ?  24/06/19   ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Codigo gerado pelo AP6 IDE.                                ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? AP6 IDE                                                    ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/

User Function CRIA_Z11()


//?????????????????????????????????????????????????????????????????????Ŀ
//? Declaracao de Variaveis                                             ?
//???????????????????????????????????????????????????????????????????????

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "Z11"

dbSelectArea("Z11")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de . . .",cVldExc,cVldAlt)

Return
