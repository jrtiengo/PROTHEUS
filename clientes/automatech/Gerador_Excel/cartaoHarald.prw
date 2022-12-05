#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM591.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 03/07/2017                                                          ##
// Objetivo..: Programa que realiza a baixa de títulos pela leitura do arquivo de  ##
//             conciliação da CONCIL.                                              ##
// ##################################################################################

User Function cartaoHarald()

   Local lChumba := .F.
   Local cMemo1  := ""
   Local cMemo2  := ""

   Local oMemo1
   Local oMemo2

   Local kPedido     := ""
   Local kCliente    := ""
   Local aAdministra := {}
   Local aBandeiras  := {}
   Local kDigi       := ""
   Local kEmissao    := ""
   Local kDocumento  := ""
   Local kAutoriza   := ""
   Local kNumTid     := ""
   Local kValorCart  := ""

   Local oGet1     
   Local oGet2     
   Local cComboBx2 
   Local cComboBx3 
   Local oGet3     
   Local oGet4     
   Local oGet5     
   Local oGet6     
   Local oGet7     
   Local oGet8     

      DEFINE MSDIALOG oDlgX TITLE "Informação Dados Cartão de Crédito" FROM C(178),C(181) TO C(483),C(735) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgX

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(270),C(001) PIXEL OF oDlgX
      @ C(129),C(002) GET oMemo2 Var cMemo2 MEMO Size C(270),C(001) PIXEL OF oDlgX

      @ C(037),C(005) Say "Nº Ped.Venda"   Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(037),C(046) Say "Cliente"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(059),C(005) Say "Administradora" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(081),C(005) Say "Bandeira"       Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(005) Say "Ult.4 Dig."     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(035) Say "Dt.Transação"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(079) Say "Documento"      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(126) Say "Autorização"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(172) Say "TID"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(218) Say "Valor Cartão"   Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

      @ C(046),C(005) MsGet    oGet1     Var   kPedido     Size C(035),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX When lChumba
      @ C(046),C(046) MsGet    oGet2     Var   kCliente    Size C(226),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX When lChumba
      @ C(068),C(005) ComboBox cComboBx2 Items aAdministra Size C(269),C(010)                                         PIXEL OF oDlgX
      @ C(090),C(005) ComboBox cComboBx3 Items aBandeiras  Size C(269),C(010)                                         PIXEL OF oDlgX
      @ C(113),C(005) MsGet    oGet3     Var   kDigi       Size C(024),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(035) MsGet    oGet4     Var   kEmissao    Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(079) MsGet    oGet5     Var   kDocumento  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(126) MsGet    oGet6     Var   kAutoriza   Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(172) MsGet    oGet7     Var   kNumTid     Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(218) MsGet    oGet8     Var   kValorCart  Size C(056),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgX

      @ C(135),C(100) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgX 
      @ C(135),C(138) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

      ACTIVATE MSDIALOG oDlgX CENTERED 
      
Return(.T.)