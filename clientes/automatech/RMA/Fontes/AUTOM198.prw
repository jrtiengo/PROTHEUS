#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#include "MSGRAPHI.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM198.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/11/2013                                                          *
// Objetivo..: Programa que realiza controle - RMA - Return Merchandise Authorized *
//**********************************************************************************

User Function AUTOM198()

   Local cSql        := ""
   Local lVendedor   := .F.
   Local lChumba     := .F.
   Local nContar     := 0

   Private aNumSerie := {}

   Private cEmailLib := ""
   Private aVendedor := {}
   Private aStatus   := {"0 - Todos os Status", "1 - Abertura/Nova Aprovação", "2 - Aprovada", "3 - Cancelada por Vencimento", "8 - Revisão", "7 - Recusado", "6 - Aguardando Doc Retorno", "5 - Encerrado", "9 - Doc/Merc. Recebidos"}
   Private cComboBx1
   Private cComboBx2
   Private cInicial	 := Ctod("01/01/" + Strzero(Year(Date()),4))
   Private cFinal	 := Date()
   Private _cNumRMA  := Space(5)  
   Private cGet3	 := Space(25)
   Private cMemo1	 := ""
   Private cMemo2	 := ""
   Private cMemo3	 := ""
   Private cMemo4	 := ""   
   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4   
   Private _oNroRMA

   Private cGet3     := ""
   Private cGet4     := ""
   Private cGet5     := ""
   Private cGet6     := ""
   Private cGet7     := ""
   Private cGet8     := ""
   Private cGet9     := ""
   Private cGet10    := ""                  

   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10

   Private aBrowse   := {}

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

   Private oDlg

   // Verifica se usuário pode acessar esta tela. A regra é, somente vendedores
   If Select("T_ACESSO") > 0
      T_ACESSO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.A3_CODUSR,"
   cSql += "       A.A3_NOME  ,"
   cSql += "       A.A3_ARMA   "
   cSql += "  FROM " + RetSqlName("SA3") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.A3_CODUSR  = '" + Alltrim(__CUSERID) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSO", .T., .T. )
   
   If T_ACESSO->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você não tem permissão para acessar este programa." + chr(13) + Chr(10) + "Entre em contato com o Administrador do Sistema.")
      Return(.T.)
   Endif

   // Pesquisa a tabela de vendedores para popular o combo de vendedores
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT A.A3_COD   ,"
   cSql += "                A.A3_NOME  ," 
   cSql += "                A.A3_CODUSR "
   cSql += "  FROM " + RetSqlName("SA3") + " A  "
   cSql += " WHERE A.D_E_L_E_T_ = '' "  
   cSql += "   AND A.A3_RMA     = '1'"
   cSql += "   AND A.A3_COD <> ''    "

   If __Cuserid <> "000000"

      // Verifica se vendedor terá o combobox aberto
      DbSelectArea ("SA3")
      DbSetOrder(7)
      If DbSeek ( xFilial("SA3") + __CUSERID )
         If SA3->A3_ARMA == "2"
            cSql += " AND A.A3_CODUSR = '" + Alltrim(__CUSERID) + "'"
         Endif   
      Endif
      
   Endif

   cSql += " ORDER BY A.A3_NOME

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   // Verifica se vendedor terá o combobox aberto
   If __Cuserid == "000000"
      aAdd( aVendedor, "000000 - Selecione o Vendedor para Pesquisa" )      
   Else   
      DbSelectArea ("SA3")
      DbSetOrder(7)
      If DbSeek ( xFilial("SA3") + __CUSERID )
         If SA3->A3_ARMA == "1"
            aAdd( aVendedor, "000000 - Selecione o Vendedor para Pesquisa" )
         Endif
      Endif
   Endif

   // Carrega o combobox dos vendedores
   T_VENDEDOR->( DbGoTop() )
   WHILE !T_VENDEDOR->( EOF() )
      aAdd( aVendedor, T_VENDEDOR->A3_COD + " - " + Alltrim(T_VENDEDOR->A3_NOME) )
      T_VENDEDOR->( DbSkip() )
   ENDDO
   aAdd( aVendedor, Replicate("X",6) + " - " + "Todos" )

   If __Cuserid == "000000"
      lVendedor := .T.
   Else
      lVendedor := .F.
   Endif

   // Verifica se usuáio/Vendedor possui acesso a todos os vendedores
   If T_ACESSO->A3_ARMA == "1"
      lVendedor := .T.
   Endif
   
   // Além do Admin, o combo de vendedores também ficará aberto para os aprovadores de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_NRMA1, ZZ4_NRMA2, ZZ4_NRMA3, ZZ4_NRMA4, ZZ4_NRMA5, ZZ4_NRMA6, ZZ4_NRMA7, ZZ4_NRMA8, ZZ4_NRMA9, ZZ4_NRMA10,"
   cSql += "       ZZ4_ERMA1, ZZ4_ERMA2, ZZ4_ERMA3, ZZ4_ERMA4, ZZ4_ERMA5, ZZ4_EMAI6, ZZ4_EMAI7, ZZ4_EMAI8, ZZ4_EMAI9, ZZ4_EMAI10 " 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cEmailLib := ""

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA1)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_ERMA1 + ";"
      lVendedor := .T.
   Endif
      
   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA2)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_ERMA2 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA3)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_ERMA3 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA4)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_ERMA4 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA5)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_ERMA5 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA6)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_EMAI6 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA7)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_EMAI7 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA8)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_EMAI8 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA9)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_EMAI9 + ";"
      lVendedor := .T.
   Endif

   If UPPER(ALLTRIM(T_PARAMETROS->ZZ4_NRMA10)) == UPPER(ALLTRIM(cUserName))
      cEmailLib += T_PARAMETROS->ZZ4_EMAI10 + ";"
      lVendedor := .T.
   Endif

   PsqGridDados(1, Substr(aVendedor[1],1,6), "0")

   DEFINE MSDIALOG oDlg TITLE "RMA - Return Merchandise Authorization" FROM C(178),C(181) TO C(633),C(967) PIXEL

   @ C(003),C(005) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlg

   @ C(022),C(100)  Say "Nro RMA:" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(019),C(120) MsGet _oNroRMA Var _cNumRMA   /*F3 "ZS4"*/ Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(018),C(160) Button "Pesquisar"       Size C(036),C(012) PIXEL OF oDlg ACTION( BuscaRma(_cNumRMA) )
   @ C(022),C(288) Say "R M A - Return Merchandise Authorization" Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(035),C(003) Say "Data Inicial"                             Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(044) Say "Data Final"                               Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(083) Say "Vendedor"                                 Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(236) Say "Status"                                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(031),C(001) GET oMemo1 Var cMemo1 MEMO Size C(387),C(001) PIXEL OF oDlg
   @ C(057),C(001) GET oMemo2 Var cMemo2 MEMO Size C(387),C(001) PIXEL OF oDlg
   @ C(207),C(003) GET oMemo3 Var cMemo3 MEMO Size C(385),C(001) PIXEL OF oDlg
   @ C(191),C(003) GET oMemo4 Var cMemo4 MEMO Size C(385),C(001) PIXEL OF oDlg

   @ C(044),C(003) MsGet oGet1 Var cInicial Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(044) MsGet oGet2 Var cFinal   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(083) ComboBox cComboBx1 Items aVendedor When lVendedor Size C(146),C(010) PIXEL OF oDlg
   @ C(044),C(236) ComboBox cComboBx2 Items aStatus                  Size C(110),C(010) PIXEL OF oDlg

   @ C(041),C(352) Button "Atualizar"        Size C(036),C(012) PIXEL OF oDlg ACTION( PsqGridDados(0, Substr(cComboBx1,1,6), Substr(cComboBx2,1,1) ) )
   @ C(212),C(003) Button "Incluir"          Size C(037),C(012) PIXEL OF oDlg ACTION( AbreRMAMan("I", "", "", aBrowse[oBrowse:nAt,01], cComboBx1 ) )
   @ C(212),C(044) Button "Alterar"          Size C(037),C(012) PIXEL OF oDlg ACTION( AbreRMAMan("A", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,01], cComboBx1 ) )
   @ C(212),C(085) Button "Excluir"          Size C(037),C(012) PIXEL OF oDlg ACTION( AbreRMAMan("E", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,01], cComboBx1) )
   @ C(212),C(127) Button "Visualizar"       Size C(037),C(012) PIXEL OF oDlg ACTION( AbreRMAMan("V", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,01], cComboBx1) )
   @ C(212),C(165) Button "Rec.Doc./Mat."    Size C(047),C(012) PIXEL OF oDlg ACTION( SalvaRecDoc(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,09]) )
   @ C(212),C(214) Button "Impressão RMA"    Size C(045),C(012) PIXEL OF oDlg ACTION( MandaEmailCli(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], cComboBx1, aBrowse[oBrowse:nAt,01]) )
   @ C(212),C(261) Button "DANFE"            Size C(037),C(012) PIXEL OF oDlg ACTION( IMPDANFE(aBrowse[oBrowse:nAt,15]) )
   @ C(212),C(300) Button "Fluxo / Legenda"  Size C(047),C(012) PIXEL OF oDlg ACTION( AbreLegenda() )

   @ C(197),C(003) Jpeg FILE "br_amarelo"               Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(013) MsGet oGet3 Var cGet3   When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(197),C(051) Jpeg FILE "br_verde"                 Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(062) MsGet oGet4 Var cGet4   When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(197),C(099) Jpeg FILE "br_laranja"               Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(110) MsGet oGet5 Var cGet5   When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(197),C(148) Jpeg FILE "br_pink"                  Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(158) MsGet oGet6 Var cGet6   When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(197),C(196) Jpeg FILE "br_azul"                  Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(207) MsGet oGet7 Var cGet7   When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(197),C(245) Jpeg FILE "br_vermelho"              Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(255) MsGet oGet8 Var cGet8   When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(197),C(293) Jpeg FILE "br_preto"                 Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(304) MsGet oGet9 Var cGet9   When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(197),C(342) Jpeg FILE "br_cancel"                Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(195),C(353) MsGet oGet10 Var cGet10 When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(212),C(351) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 080 , 003, 495, 165,,{'Lg ', 'RMA', 'ANO', 'Data', 'Hora', 'Cliente', 'Loja', 'Descrição dos Clientes', 'Vendedor', 'Descrição dos Vendedores', 'Data Aprovação', 'Hora Aprovação', 'Aprovador'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,08]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,09]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,10]            ,;                                                                                                                                                      
                         aBrowse[oBrowse:nAt,11]            ,;                                                                                                                                                      
                         aBrowse[oBrowse:nAt,12]            ,;                                                                                                                                                      
                         aBrowse[oBrowse:nAt,13]           } }
	oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava a baixa da RMA
Static Function SalvaRecDoc( _Status, _RMA, _ANO, cVendedor)

   Local cSql        := ""
   Local lEaprovador := .F.
   Local cDocumento  := Date()
   Local cHoraDoc    := Time()
   
   Private oDlgB
   
   If _Status <> "6"
      MsgAlert("Somente permitido informar recebimento de Documento / Mercadoria no Status Laranja")
      Return(.T.)
   Endif

   // Somente permite informação de recebimento de documento / mercadoria para os liberadores de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_NRMA1 ,"
   cSql += "       ZZ4_NRMA2 ,"
   cSql += "       ZZ4_NRMA3 ,"
   cSql += "       ZZ4_NRMA4 ,"
   cSql += "       ZZ4_NRMA5 ,"
   cSql += "       ZZ4_NRMA6 ,"
   cSql += "       ZZ4_NRMA7 ,"
   cSql += "       ZZ4_NRMA8 ,"
   cSql += "       ZZ4_NRMA9 ,"
   cSql += "       ZZ4_NRMA10,"            
   cSql += "       ZZ4_VRMA   "
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return(.T.)
   Endif
   
   If Alltrim(T_PARAMETROS->ZZ4_NRMA1)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA2)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA3)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA4)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA5)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA6)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA7)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA8)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA9)  + ;
      Alltrim(T_PARAMETROS->ZZ4_NRMA10) == ""
      MsgAlert("Operação somente permitida para Liberadores de RMA.")
      Return(.T.)
   Endif

   lEaprovador := .F.

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA1)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif
   
   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA2)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA3)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA4)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA5)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA6)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA7)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA8)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA9)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA10)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If lEaprovador == .F.       
      MsgAlert("Operação somente permitida para Liberadores de RMA.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgB TITLE "Recebimento de Doc./Mercadoria" FROM C(178),C(181) TO C(281),C(361) PIXEL

   @ C(005),C(005) Say "Data do Recebimento"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgB
   @ C(005),C(050) Say "Hora do Recebimento"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgB

   @ C(015),C(005) MsGet oGet1 Var cDocumento Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgB
   @ C(015),C(050) MsGet oGet2 Var cHoraDoc   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgB

   @ C(033),C(006) Button "Confirma" Size C(4037),C(012) PIXEL OF oDlgB ACTION( GravaRecDoc(_RMA, _ANO, cDocumento, cHoraDoc, cVendedor) )
   @ C(033),C(044) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgB ACTION( oDlgB:End() )
 
   ACTIVATE MSDIALOG oDlgB CENTERED 

Return(.T.)

// Função que grava o recebimento do documento e da mercadoria
Static Function GravaRecDoc( _RMA, _ANO, _DataRec, _HoraRec, cVendedor)

   Local _nErro := 0
   Local _nErro := 0
   Local cSql   := ""
   Local cTexto := ""

   If Empty(_DataRec)
      MsgAlert("Data de recebimento do documento/material não informada.")
      Return(.T.)
   Endif
      
   If Empty(_HoraRec)
      MsgAlert("Hora de recebimento do documento/material não informada.")
      Return(.T.)
   Endif

   If _DataRec > Date()
      MsgAlert("Data não pode ser maior que a data atual.")
      Return(.T.)
   Endif

   // Atualiza os dados de recebimento do Documento/Material
   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZS4")
   cSql += "   SET "
   cSql += "   ZS4_STAT = '" + Alltrim("9")       + "',"
   cSql += "   ZS4_DDOC = '" + Strzero(year(_DataRec),4) + Strzero(month(_DataRec),2) + Strzero(day(_DataRec),2) + "', "
   cSql += "   ZS4_HDOC = '" + Alltrim(_HoraRec)  + "',"
   cSql += "   ZS4_UDOC = '" + Alltrim(__cUserID) + "'"
   cSql += " WHERE ZS4_NRMA = '" + Alltrim(_RMA)  + "'"
   cSql += "   AND ZS4_ANO  = '" + Alltrim(_ANO)  + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   // Pesquisa o -mail do vendedor para envio de email de aviso de recebimento de documento/mercadoria
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT A.A3_COD  ,"
   cSql += "                A.A3_EMAIL " 
   cSql += "  FROM " + RetSqlName("SA3") + " A  "
   cSql += " WHERE A.D_E_L_E_T_ = '' "  
   cSql += "   AND A.A3_RMA     = '1'"
   cSql += "   AND A.A3_COD     = '" + Substr(cVendedor,01,06) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   // Envia e-mail ao veendedor informando que foi recebido o documento / mercadoria
   IF !Empty(Alltrim(T_VENDEDOR->A3_EMAIL))

      cTexto := ""
      cTexto := "Prezado(a) Vendedor(a)" + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Informados que foi recebido no dia " + Dtoc(_DataRec) + " as " + _HoraRec + " o documento/mercadoria(s)" + chr(13) + chr(10)
      cTexto += "referente a sua RMA " + Alltrim(_RMA) + "/" + Alltrim(_ANO) + chr(13) + chr(10)
      cTexto += "Aguarde informativo de baixa da sua RMA."

      U_AUTOMR20(cTexto, Alltrim(T_VENDEDOR->A3_EMAIL), "", "Aviso de Recebimento de Documento/Mercadoria de RMA" )   
      
   Endif
       
   oDlgB:End()

   // Atualiza o Grid
   PsqGridDados(0, Substr(cVendedor,01,06), "0")

Return(.T.)

// Função que pesquisa os dados para carregar o grid
Static Function PsqGridDados(_Tipo, _Vendedor, _Status)

   Local cSql      := ""
   Local nContar   := 0
   Local lJaExiste := .F.

   Local xGet3  := 0
   Local xGet4  := 0
   Local xGet5  := 0
   Local xGet6  := 0
   Local xGet7  := 0
   Local xGet8  := 0
   Local xGet9  := 0
   Local xGet10 := 0               

   aBrowse    := {}

   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

// cSql := "SELECT DISTINCT   "

   cSql := ""
   cSql += "SELECT A.ZS4_NRMA,"
   cSql += "       A.ZS4_ANO ,"
   cSql += "       A.ZS4_STAT,"
   cSql += "       A.ZS4_ABER,"
   cSql += "       A.ZS4_HORA,"
   cSql += "       A.ZS4_CLIE,"
   cSql += "       A.ZS4_LOJA,"
   cSql += "       B.A1_NOME ,"
   cSql += "       A.ZS4_VEND,"
   cSql += "       C.A3_NOME ,"
   cSql += "       A.ZS4_DLIB,"
   cSql += "       A.ZS4_HLIB,"
   cSql += "       A.ZS4_APRO,"
   cSql += "       A.ZS4_NFIL "   
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C  "
   cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND A.ZS4_ABER  >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)" 
   cSql += "   AND A.ZS4_ABER  <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"
   cSql += "   AND A.ZS4_CHEK   = '1'"
   If Alltrim(_Vendedor) <> "000000"
	   cSql += "   AND A.ZS4_VEND   = '" + Alltrim(_Vendedor) + "'"
   EndIf
   // Pesquisa dados do vendedor selecionado
