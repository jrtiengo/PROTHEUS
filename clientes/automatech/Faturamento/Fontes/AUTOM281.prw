#INCLUDE "PROTHEUS.ch"
#Include "TOTVS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM281.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/03/2015                                                          *
// Objetivo..: Programa customizado de mensagens de aviso do Sistema               *
//**********************************************************************************

User Function AUTOM281(_Mensagem)

   Local cMensagem := _Mensagem
   Local oMensagem

   Private oDlgMsg

   U_AUTOM628("AUTOM281")
   
   DEFINE MSDIALOG oDlgMsg TITLE "" FROM C(178),C(181) TO C(380),C(658) PIXEL  && STYLE nOR(WS_VISIBLE,WS_POPUP)

   @ C(002),C(002) Jpeg FILE "mensagempro.bmp" Size C(252),C(116) PIXEL NOBORDER OF oDlgMsg

   @ C(019),C(040) GET oMensagem Var cMensagem MEMO Size C(195),C(064) PIXEL OF oDlgMsg

   @ C(087),C(198) Button "Voltar" Size C(037),C(010) PIXEL OF oDlgMsg ACTION( oDlgMsg:End() )

   ACTIVATE MSDIALOG oDlgMsg CENTERED 

Return(.T.)