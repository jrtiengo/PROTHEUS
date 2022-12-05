#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPDUC01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/05/2012                                                          *
// Objetivo..: Programa que registra os Historicos de Atualizações da Produção     *
//**********************************************************************************

User Function ESPDUC01()   

   Local cSql       := ""
   Local oFont      := Tfont():New("Courier New",,20,.T.)
   
   Private cDetalhe := ""
   Private oMemo1

   Private aBrowse := {}
   Private oDlg

   aBrowse := {}
   
   // Pesquisa as Atualizações cadastradas
   
   // Carrega o grid
   If Select("T_OBJETO") > 0
      T_OBJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZL_CODI,"
   cSql += "       ZZL_DATA "
   cSql += "  FROM " + RetSqlName("ZZL")
   cSql += " GROUP BY ZZL_CODI, ZZL_DATA"
   cSql += " ORDER BY ZZL_CODI, ZZL_DATA"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBJETO", .T., .T. )

   If T_OBJETO->( EOF() )
      aAdd(aBrowse, { '', '' } )
   Else
      T_OBJETO->( DbGoTop() )
      WHILE !T_OBJETO->( EOF() )
         aAdd(aBrowse, { T_OBJETO->ZZL_CODI, Substr(T_OBJETO->ZZL_DATA,07,02) + "/" + Substr(T_OBJETO->ZZL_DATA,05,02) + "/" + Substr(T_OBJETO->ZZL_DATA,01,04) } )
         T_OBJETO->( DbSkip() )
      ENDDO
   Endif         

   DEFINE MSDIALOG oDlg TITLE "Histórico de Atualização de Produção" FROM C(178),C(181) TO C(547),C(895) PIXEL

   @ C(003),C(003) Say "Históricos"                        Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(090) Say "Detalhes do Histórico Selecionado" Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(013),C(090) GET oMemo1 Var cDetalhe MEMO Font oFont Size C(262),C(153) PIXEL OF oDlg

   @ C(168),C(003) Button "Incluir" Size C(025),C(012) PIXEL OF oDlg ACTION( INCHISTORICO("I") )
   @ C(168),C(030) Button "Alterar" Size C(024),C(012) PIXEL OF oDlg ACTION(  ABRECOMPO("A", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] ))
// @ C(168),C(056) Button "Excluir" Size C(031),C(012) PIXEL OF oDlg ACTION(  ABRECOMPO("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] ))
   @ C(168),C(315) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 013 , 003, 110, 200,,{'Código', 'Data' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse)
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }

   oBrowse:bLDblClick := {|| MOSTRADET(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] ) } 

   MOSTRADET(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Abre tela de Inclusão de Historicos
Static Function MOSTRADET( __Codigo, __Data)

   Local __Detalhe := ""

   // Carrega o grid
   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZL_NOME,"
   cSql += "       ZZL_TIPO "
   cSql += "  FROM " + RetSqlName("ZZL")
   cSql += " WHERE ZZL_CODI = '" + Alltrim(__Codigo) + "'"
   cSql += "   AND ZZL_DATA = '" + Alltrim(Substr(__Data,07,04) + Substr(__Data,04,02) + Substr(__Data,01,02))   + "'"
   cSql += "   AND ZZL_DELE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   If T_DETALHE->( EOF() )
      cDetalhe := ""
   Else
      cDetalhe := ""
      T_DETALHE->( DbGoTop() )
      WHILE !T_DETALHE->( EOF() )

         Do Case
            Case T_DETALHE->ZZL_TIPO == "1"
                 __Tipo := "Fonte"
            Case T_DETALHE->ZZL_TIPO == "2"
                 __Tipo := "Gatilho"
            Case T_DETALHE->ZZL_TIPO == "3"
                 __Tipo := "Ponto de Entrada"
            Case T_DETALHE->ZZL_TIPO == "4"
                 __Tipo := "Tabela"
            Case T_DETALHE->ZZL_TIPO == "5"
                 __Tipo := "Campo de Tabela"
            Case T_DETALHE->ZZL_TIPO == "6"
                 __Tipo := "Configurador"
         EndCase                 

         __Detalhe := __Detalhe + Substr(T_DETALHE->ZZL_NOME,01,30) + "  " + Alltrim(__Tipo) + chr(13) + chr(10)

         T_DETALHE->( DbSkip() )

      ENDDO

   Endif         

   cDetalhe := __Detalhe   
   oMemo1:Refresh()

Return .T.      

// Abre tela de Inclusão de Historicos
Static Function INCHistorico()

   Local cSql    := ""
   Local lChumba := .F.

   Private cCodigo := Space(006)
   Private cData   := Date()

   Private oGet1
   Private oGet2

   Private oDlgx

   // Pesquisa o próximo código para inclusão
   If Select("T_CODIGO") > 0
	  T_CODIGO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZL_CODI"
   cSql += "  FROM " + RetSqlName("ZZL")
   cSql += " ORDER BY ZZL_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CODIGO", .T., .T. )

   If T_CODIGO->( EOF() )
      cCodigo := '000001'
   Else
      cCodigo := Strzero((INT(VAL(T_CODIGO->ZZL_CODI)) + 1),6)      
   Endif

   DEFINE MSDIALOG oDlgx TITLE "Inclusão de Histórico" FROM C(178),C(181) TO C(286),C(373) PIXEL

   @ C(005),C(006) Say "Código" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(020),C(007) Say "Data"   Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgx

   @ C(004),C(030) MsGet oGet1 Var cCodigo When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(020),C(030) MsGet oGet2 Var cData                Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx

   @ C(036),C(010) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgx ACTION( ABRECOMPO("I", cCodigo, cData) )
   @ C(036),C(050) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgx ACTION( oDlgx:End() )

   ACTIVATE MSDIALOG oDlgx CENTERED 

