#include "tbiconn.ch"
#include "totvs.ch"
#include "ap5mail.ch"

USER FUNCTION DtComA01()
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Rotina monta a tela de gerenciamento da substituiÁ„o de aprovadores
	<Data> : 28/04/2014
	<Parametros> : Nenhum
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Valiuedacao,Ponto de Entrada,Genericas,Especificas ) : M
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local aCores	:= {}
	Private aRotina		:= MenuDef()
	Private cCadastro	:= "Aprovadores substitutos"


	Aadd(aCores, {"Z0G_STATUS=='1'", "BR_VERDE"})
	Aadd(aCores, {"Z0G_STATUS=='2'", "BR_AMARELO"})
	Aadd(aCores, {"Z0G_STATUS=='3'", "BR_VERMELHO"})

	DbSelectArea("Z0G")
	DbSetOrder(1)
	DbSeek(xFilial("Z0G"), .t.)

	MBrowse(006, 001, 022, 075, "Z0G",,,,,, aCores)
RETURN

STATIC FUNCTION MenuDef()
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Define a montagem das opÁıes de menu da rotina
	<Data> : 28/04/2014
	<Parametros> : Nenhum
	<Retorno> : Array com as opÁıes para o menu
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local aRet	:= {}

	Aadd(aRet, {"Pesquisar"		, "AxPesqui"	, 0, 1})
	Aadd(aRet, {"Visualizar"	, "AxVisual"	, 0, 2})
	Aadd(aRet, {"Incluir"		, "AxInclui"	, 0, 3})
	Aadd(aRet, {"Alterar"		, "u_DtCom01X"	, 0, 4})
	Aadd(aRet, {"Excluir"		, "u_DtCom01X"	, 0, 5})
	Aadd(aRet, {"Ativar"		, "u_DtCom01X"	, 0, 6})
	Aadd(aRet, {"Desativar"		, "u_DtCom01X"	, 0, 7})
	Aadd(aRet, {"JOB Manual"	, "u_DtCom01X"	, 0, 8})

Return(aRet)

STATIC FUNCTION ExeJob()
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Faz a chamada para simular a execuÁ„o por JOB a partir do menu da rotina
	<Data> : 28/04/2014
	<Parametros> : Nenhum
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local oServer
	Local _cServer	:= GetSrvInfo()[1]
	Local _cPorta	:= Alltrim(GetPvProfString("TCP", "PORT", "", GetAdv97()))
	Local _cEnvSrv	:= GetEnvServer()
	Local _cErro	:= ""

//CREATE RPCCONN oServer ON SERVER _cServer PORT Val(_cPorta) ENVIRONMENT _cEnvSrv EMPRESA cEmpAnt FILIAL cFilAnt

//IF ValType(oServer) == "O"
	//oServer:CallProc("U_DtCom01J", {cEmpAnt, cFilAnt})
	U_DtCom01J({"01", "01RS0001"},.f.)
	//CLOSE RPCCONN oServer
//ELSE
//	Aviso("AtenÁ„o", "Houve um erro na montagem do ambiente para o JOB!", {"Fechar"})
//ENDIF

RETURN


USER FUNCTION DtCom01J(aParam, p_lAuto)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Job para execuÁ„o autom·tica da substituiÁ„o de aprovadores
	<Data> : 28/04/2014
	<Parametros> : Array com dois elementos, empresa e filial, para a montagem do ambiente
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cEmp	:= ""
	Local cFil	:= ""
	Default aParam	:= {"01", "01RS0001"}
	Default p_lAuto := .T.

	SET DATE BRITISH
	SET CENTURY ON

	IF Len(aParam) < 2
		MsgOut("Par‚metros de ambiente inv·lidos.")
		RETURN
	ELSE
		cEmp	:= aParam[1]
		cFil	:= aParam[2]
	ENDIF

	If p_lAuto
		MsgOut("Preparando para montar ambiente: " + cEmp + " - " + cFil)

		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
		IF Select("SX2") > 0
			MsgOut("Ambiente montado corretamente: " + cEmp + " - " + cFil)
			RunProc()
			u_FISAL001(.F.)
			u_FIZ0J001(.F.)
			RpcClearEnv()
		ELSE
			MsgOut("Falha montando ambiente: " + cEmp + " - " + cFil)
		ENDIF
	Else
		RunProc()
		u_FISAL001(.F.)
		u_FIZ0J001(.F.)
	EndIf

RETURN

STATIC FUNCTION MsgOut(cMsg)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : FunÁ„o para padronizar o registro de atividades no console
	<Data> : 28/04/2014
	<Parametros> : cMsg - Mensagem a ser exibida no console
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	ConOut("DTCOM01J - " + Dtoc(Date()) + " " + Time() + ": " + cMsg)
RETURN

STATIC FUNCTION RunProc()
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Efetivo processamento da substituiÁ„o de aprovadores chamada pelo JOB
	<Data> : 28/04/2014
	<Parametros> : Nenhum
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cMail		:= GetMv("DT_EMSUAPR",, "")
	Local cQuery	:= ""
	Local dDate		:= Date()
	Local cTime		:= Time()
	Local nTotReg	:= 0
	Local cMsgLog	:= ""

