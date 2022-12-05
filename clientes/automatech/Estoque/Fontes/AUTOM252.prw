#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM252.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/09/2014                                                          *
// Objetivo..: Importação automática de CTe                                        *
//**********************************************************************************

User Function AUTOM252()

   Local cMemo1	  := ""
// Local nRadioOp := 0

   Local oMemo1
// Local oRadioOp

   Private lAbertura := 0
   Private aErro     := {}

   Private oDlgInf

   U_AUTOM628("AUTOM252")

   DEFINE MSDIALOG oDlgInf TITLE "Importação de CTE's" FROM C(178),C(181) TO C(417),C(465) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(136),C(030) PIXEL NOBORDER OF oDlgInf

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(135),C(001) PIXEL OF oDlgInf

   @ C(040),C(003) Button "Importação Individual" Size C(135),C(024) PIXEL OF oDlgInf ACTION( ImpIndividual() )
   @ C(065),C(003) Button "Importação Agrupada"   Size C(135),C(024) PIXEL OF oDlgInf ACTION( ImpAgrupada() )
   @ C(091),C(003) Button "Voltar"                Size C(135),C(024) PIXEL OF oDlgInf ACTION( oDlgInf:End() )

   ACTIVATE MSDIALOG oDlgInf CENTERED 

Return(.T.)

// Função que confere os centro de custos informados
Static Function ImpIndividual()

   Local lChumba       := .F.
   Local cMemo1	       := ""
   Local cString       := ""
   Local oMemo1
   Local aFiles        := {} // O array receberá os nomes dos arquivos e do diretório
   Local aSizes        := {} // O array receberá os tamanhos dos arquivos e do diretorio
   Local nX

   Local cImportar     := Space(150)
   Local oGet1

   Private oDlg

   Private nMeter1	     := 0
   Private cConsistencia := ""
   
   Private oMeter1
   Private oConsistencia
   Private lRetErro      := .F.

   Private aArquivos   := {}
   Private oArquivos
   Private PRODU_PCTE  := ""
   Private SAIDA_PCTE  := ""
   Private CONDI_DCTE  := ""
   Private CICMS_CCTE  := ""
   Private SICMS_SCTE  := ""
   Private DIRET_ORIO  := ""
   Private NATUR_EZA   := ""
   Private CENTRO_CUS  := ""
   
   // Verifica se parâmetros estão criados para ser rodado o programa
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_PCTE," && Código do produto para cte's ref, a notas fiscais de entrada
   cSql += "       ZZ4_PCT1," && Código do produto para cte's ref, a notas fiscais de saída
   cSql += "       ZZ4_DCTE," && Condição de Pagamento para inclusão dos conhecimentos de transportes
   cSql += "       ZZ4_CCTE," && TES para conhecimentos de transportes com ICMS
   cSql += "       ZZ4_SCTE," && TES para conhecimentos de transportes sem ICMS
   cSql += "       ZZ4_DXML," && Indica o diretório onde estão os XML's a serem carregados
   cSql += "       ZZ4_NATC," && Código da Natureza a ser utilizada para o Contas a Pagar
   cSql += "       ZZ4_CCUS " && Código do Centro de Custo utilizado em caso de não informação do mesmo
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não existem parâmetros criados para este programa." + chr(13) + chr(10) + "Entre em contato com o administrador do sistema.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCTE))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código do produto Frete (Entrada) não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCT1))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código do produto Frete (Saída) não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_DCTE))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Condição de Pagamento para Frete não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso."  + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_CCTE))
      MsgAlert("Atenção!"  + chr(13) + chr(10) + chr(13) + chr(10) + "TES de frete com ICMS não parametrizada." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_SCTE))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "TES de frete sem ICMS não parametrizada." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_DXML))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Diretório a ser utilizado para importação não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_NATC))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código da Natureza para importação não parametrizada." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_CCUS))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Centro de Custo padrão para importação não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   // Carrega variáveis de parâmetros
   PRODU_PCTE := T_PARAMETROS->ZZ4_PCTE
   SAIDA_PCTE := T_PARAMETROS->ZZ4_PCT1
   CONDI_DCTE := T_PARAMETROS->ZZ4_DCTE
   CICMS_CCTE := T_PARAMETROS->ZZ4_CCTE
   SICMS_SCTE := T_PARAMETROS->ZZ4_SCTE
   DIRET_ORIO := T_PARAMETROS->ZZ4_DXML
   NATUR_EZA  := T_PARAMETROS->ZZ4_NATC
   CENTRO_CUS := T_PARAMETROS->ZZ4_CCUS

   lAbertura             := 1
   
   // Desenha a tela de importação de CTE's
   DEFINE MSDIALOG oDlg TITLE "Importação de CTE's - Conhecimento de Transportes" FROM C(178),C(181) TO C(361),C(673) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(239),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Este programa realiza a importação de CTE's - Conhecimentos de Transportes." Size C(187),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(005) Say "Informe a chave do CTE a ser importado."                                     Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(060),C(005) MsGet oGet1 Var cImportar Size C(235),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(074),C(164) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION( CarregaXML(cImportar) )
   @ C(074),C(203) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End()   )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################################
// Função que carrega o array com os arquivos XML para importação ##
// #################################################################
Static Function CarregaXML(_aImportar)

   Local lChumba   := .F.
   Local xContar   := 0
   Local aFiles    := {} // O array receberá os nomes dos arquivos e do diretório
   Local aSizes    := {} // O array receberá os tamanhos dos arquivos e do diretorio
   Local nRegua    := 0
   Local cAvancada := Space(250)
   Local cMemo1	   := ""
   Local oGet1
   Local oMemo1

   Local xArquivo  := Alltrim(_aImportar)

   Private lDeuErro := .F.

   Private oDlgAvancada

   // ####################################################################
   // Inicializa o array que receberá o nome do arquivo a ser importado ##
   // ####################################################################
   aArquivos := {}

   If Empty(xArquivo)
      MsgAlert("Chave do CTE a ser importado não informado. Verifique!")
      Return(.T.)
   Endif

   DIRET_ORIO := "C:\XML\"
                       
   // ############################################
   // Carrega os arquivos do diretório de XML's ##
   // ############################################
   ADir(Alltrim(DIRET_ORIO) + "*.*", aFiles, aSizes)
     
   // #################################################
   // Carrega o array aArquivos para display no List ##
   // #################################################
   nRegua := 0
   nCount := Len( aFiles )

   For nX := 1 to nCount  
   
//     If Substr(aFiles[nX],01,01) == "#"
//        Loop
//     Endif

       If U_P_OCCURS(UPPER(aFiles[nX]), "CTE"  , 1) <> 0 .Or. ;
          U_P_OCCURS(UPPER(aFiles[nX]), "CT-E" , 1) <> 0 .Or. ;
          U_P_OCCURS(UPPER(aFiles[nX]), "CT-e_", 1) <> 0 .Or. ;
          U_P_OCCURS(UPPER(aFiles[nX]), "cte"  , 1) <> 0
                                               
          If U_P_OCCURS(UPPER(aFiles[nX]), "CANC", 1) <> 0
             Loop
          Endif

          cString := U_P_CORTA(aFiles[nX], ".", 1)

          If U_P_OCCURS(aFiles[nX], xArquivo, 1) <> 0
             aAdd( aArquivos, { .T., aFiles[nX] } )
          Endif
          
       Endif   

   Next nX

   If Len(aArquivos) == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Chave do arquivo CTE informado não localizado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // ###########################################################
   // Realiza a importação dos dados da Chave do CTE informado ##
   // ###########################################################
   For xContar = 1 to Len(aArquivos)

       // ##########################################################
       // Inicializa a variável de controle de erro de importação ##
       // ##########################################################
       lDeuErro := .F.
       
       // ##################################################
       // Função de importação dos dadso do CTE informado ##
       // ##################################################
       I_CTE_FRETE(aArquivos[xContar,2])

       If lDeuErro == .T.
          Loop
       Endif

       // ##########################################################
       // Renomea o arquivo para que este não seja mais utilizado ##
       // ##########################################################
       If Substr(aArquivos[xContar,2],01,01) <> "#"
          nStatus1 := frename(Alltrim(DIRET_ORIO) + Alltrim(aArquivos[xContar,2]), Alltrim(DIRET_ORIO) + "#" + Alltrim(aArquivos[xContar,2]) ) 
       Else
          nStatus1 := 0
       Endif   
       
       IF nStatus1 == -1
          MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + Chr(10) + "Houve falha na operação: FError " + str(ferror(),4) + " - Arq.XML " + Alltrim(aArquivos[xContar,2]))
       Else
          MsgAlert("Arquivo XML " + Alltrim(aArquivos[xContar,2]) + " processado com sucesso.")
       Endif   

   Next xContar

Return(.T.)

