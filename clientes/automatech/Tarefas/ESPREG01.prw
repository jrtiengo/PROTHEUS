#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPREG01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/06/2014                                                          *
// Objetivo..: Programa que realiza os apontamentos da tarefa                      *
//**********************************************************************************

User Function ESPREG01(_xCodTar, _xNome)

   Local cSql          := ""
   Local lChumba       := .F.

   Private cTarefa     := _xCodTar
   Private cNome       := _xNome
   Private cMemo1      := ""
   Private cAbertura   := ""
   Private cFechamento := ""   
   Private lSalvar     := .F.

   Private oGet1
   Private oGet2
   Private oMemo1
   Private oMemo2
   Private oMemo3   

   Private aHoras := {}
                       
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

   // Envia para a função que crarega os apontamentos da tarefa selecionada
   carrega_aponta(cTarefa, 1)

   Private oDlgApo

   DEFINE MSDIALOG oDlgApo TITLE "Apontamentos de Tarefa" FROM C(178),C(181) TO C(612),C(717) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"                                   Size C(122),C(026)                 PIXEL NOBORDER OF oDlgApo
   @ C(023),C(185) Say "APONTAMENTOS DE TAREFAS"                                Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgApo
   @ C(035),C(005) Say "Código"                                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgApo
   @ C(035),C(031) Say "Descrição da Tarefa"                                    Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgApo
   @ C(055),C(005) Say "Apontamentos Efetuados"                                 Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgApo
   @ C(055),C(156) Say "Duplo click no apontamento para visualizar observações" Size C(136),C(008) COLOR CLR_BLACK PIXEL OF oDlgApo
   @ C(129),C(005) Say "Observações da Abertura do Apontamento"                 Size C(103),C(008) COLOR CLR_BLACK PIXEL OF oDlgApo
   @ C(164),C(005) Say "Observações do Fechamento do Apontamento"               Size C(111),C(008) COLOR CLR_BLACK PIXEL OF oDlgApo

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(262),C(001) PIXEL OF oDlgApo

   @ C(044),C(005) MsGet oGet1  Var cTarefa     Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgApo When lChumba
   @ C(044),C(031) MsGet oGet2  Var cNome       Size C(233),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgApo When lChumba

   @ C(139),C(005) GET   oMemo2 Var cAbertura   MEMO Size C(259),C(024)                         PIXEL OF oDlgApo
   @ C(173),C(005) GET   oMemo3 Var cFechamento MEMO Size C(259),C(024)                         PIXEL OF oDlgApo

   @ C(201),C(005) Button "Abre Apontamento"    Size C(052),C(012) PIXEL OF oDlgApo ACTION( Gera_Apontamento("I", cTarefa, Space(06)            ) ) When lSalvar
   @ C(201),C(060) Button "Fecha Apontamento"   Size C(052),C(012) PIXEL OF oDlgApo ACTION( Gera_Apontamento("F", cTarefa, aHoras[oHoras:nAt,01]) ) When lSalvar
   @ C(201),C(115) Button "Altera Apontamento"  Size C(052),C(012) PIXEL OF oDlgApo ACTION( Gera_Apontamento("A", cTarefa, aHoras[oHoras:nAt,01]) ) When lSalvar
   @ C(201),C(171) Button "Exclui Apontamento"  Size C(052),C(012) PIXEL OF oDlgApo ACTION( Gera_Apontamento("E", cTarefa, aHoras[oHoras:nAt,01]) ) When lSalvar
   @ C(201),C(226) Button "Voltar"              Size C(038),C(012) PIXEL OF oDlgApo ACTION( oDlgApo:End() )

   oHoras := TCBrowse():New( 080 , 005, 332, 080,,{'Apontamento', 'Tipo', 'Data I', 'Hora I', 'Data F', 'Hora F', 'Tot.Horas'},{20,50,50,50},oDlgApo,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oHoras:SetArray(aHoras)
    
   // Monta a linha a ser exibina no Browse
   If Len(aHoras) == 0
   Else
      oHoras:bLine := {||{aHoras[oHoras:nAt,01],;
                          aHoras[oHoras:nAt,02],;
                          aHoras[oHoras:nAt,03],;
                          aHoras[oHoras:nAt,04],;
                          aHoras[oHoras:nAt,05],;
                          aHoras[oHoras:nAt,06],;
                          aHoras[oHoras:nAt,07]}}

      oHoras:bLDblClick := {|| MOSTRANTS(aHoras[oHoras:nAt,01]) } 

   Endif   

   ACTIVATE MSDIALOG oDlgApo CENTERED 

Return(.T.)

// Sub-Função que carrega as observações para visualização
Static Function MOSTRANTS(_Aponta)

   Local cSql    := ""
   Local cAbre   := ""
   Local cFecha  := ""

   cAbertura     := ""
   cFechamento   := ""

   If Select("T_MOSTRA") > 0
      T_MOSTRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT0_OBSE)) AS DESCRICAO, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT0_NOTA)) AS NOTAS      "
   cSql += "  FROM " + RetSqlName("ZT0")
   cSql += " WHERE ZT0_DELE  = ''"
   cSql += "   AND ZT0_APON  = '" + Alltrim(_Aponta) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

   If T_MOSTRA->( EOF() )
      Return .T.
   Endif

   cAbertura   := T_MOSTRA->DESCRICAO
   cFechamento := T_MOSTRA->NOTAS

   oMemo2:Refresh()
   oMemo3:Refresh()   