//   If _Tipo == 1
//   Else   
//      cSql += "   AND A.ZS4_VEND   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
//   Endif

   // Status
   If _Status == "0"
   Else
      cSql += "  AND A.ZS4_STAT = '" + Alltrim(_Status) + "'"   
   Endif

   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      aAdd( aBrowse, { "0", "","","","","","","","","","","","","","" })
   Else
   
      T_DADOS->( DbGoTop() )
      
      WHILE !T_DADOS->( EOF() )
      
         // Verifica se o RMA/ANO já está incluído no array aBrowse
         lJaExiste := .F.
         For nContar = 1 to Len(aBrowse)
             If T_DADOS->ZS4_NRMA == aBrowse[nContar,02] .And. T_DADOS->ZS4_ANO == aBrowse[nContar,03]
                lJaExiste := .T.                
                Exit
             Endif
         Next nContar
         
         If lJaExiste == .T.
            T_DADOS->( DbSkip() )                                    
            Loop
         Endif

         aAdd( aBrowse, { T_DADOS->ZS4_STAT,;
                          T_DADOS->ZS4_NRMA,;
                          T_DADOS->ZS4_ANO ,;
                          Substr(T_DADOS->ZS4_ABER,07,02) + "/" + Substr(T_DADOS->ZS4_ABER,05,02) + "/" + Substr(T_DADOS->ZS4_ABER,01,04) ,;
                          T_DADOS->ZS4_HORA,;
                          T_DADOS->ZS4_CLIE,;
                          T_DADOS->ZS4_LOJA,;
                          T_DADOS->A1_NOME ,;
                          T_DADOS->ZS4_VEND,;
                          T_DADOS->A3_NOME ,;
                          T_DADOS->ZS4_DLIB,;
                          T_DADOS->ZS4_HLIB,;
                          T_DADOS->ZS4_APRO,;
                          T_DADOS->ZS4_NFIL}) 

         T_DADOS->( DbSkip() )                 
      ENDDO
   Endif

   // Atualiza as estatísticas da tela
   cGet3 := ""
   cGet4 := ""
   cGet5 := ""
   cGet6 := ""
   cGet7 := ""
   cGet8 := ""
   cGet9 := ""
   cGet10 := ""
   
   If _Tipo == 1
   Else
      oGet3:Refresh()               
      oGet4:Refresh()               
      oGet5:Refresh()               
      oGet6:Refresh()               
      oGet7:Refresh()               
      oGet8:Refresh()               
      oGet9:Refresh()                              
      oGet10:Refresh()               
   Endif    

   For nContar = 1 to Len(aBrowse)

       Do Case
          Case aBrowse[nContar,01] == "2"
               xGet4 := xGet4 + 1
          Case aBrowse[nContar,01] == "3"
               xGet10 := xGet10 + 1
          Case aBrowse[nContar,01] == "1"
               xGet3 := xGet3 + 1
          Case aBrowse[nContar,01] == "5"
               xGet7 := xGet7 + 1
          Case aBrowse[nContar,01] == "6"
               xGet5 := xGet5 + 1
          Case aBrowse[nContar,01] == "7"
               xGet9 := xGet9 + 1
          Case aBrowse[nContar,01] == "8"
               xGet8 := xGet8 + 1
          Case aBrowse[nContar,01] == "9"
               xGet6 := xGet6 + 1
          Case aBrowse[nContar,01] == "4"
               xGet10 := xGet10 + 1          
       EndCase   

   Next nContar

   cGet3  := str(xGet3,5)
   cGet4  := str(xGet4,5)
   cGet5  := str(xGet5,5)
   cGet6  := str(xGet6,5)
   cGet7  := str(xGet7,5)
   cGet8  := str(xGet8,5)
   cGet9  := str(xGet9,5)
   cGet10 := str(xGet10,5)

   If _Tipo == 1
   Else
      oGet3:Refresh()               
      oGet4:Refresh()               
      oGet5:Refresh()               
      oGet6:Refresh()               
      oGet7:Refresh()               
      oGet8:Refresh()               
      oGet9:Refresh()                              
      oGet10:Refresh()               
   Endif   

   If _Tipo == 1
      Return(.T.)
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,08]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,09]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,10]            ,;                                                                                                                                                      
                         aBrowse[oBrowse:nAt,11]            ,;                                                                                                                                                      
                         aBrowse[oBrowse:nAt,12]            ,;                                                                                                                                                      
                         aBrowse[oBrowse:nAt,13]           } }

Return(.T.)

// Desenha a tela de Fluxo e Legenda
Static Function AbreLegenda()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo6	 := ""
   Local cMemo7	 := ""
   Local cMemo8	 := ""
   Local cMemo9	 := ""
   Local cMemo10 := ""
   Local cMemo11 := ""
   Local cMemo12 := ""
   Local cMemo13 := ""
   Local cMemo14 := ""
   Local cMemo15 := ""
   Local cMemo16 := ""
   Local cMemo17 := ""
   Local cMemo18 := ""
   Local cMemo19 := ""
   Local cMemo20 := ""
   Local cMemo21 := "RMA encerrada automaticamente pelo processo de encerramento de RMA com prazo de validade vencida."
   Local cMemo22 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo6
   Local oMemo7
   Local oMemo8
   Local oMemo9
   Local oMemo10
   Local oMemo11
   Local oMemo12
   Local oMemo13
   Local oMemo14
   Local oMemo15
   Local oMemo16
   Local oMemo17
   Local oMemo18
   Local oMemo19
   Local oMemo20
   Local oMemo21
   Local oMemo22
      
   Private oDlgL

   DEFINE MSDIALOG oDlgL TITLE "Status da RMA" FROM C(178),C(181) TO C(608),C(921) PIXEL

   @ C(008),C(079) Button "Abertura/Nova Aprovação"                      Size C(072),C(012) PIXEL OF oDlgL
   @ C(042),C(096) Button "Liberação"                                    Size C(037),C(012) PIXEL OF oDlgL
   @ C(085),C(047) Button "Não Aprovado"                                 Size C(045),C(012) PIXEL OF oDlgL
   @ C(085),C(171) Button "Aprovado"                                     Size C(045),C(012) PIXEL OF oDlgL
   @ C(108),C(136) Button "Envia e-mail ao Cliente informando nº da RMA" Size C(115),C(012) PIXEL OF oDlgL
   @ C(124),C(021) Button "Revisão"                                      Size C(037),C(012) PIXEL OF oDlgL
   @ C(124),C(080) Button "Recusado"                                     Size C(037),C(012) PIXEL OF oDlgL
   @ C(132),C(162) Button "Recebimento Mat/NF"                           Size C(061),C(012) PIXEL OF oDlgL
   @ C(152),C(080) Button "Encerra"                                      Size C(037),C(012) PIXEL OF oDlgL
   @ C(153),C(146) Button "Lançamento do Documento"                      Size C(093),C(012) PIXEL OF oDlgL
   @ C(173),C(171) Button "Final Processo"                               Size C(045),C(012) PIXEL OF oDlgL
   @ C(200),C(023) Say "RMA's encerradas pelo processo de controle do financeiro" Size C(141),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(014),C(009) GET oMemo12 Var cMemo12 MEMO Size C(001),C(137) PIXEL OF oDlgL
   @ C(014),C(009) GET oMemo13 Var cMemo13 MEMO Size C(068),C(001) PIXEL OF oDlgL
   @ C(021),C(114) GET oMemo1  Var cMemo1  MEMO Size C(001),C(019) PIXEL OF oDlgL
   @ C(055),C(114) GET oMemo2  Var cMemo2  MEMO Size C(001),C(012) PIXEL OF oDlgL
   @ C(068),C(069) GET oMemo3  Var cMemo3  MEMO Size C(124),C(001) PIXEL OF oDlgL
   @ C(068),C(069) GET oMemo4  Var cMemo4  MEMO Size C(001),C(016) PIXEL OF oDlgL
   @ C(068),C(193) GET oMemo5  Var cMemo5  MEMO Size C(001),C(016) PIXEL OF oDlgL
   @ C(098),C(069) GET oMemo6  Var cMemo6  MEMO Size C(001),C(013) PIXEL OF oDlgL
   @ C(098),C(193) GET oMemo15 Var cMemo15 MEMO Size C(001),C(009) PIXEL OF oDlgL
   @ C(112),C(040) GET oMemo7  Var cMemo7  MEMO Size C(059),C(001) PIXEL OF oDlgL
   @ C(112),C(040) GET oMemo8  Var cMemo8  MEMO Size C(001),C(011) PIXEL OF oDlgL
   @ C(112),C(098) GET oMemo9  Var cMemo9  MEMO Size C(001),C(011) PIXEL OF oDlgL
   @ C(120),C(193) GET oMemo16 Var cMemo16 MEMO Size C(001),C(011) PIXEL OF oDlgL
   @ C(126),C(193) GET oMemo19 Var cMemo19 MEMO Size C(107),C(001) PIXEL OF oDlgL
   @ C(126),C(300) GET oMemo20 Var cMemo20 MEMO Size C(001),C(022) PIXEL OF oDlgL
   @ C(137),C(040) GET oMemo10 Var cMemo10 MEMO Size C(001),C(013) PIXEL OF oDlgL
   @ C(137),C(098) GET oMemo14 Var cMemo14 MEMO Size C(001),C(014) PIXEL OF oDlgL
   @ C(144),C(193) GET oMemo22 Var cMemo22 MEMO Size C(001),C(008) PIXEL OF oDlgL
   @ C(149),C(254) GET oMemo21 Var cMemo21 MEMO Size C(092),C(031) PIXEL OF oDlgL
   @ C(150),C(009) GET oMemo11 Var cMemo11 MEMO Size C(031),C(001) PIXEL OF oDlgL
   @ C(165),C(193) GET oMemo17 Var cMemo17 MEMO Size C(001),C(007) PIXEL OF oDlgL
   @ C(191),C(009) GET oMemo18 Var cMemo18 MEMO Size C(354),C(001) PIXEL OF oDlgL

   @ C(010),C(155) Jpeg FILE "br_amarelo"  Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(087),C(218) Jpeg FILE "br_verde"    Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(109),C(255) Jpeg FILE "br_laranja"  Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(126),C(061) Jpeg FILE "br_vermelho" Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(126),C(121) Jpeg FILE "br_preto"    Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(133),C(226) Jpeg FILE "br_pink"     Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(175),C(218) Jpeg FILE "br_azul"     Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(198),C(010) Jpeg FILE "br_marrom"   Size C(009),C(009) PIXEL NOBORDER OF oDlgL
   @ C(149),C(349) Jpeg FILE "br_cancel"   Size C(008),C(008) PIXEL NOBORDER OF oDlgL
                                                                                    
   @ C(198),C(326) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// Abre tela de manutenção da RMA
