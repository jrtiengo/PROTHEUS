#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRJ01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/10/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Eventos                       *
// Parâmetros: _Ano - Ano dos Eventos a serem pesquisados                          *
//**********************************************************************************

User Function ESPEVE01(_Ano)

   Local cSql      := ""
   Local lPrimeiro := .T.
   Local lChumba   := .F.
   
   Private oDlg

   Private aListBox1 := {}
   Private aListBox2 := {}
   Private aListBox3 := {}
   Private aListBox4 := {}

   Private oListBox1
   Private oListBox2
   Private oListBox3
   Private oListBox4

   Private cAno     := _Ano
   Private oGet1

   // Preenche o ListBox1 - Feriados Fixos
   // ------------------------------------
   If Select("T_EVENTOS") > 0
      T_EVENTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZS_CODIGO,"  
   cSql += "       A.ZZS_NOME  ,"  
   cSql += "       A.ZZS_DIA   ,"  
   cSql += "       A.ZZS_MES    "        
   cSql += "  FROM " + RetSqlName("ZZS") + " A "
   cSql += " WHERE A.ZZS_TIPO   = 'X'"
   cSql += "   AND A.ZZS_DELETE = '' "
   cSql += " ORDER BY A.ZZS_DIA, A.ZZS_MES"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

   // Carrega o Combo das Tarefas
   aListBox1 := {''}
   lPrimeiro := .T.
   T_EVENTOS->( EOF() )
   WHILE !T_EVENTOS->( EOF() )
      If lPrimeiro
         aListBox1 := {}
         lPrimeiro := .F.
      Endif   
      aAdd( aListBox1, T_EVENTOS->ZZS_CODIGO + " - " + Alltrim(T_EVENTOS->ZZS_NOME))
      T_EVENTOS->( DbSkip() )
   ENDDO

   // Preenche o ListBox2 - Feriados Fixos
   // ------------------------------------
   If Select("T_EVENTOS") > 0
      T_EVENTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZS_CODIGO,"  
   cSql += "       A.ZZS_NOME  ,"  
   cSql += "       A.ZZS_DIA   ,"  
   cSql += "       A.ZZS_MES    "        
   cSql += "  FROM " + RetSqlName("ZZS") + " A "
   cSql += " WHERE A.ZZS_TIPO   = 'M'"
   cSql += "   AND A.ZZS_DELETE = '' "
   cSql += "   AND A.ZZS_ANO    = '" + Alltrim(_ano) + "'"
   cSql += " ORDER BY A.ZZS_DIA, A.ZZS_MES"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

   // Carrega o Combo das Tarefas
   aListBox2 := {''}
   lPrimeiro := .T.
   T_EVENTOS->( EOF() )
   WHILE !T_EVENTOS->( EOF() )
      If lPrimeiro
         aListBox2 := {}
         lPrimeiro := .F.
      Endif   
      aAdd( aListBox2, T_EVENTOS->ZZS_CODIGO + " - " + Alltrim(T_EVENTOS->ZZS_NOME))
      T_EVENTOS->( DbSkip() )
   ENDDO

   // Preenche o ListBox3 - Férias
   // ----------------------------
   If Select("T_EVENTOS") > 0
      T_EVENTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZS_CODIGO,"  
   cSql += "       A.ZZS_USUA  ,"  
   cSql += "       A.ZZS_DDE   ,"  
   cSql += "       A.ZZS_DATE  ,"        
   cSql += "       B.ZZE_NOME   "
   cSql += "  FROM " + RetSqlName("ZZS") + " A, "
   cSql += "       " + RetSqlName("ZZE") + " B  "
   cSql += " WHERE A.ZZS_TIPO   = 'F'"
   cSql += "   AND A.ZZS_DELETE = '' "
   cSql += "   AND A.ZZS_USUA   = B.ZZE_CODIGO"
   cSql += "   AND B.ZZE_DELETE = ''"
   cSql += "   AND A.ZZS_ANO    = '" + Alltrim(_ano) + "'"
   cSql += " ORDER BY A.ZZS_DIA, A.ZZS_MES"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

   // Carrega o Combo das Tarefas
   aListBox3 := {''}
   lPrimeiro := .T.
   T_EVENTOS->( EOF() )
   WHILE !T_EVENTOS->( EOF() )
      If lPrimeiro
         aListBox3 := {}
         lPrimeiro := .F.
      Endif   
      aAdd( aListBox3, T_EVENTOS->ZZS_CODIGO + " - " + Alltrim(T_EVENTOS->ZZE_NOME))
      T_EVENTOS->( DbSkip() )
   ENDDO

   // Preenche o ListBox4 - Outros Eventos
   // ------------------------------------
   If Select("T_EVENTOS") > 0
      T_EVENTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZS_CODIGO,"  
   cSql += "       A.ZZS_NOME   "  
   cSql += "  FROM " + RetSqlName("ZZS") + " A "
   cSql += " WHERE A.ZZS_TIPO   = 'O'"
   cSql += "   AND A.ZZS_DELETE = '' "
   cSql += " ORDER BY A.ZZS_NOME"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

   // Carrega o Combo das Tarefas
   aListBox4 := {''}
   lPrimeiro := .T.
   T_EVENTOS->( EOF() )
   WHILE !T_EVENTOS->( EOF() )
      If lPrimeiro
         aListBox4 := {}
         lPrimeiro := .F.
      Endif   
      aAdd( aListBox4, T_EVENTOS->ZZS_CODIGO + " - " + Alltrim(T_EVENTOS->ZZS_NOME))
      T_EVENTOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Eventos" FROM C(178),C(181) TO C(614),C(967) PIXEL

   @ C(003),C(005) Say "FERIADOS FIXOS"  Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(177) Say "FERIADOS MÓVEIS" Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(109),C(005) Say "FÉRIAS"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(109),C(177) Say "OUTROS EVENTOS"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(363) Say "ANO"             Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(050),C(361) MsGet oGet1 Var cAno  Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   // Feriados Fixos
   @ C(096),C(059) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("X", "I", "      ", cAno))
   @ C(096),C(098) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("X", "A", Substr(aListBox1[oListBox1:nAt],01,06), cAno))
   @ C(096),C(136) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("X", "E", Substr(aListBox1[oListBox1:nAt],01,06), cAno))

   // Feriados Móveis
   @ C(096),C(232) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("M", "I", "      ", cAno))
   @ C(096),C(270) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("M", "A", Substr(aListBox2[oListBox2:nAt],01,06), cAno))
   @ C(096),C(309) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("M", "E", Substr(aListBox2[oListBox2:nAt],01,06), cAno))

   // Férias
   @ C(201),C(059) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("F", "I", "      ", cAno))
   @ C(201),C(097) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("F", "A", Substr(aListBox3[oListBox3:nAt],01,06), cAno))
   @ C(201),C(136) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("F", "E", Substr(aListBox3[oListBox3:nAt],01,06), cAno))

   // Outros Eventos
   @ C(201),C(232) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("O", "I", "      ", cAno))
   @ C(201),C(270) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("O", "A", Substr(aListBox4[oListBox4:nAt],01,06), cAno))
   @ C(201),C(309) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreEvento("O", "E", Substr(aListBox4[oListBox4:nAt],01,06), cAno))

   @ C(185),C(351) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha os ListBox
   @ C(013),C(005) ListBox oListBox1 Fields HEADER "Descrição" Size C(169),C(080) Of oDlg Pixel
   @ C(013),C(177) ListBox oListBox2 Fields HEADER "Descrição" Size C(169),C(080) Of oDlg Pixel
   @ C(118),C(005) ListBox oListBox3 Fields HEADER "Descrição" Size C(169),C(080) Of oDlg Pixel
   @ C(118),C(177) ListBox oListBox4 Fields HEADER "Descrição" Size C(169),C(080) Of oDlg Pixel

   oListBox1:SetArray(aListBox1)
   oListBox2:SetArray(aListBox2)
   oListBox3:SetArray(aListBox3)
   oListBox4:SetArray(aListBox4)

   oListBox1:bLine := {|| {aListBox1[oListBox1:nAt]} }
   oListBox2:bLine := {|| {aListBox2[oListBox2:nAt]} }
   oListBox3:bLine := {|| {aListBox3[oListBox3:nAt]} }
   oListBox4:bLine := {|| {aListBox4[oListBox4:nAt]} }
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Chama o programa de manipulação dos dados
Static Function _AbreEvento( _Tipo, _Operacao, _Codigo, __Ano)

   // Evento: Feriados Fixos
   // ----------------------
   If _Tipo == "X"
      U_ESPEVE02(_Operacao, _Codigo, __Ano ) 
   Endif
      
   // Feriados Móveis
   // ---------------
   If _Tipo == "M"
      U_ESPEVE03(_Operacao, _Codigo, __Ano ) 
   Endif
      
   If _Tipo == "F"
      U_ESPEVE04(_Operacao, _Codigo, __Ano ) 
   Endif

   If _Tipo == "O"
      U_ESPEVE05(_Operacao, _Codigo, __Ano) 
   Endif

   oDlg:End()
   U_ESPEVE01(__Ano)

Return .T.   