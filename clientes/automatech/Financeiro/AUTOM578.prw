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
// Referencia: AUTOM578.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 29/05/2017                                                          ##
// Objetivo..: Programa que envia cartas de cobrança a Clientes.                   ## 
// ##################################################################################

User Function AUTOM578()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3
  
   Local cTexto01   := ""
   Local cTexto02   := ""
   Local cTexto03   := ""   

   Private aRisco   := {}
   Private aCarta   := {}
   Private cData    := Date()
   Private cCliente := Space(06)
   Private cLoja    := Space(03)
   Private cNomeCli := Space(60)
   Private lJaEnvia := .F.

   Private cComboBx111  
   Private cComboBx222  
   Private oGet1      
   Private oGet2      
   Private oGet3      
   Private oGet4      
   Private oCheckBox1 

   Private kDias01 := 0
   Private kDias02 := 0
   Private kDias03 := 0
   Private kDias04 := 0
   Private kDias05 := 0
   Private kDias06 := 0            

   Private lRiscoA	 := .F.
   Private lRiscoB	 := .F.
   Private lRiscoC	 := .F.
   Private lRiscoD	 := .F.
   Private lRiscoE	 := .F.
   Private lRiscoT	 := .F.

   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oCheckBox4
   Private oCheckBox5
   Private oCheckBox6

   Private aLista := {}
   Private oLista

   Private oOk        := LoadBitmap( GetResources(), "LBOK" )
   Private oNo        := LoadBitmap( GetResources(), "LBNO" )

   Private oVerde     := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho  := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul      := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo   := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto     := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja   := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza     := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco    := LoadBitmap(GetResources(),'br_branco')
   Private oPink      := LoadBitmap(GetResources(),'br_pink')
   Private oCancel    := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra   := LoadBitmap(GetResources(),'br_marrom')

   aAdd( aRisco, "0 - Todos")
   aAdd( aRisco, "A - Risco A")
   aAdd( aRisco, "B - Risco B")
   aAdd( aRisco, "C - Risco C")
   aAdd( aRisco, "D - Risco D")
   aAdd( aRisco, "E - Risco E")

   Private oDlg

   // ########################################################################################
   // Pesquisa parâmetros de envio de carta de aviso de débito no parametrizador Automatech ##
   // ########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT1)) AS CARTA1, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT2)) AS CARTA2, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT3)) AS CARTA3, "
   cSql += "       ZZ4_DC01, "
   cSql += "       ZZ4_DC02, "
   cSql += "       ZZ4_DC03, "
   cSql += "       ZZ4_DC04, "
   cSql += "       ZZ4_DC05, "
   cSql += "       ZZ4_DC06  "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   aAdd( aCarta, "1 - Carta 01 de " + Str(T_PARAMETROS->ZZ4_DC01,5) + " até " + Str(T_PARAMETROS->ZZ4_DC02,5) + " dias de atraso")
   aAdd( aCarta, "2 - Carta 02 de " + Str(T_PARAMETROS->ZZ4_DC03,5) + " até " + Str(T_PARAMETROS->ZZ4_DC04,5) + " dias de atraso")
   aAdd( aCarta, "3 - Carta 03 de " + Str(T_PARAMETROS->ZZ4_DC04,5) + " até " + Str(T_PARAMETROS->ZZ4_DC06,5) + " dias de atraso")  

   kDias01  := T_PARAMETROS->ZZ4_DC01
   kDias02  := T_PARAMETROS->ZZ4_DC02
   kDias03  := T_PARAMETROS->ZZ4_DC03
   kDias04  := T_PARAMETROS->ZZ4_DC04
   kDias05  := T_PARAMETROS->ZZ4_DC05
   kDias06  := T_PARAMETROS->ZZ4_DC06               

   DEFINE MSDIALOG oDlg TITLE "Envio de Aviso de Cobrança a Clientes" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(060),C(002) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(190),C(002) GET oMemo3 Var cMemo3 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Risco Cliente"                Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(082) Say "Carta a ser enviada"          Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(248) Say "Cliente"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(063),C(005) Say "Relação de Títulos em Atraso" Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(198) Say "Data Verificação"             Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlg

// @ C(046),C(005) ComboBox cComboBx111 Items aRisco     Size C(051),C(010) PIXEL OF oDlg

   @ C(044),C(005) CheckBox oCheckBox2  Var   lRiscoA    Prompt "A" Size C(014),C(008) PIXEL OF oDlg
   @ C(044),C(020) CheckBox oCheckBox3  Var   lRiscoB    Prompt "B" Size C(014),C(008) PIXEL OF oDlg
   @ C(044),C(035) CheckBox oCheckBox4  Var   lRiscoC    Prompt "C" Size C(014),C(008) PIXEL OF oDlg
   @ C(052),C(005) CheckBox oCheckBox5  Var   lRiscoD    Prompt "D" Size C(014),C(008) PIXEL OF oDlg
   @ C(052),C(020) CheckBox oCheckBox6  Var   lRiscoE    Prompt "E" Size C(013),C(008) PIXEL OF oDlg
   @ C(052),C(035) CheckBox oCheckBox1  Var   lRiscoT    Prompt "T" Size C(014),C(008) PIXEL OF oDlg
   @ C(046),C(082) ComboBox cComboBx222 Items aCarta                Size C(100),C(010) PIXEL OF oDlg
   @ C(046),C(248) MsGet    oGet1       Var   cCliente              Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(046),C(275) MsGet    oGet2       Var   cLoja                 Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( PPCCliente() )
   @ C(046),C(296) MsGet    oGet3       Var   cNomeCli              Size C(160),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(036),C(140) CheckBox oCheckBox1  Var   lJaEnvia   Prompt "Incluir já enviadas" Size C(053),C(008) PIXEL OF oDlg
   @ C(046),C(198) MsGet    oGet4       Var   cData                 Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(044),C(052) Button "LEG"            Size C(021),C(012) PIXEL OF oDlg ACTION( PegaPrxSeq() )  &&    ACTION( MMMLegenda() )
   @ C(045),C(461) Button "Pesquisar"      Size C(037),C(012) PIXEL OF oDlg ACTION( TrazDados() )
   @ C(210),C(005) Button "Marca Todos"    Size C(035),C(012) PIXEL OF oDlg ACTION( MMAALISTA(1) )
   @ C(210),C(041) Button "Desm.Todos"     Size C(035),C(012) PIXEL OF oDlg ACTION( MMAALISTA(0) )
   @ C(210),C(078) Button "Cad.Clientes"   Size C(031),C(012) PIXEL OF oDlg ACTION( MATA030() )
   @ C(210),C(110) Button "Alterar E-mail" Size C(036),C(012) PIXEL OF oDlg ACTION( AlteraEmail() )
   @ C(210),C(147) Button "Cad.Contatos"   Size C(046),C(012) PIXEL OF oDlg ACTION( TMKA070() )
   @ C(210),C(194) Button "Texto Cartas"   Size C(046),C(012) PIXEL OF oDlg ACTION( TextoCartas() )
// @ C(210),C(241) Button "Boleto"         Size C(046),C(012) PIXEL OF oDlg ACTION( U_BOLITAU() )
   @ C(210),C(241) Button "Atend. Recep."  Size C(046),C(012) PIXEL OF oDlg ACTION( TMKA350() )
   @ C(210),C(288) Button "Ped.Venda"      Size C(046),C(012) PIXEL OF oDlg ACTION( MATA410() )
   @ C(210),C(335) Button "Funções SCR"    Size C(046),C(012) PIXEL OF oDlg ACTION( FINA740() )
   @ C(210),C(382) Button "Emite Docs"     Size C(035),C(012) PIXEL OF oDlg ACTION( U_AUTOM347() )
   @ C(210),C(417) Button "Enviar E-Mail"  Size C(044),C(012) PIXEL OF oDlg ACTION( EnviaEmailCC() )    && ACTION( ffEnviaEmailCC() )
   @ C(210),C(461) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { "0", "", "", "", .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   @ 090,005 LISTBOX oLista FIELDS HEADER "LG"                    ,; // 01
                                          "Cliente"               ,; // 02
                                          "Loja"                  ,; // 03
                                          "Descrição dos Clientes",; // 04
                                          "M"                     ,; // 05
                                          "Prefixo"               ,; // 06
                                          "Nº Título"             ,; // 07
                                          "Nº Parcela"            ,; // 08
                                          "Emissão"               ,; // 09
                                          "Vencimento"            ,; // 10                                        
                                          "Atraso"                ,; // 11
                                          "Valor Título"          ,; // 12
                                          "Carta 1"               ,; // 13
                                          "Dta Env. Carta 1"      ,; // 14
                                          "Carta 2"               ,; // 15
                                          "Dta Env. Carta 2"      ,; // 16
                                          "Carta 3"               ,; // 17
                                          "Dta Env. Carta 3"      ,; // 18
                                          "E-Mails"                ; // 19  
                            PIXEL SIZE 633,173 OF oDlg ON dblClick(aLista[oLista:nAt,5] := !aLista[oLista:nAt,5],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||{ If(aLista[oLista:nAt,01] == "0", oBranco   ,;
                        If(aLista[oLista:nAt,01] == "2", oVerde    ,;
                        If(aLista[oLista:nAt,01] == "3", oCancel   ,;                         
                        If(aLista[oLista:nAt,01] == "1", oAmarelo  ,;                         
                        If(aLista[oLista:nAt,01] == "5", oAzul     ,;                         
                        If(aLista[oLista:nAt,01] == "6", oLaranja  ,;                         
                        If(aLista[oLista:nAt,01] == "7", oPreto    ,;                         
                        If(aLista[oLista:nAt,01] == "8", oVermelho ,;
                        If(aLista[oLista:nAt,01] == "9", oPink     ,;
                        If(aLista[oLista:nAt,01] == "4", oEncerra, "")))))))))),;
                           aLista[oLista:nAt,02]         ,;
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                       Iif(aLista[oLista:nAt,05],oOk,oNo)          ,;
                           aLista[oLista:nAt,06]         ,;
                           aLista[oLista:nAt,07]         ,;
                           aLista[oLista:nAt,08]         ,;
                           aLista[oLista:nAt,09]         ,;
                           aLista[oLista:nAt,10]         ,;
                           aLista[oLista:nAt,11]         ,;
                           aLista[oLista:nAt,12]         ,;
                           aLista[oLista:nAt,13]         ,;
                           aLista[oLista:nAt,14]         ,;
                           aLista[oLista:nAt,15]         ,;
                           aLista[oLista:nAt,16]         ,;
                           aLista[oLista:nAt,17]         ,;                                                                                                                                       
                           aLista[oLista:nAt,18]         ,;                                                                                                                                       
                           aLista[oLista:nAt,19]         }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)            

// ####################################################
// Função que marca e desmarca os registros da lista ##
// ####################################################
Static Function MMAALISTA(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,05] := IIF(kTipo == 1, .T., .F.)
   Next Contar    

Return(.T.)   

// ##################################################
// Função que pesquisa o nome do cliente informado ##
// ##################################################
Static Function PPCCliente()

   If Empty(Alltrim(cCliente))
      cCliente := Space(06)
      cLoja    := Space(03) 
      cNomeCli := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cLoja))
      cCliente := Space(06)
      cLoja    := Space(03) 
      cNomeCli := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()
      Return(.T.)
   Endif

   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_NOME")

   If Empty(Alltrim(cNomeCli))
      MsgAlert("Cliente informado não cadatrado. Verifique!")
      cCliente := Space(06)
      cLoja    := Space(03) 
      cNomeCli := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()
      Return(.T.)
   Endif

