#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#define CRLF Chr(013)+Chr(010)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FuncCompra ºAutor  ³Samuel Schneider   º Data ³  07/28/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para ler cracha do funcionario e informar o preco da  º±±
±±º          ³ compra                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IntegraSys                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FuncCompra()


Local cCadastro := 'Venda por Cracha'
Local cCod := SPACE(150)
Local cValor := Space(150)
Local cFunc := 'Funcionário'
Local _aBrowse  := {}
Local aSize := MsAdvSize()
Local aObjects := {}
Local aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 5, 3}
Local aPosObj := {}
Local _aHeader := {}
Local _a := 0
Local cSpace := Space(11)
Local lGravar := '0'
Private oNome
Private cNome := space(14)
Private cFunc := space(50)
Private oFunc
Private oDlg
Private oValor
Private nValor := 0
Private oVal
Private cVal := 'Valor R$: '
Private cNomeUser := Alltrim(UsrRetName(__CUSERID))
Private bImporta     




AAdd( aObjects, { 100, 50 , .T., .T.,.T.} )
aPosObj := MsObjSize( aInfo, aObjects,.F. )

DEFINE MSDIALOG oDlg TITLE "Venda por Cracha" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL
oTFont := TFont():New('Courier new',,40,.T.)
oTFont1 := TFont():New('Courier new',,40,.T.)

oGroup2:= TGroup():New(10,10,aPosObj[1,4]-190, aPosObj[1,3]+5,'Venda',oDlg,,,.T.)

@ aPosObj[1,1],035 Say cNomeUser SIZE 160,40   OF oDlg PIXEL PICTURE "@!" FONT oTFont1
@ aPosObj[1,1],350 Say ddatabase SIZE 160,40  OF oDlg PIXEL PICTURE "@!" FONT oTFont1


oGroup:= TGroup():New(80,30,aPosObj[1,4]-30, aPosObj[1,3]-20,'Dados Funcionario',oDlg,,,.T.)

@aPosObj[1,1]+80,035 MSGET oNome VAR cNome SIZE 200,40 F3 "SZP" VALID(cFunc := cGetNome(cNome)) OF oDlg PIXEL PICTURE "@!" FONT oTFont
@aPosObj[1,1]+80,260 Say oFunc VAR substr(cFunc,1,40) SIZE 200,30  OF oDlg PIXEL PICTURE "@!" FONT oTFont1
@aPosObj[1,1]+150,035 Say oVal VAR cVal SIZE 350,40  OF oDlg PIXEL PICTURE "@!" FONT oTFont1
@aPosObj[1,1]+150,230 MSGET oValor VAR nValor PICTURE "@E 99,999,999.99" SIZE 200,40 valid(nValor > 0) OF oDlg PIXEL  FONT oTFont

@ aPosObj[1,1]+230,250 BUTTON bImporta PROMPT "Confirma ?" SIZE 100, 30 OF oDlg ACTION (lGravar := _Gravar(cFunc,cNome,nValor),oDlg:End()) PIXEL

SetKey( VK_F10, {|| apmsginfo("Versao: 1.0.3"+CRLF+"Data: "+DtoC(ddatabase)+CRLF+CRLF+;
"Desenvolvido por: Samuel Schneider","Sobre:")})


ACTIVATE DIALOG oDlg CENTERED
If lGravar == '2'
	
	
	U_FuncCompra()
	
ElseIf lGravar == '1'
	
	U_FuncCompra()
	
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FUNCCOMPRAºAutor  ³Microsiga           º Data ³  07/28/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function cGetNome(cCod)

Local cFunc := ''

If !Empty(cCod)
	DbSelectArea('SRA')
	DbSetOrder(27)
	If DbSeek(xFilial('SRA')+Alltrim(cCod))
		
		cFunc := alltrim(SRA->RA_NOME)
		oVal:SetFocus()
		
	Else
		
		MsgInfo('Funcionario não encontrado','Aviso')
		cNome:= space(14)
		oNome:SetFocus()
		return('')
	EndIf
EndIF




Return (cFunc)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FUNCCOMPRAºAutor  ³Microsiga           º Data ³  07/31/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _Gravar(_Func,_Nome,_Valor)

Local cNum := ''
Local lRet := '1'
Local cValor :=  cValToChar(_Valor)


If MsgYesNo('Confirma Gravação','Atenção')

If !Empty(_Func)
	cNum := GETSXENUM("SZP","ZP_NUM")
	
	DbSelectArea('SZP')
	DbSetOrder(1)
	
	If !DbSeek(xFilial()+cNum)
		lRet :='2'
		SZP->(RecLock('SZP',.T.))
		SZP->ZP_FILIAL := xFilial('SZP')
		SZP->ZP_NUM := cNum
		SZP->ZP_MAT := Posicione('SRA',27,xFilial('SRA')+_Nome,'RA_MAT')
		SZP->ZP_NOME := _Func
		SZP->ZP_VALOR := val(cValor)
		SZP->ZP_PAGO := '2'
		SZP->ZP_EMISSAO := dDatabase
		SZP->ZP_CODCRA := cNome
		SZP->ZP_CC := Posicione('SRA',27,xFilial('SRA')+_Nome,'RA_CC')
		SZP->ZP_USER := ALLTRIM(cNomeUser)
		SZP->ZP_HORA := TIME()
		SZP->(MsUnlock())
	EndIf
	
	ConfirmSX8()
	
Else
	MsgInfo('Preencha o codigo do funcionario','Atenção')
	cNome:= space(10)
	oNome:SetFocus()
	lRet := '1'
endif

Else

oValor := SetFocus()
Return
EndIf

Return(lRet)
