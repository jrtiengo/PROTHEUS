#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#include "AP5MAIL.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*/{Protheus.doc}  - SEEDINT
Funcao de integracao Seed / Protheus
@since 01/05/2018
/*/

User Function SEEDINT()

PRIVATE nHndERP := AdvConnection()  //Conecta banco Protheus
PRIVATE cDbExt  := GetSrvProfString("SeedBd","")//"MSSQL/prod_seed" //SEED_VAR
PRIVATE cSrvExt := GetSrvProfString("SeedServ","")//"SRV-BD.atech.local"
PRIVATE nHndSeed := -1
PRIVATE _aOPOK     := {}
PRIVATE _aPVOK     := {}
PRIVATE _aSCOK     := {}
PRIVATE lerros := .F.
Private cIniFile := GetAdv97()
Private cCodEmp  := ""
Private cCodFil  := ""   //Via Schedule
Private _aTabImp := {"SC1","SC2",'SC5','SC6'}
Private cNomeArq := ''

//Abre tabelas necessarias
If !(Type("oMainWnd")=="O")
	cCodEmp := '11'
	cCodFil := '01'
	
	conout("Emp JOB: "+cCodEmp)
	conout("Fil JOB:  "+cCodFil)
	
	RPCSetType(3) //Nao usa licenca
	
	//Abre empresa/filial/modulo/arquivos
	RPCSetEnv(cCodEmp,cCodFil,"","","FAT","",_aTabImp)
ENDIF

nHndERP :=  AdvConnection()

CONOUT(nHndERP)

//Conecta com SEED
nHndSeed := TcLink( cDbExt, cSrvExt, 7890 )

If nHndSeed < 0
	UserException( "Falha ao conectar com " + cDbExt + " em " + cSrvExt )
Endif

//Validacao de e-mail cadastrado no parametro
cmail := AllTrim(GetMV("ZA_SEED1"))

IF EMPTY(cmail)
	ALERT("E-mail nao cadastrado. Favor configurar parametro ZA_SEED1")
	RETURN
ENDIF

conout(':: Executa SEED OP')

U_SEEDOP() //Integra OP

conout(':: SEEDOP -  Qtd. Registros:' + ALLTRIM( STR(LEN(_aOPOK))))

tcSetConn( nHndSeed ) // VOLTA BANCO SEED

if len(_aOPOK) > 0
	for ny := 1 to len(_aOPOK) // ATUALIZA TABELAS SEED
		IF _aOPOK[NY][3] = 'OK'
			cQryUpd := " UPDATE SEED..PLANNEDORDER_INTERFACE "
			cQryUpd += " SET OP_PROTHEUS = "+ "'"+ ALLTRIM (_aOPOK[NY][2])+"'"
			cQryUpd += " ,DATEPROCESSED = GETDATE() "
			cQryUpd += " ,CONTROL = 'R' "
			cQryUpd += " WHERE PLANNEDORDERID = " + "'"+ALLTRIM (_aOPOK[NY][1])+"'"
			TCSQLEXEC(cQryUpd)
		ELSE
			cQryUpd := " UPDATE SEED..PLANNEDORDER_INTERFACE "
			cQryUpd += " SET DATEPROCESSED = GETDATE() "
			cQryUpd += " ,CONTROL = 'R' "
			cQryUpd += " WHERE PLANNEDORDERID = " + "'"+ALLTRIM (_aOPOK[NY][1])+"'"
			TCSQLEXEC(cQryUpd)
			lErros := .T.
		Endif
	next ny
	IF lerros
		envw(_aOPOK,1) // Enviar Email
		lerros := .F.
	ENDIF
endif

conout(':: Executa SEED PV')

U_SEEDPV() //Integra PV

tcSetConn( nHndSeed ) // VOLTA BANCO SEED
conout(':: SEEDPV -  Qtd. Registros:' + ALLTRIM( STR(LEN(_aPVOK))))

if len(_aPVOK) > 0
	for ny := 1 to len(_aPVOK) // ATUALIZA TABELAS SEED
		IF _aPVOK[NY][3] = 'OK'
			cQryUpd := " UPDATE SEED..SALESORDER_INTERFACE "
			cQryUpd += " SET DATEPROCESSED = GETDATE()
			cQryUpd += " ,CONTROL = 'R' "
			cQryUpd += " WHERE SALESORDERID = " + "'"+ALLTRIM(_aPVOK[NY][1])+"'"
			TCSQLEXEC(cQryUpd)
		ELSE
			cQryUpd := " UPDATE SEED..SALESORDER_INTERFACE "
			cQryUpd += " SET DATEPROCESSED = GETDATE() "
			cQryUpd += " ,CONTROL = 'R' "
			cQryUpd += " WHERE SALESORDERID  = " + "'"+ALLTRIM(_aPVOK[NY][1])+"'"
			TCSQLEXEC(cQryUpd)
			lErros := .T.
		Endif
	next ny
	IF lErros
		envw(_aPVOK,2) // Enviar Email
		lErros := .F.
	ENDIF
ENDIF
conout(':: Executa SEED SC')

U_SEEDSC() //Integra SC

tcSetConn( nHndSeed ) // Conecta SEED
conout(':: SEEDSC -  Qtd. Registros:' + ALLTRIM( STR(LEN(_aSCOK))))

if len(_aSCOK) > 0
	for ny := 1 to len(_aSCOK) // ATUALIZA TABELAS SEED
		IF _aSCOK[NY][3] = 'OK'
			cQryUpd := " UPDATE SEED..PURCHASEREQUEST_INTERFACE "
			cQryUpd += " SET DATEPROCESSED = GETDATE()
			cQryUpd += " ,CONTROL = 'R' , NUM_PROTHEUS = "+"'"+ ALLTRIM (_aSCOK[NY][2])+"'"
			cQryUpd += " WHERE REQUESTID = " + "'"+ALLTRIM (_aSCOK[NY][1])+"'"
			TCSQLEXEC(cQryUpd)
		ELSE
			cQryUpd := " UPDATE SEED..PURCHASEREQUEST_INTERFACE "
			cQryUpd += " SET DATEPROCESSED = GETDATE() "
			cQryUpd += " ,CONTROL = 'R' "
			cQryUpd += " WHERE REQUESTID  = " + "'"+ALLTRIM(_aSCOK[NY][1])+"'"
			TCSQLEXEC(cQryUpd)
			lErros := .T.
		Endif
	next ny
	IF lErros
		envw(_aSCOK,3) // Enviar Email
		lErros := .F.
	ENDIF
endif

//Conecta Protheus
tcSetConn( nHndERP )

//Desconecta SEED
TcUnlink( nHndSeed )

Return()

/*/{Protheus.doc}  - SEEDOP
Rotina de Integração OPS - Seed / Protheus
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
/*/

USER FUNCTION SEEDOP()

lOCAL	query_var	:= ""
PRIVATE _aOP       	:= {}  // ARRAY COM AS OPS
PRIVATE cAliasOP	:= "SEEDXXX01"

/*
query_var += " SELECT PlannedOrderID, MaterialID, Quantity, Priority  ,RegType  ,OP_Protheus ,Control, "
query_var += " CONVERT(VARCHAR,EDD, 112) EDD , CONVERT(VARCHAR,IssueDate, 112)IssueDate "
query_var += " ,DateCreated ,DateProcessed , CONVERT(VARCHAR,StartTime, 112)StartTime  "
query_var += " FROM SEED_DEV.PlannedOrder_Interface "
query_var += " WHERE  Control = 'N' "
*/

