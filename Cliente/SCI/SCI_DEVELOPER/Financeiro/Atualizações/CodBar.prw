#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±± Rhaiana Vianna CODBAR()
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para retornar cod barras                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 10                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CodBar()

Local cRet := SE2->E2_CODBAR

If Len(Alltrim(cRet)) <> 44 .and. !SubStr(cRet,1,2) $ '81/82/83/84/85/86'     //44 posicoes é o código de barras, se tiver 47 entao o que temos é a linha digitavel

   cRet := Substr(SE2->E2_CODBAR,01,03)            // banco
   cRet := cRet + Substr(SE2->E2_CODBAR,04,01)     // moeda
   cRet := cRet + Substr(SE2->E2_CODBAR,33,01)     // dac
   cRet := cRet + Substr(SE2->E2_CODBAR,34,04)     // fator vcto
   cRet := cRet + Substr(SE2->E2_CODBAR,38,10)     // valor
   cRet := cRet + Substr(SE2->E2_CODBAR,05,05)     // livre
   cRet := cRet + Substr(SE2->E2_CODBAR,11,10)     // livre
   cRet := cRet + Substr(SE2->E2_CODBAR,22,10)     // livre

//a decomposicao dos nuemro digital dos titulo de concessionarias eh diferente
ElseIf Len(Alltrim(cRet)) <> 44 .and. SubStr(cRet,1,2) $ '81/82/83/84/85/86'

//concessionarias sao 4 cadeias de 11 caracteres + 1 digito verificador, portanto vamos tirar estes digito...
   
   cRet := Substr(SE2->E2_CODBAR,01,11)            
   cRet := cRet + Substr(SE2->E2_CODBAR,13,11)     
   cRet := cRet + Substr(SE2->E2_CODBAR,25,11)     
   cRet := cRet + Substr(SE2->E2_CODBAR,37,11)     

EndIf

Return(cRet)

/*
*****************************************************************************