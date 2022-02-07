#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ\ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT130WF   บAutor  ณJose Vergani        บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGERAR AS COTAวีES POR E-MAIL PARA OS FORNECEDORES           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exclusivo para clientes Microsiga Serra Gaucha             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT130WF( nOpcao, oProcess )
Local aArea	:= GetArea()

Local aSend := {}

If ValType(nOpcao) = "A"
	nOpcao := nOpcao[1]
Endif

If nOpcao == NIL
	nOpcao := 0
End

ConOut("Opcao:")
ConOut(nOpcao)

If oProcess == NIL
	oProcess := TWFProcess():New( "COTACAO", "COTACAO DE COMPRAS" )
End

//aadd(aSend, PARAMIXB[1])

Do Case
	Case nOpcao == 0
		//U_COTIniciar( aSend, oProcess )
		U_COTIniciar( PARAMIXB[2], oProcess )
	Case nOpcao == 1
		U_COTRetorno( oProcess )
	Case nOpcao == 2
		U_COTTimeOut( oProcess )
EndCase

OProcess:Free()

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT130WF   บAutor  ณMicrosiga           บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COTIniciar( _aDados, oProcess )

//Local	_aDados	:=	Paramixb
Local	_aArea	   :=	GetArea()
Local	_aArSc8	   :=	SC8 -> ( GetArea() )
Local	_nLinha	   :=	0
Local	_xFornece  :=	""
Local	_xEmail	   :=	""
Local  _cCAbec     :=  SPACE(250)
Local	_bEnvia    := .f.
Local _nDtCotVal   := VAL(ALltrim(fBuscaCpo("SX1", 1, "MTA130    "+"04", "X1_CNT01"))) // NUMERO DE DIAS DE VALIDADE DA COTACAO

Local cIp := GetMv("MV_ENDIPWF") //http://192.168.0.250 // 189.10.195.114
Local nPorta       := 9091 //8091 base teste

Local cQry := ""
Local aCondPg := {}

Local cNomeEmp := Alltrim(SM0->M0_NOMECOM)  
Local cEndEmp :=  Alltrim(SM0->M0_ENDCOB) + " - " +Alltrim(SM0->M0_CIDCOB) +"/"+ Alltrim(SM0->M0_ESTCOB)

Local cEmp := "emp" + SM0->M0_CODIGO

