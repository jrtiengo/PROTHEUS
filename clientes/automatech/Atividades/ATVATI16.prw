#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI16.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/10/2012                                                          *
// Objetivo..: Programa que abre a relação de atividades em atraso/a realizar para *
//             o nível Administrador.                                              *
//**********************************************************************************

User Function ATVATI16()
 
   Local cSql        := ""

   Private aUsuarios := {}
   Private aSetores  := {}

   Private cComboBx1
   Private cComboBx2

   Private oDlg

   // Carrega o Combo de Usuários Normais
   aAdd( aUsuarios, "Todos")
   
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA FROM " + RetSqlName("ZZT") + " WHERE ZZT_NORM = 'T' AND ZZT_DELETE = '' ORDER BY ZZT_NORM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )
      
   WHILE !T_USUARIOS->( EOF() )   
      aAdd( aUsuarios, T_USUARIOS->ZZT_USUA )
      T_USUARIOS->( DbSkip() )
   ENDDO

   // Carrega o Combo de Áreas
   aAdd( aSetores, "Todas")
   
   If Select("T_SETOR") > 0
      T_SETOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZR_CODIGO,"
   cSql += "       ZZR_NOME   "
   cSql += "  FROM " + RetSqlName("ZZR")
   cSql += " WHERE ZZR_DELETE = ''"
   cSql += " ORDER BY ZZR_NOME"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SETOR", .T., .T. )
      
   WHILE !T_SETOR->( EOF() )   
      aAdd( aSetores, T_SETOR->ZZR_CODIGO + " - " + Alltrim(T_SETOR->ZZR_NOME) )
      T_SETOR->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Filtro de Atividades" FROM C(178),C(181) TO C(326),C(468) PIXEL

   @ C(005),C(005) Say "Usuário" Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(005) Say "Área"    Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(015),C(005) ComboBox cComboBx1 Items aUsuarios Size C(132),C(010) PIXEL OF oDlg
   @ C(038),C(005) ComboBox cComboBx2 Items aSetores  Size C(132),C(010) PIXEL OF oDlg

   @ C(056),C(032) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( Carativi(cComboBx1, cComboBx2) ) 
   @ C(056),C(071) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa dados do usuário selecionado no ComboBx1
Static Function CARATIVI( xNormal, xArea)

   Local lChumba       := .F.
   Local lAdm          := .F.
   Local lSupervisor   := .F.
   Local lNormal       := .F.      
   Local cSql          := ""
   Local cData1        := Ctod("  /  /    ")
   Local cData2        := Ctod("  /  /    ")
   Local cSemana       := ""
   Local lMaisHoje     := .F.

   Private cDono       := xNormal
   Private cSetor      := xArea

   Private cTOTATI     := 0
   Private cTOTATR     := 0
   Private cTOTAFA     := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlg

   Private aBrowse := {}

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')    // Executado Antes do Prazo
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho') // Executado Fora do Prazo
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')     // Executado no Prazo
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')  // Vencida e não Executada
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')  // Aguardando Aprovação do Supervisor
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')   // Atividade Encerrada
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')    // Disponível
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')    // Disponível

   // Pesquisa as atividades em atraso/a realizar para os dados selecionados nos combos
   If Select("T_ATIVIDADES") > 0
      T_ATIVIDADES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZX_FILIAL,"
   cSql += "       A.ZZX_DAT1  ,"
   cSql += "       A.ZZX_DAT2  ,"
   cSql += "       A.ZZX_CODIGO,"
   cSql += "       B.ZZU_NOME  ,"
   cSql += "       A.ZZX_USUA  ,"
   cSql += "       A.R_E_C_N_O_ AS REGISTRO,"
   cSql += "       C.ZZV_AREA  ,"
   cSql += "       D.ZZR_NOME   "
   cSql += "  FROM " + RetSqlName("ZZX") + " A, "
   cSql += "       " + RetSqlName("ZZU") + " B, "
   cSql += "       " + RetSqlName("ZZV") + " C, "
   cSql += "       " + RetSqlName("ZZR") + " D  "
   cSql += " WHERE A.ZZX_ATIV   = B.ZZU_CODIGO"
   cSql += "   AND A.ZZX_DELETE = ''"
   cSql += "   AND A.ZZX_CODIGO = C.ZZV_CODIGO"
   cSql += "   AND C.ZZV_DELETE = ''"
   cSql += "   AND C.ZZV_AREA   = D.ZZR_CODIGO"
   cSql += "   AND D.ZZR_DELETE = ''"

   If Alltrim(Upper(cDono)) <> "TODOS"
      cSql += "   AND A.ZZX_USUA   = '" + Alltrim(cDono) + "'"
   Endif
      
   If Alltrim(Upper(Substr(cSetor,01,05))) <> "TODAS"
      cSql += "   AND C.ZZV_AREA   = '" + Alltrim(Substr(cSetor,01,06)) + "'"
   Endif

   cSql += "   AND B.ZZU_DELETE = ''"
   cSql += "   AND A.ZZX_REAL   = ''"
   cSql += "   AND A.ZZX_MES   <= " + Alltrim(Str(Month(date())))
   cSql += "   AND A.ZZX_ANO    = " + Alltrim(Str(Year(date())))
   cSql += " ORDER BY A.ZZX_USUA, A.ZZX_DAT1 "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADES", .T., .T. )

   WHILE !T_ATIVIDADES->( EOF() )

      cData1  := Ctod(Substr(T_ATIVIDADES->ZZX_DAT1,07,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT1,05,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT1,01,04))
      cData2  := Ctod(Substr(T_ATIVIDADES->ZZX_DAT2,07,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT2,05,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT2,01,04))

      Do Case
         Case Dow(cData1) == 1
              cSemana := "Domingo"
         Case Dow(cData1) == 2
              cSemana := "Segunda"
         Case Dow(cData1) == 3
              cSemana := "Terça"
         Case Dow(cData1) == 4
              cSemana := "Quarta"
         Case Dow(cData1) == 5
              cSemana := "Quinta"
         Case Dow(cData1) == 6
              cSemana := "Sexta"
         Case Dow(cData1) == 7
              cSemana := "Sábado"
      EndCase              

      cTOTATI := cTOTATI + 1

      IF cData1 < Date()
         cTOTATR := cTOTATR + 1
      Else   
         cTOTAFA := cTOTAFA + 1
      Endif   

      aAdd( aBrowse, { IIF(cData1 < Date(), "8", "2")    ,;
                       cData1                            ,;
                       cData2                            ,;
                       cSemana                           ,;
                       T_ATIVIDADES->ZZX_CODIGO          ,;
                       T_ATIVIDADES->ZZU_NOME            ,;
                       T_ATIVIDADES->ZZX_USUA            ,;
                       T_ATIVIDADES->ZZV_AREA            ,;
                       Strzero(T_ATIVIDADES->REGISTRO,06),;                       
                       T_ATIVIDADES->ZZR_NOME            ,;
                       } )
      
      T_ATIVIDADES->( DbSkip() )
      
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { '','','','','','','' } )
   Endif         

   DEFINE MSDIALOG oDlg TITLE "Agenda de Atividades - Em Atraso / A Realizar" FROM C(178),C(181) TO C(554),C(880) PIXEL

   @ C(005),C(005) Say "Usuário"                                    Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(084) Say "Área"                                       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(165),C(177) Say "VERMELHO - Em Atraso"                       Size C(060),C(008) COLOR CLR_RED PIXEL OF oDlg
   @ C(174),C(177) Say "VERDE - A Realizar"                         Size C(050),C(008) COLOR CLR_GREEN PIXEL OF oDlg
   @ C(028),C(005) Say "Relação de Atividades em atraso/a realizar" Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(163),C(005) Say "Total Atividades"                           Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(163),C(058) Say "Total em Atraso"                            Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(163),C(109) Say "Total A Realizar"                           Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet4 Var cDono Size C(075),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(014),C(084) MsGet oGet5 Var cSetor  Size C(075),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(173),C(010) MsGet oGet1 Var cTOTATI Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(173),C(063) MsGet oGet2 Var cTOTATR Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(173),C(114) MsGet oGet3 Var cTOTAFA Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

// @ C(168),C(268) Button "Detalhes" Size C(037),C(012) PIXEL OF oDlg ACTION( ABRE_DET(aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,08],aBrowse[oBrowse:nAt,09]))
   @ C(168),C(307) Button "Sair"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 045 , 005, 435, 158,,{'L', 'De', 'Até', 'Semana', 'Código', 'Descrição das Atividades', 'Usuário', 'Área'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oCinza   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho, oBranco)))))))),;                         
                         aBrowse[oBrowse:nAt,02] ,;
                         aBrowse[oBrowse:nAt,03] ,;
                         aBrowse[oBrowse:nAt,04] ,;
                         aBrowse[oBrowse:nAt,05] ,;
                         aBrowse[oBrowse:nAt,06] ,;
                         aBrowse[oBrowse:nAt,07] ,;
                         aBrowse[oBrowse:nAt,10] }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a tela de detalhes da tarefa
Static Function ABRE_DET(xAtividade, xArea, xRegistro)

   U_ATVMOV02(xAtividade, xArea, xRegistro)

   PESQUSUS(cComboBx3)
   
Return .T.