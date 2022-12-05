#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Gtc502()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NREC,NSELECT,NORDER,M->C5_PARC1,M->C5_DATA1,")

nRec := Recno()
nSelect := Select()
nOrder  := DbSetOrder()

DbSelectArea("SE1")
DbSetOrder(2)
IF DbSeek(xFilial("SE1")+M->C5_CLIENTE+M->C5_LOJACLI+"   "+M->C5_RA+" "+"RA ")
   M->C5_PARC1:= SE1->E1_SALDO
   M->C5_DATA1:= SE1->E1_VENCREA
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>    __Return(M->C5_RA)
Return(M->C5_RA)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

ELSE
   Msgbox("Nao foi encontrado o Adiantamento para este cliente"+chr(13)+;
   "Tecle <F3> para consulta das RA's.","Adiantamentos","INFO")
   // STOP = Pare
   // INFO = Interrogacao
   // ALERT= Exclama‡Æo
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>    __Return(space(6))
Return(space(6))        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00
Endif   

DbSelectArea( nSelect )
DbSetOrder( nOrder )
DbGoto( nRec )

