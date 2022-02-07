#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
��� Programa    � RCTBM02  � Monta valor dos juros, desconto, multa quando t�tulo n�o     ���
���             �          � esta posicionado.                                            ���
�����������������������������������������������������������������������������������������͹��
��� Solicitante � ??.??.?? � Zaiin                                                        ���
�����������������������������������������������������������������������������������������͹��
��� Autor       � 01.05.04 � Almir Bandina                                                ���
�����������������������������������������������������������������������������������������͹��
��� Produ��o    � ??.??.?? � Ignorado                                                     ���
�����������������������������������������������������������������������������������������͹��
��� Par�metros  � ExpC1 = C�digo do lan�amento padr�o                                     ���
���             � ExpC2 = Sequencia do Lan�amento Padr�o                                  ���
���             � ExpC3 = Tipo de baixa (DC, JR, MT, CM, ETC)                             ���         
�����������������������������������������������������������������������������������������͹��
��� Retorno     � Nil.                                                                    ���
�����������������������������������������������������������������������������������������͹��
��� Observa��es �                                                                         ���
���             �                                                                         ���
���             �                                                                         ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������͹��
��� Altera��es  � ??.??.?? - Nome - Descri��o                                             ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
*/
User Function RCTBM02(cCodPad, cItePad, cTpDoc, cConteudo )

Local aAreaAtu	:= GetArea()
Local aAreaSE5	:= SE5->(GetArea())
Local nRet		:= 0
Local cRet      := " "
Local cQry		:= ""
Local cAlias	:= "SE5"
Local cPrefixo	:= SEF->EF_PREFIXO
Local cNumero	:= SEF->EF_TITULO
Local cParcela	:= SEF->EF_PARCELA
Local cTipo		:= SEF->EF_TIPO
Local cFornece	:= SEF->EF_FORNECE
Local cLoja		:= SEF->EF_LOJA

Default cTpDoc	:= " "

If cCodPad $ "590"
	#IFDEF TOP
		// Define a select para apurar o valor de desconto, juros e multa
		If cConteudo == "1"
			
			cQry	+= "SELECT"
			cQry	+= " E5.E5_FILIAL,E5.E5_PREFIXO,E5.E5_NUMERO,E5.E5_PARCELA,E5.E5_TIPO,"
			cQry	+= " E5.E5_CLIFOR,E5.E5_LOJA,E5.E5_TIPODOC,E5.E5_VALOR,E5.E5_BENEF,E5.E5_NUMCHEQ"
			cQry	+= " FROM "+RetSqlName("SE5")+" E5 WHERE"
			cQry	+= " E5.E5_FILIAL = '"+xFilial("SE5")+"' AND"
			cQry	+= " E5.E5_PREFIXO = '"+cPrefixo+"' AND"
			cQry	+= " E5.E5_NUMERO = '"+cNumero+"' AND"
			cQry	+= " E5.E5_PARCELA = '"+cParcela+"' AND"
			cQry	+= " E5.E5_TIPO = '"+cTipo+"' AND"
			cQry	+= " E5.E5_CLIFOR = '"+cFornece+"' AND"
			cQry	+= " E5.E5_LOJA = '"+cLoja+"' AND"
			cQry	+= " E5.D_E_L_E_T_ <> '*'"
			
			If cConteudo == "1"
				
				// Verifica se o alias esta em uso
				If Select("CTBM02") > 0
					dbSelectArea("CTBM02")
					dbCloseArea()
				EndIf
				// Roda a query
				TCQUERY cQry NEW ALIAS "CTBM01"
				dbSelectArea("CTBM01")
				dbGoTop()
				cAlias	:= "CTBM01"
			Else
				// Verifica se o alias esta em uso
				If Select("CTBM01") > 0
					dbSelectArea("CTBM01")
					dbCloseArea()
				EndIf
				// Roda a query
				TCQUERY cQry NEW ALIAS "CTBM01"
				dbSelectArea("CTBM01")
				dbGoTop()
				cAlias	:= "CTBM01"
				
			Endif
	#ELSE
			dbSelectArea("SE5")
			dbSetOrder(7)			// PREFIXO+NUMERO+PARCELA+TIPO+CLIFOR+LOJA+SEQ
			MsSeek(xFilial("SE5")+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)
	#ENDIF
		
		While !Eof() .And. (cAlias)->E5_FILIAL == xFilial("SE5") .And.;
			(cAlias)->E5_PREFIXO == cPrefixo .And.;
			(cAlias)->E5_NUMERO == cNumero .And.;
			(cAlias)->E5_PARCELA == cParcela .And.;
			(cAlias)->E5_TIPO == cTipo .And.;
			(cAlias)->E5_CLIFOR == cFornece .And.;
			(cAlias)->E5_LOJA == cLoja
			
			// Define o valor do retorno de acordo com o par�metro
			If cTpDoc == "DC" .And. (cAlias)->E5_TIPODOC == "DC"					// Desconto
				nRet	+= (cAlias)->E5_VALOR
				cRet    := 	"DESCONTO REF.TITULO "+(cAlias)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA)+"-"+(cAlias)->E5_BENEF+" CHEQUE "+(cAlias)->E5_NUMCHEQ
			ElseIf cTpDoc == "JR" .And. (cAlias)->E5_TIPODOC == "JR"				// Juros
				nRet	:= (cAlias)->E5_VALOR
				cRet    += 	"JUROS REF.TITULO "+(cAlias)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA)+"-"+(cAlias)->E5_BENEF+" CHEQUE "+(cAlias)->E5_NUMCHEQ
			ElseIf cTpDoc == "MT" .And. (cAlias)->E5_TIPODOC == "MT"				// Multa
				nRet	:= (cAlias)->E5_VALOR
				cRet    += 	"MULTA REF.TITULO "+(cAlias)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA)+"-"+(cAlias)->E5_BENEF+" CHEQUE "+(cAlias)->E5_NUMCHEQ
				
			ElseIf cTpDoc == "CM" .And. (cAlias)->E5_TIPODOC == "CM"				// Corre��o Monet�ria
				nRet	:= (cAlias)->E5_VALOR
				cRet    += 	"CORRECAO MONETARIA REF.TITULO "+(cAlias)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA)+"-"+(cAlias)->E5_BENEF+" CHEQUE "+(cAlias)->E5_NUMCHEQ
				
			ElseIf cTpDoc == "BA" .And. (cAlias)->E5_TIPODOC == "BA"				// Baixa
				nRet	:= (cAlias)->E5_VALOR
				cRet    += 	"VALOR REF.TITULO "+(cAlias)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA)+"-"+(cAlias)->E5_BENEF+" CHEQUE "+(cAlias)->E5_NUMCHEQ
			EndIf
			
			// Volta para area original
			dbSelectArea(cAlias)
			dbSkip()
		EndDo
	EndIf
	
	//Restaura a integridade dos arquivos
	// Verifica se o alias esta em uso
	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	EndIf
	RestArea(aAreaSE5)
	RestArea(aAreaAtu)
endif
Return(iif(cConteudo=="1",nRet,cRet))
