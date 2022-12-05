#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI10.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Atividades X Áreas                                      *
//**********************************************************************************

User Function ATVATI10(_Operacao, _Filial, _Codigo, _Area, _NomeArea, _Usuario)

   Local lChumba   := .F.
   Local cSql      := ""
   Local _Primeira := ""
   Local lPrimeira := .T.
   Local _Segunda  := ""
   Local lSegunda  := .T.

   Private __Periodo := Space(100)

   If _Operacao == "I"

      // Combo 01 - Atividades da Área Selecionada
      Private aComboBx1	 := {}

      If Select("T_ATIVIDADES") > 0
         T_ATIVIDADES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZU_CODIGO , "
      cSql += "       A.ZZU_NOME     "
      cSql += "  FROM " + RetSqlName("ZZU") + " A  "
      cSql += " WHERE A.ZZU_DELETE = ''"
      cSql += "   AND A.ZZU_AREA LIKE '%" + Alltrim(_Area) + "%'"
      cSql += " ORDER BY A.ZZU_ORDE "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADES", .T., .T. )
   
      If T_ATIVIDADES->( EOF() )
         MsgAlert("Não existem atividades cadastradas para esta área.")
         Return .T.
      Endif
   
      T_ATIVIDADES->( DbGoTop() )
      WHILE !T_ATIVIDADES->( EOF() )
         aAdd(aComboBx1, T_ATIVIDADES->ZZU_CODIGO + " - " + T_ATIVIDADES->ZZU_NOME )
         If lPrimeira
            lPrimeira := .F.
            _Primeira := T_ATIVIDADES->ZZU_CODIGO + " - " + T_ATIVIDADES->ZZU_NOME 
         Endif
         T_ATIVIDADES->( DbSkip() )
      ENDDO

      //Combo 02 - Áreas
      Private aComboBx2	 := {_Area + " - " + Alltrim(_NomeArea) }

      // Combo 03 - Status da Área X Atividade
      Private aComboBx3	 := {"A - Ativo","I - Inativo"}

      // Combo 04 - Cadastro de Usuários
      Private aComboBx4 := { _Usuario }
   
      If Select("T_USUARIOS") > 0
         T_USUARIOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZT_USUA , "
      cSql += "       A.ZZT_NOMR   "
      cSql += "  FROM " + RetSqlName("ZZT") + " A  "
      cSql += " WHERE A.ZZT_DELETE = ''"
      cSql += "   AND A.ZZT_AREA   = '" + Alltrim(_Area)    + "'"
      cSql += "   AND A.ZZT_USUA   = '" + Alltrim(_Usuario) + "'"
      cSql += " ORDER BY A.ZZT_NOMS "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )
   
      Private cRespon := T_USUARIOS->ZZT_NOMR

      // Declaração das Variáveis Privadas
      Private cComboBx1
      Private cComboBx2
      Private cComboBx3
      Private cComboBx4

      Private cCodigo  := _Codigo
      Private cFilial  := _Filial
      Private cData    := Date()
      Private cparaq   := Space(40)
      Private cDetalhe := ""

      Private oGet1
      Private oGet4
      Private oGet5
      Private oGet6
      Private oMemo1

   Else

      If Select("T_ATIVIDADE") > 0
         T_ATIVIDADE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZV_FILIAL,"
      cSql += "       A.ZZV_CODIGO,"
      cSql += "       A.ZZV_DATA  ,"
      cSql += "       A.ZZV_AREA  ,"
      cSql += "       A.ZZV_USUA  ,"
      cSql += "       A.ZZV_PARA  ,"
      cSql += "       B.ZZR_NOME  ,"
      cSql += "       A.ZZV_STATUS,"
      cSql += "       A.ZZV_ATIV  ,"
      cSql += "       C.ZZU_NOME   "
      cSql += "  FROM " + RetSqlName("ZZV") + " A, "
      cSql += "       " + RetSqlName("ZZR") + " B, "
      cSql += "       " + RetSqlName("ZZU") + " C  "
      cSql += " WHERE A.ZZV_FILIAL = '" + Alltrim(_Filial)  + "'"
      cSql += "   AND A.ZZV_AREA   = '" + Alltrim(_Area)    + "'"
      cSql += "   AND A.ZZV_CODIGO = '" + Alltrim(_Codigo)  + "'"
      cSql += "   AND A.ZZV_USUA   = '" + Alltrim(_Usuario) + "'"
      cSql += "   AND A.ZZV_DELETE = ''"
      cSql += "   AND A.ZZV_AREA   = B.ZZR_CODIGO"
      cSql += "   AND B.ZZR_DELETE = ''"
      cSql += "   AND A.ZZV_ATIV   = C.ZZU_CODIGO"
      cSql += "   AND C.ZZU_DELETE = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADE", .T., .T. )
      
      If T_ATIVIDADE->( EOF() )
         Return .T.
      Endif
      
      // Combo 01 - Atividades da Área Selecionada
      Private aComboBx1	 := {}
      aAdd(aComboBx1, T_ATIVIDADE->ZZV_ATIV + " - " + Alltrim(T_ATIVIDADE->ZZU_NOME) )
      _Primeira := T_ATIVIDADE->ZZV_ATIV + " - " + Alltrim(T_ATIVIDADE->ZZU_NOME) 

      //Combo 02 - Áreas
      Private aComboBx2	 := {_Area + " - " + Alltrim(_NomeArea) }

      // Combo 03 - Status da Área X Atividade
      Private aComboBx3	 := {"A - Ativo","I - Inativo"}

      // Combo 04 - Cadastro de Usuários
      Private aComboBx4 := {}
      aAdd( acomboBx4, Alltrim(T_ATIVIDADE->ZZV_USUA) )

      // Pesquisa o nome do responsável do usuário
      If Select("T_USUARIOS") > 0
         T_USUARIOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZT_USUA , "
      cSql += "       A.ZZT_NOMR   "
      cSql += "  FROM " + RetSqlName("ZZT") + " A  "
      cSql += " WHERE A.ZZT_DELETE = ''"
      cSql += "   AND A.ZZT_USUA   = '" + Alltrim(T_ATIVIDADE->ZZV_USUA) + "'"
      cSql += "   AND A.ZZT_AREA   = '" + Alltrim(_Area) + "'"
      cSql += " ORDER BY A.ZZT_NOMS "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

      If T_USUARIOS->( EOF() )
         Private cRespon  := ""      
      Else
         Private cRespon  := T_USUARIOS->ZZT_NOMR
      Endif   

      // Declaração das Variáveis Privadas
      Private cComboBx1
      Private cComboBx2
      Private cComboBx3 := IIF(T_ATIVIDADE->ZZV_STATUS == "A", "A - Ativo","I - Inativo")
      Private cComboBx4

      Private cCodigo  := T_ATIVIDADE->ZZV_CODIGO
      Private cFilial  := T_ATIVIDADE->ZZV_FILIAL
      Private cData    := Ctod(Substr(T_ATIVIDADE->ZZV_DATA,07,02) + "/" + Substr(T_ATIVIDADE->ZZV_DATA,05,02) + "/" + Substr(T_ATIVIDADE->ZZV_DATA,01,04))
      Private cparaq   := T_ATIVIDADE->ZZV_PARA
      Private cDetalhe := ""

      Private oGet1
      Private oGet4
      Private oGet5
      Private oGet6
      Private oMemo1

   Endif
   
   Private oDlg

   If _Operacao == "I"
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
         cCodigo := "000001"
         cData   := Date()
      Else                            
         T_NOVO->( DbGoTop() )
         cCodigo := Strzero(INT(VAL(T_NOVO->ZZV_CODIGO)) + 1,6)
         cData   := Date()
      Endif
   Endif

   // Envia para a função que carrega os detalhes da primeira atividade do combo 01
   _Detalhes(_Primeira)
   
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Atividades" FROM C(178),C(181) TO C(499),C(678) PIXEL

   @ C(004),C(006) Say "Código"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(035) Say "Abertura"              Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(077) Say "Área"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(191) Say "Status"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(006) Say "Atividade"             Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(006) Say "Detalhes da Atividade" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(096),C(006) Say "Usuário"               Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(096),C(135) Say "Responsável Usuário"   Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(119),C(006) Say "para Quem"             Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(006) MsGet oGet1 Var cCodigo            When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(035) MsGet oGet4 Var cData              When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(076) ComboBox cComboBx2 Items aComboBx2 When lChumba Size C(106),C(010) PIXEL OF oDlg
   @ C(014),C(191) ComboBox cComboBx3 Items aComboBx3              Size C(052),C(010) PIXEL OF oDlg
   @ C(036),C(006) ComboBox cComboBx1 Items aComboBx1 When IIF(_Operacao == "I", .T., .F.)  Size C(237),C(010) PIXEL OF oDlg VALID(_Detalhes(cComboBx1))
   @ C(059),C(006) GET oMemo1 Var cDetalhe MEMO       When lChumba Size C(237),C(034) PIXEL OF oDlg
   @ C(105),C(006) ComboBox cComboBx4 Items aComboBx4 When lChumba Size C(124),C(010) PIXEL OF oDlg
   @ C(105),C(135) MsGet oGet5 Var cRespon            When lChumba Size C(107),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(128),C(006) MsGet oGet6  Var cparaq                         Size C(107),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlg

   @ C(125),C(135) Button "Parâmetros de Agendamento"  When _Operacao == "I" Size C(107),C(012) PIXEL OF oDlg ACTION(_ParPeriodo())
   @ C(144),C(006) Button "Troca de Usuário"           When _Operacao <> "I" Size C(056),C(012) PIXEL OF oDlg ACTION(_TrocaUsuario(cComboBx2, cComboBx1, cComboBx4, cData, cCodigo))
   @ C(144),C(088) Button "S A L V A R"                                      Size C(091),C(012) PIXEL OF oDlg ACTION(_SalvaAgenda(_Operacao, _Filial))
   @ C(144),C(205) Button "Voltar"                                           Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que permite a troca de usuário para a atividade X área
