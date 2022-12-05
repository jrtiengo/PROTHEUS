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

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM591.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 03/07/2017                                                          ##
// Objetivo..: Programa que realiza a baixa de títulos pela leitura do arquivo de  ##
//             conciliação da CONCIL.                                              ##
// ##################################################################################

User Function AUTOM591()

   Local cMemo1	    := ""
   Local oMemo1

   Private aFiltro     := {}
   Private aAdquirente := {"SELECIONE"}
   Private aOrigem     := {"SELECIONE","AMBOS", "BAIXADOS"}
   Private aBandeiras  := {"SELECIONE"}
   Private aArquivos   := {}

   Private cComboBx1 
   Private cComboBx2 
   Private cComboBx3 
   Private cComboBx4 
   Private cComboBx5    
   
   Private oDlgKK

   Private aBrowse   := {}

   Private cCaminho  := ""

   Private aLista    := {}
   Private oLista

   Private aResumo   := {}
   Private oResumo

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private oVerde    := LoadBitmap(GetResources(),'br_verde'   )
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul'    )
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo' )
   Private oPreto    := LoadBitmap(GetResources(),'br_preto'   )
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja' )
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza'   )
   Private oBranco   := LoadBitmap(GetResources(),'br_branco'  )
   Private oPink     := LoadBitmap(GetResources(),'br_pink'    )
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel'  )
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom'  )
    
   // #######################################################################
   // Verifica se existe a pasta C:\SIMFRETE. Caso não exista, será criada ##
   // #######################################################################
   If !ExistDir( "C:\CONCIL" )

      nRet := MakeDir( "C:\CONCIL" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta C:\CONCIL. Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Else
         cCaminho := "C:\CONCIL\"
      Endif
   
   Else
      cCaminho := "C:\CONCIL\"   
   Endif

   // ##########################
   // Carrega o array aFiltro ##
   // ##########################
   aAdd( aFiltro, "1 - Títulos com data prevista de recebimento"                )
   aAdd( aFiltro, "2 - Títulos com data efetiva de recebimento conciliados"     )   
   aAdd( aFiltro, "3 - Títulos com data efetiva de recebimento não conciliados" )   
   aAdd( aFiltro, "4 - Títulos baixados no Protheus (Total)"                    )         
   aAdd( aFiltro, "5 - Títulos baixados no Protheus (Parcial)"                  )         
   aAdd( aFiltro, "6 - Todos"                                                   )         

   // ##################################################
   // Envia para a função que carrega o array abrowse ##
   // ##################################################
   CargaBrowseCRT(0)

   DEFINE MSDIALOG oDlgKK TITLE "Baixa de Títulos Conciliados - CONCIL" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgKK

   @ C(001),C(129) Jpeg FILE "br_azul.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlgKK
   @ C(009),C(129) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgKK
   @ C(017),C(129) Jpeg FILE "br_laranja.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgKK
   @ C(024),C(129) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlgKK
   @ C(031),C(129) Jpeg FILE "br_preto.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgKK

   @ C(002),C(140) Say "Títulos com data prevista de recebimento"                Size C(099),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK
   @ C(009),C(140) Say "Títulos com data efetiva de recebimento conciliados"     Size C(125),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK
   @ C(017),C(140) Say "Títulos com data efetiva de recebimento não conciliados" Size C(136),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK
   @ C(024),C(140) Say "Título baixados no Protheus"                             Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK
   @ C(031),C(140) Say "Título baixados parcialmente no Protheus"                Size C(099),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK

   @ C(003),C(325) Say "Arquivos"                                 Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK
   @ C(012),C(325) Say "Filtrar por"                              Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK
   @ C(036),C(005) Say "Registros do arquivo importado"    Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgKK

   @ C(002),C(345) ComboBox cComboBx5 Items aArquivos    Size C(130),C(010) PIXEL OF oDlgKK
   @ C(011),C(345) ComboBox cComboBx4 Items aFiltro      Size C(130),C(010) PIXEL OF oDlgKK

   @ C(022),C(355) Button "Importar"                     Size C(058),C(012) PIXEL OF oDlgKK ACTION( ImpCRTBrowse() )
   @ C(022),C(414) Button "Limpa Importação"             Size C(056),C(012) PIXEL OF oDlgKK ACTION( LimpaImpArq() )      When !Empty(Alltrim(aLista[01,03]))
   @ C(210),C(005) Button "Marca Todos"                  Size C(050),C(012) PIXEL OF oDlgKK ACTION( MrcDmrcRegLista(1) ) When !Empty(Alltrim(aLista[01,03]))
   @ C(210),C(056) Button "Desmarca Todos"               Size C(050),C(012) PIXEL OF oDlgKK ACTION( MrcDmrcRegLista(0) ) When !Empty(Alltrim(aLista[01,03]))
   @ C(210),C(107) Button "Funções Contas a Receber"     Size C(076),C(012) PIXEL OF oDlgKK ACTION( FINA740() )
   @ C(210),C(184) Button "Baixar Títulos"               Size C(050),C(012) PIXEL OF oDlgKK ACTION( BaixaAutCONCIL() )   When !Empty(Alltrim(aLista[01,03]))
   @ C(210),C(235) Button "Altera NF"                    Size C(037),C(012) PIXEL OF oDlgKK ACTION( PsqNotaPed() )       When !Empty(Alltrim(aLista[01,03])) 
   @ C(210),C(286) Button "Resumo Baixas"                Size C(037),C(012) PIXEL OF oDlgKK ACTION( ResultadoBx() )      When Len(aResumo) <> 0
   @ C(210),C(461) Button "Voltar"                       Size C(037),C(012) PIXEL OF oDlgKK ACTION( oDlgKK:End() )

   // #################
   // Desenha aLista ##
   // #################
   aAdd( aLista, { .F., "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   @ 055,005 LISTBOX oLista FIELDS HEADER "M"                    ,; // 01  
                                          "LG"                   ,; // 02 
                                          "ID Conc."             ,; // 03
                                          "Adquirente"           ,; // 04
                                          "Estabelecimento"      ,; // 05
                                          "Terminal"             ,; // 06
                                          "Dta Venda"            ,; // 07
                                          "Prv. Pgtº"            ,; // 08
                                          "Origem"               ,; // 09
                                          "Bandeira/Produto"     ,; // 10
                                          "NSU / DOC"            ,; // 11
                                          "Parcerla/Qtd"         ,; // 12
                                          "Cartão"               ,; // 13
                                          "Autorização"          ,; // 14
                                          "Histórico"            ,; // 15
                                          "Vlr Bruto Previsto"   ,; // 16
                                          "Vlr Bruto Pago"       ,; // 17
                                          "Vlr Liq. Previsto"    ,; // 18
                                          "Vlr Liq. Pago"        ,; // 19
                                          "Taxa"                 ,; // 20
                                          "Nota/Pedido"          ,; // 21
                                          "Banco"                ,; // 22
                                          "Agência"              ,; // 23
                                          "Conta"                ,; // 24
                                          "CONCIL"               ,; // 25
                                          "Parcela Protheus"     ,; // 26
                                          "Parcela CONCIL"       ,; // 27
                                          "Valor Taxa"            ; // 28
                                          PIXEL SIZE 633,210 OF oDlgKK ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
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
                           aLista[oLista:nAt,17]         ,;
                           aLista[oLista:nAt,18]         ,;
                           aLista[oLista:nAt,19]         ,;
                           aLista[oLista:nAt,20]         ,;
                           aLista[oLista:nAt,21]         ,;
                           aLista[oLista:nAt,22]         ,;
                           aLista[oLista:nAt,23]         ,;
                           aLista[oLista:nAt,24]         ,;
                           aLista[oLista:nAt,25]         ,;
                           aLista[oLista:nAt,26]         ,;                                                      
                           aLista[oLista:nAt,27]         ,;                                                      
                           aLista[oLista:nAt,28]         }}

//   oLista:bLDblClick := {|| ChecaReg() }
   oLista:bHeaderClick := {|oObj,nCol| oLista:aArray := Ordenar(nCol,oLista:aArray),oLista:Refresh()}

   ACTIVATE MSDIALOG oDlgKK CENTERED 

Return(.T.)

// #################################################
// Função que Ordena a coluna selecionada no grid ##
// #################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol == 1
      Return(.T.)
   Endif
      
   If _nPosCol == 2
      Return(.T.)
   Endif
      
   _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays

Return(_aOrdena)

// ##########################################
// Função que checa o registro selecionado ##
// ##########################################
Static Function ChecaReg()

   If aLista[oLista:nAt,02] == "8"
      MsgAlert("Registro não pode ser selecionado pois o mesmo já foi quitado no Sistema Protheus.")
      aLista[oLista:nAt,01] := .F.

      oLista:SetArray( aLista )

      oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                           If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                           If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                           If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                           If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
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
                              aLista[oLista:nAt,17]         ,;
                              aLista[oLista:nAt,18]         ,;
                              aLista[oLista:nAt,19]         ,;
                              aLista[oLista:nAt,20]         ,;
                              aLista[oLista:nAt,21]         ,;
                              aLista[oLista:nAt,22]         ,;
                              aLista[oLista:nAt,23]         ,;
                              aLista[oLista:nAt,24]         ,;
                              aLista[oLista:nAt,25]         ,;
                              aLista[oLista:nAt,26]         ,;                                                            
                              aLista[oLista:nAt,27]         ,;                                                            
                              aLista[oLista:nAt,28]         }}

   Endif

