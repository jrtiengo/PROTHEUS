#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"                                             
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM693.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ## 
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 25/07/2018                                                            ##
// Objetivo..: Programa que mostra os detalhes de pedidos e notas das OS             ##
// #################################################################################### 

User Function AUTOM693()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo
      
   Private kNumOS	:= AB6->AB6_NUMOS
   Private kCliente := AB6->AB6_CODCLI + "." + AB6->AB6_LOJA + " - " + POSICIONE("SA1",1,XFILIAL("SA1") + AB6->AB6_CODCLI + AB6->AB6_LOJA, "A1_NOME")
   Private kPedidos := ""
   Private kNotas   := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlg

   BSKDetalhes()

   DEFINE MSDIALOG oDlg TITLE "Consulta Pedidos/Notas Fiscais de OSs" FROM C(178),C(181) TO C(417),C(580) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(194),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Nr. OS"                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(041) Say "Nome do Cliente"                        Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Pedido(s) de Venda relacionado(s) a OS" Size C(095),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(080),C(005) Say "Nota(s) Fiscal(is) relacionada(s) a OS" Size C(095),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(044),C(005) MsGet oGet1 Var kNumos   Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(044),C(041) MsGet oGet2 Var kCliente Size C(155),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(067),C(004) MsGet oGet3 Var kPedidos Size C(192),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(089),C(005) MsGet oGet4 Var kNotas   Size C(192),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(103),C(083) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################################################################
// Função que pesquisa o número do pedido de venda e notas fiscais relacionadas a ordem de serviço ##
// ##################################################################################################
Static Function BSKDetalhes()
           
   MsgRun("Aguarde! Pesquisando Detalhes da OS ...", "Detalhes da OS",{|| kBSKDetalhes() })
   
Return(.T.)
   
// ##################################################################################################
// Função que pesquisa o número do pedido de venda e notas fiscais relacionadas a ordem de serviço ##
// ##################################################################################################
Static Function kBSKDetalhes()
   
   kPedidos := U_AUTOMR70(kNumos, cFilAnt, 1)
   kNotas   := U_AUTOMR70(kNumos, cFilAnt, 2)
   
Return(.T.)