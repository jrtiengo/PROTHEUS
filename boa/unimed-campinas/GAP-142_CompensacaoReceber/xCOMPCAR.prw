#Include "protheus.ch"
#INCLUDE "totvs.ch"
#Include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "COLORS.CH"

#Define Crlf   (chr(13)+chr(10))


/*/{Protheus.doc} Infa125
Rotina para compensacoes CAP (contas a pagar) x CAR (contas a receber) - importacao planilha PEDMKPs (E1_PEDMKP)
@type function
@version 1.0
@author Celso Rene
@since 28/05/2025
@return variant, return null
/*/
User Function Infa125()

	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oSay1
	Local oSay2
	Local oSay3

	Local cGet1 := Space(9) //cod. fornecedor
	Local cGet2 := Space(4) //loja
	Local dGet1 := dDataBase - 60 
	Local dGet2 := dDataBase

	Local oButBus
	Local oButImp
	Local oButProc
	Local oButCanc

	Private _oDlg
	Private oCheckBo1
	Private lCheckBo1
	Private oSay4
	Private oSay
	Private oOk      := LoadBitmap( GetResources(), "CHECKED" )
	Private oNo      := LoadBitmap( GetResources(), "UNCHECKED" )
	Private oLbx 	 := Nil
	Private cGet3 := space(70)
	Private _aVetor  := {}
	Private _aPedmkp := {}
	Private lMark    := .F.
	Private lChk	 := .F.
	Private cArqOri


	DEFINE MSDIALOG _oDlg TITLE "Compensações CAP x CAR: PEDMKPs" FROM 000, 000  TO 450, 650 COLORS 0, 16777215 PIXEL

	@ 010, 012 SAY oSay1 PROMPT "Cod. Fornecedor" SIZE 042, 008 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 010, 062 SAY oSay2 PROMPT "Loja" SIZE 025, 008 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 020, 012 MSGET oGet1 VAR cGet1 SIZE 047, 010 OF _oDlg COLORS 0, 16777215 PIXEL F3 "SA2" Valid( !Empty(cGet1) .and. ExistCPO( "SA2", cGet1, 1 ))
	@ 020, 062 MSGET oGet2 VAR cGet2 SIZE 022, 010 OF _oDlg COLORS 0, 16777215 PIXEL Valid(ExistCPO( "SA2", cGet1 + cGet2 , 1))

	@ 010, 100 SAY oSay3 PROMPT "Periodo" SIZE 023, 008 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 020, 100 MSGET oGet3 VAR dGet1 SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 020, 143 MSGET oGet4 VAR dGet2 SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 010, 250 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "anexo planilha" SIZE 045, 008 OF _oDlg COLORS 0, 16777215 PIXEL
	//oCheckBo1 := TCheckBox():New(010,235,"Planilha",bSETGET(lCheckBo1),_oDlg,100,210,,,,,,,,.T.)
	oCheckBo1:lReadOnly:= .T.

	@ 020, 190 BUTTON oButBus PROMPT "Buscar" SIZE 034, 010 OF _oDlg PIXEL Action(xBuscaCAP(cGet1, cGet2, dGet1, dGet2), lCheckBo1:= .F. ,oCheckBo1:Refresh(), cGet3:= space(70), oSay4:Refresh(), _oDlg:Refresh())
	@ 020, 250 BUTTON oButImp  PROMPT "Plan. PEDMKPs" SIZE 044, 010 OF _oDlg PIXEL Action (xImpPEDMKP(), oCheckBo1:Refresh(), oSay4:Refresh())
	@ 208, 010 BUTTON oButProc PROMPT "Processar" SIZE 037, 012 OF _oDlg PIXEL Action( FWMsgRun(,{|oSay| xProcFIN(cGet1 + cGet2, oSay) },"Processamento compensações","Aguarde ... ") )

	//detalhes totalizador planilha anexo - CAR: PEDMKPs
	@ 212, 060  SAY oSay4 PROMPT cGet3 SIZE 200, 008 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 208, 285 BUTTON oButCanc PROMPT "Sair" SIZE 037, 012 OF _oDlg PIXEL Action(_oDlg:End())

	//desabilitar saida pela tecla 'ESC'
	_oDlg:lEscClose := .F.


	ACTIVATE MSDIALOG _oDlg CENTERED


Return()


