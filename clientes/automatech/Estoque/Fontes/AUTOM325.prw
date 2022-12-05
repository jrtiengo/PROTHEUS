#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM325.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                    *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/12/2015                                                          *
// Objetivo..: Programa que permite o usuário a realizar inativação de produtos    *
//**********************************************************************************

User Function AUTOM325()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private lRegra1 := .F.
   Private lRegra2 := .F.
   Private oRegra1
   Private oRegra2
  
   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Inativação de Produtos Cfme. Regra" FROM C(178),C(181) TO C(323),C(565) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(184),C(001) PIXEL OF oDlg

   @ C(045),C(017) CheckBox oRegra1 Var lRegra1 Prompt "Inativação pela Regra 1" Size C(071),C(008) PIXEL OF oDlg
   @ C(059),C(017) CheckBox oRegra2 Var lRegra2 Prompt "Inativação pela Regra 2" Size C(070),C(008) PIXEL OF oDlg
   
   @ C(048),C(101) Button "Inativar" Size C(037),C(012) PIXEL OF oDlg ACTION( BscInativa() )
   @ C(048),C(142) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa produtos conforme parâmetros informados
Static Function BscInativa()

  MsgRun("Favor Aguarde! Inativando Produtos ...", "Inativando Produtos",{|| ZZZInativa2() })

Return(.T.)