// Primeiro verifica a todos que est„o com status 1 e data de inÌcio menor ou igual a hoje
	MsgOut("Iniciando ativaÁ„o de substitutos.")

	cMsgLog	:= "Processo de substituiÁ„o iniciado em " + Dtoc(dDate) + " ‡s " + cTime + " h" + CRLF + CRLF

	cQuery := "SELECT Z0G.R_E_C_N_O_ AS REG "
	cQuery += "FROM " + RetSqlName("Z0G") + " Z0G "
	cQuery += "WHERE Z0G.D_E_L_E_T_ = ' ' "
	cQuery += "AND Z0G_STATUS = '1' "
	cQuery += "AND Z0G_DATAI <= '" + Dtos(dDate) + "' "

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBZ0G", .F., .T.)

	TBZ0G->(DbGoTop())

	WHILE !TBZ0G->(Eof())
		nTotReg++

		Z0G->(DbGoTo(TBZ0G->REG))

		BEGIN TRANSACTION
			AtivComp(Z0G->Z0G_CODIGO, Z0G->Z0G_GRPAPR, Z0G->Z0G_APROV, Z0G->Z0G_SUBST, .t.)
		END TRANSACTION

		TBZ0G->(DbSkip())
	ENDDO
	TBZ0G->(DbCloseArea())

	IF nTotReg == 0
		cMsgLog += "N„o foram localizados aprovadores para iniciar a substituiÁ„o." + CRLF + CRLF
	ELSE
		cMsgLog += "Foram iniciados " + Alltrim(Str(nTotReg)) + " processos de substituiÁ„o." + CRLF + CRLF
		nTotReg	:= 0
	ENDIF

	MsgOut("Finalizando ativaÁ„o de substitutos.")

// Verifica a todos que est„o com status 2 e data de tÈrmino menor que hoje
	MsgOut("Iniciando desativaÁ„o de substitutos.")

	cQuery := "SELECT Z0G.R_E_C_N_O_ AS REG "
	cQuery += "FROM " + RetSqlName("Z0G") + " Z0G "
	cQuery += "WHERE Z0G.D_E_L_E_T_ = ' ' "
	cQuery += "AND Z0G_STATUS = '2' "
	cQuery += "AND Z0G_DATAF < '" + Dtos(dDate) + "' "

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBZ0G", .F., .T.)

	TBZ0G->(DbGoTop())

	WHILE !TBZ0G->(Eof())
		nTotReg++

		Z0G->(DbGoTo(TBZ0G->REG))

		BEGIN TRANSACTION
			InatComp(Z0G->Z0G_CODIGO, .t.)
		END TRANSACTION
		IF TcSqlExec("DELETE " + RetSqlName("SAL") + " WHERE D_E_L_E_T_ = '*' AND AL_XCHAVE = '" + Z0G->Z0G_CODIGO + "'") > 0
			Aviso("Erro update", TcSqlError(), {"Fechar"}, 3)
		ELSE
			TcRefresh(RetSqlName("SAL"))
		ENDIF
		TBZ0G->(DbSkip())
	ENDDO
	TBZ0G->(DbCloseArea())

	IF nTotReg == 0
		cMsgLog += "N„o foram localizados aprovadores para encerrar a substituiÁ„o." + CRLF + CRLF
	ELSE
		cMsgLog += "Foram encerrados " + Alltrim(Str(nTotReg)) + " processos de substituiÁ„o." + CRLF + CRLF
		nTotReg	:= 0
	ENDIF

	cMsgLog += "Processo de substituiÁ„o finalizado em " + Dtoc(Date()) + " ‡s " + Time() + " h" + CRLF + CRLF

	MsgOut("Finalizando desativaÁ„o de substitutos.")

	IF !Empty(Alltrim(cMail))
		EnvMail(cMail, cMsgLog)
	ELSE
		MsgOut("EndereÁo de e-mail n„o informado no par‚metro 'DT_EMSUAPR' ou par‚metro n„o cadastrado.")
	ENDIF

RETURN

STATIC FUNCTION EnvMail(cMailDestino, cTexto)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Faz o envio de e-mails informativos de processamento
	<Data> : 28/04/2014
	<Parametros> : cMailDestino, cTexto
	cMailDestino	: EndereÁo de destino da mensagem
	cTexto			: Mensagem a ser enviada
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cMailServer	:= GetMv("MV_RELSERV")
	Local cMailConta	:= GetMv("MV_RELACNT")
	Local cMailSenha	:= GetMv("MV_RELPSW" )
	Local lMensagem		:= .t.
	Local cAssunto		:= "SubstituiÁ„o de Aprovadores - Log de Processamento"
	Local lConexao		:= .F.
	Local lEnvio		:= .F.
	Local lDesconexao	:= .F.
	Local lErro			:= .F.
	Local cErro			:= ""

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Executa conexao ao servidor mencionado no parametro. ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lConexao

	If !lConexao .AND. !lErro
		GET MAIL ERROR cErro
		MsgOut("Nao foi possivel estabelecer a CONEXAO com o servidor - " + cErro)
		lErro := .t.
	EndIf

	cTexto	:= '<meta MIME-Version: 1.0 Content-type: text/html; charset=iso-8859-1>' +;
		'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' +;
		'<html><title></title><head></head><body>' + cTexto +  '</body></html>'

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Executa envio da mensagem. ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF !lErro
		SEND MAIL FROM cMailConta TO cMailDestino SUBJECT cAssunto BODY cTexto FORMAT TEXT RESULT lEnvio
	ENDIF

	IF !lEnvio .And. !lErro
		GET MAIL ERROR cErro
		MsgOut("Nao foi possivel ENVIAR a mensagem - " + cErro)
		lErro := .T.
	ENDIF

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Executa disconexao ao servidor SMTP. ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF lConexao
		DISCONNECT SMTP SERVER RESULT lDesconexao
	ENDIF
	IF !lDesconexao .And. !lErro
		GET MAIL ERROR cErro
		MsgOut("Nao foi possivel desconectar do servidor - " + cErro)
		lErro := .T.
	ENDIF

