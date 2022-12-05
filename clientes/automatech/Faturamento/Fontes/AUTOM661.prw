#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
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
// Referencia: AUTOM661.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 29/11/2017                                                          ##
// Objetivo..: Programa que gera XML para o Simfrete por informação de período de  ##
//             pesquisa.                                                           ##
// ##################################################################################

User Function AUTOM661()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aEmpresas := U_AUTOM539(1, "")      
   Private aFiliais  := U_AUTOM539(2, cEmpAnt) 
   Private cNota	 := Space(09)
   Private cSerie	 := Space(03)
   Private dData01	 := Ctod("  /  /    ")
   Private dData02	 := Ctod("  /  /    ")

   Private cComboBx1
   Private cComboBx2
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Geração de XML SIMFRETE" FROM C(178),C(181) TO C(480),C(454) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(131),C(001) PIXEL OF oDlg
   @ C(128),C(002) GET oMemo2 Var cMemo2 MEMO Size C(131),C(001) PIXEL OF oDlg
   
   @ C(033),C(005) Say "Empresa"         Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Filial"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(080),C(005) Say "Nº Nota Fiscal"  Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(080),C(048) Say "Série"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(102),C(005) Say "Período Inicial" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(102),C(048) Say "Período Final"   Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(043),C(005) ComboBox cComboBx1 Items aEmpresas Size C(128),C(010)                              PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(066),C(005) ComboBox cComboBx2 Items aFiliais  Size C(128),C(010)                              PIXEL OF oDlg
   @ C(089),C(005) MsGet    oGet1     Var   cNota     Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(089),C(048) MsGet    oGet2     Var   cSerie    Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(111),C(005) MsGet    oGet3     Var   dData01   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(111),C(048) MsGet    oGet4     Var   dData02   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(133),C(030) Button "Gerar"  Size C(037),C(012) PIXEL OF oDlg ACTION( GeraXMLSFrete() )
   @ C(133),C(069) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(066),C(005) ComboBox cComboBx2 Items aFiliais Size C(128),C(010) PIXEL OF oDlg

Return(.T.)


// ######################################################
// Função que gera os xml's conforme período informado ##
// ######################################################
Static Function GeraXMLSFrete()

   MsgRun("Aguarde! Gerando XML para o período infromado ...", "XML Simfrete",{|| xGeraXMLSFrete() })

Return(.T.)

