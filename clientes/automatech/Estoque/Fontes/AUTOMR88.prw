#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR88.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/03/2012                                                          *
// Objetivo..: Emissão de etiquetas da produção                                    *
//**********************************************************************************

User Function AUTOMR88(_Vendedor)

   Private lChumba   := .F.
   Private aComboBx1 := {"  ", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas"}
   Private cComboBx1
 
   Private aComboBx2 := {"    ", "LPT1", "LPT2", "COM1", "COM2", "COM3"}
   Private cComboBx2

   Private aBrowse   := {}

   Private cProducao := Space(06)
   Private cCliente  := Space(100)

   Private cEtq01	 := Space(05)
   Private cQtd01	 := Space(10)

   Private cEtq02	 := Space(05)
   Private cQtd02	 := Space(10)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private oDlg

   aAdd( aBrowse, { '','' } )

   U_AUTOM628("AUTOMR88")

   DEFINE MSDIALOG oDlg TITLE "Emissão Etiquetas Produção" FROM C(178),C(181) TO C(431),C(841) PIXEL

   @ C(006),C(007) Say "O.Produção" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(113) Say "Filial"     Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(019),C(007) Say "Cliente"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(007) Say "Produto(s)" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(097),C(033) Say "Etiquetas"  Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(097),C(076) Say "Quantidade" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(113),C(033) Say "Etiquetas"  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(113),C(076) Say "Quantidade" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(097),C(180) Say "Porta de Impressão" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(043) MsGet oGet1 Var cProducao          Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(005),C(128) ComboBox cComboBx1 Items aComboBx1 Size C(073),C(010) PIXEL OF oDlg

   @ C(002),C(245) Button "Pesquisa" Size C(037),C(012) PIXEL OF oDlg ACTION(BUSCACAO(cProducao, cComboBx1))
   @ C(002),C(287) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ C(018),C(043) MsGet oGet2 Var cCliente When lChumba Size C(281),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(096),C(008) MsGet oGet3 Var cEtq01 Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(096),C(110) MsGet oGet4 Var cQtd01 Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(111),C(008) MsGet oGet5 Var cEtq02 Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(111),C(110) MsGet oGet6 Var cQtd02 Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(109),C(180) ComboBox cComboBx2 Items aComboBx2 Size C(072),C(010) PIXEL OF oDlg

   @ C(100),C(287) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION(ETQPRODUCAO(cProducao, cCliente, cEtq01, cQtd01, cEtq02, cQtd02, cComboBx2, aBrowse[oBrowse:nAt,01]))

   oBrowse := TCBrowse():New( 050 , 005, 410, 065,,{'Codigo', 'Descrição', 'Etq-01', 'Qtd-01', 'Etq-02','Qtd-02'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02] ;
                        } }
   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return .T.   