// Função que realiza a importação do conhecimento de transporte selecionado
Static Function I_CTE_FRETE(__Arquivo)

   Local nContar      := 0
   Local lVoltar      := .F.
   Local cAgravar     := ""
   Local cConteudo    := ""
   Local aBrowse      := {}
   Local nQuantos     := 0
   Local cLegenda     := ""
   Local nBruto       := 0
   Local cChave       := ""
   Local cSerie       := ""
   Local cNumero      := ""
   Local cCodForne    := ""
   Local cLojForne    := ""
   Local cEstForne    := ""
   Local cModelo      := ""
   Local cEmissao     := ""
   Local cArquivo     := Alltrim(DIRET_ORIO) + Alltrim(__Arquivo)
   Local cSql         := ""
   Local nContar      := 0
   Local _nErro       := 0
   Local tStatus      := "E"
   Local lPodeGrv     := .T.
   Local aFreteN      := {}
   Local _nErro       := 0
   Local oOk          := LoadBitmap( GetResources(), "LBOK" )
   Local oNo          := LoadBitmap( GetResources(), "LBNO" )

   Local lNaoeCTE     := .F.

   Private __Empresa  := ""
   Private __Filial   := ""
   Private __FilGrava := ""
   Private __xSerie   := ""

   Private xChave     := Alltrim(__Arquivo)
   Private aFretes    := {}
   Private aNotas     := {}
   Private aRelatorio := {}
   Private __FilGrava := ""

   lDeuErro := .F.

   // Realiza a consistência dos dados antes da importação
   If !File(Alltrim(cArquivo))

      If lAbertura == 1
         MsgAlert("Arquivo XML para importação inexistente.")
         lDeuErro := .T.
      Else
         aAdd( aErro, { Alltrim(cArquivo), "Arquivo XML para importação inexistente." })
         lDeuErro := .T.
      Endif
               
      REturn(.T.)
   Endif

   // Limpa o Array das notas fiscais importadas
   aNotas := {}
   aAdd( aNotas, { '1', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' } )

   // Abre o arquivo informado do conhecimento de transporte para importação
   nHandle := FOPEN(Alltrim(cArquivo), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0

      If lAbertura == 1
         MsgAlert("Erro ao abrir o arquivo " + Alltrim(__Arquivo))
         lDeuErro := .T.
      Else
         aAdd( aErro, { Alltrim(__Arquivo), "Erro ao abrir o arquivo" })
         lDeuErro := .T.
      Endif
         
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
       If Substr(xBuffer, nContar, 1) <> ">"
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cAgravar := ""
          For nLimpa = 1 to Len(cConteudo)
              If Substr(cConteudo, nLimpa, 2) == "</"
                 Exit
              Else   
                 cAgravar := cAgravar + Substr(cConteudo, nLimpa, 1)
              Endif
          Next nLimpa
          aAdd(aBrowse, { cAgravar } )
          cConteudo := ""
       Endif
   Next nContar    

   // Fecha o arquivo
   fClose(nHandle)

   // Verifica se XML lido é um XML de Conhecimento de Transprote
   If Len(aBrowse) == 0

      If lAbertura == 1
         MsgAlert("Importação do arquivo " + Alltrim(__Arquivo) + " com problema. Processo abortado.")
         lDeuErro := .T.
      Else
         aAdd( aErro, { Alltrim(__Arquivo), "Importação do arquivo com problema. Processo abortado." })
         lDeuErro := .T.
      Endif
         
      Return(.T.)
   Endif
      
//   If Upper(Alltrim(aBrowse[2,1])) <> "<CTE"
//
//      If lAbertura == 1
//         MsgAlert("XML " + Alltrim(__Arquivo) + " não é um XML de Conhecimento de Transporte.")
//      Else
//         aAdd( aErro, { Alltrim(__Arquivo), "XML não é um XML de Conhecimento de Transporte." })
//      Endif            
//           
//      Return(.T.)
//   Endif
   
   // Percorre o array e procura a tag <CTE>. Se não encontrar, dá aviso que não é um CML de transporte.
   lNaoeCTE := .F.
   For nContar = 1 to Len(aBrowse)
       If Substr(Upper(Alltrim(aBrowse[nContar,1])),01,04) == "<CTE"
          lNaoeCTE := .T.
          Exit
       Endif
   Next ncontar
   
   If lNaoeCTE == .F.    
      If lAbertura == 1
         MsgAlert("XML " + Alltrim(__Arquivo) + " não é um XML de Conhecimento de Transporte.")
         lDeuErro := .T.
      Else
         aAdd( aErro, { Alltrim(__Arquivo), "XML não é um XML de Conhecimento de Transporte." })
         lDeuErro := .T.
      Endif            
      Return(.T.)
   Endif

   // Pesquisa a data do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,06) == '<dhEmi'
          nContar  := nContar + 1              
          cDataCTE := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        
   
   cdataCTE := Ctod(Substr(cDataCTE,09,02) + "/" + Substr(cDataCTE,06,02) + "/" + Substr(cDataCTE,01,04))

   // Pesquisa o nome da Transportadora
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<emit'
          nContar  := nContar + 2                  
          cCNPJT   := aBrowse[nContar,01]
          nContar  := nContar + 4                  
          cTranspo := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o código da transportadora
   If Select("T_TRANSPO") > 0
      T_TRANSPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A4_COD"
   cSql += "  FROM " + RetSqlName("SA4")
   cSql += " WHERE D_E_L_E_T_ = ''"
// cSql += "   AND A4_CGC LIKE '" + Substr(cCNPJT,01,08) + "%'"
   cSql += "   AND A4_CGC     = '" + Alltrim(cCNPJT) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPO", .T., .T. )

   If T_TRANSPO->( EOF() )
      cCodTransp := ""
   Else   
      cCodTransp := T_TRANSPO->A4_COD
   Endif   
               
   // Pesquisa a Transportadora no cadastro de Fornecedores pelo CNPJ
   If Select("T_FORNECEDOR") > 0
      T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD ,"
   cSql += "       A2_LOJA,"
   cSql += "       A2_EST  "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE D_E_L_E_T_ = ''"
// cSql += "   AND A2_CGC LIKE '" + Substr(cCNPJT,01,08) + "%'"
   cSql += "   AND A2_CGC     = '" + Alltrim(cCNPJT) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   If T_FORNECEDOR->( EOF() )
      cCodForne := ""               
      cLojForne := ""
      cEstForne := ""
   Else   
      cCodForne := T_FORNECEDOR->A2_COD
      cLojForne := T_FORNECEDOR->A2_LOJA
      cEstForne := T_FORNECEDOR->A2_EST
   Endif   

   // Pesquisa a Chave do Conhecimento de Frete
   For nContar = 1 to Len(aBrowse)

       If Substr(aBrowse[nContar,01],01,11) == '<infCte Id=' .Or. Substr(aBrowse[nContar,01],01,14) == '<infCte versao'

          Do Case

             Case Substr(aBrowse[nContar,01],01,11) == '<infCte Id='          
                  cChave := Substr(aBrowse[nContar,01],16,44)
                  xChave := Substr(aBrowse[nContar,01],16,44)

             Case Substr(aBrowse[nContar,01],01,14) == '<infCte versao'
                  cChave := Substr(aBrowse[nContar,01],30,44)
                  xChave := Substr(aBrowse[nContar,01],30,44)

          EndCase

          Exit

       Endif

   Next nContar        

//   // Verifica se chave já foi incluída na tabela ZS9
//   If Select("T_JACADASTRADA") > 0
//      T_JACADASTRADA->( dbCloseArea() )
//   EndIf
//
//   cSql := ""
//   cSql := "SELECT ZS9_CHAV"
//   cSql += "  FROM " + RetSqlName("ZS9")
//   cSql += " WHERE ZS9_CHAV   = '" + Alltrim(xChave) + "'"
//   cSql += "   AND D_E_L_E_T_ = ''"
//
//   cSql := ChangeQuery( cSql )
//   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JACADASTRADA", .T., .T. )
//
//   If !T_JACADASTRADA->( EOF() )
//      If lAbertura == 1
//         MsgAlert("Arquivo " + chr(13) + chr(10) + Alltrim(__Arquivo) + chr(13) + chr(10) + "já registrado na tabela ZS9.")
//      Else
//         aAdd( aErro, { Alltrim(__Arquivo), "Arquivo já registrado na tabela ZS9." })
//      Endif
//      Return(.T.)
//   Endif

   // Pesquisa a Série do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<serie'
          nContar := nContar + 1                   
          cSerie  := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa a Número do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<nCT'
          nContar := nContar + 1                   
          cNumero := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o Modelo do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<mod'
          nContar := nContar + 1                   
          cModelo := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa a Data de Emissão do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,06) == '<dhEmi'
          nContar  := nContar + 1                   
          cEmissao := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o nome do Remetente
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<rem'  
          nContar    := nContar + 2
          cCGCFor    := aBrowse[nContar,01]
          nContar    := nContar + 4
          cRemetente := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o código do Fornecedor
   If Select("T_FORNECEDOR") > 0
      T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD ,"
   cSql += "       A2_LOJA "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A2_CGC = '" + Alltrim(cCGCFor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   If T_FORNECEDOR->( EOF() )
      cCodFor := Space(06)
      cLojFor := Space(03)
   Else   
      cCodFor := T_FORNECEDOR->A2_COD
      cLojFor := T_FORNECEDOR->A2_LOJA
   Endif   

   // Pesquisa o nome do Destinatário
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<dest'
          nContar  := nContar + 2                   
          cCGCDest := aBrowse[nContar,01]
          nContar  := nContar + 4                   
          cDestino := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o código do Destinatário
   If Select("T_DESTINO") > 0
      T_DESTINO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A1_CGC = '" + Alltrim(cCGCDest) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESTINO", .T., .T. )

   If T_DESTINO->( EOF() )
      cCodCli := Space(06)
      cLojCli := Space(03)
   Else   
      cCodCli := T_DESTINO->A1_COD
      cLojCli := T_DESTINO->A1_LOJA
   Endif   

   // #######################################################################################################
   // Verifica o tipo de conhecimento. Se ref. a notas fiscais de entrada ou ref. a notas fiscais de saída ##
   // #######################################################################################################
   If cCGCFor$("03385913000161#03385913000242#03385913000404#03385913000595#12757071000112#07166377000164#03385913000757")

      lEntrada := .F.
      lSaida   := .T.

      Do Case
         Case cCGCFor == "03385913000161"
              __Empresa  := "01"
              __Filial   := "01"
              __FilGrava := "01"
              __xSerie   := "1"
         Case cCGCFor == "03385913000242"
              __Empresa  := "01"
              __Filial   := "02"
              __FilGrava := "02"
              __xSerie   := "2"
         Case cCGCFor == "03385913000404"
              __Empresa  := "01"
              __Filial   := "03"
              __FilGrava := "03"
              __xSerie   := "3"
         Case cCGCFor == "03385913000595"
              __Empresa  := "01"
              __Filial   := "04"
              __FilGrava := "04"
              __xSerie   := "4"
         Case cCGCFor == "12757071000112"
              __Empresa  := "02"
              __Filial   := "01"
              __FilGrava := "01"
              __xSerie   := "1"
         Case cCGCFor == "07166377000164"
              __Empresa  := "03"
              __Filial   := "01"
              __FilGrava := "01"
              __xSerie   := "1"
         Case cCGCFor == "03385913000757"
              __Empresa  := "01"
              __Filial   := "06"
              __FilGrava := "06"
              __xSerie   := "1"
         Otherwise

             If lAbertura == 1
                lDeuErro := .T.
                MsgAlert("ATENÇÃO!"                                        + chr(13) + chr(10) + chr(13) + chr(10) + ;
                         "CTE nº " + Alltrim(__Arquivo)                    + chr(13) + chr(10) + ;
                         "não pertence a nenhum CNPJ do Grupo Automatech.")
             Else
                aAdd( aErro, { Alltrim(__Arquivo), "CNPJ do CTE não pertence ao Grupo de Empresas Auitomatech. Verifique!" })
                lDeuErro := .T.
             Endif
             
             Return(.T.)
              
      EndCase
      
   Endif   
   
   If cCGCDest$("03385913000161#03385913000242#03385913000404#03385913000595#12757071000112#07166377000164#03385913000757")

      lEntrada := .T.
      lSaida   := .F.

      Do Case
         Case cCGCDest == "03385913000161"
              __Empresa  := "01"
              __Filial   := "01"
              __FilGrava := "01"
              __xSerie   := "1"
         Case cCGCDest == "03385913000242"
              __Empresa  := "01"
              __Filial   := "02"
              __FilGrava := "02"
              __xSerie   := "2"
         Case cCGCDest == "03385913000404"
              __Empresa  := "01"
              __Filial   := "03"
              __FilGrava := "03"
              __xSerie   := "3"
         Case cCGCDest == "03385913000595"
              __Empresa  := "01"
              __Filial   := "04"
              __FilGrava := "04"
              __xSerie   := "4"
         Case cCGCDest == "12757071000112"
              __Empresa  := "02"
              __Filial   := "01"
              __FilGrava := "01"
              __xSerie   := "1"
         Case cCGCDest == "07166377000164"
              __Empresa  := "03"
              __Filial   := "01"
              __FilGrava := "01"
              __xSerie   := "1"
         Case cCGCDest == "03385913000757"
              __Empresa  := "01"
              __Filial   := "06"
              __FilGrava := "06"
              __xSerie   := "1"
      Otherwise
      
         // Pesquisa o CNPJ do Destinatário
         nContar := 0
         For nContar = 1 to Len(aBrowse)
             If Substr(aBrowse[nContar,01],01,05) == '<dest'  
                nContar    := nContar + 2
                xCGCFor    := aBrowse[nContar,01]
                Exit
             Endif
         Next nContar        
 
         Do Case
            Case cCGCDest == "03385913000161"
                 __Empresa  := "01"
                 __Filial   := "01"
                 __FilGrava := "01"
                 __xSerie   := "1"
            Case cCGCDest == "03385913000242"
                 __Empresa  := "01"
                 __Filial   := "02"
                 __FilGrava := "02"
                 __xSerie   := "2"
            Case cCGCDest == "03385913000404"
                 __Empresa  := "01"
                 __Filial   := "03"
                 __FilGrava := "03"
                 __xSerie   := "3"
            Case cCGCDest == "03385913000595"
                 __Empresa  := "01"
                 __Filial   := "04"
                 __FilGrava := "04"
                 __xSerie   := "4"
            Case cCGCDest == "12757071000112"
                 __Empresa  := "02"
                 __Filial   := "01"
                 __FilGrava := "01"
                 __xSerie   := "1"
            Case cCGCDest == "07166377000164"
                 __Empresa  := "03"
                 __Filial   := "01"
                 __FilGrava := "01"
                 __xSerie   := "1"
            Case cCGCDest == "03385913000757"
                 __Empresa  := "01"
                 __Filial   := "06"
                 __FilGrava := "06"
                 __xSerie   := "1"

            Otherwise

                 If lAbertura == 1
                    lDeuErro := .T.
                    MsgAlert("ATENÇÃO!"                                        + chr(13) + chr(10) + chr(13) + chr(10) + ;
                             "CTE nº " + Alltrim(__Arquivo)                    + chr(13) + chr(10) + ;
                             "não pertence a nenhum CNPJ do Grupo Automatech.")
                 Else
                    aAdd( aErro, { Alltrim(__Arquivo), "CNPJ do CTE não pertence ao Grupo de Empresas Auitomatech. Verifique!" })
                    lDeuErro := .T.
                 Endif
             
                 Return(.T.)

         EndCase
      
      EndCase

   Endif   

   // ##########################################################
   // Verifica se o CTE lido pertence a Empresa/Filial logada ##
   // ##########################################################
   If Alltrim(cEmpAnt) == Alltrim(__Empresa)
   
      If Alltrim(cFilAnt) == Alltrim(__Filial)
      Else
         If lAbertura == 1
            lDeuErro := .T.
            MsgAlert("ATENÇÃO!"                                                                                                     + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Você está logado na Empresa " + Alltrim(cEmpAnt) + " - Filial " + Alltrim(cFilAnt)                            + chr(13) + chr(10) + ;
                     "O CTE: " + Alltrim(__Arquivo)                                                                                 + chr(13) + chr(10) + ;
                     "que você está querendo importar, pertence a Empresa " + Alltrim(__Empresa) + " - Filial " + Alltrim(__Filial) + chr(13) + chr(10) + ;
                     "Logue-se na Empresa indicada e importe novamente este CTE.")
         Else
            aAdd( aErro, { Alltrim(__Arquivo), "CTE não pertence a esta Empresa/Filial. Verifique!" })
            lDeuErro := .T.
         Endif
         Return(.T.)
      Endif
      
   Else

      If lAbertura == 1
         lDeuErro := .T.
         MsgAlert("ATENÇÃO!"                                                                                                     + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Você está logado na Empresa " + Alltrim(cEmpAnt) + " - Filial " + Alltrim(cFilAnt)                            + chr(13) + chr(10) + ;
                  "O CTE: " + Alltrim(__Arquivo)                                                                                 + chr(13) + chr(10) + ;
                  "que você está querendo importar, pertence a Empresa " + Alltrim(__Empresa) + " - Filial " + Alltrim(__Filial) + chr(13) + chr(10) + ;
                  "Logue-se na Empresa indicada e importe novamente este CTE.")
      Else
         aAdd( aErro, { Alltrim(__Arquivo), "CTE não pertence a esta Empresa/Filial. Verifique!" })
         lDeuErro := .T.
      Endif

      Return(.T.)

   Endif               

   // ##################################################################################################
   // Verifica se chave já foi incluída na tabela ZS9 conforme a Empresa setada na variável __Empresa ##
   // ##################################################################################################
   If Select("T_JACADASTRADA") > 0
      T_JACADASTRADA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS9_CHAV"
   cSql += "  FROM ZS9" + Alltrim(__Empresa) + "0 (Nolock)"
   cSql += " WHERE ZS9_CHAV   = '" + Alltrim(xChave) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JACADASTRADA", .T., .T. )

   If !T_JACADASTRADA->( EOF() )
      If lAbertura == 1
         MsgAlert("Arquivo " + chr(13) + chr(10) + Alltrim(__Arquivo) + chr(13) + chr(10) + "já registrado na tabela ZS9 da Empresa: " + Alltrim(__Empresa))
         lDeuErro := .T.
      Else
         aAdd( aErro, { Alltrim(__Arquivo), "Arquivo já registrado na tabela ZS9 da Empresa: " + Alltrim(__Empresa) })
         lDeuErro := .T.
      Endif
      Return(.T.)
   Endif

   // ###################################################################################################################################################
   // Pesquisa as notas fiscais de origem do Conhecimento de Transporte lido.                                                                          ##
   // Caso pelo menos uma das notas fiscais do conhecimento de transporte não for encontrada, o CTE lido não será importado, somente gerado relatório. ##
   // Se encontrar, carrega o array aNota com os dados da importação que será utilizdo na inclusão das tabelas.                                        ##
   // ###################################################################################################################################################
   aNotas     := {}
   nAcumulado := 0
   lVoltar    := .F.

   For nContar = 1 to Len(aBrowse)

       // Em case de informação do nº da chave
//       If Substr(aBrowse[nContar,01],01,07) == '<infNFe'     .Or. ;
//          Substr(aBrowse[nContar,01],01,11) == '<infCteComp' .Or. ;
//          Substr(aBrowse[nContar,01],01,07) == '<infDoc'
//
////        Substr(aBrowse[nContar,01],01,07) == '<infCte'     .Or. ;
//
//          If Substr(aBrowse[nContar,01],01,07) == '<infDoc'
//             nContar  := nContar + 3
//          Else
//             nContar  := nContar + 2                   
//          Endif   
          
       If UPPER(ALLTRIM(aBrowse[nContar,1])) == "<CHAVE" .Or. UPPER(ALLTRIM(aBrowse[nContar,1])) == "<NDOC"
       
          nContar  := nContar + 1                          

          // Em função de poder haver notas fiscais emitidas pela Automatech porém serem notas fiscais de entrada,
          // foi preciso verificar aqui o tipo de nota fiscal se de Entrada ou de Saída

          lEntrada := .F.

          If Select("T_TIPONOTA") > 0
             T_TIPONOTA->( dbCloseArea() )
          EndIf
          
          cSql := ""                               
          cSql := "SELECT F1_FILIAL ,"
          cSql += "       F1_DOC    ,"
          cSql += "       F1_SERIE  ,"
          cSql += "       F1_VALBRUT "
          cSql += "  FROM " + RetSqlName("SF1")
          cSql += " WHERE F1_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
          cSql += "   AND D_E_L_E_T_ = ''

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPONOTA", .T., .T. )

          If T_TIPONOTA->( EOF() )
             lEntrada := .F.
          Else
             lEntrada := .T.
          Endif

          // Pesquisa a legenda da nota fiscal
          If Select("T_TABELA") > 0
             T_TABELA->( dbCloseArea() )
          EndIf

          If lEntrada == .T.
             cSql := ""                               
             cSql := "SELECT F1_FILIAL ,"
             cSql += "       F1_DOC    ,"
             cSql += "       F1_SERIE  ,"
             cSql += "       F1_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF1")
             cSql += " WHERE F1_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Else
             cSql := ""                               
             cSql := "SELECT F2_FILIAL ,"
             cSql += "       F2_DOC    ,"
             cSql += "       F2_SERIE  ,"
             cSql += "       F2_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF2")
             cSql += " WHERE F2_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Endif             

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )
             
          If T_TABELA->( EOF() )
          
             If lAbertura == 1
                MsgAlert("Arquivo " + Alltrim(__Arquivo) + " sem nota fiscal de origem encontrada.")
                lDeuErro := .T.
             Else
                aAdd( aErro, { Alltrim(__Arquivo), "Arquivo sem nota fiscal de origem encontrada." })
                lDeuErro := .T.
             Endif   
             
             lVoltar := .T.
             Exit
          Endif
  
          // Pesquisa o Valor total da nota fiscal para cálculo da proporcionalidade do frete
          If Select("T_VLRBRUTO") > 0
             T_VLRBRUTO->( dbCloseArea() )
          EndIf

          If lEntrada == .T.
             cSql := ""                               
             cSql := "SELECT F1_FILIAL ,"
             cSql += "       F1_DOC    ,"
             cSql += "       F1_SERIE  ,"
             cSql += "       F1_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF1")
             cSql += " WHERE F1_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Else
             cSql := ""                               
             cSql := "SELECT F2_FILIAL ,"
             cSql += "       F2_DOC    ,"
             cSql += "       F2_SERIE  ,"
             cSql += "       F2_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF2")
             cSql += " WHERE F2_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Endif             

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VLRBRUTO", .T., .T. )

          If T_VLRBRUTO->( EOF() )
             nBruto := 0
          Else
             nBruto := IIF(lEntrada == .T., T_VLRBRUTO->F1_VALBRUT, T_VLRBRUTO->F2_VALBRUT) 
          Endif

          nAcumulado := nAcumulado + nBruto

          kFilial := IIF(lEntrada == .T., T_VLRBRUTO->F1_FILIAL, T_VLRBRUTO->F2_FILIAL) 

          // Carrega o Array aNotas
          aAdd( aNotas, { cLegenda                         ,; && 01 - Legenda
                          Substr(aBrowse[nContar,01],26,09),; && 02 - Nº da Nota Fiscal
                          Substr(aBrowse[nContar,01],23,03),; && 03 - Série da Nota Fiscal
                          aBrowse[nContar,01]              ,; && 04 - Chave
                          cLegenda                         ,; && 05 - Legenda
                          cChave                           ,; && 06 - Nº da Chave da Nota Fiscal
                          cSerie                           ,; && 07 - Série da Nota Fiscal
                          cNumero                          ,; && 08 - Nº do CT-e
                          cModelo                          ,; && 09 - Modelo do CT-e
                          kFilial                          ,; && 10 - Código da Filial da Nota Fiscal
                          nBruto                           ,; && 11 - Valor Bruto da Nota Fiscal
                          0                                ,; && 12 - Total dos Documentos do CT-e
                          cEmissao                         ,; && 13 - Total dos Documentos do CT-e
                          cCodForne                        ,; && 14 - Código do Fornecedor
                          cLojForne                        ,; && 15 - Loja do Fornecedor
                          cEstForne                        }) && 16 - Estado (UF) do Fornecedor
       Endif

       // Em caso de informação de nota fiscal sem chave
       If Substr(aBrowse[nContar,01],01,07) == '<infNF'

          nContar := nContar + 4
          __Serie := aBrowse[nContar,01]
          nContar := nContar + 2          
          __NotaF := aBrowse[nContar,01]

          // Pesquisa a legenda da nota fiscal
          If Select("T_TABELA") > 0
             T_TABELA->( dbCloseArea() )
          EndIf

          If lEntrada == .T.
             cSql := ""                               
             cSql := "SELECT F1_FILIAL ,"
             cSql += "       F1_DOC    ,"
             cSql += "       F1_SERIE  ,"
             cSql += "       F1_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF1")
             cSql += " WHERE F1_SERIE = '" + Alltrim(__xSerie) + "'"
             cSql += "   AND F1_DOC   = '" + Alltrim(__NotaF) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Else       
          
             If Len(__NotaF) < 6
                __NotaF := Strzero(INT(VAL(__NotaF)),6)
             Endif   
          
             cSql := ""                               
             cSql := "SELECT F2_FILIAL ,"
             cSql += "       F2_DOC    ,"
             cSql += "       F2_SERIE  ,"
             cSql += "       F2_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF2")
             cSql += " WHERE F2_SERIE = '" + Alltrim(__xSerie) + "'"
             cSql += "   AND F2_DOC   = '" + Alltrim(__NotaF) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Endif             

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )
             
          If T_TABELA->( EOF() )
             If lAbertura == 1
                MsgAlert("Arquivo " + Alltrim(__Arquivo) + " sem nota fiscal de origem encontrada.")
                lDeuErro := .T.
             Else
                aAdd( aErro, { Alltrim(__Arquivo), "Arquivo sem nota fiscal de origem encontrada." })
                lDeuErro := .T.
             Endif                   
             lVoltar := .T.
             Exit
          Endif

          // Pesquisa o Valor total da nota fiscal para cálculo da proporcionalidade do frete
          If Select("T_VLRBRUTO") > 0
             T_VLRBRUTO->( dbCloseArea() )
          EndIf

          If lEntrada == .T.
             cSql := ""                               
             cSql := "SELECT F1_FILIAL ,"
             cSql += "       F1_DOC    ,"
             cSql += "       F1_SERIE  ,"
             cSql += "       F1_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF1")
             cSql += " WHERE F1_SERIE = '" + Alltrim(__xSerie) + "'"
             cSql += "   AND F1_DOC   = '" + Alltrim(__NotaF) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Else
             cSql := ""                               
             cSql := "SELECT F2_FILIAL ,"
             cSql += "       F2_DOC    ,"
             cSql += "       F2_SERIE  ,"
             cSql += "       F2_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF2")
             cSql += " WHERE F2_SERIE = '" + Alltrim(__xSerie) + "'"
             cSql += "   AND F2_DOC   = '" + Alltrim(__NotaF) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Endif             

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VLRBRUTO", .T., .T. )

          If T_VLRBRUTO->( EOF() )
             nBruto := 0
          Else
             nBruto := IIF(lEntrada == .T., T_VLRBRUTO->F1_VALBRUT, T_VLRBRUTO->F2_VALBRUT) 
          Endif

          nAcumulado := nAcumulado + nBruto

          kFilial := IIF(lEntrada == .T., T_VLRBRUTO->F1_FILIAL, T_VLRBRUTO->F2_FILIAL) 

          // Carrega o Array aNotas
          aAdd( aNotas, { cLegenda                         ,; && 01 - Legenda
                          Substr(aBrowse[nContar,01],26,09),; && 02 - Nº da Nota Fiscal
                          Substr(aBrowse[nContar,01],23,03),; && 03 - Série da Nota Fiscal
                          aBrowse[nContar,01]              ,; && 04 - Chave
                          cLegenda                         ,; && 05 - Legenda
                          cChave                           ,; && 06 - Nº da Chave da Nota Fiscal
                          cSerie                           ,; && 07 - Série da Nota Fiscal
                          cNumero                          ,; && 08 - Nº do CT-e
                          cModelo                          ,; && 09 - Modelo do CT-e
                          kFilial                          ,; && 10 - Código da Filial da Nota Fiscal
                          nBruto                           ,; && 11 - Valor Bruto da Nota Fiscal
                          0                                ,; && 12 - Total dos Documentos do CT-e
                          cEmissao                         ,; && 13 - Total dos Documentos do CT-e
                          cCodForne                        ,; && 14 - Código do Fornecedor
                          cLojForne                        ,; && 15 - Loja do Fornecedor
                          cEstForne                        }) && 16 - Estado (UF) do Fornecedor
       Endif

   Next nContar        

   // Envia para a leitura do próximo arquivos XML
   If lVoltar
      Return(.T.)
   Endif   

   // Captura os valores do Frete
   aFrete := {}

   _Total_Frete := ""
   _Frete_Peso  := ""
   _Frete_Valor := ""                              
   _Pedagio     := ""
   _Gris        := ""
   _TRT         := ""
   _Outros      := ""
   _TAS         := ""

   // Captura dados do Frete lidos do Conhecimento de Frete
   For nContar = 1 to Len(aBrowse)

       // Captura o Valor Total do Frete
       If Substr(aBrowse[nContar,01],01,07) == '<vPrest'
          nContar      := nContar + 2                   
          _Total_Frete := aBrowse[nContar,01]
          Loop
       Endif
          
       // Captura o valor do Frete Peso
       If Upper(Alltrim(aBrowse[nContar,01])) == 'FRETE PESO'
          nContar := nContar + 2
          _Frete_Peso  := aBrowse[nContar,01]
          Loop
       Endif

       // Captura o valor do Frete Valor       
       If Upper(Alltrim(aBrowse[nContar,01])) == 'FRETE VALOR'          
          nContar      := nContar + 2
          _Frete_Valor := aBrowse[nContar,01]
          Loop
       Endif
       
       // Captura o valor do Pedágio
       If Upper(Alltrim(aBrowse[nContar,01])) == 'PEDAGIO'
          nContar      := nContar + 2
          _Pedagio     := aBrowse[nContar,01]
          Loop
       Endif
       
       // Captura o valor do GRIS
       If Upper(Alltrim(aBrowse[nContar,01])) == 'GRIS'
          nContar      := nContar + 2                   
          _Gris        := aBrowse[nContar,01]
          Loop
       Endif   

       // Captura o valor do TRT
       If Upper(Alltrim(aBrowse[nContar,01])) == 'TRT'
          nContar      := nContar + 2
          _TRT         := aBrowse[nContar,01]
          Loop
       Endif

       // Captura o valor do OUTROS
       If Upper(Alltrim(aBrowse[nContar,01])) == 'OUTROS'
          nContar      := nContar + 2
          _Outros      := aBrowse[nContar,01]
          Loop
       Endif

       // Captura o valor do TAS
       If Upper(Alltrim(aBrowse[nContar,01])) == 'TAS'
          nContar      := nContar + 2
          _TAS         := aBrowse[nContar,01]
          Loop
       Endif
          
       // Leitura do Impostos do XML
       If Substr(aBrowse[nContar,01],01,04) == '<imp'

          nContar := nContar + 5

          If Substr(aBrowse[nContar,01],01,04) == '<vBC'
             nContar := nContar + 1                 
             _BaseICMSFrete  :=  aBrowse[nContar,01]
             nContar := nContar + 2
             _PercICMSFrete  :=  aBrowse[nContar,01]
             nContar := nContar + 2	
             _ValorICMSFrete :=  aBrowse[nContar,01]
          Else
             _BaseICMSFrete  :=  ""
             _PercICMSFrete  :=  ""
             _ValorICMSFrete :=  ""
          Endif
             
          Exit

       Endif

   Next nContar        

   // Carrega a variável com o total do frete
   cValfrete := val(_Total_Frete)

   // Carrega array aFrete para display dos valores que compoem o valor total do frete
   aAdd( aFrete, { _Frete_Peso  ,;
                   _Frete_Valor ,;
                   _Pedagio     ,;
                   _Gris        ,;
                   _TRT         ,;
                   _Outros      ,;
                   _TAS         ,;
                   _Total_Frete })

   // Calcula o Valor Proporcionalizado e atualiza no array aNotas
   For nContar = 1 to Len(aNotas)
       aNotas[nContar,12] := Round(((cValFrete * Round((Round((aNotas[nContar,11] / nAcumulado),2) * 100),2)) / 100),2)
   Next nContar    

   // Atualiza a tabela ZS9 com os dados do conhecimento de frete lido
   cSql     := ""
   nContar  := 0
   _nErro   := 0
   tStatus  := "E"
   lPodeGrv := .T.
   aFreteN  := {}
   _nErro   := 0

   // Verifica se conhecimento já está gravado. Se não estiver, o inclui. Se já estiver, deleta para nova gravação.
   If Select("T_JAEXISTE") > 0
      T_JAEXISTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS9_CHAV"
