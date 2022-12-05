#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#include "colors.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Tarefas                       *
//**********************************************************************************

User Function ESPTAR01()

   Local lChumba        := .F.
   Local cSql           := ""

   Private AAA_Abertura := 1

   Private nMeter1	    := 0
   Private oMeter1

   Private aRecalculo   := {}

   Private dData01      := Ctod("  /  /    ")
   Private dData02      := Ctod("  /  /    ")
   Private aComboBx1    := {}
   Private aComboBx2    := {}
   Private aComboBx3    := {}
   Private aComboBx4    := {}
   Private aComboBx5    := {}
   Private aComboBx6    := {}
   Private aComboBx7    := {'01 - Por Ordem de Tarefa', '02 - Por Ordem de Prioridade', '03 - Por Ordem de Prioridade + Ordem de Tarefa', '04 - Por Ordem de Prioridade + Ordem de Tarefa (Descendente)', "05 - Por Código de Tarefa"}
   Private nContar      := 0
   Private lSalvar      := .F.

   Private cBranco      := 0
   Private cVerde       := 0
   Private cRosa        := 0
   Private cAmarelo     := 0
   Private cAzul        := 0
   Private cLaranja     := 0
   Private cPreto       := 0
   Private cVermelho    := 0
   Private cMarrom      := 0
   Private cCancel      := 0
   Private cTarefas     := 0

   Private cMemo1	    := ""
   Private cMemo2	    := ""
   Private oMemo1
   Private oMemo2

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11

   Private cComboBx1   := "000000"
   Private cComboBx2   := "000000"
   Private cComboBx3   := ""
   Private cComboBx4   := "000000"
   Private cComboBx5   := "  "
   Private cComboBx6   := "000000"
   Private cComboBx7
                              
   Private nGet1	   := Ctod("  /  /    ")
   Private nGet2	   := Ctod("  /  /    ")
   Private oGet1
   Private oGet2

   Private lHoras      := .T.

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Private _aArea   		:= {}
   Private _aAlias  		:= {}

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   // Variaveis Private da Funcao
   Private oDlgP

   // Privates das NewGetDados
   Private oGetDados1

   //Private para a tela de entrada do Controle de Tarefas
   Private nTvisual := ""

   // Verifica se o usuário logado possui permissão para liberar tarefas
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI, "
   cSql += "       ZZA_VISU  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += "WHERE RTRIM(LTRIM(UPPER(ZZA_NOME))) = '" + Upper(Alltrim(cUserName)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )
   
   If T_USUARIO->( EOF() )
      MsgAlert("Atenção! Você não possui permissão para realizar esta operação.")
      Return(.T.)
   Endif
            
   If T_USUARIO->ZZA_VISU <> "T"
      lSalvar := .T.
   Else
      lSalvar := .F.   
   Endif

   // Carrega as datas iniciais e finais com o período do mês atual
   dData01 := Ctod("01/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))

   Do Case
      Case Month(Date()) == 1
           dData02 := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 2
           If Mod(Year(Date()),4) == 0
              dData02 := Ctod("29/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
           Else
              dData02 := Ctod("28/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
           Endif   
      Case Month(Date()) == 3
           dData02 := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 4
           dData02 := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 5
           dData02 := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 6
           dData02 := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 7
           dData02 := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 8
           dData02 := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 9
           dData02 := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 10
           dData02 := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 11
           dData02 := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 12
           dData02 := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
   EndCase

   Private aBrowse := {}

   // Carrega o Combo de Origem
   If Select("T_ORIGEM") > 0
      T_ORIGEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZF_CODIGO, "
   cSql += "       ZZF_NOME    "
   cSql += "  FROM " + RetSqlName("ZZF")
   cSql += " WHERE ZZF_DELETE = ''"
   cSql += " ORDER BY ZZF_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORIGEM", .T., .T. )

   aComboBx1 := {}

   If !T_ORIGEM->( EOF() )
      aAdd( aComboBx1, "000000 - TODOS" )  
      WHILE !T_ORIGEM->( EOF() )
         aAdd( aComboBx1, T_ORIGEM->ZZF_CODIGO + " - " + T_ORIGEM->ZZF_NOME )
         T_ORIGEM->( DbSkip() )
      ENDDO
   Endif
      
   // Carrega o Combo de Componentes
   If Select("T_COMPO") > 0
      T_COMPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZB_CODIGO, "
   cSql += "       ZZB_NOME    "
   cSql += "  FROM " + RetSqlName("ZZB")
   cSql += " WHERE ZZB_DELETE = ''"
   cSql += " ORDER BY ZZB_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPO", .T., .T. )

   aComboBx2 := {}

   If !T_COMPO->( EOF() )
      aAdd( aComboBx2, "000000 - TODOS" )
      WHILE !T_COMPO->( EOF() )
         aAdd( aComboBx2, T_COMPO->ZZB_CODIGO + " - " + T_COMPO->ZZB_NOME )
         T_COMPO->( DbSkip() )
      ENDDO
   Endif
         
   // Carrega o combo de usuarios
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      MsgAlert("Cadastro de Usuários está vazio.")
      Return .T.
   Endif

   // Carrega o Combo dos Usuários do Sistema
   aAdd( aComboBx3, "TODOS OS USUÁRIOS" )
   T_USUARIO->( EOF() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aComboBx3, T_USUARIO->ZZA_NOME )
      T_USUARIO->( DbSkip() )
   ENDDO

   // Carrega o Combo de Prioridades
   If Select("T_PRIORI") > 0
      T_PRIORI->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZD_CODIGO, "
   cSql += "       ZZD_NOME    "
   cSql += "  FROM " + RetSqlName("ZZD")
   cSql += " WHERE ZZD_DELETE = ''"
   cSql += " ORDER BY ZZD_CODIGO "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORI", .T., .T. )

   aComboBx4 := {}

   If !T_PRIORI->( EOF() )
      aAdd( aComboBx4, "000000 - TODAS" )
      WHILE !T_PRIORI->( EOF() )
         aAdd( aComboBx4, T_PRIORI->ZZD_CODIGO + " - " + T_PRIORI->ZZD_NOME )
         T_PRIORI->( DbSkip() )
      ENDDO
   Endif

   // Carrega o Combo de Status
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZC_CODIGO, "
   cSql += "       ZZC_NOME  , "
   cSql += "       ZZC_LEGE    "
   cSql += "  FROM " + RetSqlName("ZZC")
   cSql += " WHERE ZZC_DELETE = ''"
   cSql += " ORDER BY ZZC_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   aComboBx5 := {}

   If !T_STATUS->( EOF() )
      aAdd( aComboBx5, "T - TOD0S" )
      WHILE !T_STATUS->( EOF() )

         If INT(VAL(T_STATUS->ZZC_CODIGO)) <= 9
            If T_STATUS->ZZC_CODIGO == "000000"
               aAdd( aComboBx5, "X" + " - " + T_STATUS->ZZC_NOME )            
            Else   
               aAdd( aComboBx5, STR(INT(VAL(T_STATUS->ZZC_CODIGO)),1) + " - " + T_STATUS->ZZC_NOME )
            Endif   
         Else
            aAdd( aComboBx5, T_STATUS->ZZC_LEGE + " - " + T_STATUS->ZZC_NOME )
         Endif               
            
         T_STATUS->( DbSkip() )
      ENDDO
   Endif

   // Inclui o Status que será utilizado para revisão das Tarefas
   aAdd( aComboBx5, "A - ANÁLISE DE TAREFAS S/X e S/V" )
   aAdd( aComboBx5, "B - ANÁLISE DE TAREFAS C/X e S/V" )   
   aAdd( aComboBx5, "C - ANÁLISE DE TAREFAS C/X e C/V" )   
   aAdd( aComboBx5, "R - REORDENAÇÃO" )

   // Carrega o Combo de Desenvolvedores
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   aComboBx6 := {}

   If !T_DESENVE->( EOF() )
      aAdd( aComboBx6, "000000 - TOD0S" )
      WHILE !T_DESENVE->( EOF() )
         aAdd( aComboBx6, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )
         T_DESENVE->( DbSkip() )
      ENDDO
   Endif

   // Carrega o Array com os dados das tarefas conforme o filtro informado.
   aBrowse := {}

   // Verifica se existe parâmetros de filtro de pesquisa para o usuário
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZI_USUA, "
   cSql += "       ZZI_DT01, "
   cSql += "       ZZI_DT02, "
   cSql += "       ZZI_ORIG, "
   cSql += "       ZZI_COMP, "
   cSql += "       ZZI_PRIO, "
   cSql += "       ZZI_STAT, "
   cSql += "       ZZI_DESE, "
   cSql += "       ZZI_ARIO, "
   cSql += "       ZZI_ORDE, "
   cSql += "       ZZI_ABRE, "
   cSql += "       ZZI_TVIS  "
   cSql += "  FROM " + RetSqlName("ZZI")
   cSql += " WHERE ZZI_USUA = '" + Alltrim(cUserName) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   // Posiciona os combos conforme parãmetros do usuário
   If !T_MASTER->( EOF() )
          
      // Verifica se o usuário possui indicação de tipo de visualização. Se não tiver, inicialmente será por legenda.
      If Empty(Alltrim(T_MASTER->ZZI_TVIS))
         nTvisual := "1"
      Else
         nTvisual := Alltrim(T_MASTER->ZZI_TVIS)
      Endif

      // Carrega as datas iniciais e finais com o período do mês atual
      dData01 :=  Ctod(Substr(T_MASTER->ZZI_DT01,07,02) + "/" + Substr(T_MASTER->ZZI_DT01,05,02) + "/" + Substr(T_MASTER->ZZI_DT01,01,04))
      dData02 :=  Ctod(Substr(T_MASTER->ZZI_DT02,07,02) + "/" + Substr(T_MASTER->ZZI_DT02,05,02) + "/" + Substr(T_MASTER->ZZI_DT02,01,04))
   
      // Posiciona a Ordenação
      For nContar = 1 to Len(aComboBx7)
          If Empty(Alltrim(T_MASTER->ZZI_ORDE))
             cComboBx7 := aComboBx7[1]
          Else
             If Substr(aComboBx7[nContar],01,02) == Alltrim(T_MASTER->ZZI_ORDE)
                cComboBx7 := aComboBx7[nContar]
                Exit
             Endif
          Endif   
      Next nContar

      // A partir de 15/01/2015, é forçado somente a ordenação 01 - Por Ordem de Tarefa
      cComboBx7 := "01"

      // Posiciona o Usuário
      For nContar = 1 to Len(aComboBx3)
          If Alltrim(aComboBx3[nContar]) == Alltrim(T_MASTER->ZZI_ARIO)
             cComboBx3 := aComboBx3[nContar]
             Exit
          Endif
      Next nContar

      // Posiciona a Origem
      For nContar = 1 to Len(aComboBx1)
          If Substr(aComboBx1[nContar],01,06) == Alltrim(T_MASTER->ZZI_ORIG)
             cComboBx1 := aComboBx1[nContar]
             Exit
          Endif
      Next nContar
   
      // Posiciona o Componente
      For nContar = 1 to Len(aComboBx2)
          If Substr(aComboBx2[nContar],01,06) == Alltrim(T_MASTER->ZZI_COMP)
             cComboBx2 := aComboBx2[nContar]
             Exit
          Endif
      Next nContar
   
      // Posiciona a Prioridade
      For nContar = 1 to Len(aComboBx4)
          If Substr(aComboBx4[nContar],01,06) == Alltrim(T_MASTER->ZZI_PRIO)
             cComboBx4 := aComboBx4[nContar]
             Exit
          Endif
      Next nContar
   
      // Posiciona o Status
      For nContar = 1 to Len(aComboBx5)
          If Alltrim(Substr(aComboBx5[nContar],01,02)) == Alltrim(T_MASTER->ZZI_STAT)
             cComboBx5 := aComboBx5[nContar]
             Exit
          Endif
      Next nContar

      // Posiciona o Desenvolvedor
      For nContar = 1 to Len(aComboBx6)
          If Substr(aComboBx6[nContar],01,06) == Alltrim(T_MASTER->ZZI_DESE)
             cComboBx6 := aComboBx6[nContar]
             Exit
          Endif
      Next nContar

      // Captura o tipo de abertura do grid da tela de tarefas por usuário
      AAA_Abertura := T_MASTER->ZZI_ABRE
      
   Else
   
      nTvisual := "1"
   
   Endif   

   If cComboBx7 == Nil
      cComboBx7 := "01 - Por Ordem de Tarefa"
   Endif      

   // ---------------------------------------------------------------------------- //
   // Envia para a função que carrega o grid das tarefas conforme filtro informado //
   // ---------------------------------------------------------------------------- //
   CarBrowse(1,0)

   // Atualiza as Estatísticas das Tarefas
   cTarefas  := 0 
   cAmarelo  := 0
   cLaranja  := 0
   cRosa     := 0 
   cVermelho := 0
   cAzul     := 0
   cCancel   := 0

   For nContar = 1 to Len(aBrowse)

      Do Case
         Case Alltrim(aBrowse[nContar,21]) == "1"
              cBranco := cBranco + 1
         Case Alltrim(aBrowse[nContar,21]) == "7"
              cVerde := cVerde + 1
         Case Alltrim(aBrowse[nContar,21]) == "5"
              cRosa := cRosa + 1      
         Case Alltrim(aBrowse[nContar,21]) == "2"
              cAmarelo := cAmarelo + 1
         Case Alltrim(aBrowse[nContar,21]) == "8"
              cAzul := cAzul + 1
         Case Alltrim(aBrowse[nContar,21]) == "4"
              cLaranja := cLaranja + 1
         Case Alltrim(aBrowse[nContar,21]) == "3"
              cPreto := cPreto + 1
         Case Alltrim(aBrowse[nContar,21]) == "6"
              cVermelho := cVermelho + 1
         Case Alltrim(aBrowse[nContar,21]) == "9"
              cMarrom := cMarrom + 1
         Case Alltrim(aBrowse[nContar,21]) == "10"
              cCancel := cCancel + 1
      EndCase
      
   Next nContar

   cTarefas := cAmarelo + cLaranja + cRosa + cVermelho + cAzul + cCancel

   DEFINE MSDIALOG oDlgP TITLE "Controle de Tarefas" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlgP

   // Cria Componentes Padroes do Sistema
   @ C(025),C(006) Say "Data Inicial"                                                        Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(025),C(037) Say "Data Final"                                                          Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(025),C(068) Say "Responsável"                                                         Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(025),C(118) Say "Componente"                                                          Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(025),C(189) Say "Usuário"                                                             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(025),C(252) Say "Prioridade"                                                          Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(025),C(335) Say "Status"                                                              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(025),C(420) Say "Desenvolvedor"                                                       Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(162),C(005) Say "Solicitação da Tarefa"                                               Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(163),C(250) Say "Solução Adotada"                                                     Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(163),C(360) Say "Duplo Click sobre a tarefa, visualiza Solicitação e Solução Adotada" Size C(165),C(008) COLOR CLR_RED   PIXEL OF oDlgP
   @ C(150),C(268) Say "=="                                                                  Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(150),C(005) Say "ESTATÍSTICAS:" Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(150),C(037) Jpeg FILE "br_verde"    Size C(009),C(009) PIXEL NOBORDER OF oDlgP
   @ C(150),C(070) Jpeg FILE "br_amarelo"  Size C(009),C(009) PIXEL NOBORDER OF oDlgP
   @ C(150),C(103) Jpeg FILE "br_laranja"  Size C(009),C(009) PIXEL NOBORDER OF oDlgP
   @ C(150),C(135) Jpeg FILE "br_pink"     Size C(009),C(009) PIXEL NOBORDER OF oDlgP
   @ C(150),C(168) Jpeg FILE "br_vermelho" Size C(009),C(009) PIXEL NOBORDER OF oDlgP
   @ C(150),C(200) Jpeg FILE "br_azul"     Size C(009),C(009) PIXEL NOBORDER OF oDlgP
   @ C(150),C(232) Jpeg FILE "br_cancel"   Size C(009),C(009) PIXEL NOBORDER OF oDlgP

   @ C(032),C(006) MsGet oGet1 Var dData01 Size C(030),C(009) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlgP
   @ C(032),C(037) MsGet oGet2 Var dData02 Size C(030),C(009) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlgP
 
   @ C(005),C(335) Say "Ordenação"                       Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(013),C(335) ComboBox cComboBx7    Items aComboBx7 Size C(130),C(010) PIXEL OF oDlgP When lChumba

   @ C(011),C(470) Button "\/" Size C(014),C(012) PIXEL OF oDlgP ACTION( ExpandeTel(2) )
   @ C(011),C(485) Button "/\" Size C(014),C(012) PIXEL OF oDlgP ACTION( ExpandeTel(1) )

   @ C(033),C(068) ComboBox cComboBx1    Items aComboBx1 Size C(048),C(010) PIXEL OF oDlgP
   @ C(033),C(118) ComboBox cComboBx2    Items aComboBx2 Size C(068),C(010) PIXEL OF oDlgP
   @ C(033),C(189) ComboBox cComboBx3    Items aComboBx3 Size C(060),C(010) PIXEL OF oDlgP
   @ C(033),C(252) ComboBox cComboBx4    Items aComboBx4 Size C(080),C(010) PIXEL OF oDlgP
   @ C(033),C(335) ComboBox cComboBx5    Items aComboBx5 Size C(080),C(010) PIXEL OF oDlgP
   @ C(033),C(420) ComboBox cComboBx6    Items aComboBx6 Size C(080),C(010) PIXEL OF oDlgP

   @ C(170),C(005) GET oMemo1 Var cMemo1 MEMO Size C(240),C(030) PIXEL OF oDlgP
   @ C(170),C(250) GET oMemo2 Var cMemo2 MEMO Size C(248),C(030) PIXEL OF oDlgP

   @ C(202),C(005) METER oMeter1 VAR nMeter1 Size C(493),C(008) NOPERCENTAGE PIXEL OF oDlgP

   @ C(148),C(047) MsGet oGet11  Var cVerde   Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba
   @ C(148),C(080) MsGet oGet3  Var cAmarelo  Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba
   @ C(148),C(113) MsGet oGet4  Var cLaranja  Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba
   @ C(148),C(145) MsGet oGet5  Var cRosa     Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba
   @ C(148),C(178) MsGet oGet6  Var cVermelho Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba
   @ C(148),C(210) MsGet oGet7  Var cAzul     Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba
   @ C(148),C(242) MsGet oGet9  Var cCancel   Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba
   @ C(148),C(282) MsGet oGet8  Var cTarefas  Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgP When lChumba

   If AAA_Abertura == 1
      @ C(162),C(046) Button "..."          Size C(008),C(007) PIXEL OF oDlgP ACTION ( AbreDetalhe(aBrowse[oBrowse:nAt,02]) )
   Else
      @ C(211),C(046) Button "..."          Size C(008),C(007) PIXEL OF oDlgP ACTION ( AbreDetalhe(aBrowse[oBrowse:nAt,02]) )
      @ C(011),C(293) Button "Estatísticas" Size C(037),C(012) PIXEL OF oDlgP ACTION ( AbreEstaT() )
   Endif
  
   // Deixar comentado esta opção. Poderá ser utilizado no futuro
// @ C(011),C(252) Button "Data Inicial" Size C(037),C(012) PIXEL OF oDlgP ACTION ( DataIniPrev() )

   @ C(011),C(174) Button "Troca Visual" Size C(037),C(012) PIXEL OF oDlgP ACTION ( TrocaVisual()   )
   @ C(011),C(213) Button "Todas Datas"  Size C(037),C(012) PIXEL OF oDlgP ACTION ( CarBrowse(2, 0) )
   @ C(011),C(252) Button "Só Previstas" Size C(037),C(012) PIXEL OF oDlgP ACTION ( CarBrowse(2, 1) )

   @ C(148),C(344) Button "Relação"      Size C(037),C(012) PIXEL OF oDlgP ACTION( U_ESPREL10(cCombobx6) )
   @ C(148),C(382) Button "Extras"       Size C(037),C(012) PIXEL OF oDlgP ACTION( U_ESPEXT01() )
   @ C(148),C(420) Button "Apontamentos" Size C(037),C(012) PIXEL OF oDlgP ACTION( ChamaAponta(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,05]) )
   @ C(148),C(458) Button "Transf.Horas" Size C(037),C(012) PIXEL OF oDlgP ACTION( TransfeHoras() )
   @ C(208),C(006) Button "Atualizar"    Size C(037),C(012) PIXEL OF oDlgP ACTION (PesquisaTarefa() )
   @ C(208),C(056) Button "Visão Projeto" Size C(037),C(012) PIXEL OF oDlgP ACTION( U_ESPARV01(aBrowse[oBrowse:nAt,20], lHoras) )

   If AAA_Abertura == 1
      @ C(212),C(100) CheckBox oCheckBox1 Var lHoras  Prompt "Visualizar com Horas" Size C(062),C(008) PIXEL OF oDlgP   
      @ C(148),C(306) Button "Reordenar"    Size C(037),C(012) PIXEL OF oDlgP ACTION( REORGATAR() )
   Else
      @ C(212),C(100) CheckBox oCheckBox1 Var lHoras  Prompt "V.Horas" Size C(062),C(008) PIXEL OF oDlgP   
      @ C(208),C(128) Button "Reordenar"    Size C(037),C(012) PIXEL OF oDlgP ACTION( REORGATAR() )
   Endif
   
   @ C(208),C(167) Button "Inc.Normal"   Size C(037),C(012) PIXEL OF oDlgP ACTION( TrataOperacao("I", "0     ","      ", "", "", "", "", "", "", "" ) ) && When lChumba
