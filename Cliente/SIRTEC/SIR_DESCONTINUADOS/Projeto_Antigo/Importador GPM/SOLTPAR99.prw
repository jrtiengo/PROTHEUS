#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #######################################################################################
// SOLUTIO IT SOLU��ES CORPORATIVAS                                                     ##
// ------------------------------------------------------------------------------------ ##
// Referencia: SOLTPAR99.PRW                                                            ##
// Par�metros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans L�schenkohl                                                  ##
// Data......: 25/06/2019                                                               ##
// Objetivo..: Programa uqe chama os programas dos parametrizadores de importa��o de OS ##
// #######################################################################################

User Function SOLTPAR99()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2
   
   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Par�metros GPM" FROM C(178),C(181) TO C(569),C(398) PIXEL

   @ C(069),C(005) GET oMemo1 Var cMemo1 MEMO Size C(100),C(001) PIXEL OF oDlg
   @ C(140),C(005) GET oMemo2 Var cMemo2 MEMO Size C(100),C(001) PIXEL OF oDlg

   @ C(002),C(005) Button "Cadastro de Contratos"            Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR80() )
   @ C(018),C(005) Button "Cadastro Centros de Servi�os"     Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPCS81() )
   @ C(034),C(005) Button "Cadastro Tipos de Servi�os"       Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPTS81() )
   @ C(050),C(005) Button "Cadastro de Servi�os"             Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPCC80() )
   @ C(073),C(005) Button "Par�metros Cria��o de OS"         Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR01() )
   @ C(089),C(005) Button "Par�metros Tipos de Servi�os"     Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR30() )
   @ C(105),C(005) Button "Par�metros Itens Atendimento"     Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR13() )
   @ C(121),C(005) Button "Par�metros Atendimento Equipe"    Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR24() )
   @ C(143),C(005) Button "Diret�rio Arquivos de Importa��o" Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR67() )
   @ C(159),C(005) Button "Email Envio de Logs"              Size C(100),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR76() )
   @ C(175),C(005) Button "Retornar"                         Size C(100),C(015) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)