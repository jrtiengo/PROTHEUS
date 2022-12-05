#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Clbr01()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LEND,TREGS,M_MULT,P_ANT,P_ATU,P_CNT")
SetPrvt("M_SAV20,M_SAV7,L_TOTSIND,L_117,W_SINDIC,W_TOTSIND")
SetPrvt("W_COL,W_MENOR,W_MAIOR,W_XFILIAL,W_CHARA_1,W_CHARA_2")
SetPrvt("W_CHARA_3,W_MATRI,W_TURNO,W_CC,W_RECRA,L_D117")
SetPrvt("W_QTDPD117,W_QTDPD4XX,W_RECPC117,W_PCDATA,W_QTDPD114,W_RECPC114")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CLBR01    ³ Autor ³ Reiner Trennepohl     ³ Data ³ 04.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Acerto de Horas Extras                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RDMake <Programa.Ext> -w                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Incluido as perguntas no dicionario do advanced              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

DbSelectArea("SX1")
DbSetOrder(1)
if !DbSeek("CLBR01")
    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "01"
    SX1->X1_PERGUNT:= "Informe o(s) Sindicato(s)"
    SX1->X1_VARIAVL:= "mv_ch1"
    SX1->X1_TIPO   := "C"
    SX1->X1_TAMANHO:= 30
    SX1->X1_VAR01  := "MV_PAR01"
    SX1->X1_GSC    := "G"
    MsUnlock()

    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "02"
    SX1->X1_PERGUNT:= "Da Filial          ?"
    SX1->X1_VARIAVL:= "mv_ch2"
    SX1->X1_TIPO   := "C"
    SX1->X1_TAMANHO:= 2
    SX1->X1_VAR01  := "MV_PAR02"
    SX1->X1_GSC    := "G"
    MsUnlock()

    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "03"
    SX1->X1_PERGUNT:= "Ate a  Filial      ?"
    SX1->X1_VARIAVL:= "mv_ch3"
    SX1->X1_TIPO   := "C"
    SX1->X1_TAMANHO:= 2
    SX1->X1_VAR01  := "MV_PAR03"
    SX1->X1_GSC    := "G"
    MsUnlock()

    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "04"
    SX1->X1_PERGUNT:= "Da Matricula       ?"
    SX1->X1_VARIAVL:= "mv_ch4"
    SX1->X1_TIPO   := "C"
    SX1->X1_TAMANHO:= 6
    SX1->X1_VAR01  := "MV_PAR04"
    SX1->X1_GSC    := "G"
    MsUnlock()

    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "05"
    SX1->X1_PERGUNT:= "Ate a Matricula    ?"
    SX1->X1_VARIAVL:= "mv_ch5"
    SX1->X1_TIPO   := "C"
    SX1->X1_TAMANHO:= 6
    SX1->X1_VAR01  := "MV_PAR05"
    SX1->X1_GSC    := "G"
    MsUnlock()

    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "06"
    SX1->X1_PERGUNT:= "Do C Custo         ?"
    SX1->X1_VARIAVL:= "mv_ch6"
    SX1->X1_TIPO   := "C"
    SX1->X1_TAMANHO:= 9
    SX1->X1_VAR01  := "MV_PAR06"
    SX1->X1_GSC    := "G"
    MsUnlock()


    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "07"
    SX1->X1_PERGUNT:= "Ate o C Custo      ?"
    SX1->X1_VARIAVL:= "mv_ch7"
    SX1->X1_TIPO   := "C"
    SX1->X1_TAMANHO:= 9
    SX1->X1_VAR01  := "MV_PAR07"
    SX1->X1_GSC    := "G"
    MsUnlock()

    RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "08"
    SX1->X1_PERGUNT:= "Periodo Inicial    ?"
    SX1->X1_VARIAVL:= "mv_ch8"
    SX1->X1_TIPO   := "D"
    SX1->X1_TAMANHO:= 8
    SX1->X1_VAR01  := "MV_PAR08"
    SX1->X1_GSC    := "G"
    MsUnlock()

   RecLock("SX1",.T.)
    SX1->X1_GRUPO  := "CLBR01"
    SX1->X1_ORDEM  := "09"
    SX1->X1_PERGUNT:= "Periodo Final      ?"
    SX1->X1_VARIAVL:= "mv_ch9"
    SX1->X1_TIPO   := "D"
    SX1->X1_TAMANHO:= 8
    SX1->X1_VAR01  := "MV_PAR09"
    SX1->X1_GSC    := "G"
    MsUnlock()
Endif

GetSelecao()
     
