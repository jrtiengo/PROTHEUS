#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM112.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/05/2012                                                          *
// Objetivo..: Programa que permite ao usuário do financeiro informar através de   *
//             leitura do codigo de barras do bloqueto bancário de cobrança,  os   *
//             dados para elaboração do CNAB de Pagamentos.                        *
//**********************************************************************************

User Function AUTOM112()

   Local   lChumbado := .F.

   Private cNota	 := Space(10)
   Private cSerie	 := Space(03)
   Private cForne	 := Space(06)
   Private cLoja	 := Space(03)
   Private cNome	 := Space(40)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlg

   U_AUTOM628("AUTOM112")

   DEFINE MSDIALOG oDlg TITLE "Informação Código de Barras Títulos Contas a Pagar" FROM C(178),C(181) TO C(322),C(663) PIXEL

   @ C(007),C(007) Say "Nota Fiscal" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(022),C(007) Say "Série"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(008) Say "Fornecedor"  Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(006),C(040) MsGet oGet1 Var cNota                 Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(021),C(040) MsGet oGet2 Var cSerie                Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(040) MsGet oGet3 Var cForne F3("SA2")      Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(068) MsGet oGet4 Var cLoja                 Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TRAZXCLIENTE(cForne, cloja))
   @ C(037),C(090) MsGet oGet5 Var cNome  When lChumbado Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(053),C(085) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION ( PesqBarras() )
   @ C(053),C(125) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return (.T.)     

// Função que pesquisa o fornecedor informado
Static Function TrazXCliente( _Fornece, _Loja )

   Local cSql := ""
   
   If Empty(Alltrim(_Fornece))
      cNome := ""
      Return .T.
   Endif

   If Select("T_FORNECEDOR") > 0
   	  T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT A2_COD , "
   cSql += "       A2_LOJA, " 
   cSql += "       A2_NOME  "
   cSql += "  FROM " + RetSqlName("SA2010")
   cSql += " WHERE A2_COD  = '" + Alltrim(_Fornece) + "'"
   cSql += "   AND A2_LOJA = '" + Alltrim(_Loja)    + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )
	
    If !T_FORNECEDOR->( EOF() )
       cForne := T_FORNECEDOR->A2_COD
       cLoja  := T_FORNECEDOR->A2_LOJA
       cNome  := Alltrim(T_FORNECEDOR->A2_NOME)
    Else
       MsgAlert("Fornecedor informado não cadastrado.")
       cForne := Space(06)
       cLoja  := Space(03)
       cNome  := ""
    Endif

    If Select("T_FORNECEDOR") > 0
   	   T_FORNECEDOR->( dbCloseArea() )
    EndIf

Return .T.

