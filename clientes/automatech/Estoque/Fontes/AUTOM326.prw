#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM326.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                    ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 10/12/2015                                                          ##
// Objetivo..: Programa genérico que permite que seja lido um arquivo  sequencial  ##
//             (TXT) em  um formato determinado com o objetivo de  poder realizar  ##
//             baixas ou entradas de estoque de mercadorias utilizando o processo  ##
//             automático de Movimentação Interna (2). O layout está definido  na  ##
//             ação do botão LAYOUT.                                               ##
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: .T.                                                                 ##
// ##################################################################################

User Function AUTOM326()

   MsgRun("Aguarde! Abrindo Movimentações Estoque Automáticas ...", "PROGRAMA: AUTOM326",{|| xAUTOM326() })

Return(.T.)

Static Function xAUTOM326()

   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local cMinternos := ""
   Local cMemo2	    := ""
   Local oMemo1
   Local oMemo2

   Private cPlanilha := Space(250)
   Private cCaminho  := Space(250)
   Private cEmissao  := Date()
   Private cArqLog   := Space(60)

   Private oGet1
   Private oGet2
   Private oGet3   
   Private oGet4   

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   Private oDlg

   Private aLista := {}
   Private oLista

   // ###########################
   // Parâmetros de Importação ##
   // ###########################
   Private pProduto    := 0
   Private pSerie      := 0
   Private pQuantidade := 0
   Private pArmazem    := "01"
   Private pCabecalho  := ""
   Private lProduto    := .T.
   Private lSerie      := .F.
   Private lQuantidade := .T.
   Private lArmazem    := .T.
   Private pTipoLanc   := "T"
   Private pZerados    := "N"

   Private lTipoArq    := 0

   U_AUTOM628("AUTOM326")

   // ##########################################################################
   // Verifica se usuário logado possui permissão para executar este programa ##
   // ##########################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_MINT FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cMinternos := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_MINT)

   If Empty(Alltrim(cMinternos))
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif
   
   If U_P_OCCURS(Alltrim(Upper(cMinternos)), Alltrim(Upper(cUserName)), 1) == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif

   // #################################
   // Desenha a tela de visualização ##
   // #################################
   DEFINE MSDIALOG oDlg TITLE "Ajustes Genérico de Estoque" FROM C(178),C(181) TO C(616),C(967) PIXEL
  
   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg
                                   
   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(381),C(001) PIXEL OF oDlg
   @ C(199),C(003) GET oMemo2 Var cMemo2 MEMO Size C(381),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Arquivo TXT a ser utilizado para leitura dos produtos" Size C(127),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Produtos do arquivo carregado"                         Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(005) Say "Arquivo de LOG do Ajuste deverá ser gravado em:"       Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(240) Say "Nome Arquivo de Log"                                   Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(344) Say "Data Movimentação"                                     Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) MsGet  oGet1 Var cPlanilha Size C(322),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(044),C(330) Button "..."               Size C(013),C(009)                              PIXEL OF oDlg ACTION( PESQPLANILHA() )
   @ C(041),C(347) Button "Carregar"          Size C(037),C(012)                              PIXEL OF oDlg ACTION( CARGAPLANILHA() )
   @ C(186),C(005) MsGet  oGet2 Var cCaminho  Size C(210),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(186),C(222) Button "..."               Size C(013),C(009)                              PIXEL OF oDlg ACTION( SalvaCaminho() )
   @ C(186),C(240) MsGet  oGet4 Var cArqLog   Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(186),C(344) MsGet  oGet3 Var cEmissao  Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(203),C(005) Button "Marca Todos"     Size C(051),C(012) PIXEL OF oDlg ACTION( MRCTODREG(1) )
   @ C(203),C(057) Button "Desmarca Todos"  Size C(051),C(012) PIXEL OF oDlg ACTION( MRCTODREG(2) )
   @ C(203),C(222) Button "Parâmetros Imp." Size C(052),C(012) PIXEL OF oDlg ACTION( MstLayout() )
   @ C(203),C(286) Button "Ajustar"         Size C(050),C(012) PIXEL OF oDlg ACTION( AcaoMovimentar() )
   @ C(203),C(347) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "", "", "", "", "", "", "", "" } )

   // ############################################### 
   // Lista com os produtos do arquivo selecionado ##
   // ###############################################
   @ 085,006 LISTBOX oLista FIELDS HEADER "M", "Empresa", "Filial", "Código", "Descrição dos Produtos", "Ação", "Nº de Série", "Armazém", "Quantidade" PIXEL SIZE 488,135 OF oDlg ;
             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
           					    aLista[oLista:nAt,03],;
           					    aLista[oLista:nAt,04],;
          					    aLista[oLista:nAt,05],;
          					    aLista[oLista:nAt,06],;
          					    aLista[oLista:nAt,07],;
          					    aLista[oLista:nAt,08],;
          					    aLista[oLista:nAt,09]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################################################