Return(.T.)

// ############################################################################
// Função que pesquisa os registro de débito de clientes conforme parâmetros ##
// ############################################################################
Static Function TrazDados()

   MsgRun("Aguarde! Pesquisando Títulos vencidos ...", "Envio de Aviso de Débito",{|| xTrazDados() })

Return(.T.)

// ############################################################################
// Função que pesquisa os registro de débito de clientes conforme parâmetros ##
// ############################################################################
Static Function xTrazDados()

   Local cSql      := ""
   Local nRecCount := 0
   Local lPrimeiro := .T.
   Local nCartas   := 0 
   Local kk_Email  := ""

   // ################################################## 
   // Gera consistências antes de executar a pesquisa ##
   // ##################################################
   If lRiscoA == .F. .And. lRiscoB == .F. .And. lRiscoC == .F. .And. lRiscoD == .F. .And. lRiscoE == .F. .And. lRiscoT == .F.
      MsgAlert("Riscos de Cliente a serem pesquisadoos não indicados. Verifique!")
      Return(.T.)
   Endif
   
   If cData == Ctod("  /  /    ")
      MsgAlert("Data de Verificação não informada. Verifique!")
      Return(.T.)
   Endif

   // #######################
   // Limpa o array aLista ##
   // #######################
   aLista := {}

   // ################################
   // Prepara data para verificação ##
   // ################################
   cVerifica := Substr(Dtoc(cData),07,04) + Substr(Dtoc(cData),04,02) + Substr(Dtoc(cData),01,02)

   // #####################################################
   // Pesquisa os títulos em aberto conforme parâmetros  ##
   // #####################################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SE1.E1_CLIENTE," + CHR(13)
   cSql += "       SE1.E1_LOJA   ," + CHR(13)
   cSql += "	   SA1.A1_NOME   ," + CHR(13)
   cSql += "	   SA1.A1_EMAIL  ," + CHR(13)
   cSql += "       SA1.A1_RISCO  ," + CHR(13)
   cSql += "       SA1.A1_CGC    ," + CHR(13)
   cSql += "       SE1.E1_PREFIXO," + CHR(13)
   cSql += "       SE1.E1_NUM    ," + CHR(13)
   cSql += "	   SE1.E1_PARCELA," + CHR(13)
   cSql += "       SE1.E1_TIPO   ," + CHR(13)
   cSql += "       SE1.E1_EMISSAO," + CHR(13)
   //cSql += "	   SE1.E1_VENCTO ," + CHR(13) 
   cSql += "	   SE1.E1_VENCREA ," + CHR(13)
   //cSql += "       DATEDIFF(day, SE1.E1_VENCTO, '" + cVerifica + "') AS ATRASO," + CHR(13)
   cSql += "       DATEDIFF(day, SE1.E1_VENCREA, '" + cVerifica + "') AS ATRASO," + CHR(13)
   cSql += "	   SE1.E1_VALOR  ," + CHR(13)
   cSql += "	   SE1.E1_CAR1   ," + CHR(13)
   cSql += "	   SE1.E1_DEN1   ," + CHR(13)
   cSql += "	   SE1.E1_CAR2   ," + CHR(13)
   cSql += "	   SE1.E1_DEN2   ," + CHR(13)
   cSql += "	   SE1.E1_CAR3   ," + CHR(13)
   cSql += "	   SE1.E1_DEN3   ," + CHR(13)
   cSql += "       SE1.E1_NATUREZ," + CHR(13)
   cSql += "       SE1.E1_NUMBCO  " + CHR(13)
   cSql += "  FROM " + RetSqlName("SE1") + " SE1, " + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " SA1  " + CHR(13)
   cSql += " WHERE SE1.E1_SALDO  <> 0 " + CHR(13)
   cSql += "   AND SE1.D_E_L_E_T_ = ''" + CHR(13)
   cSql += "   AND SE1.E1_SALDO  <> 0 " + CHR(13)
   cSql += "   AND SE1.E1_TIPO IN ('NF','FT')" + CHR(13)
   cSql += "   AND (SELECT F2_COND FROM " + RetSqlName("SF2") + " WHERE F2_DOC = SE1.E1_NUM AND F2_SERIE = SE1.E1_PREFIXO AND D_E_L_E_T_ = '') NOT IN ('001','098','099','108','109','110','111','112','113','114','115','116','117','118','188','190','200','201')" + CHR(13)

   Do Case
      Case Substr(cComboBx222,01,01) == "1"
           //cSql += "   AND DATEDIFF(day, SE1.E1_VENCTO, '" + cVerifica + "') >= " + Alltrim(Str(kDias01))  + CHR(13) 
           cSql += "   AND DATEDIFF(day, SE1.E1_VENCREA, '" + cVerifica + "') >= " + Alltrim(Str(kDias01))  + CHR(13)
           //cSql += "   AND DATEDIFF(day, SE1.E1_VENCTO, '" + cVerifica + "') <= " + Alltrim(Str(kDias02))  + CHR(13)
           cSql += "   AND DATEDIFF(day, SE1.E1_VENCREA, '" + cVerifica + "') <= " + Alltrim(Str(kDias02))  + CHR(13)
      Case Substr(cComboBx222,01,01) == "2"
           //cSql += "   AND DATEDIFF(day, SE1.E1_VENCTO, '" + cVerifica + "') >= " + Alltrim(Str(kDias03))  + CHR(13)
           cSql += "   AND DATEDIFF(day, SE1.E1_VENCREA, '" + cVerifica + "') >= " + Alltrim(Str(kDias03))  + CHR(13)
           //cSql += "   AND DATEDIFF(day, SE1.E1_VENCTO, '" + cVerifica + "') <= " + Alltrim(Str(kDias04))  + CHR(13)
 	 	   cSql += "   AND DATEDIFF(day, SE1.E1_VENCREA, '" + cVerifica + "') <= " + Alltrim(Str(kDias04))  + CHR(13)
      Case Substr(cComboBx222,01,01) == "3"
           //cSql += "   AND DATEDIFF(day, SE1.E1_VENCTO, '" + cVerifica + "') >= " + Alltrim(Str(kDias05))  + CHR(13)
           cSql += "   AND DATEDIFF(day, SE1.E1_VENCREA, '" + cVerifica + "') >= " + Alltrim(Str(kDias05))  + CHR(13)
           //cSql += "   AND DATEDIFF(day, SE1.E1_VENCTO, '" + cVerifica + "') <= " + Alltrim(Str(kDias06))  + CHR(13)
           cSql += "   AND DATEDIFF(day, SE1.E1_VENCREA, '" + cVerifica + "') <= " + Alltrim(Str(kDias06))  + CHR(13)
   EndCase

   cSql += "   AND SA1.A1_COD     = SE1.E1_CLIENTE" + CHR(13)
   cSql += "   AND SA1.A1_LOJA    = SE1.E1_LOJA" + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''" + CHR(13)

