#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Tarefas                       *
// Parâmetros: _xTipo = I - Inclusão de Tarefa                                     *
//                      A - Alteração de Tarefa                                    *
//                      E - Exclusão de Tarefa                                     *
//             _xCodigo   - Código da Tarefa                                       *
//             _xParametros - Parâmetros de pesquisa do select para ordenação      *
//**********************************************************************************

User Function ESPTAR02( _xTipo, _xCodigo, _xParametros )

   Local lChumba      := .F.
   Local lFechado     := .F.
   Local lEditar      := .F.
   
   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea  := {}
   Local _aAlias := {}

   // Variaveis Locais da Funcao
   Private Status_Fecha  := 0
   Private ___Manutencao := _xTipo
   Private lAbertos      := .F.
   Private lOrdenacao    := .F.
   Private lDiasPrevi    := .F.
   Private lEditaCampos  := .F.
   Private lHoras        := .F.
   Private lDias         := .F.
   Private aComboBx1	 := {} // Usuários
   Private aComboBx2	 := {} // Status
   Private aComboBx3	 := {} // Prioridade
   Private aComboBx4	 := {} // Responsável
   Private aComboBx5	 := {} // Componente
   Private aComboBx6	 := {} // Programador
   Private aComboBx7	 := {" "   , "C - Correção", "M - Melhoria", "S - Suporte"}      // Tipo de Tarefa
   Private lSalvar       := .F.
   Private lIndicador    := .F.

   // ------------------------------------------------------------------------------------------------------------ //
   // Estimativa                                                                                                   //
   // ------------------------------------------------------------------------------------------------------------ // 
   // Foi retirado do array as opções "H - Horas", "D - Dias", conforme reunião com Gustavo. Poderá voltar um dia. //
   // ------------------------------------------------------------------------------------------------------------ //   
   Private aComboBx8	 := {"       ", "01 Dia" , "02 Dias", "03 Dias", "04 Dias", "05 Dias", "06 Dias", "07 Dias",;
                             "08 Dias", "09 Dias", "10 Dias", "11 Dias", "12 Dias", "13 Dias", "14 Dias", "15 Dias",;
                             "16 Dias", "17 Dias", "18 Dias", "19 Dias", "20 Dias", "21 Dias", "22 Dias", "23 Dias",; 
                             "24 Dias", "25 Dias", "26 Dias", "27 Dias", "28 Dias", "29 Dias", "30 Dias", "31 Dias"}

   Private cUsuario
   Private cStatus
   Private cPrioridade
   Private cOrigem     
   Private cComponente 
   Private cProgramador 
   Private cTipoTarefa
   Private cEstimativa
   Private oIndicador

   Private x_Origem      := U_P_CORTA(_xParametros, "|", 1)
   Private x_Componente  := U_P_CORTA(_xParametros, "|", 2)
   Private x_Usuario     := U_P_CORTA(_xParametros, "|", 3)
   Private x_Prioridade  := U_P_CORTA(_xParametros, "|", 4)
   Private x_Status      := U_P_CORTA(_xParametros, "|", 5)
   Private x_Programador := U_P_CORTA(_xParametros, "|", 6)
   Private x_Ordenacao   := U_P_CORTA(_xParametros, "|", 7)
   Private x_Data01      := Ctod(U_P_CORTA(_xParametros, "|", 8))
   Private x_Data02      := Ctod(U_P_CORTA(_xParametros, "|", 9))

   Private cxHoras      := Space(03)
   Private cxDias       := Space(03)
   Private cDebito      := 0
   Private cCredito     := 0
   Private cCodigo	    := Space(06)
   Private cTitulo	    := Space(60)
   Private nOrdenacao   := 0
   Private dData01      := Ctod("  /  /    ")
   Private cApartirde   := Ctod("  /  /    ")
   Private cHora        := Space(10)
   Private dPrevisto    := Ctod("  /  /    ")
   Private dTermino     := Ctod("  /  /    ")
   Private dProducao    := Ctod("  /  /    ")
   Private cChamado     := Space(50)
   Private cChaveTex    := Space(06)
   Private cChaveNot    := Space(06)
   Private cChaveSol    := Space(06)
   Private cTexto	    := ""
   Private cNota	    := ""
   Private cSolucao     := ""
   Private cFontes      := ""
   Private cThoras      := ""
   Private cTdesen      := ""
   Private cTatraso     := ""
   Private cTSaldo      := ""

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
   Private oGet12  
   Private oGet14  
   Private oGet15  
   Private oGet16  

   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4
   Private nContar := 0

   Private lMarketing := .F.
   Private oMarketing

   Private nOrdenacao  := 0
   Private hEstimativa := Space(02)
   Private hPorDia     := Space(05)
   Private hTotaEst    := ""
   Private cTdesen     := ""
   Private cTatraso    := ""
   Private cHsaldo     := ""

   Private oGet50
   Private oGet51
   Private oGet52
   Private oGet53
   Private oGet54
   Private oGet55
   Private oGet56

   // Variaveis Private da Funcao
   Private oDlgMANU
   
   // Variaveis que definem a Acao do Formulario
   Private VISUAL := .F.                        
   Private INCLUI := .F.                        
   Private ALTERA := .F.                        
   Private DELETA := .F.                        

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

   // Carrega o combo de usuarios
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      MsgAlert("Cadastro de Usuários está vazio.")
      Return .T.
   Endif

   // Carrega o Combo dos Usuários do Sistema
   aComboBx1 := {}
   aAdd( aComboBx1, "          " )
   T_USUARIO->( EOF() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aComboBx1, T_USUARIO->ZZA_NOME )
      T_USUARIO->( DbSkip() )
   ENDDO
 
   // Posiciona o usuário logado
   For nContar = 1 to Len(aComboBX1)
       If Alltrim(aComboBx1[nContar]) == Alltrim(cUserName)
          cUsuario = cUserName
          Exit
       Endif
   Next nContar       

   If _xTipo == "I"
      dData01    := Date()
      cHora      := Time()
      cApartirde := Date()
   Endif

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

   aComboBx4 := {}

   If !T_ORIGEM->( EOF() )
      aAdd( aComboBx4, "              " )  
      WHILE !T_ORIGEM->( EOF() )
         aAdd( aComboBx4, T_ORIGEM->ZZF_CODIGO + " - " + T_ORIGEM->ZZF_NOME )
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

   aComboBx5 := {}

   If !T_COMPO->( EOF() )
      aAdd( aComboBx5, "              " )
      WHILE !T_COMPO->( EOF() )
         aAdd( aComboBx5, T_COMPO->ZZB_CODIGO + " - " + T_COMPO->ZZB_NOME )
         T_COMPO->( DbSkip() )
      ENDDO
   Endif

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
      aAdd( aComboBx6, "              " )
      WHILE !T_DESENVE->( EOF() )
         aAdd( aComboBx6, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )
         T_DESENVE->( DbSkip() )
      ENDDO
   Endif

   // Status das Tarefas
   //
   // 01 - Abertura de Tarefa - Aguardando Aprovação
   // 02 - Tarefa Aprovada
   // 03 - Tarefa Não Aprovada
   // 04 - Em Desenvolvimento
   // 05 - Em Validação
   // 06 - Validação Aprovada
   // 07 - Validação Reprovada
   // 08 - Encerrada (Em Produção)

   If _xTipo == "I"
      aComboBx2 := {}
      aAdd( aComboBx2, "2 - Aprovada" )
   Else
   
      // Carrega o Combo de Status
      If Select("T_STATUS") > 0
         T_STATUS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZC_CODIGO, "
      cSql += "       ZZC_NOME    "
      cSql += "  FROM " + RetSqlName("ZZC")
      cSql += " WHERE ZZC_DELETE = ''"
      cSql += " ORDER BY ZZC_NOME "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

      aComboBx2 := {}

      If !T_STATUS->( EOF() )
         WHILE !T_STATUS->( EOF() )
            aAdd( aComboBx2, STR(INT(VAL(T_STATUS->ZZC_CODIGO)),1) + " - " + T_STATUS->ZZC_NOME )
            T_STATUS->( DbSkip() )
         ENDDO
      Endif

   Endif

   // Carrega o Combo de Prioidades
   If Select("T_PRIORI") > 0
      T_PRIORI->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZD_CODIGO, "
   cSql += "       ZZD_NOME    "
   cSql += "  FROM " + RetSqlName("ZZD")
   cSql += " WHERE ZZD_DELETE = ''"
   cSql += " ORDER BY ZZD_CODIGO  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORI", .T., .T. )

   aComboBx3 := {}

   If !T_PRIORI->( EOF() )
      aAdd( aComboBx3, "" )
      WHILE !T_PRIORI->( EOF() )
         aAdd( aComboBx3, T_PRIORI->ZZD_CODIGO + " - " + T_PRIORI->ZZD_NOME )
         T_PRIORI->( DbSkip() )
      ENDDO
   Endif

   // Em caso de alteração, captura os dados para manipulação
   If _xTipo == "A" .OR. _xTipo == "E"
   
      If Select("T_TAREFA") > 0
         T_TAREFA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZG_FILIAL,"
      cSql += "       ZZG_CODI  ,"
      cSql += "       ZZG_SEQU  ,"
      cSql += "       ZZG_TITU  ,"
      cSql += "       ZZG_USUA  ,"
      cSql += "       ZZG_DATA  ,"
      cSql += "       ZZG_HORA  ,"
      cSql += "       ZZG_STAT  ,"
      cSql += "       ZZG_DES2  ,"
      cSql += "       ZZG_PRIO  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO, "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_NOT1)) AS NOTAS    , "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS SOLICITAS, "
      cSql += "       ZZG_NOT2  ,"
      cSql += "       ZZG_PREV  ,"
      cSql += "       ZZG_TERM  ,"
      cSql += "       ZZG_PROD  ,"
      cSql += "       ZZG_SOL2  ,"
      cSql += "       ZZG_DELE  ,"
      cSql += "       ZZG_ORIG  ,"
      cSql += "       ZZG_COMP  ,"
      cSql += "       ZZG_PROG  ,"
      cSql += "       ZZG_CHAM  ,"
      cSql += "       ZZG_MARK  ,"
      cSql += "       ZZG_TTAR  ,"
      cSql += "       ZZG_ESTI  ,"
      cSql += "       ZZG_XHOR  ,"
      cSql += "       ZZG_XDIA  ,"
      cSql += "       ZZG_DEBI  ,"
      cSql += "       ZZG_CRED  ,"
      cSql += "       ZZG_ORDE  ,"
      cSql += "       ZZG_APAR  ,"
      cSql += "       ZZG_THOR  ,"
      cSql += "       ZZG_TDES  ,"
      cSql += "       ZZG_TATR  ,"
      cSql += "       ZZG_TSAL  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_FONT)) AS FONTES,"
      cSql += "       ZZG_CTINEF "
      cSql += "  FROM " + RetSqlName("ZZG")
      cSql += " WHERE ZZG_DELE  = ''"
      cSql += "   AND ZZG_CODI  = '" + Substr(_xCodigo,01,06) + "'"
      cSql += "   AND ZZG_SEQU  = '" + Substr(_xCodigo,08,02) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )

      If T_TAREFA->( EOF() )
         MsgAlert("Não existem dados a serem visualizados para a tarefa selecioada.")
         ODlgMANU:End()
         Return .T.
      Endif

      cCodigo     := Alltrim(T_TAREFA->ZZG_CODI) + "." + Alltrim(T_TAREFA->ZZG_SEQU)
      cTitulo     := T_TAREFA->ZZG_TITU
      dData01     := Substr(T_TAREFA->ZZG_DATA,07,02) + "/" + Substr(T_TAREFA->ZZG_DATA,05,02) + "/" + Substr(T_TAREFA->ZZG_DATA,01,04)
      cHora       := T_TAREFA->ZZG_HORA
      dPrevisto   := Ctod(Substr(T_TAREFA->ZZG_PREV,07,02) + "/" + Substr(T_TAREFA->ZZG_PREV,05,02) + "/" + Substr(T_TAREFA->ZZG_PREV,01,04))
      dTermino    := Ctod(Substr(T_TAREFA->ZZG_TERM,07,02) + "/" + Substr(T_TAREFA->ZZG_TERM,05,02) + "/" + Substr(T_TAREFA->ZZG_TERM,01,04))
      dProducao   := Ctod(Substr(T_TAREFA->ZZG_PROD,07,02) + "/" + Substr(T_TAREFA->ZZG_PROD,05,02) + "/" + Substr(T_TAREFA->ZZG_PROD,01,04))
      cChamado    := T_TAREFA->ZZG_CHAM
      cChaveTex   := T_TAREFA->ZZG_DES2
      cChaveNot   := T_TAREFA->ZZG_NOT2
      cChaveSol   := T_TAREFA->ZZG_SOL2
      cxHoras     := T_TAREFA->ZZG_XHOR
      cxDias      := T_TAREFA->ZZG_XDIA
      cDebito     := T_TAREFA->ZZG_DEBI
      cCredito    := T_TAREFA->ZZG_CRED
      cFontes     := T_TAREFA->FONTES
      nOrdenacao  := T_TAREFA->ZZG_ORDE
      cApartirDe  := Ctod(Substr(T_TAREFA->ZZG_APAR,07,02) + "/" + Substr(T_TAREFA->ZZG_APAR,05,02) + "/" + Substr(T_TAREFA->ZZG_APAR,01,04))
      cTipoTarefa := T_TAREFA->ZZG_TTAR
