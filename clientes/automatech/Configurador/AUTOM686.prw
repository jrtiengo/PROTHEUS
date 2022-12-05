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

// ##############################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                       ##
// ------------------------------------------------------------------------------------------- ##
// Referencia: AUTOM686.PRW                                                                    ##
// Parâmetros: Nenhum                                                                          ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                                  ##                       
// ------------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                         ##
// Data......: 20/04/2018                                                                      ##
// Objetivo..: Programa que poermite executar programas e funções fora menu                    ##
// Parâmetros: Sem parâmetros                                                                  ##
// Retorno...: Sem Retorno                                                                     ##
//###############################################################################################

User Function AUTOM686()

   Local cMemo1	 := ""
   Local oMemo1
      
   Private cString := Space(150)

   Private oGet1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Executar Programas" FROM C(178),C(181) TO C(323),C(543) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(115),C(022) PIXEL OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(175),C(001) PIXEL OF oDlg

   @ C(032),C(005) Say "Nome do programa/função a ser executado" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(042),C(005) MsGet oGet1 Var cString Size C(171),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(056),C(052) Button "Executar" Size C(037),C(012) PIXEL OF oDlg ACTION( ExecutaStr() )
   @ C(056),C(091) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################
// Função que executa o conteúdo do campo cString ##
// #################################################
Static Function ExecutaStr()
    
   Local cComando := Alltrim(cString)
  
   If Empty(Alltrim(cString))
      MsgAlert("Comando a ser executado não informado. Verifique!")
      Return(.T.)
   Endif
      
   &cComando           
   
   cString := Space(100)
   oGet1:refresh()
   
Return(.T.)