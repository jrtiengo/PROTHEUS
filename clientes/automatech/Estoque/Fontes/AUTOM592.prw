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
// Referencia: AUTOM592.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 06/07/2017                                                          ##
// Objetivo..: Programa importador de números de séries da TERCA                   ##
// Parãmetros: Sem Parâmetros                                                      ##
// ##################################################################################

User Function AUTOM592()

   Local lChumba  := .F.
   Local cMemo1	  := ""
   Local oMemo1
      
   Private cCaminho := Space(250)
   Private oGet1

   Private oDlg

   Private aBrowse   := {}
   Private aSeries   := {}
   Private aLista    := {}
   Private oLista

   Private kk_Nota   := ""
   Private kk_Serie  := ""

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   U_AUTOM628("AUTOM592")

   DEFINE MSDIALOG oDlg TITLE "Endereçamento de Nº de Séries TERCA" FROM C(178),C(181) TO C(619),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg
   @ C(206),C(245) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(206),C(290) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Arquivo a ser aberto"                 Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Conteúdo do arquivo aberto"           Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(301) Say "Nº de Séries do registro selecionado" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(258) Say "A Endereçar"                          Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(304) Say "Já Endereçado"                        Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(003) MsGet oGet1 Var cCaminho Size C(234),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(044),C(241) Button "..."                       Size C(016),C(009) PIXEL OF oDlg ACTION( PESQTERCA() )
   @ C(044),C(261) Button "Abrir"                     Size C(037),C(009) PIXEL OF oDlg ACTION( ImpNSBrowse() )
   @ C(044),C(301) Button "Nº de Séries"              Size C(087),C(009) PIXEL OF oDlg ACTION( VeNSeries() ) When !Empty(Alltrim(aLista[01,03]))
   @ C(204),C(005) Button "Marca Todos"               Size C(050),C(012) PIXEL OF oDlg ACTION( MrcNSeries(1) ) When !Empty(Alltrim(aLista[01,03]))
   @ C(204),C(056) Button "Desmarca Todos"            Size C(050),C(012) PIXEL OF oDlg ACTION( MrcNSeries(0) ) When !Empty(Alltrim(aLista[01,03]))
   @ C(204),C(112) Button "Endereçar"                 Size C(050),C(012) PIXEL OF oDlg ACTION( EnderecaNS() )
   @ C(204),C(166) Button "Endereçamento de Produtos" Size C(076),C(012) PIXEL OF oDlg ACTION( MATA265() )
   @ C(204),C(356) Button "Voltar"                    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // #################
   // Desenha aLista ##
   // #################
   aAdd( aLista, { .F., "2", "", "", "" } )

   @ 080,005 LISTBOX oLista FIELDS HEADER "M"                      ,; // 01  
                                          "LG"                     ,; // 02 
                                          "Produto"                ,; // 03
                                          "Descrição dos Produtos" ,; // 04
                                          "Qtd Nºs de Séries"       ; // 05
                                          PIXEL SIZE 375,178 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
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
                           aLista[oLista:nAt,05]         }}

   // ###################
   // Desenha o Browse ##
   // ###################
   aAdd( aBrowse, { "" } )

   oBrowse := TCBrowse():New( 080 , 385, 115, 178,,{'Arquivos' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################################
// Função que abre diálogo de pesquisa dos arquivos a serem lidos ##
// #################################################################
Static Function PESQTERCA()

   cCaminho := cGetFile('*.csv', "Selecione o Arquivo de Nº de Séries",1,"C:\",.F.,16,.F.)

Return .T. 

// ############################################################
// Função que mostra os nº de séries do registro selecionado ##
// ############################################################
Static Function VENSERIES()

   Local nContar := 0
   
   aBrowse := {}
   
   For nContar = 1 to Len(aSeries)
       If Upper(Alltrim(aSeries[nContar,03])) == Upper(Alltrim(aLista[oLista:nAt,03]))
          aAdd( aBrowse, { aSeries[nContar,05] } )
       Endif
   Next nContar        
      
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]} }

