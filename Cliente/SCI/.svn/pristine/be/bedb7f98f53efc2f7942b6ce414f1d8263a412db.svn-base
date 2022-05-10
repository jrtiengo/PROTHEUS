#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ INT650PIS Autor  Victor Giannoccaro   º Data ³  05/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  PIS - Busca para contabilização de Retenção               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SCIG010(cImposto)

Local _aArea  := GetArea()
Local nValImp := 0
Local cPref := ""
Local cNota := ""
Local cCampo:=""             
Local cParImposto:=""

cPref := SF1->F1_PREFIXO
cNota := SF1->F1_DUPL

If cImposto=='PIS'
	cCampo:='SE2->E2_PARCPIS'
Elseif cImposto=='COF'
	cCampo:='SE2->E2_PARCCOF'
Elseif cImposto=='CSL'
	cCampo:='SE2->E2_PARCSLL'
END                           

If Empty(cCampo)
	Alert("Atenção: imposto "+cImposto+" não está programado")
	Return 0
End

//localiza qual é o titulo gerado referente ao impostos
DbSelectArea("SE2")
DbSetOrder(1)
DbSeek(xFilial("SE2")+CPREF+CNOTA )
While !eof() .And. SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM == xFilial("SE2")+CPREF+CNOTA
	
	If SE2->E2_FORNECE==SF1->F1_FORNECE .AND. SE2->E2_LOJA==SF1->F1_LOJA .AND. SE2->E2_TIPO=='NF '
		cParImposto:=&(cCampo)
		exit
	End
	dbskip()
enddo

DbSelectArea("SE2")
DbSetOrder(1)
DbSeek(xFilial("SE2")+CPREF+CNOTA )
While !eof() .And. SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM == xFilial("SE2")+CPREF+CNOTA
	If SE2->E2_PARCELA==cParImposto
		nValImp  := SE2->E2_VALOR
	EndIf
	dbskip()
enddo

RestArea(_aArea)

Return(nValImp)