// cSql += "  FROM " + RetSqlName("ZS9")
   cSql += "  FROM ZS9" + Alltrim(__Empresa) + "0 (Nolock)"
   cSql += " WHERE ZS9_CHAV   = '" + Alltrim(xChave) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

   If T_JAEXISTE->( EOF() )
      lJaGravado := .F.
   Else
      lJaGravado := .T.      
   Endif
      
   // Se conhecimento de transporte já cadastrado, verifica se o documento de entrada está gravado
   If lJaGravado
   Else

      // Grava os dados na tabela ZS9
      For nContar = 1 to Len(aNotas)

          // Atualiza a Tabela de CTE
          dbSelectArea("ZS9")
          RecLock("ZS9",.T.)
          ZS9_FILIAL := "  "

          If lEntrada
             ZS9_TIPO := "E"
          Endif
       
          If lSaida
             ZS9_TIPO := "S"
          Endif
          
          ZS9_DLEI   := Date()
          ZS9_HLEI   := Time()
          ZS9_ULEI   := cUserName
          ZS9_CHAV   := xChave
          ZS9_CTRA   := cCodTransp
          ZS9_SERI   := cSerie  
          ZS9_NUME   := cNumero 
          ZS9_MODE   := cModelo
          ZS9_CFOR   := cCodFor
          ZS9_LFOR   := cLojFor
          ZS9_CDES   := cCodCli
          ZS9_LDES   := cLojCli
   
          If lEntrada
             ZS9_NFIS   := ALLTRIM(STR(INT(VAL(aNotas[nContar,02]))))
             ZS9_SFIS   := ALLTRIM(STR(INT(VAL(aNotas[nContar,03]))))
          Else
             ZS9_NFIS   := Substr(aNotas[nContar,02],04,06)
             ZS9_SFIS   := ALLTRIM(STR(INT(VAL(aNotas[nContar,03]))))
          Endif

          ZS9_CFIS   := aNotas[nContar,04]
          ZS9_LEGE   := aNotas[nContar,01]
          ZS9_STAT   := tStatus
          ZS9_DATA   := cdataCTE
          ZS9_VFRE   := cValFrete
          ZS9_TNOT   := nAcumulado
          ZS9_FREN   := aNotas[nContar,12]
          ZS9_CGCR   := cCGCFor
          ZS9_CGCD   := cCgcDest
          ZS9_CGCT   := cCnpjt
          MsUnLock()

          // Grava os dados na nota fiscal de origem
          If lEntrada = .T.

             cSql := ""
             cSql := "UPDATE " + RetSqlName("SF1")
             cSql += "   SET"
             cSql += "   F1_SERF = '" + Alltrim(aNotas[nContar,07]) + "',"
             cSql += "   F1_NUMF = '" + Alltrim(aNotas[nContar,08]) + "',"
             cSql += "   F1_MODF = '" + Alltrim(aNotas[nContar,09]) + "',"
             cSql += "   F1_CHAF = '" + Alltrim(xChave)             + "',"
             cSql += "   F1_VALF =  " + Alltrim(str(aNotas[nContar,12],10,02))
             cSql += " WHERE F1_FILIAL = '" + Alltrim(aNotas[nContar,10]) + "'"
             cSql += "   AND F1_CHVNFE = '" + Alltrim(aNotas[nContar,04]) + "'"
             
             _nErro := TcSqlExec(cSql) 
        
             If TCSQLExec(cSql) < 0 
                alert(TCSQLERROR())
                Return(.T.)
             Endif

          Else

             cSql := ""
             cSql := "UPDATE " + RetSqlName("SF2")
             cSql += "   SET"
             cSql += "   F2_SERF = '" + Alltrim(aNotas[nContar,07]) + "',"
             cSql += "   F2_NUMF = '" + Alltrim(aNotas[nContar,08]) + "',"
             cSql += "   F2_MODF = '" + Alltrim(aNotas[nContar,09]) + "',"
             cSql += "   F2_CHAF = '" + Alltrim(xChave)             + "',"
             cSql += "   F2_VALF =  " + Alltrim(str(aNotas[nContar,12],10,02))
             cSql += " WHERE F2_FILIAL = '" + Alltrim(aNotas[nContar,10]) + "'"
             cSql += "   AND F2_CHVNFE = '" + Alltrim(aNotas[nContar,04]) + "'"
             
             _nErro := TcSqlExec(cSql) 

             If TCSQLExec(cSql) < 0 
                alert(TCSQLERROR())
                Return(.T.)
             Endif

          Endif   

          _nErro := TcSqlExec(cSql) 

          If TCSQLExec(cSql) < 0 
             alert(TCSQLERROR())
             Return(.T.)
          Endif

      Next nContar
      
   Endif

   // Grava o conhecimento de transporte no documento de entrada do Sistema
   SALVACTE()

