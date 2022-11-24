#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PSZIMPPV   ³ Autor ³ Robson Salvieri       ³ Data ³16/12/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ZAMPROGNA          ³Contato ³ robson@veza.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao do Pedido de Venda                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterado: 000000 - Analista - 99/99/9999 - Motivo da Alteracao
*/

User Function IMPPV(_cNumPV)
***************************

Local cPerg				:= "PERGRELPV"
Local _cQryPV			:= ""
Local aStru				:= {}
Local _cPVAtu			:= ""
Local nViasImp			:=0
Private aObs			:= {}
Private cObs			:= ""
Private _cObsPrd		:= ""
Private _cObsFat		:= ""
Private _cPvTria		:= ""
Private _nQuant		:= 0
Private _nTot			:= 0
Private _nSubTot  	:= 0
Private _nIpi			:= 0
Private _nTamLin		:= 80
Private _nLimVert		:= 2300
Private _nVias			:= 1
Private _nPagina		:= 1
Private _nIniLin		:= 0
Private _nLin			:= 0
Private _nCotDia		:= 1
Private _dCotDia		:= DtoS(dDataBase)
Private _cPrevisao	:= ""
Private _TpFrete		:= ""
Private _TpPedVen	:= ""
Private _Transporte	:= ""
Private _cPrazoPag	:= ""
Private _nMoeda		:= 1
Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b
Private cLogoD			:= ""
Private bUsaFor		:= .F.
    
	_cNumPV	:= ""
	
	// Tratamento das perguntas
	If Alltrim(_cNumPV) == ""
		AjustaSX1( cPerg )
		If !Pergunte( cPerg, .T. )
			Return
  		EndIf
    Endif

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()
	
	// Orientação da página
	oPrint:SetLandScape() // Para Paisagem
	//oPrint:SetPortrait()    // Para Retrato
	
	// Tamanho da página na impressão
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	oPrint:SetPaperSize(9)   // A4
	
	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )

	// Nome da Empresa/Filial para o cabecalho
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )
	
	_cQryPV := " SELECT DISTINCT C5_TIPO AS TIPO, C5_NUM, C5_PVTRIAN, "
	_cQryPV += "                 SUBSTRING(C5_EMISSAO, 7, 2) + '/' + "
	_cQryPV += "                 SUBSTRING(C5_EMISSAO, 5, 2) + '/' + "
	_cQryPV += "                 SUBSTRING(C5_EMISSAO, 1, 4) C5_EMISSAO, "
	_cQryPV += "                 C5_VEND1, "
	_cQryPV += "                 C5_TPFRETE, "
	_cQryPV += "                 C5_MOEDA, "
	_cQryPV += "                 C5_CONDPAG, "
	_cQryPV += "                 C5_TIPOPV, "                                 
	_cQryPV += "                 C5_MENNOTA, " 
	_cQryPV += "                 C5_TRANSP, "
	_cQryPV += "                 C5_CLIENTE, "
	_cQryPV += "                 C5_LOJACLI, " 		 
	_cQryPV += "                 C5_CLIENT, "
	_cQryPV += "                 C5_LOJAENT, " 		 	
	_cQryPV += "                 CONVERT(CHAR(2000),SUBSTRING(C5_OBSPROD, 1, 2000)) as OBSPROD1,"
	_cQryPV += "                 CONVERT(CHAR(2000),SUBSTRING(C5_OBSFATU,1,2000)) as OBSFAT1," 
	_cQryPV += "                 C6_ITEM, "
	_cQryPV += "                 C6_PRODUTO, "
	_cQryPV += "                 C6_DESCRI, "
	_cQryPV += "                 C6_UM, "         
	_cQryPV += "                 C6_UNSVEN, "         	
	_cQryPV += "                 C6_QTDVEN, "
	_cQryPV += "                 C6_PRCVEN, "
	_cQryPV += "                 C6_VALOR, "
	_cQryPV += "                 C6_CF, "         
	_cQryPV += "                 C6_TES, "         	
	_cQryPV += "                 SUBSTRING(C6_ENTREG, 7, 2) + '/' + "
	_cQryPV += "                 SUBSTRING(C6_ENTREG, 5, 2) + '/' + "
	_cQryPV += "                 SUBSTRING(C6_ENTREG, 1, 4) C6_ENTREG, "
	_cQryPV += "                 C6_LOTECTL, "
	_cQryPV += "                 B8_LOTEFOR, " 
	_cQryPV += "             	 B8_ENDZAMP, " 
	_cQryPV += "                 B1_POSIPI, "
	_cQryPV += "                 B1_IPI, "	
	_cQryPV += "                 B1_DESC, "
	_cQryPV += "                 B1_ESPECIF, "
	_cQryPV += "                 E4_DESCRI "
	_cQryPV += "   FROM "+RetSqlName("SC5")+" SC5 "
	_cQryPV += " INNER JOIN "+RetSqlName("SC6")+" SC6 "
	_cQryPV += "    ON (SC5.C5_NUM = SC6.C6_NUM) "
	_cQryPV += " INNER JOIN " + RetSqlName("SB8") + " AS SB8 "
	_cQryPV += " ON B8_LOTECTL=C6_LOTECTL AND B8_NUMLOTE='' AND SB8.D_E_L_E_T_ <> '*' "
	_cQryPV += "  INNER JOIN "+RetSqlName("SB1")+" SB1 "
	_cQryPV += "     ON (SB1.B1_COD = SC6.C6_PRODUTO) "
	_cQryPV += " INNER JOIN "+RetSqlName("SE4")+" SE4 "
	_cQryPV += "    ON (SC5.C5_CONDPAG = SE4.E4_CODIGO) "
	_cQryPV += "   AND SC5.C5_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
	_cQryPV += "   AND SC5.D_E_L_E_T_ <> '*' "
	_cQryPV += "   AND SC6.D_E_L_E_T_ <> '*' "
	_cQryPV += "   AND SE4.D_E_L_E_T_ <> '*' "
	_cQryPV += "   AND SB1.D_E_L_E_T_ <> '*' "
	_cQryPV += " ORDER BY SC5.C5_NUM, SC6.C6_ITEM "
	_cQryPV := ChangeQuery( _cQryPV )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQryPV), "T_SC5PV", .T., .T. )	
	IF EOF()
	   MsgInfo("Nao existe pedidos a serem impressos com estes parametros","Aviso")
	   DBCloseArea("T_SC5PV")
	   Return
	ENDIF
	// Formatar os campos para uso
	aStru := T_SC5PV->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_SC5PV->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_SC5PV", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )
	
	For nViasImp := 1 To _nVias
	
		_nQuant := 0
		_nTot   := 0
		_nSubTot := 0
		_nIpi   := 0
		aObs    := {}
		cObs    := ""
		
		If !Empty(Alltrim(T_SC5PV->OBSPROD1))
			_cObsPrd	+= Alltrim(T_SC5PV->OBSPROD1)
			_cObsPrd	:= AjusStr(_cObsPrd)
		EndIf

		If !Empty(Alltrim(T_SC5PV->OBSFAT1))
			_cObsFat	+= Alltrim(T_SC5PV->OBSFAT1)
			_cObsFat	:= AjusStr(_cObsFat)
		EndIf

		// Volta para o primeiro registro
		T_SC5PV->( dbGoTop() )
		
		While !T_SC5PV->( Eof() )
		
			// Quando o número do pedido de vendas mudar
			If _cPVAtu != T_SC5PV->C5_NUM
			   cNumPed   := T_SC5PV->C5_NUM 
			   dEmiped   := T_SC5PV->C5_EMISSAO  
			   bUsaFor := .F.
			   // Verifica se o pedido usa cliente ou fornecedor
			   If T_SC5PV->TIPO<> "B" 
					_cQryPes := "SELECT A1_COD AS CODIGO, A1_LOJA AS LOJA,A1_NOME AS NOME, A1_DDD AS DDD, A1_TEL AS TEL, A1_FAX AS FAX, A1_END AS ENDER, A1_BAIRRO AS BAIRRO, A1_MUN AS MUN, "
					_cQryPes += "A1_EST AS ESTADO, A1_CEP AS CEP, A1_EMAIL AS EMAIL, A1_CONTATO AS CONTATO, A1_INSCR AS INSCR, A1_CGC AS CGC "
					_cQryPes += "FROM "+RetSqlName("SA1")+" SA1 "
					_cQryPes += "WHERE SA1.A1_COD='" + T_SC5PV->C5_CLIENTE + "' AND SA1.A1_LOJA='" +  T_SC5PV->C5_LOJACLI + "' "
					_cQryPes += "AND SA1.D_E_L_E_T_ <> '*' "    
				Else                   
			   	bUsaFor := .T.	                         
					_cQryPes := "SELECT A2_COD AS CODIGO, A2_LOJA AS LOJA,A2_NOME AS NOME, A2_DDD AS DDD, A2_TEL AS TEL, A2_FAX AS FAX, A2_END AS ENDER, A2_BAIRRO AS BAIRRO, A2_MUN AS MUN, "
					_cQryPes += "A2_EST AS ESTADO, A2_CEP AS CEP, A2_EMAIL AS EMAIL, A2_CONTATO AS CONTATO, A2_INSCR AS INSCR, A2_CGC AS CGC "
					_cQryPes += "FROM "+RetSqlName("SA2")+" SA2 "
					_cQryPes += "WHERE SA2.A2_COD='" + T_SC5PV->C5_CLIENTE + "' AND SA2.A2_LOJA='" +  T_SC5PV->C5_LOJACLI + "' "
					_cQryPes += "AND SA2.D_E_L_E_T_ <> '*' "    				
				EndIf
				_cQryPes := ChangeQuery( _cQryPes )
				dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQryPes), "CLIFOR", .T., .T. )	
			   // Traz informações do cadastro do cliente
				cCliNome  := CLIFOR->NOME
				cCliDDD   := CLIFOR->DDD
				cCliTel   := CLIFOR->TEL
				cCliFax   := CLIFOR->FAX
				cCliEnd   := CLIFOR->ENDER
				cCliMun   := CLIFOR->MUN
				cCliBair  := CLIFOR->BAIRRO
				cCliUF    := CLIFOR->ESTADO
				cCliEmail := CLIFOR->EMAIL 
				cCliCep   := CLIFOR->CEP  
				cCliCGC	  := CLIFOR->CGC
				cCliInscr := CLIFOR->INSCR
				
				CLIFOR->(dbCloseArea())
			   		   
			   cCodVend  := T_SC5PV->C5_VEND1
			   cCliCod   := T_SC5PV->C5_CLIENTE
			   dEntrega  := T_SC5PV->C6_ENTREG
			   cCodTransp:= T_SC5PV->C5_TRANSP  
				Do Case
					Case Alltrim(T_SC5PV->C5_TIPOPV) == "V"
						_TpPedVen   := "VENDA"
					Case Alltrim(T_SC5PV->C5_TIPOPV) == "S"
						_TpPedVen   := "SERVIÇO"
					Case Alltrim(T_SC5PV->C5_TIPOPV) == "T"
						_TpPedVen   := "TRIANGULAR"
					Case Alltrim(T_SC5PV->C5_TIPOPV) == "R"
						_TpPedVen   := "REM.TRIANG."   						
					Case Alltrim(T_SC5PV->C5_TIPOPV) == "D"
						_TpPedVen   := "RET.CSN"   						
					Case Alltrim(T_SC5PV->C5_TIPOPV) == "A"
						_TpPedVen   := "SERV.NFS-E" 
					Case Alltrim(T_SC5PV->C5_TIPOPV) == "F"
						_TpPedVen   := "FORNECEDOR" 
					OtherWise 
						_TpPedVen   := ""
				EndCase
			   
				// imprime o cabeçalho
				PrintCabec(cNumPed, dEmiPed, cCodVend, cCliCod, cCliNome, cCliDDD, cCliTel, cCliFax, cCliEnd, cCliMun, cCliBair, cCliUF, cCliEmail, cCliCep, cCodTransp, _TpPedVen, dEntrega)			     
               
				_nMoeda    := T_SC5PV->C5_MOEDA
				_cPrevisao := T_SC5PV->C5_EMISSAO
				_cPrazoPag := Posicione( "SE4", 1, xFilial("SE4") + T_SC5PV->C5_CONDPAG, "E4_DESCRI" )

				Do Case
					Case Alltrim(T_SC5PV->C5_TPFRETE) == "C"
						 _TpFrete   := "C I F" 
					Case Alltrim(T_SC5PV->C5_TPFRETE) == "F"
					     _TpFrete   := "F O B"   
					Case Alltrim(T_SC5PV->C5_TPFRETE) == "T"
					     _TpFrete   := "Terceiros" 
					Case Alltrim(T_SC5PV->C5_TPFRETE) == "S"
					     _TpFrete   := "Sem frete"  
					OtherWise 
						 _TpFrete   := ""    						
				 EndCase

			EndIf
			
			oPrint:Say( _nLin, 0100, T_SC5PV->C6_ITEM, oFont09 )
			oPrint:Say( _nLin, 0250, T_SC5PV->C6_PRODUTO, oFont09 ) 
			If Len(Alltrim(T_SC5PV->C6_DESCRI)) > 60
				// imprime a descrição em mais de uma linha     
				oPrint:Say( _nLin, 0550, Substr(Alltrim(T_SC5PV->C6_DESCRI),1,50), oFont09 )
				SomaLinha(50)
				oPrint:Say( _nLin, 0550, Substr(Alltrim(T_SC5PV->C6_DESCRI),51,50), oFont09 )				
			Else 
				oPrint:Say( _nLin, 0550, Alltrim(T_SC5PV->C6_DESCRI), oFont09 )			
			Endif
			oPrint:Say( _nLin, 1680, PadL( Transform( T_SC5PV->C6_UNSVEN, "@E 999999"), 06 ), oFont09,,,,1 )
			oPrint:Say( _nLin, 1800, PadL( Transform( T_SC5PV->C6_QTDVEN, "@E 999,999.999"), 11 ), oFont09,,,,1 )			
			oPrint:Say( _nLin, 2000, Ltrim(Rtrim(Posicione("SF4",1,xFilial("SF4") + T_SC5PV->C6_TES,"F4_CF"))), oFont09 )

			oPrint:Say( _nLin, 2200, PadC( T_SC5PV->C6_UM, 2 ), oFont09 )
			IF Posicione("SF4",1,xFilial("SF4") + T_SC5PV->C6_TES,"F4_IPI") == "S"
			   oPrint:Say( _nLin, 2400, PadL( Transform( T_SC5PV->B1_IPI, "@R 999.99%"), 08 ), oFont09,,,,1 )
 			ENDIF
 			oPrint:Say( _nLin, 2600, PadL( Transform( T_SC5PV->C6_PRCVEN, "@E 999,999,999.99"), 15 ), oFont09,,,,1 )
			oPrint:Say( _nLin, 3000, PadL( Transform( T_SC5PV->C6_VALOR, "@E 999,999,999.99"), 15 ), oFont09,,,,1 )
			oPrint:Say( _nLin, 3320, Substr(T_SC5PV->C6_ENTREG,01,02) + "/" + Substr(T_SC5PV->C6_ENTREG,04,02) + "/" + Substr(T_SC5PV->C6_ENTREG,07,04), oFont09,,,,1 )

			SomaLinha(50)
			If Alltrim(T_SC5PV->C5_TIPOPV)="D"
				// imprime dados adicionais de lote e localizacao
				oPrint:Say( _nLin, 0250, "Lote: " + T_SC5PV->C6_LOTECTL, oFont09 ) 
				oPrint:Say( _nLin, 0550, "Lote Fornecedor: " + T_SC5PV->B8_LOTEFOR, oFont09 ) 
				oPrint:Say( _nLin, 1000, "Localização PSZ: " + T_SC5PV->B8_ENDZAMP, oFont09 ) 
				SomaLinha(50)
			EndIf 

			IF Posicione("SF4",1,xFilial("SF4") + T_SC5PV->C6_TES,"F4_ESTOQUE") == "S"
				_nQuant  += T_SC5PV->C6_QTDVEN  
			   _nSubTot += T_SC5PV->C6_VALOR                         
			   IF Posicione("SF4",1,xFilial("SF4") + T_SC5PV->C6_TES,"F4_IPI") == "S" 
			   	_nTot   += T_SC5PV->C6_VALOR + round(((T_SC5PV->B1_IPI * T_SC5PV->C6_VALOR) / 100),2)
    			   _nIPI   += ROUND(((T_SC5PV->B1_IPI * T_SC5PV->C6_VALOR) / 100),2)
			   ELSE 
			       _nTot   += T_SC5PV->C6_VALOR       
			   ENDIF
      	ENDIF		   
         _cPvTria := T_SC5PV->C5_PVTRIAN
			_cPVAtu := T_SC5PV->C5_NUM
	
			T_SC5PV->( dbSkip() )
			
			// Quando mudar o pedido, imprime o rodapé
			If _cPVAtu != T_SC5PV->C5_NUM .or. Eof()
				PrintRodape()
			EndIf
		End

		//PrintRodape()
		
	Next
	
	T_SC5PV->( dbCloseArea() )

	oPrint:Preview()
	
	MS_FLUSH()

