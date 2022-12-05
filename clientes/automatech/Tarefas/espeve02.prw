#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/10/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Feriados Fixos                *
//**********************************************************************************

User Function ESPEVE02(_Operacao, _Codigo, _Ano)

   Local lChumba   := .F.

   Private cCodigo := Space(06)
   Private cNome   := Space(40)
   Private cDia	   := Space(02)
   Private cMes    := Space(02)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   If _Operacao <> "I"

      If Select("T_EVENTOS") > 0
         T_EVENTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZS_CODIGO,"  
      cSql += "       A.ZZS_NOME  ,"  
      cSql += "       A.ZZS_DIA   ,"  
      cSql += "       A.ZZS_MES    "        
      cSql += "  FROM " + RetSqlName("ZZS") + " A, "
      cSql += " WHERE A.ZZS_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND A.ZZS_TIPO   = 'X'"
      cSql += "   AND A.ZZS_DELETE = '' "
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

      cCodigo := T_EVENTOS->ZZS_CODIGO
      cNome	  := T_EVENTOS->ZZS_NOME
      cDia    := T_EVENTOS->ZZS_DIA
      cMes    := T_EVENTOS->ZZS_MES
                                       
   Endif

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Feriados Fixos" FROM C(178),C(181) TO C(283),C(523) PIXEL

   @ C(005),C(005) Say "Código"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(032) Say "Descrição do Feriado" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(032) Say "Dia"                  Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(053) Say "Mês"                  Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet oGet1 Var cCodigo Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(015),C(032) MsGet oGet2 Var cNome   Size C(132),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(032) MsGet oGet3 Var cDia    Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(053) MsGet oGet4 Var cMes    Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(033),C(087) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaFixo( _Operacao, cCodigo, cNome, cDia, cMes, _Ano) )
   @ C(033),C(126) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaFixo(_Operacao, _Codigo, _Nome, _Dia, _Mes, _Ano)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Nome))
         MsgAlert("Descrição do Feriado Fixo não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Dia))
         MsgAlert("Dia do Feriado Fixo não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Mes))
         MsgAlert("Mês do Feriado Fixo não informado. Verique !!")
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
      ZZS_NOME   := _Nome
      ZZS_USUA   := Space(20)
      ZZS_DIA    := _Dia
      ZZS_MES    := _Mes
      ZZS_DATA   := Ctod("  /  /    ")
      ZZS_DDE    := Ctod("  /  /    ")
      ZZS_DATE   := Ctod("  /  /    ")
      ZZS_TIPO   := "X"
      ZZS_ANO    := _Ano
      ZZS_DELETE := ""
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      If Empty(Alltrim(_Nome))
         MsgAlert("Descrição do Feriado Fixo não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Dia))
         MsgAlert("Dia do Feriado Fixo não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Mes))
         MsgAlert("Mês do Feriado Fixo não informado. Verique !!")
         Return .T.
      Endif   

      aArea := GetArea()

      DbSelectArea("ZZS")
      DbSetOrder(1)
      If DbSeek(cFilAnt + _Codigo)
         RecLock("ZZS",.F.)
         ZZS_NOME   := _Nome
         ZZS_USUA   := Space(20)
         ZZS_DIA    := _Dia
         ZZS_MES    := _Mes
         ZZS_DATA   := Ctod("  /  /    ")
         ZZS_DDE    := Ctod("  /  /    ")
         ZZS_DATE   := Ctod("  /  /    ")
         ZZS_TIPO   := "X"
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