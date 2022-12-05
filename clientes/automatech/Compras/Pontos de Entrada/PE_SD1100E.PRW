#INCLUDE "protheus.ch" 

/*
Jean Rehermann - Ponto de entrada na deleção dos itens da nota de entrada, roda 1 vez para cada item.
Ponto de entrada é acionado na exclusão de uma nota de entrada.
Utilizado para verificar se item da nota com pedido de compra possui amarração ao pedido de venda, e avalia se altera
ou não o status (item de venda não pode estar faturado)
*/
User Function SD1100E()

    U_AUTOM628("PE_SD1100E")

	aArea := GetArea()
	
	If !Empty( AllTrim( SD1->D1_PEDIDO + SD1->D1_ITEMPC ) )

		_cQuery := "SELECT C6_STATUS, R_E_C_N_O_ FROM "+ RetSqlName("SC6") +" WHERE C6_PCOMPRA = '"+ SD1->D1_PEDIDO +"' "
		_cQuery += " AND C6_ITEMPC = '"+ SD1->D1_ITEMPC +"' AND D_E_L_E_T_ = ' '"
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cQuery),"T_C6", .T., .T.)
		
		While !T_C6->( Eof() )
		
			If T_C6->C6_STATUS $ "08|10"

				dbSelectArea("SC6")
				dbGoTo( T_C6->R_E_C_N_O_ ) // Seleciono o SC6 e posiciono no RECNO correspondente
				RecLock("SC6",.F.)
					SC6->C6_STATUS := "06"  // Gravo novo status no item "06 - Em Compra"
					U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "06", "PE_SD1100E") // Gravo o log de atualização de status na tabela ZZ0
				MsUnlock()
				dbSelectArea("T_C6")

			EndIf
			
			T_C6->( dbSkip() )
		End
		
		T_C6->( dbCloseArea() )
	EndIf
			
	RestArea( aArea )

Return()