For _nLinha := 1 to Len( _aDados )
	_xFornece := ""
	DbSelectArea("SC8")
	DbSetOrder(1)
	DbSeek(xFilial("SC8")+_aDados[_nLinha])
	//BUSCA AS COTACOES GERADAS
	While !Eof() .and. (SC8->C8_FILIAL+SC8->C8_NUM == xFilial("SC8")+_aDados[_nLinha])
		If !Empty(SC8->C8_NUMPED)
			MsgInfo( "Esta cota็ใo para o produto '" + AllTrim(SC8->C8_PRODUTO) + "' jแ estแ encerrada." )
			DbSelectArea("SC8")
			DbSkip()
			Loop
		Endif
		//CONTROLA O ENVIO POR FORNECEDOR
		If _xFornece <> SC8->C8_FORNECE
			_xFornece := SC8->C8_FORNECE
			_xEmail   := AllTrim(FBUSCACPO("SA2",1,xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA,"A2_EMAIL"))+SPACE(50)
			//MANDA E-MAIL APENAS PARA OS QUE POSSUI EMAIL NO CADASTRO - A2_EMAIL -
			DbSelectArea("SC8")
			
			//ENVIA E-MAIL APOS CONFIRMACAO DO USUARIO
			_aTela	:=	_TlForn( FBUSCACPO("SA2",1,xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA,"A2_NOME"), _aDados[_nLinha], _xEmail, Space(65), _cCAbec )
			If _aTela[1,1]
				_bEnvia := .t.
				oProcess := TWFProcess():New( "COTACAO", "COTACAO DE COMPRAS" )
				oProcess:NewTask( "COTACAO DE COMPRAS", "\workflow\htm\GERACOT.HTM" )
				oProcess:bReturn := "U_MT130WF(1)"
				oProcess:bTimeOut := {{"U_MT130WF(2)",30, 0, 5 }}
				oProcess:cSubject := "Cotacao de Precos - " + Alltrim(SM0->M0_NOME)
				oHTML := oProcess:oHTML
				
				oHtml:ValByName( "cNomeEmp", cNomeEmp )
			    oHtml:ValByName( "cEndEmp" , cEndEmp )
				
				oHtml:ValByName( "xCotacao"   , _aDados[_nLinha] )
				oHtml:ValByName( "Solicitante"   , Alltrim(UsrRetName(__CUSERID)) )
				oHtml:ValByName( "emissao"    , DTOC(DATE()) )
				
				// Condicoes de pagamento - Query com aquelas setadas E4_WFCOTCP
				oHtml:ValByName( "cd_pgto"    , iif(!Empty(SC8->C8_COND),SC8->C8_COND,"001") )
				
				cQry := " SELECT E4_CODIGO, E4_DESCRI "
				cQry += " FROM " + RetSQLName("SE4") + " SE4 "
				cQry += " WHERE SE4.D_E_L_E_T_ = '' "
				cQry += " AND E4_FILIAL = '" + xFilial("SE4") + "'"
				cQry += " AND E4_WFCOTCP = 'T'"  
				cQry += " ORDER BY E4_CODIGO "
								
				TCQUERY cQry NEW ALIAS "TRB1"
				dbSelectArea("TRB1")
				
				//Preencho as op็๕es do html
				nCont := 1
				While ! EOF() //For i := 1 To Len(aCondPg)					
					oHtml:ValByName(  "codpg"+cValToChar(nCont)  , Alltrim(TRB1->E4_CODIGO) )
					oHtml:ValByName( "classe"+cValToChar(nCont) , "show" )
					oHtml:ValByName( "descpg"+cValToChar(nCont) , Alltrim(TRB1->E4_CODIGO) + " - " + Alltrim( TRB1->E4_DESCRI) )
					nCont ++
					dbSelectArea("TRB1")
					dbSkip()
				EndDo
				// Preencho os itens do html que sobraram : 20 = itens disponiveis no html
				For i := nCont To 20 
					oHtml:ValByName( "codpg"+cValToChar(i) , "001" )
					oHtml:ValByName( "classe"+cValToChar(i) , "hide" )
					oHtml:ValByName( "descpg"+cValToChar(i) , "-" )
				Next
				dbSelectArea("TRB1")
				dbCloseArea()

				oHtml:ValByName( "cd_pgto"    , iif(!Empty(SC8->C8_COND),SC8->C8_COND,"001") )
				oHtml:ValByName( "tp_frete"   , iif(!Empty(SC8->C8_COND),SC8->C8_COND,"001") )
				oHtml:ValByName( "DtRet"       , DTOC(DATE()+_nDtCotVal))
				//DADOS DO FORNECEDOR
				DbSelectArea( "SA2" )
				DbSetOrder(1)
				DbSeek( xFilial("SA2") + SC8->C8_FORNECE + SC8->C8_LOJA )
				If Found()
					oHtml:ValByName( "Forn",	      SC8->C8_FORNECE )
					oHtml:ValByName( "FornLoja",		SC8->C8_LOJA)
					oHtml:ValByName( "NomeFor", 		SA2->A2_NOME)
				Endif
			Else
				_bEnvia	:=	.f.
			Endif
			//Endif
		Endif
		If _bEnvia
			DbSelectArea("SC8")
			AAdd( (oHtml:ValByName( "t1.1" )),	SC8->C8_ITEM )
			AAdd( (oHtml:ValByName( "t1.2" )),	AllTrim(SC8->C8_PRODUTO) )
			AAdd( (oHtml:ValByName( "t1.3" )),	Alltrim(FBUSCACPO("SB1",1,XFILIAL("SB1")+SC8->C8_PRODUTO,"B1_DESC")) )
			AAdd( (oHtml:ValByName( "t1.4" )), 	SC8->C8_UM )
			AAdd( (oHtml:ValByName( "t1.5" )),	AllTrim(TRANSFORM(SC8->C8_QUANT,"@E 9,999,999.99")) )
			AAdd( (oHtml:ValByName( "t1.preco" )), '' ) // Round(SC8->C8_PRECO,2) )
			AAdd( (oHtml:ValByName( "t1.6" )),	   '' ) // Round(SC8->C8_IPICOT,2) )
			AAdd( (oHtml:ValByName( "t1.7" )),	   '' ) // Round(SC8->C8_STCOT,2) )
			AAdd( (oHtml:ValByName( "t1.prazo" )), '' ) // DTOC(SC8->C8_DATPRF) )
			AAdd( (oHtml:ValByName( "t1.obs")),		AllTrim(SC8->C8_OBS) )
		Endif
		DbSelectArea("SC8")
		DbSkip()
			
		If (_xFornece <> SC8->C8_FORNECE) .Or. SC8->(EOF())
			If _bEnvia
				Conout(_aTela[_nLinha,3])
								
				oProcess:cTo := "wf\cotacao"
				cMailID := oProcess:Start()								
				//-- ENVIO PARA USUARIO
			    cHtml := "\workflow\htm\WFLINK.htm"      
			    oProcess:NewTask( "Cota็ใo de Compras", cHtml )
			    oProcess:cSubject := "Cotacao de Pre็os - " + Alltrim(SM0->M0_NOME)
			    //oProcess:cTo := cEmail
			    oProcess:ohtml:ValByName( "referente","Cota็ใo de Pre็os." )
			    
			    oProcess:ohtml:ValByName( "cNomeEmp", cNomeEmp )
			    oProcess:ohtml:ValByName( "cEndEmp" , cEndEmp )
			    
			    oProcess:oHTML:ValByName( "proc_link", cIp + ":" + cValToChar( nPorta ) + "/wf/messenger/"+cEmp+"/wf/cotacao/" + cMailID + ".htm" )				
				oProcess:cTo := _aTela[_nLinha,2]
				
				If !Empty(_aTela[_nLinha,3])
					oProcess:cCC := _aTela[_nLinha,3]
				EndIf
				oProcess:Start()	
			Endif			
			_bEnvia := .f.
		Endif		
	Enddo