Static Function _TrocaUsuario(__Area, __Atividade, __Usuario, __Data, __Codigo)

   Local lFechado  := .F.

   Local aTroca  := {}
   Local cTroca

   Local cGet1	 := __Atividade
   Local cGet2	 := __Usuario
   Local cGet3	 := Ctod("  /  /    ")

   Local oGet1
   Local oGet2
   Local oGet3

   Private aBrowseT   := {}
   Private HouveTroca := .F.

   Private oDlgT

   // Pesquisa os Usuários
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZT_USUA , "
   cSql += "       A.ZZT_NOMR   "
   cSql += "  FROM " + RetSqlName("ZZT") + " A  "
   cSql += " WHERE A.ZZT_DELETE = ''"
   cSql += "   AND A.ZZT_AREA   = '" + Alltrim(Substr(__Area,01,06)) + "'"
   cSql += "   AND A.ZZT_USUA  <> '" + Alltrim(__Usuario)            + "'"
   cSql += " ORDER BY A.ZZT_NOMS "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   WHILE !T_USUARIOS->( EOF() )
      aAdd(aTroca, T_USUARIOS->ZZT_USUA )
      T_USUARIOS->( DbSkip() )
   ENDDO
      
   // Pesquisa as agendas para a atividade e usuário selecionados
   If Select("T_AGENDAS") > 0
      T_AGENDAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZX_FILIAL,"
   cSql += "       ZZX_CODIGO,"
   cSql += "       ZZX_USUA  ,"
   cSql += "       ZZX_MES   ,"
   cSql += "       ZZX_ANO   ,"
   cSql += "       ZZX_DAT1  ,"
   cSql += "       ZZX_DAT2  ,"
   cSql += "       R_E_C_N_O_ "
   cSql += "  FROM " + RetSqlName("ZZX")
   cSql += " WHERE ZZX_USUA   = '" + Alltrim(__Usuario)        + "'"
   cSql += "   AND ZZX_CODIGO = '" + Alltrim(__Codigo)         + "'"
   cSql += "   AND ZZX_ATIV   = '" + Substr(__Atividade,01,06) + "'"
   cSql += "   AND ZZX_ANO    = "  + Alltrim(Str(Year(__Data)))
   cSql += "   AND ZZX_DELETE = ''"
   cSql += "   AND ZZX_REAL   = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDAS", .T., .T. )
   
   T_AGENDAS->( DbGoTop() )
   
   WHILE !T_AGENDAS->( EOF() )
   
      aAdd( aBrowseT, { Substr(T_AGENDAS->ZZX_DAT1,07,02) + "/" + Substr(T_AGENDAS->ZZX_DAT1,05,02) + "/" + Substr(T_AGENDAS->ZZX_DAT1,01,04) ,;
                        T_AGENDAS->ZZX_USUA,;
                        cGet2              ,;
                        Alltrim(Str(T_AGENDAS->R_E_C_N_O_)) } )

      T_AGENDAS->( DbSkip() )

   ENDDO     

   If Len(aBrowseT) == 0
      aAdd( aBrowseT, { '','','' } )         
   Endif   

   DEFINE MSDIALOG oDlgT TITLE "Troca de Usuário (Atividades)" FROM C(178),C(181) TO C(555),C(600) PIXEL

   @ C(005),C(005) Say "Atividade"                                              Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(026),C(005) Say "Usuário Atual da Atividade"                             Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(026),C(110) Say "Trocar para o Usuário"                                  Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(053),C(005) Say "Trocar usuário a partir da data (Inclusive)"            Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(066),C(005) Say "Relação de Atividades permitidas para troca de usuário" Size C(132),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

   @ C(014),C(005) MsGet    oGet1  Var   cGet1  Size C(199),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lFechado
   @ C(035),C(005) MsGet    oGet2  Var   cGet2  Size C(099),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lFechado
   @ C(035),C(110) ComboBox cTroca Items aTroca Size C(095),C(010) PIXEL OF oDlgT
   @ C(052),C(110) MsGet    oGet3  Var   cGet3  Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT

   @ C(172),C(047) Button "Trocar Usuário" Size C(059),C(012) PIXEL OF oDlgT ACTION( _RealizaTroca( cTroca, cGet3 ) )
   @ C(172),C(107) Button "Efetivar Troca" Size C(059),C(012) PIXEL OF oDlgT ACTION( _EfetivaTroca( __Area, __Usuario, __Atividade, __Codigo ) )
   @ C(172),C(167) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   oBrowseT := TCBrowse():New( 095 , 005, 255, 115,,{'Data', 'Usuário Atual', 'Novo Usuário'},{20,50,50,50},oDlgT,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowseT:SetArray(aBrowseT) 
    
   // Monta a linha a ser exibina no Browse
   oBrowseT:bLine := {||{ aBrowseT[oBrowseT:nAt,01],;
                          aBrowseT[oBrowseT:nAt,02],;
                          aBrowseT[oBrowseT:nAt,03],;
                       } }

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// Função que realiza a troca de usuário nas atividades selecionadas
Static Function _RealizaTroca( _TrocauSua, __Data )

   Local nContar := 0

   If Empty(__Data)
      MsgAlert("Necessário informar Data A Partir de para troca.")
      Return .T.
   Endif
      
   For nContar = 1 to lEn(aBrowseT)

       If Ctod(aBrowseT[nContar,01]) >= __Data
          HouveTroca := .T.
          aBrowseT[nContar,03] := _TrocauSua
       Endif
       
   Next nContar
   
   // Seta vetor para a browse                            
   oBrowseT:SetArray(aBrowseT) 
    
   // Monta a linha a ser exibina no Browse
   oBrowseT:bLine := {||{ aBrowseT[oBrowseT:nAt,01],;
                          aBrowseT[oBrowseT:nAt,02],;
                          aBrowseT[oBrowseT:nAt,03],;
                       } }
          
Return(.T.)       

// Função que efetiva a troca de usuário
Static Function _EfetivaTroca(___Area, ___Usuario, ___Atividade, __Codigo)

   Local cSql     := ""
   Local nContar  := 0
   Local xxCodigo := ""
   Local nNovoUsu := ""

   If HouveTroca == .F.
      MsgAlert("Atenção! Não houve troca de usuário para esta atividade. Efetivação não será executada.")
      Return(.T.)
   Endif   

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

   // Grava o novo usuário nos registros da Tabela ZZX010 
   For nContar = 1 to Len(aBrowseT)
       
       If Alltrim(aBrowseT[nContar,02]) == Alltrim(aBrowseT[nContar,03])
          Loop
       Endif   

       nNovoUsu := Alltrim(aBrowseT[nContar,03])

       DbSelectArea("ZZX")
       DbGoTo(val(aBrowseT[nContar,04]))
       RecLock("ZZX",.F.)
       ZZX_CODIGO := xxCodigo
       ZZX_USUA   := aBrowseT[nContar,03]
       MsUnLock()        

   Next nContar
   
   // Pesquisa os dados da Tabela ZZV010 para duplicar para o novo usuário
   If Select("T_DUPLICA") > 0
      T_DUPLICA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZV_FILIAL ," + CHR(13)
   cSql += "       ZZV_CODIGO ," + CHR(13)
   cSql += "       ZZV_DATA   ," + CHR(13)
   cSql += "       ZZV_AREA   ," + CHR(13)
   cSql += "       ZZV_STATUS ," + CHR(13)
   cSql += "       ZZV_ATIV   ," + CHR(13)
   cSql += "       ZZV_USUA   ," + CHR(13)
   cSql += "       ZZV_PERI   ," + CHR(13)
   cSql += "       ZZV_PARA   ," + CHR(13)
   cSql += "       ZZV_DELETE  " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZV")                                       + CHR(13)
   cSql += " WHERE ZZV_AREA   = '" + Alltrim(Substr(___Area,01,06))      + "'" + CHR(13)
   cSql += "   AND ZZV_USUA   = '" + Alltrim(___Usuario)                 + "'" + CHR(13)
   cSql += "   AND ZZV_ATIV   = '" + Alltrim(Substr(___Atividade,01,06)) + "'" + CHR(13)
   cSql += "   AND ZZV_CODIGO = '" + Alltrim(__Codigo)                   + "'" + CHR(13)
   cSql += "   AND ZZV_DELETE = ''"                                            + CHR(13)
 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DUPLICA", .T., .T. )

   // Inseri os dados na Tabela
   dbSelectArea("ZZV")
   RecLock("ZZV",.T.)
   ZZV_FILIAL := T_DUPLICA->ZZV_FILIAL
   ZZV_CODIGO := xxCodigo
   ZZV_DATA   := CTOD(SUBSTR(T_DUPLICA->ZZV_DATA,07,02) + "/" + SUBSTR(T_DUPLICA->ZZV_DATA,05,02) + "/" + SUBSTR(T_DUPLICA->ZZV_DATA,01,04))
   ZZV_AREA   := T_DUPLICA->ZZV_AREA
   ZZV_STATUS := T_DUPLICA->ZZV_STATUS
   ZZV_ATIV   := T_DUPLICA->ZZV_ATIV
   ZZV_USUA   := nNovoUsu
   ZZV_PERI   := T_DUPLICA->ZZV_PERI
   ZZV_PARA   := T_DUPLICA->ZZV_PARA
   ZZV_DELETE := T_DUPLICA->ZZV_DELETE
   MsUnLock()

   MsgAlert("Efetivação da troca de usuário da atividade concluída com sucesso.")
   
   oDlgT:End()
   
Return (.T.)

// Função que pesquisa os detalhes da Atividade
Static Function _Detalhes( _Atividade )

   Local cSql   := ""
   Local cTexto := ""

   If Select("T_ATIVIDADE") > 0
      T_ATIVIDADE->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT A.ZZU_CODIGO, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZU_DETA)) AS DETALHE"
   cSql += "  FROM " + RetSqlName("ZZU") + " A "
   cSql += " WHERE A.ZZU_DELETE = ''"     
   cSql += "   AND A.ZZU_CODIGO = '" + Alltrim(Substr(_Atividade,01,06)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADE", .T., .T. )

   If T_ATIVIDADE->( EOF() )
      Return .T.
   Endif
      
   cDetalhe := T_ATIVIDADE->DETALHE

Return .T.

// Função que pesquisa o Responsável do Usuário selecionado
Static Function _Responsavel( __Usuario )

   Local cSql   := ""
   Local cTexto := ""

   If Select("T_CHEFE") > 0
      T_CHEFE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZT_USUA , "
   cSql += "       A.ZZT_NOMR   "
   cSql += "  FROM " + RetSqlName("ZZT") + " A  "
   cSql += " WHERE A.ZZT_DELETE = ''"
   cSql += "   AND A.ZZT_USUA   = '" + Alltrim(__Usuario) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHEFE", .T., .T. )

   If T_CHEFE->( EOF() )
      cRespon := Space(40)
   Else
      cRespon := T_CHEFE->ZZT_NOMR
   Endif
          
   oGet5:Refresh()

Return .T.

// Função que abre a tela de parametrização da peridiocidade da atividade
Static Function _ParPeriodo()

   If Empty(__Periodo)

      Private cMes	     := 0
      Private cAno       := 0
      Private cQDia01    := 0 
      Private cQDia02    := 0 
      Private cQDia03    := 0 
      Private cQDia04    := 0 
      Private cMDia01    := 0
      Private cMDia02    := 0
      Private cADia01    := 0
      Private cADia02    := 0
   
      Private lDiario 	 := .F.
      Private lSemanal   := .F.
      Private lSegunda	 := .F.
      Private lTerca	 := .F.
      Private lQuarta	 := .F.
      Private lQuinta	 := .F.
      Private lSexta  	 := .F.
      Private lSabado	 := .F.
      Private lDomingo	 := .F.
      Private lQuinzenal := .F.
      Private lMensal    := .F.
      Private lAnual     := .F.
      
   Else
      
      Private cMes	     := INT(VAL(U_P_CORTA(__Periodo, "|", 21)))
      Private cAno       := INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
      Private cQDia01    := INT(VAL(U_P_CORTA(__Periodo, "|", 11)))
      Private cQDia02    := INT(VAL(U_P_CORTA(__Periodo, "|", 12)))
      Private cQDia03    := INT(VAL(U_P_CORTA(__Periodo, "|", 13)))
      Private cQDia04    := INT(VAL(U_P_CORTA(__Periodo, "|", 14)))
      Private cMDia01    := INT(VAL(U_P_CORTA(__Periodo, "|", 16)))
      Private cMDia02    := INT(VAL(U_P_CORTA(__Periodo, "|", 17)))
      Private cADia01    := INT(VAL(U_P_CORTA(__Periodo, "|", 19)))
      Private cADia02    := INT(VAL(U_P_CORTA(__Periodo, "|", 20)))
   
      Private lDiario 	 := IIF(U_P_CORTA(__Periodo, "|",  1) == "T", .T., .F.)
      Private lSemanal   := IIF(U_P_CORTA(__Periodo, "|",  2) == "T", .T., .F.)
      Private lSegunda	 := IIF(U_P_CORTA(__Periodo, "|",  3) == "T", .T., .F.)
      Private lTerca	 := IIF(U_P_CORTA(__Periodo, "|",  4) == "T", .T., .F.)
      Private lQuarta	 := IIF(U_P_CORTA(__Periodo, "|",  5) == "T", .T., .F.)
      Private lQuinta	 := IIF(U_P_CORTA(__Periodo, "|",  6) == "T", .T., .F.)
      Private lSexta  	 := IIF(U_P_CORTA(__Periodo, "|",  7) == "T", .T., .F.)
      Private lSabado	 := IIF(U_P_CORTA(__Periodo, "|",  8) == "T", .T., .F.)
      Private lDomingo	 := IIF(U_P_CORTA(__Periodo, "|",  9) == "T", .T., .F.)
      Private lQuinzenal := IIF(U_P_CORTA(__Periodo, "|", 10) == "T", .T., .F.)
      Private lMensal    := IIF(U_P_CORTA(__Periodo, "|", 15) == "T", .T., .F.)
      Private lAnual     := IIF(U_P_CORTA(__Periodo, "|", 18) == "T", .T., .F.)

   Endif
   
   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oCheckBox4
   Private oCheckBox5
   Private oCheckBox6
   Private oCheckBox7
   Private oCheckBox8
   Private oCheckBox9
   Private oCheckBox10
   Private oCheckBox11
   Private oCheckBox12

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
   
   Private oDlgP

   DEFINE MSDIALOG oDlgP TITLE "Peridiocidade da Atividade" FROM C(178),C(181) TO C(611),C(433) PIXEL

   @ C(007),C(009) CheckBox oCheckBox1 Var lDiario    Prompt "Diário"        Size C(026),C(008) PIXEL OF oDlgP

   @ C(019),C(009) CheckBox oCheckBox2 Var lSemanal   Prompt "Semanal"       Size C(031),C(008) PIXEL OF oDlgP
   @ C(031),C(019) CheckBox oCheckBox3 Var lSegunda   Prompt "Segunda-Feira" Size C(048),C(008) PIXEL OF oDlgP
   @ C(031),C(074) CheckBox oCheckBox4 Var lTerca     Prompt "Terça-Feira"   Size C(048),C(008) PIXEL OF oDlgP
   @ C(043),C(019) CheckBox oCheckBox5 Var lQuarta    Prompt "Quarta-Feira"  Size C(048),C(008) PIXEL OF oDlgP
   @ C(043),C(074) CheckBox oCheckBox6 Var lQuinta    Prompt "Quinta-feira"  Size C(048),C(008) PIXEL OF oDlgP
   @ C(054),C(019) CheckBox oCheckBox7 Var lSexta     Prompt "Sexta-Feira"   Size C(048),C(008) PIXEL OF oDlgP
   @ C(054),C(074) CheckBox oCheckBox8 Var lSabado    Prompt "Sábado"        Size C(048),C(008) PIXEL OF oDlgP
   @ C(066),C(019) CheckBox oCheckBox9 Var lDomingo   Prompt "Domingo"       Size C(048),C(008) PIXEL OF oDlgP

   @ C(081),C(009) CheckBox oCheckBox10 Var lQuinzenal Prompt "Quinzenal" Size C(048),C(008) PIXEL OF oDlgP
   @ C(094),C(019) Say "1ª Quinzena de"    Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(094),C(078) Say "Até"               Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(093),C(059) MsGet oGet3 Var cQDia01 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP
   @ C(093),C(089) MsGet oGet4 Var cQDia02 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP
   @ C(108),C(019) Say "2º Quinzena de"    Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(108),C(079) Say "Até"               Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(107),C(059) MsGet oGet5 Var cQDia03 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP
   @ C(107),C(089) MsGet oGet6 Var cQDia04 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP

   @ C(121),C(009) CheckBox oCheckBox11 Var lMensal Prompt "Mensal" Size C(034),C(008) PIXEL OF oDlgP
   @ C(135),C(019) Say "De"                Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(135),C(049) Say "Até"               Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(134),C(030) MsGet oGet7 Var cMDia01 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP
   @ C(134),C(060) MsGet oGet8 Var cMDia02 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP

   @ C(148),C(009) CheckBox oCheckBox12 Var lAnual Prompt "Anual" Size C(025),C(008) PIXEL OF oDlgP
   @ C(161),C(019) Say "De"                 Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(160),C(048) Say "Até"                Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(160),C(030) MsGet oGet9  Var cADia01 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP
   @ C(160),C(060) MsGet oGet10 Var cADia02 Size C(016),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP

   @ C(181),C(019) Say "A partir  do Mês/Ano" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(180),C(072) MsGet oGet1 Var cMes       Size C(013),C(009) COLOR CLR_BLACK Picture "@E 99"   PIXEL OF oDlgP
   @ C(180),C(087) MsGet oGet2 Var cAno       Size C(022),C(009) COLOR CLR_BLACK Picture "@E 9999" PIXEL OF oDlgP

   @ C(198),C(023) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgP ACTION( _SalvaPar() )
   @ C(198),C(062) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )
  
   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que consiste os dados da tela de parametrização da periodicidade
