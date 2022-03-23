#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH" 


/*/{Protheus.doc} MT120LOK
//TODO Valida็ใo na Linha do pedido para perguntar /deletar item
@author Mแrcio Borges
@since 23/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT120LOK()

Local _Produto	:= GdFieldGet('C7_PRODUTO') // preco unitario
Local _precoU 	:= STR(GdFieldGet('C7_PRECO')) // Preco unitario
Local _DatPRF 	:= DTOS(GdFieldGet('C7_DATPRF')) // Data Entrega
Local _lRet     := .T. 
Local cSql 		:= ""

// #29774 As tabelas criadas, ficavam em aberto, gerando erro "Work area table full".
// Iniciar e finalizar o PE com a valida็ใo, para nใo deixar nada em aberto. Mauro - Solutio. 05/05/2021.
If Select( "_TMP" ) <> 0
	_TMP->(DbCloseArea())
Endif
 
//##########################
// Pesquisa Tab. Preco
//#######################3##
IF !GDDeleted(n) 
	cSql := ""
	cSql += "SELECT AIB_CODTAB,AIB_CODFOR,AIB_LOJFOR FROM " + RetSqlName("AIB") + " AIB WHERE AIB_FILIAL = '"+ xFilial("AIB") + "' AND AIB.D_E_L_E_T_ <> '*' AND AIB_CODPRO = '" + _Produto + "' AND  AIB_PRCCOM < " + _precoU + " AND AIB_DATVIG <= '" + _DatPRF + "'" 
	//ou AIA_DATDE   //Data De
	MyQuery(cSql, "_TMP")


	DbSelectArea("_TMP")
	 
	If _TMP->(!EOF())
		IF MSGYESNO("Este produto jแ possui tabela de preco com com valor menor. Tabela: " + _TMP->AIB_CODTAB + ", Fornecedor: " + _TMP->(AIB_CODFOR+"/"+AIB_LOJFOR + ". Deseja apagar a linha?")  ,"Tabela de Preco Existente !")
			aCols[n,Len(aHeader) + 1] := .T.
		ENDIF
	EndIf

	_TMP->(DbCloseArea())
Endif	
    
// #29774 As tabelas criadas, ficavam em aberto, gerando erro "Work area table full".
// Iniciar e finalizar o PE com a valida็ใo, para nใo deixar nada em aberto. Mauro - Solutio. 05/05/2021.
If Select( "_TMP" ) <> 0
	_TMP->(DbCloseArea())
Endif

Return _lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMYQUERY   บAutor  ณMarcioQuevedo Borgesบ Data ณ  12/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta Query de Consulta                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyQuery( cQuery , cursor )

	IF SELECT( cursor ) <> 0
		dbSelectArea(cursor)
		DbCloseArea(cursor)
	Endif

	TCQUERY cQuery NEW ALIAS (cursor)

Return
