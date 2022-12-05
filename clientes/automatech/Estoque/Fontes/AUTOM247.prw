#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM247.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/08/2014                                                          *
// Objetivo..: Programa que realiza o bloqueio/desbloqueio de produtos             *
//**********************************************************************************

User Function AUTOM247()

   Local cMemo1	   := ""
   Local oMemo1

   Private cString   := Space(100)
   Private oGet1
   Private aPesquisa := {}

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oDlg

   U_AUTOM628("AUTOM247")
   
   DEFINE MSDIALOG oDlg TITLE "Ativação/Inativação de Produtos" FROM C(178),C(181) TO C(562),C(742) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"  Size C(130),C(026) PIXEL NOBORDER OF oDlg
   @ C(177),C(005) Jpeg FILE "br_verde.bmp"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(177),C(069) Jpeg FILE "br_vermelho.bmp" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO     Size C(274),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Produto a ser pesquisado" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(177),C(018) Say "Produtos Ativados"        Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(177),C(083) Say "Produtos Inativos"        Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(043),C(239) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( TRAZINA() )

   @ C(046),C(005) MsGet oGet1 Var cString Size C(231),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(175),C(167) Button "Ativar / Desativar Produto" Size C(071),C(012) PIXEL OF oDlg ACTION( ConfBloq(aPesquisa[oPesquisa:nAt,01], aPesquisa[oPesquisa:nAt,02], aPesquisa[oPesquisa:nAt,03]) )
   @ C(175),C(239) Button "Voltar"                     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aPesquisa, { '1', '', '' } )

   oPesquisa := TCBrowse():New( 075 , 005, 347, 145,,{'','Codigo', 'Descrição dos Produtos'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oPesquisa:SetArray(aPesquisa) 
    
   // Monta a linha a ser exibina no Browse
   oPesquisa:bLine := {||{ If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "1", oBranco  ,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "2", oVerde   ,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "3", oPink    ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "4", oAmarelo ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "5", oAzul    ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "6", oLaranja ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "7", oPreto   ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "8", oVermelho,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                           aPesquisa[oPesquisa:nAt,02]               ,;
                           aPesquisa[oPesquisa:nAt,03]               } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa a string informada
Static Function TrazIna()

   Local cSql := ""

   If Empty(Alltrim(cString))
      aPesquisa := {}
      aAdd( aPesquisa, { '1', '', '' } )   
      
      // Seta vetor para a browse                            
      oPesquisa:SetArray(aPesquisa) 
    
       // Monta a linha a ser exibina no Browse
      oPesquisa:bLine := {||{ If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "1", oBranco  ,;
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "2", oVerde   ,;
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "3", oPink    ,;                         
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "4", oAmarelo ,;                         
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "5", oAzul    ,;                         
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "6", oLaranja ,;                         
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "7", oPreto   ,;                         
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "8", oVermelho,;
                              If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                              aPesquisa[oPesquisa:nAt,02]               ,;
                              aPesquisa[oPesquisa:nAt,03]               } }
      Return(.T.)
   Endif
   
   If Select("T_PESQUISA") > 0
      T_PESQUISA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD,"
   cSql += "       LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX)) AS DESCRICAO,"
   cSql += "       B1_MSBLQL"
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND B1_DESC LIKE '%" + Alltrim(upper(cString)) + "%'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )
   
   aPesquisa := {}

   T_PESQUISA->( DbGoTop() )
   
   WHILE !T_PESQUISA->( EOF() )
      aAdd(aPesquisa, { IIF(T_PESQUISA->B1_MSBLQL == '1', "8", "2"),;
                        T_PESQUISA->B1_COD                         ,;
                        T_PESQUISA->DESCRICAO })
      T_PESQUISA->( DbSkip() )
   ENDDO

   If Len(aPesquisa) == 0
      aAdd( aPesquisa, { '1', '', '' } )   
   Endif
      
   // Seta vetor para a browse                            
   oPesquisa:SetArray(aPesquisa) 
    
   // Monta a linha a ser exibina no Browse
   oPesquisa:bLine := {||{ If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "1", oBranco  ,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "2", oVerde   ,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "3", oPink    ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "4", oAmarelo ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "5", oAzul    ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "6", oLaranja ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "7", oPreto   ,;                         
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "8", oVermelho,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                           aPesquisa[oPesquisa:nAt,02]               ,;
                           aPesquisa[oPesquisa:nAt,03]               } }

Return(.T.)

// Função que grava o bloqueio/desbloqueio do produto selecionado
Static Function ConfBloq(_Legenda, _Codigo, _Descricao)

   Local cMensagem := ""

   If Empty(Alltrim(_Codigo))
      Return(.T.)
   Endif   

   If _Legenda == "2" 
      cMensagem := "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Confirma a INATIVAÇÃO do produto:" + chr(13) + chr(10) + Alltrim(_Codigo) + " - " + Alltrim(_Descricao)
   Else
      cMensagem := "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Confirma a ATIVAÇÃO do produto:" + chr(13) + chr(10) + Alltrim(_Codigo) + " - " + Alltrim(_Descricao)   
   Endif

   If MsgYesNo(cMensagem)
      DbSelectArea("SB1")
      DbSetOrder(1)
      If DbSeek(xFilial("SB1") + _Codigo)
         RecLock("SB1",.F.)
         If _Legenda == "2"
            B1_MSBLQL := "1"
         Else
            B1_MSBLQL := "2"
         Endif
         MsUnLock()              
      Endif
   Endif
   
//   cString := ""
//   oGet1:Refresh()
   
   TRAZINA()
   
Return(.T.)