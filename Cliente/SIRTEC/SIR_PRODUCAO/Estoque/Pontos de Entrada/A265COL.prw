#Include "PROTHEUS.CH"
#Include "RwMake.CH"
#INCLUDE "TBICONN.CH"
User Function A265COL()

If ApMsgNoYes("Você deseja enderecar multiplos itens em série", "Enderecar em Série")
	U_GeraSerie()
endif

Return

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++

User Function GeraSerie()
local _nItem      := 0
local _nSerie  := 0
local _nQuant  := 0
local _nFim    := 0
local _nSeq    := 0
local _nSeqA   := 0
local _dData   := ddatabase
local _cCodSer  := 0
local _cLocal  := ""
local _cProd   := ""
local _cCodbar := ""
Local aArea := GetArea()
Local aColsx := {}

for _x := 1 to len(aCols)
	if aCols[_x,4] > 0
		_nItem                := val(aCols[_x,1])
		_cCodSer            := val(aCols[_x,8])
		aAdd(aColsx, aClone(aCols[_x]))
/*		aAdd(aColsx, {aCols[_x,1],;
		aCols[_x,2],;
		aCols[_x,3],;
		aCols[_x,4],;
		aCols[_x,5],;
		aCols[_x,6],;
		aCols[_x,7],;
		aCols[_x,8],;
		aCols[_x,9],;
		aCols[_x,10],;
		aCols[_x,11],;
		aCols[_x,12],;
		aCols[_x,13],;
		aCols[_x,14],;
		aCols[_x,15],;
		aCols[_x,16],;
		aCols[_x,17],;
		aCols[_x,18],;
		aCols[_x,19],;
		aCols[_x,20],;
		aCols[_x,21],;
		aCols[_x,22]})
*/
	endif
next
_nItem                += 1

if !pergunte("M265BUT",.T.)
	RestArea(aArea)
	Return NIL
Endif

_cProd := alltrim(M->DA_PRODUTO)
_cQuery := "SELECT  RIGHT('000000'+MAX(RTRIM(DB_NUMSERI)),6) as maxSerie "
_cQuery += "FROM " + RetSQLName("SDB") + " AS SDB WHERE LEN(rtrim(DB_NUMSERI)) = 6 AND DB_LETRA <> 'T' AND DB_PRODUTO = '" + _cProd + "' GROUP BY SDB.DB_PRODUTO"

_cQuery := changeQuery(_cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TRB", .F., .T.)


if TRB->maxSerie == nil
	_nSerie := 1
else
	_nSerie := RetAsc(TRB->maxSerie,6,.F.)
	//_nSerie := U_soNum(TRB->maxSerie)
	_nSerie := val(_nSerie)
	_nSerie := _nSerie + 1
end if

_nQuant := MV_PAR02
_cLocal := MV_PAR01

_nAendr := M->DA_SALDO

if _nQuant > _nAendr
	Alert("Quantidade a lançar maior que o saldo a endereçar.")
	Return
end if

DBSELECTAREA("TRB")
DBGOTOP()
_cSerie := str(_nSerie)

For I:=1 to _nQuant
	_cSerie := str(_nSerie)
	_cCodbar := PADL( _cProd, 6, "0" ) + strZero(_nSerie,6)
	
	aAdd(aColsx, {strZero(_nItem,4),"",_cLocal,1,_dData,strZero(_nSerie,6),0,_cCodSer,"",CtoD(""),"","","","","","",_cCodbar,"",0,"","",0,"SDB",0,.F.})
	
	_nSerie += 1
	_nItem  += 1
	_nSeq   += 1
Next


TRB->(dbCloseArea())
RestArea(aArea)

aCols := aclone(aColsx)


Return


//Funcao para extrair numeros de uma string
User function soNum(strText)

local _l := 0
local _n := 1
local _x := ""
local _z := ""

_l := len(strText)

for _n:=1 to _l
	_x := substr(strText,_n,1)
	
	if !Texto(_x)
		_z += _x
	endif
	_n += 1
next

return (_z)
