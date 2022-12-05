#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia.: AUTOM537.PRW                                                            ##
// Parâmetros.: Nenhum                                                                  ##
// Tipo.......: (X) Programa  ( ) Gatilho                                               ##
// ------------------------------------------------------------------------------------ ##
// Autor......: Harald Hans Löschenkohl                                                 ##
// Data.......: 07/02/2017                                                              ##
// Objetivo...: Programa de pesquisa dos custos do Sale Machine e Recálculo de Custo    ##
// Parâmertros: kProduto - Código do Produto a ser pesquisado                           ##
// #######################################################################################

User Function AUTOM537(kProduto)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aEmpresas  := {}
   Private aFiliais   := {}
   Private aPessoa    := {"J - Jurídica", "F - Física"}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3      
   Private cProduto   := Space(30)
   Private cDescricao := Space(60)
   Private oGet1
   Private oGet2

   Private aBrowse := {}
 
   Private oDlg

   // ##############################
   // Carrega o Combo de Empresas ##
   // ##############################
   aEmpresas := U_AUTOM539(1, "") // {"00 - Selecione", "01 - Automatech", "02 - TI Automação", "03 - Atech" }
   
   // #############################
   // Carrega o Combo de Filiais ##
   // #############################
   aFiliais := U_AUTOM539(2, cEmpAnt) // {"00 - Selecione", "01 - Porto Alegre/Curitiba", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "05 - São Paulo"}

   // ####################
   // Inicializa o Grid ##
   // ####################
   aAdd( aBrowse, { "", "", "", "", "", "", "", "" } )

   // ######################################################################################
   // Envia para a função que carrega o array aBrowse caso o produto passado em parâmetro ##
   // ######################################################################################
   If kProduto == nil
      cProduto := Space(30)
   Else
      cProduto := kProduto
      BuscaCustos(0)
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Sales Machine - Consulta / Recálculo" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(001) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(001) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(003) Say "Empresa"              Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(061) Say "Filial"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(119) Say "Produto"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(205) Say "Descrição do Produto" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(333) Say "Tipo Pessoa"          Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(003) ComboBox cComboBx2 Items aEmpresas  Size C(055),C(010)                              PIXEL OF oDlg ON CHANGE ALTERACOMBO()
   @ C(045),C(061) ComboBox cComboBx3 Items aFiliais   Size C(055),C(010)                              PIXEL OF oDlg
   @ C(045),C(119) MsGet    oGet1     Var   cProduto   Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BSCPRODIG(cProduto) )
   @ C(045),C(205) MsGet    oGet2     Var   cDescricao Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(333) ComboBox cComboBx1 Items aPessoa    Size C(040),C(010)                              PIXEL OF oDlg

   @ C(042),C(377) Button "Pesquisar"                           Size C(037),C(012) PIXEL OF oDlg ACTION( BuscaCustos(1) )
   @ C(210),C(005) Button "Recálculo Produto Selecionado"       Size C(095),C(012) PIXEL OF oDlg ACTION( ReorganizaSM() )
// @ C(210),C(101) Button "Recálculo por Intervalo de Grupos"   Size C(095),C(012) PIXEL OF oDlg ACTION( RecPorGrupos() )
// @ C(210),C(197) Button "Recálculo por Intervalo de Produtos" Size C(095),C(012) PIXEL OF oDlg ACTION( RecPorProduto() )

   @ C(210),C(461) Button "Voltar"               Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'Estado'        + Space(15),; 
                                                    'Custo Inicial' + Space(15),;
                                                    'Credito Adj.'  + Space(15),;
                                                    'PIS'           + Space(15),;
                                                    'COFINS'        + Space(15),;
                                                    'ICMS'          + Space(15),;
                                                    'DIFAL'         + Space(15),;
                                                    'Custo Total'   + Space(15)},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx2,01,02) )
   @ C(045),C(061) ComboBox cComboBx3 Items aFiliais Size C(055),C(010) PIXEL OF oDlg

Return(.T.)