Static Function AbreRMAMan(_Tipo, _RMA, _ANO, _STATUS, _Vendedor)

   Local lChumba     := .F.
   Local lVendInclui := .F.
   Local nContar     := 0
   Local lAbre       := .F.
   Local lAprova     := .F.
   Local lContato    := .T.
   Local cTitulo     := ""

   Private lDados    := .F.
   Private aComboBx1 := U_AUTOM539(2, cEmpAnt) // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private aComboBx2 := {"01 - Encontro com NF. Original", "02 - Encontro com NF. Nova", "03 - Encontro com outra NF. (Especificar)", "04 - Cliente ficou com crédito", "05 - Cliente vai receber em espécie (Somente se for devolvido até 7 dias ou com autuorização)"}
   Private aSituacao := {}
   Private aProvador := {}
   Private aMotivo   := {}
   Private aMotivoA  := {}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx4
   Private cComboBx5   
   Private cComboBx6   
   Private cComboBx7   

   Private cDataP        := Ctod("  /  /    ")
   Private cHoraP        := ""

   Private cNRMA	     := Space(05)
   Private cARMA	     := Space(04)
   Private cAbertura     := Ctod("  /  /    ")
   Private cHora	     := Space(10)
   Private cVendedor     := Space(25)
   Private cCliente      := Space(06)
   Private cLoja	     := Space(03)
   Private cNota	     := Space(06)
   Private cSerie	     := Space(03)
   Private xFilial       := Space(02)
   Private nFilial	     := Space(30)
   Private yFilial	     := Space(02)
   Private yNota	     := Space(06)
   Private ySerie	     := Space(03)
   Private yTipo         := 0
   Private yTipoRMA      := Space(06)
   Private cConsideracao := ""

   Private cDCliente := Space(100)
   Private cTelefone := Space(20)
   Private cEmailCli := Space(100)
   Private cContato  := Space(06)
   Private cNomeCon  := Space(40)

   Private cDCliente := ""
   Private cMemo2	 := ""
   Private cMemo3	 := ""
   Private cMemo5	 := ""
   Private cMemo6	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11   
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15    
   Private oGet16    
   Private oGet17    
   Private oGet18    
   Private oGet19       
   Private oGet20       
   Private oGet21          

   Private oMemo2
   Private oMemo3
   Private oMemo4
   Private oMemo5
   Private oMemo6

   Private oDlgX

   Private aProdutos := {}
   Private oProdutos

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private nTroca    := 0
   Private nCodTroca := Space(06)
   Private aTipoRma  := {}
   Private cHelpRma  := "" 
   Private oHelpRma
   Private kUsuario  := ""
   Private kDataInc  := Ctod("  /  /    ")
   Private kHoraInc  := ""

   Private aVendInclui := {}
   Private cVendInclui 
   
   // Carrega o ComboBox de Motivos da RMA
   If Select("T_MOTIVO") > 0
      T_MOTIVO->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZS6_CODI, "
   cSql += "       ZS6_DESC  "
   cSql += "  FROM " + RetSqlName("ZS6")
   cSql += " WHERE ZS6_DELE = ''"

   If UPPER(Alltrim(Substr(_Vendedor,10))) == "LOGISTICA" 
      cSql += " AND ZS6_DESC = 'ERRO LOGISTICA'"
   Endif   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

   If T_MOTIVO->( EOF() )
      MsgAlert("Atenção! Cadastro de Motivos de RMA está vazio. Cadastre primeiramente os motivos antes de continuar o cadastramento da RMA.")
      Return(.T.)
   Endif

   aAdd( aMotivo, "000000 - Selecione o Motivo da RMA" )
   
   T_MOTIVO->( DbGoTop() )
   WHILE !T_MOTIVO->( EOF() )
      aAdd(aMotivo,  T_MOTIVO->ZS6_CODI + " - " + T_MOTIVO->ZS6_DESC )   
      T_MOTIVO->( DbSkip() )
   ENDDO

   // Carrega o ComboBox de Motivos de Aprovação/Reprovação/Revisão
   If Select("T_MOTIVO") > 0
      T_MOTIVO->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZS7_CODI, "
   cSql += "       ZS7_DESC  "
   cSql += "  FROM " + RetSqlName("ZS7")
   cSql += " WHERE ZS7_DELE = ''"
   cSql += " ORDER BY ZS7_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

   If T_MOTIVO->( EOF() )
      MsgAlert("Atenção! Cadastro de Motivos de Aprovação/Reprovação/Revisão de RMA está vazio. Cadastre primeiramente os motivos antes de continuar o cadastramento da RMA.")
      Return(.T.)
   Endif

   aAdd( aMotivoA, "000000 - Selecione o Motivo" )
   
   T_MOTIVO->( DbGoTop() )
   WHILE !T_MOTIVO->( EOF() )
      aAdd(aMotivoA,  T_MOTIVO->ZS7_CODI + " - " + T_MOTIVO->ZS7_DESC )   
      T_MOTIVO->( DbSkip() )
   ENDDO

   If _Tipo == "I"

      // Pesquisa o Titulo do tipo de RMA que está sendo incluída
      If Select("T_TIPORMA") > 0
         T_TIPORMA->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZS8_CODI,"
      cSql += "       ZS8_DESC,"
      cSql += "       ZS8_TIPO,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZS8_HELP)) AS OBSERVACAO"
      cSql += "  FROM " + RetSqlName("ZS8")
      cSql += " WHERE ZS8_DELE = ''"
      cSql += " ORDER BY ZS8_DESC"  

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPORMA", .T., .T. )

      If T_TIPORMA->( EOF() )
         MsgAlert("Atenção! Inclusão não permitida. O Cadastro de Tipos de RMA está vazio. Entre em contato com o Administrador do Sistema.")
         Return(.T.)
      Endif

      cTitulo := T_TIPORMA->ZS8_DESC

      WHILE !T_TIPORMA->( EOF() )
         aAdd( aTipoRma, { T_TIPORMA->ZS8_CODI,;
                           T_TIPORMA->ZS8_DESC,;
                           T_TIPORMA->ZS8_TIPO,;
                           T_TIPORMA->OBSERVACAO})
         T_TIPORMA->( DbSkip() )
      ENDDO

      MSTHELPRMA( aTipoRma[01,04], 1 )  

      // Carrega o combobox de vendedores na inclusão de RMA
      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DISTINCT A.A3_COD ,"
      cSql += "                A.A3_NOME " 
      cSql += "  FROM " + RetSqlName("SA3") + " A  "
      cSql += " WHERE A.D_E_L_E_T_ = '' "  
      cSql += "   AND A.A3_RMA     = '1'"
      cSql += "   AND A.A3_COD <> ''    "

      If __Cuserid <> "000000"

         // Verifica se vendedor terá o combobox aberto
         DbSelectArea ("SA3")
         DbSetOrder(7)
         If DbSeek ( xFilial("SA3") + __CUSERID )
            If SA3->A3_ARMA == "2"
               cSql += " AND A.A3_CODUSR = '" + Alltrim(__CUSERID) + "'"
            Endif   
         Endif   

      Endif

      cSql += " ORDER BY A.A3_NOME

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

      // Verifica se vendedor terá o combobox aberto
      If __Cuserid == "000000"
         aAdd( aVendInclui, "000000 - Selecione o Vendedor para Pesquisa" )      
      Else   
         DbSelectArea ("SA3")
         DbSetOrder(7)
         If DbSeek ( xFilial("SA3") + __CUSERID )
            If SA3->A3_ARMA == "1"
               aAdd( aVendInclui, "000000 - Selecione o Vendedor para Pesquisa" )
            Endif
         Endif
      Endif   

      T_VENDEDOR->( DbGoTop() )
      WHILE !T_VENDEDOR->( EOF() )
         aAdd( aVendInclui, T_VENDEDOR->A3_COD + " - " + Alltrim(T_VENDEDOR->A3_NOME) )
         T_VENDEDOR->( DbSkip() )
      ENDDO

      If __Cuserid == "000000"
         lVendInclui := .T.
      Else
         lVendInclui := .F.
      Endif

      // Verifica se usuáio/Vendedor possui acesso a todos os vendedores
      If T_ACESSO->A3_ARMA == "1"
         lVendInclui := .T.
      Endif

      kUsuario := __Cuserid + " - " + Alltrim(cUserName)
      kDataInc := Date()
      kHoraInc := Time()

      DEFINE MSDIALOG oDlgT TITLE "Tipo de Inclusão de RMA" FROM C(178),C(181) TO C(578),C(627) PIXEL

      @ C(005),C(005) Say "RMA do Vendedor"                                                                 Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
      @ C(023),C(005) Say "Informe o tipo de RMA que será incluída"                                         Size C(098),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
      @ C(097),C(005) Say "Help do tipo de RMA selecionado (Duplo click sobre o tipo para visualizar Help)" Size C(190),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
      @ C(158),C(005) Say "RMA incluída por"                                                                Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
      @ C(158),C(124) Say "Data"                                                                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
      @ C(158),C(172) Say "Hora"                                                                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

      @ C(014),C(005) ComboBox cVendInclui Items aVendInclui   When lVendInclui Size C(215),C(010) PIXEL OF oDlgT
      @ C(106),C(005) GET      oHelpRma    Var   cHelpRma MEMO When lChumba     Size C(211),C(048) PIXEL OF oDlgT
      @ C(168),C(005) MsGet    oGet1       Var   kUsuario      When lChumba     Size C(115),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
      @ C(168),C(124) MsGet    oGet2       Var   kDataInc      When lChumba     Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
      @ C(168),C(172) MsGet    oGet3       Var   kHoraInc      When lChumba     Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
      @ C(183),C(091) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgT ACTION( nCodTroca := aTipoRma[oTipoRma:nAt,01], oDlgT:End() )

      oTipoRma := TCBrowse():New( 040 , 005, 275, 080,,{'Código', 'Descrição Tipos RMA'},{20,50,50,50},oDlgT,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

      // Seta vetor para a browse                            
      oTipoRma:SetArray(aTipoRma) 
    
      // Monta o grid com os tipos de RMA
      oTipoRma:bLine := {||{ aTipoRma[oTipoRma:nAt,01], aTipoRma[oTipoRma:nAt,02]} }

      oTipoRma:bLDblClick := {|| MSTHELPRMA(aTipoRma[oTipoRma:nAt,04],2) } 

      ACTIVATE MSDIALOG oDlgT CENTERED 

      // Carrega o Tipo de RMA a ser incluída
      DbSelectArea ("ZS8")
      DbSetOrder(1)
      If DbSeek ( xFilial("ZS8") + nCodTroca )
         yTipo   := INT(VAL(ZS8_TIPO))
         cTitulo := Alltrim(ZS8_DESC)
      Else
         yTipo   := 0         
         cTitulo := ""
      Endif
            
      yTipoRma := nCodTroca

      // Verifica se o vendedor da RMA doi selecionado. Se não foi, retorna
      If Substr(cVendInclui,01,06) == "000000"
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não foi selecionado o vendedor para a RMA." + chr(13) + chr(10) + "Processo cancelado.")
         Return(.T.)
      Endif

   Else

      If _Status == "2"
         If _Tipo == "V"
         Else
            If _Tipo == "A"
               MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA já foi aprovada. Alteração não permitida." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
               Return(.T.)
            Endif
         Endif
      Endif

      If _Status == "3"
         If _Tipo == "V"
         Else
            If _Tipo == "A" .OR. _Tipo == "E"
               If _Tipo == "A"
                  MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA encerrada por data de validade expirada. Alteração não permitida." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
               Else
                  MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA encerrada por data de validade expirada. Exclusão não permitida." + chr(13) + chr(10) + "Utilize a opção Visualizar.")                  
               Endif
               Return(.T.)
            Endif
         Endif
      Endif

      If _Status == "7"
         If _Tipo == "V"
         Else
            MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA não pode ser alterada/excluída pois a mesma foi Recusada." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
            Return(.T.)
         Endif
      Endif

//      If _Status == "6"
//         If _Tipo == "V"
//         Else
//            MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA não pode ser alterada/excluída pois a mesma já foi informada ao Cliente e está aguardando o Documento de Entrada." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
//            Return(.T.)
//         Endif
//      Endif

      If _Status == "5"
         If _Tipo == "V"
         Else
            MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA não pode ser alterada/excluída pois já está encerrada." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
            Return(.T.)
         Endif
      Endif

   Endif

   If _Tipo == "I"
      lAbre     := .T.
      lContato  := .T.
      
      cNRMA	    := Space(05)
      cARMA	    := Space(04)
      cAbertura := date()
      cHora	    := time()
      cVendedor := cVendInclui   && _Vendedor
      cCliente  := Space(06)
      cLoja	    := Space(03)
      cNota	    := Space(06)
      cSerie	:= Space(03)
      cDCliente := Space(100)
      cTelefone := Space(20)
      cEmailCli := Space(100)
      cContato  := Space(06)
      cNomeCon  := Space(40)
      yFilial	:= Space(02)
      yNota	    := Space(06)
      ySerie	:= Space(03)
      aAdd( aSituacao, "1 - Abertura" )
   Endif

   // Alteração
   If _Tipo == "A" .Or. _Tipo == "E" .Or. _Tipo == "V"

      Do Case
         Case _Tipo == "E"
              lAbre    := .F.
              lcontato := .F.
         Case _Tipo == "V"
              lAbre    := .F.
              lContato := .F.
         Case _Tipo == "A"
              lContato := .T.
              lAbre    := .F.
      EndCase

      If Select("T_DADOS") > 0
         T_DADOS->( dbCloseArea() )
      EndIf
  
      cSql := ""
      cSql += "SELECT A.ZS4_NRMA,"
      cSql += "       A.ZS4_ANO ,"
      cSql += "       A.ZS4_STAT,"
      cSql += "       A.ZS4_ABER,"
      cSql += "       A.ZS4_HORA,"
      cSql += "       A.ZS4_CLIE,"
      cSql += "       A.ZS4_LOJA,"
      cSql += "       A.ZS4_TELE,"
      cSql += "       A.ZS4_EMAI,"
      cSql += "       A.ZS4_NFIL,"
      cSql += "       A.ZS4_NOTA,"
      cSql += "       A.ZS4_SERI,"
      cSql += "       A.ZS4_CRED,"
      cSql += "       A.ZS4_CREF,"
      cSql += "       A.ZS4_CREN,"
      cSql += "       A.ZS4_CRES,"
      cSql += "       B.A1_NOME ,"
      cSql += "       A.ZS4_VEND,"
      cSql += "       C.A3_NOME ,"
      cSql += "       C.A3_EMAIL,"
      cSql += "       A.ZS4_DLIB,"
      cSql += "       A.ZS4_HLIB,"
      cSql += "       A.ZS4_APRO,"
      cSql += "       A.ZS4_CONT,"
      cSql += "       A.ZS4_CHEK,"
      cSql += "       A.ZS4_ITEM,"
      cSql += "       A.ZS4_PROD,"
      cSql += "       A.ZS4_QUAN,"
      cSql += "       A.ZS4_UNIT,"
      cSql += "       A.ZS4_TOTA,"
      cSql += "       A.ZS4_CMOT,"
      cSql += "       A.ZS4_CMTA,"
      cSql += "       A.ZS4_TIPO,"
      cSql += "       A.ZS4_CTIP,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_MOTI)) AS MOTIVO,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_RECA)) AS RECADO,"
      cSql += "       D.U5_CONTAT,"
      cSql += "       E.B1_DESC  ,"
      cSql += "       E.B1_DAUX  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)) AS SERIES, "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_CONS)) AS OBSERVACAO "
      cSql += "  FROM " + RetSqlName("ZS4") + " A, "
      cSql += "       " + RetSqlName("SA1") + " B, "
      cSql += "       " + RetSqlName("SA3") + " C, "
      cSql += "       " + RetSqlName("SU5") + " D, "
      cSql += "       " + RetSqlName("SB1") + " E  "
      cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
      cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
      cSql += "   AND A.ZS4_NRMA   = '" + Alltrim(_RMA) + "'"
      cSql += "   AND A.ZS4_ANO    = '" + Alltrim(_ANO) + "'"
      cSql += "   AND B.D_E_L_E_T_ = ''       "
      cSql += "   AND A.ZS4_VEND   = C.A3_COD "
      cSql += "   AND C.D_E_L_E_T_ = ''       "
      cSql += "   AND A.ZS4_CONT   = D.U5_CODCONT"
      cSql += "   AND D.D_E_L_E_T_ = ''       "
      cSql += "   AND A.ZS4_PROD   = E.B1_COD "
      cSql += "   AND E.D_E_L_E_T_ = ''       "
      cSql += " ORDER BY A.ZS4_ITEM"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

      cNRMA	     := _RMA
      cARMA	     := _ANO
      cAbertura  := Ctod(Substr(T_DADOS->ZS4_ABER,07,02) + '/' + Substr(T_DADOS->ZS4_ABER,05,02) + '/' + Substr(T_DADOS->ZS4_ABER,01,04))
      cHora	     := T_DADOS->ZS4_HORA
      cVendedor  := T_DADOS->ZS4_VEND + " - " + Alltrim(T_DADOS->A3_NOME)
      cCliente   := T_DADOS->ZS4_CLIE 
      cLoja	     := T_DADOS->ZS4_LOJA
      cDCliente  := T_DADOS->A1_NOME
      cTelefone  := T_DADOS->ZS4_TELE
      cContato   := T_DADOS->ZS4_CONT
      cNomeCon   := T_DADOS->U5_CONTAT
      cEmailCli  := T_DADOS->ZS4_EMAI
      xFilial    := T_DADOS->ZS4_NFIL
      cNota	     := T_DADOS->ZS4_NOTA
      cSerie	 := T_DADOS->ZS4_SERI
      yFilial	 := T_DADOS->ZS4_CREF
      yNota	     := T_DADOS->ZS4_CREN
      ySerie	 := T_DADOS->ZS4_CRES
      cMemo2     := T_DADOS->MOTIVO
      yTipo      := T_DADOS->ZS4_TIPO
      yTipoRma   := T_DADOS->ZS4_CTIP
      cEmailVend := T_DADOS->A3_EMAIL
   
      cMemo5    := T_DADOS->RECADO

      Do Case
         Case xFilial == "01"
              nFilial := "01 - Porto Alegre"   
         Case xFilial == "02"
              nFilial := "02 - Caxias do Sul"   
         Case xFilial == "03"
              nFilial := "03 - Pelotas"   
         Case xFilial == "04"
              nFilial := "04 - Suprimentos"   
      EndCase

      If Empty(Alltrim(T_DADOS->ZS4_APRO))
         aAdd(aProvador, "" )
         cDataP        := Ctod("  /  /    ")
         cHoraP        := ""
         cConsideracao := ""
      Else
         aAdd(aProvador, T_DADOS->ZS4_APRO )         
         cDataP        := Substr(T_DADOS->ZS4_DLIB,07,02) + "/" + Substr(T_DADOS->ZS4_DLIB,05,02) + "/" + Substr(T_DADOS->ZS4_DLIB,01,04)
         cHoraP        := T_DADOS->ZS4_HLIB
         cConsideracao := T_DADOS->OBSERVACAO
      Endif

      Do Case
         Case T_DADOS->ZS4_STAT == "1"
              aAdd( aSituacao, "1 - Abertura" ) 
         Case T_DADOS->ZS4_STAT == "2"
              aAdd( aSituacao, "2 - Aprovado" ) 
         Case T_DADOS->ZS4_STAT == "3"
              aAdd( aSituacao, "3 - Cancelada" ) 
         Case T_DADOS->ZS4_STAT == "8"
              aAdd( aSituacao, "8 - Revisão" ) 
         Case T_DADOS->ZS4_STAT == "7"
              aAdd( aSituacao, "7 - Recusado" ) 
         Case T_DADOS->ZS4_STAT == "6"
              aAdd( aSituacao, "6 - Aguardando Doc Retorno" )
         Case T_DADOS->ZS4_STAT == "5"
              aAdd( aSituacao, "5 - Processo Finalizado" )
      EndCase

      // Posiciona o tipo de crédito
      For nContar = 1 to Len(aComboBx2)
          If Substr(aComboBx2[nContar],01,02) == T_DADOS->ZS4_CRED
             cComboBx2 := aComboBx2[nContar]
             EXIT
          Endif
      Next nontar

      // Posiciona o tipo de Motivo da RMA
      For nContar = 1 to Len(aMotivo)
          If Substr(aMotivo[nContar],01,06) == T_DADOS->ZS4_CMOT
             cComboBx6 := aMotivo[nContar]
             EXIT
          Endif
      Next nontar

      // Posiciona o tipo de Motivo da Aprovação/Reprovação/Revisão de RMA
      For nContar = 1 to Len(aMotivoA)
          If Substr(aMotivoA[nContar],01,06) == T_DADOS->ZS4_CMTA
             cComboBx7 := aMotivoA[nContar]
             EXIT
          Endif
      Next nontar

      // Carrega os Produtos
      aProdutos := {}
      aNumSerie := {}

      WHILE !T_DADOS->( EOF() )
         aAdd( aProdutos, { IIF(T_DADOS->ZS4_CHEK == "1", .T., .F.)                     ,;
                            T_DADOS->ZS4_ITEM                                           ,;
                            T_DADOS->ZS4_PROD                                           ,;
                            Alltrim(T_DADOS->B1_DESC) + ' ' + Alltrim(T_DADOS->B1_DAUX) ,;  
                            T_DADOS->ZS4_QUAN                                           ,;
                            T_DADOS->ZS4_UNIT                                           ,;
                            T_DADOS->ZS4_TOTA  })

         // Carrega o array dos números de séries
         For nContar = 1 to U_P_OCCURS(T_DADOS->SERIES,"|",1)
             aAdd( aNumSerie, { T_DADOS->ZS4_CLIE,;
                                T_DADOS->ZS4_LOJA,;
                                T_DADOS->ZS4_NFIL,;
                                T_DADOS->ZS4_NOTA,;
                                T_DADOS->ZS4_SERI,;
                                T_DADOS->ZS4_PROD,;
                                U_P_CORTA(T_DADOS->SERIES,"|", nContar) ,;
                                .T.              })

         Next nContar                       

         T_DADOS->( DbSkip() )

      ENDDO                           

      // Carrega o Tipo de RMA a ser incluída
      DbSelectArea ("ZS8")
      DbSetOrder(1)
      If DbSeek ( xFilial("ZS8") + yTipoRma )
         cTitulo := ZS8_DESC
      Else
         cTitulo := ""
      Endif

   Endif

   // Se o vendedor for LOGISTICA, seleciona no combo de Motivos o motivo ERRO LOGISTICA
   If _Tipo == "I"
      If UPPER(Alltrim(Substr(cVendedor,10))) == "LOGISTICA" 

         aMotivo := {}

         // Carrega o ComboBox de Motivos da RMA
         If Select("T_MOTIVO") > 0
            T_MOTIVO->( dbCloseArea() )
         EndIf

         cSql := "SELECT ZS6_CODI, "
         cSql += "       ZS6_DESC  "
         cSql += "  FROM " + RetSqlName("ZS6")
         cSql += " WHERE ZS6_DELE = ''"
         cSql += " AND ZS6_DESC   = 'ERRO LOGISTICA'"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

         If T_MOTIVO->( EOF() )
            MsgAlert("Atenção! Cadastro de Motivos de RMA está vazio. Cadastre primeiramente os motivos antes de continuar o cadastramento da RMA.")
            Return(.T.)
         Endif

         aAdd( aMotivo, "000000 - Selecione o Motivo da RMA" )
   
         T_MOTIVO->( DbGoTop() )
         WHILE !T_MOTIVO->( EOF() )
            aAdd(aMotivo,  T_MOTIVO->ZS6_CODI + " - " + T_MOTIVO->ZS6_DESC )   
            T_MOTIVO->( DbSkip() )
         ENDDO

      Endif   
   Endif

   If _Tipo == "I"
      DEFINE MSDIALOG oDlgX TITLE "RMA - Return Mersandise Authorized" FROM C(178),C(181) TO C(633),C(770) PIXEL
   Endif
   
   If _Tipo == "A"
      DEFINE MSDIALOG oDlgX TITLE "RMA - Return Mersandise Authorized" FROM C(178),C(181) TO C(633),C(770) PIXEL
   Endif

   If _Tipo == "E"
      DEFINE MSDIALOG oDlgX TITLE "RMA - Return Mersandise Authorized" FROM C(178),C(181) TO C(633),C(770) PIXEL
   Endif

   If _Tipo == "V"
      DEFINE MSDIALOG oDlgX TITLE "RMA - Return Mersandise Authorized" FROM C(178),C(181) TO C(633),C(967) PIXEL
   Endif   

   @ C(005),C(005) Say "Nº RMA"                      Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(005),C(061) Say "Data Abertura"               Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(005),C(105) Say "Hora Abertura"               Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(005),C(148) Say "Vendedor"                    Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(005),C(224) Say "Status"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(026),C(005) Say "Cliente"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(026),C(225) Say "Telefone"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(045),C(005) Say "Contato"                     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(045),C(140) Say "E-mail"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(064),C(005) Say "Filial"                      Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(064),C(114) Say "Nº N.Fiscal"                 Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(064),C(159) Say "Série"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(085),C(005) Say "Produtos da Nota Fiscal"     Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(132),C(005) Say "Motivo da RMA"               Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(132),C(156) Say "Informações Ref. ao Crédito" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(154),C(005) Say "Detalhes do Motivo da RMA"   Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(154),C(156) Say "Filial"                      Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(154),C(174) Say "N.Fiscal"                    Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(154),C(210) Say "Série"                       Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(192),C(125) Say "Motivo"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(204),C(083) Say "Considerações"               Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(205),C(005) Say "Data"                        Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(215),C(005) Say "Hora"                        Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(192),C(005) Say "Aprovador"                   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   If _Tipo == "V"
      @ C(005),C(292) Say "Recados da RMA"              Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   Endif   

   // Título do tipo de RMA
   @ C(026),C(057) Say cTitulo Size C(161),C(008) COLOR CLR_RED PIXEL OF oDlgX

   @ C(014),C(005) MsGet    oGet1     Var   cNRMA       When lChumba  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(014),C(031) MsGet    oGet2     Var   cARMA       When lChumba  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(014),C(061) MsGet    oGet3     Var   cAbertura   When lChumba  Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(014),C(105) MsGet    oGet4     Var   cHora       When lChumba  Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(014),C(148) MsGet    oGet5     Var   cVendedor   When lChumba  Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(014),C(224) ComboBox cComboBx4 Items aSituacao   When lChumba  Size C(064),C(010) PIXEL OF oDlgX
   @ C(035),C(005) MsGet    oGet6     Var   cCliente    When lAbre    Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX F3("SA1")
   @ C(035),C(033) MsGet    oGet7     Var   cLoja       When lAbre    Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX VALID(BSCCLIRMA(cCliente, cLoja))
   @ C(035),C(057) MsGet    oGet15    Var   cDCliente   When lChumba  Size C(161),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(035),C(224) MsGet    oGet16    Var   cTelefone   When lChumba  Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(053),C(005) MsGet    oGet18    Var   cContato    When lChumba  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(053),C(033) Button "..."                         When lContato Size C(010),C(009) PIXEL OF oDlgX ACTION( TRZCONTATO(cCliente, cLoja) )
   @ C(053),C(047) MsGet    oGet19    Var   cNomeCon    When lChumba  Size C(087),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX

   If _Tipo == "A"
      @ C(053),C(140) MsGet    oGet17    Var   cEmailCli                 Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   Else
      @ C(053),C(140) MsGet    oGet17    Var   cEmailCli   When lAbre    Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   Endif      

   @ C(072),C(005) MsGet    oGet10    Var   xFilial     When lAbre    Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX VALID(BSCFILIAL(xFilial))
   @ C(072),C(022) MsGet    oGet11    Var   nFilial     When lChumba  Size C(088),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(072),C(114) MsGet    oGet8     Var   cNota       When lAbre    Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(072),C(159) MsGet    oGet9     Var   cSerie      When lAbre    Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX

   @ C(070),C(181) Button   "Pesquisar"                 When lAbre    Size C(050),C(012) PIXEL OF oDlgX ACTION( BSCNOTA1(xFilial, cNota, cSerie, cCliente, cLoja, 2))
   @ C(070),C(238) Button   "Pesq. NFs Cliente"         When lAbre    Size C(050),C(012) PIXEL OF oDlgX ACTION( BSCNOTA2(cCliente, cLoja) )
   @ C(163),C(005) GET      oMemo2    Var   cMemo2 MEMO When lAbre    Size C(147),C(020) PIXEL OF oDlgX
   @ C(141),C(005) ComboBox cComboBx6 Items aMotivo     When lAbre    Size C(147),C(010) PIXEL OF oDlgX
   @ C(141),C(156) ComboBox cComboBx2 Items aComboBx2   When lContato Size C(133),C(010) PIXEL OF oDlgX VALID( LibCampo(cComboBx2) )
   @ C(164),C(156) MsGet    oGet12    Var   yFilial     When lDados   Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(164),C(174) MsGet    oGet13    Var   yNota       When lDados   Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(164),C(210) MsGet    oGet14    Var   ySerie      When lDados   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(186),C(005) GET      oMemo3    Var   cMemo3 MEMO When lAbre    Size C(283),C(001) PIXEL OF oDlgX

   @ C(104),C(255) Button "Quantidade" Size C(034),C(012) PIXEL OF oDlgX ACTION( AlteQuant(aProdutos[oProdutos:nAt,02], aProdutos[oProdutos:nAt,03], aProdutos[oProdutos:nAt,04], aProdutos[oProdutos:nAt,05], aProdutos[oProdutos:nAt,06], aProdutos[oProdutos:nAt,07], aProdutos[oProdutos:nAt,01]) )
   @ C(118),C(255) Button "Nº Séries"  Size C(034),C(012) PIXEL OF oDlgX ACTION( BscNrSerie(aProdutos[oProdutos:nAt,01], cCliente, cLoja, xFilial, cNota, cSerie, aProdutos[oProdutos:nAt,03] ) )

   Do Case
      Case _Tipo == "I"
           @ C(156),C(251) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlgX ACTION( SalvaRMA(_Tipo) )
      Case _Tipo == "A"
           @ C(156),C(251) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlgX ACTION( SalvaRMA(_Tipo) )
      Case _Tipo == "E"           
           @ C(156),C(251) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgX ACTION( SalvaRMA(_Tipo) )
   EndCase

   @ C(170),C(251) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Aprovação/Reprovação
   @ C(190),C(035) ComboBox cComboBx5 Items aProvador   When lAprova Size C(086),C(010) PIXEL OF oDlgX

   @ C(190),C(144) ComboBox cComboBx7 Items aMotivoA           When lAprova Size C(104),C(010) PIXEL OF oDlgX
   @ C(203),C(124) GET      oMemo4    Var   cConsideracao MEMO When lAprova Size C(123),C(021) PIXEL OF oDlgX
   @ C(203),C(035) MsGet    oGet20    Var   cDataP             When lAprova Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(215),C(035) MsGet    oGet21    Var   cHoraP             When lAprova Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(189),C(251) Button "Aprovar"                            When lAprova Size C(037),C(008) PIXEL OF oDlgX
   @ C(198),C(251) Button "Revisar"                            When lAprova Size C(037),C(008) PIXEL OF oDlgX
   @ C(207),C(251) Button "Reprovar"                           When lAprova Size C(037),C(008) PIXEL OF oDlgX
   @ C(217),C(251) Button "Retornar"                           When lAprova Size C(037),C(008) PIXEL OF oDlgX

   If _Tipo == "V"
      @ C(014),C(292) GET oMemo5 Var cMemo5 MEMO Size C(096),C(140) PIXEL OF oDlgX
      @ C(156),C(292) GET oMemo6 Var cMemo6 MEMO Size C(096),C(053) PIXEL OF oDlgX
      @ C(212),C(312) Button "Registrar Recado"  Size C(055),C(012) PIXEL OF oDlgX ACTION(REGRECADO(_RMA, _ANO, cEmailLib, cEmailVend))
   Endif  

   If _Tipo == "I"
      aAdd( aProdutos, { .F., "","","","","","" } )
   Endif

   // Cria Componentes Padroes do Sistema
   @ 117,05 LISTBOX oProdutos FIELDS HEADER "", "Item", "Código" ,"Descrição dos Produtos", "Qtd", "R$ Unitário", "R$ Total" PIXEL SIZE 315,048 OF oDlgX ;
                            ON dblClick(aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1],oProdutos:Refresh())     
   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
             		    		   aProdutos[oProdutos:nAt,02],;
         	         	           aProdutos[oProdutos:nAt,03],;
         	         	           aProdutos[oProdutos:nAt,04],;
         	         	           aProdutos[oProdutos:nAt,05],;
         	         	           aProdutos[oProdutos:nAt,06],;         	         	                    	         	           
         	        	           aProdutos[oProdutos:nAt,07]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que registra o recado digitado
