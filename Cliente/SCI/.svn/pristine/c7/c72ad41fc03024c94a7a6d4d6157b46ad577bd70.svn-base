#Include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºADAPTADO  ³COP319   ºAutor  ³Marcelo Tarasconi   º Data ³  29/11/2008 º±±
±±ºPrograma  ³PLFF319   ºAutor  ³Marcelo Tarasconi   º Data ³  12/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para declarar variaveis contadoras para cnab a pagar º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 8                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COP325()

Local cRet := Alltrim(SE2->E2_CODBAR)

If Len(cRet) <> 44 //44 posicoes é o código de barras leitor , se tiver 48 entao o que temos é a linha digitavel
   cRet := Substr(Alltrim(SE2->E2_CODBAR) ,01,11)     
   cRet += Substr(Alltrim(SE2->E2_CODBAR) ,13,11)     
   cRet += Substr(Alltrim(SE2->E2_CODBAR) ,25,11)     
   cRet += Substr(Alltrim(SE2->E2_CODBAR) ,37,11)     
EndIf    

Return(cRet)