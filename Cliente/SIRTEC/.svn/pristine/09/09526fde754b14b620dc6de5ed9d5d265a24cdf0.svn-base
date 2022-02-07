#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FB603MDT  º Autor ³ Ezequiel Pianegondaº Data ³  14/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de entrega de EPC.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FB603MDT()
Local cQuery:= ""
Local cAli:= GetNextAlias()

Private cPerg:= PADR("FB603MDT", 10 , " ")  //PADR("FB603MDT", Len(SX1->X1_GRUPO), " ")

ValidPerg()
Pergunte(cPerg, .T.)

Private cEquipe:= MV_PAR01
Private cNomeEq:= Posicione("AA1", 1, xFilial("AA1")+MV_PAR01, "AA1_NOMTEC")
Private _aDados:= {}

cQuery:= " SELECT R_E_C_N_O_ AS RECNOZZD "
cQuery+= " FROM "+RetSqlName("ZZD")+" ZZD "
cQuery+= " WHERE ZZD_EQUIPE = '"+MV_PAR01+"' AND "
cQuery+= "       ZZD_DTENTR BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"' AND "
cQuery+= "      "+RetSqlCond("ZZD")

_aDados:= {}
TCQuery ChangeQuery(cQuery) New Alias cAli
Do While !cAli->(EOF())
	AADD(_aDados, cAli->RECNOZZD)
	cAli->(dbSkip())
EndDo
cAli->(dbCloseArea())
u_FB602MDT()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidPerg ³ Autor ³ Ezequiel Pianegonda   ³ Data ³13/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
Local _aArea  := GetArea()
Local _aRegs  := {}
Local _aHelps := {}
Local _i      := 0
Local _j      := 0

_aRegs = {}
//             GRUPO  ORDEM PERGUNT                       PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID           VAR01       DEF01         DEFSPA1 DEFENG1 CNT01 VAR02 DEF02        DEFSPA2 DEFENG2 CNT02 VAR03 DEF03    DEFSPA3 DEFENG3 CNT03 VAR04 DEF04 DEFSPA4 DEFENG4 CNT04 VAR05 DEF05 DEFSPA5 DEFENG5 CNT05 F3     GRPSXG
AADD (_aRegs, {cPerg, "01", "Equipe             ?", "",    "",    "mv_ch1", "C", 06, 0,  0,     "G", "",             "mv_par01", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})
AADD (_aRegs, {cPerg, "02", "Data entrega de    ?", "",    "",    "mv_ch2", "D", 08, 0,  0,     "G", "",             "mv_par02", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})
AADD (_aRegs, {cPerg, "03", "Data entrega ate   ?", "",    "",    "mv_ch3", "D", 08, 0,  0,     "G", "",             "mv_par03", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
AADD (_aHelps, {"01", {"Informe a equipe a ser considerada ", "no filtro.                              ", "                                        "}})
AADD (_aHelps, {"02", {"Informe a data de entrega inicial a", " ser considerada no filtro.             ", "                                        "}})
AADD (_aHelps, {"03", {"Informe a data de entrega final a ser", " considerada no filtro.                 ", "                                        "}})

/*
DbSelectArea ("SX1")
DbSetOrder (1)
For _i := 1 to Len (_aRegs)
	If ! DbSeek (cPerg + _aRegs [_i, 2])
		RecLock("SX1", .T.)
	Else          
		RecLock("SX1", .F.)
	Endif
	For _j := 1 to FCount ()
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= Len (_aRegs [_i]) .and. left (fieldname (_j), 6) != "X1_CNT" .and. fieldname (_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs [_i, _j])
		Endif
	Next
	MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
DbSeek (cPerg, .T.)
Do While !Eof() .And. x1_grupo == cPerg
	If Ascan(_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
		Reclock("SX1", .F.)
		Dbdelete()
		Msunlock()
	Endif
	Dbskip()
enddo

// Gera helps das perguntas
For _i := 1 to Len(_aHelps)
	PutSX1Help ("P." + alltrim(cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
Next
*/

Restarea(_aArea)

Return()