Return(.T.)

// #########################################
// Função que marca/desmarca os registros ##
// #########################################
Static Function MrcNSeries(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       If kTipo == 1
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.                
       Endif         
   Next nContar
   
Return(.T.)       

// ######################################################
// Função que importa o arquivo selecionado na aBrowse ##
// ######################################################
Static Function ImpNSBrowse()

   MsgRun("Aguarde! Importando dados do arquivo selecionado ...", "Importação TERCA",{|| xImpNSBrowse() })

Return(.T.)

// ######################################################
// Função que importa o arquivo selecionado na aBrowse ##
// ######################################################
Static Function xImpNSBrowse()

   Local nContar   := 0
   Local nPercorre := 0
   Local nLimpa    := 0
   Local lMarcadas := .F.
   Local cAgravar  := ""
   Local cConteudo := ""
   Local aCarga    := {}  
   Local aTempo    := {}
   Local nProcura  := 0
   Local lJaEsta   := .F.       
   
   // ################################################
   // Limpa o array aLimpa para receber novos dados ##
   // ################################################
   aLista := {}
   aTotal := {}

   // ########################################
   // Abre o arquivo selecionado na aBrowse ##
   // ########################################
   nHandle := FOPEN(Alltrim(cCaminho) + Alltrim(aBrowse[oBrowse:nAt,01]), FO_READWRITE + FO_SHARED)
     
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

       If Substr(xBuffer, nPercorre, 1) <> CHR(10)
          cConteudo := cConteudo + Substr(xBuffer, nPercorre, 1)
       Else
          cConteudo := cConteudo + ";"
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
   kInicio  := .F.
   kk_Nota  := ""
   kk_Serie := ""

   For nContar = 1 to Len(aCarga)

//       If (Alltrim(U_P_CORTA(aCarga[nContar,01], ";", 1)) = "CODIGO EMPRESA")) .And.;
//          (Alltrim(U_P_CORTA(aCarga[nContar,01], ";", 1) = "CODIGO"))
//          Loop
//       Endif

       If U_P_OCCURS(aCarga[nContar,01], "CODIGO", 1) <> 0
          Loop
       Endif

       aAdd( aSeries , { .F.                                              ,;
                         "2"                                              ,;
                         U_P_CORTA(aCarga[nContar,01], ";", 5) + Space(30),;
                         U_P_CORTA(aCarga[nContar,01], ";", 6) + Space(60),;                           
                         U_P_CORTA(aCarga[nContar,01], ";", 7)})

       // ###################################################################################
       // Verifica se o produto já está contido no array aLista. Se não estiver, o inclui. ##
       // ###################################################################################
       lJaEsta := .F.
       For nLocaliza = 1 to Len(aLista)
           If Upper(Alltrim(aLista[nLocaliza,03])) == Upper(Alltrim(U_P_CORTA(aCarga[nContar,01], ";", 5)))
              lJaEsta := .T.
              Exit
           Endif
       Next nLocaliza
       
       If lJaEsta == .T.
          aLista[nLocaliza,05] := aLista[nLocaliza,05] + 1       
       Else
          kk_Nota  := U_P_CORTA(aCarga[nContar,01], ";", 3)
          kk_Serie := U_P_CORTA(aCarga[nContar,01], ";", 4)
          aAdd( aLista , { .F.                                             ,;
                          "2"                                              ,;
                          U_P_CORTA(aCarga[nContar,01], ";", 5) + Space(30),;
                          U_P_CORTA(aCarga[nContar,01], ";", 6) + Space(60),;                           
                          1                                                })
       Endif

   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { .F., "2", "", "", "" })
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
                           aLista[oLista:nAt,05]         }}

   // ###################################################################### 
   // Envia para a função que mostra os nºs de séries do primeiro produto ##
   // ######################################################################
   If Empty(Alltrim(aLista[01,03]))
   Else
      VENSERIES()
   Endif   

