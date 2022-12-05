#INCLUDE "PROTHEUS.CH"

User Function M310ITENS()
Local cPrograma := PARAMIXB[1]
Local aItens    := PARAMIXB[2] 
Local nx
Local nz

U_AUTOM628("PE_M310ITENS")

If cPrograma == "MATA410" // Pedido de venda
	// ARRAY AITENS (PADRAO DAS ROTINAS AUTOMATICAS)
	// [1]       ITEM 1
	// [1][1]    CAMPO 1 DO ITEM 1
	// [1][1][1] NOME DO CAMPO
	// [1][1][2] CONTEUDO DO CAMPO
	// [1][1][3] VALIDACAO A SER UTILIZADA
	
	// Exemplo MUDANDO ARMAZEM
	/*
	For nx:=1 to Len(aItens)
		For nz:=1 to Len(aItens[nx])
			If "C6_LOCAL" $ aItens[nx,nz,1]
			   //	aItens[nx,nz,2]	:="02"
			EndIf	
		Next nz
	Next nx
	*/
	aItens := U_JpcAcdTr(aItens)
EndIf
RETURN aItens