Return(.T.)

// Função que salva os dados do CTE como documento de entrada do Sistema.
Static Function SALVACTE()

   Local cSql          := ""
   Local nContar       := 0
   Local vBIcmsST      := 0
   Local vVIcmsST      := 0
   Local nDuplicatas   := 0
   Local nContar       := 0
   Local nVlrFrete     := 0

   Private aCabec      := {}
   Private aItens      := {}
   Private aPagar      := {}
   Private lMsErroAuto := .F.  

   Private aCustos     := {}

   // Envia para a função que solicita o rateio por centro de custo
   If lAbertura == 1
      ACCUSTO()
   Else

      // +------------------------------------------------+
      // |Verifica o nota fiscal conforme regra abaixo:   |
      // |------------------------------------------------|
      // | Filial |  CC Venda | CC Compra | Transferência |
      // |--------|-----------|-----------|---------------|
      // |   01   |     030   |    070    |     070       |
      // |   02   |     230   |    270    |     270       |
      // |   03   |     330   |    370    |     370       |
      // |   04   |     450   |    450    |     450       |
      // +------------------------------------------------+

      // Psquisa a vhave da nota fiscal para carrega o centro de custo correspondente
      If Select("T_CHAVENFE") > 0
         T_CHAVENFE->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT F1_FILIAL,"
      cSql += "       F1_CHVNFE "
      cSql += "  FROM " + RetSqlName("SF1")
      cSql += " WHERE F1_CHVNFE  = '" + Alltrim(aNotas[01,04]) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAVENFE", .T., .T. )

      If T_CHAVENFE->( EOF() )
      
         If Select("T_CHAVENFS") > 0
            T_CHAVENFS->( dbCloseArea() )
         EndIf
      
         cSql := ""
         cSql := "SELECT F2_FILIAL,"
         cSql += "       F2_CHVNFE "
         cSql += "  FROM " + RetSqlName("SF2")
         cSql += " WHERE F2_CHVNFE  = '" + Alltrim(aNotas[01,04]) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAVENFS", .T., .T. )

         If T_CHAVENFS->( EOF() )
            aAdd( aCustos, { 100, CENTRO_CUS, "CENTRO DE CUSTO PADRAO" } )
         Else
            Do Case
               Case T_CHAVENFS->F2_FILIAL == "01"
                    aAdd( aCustos, { 100, "030", "VENDAS" } )
               Case T_CHAVENFS->F2_FILIAL == "02"
                    aAdd( aCustos, { 100, "230", "VENDAS" } )
               Case T_CHAVENFS->F2_FILIAL == "03"
                    aAdd( aCustos, { 100, "330", "VENDAS" } )
               Case T_CHAVENFS->F2_FILIAL == "04"
                    aAdd( aCustos, { 100, "450", "SUPRIMENTOS" } )
            EndCase
         Endif
      Else
         Do Case
            Case T_CHAVENFE->F1_FILIAL == "01"
                 aAdd( aCustos, { 100, "070", "LOGISTICA" } )
            Case T_CHAVENFE->F1_FILIAL == "02"
                 aAdd( aCustos, { 100, "270", "LOGISTICA" } )
            Case T_CHAVENFE->F1_FILIAL == "03"
                 aAdd( aCustos, { 100, "370", "LOGISTICA" } )
            Case T_CHAVENFE->F1_FILIAL == "04"
                 aAdd( aCustos, { 100, "450", "SUPRIMENTOS" } )
         EndCase
      Endif
   Endif

   If Len(aCustos) == 0

      If lAbertura == 1
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Rateio por Centro de Custo não informado." + chr(13) + chr(10) + "Lançamento será gravado com o centro de custo padrão.")
         lDeuErro := .T.
      Else
         aAdd( aErro, { "", "Atenção! Rateio por Centro de Custo não informado. Lançamento gravado com o centro de custo padrão." })
         lDeuErro := .T.
      Endif
         
      aAdd( aCustos, { 100, CENTRO_CUS, "CENTRO DE CUSTO PADRAO" } )

   Endif   

   // Prepara dados para inclusão automática
   PRIVATE aRotina := {{"Pesquisar"   , "AxPesqui"   , 0, 1},;
              		   {"Visualizar"  , "A103NFiscal", 0, 2},; 
		               {"Incluir"     , "A103NFiscal", 0, 3},; 
   		               { "Classificar", "A103NFiscal", 0, 4},; 
		               {"Retornar"    , "A103Devol"  , 0, 3},; 
		               {"Excluir"     , "A103NFiscal", 3, 5},; 
		               {"Imprimir"    , "A103Impri"  , 0, 4},; 
		               {"Legenda"     , "A103Legenda", 0, 2} } 

   // Verifica se conhecimento de transporte já está cadastrado. Se sim, lê o próximo conhecimento marcado.
   If Select("T_CADASTRO") > 0
      T_CADASTRO->( dbCloseArea() )
   EndIf

   cSql := ""                               
   cSql := "SELECT F1_FILIAL ,"
   cSql += "       F1_DOC    ,"
   cSql += "       F1_SERIE  ,"
   cSql += "       F1_VALBRUT "
   cSql += "  FROM " + RetSqlName("SF1")
   cSql += " WHERE F1_FILIAL = '" + Alltrim(cFilAnt)       + "'"
   cSql += "   AND F1_DOC    = '" + Alltrim(aNotas[01,08]) + "'"
   cSql += "   AND F1_SERIE  = '" + Alltrim(aNotas[01,07]) + "'"
   cSql += "   AND D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADASTRO", .T., .T. )

   If !T_CADASTRO->( EOF() )
      Return(.T.)
   Endif

   // Cria o Array do cabeçalho da nota fiscal de entrada
   XXX_Emissao := Ctod(Substr(aNotas[01,13],09,02) + "/" + Substr(aNotas[01,13],06,02) + "/" + Substr(aNotas[01,13],01,04))

   // Acumula o valor do frete para gravação
   For nContar = 1 to Len(aFrete)
       nVlrFrete := nVlrFrete + Val(aFrete[nContar,08])
   Next nContar
   
   // Carrega o array aCabec
   aCabec := {{'F1_TIPO'   , 'N'                                        ,NIL},;
    		  {'F1_FORMUL' , 'N' 		                                ,NIL},;
    		  {'F1_FILIAL' , __FilGrava                                 ,NIL},;
    		  {'F1_DOC'    , aNotas[01,08]                              ,NIL},;
		      {'F1_SERIE'  , aNotas[01,07]                              ,NIL},;
		      {'F1_ESPECIE', 'CTE'                                      ,NIL},;
		      {'F1_EMISSAO', XXX_Emissao                                ,NIL},;
		      {'F1_FORNECE', aNotas[01,14]                              ,NIL},;
		      {'F1_LOJA'   , aNotas[01,15]                              ,NIL},;
		      {'F1_CHVNFE' , xChave                                     ,NIL},;
		      {'F1_EST'    , aNotas[01,16]                              ,NIL},;
		      {'F1_VALMERC', nVlrFrete                                  ,NIL},;
		      {'F1_VALBRUT', nVlrFrete /*+ Val(_ValorICmsFrete)*/       ,NIL},;
		      {'F1_FRETE'  , 0                                          ,NIL},;		      		      
		      {'F1_MOEDA'  , 1                                          ,NIL},;		      		      
		      {'F1_PREFIXO', aNotas[01,07]                              ,NIL},;
		      {'F1_STATUS' , 'A'                                        ,NIL},;		      		      
		      {'F1_COND'   , CONDI_DCTE                                 ,NIL} }

   // Cria  o array aItens para gravação da tabela SD1 - Ítens do Documento de Entrada
   aAdd(aItens,{{'D1_COD'    , IIF(lEntrada == .T., PRODU_PCTE, SAIDA_PCTE)           ,NIL},;   // 01
                {'D1_FILIAL' , __FilGrava                                             ,NIL},;   // 02
	   	        {'D1_TIPO'   , 'N'                  	                              ,NIL},;   // 03
	   	        {'D1_RATEIO' , '1'                  	                              ,NIL},;   // 03
	   	        {'D1_ITEM'   , '0001'                  	                              ,NIL},;   // 03
	     	    {'D1_UM'	 , 'UN'                 	                              ,NIL},;   // 04
		        {'D1_QUANT'  , 1                                                      ,NIL},;   // 05
		        {'D1_VUNIT'  , nVlrFrete                                              ,NIL},;   // 06
    		    {'D1_TOTAL'  , nVlrFrete                                              ,NIL},;   // 07 
    		    {'D1_TES'    , IIF(Val(_ValorIcmsFrete) == 0, SICMS_SCTE, CICMS_CCTE) ,NIL},;   // 08
	   	        {'D1_EMISSAO', XXX_Emissao                                            ,Nil},;   // 09 
   	            {'D1_DOC'    , aNotas[01,08]                                          ,Nil},;   // 10 
    	        {'D1_SERIE'  , aNotas[01,07]                                          ,Nil},;   // 11 
	    	    {'D1_FORNECE', aNotas[01,14]                                          ,Nil},;   // 12
	    	    {'D1_LOJA'   , aNotas[01,15]                                          ,Nil}})   // 13   	         

   // Grava os dados da Pré-nota de entrada
   MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCabec, aItens, 3)     

   If lMsErroAuto
      MostraErro()
      If lAbertura == 1
         MsgAlert("Erro na inclusão dos dados do XML.")
         lDeuErro := .T.
      Else   
         aAdd( aErro, {"", "Erro na inclusão dos dados do XML." })         
         lDeuErro := .T.
      Endif   
      lRetErro := .F.
      lOndErro := 1
      Return .T.
   Else
      lRetErro := .T.
      lOndErro := 1
      // Chama o programa da pré-nota
      // A103NFiscal("SF1",,4)
   EndIf

   // Realiza a inclusão do contas a pagar