RETURN

USER FUNCTION DtCom01X(cAlias, nReg, nOpc)
	IF aRotina[nOpc, 4] == 6
		IF Z0G->Z0G_STATUS # "1"
			Aviso("Status", "O status atual deste documento n„o permite a ativaÁ„o da substituiÁ„o de aprovador!", {"Fechar"}, 2)
		ELSEIF MsgYesNo("Confirma iniciar a substituiÁ„o do(a) aprovador(a) " + Alltrim(Z0G->Z0G_NOMAPR) + " pelo(a) aprovador(a) " + Alltrim(Z0G->Z0G_NOMSUB) + "?" + CRLF + ;
				"A substituiÁ„o iniciar· imediatamente e ficar· em vigor atÈ o dia " + Dtoc(Iif(Z0G->Z0G_DATAF < Date(), Date(), Z0G->Z0G_DATAF)) + ".")
			BEGIN TRANSACTION
				Processa({|| AtivComp(Z0G->Z0G_CODIGO, Z0G->Z0G_GRPAPR, Z0G->Z0G_APROV, Z0G->Z0G_SUBST)})
			END TRANSACTION
		ENDIF
	ELSEIF aRotina[nOpc, 4] == 7
		IF Z0G->Z0G_STATUS # "2"
			Aviso("Status", "O status atual deste documento n„o permite a desativaÁ„o da substituiÁ„o de aprovador!", {"Fechar"}, 2)
		ELSEIF MsgYesNo("Confirma o encerramento da substituiÁ„o do(a) aprovador(a) " + Alltrim(Z0G->Z0G_NOMAPR) + " pelo(a) aprovador(a) " + Alltrim(Z0G->Z0G_NOMSUB) + ;
				" imediatamente?")
			BEGIN TRANSACTION
				Processa({|| InatComp(Z0G->Z0G_CODIGO)})
			END TRANSACTION
			IF TcSqlExec("DELETE " + RetSqlName("SAL") + " WHERE D_E_L_E_T_ = '*' AND AL_XCHAVE = '" + Z0G->Z0G_CODIGO + "'") > 0
				Aviso("Erro update", TcSqlError(), {"Fechar"}, 3)
			ELSE
				TcRefresh(RetSqlName("SAL"))
			ENDIF
		ENDIF
	ELSEIF aRotina[nOpc, 4] == 4
		IF Z0G->Z0G_STATUS == "3"
			Aviso("Status", "O status atual deste documento n„o permite alteraÁıes.", {"Fechar"})
		ELSE
			AxAltera(cAlias, nReg, nOpc)
		ENDIF
	ELSEIF aRotina[nOpc, 4] == 5
		IF Z0G->Z0G_STATUS # "1"
			Aviso("Status", "N„o È possÌvel excluir documentos onde j· existe ou existiu substituiÁ„o ativa.", {"Fechar"})
		ELSE
			AxDeleta(cAlias, nReg, nOpc)
		ENDIF
	ELSEIF aRotina[nOpc, 4] == 8 .AND. Aviso("Executar JOB", "Esta rotina ir· executar o JOB de substituiÁ„o autom·tica de aprovadores e deve ser executada caso ocorra " + ;
			"falha no agendamento." + CRLF + "Confirma a execuÁ„o?", {"Sim", "N„o"}) == 1
		MsgRun("Aguarde a execuÁ„o do JOB...",, {|| ExeJob()})
	ENDIF
RETURN

