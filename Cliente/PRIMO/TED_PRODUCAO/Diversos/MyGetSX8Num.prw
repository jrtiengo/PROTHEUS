#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#include 'tbiconn.ch'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณMyGetSX8NumบAutor  ณMarcioQuevedoBorges บ Data ณ  17/02/09   บฑฑ
ฑฑฬอออออออออฯัออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca a proxima sequencia                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe:  ณ u_MyGetSX8Num(cAlias,cCpoSX8,[nOrder],[lLicense],[cFiltro])บฑฑ
ฑฑบ          ณ cAlias  : Alias da Tabela                                  บฑฑ
ฑฑบ          ณ cCpoSx8 : Campo chave da numera็ใo da tabela               บฑฑ
ฑฑบ          ณ nOrder  : Ordem de pesquisa da Chave no License            บฑฑ
ฑฑบ          ณ lLicense: Se .T. e numeracao license menor que max, acerta บฑฑ
ฑฑบ          ณ           o license - Default .T.                          บฑฑ
ฑฑบ          ณ cFiltro : Filtro para trazer o registro. Formato SQL       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 8                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



User Function MyGetSX8Num(cAlias,cCpoSx8,nOrder,lLicense,cFilter)

	Local cTRB := GetNextAlias()
	Local cQuery := ""

	IF cAlias == Nil
		Return ""
	ENDIF


	IF lLicense == Nil
		lLicense := .T.
	Endif

//IF nOrder == Nil
//	nOrder 	:= RetOrder( cAlias , GetX3Pref(cAlias)+"_FILIAL" + cCpoSx8 )
//ENDIF


	IF cFilter == Nil
		cFilter := ""
	ENDIF


	cSeqID  := ""

	IF cCpoSx8 == Nil .AND. !Empty(ReadVar())
		cCpoSx8 := Alltrim(ReadVar())
		cCpoSx8 := StrTran(cCpoSx8,"M->","")
	ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a numera็ใo jแ existe na base.    ณ
//ณSe jแ existir, efetua confirma็a๕ e busca     ณ
//ณpr๓xima numera็ใo. Ajustando license da tabelaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF cCpoSx8 <> Nil
		cQuery := "SELECT MAX(" + cCpoSx8 + ")MaxID FROM " + RetSQLName(cAlias) + " TBL "
		cQuery += " WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND "
		cQuery += " TBL.D_E_L_E_T_ = ' ' "
		IF !EMPTY(cFilter)
			cQuery += " AND " + cFilter
		ENDIF

		//cQuery := ChangeQuery(cQuery)


		IF SELECT( cTRB ) <> 0
			(cTRB)->(DbCloseArea())
		Endif

		MPSysOpenQuery( cQuery, cTRB )

		cSeqID:=(cTRB)->MaxID
		(cTRB)->(DbCloseArea())

		DBSelectArea(cAlias)

		IF Empty(cSeqID)
			nTamanho := TamSX3(cCpoSx8)[1]
			cSeqID := Replicate("0",nTamanho)
		ENDIF

		//cNum := cSeqID
	ENDIF
	IF lLicense

		cNumLicense := GETSXENum(cAlias,cCpoSx8,nOrder)

		WHILE cNumLicense < cSeqID//cNum
			cNumLicense := GETSXENum(cAlias,cCpoSx8,nOrder)
			(cAlias)->(ConfirmSX8())
		ENDDO
	ELSE
		cNumLicense := GETSXENum(cAlias,cCpoSx8,nOrder)
	ENDIF

	IF cCpoSx8 == Nil
		cCpoSx8 := ""
	ENDIF

	IF cSeqID > cNumLicense
		cNumLicense := cSeqID
	ENDIF

// Verifica se o numero jแ estแ reservado.
	While !MayIUseCode(cAlias+cCpoSx8+cNumLicense)
		cNumLicense := Soma1(cNumLicense)
	Enddo

	cNum := cNumLicense

Return cNum