query_var += " SELECT PLANNEDORDERID, MATERIALID, QUANTITY, PRIORITY  ,REGTYPE  ,OP_PROTHEUS ,CONTROL, "
query_var += " EDD , ISSUEDATE "
query_var += " ,DATECREATED ,DATEPROCESSED , STARTTIME  "
query_var += " FROM SEED..PLANNEDORDER_INTERFACE "
query_var += " WHERE  CONTROL = 'N' "

query_var := ChangeQuery(query_var)

If Select(cAliasOP) <> 0
	(cAliasOP)->(dbCloseArea())
EndIf

dbUseArea(.T.,'TOPCONN', TCGenQry(,,query_var),cAliasOP, .F., .T.)

While (cAliasOP)->(!Eof())
	AADD(_aOp,{;
	(cAliasOP)->PlannedOrderID,;  // 1
	(cAliasOP)->MaterialID,;      // 2
	(cAliasOP)->Quantity,;        // 3
	(cAliasOP)->EDD,;             // 4
	(cAliasOP)->IssueDate,;       // 5
	(cAliasOP)->Priority,;        // 6
	(cAliasOP)->RegType,;         // 7
	(cAliasOP)->OP_Protheus,;     // 8
	(cAliasOP)->Control,;         // 9
	(cAliasOP)->DateCreated,;     // 10
	(cAliasOP)->DateProcessed,;   // 11
	(cAliasOP)->StartTime})  	  // 12
	(cAliasOP)->(dbSkip())
