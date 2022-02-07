#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "tbiconn.ch"


/*/{Protheus.doc} XDEV695
//Devolucao E.P.I.
@author Celso Rene
@since 07/03/2019
@version 1.0
@type function
/*/
User Function XDEV695()

	Local _aFunc  		:= {}
	Local _aItem  		:= {}
	Local _nOpcao 		:= 5
	//Local _aAreaEPI		:= GetArea()
	Local _aParam		:= {}
	Local _cPrdEPI		:= SCP->CP_PRODUTO
	//Local _cMat			:= SCP->CP_XMAT
	Local _cMat			:= SCP->CP_SEQFUNC

	Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
	Private lMSErroAuto := .F. // inicializa como .F., volta .T. se houver erro

	cmodulo := "MDT"
	modulo	:= 35
	nmodulo	:= 35


	dbSelectArea("TN3")
	dbSetOrder(2) //TN3_FILIAL+TN3_CODEPI  
	dbSeek(xFilial("TN3") + SCP->CP_PRODUTO)

	aAdd( _aFunc, {"RA_MAT", SCP->CP_SEQFUNC, Nil } )// Array com a chave, setando no funcionário a ser entregue o EPI.


	//Dados dos EPI a ser entregue ao funcionário
	aAdd( _aItem, {{"TNF_CODEPI", SCP->CP_PRODUTO , Nil },;
	{"TNF_FORNEC"	, TN3->TN3_FORNEC		, Nil },;
	{"TNF_LOJA"		, TN3->TN3_LOJA			, Nil },; 
	{"TNF_NUMCAP"	, TN3->TN3_NUMCAP		, Nil },;
	{"TNF_MAT"		, SCP->CP_SEQFUNC		, Nil },;
	{"TNF_QTDENT"	, SCP->CP_QUANT			, Nil },;
	{"TNF_LOCAL"	, SCP->CP_LOCAL			, Nil },;
	{"TNF_TIPODV"	, "2"					, Nil },; //nao gerar estoque
	{"TNF_INDDEV"	, "1"					, Nil },;
	{"TNF_LOCDV"	, SCP->CP_LOCAL			, Nil },;
	{"TNF_DTDEVO"	, dDataBase				, Nil },;
	{"TNF_QTDEVO"	, SCP->CP_QUANT			, Nil }})

	If ( SCP->CP_STATUS == "E" ) //requisitada S.A. //SCP->CP_QUANT == SCP->CP_QUJE 

		//PUTMV("MV_NGMDTES", "N")

		dbSelectArea("SRA")
		dbSetOrder(1)
		//dbSeek(xFilial("SRA")+ ZNF->ZNF_MAT)
		dbSelectArea("TNF")
		dbSetOrder(6) //TNF_FILIAL+TNF_NUMSA+TNF_ITEMSA
		dbSeek(xFilial("TNF") + SCP->CP_NUM + SCP->CP_ITEM)
		If ( Found() )  

			//nao funciona o execauto se nao incluir esse trecho...
			//cAliasTLW := GetNextAlias()
			//cArquivTLW := ""
			//MDT695TLW( @cArquivTLW )

			MSExecAuto({|x,z,y,w| MDTA695(x,z,y,w)},, _aFunc, _aItem, 4 ) 


			If (lMSErroAuto)

				MostraErro()
				MsgAlert("Problema ao executar operação automática de devolução - Funcionário x EPI.","# Falha rotina automática MDTA695!")

			Else
			
				If (TNF->TNF_QTDEVO > 0)

					_lTNF := .T.

					MsgInfo("Devolução E.P.I. registro - Funcionário x EPI: " + _cMat + " - " + _cPrdEPI )
				
				Else
					
					MsgAlert("Problema ao executar operação automática de devolução - Funcionário x EPI.","# Falha rotina automática MDTA695!")
					
				EndIf

			EndIf

			//PUTMV("MV_NGMDTES", "S")

		Endif
		
	EndIf

	cmodulo := "EST"
	modulo	:= 04
	nmodulo	:= 04


	//	RestArea(_aAreaEPI)


Return()
