#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: AUTOM648.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 17/10/2017                                                                ##
// Objetivo..: Programa que altera a hora do documengo de entrada                        ##
// ########################################################################################

User Function AUTOM648()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local oMemo1
   
   Private lEdita   := .F.
   Private cNota	:= Space(09)
   Private cSerie	:= Space(03)
   Private cCliente := Space(60)
   Private cHora    := Space(08)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Alteração Hora Documento de Entrada" FROM C(178),C(181) TO C(386),C(557) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(181),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Nº Nota Fiscal" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(047) Say "Série"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Cliente"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(005) Say "Hora "          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(005) MsGet  oGet1 Var cNota    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(047),C(047) MsGet  oGet2 Var cSerie   Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(068),C(005) MsGet  oGet3 Var cCliente Size C(179),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(044),C(070) Button "Pesquisar"        Size C(037),C(012) PIXEL OF oDlg ACTION( BscNfHora() )

   @ C(090),C(005) MsGet oGet4 Var cHora     Size C(036),C(009) COLOR CLR_BLACK Picture "XX:XX:XX" PIXEL OF oDlg When lEdita

   @ C(087),C(070) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvNfHora() ) When lEdita
   @ C(087),C(113) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
  
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################
// Função que pesquisa a nota fiscal/série informada ##
// ####################################################
Static Function BscNfHora()

   Local cSql    := ""

   If Empty(Alltrim(cNota))
      MsgAlert("Nota Fiscal a ser pesquisada não informada. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cSerie))
      MsgAlert("Série da Nota Fiscal a ser pesquisada não informada. Verifique!")
      Return(.T.)
   Endif

   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_NOTAFISCAL") > 0
      T_NOTAFISCAL->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT SF1.F1_FILIAL ,"
   cSql += "       SF1.F1_DOC    ,"
   cSql += " 	   SF1.F1_FORNECE,"
   cSql += "	   SF1.F1_LOJA   ,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "       SF1.F1_HORA    "
   cSql += "  FROM " + RetSqlName("SF1") + " SF1, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SF1.F1_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND SF1.F1_DOC     = '" + Alltrim(cNota)   + "'"
   cSql += "   AND SF1.F1_SERIE   = '" + Alltrim(cSerie)  + "'"
   cSql += "   AND SF1.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SF1.F1_FORNECE"
   cSql += "   AND SA1.A1_LOJA    = SF1.F1_LOJA   "
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAFISCAL", .T., .T. )
   
   If T_NOTAFISCAL->( EOF() )
      MsgAlert("Nota Fiscal/Série não localizada. Verifique!")
      Return(.T.)
   Endif
   
   cCliente := T_NOTAFISCAL->F1_FORNECE + "." + T_NOTAFISCAL->F1_LOJA + "-" + Alltrim(T_NOTAFISCAL->A1_NOME)
   cHora    := T_NOTAFISCAL->F1_HORA
   
   If Empty(Alltrim(T_NOTAFISCAL->F1_HORA))
      lEdita := .T.
   Else
      lEdita := .F.      
   Endif
   
Return(.T.)

// ##############################################################
// Função que salva a hora para a nota fiscal/série pesquisada ##
// ##############################################################
Static Function SlvNfHora()

   Local cFornecedor := Substr(cCliente,01,06)
   Local cLojaFornec := Substr(cCliente,08,03)

   dbSelectArea("SF1")
   dbSetOrder(1)
   If DbSeek( xFilial("SF1") + cNota + cSerie + cFornecedor + cLojaFornec)
	  RecLock("SF1",.F.)
	  SF1->F1_HORA := cHora
	  MsUnlock()
   Endif
	  
   lEdita   := .F.
   cNota    := Space(09)
   cSerie   := Space(03)
   cCliente := Space(60)
   cHora    := Space(08)
  
   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()         

Return(.T.)