Return                                               

// Retorna um array com as linhas de texto do campo memo
Static Function MemoObs( cTexto, nTam )

	Local aObserv := {}
	Local nX := 1
	Local nLinhas := nResto := 0
	
	nLinhas := MlCount( cTexto, nTam )
	
	For nX := 1 To nLinhas
		aAdd( aObserv, MemoLine( cTexto, nTam, nX ) )
	Next

Return( aObserv )

// Verifica se a soma de linhas não ultrapassa o limite
Static Function SomaLinha(nLinhas)
	
	_nLin += nLinhas
	
	// Se ultrapassar o limite encerra a página e inicia outra com o cabeçalho
	If _nLin >= _nLimVert
		oPrint:EndPage()
		PrintCabec(cNumPed, dEmiPed, cCodVend, cCliCod, cCliNome, cCliDDD, cCliTel, cCliFax, cCliEnd, cCliMun, cCliBair, cCliUF, cCliEmail, cCliCep, cCodTransp,_TpPedVen, dEntrega)
	EndIf
	
Return

// Imprime o rodapé e finaliza a página
Static Function PrintRodape()	
	Local nX :=0

	oPrint:Line( _nLin, 0100, _nLin, 3420)

	SomaLinha(50)
	oPrint:Line( _nLin, 0550, _nLin + 250, 0550 )

	oPrint:Say( _nLin, 0100, "Condição de Pagamento", oFont10b )

	oPrint:Say( _nLin, 0600, "Subtotais", oFont12b )
	oPrint:Say( _nLin, 1800, PadL( Transform( _nQuant, "@E 999,999,999.999"), 15 ), oFont12,,,,1 )

	oPrint:Say( _nLin, 3000, PadL( Transform( _nSubTot, "@E 999,999,999.99"), 15 ), oFont12,,,,1 )

	SomaLinha(50)

	oPrint:Say( _nLin, 0100, _cPrazoPag, oFont10 )
                                                   
    IF _nIpi > 0 
	   oPrint:Say( _nLin, 0600, "Valor do IPI", oFont12b )
	   oPrint:Say( _nLin, 3000, PadL( Transform( _nIpi, "@E 999,999,999.99"), 15 ), oFont12,,,,1 )
    ENDIF
	SomaLinha(60)
	oPrint:Say( _nLin, 0100, "Tipo de Frete", oFont10b )

	oPrint:Line( _nLin - 5, 0600, _nLin - 5, 3420)
	oPrint:Say( _nLin, 0600, "Valor Total do Pedido", oFont14b )
	oPrint:Say( _nLin, 3000, PadL( Transform( _nTot, "@E 999,999,999.99"), 15 ), oFont14b,,,,1 )

    If !Empty(Alltrim(_TpFrete))
	   SomaLinha(50)
	   oPrint:Say( _nLin, 0100, _Tpfrete, oFont10 )
	Endif

	SomaLinha(50)
    
	oPrint:Say( _nLin, 0100, "Tipo Ped.: "+_TpPedVen, oFont10b )
		
	SomaLinha(60)

	If _nMoeda > 1
		oPrint:Say( _nLin, 0100, "Cotação US$", oFont10b )
		oPrint:Say( _nLin + 50, 0100, "R$ "+ AllTrim( Transform( _nCotDia, "@E 99.9999") ) +" - "+ DtoC( StoD( _dCotDia ) ), oFont10 )
	EndIf

	SomaLinha(110)
	oPrint:Line( _nLin, 0900, _nLin, 1400 )
	oPrint:Line( _nLin, 1600, _nLin, 2100 )            
	If !bUsaFor
		oPrint:Say( _nLin + 5, 1035, "Assinatura do Cliente", oFont08 )  
	Else                                                                
		oPrint:Say( _nLin + 5, 1035, "Assinatura do Fornecedor", oFont08 )  	
	EndIf
	oPrint:Say( _nLin + 5, 1735, "Assinatura do Vendedor", oFont08 )
	SomaLinha(50)
	If !Empty(_cObsPrd)
		SomaLinha(40)
		oPrint:Say( _nLin, 0100, "Observações da Produção", oFont10 )
		aObs := MemoObs( _cObsPrd, 150 )
	
		If Len( aObs ) >= 1
			For nX := 1 To Len( aObs )
				SomaLinha(40)
				oPrint:Say( _nLin, 0100, aObs[nX], oFont10 )
			Next
		EndIf

	//		oPrint:Say( _nLin, 0100, _cObsPrd, oFont10 )
		SomaLinha(40)
	EndIf                                 
	
	If !Empty(_cObsFat)
		SomaLinha(40)
		oPrint:Say( _nLin, 0100, "Observações do Faturamento", oFont10 )
		aObs := MemoObs( _cObsFat, 150 )
	
		If Len( aObs ) >= 1
			For nX := 1 To Len( aObs )
				SomaLinha(40)
				oPrint:Say( _nLin, 0100, aObs[nX], oFont10 )
			Next
		EndIf

		SomaLinha(40)
	EndIf   
	
	If !Empty(_cPVTria)
		SomaLinha(40)    
		oPrint:Say( _nLin, 0100, "Nr. Pedido Triangular Associado: " , oFont10b )
		oPrint:Say( _nLin, 0800, _cPVTria , oFont10 )
		SomaLinha(40)
	Endif                              

	oPrint:EndPage()
	
	_nQuant := 0
	_nTot   := 0
	_nSubTot:= 0
	_nIpi   := 0
	aObs    := {}
	cObs    := ""

