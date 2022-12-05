#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPAPO01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/02/2014                                                          *
// Objetivo..: Programa que consulta os apontamento de horas e observações das ta- *
//             refas do Projetos.                                                  * 
//**********************************************************************************

User Function ESPAPO01()
                                                          
   Local lChumba        := .F.  
   Local lColabora      := .F.  

   Private aColaborador := {}
   Private aProjetos    := {}
   Private aTarefas     := {}
   Private aBrowse      := {}
   Private cHoras       := ""

   Private oTarefas
   Private oBrowse
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private dInicial   := Ctod("01/" + Strzero(month(date()),2) + "/" + Strzero(year(date()),4))
   Private dFinal	  := Ctod("  /  /    ")
   Private cMemo1	  := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo1

   Private oDlg

   // Calcula a data final para pesquisa
   Do Case
      Case Month(Date()) == 1
           dFinal := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 2
           If Mod(Year(Date()),4) == 0
              dFinal := Ctod("29/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
           Else
              dFinal := Ctod("28/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
           Endif   
      Case Month(Date()) == 3
           dFinal := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 4
           dFinal := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 5
           dFinal := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 6
           dFinal := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 7
           dFinal := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 8
           dFinal := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 9
           dFinal := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 10
           dFinal := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 11
           dFinal := Ctod("30/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
      Case Month(Date()) == 12
           dFinal := Ctod("31/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
   EndCase

   // Verifica se o combo do colaborador pode ficar aberto ou não
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZE_LOGIN, "
   cSql += "       ZZE_ADMIN  "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += "   AND ZZE_LOGIN  = '" + Upper(Alltrim(CUSERNAME)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )
   
   If T_DESENVE->( EOF() )
      lColabora := .F.
   Else
      If T_DESENVE->ZZE_ADMIN <> "T"
         lColabora := .F.
      Else
         lColabora := .T.
      Endif
   Endif

   // Carrega o ComboBox dos Colaboradores
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += "   AND ZZE_TIPOP  = 'T'"

   If lColabora == .F.
      cSql += "   AND ZZE_LOGIN = '" + Upper(Alltrim(CUSERNAME)) + "'"
   Endif   

   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   If T_DESENVE->( EOF() )
      aColaborador := {}
   Else
      If lColabora
         aAdd( aColaborador, "000000 - Todos os Colaboradores")
      Endif   
      WHILE !T_DESENVE->( EOF() )
         aAdd( aColaborador, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )
         T_DESENVE->( DbSkip() )
      ENDDO
   Endif

   // Carrega o ComboBox dos Projetos
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZY_CODIGO, "
   cSql += "       A.ZZY_CLIENT, "
   cSql += "       A.ZZY_LOJA  , "
   cSql += "       A.ZZY_CHAVE , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.ZZY_TITULO  "
   cSql += "  FROM " + RetSqlName("ZZY") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.ZZY_DELETE = ''"
   cSql += "   AND A.ZZY_CLIENT = B.A1_COD  "
   cSql += "   AND A.ZZY_LOJA   = B.A1_LOJA "
   cSql += " ORDER BY A.ZZY_CHAVE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   If T_PROJETO->( EOF() )
      aProjetos := {}
   Else
      aAdd( aProjetos, "000000 - Todos os Projetos" )
      WHILE !T_PROJETO->( EOF() )
         aAdd( aProjetos, T_PROJETO->ZZY_CODIGO + " - " + T_PROJETO->ZZY_CHAVE )
         T_PROJETO->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlg TITLE "Consulta Apontamentos de Horas por Projetos/Tarefas" FROM C(178),C(181) TO C(626),C(967) PIXEL

   @ C(005),C(005) Say "De"                Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(047) Say "Para"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(090) Say "Colaborador"       Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(193) Say "Projeto"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Tarefa do Projeto" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(123) Say "Registro de apontamentos de horas para a tarefa selecionada"                                      Size C(148),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(148),C(122) Say "Detalhe do apontamento selecionado (Duplo click sobre o apontamento para visualizar observações)" Size C(239),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet1     Var   dInicial                    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(047) MsGet    oGet2     Var   dFinal                      Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(147),C(348) MsGet    oGet3     Var   cHoras       When lChumba   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(090) ComboBox cComboBx1 Items aColaborador When lColabora Size C(098),C(010) PIXEL OF oDlg
   @ C(014),C(193) ComboBox cComboBx2 Items aProjetos                   Size C(133),C(010) PIXEL OF oDlg
   @ C(012),C(329) Button "Pesquisar"                                   Size C(056),C(012) PIXEL OF oDlg ACTION( CargaTarefa() )
   @ C(159),C(121) GET      oMemo1    Var cMemo1 MEMO                   Size C(262),C(048) PIXEL OF oDlg

   @ C(208),C(348) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( OdLG:eND() )

   // Cria Grid para mostrar as notas fiscais que foram lidas
   aAdd( aTarefas, { "", "" } )

   @ 045,005 LISTBOX oTarefas FIELDS HEADER "Código", "Descrição" PIXEL SIZE 145,215 OF oDlg ;
                     ON dblClick(aTarefas[oTarefas:nAt,1] := !aTarefas[oTarefas:nAt,1],oTarefas:Refresh())     

   oTarefas:SetArray( aTarefas )
   oTarefas:bLine := {|| {aTarefas[oTarefas:nAt,01],;
        		          aTarefas[oTarefas:nAt,02]}}

   oTarefas:bLDblClick := {|| MOSTRATRF(aTarefas[oTarefas:nAt,01], 1) } 

   // Cria Browse com os apontamento das horas
   aAdd( aBrowse, {"","","","","",""} )

   oBrowse := TCBrowse():New( 045 , 155, 335, 140,,{'Colaborador ', 'Projeto', 'Tarefa', 'Data', 'Horas'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05]} }

   oBrowse:bLDblClick := {|| MOSTRADET( aBrowse[oBrowse:nAt,06] ) } 

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega as Tarefas para display
Static Function CargaTarefa()

   Local cSql    := ""
   Local lExiste := .F.
   Local nContar := 0

   aTarefas := {}
                                                                              
   oTarefas:SetArray( aTarefas )
   oTarefas:bLine := {|| {aTarefas[oTarefas:nAt,01],;
        		          aTarefas[oTarefas:nAt,02]}}

   If Substr(cComboBx1,01,06) == "000000" .And. Substr(cComboBx2,01,06) == "000000"

      aAdd( aTarefas, { "", "" } ) 
   
      oTarefas:SetArray( aTarefas )
      oTarefas:bLine := {|| {aTarefas[oTarefas:nAt,01],;
           		             aTarefas[oTarefas:nAt,02]}}
   
      MOSTRATRF(aTarefas[01,01], 2)
      
      Return(.T.)
      
   Endif   

   // Carrega o combo das tarefas do projeto
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZW_CODIGO," + CHR(13)
   cSql += "       A.ZZW_PROJ  ," + CHR(13)
   cSql += "       D.ZZY_CHAVE ," + CHR(13)
   cSql += "       A.ZZW_TARE  ," + CHR(13)
   cSql += "       B.ZZG_CODI  ," + CHR(13)
   cSql += "       B.ZZG_SEQU  ," + CHR(13)
   cSql += "       B.ZZG_TITU  ," + CHR(13)
   cSql += "       A.ZZW_CDES  ," + CHR(13)
   cSql += "       C.ZZE_NOME  ," + CHR(13)
   cSql += "       SUBSTRING(A.ZZW_DATA,07,02) + '/' + SUBSTRING(A.ZZW_DATA,05,02) + '/' + SUBSTRING(A.ZZW_DATA,01,04) AS DATA," + CHR(13)
   cSql += "       A.ZZW_HORA   " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZW") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("ZZG") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("ZZE") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("ZZY") + " D  " + CHR(13)
   cSql += " WHERE A.ZZW_DELE   = ' '" + CHR(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"  + CHR(13)

   // Filtra pelo Projeto
   If Substr(cComboBx2,01,06) <> "000000"
      cSql += "   AND A.ZZW_PROJ = '" + Substr(cComboBx2,01,06) + "'" + CHR(13)
   Endif   

   // Filtra pelo Colaborador
   If Substr(cComboBx1,01,06) <> "000000"
      cSql += "   AND A.ZZW_CDES = '" + Substr(cComboBx1,01,06) + "'" + CHR(13)
   Endif

   // Filtra pela Data Inicial e Final informada
   cSql += "   AND A.ZZW_DATA >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103) AND A.ZZW_DATA <= CONVERT(DATETIME,'" + Dtoc(dFinal) + "', 103)" + CHR(13)
   cSql += "   AND A.ZZW_TARE   = B.ZZG_CODI  " + CHR(13)
   cSql += "   AND A.ZZW_SEQU   = B.ZZG_SEQU  " + CHR(13)
   cSql += "   AND B.ZZG_DELE   = ' '         " + CHR(13)
   cSql += "   AND B.ZZG_STAT  <> '1'         " + CHR(13)
   cSql += "   AND A.ZZW_CDES   = C.ZZE_CODIGO" + CHR(13)
   cSql += "   AND C.ZZE_DELETE = ' '         " + CHR(13)
   cSql += "   AND A.ZZW_PROJ   = D.ZZY_CODIGO" + CHR(13)
   cSql += "   AND D.ZZY_DELETE = ' '         " + CHR(13)
   cSql += " ORDER BY B.ZZG_CODI, B.ZZG_SEQU  " + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   // Carrega o List com as Tarefas
   If Substr(cCombobx1,01,06) <> "000000" .And. Substr(cCombobx2,01,06) == "000000"
      aAdd( aTarefas, { "000000", "TODAS AS TAREFAS" } )
   Endif

   T_PROJETO->( DbGoTop() )
   WHILE !T_PROJETO->( EOF() )

      // Verifica se a tarefa já está contida no Array
      lExiste := .F.
      For nContar = 1 to Len(aTarefas)
          If aTarefas[nContar,01] == Alltrim(T_PROJETO->ZZG_CODI) + "." + Alltrim(T_PROJETO->ZZG_SEQU)
             lExiste := .T.
             Exit
          Endif
      Next nContar
          
      If lExiste   
      Else
         aAdd( aTarefas, { Alltrim(T_PROJETO->ZZG_CODI) + "." + Alltrim(T_PROJETO->ZZG_SEQU), Alltrim(T_PROJETO->ZZG_TITU) } )
      Endif
             
      T_PROJETO->( DbSkip() )

   ENDDO

   oTarefas:SetArray( aTarefas )
   oTarefas:bLine := {|| {aTarefas[oTarefas:nAt,01],;
        		          aTarefas[oTarefas:nAt,02]}}

   If Len(aTarefas) <> 0
      MOSTRATRF(aTarefas[01,01],1)
   Endif   

Return(.T.)

// Função que carrega o grid com os apontamento da tarefa selecionada
Static Function MOSTRATRF(_Tarefa, _Tipo)

   Local cSql   := ""
   Local xHoras := 0
   Local cSoma  := 0

   // Carrega as horas apontadas para a tarefa selecionada
   If Select("T_HORAS") > 0
      T_HORAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZW_CODIGO,"
   cSql += "       A.ZZW_PROJ  ,"
   cSql += "       D.ZZY_CHAVE ,"
   cSql += "       A.ZZW_TARE  ,"
   cSql += "       A.ZZW_SEQU  ,"
   cSql += "       B.ZZG_CODI  ,"
   cSql += "       B.ZZG_SEQU  ,"
   cSql += "       B.ZZG_TITU  ,"
   cSql += "       A.ZZW_CDES  ,"
   cSql += "       C.ZZE_NOME  ,"
   cSql += "       SUBSTRING(A.ZZW_DATA,07,02) + '/' + SUBSTRING(A.ZZW_DATA,05,02) + '/' + SUBSTRING(A.ZZW_DATA,01,04) AS DATA,"
   cSql += "       A.ZZW_HORA  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZW_NOTA)) AS MOTIVO"
   cSql += "  FROM " + RetSqlName("ZZW") + " A , "
   cSql += "       " + RetSqlName("ZZG") + " B , " 
   cSql += "       " + RetSqlName("ZZE") + " C , "
   cSql += "       " + RetSqlName("ZZY") + " D   "
   cSql += " WHERE A.ZZW_DELE = ' ' "

   If _Tipo == 1

      // Filtra o Projeto
      If Substr(cComboBx2,01,06) <> "000000"
         cSql += "   AND A.ZZW_PROJ = '" + Substr(cComboBx2,01,06) + "'"
      Endif

      // Filtra o Colaborador
      If Substr(cComboBx1,01,06) <> "000000"
         cSql += "   AND A.ZZW_CDES = '" + Substr(cComboBx1,01,06) + "'"
      Endif   

      If Alltrim(_Tarefa) <> "000000"
         cSql += "   AND A.ZZW_TARE = '" + Substr(_Tarefa,01,06) + "'"
         cSql += "   AND A.ZZW_SEQU = '" + Substr(_Tarefa,08,02) + "'"
      Endif

   Endif   

   cSql += "   AND A.ZZW_DATA >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103) AND A.ZZW_DATA <= CONVERT(DATETIME,'" + Dtoc(dFinal) + "', 103)" + chr(13)
   cSql += "   AND A.ZZW_TARE = B.ZZG_CODI  "
   cSql += "   AND A.ZZW_SEQU = B.ZZG_SEQU  "
   cSql += "   AND B.ZZG_DELE = ' '         "
   cSql += "   AND B.ZZG_STAT <> '1'        "
   cSql += "   AND A.ZZW_CDES = C.ZZE_CODIGO" 
   cSql += "   AND C.ZZE_DELETE = ' '       "
   cSql += "   AND A.ZZW_PROJ = D.ZZY_CODIGO" 
   cSql += "   AND D.ZZY_DELETE = ' '       "
   cSql += " ORDER BY A.ZZW_DATA DESC       "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )

   aBrowse := {}

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05]} }

   xHoras  := 0
   cSoma   := 0
   
   If T_HORAS->( EOF() )
      aAdd( aBrowse, { '','','','','',''} )
   Else
      T_HORAS->( DbGoTop() )
      WHILE !T_HORAS->( EOF() )

         aAdd( aBrowse, { Alltrim(T_HORAS->ZZE_NOME) ,;
                          Alltrim(T_HORAS->ZZY_CHAVE),;
                          Alltrim(T_HORAS->ZZG_TITU) ,;
                          T_HORAS->DATA              ,;
                          T_HORAS->ZZW_HORA          ,;
                          T_HORAS->MOTIVO            })

         // Soma as horas para display
         cSoma := cSoma + VAL(T_HORAS->ZZW_HORA)
            
         T_HORAS->( DbSkip() )

      ENDDO

   Endif

   cHoras := Str(cSoma,10,2)
   oGet3:Refresh()

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05]} }
  
   oBrowse:Refresh()

Return(.T.)

// Função que mostra o detalhe do apontamento
Static Function MOSTRADET(_Observa)

   cMemo1 := _Observa
   oMemo1:Refresh()

Return(.T.)