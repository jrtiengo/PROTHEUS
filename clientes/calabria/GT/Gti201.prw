#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Gti201()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NORDER,NSELECT,NREC,AREA_ANTI1,ORDER_ANTI1,REC_ANTI1")
SetPrvt("M->I2_DEBITO,")

nOrder  := DbSetOrder()
nSelect := Select()
nRec    := Recno()

DbSelectARea("SI1")
Area_AntI1  := Select()
Order_AntI1 := IndexOrd()
Rec_AntI1   := Recno()

IF LEN(ALLTRIM(M->I2_DEBITO)) <= 4 // Entra quando for conta reduzida

   DbSelectArea("SI1")
   DbSetOrder(3)
   If DbSeek(xFilial("SI1")+M->I2_DEBITO) .AND. ACOLS[N,2] == "D"
      M->I2_DEBITO := SI1->I1_CODIGO
      DbSetOrder(1)
   ElseIf DbSeek(xFilial("SI1")+M->I2_DEBITO) .AND. ACOLS[N,2] == "X"
      M->I2_DEBITO := SI1->I1_CODIGO
      DbSetOrder(1)
   Else
      Msgbox("Informe o tipo de lancamento D -> D‚bito ou C -> Cr‚dito"+chr(13)+;
             "ou entao pode ser que a conta nao pertence ao tipo informado.","Impossivel Continuar","INFO")
      M->I2_DEBITO := SPACE(15)
   ENDIF   
ELSE

   DbSelectArea("SI1")
   DbSetOrder(1)
   If DbSeek(xFilial("SI1")+M->I2_DEBITO) .AND. ACOLS[N,2] == "D"
      M->I2_DEBITO := SI1->I1_CODIGO
   ElseIf DbSeek(xFilial("SI1")+M->I2_DEBITO) .AND. ACOLS[N,2] == "X"
      M->I2_DEBITO := SI1->I1_CODIGO
   Else
      Msgbox("Informe o tipo de lancamento D -> D‚bito ou C -> Cr‚dito"+chr(13)+;
             "ou entao pode ser que a conta nao pertence ao tipo informado.","Impossivel Continuar","INFO")
      M->I2_DEBITO := SPACE(15)
   ENDIF   
ENDIF

DbSelectARea("SI1")
DbSetOrder(Order_AntI1)
DbGoTo(Rec_AntI1)

DbSelectArea( nSelect )
DbSetOrder( nOrder )
DbGoto( nRec )

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> __RETURN(M->I2_DEBITO)
Return(M->I2_DEBITO)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00
