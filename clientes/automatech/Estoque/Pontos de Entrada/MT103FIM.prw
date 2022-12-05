#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM102.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 19/04/2012                                                          *
// Objetivo..: Ponto de entrada que abre a janela de informa��o dos codigos de     *
//             barras no final da nota fiscal de entrada. Isso serve para o CNAB   *
//             do Banco Ita�.                                                      *
//**********************************************************************************

User Function MT103FIM()

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

   xNota  := cNfiscal
   xSerie := cSerie
   xForne := cA100For
   xLoja  := cLoja

   If Empty(Alltrim(xNota))
      Return .T.
   Endif    

   // Pesquisa o nome do Fornecedor para display
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(xForne) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(xLoja)  + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   xNome  := T_CLIENTE->A1_NOME

   Private oDlg

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
   cSql += " WHERE E2_NUM    = '" + Alltrim(xNota)  + "'"
   cSql += "  AND E2_PREFIXO = '" + Alltrim(xSerie) + "'"
   cSql += "  AND E2_FORNECE = '" + Alltrim(xForne) + "'"
   cSql += "  AND E2_LOJA    = '" + Alltrim(xLoja)  + "'"
   cSql += "  AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TITULO", .T., .T. )

   If T_TITULO->( EOF() )
      Return .T.
   Endif

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

   DEFINE MSDIALOG oDlg TITLE "C�digo de Barras dos T�tulos" FROM C(178),C(181) TO C(451),C(821) PIXEL

   @ C(006),C(004) Say "Nota Fiscal"            Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(048) Say "S�rie"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(073) Say "Fornecedor"             Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(003) Say "T�tulos da Nota Fiscal" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(015),C(003) MsGet oGet1 Var xNota  When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(048) MsGet oGet2 Var xSerie When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(073) MsGet oGet3 Var xForne When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(100) MsGet oGet4 Var xLoja  When lChumba Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(121) MsGet oGet5 Var xNome  When lChumba Size C(195),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(120),C(168) Button "Informar C�digo Barras" Size C(070),C(012) PIXEL OF oDlg ACTION( ABRECODIGO() )
   @ C(120),C(240) Button "Confirmar"              Size C(037),C(012) PIXEL OF oDlg ACTION( GRAVATITULO() )
   @ C(120),C(279) Button "Voltar"                 Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 040 , 003, 400, 110,,{'Prc', 'T�tulo', 'Vencimento', 'Valor', 'Codigo de Barras' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Abre janela para informa��o do c�digo de barras para a parcela selecionada
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

   DEFINE MSDIALOG oDlgx TITLE "Informa��o C�digo de Barras" FROM C(178),C(181) TO C(389),C(540) PIXEL

   @ C(008),C(007) Say "Parcela"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(022),C(007) Say "T�tulo"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(034),C(008) Say "Vencimento"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(047),C(008) Say "Valor"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(061),C(008) Say "Tipo Leitura"  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(074),C(007) Say "C�digo Barras" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
      
   @ C(007),C(043) MsGet oGet1 Var cParcela    when lChumbado Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(020),C(044) MsGet oGet2 Var cTitulo     when lChumbado Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(033),C(043) MsGet oGet3 Var cVencimento when lChumbado Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(046),C(043) MsGet oGet4 Var cValor      when lChumbado Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(059),C(043) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlgx
   @ C(073),C(044) MsGet oGet5 Var cBarras            Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx

   @ C(088),C(049) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgx ACTION( GRAVABARRA(cParcela, cComboBx1, cBarras) )
   @ C(088),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgx ACTION( oDlgx:End() )

   ACTIVATE MSDIALOG oDlgx CENTERED 

Return(.T.)

// Fun��o que atualiza o codigo de barras no array aBrowse
Static Function GRAVABARRA(_Parcela, _Combo, _Barras)

   Local nContar     := 0
   Local _Banco      := ""
   Local _Moeda      := ""
   Local _DVBarras   := ""
   Local _Fator      := ""
   Local _ValTitulo  := ""
   Local _CampoLivre := ""

   // Prapara os Campos para Grava��o

   If Alltrim(_Combo) == "Scaner"
      _Banco      := Substr(_Barras,01,03)
      _Moeda      := Substr(_Barras,04,01)
      _DVBarras   := Substr(_Barras,05,01)
      _Fator      := Substr(_Barras,06,04)
      _ValTitulo  := Substr(_Barras,10,10)
      _CampoLivre := Substr(_Barras,20,25)
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

   oDlgx:End()

Return .T.

// Fun��o que atualiza o codigo de barras no array aBrowse
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
          Return MsgStop("Erro durante a altera��o das parcelas: " + TCSQLError())
       EndIf 

   Next nContar

   oDlg:End()
   
Return .T.