// @ C(208),C(206) Button "Inc.Projeto"  Size C(037),C(012) PIXEL OF oDlgP ACTION( TrataOperacao("P", "0     ","      ", "", "", "", "", "", "", "") ) When lChumba
   @ C(208),C(206) Button "Especificação" Size C(037),C(012) PIXEL OF oDlgP ACTION( U_ESPTAR20(Substr(aBrowse[oBrowse:nAt,02],01,06), Substr(aBrowse[oBrowse:nAt,02],08,02), aBrowse[oBrowse:nAt,05], aBrowse[oBrowse:nAt,18]) )
   @ C(208),C(247) Button "Alterar"      When Len(aBrowse) <> 0 Size C(037),C(012) PIXEL OF oDlgP ACTION( TrataOperacao("A", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,20], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11], aBrowse[oBrowse:nAt,12], aBrowse[oBrowse:nAt,13],, aBrowse[oBrowse:nAt,14]) ) 
   @ C(208),C(301) Button "Pesquisa"     Size C(037),C(012) PIXEL OF oDlgP ACTION( PESQTAREFAS() )
   @ C(208),C(342) Button "Histórico"    When Len(aBrowse) <> 0 Size C(037),C(012) PIXEL OF oDlgP ACTION( TrataOperacao("H", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,20], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11], aBrowse[oBrowse:nAt,12], aBrowse[oBrowse:nAt,13],, aBrowse[oBrowse:nAt,14]) ) 
   @ C(208),C(381) Button "Legenda"      Size C(037),C(012) PIXEL OF oDlgP ACTION( U_ESPSTA03() )
   @ C(208),C(420) Button "Calendário"   Size C(037),C(012) PIXEL OF oDlgP ACTION( U_ESPCAL01() )
   @ C(208),C(460) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   // para o 1 = 633 = 127
   // para o 2 = 733 = 150

   If nTvisual == "1"

      __Altura := IIF(AAA_Abertura == 1, 127, 197)
    
      oBrowse := TCBrowse():New( 058 , 005, 633, __Altura,,{''                ,; // 01 - Legenda da Tarefa
                                                            'Codigo'          ,; // 02 - Código da Tarefa
                                                            'Prio'            ,; // 03 - Prioridade da tarefa
                                                            'Ordem'           ,; // 04 - Ordem de Execusão da Tarefa
                                                            'Título da Tarefa',; // 05 - Título da Tarefa
                                                            'Abertura'        ,; // 06 - Data de abertura da Tarefa
                                                            'Tipo'            ,; // 07 - Tipo de Tarefa (Correção, Melhoria, ...)
                                                            'Apartir de'      ,; // 08 - Data a Partir de. Utilizada para cálculo da data de previsão de entrega
                                                            'Estimativa'      ,; // 09 - Estimativa de tempo para desenvolvimento (Em Dias)
                                                            'Previsto'        ,; // 10 - Data Prevista de Entrega da Tarefa
                                                            'Tot.Horas'       ,; // 11 - Total de horas para desenvolvimento da tarefa
                                                            'Tot.Desen'       ,; // 12 - Total de Horas já utilizadas no desenvolvimeno da Tarefa
                                                            'Tot.Atraso'      ,; // 13 - Total de horas de atraso apontadas para a tarefa
                                                            'Saldo Horas'     ,; // 14 - Saldo de Horas restantes para desenvolvimento
                                                            'Encerrada Em'    ,; // 15 - Data em que a tarefa foi encerrada
                                                            'Origem'          ,; // 16 - Origem da Tarefa
                                                            'Componente'      ,; // 17 - Componente da Tarefa
                                                            'Usuário'         ,; // 18 - Usuário que abriu a Tarefa
                                                            'Chamado'}        ,; // 19 - Nº do chamado em relação a Solutio ou TOTVS
                                                            {20,50,50,50},oDlgP,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

      // Seta vetor para a browse                            
      oBrowse:SetArray(aBrowse) 
    
      // Monta a linha a ser exibina no Browse
      If Len(aBrowse) == 0
      Else
         oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                               aBrowse[oBrowse:nAt,02]               ,;
                               aBrowse[oBrowse:nAt,03]               ,;
                               aBrowse[oBrowse:nAt,04]               ,;                         
                               aBrowse[oBrowse:nAt,05]               ,;                         
                               aBrowse[oBrowse:nAt,06]               ,;                         
                               SubStr(aBrowse[oBrowse:nAt,07],01,10) ,;                         
                               aBrowse[oBrowse:nAt,08]               ,;                         
                               aBrowse[oBrowse:nAt,09]               ,;                         
                               aBrowse[oBrowse:nAt,10]               ,;                                                     
                               aBrowse[oBrowse:nAt,11]               ,;                         
                               aBrowse[oBrowse:nAt,12]               ,;
                               aBrowse[oBrowse:nAt,13]               ,;
                               aBrowse[oBrowse:nAt,14]               ,;
                               aBrowse[oBrowse:nAt,15]               ,;
                               aBrowse[oBrowse:nAt,16]               ,;
                               aBrowse[oBrowse:nAt,17]               ,;
                               aBrowse[oBrowse:nAt,18]               ,;
                               aBrowse[oBrowse:nAt,19]               }}
      
         oBrowse:bLDblClick := {|| MOSTRAOBS(aBrowse[oBrowse:nAt,02]) } 

      Endif   

      oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}
      
   Else

      __Altura := IIF(AAA_Abertura == 1, 127, 197)
    
      oBrowse := TCBrowse():New(058,005,633, __Altura,,,,oDlgP,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

      oBrowse:AddColumn(TCColumn():New('Lg'              , {|| aBrowse[oBrowse:nAt,01]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Codigo'          , {|| aBrowse[oBrowse:nAt,02]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Prio'            , {|| aBrowse[oBrowse:nAt,03]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Ordem'           , {|| aBrowse[oBrowse:nAt,04]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Título da Tarefa', {|| aBrowse[oBrowse:nAt,05]},"@!",,,"LEFT", 120,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Abertura'        , {|| aBrowse[oBrowse:nAt,06]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Tipo'            , {|| aBrowse[oBrowse:nAt,07]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Apartir de'      , {|| aBrowse[oBrowse:nAt,08]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Estimativa'      , {|| aBrowse[oBrowse:nAt,09]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Previsto'        , {|| aBrowse[oBrowse:nAt,10]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Tot.Horas'       , {|| aBrowse[oBrowse:nAt,11]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Tot.Desen'       , {|| aBrowse[oBrowse:nAt,12]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Tot.Atraso'      , {|| aBrowse[oBrowse:nAt,13]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Saldo Horas'     , {|| aBrowse[oBrowse:nAt,14]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Encerrada Em'    , {|| aBrowse[oBrowse:nAt,15]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Origem'          , {|| aBrowse[oBrowse:nAt,16]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Componente'      , {|| aBrowse[oBrowse:nAt,17]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Usuário'         , {|| aBrowse[oBrowse:nAt,18]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oBrowse:AddColumn(TCColumn():New('Chamado'         , {|| aBrowse[oBrowse:nAt,19]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )

      oBrowse:SetArray(aBrowse)
      oBrowse:bWhen := { || Len(aBrowse) > 0 }

      // Ordena a coluna selecionada
      oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}

      // Para que a linha seja colorida conforme a sua escolha é expressamente necessário informar o atributo lUseDefaultColors como falso
      // Se estiver usando o MsNewGetDados() é necessário colocar assim:>> oList:oBrowse:lUseDefaultColors := .F.
      oBrowse:lUseDefaultColors := .F.                
        
      // A propriedade SetBlkBackColor serve para colorir o fundo do grid
      // criei a função GETDCLR no qual passo a ela a linha posicionada e uma determinada cor.
      oBrowse:SetBlkBackColor({|| TrocaCorLinha(oBrowse:nAt,16777215)})
      
      // Altera a cor da linha do grid
      // bColor := 16777215
      // oBrowse:SetBlkColor(bColor)

      //Se estiver usando o MsNewGetDados()
      //oList:oBrowse:SetBlkBackColor({|| GETDCLR(oList:nAt,8421376)})
      //oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   Endif

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)
           
// Função que troca a cor da linha conforme prioridade
Static Function TrocaCorLinha(nLinha,nCor)

   Local cSql := ""
   Local nRet := 16777215

   If Len(aBrowse) == 0
      Return nRet
   Endif

   Do Case
      Case Alltrim(aBrowse[nLinha,01]) == "ABERTURA"
           nRet := 16777215
      Case Alltrim(aBrowse[nLinha,01]) == "APROVADA"
           nRet := 65535
      Case Alltrim(aBrowse[nLinha,01]) == "REPORVADA"
           nRet := 8421504
      Case Alltrim(aBrowse[nLinha,01]) == "DESENVOLVIMENTO"
           nRet := 16776960
      Case Alltrim(aBrowse[nLinha,01]) == "AGUARDANDO VAL."
           nRet := 16711935
      Case Alltrim(aBrowse[nLinha,01]) == "INCONFORME"
           nRet := 255
      Case Alltrim(aBrowse[nLinha,01]) == "VALIDAÇÃO OK"
           nRet := 65280
      Case Alltrim(aBrowse[nLinha,01]) == "LIBERADA PRO"
           nRet := 16711680
      Case Alltrim(aBrowse[nLinha,01]) == "TAREFA ENC."
           nRet := 32896
      Case Alltrim(aBrowse[nLinha,01]) == "AGUARDANDO EST."
           nRet := 0
   EndCase

   Return nRet

   // FICA COMO TESTE
   // Em caso de Aguardando Validação, não altera a cor
   If Alltrim(aBrowse[nLinha,1]) == "AGUARDANDO VAL."
      nRet := 65280
      Return(nRet)
   Endif

   // Pesquisa a prioridade para buscar a cor a ser visualizada
   // If Select("T_CORES") > 0
   //    T_CORES->( dbCloseArea() )
   // EndIf
   // 
   // cSql := ""
   // cSql := "SELECT ZZD_COR"
   // cSql += "  FROM " + RetSqlName("ZZD")
   // cSql += " WHERE ZZD_NOME   = '" + Alltrim(aBrowse[nLinha,3]) + "'"
   // cSql += "   AND ZZD_DELETE = ''"
   //
   // cSql := ChangeQuery( cSql )
   // dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CORES", .T., .T. )
   // 
   // If T_CORES->( EOF() )
   //    nRet := 16777215
   //    Return(nRet)
   // Endif
   //    
   // Do Case
   //    Case Alltrim(T_CORES->ZZD_COR) == "1"
   //         nRet := 0
   //    Case Alltrim(T_CORES->ZZD_COR) == "2"
   //         nRet := 8388608   
   //    Case Alltrim(T_CORES->ZZD_COR) == "3"
   //         nRet := 32768
   //    Case Alltrim(T_CORES->ZZD_COR) == "4"
   //         nRet := 8421376
   //    Case Alltrim(T_CORES->ZZD_COR) == "5"
   //         nRet := 128
   //    Case Alltrim(T_CORES->ZZD_COR) == "6"
   //         nRet := 8388736
   //    Case Alltrim(T_CORES->ZZD_COR) == "7"
   //         nRet := 32896
   //   Case Alltrim(T_CORES->ZZD_COR) == "8"
   //        nRet := 12632256
   //   Case Alltrim(T_CORES->ZZD_COR) == "A"
   //        nRet := 8421504
   //   Case Alltrim(T_CORES->ZZD_COR) == "B"
   //        nRet := 16711680
   //   Case Alltrim(T_CORES->ZZD_COR) == "C"
   //        nRet := 65280
   //   Case Alltrim(T_CORES->ZZD_COR) == "D"
   //        nRet := 16776960
   //   Case Alltrim(T_CORES->ZZD_COR) == "E"
   //        nRet := 255
   //   Case Alltrim(T_CORES->ZZD_COR) == "F"
   //        nRet := 16711935
   //   Case Alltrim(T_CORES->ZZD_COR) == "G"
   //        nRet := 65535
   //   Case Alltrim(T_CORES->ZZD_COR) == "H"
   //        nRet := 16777215
   //EndCase

Return nRet

// Função que Ordena a coluna selecionada no grid
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// Função que Expande ou recolhe o grid
Static Function ExpandeTel(_AbreouFecha)

   If _AbreouFecha == 1
      AAA_Abertura := 1
   Else
      AAA_Abertura := 2   
   Endif

   // Atualiza o campo ZZI_ABRE da tabela ZZI010
   DbSelectArea("ZZI")
   DbSetOrder(1)
   If DbSeek(Alltrim(cUserName))
      RecLock("ZZI",.F.)
      ZZI_ABRE := AAA_Abertura
      MsUnLock()              
   Endif
   
   oDlgP:eND()
   
   U_ESPTAR01()

Return(.T.)   

// Sub-Função que mostra a Descrição da Tarefa e a Solução Adotada
Static Function MOSTRAOBS(_Codigo)

   Local cSql     := ""
   Local cTexto   := ""
   Local cTarefa  := ""
   Local cSolucao := ""

   cMemo1 := ""
   cMemo2 := ""

   If Select("T_MOSTRA") > 0
      T_MOSTRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       ZZG_TITU  ,"
   cSql += "       ZZG_USUA  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_NOT1)) AS NOTAS    , "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS SOLICITAS  "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Alltrim(Substr(_Codigo,01,06)) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Alltrim(Substr(_Codigo,08,02)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

   If T_MOSTRA->( EOF() )
      Return .T.
   Endif

   // Carrega o campo cTexto
   If !Empty(Alltrim(T_MOSTRA->DESCRICAO))
      cTarefa := "TAREFA Nº: "  + Alltrim(Substr(_Codigo,01,06) + "." + Substr(_Codigo,08,02)) + " - " + Alltrim(T_MOSTRA->ZZG_TITU) + chr(13) + chr(10)
      cTarefa += "Solicitante:" + Alltrim(T_MOSTRA->ZZG_USUA) + chr(13) + chr(10)
      ctarefa += "Solicitação:" + chr(13) + chr(10)
      cMemo1  := cTarefa + Chr(13) + Alltrim(T_MOSTRA->DESCRICAO)
   Endif

   // Carrega o campo cSolucao
   If !Empty(Alltrim(T_MOSTRA->SOLICITAS))
      cSolucao := "TAREFA Nº " + Alltrim(Substr(_Codigo,01,06) + "." + Substr(_Codigo,08,02)) + chr(13) + chr(10)
      cMemo2   := cSolucao + Chr(13) + Alltrim(T_MOSTRA->SOLICITAS)
   Endif

   oMemo1:Refresh()
   oMemo2:Refresh()   

Return .T.

// Procedimento que realiza a pesquisa das tarefas conforme filtro informado
Static Function TrataOperacao(_Operacao, _Codigo, __Projeto, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo)

   // Inclusão de Tarefa Normal
   If _Operacao == "I"
      U_ESPTAR02("I", _Codigo)

      // Atualiza o grid
      CarBrowse(2,0)
   Endif
                             
   // Inclusão de Tarefa do Projeto
   If _Operacao == "P"
      U_ESPTAR15("C")

      // Atualiza o grid
      CarBrowse(2,0)
   Endif

   // Alteração de Tarefa
   If _Operacao == "A"

      // Cria o parâmetro de pesquisa
      __Filtros := cCombobx1     + "|" + ;
                   cCombobx2     + "|" + ;
                   cCombobx3     + "|" + ;
                   cCombobx4     + "|" + ;
                   cCombobx5     + "|" + ;
                   cCombobx6     + "|" + ;
                   cCombobx7     + "|" + ;
                   Dtoc(dData01) + "|" + ;
                   Dtoc(dData02) + "|"

      If Empty(Alltrim(__Projeto))
         U_ESPTAR02("A", _Codigo, __Filtros)
      Else         
         MsgAlert("Alteração tarefa de projeto não permitida por esta tela. Utilize Consulta de Tarefas para realizar alteração.")
      Endif            

      // Atualiza o grid
      CarBrowse(2,0)

   Endif

   // Exclusão de Tarefa
   If _Operacao == "E"
      If Empty(Alltrim(__Projeto))
         U_ESPTAR02("E", _Codigo)
      Else
         U_ESPTAR18("E", _Codigo)
      Endif            

      // Atualiza o grid
      CarBrowse(2,0)

   Endif

   // Exclusão de Tarefa
   If _Operacao == "H"
      U_ESPHIS01(_Codigo, __Apartir, __Estima, __Previsto, __Thoras, __Tdesen, __Tatraso, __Tsaldo)

      // Atualiza o grid
      CarBrowse(2,0)

   Endif

Return .T.

// Procedimento que realiza a pesquisa das tarefas conforme filtro informado
Static Function PesquisaTarefa()

   // Carrega o Array com os dados das tarefas conforme o filtro informado.
   Private aBrowse := {}

   aBrowse := {}

   // Atualiza a tabela de parâmetros com os dados informados
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZI_USUA, " + CHR(13)
   cSql += "       ZZI_DT01, " + CHR(13)
   cSql += "       ZZI_DT02, " + CHR(13)
   cSql += "       ZZI_ORIG, " + CHR(13)
   cSql += "       ZZI_COMP, " + CHR(13)
   cSql += "       ZZI_PRIO, " + CHR(13)
   cSql += "       ZZI_STAT, " + CHR(13)
   cSql += "       ZZI_DESE, " + CHR(13)
   cSql += "       ZZI_ARIO, " + CHR(13)
   cSql += "       ZZI_ABRE  " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZI") + CHR(13)
   cSql += " WHERE ZZI_USUA = '" + Alltrim(cUserName) + "'" + CHR(13)
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )
   
   // Inseri os dados na Tabela - SMT
   If T_MASTER->( EOF() )
      aArea := GetArea()
      dbSelectArea("ZZI")
      RecLock("ZZI",.T.)
      ZZI_USUA := IIF(Alltrim(cComboBx3) = "TODOS OS USUÁRIOS", cUserName, cComboBx3)
      ZZI_DT01 := dData01
      ZZI_DT02 := dData02
      ZZI_ORIG := SubStr(cComboBx1,01,06)
      ZZI_COMP := SubStr(cComboBx2,01,06)
      ZZI_PRIO := SubStr(cComboBx4,01,06)
      ZZI_STAT := Alltrim(SubStr(cComboBx5,01,02))
      ZZI_DESE := SubStr(cComboBx6,01,06)
      ZZI_ARIO := Alltrim(cComboBx3)
      ZZI_ORDE := SubStr(cComboBx7,01,02)
      ZZI_ABRE := AAA_Abertura
      MsUnLock()
   Else
      DbSelectArea("ZZI")
      DbSetOrder(1)
      If DbSeek(Alltrim(cUserName))
         RecLock("ZZI",.F.)
         ZZI_DT01 := dData01
         ZZI_DT02 := dData02
         ZZI_ORIG := SubStr(cComboBx1,01,06)
         ZZI_COMP := SubStr(cComboBx2,01,06)
         ZZI_PRIO := SubStr(cComboBx4,01,06)
         ZZI_STAT := Alltrim(SubStr(cComboBx5,01,02))
         ZZI_DESE := SubStr(cComboBx6,01,06)
         ZZI_ARIO := Alltrim(cComboBx3)
         ZZI_ORDE := SubStr(cComboBx7,01,02)
         ZZI_ABRE := AAA_Abertura
         MsUnLock()              
      Endif
   Endif

   oDlgP:End()

   U_ESPTAR01()   

Return .T.

// Processo que envia os e-mail marketing
Static Function EMAILMARKETING()         

   Local cSql     := ""
   Private OLIST
   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oDlgmail

   // Pesquisa as tarefas que estão marcadas para serem enviadas via e-mail marketing
   If Select("T_EMAIL") > 0
      T_EMAIL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI, "
   cSql += "       ZZG_SEQU, "
   cSql += "       ZZG_TITU  "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_STAT = '7'" // Status 7 - Em Produção
   cSql += "   AND ZZG_DELE = '' "
   cSql += "   AND ZZG_MARK = 'X'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMAIL", .T., .T. )
   
   If T_EMAIL->( EOF() )
      aLista := {}
      aAdd( aLista, { .F., '', '' } )
   Else   
      T_EMAIL->( DbGoTop() )
      WHILE !T_EMAIL->( EOF() )
         AADD(aLista, {.F.               ,; // 01 - Marcação
                       T_EMAIL->ZZG_CODI ,; // 02 - Código da Tarefa
                       T_EMAIL->ZZG_SEQU ,; // 03 - Sequencial da Trefa
                       T_EMAIL->ZZG_TITU }) // 04 - Título da Tarefa
         T_EMAIL->( DbSkip() )
      Enddo                            
   Endif   

   DEFINE MSDIALOG oDlgmail TITLE "Envio de e-mail" FROM C(178),C(181) TO C(549),C(856) PIXEL

   @ C(002),C(003) Say "Selecione as Tarefas a serem enviadas" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlgmail

   @ C(168),C(003) Button "Marca Todos"    Size C(037),C(012) PIXEL OF oDlgmail ACTION( MARCA_T(1) )
   @ C(168),C(040) Button "Desmarca Todos" Size C(037),C(012) PIXEL OF oDlgmail ACTION( MARCA_T(2) )   

   @ C(168),C(255) Button "Enviar" Size C(037),C(012) PIXEL OF oDlgmail ACTION( JANENVIO() )
   @ C(168),C(295) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgmail ACTION( oDlgmail:End() )

   @ 010,003 LISTBOX oList FIELDS HEADER "", "Código" ,"Seq", "Título das Tarefas" PIXEL SIZE 425,200 OF oDlgmail ;
                           ON dblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aLista )
   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
          					   aLista[oList:nAt,02],;
          					   aLista[oList:nAt,03],;
         	        	       aLista[oList:nAt,04]}}

   ACTIVATE MSDIALOG oDlgmail CENTERED 

Return(.T.)

// Função que marca/desmarca as tarefas a serem enviadas via e-mail marketing
Static Function MARCA_T(_Tipo)         

   Local nContar := 0

   For nContar = 1 to Len(aLista)
       If _Tipo == 1
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.          
       Endif
   Next nContar               
          
   oList:SetArray( aLista )
   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
          					   aLista[oList:nAt,02],;
          					   aLista[oList:nAt,03],;
         	        	       aLista[oList:nAt,04]}}
   
Return .T.

// Abre tela de seleção de destinatários de e-mail marketing
Static Function JANENVIO()         

   Local nContar  := 0
   Local lMarca   := .F.

   Private cMemo1 := "Segue abaixo relação de tarefas implementadas no Sistema Protheus."
   Private cMemo2 := ""

   Private oMemo1
   Private oMemo2

   Private oDlgEnvio

   Private aUsuario := {}

   // Verifica se existe alguma tarefa marcada para envio
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarca := .T.
          Exit
       Endif
   Next nContar
   
   If !lMarca       
      MsgAlert("Nenhuma tarefa marcada para envio de e-mail.")
      Return .T.
   Endif   
   
   // Carrega o grid dos usuários
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY ZZA_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )
   
   T_USUARIO->( DbGoTop() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aUsuario, { T_USUARIO->ZZA_NOME, T_USUARIO->ZZA_EMAI } )
      T_USUARIO->( DbSkip() )
   ENDDO
   
   DEFINE MSDIALOG oDlgEnvio TITLE "Envio de e-mail" FROM C(178),C(181) TO C(599),C(766) PIXEL

   @ C(002),C(004) Say "Usuários"      Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnvio
   @ C(002),C(123) Say "Destinatários" Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnvio
   @ C(139),C(004) Say "Assunto"       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnvio
   
   @ C(012),C(123) GET oMemo2 Var cMemo2 MEMO Size C(165),C(124) PIXEL OF oDlgEnvio
   @ C(148),C(003) GET oMemo1 Var cMemo1 MEMO Size C(285),C(040) PIXEL OF oDlgEnvio

   @ C(193),C(211) Button "Enviar" Size C(037),C(012) PIXEL OF oDlgEnvio ACTION( MANDAEMAIL() )
   @ C(193),C(251) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgEnvio ACTION( oDlgEnvio:End() )

   oUsuario := TCBrowse():New( 012 , 004, 150, 160,,{'Usuários', 'E-mail'},{20,50,50,50},oDlgEnvio,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
 
   // Seta vetor para a browse                            
   oUsuario:SetArray(aUsuario) 
    
   oUsuario:bLine := {||{ aUsuario[oUsuario:nAt,01], aUsuario[oUsuario:nAt,02] } }
      
   oUsuario:bLDblClick := {|| UTILIZAUSU(aUsuario[oUsuario:nAt,02]) } 

   ACTIVATE MSDIALOG oDlgEnvio CENTERED 

Return(.T.)

// Processo que transfere o e-mail do usuário selecionado para o cmapo memo
Static Function UTILIZAUSU(_Email)

   If Empty(_Email)
      Return .T.
   Endif

   cMemo2 := cMemo2 + Alltrim(_Email) + ";"
   oMemo2:Refresh()
   
Return .T.

// Processo que envia o e-mail marketing selecionados
Static Function MANDAEMAIL()

   Local nContar  := 0
   Local cAssunto := ""
   Local cEnde01  := ""
   Local cEnde02  := ""
   Local cTexto   := ""
   Local nRegua   := 0
   
   // Verifica se houve a marcação de pelo menos um aordem de produção para impressão
   For nContar = 1 to Len(aLista)
       If aLista[nContar,1] == .T.
          cAssunto := cAssunto + Alltrim(aLista[nContar,4]) + CHR(13) + CHR(10)

          cAssunto := cAssunto + Replicate("-", (Len(Alltrim(aLista[nContar,4])) * 2)) + CHR(13) + CHR(10)

          // Carrega a solicitação a ser enexada juntamente com o título tarefa
          If Select("T_MOSTRA") > 0
             T_MOSTRA->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT ZZG_FILIAL,"
          cSql += "       ZZG_CODI  ,"
          cSql += "       ZZG_SEQU  ,"
          cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO, "
          cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_NOT1)) AS NOTAS    , "
          cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS SOLICITAS  "
          cSql += "  FROM " + RetSqlName("ZZG")
          cSql += " WHERE ZZG_DELE  = ''"
          cSql += "   AND ZZG_CODI  = '" + Alltrim(aLista[nContar,2]) + "'"
          cSql += "   AND ZZG_SEQU  = '" + Alltrim(aLista[nContar,3]) + "'"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

          If T_MOSTRA->( EOF() )
             Loop
          Endif

          // Carrega o campo cTexto
          If !Empty(Alltrim(T_MOSTRA->DESCRICAO))  
             cTexto := Alltrim(T_MOSTRA->DESCRICAO)
             cAssunto := cAssunto + cTexto + chr(13) + chr(10) + chr(13) + chr(10)
          Endif
            
      Endif

   Next nContar       

   If Empty(cAssunto)
      MsgAlert("Atenção !!" + chr(13) + chr(13) + "Não foi indicada nenhuma Tarefa para envio." + chr(13) + chr(13) + "Verifique !")
      Return .T.
   Endif

   If Empty(Alltrim(cMemo2))
      MsgAlert("Atenção !!" + chr(13) + chr(13) + "Não foi informado nenhum endereço de e-mail para envio." + chr(13) + chr(13) + "Verifique !")
      Return .T.
   Endif

   // Elimina o último ponto e vírgula dos endereços de e-mail para envio
   cEnde01 := Alltrim(cMemo2)
   cEnde02 := Substr(cEnde01,01, Len(cEnde01) - 1)

   If Empty(cMemo1)
      cCorpo  := Alltrim(cAssunto)
   Else   
      cCorpo  := Alltrim(cMemo1) + chr(13) + chr(10) + chr(13) + chr(10) + Alltrim(cAssunto)
   Endif

   U_AUTOMR20(Alltrim(cCorpo)                , ;
              cEnde02                        , ;
              ""                             , ;
              "Informativo de Liberação de Tarefas (Protheus)" )

   oDlgEnvio:End()
   oDlgmail:End()

   // Limpa a marcação de envio de e-mail marketing
   For nContar = 1 to Len(aLista)
       If aLista[nContar,1] == .T.
          // Atualiza a tabela da Tarefa
          DbSelectArea("ZZG")
          DbSetOrder(1)

          If DbSeek(xfilial("ZZG") + aLista[nContar,2])
             RecLock("ZZG",.F.)
             ZZG_MARK := ""
             MsUnLock()                 
          Endif
       Endif
       
   Next nContar    

