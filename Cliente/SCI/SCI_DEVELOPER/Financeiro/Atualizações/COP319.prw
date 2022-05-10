#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºADAPTADO  ³COP319   ºAutor  ³Marcelo Tarasconi   º Data ³  29/11/2008 º±±
±±ºPrograma  ³PLFF319   ºAutor  ³Marcelo Tarasconi   º Data ³  05/11/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para retornar cod barras                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 10                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function COP319()

Local cRet := SE2->E2_CODBAR

If Len(Alltrim(cRet)) <> 44 //44 posicoes é o código de barras, se tiver 47 entao o que temos é a linha digitavel
   cRet := Substr(SE2->E2_CODBAR,01,03)            // banco
   cRet := cRet + Substr(SE2->E2_CODBAR,04,01)     // moeda
   cRet := cRet + Substr(SE2->E2_CODBAR,33,01)     // dac
   cRet := cRet + Substr(SE2->E2_CODBAR,34,04)     // fator vcto
   cRet := cRet + Substr(SE2->E2_CODBAR,38,10)     // valor
   cRet := cRet + Substr(SE2->E2_CODBAR,05,05)     // livre
   cRet := cRet + Substr(SE2->E2_CODBAR,11,10)     // livre
   cRet := cRet + Substr(SE2->E2_CODBAR,22,10)     // livre
EndIf

Return(cRet)