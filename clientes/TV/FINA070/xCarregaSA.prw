#INCLUDE "PROTHEUS.CH"

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CARREGASA6

Validação genérica de Banco Agência e C/C.
Arquivo original: MATXFUNA.PRX

@Author	Wagner Xavier
@since 21/03/1996
/*/
//-----------------------------------------------------------------------------------------------------
user Function xCarregaSa(cBanco,cAgencia,cConta,lHelp,cBenef100,lValidBloq,cNatureza, cMoeda,lSitef, cOldBanco, cOldAgenc,cOldConta, cChmSA6)
Local cAlias	:= Alias()
Local cChave	:= ""
Local lRet		:=.T.
Local nTamBen	:= Iif(cBenef100=NIL,0,Len(cBenef100))
Local lBenefi	:= .T.
Local lFinBenef	:= Existblock ("FINBENEF")
Local lChmPor	:= .T.

Default cBanco		:= ""
Default cAgencia	:= ""
Default cConta		:= ""
Default lHelp		:= .T.
Default cBenef100	:= ""
Default lValidBloq  := .F.
Default cMoeda		:= ""
Default cNatureza	:= ""
Default lSitef 		:= .F.
Default cOldBanco	:= ""
Default cOldAgenc   := ""
Default cOldConta	:= ""
Default cChmSA6		:= ""

If cChmSA6 = "cChmBco"
	If !Empty(cBanco) .And. Empty(cAgencia) .And. Empty(cConta)
		cChave:= cBanco
		If !SA6->(DbSeek(xFilial("SA6")+cChave))
			Help(" ",1,"FA100BCO")
			Return .F.
		EndIf
		cAgencia := ""
		cConta   := ""
	ElseIf cBanco <> cOldBanco .And. !Empty(cAgencia) .And. !Empty(cConta)
		If cAgencia <> cOldAgenc .And. cConta <> cOldConta
			cChave:= cBanco + cAgencia + cConta
			If !SA6->(DbSeek(xFilial("SA6")+cChave))
				Help(" ",1,"FA100BCO")
				Return .F.
			EndIf
			lChmPor		:= .F.
			cOldBanco := cBanco
			cOldAgenc := cAgencia
			cOldConta := cConta
		Else
			cChave:= cBanco
			cOldBanco := cBanco
			lChmPor		:= .F.
		EndIf
	EndIf
ElseIf cChmSA6 = "cChmAge"
	If cBanco = cOldBanco .And. cAgencia <> cOldAgenc
		cChave:= cBanco + cAgencia
		If !SA6->(DbSeek(xFilial("SA6")+cChave))
			Help(" ",1,"FA100BCO")
			Return .F.
		EndIf
		lChmPor	  := .F.
		cOldBanco := cBanco
		cOldAgenc := cAgencia
	ElseIf cBanco = cOldBanco .And. cAgencia = cOldAgenc .And. cConta <> cOldConta
		cChave:= cBanco + cAgencia
		lChmPor	  := .F.
		cOldBanco := cBanco
		cOldAgenc := cAgencia
	ElseIf cBanco <> cOldBanco .And. cAgencia <> cOldAgenc .And. cConta = cOldConta
		cChave:= cBanco + cAgencia + cConta
		If !SA6->(DbSeek(xFilial("SA6")+cChave))
			Help(" ",1,"FA100BCO")
			Return .F.
		EndIf
		lChmPor	  := .F.
		cOldBanco := cBanco
		cOldAgenc := cAgencia
		cOldConta := cConta
	EndIf
ElseIf cChmSA6 = "cChmCta"
	If cBanco = cOldBanco .And. cAgencia = cOldAgenc .And. cConta <> cOldConta
		cChave:= cBanco + cAgencia + cConta
		If !SA6->(DbSeek(xFilial("SA6")+cChave))
			Help(" ",1,"FA100BCO")
			Return .F.
		EndIf
		lChmPor	  := .F.
		cOldBanco := cBanco
		cOldAgenc := cAgencia
		cOldConta := cConta
	Else 
		cChave:= cBanco + cAgencia + cConta
		If !SA6->(DbSeek(xFilial("SA6")+cChave))
			Help(" ",1,"FA100BCO")
			Return .F.
		EndIf
		lChmPor	  := .F.
	Endif
Else
	If FunName() == 'FINA110' .And. !Empty(cAgencia) .And. !Empty(cConta) .AND. (cBanco <> cOldBanco .OR. cAgencia <> cOldAgenc .OR. cConta <> cOldConta) .AND. SA6->(DbSeek(xFilial("SA6")+ cBanco + cAgencia + cConta))// Quando alterado banco, agência e conta via F3
		cChave := cBanco + cAgencia + cConta
	Else
		If cOldBanco <> cBanco .And. cOldBanco <> ""
			cAgencia := ""
			cConta   := ""
		ElseIf cOldAgenc <> cAgencia .And. cOldAgenc <> ""
			cConta := ""
		EndIf
	EndIf
Endif

If lChmPor
	cChave:= cBanco+Iif(Empty(cAgencia),"",cAgencia)+Iif(Empty(cConta),"",cConta)
Endif
nTamBen := Len(cBenef100)

lHelp := Iif( lHelp=Nil,.T.,lHelp)
cFilOld:= cFilAnt
If !(FunName() $ "FINA091") .AND. !lSitef
	cFilAnt:= SM0->M0_CODFIL
Endif
DbSelectArea("SA6")
DbSetOrder(1)

If FunName() $ "FINA080|FINA750"
	If Type("oBanco") == "O"
		If oBanco:lModiFied
			cChave:=cBanco+IIF(!Empty(cAgencia),cAgencia,"")+IIF(!Empty(cConta),cConta,"")
			If DbSeek(cFilial+cChave)
				If cAgencia<>SA6->A6_AGENCIA
					cAgencia:=SA6->A6_AGENCIA
					cConta:=SA6->A6_NUMCON
				Else
					If cConta<>SA6->A6_NUMCON
						cConta:=SA6->A6_NUMCON
					EndIf
				EndIf
			Else
				cAgencia:=""
				cConta:=""
				cChave:=cBanco
			EndIf
		Endif
	EndIf
EndIf

If FunName() $ "FINA080|FINA750"
	If Type("oAgencia") == "O"
		If oAgencia:lModiFied
			cChave:=(cBanco+cAgencia+cConta)
			If DbSeek(cFilial+cChave)
				If cConta<>SA6->A6_NUMCON
					cConta:=SA6->A6_NUMCON
				Endif
			Else
			cConta:=""
		EndIf
		EndIf
  	EndIf
EndIf

If !DbSeek(xFilial("SA6")+cChave)
	lRet := .F.
	If lHelp
		Help(" ",1,"FA100BCO")
	EndIf
Else
	cBanco		:= Iif(cBanco	== NIl .or.  Empty( cBanco ),  SA6->A6_COD,     cBanco )
	cAgencia	:= Iif(cAgencia == NIl .or. Empty( cAgencia ), SA6->A6_AGENCIA	, cAgencia )
	cConta		:= Iif(cConta   == Nil .or. Empty( cConta   ), SA6->A6_NUMCON	, cConta   )
	If cPaisLoc == "BRA" .And. SA6->A6_MOEDA > 0
		cMoeda := SA6->A6_MOEDA
	EndIf
EndIf

cOldBanco := cBanco
cOldAgenc := cAgencia
cOldConta := cConta
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o nome do beneficiario, caso banco destino  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Carrega o nome do beneficiario, caso banco destino
If	lFinBenef
	lBenefi := ExecBlock ("FINBENEF",.F.,.F.)
Endif

If lRet .and. cBenef100 != Nil .and. lBenefi   // FINA100
	cBenef100 := Padr(SUBSTR(SM0->M0_NOMECOM,1,nTamBen),nTamben)
EndIf

If lRet .And. lValidBloq
	If SA6->A6_BLOCKED == "1"  //Conta Bloqueada
		Help(" ",1,"CCBLOCKED",,"STR0091",1,0)
		lRet := .F.
	ElseIf FieldPos("A6_MSBLQL") > 0 .And. SA6->A6_MSBLQL == "1" // campo de bloqueio ativado e banco bloqueado
		Help(" ",1,"REGBLOQ",,,1,0)
		lRet := .F.
	Endif
EndIf

If lRet .and. ExistBlock("PE_LOADSA6")
	cNatureza := Execblock("PE_LOADSA6",.F.,.F.)
EndIf
cFilAnt:=cFilOld
DbSelectArea( cAlias )
Return lRet
