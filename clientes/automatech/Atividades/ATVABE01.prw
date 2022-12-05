#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVABE01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/10/2012                                                          *
// Objetivo..: Programa que abre novos registros de atividades para ano informado. *
//**********************************************************************************

User Function ATVABE01()

   Local cOrigem  := 0
   Local cDestino := 0

   Local oGet1
   Local oGet2

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Abertura de novos períodos para Atividades" FROM C(178),C(181) TO C(352),C(689) PIXEL

   @ C(005),C(005) Say "Este procedimento tem por finalidade abrir registros de atividades para novo período."                Size C(206),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(014),C(005) Say "Para realizar a abertura informe o Ano a ser aberto."                                                 Size C(121),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(005) Say "Este procedimento somente abrirá novos registros caso não haja nenhum registro para o ano informado." Size C(244),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(057) Say "Informe o Ano de origem dos registros" Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(052),C(057) Say "Abrir registros de Atividades para o ano" Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(038),C(152) MsGet oGet1 Var cOrigem  Size C(035),C(009) COLOR CLR_BLACK Picture "9999" PIXEL OF oDlg
   @ C(052),C(152) MsGet oGet2 Var cDestino Size C(035),C(009) COLOR CLR_BLACK Picture "9999" PIXEL OF oDlg

   @ C(069),C(083) Button "Abrir Registros" Size C(047),C(012) PIXEL OF oDlg ACTION( _AbreNovoPer(cOrigem, cDestino) )
   @ C(069),C(131) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre os registros para o novo período
