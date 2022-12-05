#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function calr010()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TITULO,CSTRING,WNREL,CDESC1,CDESC2,TAMANHO")
SetPrvt("ARETURN,NLASTKEY,CPERG,NOMEPROG,CABEC2,M_PAG")
SetPrvt("NTIPO,LI,CABEC1,NC2NUM,N1,DESC")


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CALR010  ³ Autor ³ CARLOS R. GALIMBERTI  ³ Data ³ 05/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Emissao das Ordens de Servico                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

ValidPerg() // Valida perguntas no SX1

titulo      := "Emissao da Ordens de Servico"
cString     := "SD3"
wnrel       := "PRBR10"
cDesc1      := "O objetivo deste relat¢rio e' emitir as ordens servico em"
cDesc2      := "aberto conforme parametros."
Tamanho     := "P"
aReturn     := {"Zebrado",1,"Administracao",2,2,1,"",1}
nLastKey    := 0
cPerg       := NomeProg := "CALR10"
Cabec2      := ""
m_pag       := 1
nTipo       := 18  // Normal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // OP inicial                                   ³
//³ mv_par02     // OP final                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,"",.F.,"",,Tamanho)
If nLastKey == 27
   Set Filter To
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter To
   Return
Endif

#IFDEF WINDOWS
       RptStatus({|lEnd| RCAL010Imp()},titulo)// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>        RptStatus({|lEnd| Execute(RCAL010Imp)},titulo)
#ENDIF

Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function RCAL010Imp
Static Function RCAL010Imp()


Li := 68
DbSelectArea("SZA")
SetRegua(Reccount())
DbSetOrder(1)
DbSeek(xFilial("SZA")+ MV_PAR01,.T.)

While !eof() .and. ZA_NUM <= MV_PAR02

   If li > 58
      Cabec1      := "Numero: " + ZA_NUM
      Li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo) +1
   EndIf

   DbSelectArea("SC2")
   DBSetOrder(1)
   DbSeek( xFilial()+ LEFT(SZA->ZA_OP,6))

   DbSelectArea("SA1")
   DBSetOrder(1)
   DbSeek( xFilial("SA1")+ SC2->C2_CLIENTE)

   @ Li,000 PSAY "Cliente : " + SA1->A1_NOME
   @ Li,057 PSAY "FONE RES : "+ SA1->A1_TEL
   Li := Li +1
   DbSelectArea("SC2")
   @ Li,000 PSAY "CHASSI : " + SC2->C2_CHASSI
   @ Li,057 PSAY "PLACA  : " + SC2->C2_PLACA
   Li := Li +1
   @ Li,000 PSAY "ANO    : " + SC2->C2_ANO
   @ Li,057 PSAY "MODELO : " + SC2->C2_MODELO
   Li := Li +1
   @ Li,000 PSAY "MARCA  : " + SC2->C2_MARCA
   Li := Li +1
   @ Li,000 PSAY "KM: " + STR(SC2->C2_KM,12,2)
   @ Li,057 PSAY "RECEBIDO EM : " + DTOC(SC2->C2_EMISSAO)
   Li := Li +1
   @ Li,000 PSAY "PROMETIDO PARA : " + DTOC(SC2->C2_DATPRF)
   @ Li,057 PSAY "ENTREGUE EM : __/__/__" 
   Li := Li +2
   @ Li,000 PSAY Replicate("-",80)
   Li := Li +1
   @ Li,000 PSAY "CODIGO              DESCRIMINACAO                                          VALOR"
   Li := Li +1
   @ Li,000 PSAY Replicate("-",80)
   Li := Li +2

   nC2Num := SZA->ZA_NUM

   DbSelectArea("SZA")
   While !eof() .and. SZA->ZA_NUM == nC2Num

     DbSelectArea("SC2")
     DBSetOrder(1)
     DbSeek( xFilial()+ LEFT(SZA->ZA_OP,6))
     n1 := 1

     DBSelectArea("SZA")
     @ Li,000 PSAY SZA->ZA_COD
     @ Li,069 PSAY SZA->ZA_VALOR Picture "@E 999,999.99"
     While .T.
       Desc := MemoLine(SZA->ZA_DESC,50,n1,1,.T.)
       @ Li,020 PSAY DESC
       Li := Li +1

       if Li > 66
          Li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo) +1
          @ Li,000 PSAY Replicate("-",80)
          Li := Li +1
          @ Li,000 PSAY "CODIGO              DESCRIMINACAO                                         VALOR"
          Li := Li +1
          @ Li,000 PSAY Replicate("-",80)
          Li := Li +2
       EndIf

       n1 := n1 +1

       if Empty( Desc )
          Exit
       endif

     EndDo
     IncRegua()
     DbSkip()
     Li := Li +2

   Enddo
   IF LI+8 > 66
      Li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo) +1
      @ Li,000 PSAY Replicate("-",80)
      Li := Li +1
      @ Li,000 PSAY "CODIGO              DESCRIMINACAO                                         VALOR"
      Li := Li +1
      @ Li,000 PSAY Replicate("-",80)
      Li := Li +2
   ENDIF
   Li := Li +3
   @ Li, 020 PSAY "AUTORIZACAO"
   Li := Li +1
   @ Li, 000 PSAY "Autorizo a execucao do(s) servico(s) de "
   Li := Li +1
   @ Li, 000 PSAY "conformidade com a presente Ordem de Servico."
   Li := Li +3
   @ Li,030 PSAY "Em ___/___/___"
   Li := 67
   Eject

Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set Filter To
dbSetOrder(1)

Set device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

RETURN

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function ValidPerg
Static Function ValidPerg()

DbSelectArea("SX1")
DbSetOrder(1)
IF !DbSeek( "CALR10")

   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := "CALR10"
   SX1->X1_ORDEM  := "01"
   SX1->X1_PERGUNT:= "Da Ordem Servico"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:=  6
   SX1->X1_GSC    := "G"
   SX1->X1_VAR01  := "MV_PAR01"
   MSUNLOCK()

   RecLock("SX1",.T.)
   SX1->X1_GRUPO  := "CALR10"
   SX1->X1_ORDEM  := "02"
   SX1->X1_PERGUNT:= "Ate a Ordem Servico"
   SX1->X1_TIPO   := "C"
   SX1->X1_TAMANHO:=  6
   SX1->X1_GSC    := "G"
   SX1->X1_VAR01  := "MV_PAR02"
   MSUNLOCK()
ENDIF

RETURN