Return .T.

// Função que abre a tela de pesquisa de tarefas
Static Function PESQTAREFAS()

   // Chama programa que abre janela para pesquisar tarefas
   U_ESPPES01()

   // Atualiza o grid
   CarBrowse(2,0)

Return(.T.)

// Função que abre a janela do detalhe da tarefa selecionada
Static Function ABREDETALHE(_xCodTar, _xSeque)

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgDetalhe
  
   If Empty(Alltrim(_xCodTar))
      Return(.T.)
   Endif   

   // Pesquisa detalhes da tarefa selecionada
   If Select("T_MOSTRA") > 0
      T_MOSTRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL,"
   cSql += "       A.ZZG_CODI  ,"
   cSql += "       A.ZZG_SEQU  ,"
   cSql += "       SUBSTRING(A.ZZG_DATA,07,02) + '/' + SUBSTRING(A.ZZG_DATA,05,02) + '/' + SUBSTRING(A.ZZG_DATA,01,04) AS INCLUSAO,"
   cSql += "       SUBSTRING(A.ZZG_PREV,07,02) + '/' + SUBSTRING(A.ZZG_PREV,05,02) + '/' + SUBSTRING(A.ZZG_PREV,01,04) AS PREVISTO,"
   cSql += "       A.ZZG_PRIO  ,"
   cSql += "       B.ZZD_NOME  ,"
   cSql += "       A.ZZG_TITU  ,"   
   cSql += "       A.ZZG_USUA  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZG_DES1)) AS DESCRICAO, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZG_NOT1)) AS NOTAS    , "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZG_SOL1)) AS SOLICITAS  "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZD") + " B  "
   cSql += " WHERE A.ZZG_DELE   = ''"
   cSql += "   AND A.ZZG_CODI   = '" + Substr(_xCodTar,01,06) + "'"
   cSql += "   AND A.ZZG_SEQU   = '" + Substr(_xCodTar,08,02) + "'"
   cSql += "   AND B.ZZD_CODIGO = A.ZZG_PRIO"
   cSql += "   AND B.ZZD_DELETE = ''        "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

   If T_MOSTRA->( EOF() )
      Return .T.
   Endif

   // Carrega o campo cTexto
   If !Empty(Alltrim(T_MOSTRA->DESCRICAO))
      cTarefa := "TAREFA Nº: "    + Alltrim(_xCodTar) + "." + Alltrim(_xSeque) + " - " + Alltrim(T_MOSTRA->ZZG_TITU) + chr(13) + chr(10) + chr(13) + chr(10)
      cTarefa += "Solicitante:"   + Alltrim(T_MOSTRA->ZZG_USUA) + chr(13) + chr(10)
      cTarefa += "Prioridade.:"   + Alltrim(T_MOSTRA->ZZD_NOME) + chr(13) + chr(10)
      cTarefa += "Data Abertura:" + Alltrim(T_MOSTRA->INCLUSAO) + chr(13) + chr(10)
      cTarefa += "Data Prevista:" + Alltrim(T_MOSTRA->PREVISTO) + chr(13) + chr(10) + CHR(13) + CHR(10)
      cTarefa += "Solicitação:" + chr(13) + chr(10) + chr(13) + chr(10)
      cMemo1  := cTarefa + Chr(13) + Alltrim(T_MOSTRA->DESCRICAO)
   Endif

   DEFINE MSDIALOG oDlgDetalhe TITLE "Detalhes da Tarefa" FROM C(178),C(181) TO C(601),C(745) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(023) PIXEL NOBORDER OF oDlgDetalhe
   @ C(019),C(230) Say "DETALHES DA TAREFA"   Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgDetalhe
   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(278),C(164) PIXEL OF oDlgDetalhe
   @ C(196),C(122) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlgDetalhe ACTION( oDlgDetalhe:End() )

   ACTIVATE MSDIALOG oDlgDetalhe CENTERED 

