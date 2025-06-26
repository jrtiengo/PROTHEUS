#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SX5Nota
description Ponto de entrada no final do pedido de compras
@type function
@version  
@author Tiengo Junior
@since 24/06/2025
@obs PARAMIXB[1] //Filial
@obs PARAMIXB[2] //Tabela da SX5
@obs PARAMIXB[3] //Chave da Tabela na SX5
@obs Paramixb[4]  //Conteúdo da Chave indicada
@See https://tdn.totvs.com/pages/releaseview.action?pageId=471926355
/*/
User Function SX5Nota()

	Local lRet      := .f.                                      as logical
	Local _cChave   := Paramixb[3]                              as Character
	Local _cSeries	:= GetMV("MV_ESPECIE")                      as Character

	//Verifica se chave da tabela SX5 existe no parametro MV_ESPECIE
	If Alltrim(Substr(_cChave,1,3)) $ UPPER(_cSeries)
		lRet := .t.
	EndIf

Return(lRet)