//   aPagar:= { { "E2_PREFIXO"  , "CTE"             , NIL },;
//              { "E2_NUM"      , aNotas[01,08]     , NIL },;
//              { "E2_TIPO"     , "NF"              , NIL },;
//              { "E2_NATUREZ"  , NATUR_EZA         , NIL },;
//              { "E2_FORNECE"  , aNotas[01,14]     , NIL },;
//              { "E2_LOJA"     , aNotas[01,15]     , NIL },;
//              { "E2_EMISSAO"  , XXX_Emissao       , NIL },;
//              { "E2_VENCTO"   , XXX_Emissao       , NIL },;
//              { "E2_VENCREA"  , XXX_Emissao       , NIL },;
//              { "E2_VALOR"    , nVlrFrete         , NIL } }
 
//   MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aPagar,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
 
//   If lMsErroAuto
//       MostraErro()
//       lReterro := .F.
//       lOndErro := 2
//   Else
//       lReterro := .T.
//       lOndErro := 2
//   Endif

   // Garva o rateio por centro de custo
   For nContar = 1 to Len(aCustos)
   
       If aCustos[nContar,01] == 0
          Loop
       Endif

//     aArea := GetArea()

       DbSelectArea("SDE")
       DbSetOrder(1)
       RecLock("SDE",.T.)
       SDE->DE_FILIAL  := cFilAnt
       SDE->DE_DOC     := aNotas[01,08]
       SDE->DE_SERIE   := aNotas[01,07]
       SDE->DE_FORNECE := aNotas[01,14]
       SDE->DE_LOJA    := aNotas[01,15]
       SDE->DE_ITEMNF  := Strzero(nContar,4)
       SDE->DE_ITEM    := Strzero(nContar,2)
       SDE->DE_PERC    := aCustos[nContar,01]
       SDE->DE_CC      := aCustos[nContar,02]
       SDE->DE_CUSTO1  := Round(((nVlrFrete * aCustos[nContar,01]) / 100),2)
       MsUnLock()              
   
   Next nContar

