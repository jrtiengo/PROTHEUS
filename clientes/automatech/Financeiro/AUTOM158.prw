#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM158.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/02/2013                                                          *
// Objetivo..: `Programa que gera a estatísica de atendimentos por operador        *
//**********************************************************************************

User Function AUTOM158()

   Local dInicial := Ctod("  /  /    ")
   Local dFinal   := Ctod("  /  /    ")

   Local oGet1
   Local oGet2

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Estatística de Atendimento (Ativo/Receptivo)" FROM C(178),C(181) TO C(249),C(535) PIXEL

   @ C(005),C(005) Say "Data Inicial" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(020),C(005) Say "Data Final"   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(004),C(036) MsGet oGet1 Var dInicial Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(019),C(036) MsGet oGet2 Var dFinal   Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   
   @ C(010),C(090) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION(TREEATENDE( dInicial, dFinal ))
   @ C(010),C(131) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Funcção que abre a tela com o treeview de consulta
Static Function TREEATENDE( _DataIni, _DataFim )

   Local lChumba    := .F.
   Local cSql       := ""
   Local DataIni    := _DataIni
   Local DataFim    := _DataFim
   Local tReceptivo := 0
   Local tAtivo     := 0
   Local tTotal     := 0

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Static oDbTree
   Local lCargo   := .T.  // Utiliza a opcao CARGO
   Local lDisable := .F.  // Desabilita a DBTree

   Private cBmp1        := "PMSEDT3" 
   Private cBmp2        := "PMSDOC" 

   Private oDlgT

   // Consiste as data de pesquisa
   If Empty(DataIni)
      MsgAlert("Data inicial para pesquisa não informada.")
      Return(.T.)
   Endif
      
   If Empty(DataFim)
      MsgAlert("Data final para pesquisa não informada.")
      Return(.T.)
   Endif

   If DataFim < DataIni
      MsgAlert("Data final não pode ser menor que a data inicial.")
      Return(.T.)
   Endif

   If DataIni > DataFim
      MsgAlert("Data inicial não pode ser maior que a data final.")
      Return(.T.)
   Endif

   If Select("T_ATENDE") > 0
   	  T_ATENDE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ACF_ULTATE AS DATA   ," 
   cSql += "       B.U7_NREDUZ AS OPERADOR," 
   cSql += "       A.ACF_OPERA AS TIPO    ,"
   cSql += "       COUNT(A.ACF_OPERA) AS QTD" 
   cSql += "  FROM " + RetSqlName("ACF") + " A, "
   cSql += "       " + RetSqlName("SU7") + " B  " 
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.ACF_ULTATE >= CONVERT(DATETIME,'" + Dtoc(DataIni) + "', 103)"
   cSql += "   AND A.ACF_ULTATE <= CONVERT(DATETIME,'" + Dtoc(DataFim) + "', 103)"
   cSql += "   AND A.ACF_OPERAD  = B.U7_COD"
   cSql += " GROUP BY A.ACF_ULTATE, A.ACF_OPERA, B.U7_NREDUZ"
   cSql += " ORDER BY A.ACF_ULTATE, B.U7_NREDUZ"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATENDE", .T., .T. )

   If T_ATENDE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif

   // Agrupa as data
   If Select("T_DATAS") > 0
   	  T_DATAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ACF_ULTATE AS DATA "
   cSql += "  FROM " + RetSqlName("ACF") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.ACF_ULTATE >= CONVERT(DATETIME,'" + Dtoc(DataIni) + "', 103)"
   cSql += "   AND A.ACF_ULTATE <= CONVERT(DATETIME,'" + Dtoc(DataFim) + "', 103)"
   cSql += " GROUP BY A.ACF_ULTATE"
   cSql += " ORDER BY A.ACF_ULTATE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DATAS", .T., .T. )

   DEFINE MSDIALOG oDlgT TITLE "Estatística de Atendimento (Ativo/Receptivo)" FROM C(178),C(181) TO C(595),C(597) PIXEL

   @ C(005),C(005) Say "Data Inicial" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(005),C(084) Say "Data Final"   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(141),C(163) Say "Ativos"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(163),C(163) Say "Receptivos"   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(185),C(163) Say "Total"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

   @ C(004),C(036) MsGet oGet1 Var DataIni When lChumba Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
   @ C(004),C(112) MsGet oGet2 Var DataFim When lChumba Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
	
   @ C(151),C(164) MsGet oGet3 Var tReceptivo When lChumba Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
   @ C(173),C(163) MsGet oGet4 Var tAtivo     When lChumba Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
   @ C(195),C(163) MsGet oGet5 Var tTotal     When lChumba Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT

   @ C(002),C(166) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   // Cria o Objeto TreeView
   oTree := DbTree():New(025,005,260,200,oDlgT,,,.T.)

   // Elabora o treeView
   T_DATAS->( DbGoTop() )

   nNivel1 := 1
   nNivel2 := 100

   // Abre o nível mais elevado do TreeView
   oTree:AddItem("ESTATÍSTICA DE ATENDIMENTOS" + Space(84), Strzero(nNivel1,3), cBmp1 ,,,,nNivel2)

   cCargo  := 1

   _Ativo     := 0
   _Receptivo := 0
   _Total     := 0

   WHILE !T_DATAS->( EOF() )

      nNivel1 += 1
      nNivel2 := nNivel2 + 100

      // Cria a Linha do Projeto
      oTree:AddItem(Substr(T_DATAS->DATA,07,02) + "/" + Substr(T_DATAS->DATA,05,02) + "/" + Substr(T_DATAS->DATA,01,04), Strzero(nNivel1,3), cBmp1 ,,,,nNivel2)

      // Pesquisa os dados para a data selecionada
      T_ATENDE->( DbGoTop() )
      
      WHILE !T_ATENDE->( EOF() )
       
         If T_ATENDE->DATA == T_DATAS->DATA

            nNivel2 += 1

            If T_ATENDE->TIPO == "1"
               oTree:AddItem(">      " + Upper(Alltrim(T_ATENDE->OPERADOR)) + "  Ativo: " + Alltrim(Str(T_ATENDE->QTD)), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)
               tAtivo := tAtivo + T_ATENDE->QTD
            Else
               oTree:AddItem(">      " + Upper(Alltrim(T_ATENDE->OPERADOR)) + "  Receptivo: " + Alltrim(Str(T_ATENDE->QTD)), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)            
               tReceptivo := tReceptivo + T_ATENDE->QTD
            Endif               

            tTotal := tTotal + T_ATENDE->QTD

            cCargo += 1
            
         Endif   
              
         T_ATENDE->( DbSkip() )

      Enddo

      nNivel2 += 1
      oTree:AddItem(Replicate("-", 100), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)
      cCargo += 1

      T_DATAS->( DbSkip() )
          
   ENDDO

   // Retorna ao primeiro nível
   oTree:TreeSeek("001")

   // Indica o término da contrução da Tree
   oTree:EndTree()

   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)