Static Function _SalvaPar()

   Local cTotal := 0

   If lDiario == .F. .and. lSemanal == .F. .and. lQuinzenal == .F. .and. lMensal == .F. .and. lAnual == .F.
      MsgAlert("Forma de agendamento da atividade não informada.")
      Return .T.
   Endif

   // Permite somente a indicação de uma opção
   If lDiario
      cTotal := cTotal + 1
   Endif
      
   If lSemanal
      cTotal := cTotal + 1
   Endif
   
   If lQuinzenal
      cTotal := cTotal + 1
   Endif
   
   If lMensal
      cTotal := cTotal + 1
   Endif
   
   If lAnual
      cTotal := cTotal + 1
   Endif

   If cTotal > 1
      MsgAlert("Permitido somente a indicação de uma forma de agendamento.")
      Return .T.
   Endif
   
   // Consiste a forma semanal
   If lSemanal
      If !lSegunda .and. !lTerca .and. !lQuarta .and. !lQuinta .and. !lSexta .and. !lSabado .and. !lDomingo
         MsgAlert("Necessário informar o dia da semana para agendamento.")
         Return .T.
      Endif
   Endif   
   
   // Consiste a forma Quinzenal
   If lQuinzenal

      If (cQdia01 + cQdia02 + cQDia03 + cQDia04) == 0
         MsgAlert("Necessário informar os dias do agendamento quinzenal.")
         Return .T.
      Endif
      If cQdia01 == 0
         MsgAlert("Dia De da 1ª Quinzena não informado.")
         Return .T.
      Endif

      If cQdia02 == 0
         MsgAlert("Dia Até da 1ª Quinzena não informado.")
         Return .T.
      Endif

      If cQdia03 == 0
         MsgAlert("Dia De da 2ª Quinzena não informado.")
         Return .T.
      Endif

      If cQdia04 == 0
         MsgAlert("Dia Até da 2ª Quinzena não informado.")
         Return .T.
      Endif

   Endif   

   // Consiste a forma Mensal
   If lMensal

      If (cMDia01 + cMDia02) == 0
         MsgAlert("Necessário informar os dias do agendamento mensal.")
         Return .T.
      Endif

      If cMDia01 == 0
         MsgAlert("Dia De da Forma Mensal não informado.")
         Return .T.
      Endif

      If cMDia02 == 0
         MsgAlert("Dia Até da Forma Mensal não informado.")
         Return .T.
      Endif

   Endif   
      
   // Consiste a forma Anual
   If lAnual

      If (cADia01 + cADia02) == 0
         MsgAlert("Necessário informar os dias do agendamento anual.")
         Return .T.
      Endif

      If cADia01 == 0
         MsgAlert("Dia De da Forma Anual não informado.")
         Return .T.
      Endif

      If cADia02 == 0
         MsgAlert("Dia Até da Forma Anual não informado.")
         Return .T.
      Endif

   Endif   

   // Consiste Mês/Ano
   If (cMes + cAno) == 0
      MsgAlert("A partir do Mês/Ano não informados.")
      Return .T.
   Endif

   If cMes == 0
      MsgAlert("Mês do A partir do Mês/Ano não informado.")
      Return .T.
   Endif

   If cAno == 0
      MsgAlert("Ano do A partir do Mês/Ano não informado.")
      Return .T.
   Endif

   __Periodo := ""
   __Periodo := IIF(lDiario   , "T","F") + "|" + ;
                IIF(lSemanal  , "T","F") + "|" + ;
                IIF(lSegunda  , "T","F") + "|" + ;
                IIF(lTerca    , "T","F") + "|" + ;
                IIF(lQuarta   , "T","F") + "|" + ;
                IIF(lQuinta   , "T","F") + "|" + ;
                IIF(lSexta    , "T","F") + "|" + ;
                IIF(lSabado   , "T","F") + "|" + ;
                IIF(lDomingo  , "T","F") + "|" + ;
                IIF(lQuinzenal, "T","F") + "|" + ;
                Alltrim(Str(cQDia01))    + "|" + ;
                Alltrim(Str(cQDia02))    + "|" + ;
                Alltrim(Str(cQDia03))    + "|" + ;
                Alltrim(Str(cQDia04))    + "|" + ;
                IIF(lMensal, "T","F")    + "|" + ;
                Alltrim(Str(cMDia01))    + "|" + ;
                Alltrim(Str(cMDia02))    + "|" + ;
                IIF(lAnual, "T","F")     + "|" + ;
                Alltrim(Str(cADia01))    + "|" + ;
                Alltrim(Str(cADia02))    + "|" + ;
                Alltrim(Str(cMes))       + "|" + ;
                Alltrim(Str(cAno))       + "|"

   oDlgP:End()