Return(.T.)

// Abre tela do Grid dos Componentes que fazem parte da Atualização
Static Function ABRECOMPO( _Tipo, _Codigo, _Data)

   Local cSql      := ""
   Local lChumba   := .F.

   Private xCodigo := _Codigo
   Private xData   := _Data

   Private oGet1
   Private oGet2

   Private aConsulta := {}

   Private oDlga

   If Empty(_data)
      MsgAlert("Data de Atualização não informada. Verifique!")
      Return .T.
   Endif

   If _Tipo == "I"
      oDlgx:End()
   Endif   

   aConsulta := {}
   
   // Carrega o grid
   If Select("T_OBJETO") > 0
      T_OBJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZL_CODI,"
   cSql += "       ZZL_DATA,"
   cSql += "       ZZL_NOME,"
   cSql += "       ZZL_TIPO "
   cSql += "  FROM " + RetSqlName("ZZL")
   cSql += " WHERE ZZL_CODI = '" + Alltrim(xCodigo) + "'"

   If _Tipo == "I"
      cSql += "   AND ZZL_DATA = '" + Dtoc(xData) + "'"
   Else
      cSql += "   AND ZZL_DATA = '" + Alltrim(Substr(xData,07,04) + Substr(xData,04,02) + Substr(xData,01,02))   + "'"
   Endif    
      
   cSql += "   AND ZZL_DELE = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBJETO", .T., .T. )
   
   If !T_OBJETO->( EOF() )

      WHILE !T_OBJETO->( EOF() )

         Do Case
            Case T_OBJETO->ZZL_TIPO == "1"
                 __Tipo := "Fonte"
            Case T_OBJETO->ZZL_TIPO == "2"
                 __Tipo := "Gatilho"
            Case T_OBJETO->ZZL_TIPO == "3"
                 __Tipo := "Ponto de Entrada"
            Case T_OBJETO->ZZL_TIPO == "4"
                 __Tipo := "Tabela"
            Case T_OBJETO->ZZL_TIPO == "5"
                 __Tipo := "Campo de Tabela"
            Case T_OBJETO->ZZL_TIPO == "6"
                 __Tipo := "Configurador"
         EndCase                 

         aAdd( aConsulta, { T_OBJETO->ZZL_NOME, __Tipo } )
         
         T_OBJETO->( DbSkip() )
         
      ENDDO    
      
   Else
   
      aAdd(aConsulta, { '', '' } )
   
   Endif

   DEFINE MSDIALOG oDlga TITLE "Histórico de Atualização do Ambiente de Produção - Protheus" FROM C(178),C(181) TO C(561),C(902) PIXEL

   @ C(005),C(003) Say "Código" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlga
   @ C(005),C(062) Say "Data"   Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlga

   @ C(004),C(023) MsGet oGet1 Var xCodigo When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlga
   @ C(004),C(080) MsGet oGet2 Var xData   When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlga

   @ C(175),C(197) Button "Incluir" Size C(037),C(012) PIXEL OF oDlga ACTION( MANIDADOS("I", xCodigo, xData, "") )
   @ C(175),C(238) Button "Alterar" Size C(037),C(012) PIXEL OF oDlga ACTION( MANIDADOS("A", xCodigo, xData, aConsulta[oConsulta:nAt,01]) )
   @ C(175),C(279) Button "Excluir" Size C(037),C(012) PIXEL OF oDlga ACTION( MANIDADOS("E", xCodigo, xData, aConsulta[oConsulta:nAt,01]) )
   @ C(175),C(318) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlga ACTION( FECHAOBJ() )

   // Desenha o Browse
   oConsulta := TCBrowse():New( 023 , 005, 455, 195,,{'Objeto', 'Tipo' },{20,50,50,50},oDlga,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta)
    
   // Monta a linha a ser exibina no Browse
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01], aConsulta[oConsulta:nAt,02]} }

   ACTIVATE MSDIALOG oDlga CENTERED 