EndDo

If Select(cAliasOP) <> 0
	(cAliasOP)->(dbCloseArea())
EndIf

tcSetConn( nHndERP ) //Conecta Protheus
//TcUnlink( nHndSeed )

IF LEN(_aOp) > 0   //Verifica se existem itens a processar
	FOR NX := 1 TO LEN(_aOp)
		IF  _aOp[NX][7] = 'C' 	// Incluir OP
			U_XMATA650(_aOp,NX,3)// 3 = inclusao
		ELSEIF _aOp[NX][7] = 'U' // Atualizar OP
			U_XMATA650(_aOp,NX,4)// 4 = Alteracao
		ELSEIF _aOp[NX][7] = 'D' // excluir OP
			U_XMATA650(_aOp,NX,5)// 5 = Exclusao
		EndIf
	NEXT NX
EndIf

RETURN()

/*/{Protheus.doc}  XMATA650
Rotina de gravacao OP
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
/*/

User Function  XMATA650(_aOP,N,nTipo)

Local aMATA650 := {}       //-Array com os campos

//nOpc 3 - Inclusao
//nOpc 4 - Alteracao
//nOpc 5 - Exclusao

Local   nOpc            := nTipo
Private lMsHelpAuto 	:= 	.T.
Private lAutoErrNoFile 	:= 	.T.
Private lMsErroAuto 	:= 	.F.
Private aAutoErro		:=	{}

BEGIN TRANSACTION

DbSelectArea('SC2')
SC2->(DbSetOrder(1))

IF nOpc = 3
	cNumOP :=  GetNumSC2() //GETSXENUM("SC2", "C2_NUM")
	AAdd(aMata650,{"C2_FILIAL" , XFILIAL("SC2")  ,Nil})
	AAdd(aMata650,{"C2_ITEM"   , '01'    ,Nil})
	AAdd(aMata650,{"C2_SEQUEN" , '001'  ,Nil})
	AAdd(aMata650,{"C2_NUM"    , cNumOP    ,Nil})
	AAdd(aMata650,{"C2_PRODUTO", _aOp[N][2]  ,Nil})
	AAdd(aMata650,{"C2_LOCAL"  , POSICIONE("SB1",1,XFILIAL("SB1")+_aOp[N][2],"B1_LOCPAD")   ,Nil})
	AAdd(aMata650,{"C2_QUANT"  , _aOp[N][3]   ,Nil})
	AAdd(aMata650,{"C2_UM"     , POSICIONE("SB1",1,XFILIAL("SB1")+ _aOp[N][2],"B1_UM")      ,Nil})
	AAdd(aMata650,{"C2_DATPRI" , _aOp[N][12]   ,Nil})
	AAdd(aMata650,{"C2_DATPRF" , _aOp[N][4]  ,Nil})
	AAdd(aMata650,{"C2_EMISSAO", _aOp[N][5] ,Nil})
	AAdd(aMata650,{"C2_NUMSEED", ALLTRIM(_aOp[N][1])   ,Nil})
	AAdd(aMata650,{"AUTEXPLODE", "S"      ,Nil})
