#Include 'Protheus.ch'
#Include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F080PCAN  ºAutor  ³ Leonel Vilaverde   º Data ³  29/12/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PE após exclusao da baixa do contas a pagar                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Objetivo de gerar registro a ser contabilizado              º±±
±±º                                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F080PCAN()
Local aArea:= GetArea()
Local aSE5:= SE5->(GetArea())

Private aAutoCab:= {}
Private aAutoItens:= {}

MsgBox("Estou no F080PCAN " + SE5->E5_NUMERO + ' ' + SE5->E5_LA + ' ' + SE5->E5_SITUACA + ' ' + SE5->E5_TIPODOC + ' ' + SE5->E5_MOTBX +  ' ' + SE5->E5_MOTBX + '  ' + DTOC(SE5->E5_DATA) ,"ATENCAO!")

IF  SE5->E5_MOTBX == 'EST'  .AND. SE5->E5_SITUACA == 'C' .AND. ALLTRIM(SE5->E5_LA) == 'S'
    cCFilial  := SE5->E5_FILIAL
    cPrefixo  := SE5->E5_PREFIXO
    cNumero   := SE5->E5_NUMERO
    cParcela  := SE5->E5_PARCELA
	cTIPO     := SE5->E5_TIPO
	cCLIFOR   := SE5->E5_CLIFOR 
	cLOJA     := SE5->E5_LOJA
	cSeq      := SE5->E5_SEQ 
	cBENEF    := SE5->E5_BENEF 
	dDATA     := SE5->E5_DATA 
	cNATUREZ  := SE5->E5_NATUREZ
	cMOTBX    := SE5->E5_MOTBX
	nVLMOED2  := SE5->E5_VLMOED2
	dDTDISPO  := SE5->E5_DATA
	nVALOR    := SE5->E5_VALOR
    cMOEDA    := SE5->E5_MOEDA
    cFILORIG  := SE5->E5_FILORIG
    dDTCANBX  := SE5->E5_DTCANBX
    cORIGEM   := SE5->E5_ORIGEM 
    cFORNECE  := SE5->E5_FORNECE 
    cMULTNAT  := SE5->E5_MULTNAT 
    cTPDESC   := SE5->E5_TPDESC 

//   	cSeq := Soma1( cSeq )  deixar a mesma seq, pois não será gerado extrato.

	SE5->( RecLock( 'SE5', .t. ) )
	SE5->E5_FILIAL   := cCFILIAL
	SE5->E5_PREFIXO  := cPREFIXO
	SE5->E5_NUMERO   := cNUMERO
	SE5->E5_PARCELA  := cPARCELA
	SE5->E5_TIPO     := cTIPO
	SE5->E5_CLIFOR   := cCLIFOR 
	SE5->E5_LOJA     := cLOJA
	SE5->E5_SEQ      := cSeq 
	SE5->E5_BENEF    := cBENEF 
	SE5->E5_DATA     := dDATA 
	SE5->E5_NATUREZ  := cNATUREZ
	SE5->E5_RECPAG   := 'R'
	SE5->E5_DTDIGIT  := dDataBase
	SE5->E5_MOTBX    := cMOTBX
	SE5->E5_VLMOED2  := nVLMOED2
	SE5->E5_DTDISPO  := dDATA
	SE5->E5_VALOR    := nVALOR
	SE5->E5_TIPODOC  := 'ES'
    SE5->E5_HISTOR   := 'Cancelamento de Baixa EST'
    SE5->E5_MOEDA    := cMoeda
    SE5->E5_FILORIG  := cFILORIG
    SE5->E5_DTCANBX  := dDTCANBX
    SE5->E5_ORIGEM   := cORIGEM 
    SE5->E5_FORNECE  := cFORNECE 
    SE5->E5_MULTNAT  := cMULTNAT
    SE5->E5_TPDESC   := cTPDESC 
//    SE5->E5_MOVFKS   := 'N'
	SE5->( MsUnlock() )

EndIF

RestArea(aSE5)
RestArea(aArea)

Return