Return(.T.)

// #######################################################
// Função que realiza o endereçamento dos nºs de séries ##
// #######################################################
Static Function EnderecaNS()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local nContar  := 0
   Local lMarcado := .F.

   Private cNFAuto	 := kk_Nota
   Private cSRAuto	 := kk_Serie
   Private cNFForn	 := Space(09)
   Private cSRForn 	 := Space(03)
   Private cCodFor	 := Space(06)
   Private cLojFor	 := Space(03)
   Private cNomeFo	 := Space(60)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlgEnder

   // ###################################################################
   // Verifica se houve pelo menos um registro marcado no array aLista ##
   // ###################################################################
   lMarcados := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcados := .T. 
          Exit
       Endif
   Next nContar
   
   If lMarcados == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum nº de série foi marcado para ser endereçado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // ####################################################################################################
   // Desenha a tela para solicitar o nº da nota fiscal do fornecedor para importação dos Nºs de Séries ##
   // ####################################################################################################
   DEFINE MSDIALOG oDlgEnder TITLE "Endereçamento Nº Série" FROM C(178),C(181) TO C(426),C(554) PIXEL

   @ C(001),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(024) PIXEL NOBORDER OF oDlgEnder

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(179),C(001) PIXEL OF oDlgEnder
   @ C(101),C(002) GET oMemo2 Var cMemo2 MEMO Size C(179),C(001) PIXEL OF oDlgEnder
   
   @ C(033),C(005) Say "Importação ref a NF/Série Automatech" Size C(102),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnder
   @ C(056),C(005) Say "Nº NF/Série Fornecedor"               Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnder
   @ C(078),C(005) Say "Fornecedor/Loja"                      Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnder
      
   @ C(043),C(005) MsGet oGet1 Var cNFAuto Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder When lChumba
   @ C(043),C(041) MsGet oGet2 Var cSRAuto Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder When lChumba
   @ C(066),C(005) MsGet oGet3 Var cNFForn Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder
   @ C(066),C(041) MsGet oGet4 Var cSRForn Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder
   @ C(087),C(005) MsGet oGet5 Var cCodFor Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder F3("SA2")
   @ C(087),C(041) MsGet oGet6 Var cLojFor Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder VALID( CCppFF() )
   @ C(087),C(060) MsGet oGet7 Var cNomeFo Size C(119),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder When lChumba

   @ C(106),C(053) Button "Endereçar" Size C(037),C(012) PIXEL OF oDlgEnder ACTION( xxEnderecaNS() )
   @ C(106),C(092) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgEnder ACTION( oDlgEnder:End() )

   ACTIVATE MSDIALOG oDlgEnder CENTERED 

Return(.T.)

// #####################################################
// Função que pesquisa o nome do fornecedor informado ##
// #####################################################
Static Function CCppFF()

   If Empty(Alltrim(cCodFor))
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cLojFor))
      Return(.T.)
   Endif

   cNomeFo := POSICIONE("SA2",1,XFILIAL("SA2") + cCodFor + cLojFor, "A2_NOME")
   
   If Empty(Alltrim(cNomeFo))
      cCodFor := Space(06)
      cLojFor := Space(03)
      cNomeFo := Space(60)
      oGet5:Refresh() 
      oGet6:Refresh() 
      oGet7:Refresh()       
      MsgAlert("Fornecedor informado não cadastrado. Verifique!")
      Return(.T.)
   Endif
      
Return(.T.)

