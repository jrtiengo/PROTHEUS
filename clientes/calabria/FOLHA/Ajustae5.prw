#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/03/00

User Function Ajustae5()        // incluido pelo assistente de conversao do AP5 IDE em 29/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CTIPODOC,")

DbSelectArea("SE5")
DbSetOrder(1)
DbSeek(xFilial()+"01022000",.T.)
While !Eof() .and. SE5->E5_FILIAL == xFilial()
      _cTipoDoc:=SE5->E5_TIPODOC
      If E5_TIPODOC == "VL" .OR. SE5->E5_TIPODOC == "BA"

         If SE5->E5_RECPAG == "R"
            // Localizando o registro no Contas a Receber
            DbSelectArea("SE1")
            DbSetOrder(1)
            If DbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
               If !Empty(SE1->E1_LOTE) .OR. SE1->E1_SITUACA $ "27"
                  _cTipoDoc := "BA"
               Else
                  _cTipoDoc := "VL"
               EndIf
            EndIf

         Else

            If Empty(SE5->E5_NUMCHEQ)
               _cTipoDoc := "BA"
            EndIf
            If SE5->E5_MOTBX == "DEB" .OR. Left(SE5->E5_BANCO,2) == "CX"
               _cTipoDoc := "VL"
            EndIf
                       
         EndIf 

         //Atualizando SE5
         DbSelectArea("SE5")
         RecLock("SE5",.F.)
         SE5->E5_TIPODOC := _cTipoDoc
         MsUnlock()

      Endif

      DbSkip()

Enddo

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 29/03/00