// Função que pesquisa a ordem de produção informada
Static Function BUSCACAO(_Producao, _Filial)

   Local cSql := ""
   
   If Empty(_Producao)
      Msgalert("Necessario informar a Ordem de Produção a ser pesquisada.")
      Return .T.
   Endif
   
   If Empty(_Filial)
      Msgalert("Filial não selecionada.")
      Return .T.
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02] ;
                        } }
   oBrowse:Refresh()

   // Pesquisa os dados da Ordem de Podução informada
   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C2_FILIAL ," + CHR(13)
   cSql += "       A.C2_NUM    ," + CHR(13)
   cSql += "       A.C2_PRODUTO," + CHR(13)
   cSql += "       A.C2_PEDIDO ," + CHR(13)
   cSql += "       B.UA_CLIENTE," + CHR(13)
   cSql += "       B.UA_LOJA   ," + CHR(13)
   cSql += "       C.A1_NOME   ," + CHR(13)
   cSql += "       D.B1_DESC   ," + CHR(13)
   cSql += "       D.B1_DAUX    " + CHR(13)
   cSql += "  FROM " + RetSqlName("SC2") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("SUA") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("SB1") + " D  " + CHR(13)
   cSql += " WHERE A.C2_FILIAL    = B.UA_FILIAL"  + CHR(13)
   cSql += "   AND A.C2_PEDIDO    = B.UA_NUMSC5"  + CHR(13)
   cSql += "   AND B.UA_CLIENTE   = C.A1_COD"     + CHR(13)
   cSql += "   AND B.UA_LOJA      = C.A1_LOJA"    + CHR(13)
   cSql += "   AND A.R_E_C_D_E_L_ = ''"           + CHR(13)
   cSql += "   AND A.C2_FILIAL    = '" + Alltrim(Substr(_Filial,01,02)) + "'" + CHR(13)
   cSql += "   AND A.C2_NUM       = '" + Alltrim(_Producao)             + "'" + CHR(13)
   cSql += "   AND A.C2_PRODUTO   = D.B1_COD "    + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   If T_PRODUCAO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para esta Ordem de Produção.")

      cCliente := ""
      cEtq01   := Space(05)
      cQtd01   := Space(10)
      cEtq02   := Space(05)
      cQtd02   := Space(10)

      aBrowse := {}
      aAdd( aBrowse, { '','' } )   


      // Seta vetor para a browse                            
      oBrowse:SetArray(aBrowse) 

      // Monta a linha a ser exibina no Browse
      oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],; // Código
                            aBrowse[oBrowse:nAt,02] ; // Descrição
                        } }
      oBrowse:bLDblClick := {|| CARREGAETQ() } 

      oBrowse:Refresh()

      Return .T.
   Endif

   cCliente := T_PRODUCAO->A1_NOME 

   // Carrega o combo dos produtos da ordem de produção
   aBrowse := {}

   T_PRODUCAO->( DbGoTop() )
   
   WHILE !T_PRODUCAO->( EOF() )     
      aAdd( aBrowse, { Alltrim(T_PRODUCAO->C2_PRODUTO), Alltrim(T_PRODUCAO->B1_DESC) + " " + Alltrim(T_PRODUCAO->B1_DAUX), '','','','' } )
      T_PRODUCAO->( DbSkip() )
   ENDDO   

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],; // Código
                         aBrowse[oBrowse:nAt,02] ; // Descrição
                        } }
   oBrowse:bLDblClick := {|| CARREGAETQ() } 

   oBrowse:Refresh()
   
Return .T.

