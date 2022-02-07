#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 17/11/00

User Function MANSD1CT()        // incluido pelo assistente de conversao do AP5 IDE em 17/11/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CPERG,VCONTADOR,CCLIENTE,")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MANSD1CT   ³ Autor ³ Leonel Vilaverde    ³ Data ³ 03.11.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Altera Conta, Item e Centro de Custo no SD1                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

cPERG := "MANSD1CT"

If (PERGUNTE( cPERG,.T.))
        PROCESSA({|| RUNPROC()},"Manutenção de Itens Documento de Entrada","Aguarde...")// Substituido pelo assistente de conversao do AP5 IDE em 17/11/00 ==>         PROCESSA({|| EXECUTE(RUNPROC)},"Manutenção de Contas a Receber","Aguarde...")
EndIf


RETURN()

*****************************************************************************
// Substituido pelo assistente de conversao do AP5 IDE em 17/11/00 ==> FUNCTION RUNPROC
Static FUNCTION RUNPROC()
*****************************************************************************

vCONTADOR := 0
cCLIENTE  := "ZZZZZZ"
cCTAOld   := ''


CT1->( dbSetOrder( 1 ) )

DBSELECTAREA("CT1")
DBSETORDER(1)

IF !DBSEEK( xFILIAL("CT1") + MV_PAR07, .F. )
        MSGBOX("Conta não encontrada. Verifique o parametro 7 Conta !","Atenção !","ALERT")
        RETURN
ENDIF


DBSELECTAREA("SD1")
DBSETORDER(1)
PROCREGUA(2)

IF !DBSEEK( xFILIAL("SD1") + MV_PAR01 + MV_PAR02 + MV_PAR03 + MV_PAR04 + MV_PAR05 + MV_PAR06, .F. )
        MSGBOX("Item não encontrado. Verifique os parametros !","Atenção !","ALERT")
        RETURN
ENDIF

INCPROC()



WHILE !EOF() .AND. SD1->D1_DOC      == MV_PAR01;
             .AND. SD1->D1_SERIE    == MV_PAR02;
             .AND. SD1->D1_FORNECE  == MV_PAR03;
             .AND. SD1->D1_LOJA     == MV_PAR04;
             .AND. SD1->D1_COD      == MV_PAR05;
             .AND. SD1->D1_ITEM     == MV_PAR06

        cCTAOld := SD1->D1_CONTA

        lPerg := MsgBox( 'Item N.F.E. - Deseja alterar conta! Prosseguir?' + ' ' + cCTAOld + MV_PAR07, 'ATENCAO', 'YESNO' )
   		IF lPerg
	        RECLOCK("SD1",.F.)
	        SD1->D1_CONTA := MV_PAR07
	        MSUNLOCK()
        EndIF

        DBSKIP()
        INCPROC()
ENDDO

RETURN
