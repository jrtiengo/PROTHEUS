#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI20.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/11/2012                                                          *
// Objetivo..: Programa que pesquisa Atividades por Áreas (TreeView)               *
//**********************************************************************************

User Function ATVATI20()

   Private aArea    := {}
   Private aAdm     := {}

   Private cComboBx1
   Private cComboBx2

   Private cMes	    := Month(Date())
   Private cAno 	:= Year(Date())

   Private oGet1
   Private oGet2

   Private oDlg

   // Carrega o combo de Áreas para seleção
   If Select("T_AREAS") > 0
      T_AREAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZR_CODIGO , "
   cSql += "       A.ZZR_NOME     "
   cSql += "  FROM " + RetSqlName("ZZR") + " A  "
   cSql += " WHERE A.ZZR_DELETE = ''"
   cSql += " ORDER BY A.ZZR_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREAS", .T., .T. )

   If T_AREAS->( EOF () )
      MsgAlert("Cadastro de Áreas está vazio. Verifique !!!!")
      Return .T.
   Endif
   
   T_AREAS->( DbGoTop() )
   WHILE !T_AREAS->( EOF() )
      aAdd(aArea, T_AREAS->ZZR_CODIGO + " - " + Alltrim(T_AREAS->ZZR_NOME) )   
      T_AREAS->( DbSkip() )
   ENDDO

   If Len(aArea) == 0
      aAdd( aArea, '' )
   Endif   

   // Carrega o combo de Usuários
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA "
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_DELETE = ''"
   cSql += "   AND ZZT_ADM    = 'T'"
   cSql += " ORDER BY ZZT_USUA "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   If T_USUARIOS->( EOF() )
      MsgAlert("Não existem Usuários parametrizados para esta Área.")
      Return .T.
   Endif
   
   T_USUARIOS->( DbGoTop() )
   WHILE !T_USUARIOS->( EOF() )
      aAdd(aAdm, T_USUARIOS->ZZT_USUA )
      T_USUARIOS->( DbSkip() )
   ENDDO

   If Len(aAdm) == 0
      aAdd( aAdm, '' )
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Pesquisa Atividades por Áreas" FROM C(178),C(181) TO C(330),C(501) PIXEL

   @ C(005),C(005) Say "Área"                  Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Administrador da Área" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Mês"                   Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(026) Say "Ano"                   Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) ComboBox cComboBx1 Items aArea Size C(150),C(010) PIXEL OF oDlg
   @ C(036),C(005) ComboBox cComboBx2 Items aAdm  Size C(150),C(010) PIXEL OF oDlg
   @ C(060),C(005) MsGet    oGet1     Var   cMes  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(060),C(026) MsGet    oGet2     Var   cAno  Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(057),C(078) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( _TreeAtiv(cComboBx1, cComboBx2, cMes, cAno) )
   @ C(057),C(116) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre o TreeView das Atividades