//   If Substr(cComboBx111,01,01) == "0"   
//   Else
//      cSql += "  AND SA1.A1_RISCO = '" + Substr(cComboBx111,01,01) + "'"
//   Endif

   kRisco := ""
    
   If lRiscoT == .T.
   Else

      If lRiscoA == .T. .Or. lRiscoB == .T. .Or. lRiscoC == .T. .Or. lRiscoD == .T. .or. lRiscoE == .T.
         kRisco := "("
      Endif   

      If lRiscoA == .T.
         kRisco := kRisco + "'A'" + ","
      Endif   

      If lRiscoB == .T.
         kRisco := kRisco + "'B'" + ","
      Endif   

      If lRiscoC == .T.
         kRisco := kRisco + "'C'" + ","
      Endif   

      If lRiscoD == .T.
         kRisco := kRisco + "'D'" + ","
      Endif   

      If lRiscoE == .T.
         kRisco := kRisco + "'E'" + ","
      Endif   

      If Empty(Alltrim(kRisco))
      Else
         kRisco := Substr(kRisco,01,Len(Alltrim(kRisco)) - 1) + ")"
         cSql += " AND SA1.A1_RISCO IN " + kRisco
      Endif
      
   Endif
      

//   If lRiscoA == .T.
//      cSql += " AND SA1.A1_RISCO = 'A'"
//   Endif
//      
//   If lRiscoB == .T.
//      cSql += " AND SA1.A1_RISCO = 'B'"
//   Endif
//
//   If lRiscoC == .T.
//      cSql += " AND SA1.A1_RISCO = 'C'"
//   Endif
//
//   If lRiscoD == .T.
//      cSql += " AND SA1.A1_RISCO = 'D'"
//   Endif
//
//   If lRiscoE == .T.
//      cSql += " AND SA1.A1_RISCO = 'E'"
//   Endif

   If Empty(Alltrim(cCliente))
   Else
      cSql += " AND SE1.E1_CLIENTE = '" + Alltrim(cCliente) + "'" + CHR(13)
      cSql += " AND SE1.E1_LOJA    = '" + Alltrim(cLoja)    + "'" + CHR(13)
   Endif

   cSql += " ORDER BY SE1.E1_CLIENTE, SE1.E1_LOJA" + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      Do Case
         Case T_CONSULTA->A1_RISCO == "A"
              kLegenda := "2"
         Case T_CONSULTA->A1_RISCO == "B"
              kLegenda := "5"
         Case T_CONSULTA->A1_RISCO == "C"
              kLegenda := "1"
         Case T_CONSULTA->A1_RISCO == "D"
              kLegenda := "6"
         Case T_CONSULTA->A1_RISCO == "E"
              kLegenda := "8"
         Otherwise
              kLegenda := "0"              
      EndCase              

      // ##########################################
      // Despreza os registros se lJaEnvia = .T. ##
      // ##########################################
      If lJaEnvia == .T.
      Else

         Do Case 
            Case Substr(cComboBx222,01,01) == "1"
                 If Empty(Alltrim(T_CONSULTA->E1_CAR1))
                 Else
                    T_CONSULTA->( DbSkip() )
                    Loop
                 Endif
                                        
            Case Substr(cComboBx222,01,01) == "2"
                 If Empty(Alltrim(T_CONSULTA->E1_CAR2))
                 Else
                    T_CONSULTA->( DbSkip() )
                    Loop
                 Endif

            Case Substr(cComboBx222,01,01) == "3"
                 If Empty(Alltrim(T_CONSULTA->E1_CAR3))
                 Else
                    T_CONSULTA->( DbSkip() )
                    Loop
                 Endif

         EndCase

      Endif

      // ############################################################################
      // Somente mostrará registros para a regra                                   ##
      // Se solicitado carta 2, somente mostrará registro se a carta 1 foi enviada ##
      // Se solicitado carta 3, somente mostrará registro se a carta 2 foi enviada ##      
      // ############################################################################
      Do Case 

         Case Substr(cComboBx222,01,01) == "2"
              If Empty(Alltrim(T_CONSULTA->E1_CAR1))
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif

            Case Substr(cComboBx222,01,01) == "3"
                 If Empty(Alltrim(T_CONSULTA->E1_CAR2))
                    T_CONSULTA->( DbSkip() )
                    Loop
                 Endif

      EndCase

      // #################################################
      // Prepara os e-mail do cliente para visualização ##
      // #################################################

      // ############################################
      // Pesquisa o e-mail dos contatos do cliente ##
      // ############################################
      If Select("T_CONTATOS") > 0
         T_CONTATOS->( dbCloseArea() )
      EndIf

      cSql := ""                                       
      cSql := "SELECT AC8.AC8_CODENT,"
      cSql += "       SU5.U5_CODCONT,"
      cSql += "       SU5.U5_EMAIL   "
      cSql += "  FROM " + RetSqlName("AC8") + " AC8, "
      cSql += "       " + RetSqlName("SU5") + " SU5  "
      cSql += " WHERE AC8.AC8_CODENT = '" + (T_CONSULTA->E1_CLIENTE + T_CONSULTA->E1_LOJA) + "'"
      cSql += "   AND AC8.D_E_L_E_T_ = ''"
      cSql += "   AND SU5.U5_CODCONT = AC8.AC8_CODCON"
      cSql += "   AND SU5.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATOS", .T., .T. )

      kk_Email := ""
      kk_Email := Alltrim(T_CONSULTA->A1_EMAIL) + ";"

      Count To nRecCount

      If (nRecCount > 0)

         T_CONTATOS->( DbGoTop() )
         
         WHILE !T_CONTATOS->( EOF() )

            If Empty(Alltrim(T_CONTATOS->U5_EMAIL))
               T_CONTATOS->( DbSkip() )
               Loop
            Endif   

            kk_Email := kk_Email + Alltrim(T_CONTATOS->U5_EMAIL) + ";"
            
            T_CONTATOS->( DbSkip() )
            
         Enddo   
            
      Endif

      // ###############################################
      // Elimina o último Ponto e Vírgula dos E-Mails ##
      // ###############################################
      If !Empty(Alltrim(kk_Email))
         kk_Email := Substr(kk_Email,01, Len(Alltrim(kk_Email)) - 1)
      Endif

      // #################################################
      // Abre a linha com e-mail do cadastro do cliente ##
      // #################################################
      aAdd( aLista, { kLegenda                 ,;
                      T_CONSULTA->E1_CLIENTE   ,;
                      T_CONSULTA->E1_LOJA      ,;
                      T_CONSULTA->A1_NOME      ,;
                      .F.                      ,;
                      T_CONSULTA->E1_PREFIXO   ,;
                      T_CONSULTA->E1_NUM       ,;
                      T_CONSULTA->E1_PARCELA   ,;
                      Substr(T_CONSULTA->E1_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->E1_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->E1_EMISSAO,01,04) ,;
                      Substr(T_CONSULTA->E1_VENCREA,07,02) + "/" + Substr(T_CONSULTA->E1_VENCREA,05,02) + "/" + Substr(T_CONSULTA->E1_VENCREA,01,04) ,;                      
                      T_CONSULTA->ATRASO       ,;
                      TRANSFORM(T_CONSULTA->E1_VALOR, "@E 9999999.99") ,;
                      T_CONSULTA->E1_CAR1      ,;
                      Substr(T_CONSULTA->E1_DEN1,07,02) + "/" + Substr(T_CONSULTA->E1_DEN1,05,02) + "/" + Substr(T_CONSULTA->E1_DEN1,01,04) ,;                      
                      T_CONSULTA->E1_CAR2      ,;
                      Substr(T_CONSULTA->E1_DEN2,07,02) + "/" + Substr(T_CONSULTA->E1_DEN2,05,02) + "/" + Substr(T_CONSULTA->E1_DEN2,01,04) ,;                      
                      T_CONSULTA->E1_CAR3      ,;
                      Substr(T_CONSULTA->E1_DEN3,07,02) + "/" + Substr(T_CONSULTA->E1_DEN3,05,02) + "/" + Substr(T_CONSULTA->E1_DEN3,01,04) ,;
                      kk_Email                 ,;                      
                      T_CONSULTA->E1_CLIENTE   ,;
                      T_CONSULTA->E1_LOJA      ,;
                      T_CONSULTA->A1_NOME      ,;
                      T_CONSULTA->E1_PREFIXO   ,;
                      T_CONSULTA->E1_NUM       ,;
                      T_CONSULTA->E1_PARCELA   ,;
                      Substr(T_CONSULTA->E1_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->E1_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->E1_EMISSAO,01,04) ,;
                      Substr(T_CONSULTA->E1_VENCREA,07,02) + "/" + Substr(T_CONSULTA->E1_VENCREA,05,02) + "/" + Substr(T_CONSULTA->E1_VENCREA,01,04) ,;                      
                      T_CONSULTA->ATRASO       ,;
                      TRANSFORM(T_CONSULTA->E1_VALOR, "@E 9999999.99") ,;
                      ""                       ,;
                      T_CONSULTA->E1_TIPO      ,;
                      T_CONSULTA->E1_NATUREZ   ,;
                      T_CONSULTA->E1_NUMBCO    ,;
                      T_CONSULTA->A1_CGC       })

////                  Substr(/*T_CONSULTA->E1_VENCTO*/T_CONSULTA->E1_VENCREA,07,02) + "/" + Substr(/*T_CONSULTA->E1_VENCTO*/T_CONSULTA->E1_VENCREA ,05,02) + "/" + Substr(/*T_CONSULTA->E1_VENCTO*/T_CONSULTA->E1_VENCREA ,01,04) ,;                      


