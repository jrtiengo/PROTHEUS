#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Gtc601()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("M->C6_BLQ,")

IF SA1->A1_RISCO == "E" .OR. SA1->A1_RISCO == "B"
   MsgBox("Credito bloqueado. Consulte o departamento Financeiro.","Pode Continuar","INFO")
   M->C6_BLQ:= "S"
ELSE
   M->C6_BLQ:= " "
Endif
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> __Return(M->C6_BLQ)
Return(M->C6_BLQ)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00



