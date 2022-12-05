#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "APWEBSRV.CH" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM589.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##                                         
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 27/06/2017                                                          ##
// Objetivo..: Programa que realiza a importação de NF de Serviço                  ##
// Parâmetros: Sem Parâmetros                                                      ##
// ##################################################################################

User Function AUTOM589()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private aStatus	    := {"A - A Importar", "I - Importados", "T - Todas"}
   Private cComboBx1
   Private cPesquisar   := Space(60)
   Private oGet1

   Private cCaminho     := "S:\Financeiro\NFE\XML\NFServicos\"

// Private cCaminho     := "D:\Protheus11\"

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   Private oDlg

   U_AUTOM628("AUTOM589")

   DEFINE MSDIALOG oDlg TITLE "Parametrizador XML - Nota Fiscal de Serviço" FROM C(178),C(181) TO C(571),C(963) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Pesquisar arquivos contendo a expressão"      Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(276) Say "Status de Visualização"                       Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Selecione o(s) XML(s) a ser(em) importado(s)" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet    oGet1     Var   cPesquisar  Size C(264),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(276) ComboBox cComboBx1 Items aStatus     Size C(069),C(010)                              PIXEL OF oDlg

   @ C(045),C(351) Button "Pesquisar"                     Size C(035),C(009) PIXEL OF oDlg ACTION( CargaListaNFS() )
   @ C(179),C(005) Button "Marca Todos"                   Size C(050),C(012) PIXEL OF oDlg ACTION( xMrcDmc(1) )
   @ C(179),C(056) Button "Desmarca Todos"                Size C(050),C(012) PIXEL OF oDlg ACTION( xMrcDmc(2) )
   @ C(179),C(154) Button "Parametrizador de Prefeituras" Size C(083),C(012) PIXEL OF oDlg ACTION( U_AUTOM588() )
   @ C(179),C(310) Button "Importar"                      Size C(037),C(012) PIXEL OF oDlg ACTION( ImpNFServico() )
   @ C(179),C(349) Button "Voltar"                        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "" })

   @ 084,005 LISTBOX oLista FIELDS HEADER "M", "Documentos" PIXEL SIZE 492,138 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                           aLista[oLista:nAt,02]         }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################################
// Função que carrega a lista com os documentos a serem visualizados ##
// ####################################################################
Static Function CargaListaNFS()

   Local lChumba   := .F.
   Local nContar   := 0
   Local aFiles    := {} // O array receberá os nomes dos arquivos e do diretório
   Local aSizes    := {} // O array receberá os tamanhos dos arquivos e do diretorio
   Local nRegua    := 0
   Local cAvancada := Space(250)
   Local cMemo1	   := ""
   Local oGet1
   Local oMemo1

   // ####################################################################
   // Inicializa o array que receberá o nome do arquivo a ser importado ##
   // ####################################################################
   aLista := {}

   // ############################################
   // Carrega os arquivos do diretório de XML's ##
   // ############################################
   ADir(Alltrim(cCaminho) + "*.XML", aFiles, aSizes)

   // #################################################
   // Carrega o array aArquivos para display no List ##
   // #################################################
   nRegua := 0
   nCount := Len( aFiles )

   For nX := 1 to nCount  
 
       // ######################################################
       // Se informado parte de nome de arquivo para pesquisa ##
       // ###################################################### 
       If Empty(Alltrim(cPesquisar))
       Else
          If U_P_OCCURS(UPPER(aFiles[nX]), Alltrim(Upper(cPesquisar)), 1) == 0
             Loop
          Endif                
       Endif   

       Do Case
          Case Substr(cComboBx1,01,01) == "A"
               If Substr(aFiles[nX],01,01) == "#"
                  Loop
               Endif
          Case Substr(cComboBx1,01,01) == "I"
               If Substr(aFiles[nX],01,01) <> "#"
                  Loop
               Endif
       EndCase               

       cString := U_P_CORTA(aFiles[nX], ".", 1)

       aAdd( aLista, { .F., aFiles[nX] } )
          
   Next nX

   If Len(aLista) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aLista, { .F., "" } )
   Endif
      
   oLista:SetArray( aLista )

   oLista:bLine := {|| {Iif(aLista[oLista:nAt,01],oOk,oNo), aLista[oLista:nAt,02]}}

Return(.T.)