Return(.T.)

// Função que abre a janela de informação do centro de custo do CTE
Static Function ACCUSTO()

   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Private cPerc1   := 0
   Private cPerc2   := 0
   Private cPerc3   := 0
   Private cPerc4   := 0
   Private cPerc5   := 0

   Private cCusto1  := Space(09)
   Private cCusto2  := Space(09)
   Private cCusto3  := Space(09)
   Private cCusto4  := Space(09)
   Private cCusto5  := Space(09)

   Private cDescri1 := Space(60)
   Private cDescri2 := Space(60)
   Private cDescri3 := Space(60)
   Private cDescri4 := Space(60)
   Private cDescri5 := Space(60)

   Private oGet1
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9

   Private oDlgC

   DEFINE MSDIALOG oDlgC TITLE "Informação Centro de Custo" FROM C(178),C(181) TO C(444),C(665) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(235),C(001) PIXEL OF oDlgC

   @ C(039),C(005) Say "Perc."   Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(039),C(032) Say "C.Custo" Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(049),C(005) MsGet oGet1  Var cPerc1   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(049),C(033) MsGet oGet2  Var cCusto1  Size C(023),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto1, 1))
   @ C(049),C(067) MsGet oGet3  Var cDescri1 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(062),C(005) MsGet oGet4  Var cPerc2   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(062),C(033) MsGet oGet8  Var cCusto2  Size C(023),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto2, 2))
   @ C(062),C(067) MsGet oGet12 Var cDescri2 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(075),C(005) MsGet oGet5  Var cPerc3   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(075),C(033) MsGet oGet9  Var cCusto3  Size C(023),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto3, 3))
   @ C(075),C(067) MsGet oGet13 Var cDescri3 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(088),C(005) MsGet oGet6  Var cPerc4   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(088),C(033) MsGet oGet10 Var cCusto4  Size C(023),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto4, 4))
   @ C(088),C(067) MsGet oGet14 Var cDescri4 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(101),C(005) MsGet oGet7  Var cPerc5   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(101),C(033) MsGet oGet11 Var cCusto5  Size C(023),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto5, 5))
   @ C(101),C(067) MsGet oGet15 Var cDescri5 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba

   @ C(115),C(160) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgC ACTION( ConfRateio() )
   @ C(115),C(199) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgC ACTION( ODlgC:End() )

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que pesquisa o centro de custo informado
Static Function TRZCTT(_Codigo, _Tipo)

   Local cSql := ""

   If Empty(Alltrim(_Codigo))
      Return(.T.)
   Endif
      
   If Select("T_CUSTO") > 0
      T_CUSTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CTT_CUSTO,"
   cSql += "       CTT_DESC01"
   cSql += "  FROM " + RetSqlName("CTT")
   cSql += " WHERE CTT_BLOQ  <> '1'"
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += "   AND CTT_CUSTO  = '" + Alltrim(_Codigo) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSTO", .T., .T. )

   If T_CUSTO->( EOF() )
      MsgAlert("Centro de Custo informado não cadastrado.")
      Return(.T.)
   Endif
   
   Do Case
      Case _Tipo == 1
           cDescri1 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 2
           cDescri2 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 3
           cDescri3 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 4
           cDescri4 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 5
           cDescri5 := T_CUSTO->CTT_DESC01   
   EndCase
   