ELSE
	cNumOP := ALLTRIM(_aOp[N][8])
	AAdd(aMata650,{"C2_FILIAL" , XFILIAL("SC2")  ,Nil})
	AAdd(aMata650,{"C2_ITEM"   , '01'    ,Nil})
	AAdd(aMata650,{"C2_SEQUEN" , '001'  ,Nil})
	AAdd(aMata650,{"C2_NUM"    , alltrim(_aOp[N][8])   ,Nil})
	AAdd(aMata650,{"C2_DATPRI" , _aOp[N][12]   ,Nil})
	AAdd(aMata650,{"C2_DATPRF" , _aOp[N][4]  ,Nil})
ENDIF

//Alterar/Excluir posicionar SC2 antes do execauto
If nOpc == 4 .Or. nOpc == 5
	SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
	SC2->(DbSeek(xFilial("SC2")+ PADR(alltrim(_aOp[N][8]), TAMSX3("C2_NUM")[1])+"01"+"001"))
EndIf

msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

If lMsErroAuto
	aAutoErro := GETAUTOGRLOG()
	AADD(_aOPOK, {_aOp[N][1],cNumOP,'ERRO', XCONVERRLOG(aAutoErro)} )
	DisarmTransaction()
Else
	ConfirmSX8()
	AADD(_aOPOK,{ _aOp[N][1],cNumOP,'OK'})
EndIf

END TRANSACTION

Return Nil

/*/{Protheus.doc}
Rotina de ajuste do LOG
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
/*/

Static Function xConverrLog(aAutoErro)
Local cRet := ""
Local _ni   := 1

FOR _ni := 1 to Len(aAutoErro)
	cRet += CRLF+AllTrim(aAutoErro[_ni])
NEXT _ni

RETURN cRet

/*/{Protheus.doc}  -XMATA410
Rotina de alteração pedido de venda - SEED / Protheus
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
/*/

USER FUNCTION SEEDPV()

lOCAL	query_var	:= ""
PRIVATE aPV       	:= {}  // ARRAY COM AS OPS
PRIVATE cAliasPV	:= "SEEDXXX02"

/*
query_var += "SELECT SalesOrderID "
query_var += "     ,SalesItemID	  "
query_var += "     ,MaterialID    "
query_var += "     ,CONVERT(VARCHAR,PlannedDate, 112) PlannedDate "
query_var += "     ,RegType       "
query_var += "     ,Control       "
query_var += "     ,DateCreated   "
query_var += "     ,DateProcessed "
query_var += " FROM SEED_DEV.SalesOrder_Interface "
query_var += " WHERE  Control = 'N' "
query_var += " ORDER BY SalesOrderID, SalesItemID  "
*/

query_var += "SELECT SALESORDERID "
query_var += "     ,SALESITEMID	  "
query_var += "     ,MATERIALID    "
query_var += "     ,PLANNEDDATE "
query_var += "     ,REGTYPE       "
query_var += "     ,CONTROL       "
query_var += "     ,DATECREATED   "
query_var += "     ,DATEPROCESSED "
query_var += " FROM SEED..SALESORDER_INTERFACE "
query_var += " WHERE  CONTROL = 'N' "
query_var += " ORDER BY SALESORDERID, SALESITEMID  "

query_var := ChangeQuery(query_var)

If Select(cAliasPV) <> 0
	(cAliasPV)->(dbCloseArea())
EndIf

dbUseArea(.T.,'TOPCONN', TCGenQry(,,query_var),cAliasPV, .F., .T.)

While (cAliasPV)->(!Eof())
	AADD(aPV,{;
	(cAliasPV)->SalesOrderID,;    //1
	(cAliasPV)->SalesItemID,;	  //2
	(cAliasPV)->MaterialID,;      //3
	(cAliasPV)->PlannedDate,;     //4
	(cAliasPV)->RegType,;         //5
	(cAliasPV)->Control,;         //6
	(cAliasPV)->DateCreated,;     //7
	(cAliasPV)->DateProcessed })  //8
	(cAliasPV)->(dbSkip())
