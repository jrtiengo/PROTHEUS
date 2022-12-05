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
// Referencia: autom678.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/02/2018                                                          ##
// Objetivo..: Programa que realiza baixa do contas a receber pela leitura de XML  ##
// ##################################################################################

User Function AUTOM678()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private cCaminho := Space(250)
   Private oGet1

   Private aBrowse  := {}
   Private oBrowse

   Private oOk      := LoadBitmap( GetResources(), "LBOK" )
   Private oNo      := LoadBitmap( GetResources(), "LBNO" )

   Private yBaixa   := Ctod("  /  /    ")
   Private yCredito := Ctod("  /  /    ")
   Private yBanco   := Space(03)
   Private yAgencia := Space(05)
   Private yConta   := Space(10)

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Baixa Contas a Receber em Lote" FROM C(178),C(181) TO C(596),C(958) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Arquivo a ser importado" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet  oGet1 Var cCaminho Size C(164),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(170) Button "..."              Size C(014),C(009) PIXEL OF oDlg ACTION( PESQARQ1() )
   @ C(042),C(188) Button "Importar"         Size C(037),C(012) PIXEL OF oDlg ACTION( LeArqBaixas() )
   @ C(193),C(005) Button "Marca Todos"      Size C(050),C(012) PIXEL OF oDlg ACTION( IndicaReg(1) )
   @ C(193),C(056) Button "Desmarca Todos"   Size C(050),C(012) PIXEL OF oDlg ACTION( IndicaReg(2) )
   @ C(193),C(269) Button "Excel"            Size C(037),C(012) PIXEL OF oDlg ACTION( SaiExcel() )
   @ C(193),C(308) Button "Baixar"           Size C(037),C(012) PIXEL OF oDlg ACTION( FazBaixas() )
   @ C(193),C(347) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ 075,005 LISTBOX oBrowse FIELDS HEADER "M"                      ,; // 01
                                           "Empresa"                ,; // 02
                                           "Tipo"                   ,; // 03
                                           "Filial"                 ,; // 04
                                           "Prefixo"                ,; // 05
                                           "Titulo"                 ,; // 06
                                           "Condição PGTo."         ,; // 07
                                           "Parcela"                ,; // 08
                                           "Cliente"                ,; // 09
                                           "Loja"                   ,; // 10
                                           "Descrição dos Clientes" ,; // 11
                                           "Emissao"                ,; // 12
                                           "Vencimento"             ,; // 13
                                           "Valor"                  ,; // 14
                                           "Data Baixa"              ; // 15
                                           PIXEL SIZE 487,167 OF oDlg ON dblClick(aBrowse[oBrowse:nAt,1] := !aBrowse[oBrowse:nAt,1],oBrowse:Refresh())     

   aAdd( aBrowse, { .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "" }) 

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||     {Iif(aBrowse[oBrowse:nAt,01],oOk,oNo),;
                                 aBrowse[oBrowse:nAt,02]         ,;
                                 aBrowse[oBrowse:nAt,03]         ,;
                                 aBrowse[oBrowse:nAt,04]         ,;                                
                                 aBrowse[oBrowse:nAt,05]         ,;
                                 aBrowse[oBrowse:nAt,06]         ,;
                                 aBrowse[oBrowse:nAt,07]         ,;                                
                                 aBrowse[oBrowse:nAt,08]         ,;
                                 aBrowse[oBrowse:nAt,09]         ,;
                                 aBrowse[oBrowse:nAt,10]         ,;                                
                                 aBrowse[oBrowse:nAt,11]         ,;
                                 aBrowse[oBrowse:nAt,12]         ,;
                                 aBrowse[oBrowse:nAt,13]         ,;
                                 aBrowse[oBrowse:nAt,14]         ,;
                                 aBrowse[oBrowse:nAt,15]         }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)                      
                                                                               
// ################################################################################
// Função que abre diálogo de pesquisa para selecionar o arquivo a ser importado ##
// ################################################################################
Static Function PESQARQ1()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)

Return .T. 

// ################################################
// Função que marca/desmarca registros do Browse ##
// ################################################
Static Function IndicaReg(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aBrowse)
       aBrowse[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)          

// #########################################################################
// Função que lê o arquivo informado e carrega os dados para visualização ##
// #########################################################################
Static Function LeArqBaixas()

   MsgRun("Aguarde! Importando arquivo selecionado ...", "Baixas de SCR",{|| xLeArqBaixas() })

Return(.T.)