Return(.T.)

// Função que realiza a reorganização das tarefas
Static Function REORGATAR()

   Local nIniciar   := 0
   Local nIntervalo := 0
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oGet1
   Local oGet2
   Local oMemo1
   Local oMemo2

   Private oDlgZ

   DEFINE MSDIALOG oDlgZ TITLE "Reordenação de Tarefas" FROM C(178),C(181) TO C(372),C(596) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(138),C(029) PIXEL NOBORDER OF oDlgZ

   @ C(034),C(002) GET oMemo1 Var cMemo1 MEMO Size C(201),C(001) PIXEL OF oDlgZ
   @ C(073),C(002) GET oMemo2 Var cMemo2 MEMO Size C(201),C(001) PIXEL OF oDlgZ

   @ C(039),C(005) Say "Este procedimento realiza a reorganização das tarefas conforme parâmetros abaixo." Size C(198),C(008) COLOR CLR_BLACK PIXEL OF oDlgZ
   @ C(051),C(005) Say "Iniciar a reorganização com a numeração"                                           Size C(099),C(008) COLOR CLR_BLACK PIXEL OF oDlgZ
   @ C(051),C(139) Say "Intervalo entre numeração"                                                         Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgZ

   @ C(060),C(005) MsGet oGet1 Var nIniciar   Size C(029),C(009) COLOR CLR_BLACK Picture "@E 999999" PIXEL OF oDlgZ
   @ C(060),C(139) MsGet oGet2 Var nIntervalo Size C(015),C(009) COLOR CLR_BLACK Picture "@E 999"    PIXEL OF oDlgZ

   @ C(080),C(065) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgZ ACTION( GERAREORG(nIniciar, nIntervalo) ) When lSalvar
   @ C(080),C(104) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgZ ACTION( oDlgZ:End() )

   ACTIVATE MSDIALOG oDlgZ CENTERED 

Return(.T.)

