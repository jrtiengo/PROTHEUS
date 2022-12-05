#INCLUDE "protheus.ch"
/*
Funcao MT120FIM
Jean Rehermann | SOLUTIO - 24/01/2012 - Ultima instrucao ao final da funcao a120pedido
PARAMIXB[1]   // Opcao Escolhida pelo usuario 
PARAMIXB[2]   // Numero do Pedido de Compras	
PARAMIXB[3]   // Indica se a acao foi Cancelada = 0  ou Confirmada = 1
*/
User Function MT120FIM()

	Local nOpcao := PARAMIXB[1]
	Local cNumPC := PARAMIXB[2]
	Local nOpcA  := PARAMIXB[3]
	Local _aArea := GetArea()
	
    U_AUTOM628("PE_MT120FIM")

	If nOpcao == 5 .And. nOpcA == 1
	
		_cQuery := "SELECT R_E_C_N_O_ FROM "+ RetSqlName("SC6")
		_cQuery += " WHERE C6_PCOMPRA = '"+ cNumPC +"' "
		_cQuery += " AND D_E_L_E_T_ = '' "

		_cQuery := ChangeQuery( _cQuery )

		If Select("T_SC6") > 0
			T_SC6->( dbCloseArea() )
		EndIf
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_SC6",.T.,.T.)
		
		While !T_SC6->( Eof() )

			dbSelectArea("SC6")
			dbGoTo( T_SC6->R_E_C_N_O_ )
			
			U_GravaSts("PE_MT120FIM")
		
			dbSelectArea("T_SC6")
			
			T_SC6->( dbSkip() )
		End

		If Select("T_SC6") > 0
			T_SC6->( dbCloseArea() )
		EndIf

	EndIf
	
	RestArea( _aArea )
	
Return