STATIC FUNCTION InatComp(cCodigo, lJob)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Inativa o processo de subsituiÁ„o retornando os grupos ‡ situaÁ„o original
	<Data> : 28/04/2014
	<Parametros> : cCodigo, lJob
	cCodigo	: CÛdigo do processo de substituiÁ„o
	lJob	: Se verdadeiro, indica se tratar de processo via job
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cAlias	:= Alias()
	Local cGrpAnt	:= ""
	Local lAchou	:= .f.
	Local cAlTpDoc  := SuperGetMV('MV_ALTPDOC',.F.,.F.)
	Local cCodUsr   := RetCodUsr()
	Local cNomeUsr  := UsrRetName(RetCodUsr())
	Default lJob	:= .f.

	IF !lJob
		ProcRegua(0)
	ENDIF

	DbSelectArea("Z0J")
	DbSetOrder(1)
	DbSeek(xFilial("Z0J") + cCodigo, .f.)
	WHILE !Eof() .AND. xFilial("Z0J") + cCodigo == Z0J->(Z0J_FILIAL + Z0J_CODIGO)
		IF !lJob
			IncProc()
		ENDIF
		IF cGrpAnt # Z0J->Z0J_GRPAPR
			cGrpAnt	:= Z0J->Z0J_GRPAPR

			DbSelectArea("SAL")
			DbSetOrder(3)
			DbSeek(xFilial("SAL") + cGrpAnt+Z0J->Z0J_APROV , .f.)
			WHILE !Eof() .AND. xFilial("SAL") + cGrpAnt+Z0J->Z0J_APROV == SAL->(AL_FILIAL + AL_COD+AL_APROV)
				RecLock("SAL", .f.)
				SAL->AL_XCHAVE	:= cCodigo
				DbDelete()
				MsUnlock()
				FKCOMMIT()
				DbSkip()
			ENDDO
		ENDIF

		SAL->(DbSetOrder(3))
		lAchou	:= DbSeek(xFilial("SAL") + cGrpAnt+Z0J->Z0J_APROV , .f.)
		RecLock("SAL", !lAchou)
		SAL->AL_FILIAL	:= xFilial("SAL")
		SAL->AL_COD		:= Z0J->Z0J_GRPAPR
		SAL->AL_DESC	:= Z0J->Z0J_DESC
		SAL->AL_ITEM	:= Z0J->Z0J_ITEM
		SAL->AL_APROV	:= Z0J->Z0J_APROV
		SAL->AL_USER	:= Z0J->Z0J_USER
		//SAL->AL_NOME	:= Z0J->Z0J_NOME
		SAL->AL_NIVEL	:= Z0J->Z0J_NIVEL
		SAL->AL_LIBAPR	:= Z0J->Z0J_LIBAPR
		SAL->AL_AUTOLIM	:= Z0J->Z0J_AUTOLI
		SAL->AL_TPLIBER	:= Z0J->Z0J_TPLIBE
		SAL->AL_PERFIL  := Z0J->Z0J_PERFIL // Campo incluido para adequacao da nova rotina de Grupos de Aprovacao 12.1.23 j2a.saulo
		If !lAchou
			SAL->AL_DOCAE	:= cAlTpDoc
			SAL->AL_DOCCO	:= cAlTpDoc
			SAL->AL_DOCCP	:= cAlTpDoc
			SAL->AL_DOCMD	:= cAlTpDoc
			SAL->AL_DOCNF	:= cAlTpDoc
			SAL->AL_DOCPC	:= cAlTpDoc
			SAL->AL_DOCSA	:= cAlTpDoc
			SAL->AL_DOCSC	:= cAlTpDoc
			SAL->AL_DOCST	:= cAlTpDoc
			SAL->AL_DOCIP	:= cAlTpDoc
			SAL->AL_DOCCT	:= cAlTpDoc
			SAL->AL_DOCGA	:= cAlTpDoc
			SAL->AL_AGRCNNG	:= cAlTpDoc
		EndIf
		MsUnlock()
		FKCOMMIT()

		RecLock("Z0H", .t.)
		Z0H->Z0H_FILIAL	:= xFilial("Z0H")
		Z0H->Z0H_CODIGO	:= Z0G->Z0G_CODIGO
		Z0H->Z0H_DATA	:= Date()
		Z0H->Z0H_SEQ	:= SeqZ0h(Z0G->Z0G_CODIGO)
		Z0H->Z0H_CODUSR	:= cCodUsr
		Z0H->Z0H_NOMUSR	:= cNomeUsr
		Z0H->Z0H_CDAPSU	:= Z0G->Z0G_SUBST
		Z0H->Z0H_NMAPSU	:= Z0G->Z0G_NOMSUB
		Z0H->Z0H_DATAI	:= Z0G->Z0G_DATAI
		Z0H->Z0H_DATAF	:= Z0G->Z0G_DATAF
		Z0H->Z0H_CDAPPR	:= Z0G->Z0G_APROV
		Z0H->Z0H_NMAPPR	:= Z0G->Z0G_NOMAPR
		Z0H->Z0H_GRPAPR	:= SAL->AL_COD
		Z0H->Z0H_STATUS	:= "FINALIZADO"
		MsUnlock()
		FKCOMMIT()

		DbSelectArea("Z0J")
		DbSkip()
	ENDDO
	RecLock("Z0G", .f.)
	Z0G->Z0G_STATUS	:= "3"
	Z0G->Z0G_USRFIM	:= Iif(lJob, "JOB", UsrRetName(RetCodUsr()))
	Z0G->Z0G_DATFIM	:= Date()
	Z0G->Z0G_HRFIM	:= Time()
	MsUnlock()
	FKCOMMIT()

	IF !Empty(Alltrim(cAlias)) .AND. Select(cAlias) > 0
		DbSelectArea(cAlias)
	ENDIF
RETURN

