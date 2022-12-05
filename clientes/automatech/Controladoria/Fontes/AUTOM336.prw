#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##  
// Referencia: AUTOM336.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 06/04/2016                                                          ##
// Objetivo..: Programa que permite a COntroladoria alterar hora de emissão de doc.##
// ##################################################################################

User Function AUTOM336()

   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local cMemo3	    := ""
   Local cMemo4	    := ""
   Local lTemAcesso := .F.

   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4

   Private lEditar  := .F.
   Private xFilial  := U_AUTOM539(2, cEmpAnt) // {"00 - Selecione", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private xTipoDoc := {"0 - Selecione", "1 - Documento de Entrada", "2 - Documento de Saída"}
   Private cComboBx1
   Private cComboBx2

   Private cDocumento := Space(09)
   Private cSerie 	  := Space(03)
   Private cHora   	  := Space(06)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg

   // ##########################################################################
   // Verifica se o usuário logado possui permissão de acesso a este programa ##
   // ##########################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_AHOR" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If U_P_OCCURS(T_PARAMETROS->ZZ4_AHOR, UPPER(ALLTRIM(cUserName)), 1) == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif

   // #################################
   // Desenha tela para visualização ##
   // #################################
   DEFINE MSDIALOG oDlg TITLE "Altareação Hora Emissão Nota Fiscal" FROM C(178),C(181) TO C(563),C(519) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(160),C(001) PIXEL OF oDlg
   @ C(068),C(003) GET oMemo2 Var cMemo2 MEMO Size C(160),C(001) PIXEL OF oDlg
   @ C(145),C(003) GET oMemo4 Var cMemo4 MEMO Size C(160),C(001) PIXEL OF oDlg
   @ C(168),C(003) GET oMemo3 Var cMemo3 MEMO Size C(160),C(001) PIXEL OF oDlg
   
   @ C(041),C(005) Say "Este procedimento permite que seja alterada a hora de emissão"     Size C(152),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(005) Say "de notas fiscais de entrada e saída."                              Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Este procedimento somente poderá ser uilizado pela Controladoria." Size C(160),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(073),C(005) Say "Filial"                                                            Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(096),C(005) Say "Tipo de Documento a ser alterado"                                  Size C(082),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(121),C(005) Say "Nº do Documento"                                                   Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(121),C(056) Say "Série"                                                             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(153),C(039) Say "Hora"                                                              Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(082),C(005) ComboBox cComboBx2 Items xFilial    Size C(158),C(010) PIXEL OF oDlg When !lEditar
   @ C(106),C(005) ComboBox cComboBx1 Items xTipoDoc   Size C(158),C(010) PIXEL OF oDlg When !lEditar
   @ C(130),C(005) MsGet    oGet1     Var   cDocumento Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When !lEditar
   @ C(130),C(056) MsGet    oGet2     Var   cSerie     Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When !lEditar

   @ C(127),C(092) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PsqDocumento() ) When !lEditar

   @ C(152),C(057) MsGet oGet3 Var cHora Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lEditar
   @ C(150),C(092) Button "Salvar"       Size C(037),C(012)                              PIXEL OF oDlg When lEditar ACTION( GrvNovaHora() )

   @ C(174),C(065) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################
// Função que pesquisa a hora do documento informado ##
// ####################################################
Static Function PsqDocumento()

   Local cSql := ""

   If Substr(cComboBx2,01,02) == "00"
      MsgAlert("Filial não selecionada.")
      Return(.T.)
   Endif

   If Substr(cComboBx1,01,01) == "0"
      MsgAlert("Tipo de documento não selecionado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cDocumento))
      MsgAlert("Nº do documento não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cSerie))
      MsgAlert("Série do documento não informado.")
      Return(.T.)
   Endif

   // #########################################
   // Pesquisa a hora do documento informado ##
   // #########################################
   If Select("T_DOCUMENTO") > 0
      T_DOCUMENTO->( dbCloseArea() )
   EndIf
   
   If Substr(cComboBx1,01,01) == "1"
      cSql := ""
      cSql := "SELECT F1_FILIAL,"
      cSql += "       F1_DOC   ,"
      cSql += "	      F1_SERIE ,"
      cSql += "	      F1_HORA   "
      cSql += "  FROM " + RetSqlName("SF1")
      cSql += "  WHERE F1_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "    AND F1_DOC     = '" + Alltrim(cDocumento) + "'"
      cSql += "    AND F1_SERIE   = '" + Alltrim(cSerie)     + "'"
      cSql += "    AND D_E_L_E_T_ = ''"
   Else
      cSql := ""
      cSql := "SELECT F2_FILIAL,"
      cSql += "       F2_DOC   ,"
      cSql += "	      F2_SERIE ,"
      cSql += "	      F2_HORA   "
      cSql += "  FROM " + RetSqlName("SF2")
      cSql += "  WHERE F2_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "    AND F2_DOC     = '" + Alltrim(cDocumento) + "'"
      cSql += "    AND F2_SERIE   = '" + Alltrim(cSerie)     + "'"
      cSql += "    AND D_E_L_E_T_ = ''"
   Endif      

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DOCUMENTO", .T., .T. )

   If T_DOCUMENTO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")

      lEditar    := .F.
      cDocumento := Space(09)
      cSerie 	 := Space(03)
      cHora   	 := Space(06)

      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()

      Return(.T.)
   Endif
      
   If Substr(cComboBx1,01,01) == "1"
      cHora := T_DOCUMENTO->F1_HORA   
   Else
      cHora := T_DOCUMENTO->F2_HORA         
   Endif
   
   lEditar := .T.
   oGet3:Refresh()

Return(.T.)

// #########################################
// Função que grava a nova hora informada ##
// #########################################
Static Function GrvNovaHora()

   Local cSql := ""

   If Substr(cComboBx1,01,01) == "1"
      cSql := ""
      cSql := "UPDATE " + RetSqlName("SF1")
      cSql += "   SET " 
      cSql += "	  F1_HORA = '" + Alltrim(cHora) + "'"
      cSql += "  WHERE F1_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "    AND F1_DOC     = '" + Alltrim(cDocumento) + "'"
      cSql += "    AND F1_SERIE   = '" + Alltrim(cSerie)     + "'"
      cSql += "    AND D_E_L_E_T_ = ''"
   Else
      cSql := ""
      cSql := "UPDATE " + RetSqlName("SF2")
      cSql += "   SET " 
      cSql += "	  F2_HORA = '" + Alltrim(cHora) + "'"
      cSql += "  WHERE F2_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "    AND F2_DOC     = '" + Alltrim(cDocumento) + "'"
      cSql += "    AND F2_SERIE   = '" + Alltrim(cSerie)     + "'"
      cSql += "    AND D_E_L_E_T_ = ''"
   Endif      

   lResult := TCSQLEXEC(cSql)

   If lResult < 0
      Return MsgStop("Erro durante a alteração das parcelas: " + TCSQLError())
   EndIf 

   lEditar    := .F.
   cDocumento := Space(09)
   cSerie 	  := Space(03)
   cHora   	  := Space(06)

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()

Return(.T.)