// Função que gera a reorganização das tarefas
Static Function GERAREORG(r_Numero, r_Intervalo)

   Local cSql         := ""
   Local aOrdem       := {}
   Local dPartida     := Ctod("  /  /    ")
   Local kPrevisto    := Ctod("  /  /    ")
   Local kApartirDe   := Ctod("  /  /    ")
   Local kDebito      := 0
   Local kCredito     := 0
   Local xOrdenacao   := 0
   Local __Ordenacao  := 0
   Local __Intervalo  := 0
   Local nContar      := 0
   Local lPrimeira    := .T.
   Local lInicial     := .F.
   Local __Adicionar
   Local cDataIni     := Ctod("  /  /    ")
   Local oGet1
   Local lCargaUm     := .T.
   Local kDestaData   := Ctod("  /  /    ")
   Local lIniMarca    := .F.
   Local nNumero      := r_Numero
   Local nIntervalo   := r_Intervalo

   // Consiste os dados antes da reordenação
   If nNumero = 0
      MsgAlert("Iniciar reorganização com o número não informado.")
      Return(.T.)
   Endif
      
   If nIntervalo = 0
      MsgAlert("Intervalo entre numeração não informado.")
      Return(.T.)
   Endif

   oDlgZ:End()

   // Pesquisa a Ordenação e o intervalo para a prioridade informada
   If Select("T_PRIORIDADE") > 0
      T_PRIORIDADE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_ORDE,"
   cSql += "       ZZJ_INTE "
   cSql += "  FROM " + RetSqlName("ZZJ") 
   cSql += " WHERE D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORIDADE", .T., .T. )

   __Ordenacao := T_PRIORIDADE->ZZJ_ORDE
   __Intervalo := T_PRIORIDADE->ZZJ_INTE

   // Pesquisa as tarefas da prioridade informada para realizar a renumeração das mesmas
   If Select("T_ORDENACAO") > 0
      T_ORDENACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL," + CHR(13)
   cSql += "       A.ZZG_CODI  ," + CHR(13)
   cSql += "       A.ZZG_SEQU  ," + CHR(13)
   cSql += "       A.ZZG_TITU  ," + CHR(13)
   cSql += "       A.ZZG_USUA  ," + CHR(13)
   cSql += "       A.ZZG_DATA  ," + CHR(13)
   cSql += "       A.ZZG_HORA  ," + CHR(13)
   cSql += "       A.ZZG_STAT  ," + CHR(13)
   cSql += "       A.ZZG_DES1  ," + CHR(13)
   cSql += "       A.ZZG_PRIO  ," + CHR(13)
   cSql += "       A.ZZG_NOT1  ," + CHR(13)
   cSql += "       A.ZZG_PREV  ," + CHR(13)
   cSql += "       A.ZZG_TERM  ," + CHR(13)
   cSql += "       A.ZZG_PROD  ," + CHR(13)
   cSql += "       A.ZZG_SOL1  ," + CHR(13)
   cSql += "       A.ZZG_DELE  ," + CHR(13)
   cSql += "       A.ZZG_ORIG  ," + CHR(13)
   cSql += "       A.ZZG_CHAM  ," + CHR(13)
   cSql += "       A.ZZG_COMP  ," + CHR(13)
   cSql += "       A.ZZG_PROG  ," + CHR(13)
   cSql += "       A.ZZG_PROJ  ," + CHR(13)
   cSql += "       B.ZZD_NOME  ," + CHR(13)
   cSql += "       B.ZZD_ORDE  ," + CHR(13)
   cSql += "       C.ZZF_NOME  ," + CHR(13)
   cSql += "       D.ZZB_NOME  ," + CHR(13)
   cSql += "       E.ZZC_LEGE  ," + CHR(13)
   cSql += "       A.ZZG_TTAR  ," + CHR(13)
   cSql += "       A.ZZG_ESTI  ," + CHR(13)
   cSql += "       A.ZZG_XHOR  ," + CHR(13)
   cSql += "       A.ZZG_XDIA  ," + CHR(13)
   cSql += "       A.ZZG_DEBI  ," + CHR(13)
   cSql += "       A.ZZG_CRED  ," + CHR(13)
   cSql += "       A.ZZG_ORDE  ," + CHR(13)
   cSql += "       A.ZZG_APAR   " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZG") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("ZZD") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("ZZF") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("ZZB") + " D, " + CHR(13)
   cSql += "       " + RetSqlName("ZZC") + " E  " + CHR(13)
   cSql += " WHERE A.ZZG_DELE   = ''" + CHR(13)
   cSql += "   AND A.ZZG_DATA  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + CHR(13)
   cSql += "   AND A.ZZG_DATA  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + CHR(13)
   cSql += "   AND A.ZZG_STAT  <> '1'" + CHR(13)

   If Alltrim(Substr(cCombobx5,01,02)) == "X"
      cSql += "   AND '0000' + A.ZZG_STAT = E.ZZC_CODIGO " + CHR(13)      
   Else   
      cSql += "   AND ('00000' + A.ZZG_STAT = E.ZZC_CODIGO OR '0000' + A.ZZG_STAT = E.ZZC_CODIGO)" + CHR(13)
   Endif   

   cSql += "   AND A.ZZG_PRIO   = B.ZZD_CODIGO " + CHR(13)
   cSql += "   AND A.ZZG_ORIG   = C.ZZF_CODIGO " + CHR(13)
   cSql += "   AND C.ZZF_DELETE = ''"            + CHR(13)
   cSql += "   AND A.ZZG_COMP   = D.ZZB_CODIGO " + CHR(13)

   // Origem
   If Substr(cCombobx1,01,06) <> "000000"
      cSql += " AND A.ZZG_ORIG = '" + Substr(cCombobx1,01,06) + "'" + CHR(13)
   Endif
      
   // Componente
   If Substr(cCombobx2,01,06) <> "000000"
      cSql += " AND A.ZZG_COMP = '" + Substr(cCombobx2,01,06) + "'" + CHR(13)
   Endif
                             
   // Usuário
   If Alltrim(cCombobx3) <> "TODOS OS USUÁRIOS" .AND. !Empty(Alltrim(cCombobx3))
      cSql += " AND A.ZZG_USUA = '" + Alltrim(cCombobx3) + "'" + CHR(13)
   Endif

   // Prioridade
   If Substr(cCombobx4,01,06) <> "000000"
      cSql += " AND A.ZZG_PRIO = '" + Substr(cCombobx4,01,06) + "'" + CHR(13)
   Endif

   // Status
   If Alltrim(Substr(cCombobx5,01,02)) <> "T"
      If Alltrim(Substr(cCombobx5,01,02)) <> "A" .AND. ;
         Alltrim(Substr(cCombobx5,01,02)) <> "B" .AND. ;
         Alltrim(Substr(cCombobx5,01,02)) <> "C"
         Do Case
            Case Alltrim(Substr(cCombobx5,01,02)) == "X"
                 cSql += " AND A.ZZG_STAT = '10'" + CHR(13)
            Case Alltrim(Substr(cCombobx5,01,02)) == "R"
                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','8','10')" + CHR(13)
            Otherwise
                 cSql += " AND LTRIM(A.ZZG_STAT) = '" + Alltrim(Substr(cCombobx5,01,02)) + "'" + CHR(13)
         EndCase
      Else
         Do Case
            Case Alltrim(Substr(cCombobx5,01,02)) == "A"
                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','8')" + CHR(13)
            Case Alltrim(Substr(cCombobx5,01,02)) == "B"
                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','8','10')" + CHR(13)            
            Case Alltrim(Substr(cCombobx5,01,02)) == "B"
                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','7','8','10')" + CHR(13)            
         EndCase
      Endif            
   Endif

   // Programador
   If Substr(cCombobx6,01,06) <> "000000"
//    cSql += " AND A.ZZG_PROG = '" + Substr(cCombobx6,01,06) + "'" + CHR(13)
   Endif

   Do Case
      Case Substr(cCombobx7,01,02) == "01"
           cSql += " ORDER BY A.ZZG_ORDE " + CHR(13)
      Case Substr(cCombobx7,01,02) == "02"
           cSql += " ORDER BY B.ZZD_ORDE " + CHR(13)
      Case Substr(cCombobx7,01,02) == "03"
           cSql += " ORDER BY B.ZZD_ORDE, A.ZZG_ORDE " + CHR(13)
      Case Substr(cCombobx7,01,02) == "04"
           cSql += " ORDER BY B.ZZD_ORDE, A.ZZG_ORDE DESC" + CHR(13)
      Case Substr(cCombobx7,01,02) == "05"
           cSql += " ORDER BY A.ZZG_CODI, A.ZZG_SEQU" + CHR(13)
   EndCase

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDENACAO", .T., .T. )

   // Formata os campos data para manipulação
   TCSETFIELD("T_ORDENACAO", "ZZG_DATA", "D", 8, 0)
   TCSETFIELD("T_ORDENACAO", "ZZG_PREV", "D", 8, 0)
   TCSETFIELD("T_ORDENACAO", "ZZG_APAR", "D", 8, 0)

   If T_ORDENACAO->( EOF() )
      oDlgZ:End()
      Return(.T.)
   Endif

   T_ORDENACAO->( DbGoTop() )
   
   lInicial   := .F.
   
   WHILE !T_ORDENACAO->( EOF() )

      // Carrega os dados das tarefas para recálculo das datas
      aAdd( aOrdem, {T_ORDENACAO->ZZG_CODI ,; // 01 - Código da Tarefa
                     T_ORDENACAO->ZZG_SEQU ,; // 02 - Sequencial da Tarefa
                     T_ORDENACAO->ZZG_ORDE }) // 03 - Ordenação

      T_ORDENACAO->( DbSkip() )

   ENDDO
                     
   If Len(aOrdem) == 0
      oDlgZ:End()
      Return(.T.)
   Endif
   
   // Grava a nova numeração das tarefas
   For nContar = 1 to Len(aOrdem)
       aOrdem[nContar,03] := nNumero
       nNumero := nNumero + nIntervalo
   Next nContar     

   // Grava as novas datas nas tarefas envolvidas
   For nContar = 1 to Len(aOrdem)

       // Atualiza a tabela de tarefas
       aArea := GetArea()

       DbSelectArea("ZZG")
       DbSetOrder(1)
 
       If DbSeek(xfilial("ZZG") + aOrdem[nContar,01] + aOrdem[nContar,02])
          RecLock("ZZG",.F.)
          ZZG_ORDE := aOrdem[nContar,03]
          MsUnLock()              
       Endif

   Next nContar
   
   // Fecha a janela da reorganização de numeração
   oDlgZ:End()

   // Envia para a função que atualiza a tela
   PesquisaTarefa()

Return(.T.)

// --------------------------------------- //
// Função que chama a tela de apontamentos //
// Parâmetros: 01 - Código da Tarefa       //
//             02 - Sequencial da tarefa   //
//             02 - Título da Tarefa       //
// --------------------------------------- //
Static Function ChamaAponta(c__Tarefa, c__Titulo)

   // Envia para o programa de apontamentos da tarefa
   U_ESPREG01(c__Tarefa, c__Titulo)

   If lSalvar == .F.
      Return(.T.)
   Endif

   // Envia para a função que carrega o array aBrowse
   CarBrowse(2,0)

Return(.T.)

// Função que realiza a transferência de apontamentos para as tarefas do projeto
Static Function TransfeHoras()

   Local lChumba   := .F.
   Local aDesenve  := {}
   Local dInicial  := Ctod("  /  /    ")
   Local dFinal    := Ctod("  /  /    ")
   Local cProjeto  := "000017 - PROTHEUS"
   Local cTarefap  := "000733 - DESENVOLVIMENTO/SUPORTE"

   Local cComboBx1
   Local cMemo1	   := ""
   Local oMemo1

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4

   Private oDlgT

   // Carrega combobox com os usuários
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO,"
   cSql += "       ZZE_NOME   "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   // Carrega o Combo dos Projetos
   aDesenvolve := {}
   aAdd( aDesenvolve, "Selecione o Desenvolvedor" )
   T_DESENVE->( EOF() )
   WHILE !T_DESENVE->( EOF() )
      aAdd( aDesenvolve, T_DESENVE->ZZE_CODIGO + " - " + Alltrim(T_DESENVE->ZZE_NOME) )
      T_DESENVE->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgT TITLE "Transferência de Apontamentos" FROM C(178),C(181) TO C(461),C(580) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgT

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(190),C(001) PIXEL OF oDlgT

   @ C(037),C(005) Say "Data Inicial"      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(037),C(047) Say "Data Final"        Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(059),C(005) Say "Usuários"          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(079),C(005) Say "Projetos"          Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(098),C(005) Say "Tarefa do Projeto" Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   
   @ C(046),C(005) MsGet    oGet1     Var   dInicial    Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
   @ C(046),C(047) MsGet    oGet2     Var   dFinal      Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
   @ C(067),C(005) ComboBox cComboBx1 Items aDesenvolve Size C(188),C(010)                              PIXEL OF oDlgT
   @ C(088),C(005) MsGet    oGet3     Var   cProjeto    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
   @ C(108),C(005) MsGet    oGet4     Var   cTarefap    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba

   @ C(124),C(061) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgT ACTION( EnviaHoras(dInicial, dFinal, cProjeto, cTarefap, Substr(cComboBx1,01,06) ) ) When lSalvar
   @ C(124),C(100) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// Função que realiza a transferência de apontamentos para a tarefa de horas dos projetos
Static Function EnviaHoras( _dInicial, _dFinal, _Projeto, _Tarefap, _Usuario )

   Local cTexto  := ""
   Local nContar := 0
   Local nVezes  := 0
   Local aHoras  := {}

   If Empty(_Dinicial)
      MsgAlert("Data inicial de transferência de horário não informado.")
      Return(.T.)
   Endif
      
   If Empty(_Dfinal)
      MsgAlert("Data final de transferência de horário não informado.")
      Return(.T.)
   Endif

   If _Usuario == "000000"
      MsgAlert("Desenvolvedor não selecionado.")
      Return(.T.)
   Endif

   // Captura a quantidade de horas referente a horas extras-tarefas
   If Select("T_EXTRAS") > 0
      T_EXTRAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZN_DATA , "
   cSql += "       ZZN_PROG , "
   cSql += "       ZZN_CHAV1, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZN_CHAVE)) AS DESCRICAO"
   cSql += "  FROM " + RetSqlName("ZZN")
   cSql += " WHERE ZZN_DATA    = CONVERT(DATETIME,'" + Dtoc(_dInicial) + "', 103)" + CHR(13)
   cSql += "   AND ZZN_PROG    = '" + Alltrim(_Usuario)  + "'"
   cSql += "   AND ZZN_DELE    = ''"
   cSql += "   AND D_E_L_E_T_  = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXTRAS", .T., .T. )
   
   WHILE !T_EXTRAS->( EOF() )

      cTexto := ""
      cTexto := Strtran(T_EXTRAS->DESCRICAO, chr(13), "#")
      nVezes := U_P_OCCURS(ctexto, "#", 1)

      For nContar = 1 to nVezes
          aAdd( aHoras, T_EXTRAS->ZZN_DATA, U_P_CORTA(U_P_CORTA(TRIM(cTexto), "#", nContar),"@",2) )
      Next nContar

      T_EXTRAS->( DbSkip() )

   ENDDO
      
   
   Return(.T.)
   

   // Pesquisa o código do desenvolvedor para gravação
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO"
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_LOGIN  = '" + Alltrim(UPPER(__Usuario)) + "'"
   cSql += "   AND ZZE_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   // INCLUSÃO
   If __Tipo == "I"
   
      // Pesquisa o próximo código para inclusão
      If Select("T_NUMERO") > 0
         T_NUMERO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZW_CODIGO"
      cSql += "  FROM " + RetSqlName("ZZW")
      cSql += " ORDER BY ZZW_CODIGO DESC"
            
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMERO", .T., .T. )

      If T_NUMERO->( EOF() )
         cProximo := "000001"
      Else
         cProximo := STRZERO((INT(VAL(T_NUMERO->ZZW_CODIGO)) + 1),6)
      Endif
      
      // Inclui
      dbSelectArea("ZZW")
      RecLock("ZZW",.T.)
      ZZW_FILIAL := cFilAnt
      ZZW_CODIGO := cProximo
      ZZW_PROJ   := Substr(__Projeto,01,06)
      ZZW_CLIENT := Substr(__Cliente,01,06)
      ZZW_LOJA   := Substr(__Cliente,08,03)
      ZZW_TARE   := Substr(__Tarefa,01,06)
      ZZW_DATA   := __Data
      ZZW_HORA   := __Hora
      ZZW_NOTA   := __Nota
      ZZW_USUA   := __Usuario
      ZZW_CDES   := T_DESENVE->ZZE_CODIGO
      ZZW_DELE   := ""
      MsUnLock()
      
   Endif

Return(.T.)

