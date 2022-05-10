#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"



User Function CN140GREV()

Local cAno     := VAL(SubStr( DtoS(     YearSum( ddatabase , 1 )       ), 1, 4 ))//adicinando mais um exercicio para determinar longo
PRIVATE oDlg
Private cContrato    :=PARAMIXB[1]
Private cRevisaoAtu  :=PARAMIXB[2]
Private cRevisaoNew  :=PARAMIXB[3]
Private cTipoRevisao :=PARAMIXB[4]

Private nGet1:=0.00
Private nGet2:=0.00
PRIVATE oFont:= TFont():New("Arial",,14,.T.)
PRIVATE oSay
PRIVATE oSay2
PRIVATE cParTpRev := Getmv( "ES_TIPOREV" )//tipo de revisoes que permitem alterar campos na revisao do contrato
PRIVATE cParTpPg  := Getmv( "ES_TPREVPG" )


cQryUp:=""
cQryUp:=" UPDATE "+RETSQLNAME("CN9")
cQryUp+=" SET CN9_CSILA='' "
cQryUp+=" WHERE CN9_FILIAL='"+xFilial("CN9")+"'"
cQryUp+=" AND CN9_NUMERO  ='"+cContrato+"'"
cQryUp+=" AND CN9_REVISA  ='"+cRevisaoNew+"'"
cQryUp+=" AND D_E_L_E_T_=''"

TcSqlExec(cQryUp)

IF (cTipoRevisao $ (cParTpRev))
	ShowTela()
endif

IF (cTipoRevisao $ (cParTpPg))
	TPREVPG()
ENDIF

Return NIL


// Grava dados da alteracao

STATIC FUNCTION GravaCnd()

dbSelectArea("CN9")
dbsetOrder(1)
dbSeek(xFilial('CN9')+CN9->(CN9_NUMERO+CN9_REVISA),.t.)

cQuery:=" UPDATE "+RETSQLNAME("CN9")+" "
cQuery+=" SET CN9_TXROY  ="+ALLTRIM(str(nGet1))
cQuery+=" ,CN9_VLMIGR ="+ALLTRIM(str(nGet2))
cQuery+=" WHERE CN9_FILIAL='"+xFilial("CN9")+"'"
cQuery+=" AND CN9_NUMERO  ='"+cContrato+"'"
cQuery+=" AND CN9_REVISA  ='"+cRevisaoNew+"'"
cQuery+=" AND CN9_TIPREV  ='"+cTipoRevisao+"'"
cQuery+=" AND D_E_L_E_T_=''"

nRet:=TcSqlExec(cQuery)
If nRet<>0
	Alert(TCSQLERROR())
End
Alert('Alteracao realizada com sucesso!!!')

Close(oDlg)



cQuery:=" UPDATE "+RETSQLNAME("SE2")+" "
cQuery+=" SET E2_NATUREZ =ED_NATCPLP "
cQuery += " FROM "+RetSqlName('SE2')+" SE2 "
cQuery += "  INNER JOIN "+RETSQLNAME("SED")+" SED ON ( SE2.E2_NATUREZ=SED.ED_CODIGO) "
cQuery += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
cQuery += "  AND SE2.E2_PREFIXO='CTR'
cQuery += "  AND SED.D_E_L_E_T_<>'*' "
cQuery += "  AND SE2.D_E_L_E_T_<>'*' "
cQuery += "  AND SE2.E2_TIPO='PR' "
cQuery += "  AND YEAR(SE2.E2_VENCTO)>'"+ALLTRIM(str(cAno))+"' "
cQuery += "  AND SED.ED_NATCLP  ='C' "
cQuery += "  AND SE2.E2_MDCONTR = '"+cContrato+"' "
cQuery += "  AND SE2.E2_MDREVIS = '"+cRevisaoNew+"' "

nRet:=TcSqlExec(cQuery)
If nRet<>0
	Alert(TCSQLERROR())
Endif


// Passando planilhas do cronograma contabil para o longo prazo
cQuery := " UPDATE "+RetSqlName('CNW')
cQuery += " SET CNW_FGEXER='',"
cQuery += " CNW_FGLPCP='L' "
cQuery += " FROM "+RetSqlName('CNW')+" CNW "
cQuery += "	WHERE CNW.CNW_FGLPCP ='' "
cQuery += "   AND SUBSTRING(CNW_DTPREV,1,4)>='"+ALLTRIM(str(cAno))+"' "
cQuery += "	  AND CNW.CNW_FGEXER ='' "
cQuery += "   AND CNW.CNW_CONTRA = '"+cContrato+"' "
cQuery += "   AND CNW.CNW_REVISA = '"+cRevisaoNew+"' "
cQuery += "	  AND CNW.D_E_L_E_T_ <>'*' "

nRet:=TcSqlExec(cQuery)
If nRet<>0
	Alert(TCSQLERROR())
Endif

// Passando planilhas do cronograma contabil para o curto prazo
cQuery := " UPDATE "+RetSqlName('CNW')
cQuery += " SET CNW_FGEXER='',"
cQuery += " CNW_FGLPCP='C' "
cQuery += " FROM "+RetSqlName('CNW')+" CNW "
cQuery += "	WHERE CNW.CNW_FGLPCP ='' "
cQuery += "   AND SUBSTRING(CNW_DTPREV,1,4)<'"+ALLTRIM(str(cAno))+"' "
cQuery += "	  AND CNW.CNW_FGEXER ='' "
cQuery += "   AND CNW.CNW_CONTRA = '"+cContrato+"' "
cQuery += "   AND CNW.CNW_REVISA = '"+cRevisaoNew+"' "
cQuery += "	  AND CNW.D_E_L_E_T_ <>'*' "

nRet:=TcSqlExec(cQuery)
If nRet<>0
	Alert(TCSQLERROR())
Endif

RETURN NIL



STATIC FUNCTION ShowTela()

DEFINE MSDIALOG oDlg FROM 0,0 TO 225,250 PIXEL TITLE 'Editando...'

oSay := TSay():New( 20, 01, {|| "% Royalties......:"},oDlg,, oFont,,,, .T., CLR_BLACK,CLR_WHITE )
oSay:lTransparent:= .F.
oSay2 := TSay():New( 35, 01,{|| "Vlr. Parcela Min.:"},oDlg,, oFont,,,, .T., CLR_BLACK,CLR_WHITE )
oSay2:lTransparent:= .F.

@ 18,65 MSGET oGet1 VAR nGet1 SIZE 40,10 OF oDlg PIXEL PICTURE "@E 999999.99"
@ 32,65 MSGET oGet2 VAR nGet2 SIZE 46,10 OF oDlg PIXEL PICTURE "@E 999999999999.99"
dbSelectArea("CN9")
dbsetOrder(1)
dbSeek(xFilial('CN9')+CN9->(CN9_NUMERO+CN9_REVISA),.t.)
nGet1:=CN9->CN9_TXROY
nGet2:=CN9_VLMIGR
oSButton1 := SButton():New( 70,30,1,{||GravaCnd()},oDlg,.T.,,)
oSButton2 := SButton():New( 70,70,2,{||Close(oDlg)},oDlg,.T.,,)
ACTIVATE MSDIALOG oDlg CENTERED

RETURN NIL

static Function TPREVPG()

PRIVATE oDlg
Private cGet1:='   '
PRIVATE oFont:= TFont():New("Arial",,14,.T.)
PRIVATE oSay
PRIVATE cParTipRevisao:= Getmv( "ES_TPREVPG" )//tipo de revisoes que permitem alterar campos na revisao do contrato
  
   IF (cTipoRevisao $ (cParTipRevisao))
      ShowTela2()
   ENDIF    
             
Return NIL 


// Grava dados da alteracao

STATIC FUNCTION GravaCnd2()
     
  dbSelectArea("CN9")
  dbsetOrder(3)
  cQuery:=" UPDATE "+RETSQLNAME("CN9")+" "
  cQuery+=" SET CN9_CONDPG ='"+cGet1+"'"
  cQuery+=" WHERE CN9_FILIAL='"+xFilial("CN9")+"'"
  cQuery+=" AND CN9_NUMERO ='"+cContrato+"'"
  cQuery+=" AND CN9_REVISA ='"+cRevisaoNew+"'"
  cQuery+=" AND CN9_TIPREV ='"+cTipoRevisao+"'"
  cQuery+=" AND D_E_L_E_T_=''"
		
  nRet:=TcSqlExec(cQuery)			
  If nRet<>0
    Alert(TCSQLERROR())
  End
       
  Alert('Alteracao realizada com sucesso!!!')
                          
  Close(oDlg)


RETURN NIL  



STATIC FUNCTION ShowTela2()
 
DEFINE MSDIALOG oDlg FROM 0,0 TO 304,504 PIXEL TITLE 'Alterando campos do contrato'  
    
	oSay := TSay():New( 20, 01, {|| "Cond. de Pag."},oDlg,, oFont,,,, .T., CLR_BLACK,CLR_WHITE )
    oSay:lTransparent:= .F.
	@ 18,65 MSGET oGet1 VAR cGet1 F3('SE4')SIZE 40,10 OF oDlg PIXEL          
   	oSButton1 := SButton():New( 01,01,1,{||GravaCnd2()},oDlg,.T.,,)      
    ACTIVATE MSDIALOG oDlg CENTERED 

RETURN NIL




