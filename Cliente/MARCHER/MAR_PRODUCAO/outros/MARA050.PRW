#include "protheus.ch"
#INCLUDE "colors.ch"



/*/{Protheus.doc} MARA050
Altera parametros MV_ULMES e MV_DBLQMOV    
@type function
@version  
@author solutio
@since 17/05/2021
@return return_type, return_description
/*/
User Function MARA050()
	************************

	Local _lRet	:= .T.
	Local _cTitTela	:= "Bloqueio de Parâmetros de Datas - (MARA050.PRW)"

	Private aarray  := pswret()
	Private aHeader := {}
	Private aCols   :=  {}
	Private cDescpar := ""
	Private cDescpa1 := ""
	Private cDescpa2 := ""
	Private _dDtnew := dDatabase
	Private _dDtatu := ""
	Private cES_ALTDTCTB := SUPERGETMV("ES_ALTDTCTB",.F.,"000000/000065/000132") //Usuarios com acesso a rotina MARA050, de Bloqueio de Parâmetros de datas
	Private _cParam

	cDescpar := POSICIONE("SX6",1,xFilial("SX6")+"MV_DATAFIN","X6_DESCRIC")
	cDescpa1 := POSICIONE("SX6",1,xFilial("SX6")+"MV_DATAFIN","X6_DESC1")
	cDescpa2 := POSICIONE("SX6",1,xFilial("SX6")+"MV_DATAFIN","X6_DESC2")
	_dDtatu  := GetMV("MV_DATAFIN")
	aAdd(aHeader,{ "Parâmetro", "X6_VAR", "@E"	, 010,  0,  ".F." ,  " ",  "C",  " " ,    	,		,		,} )

	//aAdd(aCols,{"MV_DATAFIN",.F.})
	//aAdd(aCols,{"MV_DATAFIS",.F.})
	aAdd(aCols,{"MV_DBLQMOV",.F.})
	aAdd(aCols,{"MV_ULMES",  .F.})


	_cParam	 := acols[1][1]
	_dDtatu  := GetMV(_cParam)
	cDescpar := SX6->X6_DESCRIC
	cDescpa1 := SX6->X6_DESC1
	cDescpa2 := SX6->X6_DESC2
	_dDtnew  := _dDtatu

	n:=0
	lgrpcont := RetCodUsr() $ cES_ALTDTCTB //.T.

	If substr(aarray[3][34],3,1) <> "X" .or. lgrpcont //Se usuario tiver acesso ao modulo de contabilidade

		DEFINE MSDIALOG oDlgConf TITLE _cTitTela FROM 001,001 TO 271,500 PIXEL

		oGetVis  := MsNewGetDados():New(05, 05, 105, 105,1 , "AllwaysTrue","AllwaysTrue",;
			"",{},0,0,"AllwaysTrue","AllwaysFalse","AllwaysTrue",oDlgconf,aHeader,aCols)

		oGetVis:oBrowse:LHSCROLL := .F.
		oGetVis:oBrowse:LNOHSCROLL := .F.

		@ 005,110 SAY "Parâmetro " + _cParam SIZE 300,010 PIXEL OF oDlgConf
		@ 015,110 SAY "Data Atual" SIZE 050,010 PIXEL OF oDlgConf
		@ 015,170 SAY _dDtatu SIZE 050,010 PICTURE "@D 99/99/9999"  PIXEL OF oDlgConf
		@ 030,110 SAY "Informe a nova data" SIZE 050,010 PIXEL OF oDlgConf
		@ 029,170 MSGET o_nMesAlt	VAR _dDtnew 	SIZE 040,8 PICTURE "@D 99/99/9999" WHEN .T. PIXEL OF oDlgConf
		@ 044,110 SAY cDescpar SIZE 300,010    PIXEL OF oDlgConf
		@ 054,110 SAY cDescpa1 SIZE 300,010    PIXEL OF oDlgConf
		@ 064,110 SAY cDescpa2 SIZE 300,010    PIXEL OF oDlgConf
		@ 115,015 Button "&Carrega !"	Size 030,012 PIXEL OF oDlgConf Action(CARREGA(oGetVis:oBrowse:NROWPOS))
		@ 115,065 Button "&Atualizar !"	Size 030,012 PIXEL OF oDlgConf Action(iIf(A101ALT(@_dDtnew,acols[oGetVis:oBrowse:NROWPOS][1],oGetVis:oBrowse:NROWPOS),(_lRet:=.T.),Nil))
		@ 115,115 Button "&Sair" 		Size 030,012 PIXEL OF oDlgConf Action(oDlgConf:End())

		ACTIVATE MSDIALOG oDlgConf CENTERED

	Else
		ApMsgInfo("Seu usuário não possui permissão para efetuar as alterações nos Parâmetros.","ATENÇÃO - "+ProcName())
	EndIf

Return(_lRet)


/*/{Protheus.doc} CARREGA
Carrega dados do parâmetro
@type function
@version  
@author solutio
@since 01/07/2021
@param nPos, numeric, posição parâmetro no array
/*/
static function CARREGA(nPos)
	Private _aArea   	:= GetArea()
	cDescpar := ""
	oDlgConf:refresh()

	_cParam	 := acols[npos][1]
	_dDtatu  := GetMV(_cParam)
	cDescpar := SX6->X6_DESCRIC
	cDescpa1 := SX6->X6_DESC1
	cDescpa2 := SX6->X6_DESC2
	_dDtnew  := _dDtatu


	oDlgConf:refresh()
	restarea(_aArea)
return



/*/{Protheus.doc} A101ALT
description
@type function
@version  
@author solutio
@since 01/07/2021
@param _dDtnew, variant, Nova Data
@param _cpar, variant, Parâmetro para ser alterado
@param npos, numeric, Posição do parâmetro no array
/*/
Static Function A101ALT(_dDtnew,_cpar,npos)


	Local _lRet		:= .T.
	Local _cIMD101	:= GetArea()

	iF _dDtnew == _dDtatu
		MsgAlert("Data não foi modificada")
		Return .F. 
	Endif

	If ApMsgYesNo("Deseja confirmar a alteração do Parâmetros"+_cPAr,"ATENÇÃO")


		PutMV(_cPar,dtos(_dDtnew))//Data limite p/ realizacao de operacoes financeiras

		MsgAlert("Parametro Alterado com sucesso","Alteração")
		CARREGA(nPos)
		oDlgConf:refresh()
	Else
		_lRet	:= .F.
	EndIf

	RestArea(_cIMD101)

Return (_lRet)
