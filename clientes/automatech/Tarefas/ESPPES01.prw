#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPES01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/10/2013                                                          *
// Objetivo..: Programa que realiza a pesquisa de tarefas                          *
//**********************************************************************************

User Function ESPPES01()

   Private aTipo     := {"1 - Código da Tarefa", "2 - Título da Tarefa", "3 - Descrição da Tarefa", "4 - Outras Observações", "5 - Solução Adotada" }
   Private cString	 := Space(250)
   Private cTipo
   Private oMemo1
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

   Private oDlgX

   DEFINE MSDIALOG oDlgx TITLE "Pesquisa de Tarefas" FROM C(178),C(181) TO C(551),C(791) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgx

   @ C(031),C(002) GET oMemo2 Var cMemo2 MEMO Size C(298),C(001) PIXEL OF oDlgx

   @ C(035),C(005) Say "Campo a ser pesquisado"  Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(035),C(081) Say "String a ser pesquisada" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(055),C(005) Say "Resultado da pesquisa"   Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   
   @ C(044),C(005) ComboBox cTipo Items aTipo    Size C(072),C(010)                              PIXEL OF oDlgx
   @ C(044),C(081) MsGet    oGet1 Var   cString  Size C(179),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx

   @ C(041),C(263) Button "Pesquisar"            Size C(037),C(012) PIXEL OF oDlgx ACTION( RodaPesquisa() )
   @ C(171),C(177) Button "Visualizar / Alterar" Size C(082),C(012) PIXEL OF oDlgx ACTION( xTrataOperacao("A", aPesquisa[ oPesquisa:nAt, 02 ]) ) 
   @ C(171),C(262) Button "Voltar"               Size C(037),C(012) PIXEL OF oDlgx ACTION( oDlgX:End() )

   aAdd( aPesquisa, { '1', '', '', '', '' } )

   oPesquisa := TCBrowse():New( 080 , 005, 380, 133,,{'','Codigo', 'Prio', 'Ordenação', 'Título da Tarefa'},{20,50,50,50},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "X", oCancel  ,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                           aPesquisa[oPesquisa:nAt,02]               ,;
                           aPesquisa[oPesquisa:nAt,03]               ,;
                           aPesquisa[oPesquisa:nAt,04]               ,;                         
                           aPesquisa[oPesquisa:nAt,05]               } }

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que roda a pesquisa conforme os parâmetros informados
Static Function RodaPesquisa()

   Local cSql := ""

   If Empty(Alltrim(cString))
      MsgAlert("String de pesquisa não informada.")
      Return(.T.)
   Endif

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL,"                          + CHR(13)
   cSql += "       A.ZZG_CODI  ,"                          + CHR(13)
   cSql += "       A.ZZG_SEQU  ,"                          + CHR(13)
   cSql += "       B.ZZD_NOME  ,"                          + CHR(13)
   cSql += "       A.ZZG_ORDE  ,"                          + CHR(13)
   cSql += "       A.ZZG_TITU  ,"                          + CHR(13)
   cSql += "       E.ZZC_LEGE   "                          + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "          + CHR(13)
   cSql += "       " + RetSqlName("ZZD") + " B, "          + CHR(13)
   cSql += "       " + RetSqlName("ZZC") + " E  "          + CHR(13)
   cSql += " WHERE A.ZZG_DELE  = ''"                       + CHR(13)
   cSql += "   AND ('00000' + A.ZZG_STAT = E.ZZC_CODIGO OR '0000' + A.ZZG_STAT = E.ZZC_CODIGO)" + CHR(13)
   cSql += "   AND A.ZZG_PRIO = B.ZZD_CODIGO "             + CHR(13)

   Do Case
      Case Substr(cTipo,01,01) = "1"
           If U_P_OCCURS(cString, ".", 1) == 0
              cSql += " AND UPPER(A.ZZG_CODI) LIKE '%" + UPPER(Alltrim(cString)) + "%'"
           Else
              cSql += " AND LTRIM(A.ZZG_CODI + '.' + A.ZZG_SEQU) LIKE '%" + UPPER(Alltrim(cString)) + "%'"
           Endif
      Case Substr(cTipo,01,01) = "2"
           cSql += " AND UPPER(A.ZZG_TITU) LIKE '%" + UPPER(Alltrim(cString)) + "%'"
      Case Substr(cTipo,01,01) = "3"
           cSql += " AND UPPER(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000) ,A.ZZG_DES1))) LIKE '%" + UPPER(Alltrim(cString)) + "%'"
      Case Substr(cTipo,01,01) = "4"
           cSql += " AND UPPER(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000) ,A.ZZG_NOT1))) LIKE '%" + UPPER(Alltrim(cString)) + "%'"
      Case Substr(cTipo,01,01) = "5"
           cSql += " AND UPPER(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000) ,A.ZZG_SOL1))) LIKE '%" + UPPER(Alltrim(cString)) + "%'"
   EndCase           

   cSql += " ORDER BY A.ZZG_ORDE " + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      aPsquisa := {}
   Else
      aPesquisa := {}
      WHILE !T_STATUS->( EOF() )
         aAdd( aPesquisa, { T_STATUS->ZZC_LEGE,;
                            Alltrim(T_STATUS->ZZG_CODI) + "." + Alltrim(T_STATUS->ZZG_SEQU) ,;
                            T_STATUS->ZZD_NOME,;
                            T_STATUS->ZZG_ORDE,;
                            T_STATUS->ZZG_TITU} )
         T_STATUS->( DbSkip() )
      ENDDO
   Endif

   If Len(aPesquisa) == 0
      aAdd( aPesquisa, { '1', '', '', '', '' } )
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
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "X", oCancel  ,;
                           If(Alltrim(aPesquisa[oPesquisa:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                           aPesquisa[oPesquisa:nAt,02]               ,;
                           aPesquisa[oPesquisa:nAt,03]               ,;
                           aPesquisa[oPesquisa:nAt,04]               ,;                         
                           aPesquisa[oPesquisa:nAt,05]               } }

Return(.T.)

// Função que abre a tarefa selecionada para visualização
Static Function xTrataOperacao(_Operacao, _Codigo)

   If Empty(Alltrim(_Codigo))
      Return(.T.)
   Endif

   U_ESPTAR02("A", _Codigo)

Return(.T.)