#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APVT100.CH"


/*/{Protheus.doc} xSepZZ1
Separacao das etiquetas - CB0 (gera registros ZZ1) romaneio
@type function
@author Celso Rene
@since 26/05/2020
@version P12.1.25
/*/
User Function xSepZZ1()

	Local aTela
	Local  nOpcX
	Private nOpc
	Private _lUsaForn  := .F.  // Utiliza Fornecedor

	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf

	aTela := VtSave()
	VTCLear()

	IF Vtmodelo()=="RF"

		@ 0,0 VTSAY "Romaneio"
		@ 1,0 VTSay "Selecione:"
		nOpc:=VTaChoice(3,0,6,VTMaxCol(),{"Novo Romaneio","Alterar Romaneio.","Transferencia"}) //"Separacao romaneio

		//verifica se utiliza fornecedor
		If nOpc == 1
			VTCLear()
			@ 0,0 VTSAY "Romaneio"
			@ 1,0 VTSay "Selecione:"
			nOpcX := VTaChoice(3,0,6,VTMaxCol(),{"Normal","Para Beneficiamento"}) //"Separacao romaneio
			_lUsaForn := (nOpcX == 2 )
		Endif
	ENDIF

	VtRestore(,,,,aTela)

	//Executa rotina de romaneio via coletar de dados
	xEpedZZ1(nOpc)

Return()



/*/{Protheus.doc} xEpedZZ1
//Rotina para gerar registros romaneio
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xEpedZZ1(nOpc)

	//Local cComando	:= ""

	Local _lTransf 		:= .F.

	Private cEtiCB0 	:= Space(TamSx3("CB0_CODETI")[1])
	Private _nQuant		:= 0
	Private _cCodOpe	:= CBRetOpe()
	Private lPulaItem 	:= .F.
	Private _aItens		:= {}
	Private lSair		:= .F.
	Private _xProduto	:= Space(TamSX3("B1_COD")[1])
	Private _nQtdLida	:= 0 //Quantidade lida pelo coletor
	Private nRecnoCB0	:= 0
	Private _cExped     := Space(TamSx3("ZZ1_NEXPE")[1])
	Private _cLocdes    := Space(TamSx3("ZZ1_LOCDES")[1])
	Private _cCli       := Space(TamSx3("ZZ1_CLIENT")[1])
	Private _cLoja      := Space(TamSx3("ZZ1_LOJA")[1])
	//Private _cUsaForn := "N" //Pergunta se utiliza fornecedor

	Private _TipoPV		:= if(_lUsaForn,"B","N")
	Private cDocSD3  	:= Space(9)

	Private cLeitura    := Space(TamSx3("ZZ1_ETIQ")[1])
	Private _aTransf	:= {}

	Private _lSair		:= .F. //saida da rotina de leitura de etiquetas


	//Validacao Operador
	if (Empty(_cCodOpe))
		VTAlert("Operador nao cadastrado","Aviso",3)
		Return()
	endif

	_aSave := VTSAVE()



//LEITURA DO DOCUMENTO
	VTClear()
	if (VTModelo()=="RF" .or. lVT100B) .and. nOpc == 1

		@ 0,0 VTSAY "Romaneio"
		If _lUsaForn
			@ 2,0 VtSay "Informe Fornecedor e Loja"
		Else
			@ 2,0 VtSay "Informe Cliente e Loja"
		Endif
		@ 3,0 VtGet _ccli pict  '@!'  F3 if(_lUsaForn,"SA2","SA1") Valid xVldCli(1,_ccli,_lUsaForn)  When Empty(_ccli)
		@ 4,0 VtGet _cLoja pict '@!' Valid xVldCli(2,_cLoja,_lUsaForn) When Empty(_cLoja)

	elseif (VTModelo()=="RF" .or. lVT100B) .and. nOpc == 2
		@ 0,0 VTSAY "romaneio"
		@ 3,0 VtSay "Informe o Num. Exped."
		@ 4,0 VtGet _cExped pict '@!' Valid xVldExp(_cExped) F3 "ZZ1" When Empty(_cExped)
	elseif (VTModelo()=="RF" .or. lVT100B) .and. nOpc == 3
		@ 0,0 VTSAY "Exped. Transf."
		@ 3,0 VtSay "Local Destino"
		@ 4,0 VtGet _cLocdes pict '@!' Valid xVldLocdes(_cLocdes) F3 "NNR" When Empty(_cLocdes)
	endif
	VTREAD
	VtRestore(,,,,_aSave)

	if (VTLastKey() == 27)
		VTAlert("Processo Abortado","Aviso")
		Return()
	endif

	VtRestore(,,,,_aSave)
	VTClear()

	Begin Transaction

		//novo numero romaneio
		if (nOpc == 1)
			_cExped := xNovoNum(_cExped)
		elseif (nOpc == 2)
			dbSelectArea("ZZ1")
			dbSetOrder(1)
			dbSeek(xFilial("ZZ1") + _cExped)
			if (Found())
				_ccli   := ZZ1->ZZ1_CLIENT
				_cLoja  := ZZ1->ZZ1_LOJA
				_TipoPV := ZZ1->ZZ1_TPPV
			endif
		elseif (nOpc == 3)
			_cExped := xNovoNum(_cExped)
			cDocSD3  := u_MyGetSX8Num("SD3","D3_DOC",/*nOrder*/,/*lLicense*/,"ISNUMERIC(SUBSTRING(D3_DOC,1,1)) = 1") //GetSxeNum("SD3","D3_DOC") // u_MyGetSX8Num(cAlias,cCpoSX8,[nOrder],[lLicense],[cFiltro])
		endif


		//Bloqueio do Registro na ZZ1 - Impede procedimento Manual
		xBlqColet(_cExped)
		Do While .T.

			//Faz leitura da Etiqueta de produto -- Posiciona na CB0 e valida etiqueta
			lLeitura := ConfZZ1()

			if (VTLastKey() == 27 .or. _lSair)
				if (VtYesNo("Deseja sair?","Atencao",.T.))
					Exit
					//Return(.F.)
				else
					Loop
				endif

			else
				if (lLeitura)
					xGravaZZ1(cLeitura)
				endif
				//xConfere()
				//else
				//Exit
			endif

		EndDo

		if (nOpc == 3 .and. Len(_aTransf) > 0)
			if (MsgYesNo("Gerar transf. ?","Tranferencia?"))
				_lTransf := xTransZZ1(_aTransf)
				if (!_lTransf)
					DisarmTransaction()
				endif
			else
				DisarmTransaction()
			endif
		endif
		xLibColet(_cExped)
	End Transaction


