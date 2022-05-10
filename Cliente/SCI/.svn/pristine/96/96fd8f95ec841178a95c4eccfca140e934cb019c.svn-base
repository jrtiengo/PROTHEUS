#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³U_CRIASXE ³ Autor ³ Expedito Mendonca Jr. ³ Data ³ 11/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Este ponto de entrada eh acionado toda vez que o license     ³±±
±±³          ³ server eh reiniciado, com o objetivo de determinar o proximo ³±±
±±³          ³ numero disponivel das tabelas que possuem tratamentos        ³±±
±±³          ³ especificos ou excecoes nos campos de numeracao sequencial   ³±±
±±³          ³ automatica (Getsxenum).                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE ERNESTO WOEBCKE				        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CriaSXE()
Local aAreaAtu := GetArea(), aAreaTmp, nTam, cProxNum
Local cAlias := PARAMIXB[1], cCampo := PARAMIXB[2]
                        
//If cEmpAnt == "010001"
	If cAlias == "SB1" .and. (cCampo == "B1_COD" .or. cCampo = NIL)
		// Seleciona os pedidos aptos a faturar
		cQuery := "SELECT MAX(B1_COD) MAXCODB1"
		cQuery += " FROM " + RetSQLName("SB1") + " SB1"
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"
//		cQuery += " AND LENGTH(TRIM(B1_COD)) = 6"
//		cQuery += " AND B1_COD <> '87401          '
		cQuery += " AND SB1.D_E_L_E_T_ <> '*'"
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB_FIB",.F.,.T.)
		cProxNum := Strzero( Val(TRB_FIB->MAXCODB1) + 1 , 6 )		// Codigo de 6 digitos
		TRB_FIB->(DbCloseArea())

	Endif                 
	
//Endif

// Restaura o ambiente
Restarea(aAreaAtu)
//alert(cproxnum)
Return cProxNum