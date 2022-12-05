#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM271.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/01/2015                                                          *
// Objetivo..: Pesquisa DIFAL pelo padrão                                          *
//**********************************************************************************

// Função que define a Window
User Function AUTOM271()
   
   Local lChumba := .F.

   Private cProposta := Space(06)
   Private cBaseRet  := 0
   Private cIcmsRet  := 0
   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg

   U_AUTOM628("AUTOM271")

   DEFINE MSDIALOG oDlg TITLE "Cálculo do DIFAL" FROM C(178),C(181) TO C(349),C(475) PIXEL

   @ C(008),C(010) Say "Nº Proposta Comercial" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(010) Say "Base Icms Retido"      Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(076) Say "Valor ICMS Retido"     Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(013),C(076) Button "Pesquisar DIFAL" Size C(060),C(012) PIXEL OF oDlg ACTION( buscaimpped(cProposta) )

   @ C(017),C(010) MsGet oGet1 Var cProposta Size C(049),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(048),C(010) MsGet oGet2 Var cBaseRet  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lChumba
   @ C(048),C(076) MsGet oGet3 Var cIcmsRet  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lChumba

   @ C(068),C(055) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED
   
Return(.T.)

// Função que pesquisa o ICMS conforme o pedido informado //
// ------------------------------------------------------ // 
// Variáveis retornadas pela função MaFisRet              //
// -----------------------------------------              //
// IT_ALIQICM  - Aliquota do ICMS                         //
// NF_VALICM   - Valor do ICMS                            //
// NF_BASEICM  - Base de Cálculo do ICMS                  //
// IT_ALIQIPI  - Aliquota do IPI                          //
// NF_VALIPI   - Valor do IPI                             //
// NF_BASEIPI  - Base de Cálculo do IPI                   //
// IT_VALMERC  - Valor da Mercadoria                      //
// IT_VALSOL   - Valor ICMS Solidário                     //
// LF_ICMSRET  - ICMS Retido (DIFAL)                      //
// LF_BASERET  - Base ICMS Retido (DIFAL)                 //
// NF_DESCZ    - ?????                                    //
// ------------------------------------------------------ //
Static function buscaimpped(cProposta)

   Local cSql            := ""
   Local nOrcamento      := ""
   Local nTotal_Proposta := 0
   Local nFrete          := 0
   
   If Empty(Alltrim(cProposta))
      Return(.T.)
   Endif
      
   // Pesquisa o nº do orçamento da proposta para pesquisa
   dbSelectArea("SCK")
   dbSetOrder(5)
   If dbSeek(xFilial("SCK") + cProposta)
      nOrcamento := SCK->CK_NUM
   Else
      Msgalert("Orçamento não localizado.")
      Return(.T.)
   Endif

   // Pesquisa o código e loja do cliente do orçamento
   dbSelectArea("SCJ")
   dbSetOrder(1)
   If !dbSeek(xFilial("SCJ") + nOrcamento) 
      MsgAlert("Cabeçalho de Orçamento não localizado.")
      Return(.T.)
   Endif

   cBaseRet := 0
   cIcmsRet := 0

   // Posiciona no registro da tabela ADY
   dbSelectArea("ADY")
   dbSetOrder(01)
   dbSeek(xFilial("ADY") + cProposta)

   nFrete := ADY_FRETE             
   
   // Pesquisa o valor total da proposta comercial
   If Select("T_TOTALPROPOSTA") > 0
      T_TOTALPROPOSTA->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT SUM(CK_VALOR) AS VLR_TOTAL"
   cSql += "  FROM " + RetSqlName("SCK")
   cSql += " WHERE CK_FILIAL  = '" + Alltrim(cFilAnt)   + "'"
   cSql += "   AND CK_PROPOST = '" + Alltrim(cProposta) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TOTALPROPOSTA", .T., .T. )

   nTotal_Proposta := T_TOTALPROPOSTA->VLR_TOTAL   

   // Posiciona os ítens do orçamento
   dbSelectArea("SCK")
   dbSetOrder(01)
   dbSeek(xFilial("SCK") + nOrcamento)

   WHILE !EOF() .AND. SCJ->CJ_NUM == SCK->CK_NUM

      // Posiciona o cadastro da TES da proposta comercial
      dbSelectArea("SF4")
      dbSetOrder(1)
      dbSeek(xFilial("SF4") + SCK->CK_TES)
      
      dbSelectArea("SCK")

      // Calcula a propostacionalidade do frete para cálculo do Difal
      n_Frete := Round(((nFrete * Round((((SCK->CK_QTDVEN*SCK->CK_PRCVEN) / nTotal_Proposta) * 100),2)) / 100),2)

      // Calculo dos Impostos
      MaFisIni(SCJ->CJ_CLIENTE,SCJ->CJ_LOJA,"C","N",,MaFisRelImp("MTR700",{"SCJ","SCK"}),,,"SB1","MTR700")
      MaFisAdd(SCK->CK_PRODUTO, SCK->CK_TES, SCK->CK_QTDVEN, SCK->CK_PRCVEN, SCK->CK_VALDESC, "", "", 0, 0, 0, 0, 0, ( (SCK->CK_QTDVEN*SCK->CK_PRCVEN) + n_Frete ), 0, 0, 0)

      cBaseRet  := cBaseRet + MaFisRet(1,"LF_BASERET")
      cIcmsRet  := cIcmsRet + MaFisRet(1,"LF_ICMSRET")

      oGet2:Refresh()
      oGet3:Refresh()

      MaFisEnd()

      DBSKIP()

   ENDDO
   
Return(.T.)