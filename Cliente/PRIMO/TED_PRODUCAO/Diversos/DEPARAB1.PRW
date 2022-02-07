#include "rwmake.ch"
#include "topconn.ch"
/*
+-------+--------------+---------+---------------------------+---------+-------------+
|Funcao | DEPARA       | Autor:  | Marcos Zanetti            | Data:   |  21/05/04   |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | Alteracao de codigo de produtos no sistema    		                 | 
+-------------+----------------------------------------------------------------------+
| Uso:        | Modulo Compras / Estoque / Faturamento                               |
+-------------+----------------------------------------------------------------------+
| Observações: No final do processamento, o sistema gera um rquivo de LOG com o nome | 
|		       DPaammdd.log, onde aammdd identifica a data de execucao do programa.  |
+--------------------+-----------+---------------------------------------------------+
|            ALTERACOES FEITAS DESDE A CRIACAO DO PROGRAMA:                          |
+--------------------+-----------+---------------------------------------------------+
|Programador         | Data      | Descricao                                         |
+--------------------+-----------+---------------------------------------------------+
|Rodrigo Carvalhaes  | 04/07/2004| Alterado para o programa trabalhar com a tabela   |
|								 | SZ8 ao invés de com o arquivo em DBF				 |
+--------------------+-----------+---------------------------------------------------+  

CASO VOCÊ ALTERE ESSE PROGRAMA, FAVOR ENVIAR CÓPIA PARA: rodrigo@carvalhaes.net 
SE POSSUIRES SUGESTÕES PARA INCLUIRMOS NESTE "TO DO LIST", NÃO HESITE EM ME ENVIAR.

*/

// TO DO LIST:
// 1. SE NÃO HOUVER NENHUM PRODUTO ELE NÃO ESTÁ ABORTANDO AS ALTERAÇÕES. CORREÇÃO.
// 2. ALTERAR A FUNÇÃO CRV028 PARA BROWSE COM MENU CONFIGURAVEL E INCLUIR NESTE MENU AS SEGUINTES ROTINAS:
// => LIMPAR A TABELA SZ8 (UTIL APOS A ALTERAÇÃO DE CÓDIGOS POIS DELETAR UM A UM É UM SACO...)
// => GERAR CÓDIGO - AONDE ABRIRIA UMA TELA SOLICITANDO O CÓDIGO INICIAL E USANDO A FUNCAO SOMA1
// GERARIA O CODIGO INCREMENTAL PARA TODOS OS ITENS, GRAVANDO NO CAMPO COD_PARA

/*/{Protheus.doc} DEPARAB1
Alteracao de codigo de produtos no sistema .
@type function
@version 
@author Márcio Borges - Solutio
@since 31/07/2020
@return return_type, return_description
/*/
User Function DEPARAB1()

	Local x_cFilAnt := cFilAnt
	Local aSays		:= {}
	Local aButtons 	:= {}
	Local nOpca 	:= 0
	Local cCadastro := "Alteração de códigos de produtos"

	Private cTabDEPARA 	:= "DEPARAB1V1" // Tabela de Modificações DE-PARA
	Private lRunB1COD   := .F.
	Private lAtualiz	:= .T. //Se altera os registros ou apenas loga
	Private  nTotReg 	:= 0  // Quantidades de de-para a serem efetuados


/*
Estrutura:
FILIAL 		--> Filial do de-para
COD_DE 		--> Código anterior
COD_PARA	--> Novo Código
DTHRPROC	--> Processado na data hora "AAAAMMDD-HH:MM:SS"

*/

	Private _aCampos:= {}
	Private _cLog 	:= ""
	Private lErro   := .F.

	AADD(aSays,"Este programa efetuará a mudança de códigos de produtos no sistema")
	AADD(aSays,"com base na tabela " + cTabDEPARA + " presente no banco de dados.")
//AADD(aSays,"Caso esse arquivo não exista, será criado um novo vazio.")
	AADD(aSays,"")
	AADD(aSays,"")
	AADD(aSays,"")
	AADD(aSays,"Específico Primo Tedesco")
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End() } } )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( cCadastro, aSays, aButtons )