// Função que abre a janela das estatísticas das tarefas quando o grid está expandido
Static Function AbreEstaT()

   Local lChumba := .F.
   Local cGet1	 := cAmarelo
   Local cGet2	 := cLaranja
   Local cGet3	 := cRosa
   Local cGet4	 := cVermelho
   Local cGet5	 := cAzul
   Local cGet6	 := cCancel
   Local cGet7	 := cVerde
   Local cGet8	 := cTarefas
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oMemo1
   Local oMemo2

   Private oDlgEst

   DEFINE MSDIALOG oDlgEst TITLE "Estatísticas de Tarefas" FROM C(178),C(181) TO C(515),C(571) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgEst
   @ C(039),C(056) Jpeg FILE "br_amarelo"     Size C(009),C(009) PIXEL NOBORDER OF oDlgEst
   @ C(052),C(056) Jpeg FILE "br_laranja"     Size C(009),C(009) PIXEL NOBORDER OF oDlgEst
   @ C(065),C(056) Jpeg FILE "br_pink"        Size C(009),C(009) PIXEL NOBORDER OF oDlgEst
   @ C(078),C(056) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlgEst
   @ C(091),C(056) Jpeg FILE "br_azul"        Size C(009),C(009) PIXEL NOBORDER OF oDlgEst
   @ C(104),C(056) Jpeg FILE "br_cancel"      Size C(009),C(009) PIXEL NOBORDER OF oDlgEst
   @ C(117),C(056) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlgEst

   @ C(021),C(151) Say "E S T A T Í S T I C A S" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst

   @ C(040),C(094) Say "Aprovadas"                      Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst
   @ C(053),C(094) Say "Em Desenvolvimento"             Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst
   @ C(066),C(094) Say "Em Validação"                   Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst
   @ C(080),C(094) Say "Retorno de Validação"           Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst
   @ C(093),C(094) Say "Liberado para Produção"         Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst
   @ C(105),C(094) Say "Aguardando Estimativa de Tempo" Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst
   @ C(118),C(094) Say "Validação OK"                   Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst
   @ C(132),C(094) Say "Total de Tarefas"               Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgEst

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(189),C(001) PIXEL OF oDlgEst
   @ C(146),C(002) GET oMemo2 Var cMemo2 MEMO Size C(189),C(001) PIXEL OF oDlgEst
   
   @ C(039),C(070) MsGet oGet1 Var cGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba
   @ C(052),C(070) MsGet oGet2 Var cGet2 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba
   @ C(065),C(070) MsGet oGet3 Var cGet3 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba
   @ C(078),C(070) MsGet oGet4 Var cGet4 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba
   @ C(091),C(070) MsGet oGet5 Var cGet5 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba
   @ C(104),C(070) MsGet oGet6 Var cGet6 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba
   @ C(117),C(070) MsGet oGet7 Var cGet7 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba
   @ C(130),C(070) MsGet oGet8 Var cGet8 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEst When lChumba

   @ C(152),C(078) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgEst ACTION( oDlgEst:End() )

   ACTIVATE MSDIALOG oDlgEst CENTERED 

Return(.T.)

// Função que abre a janela que solicita a data inicial para cálculo da previsão de entrega
Static Function DataIniPrev()

   Local cSql      := ""
   Local cDataIni  := Ctod("  /  /    ")
   Local cMemo1	   := ""
   Local lUtilizar := .F.
   Local oCheckBox1
   Local oGet1
   Local oMemo1

   Private oDlgDD

   // Pesquisa a data inicial para edição
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_DPRE,"
   cSql += "       ZZ4_UTIL "
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      cDataIni  := Ctod("  /  /    ")
      lUtilizar := .F.
   Else
      cDataIni := Ctod(Substr(T_PARAMETROS->ZZ4_DPRE,7,2) + "/" + Substr(T_PARAMETROS->ZZ4_DPRE,5,2) + "/" + Substr(T_PARAMETROS->ZZ4_DPRE,1,4))
      lUtilizar := IIF(T_PARAMETROS->ZZ4_UTIL == "X", .T., .F.)
   Endif

   // Desenha a tela para solicitar a data para cálculo das datas previstas de entrega
   DEFINE MSDIALOG oDlgDD TITLE "Data inicial para cálculo das datas previstas de entrega das tarefas" FROM C(178),C(181) TO C(367),C(671) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgDD

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(238),C(001) PIXEL OF oDlgDD

   @ C(037),C(005) Say "ATENÇÃO !"                                                                                          Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgDD
   @ C(049),C(005) Say "A data abaixo será utilizada para cálculo das datas previstas de entrega das tarefas."              Size C(202),C(008) COLOR CLR_BLACK PIXEL OF oDlgDD
   @ C(058),C(005) Say "Somente será utilizada a data abaixo caso a indicação de Utiliza data para cálculo esteja marcada." Size C(237),C(008) COLOR CLR_BLACK PIXEL OF oDlgDD
   @ C(069),C(005) Say "Data inicial para cálculo das datas previstas"                                                      Size C(105),C(008) COLOR CLR_BLACK PIXEL OF oDlgDD

   @ C(080),C(005) MsGet    oGet1      Var cDataIni                                                         Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDD
   @ C(082),C(058) CheckBox oCheckBox1 Var lUtilizar Prompt "Utilizar data para cálculo de datas previstas" Size C(113),C(008)                              PIXEL OF oDlgDD

   @ C(077),C(203) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDD ACTION( SlvDatIni(cDataIni, lUtilizar) )

   ACTIVATE MSDIALOG oDlgDD CENTERED 

Return(.T.)

// Função que grava a data inicial para cálculo da data de previsão das tarefas
Static Function SlvDatIni(_cDataIni, _lUtilizar)

   If Empty(_cDataIni)
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "A data inicial para cálculo da data de previsão das tarefas não informada.")
      Return(.T.)
   Endif
   
   // Grava a data informada
   RecLock("ZZ4",.F.)
   ZZ4_DPRE := _cDataIni
   ZZ4_UTIL := IIF(_lUtilizar == .T., "X", "")
   MsUnLock()              
   
   oDlgDD:End() 

   // Envia para a função que atualiza o array aBrowse
   CarBrowse(2,0)

Return(.T.)

// ----------------------------------------------------------------------------------------------- //
// Função que realiza o cálculo das datas previstas em tempo de execusão do grid                   //
// O Objetivo desta função é carregas o array aRecalculo com os dados a serem visualizados no grid //
// ----------------------------------------------------------------------------------------------- //
Static Function RecalPrevista(_EmQueTela)

   Local nRegua       := 0
   Local cSql         := ""
   Local nContar      := 0
   Local cString      := ""
   Local cDataInicial := Ctod("  /  /    ")
   Local nRetiraData  := 0
   Local nAtrasos     := 0

   Private nHdl

   // Limpa o array aRecalculo antes do cálculo
   aRecalculo := {}
   
   // ---------------------------------------------------------------------------------- //
   // Captura a data de início do cálculo das datas previstas de entrega                 //
   // Regra: O primeiro registro do select abaixo refere-se a última tarefa encerrada.   //
   //        Considera-se tarefa encerrada as tarefas que possuem os seguintes status:   //
   //        05 - Aguardando Validação                                                   //
   //        07 - Validação OK                                                           //
   //        08 - Liberada para Produção                                                 //
   //        09 - Tarefa Encerrada                                                       //
   //        Caso o select retornar vazio, a data a ser utilizada para início do cálculo //
   //        será a data parametrizada.                                                  //
   // ---------------------------------------------------------------------------------- //

   // Pesquisa a data inicial para cálculo das datas previstas de entrega
   If Select("T_XPARAMETROS") > 0
      T_XPARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_DPRE, "
   cSql += "       ZZ4_UTIL  "
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_XPARAMETROS", .T., .T. )

   If T_XPARAMETROS->ZZ4_UTIL == "X"
      cDataInicial := T_XPARAMETROS->ZZ4_DPRE   
   Else
      If Select("T_DATAINICIAL") > 0
         T_DATAINICIAL->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZG_CODI,"
      cSql += "       ZZG_SEQU,"
      cSql += "       ZZG_ORDE "
      cSql += "  FROM " + RetSqlName("ZZG")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += "   AND ZZG_DELE   = ' '"
      cSql += "   AND ZZG_ORDE  <> 0"
      cSql += "   AND ZZG_ORIG   = '000001'"
      cSql += "   AND LTRIM(ZZG_STAT) IN ('5', '7', '8', '9')"
//    cSql += "   AND LTRIM(ZZG_STAT) IN ('5', '6', '7', '8', '9')"
      cSql += " ORDER BY ZZG_ORDE DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DATAINICIAL", .T., .T. )

      If T_DATAINICIAL->( EOF() )

         // Pesquisa a data inicial para cálculo das datas previstas de entrega
         If Select("T_XPARAMETROS") > 0
            T_XPARAMETROS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZ4_DPRE, "
         cSql += "       ZZ4_UTIL  "
         cSql += "  FROM " + RetSqlName("ZZ4")
         cSql += " WHERE D_E_L_E_T_ = ''" 

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_XPARAMETROS", .T., .T. )

         If T_XPARAMETROS->( EOF() )
            cDataInicial := Date()
            nRetiraData  := 0
         Else
            If Empty(Alltrim(T_XPARAMETROS->ZZ4_DPRE))
               cDataInicial := Date()
               nRetiraData  := 0
            Else
               cDataInicial := T_XPARAMETROS->ZZ4_DPRE
               nRetiraData  := 0
            Endif
         Endif
      Else
         // Pesquisa na tabela de histórico de Status a data inicial para cálculo da data prevista de entrega
         If Select("T_HISTORICO") > 0
            T_HISTORICO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT TOP (1) ZZH_DATA,"
         cSql += "               ZZH_HORA,"
         cSql += "               ZZH_STAT,"
         cSql += "               ZZH_DIFE " 
         cSql += "  FROM " + RetSqlName("ZZH")
         cSql += "   WHERE ZZH_DELE   = ' '"
         cSql += "   AND D_E_L_E_T_ = '' "
         cSql += "   AND LTRIM(ZZH_STAT) IN ('5')"  && Conforme análise do Gustavo, estes status não devem fazer mais parte da pesquisa da data de cálculo, '6', '7', '8', '9')" 
         cSql += " ORDER BY ZZH_DATA DESC, ZZH_HORA DESC, ZZH_STAT DESC"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HISTORICO", .T., .T. )

         If T_HISTORICO->( EOF() )
            // Pesquisa a data inicial para cálculo das datas previstas de entrega
            If Select("T_XPARAMETROS") > 0
               T_XPARAMETROS->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT ZZ4_DPRE "
            cSql += "  FROM " + RetSqlName("ZZ4")
            cSql += " WHERE D_E_L_E_T_ = ''" 

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_XPARAMETROS", .T., .T. )
    
            If T_XPARAMETROS->( EOF() )
               cDataInicial := Date()
            Else
               If Empty(Alltrim(T_XPARAMETROS->ZZ4_DPRE))
                  cDataInicial := Date()
                  nRetiraData  := 0
               Else
                  cDataInicial := T_XPARAMETROS->ZZ4_DPRE
                  nRetiraData  := 0
               Endif
            Endif
         Else
            T_HISTORICO->( DbGoTop() )
            cDataInicial := T_HISTORICO->ZZH_DATA
            nRetiraData  := IIF(T_HISTORICO->ZZH_DIFE < 0, (T_HISTORICO->ZZH_DIFE * -1), 0)
         Endif
      Endif
   Endif

   // Select que pesquisa as tarefas que serão calculadas as datas previstas de entrega
   If Select("T_AORDENAR") > 0
      T_AORDENAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       ZZG_TITU  ,"
   cSql += "       ZZG_DATA  ,"
   cSql += "	   ZZG_STAT  ,"
   cSql += "	   ZZG_APAR  ,"
   cSql += "       ZZG_ESTI  ,"
   cSql += "       ZZG_PROG  ,"
   cSql += "       CASE WHEN ZZG_ESTI  = '' THEN '01'    "
   cSql += "            WHEN ZZG_ESTI <> '' THEN ZZG_ESTI"
   cSql += "       END AS ESTIMATIVA          ,"
   cSql += "	   0 AS ATRASO_JUSTIFICADO    ,"
   cSql += "	   0 AS ATRASO_NAO_JUSTIFICADO,"
   cSql += "	   ZZG_PREV  ,"
   cSql += "	   ZZG_ORDE   "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZZG_DELE   = ' '"
   cSql += "   AND ZZG_ORDE  <> 0  "
   cSql += "   AND ZZG_ORIG   = '000001'"