Static Function REGRECADO(_RMA, _ANO, _EmailLib, _EmailVend)

   Local _nErro  := 0
   Local nContar := 0
   Local cTexto  := ""

   If Empty(Alltrim(cMemo6))
      Return(.T.)
   Endif

   If MsgYesNo("Deseja registrar o recado informado?")

      // Prepara o texto para gravação
      cMemo5 := Alltrim(cMemo5) + "[ " + Alltrim(cUserName) + " - " + Dtoc(Date()) + " - " + Time() + " ]" + ;
                                  chr(13) + chr(10) + Alltrim(cMemo6) + chr(13) + chr(10) + chr(13) + chr(10)
      cMemo6 := ""
      oMemo5:Refresh()
      oMemo6:Refresh()

      For nContar = 1 to Len(aProdutos)
 
          If aProdutos[nContar,01] == .F.
             Loop
          Endif

          aArea := GetArea()

          DbSelectArea("ZS4")
          DbSetOrder(2)
          If DbSeek(xfilial("ZS4") + _RMA + _ANO + aProdutos[nContar,02] + aProdutos[nContar,3] )
             RecLock("ZS4",.F.)
             ZS4_RECA := cMemo5
             MsUnLock()              
          Endif
          
      Next nContar    

      // Envia e-mail aos Liberadores ou para o Vendedor
      If !Empty(Alltrim(_EmailVend))

         cTexto := ""
         cTexto := "Prezado(a) Vendedor(a)/Liberado(a) de RMA" + chr(13) + chr(10) + chr(13) + chr(10)
         cTexto += "Existe recado adicionado a RMA conforme dados abaixo:" + chr(13) + chr(10) + chr(13) + chr(10)
         cTexto += "Dados da RMA" + chr(13) + chr(10) + chr(13) + chr(10)
         cTexto += "Nº RMA: " + cNRMA + "/" + cARMA + chr(13) + chr(10)
         cTexto += "Cliente: " + cCliente + "." + cLoja + " - " + Alltrim(cDCliente) + chr(13) + chr(10)
         cTexto += "Nota Fiscal: " + Alltrim(cNota) + chr(13) + chr(10)
         cTexto += "Série: " + Alltrim(cSerie) + chr(13) + chr(10) + chr(13) + chr(10)

         U_AUTOMR20(cTexto, Alltrim(_EmailVend), "", "Recado de RMA" )   
   
      Endif

   Endif
   
