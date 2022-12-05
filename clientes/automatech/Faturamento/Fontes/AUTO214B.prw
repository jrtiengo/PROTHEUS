#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTO214B.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/03/2014                                                          *
// Objetivo..: Programa que mostra as Regras de Negócio na tela da consulta de pro-*
//             dutos.
//**********************************************************************************

User Function AUTO214B()

   Local lChumba    := .F.
   Local cSql       := ""

   Private cDetalhe := ""
   Private oMemo1

   Private aRegras  := {}

   Private oDlg

   U_AUTOM628("AUTO214B")
   
   // Pesquisa as regras para display
   If Select("T_REGRAS") > 0
      T_REGRAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS5_CODI,"
   cSql += "       ZS5_TITU "
   cSql += "  FROM " + RetSqlName("ZS5")
   cSql += " WHERE ZS5_DELE = ''"
   cSql += " ORDER BY ZS5_TITU  "    

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REGRAS", .T., .T. )

   If T_REGRAS->( EOF() )
      MsgAlert("Não existem regras de Negócio cadastradas.")
      Return(.T.)
   Endif

   aRegras := {}
      
   T_REGRAS->( DbGoTop() )
   WHILE !T_REGRAS->( EOF() )
      aAdd( aRegras, { T_REGRAS->ZS5_CODI, T_REGRAS->ZS5_TITU } )
      T_REGRAS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Regras de Negócio" FROM C(178),C(181) TO C(631),C(770) PIXEL

   @ C(005),C(001) Jpeg FILE "logoautoma.bmp" Size C(141),C(047) PIXEL NOBORDER OF oDlg

   @ C(022),C(232) Say "REGRAS DE NEGÓCIO"                                  Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(130),C(005) GET oMemo1 Var cDetalhe MEMO Size C(287),C(078) PIXEL OF oDlg
   @ C(115),C(231) Button "Detalhes da Regra"   Size C(058),C(012) PIXEL OF oDlg ACTION( MostraRegra(aRegras[oRegras:nAt,01], aRegras[oRegras:nAt,02]) )
   @ C(211),C(252) Button "Retornar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oRegras := TCBrowse():New( 040 , 005, 368, 105,,{'Código', 'Descrição da Regra'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oRegras:SetArray(aRegras) 
    
   // Monta a linha a ser exibina no Browse
   oRegras:bLine := {||{ aRegras[oregras:nAt,01],;
                         aRegras[oRegras:nAt,02]} }

   MostraRegra(aRegras[oRegras:nAt,01],aRegras[oRegras:nAt,02] )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que mostra o detalhe da regra selecionada
Static Function MostraRegra(_Codigo, _Titulo)

   Local cSql := ""

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZS5_TEXT)) AS DETALHE" 
   cSql += "  FROM " + RetSqlName("ZS5")
   cSql += " WHERE ZS5_CODI = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND ZS5_DELE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   cDetalhe := ""
   
   If T_DETALHE->( EOF() )
      cDetalhe := "REGRA: " + Alltrim(_Titulo) + chr(13) + chr(10) + chr(13) + chr(10)
   Else
      cDetalhe := "REGRA: " + Alltrim(_Titulo) + chr(13) + chr(10) + chr(13) + chr(10) + T_DETALHE->DETALHE
   Endif
   
Return(.T.)