Return(.T.)

// #########################################
// Função que marca/desmarca os registros ##
// #########################################
Static Function MrcDmrcRegLista(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
   
       If kTipo == 1
          If StrTran(Alltrim(aLista[nContar,09]), chr(10), "") == "PAGO"       
             If Empty(Alltrim(StrTran(aLista[nContar,21], chr(10), "")))
                aLista[nContar,01] := .F.
             Else
                aLista[nContar,01] := .T.                
             Endif         
          Endif
       Else
          aLista[nContar,01] := .F.
       Endif
   Next nContar
   
Return(.T.)       

// ##############################################################################################
// Função que carrega o browse com os arquivos disponíveis para importação de baixa de títulos ##
// ##############################################################################################
Static Function CargaBrowseCRT(kTipo)

   Local lChumba   := .F.
   Local nContar   := 0
   Local aFiles    := {} // O array receberá os nomes dos arquivos e do diretório
   Local aSizes    := {} // O array receberá os tamanhos dos arquivos e do diretorio
   Local nRegua    := 0
   Local cAvancada := Space(250)
   Local cMemo1	   := ""
   Local oGet1
   Local oMemo1

   // #########################################################################
   // Inicializa o array que receberá o nome dos arquivos a serem importados ##
   // #########################################################################
   aBrowse   := {}
   aArquivos := {}

   // ############################################
   // Carrega os arquivos do diretório de XML's ##
   // ############################################
   ADir(Alltrim(cCaminho) + "*.TXT", aFiles, aSizes)

   // #################################################
   // Carrega o array aArquivos para display no List ##
   // #################################################
   nRegua := 0
   nCount := Len( aFiles )

   For nX := 1 to nCount  
 
       // ##################################
       // Despreza arquivos já importados ##
       // ##################################
       If Substr(aFiles[nX],01,01) == "#"
          Loop
       Endif

       cString := U_P_CORTA(aFiles[nX], ".", 1)

       aAdd( aBrowse  , { aFiles[nX] } )
       aAdd( aArquivos, aFiles[nX] )
          
   Next nX

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "" } )
   Endif
      
   If kTipo == 0
      Return(.T.)
   Endif   

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]} }

Return(.T.)

// ######################################################
// Função que importa o arquivo selecionado na aBrowse ##
// ######################################################
Static Function ImpCRTBrowse()

   MsgRun("Aguarde! Importando dados do arquivo selecionado ...", "Importação CONCIL",{|| xImpCRTBrowse() })

Return(.T.)

// ######################################################
// Função que importa o arquivo selecionado na aBrowse ##
// ######################################################
Static Function xImpCRTBrowse()

   Local nContar   := 0
   Local nPercorre := 0
   Local nLimpa    := 0
   Local lMarcadas := .F.
   Local cAgravar  := ""
   Local cConteudo := ""
   Local aCarga    := {}  
   Local nProcura  := 0
   Local lJaEsta   := .F.       
   
   // ################################################
   // Limpa o array aLimpa para receber novos dados ##
   // ################################################
   aLista := {}

   // ########################################
   // Abre o arquivo selecionado na aBrowse ##
   // ########################################