STATIC FUNCTION AtivComp(cCodigo, cGrupo, cAprOri, cAprDes, lJob)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Ativa o processo de substituiÁ„o de aprovadores
	<Data> : 28/04/2014
	<Parametros> : cCodigo, cGrupo, cAprOri, cAprDes, lJob
	cCodigo	: CÛdigo do processo de substituiÁ„o
	cGrupo	: Grupo de aprovaÁ„o para limitar a substituiÁ„o
	cAprOri	: CÛdigo do aprovador original
	cAprDes	: CÛdigo do aprovador substituto
	lJob	: Se verdadeiro, indica processamento via job
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cQuery	:= ""
	Local cGrpAnt	:= ""
	Local aGrupo	:= {}
	Local aStru		:= {}
	Local nLenStr	:= 0
	Local nLenGrp	:= 0
	Local nPosSub	:= 0
	Local cUsrSub	:= ""
	Local nPosOri	:= 0
	Local cCodNew	:= ""
	Local cNome		:= ""
	Local nI		:= 0
	Local nTotReg	:= 0
	Local cCodUsr   := RetCodUsr()
	Local cNomeUsr  := UsrRetName(RetCodUsr())
	Default lJob	:= .f.

	SAK->(DbSetOrder(1))
	SAK->(DbSeek(xFilial("SAK") + cAprDes, .f.))

	cUsrSub	:= SAK->AK_USER
	cNome	:= SAK->AK_NOME

	cQuery += "SELECT "
	cQuery += "AL_COD, "				// 01
	cQuery += "AL_DESC, "				// 02
	cQuery += "AL_ITEM, "				// 03
	cQuery += "AL_APROV, "				// 04
	cQuery += "AL_USER, "				// 05
	cQuery += "AK_NOME, "				// 06
	cQuery += "AL_NIVEL, "				// 07
	cQuery += "AL_LIBAPR, "				// 08
	cQuery += "AL_TPLIBER, "			// 09
	cQuery += "AK_LIMMIN, "				// 10
	cQuery += "AK_LIMMAX, "				// 11
	cQuery += "AK_APROSUP, "			// 12
	cQuery += "AK_LIMITE, "				// 13
	cQuery += "AK_TIPO, "				// 14
	cQuery += "AK_LIMPED, "				// 15
	cQuery += "AK_FILIAL, "				// 16
	cQuery += "SAL.R_E_C_N_O_ AS REG, "	// 17
	cQuery += "AK_MOEDA, "				// 18
	cQuery += "AL_PERFIL "				// 19
	cQuery += "FROM " + RetSqlName("SAL") + " SAL "
	cQuery += "JOIN " + RetSqlName("SAK") + " SAK "
	cQuery += "ON SAK.D_E_L_E_T_ = ' ' "
	cQuery += "AND AK_FILIAL = '" + xFilial("SAK") + "' "
	cQuery += "AND AK_COD = AL_APROV "
	cQuery += "WHERE SAL.D_E_L_E_T_ = ' ' "
	cQuery += "AND EXISTS ( "
	cQuery += "SELECT 0 FROM " + RetSqlName("SAL") + " SALI "
	cQuery += "WHERE SALI.D_E_L_E_T_ = ' ' and SALI.AL_COD = '"+cAprOri+"' "
	cQuery += "AND SALI.AL_FILIAL = SAL.AL_FILIAL "
	cQuery += "AND SALI.AL_COD = SAL.AL_COD "
	cQuery += "AND SALI.AL_APROV = '" + cAprOri + "') "
	cQuery += "AND AL_FILIAL >= ' ' "
	cQuery += "AND AL_COD " + Iif(Empty(Alltrim(cGrupo)), ">= ' ' ", "= '" + cGrupo + "'") + " "
	cQuery += "ORDER BY AL_FILIAL, AL_COD, AL_NIVEL, AL_ITEM "

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBAL", .F., .T.)

	DbSelectArea("TBAL")
	IF !lJob
		DbGoTop()
		DbEval({|| nTotReg++})
		ProcRegua(nTotReg)
	ENDIF

	aStru	:= DbStruct()
	nLenStr	:= Len(aStru)

	TBAL->(DbGoTop())
	WHILE !TBAL->(Eof())
		IF !lJob
			IncProc()
		ENDIF
		IF cGrpAnt # TBAL->AL_COD
			cGrpAnt	:= TBAL->AL_COD
			aGrupo	:= {}
			nLenGrp	:= 0
			nPosSub	:= 0
			nPosOri	:= 0
		ENDIF

		Aadd(aGrupo, Array(nLenStr))
		nLenGrp++
		AEval(aStru, {|y,z| aGrupo[nLenGrp, z] := TBAL->(FieldGet(z))})
		IF TBAL->AL_USER == cUsrSub
			nPosSub	:= nLenGrp
		ENDIF
		IF TBAL->AL_APROV == cAprOri
			nPosOri	:= nLenGrp
		ENDIF

		DbSelectArea("TBAL")
		TBAL->(DbSkip())

		IF cGrpAnt # TBAL->AL_COD
			BkpGrp(cCodigo, cGrpAnt , cAprOri )

			IF nPosSub == 0
				// ObtÈm o cÛdigo de aprovador do substituto
				cCodNew	:= GetCdNew(cUsrSub, ;		// Usu·rio substituto
				aGrupo[nPosOri, 16], ;	// CÛdigo da filial
				aGrupo[nPosOri, 10], ;	// Limite mÌnimo
				aGrupo[nPosOri, 11], ;	// Limite m·ximo
				aGrupo[nPosOri, 12], ;	// Aprovador superior
				aGrupo[nPosOri, 18], ;	// Moeda
				aGrupo[nPosOri, 13], ;	// Limite perÌodo
				aGrupo[nPosOri, 14], ;	// Tipo
				aGrupo[nPosOri, 15], ;	// Limite pedido
				cNome;					// Nome do aprovador substituto
				)
				// Posiciona no registro do grupo de aprovaÁ„o original
				SAL->(DbGoTo(aGrupo[nPosOri, 17]))

				// Substitui os dados do aprovador original pelo do aprovador substituto
				RecLock("SAL", .f.)
				SAL->AL_APROV	:= cCodNew
				SAL->AL_USER	:= cUsrSub
				SAL->AL_XCHAVE	:= cCodigo
				//SAL->AL_NOME	:= cNome
				MsUnlock()
				FKCOMMIT()

				// Grava o arquivo de histÛrico das manutenÁıes
				RecLock("Z0H", .t.)
				Z0H->Z0H_FILIAL	:= xFilial("Z0H")
				Z0H->Z0H_CODIGO	:= Z0G->Z0G_CODIGO
				Z0H->Z0H_DATA	:= Date()
				Z0H->Z0H_SEQ	:= SeqZ0h(Z0G->Z0G_CODIGO)
				Z0H->Z0H_CODUSR	:= cCodUsr
				Z0H->Z0H_NOMUSR	:= cNomeUsr
				Z0H->Z0H_CDAPSU	:= Z0G->Z0G_SUBST
				Z0H->Z0H_NMAPSU	:= Z0G->Z0G_NOMSUB
				Z0H->Z0H_DATAI	:= Z0G->Z0G_DATAI
				Z0H->Z0H_DATAF	:= Z0G->Z0G_DATAF
				Z0H->Z0H_CDAPPR	:= Z0G->Z0G_APROV
				Z0H->Z0H_NMAPPR	:= Z0G->Z0G_NOMAPR
				Z0H->Z0H_GRPAPR	:= SAL->AL_COD
				Z0H->Z0H_STATUS	:= "SUBSTITUINDO"
				MsUnlock()
				FKCOMMIT()
			ELSE
				//_aVarI := {aGrupo, nPosOri, nPosSub}
				//Aviso( 'VarInfo', VarInfo('_aVarI', _aVarI , , .F. ) ,{'ok'} ,4,,,, .T.)

				IF aGrupo[nPosSub, 07] <= aGrupo[nPosOri, 07]
					SAL->(DbGoTo(aGrupo[nPosOri, 17]))
					RecLock("SAL", .f.)
					DbDelete()
					MsUnlock()
					FKCOMMIT()

					cCodNew	:= GetCdNew(cUsrSub, ;		// Usu·rio substituto
					aGrupo[nPosSub, 16], ;	// CÛdigo da filial
					aGrupo[nPosSub, 10], ;	// Limite mÌnimo
					aGrupo[nPosOri, 11], ;	// Limite m·ximo
					aGrupo[nPosOri, 12], ;	// Aprovador superior
					aGrupo[nPosSub, 18], ;	// Moeda
					aGrupo[nPosSub, 13], ;	// Limite perÌodo
					aGrupo[nPosSub, 14], ;	// Tipo
					aGrupo[nPosSub, 15], ;	// Limite pedido
					cNome;					// Nome do aprovador substituto
					)

					SAL->(DbGoTo(aGrupo[nPosSub, 17]))
					RecLock("SAL", .f.)
					SAL->AL_APROV	:= cCodNew
					//SAL->AL_NIVEL   := aGrupo[nPosOri,07]
					//SAL->AL_PERFIL  := aGrupo[nPosOri,19]
					MsUnlock()
					FKCOMMIT()
				ELSE
					FOR nI := nPosOri TO nPosSub - 1
						SAL->(DbGoTo(aGrupo[nI, 17]))
						RecLock("SAL", .f.)
						DbDelete()
						MsUnlock()
						FKCOMMIT()
					NEXT
					cCodNew	:= GetCdNew(cUsrSub, ;		// Usu·rio substituto
					aGrupo[nPosSub, 16], ;	// CÛdigo da filial
					aGrupo[nPosOri, 10], ;	// Limite mÌnimo
					aGrupo[nPosSub, 11], ;	// Limite m·ximo
					aGrupo[nPosSub, 12], ;	// Aprovador superior
					aGrupo[nPosSub, 18], ;	// Moeda
					aGrupo[nPosSub, 13], ;	// Limite perÌodo
					aGrupo[nPosSub, 14], ;	// Tipo
					aGrupo[nPosSub, 15], ;	// Limite pedido
					cNome;					// Nome do aprovador substituto
					)
					SAL->(DbGoTo(aGrupo[nPosSub, 17]))
					RecLock("SAL", .f.)
					SAL->AL_APROV	:= cCodNew
					SAL->AL_NIVEL   := aGrupo[nPosOri,07]
					SAL->AL_PERFIL  := aGrupo[nPosOri,19]
					MsUnlock()
					FKCOMMIT()
				ENDIF
			ENDIF
		ENDIF
	ENDDO
	TBAL->(DbCloseArea())

