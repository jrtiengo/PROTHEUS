#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"



User Function ATLLETRA()
dbselectarea("SDB")
SDB->(DBGOTOP())
while !SDB->(eof())
	if !alltrim(SDB->DB_NUMSERI) == ""
		
		if !u_soNume2(alltrim(SDB->DB_NUMSERI)) == 0
			RecLock("SDB",.F.)
			SDB->DB_LETRA:= "T"
			MsUnlock()
		else
			RecLock("SDB",.F.)
			SDB->DB_LETRA:= "F"
			MsUnlock()
		endif
	endif
	SDB->(DBskip())
enddo
return

//Funcao para extrair numeros de uma string
User function soNume2(strText)
local _l := 0
local _n := 1
local _x := ""
local _z := 0
local _afindme:={"A","B","C","D","E","F","G","H","I","J","L","M","N","O","P","Q","R","S","T","U","V","X","Z","Y","W","K","/","\"}



_l := len(strText)

for _n:=1 to _l
	_x := substr(strText,_n,1)
	for _y:= 1 to len(_aFindme)
		
		if _aFindme[_y] $ Upper(_x)
			_z++
		
		endif
		_y+=1
	next
	_n += 1
	
next
return (_z)