Static Function _AbreNovoPer(_Origem, _Destino)

   Local cSql     := ""
   Local xxCodigo := ""

   // Verifica se Ano de Origem foi informado
   If _Origem == 0
      MsgAlert("Ano de origem das atividades não informado. Verifique!")
      Return(.T.)
   Endif

   // Verifica se o ano de Destino foi informado
   If _Destino == 0
      MsgAlert("Ano de destino das atividades não informado. Verifique!")
      Return(.T.)
   Endif
   
   // Verifica se existem dados para o ano de origem
   If Select("T_ORIGEM") > 0
      T_ORIGEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZX_ANO "
   cSql += "  FROM " + RetSqlName("ZZX")
   cSql += " WHERE ZZX_DELETE = ''"
   cSql += "   AND ZZX_ANO    = " + Alltrim(Str(_Origem))
   cSql += " GROUP BY ZZX_ANO "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORIGEM", .T., .T. )
   
   If T_ORIGEM->( EOF() )
      MsgAlert("Atenção! Não existem dados a serem utilizados para abertura de novo período para o ano de origem informado. Verifique!")
      Return(.T.)
   Endif

   // Verifica se já existe algum lançamento para o ano informado. Se existir, não permite realizar este procedimento
   If Select("T_DESTINO") > 0
      T_DESTINO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZX_ANO "
   cSql += "  FROM " + RetSqlName("ZZX")
   cSql += " WHERE ZZX_DELETE = ''"
   cSql += "   AND ZZX_ANO    = " + Alltrim(Str(_Destino))

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESTINO", .T., .T. )
   
   If !T_DESTINO->( EOF() )
      MsgAlert("Atenção! Já existe registros de atividades para o Ano de destino informado. Abertura de novos registros não será executado.")
      Return(.T.)
   Endif
      
   // Pesquisa as tarefas a serem criadas
   If Select("T_CABECALHO") > 0
      T_CABECALHO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZV_FILIAL,"
   cSql += "       ZZV_CODIGO,"
   cSql += "       ZZV_DATA  ,"
   cSql += "       ZZV_AREA  ,"
   cSql += "       ZZV_STATUS,"
   cSql += "       ZZV_ATIV  ,"
   cSql += "       ZZV_USUA  ,"
   cSql += "       ZZV_PERI  ,"
   cSql += "       ZZV_PARA  ,"
   cSql += "       ZZV_DELETE "
   cSql += "  FROM " + RetSqlName("ZZV")
   cSql += " WHERE SUBSTRING(ZZV_DATA,01,04) = " + Alltrim(Str(_Origem))
   cSql += "   AND ZZV_DELETE = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CABECALHO", .T., .T. )

   T_CABECALHO->( DbGoTop() )
   
   WHILE !T_CABECALHO->( EOF() )
   
      // Carrega o novo código a ser utilizado na abertura das atividades para o novo usuário
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT ZZV_CODIGO"
      cSql += "  FROM " + RetSqlName("ZZV")
      cSql += " WHERE ZZV_DELETE = ''"
      cSql += " ORDER BY ZZV_CODIGO DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )
      
      If T_NOVO->( EOF() )
         xxCodigo := "000001"
      Else                            
         T_NOVO->( DbGoTop() )
         xxCodigo := Strzero(INT(VAL(T_NOVO->ZZV_CODIGO)) + 1,6)
      Endif
   
      // Abre registros na Tabela ZZV010 - Cabeçalho de Atividades X Usuários
      dbSelectArea("ZZV")
      RecLock("ZZV",.T.)
      ZZV_FILIAL := T_CABECALHO->ZZV_FILIAL
      ZZV_CODIGO := xxCodigo
      ZZV_DATA   := DATE()
      ZZV_AREA   := T_CABECALHO->ZZV_AREA
      ZZV_STATUS := T_CABECALHO->ZZV_STATUS
      ZZV_ATIV   := T_CABECALHO->ZZV_ATIV
      ZZV_USUA   := T_CABECALHO->ZZV_USUA
      ZZV_PERI   := T_CABECALHO->ZZV_PERI
      ZZV_PARA   := T_CABECALHO->ZZV_PARA
      ZZV_DELETE := T_CABECALHO->ZZV_DELETE
      MsUnLock()

      // Pesquisa os dados do ano de origem para ser duplicados para o ano de destino
      If Select("T_CONTEUDO") > 0
         T_CONTEUDO->( dbCloseArea() )
      EndIf
    
      cSql := "" 
      cSql := "SELECT ZZX_FILIAL,"
      cSql += "       ZZX_CODIGO,"
      cSql += "       ZZX_MES   ,"
      cSql += "       ZZX_ANO   ,"
      cSql += "       ZZX_USUA  ,"
      cSql += "       ZZX_STAT  ,"
      cSql += "       ZZX_ATIV  ,"
      cSql += "       ZZX_DAT1  ,"
      cSql += "       ZZX_DAT2  ,"
      cSql += "       ZZX_REAL  ,"
      cSql += "       ZZX_ALCA  ,"
      cSql += "       ZZX_ATR1  ,"
      cSql += "       ZZX_ATR2  ,"
      cSql += "       ZZX_NOTA  ,"
      cSql += "       ZZX_DELETE,"
      cSql += "       ZZX_SEMA  ,"
      cSql += "       ZZX_PROB  ,"
      cSql += "       ZZX_MELH   "
      cSql += "  FROM " + RetSqlName("ZZX")
      cSql += " WHERE ZZX_DELETE = ''"
      cSql += "   AND ZZX_ANO    = "  + Alltrim(Str(_Origem))
      cSql += "   AND ZZX_CODIGO = '" + Alltrim(T_CABECALHO->ZZV_CODIGO) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTEUDO", .T., .T. )

      T_CONTEUDO->( DbGoTop() )
    
      WHILE !T_CONTEUDO->( EOF() )
   
         dbSelectArea("ZZX")
         RecLock("ZZX",.T.)
         ZZX_FILIAL := T_CONTEUDO->ZZX_FILIAL
         ZZX_CODIGO := xxCodigo
         ZZX_MES    := T_CONTEUDO->ZZX_MES
         ZZX_ANO    := _Destino
         ZZX_USUA   := T_CONTEUDO->ZZX_USUA
         ZZX_STAT   := T_CONTEUDO->ZZX_STAT
         ZZX_ATIV   := T_CONTEUDO->ZZX_ATIV
         ZZX_DAT1   := Ctod(Substr(T_CONTEUDO->ZZX_DAT1,07,02) + "/" + Substr(T_CONTEUDO->ZZX_DAT1,05,02) + "/" + Strzero(_Destino,04))
         ZZX_DAT2   := Ctod(Substr(T_CONTEUDO->ZZX_DAT2,07,02) + "/" + Substr(T_CONTEUDO->ZZX_DAT2,05,02) + "/" + Strzero(_Destino,04))
         MsUnLock()

         T_CONTEUDO->( DbSkip() )
      
      ENDDO
      
      T_CABECALHO->( DbSkip() )
      
   ENDDO   

   MsgAlert("Abertura de novo período de atividades para o ano " + Strzero(_Destino) + ", gerado com sucesso.")

   oDlg:End()
   
Return(.T.)