// Muda o status do documento de substituiÁ„o
	RecLock("Z0G", .f.)
	Z0G->Z0G_STATUS	:= "2"
	Z0G->Z0G_USREFT	:= Iif(lJob, "JOB", UsrRetName(RetCodUsr()))
	Z0G->Z0G_DATEFT	:= Date()
	Z0G->Z0G_HRATIV	:= Time()
	MsUnlock()
	FKCOMMIT()

/*
VERIFICA SE SUBSTITUTO EST¡ NO GRUPO DO SUBSTITUÕDO
	SE N√O ESTIVER,
		TROCA SUBSTITUÕDO PELO SUBSTITUTO
	
	SE ESTIVER,
		SE O NÕVEL DO SUBSTITUTO FOR MENOR OU IGUAL QUE O NÕVEL DO SUBSTITUÕDO
			REMOVE O SUBSTITUÕDO DA CADEIA E MANT…M O SUBSTITUTO
			ALTERA O LIMITE M¡XIMO DO SUBSTITUTO PARA O LIMITE M¡XIMO DO SUBSTITUÕDO
			
		SE O NÕVEL DO SUBSTITUTO FOR MAIOR QUE O NÕVEL DO SUBSTITUÕDO
			ALTERA O O LIMITE MÕNIMO DO SUBSTITUTO PARA O LIMITE DO SUBSTITUÕDO
			INCLUI A CADEIA NOVAMENTE A PARTIR DO SUBSTITUTO EM ORDEM CRESCENTE DE NÕVEIS
*/

