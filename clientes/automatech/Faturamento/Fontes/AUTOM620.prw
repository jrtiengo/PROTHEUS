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
// Referencia: AUTOM620.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 30/08/2017                                                          ##
// Objetivo..: Programa que envia documentos com abertura de Ticket no freshDesk   ##
// ##################################################################################

User Function AUTOM620()

   Local lchumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private cToken := GetMV("MV_FDESK")   

   Private cDataI	 := Ctod("  /  /    ")
   Private cDataF	 := Ctod("  /  /    ")
   Private cCliente  := Space(06)
   Private cLoja	 := Space(03)
   Private cNome	 := Space(60)
   Private cNota	 := Space(09)
   Private cSerie	 := Space(03)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlg

   Private aLista := {}
   Private oLista

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

   U_AUTOM628("AUTOM620")

   // ############################################################################
   // Somente permite executar este programa para a Empresa 01 e Filial 06 (ES) ##
   // ############################################################################
//   If cEmpAnt <> "01"
//      MsgAlert("Procedimento somente liberado para Empresa 01 - Automatech e Filial 06 - Espirito Santo")
//      Return(.T.)
//   Else
//      If cFilAnt <> "06"
//         MsgAlert("Procedimento somente liberado para Empresa 01 - Automatech e Filial 06 - Espirito Santo")
//         Return(.T.)
//      Endif
//   Endif   

   // #############################################################
   // Verifica se existe a pasta C:\XMLDANFEBOL na máquina local ##
   // #############################################################
   If !ExistDir( "C:\XMLDANFEBOL" )

      nRet := MakeDir( "C:\XMLDANFEBOL" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta C:\XMLDANFEBOL. Erro: " + cValToChar( FError() ) )
	     Return(.T.)
      Endif
   
   Endif

   // ##########################################################################################
   // Aplica o Net Use para configurar o drive para leitura dos boletos bancários do servidor ##
   // ##########################################################################################
   // @ECHO OFF                                                                               ##
   // net use J: \\54.94.245.225\d$\Protheus11\Protheus_data\treport /persistent:yes          ##
   // PAUSE > NUL                                                                             ##
   // ##########################################################################################
   WinExec("net use J: \\54.94.245.225\d$\Protheus11\Protheus_data\doc_terca /persistent:yes")

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlg TITLE "Controle de Envio de Documentos (XML, DANFE e BOLETOS a Clientes)" FROM C(178),C(181) TO C(604),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(180),C(005) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(180),C(054) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(180),C(121) Jpeg FILE "br_preto.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(180),C(200) Jpeg FILE "br_laranja.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(180),C(274) Jpeg FILE "br_cancel.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlg
   @ C(168),C(002) GET oMemo2 Var cMemo2 MEMO Size C(385),C(001) PIXEL OF oDlg
   @ C(193),C(002) GET oMemo3 Var cMemo3 MEMO Size C(385),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Dta Emis. Inicial"                     Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(050) Say "Dta Emis. Final"                       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(095) Say "Cliente"                               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(292) Say "Nº NFiscal"                            Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(326) Say "Série"                                 Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(170),C(005) Say "Legendas"                              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(170),C(134) Say "Documentos"                            Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(017) Say "Não Enviados"                          Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(068) Say "Enviados"                              Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(134) Say "Documentos Inexistentes"               Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(213) Say "Documentos Existentes"                 Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(287) Say "Erro de geração. Gere Individualmente" Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) MsGet oGet1 Var cDataI   Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(050) MsGet oGet2 Var cDataF   Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(095) MsGet oGet3 Var cCliente Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(046),C(127) MsGet oGet4 Var cLoja    Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( CaptaCli() )
   @ C(046),C(147) MsGet oGet5 Var cNome    Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(292) MsGet oGet6 Var cNota    Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(326) MsGet oGet7 Var cSerie   Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(043),C(348) Button "Pesquisar"              Size C(040),C(012) PIXEL OF oDlg ACTION( PdqNFTicket() )
   @ C(197),C(005) Button "Marca Todos"            Size C(056),C(012) PIXEL OF oDlg ACTION( MrcDoc(1) )
   @ C(197),C(065) Button "Desmarca Todos"         Size C(056),C(012) PIXEL OF oDlg ACTION( MrcDoc(0) )
   @ C(197),C(129) Button "Gera XML"               Size C(037),C(012) PIXEL OF oDlg ACTION( GeraXMLNFSEL() )
   @ C(197),C(167) Button "Gerar Danfe"            Size C(037),C(012) PIXEL OF oDlg ACTION( GeraDanfeDisco() )
   @ C(197),C(206) Button "Gerar Boleto"           Size C(037),C(012) PIXEL OF oDlg ACTION( GeraBolDisco() )
   @ C(197),C(244) Button "Emails"                 Size C(037),C(012) PIXEL OF oDlg ACTION( xAltEmail() )
   @ C(197),C(285) Button "Abrir Ticket FreshDesk" Size C(060),C(012) PIXEL OF oDlg ACTION( AbrTicketFD() )
   @ C(197),C(351) Button "Voltar"                 Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "1", "1", "1", "1", "", "", "", "", "", "", "", "", "", "", "" })

   @ 078,005 LISTBOX oLista FIELDS HEADER "M"                     ,; // 01
                                          "LG-1"                  ,; // 02
                                          "XML"                   ,; // 03
                                          "DANFE"                 ,; // 04
                                          "BOLETO"                ,; // 05
                                          "Emissão"               ,; // 06
                                          "NFiscal"               ,; // 07
                                          "Série"                 ,; // 08
                                          "Cond.Pgtº"             ,; // 09 
                                          "Cliente"               ,; // 10
                                          "Loja"                  ,; // 11
                                          "Descrição dos Clientes",; // 12
                                          "Transportadora"        ,; // 13
                                          "Dta Abertura"          ,; // 14
                                          "Hr Abertura"           ,; // 15
                                          "Usuário Abertura"       ; // 16
                                          PIXEL SIZE 493,133 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo)                      ,;
                        If(aLista[oLista:nAt,02] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,02] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,02] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,02] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,02] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,02] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,02] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,02] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,02] == "9", oCancel, "")))))))))  ,;                         
                        If(aLista[oLista:nAt,03] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,03] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,03] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,03] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,03] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,03] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,03] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,03] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,03] == "9", oCancel, "")))))))))  ,;                         
                        If(aLista[oLista:nAt,04] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,04] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,04] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,04] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,04] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,04] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,04] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,04] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,04] == "9", oCancel, "")))))))))  ,;                         
                        If(aLista[oLista:nAt,05] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,05] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,05] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,05] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,05] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,05] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,05] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,05] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,05] == "9", oCancel, "")))))))))  ,;                         
                           aLista[oLista:nAt,06]                               ,;
                           aLista[oLista:nAt,07]                               ,;
                           aLista[oLista:nAt,08]                               ,;
                           aLista[oLista:nAt,09]                               ,;
                           aLista[oLista:nAt,10]                               ,;
                           aLista[oLista:nAt,11]                               ,;
                           aLista[oLista:nAt,12]                               ,;
                           aLista[oLista:nAt,13]                               ,;
                           aLista[oLista:nAt,14]                               ,;                           
                           aLista[oLista:nAt,15]                               ,;                           
                           aLista[oLista:nAt,16]                               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################################