// Função que pesquisa os dados dos títulos para os dados informados
Static Function PesqBarras()

   Local cSql     := ""
   Local lChumba  := .F.
 
   Private xNota  := Space(25)
   Private xSerie := Space(25)
   Private xForne := Space(25)
   Private xLoja  := Space(25)
   Private xNome  := Space(25)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
  
   Private aBrowse := {}

   Private oDlgX

   If Empty(Alltrim(cNota))
       Msgalert("Nota fiscal a ser pesquisada não informada.")
      Return .T.
   Endif
   
   If Empty(Alltrim(cSerie))
      Msgalert("Série da nota fiscal a ser pesquisada não informada.")
      Return .T.
   Endif

   If Empty(Alltrim(cForne))
      Msgalert("Fornecedor a ser pesquisada não informado.")
      Return .T.
   Endif

   xNota  := cNota
   xSerie := cSerie
   xForne := cForne
   xLoja  := cLoja

   // Pesquisa o nome do Fornecedor para display
   If Select("T_FORNECEDOR") > 0
      T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_NOME "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_COD  = '" + Alltrim(xForne) + "'"
   cSql += "   AND A2_LOJA = '" + Alltrim(xLoja)  + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   xNome  := T_FORNECEDOR->A2_NOME

   // Pesquisa as parcelas para display
   If Select("T_TITULO") > 0
      T_TITULO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E2_PARCELA,"
   cSql += "       E2_NUM    ,"
   cSql += "       E2_VENCTO ,"
   cSql += "       E2_VALOR  ,"
   cSql += "       E2_CODBAR ,"
   cSql += "       E2_TIPO   ,"
   cSql += "       E2_CBCO   ,"
   cSql += "       E2_CMOE   ,"
   cSql += "       E2_DVBA   ,"
   cSql += "       E2_FATO   ,"
   cSql += "       E2_CVAL   ,"
   cSql += "       E2_LIVRE  ,"
   cSql += "       E2_TLEI    "
   cSql += "  FROM " + RetSqlName("SE2")
   cSql += " WHERE E2_NUM      = '" + Alltrim(xNota)  + "'"
   cSql += "  AND E2_PREFIXO   = '" + Alltrim(xSerie) + "'"
   cSql += "  AND E2_FORNECE   = '" + Alltrim(xForne) + "'"
   cSql += "  AND E2_LOJA      = '" + Alltrim(xLoja)  + "'"
   cSql += "  AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TITULO", .T., .T. )

   Select("T_TITULO")
   T_TITULO->( DbGoTop() )
   DO WHILE !T_TITULO->( EOF() )
      dVencimento := Substr(T_TITULO->E2_VENCTO,07,02) + "/" + Substr(T_TITULO->E2_VENCTO,05,02) + "/" + Substr(T_TITULO->E2_VENCTO,01,04)
      aAdd( aBrowse, { T_TITULO->E2_PARCELA, ;
                       T_TITULO->E2_NUM    , ;
                       dVencimento         , ;
                       T_TITULO->E2_VALOR  , ;
                       T_TITULO->E2_CODBAR , ;
                       T_TITULO->E2_CBCO   , ;
                       T_TITULO->E2_CMOE   , ;
                       T_TITULO->E2_DVBA   , ;
                       T_TITULO->E2_FATO   , ;
                       T_TITULO->E2_CVAL   , ;
                       T_TITULO->E2_LIVRE  , ;
                       T_TITULO->E2_TIPO   , ;
                       T_TITULO->E2_TLEI   } )  
      T_TITULO->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgX TITLE "Código de Barras dos Títulos" FROM C(178),C(181) TO C(451),C(821) PIXEL

   @ C(006),C(004) Say "Nota Fiscal"            Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(006),C(048) Say "Série"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(006),C(073) Say "Fornecedor"             Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(025),C(003) Say "Títulos da Nota Fiscal" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   
   @ C(015),C(003) MsGet oGet1 Var xNota  When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(015),C(048) MsGet oGet2 Var xSerie When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(015),C(073) MsGet oGet3 Var xForne When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(015),C(100) MsGet oGet4 Var xLoja  When lChumba Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(015),C(121) MsGet oGet5 Var xNome  When lChumba Size C(195),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX

   @ C(120),C(168) Button "Informar Código Barras" Size C(070),C(012) PIXEL OF oDlgX ACTION( ABRECODIGO() )
   @ C(120),C(240) Button "Confirmar"              Size C(037),C(012) PIXEL OF oDlgX ACTION( GRAVATITULO() )
   @ C(120),C(279) Button "Voltar"                 Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 040 , 003, 400, 110,,{'Prc', 'Título', 'Vencimento', 'Valor', 'Codigo de Barras' },{20,50,50,50},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;      
                         aBrowse[oBrowse:nAt,05],;
                         ""                     ,;
                         ""                     ,;                         
                         ""                     ,;
                         ""                     ,;
                         ""                     ,;
                         ""                     ,;
                         aBrowse[oBrowse:nAt,05],;
                         ""                     } }

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Abre janela para informação do código de barras para a parcela selecionada
Static Function AbreCodigo()

   Local lChumbado := .F.

   Local aComboBx1 := {"Scaner","Manual"}
   Local cComboBx1

   Local cParcela    := aBrowse[oBrowse:nAt,01]
   Local cTitulo     := aBrowse[oBrowse:nAt,02]
   Local cVencimento := aBrowse[oBrowse:nAt,03]
   Local cValor      := aBrowse[oBrowse:nAt,04]
   Local cBarras     := aBrowse[oBrowse:nAt,05]

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Private oDlgx

   DEFINE MSDIALOG oDlgJ TITLE "Informação Código de Barras" FROM C(178),C(181) TO C(389),C(540) PIXEL

   @ C(008),C(007) Say "Parcela"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgJ
   @ C(022),C(007) Say "Título"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgJ
   @ C(034),C(008) Say "Vencimento"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgJ
   @ C(047),C(008) Say "Valor"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgJ
   @ C(061),C(008) Say "Tipo Leitura"  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgJ
   @ C(074),C(007) Say "Código Barras" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgJ
      
   @ C(007),C(043) MsGet oGet1 Var cParcela    when lChumbado Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgJ
   @ C(020),C(044) MsGet oGet2 Var cTitulo     when lChumbado Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgJ
   @ C(033),C(043) MsGet oGet3 Var cVencimento when lChumbado Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgJ
   @ C(046),C(043) MsGet oGet4 Var cValor      when lChumbado Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgJ
   @ C(059),C(043) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlgx
   @ C(073),C(044) MsGet oGet5 Var cBarras            Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgJ

   @ C(088),C(049) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgJ ACTION( GRAVABARRA(cParcela, cComboBx1, cBarras) )
   @ C(088),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgJ ACTION( oDlgJ:End() )

   ACTIVATE MSDIALOG oDlgJ CENTERED 

