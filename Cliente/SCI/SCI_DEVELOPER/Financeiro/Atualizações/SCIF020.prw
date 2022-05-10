#Include 'Totvs.ch'
#Include 'Protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NOVO5     ºAutor  ³Microsiga           º Data ³  04/30/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SCIF020()

Local aArea    := GetArea()
Local aAreaCNC := CNC->(GetArea())
Local aAreaCN9 := CN9->(GetArea())
Local aAreaCNF := CNF->(GetArea())
Local lOk      := .T.
Local lAtivo   := .F.
Local aBrowse  := {}

PRIVATE oDlg
Private cGet2:=''
PRIVATE oFont:= TFont():New("Arial",,14,.T.)
PRIVATE oSay2:=""
PRIVATE oSay3:=""
Private cContra := ""

dbSelectArea('CNC')
dbOrderNickName('INTCNC')
If dbSeek(xFilial('CNC')+CA100FOR+CLOJA,.f.)
	
	cChave := xFilial('CNC')+CA100FOR+CLOJA
	
	While !EOF() .and. cChave == CNC->(CNC_FILIAL+CNC_CODIGO+CNC_LOJA)
		
		dbSelectArea('CN9')
		dbSetOrder(1)
		If dbSeek(xFilial('CN9')+CNC->(CNC_NUMERO+CNC_REVISA),.f.)

			If  CN9->CN9_SITUACA == '05'
				

				dbSelectArea('CNF')
				dbSetOrder(2)
				If dbSeek(xFilial('CNF')+CNC->(CNC_NUMERO+CNC_REVISA),.f.)		

					aAdd( aBrowse,{ CNF->CNF_CONTRA, CNF->CNF_REVISA, CNF->CNF_PARCEL, CNF->CNF_COMPET, CNF->CNF_VLPREV, CNF->CNF_VLREAL, dtoc(CNF->CNF_PRUMED) } )
				lAtivo := .T.
				EndIf
			EndIf
		EndIf
	
	CNC->(dbSkip())
	End
EndIf

If lAtivo
	
	
	DEFINE DIALOG oDlg2 TITLE "Existem contratos vigentes para este fornecedor " FROM 090,090 TO 440,800 PIXEL
	
	oPanel:= tPanel():New(01,01,"",oDlg2,,,,,CLR_WHITE,180,135)
	
	oBrw := TWBrowse():New( 000,000, 358/*293*/,145,,{"Contrato","Revisão","Parcela","Compet","Valor Previsto", "Valor Realizado", "Dt Prev Med"},/*{80,30}*/, oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrw:SetArray( aBrowse )
	oBrw:bLine := {||{ aBrowse[oBrw:nAt,01],;
	aBrowse[oBrw:nAt,02] ,;
	aBrowse[oBrw:nAt,03] ,;
	aBrowse[oBrw:nAt,04] ,;
	Transform(aBrowse[oBrw:nAt,05], "@E 99,999,999.99"	) ,;
	Transform(aBrowse[oBrw:nAt,06], "@E 99,999,999.99"	) ,;
	aBrowse[oBrw:nAt,07] }}
	
	oBtnCa := TButton():New( 150,220,"&OK",oDlg2,{|| oDlg2:End() }							    , 30,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	ACTIVATE DIALOG oDlg2 CENTERED
	
EndIf

RestArea(aAreaCNC)
RestArea(aAreaCNF)
RestArea(aAreaCN9)
RestArea(aArea)

Return( lOk )