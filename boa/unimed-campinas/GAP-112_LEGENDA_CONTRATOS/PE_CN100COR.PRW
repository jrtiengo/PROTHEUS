#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CN100COR
Este Ponto de Entrada permite incluir ou alterar as cores das legendas de contratos.
GAP112
@type function
@version 1.0 
@author Tiengo Jr.
@since 30/06/2025
@Obs PARAMIXB[1]		- Matriz contendo valores a serem utilizados na legenda.
@Obs PARAMIXB[1][N][1]	- Condição ADVPL que define a cor da legenda
@Obs PARAMIXB[1][N][2]	- Cor da legenda	
@Obs PARAMIXB[1][N][3]	- Texto da legenda
@Return aRet[1]			- Matriz contendo valores a serem utilizados na legenda.
@Return aRet[1][N][1]	- Condição ADVPL que define a cor da legenda
@Return aRet[1][N][2]	- Cor da legenda	
@Return aRet[1][N][3] 	- Texto da legenda
@Seehttps://tdn.totvs.com/pages/releaseview.action?pageId=6089696
/*/

User Function CN100COR()

	Local xParam := PARAMIXB[1]
	Local aRet := {}

	Do Case

	Case ValType(xParam) == "A"

		//Cancelado
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'RED'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '01' .and. Alltrim(CN9->CN9_XSITUA) == '01'"

		//Em Elaboração
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'YELLOW'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '02' .and. Alltrim(CN9->CN9_XSITUA) == '02'"

		//Emitido
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'BLUE'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '03' .and. Alltrim(CN9->CN9_XSITUA) == '03'"

		//em Aprovação
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'ORANGE'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '04' .and. Alltrim(CN9->CN9_XSITUA) == '04'"

		//Vigente
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'GREEN'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '05' .and. Alltrim(CN9->CN9_XSITUA) == '05'"

		//Paralisado
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'GRAY'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '06' .and. Alltrim(CN9->CN9_XSITUA) == '06'"

		//Solicitação Finalização
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'BROWN'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '07' .and. Alltrim(CN9->CN9_XSITUA) == '07'"

		//Finalizado
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'BLACK'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '08' .and. Alltrim(CN9->CN9_XSITUA) == '08'"

		//Revisão
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'PINK'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '09' .and. Alltrim(CN9->CN9_XSITUA) == '09'"

		//Revisado
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'WHITE'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == '10' .and. Alltrim(CN9->CN9_XSITUA) == '10'"

		//Aprov Revisão
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'VIOLET'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == 'A' .and. Alltrim(CN9->CN9_XSITUA) == 'A'"

		//Inclui nova cor para legenda.
		aAdd(xParam,{"Alltrim(CN9->CN9_SITUAC) == '02' .and. Alltrim(CN9->CN9_XSITUA) == '2N'" ,"BR_PRETO_0"	,"Em Elaboração Area Negócio"})
		aAdd(xParam,{"Alltrim(CN9->CN9_SITUAC) == '02' .and. Alltrim(CN9->CN9_XSITUA) == '2J'" ,"BR_PRETO_1"	,"Jurídico"})
		aAdd(xParam,{"Alltrim(CN9->CN9_SITUAC) == '02' .and. Alltrim(CN9->CN9_XSITUA) == '2A'" ,"BR_PRETO_2"	,"Em Assinatura"})
		aAdd(xParam,{"Alltrim(CN9->CN9_SITUAC) == '02' .and. Alltrim(CN9->CN9_XSITUA) == '2C'" ,"BR_PRETO_3"	,"Em Cancelamento"})
	EndCase

	aRet := xParam

Return(aRet)