Return(.T.)

// Função que mostra o help do tipo de RMA selecionado
Static Function MSTHELPRMA(_Observacao, _Mostra)

   cHelpRma := _Observacao

   If _Mostra == 2
      oHelpRma:Refresh()
   Endif   

Return(.T.)

// Função que salva os dados incluidos, alterados ou excluídos
Static Function SalvaRMA(_Operacao)

   Local cSql     := ""
   Local cEmail   := ""
   Local nContar  := 0
   Local nProcura := 0
   Local nItens   := 0
   Local cString  := ""
   Local _nErro   := 0
   Local cTexto   := ""
   Local lMarcado := .F.
   
   // Realiza a consistência dos dados antes da gravação
   If Empty(Alltrim(cCliente))
      MsgAlert("Cliente não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cContato))
      MsgAlert("Contato co Cliente não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(xFilial))
      MsgAlert("Filial da nota fiscal a ser devolvida não informada.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cNota))
      MsgAlert("Nota Fiscal a ser devolvida não informada.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cSerie))
      MsgAlert("Série da Nota Fiscal a ser devolvida não informada.")
      Return(.T.)
   Endif                                      

   If Substr(cComboBx6,01,06) == "000000"
      MsgAlert("Motivo da RMA não selecionado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cMemo2))
      MsgAlert("Descrição do Motivo da RMA não informado.")
      Return(.T.)
   Endif

   If Substr(cComboBx2,01,02) == "  "
      MsgAlert("Informações ref. ao crédito não informado.")
      Return(.T.)
   Endif

   nItens := 0

   For nContar = 1 to Len(aProdutos)
       If aProdutos[nContar,01] == .T.
          nItens += 1
       Endif
   Next nContar       
   
// If yTipo == 1
      If nItens == 0
         MsgAlert("Nenhum item foi indicado para devolução. Verifique!")
         Return(.T.)
      Endif
// Endif   

   If Substr(cComboBx2,01,02) == "03"

      If Empty(Alltrim(yFilial))
         MsgAlert("Filial da Nota Fiscal de crédito não informada.")
         Return(.T.)
      Endif
         
      If Empty(Alltrim(yNota))
         MsgAlert("Nota Fiscal de crédito não informada.")
         Return(.T.)
      Endif
      
      If Empty(Alltrim(ySerie))
         MsgAlert("Série da Nota Fiscal de crédito não informada.")
         Return(.T.)
      Endif
      
   Endif

   // Verifica se os produtos marcados para RMA são controlados por nº de série.
   // Se forem, verifica se houve indicação de pelo menos um nº de série para a RMA
   If _Operacao == "I" .Or. _Operacao == "A"

      // Em Caso da RMA ser do tipo Troca de Nota, força sempre a indicação de todos os produtos da RMA
      If yTipo == 1
         For nContar = 1 to Len(aProdutos)
             aProdutos[nContar,01] := .T.
         Next nContar
      Endif

      For nContar = 1 to Len(aProdutos)
 
          If aProdutos[nContar,01] == .F.
             Loop
          Endif

          If Select("T_PRODUTO") > 0
             T_PRODUTO->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT B1_LOCALIZ"
          cSql += "  FROM " + RetSqlName("SB1")
          cSql += " WHERE B1_COD     = '" + Alltrim(aProdutos[nContar,03]) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

          If T_PRODUTO->( EOF() )
             Loop
          Endif
          
          If T_PRODUTO->B1_LOCALIZ <> "S"
             Loop
          Endif
          
          lMarcado := .F.

          For nProcura = 1 to Len(aNumSerie)

              If aNumSerie[nProcura,06] == aProdutos[nContar,03]

                 If aNumSerie[nProcura,08] == .T.

                    lMarcado := .T.

                 Endif

              Endif

          Next nProcura
          
          If lMarcado == .F.
             MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum nº de série foi marcado para o produto:" + chr(13) + chr(10) + Alltrim(aProdutos[nContar,03]) + " - " + Alltrim(aProdutos[nContar,04]) + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
             Return(.T.)
          Endif

      Next nContar    
   
   Endif
      
   // Inclusão de Nova RMA
   Do Case
      Case _Operacao == "I"
   
          // Pesquisa o próximo código do RMA para Inclusão
          If Select("T_PROXIMO") > 0
             T_PROXIMO->( dbCloseArea() )
          EndIf

          cSql := ""      
          cSql := "SELECT ZS4_NRMA"
          cSql += "   FROM " + RetSqlName("ZS4")
          cSql += " WHERE D_E_L_E_T_ = ''"   
          cSql += " ORDER BY ZS4_NRMA DESC"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

          If T_PROXIMO->( EOF() )
             cNRMA := "00001"
             cARMA := Strzero(Year(Date()),4)
          Else
             cNRMA := STRZERO(INT(VAL(T_PROXIMO->ZS4_NRMA)) + 1,5)
             cARMA := Strzero(Year(Date()),4)
          Endif
         
      Case _Operacao == "A"

          // Deleta o registro para nova gravação
          cSql := ""
          cSql := "DELETE FROM " + RetSqlName("ZS4")
          cSql += " WHERE ZS4_NRMA = '" + Alltrim(cNRMA)    + "'"
          cSql += "   AND ZS4_ANO  = '" + Alltrim(cARMA)    + "'"
          cSql += "   AND ZS4_CLIE = '" + Alltrim(cCliente) + "'"
          cSql += "   AND ZS4_LOJA = '" + Alltrim(cLoja)    + "'"

          _nErro := TcSqlExec(cSql) 

          If TCSQLExec(cSql) < 0 
             alert(TCSQLERROR())
             Return(.T.)
          Endif
   
      Case _Operacao == "E"

  		   If MsgYesNo("Confirma a exclusão desta solicitação de RMA?")
             // Deleta o registro para nova gravação
             cSql := ""
             cSql := " UPDATE  " + RetSqlName("ZS4")
             cSql += " Set   ZS4_STAT = '3' " //Cancelado Michel Aoki
             cSql += " WHERE ZS4_NRMA = '" + Alltrim(cNRMA)    + "'"
             cSql += "   AND ZS4_ANO  = '" + Alltrim(cARMA)    + "'"
             cSql += "   AND ZS4_CLIE = '" + Alltrim(cCliente) + "'"
             cSql += "   AND ZS4_LOJA = '" + Alltrim(cLoja)    + "'"

             _nErro := TcSqlExec(cSql) 

             If TCSQLExec(cSql) < 0 
                alert(TCSQLERROR())
                Return(.T.)
             Endif

             oDlgX:End() 

             PsqGridDados(0, Substr(cVendedor,01,06), "0")
          
             Return(.T.)

          Else

             Return(.T.)          
          
          Endif
          
   EndCase        

   // Inseri os dados na Tabela
   aArea := GetArea()

   For nContar = 1 to Len(aProdutos)
 
       // Carrega a variável de nºs de séries para gravação
       cString := ""

       For nProcura = 1 to Len(aNumSerie)

          If aNumSerie[nProcura,06] == aProdutos[nContar,03]
              If aNumSerie[nProcura,08] == .T.
                 cString += aNumSerie[nProcura,07] + "|"
              Endif
           Endif

       Next nProcura

       dbSelectArea("ZS4")
       RecLock("ZS4",.T.)

       ZS4_FILIAL := ""
       ZS4_NRMA   := cNRMA
       ZS4_ANO    := cARMA
       ZS4_ABER   := Date()
       ZS4_HORA   := Time()
       ZS4_VEND   := Substr(cVendedor,01,06)
       ZS4_STAT   := "1"
       ZS4_CLIE   := cCliente
       ZS4_LOJA   := cLoja
       ZS4_TELE   := cTelefone
       ZS4_CONT   := cContato
       ZS4_EMAI   := cEmailCli
       ZS4_NFIL   := xFilial
       ZS4_NOTA   := cNota
       ZS4_SERI   := cSerie
       ZS4_CHEK   := IIF(aProdutos[nContar,01] == .F., "0", "1")
       ZS4_ITEM   := aProdutos[nContar,02]
       ZS4_PROD   := aProdutos[nContar,03]
       ZS4_QUAN   := aProdutos[nContar,05]
       ZS4_UNIT   := aProdutos[nContar,06]
       ZS4_TOTA   := aProdutos[nContar,07]
       ZS4_CMOT   := Substr(cComboBx6,01,06)
       ZS4_CMTA   := Substr(cComboBx7,01,06)
       ZS4_MOTI   := cMemo2
       ZS4_CRED   := Substr(cComboBx2,01,02)
       ZS4_CREF   := yFilial
       ZS4_CREN   := yNota
       ZS4_CRES   := ySerie
       ZS4_NSER   := cString
       ZS4_TIPO   := yTipo
       ZS4_CTIP   := yTipoRma

       If _Operacao == "I"
          ZS4_KUSU := ALLTRIM(cUserName)
          ZS4_KDAT := Date()
          ZS4_KHOR := Time()
       Endif

       MsUnLock()
          
   Next nContar

   // Envia e-mail aos aprovadores de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZZ4_NRMA1 ,"
   cSql += "       ZZ4_NRMA2 ,"
   cSql += "       ZZ4_NRMA3 ,"
   cSql += "       ZZ4_NRMA4 ,"
   cSql += "       ZZ4_NRMA5 ,"                              
   cSql += "       ZZ4_NRMA6 ,"                              
   cSql += "       ZZ4_NRMA7 ,"                              
   cSql += "       ZZ4_NRMA8 ,"                              
   cSql += "       ZZ4_NRMA9 ,"                              
   cSql += "       ZZ4_NRMA10,"                              
   cSql += "       ZZ4_ERMA1 ,"   
   cSql += "       ZZ4_ERMA2 ,"   
   cSql += "       ZZ4_ERMA3 ,"   
   cSql += "       ZZ4_ERMA4 ,"   
   cSql += "       ZZ4_ERMA5 ,"                                   
   cSql += "       ZZ4_EMAI6 ,"                                   
   cSql += "       ZZ4_EMAI7 ,"                                   
   cSql += "       ZZ4_EMAI8 ,"                                   
   cSql += "       ZZ4_EMAI9 ,"                                   
   cSql += "       ZZ4_EMAI10 "                                   
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   If T_PARAMETROS->( EOF() )
   Else

      cEmail := ""
 
      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA1))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA1 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA2))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA2 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA3))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA3 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA4))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA4 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA5))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA5 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA6))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI6 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA7))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI7 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA8))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI8 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA9))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI9 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA10))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI10 + ";"
      Endif
      
      // Elimina a última vírgula
      cEmail := Substr(cEmail, 01, len(Alltrim(cEmail)) - 1)
      
   Endif
   
   If !Empty(Alltrim(cEmail))

      cTexto := ""
      cTexto := "Prezado(a) Aprovador(a) de RMA" + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Existe uma RMA aguardando a sua aprovação." + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Dados da RMA" + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Nº RMA: " + cNRMA + "/" + cARMA + chr(13) + chr(10)
      cTexto += "Cliente: " + cCliente + "." + cLoja + " - " + Alltrim(cDCliente) + chr(13) + chr(10)
      cTexto += "Nota Fiscal: " + Alltrim(cNota) + chr(13) + chr(10)
      cTexto += "Série: " + Alltrim(cSerie) + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Motivo Devolução:" + chr(13) + chr(10)
      cTexto += Alltrim(cMemo2) + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Att."  + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "RMA - Return Merchandise Authorization"

      U_AUTOMR20(cTexto, Alltrim(cEmail), "", "Solicitação Aprovação de RMA" )   
   
   Endif

   oDlgX:End() 

   PsqGridDados(0, Substr(cVendedor,01,06), "0")
   
