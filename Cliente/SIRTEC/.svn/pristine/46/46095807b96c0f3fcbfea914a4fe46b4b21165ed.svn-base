#include "rwmake.ch"

User Function PADRAO()

_cAlias:=Alias()

_xHrs020:=0
_xVal020:=0
_xHrs111:=0
_xVal111:=0
_xHrsPdr:=0
_xValPdr:=0

_xHrsMes:=SRA->RA_HRSMES
_xHrs111:=fBuscaPD("111","H")  // total de HOras Atestado
_xVal111:=fBuscaPD("111")      //total do valor da Verba de Atestado 
_xHrs109=fBuscaPD("109","H")  // total de HOras Atestado
_xVal109:=fBuscaPD("109")      //total do valor da Verba de Atestado
_xHrs133:=fBuscaPD("133","H")  // total de HOras Atestado
_xVal133:=fBuscaPD("133")      //total do valor da Verba de Atestado
_xHrs109:=fBuscaPD("109","H")  // total de HOras Atestado
_xVal109:=fBuscaPD("109")      //total do valor da Verba de Atestado
_xHrs144:=fBuscaPD("144","H")  // total de HOras Atestado
_xVal144:=fBuscaPD("144")      //total do valor da Verba de Atestado
_xHrs118:=fBuscaPD("118","H")  // total de HOras Atestado
_xVal118:=fBuscaPD("118")      //total do valor da Verba de Atestado

If SRA->RA_CATFUNC == "M"
	_xHrs020:=fBuscaPD("020","H")
	_xVal020:=fBuscaPD("020")
    _xPadrao:=((_xHrsMes/30)*_xHrs020)
    _xHrsPdr:=(_xPadrao - _xHrs111 )
    _xValPdr:=(_xVal020 - _xVal111 )
    fDelPD("020")
    fGeraVerba("020",_xValPdr,_xHrsPdr,,,,,,,,.T.)
ElSeIf SRA->RA_CATFUNC == "H"
	_xHrs021:=fBuscaPD("021","H")
	_xVal021:=fBuscaPD("021")
    _xPadrao:=_xHrs021
    _xHrsPdr:=(_xPadrao - _xHrs111)
    _xValPdr:=(_xVal021 - _xVal111)
    fDelPD("021")
    fGeraVerba("021",_xValPdr,_xHrsPdr,,,,,,,,.T.)    //mv_insalvh
Endif

DbSelectArea(_cAlias)

return