Return

// Inicia nova página e imprime o cabeçalho, ajustando a linha para impressão
Static Function PrintCabec(cNumPed, dEmiPed, cCodVend, cCliCod, cCliNome, cCliDDD, cCliTel, cCliFax, cCliEnd, cCliMun, cCliBair, cCliUF, cCliEmail, cCliCep, cCodTransp, TpPedVen, dEntrega)

	oPrint:StartPage()

    _nLin := 60
	
	// Logotipo e identificação do pedido
	oPrint:SayBitmap(_nLin, 0100, "logopsz.png", 0900, 0170)

	_nLin += 90

	oPrint:Say(_nLin, 1350, "PEDIDO DE VENDA: ", oFont16b)
	oPrint:Say(_nLin, 1950, cNumPed, oFont16b)
	oPrint:Say(_nLin, 2800, "EMISSÃO:", oFont16b)
	oPrint:Say(_nLin, 3100, dEmiPed, oFont16b)
	
	_nLin += 60
	oPrint:Line(_nLin, 0100, _nLin, 3420)
    _nLin += 40
	
	dbSelectArea("SM0")
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )
	
	// Dados de cadastro
	oPrint:Say( _nLin, 0330, "PS ZAMPROGNA PROD. METAL. LTDA.", oFont10b )
    _nLin += 50
    
	oPrint:Say( _nLin, 0110, "Endereço:", oFont10 )
	oPrint:Say( _nLin, 0330, AllTrim( SM0->M0_ENDENT ) +" "+ AllTrim( SM0->M0_COMPENT ), oFont10b )
	oPrint:Say( _nLin, 2600, "Cidade:", oFont10 )
	oPrint:Say( _nLin, 2800, SM0->M0_CIDENT, oFont10b )
    _nLin += 50

	oPrint:Say( _nLin, 0110, "CNPJ:", oFont10 )
	oPrint:Say( _nLin, 0330, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), oFont10b )
	oPrint:Say( _nLin, 2600, "Estado:", oFont10 )
	oPrint:Say( _nLin, 2800, SM0->M0_ESTENT, oFont10b )
    _nLin += 50	

	oPrint:Say( _nLin, 0110, "E-mail:", oFont10 )
	oPrint:Say( _nLin, 0330, "psz@pszamprogna.com.br", oFont10b )
	oPrint:Say( _nLin, 2600, "Fone/Fax:", oFont10 )
	oPrint:Say( _nLin, 2800, Transform( SM0->M0_TEL, "@R (99) 9999-9999" )+"/"+Transform( SM0->M0_FAX, "@R (99) 9999-9999" ), oFont10b )
    _nLin += 50	                      
       
	oPrint:Say( _nLin, 0110, "Vendedor:", oFont10 )
	oPrint:Say( _nLin, 0330, Alltrim(cCodVend)+" - "+Posicione( "SA3", 1, xFilial("SA3") + cCodVend, "A3_NOME" ), oFont10b )
	oPrint:Say( _nLin, 2600, "Dt. Entrega:", oFont10 )
	oPrint:Say( _nLin, 2800, dEntrega, oFont10b )

    _nLin += 50	
	oPrint:Line( _nLin, 0100, _nLin, 3420 )
    _nLin += 50	
	
	// Dados do cliente           
	If !bUsaFor
		oPrint:Say( _nLin, 0110, "Cliente:", oFont10 )
	Else 
		oPrint:Say( _nLin, 0110, "Fornecedor:", oFont10 )
	Endif
	oPrint:Say( _nLin, 0330, cCliCod +" - "+ cCliNome, oFont10b )
	oPrint:Say( _nLin, 2600, "Fone/Fax:", oFont10 )
	oPrint:Say( _nLin, 2800, Transform( AllTrim( cCliDDD) + cCliTel, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( cCliDDD) + cCliFax, "@R (99) 9999-9999" ), oFont10b )
    _nLin += 50	

	//Impressao do CGC e Inscricao estadual
	oPrint:Say( _nLin, 0110, "CNPJ:", oFont10 )   
	If Len(AllTrim(cCliCGC)) > 11
		oPrint:Say( _nLin, 0330, Transform( AllTrim(cCliCGC), "@R 99.999.999/9999-99"), oFont10b )
	else
		oPrint:Say( _nLin, 0330, Transform( AllTrim(cCliCGC), "@R 999.999.999-99"), oFont10b )		
	Endif
	oPrint:Say( _nLin, 2600, "Insc. Est.:", oFont10 )
	oPrint:Say( _nLin, 2800, cCliInscr, oFont10b )
    _nLin += 50	

	
	oPrint:Say( _nLin, 0110, "Endereço:", oFont10 )
	oPrint:Say( _nLin, 0330, AllTrim( cCliEnd ) +" "+ AllTrim( cCliBair ) +" "+ Transform( AllTrim( cCliCep), "@R 99999-999"), oFont10b )
	oPrint:Say( _nLin, 2600, "Cidade:", oFont10 )
	oPrint:Say( _nLin, 2800, cCliMun, oFont10b )
    _nLin += 50	
    	
	oPrint:Say( _nLin, 0110, "E-mail:", oFont10 )
	oPrint:Say( _nLin, 0330, AllTrim( Substring(cCliEmail,1,80) ), oFont10b )
	oPrint:Say( _nLin, 2600, "Estado:", oFont10 )
	oPrint:Say( _nLin, 2800, cCliUF, oFont10b )
   _nLin += 50		     
    
	// Dados do cliente entrega quando triangular  
	IF T_SC5PV->C5_TIPOPV == "T"  
		// Busca os dados do cliente do pedido de remessa para realizar a impressao de forma correta
		_cQryCli := "SELECT C5_CLIENTE, C5_LOJACLI "
		_cQryCli += "FROM "+RetSqlName("SC5")+" SC5 "
		_cQryCli += "WHERE SC5.C5_NUM='" + T_SC5PV->C5_PVTRIAN + "' "
		_cQryCli += "AND SC5.D_E_L_E_T_ <> '*' "    				
		_cQryCli := ChangeQuery( _cQryCli )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQryCli), "CLIPVREM", .T., .T. )	 
		If !Eof()
	      //_nLin += 50	
			oPrint:Line( _nLin, 0100, _nLin, 3420 )
			_nLin += 50		   
			IF SA1->(DBSEEK(xFilial("SA1") + CLIPVREM->C5_CLIENTE + CLIPVREM->C5_LOJACLI))
				oPrint:Say( _nLin, 0100, "Cliente Rem.:", oFont10 )
		      oPrint:Say( _nLin, 0330, SA1->A1_COD +" - "+ SA1->A1_NOME, oFont10b )
		      oPrint:Say( _nLin, 2600, "Fone/Fax:", oFont10 )
		      oPrint:Say( _nLin, 2800, Transform( AllTrim( SA1->A1_DDD ) + SA1->A1_TEL, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( SA1->A1_DDD ) + SA1->A1_FAX, "@R (99) 9999-9999" ), oFont10b )
	         _nLin += 50	
			   
			   oPrint:Say( _nLin, 0100, "Endereço:", oFont10 )
		      oPrint:Say( _nLin, 0330, AllTrim( SA1->A1_END ) +" "+ AllTrim( SA1->A1_BAIRRO ) +" "+ Transform( AllTrim( SA1->A1_CEP ), "@R 99999-999"), oFont10b )
		      oPrint:Say( _nLin, 2600, "Cidade:", oFont10 )
		      oPrint:Say( _nLin, 2800, SA1->A1_MUN, oFont10b )
	         _nLin += 50	
	    	
		      oPrint:Say( _nLin, 0100, "E-mail:", oFont10 )
		      oPrint:Say( _nLin, 0330, AllTrim( SA1->A1_EMAIL ), oFont10b )
		      oPrint:Say( _nLin, 2600, "Estado:", oFont10 )
		      oPrint:Say( _nLin, 2800, SA1->A1_EST, oFont10b )
	         _nLin += 50	                                             
			ENDIF
		   DBCloseArea("CLIPVREM")			
	   ENDIF
	EndIf
	IF !EMPTY(ALLTRIM(cCodTransp))                                   
      oPrint:Line( _nLin, 0100, _nLin, 3420 )
      _nLin += 50	
      IF SA4->(DBSEEK(xFilial("SA4") + cCodTransp))
	   	oPrint:Say( _nLin, 0110, "Transportadora:", oFont10 )
	      oPrint:Say( _nLin, 0360, ALLTRIM(SA4->A4_COD) +" - "+ SA4->A4_NOME, oFont10b )
         _nLin += 50	
	      oPrint:Say( _nLin, 0110, "Endereço:", oFont10 )
	      oPrint:Say( _nLin, 0330, AllTrim(SA4->A4_END ) +" "+ AllTrim( SA4->A4_BAIRRO ) +" "+ Transform( AllTrim( SA4->A4_CEP ), "@R 99999-999"), oFont10b )
	      oPrint:Say( _nLin, 2600, "Cidade:", oFont10 )
	      oPrint:Say( _nLin, 2800, SA4->A4_MUN, oFont10b )
		ENDIF
	ENDIF
	// Cabeçalhos dos itens
   _nLin += 50	
   oPrint:Line( _nLin, 0100, _nLin, 3420)
   _nLin += 50	
	oPrint:Say( _nLin, 0100, "Item", oFont09b )
	oPrint:Say( _nLin, 0250, "Código", oFont09b )
	oPrint:Say( _nLin, 0550, "Descrição", oFont09b )

	oPrint:Say( _nLin, 1680, "Nº PEÇAS", oFont09b,,,,1 )
	oPrint:Say( _nLin, 1800, "QTD", oFont09b,,,,1 )
	oPrint:Say( _nLin, 2000, "CFOP", oFont09b,,,,1 )

	oPrint:Say( _nLin, 2200, "UN.", oFont09b )
	oPrint:Say( _nLin, 2400, PadL( "% IPI", 08 ), oFont09b,,,,1 )

	oPrint:Say( _nLin, 2600, PadL( "Vlr.Unit. " + Iif( T_SC5PV->C5_MOEDA == 1, "R$", "US$" ), 15 ), oFont09b,,,,1 )

	oPrint:Say( _nLin, 3000, PadL( "Vlr.Total " + Iif( T_SC5PV->C5_MOEDA == 1, "R$", "US$" ), 15 ), oFont09b,,,,1 )
	oPrint:Say( _nLin, 3320, "Data Entrega", oFont09b,,,,1)

    _nLin += 50
	oPrint:Line( _nLin, 0100, _nLin, 3420 )
    _nLin += 50