Return(.T.)

// Função que libera ou não os dados da nota fiscal de crédito
Static Function LibCampo(cComboBx2)

   If Substr(cComboBx2,01,02) == "03"
      lDados := .T.
   Else
      yFilial := Space(02)
      yNota	  := Space(06)
      ySerie  := Space(03)
      lDados := .F.
   Endif

Return(.T.)

// Função que valida e pesquisa o nome da filial informada
Static Function BSCFILIAL(_Filial)

   If Empty(Alltrim(_Filial))
      Return(.T.)
   Endif

   If _Filial <> "01" .And. ;
      _Filial <> "02" .And. ;
      _Filial <> "03" .And. ;
      _Filial <> "04"
      MsgAlert("Filial inválida")
      Return(.T.)
   Endif
   
   Do Case
      Case _Filial == "01"
           nFilial := "01 - Porto Alegre"   
      Case _Filial == "02"
           nFilial := "02 - Caxias do Sul"   
      Case _Filial == "03"
           nFilial := "03 - Pelotas"   
      Case _Filial == "04"
           nFilial := "04 - Suprimentos"   
   EndCase

   oGet11:Refresh()
   
Return(.T.)   

// Função que pesquisa o cliente selecionado
Static Function BSCCLIRMA(_Cliente, _Loja)

   Local cSql := ""

   cCliente  := Space(06)
   cLoja     := Space(03)
   cDCliente := ""
   cTelefone := ""
   cEmailCli := ""
   cContato  := Space(06)
   cNomeCon  := Space(30)
   cEmailCli := Space(100)

   If Empty(Alltrim(_Cliente))
      Return(.T.)
   Endif

   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA,"
   cSql += "       A1_NOME,"
   cSql += "       RTRIM(A1_END) + ' - ' + RTRIM(A1_BAIRRO) AS ENDERECO ,"
   cSql += "       RTRIM(A1_EST) + '/' + RTRIM(A1_MUN) + '-' + SUBSTRING(A1_CEP,01,02) + '.' + SUBSTRING(A1_CEP,03,03) + '-' + SUBSTRING(A1_CEP,06,03) AS CIDADE,"
   cSql += "       '(' + RTRIM(A1_DDD) + ') - ' + RTRIM(A1_TEL) AS TELEFONE,"
   cSql += "       A1_EMAIL"
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A1_COD     = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(_Loja)    + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
   
   If T_CLIENTE->( EOF() )
      cCliente  := Space(06)
      cLoja     := Space(03)
      cDCliente := ""
      cTelefone := ""
      cEmailCli := ""
      cContato  := Space(06)
      cNomeCon  := Space(30)
      cEmailCli := Space(100)
      Return(.T.)
   Endif

   cCliente  := T_CLIENTE->A1_COD
   cLoja     := T_CLIENTE->A1_LOJA
   cDCliente := Alltrim(T_CLIENTE->A1_NOME)
   cTelefone := Alltrim(T_CLIENTE->TELEFONE)
   cEmailCli := Alltrim(T_CLIENTE->A1_EMAIL)

Return(.T.)

// Função que pesquisa os contato do cliente informado
Static Function TRZCONTATO(_Cliente, _Loja)

   Local cSql := ""

   Private oOk      := LoadBitmap( GetResources(), "LBOK" )
   Private oNo      := LoadBitmap( GetResources(), "LBNO" )
   Private aContato := {}
   Private oContato
   
   Private oDlgC
   
   If Empty(Alltrim(_Cliente))
      MsgAlert("Necessário informar o cliente para pesquisa de contatos.") 
      Return .T.
   Endif
      
   // Carrega o Combo de Contatos
   If Select("T_CONTATO") > 0
      T_CONTATO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.AC8_FILIAL,"
   cSql += "       A.AC8_FILENT,"
   cSql += "       A.AC8_ENTIDA,"
   cSql += "       A.AC8_CODENT,"
   cSql += "       A.AC8_CODCON,"
   cSql += "       B.U5_CONTAT ,"
   cSql += "       B.U5_EMAIL  ,"
   cSql += "       B.U5_DDD    ,"
   cSql += "       B.U5_FONE    "
   cSql += "  FROM " + RetSqlName("AC8") + " A, "
   cSql += "       " + RetSqlName("SU5") + " B  "
   cSql += " WHERE A.AC8_CODENT = '" + alltrim(_Cliente) + Alltrim(_Loja) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.AC8_CODCON = B.U5_CODCONT"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )
   
   If T_CONTATO->( EOF() )
      aAdd( aContato, { .F.,"","","" } )
   Else
      WHILE !T_CONTATO->( EOF() )
         aAdd( aContato, { .F.                   ,;
                           T_CONTATO->AC8_CODCON ,;
                           T_CONTATO->U5_CONTAT  ,;
                           T_CONTATO->U5_EMAIL   })
         T_CONTATO->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgC TITLE "Consulta Contatos" FROM C(178),C(181) TO C(392),C(656) PIXEL

   @ C(005),C(005) Say "Contatos do Cliente informado" Size C(073),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(091),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgC ACTION( FechaContato() )

   @ 020,005 LISTBOX oContato FIELDS HEADER "M", "Código", "Nome dos Contatos", "E-Mail" PIXEL SIZE 290,092 OF oDlgC ;
                            ON dblClick(aContato[oContato:nAt,1] := !aContato[oContato:nAt,1],oContato:Refresh())     
   oContato:SetArray( aContato )
   oContato:bLine := {||    {Iif(aContato[oContato:nAt,01],oOk,oNo),;
                                 aContato[oContato:nAt,02],;
           		    		     aContato[oContato:nAt,03],;
         	         	         aContato[oContato:nAt,04]}}

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que fecha a tela de consulta de contatos
Static Function FechaContato()

   Local nContar   := 0
   Local nMarcados := 0
   
   // Verifica se houve a marcação de mais do que um contato
   For nContar = 1 to Len(acontato)
       If aContato[nContar,01] == .T.
          nMarcados += 1
       Endif
   Next nContar
   
   If nMarcados > 1
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Indique apenas um contato do cliente.")
      Return .T.
   Endif

   // Pesquisa o contato marcado
   For nContar = 1 to Len(acontato)
       If aContato[nContar,01] == .T.
          cContato  := aContato[nContar,02]
          cNomeCon  := aContato[nContar,03]
          cEmailCli := aContato[nContar,04]
          Exit
       Endif
   Next nContar

   oDlgC:End() 
   
   oGet18:Refresh()
   oGet19:Refresh()
   oGet17:Refresh()

Return(.T.)

