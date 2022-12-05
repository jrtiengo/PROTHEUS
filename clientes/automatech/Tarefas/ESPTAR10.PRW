#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR10.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/02/2015                                                          *
// Objetivo..: Programa que calcula a data prevista de entrega das tarefas         *
// Parâmetros: Sem parãmetros                                                      **
//**********************************************************************************

User Function ESPTAR10()

   Local cSql         := ""
   Local nContar      := 0
   Local cString      := ""
   Local cDataInicial := Ctod("  /  /    ")
   Local nAtrasos     := 0

   Private nHdl
   
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
   If Select("T_DATAINICIAL") > 0
      T_DATAINICIAL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_ORDE "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZZG_DELE   = ' '"
   cSql += "   AND ZZG_ORDE  <> 0"
   cSql += "   AND ZZG_ORIG   = '000001'"
   cSql += "   AND LTRIM(ZZG_STAT) IN ('5', '7', '8', '9')"
   cSql += " ORDER BY ZZG_ORDE DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DATAINICIAL", .T., .T. )

   If T_DATAINICIAL->( EOF() )
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
         Else
            cDataInicial := T_XPARAMETROS->ZZ4_DPRE
         Endif
      Endif
   Else
      // Pesquisa na tabela de histórico de Status a data inicial para cálculo da data prevista de entrega
      If Select("T_HISTORICO") > 0
         T_HISTORICO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZH_DATA,"
      cSql += "       ZZH_HORA,"
      cSql += "       ZZH_STAT "
      cSql += "  FROM " + RetSqlName("ZZH")
      cSql += " WHERE ZZH_CODI   = '" + Alltrim(T_DATAINICIAL->ZZG_CODI) + "'"
      cSql += "   AND ZZH_DELE   = ' '"
      cSql += "   AND D_E_L_E_T_ = '' "
      cSql += "   AND LTRIM(ZZH_STAT) IN ('5', '7', '8', '9')" 
      cSql += " ORDER BY ZZH_DATA, ZZH_HORA"

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
            Else
               cDataInicial := T_XPARAMETROS->ZZ4_DPRE
            Endif
         Endif
      Else
         T_HISTORICO->( DbGoTop() )
         cDataInicial := T_HISTORICO->ZZH_DATA
      Endif
   Endif

   // Select que pesquisa as tarefas que serão calculadas as datas previstas de entrega
   If Select("T_AORDENAR") > 0
      T_AORDENAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
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
   cSql += "   AND LTRIM(ZZG_STAT) IN ('2', '4', '6', '10')"
   cSql += " ORDER BY ZZG_ORDE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AORDENAR", .T., .T. )

   If T_AORDENAR->( EOF() )
      Return(.T.)
   Endif

   // Prepara a data inicial para cálculo
   cDataInicial := Ctod(Substr(cDataInicial,07,02) + "/" + Substr(cDataInicial,05,02) + "/" + Substr(cDataInicial,01,04))

   cString := ""
   cString := "Cálculo da Data Prevista de entrega de Tarefas"                            + chr(13) + chr(10)
   cString += "-------------------------------------------------------------------------" + chr(13) + chr(10)
   cString += "TAREFA  A PARTIR DE  ESTIMATIVA  ATRASO JUST.   PREVISAO     ENCERRAMENTO" + chr(13) + chr(10) 
   cString += "------  -----------  ----------  ------------   ----------   ------------" + chr(13) + chr(10) 
   
   // Calcula as datas previstas de entrega
   T_AORDENAR->( DbGoTop() )
   
   WHILE !T_AORDENAR->( EOF() )
      
      // Verifica se houve informação de atraso no desenvolvimento (Atraso Justificado)
      nAtrasos := 0
      nHatras  := "00:00:00"
      
      If Select("T_ATRASOS") > 0
         T_ATRASOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZT0_CODI,"
      cSql += "       ZT0_DTAI,"
      cSql += "       ZT0_HRSI,"
	  cSql += "       ZT0_DTAF,"
      cSql += "       ZT0_HRSF " 
      cSql += "  FROM " + RetSqlName("ZT0")
      cSql += " WHERE ZT0_CODI = '" + Alltrim(T_AORDENAR->ZZG_CODI) + "'"
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
      nEstimativa := INT(VAL(IIF(Empty(Alltrim(T_AORDENAR->ZZG_ESTI)), "01", T_AORDENAR->ZZG_ESTI)))

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

      // Atualiza a String para gravação
      cString += T_AORDENAR->ZZG_CODI  + Space(02) + ;
                 Dtoc(dPrimeira)       + Space(03) + ;
                 T_AORDENAR->ZZG_ESTI  + Space(10) + ;
                 nHatras               + Space(10) + ;
                 Dtoc(cDataInicial)    + Space(03) + ;
                 "XX/XX/XXXX"          + chr(13) + chr(10)

      T_AORDENAR->( DbSkip() )
      
   ENDDO   

   // Gera o arquivo XML para o caminho informado
   nHdl := fCreate("e:\automatech\previsao.txt")
   fWrite (nHdl, cString ) 
   fClose(nHdl)


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