Return .T.

// Função que carrega os apontamentos da tarefa selecionada para popular o grid da tela
Static Function Carrega_aponta(_Tarefa, _Abertura)

   Local cSql := ""
                   
   aHoras := {}

   // Pesquisa os apontamentos para a tarefa selecionada
   If Select("T_APONTA") > 0
      T_APONTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT0_FILIAL,"
   cSql += "       ZT0_CODI  ,"
   cSql += "       ZT0_SEQU  ,"
   cSql += "       ZT0_APON  ,"
   cSql += "       ZT0_DTAI  ,"
   cSql += "       ZT0_HRSI  ,"
   cSql += "       ZT0_DTAF  ,"
   cSql += "       ZT0_HRSF  ,"
   cSql += "       ZT0_DELE  ,"
   cSql += "       ZT0_DESE  ,"
   cSql += "       ZT0_ATRA  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT0_OBSE)) AS OBSERVACAO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT0_NOTA)) AS NOTA"   
   cSql += "  FROM " + RetSqlName("ZT0")
   cSql += " WHERE ZT0_DELE = ''"
   cSql += "   AND ZT0_CODI = '" + Substr(_Tarefa,01,06) + "'"
   cSql += "   AND ZT0_SEQU = '" + Substr(_Tarefa,08,02) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTA", .T., .T. )

   If T_APONTA->( EOF() )
      aHoras := {}
   Else
      aHoras := {}
      WHILE !T_APONTA->( EOF() )

         If T_APONTA->ZT0_DESE == "X"
            __TipoApontamento := "Desenvolvimento"
         Endif
            
         If T_APONTA->ZT0_ATRA == "X"
            __TipoApontamento := "Atraso"
         Endif

         aAdd( aHoras, { T_APONTA->ZT0_APON                       ,;
                         __TipoApontamento                        ,;
                         Substr(T_APONTA->ZT0_DTAI,07,02) + "/" +  ;
                         Substr(T_APONTA->ZT0_DTAI,05,02) + "/" +  ;
                         Substr(T_APONTA->ZT0_DTAI,01,04)         ,;
                         T_APONTA->ZT0_HRSI                       ,;
                         Substr(T_APONTA->ZT0_DTAF,07,02) + "/" +  ;
                         Substr(T_APONTA->ZT0_DTAF,05,02) + "/" +  ;
                         Substr(T_APONTA->ZT0_DTAF,01,04)         ,;
                         T_APONTA->ZT0_HRSF                       ,;
                         STR(SUBHORAS(T_APONTA->ZT0_HRSF, T_APONTA->ZT0_HRSI),06,02)})

         T_APONTA->( DbSkip() )
      ENDDO
   Endif

   If _Abertura == 1
      Return(.T.)
   Endif   
      
   // Seta vetor para a browse                            
   oHoras:SetArray(aHoras)
    
   // Monta a linha a ser exibina no Browse
   oHoras:bLine := {||{aHoras[oHoras:nAt,01],;
                       aHoras[oHoras:nAt,02],;
                       aHoras[oHoras:nAt,03],;
                       aHoras[oHoras:nAt,04],;
                       aHoras[oHoras:nAt,05],;
                       aHoras[oHoras:nAt,06],;
                       aHoras[oHoras:nAt,07]}}
   oHoras:bLDblClick := {|| MOSTRANTS(aHoras[oHoras:nAt,01]) } 