// #########################################################################
// Função que lê o arquivo informado e carrega os dados para visualização ##
// #########################################################################
Static Function xLeArqBaixas()

   Local nContar     := 0
   Local cConteudo   := ""
   Local aLista      := {}
   Local lErroPar    := .F.
   Local lErroTax    := .F.
   Local kkLegenda   := ""
   Local aInformacao := {}

   // ########################################################
   // Verifica se o arquivo a ser importado foi selecionado ##
   // ########################################################
   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado não selecionado. Verifique!")
      Rerturn(.T.)
   Endif

   // ################################################
   // Limpa o array aLimpa para receber novos dados ##
   // ################################################
   aLista := {}

   // ########################################
   // Abre o arquivo selecionado na aBrowse ##
   // ########################################
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)

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

       If Substr(xBuffer, nPercorre, 1) <> CHR(13)
          cConteudo := cConteudo + Substr(xBuffer, nPercorre, 1)
       Else

          aAdd( aLista, { Strtran(cConteudo, CHR(9), "|") } )
          cConteudo := ""

       Endif

   Next nPercorre

   // ##################################
   // Fecha a leitura do arquivo lido ##
   // ##################################
   FCLOSE(nHandle)
   
   // ######################################################
   // Limpa o array aBrowse para receber novos resultados ##
   // ######################################################
   aBrowse := {}   

   // ######################################
   // Carrega o aBrowse com os resultados ##
   // ######################################
   For nContar = 1 to Len(aLista)

       // ######################################   
       // Pesquisa se o título já foi quitado ##
       // ######################################
       If Select("T_BAIXADO") > 0
          T_BAIXADO->( dbCloseArea() )
       EndIf
       
       cSql := ""
       cSql := "SELECT E1_FILIAL  ,"
       cSql += "       E1_PREFIXO ," 
       cSql += "	   E1_NUM     ,"
       cSql += "	   E1_PARCELA ,"
       cSql += "	   E1_TIPO    ,"
       cSql += "	   E1_BAIXA    "
       cSql += "  FROM SE1" + STRZERO(INT(VAL(U_P_CORTA(aLista[nContar,01], "|", 01))),02) + "0" 
       cSql += " WHERE E1_PREFIXO = '" + U_P_CORTA(aLista[nContar,01], "|", 04) + "'"
       cSql += "   AND E1_NUM     = '" + U_P_CORTA(aLista[nContar,01], "|", 05) + "'"
       cSql += "   AND E1_PARCELA = '" + U_P_CORTA(aLista[nContar,01], "|", 08) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
       
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BAIXADO", .T., .T. )
                                                              
       If T_BAIXADO->( EOF() )
          xBaixa := "  /  /    "
       Else
          xBaixa := Substr(T_BAIXADO->E1_BAIXA,07,02) + "/" + Substr(T_BAIXADO->E1_BAIXA,05,02) + "/" + Substr(T_BAIXADO->E1_BAIXA,01,04)
       Endif   

       aAdd( aBrowse, { .F.                                                          ,; // 01 - Marcação
                        STRZERO(INT(VAL(U_P_CORTA(aLista[nContar,01], "|", 01))),02) ,; // 02 - Empresa
                        U_P_CORTA(aLista[nContar,01], "|", 02)                       ,; // 03 - Tipo
                        U_P_CORTA(aLista[nContar,01], "|", 03)                       ,; // 04 - Filial
                        U_P_CORTA(aLista[nContar,01], "|", 04)                       ,; // 05 - Prefixo
                        U_P_CORTA(aLista[nContar,01], "|", 05)                       ,; // 06 - Título
                        U_P_CORTA(aLista[nContar,01], "|", 06)                       ,; // 07 - Condição de Pagamento
                        U_P_CORTA(aLista[nContar,01], "|", 08)                       ,; // 08 - Parcela
                        U_P_CORTA(aLista[nContar,01], "|", 09)                       ,; // 09 - Cliente
                        U_P_CORTA(aLista[nContar,01], "|", 10)                       ,; // 10 - Loja
                        U_P_CORTA(aLista[nContar,01], "|", 11)                       ,; // 11 - Nome do Cliente
                        CTOD(SUBSTR(U_P_CORTA(aLista[nContar,01], "|", 12),09,02) + "/" + SUBSTR(U_P_CORTA(aLista[nContar,01], "|", 12),06,02) + "/" + SUBSTR(U_P_CORTA(aLista[nContar,01], "|", 12),01,04)) ,; // 12 - Data de Emissão
                        CTOD(SUBSTR(U_P_CORTA(aLista[nContar,01], "|", 13),09,02) + "/" + SUBSTR(U_P_CORTA(aLista[nContar,01], "|", 13),06,02) + "/" + SUBSTR(U_P_CORTA(aLista[nContar,01], "|", 13),01,04)) ,; // 13 - Data de Vencimento                       
                        VAL(STRTRAN(U_P_CORTA(aLista[nContar,01], "|", 18),",",".")) ,; // 14 - Valor do Título
                        xBaixa                                                       }) // 15 - Data da Baixa do Título
   Next nContar

   If Len(aBrowse) == 0
      aAdd( aBrowse, { .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "" }) 
   Endif   

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||     {Iif(aBrowse[oBrowse:nAt,01],oOk,oNo),;
                                 aBrowse[oBrowse:nAt,02]         ,;
                                 aBrowse[oBrowse:nAt,03]         ,;
                                 aBrowse[oBrowse:nAt,04]         ,;                                
                                 aBrowse[oBrowse:nAt,05]         ,;
                                 aBrowse[oBrowse:nAt,06]         ,;
                                 aBrowse[oBrowse:nAt,07]         ,;                                
                                 aBrowse[oBrowse:nAt,08]         ,;
                                 aBrowse[oBrowse:nAt,09]         ,;
                                 aBrowse[oBrowse:nAt,10]         ,;                                
                                 aBrowse[oBrowse:nAt,11]         ,;
                                 aBrowse[oBrowse:nAt,12]         ,;
                                 aBrowse[oBrowse:nAt,13]         ,;
                                 aBrowse[oBrowse:nAt,14]         ,;
                                 aBrowse[oBrowse:nAt,15]         }}

