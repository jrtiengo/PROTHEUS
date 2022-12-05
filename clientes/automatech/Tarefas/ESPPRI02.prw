#INCLUDE "PROTHEUS.CH"
#include "TOTVS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRI02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Prioridades de Tarefas        *
//**********************************************************************************

User Function ESPPRI02(_Operacao, _Codigo, _Descricao, _Ordem, _Corx)

   Local lChumba := .F.
   Local cCodigo := Space(06)
   Local cNome	 := Space(40)
   Local cOrdem  := 0
   Local aCores	 := {"1 < Preto"     ,;
                     "2 < Azul"      ,;
                     "3 < Verde"     ,;
                     "4 < Azul Claro",;
                     "5 < Vermelho"  ,;
                     "6 < Magenta"   ,;
                     "7 < Marrom"    ,;
                     "8 < Cinza"     ,;
                     "9 < Branco"    ,;
                     "A > Cinza"     ,;
                     "B > Azul"      ,;
                     "C > Verde"     ,;
                     "D > Azul Claro",;
                     "E > Vermelho"  ,;
                     "F > Magenta"   ,;
                     "G > Amarelo"   ,;
                     "H > Branco"     }
   Local cCores

   Local oGet1
   Local oGet2   
   Local oGet3

   Private oDlg

   cCodigo    := _Codigo
   cNome      := _Descricao
   cOrdem     := _Ordem
   cCores     := _Corx

   Do Case
      Case Alltrim(_Corx) == "1"
           __Cor := "1 < Preto"
      Case Alltrim(_Corx) == "2"
           __Cor := "2 < Azul"
      Case Alltrim(_Corx) == "3"
           __Cor := "3 < Verde"
      Case Alltrim(_Corx) == "4"
           __Cor := "4 < Azul Claro"
      Case Alltrim(_Corx) == "5"
           __Cor := "5 < Vermelho"
      Case Alltrim(_Corx) == "6"
           __Cor := "6 < Magenta"
      Case Alltrim(_Corx) == "7"
           __Cor := "7 < Marrom"
      Case Alltrim(_Corx) == "8"
           __Cor := "8 < Cinza"
      Case Alltrim(_Corx) == "A"
           __Cor := "A > Cinza"
      Case Alltrim(_Corx) == "B"
           __Cor := "B > Azul"
      Case Alltrim(_Corx) == "C"
           __Cor := "C > Verde"
      Case Alltrim(_Corx) == "D"
           __Cor := "D > Azul Claro"           
      Case Alltrim(_Corx) == "E"
           __Cor := "E > Vermelho"
      Case Alltrim(_Corx) == "F"
           __Cor := "F > Magenta"
      Case Alltrim(_Corx) == "G"
           __Cor := "G > Amarelo"
      Case Alltrim(_Corx) == "H"
           __Cor := "H > Branco"
   EndCase                             

   // Desenha a tela da manutenção de prioridade
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Prioridades" FROM C(178),C(181) TO C(316),C(532) PIXEL

   @ C(005),C(005) Say "Código"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(034) Say "Descrição da Prioridade" Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(034) Say "Ordem de Visualização"   Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(098) Say "Cor da prioridade"       Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(013),C(005) MsGet    oGet1  Var   cCodigo Size C(023),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlg
   @ C(013),C(034) MsGet    oGet2  Var   cNome   Size C(134),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlg
   @ C(036),C(034) MsGet    oGet3  Var   cOrdem  Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg
   @ C(036),C(098) ComboBox cCores Items aCores  Size C(069),C(010) PIXEL OF oDlg

   @ C(052),C(048) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaPriori( _Operacao, cCodigo, cNome, cOrdem, cCores ) )
   @ C(052),C(086) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaPriori(_Operacao, _Codigo, _Descricao, _Ordem, _Cores)

   Local cSql    := ""
   Local xCodigo := Space(06)

   If Empty(Alltrim(_Descricao))
      MsgAlert("Descrição não informada. Verique !!")
      Return .T.
   Endif   

   If _Ordem == 0
      MsgAlert("Ordem de Visualização não informada. Verique !!")
      Return .T.
   Endif   

   // Operação de Inclusão
   If _Operacao == "I"

      // Pesquisa o próximo código para inclusão
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZD_CODIGO "
      cSql += "  FROM " + RetSqlName("ZZD")
      cSql += " WHERE ZZD_DELETE = ''"
      cSql += " ORDER BY ZZD_CODIGO DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := Strzero((INT(VAL(T_PROXIMO->ZZD_CODIGO)) + 1),6)
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZD")
      RecLock("ZZD",.T.)
      ZZD_CODIGO := xCodigo
      ZZD_NOME   := _Descricao
      ZZD_ORDE   := _Ordem
      ZZD_COR    := Substr(_Cores,01,01)
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZD")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZD") + _Codigo)
         RecLock("ZZD",.F.)
         ZZD_NOME := _Descricao
         ZZD_ORDE := _Ordem
         ZZD_COR  := Substr(_Cores,01,01)
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZD")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZD") + _Codigo)
            RecLock("ZZD",.F.)
            ZZD_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil

// Função que abre a palheta de cores para seleção
Static Function _PALHETA()

   Local nColorIni := CLR_HRED

   Private oDlgCor

   DEFINE DIALOG oDlgCor TITLE "Exemplo TColorTriangle" FROM 180,180 TO 550,700 PIXEL        

   // Usando Create
   oTColorTriangle1 := tColorTriangle():Create( oDlg  )
   oTColorTriangle1:SetColorIni( nColorIni )

   // Usando New
   oTColorTriangle2 := tColorTriangle():New(100,01,oDlgCor,200,80)
   oTColorTriangle2:SetColorIni( nColorIni )

   ACTIVATE DIALOG oDlgCor CENTERED

Return(.T.)   