// cSql += "   AND LTRIM(ZZG_STAT) IN ('2', '4', '6', '10')"
   cSql += "   AND LTRIM(ZZG_STAT) IN ('2', '4', '10')"
   cSql += " ORDER BY ZZG_ORDE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AORDENAR", .T., .T. )

   If T_AORDENAR->( EOF() )
      Return(.T.)
   Endif

   // Prepara a data inicial para cálculo
   cDataInicial := Ctod(Substr(cDataInicial,07,02) + "/" + Substr(cDataInicial,05,02) + "/" + Substr(cDataInicial,01,04))
   cDataInicial := cDataInicial - nRetiraData

   // Calcula as datas previstas de entrega
   T_AORDENAR->( DbGoTop() )

   // Inicializa a régua
   If _EmqueTela == 1
   Else
      nRegua := 0
      oMeter1:Refresh()
      oMeter1:Set(0)
      oMeter1:SetTotal(100)
   Endif   
   
   WHILE !T_AORDENAR->( EOF() )
      
      If _EmQueTela == 1
      Else
         nRegua := nRegua + 1
         oMeter1:Set(nRegua)      
      Endif   

      // Verifica se houve informação de atraso no desenvolvimento (Atraso Justificado)
      nAtrasos := 0
      nHatras  := "00:00:00"
      
      If Select("T_ATRASOS") > 0
         T_ATRASOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZT0_CODI,"
      cSql += "       ZT0_SEQU,"
      cSql += "       ZT0_DTAI,"
      cSql += "       ZT0_HRSI,"
	  cSql += "       ZT0_DTAF,"
      cSql += "       ZT0_HRSF " 
      cSql += "  FROM " + RetSqlName("ZT0")
      cSql += " WHERE ZT0_CODI = '" + Alltrim(T_AORDENAR->ZZG_CODI) + "'"
      cSql += "   AND ZT0_SEQU = '" + Alltrim(T_AORDENAR->ZZG_SEQU) + "'" 
      cSql += "   AND ZT0_ATRA = 'X'"
      cSql += "   AND ZT0_DELE = '' "         

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATRASOS", .T., .T. )

      If T_ATRASOS->( EOF() )
         nAtrasos := 0
      Else
         T_ATRASOS->( DbGoTop() )
         WHILE !T_ATRASOS->( EOF() )
            _Diferenca := ElapTime( T_ATRASOS->ZT0_HRSI, T_ATRASOS->ZT0_HRSF )
            nHatras    := SomaHoras( nHatras, _Diferenca )
            T_ATRASOS->( DbSkip() )
         ENDDO
      Endif

      // Prepara a estimativa para cálculo da data prevista de entrega
      nEstimativa := INT(VAL(T_AORDENAR->ESTIMATIVA))

      dPrimeira := cDataInicial

      // Calcula a data prevista de entrega
      For nContar = 1 to nEstimativa

          cDataInicial := cDataInicial + 1
          
          // Verifica se data é sábado
          cDataInicial := Valida_Data(1, cDataInicial, T_AORDENAR->ZZG_PROG)

          // Verifica se data é domingo
          cDataInicial := Valida_Data(2, cDataInicial, T_AORDENAR->ZZG_PROG)

          // Verifica se data é um feriado fixo
          cDataInicial := Valida_Data(3, cDataInicial, T_AORDENAR->ZZG_PROG)
       
          // Verifica se data é um feriado móvel
          cDataInicial := Valida_Data(4, cDataInicial, T_AORDENAR->ZZG_PROG)

          // Verifica se data está no intervalo de férias do usuário selecionado
          cDataInicial := Valida_Data(5, cDataInicial, T_AORDENAR->ZZG_PROG)

      Next nContar

      If TYPE("nHatras") == "C"
         nHatras := "00:00"
      Else
         nHatras := Alltrim(Str(nHatras))
      Endif   

      // ----------------------------------------------------------------------------------- //
      // Calcula o total de horas de desenvolvimento, atraso e saldo de horas da tarefa lida //
      // ----------------------------------------------------------------------------------- //

      // Pesquisa o total de horas que o desenvolvedor trabalha por dia
      If Select("T_HORASDIA") > 0
         T_HORASDIA->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZZE_CODIGO,"
      cSql += "       ZZE_NOME  ,"
      cSql += "	      ZZE_TEMPO  "
      cSql += "  FROM " + RetSqlName("ZZE")
      cSql += " WHERE ZZE_DELETE = ''"
      cSql += "   AND ZZE_CODIGO = '" + Alltrim(T_AORDENAR->ZZG_PROG) + "'"
                     
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORASDIA", .T., .T. )

      If T_HORASDIA->( EOF() )

         hPorDia  := "00:00"
         hTotaEst := "00:00"

      Else

         hPorDia  := Strzero(INT(VAL(Alltrim(T_HORASDIA->ZZE_TEMPO))),2) + ":00"

         If (Int(Val(T_AORDENAR->ESTIMATIVA)) * Int(Val(hPorDia))) < 100
            hTotaEst := Strzero(Int(Val(T_AORDENAR->ESTIMATIVA)) * Int(Val(hPorDia)),2) + ":00"
         Else
            hTotaEst := Strzero(Int(Val(T_AORDENAR->ESTIMATIVA)) * Int(Val(hPorDia)),3) + ":00"
         Endif         

      Endif
 
      // --------------------------------------------------------------------------------------- //
      // Pesquisa o total de horas de desenvolvimento e horas de atraso para a tarefa pesquisada //
      // --------------------------------------------------------------------------------------- //
      If Select("T_HORAS") > 0
         T_HORAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZT0_FILIAL,"
      cSql += "       ZT0_CODI  ,"
      cSql += "       ZT0_SEQU  ,"      
      cSql += "       ZT0_DTAI  ,"
      cSql += "       ZT0_HRSI  ,"
      cSql += "       ZT0_DTAF  ,"
      cSql += "       ZT0_HRSF  ,"
      cSql += "       ZT0_APON  ,"
      cSql += "       ZT0_DESE  ,"
      cSql += "       ZT0_ATRA   "
      cSql += "  FROM " + RetSqlName("ZT0")
      cSql += " WHERE ZT0_DELE = ''"
      cSql += "   AND ZT0_CODI = '" + Alltrim(T_AORDENAR->ZZG_CODI) + "'"
      cSql += "   AND ZT0_SEQU = '" + Alltrim(T_AORDENAR->ZZG_SEQU) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )

      nHdesen := "00:00:00"
      nHatras := "00:00:00"

      T_HORAS->( DbGoTop() )
     
      WHILE !T_HORAS->( EOF() )
         
         If EMPTY(T_HORAS->ZT0_DTAI) .AND. EMPTY(T_HORAS->ZT0_DTAF)
            T_HORAS->( DbSkip() )         
            LOOP
         ENDIF

         // Calcula a quantidade de horas de desenvolvimento
         If T_HORAS->ZT0_DESE == "X"
            _Diferenca := ElapTime( T_HORAS->ZT0_HRSI, T_HORAS->ZT0_HRSF )
            nHdesen    := SomaHoras( nHdesen, _Diferenca )
         Endif
         
         // Calcula a quantidade de horas de atraso
         If T_HORAS->ZT0_ATRA == "X"
            _Diferenca := ElapTime( T_HORAS->ZT0_HRSI, T_HORAS->ZT0_HRSF )
            nHatras    := SomaHoras( nHatras, _Diferenca )
         Endif
 
         T_HORAS->( DbSkip() )
        
      ENDDO   
         
      If ValType(nHdesen) == "C"
         nHdesen := 0.00
      Endif
                           
      If ValType(nHatras) == "C"
         nHatras := 0.00
      Endif

      // Prepara as horas para gravação
      cTdesen  := strzero(int(val(u_p_corta(str(nHdesen,05,02), '.',1))),2) + ":" + strzero(int(val(u_p_corta(str(nHdesen,05,02) + '.', '.',2))),2)
      cTatraso := strzero(int(val(u_p_corta(str(nHatras,05,02), '.',1))),2) + ":" + strzero(int(val(u_p_corta(str(nHatras,05,02) + '.', '.',2))),2)

      cHsaldo1 := SubHoras(hTotaEst + ":00", cTdesen + ":00")
      cHsaldo2 := SomaHoras(cHsaldo1, cTatraso + ":00")
      cHsaldo  := U_P_CORTA(Alltrim(STR(CHSALDO2)), ".", 1) + ":" + STRZERO(INT(VAL(U_P_CORTA(ALLTRIM(STR(CHSALDO2)) + ".", ".", 2))),2)

      // Verifica se tem horas de atraso justificada. Caso tenha, adiciona a quantidade de horas na data prevista
      If Val(Strtran(cTatraso, ":", ".")) <> 0
         If Int(val(Strtran(cTatraso, ":", "."))  / Int(Val(hPorDia))) == 0
            cDataInicial := cDataInicial + 1         
         Else   
            cDataInicial := cDataInicial + Int(val(Strtran(cTatraso, ":", "."))  / Int(Val(hPorDia)))
         Endif
      Endif

      // Carrega o array aRecalculo
      aAdd( aRecalculo, { T_AORDENAR->ZZG_CODI   ,; // 01 - Código da Tarefa
                          T_AORDENAR->ZZG_ORDE   ,; // 02 - Ordenação da Tarefa
                          T_AORDENAR->ESTIMATIVA ,; // 03 - Estimativa de Entrega
                          Dtoc(dPrimeira)        ,; // 04 - Data A Partir De
                          Dtoc(cDataInicial)     ,; // 05 - Data de Previsão de Entrega
                          hPorDia                ,; // 06 - Total Horas Trabalhada pelo programador da tarefa
                          hTotaEst               ,; // 07 - Total de Horas para desenbvolvimento da tarefa          
                          cTdesen                ,; // 08 - Total de horas de desenvolvimento da tarefa
                          cTatraso               ,; // 09 - Total de horas de atraso da tarefa
                          cHsaldo                ,; // 10 - Saldo de horas da tarefa
                          T_AORDENAR->ZZG_SEQU   }) // 11 - Sequencial da Tarefa

      T_AORDENAR->( DbSkip() )
      
   ENDDO   

   If _EmQueTela == 1
   Else
      oMeter1:Set(0)
   Endif

Return(.T.)

// Função que verifica se a data calculada é um Sábado, Domingo, Feriado Fixo, Feriado Móvel, Férias ou Outros Eventos
Static Function Valida_Data(_Tipo, _Data, _Programador)

   Local nLaco := 0

   // Verifica se Data é Sábado
   If _Tipo == 1
       If Dow(_Data) == 7
          _Data := _Data + 2
       Endif                        
   Endif
       
   // Verifica se Data é Domingo
   If _Tipo == 2
       If Dow(_Data) == 1
          _Data := _Data + 1
       Endif                        
   Endif
       
   // Verifica se data é um Feriado Fixo
   If _Tipo == 3

      If Select("T_FERIADOF") > 0
         T_FERIADOF->( dbCloseArea() )
      EndIf

      cSql := ""      
      cSql := "SELECT ZZS_DIA,"
      cSql += "       ZZS_MES " 
      cSql += "  FROM " + RetSqlName("ZZS")
      cSql += " WHERE ZZS_DELETE = ''"
      cSql += "   AND ZZS_TIPO   = 'X'"
      cSql += "   AND ZZS_DIA    = '" + Alltrim(Strzero(Day(_Data),2))   + "'"
      cSql += "   AND ZZS_MES    = '" + Alltrim(Strzero(Month(_Data),2)) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FERIADOF", .T., .T. )

      If !T_FERIADOF->( EOF() )
         _Data := _Data + 1
      Endif

   Endif
      
   // Verifica se data é um Feriado Móvel
   If _Tipo == 4

      If Select("T_FERIADOM") > 0
         T_FERIADOM->( dbCloseArea() )
      EndIf

      cSql := ""      
      cSql := "SELECT ZZS_DIA,"
      cSql += "       ZZS_MES " 
      cSql += "  FROM " + RetSqlName("ZZS")
      cSql += " WHERE ZZS_DELETE = ''"
      cSql += "   AND ZZS_TIPO   = 'M'"
      cSql += "   AND ZZS_DIA    = '" + Alltrim(Strzero(Day(_Data),2))   + "'"
      cSql += "   AND ZZS_MES    = '" + Alltrim(Strzero(Month(_Data),2)) + "'"
      cSql += "   AND ZZS_ANO    = '" + Alltrim(Strzero(Year(_Data),4))  + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FERIADOM", .T., .T. )

      If !T_FERIADOM->( EOF() )
         _Data := _Data + 1
      Endif

   Endif

   // Verifica se data é está no intervalo de férias do usuário selecionado
   If _Tipo == 5

      If Select("T_FERIAS") > 0
         T_FERIAS->( dbCloseArea() )
      EndIf

      cSql := ""      
      cSql := "SELECT ZZS_DDE ,"
      cSql += "       ZZS_DATE " 
      cSql += "  FROM " + RetSqlName("ZZS")
      cSql += " WHERE ZZS_DELETE = ''"
      cSql += "   AND ZZS_TIPO   = 'F'"
      cSql += "   AND ZZS_USUA   = '" + Alltrim(Substr(_Programador,01,06)) + "'"
      cSql += "   AND ZZS_ANO    = '" + Alltrim(Strzero(Year(_Data),4))     + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FERIAS", .T., .T. )

      If !T_FERIAS->( EOF() )

         If _Data >= Ctod(Substr(T_FERIAS->ZZS_DDE ,07,02) + "/" + Substr(T_FERIAS->ZZS_DDE ,05,02) + "/" + Substr(T_FERIAS->ZZS_DDE ,01,04)) .And. ;
            _Data <= Ctod(Substr(T_FERIAS->ZZS_DATE,07,02) + "/" + Substr(T_FERIAS->ZZS_DATE,05,02) + "/" + Substr(T_FERIAS->ZZS_DATE,01,04))

            d_Data_Ini := Ctod(Substr(T_FERIAS->ZZS_DDE ,07,02) + "/" + Substr(T_FERIAS->ZZS_DDE ,05,02) + "/" + Substr(T_FERIAS->ZZS_DDE ,01,04))
            d_data_Fim := Ctod(Substr(T_FERIAS->ZZS_DATE,07,02) + "/" + Substr(T_FERIAS->ZZS_DATE,05,02) + "/" + Substr(T_FERIAS->ZZS_DATE,01,04))

            For nLaco = 1 to (d_Data_Fim - d_Data_Ini)
                
                If _Data > d_Data_Fim
                   Exit
                Endif

                _Data := _Data + 1
                
            Next nLaco    

         Endif
         
      Endif

   Endif

Return _Data

