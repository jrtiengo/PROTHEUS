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
// Referencia: AUTOM660.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 27/11/2017                                                          ##
// Objetivo..: Programa que emite documentos Oficiais                              ##
//             XML, DANFE, RPS, BOLETO BANCÁRIO                                    ##
// ##################################################################################

User Function AUTOM660()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Emissão de Documentos" FROM C(178),C(181) TO C(460),C(424) PIXEL

   @ C(002),C(003) Jpeg FILE "nlogoautoma.bmp" Size C(115),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(115),C(001) PIXEL OF oDlg

   @ C(032),C(005) Button "CÓPIA DE XML"    Size C(113),C(020) PIXEL OF oDlg ACTION( GeraXMLNFSEL() )
   @ C(053),C(005) Button "DANFE"           Size C(113),C(020) PIXEL OF oDlg ACTION( STSDANFE() )
   @ C(075),C(005) Button "R P S"           Size C(113),C(020) PIXEL OF oDlg ACTION( GERARPS() )
   @ C(096),C(005) Button "BOLETO BANCÁRIO" Size C(113),C(020) PIXEL OF oDlg ACTION( BCOBOLETOS() )
   @ C(118),C(005) Button "VOLTAR"          Size C(113),C(020) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################
// Função que imprime a DANFE ##
// #############################
Static Function STSDANFE()

   Local cFil := cFilAnt

   Private aFilBrw := {"SF2","F2_FILIAL=='" + cFil + "'.And.F2_SERIE=='" + SubStr( cFil, 2 ) +"'"}

   // #######################################
   // Chama a função de impressão da DANFE ##
   // #######################################
   SPEDDANFE()
   
Return(.T.)

// ####################
// Função gera o RPS ##
// ####################
Static Function GERARPS()

   U_AMATR968()
   
Return(.T.)   

// #######################################
// Função que imprime boletos bancários ##
// #######################################
Static Function BCOBOLETOS()

   // ##########################################################
   // Pesquisa o banco a ser utilizado para emissão do boleto ##
   // ##########################################################
   kTipo_Banco := U_AUTOM575()
      
   If kTipo_Banco == "0"
   Else
      Do Case
         Case kTipo_Banco == "1"
              U_SANTANDER(.F., "", "", "U")
         Case kTipo_Banco == "2"
              U_BOLITAU(.F., "", "", "U")
      EndCase
   Endif

Return(.T.)

// #######################################################
// Função que gera o XML das notas fiscais selecionadas ##
// #######################################################
Static Function GeraXMLNFSEL()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private aFiliais := U_AUTOM539(2, cEmpAnt)
   Private cNota    := Space(09)
   Private cSerie   := Space(03)
   Private cCaminho := Space(250)

   Private cComboBx1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgXML

   DEFINE MSDIALOG oDlgXML TITLE "Cópia de XML" FROM C(178),C(181) TO C(366),C(592) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgXML

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(199),C(001) PIXEL OF oDlgXML

   @ C(032),C(005) Say "Filial"        Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
   @ C(032),C(074) Say "N.Fiscal"      Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
   @ C(032),C(116) Say "Série"         Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
   @ C(055),C(005) Say "Salvar XML em" Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML

   @ C(042),C(005) ComboBox cComboBx1 Items aFiliais Size C(064),C(010)                              PIXEL OF oDlgXML
   @ C(042),C(074) MsGet    oGet2     Var   cNota    Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXML
   @ C(042),C(116) MsGet    oGet3     Var   cSerie   Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXML
   @ C(064),C(005) MsGet    oGet4     Var   cCaminho Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXML When lChumba
   @ C(064),C(187) Button "..."                      Size C(014),C(009)                              PIXEL OF oDlgXML ACTION( xCaptaCaminho() )

   @ C(077),C(062) Button "Gera XML" Size C(037),C(012) PIXEL OF oDlgXML ACTION( xGeraXMLNFSEL() )
   @ C(077),C(101) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgXML ACTION( oDlgXML:End() )

   ACTIVATE MSDIALOG oDlgXML CENTERED 

Return(.T.)

