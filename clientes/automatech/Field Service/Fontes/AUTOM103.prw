#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM103.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/04/2012                                                          *
// Objetivo..: Programa que gera o Tracker de Nº de Série por Etiquetas            *
// Parâmetros: _Tipo   - C = Chamado O = Orçamento S = Ordem de Serviço            *
//             _Filial - Código da Filial do Documento                             *
//             _Serie  - Nº de Série a ser pesquisado                              *
//**********************************************************************************

//utilização da função DbTree
User Function AUTOM103(_Tipo, _Filial, _Documento)

   Local cSerie    := ""
   Local oGet1 

   Local cDocu     := Space(10)
   Local oGet2 

   Local aComboBx1  := {"Chamado Técnico", "Orçamento", "Ordem de Serviço"}
   Local cComboBx1   

   Local lChumba   := .F.

   Local cBmp1     := "PMSEDT3" 
   Local cBmp2     := "PMSDOC" 
   Local cSql      := ""
   Local aNotas    := {}
   Local nContar   := 0
   Local nDireita  := 0
   Local nEsquerda := 0

   Private oDlg 
   Private oDBTree 

   // Pesquisa pelo chamado
   If _Tipo == "C"
      If Select("T_SERIE") > 0
         T_SERIE->( dbCloseArea() )
      EndIf
     
      cSql := ""
      cSql := "SELECT AB2_FILIAL,"
      cSql += "       AB2_NRCHAM,"
      cSql += "       AB2_NUMSER "
      cSql += "  FROM " + RetSqlName("AB2")
      cSql += " WHERE AB2_FILIAL = '" + Alltrim(_Filial)    + "'"
      cSql += "   AND AB2_NRCHAM = '" + Alltrim(_Documento) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

      If T_SERIE->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif
      
      cSerie := T_SERIE->AB2_NUMSER

   Endif         

   // Pesquisa pelo Orçamento
   If _Tipo == "O"
      If Select("T_SERIE") > 0
         T_SERIE->( dbCloseArea() )
      EndIf
     
      cSql := ""
      cSql := "SELECT AB4_FILIAL,"
      cSql += "       AB4_NUMORC,"
      cSql += "       AB4_NUMSER "
      cSql += "  FROM " + RetSqlName("AB4")
      cSql += " WHERE AB4_FILIAL = '" + Alltrim(_Filial)    + "'"
      cSql += "   AND AB4_NUMORC = '" + Alltrim(_Documento) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

      If T_SERIE->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif
      
      cSerie := T_SERIE->AB4_NUMSER

   Endif         

   // Pesquisa pela Ordem de Serviço
   If _Tipo == "S"
      If Select("T_SERIE") > 0
         T_SERIE->( dbCloseArea() )
      EndIf
     
      cSql := ""
      cSql := "SELECT AB7_FILIAL,"
      cSql += "       AB7_NUMOS ,"
      cSql += "       AB7_NUMSER "
      cSql += "  FROM " + RetSqlName("AB7")
      cSql += " WHERE AB7_FILIAL = '" + Alltrim(_Filial)    + "'"
      cSql += "   AND AB7_NUMOS  = '" + Alltrim(_Documento) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

      If T_SERIE->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif
      
      cSerie := T_SERIE->AB7_NUMSER

   Endif         

   // Pesquisa os nº dos documentos a serem mostrados
   If Select("T_RESUMO") > 0
      T_RESUMO->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT A.AB2_FILIAL," + CHR(13)
   cSql += "       A.AB2_NRCHAM," + CHR(13)
   cSql += "       A.AB2_NUMORC," + CHR(13)
   cSql += "       B.AB4_NUMOS ," + CHR(13)
   cSql += "       C.AB1_ETIQUE " + CHR(13)
   cSql += "  FROM " + RetSqlName("AB2") + " A , " + CHR(13)
   cSql += "       " + RetSqlName("AB4") + " B , " + CHR(13)
   cSql += "       " + RetSqlName("AB1") + " C   " + CHR(13)
   cSql += " WHERE A.AB2_FILIAL = '" + Alltrim(_Filial) + "'"    + CHR(13)
   cSql += "   AND A.AB2_NUMSER = '" + Alltrim(cSerie)  + "'"    + CHR(13)
   cSql += "   AND A.AB2_FILIAL = B.AB4_FILIAL"                  + CHR(13)
   cSql += "   AND A.AB2_NRCHAM = SUBSTRING(B.AB4_NRCHAM,01,08)" + CHR(13)
   cSql += "   AND A.AB2_FILIAL = C.AB1_FILIAL                 " + CHR(13)
   cSql += "   AND A.AB2_NRCHAM = C.AB1_NRCHAM                 " + CHR(13)
   cSql += " ORDER BY C.AB1_ETIQUE "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
 
   If T_RESUMO->( EOF() )
      Msgalert("Não existem dados a serem visualizados.")
      Return .T.
   Endif
   
   T_RESUMO->( DbGoTop() )
   WHILE !T_RESUMO->( EOF() )   
      aAdd( aNotas, { T_RESUMO->AB1_ETIQUE, T_RESUMO->AB2_NRCHAM, Substr(T_RESUMO->AB2_NUMORC,01,06), Substr(T_RESUMO->AB4_NUMOS,01,06) } )
      T_RESUMO->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Tracker por Nº Série/Etiquetas" FROM 0,0 TO 500,500 PIXEL 

   @ C(007),C(010) Say "Nº Série" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(185),C(010) Say "Etiqueta:" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(068) Say "Tipo:"     Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(030) MsGet oGet1 Var cSerie When lChumba Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(183),C(035) MsGet oGet2 Var cDocu  Size C(030),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlg
   @ C(184),C(080) ComboBox cComboBx1 Items aComboBx1 Size C(045),C(010) PIXEL OF oDlg
   @ C(182),C(130) Button "Visualiza" Size C(035),C(012) PIXEL OF oDlg ACTION( ABRE_VISAO(_Tipo, _Filial, cDocu) )

   oDBTree := dbTree():New(25,10,230,240,oDlg,,,.T.)                                                               
                                                                                                   
   For nContar = 1 to Len(aNotas)

       oDBTree:AddTree("Etiqueta Nº " + Alltrim(aNotas[nContar,01]) ,.T.,cBmp1,cBmp1,,, Strzero(nContar,02) + ".0")
          oDBTree:AddTreeItem("Chamado Nº "   + Alltrim(aNotas[nContar,02]),cBmp2,,Strzero(nContar,02) + ".1") 
          oDBTree:AddTreeItem("Orçamento Nº " + Alltrim(aNotas[nContar,03]),cBmp2,,Strzero(nContar,02) + ".2") 
          oDBTree:AddTreeItem("O.Serviço Nº " + Alltrim(aNotas[nContar,04]),cBmp2,,Strzero(nContar,02) + ".3") 

   Next nContar

   oDBTree:EndTree() 

   oDBTree:EndTree()    

   @ C(182),C(165) Button "Voltar" Size C(023),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
 
   ACTIVATE MSDIALOG oDlg CENTER 