Return .T.

// Função que Grava os dados e gera a agenda
Static Function _SalvaAgenda(_Operacao, _Filial)

   Local cSql     := ""
   Local nContar  := 0
   Local _Data    := Ctod("  /  /    ")
   Local _Inicial := Ctod("  /  /    ")
   Local _Final   := Ctod("  /  /    ")

   // Exclusão de agendamento
   If _Operacao == "E"

      If MsgYesNo("Atenção!!!" + chr(13) + chr(10) + "Todos os agendamentos desta Atividade serão excluídos" + chr(13) + chr(10) + "Confirma a exclusão desta Atividade?")

         aArea := GetArea()

         DbSelectArea("ZZV")
         DbSetOrder(1)
         If DbSeek(_Filial + Alltrim(cCodigo))
            RecLock("ZZV",.F.)
            ZZV_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   // Operação de Inclusão
   If _Operacao == "I"

      // Verifica se a atividade já está cadastrada para a área/usuário
      If Select("T_JAEXISTE") > 0
         T_JAEXISTE->( dbCloseArea() )
      EndIf

      cSql := ""

      cSql := "SELECT ZZV_AREA,"
      cSql += "       ZZV_USUA,"
      cSql += "       ZZV_ATIV "
      cSql += "  FROM " + RetSqlName("ZZV")
      cSql += " WHERE ZZV_AREA   = '" + Alltrim(Substr(cComboBx2,01,06)) + "'"
      cSql += "   AND ZZV_USUA   = '" + Alltrim(cComboBx4)               + "'"
      cSql += "   AND ZZV_ATIV   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
      cSql += "   AND ZZV_DELETE = ''"
 
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

      If !T_JAEXISTE->( EOF() )
         MsgAlert("Atividade já cadastrada para esta Área/Usuário. Verifique !!")
         Return .T.
      Endif

      // Verifica se houve indicação de agendamento para a atividade
      If Empty(Alltrim(__Periodo))
         MsgAlert("Parametrização do Agendamento da Atividade não configurada. Verifique !!")
         Return .T.
      Endif   

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZV")
      RecLock("ZZV",.T.)
      ZZV_FILIAL := cFilAnt
      ZZV_CODIGO := cCodigo
      ZZV_DATA   := cData
      ZZV_AREA   := Substr(cComboBx2,01,06)
      ZZV_STATUS := Substr(cComboBx3,01,01)
      ZZV_ATIV   := Substr(cComboBx1,01,06)
      ZZV_USUA   := Alltrim(cComboBx4)
      ZZV_PERI   := __Periodo
      ZZV_PARA   := cParaq
      ZZV_DELETE := ""
      MsUnLock()

      // Gera os registro de agenda para a Atividade
      If U_P_CORTA(__Periodo, "|", 1) == "T"
    
         _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
         _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

         WHILE .T.

            dbSelectArea("ZZX")
            RecLock("ZZX",.T.)
            ZZX_FILIAL := cFilAnt 
            ZZX_CODIGO := cCodigo
            ZZX_AREA   := Substr(cComboBx2,01,06)
            ZZX_MES    := Month(_Inicial)
            ZZX_ANO    := Year(_inicial)
            ZZX_USUA   := Alltrim(cComboBx4)
            ZZX_STAT   := Substr(cComboBx3,01,01)
            ZZX_ATIV   := Substr(cComboBx1,01,06)
            ZZX_DAT1   := _Inicial
            ZZX_DAT2   := _Inicial
            ZZX_REAL   := Ctod("  /  /    ")
            ZZX_ALCA   := Ctod("  /  /    ")
            ZZX_ATR1   := 0
            ZZX_ATR2   := 0
            ZZX_PROB   := Space(10)
            ZZX_MELH   := Space(10)
            ZZX_NOTA   := Space(10)

            Do Case
               Case Dow(_inicial) == 1
                    ZZX_SEMA   := "Domingo"
               Case Dow(_inicial) == 2
                    ZZX_SEMA   := "Segunda-Feira"
               Case Dow(_inicial) == 3
                    ZZX_SEMA   := "Terça-Feira"
               Case Dow(_inicial) == 4
                    ZZX_SEMA   := "Quarta-Feira"
               Case Dow(_inicial) == 5
                    ZZX_SEMA   := "Quinta-Feira"
               Case Dow(_inicial) == 6
                    ZZX_SEMA   := "Sexta-Feira"
               Case Dow(_inicial) == 7
                    ZZX_SEMA   := "Sábado"
            EndCase                    

            ZZX_DELETE := ""
            MsUnLock()

            _Inicial := _Inicial + 1
            
            If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
               Exit
            Endif

         ENDDO   

      Endif

      // Gera os registro de agenda para a Atividade
      If U_P_CORTA(__Periodo, "|", 2) == "T"

         // Agendas de Domingos
         If U_P_CORTA(__Periodo, "|", 9) == "T"         

            _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
            _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

            WHILE .T.
     
               If Dow(_Inicial) <> 1
                  _Inicial := _Inicial + 1
                  If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                     Exit
                  Else
                     Loop
                  Endif
               Endif
 
               dbSelectArea("ZZX")
               RecLock("ZZX",.T.)
               ZZX_FILIAL := cFilAnt 
               ZZX_CODIGO := cCodigo
               ZZX_AREA   := Substr(cComboBx2,01,06)
               ZZX_MES    := Month(_Inicial)
               ZZX_ANO    := Year(_inicial)
               ZZX_USUA   := Alltrim(cComboBx4)
               ZZX_STAT   := Substr(cComboBx3,01,01)
               ZZX_ATIV   := Substr(cComboBx1,01,06)
               ZZX_DAT1   := _Inicial
               ZZX_DAT2   := _Inicial
               ZZX_REAL   := Ctod("  /  /    ")
               ZZX_ALCA   := Ctod("  /  /    ")
               ZZX_ATR1   := 0
               ZZX_ATR2   := 0
               ZZX_PROB   := Space(10)
               ZZX_MELH   := Space(10)
               ZZX_NOTA   := Space(10)
               ZZX_SEMA   := "Domingo"
               ZZX_DELETE := ""
               MsUnLock()

               _Inicial := _Inicial + 1
            
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Endif

            ENDDO   

         Endif

         // Agendas das Segundas-Feiras
         If U_P_CORTA(__Periodo, "|", 3) == "T"         

            _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
            _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

            WHILE .T.
     
               If Dow(_Inicial) <> 2
                  _Inicial := _Inicial + 1
                  If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                     Exit
                  Else
                     Loop
                  Endif
               Endif
 
               dbSelectArea("ZZX")
               RecLock("ZZX",.T.)
               ZZX_FILIAL := cFilAnt 
               ZZX_CODIGO := cCodigo
               ZZX_AREA   := Substr(cComboBx2,01,06)
               ZZX_MES    := Month(_Inicial)
               ZZX_ANO    := Year(_inicial)
               ZZX_USUA   := Alltrim(cComboBx4)
               ZZX_STAT   := Substr(cComboBx3,01,01)
               ZZX_ATIV   := Substr(cComboBx1,01,06)
               ZZX_DAT1   := _Inicial
               ZZX_DAT2   := _Inicial
               ZZX_REAL   := Ctod("  /  /    ")
               ZZX_ALCA   := Ctod("  /  /    ")
               ZZX_ATR1   := 0
               ZZX_ATR2   := 0
               ZZX_PROB   := Space(10)
               ZZX_MELH   := Space(10)
               ZZX_NOTA   := Space(10)
               ZZX_SEMA   := "Segunda-Feira"
               ZZX_DELETE := ""
               MsUnLock()

               _Inicial := _Inicial + 1
            
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Endif

            ENDDO   

         Endif
         
         // Agendas das Terças-feiras
         If U_P_CORTA(__Periodo, "|", 4) == "T"         

            _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
            _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

            WHILE .T.
     
               If Dow(_Inicial) <> 3
                  _Inicial := _Inicial + 1
                  If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                     Exit
                  Else
                     Loop
                  Endif
               Endif
 
               dbSelectArea("ZZX")
               RecLock("ZZX",.T.)
               ZZX_FILIAL := cFilAnt 
               ZZX_CODIGO := cCodigo
               ZZX_AREA   := Substr(cComboBx2,01,06)
               ZZX_MES    := Month(_Inicial)
               ZZX_ANO    := Year(_inicial)
               ZZX_USUA   := Alltrim(cComboBx4)
               ZZX_STAT   := Substr(cComboBx3,01,01)
               ZZX_ATIV   := Substr(cComboBx1,01,06)
               ZZX_DAT1   := _Inicial
               ZZX_DAT2   := _Inicial
               ZZX_REAL   := Ctod("  /  /    ")
               ZZX_ALCA   := Ctod("  /  /    ")
               ZZX_ATR1   := 0
               ZZX_ATR2   := 0
               ZZX_PROB   := Space(10)
               ZZX_MELH   := Space(10)
               ZZX_NOTA   := Space(10)
               ZZX_SEMA   := "Terça-Feira"
               ZZX_DELETE := ""
               MsUnLock()

               _Inicial := _Inicial + 1
            
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Endif

            ENDDO   

         Endif

         // Agendas das Quartas-Feiras
         If U_P_CORTA(__Periodo, "|", 5) == "T"         

            _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
            _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

            WHILE .T.
     
               If Dow(_Inicial) <> 4
                  _Inicial := _Inicial + 1
                  If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                     Exit
                  Else
                     Loop
                  Endif
               Endif
 
               dbSelectArea("ZZX")
               RecLock("ZZX",.T.)
               ZZX_FILIAL := cFilAnt 
               ZZX_CODIGO := cCodigo
               ZZX_AREA   := Substr(cComboBx2,01,06)
               ZZX_MES    := Month(_Inicial)
               ZZX_ANO    := Year(_inicial)
               ZZX_USUA   := Alltrim(cComboBx4)
               ZZX_STAT   := Substr(cComboBx3,01,01)
               ZZX_ATIV   := Substr(cComboBx1,01,06)
               ZZX_DAT1   := _Inicial
               ZZX_DAT2   := _Inicial
               ZZX_REAL   := Ctod("  /  /    ")
               ZZX_ALCA   := Ctod("  /  /    ")
               ZZX_ATR1   := 0
               ZZX_ATR2   := 0
               ZZX_PROB   := Space(10)
               ZZX_MELH   := Space(10)
               ZZX_NOTA   := Space(10)
               ZZX_SEMA   := "Quarta-Feira"
               ZZX_DELETE := ""
               MsUnLock()

               _Inicial := _Inicial + 1
            
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Endif

            ENDDO   

         Endif

         // Agendas das Quintas-Feiras
         If U_P_CORTA(__Periodo, "|", 6) == "T"         

            _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
            _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

            WHILE .T.
     
               If Dow(_Inicial) <> 5
                  _Inicial := _Inicial + 1
                  If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                     Exit
                  Else
                     Loop
                  Endif
               Endif
 
               dbSelectArea("ZZX")
               RecLock("ZZX",.T.)
               ZZX_FILIAL := cFilAnt 
               ZZX_CODIGO := cCodigo
               ZZX_AREA   := Substr(cComboBx2,01,06)
               ZZX_MES    := Month(_Inicial)
               ZZX_ANO    := Year(_inicial)
               ZZX_USUA   := Alltrim(cComboBx4)
               ZZX_STAT   := Substr(cComboBx3,01,01)
               ZZX_ATIV   := Substr(cComboBx1,01,06)
               ZZX_DAT1   := _Inicial
               ZZX_DAT2   := _Inicial
               ZZX_REAL   := Ctod("  /  /    ")
               ZZX_ALCA   := Ctod("  /  /    ")
               ZZX_ATR1   := 0
               ZZX_ATR2   := 0
               ZZX_PROB   := Space(10)
               ZZX_MELH   := Space(10)
               ZZX_NOTA   := Space(10)
               ZZX_SEMA   := "Quinta-Feira"
               ZZX_DELETE := ""
               MsUnLock()

               _Inicial := _Inicial + 1
            
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Endif

            ENDDO   

         Endif

         // Agendas das Sextas-Feiras
         If U_P_CORTA(__Periodo, "|", 7) == "T"         

            _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
            _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

            WHILE .T.
     
               If Dow(_Inicial) <> 6
                  _Inicial := _Inicial + 1
                  If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                     Exit
                  Else
                     Loop
                  Endif
               Endif
 
               dbSelectArea("ZZX")
               RecLock("ZZX",.T.)
               ZZX_FILIAL := cFilAnt 
               ZZX_CODIGO := cCodigo
               ZZX_AREA   := Substr(cComboBx2,01,06)
               ZZX_MES    := Month(_Inicial)
               ZZX_ANO    := Year(_inicial)
               ZZX_USUA   := Alltrim(cComboBx4)
               ZZX_STAT   := Substr(cComboBx3,01,01)
               ZZX_ATIV   := Substr(cComboBx1,01,06)
               ZZX_DAT1   := _Inicial
               ZZX_DAT2   := _Inicial
               ZZX_REAL   := Ctod("  /  /    ")
               ZZX_ALCA   := Ctod("  /  /    ")
               ZZX_ATR1   := 0
               ZZX_ATR2   := 0
               ZZX_PROB   := Space(10)
               ZZX_MELH   := Space(10)
               ZZX_NOTA   := Space(10)
               ZZX_SEMA   := "Sexta-Feira"
               ZZX_DELETE := ""
               MsUnLock()

               _Inicial := _Inicial + 1
            
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Endif

            ENDDO   

         Endif

         // Agendas de Sábados
         If U_P_CORTA(__Periodo, "|", 8) == "T"         

            _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
            _Final   := Ctod("31/12" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

            WHILE .T.
     
               If Dow(_Inicial) <> 7
                  _Inicial := _Inicial + 1
                  If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                     Exit
                  Else
                     Loop
                  Endif
               Endif
 
               dbSelectArea("ZZX")
               RecLock("ZZX",.T.)
               ZZX_FILIAL := cFilAnt 
               ZZX_CODIGO := cCodigo
               ZZX_AREA   := Substr(cComboBx2,01,06)
               ZZX_MES    := Month(_Inicial)
               ZZX_ANO    := Year(_inicial)
               ZZX_USUA   := Alltrim(cComboBx4)
               ZZX_STAT   := Substr(cComboBx3,01,01)
               ZZX_ATIV   := Substr(cComboBx1,01,06)
               ZZX_DAT1   := _Inicial
               ZZX_DAT2   := _Inicial
               ZZX_REAL   := Ctod("  /  /    ")
               ZZX_ALCA   := Ctod("  /  /    ")
               ZZX_ATR1   := 0
               ZZX_ATR2   := 0
               ZZX_PROB   := Space(10)
               ZZX_MELH   := Space(10)
               ZZX_NOTA   := Space(10)
               ZZX_SEMA   := "Sábado"
               ZZX_DELETE := ""
               MsUnLock()

               _Inicial := _Inicial + 1
            
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Endif

            ENDDO   

         Endif

      Endif

      // Cria a Agenda Quinzenal
      If U_P_CORTA(__Periodo, "|", 10) == "T"

         // Abre Agenda para a Primeira Quinzena
         _Data    := Ctod(Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 11))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

         _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

         WHILE .T.
     
            If Day(_Inicial) <> Int(Val(U_P_CORTA(__Periodo, "|", 12)))
               _Inicial := _Inicial + 1
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Else
                  Loop
               Endif
            Endif
 
            dbSelectArea("ZZX")
            RecLock("ZZX",.T.)
            ZZX_FILIAL := cFilAnt 
            ZZX_CODIGO := cCodigo
            ZZX_AREA   := Substr(cComboBx2,01,06)
            ZZX_MES    := Month(_Inicial)
            ZZX_ANO    := Year(_inicial)
            ZZX_USUA   := Alltrim(cComboBx4)
            ZZX_STAT   := Substr(cComboBx3,01,01)
            ZZX_ATIV   := Substr(cComboBx1,01,06)
            ZZX_DAT1   := Ctod(Strzero(Day(_Data),2) + "/" + Strzero(Month(_Inicial),2) + "/" + Strzero(Year(_inicial),4))
            ZZX_DAT2   := _Inicial
            ZZX_REAL   := Ctod("  /  /    ")
            ZZX_ALCA   := Ctod("  /  /    ")
            ZZX_ATR1   := 0
            ZZX_ATR2   := 0
            ZZX_PROB   := Space(10)
            ZZX_MELH   := Space(10)
            ZZX_NOTA   := Space(10)
            Do Case
               Case Dow(_inicial) == 1
                    ZZX_SEMA   := "Domingo"
               Case Dow(_inicial) == 2
                    ZZX_SEMA   := "Segunda-Feira"
               Case Dow(_inicial) == 3
                    ZZX_SEMA   := "Terça-Feira"
               Case Dow(_inicial) == 4
                    ZZX_SEMA   := "Quarta-Feira"
               Case Dow(_inicial) == 5
                    ZZX_SEMA   := "Quinta-Feira"
               Case Dow(_inicial) == 6
                    ZZX_SEMA   := "Sexta-Feira"
               Case Dow(_inicial) == 7
                    ZZX_SEMA   := "Sábado"
            EndCase                    
                    
            ZZX_DELETE := ""
            MsUnLock()

            _Inicial := _Inicial + 1
            
            If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
               Exit
            Endif

         ENDDO   

         // Abre Agenda para a Segunda Quinzena
         _Data    := Ctod(Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 13))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

         _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

         WHILE .T.
     
            If Day(_Inicial) <> Int(Val(U_P_CORTA(__Periodo, "|", 14)))
               _Inicial := _Inicial + 1
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Else
                  Loop
               Endif
            Endif
 
            dbSelectArea("ZZX")
            RecLock("ZZX",.T.)
            ZZX_FILIAL := cFilAnt 
            ZZX_CODIGO := cCodigo
            ZZX_AREA   := Substr(cComboBx2,01,06)
            ZZX_MES    := Month(_Inicial)
            ZZX_ANO    := Year(_inicial)
            ZZX_USUA   := Alltrim(cComboBx4)
            ZZX_STAT   := Substr(cComboBx3,01,01)
            ZZX_ATIV   := Substr(cComboBx1,01,06)
            ZZX_DAT1   := Ctod(Strzero(Day(_Data),2) + "/" + Strzero(Month(_Inicial),2) + "/" + Strzero(Year(_inicial),4))