RETURN

STATIC FUNCTION GetCdNew(cUsrSub, cCodFil, nLimMin, nLimMax, cAprvSup, nMoeda, nLimPer, cTipo, nLimPed, cNome)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Retorna o cÛdigo do aprovador substituto baseado nas caracterÌsticas do aprovador original, cadastrando novo se necess·rio
	<Data> : 28/04/2014
	<Parametros> : cUsrSub, cCodFil, nLimMin, nLimMax, cAprvSup, nMoeda, nLimPer, cTipo, nLimPed, cNome
	cUsrSub	: CÛdigo do usu·rio substituto
	cCodFil	: CÛsido da filial do cadastros de aprovador substituÌdo
	nLimMin	: Valor limite mÌnimo
	nLimMax	: Valor limite m·ximo
	cAprvSup: CÛdigo do aprovador superior
	nMoeda	: N˙mero da moeda dos valores de aprovaÁ„o
	nLimPer	: Limite de valor no perÌodo
	cTipo	: Tipo de limite
	nLimPed	: Limite de valor por pedido
	cNome	: Nome do aprovador substituto
	<Retorno> : CÛdigo do aprovador substituto para ser gravado no grupo de aprovaÁ„o
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cRet		:= ""
	Local cAlias	:= Alias()
	Local cQuery	:= ""

//Primeiro vÍ se encontra para o usu·rio com as mesmas caracterÌsticas exigidas pelo original
	cQuery := "SELECT AK_COD "
	cQuery += "FROM " + RetSqlName("SAK") + " SAK "
	cQuery += "WHERE SAK.D_E_L_E_T_ = ' ' "
	cQuery += "AND AK_FILIAL = '" + cCodFil + "' "
	cQuery += "AND AK_USER = '" + cUsrSub + "' "
	cQuery += "AND AK_LIMMIN = " + Str(nLimMin) + " "
	cQuery += "AND AK_LIMMAX = " + Str(nLimMax) + " "
	cQuery += "AND AK_APROSUP = '" + cAprvSup + "' "
	cQuery += "AND AK_MOEDA = " + Str(nMoeda) + " "
	cQuery += "AND AK_LIMITE = " + Str(nLimPer) + " "
	cQuery += "AND AK_TIPO = '" + cTipo + "' "
	cQuery += "AND AK_LIMPED = " + Str(nLimPed) + " "

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBAK", .F., .T.)

	cRet	:= TBAK->AK_COD

	TBAK->(DbCloseArea())

//Sen„o, cadastra um cÛdigo novo com as informaÁıes
	IF Empty(Alltrim(cRet))
		WHILE Empty(cRet) .OR. SAK->(DbSeek(xFilial("SAK") + cRet, .f.))
			cRet	:= GetSxeNum("SAK", "AK_COD")
			ConfirmSx8()
		ENDDO
		RecLock("SAK", .t.)
		SAK->AK_FILIAL	:= xFilial("SAK")
		SAK->AK_COD		:= cRet
		SAK->AK_USER	:= cUsrSub
		SAK->AK_NOME	:= cNome
		SAK->AK_LIMMIN	:= nLimMin
		SAK->AK_LIMMAX	:= nLimMax
		SAK->AK_APROSUP	:= cAprvSup
		SAK->AK_MOEDA	:= nMoeda
		SAK->AK_LIMITE	:= nLimPer
		SAK->AK_TIPO	:= cTipo
		SAK->AK_LIMPED	:= nLimPed
		MsUnlock()
		FKCOMMIT()
	ENDIF

	IF !Empty(Alltrim(cAlias)) .AND. Select(cAlias) > 0
		DbSelectArea(cAlias)
	ENDIF
