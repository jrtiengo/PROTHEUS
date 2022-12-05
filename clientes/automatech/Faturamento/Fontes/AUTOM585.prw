#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativa��o
#define SW_SHOW             5 // Mostra na posi��o mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posi��o anterior
#define SW_SHOWDEFAULT      10// Posi��o padr�o da aplica��o
#define SW_FORCEMINIMIZE    11// For�a minimiza��o independente da aplica��o executada
#define SW_MAX              11// Maximizada

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM585.PRW                                                            ##
// Par�metros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                 ##
// Data......: 02/08/2018                                                              ##
// Objetivo..: Programa que abre Ticket no freshdesk solicitando gera��o de guia GNRE  ##
// Par�metros: Sem Par�metros                                                          ##
// ######################################################################################

User Function AUTOM585( kDocumento, kSerie, kValor, kCnpj)
            	
   Local cString  := ""
   Local cSURL    := "https://automatech.freshdesk.com/api/v2/tickets"
   Local cEnvio   := "C:\FRESHDESK\ENVIO.TXT"
   Local cRetorno := "C:\FRESHDESK\RETORNO.TXT"
   Local nRet     := MakeDir( "C:\FRESHDESK" )   
   Local nTimeOut := 0
   Local aHeadOut := {}
   Local cHeadRet := ""
   Local sPostRet := Nil

   U_AUTOM628("AUTOM585")

   // ###########################################
   // Verifica se existe o diret�rio FRESHDESK ##
   // ###########################################
   If FILE("C:\FRESHDESK")
   Else
      If nRet != 0
         MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "N�o foi poss�vel criar o diret�rio C:\FRESHDESK." + CHR(13) + CHR(10) + "Crie o diret�rio C:\FRESHDESK em seu equipamento.")
         Return(.T.)
      Endif
   Endif   

   // #########################################
   // Elabora o Json para envio ao FreshDesk ##
   // #########################################
   cString := ''
   cString += '{'
   cString += ' "email": "harald@automatech.com.br", '
   cString += ' "source": 2,'
   cString += ' "status": 2,'
   cString += ' "priority": 1,'
   cString += ' "description": "Solicitamos a gera��o da Guia GNRE para a Nota Fiscal de n� ' + Alltrim(kDocumento) + ' S�rie ' + Alltrim(kSerie) + ' no valor de R$ ' + Transform(kValor, "@E 9999999.99") + '"'
   cString += ' "email_config_id": 16000023371,'
   cString += ' "group_id": 16000079978,'
   cString += ' "type": "Info GNRE",'
   cString += ' "custom_fields": {'
   cString += '    "cnpj_ou_cpf": "' + Alltrim(kCnpj) + '"'
   cString += '  } '
   cString += '}'

   // ######################################################
   // Cria o arquivo de envio da solicita��o ao FreshDesk ##
   // ######################################################
   nHdl := fCreate("C:\FRESHDESK\ENVIO.TXT")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   // ##########################################################################################################################################################
   // Exemplo de envio do comando                                                                                                                             ##
   // AtechHttpPost.exe https://automatech.freshdesk.com/api/v2/tickets C:\retorno.txt C:\envio.txt application/json "Basic c3BuaHc4cGxicnlsUlJSWVBPcE46eA==" ##
   // ##########################################################################################################################################################
   
   WinExec('AtechHttpPost2.exe' + ' ' + Alltrim(cSURL) + ' ' + 'C:\FRESHDESK\RETORNO.TXT' + ' ' + 'C:\FRESHDESK\ENVIO.TXT' + ' ' + 'application/json' + ' ' + '"Basic c3BuaHc4cGxicnlsUlJSWVBPcE46eA=="')

   // #################################################################################
   // Abre o arquivo de retorno para capturar o c�digo do ticket gerado no freshdesk ##
   // #################################################################################
   nHandle := FOPEN("C:\FRESHDESK\RETORNO.TXT", FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo C:\FRESHDESK\RETORNO.TXT")
      Return .T.
   Endif

   // ################################
   // L� o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // L� todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := xBuffer
   
   FCLOSE(nHandle)

   If U_P_OCCURS(CCONTEUDO, '"id":',1) == 0
      MsgAlert("Erro ao abrir o Ticket no FreshDesk." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Erro: "                               + chr(13) + chr(10) + chr(13) + chr(10) + ;
               Alltrim(cConteudo))
   Else
      MsgAlert("Ticket de Controle FreshDesk aberto com o n� " + substr(cconteudo, int(val(U_P_OCCURS(CCONTEUDO, '"id":',2))) + 5,6))
   Endif

Return(.T.)