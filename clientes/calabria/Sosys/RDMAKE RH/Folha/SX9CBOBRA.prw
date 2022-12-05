#include "Totvs.Ch"
#define STR0001 "ATENCAO"
#define STR0002 "Este processo devera ser executado por GRUPO DE EMPRESA."
#define STR0003 "Deseja remover o relacionamento entre os campos RJ_CODCBO (CBO 2002) e R2_CBO (C.B.O.)?"
#define STR0004 "Relacionamento removido com sucesso!"
#define STR0005 "Removendo relacionando no dicionario SX9 (Relacionamentos)..."

/*/{Protheus.doc} SX9CBOBRA
Funcao responsavel por executar o processo de exclusao do relacionamento entre os campos RJ_CODCBO (CBO 2002) e R2_CBO (C.B.O.)
@author raquel.andrade
@since 02/12/2021
@version P12
@return lMsErroAuto, logic, retorna resultado da operação
/*/
User Function SX9CBOBRA()
Private lMsErroAuto := .F.


If MsgYesNo( OemToAnsi( STR0002 + CRLF +  CRLF + STR0003), OemToAnsi( STR0001 ) )

    MsAguarde({|| MSExecAuto( {|| u_DelRel() }) },OemToAnsi( STR0005 ) ) 

    If lMsErroAuto
        MostraErro()
    Else
        MsgInfo(OemToAnsi( STR0004 ), OemToAnsi( STR0001 ))
    EndIf

EndIf

Return !lMsErroAuto


/*/{Protheus.doc} DelRel
Funcao responsavel para excluir registros do dicionário de Relacionamentos SX9
@author raquel.andrade
@since 02/12/2021
@version P12
@return lRet, logic, retorna resultado da operação
/*/
User Function DelRel()
Local aArea     := GetArea()
Local lRet		:= .F.

    DbSelectArea("SX9")
    DbSetOrder(1)

	If SX9->(DbSeek("SRJ"))
		While AllTrim(SX9->X9_DOM) == "SRJ" .And. !lRet
			If AllTrim(SX9->X9_EXPDOM) == "RJ_CODCBO" .And. AllTrim(SX9->X9_EXPCDOM) == "R2_CBO" 
				RecLock( "SX9" , .F. )
			    SX9->( dbDelete() )
				lRet	:= .T.
			    SX9->(MsUnLock())
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf
    
    RestArea(aArea)   
 
Return lRet