/*/{Protheus.doc} xBuscaCAP
busca CAP conforme filtros fornecedor e periodo
@type function
@version 1.0
@author Celso Rene
@since 28/05/2025
@param _cFor, variant, string
@param _cLoja, variant, string
@param _dDta1, variant, date
@param _dDta2, variant, date
@return variant, return null
/*/
Static Function xBuscaCAP(_cFor, _cLoja, _dDta1, _dDta2)

	Local _cQuery  := " "
	Local cAliaSE2 := GetNextAlias()

	_cQuery := " SELECT E2_PREFIXO, E2_NUM, E2_EMISSAO, E2_NOMFOR, E2_TIPO, E2_SALDO, E2_FORNECE, E2_LOJA , R_E_C_N_O_ RECSE2 FROM SE2010  WHERE E2_FILIAL = '  ' AND E2_EMISSAO BETWEEN  '"+ DtoS(_dDta1) +"' AND  '"+ DtoS(_dDta2) +"' AND E2_FORNECE = '" + _cFor +"' AND E2_LOJA = '" + _cLoja + "' AND E2_TIPO NOT IN ('RA','PA','NCC','NDF') AND E2_SALDO > 0 AND D_E_L_E_T_ = ' ' "

	//zerando itens - busca query
	_aVetor:= {}

	MPSysOpenQuery ( _cQuery , cAliaSE2 )
	DbSelectArea(cAliaSE2)
	Do While (cAliaSE2)->(!EOF())

		lMark := .F. //desmarcando todas as linhas do array
		Aadd( _aVetor,{ lMark,(cAliaSE2)->E2_PREFIXO, (cAliaSE2)->E2_NUM, DtoC(StoD((cAliaSE2)->E2_EMISSAO)),(cAliaSE2)->E2_NOMFOR,  (cAliaSE2)->E2_TIPO, (cAliaSE2)->E2_SALDO, (cAliaSE2)->RECSE2  })

		(cAliaSE2)->(dbSkip())
	EndDo
	(cAliaSE2)->(dbCloseArea())

	if Len(_aVetor) == 0
		Aadd( _aVetor,{ lMark, Space(3), Space(9), Space(10), Space(20), Space(3), 0, 0})
	endif
	@ 040,010 LISTBOX oLbx VAR cVar FIELDS HEADER  "", "Prefixo","Numero","Emissão","Nome fornecedor","Tipo","Saldo","Recno" ;
		SIZE 315,162 OF _oDlg PIXEL ON dblClick(_aVetor[oLbx:nAt,1] := !_aVetor[oLbx:nAt,1],oLbx:Refresh() , _aPedmkp := {}, lCheckBo1:= .F.,oCheckBo1:Refresh(), cGet3:= Space(70) ,oSay4:Refresh()  )

	oLbx:SetArray( _aVetor )
	oLbx:bLine := {|| {Iif(_aVetor[oLbx:nAt,1],oOk,oNo),_aVetor[oLbx:nAt,2],_aVetor[oLbx:nAt,3],_aVetor[oLbx:nAt,4],_aVetor[oLbx:nAt,5],_aVetor[oLbx:nAt,6],Transform(_aVetor[oLbx:nAt,7],PesqPict("SE2","E2_VALOR",10)), cValtoChar(_aVetor[oLbx:nAt,8])}}

	_oDlg:Refresh()


Return()