// ################################################################
// Função que seleciona o diretório para gravação do arquivo CSV ##
// ################################################################
Static Function xCaptaCaminho()

   cCaminho := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )

Return(.T.)

// #################################################
// Função que gera o XML da nota fiscal informada ##
// #################################################
Static Function xGeraXMLNFSEL()

   Local cSql    := ""
   Local cString := ""
   Local nContar     := 0
   Local lTemMarcado := .F.
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

   If Empty(Alltrim(cNota))
      MsgAlert("Nota fiscal a ser gerada a cópia do XML não informada. Verifique!")
      Return(.T.)
   Endif   

   If Empty(Alltrim(cSerie))
      MsgAlert("Série da Nota fiscal a ser gerada a cópia do XML não informada. Verifique!")
      Return(.T.)
   Endif   

   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho onde o XML deverá ser salvo não informado. Verifique!")
      Return(.T.)
   Endif   

   // ###############################################################################################
   // Verifica se existe a pasta TAXADOLAR no equipamento do usuário. Caso não exista, será criada ##
   // ###############################################################################################
   If !ExistDir( "C:\RETASSTERCA" )
      nRet := MakeDir( "C:\RETASSTERCA" )
   Endif

   // ###############################################
   // Prepara a Chave da Entidade a ser pesquisada ##
   // ###############################################
   Do Case
      Case cEmpAnt == "01" .And. Substr(cComboBx1,01,02) == "01"
           kChave := "000001"
      Case cEmpAnt == "01" .And. Substr(cComboBx1,01,02) == "02"
           kChave := "000002"
      Case cEmpAnt == "01" .And. Substr(cComboBx1,01,02) == "03"
           kChave := "000003"
      Case cEmpAnt == "01" .And. Substr(cComboBx1,01,02) == "05"
           kChave := "000011"
      Case cEmpAnt == "01" .And. Substr(cComboBx1,01,02) == "06"
           kChave := "000010"
      Case cEmpAnt == "02" .And. Substr(cComboBx1,01,02) == "01"
           kChave := "000004"
      Case cEmpAnt == "03" .And. Substr(cComboBx1,01,02) == "01"
           kChave := "000009"
      Case cEmpAnt == "04" .And. Substr(cComboBx1,01,02) == "01"
           kChave := "000013"
   EndCase           

   // #############################################
   // Fecha o arquivo de retorno para eliminação ##
   // #############################################
   FCLOSE(cRetorno)

   // ##############################################################################
   // Elimina o Arquivo para receber nova cotação do dolar no diretório TAXADOLAR ##
   // ##############################################################################
   FERASE(cRetorno)

   kDocumento := StrTran(cSerie + cNota, " ", "%20")

//   cUrl := "http://54.94.245.225/AtechProtheusDataWS/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kChave

   // ###############
   // Developer 11 ##
   // ###############
// cUrl := "http://54.94.245.225/AtechProtheusDataWS11Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kchave
   
   // ##############
   // Produção 11 ##
   // ##############
   cUrl := "http://54.94.245.225/AtechProtheusDataWS11Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kchave
   
   // ###############
   // Developer 12 ##
   // ###############
// cUrl := "http://54.94.245.225/AtechProtheusDataWS12Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kchave
   
   // ##############
   // Produção 12 ##
   // ##############
