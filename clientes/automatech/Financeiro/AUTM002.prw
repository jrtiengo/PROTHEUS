#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAUTM002   บAutor  ณMauro JPC           บ Data ณ  29/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera็ใo de borderos para titulos do Itau com boleto.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AUTM002()

Local cQuery			:= {}
Local aHeader			:= {}
Local aVetor			:= {}
Local aAlter			:= {}
Local oGDSelSol
Local _oBtn1
Local _oBtn2
Local lGera				:=.F.
Local lAtivo			:=.F.
Local lChk				:=.F.
Private oDlg
//Private oDlgc

Private oOk      		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Private oNo      		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO

Private cPerga			:= "AUTM002   "
Private nPerg			:= 1
ValidPerg()
Pergunte(cPerga,.F.)

DEFINE MSDIALOG oDlg TITLE "Gera็ใo de bordero para Itau" From 100,00 To 350,500 OF oMainWnd PIXEL
@ 020, 030 Say "Este programa tem como objetivo gerar borderos   " OF oDlg PIXEL
@ 030, 030 Say "para a gera็ใo de cnab, para titulos que possuem " OF oDlg PIXEL
@ 050, 030 Say "boletos.  " OF oDlg PIXEL
@ 100, 139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerga)
@ 100, 168 BMPBUTTON TYPE 1 ACTION(oDlg:End(),lGera:=.T.)
@ 100, 196 BMPBUTTON TYPE 2 ACTION oDlg:End()
ACTIVATE MSDIALOG oDlg Centered

If lGera

	cQuery := " SELECT E1_NUM, E1_EMISSAO, E1_VENCTO, E1_CLIENTE, E1_VALOR "
	cQuery += " FROM "+RetSqlName("SE1")+" SE1(NoLock) "
	cQuery += " WHERE E1_PORTADO = '341' "
	cQuery += " AND E1_NUMBCO <> '' "
	cQuery += " AND E1_NUMBOR = '' "	
	cQuery += " AND E1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	cQuery += " AND E1_VENCTO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "	
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY E1_NUM "
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "SE1TEMP"



EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTM1371A   บAutor  ณMauro JPC           บ Data ณ  22/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de sele็ใo das solicita็๕es de compras, para a integra-บฑฑ
ฑฑบ          ณ็ใo com a Neogrid.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus10                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TM1371A()

If lGera

	
	DbSelectArea("SC1TEMP")
	DbGoTop()
	Do While !EOF()
		aadd(aVetor,{lChk,SC1TEMP->C1_NUM,SC1TEMP->C1_SOLICIT,SC1TEMP->C1_EMISSAO,SC1TEMP->C1_FMSNEO})
		DbSkip()
	EndDo
	DbSelectArea("SC1TEMP")
	DbCloseArea()
	If Len(aVetor) > 0 //Se houver dados 
		
		Define MSDIALOG oDlgc Title "Solicita็๕es de compras para Neogrid" From 0,0 TO 330,510 Pixel
		@ 030,010 Listbox oLbx Var cVar Fields Header "Marca", "Numero", "Solicitante", "Emissao", "Movimento" ;
		Size 230,095 Of oDlgc Pixel On dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		stod(aVetor[oLbx:nAt,4]),;
		aVetor[oLbx:nAt,5]}}
		@ 125,10 Checkbox oChk Var lChk PROMPT "Marca/Desmarca" Size 60,007 Pixel Of oDlgc ;
		On CLICK(aEval(aVetor,{|x| x[1]:=lChk}),oLbx:Refresh())
		@ 140,015 Say "Pesquisa Matricula" Size 050,032 COLOR CLR_BLACK Pixel Of oDlgc
		@ 155,015 Button "OK" Size 037,012 Pixel Of oDlgc Action(oDlgc:End(),SelaCols(aVetor,"A"))
		@ 155,055 Button "CANCELA" Size 037,012 Pixel Of oDlgc Action(oDlgc:End())
		Activate MSDIALOG oDlgc Centered
	Else
		MsgBox("Nใo hแ dados no perํodo selecionado!")
	EndIf
	
	
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTM1371B   บAutor  ณMicrosiga           บ      ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TM1371B()
Local cQuery			:= {}
Local aHeader			:= {}
Local aVetor			:= {}
Local aAlter			:= {}
Local oGDSelSol
Local _oBtn1
Local _oBtn2
Local lGera				:=.F.
Local lAtivo			:=.F.
Local lChk				:=.F.
Private oDlgd
Private oDlge

Private oOkb      		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Private oNob      		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO

Private cPergb			:= "TMSELFOR  "
Private nPerg			:= 2
ValidPerg()
Pergunte(cPergb,.F.)