Return(.T.)

// Função que realiza a manutenção dos apontamentos
Static Function Gera_Apontamento(_Operacao, _Tarefa, _Apontamento)

   Local lChumba     := .F.
   Local lFecha      := .T.
   Local lAbertura   := .F.
   Local lFechamento := .F.

   Private cDataI      := Ctod("  /  /    ")
   Private cHoraI      := Space(08)
   Private cDataF      := Ctod("  /  /    ")
   Private cHoraF      := Space(08)
   Private lDesenvolve := .F.
   Private lAtrasado   := .F.

   Private cMemo1 := ""
   Private cMemo2 := ""
   Private cMemo3 := ""
   Private oCheckBox1
   Private oCheckBox2

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private oDlgA

   // Se operação for de abertura, carrega a data e hora inicial
   If _Operacao == "I"

      Private cDataI := Date()
      Private cHoraI := Time()

      // Verifica se tarefa está no status Desenvolvimento
      If Select("T_PODEABRIR") > 0
         T_PODEABRIR->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZZG_CODI,"
      cSql += "       ZZG_SEQU,"
      cSql += "       ZZG_STAT "
      cSql += "  FROM " + RetSqlName("ZZG")
      cSql += " WHERE ZZG_CODI   = '" + Substr(_Tarefa,01,06) + "'"
      cSql += "   AND ZZG_SEQU   = '" + Substr(_Tarefa,08,02) + "'"      
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PODEABRIR", .T., .T. )
 
      If T_PODEABRIR->ZZG_STAT <> "4"
