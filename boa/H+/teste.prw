#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

User Function EXEC103()

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local cNum := ""
	Local nX := 0
    Local aItensRat := {}

	Conout("Inicio: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" FUNNAME "MATA103"

	cNum := GetSxeNum("SF1","F1_DOC")
	SF1->(dbSetOrder(1))
	While SF1->(dbSeek(xFilial("SF1")+cNum))
		ConfirmSX8()
		cNum := GetSxeNum("SF1","F1_DOC")
	EndDo

//Cabeçalho
	aadd(aCab,{"F1_TIPO" ,"N" ,NIL})
	aadd(aCab,{"F1_FORMUL" ,"N" ,NIL})
	aadd(aCab,{"F1_DOC" ,'TSTCLASS1' ,NIL})
	aadd(aCab,{"F1_SERIE" ,"TST" ,NIL})
	aadd(aCab,{"F1_EMISSAO" ,DDATABASE ,NIL})
	aadd(aCab,{"F1_DTDIGIT" ,DDATABASE ,NIL})
	aadd(aCab,{"F1_FORNECE" ,"000001" ,NIL})
	aadd(aCab,{"F1_LOJA" ,"01" ,NIL})
	aadd(aCab,{"F1_ESPECIE" ,"NF" ,NIL})
	aadd(aCab,{"F1_COND" ,"001" ,NIL})

//Itens
	For nX := 1 To 1
		aItem := {}
		//aadd(aItem,{"D1_ITEM" ,StrZero(nX,4) ,NIL})
		aadd(aItem,{"D1_COD" ,'000000000000001' ,NIL})
		aadd(aItem,{"D1_UM" ,"UN" ,NIL})
		aadd(aItem,{"D1_LOCAL" ,"01" ,NIL})
		aadd(aItem,{"D1_QUANT" ,1 ,NIL})
		aadd(aItem,{"D1_VUNIT" ,100 ,NIL})
		aadd(aItem,{"D1_TOTAL" ,100 ,NIL})
		aadd(aItem,{"D1_TES" ,"001" ,NIL})

		aAdd(aItens,aItem)
	Next nX

//3-Inclusão / 4-Classificação / 5-Exclusão
	MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,a,,,,b)},aCab,aItens,4,.F.,aItensRat)

	If !lMsErroAuto
		ConOut(" Incluido NF: " + cNum)
	Else
		MostraErro()
		ConOut("Erro na inclusao!")
	EndIf

	ConOut("Fim: " + Time())

	RESET ENVIRONMENT

Return
