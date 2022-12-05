#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch"  

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE10.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/10/2012                                                          *
// Objetivo..: Programa de Agendamento de Eventos por Usuário	                   *
//**********************************************************************************

User Function ESPEVE10()
                       
   Local nContar     := 0
   Local lChumbaU    := .F.

   Private aUsuarios := {}
   Private aAnos     := {}
   Private cComboBx1
   Private cComboBx2
           
   Private aBrowse   := {}

   aAdd( aBrowse, { '', '', '', '' } )

   // Carrega o combo de usuários (Desenvolvedores)
   // ---------------------------------------------
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   aUsuarios := {}
   WHILE !T_DESENVE->( EOF() )
      aAdd( aUsuarios, Alltrim(T_DESENVE->ZZE_CODIGO) + " - " + Alltrim(T_DESENVE->ZZE_NOME) )
      T_DESENVE->( DbSkip() )
   ENDDO

   // Posiciona o Usuário
   If Alltrim(Upper(cUserName))$("ADMINISTRADOR#ROGER#GUSTAVO")
      lChumbaU := .T.
   Else
      lChumbaU := .F.

      If Select("T_DESENVE") > 0
         T_DESENVE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZE_CODIGO, "
      cSql += "       ZZE_NOME    "
      cSql += "  FROM " + RetSqlName("ZZE")
      cSql += " WHERE ZZE_DELETE = ''"
      cSql += "   AND ZZE_LOGIN  = '" + Alltrim(Upper(cUserName)) + "'"
      cSql += " ORDER BY ZZE_NOME "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

      aUsuarios := {}
      aAdd( aUsuarios, Alltrim(T_DESENVE->ZZE_CODIGO) + " - " + Alltrim(T_DESENVE->ZZE_NOME) )
      
   Endif

   // Carrega o Combox de Anos
   // ------------------------
   For nContar = 2012 to (Year(Date()) + 5)
       aAdd( aAnos, Strzero(nContar,4) )
   Next nContar    

   cComboBx2 := Strzero(Year(date()),4)       

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Agendamento de Eventos" FROM C(184),C(187) TO C(497),C(792) PIXEL

   @ C(001),C(005) Jpeg FILE "logoautoma.bmp" Size C(143),C(027)                 PIXEL NOBORDER OF oDlg

   @ C(027),C(005) Say "Usuários"             Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(187) Say "Ano"                  Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(046),C(005) Say "Eventos"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(036),C(005) ComboBox cComboBx1 Items aUsuarios When lChumbaU Size C(177),C(010) PIXEL OF oDlg
   @ C(036),C(187) ComboBox cComboBx2 Items aAnos                   Size C(031),C(010) PIXEL OF oDlg

   @ C(036),C(222) Button "Pesquisar"  Size C(037),C(012) PIXEL OF oDlg ACTION( PesqAgenda() )
   @ C(036),C(260) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ C(140),C(143) Button "Incluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( AgendaOper( "I", "      ", cComboBx1, cComboBx2, "", ""))
   @ C(140),C(182) Button "Alterar"    Size C(037),C(012) PIXEL OF oDlg ACTION( AgendaOper( "A", aBrowse[oBrowse:nAt,01], cComboBx1, cComboBx2, aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]))
   @ C(140),C(221) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlg ACTION( AgendaOper( "V", aBrowse[oBrowse:nAt,01], cComboBx1, cComboBx2, aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]))
   @ C(140),C(260) Button "Excluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( AgendaOper( "E", aBrowse[oBrowse:nAt,01], cComboBx1, cComboBx2, aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]))

   oBrowse := TCBrowse():New(067, 005, 375, 108,,{'Código', 'Data', 'Evento', 'Autorizado'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                       } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa a agenda de eventos para o usuário/ano selecionados
Static Function PesqAgenda()

   cSql := ""

   If Select("T_AGENDA") > 0
      T_AGENDA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZ2_CODIGO, "
   cSql += "       A.ZZ2_DATA  , "
   cSql += "       A.ZZ2_EVEN  , "
   cSql += "       A.ZZ2_AUTO  , "
   cSql += "       B.ZZS_NOME    "
   cSql += "  FROM " + RetSqlName("ZZ2") + " A, "
   cSql += "       " + RetSqlName("ZZS") + " B  "
   cSql += " WHERE A.ZZ2_DELETE = ''"
   cSql += "   AND A.ZZ2_EVEN   = B.ZZS_CODIGO  "
   cSql += "   AND A.ZZ2_USUA   = '" + Substr(cComboBx1,01,06) + "'"
   cSql += "   AND A.ZZ2_ANO    = '" + Alltrim(cComboBx2)      + "'"
   cSql += "   AND B.ZZS_DELETE = ''"
   cSql += " ORDER BY A.ZZ2_DATA "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDA", .T., .T. )

   aBrowse := {}
   WHILE !T_AGENDA->( EOF() )
      aAdd( aBrowse, { T_AGENDA->ZZ2_CODIGO,;
                       Substr(T_AGENDA->ZZ2_DATA,07,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,05,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,01,04) ,;
                       T_AGENDA->ZZS_NOME,;
                       IIF(Empty(Alltrim(T_AGENDA->ZZ2_AUTO)), "N", T_AGENDA->ZZ2_AUTO) } )
      T_AGENDA->( DbSkip() )
   ENDDO

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                       } }
   
Return .T.
   
// Função que abre a tela de manutenção de Agendamento de Eventos
Static Function AgendaOper(_Operacao, _Codigo, _Usuario, _Ano, _Evento, _Autorizado)

   If _Operacao == "A"
      If _Autorizado == "S"
         MsgAlert("Agendamento de Evento já autorizado. Utilize Visualizar.")
         Return .T.
      Endif
   Endif
         
   If _Operacao == "E"
      If _Autorizado == "S"
         MsgAlert("Agendamento de Evento já autorizado. Utilize Visualizar.")
         Return .T.
      Endif
   Endif

   If _Operacao == "V"
      U_ESPEVE141(_Codigo)
   Else
      U_ESPEVE11(_Operacao, _Codigo, _Usuario, _Ano, _Evento)
   Endif   

   PesqAgenda()
   
Return .T.