#INCLUDE "protheus.ch"

//***************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                *
// ------------------------------------------------------------------------------------ *
// Referencia: P_OCCURS.PRW                                                             *
// Parâmetros: Nenhum                                                                   *
// Tipo......: (X) Programa  ( ) Gatilho                                                *
// ------------------------------------------------------------------------------------ *
// Autor.....: Harald Hans Löschenkohl                                                  *
// Data......: 20/07/2012                                                               *
// Objetivo..: Pesquisar em uma string um determinado conteúdo.                         *
// Parâmetros: String   - String a ser pesquisada										*
//             Caracter - Caracteres a serem pesquisados								*
//             Tipo     - Indica o tipo de retorno sendo:								*
//						  1 - Retorna a quantidade de ocorrências encontradas na String *
// 						  2 - Retorna as posições do caracter parssado na String	    *
//***************************************************************************************

User Function P_OCCURS(cString, cCaracter, cTipo)

   LOCAL cPesquisa := ""
   LOCAL nContar   := 0
   LOCAL nQuant    := 0
   LOCAL cPosicao  := ""
   
   IF EMPTY(cString)
      IF cTipo == 1
         RETURN nQuant
      ELSE
         RETURN cPosicao
      ENDIF
   ENDIF
   
   IF EMPTY(cCaracter)
      IF cTipo == 1
         RETURN nQuant
      ELSE
         RETURN cPosicao
      ENDIF
   ENDIF
   
   cPesquisa = ALLTRIM(cString)
   
   FOR nContar = 1 TO LEN(ALLTRIM(cString))
       IF SUBSTR(cPesquisa, nContar, LEN(cCaracter)) = ALLTRIM(cCaracter)
          nQuant   := nQuant + 1
          cPosicao := cPosicao + ALLTRIM(STR(nContar)) + "|"
       ENDIF
   NEXT nContar
   
   IF cTipo == 1
      RETURN nQuant
   ELSE
      IF nQuant == 1
         RETURN SUBSTR(cPosicao, 1, LEN(cPosicao) - 1)
      ELSE
         RETURN cPosicao
      ENDIF
   ENDIF
   
RETURN .t.
            
//******************************************************************************************
// Processo  : P_CORTA(String, Caracter, Tipo)											   *
// Parâmetros: String   - String a ser pesquisada										   *
//             Caracter - Caracter que indica o separador de corte						   *
//             Nº do separador a ser cortado											   *
//						  Se nº a ser cortado for = a 0, o retorno será no formato de      *
//					      um array														   *
// 						  Se nº a ser cortado for = 1, retorna somente o resultado do      *
//                        corte solicitado                                                 *
//******************************************************************************************
// Criado em 20/07/2012 - Harald Hans Löschenkohl										   *
//******************************************************************************************

User Function P_CORTA(cString, cCorte, nPosicao)
   
   Local nContar   := 0
   Local cSeparado := ""
   Local cRetorno  := ""
   Local aResumo   := {}
   
   // Se cString = branco, não processa
   IF EMPTY(cString)
      RETURN ""
   ENDIF
   
   // Se caracter de corte = branco, não processa
   IF EMPTY(cCorte)
      RETURN ""
   ENDIF

   // Verifica se o último caracter é o separador passado no parâmetro.
   // Caso não for, adiciona o separador no final para que o laço abaixo
   // não dê problemas.
   IF SUBSTR(cString, LEN(cString), 1) <> cCorte
      cString := cString + cCorte
   ENDIF

   cSeparado := ""
   nElemento := 1   

   FOR nContar = 1 TO LEN(cString)        
       IF SUBSTR(cString, nContar, 1) == cCorte
		  aAdd( aResumo, { cSeparado } )
		  nElemento := nElemento + 1
		  cSeparado := ""
		  LOOP
       ELSE
          cSeparado := cSeparado + SUBSTR(cString, nContar, 1)
       ENDIF
   NEXT nContar
   
   // Inclui no array a última pesquisa
   IF !EMPTY(cSeparado)
      aAdd( aResumo, { cSeparado } )
   ENDIF
   
   IF Len(aResumo) > 0
      IF nPosicao == 0
         cRetorno := aResumo
      ELSE
         IF Len(aResumo) >= nPosicao
            cRetorno := aResumo[nPosicao,01]
         ELSE
            cRetorno := ""
         ENDIF
      ENDIF
   ELSE
      cRetorno := ""
   ENDIF

RETURN cRetorno        

//******************************************************************************************
// Processo  : P_TIMETOSEC(cHora, cMostra)										           *
// Objetivo  : Transforma Tempo em Segundos                                                *
// Parâmetros: cHora   - Hora a ser calculada                                              *
//             cMostra - 0 - Não mostra resultado                                          *
//                       1 - Mostra resultado                                              *
//******************************************************************************************
// Criado em 15/02/2013 - Harald Hans Löschenkohl										   *
//******************************************************************************************

User Function TIMETOSEC(cHora, cMostra)

   Local nSeg
   Local nMin
   Local nHora

   IF U_P_OCCURS(cHora,":",1) > 0
      cHora = SUBSTR(cHora,1,2) + SUBSTR(cHora,4,2)
   ENDIF

   nMin  := VAL(SUBSTR(cHora,3,2)) * 60
   nHora := ( VAL(SUBSTR(cHora,1,2)) * 60 ) * 60
   nSeg  := INT(nMin + nHora)
   
   If cMostra == 1
      MsgAlert(nSeg)
   Endif   

RETURN nSeg

//******************************************************************************************
// Processo  : P_SECTOTIME(cSeg)      										               *
// Objetivo  : Transforma Segundos em Horas                                                *
// Parâmetros: cSeg - Segundos a serem convertidos                                         *
//******************************************************************************************
// Criado em 15/02/2013 - Harald Hans Löschenkohl										   *
//******************************************************************************************

User Function SECTOTIME(nSeg)

   Local nMin 
   Local nHora
   Local nResto

   nMin   = nSeg / 60
   nHora  = INT(nMin / 60)
   nResto = INT(MOD(nMin,60))

RETURN Strzero(nHora,2) + ":" + Strzero(nResto,2)