// Função que abre diálogo para selecionar o caminho de gravação do arquivo de log de ajuste de estoque ##
// #######################################################################################################
Static Function SalvaCaminho()

   cCaminho := cGetFile( "Arquivos", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )

Return(.T.)

// ############################################################
// Função que marca/desmarca os registros para processamento ##
// ############################################################
Static Function MRCTODREG(_TipoBotao)
                                    
   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       If _TipoBotao == 1
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.          
       Endif
   Next nContar
   
Return(.T.)          

// ############################################################################
// Função que abre diálogo de pesquisa o arquivo a ser importado para ajuste ##
// ############################################################################
Static Function PESQPLANILHA()

   cPlanilha := cGetFile('*.txt', "Selecione o Arquivo a ser utilizado",1,"C:\",.F.,16,.F.)

Return .T. 

// #################################################################
// Função que carrega para a lista o conteúdo do arquivo indicado ##
// #################################################################
Static Function CARGAPLANILHA()
                             
   If pProduto == 0 .And. pSerie == 0 .And. pQuantidade == 0
      MsgAlert("Atenção!"                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Parametrização de importação não informada.")
      Return(.T.)
   Endif         

   If Empty(Alltrim(cPlanilha))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo a ser utilizado para carga não informado. Informe o arquivo a ser processado.")
      Return(.T.)
   Endif

   Do Case
      Case U_P_OCCURS(Alltrim(Upper(cPlanilha)), ".CSV", 1) <> 0
           lTipoArq := 1
      Case U_P_OCCURS(Alltrim(Upper(cPlanilha)), ".TXT", 1) <> 0   
           lTipoArq := 2
      OtherWise
           lTipoArq := 0     
   EndCase

   If lTipoArq == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Tipo de Arquivo a ser utilizado é inválido." + chr(13) + chr(10) + "Aceitos (CSV ou TXT).")
      Return(.T.)
   Endif

   MsgRun("Favor Aguarde! Carregando dados do arquivo selecionado ...", "Selecionando Registros",{|| CRGPLANILHA() })      

Return(.T.)

// #################################################################
// Função que carrega para a lista o conteúdo do arquivo indicado ##
// #################################################################
Static Function CRGPLANILHA()

   Local aBrowse := {}
   Local nContar := 0

   // ####################################################
   // Abre o arquivo selecionado para pesquisa de dados ##
   // ####################################################
   nHandle := FOPEN(Alltrim(cPlanilha), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
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

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)

          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)

       Else

          Do Case
             Case lTipoArq == 1
                  cAgravar := StrTran(StrTran(cConteudo, ";"   , "|"), chr(10), "") + "|"
             Case lTipoArq == 2
                  cAgravar := StrTran(StrTran(cConteudo, chr(9), "|"), chr(10), "") + "|"
          EndCase

          aAdd(aBrowse, { cAgravar } )
          cConteudo := ""

       Endif

   Next nContar    

   // ####################################################
   // Alimenta a Lista aLista com o resultado capturado ##
   // ####################################################
   aLista := {}

   For nContar = 1 to Len(aBrowse)

       // ###################
       // Separa os campos ##
       // ###################
       kEmpresa    := cEmpAnt
       kFilial     := cFilAnt

       If lProduto == .T. 

          If Len(U_P_CORTA(aBrowse[nContar,1], "|", pProduto)) <= 6
             kNumero := Strzero(INT(VAL(U_P_CORTA(aBrowse[nContar,1], "|", pProduto))),6)
          Else   
             kNumero := U_P_CORTA(aBrowse[nContar,1], "|", pProduto)
          Endif   

          kCodigo := kNumero + Space(30 - Len(kNumero))

       Endif
          
       kNomePro := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kCodigo, "B1_DESC")) + " " + ;
                   Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kCodigo, "B1_DAUX"))

       If lSerie == .T.
          kSerie := U_P_CORTA(aBrowse[nContar,1], "|", pSerie)
       Else
          kSerie := ""
       Endif   
       
       If lQuantidade == .T.   
          kQuantidade := VAL(U_P_CORTA(Strtran(aBrowse[nContar,1], ",", "."), "|", pQuantidade))          
       Endif   
            
       If lArmazem == .T.   
          kArmazem    := Alltrim(pArmazem)
       Endif   

       If kQuantidade >=0 
          kAcao := "E"
       Else
          kAcao := "S"
       Endif   

       // ################################################################################
       // Seleciona o tipo de registro em relação a Entradas/ Saídas conforme parâmetro ##
       // ################################################################################
       Do Case
          Case pTipoLanc == "E"
               If kAcao == "E"
               Else
                  Loop
               Endif
          Case pTipoLanc == "S"
               If kAcao == "S"
               Else
                  Loop
               Endif
       EndCase               

       // #########################################################
       // Despreza registros com quantidade = 0 se parametrizado ##
       // #########################################################
       If pZerados == "N"
          If kQuantidade == 0 
             Loop
          Endif
       Endif

       // ##########################
       // Trata o nome da Empresa ##
       // ##########################
       Do Case
          Case kEmpresa == '01'
               cEmpresa := "01 - Automatech"
               Do Case
                  Case kFilial == "01"
                       xFilial := "01 - Porto Alegre"
                  Case kFilial == "02"
                       xFilial := "02 - Caxias do Sul"
                  Case kFilial == "03"
                       xFilial := "03 - Pelotas"
                  Case kFilial == "04"
                       xFilial := "04 - Suprimentos"
                  Case kFilial == "05"
                       xFilial := "05 - São Paulo"
                  Case kFilial == "06"
                       xFilial := "06 - Espirito Santo"
                  Case kFilial == "07"
                       xFilial := "07 - Suprimnetos(Nova)"
               EndCase
          Case kEmpresa == '02'
               cEmpresa := "02 - TI Automação"
               xFilial  := "01 - Curitiba"
          Case kEmpresa == '03'
               cEmpresa := "03 - Atech"
               xFilial  := "01 - Porto Alegre"
          Case kEmpresa == '04'
               cEmpresa := "04 - Atech"
               xFilial  := "01 - Pelotas"
       EndCase               

       // #########################
       // Carrega o array aLista ##
       // #########################
       aAdd( aLista, { .F.           ,; // 01 - Marca/Desmarca
                       cEmpresa      ,; // 02 - Empresa
                       xFilial       ,; // 03 - Filial
                       kCodigo       ,; // 04 - Código do Produto
                       kNomePro      ,; // 05 - Descrição do Produto
                       kAcao         ,; // 06 - Ação
                       kSerie        ,; // 07 - Nº de Série
                       kArmazem      ,; // 08 - Armazém 
                       kQuantidade })   // 09 - Quantidade
          
   Next nContar
   
   If Len(aLista) == 0
      MsgAlert("Não existem dados a serem visualizados para esta pesquisa. Verifique dados informados.")
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "" } )   
   Endif

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
           					    aLista[oLista:nAt,03],;
           					    aLista[oLista:nAt,04],;
          					    aLista[oLista:nAt,05],;
          					    aLista[oLista:nAt,06],;
          					    aLista[oLista:nAt,07],;
          					    aLista[oLista:nAt,08],;
          					    aLista[oLista:nAt,09]}}
   oLista:Refresh()
      