// Função que atualiza os boletos do servidor para a máquina local ##
// ##################################################################
//Static Function AtualizaBol()
//
//   MsgRun("Atualizando Boletos bancários ...","Aguarde ...",{|| WinExec("copiadoc.bat") })
//
//Return(.T.)

// #####################################################
// Função que gera a danfe da nota fiscal selecionada ##
// #####################################################
Static Function GeraDanfeDisco()

   MsgRun("Aguarde! Gerando DANFE da(s) NF(s) selecionada(s) ...", "Geração de DANFE",{|| xGeraDanfeDisco() })

Return(.T.)

// #####################################################
// Função que gera a danfe da nota fiscal selecionada ##
// #####################################################
Static Function xGeraDanfeDisco()

   Local nContar     := 0
   Local lTemMarcado := .F.

   If Empty(Alltrim(aLista[oLista:nAt,07]))
      MsgAlert("Nenhuma nota fiscal selecionada para geração da DANFE. Verifique!")
      Return(.T.)
   Endif   

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lTemMarcado := .T.
          Exit
       Endif
   Next nContar       

   If lTemMarcado == .F.
      MsgAlert("Nenhuma nota fiscal selecionada para geração da DANFE. Verifique!")
      Return(.T.)
   Endif   

   // ##################################################
   // Envia para o programa que gera a DANFE em disco ##
   // ##################################################
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif

       U_AUTOM651(cEmpAnt, cFilAnt, aLista[nContar,07], aLista[nContar,08], aLista[nContar,10], aLista[nContar,11], 1)

   Next nContar    

   // ##########################
   // Atualiza o Grid da tela ##
   // ##########################
   xPdqNFTicket()

Return(.T.)   

// ######################################################
// Função que gera o Boleto da nota fiscal selecionada ##
// ######################################################
Static Function GeraBolDisco()

   MsgRun("Aguarde! Gerando BOLETO(s) da(s) NF selecionada(s) ...", "Geração de BOLETO",{|| xGeraBolDisco() })

Return(.T.)

// ######################################################
// Função que gera o Boleto da nota fiscal selecionada ##
// ######################################################
Static Function xGeraBolDisco()

   Local nContar     := 0
   Local nQuantos    := 0
   Local lTemMarcado := .F.

   If Empty(Alltrim(aLista[oLista:nAt,07]))
      MsgAlert("Nenhuma nota fiscal selecionada para geração da BOLETO. Verifique!")
      Return(.T.)
   Endif   

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lTemMarcado := .T.
          nQuantos    += 1 
       Endif
   Next nContar       

   If lTemMarcado == .F.
      MsgAlert("Nenhuma nota fiscal selecionada para geração da BOLETO. Verifique!")
      Return(.T.)
   Endif   

//   If nQuantos > 1
//      MsgAlert("Marque apenas uma nota fiscal a ser gerado Boleto.")
//      Return(.T.)
//   Endif   

   // ##################################################
   // Envia para o programa que gera a DANFE em disco ##
   // ##################################################
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif

       // ##################################################
       // Envia para o programa que gera a DANFE em disco ##
       // ##################################################
       U_AUTOM655(.T., aLista[oLista:nAt,07], aLista[oLista:nAt,08], "", 1, cEmpAnt, cFilAnt)
       
   Next nContar    

   // ####################################
   // Atualiza o grid para visualização ##
   // ####################################
   xPdqNFTicket()

Return(.T.)   

// ########################################
// Função que pesquisa o nome do Cliente ##
// ########################################
Static Function CaptaCli()

   If Empty(Alltrim(cCliente)) 
      cCliente := Space(06)
      cLoja    := Space(03)
      cNome    := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()      
      Return(.T.)
   Endif

   If Empty(Alltrim(cLoja)) 
      cCliente := Space(06)
      cLoja    := Space(03)
      cNome    := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()      
      Return(.T.)
   Endif

   cNome := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")

   If Empty(Alltrim(cNome)) 
      MsgAlert("Cliente informado não localizado.")
      cCliente := Space(06)
      cLoja    := Space(03)
      cNome    := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()      
      Return(.T.)
   Endif

