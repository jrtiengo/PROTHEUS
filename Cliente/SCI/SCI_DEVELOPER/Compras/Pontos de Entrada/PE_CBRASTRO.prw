#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'apvt100.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³CBRASTRO  ºAutor  ³Microsiga           º Data ³  29/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CBRastro()

//aRetAux := ExecBlock("CBRastro",.F.,.F.,{cProduto,cLote,cSubLote,dValid})
Local aArea    := GetArea()
Local aAreaSB8 := SB8->(GetArea())
Local aRet     := {Paramixb[2],Paramixb[3],PAramixb[4]} 
Local aSave
Local cLote    := Space(TamSx3("D1_LOTECTL")[1])
//Local cCodEmp := "01"
//Local cCodFil := "0101"
DEFAULT lEmpty		:= .F.
DEFAULT lNextLote 	:= .F.

//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " Inicio ParamIxb[1]  " + ParamIxb[1]   )
//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " Inicio ParamIxb[2]  " + ParamIxb[2]   )
//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " Inicio ParamIxb[3]  " + ParamIxb[3]   )
//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " Inicio ParamIxb[4]  " + dtoc(ParamIxb[4])   )

//VTClear()
//VTSetSize(18,32)

//RpcClearEnv()
//RpcSetType( 3 )
//RpcSetenv( cCodEmp, cCodFil,,,,GetEnvServer(),{"SB8"} )

aSave := VTSAVE()

While .T.

	//aSave := VTSAVE()
	VTClear()
	//VTClearBuffer()
	@ 0,0 VTSay "Rastro SCI"
	@ 2,0 VtSay "Lote"
	@ 3,0 VtGet cLote valid If(lEmpty,.t.,!Empty(cLote).Or. lNextLote) when Empty(cLote)
	VTRead

	If VTLastKey() == 27
		VTAlert("Lote invalido","Aviso",.t.,3000) 
		Return(aRet)
	EndIf

	dbSelectArea("SB8")
	dbSetOrder(5)//Filial + Produto + LoteCtl
	If dbSeek(xFilial("SB8")+paramixb[1]+cLote,.f.)	
		//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " Achou Lote  " +  dtoc(SB8->B8_DTVALID)   )
		aRet[1] := cLote
		aRet[2] := ''
		aRet[3] := SB8->B8_DTVALID
		Exit
	Else
		VTBeep(4)
		VTAlert("Lote nao encontrado.","Alerta",.T.,3000)
		Loop
	EndIf
	
	
	//VtRestore(,,,,aSave)

EndDo

//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " aRet[1]  " + aRet[1]   )
//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " aRet[1]  " + aRet[2]   )
//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " aRet[1]  " + aRet[3]   )
//Conout("CBRASTRO " + dtoc(Date()) + " " + Time() + " " + " Len aRet  " + Alltrim(Str(Len(aRet)))   )
VtRestore(,,,,aSave)

RestArea(aAreaSB8)
RestArea(aArea)
Return(aRet)