// cUrl := "http://54.94.245.225/AtechProtheusDataWS12Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kchave

   // ##############################################################################
   // Envia a solicitação de cotação da taxa do dolar                             ##
   // http://192.168.0.84/AtechProtheusDataWS/?NFE_ID=6%20%20001208&ID_ENT=000010 ##
   // ##############################################################################
   WaitRun('AtechHttpget.exe' + ' "' + cUrl + '" ' + cRetorno, SW_SHOWNORMAL )
  
   If File(cRetorno)
   Else
      MsgAlert("Erro na leitura do XML pelo Web Service. Tente novamente.")
      Return(.T.)
   Endif   

   // ##########################################
   // Trata o retorno do envio da solicitação ##
   // ##########################################

   // #################################################################################
   // Abre o arquivo de retorno para capturar o código do ticket gerado no freshdesk ##
   // #################################################################################
   nHandle := FOPEN("C:\RETASSTERCA\ASSINATURA.TXT", FO_READWRITE + FO_SHARED)
      
   If FERROR() != 0
      MsgAlert("Assinatura do XML do documento Nr " + aLista[nContar,08] + "/" + aLista[nContar,07] + " não localizada.")
      Return(.T.)
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
                                                                             
   // ###################################################################
   // Captura os dados para elaboração do XML do documento selecionado ##
   // ###################################################################
   If Select("T_GERAXML") > 0
      T_GERAXML->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT F2_DOC,"                                                   + CHR(13)
   cSql += "       F2_SERIE  , "                                                       + CHR(13)
   cSql += "       F2_FILIAL , "                                                       + CHR(13)
   cSql += "       F2_CLIENTE, "                                                       + CHR(13)
   cSql += "       F2_LOJA   , "                                                       + CHR(13)
   cSql += "       F2_EMISSAO, "                                                       + CHR(13)
   cSql += "       F2_VALBRUT, "                                                       + CHR(13)
   cSql += "       F2_HORA   , "                                                       + CHR(13)
   cSql += "       A1_EMAIL  , "                                                       + CHR(13)
   cSql += "       SPED.R_E_C_N_O_ AS REG_XML,"                                        + CHR(13)
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),XML_PROT)) as XML_PROT"  + CHR(13)
   cSql += "   FROM " + RetSqlName("SF2") + " AS SF2,"                                 + CHR(13)
   cSql += "        P11_TSS..SPED054 AS SPED, "                                        + CHR(13)
   cSql += "        " + RetSqlName("SC5") + " AS SC5,"                                 + CHR(13)
   cSql += "        " + RetSqlName("SA1") + " AS SA1 "                                 + CHR(13)
   cSql += " WHERE F2_CHVNFE        <> '' "                                            + CHR(13)
   cSql += "   AND F2_TIPO           = 'N'"                                            + CHR(13)
   cSql += "   AND F2_SERIE + F2_DOC = NFE_ID"                                         + CHR(13)
   cSql += "   AND F2_FILIAL         = C5_FILIAL "                                     + CHR(13)
   cSql += "   AND F2_DOC            = C5_NOTA   "                                     + CHR(13)
   cSql += "   AND F2_SERIE          = C5_SERIE  "                                     + CHR(13)
   cSql += "   AND A1_COD            = F2_CLIENTE"                                     + CHR(13)
   cSql += "   AND A1_LOJA           = F2_LOJA   "                                     + CHR(13)
   cSql += "   AND NFE_PROT         <> '' "                                            + CHR(13)
   cSql += "   AND F2_DOC            = '" + Alltrim(cNota)          + "'"              + CHR(13)
   cSql += "   AND F2_SERIE          = '" + Alltrim(cSerie)         + "'"              + CHR(13)
   cSql += "   AND F2_FILIAL         = '" + Substr(cComboBx1,01,02) + "'"              + CHR(13)
   cSql += "   AND SF2.D_E_L_E_T_   <> '*'"                                            + CHR(13)
   cSql += "   AND SPED.D_E_L_E_T_  <> '*'"                                            + CHR(13)
   cSql += "   AND SPED.ID_ENT       = '" + Alltrim(kChave)             + "'"          + CHR(13)
   cSql += "   AND SC5.D_E_L_E_T_   <> '*'"                                            + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_   <> '*'"                                            + CHR(13)
   cSql += "   ORDER BY F2_EMISSAO DESC   "                                            + CHR(13)
	
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GERAXML", .T., .T. )
                                                
   // ######################################
   // Cria o XML do Documento selecionado ##
   // ######################################
   cCaminho := cCaminho + "XML_" + Alltrim(cNota) + "_" + Alltrim(cSerie) + "_" + Substr(cComboBx1,01,02) + ".XML"

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

   MsgAlert("Arquivo " + Alltrim(cCaminho) + " Salvo com sucesso.")

   oDlgXML:End()
       
Return(.T.)