#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM215.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/03/2014                                                          *
// Objetivo..: Programa que importa arquivo de descrição de produtos para o Cadas- *
//             tro de Produtos.                                                    *
//**********************************************************************************

User Function AUTOM215()
                      
   Local lChumba     := .F.

   Private cCaminho  := Space(250)

   Private oGet1

   Private aBrowse   := {}

   Private oDlg

   U_AUTOM628("AUTOM215")
   
   DEFINE MSDIALOG oDlg TITLE "Importação Descrição de Produtos" FROM C(178),C(181) TO C(531),C(804) PIXEL

   @ C(005),C(005) Say "Arquivo a ser importado"               Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(011),C(269) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPPRODUTOS(cCaminho) )

   @ C(014),C(005) MsGet oGet1  Var cCaminho  When lChumba Size C(247),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(255) Button "..." Size C(011),C(009) PIXEL OF oDlg ACTION( BUSCAPRD() )
                                                                               
   @ C(161),C(231) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( GrvDescri() )
   @ C(161),C(270) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "","","" } )

   oBrowse := TCBrowse():New( 035 , 005, 387, 167,,{'Código', 'Descrição I', 'Descrição II'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do arquivo de produtos a ser importado
Static Function BUSCAPRD()

   cCaminho := cGetFile('*.txt', "Selecione o arquivo a ser importado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que importa o arquivo de descrição de produtos
Static Function IMPPRODUTOS( _Caminho )

   Local lExiste   := .T.
   Local cConteudo := ""
   Local nContar   := 0
   Local nEndereco := 0
   Local cProduto  := ""
   Local cSerie    := ""
   Local nQuanti   := 0
   Local aProdutos := {}
   Local nSepara   := 0
   Local j         := ""

   Private lVolta    := .F.

   If Empty(Alltrim(_Caminho))
      MsgAlert("Arquivo de Descrição de Produtos a ser importado não informado.")
      Return .T.
   Endif

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(_Caminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
 
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
                
       Else
          
          cConteudo := cConteudo + "#"
          _Linha    := ""
          
          // Declara as variáveis para alimentar o array aBrowse
          For nSepara = 1 to U_P_OCCURS(cConteudo, "#", 1)
              _Linha := _Linha + Alltrim(U_P_CORTA(cConteudo, "#", nSepara)) + "|"
          Next nSepara              
          
          aAdd( aProdutos,  Strtran(_Linha, chr(9), "|") )

          cConteudo := ""

          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
            
       Endif

   Next nContar    

   // Prepara o array aBrowse para display dos produtos antes da importação
   For nContar = 1 to Len(aProdutos)

       If Empty(Alltrim(U_P_CORTA(aProdutos[nContar], "|", 1)))
          Loop
       Endif

       If Alltrim(U_P_CORTA(aProdutos[nContar], "|", 1)) == "Codigo"
          Loop
       Endif

       aAdd( aBrowse, { U_P_CORTA(aProdutos[nContar], "|", 1) ,;
                        U_P_CORTA(aProdutos[nContar], "|", 2) ,;
                        U_P_CORTA(aProdutos[nContar], "|", 3) })
   Next nContar
   
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03]}}

Return(.T.)

// Função que atualiza as descrições dos produtos do array aBrowse
Static Function GrvDescri()

   Local nContar := 0
   
   For nContar = 1 to Len(aBrowse)
   
       If Alltrim(aBrowse[nContar,01]) == ""
          Loop
       Endif
       
	   dbSelectArea("SB1")
	   dbSetOrder(1)
   	   If DbSeek(xFilial("SB1") + Alltrim(aBrowse[nContar,01]) + Space(30 - Len(Alltrim(aBrowse[nContar,01]))))
          RecLock("SB1",.F.)
          B1_DESC := aBrowse[nContar,02]
          B1_DAUX := aBrowse[nContar,03]
          MsUnLock()              
       Endif
       
   Next nContar
   
   oDlg:End() 
   
Return(.T.)