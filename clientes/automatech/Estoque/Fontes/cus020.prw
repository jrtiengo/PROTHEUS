#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 17/01/03

User Function Cus020()        // incluido pelo assistente de conversao do AP5 IDE em 17/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TITULO,TAMANHO,CDESC1,CDESC2,CDESC3,ARETURN")
SetPrvt("ALINHA,NOMEPROG,NLASTKEY,CSTRING,WNREL,LI")
SetPrvt("CBTXT,CBCONT,CABEC1,CABEC2,M_PAG,AC_1")
SetPrvt("AC_2,DDATAINI,CFILSD3,COP,NVINI1,NVINI2")
SetPrvt("NVINI3,NVINI4,NVINI5,NAPRINI1,NAPRINI2,NAPRINI3")
SetPrvt("NAPRINI4,NAPRINI5,LTEM,")

/*....
      CUS020.PRW - Ajuste do Saldo Inicial das Ordens de Produ‡Æo

      - Definicao: Roberto Mazzarolo
        Confeccao: Roberto Mazzarolo
      ....*/


   Titulo  := "Saldo das Ops "
   Tamanho :="P"
   cDesc1  :=OemToAnsi("Listando os Saldos das Ops")
   cDesc2  :=OemToAnsi("")
   cDesc3  :=OemToAnsi("")
   aReturn :={"Zebrado",1,"Administracao",2,2,1,"",1 }
   aLinha  :={ }
   NomeProg:="CUS020"
   nLASTKEY:= 0
   cString :="SB2"
   WnRel   :="CUS020"
   LI      := 99
   *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   *³ Ajuste de parametros via SETPRINT                            ³
   *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   WnRel:=SetPrint(cString,"CUS020","",Titulo,cDesc1,cDesc2,cDesc3,.T.)

   if nLastKey == 27
      return
   endif
   *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   *³ Aceita parametros e faz ajustes necessarios                  ³
   *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   setdefault(aReturn,cString)

   if nLastKey == 27
      return
   endif

   *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   *³ variaveis utilizadas para a impressao do cabecalho e rodape  ³
   *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cbtxt:= space(10)
   cbcont:= 0
   Cabec1 :="*   Ops             Saldo Gravado       Saldo Calculado     Data encerramento"
   Cabec2 :=""
           *     zzzzzzzzzzzzzzz    99      19/04/96
           *0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
           *0          1         2         3         4         5         6         7

   cstring:="SB2"
   m_pag := 1

   AC_1 := 0
   AC_2 := 0

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Incluido as perguntas no dicionario do advanced              ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX1")
DbSetOrder(1)
if !DbSeek("CUS020")
      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "CUS020"
      SX1->X1_ORDEM  := "01"
      SX1->X1_PERGUNT:= "Ate a Data         ?"
      SX1->X1_VARIAVL:= "mv_ch1"
      SX1->X1_TIPO   := "D"
      SX1->X1_TAMANHO:= 8
      SX1->X1_VAR01  := "MV_PAR01"
      SX1->X1_GSC    := "G"
      MsUnlock()

      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "CUS020"
      SX1->X1_ORDEM  := "02"
      SX1->X1_PERGUNT:= "Apaga Estornos     ?"
      SX1->X1_VARIAVL:= "mv_ch2"
      SX1->X1_TIPO   := "N"
      SX1->X1_TAMANHO:= 1
      SX1->X1_VAR01  := "MV_PAR02"
      SX1->X1_GSC    := "C"
      SX1->X1_Def01  := "Sim"
      SX1->X1_Def02  := "Nao"
      MsUnlock()
End

Pergunte("CUS020",.F.)

@ 000,000 TO 380,500 DIALOG DIA001 TITLE "Re-Calculo Saldo Inicilal Das OPs"
@ 010,010 BITMAP SIZE 110,40 FILE "SSUL.BMP"
@ 060,005 TO 155,245
@ 070,010 say "Objetivo: Re-Calcular o Saldo Inicial das Ordens de Producao Ate  "
@ 080,010 Say "a Data Informada no parametro - As Requisicoes Soma no VINI e as "
@ 090,010 say "Producoes soma no APRINI . As Requisicoes/producaoes apos a data "
@ 100,010 say "informada serao desconsideradas.  "
@ 130,010 BUTTON "_Parametros" SIZE 100,15 ACTION Pergunte("CUS020",.T.)
@ 130,130 BUTTON "_Calculo"    SIZE 100,15 ACTION Calcula()// Substituido pelo assistente de conversao do AP5 IDE em 17/01/03 ==> @ 130,130 BUTTON "_Calculo"    SIZE 100,15 ACTION Execute(Calcula)
@ 160,010 BMPBUTTON TYPE 1 ACTION Close(DIA001)
ACTIVATE DIALOG DIA001 CENTERED

Return

