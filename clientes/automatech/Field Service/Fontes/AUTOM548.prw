#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTUOM548.PRW                                                        ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 07/03/2017                                                           ##
// Objetivo..: Tela de pesquisa de nº de série pela tela de contrato AT.            ##
// ###################################################################################

User Function AUTOM548()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private xTabela := Alias()

   Private kMarca  := ""

   Private cPesquisa := Space(20)
   Private oGet1

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista  := {}
 
   Private oDlg
 
   // #####################################
   // Verifica se cliente fopi informado ##
   // #####################################
   If Empty(Alltrim(M->AAH_CODCLI))
      MsgAlert("Necessário informar Cliente antes de prosseguir.")
      Return(.T.)
   Endif

   // #########################################
   // Verifica se a cMarca já está carregada ##
   // #########################################
   (xTabela)->( DbGoTop() )
   
   WHILE !(xTabela)->( EOF() )

      If (xTabela)->AA3_CODCLI == M->AAH_CODCLI .And. (xTabela)->AA3_LOJA == M->AAH_LOJA
         If !Empty(Alltrim((xTabela)->AA3_OK))
            kMarca := (xTabela)->AA3_OK
            Exit
         Endif
      Endif   
      
      (xTabela)->( DbSkip() )
      
   ENDDO      
         
   If Empty(Alltrim(kMarca))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Necessário selecinar pelo menos 1 nº de série para que a marca de registros seja criada.")
      (xTabela)->( DbGoTop() )
      Return(.T.)
   Endif

   // #################################################
   // Envia para a função que carrega o array aLista ##
   // #################################################
   PsqNSeries(0, "")

   DEFINE MSDIALOG oDlg TITLE "Nº de Séries Contrato AT" FROM C(178),C(181) TO C(627),C(959) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(381),C(001) PIXEL OF oDlg
   @ C(059),C(002) GET oMemo2 Var cMemo2 MEMO Size C(381),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Nº de Série a ser pesquisado" Size C(071),C(008) COLOR CLR_BLACK              PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var cPesquisa          Size C(096),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(042),C(107) Button "Pesquisar"                 Size C(037),C(012)                              PIXEL OF oDlg ACTION( DeterminadoN(cPesquisa) )

   @ C(208),C(005) Button "Gerar Seleção em Arq TXT"  Size C(080),C(012) PIXEL OF oDlg ACTION( GeraArqTXTs() )
   @ C(208),C(346) Button "Voltar"                    Size C(037),C(012) PIXEL OF oDlg ACTION( SairZKA() )

   // ###########################
   // Cria o display da aLista ##
   // ###########################
   @ 085,005 LISTBOX oLista FIELDS HEADER "M"                 ,; // 01
                                          "Posição"           ,; // 02
                                          "CLiente"           ,; // 03
                                          "Loja"              ,; // 04
                                          "Produto"           ,; // 05
                                          "Descrição Produtos",; // 06
                                          "Nº de Série"       ,; // 07
                                          "Data venda"        ,; // 08
                                          "Data Instalação"   ,; // 09
                                          "Data Garantia"     ,; // 10
                                          "Fornecedor"        ,; // 11
                                          "Loja Forn."        ,; // 12
                                          "Nome Fornecedor"   ,; // 13
                                          "Fabricante"        ,; // 14
                                          "Loja Fab."         ,; // 15
                                          "Nome Fabricante"   ,; // 16
                                          "Nº Nota Fiscal"     ; // 17
                             PIXEL SIZE 484,175 OF oDlg ;
                             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {|| {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]         ,;  
                            aLista[oLista:nAt,03]         ,;  
                            aLista[oLista:nAt,04]         ,;  
                            aLista[oLista:nAt,05]         ,;  
                            aLista[oLista:nAt,06]         ,;  
                            aLista[oLista:nAt,07]         ,;  
                            aLista[oLista:nAt,08]         ,;  
                            aLista[oLista:nAt,09]         ,;  
                            aLista[oLista:nAt,10]         ,;  
                            aLista[oLista:nAt,11]         ,;  
                            aLista[oLista:nAt,12]         ,;  
                            aLista[oLista:nAt,13]         ,;  
                            aLista[oLista:nAt,14]         ,;  
                            aLista[oLista:nAt,15]         ,;  
                            aLista[oLista:nAt,16]         ,;  
                            aLista[oLista:nAt,17]         }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ########################################################################################################
