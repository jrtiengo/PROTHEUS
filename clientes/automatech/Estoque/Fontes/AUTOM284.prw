#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM284.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 26/03/2015                                                          *
// Objetivo..: Alerta do Sistema para os procedimentos MATA240 - Internos e        *
//             MATA241 - Internos(2)                                               *
//**********************************************************************************

User Function AUTOM284()                                                            

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlg

   U_AUTOM628("AUTOM284")

   DEFINE MSDIALOG oDlg TITLE "A l e r t a" FROM C(178),C(181) TO C(346),C(555) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(146),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(178),C(001) PIXEL OF oDlg

   @ C(041),C(005) Say "ATEN��O"                                                Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(005) Say "ESTE PROCEDIMENTO N�O EST� MAIS DISPON�VEL NO SISTEMA." Size C(173),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(066),C(143) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)