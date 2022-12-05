#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR47.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/02/2012                                                          *
// Objetivo..: Programa tela das Mais Opções do Cadastro de Clientes.              *
//**********************************************************************************

User Function AUTOMR47()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlg

   U_AUTOM628("AUTOMR47")
   
   DEFINE MSDIALOG oDlg TITLE "Opções ..." FROM C(178),C(181) TO C(534),C(469) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(137),C(001) PIXEL OF oDlg

   @ C(036),C(005) Button "Consulta Serasa CREDNET"           Size C(133),C(016) PIXEL OF oDlg ACTION(U_AUTOM151())
   @ C(053),C(005) Button "Histórico Consulta Serasa CREDNET" Size C(133),C(016) PIXEL OF oDlg ACTION(U_AUTOMR44(M->A1_COD, M->A1_LOJA, M->A1_NOME))
   @ C(071),C(005) Button "Consulta Serasa RELATO"            Size C(133),C(016) PIXEL OF oDlg ACTION(U_AUTOM303(M->A1_COD, M->A1_LOJA, M->A1_NOME, M->A1_CGC))
   @ C(088),C(005) Button "Histórico Consulta Serasa RELATO"  Size C(133),C(016) PIXEL OF oDlg ACTION(U_AUTOM302(M->A1_COD, M->A1_LOJA, M->A1_NOME, M->A1_CGC, 0))
   @ C(106),C(005) Button "Pendência Financeira Consolidada"  Size C(133),C(016) PIXEL OF oDlg ACTION(U_AUTOM207(M->A1_COD, M->A1_NOME))
   @ C(123),C(005) Button "Etiqueta de Endereçamento Postal"  Size C(133),C(016) PIXEL OF oDlg ACTION(U_AUTOMR48())
   @ C(140),C(005) Button "Cliente X  Contrato"               Size C(133),C(016) PIXEL OF oDlg ACTION(U_AUTOMR61(M->A1_COD, M->A1_LOJA))
   @ C(158),C(005) Button "Voltar"                            Size C(133),C(016) PIXEL OF oDlg ACTION(oDlg:End())

   ACTIVATE MSDIALOG oDlg CENTERED 


Return(.T.)