Static Function _TreeAtiv(__Area, __Usuario, __Mes, __Ano)

   Private oDlgX

   DEFINE MSDIALOG oDlgX TITLE "Pesquisa Atividades por Áreas" FROM C(178),C(181) TO C(611),C(763) PIXEL

   // Cria a Tree
   oTree := DbTree():New(3,2,250,365,oDlgX,,,.T.)

   // Cria a Linha da Área
   cArea := "Área: " + Alltrim(Substr(__Area,10)) + "    Pesquisa: " + Strzero(__Mes,2) + "/" + Strzero(__Ano,4)
   oTree:AddItem(cArea + Space(110 - Len(Alltrim(cArea))),"001", "FOLDER5" ,,,,1)

   // Cria a Linha do Usuário Administrador
   oTree:AddItem("Adm: " + Alltrim(__Usuario) + Space(110 - Len(Alltrim(__Usuario))),"002", "FOLDER6",,,,2)	

   // Pesquisa o supervisor da área
   If Select("T_SUPERVISOR") > 0
      T_SUPERVISOR->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZT_USUA "
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_RESP   = '" + Alltrim(__Usuario)            + "'"
   cSql += "   AND ZZT_AREA   = '" + Alltrim(Substr(__Area,01,06)) + "'"
   cSql += "   AND ZZT_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SUPERVISOR", .T., .T. )

   // Cria a Linha do Usuário Supervisor
   oTree:AddItem("Supervisor: " + Alltrim(T_SUPERVISOR->ZZT_USUA) + Space(110 - Len(Alltrim(T_SUPERVISOR->ZZT_USUA))),"003", "FOLDER6",,,,2)	

   // Pesquisa os Usuários da Área/Supervisor
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZT_USUA,"
   cSql += "       ZZT_NOMS "
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_RESP   = '" + Alltrim(T_SUPERVISOR->ZZT_USUA) + "'"
   cSql += "   AND ZZT_AREA   = '" + Alltrim(Substr(__Area,01,06))   + "'"
   cSql += "   AND ZZT_NORM   = 'T'"
   cSql += "   AND ZZT_DELETE = '' 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   // Cria as linhas dos Usuários do Supervisor da Área
   nContar := 4
   T_USUARIOS->( DbGoTop() )
   WHILE !T_USUARIOS->( EOF() )

      // Cria a Linha do Usuário
      oTree:AddItem("Usuário: " + Alltrim(T_USUARIOS->ZZT_NOMS),"003", "FOLDER11",,,,2)	

      // Pesquisa as Atividades para o mês/Ano do usuário selecionado
      If Select("T_ATIVIDADES") > 0
         T_ATIVIDADES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZX_ATIV,"
      cSql += "       A.ZZX_DAT1,"
      cSql += "       B.ZZU_NOME "
      cSql += "  FROM " + RetSqlName("ZZX") + " A, "
      cSql += "       " + RetSqlName("ZZU") + " B  "
      cSql += "  WHERE A.ZZX_USUA   = '" + Alltrim(T_USUARIOS->ZZT_USUA) + "'"
      cSql += "    AND A.ZZX_DELETE = '' "
      cSql += "    AND A.ZZX_MES    = " + Alltrim(Str(__Mes)) 
      cSql += "    AND A.ZZX_ANO    = " + Alltrim(Str(__Ano)) 
      cSql += "    AND A.ZZX_ATIV   = B.ZZU_CODIGO"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADES", .T., .T. )

      WHILE !T_ATIVIDADES->( EOF() )
         __Data := Substr(T_ATIVIDADES->ZZX_DAT1,07,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT1,05,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT1,01,04)

         Do Case
            Case Dow(Ctod(__Data)) == 1
                 cSemana := "Domingo"
            Case Dow(Ctod(__Data)) == 2
                 cSemana := "Segunda"
            Case Dow(Ctod(__Data)) == 3
                 cSemana := "Terça"
            Case Dow(Ctod(__Data)) == 4
                 cSemana := "Quarta"
            Case Dow(Ctod(__Data)) == 5
                 cSemana := "Quinta"
            Case Dow(Ctod(__Data)) == 6
                 cSemana := "Sexta"
            Case Dow(Ctod(__Data)) == 7
                 cSemana := "Sábado"
         EndCase        

//         oTree:AddItem(space(30) + T_ATIVIDADES->ZZX_DAT1 + " - " + Alltrim(T_ATIVIDADES->ZZU_NOME), "" ,,,,nContar)	
         oTree:AddItem(". . . . . ." + __Data + "  (" + cSemana + ") - " + Alltrim(T_ATIVIDADES->ZZU_NOME), "" ,,,,nContar)	

         T_ATIVIDADES->( DbSkip() )
      ENDDO

      T_USUARIOS->( DbSkip() )
      
   ENDDO



   oTree:TreeSeek("001") // Retorna ao primeiro nível




   @ C(200),C(247) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)