/*
      // ############################################
      // Pesquisa o e-mail dos contatos do cliente ##
      // ############################################
      If Select("T_CONTATOS") > 0
         T_CONTATOS->( dbCloseArea() )
      EndIf

      cSql := ""                                       
      cSql := "SELECT AC8.AC8_CODENT,"
      cSql += "       SU5.U5_CODCONT,"
      cSql += "       SU5.U5_EMAIL   "
      cSql += "  FROM " + RetSqlName("AC8") + " AC8, "
      cSql += "       " + RetSqlName("SU5") + " SU5  "
      cSql += " WHERE AC8.AC8_CODENT = '" + (T_CONSULTA->E1_CLIENTE + T_CONSULTA->E1_LOJA) + "'"
      cSql += "   AND AC8.D_E_L_E_T_ = ''"
      cSql += "   AND SU5.U5_CODCONT = AC8.AC8_CODCON"
      cSql += "   AND SU5.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATOS", .T., .T. )

      Count To nRecCount

      If (nRecCount > 0)

         T_CONTATOS->( DbGoTop() )
         
         WHILE !T_CONTATOS->( EOF() )

            If Empty(Alltrim(T_CONTATOS->U5_EMAIL))
               T_CONTATOS->( DbSkip() )
               Loop
            Endif   

            aAdd( aLista, { ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            .F.                 ,; 
                            "9"                 ,; 
                            T_CONTATOS->U5_EMAIL,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,;             
                            ""                  ,; 
                            ""                  ,; 
                            ""                  ,; 
                            T_CONSULTA->E1_CLIENTE   ,;
                            T_CONSULTA->E1_LOJA      ,;
                            T_CONSULTA->A1_NOME      ,;
                            T_CONSULTA->E1_PREFIXO   ,;
                            T_CONSULTA->E1_NUM       ,;
                            T_CONSULTA->E1_PARCELA   ,;
                            Substr(T_CONSULTA->E1_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->E1_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->E1_EMISSAO,01,04) ,;
                            Substr(T_CONSULTA->E1_VENCTO ,07,02) + "/" + Substr(T_CONSULTA->E1_VENCTO ,05,02) + "/" + Substr(T_CONSULTA->E1_VENCTO ,01,04) ,;                      
                            T_CONSULTA->ATRASO       ,;
                            TRANSFORM(T_CONSULTA->E1_VALOR, "@E 9999999.99") ,;
                            T_CONTATOS->U5_CODCONT   ,;
                            T_CONSULTA->E1_TIPO      })
            
            T_CONTATOS->( DbSkip() )
            
         Enddo   
            
      Endif

*/
                         
      T_CONSULTA->( DbSkip() )
       
   ENDDO                  
   
   If Len(aLista) == 0
      aAdd( aLista, { "0", "", "", "", .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   oLista:SetArray( aLista )

   oLista:bLine := {||{ If(aLista[oLista:nAt,01] == "0", oBranco   ,;
                        If(aLista[oLista:nAt,01] == "2", oVerde    ,;
                        If(aLista[oLista:nAt,01] == "3", oCancel   ,;                         
                        If(aLista[oLista:nAt,01] == "1", oAmarelo  ,;                         
                        If(aLista[oLista:nAt,01] == "5", oAzul     ,;                         
                        If(aLista[oLista:nAt,01] == "6", oLaranja  ,;                         
                        If(aLista[oLista:nAt,01] == "7", oPreto    ,;                         
                        If(aLista[oLista:nAt,01] == "8", oVermelho ,;
                        If(aLista[oLista:nAt,01] == "9", oPink     ,;
                        If(aLista[oLista:nAt,01] == "4", oEncerra, "")))))))))),;
                           aLista[oLista:nAt,02]         ,;
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                       Iif(aLista[oLista:nAt,05],oOk,oNo)          ,;
                           aLista[oLista:nAt,06]         ,;
                           aLista[oLista:nAt,07]         ,;
                           aLista[oLista:nAt,08]         ,;
                           aLista[oLista:nAt,09]         ,;
                           aLista[oLista:nAt,10]         ,;
                           aLista[oLista:nAt,11]         ,;
                           aLista[oLista:nAt,12]         ,;
                           aLista[oLista:nAt,13]         ,;
                           aLista[oLista:nAt,14]         ,;
                           aLista[oLista:nAt,15]         ,;
                           aLista[oLista:nAt,16]         ,;
                           aLista[oLista:nAt,17]         ,;                                                                                                                                       
                           aLista[oLista:nAt,18]         ,;                                                                                                                                       
                           aLista[oLista:nAt,19]         }}

Return(.T.)   

// ######################################################
// Função que parametriza as cartas de aviso de débito ##
// ######################################################
Static Function TextoCartas()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgTX

   DEFINE MSDIALOG oDlgTX TITLE "Parametrização Carta de Aviso de Débito" FROM C(178),C(181) TO C(457),C(432) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(120),C(026) PIXEL NOBORDER OF oDlgTX

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(119),C(001) PIXEL OF oDlgTX

   @ C(036),C(005) Button "CARTA AVISO DE DÉBITO 1" Size C(116),C(024) PIXEL OF oDlgTX ACTION( xTextoCartas(1) )
   @ C(061),C(005) Button "CARTA AVISO DE DÉBITO 2" Size C(116),C(024) PIXEL OF oDlgTX ACTION( xTextoCartas(2) )
   @ C(087),C(005) Button "CARTA AVISO DE DÉBITO 3" Size C(116),C(024) PIXEL OF oDlgTX ACTION( xTextoCartas(3) )
   @ C(112),C(005) Button "VOLTAR"                  Size C(116),C(024) PIXEL OF oDlgTX ACTION( oDlgTX:End() )

   ACTIVATE MSDIALOG oDlgTX CENTERED 

Return(.T.)

// ######################################################
// Função que parametriza as cartas de aviso de débito ##
// ######################################################
Static Function xTextoCartas(kTipo)
 
   Local lChumba := .F. 

   Local cMemo1  := ""
   Local oMemo1
      
   Private nDias01 := 0
   Private nDias02 := 0
   Private cTexto1 := ""
   Private cTexto2 := ""
   Private cTexto3 := ""

   Private oGet1
   Private oGet2
   Private oMemo2
   Private oMemo3
   Private oMemo4

   Private oDlgCC

   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT1)) AS CARTA1, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT2)) AS CARTA2, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT3)) AS CARTA3, "
   cSql += "       ZZ4_DC01, "
   cSql += "       ZZ4_DC02, "
   cSql += "       ZZ4_DC03, "
   cSql += "       ZZ4_DC04, "
   cSql += "       ZZ4_DC05, "
   cSql += "       ZZ4_DC06  "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   Do Case 
   
      Case kTipo == 1
           cTexto1 := U_P_CORTA(T_PARAMETROS->CARTA1, "|", 1)
           cTexto3 := U_P_CORTA(T_PARAMETROS->CARTA1, "|", 2)
           nDias01 := T_PARAMETROS->ZZ4_DC01
           nDias02 := T_PARAMETROS->ZZ4_DC02

      Case kTipo == 2
           cTexto1 := U_P_CORTA(T_PARAMETROS->CARTA2, "|", 1)
           cTexto3 := U_P_CORTA(T_PARAMETROS->CARTA2, "|", 2)
           nDias01 := T_PARAMETROS->ZZ4_DC03
           nDias02 := T_PARAMETROS->ZZ4_DC04

      Case kTipo == 3
           cTexto1 := U_P_CORTA(T_PARAMETROS->CARTA3, "|", 1)
           cTexto3 := U_P_CORTA(T_PARAMETROS->CARTA3, "|", 2)
           nDias01 := T_PARAMETROS->ZZ4_DC05
           nDias02 := T_PARAMETROS->ZZ4_DC06

   EndCase

   Private oDlgCC
  
   DEFINE MSDIALOG oDlgCC TITLE "Parametrização Carta de Aviso de Débito" FROM C(178),C(181) TO C(642),C(654) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgCC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(227),C(001) PIXEL OF oDlgCC

   @ C(023),C(152) Say "CARTA AVISO DE DÉBITO [ " + Alltrim(Str(kTipo)) + " ]"                            Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(036),C(005) Say "Texto superior carta de aviso de débito"                                          Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(036),C(116) Say "# - Nome do Cliente"                                                              Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(036),C(170) Say "& - CNPJ/CPF do Cliente"                                                          Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(109),C(005) Say "Quandro informativo de títulos em atraso elaborados automaticamente pelo sistema" Size C(198),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(157),C(005) Say "Texto a ser impresso logo abaixo do quadro informativo de títulos em atraso"      Size C(180),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(204),C(005) Say "Enviar Carta para títulos em atraso de/até (Dias)"                                Size C(116),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(214),C(026) Say "De"                                                                               Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
   @ C(214),C(063) Say "até"                                                                              Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgCC
	   
   @ C(046),C(005) GET oMemo2  Var cTexto1 MEMO Size C(227),C(062)                                    PIXEL OF oDlgCC
   @ C(119),C(005) GET oMemo3  Var cTexto2 MEMO Size C(227),C(037)                                    PIXEL OF oDlgCC When lChumba
   @ C(167),C(005) GET oMemo4  Var cTexto3 MEMO Size C(227),C(033)                                    PIXEL OF oDlgCC
   @ C(213),C(036) MsGet oGet1 Var nDias01      Size C(024),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgCC
   @ C(213),C(073) MsGet oGet2 Var nDias02      Size C(024),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgCC

   @ C(215),C(194) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCC  ACTION( SalvaTexto(kTipo) )

   ACTIVATE MSDIALOG oDlgCC CENTERED 

Return(.T.)

