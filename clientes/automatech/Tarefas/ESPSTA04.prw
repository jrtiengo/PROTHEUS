#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPSTA04.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/02/2012                                                          *
// Objetivo..: Programa de Mostra o Fluxo das Tarefas                              *
//**********************************************************************************

User Function ESPSTA04()

   Local cMemo1	 := ""
   Local cMemo10 := ""
   Local cMemo11 := ""
   Local cMemo12 := ""
   Local cMemo13 := ""
   Local cMemo14 := ""
   Local cMemo15 := ""
   Local cMemo16 := ""
   Local cMemo17 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo6	 := ""
   Local cMemo7	 := ""
   Local cMemo8	 := ""
   Local cMemo9	 := ""
   Local oMemo1
   Local oMemo10
   Local oMemo11
   Local oMemo12
   Local oMemo13
   Local oMemo14
   Local oMemo15
   Local oMemo16
   Local oMemo17
   Local oMemo2
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo6
   Local oMemo7
   Local oMemo8
   Local oMemo9

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Fluxo das Tarefas" FROM C(178),C(181) TO C(623),C(612) PIXEL

   // Cria as Groups do Sistema
   @ C(001),C(002) TO C(201),C(212) LABEL "Fluxo das Tarefas" PIXEL OF oDlg

   @ C(012),C(014) Button "ABERTURA"            Size C(037),C(012) PIXEL OF oDlg
   @ C(013),C(121) Button "APROVAÇÃO"           Size C(037),C(012) PIXEL OF oDlg
   @ C(045),C(076) Button "APROVADO"            Size C(037),C(012) PIXEL OF oDlg
   @ C(045),C(167) Button "REPROVADO"           Size C(037),C(012) PIXEL OF oDlg
   @ C(067),C(076) Button "DESENV."             Size C(037),C(012) PIXEL OF oDlg
   @ C(089),C(075) Button "VALIDAÇÃO"           Size C(037),C(012) PIXEL OF oDlg
   @ C(119),C(018) Button "VALIDAÇÃO NÃO OK"    Size C(061),C(012) PIXEL OF oDlg
   @ C(119),C(103) Button "VALIDAÇÃO OK"        Size C(075),C(012) PIXEL OF oDlg
   @ C(141),C(103) Button "LIBERADO P/PRODUÇÃO" Size C(075),C(012) PIXEL OF oDlg
   @ C(162),C(103) Button "EM PRODUÇÃO"         Size C(075),C(012) PIXEL OF oDlg
   @ C(183),C(103) Button "TAREFA ENCERRADA"    Size C(075),C(012) PIXEL OF oDlg

   @ C(018),C(052) GET oMemo1  Var cMemo1  MEMO Size C(068),C(001) PIXEL OF oDlg
   @ C(026),C(139) GET oMemo2  Var cMemo2  MEMO Size C(001),C(010) PIXEL OF oDlg
   @ C(035),C(094) GET oMemo3  Var cMemo3  MEMO Size C(091),C(001) PIXEL OF oDlg
   @ C(035),C(185) GET oMemo5  Var cMemo5  MEMO Size C(001),C(010) PIXEL OF oDlg
   @ C(036),C(093) GET oMemo4  Var cMemo4  MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(057),C(093) GET oMemo6  Var cMemo6  MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(072),C(008) GET oMemo13 Var cMemo13 MEMO Size C(066),C(001) PIXEL OF oDlg
   @ C(073),C(008) GET oMemo11 Var cMemo11 MEMO Size C(001),C(052) PIXEL OF oDlg
   @ C(079),C(093) GET oMemo15 Var cMemo15 MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(101),C(093) GET oMemo7  Var cMemo7  MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(109),C(048) GET oMemo8  Var cMemo8  MEMO Size C(092),C(001) PIXEL OF oDlg
   @ C(109),C(048) GET oMemo9  Var cMemo9  MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(109),C(140) GET oMemo10 Var cMemo10 MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(125),C(008) GET oMemo12 Var cMemo12 MEMO Size C(010),C(001) PIXEL OF oDlg
   @ C(132),C(140) GET oMemo14 Var cMemo14 MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(154),C(140) GET oMemo16 Var cMemo16 MEMO Size C(001),C(009) PIXEL OF oDlg
   @ C(174),C(140) GET oMemo17 Var cMemo17 MEMO Size C(001),C(009) PIXEL OF oDlg

   @ C(204),C(174) Button "VOLTAR" Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)