Return Nil

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function GetSelecao
Static Function GetSelecao()
PERGUNTE("CLBR01",.f.)
@010,010 TO 250,600 DIALOG Dial001 TITLE "Acertos Horas Extras"
@030,005 TO 070,290
@050,010 Say "ObJetivo:  Acertar a Quantidade de Horas Extras Trabalhadas de Acordo com as Faltas ou Atrazos Ocorridos"
@090,015 BUTTON "_Paramentros"     SIZE 080,15 ACTION Fun001()// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> @090,015 BUTTON "_Paramentros"     SIZE 080,15 ACTION Execute(Fun001)
@090,110 BUTTON "_Executa"         SIZE 080,15 ACTION Fun002()// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> @090,110 BUTTON "_Executa"         SIZE 080,15 ACTION Execute(Fun002)
@090,205 BUTTON "_Abandona"        SIZE 080,15 ACTION Close(Dial001)
ACTIVATE DIALOG Dial001 CENTER
RETURN NIL

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function Fun001
Static Function Fun001()
Pergunte("CLBR01",.t.)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function Fun002
Static Function Fun002()
Close(Dial001)
Processa( {|| RunProc() } )// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Processa( {|| Execute(RunProc) } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RunProc   ³ Autor ³ Reiner Trennepohl     ³ Data ³ 04.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa o Processamento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function RunProc
Static Function RunProc()

//DBSELECTAREA("SP7")
//DBSETORDER(1)

//DBSELECTAREA("SP4")
//DBSETORDER(1)

//DBSELECTAREA("SP2")
//DBSETORDER(3)

DBSELECTAREA("SPC")
DBSETORDER(1)

DBSELECTAREA("SRA")
DBSETORDER(10)
DbGoTop()
ProcRegua(RecCount())
lEnd := .F.

#IFNDEF  WINDOWS
    tregs:=SRA->(reccount())
    m_mult:= 1
    if tregs > 0
       m_mult:= 70/tregs
    endif
    p_ant:=4
    p_atu:=4
    p_cnt:= 0
    m_sav20:=Dcursor(3)
    m_sav7:=savescreen(0,0,24,79)
#ENDIF
l_TotSind := .F.
l_117     := .F.
w_Sindic  := Mv_Par01
w_TotSind := ""
w_Col     := 1
Do While .T.
   w_Sindic  := Substr(w_Sindic,w_Col)
   w_Col     := 1
   If Subs(w_Sindic,w_Col,1) == " "
      Exit
   Endif
   w_TotSind := w_TotSind + Substr(w_Sindic,w_Col,2)
   If Substr(w_Sindic,w_Col+2,2) == ",,"
      w_Menor := Val(Substr(w_Sindic,w_Col,2)) + 1
      w_Col := w_Col + 4
      w_Maior := Val(Substr(w_Sindic,w_Col,2))
      Do While w_Menor < w_Maior
         w_TotSind := w_TotSind + StrZero(w_Menor,2)
         w_Menor := w_Menor + 1
      Enddo
      w_TotSind := w_TotSind + StrZero(w_Maior,2)
      w_Col := w_Col + 3
   Else
      w_Col := w_Col + 3
   Endif
Enddo
If Len(w_TotSind) > 0
   l_TotSind := .T.