// Função que Imprime a Etiqueta de Produção conforme parâmetros
Static Function ETQPRODUCAO(_Producao, _Cliente, _Etq01, _Qtd01, _Etq02, _Qtd02, _ComboBx2, _Codigo)

   Local cSql     := ""
   Local cPorta   := _ComboBx2
   Local cEtq01   := Val(_Etq01)
   Local cQtd01   := Val(_Qtd01)
   Local cEtq02   := Val(_Etq02)
   Local cQtd02   := Val(_Qtd02)
   Local nContar  := 0
   Local cTamanho := ""

   If cEtq01 <> 0 .And. cQtd01 == 0
      MsgAlert("Quantidade para primeira etiqueta não informada.")
      Return .T.
   Endif
      
   If cEtq01 == 0 .And. cQtd01 <> 0
      MsgAlert("Quantidade da primeira etiqueta não informada.")
      Return .T.
   Endif

   If cEtq02 <> 0 .And. cQtd02 == 0
      MsgAlert("Quantidade para a segunda etiqueta não informada.")
      Return .T.
   Endif

   If cEtq02 == 0 .And. cQtd02 <> 0
      MsgAlert("Quantidade da segunda etiqueta não informada.")
      Return .T.
   Endif

   If (cEtq01 + cQtd01 + cEtq02 + cQtd02) == 0
      MsgAlert("Necessário informar as quantidades de etiquetas e quantidades a serem impressas.")
      Return .T.
   Endif

   // Verifica se a porta de impressão foi informada
   IF Empty(Alltrim(cPorta))
      MsgAlert("Porta de Impressão não informada.")
      Return .T.
   Endif
   
   /* Comentado por CesarMussi em 08/12/2016
   //------------------------------------------
   // Pesquisa o tamanho da etiqueta
   If Select("T_TAMANHO") > 0
      T_TAMANHO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BS_DESCR "
   cSql += "  FROM " + RetSqlName("SBS")
   cSql += " WHERE BS_FILIAL    = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND BS_CODIGO    = '" + Substr(_Codigo,03,04)   + "'"
   cSql += "   AND BS_BASE      = '02'"
   cSql += "   AND R_E_C_D_E_L_ = ''  " 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAMANHO", .T., .T. )

   If T_TAMANHO->( Eof() )
      cTamanho := ""
   Else
      cTamanho := T_TAMANHO->BS_DESCR
   Endif  */
   
   cTamanho := U_BuscaCar(_Codigo,"FAC")

   // Imprime as Etiquetas da Primeira Informação
   For nContar := 1 to (cEtq01 + cEtq02)

       MSCBPRINTER("S600",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE("^XA" + chr(13))
       MSCBWRITE("~SD16" + chr(13))
       MSCBWRITE("^PR2" + chr(13))
       MSCBWRITE("^FO513,62^ADR,36,30^FDAUTOMATECH^FS" + chr(13))
       MSCBWRITE("^FO456,24^GB2,946,2^FS" + chr(13))
       MSCBWRITE("^FO490,111^ACR,18,10^FDwww.automatech.com.br^FS" + chr(13))
       MSCBWRITE("^FO456,463^GB118,2,2^FS" + chr(13))
       MSCBWRITE("^FO486,543^ADR,54,30^FDOP^FS" + chr(13))
       MSCBWRITE("^FO485,654^AER,56,30^FD" + Alltrim(cProducao) + "^FS" + chr(13))

       If Len(Alltrim(cCliente)) <= 25
          MSCBWRITE("^FO356,39^ADR,54,30^FD" + Alltrim(cCliente) + "^FS" + chr(13))
       Else
          MSCBWRITE("^FO356,39^ADR,54,30^FD" + Substr(cCliente,01,25) + "^FS" + chr(13))
          MSCBWRITE("^FO285,39^ADR,54,30^FD" + Substr(cCliente,26,25) + "^FS" + chr(13))
       Endif

       MSCBWRITE("^FO427,34^ACR,18,10^FDCliente^FS" + chr(13))
       MSCBWRITE("^FO270,28^GB2,946,2^FS" + chr(13))
       MSCBWRITE("^FO236,32^ACR,18,10^FDMedida^FS" + chr(13))
       MSCBWRITE("^FO159,88^ADR,54,30^FD" + Alltrim(cTamanho) + "^FS" + chr(13))
       MSCBWRITE("^FO142,30^GB2,942,2^FS" + chr(13))
       MSCBWRITE("^FO236,491^ADR,18,10^FDQuantidade^FS" + chr(13))
       MSCBWRITE("^FO142,463^GB128,2,2^FS" + chr(13))

       If nContar <= cEtq01
          MSCBWRITE("^FO159,614^ADR,54,30^FD" + Alltrim(Str(cQtd01,10)) + "^FS" + chr(13))
       Else
          MSCBWRITE("^FO159,614^ADR,54,30^FD" + Alltrim(Str(cQtd02,10)) + "^FS" + chr(13))
       Endif

       If nContar <= cEtq01
          MSCBWRITE("^FO65,162^BY2,3.0^BCR,51,Y,N,N,N^FD>" + Alltrim(cProducao) + Alltrim(_Codigo) + Alltrim(Str(cQtd01,10)) + "^FS" + chr(13))
       Else
          MSCBWRITE("^FO65,162^BY2,3.0^BCR,51,Y,N,N,N^FD>" + Alltrim(cProducao) + Alltrim(_Codigo) + Alltrim(Str(cQtd02,10)) + "^FS" + chr(13))
       Endif

       MSCBWRITE("^PQ1,1,0,Y^FS" + chr(13))
       MSCBWRITE("^XZ" + chr(13))
       MSCBEND()
       MSCBCLOSEPRINTER()

   Next nContar
   
Return .T.