// nHandle := FOPEN(Alltrim(cCaminho) + Alltrim(aBrowse[oBrowse:nAt,01]), FO_READWRITE + FO_SHARED)
   nHandle := FOPEN(Alltrim(cCaminho) + Alltrim(cComBobx5), FO_READWRITE + FO_SHARED)

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

          aAdd( aCarga, { cConteudo } )
          cConteudo := ""

       Endif

   Next nPercorre

   // ##################################
   // Fecha a leitura do arquivo lido ##
   // ##################################
   FCLOSE(nHandle)

   // #######################################################
   // Carrega o array aBrowse pela leitura do array aCarga ##
   // #######################################################
   kInicio := .F.

   For nContar = 12 to Len(aCarga)

       If Substr(strtran(aCarga[nContar,1], chr(10), ""),01,01) == " "
       Else

          kLinha01 := Alltrim(str(int(val(U_P_CORTA(aCarga[nContar,01], CHR(9), 01)))))
          kLinha02 := U_P_CORTA(aCarga[nContar,01], CHR(9), 02)
          kLinha03 := U_P_CORTA(aCarga[nContar,01], CHR(9), 03)
          kLinha04 := U_P_CORTA(aCarga[nContar,01], CHR(9), 04)
          kLinha05 := U_P_CORTA(aCarga[nContar,01], CHR(9), 05)
          kLinha06 := U_P_CORTA(aCarga[nContar,01], CHR(9), 06)
          kLinha07 := U_P_CORTA(aCarga[nContar,01], CHR(9), 07)
          kLinha08 := U_P_CORTA(aCarga[nContar,01], CHR(9), 08)
          kLinha09 := U_P_CORTA(aCarga[nContar,01], CHR(9), 09)
          kLinha10 := U_P_CORTA(aCarga[nContar,01], CHR(9), 10)
          kLinha11 := U_P_CORTA(aCarga[nContar,01], CHR(9), 11)
          kLinha12 := U_P_CORTA(aCarga[nContar,01], CHR(9), 12)
          kLinha13 := U_P_CORTA(aCarga[nContar,01], CHR(9), 13)
          kLinha14 := U_P_CORTA(aCarga[nContar,01], CHR(9), 14)
          kLinha15 := U_P_CORTA(aCarga[nContar,01], CHR(9), 15)
          kLinha16 := U_P_CORTA(aCarga[nContar,01], CHR(9), 16)
          kLinha17 := U_P_CORTA(aCarga[nContar,01], CHR(9), 17)
          kLinha18 := U_P_CORTA(aCarga[nContar,01], CHR(9), 18)
          kLinha19 := U_P_CORTA(aCarga[nContar,01], CHR(9), 19)
          kLinha20 := U_P_CORTA(aCarga[nContar,01], CHR(9), 20)
          kLinha21 := U_P_CORTA(aCarga[nContar,01], CHR(9), 21)
          kLinha22 := U_P_CORTA(aCarga[nContar,01], CHR(9), 22)

          Do Case
             Case Alltrim(kLinha07) == "PREVISTO" 
                  kLegenda := "5"
             Case Alltrim(kLinha07) == "PAGO" 

                  If Empty(Alltrim(kLinha19))
                     kLegenda := "6"
                  Else
                     kLegenda := "2"                     
                  Endif   

             Otherwise
                  kLegenda := "1"
          EndCase

          // ######################################
          // Verifica se o título já foi baixado ##
          // ######################################
          If U_P_OCCURS(Alltrim(kLinha19) + "-", "-", 1) == 4

             If Select("T_PAGO") > 0
                T_PAGO->( dbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT E1_FILIAL ,"
             cSql += "       E1_PREFIXO,"
             cSql += " 	     E1_NUM    ,"
             cSql += "       E1_PARCELA,"
             cSql += "       E1_VALOR  ,"
             cSql += "       E1_SALDO   "

             Do Case
                Case Substr(kLinha19,01,02) == "01"
                     cSql += "  FROM SE1010 
                Case Substr(kLinha19,01,02) == "02"
                     cSql += "  FROM SE1020 
                Case Substr(kLinha19,01,02) == "03"
                     cSql += "  FROM SE1030 
                Case Substr(kLinha19,01,02) == "04"
                     cSql += "  FROM SE1040 
             EndCase 

//             cSql += " WHERE E1_FILORIG = '01'
//             cSql += "   AND E1_PREFIXO = '1'
//             cSql += "   AND E1_NUM     = '081266'
//             cSql += "   AND D_E_L_E_T_ = '' 

             cSql += " WHERE E1_NUM     = '" + Alltrim(U_P_CORTA(kLinha19 + "-", "-", 4)) + "'"
             cSql += "   AND E1_TIPO    = 'NF '"
             cSql += "   AND E1_PREFIXO = '" + Alltrim(U_P_CORTA(kLinha19 + "-", "-", 3)) + "'"   
             cSql += "   AND D_E_L_E_T_ = '' 

             If Alltrim(kLinha12) == "01/01"
             Else            
                cSql += " AND E1_PARCELA = '" + Substr(kLinha12,01,02) + "'"
             Endif      
          
             cSql := ChangeQuery( cSql )
             dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PAGO", .T., .T. )

             If !T_PAGO->( EOF() )
                kLegenda := "8"
             Endif

          Endif

          // ############################
          // Pesquisa dados da parcela ##
          // ############################
          If Select("T_RECEBER") > 0
             T_RECEBER->( dbCloseArea() )
          EndIf

          cSql := "" 
          cSql := "SELECT SE1.E1_FILIAL ,"
          cSql += "       SE1.E1_PREFIXO,"
          cSql += "	      SE1.E1_NUM    ,"
          cSql += "	      SE1.E1_PARCELA,"
          cSql += " 	  SE1.E1_TIPO   ,"
          cSql += "	      SE1.E1_CLIENTE,"
          cSql += "	      SE1.E1_LOJA   ,"
          cSql += "	      SE1.E1_NOMCLI ,"
          cSql += "       SE1.E1_VALOR   "
          cSql += "  FROM " + RetSqlName("SE1") + " SE1 "
          cSql += " WHERE SE1.E1_NUM     = '" + Alltrim(U_P_CORTA(kLinha19 + "-", "-", 4)) + "'"
          cSql += "   AND SE1.E1_TIPO    = 'NF '"
          cSql += "   AND SE1.E1_PREFIXO = '" + Alltrim(U_P_CORTA(kLinha19 + "-", "-", 3)) + "'"   
          
          If Alltrim(kLinha10) == "01/01"
          Else
             cSql += "   AND SE1.E1_PARCELA = '" + Alltrim(U_P_CORTA(kLinha10, "/", 1))       + "'
          Endif
             
          cSql += "   AND SE1.D_E_L_E_T_ = ''   "

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RECEBER", .T., .T. )

          If T_RECEBER->( EOF() )
             kValorProtheus := 0
          Else
             kValorProtheus := T_RECEBER->E1_VALOR
          Endif   

          // #####################################################
          // Seleciona os registros conforme filtro selecionado ##
          // #####################################################
          Do Case
             Case Substr(cComboBx4,01,01) == "1"
                  If kLegenda <> "5"
                     Loop
                  Endif
                     
             Case Substr(cComboBx4,01,01) == "2"

                  If kLegenda <> "2"
                     Loop
                  Endif

                  If Empty(Alltrim(kLinha21))
                      Loop
                  Endif

             Case Substr(cComboBx4,01,01) == "3"

                  If kLegenda <> "6"
                     Loop
                  Endif

             Case Substr(cComboBx4,01,01) == "4"

                  If kLegenda <> "8"
                     Loop
                  Endif

             Case Substr(cComboBx4,01,01) == "5"

                  If kLegenda <> "7"
                     Loop
                  Endif

          EndCase

          // ######################################
          // Carrega o array aLista para display ##
          // ######################################
          aAdd( aLista, { .F.               ,;
                          kLegenda          ,;
                          Alltrim(kLinha01) ,;
                          Alltrim(kLinha02) ,;
                          Alltrim(kLinha03) ,;
                          Alltrim(kLinha04) ,;
                          Alltrim(kLinha05) ,;
                          Alltrim(kLinha06) ,;
                          Alltrim(kLinha07) ,;
                          Alltrim(kLinha08) ,;
                          Alltrim(kLinha09) ,;
                          Alltrim(kLinha10) ,;
                          Alltrim(kLinha11) ,;
                          Alltrim(kLinha12) ,;
                          Alltrim(kLinha13) ,;
                          Transform(VAL(STRTRAN(STRTRAN(kLinha14,".",""), ",", ".")), "@E 9999999.99") ,;
                          Transform(VAL(STRTRAN(STRTRAN(kLinha15,".",""), ",", ".")), "@E 9999999.99") ,;
                          Transform(VAL(STRTRAN(STRTRAN(kLinha16,".",""), ",", ".")), "@E 9999999.99") ,;
                          Transform(VAL(STRTRAN(STRTRAN(kLinha17,".",""), ",", ".")), "@E 9999999.99") ,;                                                                                       
                          Alltrim(kLinha18) ,;
                          Alltrim(kLinha19) ,;
                          Alltrim(kLinha20) ,;
                          Alltrim(kLinha21) ,;
                          Alltrim(kLinha22) ,;
                          IIF(Empty(Alltrim(kLinha19)), "N", "S"),;
                          kValorProtheus    ,;
                          Transform(VAL(STRTRAN(STRTRAN(kLinha17,".",""), ",", ".")), "@E 9999999.99") ,;
                          kValorProtheus - VAL(STRTRAN(STRTRAN(kLinha17,".",""), ",", ".")) ,;
                          ""                })
                                   
          // ################################################################
          // Verifica se o Adquirente já está contido no array aAdquirente ##
          // ################################################################
          lJaEsta := .F.  
          kAdquirente := kLinha02
          For nProcura = 1 to Len(aAdquirente)
              If Upper(Alltrim(aAdquirente[nProcura])) == kAdquirente
                 lJaEsta := .T.
                 Exit
              Endif
          Next nProcura
                    
          If lJaEsta == .F.       
             aAdd( aAdquirente, kAdquirente )
          Endif   

          // ########################################################
          // Verifica se a Origem já está contido no array aOrigem ##
          // ########################################################
          lJaEsta := .F.
          kOrigem := kLinha07
          For nProcura = 1 to Len(aOrigem)
              If Upper(Alltrim(aOrigem[nProcura])) == kOrigem
                 lJaEsta := .T.
                 Exit
              Endif
          Next nProcura
                
          If lJaEsta == .F.       
             aAdd( aOrigem, kOrigem )
          Endif   
 
          // ############################################################
          // Verifica se a Bandeira já está contido no array aBandeira ##
          // ############################################################
          lJaEsta   := .F.
          kBandeira := kLinha08
          For nProcura = 1 to Len(aBandeiras)
              If Upper(Alltrim(aBandeiras[nProcura])) == kBandeira
                 lJaEsta := .T.
                 Exit
              Endif
          Next nProcura
                    
          If lJaEsta == .F.       
             aAdd( aBandeiras, kBandeira )
          Endif   

       Endif

   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { .F., "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif
      
   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
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
                           aLista[oLista:nAt,17]         ,;
                           aLista[oLista:nAt,18]         ,;
                           aLista[oLista:nAt,19]         ,;
                           aLista[oLista:nAt,20]         ,;
                           aLista[oLista:nAt,21]         ,;
                           aLista[oLista:nAt,22]         ,;
                           aLista[oLista:nAt,23]         ,;
                           aLista[oLista:nAt,24]         ,;
                           aLista[oLista:nAt,25]         ,;
                           aLista[oLista:nAt,26]         ,;                                                      
                           aLista[oLista:nAt,27]         ,;                           
                           aLista[oLista:nAt,28]         }}

Return(.T.)

// ######################################
// Função que limpa a importação atual ##
// ######################################
Static Function LimpaImpArq()

   aLista := {}

   aAdd( aLista, { .F., "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
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
                           aLista[oLista:nAt,17]         ,;
                           aLista[oLista:nAt,18]         ,;
                           aLista[oLista:nAt,19]         ,;
                           aLista[oLista:nAt,20]         ,;
                           aLista[oLista:nAt,21]         ,;
                           aLista[oLista:nAt,22]         ,;
                           aLista[oLista:nAt,23]         ,;
                           aLista[oLista:nAt,24]         ,;
                           aLista[oLista:nAt,25]         ,;
                           aLista[oLista:nAt,26]         ,;                           
                           aLista[oLista:nAt,27]         ,;
                           aLista[oLista:nAt,28]         }}

Return(.T.)

// ####################################################
// Função que abre a tela de pesquisa da nota fiscal ##
// ####################################################
Static Function PsqNotaPed()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private cIDCON	:= aLista[oLista:nAt,03]
   Private cVDCON	:= aLista[oLista:nAt,07]
   Private cBACON	:= aLista[oLista:nAt,10]
   Private cATCON	:= aLista[oLista:nAt,14]
   Private cNSCON	:= aLista[oLista:nAt,11]
   Private cCTCON	:= aLista[oLista:nAt,13]
   Private cPRCON	:= aLista[oLista:nAt,12]
   Private cVLCON	:= aLista[oLista:nAt,17]
   Private lCampo01 := .F.
   Private lCampo02 := .F.
   Private lCampo03 := .F.
   Private cCodEmp  := Space(02)
   Private cCodFil  := Space(02)
   Private cCodPre  := Space(03)
   Private cCodNot  := Space(09)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12        

   Private oCampo01
   Private oCampo02
   Private oCampo03   
   
   Private oDlgPSQ
   
   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aPesquisa := {}
   Private oPesquisa

   Private aListaPar := {}
   Private oListaPar

   // ################################################################
   // Verifica se o regsitro selecionado é um registro de pagamento ##
   // ################################################################
   If StrTran(Alltrim(aLista[oLista:nAt,09]), chr(10), "") == "PAGO"       
   Else
      MsgAlert("Registro selecionado não é um registro de pagamento.")
      Return(.T.)
   Endif

   If aLista[oLista:nAt,25] == "S"
      MsgAlert("Registro não pode ser alterado pois este foi conciliado pela CONCIL.")
      Return(.T.)
   Endif

   // #######################################
   // Carrega os dados do documento manual ##
   // #######################################
   If Empty(Alltrim(aLista[oLista:nAt,21]))
      cCodEmp  := cEmpAnt
      cCodFil  := Space(02)
      cCodPre  := Space(03)
      cCodNot  := Space(09)
   Else
      cCodEmp  := U_P_CORTA(Alltrim(aLista[oLista:nAt,21]) + "-", "-", 1)
      cCodFil  := U_P_CORTA(Alltrim(aLista[oLista:nAt,21]) + "-", "-", 2)
      cCodPre  := U_P_CORTA(Alltrim(aLista[oLista:nAt,21]) + "-", "-", 3)
      cCodNot  := U_P_CORTA(Alltrim(aLista[oLista:nAt,21]) + "-", "-", 4)
   Endif

   // Se retornar a utilizar, apagar estas variáveis abaixo
   cCodEmp  := Space(02)
   cCodFil  := Space(02)
   cCodPre  := Space(03)
   cCodNot  := Space(09)

   // ############################################
   // Desenha a tela paravisualização dos dados ##
   // ############################################
   DEFINE MSDIALOG oDlgPSQ TITLE "Conciliação CONCIL" FROM C(178),C(181) TO C(609),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgPSQ

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlgPSQ

   @ C(036),C(005) Say "ID Conc."                                             Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(036),C(032) Say "Dta Venda"                                            Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(036),C(071) Say "Bandeira"                                             Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(036),C(116) Say "Autorização"                                          Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(036),C(160) Say "NSU/DOC"                                              Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(036),C(202) Say "Cartão"                                               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(036),C(259) Say "Parcela/Qtd"                                          Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(036),C(294) Say "Valor"                                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(058),C(005) Say "Pedidos de Venda Localizados"                         Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
   @ C(116),C(005) Say "Parcelamento da Nota Fiscal selecionada"              Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ
