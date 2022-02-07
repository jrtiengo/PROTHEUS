#include "protheus.ch"
#include "topconn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB105TEC ³ Autor ³ Alisson Teles               ³ Data ³ 09/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ alisson.teles@totvs.com.br            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Integração Sirtec x FullSoft, mostra itens marcados na checklist. ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB105TEC(cNumOS, cSeq, cTipo)

Local oOk      := LoadBitmap(GetResources(), "BR_VERDE")
Local oNo      := LoadBitmap(GetResources(), "BR_VERMELHO")
Local aLegenda :={{"BR_VERDE",	 "Verificado" 	  },;
					   {"BR_VERMELHO", "Não verificado"}}
					   
Local cAlias := "TRB"
Local aOrdem := {}
Local oDlg

If cTipo == "V"

	cQuery := "	SELECT AB3.AB3_CODCLI, AB3.AB3_LOJA, ZZH.ZZH_CODCHK, ZZG.ZZG_DESC, ISNULL((SELECT ZZN.ZZN_ITEMCH "
	cQuery += "																				  FROM "+RetSqlName("ZZN")+" ZZN "
	cQuery += " 																			  WHERE "+RetSqlCond("ZZN")+" 
	cQuery += "																					  AND ZZN.ZZN_CODOS = AB3.AB3_NUMORC "
	cQuery += "																					  AND ZZN.ZZN_ITEMCH = ZZH.ZZH_CODCHK "
	cQuery += "                                                               AND ZZN.ZZN_TIPO = 'V' ),'') as MARCA "
	cQuery += " FROM "+ RetSqlName("AB3")+" AB3 INNER JOIN "+RetSqlName("ZZH")+" ZZH ON AB3.AB3_CODCLI = ZZH.ZZH_CODCLI AND AB3.AB3_LOJA = ZZH.ZZH_LOJCLI "
	cQuery += "  										  INNER JOIN "+RetSqlName("ZZG")+ " ZZG ON ZZH.ZZH_CODCHK = ZZG.ZZG_CODIGO "
	cQuery += "WHERE AB3.AB3_NUMORC = '"+cNumOS+"' "
	cQuery += " AND "+ RetSqlCond("AB3")
	cQuery += " AND "+ RetSqlCond("ZZH")
	cQuery += " AND "+ RetSqlCond("ZZG")

Else

	cQuery := "	SELECT AB6.AB6_CODCLI, AB6.AB6_LOJA, ZZH.ZZH_CODCHK, ZZG.ZZG_DESC, ISNULL((SELECT ZZN.ZZN_ITEMCH "
	cQuery += "																				  FROM "+RetSqlName("ZZN")+" ZZN "
	cQuery += " 																			  WHERE "+RetSqlCond("ZZN")+" 
	cQuery += "																					  AND ZZN.ZZN_CODOS = " + cNumOS
	cQuery += "																					  AND ZZN.ZZN_SEQ = " + cSeq
	cQuery += "																					  AND ZZN.ZZN_TIPO = 'A' "
	cQuery += "                                                               AND ZZN.ZZN_ITEMCH = ZZH.ZZH_CODCHK ),'') as MARCA "
	cQuery += " FROM "+ RetSqlName("AB6")+" AB6 INNER JOIN "+RetSqlName("ZZH")+" ZZH ON AB6.AB6_CODCLI = ZZH.ZZH_CODCLI AND AB6.AB6_LOJA = ZZH.ZZH_LOJCLI "
	cQuery += "  										  INNER JOIN "+RetSqlName("ZZG")+ " ZZG ON ZZH.ZZH_CODCHK = ZZG.ZZG_CODIGO "
	cQuery += "WHERE AB6.AB6_NUMOS = '"+Left(cNumOS,6)+"' "
	cQuery += " AND "+ RetSqlCond("AB6")
	cQuery += " AND "+ RetSqlCond("ZZH")
	cQuery += " AND "+ RetSqlCond("ZZG")

Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

While (cAlias)->(!EoF())
	If !Empty((cAlias)->MARCA)
		AADD( aOrdem, { .T. , Alltrim((cAlias)->ZZH_CODCHK), Alltrim((cAlias)->ZZG_DESC) })
	Else
		AADD( aOrdem, { .F. , Alltrim((cAlias)->ZZH_CODCHK), Alltrim((cAlias)->ZZG_DESC) })
	EndIf
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dBCloseArea())

If len(aOrdem) > 0

	DEFINE MSDIALOG oDlg TITLE "Check List" FROM 000, 000  TO 270, 580 COLORS 0, 16777215 PIXEL
		
		@0.2,0.2 LISTBOX oQual VAR cVar Fields HEADER "",OemToAnsi("Cód"), OemToAnsi("Descrição") SIZE 290,118 //NOSCROLL
		oQual:SetArray(aOrdem)
		oQual:bLine := { || { if( aOrdem[oQual:nAt, 1], oOk, oNo), aOrdem[oQual:nAt, 2],aOrdem[oQual:nAt, 3]   } }
		
		@123,230 BUTTON "Legenda" SIZE 030,010 PIXEL OF oDlg ACTION (BrwLegenda("Check List","Legenda" ,aLegenda))
		@123,262 BUTTON "Fechar"  SIZE 030,010 PIXEL OF oDlg ACTION (oDlg:End())
		
	ACTIVATE MSDIALOG oDlg
	
Else
	MsgInfo("Não há itens marcados no ChekList para essa Ordem de Serviço.")
Endif

Return