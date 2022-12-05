#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativa��o
#define SW_SHOW             5 // Mostra na posi��o mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posi��o anterior
#define SW_SHOWDEFAULT      10// Posi��o padr�o da aplica��o
#define SW_FORCEMINIMIZE    11// For�a minimiza��o independente da aplica��o executada
#define SW_MAX              11// Maximizada

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM595.PRW                                                            ##
// Par�metros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                 ##
// Data......: 02/08/2018                                                              ##
// Objetivo..: Programa que abre/fecha Ticket no freshdesk referente ao controle de    ##
//             demonstra��o de produtos a Clientes.                                    ##
// Par�metros: kOperacao  = Indica a opera��o A = Abertura, F = Fechamento do Ticket   ##
//             kPedido    = N� do Pedido de Venda                                      ##
//             kFilial    = C�digo da Filial do Documento                              ##
//             kDocumento = N� da Nota Fiscal                                          ##
//             kSerie     = S�rie da Nota Fiscal                                       ##
//             kCodCli    = C�digo do Cliente                                          ##
//             kLojCli    = Loja do Cliente                                            ##
//             kTicket    = N� do Tocket a ser Fechado                                 ##
// ######################################################################################

User Function AUTOM595( kOperacao, kPedido, kFilial, kDocumento, kSerie, kCodCli, kLojCli, kTicket)
            	
   Local cString     := ""
   Local cProdutos   := ""
   Local cSURL       := ""
   Local cEnvio      := "C:\FRESHDESK\ENVIODEMO.TXT"
   Local cRetorno    := "C:\FRESHDESK\RETORNODEMO.TXT"
   Local nRet        := MakeDir( "C:\FRESHDESK" )   
   Local nTimeOut    := 0
   Local aHeadOut    := {}
   Local cHeadRet    := ""
   Local sPostRet    := Nil
   Local cSTIM       := 1000000
   Local nTentativas := 0
   Local lExiste     := .F.
   Local lPrimeiro   := .T.
   Local nNomeCli    := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_NOME"  )
   Local cCnpj       := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_CGC"   )
   Local cInscricao  := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_INSCR" )
   Local cEndereco   := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_END"   )
   Local cBairro     := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_BAIRRO")
   Local cCep        := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_CEP"   )
   Local cCidade     := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_MUN"   )
   Local cEstado     := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodCli + kLojCli, "A1_EST"   )
   Local cEVendedor  := ""
   Local cNomeVende  := ""

   U_AUTOM628("AUTOM595")