// @ C(202),C(005) Say "Informação Manual (Empresa-Filial-Prefixo-Documento)" Size C(129),C(008) COLOR CLR_BLACK PIXEL OF oDlgPSQ

   @ C(045),C(005) MsGet oGet1 Var cIDCON Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
   @ C(045),C(032) MsGet oGet2 Var cVDCON Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
   @ C(045),C(071) MsGet oGet3 Var cBACON Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
   @ C(045),C(116) MsGet oGet4 Var cATCON Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
   @ C(045),C(160) MsGet oGet5 Var cNSCON Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
   @ C(045),C(202) MsGet oGet6 Var cCTCON Size C(051),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
   @ C(045),C(259) MsGet oGet7 Var cPRCON Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
   @ C(045),C(294) MsGet oGet8 Var cVLCON Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba

   @ C(057),C(116) CheckBox oCampo01 Var lCampo01 Prompt "" Size C(006),C(008) PIXEL OF oDlgPSQ
   @ C(057),C(160) CheckBox oCampo02 Var lCampo02 Prompt "" Size C(008),C(008) PIXEL OF oDlgPSQ
   @ C(057),C(202) CheckBox oCampo03 Var lCampo03 Prompt "" Size C(007),C(008) PIXEL OF oDlgPSQ

// @ C(201),C(136) MsGet oGet9  Var cCodEmp Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ When lChumba
// @ C(201),C(154) MsGet oGet10 Var cCodFil Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ
// @ C(201),C(172) MsGet oGet11 Var cCodPre Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ
// @ C(201),C(190) MsGet oGet12 Var cCodNot Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPSQ

   @ C(199),C(005) Button "Limpa Marcados" Size C(049),C(012) PIXEL OF oDlgPSQ ACTION( LmpRegMarc() )
   @ C(042),C(350) Button "Pesquisar"      Size C(038),C(012) PIXEL OF oDlgPSQ ACTION( PsqNFDISPO() )
   @ C(199),C(309) Button "Confirmar"      Size C(037),C(012) PIXEL OF oDlgPSQ ACTION( CFMNFPESQUISA() )
   @ C(199),C(350) Button "Voltar"         Size C(038),C(012) PIXEL OF oDlgPSQ ACTION( oDlgPSQ:End() )

   // #################
   // Desenha aLista ##
   // #################
   aAdd( aPesquisa, { "", "", "", "", "", "", "", "", "", "", "" })

   oPesquisa := TCBrowse():New( 084 , 005, 495, 060,,{"FILIAL"          ,; // 01
                                                      "Nº PV"           ,; // 02
                                                      "Emissão"         ,; // 03
                                                      "Cliente"         ,; // 04
                                                      "Loja"            ,; // 05
                                                      "Nome do Cliente" ,; // 06
                                                      "Nota Fiscal"     ,; // 07
                                                      "Série"           ,; // 08
                                                      "Dta Fat."        ,; // 09
                                                      "Valor" }         ,; // 10
                                                     {20,50,50,50},oDlgPSQ,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oPesquisa:SetArray(aPesquisa) 
    
   oPesquisa:bLine := {||{aPesquisa[oPesquisa:nAt,01],;
                          aPesquisa[oPesquisa:nAt,02],;
                          aPesquisa[oPesquisa:nAt,03],;
                          aPesquisa[oPesquisa:nAt,04],;
                          aPesquisa[oPesquisa:nAt,05],;
                          aPesquisa[oPesquisa:nAt,06],;
                          aPesquisa[oPesquisa:nAt,07],;                                                                              
                          aPesquisa[oPesquisa:nAt,08],;
                          aPesquisa[oPesquisa:nAt,09],;
                          aPesquisa[oPesquisa:nAt,10]}}

   oPesquisa:bLDblClick := {|| PegaParcelas( aPesquisa[oPesquisa:nAt,01], aPesquisa[oPesquisa:nAt,07], aPesquisa[oPesquisa:nAt,08], aPesquisa[oPesquisa:nAt,04], aPesquisa[oPesquisa:nAt,05]) }

   // ####################
   // Desenha aListaPar ##
   // ####################
   aAdd( aListaPar, { .F., "", "", "", "", "", "", "", ""  })

   @ 160,005 LISTBOX oListaPar FIELDS HEADER "M"             ,; // 01  
                                             "Prefixo"       ,; // 02 
                                             "Nº Documento"  ,; // 03
                                             "Parcelas"      ,; // 04
                                             "Data Emissão"  ,; // 05
                                             "Vencimento"    ,; // 06
                                             "Vctº Real"     ,; // 07
                                             "Valor parcela" ,; // 08
                                             "Data Baixa"     ; // 09
                                          PIXEL SIZE 495,090 OF oDlgPSQ ON dblClick(aListaPar[oListaPar:nAt,1] := !aLista[oListaPar:nAt,1],oListaPar:Refresh())     

   oListaPar:SetArray( aListaPar )

   oListaPar:bLine := {||{Iif(aListaPar[oListaPar:nAt,01],oOk,oNo),;
                              aListaPar[oListaPar:nAt,02]         ,;
                              aListaPar[oListaPar:nAt,03]         ,;
                              aListaPar[oListaPar:nAt,04]         ,;
                              aListaPar[oListaPar:nAt,05]         ,;
                              aListaPar[oListaPar:nAt,06]         ,;
                              aListaPar[oListaPar:nAt,07]         ,;
                              aListaPar[oListaPar:nAt,08]         ,;
                              aListaPar[oListaPar:nAt,09]         }}

   ACTIVATE MSDIALOG oDlgPSQ CENTERED 

Return(.T.)

// #####################################################################
// Função que limpa registros marcados na tela de seleção de parcelas ##
// #####################################################################
Static Function LmpRegMarc()

   Local nContar := 0
   
   For nContar = 1 to Len(aListaPar)
       aListaPar[nContar,01] := .F.
   Next nContar
   
Return(.T.)      

// ###################################################
// Função que confirma a seleção de uma nota fiscal ##
// ###################################################
Static Function CFMNFPESQUISA()

   Local nConfirma := 0
   Local lMarcado  := .F.
   Local qMarcado  := 0
   Local nManual   := 0
   
   // ################################################
   // Verifica se pelo meno um registro foi marcado ##
   // ################################################
   For nConfirma = 1 to Len(aListaPar)
       If aListaPar[nConfirma,01] == .T.
          lMarcado := .T.
          Exit
       Endif        
   Next nConfirma
   
   If lMarcado == .F.
      If Empty(Alltrim(cCodEmp)) .And. Empty(Alltrim(cCodFil)) .And. Empty(Alltrim(cCodPre)) .And. Empty(Alltrim(cCodNot))
         MsgAlert("Nenhum registro de parcela foi selecionado e nem foi informado manualmente o documento a ser considerado. Verifique!")
         Return(.T.)
      Endif   
   Endif

   If lMarcado == .T.
      If !Empty(Alltrim(cCodEmp)) .And. Empty(Alltrim(cCodFil)) .And. Empty(Alltrim(cCodPre)) .And. Empty(Alltrim(cCodNot))
         MsgAlert("Atenção! Marque um registro ou informe o documento manual. Não permitido duas informações. Verifique!")      
         Return(.T.)
      Endif
   Endif
         
   If !Empty(Alltrim(cCodEmp) + Alltrim(cCodFil) + Alltrim(cCodPre) + Alltrim(cCodNot))

      If Empty(Alltrim(cCodEmp))
      Else
         nManual := nManual + 1
      Endif
         
      If Empty(Alltrim(cCodFil))
      Else
         nManual := nManual + 1
      Endif
              
      If Empty(Alltrim(cCodPre))
      Else
         nManual := nManual + 1
      Endif
               
      If Empty(Alltrim(cCodNot))
      Else
         nManual := nManual + 1
      Endif

      If nManual <> 4
         MsgAlert("Informação incompleta no documento manual a ser considerado. Verifique!")
         Return(.T.)
      Endif

      // ###################################################
      // Atualiza o array aLista com a seleção da parcela ##
      // ###################################################
      aLista[oLista:nAt,21] := Alltrim(cEmpAnt) + "-" + Alltrim(cCodFil) + "-" + Alltrim(cCodPre) + "-" + Alltrim(cCodNot)

      oDlgPSQ:End()

      oLista:SetArray( aLista )

      oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                           If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                           If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                           If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                           If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                           If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
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
                            aLista[oLista:nAt,17]         ,;
                            aLista[oLista:nAt,18]         ,;
                            aLista[oLista:nAt,19]         ,;
                            aLista[oLista:nAt,20]         ,;
                            aLista[oLista:nAt,21]         ,;
                            aLista[oLista:nAt,22]         ,;
                            aLista[oLista:nAt,23]         ,;
                            aLista[oLista:nAt,24]         ,;
                            aLista[oLista:nAt,25]         ,;
                            aLista[oLista:nAt,26]         ,;
                            aLista[oLista:nAt,27]         ,;
                            aLista[oLista:nAt,28]         }}

      Return(.T.)
       
   Endif   
            
   If lMarcado == .T.

      // ########################################################################
      // Verifica quantos registros foram marcados. Permite somente um marcado ##
      // ########################################################################
      qMarcado := 0
      For nConfirma = 1 to Len(aListaPar)
          If aListaPar[nConfirma,01] == .T.
             qMarcado += 1
          Endif        
      Next nConfirma

      If qMarcado > 1
         MsgAlert("Somente permitido marca um registro de parcela. Verifique!")
         Return(.T.)
      Endif

      // ################################################
      // Verifica se o registro marcado já foi baixado ##
      // ################################################
      lBaixado := .F.
      For nConfirma = 1 to Len(aListaPar)
          If aListaPar[nConfirma,01] == .T.
             If !Empty(Ctod(aListaPar[nConfirma,09]))
                lBaixado := .T.
                Exit
             Endif
          Endif
      Next nConfirma          
             
      If lBaixado = .T.
         MsgAlert("Parcela selecionada já está baixada. Verifique!")
         Return(.T.)
      Endif
      
      // #####################################################
      // Verifica se a parce selecionada éa mesma da CONCIL ##
      // #####################################################
      For nConfirma = 1 to Len(aListaPar)
          If aListaPar[nConfirma,01] == .T.
             kk_Parcela := aListaPar[nConfirma,04]
             kk_Prefixo := aListaPar[nConfirma,02]
             kk_Nota    := aListaPar[nConfirma,03]

             If Empty(Alltrim(kk_Parcela)) 
                kk_Parcela := "01"
             Endif   

             Exit
          Endif
      Next nConfirma          

      If Alltrim(Upper(Substr(cPRCON,01,02))) <> Alltrim(Upper(kk_Parcela))
         MsgAlert("Parcela selecionada é inválida. Verifique!")
         Return(.T.)
      Endif

      // ###################################################
      // Atualiza o array aLista com a seleção da parcela ##
      // ###################################################
      aLista[oLista:nAt,21] := Alltrim(cEmpAnt) + "-" + Alltrim(aPesquisa[oPesquisa:nAt,01]) + "-" + Alltrim(kk_Prefixo) + "-" + Alltrim(kk_Nota)
      
   Endif   

   oDlgPSQ:End()

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
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
                           aLista[oLista:nAt,17]         ,;
                           aLista[oLista:nAt,18]         ,;
                           aLista[oLista:nAt,19]         ,;
                           aLista[oLista:nAt,20]         ,;
                           aLista[oLista:nAt,21]         ,;
                           aLista[oLista:nAt,22]         ,;
                           aLista[oLista:nAt,23]         ,;
                           aLista[oLista:nAt,24]         ,;
                           aLista[oLista:nAt,25]         ,;
                           aLista[oLista:nAt,26]         ,;
                           aLista[oLista:nAt,27]         ,;
                           aLista[oLista:nAt,28]         }}

