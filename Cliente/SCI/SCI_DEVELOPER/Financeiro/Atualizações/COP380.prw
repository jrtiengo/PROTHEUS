#Include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³COP380   ºAutor  ³Marcelo Tarasconi   º Data ³  31/12/2008 º±±
±±ºPrograma  ³RomF360   ºAutor  ³Marcelo Tarasconi   º Data ³  19/07/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao chamada pelo PE_F240Fil pois via Posicione nao estavaº±±
±±º          ³trazendo corretamente os fontes                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function COP380()

Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaSA2 := SA2->(GetArea())


dbSelectArea('SA2')
dbSetOrder(1) //Filial + CODIGO + Loja

If dbSeek(xFilial('SA2')+SE2TMP->E2_FORNECE+SE2TMP->E2_LOJA,.F.)

	If cModPgto == '01' 
	   If cTipoPag $ '20'
		   If Empty(SE2TMP->E2_CODBAR) .and. !Empty(SA2->A2_BANCO) .and. !Empty(SA2->A2_AGENCIA) .and. !Empty(SA2->A2_NUMCON) .and. SA2->A2_BANCO == cPort240 
		      lRet := .T.
		   EndIf
	   EndIf

	ElseIf cModPgto == '03'
	   If cTipoPag $ '20'
		   If SE2TMP->E2_SALDO < GetMv("ES_VDOCTED") .and. Empty(SE2TMP->E2_CODBAR) .and. !Empty(SE2TMP->E2_BANCO) .and. !Empty(SE2TMP->E2_AGENC) .and. !Empty(SE2TMP->E2_NUMCON) .and. SE2TMP->E2_BANCO <> cPort240 
		      lRet := .T.
    	   ElseIf SE2TMP->E2_SALDO < GetMv("ES_VDOCTED") .and. Empty(SE2TMP->E2_CODBAR) .and. !Empty(SA2->A2_BANCO) .and. !Empty(SA2->A2_AGENCIA) .and. !Empty(SA2->A2_NUMCON) .and. SA2->A2_BANCO <> cPort240 
		      lRet := .T.
		   EndIf

	   //Else
		   //If SE2TMP->E2_SALDO >= GetMv("ES_VDOCTED") .and. Empty(SE2TMP->E2_CODBAR) .and. !Empty(SA2->A2_BANCO) .and. !Empty(SA2->A2_AGENCIA) .and. !Empty(SA2->A2_NUMCON) .and. SA2->A2_BANCO <> cPort240 
		   //   lRet := .T.
		   //EndIf

	   EndIf
    
	ElseIf cModPgto == '41'
	   If cTipoPag $ '20'
		   If SE2TMP->E2_SALDO >= GetMv("ES_VDOCTED") .and. Empty(SE2TMP->E2_CODBAR) .and. !Empty(SE2TMP->E2_BANCO) .and. !Empty(SE2TMP->E2_AGENC) .and. !Empty(SE2TMP->E2_NUMCON) .and. SE2TMP->E2_BANCO <> cPort240 
		      lRet := .T.
    	   ElseIf SE2TMP->E2_SALDO >= GetMv("ES_VDOCTED") .and. Empty(SE2TMP->E2_CODBAR) .and. !Empty(SA2->A2_BANCO) .and. !Empty(SA2->A2_AGENCIA) .and. !Empty(SA2->A2_NUMCON) .and. SA2->A2_BANCO <> cPort240 
		      lRet := .T.
		   EndIf
	   EndIf

    
    EndIf
	
EndIf

If SE2TMP->E2_PAGCOM == '1'
	lRet := .F.
EndIf

RestArea(aAreaSA2)
RestArea(aArea)
Return(lRet)