Return(.T.)

// Função que confere os centro de custos informados
Static Function ConfRateio()

   If (cPerc1 + cPerc2 + cPerc3 + cPerc4 + cPerc5) == 0
      MsgAlert("Nenhum rateio foi informado. Verifique!")
      Return(.T.)
   Endif

   If (cPerc1 + cPerc2 + cPerc3 + cPerc4 + cPerc5) <> 100
      MsgAlert("Percentual de rateio por centro de custo inconsistente. Verifique!")
      Return(.T.)
   Endif
      
   If cPerc1 <> 0
      If Empty(Alltrim(cCusto1))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif
         
   If cPerc2 <> 0
      If Empty(Alltrim(cCusto2))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If cPerc3 <> 0
      If Empty(Alltrim(cCusto3))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If cPerc4 <> 0
      If Empty(Alltrim(cCusto4))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If cPerc5 <> 0
      If Empty(Alltrim(cCusto5))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto1))
      If cPerc1 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif
      
   If !Empty(Alltrim(cCusto2))
      If cPerc2 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto3))
      If cPerc3 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto4))
      If cPerc4 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto5))
      If cPerc5 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   aCustos := {}
   
   aAdd( aCustos, { cPerc1, cCusto1, cDescri1 } )
   aAdd( aCustos, { cPerc2, cCusto2, cDescri2 } )
   aAdd( aCustos, { cPerc3, cCusto3, cDescri3 } )
   aAdd( aCustos, { cPerc4, cCusto4, cDescri4 } )
   aAdd( aCustos, { cPerc5, cCusto5, cDescri5 } )            

   oDLgc:End()

Return(.T.)

