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

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM574.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ## 
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 23/05/2017                                                            ##
// Objetivo..: Tracking SIMFRETE                                                     ##   
// #################################################################################### 

User Function AUTOM574()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private aFilial  := U_AUTOM539(2, cEmpAnt)
   Private cInicial := Ctod("  /  /    ")
   Private cFinal   := Ctod("  /  /    ")
   Private cNFiscal := Space(09)
   Private cSerie   := Space(03)
   Private cCliente := Space(06)
   Private cLoja    := Space(03)
   Private cNomeCli := Space(60)

   Private cComboBx1
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlg

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   U_AUTOM628("AUTOM574")
   
   // #######################################################################
   // Verifica se existe a pasta C:\SIMFRETE. Caso não exista, será criada ##
   // #######################################################################
   If !ExistDir( "C:\SIMFRETE" )

      nRet := MakeDir( "C:\SIMFRETE" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta C:\SIMFRETE. Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Endif
   
   Endif

   // #############################
   // Dsenha a tela para display ##
   // #############################
   DEFINE MSDIALOG oDlg TITLE "Tracking SIMFRETE" FROM C(178),C(181) TO C(539),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlg
   @ C(060),C(002) GET oMemo2 Var cMemo2 MEMO Size C(386),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Filial"          Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(057) Say "Dta Emissão De"  Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(100) Say "Dta Emissão Até" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(143) Say "Nº N.Fiscal"     Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(185) Say "Série"           Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(204) Say "Cliente"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) ComboBox cComboBx1 Items aFilial Size C(049),C(010) PIXEL OF oDlg
   @ C(045),C(057) MsGet    oGet1     Var   cInicial Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(100) MsGet    oGet2     Var   cFinal   Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(143) MsGet    oGet3     Var   cNFiscal Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(185) MsGet    oGet4     Var   cSerie   Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(204) MsGet    oGet5     Var   cCliente Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(045),C(232) MsGet    oGet6     Var   cLoja    Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TTCCNN() )
   @ C(045),C(251) MsGet    oGet7     Var   cNomeCli Size C(096),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(044),C(351) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PPNNCCPP() )
   @ C(164),C(005) Button "Tracking"  Size C(037),C(012) PIXEL OF oDlg ACTION( ConsultaSimFrete() )
   @ C(164),C(351) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "", "", "", "", "", "", "", "" })

   @ 085,005 LISTBOX oLista FIELDS HEADER "M", "Filial", "Documento", "Série", "Emissao", "Código", "Loja", "Nome dos Clientes", "CNPJ/CPF" PIXEL SIZE 490,120 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                           aLista[oLista:nAt,02]         ,;
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                           aLista[oLista:nAt,05]         ,;
                           aLista[oLista:nAt,06]         ,;
                           aLista[oLista:nAt,07]         ,;
                           aLista[oLista:nAt,08]         ,;
                           aLista[oLista:nAt,09]         }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##########################################
// Função que Pesquisa o Cliente Informado ##
// ##########################################
Static Function TTCCNN()

   If Empty(Alltrim(cCliente))
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)
      oGet5:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cLoja))
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)
      oGet5:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()
      Return(.T.)
   Endif

   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_NOME")      
   
   If Empty(Alltrim(cNomeCli))
      MsgAlert("Cliente informado não cadastrado.")
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)
      oGet5:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()
      Return(.T.)
   Else
      oGet7:Refresh()
   Endif
      
Return(.T.)

// ###########################################################
// Função que Pesquisa as notas fiscais conforme parâmetros ##
// ###########################################################
Static Function PPNNCCPP()

   MsgRun("Aguarde! Pesquisando Notas Fiscais ...", "Tracking SimFrete",{|| xPPNNCCPP() })

Return(.T.)

