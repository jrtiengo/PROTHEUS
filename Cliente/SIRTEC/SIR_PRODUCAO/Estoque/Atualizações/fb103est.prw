#Include "PROTHEUS.CH"
#Include "RwMake.CH"
#INCLUDE "TBICONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  FB103EST -  Autor ³Rodny Coronel          ³ Data ³16.12.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina para lancamento automatizado de varios registros no  ³±±
±±³          ³Endereçamento de produtos = Ponto de Entrada                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FB103EST()

Local _bGerar
Local _xArmazem
Local _xEndereco
Local _xFilial
Local _xProduto
Local _xQuant
Local _xSaldo
Local _xSequencia
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Static oDlg
Private cxArmazem 	:= Space(40)
Private cxEndereco 	:= Space(40)
Private cxFilial 		:= Space(2)
Private cxProduto 	:= Space(15)
Private cxQuant 		:= Space(6)
Private cxSaldo 		:= 0
Private cxSequencia    := Space(40)


DEFINE MSDIALOG oDlg TITLE "Endereçar Produtos em Série" FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL



@ 005, 056 MSGET _xProduto VAR cxProduto SIZE 114, 013 OF oDlg COLORS 0, 16777215 F3 "SDA" PIXEL
@ 022, 056 MSGET _xSequencia VAR cxSequencia SIZE 114, 013 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 039, 056 MSGET _xSaldo VAR cxSaldo SIZE 114, 013 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 056, 056 MSGET _xArmazem VAR cxArmazem SIZE 114, 013 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 073, 056 MSGET _xFilial VAR cxFilial SIZE 114, 013 OF oDlg COLORS 0, 16777215 READONLY PIXEL

@ 095, 087 MSGET _xEndereco VAR cxEndereco SIZE 073, 013 OF oDlg COLORS 0, 16777215 F3 "SBE" PIXEL
@ 112, 087 MSGET _xQuant VAR cxQuant SIZE 073, 013 OF oDlg COLORS 0, 16777215 PIXEL

@ 005, 027 SAY oSay1 PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 022, 027 SAY oSay2 PROMPT "Sequencial" SIZE 031, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 039, 027 SAY oSay3 PROMPT "Saldo" SIZE 018, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 056, 027 SAY oSay6 PROMPT "Armazem" SIZE 025, 007 OF oDlg COLORS 0, 16777215  PIXEL
@ 073, 027 SAY oSay7 PROMPT "Filial" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 095, 025 SAY oSay4 PROMPT "Endereço de Destino :" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 112, 025 SAY oSay5 PROMPT "Quantidade a Endereçar :" SIZE 062, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 131, 050 BUTTON _bGerar PROMPT "Gerar" SIZE 045, 012 OF oDlg ACTION U_GerarSerie() PIXEL
@ 131, 100 BUTTON _bGerar PROMPT "Cancelar" SIZE 045, 012 OF oDlg ACTION oDlg:End() PIXEL
ACTIVATE MSDIALOG oDlg CENTERED

Return

//---------------------------------

User Function GerarSerie()
Local aCab 		:= {}
Local aItem		:= {}
Local aAuxCab	:= {}
Local aAuxItem	:= {}
//++++++++++++++++++++++++++
local _nSerie  := 0
local _nQuant  := 0
local _nFim    := 0
local _nSeq    := 0
local _nSeqA   := 0
local _cLocal  := ""
local _cProd   := ""
local _cCodbar := ""
Local aArea := GetArea()

Private lMsHelpAuto 	  := .F.
Private lMsErroAuto 	  := .F.

_cProd := cxProduto
_cQuery := "SELECT  CAST(MAX( DB_NUMSERI ) AS INT) as maxSerie, "
_cQuery += "CAST(MAX( DB_NUMSEQ ) AS INT) as maxSeq "
_cQuery += "FROM " + RetSQLName("SDB") + " AS SDB WHERE DB_PRODUTO = '" + _cProd + "' GROUP BY SDB.DB_PRODUTO"