Return

// Cria as perguntas para o relatório
Static Function AjustaSX1( cPerg )

	PutSx1( cPerg, "01", "Do Pedido ?          ","","","mv_ch1","C",06,00,00,"G" ,""  ,"SC7",""     ,""   ,"MV_PAR01",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "02", "Até o Pedido ?       ","","","mv_ch2","C",06,00,00,"G" ,""  ,"SC7",""     ,""   ,"MV_PAR02",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
//	PutSx1( cPerg, "03", "Da Emissão ?         ","","","mv_ch3","D",08,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR03",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
//	PutSx1( cPerg, "04", "Até Emisão ?         ","","","mv_ch4","D",08,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR04",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
//	PutSx1( cPerg, "05", "Descrição Produto ?  ","","","mv_ch5","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR05","Do Cadastro" ,""      ,""      ,""    ,"Do Pedido"   ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
//	PutSx1( cPerg, "06", "Nº de Vias ?         ","","","mv_ch6","N",02,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR06",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
//	PutSx1( cPerg, "07", "Data da Cotação ?    ","","","mv_ch7","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR06","Da Emissão"  ,""      ,""      ,""    ,"Da Impressão",""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
//	PutSx1( cPerg, "08", "Moeda ?              ","","","mv_ch8","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR07","Do Pedido"   ,""      ,""      ,""    ,"Corrente"    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")

Return

// Imprime uma régua horizontal numerada de 100 em 100 e uma régua vertical numerada de 50 em 50
Static Function PrtRegua()
Local xxx :=0

	For xxx = 100 to 2400 step 100
		oPrint:Line( 0010, xxx, 0030, xxx )
		oPrint:Say( 0010, xxx+10, AllTrim( Str(xxx) ), oFont08 )
		If xxx > 2400
			Exit
		EndIf
	Next

	For xxx = 50 to 3600 step 50
		oPrint:Line( xxx, 0020, xxx, 0040 )
		oPrint:Say( xxx - 25, 0020, AllTrim( Str( xxx ) ), oFont06 )
		If xxx > 3600
			Exit
		EndIf
	Next

Return

Static Function AjusStr(cTexto)

Local _nInd := 0
Local _TxtAju	:= cTexto

Do While _nInd < Len(_TxtAju)
	_nInd ++
	If Substr(_TxtAju,_nInd,1) == CHR(13)
		_TxtAju	:= STUFF(_TxtAju,_nInd,1," ")
	EndIf
EndDo

Return(_TxtAju)