Next

RestArea( _aArSc8 )
RestArea( _aArea )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT130WF   บAutor  ณMicrosiga           บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COTTimeOut( oProcess )
ConOut("Funcao de TIMEOUT executada")
oProcess:Finish()  //Finalizo o Processo
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT130WF   บAutor  ณMicrosiga           บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a Libera็ใo Automแtica do Pedido                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COTRetorno( oProcess )

Local	_cCotacao	:=	oProcess:oHtml:RetByName('xCotacao')
Local	_cFornece	:=	oProcess:oHtml:RetByName('Forn')
Local	_cLoja		:=	oProcess:oHtml:RetByName('FornLoja')
Local	_cCondicao	:=	oProcess:oHtml:RetByName('Cd_pgto')
Local   _cTpFrete   :=  oProcess:oHtml:RetByName('Tp_frete')
Local	_cFilial	:=	oProcess:oHtml:RetByName('WFFILIAL')
Local	_aItens		:=	oProcess:oHtml:RetByName('T1.1')
Local	_aPrecos    :=	oProcess:oHtml:RetByName('T1.preco')
Local	_aEntrega	:=	oProcess:oHtml:RetByName('T1.prazo')
Local	_aObserv    :=	oProcess:oHtml:RetByName('T1.obs')

Local _aIpi			:= oProcess:oHtml:RetByName('T1.6')
Local _aST 			:= oProcess:oHtml:RetByName('T1.7')