// ##################################################################
// Função que pesquisa a descrição do produto digitado/selecionado ##
// ##################################################################
Static Function BSCPRODIG(_Produto)

   If Empty(Alltrim(_Produto))
      cProduto   := Space(30)
      cDescricao := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      Return(.T.)
   Endif
   
   cDescricao := Alltrim(Posicione("SB1", 1, xFilial("SB1") + _Produto, "B1_DESC")) + " " + ;
                 Alltrim(Posicione("SB1", 1, xFilial("SB1") + _Produto, "B1_DAUX"))
   oGet2:Refresh()

Return(.T.)

// #####################################################################
// Função que pesquisa os custos para o produto informado/selecionado ##
// #####################################################################
Static Function BuscaCustos(kTipo)

   Local cSql := ""

   If kTipo == 0
   Else
      If Substr(cComboBx2,01,02) == "00"
         MsgAlert("Empresa não selecionada.")
         Return(.T.)
      Endif
   
      If Substr(cComboBx3,01,02) == "00"
         MsgAlert("Filial não selecionada.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cProduto))
         MsgAlert("Produto a ser pesquisado não informado.")
         Return(.T.)
      Endif
   Endif 

   aBrowse := {}

   // ########################################
   // Pesquisa os dados conforme parâmetros ##
   // ########################################
   If Select("T_ESTADOS") > 0
      T_ESTADOS->( dbCloseArea() )
   EndIf

   If kTipo == 0
   
      cSql := ""
      cSql := "SELECT ZTP_ESTA,"
      cSql += "       ZTP_CM01,"
      cSql += "	      ZTP_CAJ1,"
      cSql += "	      ZTP_PIS1,"
      cSql += "	      ZTP_COF1,"
      cSql += "       ZTP_ICM1,"
      cSql += "	      ZTP_PDF1,"
      cSql += "	      ZTP_CUS1 "
      cSql += "  FROM " + RetSqlName("ZTP")
      cSql += " WHERE ZTP_EMPR    = '" + Alltrim(cEmpAnt)  + "'"
      cSql += "    AND ZTP_FILIAL = '" + Alltrim(cFilAnt)  + "'"
      cSql += "   AND ZTP_PROD    = '" + Alltrim(cProduto) + "'"
      cSql += "    AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY ZTP_ESTA"   
      
   Else   
   
      If Substr(cComboBx1, 01,01) == "J"

         cSql := ""
         cSql := "SELECT ZTP_ESTA,"
         cSql += "       ZTP_CM01,"
         cSql += "	     ZTP_CAJ1,"
         cSql += "	     ZTP_PIS1,"
         cSql += "	     ZTP_COF1,"
         cSql += "       ZTP_ICM1,"
         cSql += "	     ZTP_PDF1,"
         cSql += "	     ZTP_CUS1 "
         cSql += "  FROM " + RetSqlName("ZTP")
         cSql += " WHERE ZTP_EMPR    = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
         cSql += "    AND ZTP_FILIAL  = '" + Alltrim(Substr(cComboBx3,01,02)) + "'"
         cSql += "    AND ZTP_PROD    = '" + Alltrim(cProduto) + "'"
         cSql += "    AND D_E_L_E_T_ = ''"
         cSql += " ORDER BY ZTP_ESTA"   
      
      Else
      
         cSql := ""
         cSql := "SELECT ZTP_ESTA,"
         cSql += "       ZTP_CM02,"
         cSql += "	     ZTP_CAJ2,"
         cSql += "	     ZTP_PIS2,"
         cSql += "	     ZTP_COF2,"
         cSql += "       ZTP_ICM2,"
         cSql += "	     ZTP_PDF2,"
         cSql += "	     ZTP_CUS2 "
         cSql += "  FROM " + RetSqlName("ZTP")
         cSql += " WHERE ZTP_EMPR    = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
         cSql += "    AND ZTP_FILIAL  = '" + Alltrim(Substr(cComboBx3,01,02)) + "'"
         cSql += "    AND ZTP_PROD    = '" + Alltrim(cProduto) + "'"
         cSql += "    AND D_E_L_E_T_ = ''"
         cSql += " ORDER BY ZTP_ESTA"   
      
      Endif
      
   Endif   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTADOS", .T., .T. )
      
   T_ESTADOS->( DbGoTop() )
   
   WHILE !T_ESTADOS->( EOF() )
   
      If kTipo == 0

         aAdd( aBrowse, {T_ESTADOS->ZTP_ESTA,;
                         STR(T_ESTADOS->ZTP_CM01,10,02) ,;
         	             STR(T_ESTADOS->ZTP_CAJ1,10,02) ,;
      	                 STR(T_ESTADOS->ZTP_PIS1,06,02) ,;
      	                 STR(T_ESTADOS->ZTP_COF1,06,02) ,;
      	                 STR(T_ESTADOS->ZTP_ICM1,06,02) ,;
      	                 STR(T_ESTADOS->ZTP_PDF1,06,02) ,;
      	                 STR(T_ESTADOS->ZTP_CUS1,10,02) })
      	                 
      Else      	                 

         If Substr(cComboBx1, 01,01) == "J"

            aAdd( aBrowse, {T_ESTADOS->ZTP_ESTA,;
                            STR(T_ESTADOS->ZTP_CM01,10,02) ,;
            	            STR(T_ESTADOS->ZTP_CAJ1,10,02) ,;
      	                    STR(T_ESTADOS->ZTP_PIS1,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_COF1,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_ICM1,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_PDF1,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_CUS1,10,02) })

         Else

            aAdd( aBrowse, {T_ESTADOS->ZTP_ESTA,;
                            STR(T_ESTADOS->ZTP_CM02,10,02) ,;
            	            STR(T_ESTADOS->ZTP_CAJ2,10,02) ,;
      	                    STR(T_ESTADOS->ZTP_PIS2,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_COF2,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_ICM2,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_PDF2,06,02) ,;
      	                    STR(T_ESTADOS->ZTP_CUS2,10,02) })
      	                
         Endif
         
      Endif   
      
      T_ESTADOS->( DbSkip() )
      
  Enddo
  
  If Len(aBrowse) == 0
     MsgAlert("Não existem dados a serem visualizados para este produto.")
     aAdd( aBrowse, { "", "", "", "", "", "", "", "" } )      	               
  Endif

  If kTipo == 0
     Return(.T.)
  Endif

  oBrowse:SetArray(aBrowse) 
  oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                        aBrowse[oBrowse:nAt,02],;
                        aBrowse[oBrowse:nAt,03],;
                        aBrowse[oBrowse:nAt,04],;
                        aBrowse[oBrowse:nAt,05],;
                        aBrowse[oBrowse:nAt,06],;
                        aBrowse[oBrowse:nAt,07],;
                        aBrowse[oBrowse:nAt,08]} }