// ****************************************************************
// ****************************************************************
// ****************************************************************
// ****************************************************************
// ****************************************************************

/*
      // Carrega os dados das tarefas para recálculo das datas
      aAdd( aOrdem, {T_ORDENACAO->ZZG_CODI,; // 01 - Código da Tarefa
                     T_ORDENACAO->ZZG_DATA,; // 02 - Data de Abertura da Tarefa (Serve para cálculo da primeira data prevista de entrega
                     T_ORDENACAO->ZZG_PREV,; // 03 - Data Prevista de Entrega
                     __Estimativa         ,; // 04 - Estimativa para Cálculo
                     T_ORDENACAO->ZZG_XDIA,; // 05 - Dias para cálculo da data prevista de entrega
                     T_ORDENACAO->ZZG_XHOR,; // 06 - Hora para cálculo da data prevista de entrega
                     T_ORDENACAO->ZZG_DEBI,; // 07 - Dias de Atraso
                     T_ORDENACAO->ZZG_PROG,; // 08 - Programador responsável pela tarefa
                     0                    ,; // 09 - Débito de Dias
                     0                    ,; // 10 - Crédito de Dias
                     T_ORDENACAO->ZZG_ORDE,; // 11 - Ordenação
                     "X"                  ,; // 12 - Indica se calcula a nova data de previsão
                     __APartirDe          ,; // 13 - Data de A Partir De
                     T_ORDENACAO->ZZD_ORDE,; // 14 - Ordenação da Prioridade da Tarefa
                     T_ORDENACAO->ZZG_STAT,; // 15 - Status da Tarefa
                     T_ORDENACAO->ZZG_THOR,; // 16 - Total de Horas para desenvolvimento
                     T_ORDENACAO->ZZG_TDES,; // 17 - Total de Horas utilizadas no desenvolvimento
                     T_ORDENACAO->ZZG_TATR,; // 18 - Total de Hora de atraso
                     T_ORDENACAO->ZZG_TSAL}) // 19 - Total de Saldo de Horas da tarefa

      T_ORDENACAO->( DbSkip() )

   ENDDO
                     
   oMeter1:Set(100)      

   If Len(aOrdem) == 0
      Return(.T.)
   Endif
   
   // Régua de percentual
   @ C(020),C(161) METER oMeter1 VAR nMeter1                   Size C(222),C(008) NOPERCENTAGE    PIXEL OF oDlgManu

   nRegua := 0
   oMeter1:Refresh()
   oMeter1:Set(nRegua)
   oMeter1:SetTotal(100)

   // Corrige a ordenação para realizar o novo cálculo
   For nContar = 1 to Len(aOrdem)

       nRegua := nRegua + 1
       oMeter1:Set(nRegua)      

       If aOrdem[nContar,11] == 0

          // Se não existe ordenação, pesquisa a próxima para a prioridade
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
          cSql += " ORDER BY ZZG_ORDE DESC "
                     
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

          nOrdenacao := T_PROXIMO->ZZG_ORDE + T_INTERVALO->ZZJ_INTE
         
       Else
       
          nOrdenacao := aOrdem[nContar,11]
       
       Endif   

       aOrdem[nContar,11] := nOrdenacao

       If Empty(Alltrim(aOrdem[nContar,04]))
          aOrdem[nContar,04] := "01"
       Endif

       // Calcula o total de horas
       If Empty(Alltrim(aOrdem[nContar,16]))
          aOrdem[nContar,16] := Strzero((INT(VAL(aOrdem[nContar,04])) * 4),2) + ":00"
          aOrdem[nContar,19] := Strzero((INT(VAL(aOrdem[nContar,04])) * 4),2) + ":00"
       Endif

   Next nContar

   oMeter1:Set(100)      

   // Calcula as datas previstas para a prioridades pesquisadas

   // Régua de Percentual
   @ C(020),C(161) METER oMeter1 VAR nMeter1                   Size C(222),C(008) NOPERCENTAGE    PIXEL OF oDlgManu

   nRegua := 0
   oMeter1:Refresh()
   oMeter1:Set(nRegua)
   oMeter1:SetTotal(100)

   For nContar = 1 to Len(aOrdem)

       nRegua := nRegua + 1
       oMeter1:Set(nRegua)      

       If Alltrim(aOrdem[nContar,15]) == "10"
          Loop
       Endif   

       // Transforma as horas em numéricos levando em consideração a regra: se hora fracionada, considera uma hora cheia
       h_estimativa      := INT(VAL(Substr(aOrdem[nContar,16],01,02)))
       h_desenvolvimento := INT(VAL(Substr(aOrdem[nContar,17],01,02))) + IIF(INT(VAL(Substr(aOrdem[nContar,17],04,02))) == 0, 0, 1)
       h_atraso          := INT(VAL(Substr(aOrdem[nContar,18],01,02))) + IIF(INT(VAL(Substr(aOrdem[nContar,18],04,02))) == 0, 0, 1)

       // Se total de horas de desenvolvimento menos total estimado for maior que total de horas estimadas para desenvolvimento, acrescenta horas no total
       If h_desenvolvimento <> 0
          If h_desenvolvimento > h_estimativa
             __MaisDesen := INT((h_desenvolvimento - h_estimativa) / 4) + IIF(MOD((h_desenvolvimento - h_estimativa),4) == 0, 0, 1)
          Else
             __MaisDesen := 0             
          Endif   
       Else
          __MaisDesen := 0
	       Endif
 
       // Se houver horas informadas como atraso, calcula a quantidade de dias a serem adicionados para o cálculo da data prevista de entrega
       If h_atraso <> 0
          __MaisAtraso := INT(h_atraso / 4) + IIF(MOD(h_atraso,4) == 0, 0, 1)
       Else
          __MaisAtraso := 0
       Endif      

       // ------------------------------------------------------- //
       // Calcula data prevista pela quantidade de dias informado //
       // ------------------------------------------------------- //
       __Adicionar := int(val(aOrdem[nContar,04])) + __MaisDesen + __MaisAtraso
     
       If lCargaUm
          kDestaData  := aOrdem[nContar,13]
          kPrevisto   := aOrdem[nContar,13]
          lCargaUm := .F.
       Endif   

       For yContar = 1 to __Adicionar

           kPrevisto := kPrevisto + 1

           // Verifica se data é sábado
           kPrevisto := Dataextras(1, kPrevisto)

           // Verifica se data é domingo
           kPrevisto := Dataextras(2, kPrevisto)

           // Verifica se data é um feriado fixo
           kPrevisto := Dataextras(3, kPrevisto)
       
           // Verifica se data é um feriado móvel
           kPrevisto := Dataextras(4, kPrevisto)

           // Verifica se data está no intervalo de férias do usuário selecionado
           kPrevisto := Dataextras(5, kPrevisto)
                                                                             
       Next yContar    

       // Atualiza o Array para ser usado na atualização da Tabela ZZG
       aOrdem[nContar,03] := kPrevisto   && Data Prevista de entrega
       aOrdem[nContar,13] := kDestaData  && Data A Partir De

       kApartirDe := kPrevisto        
       kDestaData := kPrevisto         
          
   Next nContar    

   oMeter1:Set(100)      
   
   // Grava as novas datas nas tarefas envolvidas

   // Régua de Percentual
   @ C(020),C(161) METER oMeter1 VAR nMeter1                   Size C(222),C(008) NOPERCENTAGE    PIXEL OF oDlgManu

   nRegua := 0
   oMeter1:Refresh()
   oMeter1:Set(nRegua)
   oMeter1:SetTotal(100)

   For nContar = 1 to Len(aOrdem)

       nRegua := nRegua + 1
       oMeter1:Set(nRegua)      

       // Atualiza a tabela de tarefas
       aArea := GetArea()

       DbSelectArea("ZZG")
       DbSetOrder(1)
 
       If DbSeek(xfilial("ZZG") + aOrdem[nContar,01])
          RecLock("ZZG",.F.)
          ZZG_APAR := aOrdem[nContar,13]
          ZZG_PREV := IIF(Alltrim(aOrdem[nContar,15]) == "10", Ctod("  /  /    "), aOrdem[nContar,03])
          ZZG_ESTI := aOrdem[nContar,04]
          ZZG_ORDE := aOrdem[nContar,11]
          ZZG_THOR := aOrdem[nContar,16]
          ZZG_TDES := aOrdem[nContar,17]
          ZZG_TATR := aOrdem[nContar,18]
          ZZG_TSAL := aOrdem[nContar,19]
          MsUnLock()              
       Endif

   Next nContar



   ENDDO
   
Return(.T.)

*/