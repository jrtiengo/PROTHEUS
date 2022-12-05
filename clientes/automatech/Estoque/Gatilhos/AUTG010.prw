#include "rwmake.ch"
#include "topconn.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTG010.PRW                                                         ##
// Par�metros: Nenhum                                                              ##
// Tipo......: Gatilho                                                             ##
// Campo.....: A2_CGC                                                              ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 23/04/2018                                                          ##
// Objetivo..: Rotina chamada no inicializador padr�o do campo B1_COD (Produtos)   ##
// Par�metros: Sem Par�metros                                                      ##
// Retorno...: Novo codigo de produto na inclus�o do Cadastro de Produtos          ##
// ##################################################################################

User Function AUTG010()

   Local cNewNum := Space(30)
   Local lCopia  := .f.

   U_AUTOM628("AUTG010")                         
   
   For _nI := 1 to 10
       If Procname(_nI) <> Nil
	      If Alltrim(ProcName(_nI)) == "A010COPIA"
		     lCopia  := .t.
	      Endif
       Endif
   Next

   // ############################################################################################
   // Alterado por Jean Rehermann em 28-05-2012 | Substitui��o da fun��o ProcName por FunName   ##
   // IF lCopia .or. (ALLTRIM(ProcName(12)) == "MATA010" .and. INCLUI)                          ##
   // ALTERADO EM 11/07/16 POR BRUNO SPERB  fun��o n�o deve considerar produtos de m�o de obra  ##
   // ############################################################################################
   IF lCopia .or. (ALLTRIM(FunName()) == "MATA010" .and. INCLUI)
      cSql     := "SELECT TOP 1 B1_COD AS 'B1_COD' FROM SB1010 WHERE LEN(LTRIM(RTRIM(B1_COD))) = 6 AND B1_COD NOT LIKE 'MOD%' ORDER BY B1_COD DESC "
      dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"SB1QRY", .F., .T.)
      DbSelectArea("SB1QRY")
      DBGOTOP()
      cAtuNum  := ALLTRIM(SB1QRY->B1_COD)
      DbCloseArea()
      cNewNum  := SOMA1(cAtuNum)+REPL(" ",24)
   Else
      cNewNum := GETSXENUM("SB1","B1_COD")
   ENDIF

Return(cNewNum)