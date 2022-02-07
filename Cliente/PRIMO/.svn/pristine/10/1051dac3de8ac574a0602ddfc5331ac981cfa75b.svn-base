#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"

User Function PE01NFESEFAZ

	Local aProd		:= PARAMIXB[1]
	Local cMensCli	:= PARAMIXB[2]
	Local cMensFis	:= PARAMIXB[3]
	Local aDest 	:= PARAMIXB[4]
	Local aNota 	:= PARAMIXB[5]
	Local aInfoItem := PARAMIXB[6]
	Local aDupl		:= PARAMIXB[7]
	Local aTransp	:= PARAMIXB[8]
	Local aEntrega	:= PARAMIXB[9]
	Local aRetirada	:= PARAMIXB[10]
	Local aVeiculo	:= PARAMIXB[11]
	Local aReboque	:= PARAMIXB[12]
	Local aNfVincRur:= PARAMIXB[13]
	Local aEspVol	:= PARAMIXB[14]
	Local aNfVinc	:= PARAMIXB[15] //Notas Vinculadas
	Local aDetPag	:= PARAMIXB[16]
	Local aObsCont	:= PARAMIXB[17]
	Local aTes		:={}
	Local nK

// Jean Rehermann - Solutio IT - 11/08/2020 - Variáveis para informar placa do veículo
	Local oDlgVeic,oSay1,oGet1,oGet2,oGet3,oSBtn1,oSBtn2,cPlaca,cUfVei,cRNTC,nOk := 0

	If Len(aNota)>=4
		cTipo:=aNota[4]
	End

	If cTipo=='1'  //saida

		dbSelectArea("SC5")
		dbSetOrder(1)
		IF dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)

			dbSelectArea("DHB")
			dbSetOrder(1)
			IF dbSeek(xFilial('DHB')+SC5->C5_CODMOT)
				cMensCli += '    Motorista: '+DHB->DHB_NOMMOT
			END

			If !AllTrim(SC5->C5_MENNOTA) $ cMensCli
				cMensCli += AllTrim(SC5->C5_MENNOTA)
			EndIf
			If !Empty(SC5->C5_MENPAD) .And. !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis
				cMensFis += AllTrim(FORMULA(SC5->C5_MENPAD))
			EndIf
		Endif

		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)

		While D2_FILIAL+D2_DOC+D2_SERIE==SF2->(F2_FILIAL+F2_DOC+F2_SERIE).AND.!EOF()
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+SD2->D2_TES)

			IF aScan(aTes,SF4->F4_FORM1) == 0.And.!Empty(SF4->F4_FORM1)
				Aadd(aTes,SF4->F4_FORM1)
				cMensFis += alltrim(Formula(SF4->F4_FORM1))
			End

			IF aScan(aTes,SF4->F4_FORM2) == 0.And.!Empty(SF4->F4_FORM2)
				Aadd(aTes,SF4->F4_FORM2)
				cMensFis += alltrim(Formula(SF4->F4_FORM2))
			End

			IF aScan(aTes,SF4->F4_FORM3) == 0.And.!Empty(SF4->F4_FORM3)
				Aadd(aTes,SF4->F4_FORM3)
				cMensFis += alltrim(Formula(SF4->F4_FORM3))
			End

			IF aScan(aTes,SF4->F4_FORM4) == 0.And.!Empty(SF4->F4_FORM4)
				Aadd(aTes,SF4->F4_FORM4)
				cMensFis += alltrim(Formula(SF4->F4_FORM4))
			End

			IF aScan(aTes,SF4->F4_FORM5) == 0.And.!Empty(SF4->F4_FORM5)
				Aadd(aTes,SF4->F4_FORM5)
				cMensFis += alltrim(Formula(SF4->F4_FORM5))
			End

