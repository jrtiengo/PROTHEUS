#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCHVNFE   บ Autor ณCelso - Mauro       บ Data ณ  29/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se a nf eh da especie sped e se a chave nfe estah   บฑฑ
ฑฑบ          ณ preenchida.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 			                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MT103DNF()

Local lTrueOr:= .T.
LOCAL cFcgc:=""
LOCAL cFest:=""
local cest:="99"
local aEst:={"11RO","12AC","13AM","14RR","15PA","16AP","17TO","21MA","22PI","23CE","24RN","25PB","26PE","27AL","28SE","29BA","31MG","32ES","33RJ","35SP","41PR","42SC","43RS","50MS","51MT","52GO","53DF"}

LOCAL cCHV:= paramixb[1][13] //Chave nfe  //F1_CHVNFE

LOCAL cDemissao:= DTOS(DDEMISSAO) // CONVERTE EMISSAO

    U_AUTOM628("MT103DNF")

IF ALLTRIM(CESPECIE) == "SPED" .OR. ALLTRIM(CESPECIE) == "CTE"

	If CFORMUL == "S"
		Return(.T.)
	EndIf
	
	If EMPTY(cCHV) 
		MsgBox("Chave nfe estแ vazia. Favor verificar!!!")
		Return(.F.)
	EndIf
	
	If CTIPO = "D" .Or. CTIPO = "B"
		cFcgc:=POSICIONE("SA1",1,XFILIAL("SA1")+CA100FOR+CLOJA,"A1_CGC")
		cFest:=POSICIONE("SA1",1,XFILIAL("SA1")+CA100FOR+CLOJA,"A1_EST")
	Else
		cFcgc:=POSICIONE("SA2",1,XFILIAL("SA2")+CA100FOR+CLOJA,"A2_CGC")
		cFest:=POSICIONE("SA2",1,XFILIAL("SA2")+CA100FOR+CLOJA,"A2_EST")
	EndIf
	
	
	FOR X:=1 TO LEN(aEst)
		if right(aEst[x],2) == cFest     //CODIGO SIGLA ESTADO
			cest:= left(aEst[x],2)
			x:=len(aEst)
		endif
	next x
	
	If   cEst <> Substr(cCHV,1,2)
		lTrueOr := .F.
		
	ElseIf cvaltochar(SUBSTR(cDemissao,3,2)) <> Substr(cCHV,3,2)
		lTrueOr := .F.
		
	ElseIf cvaltochar(Substr(cDemissao,5,2)) <> Substr(cCHV,5,2)
		lTrueOr := .F.
		
//	ElseIf  "55" <> Substr(cCHV,21,2)
//		lTrueOr := .F.
		
	ElseIf STRZERO(VAL(CSERIE),3) <> Substr(cCHV,23,3)
		lTrueOr := .F.
		
	ElseIf STRZERO(VAL(CNFISCAL),9) <> Substr(cCHV,26,9)
		lTrueOr := .F.
		
	ElseIf cFcgc <> Substr(cCHV,7,14)
		If VAL(CSERIE) >= 890
			lTrueOr := .T.
		Else
			lTrueOr := .F.
		EndIf

	Endif
	
    IF ALLTRIM(CESPECIE) == "SPED" 
	   If "55" <> Substr(cCHV,21,2)
  		  lTrueOr := .F.
  	   Endif
  	Endif
  	   
    IF ALLTRIM(CESPECIE) == "CTE" 
	   If "57" <> Substr(cCHV,21,2)
  		  lTrueOr := .F.
  	   Endif
  	Endif
    
	IF	lTrueOr == .F.
		Alert("Chave Nfe invแlida !" )
	Endif
	
ENDIF

Return(lTrueOr)