Local _Solict := oProcess:oHtml:RetByName('Solicitante') //!Solicitante!
Local _DtRet := oProcess:oHtml:RetByName('DtRet') //!DtRet!
Local _Cd_Pgto := oProcess:oHtml:RetByName('cd_pgto') //!cd_pgto!

Local	_aArea	    :=	GetArea()
Local	_aArSc8	    :=	SC8 -> ( GetArea() )
Local	_cQuery	    :=	""
Local	_nLinha	    :=	1
Local  _dData       := ddatabase
Local  _nValPrc     := 0
Local  nPrzDias     := 0

ConOut('-------Executando Retorno de Cota็ใo de Compra "'+_cFilial+" - "+_cCotacao+'" do Fornecedor "'+_cFornece+"/"+_cLoja+'"...')

For _nLinha	:= 1 to Len( _aItens )
	
	DbSelectArea("SC8")
	DbSetOrder(1)
	DbSeek(xFilial("SC8")+_cCotacao+_cFornece+_cLoja+_aItens[_nLinha],.T.)
	Do While !Eof() .And. SC8->C8_NUM == _cCotacao .And. SC8->C8_FORNECE == _cFornece ;
		.And. SC8->C8_LOJA == _cLoja .And. SC8->C8_ITEM == _aItens[_nLinha]
		
		RecLock("SC8",.F.)
		
		SC8->C8_MOEDA   := 1
		SC8->C8_COND    := _cCondicao
		SC8->C8_TPFRETE := _cTpFrete		
		REPLACE SC8->C8_OBS WITH _aObserv[_nLinha]
		
		_cData := ""
		//Tratamento para formato de data: Chrome retorna: 'yyyy-mm-dd', IE: 'dd/mm/yyyy'
		If SubStr(_aEntrega[_nLinha],5,1) == "-" // Chrome
			_cData := _aEntrega[_nLinha]
			_cData := SubStr(_cData,9,2) + "/" + SubStr(_cData,6,2) + "/" + SubStr(_cData,1,4)			 	
		Else // IE
			_cData := _aEntrega[_nLinha]
		EndIf
		
		_dData          := ctod(_cData)
		Conout("------Data: " + _cData) //chrome retorno: yyyy-mm-dd, ie: 26/09/2015
		
		// Alterado 24/09/2015 - O retorno  do campo prazo sera em dias
		nPrzDias := Val(StrTran(AllTrim(_aEntrega[_nLinha]), ',', '.'))
		SC8->C8_PRAZO   := nPrzDias  //  _dData - ddatabase
		//_nValPrc        := Val(AllTrim(_aPrecos[_nLinha]))
		_nValPrc        := Val(StrTran(AllTrim(_aPrecos[_nLinha]), ',', '.')) // Substitui ',' por '.' para conversao correta com VAL()
		
		SC8->C8_DATPRF   := _dData
		
		SC8->C8_IPICOT   := Val(StrTran(AllTrim(_aIpi[_nLinha]), ',', '.'))
		//		conout(_aIpi[_nLinha])
		SC8->C8_STCOT    := Val(StrTran(AllTrim(_aST[_nLinha]), ',', '.'))				
		
		SC8->C8_PRECO   := _nValPrc
		SC8->C8_TOTAL   := _nValPrc * SC8->C8_QUANT
		
		// Campo que armazena total da cota็ใo (Unit + IPI + ST) * Quant
		SC8->C8_STOTCOT := Round( (SC8->C8_PRECO + SC8->C8_IPICOT + SC8->C8_STCOT) * SC8->C8_QUANT, 2)
		
		MsUnlock("SC8")
		DbSelectArea("SC8")
		DbSkip()
	EndDo
Next

