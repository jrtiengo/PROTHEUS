#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Gtc501()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("FLAG,M->C5_MENNOTA,M->C6_BLOQUEI,")

FLAG:= "N"
if sa1->a1_risco == "E" .OR. sa1->a1_risco == "B"
   MsgBox("Credito bloqueado. Consulte o departamento Financeiro.","Pode Continuar","INFO")
   FLAG := "S"
Endif
IF FLAG == "S"
   M->C5_MENNOTA := "Credito bloqueado. Consulte o departamento Financeiro."
   //M->C6_BLOQUEI:= "S"
   FLAG := "N"
Endif
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> __Return(M->C5_MENNOTA,M->C6_BLOQUEI)
//Return(M->C5_MENNOTA,M->C6_BLOQUEI)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00
Return(M->C5_MENNOTA)