/*/{Protheus.doc} xImpPEDMKP
Rotina para importacao dos PEDMKPs para compesacoes do CAR
@type function
@version 1.0
@author Celso Rene
@since 30/05/2025
@return variant, return null
/*/
Static Function xImpPEDMKP()

	Local nTotLinhas := 0
	Local cLinAtu    := ""
	Local nLinhaAtu  := 0
	Local oArquivo
	Local aLinhas
	Local aLinha     := {}

	Local nRet		 := 0
	Local _nSaldMKP	 := 0
	Local _nx		 := 0
	Local _nMark	 := 0
	Local _nSel		 := 0

	//Local cDirLog    := GetTempPath()

	//verificando _avetor, selecoes validas - CAP: contas a pagar (1 registro)
	for _nx:= 1 to Len(_aVetor)
		if (_aVetor[_nx][1])
			_nMark++
			_nSel := _nx
		endif
	next _nx

	//selecao invalida ou processamento
	if (_nMark > 1 .or. _nMark == 0)
		MsgAlert("Selecionado(s) '0' (nenhum) ou mais de '1' (um) registro(s) para processamento das comensações (somente '1' (um) é permitido)!","# Seleção inválida!")
		Return()
	endif

	//zerando arrays do registros do contas a receber (SE1) que serao compensados
	_aPedmkp := {}
	_nSaldMKP:= 0
	lCheckBo1:= .F.
	cGet3:= space(70)

	//forcando gravacao C:\temp
	if (ExistDir("C:\temp") == .F.)
		nRet := MakeDir("C:\temp")
	endif

	//selecao do arquivo
	cArqOri := tFileDialog( "CSV files (*.csv) ", "Seleção do Arquivo '.csv' ", ,"C:\temp\" , .F., )


	//arquivo selecionado
	if (!Empty(cArqOri))

		oArquivo := FWFileReader():New(cArqOri)

		//se o arquivo pode ser aberto
		If (oArquivo:Open())

			//se nao for fim do arquivo
			If ! (oArquivo:EoF())

				//definindo o tamanho da regua
				aLinhas := oArquivo:GetAllLines()
				nTotLinhas := Len(aLinhas)
				ProcRegua(nTotLinhas)

				//metodo GoTop nao funciona (dependendo da versao da LIB), deve fechar e abrir novamente o arquivo
				oArquivo:Close()
				oArquivo := FWFileReader():New(cArqOri)
				oArquivo:Open()

				//enquanto tiver linhas
				While (oArquivo:HasLine())

					aLinha := {}

					//Incrementa na tela a mensagem
					nLinhaAtu++
					IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

					//pegando a linha atual e transformando em array
					cLinAtu := oArquivo:GetLine()

					cLinAtu :=Replace(cLinAtu,",",".")
					aLinha  := StrTokArr(cLinAtu, ";")

					//validando layout do arquivo
					if (Len(aLinha) <> 2)
						MsgAlert("Inválido layout do arquivo selecionado!", "Arquivo inválido")
						Return()
					endif

					//convertendo o saldo da linha (posicao 2): de string para numero
					aLinha[2]:= val(aLinha[2])

					//verificando se PEDMKP <> ' ' e saldo > 0
					if (!Empty(aLinha[1])  .and. aLinha[2] > 0)
						_cQrySE1 := " SELECT R_E_C_N_O_ RECSE1 FROM SE1010 WHERE E1_FILIAL = ' ' AND E1_TIPO IN ('NF','NFP','NDC') AND E1_SALDO >= " + cValtoChar(aLinha[2]) + " AND E1_PEDMKP = '" + Alltrim(aLinha[1]) + "' AND D_E_L_E_T_ = ' ' "
						if ( SELECT("TSE1") ) <>  0
							TSE1->(dbCloseArea())
						endif
						TcQuery _cQrySE1 Alias "TSE1" New
						//se encontrou o registro na SE1 com saldo (busca pelo PEDMKP)
						if (TSE1->(!EOF()))
							_nSaldMKP += aLinha[2]
							aadd(_aPedmkp, {aLinha[1], aLinha[2], TSE1->RECSE1})
							lCheckBo1:= .T.
						endif
						TSE1->(dbCloseArea())
					endif

				EndDo

				//fecha o arquivo
				oArquivo:Close()

			else
				MsgAlert("Arquivo não tem conteúdo!", "Arquivo inválido")
			endif

		endif

	else
		MsgStop("Não selecionado nenhum arquivo!", "Arquivo inválido")
	endif

	if (_nSaldMKP > _aVetor[_nSel][7])
		_aPedmkp:= {}
		MsgAlert("Soma dos saldos da planilha ultrapassam a soma do registo a compensar selecionado!","# Saldo menor a compensar")
	else
		if (Len(_aPedmkp) > 0)
			MsgInfo("Planilha anexada, " + cValtoChar(Len(_aPedmkp)) + " registros, saldo a compensar de R$ " + Transform(_nSaldMKP ,"@E 9,999,999.99"),"# CAR: PEDMKPs a compensar")
			cGet3:= PADR("Registro(s) selecionado(s): "  + cValtoChar(Len(_aPedmkp)) + "  - saldo a compensar de R$ " + Transform(_nSaldMKP ,"@E 9,999,999.99"),70)
		endif
	endif


Return()


/*/{Protheus.doc} xProcFIN
Processamento de compensacoes
@type function
@version 1.0
@author Celso Rene
@since 30/05/2025
@param _cForn, variant, string (chave: fornecedor + loja)
@param oSay, variant, Object (say para regua de processamento)
@return variant, return _lRet bollean
/*/
Static Function xProcFIN(_cForn,oSay)

	Local _lRet 	:= .F.
	Local _nx 		:= 0
	Local _nMark 	:= 0
	Local _nSel  	:= 0

	Local aSE1450 	:= {}
	Local aSE2450 	:= {}
	Local aAutoCab 	:= {}
	Local nProc 	:= 0
	Local nErro 	:= 0

	//Local _aRel     := {}
	Local _cLinha   := "Compensacao;Chave titulo CAP;Saldo ant. CAP;RECNO CAP;Chave titulo CAR;PEDMKP;Vlr. compens. CAR;RECNO CAR"  + Crlf
	Local _cQryMKP  := ""
	Local _nCont 	:= 0
	Local _nRECSE1	:= 0
	Local _nRECSE2	:= 0
	Local _cNumTITE1:= ""
	Local _cNumTITE2:= ""
	Local _nSldE2Ant:= 0
	Local _nSldE1Ant:= 0
	Local _nQuery	:= 0 //retorno update SE5 - update E5_ARQORI (TcSqlExec)

	//Local nTamChavE1:= TamSx3("E1_PREFIXO")[1]+TamSx3("E1_NUM")[1]+TamSx3("E1_PARCELA")[1]+TamSx3("E1_TIPO")[1]+TamSx3("E1_FILIAL")[1]
	//Local nTamChavE2:= TamSx3("E2_PREFIXO")[1]+TamSx3("E2_NUM")[1]+TamSx3("E2_PARCELA")[1]+TamSx3("E2_TIPO")[1]+TamSx3("E2_FILIAL")[1]+TamSx3("E2_FORNECE")[1]+TamSx3("E2_LOJA")[1]

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.


	//total dos registros no array - CAR (anexo planilha)
	_nTotReg := Len(_aPedmkp)

	//verificando vetor, selecoes validas
	for _nx:= 1 to Len(_aVetor)
		if (_aVetor[_nx][1])
			_nMark++
			_nSel := _nx
		endif
	next _nx

	//selecao invalida para o processamento
	if (_nMark > 1 .or. _nMark == 0)
		MsgAlert("Selecionado(s) '0' (nenhum) ou mais de '1' (um) registro(s) para processamento das comensações (somente '1' (um) é permitido)!","# Seleção inválida!")
	else

		//verificando se selecionado planilha com os MKPs para compensacoes (SE1: contas a receber)
		if (Len(_aPedmkp) = 0 .or. !lCheckBo1)
			MsgAlert("Não selecionado planilha com os CAR: MKPs para comensações (CAR: PEDMKPs)!","# Plnailha CAR: MKPs inválida!")
			Return()
		endif

		//confirmando processamento das compensacoes entre carteiras
		if (!MsgYesno("Deseja realmente processar as compensações previstas?","# Processamento compens. entre carteiras"))
			Return()
		endif


		//guarda RECNO SE2
		_nRECSE2 := _aVetor[_nSel][8]

		//processando as compensacoes dos CAR: PDMKPS selecionados
		for _nx:= 1 to Len(_aPedmkp)

			//posicionando registro SE2
			dbSelectArea("SE2")
			dbGoTo(_nRECSE2)

			//chave SE2: conta a pagar
			aSE2450:= {}
			aadd(aSE2450,{SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA})

			_cQryMKP := "SELECT E1_PEDMKP, E1_PREFIXO, E1_NUM, E1_SALDO, E1_TIPO, R_E_C_N_O_ RECSE1 FROM SE1010 WHERE E1_FILIAL = '  ' AND E1_TIPO IN ('NF','NFP','NDC') AND E1_PEDMKP = '" + Alltrim(_aPedmkp[_nx][1]) + "' AND E1_SALDO >= " + cValtoChar(_aPedmkp[_nx][2]) + " AND D_E_L_E_T_ = ' ' "
			if ( SELECT("TSE1") ) <>  0
				TSE1->(dbCloseArea())
			endif
			TcQuery _cQryMKP Alias "TSE1" New

			//se nao encontrar registro SE1 - Loop
			if (TSE1->(EOF()))
				TSE1->(dbCloseArea())
				Loop
			endif

			//guarda RECNO SE1
			_nRECSE1 := TSE1->RECSE1

			//posicionando registro SE1: contas a receber
			dbSelectArea("SE1")
			dbGoTo(_nRECSE1)

			TSE1->(dbCloseArea())

			//chave SE1: conta a receber
			aSE1450:= {}
			aadd(aSE1450,{SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO})
			_cNumTITE1 := SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
			_nSldE1Ant := SE1->E1_SALDO

			if (SE2->E2_SALDO >= _aPedmkp[_nx][2])

				//caso tenha passado , chamo a compensacao para esse PEDMKP
				aAutoCab := {;
					{"AUTDVENINI450", iif(SE1->E1_VENCREA <= SE2->E2_VENCREA,	SE1->E1_VENCREA,SE2->E2_VENCREA)	, nil},;
					{"AUTDVENFIM450", iif(SE1->E1_VENCREA >= SE2->E2_VENCREA,	SE1->E1_VENCREA,SE2->E2_VENCREA)	, nil},;
					{"AUTNLIM450"   , _aPedmkp[_nx][2]  , nil},; //SE2->E2_SALDO
					{"AUTCCLI450"   , SE1->E1_CLIENTE 	, nil},;
					{"AUTCLJCLI"    , SE1->E1_LOJA		, nil},;
					{"AUTCFOR450"   , SE2->E2_FORNECE 	, nil},;
					{"AUTCLJFOR"    , SE2->E2_LOJA 		, nil},;
					{"AUTCMOEDA450" , "01" 				, nil},;
					{"AUTNDEBCRED"  , 1 				, nil},;
					{"AUTLTITFUTURO", .T. 				, nil},;
					{"AUTARECCHAVE" , aSE1450 			, nil},;
					{"AUTAPAGCHAVE" , aSE2450 			, nil}}

				nRecnoTIT := SE2->(RECNO())
				_cNumTITE2 := SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
				_nSldE2Ant := SE2->E2_SALDO

				//chamada de perguntas para FINA450 - obrigatorio
				SetMVValue("AFI450","MV_PAR01",2)
				SetMVValue("AFI450","MV_PAR02",1)
				SetMVValue("AFI450","MV_PAR03",1)
				SetMVValue("AFI450","MV_PAR04",2)
				Pergunte("AFI450",.F.)
				//AcessaPerg("AFI450", .F.)

				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| FINA450(x,y,z)}, nil , aAutoCab , 3 )

				if (lMsErroAuto)
					nErro++
					Mostraerro()
				else
					_lRet := .T.
					nProc++

					//atualizando campo da tabela: SE5 - E5_ARQORI
					_cQryUPDE5 := " UPDATE SE5010 SET E5_ARQORI = '" + Padr(cArqOri, TamSx3("E5_ARQORI")[1]) + "' WHERE E5_FILIAL = '  ' AND E5_IDENTEE = '" + SE5->E5_IDENTEE + "' AND E5_DATA = '" + DtoS(dDataBase) + "' AND E5_ORIGEM = 'INFA125' AND E5_SITUACA = ' ' AND E5_TIPODOC <> 'ES' AND D_E_L_E_T_ = ' ' "
					_nQuery := TcSqlExec(_cQryUPDE5)
					TCSQLEXEC("COMMIT")

					//aadd(_aRel, {SE5->E5_IDENTEE,_cNumTITE2, _nSldE2Ant, _nRECSE2, _cNumTITE1 , _aPedmkp[_nx][1], _aPedmkp[_nx][2], _nRECSE1} )

					//montando string da linha para o relatorio .csv
					_cLinha +=  chr(160) + SE5->E5_IDENTEE
					_cLinha +=  + ";" + chr(160) + _cNumTITE2
					_cLinha +=  + ";" + Transform(_nSldE2Ant,"@E 999,999,999.99")
					_cLinha +=  + ";" + cValtoChar(_nRECSE2)
					_cLinha +=  + ";" + chr(160) + _cNumTITE1
					_cLinha +=  + ";" + chr(160) + _aPedmkp[_nx][1]
					_cLinha +=  + ";" + Transform(_aPedmkp[_nx][2],"@E 999,999,999.99")
					_cLinha +=  + ";" + cValtoChar(_nRECSE1) + Crlf
				endif
			endif

			_nCont++

			oSay:SetText("Processando:  " + cvaltochar(_nCont) + " de " + cvaltochar(_nTotReg))
			ProcessMessage()

		next _nx

		//verificando se processou compensacoes
		if (nProc > 0)
			//mensagem de sucesso e pergunta impressao relatorio planilha .csv ?
			if (MsgYesno("Processamento das compensações realizadas com sucesso, deseja gerar relatorio (planilha '.csv' na pasta = 'c:\temp\Infa425_...')?","# Processadas compensações"))
				//gravando relatorio .csv
				MsAguarde({|| MemoWrite("C:\temp\" + "Infa425_" + DtoS(dDataBase) + "_" + Alltrim(Substring(_cNumTITE2,4,9)) +".csv", _cLinha)}, "Aguarde...", "Relatório Compensações...")
			endif
			_oDlg:End()
		endif

	endif


Return(_lRet)