ConOut('Atualizada Cota็ใo de Compra "'+_cCotacao+'" do Fornecedor "'+_cFornece+"/"+_cLoja+'".')
//U_COTNotificar(_cFilial, _cCotacao, _cFornece, _cLoja )

//Frete
If _cTpFrete == "C"
	_cTpFrete := "CIF"
Else
	_cTpFrete := "FOB"
EndIf

U_COTNotificar(_cFilial, _cCotacao, _cFornece, _cLoja, _Solict, _DtRet, _Cd_Pgto, _cTpFrete)

RestArea( _aArSc8 )
RestArea( _aArea )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT130WF   บAutor  ณMicrosiga           บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COTNotificar(_cFilial, _cCotacao, _cFornece, _cLoja, _Solict, _DtRet, _Cd_Pgto, _Tp_Frete)

Local	oProcess
Local	_cQuery	:=	""
Local	_aArea	:=	GetArea()
Local	_bIniProc	:=	.f.
Local _cCodComp   := fBuscaCpo("SC1",1,xFilial("SC1")+_cCotacao,"C1_CODCOMP")

Local cNomeEmp := Alltrim(SM0->M0_NOMECOM)  
Local cEndEmp :=  Alltrim(SM0->M0_ENDCOB) + " - " +Alltrim(SM0->M0_CIDCOB) +"/"+ Alltrim(SM0->M0_ESTCOB)

Conout("Inicio processo de notifica็ใo da cotacao :"+ _cCotacao )

DbSelectArea("SC8")
DbSetOrder(1)
DbSeek(_cFilial+_cCotacao+_cFornece+_cLoja, .T.)
Do While !Eof() .And. SC8->C8_NUM == _cCotacao .And. SC8->C8_FORNECE == _cFornece ;
	.And. SC8->C8_LOJA == _cLoja
	If !_bIniProc
		_bIniProc	:=	.t.
		oProcess := TWFProcess():New( "COTNOT", "NOTIFICACAO DE COTACAO" )
		oProcess:NewTask( "COTACAO DE COMPRAS", "\workflow\Htm\COTNOT.HTM" )
		oProcess:cSubject := "Notificacao de Entrega de Cotacao de Compras "+_cCotacao+" - " + Alltrim(SM0->M0_NOME)
		oHTML :=oProcess:oHTML
		oHtml:ValByName( "xCotacao"   ,	_cCotacao )
		oHtml:ValByName( "emissao"   , DTOC(DATE()) )
		
		oHtml:ValByName( "cNomeEmp", cNomeEmp )
		oHtml:ValByName( "cEndEmp" , cEndEmp )
		
		//DADOS DO FORNECEDOR
		DbSelectArea( "SA2" )
		DbSetOrder(1)
		DbSeek( xFilial("SA2")+_cFornece+_cLoja )
		If Found()
			oHtml:ValByName( "Forn",	_cFornece )
			oHtml:ValByName( "FornLoja",		_cLoja)
			oHtml:ValByName( "Nome", 		SA2->A2_NOME)
		Endif
		
		_Cd_Pgto += " - " + Alltrim( Posicione("SE4",1,xFilial("SE4") + _Cd_Pgto, "E4_DESCRI") )
		
		oHtml:ValByName( "Solicitante",		_Solict)
		oHtml:ValByName( "cd_pgto",			_Cd_Pgto)
		oHtml:ValByName( "tp_frete",		_Tp_Frete)
		oHtml:ValByName( "DtRet",			_DtRet)		
		
		Conout( "Enviando Notifica็ใo de Cota็ใo de Compras: " + _cCotacao + "... " )
		//Conout(_Solict+" - "+ _DtRet +" - "+ _Cd_Pgto + " - "+ _Tp_Frete)
		
	Endif
	AAdd( (oHtml:ValByName( "t1.1" )),		SC8->C8_ITEM )
	AAdd( (oHtml:ValByName( "t1.2" )),		AllTrim(SC8->C8_PRODUTO) )
	AAdd( (oHtml:ValByName( "t1.3" )),		Alltrim(FBUSCACPO("SB1",1,XFILIAL("SB1")+SC8->C8_PRODUTO,"B1_DESC")) )
	AAdd( (oHtml:ValByName( "t1.4" )), 		SC8->C8_UM )
	AAdd( (oHtml:ValByName( "t1.5" )),		AllTrim(TRANSFORM(SC8->C8_QUANT,"@E 9,999,999.99")) )
	AAdd( (oHtml:ValByName( "t1.preco" )),	AllTrim(TRANSFORM(SC8->C8_PRECO,"@E 9,999,999.99")) )
	AAdd( (oHtml:ValByName( "t1.prazo" )),	cValToChar(SC8->C8_PRAZO)+SPACE(1)+"Dias" )
	AAdd( (oHtml:ValByName( "t1.obs")),		AllTrim(SC8->C8_OBS) )
	
	AAdd( (oHtml:ValByName( "t1.6" )), 		AllTrim(TRANSFORM(SC8->C8_IPICOT,"@E 99.99")) )
	AAdd( (oHtml:ValByName( "t1.7" )), 		AllTrim(TRANSFORM(SC8->C8_STCOT, "@E 999,999.99")) )
	
	DbSelectArea( "SC8" )
	DbSkip()