Return(.T.)                                   

// Função que fecha a janela de informações dos Objetos
Static Function FechaObj()

   Local cSql := ""

   oDlga:End() 

   aBrowse := {}
   
   // Pesquisa as Atualizações cadastradas
   
   // Carrega o grid
   If Select("T_OBJETO") > 0
      T_OBJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZL_CODI,"
   cSql += "       ZZL_DATA "
   cSql += "  FROM " + RetSqlName("ZZL")
   cSql += " GROUP BY ZZL_CODI, ZZL_DATA"
   cSql += " ORDER BY ZZL_CODI, ZZL_DATA"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBJETO", .T., .T. )

   If T_OBJETO->( EOF() )
      aAdd(aBrowse, { '', '' } )
   Else
      T_OBJETO->( DbGoTop() )
      WHILE !T_OBJETO->( EOF() )
         aAdd(aBrowse, { T_OBJETO->ZZL_CODI, Substr(T_OBJETO->ZZL_DATA,07,02) + "/" + Substr(T_OBJETO->ZZL_DATA,05,02) + "/" + Substr(T_OBJETO->ZZL_DATA,01,04) } )
         T_OBJETO->( DbSkip() )
      ENDDO
   Endif         

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse)
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }

   oBrowse:bLDblClick := {|| MOSTRADET(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] ) } 

   MOSTRADET(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] )

Return .T.

