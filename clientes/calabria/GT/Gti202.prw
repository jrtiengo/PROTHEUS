#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Gti202()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NSELECT,NORDER,NREC,AREA_ANTI1,ORDER_ANTI1,REC_ANTI1")
SetPrvt("M->I2_CREDITO,")

nSelect:= Select()
nOrder := DbSetOrder()
nRec   := Recno() // registro atual do arquivo exemplo SI2

DbSelectARea("SI1")
Area_AntI1  := Select()
Order_AntI1 := IndexOrd()
Rec_AntI1   := Recno()

if len(alltrim(M->I2_CREDITO)) <= 4

   DbSelectArea("SI1")
   DbSetOrder(3)
   IF DbSeek(xFilial("SI1")+M->I2_CREDITO) .AND. ACOLS[N,2] == "C" 
      M->I2_CREDITO := SI1->I1_CODIGO
      DbSetOrder(1)
   ElseIf DbSeek(xFilial("SI1")+M->I2_CREDITO) .AND. ACOLS[N,2] == "X"
      M->I2_CREDITO := SI1->I1_CODIGO
      DbSetOrder(1)
   ELSE
      Msgbox("Informe o tipo de lancamento D -> D‚bito ou C -> Cr‚dito"+chr(13)+;
      "ou entao pode ser que a conta nao pertence ao tipo informado.","Impossivel Continuar","INFO")
      M->I2_CREDITO := SPACE(15)
   Endif   
Else

   DbSelectArea("SI1")
   DbSetOrder(1)
   IF DbSeek(xFilial("SI1")+M->I2_CREDITO) .AND. ACOLS[N,2] == "C" 
      M->I2_CREDITO := SI1->I1_CODIGO
   ElseIf DbSeek(xFilial("SI1")+M->I2_CREDITO) .AND. ACOLS[N,2] == "X"
      M->I2_CREDITO := SI1->I1_CODIGO
   ELSE
      Msgbox("Informe o tipo de lancamento D -> D‚bito ou C -> Cr‚dito"+chr(13)+;
      "ou entao pode ser que a conta nao pertence ao tipo informado.","Impossivel Continuar","INFO")
      M->I2_CREDITO := SPACE(15)
   Endif   
Endif

DbSelectARea("SI1")
DbSetOrder(Order_AntI1)
DbGoTo(Rec_AntI1)

DbSelectArea( nSelect )
DbSetOrder( nOrder )
DbGoto( nRec )

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> __RETURN(M->I2_CREDITO)
Return(M->I2_CREDITO)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00