Return()


/*/{Protheus.doc} xVldCli
//Rotina para validar cliente e loja - para a nova romaneio
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xVldCli(_nCliLoj,_cValid,_lUsaForn)

	Local _lRet := .F.

	if (Empty(_cValid))
		if (TerProtocolo() # "PROTHEUS")
			if (IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B ))
				VTKeyBoard(chr(23))
			endif
		endif
		Return .f.
	endif

	if (TerProtocolo() # "PROTHEUS")
		if IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VtClearBuffer()
		else
			TercBuffer()
		endif
	endif

	iF _lUsaForn
		if (_nCliLoj == 1)
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2") + _cValid  )
			if (Found())
				_lRet := .T.
			else
				VTAlert("Fornecedor nao localizado!","Aviso")
			endif
		else
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2") + _ccli + _cValid )
			if (Found())
				_lRet := .T.
			else
				VTAlert("Fornecedor nao localizado!","Aviso")
			endif
		endif

	Else
		if (_nCliLoj == 1)
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + _cValid  )
			if (Found())
				_lRet := .T.
			else
				VTAlert("Cliente nao localizado!","Aviso")
			endif
		else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + _ccli + _cValid )
			if (Found())
				_lRet := .T.
			else
				VTAlert("Cliente nao localizado!","Aviso")
			endif
		endif
	Endif

Return(_lRet)


/*/{Protheus.doc} xVldExp
//validacao numero romaneio informado para alteracao
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xVldExp(_cExped)

	Local _lRet     := .F.
