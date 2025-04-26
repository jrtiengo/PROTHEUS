#Include "Protheus.ch"

/*----------------------------------------------------------------------------------------------------
| Programa  | A410EXC   | Autor | Carlos N. Puerta                               | Data | 28/07/2021 |
------------------------------------------------------------------------------------------------------
| Desc.     | PE acionado na exclusao do pedido de venda.                                            |
------------------------------------------------------------------------------------------------------
| Objetivo  | Não permitir a exclusão do PV de Venda que possui PV de Simples Remessa amarrado (ZZ2) |
----------------------------------------------------------------------------------------------------*/
User Function A410EXC()
Local _aArea		:= GetArea()
Local _lRet			:= .T.

If _lRet .And. (cEmpAnt == "01" .Or. cEmpAnt == "03")
    dBSelectArea("ZZ2")
    dbSetOrder(1)             // ZZ2_FILIAL+ZZ2_PVORIG+ZZ2_PVDEST
    MsSeek(xFilial("ZZ2")+M->C5_NUM,.T.)
    While !Eof() .And. M->C5_NUM == ZZ2->ZZ2_PVORIG
        If ZZ2->ZZ2_MOTIVO == "1"
            Alert("Existe o PV de Simples Remessa "+ZZ2->ZZ2_PVDEST+" que impossibilita a exclusao desse PV...")
		    _lRet := .F.
	        Exit
	    EndIf
	    dbSkip()
    End
EndIf

RestArea(_aArea)
Return(_lRet)
