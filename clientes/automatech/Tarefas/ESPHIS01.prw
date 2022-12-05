#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPHIS01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/01/2012                                                          *
// Objetivo..: Programa de Manutenção dos Históicos da Tarefa                      *
// Parâmetros: Código da Tarefa                                                    *
//             Data A Partir De                                                    *
//             Estimativa                                                          *
//             Previsto                                                            *
//**********************************************************************************

User Function ESPHIS01(_Codigo, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo)

   Local aArea 	 := GetArea()
   
   Private cCodigo	 := ""
   Private cTitulo	 := Space(60)
   Private lLibera   := .F.
   Private lSalvar   := .F.

   Private oGet1
   Private oGet2

   Private _aAlias   := {}

   Private oDlg

   Private oBrowseH
   Private aHistorico := {}

   Private oCVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oCVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oCAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oCAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oCPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oCLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oCBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oCPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oCEncerra  := LoadBitmap(GetResources(),'br_marrom')

   // Verifica se o usuário logado possui permissão para liberar tarefas
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI, "
   cSql += "       ZZA_VISU  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += "WHERE RTRIM(LTRIM(UPPER(ZZA_NOME))) = '" + Upper(Alltrim(cUserName)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )
   
   If T_USUARIO->( EOF() )
      MsgAlert("Atenção! Você não possui permissão para realizar esta operação.")
      Return(.T.)
   Endif
            
   If T_USUARIO->ZZA_VISU <> "T"
      lSalvar := .T.
   Else
      lSalvar := .F.   
   Endif

   // Captura os dados da tarefa para display
   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       ZZG_TITU   "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Substr(_Codigo,01,06) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Substr(_Codigo,08,02) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )
   
   cCodigo    := T_TAREFA->ZZG_CODI + "." + T_TAREFA->ZZG_SEQU
   cTitulo    := T_TAREFA->ZZG_TITU

   DEFINE MSDIALOG oDlg TITLE "Histórico de Tarefa" FROM C(178),C(181) TO C(555),C(655) PIXEL

   // Carrega os históricos para display
   MontaStatus(_Codigo, 1)

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(026),C(006) Say "Tarefa"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(035) Say "Título da Tarefa"     Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(007) Say "Históricos da Tarefa" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(035),C(007) MsGet oGet1 Var cCodigo    When lLibera Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(035) MsGet oGet2 Var cTitulo    When lLibera Size C(195),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(171),C(007) Button "Visualizar Histórico" Size C(066),C(012) PIXEL OF oDlg ACTION( ALTESTATUS("V", _Codigo, aHistorico[ oBrowseH:nAt, 05 ], __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo))
   @ C(171),C(139) Button "Alterar Status"       Size C(051),C(012) PIXEL OF oDlg ACTION( ALTESTATUS("A", _Codigo, aHistorico[ oBrowseH:nAt, 05 ], __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo) ) When lSalvar
   @ C(171),C(192) Button "Voltar"               Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

   RestArea(aArea)

Return(.T.)

// Função que abre a tela de alteração do status da tarefa
Static Function AlteStatus(_Tipo, _Codigo, _Registro, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo)

   Local cGuarda := _Codigo

   If _Tipo == "A"
      _Registro := aHistorico[ len(aHistorico),5]
   Endif

   If _Registro == 0
      Return(.T.)
   Endif   

   // Chama tela de Alteração/Visualização de Status de tarefa
   U_ESPHIS02(_Tipo, _Codigo, _Registro, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo) 
  
   // Fecha o Dialogo e o chama novamente
   oDlg:End()

   U_ESPHIS01(_Codigo, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo)

// MontaStatus(cGuarda, 2)

Return .T.

// Função que abre a tela de alteração do status da tarefa
Static Function MontaStatus(_Codigo, _Tipo)

   aHistorico := {}

   // Carrega os históricos para display
   If Select("T_HISTORICO") > 0
      T_HISTORICO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZH_CODI  , "
   cSql += "       A.ZZH_SEQU  , "
   cSql += "       A.ZZH_DATA  , "
   cSql += "       A.ZZH_HORA  , "
   cSql += "       A.ZZH_STAT  , "
   cSql += "       A.ZZH_DELE  , "
   cSql += "       A.R_E_C_N_O_, "
   cSql += "       B.ZZC_NOME  , "
   cSql += "       B.ZZC_LEGE    "
   cSql += "  FROM " + RetSqlName("ZZH") + " A, "
   cSql += "       " + RetSqlName("ZZC") + " B  "
   cSql += " WHERE A.ZZH_DELE   = ''"
   cSql += "   AND '00000' + A.ZZH_STAT   = B.ZZC_CODIGO"
   cSql += "   AND B.ZZC_DELETE = ''"
   cSql += "   AND A.ZZH_CODI   = '" + Substr(_Codigo,01,06) + "'"
   cSql += "   AND A.ZZH_SEQU   = '" + Substr(_Codigo,08,02) + "'"
   cSql += " ORDER BY ZZH_DATA, ZZH_HORA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HISTORICO", .T., .T. )

   If T_HISTORICO->( EOF() )
      aAdd( aHistorico, { ' ', '', '', '', '' } )
   Else
      WHILE !T_HISTORICO->( EOF() )
         aAdd( aHistorico, { Alltrim(T_HISTORICO->ZZC_LEGE)              ,;
                             Substr(T_HISTORICO->ZZH_DATA,07,02) + "/" +  ;
                             Substr(T_HISTORICO->ZZH_DATA,05,02) + "/" +  ;
                             Substr(T_HISTORICO->ZZH_DATA,01,04)         ,; 
                             T_HISTORICO->ZZH_HORA                       ,;
                             T_HISTORICO->ZZC_NOME                       ,;
                             T_HISTORICO->R_E_C_N_O_ } )
         T_HISTORICO->( DbSkip() )
      ENDDO
   Endif

   oBrowseH := TCBrowse():New( 070 , 005, 295, 145,,{'','Data','Hora', 'Histórico da Tarefa','Registro'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowseH:SetArray(aHistorico) 
    
   // Monta a linha a ser exibina no Browse
   oBrowseH:bLine := {||{ If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "1", oCBranco  ,;
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "2", oCVerde   ,;
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "3", oCPink    ,;                         
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "4", oCAmarelo ,;                         
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "5", oCAzul    ,;                         
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "6", oCLaranja ,;                         
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "7", oCPreto   ,;                         
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "8", oCVermelho,;                         
                          If(Alltrim(aHistorico[oBrowseH:nAt,01]) == "9", oCEncerra, ""))))))))),;                         
                          aHistorico[oBrowseH:nAt,02]            ,;
                          aHistorico[oBrowseH:nAt,03]            ,;
                          aHistorico[oBrowseH:nAt,04]            ,;
                          aHistorico[oBrowseH:nAt,05]            } }

Return .T.   