EndDo

If Select(cAliasPV) <> 0
	(cAliasPV)->(dbCloseArea())
EndIf

tcSetConn( nHndERP ) // volta conexao do protheus

cPedido := ''

IF LEN(aPV) > 0   //Verifica se existem itens a processar
	FOR Ni := 1 TO LEN(aPV)
		IF !(ALLTRIM(aPV[Ni][1]) $ cPedido )
			U_XMATA410(aPV,Ni,4)
		ENDIF
		cPedido += 	ALLTRIM(aPV[Ni][1]) + '/'
	NEXT Ni
EndIf

RETURN()

/*/{Protheus.doc}  -XMATA410
Rotina alteracao pedido de venda - Seed / Protheus
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
/*/

USER FUNCTION  XMATA410(aPv,N,nTipo)

LOCAL aItens := {}
LOCAL aLinha := {}
LOCAL aCabec := {}
Private lMsHelpAuto 	:= 	.T.
Private lAutoErrNoFile 	:= 	.T.
Private lMsErroAuto 	:= 	.F.
Private aAutoErro		:=	{}

DBSELECTAREA("SC5")
DBSETORDER(1)
DBSEEK(XFILIAL("SC5")+ALLTRIM(aPv[N][1]))

if ! found()
	AADD(_aPVOK, {aPv[N][1],'','ERRO', "Pedido Nao encontrado: "+ALLTRIM(aPv[N][1]) } )
	return
endif

BEGIN TRANSACTION

aadd(aCabec,{"C5_NUM",SC5->C5_NUM,Nil})
aadd(aCabec,{"C5_TIPO",SC5->C5_TIPO,Nil})
aadd(aCabec,{"C5_CLIENTE",SC5->C5_CLIENTE,Nil})
aadd(aCabec,{"C5_LOJACLI",SC5->C5_LOJACLI,Nil})
aadd(aCabec,{"C5_CONDPAG",SC5->C5_CONDPAG,Nil})

For nB := 1 to len(aPv)
	IF ALLTRIM(aPv[NB][1]) = SC5->C5_NUM
		DBSELECTAREA("SC6")
		SC6->(DBSETORDER(1))
		SC6->(DBSEEK(XFILIAL("SC6")+SC5->C5_NUM+StrZero(aPv[NB][2],2)+aPv[NB][3]))
		IF FOUND()
			NQTDVEN := SC6->C6_QTDVEN
			NPRCVEN := SC6->C6_PRCVEN
			aLinha := {}
			aadd(aLinha,{"LINPOS","C6_ITEM",StrZero(aPv[NB][2],2)})
			aadd(aLinha,{"C6_PRODUTO",aPv[NB][3],Nil})
			aadd(aLinha,{"C6_QTDVEN",NQTDVEN,Nil})
			aadd(aLinha,{"C6_PRCVEN",NPRCVEN,Nil})
			aadd(aLinha,{"C6_VALOR",A410Arred(NQTDVEN *NPRCVEN, "C6_VALOR") ,   ,Nil})
			aadd(aLinha,{"C6_TES",POSICIONE('SC6',1,XFILIAL('SC6')+SC5->C5_NUM+StrZero(aPv[NB][2],2)+aPv[NB][3],'C6_TES'),Nil})
			aadd(aLinha,{"C6_DTSEED",aPv[NB][4],Nil})
			aadd(aLinha,{"AUTDELETA",'N',Nil})
			aadd(aItens,aLinha)
		ENDIF
	endif
Next NB

MATA410(aCabec,aItens,4)

If lMsErroAuto
	aAutoErro := GETAUTOGRLOG()
	AADD(_aPVOK, {aPv[N][1],SC5->C5_NUM,'ERRO', XCONVERRLOG(aAutoErro)} )
	DisarmTransaction()