Return(.T.)           

// ###############################################################
// Função que pesquisa a nota fiscal pela informação dos campos ##
// ###############################################################
Static Function PsqNFDISPO()

   Local cSql     := ""
   Local nMarcado := 0

   // ###################################################
   // Realiza consistência dos dados antes da pesquisa ##
   // ###################################################
   If lCampo01 == .F. .And. lCampo02 == .F. .And. lCampo03 == .F.
      MsgAlert("Indicação de qual campo deverá ser pesquisado não selecionado.")
      Return(.T.)
   Endif

   If lCampo01 == .T. 
      nMarcado += 1
   Endif    
   
   If lCampo02 == .T. 
      nMarcado += 1
   Endif    
   
   If lCampo03 == .T. 
      nMarcado += 1
   Endif    

   If nMarcado > 1
      MsgAlert("Informe apenas um campo a ser utilizado na pesquisa.")
      Return(.T.)
   Endif
   
   // #########################################################
   // Limpa o array aPesquisa para receber novas informações ##
   // #########################################################
   aPesquisa  := {}

   If Select("T_PROCURA") > 0
      T_PROCURA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ," + CHR(13)
   cSql += "       SC5.C5_NUM    ," + CHR(13)
   cSql += "       SC5.C5_EMISSAO," + CHR(13)
   cSql += "       SC5.C5_ADM    ," + CHR(13)
   cSql += "       SC5.C5_CARTAO ," + CHR(13)
   cSql += "       SC5.C5_AUTORIZ," + CHR(13)
   cSql += "       SC5.C5_TID    ," + CHR(13)
   cSql += "       SC5.C5_DOC    ," + CHR(13)
   cSql += "       SC5.C5_DATCART," + CHR(13)
   cSql += "       SC5.C5_CLIENTE," + CHR(13)
   cSql += "	   SC5.C5_LOJACLI," + CHR(13)
   cSql += "	   SA1.A1_NOME   ," + CHR(13)
   cSql += "      (SELECT TOP(1) C6_NOTA   FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND D_E_L_E_T_ = '') AS NOTA   ," + CHR(13)
   cSql += "      (SELECT TOP(1) C6_SERIE  FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND D_E_L_E_T_ = '') AS SERIE  ," + CHR(13)
   cSql += "      (SELECT TOP(1) C6_DATFAT FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND D_E_L_E_T_ = '') AS DATAFAT," + CHR(13)
   cSql += "      (SELECT SUM(C6_VALOR)"     + CHR(13)
   cSql += "   	     FROM " + RetSqlName("SC6")  + CHR(13)
   cSql += "	       WHERE C6_FILIAL = SC5.C5_FILIAL " + CHR(13)
   cSql += "		     AND C6_NUM    = SC5.C5_NUM AND D_E_L_E_T_ = ''" + CHR(13)
   cSql += "	         AND C6_NOTA   = (SELECT TOP(1) C6_NOTA   FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND D_E_L_E_T_ = '')" + CHR(13)
   cSql += "		     AND C6_SERIE  = (SELECT TOP(1) C6_SERIE  FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND D_E_L_E_T_ = '')) AS TOTAL" + CHR(13)
   cSql += "   FROM " + RetSqlName("SC5") + " SC5, " + CHR(13)
   cSql += "        " + RetSqlName("SA1") + " SA1  "    + CHR(13)

   Do Case
      Case lCampo01 == .T.
//         cSql += "  WHERE SC5.C5_AUTORIZ = '" + Alltrim(StrTran(Alltrim(aLista[oLista:nAt,14]), chr(10), "")) + "'" + CHR(13)
           cSql += "  WHERE SC5.C5_AUTORIZ LIKE '%" + Alltrim(StrTran(Alltrim(aLista[oLista:nAt,14]), chr(10), "")) + "%'" + CHR(13)
      Case lCampo02 == .T.
//         cSql += "  WHERE SC5.C5_TID     = '" + Alltrim(StrTran(Alltrim(aLista[oLista:nAt,11]), chr(10), "")) + "'" + CHR(13)
           cSql += "  WHERE SC5.C5_TID     LIKE '%" + Alltrim(StrTran(Alltrim(aLista[oLista:nAt,11]), chr(10), "")) + "%'" + CHR(13)
      Case lCampo03 == .T.