Return(.T.)
           
// ########################################################
// Função que realiza as baixas dos títulos selecionados ##
// ########################################################
Static Function FazBaixas()

   MsgRun("Aguarde! Realizando baixas dos títulos selecionados ...", "Baixas de SCR",{|| xFazBaixas() })

Return(.T.)

// ########################################################
// Função que realiza as baixas dos títulos selecionados ##
// ########################################################
Static Function xFazBaixas()

   Local nContar   := 0
   Local lMarcados := .F.
                   
   // #############################################################################
   // Verifica se houve pelo menos um registro selecionado para realizar a baixa ##
   // #############################################################################
   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar 
   
   If lMarcados == .F.
      MsgAlert("Atenção! Nenhum registro foi selecionado para realizar baixa. Verifique!")
      Return(.T.)
   Endif          

   // ##############################################################
   // Abre a solicitação de dados complementares antes das baixas ##
   // ##############################################################
   lVoltar := .T.
   BancoAgencia()
   
   If lVoltar == .T.
      Return(.T.)
   Endif   

   // ######################################
   // Realiza a baixa dos registros lidos ##
   // ######################################
   For nContar = 1 to Len(aBrowse)

       // #####################################
       // Despreza registro não selecionados ##
       // #####################################
       If aBrowse[nContar,01] == .F.
          Loop
       Endif   

       // ##################################
       // Prepara os campos para gravação ##
       // ##################################
       yPrefixo  := Alltrim(aBrowse[nContar,05]) + Space(03 - Len(Alltrim(aBrowse[nContar,05])))
       yNumero   := Alltrim(aBrowse[nContar,06]) + Space(09 - Len(Alltrim(aBrowse[nContar,06])))  
       yParcela  := aBrowse[nContar,08]
       yValorTit := aBrowse[nContar,14]
       yTipo     := aBrowse[nContar,03]                     
//     yValorTax := 0

       // #######################################
       // Realiza a baixa do capital do título ##
       // #######################################
       aInformacao := {{"E1_PREFIXO"  , yPrefixo      , Nil    },;
                       {"E1_NUM"      , yNumero       , Nil    },;
                       {"E1_PARCELA"  , yParcela      , Nil    },;
                       {"E1_TIPO"     , yTipo         , Nil    },;
                       {"AUTMOTBX"    , "NOR"         , Nil    },;
                       {"AUTBANCO"    , yBanco        , Nil    },;
                       {"AUTAGENCIA"  , yAgencia      , Nil    },;
                       {"AUTCONTA"    , yConta        , Nil    },;
                       {"AUTDTBAIXA"  , yBaixa        , Nil    },;
                       {"AUTDTCREDITO", yCredito      , Nil    },;
                       {"AUTHIST"     , "BAIXA CARTAO", Nil    },;
                       {"AUTJUROS"    , 0             , Nil,.T.},;
                       {"AUTVALREC"   , yValorTit     , Nil    }}

       lMsErroAuto := .F.

       MSExecAuto({|x,y| Fina070(x,y)}, aInformacao,3) 
 
       IF lMsErroAuto
          lErroPar := .T.
	      MostraErro()
       Else
          lErroPar := .F.
       Endif       