return(.t.)

   // ###########################################
   // Verifica se existe o diret�rio FRESHDESK ##
   // ###########################################
   If FILE("C:\FRESHDESK")
   Else
      If nRet != 0
         MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "N�o foi poss�vel criar o diret�rio C:\FRESHDESK." + CHR(13) + CHR(10) + "Crie o diret�rio C:\FRESHDESK em seu equipamento.")
         Return(.T.)
      Endif
   Endif   

   // ###############################################
   // Prepara o CNPJ/CPF e o CEP para visualiza��o ##
   // ###############################################
   If Len(Alltrim(cCnpj)) == 14
      cCnpj := Substr(cCnpj,01,02) + '.' + Substr(cCnpj,03,03) + '.' + Substr(cCnpj,06,03) + '/' + Substr(cCnpj,09,04) + '-' + Substr(cCnpj,13,02)
   Else
      cCnpj := Substr(cCnpj,01,03) + '.' + Substr(cCnpj,04,03) + '.' + Substr(cCnpj,07,03) + '-' + Substr(cCnpj,10,02)
   Endif
    
   cCep := Substr(cCep,01,02) + '.' + Substr(cCep,03,03) + '-' + Substr(cCep,06,03)

   // ############################################################
   // Prepara a URL conforme o tipo de Opera��o a ser realizada ##
   // ############################################################
   If kOperacao == "A"
      cSURL := "https://automatech.freshdesk.com/api/v2/tickets"
   Else      
      cSURL := "https://automatech.freshdesk.com/api/v2/tickets/" + Alltrim(kTicket)
   Endif   

   // #####################################################
   // Pesquisa o e-mail do vendedor para envio do ticket ##
   // #####################################################
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SF2.F2_VEND1,"
   cSql += "       SA3.A3_NOME ,"
   cSql += "       SA3.A3_EMAIL "
   cSql += "  FROM " + RetSqlname("SF2") + " SF2, "
   cSql += "       " + RetSqlName("SA3") + " SA3  "
   cSql += " WHERE SF2.F2_FILIAL  = '" + Alltrim(kFilial)    + "'"
   cSql += "   AND SF2.F2_DOC     = '" + Alltrim(kDocumento) + "'"
   cSql += "   AND SF2.F2_SERIE   = '" + Alltrim(kSerie)     + "'"
   cSql += "   AND SF2.F2_CLIENTE = '" + Alltrim(kCodCli)    + "'"
   cSql += "   AND SF2.F2_LOJA    = '" + Alltrim(kLojCli)    + "'"
   cSql += "   AND SF2.D_E_L_E_T_ = ''"
   cSql += "   AND SA3.A3_COD     = SF2.F2_VEND1"
   cSql += "   AND SA3.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( EOF() )

      cTexto := ""
      cTexto += "O pedido de DEMONSTRA��O n� " + Alltrim(kPedido) + " - "        + ;
                "Nota Fiscal n� " + Alltrim(kDocumento) + "/" + Alltrim(kSerie)  + ;
                " n�o teve seu Tickt aberto pelo motivo do e-mail do vendedor estar incorreto. <br><br>"       + ;
                "Vendedor: " + Alltrim(cNomeVende) + "<br><br>"                  + ;  
                "Seguem abaixo os dados: <br><br> "                              + ;
                "Dados da remessa de Demonstra��o <br><br> "                     + ;
                "Raz�o Social: " + Alltrim(nNomeCli) + "<br>"                    + ;
                "CNPJ: " + Alltrim(cCnpj) + "<br>"                               + ;
                "IE: " + Alltrim(cInscricao) + "<br>"                            + ;
                "Endereco: " + Alltrim(cEndereco) + "<br>"                       + ;
                "Bairro: " + Alltrim(cBairro) + "<br>"                           + ;
                "Cidade: " + Alltrim(cCEP) + " - " + Alltrim(cCidade) + " / " + Alltrim(cEstado) + "<br><br> " + ;
                "DESCRICAO DOS PRODUTOS: <br><br> "                              + ;
                cProdutos

      // ######################
      // Envia e-mail ao RMA ##
      // ######################
      U_AUTOMR20(cTexto , "rma@automatech.com.br", "", "ERRO NA ABERTURA DE TICKT DE DEMONSTRA��O DE MERCADORIA" )

      Return(.T.)
   Else
      cEVendedor := U_P_CORTA(Alltrim(T_VENDEDOR->A3_EMAIL) + ";", ";", 1)
      cNomeVende := T_VENDEDOR->A3_NOME
   Endif

   // #########################################
   // Elabora o Json para envio ao FreshDesk ##
   // #########################################
   If kOperacao == "A"

      cString := ''
      cString += '{'
      cString += ' "email": "' + Alltrim(cEVendedor) + '", '
      cString += ' "source": 2,'
      cString += ' "status": 2,'
      cString += ' "priority": 1,'
      
      // ######################################
      // Pesquisa os produtos da Nota Fiscal ##
      // ######################################

      cProdutos := ""
      
      dbSelectArea("SD2")
      dbSetOrder(3)
      dbSeek( kFilial + kDocumento + kSerie + kCodCli + kLojCli ) 

      WHILE SD2->( !EOF() ) .and. (kFilial + kDocumento + kSerie + kCodCli + kLojCli ) == SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )

         cProdutos += 'Part Number: ' + Alltrim(POSICIONE("SB1", 1, XFILIAL("SB1") + SD2->D2_COD, "B1_PARNUM")) + '<br> ' + ;
                      'Codigo Produto: ' + Alltrim(SD2->D2_COD) + '<br> '                                                 + ;
                      'Descricao: ' + Alltrim(POSICIONE("SB1", 1, XFILIAL("SB1") + SD2->D2_COD, "B1_DESC")) + '<br> '     + ;
                      'Quantidade: ' + Transform(SD2->D2_QUANT, "@E 9999999.99") + '<br><br>'

         dbSelectArea("SD2")
         SD2->( dbSkip() )
                      
      ENDDO
      
      cString += ' "description": "ABERTURA DE TICKT <br><br>O pedido de DEMONSTRACAO nr. ' + Alltrim(kPedido) + ;
                                  ' / Nota Fiscal nr. ' + Alltrim(kDocumento) + '/' + Alltrim(kSerie)          + ;
                                  ' foi faturado, mercadorias estao sendo enviadas. <br><br>' + ;
                                  'Seguem abaixo os dados: <br><br> '               + ;
                                  'Dados da remessa de Demonstracao <br><br> '      + ;
                                  'Razao Social: ' + Alltrim(nNomeCli) + '<br>'     + ;
                                  'CNPJ: ' + Alltrim(cCnpj) + '<br>'                + ;
                                  'IE: ' + Alltrim(cInscricao) + '<br>'             + ;
                                  'Endereco: ' + Alltrim(cEndereco) + '<br> '       + ;
                                  'Bairro: ' + Alltrim(cBairro) + '<br> '           + ;
                                  'Cidade: ' + Alltrim(cCEP) + ' - ' + Alltrim(cCidade) + ' / ' + Alltrim(cEstado) + '<br><br> ' + ;
                                  'DESCRICAO DOS PRODUTOS: <br><br> '               //+ ;
      cString += cProdutos + '",'
      cString += ' "email_config_id": 16000023371,'
      cString += ' "group_id": 16000079978,'
      cString += ' "type": "Info Demos",'
      cString += ' "custom_fields": {'
      cString += '    "cnpj_ou_cpf": "' + Alltrim(cCnpj) + '"'
      cString += '  } '
      cString += '}'

   Else   

      cString := ''
      cString += '{'
      cString += ' "email": "' + Alltrim(cEVendedor) + '", '
      cString += ' "source": 2,'
      cString += ' "status": 5,'
      cString += ' "priority": 1,'

      // ######################################
      // Pesquisa os produtos da Nota Fiscal ##
      // ######################################

      cProdutos := ""
      
      dbSelectArea("SD2")
      dbSetOrder(3)
      dbSeek( kFilial + kDocumento + kSerie + kCodCli + kLojCli ) 

      WHILE SD2->( !EOF() ) .and. (kFilial + kDocumento + kSerie + kCodCli + kLojCli ) == SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )

         cProdutos += 'Part Number: ' + Alltrim(POSICIONE("SB1", 1, XFILIAL("SB1") + SD2->D2_COD, "B1_PARNUM")) + '<br> ' + ;
                      'Codigo Produto: ' + Alltrim(SD2->D2_COD) + '<br> '                                                 + ;
                      'Descricao: ' + Alltrim(POSICIONE("SB1", 1, XFILIAL("SB1") + SD2->D2_COD, "B1_DESC")) + '<br> '     + ;
                      'Quantidade: ' + Transform(SD2->D2_QUANT, "@E 9999999.99") + '<br><br>'

         dbSelectArea("SD2")
         SD2->( dbSkip() )
                      
      ENDDO

      If kOperacao == "F"
         cString += ' "description": "FECHAMENTO DO TICKT <br><br>O pedido de DEMONSTRACAO nr. ' + Alltrim(kPedido) + ;
                                     ' / Nota Fiscal nr. ' + Alltrim(kDocumento) + '/' + Alltrim(kSerie)          + ;
                                     ' foi RETORNADO, mercadorias foram devolvidas. <br><br>' + ;
                                     'Tickt ' + Alltrim(kTicket) + ' de acompanhamento foi encerrado. <br><br>' + ; 
                                     'Seguem abaixo os dados: <br><br> '               + ;
                                     'Dados da remessa de Demonstracao <br><br> '      + ;
                                     'Razao Social: ' + Alltrim(nNomeCli) + '<br>'     + ;
                                     'CNPJ: ' + Alltrim(cCnpj) + '<br>'                + ;
                                     'IE: ' + Alltrim(cInscricao) + '<br>'             + ;
                                     'Endereco: ' + Alltrim(cEndereco) + '<br> '       + ;
                                     'Bairro: ' + Alltrim(cBairro) + '<br> '           + ;
                                     'Cidade: ' + Alltrim(cCEP) + ' - ' + Alltrim(cCidade) + ' / ' + Alltrim(cEstado) + '<br><br> ' + ;
                                     'DESCRICAO DOS PRODUTOS: <br><br> '               //+ ;
         cString += cProdutos + '",'
         cString += ' "email_config_id": 16000023371,'
         cString += ' "group_id": 16000079978,'
         cString += ' "type": "Info Demos",'
         cString += ' "custom_fields": {'
         cString += '    "cnpj_ou_cpf": "' + Alltrim(cCnpj) + '"'
         cString += '  } '
         cString += '}'
      Else  
         cString += ' "description": "FECHAMENTO DO TICKT <br><br>O pedido de DEMONSTRACAO nr. ' + Alltrim(kPedido) + ;
                                     ' / Nota Fiscal nr. ' + Alltrim(kDocumento) + '/' + Alltrim(kSerie)          + ;
                                     ' foi EXCLUIDA. <br><br>' + ;
                                     'Tickt ' + Alltrim(kTicket) + ' de acompanhamento foi encerrado. <br><br>' + ; 
                                     'Seguem abaixo os dados: <br><br> '               + ;
                                     'Dados da remessa de Demonstracao <br><br> '      + ;
                                     'Razao Social: ' + Alltrim(nNomeCli) + '<br>'     + ;
                                     'CNPJ: ' + Alltrim(cCnpj) + '<br>'                + ;
                                     'IE: ' + Alltrim(cInscricao) + '<br>'             + ;
                                     'Endereco: ' + Alltrim(cEndereco) + '<br> '       + ;
                                     'Bairro: ' + Alltrim(cBairro) + '<br> '           + ;
                                     'Cidade: ' + Alltrim(cCEP) + ' - ' + Alltrim(cCidade) + ' / ' + Alltrim(cEstado) + '<br><br> ' + ;
                                     'DESCRICAO DOS PRODUTOS: <br><br> '               //+ ;
         cString += cProdutos + '",'
         cString += ' "email_config_id": 16000023371,'
         cString += ' "group_id": 16000079978,'
         cString += ' "type": "Info Demos",'
         cString += ' "custom_fields": {'
         cString += '    "cnpj_ou_cpf": "' + Alltrim(cCnpj) + '"'
         cString += '  } '
         cString += '}'
      Endif
   Endif
   
   // ########################################################################################
   // Elimina o arquivo de enviodemo.txt e retornodemo.txt antes de enviar nova solicita��o ##
   // ########################################################################################
   If File("C:\FRESHDESK\ENVIODEMO.TXT")
      fErase("C:\FRESHDESK\ENVIODEMO.TXT")
   Endif

   If File("C:\FRESHDESK\RETORNODEMO.TXT")
      fErase("C:\FRESHDESK\RETORNODEMO.TXT")
   Endif   

   // ######################################################
   // Cria o arquivo de envio da solicita��o ao FreshDesk ##
   // ######################################################
   nHdl := fCreate("C:\FRESHDESK\ENVIODEMO.TXT")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   // ##########################################################################################################################################################
   // Exemplo de envio do comando                                                                                                                             ##
   // AtechHttpPost.exe https://automatech.freshdesk.com/api/v2/tickets C:\retorno.txt C:\envio.txt application/json "Basic c3BuaHc4cGxicnlsUlJSWVBPcE46eA==" ##
   // ##########################################################################################################################################################
   If kOperacao == "A"   
      WinExec('AtechHttpPost2.exe' + ' ' + Alltrim(cSURL) + ' ' + 'C:\FRESHDESK\RETORNODEMO.TXT' + ' ' + 'C:\FRESHDESK\ENVIODEMO.TXT' + ' ' + 'application/json' + ' ' + '"Basic c3BuaHc4cGxicnlsUlJSWVBPcE46eA=="')
   Else
      WinExec('AtechHttpPut.exe' + ' ' + Alltrim(cSURL) + ' ' + 'C:\FRESHDESK\RETORNODEMO.TXT' + ' ' + 'C:\FRESHDESK\ENVIODEMO.TXT' + ' ' + 'application/json' + ' ' + '"Basic c3BuaHc4cGxicnlsUlJSWVBPcE46eA=="')         
   Endif
  
   // ###########################################################
   // Verifica se o arquivo de retorno foi criado no diret�rio ##
   // ###########################################################
   WHILE nTentativas < cSTIM
      If File("C:\FRESHDESK\RETORNODEMO.TXT")
         lExiste := .T.
         Exit
      Endif
      nTentativas := nTentativas + 1
   Enddo
                                       
   If lExiste == .F.
      Return(.T.)
   Endif

   // ##########################################
   // Trata o retorno do envio da solicita��o ##
   // ##########################################

   // #################################################################################
   // Abre o arquivo de retorno para capturar o c�digo do ticket gerado no freshdesk ##
   // #################################################################################
   nHandle := FOPEN("C:\FRESHDESK\RETORNODEMO.TXT", FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo C:\FRESHDESK\RETORNODEMO.TXT")
      Return .T.
   Endif

   // ################################
   // L� o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // L� todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   FCLOSE(nHandle)

   If U_P_OCCURS(xBuffer, '"id":',1) == 0
      MsgAlert("Erro ao abrir o Tickt no FreshDesk."          + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Envie este erro ao Administrador do Sistema." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Erro: "                                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
               Alltrim(xBuffer))

      cTexto := ""
      cTexto += "O pedido de DEMONSTRA��O n� " + Alltrim(kPedido) + " - "        + ;
                "Nota Fiscal n� " + Alltrim(kDocumento) + "/" + Alltrim(kSerie)  + ;
                " n�o teve seu Tickt aberto por motivos de erro. <br><br>"       + ;
                "Vendedor: " + Alltrim(cNomeVende) + "<br><br>"                  + ;  
                "Seguem abaixo os dados: <br><br> "                              + ;
                "Dados da remessa de Demonstra��o <br><br> "                     + ;
                "Raz�o Social: " + Alltrim(nNomeCli) + "<br>"                    + ;
                "CNPJ: " + Alltrim(cCnpj) + "<br>"                               + ;
                "IE: " + Alltrim(cInscricao) + "<br>"                            + ;
                "Endereco: " + Alltrim(cEndereco) + "<br>"                       + ;
                "Bairro: " + Alltrim(cBairro) + "<br>"                           + ;
                "Cidade: " + Alltrim(cCEP) + " - " + Alltrim(cCidade) + " / " + Alltrim(cEstado) + "<br><br> " + ;
                "DESCRICAO DOS PRODUTOS: <br><br> "                              + ;
                cProdutos

      // ######################
      // Envia e-mail ao RMA ##
      // ######################
      U_AUTOMR20(cTexto , "rma@automatech.com.br", "", "ENCERRAMENTO DE TICKT DE DEMONSTRA��O DE MERCADORIA" )

   Else

      // ##########################################
      // Atualiza o campo F2_ZTICK da Tabela SF2 ##
      // ##########################################
      cSql := "" 
      cSql := "UPDATE " + RetSqlName("SF2")
      cSql += "   SET "
      cSql += "   F2_ZTICK = '" + Substr(xBuffer, int(val(U_P_OCCURS(xBuffer, '"id":',2))) + 5,6) + "'"
      cSql += " WHERE F2_FILIAL  = '" + Alltrim(kFilial)    + "'"
      cSql += "   AND F2_DOC     = '" + Alltrim(kDocumento) + "'"
      cSql += "   AND F2_SERIE   = '" + Alltrim(kSerie)     + "'"
      cSql += "   AND F2_CLIENTE = '" + Alltrim(kCodCli)    + "'"  
      cSql += "   AND F2_LOJA    = '" + Alltrim(kLojCli)    + "'"

      _nErro := TcSqlExec(cSql) 

      If kOperacao == "A"

//       MsgAlert("Tickt de Controle FreshDesk (Abertura) com o n� " + substr(xBuffer, int(val(U_P_OCCURS(xBuffer, '"id":',2))) + 5,6))

         // #########################################################
         // Elabora o e-mail de aviso de abertura do Ticket ao RMA ##
         // #########################################################
         xNtickt :=substr(xBuffer, int(val(U_P_OCCURS(xBuffer, '"id":',2))) + 5,6)

         cTexto := ""
         cTexto += "O pedido de DEMONSTRA��O n� " + Alltrim(kPedido) + " - "        + ;
                   "Nota Fiscal n� " + Alltrim(kDocumento) + "/" + Alltrim(kSerie)  + ;
                   " foi faturado, mercadorias est�o sendo enviadas. <br><br>"      + ;
                   "Tickt N� " + Alltrim(xNtickt) + "<br><br>"                      + ;  
                   "Vendedor: " + Alltrim(cNomeVende) + "<br><br>"                  + ;  
                   "Seguem abaixo os dados: <br><br> "                              + ;
                   "Dados da remessa de Demonstra��o <br><br> "                     + ;
                   "Raz�o Social: " + Alltrim(nNomeCli) + "<br>"                    + ;
                   "CNPJ: " + Alltrim(cCnpj) + "<br>"                               + ;
                   "IE: " + Alltrim(cInscricao) + "<br>"                            + ;
                   "Endereco: " + Alltrim(cEndereco) + "<br>"                       + ;
                   "Bairro: " + Alltrim(cBairro) + "<br>"                           + ;
                   "Cidade: " + Alltrim(cCEP) + " - " + Alltrim(cCidade) + " / " + Alltrim(cEstado) + "<br><br> " + ;
                   "DESCRICAO DOS PRODUTOS: <br><br> "                              + ;
                   cProdutos

         // ######################
         // Envia e-mail ao RMA ##
         // ######################
         U_AUTOMR20(cTexto , "rma@automatech.com.br", "", "ABERTURA DE TICKT DE DEMONSTRA��O DE MERCADORIA" )

      Else

//       MsgAlert("Tickt de Controle FreshDesk (Fechamento) com o n� " + substr(xBuffer, int(val(U_P_OCCURS(xBuffer, '"id":',2))) + 5,6))         

         // #############################################################
         // Elabora o e-mail de aviso de encerramento do Ticket ao RMA ##
         // #############################################################
         xNtickt :=substr(xBuffer, int(val(U_P_OCCURS(xBuffer, '"id":',2))) + 5,6)

         cTexto := ""

         If kOperacao == "F"
            cTexto += "O pedido de DEMONSTRA��O n� " + Alltrim(kPedido) + " - "        + ;
                      "Nota Fiscal n� " + Alltrim(kDocumento) + "/" + Alltrim(kSerie)  + ;
                      " foi RETORNADA, mercadorias foram devolvidas. <br><br>"         + ;
                      "Tickt N� " + Alltrim(xNtickt) + "<br><br>"                      + ;  
                      "Vendedor: " + Alltrim(cNomeVende) + "<br><br>"                  + ;  
                      "Seguem abaixo os dados: <br><br> "                              + ;
                      "Dados da remessa de Demonstra��o <br><br> "                     + ;
                      "Raz�o Social: " + Alltrim(nNomeCli) + "<br>"                    + ;
                      "CNPJ: " + Alltrim(cCnpj) + "<br>"                               + ;
                      "IE: " + Alltrim(cInscricao) + "<br>"                            + ;
                      "Endereco: " + Alltrim(cEndereco) + "<br>"                       + ;
                      "Bairro: " + Alltrim(cBairro) + "<br>"                           + ;
                      "Cidade: " + Alltrim(cCEP) + " - " + Alltrim(cCidade) + " / " + Alltrim(cEstado) + "<br><br> " + ;
                      "DESCRICAO DOS PRODUTOS: <br><br> "                              + ;
                      cProdutos
         Else
            cTexto += "O pedido de DEMONSTRA��O n� " + Alltrim(kPedido) + " - "        + ;
                      "Nota Fiscal n� " + Alltrim(kDocumento) + "/" + Alltrim(kSerie)  + ;
                      " foi EXCLU�DA. <br><br>"                                        + ;
                      "Tickt N� " + Alltrim(xNtickt) + "<br><br>"                      + ;  
                      "Vendedor: " + Alltrim(cNomeVende) + "<br><br>"                  + ;                
                      "Seguem abaixo os dados: <br><br> "                              + ;
                      "Dados da remessa de Demonstra��o <br><br> "                     + ;
                      "Raz�o Social: " + Alltrim(nNomeCli) + "<br>"                    + ;
                      "CNPJ: " + Alltrim(cCnpj) + "<br>"                               + ;
                      "IE: " + Alltrim(cInscricao) + "<br>"                            + ;
                      "Endereco: " + Alltrim(cEndereco) + "<br>"                       + ;
                      "Bairro: " + Alltrim(cBairro) + "<br>"                           + ;
                      "Cidade: " + Alltrim(cCEP) + " - " + Alltrim(cCidade) + " / " + Alltrim(cEstado) + "<br><br> " + ;
                      "DESCRICAO DOS PRODUTOS: <br><br> "                              + ;
                      cProdutos
         Endif                      
         // ######################
         // Envia e-mail ao RMA ##
         // ######################
         U_AUTOMR20(cTexto , "rma@automatech.com.br", "", "ENCERRAMENTO DE TICKT DE DEMONSTRA��O DE MERCADORIA" )
            
      Endif
 
   Endif

Return(.T.)