DEFINE MSDIALOG oDlgd TITLE "Sele็ใo dos fornecedores" From 100,00 To 350,500 OF oMainWnd PIXEL
@ 020, 030 Say "Este programa tem como objetivo gerar o arquivo XML dos   " OF oDlgd PIXEL
@ 030, 030 Say "fornecedores, que serใo enviadas para a Neogrid." OF oDlgd PIXEL
@ 050, 030 Say "Clique em parโmetros para selecionar a faixa de fornecedores.          " OF oDlgd PIXEL
@ 070, 030 Say "Tipos de movimento: 9 - Inclusใo / 4 - Altera็ใo / 1 - Exclusใo " OF oDlgd PIXEL
@ 100, 139 BMPBUTTON TYPE 5 ACTION Pergunte(cPergb)
@ 100, 168 BMPBUTTON TYPE 1 ACTION(oDlgd:End(),lGera:=.T.)
@ 100, 196 BMPBUTTON TYPE 2 ACTION oDlgd:End()
ACTIVATE MSDIALOG oDlgd Centered

If lGera
	cQuery := " SELECT A2_COD, A2_LOJA, A2_NOME "
	cQuery += " FROM "+RetSqlName("SA2")+" SA2(NoLock) "
	cQuery += " WHERE A2_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	
	If MV_PAR03 == 2 //Lista bloqueados?
		cQuery += " AND A2_MSBLQL <> '1' "
	EndIf
	
	If MV_PAR04 == 1 //Somente ativos
		cQuery += " AND D_E_L_E_T_ <> '*' "
	Else //Somente deletados
		cQuery += " AND D_E_L_E_T_ =  '*' "
	EndIf
	cQuery += " ORDER BY A2_COD "
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "SA2TEMP"
	
	DbSelectArea("SA2TEMP")
	DbGoTop()
	Do While !EOF()
		//aadd(aVetor,{lChk,SA2TEMP->A2_COD,SA2TEMP->A2_LOJA,SA2TEMP->A2_FMSNEO})
		aadd(aVetor,{lChk,SA2TEMP->A2_COD,SA2TEMP->A2_LOJA,SA2TEMP->A2_NOME,"9"})
		DbSkip()
	EndDo
	DbSelectArea("SA2TEMP")
	DbCloseArea()
	If Len(aVetor) > 0 //Se houver dados 
		
		Define MSDIALOG oDlgc Title "Fornecedores para Neogrid" From 0,0 TO 330,510 Pixel
		@ 030,010 Listbox oLbx Var cVar Fields Header "Marca", "Codigo", "Loja", "Nome" ;
		Size 230,095 Of oDlgc Pixel On dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOkb,oNob),;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		aVetor[oLbx:nAt,4]}}
		@ 125,10 Checkbox oChk Var lChk PROMPT "Marca/Desmarca" Size 60,007 Pixel Of oDlgc ;
		On CLICK(aEval(aVetor,{|x| x[1]:=lChk}),oLbx:Refresh())
		@ 140,015 Say "Pesquisa Matricula" Size 050,032 COLOR CLR_BLACK Pixel Of oDlgc
		@ 155,015 Button "OK" Size 037,012 Pixel Of oDlgc Action(oDlgc:End(),SelaCols(aVetor,"B"))
		@ 155,055 Button "CANCELA" Size 037,012 Pixel Of oDlgc Action(oDlgc:End())
		Activate MSDIALOG oDlgc Centered
	Else
		MsgBox("Nใo hแ dados no perํodo selecionado!")
	EndIf
	
	
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSelaCols  บAutor  ณMicrosiga           บ      ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSepara็ใo dos dados selecionados na tela.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus10                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelaCols(aDados,cRot)

Local	nCont	:= 0
Private	aRet	:= {}

For nCont := 1 to len(aDados)
	If aDados[nCont][1]
		IIF(cRot=="A",aadd(aRet,{aDados[nCont][2],aDados[nCont][5]}),aadd(aRet,{aDados[nCont][2],aDados[nCont][3],"9"}))
	EndIf
Next

nCont:=0
//Caso possua dados, gera o xml.
If Len(aRet) > 0
	For nCont := 1 to Len(aRet)
		/*
		//Valida se foi gerado o arquivo de inclusใo do XML de solicita็๕es.
		If ValidIncl(aRet[nCont][1],aRet[nCont][2])
		u_JPC003(aRet[nCont][1],aRet[nCont][2])
		EndIf
		*/
		If cRot == "A"
			U_TM1372(aRet[nCont][1],aRet[nCont][2])
		Else
			U_TM1324(aRet[nCont][1],aRet[nCont][2],aRet[nCont][3])
		EndIf
	Next
	
	MsgBox("Finalizado!!!")
	
Else
	MsgBox("Nใo hแ dados a serem gerados!!!")
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณMicrosiga           บ      ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria็ใo do grupo de perguntas.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus10                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()

cAlias := Alias()
aRegs  :={}


// 			Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerga,"01","Emissใo de		?","","","mv_ch1","D",08,0,0,"G","" ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerga,"02","Emissใo ate	?","","","mv_ch2","D",08,0,0,"G","" ,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerga,"03","Vencimento de	?","","","mv_ch3","D",08,0,0,"G","" ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerga,"04","Vencimento ate	?","","","mv_ch4","D",08,0,0,"G","" ,"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerga,"03","Ativos?				?","","","mv_ch3","N",01,0,0,"C","" ,"        ","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})

DbSelectArea("SX1")
DbSetOrder(1)
For i:=1 to Len(aRegs)
	If !DbSeek(cPerga+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j<=Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

DbSelectArea(cAlias)
Return()