#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "TOTVS.CH"
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

// #####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              ##
// ---------------------------------------------------------------------------------- ##
// Referencia: autom679.PRW                                                           ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                        ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 19/02/2018                                                             ##
// Objetivo..: Programa que deleta regustros do contas a receber pela leitura de XML  ##
// #####################################################################################

User Function AUTOM679()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private cCaminho := Space(250)
   Private oGet1

   Private aBrowse  := {}
   Private oBrowse

   Private oOk      := LoadBitmap( GetResources(), "LBOK" )
   Private oNo      := LoadBitmap( GetResources(), "LBNO" )

   Private yBaixa   := Ctod("  /  /    ")
   Private yCredito := Ctod("  /  /    ")
   Private yBanco   := Space(03)
   Private yAgencia := Space(05)
   Private yConta   := Space(10)

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Exclusão Registros de RAs" FROM C(178),C(181) TO C(596),C(958) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Arquivo a ser importado para exclusão" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet  oGet1 Var cCaminho Size C(164),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(170) Button "..."              Size C(014),C(009) PIXEL OF oDlg ACTION( PESQARQ1() )
   @ C(042),C(188) Button "Importar"         Size C(037),C(012) PIXEL OF oDlg ACTION( LeArqBaixas() )
   @ C(193),C(005) Button "Marca Todos"      Size C(050),C(012) PIXEL OF oDlg ACTION( IndicaReg(1) )
   @ C(193),C(056) Button "Desmarca Todos"   Size C(050),C(012) PIXEL OF oDlg ACTION( IndicaReg(2) )
   @ C(193),C(308) Button "Excluir"          Size C(037),C(012) PIXEL OF oDlg ACTION( FazBaixas() )
   @ C(193),C(347) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ 075,005 LISTBOX oBrowse FIELDS HEADER "M"                      ,; // 01
                                           "Código"                 ,; // 02
                                           "Loja"                   ,; // 03
                                           "Descrição dos Clientes" ,; // 04
                                           "Prefixo"                ,; // 05
                                           "Titulo"                 ,; // 06
                                           "Parcela"                ,; // 07
                                           "Tipo"                    ; // 08
                                           PIXEL SIZE 487,167 OF oDlg ON dblClick(aBrowse[oBrowse:nAt,1] := !aBrowse[oBrowse:nAt,1],oBrowse:Refresh())     

   aAdd( aBrowse, { .F., "", "", "", "", "", "", "" }) 

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||     {Iif(aBrowse[oBrowse:nAt,01],oOk,oNo),;
                                 aBrowse[oBrowse:nAt,02]         ,;
                                 aBrowse[oBrowse:nAt,03]         ,;
                                 aBrowse[oBrowse:nAt,04]         ,;                                
                                 aBrowse[oBrowse:nAt,05]         ,;
                                 aBrowse[oBrowse:nAt,06]         ,;
                                 aBrowse[oBrowse:nAt,07]         ,;                                
                                 aBrowse[oBrowse:nAt,08]         }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)                      
                                                                               
// ################################################################################
// Função que abre diálogo de pesquisa para selecionar o arquivo a ser importado ##
// ################################################################################
Static Function PESQARQ1()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)

Return .T. 

// ################################################
// Função que marca/desmarca registros do Browse ##
// ################################################
Static Function IndicaReg(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aBrowse)
       aBrowse[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)          

// #########################################################################
// Função que lê o arquivo informado e carrega os dados para visualização ##
// #########################################################################
Static Function LeArqBaixas()

   MsgRun("Aguarde! Importando arquivo selecionado ...", "Baixas de SCR",{|| xLeArqBaixas() })

Return(.T.)

