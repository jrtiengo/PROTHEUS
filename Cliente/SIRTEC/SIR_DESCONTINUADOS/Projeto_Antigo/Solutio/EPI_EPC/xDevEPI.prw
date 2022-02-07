#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"


/*/{Protheus.doc} xDevEPI
//Rotina customizada para devolucao de EPI.
@author Celso Rene
@since 10/10/2019
@version 1.0
@type function
/*/
User Function xDevEPI()

Local cAliasX3 := GetNextAlias()

Private oBrw
Private aHead		:= {}
Private cCadastro	:= "TNF"

oBrw := FWMBrowse():New()

aRotina := {}

AADD(aRotina, {"Visualizar"	, "AxVisual"  	, 0	, 2 })
AADD(aRotina, {"Devolver"	, "U_xDevTNF()" , 0	, 6 })
AADD(aRotina, { "Legenda"   , "u_xLegTNF()"	, 1, 0, 6 })


OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,cAliasX3,"SX3",Nil,.F.)
lOpen := Select(cAliasX3) > 0

If lOpen
	dbSelectArea(cAliasX3)
	(cAliasX3)->(dbSetOrder(1))
	(cAliasX3)->(dbSeek("TNF"))
	While ( !(cAliasX3)->(Eof()) .And. (cAliasX3)->X3_ARQUIVO == "TNF" )
		If ( X3USO((cAliasX3)->X3_USADO) .And. cNivel >= (cAliasX3)->X3_NIVEL )
			Aadd(aHead,{ AllTrim((cAliasX3)->X3_TITULO), (cAliasX3)->X3_CAMPO, (cAliasX3)->X3_PICTURE,(cAliasX3)->X3_TAMANHO, (cAliasX3)->X3_DECIMAL,;
			"AllwaysTrue()",(cAliasX3)->X3_USADO, (cAliasX3)->X3_TIPO, (cAliasX3)->X3_ARQUIVO, (cAliasX3)->X3_CONTEXT } )
		EndIf
		(cAliasX3)->(dbSkip())
	EndDo
	(cAliasX3)->(DBCloseArea())
Endif


dbSelectArea("TNF")
dbgotop()

oBrw:SetAlias("TNF")

//SET FILTER TO (!Empty(TNF->TNF_DTRECI))


oBrw:AddLegend("TNF_INDDEV = '2'"  ,"GREEN"  	,"Não Devolvido")
oBrw:AddLegend("TNF_INDDEV = '1'"  ,"RED"    	,"Devolvido") 
oBrw:AddLegend("TNF_INDDEV = '3'"  ,"BR_AMARELO","Em Sol. Armazém")
oBrw:AddLegend("TNF_INDDEV = ' '"  ,"BR_PRETO"  ,"Status não informado") 
oBrw:SetFields(aHead)
oBrw:SetDescription( "EPIs entregues - Fucnionários" )
oBrw:Activate()


Return()


/*/{Protheus.doc} xDevTNF
//Gerar devolucao TNF - (TLW - registro devolucao)
@author Celso Rene
@since 10/10/2019
@version 1.0
@type function
/*/
User Function xDevTNF()

Private oDlg
Private Matricula
Private oButton1
Private oButton2
Private oGet1
Private cGet1 := TNF->TNF_MAT
Private oGet10
Private cGet10 := TNF->TNF_HRENTR
Private oGet11
Private cGet11 := cValtoChar(TNF->TNF_QTDENT)
Private oGet2
Private cGet2 := Posicione("SRA",1,xFilial("SRA") + TNF->TNF_MAT,"RA_NOME")
Private oGet3
Private cGet3 := TNF->TNF_FORNEC
Private oGet4
Private cGet4 := TNF->TNF_LOJA
Private oGet5
Private cGet5 := Posicione("SA2",1,xFilial("SA2") + TNF->TNF_FORNEC + TNF->TNF_LOJA,"A2_NOME")
Private oGet6
Private cGet6 := TNF->TNF_CODEPI
Private oGet7
Private cGet7 := Posicione("SB1",1,xFilial("SB1") + TNF->TNF_CODEPI,"B1_DESC")
Private oGet8
Private cGet8 := TNF->TNF_NUMCAP
Private oGet9
Private cGet9 := DtoC(TNF->TNF_DTRECI)
Private oSay1
Private oSay10
Private oSay11
Private oSay2
Private oSay3
Private oSay4
Private oSay5
Private oSay6
Private oSay7
Private oSay8
Private oSay9