//       MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Somente é permitido abrir apontamentos para tarefas que estão no status:" + chr(13) + chr(10) + "4 - Em Desenvolvimento.")
//       Return(.T.)
      Endif

      // Verifica se existe registro somente de abertura. Não deixa abrir outra se não for fechado o que estiver em aberto
      If Select("T_ABERTO") > 0
         T_ABERTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZT0_FILIAL,"
      cSql += "       ZT0_CODI  ,"
      cSql += "       ZT0_SEQU  ,"
      cSql += "       ZT0_APON  ,"
      cSql += "       ZT0_DTAI  ,"
      cSql += "       ZT0_HRSI  ,"
      cSql += "       ZT0_DTAF  ,"
      cSql += "       ZT0_HRSF   "
      cSql += "  FROM " + RetSqlName("ZT0")
      cSql += " WHERE ZT0_DELE  = ''"
      cSql += "   AND ZT0_DTAI <> ''"
      cSql += "   AND ZT0_DTAF  = ''"  

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ABERTO", .T., .T. )

      If !T_ABERTO->( EOF() )
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existe apontamento em aberto para na tarefa nº " + Alltrim(T_ABERTO->ZT0_CODI) + "." + chr(13) + chr(10) + "Você deve encerrar primeiro o apontamento que está aberto para poder" + chr(13) + chr(10) + "abrir outro apontamento.")
//       Return(.T.)
      Endif

   Endif
   
   // Se operação for de fechamento, carrega a data e hora final
   If _Operacao == "F" .Or. _Operacao == "A" .Or. _Operacao == "E"

      Private cDataF := Date()
      Private cHoraF := Time()

      If Select("T_APONTA") > 0
         T_APONTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZT0_FILIAL,"
      cSql += "       ZT0_CODI  ,"
      cSql += "       ZT0_SEQU  ,"
      cSql += "       ZT0_APON  ,"
      cSql += "       ZT0_DTAI  ,"
      cSql += "       ZT0_HRSI  ,"
      cSql += "       ZT0_DTAF  ,"
      cSql += "       ZT0_HRSF  ,"
      cSql += "       ZT0_DELE  ,"
      cSql += "       ZT0_DESE  ,"
      cSql += "       ZT0_ATRA  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT0_OBSE)) AS OBSERVACAO,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT0_NOTA)) AS NOTA"
      cSql += "  FROM " + RetSqlName("ZT0")
      cSql += " WHERE ZT0_DELE = ''"
      cSql += "   AND ZT0_CODI = '" + Substr(_Tarefa,01,06) + "'"
      cSql += "   AND ZT0_SEQU = '" + Substr(_Tarefa,08,02) + "'"      
      cSql += "   AND ZT0_APON = '" + Alltrim(_Apontamento) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTA", .T., .T. )

      If T_APONTA->( EOF() )
         MsgAlert("Não existem dados a serem visualizados para este apontamento.")
         Return(.T.)
      Endif

      lFecha := .T.
      
      If _Operacao == "A"
         cDataF := Ctod("  /  /    ")
         cHoraF := Space(05)
      Endif   

      If _Operacao == "A"
         cDataF := Ctod("  /  /    ")
         cHoraF := Space(05)
      Endif   

      // Se apontamento já fechado, carrega data e hora de fechamento para display
      If !Empty(Alltrim(T_APONTA->ZT0_DTAI)) .And. !Empty(Alltrim(T_APONTA->ZT0_DTAF))
         cDataF := Ctod(Substr(T_APONTA->ZT0_DTAF,07,02) + "/" + Substr(T_APONTA->ZT0_DTAF,05,02) + "/" + Substr(T_APONTA->ZT0_DTAF,01,04))
         cHoraF := T_APONTA->ZT0_HRSF
      Endif   

      cDataI      := Ctod(Substr(T_APONTA->ZT0_DTAI,07,02) + "/" + Substr(T_APONTA->ZT0_DTAI,05,02) + "/" + Substr(T_APONTA->ZT0_DTAI,01,04))
      cHoraI      := T_APONTA->ZT0_HRSI
      lDesenvolve := IIF(T_APONTA->ZT0_DESE == "X", .T., .F.)
      lAtrasado   := IIF(T_APONTA->ZT0_ATRA == "X", .T., .F.)
         
      cMemo2 := T_APONTA->OBSERVACAO
      cMemo3 := T_APONTA->NOTA

   Endif

   // Carrega variável que habilitará ou não os campos para edição
   Do Case
      Case _Operacao == "I"
           lAbertura   := .T.
           lFechamento := .F.
      Case _Operacao == "F" 
           lAbertura   := .F.
           lFechamento := .T.
      Case _Operacao == "A"
           lAbertura   := IIF(lFecha, .T., .F.)
           lFechamento := IIF(lFecha, .T., .F.)
      Case _Operacao == "E"
           lAbertura   := .F.
           lFechamento := .F.
   EndCase

   DEFINE MSDIALOG oDlgA TITLE "Apontamento da Tarefa" FROM C(178),C(181) TO C(475),C(717) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgA

   @ C(037),C(005) Say "Data Inicial"                          Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(037),C(047) Say "Hora Inicial"                          Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(037),C(093) Say "Data Final"                            Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(037),C(135) Say "Hora Final"                            Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(059),C(005) Say "Observações Abertura de Apontamento"   Size C(095),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(094),C(005) Say "Observações Fechamento de Apontamento" Size C(105),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(037),C(185) Say "Tipo de Apontamento"                   Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   Do Case
      Case _Operacao == "I"
           @ C(022),C(170) Say "ABERTURA DE APONTAMENTOS" Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
      Case _Operacao == "F"
           @ C(022),C(170) Say "FECHAMENTO DE APONTAMENTOS" Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
      Case _Operacao == "A"
           @ C(022),C(170) Say "ALTERAÇÃO DE APONTAMENTOS" Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
      Case _Operacao == "E"
           @ C(022),C(170) Say "EXCLUSÃO DE APONTAMENTOS" Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   EndCase           

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(262),C(001) PIXEL OF oDlgA

   @ C(046),C(005) MsGet oGet1  Var cDataI      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgA When lAbertura
   @ C(046),C(047) MsGet oGet2  Var cHoraI      Size C(036),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgA When lAbertura
   @ C(046),C(093) MsGet oGet3  Var cDataF      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgA When lAbertura && lFechamento
   @ C(046),C(135) MsGet oGet4  Var cHoraF      Size C(036),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgA When lAbertura && lFechamento

   If _Operacao == "I"
      @ C(046),C(185) CheckBox oCheckBox1 Var lDesenvolve Prompt "Desenvolvimento" Size C(052),C(008) PIXEL OF oDlgA
      @ C(055),C(185) CheckBox oCheckBox2 Var lAtrasado   Prompt "Atraso"          Size C(048),C(008) PIXEL OF oDlgA
   Else
      @ C(046),C(185) CheckBox oCheckBox1 Var lDesenvolve Prompt "Desenvolvimento" Size C(052),C(008) PIXEL OF oDlgA When lChumba
      @ C(055),C(185) CheckBox oCheckBox2 Var lAtrasado   Prompt "Atraso"          Size C(048),C(008) PIXEL OF oDlgA When lChumba
   Endif      

   @ C(068),C(005) GET   oMemo2 Var cMemo2 MEMO Size C(259),C(025) PIXEL OF oDlgA When lAbertura
   @ C(104),C(005) GET   oMemo3 Var cMemo3 MEMO Size C(259),C(025) PIXEL OF oDlgA When lFechamento

   @ C(132),C(186) Button "Salvar"              Size C(037),C(012) PIXEL OF oDlgA ACTION( Grava_Apontamento(_Operacao, _Tarefa, _Apontamento) ) When lFecha
   @ C(132),C(227) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlgA ACTION( oDlgA:End() )

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Função que grava a inclusão, alteração ou exclusão de apontamentos
Static Function Grava_Apontamento(_Operacao, _Tarefa, _Apontamento)
   
   Local cSql    := ""
   Local cCodigo := ""
   Local nHdesen := "  :  :  "
   Local nHatras := "  :  :  "

   If lDesenvolve .And. lAtrasado
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + "Somente permitido informar o Tipo de Apontamento Desenvolvimento ou Atraso." + Chr(13) + Chr(10) + "Verifique!")
      Return(.T.)
   Endif

   If !lDesenvolve .And. !lAtrasado
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + "Tipo de Apontamento não indicado. Verifique!")
      Return(.T.)
   Endif

   // Inclusão de Apontamento
   If _Operacao == "I"

      // Pesquisa o Próximo número de apontamento para gravação
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZT0_APON "
      cSql += "  FROM " + RetSqlName("ZT0")
      cSql += " ORDER BY ZT0_APON DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

      If T_NOVO->( EOF() )
         cCodigo := '000001'
      Else
         cCodigo := Strzero((INT(VAL(T_NOVO->ZT0_APON)) + 1),6)      
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()
      dbSelectArea("ZT0")
      RecLock("ZT0",.T.)
      ZT0_CODI := Substr(_Tarefa,01,06)
      ZT0_SEQU := Substr(_Tarefa,08,02)
      ZT0_APON := cCodigo
      ZT0_DTAI := cDataI
      ZT0_HRSI := cHoraI
      ZT0_DTAF := cDataF
      ZT0_HRSF := cHoraF
      ZT0_OBSE := cMemo2
      ZT0_NOTA := cMemo3
      ZT0_DESE := IIF(lDesenvolve == .T., "X", " ")
      ZT0_ATRA := IIF(lAtrasado   == .T., "X", " ")
      ZT0_DELE := ""
      MsUnLock()
   Endif

   // Fechamento de Tarefa/Alteração
   If _Operacao == "F" .Or. _Operacao == "A"
 
	  dbSelectArea("ZT0")
	  dbSetOrder(3)
	  If dbSeek(xFilial("ZT0") + Substr(_Tarefa,01,06) + Substr(_Tarefa,08,02) + _Apontamento)
         aArea := GetArea()
         dbSelectArea("ZT0")
         RecLock("ZT0",.F.)
       
         If _Operacao == "A"
            ZT0_DTAF := cDataF
            ZT0_HRSF := cHoraF
         Else
            ZT0_DTAF := cDataF
            ZT0_HRSF := cHoraF
         Endif   

         ZT0_OBSE := cMemo2
         ZT0_NOTA := cMemo3
         ZT0_DESE := IIF(lDesenvolve == .T., "X", " ")
         ZT0_ATRA := IIF(lAtrasado   == .T., "X", " ")
         MsUnLock()
      Endif

   Endif
      
   // Exclusão de Apontamentos
   If _Operacao == "E"

      If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente excluir este apontamento?")
 
   	     dbSelectArea("ZT0")
	     dbSetOrder(3)
	     If dbSeek(xFilial("ZT0") + _Tarefa + _Apontamento)
            aArea := GetArea()
            dbSelectArea("ZT0")
            RecLock("ZT0",.F.)
            ZT0_DELE := "X"
            MsUnLock()
         Endif
         
      Endif   

   Endif

   If _Operacao == "I"
      oDlgApo:End()      
      oDlgA:End()
      U_ESPREG01(cTarefa, cNome)
      Return(.T.)
   Endif

   // Atualiza as columas de Total de Horas de Desenvolvimento e Total de Horas de Atraso para a tarefa selecionada
   If Select("T_HORAS") > 0
      T_HORAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT0_FILIAL,"
   cSql += "       ZT0_CODI  ,"
   cSql += "       ZT0_SEQU  ,"
   cSql += "       ZT0_APON  ,"
   cSql += "       ZT0_DTAI  ,"
   cSql += "       ZT0_HRSI  ,"
   cSql += "       ZT0_DTAF  ,"
   cSql += "       ZT0_HRSF  ,"
   cSql += "       ZT0_DESE  ,"
   cSql += "       ZT0_ATRA   "
   cSql += "  FROM " + RetSqlName("ZT0")
   cSql += " WHERE ZT0_DELE  = ''"
   cSql += "   AND ZT0_CODI  = '" + Substr(_Tarefa,01,06) + "'"
   cSql += "   AND ZT0_SEQU  = '" + Substr(_Tarefa,08,02) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )

   nHdesen := "00:00:00"
   nHatras := "00:00:00"

   If !T_HORAS->( EOF() )
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
         
   Endif

   If ValType(nHdesen) == "C"
      nHdesen := 0.00
   Endif
                           
   If ValType(nHatras) == "C"
      nHatras := 0.00
   Endif

   // Prepara as horas para gravação
   nHdesen := strzero(int(val(u_p_corta(str(nHdesen,05,02), '.',1))),2) + ":" + strzero(int(val(u_p_corta(str(nHdesen,05,02) + '.', '.',2))),2)
   nHatras := strzero(int(val(u_p_corta(str(nHatras,05,02), '.',1))),2) + ":" + strzero(int(val(u_p_corta(str(nHatras,05,02) + '.', '.',2))),2)

   // Atualiza os campos de total de horas da tarfa selecionada
   aArea := GetArea()

   DbSelectArea("ZZG")
   DbSetOrder(1)
 
   If DbSeek(xfilial("ZZG") + Substr(_Tarefa,01,06) + Substr(_Tarefa,08,02))
      RecLock("ZZG",.F.)
      ZZG_TDES := nHdesen
      ZZG_TATR := nHatras
      ZZG_TSAL := STR(SUBHORAS(SUBHORAS(ZZG_THOR, ZZG_TDES), ZZG_TATR),06,02)
      MsUnLock()              
   Endif

   oDlgA:End()

   If _Operacao == "I"
      oDlgApo:End()      
      U_ESPREG01(cTarefa, cNome)
      Return(.T.)
   Endif
           
   Carrega_aponta(_Tarefa,2)

Return(.T.)