// #########################################################################
// Função que lê o arquivo informado e carrega os dados para visualização ##
// #########################################################################
Static Function xLeArqBaixas()

   Local nContar     := 0
   Local cConteudo   := ""
   Local aLista      := {}
   Local lErroPar    := .F.
   Local lErroTax    := .F.
   Local kkLegenda   := ""
   Local aInformacao := {}

   // ########################################################
   // Verifica se o arquivo a ser importado foi selecionado ##
   // ########################################################
   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado não selecionado. Verifique!")
      Rerturn(.T.)
   Endif

   // ################################################
   // Limpa o array aLimpa para receber novos dados ##
   // ################################################
   aLista := {}

   // ########################################
   // Abre o arquivo selecionado na aBrowse ##
   // ########################################
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
  
   For nPercorre = 1 to Len(xBuffer)

       If Substr(xBuffer, nPercorre, 1) <> CHR(13)
          cConteudo := cConteudo + Substr(xBuffer, nPercorre, 1)
       Else
          nPercorre := nPercorre + 1
          aAdd( aLista, { Strtran(cConteudo, CHR(9), "|") } )
          cConteudo := ""
       Endif

   Next nPercorre

   // ##################################
   // Fecha a leitura do arquivo lido ##
   // ##################################
   FCLOSE(nHandle)
   
   // ######################################################
   // Limpa o array aBrowse para receber novos resultados ##
   // ######################################################
   aBrowse := {}   

   // ######################################
   // Carrega o aBrowse com os resultados ##
   // ######################################
   For nContar = 1 to Len(aLista)
   
       kCodigo  := Substr(u_p_corta(aLista[nContar,1], "|", 1),01,06)   
       kLoja    := Substr(u_p_corta(aLista[nContar,1], "|", 1),08,03)    
       kNome    := Substr(u_p_corta(aLista[nContar,1], "|", 1),12)  
       kPrefixo := u_p_corta(u_p_corta(aLista[nContar,1], "|", 2), "-", 1) 
       kTitulo  := u_p_corta(u_p_corta(aLista[nContar,1], "|", 2), "-", 2)  
       kParcela := u_p_corta(u_p_corta(aLista[nContar,1] + "-", "|", 2), "-", 3)
       kTipo    := u_p_corta(aLista[nContar,1], "|", 3)

       aAdd( aBrowse, { .F.      ,; // 01 - Marcação
                        kCodigo  ,; // 02 - Código do Cliente
                        kLoja    ,; // 03 - Loja do Cliente
                        kNome    ,; // 04 - Nome do Cliente
                        kPrefixo ,; // 05 - Prefixo
                        kTitulo  ,; // 06 - Título
                        kParcela ,; // 07 - Parcela
                        kTipo    }) // 08 - Tipo
   Next nContar

   If Len(aBrowse) == 0
      aAdd( aBrowse, { .F., "", "", "", "", "", "", "" }) 
   Endif   

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||     {Iif(aBrowse[oBrowse:nAt,01],oOk,oNo),;
                                 aBrowse[oBrowse:nAt,02]         ,;
                                 aBrowse[oBrowse:nAt,03]         ,;
                                 aBrowse[oBrowse:nAt,04]         ,;                                
                                 aBrowse[oBrowse:nAt,05]         ,;
                                 aBrowse[oBrowse:nAt,06]         ,;
                                 aBrowse[oBrowse:nAt,07]         ,;                                
                                 aBrowse[oBrowse:nAt,08]         }}

Return(.T.)
           
// ########################################################
// Função que realiza as baixas dos títulos selecionados ##
// ########################################################
Static Function FazBaixas()

   MsgRun("Aguarde! Realizando a exclusão dos títulos selecionados ...", "Exclusão de RAs",{|| xFazBaixas() })

Return(.T.)

// ########################################################
// Função que realiza as baixas dos títulos selecionados ##
// ########################################################
Static Function xFazBaixas()

   Local cSql      := ""
   Local nContar   := 0
   Local lMarcados := .F.
   Local aArray    := {}
                   
   PRIVATE lMsErroAuto := .F.
   
   // #############################################################################
   // Verifica se houve pelo menos um registro selecionado para realizar a baixa ##
   // #############################################################################
   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar 
   
   If lMarcados == .F.
      MsgAlert("Atenção! Nenhum registro foi selecionado para realizar a exclusão de RAs. Verifique!")
      Return(.T.)
   Endif          

   // ######################################
   // Realiza a baixa dos registros lidos ##
   // ######################################
   For nContar = 1 to Len(aBrowse)

       // #####################################
       // Despreza registro não selecionados ##
       // #####################################
       If aBrowse[nContar,01] == .F.
          Loop
       Endif   

       // ###################################
       // Pesquisa o título a ser deletado ##
       // ###################################
       If Select("T_TITULO") > 0
          T_TITULO->( dbCloseArea() )
       EndIf                                                 
       
       cSql := ""
       cSql := "SELECT E1_PREFIXO,"
       cSql += "       E1_NUM    ,"
  	   cSql += "       E1_PARCELA,"
  	   cSql += "       E1_TIPO   ,"
  	   cSql += "       E1_CLIENTE,"
  	   cSql += "       E1_LOJA   ,"
  	   cSql += "       R_E_C_N_O_ "
       cSql += "  FROM " + RetSqlName("SE1")
       cSql += " WHERE E1_PREFIXO = '" + Alltrim(aBrowse[nContar,05]) + "'"
       cSql += "   AND E1_NUM     = '" + Alltrim(aBrowse[nContar,06]) + "'"
       cSql += "   AND E1_PARCELA = '" + Alltrim(aBrowse[nContar,07]) + "'"
       cSql += "   AND E1_CLIENTE = '" + Alltrim(aBrowse[nContar,02]) + "'"
       cSql += "   AND E1_LOJA    = '" + Alltrim(aBrowse[nContar,03]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TITULO", .T., .T. )

//       If T_TITULO->( EOF() )
//          Loop
//       Endif
       
   	   DbSelectArea("SE1")
	   DbSetOrder(1)
	   If DbSeek(xFilial("SE1") + T_TITULO->E1_PREFIXO + T_TITULO->E1_NUM + T_TITULO->E1_PARCELA + T_TITULO->E1_TIPO)

          aArray := { { "E1_PREFIXO" , SE1->E1_PREFIXO , NIL },;
                      { "E1_NUM"     , SE1->E1_NUM     , NIL } }
 
          MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 5)
 
          If lMsErroAuto
             MostraErro()
          Else
             Alert("Exclusão do Título com sucesso!")
          Endif
          
       Endif

   Next nContar

Return(.T.)