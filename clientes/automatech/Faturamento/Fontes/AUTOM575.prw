#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM575.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 24/05/2017                                                          ##
// Objetivo..: Programa que Emisste Boleto Banc�rio                                ##
//             do Site.                                                            ##
// ##################################################################################

User Function AUTOM575()

   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local lSantander	:= .T.
   Local lItau   	:= .T.

   Local oCheckBox1
   Local oCheckBox2

   Local oMemo1
   Local oMemo2

   Private cRetorno   := ""
   
   Private oDlg

   U_AUTOM628("AUTOM575")
   
   // ###############################################################################
   // Pesquisa o par�metro automatech para ver em que banco o boleto ser� impresso ##
   // ###############################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TBOL FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   Do Case
      Case T_PARAMETROS->ZZ4_TBOL == "1"
           Return("1")
      Case T_PARAMETROS->ZZ4_TBOL == "2"
           Return("2")
      Case T_PARAMETROS->ZZ4_TBOL == "3"                     
           lSantander := .F.
           lItau      := .F.                  
   EndCase

   // #########################################################################################
   // Desenha a tela para sele��o do banco a ser utilizado para emiss�o de boletos banc�rios ##
   // #########################################################################################
   DEFINE MSDIALOG oDlg TITLE "Boleto Banc�rio" FROM C(178),C(181) TO C(386),C(462) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(134),C(001) PIXEL OF oDlg
   @ C(080),C(002) GET oMemo2 Var cMemo2 MEMO Size C(134),C(001) PIXEL OF oDlg
   
   @ C(038),C(005) Say "Indique abaixo o Banco a ser utilizado para emiss�o de Boleto" Size C(132),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(052),C(035) CheckBox oCheckBox1 Var lSantander Prompt "Banco Santander" Size C(053),C(008) PIXEL OF oDlg
   @ C(064),C(035) CheckBox oCheckBox2 Var lItau      Prompt "Banco Ita�"      Size C(048),C(008) PIXEL OF oDlg

   @ C(087),C(030) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( VaiRetornar( lSantander, lItau ) )
   @ C(087),C(070) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( cRetorno := "0", oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(cRetorno)

// #############################################################
// Fun��o que consiste os dados e retorna o banco selecionado ##
// #############################################################
Static Function VaiRetornar(lSantander, lItau)

   If lSantander == .F. .And. lItau == .F.
      MsgAlert("Necess�rio indicar um banco para emiss�o de boletos.")
      Return(.T.)
   Endif

   Do Case 
      Case lSantander == .T. .And. lItau == .F.
           cRetorno := "1"
      Case lSantander == .F. .And. lItau == .T.
           cRetorno := "2"
   EndCase
   
   oDlg:End()
   
Return(cRetorno)