// ###########################################
// Realiza o endereçamento dos nº de séries ##
// ###########################################
Static Function xxEnderecaNS()

   If Empty(Alltrim(cNFForn))
      MsgAlert("Nº da nota fiscal do fornecedor não informada. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cSRForn))
      MsgAlert("Nº de Série da nota fiscal do fornecedor não informada. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCodFor)) .OR. Empty(Alltrim(cLojFor))
      MsgAlert("Necessário informar o Fornecedor. Verifique!")
      Return(.T.)
   Endif

   // ######################################################
   // Início do processo de endereçamento de nº de séries ##
   // ######################################################
   For nContar = 1 to Len(aLista)
   
       // ################################################
       // Se registro não estiver marcado, lê o próximo ##
       // ################################################
       If aLista[nContar,01] == .F.
          Loop
       Endif
       
       // #########################################################################################
       // Verirfica se existe endereçamento pendente para a Nota Fical/Série/Produto selecionado ##
       // #########################################################################################
       If Select("T_PENDENTE") > 0
          T_PENDENTE->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT DA_FILIAL ,"
       cSql += "       DA_PRODUTO," 
	   cSql += "       DA_QTDORI ,"
	   cSql += "       DA_SALDO  ,"
	   cSql += "       DA_DATA   ,"
	   cSql += "       DA_LOCAL  ,"
	   cSql += "       DA_DOC    ,"
	   cSql += "       DA_SERIE  ,"
	   cSql += "       DA_CLIFOR ,"
	   cSql += "       DA_LOJA   ,"
	   cSql += "       DA_TIPONF ,"
	   cSql += "       DA_NUMSEQ ,"
	   cSql += "       DA_ORIGEM  "
       cSql += "  FROM " + RetSqlName("SDA")
       cSql += " WHERE DA_FILIAL  = '" + Alltrim(cFilAnt) + "'"
       cSql += "   AND DA_DOC     = '" + Alltrim(cNFForn) + "'"
       cSql += "   AND DA_SERIE   = '" + Alltrim(cSRForn) + "'"
       cSql += "   AND DA_CLIFOR  = '" + Alltrim(cCodFor) + "'"
       cSql += "   AND DA_LOJA    = '" + Alltrim(cLojFor) + "'"
       cSql += "   AND DA_PRODUTO = '" + Alltrim(Strzero(Int(Val(aLista[nContar,03])),6)) + "'"
       cSql += "   AND DA_QTDORI  = DA_SALDO"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PENDENTE", .T., .T. )
       
       If T_PENDENTE->( EOF() )
          MsgAlert("Atenção!"                                                        + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Não existe pendencia de endereçamento para o produto "           + chr(13) + chr(10)                     + ;
                   Alltrim(aLista[nContar,03]) + " - " + Alltrim(aLista[nContar,04]) + chr(13) + chr(10)                     + ;
                   "ou produto já foi endereçado."                                   + chr(13) + chr(10)                     + ;
                   "Verifique a informação do nº da nota fiscal/ série do fornecedor se estão corretas.")
          Return(.T.)
       Endif
                             
       // ######################################################
       // Lança dos Endereçamentos para o produto selecionado ##
       // ######################################################

       nSeqItem := 0       

       For nEndereco = 1 to Len(aSeries)

           If Upper(Alltrim(Strzero(Int(Val(aSeries[nEndereco,03])),6))) == Upper(Alltrim(Strzero(Int(Val(aLista[nContar,03])),6)))
           
              nSeqItem += 1

     		  DbSelectArea("SDB")
		      Reclock("SDB",.T.)
              SDB->DB_FILIAL  := T_PENDENTE->DA_FILIAL
              SDB->DB_ITEM    := Strzero(nSeqItem,4)
              SDB->DB_PRODUTO := Strzero(Int(Val(aLista[nContar,03])),6) + Space(24)
              SDB->DB_LOCAL   := T_PENDENTE->DA_LOCAL
              SDB->DB_LOCALIZ := "GENERICO"
              SDB->DB_DOC     := T_PENDENTE->DA_DOC
              SDB->DB_SERIE   := T_PENDENTE->DA_SERIE
              SDB->DB_CLIFOR  := T_PENDENTE->DA_CLIFOR
              SDB->DB_LOJA    := T_PENDENTE->DA_LOJA
              SDB->DB_TIPONF  := T_PENDENTE->DA_TIPONF
              SDB->DB_TM      := "499"
              SDB->DB_ORIGEM  := T_PENDENTE->DA_ORIGEM
              SDB->DB_QUANT   := 1
              SDB->DB_DATA    := DATE()
              SDB->DB_NUMSERI := aSeries[nEndereco,05]
              SDB->DB_NUMSEQ  := T_PENDENTE->DA_NUMSEQ
              SDB->DB_TIPO    := "D"
              SDB->DB_SERVIC  := "499"
              SDB->DB_ATIVID  := "ZZZ"
              SDB->DB_HRINI   := TIME()
              SDB->DB_ATUEST  := "S"
              SDB->DB_STATUS  := "M"
              SDB->DB_ORDATIV := "ZZ"
     		  MsUnlock()

     		  DbSelectArea("SBF")
		      Reclock("SBF",.T.)
		      SBF->BF_FILIAL  := T_PENDENTE->DA_FILIAL
		      SBF->BF_PRODUTO := Strzero(Int(Val(aLista[nContar,03])),6) + Space(24)
		      SBF->BF_LOCAL   := T_PENDENTE->DA_LOCAL
		      SBF->BF_LOCALIZ := "GENERICO" 
		      SBF->BF_NUMSERI := aSeries[nEndereco,05] 
		      SBF->BF_QUANT   := 1 
     		  MsUnlock()
     		  
           Endif

       Next nEndereco

       // #####################################################
       // Zera o saldo para não precisar endereçar novamente ##
       // #####################################################
       dbSelectArea("SDA")
	   dbSetOrder(1)
	   If DbSeek(T_PENDENTE->DA_FILIAL + T_PENDENTE->DA_PRODUTO + T_PENDENTE->DA_LOCAL + T_PENDENTE->DA_NUMSEQ + T_PENDENTE->DA_DOC + T_PENDENTE->DA_SERIE + T_PENDENTE->DA_CLIFOR + T_PENDENTE->DA_LOJA)
          Reclock("SDA",.F.)
          SDA->DA_SALDO := 0
   		  MsUnlock()          
   	   Endif

       // #######################################################
       // Subtrai do campo B2_QACLASS (Quantidade a Endereçar) ##
       // #######################################################
       dbSelectArea("SB2")
	   dbSetOrder(1)
	   If DbSeek(T_PENDENTE->DA_FILIAL + T_PENDENTE->DA_PRODUTO + T_PENDENTE->DA_LOCAL)
          Reclock("SB2",.F.)
          SB2->B2_QACLASS := SB2->B2_QACLASS - aLista[nContar,05]
   		  MsUnlock()          
   	   Endif


       // #################################
       // Altera o Status para importado ##
       // #################################
       aLista[nContar,02] := "8"       

   Next nContar        

   MsgAlert("Importação realizada com sucesso.")
   
   oDlgEnder:End() 

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
                           aLista[oLista:nAt,05]         }}
   
Return(.T.)

// ###########################
// Layout do Arquivo TERCA  ##
// ###########################
// 1º Layout da TERCA       ##
//                          ##
// 1 - Código Empresa       ##
// 2 - Código Produto       ##
// 3 - Descrição Produto    ##
// 4 - Número Série         ##
// 5 - Classe               ##
// 6 - NF Remessa           ##
// 7 - Serie                ##
//                          ##
// 2º Layout da TERCA       ##
//                          ##
// 1 - Codigo Empresa       ##
// 2 - Depositante          ##
// 3 - Documento            ##
// 4 - Serie                ##
// 5 - Código produto       ##
// 6 - Série                ##
// 7 - Número Série         ##
// 8 - Status               ##
// ###########################

