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

// ###############################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                        ##
// -------------------------------------------------------------------------------------------- ##
// Referencia: AUTOM645.PRW                                                                     ##
// Parâmetros: Nenhum                                                                           ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                  ##
// -------------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                          ##
// Data......: 09/10/2017                                                                       ##
// Objetivo..: Programa que pesquisa a cotação do dolar no Banco Central na entrada do Sistema. ##
// ###############################################################################################

User Function AUTOM645()

   Local lChumba  := .F.
   Local cMemo1	  := ""
   Local oMemo1
   
   Private lEditar    := .F.
   Private cCotacao   := Date()
   Private nTaxaDolar := 0

   Private oGet1
   Private oGet2

   Private oDlg

   kTaxaBcoCentral()

//   DEFINE MSDIALOG oDlg TITLE "Taxa do Dolar" FROM C(178),C(181) TO C(359),C(446) PIXEL
//
//   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlg
//
//   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(126),C(001) PIXEL OF oDlg
//
//   @ C(034),C(005) Say "Pesquisa Taxa do Dolar pelo Site do Banco Central" Size C(123),C(008) COLOR CLR_BLACK PIXEL OF oDlg
//   @ C(046),C(011) Say "Taxa do Dia"                                       Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
//   @ C(046),C(062) Say "Taxa"                                              Size C(018),C(007) COLOR CLR_BLACK PIXEL OF oDlg
//
//   @ C(056),C(011) MsGet oGet1 Var cCotacao   Size C(034),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlg
//   @ C(056),C(062) MsGet oGet2 Var nTaxaDolar Size C(041),C(009) COLOR CLR_BLACK Picture "@E 99999.99999" PIXEL OF oDlg When lChumba
//
//   @ C(072),C(010) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( kTaxaBcoCentral() )
//   @ C(072),C(048) Button "Salvar"    Size C(037),C(012) PIXEL OF oDlg ACTION( GravaTaxaDolar() ) When lEditar
//   @ C(072),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
//
//   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################################
// Função que pesquisa a taxa do dolar pelo site do Banco Central ##
// #################################################################
Static Function kTaxaBcoCentral()

   MsgRun("Aguarde! Pesquisando taxa do Dolar ...", "Banco Central do Brasil",{|| xkTaxaBcoCentral() })

Return(.T.)

// #################################################################
// Função que pesquisa a taxa do dolar pelo site do Banco Central ##
// #################################################################
Static Function xkTaxaBcoCentral()

   Local cComando    := "http://www4.bcb.gov.br/Download/fechamento/"
   Local cRetorno    := "C:\TAXADOLAR\RETDOLAR.TXT"
   Local nTentativas := 0
   Local cSTIM       := 15000000
   Local dPesquisar  := cCotacao
   Local dDataGrava  := cCotacao

   If _TaxaDolar <> nil
      _TaxaDolar := .T.
   Endif   

//   If cCotacao == Ctod("  /  /    ")
//      MsgAlert("Data a ser pesquisada não informada. Verifique!")
//      Return(.T.)
//   Endif   

   dPesquisar := dPesquisar - 1

   // ####################################################################
   // Verifica se a taxa do dolar já está cadastrada para a data do dia ##
   // ####################################################################
   DbSelectArea("SM2")
   dbSetOrder(1)
   If dbSeek( Dtos( dDataGrava ) )
      Return(.T.)
   Endif

   // ###############################################################################################
   // Verifica se existe a pasta TAXADOLAR no equipamento do usuário. Caso não exista, será criada ##
   // ###############################################################################################
   If !ExistDir( "C:\TAXADOLAR" )

      nRet := MakeDir( "C:\TAXADOLAR" )
   
   Endif

   // #################################
   // Seta a data para um dia válido ##
   // #################################
   Do Case
      Case Dow(dPesquisar) == 1 // Domingo
           dPesquisar := dPesquisar - 2
      Case Dow(dPesquisar) == 2 // Segunda
           dPesquisar := dPesquisar - 3
      Case Dow(dPesquisar) == 7 // Sábado
           dPesquisar := dPesquisar - 1
   EndCase           

   dPesquisar := Strzero(Year(dPesquisar),4) + Strzero(Month(dPesquisar),02) + Strzero(day(dPesquisar),2)

   cComando := cComando + dPesquisar + ".csv"

   // #############################################
   // Fecha o arquivo de retorno para eliminação ##
   // #############################################
   FCLOSE(cRetorno)

   // ##############################################################################
   // Elimina o Arquivo para receber nova cotação do dolar no diretório TAXADOLAR ##
   // ##############################################################################
   FERASE(cRetorno)

   // ##################################################
   // Envia a solicitação de cotação da taxa do dolar ##
   // ##################################################
   WaitRun('AtechHttpget.exe' + ' "' + cComando + '" ' + cRetorno, SW_SHOWNORMAL )
   
   // ###########################
   // Lê o retorno da consulta ##
   // ###########################
//   lExiste     := .F.
//   nTentativas := 0
//
//   while nTentativas < cSTIM
//
//      If File(cRetorno)
//         lExiste := .T.
//         Exit
//      Endif
//
//      nTentativas := nTentativas + 1
//
//   Enddo
//
//   If lExiste == .F.
//      Return(.T.)
//   Endif

   If File(cRetorno)
   Else
      Return(.T.)
   Endif   

   // ##########################################
   // Trata o retorno do envio da solicitação ##
   // ##########################################

   // #################################################################################
   // Abre o arquivo de retorno para capturar o código do ticket gerado no freshdesk ##
   // #################################################################################
   nHandle := FOPEN("C:\TAXADOLAR\RETDOLAR.TXT", FO_READWRITE + FO_SHARED)
      
   If FERROR() != 0
//    MsgAlert("Erro ao abrir o arquivo de retorno da consulta da taxa do dolar em C:\TAXADOLAR\RETDOLAR.TXT")
      Return .T.
   Endif

   // ################################
   // Lê o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // Lê todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   FCLOSE(nHandle)

   // ################################################
   // Captura todo o retorno recebido pára gravação ##
   // ################################################
   kString := xBuffer

   // ###########################
   // Pesquisa a taxa do Dolar ##
   // ###########################
   For nContar = 1 to U_P_OCCURS(xBuffer, CHR(13), 1)

       cSepara := U_P_CORTA(xBuffer, CHR(13), nContar)                                                        
       
       If U_P_CORTA(cSepara, ";", 2) <> "155"
          Loop
       Endif
       
       If U_P_CORTA(cSepara, ";", 4) <> "BSD"
          Loop
       Endif

       nTaxaDolar := Val(StrTran(U_P_CORTA(cSepara, ";", 6), ",", "."))

       If nTaxaDolar == 0
          lEditar := .F.
       Else
          lEditar := .T.
       Endif      

   Next nContar

   GravaTaxaDolar()
 
Return(.T.)

// #####################################
// Função que grava a taxa pesquisada ##
// #####################################
Static Function GravaTaxaDolar()

   If nTaxaDolar == 0
      Return(.T.)
   Endif
   
   DbSelectArea("SM2")
   dbSetOrder(1)
   If dbSeek( Dtos( cCotacao ) )
   Else
	  RecLock("SM2",.T.)
	  SM2->M2_DATA   := cCotacao
	  SM2->M2_MOEDA2 := nTaxaDolar
      MsUnlock()
   EndIf

   cCotacao   := Date()
   nTaxaDolar := 0

Return(.T.)