// ######################################################
// Função que parametriza as cartas de aviso de débito ##
// ######################################################
Static Function SalvaTexto(kTipo)

   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   Do Case
   
      Case kTipo == 1
           ZZ4->ZZ4_CRT1 := Alltrim(cTexto1) + "|" + Alltrim(cTexto3) + "|"
           ZZ4->ZZ4_DC01 := nDias01
           ZZ4->ZZ4_DC02 := nDias02

      Case kTipo == 2
           ZZ4->ZZ4_CRT2 := Alltrim(cTexto1) + "|" + Alltrim(cTexto3) + "|"
           ZZ4->ZZ4_DC03 := nDias01
           ZZ4->ZZ4_DC04 := nDias02

      Case kTipo == 3
           ZZ4->ZZ4_CRT3 := Alltrim(cTexto1) + "|" + Alltrim(cTexto3) + "|"
           ZZ4->ZZ4_DC05 := nDias01
           ZZ4->ZZ4_DC06 := nDias02

   EndCase
   
   MsUnLock()

   oDlgCC:End() 

Return(.T.)   

// ##########################################################
// Função que permite usuário alterar o e-mail do registro ##
// ##########################################################
Static Function AlteraEmail()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private kCliente	 := aLista[oLista:nAt,20] + "." + aLista[oLista:nAt,21] + " - " + aLista[oLista:nAt,22]
   Private kCadastro := "E-mails do Cliente" 
   Private kEmail1 	 := aLista[oLista:nAt,19]
   Private kEmail2 	 := aLista[oLista:nAt,19] + Space(250 - Len(Alltrim(aLista[oLista:nAt,19])))
   Private kContato  := aLista[oLista:nAt,31]

   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlgEMAIL

   If Empty(Alltrim(aLista[oLista:nAt,21]))
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgEMAIL TITLE "Alteração de E-mail" FROM C(178),C(181) TO C(467),C(725) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgEMAIL

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(265),C(001) PIXEL OF oDlgEMAIL
   @ C(120),C(002) GET oMemo2 Var cMemo2 MEMO Size C(265),C(001) PIXEL OF oDlgEMAIL
   
   @ C(037),C(005) Say "Alteração de E-mail de Cliente/Contato" Size C(097),C(008) COLOR CLR_BLACK PIXEL OF oDlgEMAIL
   @ C(050),C(005) Say "Cliente"                                Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgEMAIL
   @ C(050),C(207) Say "E-Mail de"                              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgEMAIL
   @ C(073),C(005) Say "E-mail Atual"                           Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgEMAIL
   @ C(095),C(005) Say "Novo E-mail"                            Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgEMAIL
   @ C(040),C(167) Say "Código Contato"                         Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgEMAIL

   @ C(039),C(207) MsGet oGet7 Var kContato  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEMAIL When lChumba
   @ C(060),C(005) MsGet oGet3 Var kCliente  Size C(196),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEMAIL When lChumba
   @ C(060),C(207) MsGet oGet4 Var kCadastro Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEMAIL When lChumba
   @ C(082),C(005) MsGet oGet5 Var kEmail1   Size C(263),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEMAIL When lChumba
   @ C(104),C(005) MsGet oGet6 Var kEmail2   Size C(263),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEMAIL && When IIF(aLista[oLista:nAt,06] == "9", .T., .F.)

   @ C(128),C(096) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgEMAIL ACTION( SlvContato() )
   @ C(128),C(135) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgEMAIL ACTION( oDlgEMAIL:End() )

   ACTIVATE MSDIALOG oDlgEMAIL CENTERED 

Return(.T.)

// ###################################################
// Função que grava o e-mail do contato selecionado ##
// ###################################################
Static Function SlvContato()

   Local cSql := ""

   If Empty(Alltrim(kEmail2))
      MsgAlert("E-mail do contato não informado. Verifique!")
      Return(.T.)
   Endif
   
//   cSql := ""
//   cSql := "UPDATE " + RetSqlName("SU5")
//   cSql += "   SET "
//   cSql += "   U5_EMAIL       = '" + Alltrim(kEmail2)  + "'"
//   cSql += " WHERE U5_CODCONT = '" + Alltrim(kContato) + "'"
//
//   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   aLista[oLista:nAt,19] := kEmail2

   oDlgEMAIL:End()

Return(.T.)      

// #################################################
// Função que envia e-mail dos registros marcados ##
// #################################################
Static Function EnviaEmailCC()

   MsgRun("Aguarde! Enviando E-mails selecionados ...", "Envio de Aviso de Débito",{|| xEnviaEmailCC() })

Return(.T.)

