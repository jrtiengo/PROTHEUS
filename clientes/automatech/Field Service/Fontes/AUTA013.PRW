#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTA013.PRW                                                              ##
// Par�metros: Nenhum                                                                   ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Gilmar Coelho - Empresa Solutio                                          ##
// Data......: 08/11/2013                                                               ##
// Objetivo..: Edita Inf. Interna em O.S. com status encerrado                          ##
// #######################################################################################

User Function AUTA013()

   Local lChumba    := .F.
   Local _lRet      := .T.
   Local cMemo1	    := ""
   Local oMemo1
      
   Private kData	:= Date()
   Private kHora	:= Time()
   Private kUsuario := Upper(Alltrim(cUserName))
   Private kNumOS   := AB6->AB6_NUMOS
   Private kInterna := AB6->AB6_MINTER

   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo2

   Private oDlg

   If (AB6->AB6_STATUS == "E" .OR. AB6->AB6_STATUS="B" )

      DEFINE MSDIALOG oDlg TITLE "Informa��es Internas da OS" FROM C(178),C(181) TO C(498),C(702) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(254),C(001) PIXEL OF oDlg

      @ C(037),C(005) Say "Observa��es Internas da Ordem de Servi�o N� " + Alltrim(kNumOS) Size C(136),C(008) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(047),C(005) GET   oMemo2 Var kInterna MEMO Size C(251),C(088) PIXEL OF oDlg

      @ C(144),C(180) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( salvarMemo() )
      @ C(144),C(219) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

      ACTIVATE MSDIALOG oDlg CENTERED 

   Else

  	  _lRet := .F.

   	  MsgAlert("Aten��o, esta op��o deve ser usada somente para ordem de servi�o encerrada." )

   EndIf

Return(_lRet)

// ##################################################################################
// Fun��o que sal�va a observa��es interna bem como data e hora da Devolu��o da OS ##
// ##################################################################################
Static Function salvarMemo()
	
   RecLock("AB6",.F.)
   AB6->AB6_MINTER := kInterna
   MsUnlock()
	
   oDlg:End()
	  
Return()