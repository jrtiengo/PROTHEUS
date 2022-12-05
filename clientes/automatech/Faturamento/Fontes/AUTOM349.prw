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
// Referencia: AUTOM349.PRW                                                                                                                              *
// Parâmetros: Nenhum                                                                                                                                    *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                                                   *
// Data......: 30/05/2016                                                                                                                                *
// Objetivo..: Programa que cria o cadastro de contatos dos clientes do boticário                                                                        *
//********************************************************************************************************************************************************

User Function AUTOM349()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cCaminho := Space(250)
   Private oGet1

   Private oDlg

   U_AUTOM628("AUTOM349")
   
   // Procedimento somente permitido para usuário Admin e Roger
   If __CuserId == "000000" .OR. __CuserId == "000002"
   Else
      MsgAlert("Procedimento não permitido para este usuário.")
      Return(.T.)
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Inclusão Automática de Contatos de Clientes Boticário" FROM C(178),C(181) TO C(433),C(671) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(237),C(001) PIXEL OF oDlg
   @ C(080),C(003) GET oMemo2 Var cMemo2 MEMO Size C(237),C(001) PIXEL OF oDlg
   
   @ C(045),C(005) Say "Este procedimento realiza a inclusão automática dos contatos dos clientes através da leitura de sequencial (TXT)." Size C(255),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(084),C(005) Say "Informe o arquivo a ser utilizado para importação"                                                                 Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(093),C(005) MsGet oGet1 Var cCaminho Size C(220),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(093),C(229) Button "..."             Size C(011),C(009)                              PIXEL OF oDlg ACTION( PESQCONTCLIE() )

   @ C(110),C(084) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( AIncContatos() )
   @ C(110),C(123) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do XML a ser importado
Static Function PESQCONTCLIE()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo a ser utilizado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que inclui novos clientes pela leitura do TXT
Static Function AIncContatos()

  MsgRun("Favor Aguarde! Incluíndo Contatos dos Clientes ...", "Inclusão de Contatos",{|| BIncContatos() })

Return(.T.)

// Função que lê o arquivo informado e realiza a atualização dos vendedores
Static Function BIncContatos()

   Local cConteudo  := ""
   Local aLinhas    := {}
   Local aClientes  := {}
   Local aNumeracao := {}
   Local lJaEsta    := .F.
   Local nProcura   := 0
   Local lNovo      := .F.

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser utilizado para importação não informado.")
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
           
       _Codigo      := U_P_CORTA(aLinhas[nContar], "|",  1)
       _Nome        := U_P_CORTA(aLinhas[nContar], "|",  2)
       _CNPJ        := U_P_CORTA(aLinhas[nContar], "|",  3)
       _Inscricao   := U_P_CORTA(aLinhas[nContar], "|",  4)
       _Franquia    := U_P_CORTA(aLinhas[nContar], "|",  5)
       _Fantasia    := U_P_CORTA(aLinhas[nContar], "|",  6)
       _Endereco    := U_P_CORTA(aLinhas[nContar], "|",  7)
       _Numero      := U_P_CORTA(aLinhas[nContar], "|",  8)
       _Complemento := U_P_CORTA(aLinhas[nContar], "|",  9)
       _Bairro      := U_P_CORTA(aLinhas[nContar], "|", 10)
       _Cidade      := U_P_CORTA(aLinhas[nContar], "|", 11)
       _Estado      := U_P_CORTA(aLinhas[nContar], "|", 12)
       _CEP         := U_P_CORTA(aLinhas[nContar], "|", 13)
       _Rua3        := U_P_CORTA(aLinhas[nContar], "|", 14)
       _Tel01       := U_P_CORTA(aLinhas[nContar], "|", 15)
       _Tel02       := U_P_CORTA(aLinhas[nContar], "|", 16)
       _Fax         := U_P_CORTA(aLinhas[nContar], "|", 17)
       _Email       := U_P_CORTA(aLinhas[nContar], "|", 18)
       _PDV_Local   := U_P_CORTA(aLinhas[nContar], "|", 19)
       _PDV_Tipo    := U_P_CORTA(aLinhas[nContar], "|", 20)
       
       aAdd( aClientes, { _Codigo      ,; // 01
                          _Nome        ,; // 02
                          _CNPJ        ,; // 03
                          _Inscricao   ,; // 04
                          _Franquia    ,; // 05
                          _Fantasia    ,; // 06
                          _Endereco    ,; // 07
                          _Numero      ,; // 08
                          _Complemento ,; // 09
                          _Bairro      ,; // 10
                          _Cidade      ,; // 11
                          _Estado      ,; // 12
                          _CEP         ,; // 13
                          _Rua3        ,; // 14
                          _Tel01       ,; // 15
                          _Tel02       ,; // 16
                          _Fax         ,; // 17
                          _Email       ,; // 18
                          _PDV_Local   ,; // 19
                          _PDV_Tipo    ,; // 20
                          ""           ,; // 21
                          ""           ,; // 22
                          ""           ,; // 23
                          ""           ,; // 24
                          POSICIONE("SA1",3,XFILIAL("SA1") + _CNPJ,"A1_COD")   ,;
                          POSICIONE("SA1",3,XFILIAL("SA1") + _CNPJ,"A1_LOJA")  })                           

   Next nContar
   
   // Inclui o contato nas tabelas SU5 e AC8 para os contatos inexistentes
   For nContar = 1 to Len(aClientes)
   
       If Empty(Alltrim(aClientes[nContar,25]))
          Loop
       Endif
          
       cEntidade := aClientes[nContar,25] + aClientes[nContar,26]
       
       cAchei := POSICIONE("AC8",3,XFILIAL("SA1") + cEntidade,"AC8_CODENT")
       
       If Alltrim(cAchei) == Alltrim(cEntidade)
          Loop
       Endif

       // Se não possuir e-mail, não grava
       If Empty(Alltrim(aClientes[nContar,18]))
          Loop
       Endif

       // Inclui o Contato para depois incluir o vínculo do contato do cliente
       Cod_Contato := NEWNUMCONT()

       DbSelectArea("SU5")
       RecLock("SU5",.T.)
       U5_FILIAL  := ""
       U5_CODCONT := Cod_Contato
       U5_CONTAT  := aClientes[nContar,02]
       U5_DDD     := Substr(aClientes[nContar,15],01,02)
       U5_FONE    := Alltrim(Substr(aClientes[nContar,15],03))
       U5_FCOM1   := Alltrim(Substr(aClientes[nContar,15],03))
       U5_EMAIL   := aClientes[nContar,18]
       U5_NIVEL   := "08"
       U5_ATIVO   := "1"
       U5_STATUS  := "2"
       U5_TIPO    := "3"
       Msunlock()

       // Cadastra o Vínculo Contato X Cliente
       DbSelectArea("AC8")
       RecLock("AC8",.T.)
       AC8_FILIAL  := ""
       AC8_FILENT := ""       
       AC8_ENTIDA := "SA1"
       AC8_CODENT := cEntidade
       AC8_CODCON := Cod_Contato
       Msunlock()
       
   Next nContar

   MsgAlert("Contatos dos Clientes incluídos com sucesso!")

Return(.T.)