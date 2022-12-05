#include "Totvs.Ch"
#define STR0001 "ATENCAO"
#define STR0002 "Este processo devera ser executado por FILIAL."
#define STR0003 "Deseja atualizar os campos novos da tabela RJ1 (Def. Tit. Usr. Roteiro) de registros existentes?"
#define STR0004 "Registros atualizados com sucesso!"
#define STR0005 "Atualizando registros da tabela RJ1..."
#define STR0006 "Base de dados não possui novos campos na tabela RJ1 - RJ1_PROCES / RJ1_ROTEIR / RJ1_TIPO"

/*/{Protheus.doc} AtuRJ1
Funcao responsavel por executar o processo de atualização dos registros da tabela RJ1.
@author raquel.andrade
@since 03/08/2020
@version P12
@return lMsErroAuto, logic, retorna resultado da operação
/*/
User Function AtuRJ1()
Local lCpoInteg	:= RJ1->(ColumnPos( "RJ1_ROTEIR")) > 0 .And. RJ1->(ColumnPos( "RJ1_PROCES")) > 0 .And. RJ1->(ColumnPos( "RJ1_TIPO")) > 0
Private lMsErroAuto := .F.


If MsgYesNo( OemToAnsi( STR0002 + CRLF +  CRLF + STR0003), OemToAnsi( STR0001 ) )

    If lCpoInteg
        MsAguarde({|| MSExecAuto( {|| u_AtualReg() }) },OemToAnsi( STR0005 ) )

        If lMsErroAuto
            MostraErro()
        Else
            MsgInfo(OemToAnsi( STR0004 ), OemToAnsi( STR0001 ))
        EndIf
    Else
        MsgInfo(OemToAnsi( STR0006 ), OemToAnsi( STR0001 ))
    EndIf

EndIf

Return !lMsErroAuto


/*/{Protheus.doc} AtualReg
Funcao responsavel em alimentar os campos novos criados na tabela RJ1.
@author raquel.andrade
@since 03/08/2020
@version P12
@return lRet, logic, retorna resultado da operação
/*/
User Function AtualReg()
Local aArea     := GetArea()
Local nSize		:= TamSX3("RC1_PREFIX")[1]
Local cRotRES	:= fGetCalcRot("4") //Rescisão

    dbSelectArea('RJ1')
    dbSetOrder(1)
    While RJ1->(!Eof())

        dbSelectArea('RC1')
        dbSetOrder(1) // RC1_FILIAL+RC1_FILTIT+RC1_CODTIT+RC1_PREFIX+RC1_NUMTIT
        If RC1->(dbSeek( xFilial("RC1") + RJ1->RJ1_FILIAL + RJ1->RJ1_CODTIT + PadR(RJ1->RJ1_PREFIX,nSize) + RJ1->RJ1_NUMTIT)) .And. Empty(RJ1->RJ1_ROTEIR)

            RecLock("RJ1",.F.,.F.)

            RJ1->RJ1_PROCES := Posicione("SRA",1,RJ1->RJ1_FILFUN+RJ1->RJ1_MAT,"RA_PROCES")
            RJ1->RJ1_ROTEIR := cRotRES
            RJ1->RJ1_TIPO   := RC1->RC1_TIPO

            MsUnLock()

        EndIf
        RJ1->(DbSkip())
    EndDo

    lRet    := .T.

    RestArea(aArea)

Return lRet