// Substituido pelo assistente de conversao do AP5 IDE em 17/01/03 ==> Function CalCula
Static Function CalCula()

   Pergunte("CUS020",.F.)

   DbSelectARea("SD3")
   DbSetOrder(1)  // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

   DbSelectARea("SC2")
   DbSetOrder(1)  // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

   Processa( {|| ZeraOp() },"Re-Calculando Saldo Inicial das OPs","Aguarde.." )// Substituido pelo assistente de conversao do AP5 IDE em 17/01/03 ==>    Processa( {|| Execute(ZeraOp) },"Re-Calculando Saldo Inicial das OPs","Aguarde.." )

   Close(Dia001)

Return


// Substituido pelo assistente de conversao do AP5 IDE em 17/01/03 ==> Function ZeraOP
Static Function ZeraOP()

   ddataini := ctod("01/12/99" )

   cFilSd3 := xFilial("SD3")

   DbSelectARea("SC2")
   ProcRegua(Reccount())
   DbGotop()
   While !eof()

      IncProc()

      cOp := Sc2->C2_Num + Sc2->C2_Item + Sc2->C2_Sequen

      nVIni1   := nVIni2   := nVIni3   := nVIni4   := nVIni5   := 0
      nAprIni1 := nAprIni2 := nAprIni3 := nAprIni4 := nAprIni5 := 0

      lTem := .f.
      DbSelectArea("SD3")
      DbSeek( cFilSd3 + cOp )
      While !Eof() .and. D3_Op == cOp


          If D3_Emissao <= Mv_Par01 .and. Sd3->d3_Estorno <> "S"
             If d3_emissao >= dDataini
                ltem := .t.
             End
             /*...
                   Este movimento refere-se a ordem de producao em questao e esta
                   com data anterior ou igual ao saldo desejado
                   ...*/
             If Left( Sd3->D3_Cf,1)  == "R"
                //... Requisiacao - Soma no VIni
                nVini1   := nVIni1   + Sd3->D3_Custo1
                nVini2   := nVIni2   + Sd3->D3_Custo2
                nVini3   := nVIni3   + Sd3->D3_Custo3
                nVini4   := nVIni4   + Sd3->D3_Custo4
                nVini5   := nVIni5   + Sd3->D3_Custo5

             ElseIf Left( Sd3->D3_Cf,1)  == "D"
                //... Devolucao diminui do VIni
                nVini1   := nVIni1   - Sd3->D3_Custo1
                nVini2   := nVIni2   - Sd3->D3_Custo2
                nVini3   := nVIni3   - Sd3->D3_Custo3
                nVini4   := nVIni4   - Sd3->D3_Custo4
                nVini5   := nVIni5   - Sd3->D3_Custo5

             Else
                //... Producao Soma no AprIni ( Apropriacao ao produto )
                nAprIni1 := nAprIni1 + Sd3->D3_Custo1
                nAprIni2 := nAprIni2 + Sd3->D3_Custo2
                nAprIni3 := nAprIni3 + Sd3->D3_Custo3
                nAprIni4 := nAprIni4 + Sd3->D3_Custo4
                nAprIni5 := nAprIni5 + Sd3->D3_Custo5

             End
          ElseIf Mv_Par02 == 1 .and. Sd3->d3_Estorno == "S"
             //... Deletando os estornos
             RecLock("SD3" ,.f.)
             DbDelete()
             MsUnLock()

          End

          DbSkip()
      EndDo


      DbSelectArea("SC2")
      
      IF EMPTY(C2_DATRF) .OR. C2_DATRF > MV_PAR01
         Reclock("SC2",.f.)
         Replace C2_Vini1   With nVIni1   ,;
                 C2_AprIni1 With nAprIni1 
                 //C2_Vini2   With nVIni2   ,;
                 //C2_Vini3   With nVIni3   ,;
                 //C2_Vini4   With nVIni4   ,;
                 //C2_Vini5   With nVIni5   ,;
                 
                 //C2_AprIni2 With nAprIni2 ,;
                 //C2_AprIni3 With nAprIni3 ,;
                 //C2_AprIni4 With nAprIni4 ,;
                 //C2_AprIni5 With nAprIni5
      
         MsUnlock()
      ELSE
         if ltem .and. c2_vini1 <> nvini1  
            If Li > 55
               Li := Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,18) + 1
            End
            @ li , 005 PSay C2_Num + C2_item
            @ li , 020 PSay Transform(c2_vini1 , "@e 99999,999.99  " )
            @ li , 040 PSay Transform(nvini1, "@e 99999,999.99" )
            @ li , 060 PSay C2_DatRf
            LI := LI + 1
            AC_1 := AC_1 + C2_VINI1
            AC_2 := AC_2 + nvini1
         End
      ENDIF
      DbSkip()

   EndDo

   IF LI < 80
      @ li , 020 PSay Transform(AC_1 , "@e 99999,999.99  " )
      @ li , 040 PSay Transform(AC_2, "@e 99999,999.99" )
      RODA(CBCONT,CBTXT,"M")
   ENDIF

   if aReturn[5] == 1
      set printer to commit
      ourspool(wnrel)
   endif

   FT_PFLUSH()

Return