Else
	AADD(_aPVOK,{ aPv[N][1],SC5->C5_NUM,'OK'})
EndIf

END TRANSACTION

RETURN()

/*/{Protheus.doc}  - SEEDSC
Rotina atualizacao itens solicitacao de compras - Seed / Protheus
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
/*/

USER FUNCTION SEEDSC()

LOCAL 	query_var	:= ""
PRIVATE  aSC        := {}  // ARRAY COM AS OPS
PRIVATE cAliasSC	:= "SEEDXXX03"

/*
query_var += " SELECT RequestID,MaterialID,Quantity, "
query_var += " CONVERT(VARCHAR,EDD, 112) EDD , CONVERT(VARCHAR,IssueDate, 112)IssueDate "
query_var += " ,RegType,Num_Protheus,Control,DateCreated,DateProcessed "
query_var += " FROM SEED_DEV.PurchaseRequest_Interface "
query_var += " WHERE  Control = 'N' "
query_var += " ORDER BY RequestID "    -
*/

query_var += " SELECT REQUESTID,MATERIALID,QUANTITY, "
query_var += " EDD , ISSUEDATE "
query_var += " ,REGTYPE,NUM_PROTHEUS,CONTROL,DATECREATED,DATEPROCESSED "
query_var += " FROM SEED..PURCHASEREQUEST_INTERFACE "
query_var += " WHERE  CONTROL = 'N' "
query_var += " ORDER BY REQUESTID "

query_var := ChangeQuery(query_var)

If Select(cAliasSC) <> 0
	(cAliasSC)->(dbCloseArea())
EndIf

dbUseArea(.T.,'TOPCONN', TCGenQry(,,query_var),cAliasSC, .F., .T.)

While (cAliasSC)->(!Eof())
	AADD(aSC,{;
	(cAliasSC)->RequestID ,;   	//1
	(cAliasSC)->MaterialID,;    //2
	(cAliasSC)->Quantity,;      //3
	(cAliasSC)->EDD,;           //4
	(cAliasSC)->IssueDate,;     //5
	(cAliasSC)->RegType,;       //6
	(cAliasSC)->Num_Protheus,;  //7
	(cAliasSC)->Control,;       //8
	(cAliasSC)->DateCreated,;   //9
	(cAliasSC)->DateProcessed })//10
	
	(cAliasSC)->(dbSkip())
EndDo

If Select(cAliasSC) <> 0
	(cAliasSC)->(dbCloseArea())
EndIf

tcSetConn( nHndERP ) // volta conexao do protheus
//TcUnlink( nHndSeed )

cPedido := ''

IF LEN(aSC) > 0   //Verifica se existem itens a processar
	FOR NX := 1 TO LEN(aSC)
		IF  aSC[NX][6] = 'C' 		// Inclui SC
			U_XMATA110(aSC,NX,3)   	// 3 = inclusao
		ELSEIF aSC[NX][6] = 'U'  	// Altera SC
			U_XMATA110(aSC,NX,4)   	// 4 = Alteracao
		ELSEIF aSC[NX][6] = 'D'     // Exclui SC
			U_XMATA110(aSC,NX,5)	// 3 = Exclusao
		EndIf
	NEXT NX
EndIf

RETURN()

/*/{Protheus.doc}  -XMATA110
Rotina solictacao de compras - Seed / Protheus
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
Regra do sistema SEED - sempre vai ter um item por solicitação
/*/

USER FUNCTION XMATA110(aSC,N,nTipo)

Local aCabec 	:= {}
Local aItens 	:= {}
Local aLinha 	:= {}
Local nX     	:= 0
Local nY     	:= 0
Local cDoc   	:= ""
Local lOk    	:= .T.
Local nOpc      := nTipo
Local cNum 		:= ''
Local SOLICIT	:= ''
Local EMISSAO	:= ''
Local ITEM   	:= ''
Local PRODUTO	:= ''
Local QUANT  	:= ''
Local DATPRF 	:= ''
Local NUMSEED	:= ''
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile	:= .T.
Private lMsErroAuto 	:= .F.
Private aAutoErro		:=	{}

