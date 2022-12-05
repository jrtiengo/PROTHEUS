#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//********************************************************************************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                                                                                 *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Referencia: AUTOM340.PRW                                                                                                                              *
// Par�metros: Nenhum                                                                                                                                    *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                                                                                                   *
// Data......: 14/04/2016                                                                                                                                *
// Objetivo..: Prothelito News para o Administrador pelo Parametrizador Automatech                                                                       *
//********************************************************************************************************************************************************

User Function AUTOM340()

   Local lJaLeu      := .F.
   Local nContar     := 0

   Private cLidos    := ""
   Private lSegue    := .F.
   Private cMensagem := ""
   Private lNaoLer   := .F.

   Private oCheckBox1
   Private oMemo2
  
   Private oDlg

   U_AUTOM628("AUTOM340")
   
   // Envia para a fun��o que captura a mensagem a ser visualizada
   CapturaMensagem()

   DEFINE MSDIALOG oDlg TITLE "Mensagens Prothelito" FROM C(178),C(181) TO C(598),C(1050) PIXEL

   @ C(005),C(010) Jpeg FILE "PNEWS3.PNG" Size C(090),C(018) PIXEL NOBORDER OF oDlg
   @ C(027),C(002) Jpeg FILE "PNEWS1.PNG" Size C(090),C(144) PIXEL NOBORDER OF oDlg

   @ C(004),C(096) GET      oMemo2     Var cMensagem MEMO                                      Size C(337),C(188) PIXEL OF oDlg

   @ C(195),C(002) Button "Grava nova mensagem" Size C(090),C(012) PIXEL OF oDlg ACTION( GravaMPROT() )

   @ C(195),C(395) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que o novo arquivo TXT de mensagem e limpa o campo ZZ4_PROT
Static Function GravaMPROT()

   Local cSql     := ""
   Local cCaminho := ""
   Local cString  := ""
   
   cCaminho := GetSrvProfString("Startpath","") + "MenNews.TXT"
   cString  := Alltrim(cMensagem)
   
   // Gera o arquivo XML para o caminho informado
   nHdl := fCreate(cCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   CapturaMensagem()
   
   oMemo2:Refresh()

   // Limpa o campo ZZ4_PROT
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se n�o existir, inclui sen�o altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_PROT)) FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4_PROT := ""
   MsUnLock()
   
Return(.T.)   

// Fun��o que captura a mensagem a ser visualizada
Static Function CapturaMensagem()

   Local cConteudo := ""
   Local aLinhas   := {}
   Local aClientes := {}

   cMensagem := ""

   If !File(GetSrvProfString("Startpath","") + "MenNews.TXT")
      lSegue := .F.
      Return(.T.)
   Else
      lSegue := .T.   
   Endif   

   cCaminho := GetSrvProfString("Startpath","") + "MenNews.TXT"

   // Abre o arquivo informado do conhecimento de transporte para importa��o
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      lSegue := .F.
      Return .T.
   Endif

   // L� o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // L� todos os Registros
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   cMensagem := xBuffer

   FClose(nHandle)

   If Empty(Alltrim(cMensagem))
      lSegue := .F.
   Endif

Return(.T.)