Endif
DbSeek(MV_Par02)
DO WHILE RA_FILIAL <=MV_Par03 .And. !EOF()
   w_xFilial := RA_FILIAL
   Do While RA_FILIAL == w_xFilial .And. !EOF()

     *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     *³ Cancela ImpresÆo ao se pressionar <ALT> + <A>.               ³
     *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     #IFNDEF WINDOWS
         Inkey()
         If Lastkey() == 286
            lEnd := .T.
         EndIf
     #ENDIF
     If lEnd
        @ pRow()+ 1, 00 PSAY ' CANCELADO PELO OPERADOR . . . '
        Exit
     EndIF

     *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     *³ Incrementa Regua de Processamento.                           ³
     *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     #IFNDEF WINDOWS
        *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        *³ Atualiza barra de status ³
        *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        p_cnt :=p_cnt + 1
        p_atu := 3 + int(p_cnt*m_mult)
        if p_atu >= p_atu
           restscreen(0,0,24,79,m_sav7)
           restscreen(23,p_atu,24,p_atu+3,m_sav20)
        endif
     #ELSE
        IncProc()
     #ENDIF
     If RA_Sitfolh == "D"
        dBSkip()
        Loop
     Endif
     If RA_MAT < MV_Par04 .Or. RA_MAT > MV_Par05
        dBSkip()
        Loop
     Endif
     If RA_CC < MV_Par06 .Or. RA_CC > MV_Par07
        dBSkip()
        Loop
     Endif
     If RA_SINDICA $w_TotSind
      w_ChaRA_1 := RA_FILIAL + RA_MAT
      w_ChaRA_2 := RA_FILIAL + RA_TNOTRAB + RA_SEQTURN
      w_ChaRA_3 := RA_FILIAL + RA_TNOTRAB

      w_Matri   := RA_MAT
      w_Turno   := RA_TNOTRAB
      w_CC      := RA_CC
      w_RecRA   := Recno()

      DBSELECTAREA("SPC")
      dBSeek(w_ChaRA_1+"117")
      Do While PC_FILIAL + PC_MAT + PC_PD == w_ChaRA_1 + "117" .And. !EOF()
         If PC_DATA > Mv_Par09
            Exit
         Endif
         If PC_DATA >= MV_Par08 .And. PC_DATA <= MV_Par09
            l_D117 := .F.
            w_QtdPD117 := PC_QUANTC
            w_QtdPD4xx := 0
            w_RecPC117 := Recno()
            w_PCData := PC_DATA

            dBSeek(w_ChaRA_1+"114"+DToS(w_PCData))
            If EOF()
               dBGoTo(w_RecPC117)
               dBSkip()
               Loop
            Else
               w_QtdPD114 := PC_QUANTC
               w_RecPC114 := Recno()
            Endif

            dBSeek(w_ChaRA_1+"406"+DToS(w_PCData))
            If !EOF()
               If PC_PDI == "791"
                  If PC_QUANTC > PC_QUANTI
                     w_QtdPD4xx := w_QtdPD4xx + (PC_QUANTC - PC_QUANTI)
                  Endif
               Else
                  w_QtdPD4xx := w_QtdPD4xx + PC_QUANTC
               Endif
            Endif

            dBSeek(w_ChaRA_1+"413"+DToS(w_PCData))
            If !EOF()
               If PC_PDI == "791"
                  If PC_QUANTC > PC_QUANTI
                     w_QtdPD4xx := w_QtdPD4xx + (PC_QUANTC - PC_QUANTI)
                  Endif
               Else
                  w_QtdPD4xx := w_QtdPD4xx + PC_QUANTC
               Endif
            Endif

            dBSeek(w_ChaRA_1+"414"+DToS(w_PCData))
            If !EOF()
               If PC_PDI == "791"
                  If PC_QUANTC > PC_QUANTI
                     w_QtdPD4xx := w_QtdPD4xx + (PC_QUANTC - PC_QUANTI)
                  Endif
               Else
                  w_QtdPD4xx := w_QtdPD4xx + PC_QUANTC
               Endif
            Endif

            dBSeek(w_ChaRA_1+"416"+DToS(w_PCData))
            If !EOF()
               If PC_PDI == "791"
                  If PC_QUANTC > PC_QUANTI
                     w_QtdPD4xx := w_QtdPD4xx + (PC_QUANTC - PC_QUANTI)
                  Endif
               Else
                  w_QtdPD4xx := w_QtdPD4xx + PC_QUANTC
               Endif
            Endif
            
            If w_QtdPD4xx > 0
               l_117 := .T.
               If w_QtdPD117 >= w_QtdPD4xx
                  w_QtdPD117 := w_QtdPD117 - w_QtdPD4xx
                  w_QtdPD114 := w_QtdPD114 + w_QtdPD4xx
                  If w_QtdPD117 == 0
                     l_D117 := .T.
                  Endif
               Else
                  l_D117     := .T.
                  w_QtdPD114 := w_QtdPD114 + w_QtdPD117
               Endif
            Endif
         Endif
         dBGoTo(w_RecPC114)
         RecLock("SPC",.F.)
         SPC->PC_QUANTC := w_QtdPD114
         MsUnlock()

         dBGoTo(w_RecPC117)
         If l_D117
            RecLock("SPC",.F.)
            SPC->PC_QUANTC := w_QtdPD117
            dBDelete()
            MsUnlock()
         Else
            RecLock("SPC",.F.)
            SPC->PC_QUANTC := w_QtdPD117
            MsUnlock()
         Endif
         dBSkip()
      Enddo
      DBSELECTAREA("SRA")
      dBGoTo(w_RecRA)
     Endif
     
     dBSkip()
   Enddo
Enddo
If l_117
   MsgBox ("Foram Encotradas Horas Extras a 100%, os C lculos dos Eventos 114 e 117, Foram Refeitos.","Aten‡„o !!!","ALERT")
Else
   MsgBox ("N„o Foi Necess rio o C lculo de Horas Extras, pois, n„o Encotrou-se Hor rio Extra com Algum Tipo de Desconto Referente a Atrazo ou Sa¡da Antecipada.","Aten‡„o !!!","ALERT")
Endif
Return

