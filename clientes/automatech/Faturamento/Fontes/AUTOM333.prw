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
// Referencia: AUTOM333.PRW                                                                                                                              *
// Parâmetros: Nenhum                                                                                                                                    *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                                                   *
// Data......: 15/02/2016                                                                                                                                *
// Objetivo..: Programa que realiza a alteração do código do vendedor pela leitura de arquivo TXT.                                                       *
// Layout Arq: CLIENTE | LOJA | VENDEDOR                                                                                                                 *                    
//********************************************************************************************************************************************************

User Function AUTOM333()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cCaminho := Space(250)
   Private oGet1

   Private oDlg

   U_AUTOM628("AUTOM333")
   
   // Procedimento somente permitido para usuário Admin e Roger
   If __CuserId == "000000" .OR. __CuserId == "000002"
   Else
      MsgAlert("Procedimento não permitido para este usuário.")
      Return(.T.)
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Alteração Vendedor Cadastro de Clientes" FROM C(178),C(181) TO C(433),C(671) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(237),C(001) PIXEL OF oDlg
   @ C(080),C(003) GET oMemo2 Var cMemo2 MEMO Size C(237),C(001) PIXEL OF oDlg
   
   @ C(040),C(005) Say "Este procedimento realiza a alteração do código do vendedor no cadastro de clientes." Size C(205),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(005) Say "Este somente poderá ser executado pelos usuários Admin e Roger."                      Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(005) Say "Atenção ao layout do arquivo TXT a ser utilizado por este procedimento:"              Size C(174),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(027) Say "CÓDIGO CLIENTE | LOJA CLIENTE | VENDEDOR A SER CONSIDERADO"                           Size C(180),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(084),C(005) Say "Informe o arquivo a ser utilizado para alteração de vendedores"                       Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(093),C(005) MsGet oGet1 Var cCaminho Size C(220),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(093),C(229) Button "..."             Size C(011),C(009)                              PIXEL OF oDlg ACTION( PESQARQVEND() )

   @ C(110),C(084) Button "Atualizar" Size C(037),C(012) PIXEL OF oDlg ACTION( AtuVendCliente() )
   @ C(110),C(123) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do XML a ser importado
Static Function PESQARQVEND()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo a ser utilizado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que lê o arquivo informado e realiza a atualização dos vendedores
Static Function AtuVendCliente()

   Local cConteudo := ""
   Local aLinhas   := {}
   Local aClientes := {}

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser lido para atualização não informado.")
      Return(.T.)
   Endif
   
   // Abre o arquivo informado do conhecimento de transporte para importação
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo " + Alltrim(__Arquivo))
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

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + "|"
          cConteudo := StrTran(cConteudo, chr(9), "|")
          _Linha    := ""
          aAdd( aLinhas,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Realiza a gravação dos registros
   For nContar = 1 to Len(aLinhas)
           
       _CodigoCli   := U_P_CORTA(aLinhas[nContar], "|", 1)
       _LojaCli     := U_P_CORTA(aLinhas[nContar], "|", 2)
       _CodVendedor := U_P_CORTA(aLinhas[nContar], "|", 3)
       
       aAdd( aClientes, { _CodigoCli, _LojaCli, _CodVendedor } )

   Next nContar

   // Realiaza a gravação do código do vendedor conforme array aClientes
   For nContar = 1 to Len(aClientes)

       dbSelectArea("SA1")
  	   dbSetOrder(1)
	   If DbSeek(xFilial("SA1") + aClientes[nContar,01] + aClientes[nContar,02])
		  RecLock( "SA1" , .F. )
		  SA1->A1_VEND := aClientes[nContar,03]
		  MsUnLock()	
	   EndIf

   Next nContar

   MsgAlert("Alteração realizada com sucesso!")

   cCaminho := Space(250)
   oGet1:Refresh()

Return(.T.)