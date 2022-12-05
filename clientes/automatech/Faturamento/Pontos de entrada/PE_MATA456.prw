#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MTA456P  ³ Autor ³ JPC Cesar Mussi       ³ Data ³ 18/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE para bloquear liberacao de estoque                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function mta456p

   U_AUTOM628("PE_MATA456")

_RetVal   := .T.
// Criacao de temporario (padrao SQL-topconnect)
_cQuery := _cField := _cFrom := _cWhere := _cOrder := ""
// Campos
_cField += "SELECT SC9.*"
_cFrom  += " FROM " + RetSqlName("SC9") + " SC9"
_cWhere += " WHERE SC9.C9_FILIAL = '" + XFILIAL("SC9") + "'"
_cWhere += " AND SC9.C9_PEDIDO = '" + SC9->C9_PEDIDO + "'"
_cWhere += " AND SC9.C9_BLEST <> '  '"
_cWhere += " AND SC9.C9_BLEST <> '10'"
_cWhere += " AND SC9.D_E_L_E_T_ = ' '"

// Quantidade de linhas para montagem da regua de processamento
_cQuery := "Select count(*) total" + _cFrom + _cWhere
_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQRY(,,_cQuery),"LIN",.F.,.T.)
_QtdRow := LIN->TOTAL
dbCloseArea("LIN")
If _QtdRow > 0
	
	msgbox("Pedido " + sc9->c9_pedido + " Possui Item Bloqueado por Estoque !","Liberação Manual Não Permitida !","INFO")
	_RetVal := .F.
	
EndIf

Return(_RetVal)