// Função que atualiza a tabela ZKA para posterior gravação dos nº de séries na tabela de Base Instalada ##
// ########################################################################################################
Static Function SairZKA()

   MsgRun("Favor Aguarde! Atualizando tabela de nº de séries do cliente ...", "Atualização Nº Séire do Cliente",{|| xSairZKA() })

Return(.T.)

// ########################################################################################################
// Função que atualiza a tabela ZKA para posterior gravação dos nº de séries na tabela de Base Instalada ##
// ########################################################################################################
Static Function xSairZKA()

   Local cSql    := ""
   Local nContar := 0

   (xTabela)->( dbGoTop() )
   
   WHILE !(xTabela)->( EOF() )
   
      For nContar = 1 to Len(aLista)

          If Alltrim((xTabela)->AA3_NUMSER) == Alltrim(aLista[nContar,07])
   
    	     dbSelectArea((xTabela))
             RecLock((xTabela),.F.)
             If aLista[nContar,01] == .F.
      	        (xTabela)->AA3_OK := ""
      	     Else
       	        (xTabela)->AA3_OK := kMarca
       	     Endif            	       
             MsUnLock()              
             Exit
             
          Endif   
   	      
      Next nContar
      
      (xTabela)->( DbSkip() )
      
   Enddo

   oDlg:End() 
   
Return(.T.)   

// ####################################################
// Função que pesquisa os nº de série para indicação ##
// ####################################################
Static Function PsqNSeries(kTipo, kPesquisa)

   MsgRun("Favor Aguarde! Carregando Números de Séries do Cliente ...", "Pesquisa Nº de Séries do Cliente",{|| xPsqNSeries(kTipo, kPesquisa) })

Return(.T.)

// #################################################
// Função que pesquisa um determinado nº de série ##
// #################################################
Static Function DeterminadoN(xx_Serie)
                   
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local lChumba := .F.
   Local nContar := 0
   Local lExiste := .F.

   Local oMemo1
   Local oMemo2

   Private kSerie	 := xx_Serie
   Private kPosicao  := Space(05)
   Private kSituacao := Space(30)
   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgP

   // ###################################
   // Pesquisa o nº de série informado ##
   // ###################################
   If Empty(Alltrim(kSerie))
      MsgAlert("Nº de Série a ser pesquisado não informado.")
      Return(.T.)
   Endif

   For nContar = 1 to Len(aLista)
       If Alltrim(aLista[nContar,07]) == Alltrim(kSerie)
          lExiste := .T.
          Exit
       Endif
   Next nContar
      
   If lExiste == .F.
      MsgAlert("Nº de Série não localizado nesta lista.")
      Return(.T.)
   Else
      kPosicao  := aLista[nContar,02]
      kSituacao := IIF(aLista[nContar,01] == .F., "DESMARCADO", "MARCADO")
   Endif

   DEFINE MSDIALOG oDlgP TITLE "Nº de Séries Contrato AT" FROM C(178),C(181) TO C(434),C(424) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(114),C(001) PIXEL OF oDlgP
   @ C(105),C(002) GET oMemo2 Var cMemo2 MEMO Size C(114),C(001) PIXEL OF oDlgP

   @ C(036),C(005) Say "Nº de Série pesquisado"       Size C(110),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(059),C(005) Say "Posição de localização"       Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(081),C(005) Say "Este Nº de Série encontra-se" Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgP   

   @ C(046),C(005) MsGet oGet1 Var kSerie    Size C(111),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
   @ C(068),C(005) MsGet oGet2 Var kPosicao  Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
   @ C(091),C(005) MsGet oGet3 Var kSituacao Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba

   @ C(111),C(005) Button "Marca/Desmarcar" Size C(054),C(012) PIXEL OF oDlgP ACTION( MdNumSerie(kSerie, kPosicao, kSituacao) )
   @ C(111),C(061) Button "Voltar"          Size C(055),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// #####################################################