// VERIFICA SE JÁ EXISTE A SOLICITACAO
IF ! EMPTY(ALLTRIM(ASC[N][7]))
	DBSELECTAREA("SC1")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SC1")+ALLTRIM(ASC[N][7]))
	IF FOUND()
		cNum 	:= SC1->C1_NUM
		SOLICIT:= SC1->C1_SOLICIT
		EMISSAO:= SC1->C1_EMISSAO
		ITEM   := SC1->C1_ITEM
		PRODUTO:= SC1->C1_PRODUTO
		QUANT  := SC1->C1_QUANT
		DATPRF := SC1->C1_DATPRF
		NUMSEED:= SC1->C1_NUMSEED
	ENDIF
ENDIF

IF ! EMPTY(CNUM) .AND. nOpc = 3 //verifica se existe a solicitação no Protheus
	AADD(_aSCOK, {aSC[N][1],cDoc ,'ERRO', 'Solicitacao:'+ alltrim(cnum)+ ' já Cadastrada no Protheus' } )
	RETURN()
ENDIF

BEGIN TRANSACTION

IF nOpc = 3  //Incluir
	
	//Verifica numero da SC
	cDoc := GetSXENum("SC1","C1_NUM")
	
	SC1->(dbSetOrder(1))
	
	While SC1->(dbSeek(xFilial("SC1")+cDoc))
		ConfirmSX8()
		cDoc := GetSXENum("SC1","C1_NUM")
	EndDo
	aadd(aCabec,{"C1_NUM"    ,cDoc})
	aadd(aCabec,{"C1_SOLICIT","INTEGRA.SEED"})
	aadd(aCabec,{"C1_EMISSAO",dDataBase})
	aLinha := {}
	aadd(aLinha,{"C1_ITEM"    ,'0001'			 ,Nil})
	aadd(aLinha,{"C1_PRODUTO" ,aSC[n][2]	 ,Nil})
	aadd(aLinha,{"C1_QUANT"   ,aSC[n][3]   ,Nil})
	aadd(aLinha,{"C1_DATPRF"  ,aSC[n][4]   ,Nil})
	aadd(aLinha,{"C1_NUMSEED" ,aSC[n][1]   ,Nil})
	aadd(aItens,aLinha)
ELSEIF nOpc = 4  //Altera
	aadd(aCabec,{"C1_NUM"    ,CNUM})
	aadd(aCabec,{"C1_SOLICIT",SOLICIT })
	aadd(aCabec,{"C1_EMISSAO",EMISSAO})
	aLinha := {}
	aadd(aLinha,{"C1_ITEM"    ,ITEM			 ,Nil})
	aadd(aLinha,{"C1_PRODUTO" ,PRODUTO	 ,Nil})
	aadd(aLinha,{"C1_QUANT"   ,aSC[n][3]   ,Nil})
	aadd(aLinha,{"C1_DATPRF"  ,aSC[n][4]   ,Nil})
	aadd(aItens,aLinha)
ELSEIF nOpc = 5  //Exclui
	aadd(aCabec,{"C1_NUM"    ,CNUM})
	aadd(aCabec,{"C1_SOLICIT",SOLICIT })
	aadd(aCabec,{"C1_EMISSAO",EMISSAO})
	aLinha := {}
	aadd(aLinha,{"C1_ITEM"    ,ITEM				   ,Nil})
	aadd(aLinha,{"C1_PRODUTO" ,PRODUTO	 		   ,Nil})
	aadd(aLinha,{"C1_QUANT"   ,aSC[n][3]  		   ,Nil})
	aadd(aLinha,{"C1_DATPRF"  ,aSC[n][4]   ,Nil})
	aadd(aItens,aLinha)
ENDIF

MSExecAuto({|x,y,z| mata110(x,y,z)},aCabec,aItens,nopc)