Return .T.

// Função que abre a tela conforme o botão selecionado
Static Function ABRE_VISAO( xTipo, xFilial, xDocumento)

   Local aIndex   := {}
// Local cFiltro1 := "AB1_FILIAL == '" + Alltrim(xFilial) + "', AB1_NRCHAM == '" + Alltrim(xDocumento) + "'"
// Local cFiltro2 := "AB3_FILIAL == '" + Alltrim(xFilial) + "', AB3_NUMORC == '" + Alltrim(xDocumento) + "'"
// Local cFiltro3 := "AB6_FILIAL == '" + Alltrim(xFilial) + "', AB6_NUMOS  == '" + Alltrim(xDocumento) + "'"
   
   Local cFiltro1 := "AB1_FILIAL == '" + Alltrim(xFilial) + "', AB1_ETIQUE == '" + Alltrim(xDocumento) + "'"
   Local cFiltro2 := "AB3_FILIAL == '" + Alltrim(xFilial) + "', AB3_ETIQUE == '" + Alltrim(xDocumento) + "'"
   Local cFiltro3 := "AB6_FILIAL == '" + Alltrim(xFilial) + "', AB6_ETIQUE  == '" + Alltrim(xDocumento) + "'"

   Private aRotina := {;
                      { "Pesquisar"  , ""         , 0 , 1 },;
                      { "Visualizar" , "AxVisual" , 0 , 2 },;
                      { "Incluir"    , ""         , 0 , 3 },;
                      { "Alterar"    , ""         , 0 , 4 },;
                      { "Excluir"    , ""         , 0 , 5 } ;
                      }

   //Determina a Expressão do Filtro
   Do Case
      Case xTipo == "C"
           Private bFiltraBrw := { || FilBrowse( "AB1" , @aIndex , @cFiltro1 ) } 
           Private cCadastro := "Consulta de Chamados"
      Case xTipo == "O"
           Private bFiltraBrw := { || FilBrowse( "AB3" , @aIndex , @cFiltro2 ) } 
           Private cCadastro := "Consulta Orçamentos"
      Case xTipo == "S"
           Private bFiltraBrw := { || FilBrowse( "AB6" , @aIndex , @cFiltro3 ) } 
           Private cCadastro := "Consulta Ordem de Serviço"

   EndCase        

   //Efetiva o Filtro antes da Chamada a mBrowse
   Eval( bFiltraBrw )    

   Do Case
      Case xTipo == "C"
           mBrowse( 6 , 1 , 22 , 75 , "AB1" )
           EndFilBrw( "AB1" , @aIndex ) //Finaliza o Filtro

      Case xTipo == "O"
           mBrowse( 6 , 1 , 22 , 75 , "AB3", .f. )
           EndFilBrw( "AB3" , @aIndex ) //Finaliza o Filtro

      Case xTipo == "S"
           mBrowse( 6 , 1 , 22 , 75 , "AB6", .f. )
           EndFilBrw( "AB6" , @aIndex ) //Finaliza o Filtro

   EndCase        

Return( NIL )