// Função que Marca/Desmarca o nº de série pesquisado ##
// #####################################################
Static Function MdNumSerie(kSerie, kPosicao, kSituacao)

   Local nContar := 0

   For nContar = 1 to Len(aLista)
       If Alltrim(aLista[nContar,07]) == Alltrim(kSerie)
          lExiste := .T.
          Exit
       Endif
   Next nContar
      
   If lExiste == .F.
   Else
      aLista[nContar,01] := IIF(Alltrim(kSituacao) == "DESMARCADO", .T., .F.)
   Endif

   oDlgP:End()

Return(.T.)

// ####################################################
// Função que pesquisa os nº de série para indicação ##
// ####################################################
Static Function xPsqNSeries(kTipo, kPesquisa)

   Local cSql     := ""
   Local lExiste  := .F.
   Local nContar  := 0
   Local nposicao := 0

   // ##################################################
   // Limpa array aLista para receber novos registros ##
   // ##################################################
   aLista := {}

   (xTabela)->( DbGoTop() )   
   
   nPosicao := 0
   
   WHILE !(xTabela)->(EOF() )
                
      nPosicao := nPosicao + 1
   
      nProduto    := POSICIONE("SB1",1,XFILIAL("SB1") + (xTabela)->AA3_CODPRO, "B1_DESC")
      nFornecedor := POSICIONE("SA2",1,XFILIAL("SA2") + (xTabela)->AA3_FORNEC + (xTabela)->AA3_LOJAFO, "A2_NOME")
      nFabricante := POSICIONE("SA1",1,XFILIAL("SA1") + (xTabela)->AA3_CODFAB + (xTabela)->AA3_LOJAFA, "A1_NOME")

      aAdd( aLista, { IIF(Empty(Alltrim((xTabela)->AA3_OK)), .F., .T.)                     ,; // 01 - Coluna de Marcação
                      Strzero(nPosicao,05)                                                 ,; // 02 - Posição
                      (xTabela)->AA3_CODCLI                                                ,; // 03 - Código do Cliente
                      (xTabela)->AA3_LOJA                                                  ,; // 04 - Loja do Cliente
                      (xTabela)->AA3_CODPRO                                                ,; // 05 - Código do Produto
                      nProduto                                                             ,; // 06 - Descrição do Produto
                      (xTabela)->AA3_NUMSER                                                ,; // 07 - Nº de Série do produto
                      (xtabela)->AA3_DTVEND                                                ,; // 08 - Data de venda do Nº de Série
                      (xtabela)->AA3_DTINST                                                ,; // 09 - Data de Instação do Nº de Série
                      (xtabela)->AA3_DTGAR                                                 ,; // 10 - Data de garantia do Nº de Série
                      (xtabela)->AA3_FORNEC                                                ,; // 11 - Códigodo Fornecedor
                      (xtabela)->AA3_LOJAFO                                                ,; // 12 - Loja do Fornecedor
                      nFornecedor                                                          ,; // 13 - Nome do Fornecedor
                      (xtabela)->AA3_CODFAB                                                ,; // 14 - Código do Fabricante
                      (xtabela)->AA3_LOJAFA                                                ,; // 15 - Loja do Fabricante
                      nFabricante                                                          ,; // 16 - Nome do Fabricante
                      (xtabela)->AA3_NFVEND })                                                // 17 - Nº da Nota Fiscal de Venda

       (xTabela)->( DbSkip() )
       
   ENDDO
                             
   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })       
   Endif
    
   If kTipo == 0
      Return(.T.)
   Endif
          
   oLista:SetArray( aLista )

   oLista:bLine := {|| {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]         ,;  
                            aLista[oLista:nAt,03]         ,;  
                            aLista[oLista:nAt,04]         ,;  
                            aLista[oLista:nAt,05]         ,;  
                            aLista[oLista:nAt,06]         ,;  
                            aLista[oLista:nAt,07]         ,;  
                            aLista[oLista:nAt,08]         ,;  
                            aLista[oLista:nAt,09]         ,;  
                            aLista[oLista:nAt,10]         ,;  
                            aLista[oLista:nAt,11]         ,;  
                            aLista[oLista:nAt,12]         ,;  
                            aLista[oLista:nAt,13]         ,;  
                            aLista[oLista:nAt,14]         ,;  
                            aLista[oLista:nAt,15]         ,;  
                            aLista[oLista:nAt,16]         ,;  
                            aLista[oLista:nAt,17]         }}