//          ZZX_DAT1   := _Data
            ZZX_DAT2   := _Inicial
            ZZX_REAL   := Ctod("  /  /    ")
            ZZX_ALCA   := Ctod("  /  /    ")
            ZZX_ATR1   := 0
            ZZX_ATR2   := 0
            ZZX_PROB   := Space(10)
            ZZX_MELH   := Space(10)
            ZZX_NOTA   := Space(10)
            Do Case
               Case Dow(_inicial) == 1
                    ZZX_SEMA   := "Domingo"
               Case Dow(_inicial) == 2
                    ZZX_SEMA   := "Segunda-Feira"
               Case Dow(_inicial) == 3
                    ZZX_SEMA   := "Terça-Feira"
               Case Dow(_inicial) == 4
                    ZZX_SEMA   := "Quarta-Feira"
               Case Dow(_inicial) == 5
                    ZZX_SEMA   := "Quinta-Feira"
               Case Dow(_inicial) == 6
                    ZZX_SEMA   := "Sexta-Feira"
               Case Dow(_inicial) == 7
                    ZZX_SEMA   := "Sábado"
            EndCase                    
                    
            ZZX_DELETE := ""
            MsUnLock()

            _Inicial := _Inicial + 1
            
            If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
               Exit
            Endif

         ENDDO   

      Endif   

      // Cria a Agenda Mensal
      If U_P_CORTA(__Periodo, "|", 15) == "T"

         // Abre Agenda para a Primeira Quinzena
         _Data    := Ctod(Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 16))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))
                          
         _Inicial := Ctod("01/"   + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

         WHILE .T.
     
            If Day(_Inicial) <> Int(Val(U_P_CORTA(__Periodo, "|", 17)))
               _Inicial := _Inicial + 1
               If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
                  Exit
               Else
                  Loop
               Endif
            Endif
 
            dbSelectArea("ZZX")
            RecLock("ZZX",.T.)
            ZZX_FILIAL := cFilAnt 
            ZZX_CODIGO := cCodigo
            ZZX_AREA   := Substr(cComboBx2,01,06)
            ZZX_MES    := Month(_Inicial)
            ZZX_ANO    := Year(_inicial)
            ZZX_USUA   := Alltrim(cComboBx4)
            ZZX_STAT   := Substr(cComboBx3,01,01)
            ZZX_ATIV   := Substr(cComboBx1,01,06)
//          ZZX_DAT1   := _Data
            ZZX_DAT1   := Ctod(Strzero(Day(_Data),2) + "/" + Strzero(Month(_Inicial),2) + "/" + Strzero(Year(_inicial),4))
            ZZX_DAT2   := _Inicial
            ZZX_REAL   := Ctod("  /  /    ")
            ZZX_ALCA   := Ctod("  /  /    ")
            ZZX_ATR1   := 0
            ZZX_ATR2   := 0
            ZZX_PROB   := Space(10)
            ZZX_MELH   := Space(10)
            ZZX_NOTA   := Space(10)
            Do Case
               Case Dow(_inicial) == 1
                    ZZX_SEMA   := "Domingo"
               Case Dow(_inicial) == 2
                    ZZX_SEMA   := "Segunda-Feira"
               Case Dow(_inicial) == 3
                    ZZX_SEMA   := "Terça-Feira"
               Case Dow(_inicial) == 4
                    ZZX_SEMA   := "Quarta-Feira"
               Case Dow(_inicial) == 5
                    ZZX_SEMA   := "Quinta-Feira"
               Case Dow(_inicial) == 6
                    ZZX_SEMA   := "Sexta-Feira"
               Case Dow(_inicial) == 7
                    ZZX_SEMA   := "Sábado"
            EndCase                    
                    
            ZZX_DELETE := ""
            MsUnLock()

            _Inicial := _Inicial + 1
            
            If Year(_Inicial) <> INT(VAL(U_P_CORTA(__Periodo, "|", 22)))
               Exit
            Endif

         ENDDO   

      Endif   

      // Cria a Agenda Anual
      If U_P_CORTA(__Periodo, "|", 18) == "T"

         // Abre Agenda para a Primeira Quinzena
         _Inicial := Ctod(Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 19))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))

         _Final   := Ctod(Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 20))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 21))),2) + "/" + ;
                          Strzero(INT(VAL(U_P_CORTA(__Periodo, "|", 22))),4))


         dbSelectArea("ZZX")
         RecLock("ZZX",.T.)
         ZZX_FILIAL := cFilAnt 
         ZZX_CODIGO := cCodigo
         ZZX_AREA   := Substr(cComboBx2,01,06)
         ZZX_MES    := Month(_Inicial)
         ZZX_ANO    := Year(_inicial)
         ZZX_USUA   := Alltrim(cComboBx4)
         ZZX_STAT   := Substr(cComboBx3,01,01)
         ZZX_ATIV   := Substr(cComboBx1,01,06)
         ZZX_DAT1   := _Inicial
         ZZX_DAT2   := _Final
         ZZX_REAL   := Ctod("  /  /    ")
         ZZX_ALCA   := Ctod("  /  /    ")
         ZZX_ATR1   := 0
         ZZX_ATR2   := 0
         ZZX_PROB   := Space(10)
         ZZX_MELH   := Space(10)
         ZZX_NOTA   := Space(10)

         Do Case
            Case Dow(_inicial) == 1
                 ZZX_SEMA   := "Domingo"
            Case Dow(_inicial) == 2
                 ZZX_SEMA   := "Segunda-Feira"
            Case Dow(_inicial) == 3
                 ZZX_SEMA   := "Terça-Feira"
            Case Dow(_inicial) == 4
                 ZZX_SEMA   := "Quarta-Feira"
            Case Dow(_inicial) == 5
                 ZZX_SEMA   := "Quinta-Feira"
            Case Dow(_inicial) == 6
                 ZZX_SEMA   := "Sexta-Feira"
            Case Dow(_inicial) == 7
                 ZZX_SEMA   := "Sábado"
         EndCase                    
                   
         ZZX_DELETE := ""
         MsUnLock()

      Endif   
      
   Endif

   // Operação de Atividades
   If _Operacao == "A"

      If SubStr(cComboBx3,01,01) == "I"
         If MsgYesNo("Atenção!!!" + chr(13) + chr(10) + "A Atividade selecionada será INATIVADA" + chr(13) + chr(10) + "Deseja realmente Inativá-la?")
            aArea := GetArea()
            DbSelectArea("ZZV")
            DbSetOrder(1)
            If DbSeek(_Filial + Alltrim(cCodigo))
               RecLock("ZZV",.F.)
               ZZV_STATUS := SubStr(cComboBx3,01,01)
               ZZV_PARA := cParaq
               MsUnLock()              
            Endif   
         Endif
      Else
         aArea := GetArea()
         DbSelectArea("ZZV")
         DbSetOrder(1)
         If DbSeek(_Filial + Alltrim(cCodigo))
            RecLock("ZZV",.F.)
            ZZV_STATUS := SubStr(cComboBx3,01,01)
            ZZV_PARA := cParaq
            MsUnLock()              
         Endif  
      Endif   
      
   Endif

   ODlg:End()

Return Nil