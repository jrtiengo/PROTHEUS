//|--------------------------------------------------------------|
//|Proximo Numero de um Titlo Financeiro de acordo com Prefixo |
//|--------------------------------------------------------------|
User Function CONTNUM(cPrefixo)

Local aArea := GetArea()

cQuery := "select MAX(E2_NUM) NUMERO"
cQuery += " from "
cQuery += RetSQLName("SE2") "
cQuery += " where "
cQuery += " E2_FILIAL = '" + xFilial("SE2") + "' AND "
cQuery += " E2_prefixo = '" + cPrefixo + "' AND "
cQuery += RetSQLName("SE2")+".D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)

If (Select("TEMP") <> 0)
DbSelectArea("TEMP")
DbCloseArea()
Endif
dbUseArea( .T.,"TOPCONN", TCGENQRY(,,cQuery),"TEMP", .F., .T.)
DbSelectArea("TEMP")

//cNumero := StrZero(Val(Temp->numero)+1, 6)

cNumero := Soma1(Temp->numero,6)

DbSelectArea("TEMP")
DbCloseArea()
RestArea(aArea)

RETURN(cNumero)
