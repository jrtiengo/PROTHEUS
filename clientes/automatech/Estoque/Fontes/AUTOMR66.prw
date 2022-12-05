#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR66.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/01/2012                                                          *
// Objetivo..: Programa que pesquisa nºs de séries por pedido/nota fiscal          *
//**********************************************************************************

User Function AUTOMR66()

   Private aComboBx1 := {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas"}
   Private aComboBx2 := {"01 - Pedido de Venda", "02 - Nota Fiscal"}
   Private cComboBx1
   Private cComboBx2

   Private cDocumento := Space(10)
   Private cSerie     := Space(03)
   Private cMemo1	  := ""
   Private oGet1
   Private oGet2
   Private oMemo1

   Private aBrowse    := {}  

   Private oDlg

   U_AUTOM628("AUTOMR66")

   aAdd( aBrowse, { '', '', '', '' } )

   DEFINE MSDIALOG oDlg TITLE "Consulta Nº de Séries por Pedido/Nota Fiscal" FROM C(178),C(181) TO C(550),C(821) PIXEL

   @ C(003),C(004) Say "Filial"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(085) Say "Documento" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(138) Say "Tipo"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(202) Say "Série"     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(024),C(005) Say "Produtos do Pedido/Nota Fiscal"                    Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(225) Say "Nºs Séries do produto selecionado"                 Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(170),C(005) Say "DuploClick sobre o produto, pesquisa nº de séries" Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(012),C(004) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
   @ C(012),C(086) MsGet oGet1 Var cDocumento Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(012),C(137) ComboBox cComboBx2 Items aComboBx2 Size C(054),C(010) PIXEL OF oDlg
   @ C(012),C(202) MsGet oGet2 Var cSerie When Substr(cComboBx2,01,02) == "02" Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(033),C(225) GET oMemo1 Var cMemo1 MEMO Size C(088),C(134) PIXEL OF oDlg

   @ C(170),C(225) Button "Exportar para Arquivo TXT" Size C(088),C(012) PIXEL OF oDlg ACTION( EXPORTADOR( aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04] ) )

   @ C(009),C(234) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( TrazSerie( cComboBx1, cDocumento, cComboBx2, cSerie ) )
   @ C(009),C(275) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 040 , 005, 278, 175,,{'Codigo', 'Descrição dos Produtos', 'NFiscal', 'Série'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04] } }
 
   oBrowse:bLDblClick := {|| MOSTRASER(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) } 

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return .T.   

// Função que pesquisa os nºs de séries conforme informações
Static Function TRAZSERIE( cComboBx1, cDocumento, cComboBx2, cSerie )

   If Empty(Alltrim(cDocumento))
      MsgAlert("Documento a ser pesquisado não informado.")
      Return .T.
   Endif

   If Substr(cComboBx2,01,02) == "02"
      If Empty(Alltrim(cSerie))
         MsgAlert("Série do Documento a ser pesquisado não informado.")
         Return .T.
      Endif
   Endif

   // Limpa o campo de nºs de séries para nova carga
   cMemo1 := ""
   oMemo1:Refresh()

   // Limpa o array aBrowse para nova carga
   aBrowse := {}

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04] } }

   // Pesquisa por nº de pedido de venda
   If Substr(cComboBx2,01,02) == "01"

      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := "" 
      cSql := "SELECT A.C6_PRODUTO, "
      cSql += "       A.C6_NOTA   , "
      cSql += "       A.C6_SERIE  , "
      cSql += "       A.C6_NUM    , "
      cSql += "       B.B1_DESC   , "
      cSql += "       B.B1_DAUX     "
      cSql += "  FROM " + RetSqlName("SC6") + " A, "
      cSql += "       " + RetSqlName("SB1") + " B  "
      cSql += " WHERE A.C6_NUM     = '" + Alltrim(cDocumento)              + "'"
      cSql += "   AND A.C6_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
      cSql += "   AND A.C6_PRODUTO = B.B1_COD "
      cSql += "   AND A.R_E_C_D_E_L_ = ''     "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      If !T_PRODUTOS->( EOF() )
         WHILE !T_PRODUTOS->( EOF() )
            aAdd( aBrowse, { T_PRODUTOS->C6_PRODUTO,;
                             Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),;
                             T_PRODUTOS->C6_NUM ,;
                             "" } )
            T_PRODUTOS->( DbSkip() )
         ENDDO
      Endif
   Endif   

   // Pesquisa por nº de nota fiscal
   If Substr(cComboBx2,01,02) == "02"

      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.D2_COD , "
      cSql += "       B.B1_DESC, "
      cSql += "       B.B1_DAUX  "
      cSql += "  FROM " + RetSqlName("SD2") + " A, "
      cSql += "       " + RetSqlName("SB1") + " B  "
      cSql += " WHERE A.D2_COD       = B.B1_COD "
      cSql += "   AND A.D2_DOC       = '" + Alltrim(cDocumento) + "'"
      cSql += "   AND A.D2_SERIE     = '" + Alltrim(cSerie)     + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      If !T_PRODUTOS->( EOF() )
         WHILE !T_PRODUTOS->( EOF() )
            aAdd( aBrowse, { T_PRODUTOS->D2_COD,;
                             Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),;
                             cDocumento,;
                             cSerie} )
            T_PRODUTOS->( DbSkip() )
         ENDDO
      Endif
      
   Endif
      
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04] } }

   oBrowse:bLDblClick := {|| MOSTRASER(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) } 
   
