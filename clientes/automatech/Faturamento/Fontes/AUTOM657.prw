#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#Include "Tbiconn.Ch"
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
// Referencia: AUTOM657.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 21/11/2017                                                          ##
// Objetivo..: Schedule que gera os xml de notas fiscais assinadas e grava estas   ##
//             nas pastas correspondentes das Empresas/Filiais  para alimentar o   ##
//             Sistema SIMFRETE.                                                   ##
// ##################################################################################

User Function AUTOM657()

   Local cSql        := 0
   Local nContar     := 0
   Local cCaminho    := ""
   Local aEmpresas   := {}
   Local dData       := ""
   Local cString     := ""
   Local lTemMarcado := .F.
   Local cCaminho    := ""
   Local cString     := ""
   Local kChave      := ""    
   Local cComnado    := ""
   Local nTimeOut    := 0
   Local aHeadOut    := {}
   Local cHeadRet    := ""
   Local sPostRet    := Nil
   Local cUrl        := ""
   Local cRetorno    := "C:\RETASSTERCA\ASSINATURA.TXT"
   Local nTentativas := 0
   Local cSTIM       := 15000000
                                                    
   PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'

   // ######################################################
   // Carrega o array com as Empresas a serem pesquisadas ##
   // ######################################################
   aAdd( aEmpresas, { "01", "01", "000001" } )
   aAdd( aEmpresas, { "01", "02", "000002" } )
   aAdd( aEmpresas, { "01", "03", "000003" } )
   aAdd( aEmpresas, { "01", "05", "000011" } )
   aAdd( aEmpresas, { "01", "06", "000010" } )
   aAdd( aEmpresas, { "02", "01", "000004" } )
   aAdd( aEmpresas, { "03", "01", "000009" } )
   aAdd( aEmpresas, { "04", "01", "000013" } )

   dData := Strzero(Year(Date()),4) + Strzero(Month(Date()),2) + Strzero(Day(Date()),2)

   // ###############################################################################################
   // Verifica se existe a pasta TAXADOLAR no equipamento do usuário. Caso não exista, será criada ##
   // ###############################################################################################
   If !ExistDir( "C:\RETASSTERCA" )
      nRet := MakeDir( "C:\RETASSTERCA" )
   Endif

   // #################################################
   // Pesquisa a Nota Fiscal/Série para a data atual ## 
   // #################################################
   For nContar = 1 to Len(aEmpresas)

       If Select("T_GERAXML") > 0
          T_GERAXML->( dbCloseArea() )
       EndIf
   
       cSql := ""
       cSql := "SELECT DISTINCT F2_DOC," + chr(13)
       cSql += "       F2_SERIE  , " + chr(13)
       cSql += "       F2_FILIAL , " + chr(13)
       cSql += "       F2_CLIENTE, " + chr(13)
       cSql += "       F2_LOJA   , " + chr(13)
       cSql += "       F2_EMISSAO, " + chr(13)
       cSql += "       F2_VALBRUT, " + chr(13)
       cSql += "       F2_HORA   , " + chr(13)
       cSql += "       A1_EMAIL  , " + chr(13)
       cSql += "       F2_CHVNFE , " + chr(13)
       cSql += "       CONVERT(varchar(8000),convert(binary(8000),XML_PROT)) as XML_PROT " + chr(13)
       cSql += "   FROM SF2" + aEmpresas[nContar,01] + "0 AS SF2," + chr(13)
       cSql += "        P11_TSS..SPED054 AS SPED, " + chr(13)
       cSql += "        SC5" + aEmpresas[nContar,01] + "0 AS SC5," + chr(13)
       cSql += "        " + RetSqlName("SA1") + " AS SA1 " + chr(13)
       cSql += " WHERE F2_CHVNFE        <> '' "   + chr(13)
       cSql += "   AND F2_TIPO           = 'N'" + chr(13)
       cSql += "   AND F2_SERIE + F2_DOC = NFE_ID" + chr(13)
       cSql += "   AND F2_FILIAL         = C5_FILIAL " + chr(13)
       cSql += "   AND F2_DOC            = C5_NOTA   " + chr(13)
       cSql += "   AND F2_SERIE          = C5_SERIE  " + chr(13)
       cSql += "   AND A1_COD            = F2_CLIENTE" + chr(13)
       cSql += "   AND A1_LOJA           = F2_LOJA   " + chr(13)
       cSql += "   AND NFE_PROT         <> '' " + chr(13)
       cSql += "   AND SF2.F2_EMISSAO    = '" + dData + "'" + chr(13)
       cSql += "   AND SF2.D_E_L_E_T_   <> '*'" + chr(13)
       cSql += "   AND SPED.D_E_L_E_T_  <> '*'" + chr(13)
       cSql += "   AND SPED.ID_ENT       = '" + aEmpresas[nContar,03] + "'" + chr(13)
       cSql += "   AND SC5.D_E_L_E_T_   <> '*'" + chr(13)
       cSql += "   AND SA1.D_E_L_E_T_   <> '*'" + chr(13)
       cSql += "   ORDER BY F2_EMISSAO DESC " + chr(13)

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GERAXML", .T., .T. )

       T_GERAXML->( DbGoTop() )
     
       WHILE !T_GERAXML->( EOF() )

          If File("\XML_DANFE\XML_SIMFRETE_" + aEmpresas[nContar,01] + "\	XML_" + Alltrim(T_GERAXML->F2_DOC) + "_" + Alltrim(T_GERAXML->F2_SERIE) + ".XML")
             Ferase("\XML_DANFE\XML_SIMFRETE_" + aEmpresas[nContar,01] + "\XML_" + Alltrim(T_GERAXML->F2_DOC) + "_" + Alltrim(T_GERAXML->F2_SERIE) + ".XML")
          Endif

          // ###############################################
          // Pesquisa a assinatura do XML via Web Service ##
          // ###############################################

          // #############################################
          // Fecha o arquivo de retorno para eliminação ##
          // #############################################
          FCLOSE(cRetorno)

          // ##############################################################################
          // Elimina o Arquivo para receber nova cotação do dolar no diretório TAXADOLAR ##
          // ##############################################################################
          FERASE(cRetorno)

          kDocumento := StrTran(T_GERAXML->F2_SERIE + T_GERAXML->F2_DOC, " ", "%20")

          // ###############
          // Developer 11 ##
          // ###############
   //     cUrl := "http://54.94.245.225/AtechProtheusDataWS11Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + aEmpresas[nContar,03]
   
          // ##############
          // Produção 11 ##
          // ##############
          cUrl := "http://54.94.245.225/AtechProtheusDataWS11Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + aEmpresas[nContar,03]

          // ###############
          // Developer 12 ##
          // ###############
   //     cUrl := "http://54.94.245.225/AtechProtheusDataWS12Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + aEmpresas[nContar,03]
   
          // ##############
          // Produção 12 ##
          // ##############
   //     cUrl := "http://54.94.245.225/AtechProtheusDataWS12Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + aEmpresas[nContar,03]

          // ##############################################################################
          // Envia a solicitação de cotação da taxa do dolar                             ##
          // ##############################################################################
          WaitRun('AtechHttpget.exe' + ' "' + cUrl + '" ' + cRetorno, SW_SHOWNORMAL )
  
          If File(cRetorno)
          Else
             Loop
          Endif   

          // ##########################################
          // Trata o retorno do envio da solicitação ##
          // ##########################################

          // #################################################################################
          // Abre o arquivo de retorno para capturar o código do ticket gerado no freshdesk ##
          // #################################################################################
          nHandle := FOPEN("C:\RETASSTERCA\ASSINATURA.TXT", FO_READWRITE + FO_SHARED)
      
          If FERROR() != 0
             Loop
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
 
          FCLOSE(nHandle)

          // ################################################
          // Captura todo o retorno recebido pára gravação ##
          // ################################################
          kAssinatura := Alltrim(xBuffer)

          cCaminho := "\XML_DANFE\XML_SIMFRETE_" + aEmpresas[nContar,01] + "\XML_" + Alltrim(T_GERAXML->F2_DOC) + "_" + Alltrim(T_GERAXML->F2_SERIE) + ".XML"

          cString := ""
          cString := cString + '<?xml version="1.0" encoding="UTF-8"?>'
          cString := cString + '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10">'
          cString := cString + kAssinatura
          cString := cString + Alltrim(T_GERAXML->XML_PROT) 
          cString := cString + '</nfeProc>'

          // ################################################
          // Salva o arquivo XML da nota fiscal pesquisada ##
          // ################################################ 
          nHdl := fCreate(cCaminho)
          fWrite (nHdl, cString ) 
          fClose(nHdl)
      
          // #######################################################################################
          // Atualiza o cabeçalho da nota fiscal indicando que o XML da nota fiscal já foi gerado ##
           // #######################################################################################
          cSql := ""
          cSql := "UPDATE SF2" + aEmpresas[nContar,01] + "0"
          cSql += "   SET"
          cSql += "   F2_ZIMF = 'S'"
          cSql += "   WHERE F2_FILIAL  = '" + Alltrim(T_GERAXML->F2_FILIAL)  + "'"
          cSql += "     AND F2_DOC     = '" + Alltrim(T_GERAXML->F2_DOC)     + "'"
          cSql += "     AND F2_SERIE   = '" + Alltrim(T_GERAXML->F2_SERIE)   + "'"
          cSql += "     AND F2_CLIENTE = '" + Alltrim(T_GERAXML->F2_CLIENTE) + "'"
          cSql += "     AND F2_LOJA    = '" + Alltrim(T_GERAXML->F2_LOJA)    + "'"

          _nErro := TcSqlExec(cSql) 
         
          T_GERAXML->( DbSkip() )

       ENDDO   
      
   Next nContar    

   RESET ENVIRONMENT
       
Return(.T.)