//         cSql += "  WHERE SC5.C5_CARTAO  = '" + Substr(Alltrim(StrTran(Alltrim(aLista[oLista:nAt,13]), chr(10), "")),13,04) + "'" + CHR(13)
           cSql += "  WHERE SC5.C5_CARTAO  LIKE '%" + Substr(Alltrim(StrTran(Alltrim(aLista[oLista:nAt,13]), chr(10), "")),13,04) + "%'" + CHR(13)
   EndCase        

   cSql += "    AND SC5.D_E_L_E_T_ = ''" + CHR(13)
   cSql += "    AND SA1.A1_COD     = SC5.C5_CLIENTE" + CHR(13)
   cSql += "    AND SA1.A1_LOJA    = SC5.C5_LOJACLI" + CHR(13)
   cSql += "    AND SA1.D_E_L_E_T_ = ''            " + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROCURA", .T., .T. )

   T_PROCURA->( DbGoTop() )
   
   WHILE !T_PROCURA->( EOF() )

      kkEmissao := Substr(T_PROCURA->C5_EMISSAO,07,02) + "/" + Substr(T_PROCURA->C5_EMISSAO,05,02) + "/" + Substr(T_PROCURA->C5_EMISSAO,01,04)
      kkDataFat := Substr(T_PROCURA->DATAFAT   ,07,02) + "/" + Substr(T_PROCURA->DATAFAT   ,05,02) + "/" + Substr(T_PROCURA->DATAFAT   ,01,04)
   
      aAdd( aPesquisa, { T_PROCURA->C5_FILIAL ,; // 01
                         T_PROCURA->C5_NUM    ,; // 02
                         kkEmissao            ,; // 03
                         T_PROCURA->C5_CLIENTE,; // 04
                         T_PROCURA->C5_LOJACLI,; // 05
                         T_PROCURA->A1_NOME   ,; // 06
                         T_PROCURA->NOTA      ,; // 07
                         T_PROCURA->SERIE     ,; // 08
                         kkDataFat            ,; // 09
                         Transform(T_PROCURA->TOTAL, "@E 9999999.99") }) // 10

      T_PROCURA->( DbSkip() )
      
   ENDDO   

   If Len(aPesquisa) == 0
      aAdd( aPesquisa, { "", "", "", "", "", "", "", "", "", "", "" })
      MsgAlert("Não existem dados a srem visualizados para esta pesquisa.")
   Endif
   
   // ##########################################################################################
   // Envia para a função que pesquisa as parcelas da primeira nota fiscal do array aPesquisa ##
   // ##########################################################################################
   PegaParcelas( aPesquisa[oPesquisa:nAt,01], aPesquisa[oPesquisa:nAt,07], aPesquisa[oPesquisa:nAt,08], aPesquisa[oPesquisa:nAt,04], aPesquisa[oPesquisa:nAt,05] )
   
   // #####################################
   // Atualiza o array aPesquisa na tela ##
   // #####################################
   oPesquisa:SetArray( aPesquisa )

   oPesquisa:bLine := {||{aPesquisa[oPesquisa:nAt,01]         ,;
                          aPesquisa[oPesquisa:nAt,02]         ,;
                          aPesquisa[oPesquisa:nAt,03]         ,;
                          aPesquisa[oPesquisa:nAt,04]         ,;
                          aPesquisa[oPesquisa:nAt,05]         ,;
                          aPesquisa[oPesquisa:nAt,06]         ,;
                          aPesquisa[oPesquisa:nAt,07]         ,;
                          aPesquisa[oPesquisa:nAt,08]         ,;
                          aPesquisa[oPesquisa:nAt,09]         ,;                                                            
                          aPesquisa[oPesquisa:nAt,10]         }}

Return(.T.)

// #################################################################################################
// Função que pesquisa as parcelas da nota fiscal selecionada na tela de alteração de nota fiscal ##
// #################################################################################################
Static Function PegaParcelas(kFilial, kNota, kSerie, kCliente, kLoja)

   Local cSql := ""

   aListaPar := {}

   If Select("T_PARCELAS") > 0
      T_PARCELAS->( dbCloseArea() )
   EndIf

   cSql := " SELECT E1_FILORIG,"
   cSql += "        E1_PREFIXO,"
   cSql += " 	    E1_NUM    ,"
   cSql += " 	    E1_PARCELA,"
   cSql += " 	    E1_EMISSAO,"
   cSql += " 	    E1_VENCTO ,"
   cSql += " 	    E1_VENCREA,"
   cSql += " 	    E1_VALOR  ,"
   cSql += " 	    E1_BAIXA  ,"
   cSql += " 	    E1_CLIENTE,"
   cSql += " 	    E1_LOJA    "
   cSql += "   FROM " + RetSqlName("SE1")
   cSql += "  WHERE E1_FILORIG = '" + Alltrim(kFilial)  + "'"
   cSql += "    AND E1_NUM     = '" + Alltrim(kNota)    + "'"
   cSql += "    AND E1_PREFIXO = '" + Alltrim(kSerie)   + "'"
   cSql += "    AND E1_CLIENTE = '" + Alltrim(kCliente) + "'"
   cSql += "    AND E1_LOJA    = '" + Alltrim(kLoja)    + "'"
   cSql += "    AND D_E_L_E_T_ = ''"
 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

   If T_PARCELAS->( EOF() )

      aAdd( aListaPar, { .F., "", "", "", "", "", "", "", ""  })   
   
      oListaPar:SetArray( aListaPar )

      oListaPar:bLine := {||{Iif(aListaPar[oListaPar:nAt,01],oOk,oNo),;
                                 aListaPar[oListaPar:nAt,02]         ,;
                                 aListaPar[oListaPar:nAt,03]         ,;
                                 aListaPar[oListaPar:nAt,04]         ,;
                                 aListaPar[oListaPar:nAt,05]         ,;
                                 aListaPar[oListaPar:nAt,06]         ,;
                                 aListaPar[oListaPar:nAt,07]         ,;
                                 aListaPar[oListaPar:nAt,08]         ,;
                                 aListaPar[oListaPar:nAt,09]         }}
                                 
      Return(.T.)
      
   Endif
                                       
   T_PARCELAS->( DbGoTop() )
   
   WHILE !T_PARCELAS->( EOF() )
   
      aAdd( aListaPar, { .F.                   ,;
                         T_PARCELAS->E1_PREFIXO,;
                         T_PARCELAS->E1_NUM    ,;
                         T_PARCELAS->E1_PARCELA,;
                         Substr(T_PARCELAS->E1_EMISSAO,07,02) + "/" + Substr(T_PARCELAS->E1_EMISSAO,05,02) + "/" + Substr(T_PARCELAS->E1_EMISSAO,01,04) ,;
                         Substr(T_PARCELAS->E1_VENCTO ,07,02) + "/" + Substr(T_PARCELAS->E1_VENCTO ,05,02) + "/" + Substr(T_PARCELAS->E1_VENCTO ,01,04) ,;
                         Substr(T_PARCELAS->E1_VENCREA,07,02) + "/" + Substr(T_PARCELAS->E1_VENCREA,05,02) + "/" + Substr(T_PARCELAS->E1_VENCREA,01,04) ,;
                         Transform(T_PARCELAS->E1_VALOR, "@E 9999999.99") ,;
                         Substr(T_PARCELAS->E1_BAIXA  ,07,02) + "/" + Substr(T_PARCELAS->E1_BAIXA  ,05,02) + "/" + Substr(T_PARCELAS->E1_BAIXA  ,01,04) })

      T_PARCELAS->( DbSkip() )
      
   ENDDO                            
          
   If Len(aListaPar) == 0
      aAdd( aListaPar, { .F., "", "", "", "", "", "", "", ""  })   
   Endif
   
   oListaPar:SetArray( aListaPar )

   oListaPar:bLine := {||{Iif(aListaPar[oListaPar:nAt,01],oOk,oNo),;
                              aListaPar[oListaPar:nAt,02]         ,;
                              aListaPar[oListaPar:nAt,03]         ,;
                              aListaPar[oListaPar:nAt,04]         ,;
                              aListaPar[oListaPar:nAt,05]         ,;
                              aListaPar[oListaPar:nAt,06]         ,;
                              aListaPar[oListaPar:nAt,07]         ,;
                              aListaPar[oListaPar:nAt,08]         ,;
                              aListaPar[oListaPar:nAt,09]         }}

   oListaPar:refresh()

Return(.T.)

// #################################################################
// Função que realiza a baixa automática dos títulos selecionados ##
// #################################################################
Static Function BaixaAutCONCIL()

   Local cMemo1	 := ""
   Local oMemo1
   Local nContar := 0

   Private oDlgBaixax

   Private oOk     := LoadBitmap( GetResources(), "LBOK" )
   Private oNo     := LoadBitmap( GetResources(), "LBNO" )

   Private aBaixar := {}
   Private oBaixar

   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif

       // #########################################################################################
       // Verifica o formato do documento. Se não estiver no formato válido, despreza o registro ##
       // #########################################################################################