Return .T.         

// Função que pesquisa os nºs de séries do poduto selecionado
Static Function MOSTRASER( _Produto, _Documento, _Serie )

   Local cSql := ""

   cMemo1 := ""

   // Pesquisa por Nº de Pedido de Venda
   If Substr(cComboBx2,01,02) == "01"

      If Select("T_SERIES") > 0
         T_SERIES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DC_NUMSERI"
      cSql += "  FROM " + RetSqlName("SDC")
      cSql += " WHERE DC_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
      cSql += "   AND DC_PEDIDO  = '" + Alltrim(_Documento)     + "'"
      cSql += "   AND DC_PRODUTO = '" + Alltrim(_Produto)       + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

      If T_SERIES->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         If Select("T_SERIES") > 0
            T_SERIES->( dbCloseArea() )
         EndIf
         Return .T.
      Endif   

      // Carrega o Array aBrowse para display
      T_SERIES->( DbGoTop() )
      While !T_SERIES->( EOF() )
         cMemo1 := cMemo1 + T_SERIES->DC_NUMSERI + CHR(10) + CHR(13)
         T_SERIES->( DBSKIP() )
      Enddo

   Else
      // Pesquisa os nº de séries para os parâmetros passados para a função
      If Select("T_SERIES") > 0
         T_SERIES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DB_DOC    , "
      cSql += "       DB_SERIE  , "
      cSql += "       DB_PRODUTO, "
      cSql += "       DB_NUMSERI  "
      cSql += "  FROM " + RetSqlName("SDB")
      cSql += " WHERE DB_DOC     = '" + Alltrim(_Documento) + "'"
      cSql += "   AND DB_SERIE   = '" + Alltrim(_Serie)     + "'"
      cSql += "   AND DB_PRODUTO = '" + Alltrim(_Produto)   + "'"   
 
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

      If T_SERIES->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         If Select("T_SERIES") > 0
            T_SERIES->( dbCloseArea() )
         EndIf
         Return .T.
      Endif   

      // Carrega o Array aBrowse para display
      T_SERIES->( DbGoTop() )
      While !T_SERIES->( EOF() )
         cMemo1 := cMemo1 + T_SERIES->DB_NUMSERI + CHR(10) + CHR(13)
         T_SERIES->( DBSKIP() )
      Enddo
   Endif   

   oMemo1:Refresh()

Return .T.   

// Função que realiza a exportação dos nºs de séries
Static Function EXPORTADOR( _Produto, _Documento, _Serie )

   Local cSql     := ""
   Local aSeries  := {}
   Local aLinha   := {}
   Local nArquivo                
   Local cCaminho := Space(100)

   If Empty(Alltrim(cMemo1))
      MsgAlert("Nenhum nº de série pesquisado para exportação. Verifique!")
      Return .T.
   Endif   

   Private oDlg1

   DEFINE MSDIALOG oDlg1 TITLE "Exportação Nºs de Séries" FROM C(178),C(181) TO C(275),C(612) PIXEL

   @ C(006),C(006) Say "Caminho + Nome do arquivo de exportação" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlg1

   @ C(016),C(007) MsGet oGet1 Var cCaminho Size C(202),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg1

   @ C(029),C(130) Button "Exportar" Size C(037),C(012) PIXEL OF oDlg1 ACTION ( EXPORTASN(_Produto, _Documento, _Serie, cCaminho))
   @ C(029),C(172) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg1 ACTION ( oDlg1:End() )
   
   ACTIVATE MSDIALOG oDlg1 CENTERED 

Return .T.

// Função que realiza a exportação dos nºs de séries
Static Function EXPORTASN( _Produto, _Documento, _Serie, _Caminho )

   Local cSql     := ""
   Local aSeries  := {}
   Local aLinha   := {}
   Local nArquivo                

   If Empty(Alltrim(_Caminho))
      MsgAlert("Necessário informar o caminho de gravação do arquivo de exportação de nºs de séries.")
      Return .T.
   Endif   

   // Pesquisa os nº de séries para os parâmetros passados para a função
   If Select("T_SERIES") > 0
      T_SERIES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DB_DOC    , "
   cSql += "       DB_SERIE  , "
   cSql += "       DB_PRODUTO, "
   cSql += "       DB_NUMSERI  "
   cSql += "  FROM " + RetSqlName("SDB")
   cSql += " WHERE DB_DOC     = '" + Alltrim(_Documento) + "'"
   cSql += "   AND DB_SERIE   = '" + Alltrim(_Serie)     + "'"
   cSql += "   AND DB_PRODUTO = '" + Alltrim(_Produto)   + "'"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

   // Carrega o Array aSeries
   T_SERIES->( DbGoTop() )
   While !T_SERIES->( EOF() )
      aAdd( aSeries, T_SERIES->DB_NUMSERI )
      T_SERIES->( DBSKIP() )
   Enddo

   nArquivo := Fcreate(Alltrim(_Caminho))

   If Ferror() # 0
      MsgAlert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
      lFalha := .t.
   Else
      For nLinha := 1 to len(aSeries)
          fwrite(nArquivo, aSeries[nLinha] + chr(13) + chr(10))
          If ferror() # 0
             MsgAlert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
             lFalha := .t.
          Endif
      Next nLinha
   Endif

   Fclose(nArquivo) 

   MsgAlert("Arquivo exportado com sucesso.")

   oDlg1:End()
   
Return .T.