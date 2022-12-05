#INCLUDE "protheus.ch"  
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: SYSCAT01.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 02/03/2017                                                              ##
// Objetivo..: Cadastro de Categorias                                                  ##
// ######################################################################################

User Function SYSCAT01()
                                         
   Local cMemo1	   := ""
   Local cMemo2	   := ""
   Local oMemo1
   Local oMemo2

   Private aBrowse := {}

   Private oDlg

   // ###################################################################################
   // Verifica se existe a pasta sosystools na aplicação. Caso não exista, será criada ##
   // ###################################################################################
   If !ExistDir( "\sosystools" )

      nRet := MakeDir( "\sosystools" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta sosystools. Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Endif
   
   Endif
                               
   le_categorias(0)

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Categorias" FROM C(178),C(181) TO C(589),C(545) PIXEL

   @ C(002),C(002) Jpeg FILE "sosys.png" Size C(118),C(030) PIXEL NOBORDER OF oDlg

   @ C(037),C(002) GET oMemo1 Var cMemo1 MEMO Size C(175),C(001) PIXEL OF oDlg
   @ C(184),C(002) GET oMemo2 Var cMemo2 MEMO Size C(175),C(001) PIXEL OF oDlg

   @ C(189),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( Abre_categoria("I", Space(06), Space(40) ) )
   @ C(189),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( Abre_categoria("A", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] ) )
   @ C(189),C(082) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( Abre_categoria("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] ) )
   @ C(189),C(141) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 055 , 005, 223, 177,,{'Código'                   ,; // 01
                                                    'Descrição Categorias'   } ,; // 02
                                                   {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}
      
   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################
// Função que lê os dados do arquivo de Categorias ##
// ##################################################
Static Function le_categorias(kTipo)

   Local _Arquivo := "\sosystools\categorias.cfg"
                         
   aBrowse := {} 

   If !File(_Arquivo)

      If Len(aBrowse) == 0     
         aAdd( aBrowse, { "", "" })
      Endif
      
      If kTipo == 1

         oBrowse:SetArray(aBrowse) 
    
         oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                               aBrowse[oBrowse:nAt,02]}}
      
         oBrowse:Refresh()
      
      Endif
      
      Return(.T.)

   Endif

   // #############################
   // Abre o arquivo selecionado ##
   // #############################
   nHandle := FOPEN(Alltrim(_Arquivo), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
   Else

      // Lê o tamanho total do arquivo
      nLidos := 0
      FSEEK(nHandle,0,0)
      nTamArq := FSEEK(nHandle,0,2)
      FSEEK(nHandle,0,0)

      // Lê todos os Registros
      xBuffer:=Space(nTamArq)         
      FREAD(nHandle,@xBuffer,nTamArq)
 
      cConteudo := ""
      aConsulta := {}

      For nContar = 1 to Len(xBuffer)

          If Substr(xBuffer, nContar, 1) <> CHR(13)

             cConteudo := cConteudo + Substr(xBuffer, nContar, 1)

          Else

             If !Empty(Alltrim(U_P_CORTA(cConteudo, "|", 1)))
                aAdd( aBrowse, { U_P_CORTA(cConteudo, "|", 1), U_P_CORTA(cConteudo, "|", 2) }) 
             Endif   

             cConteudo := ""
             
//             nContar := nContar + 1

          Endif

      Next nContar    
   
   Endif

   FCLOSE(nHandle)
                
   FCLOSE(Alltrim(_Arquivo))
   
   If Len(aBrowse) == 0     
      aAdd( aBrowse, { "", "" })
   Endif
   
   If kTipo == 1
      oBrowse:SetArray(aBrowse) 
    
      oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                            aBrowse[oBrowse:nAt,02]}}
      
      oBrowse:Refresh()
     
   Endif
   
Return(.T.)      

