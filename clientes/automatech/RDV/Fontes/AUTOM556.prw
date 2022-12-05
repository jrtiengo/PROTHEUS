#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM556.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 11/04/2017                                                           *
// Objetivo..: Manutenção Cadastro de Áreas                                         *
//***********************************************************************************

User Function AUTOM556()

   Local cMemo1	 := ""
   Local oMemo1

   Private aBrowse := {}

   Private oDlg

   // ##################################################
   // Função que carrega o grid com dados do cadastro ##
   // ##################################################
   CarregaZSF(0)

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Áreas" FROM C(178),C(181) TO C(506),C(710) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(257),C(001) PIXEL OF oDlg

   @ C(147),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManAreas("I", "", "") )
   @ C(147),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( ManAreas("A", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]) )
   @ C(147),C(081) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManAreas("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]) )
   @ C(147),C(223) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 050 , 005, 326, 133,,{'Código', 'Descrição das Áreas'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################
// Função que carrega o grid com dados do cadastro ##
// ##################################################
Static Function CarregaZSF(kTipo)

   Local cSql := ""
   
   aBrowse := {}
   
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
   
   WHILE !T_AREA->( EOF() )
      aAdd( aBrowse, { T_AREA->ZSF_CODI, T_AREA->ZSF_NOME })
      T_AREA->( DbSkip() )
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
Static Function ManAreas(kOperacao, kCodigo, kDescricao)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cCodigo	  := IIF(kOperacao == "I", Space(06), kCodigo)
   Private cDescricao := IIF(kOperacao == "I", Space(40), kDescricao)

   Private oGet1
   Private oGet2

   Private oDlgM

   DEFINE MSDIALOG oDlgM TITLE "Cadastro de Áreas" FROM C(178),C(181) TO C(380),C(570) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(022) PIXEL NOBORDER OF oDlgM

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(187),C(001) PIXEL OF oDlgM
   @ C(078),C(002) GET oMemo2 Var cMemo2 MEMO Size C(187),C(001) PIXEL OF oDlgM
   
   @ C(033),C(005) Say "Código"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(055),C(005) Say "Descrição da Área" Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   
   @ C(042),C(005) MsGet oGet1 Var cCodigo    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
   @ C(064),C(005) MsGet oGet2 Var cDescricao Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When iif(kOperacao == "E", .F., .T.)

   @ C(084),C(060) Button IIF(kOperacao == "E", "Exclui", "Salvar") Size C(037),C(012) PIXEL OF oDlgM ACTION( SalvaArea( kOperacao, cCodigo, cDescricao) )
   @ C(084),C(098) Button "Voltar"                                  Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// ################################################
// Função que salva as informações na tabela ZSF ##
// ################################################
Static Function SalvaArea(kOperacao, kCodigo, kDescricao)

   If kOperacao == "E"
      If MsgYesNo("Deseja realmente excluir este registro?")
      Else
         Return(.T.)
      Endif
   Else
      If Empty(Alltrim(kDescricao))
         MsgAlert("Descrição da área não informada.")
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
      cSql := "SELECT MAX(ZSF_CODI) AS PROXIMO FROM " + RetSqlName("ZSF")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      IF T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := Strzero(INT(VAL(T_PROXIMO->PROXIMO)) + 1,6)
      Endif   

      dbSelectArea("ZSF")
      RecLock("ZSF",.T.)
      ZSF->ZSF_FILIAL := cFilAnt
      ZSF->ZSF_CODI   := xCodigo
      ZSF->ZSF_NOME   := kDescricao
      ZSF->ZSF_DELE   := ""
      MsUnLock()
   Endif
      
   // ############
   // Alteração ##
   // ############
   If kOperacao == "A"
      dbSelectArea("ZSF")
      DbSetOrder(1)
      If DbSeek(cFilAnt + kCodigo)
         RecLock("ZSF",.F.)
         ZSF->ZSF_NOME   := kDescricao
         MsUnLock()
      Endif
   Endif
      
   // ###########
   // Exclusão ##
   // ###########
   If kOperacao == "E"
      dbSelectArea("ZSF")
      DbSetOrder(1)
      If DbSeek(cFilAnt + kCodigo)
         RecLock("ZSF",.F.)
         ZSF->ZSF_DELE := "X"
         MsUnLock()
      Endif
   Endif

   // #########################################
   // Fecha a tela de manutenção do cadastro ##
   // #########################################
   oDlgM:End()

   // ####################################
   // Atualiza o gris com as alterações ##
   // ####################################
   CarregaZSF(1)
   
Return(.T.)   