//       If U_P_OCCURS(aLista[nContar,21] + "-", "-", 1) <> 4
//          Loop
//       Endif   

       If Empty(Alltrim(aLista[nContar,21]))
          Loop
       Endif   

       // ################################
       // Pesquisa dados da nota fiscal ##
       // ################################
       If Select("T_RECEBER") > 0
          T_RECEBER->( dbCloseArea() )
       EndIf

       cSql := "" 
       cSql := "SELECT SE1.E1_FILIAL ,"
       cSql += "       SE1.E1_PREFIXO,"
       cSql += "	   SE1.E1_NUM    ,"
       cSql += "	   SE1.E1_PARCELA,"
       cSql += " 	   SE1.E1_TIPO   ,"
       cSql += "	   SE1.E1_CLIENTE,"
       cSql += "	   SE1.E1_LOJA   ,"
       cSql += "	   SE1.E1_NOMCLI ,"
       cSql += "       SE1.E1_VALOR   "
       cSql += "  FROM " + RetSqlName("SE1") + " SE1 "
       cSql += " WHERE SE1.E1_NUM     = '" + Alltrim(U_P_CORTA(aLista[nContar,21] + "-", "-", 4)) + "'"
       cSql += "   AND SE1.E1_TIPO    = 'NF '"
       cSql += "   AND SE1.E1_PREFIXO = '" + Alltrim(U_P_CORTA(aLista[nContar,21] + "-", "-", 3)) + "'"
       cSql += "   AND SE1.D_E_L_E_T_ = ''   "

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RECEBER", .T., .T. )

       If T_RECEBER->( EOF() )
          _Cliente       := "******"
          _Loja	         := "***"
          _NomeCli       := "************************************************************"
          _ValorProtheus := 0
       Else
          _Cliente       := T_RECEBER->E1_CLIENTE
          _Loja	         := T_RECEBER->E1_LOJA
          _NomeCli       := T_RECEBER->E1_NOMCLI
          _ValorProtheus := T_RECEBER->E1_VALOR
       Endif      
   
       // ########################################
       // Pesquisa o banco para baixa do título ##
       // ########################################
       If Select("T_CONTABANCO") > 0
          T_CONTABANCO->( dbCloseArea() )
       EndIf
    
       cSql := "SELECT A6_COD    ,"
       cSql += "       A6_AGENCIA,"
       cSql += "	   A6_NUMCON
       cSql += "  FROM " + RetSqlName("SA6")
       cSql += " WHERE A6_NUMCON  = '" + Alltrim(aLista[nContar,24]) + "'"
       cSql += "   AND A6_COD     = '" + Alltrim(aLista[nContar,22]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
    
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTABANCO", .T., .T. )

       If T_CONTABANCO->( EOF() )
          _BancoTit  := "***"
          _AgenTit   := "**********"
          _ContaTit  := "********************"
       Else
          _BancoTit  := T_CONTABANCO->A6_COD
          _AgenTit   := T_CONTABANCO->A6_AGENCIA
          _ContaTit  := T_CONTABANCO->A6_NUMCON
       Endif   
   
       // ######################################
       // Pesquisa o banco para baixa da taxa ##
       // ######################################
       If Select("T_CONTABANCO") > 0
          T_CONTABANCO->( dbCloseArea() )
       EndIf
    
       cSql := "SELECT A6_COD    ,"
       cSql += "       A6_AGENCIA,"
       cSql += "	   A6_NUMCON
       cSql += "  FROM " + RetSqlName("SA6")
       cSql += " WHERE A6_NUMCON  = '" + Alltrim(aLista[nContar,04]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
    
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTABANCO", .T., .T. )

       If T_CONTABANCO->( EOF() )
          _BancoTax  := "***"
          _AgenTax   := "**********"
          _ContaTax  := "********************"
       Else
          _BancoTax  := T_CONTABANCO->A6_COD
          _AgenTax   := T_CONTABANCO->A6_AGENCIA
          _ContaTax  := T_CONTABANCO->A6_NUMCON
       Endif   
  
       // ##########################################################
       // Carrega o array aBaixar com os títulos a serem baixados ##
       // ##########################################################
       aAdd( aBaixar, { .T.                                                 ,;
                        U_P_CORTA(aLista[nContar,21] + "-", "-", 3)         ,;
                        U_P_CORTA(aLista[nContar,21] + "-", "-", 4)         ,;
                        aLista[nContar,12]                                  ,;
                        "NF"                                                ,;
                        _Cliente                                            ,;
                        _Loja	                                            ,;
                        _NomeCli                                            ,;
                        aLista[nContar,08]                                  ,;
                        Transform(val(Strtran(aLista[nContar,19],",",".")), "@E 9999999.99") ,;
                        _BancoTit                                           ,;
                        _AgenTit                                            ,;
                        _ContaTit                                           ,;
                        Transform(val(Strtran(aLista[nContar,17],",",".")) - val(Strtran(aLista[nContar,19],",",".")) , "@E 9999999.99"),;
                        _BancoTax                                           ,;
                        _AgenTax                                            ,;
                        _ContaTax                                           ,;
                        "BAIXA DE TÍTULO VIA CONCIL"                        ,;
                        aLista[nContar,03]                                  ,;
                        _ValorProtheus                                      ,;
                        Val(Strtran(aLista[nContar,19],",","."))            ,;
                        _ValorProtheus - Val(Strtran(aLista[nContar,19],",",".")) })

   Next nContar       

   If Len(aBaixar) == 0
      aAdd( aBaixar, { .F., "","","","","","","","","","","","","","","","","", "", "", "", "" })
   Endif

   DEFINE MSDIALOG oDlgBaixax TITLE "Confirmação de Baixa de Títulos - CONCIL" FROM C(178),C(181) TO C(534),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgBaixax

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlgBaixax

   @ C(037),C(005) Say "Relação de títulos que serão baixados no contas a receber" Size C(146),C(008) COLOR CLR_BLACK PIXEL OF oDlgBaixax

   @ C(162),C(005) Button "Marcar Todas"    Size C(049),C(012) PIXEL OF oDlgBaixax ACTION( MRCTITBXX(1) )
   @ C(162),C(055) Button "Desmarcar Todas" Size C(049),C(012) PIXEL OF oDlgBaixax ACTION( MRCTITBXX(0) )
   @ C(162),C(311) Button "Confirma"        Size C(037),C(012) PIXEL OF oDlgBaixax ACTION( ConfirmaBaixa() )
   @ C(162),C(350) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgBaixax ACTION( oDlgBaixax:End() )

   @ 057,005 LISTBOX oBaixar FIELDS HEADER "M"               ,; // 01  
                                           "Prefixo"         ,; // 02 
                                           "Nº Título"       ,; // 03
                                           "Nº Parcela"      ,; // 04
                                           "Tipo"            ,; // 05
                                           "Cliente"         ,; // 06
                                           "Loja"            ,; // 07
                                           "Nome do Cliente" ,; // 08
                                           "Data Pgtoº"      ,; // 09
                                           "Valor Título"    ,; // 10
                                           "Banco"           ,; // 11
                                           "Agência"         ,; // 12
                                           "C.Corrente"      ,; // 13
                                           "Valor Taxa"      ,; // 14
                                           "Banco"           ,; // 15
                                           "Agência"         ,; // 16
                                           "C.Corrente"      ,; // 17
                                           "Histórico"       ,; // 18
                                           "ID CONCIL"       ,; // 19
                                           "Valor Protheus"  ,; // 20
                                           "Valor CONCIL"    ,; // 21
                                           "Valor Taxa"       ; // 22
                                           PIXEL SIZE 490,147 OF oDlgBaixax ON dblClick(aBaixar[oBaixar:nAt,1] := !aBaixar[oBaixar:nAt,1],oBaixar:Refresh())     
   oBaixar:SetArray( aBaixar )

   oBaixar:bLine := {||{Iif(aBaixar[oBaixar:nAt,01],oOk,oNo),;
                            aBaixar[oBaixar:nAt,02]         ,;
                            aBaixar[oBaixar:nAt,03]         ,;
                            aBaixar[oBaixar:nAt,04]         ,;
                            aBaixar[oBaixar:nAt,05]         ,;
                            aBaixar[oBaixar:nAt,06]         ,;
                            aBaixar[oBaixar:nAt,07]         ,;
                            aBaixar[oBaixar:nAt,08]         ,;
                            aBaixar[oBaixar:nAt,09]         ,;
                            aBaixar[oBaixar:nAt,10]         ,;
                            aBaixar[oBaixar:nAt,11]         ,;
                            aBaixar[oBaixar:nAt,12]         ,;
                            aBaixar[oBaixar:nAt,13]         ,;
                            aBaixar[oBaixar:nAt,14]         ,;
                            aBaixar[oBaixar:nAt,15]         ,;
                            aBaixar[oBaixar:nAt,16]         ,;
                            aBaixar[oBaixar:nAt,17]         ,;
                            aBaixar[oBaixar:nAt,18]         ,;
                            aBaixar[oBaixar:nAt,19]         ,;
                            aBaixar[oBaixar:nAt,20]         ,;                            
                            aBaixar[oBaixar:nAt,21]         ,;
                            aBaixar[oBaixar:nAt,22]         }}

   ACTIVATE MSDIALOG oDlgBaixax CENTERED 
   
Return(.T.)   

// ###############################################
// Função que marca/desmarca títulos para baixa ##
// ###############################################
Static Function MRCTITBXX(kMarca)

   Local nMarcar := 0
                
   For nMarcar = 1 to Len(aBaixar)
   
       aBaixar[nMarcar,01] := IIF( kMarca == 1, .T., .F.)
       
   Next nMarcar
   
Return(.T.)       

// ###########################################
// Função que baixa os títulos selecionados ##
// ###########################################
Static Function ConfirmaBaixa()

   MsgRun("Aguarde! Baixando parcelas selecionadas ...", "Baixa de parcelas",{|| xConfirmaBaixa() })

Return(.T.)

// ###########################################
// Função que baixa os títulos selecionados ##
// ###########################################
Static Function xConfirmaBaixa()

   Local nReceber    := 0   
   Local aInformacao := {}
   Local lErroPar    := .F.
   Local lErroTax    := .F.
   Local kkLegenda   := ""

   aResumo := {}

   For nReceber = 1 to Len(aBaixar)

       If aBaixar[nReceber,01] == .F.
          Loop
       Endif

       If aBaixar[nReceber,02] == "5"
          Loop
       Endif

       If aBaixar[nReceber,02] == "8"
          Loop
       Endif

       lErroPar  := .F.
       lErroTax  := .F.
       kkLegenda := ""  

       // ####################
       // Prepara a parcela ##
       // ####################
       If aBaixar[nReceber,04] == "01/01"
          kParcela := "  "
       Else
          kParcela := Substr(aBaixar[nReceber,04],01,02)
       Endif   

       // ##################################
       // Prepara os campos para gravação ##
       // ##################################
       yPrefixo  := Alltrim(aBaixar[nReceber,02]) + Space(3 - Len(Alltrim(aBaixar[nReceber,02])))
       yNumero   := Alltrim(aBaixar[nReceber,03]) + Space(9 - Len(Alltrim(aBaixar[nReceber,03])))
//       yValorTit := VAL(StrTran(aBaixar[nReceber,10], ",", "."))
//       yValorTax := VAL(StrTran(aBaixar[nReceber,14], ",", "."))

       yValorTit := aBaixar[nReceber,21]
       yValorTax := aBaixar[nReceber,22]


       // #######################################
       // Realiza a baixa do capital do título ##
       // #######################################
       aInformacao := {{"E1_PREFIXO"  , yPrefixo                                  , Nil    },;
                       {"E1_NUM"      , yNumero                                   , Nil    },;
                       {"E1_PARCELA"  , kParcela                                  , Nil    },;
                       {"E1_TIPO"     , aBaixar[nReceber,05]                      , Nil    },;
                       {"AUTMOTBX"    , "NOR"                                     , Nil    },;
                       {"AUTBANCO"    , STRZERO(INT(VAL(aBaixar[nReceber,11])),03), Nil    },;
                       {"AUTAGENCIA"  , aBaixar[nReceber,12]                      , Nil    },;
                       {"AUTCONTA"    , aBaixar[nReceber,13]                      , Nil    },;
                       {"AUTDTBAIXA"  , Ctod(aBaixar[nReceber,09])                , Nil    },;
                       {"AUTDTCREDITO", Ctod(aBaixar[nReceber,09])                , Nil    },;
                       {"AUTHIST"     , "BAIXA CARTAO"                            , Nil    },;
                       {"AUTJUROS"    , 0                                         , Nil,.T.},;
                       {"AUTVALREC"   , yValorTit                                 , Nil    }}

       lMsErroAuto := .F.

       MSExecAuto({|x,y| Fina070(x,y)}, aInformacao,3) 
 
       IF lMsErroAuto
          lErroPar := .T.
	      //MostraErro()
       Else
          lErroPar := .F.
       Endif       

       // ####################################
       // Realiza a baixa da taxa do cartão ##
       // ####################################
       aValTaxa    := {{"E1_PREFIXO"  , yPrefixo                                  , Nil    },;
                       {"E1_NUM"      , yNumero                                   , Nil    },;
                       {"E1_PARCELA"  , kParcela                                  , Nil    },;
                       {"E1_TIPO"     , aBaixar[nReceber,05]                      , Nil    },;
                       {"AUTMOTBX"    , "NOR"                                     , Nil    },;
                       {"AUTBANCO"    , aBaixar[nReceber,15]                      , Nil    },;
                       {"AUTAGENCIA"  , aBaixar[nReceber,16]                      , Nil    },;
                       {"AUTCONTA"    , aBaixar[nReceber,17]                      , Nil    },;
                       {"AUTDTBAIXA"  , Ctod(aBaixar[nReceber,09])                , Nil    },;
                       {"AUTDTCREDITO", Ctod(aBaixar[nReceber,09])                , Nil    },;
                       {"AUTHIST"     , "BAIXA CARTAO"                            , Nil    },;
                       {"AUTJUROS"    , 0                                         , Nil,.T.},;
                       {"AUTVALREC"   , yValorTax                                 , Nil    }}

       lMsErroAuto := .F.
       
       MSExecAuto({|x,y| Fina070(x,y)}, aValTaxa,3) 
 
       IF lMsErroAuto
          lErroTax := .T.
	      //MostraErro()
       Else
          lErroTax := .F.
       Endif       

       // ###################################
       // Altera a legenda do array aLista ##
       // ###################################
       For nTrocaLeg = 1 to Len(aLista)
           If Alltrim(aLista[nTrocaLeg,03]) == Alltrim(aBaixar[nReceber,19])
              Do Case
                 Case lErroPar == .F. .And. lErrotax == .F.
                      aLista[nTrocaLeg,02] := "8"
                      kkLegenda := "8"
                      
                 Case lErroPar == .T. .And. lErrotax == .F.
                      aLista[nTrocaLeg,02] := "7"
                      kkLegenda := "7"

                 Case lErroPar == .F. .And. lErrotax == .T.
                      aLista[nTrocaLeg,02] := "7"
                      kkLegenda := "7"
                      
                 Case lErroPar == .T. .And. lErrotax == .T.
                      aLista[nTrocaLeg,02] := "7"
                      kkLegenda := "7"
                      
              EndCase
              Exit
           Endif
       Next nTrocaLeg       

       // ##########################
       // Carrega o array aResumo ##
       // ##########################
       aAdd( aResumo, { kkLegenda, yPrefixo, yNumero, kparcela, yValorTit, IIF(lErroPar == .T., "ERRO", "OK"), yValorTax, IIF(lErroTax == .T., "ERRO", "OK") })

   Next nReceber

   oDlgBaixax:End() 
   
Return(.T.)

// ##################################################################
// Função que abre a janela para visualizar o resultado das baixas ##
// ##################################################################
Static Function ResultadoBx()

   Local cMemo1	 := ""
   Local oMemo1
   Local nContar := 0

   Private oDlgResumo

   If Len(aResumo) == 0
      aAdd( aResumo, { '1', "", "", "", "", "", "", "" })
   Endif

   DEFINE MSDIALOG oDlgResumo TITLE "Resumo de Baixa de Títulos - CONCIL" FROM C(178),C(181) TO C(534),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgResumo

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlgResumo

   @ C(037),C(005) Say "Resumo das baixas de títulos" Size C(146),C(008) COLOR CLR_BLACK PIXEL OF oDlgResumo

   @ C(162),C(005) Button "Excel"           Size C(037),C(012) PIXEL OF oDlgResumo ACTION( GeraExcel() )
   @ C(162),C(350) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgResumo ACTION( oDlgResumo:End() )
   
   @ 057,005 LISTBOX oResumo FIELDS HEADER "LG"              ,; // 01  
                                           "Prefixo"         ,; // 02 
                                           "Nº Título"       ,; // 03
                                           "Nº Parcela"      ,; // 04
                                           "Valor Parcela"   ,; // 05
                                           "Status da Baixa" ,; // 06
                                           "Valor da Taxa"   ,; // 07
                                           "Status da Baixa"  ; // 08
                                           PIXEL SIZE 490,147 OF oDlgResumo ON dblClick(aBaixar[oBaixar:nAt,1] := !aBaixar[oBaixar:nAt,1],oBaixar:Refresh())     
   oResumo:SetArray( aResumo )

   oResumo:bLine := {||{If(Alltrim(aResumo[oResumo:nAt,01]) == "1", oBranco  ,;
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "2", oVerde   ,;
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "3", oPink    ,;                         
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "4", oAmarelo ,;                         
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "5", oAzul    ,;                         
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "6", oLaranja ,;                         
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "7", oPreto   ,;                         
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "8", oVermelho,;
                        If(Alltrim(aResumo[oResumo:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                           aResumo[oResumo:nAt,02]         ,;
                           aResumo[oResumo:nAt,03]         ,;
                           aResumo[oResumo:nAt,04]         ,;
                           aResumo[oResumo:nAt,05]         ,;
                           aResumo[oResumo:nAt,06]         ,;
                           aResumo[oResumo:nAt,07]         ,;
                           aResumo[oResumo:nAt,08]         }}

   ACTIVATE MSDIALOG oDlgResumo CENTERED 
   
Return(.T.)   



// #######################################
// Função que gera o resultado em Excel ##
// #######################################
Static Function GeraExcel()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   aAdd( aCabExcel, { "Prefixo"         , "C", 03, 00 })
   aAdd( aCabExcel, { "Nº Título"       , "C", 09, 00 })
   aAdd( aCabExcel, { "Nº Parcela"      , "C", 02, 00 })
   aAdd( aCabExcel, { "Valor Parcela"   , "N", 10, 02 })
   aAdd( aCabExcel, { "Status da Baixa" , "C", 20, 00 })
   aAdd( aCabExcel, { "Valor da Taxa"   , "N", 10, 02 })
   aAdd( aCabExcel, { "Status da Baixa" , "C", 20, 00 })
   
   MsgRun("Aguarde! Preparando Dados ..."     , "Selecionando os Registros", {|| kkSaidaExcel(aCabExcel, @aItensExcel)})
   MsgRun("Aguarde! Gerando Arquivo Excel ...", "Exportando Resumo para Excel", {||DlgToExcel({{"GETDADOS","Resumo das baixas CONCIL", aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kkSaidaExcel(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aResumo)

       aAdd( aCols, { aResumo[nContar,02] ,;
                      aResumo[nContar,03] ,;
                      aResumo[nContar,04] ,;
                      aResumo[nContar,05] ,;
                      aResumo[nContar,06] ,;
                      aResumo[nContar,07] ,;
                      aResumo[nContar,08] ,;                      
                      ""                  })

   Next nContar

Return(.T.)