Return(.T.)

// ########################################
// Função que marca e desmarca registros ##
// ########################################
Static Function MrcDoc(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)       

// ########################################################
// Função que pesquisa notas fiscais conforme parâmetros ##
// ########################################################
Static Function PdqNFTicket()

   MsgRun("Aguarde! Pesquisando Notas Fiscais ...", "Pesquisa Notas Fiscais",{|| xPdqNFTicket() })

Return(.T.)

// ########################################################
// Função que pesquisa notas fiscais conforme parâmetros ##
// ########################################################
Static Function xPdqNFTicket()

   Local cSql      := ""
   Local aFiles    := {}  // O array receberá os nomes dos arquivos e do diretório
   Local aSizes    := {}  // O array receberá os tamanhos dos arquivos e do diretorio
   Local aArquivos := {}  // O array receberá os nomes dos arquivos e do diretório
   Local aTamanhos := {}  // O array receberá os tamanhos dos arquivos e do diretorio
   Local lComErro  := .F. // Verifica se existem documentos com erro de geração

   cSlq := ""

   If cDataI == Ctod("  /  /    ")
      MsgAlert("Data inicial de emissão não informada. Verifique")
      Return(.T.)
   Endif
      
   If cDataF == Ctod("  /  /    ")
      MsgAlert("Data inicial de emissão não informada. Verifique")
      Return(.T.)
   Endif

   aLista := {}

   // ###########################################################
   // Pesquisa as notas fiscais a serem enviados os documentos ##
   // ###########################################################
   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf
 
   cSql := ""
   cSql := "SELECT SF2.F2_FILIAL ," + CHR(13)
   cSql += "       SF2.F2_DOC    ," + CHR(13)
   cSql += "       SF2.F2_SERIE  ," + CHR(13)
   cSql += "       SF2.F2_EMISSAO," + CHR(13)
   cSql += "       SF2.F2_CLIENTE," + CHR(13)
   cSql += "       SF2.F2_LOJA   ," + CHR(13)
   cSql += "       SA1.A1_NOME   ," + CHR(13)
   cSql += "       SA1.A1_EMAIL  ," + CHR(13)
   cSql += "       SF2.F2_ZEEN   ," + CHR(13)
   cSql += "       SF2.F2_ZDEN   ," + CHR(13)
   cSql += "       SF2.F2_ZHEN   ," + CHR(13)
   cSql += "       SF2.F2_ZUEN   ," + CHR(13)
   cSql += "       SF2.F2_ZXML   ," + CHR(13)
   cSql += "       SF2.F2_ZDNF   ," + CHR(13)
   cSql += "       SF2.F2_ZBLT   ," + CHR(13)
   cSql += "       SF2.F2_TRANSP ," + CHR(13)
   cSql += "       SA4.A4_NOME   ," + CHR(13)
   cSql += "       SE4.E4_DESCRI  " + CHR(13)
   cSql += "  FROM " + RetSqlName("SF2") + " SF2, "                                 + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " SA1, "                                 + CHR(13)
   cSql += "       " + RetSqlName("SA4") + " SA4, "                                 + CHR(13)
   cSql += "       " + RetSqlName("SE4") + " SE4  "                                 + CHR(13)
   cSql += " WHERE SF2.F2_FILIAL   = '" + Alltrim(cFilAnt) + "'"                    + CHR(13)
   cSql += "   AND SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDataI) + "', 103)" + CHR(13)
   cSql += "   AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDataF) + "', 103)" + CHR(13)
   cSql += "   AND SF2.D_E_L_E_T_  = ''"                                            + CHR(13)
   cSql += "   AND SA1.A1_COD      = SF2.F2_CLIENTE"                                + CHR(13)
   cSql += "   AND SA1.A1_LOJA     = SF2.F2_LOJA   "                                + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_  = ''"                                            + CHR(13)
   cSql += "   AND SA4.A4_COD      = SF2.F2_TRANSP "                                + CHR(13)
   cSql += "   AND SA4.D_E_L_E_T_  = ''"                                            + CHR(13)
   cSql += "   AND SE4.E4_CODIGO   = SF2.F2_COND   "                                + CHR(13)
   cSql += "   AND SE4.D_E_L_E_T_  = ''"                                            + CHR(13)

   If Empty(Alltrim(cCliente))
   Else
      cSql += " AND SF2.F2_CLIENTE = '" + Alltrim(cCliente) + "'"
      cSql += " AND SF2.F2_LOJA    = '" + Alltrim(cLoja)    + "'"
   Endif
      
   If Empty(Alltrim(cNota))
   Else
      cSql += " AND SF2.F2_DOC = '" + Alltrim(cNota) + "'"
   Endif
   
   If Empty(Alltrim(cSerie))
   Else
      cSql += " AND SF2.F2_SERIE = '" + Alltrim(cSerie) + "'"
   Endif

   cSql += " ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE "                        

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   ADir("C:\XMLDANFEBOL\DANFE_*.*", aArquivos, aTamanhos)

   lComErro := .F.

   T_NOTAS->( DbGoTop() )
   
   WHILE !T_NOTAS->( EOF() )
   
      kleg01   := IIF(T_NOTAS->F2_ZEEN <> "1", "8", "2")
      kXML     := IIF(File("C:\XMLDANFEBOL\XML_"    + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + "_" + Alltrim(cFilAnt) + ".XML"), "6", "7")
      kDANFE   := IIF(File("C:\XMLDANFEBOL\DANFE_"  + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + "_" + Alltrim(cFilAnt) + ".PDF"), "6", "7")
      kBOLETO  := IIF(File("C:\XMLDANFEBOL\BOLETO_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + "_" + Alltrim(cFilAnt) + ".PDF"), "6", "7")
      kEmissao := Substr(T_NOTAS->F2_EMISSAO,07,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,05,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,01,04)
      kEnvio   := Substr(T_NOTAS->F2_ZDEN   ,07,02) + "/" + Substr(T_NOTAS->F2_ZDEN   ,05,02) + "/" + Substr(T_NOTAS->F2_ZDEN   ,01,04)

      // ########################################################################################
      // Verifica se existem ocumento com erro de geração pelo tamanho do arquivo no diretório ##
      // ########################################################################################
      For kk = 1 to Len(aArquivos)
          If aArquivos[kk] == "DANFE_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + "_" + Alltrim(cFilAnt) + ".PDF"
             If aTamanhos[kk] == 0 .Or. aTamanhos[kk] == 1
                lComErro := .T.
                kDANFE := "9"
             Endif
             Exit
          Endif
      Next kk           

      aAdd( aLista, { .F.                 ,; // 01
                      kLeg01              ,; // 02
                      kXML                ,; // 03
                      kDANFE              ,; // 04
                      kBOLETO             ,; // 05
                      kEmissao            ,; // 06
                      T_NOTAS->F2_DOC     ,; // 07
                      T_NOTAS->F2_SERIE   ,; // 08
                      T_NOTAS->E4_DESCRI  ,; // 09
                      T_NOTAS->F2_CLIENTE ,; // 10
                      T_NOTAS->F2_LOJA    ,; // 11
                      T_NOTAS->A1_NOME    ,; // 12
                      T_NOTAS->A4_NOME    ,; // 13
                      kEnvio              ,; // 14
                      T_NOTAS->F2_ZHEN    ,; // 15
                      T_NOTAS->F2_ZUEN    }) // 16

      T_NOTAS->( DbSkip() )
       
   ENDDO   

   If Len(aLista) == 0
      aAdd( aLista, { .F., "1", "1", "1", "1", "", "", "", "", "", "", "", "", "", "", "" })
   Else

      // ############################# 
      // Trata os boletos bancários ##
      // #############################
      ADir("J:\BOLETO*.HTM", aFiles, aSizes)

      // #################################
      // Copia os Arquivos selecionados ##
      // #################################
      nCount := Len( aFiles )

      For nContar = 1 to Len(aLista)

          cBoleto := "BOLETO_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt)

          // ###########################################################
          // Verifica se o arquivo está contido no array do diretório ##
          // ###########################################################
          For nX := 1 to nCount  
                                     
              If U_P_CORTA(aFiles[nX], "_", 1) + "_" + ;
                 U_P_CORTA(aFiles[nX], "_", 2) + "_" + ;
                 U_P_CORTA(aFiles[nX], "_", 3) + "_" + ;
                 U_P_CORTA(aFiles[nX], "_", 4) == cBoleto
//                 __CopyFile( "J:\" + aFiles[nX], "C:\XMLDANFEBOL\" + aFiles[nX])

//               If File("C:\XMLDANFEBOL\" + aFiles[nX])
                 If File("J:\" + aFiles[nX])
                    aLista[nContar,05] := "6"
                 Endif   

              Endif
              
          Next nX

      Next nContar                  

/*

      // ############################# 
      // Trata os boletos bancários ##
      // #############################
      ADir("C:\XMLDANFEBOL\*.HTM", aFiles, aSizes)

      // #################################
      // Copia os Arquivos selecionados ##
      // #################################
      nCount := Len( aFiles )

      For nContar = 1 to Len(aLista)

          cBoleto := "BOLETO_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt)

          // ###########################################################
          // Verifica se o arquivo está contido no array do diretório ##
          // ###########################################################
          For nX := 1 to nCount  
          
              If U_P_CORTA(aFiles[nX], "_", 1) + "_" + ;
                 U_P_CORTA(aFiles[nX], "_", 2) + "_" + ;
                 U_P_CORTA(aFiles[nX], "_", 3) + "_" + ;
                 U_P_CORTA(aFiles[nX], "_", 4) == cBoleto
                 aLista[nContar,05] := "6"
              Endif
              
          Next nX

      Next nContar                  

*/

   Endif   

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo)                      ,;
                        If(aLista[oLista:nAt,02] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,02] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,02] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,02] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,02] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,02] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,02] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,02] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,02] == "9", oCancel, "")))))))))  ,;                         
                        If(aLista[oLista:nAt,03] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,03] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,03] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,03] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,03] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,03] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,03] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,03] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,03] == "9", oCancel, "")))))))))  ,;                         
                        If(aLista[oLista:nAt,04] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,04] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,04] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,04] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,04] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,04] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,04] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,04] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,04] == "9", oCancel, "")))))))))  ,;                         
                        If(aLista[oLista:nAt,05] == "1", oBranco               ,;
                        If(aLista[oLista:nAt,05] == "2", oVerde                ,;
                        If(aLista[oLista:nAt,05] == "3", oPink                 ,;                         
                        If(aLista[oLista:nAt,05] == "4", oAmarelo              ,;                         
                        If(aLista[oLista:nAt,05] == "5", oAzul                 ,;                         
                        If(aLista[oLista:nAt,05] == "6", oLaranja              ,;                         
                        If(aLista[oLista:nAt,05] == "7", oPreto                ,;                         
                        If(aLista[oLista:nAt,05] == "8", oVermelho             ,;
                        If(aLista[oLista:nAt,05] == "9", oCancel, "")))))))))  ,;                         
                           aLista[oLista:nAt,06]                               ,;
                           aLista[oLista:nAt,07]                               ,;
                           aLista[oLista:nAt,08]                               ,;
                           aLista[oLista:nAt,09]                               ,;
                           aLista[oLista:nAt,10]                               ,;
                           aLista[oLista:nAt,11]                               ,;
                           aLista[oLista:nAt,12]                               ,;
                           aLista[oLista:nAt,13]                               ,;
                           aLista[oLista:nAt,14]                               ,;                           
                           aLista[oLista:nAt,15]                               ,;                           
                           aLista[oLista:nAt,16]                               }}

   If lComErro == .T.
      MsgAlert("Atenção!"                                             + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Existe(m) documento(s) gerado(s) com inconsistência." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Gere estes documentos novamente antes de enviá-los.") 
   Endif

