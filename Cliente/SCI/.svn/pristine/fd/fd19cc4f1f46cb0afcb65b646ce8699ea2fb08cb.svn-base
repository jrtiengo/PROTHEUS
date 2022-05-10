#Include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºADAPTADO  ³COP316   ºAutor  ³Marcelo Tarasconi   º Data ³  29/11/2008 º±±
±±ºPrograma  ³PLFF316   ºAutor  ³Marcelo Tarasconi   º Data ³  12/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para declarar variaveis contadoras para cnab a pagar º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 8                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COP316()

Local aArea    := GetArea()
Local aAreaSE2 := SE2->(GetArea())
local nAbat    := 0    
local nValor   := 0

//Procura abatimento
nAbat := Posicione('SE2',1,xFilial('SE2')+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+'AB-','E2_VALOR')

//Volto area original
RestArea(aAreaSE2)
RestArea(aArea)
 
If SE2->E2_PORTADO == '399' //HSBC
	nValor := STRZERO((SE2->E2_SALDO - SE2->E2_SDDECRE - nAbat + SE2->E2_SDACRES)*100, 13) //HSBC
Else 
	nValor := STRZERO((SE2->E2_SALDO - SE2->E2_SDDECRE - nAbat + SE2->E2_SDACRES)*100, 15) //ITAU
EndIf


Return(nValor)


/*
Local aArea    := GetArea()
Local aAreaSE2 := SE2->(GetArea())
local nAbat    := 0

//Procura abatimento
nAbat := Posicione('SE2',1,xFilial('SE2')+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+'AB-','E2_VALOR')

//Volto area original
RestArea(aAreaSE2)
RestArea(aArea)

//Return(STRZERO((SE2->E2_SALDO - SE2->E2_SDDECRE - nAbat )*100, 15))
Return(STRZERO((SE2->E2_SALDO - SE2->E2_SDDECRE - nAbat + SE2->E2_SDACRES)*100, 15))