Return(.T.)

// ###########################################################
// Função que processa as movimentações de Entrada e Saídas ##
// ###########################################################
Static Function AcaoMovimentar()

   If lproduto == .F.
      MsgAlert("Atenção!"                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Parametrização de importação não informada.")
      Return(.T.)
   Endif
   
   If Pproduto == 0
      MsgAlert("Atenção!"                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Parametrização de importação não informada.")
      Return(.T.)
   Endif
   
   If lQuantidade == .F.
      MsgAlert("Atenção!"                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Parametrização de importação não informada.")
      Return(.T.)
   Endif

   If Pquantidade == 0
      MsgAlert("Atenção!"                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Parametrização de importação não informada.")
      Return(.T.)
   Endif
   
   If lArmazem == .F.
      MsgAlert("Atenção!"                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Parametrização de importação não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(Parmazem))
      MsgAlert("Atenção!"                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Parametrização de importação não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho a ser gravado a arquivo de log de ajuste nao selecionado. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cArqLog))
      MsgAlert("Nome do arquivo de log de ajuste não informado. Verifique!")
      Return(.T.)
   Endif

   cCaminho := Alltrim(cCaminho) + Alltrim(cArqLog)

   MsgRun("Favor Aguarde! Realizando movimentações de estoque ...", "Movimentações de Estoque",{|| AMovimentar() })      

Return(.T.)

// ###########################################################
// Função que processa as movimentações de Entrada e Saídas ##
// ###########################################################
Static Function AMovimentar()

   Local nContar      := 0
   Local lMarcado     := .F.
   Local cSql         := ""
   Local aAuto        := {}
   Local aItem        := {}
   Local _xDOCx       := ""
   Local cLote        := "   "
   Local dDataVl      := ""
   Local nQuant       := 1
   Local nOpcAuto     := 3 // Indica qual tipo de ação será tomada (Inclusão/Exclusão)
   Local cString      := ""
   Local aCabS        := {}
   Local aItemS       := {}      
   Local lTem_Incluir := .F.
   Local lTem_Baixar  := .F.
   Local lEfetiva     := .F.

   PRIVATE lMsHelpAuto := .T.
   PRIVATE lMsErroAuto := .F.

   // #############################################################################
   // Verifica se caminho para gravação do arquivo de log de baixa foi informado ##
   // #############################################################################
   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho para gravação do arquivo de LOG não informado.")
      Return(.T.)
   Endif

   // #############################################################################
   // Verifica se caminho para gravação do arquivo de log de baixa foi informado ##
   // #############################################################################
   If Empty(cEmissao)
      MsgAlert("Data da Movimentação não informada.")
      Return(.T.)
   Endif

   // ####################################################################################################
   // Verifica se houve marcação de pelo menos um registro para realizar a transferência entre armazéns ##
   // ####################################################################################################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro foi marcado para realizar o processo de movimentação de estoque. Verifique!")
      Return(.T.)
   Endif
             
   // ###########################################################################
   // Verifica se existem lançamentos de entradas e saídas a serem realizadas. ##
   // Isso é necessário para a geração dos códigos dos documentos              ##
   // ###########################################################################
   lTem_Incluir := .F.

   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif  

       If Upper(Alltrim(aLista[nContar,6])) == "E"
          lTem_Incluir := .T.
          Exit
       Endif

   Next nContar

   lTem_Baixar := .F.

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .F.
          Loop
       Endif  
       If Upper(Alltrim(aLista[nContar,6])) == "S"
          lTem_Baixar := .T.
          Exit
       Endif
   Next nContar

   If lTem_Incluir == .F. .And. lTem_Baixar == .F.
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não foram localizados ações de Incluir ou Baixar produtos para o processo. Verifique!")
      Return(.T.)
   Endif

   // ################################################################
   // Verifica se a Empresa logada é a mesma do arquivo selecionado ##
   // ################################################################
   If aLista[01,02] <> cEmpAnt
      Do Case
         Case cEmpAnt == "01"
              Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo selecionado não pertence a Empresa logada. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "Empresa Logada: 01 - Automatech" + chr(13) + chr(10) + "Empresa arquivo selecionado: " + aLista[01,02])
         Case cEmpAnt == "02"
              Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo selecionado não pertence a Empresa logada. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "Empresa Logada: 02 - TI Automação" + chr(13) + chr(10) + "Empresa arquivo selecionado: " + aLista[01,02])
         Case cEmpAnt == "03"
              Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo selecionado não pertence a Empresa logada. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "Empresa Logada: 03 - Atech" + chr(13) + chr(10) + "Empresa arquivo selecionado: " + aLista[01,02])
         Case cEmpAnt == "04"
              Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo selecionado não pertence a Empresa logada. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "Empresa Logada: 03 - Atech" + chr(13) + chr(10) + "Empresa arquivo selecionado: " + aLista[01,02])
      EndCase
      Return(.T.)
   Endif

   // ###########################################################
   // Inicializa a variável que conterá o log da transferência ##
   // ###########################################################
   cString := ""

   // ##################################################
   // Realiza as inclusões de quantidades de produtos ##
   // ##################################################
   If lTem_Incluir == .T.

      _xDOCx := GetSxENum("SD3","D3_DOC",1)

      cString += "Documento de Entrada nr " + _xDOCx + chr(13) + chr(10)

      // #################################
      // Inclui os registro de Entradas ##
      // #################################
      aCabE    := {}
      aItemE   := {}
      lEfetiva := .T.

      aCabE := {{"D3_DOC"    , _xDOCx   ,Nil},;
                {"D3_TM"     , "410"    ,Nil},;
                {"D3_CC"     , ''       ,Nil},;
                {"D3_EMISSAO", cEmissao ,Nil}}
                                                   
      // ###############################
      // Carrega os produtos no array ##
      // ###############################
      For nContar = 1 to Len(aLista)
    
          // ###########################
          // Se não marcado, despreza ##
          // ###########################
          If aLista[nContar,1] == .F.
             Loop
          Endif
          
          // ###########################################
          // Se não for registro de Entrada, despreza ##
          // ########################################### 
          If UPPER(Alltrim(aLista[nContar,6])) <> "E"
             Loop
          Endif

          // ########################################
          // Despreza registros com quantidade = 0 ##
          // ########################################
          If aLista[nContar,9] == 0
             Loop
          Endif

          // ############################################################
          // Verifica se o produto lido é com controle de nº de série. ##
          // Se for, não movimenta (por enquanto)                      ##
          // ############################################################
          If Posicione( "SB1", 1, xFilial("SB1") + aLista[nContar,04], "B1_LOCALIZ" ) == "S"
             cString += "Produto: " + Alltrim(aLista[nContar,04]) + " - " + Alltrim(aLista[nContar,05]) + " tem seu controle por nº de série. Efetivação não executada." + chr(13) + chr(10)
             Loop
          Endif

          // #####################################
          // Prepara a quantidade para gravação ##
          // #####################################
          kkQuantidade := IIF(aLista[nContar,09] >= 0, aLista[nContar,09], (aLista[nContar,09] * -1))

          // #################################    
          // Atualiza o array para gravação ##
          // #################################
          aadd(aItemE,{{"D3_FILIAL", Substr(aLista[nContar,03],01,02), NIL},;
                       {"D3_COD"   , aLista[nContar,04]              , NIL},;
                       {"D3_QUANT" , kkQuantidade                    , NIL},;
                       {"D3_DTLANC", cEmissao                        , Nil},;
                       {"D3_LOCAL" , aLista[nContar,08]              , NIL}})

          cString += "Produto: " + Alltrim(aLista[nContar,04]) + " - " + Alltrim(aLista[nContar,05]) + " efetivado." + chr(13) + chr(10)

          lEfetiva := .T.

      Next nContar

      // ##################################################
      // Atualiza os registros de Movimentação Interna 2 ##
      // ##################################################
      If lEfetiva == .T.

         MSExecAuto({|x,y,z|MATA241(x,y,z)},aCabE,aItemE, 3)

         If lMsErroAuto
            MostraErro()
         EndIf

      Endif
      
   Endif   

   // ###############################################
   // Realiza as Saídas de quantidades de produtos ##
   // ###############################################
   If lTem_Baixar == .T.

      _xDOCx := GetSxENum("SD3","D3_DOC",1)

      cString += "Documento de Saída nr " + _xDOCx + chr(13) + chr(10)

      // ###############################
      // Inclui os registro de Saídas ##
      // ###############################
      aCabS    := {}
      aItemS   := {}      
      lEfetiva := .F.
   
      aCabS := {{"D3_DOC"    , _xDOCx  ,Nil},;
                {"D3_TM"     , "600"   ,Nil},;
                {"D3_CC"     , ''      ,Nil},;
                {"D3_EMISSAO", cEmissao,Nil}}
                                                   
      For nContar = 1 to Len(aLista)

          // ###########################
          // Se não marcado, despreza ##
          // ###########################
          If aLista[nContar,1] == .F.                
             Loop
          Endif
         
          // #########################################
          // Se não for registro de Saída, despreza ##
          // ######################################### 
          If Upper(Alltrim(aLista[nContar,6])) <> "S"
             Loop
          Endif

          // ########################################
          // Despreza registros com quantidade = 0 ##
          // ########################################
          If aLista[nContar,9] == 0
             Loop
          Endif

          // ############################################################
          // Verifica se o produto lido é com controle de nº de série. ##
          // Se for, não movimenta (por enquanto)                      ##
          // ############################################################
          If Posicione( "SB1", 1, xFilial("SB1") + aLista[nContar,04], "B1_LOCALIZ" ) == "S"
             cString += "Produto: " + Alltrim(aLista[nContar,04]) + " - " + Alltrim(aLista[nContar,05]) + " tem seu controle por nº de série. Efetivação não executada." + chr(13) + chr(10)
             Loop
          Endif

          // #####################################
          // Prepara a quantidade para gravação ##
          // #####################################
          kkQuantidade := IIF(aLista[nContar,09] >= 0, aLista[nContar,09], (aLista[nContar,09] * -1))

          // ######################################################################
          // Verifica se existe saldos para a quantidade solicitada para reserva ##
          // ######################################################################   
          dbSelectArea("SB2")
          dbSetOrder(1)
          MsSeek(cFilAnt + Padr(aLista[nContar,04],30) + aLista[nContar,08])

          If SaldoSb2() < kkQuantidade

             cString += "Produto: " + Alltrim(aLista[nContar,04]) + " - " + Alltrim(aLista[nContar,05]) + " sem saldo suficiente para efetivação." + chr(13) + chr(10)

             Loop

          Else

             aadd(aItemS,{{"D3_FILIAL", Substr(aLista[nContar,03],01,02), NIL},;
                          {"D3_COD"   , aLista[nContar,04]              , NIL},;
                          {"D3_QUANT" , kkQuantidade                    , NIL},;
                          {"D3_DTLANC", cEmissao                        , NIL},;
                          {"D3_LOCAL" , aLista[nContar,08]              , NIL}})

             cString += "Produto: " + Alltrim(aLista[nContar,04]) + " - " + Alltrim(aLista[nContar,05]) + " efetivado." + chr(13) + chr(10)

             lEfetiva := .T.

          Endif
          
      Next nContar

      // ##################################################
      // Atualiza os registros de Movimentação Interna 2 ##
      // ##################################################
      If lEfetiva

         MSExecAuto({|x,y,z|MATA241(x,y,z)},aCabS,aItemS, 3)

         If lMsErroAuto
            MostraErro()
         EndIf

      Endif

   Endif   
  
   // ###################################
   // Salva o arquivo de log de Baixas ##
   // ###################################
   cCaminho := Alltrim(cCaminho)

   nHdl := fCreate(cCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   aAdd( aLista, { .F., "", "", "", "", "", "", "", "" } )

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
           					    aLista[oLista:nAt,03],;
           					    aLista[oLista:nAt,04],;
          					    aLista[oLista:nAt,05],;
          					    aLista[oLista:nAt,06],;
          					    aLista[oLista:nAt,07],;
          					    aLista[oLista:nAt,08],;
          					    aLista[oLista:nAt,09]}}

   MsgAlert("Movimentações realizadas. Verifique arquivo de log.")