//       // ####################################
//       // Realiza a baixa da taxa do cartão ##
//       // ####################################
//       aValTaxa    := {{"E1_PREFIXO"  , yPrefixo                  , Nil    },;
//                       {"E1_NUM"      , yNumero                   , Nil    },;
//                       {"E1_PARCELA"  , kParcela                  , Nil    },;
//                       {"E1_TIPO"     , aBaixar[nReceber,05]      , Nil    },;
//                       {"AUTMOTBX"    , "NOR"                     , Nil    },;
//                       {"AUTBANCO"    , aBaixar[nReceber,15]      , Nil    },;
//                       {"AUTAGENCIA"  , aBaixar[nReceber,16]      , Nil    },;
//                       {"AUTCONTA"    , aBaixar[nReceber,17]      , Nil    },;
//                       {"AUTDTBAIXA"  , Ctod(aBaixar[nReceber,09]), Nil    },;
//                       {"AUTDTCREDITO", Ctod(aBaixar[nReceber,09]), Nil    },;
//                       {"AUTHIST"     , "BAIXA CARTAO"            , Nil    },;
//                       {"AUTJUROS"    , 0                         , Nil,.T.},;
//                       {"AUTVALREC"   , yValorTax                 , Nil    }}
//
//       lMsErroAuto := .F.
//       
//       MSExecAuto({|x,y| Fina070(x,y)}, aValTaxa,3) 
// 
//       IF lMsErroAuto
//          lErroTax := .T.
//	      MostraErro()
//       Else
//          lErroTax := .F.
//       Endif       

   Next nContar

   MsgAlert("Baixas realizadas com sucesso!")

Return(.T.)

// ############################################################################
// Função que permite o usuário a selecionar o banbco e datas antes da baixa ##
// ############################################################################
Static Function BancoAgencia()

   Local cMemo1	 := ""
   Local oMemo1
      
   Private aBancos	 := {}
   Private cComboBx1
   Private dBaixa 	 := Ctod("  /  /    ")
   Private dCredito  := Ctod("  /  /    ")

   Private oGet1
   Private oGet2

   Private oDlgBco

   If Select("T_BANCOS") > 0
      T_BANCOS->( dbCloseArea() )
   EndIf
              
   cSql := ""
   cSql := "SELECT A6_COD    ,"
   cSql += "       A6_AGENCIA,"
   cSql += "       A6_NUMCON ,"
   cSql += "       A6_NOME    "
   cSql += "  FROM " + RetSqlName("SA6")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY A6_COD, A6_AGENCIA, A6_NUMCON"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANCOS", .T., .T. )
   
   T_BANCOS->( DbGoTop() )
   
   aAdd( aBancos, "Selecione" )

   WHILE !T_BANCOS->( EOF() )
      aAdd( aBancos, A6_COD + " - " + A6_AGENCIA + " - " + A6_NUMCON + " - " + A6_NOME )
      T_BANCOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgBco TITLE "Novo Formulário" FROM C(178),C(181) TO C(335),C(533) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgBco
   
   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(169),C(001) PIXEL OF oDlgBco

   @ C(055),C(005) Say "Data da Baixa"           Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgBco
   @ C(055),C(049) Say "Data do Crédito"         Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgBco
   @ C(033),C(005) Say "Banco / Agência / Conta" Size C(065),C(008) COLOR CLR_BLACK PIXEL OF oDlgBco

   @ C(042),C(005) ComboBox cComboBx1 Items aBancos  Size C(168),C(010)                              PIXEL OF oDlgBco
   @ C(065),C(005) MsGet    oGet1     Var   dBaixa   Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBco
   @ C(065),C(049) MsGet    oGet2     Var   dCredito Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBco

   @ C(062),C(096) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgBco ACTION( FechaBanco(1) )
   @ C(062),C(134) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgBco ACTION( FechaBanco(2) )

   ACTIVATE MSDIALOG oDlgBco CENTERED 

Return(.T.)