End

If _bIniProc
	oProcess:cTo := GETMV("ML_COMMAIL") // "bruno.fernando@totvs.com.br" //IIF(!EMPTY(_cCodComp),fBuscaCpo("SY1",1,xFilial("SY1")+_CCodComp,"Y1_EMAIL"), GETMV("ML_COMMAIL"))
	oProcess:Start()
	OProcess:Free()
	Conout( "Fim: Notifica็ใo de Cota็ใo de Compras: " + _cCotacao )
Endif

RestArea( _aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT130WF   บAutor  ณMicrosiga           บ Data ณ  12/15/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _TlForn( _cNome, _cCotacao, cEdit1, cEdit2, cMemo )

Local oEdit1
Local oEdit2
Local oMemo1

Local	_aDados	:=	{}
Local	_oDlg
Local	_oFont12N	:=	TFont():New("Courier New",10,16,,.t.,,,,.T.,.F.)
Local	_oNome

DEFINE MSDIALOG _oDlg TITLE "Cota็ใo Nฐ: " + _cCotacao FROM 258,420 TO 440,893 PIXEL
@ 008,010 Say "Fornecedor: "           			Size 053,008 PIXEL OF _oDlg
@ 008,065 Say _cNome FONT _oFont12N COLOR CLR_HRED PIXEL OF _oDlg
@ 020,010 Say "E-mail do Fornecedor:"           Size 053,008 PIXEL OF _oDlg
@ 020,065 MsGet oEdit1 Var cEdit1      			Size 150,009 PIXEL OF _oDlg
@ 032,010 Say "Enviar C๓pia para:"              Size 053,008 PIXEL OF _oDlg
@ 032,065 MsGet oEdit2 Var cEdit2				   Size 150,009 PIXEL OF _oDlg
//@ 045,010 Say "Mensagem Para Cabe็alho: "       Size 053,008 PIXEL OF _oDlg
//@ 045,065 GET oMemo1 Var cMemo MEMO             Size 150,029 PIXEL OF _oDlg
@ 076,131 Button "Enviar"                       Size 037,012 PIXEL OF _oDlg Action ( aadd( _aDados, { .t., cEdit1, cEdit2, cMemo } ) , _oDlg:End() )
@ 076,178 Button "Cancelar"                     Size 037,012 PIXEL OF _oDlg Action ( aadd( _aDados, { .f., "", "", "" } ) , _oDlg:End() )
ACTIVATE MSDIALOG _oDlg CENTERED

If Len(_aDados) = 0
	aadd( _aDados, { .f., "", "", "" } )
Endif

Return _aDados