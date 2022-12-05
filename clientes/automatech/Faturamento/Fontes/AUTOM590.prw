#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "APWEBSRV.CH" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM590.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 30/06/2017                                                          ##
// Objetivo..: Programna que limpa o código do vendedor 1(Hardware) do Cad.Cliente ##
// Parâmetros: Sem Parâmetros                                                      ##
// ##################################################################################

User Function AUTOM590()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cCaminho := Space(250)
   Private oGet1
 
   Private oDlg

   U_AUTOM628("AUTOM590")

   DEFINE MSDIALOG oDlg TITLE "Limpeza Campo Vendedor 1 Cadastro de Clientes" FROM C(178),C(181) TO C(422),C(558) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(182),C(001) PIXEL OF oDlg
   @ C(076),C(002) GET oMemo2 Var cMemo2 MEMO Size C(182),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Este programa tem por finalidade de limpar o campo Vendedor 1 (HardWare) " Size C(181),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(046),C(005) Say "do Cadastro de Clientes atravéz da leitura de arquivo sequencial (TXT)"    Size C(170),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(005) Say "com o sequinte layout:"                                                    Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(065),C(005) Say "CÓDIGO CLIENTE - LOJA DO CLIENTE"                                          Size C(098),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(005) Say "Arquivo a ser lido"                                                        Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(090),C(005) MsGet oGet1 Var cCaminho Size C(161),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(087),C(170) Button "..."             Size C(014),C(012)                              PIXEL OF oDlg ACTION( xARQAJUSTE() )
   
   @ C(105),C(056) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( xPRCARQUIVO() )
   @ C(105),C(094) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################################
// Função que abre diálogo de pesquisa do arquivo a ser importado ##
// #################################################################
Static Function xARQAJUSTE()

   cCaminho := cGetFile('*.*', "Selecione o Arquivo de Inventário",1,"C:\",.F.,16,.F.)

Return .T. 

// ########################################################
// Função que importa o arquivo selecionado e o processa ##
// ########################################################
Static Function xPRCARQUIVO()

   Local cConteudo := ""
   Local nContar   := 0
   Local aBrowse   := {}

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado não informado.")
      Return(.T.)
   Endif

   // #########################################################################
   // Abre o arquivo a ser lido para extração das informações do arquivo xml ##
   // #########################################################################
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
      aprodutos := {}
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
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          aAdd( aBrowse,  StrTran(cConteudo, chr(9), "|"))
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   If Len(aBrowse) == 0
      MsgAlert("Nenhum registro foi importado. Verifique!")
      Return(.T.)
   Endif
   
   For nContar = 1 to Len(aBrowse)
       
       xCodigo := STRZERO(INT(VAL(U_P_CORTA(aBrowse[nContar], "|", 1))),6)
       xLoja   := STRZERO(INT(VAL(U_P_CORTA(aBrowse[nContar], "|", 2))),3)
       
       DbSelectArea("SA1")
       DbSetOrder(1)
       If DbSeek(xfilial("SA1") + xCodigo + xLoja )
          Reclock("SA1",.F.)
          SA1->A1_VEND := ""
          Msunlock()
       Endif
       
   Next nContar
   
   MsgAlert("Vendedore 1 dos Clientes do arquivo zerados com sucesso.")

Return(.T.)