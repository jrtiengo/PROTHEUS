#include 'rwmake.ch'
/*
�����������������������������������������������������������������������������
���Programa  �MT100TOK  �Autor  �Marcelo Tarasconi e � Data � 13/03/2020  ���
�������������������������������������������������������������������������͹��
���Descricao �PE para tratamento valida��es documento de entrada          ���
�������������������������������������������������������������������������͹��
���Uso       � MP 12                                                      ���
�����������������������������������������������������������������������������
*/
User Function MT100TOK()

Local lRet       := Paramixb[1]
Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local nVlrIR     := 0

//MV_VISDIRF == 1
//A2_DIRF C 1
//A2_CODRET C 4

//Alert('Estou no PE_MT100TOK')

//If .F.  .and.  !cTipo $ 'D/B' .and. FunName() $ 'MATA103' //Somente para fornecedores, A ROTINA MATA920 CHAMA A MATA103
//If   !cTipo $ 'D/B' .and. FunName() $ 'MATA103' //Somente para fornecedores, A ROTINA MATA920 CHAMA A MATA103

    //Alert('Estou no PE_MT100TOK'+' '+ FunName()) 

	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+CA100FOR+CLOJA,.f.)
	
	If oFisRod <> NIL //na rotina de retorno nao existe este objeto
		
		If Len(oFisRod:aArray) > 0
			For i:=1 to Len(oFisRod:aArray)
				If oFisRod:aArray[i][1] == 'IRR'
					nVlrIR := oFisRod:aArray[i][5]
				EndIf
			Next i
		EndIf
		
		//If SA2->A2_DIRF == '1'
		If !Empty(SA2->A2_CDRETIR)  .AND. SA2->A2_CALCIRF $ '1/2/3' 
			If nVlrIR > 0  .and. Empty(cCOdRet)
				cDirf   := '1' 
				cCodRet := SA2->A2_CDRETIR
				Alert('Fornecedor parametrizado com DIRF e NF tem valor de IRR! Acertando DIRF!!!')
//				lRet := .f.
			EndIf
		Else
			If nVlrIR > 0
				Alert('Fornecedor parametrizado com DIRF = 2 (Gera DIRF = Nao) mas NF tem valor de IRR!')
				lRet := .f.
			EndIf
		EndIf
		
	EndIf
	
	
//EndIf

RestArea(aAreaSA2)
RestArea(aArea)
Return(lRet)