// ############################################################
// Função que abre a janela da importação agrupada de CTE's  ##
// ############################################################
Static Function ImpAgrupada()

   Local cSql         := ""
   Local lChumba      := .F.

   Private cCaminho   := "S:\Operacoes\Financeiro\NFE\XML\ARQUIVO_XML NOVO"
   Private cLocalizar := Space(50)
   Private aStatus    := {"01 - A Importar", "02 - Importados", "03 - Ambos"}
   Private cMemo1     := ""
   Private cMemo2     := ""

   Private oGet1
   Private oGet2
   Private oMemo1
   Private oMemo2
   Private cStatus

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgAgr

   Private aLista := {}
   Private oLista

   // Verifica se parâmetros estão criados para ser rodado o programa
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_PCTE," && Código do produto para cte's ref, a notas fiscais de entrada
   cSql += "       ZZ4_PCT1," && Código do produto para cte's ref, a notas fiscais de saída
   cSql += "       ZZ4_DCTE," && Condição de Pagamento para inclusão dos conhecimentos de transportes
   cSql += "       ZZ4_CCTE," && TES para conhecimentos de transportes com ICMS
   cSql += "       ZZ4_SCTE," && TES para conhecimentos de transportes sem ICMS
   cSql += "       ZZ4_DXML," && Indica o diretório onde estão os XML's a serem carregados
   cSql += "       ZZ4_NATC," && Código da Natureza a ser utilizada para o Contas a Pagar
   cSql += "       ZZ4_CCUS " && Código do Centro de Custo utilizado em caso de não informação do mesmo
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não existem parâmetros criados para este programa." + chr(13) + chr(10) + "Entre em contato com o administrador do sistema.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCTE))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código do produto Frete (Entrada) não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCT1))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código do produto Frete (Saída) não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_DCTE))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Condição de Pagamento para Frete não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso."  + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_CCTE))
      MsgAlert("Atenção!"  + chr(13) + chr(10) + chr(13) + chr(10) + "TES de frete com ICMS não parametrizada." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_SCTE))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "TES de frete sem ICMS não parametrizada." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_DXML))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Diretório a ser utilizado para importação não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_NATC))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Código da Natureza para importação não parametrizada." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_CCUS))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Centro de Custo padrão para importação não parametrizado." + chr(13) + chr(10) + "Informe o Administrador do Sistema sobre este caso." + chr(13) + chr(10) + "Procedimento não será executado sem esta parametrização.")
      Return(.T.)
   Endif

   // Carrega variáveis de parâmetros
   PRODU_PCTE := T_PARAMETROS->ZZ4_PCTE
   SAIDA_PCTE := T_PARAMETROS->ZZ4_PCT1
   CONDI_DCTE := T_PARAMETROS->ZZ4_DCTE
   CICMS_CCTE := T_PARAMETROS->ZZ4_CCTE
   SICMS_SCTE := T_PARAMETROS->ZZ4_SCTE
   DIRET_ORIO := T_PARAMETROS->ZZ4_DXML
   NATUR_EZA  := T_PARAMETROS->ZZ4_NATC
   CENTRO_CUS := T_PARAMETROS->ZZ4_CCUS

   cCaminho := DIRET_ORIO

   lAbertura             := 2
   
   // Desenha a janela para visualização dos CTE's
   DEFINE MSDIALOG oDlgAgr TITLE "Importação de CTE's" FROM C(178),C(181) TO C(622),C(958) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlgAgr

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(381),C(001) PIXEL OF oDlgAgr
   @ C(195),C(003) GET oMemo2 Var cMemo2 MEMO Size C(381),C(001) PIXEL OF oDlgAgr

   @ C(040),C(005) Say "Caminho de leitura dos arquivos CTE's"        Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlgAgr
   @ C(062),C(005) Say "Relação de CTE's disponíveis para importação" Size C(113),C(008) COLOR CLR_BLACK PIXEL OF oDlgAgr
   @ C(040),C(262) Say "Status a Pesquisar"                           Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgAgr
   @ C(199),C(005) Say "Localizar Chave para marcação"                Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlgAgr

   @ C(049),C(005) MsGet    oGet1   Var   cCaminho Size C(248),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAgr && When lChumba
   @ C(049),C(262) ComboBox cStatus Items aStatus  Size C(079),C(010)                              PIXEL OF oDlgAgr

   @ C(048),C(347) Button "Pesquisar"              Size C(037),C(012) PIXEL OF oDlgAgr ACTION( CarregaaLista() )

   @ C(208),C(005) MsGet oGet2 Var cLocalizar Size C(103),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAgr

   @ C(207),C(114) Button "Localizar"       Size C(037),C(012) PIXEL OF oDlgAgr ACTION( Fun_Localiza() )
   @ C(207),C(173) Button "Marcar Todos"    Size C(047),C(012) PIXEL OF oDlgAgr ACTION( MrcDmc(1) )
   @ C(207),C(225) Button "Desmarcar Todos" Size C(047),C(012) PIXEL OF oDlgAgr ACTION( MrcDmc(2) )
   @ C(207),C(288) Button "Importar CTE's"  Size C(044),C(012) PIXEL OF oDlgAgr ACTION( ImpCTEMrc() )
   @ C(207),C(347) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgAgr ACTION( oDlgAgr:End() )

   aAdd( aLista, { .F., "" } )

   // Lista com os produtos do pedido selecionado
   @ 090,006 LISTBOX oLista FIELDS HEADER "M", "Relação de CTE's" PIXEL SIZE 485,155 OF oDlgAgr ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   
   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02]}}

   ACTIVATE MSDIALOG oDlgAgr CENTERED 

Return(.T.)

// #######################################################
// Função que localiza e marca a chave do CTE informado ##
// #######################################################
Static Function Fun_Localiza()
                            
   Local nContar := 0          
   Local lAchei  := .F.
   
   If Empty(Alltrim(cLocalizar))
      Return(.T.)
   Endif
   
   If Len(Alltrim(cLocalizar)) < 44
      MsgAlert("Chave informada é inválida.")
      Return(.T.)
   Endif
   
   For nContar = 1 to Len(aLista)
   
       If AT(Alltrim(cLocalizar), aLista[nContar,02]) <> 0
          lAchei := .T.
          aLista[nContar,01] := .T.
          Exit
       Endif
       
   Next nContar

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02]}}

   If lAchei == .T.
      Msgalert("Chave localizada e marcada.")
   Else
      Msgalert("Chave não localizada.")   
   Endif   

   cLocalizar := Space(50)
   oGet2:Refresh()

Return(.T.)          

// Função que carrega o array aLista
Static Function CarregaaLista()

   Local lChumba   := .F.
   Local nContar   := 0
   Local aFiles    := {} // O array receberá os nomes dos arquivos e do diretório
   Local aSizes    := {} // O array receberá os tamanhos dos arquivos e do diretorio
   Local nRegua    := 0
   Local cAvancada := Space(250)
   Local cMemo1	   := ""
   Local oGet1
   Local oMemo1

   // Inicializa o array que receberá o nome do arquivo a ser importado
   aLista := {}

   // Carrega os arquivos do diretório de XML's
   ADir(Alltrim(DIRET_ORIO) + "*.*", aFiles, aSizes)

   // Carrega o array aArquivos para display no List
   nRegua := 0
   nCount := Len( aFiles )

   For nX := 1 to nCount  
 
       Do Case
          Case Substr(cStatus,01,02) == "01"
               If Substr(aFiles[nX],01,01) == "#"
                  Loop
               Endif
          Case Substr(cStatus,01,02) == "02"
               If Substr(aFiles[nX],01,01) <> "#"
                  Loop
               Endif
       EndCase               

       If U_P_OCCURS(UPPER(aFiles[nX]), "CTE", 1) <> 0 .Or. U_P_OCCURS(UPPER(aFiles[nX]), "CT-E", 1) <> 0

          If U_P_OCCURS(UPPER(aFiles[nX]), "CANC", 1) <> 0
             Loop
          Endif

          cString := U_P_CORTA(aFiles[nX], ".", 1)

          aAdd( aLista, { .F., aFiles[nX] } )
          
       Endif   

   Next nX

   If Len(aLista) == 0
      aAdd( aLista, { .F., "" } )
   Endif
      
   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02]}}

Return(.T.)

// Função que carrega o array aLista
Static Function MrcDmc(_Botao)

   Local nContar := 0

   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(_Botao == 1, .T., .F.)
   Next nContar
   
Return(.T.)          

// Função que realiza a importação dos CTE's marcados no array aLista
Static Function ImpCTEMrc()

   Local nContar  := 0
   Local lMarcado := .F.

   aErro := {}

   lDeuErro := .F. 

   // Verifica se existe pelo menos um registro marcado para importação
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro foi marcado para ser importado. Verifique!")
      Return(.T.)
   Endif

   // Realiza a importação dos dados da Chave do CTE informado
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif
       
       lDeuErro := .F.
       
       // Função de importação dos dadso do CTE informado
       I_CTE_FRETE(aLista[nContar,2])

       // Renomea o arquivo para que este não seja mais utilizado
       If lDeuErro == .T.
       Else
          If Substr(aLista[nContar,2],01,01) <> "#"
             nStatus1 := frename(Alltrim(DIRET_ORIO) + Alltrim(aLista[nContar,2]), Alltrim(DIRET_ORIO) + "#" + Alltrim(aLista[nContar,2]) ) 
          Else
             nStatus1 := 0
          Endif   

          IF nStatus1 == -1
             aAdd( aErro, { Alltrim(aLista[nContar,02]), "Atenção! Houve falha na operação: FError " + str(ferror(),4) })
             lDeuErro := .T.
          Else
             aAdd( aErro, { Alltrim(aLista[nContar,02]), "Arquivo XML processado com sucesso." } )
             lDeuErro := .T.
          Endif   
       Endif             

   Next nContar

   // Envia para a função que mostra o status da importação dos CTE's
   StatusCTE()

   aLista := {}
   aAdd( aLista, { .F., "" } )
   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02]}}

Return(.T.)

// Tela que mostra o status da importação dos CTE's
Static Function StatusCTE()

   Local nContar := 0
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

// Private oErro

   Private oDlgStatus

   cString := ""
  
   For nContar = 1 to Len(aErro)
       cString += aErro[nContar,01] + " - " + Alltrim(aErro[nContar,02]) + chr(13) + chr(10)
   Next nContar        

   // Desenha a tela para visualização dos Status da Importação dos CTE's
   DEFINE MSDIALOG oDlgStatus TITLE "Importação de CTE's" FROM C(178),C(181) TO C(622),C(958) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlgStatus

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(381),C(001) PIXEL OF oDlgStatus

   @ C(039),C(005) Say "Status da Importação dos CTE's" Size C(113),C(008) COLOR CLR_BLACK PIXEL OF oDlgStatus

   @ C(048),C(005) GET oMemo2 Var cString MEMO Size C(379),C(154) PIXEL OF oDlgStatus

   @ C(206),C(347) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgStatus ACTION( oDlgStatus:End() )

   ACTIVATE MSDIALOG oDlgStatus CENTERED 

Return(.T.)