Return(.T.)

// ###############################################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para o produto informado/selecionado ##
// ###############################################################################################
Static Function ReorganizaSM()

   If Empty(Alltrim(cProduto))
      MsgAlert("Produto a ser calculado não informado.")
      Return(.T.)
   Endif

   MsgRun("Favor Aguarde! Calculando Custo Sales Machine ...", "Sales Machine",{|| xReorganizaSM() })
   
   BuscaCustos()   
   
Return(.T.)
   
// ###############################################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para o produto informado/selecionado ##
// ###############################################################################################
Static Function xReorganizaSM()

   U_AUTOM525(cProduto, 0, "", 1)

Return(.T.)

// #####################################################################
// Função que realiza o recálculo por intervalo de grupos de produtos ##
// #####################################################################
Static Function RecPorGrupos()

   Local lChumba     := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := "A execução deste procedimento é lento. Procure informar um range não muito extenso entre os grupos."
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private aGruposIni   := {}
   Private aGruposFim   := {}
   Private cComboBx2
   Private cComboBx3
   Private cTotProdutos := 0
   Private oGet1

   Private oDlg

   If Select("T_GRUPOS") > 0
      T_GRUPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY BM_GRUPO    "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPOS", .T., .T. )

   T_GRUPOS->( DbGoTop() )

   aAdd( aGruposIni, "0000 - Selecione o Grupo" )
   aAdd( aGruposFim, "0000 - Selecione o Grupo" )

   WHILE !T_GRUPOS->( EOF() )
      aAdd( aGruposIni, T_GRUPOS->BM_GRUPO + " - " + Alltrim(T_GRUPOS->BM_DESC) )
      aAdd( aGruposFim, T_GRUPOS->BM_GRUPO + " - " + Alltrim(T_GRUPOS->BM_DESC) )
      T_GRUPOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgG TITLE "Sales Machine - Consulta / Recálculo" FROM C(178),C(181) TO C(503),C(529) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgG

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(168),C(001) PIXEL OF oDlgG
   @ C(140),C(002) GET oMemo3 Var cMemo3 MEMO Size C(168),C(001) PIXEL OF oDlgG

   @ C(036),C(005) Say "Grupo Inicial"                                       Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(058),C(005) Say "Grupo Final"                                         Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(084),C(005) Say "Total de Produtos referente aos grupos selecionados" Size C(125),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(094),C(005) Say "A T E N Ç Ã O !"                                     Size C(041),C(008) COLOR CLR_RED   PIXEL OF oDlgG
		   
   @ C(045),C(005) ComboBox cComboBx2 Items aGruposIni   Size C(162),C(010) PIXEL OF oDlgG ON CHANGE PSQTOTGRUPOS()
   @ C(068),C(005) ComboBox cComboBx3 Items aGruposFim   Size C(162),C(010) PIXEL OF oDlgG ON CHANGE PSQTOTGRUPOS()
   @ C(084),C(131) MsGet    oGet1     Var   cTotProdutos Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG When lChumba
   @ C(105),C(005) GET      oMemo2    Var   cMemo2 MEMO  Size C(163),C(031) PIXEL OF oDlgG When lChumba

   @ C(145),C(045) Button "Processar" Size C(037),C(012) PIXEL OF oDlgG ACTION( GCalculaSM(cComboBx2, cComboBx3) )
   @ C(145),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgG ACTION( oDlgG:End() )

   ACTIVATE MSDIALOG oDlgG CENTERED 