// ###########################################################
// Função que Pesquisa as notas fiscais conforme parâmetros ##
// ###########################################################
Static Function xPPNNCCPP()

   Local cSql := ""

   If Empty(Alltrim(cNFiscal))

      If cInicial == Ctod("  /  /    ")
         MsgAlert("Data inicial de emissão não informada.")
         Return(.T.)
      Endif
         
      If cFinal == Ctod("  /  /    ")
         MsgAlert("Data final de emissão não informada.")
         Return(.T.)
      Endif
      
   Else
   
      If Empty(Alltrim(cSerie))
         MsgAlert("Série da Nota Fiscal não informada.")
         Return(.T.)
      Endif
   
   Endif
   
   aLista := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf
 
   cSql := ""
   cSql := "SELECT SF2.F2_FILIAL ,"
   cSql += "       SF2.F2_DOC    ,"
   cSql += "	   SF2.F2_SERIE  ,"
   cSql += "	   SF2.F2_EMISSAO,"
   cSql += "	   SF2.F2_CLIENTE,"
   cSql += "	   SF2.F2_LOJA   ,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "       SA1.A1_CGC     "
   cSql += "  FROM " + RetSqlName("SF2") + " SF2, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SF2.F2_FILIAL   = '" + Substr(cComboBx1,01,02) + "'"

   If Empty(Alltrim(cNFiscal))
      cSql += "   AND SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"
      cSql += "   AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"
   Endif   

   If Empty(Alltrim(cCLiente))
   Else
      cSql += "   AND SF2.F2_CLIENTE  = '" + Alltrim(cCliente) + "'"
      cSql += "   AND SF2.F2_LOJA     = '" + Alltrim(cLoja)    + "'"
   Endif   

   If Empty(alltrim(cNFiscal))
   Else
      cSql += "   AND SF2.F2_DOC   = '" + Alltrim(cNFiscal) + "'"
      cSql += "   AND SF2.F2_SERIE = '" + Alltrim(cSerie)   + "'"
   Endif

   cSql += "   AND SF2.D_E_L_E_T_  = ''
   cSql += "   AND SA1.A1_COD      = SF2.F2_CLIENTE
   cSql += "   AND SA1.A1_LOJA     = SF2.F2_LOJA
   cSql += "   AND SA1.D_E_L_E_T_  = ''   
   cSql += " ORDER BY SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )      

      aAdd( aLista, { .F.                    ,;
                      T_CONSULTA->F2_FILIAL  ,;
                      T_CONSULTA->F2_DOC     ,;
                      T_CONSULTA->F2_SERIE   ,;
                      Substr(T_CONSULTA->F2_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->F2_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->F2_EMISSAO,01,04) ,;
                      T_CONSULTA->F2_CLIENTE ,;
                      T_CONSULTA->F2_LOJA    ,;
                      T_CONSULTA->A1_NOME    ,;
                      T_CONSULTA->A1_CGC     })

      T_CONSULTA->( DbSkip() )
      
   ENDDO
      
   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                           aLista[oLista:nAt,02]         ,;
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                           aLista[oLista:nAt,05]         ,;
                           aLista[oLista:nAt,06]         ,;
                           aLista[oLista:nAt,07]         ,;
                           aLista[oLista:nAt,08]         ,;                           
                           aLista[oLista:nAt,09]         }}

Return(.T.)