Return(.T.)

// ##########################################
// Função que abre os tickert no FreshDesk ##
// ##########################################
Static Function AbrTicketFD()

   MsgRun("Aguarde! Abrindo Teckets FreshDesk ...", "Abertura de Tickets",{|| xAbrTicketFD() })

Return(.T.)

// ##########################################
// Função que abre os tickert no FreshDesk ##
// ##########################################
Static Function xAbrTicketFD()

   Local nContar      := 0
   Local lMarcado     := .F.
   Local cString      := ""
   Local aFiles       := {} // O array receberá os nomes dos arquivos e do diretório
   Local aSizes       := {} // O array receberá os tamanhos dos arquivos e do diretorio
   Local lTemArquivos := .F.
   Local kAbreEmail   := 0
   Local kEnde01      := Space(250)
   Local kEnde02      := Space(250)
   Local kEnde03      := Space(250)
   Local kEnde04      := Space(250)
   Local kEnde05      := Space(250)

   // ###################################################
   // Verifica se houve pelo menos um registro marcado ##
   // ###################################################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar          
 
   If lMarcado == .F.
      MsgAlert("Nenhum registro foi marcado para abertura de ticket. Verifique!")
      Return(.T.)
   Endif
   
   // #########################################################################
   // Carrega os emails a serem enviados a abertura dos Tickets no FreshDesk ##
   // #########################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ET01," 
   cSql += "       ZZ4_ET02,"  
   cSql += "       ZZ4_ET03,"  
   cSql += "       ZZ4_ET04,"  
   cSql += "       ZZ4_ET05 "        
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      kEnde01 := Space(250)
      kEnde02 := Space(250)
      kEnde03 := Space(250)
      kEnde04 := Space(250)
      kEnde05 := Space(250)
   Else
      kEnde01 := T_PARAMETROS->ZZ4_ET01
      kEnde02 := T_PARAMETROS->ZZ4_ET02
      kEnde03 := T_PARAMETROS->ZZ4_ET03
      kEnde04 := T_PARAMETROS->ZZ4_ET04
      kEnde05 := T_PARAMETROS->ZZ4_ET05                  
   Endif

   If Empty(Alltrim(kEnde01) + Alltrim(kEnde02) + Alltrim(kEnde03) + Alltrim(kEnde04) + Alltrim(kEnde05))
      MsgAlert("Atenção! Nenhum e-mail parametrizado para abertura de tickets no FreshDesk. Verifique!")
      Return(.T.)
   Endif   

   If !Empty(Alltrim(kEnde01))
      kAbreEmail := kAbreEmail + 1
   Endif

   If !Empty(Alltrim(kEnde02))
      kAbreEmail := kAbreEmail + 1
   Endif

   If !Empty(Alltrim(kEnde03))
      kAbreEmail := kAbreEmail + 1
   Endif

   If !Empty(Alltrim(kEnde04))
      kAbreEmail := kAbreEmail + 1
   Endif

   If !Empty(Alltrim(kEnde05))
      kAbreEmail := kAbreEmail + 1
   Endif

   // ###########################################################
   // Abre os Tickets no FreshDesk dos documentos selecionados ##
   // ###########################################################
   For nContar = 1 to Len(aLista)
   
       If aLista[nContar,01] == .F.
          Loop
       Endif

       For kkAbre = 1 to kAbreEmail

           j := Strzero(kkAbre,2)

           lTemArquivos := .F.
       
           cString := ""
           //cString := cString + "https://automatech.freshdesk.com/api/v2/tickets spnhw8plbrylRRRYPOpN agatendimento3@terca.com.br"   + " "

           If kkAbre == 1
              If !Empty(Alltrim(kEnde01))
                 kEndereco := Alltrim(kEnde01)
              Endif   
           Endif   

           If kkAbre == 2
              If !Empty(Alltrim(kEnde02))
                 kEndereco := Alltrim(kEnde02)
              Endif   
           Endif   

           If kkAbre == 3
              If !Empty(Alltrim(kEnde03))
                 kEndereco := Alltrim(kEnde03)
              Endif   
           Endif   

           If kkAbre == 4
              If !Empty(Alltrim(kEnde04))
                 kEndereco := Alltrim(kEnde04)
              Endif   
           Endif   

           If kkAbre == 5
              If !Empty(Alltrim(kEnde05))
                 kEndereco := Alltrim(kEnde05)
              Endif   
           Endif   

           cString := cString + "c:\retorno\retorno.txt https://automatech.freshdesk.com/api/v2/tickets "+ Alltrim(cToken) +" "+ Alltrim(kEndereco) + " "
           cString := cString + '" OL - ES - NF '   + Alltrim(aLista[nContar,07]) + "/" + Alltrim(aLista[nContar,08]) + " - Transp. " + aLista[nContar,13] + '" '
           cString := cString + '"Segue em anexo documentos conforme dados abaixo: <br><br>'
           cString := cString + 'Nota Fiscal: '    + Alltrim(aLista[nContar,07]) + '/' + Alltrim(aLista[nContar,08]) + '<br>'
           cString := cString + 'Transportadora: ' + Alltrim(aLista[nContar,13]) + '<br>'
           cString := cString + 'Cliente: '        + Alltrim(aLista[nContar,12]) + '<br>'
           cString := cString + 'Data Emissao: '   + aLista[nContar,06] + '"'
           cString := cString + " " + "2"
           cString := cString + " " + "1"        
           cString := cString + ' "s:type=Info Documentos" '
           cString := cString + ' "s:custom_fields[cnpj_ou_cpf]=11111111111111" '
           cString := cString + ' "s:custom_fields[infodoc_transportadora]=' + Alltrim(aLista[nContar,13]) + '"'
           cString := cString + ' "s:custom_fields[infodoc_nota_fiscal]=' + Alltrim(aLista[nContar,07]) + '/' + Alltrim(aLista[nContar,08]) + '"'
           cString := cString + ' "s:custom_fields[infodoc_cliente]=' + Alltrim(aLista[nContar,12]) + '"'

           // #####################
           // Carrega os anexnos ##
           // #####################
           If aLista[nContar,03] == "6"
              If File("C:\XMLDANFEBOL\XML_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt) + ".XML")
                 cString := cString + " f:" + "C:\XMLDANFEBOL\XML_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt) + ".XML"
                 lTemArquivos := .T.
              Endif   
           Endif
                     
           If aLista[nContar,04] == "6"
              If File("C:\XMLDANFEBOL\DANFE_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt) + ".PDF")
                 cString := cString + " f:" + "C:\XMLDANFEBOL\DANFE_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt) + ".PDF"
                 lTemArquivos := .T.
              Endif   
           Endif
   
           If aLista[nContar,05] == "6"

              // ############################# 
              // Trata os boletos bancários ##
              // #############################
              // ADir("C:\XMLDANFEBOL\BOLETO*.HTM", aFiles, aSizes)
              ADir("J:\BOLETO*.HTM", aFiles, aSizes)

              // #################################
              // Copia os Arquivos selecionados ##
              // #################################
              nCount := Len( aFiles )

              // ####################################################  
              // Monta o nome do arquivo a ser procurado e anexado ##
              // ####################################################
              cBoleto := "BOLETO_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt)

              // ###########################################################
              // Verifica se o arquivo está contido no array do diretório ##
              // ###########################################################
              For nX := 1 to nCount  
          
                  If U_P_CORTA(aFiles[nX], "_", 1) + "_" + ;
                     U_P_CORTA(aFiles[nX], "_", 2) + "_" + ;
                     U_P_CORTA(aFiles[nX], "_", 3) + "_" + ;
                     U_P_CORTA(aFiles[nX], "_", 4) == cBoleto
                     //cString := cString + " f:" + "C:\XMLDANFEBOL\" + aFiles[nX]
                     cString := cString + " f:" + "J:\" + aFiles[nX]
                     lTemArquivos := .T.
                  Endif   

              Next nX

           Endif

           If lTemArquivos == .F.
              MsgAlert("Não existem arquivos a serem anexados ao Ticket")
              Loop
           Endif

           // #######################################################
           // Executa o comando de aberetura do ticket no FresDesk ##
           // #######################################################
           x := WinExec('AtechHttpPostAttachmentsFresh.exe' + ' ' + cString)

           // ##########################################
           // Atualiza os dados de abertura do ticket ##
           // ##########################################
           cSql := ""
           cSql := "UPDATE " + RetSqlName("SF2")
           cSql += "   SET"
           cSql += "   F2_ZEEN = '1',"
 	       cSql += "   F2_ZDEN = '" + Strzero(year(Date()),4) + Strzero(month(Date()),2) + Strzero(day(Date()),2) + "', "
 	       cSql += "   F2_ZHEN = '" + Time()                             + "',"
 	       cSql += "   F2_ZUEN = '" + Alltrim(cUserName)                 + "',"
 	       cSql += "   F2_ZXML = '" + IIF(aLista[nContar,03] == "6", "1", "0")      + "',"
 	       cSql += "   F2_ZDNF = '" + IIF(aLista[nContar,04] == "6", "1", "0")      + "',"
 	       cSql += "   F2_ZBLT = '" + IIF(aLista[nContar,05] == "6", "1", "0")      + "' "
           cSql += " WHERE F2_FILIAL  = '" + Alltrim(cFilAnt)            + "'"
           cSql += "   AND F2_DOC     = '" + Alltrim(aLista[nContar,07]) + "'"
           cSql += "   AND F2_SERIE   = '" + Alltrim(aLista[nContar,08]) + "'"
           cSql += "   AND F2_CLIENTE = '" + Alltrim(aLista[nContar,10]) + "'"
           cSql += "   AND F2_LOJA    = '" + Alltrim(aLista[nContar,11]) + "'"

           lResult := TCSQLEXEC(cSql)
           
           
       Next kkAbre

   Next nContar

   // ######################################################
   // Atualiza novamente a tela após abertura dos tickets ##
   // ######################################################
   PdqNFTicket()

Return(.T.)                                        

// #######################################################
// Função que gera o XML das notas fiscais selecionadas ##
// #######################################################
Static Function GeraXMLNFSEL()

   MsgRun("Aguarde! Gerando XML(s) da(s) Nota(s) Fiscal(is) Selecionada(s) ...", "Arquivo XML",{|| xGeraXMLNFSEL() })

Return(.T.)

// #######################################################
// Função que gera o XML das notas fiscais selecionadas ##
// #######################################################
Static Function xGeraXMLNFSEL()

   Local nContar     := 0
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

   If Empty(Alltrim(aLista[oLista:nAt,07]))
      MsgAlert("Nenhuma nota fiscal selecionada para geração de XML. Verifique!")
      Return(.T.)
   Endif   

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lTemMarcado := .T.
          Exit
       Endif
   Next nContar       

   If lTemMarcado == .F.
      MsgAlert("Nenhuma nota fiscal selecionada para geração do XML. Verifique!")
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
      Case cEmpAnt == "01" .And. cFilAnt == "01"
           kChave := "000001"
      Case cEmpAnt == "01" .And. cFilAnt == "02"
           kChave := "000002"
      Case cEmpAnt == "01" .And. cFilAnt == "03"
           kChave := "000003"
      Case cEmpAnt == "01" .And. cFilAnt == "05"
           kChave := "000011"
      Case cEmpAnt == "01" .And. cFilAnt == "06"
           kChave := "000010"
      Case cEmpAnt == "02" .And. cFilAnt == "01"
           kChave := "000004"
      Case cEmpAnt == "03" .And. cFilAnt == "01"
           kChave := "000009"
      Case cEmpAnt == "04" .And. cFilAnt == "01"
           kChave := "000013"
   EndCase           

   // ############################################
   // Gera o XML das notas fiscais selecionadas ##
   // ############################################
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif                                 

       // #############################################
       // Fecha o arquivo de retorno para eliminação ##
       // #############################################
       FCLOSE(cRetorno)

       // ##############################################################################
       // Elimina o Arquivo para receber nova cotação do dolar no diretório TAXADOLAR ##
       // ##############################################################################
       FERASE(cRetorno)

       kDocumento := StrTran(aLista[nContar,08] + aLista[nContar,07], " ", "%20")

       // ###############
       // Developer 11 ##
       // ###############
//     cUrl := "http://54.94.245.225/AtechProtheusDataWS11Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kChave

       // ##############
       // Produção 11 ##
       // ##############
//       cUrl := "http://54.94.245.225/AtechProtheusDataWS11Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kChave

       // ###############
       // Developer 12 ##
       // ###############
//     cUrl := "http://54.94.245.225/AtechProtheusDataWS12Dev/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kChave


       // ##############
       // Produção 12 ##
       // ##############
//     cUrl := "http://54.94.245.225/AtechProtheusDataWS12Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kChave

       cUrl := "http://srv-erp/AtechProtheusDataWS12Prod/SPED050.aspx?NFE_ID=" + kDocumento + "&ID_ENT=" + kChave
       
       // ##############################################################################
       // Envia a solicitação de cotação da taxa do dolar                             ##
       // http://192.168.0.84/AtechProtheusDataWS/?NFE_ID=6%20%20001208&ID_ENT=000010 ##
       // ##############################################################################
       WaitRun('AtechHttpget.exe' + ' "' + cUrl + '" ' + cRetorno, SW_SHOWNORMAL )
  
       // ###########################
       // Lê o retorno da consulta ##
       // ###########################
       //   lExiste     := .F.
       //   nTentativas := 0
       //
       //   while nTentativas < cSTIM
       //
       //      If File(cRetorno)
       //         lExiste := .T.
       //         Exit
       //      Endif
       //
       //      nTentativas := nTentativas + 1
       //
       //   Enddo
       //
       //   If lExiste == .F.
       //      Return(.T.)
       //   Endif

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
          MsgAlert("Assinatura do XML do documento Nr " + aLista[nContar,08] + "/" + aLista[nContar,07] + " não localizada." + cValToChar( FError() ))
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
          Loop
       Endif   

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

       // ######################################
       // Utilizado para rodar no Protheus 11 ##
       // ######################################
       // cSql += "        P11_TSS..SPED054 AS SPED, "                                        + CHR(13)
        
       // ######################################
       // Utilizado para rodar no Protheus 12 ##
       // ###################################### 
       cSql += "        P12_TSS..SPED054 AS SPED, "                               + CHR(13)

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
       cSql += "   AND F2_DOC            = '" + Alltrim(aLista[nContar,07]) + "'"          + CHR(13)
       cSql += "   AND F2_SERIE          = '" + Alltrim(aLista[nContar,08]) + "'"          + CHR(13)
       cSql += "   AND F2_FILIAL         = '" + Alltrim(cFilAnt)            + "'"          + CHR(13)
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

       cCaminho := "C:\XMLDANFEBOL\XML_" + Alltrim(aLista[nContar,07]) + "_" + Alltrim(aLista[nContar,08]) + "_" + Alltrim(cFilAnt) + ".XML"

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
       
   Next nContar    
       
   // ############################################
   // Atualiza o grid da tela para visualização ##
   // ############################################
   xPdqNFTicket()

Return(.T.)

// ############################################################################################################################################
// Forum sobre campos memo ADVPL                                                                                                             ##
// http://www.helpfacil.com.br/forum/display_topic_threads.asp?ForumID=1&TopicID=39514&PagePosition=3                                        ##
// ############################################################################################################################################
//http://tdn.totvs.com/display/tec/Melhoria+-+Suporte+a+campo+MEMO+com+mais+de+1+MB                                                          ##
// No Dbacess.Ini inclui na tag GENERAL                                                                                                      ##
// MaxStringSize=10 (corresponde a 10 mb)                                                                                                    ##
//Você não vai precisar de nenhum índice, você vai fazer a query para recuperar o R_E_C_N_O_ do registro que você quer, usando um outro nome ##
//                                                                                                                                           ##
//SELECT CAMPO1,CAMPO2, R_E_C_N_O_ AS RECNO FROM SPED050 WHERE ORDER BY                                                                      ##
//                                                                                                                                           ##
//Ao abrir a query, você posiciona no registro correspondente da SPED050 usando SPED050->(DBGOTO(QRY->RECNO))                                ##
//                                                                                                                                           ##
//Se voce abrir a SPED050 na mão, feche-a depois usando DBCloseArea()                                                                        ##
//                                                                                                                                           ##
//       // #######################                                                                                                          ##
//       // Abre a tebal SPED050 ##                                                                                                          ##
//       // #######################                                                                                                          ##
//       USE SPED054 ALIAS SPED054 SHARED NEW VIA "TOPCONN"                                                                                  ##
//                                                                                                                                           ##
//                                                                                                                                           ##
//       IF NetErr()                                                                                                                         ##
//          MsgAlert("Falha ao abrir SPED050")                                                                                               ##
//       Endif                                                                                                                               ##
//                                                                                                                                           ##
//       SPED054->(DBGOTO(T_GERAXML->REG_XML))                                                                                               ##
//                                                                                                                                           ##
//       A:=1                                                                                                                                ##
//                                                                                                                                           ##
//       DBCloseArea()                                                                                                                       ##
// ############################################################################################################################################

// ################################################################################
// Função que confirma o endereço de e-mail para abertura do ticket do freshdesk ##
// ################################################################################
//Static Function xEnderecoE()
//
//   Local cEndereco := Alltrim(kEndereco) + Space(250 - Len(kEndereco))
//   Local oGet1
//
//   Private oDlgEnd
//
//   DEFINE MSDIALOG oDlgEnd TITLE "Abertura de Ticket FreshDesk" FROM C(178),C(181) TO C(314),C(576) PIXEL
//
//   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgEnd
//
//   @ C(029),C(005) Say "Abrir FreshDesk para o endereço de e-mail" Size C(111),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnd
//
//   @ C(038),C(005) MsGet oGet1 Var cEndereco Size C(189),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnd
//
//   @ C(052),C(064) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgEnd ACTION( xSaiEnderecoE(cEndereco) )
//   @ C(052),C(103) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgEnd ACTION( oDlgEnd:End() )
//
//   ACTIVATE MSDIALOG oDlgEnd CENTERED 
//
//Return(.T.)

// ##################################################################################################
// Função que valida e encerra a tela de solicitação do endereço de e-mail para abertura do ticket ##
// ##################################################################################################
//Static Function xSaiEnderecoE(_Endereco)
//
//   If Empty(Alltrim(_Endereco))
//      MsgAlert("Necessário informar o endereço de e-mail para abertura do ticket.")
//      Return(.T.)
//   Endif
//         
//   kEndereco := _Endereco
//   
//   oDlgEnd:End()
//   
//Return(.T.)

// ###################################################################################
// Função que confirma altera o parâmetro de e-mails a serem enviados os documentos ##
// ###################################################################################
Static Function xAltEmail()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private kEmail01	:= Space(250)
   Private kEmail02 := Space(250)
   Private kEmail03 := Space(250)
   Private kEmail04	:= Space(250)
   Private kEmail05 := Space(250)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlgEM

   // ###############################################################
   // Pesquisa os e-mail na tabela ZZ4 - Parametrizador Automatech ##
   // ###############################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ET01," 
   cSql += "       ZZ4_ET02,"  
   cSql += "       ZZ4_ET03,"  
   cSql += "       ZZ4_ET04,"  
   cSql += "       ZZ4_ET05 "        
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      kEmail01 := T_PARAMETROS->ZZ4_ET01
      kEmail02 := T_PARAMETROS->ZZ4_ET02
      kEmail03 := T_PARAMETROS->ZZ4_ET03
      kEmail04 := T_PARAMETROS->ZZ4_ET04
      kEmail05 := T_PARAMETROS->ZZ4_ET05                  
   Endif

   DEFINE MSDIALOG oDlgEM TITLE "E-mails abertura de ticket FreshDesk Terca" FROM C(178),C(181) TO C(411),C(564) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp" Size C(106),C(022) PIXEL NOBORDER OF oDlgEM

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(185),C(001) PIXEL OF oDlgEM

   @ C(034),C(005) Say "Informe abaixo os e-mails de envio e abertura de Ticket FreskDesk (TERCA)" Size C(182),C(008) COLOR CLR_BLACK PIXEL OF oDlgEM

   @ C(044),C(005) MsGet oGet1 Var kEmail01 Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEM
   @ C(054),C(005) MsGet oGet2 Var kEmail02 Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEM
   @ C(065),C(005) MsGet oGet3 Var kEmail03 Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEM
   @ C(075),C(005) MsGet oGet4 Var kEmail04 Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEM
   @ C(086),C(005) MsGet oGet5 Var kEmail05 Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEM

   @ C(100),C(079) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgEM ACTION( xGrvEmail() )

   ACTIVATE MSDIALOG oDlgEM CENTERED 

Return(.T.)

// #######################################################
// Função que grava os emails informados e fecha a tela ##
// #######################################################
Static Function xGrvEmail()                               

   Local cSql := ""

   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_ET01   := kEmail01
      ZZ4_ET02   := kEmail02
      ZZ4_ET03   := kEmail03
      ZZ4_ET04   := kEmail04
      ZZ4_ET05   := kEmail05                  
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_ET01   := kEmail01
      ZZ4_ET02   := kEmail02
      ZZ4_ET03   := kEmail03
      ZZ4_ET04   := kEmail04
      ZZ4_ET05   := kEmail05                  
   Endif

   MsUnLock()

   oDlgEM:End() 
   
Return(.T.)