// Função que pesquisa a nota fisdcal informada
Static Function BSCNOTA1(_Filial, _Nota, _Serie, _Cliente, _Loja, _Tipo)

   Local cSql := ""

   If Empty(Alltrim(xFilial))
      MsgAlert("Filial não informada para pesquisa.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(_Nota))
      MsgAlert("Nota Fiscal não informada para pesquisa.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_Serie))
      MsgAlert("Série não informada para pesquisa.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_Cliente))
      MsgAlert("Cliente não informado para pesquisa.")
      Return(.T.)
   Endif

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql := "SELECT A.D2_ITEM,"
   cSql += "       A.D2_COD ,"
   cSql += "       RTRIM(B.B1_DESC) + ' ' + RTRIM(B.B1_DAUX) AS DESCRICAO,"
   cSql += "       A.D2_QUANT ,"
   cSql += "       A.D2_PRCVEN,"
   cSql += "       A.D2_TOTAL  "
   cSql += "  FROM " + RetSqlName("SD2") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(xFilial) + "'"
   cSql += "   AND A.D2_DOC     = '" + Alltrim(_Nota)   + "'"
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(_Serie)  + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.D2_COD     = B.B1_COD"
   cSql += "   AND B.D_E_L_E_T_ = ''"
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(_Loja)    + "'"
   cSql += " ORDER BY A.D2_ITEM "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   aProdutos := {}

   T_NOTA->( DbGoTop() )
   
   WHILE !T_NOTA->( EOF() )
      aAdd( aProdutos, { IIF(yTipo == 1, .T., .F.) ,;
                         T_NOTA->D2_ITEM           ,;
                         T_NOTA->D2_COD            ,;
                         T_NOTA->DESCRICAO         ,;  
                         T_NOTA->D2_QUANT          ,;
                         T_NOTA->D2_PRCVEN         ,;
                         T_NOTA->D2_TOTAL })
      T_NOTA->( DbSkip() )
   ENDDO                           

   If _Tipo == 1
      Return(.T.)
   Endif
                        
   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
             		    		   aProdutos[oProdutos:nAt,02],;
         	         	           aProdutos[oProdutos:nAt,03],;
         	         	           aProdutos[oProdutos:nAt,04],;
         	         	           aProdutos[oProdutos:nAt,05],;
         	         	           aProdutos[oProdutos:nAt,06],;         	         	                    	         	           
         	        	           aProdutos[oProdutos:nAt,07]}}

Return(.T.)

// Função que pesquisa as notas fiscais do cliente informado
Static Function BSCNOTA2(_Cliente, _Loja)

   Local cGet1	 := Space(25)
   Local oGet1

   Private oDlgN

   Private aCabeca  := {}
   Private aDetalhe := {}

   Private oCabeca
   Private oDetalhe

   If Empty(Alltrim(_Cliente))
      MsgAlert("Necessário informar o Cliente para pesquisa.")
      Return(.T.)
   Endif

   aCabeca := {}

   aAdd( aDetalhe, { "","","","","","","" })

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F2_FILIAL ,"
   cSql += "       SUBSTRING(F2_EMISSAO,07,02) + '/' + SUBSTRING(F2_EMISSAO,05,02) + '/' + SUBSTRING(F2_EMISSAO,01,04) AS EMISSAO,"
   cSql += "       F2_DOC    ,"
   cSql += "       F2_SERIE  ,"
   cSql += "       F2_VALBRUT "
   cSql += "  FROM " + RetSqlName("SF2")
   cSql += " WHERE F2_CLIENT  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND F2_LOJA    = '" + Alltrim(_Loja)    + "'"
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += "   AND F2_TIPO    = 'N'" 
   cSql += " ORDER BY F2_FILIAL, SUBSTRING(F2_EMISSAO,07,02) + '/' + SUBSTRING(F2_EMISSAO,05,02) + '/' + SUBSTRING(F2_EMISSAO,01,04)"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   If T_NOTA->( EOF() )
      aAdd( aCabeca , { "","","","","" } )
   Else

      T_NOTA->( DbGoTop() )
   
      WHILE !T_NOTA->( EOF() )
         aAdd( aCabeca, { T_NOTA->F2_FILIAL,;
                          T_NOTA->EMISSAO  ,;
                          T_NOTA->F2_DOC   ,;
                          T_NOTA->F2_SERIE ,;
                          T_NOTA->F2_VALBRUT})
         T_NOTA->( DbSkip() )
      ENDDO                            
   Endif

   // Carrega os produtos da primeira nota fiscal para display
   aDetalhe := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_FILIAL ," + chr(13)
   cSql += "       A.D2_CLIENTE," + chr(13)
   cSql += "       A.D2_LOJA   ," + chr(13)
   cSql += "       A.D2_DOC    ," + chr(13)
   cSql += "       A.D2_SERIE  ," + chr(13)
   cSql += "       A.D2_ITEM   ," + chr(13)
   cSql += "       A.D2_COD    ," + chr(13)
   cSql += "       B.B1_DESC   ," + chr(13)
   cSql += "       A.D2_UM     ," + chr(13)
   cSql += "       A.D2_QUANT  ," + chr(13)
   cSql += "       A.D2_PRCVEN ," + chr(13)
   cSql += "       A.D2_TOTAL   " + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " B  " + chr(13)
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(aCabeca[1,1]) + "'" + chr(13)
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(_Cliente)     + "'" + chr(13)
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(_Loja)        + "'" + chr(13)
   cSql += "   AND A.D2_DOC     = '" + Alltrim(aCabeca[1,3]) + "'" + chr(13)
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(aCabeca[1,4]) + "'" + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"       + chr(13)
   cSql += "   AND A.D2_COD     = B.B1_COD" + chr(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"       + chr(13)
   cSql += " ORDER BY A.D2_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   If T_DETALHE->( EOF() )
      aAdd( aDetalhe, { "","","","","","","" })
   Else
      WHILE !T_DETALHE->( EOF() )
         aAdd( aDetalhe, { T_DETALHE->D2_ITEM  ,;
                           T_DETALHE->D2_COD   ,;
                           T_DETALHE->B1_DESC  ,;
                           T_DETALHE->D2_UM    ,;
                           T_DETALHE->D2_QUANT ,;
                           T_DETALHE->D2_PRCVEN,;
                           T_DETALHE->D2_TOTAL })
         T_DETALHE->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgN TITLE "Notas Fiscais do Cliente" FROM C(178),C(181) TO C(499),C(569) PIXEL

   @ C(005),C(005) Say "Notas Fiscais do Cliente"            Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgN
   @ C(064),C(005) Say "Produtos da Nota Fiscal selecionada" Size C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlgN

   @ C(143),C(110) Button "Selecionar" Size C(037),C(012) PIXEL OF oDlgN ACTION( FechaPsq() )
   @ C(143),C(151) Button "Retornar"   Size C(037),C(012) PIXEL OF oDlgN ACTION( oDlgN:End() )

   @ 014,05 LISTBOX oCabeca FIELDS HEADER "Filial", "Emissao", "Nº N.Fiscal" ,"Série", "Valor Total" PIXEL SIZE 240,065 OF oDlgN ;
                            ON dblClick(aCabeca[oCabeca:nAt,1] := !aCabeca[oCabeca:nAt,1],oCabeca:Refresh())     
   oCabeca:SetArray( aCabeca )
   oCabeca:bLine := {||     {aCabeca[oCabeca:nAt,01],;
           		    		 aCabeca[oCabeca:nAt,02],;
         	         	     aCabeca[oCabeca:nAt,03],;
         	         	     aCabeca[oCabeca:nAt,04],;
         	         	     aCabeca[oCabeca:nAt,05]}}

   oCabeca:bLDblClick := {|| MSTPRODUTO(aCabeca[oCabeca:nAt,01], aCabeca[oCabeca:nAt,03], aCabeca[oCabeca:nAt,04], _Cliente, _Loja) } 

   @ 090,05 LISTBOX oDetalhe FIELDS HEADER "Item", "Código", "Descrição dos Produtos" ,"Und", "Qtd.", "Unitário", "Total" PIXEL SIZE 240,090 OF oDlgN ;
                            ON dblClick(aDetalhe[oDetalhe:nAt,1] := !aDetalhe[oDetalhe:nAt,1],oDetalhe:Refresh())     
   oDetalhe:SetArray( aDetalhe )
   oDetalhe:bLine := {||     {aDetalhe[oDetalhe:nAt,01],;
          		    		  aDetalhe[oDetalhe:nAt,02],;
          		    		  aDetalhe[oDetalhe:nAt,03],;
          		    		  aDetalhe[oDetalhe:nAt,04],;
          		    		  aDetalhe[oDetalhe:nAt,05],;
          		    		  aDetalhe[oDetalhe:nAt,06],;
          		    		  aDetalhe[oDetalhe:nAt,07]}}
   oDetalhe:Refresh()

   ACTIVATE MSDIALOG oDlgN CENTERED 

Return(.T.)                                                                                 

// Função que fecha a janela de pesquisa de notas fiscais do cliente informado
Static Function FechaPsq()

   xFilial := aCabeca[oCabeca:nAt,01]
   cNota   := aCabeca[oCabeca:nAt,03]
   cSerie  := aCabeca[oCabeca:nAt,04]
   
   oDlgN:End()   

   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()

   BSCFILIAL(xFilial)
   
   BSCNOTA1(xFilial, cNota, cSerie, cCliente, cLoja, 2)

Return(.T.)

// Função que pesquisa as notas fiscais do cliente informado
Static Function mstproduto(_Filial, _Nota, _Serie, _Cliente, _Loja, _Tipo)

   Local cSql 

   aDetalhe := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_FILIAL ," + chr(13)
   cSql += "       A.D2_CLIENTE," + chr(13)
   cSql += "       A.D2_LOJA   ," + chr(13)
   cSql += "       A.D2_DOC    ," + chr(13)
   cSql += "       A.D2_SERIE  ," + chr(13)
   cSql += "       A.D2_ITEM   ," + chr(13)
   cSql += "       A.D2_COD    ," + chr(13)
   cSql += "       B.B1_DESC   ," + chr(13)
   cSql += "       A.D2_UM     ," + chr(13)
   cSql += "       A.D2_QUANT  ," + chr(13)
   cSql += "       A.D2_PRCVEN ," + chr(13)
   cSql += "       A.D2_TOTAL   " + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " B  " + chr(13)
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(_Filial)  + "'" + chr(13)
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(_Cliente) + "'" + chr(13)
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(_Loja)    + "'" + chr(13)
   cSql += "   AND A.D2_DOC     = '" + Alltrim(_Nota)    + "'" + chr(13)
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(_Serie)   + "'" + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"       + chr(13)
   cSql += "   AND A.D2_COD     = B.B1_COD" + chr(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"       + chr(13)
   cSql += " ORDER BY A.D2_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   If T_DETALHE->( EOF() )
      aAdd( aDetalhe, { "","","","","","","" })
   Else
      WHILE !T_DETALHE->( EOF() )
         aAdd( aDetalhe, { T_DETALHE->D2_ITEM  ,;
                           T_DETALHE->D2_COD   ,;
                           T_DETALHE->B1_DESC  ,;
                           T_DETALHE->D2_UM    ,;
                           T_DETALHE->D2_QUANT ,;
                           T_DETALHE->D2_PRCVEN,;
                           T_DETALHE->D2_TOTAL })
         T_DETALHE->( DbSkip() )
      ENDDO
   Endif

   oDetalhe:SetArray( aDetalhe )
   oDetalhe:bLine := {||     {aDetalhe[oDetalhe:nAt,01],;
          		    		  aDetalhe[oDetalhe:nAt,02],;
          		    		  aDetalhe[oDetalhe:nAt,03],;
          		    		  aDetalhe[oDetalhe:nAt,04],;
          		    		  aDetalhe[oDetalhe:nAt,05],;
          		    		  aDetalhe[oDetalhe:nAt,06],;
          		    		  aDetalhe[oDetalhe:nAt,07]}}
   oDetalhe:Refresh()
   
Return(.T.)

// Função que pesquisa os nºs de séries a serem devolvidos para o produto selecionado
Static Function BscNrSerie(_Marca, _Cliente, _Loja, _Filial, _Nota, _Serie, _Produto)

   Private oDlgS

   Private aSeries := {}
   Private oSeries
   Private oOk     := LoadBitmap( GetResources(), "LBOK" )
   Private oNo     := LoadBitmap( GetResources(), "LBNO" )

   If _Marca == .F.
      MsgAlert("Atenção! Produto não foi marcado para ser utilizado na RMA.")
      Return(.T.)
   Endif   

   If Select("T_SERIES") > 0
      T_SERIES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DB_NUMSERI"
   cSql += "  FROM " + RetSqlName("SDB")
   cSql += " WHERE DB_FILIAL  = '" + Alltrim(_Filial)  + "'"
   cSql += "   AND DB_PRODUTO = '" + Alltrim(_Produto) + "'"
   cSql += "   AND DB_DOC     = '" + Alltrim(_Nota)    + "'"
   cSql += "   AND DB_SERIE   = '" + Alltrim(_Serie)   + "'"
   cSql += "   AND DB_CLIFOR  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND DB_LOJA    = '" + Alltrim(_Loja)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''
   cSql += " ORDER BY DB_NUMSERI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

   If T_SERIES->( EOF() )
      aAdd( aSeries, { .F., "" } )
   Else
      T_SERIES->( DbGoTop() )
      WHILE !T_SERIES->( EOF() )
         aAdd( aSeries, { .F.                  ,;
                          T_SERIES->DB_NUMSERI ,;
                          _Cliente             ,;
                          _Loja                ,;
                          _Filial              ,;
                          _Nota                ,;
                          _Serie               ,;
                          _Produto             })
         T_SERIES->( DbSkip() )
      ENDDO
   Endif

   // Posiciona no array aNumSerie para marcar os nºs de séries que já foram marcados anteriormente
   For nContar = 1 to Len(aSeries)

       For nProcura = 1 to Len(aNumSerie)

           If aNumSerie[nProcura,01] == _Cliente .And. ;
              aNumSerie[nProcura,02] == _Loja    .And. ;
              aNumSerie[nProcura,03] == _Filial  .And. ;
              aNumSerie[nProcura,04] == _Nota    .And. ;
              aNumSerie[nProcura,05] == _Serie   .And. ;
              aNumSerie[nProcura,06] == _Produto .And. ;
              aNumSerie[nProcura,07] == aSeries[nContar,02]
              aSeries[nContar,01] := aNumSerie[nProcura,08] 
              Exit
           Endif

       Next nProcura
          
   Next nContar    

   DEFINE MSDIALOG oDlgS TITLE "Nºs de Séries" FROM C(178),C(181) TO C(534),C(450) PIXEL

   @ C(005),C(005) Say "Indique os nº de Séries a serem devolvidos" Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

   @ C(162),C(005) Button "Marca Todos"    Size C(037),C(012) PIXEL OF oDlgS ACTION(MrcSerie(1))
   @ C(162),C(044) Button "Desmarca Todos" Size C(045),C(012) PIXEL OF oDlgS ACTION(MrcSerie(2))
   @ C(162),C(091) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgS ACTION( FechaNrSerie(_Cliente, _Loja, _Filial, _Nota, _Serie, _Produto) )

   // Cria Componentes Padroes do Sistema
   @ 015,005 LISTBOX oSeries FIELDS HEADER "", "Nºs de Séries" PIXEL SIZE 160,188 OF oDlgS ;
                            ON dblClick(aSeries[oSeries:nAt,1] := !aSeries[oSeries:nAt,1],oSeries:Refresh())     
   oSeries:SetArray( aSeries )
   oSeries:bLine := {||     {Iif(aSeries[oSeries:nAt,01],oOk,oNo),;
       	        	             aSeries[oSeries:nAt,02]}}

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)

// Função que marca e desmarca os nºs de séries
Static Function MrcSerie(_Tipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aSeries)
       aSeries[nContar,01] := IIF(_Tipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)       

// Função que carrega o array aNumSerie e fecha a janela de nºs de séries
Static Function FechaNrSerie(_Cliente, _Loja, _Filial, _Nota, _Serie, _Produto)
   
   Local nContar  := 0
   Local bProcura := 0
   Local _NumeroS := ""

   Private aTransito := {}
   
   // Grava os nº de séries do array aNumSerie
   lExiste := .F.

   For nContar = 1 to Len(aSeries)

       For nProcura = 1 to Len(aNumSerie)

           If Alltrim(aNumSerie[nProcura,01]) == Alltrim(_Cliente)            .And. ;
              Alltrim(aNumSerie[nProcura,02]) == Alltrim(_Loja)               .And. ;
              Alltrim(aNumSerie[nProcura,03]) == Alltrim(_Filial)             .And. ;
              Alltrim(aNumSerie[nProcura,04]) == Alltrim(_Nota)               .And. ;
              Alltrim(aNumSerie[nProcura,05]) == Alltrim(_Serie)              .And. ;
              Alltrim(aNumSerie[nProcura,06]) == Alltrim(_Produto)            .And. ;
              Alltrim(aNumSerie[nProcura,07]) == Alltrim(aSeries[nContar,02])
              aNumSerie[nProcura,08]          := aSeries[nContar,01]
              lExiste := .T.
              Exit
           Endif

       Next nProcura
       
       If lExiste == .F.
          aAdd( aNumSerie, { _Cliente           ,;
                             _Loja              ,;
                             _Filial            ,;
                             _Nota              ,;
                             _Serie             ,;
                             _Produto           ,;
                             aSeries[nContar,02],;
                             aSeries[nContar,01]})
                             
       Endif

       lExiste := .F.
       
   Next nContar    

   oDlgS:End()
   
Return(.T.)

// Função que envoia o e-mail ao Cliente
Static Function MandaEmailCli(_RMA, _ANO, _Vendedor, _Status)

   Local cTexto    := ""
   Local _TCredito := ""
   Local _Ncredito := ""
   Local _Scredito := ""
   Local _nErro    := 0

   If _Status <> '2' .And. _Status <> '6' .And. _Status <> '5'
      MsgAlert("Impressão da RMA não permitida para este Status.")
      Return(.T.)
   Endif

//   If _Status == '2'
//      If Substr(_Vendedor,01,06) <> __Cuserid
//         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "A primeira impressão da RMA somente poderá ser realizada pelo vendedor que a incluiu.")
//         Return(.T.)
//      Endif
//   Endif

   // Envia para o programa de emissão do formulário de RMA
   U_AUTOM220(_RMA, _ANO)
                         
   If Select("T_IMPRESSA") > 0
      T_IMPRESSA->( dbCloseArea() )
   EndIf
  
   cSql := ""
   cSql += "SELECT ZS4_IMPR"
   cSql += "  FROM " + RetSqlName("ZS4")
   cSql += " WHERE ZS4_NRMA   = '" + Alltrim(_RMA) + "'"
   cSql += "   AND ZS4_ANO    = '" + Alltrim(_ANO) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IMPRESSA", .T., .T. )

   If Alltrim(T_IMPRESSA->ZS4_IMPR) <> ''
      Return(.T.)
   Endif

   // Altera o Status da RMA
   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZS4")
   cSql += "   SET "
   cSql += "   ZS4_STAT = '6',"
   cSql += "   ZS4_IMPR = 'X' "
   cSql += " WHERE ZS4_NRMA = '" + Alltrim(_RMA) + "'"
   cSql += "   AND ZS4_ANO  = '" + Alltrim(_ANO) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   PsqGridDados(0, Substr(_Vendedor,01,06), "0")

   RETURN(.T.)
   
   // Temporariamente suspenso o envio de e-mail

   If Empty(Alltrim(_RMA))
      Return(.T.)
   Endif
      
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf
  
   cSql := ""
   cSql += "SELECT A.ZS4_NRMA,"
   cSql += "       A.ZS4_ANO ,"
   cSql += "       A.ZS4_STAT,"
   cSql += "       A.ZS4_ABER,"
   cSql += "       A.ZS4_HORA,"
   cSql += "       A.ZS4_CLIE,"
   cSql += "       A.ZS4_LOJA,"
   cSql += "       A.ZS4_TELE,"
   cSql += "       A.ZS4_EMAI,"
   cSql += "       A.ZS4_NFIL,"
   cSql += "       A.ZS4_NOTA,"
   cSql += "       A.ZS4_SERI,"
   cSql += "       A.ZS4_CRED,"
   cSql += "       A.ZS4_CREF,"
   cSql += "       A.ZS4_CREN,"
   cSql += "       A.ZS4_CRES,"
   cSql += "       B.A1_NOME ,"
   cSql += "       A.ZS4_VEND,"
   cSql += "       C.A3_NOME ,"
   cSql += "       A.ZS4_DLIB,"
   cSql += "       A.ZS4_HLIB,"
   cSql += "       A.ZS4_APRO,"
   cSql += "       A.ZS4_CONT,"
   cSql += "       A.ZS4_CHEK,"
   cSql += "       A.ZS4_ITEM,"
   cSql += "       A.ZS4_PROD,"
   cSql += "       A.ZS4_QUAN,"
   cSql += "       A.ZS4_UNIT,"
   cSql += "       A.ZS4_TOTA,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_MOTI)) AS MOTIVO,"
   cSql += "       D.U5_CONTAT,"
   cSql += "       E.B1_DESC  ,"
   cSql += "       E.B1_DAUX  ,"
   cSql += "       ISNULL(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)), '') AS SERIES, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_CONS)) AS OBSERVACAO "
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C, "
   cSql += "       " + RetSqlName("SU5") + " D, "
   cSql += "       " + RetSqlName("SB1") + " E  "
   cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND A.ZS4_NRMA   = '" + Alltrim(_RMA) + "'"
   cSql += "   AND A.ZS4_ANO    = '" + Alltrim(_ANO) + "'"
   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_CONT   = D.U5_CODCONT"
   cSql += "   AND D.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_PROD   = E.B1_COD "
   cSql += "   AND E.D_E_L_E_T_ = ''       "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Reutnr(.T.)
   Endif
   
   // Verifica o Status da RMA
   Do Case
      Case T_DADOS->ZS4_STAT == "1"
           MsgAlert("RMA aguardando aprovação. Envio de informação ao Cliente não autorizada.")
           Return(.T.)
      Case T_DADOS->ZS4_STAT == "8"
           MsgAlert("RMA aguardando revisão. Envio de informação ao Cliente não autorizada.")
           Return(.T.)
      Case T_DADOS->ZS4_STAT == "7"
           MsgAlert("RMA Recusada. Envio de informação ao Cliente não autorizada.")
           Return(.T.)

      Case T_DADOS->ZS4_STAT == "6"
 		   If MsgYesNo("Informação de dados da RMA já enviada ao Cliente. Deseja enviar os dados novamente?")
 		   Else
              Return(.T.)
           Endif
      Case T_DADOS->ZS4_STAT == "5"
           MsgAlert("RMA já encerrada. Envio de informação ao Cliente não autorizada.")
           Return(.T.)
   EndCase           

   If Empty(Alltrim(T_DADOS->ZS4_EMAI))
      MsgAlert("Email de contato do cliente para envio inexistente.")
      Return(.T.)
   Endif

   // Elabora o texto para envio do e-mail
   cTexto := ""
   cTexto := "Prezado Cliente:" + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "Viemos lhe informar os dados de sua RMA - Solicitação de Devolução de Mercadoria(s) adquirida(s) junto a Automatech Sistema de Automação Ltda." + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Salientamos que o nº desta solicitação deverá constar em sua Nota Fiscal de Devolução. A falta desta implicará no recebimento da(s) mercadoria(s)." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "RMA Nº..: " + Alltrim(_RMA) + "/" + Alltrim(_ANO) + chr(13) + chr(10)
   cTexto += "Data: " + Substr(T_DADOS->ZS4_ABER,07,02) + "/" + Substr(T_DADOS->ZS4_ABER,05,02) + "/" + Substr(T_DADOS->ZS4_ABER,01,04) + chr(13) + chr(10)
   cTexto += "Hora: " + T_DADOS->ZS4_HORA + chr(13) + chr(10)
   cTexto += "Vendedor: " + Alltrim(T_DADOS->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "DADOS DO CLIENTE" + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Razão Social: " + Alltrim(A1_NOME) + chr(13) + chr(10)
   cTexto += "Contato: " + Alltrim(T_DADOS->U5_CONTAT) + chr(13) + chr(10)
   cTexto += "Telefone: " + Alltrim(T_DADOS->ZS4_TELE) + chr(13) + chr(10)
   cTexto += "E-Mail: " + Alltrim(T_DADOS->ZS4_EMAI) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "NOTA FISCAL DE VENDA Nº " + Alltrim(T_DADOS->ZS4_NOTA) + " - Série: " + Alltrim(T_DADOS->ZS4_SERI) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "MOTIVO DA DEVOLUÇÃO DA(S) MERCADORIA(S)" + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += Alltrim(T_DADOS->MOTIVO) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "PRODUTOS A SEREM DEVOLVIDOS" + chr(13) + chr(10) + chr(13) + chr(10)

   T_DADOS->( EOF() )

   _TCredito := T_DADOS->ZS4_CRED
   _Ncredito := T_DADOS->ZS4_CREN
   _Scredito := T_DADOS->ZS4_CRES
   
   WHILE !T_DADOS->( EOF() )

      If T_DADOS->ZS4_CHEK == "0"
         T_DADOS->( DbSkip() )         
         Loop
      Endif

      cTexto += "Descrição do Produto: " + Alltrim(T_DADOS->B1_DESC) + " " + Alltrim(T_DADOS->B1_DAUX) + chr(13) + chr(10)
  
      If Empty(Alltrim(T_DADOS->SERIES))
      Else
         cTexto += "Nºs de Série(s): "
         For nContar = 1 to U_P_OCCURS(T_DADOS->SERIES, "|", 1)      
             cTexto += U_P_CORTA(T_DADOS->SERIES, "|", nContar) + ", "
         Next nContar
      Endif

      cTexto += chr(13) + chr(10) + chr(13) + chr(10)
         
      T_DADOS->( DbSkip() )

   ENDDO   

   Do Case
      Case _Tcredito == "01"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: ENCONTRO COM NOTA FISCAL ORIGINAL" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "02"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: ENCONTRO COM NOVA NOTA FISCAL" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "03"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: ENCONTRO COM OUTRA NF (NF Nº " + _Ncredito + " SÉRIE: " + _Scredito + ")" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "04"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: CLIENTE FICOU COM CRÉDITO JUNTO A AUTOMATECH" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "05"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: CLIENTE VAI RECEBER EM ESPÉCIE" + chr(13) + chr(10) + chr(13) + chr(10)
   EndCase

   cTexto += "CONDIÇÕES GERAIS DE TROCA DA(S) MERCADORIA(S)" + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "1. Somente serão aceitas trocas de produtos em suas embalagens originais, com, todos os acessórios e sem uso." + chr(13) + chr(10)
   cTexto += "2. O Produto deve estar em perfeitas condições de venda. Na eventual devolução de um produto fora deste estado (faltando" + chr(13) + chr(10)
   cTexto += "algum acessório, com vestígios de uso, etc.), será cobrado do Cliente o valor devido para colocá-lo em condições de venda." + chr(13) + chr(10)
   cTexto += "3. O prazo para devolução de produtos para a Automatech Sistema de automação Ltda é de 10 dias, contados a partir da data" + chr(13) + chr(10)
   cTexto += "do recebimento da mercadoria pelo Cliente." + chr(13) + chr(10)
   cTexto += "4. Desde que a devolução não seja motivada por um equívoco da Automatech Sistemas de Automação Ltda todos os fretes envolvidos" + chr(13) + chr(10)
   cTexto += "correm por conta do Cliente." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "PROCEDIMENTO DE TROCA" + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "1. Encaminhar cópía da nota fiscal de devolução por e-mail para a área de estoque da Automatech Sistemas de Automação Ltda para" + chr(13) + chr(10)
   cTexto += "o endereço (estoque01@automatech.com.br). Deve conter na nota o nº da NF de Venda e da RMA. Em Caso de pessoa física ou Empresa" + chr(13) + chr(10)
   cTexto += "que não possua inscrição estadual, não é necessária nota fiscal de devolução. A Automatech fará a nota fiscal de entrada." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "2. Encaminhar o equipamento para a Automatech conforme instruções da área de estoque." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "3. Após o equipamento ser recebido, este será inspecionado (estado geral, embalagem e acessórios) e se tudo estiver de acordo" + chr(13) + chr(10)
   cTexto += "com as condições gerais de troca de mercadorias o valor do equipamento será creditado para aquisiçãode um novo produto." + chr(13) + chr(10)
   cTexto += "Será devolvido o valor da compra em dinhiero somente se o produto for devolvido em até 7 dias depois do faturamento." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "OBS: NÃO SERÁ REALIZADO A ENTRADA DA DEVOLUÇÃO SEM QUE A RMA TENHA SIDO APROVADA, VISTO QUE SERÁ LEVADO EM CONSIDERAÇÃO TODAS" + chr(13) + chr(10)
   cTexto += "AS EXIGÊNCIAS ACIMA." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "Att." + chr(13) + chr(10) + chr(13) + chr(10)
   
   cTexto += "Automatech Sistemas de Automação Ltda" + chr(13) + chr(10)
   cTexto += "Departamento de Estoque" + chr(13) + chr(10)

   U_AUTOMR20(cTexto, 'harald@automatech.com.br', "", "Informações de RMA" )

   // Altera o Status da RMA
   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZS4")
   cSql += "   SET "
   cSql += "   ZS4_STAT = '6'"
   cSql += " WHERE ZS4_NRMA = '" + Alltrim(_RMA) + "'"
   cSql += "   AND ZS4_ANO  = '" + Alltrim(_ANO) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   PsqGridDados(0, Substr(_Vendedor,01,06), "0")
   
Return(.T.)

// Função que permite que a quantidade do produto selecionado seja alterada
Static Function AlteQuant(_Item, _Codigo , _Descricao, _Qtd, _Unitario, _Total, _Marca)

   Local lChumba       := .F.

   Private xProduto    := Alltrim(_Item) + "." + Alltrim(_Codigo) + Alltrim(_Descricao)
   Private xVerificar  := _Qtd
   Private xQuantidade := _Qtd
   Private xUnitario   := _Unitario
   Private xTotal      := _Total

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgQ

   If yTipo == 1
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Alteração de quantidade não permitida pois o tipo de RMA informada" + chr(13) + chr(10) + ;
               "é do tipo devolução total.")
      Return(.T.)
   Endif   

   If _Marca == .F.
      MsgAlert("Atenção! Produto não foi marcado para ter sua quantidade alterada.")
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlgQ TITLE "Alteração de Quantidade " FROM C(178),C(181) TO C(324),C(521) PIXEL

   @ C(005),C(005) Say "Produto"    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   @ C(026),C(005) Say "Quantidade" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   @ C(026),C(053) Say "Unitário"   Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   @ C(026),C(114) Say "Total"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ

   @ C(013),C(005) MsGet oGet1 Var xProduto    When lChumba Size C(159),C(009) COLOR CLR_BLACK Picture "@!"                  PIXEL OF oDlgQ
   @ C(036),C(005) MsGet oGet2 Var xQuantidade              Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999999.99"      PIXEL OF oDlgQ VALID(CALNPRECO(xQuantidade, xUnitario, _Item, _Codigo))
   @ C(036),C(053) MsGet oGet3 Var xUnitario   When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.9999" PIXEL OF oDlgQ
   @ C(036),C(114) MsGet oGet4 Var xTotal      When lChumba Size C(049),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.9999" PIXEL OF oDlgQ

   @ C(053),C(046) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgQ ACTION( CFMQTD(xProduto, xQuantidade, xUnitario, xTotal) )
   @ C(053),C(085) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgQ ACTION( oDlgQ:End() )

   ACTIVATE MSDIALOG oDlgQ CENTERED 

Return(.T.)

// Função que calcula o valor total
Static Function CALNPRECO(_xQuantidade, _xUnitario, _Item, _Codigo)

   Local cSql    := ""
   Local nSaldo  := 0

   xTotal := xQuantidade * xUnitario
   oGet4:Refresh()

   // Calcula o Saldo do Produto selecionado
   If Select("T_QTDORIGEM") > 0
      T_QTDORIGEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_ITEM  ,"
   cSql += "       A.D2_COD   ,"
   cSql += "       RTRIM(B.B1_DESC) + ' ' + RTRIM(B.B1_DAUX) AS DESCRICAO,"
   cSql += "       A.D2_QUANT ,"
   cSql += "       A.D2_PRCVEN,"
   cSql += "       A.D2_TOTAL  "
   cSql += "  FROM " + RetSqlName("SD2") + " A, " 
   cSql += "       " + RetSqlName("SB1") + " B  " 
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(xFilial) + "'"
   cSql += "   AND A.D2_DOC     = '" + Alltrim(cNota)   + "'"
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(cSerie)  + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''
   cSql += "   AND A.D2_COD     = B.B1_COD
   cSql += "   AND B.D_E_L_E_T_ = ''
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(cCliente) + "'"
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND A.D2_COD     = '" + Alltrim(_Codigo)  + "'"
   cSql += "   AND A.D2_ITEM    = '" + Alltrim(_Item)    + "'"
   cSql += " ORDER BY A.D2_ITEM 
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QTDORIGEM", .T., .T. )
   
   If T_QTDORIGEM->( EOF() )
      MSGALERT("Erro na pesquisa da quantidade original so produto. Entre em contato com a área de desenvolvimento para análise.")
      Return(.T.)
   Endif

   nSaldo := T_QTDORIGEM->D2_QUANT      
   
   // Pesquisa as RMA's já efetivadas para o Produto/Item
   If Select("T_CONSUMO") > 0
      T_CONSUMO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZS4_QUAN"
   cSql += "  FROM " + RetSqlName("ZS4")
   cSql += " WHERE ZS4_CLIE   = '" + Alltrim(cCliente) + "'"
   cSql += "   AND ZS4_LOJA   = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND ZS4_NFIL   = '" + Alltrim(xFilial)  + "'"
   cSql += "   AND ZS4_NOTA   = '" + Alltrim(cNota)    + "'"
   cSql += "   AND ZS4_SERI   = '" + Alltrim(cSerie)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += "   AND ZS4_PROD   = '" + Alltrim(_Codigo)  + "'"
   cSql += "   AND ZS4_ITEM   = '" + Alltrim(_Item)    + "'"

   If cNRMA <> ""
      cSql += " AND ZS4_NRMA <> '" + Alltrim(cNRMA) + "'"
      cSql += " AND ZS4_ANO  <> '" + Alltrim(cARMA) + "'"
   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSUMO", .T., .T. )

   If T_CONSUMO->( EOF() )
      nSaldo := nSaldo - 0
   Else
      nSaldo := nSaldo - T_CONSUMO->ZS4_QUAN
   Endif
      
   If xQuantidade >= nSaldo      
      MsgAlert("Atenção! Quantidade informada é maior que o saldo disponíovel do produto para utilização em RMA. Verifique!")
      oDlgQ:End()
      Return(.T.)                                                 
   Endif

   xTotal := nSaldo * xUnitario

   oGet4:Refresh() 
   
Return(.T.)

// Função que altera a quantidade do produto
Static Function CFMQTD(yProduto, yQuantidade, yUnitario, yTotal)

   aProdutos[oProdutos:nAt,05] := yQuantidade
   aProdutos[oProdutos:nAt,06] := yUnitario
   aProdutos[oProdutos:nAt,07] := yQuantidade * yUnitario

   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
             		    		   aProdutos[oProdutos:nAt,02],;
         	         	           aProdutos[oProdutos:nAt,03],;
         	         	           aProdutos[oProdutos:nAt,04],;
         	         	           aProdutos[oProdutos:nAt,05],;
         	         	           aProdutos[oProdutos:nAt,06],;         	         	                    	         	           
         	        	           aProdutos[oProdutos:nAt,07]}}

   oDlgQ:End()