// #################################################
// Função que envia e-mail dos registros marcados ##
// #################################################
Static Function xEnviaEmailCC()

   Local nContar  := 0
   Local _cHTML   := ""
   Local cString1 := ""
   Local cString2 := ""
   Local lMarcado := .F.
   Local lRetorno := .T.
   
   // ############################################################################
   // Verifica se houve marcação de pelo menos um registro para envio de e-mail ##
   // ############################################################################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,05] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      MsgAlert("Nenhum registro foi selecionado para envio de e-mail. Verifique!")
      Return(.T.)
   Endif          

   // ##########################################
   // Solicita confirmação de envio de e-mail ##
   // ##########################################
   If MsgYesNo("Deseja realmente enviar os e-mail indicados?")
   Else
      Return(.T.)
   Endif   

   // ###############################################
   // Pesquisa o texto da carta conforme parâmetro ##
   // ############################################### 
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT1)) AS CARTA1, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT2)) AS CARTA2, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT3)) AS CARTA3  "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   Do Case 
      Case Substr(cComboBx222,01,01) == "1"
           kTexto1  := U_P_CORTA(T_PARAMETROS->CARTA1, "|", 1)
           kTexto2  := U_P_CORTA(T_PARAMETROS->CARTA1, "|", 2)
           ww_Carta := "1"

      Case Substr(cComboBx222,01,01) == "2"
           kTexto1  := U_P_CORTA(T_PARAMETROS->CARTA2, "|", 1)
           kTexto2  := U_P_CORTA(T_PARAMETROS->CARTA2, "|", 2)
           ww_Carta := "2"

      Case Substr(cComboBx222,01,01) == "3"
           ktexto1  := U_P_CORTA(T_PARAMETROS->CARTA3, "|", 1)
           ktexto2  := U_P_CORTA(T_PARAMETROS->CARTA3, "|", 2)
           ww_Carta := "3"

   EndCase
   
   // ############################
   // Elabora o HTML para envio ##
   // ############################
   For nContar = 1 to Len(aLista)
    
       If aLista[nContar,05] == .F.
          Loop
       Endif

       // ######################################################
       // Prepara o nº do documento do cliente para impressão ##
       // ######################################################       
       kDocumento := POSICIONE("SA1",1,XFILIAL("SA1") + aLista[nContar,20] + aLista[nContar,21],"A1_CGC")

       If Len(Alltrim(kDocumento)) == 14
          kCNPJCPF := Substr(kDocumento,01,02) + "." + ;
                      Substr(kDocumento,03,03) + "." + ;
                      Substr(kDocumento,06,03) + "/" + ;
                      Substr(kDocumento,09,04) + "-" + ;
                      Substr(kDocumento,13,02)
       Else
          kCNPJCPF := Substr(kDocumento,01,03) + "." + ;
                      Substr(kDocumento,04,03) + "." + ;
                      Substr(kDocumento,07,03) + "-" + ;
                      Substr(kDocumento,10,03)
       Endif       

       cString1 := Strtran(kTexto1 , "#", aLista[nContar,22])
       cString1 := Strtran(cString1, "&", "CNPJ/CPF: " + kCNPJCPF)
       cString1 := Strtran(cString1, CHR(13), "<br></br>")
       
       cString2 := Strtran(kTexto2 , "#", aLista[nContar,22])
       cString2 := Strtran(cString2, "&", "CNPJ/CPF: " + kCNPJCPF)
       cString2 := Strtran(cString2, CHR(13), "<br></br>")

       // #################
       // Início do HTML ##
       // #################
       _cHTML:='<HTML><HEAD><TITLE></TITLE>'
       _cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
       _cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
       _cHTML+='<BODY>'

       // ###########################
       // Imprime o texto da carta ##
       // ########################### 
       _cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">' + Alltrim(cString1) + '</h3></font>'

       // ######################################
       // Cria o quadro dos títulos em atraso ##
       // ######################################
       _cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#CCCCCC" BGCOLOR=#EEE9E9 CELLPADDING=2 CELLSPACING=0 STYLE="page-break-before: always">'

       _cHtml += '	<TR ALIGN=TOP>'
       _cHtml += '		<TD ALIGN=LEFT WIDTH=60 >'
       _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>PREFIXO</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>Nº TÍTULO</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>Nº PARCELA</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>EMISSÃO</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>VENCIMENTO</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>DIAS ATRASO</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
       _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>VALOR DO TÍTULO</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '	</TR>'

       // ######################################
       // Inclui os dados do título em atraso ##
       // ######################################
       _cHtml += '<TR ALIGN=TOP>'
       _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
       _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + aLista[nContar,23] + '</P></font>'
       _cHtml += '		</TD>'
	
       _cHtml += '		<TD ALIGN=LEFT bgcolor=#FFFFFF>'
       _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + aLista[nContar,24] + '</P></font>'
       _cHtml += '		</TD>'
	  
       _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
       _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + aLista[nContar,25] + '</P></font>'
       _cHtml += '		</TD>'
    
       _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
       _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + aLista[nContar,26] + '</P></font>'
       _cHtml += '		</TD>'

       _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
       _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + aLista[nContar,27] + '</P></font>'
       _cHtml += '		</TD>'
    
       _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
       _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + Transform(aLista[nContar,28], "@E 99999") + '</P></font>'
       _cHtml += '		</TD>'
    
      _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
      _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + Transform(aLista[nContar,29], "@E 9999999.99") + '</P></font>'
      _cHtml += '		</TD>'

      _cHtml += '</TR>'
	
      _cHtml 	+= '</TABLE>'

       // ###############################################
       // Imprime o texto abaixo do quadro de parcelas ##
       // ###############################################
       If Empty(Alltrim(cString2))
          _cHtml	+= '<br></br>'
          _cHtml	+= '<br></br>'
       Else
          _cHtml	+= '<br></br>'
          _cHtml	+= '<br></br>'
          _cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">' + Alltrim(cString2) + '</h3></font>'
          _cHtml	+= '<br></br>'
          _cHtml	+= '<br></br>'
       Endif

       kEnviadoPor := ""
       kEnviadoPor += 'Att.'                                  + '<br></br>' + '<br></br>'
       kEnviadoPor += 'Automatech Sistemas de Automação Ltda' + '<br></br>'
       kEnviadoPor += 'Fone: (51) - 3017-8300'                + '<br></br>'
       kEnviadoPor += 'www.automatech.com.br'                 + '<br></br>' + '<br></br>'

       _cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">' + Alltrim(kEnviadoPor) + '</h3></font>'
   
       _cHtml	+= '<br></br>'
       _cHtml	+= '<br></br>'
       _cHtml 	+= '<b><font size="1" color=#696969 face="Verdana"> E-mail enviado automaticamente, nao responda este e-mail </font></b>'
       _cHtml	+= '<br></br>'
       _cHtml	+= '<br></br>'
       _cHtml 	+= '</head>'
       _cHtml 	+= '</html>'

       // #################
       // Envia o e-mail ##
       // #################
       cParaQuem := Alltrim(aLista[nContar,19])

       lRetorno := U_AUTOMR20(_cHtml, cParaQuem, "", "AVISO DE COBRANÇA")

       // ############################################################
       // Atualiza o envio da carta no cadastro de contas a receber ##
       // ############################################################
       If lRetorno == .T.
     	  DbSelectArea("SE1")
	      DbSetOrder(1)   
	      If DbSeek(xFilial("SE1") + aLista[nContar,23] + aLista[nContar,24] + aLista[nContar,25] + aLista[nContar,31])

		     RecLock("SE1",.F.)
             
             Do Case

                Case Substr(cComboBx222,01,01) == "1"
    		         SE1->E1_CAR1 := "X"
    		         SE1->E1_DEN1 := Date()
    		      
                Case Substr(cComboBx222,01,01) == "2"
    		         SE1->E1_CAR2 := "X"
    		         SE1->E1_DEN2 := Date()

                Case Substr(cComboBx222,01,01) == "3"
    		         SE1->E1_CAR3 := "X"
    		         SE1->E1_DEN3 := Date()

             EndCase

      	     MsUnLock()
      	     
 		  EndIf
 	   
          // ##################################################
 		  // Cria um resgistro de atendimento no Call Center ##
 		  // ##################################################
 		  
          // ##############################
          // Abre registro na tabela SYP ##
          // ##############################
          
          // ##########################################
          // Pesquisa o próximo código para inclusão ##
          // ##########################################
          cPrxSyp := GetSXENum("SYP","SY_CHAVE")
          ConfirmSX8()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "001"
          SYP->YP_TEXTO := Dtoc(Date()) + " - " + Time() + "\13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "002"
          SYP->YP_TEXTO := "Envio de e-mail de Cobrança de Título em atraso \13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "003"
          SYP->YP_TEXTO := "Carta enviada: Carta " + ww_carta + "\13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "004"
          SYP->YP_TEXTO := "Período de Cobrança: " + cComboBx222 + "\13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "005"
          SYP->YP_TEXTO := "Título Cobrado: \13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "006"
          SYP->YP_TEXTO := "Prefixo: " + aLista[nContar,06] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "007"
          SYP->YP_TEXTO := "Nº Título: " + aLista[nContar,07] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "008"
          SYP->YP_TEXTO := "Parcela: " + aLista[nContar,08] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "009"
          SYP->YP_TEXTO := "Emissão: " + aLista[nContar,09] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "010"
          SYP->YP_TEXTO := "Vencimento: " + aLista[nContar,10] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "011"
          SYP->YP_TEXTO := "Valor Título: " + aLista[nContar,12] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()
 		  
          // ##############################
          // Abre regsitro na tabela ACF ##
          // ##############################

          // ##########################################
          // Pesquisa o próximo código para inclusão ##
          // ##########################################
          cPrxACF := GetSXENum("ACF","ACF_CODIGO")
          ConfirmSX8()

	      dbSelectArea("ACF")
		  RecLock("ACF",.T.)
 		  ACF->ACF_FILIAL := cFilAnt
 		  ACF->ACF_CODIGO := cPrxACF
 		  ACF->ACF_CLIENT := aLista[nContar,02]
 		  ACF->ACF_LOJA   := aLista[nContar,03]
 		  ACF->ACF_OPERAD := "000007"
 		  ACF->ACF_OPERA  := "1"
 		  ACF->ACF_STATUS := "2"
 		  ACF->ACF_DATA   := Date()
 		  ACF->ACF_CODOBS := cPrxSyp
 		  ACF->ACF_PENDEN := Date()
 		  ACF->ACF_HRPEND := Substr(Time(),01,05)
 		  ACF->ACF_INICIO := Time()
 		  ACF->ACF_FIM    := Time()
 		  ACF->ACF_DIASDA := 9992
 		  ACF->ACF_HORADA := 22668
 		  ACF->ACF_OPERAT := "000007"
 		  ACF->ACF_ULTATE := Date()
      	  MsUnlock() 		  

          // ##############################
          // Abre registro na tabela ACG ##
          // ##############################
	      dbSelectArea("ACG")
		  RecLock("ACG",.T.)
          ACG->ACG_FILIAL := cFilAnt
          ACG->ACG_CODIGO := cPrxACF
          ACG->ACG_PREFIX := aLista[nContar,06]
          ACG->ACG_TITULO := aLista[nContar,07]
          ACG->ACG_PARCEL := aLista[nContar,08]
          ACG->ACG_TIPO   := aLista[nContar,31]
          ACG->ACG_DTVENC := Ctod(aLista[nContar,10])
          ACG->ACG_DTREAL := Ctod(aLista[nContar,10])
          ACG->ACG_VALOR  := VAL(aLista[nContar,12])
          ACG->ACG_RECEBE := VAL(aLista[nContar,12])
          ACG->ACG_NATURE := aLista[nContar,32]
          ACG->ACG_NUMBCO := aLista[nContar,33]
          ACG->ACG_VALREF := VAL(aLista[nContar,12])
          ACG->ACG_STATUS := "2"
      	  MsUnlock() 		   		  


/*

	      dbSelectArea("ACF")
		  RecLock("ACF",.T.)
 		  ACF->ACF_FILIAL := cFilAnt
 		  ACF->ACF_CODIGO := cPrxACF
 		  ACF->ACF_CLIENT := aLista[nContar,02]
 		  ACF->ACF_LOJA   := aLista[nContar,03]
 		  ACF->ACF_OPERAD := "000007"
 		  ACF->ACF_OPERA  := "1"
 		  ACF->ACF_STATUS := "2"
 		  ACF->ACF_DATA   := Date()
 		  ACF->ACF_CODOBS := cPrxSyp
 		  ACF->ACF_PENDEN := Date()
 		  ACF->ACF_HRPEND := Substr(Time(),01,05)
 		  ACF->ACF_INICIO := Time()
 		  ACF->ACF_FIM    := Time()
 		  ACF->ACF_DIASDA := 9992
 		  ACF->ACF_HORADA := 22668
 		  ACF->ACF_OPERAT := "000007"
 		  ACF->ACF_ULTATE := Date()
      	  MsUnlock() 		  

          // ##############################
          // Abre registro na tabela ACG ##
          // ##############################
	      dbSelectArea("ACG")
		  RecLock("ACG",.T.)
          ACG->ACG_FILIAL := cFilAnt
          ACG->ACG_CODIGO := cPrxACF
          ACG->ACG_PREFIX := aLista[nContar,06]
          ACG->ACG_TITULO := aLista[nContar,07]
          ACG->ACG_PARCEL := aLista[nContar,08]
          ACG->ACG_TIPO   := aLista[nContar,31]
          ACG->ACG_DTVENC := Ctod(aLista[nContar,10])
          ACG->ACG_DTREAL := Ctod(aLista[nContar,10])
          ACG->ACG_VALOR  := aLista[nContar,12]
          ACG->ACG_RECEBE := aLista[nContar,12]
          ACG->ACG_NATURE := aLista[nContar,32]
          ACG->ACG_NUMBCO := aLista[nContar,33]
          ACG->ACG_VALREF := aLista[nContar,12]
          ACG->ACG_STATUS := "2"
      	  MsUnlock() 		   		  

*/

 	   Endif	  

   Next nContar

   MsgAlert("E-Mail(s) enviado(s) com sucesso!")

   // #########################################
   // Atualiza a tela após envio dos e-mails ##
   // #########################################
   TrazDados()
 
Return(.T.)

