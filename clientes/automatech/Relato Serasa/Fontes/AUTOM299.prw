#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM299.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/07/2015                                                          *
// Objetivo..: Programa que permite realizar a alteração do vencinto do título do  *
//             Contas a Receber. Isso se fez necessário em razão  da  geração  do  *
//             arquivo RELATO para o SERASA.                                       *
//**********************************************************************************

User Function AUTOM299()
                      
   Local lChumba := .F.
   
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private cCliente     := SE1->E1_CLIENTE
   Private cLoja        := SE1->E1_LOJA
   Private cNome        := Posicione("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_NOME")
   Private cPrefixo     := SE1->E1_PREFIXO
   Private cTitulo      := SE1->E1_NUM
   Private cParcela     := SE1->E1_PARCELA
   Private cTipo        := SE1->E1_TIPO
   Private cEmissao     := SE1->E1_EMISSAO
   Private cVencimento  := SE1->E1_VENCTO
   Private cReal        := SE1->E1_VENCREA

   Private oGet1
   Private oGet10
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9

   Private oDlg

   If SE1->E1_SALDO == 0
      MsgAlert("Alteração não permitida. Título já está quitado.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlg TITLE "Alteração de Vencimento de Título" FROM C(178),C(181) TO C(459),C(637) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(138),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(219),C(001) PIXEL OF oDlg
   @ C(083),C(005) GET oMemo2 Var cMemo2 MEMO Size C(219),C(001) PIXEL OF oDlg
   @ C(116),C(005) GET oMemo3 Var cMemo3 MEMO Size C(219),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Cliente"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(005) Say "Prefixo"    Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(031) Say "Data Final" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(084) Say "Parcela"    Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(112) Say "Tipo"       Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(027) Say "Emissão"    Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(091) Say "Vencimento" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(154) Say "Vctº Real"  Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) MsGet oGet3  Var cCliente Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(039) MsGet oGet4  Var cLoja    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(071) MsGet oGet5  Var cNome    Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(065),C(157) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg

   @ C(068),C(005) MsGet oGet6  Var cPrefixo    Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(068),C(031) MsGet oGet1  Var cTitulo     Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(068),C(084) MsGet oGet2  Var cParcela    Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(068),C(112) MsGet oGet7  Var cTipo       Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(100),C(027) MsGet oGet8  Var cEmissao    Size C(047),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(100),C(091) MsGet oGet9  Var cVencimento Size C(047),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(100),C(154) MsGet oGet10 Var cReal       Size C(047),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(123),C(055) Button "Confirma Alteração" Size C(057),C(012) PIXEL OF oDlg ACTION( ConfDatas() )
   @ C(123),C(113) Button "Voltar"             Size C(057),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava a alteração dos vencimento
Static Function ConfDatas()

   If Empty(cVencimento)
      Msgalert("Data de Vencimento não informada. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(cReal)
      Msgalert("Data de Vencimento Real não informada. Verifique!")
      Return(.T.)
   Endif

   // Pesquisa o registro para alteração
   DbSelectArea("SE1")
   DbSetOrder(1)
   If DbSeek(xfilial("SE1") + cPrefixo + cTitulo + cParcela + cTipo)
      RecLock("SE1",.F.)
      E1_VENCTO  := cVencimento
      E1_VENCREA := cReal
      E1_ZAVC    := "S"
      E1_ZDVC    := Date()
      MsUnLock()              
   Endif

   MsgAlert("Vencimentos alterados com sucesso.")
   
   oDlg:End()

Return(.T.)