/*
//Tratamento para Nota Fiscal de Exportação - Tratamento se encontra na rotina NFESEFAZ (U_A020RNFE) pois não foi possivel fazer chamada 

			dbSelectArea("ZA2")
			dbSetOrder(1)
			If dbSeek( SD2->D2_FILIAL + SD2->D2_PEDIDO )

				While !ZA2->(Eof()) .And. ZA2->ZA2_FILIAL == SD2->D2_FILIAL .And. ZA2->ZA2_NUM == SD2->D2_PEDIDO
					//If !AllTrim(ZA2->ZA2_REFNFE) $ cChaveRef
						//    AADD(aNfVinc,  AllTrim(ZA2->ZA2_REFNFE) )
						//	cChave += "<refNFe>" + AllTrim(ZA2->ZA2_REFNFE) + "</refNFe>"
						aAdd( aNfVinc, { SF3->F3_EMISSAO, SF3->F3_SERIE, SF3->F3_NFISCAL, SA1->A1_CGC, SM0->M0_ESTCOB, SF3->F3_ESPECIE,  AllTrim(ZA2->ZA2_REFNFE),0,"","",0,"","" } )
					//EndIf
					ZA2->(dbSkip())
				EndDo

			EndIf

*/

			dbSelectArea("SD2")
			dbSkip()
		END

		//ajuste da descricao do produto, adicionando o Lote Minis da Agricultura
		For nK:=1 to Len(aInfoItem)

			dbSelectArea("SC6")
			dbSetOrder(1)
			IF dbSeek(xFilial("SC6")+aInfoItem[nK,1]+aInfoItem[nK,2])

				If !EMPTY(SC6->C6_NUMPCOM)
					cMensCli += '  PC/Item: '+alltrim(SC6->C6_NUMPCOM)+'/'+alltrim(SC6->C6_ITEMPC)
				END

				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

				aProd[nK,4]:=ALLTRIM(SB1->B1_DESC)
			Endif
		Next
	END

	// Jean Rehermann - Solutio IT - 11/08/2020 - Tela para informação de placa de veículo
	If MsgYesNo("Deseja informar a placa do veículo?")

		cPlaca := Iif( Len( aVeiculo ) > 0, aVeiculo[ 1 ], Space(08) )
		cUfVei := Iif( Len( aVeiculo ) > 1, aVeiculo[ 2 ], Space(02) )
		cRNTC  := Iif( Len( aVeiculo ) > 2, aVeiculo[ 3 ], Space(20) )

		oDlgVeic := MSDialog():New( 170,323,423,576,"Veículo",,,.F.,,,,,,.T.,,,.T. )
		oSay1    := TSay():New( 004,004,{||"Ao informar a placa é obrigatório informar a UF do veículo. RNTC sempre é opcional. Usar apenas letras e números."},oDlgVeic,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,024)
		oGet1    := TGet():New( 044,010,{|u|Iif(PCount()>0,cPlaca:=u,cPlaca)},oDlgVeic,052,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cPlaca",,,,.F.,.F.,,"Placa: ",2)
		oGet2    := TGet():New( 064,010,{|u|Iif(PCount()>0,cUfVei:=u,cUfVei)},oDlgVeic,028,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"12","cUfVei",,,,.F.,.F.,,"   UF: ",2)
		oGet3    := TGet():New( 084,010,{|u|Iif(PCount()>0,cRNTC:=u,cRNTC)  },oDlgVeic,060,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cRNTC",,,,.F.,.F.,," RNTC: ",2)
		oSBtn1   := SButton():New( 104,088,1,{||nOk:=1,oDlgVeic:End()},oDlgVeic,,"", )
		oSBtn2   := SButton():New( 104,056,2,{||oDlgVeic:End()},oDlgVeic,,"", )
		oDlgVeic:Activate(,,,.T.,{|| ( !Empty( cPlaca ) .And. !Empty( cUfVei ) ) .Or. ( Empty( cPlaca ) .And. Empty( cUfVei ) ) })

		If nOk == 1 .And. !Empty( cPlaca ) .And. !Empty( cUfVei )
			aVeiculo := {}
			aAdd( aVeiculo, cPlaca ) // Placa
			aAdd( aVeiculo, cUfVei ) // UF
			aAdd( aVeiculo, cRNTC  ) //RNTC
		EndIf

	EndIf



Return {aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont}