_cQuery := changeQuery(_cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TRB", .F., .T.)

if TRB->maxSerie = 0
	_nSerie := 1
else
	_nSerie := TRB->maxSerie + 1
end if

_nSeq   := TRB->maxSeq + 1
_nQuant := val(cxQuant)
_cLocal := cxEndereco
_cFilial:= cxFilial
_cArmaz := cxArmazem
_nQsaldo:= cxSaldo
_nSeqA  := cxSequencia
_nSaldo := cxSaldo - _nQuant

if _nQuant > _nQsaldo
	Alert("Quantidade a lançar maior que o saldo a endereçar.")
	TRB->(dbCloseArea())
	Return
end if
_nItem  := 1
//++++++++++++++++++++++++++
dbSelectArea("SDA")
dbSetOrder(1)
dbSeek( xFilial("SDA")+cxProduto+cxArmazem+cxSequencia)

/*
aCab:= {	{"DA_FILIAL"	,xFilial("SDA") 	,nil},;
{"DA_PRODUTO"	,_cProd	,NIL},;
{"DA_SALDO"		,_nSaldo	,NIL},;
{"DA_DATA"		,SDA->DA_DATA ,NIL},;
{"DA_QTDORI"	,SDA->DA_QTDORI ,NIL},;
{"DA_DOC"		,SDA->DA_DOC ,NIL},;
{"DA_QTDORI"	,SDA->DA_QTDORI ,NIL},;
{"DA_SERIE"		,SDA->DA_SERIE ,NIL},;
{"DA_CLIFOR"	,SDA->DA_CLIFOR ,NIL},;
{"DA_LOJA"		,SDA->DA_LOJA ,NIL},;
{"DA_TIPONF"	,SDA->DA_TIPONF ,NIL},;
{"DA_ORIGEM"	,SDA->DA_ORIGEM ,NIL},;
{"DA_QTSEGUM"	,SDA->DA_QTSEGUM ,NIL},;
{"DA_QTDORI2"	,SDA->DA_QTDORI2 ,NIL},;
{"DA_LOCAL"		,_cArmaz	,NIL}}

aCab:= {	{"DA_FILIAL"	,xFilial("SDA") 	,nil},;
{"DA_PRODUTO"	,_cProd	,NIL},; 
{"DA_SALDO"		,_nSaldo	,NIL},;      
{"DA_QTDORI"	,SDA->DA_QTDORI ,NIL},;
{"DA_QTSEGUM"	,SDA->DA_QTSEGUM ,NIL},;
{"DA_QTDORI2"	,SDA->DA_QTDORI2 ,NIL},;
{"DA_LOCAL"		,_cArmaz	,NIL}}
*/
aCab:= {	{"DA_PRODUTO"	,_cProd	,NIL},;
			{"DA_SALDO"		,_nSaldo	,NIL}}

//aAuxCab := aClone(u_OrdAuto(aCab))

For I:=1 to 1
	_cSerie := str(_nSerie)
	_cCodbar := PADL( _cProd, 6, "0" ) + strZero(_nSerie,6)
   /*
	aItem := {	{"DB_FILIAL"	,xFilial("SDB")    ,nil},;
	{"DB_ITEM"		,strZero(_nItem,3) ,NIL},;
	{"DB_PRODUTO"	,_cProd			    ,NIL},;
	{"DB_LOCAL"		,_cArmaz			    ,NIL},;
	{"DB_LOCALIZ"	,_cLocal				 ,NIL},;
	{"DB_DATA"		,ddatabase			 ,NIL},;
	{"DB_QUANT"		,1						 ,NIL},;
	{"DB_NUMSERI"	,strZero(_nSerie,6),NIL},;
	{"DB_NUMSEQ"	,cxSequencia		 ,NIL},;
	{"DB_CODBAR"	,_cCodbar			 ,NIL}}
	
	Aadd(aItem, {{"DB_ITEM" ,"0003" ,NIL},;

        {"DB_LOCALIZ" ,"XUXA" ,NIL},;

        {"DB_DATA" ,dDataBase ,NIL},;

        {"DB_QUANT" , 2 ,NIL}})
	
	*/
	
	aADD(aItem , {	{"DB_ITEM"		,strZero(_nItem,4) ,NIL},;
	{"DB_LOCALIZ"	,_cLocal				 ,NIL},;
	{"DB_DATA"		,ddatabase			 ,NIL},;
	{"DB_QUANT"		,1						 ,NIL}})
	
	 
	
//	aadd(aAuxItem, aClone(u_OrdAuto(aItem)))
	
	_nSerie += 1
	_nItem  += 1
	_nSeq   += 1
	
Next

/*
Begin Transaction
dbSelectArea("SDA")
dbSelectArea("SDB")
MSExecAuto({|x,y,z,a| mata265(x,y,z,a)},aAuxCab,aAuxItem,3,.T.)

If lMsErroAuto
	MostraErro()
	DisarmTransaction()
Else
	Alert("Ok Endereçamentos realizados com sucesso!!")
EndIf

End Transaction

conout("processando rotina automática")

MSExecAuto( {| x,y,z| mata265(x,y,z)},aCab,aItem,3)
*/   

conout("processando rotina automática")

MSExecAuto( {| x,y,z| mata265(x,y,z)},aCab,aItem,3) //Distribui



If lMsErroAuto
	MostraErro()
Else
	Conout("Processamento Ok !")
Endif

TRB->(dbCloseArea())
oDlg:End()

Return





#Include "RwMake.CH"

#INCLUDE "TBICONN.CH"


