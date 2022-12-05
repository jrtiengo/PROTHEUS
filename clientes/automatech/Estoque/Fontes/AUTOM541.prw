#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM541.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 23/02/2017                                                               ##
// Objetivo..: Programa que limpa o campo A1_VEND para vendedores do tipo Gerente       ##
// #######################################################################################

User Function AUTOM541()

   Local lChumba := .F.
   Local cSql    := ""
   Local cMemo1	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo3

   Local cExecutivo := 0
   Local cGerente   := 0
   Local cEmBranco  := 0
   Local cTotalCli  := 0

   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8

   Private oDlg

   U_AUTOM628("AUTOM541")

   // ######################################################
   // Pesquisa o total de clientes com vendedor Executivo ##
   // ######################################################
   If (Select( "T_EXECUTIVOS" ) != 0 )
      T_EXECUTIVOS->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT COUNT(*) AS EXECUTIVO"
   cSql += "  FROM " + RetSqlName("SA1") + " (Nolock) SA1, "
   cSql += "       " + RetSqlName("SA3") + " (Nolock) SA3  "
   cSql += " WHERE SA3.A3_COD     = SA1.A1_VEND"
   cSql += "   AND SA3.D_E_L_E_T_ = '' "
   cSql += "   AND SA3.A3_ZTBI    = '1'"   
   cSql += "   AND SA1.A1_VEND   <> '' "
   cSql += "   AND SA1.D_E_L_E_T_ = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_EXECUTIVOS",.T.,.T.)

   cExecutivo := IIF(T_EXECUTIVOS->( EOF() ), 0, T_EXECUTIVOS->EXECUTIVO)

   // ####################################################
   // Pesquisa o total de clientes com vendedor Gerente ##
   // ####################################################
   If (Select( "T_GERENTE" ) != 0 )
      T_GERENTE->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT COUNT(*) AS GERENTE"
   cSql += "  FROM " + RetSqlName("SA1") + " (Nolock) SA1, "
   cSql += "       " + RetSqlName("SA3") + " (Nolock) SA3  "
   cSql += " WHERE SA3.A3_COD     = SA1.A1_VEND"
   cSql += "   AND SA3.D_E_L_E_T_ = '' "
   cSql += "   AND SA3.A3_ZTBI   <> '1'"   
   cSql += "   AND SA1.A1_VEND   <> '' "
   cSql += "   AND SA1.D_E_L_E_T_ = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_GERENTE",.T.,.T.)

   cGerente := IIF(T_GERENTE->( EOF() ), 0, T_GERENTE->GERENTE)

   // ##########################################################
   // Pesquisa o total de clientes sem informação de vendedor ##
   // ##########################################################
   If (Select( "T_VAZIO" ) != 0 )
      T_VAZIO->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT COUNT(*) AS VAZIO"
   cSql += "  FROM " + RetSqlName("SA1") + " (Nolock) SA1 "
   cSql += " WHERE SA1.D_E_L_E_T_ = '' "
   cSql += "   AND SA1.A1_VEND    = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_VAZIO",.T.,.T.)

   cEmBranco := IIF(T_VAZIO->( EOF() ), 0, T_VAZIO->VAZIO)

   // ##############################
   // Calcula o total de clientes ##
   // ##############################
   cTotalcli := cExecutivo + cGerente + cEmBranco

   DEFINE MSDIALOG oDlg TITLE "Sales Machine - Consulta / Recálculo" FROM C(178),C(181) TO C(440),C(526) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(164),C(001) PIXEL OF oDlg
   @ C(108),C(002) GET oMemo3 Var cMemo3 MEMO Size C(164),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Programa que limpa o código do vendedor 1 no cadastro de clientes." Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(044),C(005) Say "Somente será limpo o campo vendedor para vendedores Gerente."       Size C(156),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(039) Say "Clientes com vendedor EXECUTIVO"                                    Size C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(039) Say "Clientes com vendedor GERENTE"                                      Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(039) Say "Clientes com vendedor EM BRANCO"                                    Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(096),C(039) Say "Total de Clientes"                                                  Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	   
   @ C(056),C(005) MsGet oGet5 Var cExecutivo Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(069),C(005) MsGet oGet6 Var cGerente   Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(082),C(005) MsGet oGet7 Var cEmBranco  Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(095),C(005) MsGet oGet8 Var cTotalCli  Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(114),C(048) Button "Processar" Size C(037),C(012) PIXEL OF oDlg ACTION( LimpaVendedor() )
   @ C(114),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ########################################################################
// Função que limpa o código do vendedor Gerente do cadastro de clientes ##
// ########################################################################
Static Function LimpaVendedor()

   If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente limpar o código do vendedor 1 para clientes com vendedores GERENTE?")

      MsgRun("Favor Aguarde! Limpando Vendedor do Cad. de Clientes ...", "Cadastro de Clientes",{|| xLimpaVendedor() })
      
   Endif   

Return(.T.)

// ########################################################################
// Função que limpa o código do vendedor Gerente do cadastro de clientes ##
// ########################################################################
Static Function xLimpaVendedor()

   Local cSql := ""

   If (Select( "T_LIMPAR" ) != 0 )
      T_LIMPAR->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SA1.A1_COD  ,"
   cSql += "       SA1.A1_LOJA ,"
   cSql += "	   SA1.A1_NOME ,"
   cSql += "	   SA1.A1_VEND ,"
   cSql += "	   SA3.A3_TIPOV "
   cSql += "  FROM " + RetSqlName("SA1") + " (Nolock) SA1, "
   cSql += "       " + RetSqlName("SA3") + " (Nolock) SA3  "
   cSql += " WHERE SA3.A3_COD     = SA1.A1_VEND"
   cSql += "   AND SA3.D_E_L_E_T_ = ''         "
   cSql += "   AND SA3.A3_ZTBI   <> '1'        "
   cSql += "   AND SA1.A1_VEND   <> ''         "
   cSql += "   AND SA1.D_E_L_E_T_ = ''         "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_LIMPAR",.T.,.T.)

   T_LIMPAR->( DbGoTop() )
   
   WHILE !T_LIMPAR->( EOF() )

      DbSelectArea("SA1")
      DbSetOrder(1)
      If DbSeek(xfilial("SA1") + T_LIMPAR->A1_COD + T_LIMPAR->A1_LOJA )
         Reclock("SA1",.F.)
         SA1->A1_VEND := ""
         Msunlock()
      Endif
      
      T_LIMPAR->( DbSkip() )
      
   ENDDO

   MsgAlert("Campo vendedor 1 limpado com sucesso!")
   
Return(.T.)