// Função que carrega o array aBrowse para popular o grid da tela de manutenção de tarefas
Static Function CarBrowse(_EmQueTela, _Mostra)

   Local cSql := ""

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL," + CHR(13)
   cSql += "       A.ZZG_CODI  ," + CHR(13)
   cSql += "       A.ZZG_SEQU  ," + CHR(13)
   cSql += "       A.ZZG_TITU  ," + CHR(13)
   cSql += "       A.ZZG_USUA  ," + CHR(13)
   cSql += "       A.ZZG_DATA  ," + CHR(13)
   cSql += "       A.ZZG_HORA  ," + CHR(13)
   cSql += "       A.ZZG_STAT  ," + CHR(13)
   cSql += "       A.ZZG_DES1  ," + CHR(13)
   cSql += "       A.ZZG_PRIO  ," + CHR(13)
   cSql += "       A.ZZG_NOT1  ," + CHR(13)
   cSql += "       A.ZZG_PREV  ," + CHR(13)
   cSql += "       A.ZZG_TERM  ," + CHR(13)
   cSql += "       A.ZZG_PROD  ," + CHR(13)
   cSql += "       A.ZZG_SOL1  ," + CHR(13)
   cSql += "       A.ZZG_DELE  ," + CHR(13)
   cSql += "       A.ZZG_ORIG  ," + CHR(13)
   cSql += "       A.ZZG_CHAM  ," + CHR(13)
   cSql += "       A.ZZG_COMP  ," + CHR(13)
   cSql += "       A.ZZG_PROG  ," + CHR(13)
   cSql += "       A.ZZG_PROJ  ," + CHR(13)
   cSql += "       B.ZZD_NOME  ," + CHR(13)
   cSql += "       B.ZZD_ORDE  ," + CHR(13)
   cSql += "       C.ZZF_NOME  ," + CHR(13)
   cSql += "       D.ZZB_NOME  ," + CHR(13)
   cSql += "       E.ZZC_LEGE  ," + CHR(13)
   cSql += "       A.ZZG_TTAR  ," + CHR(13)
   cSql += "       A.ZZG_ESTI  ," + CHR(13)
   cSql += "       A.ZZG_XHOR  ," + CHR(13)
   cSql += "       A.ZZG_XDIA  ," + CHR(13)
   cSql += "       A.ZZG_DEBI  ," + CHR(13)
   cSql += "       A.ZZG_CRED  ," + CHR(13)
   cSql += "       A.ZZG_ORDE  ," + CHR(13)
   cSql += "       A.ZZG_APAR  ," + CHR(13)
   cSql += "       A.ZZG_THOR  ," + CHR(13)
   cSql += "       A.ZZG_TDES  ," + CHR(13)
   cSql += "       A.ZZG_TATR  ," + CHR(13)
   cSql += "       A.ZZG_TSAL   " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZG") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("ZZD") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("ZZF") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("ZZB") + " D, " + CHR(13)
   cSql += "       " + RetSqlName("ZZC") + " E  " + CHR(13)
   cSql += " WHERE A.ZZG_FILIAL = ''"
   cSql += "   AND A.ZZG_DELE   = ''" + CHR(13)
   cSql += "   AND A.ZZG_DATA  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + CHR(13)
   cSql += "   AND A.ZZG_DATA  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + CHR(13)
   cSql += "   AND A.ZZG_STAT  <> '1'" + CHR(13)

   If Alltrim(Substr(cCombobx5,01,02)) == "X"
      cSql += "   AND '0000' + A.ZZG_STAT = E.ZZC_CODIGO " + CHR(13)      
   Else   
      cSql += "   AND ('00000' + A.ZZG_STAT = E.ZZC_CODIGO OR '0000' + A.ZZG_STAT = E.ZZC_CODIGO) " + CHR(13)
   Endif   

   cSql += "   AND A.ZZG_PRIO   = B.ZZD_CODIGO " + CHR(13)
   cSql += "   AND B.ZZD_FILIAL = A.ZZG_FILIAL " + CHR(13)
   cSql += "   AND A.ZZG_ORIG   = C.ZZF_CODIGO " + CHR(13)
   cSql += "   AND C.ZZF_FILIAL = A.ZZG_FILIAL " + CHR(13)
   cSql += "   AND C.ZZF_DELETE = ''"            + CHR(13)
   cSql += "   AND A.ZZG_COMP   = D.ZZB_CODIGO " + CHR(13)
   cSql += "   AND D.ZZB_FILIAL = A.ZZG_FILIAL " + CHR(13)

   // Origem
   If Substr(cCombobx1,01,06) <> "000000"
      cSql += " AND A.ZZG_ORIG = '" + Substr(cCombobx1,01,06) + "'" + CHR(13)
   Endif
      
   // Componente
   If Substr(cCombobx2,01,06) <> "000000"
      cSql += " AND A.ZZG_COMP = '" + Substr(cCombobx2,01,06) + "'" + CHR(13)
   Endif
                             
   // Usuário
   If Alltrim(cCombobx3) <> "TODOS OS USUÁRIOS" .AND. !Empty(Alltrim(cCombobx3))
      cSql += " AND A.ZZG_USUA = '" + Alltrim(cCombobx3) + "'" + CHR(13)
   Endif

   // Prioridade
   If Substr(cCombobx4,01,06) <> "000000"
      cSql += " AND A.ZZG_PRIO = '" + Substr(cCombobx4,01,06) + "'" + CHR(13)
   Endif

   // Status
   If Alltrim(Substr(cCombobx5,01,02)) <> "T"
      If Alltrim(Substr(cCombobx5,01,02)) <> "A" .AND. ;
         Alltrim(Substr(cCombobx5,01,02)) <> "B" .AND. ;
         Alltrim(Substr(cCombobx5,01,02)) <> "C"

         Do Case
            Case Alltrim(Substr(cCombobx5,01,02)) == "X"
                 cSql += " AND A.ZZG_STAT = '10'" + CHR(13)
            Case Alltrim(Substr(cCombobx5,01,02)) == "R"
               cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','8','10')" + CHR(13)
//                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','8','10')" + CHR(13)
            Otherwise
                 cSql += " AND LTRIM(A.ZZG_STAT) = '" + Alltrim(Substr(cCombobx5,01,02)) + "'" + CHR(13)
         EndCase

      Else
         Do Case
            Case Alltrim(Substr(cCombobx5,01,02)) == "A"
               cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','8')" + CHR(13)
//                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','8')" + CHR(13)
            Case Alltrim(Substr(cCombobx5,01,02)) == "B"      
               cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','8','10')" + CHR(13)
//                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','8','10')" + CHR(13)
            Case Alltrim(Substr(cCombobx5,01,02)) == "C"                        
               cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','6','7','8','10')" + CHR(13)
//                 cSql += " AND LTRIM(A.ZZG_STAT) IN ('2','4','5','7','8','10')" + CHR(13)
         EndCase                          
      Endif            
   Endif

   // Programador
   If Substr(cCombobx6,01,06) <> "000000"
      cSql += " AND A.ZZG_PROG = '" + Substr(cCombobx6,01,06) + "'" + CHR(13)
   Endif

   Do Case
      Case Substr(cCombobx7,01,02) == "01"
           cSql += " ORDER BY A.ZZG_ORDE " + CHR(13)
      Case Substr(cCombobx7,01,02) == "02"
           cSql += " ORDER BY B.ZZD_ORDE " + CHR(13)
      Case Substr(cCombobx7,01,02) == "03"
           cSql += " ORDER BY B.ZZD_ORDE, A.ZZG_ORDE " + CHR(13)
      Case Substr(cCombobx7,01,02) == "04"
           cSql += " ORDER BY B.ZZD_ORDE, A.ZZG_ORDE DESC" + CHR(13)
      Case Substr(cCombobx7,01,02) == "05"
           cSql += " ORDER BY A.ZZG_CODI, A.ZZG_SEQU" + CHR(13)
   EndCase

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      aBrowse := {}
   Else                                                            
   
      // Envia para a rotina de calculo das datas previstas 
      RecalPrevista(_EmQueTela)

      // Carrega o array aBrowse
      aBrowse := {}

      WHILE !T_STATUS->( EOF() )

        Do Case
           Case T_STATUS->ZZG_TTAR == "C"
                __TipoTar := "Correção"
           Case T_STATUS->ZZG_TTAR == "M"
                __TipoTar := "Melhoria"
           Case T_STATUS->ZZG_TTAR == "S"
                __TipoTar := "Suporte"
           Otherwise
                __TipoTar := "A Definir"                                
        EndCase

        // Pesquisa dados da tarefa no array aRecalculo
        x_Apartirde  := ""
        x_Estimativa := ""
        x_PrevistoPa := ""
        x_TotalHoras := ""
        x_Desenvolve := ""
        x_AtrasoJust := ""
        x_SaldoHoras := ""

        For nContar = 1 to Len(aRecalculo)
            If aRecalculo[nContar,01] == T_STATUS->ZZG_CODI .And. ;
               aRecalculo[nContar,11] == T_STATUS->ZZG_SEQU
               x_Apartirde  := aRecalculo[nContar,04]
               x_Estimativa := aRecalculo[nContar,03]
               x_PrevistoPa := aRecalculo[nContar,05]
               x_TotalHoras := aRecalculo[nContar,07]
               x_Desenvolve := aRecalculo[nContar,08]
               x_AtrasoJust := aRecalculo[nContar,09]
               x_SaldoHoras := aRecalculo[nContar,10]
               Exit
            Endif
        Next nContar       

        If x_Apartirde  == "" .And. x_Estimativa == "" .And. ;
           x_PrevistoPa == "" .And. x_TotalHoras == "" .And. ;
           x_Desenvolve == "" .And. x_AtrasoJust == "" .And. ;
           x_SaldoHoras == ""

           If _Mostra == 0
              x_Apartirde  := Substr(T_STATUS->ZZG_APAR,07,02) + "/" + Substr(T_STATUS->ZZG_APAR,05,02) + "/" + Substr(T_STATUS->ZZG_APAR,01,04)
              x_Estimativa := T_STATUS->ZZG_ESTI
              x_PrevistoPa := Substr(T_STATUS->ZZG_PREV,07,02) + "/" + Substr(T_STATUS->ZZG_PREV,05,02) + "/" + Substr(T_STATUS->ZZG_PREV,01,04)
              x_TotalHoras := T_STATUS->ZZG_THOR
              x_Desenvolve := T_STATUS->ZZG_TDES
              x_AtrasoJust := T_STATUS->ZZG_TATR
              x_SaldoHoras := T_STATUS->ZZG_TSAL
           Endif   

        Endif

        // Prepara a data de abertura 
        d_Data_Abertura := Substr(T_STATUS->ZZG_DATA,07,02) + "/" + Substr(T_STATUS->ZZG_DATA,05,02) + "/" + Substr(T_STATUS->ZZG_DATA,01,04)

        // Prepara a data Encerramento
        d_Data_Encerra  := Substr(T_STATUS->ZZG_PROD,07,02) + "/" + Substr(T_STATUS->ZZG_PROD,05,02) + "/" + Substr(T_STATUS->ZZG_PROD,01,04)

        // Prepata o código da tarefa
        c_Codigo_Tarefa := Alltrim(T_STATUS->ZZG_CODI) + "." + Alltrim(T_STATUS->ZZG_SEQU)

        // Prepara a legenda para gravação em caso de visualização do tipo cor
        If nTvisual == "2"

           Do Case
              Case Alltrim(T_STATUS->ZZG_STAT) == "1"
                   _x_Legenda := "ABERTURA"
              Case Alltrim(T_STATUS->ZZG_STAT) == "2"
                   _x_Legenda := "APROVADA"
              Case Alltrim(T_STATUS->ZZG_STAT) == "3"
                   _x_Legenda := "REPORVADA"
              Case Alltrim(T_STATUS->ZZG_STAT) == "4"
                   _x_Legenda := "DESENVOLVIMENTO"
              Case Alltrim(T_STATUS->ZZG_STAT) == "5"
                   _x_Legenda := "AGUARDANDO VAL."
              Case Alltrim(T_STATUS->ZZG_STAT) == "6"
                   _x_Legenda := "INCONFORME"
              Case Alltrim(T_STATUS->ZZG_STAT) == "7"
                   _x_Legenda := "VALIDAÇÃO OK"
              Case Alltrim(T_STATUS->ZZG_STAT) == "8"
                   _x_Legenda := "LIBERADA PRO"
              Case Alltrim(T_STATUS->ZZG_STAT) == "9"
                   _x_Legenda := "TAREFA ENC."
              Case Alltrim(T_STATUS->ZZG_STAT) == "X"                                                                                                                
                   _x_Legenda := "AGUARDANDO EST."
           EndCase
        Else
           _x_Legenda := T_STATUS->ZZC_LEGE
        Endif

        // Carrega o array para display no grid da tela proncipal da manutenção de tarefas
        aAdd( aBrowse, { _x_Legenda                               ,; // 01 - Legenda da Tarefa (Status)
                         c_Codigo_Tarefa                          ,; // 02 - Código da Tarefa
                         ALLTRIM(T_STATUS->ZZD_NOME)              ,; // 03 - Nome da Prioridade da Tarefa
                         ALLTRIM(STR(T_STATUS->ZZG_ORDE,5))       ,; // 04 - Ordenação da Tarefa
                         T_STATUS->ZZG_TITU                       ,; // 05 - Título da Tarefa
                         d_Data_Abertura                          ,; // 06 - Data de Abertura da Tarefa
                         __TipoTar                                ,; // 07 - Tipo da Tarefa
                         x_Apartirde                              ,; // 08 - Data a aprtir de para cálculo da data de previsão de entrega
                         x_Estimativa                             ,; // 09 - Estimativa de desenvolvimento da tarefa
                         x_PrevistoPa                             ,; // 10 - Data prevista de entrega da tarefa
                         x_TotalHoras                             ,; // 11 - Total de horas para desenvolvimento da tarefa
                         x_Desenvolve                             ,; // 12 - Total de horas utilizadas no desenvolvimento
                         x_AtrasoJust                             ,; // 13 - Total de horas de atraso justificado
                         x_SaldoHoras                             ,; // 14 - Saldo de horas para desenvolvimento da tarefa
                         d_Data_Encerra                           ,; // 15 - Data em que a tarefa foi colocada em produção
                         Alltrim(T_STATUS->ZZF_NOME)              ,; // 16 - Origem da tarefa (Protheus, Projetos, Técnica)
                         Alltrim(T_STATUS->ZZB_NOME)              ,; // 17 - Descrição do Componente da tarefa
                         T_STATUS->ZZG_USUA                       ,; // 18 - Nome do usuário que abriu a tarefa
                         T_STATUS->ZZG_CHAM                       ,; // 19 - Nº do chamado em caso de tarefa ser da Solutio ou Totvs
                         T_STATUS->ZZG_PROJ                       ,; // 20 - Código da tarefa ref. a projetos
                         T_STATUS->ZZG_STAT                       ,; // 21 - Código do Statuis da tarefa
                         Alltrim(T_STATUS->ZZG_SEQU)              }) // 22 - Sequencial da Tarefa

                                           
        T_STATUS->( DbSkip() )

      ENDDO

   Endif

Return(.T.)

// Função que troca a forma de visualização do grid do Controle de tarefas
Static Function TrocaVisual()

   Local cSql      := ""
   Local cMensagem := ""
   
   // Verifica se existe parâmetros de filtro de pesquisa para o usuário
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZI_TVIS  "
   cSql += "  FROM " + RetSqlName("ZZI")
   cSql += " WHERE ZZI_USUA = '" + Alltrim(cUserName) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   If T_MASTER->( EOF() )
      Return(.T.)
   Endif
      
   If T_MASTER->ZZI_TVIS == "1"
      cMensagem := "Atenção!"                                                                     + chr(13) + chr(13) + ;
                   "O Sistema está configurado atualmente para você visualizar o grid de tarefas" + chr(13)           + ;
                   "no formato por Legenda."                                                      + chr(13) + chr(13) + ;
                   "Você deseja trocar deste formato para o formato por Cores?"
   Else
      cMensagem := "Atenção!"                                                                     + chr(13) + chr(13) + ;
                   "O Sistema está configurado atualmente para você visualizar o grid de tarefas" + chr(13)           + ;
                   "no formato por Cores."                                                        + chr(13) + chr(13) + ;
                   "Você deseja trocar deste formato para o formato por Legenda?"
   Endif
                      
   If MsgYesNo(cMensagem)

      DbSelectArea("ZZI")
      DbSetOrder(1)
      If DbSeek(Alltrim(cUserName))
         RecLock("ZZI",.F.)
         ZZI_TVIS := IIF(T_MASTER->ZZI_TVIS == "1", "2", "1")
         MsUnLock()              
      Endif

      oDlgP:eND()
   
      U_ESPTAR01()

   Endif
   
Return(.T.)   