Return(.T.)

// ######################################################################
// Função que pesquisa o total de produtos conforme os grupos informados#
// ######################################################################
Static Function PsqTotGrupos()

   Local cSql := ""

   If Substr(cComboBx2,01,04) == "0000"
      Return(.T.)
   Endif
      
   If Substr(cComboBx3,01,04) == "0000"
      Return(.T.)
   Endif

   If INT(VAL(Substr(cComboBx2,01,04))) > INT(VAL(Substr(cComboBx3,01,04)))
      MsgAlert("Grupo inicial não pode ser maior que grupo final. Corrija a selecção de grupos.")
      Return(.T.)
   Endif
 
   If Select("T_GRUPOS") > 0
      T_GRUPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT COUNT(*) AS TOT_PRODUTOS "
   cSql += "  FROM " + RetSqlName("SB1") + " (Nolock)"
   cSql += " WHERE B1_GRUPO  >= '" + Substr(cComboBx2,01,04) + "'"
   cSql += "   AND B1_GRUPO  <= '" + Substr(cComboBx3,01,04) + "'"
   cSql += "   AND B1_MSBLQL <> '1'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPOS", .T., .T. )

   cTotProdutos := IIF(T_GRUPOS->( EOF() ), 0, T_GRUPOS->TOT_PRODUTOS)
   oGet1:Refresh()
   
Return(.T.)

// ###############################################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para o produto informado/selecionado ##
// ###############################################################################################
Static Function GCalculaSM(kComboBx2, kComboBx3)

   If Substr(kComboBx2,01,04) == "0000"
      MsgAlert("Grupo inicial não selecionado.")
      Return(.T.)
   Endif
      
   If Substr(cComboBx3,01,04) == "0000"
      MsgAlert("Grupo final não selecionado.")
      Return(.T.)
   Endif

   If INT(VAL(Substr(kComboBx2,01,04))) > INT(VAL(Substr(kComboBx3,01,04)))
      MsgAlert("Grupo inicial não pode ser maior que grupo final. Corrija a selecção de grupos.")
      Return(.T.)
   Endif

   MsgRun("Favor Aguarde! Calculando Custo Sales Machine ...", "Sales Machine",{|| xCalculaSM(kComboBx2, kComboBx3) })
   
   BuscaCustos()   
   