Return(.T.)

// #####################################################
// Função que abre kanela para geração do arquivo txt ##
// #####################################################
Static Function GeraArqTXTs()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local cCaminho := Space(250)
   Local aSelecao := {"1 - Somente Nºs de Séries Desmacados", "2 - Somente Nºs de Séries Marcados", "3 - Ambos"}

   Local oGet1
   Local cComboBx1
   
   Private oDlgTXT

   DEFINE MSDIALOG oDlgTXT TITLE "Nº de Séries em Arquivo TXT" FROM C(178),C(181) TO C(389),C(575) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgTXT

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(191),C(001) PIXEL OF oDlgTXT
   @ C(083),C(005) GET oMemo2 Var cMemo2 MEMO Size C(191),C(001) PIXEL OF oDlgTXT

   @ C(036),C(005) Say "Nome e local onde será salvo o arquivo" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT
   @ C(058),C(005) Say "Registros a serem selecionados"         Size C(079),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT

   @ C(045),C(005) MsGet    oGet1     Var   cCaminho Size C(187),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTXT
   @ C(068),C(005) ComboBox cComboBx1 Items aSelecao Size C(187),C(010)                              PIXEL OF oDlgTXT

   @ C(088),C(062) Button "Gerar TXT" Size C(037),C(012) PIXEL OF oDlgTXT ACTION( kGeraTXT(cCaminho, cComboBx1) )
   @ C(088),C(100) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgTXT ACTION( oDlgTXT: End() )

   ACTIVATE MSDIALOG oDlgTXT CENTERED 

Return(.T.)

// #######################################################
// Função que gera o arquivo em txt conforme parâmetros ##
// #######################################################
Static Function kGeraTXT(cCaminho, cComboBx1)

   MsgRun("Favor Aguarde! Gerando arquivo TXT das informações ...", "Arquivo TXT das Informações",{|| xkGeraTXT(cCaminho, cComboBx1) })

Return(.T.)

// #######################################################
// Função que gera o arquivo em txt conforme parâmetros ##
// #######################################################
Static Function xkGeraTXT(cCaminho, cComboBx1)

   Local nContar := 0
   Local cString := ""
   
   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho + Arquivo não informado para geração do arquivo TXT.")
      Return(.T.)
   Endif
      
   cString := ""

   cString := cString + "Cliente: " + M->AAH_CODCLI + "." + M->AAH_LOJA + POSICIONE("SA1",1,XFILIAL("SA1") + M->AAH_CODCLI + M->AAH_LOJA, "A1_NOME") + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   cString := cString + "S CODIGO PRODUTO                 DESCRICAO DOS PRODUTOS         NUEMRO DE SERIES"     + CHR(13) + CHR(10)
   cString := cString + "- ------------------------------ ------------------------------ --------------------" + CHR(13) + CHR(10)

   For nContar = 1 to Len(aLista)
       
       Do Case
          Case Substr(cComboBx1,01,01) == "1"
               If aLista[nContar,01] == .T.
                  Loop
               Endif
          Case Substr(cComboBx1,01,01) == "2"
               If aLista[nContar,01] == .F.
                  Loop
               Endif
       EndCase                  

       cString := cString + IIF(aLista[nContar,01] == .F., " ", "X") + " " + ;
                            aLista[nContar,05]                       + " " + ;
                            aLista[nContar,06]                       + " " + ;                            
                            aLista[nContar,07]                       + CHR(13) + CHR(10)

   Next nContar   
   
   // Salva o arquivo de log de Baixas
   cCaminho := Alltrim(cCaminho)

   nHdl := fCreate(cCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)
   
   oDlgTXT:End() 

   MsgAlert("Arquivo gerado com sucesso.")

Return(.T.)