//Local _aArea    := GetArea()

	if (Empty(_cExped))
		if (TerProtocolo() # "PROTHEUS")
			if (IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B ))
				VTKeyBoard(chr(23))
			endif
		endif
		Return .f.
	endif

	if (TerProtocolo() # "PROTHEUS")
		if (IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B))
			VtClearBuffer()
		else
			TercBuffer()
		endif
	endif

	dbSelectArea("ZZ1")
	dbSetOrder(1)
	dbSeek(xFilial("ZZ1") + _cExped)
	if (Found() .and. Empty(ZZ1->ZZ1_PEDVEN) .and. Empty(ZZ1->ZZ1_DOCSD3) .and. Empty(ZZ1->ZZ1_COLET) )
		_lRet     := .T.
	else
		VTAlert("Romaneio nao encontrado!","Aviso")
	endif

	//verificando se romaneio esta em uso
	if (_lRet .and. !Empty(ZZ1->ZZ1_COLET))
		VTAlert("Romaneio em uso coletor!","Aviso")
	endif


//RestArea(_aArea)

Return(_lRet)



/*/{Protheus.doc} xVldLocdes
//validacao local destino tranferencia
@author Celso Rene
@since 24/02/2021
@version 1.0
@type function
/*/
Static Function xVldLocdes(_xLocdes)

	Local _lRet := .F.

	if (Empty(_xLocdes))
		if (TerProtocolo() # "PROTHEUS")
			if (IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B ))
				VTKeyBoard(chr(23))
			endif
		endif
		Return .f.
	endif

	if (TerProtocolo() # "PROTHEUS")
		if IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VtClearBuffer()
		else
			TercBuffer()
		endif
	endif

	dbSelectArea("NNR")
	dbSetOrder(1)
	dbSeek(xFilial("NNR") + _xLocdes) //NNR_FILIAL+NNR_CODIGO
	if (Found())
		_lRet := .T.
	else
		VTAlert("Armazem nao localizado!","Aviso")
	endif

Return(_lRet)


/*/{Protheus.doc} ConfZZ1
//Funcao que faz a leitura da Etiqueta 
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function ConfZZ1()

	Local _lRet     := .F.

	cLeitura        := Space(TamSx3("ZZ1_ETIQ")[1])

	_aSave := VTSAVE()

	//LEITURA DO DOCUMENTO
	VTClear()

	if (nOpc <> 3)
		@ 0,0 VTSAY "Romaneio " + _cExped
		@ 3,0 VtSay "Etiqueta I.D."
		@ 4,0 VtGet cLeitura pict '@!' Valid xVldEtiq(cLeitura)
	else
		@ 0,0 VTSAY "Transf. " +cDocSD3 //_cExped
		@ 3,0 VtSay "Etiqueta I.D."
		@ 4,0 VtGet cLeitura pict '@!' Valid xVldEtiqT(cLeitura)
	endif

	VTREAD
	VtRestore(,,,,_aSave)

	if (VTLastKey() == 27)
		//VTAlert("Aguarde, saindo","Aviso",.T.,2500)
		//xLibColet(_cExped)
		_lSair := .T.
		Return(.F.)
	else
		_lRet := .T.
	endif

	VtRestore(,,,,_aSave)
	VTClear()

Return(_lRet)


/*/{Protheus.doc} xVldEtiq
//Funcao que valida a leitura da etiqueta
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xVldEtiq(cLeitura)

	Local _lRet    := .T.
	Local _cQryzz1 := ""

	dbSelectArea("CB0")
	dbSetOrder(1)
	dbSeek(xFilial("CB0") + cLeitura)
	if (Found())
		_cQryzz1 := " SELECT ZZ1_NEXPE , ZZ1_CLIENT , ZZ1_LOJA, ZZ1_PROD , ZZ1_LOCAL , ZZ1_ETIQ  " + chr(13)
		_cQryzz1 += " FROM " + RetSqlName("ZZ1") + " WHERE ZZ1_ETIQ = '" + cLeitura + "' AND D_E_L_E_T_ = '' AND ZZ1_PEDVEN = '' AND ZZ1_LOCDES = '' "
		if (Select( "TZZ1" ) <> 0)
			TZZ1->( dbCloseArea() )
		endif
		TcQuery _cQryzz1 New Alias "TZZ1"
		if (!TZZ1->(EOF()))
			_lRet 	:= .F.
			VTAlert("Etiq. na exped." + TZZ1->ZZ1_NEXPE+"!" ,"Aviso")
			cLeitura        := Space(TamSx3("ZZ1_ETIQ")[1])
		endif
		TZZ1->(dbCloseArea())
	else
		_lRet 	:= .F.
		VTAlert("Nao encontrada etiqueta!","Aviso")
		cLeitura        := Space(TamSx3("ZZ1_ETIQ")[1])
	endif


Return(_lRet)


/*/{Protheus.doc} xConfere
//Funcao que confere opcao do operador
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
/*Static Function xConfere()

	Private lSaida := .F.

	_aSave := VTSAVE()

	While .T.

		if lSaida
			exit
		endif

		If	VTLastKey() == 27

			if (VtYesNo("Deseja sair?","Atencao",.T.))
				xLibColet(_cExped)
				Return(.F.)
			else
				Loop
			endif
		else

			lSaida := .T.

			xGravaZZ1()


		endif

	EndDo


Return()*/


/*/{Protheus.doc} xNovoNum
//Busca nova numeracao valida para a romaneio - ZZ1_NEXPE
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xNovoNum(_cExped)

	if (Empty( _cExped ))
		_cExped:= u_MyGetSX8Num("ZZ1","ZZ1_NEXPE") //GetSXENum("ZZ1","ZZ1_NEXPE")
		do while ZZ1->( DbSeek( xFilial( "ZZ1" ) +_cExped) )
			ConfirmSX8()
			_cExped:= u_MyGetSX8Num("ZZ1","ZZ1_NEXPE") //GetSXENum( "ZZ1", "ZZ1_NEXPE" )
		enddo
		ConfirmSX8()
	endif


Return(_cExped)


/*/{Protheus.doc} xLibColet
//Libera coletor - ZZ1_COLET = ""
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xLibColet(_cExped)

	dbSelectArea("ZZ1")
	dbSetOrder(1)
	dbSeek(xFilial("ZZ1") + _cExped )
	if (Found())
		do While !ZZ1->(EOF()) .and. ZZ1->ZZ1_NEXPE ==_cExped
			RecLock("ZZ1",.F.)
			ZZ1->ZZ1_COLET := ""
			ZZ1->(MsUnlock())
			ZZ1->(dbSkip())
		end Do
	endif


Return()


/*/{Protheus.doc} xBlqColet
//Libera coletor - ZZ1_COLET = "C"
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xBlqColet(_cExped)

	dbSelectArea("ZZ1")
	dbSetOrder(1)
	dbSeek(xFilial("ZZ1") + _cExped )
	if (Found())
		do While !ZZ1->(EOF()) .and. ZZ1->ZZ1_NEXPE ==_cExped
			RecLock("ZZ1",.F.)
			ZZ1->ZZ1_COLET := "C"
			ZZ1->(MsUnlock())
			ZZ1->(dbSkip())
		end Do
	endif


Return()


/*/{Protheus.doc} xGravaZZ1
//gera registro ZZ1
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
Static Function xGravaZZ1(cLeitura)

	Local _QryIt := ""
	Local _cItem := "000"

	_QryIt := " SELECT ISNULL(MAX(ZZ1_ITEM),'000') AS XITEM"
	_QryIt += " FROM " + RetSqlName("ZZ1") + " WHERE ZZ1_NEXPE = '" + _cExped + "' AND D_E_L_E_T_ = '' AND ZZ1_PEDVEN = '' AND ZZ1_LOCDES = '' "
	if( Select( "TZZ1" ) <> 0 )
		TZZ1->( dbCloseArea() )
	endif
	TcQuery _QryIt New Alias "TZZ1"
	if (!TZZ1->(EOF()))
		_cItem := Soma1(TZZ1->XITEM)
	else
		_cItem := Soma1(_cItem)
	endif
	TZZ1->(dbCloseArea())

	dbSelectArea("CB0")
	dbSetOrder(1)
	dbSeek(xFilial("CB0") + cLeitura)

	dbSelectArea("ZZ1")
	RecLock("ZZ1",.T.)

	ZZ1->ZZ1_FILIAL     := xFilial("ZZ1")
	ZZ1->ZZ1_NEXPE      := _cExped
	ZZ1->ZZ1_DATA       := dDataBase
	ZZ1->ZZ1_CLIENT     := _cCli
	ZZ1->ZZ1_LOJA       := _cLoja
	ZZ1->ZZ1_TPPV		:= _TipoPV
	ZZ1->ZZ1_USER       := RetCodUsr()
	ZZ1->ZZ1_ITEM       := _cItem
	ZZ1->ZZ1_ETIQ       := CB0->CB0_CODETI
	ZZ1->ZZ1_PROD       := CB0->CB0_CODPRO
	ZZ1->ZZ1_LOCAL      := CB0->CB0_LOCAL
	ZZ1->ZZ1_QUANT      := CB0->CB0_QTDE
	ZZ1->ZZ1_OP         := CB0->CB0_OP

	if (nOpc == 3) //transferencia
		ZZ1->ZZ1_OBS        := "SEPARACAO TRANSFERENCIA - COLETOR DE DADOS"
		ZZ1->ZZ1_LOCDES		:= _cLocdes
		//ZZ1->ZZ1_DOCSD3		:= cDocSD3
	else
		ZZ1->ZZ1_OBS        := "SEPARACAO EXPEDICAO - COLETOR DE DADOS"
	endif

	ZZ1->ZZ1_COLET		:= "C"

	ZZ1->(MsUnlock())

	if (nOpc == 3)
		aAdd(_aTransf, { ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_ETIQ,ZZ1->ZZ1_ITEM,ZZ1->ZZ1_PROD,ZZ1->ZZ1_LOCAL,ZZ1->ZZ1_QUANT,ZZ1->(Recno())})
		if (!Empty(ZZ1->ZZ1_LOCDES))
			dbSelectArea("CB0")
			RecLock("CB0",.F.)
			CB0->CB0_LOCAL := ZZ1->ZZ1_LOCDES
			CB0->(MsUnlock())
		endif
	else
		//atualizar a etiqueta de I.D. CB0 - CB0_XNEXPE
		dbSelectArea("CB0")
		RecLock("CB0",.F.)
		CB0->CB0_XNEXPE	:= _cExped
		CB0->(MsUnlock())
	endif

Return()


/*/{Protheus.doc} xVldEtiqT
//Funcao que valida a leitura da etiqueta
@author Celso Rene
@since 24/02/2021
@version 1.0
@type function
/*/
Static Function xVldEtiqT(xTrans)

	Local _lRet    := .T.
	Local _cQryzz1 := ""

	dbSelectArea("CB0")
	dbSetOrder(1)
	dbSeek(xFilial("CB0") + cLeitura)
	if (Found())
		_cQryzz1 := " SELECT ZZ1_NEXPE , ZZ1_CLIENT , ZZ1_LOJA, ZZ1_PROD , ZZ1_LOCAL , ZZ1_ETIQ  " + chr(13)
		_cQryzz1 += " FROM " + RetSqlName("ZZ1") + " WHERE ZZ1_ETIQ = '" + cLeitura + "' AND D_E_L_E_T_ = '' AND ZZ1_PEDVEN = '' AND ZZ1_LOCDES = '' "
		if (Select( "TZZ1" ) <> 0)
			TZZ1->( dbCloseArea() )
		endif
		TcQuery _cQryzz1 New Alias "TZZ1"
		if (!TZZ1->(EOF()))
			_lRet 	:= .F.
			VTAlert("Etiq. na exped." + TZZ1->ZZ1_NEXPE+"!" ,"Aviso")
			cLeitura        := Space(TamSx3("ZZ1_ETIQ")[1])
		else
			if (_cLocdes == CB0->CB0_LOCAL)
				_lRet 	:= .F.
				VTAlert("Armaz. etiqueta igual ao destino!","Aviso")
				cLeitura        := Space(TamSx3("ZZ1_ETIQ")[1])
			endif
		endif
		TZZ1->(dbCloseArea())

	else
		_lRet 	:= .F.
		VTAlert("Nao encontrada etiqueta!","Aviso")
		cLeitura        := Space(TamSx3("ZZ1_ETIQ")[1])
	endif


Return(_lRet)



/*/{Protheus.doc} xTransZZ1
//Transferencia local - Mata261
@author Celso Rene
@since 24/02/2021
@version 1.0
@type function
/*/
Static Function xTransZZ1(xTrans)

	Local _lRet 	:= .F.
	Local _aAuto 	:= {}
	Local _aItem 	:= {}
	Local _aLinha	:= {}
	Local _aAreaT	:= GetArea()
	//Local _cDocum	:= Space(9)
	Local nx 		:= 0
	Local nOpcAuto  := 0
	//Local lContinua := .T.
	Local ny		:= 0
	Local _cItem	:= "000"

	Local aTranSD3	:= {}

	Private lMsErroAuto := .F.

	xTrans := aSort(xTrans,,,{|x,y| x[4]<y[4]})
	_cPodAnt  := xTrans[1][4]
	_nQtdProd := 0
	for nx :=1 to Len(xTrans)
		if (_cPodAnt <> xTrans[nx][4])
			aAdd(aTranSD3, { xTrans[nx-1][1] , "" , "" , _cPodAnt , xTrans[nx-1][5] , _nQtdProd , 0})
			_nQtdProd := 0
		endif

		_cPodAnt  := xTrans[nx][4]
		_nQtdProd += xTrans[nx][6]

	next nx

	aAdd(aTranSD3, { xTrans[Len(xTrans)][1] , "" , "" , _cPodAnt , xTrans[Len(xTrans)][5] , _nQtdProd, 0})


	//Cabecalho a Incluir
	//_cDocum := GetSxeNum("SD3","D3_DOC")
	aadd(_aAuto,{cDocSD3,dDataBase}) //Cabecalho

	//Itens a Incluir
	_aItem := {}

	//ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_ETIQ,ZZ1->ZZ1_ITEM,ZZ1->ZZ1_PROD,ZZ1->ZZ1_LOCAL,ZZ1->ZZ1_QUANT,RECNO

	for nx:= 1 to Len(aTranSD3)

		_aLista := {aTranSD3[nx][4],aTranSD3[nx][4]}

		for ny := 1 to len(_aLista) step 2
			_aLinha := {}

			//cria local SB2 caso nao exista o mesmo para o produto
			dbSelectArea("SB2")
			dbSetOrder(1)
			if (!dbSeek(xFilial("SB2")+ xTrans[nx][4] + _cLocDes))
				if (MsgYesNo("Deseja criar saldo armazém " +_cLocDes + " para esse produto " + Alltrim(xTrans[nx][4]) +" ? - 'O Armazem informado como destino não existe para este produto' !","# Armazém"))
					CriaSB2(xTrans[nx][4]	,_cLocDes)
				endif
			endif

			//Origem
			if (ny == 1)
				_cItem := Soma1(_cItem)
			endif
			SB1->(DbSeek(xFilial("SB1")+PadR(_aLista[ny], tamsx3('D3_COD') [1])))
			aadd(_aLinha,{"ITEM"			, _cItem				, Nil})
			aadd(_aLinha,{"D3_COD"			, aTranSD3[nx][4]		, Nil}) //Cod Produto origem
			aadd(_aLinha,{"D3_DESCRI"		, SB1->B1_DESC			, Nil}) //descr produto origem
			aadd(_aLinha,{"D3_UM"			, SB1->B1_UM			, Nil}) //unidade medida origem
			aadd(_aLinha,{"D3_LOCAL"		, aTranSD3[nx][5]		, Nil}) //armazem origem
			aadd(_aLinha,{"D3_LOCALIZ"		, ""					, Nil}) //Informar endereco origem

			//Destino
			SB1->(DbSeek(xFilial("SB1")+PadR(_aLista[ny+1], tamsx3('D3_COD') [1])))
			aadd(_aLinha,{"D3_COD"			, aTranSD3[nx][4]		, Nil}) //cod produto destino
			aadd(_aLinha,{"D3_DESCRI"		, SB1->B1_DESC			, Nil}) //descr produto destino
			aadd(_aLinha,{"D3_UM"			, SB1->B1_UM			, Nil}) //unidade medida destino
			aadd(_aLinha,{"D3_LOCAL"		, _cLocDes				, Nil}) //armazem destino
			aadd(_aLinha,{"D3_LOCALIZ"		, "" 					, Nil}) //Informar endereco destino

			aadd(_aLinha,{"D3_NUMSERI"		, ""					, Nil}) //Numero serie
			aadd(_aLinha,{"D3_LOTECTL"		, ""					, Nil}) //Lote Origem
			aadd(_aLinha,{"D3_NUMLOTE"		, ""					, Nil}) //sublote origem
			aadd(_aLinha,{"D3_DTVALID"		, ""					, Nil}) //data validade
			aadd(_aLinha,{"D3_POTENCI"		, 0						, Nil}) // Potencia
			aadd(_aLinha,{"D3_QUANT"		, aTranSD3[nx][6]		, Nil}) //Quantidade
			aadd(_aLinha,{"D3_QTSEGUM"		, 0						, Nil}) //Seg unidade medida
			aadd(_aLinha,{"D3_ESTORNO"		, ""					, Nil}) //Estorno
			aadd(_aLinha,{"D3_NUMSEQ"		, ""					, Nil}) // Numero sequencia D3_NUMSEQ

			aadd(_aLinha,{"D3_LOTECTL"		, ""					, Nil}) //Lote destino
			aadd(_aLinha,{"D3_NUMLOTE"		, ""					, Nil}) //sublote destino
			aadd(_aLinha,{"D3_DTVALID"		, ""					, Nil}) //validade lote destino
			aadd(_aLinha,{"D3_ITEMGRD"		, ""					, Nil}) //Item Grade

			aAdd(_aLinha,{"D3_OBSERVA"		, "Romaneio: " + _cExped    , Nil})	//D3_OBSERVA            "Exped " + cCodigo + " - " + xTrans[nx][2]         , Nil}

			//aadd(_aLinha,{"D3_CODLAN"		, ""					, Nil}) //cat83 prod origem
			//aadd(_aLinha,{"D3_CODLAN"		, ""					, Nil}) //cat83 prod destino

			aAdd(_aAuto,_aLinha)

		next ny

	next nx

	lMsErroAuto := .F.

	nOpcAuto := 3 // Inclusao
	VTMsg("Transferindo...") //'Aguarde...'
	MSExecAuto({|x,y| mata261(x,y)},_aAuto,nOpcAuto)

	if lMsErroAuto
		VTAlert("Falha Transf. - gerar novamente","Aviso")
		VTDispFile(NomeAutoLog(),.t.)
		//MostraErro()
		_lRet := .F.
	else
		VTAlert("Doc. "+cDocSD3,"Transf. Gerada")
		_lRet:= .T.

		//atualizando o campo pedido de venda dos itens da romaneio - processo exclusado registro P.V.
		//_cUpdtZZ1 := " UPDATE " + RetSqlName("ZZ1") + " WITH (NOLOCK) SET ZZ1_DOCSD3 = '" + _cDocum + "'  WHERE D_E_L_E_T_ = '' AND ZZ1_NEXPE = '" + cCodigo + "' "
		//TcSqlExec(_cUpdtZZ1)
		dbSelectArea("ZZ1")
		dbSetOrder(1) //ZZ1_FILIAL + ZZ1_NEXPE
		dbSeek(xFilial("ZZ1") + _cExped)
		Do While !ZZ1->(EOF()) .and. ZZ1->ZZ1_NEXPE == _cExped
			RecLock("ZZ1",.F.)
			ZZ1->ZZ1_DOCSD3 := cDocSD3 //_cDocum
			ZZ1->(MsUnlock())
			ZZ1->(dbSkip())
		EndDo

	EndIf


	RestArea(_aAreaT)


Return(_lRet)