Return(cRet)

STATIC FUNCTION BkpGrp(cCodigo, cCodGrp , cAprOri)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Faz o backup do grupo de aprovaÁ„o original para preservar as alteraÁıes
	<Data> : 28/04/2014
	<Parametros> : cCodigo, cCodGrp
	cCodigo	: CÛdigo do processo de substituiÁ„o
	cCodGrp	: CÛdigo do grupo para realizar o backup das informaÁıes
	<Retorno> : Nenhum
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cAlias	:= Alias()
	Local lAchou		:= .f.

	Z0J->(DbSetOrder(1))

	SAL->(DbSetOrder(3))
	SAL->(DbSeek(xFilial("SAL") + cCodGrp+cAprOri, .f.))
	WHILE !SAL->(Eof()) .AND. xFilial("SAL") + cCodGrp +cAprOri == SAL->(AL_FILIAL + AL_COD+AL_APROV)
		lAchou	:= Z0J->(DbSeek(SAL->(AL_FILIAL + cCodigo + AL_COD + AL_ITEM), .f.))

		RecLock("Z0J", !lAchou)
		Z0J->Z0J_FILIAL	:= SAL->AL_FILIAL
		Z0J->Z0J_CODIGO	:= cCodigo
		Z0J->Z0J_GRPAPR	:= SAL->AL_COD
		Z0J->Z0J_DESC	:= SAL->AL_DESC
		Z0J->Z0J_ITEM	:= SAL->AL_ITEM
		Z0J->Z0J_APROV	:= SAL->AL_APROV
		Z0J->Z0J_USER	:= SAL->AL_USER
		Z0J->Z0J_NOME	:= Posicione( "SAK" , 2 , xFilial( "SAK" ) + SAL->AL_USER , "AK_NOME" )
		Z0J->Z0J_NIVEL	:= SAL->AL_NIVEL
		Z0J->Z0J_LIBAPR	:= SAL->AL_LIBAPR
		Z0J->Z0J_AUTOLI	:= SAL->AL_AUTOLIM
		Z0J->Z0J_TPLIBE	:= SAL->AL_TPLIBER
		Z0J->Z0J_PERFIL := SAL->AL_PERFIL // Campo incluido para adequacao da nova rotina de Grupos de Aprovacao 12.1.23 j2a.saulo
		FKCOMMIT()

		SAL->(DbSkip())
	ENDDO

	IF !Empty(Alltrim(cAlias)) .AND. Select(cAlias) > 0
		DbSelectArea(cAlias)
	ENDIF
RETURN

USER FUNCTION DtCom01V(nTipo)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Rotina genÈrica de execuÁ„o de validaÁıes do projeto
	<Data> : 28/04/2014
	<Parametros> : nTipo - o tipo indica qual validaÁ„o dever· ser executada
	<Retorno> : LÛgico
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local lRet	:= .t.
	Default nTipo	:= 0

	IF nTipo == 1
		lRet	:= VldDtVig()
	ENDIF
Return(lRet)

STATIC FUNCTION VldDtVig()
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : Valida a digitaÁ„o das datas de vigÍncia da substituiÁ„o
	<Data> : 28/04/2014
	<Parametros> : Nenhum
	<Retorno> : LÛgico
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local lRet	:= .t.

	IF M->Z0G_DATAI > M->Z0G_DATAF .AND. !Empty(M->Z0G_DATAF)
		Aviso("VigÍncia inv·lida", "A data inicial de vigÍncia deve ser menor que a data final!", {"Fechar"})
		lRet	:= .f.
	ENDIF
Return(lRet)

STATIC FUNCTION SeqZ0h(cCodigo)
/*/f/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	<Descricao> : ObtÈm a sequencia do histÛrico de substituiÁ„o de aprovadores
	<Data> : 28/04/2014
	<Parametros> : cCodigo - cÛdigo do processo de aprovaÁ„o
	<Retorno> : Caractere sequencial do log
	<Processo> : AprovaÁ„o de Compras
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
	<Autor> : Marcelo Coutinho
	<Obs> :
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	Local cRet		:= "001"
	Local cQuery	:= ""
	Local cAlias	:= Alias()

	cQuery += "SELECT MAX(Z0H_SEQ) AS Z0H_SEQ "
	cQuery += "FROM " + RetSqlName("Z0H") + " Z0H "
	cQuery += "WHERE Z0H.D_E_L_E_T_ = ' ' "
	cQuery += "AND Z0H_FILIAL = '" + xFilial("Z0H") + "' "
	cQuery += "AND Z0H_CODIGO = '" + cCodigo + "' "
	cQuery += "AND Z0H_SEQ <> ' ' "

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBZ0H", .F., .T.)

	IF !TBZ0H->(Eof())
		cRet	:= Soma1(TBZ0H->Z0H_SEQ)
	ENDIF
	TBZ0H->(DbCloseArea())

	IF !Empty(Alltrim(cAlias)) .AND. Select(cAlias) > 0
		DbSelectArea(cAlias)
	ENDIF
Return(cRet)
