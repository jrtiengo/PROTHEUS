#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM134.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 15/11/2012                                                          *
// Objetivo..: Programa que visualiza dados do embarque do pedido (Call Center)    *
// Parâmetro.: Filial, Nº do Pedido                                                * 
//**********************************************************************************

User Function AUTOM134(_Filial, _Pedido)

   Local lChumba       := .F.
   Local cSql          := ""

   Private __Filial    := _Filial
   Private __Pedido    := _Pedido

   Private cBruto	   := Space(25)
   Private cLiquido    := Space(25)
   Private cVolumes    := 0
   Private cEspecie    := Space(25)
   Private cTipo	   := Space(25)
   Private cTranspo    := Space(25)
   Private cNtranspo   := Space(25)
   Private cExpedido   := Space(25)
   Private cHoras      := Space(25)
   Private cNota       := Space(10)
   Private cDataFat    := Space(10)
   Private cQuanti     := 0
   Private ctexto	   := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oMemo1

   Private aBrowse := {}

   If Empty(Alltrim(_Pedido))
      Return .T.
   Endif   

   // Carrega o campo memo com as informações do pedido
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UA_FILIAL , "
   cSql += "       A.UA_NUM    , "
   cSql += "       A.UA_EMISSAO, "
   cSql += "       A.UA_CLIENTE, "
   cSql += "       A.UA_LOJA   , "
   cSql += "       A.UA_EMISNF , "
   cSql += "       A.UA_DOC    , "
   cSql += "       B.A1_NOME   , "
   cSql += "       B.A1_CGC    , "
   cSql += "       B.A1_INSCR    "
   cSql += "  FROM " + RetSqlName("SUA") + " A, " + RetSqlName("SA1") + " B "
   cSql += " WHERE A.UA_NUM     = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.UA_FILIAL  = '" + Alltrim(_Filial) + "'"
   cSql += "   AND A.UA_CLIENTE = B.A1_COD "
   cSql += "   AND A.UA_LOJA    = B.A1_LOJA"
   cSql += "   AND B.D_E_L_E_T_ = ''       "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   cNota    := T_DADOS->UA_DOC
   cDataFat := Substr(T_DADOS->UA_EMISNF,07,02) + "/" + Substr(T_DADOS->UA_EMISNF,05,02) + "/" + Substr(T_DADOS->UA_EMISNF,01,04)

   cTexto   := ""
   cTexto   := cTexto + "Nº Pedido: " + Alltrim(_Pedido) + " em " + ;
               Substr(T_DADOS->UA_EMISSAO,07,02) + "/"   + ;
               Substr(T_DADOS->UA_EMISSAO,05,02) + "/"   + ;
               Substr(T_DADOS->UA_EMISSAO,01,04) + chr(13) + chr(10) + ;
               "Cliente: " + T_DADOS->UA_CLIENTE + "." + T_DADOS->UA_LOJA + " - " + ;
               Alltrim(T_DADOS->A1_NOME) + chr(13) + chr(10) + ;
               "CNPJ/IE: " + Alltrim(T_DADOS->A1_CGC) + " / " + Alltrim(T_DADOS->A1_INSCR)

   // Carrega o grid com os produtos do pedido passado no parâmetro
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UB_FILIAL ,"
   cSql += "       A.UB_PRODUTO,"
   cSql += "       A.UB_NUMPV  ,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX   ,"
   cSql += "       A.UB_QUANT   "
   cSql += "  FROM " + RetSqlName("SUB") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.UB_NUM     = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND A.UB_FILIAL  = '" + Alltrim(_Filial) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.UB_PRODUTO = B.B1_COD"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   aBrowse := {}   
   DO WHILE !T_PRODUTOS->( EOF() )
      aAdd(aBrowse, { T_PRODUTOS->UB_PRODUTO, Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),;
                      T_PRODUTOS->UB_NUMPV  ,;
                      T_PRODUTOS->UB_QUANT} )
      T_PRODUTOS->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { '','', '' })
   Endif

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Consulta Volumes" FROM C(178),C(181) TO C(506),C(600) PIXEL

   @ C(043),C(005) Say "Produtos do Pedido" Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(094),C(005) Say "Peso Bruto"         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(094),C(111) Say "Volumes"            Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(094),C(138) Say "Espécie"            Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(094),C(178) Say "Tipo Frete"         Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(095),C(057) Say "Peso Líquido"       Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(116),C(005) Say "Transportadora"     Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(138),C(005) Say "Expedido em"        Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(138),C(052) Say "Horas"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(138),C(086) Say "N.Fiscal"           Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(138),C(122) Say "Data Fat."          Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(116),C(179) Say "Qtd PV"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(043),C(106) Say "Duplo-Click, visualiza detalhes do produto" Size C(099),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(005),C(005) GET   oMemo1 Var cTexto MEMO When lChumba Size C(199),C(035) PIXEL OF oDlg 
   @ C(104),C(005) MsGet oGet1  Var cBruto      When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(104),C(057) MsGet oGet2  Var cLiquido    When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(104),C(111) MsGet oGet13 Var cVolumes    When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(104),C(138) MsGet oGet3  Var cEspecie    When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(104),C(179) MsGet oGet7  Var cTipo       When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(126),C(005) MsGet oGet4  Var cTranspo    When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(126),C(032) MsGet oGet6  Var cNtranspo   When lChumba Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(148),C(005) MsGet oGet8  Var cExpedido   When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(148),C(052) MsGet oGet9  Var cHoras      When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(148),C(086) MsGet oGet10 Var cNota       When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(148),C(122) MsGet oGet11 Var cDataFat    When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(126),C(179) MsGet oGet12 Var cQuanti     When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(146),C(167) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg  ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 065 , 005, 255, 050,,{'Código', 'Descrição dos Produtos', 'Nº Pedido'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]} }

   oBrowse:bLDblClick := {|| MOSTRAVOL(aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) } 

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Sub-Função que mostra os detalhes dos volumes da nota fiscal do pedido selecionado
Static Function MOSTRAVOL(_Codigo, _Qtd)

   Local cSql := ""           

   If Select("T_VOLUMES") > 0
      T_VOLUMES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C6_NOTA   ,"
   cSql += "       A.C6_SERIE  ,"
   cSql += "       B.F2_PBRUTO ,"
   cSql += "       B.F2_PLIQUI ,"
   cSql += "       B.F2_ESPECI1,"
   cSql += "       B.F2_VOLUME1,"
   cSql += "       B.F2_TRANSP ,"
   cSql += "       B.F2_TPFRETE,"
   cSql += "       B.F2_CONHECI,"
   cSql += "       B.F2_HREXPED "
   cSql += "  FROM " + RetSqlName("SC6") + " A, "
   cSql += "       " + RetSqlName("SF2") + " B  "
   cSql += " WHERE A.C6_NUM     = '" + Alltrim(_Codigo)  + "'"
   cSql += "   AND A.C6_FILIAL  = '" + Alltrim(__Filial) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"       
   cSql += "   AND B.F2_FILIAL  = A.C6_FILIAL"
   cSql += "   AND B.F2_DOC     = A.C6_NOTA  "
   cSql += "   AND B.F2_SERIE   = A.C6_SERIE "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VOLUMES", .T., .T. )

   If T_VOLUMES->( EOF() )
      cBruto	:= Space(25)
      cLiquido  := Space(25)
      cEspecie  := Space(25)
      cTipo	    := Space(25)
      cTranspo  := Space(25)
      cNtranspo := Space(25)
      cExpedido := Space(25)
      cHoras    := Space(25)
      cQuanti   := 0
      ctexto	:= ""
      cVolumes  := 0

      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()
      oGet4:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()
      oGet8:Refresh()
      oGet9:Refresh()
      oGet12:Refresh()
      oMemo1:Refresh()

      Return .T.
   Endif
      
   cBruto	 := T_VOLUMES->F2_PBRUTO
   cLiquido  := T_VOLUMES->F2_PLIQUI
   cEspecie  := T_VOLUMES->F2_ESPECI1
   cTipo	 := IIF(T_VOLUMES->F2_TPFRETE == "F", "FOB", "CIF")
   cTranspo  := T_VOLUMES->F2_TRANSP
   cExpedido := T_VOLUMES->F2_CONHECI
   cHoras    := T_VOLUMES->F2_HREXPED
   cQuanti   := _Qtd
   cVolumes  := T_VOLUMES->F2_VOLUME1

   // Pesquisa a Transportadora
   If !Empty(Alltrim(cTranspo))

      If Select("T_FRETE") > 0
         T_FRETE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A4_COD , "
      cSql += "       A4_NOME  "
      cSql += "  FROM " + RetSqlName("SA4")
      cSql += " WHERE A4_COD     = '" + alltrim(cTranspo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"       

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FRETE", .T., .T. )
      
      cNtranspo := T_FRETE->A4_NOME
   
   Else
   
      cNtranspo := Space(40)
   
   Endif

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet12:Refresh()
   oGet13:Refresh()
   oMemo1:Refresh()

Return .T.