//    cThoras     := T_TAREFA->ZZG_THOR
//    cTdesen     := T_TAREFA->ZZG_TDES
//    cTatraso    := T_TAREFA->ZZG_TATR
//    cTSaldo     := T_TAREFA->ZZG_TSAL
      hEstimativa := T_TAREFA->ZZG_ESTI
      lIndicador  := IIF(T_TAREFA->ZZG_CTINEF == "X", .T., .F.)

      If INT(VAL(T_TAREFA->ZZG_STAT)) = 7
         lFechado := .F.
      Else
         lFechado := .T.
      Endif      

      Status_Fecha := INT(VAL(T_TAREFA->ZZG_STAT))

      If Status_Fecha == 0
         cStatus := "2"
      Endif         

      If T_TAREFA->ZZG_MARK == "X"
         lmarketing := .T.
      Else
         lmarketing := .F.         
      Endif   

      // Se não existe ordenação, pesquisa a próxima para a prioridade
      If nOrdenacao <> 0
      Else
         If Select("T_INTERVALO") > 0
            T_INTERVALO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZZJ_ORDE,"
         cSql += "       ZZJ_INTE "
         cSql += "  FROM " + RetSqlName("ZZJ")
         cSql += " WHERE D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_INTERVALO", .T., .T. )
         
         If T_INTERVALO->( EOF() )
            MsgAlert("Atenção! Parametrização de intervalo de ordenação não configurada. Verifique parametrizador.")
            Return(.T.)
         Endif

         If Select("T_PROXIMO") > 0
            T_PROXIMO->( dbCloseArea() )
         EndIf
 
         cSql := "SELECT ZZG_ORDE "
         cSql += "  FROM " + RetSqlName("ZZG")
         cSql += " WHERE D_E_L_E_T_ = ''"
         cSql += "   AND ZZG_PRIO   = '" + Alltrim(T_TAREFA->ZZG_PRIO) + "'"
         cSql += " ORDER BY ZZG_ORDE DESC "
                     
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

         If T_PROXIMO->( EOF() )
            nOrdenacao := T_INTERVALO->ZZJ_INTE
         Else
            nOrdenacao := T_PROXIMO->ZZG_ORDE + T_INTERVALO->ZZJ_INTE
         Endif   
         
      Endif   

      // Localiza o Usuario para display
      For nContar = 1 to Len(aComboBx1)
          If Upper(Alltrim(aComboBx1[nContar])) == Upper(Alltrim(T_TAREFA->ZZG_USUA)) 
             cUsuario := T_TAREFA->ZZG_USUA
             Exit
          Endif
      Next nContar       
             
      // Localiza o Status para display
      For nContar = 1 to Len(aComboBx2)
          If Status_Fecha == 0
             If Upper(Alltrim(Substr(aComboBx2[nContar],01,01))) == Upper(Alltrim(cStatus)) 
                cStatus := aComboBx2[nContar]
                Exit
             Endif
          Else
             If Upper(Alltrim(Substr(aComboBx2[nContar],01,01))) == Upper(Alltrim(T_TAREFA->ZZG_STAT)) 
                cStatus := aComboBx2[nContar]
                Exit
             Endif
          Endif             
      Next nContar       

      // Localiza a Prioridade para display
      For nContar = 1 to Len(aComboBx3)
          If Upper(Alltrim(Substr(aComboBx3[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_PRIO)) 
             cPrioridade := aComboBx3[nContar]
             Exit
          Endif
      Next nContar       

      // Localiza a Origem para display
      For nContar = 1 to Len(aComboBx4)
          If Upper(Alltrim(Substr(aComboBx4[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_ORIG)) 
             cOrigem := aComboBx4[nContar]
             Exit
          Endif
      Next nContar       

      // Localiza o Componente para display
      For nContar = 1 to Len(aComboBx5)
          If Upper(Alltrim(Substr(aComboBx5[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_COMP)) 
             cComponente := aComboBx5[nContar]
             Exit
          Endif
      Next nContar       

      // Localiza o Programador para display
      For nContar = 1 to Len(aComboBx6)
          If Upper(Alltrim(Substr(aComboBx6[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_PROG)) 
             cProgramador := aComboBx6[nContar]
             Exit
          Endif
      Next nContar       

      // Localiza o Tipo de Tarefa
      For nContar = 1 to Len(aComboBx7)
          If Substr(aComboBx7[nContar],01,01) == Upper(Alltrim(T_TAREFA->ZZG_TTAR)) 
             cTipoTarefa := aComboBx7[nContar]
             Exit
          Endif
      Next nContar       

      // Localiza a Estimativa
      For nContar = 1 to Len(aComboBx8)
          If Substr(aComboBx8[nContar],01,01) == "H" .Or. Substr(aComboBx8[nContar],01,01) == "D"
             If Substr(aComboBx8[nContar],01,01) == Upper(Alltrim(T_TAREFA->ZZG_ESTI)) 
                cEstimativa := aComboBx8[nContar]
                Exit
             Endif
          Else
             If Substr(aComboBx8[nContar],01,02) == Upper(Alltrim(T_TAREFA->ZZG_ESTI)) 
                cEstimativa := aComboBx8[nContar]
                Exit
             Endif
          Endif             
      Next nContar       

      // Carrega o campo cTexto
      If !Empty(Alltrim(T_TAREFA->DESCRICAO))
         cTexto := T_TAREFA->DESCRICAO
      Endif

      // Carrega o campo cNota
      If !Empty(Alltrim(T_TAREFA->NOTAS))
         cNota := T_TAREFA->NOTAS
      Endif

      // Carrega o campo cSolucao
      If !Empty(Alltrim(T_TAREFA->SOLICITAS))
         cSolucao := T_TAREFA->SOLICITAS
      Endif

      // Controle de abertura e fechamento dos botões de ordenação e dias para c[alculo da data prevista de entrega da tarefa
      lAbertos   := .F.

      // Controle de abertura e fechamento dos botões de ordenação e dias para c[alculo da data prevista de entrega da tarefa
      If _xTipo == "A"  
         lAbertos     := .T.
         lEditaCmapos := .F.
      Endif

   Else

      hEstimativa  := Space(02)
      cEstimativa  := aComboBx8[1]
      cPrioridade  := aComboBx3[1]
      lFechado     := .T.
      lAbertos     := .F.
      lEditaCampos := .F.
  
   Endif      

   // Envia para a rotina que calcula o total das horas da tarefa pesquisada
   If _xTipo == "I"
      lEditar := .T.
   Else

      CalTotHoras(Alltrim(T_TAREFA->ZZG_CODI) + "." + Alltrim(T_TAREFA->ZZG_SEQU), T_TAREFA->ZZG_PROG)
    
      // Retirado conforme solicitação do Gustavo
      //   // Se Status da tarefa for igual a 10, envia para a janela que solicita a estimativa da tarefa
      //   If _xTipo <> "I"
      //      If Alltrim(T_TAREFA->ZZG_STAT) == "10"
      //         INF_ESTIMA()
      //         Return(.T.)
      //      Endif
      //   Endif   

      // Prepara a variável de editar campo Sim/Não
      If Alltrim(T_TAREFA->ZZG_STAT)$("2#4#10")
         lEditar := .T.
      Else
         lEditar := .F.      
      Endif

   Endif

   // Desenha a tela para manutenção da tarefa pesquisada
   DEFINE MSDIALOG oDlgManu TITLE "Cadastro de Tarefas" FROM C(178),C(181) TO C(625),C(958) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"                  Size C(150),C(026)                 PIXEL NOBORDER OF oDlgManu

   @ C(030),C(005) Say "Tarefa"                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(030),C(036) Say "Título"                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(030),C(161) Say "Usuário"                               Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(030),C(220) Say "Data"                                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(030),C(256) Say "Hora"                                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(030),C(292) Say "Status"                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(030),C(344) Say "Tipo de Tarefa"                        Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(050),C(005) Say "Descrição da Tarefa"                   Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(164),C(005) Say "Prioridade"                            Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(164),C(080) Say "Responsável"                           Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(164),C(151) Say "Nº Chamado"                            Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(164),C(186) Say "Componente"                            Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(164),C(281) Say "Desenvolvedor"                         Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
// @ C(155),C(005) Say "Solução Adotada"                       Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
// @ C(155),C(281) Say "Fontes Envolvidos"                     Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
// @ C(189),C(005) Say "Outras Observações (Gerais)"           Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(185),C(007) Say "Ordenação"                             Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(185),C(043) Say "Estimativa"                            Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(185),C(086) Say "Hrs p/Dia"                             Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(185),C(132) Say "Tot.Horas"                             Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(185),C(179) Say "Tot.Desenv."                           Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(185),C(225) Say "Tot.Atrasos"                           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(185),C(271) Say "Saldo Horas"                           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(194),C(071) Say "Dias"                                  Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(194),C(119) Say "Hrs"                                   Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(194),C(165) Say "Hrs"                                   Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(194),C(212) Say "Hrs"                                   Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(194),C(258) Say "Hrs"                                   Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
   @ C(194),C(304) Say "Hrs"                                   Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgManu
	     
   If Status_Fecha == 0 .And. _xTipo <> "I"

      @ C(039),C(005) MsGet    oGet1        Var   cCodigo       Size C(028),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      @ C(039),C(036) MsGet    oGet2        Var   cTitulo       Size C(121),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      
      @ C(039),C(161) ComboBox cUsuario     Items aComboBx1     Size C(056),C(010)                                    PIXEL OF oDlgManu When IIF(Upper(Alltrim(cUserName)) == "ADMINISTRADOR", .T., .F.)

      @ C(039),C(220) MsGet    oGet3        Var   dData01       Size C(032),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      @ C(039),C(256) MsGet    oGet4        Var   cHora         Size C(032),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      @ C(039),C(292) ComboBox cStatus      Items aComboBx2     Size C(049),C(010)                                    PIXEL OF oDlgManu When lChumba
      @ C(015),C(335) CheckBox oIndicador   Var   lIndicador    Prompt "Indicador Meritotech" Size C(050),C(008)      PIXEL OF oDlgManu When lChumba
      @ C(039),C(344) ComboBox cTipoTarefa  Items aComboBx7     Size C(041),C(010)                                    PIXEL OF oDlgManu
      @ C(058),C(005) GET      oMemo1       Var   cTexto MEMO   Size C(379),C(104)                                    PIXEL OF oDlgManu When lChumba
      @ C(172),C(005) ComboBox cPrioridade  Items aComboBx3     Size C(072),C(010)                                    PIXEL OF oDlgManu When lChumba
      @ C(172),C(080) ComboBox cOrigem      Items aComboBx4     Size C(069),C(010)                                    PIXEL OF oDlgManu When lChumba
      @ C(172),C(151) MsGet    oGet5        Var   cChamado      Size C(031),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      @ C(172),C(186) ComboBox cComponente  Items aComboBx5     Size C(093),C(010)                                    PIXEL OF oDlgManu When lChumba
      @ C(172),C(281) ComboBox cProgramador Items aComboBx6     Size C(104),C(010)                                    PIXEL OF oDlgManu When lChumba
//    @ C(164),C(005) GET      oMemo2       Var   cSolucao MEMO Size C(273),C(024)                                    PIXEL OF oDlgManu When lChumba
//    @ C(164),C(281) GET      oMemo3       Var   cFontes  MEMO Size C(103),C(041)                                    PIXEL OF oDlgManu When lChumba
//    @ C(197),C(005) GET      oMemo4       Var   cNota    MEMO Size C(273),C(023)                                    PIXEL OF oDlgManu When lChumba
      @ C(192),C(007) MsGet    oGet50       Var   nOrdenacao    Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999"      PIXEL OF oDlgManu && When lEditar
      @ C(192),C(043) MsGet    oGet51       Var   hEstimativa   Size C(024),C(009) COLOR CLR_BLACK Picture "@! XX"         PIXEL OF oDlgManu VALID(CalHrEst()) When lEditar
      @ C(192),C(086) MsGet    oGet52       Var   hPorDia       Size C(029),C(009) COLOR CLR_BLACK Picture "@! XX:XX"      PIXEL OF oDlgManu When lChumba
      @ C(192),C(132) MsGet    oGet53       Var   hTotaEst      Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(179) MsGet    oGet54       Var   cTdesen       Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(225) MsGet    oGet55       Var   cTatraso      Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(271) MsGet    oGet56       Var   cHsaldo       Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(354) Button "Especificação" Size C(030),C(012) PIXEL OF oDlgManu When lChumba

   Else

      @ C(039),C(005) MsGet    oGet1        Var   cCodigo       Size C(028),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      @ C(039),C(036) MsGet    oGet2        Var   cTitulo       Size C(121),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lEditar

      @ C(039),C(161) ComboBox cUsuario     Items aComboBx1     Size C(056),C(010)                                    PIXEL OF oDlgManu When When IIF(Upper(Alltrim(cUserName)) == "ADMINISTRADOR", .T., .F.) && lEditar

      @ C(039),C(220) MsGet    oGet3        Var   dData01       Size C(032),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      @ C(039),C(256) MsGet    oGet4        Var   cHora         Size C(032),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lChumba
      @ C(039),C(292) ComboBox cStatus      Items aComboBx2     Size C(049),C(010)                                    PIXEL OF oDlgManu When lChumba
      @ C(015),C(335) CheckBox oIndicador   Var   lIndicador    Prompt "Indicador Meritotech" Size C(050),C(008)      PIXEL OF oDlgManu
      @ C(039),C(344) ComboBox cTipoTarefa  Items aComboBx7     Size C(041),C(010)                                    PIXEL OF oDlgManu && When lEditar
      @ C(058),C(005) GET      oMemo1       Var   cTexto MEMO   Size C(379),C(104)                                    PIXEL OF oDlgManu When lEditar
      @ C(172),C(005) ComboBox cPrioridade  Items aComboBx3     Size C(072),C(010)                                    PIXEL OF oDlgManu When lEditar
      @ C(172),C(080) ComboBox cOrigem      Items aComboBx4     Size C(069),C(010)                                    PIXEL OF oDlgManu When lEditar
      @ C(172),C(151) MsGet    oGet5        Var   cChamado      Size C(031),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgManu When lEditar
      @ C(172),C(186) ComboBox cComponente  Items aComboBx5     Size C(093),C(010)                                    PIXEL OF oDlgManu When lEditar
      @ C(172),C(281) ComboBox cProgramador Items aComboBx6     Size C(104),C(010)                                    PIXEL OF oDlgManu When lEditar
//    @ C(164),C(005) GET      oMemo2       Var   cSolucao MEMO Size C(273),C(024)                                    PIXEL OF oDlgManu When lEditar
//    @ C(164),C(281) GET      oMemo3       Var   cFontes  MEMO Size C(103),C(041)                                    PIXEL OF oDlgManu When lEditar
//    @ C(197),C(005) GET      oMemo4       Var   cNota    MEMO Size C(273),C(023)                                    PIXEL OF oDlgManu When lEditar
      @ C(192),C(007) MsGet    oGet50       Var   nOrdenacao    Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999"      PIXEL OF oDlgManu && When lEditar
      @ C(192),C(043) MsGet    oGet51       Var   hEstimativa   Size C(024),C(009) COLOR CLR_BLACK Picture "@! XX"         PIXEL OF oDlgManu VALID(CalHrEst()) When lEditar
      @ C(192),C(086) MsGet    oGet52       Var   hPorDia       Size C(029),C(009) COLOR CLR_BLACK Picture "@! XX:XX"      PIXEL OF oDlgManu When lChumba
      @ C(192),C(132) MsGet    oGet53       Var   hTotaEst      Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(179) MsGet    oGet54       Var   cTdesen       Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(225) MsGet    oGet55       Var   cTatraso      Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(271) MsGet    oGet56       Var   cHsaldo       Size C(029),C(009) COLOR CLR_BLACK Picture "@! XXXXXXXXXX" PIXEL OF oDlgManu When lChumba
      @ C(192),C(354) Button "Especificação"       Size C(030),C(012) PIXEL OF oDlgManu ACTION( U_ESPTAR20(Substr(cCodigo,01,06), Substr(cCodigo,08,02), cTitulo) )      

   Endif   

   If lEditar 
      If _xTipo == "I"
         @ C(208),C(281) Button "Salvar"       Size C(030),C(012) PIXEL OF oDlgManu ACTION( SalvaTarefa(_xTipo, cCodigo, "2") ) When lSalvar
      Else
         @ C(208),C(281) Button "Salvar"       Size C(030),C(012) PIXEL OF oDlgManu ACTION( SalvaTarefa(_xTipo, cCodigo, Alltrim(T_TAREFA->ZZG_STAT)) ) When lSalvar
      Endif            
   Else
      @ C(208),C(281) Button "Salvar"       Size C(030),C(012) PIXEL OF oDlgManu ACTION( SalvaTarefa(_xTipo, cCodigo, Alltrim(T_TAREFA->ZZG_STAT)) ) && When lChumba
   Endif

   @ C(208),C(312) Button "Apontamentos" Size C(042),C(012) PIXEL OF oDlgManu ACTION( ChamaRegApon(cCodigo, cTitulo, cProgramador) )
   @ C(208),C(354) Button "Voltar"       Size C(030),C(012) PIXEL OF oDlgManu ACTION( oDlgManu:End() )

   ACTIVATE MSDIALOG oDlgManu CENTERED 

Return(.T.)

// Função que calcula o total de horas da tarefa
Static Function CalHrEst()

   If Int(Val(hEstimativa)) == 0
      Return(.T.)
   Endif

   hEstimativa := Strzero(int(val(hEstimativa)),2)
   oGet51:Refresh()

   If (Int(Val(hEstimativa)) * Int(Val(hPorDia))) < 100
      hTotaEst := Strzero(Int(Val(hEstimativa)) * Int(Val(hPorDia)),2) + ":00"
   Else
      hTotaEst := Strzero(Int(Val(hEstimativa)) * Int(Val(hPorDia)),3) + ":00"
   Endif         

   oGet53:Refresh()

   // Envia para a função que calcula o saldo de horas da tarefa passada no parâmetro
   CalTotHoras(cCodigo, Substr(cProgramador,01,06))

Return(.T.)

// Função que chama o programa que realiza os apontamentos da tarefa
Static Function ChamaRegApon(__Codigo, __Titulo, __Programador)

   // Chama programa dos apontamentos da tarefa selecionada
   U_ESPREG01(__Codigo, __Titulo)
   
   // Envia para a função que calcula o saldo de horas da tarefa passada no parâmetro
   CalTotHoras(__Codigo, Substr(__Programador,01,06))

Return(.T.)

// Função que abre os botões Ordenação e Datas
Static Function AbreBotoes(_TipoBotao)

   If _TipoBotao == 1

      If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Ao ser alterado os parâmetros de Ordenação ou Datas, o Sistema irá realizar uma reorganização das Datas Previstas de Entrega." + chr(13) + chr(10) + "Deseja realmente alterar estes parâmetros?")
         lEditaCampos := .T.
      Else
         lEditaCampos := .F.
      Endif   
   Endif


return(.T.)



   // Abre o botão Ordenação e fecha o botão Datas
   If _TipoBotao == 2
      If lOrdenacao
         lOrdenacao  := .F.
         lDiasPrevi  := .T.
         lEditaOrdem := .T.
         lEditaDatas := .F.
      Else
         lOrdenacao  := .T.
         lDiasPrevi  := .F.
         lEditaOrdem := .F.
         lEditaDatas := .F.
      Endif   
   Endif         

   // Fecha o botão Ordenação e abre o botão Datas
   If _TipoBotao == 3
      If lDiasPrevi
         lOrdenacao  := .T.
         lDiasPrevi  := .F.
         lEditaOrdem := .F.
         lEditaDatas := .T.
      Else
         lOrdenacao  := .F.
         lDiasPrevi  := .T.
         lEditaOrdem := .F.
         lEditaDatas := .F.
      Endif   
   Endif

Return(.T.)
   
// Função que pesquisa a ordenação conforme a periodiciada informada
// A regra é: busca a última ordenação e soma 10 para dar um intervalo entre as numerações
Static Function BotOrdem()

   Local cSql := ""   
   
   If Empty(Alltrim(Substr(cPrioridade,01,03)))
      Return(.T.)
   Endif

   // Pesquisa a Ordenação e o intervalo para a prioridade informada
   If Select("T_PRIORIDADE") > 0
      T_PRIORIDADE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_ORDE,"
   cSql += "       ZZJ_INTE "
   cSql += "  FROM " + RetSqlName("ZZJ")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORIDADE", .T., .T. )

   // Pesquisa na tabela de tarefas a última prioridade para elaboração da ordeenação da tarefa que está sendo manipulada
   If Select("T_ORDENACAO") > 0
      T_ORDENACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_PRIO,"
   cSql += "       ZZG_PREV,"
   cSql += "       ZZG_ORDE "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE = ''"
   cSql += "   AND ZZG_PRIO = '" + Alltrim(Substr(cPrioridade,01,06)) + "'"
   cSql += "   AND ZZG_PREV = '" + Alltrim(dPrevisto)                 + "'"
   cSql += " ORDER BY ZZG_PREV, ZZG_ORDE DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDENACAO", .T., .T. )

   T_ORDENACAO->( DbGoTop() )

   // Se não encontrou nenhum registro, pesquisa a ordenação total da tabela de tarefas
   If T_ORDENACAO->( EOF() )
      If Select("T_ORDENACAO") > 0
         T_ORDENACAO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZG_CODI,"
      cSql += "       ZZG_PRIO,"
      cSql += "       ZZG_PREV,"
      cSql += "       ZZG_ORDE "
      cSql += "  FROM " + RetSqlName("ZZG")
      cSql += " WHERE ZZG_DELE = ''"
      cSql += " ORDER BY ZZG_PREV, ZZG_ORDE DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDENACAO", .T., .T. )

      T_ORDENACAO->( DbGoTop() )

      IF T_ORDENACAO->( EOF() )
         nOrdenacao := T_PRIORIDADE->ZZJ_ORDE         
      Else
         nOrdenacao := T_ORDENACAO->ZZG_ORDE + T_PRIORIDADE->ZZJ_INTE
      Endif                  
   Else
      nOrdenacao := T_ORDENACAO->ZZG_ORDE + T_PRIORIDADE->ZZJ_INTE      
   Endif   

   oGet11:Refresh()
   
Return(.T.)      

// Função que Calcula a data prevista de entrega a partir da informação do Combo Estimativa
Static Function xCalPrev(xAbre)

   Local __Adicionar

   // Se estimativa não informada, não calcula
   If ValType(cEstimativa) == "U"
      Return(.T.)
   Endif
   
   // Se estimativa = branco, não calcula
   If Substr(cEstimativa,01,01) == " "
      dPrevisto := Ctod("  /  /    ")

      If ___Manutencao == "I"
         nOrdenacao := 0
         oGet11:Refresh()
      Endif   

      Return(.T.)
   Endif                                        

   // Calculo quando estimativa por nº de dias fixos (não informado)
   __Adicionar := int(val(Substr(cEstimativa,01,02)))
   dPrevisto   := cApartirDe
   
   For nContar = 1 to __Adicionar

       dPrevisto := dPrevisto + 1

       // Verifica se data é sábado
       dPrevisto := Dataextras(1, dPrevisto)

       // Verifica se data é domingo
       dPrevisto := Dataextras(2, dPrevisto)

       // Verifica se data é um feriado fixo
       dPrevisto := Dataextras(3, dPrevisto)
       
       // Verifica se data é um feriado móvel
       dPrevisto := Dataextras(4, dPrevisto)

       // Verifica se data está no intervalo de férias do usuário selecionado
       dPrevisto := Dataextras(5, dPrevisto)

   Next nContar    

   // Calcula o total de horas para a estimativa indicada
   cThoras := Strzero((__Adicionar * 4),2) + ":00:00"
// cTSaldo := cThoras - cTdesen - cTatraso
   cTSaldo := Str(SubHoras(SubHoras(cThoras, cTdesen + ":00"), cTatraso + ":00"),06,02)

   oGet8:Refresh() 
   oGet14:Refresh() 
   oGet15:Refresh() 
   oGet16:Refresh()       

   // Captura a Ordenação para a tarefa que está sendo incluída
   If ___Manutencao == "I"
      BotOrdem()
   Endif

Return(.T.)

// Função que verifica se a data calculada é um Sábado, Domingo, Feriado Fixo, Feriado Móvel, Férias ou Outros Eventos
Static Function Dataextras(_Tipo, _Data)

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
      cSql += "   AND ZZS_USUA   = '" + Alltrim(Substr(cProgramador,01,06)) + "'"
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

// Altera Valor da Variável lLibera e lChumba
Static Function SalvaTarefa( _Operacao, _cCodigo, __Status )

   Local cSql        := ""
   Local cCodigo     := IIF(_Operacao == "I", "", _cCodigo)
   Local cSequencia  := ""
   Local _LiberaEsti := .F.
   Local cEmail      := ""
   
   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(cUsuario))
         MsgAlert("Usuário não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cTitulo))
         MsgAlert("Título da Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cTexto))
         MsgAlert("Descritivo da Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cPrioridade))
         MsgAlert("Prioridade da Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cOrigem))
         MsgAlert("Origem da Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cComponente))
         MsgAlert("Componente da Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cProgramador))
         MsgAlert("Desenvolvedor da Tarefa não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cTipoTarefa))
         MsgAlert("Tipo de Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(hEstimativa))
         MsgAlert("Estimativa de entrega não informada. Verique !!")
         Return .T.
      Endif   

      If nOrdenacao == 0
         MsgAlert("Ordenação da tarefa não informada. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o Próximo número para inclusão
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZG_CODI, "
      cSql += "       ZZG_SEQU  "
      cSql += "  FROM " + RetSqlName("ZZG")
      cSql += " WHERE ZZG_DELE = ''"
      cSql += " ORDER BY ZZG_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

      If T_NOVO->( EOF() )
         cCodigo    := "000001"
         cSequencia := "00"
      Else
         cCodigo    := Strzero((INT(VAL(T_NOVO->ZZG_CODI)) + 1),6)      
         cSequencia := "00"
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZG")
      RecLock("ZZG",.T.)
      ZZG_CODI   := cCodigo
      ZZG_SEQU   := cSequencia
      ZZG_TITU   := cTitulo
      ZZG_USUA   := cUsuario
      ZZG_DATA   := dData01
      ZZG_HORA   := cHora
      ZZG_STAT   := Substr(cStatus,01,01)
      ZZG_PRIO   := Substr(cPrioridade,01,06)
      ZZG_PREV   := dPrevisto
      ZZG_TERM   := dTermino
      ZZG_PROD   := dProducao
      ZZG_ORIG   := Substr(cOrigem,01,06)
      ZZG_CHAM   := cChamado
      ZZG_COMP   := Substr(cComponente,01,06)
      ZZG_PROG   := Substr(cProgramador,01,06)
      ZZG_MARK   := IIF(lMarketing == .T., "X", "")
      ZZG_DES1   := cTexto
      ZZG_NOT1   := cNota
      ZZG_SOL1   := cSolucao
      ZZG_TTAR   := Substr(cTipoTarefa,01,01)
      ZZG_ESTI   := hEstimativa
      ZZG_FONT   := cFontes
      ZZG_ORDE   := nOrdenacao
      ZZG_CTINEF := IIF(lIndicador == .T., "X", "")
      MsUnLock()

      aArea := GetArea()

      dbSelectArea("ZZH")
      RecLock("ZZH",.T.)
      ZZH_CODI := Strzero(int(val(cCodigo))   ,6)
      ZZH_SEQU := Strzero(int(val(cSequencia)),2)
      ZZH_DATA := dData01
      ZZH_HORA := cHora
      ZZH_STAT := Substr(cStatus,01,01)
      ZZH_DELE := " "
      MsUnLock()

      MsgAlert("Tarefa gravada com o codigo: " + Alltrim(cCodigo))

   Endif

   // Operação de Alteração
   If _Operacao == "A"

      If Empty(Alltrim(cTipoTarefa))
         MsgAlert("Tipo de Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(hEstimativa))
         MsgAlert("Estimativa de entrega não informada. Verique !!")
         Return .T.
      Endif   

      If nOrdenacao == 0
         MsgAlert("Ordenação da tarefa não informada. Verique !!")
         Return .T.
      Endif   

      // Verifica se o status da tarefa alterada é = 10 - Aguardando Estimativa.
      // Se for, troca o status para 02 - Aprovada
      If __Status == "10"
         _LiberaEsti := .T.
      Else
         _LiberaEsti := .F.
      Endif

      aArea := GetArea()

      DbSelectArea("ZZG")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZG") + Substr(cCodigo,01,06) + Substr(cCodigo,08,02))
         RecLock("ZZG",.F.)
         ZZG_TITU := cTitulo
         ZZG_USUA := cUsuario
         ZZG_DATA := Ctod(dData01)
         ZZG_HORA := cHora

         // Troca o Status da tarefa quando esta for de estimativa
         If _LiberaEsti == .T.
            ZZG_STAT := "2"
         Endif
  
         ZZG_PRIO   := Substr(cPrioridade,01,06)
         ZZG_PREV   := dPrevisto
         ZZG_TERM   := dTermino
         ZZG_PROD   := dProducao
         ZZG_ORIG   := Substr(cOrigem,01,06)
         ZZG_CHAM   := cChamado
         ZZG_COMP   := Substr(cComponente,01,06)
         ZZG_PROG   := Substr(cProgramador,01,06)
         ZZG_MARK   := IIF(lMarketing == .T., "X", "")
         ZZG_DES1   := cTexto
         ZZG_NOT1   := cNota
         ZZG_SOL1   := cSolucao
         ZZG_TTAR   := Substr(cTipoTarefa,01,01)
         ZZG_ESTI   := hEstimativa
         ZZG_XHOR   := cxHoras
         ZZG_XDIA   := cxDias
         ZZG_DEBI   := cDebito
         ZZG_CRED   := cCredito
         ZZG_FONT   := cFontes
         ZZG_ORDE   := nOrdenacao
         ZZG_CTINEF := IIF(lIndicador == .T., "X", "")
         MsUnLock()              

         // Se alteração for referente a informação da estimativa da tarefa, envia e-mail para o responsável pela informação da
         // reordenação das taferas.
         If _LiberaEsti == .T.

            If Select("T_REORDENA") > 0
               T_REORDENA->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT ZZJ_REOR FROM " + RetSqlName("ZZJ")

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REORDENA", .T., .T. )

            If !Empty(T_REORDENA->ZZJ_REOR)
               cEmail := ""
               cEmail := "Prezado(a) Usuário(a),"                                                    + chr(13) + chr(10) + chr(13) + chr(10)   
               cEmail += "Existem tarefas aguardando definição de ordenação no controle de tarefas." + chr(13) + chr(10) + chr(13) + chr(10)   
               cEmail += + chr(13) + chr(10) + chr(13) + chr(10) + "Tarefa Nº " + Substr(cCodigo,01,06) + "." + Substr(cCodigo,08,02) + chr(13) + chr(10) + chr(13) + chr(10)   
               cEmail += "Mensagem enviada automaticamente pelo Sistema de Controle de Tarefas"

               If Empty(Alltrim(T_REORDENA->ZZJ_REOR))
               Else
                  U_AUTOMR20(cEmail, Alltrim(T_REORDENA->ZZJ_REOR), "", "Aviso de reordenação de tarefas" )
               Endif
            Endif
         Endif   

      Endif

   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZG")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZG") + Substr(cCodigo,01,06) + Substr(cCodigo,06,02))
            RecLock("ZZG",.F.)
            REF_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlgMANU:End()

Return Nil

// Função que abre janela para informação da estimativa da tarefa
Static Function INF_ESTIMA()

   Local lChumba      := .F.
   Local aEstima  	  := {"       ", "01 Dia" , "02 Dias", "03 Dias", "04 Dias",;
                          "05 Dias", "06 Dias", "07 Dias", "08 Dias", "09 Dias",;
                          "10 Dias", "11 Dias", "12 Dias", "13 Dias", "14 Dias",;
                          "15 Dias", "16 Dias", "17 Dias", "18 Dias", "19 Dias",;
                          "20 Dias", "21 Dias", "22 Dias", "23 Dias", "24 Dias",;
                          "25 Dias", "26 Dias", "27 Dias", "28 Dias", "29 Dias",;
                          "30 Dias", "31 Dias"}

   Local cEstima

   Local k_Tarefa     := Substr(cCodigo,01,06) + "." + Substr(cCodigo,08,02)
   Local k_Titulo     := cTitulo
   Local k_Prioridade := cPrioridade
   Local k_Horas  	  := Space(03)
   Local k_Dias	      := Space(03)

   Local cMemo1	      := ""
   Local k_Descricao  := cTexto

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Local oMemo1
   Local oMemo2

   Private oDlgE

   DEFINE MSDIALOG oDlgE TITLE "Informação de Estimativa de Entrega" FROM C(178),C(181) TO C(459),C(717) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"  Size C(146),C(030) PIXEL NOBORDER OF oDlgE

   @ C(041),C(005) Say "Código"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(041),C(032) Say "Descrição da Tarefa"   Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(041),C(189) Say "Prioridade"            Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(062),C(005) Say "Descrição da Tarefa"   Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(119),C(005) Say "Estimativa de Entrega" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
// @ C(119),C(068) Say "Horas"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
// @ C(119),C(095) Say "Dias"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(263),C(001) PIXEL OF oDlgE

   @ C(050),C(005) MsGet oGet1      Var k_Tarefa          Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(050),C(032) MsGet oGet2      Var k_Titulo          Size C(152),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(050),C(190) MsGet oGet3      Var k_Prioridade      Size C(074),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(071),C(005) GET   oMemo2     Var k_Descricao MEMO  Size C(259),C(044)                              PIXEL OF oDlgE                              
   @ C(127),C(005) ComboBox cEstima Items aEstima         Size C(053),C(010)                              PIXEL OF oDlgE
// @ C(127),C(068) MsGet oGet4      Var k_Horas           Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
// @ C(127),C(095) MsGet oGet5      Var k_Dias            Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
                                
   @ C(124),C(188) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgE ACTION( GRV_ESTIMA(cEstima, k_Horas, k_Dias) )
   @ C(124),C(227) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// Função que grava a estimativa e altera o status da tarefa
Static Function GRV_ESTIMA(__Estimativa, __Horas, __Dias)

   Local cEmail := ""

   // Consiste os dados antes da gravação
   If Empty(Alltrim(__Estimativa))
      MsgAlert("Estimativa não informada.")
      Return(.T.)
   Endif
      
//   If Substr(__Estimativa,01,01) == "H"
//      If Empty(Alltrim(__Horas))
//         MsgAlert("Horas não informada.")
//         Return(.T.)
//      Endif   
//   Endif

//   If Substr(__Estimativa,01,01) == "D"
//      If Empty(Alltrim(__Dias))
//         MsgAlert("Dias não informado.")
//         Return(.T.)
//      Endif   
//   Endif

   // Atualiza a tabela de tarefas
   aArea := GetArea()

   DbSelectArea("ZZG")
   DbSetOrder(1)
 
   If DbSeek(xfilial("ZZG") + Substr(cCodigo,01,06) + Substr(cCodigo,08,02))
      RecLock("ZZG",.F.)
//    ZZG_ORDE := 0
      ZZG_STAT := "2"
      ZZG_ESTI := Alltrim(Substr(__Estimativa,01,02))
//    ZZG_XHOR := __Horas
//    ZZG_XDIA := __Dias
      MsUnLock()              
   Endif

   // Envia e-mail ao responsável pela informação da reordenação das tarefas após a informação da estimativa
   If Select("T_REORDENA") > 0
      T_REORDENA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_REOR "
   cSql += "  FROM " + RetSqlName("ZZJ")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REORDENA", .T., .T. )

   If !Empty(T_REORDENA->ZZJ_REOR)
      cEmail := ""
      cEmail := "Prezado(a) Usuário(a),"                                                    + chr(13) + chr(10) + chr(13) + chr(10)   
      cEmail += "Existem tarefas aguardando definição de ordenação no controle de tarefas." + chr(13) + chr(10) + chr(13) + chr(10)   
      cEmail += + chr(13) + chr(10) + chr(13) + chr(10) + "Tarefa Nº " + Alltrim(cCodigo)   + chr(13) + chr(10) + chr(13) + chr(10)   
      cEmail += "Mensagem enviada automaticamente pelo Sistema de Controle de Tarefas"

      If Empty(Alltrim(T_REORDENA->ZZJ_REOR))
      Else
         U_AUTOMR20(cEmail, Alltrim(T_REORDENA->ZZJ_REOR), "", "Aviso de reordenação de tarefas" )
      Endif
   Endif

   oDlgE:End() 
   
Return(.T.)

// Função que calcula o total de horas da tarefa pesquisada
Static Function CalTotHoras(__Tarefas, __Programador)

   Local cSql := ""

   // Pesquisa o total de horas diárias para o programador da tarefa   
   If Select("T_HORASDIA") > 0
      T_HORASDIA->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZZE_CODIGO,"
   cSql += "       ZZE_NOME  ,"
   cSql += "	   ZZE_TEMPO  "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += "   AND ZZE_CODIGO = '" + Alltrim(__Programador) + "'"
                     
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORASDIA", .T., .T. )

   If T_HORASDIA->( EOF() )

      hPorDia  := "00:00"
      hTotaEst := "00:00"

   Else

      hPorDia  := Strzero(INT(VAL(Alltrim(T_HORASDIA->ZZE_TEMPO))),2) + ":00"

      If (Int(Val(hEstimativa)) * Int(Val(hPorDia))) < 100
         hTotaEst := Strzero(Int(Val(hEstimativa)) * Int(Val(hPorDia)),2) + ":00"
      Else
         hTotaEst := Strzero(Int(Val(hEstimativa)) * Int(Val(hPorDia)),3) + ":00"
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
   cSql += "   AND ZT0_CODI = '" + Substr(__Tarefas,01,06) + "'"
   cSql += "   AND ZT0_SEQU = '" + Substr(__Tarefas,08,02) + "'"

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

Return(.T.)