// Abre a janela de digitação das informações de Inclusão, Alteração ou Exclusão de Registro
Static Function MANIDADOS( _Tipo, _Codigo, _Data, _Objeto)

   Local lChumba     := .F.
   Local cChave      := ""

   Private aComboBx1 := {"1 - Fonte", "2 - Gatilho", "3 - Ponto de Entrada", "4 - Tabela", "5 - Campo de Tabela", "6 - Configurador" }
   Private cComboBx1

   Private jCodigo   := _Codigo
   Private jData	 := _Data
   Private jObjeto	 := Space(20)
   Private jNota	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo1

   Private oDlgj

   If _Tipo <> "I"
      // Pesquisa os dados para display na tela
      If Select("T_ALTERACAO") > 0
         T_ALTERACAO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZL_CODI,"
      cSql += "       ZZL_DATA,"
      cSql += "       ZZL_NOME,"
      cSql += "       ZZL_NOT2,"
      cSql += "       ZZL_TIPO "
      cSql += "  FROM " + RetSqlName("ZZL")
      cSql += " WHERE ZZL_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZZL_DATA = '" + Alltrim(Substr(_Data,07,04) + Substr(_Data,04,02) + Substr(_Data,01,02))   + "'"
      cSql += "   AND ZZL_NOME = '" + Alltrim(_Objeto) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALTERACAO", .T., .T. )

      If !T_ALTERACAO->(EOF())
         jCodigo := T_ALTERACAO->ZZL_CODI
         jData   := T_ALTERACAO->ZZL_DATA 
         jObjeto := T_ALTERACAO->ZZL_NOME
         cChave  := T_ALTERACAO->ZZL_NOT2

         Do Case
            Case T_ALTERACAO->ZZL_TIPO == "1"
                 cComboBx1 := "1 - Fonte"
            Case T_ALTERACAO->ZZL_TIPO == "2"              
                 cComboBx1 := "2 - Gatilho"
            Case T_ALTERACAO->ZZL_TIPO == "3"              
                 cComboBx1 := "3 - Ponto de Entrada"
            Case T_ALTERACAO->ZZL_TIPO == "4"              
                 cComboBx1 := "4 - Tabela"
            Case T_ALTERACAO->ZZL_TIPO == "5"              
                 cComboBx1 := "5 - Campo de Tabela"
            Case T_ALTERACAO->ZZL_TIPO == "6"              
                 cComboBx1 := "6 - Configurador"
         EndCase                 

      Endif

      // Pesquisa o campo memo para display
      If Select("T_NOME") > 0
         T_NOME->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT YP_CHAVE,"
      cSql += "       YP_TEXTO "
      cSql += "  FROM " + RetSqlName("SYP")
      cSql += " WHERE YP_CHAVE = '" + Alltrim(T_ALTERACAO->ZZL_NOT2) + "'"
      cSql += "   AND YP_CAMPO = '" + Alltrim("ZZL_NOT2")            + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOME", .T., .T. )

      If T_NOME->(EOF())
         jNota := ""
      Else
         jNota := ""
         T_NOME->( DbGoTop() )
         WHILE !T_NOME->( EOF() )
            jNota := jNota + Alltrim(STRTRAN(T_NOME->YP_TEXTO, "\13\10", chr(13) + chr(10)))
            T_NOME->( DbSkip() )
         ENDDO
      Endif

   Else
   
      cChave := ""
   
   Endif

   DEFINE MSDIALOG oDlgj TITLE "Histórico de Atualização do Ambiente de Produção - Protheus" FROM C(178),C(181) TO C(490),C(710) PIXEL

   @ C(005),C(003) Say "Código"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgj
   @ C(005),C(036) Say "Data"                  Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgj
   @ C(029),C(035) Say "Objeto"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgj
   @ C(029),C(126) Say "Tipo de Objeto"        Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgj
   @ C(051),C(035) Say "Observações do Objeto" Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgj
   
   @ C(014),C(004) MsGet oGet1 Var jCodigo When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgj
   @ C(014),C(035) MsGet oGet2 Var jData   When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgj

   If _Tipo == "I"
      @ C(039),C(035) MsGet oGet3 Var jObjeto Size C(085),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgj
      @ C(039),C(124) ComboBox cComboBx1 Items aComboBx1 Size C(136),C(010) PIXEL OF oDlgj
   Else
      @ C(039),C(035) MsGet oGet3 Var jObjeto When lChumba Size C(085),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgj
      @ C(039),C(124) ComboBox cComboBx1 Items aComboBx1 When lChumba Size C(136),C(010) PIXEL OF oDlgj
   Endif         

   If _Tipo == "E"
      @ C(061),C(035) GET oMemo1 Var jNota MEMO When lChumba Size C(224),C(075) PIXEL OF oDlgj
   Else
      @ C(061),C(035) GET oMemo1 Var jNota MEMO Size C(224),C(075) PIXEL OF oDlgj      
   Endif   

   @ C(139),C(182) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgj ACTION( SALVADUC( _Tipo, cChave, jNota) ) 
   @ C(139),C(223) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgj ACTION( oDlgj:End() )

   ACTIVATE MSDIALOG oDlgj CENTERED 

Return(.T.)

