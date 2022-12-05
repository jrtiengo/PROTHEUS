#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    
#Include "Rwmake.ch"
#Include "TopConn.ch"
#Define ENTER CHR(13)+CHR(10)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM682.PRW                                                             ##
// Par�metros: Nenhum                                                                   ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada  ( ) Valida��o           ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans L�schenkohl                                                  ##
// Data......: 09/03/2018                                                               ##
// Objetivo..: Programa que abre a janela de cadastro de contato de cliente pelo pedido ##
//             de venda. Caso o cliente informado n�o possuir um contato vinculado,sis- ##
//             tema abrir esta janela para que o usu�rio possa cadastrar um contato.    ##
// Par�metros: Nenhum                                                                   ##
// Retorno...: .T.                                                                      ##
// #######################################################################################

User Function AUTOM682(kCliente, kLoja, kNome)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private lRetornar := ""

   Private yCliente  := kCliente + "." + kLoja + " - " + Alltrim(kNome)
   Private yContato  := Space(060)
   Private yEmailCnt := Space(150)
   Private yDDDTele  := Space(003)
   Private yFone01   := Space(015)
   Private yFone02   := Space(015)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Contato de Cliente" FROM C(178),C(181) TO C(469),C(487) PIXEL Style DS_MODALFRAME

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(122),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(145),C(001) PIXEL OF oDlg
   @ C(123),C(002) GET oMemo2 Var cMemo2 MEMO Size C(145),C(001) PIXEL OF oDlg
   
   @ C(032),C(005) Say "Cliente"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(005) Say "Nome do Contato"   Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(077),C(005) Say "E-mail do Contato" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(099),C(005) Say "DDD"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(099),C(031) Say "Tel. 1� Contato"   Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(099),C(092) Say "Tel. 2� Contato"   Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(041),C(005) MsGet oGet1 Var yCliente  Size C(142),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(064),C(005) MsGet oGet2 Var yContato  Size C(142),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(086),C(005) MsGet oGet3 Var yEmailCnt Size C(142),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(109),C(005) MsGet oGet4 Var yDDDTele  Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(109),C(031) MsGet oGet5 Var yFone01   Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(109),C(092) MsGet oGet6 Var yFone02   Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(128),C(036) Button "Gravar" Size C(037),C(012) PIXEL OF oDlg ACTION( FECHACONTATO() )
   @ C(128),C(075) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( lRetorno := "", oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##########################################################################
// Fun��o que fecha a jenela e envia o conte�do para o programa que chamou ##
// ##########################################################################
Static Function FechaContato()

   If Empty(Alltrim(yContato))   
      MsgAlert("Nome do contato n�o informado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(yEmailCnt)) 
      MsgAlert("E-Mail do contato n�o informado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(yDDDTele))   
      MsgAlert("DDD n�o informado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(yFone01))    
      MsgAlert("Telefone do 1� contato n�o informado. Verifique!")
      Return(.T.)
   Endif

   lRetornar := "XXXXXX|" + Alltrim(yContato) + "|" + Alltrim(yEmailCnt) + "|" + Alltrim(yDDDTele) + "|" + Alltrim(yFone01) + "|" + Alltrim(yFone02) + "|"

   oDlg:End()

Return(lRetornar)   

   