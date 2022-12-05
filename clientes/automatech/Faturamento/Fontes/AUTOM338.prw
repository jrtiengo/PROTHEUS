#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//********************************************************************************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                                                                 *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Referencia: AUTOM338.PRW                                                                                                                              *
// Parâmetros: Nenhum                                                                                                                                    *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                                                   *
// Data......: 12/04/2016                                                                                                                                *
// Objetivo..: Prothelito News
//********************************************************************************************************************************************************

User Function AUTOM338()

   Local lJaLeu      := .F.
   Local nContar     := 0

   Private cLidos    := ""
   Private lSegue    := .F.
   Private cMensagem := ""
   Private lNaoLer   := .F.

   Private oCheckBox1
   Private oMemo2
  
   Private oDlg

   U_AUTOM628("AUTOM338")

   If _VeMensagem <> nil
      _VeMensagem := .T.
   Endif   

   // Verifica se usuário já leu a mensagem e não quer ler mais
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_PROT)) AS JALERAM FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      Return(.T.)
   Endif

   cLidos := UPPER(ALLTRIM(T_PARAMETROS->JALERAM))

   lJaLeu := .F.
   
   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->JALERAM, "|", 1)
       If UPPER(ALLTRIM(U_P_CORTA(T_PARAMETROS->JALERAM, "|", nContar))) == UPPER(ALLTRIM(cUserName))
          lJaleu := .T.
          Exit
       Endif
   Next nContar       

   If lJaLeu == .T.
      Return(.T.)
   Endif

   // Envia para a função que captura a mensagem a ser visualizada
   CapturaMensagem()

   If lSegue == .F.
      Return(.T.)
   Endif   
  
   DEFINE MSDIALOG oDlg TITLE "Mensagens Prothelito" FROM C(178),C(181) TO C(598),C(1050) PIXEL

   @ C(005),C(010) Jpeg FILE "PNEWS3.PNG" Size C(090),C(018) PIXEL NOBORDER OF oDlg
   @ C(027),C(002) Jpeg FILE "PNEWS1.PNG" Size C(090),C(144) PIXEL NOBORDER OF oDlg

   @ C(004),C(096) GET      oMemo2     Var cMensagem MEMO                                      Size C(337),C(188) PIXEL OF oDlg

// If Upper(Alltrim(cUserName)) == "ADMINISTRADOR"
//    @ C(195),C(002) Button "Grava nova mensagem" Size C(090),C(012) PIXEL OF oDlg ACTION( GravaMPROT() )
// Endif	  

// If Upper(Alltrim(cUserName)) == "ADMINISTRADOR"
// Else
      @ C(196),C(096) CheckBox oCheckBox1 Var lNaoLer   Prompt "Não quero mais ler esta mensagem" Size C(095),C(008) PIXEL OF oDlg
// Endif   

   @ C(195),C(395) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SaidaTela() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava o campo "Não quero ler mais" e fecha a janela
Static Function SaidaTela()
                         
   If lNaoLer == .F.
      oDlg:End()
      Return(.T.)
   Endif        

   cLidos := cLidos + Upper(Alltrim(cUserName)) + "|"
   
   // Se não existir Parametrizador inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_PROT)) AS JALERAM FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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

   ZZ4_PROT := cLidos
   MsUnLock()

   oDlg:End()    
   
Return(.T.)

// Função que o novo arquivo TXT de mensagem e limpa o campo ZZ4_PROT
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
   // Se não existir, inclui senão altera
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

// Função que captura a mensagem a ser visualizada
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

   // Abre o arquivo informado do conhecimento de transporte para importação
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      lSegue := .F.
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Registros
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   cMensagem := xBuffer

   FClose(nHandle)

   If Empty(Alltrim(cMensagem))
      lSegue := .F.
   Endif

Return(.T.)