Private aColsEx 	:= {}
Private aCols	 	:= {}
Private nX
Private aHeaderEx 	:= {}
Private aFieldFill 	:= {"TLW_QTDEVO","TLW_LOCAL","TLW_TIPODV","CP_SCOM"}
Private aFields		:= {"TLW_QTDEVO","TLW_LOCAL","TLW_TIPODV","CP_SCOM"}
Private aAlterFields:= {"TLW_QTDEVO","TLW_LOCAL","TLW_TIPODV"}
Private oMSNewGetDados1

//Private _aArea := GetArea()


DEFINE MSDIALOG oDlg TITLE "# Devolução - EPIs entregues por funcionários" FROM 000, 000  TO 380, 500 COLORS 0, 16777215 PIXEL

@ 013, 006 SAY oSay1 PROMPT "Matricula: " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 035 MSGET oGet1 VAR cGet1 SIZE 031, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 013, 076 SAY oSay2 PROMPT "Nome: " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 096 MSGET oGet2 VAR cGet2 SIZE 147, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 036, 006 SAY oSay3 PROMPT "Fornec:" SIZE 032, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 032, 034 MSGET oGet3 VAR cGet3 SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 036, 078 SAY oSay4 PROMPT "Loja:" SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 032, 098 MSGET oGet4 VAR cGet4 SIZE 018, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 036, 128 SAY oSay5 PROMPT "Nome:" SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 032, 147 MSGET oGet5 VAR cGet5 SIZE 095, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 057, 077 SAY oSay6 PROMPT "Desc." SIZE 017, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 054, 023 MSGET oGet6 VAR cGet6 SIZE 049, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 057, 007 SAY oSay7 PROMPT "EPI:" SIZE 015, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 054, 096 MSGET oGet7 VAR cGet7 SIZE 147, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 074, 022 MSGET oGet8 VAR cGet8 SIZE 051, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 078, 008 SAY oSay8 PROMPT "C.A.:" SIZE 015, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 078, 077 SAY oSay9 PROMPT "Entreg:" SIZE 016, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 074, 096 MSGET oGet9 VAR cGet9 SIZE 035, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 078, 138 SAY oSay10 PROMPT "Hora:" SIZE 016, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 074, 157 MSGET oGet10 VAR cGet10 SIZE 035, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 078, 201 SAY oSay11 PROMPT "Qtd.:" SIZE 013, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 074, 215 MSGET oGet11 VAR cGet11 SIZE 027, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

fMSNewGetDados1()
@ 170, 008 BUTTON oButton1 PROMPT "Devolver" SIZE 037, 012 OF oDlg PIXEL ACTION(MsgRun("Processando devolução do E.P.I.","Aguarde...",{|| XExecDev() })) //ACTION(XExecDev())
@ 170, 051 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlg PIXEL ACTION(oDlg:End())
ACTIVATE MSDIALOG oDlg

Return

//------------------------------------------------
Static Function fMSNewGetDados1()
//------------------------------------------------

//Aadd(aHeaderEx, { AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
//SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

Aadd(aHeaderEx, { "QTD.","TLW_QTDEVO","@E 999999999.99",12,2,positivo(),;
"€€€€€€€€€€€€€€","N",,,,})

Aadd(aHeaderEx, { "LOCAL","TLW_LOCAL","@!",2,0,,; //ExistCpo("NNR")
"€€€€€€€€€€€€€€","C","NNR",,,})