If lMsErroAuto
	aAutoErro := GETAUTOGRLOG()
	AADD(_aSCOK, {aSC[N][1],cDoc ,'ERRO', XCONVERRLOG(aAutoErro)} )
	DisarmTransaction()
Else
	AADD(_aSCOK,{ aSC[N][1],cDoc ,'OK'})
EndIf

End TRANSACTION

RETURN()

/*/{Protheus.doc}  -EnvW
Rotina envio de e-mail com erro na integracao- Seed / Protheus
@author SEED SOFTWARE
@since 01/05/2018
@version 1.0
/*/

Static FUNCTION EnvW(_aOPOK,NTP)

Local lResulConn := .T.
Local lRet := .T.
Local cError 	 := ""
Local lResult 	 := .T.
Local cServer 	 := AllTrim(GetMV("MV_RELSERV"))
Local cEmail 	 := AllTrim(GetMV("MV_RELACNT"))   //EMAIL PADRAO ENVIO DE EMAIL - CRIAR PARAMETRO 	- MV_MAILCOB
Local cPass  	 := AllTrim(GetMV("MV_RELPSW"))    //SENHA DO NOVO EMAIL FINANCEIRO - CRIAR PARAMETRO -
Local lRelauth 	 := GetMv("MV_RELAUTH")
Local cDe 		 := cEmail
Local cPara 	 := ""
Local cCc 		 := ""
Local cDescrM 	 := ''
Local _aRetUser  := {}
Local cAssunto 	 := ""
Local cMsg 		 := Space(200)
Local _lJob 	 := .T.
Local aDest 	 := {}
Local cDest 	 := ""
Local aAnexo	 := {}
Local cLogo		 :=""

IF NTP = 1
	cAssunto := "Erros integracao Protheus x SEED - PlannedOrder (OP)"
ELSEIF NTP = 2
	cAssunto := "Erros integracao Protheus x SEED - SalesOrder (PEDIDO DE VENDA)"
ELSEIF NTP = 3
	cAssunto := "Erros integracao Protheus x SEED - PuchaseRequest (Solicitação de Compras )"
ENDIF

cPara :=  AllTrim(GetMV("ZA_SEED1"))

//Compactacao do arquivo
lCompacta := .T.

//Conteudo do E-mail
cHtml := ''
FOR NZ := 1 TO LEN(_aOPOK)
	IF _aOPOK[NZ][3] = 'ERRO'
		cHtml+= "Numero Seed:"+ _aOPOK[NZ][1] + CRLF
		cHtml+= _aOPOK[NZ][4]	+ CRLF
		cHtml+= ' ' + CRLF
	ENDIF
NEXT NZ

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

If !lResulConn
	GET MAIL ERROR cError
	If _lJob
		ConOut(Padc("Falha de conexao "+cError,80))
	Else
		ConOut("Falha de conexao "+cError)
	Endif
	Return(.F.)
Endif

If lRelauth
	lResult := MailAuth(Alltrim(cEmail), Alltrim(cPass))
	If !lResult
		nA := At("@",cEmail)
		cUser := If(nA>0,Subs(cEmail,1,nA-1),cEmail)
		lResult := MailAuth(Alltrim(cUser), Alltrim(cPass))
	Endif
Endif

If lResult
	SEND MAIL FROM cDe TO cPara CC cCC SUBJECT cAssunto BODY  cHtml ATTACHMENT cLogo RESULT lRet
	If !lRet
		GET MAIL ERROR cError
		If _lJob
			ConOut(Padc("Falha no e-mail "+cError,80))
		Else
			ConOut("Falha no e-mail " + cError)
		Endif
	Endif
Else
	If _lJob
		ConOut(Padc("Falha na autenticação do e-mail: "+cError,80))
	Else
		ConOut("Falha na autenticação do e-mail:" + cError)
	Endif
Endif

DISCONNECT SMTP SERVER

IF lRet
	If _lJob
		ConOut(Padc("E-mail enviado com sucesso",80))
	Else
		ConOut("Falha no envio do email" + cError)
	Endif
ENDIF

RETURN lRet