// ######################################## 
// Função que mostra as legendas do grid ##
// ########################################
Static Function MMMLegenda()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private oDlgLEGENDA

   DEFINE MSDIALOG oDlgLEGENDA TITLE "Legendas" FROM C(178),C(181) TO C(459),C(679) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgLEGENDA

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(242),C(001) PIXEL OF oDlgLEGENDA
   @ C(035),C(086) GET oMemo2 Var cMemo2 MEMO Size C(001),C(080) PIXEL OF oDlgLEGENDA
   @ C(118),C(002) GET oMemo3 Var cMemo3 MEMO Size C(242),C(001) PIXEL OF oDlgLEGENDA

   @ C(038),C(005) Say "LEGENDA - RISCO CLIENTE"                 Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(038),C(097) Say "LEGENDA - E-MAIL DO CLIENTE"             Size C(082),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(052),C(028) Say "RISCO A"                                 Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(065),C(028) Say "RISCO B"                                 Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(078),C(028) Say "RISCO C"                                 Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(091),C(028) Say "RISCO D"                                 Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(104),C(028) Say "RISCO E"                                 Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(052),C(120) Say "E-MAILs CADASTRO DO CLIENTE"             Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   @ C(065),C(120) Say "E-MAILs CADASTRO DE CONTATOS DO CLIENTE" Size C(126),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEGENDA
   
   @ C(051),C(015) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgLEGENDA
   @ C(064),C(015) Jpeg FILE "br_azul.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlgLEGENDA
   @ C(077),C(015) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgLEGENDA
   @ C(090),C(015) Jpeg FILE "br_laranja.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgLEGENDA
   @ C(103),C(015) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlgLEGENDA
   @ C(051),C(107) Jpeg FILE "br_marrom.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlgLEGENDA
   @ C(064),C(107) Jpeg FILE "br_pink.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlgLEGENDA

   @ C(124),C(106) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLEGENDA ACTION( oDlgLEGENDA:End() )

   ACTIVATE MSDIALOG oDlgLEGENDA CENTERED 

Return(.T.)

//   _cHTML+='<TABLE cellSpacing=0 cellPadding=0 width="100%" bgColor=#afeeee background="" '
//   _cHTML+='border=1>'
//   _cHTML+='  <TBODY>'
//   _cHTML+='  <TR>'
//   _cHTML+='    <TD>Voce está participando</TD>'
//
//   _cHTML+='<TD>titulo</TD></TR>'
//
//   _cHTML+='<TD>123</TD></TR>'
//   _cHTML+='  <TR>'
//   _cHTML+='    <TD>de um teste de envio</TD>'
//   _cHTML+='    <TD>456</TD></TR>'
//   _cHTML+='  <TR>'
//   _cHTML+='    <TD>de email!!!</TD>'
//   _cHTML+='    <TD>789</TD></TR></TBODY></TABLE>'

//   _cHTML+='<P>&nbsp;</P>'

//   _cHTML+='<P><A href="http://www.codigofonte.com.br">Clique nesse '

//   _cHTML+='link!!!</A></P></BODY></HTML>'





Static Function PegaPrxSeq()

   Local cCodigo := GetSXENum("SYP","SY_CHAVE")
   
//    ConfirmSX8()

   MsgAlert(cCodigo)


Return(.T.)

// ###############################################################
// Função que envia e-mail dos registros marcados via freshdesk ##
// ###############################################################
Static Function ffEnviaEmailCC()

   MsgRun("Aguarde! Enviando E-mails selecionados ...", "Envio de Aviso de Débito",{|| dskEnviaEmailCC() })

Return(.T.)

// #################################################
// Função que envia e-mail dos registros marcados ##
// #################################################
Static Function dskEnviaEmailCC()

   Local nContar     := 0
   Local _cHTML      := ""
   Local cString1    := ""
   Local cString2    := ""
   Local lMarcado    := .F.
   Local lRetorno    := .T.
   Local nTentativas := 0
   Local lExiste     := .F.
   Local cSTIM       := 1000000
      
   // ############################################################################
   // Verifica se houve marcação de pelo menos um registro para envio de e-mail ##
   // ############################################################################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,05] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      MsgAlert("Nenhum registro foi selecionado para envio de e-mail. Verifique!")
      Return(.T.)
   Endif          

   // ##########################################
   // Solicita confirmação de envio de e-mail ##
   // ##########################################
   If MsgYesNo("Deseja realmente enviar os e-mail indicados?")
   Else
      Return(.T.)
   Endif   

   // ###############################################
   // Pesquisa o texto da carta conforme parâmetro ##
   // ############################################### 
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT1)) AS CARTA1, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT2)) AS CARTA2, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CRT3)) AS CARTA3  "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   Do Case 
      Case Substr(cComboBx222,01,01) == "1"
           kTexto1  := U_P_CORTA(T_PARAMETROS->CARTA1, "|", 1)
           kTexto2  := U_P_CORTA(T_PARAMETROS->CARTA1, "|", 2)
           ww_Carta := "1"

      Case Substr(cComboBx222,01,01) == "2"
           kTexto1  := U_P_CORTA(T_PARAMETROS->CARTA2, "|", 1)
           kTexto2  := U_P_CORTA(T_PARAMETROS->CARTA2, "|", 2)
           ww_Carta := "2"

      Case Substr(cComboBx222,01,01) == "3"
           ktexto1  := U_P_CORTA(T_PARAMETROS->CARTA3, "|", 1)
           ktexto2  := U_P_CORTA(T_PARAMETROS->CARTA3, "|", 2)
           ww_Carta := "3"

   EndCase
   
   // ############################
   // Elabora o HTML para envio ##
   // ############################
   For nContar = 1 to Len(aLista)
    
       If aLista[nContar,05] == .F.
          Loop
       Endif

       // ######################################################
       // Prepara o nº do documento do cliente para impressão ##
       // ######################################################       
       kDocumento := POSICIONE("SA1",1,XFILIAL("SA1") + aLista[nContar,20] + aLista[nContar,21],"A1_CGC")

       If Len(Alltrim(kDocumento)) == 14
          kCNPJCPF0 := kDocumento
          kCNPJCPF  := Substr(kDocumento,01,02) + "." + ;
                       Substr(kDocumento,03,03) + "." + ;
                       Substr(kDocumento,06,03) + "/" + ;
                       Substr(kDocumento,09,04) + "-" + ;
                       Substr(kDocumento,13,02)
       Else
          kCNPJCPF0 := kDocumento
          kCNPJCPF  := Substr(kDocumento,01,03) + "." + ;
                       Substr(kDocumento,04,03) + "." + ;
                       Substr(kDocumento,07,03) + "-" + ;
                       Substr(kDocumento,10,03)
       Endif       

       cString1 := Strtran(kTexto1 , "#", Alltrim(aLista[nContar,22]))
       cString1 := Strtran(cString1, "&", "CNPJ/CPF: " + kCNPJCPF)
       cString1 := Strtran(cString1, CHR(13), "<br></br>")
       
       cString2 := Strtran(kTexto2 , "#", aLista[nContar,22])
       cString2 := Strtran(cString2, "&", "CNPJ/CPF: " + kCNPJCPF)
       cString2 := Strtran(cString2, CHR(13), "<br></br>")

       // #############################################
       // Elabora o texto a ser enviado ao FreshDesk ##
       // #############################################

       // ############################
       // Separa o e-mail principal ##
       // ############################
       cParaQuem := U_P_CORTA(Alltrim(aLista[nContar,19]) + ";", ";", 1)
       
       // ##################################
       // Separa os e-mails para em cópia ##
       // ##################################
       xEmail   := Alltrim(aLista[nContar,19]) + ";"
       cEmCopia := ""
                     
       For nEmCopia = 1 to U_P_OCCURS(xEmail, ";", 1)
           If nEmCopia == 1
              Loop
           Endif
           cEmCopia := cEmCopia + '"' + Alltrim(U_P_CORTA(xEmail,";",nEmCopia)) + '";'
       Next nEmCopia       

       If Empty(Alltrim(cEmCopia))
       Else
          cEmCopia := Substr(cEmCopia,01, Len(Alltrim(cEmCopia)) - 1)
       Endif                                                                     

       cString := ''
       cString += '{'
       cString += ' "email": "' + Alltrim(cParaQuem) + '", '
       cString += ' "source": 2,'
       cString += ' "status": 2,'
       cString += ' "priority": 1,'
       cString += ' "cc_emails": [' + cEmCopia + '],' 
      
       // ######################################
       // Inclui os dados do título em atraso ##
       // ######################################
       cDadosTitulo := ""
       cDadosTitulo := "Prefixo: "         + Alltrim(aLista[nContar,23]) + "<br>" + ;
                       "Nr.Titulo: "       + Alltrim(aLista[nContar,24]) + "<br>" + ;
                       "Parcela:   "       + Alltrim(aLista[nContar,25]) + "<br>" + ;
                       "Emissao: "         + Alltrim(aLista[nContar,26]) + "<br>" + ;
                       "Vencimento: "      + Alltrim(aLista[nContar,27]) + "<br>" + ;
                       "Dias Atraso: "     + Transform(aLista[nContar,28], "@E 99999") + "<br>" + ;
                       "Valor do Titulo: " + Transform(aLista[nContar,29], "@E 9999999.99")

      
       cString += ' "description": "' + cString1      + '<br><br>' + ;
                                       'DADOS DO TITULO: <br><br>' + ;
                                        cDadosTitulo  + '<br><br>' + ;
                                        cString2      + '",'
       cString += ' "email_config_id": 16000023371,'
       cString += ' "group_id": 16000079978,'
       cString += ' "type": "Info Cobrancas",'
       cString += ' "custom_fields": {'
       cString += '    "cnpj_ou_cpf": "' + Alltrim(kCNPJCPF0) + '"'
       cString += '  } '
       cString += '}'

       cString := strtran(strtran(cString, chr(13), ""), chr(10), "")

       // ########################################################################################
       // Elimina o arquivo de enviodemo.txt e retornodemo.txt antes de enviar nova solicitação ##
       // ########################################################################################
       If File("C:\FRESHDESK\ENVDEBITO.TXT")
          fErase("C:\FRESHDESK\ENVDEBITO.TXT")
       Endif

       If File("C:\FRESHDESK\RETDEBITO.TXT")
          fErase("C:\FRESHDESK\RETDEBITO.TXT")
       Endif   

      // ######################################################
      // Cria o arquivo de envio da solicitação ao FreshDesk ##
      // ######################################################
      nHdl := fCreate("C:\FRESHDESK\ENVDEBITO.TXT")
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      // ##########################################################################################################################################################
      // Exemplo de envio do comando                                                                                                                             ##
      // AtechHttpPost.exe https://automatech.freshdesk.com/api/v2/tickets C:\retorno.txt C:\envio.txt application/json "Basic c3BuaHc4cGxicnlsUlJSWVBPcE46eA==" ##
      // ##########################################################################################################################################################
      cSURL := "https://automatech.freshdesk.com/api/v2/tickets"

      WinExec('AtechHttpPost2.exe' + ' ' + Alltrim(cSURL) + ' ' + 'C:\FRESHDESK\RETDEBITO.TXT' + ' ' + 'C:\FRESHDESK\ENVDEBITO.TXT' + ' ' + 'application/json' + ' ' + '"Basic c3BuaHc4cGxicnlsUlJSWVBPcE46eA=="')
  
      // ###########################################################
      // Verifica se o arquivo de retorno foi criado no diretório ##
      // ###########################################################
      WHILE nTentativas < cSTIM
         If File("C:\FRESHDESK\RETDEBITO.TXT")
            lExiste := .T.
            Exit
         Endif
         nTentativas := nTentativas + 1
      Enddo
                                       
      If lExiste == .F.
         Return(.T.)
      Endif

      // ##########################################
      // Trata o retorno do envio da solicitação ##
      // ##########################################

      // #################################################################################
      // Abre o arquivo de retorno para capturar o código do ticket gerado no freshdesk ##
      // #################################################################################
      nHandle := FOPEN("C:\FRESHDESK\RETDEBITO.TXT", FO_READWRITE + FO_SHARED)
      
      If FERROR() != 0
         MsgAlert("Erro ao abrir o arquivo C:\FRESHDESK\RETDEBITO.TXT")
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
 
      FCLOSE(nHandle)

      If U_P_OCCURS(xBuffer, '"id":',1) == 0
         MsgAlert("Erro ao abrir o Tickt no FreshDesk."          + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Envie este erro ao Administrador do Sistema." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Erro: "                                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  Alltrim(xBuffer))

