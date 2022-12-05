#Include "Protheus.ch"
#Include "TOTVS.ch"

/*/{Protheus.doc} AT450ALC
Ponto de Entrada na alocação do técnico. Utilizado para sacramentar os agendamentos automáticos. 
@author Lucas Moresco
@since 30/06/2014
@version 1.0
/*/
User Function AT450ALC()

Local aArea    := GetArea()
Local aAreaAB6 := GetArea("AB6")
Local cQry     := ""

	If (Inclui)
		//Begin Transaction
	
			cQry := "Update "+RetSqlName("ABB")+" "+chr(13)
			cQry += "Set ABB_SACRA = 'S' "+chr(13)
			cQry += "Where "+chr(13)
			cQry += "ABB_NUMOS = '"+ABB->ABB_NUMOS+"' And "+chr(13)
			cQry += "ABB_CODTEC = '"+ABB->ABB_CODTEC+"' And "+chr(13)
			cQry += "ABB_OBSERV = 'ALOCADO AUTOMATICAMENTE' And "+chr(13)
			cQry += "ABB_FILIAL = '"+xFilial("ABB")+"' And "+chr(13)
			cQry += "D_E_L_E_T_ <> '*' "
			
			If TcSqlExec(cQry) < 0
				//DisarmTransaction()
				UserException("Erro na sacramentação do agendamento. Verificar AT450ALC ")
			EndIf
			
			DbSelectArea("AB6")
			DbSetOrder(1)
			
			If DbSeek(xFilial("AB6")+ABB->ABB_NUMOS)
		
				RecLock("AB6",.F.)
					AB6->AB6_RLAUDO := ABB->ABB_CODTEC				
				MsUnlock()
		
			EndIf
			
			RestArea(aArea)
			RestArea(aAreaAB6)
		
//		End Transaction
	EndIf
	
Return()