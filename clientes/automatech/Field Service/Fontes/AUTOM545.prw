#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM545.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 13/03/2017                                                          ##
// Objetivo..: Abre informações do contrato vinculado ao produto/nº de série  na   ##
//             abertura de chamado técnico.                                        ##
// ##################################################################################

User Function AUTOM545(kChamado)

   Local cSql    := ""
   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3

    Local cRetorno   := ""
   Local cInformacao := ""

   Local nPosCodigo := aScan( aHeader, { |x| x[2] == 'AB7_CODPRO' } )
   Local nPosSeries := aScan( aHeader, { |x| x[2] == 'AB7_NUMSER' } )   

   If kChamado == 1
      cRetorno := aCols[n,nPosCodigo]
   Else
      cRetorno := aCols[n,nPosSeries]
   Endif   

   Private oDlg

   // ##############################################################################################
   // Pesquisa para ver se o número de serie informado está vinculado a um contrato de manutenção ##
   // ##############################################################################################
   If Select("T_CONTRATO") > 0
      T_CONTRATO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA3.AA3_FILIAL,"
   cSql += "       AA3.AA3_CODCLI,"
   cSql += "       AA3.AA3_LOJA  ,"
   cSql += "       AA3.AA3_CONTRT,"
   cSql += "       AA3.AA3_CODPRO,"
   cSql += "       AA3.AA3_NUMSER,"
   cSql += "       (SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AAH_INFO))"
   cSql += "          FROM " + RetSqlName("AAH") + " (NOLOCK)"
   cSql += "         WHERE AAH_FILIAL = AA3.AA3_FILIAL"
   cSql += "          AND AAH_CONTRT  = AA3.AA3_CONTRT"
   cSql += "          AND D_E_L_E_T_  = '') AS INFORMACAO"
   cSql += "  FROM " + RetSqlName("AA3") + " AA3 (NOLOCK)"
   cSql += " WHERE AA3_FILIAL  = '" + Alltrim(cFilAnt)              + "'"
   cSql += "   AND AA3_CODCLI  = '" + Alltrim(M->AB6_CODCLI)        + "'"
   cSql += "   AND AA3_LOJA    = '" + Alltrim(M->AB6_LOJA)          + "'"
   cSql += "   AND AA3_CODPRO  = '" + Alltrim(aCols[n, nPosCodigo]) + "'"
   cSql += "   AND AA3_NUMSER  = '" + Alltrim(aCols[n, nPosSeries]) + "'"
   cSql += "   AND AA3_CONTRT <> ''"
   cSql += "   AND D_E_L_E_T_  = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATO", .T., .T. )

   If T_CONTRATO->( EOF() )
      Return(cRetorno)
   Else
      cInformacao := ""
      cInformacao := "Produto: "     + Alltrim(aCols[n, nPosCodigo]) + " - " + Alltrim(POSICIONE("SB1",1,XFILIAL("SB1")  + aCols[n, nPosCodigo], "B1_DESC")) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Nº de Série: " + Alltrim(aCols[n, nPosSeries])                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Está vinculado ao contrato de nº " + Alltrim(T_CONTRATO->AA3_CONTRT) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "INFORMAÇÕES GERAIS DO CONTRATO DE MANUTENÇÃO:"                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     Alltrim(T_CONTRATO->INFORMACAO)                                       + chr(13) + chr(10)
   Endif

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Informação de Vínculo de Contrato ao Equipamento" FROM C(178),C(181) TO C(485),C(654) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(229),C(001) PIXEL OF oDlg
   @ C(132),C(002) GET oMemo2 Var cMemo2 MEMO Size C(229),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Informações referente ao contrato de manutenção" Size C(121),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) GET oMemo3 Var cInformacao MEMO Size C(227),C(083) PIXEL OF oDlg

   @ C(137),C(098) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
 
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(cRetorno)