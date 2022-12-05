#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE12.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/10/2012                                                          *
// Objetivo..: Aprovação/Reprovação de Agendamento de Eventos                      *
//**********************************************************************************

User Function ESPEVE12()

   Local cSql := ""

   Private oDlg
   Private aTipoPesq := {"01 - Pendentes de Aprovação", "02 - Somente Aprovados", "03 - Todos"}
   Private cComboBx1

   Private aBrowse := {}

   // Declara as Legendas
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

   // Carrega o rgdi aBrowse com os agendamentos pendentes de aprovação ára display
   aAdd( aBrowse, { '1', '', '', '', '' } )

   If Select("T_AGENDA") > 0
      T_AGENDA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZ2_CODIGO, "
   cSql += "       A.ZZ2_DATA  , "
   cSql += "       A.ZZ2_EVEN  , "
   cSql += "       B.ZZS_NOME  , "
   cSql += "       C.ZZE_NOME  , "
   cSql += "       A.ZZ2_AUTO    "
   cSql += "  FROM " + RetSqlName("ZZ2") + " A, "
   cSql += "       " + RetSqlName("ZZS") + " B, "
   cSql += "       " + RetSqlName("ZZE") + " C  "
   cSql += " WHERE A.ZZ2_DELETE = '' "
   cSql += "   AND (A.ZZ2_AUTO  = '' OR A.ZZ2_AUTO  = 'N')"
   cSql += "   AND A.ZZ2_VIST  <> 'S'"
   cSql += "   AND A.ZZ2_EVEN   = B.ZZS_CODIGO  "
   cSql += "   AND A.ZZ2_USUA   = C.ZZE_CODIGO  "
   cSql += "   AND C.ZZE_DELETE = '' "
   cSql += "   AND B.ZZS_DELETE = ''"
   cSql += " ORDER BY A.ZZ2_USUA, A.ZZ2_DATA "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDA", .T., .T. )

   aBrowse := {}

   WHILE !T_AGENDA->( EOF() )

      Do Case
         Case T_AGENDA->ZZ2_AUTO == " "
             _Status := "1"
         Case T_AGENDA->ZZ2_AUTO == "N"
             _Status := "8"
         Case T_AGENDA->ZZ2_AUTO == "S"
             _Status := "2"
      EndCase             

      aAdd( aBrowse, { _Status             ,;
                       T_AGENDA->ZZ2_CODIGO,;
                       Substr(T_AGENDA->ZZ2_DATA,07,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,05,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,01,04) ,;
                       T_AGENDA->ZZS_NOME,;
                       T_AGENDA->ZZE_NOME } )
      T_AGENDA->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "1", "", "", "", "", "" } )
   Endif
   
   DEFINE MSDIALOG oDlg TITLE "Confirmação de Agenda de Eventos" FROM C(178),C(181) TO C(474),C(803) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlg
   @ C(134),C(005) Say "Tipo Pesquisa" Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(134),C(043) ComboBox cComboBx1 Items aTipoPesq Size C(072),C(010) PIXEL OF oDlg
   @ C(132),C(130) Button "Pesquisar"                 Size C(051),C(012) PIXEL OF oDlg ACTION( RealPesquisa() )
   @ C(132),C(214) Button "Aprovar/Reprovar"          Size C(051),C(012) PIXEL OF oDlg ACTION( AbreAprova(aBrowse[oBrowse:nAt,02]))
   @ C(132),C(267) Button "Voltar"                    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 035 , 005, 390, 130,,{'Lg', 'Código' + Space(06), 'Data', 'Evento', 'Usuário'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a janela de aprovação/reprovação de agenda de evento
Static Function AbreAprova(_Codigo)

   If Empty(Alltrim(_Codigo))
      Return(.T.)
   Endif

   // Abre tela de análise da solicitação
   U_ESPEVE13(_Codigo)

   RealPesquisa()

Return(.T.)

// Função que realiza a pesquisa para visualização
Static Function RealPesquisa()

   Local cSql := ""
   
   If Select("T_AGENDA") > 0
      T_AGENDA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZ2_CODIGO, "
   cSql += "       A.ZZ2_DATA  , "
   cSql += "       A.ZZ2_EVEN  , "
   cSql += "       B.ZZS_NOME  , "
   cSql += "       C.ZZE_NOME  , "
   cSql += "       A.ZZ2_AUTO    " 
   cSql += "  FROM " + RetSqlName("ZZ2") + " A, "
   cSql += "       " + RetSqlName("ZZS") + " B, "
   cSql += "       " + RetSqlName("ZZE") + " C  "
   cSql += " WHERE A.ZZ2_DELETE = '' "

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           cSql += "   AND (A.ZZ2_AUTO  = '' OR A.ZZ2_AUTO  = 'N')"
      Case Substr(cComboBx1,01,02) == "02"
      Case Substr(cComboBx1,01,02) == "03"
   EndCase

   cSql += "   AND A.ZZ2_EVEN   = B.ZZS_CODIGO  "
   cSql += "   AND A.ZZ2_USUA   = C.ZZE_CODIGO  "

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           cSql += "   AND A.ZZ2_VIST  <> 'S'"
      Case Substr(cComboBx1,01,02) == "02"
           cSql += "   AND A.ZZ2_VIST  = 'S'"
      Case Substr(cComboBx1,01,02) == "03"
   EndCase

   cSql += "   AND C.ZZE_DELETE = '' "
   cSql += "   AND B.ZZS_DELETE = ''"
   cSql += " ORDER BY A.ZZ2_USUA, A.ZZ2_DATA "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDA", .T., .T. )

   aBrowse := {}

   WHILE !T_AGENDA->( EOF() )

      Do Case
         Case T_AGENDA->ZZ2_AUTO == " "
             _Status := "1"
         Case T_AGENDA->ZZ2_AUTO == "N"
             _Status := "8"
         Case T_AGENDA->ZZ2_AUTO == "S"
             _Status := "2"
      EndCase             

      aAdd( aBrowse, { _Status             ,;
                       T_AGENDA->ZZ2_CODIGO,;
                       Substr(T_AGENDA->ZZ2_DATA,07,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,05,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,01,04) ,;
                       T_AGENDA->ZZS_NOME,;
                       T_AGENDA->ZZE_NOME } )

      T_AGENDA->( DbSkip() )

   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "1", "", "", "", "", "" } )
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05]} }

Return .T.