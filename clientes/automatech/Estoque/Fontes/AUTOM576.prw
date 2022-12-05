#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM576.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 25/05/2017                                                               ##
// Objetivo..: Programa que corrige a SB2 para a Atech                                  ##
// #######################################################################################

User Function AUTOM576()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cProduto   := Space(30)
   Private cDescricao := Space(60)
   Private oGet1
   Private oGet2
 
   Private oDlg

   U_AUTOM628("AUTOM576")

   DEFINE MSDIALOG oDlg TITLE "Corrige SB2" FROM C(178),C(181) TO C(353),C(630) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(218),C(001) PIXEL OF oDlg
   @ C(063),C(002) GET oMemo2 Var cMemo2 MEMO Size C(218),C(001) PIXEL OF oDlg
   
   @ C(037),C(005) Say "Código Produto"       Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(071) Say "Descrição do Produto" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(005) MsGet oGet1 Var cProduto   Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( CaptaProduto() )
   @ C(047),C(071) MsGet oGet2 Var cDescricao Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(069),C(005) Button "Saldo"    Size C(053),C(012) PIXEL OF oDlg ACTION( SldCampoB2() )
   @ C(069),C(111) Button "Confirma" Size C(053),C(012) PIXEL OF oDlg ACTION( AltCampoB2() )
   @ C(069),C(166) Button "Voltar"   Size C(053),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################
// Função que pesquisa a descrição do produto ##
// #############################################
Static Function CaptaProduto()

   If Empty(Alltrim(cProduto))
      cProduto   := Space(30)
      cDescricao := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      Return(.T.)
   Endif
   
   If Len(alltrim(cProduto)) <= 6
      MsgAlert("Produto informado não é etiqueta.")
      cProduto   := Space(30)
      cDescricao := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      Return(.T.)
   Endif

   cDescricao := Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC")

   If Empty(Alltrim(cProduto))
      MsgAlert("Produto não localizado.")
      cProduto   := Space(30)
      cDescricao := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      Return(.T.)
   Endif

Return(.T.)

// ##############################
// Função que altera os campos ##
// ##############################
Static Function AltCampoB2()

   Local cSql := ""

   If Empty(Alltrim(cProduto))
      Msgalert("Produto a ser alterado não informado.")
      Return(.T.)
   Endif

   dbSelectArea("SB2")
   dbSetOrder(1)
   If dbSeek( xFilial("SB2") + cProduto + "01" )
	  RecLock("SB2",.F.)
	  SB2->B2_QEMPN   := 0
	  SB2->B2_RESERVA := 0
	  MsUnLock()
   Endif

   MsgAlert("Registro alterado com sucesso.")

   cProduto   := Space(30)
   cDescricao := Space(60)
   oGet1:Refresh()
   oGet2:Refresh()

Return(.T.)

// ##########################################################################
// Função que pesquisa o saldo do produto ou componente conforme parâmetro ##
// ##########################################################################
Static Function SldCampoB2()

   If Empty(Alltrim(cProduto))
      MsgAlert("Produto a ser pesquisado não informado.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + cProduto)

   MaViewSB2(cProduto)

   RestArea( aArea )

Return(.T.)