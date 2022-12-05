#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM278.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/03/2015                                                          *
// Objetivo..: Tela de visualização do log de separação de pedidos de venda        *
//**********************************************************************************

User Function AUTOM278()

   Local cMemo1	 := ""
   Local oMemo1
      
// Private aEmpresas := {"00 - Selecione a Empresa", "01 - Automatech", "02 - TI Automação", "03 - Atech"}
// Private aFiliais  := {"00 - Selecione a Filial", IIF(cEmpAnt == "01", "01 - Porto Alegre", "01 - Curitiba"), "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}

   Private aEmpresas := U_AUTOM539(1, "") 
   Private aFiliais  := U_AUTOM539(2, cEmpAnt) 

   Private cComboBx1
   Private cComboBx2
   Private cPedido	 := Space(06)
   Private cLog  	 := ""
   Private oGet1
   Private oMemo2

   Private oDlg

   U_AUTOM628("AUTOM278")

   DEFINE MSDIALOG oDlg TITLE "Log de Separação de Pedidos de Vendas" FROM C(178),C(181) TO C(618),C(830) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(158),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(317),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Empresa"                                       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(073) Say "Filial"                                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(185) Say "Pedido de Venda"                               Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Log da separação do pedido de venda informado" Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(046),C(005) ComboBox cComboBx1 Items aEmpresas Size C(063),C(010) PIXEL OF oDlg ON CHANGE ALTERACOMBO()
   @ C(046),C(073) ComboBox cComboBx2 Items aFiliais  Size C(107),C(010) PIXEL OF oDlg

   @ C(046),C(185) MsGet oGet1 Var cPedido Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(043),C(238) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( LogSepara() )
   @ C(043),C(281) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ C(070),C(005) GET oMemo2 Var cLog MEMO Size C(314),C(146) PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

Static Function AlteraCombo

   aFiliaIS := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(046),C(073) ComboBox cComboBx2 Items aFiliais  Size C(107),C(010) PIXEL OF oDlg

Return

// Função que pesquisa a log da separação do pedido informado
Static Function LogSepara()

   Local cSql := ""

   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Necessário selecionar a Empresa a ser pesqusiada.")
      Return(.T.)
   Endif
   
   If Substr(cComboBx2,01,02) == "00"
      MsgAlert("Necessário selecionar a Filial a ser pesqusiada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cPedido))
      MsgAlert("Necessário informar o pedido de venda a ser pesquisado.")
      Return(.T.)
   Endif
           
   If Select("T_LOGSEPARACAO") > 0
      T_LOGSEPARACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C5_FILIAL,"
   cSql += "       C5_NUM   ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C5_ZMSP)) AS LOG"
   cSql += "  FROM SC5" + Alltrim(Substr(cComboBx1,01,02)) + "0"
   cSql += " WHERE C5_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND C5_NUM     = '" + Alltrim(cPedido) + "'"
   cSql += "   AND D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOGSEPARACAO", .T., .T. )

   If T_LOGSEPARACAO->( EOF() )
      cLog := "Não existem dados a serem visualizados para este pedido de venda."
   Else
      cLog := T_LogSeparacao->LOG
   Endif
   
Return(.T.)