Return(.T.)

// Função que atualiza o codigo de barras no array aBrowse
Static Function GRAVABARRA(_Parcela, _Combo, _Barras)

   Local nContar     := 0
   Local _Banco      := ""
   Local _Moeda      := ""
   Local _DVBarras   := ""
   Local _Fator      := ""
   Local _ValTitulo  := ""
   Local _CampoLivre := ""

   // Prapara os Campos para Gravação

   If Alltrim(_Combo) == "Scaner"
      _Banco      := Substr(_Barras,01,03)
      _Moeda      := Substr(_Barras,04,01)
      _DVBarras   := Substr(_Barras,05,01)
      _Fator      := Substr(_Barras,06,04)
      _ValTitulo  := Substr(_Barras,10,10)
      _CampoLivre := Substr(_Barras,20,26)
   Else
      _Banco      := Substr(_Barras,01,03)
      _Moeda      := Substr(_Barras,04,01)
      _DVBarras   := Substr(_Barras,33,01)
      _Fator      := Substr(_Barras,34,04)
      _ValTitulo  := Substr(_Barras,38,10)
      _CampoLivre := Substr(_Barras,05,05) + Substr(_Barras,11,10) + Substr(_Barras,22,10)
   Endif

   For nContar = 1 to Len(aBrowse)
       If Alltrim(aBrowse[nContar,01]) == Alltrim(_Parcela)
          aBrowse[nContar,05] := _Barras
          aBrowse[nContar,06] := _Banco
          aBrowse[nContar,07] := _Moeda
          aBrowse[nContar,08] := _DVBarras
          aBrowse[nContar,09] := _Fator
          aBrowse[nContar,10] := _ValTitulo
          aBrowse[nContar,11] := _CampoLivre

          If Alltrim(_Combo) == "Scaner"
             aBrowse[nContar,13] := "S"
          Else
             aBrowse[nContar,13] := "M"             
          Endif   

          Exit
       Endif
   Next nContar
          
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;      
                         aBrowse[oBrowse:nAt,05]} }

   oDlgJ:End()

Return .T.

// Função que atualiza o codigo de barras no array aBrowse
Static Function GRAVATITULO()

   Local nContar := 0
   Local lResult
   Local cSql    := ""

   For nContar = 1 to Len(aBrowse)

       cSql := ""
       cSql := "UPDATE " + RetSqlName("SE2") + CHR(13)
       cSql += "   SET " + CHR(13)
       cSql += "   E2_CODBAR = '" + Alltrim(aBrowse[nContar,05]) + "', " + CHR(13)
       cSql += "   E2_CBCO   = '" + Alltrim(aBrowse[nContar,06]) + "', " + CHR(13)
       cSql += "   E2_CMOE   = '" + Alltrim(aBrowse[nContar,07]) + "', " + CHR(13)
       cSql += "   E2_DVBA   = '" + Alltrim(aBrowse[nContar,08]) + "', " + CHR(13)
       cSql += "   E2_FATO   = '" + Alltrim(aBrowse[nContar,09]) + "', " + CHR(13)
       cSql += "   E2_CVAL   = '" + Alltrim(aBrowse[nContar,10]) + "', " + CHR(13)
       cSql += "   E2_LIVRE  = '" + Alltrim(aBrowse[nContar,11]) + "', " + CHR(13)
       cSql += "   E2_TLEI   = '" + Alltrim(aBrowse[nContar,13]) + "'  " + CHR(13)
       cSql += " WHERE E2_PREFIXO = '" + Alltrim(xSerie)              + "'" + CHR(13)
       cSql += "   AND E2_NUM     = '" + Alltrim(aBrowse[nContar,02]) + "'" + CHR(13)
       cSql += "   AND E2_PARCELA = '" + Alltrim(aBrowse[nContar,01]) + "'" + CHR(13)
       cSql += "   AND E2_TIPO    = '" + Alltrim(aBrowse[nContar,12]) + "'" + CHR(13)
       cSql += "   AND E2_FORNECE = '" + Alltrim(xForne)              + "'" + CHR(13)
       cSql += "   AND E2_LOJA    = '" + Alltrim(xLoja)               + "'" + CHR(13)

       lResult := TCSQLEXEC(cSql)
       If lResult < 0
          Return MsgStop("Erro durante a alteração das parcelas: " + TCSQLError())
       EndIf 

   Next nContar

   oDlgX:End()
   
Return .T.