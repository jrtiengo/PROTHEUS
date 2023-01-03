#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PE_M460FIM ?Autor ?Jeferson Arteiro      ?Data ?8/01/2016³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ZAMPROGNA          ³Contato ?jeferson@veza.com.br           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³P.E. apos a gravacao da tabela SD2 na geracao da NFS.        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - MATA461                                            ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterado: 000000 - Analista - 99/99/9999 - Motivo da Alteracao
*/

User Function M460FIM()
	*********************

	Local aArea    		:= GetArea()   
	Local aArea2		:= GetArea()
	Local aSC5          := SC5->(getArea())                                                                     
	Local nVlrDesp 		:= 0
	Local _cLote		:= ""
	Local _cSubLote		:= ""
	Local _cEnder		:= ""
	Local _cPedido		:= ""
	Local _cItem		:= ""
	/* variaveis não usadas. 
	//Local nTotal  		:= 0
	//Local nCont    		:= 0
	Local bRecria		:= .F.   
	Local cItemDB   	:= "" 
	Local cTM      		:= ""
	Local cOrigem  		:= ""
	Local cIdOper		:= "" 
	Local cRecSDB   	:= ""
	Local bBaixa   		:= .T.
	Local bRecriaSD5	:= .T.
	Local cQtdBaixa 	:= 0 
	Local cRecSD5   	:= ""    
	Local cOrigSD5  	:= "" 
	*/
	Local EmiteBol		:= "2" // 1-Sim;2=Nao
	Local sCondAVista	:= GETMV("PS_CONDAVI") 
	Local CPEDDEVN		:= GETMV("PS_PEDDEVN") 
	Local sCondVenda	:= ""
	Local lGeraCSV      := .F.
	Local lEnvMail      := SUPERGETMV("MV_MAILENV", .F.,.T.)

	Private sGeraDupl	:= ""

	//fwalertInfo("PE-M460FIM","TOTVS")  

	_cQry460	:=	"SELECT D2_PEDIDO PEDIDO, "
	_cQry460	+=	"   D2_ITEMPV ITEM, "
	_cQry460	+=	"   D2_COD PRODUTO, " 
	_cQry460 	+=  "    B1_TIPO AS TPPROD, "     
	_cQry460 	+=  "    B1_RASTRO AS RASTRO, "      
	_cQry460 	+=  "    C5_TIPOPV AS TIPOPV, "           
	_cQry460 	+=  "    D2_QUANT AS QTDMOV, "
	_cQry460 	+=  "    D2_LOCAL AS LOCSAI, " 
	_cQry460 	+=  " 	 D2_EMISSAO AS EMISSAO, "   
	_cQry460 	+=  " 	 D2_DOC AS DOC, D2_SERIE AS SERIE, D2_CLIENTE AS CLI, D2_LOJA AS LOJA, "   
	_cQry460 	+=  "	 D2_NUMSEQ AS SEQ, "
	_cQry460	+=	"	 D2_ITEM AS ITEM, F4_ESTOQUE, A1_EMITBOL,  F2_COND AS CODCOND, F4_DUPLIC AS GERADUPL "		  	
	_cQry460	+=	"FROM "+RetSQLName("SD2")+" SD2 "  
	_cQry460	+=	"LEFT JOIN "  + RetSqlName("SF2") + " AS SF2 (NOLOCK) ON F2_FILIAL='" + xFilial("SF2") + "' AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_LOJA=D2_LOJA AND F2_TIPO=D2_TIPO AND SF2.D_E_L_E_T_ <> '*' " 
	_cQry460	+=	"INNER JOIN " + RetSqlName("SB1") + " AS SB1 (NOLOCK) ON B1_FILIAL='" + xFilial("SB1") + "' AND B1_COD=D2_COD  " 
	_cQry460	+=	"INNER JOIN " + RetSqlName("SC5") + " AS SC5 (NOLOCK) ON C5_FILIAL='" + xFilial("SC5") + "' AND C5_NUM=D2_PEDIDO AND C5_CLIENTE=D2_CLIENTE AND C5_LOJACLI=D2_LOJA "
	_cQry460	+=  "INNER JOIN " + RetSqlName("SF4") + " AS SF4 (NOLOCK) ON F4_FILIAL='" + xFilial("SF4") + "' AND F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_ <> '*' "
	_cQry460	+=  "LEFT JOIN "  + RetSqlName("SA1") + " AS SA1 (NOLOCK) ON A1_FILIAL='" + xFilial("SA1") + "' AND A1_COD=D2_CLIENTE AND A1_LOJA=D2_LOJA AND SA1.D_E_L_E_T_ <>'*' "
	_cQry460	+=	"WHERE D2_FILIAL = '"+xFilial("SD2")+"'"
	_cQry460	+=	"   AND D2_DOC = '"+SD2->D2_DOC+"'"  
	_cQry460 	+=  "   AND D2_SERIE='" + SD2->D2_SERIE + "' "
	_cQry460	+=	"   AND SD2.D_E_L_E_T_ <> '*'"   
	_cQry460	+=	"   AND SB1.D_E_L_E_T_ <> '*'" 
	_cQry460 	+=  "   AND SC5.D_E_L_E_T_ <> '*'"
	TCQUERY _cQry460 NEW ALIAS "M460"       
	DbSelectArea("M460")
	M460->(dbGoTop())
	Do While M460->(!Eof()) 

		EmiteBol 	:= A1_EMITBOL
		sCondVenda	:= CODCOND
		sGeraDupl	:= GERADUPL
		_cLote		:= Posicione("SC6",1,xFilial("SC6")+PEDIDO+ITEM+PRODUTO,"C6_LOTECTL")
		_cSubLote	:= Posicione("SC6",1,xFilial("SC6")+PEDIDO+ITEM+PRODUTO,"C6_NUMLOTE")
		_cEnder		:= Posicione("SC6",1,xFilial("SC6")+PEDIDO+ITEM+PRODUTO,"C6_LOCALIZ")      
		_cDtValid	:= Posicione("SC6",1,xFilial("SC6")+PEDIDO+ITEM+PRODUTO,"C6_DTVALID")
		_cPedido	:= PEDIDO
		_cItem		:= ITEM                  
		
		// Grava nota gerada no sc6 para possibilitar o correto cancelamento do item de retorno
		_cQryUpd	:= "BEGIN UPDATE "+RetSQLName("SC6")+" "
		_cQryUpd	+= "SET C6_NOTARET='" + DOC + "', C6_SERRET='" + SERIE + "' "
		_cQryUpd	+= "WHERE C6_NUM='" + PEDIDO + "' "
		_cQryUpd	+= "AND C6_ITEMRET='S' "
		_cQryUpd	+= "AND D_E_L_E_T_ <> '*'; COMMIT; END;"
		TCSqlExec(_cQryUpd) 
	
		DbSelectARea("SD2")
		DbSetOrder(8)
		If DbSeek(xFilial("SD2")+_cPedido+_cItem)	    		    
			If  Empty(Alltrim(SD2->D2_LOTECTL))
				RecLock("SD2",.F.)
					SD2->D2_LOTECTL	:= _cLote
					SD2->D2_NUMLOTE	:= _cSubLote
				MsUnlock()
			EndIf
			If  Empty(Alltrim(SD2->D2_LOCALIZ))
				RecLock("SD2",.F.)
					SD2->D2_LOCALIZ	:= _cEnder
				MsUnlock()
			EndIf
		EndIf		
		M460->(DBSKIP())
	EndDo   
	    
	M460->(dbCloseArea())   

	//abre sc5 para gerar o csv - lotes
	IF!EMPTY(_cPedido)
		dbSelectArea('SC5') 
		SC5->(dbSetOrder(1))
		if SC5->(dbSeek(xFilial('SC5')+_cPedido))
			lGeraCSV := .T.
		endIf
	ENDiF		

	// FORCA A GRAVACAO DO CLIENTE CORRETO DA SF2	  
	//Katieli - bmtec - 26112021: adicionado campo do pedido
	_cQryUpd := "BEGIN UPDATE "+RetSQLName("SF2")+" "
	_cQryUpd	+= "SET F2_CLIENT=F2_CLIENTE, F2_LOJENT=F2_LOJA "
	if alltrim(CPEDDEVN) <> ''
	_cQryUpd	+= " ,F2_PEDDEVN='"+CPEDDEVN+"' "
	endIf
	_cQryUpd	+= "WHERE F2_FILIAL='" + XFILIAL("SF2") + "' "
	_cQryUpd	+= "AND F2_DOC='"+SF2->F2_DOC+"' "
	_cQryUpd	+= "AND F2_SERIE='"+SF2->F2_SERIE+"' "
	_cQryUpd	+= "AND F2_CLIENTE='"+SF2->F2_CLIENTE+"' "  
	_cQryUpd	+= "AND F2_LOJA='"+SF2->F2_LOJA+"' "  
	_cQryUpd	+= "AND D_E_L_E_T_ <> '*'; COMMIT; END;"
	TCSqlExec(_cQryUpd)      
	
	PUTMV("PS_PEDDEVN", "")

	// Faz query para verificar numero de parcelas e se gera duplicata sim ou nao na TES   
	// Nao precisa considerar IPI
	cValBrut := 0
	_cQry460	:=	"SELECT SUM(D2_VALBRUT) AS VALORBRUTO,SUM(D2_DESPESA) AS VALORDESP,SUM(D2_VALIPI) AS VALORIPI "
	_cQry460	+=	"FROM "+RetSQLName("SD2")+" SD2 (NOLOCK) "  
	_cQry460	+=	"LEFT JOIN " + RetSqlName("SF4") +" AS SF4 (NOLOCK) ON F4_FILIAL='" + xFilial("SF4") + "' AND F4_CODIGO=D2_TES AND SF4.D_E_L_E_T_ <> '*' " 
	_cQry460	+=	"WHERE D2_FILIAL = '"+xFilial("SD2")+"'"
	_cQry460	+=	"AND D2_DOC = '"+SF2->F2_DOC+"'"  
	_cQry460 += "AND D2_SERIE='" + SF2->F2_SERIE + "' "   
	_cQry460 += "AND D2_CLIENTE='" + SF2->F2_CLIENTE + "' "   
	_cQry460 += "AND D2_LOJA='" + SF2->F2_LOJA + "' " 
	_cQry460 += "AND F4_DUPLIC='S' "  
	_cQry460	+=	"AND SD2.D_E_L_E_T_ <> '*'"   
	TCQUERY _cQry460 NEW ALIAS "TotFat"       
	DbSelectArea("TotFat")
	If !Eof()
		nValBrut := TotFat->VALORBRUTO
		cValBrut := round(TotFat->VALORBRUTO,2)
		cValDesp := round(TotFat->VALORDESP,2)
		cValIPI := round(TotFat->VALORIPI,2)
	Endif  
	dbSelectArea("TotFat")
	dbCloseArea()
	
	cDespesa := 0
	_cQry460	:=	"SELECT F2_DESPESA AS DESPESA "
	_cQry460	+=	"FROM "+RetSQLName("SF2")+" SF2 (NOLOCK) "  
	_cQry460	+=	"WHERE F2_FILIAL = '"+xFilial("SF2")+"'"
	_cQry460	+=	"AND F2_DOC = '"+SF2->F2_DOC+"'"  
	_cQry460 += "AND F2_SERIE='" + SF2->F2_SERIE + "' "   
	_cQry460 += "AND F2_CLIENTE='" + SF2->F2_CLIENTE + "' "   
	_cQry460 += "AND F2_LOJA='" + SF2->F2_LOJA + "' " 
	_cQry460	+=	"AND SF2.D_E_L_E_T_ <> '*'"   
	TCQUERY _cQry460 NEW ALIAS "TotDesp"       
	DbSelectArea("TotDesp")
	If !Eof()
		cDespesa := TotDesp->DESPESA     
	Endif  
	dbSelectArea("TotDesp")
	dbCloseArea()	

 	iQtdParc := 0
	_cQry460	:=	"SELECT COUNT(*) AS QTD, SUM(E1_VALOR) AS VALFIN "
	_cQry460	+=	"FROM "+RetSQLName("SE1")+" SE1 (NOLOCK) "  
	_cQry460	+=	"WHERE E1_FILIAL = '"+xFilial("SE1")+"'"	
	_cQry460	+=	"AND E1_NUM='" + SF2->F2_DOC + "' "      
	_cQry460	+=	"AND E1_PREFIXO='" + SF2->F2_SERIE + "' "   
	_cQry460	+=	"AND E1_CLIENTE='" + SF2->F2_CLIENTE + "' "
	_cQry460	+=	"AND E1_LOJA='" +  SF2->F2_LOJA + "' "
	_cQry460	+=	"AND SE1.D_E_L_E_T_ <> '*' "
	TCQUERY _cQry460 NEW ALIAS "QtdParc"      
	DbSelectArea("QtdParc")
	If !Eof()
		iQtdParc := QtdParc->QTD 
		cValFin	:= round(QtdParc->VALFIN,2)
	Endif  
	dbSelectArea("QtdParc")
	dbCloseArea()	               
	
	iTotAdia := 0
	_cQryTAd :=	"SELECT SUM(FIE_VALOR) AS VALADIANT "
	_cQryTAd +=	"FROM "+RetSQLName("FIE")+" FIE (NOLOCK) "  
	_cQryTAd +=	"WHERE FIE_FILIAL = '"+xFilial("FIE")+"' "	
	_cQryTAd +=	"AND FIE_PEDIDO='" + _cPedido + "' " 
	_cQryTAd +=	"AND FIE.D_E_L_E_T_ <> '*' "
	TCQUERY _cQryTAd NEW ALIAS "TAdia"      
	DbSelectArea("TAdia")
	If !Eof()
		iTotAdia := TAdia->VALADIANT 
	Endif  
	dbSelectArea("TAdia")
	dbCloseArea()	               

	// Verifica se tem diferenca entre o valor bruto e o valor financeiro
	// Se tem diferenca eh em funcao do IPI, dessa forma, soma, alem
	// das despesas financeiras, tambem o IPI na primeira parcela 
	// Diminui do valor financeiro o valor da despesa do item e soma a despesa total 
	cValDif := 0 
	If cValIPI <> 0
		cValDif	:= Round(cValBrut - (cValFin-cValDesp+cDespesa),2)
	Endif  
	
   	nVlrParc := ROUND((nValBrut) / iQtdParc,2)
   	nVlrDesp := ROUND(cDespesa / iQtdParc,2)                 
	
	If cValDif <> 0  
	
		// soma diferenca na primeira parcela  
		If iQtdParc >1   
			// Atualiza a despesa acessoria e a diferenca na primeira parcela
		 	_cQryUpd	:= "BEGIN UPDATE "+RetSQLName("SE1")+" "
		  	_cQryUpd	+= "SET E1_VALOR=" + Ltrim(Rtrim(Str(nVlrParc+cValDif+nVlrDesp))) + ", "
		  	_cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+cValDif+nVlrDesp))) + ", "
		  	_cQryUpd	+= "E1_VLCRUZ=" + Ltrim(Rtrim(Str(nVlrParc+cValDif+nVlrDesp))) + ", "
			_cQryUpd	+= "WHERE E1_FILIAL='" + xFilial("SE1") + "' "
		  	_cQryUpd	+= "AND E1_CLIENTE='"+SF2->F2_CLIENTE+"' "
		  	_cQryUpd	+= "AND E1_LOJA='"+SF2->F2_LOJA+"' "
		  	_cQryUpd	+= "AND E1_PREFIXO='"+SF2->F2_SERIE+"' "  
		  	_cQryUpd	+= "AND E1_NUM='"+SF2->F2_DOC+"' " 
		  	_cQryUpd	+= "AND E1_PARCELA='A'" 		  	 
		  	_cQryUpd	+= "AND D_E_L_E_T_ <> '*'; COMMIT; END;"
			MEMOwrite('C:\temp\_cQryUpd.txt', _cQryUpd)
		  	TCSqlExec(_cQryUpd)	
			// Atualiza apenas despesas nas demais parcelas
		 	_cQryUpd	:= "BEGIN UPDATE "+RetSQLName("SE1")+" "
		  	_cQryUpd	+= "SET E1_VALOR=" + Ltrim(Rtrim(Str(nVlrParc+nVlrDesp))) + ", "
		  	_cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+nVlrDesp))) + ", "
		  	_cQryUpd	+= "E1_VLCRUZ=" + Ltrim(Rtrim(Str(nVlrParc+nVlrDesp))) + ", "
			_cQryUpd	+= "WHERE E1_FILIAL='" + xFilial("SE1") + "' "
		  	_cQryUpd	+= "AND E1_CLIENTE='"+SF2->F2_CLIENTE+"' "
		  	_cQryUpd	+= "AND E1_LOJA='"+SF2->F2_LOJA+"' "
		  	_cQryUpd	+= "AND E1_PREFIXO='"+SF2->F2_SERIE+"' "  
		  	_cQryUpd	+= "AND E1_NUM='"+SF2->F2_DOC+"' " 
		  	_cQryUpd	+= "AND E1_PARCELA<>'A'" 		  	 
		  	_cQryUpd	+= "AND D_E_L_E_T_ <> '*'; COMMIT; END;"
			MEMOwrite('C:\temp\_cQryUpd2.txt', _cQryUpd)
			
		  	TCSqlExec(_cQryUpd)		
		Else         
		
			// Verifica se a parcela tem diferenca entre o valor bruto
			cValDifDesp := 0
			cValDifDesp	:= Round(cValBrut - (cValFin-cValDesp+cDespesa),2) 
			If cValDifDesp < 0
				cValDifDesp :=cValDifDesp *-1
			Endif
			
			// Atualiza a despesa acessoria e a diferenca
		 	_cQryUpd	:= "BEGIN UPDATE "+RetSQLName("SE1")+" "
		  	_cQryUpd	+= "SET E1_VALOR=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + ", "
		  	//_cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + ", " // Quando for adiantamento, é necessário baixar o título NF - TIENGO 2212
			IF iTotAdia > 0
				_cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp-iTotAdia))) + ", "
			Else
				_cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + ", "	
			EndIf
		  	_cQryUpd	+= "E1_VLCRUZ=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + " "
		  	_cQryUpd	+= "E1_VLCRUZ=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + ", "
			_cQryUpd	+= "WHERE E1_FILIAL='" + xFilial("SE1") + "' "
		  	_cQryUpd	+= "AND E1_CLIENTE='"+SF2->F2_CLIENTE+"' "
		  	_cQryUpd	+= "AND E1_LOJA='"+SF2->F2_LOJA+"' "
		  	_cQryUpd	+= "AND E1_PREFIXO='"+SF2->F2_SERIE+"' "  
		  	_cQryUpd	+= "AND E1_NUM='"+SF2->F2_DOC+"' "  
		  	_cQryUpd	+= "AND D_E_L_E_T_ <> '*'; COMMIT; END;"
			MEMOwrite('C:\temp\_cQryUpd3.txt', _cQryUpd)
		  	TCSqlExec(_cQryUpd)			
		Endif
	ElseIf nVlrDesp <> 0 .or. iTotAdia > 0
		
			// Verifica se a parcela tem diferenca entre o valor bruto  
			cValDifDesp := 0
			cValDifDesp	:= Round(cValBrut - (cValFin-cValDesp+cDespesa),2) 
			If cValDifDesp < 0
				cValDifDesp :=cValDifDesp *-1
			Endif

			// Apenas Atualiza a despesa acessoria
		 	_cQryUpd	:= "BEGIN UPDATE "+RetSQLName("SE1")+" "
		  	_cQryUpd	+= "SET E1_VALOR=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + ", "
			// _cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + ", "	// Quando for adiantamento, é necessário baixar o título NF - TIENGO 2212
			IF iTotAdia > 0
				_cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp-iTotAdia))) + ", "
			Else
				_cQryUpd	+= "E1_SALDO=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + ", "	
			EndIf
		  	_cQryUpd	+= "E1_VLCRUZ=" + Ltrim(Rtrim(Str(nVlrParc+cValDifDesp))) + " "
			_cQryUpd	+= "WHERE E1_FILIAL='" + xFilial("SE1") + "' "
		  	_cQryUpd	+= "AND E1_CLIENTE='"+SF2->F2_CLIENTE+"' "
		  	_cQryUpd	+= "AND E1_LOJA='"+SF2->F2_LOJA+"' "
		  	_cQryUpd	+= "AND E1_PREFIXO='"+SF2->F2_SERIE+"' "  
		  	_cQryUpd	+= "AND E1_NUM='"+SF2->F2_DOC+"' "  
		  	_cQryUpd	+= "AND D_E_L_E_T_ <> '*'; COMMIT; END;"
			MEMOwrite('C:\temp\_cQryUpd4.txt', _cQryUpd)
		  	TCSqlExec(_cQryUpd)	

	Endif 
	aArea2	:= GetArea() 
  	// Grava numero de nota na SC6
	// BM TEC 28/05/20
	// Apenas abrir a tela nos casos de clientes que optem por emissão de boletos
	// E a condição for diferente de ?vista - a vista = pagamento antecipado
	//alert(EmiteBol)		//1 tem que ser 1 
	//alert(sCondVenda)		//018 tem que ser diferente de 001
	//alert(sCondAVista)	//001
	//	
	If (alltrim(EmiteBol)=="1" .AND. sCondVenda <> sCondAVista .AND. sGeraDupl='S')
		//alert('chamando boleto itau')
		if lEnvMail
  			U_BOLITAU()
		endIf
	ENDIF

	//SAMUEL SCHNEIDER - Gera arquivo CSV LOTES(SB8), caso cliente esteja setado para gerar - A1_CSVFAT == 1
	IF lGeraCSV
		dbSelectArea('SA1')
		dbSetOrder(1)
		if dbSeek(xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
			if SA1->A1_CSVFAT == '1'
				u_csvLotes()
			endIf
		endIf
	ENDIF

  	RestArea(aArea2) 
	RestArea(aSC5)
	RestArea(aArea)       

Return(NIL)