// Função que grava os dados informados
Static Function SalvaDuc( _TipoSalva, cChave, cObservacao)

   Local cSql := ""

   // Operação de Inclusão
   If _TipoSalva == "I"

      If Empty(Alltrim(jObjeto))
         MsgAlert("Objeto não informado. Verique !!")
         Return .T.
      Endif   

      // Pesquisa se o objeto informado já foi incluído para a atualização
      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZL_CODI,"
      cSql += "       ZZL_DATA,"
      cSql += "       ZZL_NOME "
      cSql += "  FROM " + RetSqlName("ZZL")
      cSql += " WHERE ZZL_CODI = '" + Alltrim(jCodigo) + "'"
      cSql += "   AND ZZL_DATA = '" + Alltrim(jData)   + "'"
      cSql += "   AND ZZL_NOME = '" + Alltrim(jObjeto) + "'"
      cSql += "   AND ZZL_DELE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If T_JATEM->( EOF() )
         // Inseri os dados na Tabela
         aArea := GetArea()

         dbSelectArea("ZZL")
         RecLock("ZZL",.T.)
         ZZL_CODI := jCodigo
         ZZL_DATA := jData
         ZZL_NOME := jObjeto
         ZZL_TIPO := Substr(cComboBx1,01,01)
         MsUnLock()

         // Grava o campo memo da Descrição do Apontamento do Banco de Conhecimento
         MSMM(,80,,jNota,1,,,"ZZL","ZZL_NOT2")
         
      Else
      
         // Elimina da tabela SYP os dados do Campo Texto para receber nova gravação
         dbSelectArea("SYP")
         dbSeek(xFilial("SYP")+cChave)
         If found()
            While SYP->YP_CHAVE==cChave
               Reclock("SYP",.F.)
               dbDelete()
               MsUnlock()
               dbSkip()
            Enddo
         Endif

         aArea := GetArea()

         DbSelectArea("ZZL")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZL") + jCodigo + jObjeto)
            RecLock("ZZL",.F.)

            ZZL_NOME := jObjeto
            ZZL_TIPO := Substr(cComboBx1,01,01)
   
            // Grava o campo memo da Descrição da Solução
            MSMM(,80,,jNota,1,,,"ZZL","ZZL_NOT2")

            MsUnLock()              
         Endif
         
      Endif   

   Endif

   // Operação de Alteração
   If _TipoSalva == "A"

      // Elimina da tabela SYP os dados do Campo Texto para receber nova gravação
      dbSelectArea("SYP")
      dbSeek(xFilial("SYP")+cChave)
      If found()
         While SYP->YP_CHAVE==cChave
            Reclock("SYP",.F.)
            dbDelete()
            MsUnlock()
            dbSkip()
         Enddo
      Endif

      aArea := GetArea()

      DbSelectArea("ZZL")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZL") + jCodigo + jObjeto)
         RecLock("ZZL",.F.)
         // Grava o campo memo da Descrição da Solução
         MSMM(,80,,jNota,1,,,"ZZL","ZZL_NOT2")

         MsUnLock()              
      Endif

   Endif

   // Operação de Exclusão
   If _TipoSalva == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZL")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZL") + jCodigo + jObjeto)
            RecLock("ZZL",.F.)
            ZZL_DELE := "X"
            MsUnLock()              
         Endif

         // Elimina da tabela SYP os dados do Campo Texto
         dbSelectArea("SYP")
         dbSeek(xFilial("SYP")+cChave)
         If found()
            While SYP->YP_CHAVE==cChave
               Reclock("SYP",.F.)
               dbDelete()
               MsUnlock()
               dbSkip()
            Enddo
         Endif

      Endif   

   Endif

   ODlgj:End()

   aConsulta := {}
   
   // Carrega o grid
   If Select("T_OBJETO") > 0
      T_OBJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZL_CODI,"
   cSql += "       ZZL_DATA,"
   cSql += "       ZZL_NOME,"
   cSql += "       ZZL_TIPO "
   cSql += "  FROM " + RetSqlName("ZZL")
   cSql += " WHERE ZZL_CODI = '" + Alltrim(xCodigo) + "'"
   cSql += "   AND ZZL_DATA = '" + Alltrim(xData)   + "'"
   cSql += "   AND ZZL_DELE = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBJETO", .T., .T. )
   
   If !T_OBJETO->( EOF() )

      WHILE !T_OBJETO->( EOF() )

         Do Case
            Case T_OBJETO->ZZL_TIPO == "1"
                 __Tipo := "Fonte"
            Case T_OBJETO->ZZL_TIPO == "2"
                 __Tipo := "Gatilho"
            Case T_OBJETO->ZZL_TIPO == "3"
                 __Tipo := "Ponto de Entrada"
            Case T_OBJETO->ZZL_TIPO == "4"
                 __Tipo := "Tabela"
            Case T_OBJETO->ZZL_TIPO == "5"
                 __Tipo := "Campo de Tabela"
            Case T_OBJETO->ZZL_TIPO == "6"
                 __Tipo := "Configurador"
         EndCase                 

         aAdd( aConsulta, { T_OBJETO->ZZL_NOME, __Tipo } )
         
         T_OBJETIVO->( DbSkip() )
         
      ENDDO    
      
   Else
   
      aAdd(aConsulta, { '', '' } )
   
   Endif

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta)
    
   // Monta a linha a ser exibina no Browse
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01], aConsulta[oConsulta:nAt,02]} }

Return Nil