// ################################################################################################
// Função que fecha a tela de solicitação de banco / data da baixa e data do crédito dos títulos ##
// ################################################################################################
Static Function FechaBancoAgencia(kTipo)
             
   lVoltar := .T.

   If kTipo == 2
      lVoltar := .T.    
      oDlgBco:End()
      Return(.T.)
   Endif   
                   
   If Alltrim(cComboBx1) == "Selecione"
      MsgAlert("Banco/Agência/Conta não selecionada. Verifique!")
      Return(.T.)
   Endif
   
   If dBaixa == Ctod("  /  /    ")
      MsgAlert("Data da Baixa não informada. Verifique!")
      Return(.T.)
   Endif
      
   If dCredito == Ctod("  /  /    ")
      MsgAlert("Data do Crédito não informada. Verifique!")
      Return(.T.)
   Endif

   lVoltar := .F.
             
   yBaixa   := dBaixa
   yCredito := dCredito
   
   // ######################################
   // Pesquisa dados do banco selecionado ##
   // ######################################
   If Select("T_BANCOS") > 0
      T_BANCOS->( dbCloseArea() )
   EndIf
              
   cSql := ""
   cSql := "SELECT A6_COD    ,"
   cSql += "       A6_AGENCIA,"
   cSql += "       A6_NUMCON ,"
   cSql += "       A6_NOME    "
   cSql += "  FROM " + RetSqlName("SA6")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A6_COD     = '" + Alltrim(U_P_CORTA(cComboBx1, "-",01)) + "'"
   cSql += "   AND A6_AGENCIA = '" + Alltrim(U_P_CORTA(cComboBx1, "-",02)) + "'"
   cSql += "   AND A6_NUMCON  = '" + Alltrim(U_P_CORTA(cComboBx1, "-",03)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANCOS", .T., .T. )
   
   yBanco   := T_BANCOS->A6_COD
   yAgencia := T_BANCOS->A6_AGENCIA
   yConta   := T_BANCOS->A6_NUMCON
   
   oDlgBco:End() 
   
Return(.T.)  

// #######################################
// Função que gera o resultado em Excel ##
// #######################################
Static Function SaiExcel()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   aAdd( aCabExcel, { "Empresa"      , "C", 02, 00 })
   aAdd( aCabExcel, { "Tipo"         , "C", 03, 00 })
   aAdd( aCabExcel, { "Filial"       , "C", 02, 00 })
   aAdd( aCabExcel, { "Prefixo"      , "C", 10, 02 })
   aAdd( aCabExcel, { "Título"       , "C", 10, 00 })
   aAdd( aCabExcel, { "Cond.Pgto."   , "C", 03, 00 })
   aAdd( aCabExcel, { "Parcela"      , "C", 02, 00 })
   aAdd( aCabExcel, { "Cliente"      , "C", 06, 00 })
   aAdd( aCabExcel, { "Loja"         , "C", 03, 00 })
   aAdd( aCabExcel, { "Nome Cliente" , "C", 40, 00 })
   aAdd( aCabExcel, { "Emissão"      , "C", 10, 00 })
   aAdd( aCabExcel, { "Vencimento"   , "C", 10, 00 })
   aAdd( aCabExcel, { "Valor"        , "N", 10, 02 })
   aAdd( aCabExcel, { "Data Baixa"   , "C", 10, 00 })
   
   MsgRun("Aguarde! Preparando Dados ..."     , "Selecionando os Registros", {|| kkSaidaExcel(aCabExcel, @aItensExcel)})
   MsgRun("Aguarde! Gerando Arquivo Excel ...", "Exportando Resumo para Excel", {||DlgToExcel({{"GETDADOS","Registros arquivo de baixas", aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kkSaidaExcel(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aBrowse)

       aAdd( aCols, { aBrowse[nContar,02]         ,;
                      aBrowse[nContar,03]         ,;
                      aBrowse[nContar,04]         ,;                                
                      aBrowse[nContar,05]         ,;
                      aBrowse[nContar,06]         ,;
                      aBrowse[nContar,07]         ,;                                
                      aBrowse[nContar,08]         ,;
                      aBrowse[nContar,09]         ,;
                      aBrowse[nContar,10]         ,;                                
                      aBrowse[nContar,11]         ,;
                      aBrowse[nContar,12]         ,;
                      aBrowse[nContar,13]         ,;
                      aBrowse[nContar,14]         ,;
                      aBrowse[nContar,15]         ,;
                      ""                          })

   Next nContar

Return(.T.)