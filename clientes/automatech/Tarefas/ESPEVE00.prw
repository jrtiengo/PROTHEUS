#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE00.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/10/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Eventos                       *
//**********************************************************************************

User Function ESPEVE00()

   Local nContar     := 0

   Private aComboBx1 := {}
   Private cComboBx1

   For nContar = 2012 to (Year(Date()) + 5)
       aAdd( aComboBx1, Strzero(nContar,4) )
   Next nContar    

   cComboBx1 := Strzero(Year(Date()),4)

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Eventos" FROM C(178),C(181) TO C(288),C(434) PIXEL

   @ C(005),C(005) Say "Indique o Ano dos eventos a serem pesquisados" Size C(116),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(040) Say "Ano"                                           Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(017),C(054) ComboBox cComboBx1 Items aComboBx1 Size C(029),C(010) PIXEL OF oDlg

   @ C(036),C(024) Button "OK"     Size C(037),C(012) PIXEL OF oDlg ACTION(U_ESPEVE01(cComboBx1))
   @ C(036),C(062) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)