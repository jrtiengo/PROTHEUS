#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM210.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho                                            *
// -------------------------------------------------------------------------------* *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 14/02/2014                                                           *
// Objetivo..: Planilha das variáveis do cálculo do diferencial de alíquota da pro- *
//             posta comercial.                                                     *
//***********************************************************************************

User Function AUTOM210(cPar1, cPar2)

   Local lChumba   := .F.

   Local nBase1	   := 0
   Local nBase2	   := 0
   Local nPerc1    := 0
   Local nPerc2	   := 0
   Local nIcms1	   := 0
   Local nIcms2    := 0
   Local nSubtotal := 0
   Local nFrete    := 0
   Local nRetido   := 0
   Local nTotal    := 0

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7                                 
   Local oGet8
   Local oGet9
   Local oGet10

   Private cStrSql      := ""
   Private nDiferencial := 0
   Private aPrdSol      := {}
   Private aResumoV     := {} 

   Private oDlgD

   U_AUTOM628("AUTOM210")

   MsgAlert("Aguarde! Em Desenvolvimento.")
   
   Return(.T.)
	
   // Pesquisa os produtos da Proposta Comercial
   cStrSql := " SELECT ADY.*        , "
   cStrSql += "        ADZ.*        , "
   cStrSql += "        SB1.B1_GARANT, "
   cStrSql += "        SB1.B1_DESC  , "
   cStrSql += "        SB1.B1_DAUX    "
   cStrSql += "    FROM " + RetSqlName("ADZ") + " ADZ , "
   cStrSql += "         " + RetSqlName("ADY") + " ADY , "
   cStrSql += "         " + RetSqlName("SB1") + " SB1   "
   cStrSql += "  WHERE ADY.ADY_PROPOS  = '" + Alltrim(M->ADY_PROPOS) + "' "
   cStrSql += "    AND ADY.ADY_PROPOS   = ADZ.ADZ_PROPOS "
   cStrSql += "    AND ADY.D_E_L_E_T_   = ' ' "
   cStrSql += "    AND ADZ.D_E_L_E_T_   = ' ' "
   cStrSql += "    AND ADY.ADY_FILIAL   = '" + Alltrim(M->ADY_FILIAL) + "'"
   cStrSql += "    AND ADZ.ADZ_FILIAL   = '" + Alltrim(M->ADY_FILIAL) + "'"
   cStrSql += "    AND ADZ.ADZ_PRODUT   = SB1.B1_COD "
   cStrSql += "  ORDER BY ADY.ADY_FILIAL, ADZ.ADZ_PROPOS , ADZ.ADZ_ITEM"

   If( Select( "TMPO" ) != 0 )
      TMPO->( DbCloseArea() )
   EndIf

   // Captura as variáveis para display
   cStrSql := ChangeQuery( cStrSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrSql),"TMPO",.T.,.T.)

   DbSelectArea("TMPO")

   Do while !eof()
	  aAdd( aPrdSol, { TMPO->ADZ_PRODUTO, TMPO->ADZ_TOTAL, TMPO->ADZ_TES, TMPO->ADZ_MOEDA, TMPO->ADZ_ITEM, TMPO->ADZ_DESCRI } )
      nDiferencial := U_AUTOM208( aPrdSol, TMPO->ADY_CODIGO, TMPO->ADY_LOJA, TMPO->ADY_FRETE, IIF(TMPO->ADZ_MOEDA == "1", 1, 2), "I", "", "", M->ADY_FILIAL )
      DbSelectArea("TMPO")
      TMPO->( dbSkip() )                                   
   Enddo

   DEFINE MSDIALOG oDlgD TITLE "Variáveis de Cálculo Diferencial de Alíquota" FROM C(178),C(181) TO C(482),C(960) PIXEL

   @ C(005),C(005) Say "Ítens da Proposta Comercial" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgD

   @ C(136),C(347) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End() )

   // Cria Componentes Padroes do Sistema
   @ 015,005 LISTBOX oResumoV FIELDS HEADER "cItem", "cProd", "Descrição dos Produtos", "cOri", "cEst", "cTip", "cGrp", "cGtp", "cTes", "cCfop", "cIcm", "cSol", "Total Produto", "% I.Estadual", "Vlr Icm IEstd.", "Total Produto", "% Interno", "Vlr Icm Interno", "Moeda" PIXEL SIZE 489,152 OF oDlgD ;
                              ON dblClick(aResumoV[oResumoV:nAt,1] := !aResumoV[oResumoV:nAt,1],oResumoV:Refresh())     

   oResumoV:SetArray( aResumoV )
   oResumoV:bLine := {||     {aResumoV[oResumoV:nAt,01],;
             		    	  aResumoV[oResumoV:nAt,02],;
         	         	      aResumoV[oResumoV:nAt,03],;
         	         	      aResumoV[oResumoV:nAt,04],;
         	         	      aResumoV[oResumoV:nAt,05],;
         	         	      aResumoV[oResumoV:nAt,06],;
         	         	      aResumoV[oResumoV:nAt,07],;
         	         	      aResumoV[oResumoV:nAt,08],;
         	         	      aResumoV[oResumoV:nAt,09],;
         	         	      aResumoV[oResumoV:nAt,10],;
         	         	      aResumoV[oResumoV:nAt,11],;
         	         	      aResumoV[oResumoV:nAt,12],;
         	         	      str(aResumoV[oResumoV:nAt,13],10,02),;
         	         	      str(aResumoV[oResumoV:nAt,14],06,02),;
         	         	      str(aResumoV[oResumoV:nAt,15],10,02),;
         	         	      str(aResumoV[oResumoV:nAt,16],10,02),;
         	         	      str(aResumoV[oResumoV:nAt,17],06,02),;
         	         	      str(aResumoV[oResumoV:nAt,18],10,02),;
         	         	      aResumoV[oResumoV:nAt,19]}}

   ACTIVATE MSDIALOG oDlgD CENTERED

Return(.T.)