Return(.T.)

// Função que Imprime a Danfe do registro selecionado
Static Function IMPDANFE(cFil)

   Private aFilBrw := {"SF2","F2_FILIAL=='"+ cFil +"'.And.F2_SERIE=='"+ SubStr( cFil, 2 ) +"'"}
   
   SPEDDANFE()
   
Return(.T.)
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaRMA  ºAutor  ³Michel Aoki         º Data ³  10/17/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona o cursor na RMA digitada                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BuscaRma(_cNumRMA)

Local _nPosRMA := aScan(oBrowse:aHeaders,"RMA")  
Local _nPosReg := 0     

If _nPosRMA > 0
     _nPosReg := aScan( oBrowse:aArray, { | x | AllTrim( x[ _nPosRMA ] ) == Alltrim(_cNumRMA)} )  
     If _nPosReg > 0
	     oBrowse:nAt := _nPosReg  
	     oBrowse:Refresh()
     EndIf
EndIf

Return


// Função que Ordena a coluna selecionada no grid
Static Function Ordenar(_nPosCol,_aOrdena)
Local _nPosData := aScan(oBrowse:aHeaders,"Data")  

   If _nPosCol <> 1
      If _nPosData   ==_nPosCol
	      _aOrdena := ASort (_aOrdena,,,{|x,y| Dtos(ctod(x[_nPosCol])) < Dtos(ctod(y[_nPosCol]))  }) // Ordenando Arrays
	  Else
	      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
	  EndIf    
   Endif   

Return(_aOrdena)