//         cTexto := ""
//         cTexto += "O pedido de DEMONSTRAÇÃO nº " + Alltrim(kPedido) + " - "        + ;
//                "Nota Fiscal nº " + Alltrim(kDocumento) + "/" + Alltrim(kSerie)  + ;
//                " não teve seu Tickt aberto por motivos de erro. <br><br>"       + ;
//                "Vendedor: " + Alltrim(cNomeVende) + "<br><br>"                  + ;  
//                "Seguem abaixo os dados: <br><br> "                              + ;
//                "Dados da remessa de Demonstração <br><br> "                     + ;
//                "Razão Social: " + Alltrim(nNomeCli) + "<br>"                    + ;
//                "CNPJ: " + Alltrim(cCnpj) + "<br>"                               + ;
//                "IE: " + Alltrim(cInscricao) + "<br>"                            + ;
//                "Endereco: " + Alltrim(cEndereco) + "<br>"                       + ;
//                "Bairro: " + Alltrim(cBairro) + "<br>"                           + ;
//                "Cidade: " + Alltrim(cCEP) + " - " + Alltrim(cCidade) + " / " + Alltrim(cEstado) + "<br><br> " + ;
//                "DESCRICAO DOS PRODUTOS: <br><br> "                              + ;
//                cProdutos

         Return(.T.)

      Else
           
     	  DbSelectArea("SE1")
	      DbSetOrder(1)   
	      If DbSeek(xFilial("SE1") + aLista[nContar,23] + aLista[nContar,24] + aLista[nContar,25] + aLista[nContar,31])

		     RecLock("SE1",.F.)
             
             Do Case

                Case Substr(cComboBx222,01,01) == "1"
    		         SE1->E1_CAR1 := "X"
    		         SE1->E1_DEN1 := Date()
    		      
                Case Substr(cComboBx222,01,01) == "2"
    		         SE1->E1_CAR2 := "X"
    		         SE1->E1_DEN2 := Date()

                Case Substr(cComboBx222,01,01) == "3"
    		         SE1->E1_CAR3 := "X"
    		         SE1->E1_DEN3 := Date()

             EndCase

      	     MsUnLock()
      	     
 		  EndIf
 	   
          // ##################################################
 		  // Cria um resgistro de atendimento no Call Center ##
 		  // ##################################################
 		  
          // ##############################
          // Abre registro na tabela SYP ##
          // ##############################
          
          // ##########################################
          // Pesquisa o próximo código para inclusão ##
          // ##########################################
          cPrxSyp := GetSXENum("SYP","SY_CHAVE")
          ConfirmSX8()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "001"
          SYP->YP_TEXTO := Dtoc(Date()) + " - " + Time() + "\13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "002"
          SYP->YP_TEXTO := "Envio de e-mail de Cobrança de Título em atraso \13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "003"
          SYP->YP_TEXTO := "Carta enviada: Carta " + ww_carta + "\13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "004"
          SYP->YP_TEXTO := "Período de Cobrança: " + cComboBx222 + "\13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "005"
          SYP->YP_TEXTO := "Título Cobrado: \13\10\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "006"
          SYP->YP_TEXTO := "Prefixo: " + aLista[nContar,06] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "007"
          SYP->YP_TEXTO := "Nº Título: " + aLista[nContar,07] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "008"
          SYP->YP_TEXTO := "Parcela: " + aLista[nContar,08] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "009"
          SYP->YP_TEXTO := "Emissão: " + aLista[nContar,09] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "010"
          SYP->YP_TEXTO := "Vencimento: " + aLista[nContar,10] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()

	      dbSelectArea("SYP")
		  RecLock("SYP",.T.)
          SYP->YP_CHAVE := cPrxSyp
          SYP->YP_SEQ   := "011"
          SYP->YP_TEXTO := "Valor Título: " + aLista[nContar,12] + "\13\10"
          SYP->YP_CAMPO := "ACF_CODOBS"
      	  MsUnlock()
 		  
          // ##############################
          // Abre regsitro na tabela ACF ##
          // ##############################

          // ##########################################
          // Pesquisa o próximo código para inclusão ##
          // ##########################################
          cPrxACF := GetSXENum("ACF","ACF_CODIGO")
          ConfirmSX8()

	      dbSelectArea("ACF")
		  RecLock("ACF",.T.)
 		  ACF->ACF_FILIAL := cFilAnt
 		  ACF->ACF_CODIGO := cPrxACF
 		  ACF->ACF_CLIENT := aLista[nContar,02]
 		  ACF->ACF_LOJA   := aLista[nContar,03]
 		  ACF->ACF_OPERAD := "000007"
 		  ACF->ACF_OPERA  := "1"
 		  ACF->ACF_STATUS := "2"
 		  ACF->ACF_DATA   := Date()
 		  ACF->ACF_CODOBS := cPrxSyp
 		  ACF->ACF_PENDEN := Date()
 		  ACF->ACF_HRPEND := Substr(Time(),01,05)
 		  ACF->ACF_INICIO := Time()
 		  ACF->ACF_FIM    := Time()
 		  ACF->ACF_DIASDA := 9992
 		  ACF->ACF_HORADA := 22668
 		  ACF->ACF_OPERAT := "000007"
 		  ACF->ACF_ULTATE := Date()
      	  MsUnlock() 		  

          // ##############################
          // Abre registro na tabela ACG ##
          // ##############################
	      dbSelectArea("ACG")
		  RecLock("ACG",.T.)
          ACG->ACG_FILIAL := cFilAnt
          ACG->ACG_CODIGO := cPrxACF
          ACG->ACG_PREFIX := aLista[nContar,06]
          ACG->ACG_TITULO := aLista[nContar,07]
          ACG->ACG_PARCEL := aLista[nContar,08]
          ACG->ACG_TIPO   := aLista[nContar,31]
          ACG->ACG_DTVENC := Ctod(aLista[nContar,10])
          ACG->ACG_DTREAL := Ctod(aLista[nContar,10])
          ACG->ACG_VALOR  := VAL(aLista[nContar,12])
          ACG->ACG_RECEBE := VAL(aLista[nContar,12])
          ACG->ACG_NATURE := aLista[nContar,32]
          ACG->ACG_NUMBCO := aLista[nContar,33]
          ACG->ACG_VALREF := VAL(aLista[nContar,12])
          ACG->ACG_STATUS := "2"
      	  MsUnlock() 		   		  

 	   Endif	  

   Next nContar

   MsgAlert("E-Mail(s) enviado(s) com sucesso!")

   // #########################################
   // Atualiza a tela após envio dos e-mails ##
   // #########################################
   TrazDados()
 
Return(.T.)