// ############################################################################
// Função que consome web service para realizar a consulta Tracking SimFrete ##
// ############################################################################
Static Function ConsultaSimFrete()

   Local cSql             := ""
   Local cComando         := ""
   Local cURLSimFrete     := Space(250)
   Local cEmpresaSimFrete := Space(050)
   Local cLoginSimFrete   := Space(020)
   Local cSenhaSimfrete   := Space(020)
   Local cEmailSimFrete   := Space(250)
   Local cCaminhoRetorno  := Space(250)
   Local cConteudo        := ""
   Local cString          := ""
   Local nContar          := 0
   Local xContar          := 0
   Local aDados           := {}
   Local cSTIM            := 500000
   Local nMarcado         := 0
   Local nErr             := 0
   Local nRet
   
   // ################################################################# 
   // Pesquisa os parâmetros para consumo do web service do SimFrete ##
   // #################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_SFRE)) AS SIMFRETE"    
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Parâmetros do SimFrete não definidos." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   cURLSimFrete     := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1)))
   cEmpresaSimFrete := IIF(T_PARAMETROS->( EOF() ), Space(050), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2))), Space(050), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2)))
   cLoginSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3)))
   cSenhaSimfrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4)))
   cEmailSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5)))
   cCaminhoRetorno  := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6)))

   If Empty(Alltrim(cURLSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "URL do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif
            
   If Empty(Alltrim(cEmpresaSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Empresa de pesquisa do Web Service do Sim Frete não parametrizada." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cLoginSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Login de pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cSenhaSimfrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Senha de pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCaminhoRetorno))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Caminho para gravação retorno da pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   // ###################################################################
   // Verifica se houve a marcação de uma nota fiscal a ser pesquisada ##
   // ###################################################################
   nMarcado := 0
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          nMarcado := nMarcado + 1
       Endif
   Next nContar
   
   If nMarcado == 0
      MsgAlert("Nenhuma nota fiscal foi indicada para pesquisa.")
      Return(.T.)
   Endif
   
   If nMarcado <> 1
      MsgAlert("Somente permitido marcar uma nota fiscal de cada vez para consulta ao SimFrete.")
      Return(.T.)
   Endif

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          kFilial := aLista[nContar,02]
          kCNPJDt := aLista[nContar,09]
          kNota   := aLista[nContar,03]
          Exit
       Endif
   Next nContar

   // #################################################################
   // Pesquisa o CNPJ da Automatech conforme a filial da Nota Fiscal ##
   // #################################################################
   Do Case
      Case cEmpAnt == "01"
           Do Case 
              Case kFilial == "01"
                   kCNPJEm := "03385913000161"
              Case kFilial == "02"
                   kCNPJEm := "03385913000242
              Case kFilial == "03"
                   kCNPJEm := "03385913000404
              Case kFilial == "04"
                   kCNPJEm := "03385913000595
              Case kFilial == "05"
                   kCNPJEm := "03385913000676
           EndCase
           cNomeOrigem := "AUTOMATECH SISTEMAS DE AUTOMACAO LTDA"
      Case cEmpAnt == "02"
           kCNPJEm := "12757071000112"
      Case cEmpAnt == "03"
           kCNPJEm := "07166377000164"
      Case cEmpAnt == "04"
           kCNPJEm := ""
   EndCase

   // ######################################################################
   // Elabora a string de solicitação de pesquisa do Web Service SimFrete ##
   // ######################################################################
   cComando := ""
   cComando := "https://automatech.simfrete.com/consultaocorrv2.jsp?"         + ;
               "wsemp="       + Alltrim(cEmpresaSimFrete)                     + ;
               "&wsusr="      + Alltrim(cLoginSimFrete)                       + ;
               "&wspwd="      + Alltrim(cSenhaSimfrete)                       + ;                         
               "&cnpj="       + Alltrim(kCNPJEm)                              + ;
               "&dest="       + Alltrim(kCNPJDt)                              + ;
               "&notafiscal=" + Alltrim(kNota)

   // #######################################################################################
   // Cria nome do arquivo de retorno                                                      ##
   // Variável do parametrizador Automatech deve estar gravada com - Exemplo  C:\SIMFRETE\ ##
   // O Comando abaixo acrescenta a esta camilho a estrutura:                              ##
   // C:\SIMFRETE\FilialNúmeroPedido.TXT                                                   ##
   //                                                                                      ##
   // C:\SIMFRETE\01095796.TXT                                                             ##
   //                                                                                      ##
   // #######################################################################################
   cRetorno := Alltrim(cCaminhoRetorno) + Alltrim(kFilial) + Alltrim(kNota) + ".HTML"

   // #############################################
   // Fecha o arquivo de retorno para eliminação ##
   // #############################################
   FCLOSE(cRetorno)

   // ###################################################################
   // Elimina o Arquivo para receber nova cotação de frete do SimFrete ##
   // ###################################################################
   FERASE(cRetorno)

   // #############################################
   // Envia a solicitação de cotação ao SimFrete ##
   // #############################################
   WaitRun('AtechHttpget.exe' + ' "' + cComando + '" ' + cRetorno, SW_SHOWNORMAL )

   // ###########################
   // Lê o retorno da consulta ##
   // ###########################
   lExiste     := .F.
   nTentativas := 0

   while nTentativas < cSTIM

      If File(cRetorno)
         lExiste := .T.
         Exit
      Endif

      nTentativas := nTentativas + 1

   Enddo

   // #########################################################
   // Verifica se há arquivo de retorno de coptação de frete ##
   // #########################################################
   If lExiste == .F.

      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo de retorno de cotação de frete inexistente." + chr(13) + chr(10) + "Tente novamente.")

      // ###############################################################################################
      // Verifica se existe o arquivo de retorno no diretório. Se existir, tenta fechá-lo e excluí-lo ##
      // ###############################################################################################
      If File(cRetorno)

         // ##################
         // Fecha o arquivo ##
         // ##################
         FCLOSE(cRetorno)

         // ########################################################
         // Elimina o Arquivo para receber nova coptação de frete ##
         // ########################################################
         FERASE(cRetorno)

      Endif

      Return(.T.)

   Endif

   // ##########################
   // Abre o Json pelo Chrome ##
   // ##########################
   If file("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
      nErr := WinExec("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe " + cRetorno)
   Else
      nErr := WinExec("C:\Program Files\Google\Chrome\Application\chrome.exe " + cRetorno)
   Endif         
 
   IF nErr == 0
//    MsgAlert("Não foi possível abrir a consulta. Tente novamente.")
   Endif

   MsgAlert("Tecle <ENTER> para próxima consulta.")

   // ##################
   // Fecha o arquivo ##
   // ##################
   FCLOSE(cRetorno)

   // ########################################################
   // Elimina o Arquivo para receber nova coptação de frete ##
   // ########################################################
   FERASE(cRetorno)

   // ##################################
   // Limpa a marcação da nota fiscal ##
   // ##################################
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := .F.
   NExt nContar    

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                           aLista[oLista:nAt,02]         ,;
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                           aLista[oLista:nAt,05]         ,;
                           aLista[oLista:nAt,06]         ,;
                           aLista[oLista:nAt,07]         ,;
                           aLista[oLista:nAt,08]         ,;
                           aLista[oLista:nAt,09]         }}

Return(.T.)