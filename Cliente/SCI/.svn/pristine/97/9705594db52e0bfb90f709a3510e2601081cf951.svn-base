#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³COP300   ºAutor  ³Marcelo Tarasconi   º Data ³  29/11/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Procura titulo RAPel                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 10                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function COP300()

Local aArea    := GetArea()
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local cRet     := ''
Local nTotRAP  := 0
Local nTotNF   := 0
Local nQuant   := 0
Local aParcNum := {{'A',1},{'B',2},{'C',3},{'D',4},{'E',5},{'F',6},{'G',7},{'H',8},{'I',9},{'J',10},{'K',11},{'L',12},{'M',13},{'N',14}}
Local cData    := '000000'
Local nDif     := 0
Local nRAPParc := 0


//Testa se o Cliente tera instrucao no boleto e no CNAB
dbSelectArea('SA1')
dbSetOrder(1)
dbSeek(xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.)

dbSelectArea('ACY')
dbSetOrder(1)
If dbSeek(xFilial('ACY')+SA1->A1_GRPVEN,.F.)
   
   If ACY->ACY_INSTRU == 'S'

		dbSelectArea('SE1')
		dbSetOrder(1)//Prefixo + Num + Parcela + Tipo
		//Pode existir vários titulo de rapel, mas a parcela esta no meio do indice, entao percorro todos os titulos
		If dbSeek(xFilial('SE1')+SE1->(E1_PREFIXO+E1_NUM),.f.)
			cChave := xFilial('SE1')+SE1->(E1_PREFIXO+E1_NUM)
			While !EOF() .and. cChave == xFilial('SE1')+SE1->(E1_PREFIXO+E1_NUM)
				If SE1->E1_TIPO $ 'RAP'
					nTotRAP += SE1->E1_SALDO
				EndIf
				If SE1->E1_TIPO $ 'NF '
					nTotNF += SE1->E1_SALDO
					nQuant += 1
				EndIf
				SE1->(dbSkip())
			End
		EndIf
		
		//restaura antes de fazer o calculo, pois preciso saber o valor corrente da parcela que esta sendo percorrida...
		RestArea(aAreaSA1)
		RestArea(aAreaSE1)
		RestArea(aArea)
		
		
		//O VALORO DO RAPEL DEVERA SAIR RATEADO PELAS PARCELAS.....CUIDAR O ARREDONDAMENTO
		nRAPParc := NoRound((nTotRap/nTotNF) * SE1->E1_SALDO)
		
		//Depois de saber o valor parcelado do Rapel, vou testar e ver o arredondamento
		//Se tiver diferenca, devra esta ser incluida na ultima parcela
		If (nRAPParc * nQuant) <> nTotRAP
			nDif := nTotRAP - (nRAPParc * nQuant)
		Else
			nDif := 0
		EndIf
		
		//Depois de saber se existe diferença a maior ou menor, preciso saber quem é a ultima parcela......
		//Sei quantas parcelas foram e sei quantas são, preciso somente indicar pela parcela igual D que é na 4 passada que devo inserir o valor
		If GetMv("MV_1DUP") == 'A' //Indica que será contado A, B, C, D
			//SE FOR A ULTIMA PARCELA ENTAO NAO ZERA, FAZENDO O ACERTO DE ARREDONDAMENTO
			If Ascan( aParcNum , {|x| x[1] == SE1->E1_PARCELA }) == nQuant
				
			Else
				nDif := 0
			EndIf
		ElseIf GetMv("MV_1DUP") == '1'
			If Val(SE1->E1_PARCELA) == nQuant
				Else
				nDif := 0
			EndIf
		EndIf
		
		//      DDMMAA
		//Return("000000" + StrZero(((nRAPParc+nDif)*100),13))
		If (nRAPParc+nDif) > 0
			cData := GravaData(SE1->E1_VENCREA,.F.)
		Else
			cData := '000000'
		EndIf
	EndIf
EndIf
	
Return( cData + StrZero(((nRAPParc+nDif)*100),13))