// ######################################################
// Função que gera os xml's conforme período informado ##
// ######################################################
Static Function xGeraXMLSFrete()

   Local cSql        := 0
   Local nContar     := 0
   Local cCaminho    := ""
   Local aEmpresas   := {}
   Local dData       := ""
   Local cString     := ""
   Local lTemMarcado := .F.
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

   If dData01 == Ctod("  /  /    ")
      MsgAlert("Data inicial de pesquisa não informada. Verique!")
      Return(.T.)
   Endif
      
   If dData02 == Ctod("  /  /    ")
      MsgAlert("Data final de pesquisa não informada. Verique!")
      Return(.T.)
   Endif

   If dData02 < dData01
      MsgAlert("Datas inválidas. Verique!")
      Return(.T.)
   Endif

   // ######################################################
   // Carrega o array com as Empresas a serem pesquisadas ##
   // ######################################################
   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           Do Case 
              Case Substr(cComboBx2,01,02) == "01"
                   k_Entidade := "000001"
              Case Substr(cComboBx2,01,02) == "02"
                   k_Entidade := "000002"
              Case Substr(cComboBx2,01,02) == "03"
                   k_Entidade := "000003"
              Case Substr(cComboBx2,01,02) == "05"
                   k_Entidade := "000011"
              Case Substr(cComboBx2,01,02) == "06"
                   k_Entidade := "000010"
           Otherwise
                   k_Entidade := "000000"           
           EndCase
      Case Substr(cComboBx1,01,02) == "02"
           k_Entidade := "000004"
      Case Substr(cComboBx1,01,02) == "03"
           k_Entidade := "000009"
      Case Substr(cComboBx1,01,02) == "04"
           k_Entidade := "000013"
      Otherwise
           k_Entidade := "000000"                   
   EndCase

   // #################################################
   // Pesquisa a Nota Fiscal/Série para a data atual ## 
   // #################################################
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
   cSql += "       SPED.R_E_C_N_O_ AS REG_XML,"                                        + CHR(13)
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),XML_PROT)) as XML_PROT"  + CHR(13)
   cSql += "   FROM SF2" + Substr(cComboBx1,01,02) + "0 AS SF2," + chr(13)
   cSql += "        P11_TSS..SPED054 AS SPED (NOLOCK), " + chr(13)
   cSql += "        SC5" + Substr(cComboBx1,01,02) + "0 AS SC5," + chr(13)
   cSql += "        " + RetSqlName("SA1") + " AS SA1 " + chr(13)
   cSql += " WHERE F2_CHVNFE        <> '' "   + chr(13)
   cSql += "   AND F2_TIPO           = 'N'" + chr(13)
   cSql += "   AND F2_SERIE + F2_DOC = NFE_ID" + chr(13)
   cSql += "   AND F2_FILIAL         = C5_FILIAL " + chr(13)
   cSql += "   AND F2_DOC            = C5_NOTA   " + chr(13)
   cSql += "   AND F2_SERIE          = C5_SERIE  " + chr(13)

   If Empty(Alltrim(cNota))
   Else
      cSql += " AND F2_DOC   = '" + Alltrim(cNota)  + "'"
      cSql += " AND F2_SERIE = '" + Alltrim(cSerie) + "'"
   Endif   

   cSql += "   AND A1_COD            = F2_CLIENTE" + chr(13)
   cSql += "   AND A1_LOJA           = F2_LOJA   " + chr(13)
   cSql += "   AND NFE_PROT         <> '' " + chr(13)
   cSql += "   AND F2_EMISSAO       >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + chr(13)
   cSql += "   AND F2_EMISSAO       <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)
   cSql += "   AND SF2.D_E_L_E_T_   <> '*'" + chr(13)
   cSql += "   AND SPED.D_E_L_E_T_  <> '*'" + chr(13)
   cSql += "   AND SPED.ID_ENT       = '"   + Alltrim(k_Entidade) + "'" + chr(13)
   cSql += "   AND SC5.D_E_L_E_T_   <> '*'" + chr(13)
   cSql += "   AND SA1.D_E_L_E_T_   <> '*'" + chr(13)
   cSql += "   ORDER BY F2_EMISSAO DESC "   + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GERAXML", .T., .T. )

   T_GERAXML->( DbGoTop() )

   IF T_GERAXML->( EOF() )
      MsgAlert("Não existem dados a serem utilizados para geração de xml's.")
      Return(.T.)
   Endif   
     
   WHILE !T_GERAXML->( EOF() )

      If File("\XML_DANFE\XML_SIMFRETE_" + Substr(cComboBx1,01,02) + "\XML_" + Alltrim(T_GERAXML->F2_DOC) + "_" + Alltrim(T_GERAXML->F2_SERIE) + ".XML")
         Ferase("\XML_DANFE\XML_SIMFRETE_" + Substr(cComboBx1,01,02) + "\XML_" + Alltrim(T_GERAXML->F2_DOC) + "_" + Alltrim(T_GERAXML->F2_SERIE) + ".XML")
      Endif

      cCaminho := "\XML_DANFE\XML_SIMFRETE_" + Substr(cComboBx1,01,02) + "\XML_" + Alltrim(T_GERAXML->F2_DOC) + "_" + Alltrim(T_GERAXML->F2_SERIE) + ".XML"

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

      // cUrl := "http://54.94.245.225/AtechProtheusDataWS11Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + k_Entidade

       // ##############
      // Produção 11 ##
      // ##############

      cUrl := "http://54.94.245.225/AtechProtheusDataWS11Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + k_Entidade

      // ###############
      // Developer 12 ##
      // ###############

      // cUrl := "http://54.94.245.225/AtechProtheusDataWS12Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + k_Entidade

      // ##############
      // Produção 12 ##
      // ##############

      // cUrl := "http://54.94.245.225/AtechProtheusDataWS12Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + k_Entidade

      // ##############################################################################
      // Envia a solicitação de cotação da taxa do dolar                             ##
      // http://192.168.0.84/AtechProtheusDataWS/?NFE_ID=6%20%20001208&ID_ENT=000010 ##
      // ##############################################################################
      WaitRun('AtechHttpget.exe' + ' "' + cUrl + '" ' + cRetorno, SW_SHOWNORMAL )
  
      If File(cRetorno)
      Else
         T_GERAXML->( DbSkip() )
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
         T_GERAXML->( DbSkip() )
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
                                                                             
      If Empty(Alltrim(kAssinatura))
         T_GERAXML->( DbSkip() )
         Loop
      Endif   
                                                
      // ######################################
      // Cria o XML do Documento selecionado ##
      // ######################################
      cString := ""
      cString := cString + '<?xml version="1.0" encoding="UTF-8"?>'
      cString := cString + '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10">'
      cString := cString + kAssinatura
      cString := cString + Alltrim(T_GERAXML->XML_PROT)
      cString := cString + '</nfeProc>'

      // #################################################
      // Salva o arquivo XML da nota fisdcal pesquisada ##
      // ################################################# 
      nHdl := fCreate(cCaminho)
      fWrite (nHdl, cString ) 
      fClose(nHdl)
       
      // #######################################################################################
      // Atualiza o cabeçalho da nota fiscal indicando que o XML da nota fiscal já foi gerado ##
      // #######################################################################################
      cSql := ""
      cSql := "UPDATE SF2" + Substr(cComboBx1,01,02) + "0"
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

   MsgAlert("XML's Gerados com sucesso.")

Return(.T.)