Return(.T.)
   
// ###############################################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para o produto informado/selecionado ##
// ###############################################################################################
Static Function xCalculaSM(kComboBx2, kComboBx3)

   U_AUTOM525( Substr(kComboBx2,01,04) + "|" + Substr(kComboBx3,01,04) + "|", 0, "", 1  )

Return(.T.)

// ###########################################################
// Função que realiza o recálculo por intervalo de produtos ##
// ###########################################################
Static Function RecPorProduto()

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local cMemo2	   := "A execução deste procedimento é lento. Procure informar um range não muito extenso entre os produtos."
   Local cMemo3	   := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3
   
   Private cProdutoI := Space(30)
   Private cProdutoF := Space(30)
   Private cNome1	 := Space(60)
   Private cNome2    := Space(60)
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlgP

   DEFINE MSDIALOG oDlgP TITLE "Sales Machine - Consulta / Recálculo" FROM C(178),C(181) TO C(518),C(526) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(168),C(001) PIXEL OF oDlgP
   @ C(149),C(002) GET oMemo3 Var cMemo3 MEMO Size C(168),C(001) PIXEL OF oDlgP
   
   @ C(036),C(005) Say "Código Produto Inicial" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(071),C(005) Say "Código Produto Final"   Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(105),C(005) Say "A T E N Ç Ã O !"        Size C(041),C(008) COLOR CLR_RED   PIXEL OF oDlgP
	   
   @ C(045),C(005) MsGet oGet2  Var cProdutoI   Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP F3("SB1") VALID(GPsqproduto(1, cProdutoI))
   @ C(058),C(005) MsGet oGet4  Var cNome1      Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
   @ C(080),C(005) MsGet oGet3  Var cProdutoF   Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP F3("SB1") VALID(GPsqproduto(2, cProdutoF))
   @ C(093),C(005) MsGet oGet5  Var cNome2      Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
   @ C(114),C(005) GET   oMemo2 Var cMemo2 MEMO Size C(163),C(031)                              PIXEL OF oDlgP When lChumba

   @ C(154),C(048) Button "Processar" Size C(037),C(012) PIXEL OF oDlgP ACTION( yCalculaSM(cProdutoI, cProdutoF) )
   @ C(154),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// ##############################################################
// Função que pesquisa o nome do produto informado/selecionado ##
// ##############################################################
Static Function GPsqproduto(kTipo, kProduto)

   If kTipo == 1
      cNome1 := Posicione( "SB1", 1, xFilial("SB1") + cProdutoI, "B1_DESC" )
      oGet4:refresh()
   Else
      cNome2 := Posicione( "SB1", 1, xFilial("SB1") + cProdutoF, "B1_DESC" )
      oGet5:refresh()
   Endif      
   
Return(.T.)

// #####################################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para interbalo de produtos ##
// #####################################################################################
Static Function yCalculaSM(kProdutoI, kProdutoF)

   If Empty(Alltrim(cProdutoI))
      Msgalert("Produto inicial não informado.")
      Return(.T.)
   Endif
      

   If Empty(Alltrim(cProdutoF))
      Msgalert("Produto final não informado.")
      Return(.T.)
   Endif

   oDlgP:End() 

   MsgRun("Favor Aguarde! Calculando Custo Sales Machine ...", "Sales Machine",{|| dCalculaSM(kProdutoI, kProdutoF) })
   
   BuscaCustos()   

Return(.T.)
   
// #####################################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para interbalo de produtos ##
// #####################################################################################
Static Function dCalculaSM(kProdutoI, kProdutoF)

   Local cTimeI := Time()
   Local cTimeF := Time()

   U_AUTOM525( kProdutoI + "|" + kProdutoF + "|", 0, "", 1 )

   cTimeF := Time()
   
   MsgAlert("Recálculo encerrado." + chr(13) + "Hora Inicial: " + cTimeI + chr(13) + "Hora Final: " + cTimeF)

Return(.T.)