// Se confirmado o processamento
	if nOpcA == 1

		/*
		IF MsgYesNo("Deseja efetuar ajuste da campo de Produto da tabela principal de Produto (B1_COD) [NÃO RECOMENDADO] ?",OemToAnsi("TABELAS"))
			lRunB1COD := .T.
		ENDIF
		*/

		Proc2BarGauge({||AltCodigo()},"Alterando Códigos de produto","Iniciando Processamento", "Processando Tabela")
		if select("QRY")>0
			QRY->(dbclosearea())
		endif
	endif
	cFilAnt := x_cFilAnt

return


/*/{Protheus.doc} AltCodigo
Processa os arquivos, efetuando a alteracao do codigo 
@type function
@version 
@author solutio
@since 31/07/2020
@return return_type, return_description
/*/
Static Function AltCodigo()

	//Local X_FILIAL	:= 1
	//Local X_COD_DE	:= 2
	//Local X_COD_PARA := 3

	Local _ni
	Local lExistOld	 := .F.
	Local lExiSTNovo := .F.


	private _cAlias
	private _cCampo
	//private _cCpo
	private _nPos
	private _aCodigos := {}

	private _cTabela
	private _cEnter := chr(13) + chr(10)


	CarregaVet() // Carrega a matriz com os campos q serao alterados

	if !AbreArq() // Funcao de abertura do arquivo com os codigos antigos e novos dos produtos
		return
	endif

	//Abre SB1
	DBselectArea("SB1"); DBsetOrder(1) //Filial + Produto


	QRY->(dbgotop())

	BarGauge1Set( nTotReg )
	while QRY->(!eof())
		//aadd(_aCodigos,{QRY->FILIAL,QRY->COD_DE,QRY->COD_PARA})
		cFilAnt := QRY->FILIAL
		IncProcG1("Alterando produto " + QRY->COD_DE + " para " + QRY->COD_PARA ) // Incrementa a regua 2
		// Define o tamanho da regua 1 - Tabela DEPARA
		BarGauge2Set(Len(_aCampos)) 	// Define o tamanho da regua 2 - Campos processados

		//Posiciona Cadastro de Produto para avaliar existência
		SB1->(DBGotop())
		lExistOld  := SB1->(MsSeek( xFilial("SB1") +  PadR( QRY->COD_DE  , TamSX3("B1_COD")[01] )  ))
		SB1->(DBGotop())
		lExiSTNovo := SB1->(MsSeek( xFilial("SB1") +  PadR( QRY->COD_PARA, TamSX3("B1_COD")[01] )  ))


		Begin Transaction
			If !lExiSTNovo .and. lExistOld //Altera o código do produto

				SB1->(DBGotop())
				SB1->(MsSeek( xFilial("SB1") +  PadR( QRY->COD_DE  , TamSX3("B1_COD")[01] )  ))

				_cLog += "Alerta: Alterado código de produto (B1_COD) do registro SB1  - recno " + ALLTRIM(STR(SB1->(RECNO())))  + " , Cód DE: " + alltrim(QRY->COD_DE) + ", Cód PARA: " + alltrim(QRY->COD_PARA) +  _cEnter
				RecLock("SB1",.F.)
				SB1->B1_COD      := QRY->COD_PARA
				MsUnLock()


			ElseIF lExiSTNovo .and. lExistOld //Existem ambos códigos na mesma filial, deleta o código antigo
				SB1->(DBGotop())
				SB1->(MsSeek( xFilial("SB1") +  PadR( QRY->COD_DE  , TamSX3("B1_COD")[01] )  ))

				_cLog +=  "Alerta: Deletado registro SB1  - recno " + ALLTRIM(STR(SB1->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE) +  _cEnter
				RecLock("SB1",.F.)
				DBDELETE()
				MsUnLock()
			Endif

			// Mantem Produto posicionado no cadastro novo (PARA)
			SB1->(DBGotop())
			SB1->(MsSeek( xfilial("SB1") +  PadR( QRY->COD_PARA, TamSX3("B1_COD")[01] )  ))


			For _ni := 1 to Len(_aCampos)

				_cAlias := FWTabPref(_aCampos[_ni])
				_cCampo	:= _aCampos[_ni]
				//_cCpo   := _cAlias+"->"+_aCampos[_ni]



				IncProcG2("Processando tabela: " + _cAlias) // Incrementa a regua 1
				_cTabela := RetSQLName(_cAlias)

				if TcCanOpen(_cTabela) // Se conseguir abrir a tabela

					dbselectarea(_cAlias)
					//		dbsetorder(0) // Tira os indices da tabela

					_nPos := FieldPos(_cCampo)

					//Campos que NÃO  serão processados
					If AllTrim(_cCampo)  == 'B1_COD' .OR. AllTrim(_cCampo)  == 'A5_CODFIS' .OR. AllTrim(_cCampo)  == 'D1_CODFIS' //'B1_COD/B9_COD'
						_nPos := 0 // seta variavel para não processar este campo
					ENDIF

					//TAbelas a desconsiderar
					// Desconsiderando SB2 pois pode já existir registro movimentado (e estava dando erro de chave duplicada), e no recálculo o sistema recria os registros necessários
					If _cAlias $ 'SB2' // B2_FILIAL+B2_LOCAL+B2_COD
						DbSelectArea("SB2"); DBSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL
						SB2->(DBGotop())
						//Busca sem local, pois apaga todos os antigos códigos
						lExistOld := SB2->(MsSeek( xfilial("SB2") + PadR( QRY->COD_DE, TamSX3("B2_COD")[01] ) ) )

						While lExistOld
							_cLog +=  "Alerta: Deletado código de produto (B2_COD) do registro sb2  - recno " + ALLTRIM (STR(SB2->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE)  +  _cEnter

							RecLock("SB2",.F.)
							DBDELETE()
							MsUnLock()

							SB2->(DBGotop())
							lExistOld := SB2->(MsSeek( xfilial("SB2") + PadR( QRY->COD_DE, TamSX3("B2_COD")[01] ) ) )


						Enddo
						_nPos := 0 // seta variavel para não processar este campo
					ENDIF
					//campo para localizar se já existe chave
					If AllTrim(_cCampo) $ 'B9_COD' // UNICO: B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)

						DbSelectArea("SB9"); DBSetOrder(1) //B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)

						SB9->(DBGotop())
						lExiSTNovo  := SB9->(MsSeek( xfilial("SB9") +  PadR( QRY->COD_PARA  , TamSX3("B9_COD")[01] ) + SB1->B1_LOCPAD + '20191231' ) )

						iF !lExiSTNovo
							SB9->(DBGotop())
							lExiSTNovo := SB9->(MsSeek( xfilial("SB9") +  PadR( QRY->COD_PARA  , TamSX3("B9_COD")[01] ) + SB1->B1_LOCPAD + SPACE(8) ) )
						Endif


						SB9->(DBGotop())
						lExistOld  := SB9->(MsSeek( xfilial("SB9") +  PadR( QRY->COD_DE  , TamSX3("B9_COD")[01] ) + SB1->B1_LOCPAD + '20191231' ) )
						iF !lExistOld
							SB9->(DBGotop())
							lExistOld := SB9->(MsSeek( xfilial("SB9") +  PadR( QRY->COD_DE  , TamSX3("B9_COD")[01] ) + SB1->B1_LOCPAD + SPACE(8) ) )
						Endif
						nRecPos := SB9->(recno())

						If !lExiSTNovo .and. lExistOld //Posiciona no antigo e altera o código

							//	SB9->(DBGotop())
							//	SB9->(DBGoTO(nRecPos)) //Posiciona no antigo código

							_cLog +=  "Alerta: Alterado código de produto (B9_COD) do registro sb9  - recno " + ALLTRIM (STR(SB9->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE) + ", Cód PARA: " + alltrim(QRY->COD_PARA) +  _cEnter
							RecLock("SB9",.F.)
							SB9->B9_COD      := QRY->COD_PARA
							MsUnLock()


						ElseIF lExiSTNovo .and. lExistOld //Existem ambos códigos na mesma filial, deleta o código antigo
							//posicionado no registro antigo

							_cLog +=  "Alerta: Deletado registro SB9  - recno " + ALLTRIM (STR(SB9->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE) +  _cEnter
							RecLock("SB9",.F.)
							DBDELETE()
							MsUnLock()
						ElseIF !lExiSTNovo .and. !lExistOld
							RecLock("SB9",.T.)
							SB9->B9_FILIAL	:= xFilial("SB9")
							SB9->B9_COD		:= QRY->COD_PARA
							SB9->B9_LOCAL 	:= SB1->B1_LOCPAD
							SB9->B9_DATA	:= STOD('20191231')
							SB9->B9_MCUSTD	:= "1"
							MsUnLock()

							_cLog +=  "Alerta: Criado saldo inicial - registro SB9  - recno " + ALLTRIM (STR(SB9->(RECNO()))) + " , Cód PARA: " + alltrim(QRY->COD_PARA) +  _cEnter

						Endif

					Endif

					If _cAlias $ 'SB3'

						DbSelectArea("SB3"); DBSetOrder(1) //B3_FILIAL+B3_COD


						SB3->(DBGotop())
						lExiSTNovo  := SB3->(MsSeek( xfilial("SB3") +  PadR( QRY->COD_PARA  , TamSX3("B3_COD")[01] ) ) )

						SB3->(DBGotop())
						lExistOld  := SB3->(MsSeek( xfilial("SB3") +  PadR( QRY->COD_DE  , TamSX3("B3_COD")[01] ) ) )


						IF lExiSTNovo .and. lExistOld //Existem ambos códigos na mesma filial, deleta o código antigo
							_cLog +=  "Alerta: Deletado registro SB3  - recno " + ALLTRIM (STR(SB9->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE) +  _cEnter
							RecLock("SB3",.F.)
							DBDELETE()
							MsUnLock()
						Endif

					Endif

					If _cAlias $ 'SBZ'

						DbSelectArea("SBZ"); DBSetOrder(1) //BZ_FILIAL+BZ_COD


						SBZ->(DBGotop())
						lExiSTNovo  := SBZ->(MsSeek( xfilial("SBZ") +  PadR( QRY->COD_PARA  , TamSX3("BZ_COD")[01] ) ) )

						SBZ->(DBGotop())
						lExistOld  := SBZ->(MsSeek( xfilial("SBZ") +  PadR( QRY->COD_DE  , TamSX3("BZ_COD")[01] ) ) )


						IF lExiSTNovo .and. lExistOld //Existem ambos códigos na mesma filial, deleta o código antigo
							_cLog +=  "Alerta: Deletado registro SB3  - recno " + ALLTRIM (STR(SB9->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE) +  _cEnter
							RecLock("SBZ",.F.)
							DBDELETE()
							MsUnLock()
						Endif

					Endif


					If _cAlias $ 'SB5' //B5_FILIAL+B5_COD

						DbSelectArea("SB5"); DBSetOrder(1) //UNICO: B5_FILIAL+B5_COD


						SB5->(DBGotop())
						lExiSTNovo  := SB5->(MsSeek( xfilial("SB5") +  PadR( QRY->COD_PARA  , TamSX3("B5_COD")[01] ) ) )

						SB5->(DBGotop())
						lExistOld  := SB5->(MsSeek( xfilial("SB5") +  PadR( QRY->COD_DE  , TamSX3("B5_COD")[01] ) ) )


						IF lExiSTNovo .and. lExistOld //Existem ambos códigos na mesma filial, deleta o código antigo
							_cLog +=  "Alerta: Deletado registro SB5  - recno " + ALLTRIM (STR(SB5->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE) +  _cEnter
							RecLock("SB5",.F.)
							DBDELETE()
							MsUnLock()
						Endif

					Endif



					If _cAlias $ 'F3K' //
						DbSelectArea("F3K"); DBSetOrder(1) //F3K_FILIAL+F3K_PROD+
						F3K->(DBGotop())
						//Busca sem local, pois apaga todos os antigos códigos
						lExistOld := F3K->(MsSeek( xfilial("F3K") + PadR( QRY->COD_DE, TamSX3("F3K_PROD")[01] ) ) )

						While lExistOld
							_cLog +=  "Alerta: Deletado código de produto (F3K_PROD) do registro F3K  - recno " + ALLTRIM (STR(SB2->(RECNO()))) + " , Cód DE: " + alltrim(QRY->COD_DE) +  _cEnter

							RecLock("F3K",.F.)
							DBDELETE()
							MsUnLock()

							F3K->(DBGotop())
							lExistOld := F3K->(MsSeek( xfilial("F3K") + PadR( QRY->COD_DE, TamSX3("F3K_PROD")[01] ) ) )


						Enddo
						_nPos := 0 // seta variavel para não processar este campo
					ENDIF

					if _nPos > 0

						_cSQL := "UPDATE " + _cTabela + " SET " + _cCampo + " = '" + PadR( QRY->COD_PARA, TamSX3(_cCampo)[01])  + "' WHERE " + PrefixoCpo(_cAlias) + "_FILIAL = '" + QRY->FILIAL + "' AND " + _cCampo + " = '" + QRY->COD_DE + "' AND " + _cCampo + " <> '" + PadR( QRY->COD_PARA, TamSX3(_cCampo)[01])  + "'"
						_cLog += _cSQL + ";" +  _cEnter
						IF lAtualiz
							if TcSQLExec(_cSQL) < 0
								lErro := .T.
								_cLog += "Erro na atualizacao do campo " + _cCampo + _cEnter
								_cLog += "Codigo atual: " + QRY->COD_DE + _cEnter
								_cLog += "Codigo novo: " + QRY->COD_PARA + _cEnter
								_cLog += "Erro retornado pelo Top Connect: " + TcSqlError() + _cEnter

								If InTransact()
									GravaLog()
									DisarmTransaction()
									Break
								Endif
							Endif
						Endif



					endif

					dbselectarea(_cAlias)
					dbsetorder(1) // retorna o primeiro indice
				endif
			Next _ni

			cTime := time()
			cTime := SUBSTR(cTime,1,2) + "H" + SUBSTR(cTime,4,2)

			//If lAtualiz
			_cSQL := " UPDATE  " + cTabDEPARA + " SET  DTHRPROC = '"+ PadR( DTOS(msDate()) + "_" + cTime, 15 ) + "'" // Apenas para filial do SB1 (melhora performance)
			_cSQL += " WHERE R_E_C_N_O_ = " + STR(QRY->NREG)
			_cLog += _cSQL + ";" +  _cEnter

			IF lAtualiz
				if TcSQLExec(_cSQL) < 0
					lErro := .T.
					_cLog += "Erro retornado pelo Top Connect na atualização da tabela " + cTabDEPARA + ": " + TcSqlError() + _cEnter
					If InTransact()
						GravaLog()
						DisarmTransaction()
						Break
					Endif
				Endif
			Endif
			_cLog += "________________________________________" +  _cEnter

		/*dbselectarea("QRY")
		RecLock("QRY",.F.)
		QRY->DTHRPROC :=  DTOS(msDate()) + " - " + time()  //Data-
		MSUnlock()*/

		//Endif


		End Transaction


		QRY->(dbskip())
	enddo


gravalog()




return


Static Function GravaLog()

	if !empty(_cLog)
		cTime := time()
		cTime := SUBSTR(cTime,1,2) + "H" + SUBSTR(cTime,4,2)

		_cNomeLog := "c:\totvs\sqlsiga\DP" + substr(dtos(date()),3,6) +"-" +  cTime + iif(lErro,"falha","sucesso") + ".LOG"
		memowrite(_cNomeLog,_cLog)
		If lErro
			msgstop("Ocorreram erros durante a execução do programa. Verifique o arquivo " + _cNomeLog + " para maiores informações.")
		Else
			IW_MsgBox("Log de Processamento registrado no arquivo " + _cNomeLog ,OemToAnsi("Arquivo..."),"INFO" )
		Endif
	else
		MSGBOX(OemToAnsi("Alteração de códigos efetuada com SUCESSO !") ,"AVISO","INFO")
	endif

Return 


/*/{Protheus.doc} AbreArq
Abre tabela de DE_PARA com  que precisa ser alterado
@type function
@version 
@author solutio
@since 31/07/2020
@return return_type, return_description
/*/
Static Function AbreArq()

	Local cQuery   := ""
	Local _lRet := .T.
	Local aSetField := {}

	AADD(aSetField,{"NREG","N",15,0})



	cQuery := " SELECT FILIAL, COD_DE, COD_PARA, R_E_C_N_O_ AS NREG"
	cQuery += " FROM " + cTabDEPARA
	cQuery += " WHERE DTHRPROC = '                 '" // Apenas para filial do SB1 (melhora performance)
	cQuery += " AND  D_E_L_E_T_ <> '*' "

// Ajusta a query de acordo com o banco de dados 
	//cQuery := ChangeQuery(cQuery)

// Execucao da query
	MPSysOpenQuery( cQuery, 'QRY',aSetField  ) // TcQuery cQuery New Alias "QRY"


	DbSelectArea("QRY")
	QRY->(dbgotop())
	Count To nTotReg
	QRY->(DBGotop())

	if select("QRY") == 0 // Checa se o arquivo foi aberto com sucesso
		msgstop("A tabela " + cTabDEPARA + " não pode ser aberta. Esse programa deve ser executado de forma exclusiva.")
		return(.F.)
	endif

//IndRegua("QRY",CriaTrab(NIL,.F.),"QRY->COD_DE",,,"Selecionando Registros...")

	if nTotReg == 0
		msgstop("O arquivo de dados está vazio, cadastre os códigos a serem alterados e execute a rotina novamente.")
		_lRet := .F.
	endif

return(_lRet)


/*/{Protheus.doc} CarregaVet
 Carrega a matriz _aCampos com os campos que serao alterados
@type function
@version 
@author solutio
@since 31/07/2020
@return return_type, return_description
/*/
Static Function CarregaVet()
	//Local nPos


//Grupo Campos de Produto = '030'
	_aCampos := FWSX3Util():GetAllGroupFields( "030" )

/*
//IF !lRunB1COD 
	nPos:=Ascan(_aCampos, { |x| x == 'B1_COD' })
	If nPos > 0
		aDEL(_aCampos,nPos)
		// REDIMENSIONA O ARRAY
		aSize(_aCampos, LEN(_aCampos)-1)
	Endif
//Endif 
*/


return


/*
+-------+--------------+---------+---------------------------+---------+-------------+
|Funcao | CRV028       | Autor:  | Rodrigo Carvalhaes        | Data:   |  04/07/04   |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | Browse com os itens com terão  o código alterado 	                 | 
+-------------+----------------------------------------------------------------------+
| Uso:        | Modulo Compras / Estoque / Faturamento                               |
+-------------+----------------------------------------------------------------------+
| Observações: 																		 |
+--------------------+-----------+---------------------------------------------------+
|            ALTERACOES FEITAS DESDE A CRIACAO DO PROGRAMA:                          |
+--------------------+-----------+---------------------------------------------------+
|Programador         | Data      | Descricao                                         |
+--------------------+-----------+---------------------------------------------------+
*/
/*
	*---------------------------------*
User Function CRV028()
	*---------------------------------*
	Local cVldAlt := ".T."
	Local cVldExc := ".T."

	Private cString := "SZ8"

	dbSelectArea("SZ8")
	dbSetOrder(1)

	AxCadastro(cString,"Dados tabela SZ8 - CRV028",cVldAlt,cVldExc)
Return
*/