Aadd(aHeaderEx, { "ESTOQUE","TLW_TIPODV","@!",1,0,,; //Pertence("SN")
"€€€€€€€€€€€€€€","C",,,"S=Sim;N=Nao","N"})

Aadd(aHeaderEx, { "COMPROVANTE","CP_SCOM","@!",10,0,,; //Pertence("SN")
"€€€€€€€€€€€€€€","C",,,,"C"})


// Define field values
For nX := 1 to Len(aFields)
	//If DbSeek(aFields[nX])
	Aadd(aFieldFill, CriaVar(aFields[nX]))
	//Endif
Next nX
Aadd(aFieldFill, .F.)
//  Aadd(aColsEx, aFieldFill)

aADD( aColsEx,{;
TNF->TNF_QTDENT,;
TNF->TNF_LOCAL,;
"N",;
POSICIONE("SCP",1,XFILIAL("SCP")+ TNF->TNF_NUMSA+TNF->TNF_ITEMSA,"CP_SCOM"),;
.F.;
})

oMSNewGetDados1 := MsNewGetDados():New( 094, 006, 157, 243, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 1, "u_xvlTLW()", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

//RestArea(_aArea)

Return()


Static Function XExecDev()
Local aFunc := {}
Local aItem := {}
Local nOpcao:= 4
Local _aArea:= GetArea()

Private lMSHelpAuto := .T.
Private lMSErroAuto := .F.

Private _aDados	 := {}
Private _aDevPar := {}
Private _aDevEPI := {}

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") + TNF->TNF_CODEPI )

If (SB1->B1_MSBLQL <> "1" .and. aColsEx[1][1] > 0 .and. TNF->TNF_INDDEV == "2" .and. TNF->TNF_QTDENT > TNF->TNF_QTDEVO)
	
	//cmodulo := "MDT"
	//modulo	:= 35
	//nmodulo	:= 35
	
	/*
	aAdd( aFunc, {"RA_MAT", TNF->TNF_MAT, Nil } ) // Array com a chave, setando no funcionário a ser entregue o EPI.
	
	//nao funciona o execauto se nao incluir esse trecho...
	cAliasTLW := GetNextAlias()
	cArquivTLW := ""
	MDT695TLW( @cArquivTLW )
	
	aAdd( aItem, { ;
	{"TNF_FILIAL" , TNF->TNF_FILIAL 	, Nil },;
	{"TNF_FORNEC" , TNF->TNF_FORNEC 	, Nil },;
	{"TNF_LOJA"   , TNF->TNF_LOJA 		, Nil },;
	{"TNF_CODEPI" , TNF->TNF_CODEPI 	, Nil },;
	{"TNF_NUMCAP" , TNF->TNF_NUMCAP  	, Nil },;
	{"TNF_MAT" 	  , TNF->TNF_MAT	    , Nil },;
	{"TNF_DTENTR" , TNF->TNF_DTENTR		, Nil },;
	{"TNF_HRENTR" , tnf->TNF_HRENTR 	, Nil },;
	{"TNF_QTDENT" , TNF->TNF_QTDENT 	, Nil },;
	{"TNF_LOCAL"  , TNF->TNF_LOCAL		, Nil },;
	{"TNF_LOTECTL", TNF->TNF_LOTECTL	, Nil },;
	{"TNF_ENDLOC",  TNF->TNF_ENDLOC     , Nil },;
	{"TNF_SERIE",   TNF->TNF_SERIE      , Nil },;
	{"TNF_INDDEV" , "1"	 				, Nil },;
	{"TNF_TIPODV" , if(aColsEx[1][3]=="S","1","2") 	, Nil },;
	{"TNF_LOCDV"  , aColsEx[1][2] 		, Nil },;
	{"TNF_QTDEVO" , aColsEx[1][1]		, Nil },;
	{"TNF_DTDEVO" ,	dDataBase			, Nil } })
	
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSelectArea("TNF")
	MSExecAuto( {|x,z,y,w| MDTA695(x,z,y,w)} , , aFunc, aItem, nOpcao )
	
	If lMSErroAuto
	MostraErro()
	Else
	MsgInfo("EPI - entregue: "+ Alltrim(TNF->TNF_CODEPI) +" - da matrícula: "+ TNF->TNF_MAT + "!" ,"# EPI Entregue")
	EndIf
	*/
	
	//Begin Trnasaction
	
	RecLock( "TNF" , .F. )
	TNF->TNF_INDDEV 	:= If (TNF->TNF_QTDENT = TNF->TNF_QTDEVO + aColsEx[1][1] ,"1",TNF->TNF_INDDEV )
	TNF->TNF_DTDEVO 	:= dDataBase
	TNF->TNF_TIPODV 	:= if(aColsEx[1][3]=="S","1","2")
	TNF->TNF_LOCDV      := aColsEx[1][2]
	TNF->TNF_QTDEVO     := aColsEx[1][1]
	TNF->(MSUNLOCK())
	
	If (TNF->TNF_TIPODV == "1") 
	
		_nSeq := MdtMovEst("DE0",TNF->TNF_LOCDV,TNF->TNF_CODEPI,TNF->TNF_QTDEVO,dDataBase,"",TNF->TNF_MAT,Nil,Nil,Nil,TNF->TNF_LOTECTL,TNF->TNF_LOTESB,TNF->TNF_ENDLOC,TNF->TNF_SERIE)
		
		dbSelectArea("TLW")
		RecLock( "TLW" , .T. )
		TLW->TLW_FILIAL := xFilial("TLW")
		TLW->TLW_FORNEC := TNF->TNF_FORNEC
		TLW->TLW_LOJA   := TNF->TNF_LOJA
		TLW->TLW_CODEPI := TNF->TNF_CODEPI
		TLW->TLW_NUMCAP := TNF->TNF_NUMCAP
		TLW->TLW_MAT    := TNF->TNF_MAT
		TLW->TLW_DTENTR := TNF->TNF_DTENTR
		TLW->TLW_HRENTR := TNF->TNF_HRENTR
		TLW->TLW_DTDEVO := dDataBase
		TLW->TLW_HRDEVO := TIME()
		TLW->TLW_QTDEVO := TNF->TNF_QTDEVO//Retira a quantidade ja entregue
		TLW->TLW_LOCAL  := TNF->TNF_LOCDV    //if( nPosLcDv == 0 , M->TNF_LOCAL , M->TNF_LOCDV )
		TLW->TLW_TIPODV := TNF->TNF_TIPODV  //Repor estoque.
		TLW->TLW_NUMSEQ := _nSeq
		//TLW->->TLW_ALTERA := "X"
		TLW->(MSUNLOCK())
		
	EndIf            
	
	//End Transaction
	
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(xFilial("SRA") + TNF->TNF_MAT)
	
	//////////////////
	aAdd( _aDados , { "Mv_par01" , SRA->RA_MAT } )
	aAdd( _aDados , { "Mv_par02" , SRA->RA_MAT } )
	aAdd( _aDados , { "Mv_par03" , dDataBase } )
	aAdd( _aDados , { "Mv_par04" , dDataBase } )
	aAdd( _aDados , { "Mv_par05" , 1 } )
	aAdd( _aDados , { "Mv_par09" , SRA->RA_CC } )
	aAdd( _aDados , { "Mv_par10" , SRA->RA_CC } )
	aAdd( _aDados , { "Mv_par11" , 1 } )
	aAdd( _aDados , { "Mv_par12" , 1 } )
	aAdd( _aDados , { "Mv_par13" , SRA->RA_ADMISSA } )
	aAdd( _aDados , { "Mv_par14" , SRA->RA_ADMISSA } )
	aAdd( _aDados , { "Mv_par15" , "" } )
	aAdd( _aDados , { "Mv_par16" , "" } )
	aAdd( _aDados , { "Mv_par17" , 2 } )
	//aAdd( _aDados , { "Mv_par18" , 2 } )
	
	
	aAdd(_aDevPar,{TNF->TNF_FILIAL,TNF->TNF_CODEPI,TNF->TNF_FORNEC,TNF->TNF_LOJA,TNF->TNF_NUMCAP,TNF->TNF_MAT,TNF->TNF_DTENTR,TNF->TNF_HRENTR,dDataBase,time(),aColsEx[1][1] })
	
	aAdd( _aDevEpi , TNF->(Recno()) )
	
	u_xMDTR805( _aDados , ,_aDevEPI , .T. , _aDevPar )
	
	
	MsgInfo("EPI - entregue: "+ Alltrim(TNF->TNF_CODEPI) +" - da matrícula: "+ TNF->TNF_MAT + "!" ,"# EPI Entregue")
	
	//cmodulo := "EST"
	//modulo	:= 04
	//nmodulo	:= 04
	
Else
	MsgAlert("Devolução não permitida!","# Movimento não permitido")
EndIf

RestArea(_aArea)
oDlg:End()

Return()


/*/{Protheus.doc} xvlTLW
//Funcao executada na validacao do campo.
//atualizando informacoes dentro do acols.
@author Celso Rene
@since 14/10/2019
@version 1.0
@type function
/*/
User function xvlTLW()

Local _lRet := .T.

If (TYPE( "M->TLW_TIPODV")=="C")
	If (M->TLW_TIPODV == "")
		MsgAlert("Tipo do movimento inválido!")
		M->TLW_TIPODV	:= "N"
		aCols[n][3]		:= "N"
		aColsEx[n][3]	:= "N"
		_lRet           := .F.
	Else
		aCols[n][3]		:= M->TLW_TIPODV
		aColsEx[n][3]	:= M->TLW_TIPODV
	EndIf
ElseIf (TYPE( "M->TLW_QTDEVO")=="N")
	If ((TNF->TNF_QTDEVO + M->TLW_QTDEVO) > TNF->TNF_QTDENT )
		MsgAlert("Quantidade informada inválida!")
		aCols[n][1]		:= TNF->TNF_QTDENT - TNF->TNF_QTDEVO
		aCols[n][1]		:= TNF->TNF_QTDENT - TNF->TNF_QTDEVO
		M->TLW_QTDEVO   := TNF->TNF_QTDENT - TNF->TNF_QTDEVO
		_lRet           := .F.
	Else
		aCols[n][1]		:= M->TLW_QTDEVO
		aColsEx[n][1]  	:= M->TLW_QTDEVO
	EndIf
ElseIf (TYPE( "M->TLW_LOCAL")=="C")
	dbSelectArea("NNR")
	dbSetOrder(1) //NNR_FILIAL+NNR_CODIGO
	dbSeek(xFilial("NNR") + M->TLW_LOCAL)
	If (Found())
		aCols[n][2]		:= M->TLW_LOCAL
		aColsEx[n][2]  	:= M->TLW_LOCAL
	Else
		MsgAlert("Armazém informado inválido!")
		aCols[n][2]		:= TNF->TNF_LOCAL
		aColsEx[n][2]	:= TNF->TNF_LOCAL
		M->TLW_LOCAL	:= TNF->TNF_LOCAL
		_lRet           := .F.
	EndIf
EndIf


Return(_lRet)


/*/{Protheus.doc} xLegTNF
//Legenda
@author Celso Rene
@since 15/10/2019
@version 1.0
@type function
/*/
User Function xLegTNF()

	BrwLegenda("EPIs entregues - Fucnionários","Legenda"	,{;
	{"ENABLE"       , "Não devolvido"		},;
	{"DISABLE"    	, "Devolvido"  	    	},;
	{"BR_AMARELO"   , "Em Sol. Armazém" 	},;
	{"BR_PRETO"	    , "Status não informado"}})              

Return()          