// #########################################################
// Função que abre a manutenção do cadastro de categarias ##
// #########################################################
Static Function Abre_categoria(kOperacao, kCodigo, kDescricao)

   Local lChumba := .F.
   Local lEditar := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local cCodigo    := kCodigo
   Local cDescricao := kDescricao

   Local oGet1
   Local oGet2

   Private oDlgCat

   If kOperacao == "I" .Or. kOperacao == "A"
      lEditar := .T.
   Else
      lEditar := .F.      
   Endif   

   DEFINE MSDIALOG oDlgCat TITLE "Cadastro de Categorias" FROM C(178),C(181) TO C(402),C(548) PIXEL

   @ C(002),C(002) Jpeg FILE "sosys.png" Size C(118),C(034) PIXEL NOBORDER OF oDlgCat

   @ C(039),C(002) GET oMemo1 Var cMemo1 MEMO Size C(175),C(001) PIXEL OF oDlgCat
   @ C(089),C(002) GET oMemo2 Var cMemo2 MEMO Size C(175),C(001) PIXEL OF oDlgCat

   @ C(043),C(005) Say "Código"                 Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgCat
   @ C(065),C(006) Say "Descrição da Categoria" Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgCat

   @ C(053),C(005) MsGet oGet1 Var cCodigo    Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCat When lChumba
   @ C(075),C(005) MsGet oGet2 Var cDescricao Size C(173),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCat When lEditar

   If kOperacao == "I" .Or. kOperacao == "A"
      @ C(095),C(099) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlgCat ACTION(SALVACAT(kOperacao, cCodigo, cDescricao))
   Else
      @ C(095),C(099) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgCat ACTION(SALVACAT(kOperacao, cCodigo, cDescricao))
   Endif

   @ C(095),C(141) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCat ACTION( oDlgCat:End() )

   ACTIVATE MSDIALOG oDlgCat CENTERED 

Return(.T.)

// #####################################################
// Função que grava ou exclui a categoria selecionada ##
// #####################################################
Static Function SalvaCat(xOperacao, xCodigo, xDescricao)

   Local nContar   := 0
   Local cString   := ""
   Local aTransito := {}
   Local _Arquivo  := "\sosystools\categorias.cfg"
   
   // ######################################################
   // Atualiza o array aBrowse conforme Operação indicada ##
   // ######################################################
   Do Case
    
      Case xOperacao == "I"   

       	   aSort(aBrowse,,, { |x, y| x[1] < y[1] })
                            
           nProximo := aBrowse[Len(aBrowse),01] + 1
           
           aAdd( aBrowse, { Strzero(nProximo,6), xDescricao } )

      Case xOperacao == "A"   
      
           For nContar = 1 to Len(aBrowse)
               If aBrowse[nContar,01] == xCodigo
                  aBrowse[nContar,02] := xDescricao
                  Exit
               Endif
           Next nContar
           
      Case xOperacao == "E"   
      
           For nContar = 1 to Len(aBrowse)
               If aBrowse[nContar,01] == xCodigo
                  Loop
               Endif
               aAdd( aTransito, { aBrowse[nContar,01], aBrowse[nContar,02] })
           Next nContar

           aBrowse := {}

           For nContar = 1 to Len(aTransito)
               aAdd( aBrowse, { aTransito[nContar,01], aTransito[nContar,02] })
           Next nContar

   EndCase
               
   // #################################################################
   // Elabora a String para nova atualização do arquivo de categoria ##
   // #################################################################
   cString := ""
   
   For nContar = 1 to Len(aBrowse)
       cString := cString + aBrowse[nContar,01] + "|" + aBrowse[nContar,02] + "|" + chr(13)
   Next nContar

   // ####################################
   // Cria o novo arquivo de categorias ##
   // ####################################
   FERASE(Alltrim(_Arquivo))

   nHdl := fCreate(_Arquivo)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   // ##########################################################
   // Envia para a função que atualçiza o grid das categorias ##
   // ##########################################################
   le_categorias(0)
   
   oDlgCat:End() 
   
Return(.T.)