Return(.T.)

// ######################################## 
// Função que mostra o layout do arquivo ##
// ########################################
Static Function MstLayout()

   MsgRun("Aguarde! Abrindo tela de parâmetros de ajuste ...", "PROGRAMA: AUTOM326",{|| xMstLayout() })

Return(.T.)

// ######################################## 
// Função que mostra o layout do arquivo ##
// ########################################
Static Function xMstLayout()

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local cMensagem := "O formato do arquivo de importação deve ser do tipo CSV ou TXT." + chr(13) + chr(10) + ;
                      "Separador entre os campos necessariamente deve ser TAB para TXT" + chr(13) + chr(10) + ;
                      "; para CSV"
   Local oMemo1
   Local oMemo3

   Private cPproduto    := pProduto
   Private cPSerie 	    := pSerie
   Private cPQuantidade := pQuantidade
   Private cCabecalho   := pCabecalho
   Private cParmazem    := pArmazem

   Private lkProduto	:= lProduto
   Private lkSerie	    := lSerie
   Private lkQuantidade := lQuantidade
   Private lkArmazem    := lArmazem

   Private aTipoLanc    := {"T - Entradas/Saídas", "E - Entradas", "S - Saídas"}
   Private aZerados     := {"S - Sim", "N - Não"}

   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oCheckBox4
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4   
   Private oMemo2
   Private cComboBx1
   Private cComboBx2

   Private oDlgP

   Do Case 
      Case pTipoLanc == "T"
           cComboBx1 := "T - Entradas/Saídas"
      Case pTipoLanc == "E"
           cComboBx1 := "E - Entradas"
      Case pTipoLanc == "S"
           cComboBx1 := "S - Saídas"
      Otherwise
           cComboBx1 := "T - Entradas/Saídas"           
   EndCase

   Do Case
      Case pZerados == "S"
           cComboBx2 := "S - Sim"
      Case pZerados == "N"
           cComboBx2 := "N - Não"
      OtherWise
           cComboBx2 := "S - Sim"            
   EndCase           

   DEFINE MSDIALOG oDlgP TITLE "Ajuste de Estoque Autuomático" FROM C(178),C(181) TO C(544),C(515) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(106),C(022) PIXEL NOBORDER OF oDlgP

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(161),C(001) PIXEL OF oDlgP

   @ C(032),C(005) Say "Parâmetros para importação de arquivo de ajuste de estoque automático" Size C(146),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(045),C(087) Say "Número da coluna"                                                      Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(057),C(087) Say "Número da coluna"                                                      Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(070),C(087) Say "Número da coluna"                                                      Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(083),C(087) Say "Número do Armazém"                                                     Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(098),C(005) Say "Visualizar registros do tipo"                                          Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(098),C(086) Say "Visualizar Registros Zerados"                                          Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(120),C(005) Say "Observações"                                                           Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

			   
   @ C(044),C(005) CheckBox oCheckBox1 Var   lkProduto    Prompt "Código do Produto" Size C(058),C(008)                                                  PIXEL OF oDlgP When lChumba
   @ C(044),C(140) MsGet    oGet1      Var   cPproduto                               Size C(023),C(009) PICTURE "#@E 99999" COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(057),C(005) CheckBox oCheckBox2 Var   lKSerie      Prompt "Número de Série"   Size C(053),C(008)                                                  PIXEL OF oDlgP
   @ C(057),C(140) MsGet    oGet2      Var   cPserie                                 Size C(023),C(009) PICTURE "#@E 99999" COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(070),C(005) CheckBox oCheckBox3 Var   lKQuantidade Prompt "Quantidade Ajuste" Size C(057),C(008)                                                  PIXEL OF oDlgP When lChumba
   @ C(070),C(140) MsGet    oGet3      Var   cPquantidade                            Size C(023),C(009) PICTURE "#@E 99999" COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(083),C(005) CheckBox oCheckBox4 Var   lkArmazem    Prompt "Armazém"           Size C(048),C(008)                                                  PIXEL OF oDlgP When lChumba
   @ C(083),C(140) MsGet    oGet4      Var   cParmazem                               Size C(023),C(009)                     COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(107),C(005) ComboBox cComboBx1  Items aTipoLanc                               Size C(078),C(010)                                                  PIXEL OF oDlgP
   @ C(107),C(086) ComboBox cComboBx2  Items aZerados                                Size C(078),C(010)                                                  PIXEL OF oDlgP
   @ C(129),C(005) GET      oMemo3     Var   cMensagem    MEMO                       Size C(158),C(033)                                                  PIXEL OF oDlgP When lChumba

   @ C(184),C(066) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( FechaTELPAR() )

   @ C(167),C(047) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgP ACTION( FechaTELPAR() )
   @ C(167),C(086) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgp:End() )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)               

