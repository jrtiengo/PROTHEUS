#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM558.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 12/04/2017                                                           *
// Objetivo..: Manutenção Cadastro de Gestores                                      *
//***********************************************************************************

User Function AUTOM558()

   Local cMemo1	 := ""
   Local oMemo1

   Private aBrowse := {}

   Private oDlg

   // ##################################################
   // Função que carrega o grid com dados do cadastro ##
   // ##################################################
   CarregaZSC(0)

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Gestores" FROM C(178),C(181) TO C(506),C(710) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(257),C(001) PIXEL OF oDlg

   @ C(147),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManGestor("I", "") )
   @ C(147),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( ManGestor("A", aBrowse[oBrowse:nAt,01]) )
   @ C(147),C(081) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManGestor("E", aBrowse[oBrowse:nAt,01]) )
   @ C(147),C(223) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 050 , 005, 326, 133,,{'Código', 'Nome dos Gestores'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################
// Função que carrega o grid com dados do cadastro ##
// ##################################################
Static Function CarregaZSC(kTipo)

   Local cSql := ""
   
   aBrowse := {}
   
   If Select("T_GESTOR") > 0
      T_GESTOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSC_CODI,"
   cSql += "       ZSC_NOME "
   cSql += "  FROM " + RetSqlName("ZSC")
   cSql += " WHERE ZSC_DELE = ''"
   cSql += " ORDER BY ZSC_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GESTOR", .T., .T. )
   
   T_GESTOR->( DbGoTop() )
   
   WHILE !T_GESTOR->( EOF() )
      aAdd( aBrowse, { T_GESTOR->ZSC_CODI, T_GESTOR->ZSC_NOME })
      T_GESTOR->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "" })
   Endif   
   
   If kTipo == 0
      Return(.T.)
   Endif
   
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]}}

Return(.T.)      

// ############################################################
// Função que abre janela de manutenção do cadastro de áreas ##
// ############################################################
Static Function ManGestor(kOperacao, kCodigo)


   Local lChumba := .F.
   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cCodigo  := Space(06)
   Private cNome    := Space(40)
   Private cCodUser := Space(06)
   Private cDDD	    := Space(03)
   Private cFone	:= Space(15)
   Private cEmail	:= Space(60)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private aAreas	 := {}
   Private cComboBx1
   
   // ##############################
   // Carrega o combobox de áreas ##
   // ##############################
   If Select("T_AREA") > 0
      T_AREA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSF_CODI,"
   cSql += "       ZSF_NOME "
   cSql += "  FROM " + RetSqlName("ZSF")
   cSql += " WHERE ZSF_DELE = ''"
   cSql += " ORDER BY ZSF_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREA", .T., .T. )
   
   T_AREA->( DbGoTop() )
   
   aAreas := {}
   aAdd( aAreas, "000000 - Selecione a Área")

   WHILE !T_AREA->( EOF() )
      aAdd( aAreas, T_AREA->ZSF_CODI + " - " + T_AREA->ZSF_NOME )
      T_AREA->( DbSkip() )
   ENDDO

   Private oDlgG

   If kOperacao == "I"
   Else
   
      If Select("T_GESTOR") > 0
         T_GESTOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZSC_CODI,"
      cSql += "       ZSC_USER,"
      cSql += "       ZSC_NOME,"
      cSql += "       ZSC_DDD ,"
      cSql += "       ZSC_TELE,"
      cSql += "       ZSC_EMAI,"
      cSql += "       ZSC_AREA "
      cSql += "  FROM " + RetSqlName("ZSC")
      cSql += " WHERE ZSC_CODI = '" + Alltrim(kCodigo) + "'"
      cSql += "   AND ZSC_DELE = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GESTOR", .T., .T. )
                       
      If T_GESTOR->( EOF() )
         MsgAlert("Gestor inexistente. Verifique!")
         Return(.T.)
      Else
         cCodigo  := T_GESTOR->ZSC_CODI
         cNome    := T_GESTOR->ZSC_NOME
         cCodUser := T_GESTOR->ZSC_USER
         cDDD	  := T_GESTOR->ZSC_DDD
         cFone	  := T_GESTOR->ZSC_TELE
         cEmail	  := T_GESTOR->ZSC_EMAI
         
         For nContar = 1 to Len(aAreas)
             If Alltrim(Substr(aAreas[nContar],01,06)) == Alltrim(T_GESTOR->ZSC_AREA)
                cComboBx1 := aAreas[nContar]
                Exit
             Endif
         Next nContar       
      
      Endif
      
   Endif

   DEFINE MSDIALOG oDlgG TITLE "Cadastro de Gestores" FROM C(178),C(181) TO C(462),C(570) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(135),C(022) PIXEL NOBORDER OF oDlgG

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(187),C(001) PIXEL OF oDlgG           
   @ C(120),C(002) GET oMemo2 Var cMemo2 MEMO Size C(187),C(001) PIXEL OF oDlgG
   
   @ C(033),C(005) Say "Código"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(033),C(037) Say "Cod.Usr.Protheus" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(055),C(005) Say "Nome do Gestor"   Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(077),C(005) Say "DDD"              Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(077),C(028) Say "Celular"          Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(077),C(076) Say "Área"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(098),C(005) Say "E-Mail"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   
   @ C(042),C(005) MsGet    oGet1     Var   cCodigo  Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG When lChumba
   @ C(042),C(037) MsGet    oGet3     Var   cCodUser Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG When IIF(kOperacao == "E", .F., .T.)
   @ C(064),C(005) MsGet    oGet2     Var   cNome    Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG When IIF(kOperacao == "E", .F., .T.)
   @ C(086),C(005) MsGet    oGet4     Var   cDDD     Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG When IIF(kOperacao == "E", .F., .T.)
   @ C(086),C(028) MsGet    oGet5     Var   cFone    Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG When IIF(kOperacao == "E", .F., .T.)
   @ C(086),C(076) ComboBox cComboBx1 Items aAreas   Size C(112),C(010)                              PIXEL OF oDlgG When IIF(kOperacao == "E", .F., .T.)
   @ C(107),C(005) MsGet    oGet6     Var   cEmail   Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG When IIF(kOperacao == "E", .F., .T.)

   @ C(125),C(053) Button IIF(kOperacao == "E", "Exclui", "Salvar") Size C(037),C(012) PIXEL OF oDlgG ACTION( SalvaGestor( kOperacao) )
   @ C(125),C(091) Button "Voltar"                                  Size C(037),C(012) PIXEL OF oDlgG ACTION( oDlgG:End() )

   ACTIVATE MSDIALOG oDlgG CENTERED 

