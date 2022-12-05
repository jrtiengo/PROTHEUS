#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE04.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/10/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Férias                        *
//**********************************************************************************

User Function ESPEVE04(_Operacao, _Codigo, _Ano)

   Local lChumba     := .F.
   Local nContar     := 0

   Private aComboBx1 := {}
   Private cComboBx1

   Private cCodigo	 := Space(06)
   Private cData1 	 := Ctod("  /  /    ")
   Private cData2 	 := Ctod("  /  /    ")
   Private cNome     := Space(40)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   // Carrega o combo de usuários (Desenvolvedores)
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

   aUsuarios := {}
   WHILE !T_DESENVE->( EOF() )
      aAdd( aComboBx1, Alltrim(T_DESENVE->ZZE_CODIGO) + " - " + Alltrim(T_DESENVE->ZZE_NOME) )
      T_DESENVE->( DbSkip() )
   ENDDO

   If _Operacao <> "I"

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
      cSql += " WHERE A.ZZS_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND A.ZZS_TIPO   = 'F'"
      cSql += "   AND A.ZZS_USUA   = B.ZZE_CODIGO"
      cSql += "   AND B.ZZE_DELETE = '' "
      cSql += "   AND A.ZZS_DELETE = '' "
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

      cCodigo := T_EVENTOS->ZZS_CODIGO
      cData1  := Ctod(Substr(T_EVENTOS->ZZS_DDE,07,02)  + "/" + Substr(T_EVENTOS->ZZS_DDE,05,02)  + "/" + Substr(T_EVENTOS->ZZS_DDE,01,04))
      cData2  := Ctod(Substr(T_EVENTOS->ZZS_DATE,07,02) + "/" + Substr(T_EVENTOS->ZZS_DATE,05,02) + "/" + Substr(T_EVENTOS->ZZS_DATE,01,04))
      cNome   := T_EVENTOS->ZZE_NOME
                                       
   Endif

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Férias" FROM C(178),C(181) TO C(319),C(578) PIXEL

   @ C(005),C(005) Say "Código"     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(033) Say "Usuários"   Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(035) Say "Período de" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(114) Say "Até"        Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet    oGet1     Var   cCodigo   Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   If _Operacao == "I"
      @ C(015),C(033) ComboBox cComboBx1 Items aComboBx1 Size C(160),C(010) PIXEL OF oDlg
   Else   
      @ C(015),C(033) MsGet oGet4 Var cNome Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   Endif   

   @ C(030),C(068) MsGet    oGet2     Var   cData1    Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(127) MsGet    oGet3     Var   cData2    Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(051),C(068) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaFerias( _Operacao, cCodigo, cComboBx1, cData1, cData2, _Ano) )
   @ C(051),C(107) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaFerias(_Operacao, _Codigo, _Combo, _Data1, _Data2, _Ano)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(_Combo)
         MsgAlert("Usuário não selecionado. Verique !!")
         Return .T.
      Endif   

      If Empty(_Data1)
         MsgAlert("Data DE não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(_Data2)
         MsgAlert("Data ATÉ não informada. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o próximo código para inclusão 
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZS_CODIGO"  
      cSql += "  FROM " + RetSqlName("ZZS")
      cSql += "  ORDER BY ZZS_CODIGO DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )
   
      If T_PROXIMO->( EOF() )
         _Codigo := "000001"
      Else
         _Codigo := STRZERO((INT(VAL(T_PROXIMO->ZZS_CODIGO)) + 1),6)
      Endif
         
      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZS")
      RecLock("ZZS",.T.)
      ZZS_FILIAL := cFilAnt
      ZZS_CODIGO := _Codigo
      ZZS_NOME   := Space(40)
      ZZS_USUA   := Substr(_Combo,01,06)
      ZZS_DIA    := Strzero(Day(_Data1),2)
      ZZS_MES    := Strzero(Month(_Data1),2)
      ZZS_DATA   := Ctod("  /  /    ")
      ZZS_DDE    := _Data1
      ZZS_DATE   := _Data2
      ZZS_TIPO   := "F"
      ZZS_TEMPO  := Space(02)
      ZZS_ANO    := _Ano
      ZZS_DELETE := ""
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      If Empty(_Data1)
         MsgAlert("Data DE não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(_Data2)
         MsgAlert("Data ATÉ não informada. Verique !!")
         Return .T.
      Endif   

      aArea := GetArea()

      DbSelectArea("ZZS")
      DbSetOrder(1)
      If DbSeek(cFilAnt + _Codigo)
         RecLock("ZZS",.F.)
         ZZS_NOME   := Space(40)
         ZZS_DIA    := Strzero(Day(_Data1),2)
         ZZS_MES    := Strzero(Month(_Data1),2)
         ZZS_DATA   := Ctod("  /  /    ")
         ZZS_DDE    := _Data1
         ZZS_DATE   := _Data2
         ZZS_TIPO   := "F"
         ZZS_TEMPO  := Space(02)
         ZZS_ANO    := _Ano
         ZZS_DELETE := ""
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZS")
         DbSetOrder(1)
         If DbSeek(cFilAnt + _Codigo)
            RecLock("ZZS",.F.)
            ZZS_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil