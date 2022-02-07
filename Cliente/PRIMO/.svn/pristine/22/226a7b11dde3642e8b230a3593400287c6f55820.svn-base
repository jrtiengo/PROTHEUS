#include "protheus.ch"
#INCLUDE "colors.ch"



/*/{Protheus.doc} TEDA001
Altera parametros MV_ULMES e MV_DBLQMOV    
@type function
@version  
@author solutio
@since 17/05/2021
@return return_type, return_description
/*/
User Function TEDA001()
************************

Local _lRet	:= .T.
Local _cTitTela	:= "Alteração de parametros de Datas"

Private aarray  := pswret()                           
Private aHeader := {}
Private aCols   :=  {}   
Private cDescpar := ""
Private cDescpa1 := ""
Private cDescpa2 := ""              
Private _dDtnew := dDatabase
Private _dDtatu := ""
Private cES_ALTDTCTB := SUPERGETMV("ES_ALTDTCT",.F.,"000246/000123") 

	cDescpar := POSICIONE("SX6",1,xFilial("SX6")+"MV_DATAFIN","X6_DESCRIC")
	cDescpa1 := POSICIONE("SX6",1,xFilial("SX6")+"MV_DATAFIN","X6_DESC1")
	cDescpa2 := POSICIONE("SX6",1,xFilial("SX6")+"MV_DATAFIN","X6_DESC2")
	_dDtatu  := GetMV("MV_DATAFIN")
   	aAdd(aHeader,{ "Parâmetro", "X6_VAR", "@E"	, 010,  0,  ".F." ,  " ",  "C",  " " ,    	,		,		,} )
 
	//aAdd(aCols,{"MV_DATAFIN",.F.})
	//aAdd(aCols,{"MV_DATAFIS",.F.})
	aAdd(aCols,{"MV_DBLQMOV",.F.})
	aAdd(aCols,{"MV_ULMES",  .F.})

//aGrpcont := UsrRetGrp ( UsrRetName(RetCodUsr ( )) , RetCodUsr ( ) )
n:=0
lgrpcont := RetCodUsr() $ cES_ALTDTCTB //.T.
//for n:=1 to len(aGrpcont)
//		
//		if aGrpcont[n] == '000008' 
//		lgrpcont := .T.
//		endif
//
//next n



If substr(aarray[3][34],3,1) <> "X" .or. lgrpcont //Se usuario tiver acesso ao modulo de contabilidade

	DEFINE MSDIALOG oDlgConf TITLE _cTitTela FROM 001,001 TO 271,500 PIXEL
	 
	oGetVis  := MsNewGetDados():New(05, 05, 105, 105,1 , "AllwaysTrue","AllwaysTrue",;
								"",{},0,0,"AllwaysTrue","AllwaysFalse","AllwaysTrue",oDlgconf,aHeader,aCols) 
	 
	 oGetVis:oBrowse:LHSCROLL := .F.
	 oGetVis:oBrowse:LNOHSCROLL := .F.	

	@ 005,110 SAY "Data Atual" SIZE 050,010 PIXEL OF oDlgConf
	@ 005,150 SAY _dDtatu SIZE 050,010 PICTURE "@D 99/99/9999"  PIXEL OF oDlgConf
	@ 020,110 SAY "Informe a nova data" SIZE 050,010 PIXEL OF oDlgConf      
	@ 019,170 MSGET o_nMesAlt	VAR _dDtnew 	SIZE 040,8 PICTURE "@D 99/99/9999" WHEN .T. PIXEL OF oDlgConf 
	@ 034,110 SAY cDescpar SIZE 300,010    PIXEL OF oDlgConf
	@ 044,110 SAY cDescpa1 SIZE 300,010    PIXEL OF oDlgConf
	@ 054,110 SAY cDescpa2 SIZE 300,010    PIXEL OF oDlgConf                                         
	@ 115,015 Button "&Carrega !"	Size 030,012 PIXEL OF oDlgConf Action(CARREGA(oGetVis:oBrowse:NROWPOS))
	@ 115,065 Button "&Atualizar !"	Size 030,012 PIXEL OF oDlgConf Action(iIf(A101ALT(@_dDtnew,acols[oGetVis:oBrowse:NROWPOS][1],oGetVis:oBrowse:NROWPOS),(_lRet:=.T.),Nil))
	@ 115,115 Button "&Sair" 		Size 030,012 PIXEL OF oDlgConf Action(oDlgConf:End())
	
	ACTIVATE MSDIALOG oDlgConf CENTERED

Else
	ApMsgInfo("Seu usuário não possui permissão para efetuar as alterações nos Parâmetros.","ATENÇÃO - "+ProcName())
EndIf

Return(_lRet)

static function CARREGA(nPos)
Private _aArea   	:= GetArea()
cDescpar := ""
oDlgConf:refresh()
	
	_dDtatu  := GetMV(acols[npos][1])
	cDescpar := SX6->X6_DESCRIC
	cDescpa1 := SX6->X6_DESC1
	cDescpa2 := SX6->X6_DESC2

oDlgConf:refresh()
restarea(_aArea)
return

Static Function A101ALT(_dDtnew,_cpar,npos)
*************************

Local _lRet		:= .T.
Local _cIMD101	:= GetArea()



If ApMsgYesNo("Deseja confirmar a alteração do Parâmetros"+_cPAr,"ATENÇÃO - "+ProcName())    


	PutMV(_cPar,dtos(_dDtnew))//Data limite p/ realizacao de operacoes financeiras  
	
	Alert("Parametro Alterado com sucesso","Alteração")
	CARREGA(nPos)
	_dDtnew := dDatabase
	oDlgConf:refresh()
Else
	_lRet	:= .F.
EndIf
              
RestArea(_cIMD101)

Return (_lRet)
