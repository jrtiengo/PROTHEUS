#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE03.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 09/10/2012                                                          *
// Objetivo..: Programa de Manuten��o do Cadastro de Feriados M�veis               *
//**********************************************************************************

User Function ESPEVE03(_Operacao, _Codigo, _Ano)

   Local lChumba   := .F.

   Private cCodigo := Space(06)
   Private cNome   := Space(40)
   Private cData   := Ctod("  /  /    ")
   Private cTempo  := Space(02)

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
      cSql += "       A.ZZS_DATA  ,"  
      cSql += "       A.ZZS_TEMPO  "        
      cSql += "  FROM " + RetSqlName("ZZS") + " A, "
      cSql += " WHERE A.ZZS_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND A.ZZS_TIPO   = 'M'"
      cSql += "   AND A.ZZS_DELETE = '' "
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )

      cCodigo := T_EVENTOS->ZZS_CODIGO
      cNome	  := T_EVENTOS->ZZS_NOME
      cData   := Ctod(Substr(T_EVENTOS->ZZS_DATA,07,02) + "/" + Substr(T_EVENTOS->ZZS_DATA,05,02) + "/" + Substr(T_EVENTOS->ZZS_DATA,01,04))
      cTempo  := T_EVENTOS->ZZS_TEMPO
                                       
   Endif

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Feriados M�veis" FROM C(178),C(181) TO C(324),C(524) PIXEL

   @ C(005),C(005) Say "C�digo"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(032) Say "Descri��o do Feriado" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(032) Say "Data"                 Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(072) Say "Tempo"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet oGet1 Var cCodigo Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(015),C(032) MsGet oGet2 Var cNome   Size C(132),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(032) MsGet oGet3 Var cData   Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(072) MsGet oGet4 Var cTempo  Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(055),C(052) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaMovel( _Operacao, cCodigo, cNome, cData, cTempo, _Ano) )
   @ C(055),C(090) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que realiza a grava��o dos dados
Static Function _SalvaMovel(_Operacao, _Codigo, _Nome, _Data, _Tempo, _Ano)

   Local cSql := ""

   // Opera��o de Inclus�o
   If _Operacao == "I"

      If Empty(Alltrim(_Nome))
         MsgAlert("Descri��o do Feriado n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(_Data)
         MsgAlert("Data do Feriado n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Tempo))
         MsgAlert("Tempo n�o informado. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o pr�ximo c�digo para inclus�o 
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
      ZZS_DIA    := Strzero(Day(_Data),2)
      ZZS_MES    := Strzero(Month(_Data),2)
      ZZS_DATA   := _Data
      ZZS_DDE    := Ctod("  /  /    ")
      ZZS_DATE   := Ctod("  /  /    ")
      ZZS_TIPO   := "M"
      ZZS_TEMPO  := _Tempo
      ZZS_ANO    := _Ano
      ZZS_DELETE := ""
      MsUnLock()
      
   Endif

   // Opera��o de Altera��o
   If _Operacao == "A"

      If Empty(Alltrim(_Nome))
         MsgAlert("Descri��o do Feriado n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(_Data)
         MsgAlert("Data do Feriado n�o informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Tempo))
         MsgAlert("Tempo n�o informado. Verique !!")
         Return .T.
      Endif   

      aArea := GetArea()

      DbSelectArea("ZZS")
      DbSetOrder(1)
      If DbSeek(cFilAnt + _Codigo)
         RecLock("ZZS",.F.)
         ZZS_NOME   := _Nome
         ZZS_USUA   := Space(20)
         ZZS_DIA    := Strzero(Day(_Data),2)
         ZZS_MES    := Strzero(Month(_Data),2)
         ZZS_DATA   := _Data
         ZZS_DDE    := Ctod("  /  /    ")
         ZZS_DATE   := Ctod("  /  /    ")
         ZZS_TIPO   := "M"
         ZZS_TEMPO  := _Tempo
         ZZS_ANO    := _Ano
         ZZS_DELETE := ""
         MsUnLock()              
      Endif
      
   Endif

   // Opera��o de Exclus�o
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclus�o deste registro?")

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