Return(.T.)

// ################################################
// Função que salva as informações na tabela ZSC ##
// ################################################
Static Function SalvaGestor(kOperacao)

   If kOperacao == "E"
      If MsgYesNo("Deseja realmente excluir este registro?")
      Else
         Return(.T.)
      Endif
   Else
      If Empty(Alltrim(cCodUser))
         MsgAlert("Código de usuário do Sistema Protheus não vinculado ao gestor.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cNome))
         MsgAlert("Nome do Gestor não informado.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cDDD))
         MsgAlert("DDD telefone não informado.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cFone))
         MsgAlert("Nº telefone não informado.")
         Return(.T.)
      Endif

      If Substr(cComboBx1,01,06) == "000000"
         MsgAlert("Área do Gestor não selecionada.")
         Return(.T.)
      Endif

   Endif    

   // ###########
   // Inclusão ##
   // ###########
   If kOperacao == "I"

      // ##########################################
      // Pesquisa o próximo código para inclusão ##
      // ##########################################
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT MAX(ZSC_CODI) AS PROXIMO FROM " + RetSqlName("ZSC")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      IF T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := Strzero(INT(VAL(T_PROXIMO->PROXIMO)) + 1,6)
      Endif   

      dbSelectArea("ZSC")
      RecLock("ZSC",.T.)
      ZSC->ZSC_FILIAL := cFilAnt
      ZSC->ZSC_CODI   := xCodigo
      ZSC->ZSC_NOME   := cNome
      ZSC->ZSC_USER   := cCodUser
      ZSC->ZSC_DDD    := cDDD
      ZSC->ZSC_TELE   := cFone
      ZSC->ZSC_EMAI   := cEmail
      ZSC->ZSC_AREA   := Substr(cComboBx1,01,06)
      ZSC->ZSC_DELE   := ""
      MsUnLock()
   Endif
      
   // ############
   // Alteração ##
   // ############
   If kOperacao == "A"
      dbSelectArea("ZSC")
      DbSetOrder(1)
      If DbSeek(cFilAnt + cCodigo)
         RecLock("ZSC",.F.)
         ZSC->ZSC_NOME   := cNome
         ZSC->ZSC_USER   := cCodUser
         ZSC->ZSC_DDD    := cDDD
         ZSC->ZSC_TELE   := cFone
         ZSC->ZSC_EMAI   := cEmail
         ZSC->ZSC_AREA   := Substr(cComboBx1,01,06)
         MsUnLock()
      Endif
   Endif
      
   // ###########
   // Exclusão ##
   // ###########
   If kOperacao == "E"
      dbSelectArea("ZSC")
      DbSetOrder(1)
      If DbSeek(cFilAnt + cCodigo)
         RecLock("ZSC",.F.)
         ZSC->ZSC_DELE := "X"
         MsUnLock()
      Endif
   Endif

   // #########################################
   // Fecha a tela de manutenção do cadastro ##
   // #########################################
   oDlgG:End()

   // ####################################
   // Atualiza o gris com as alterações ##
   // ####################################
   CarregaZSC(1)
   
Return(.T.)   