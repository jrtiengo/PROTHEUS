#include "rwmake.ch"
#include "vkey.ch"

User Function AUTG011(P1)

    U_AUTOM628("AUTG011")
   
	IF p1 == "ADZ"
	   SetKey( VK_F4, { || U_AUTF4("ADZ")} )
	   _nCodigo := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "ADZ_PRODUT"})
	ELSEIF p1 == "SUB"
	   SetKey( VK_F4, { || U_AUTF4("SUB")} )
	   _nCodigo := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "UB_PRODUTO"})
	ENDIF

Return(Acols[n][_nCodigo])

User Function AUTF4(p1)

	Local _nCodigo := 0
	Local _cField  := READVAR()

	IF p1 == "ADZ" .and. Alltrim(_cField) == "M->ADZ_QTDVEN"
	   _nCodigo := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "ADZ_PRODUT"})
	ELSEIF p1 == "SUB" .and. Alltrim(_cField) == "M->UB_QUANT"
	   _nCodigo := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "UB_PRODUTO"})
	ENDIF

	IF _nCodigo > 0
	   MaViewSB2( Acols[n][_nCodigo] )
	ENDIF

Return NIL