// #################################################################
// Função que fecha a tela de parâmetros de importação de arquivo ##
// #################################################################
Static Function FechaTELPAR()

   If lKproduto == .F.
      MsgAlert("Produto não selecionado.")
      Return(.T.)
   Endif
   
   If cPproduto == 0
      MsgAlert("Posição coluna produto não informada.")
      Return(.T.)
   Endif
   
   If lkQuantidade == .F.
      MsgAlert("Quantidade não selecionada.")
      Return(.T.)
   Endif

   If cPquantidade == 0
      MsgAlert("Posicão columa quantidade não informada.")
      Return(.T.)
   Endif
   
   If lkArmazem == .F.
      MsgAlert("Armazém não selecionado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cParmazem))
      MsgAlert("Armazém a ser movimentado não informado.")
      Return(.T.)
   Endif
   
   pProduto    := cPproduto
   pSerie      := cPserie
   pQuantidade := cPQuantidade
   pCabecalho  := cCabecalho
   pArmazem    := cParmazem
   pTipoLanc   := Substr(cComboBx1,01,01)
   pZerados    := Substr(cComboBx2,01,01)

   lProduto    := lkProduto
   lSerie      := lkSerie
   lQuantidade := lkQuantidade
   lArmazem    := lkArmazem

   oDlgP:End()                
   
Return(.T.)