// Função que pesquisa produtos conforme parâmetros informados
Static Function ZZZInativa2()

   Local cSql := ""

   If lRegra1 == .F. .And. lRegra2 == .F.
      MsgAlert("Necessário indicar o tipo de inativação a ser executada.")
      Return(.T.)
   Endif

   If lRegra1 == .T. .And. lRegra2 == .T.
      MsgAlert("Indique apelas uma opção de cada vez.")
      Return(.T.)
   Endif
   
   // Seleciona produtos regra 1
   If Select("T_PRODUTOS") <>  0
      T_PRODUTOS->(DbCloseArea())
   EndIf

   If lRegra1 == .T.

      cSql := ""
      cSql := "SELECT SB1.B1_COD AS CODIGO,"
      cSql += "       LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS DESCRICAO,"
	  cSql += "       SB1.B1_POSIPI AS PART_NUMBER  ,"
   	  cSql += "       SB1.B1_GRUPO AS CODIGO_GRUPO  ,"
   	  cSql += "       SBM.BM_DESC AS DESCRICAO_GRUPO,"
      cSql += "       CASE WHEN (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2010 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '') IS NULL THEN 0"
      cSql += "            ELSE (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2010 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '')               "
	  cSql += "       END AS SALDO_AUTOMATECH,"
      cSql += "       CASE WHEN (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2020 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '') IS NULL THEN 0"
      cSql += "            ELSE (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2020 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '')               "
	  cSql += "       END AS SALDO_TI  "
      cSql += "  FROM " + RetSqlName("SB1") + " SB1, "
      cSql += "       " + RetSqlName("SBM") + " SBM  "
      cSql += " WHERE SB1.B1_GRUPO IN ('0100', '0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110', '0111', '0112', '0113', '0114', '0115', '0116', '0117', '0118', '0119', '0120', '0121', '0122', '0123', '0124', '0125', '0126', '0127', '0500')"
      cSql += "   AND SUBSTRING(SB1.B1_DESC,01,03) <> 'MAN'"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
      cSql += "   AND (CASE WHEN (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2010 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '') IS NULL THEN 0"
      cSql += "             ELSE (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2010 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '')               "
  	  cSql += "        END) = 0"
      cSql += "   AND (CASE WHEN (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2020 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '') IS NULL THEN 0"
      cSql += "             ELSE (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2020 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '')               "
	  cSql += "        END) = 0"
      cSql += "   AND SBM.BM_GRUPO   = SB1.B1_GRUPO"
      cSql += "   AND SBM.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_PARNUM  = ''"
      cSql += "   AND B1_MSBLQL     <> '1'"
      cSql += " ORDER BY SB1.B1_GRUPO, SB1.B1_DESC "
      
   Endif
      
   // Seleciona produtos regra 2
   If lRegra2 == .T.

      cSql := ""
      cSql := "SELECT SB1.B1_COD AS CODIGO,"
      cSql += "       LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS DESCRICAO,"
	  cSql += "       SB1.B1_POSIPI AS PART_NUMBER,"
	  cSql += "       SB1.B1_GRUPO AS CODIGO_GRUPO,"
	  cSql += "       SBM.BM_DESC AS DESCRICAO_GRUPO,"
      cSql += "       CASE WHEN (SELECT TOP(1) D1_EMISSAO FROM SD1010 WHERE D1_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D1_EMISSAO DESC) IS NULL THEN ''"
 	  cSql += "            ELSE (SELECT TOP(1) D1_EMISSAO FROM SD1010 WHERE D1_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D1_EMISSAO DESC)                "
      cSql += "       END AS ULTIMA_ENTRADA, "
      cSql += "       CASE WHEN (SELECT TOP(1) D2_EMISSAO FROM SD2010 WHERE D2_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D2_EMISSAO DESC) IS NULL THEN ''"
 	  cSql += "            ELSE (SELECT TOP(1) D2_EMISSAO FROM SD2010 WHERE D2_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D2_EMISSAO DESC)                "
      cSql += "       END AS ULTIMA_SAIDA,"
      cSql += "       CASE WHEN (SELECT TOP(1) D3_EMISSAO FROM SD3010 WHERE D3_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D3_EMISSAO DESC) IS NULL THEN ''"
 	  cSql += "            ELSE (SELECT TOP(1) D3_EMISSAO FROM SD3010 WHERE D3_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D3_EMISSAO DESC)                "
      cSql += "       END AS ULTIMA_AJUSTE"
      cSql += "  FROM " + RetSqlName("SB1") + " SB1, "
      cSql += "       " + RetSqlName("SBM") + " SBM  "
      cSql += " WHERE SB1.B1_GRUPO IN ('0100', '0101', '0102', '0103', '0104', '0105', '0106', '0107', '0108', '0109', '0110', '0111', '0112', '0113', '0114', '0115', '0116', '0117', '0118', '0119', '0120', '0121', '0122', '0123', '0124', '0125', '0126', '0127', '0500')"
      cSql += "   AND SUBSTRING(SB1.B1_DESC,01,03) <> 'MAN'"
      cSql += "   AND B1_MSBLQL     <> '1'   "
      cSql += "   AND SB1.D_E_L_E_T_ = ''    "
      cSql += "   AND SBM.BM_GRUPO   = SB1.B1_GRUPO"
      cSql += "   AND SBM.D_E_L_E_T_ = ''          "
      cSql += "   AND ((SELECT MAX(D1_EMISSAO) FROM " + RetSqlName("SD1") + " WHERE D1_COD = SB1.B1_COD AND D_E_L_E_T_ = '') < (GETDATE() - 730)"
      cSql += "   AND (SELECT MAX(D2_EMISSAO)  FROM " + RetSqlName("SD2") + " WHERE D2_COD = SB1.B1_COD AND D_E_L_E_T_ = '') < (GETDATE() - 730) "
      cSql += "   AND (SELECT MAX(D3_EMISSAO)  FROM " + RetSqlName("SD3") + " WHERE D3_COD = SB1.B1_COD AND D_E_L_E_T_ = '') < (GETDATE() - 730))"
      cSql += "   AND (CASE WHEN (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2010 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '') IS NULL THEN 0"
      cSql += "             ELSE (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2010 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '')               "
   	  cSql += "        END) = 0"
      cSql += "   AND (CASE WHEN (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2020 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '') IS NULL THEN 0"
      cSql += "             ELSE (SELECT SUM((B2_QATU + B2_QPEDVEN + B2_QEMPSA + B2_QNPT + B2_QEMPN + B2_QEMPPRJ + B2_QEMP + B2_SALPEDI + B2_RESERVA + B2_QTNP + B2_QTER + B2_QACLASS + B2_QEMPPRE)) FROM SB2020 WHERE B2_COD = SB1.B1_COD AND  D_E_L_E_T_ = '')               "
	  cSql += "        END) = 0"
      cSql += " ORDER BY CASE WHEN (SELECT TOP(1) D1_EMISSAO FROM " + RetSqlName("SD1") + " WHERE D1_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D1_EMISSAO DESC) IS NULL THEN ''"
 	  cSql += "               ELSE (SELECT TOP(1) D1_EMISSAO FROM " + RetSqlName("SD1") + " WHERE D1_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D1_EMISSAO DESC)                "
      cSql += "          END,"
      cSql += "          CASE WHEN (SELECT TOP(1) D2_EMISSAO FROM " + RetSqlName("SD2") + " WHERE D2_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D2_EMISSAO DESC) IS NULL THEN ''"
 	  cSql += "               ELSE (SELECT TOP(1) D2_EMISSAO FROM " + RetSqlName("SD2") + " WHERE D2_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D2_EMISSAO DESC)                "
      cSql += "          END,"
      cSql += "          CASE WHEN (SELECT TOP(1) D3_EMISSAO FROM " + RetSqlName("SD3") + " WHERE D3_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D3_EMISSAO DESC) IS NULL THEN ''"
 	  cSql += "               ELSE (SELECT TOP(1) D3_EMISSAO FROM " + RetSqlName("SD3") + " WHERE D3_COD = SB1.B1_COD AND D_E_L_E_T_ = '' ORDER BY D3_EMISSAO DESC)                "
      cSql += "          END"

   Endif

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTOS",.T.,.T.)

   If T_PRODUTOS->( EOF() )
      MsgAlert("Não existem produtos a serem inativados.")        
      Return(.T.)
   Endif
      
   // Inativa os produtos
   WHILE !T_PRODUTOS->( EOF() )

      cSql := ""       
      cSql := "UPDATE " + RetSqlName("SB1")
      cSql += "   SET " 
      cSql += "   B1_MSBLQL  = '1'"
      cSql += " WHERE B1_COD = '" + Alltrim(T_PRODUTOS->CODIGO) + "'"
          
      lResult := TCSQLEXEC(cSql)
      If lResult < 0
      EndIf 
          
      T_PRODUTOS->( DbSkip() )
       
   Enddo

   MsgAlert("Produtos inativados com sucesso.")
   
Return(.T.)