#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE05.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/10/2012                                                          *
// Objetivo..: Programa de Manutenção do Outros eventos                            *
//**********************************************************************************

User Function ESPEVE05(_Operacao, _Codigo, _Ano)

   Local lChumba   := .F.

   Private cCodigo := Space(06)
   Private cNome   := Space(40)

   Private oGet1
   Private oGet2

   If _Operacao <> "I"

      If Select("T_EVENTOS") > 0
         T_EVENTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZS_CODIGO,"  
      cSql += "       A.ZZS_NOME   "  
      cSql += "  FROM " + RetSqlName("ZZS") + " A "
      cSql += " WHERE A.ZZS_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND A.ZZS_TIPO   = 'O'"
      cSql += "   AND A.ZZS_DELETE = '' "
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

      cCodigo := T_EVENTOS->ZZS_CODIGO
      cNome	  := T_EVENTOS->ZZS_NOME
                                       
   Endif

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Outros Eventos" FROM C(178),C(181) TO C(271),C(521) PIXEL

   @ C(005),C(005) Say "Código"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(032) Say "Descrição do Feriado" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet oGet1 Var cCodigo Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(015),C(032) MsGet oGet2 Var cNome   Size C(132),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(029),C(044) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaOutros( _Operacao, cCodigo, cNome, _Ano) )
   @ C(029),C(083) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaOutros(_Operacao, _Codigo, _Nome, _Ano)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Nome))
         MsgAlert("Descrição do Evento não informado. Verique !!")
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
      ZZS_DIA    := Space(02)
      ZZS_MES    := Space(02)
      ZZS_DATA   := Ctod("  /  /    ")
      ZZS_DDE    := Ctod("  /  /    ")
      ZZS_DATE   := Ctod("  /  /    ")
      ZZS_TIPO   := "O"
      ZZS_ANO    := _Ano
      ZZS_DELETE := ""
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      If Empty(Alltrim(_Nome))
         MsgAlert("Descrição do Evento não informado. Verique !!")
         Return .T.
      Endif   

      aArea := GetArea()

      DbSelectArea("ZZS")
      DbSetOrder(1)
      If DbSeek(cFilAnt + _Codigo)
         RecLock("ZZS",.F.)
         ZZS_NOME   := _Nome
         ZZS_USUA   := Space(20)
         ZZS_DIA    := Space(02)
         ZZS_MES    := Space(02)
         ZZS_DATA   := Ctod("  /  /    ")
         ZZS_DDE    := Ctod("  /  /    ")
         ZZS_DATE   := Ctod("  /  /    ")
         ZZS_TIPO   := "O"
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