// ####################################
// Função que carrega o array aLista ##
// ####################################
Static Function xMrcDmc(_Botao)

   Local nContar := 0

   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(_Botao == 1, .T., .F.)
   Next nContar
   
Return(.T.)

// #################################################################
// Função que realiza a importação das notas fiscais selecionadas ##
// #################################################################
Static Function ImpNFServico()

   MsgRun("Aguarde! Importando XML(s) selecionado(s) ...", "Importação NF Eletrônica de Serviço",{|| xImpNFServico() })

Return(.T.)

// #################################################################
// Função que realiza a importação das notas fiscais selecionadas ##
// #################################################################
Static Function xImpNFServico()

   Local nContar       := 0
   Local nPercorre     := 0
   Local nLimpa        := 0
   Local lMarcadas     := .F.
   Local cAgravar      := ""
   Local cConteudo     := ""

   Private aBrowse     := {}
   Private aProdutos   := {}
   Private aParametros := {}
   
   // ###########################################################
   // Verifica se houve pelo menos uma nota fiscal selecionada ##
   // ###########################################################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcadas := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcadas == .F.
      MsgAlert("Atenção!" + Chr(13) + chr(10) + chr(13) + chr(10) + "Nenhuma nota fiscal foi indicada para ser importada." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // ############################################################
   // Início do laço de importação de notas fiscais de serviços ##
   // ############################################################
   For nContar = 1 to Len(aLista)
       
       // #######################################################
       // Despreza notas fiscais não indicadas para importação ##
       // #######################################################
       If aLista[nContar,01] == .F.
          Loop
       Endif
          
       // #########################################################################
       // Abre o arquivo a ser lido para extração das informações do arquivo xml ##
       // #########################################################################
       nHandle := FOPEN(Alltrim(cCaminho) + Alltrim(aLista[nContar,02]), FO_READWRITE + FO_SHARED)
     
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
           If Substr(xBuffer, nPercorre, 1) <> ">"
              cConteudo := cConteudo + Substr(xBuffer, nPercorre, 1)
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
       Next nPercorre

       // ##################################
       // Fecha a leitura do arquivo lido ##
       // ##################################
       FCLOSE(nHandle)

       // ####################################################
       // Envia para função que gera o documento de entrada ##
       // ####################################################
       GeraDocEntSrv(aLista[nContar,02])

   Next nContar
   
   // ##############################################
   // Atualiza o grid de xml's a serem importados ##
   // ##############################################
   CargaListaNFS()

Return(.T.)

// ##############################################################################################
// Função que abre a janela para confirmação de dados antes da geração do documento de entrada ##
// ##############################################################################################
Static Function GeraDocEntSrv(ArqXML)

   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1
      
   Local cSql       := ""
   Local lTemPar    := .F.
   Local Par_Codigo := Space(06)
   Local kCnpj      := ""
   Local kValorCNPJ := ""

   Private mDocumento  := Space(09)
   Private mSerie      := Space(03)
   Private mEmissao    := Ctod("  /  /    ")
   Private mFornecedor := Space(06)
   Private mLoja       := Space(03)
   Private mNomeForne  := Space(60)
   Private mMunicipio  := Space(60)
   Private mEstado     := Space(02)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet9

   Private aParametros := {}
   Private aPedidos    := {}

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgIMP

   // ############################################################################
   // Verifica se existe parametrização cadastrada para o município do XML lido ##
   // ############################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSK_FILIAL,"
   cSql += "       ZSK_CODI  ,"
   cSql += "       ZSK_SEQU  ,"
   cSql += "       ZSK_NOME  ,"
   cSql += "       ZSK_CAMP  ,"
   cSql += "       ZSK_NCAM  ,"
   cSql += "       ZSK_NTAG   "
   cSql += "  FROM " + RetSqlName("ZSK")
   cSql += " WHERE ZSK_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND ZSK_SEQU = '999'"
   cSql += "   AND ZSK_DELE = ''"
   cSql += " ORDER BY ZSK_CODI, ZSK_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
     
   T_PARAMETROS->( DbGoTop() )

   lTemPar := .F.
   
   WHILE !T_PARAMETROS->( EOF() )
   
      For nProcura = 1 to Len(aBrowse)
 
          If U_P_OCCURS(ALLTRIM(UPPER(aBrowse[nProcura,01])), ALLTRIM(UPPER(T_PARAMETROS->ZSK_NTAG)), 1) == 0
          Else
             lTemPar    := .T.
             Par_Codigo := T_PARAMETROS->ZSK_CODI
             Exit
          Endif
       
      Next nProcura 
          
      If lTemPar == .T.
         Exit
      Endif   

      T_PARAMETROS->( DbSkip() )
      
   ENDDO   
          
   If lTemPar == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Nota Fiscal do XML " + Alltrim(ArqXML)  + " não possui parâmetros cadastrados para seu município." + chr(13) + chr(10) + ;
               "Importação deste XML não será realizado.")
      Return(.T.)
   Endif
               
   // ##############################################
   // Pesquisa os parâmetros da prefeitura do XML ##
   // ##############################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSK_FILIAL,"
   cSql += "       ZSK_CODI  ,"
   cSql += "       ZSK_SEQU  ,"
   cSql += "       ZSK_NOME  ,"
   cSql += "       ZSK_CAMP  ,"
   cSql += "       ZSK_NCAM  ,"
   cSql += "       ZSK_NTAG   "
   cSql += "  FROM " + RetSqlName("ZSK")
   cSql += " WHERE ZSK_FILIAL = '" + Alltrim(cFilAnt)    + "'"
   cSql += "   AND ZSK_CODI   = '" + Alltrim(par_Codigo) + "'"
   cSql += "   AND ZSK_DELE   = ''"
   cSql += " ORDER BY ZSK_CODI, ZSK_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   T_PARAMETROS->( DbGoTop() )
   
   WHILE !T_PARAMETROS->( EOF() )
   
      aAdd( aParametros, { T_PARAMETROS->ZSK_CODI  ,;
                           T_PARAMETROS->ZSK_SEQU  ,;
                           T_PARAMETROS->ZSK_NOME  ,;
                           T_PARAMETROS->ZSK_CAMP  ,;
                           T_PARAMETROS->ZSK_NCAM  ,;
                           T_PARAMETROS->ZSK_NTAG  })
                           
      T_PARAMETROS->( DbSkip() )
      
   ENDDO
      
   // ###########################################
   // Localiza a Tag do CNPJ/CPF do Fornecedor ##
   // ###########################################
   For nProcura = 1 to Len(aParametros)
       
       If Alltrim(Upper(aParametros[nProcura,04])) == "F1_CGC"
          kCnpj := aParametros[nProcura,06]
          Exit
       Endif
       
   Next nProcura
   
   // ############################################
   // Localiza no array aBrowse o valor do CNPJ ##
   // ############################################
   For nProcura = 1 to Len(aBrowse)
       If U_P_OCCURS(Upper(aBrowse[nProcura,01]), Alltrim(kCNPJ), 1) == 0
       Else
          nProcura += 1
          kValorCNPJ := Alltrim(aBrowse[nProcura,01])
          Exit
       Endif
   Next nProcura

   If Empty(Alltrim(kValorCnpj))
      MsgAlert("Atenção!"                                                                           + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Não foi possível localizar o CNPJ/CPF do Fornecedor para o XML " + Alltrim(ArqXML)  + chr(10) + chr(13) + ;
               "Verifique parametrizador de prefeituras."                                           + chr(13) + chr(10) + ;
               "Importação deste XML não será realizado.")
      Return(.T.)
   Endif                
   
   // ##################################################################
   // Pesquisa o código e loja do fornecedor pela leitura do CNPJ/CPF ##
   // ##################################################################            
   If Select("T_FORNECEDOR") > 0
      T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT A2_COD , "
   cSql += "       A2_LOJA, "
   cSql += "       A2_NOME, "
   cSql += "       A2_MUN , "
   cSql += "	   A2_EST   "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_CGC     = '" + Alltrim(kValorCnpj) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   If T_FORNECEDOR->( EOF() )
      MsgAlert("Atenção!"                                                                           + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Não foi possível localizar o cadastro do Fornecedor para o XML " + Alltrim(ArqXML)  + chr(10) + chr(13) + ;
               "Verifique o cadastro de Fornecedores."                                              + chr(13) + chr(10) + ;
               "Importação deste XML não será realizado.")
      Return(.T.)
   Else
      mFornecedor := T_FORNECEDOR->A2_COD
      mLoja       := T_FORNECEDOR->A2_LOJA
      mNomeForne  := T_FORNECEDOR->A2_NOME
      mMunicipio  := T_FORNECEDOR->A2_MUN
      mEstado     := T_FORNECEDOR->A2_EST
   Endif   
  
   // ############################################################################################### 
   // Carrega o array aPedidos com os pedidos de compra disponível de utilização para o fornecedor ##
   // ###############################################################################################
   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC7.C7_NUM    ,"
   cSql += "       SC7.C7_EMISSAO,"
   cSql += "	   SC7.C7_DATPRF ,"
   cSql += "       SC7.C7_COND   ,"
   cSql += "       SE4.E4_DESCRI ,"
   cSql += "	   SC7.C7_ITEM   ,"
   cSql += "	   SC7.C7_PRODUTO,"
   cSql += "	   SC7.C7_PARTNUM,"
   cSql += "	   SC7.C7_DESCRI ,"
   cSql += "	   SC7.C7_UM     ,"
   cSql += "	   SC7.C7_QUANT  ,"
   cSql += "	   SC7.C7_PRECO  ,"
   cSql += "	   SC7.C7_TOTAL  ,"
   cSql += "	   SC7.C7_QUJE   ,"
   cSql += "      (SC7.C7_QUANT - SC7.C7_QUJE) AS SALDO"
   cSql += "     FROM " + RetSqlName("SC7") + " SC7, "
   cSql += "          " + RetSqlName("SE4") + " SE4  "
   cSql += "    WHERE SC7.C7_FILIAL  = '" + Alltrim(cFilAnt)     + "'"
   cSql += "      AND SC7.C7_FORNECE = '" + Alltrim(mFornecedor) + "'"
   cSql += "      AND SC7.C7_LOJA    = '" + Alltrim(mLoja)       + "'"
   cSql += "      AND SC7.D_E_L_E_T_ = ''"
   cSql += "      AND (SC7.C7_QUANT - SC7.C7_QUJE) <> 0"
   cSql += "      AND SE4.E4_CODIGO  = SC7.C7_COND"
   cSql += "      AND SE4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )
   
   T_PEDIDOS->( DbGoTop() )

   kProdutoFrete := "007339" + Space(24)

   aAdd( aPedidos, { .F.                                                             ,;
                     ""                                                              ,;
                     ""                                                              ,;
                     ""                                                              ,;
                     "001"                                                           ,;
                     "007339"                                                        ,;
                     ""                                                              ,;
                     Posicione( "SB1", 1, xFilial("SB1") + kProdutoFrete, "B1_DESC" ),;
                     ""                                                              ,; 
                     ""                                                              ,; 
                     ""                                                              ,; 
                     ""                                                              ,; 
                     ""                                                              ,; 
                     ""                                                              ,;
                     "066"                                                           ,;
                     "28 DD"                                                         })
   
   WHILE !T_PEDIDOS->( EOF() )
    
      aAdd( aPedidos, { .F.                  ,; // 01
                        T_PEDIDOS->C7_NUM    ,; // 02
                        Substr(T_PEDIDOS->C7_EMISSAO,07,02) + "/" + Substr(T_PEDIDOS->C7_EMISSAO,05,02) + "/" + Substr(T_PEDIDOS->C7_EMISSAO,01,04) ,; // 03
                        Substr(T_PEDIDOS->C7_DATPRF ,07,02) + "/" + Substr(T_PEDIDOS->C7_DATPRF ,05,02) + "/" + Substr(T_PEDIDOS->C7_DATPRF ,01,04) ,; // 04
                        T_PEDIDOS->C7_ITEM   ,; // 05
                        T_PEDIDOS->C7_PRODUTO,; // 06
                        T_PEDIDOS->C7_PARTNUM,; // 07
                        T_PEDIDOS->C7_DESCRI ,; // 08
                        T_PEDIDOS->C7_UM     ,; // 09
                        T_PEDIDOS->C7_QUANT  ,; // 10
                        T_PEDIDOS->C7_PRECO  ,; // 11
                        T_PEDIDOS->C7_TOTAL  ,; // 12
                        T_PEDIDOS->C7_QUJE   ,; // 13
                        T_PEDIDOS->SALDO     ,; // 14
                        T_PEDIDOS->C7_COND   ,; // 15
                        T_PEDIDOS->E4_DESCRI }) // 16 

      T_PEDIDOS->( DbSkip() )
      
   ENDDO
   
   // ##########################################################################################
   // Carrega o nº do documento, série e data de emissão da nota fiscal de serviço eletrônica ##
   // ##########################################################################################

   // ########################
   // Localiza a Tag F1_DOC ##
   // ########################
   kLabelTag := ""
   kValorTag := ""
   For nProcura = 1 to Len(aParametros)
       
       If Alltrim(Upper(aParametros[nProcura,04])) == "F1_DOC"
          kLabelTag := aParametros[nProcura,06]
          Exit
       Endif
       
   Next nProcura

   // ###################################
   // Captura o conteúdo da tag F1_DOC ##
   // ###################################
   For nProcura = 1 to Len(aBrowse)
       If U_P_OCCURS(Upper(aBrowse[nProcura,01]), Alltrim(kLabelTag), 1) == 0
       Else
          nProcura += 1
          kValorTag := Alltrim(aBrowse[nProcura,01])
          Exit
       Endif
   Next nProcura

   mDocumento := Alltrim(kValorTag)
   
   If Len(Alltrim(mDocumento)) <= 9
   Else
      mDocumento := Substr(Alltrim(mDocumento), Len(Alltrim(mDocumento)) - 8)      
   Endif
 
   // ##########################
   // Localiza a Tag F1_SERIE ##
   // ##########################
   kLabelTag := ""
   kValorTag := ""
   For nProcura = 1 to Len(aParametros)
       
       If Alltrim(Upper(aParametros[nProcura,04])) == "F1_SERIE"
          kLabelTag := aParametros[nProcura,06]
          Exit
       Endif
       
   Next nProcura

   // #####################################
   // Captura o conteúdo da tag F1_SERIE ##
   // #####################################
   For nProcura = 1 to Len(aBrowse)
       If U_P_OCCURS(Upper(aBrowse[nProcura,01]), Alltrim(kLabelTag), 1) == 0
       Else
          nProcura += 1
          kValorTag := Alltrim(aBrowse[nProcura,01])
          Exit
       Endif
   Next nProcura

   mSerie := Alltrim(kValorTag)

   // ############################
   // Localiza a Tag F1_EMISSAO ##
   // ############################
   kLabelTag := ""
   kValorTag := ""
   For nProcura = 1 to Len(aParametros)
       
       If Alltrim(Upper(aParametros[nProcura,04])) == "F1_EMISSAO"
          kLabelTag := aParametros[nProcura,06]
          Exit
       Endif
       
   Next nProcura

   // #######################################
   // Captura o conteúdo da tag F1_EMISSAO ##
   // #######################################
   For nProcura = 1 to Len(aBrowse)
       If U_P_OCCURS(Upper(aBrowse[nProcura,01]), Alltrim(kLabelTag), 1) == 0
       Else
          nProcura += 1
          kValorTag := Alltrim(aBrowse[nProcura,01])
          Exit
       Endif
   Next nProcura

   mEmissao := Ctod(Substr(kValorTag,09,02) + "/" + Substr(kValorTag,06,02) + "/" + Substr(kValorTag,01,04))

   // ############################################################
   // Verifica se o documento já está incluído na base de dados ##
   // ############################################################
   If Select("T_JACADASTRADO") <>  0
      T_JACADASTRADO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT F1_FILIAL ,"
   cSql += "       F1_DOC    ,"
   cSql += "	   F1_SERIE  ,"
   cSql += "       F1_FORNECE,"
   cSql += "       F1_LOJA    "
   cSql += "  FROM " + RetSqlName("SF1")
   cSql += " WHERE F1_FILIAL              = '" + Alltrim(cFilAnt)    + "'"
   cSql += "   AND LTRIM(RTRIM(F1_DOC))   = '" + Alltrim(mDocumento) + "'"
   cSql += "   AND LTRIM(RTRIM(F1_SERIE)) = '" + Alltrim(mSerie)     + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JACADASTRADO",.T.,.T.)

   If !T_JACADASTRADO->( EOF() )
      MsgAlert("Atenção!"                                                                                                      + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Nota Fiscal Nº " + Alltrim(mDocumento) + " Série " + Alltrim(mSerie) + " já está cadastrada na base de dados." + chr(10) + chr(13) + ;
               "Importação deste XML não será realizado.")
      Return(.T.)
   Endif                

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlgIMP TITLE "Parametrizador XML - Nota Fiscal de Serviço" FROM C(178),C(181) TO C(515),C(830) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgIMP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(318),C(001) PIXEL OF oDlgIMP

   @ C(036),C(005) Say "Nº Documento"                                                                                   Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgIMP
   @ C(036),C(050) Say "Série"                                                                                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgIMP
   @ C(036),C(074) Say "Dta Emissão"                                                                                    Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgIMP
   @ C(057),C(005) Say "Fornecedor"                                                                                     Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgIMP
   @ C(057),C(169) Say "Município"                                                                                      Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgIMP
   @ C(057),C(268) Say "UF"                                                                                             Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgIMP
   @ C(079),C(005) Say "Selecione a Ordem de Compra para o serviço ou indique Nota Fiscal de Serviço referente a FRETE" Size C(236),C(008) COLOR CLR_BLACK PIXEL OF oDlgIMP
   
   @ C(045),C(005) MsGet oGet1 Var mDocumento  Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba
   @ C(045),C(050) MsGet oGet2 Var mSerie      Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba
   @ C(045),C(074) MsGet oGet3 Var mEmissao    Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba
   @ C(067),C(005) MsGet oGet4 Var mFornecedor Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba
   @ C(067),C(032) MsGet oGet5 Var mLoja       Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba
   @ C(067),C(050) MsGet oGet6 Var mNomeForne  Size C(113),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba
   @ C(067),C(169) MsGet oGet7 Var mMunicipio  Size C(092),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba
   @ C(067),C(268) MsGet oGet9 Var mEstado     Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIMP When lChumba

   @ C(152),C(244) Button "Geral NF" Size C(037),C(012) PIXEL OF oDlgIMP ACTION( ImpNFSrv(ArqXML) )
   @ C(152),C(283) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgIMP ACTION( oDlgIMP:End() )

   @ 110,005 LISTBOX oPedidos FIELDS HEADER "M"                     ,;
                                            "Nº PC"                 ,;
                                            "Dta Emissao"           ,;
                                            "Dta Prev.Ent"          ,;
                                            "Item"                  ,;
                                            "Produto"               ,;
                                            "PartNumber"            ,;
                                            "Descrição dos Produtos",;
                                            "Un"                    ,;
                                            "Quantidade"            ,;
                                            "Preço Unitário"        ,;
                                            "Valor Total"           ,;
                                            "Qtd Já Recebida"       ,;
                                            "Saldo a Receber"       ,;                                    
                                            "Cond.Pgtº"             ,;
                                            "Descrição Cond. Pgtº"   ;
                                            PIXEL SIZE 405,080 OF oDlgIMP ON dblClick(aPedidos[oPedidos:nAt,1] := !aPedidos[oPedidos:nAt,1],oPedidos:Refresh())     

   oPedidos:SetArray( aPedidos )

   oPedidos:bLine := {||{Iif(aPedidos[oPedidos:nAt,01],oOk,oNo),;
                             aPedidos[oPedidos:nAt,02]         ,;
                             aPedidos[oPedidos:nAt,03]         ,;
                             aPedidos[oPedidos:nAt,04]         ,;
                             aPedidos[oPedidos:nAt,05]         ,;
                             aPedidos[oPedidos:nAt,06]         ,;
                             aPedidos[oPedidos:nAt,07]         ,;
                             aPedidos[oPedidos:nAt,08]         ,;
                             aPedidos[oPedidos:nAt,09]         ,;
                             aPedidos[oPedidos:nAt,10]         ,;
                             aPedidos[oPedidos:nAt,11]         ,;                                                                                                                                                                              
                             aPedidos[oPedidos:nAt,12]         ,;                                                          
                             aPedidos[oPedidos:nAt,13]         ,;
                             aPedidos[oPedidos:nAt,14]         ,;
                             aPedidos[oPedidos:nAt,15]         ,;                             
                             aPedidos[oPedidos:nAt,16]         }}

   ACTIVATE MSDIALOG oDlgIMP CENTERED

Return(.T.)

// ##############################################################################################
// Função que abre a janela para confirmação de dados antes da geração do documento de entrada ##
// ##############################################################################################
Static Function ImpNFSrv(ArqXML)

   Local nX            := 0
   Local nQuantos      := 0

   Private aCabec      := {}
   Private aItens      := {}
   Private lMsErroAuto := .F.  
   Private lMsHelpAuto := .F.

   PRIVATE aRotina := {{"Pesquisar"   , "AxPesqui"   , 0, 1},;
              		   {"Visualizar"  , "A103NFiscal", 0, 2},; 
		               {"Incluir"     , "A103NFiscal", 0, 3},; 
   		               { "Classificar", "A103NFiscal", 0, 4},; 
		               {"Retornar"    , "A103Devol"  , 0, 3},; 
		               {"Excluir"     , "A103NFiscal", 3, 5},; 
		               {"Imprimir"    , "A103Impri"  , 0, 4},; 
		               {"Legenda"     , "A103Legenda", 0, 2} } 

   // ###########################################################################################
   // Verifica se houve marcação de algum pedido de compra ou frete para realizar a importação ##
   // ###########################################################################################
   For nX = 1 to Len(aPedidos)
       If aPedidos[nX,01] == .T.
          nQuantos += 1
       Endif
   Next nContar
   
   If nQuantos == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não houve marcação de nenhum pedido de compra ou frete para ser importado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // ###############################################################################################################################
   // Se nQuantos > 1, verifica se houve marcação de pedidos de compra com frete. Isso não pode. Frete somente marcação individual ##
   // ###############################################################################################################################
   If nQuantos > 1
      If aPedidos[01,01] == .T.
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não é permitido utilizar registro de frete juntamente com" + chr(13) + chr(10) + "registros de pedido de venda." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif
   Endif   
      
   // ###################################################################
   // Pesquisa a condição de pagamento para o Pedido de Compra marcado ##
   // ###################################################################
   If aPedidos[01,01] == .T.
      mCondicao := aPedidos[01,15]
      lFrete    := .T.
   Else
      For xx = 1 to Len(aPedidos)
          if aPedidos[xx,01] == .T.
             mCondicao := aPedidos[xx,15]
             Exit
          Endif
      Next xx
      lFrete    := .F.
   Endif

   // ##############################################
   // Carrega o cabeçalho do documento de entrada ##
   // ##############################################
   aAdd( aCabec, {"F1_TIPO"   , "N"                 , Nil, Nil } )
   aAdd( aCabec, {"F1_FORMUL" , "N"                 , Nil, Nil } )
   aAdd( aCabec, {"F1_FILIAL" , cFilAnt             , Nil, Nil } )
   aAdd( aCabec, {"F1_DOC"    , Alltrim(mDocumento) , Nil, Nil } )
   aAdd( aCabec, {"F1_SERIE"  , Alltrim(mSerie)     , Nil, Nil } )
   aAdd( aCabec, {"F1_ESPECIE", "NFS"               , Nil, Nil } )
   aAdd( aCabec, {"F1_EMISSAO", mEmissao            , Nil, Nil } )
   aAdd( aCabec, {"F1_DTDIGIT", dDataBase           , Nil, Nil } )
   aAdd( aCabec, {"F1_FORNECE", mFornecedor         , Nil, Nil } )
   aAdd( aCabec, {"F1_LOJA"   , mLoja               , Nil, Nil } )
   aAdd( aCabec, {"F1_EST"    , mEstado             , Nil, Nil } )
   aAdd( aCabec, {"F1_MOEDA"  , 1                   , Nil, Nil } )
   aAdd( aCabec, {"F1_COND"   , mCondicao           , Nil, Nil } )

   // ##############################
   // Carrega o Array de Produtos ##
   // ##############################
   For xx := 1 To Len(aPedidos)

       If aPedidos[xx,01] == .F.
          Loop
       Endif   

       kProduto   := Alltrim(aPedidos[xx,06]) + Space(30 - Len(Alltrim(aPedidos[xx,06])))
       xEmissao   := Substr(Dtoc(mEmissao),07,04) + Substr(Dtoc(mEmissao),04,02) + Substr(Dtoc(mEmissao),01,02)
       xDigitacao := Substr(Dtoc(Date())  ,07,04) + Substr(Dtoc(Date())  ,04,02) + Substr(Dtoc(Date())  ,01,02)
       xLocal     := Posicione('SB1', 1, xFilial('SB1') + kProduto, 'B1_LOCPAD')
       xUnidade   := Posicione('SB1', 1, xFilial('SB1') + kProduto, 'B1_UM')
       xTipoProd  := Posicione('SB1', 1, xFilial('SB1') + kProduto, 'B1_TIPO')        

       // ######################################
       // Pesquisa o TES pela TES Inteligente ##
       // ######################################
       kEntra  := MaTesInt(1,"06", mFornecedor, mLoja, "F", kProduto)
       kFisca  := Posicione('SF4', 1, xFilial('SF4') + kEntra, 'F4_CF')

       aLinha := {} 
		     
	   aAdd( aLinha, { "D1_FILIAL" , cFilAnt        , Nil, Nil } )
	   aAdd( aLinha, { "D1_ITEM"   , Strzero(xx,4)  , Nil, Nil } )
	   aAdd( aLinha, { "D1_COD"    , kProduto       , Nil, Nil } )
	   aAdd( aLinha, { "D1_UN"     , xUnidade       , Nil, Nil } )
	   aAdd( aLinha, { "D1_TP"     , xTipoProd      , Nil, Nil } )		

       If lFrete == .T.

          // ##########################
          // Localiza a Tag D1_TOTAL ##
          // ##########################
          kLabelTag := ""
          kValorTag := ""
          For nProcura = 1 to Len(aParametros)
       
              If Alltrim(Upper(aParametros[nProcura,04])) == "D1_TOTAL"
                 kLabelTag := aParametros[nProcura,06]
                 Exit
              Endif
       
          Next nProcura

          // #####################################
          // Captura o conteúdo da tag D1_TOTAL ##
          // #####################################
          nValorTotal := 0
          For nProcura = 1 to Len(aBrowse)
              If U_P_OCCURS(Upper(aBrowse[nProcura,01]), Alltrim(kLabelTag), 1) == 0
              Else
                 nProcura += 1
                 kValorTag := Alltrim(aBrowse[nProcura,01])
                 Exit
              Endif
          Next nProcura

          nValorTotal := Val(kValorTag)

   	      aAdd( aLinha, { "D1_QUANT"  , 1          , Nil, Nil } )
          aAdd( aLinha, { "D1_VUNIT"  , nValorTotal, Nil, Nil } )
    	  aAdd( aLinha, { "D1_TOTAL"  , nValorTotal, Nil, Nil } )

       Else

   	      aAdd( aLinha, { "D1_QUANT"  , aPedidos[xx,14], Nil, Nil } )
          aAdd( aLinha, { "D1_VUNIT"  , aPedidos[xx,11], Nil, Nil } )
    	  aAdd( aLinha, { "D1_TOTAL"  , aPedidos[xx,12], Nil, Nil } )

       Endif	  

       aAdd( aLinha, { "D1_TES"    , kEntra         , Nil, Nil } )
       aAdd( aLinha, { "D1_CF"     , kFisca         , Nil, Nil } )

       If lFrete == .T.
       Else
		  aAdd( aLinha, { "D1_PEDIDO" , aPedidos[xx,02], Nil, Nil } )
		  aAdd( aLinha, { "D1_ITEMPC" , aPedidos[xx,05], Nil, Nil } )
       Endif

	   aAdd( aLinha, { "D1_EMISSAO", xEmissao           , Nil, Nil } )
	   aAdd( aLinha, { "D1_DTDIGIT", xDigitacao         , Nil, Nil } )
	   aAdd( aLinha, { "D1_RATEIO" , "1"                , Nil, Nil } )
	   aAdd( aLinha, { "D1_DOC"    , Alltrim(mDocumento), Nil, Nil } )
 	   aAdd( aLinha, { "D1_SERIE"  , Alltrim(mSerie)    , Nil, Nil } )
 	   aAdd( aLinha, { "D1_FORNECE", mFornecedor        , Nil, Nil } )
 	   aAdd( aLinha, { "D1_LOJA"   , mLoja              , Nil, Nil } )												
			
       aAdd( aItens, aLinha )

   Next xx

   // ###################################################################
   // Executa a rotina padrão do Protheus para inclusão da Nota Fiscal ##
   // ###################################################################
   MsgRun( "Aguarde gerando Nota de Entrada...",, { || MSExecAuto( { | w, x, y, z | MATA103( w, x, y, z ) }, aCabec, aItens, 3, .T. ) } )

   If lMsErroAuto
      MostraErro()
	  MsgAlert("Erro na inclusão dos dados do XML.")
	  Return .T.
   Else

      // ###############################
      // Renomeia o arquivo importado ##
      // ###############################
	  If MsgYesNo("Documento de Entrada foi gerado com sucesso?")
         frename(Alltrim(cCaminho) + Alltrim(ArqXML), Alltrim(cCaminho) + "#" + Alltrim(ArqXML) ) 
      Endif   
      
   Endif

   oDlgIMP:End()
   
Return(.T.)      