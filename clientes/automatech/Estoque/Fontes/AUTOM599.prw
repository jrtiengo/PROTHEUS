#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM599.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 10/08/2017                                                              ##
// Objetivo..: Programa que consulta produção por facas                                ##
// ######################################################################################

User Function AUTOM599()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private cDataIni := Ctod("  /  /    ")
   Private cDataFim := Ctod("  /  /    ")
   Private cString  := Space(60)

   Private oGet1
   Private oGet2
   Private oGet3

   DEFINE FONT oFont Name "Courier New" Size 0, 14

   Private aLista := {}

   Private oDlg

   U_AUTOM628("AUTOM599")

   DEFINE MSDIALOG oDlg TITLE "Consulta Consumo de Produtos" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(039),C(005) Say "Período Inicial" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(048) Say "Período Final"   Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(092) Say "String"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(049),C(005) MsGet oGet1 Var cDataIni Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(049),C(048) MsGet oGet2 Var cDataFim Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(049),C(092) MsGet oGet3 Var cString  Size C(137),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(046),C(235) Button "Pesquisar"           Size C(037),C(012) PIXEL OF oDlg ACTION( PegaDadosFiltro() )
   @ C(210),C(362) Button "Exportar para Excel" Size C(056),C(012) PIXEL OF oDlg ACTION( yGeraResCSV() )
   @ C(210),C(462) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { "", "", "", "", "", "" })

   // ##################################################
   // Desenha a Lista para visualização dos resultado ##
   // ##################################################
   @ 085,005 LISTBOX oList FIELDS HEADER "Nº OP" + sPACE(15), "Faca" + Space(15), "Produto" + Space(30), "Descrição dos Produtos" + Space(60), "Quantidade" + Space(15), "Data Entrega" + Space(10) PIXEL SIZE 633,180 FONT oFont OF oDlg ;             
                           ON LEFT DBLCLICK ( TrocaCor()), ON RIGHT CLICK (TrocaCor())

   oList:SetArray( aLista )

   oList:bLine := {||     {aLista[oList:nAt,01],;
                    	   aLista[oList:nAt,02],;
          				   aLista[oList:nAt,03],;
          				   aLista[oList:nAt,04],;
          				   aLista[oList:nAt,05],;
          				   aLista[oList:nAt,06]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ############################################################
// Função que pesquisa os produtos conforme filtro informado ##
// ############################################################
Static Function PegaDadosFiltro()

   MsgRun("Aguarde! Pesquisando informações conforme parâmetros ...", "Pesquisa de Informações",{|| xPegaDadosFiltro() })

Return(.T.)

// ############################################################
// Função que pesquisa os produtos conforme filtro informado ##
// ############################################################
Static Function xPegaDadosFiltro()

   Local cSql := ""

   If Empty(cDataIni)
      MsgAlert("Necessário informar data inicial para pesquisa.")
      Return(.T.)
   Endif
      
   If Empty(cDataFim)
      MsgAlert("Necessário informar data final para pesquisa.")
      Return(.T.)
   Endif

   // ############################################## 
   // Limpa o array para receber novos resultados ##
   // ##############################################
   aLista := {}

   // ############################################## 
   // Pesquisa os dados conforme filtro informado ##
   // ##############################################
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC2.C2_FILIAL ,"
   cSql += "       SC2.C2_NUM    ,"
   cSql += "	   SC2.C2_ITEM   ,"
   cSql += "	   SC2.C2_SEQUEN ,"
   cSql += "	   SC2.C2_PRODUTO,"
   cSql += "	  (LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX))) AS NOMEPRO,"
   cSql += "	   SC2.C2_QUANT  ,"
   cSql += "	   SC2.C2_DATPRF  "
   cSql += "  FROM " + RetSqlName("SC2") + " SC2, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SC2.C2_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND LEN(LTRIM(RTRIM(SC2.C2_PRODUTO))) = 17"
   cSql += "   AND SC2.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_COD     = SC2.C2_PRODUTO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_DESC LIKE '%X%'
   cSql += "   AND SC2.C2_DATPRF >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
   cSql += "   AND SC2.C2_DATPRF <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"

   If Empty(Alltrim(cString))
   Else
      cSql += "   AND SB1.B1_DESC LIKE '" + Alltrim(cString) + "%'"
   Endif    

   cSql += " ORDER BY SB1.B1_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   cQuebra := Alltrim(U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|", 1)  + ' ' + U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|",2))

   WHILE !T_PRODUTOS->( EOF() )
   
      If Alltrim(U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|", 1)  + ' ' + U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|",2)) == cQuebra

         aAdd( aLista, { Alltrim(T_PRODUTOS->C2_NUM) + "." + Alltrim(T_PRODUTOS->C2_ITEM) + "." + Alltrim(T_PRODUTOS->C2_SEQUEN)                     ,;
                         U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|", 1)  + ' ' + U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|",2) ,;                       
                         T_PRODUTOS->C2_PRODUTO ,;
                         T_PRODUTOS->NOMEPRO    ,;
                         Transform(T_PRODUTOS->C2_QUANT, "@E 9999999.99")   ,;
                         Substr(T_PRODUTOS->C2_DATPRF,07,02) + "/" + Substr(T_PRODUTOS->C2_DATPRF,05,02) + "/" + Substr(T_PRODUTOS->C2_DATPRF,01,04) })
      Else
      
         aAdd( aLista, { "", "", "", "", "", "" })
         cQuebra := Alltrim(U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|", 1)  + ' ' + U_P_CORTA(STRTRAN(T_PRODUTOS->NOMEPRO, " ", "|"), "|",2))
         Loop

      Endif

      T_PRODUTOS->( DbSkip() )

   ENDDO

   If Len(aLista) == 0
      aAdd( aLista, { "", "", "", "", "", "" })
      MsgAlert("Não existem dados a serem visualizados para este filtro.")
   Endif   

   oList:SetArray( aLista )

   oList:bLine := {||     {aLista[oList:nAt,01],;
                    	   aLista[oList:nAt,02],;
          				   aLista[oList:nAt,03],;
          				   aLista[oList:nAt,04],;
          				   aLista[oList:nAt,05],;
          				   aLista[oList:nAt,06]}}

Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function yGeraResCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}
   
   // AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
   AADD(aCabExcel, {"Nº OP"                  , "C", 13, 00 })
   AADD(aCabExcel, {"Faca"                   , "C", 15, 00 })
   AADD(aCabExcel, {"Produto"                , "C", 30, 00 })
   AADD(aCabExcel, {"Descricao dos Produtos" , "C", 60, 00 })
   AADD(aCabExcel, {"Quantidade"             , "N", 10, 02 })
   AADD(aCabExcel, {"Data Entrega"           , "C", 10, 00 })
   AADD(aCabExcel, {" "                      , "C", 01,00 })

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| kProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","RELAÇÃO DE FACAS REF AO PERÍODO DE " + Dtoc(cDataIni) + " A " + Dtoc(cDataFim), aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aLista)

       aAdd( aCols, { aLista[nContar,01]          ,;
                      aLista[nContar,02]          ,;
                      "'" + Alltrim(aLista[nContar,03]) + "'" ,;
                      aLista[nContar,04]          ,;
                      aLista[nContar,05]          ,;
                      aLista[nContar,06]          ,;
                      ""                          })

   Next nContar

Return(.T.)