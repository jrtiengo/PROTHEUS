
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM270.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Michel Yasugi Aoki / Harald Hans Löschenkohl                        *
// Data......: 09/10/2014                                                          *
// Objetivo..: Impressão de etiquetas de embarque GKN                              *
//**********************************************************************************

// Função que define a Window
User Function AUTOM270(__Pedido, __Cliente, __Loja)

   Local lChumba      := .F.

   Private kFilial    := Space(10)
   Private cPvenda    := __Pedido
   Private cNota	  := Space(10)
   Private cSerie	  := Space(03)
   Private cCliente	  := __Cliente
   Private cLoja	  := __Loja
   Private cDescricao := Posicione("SA1",1,xFilial("SA1") + __Cliente + __Loja, "A1_NOME")
   Private cMemo1	  := ""
   Private aPortas 	  := {"LPT1", "LPT2", "COM1", "COM2"}
   Private cPortas

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oMemo1
   Private aLista    := {}

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

   U_AUTOM628("AUTOM270")
   
   aAdd( aLista, { "","","","","","","","","","" })

   // Carrega o array aFiliais conforme a Empresa logada
   Do Case
      Case cEmpAnt == "01"
           Do Case
              Case cFilAnt == "01"
                   kFilial := "01-POA"
              Case cFilAnt == "02"
                   kFilial := "02-CXS"
              Case cFilAnt == "03"
                   kFilial := "03-PEL"
              Case cFilAnt == "04"
                   kFilial := "04-SUP"
              Case cFilAnt == "05"
                   kFilial := "05-SP"
              Case cFilAnt == "06"
                   kFilial := "06-ES"
              Case cFilAnt == "07"
                   kFilial := "07-SUP"
           EndCase
      Case cEmpAnt == "02"
           kFilial := "01-TI"
      Case cEmpAnt == "03"
           kFilial := "01-Atech"
      Case cEmpAnt == "04"
           kFilial := "01-PEL"
   EndCase
         
   // Verifica se pedido de venda já foi faturado.
   // Somente será permitido entrar nesta tela caso o pedido de venda já tenha sido faturado.
   // Na etiqueta da GKN, é impresso o número da nota fiscal e a série da nota fiscal devido a isso, é necessário que o pedido já tenha sido faturado.
   If Empty(Posicione("SC5",1, xFilial("SC5") + cPvenda, "C5_NOTA"))
      MsgAlert("Atenção!"                                     + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Pedido de Venda ainda não foi faturado."      + chr(13) + chr(10) + ;
               "Processo não permitido antes do faturamento." + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif

   cNota  := Posicione("SC5",1, xFilial("SC5") + cPvenda, "C5_NOTA" )
   cSerie := Posicione("SC5",1, xFilial("SC5") + cPvenda, "C5_SERIE")
   
   // Envia para a função que pesquisa os dados para popular o Grid
   psqnfgkn(cNota, cSerie, cCliente, cLoja)

   // Desenha a tela
   DEFINE MSDIALOG oDlg TITLE "Emissão Etiqueta GKN" FROM C(178),C(181) TO C(520),C(941) PIXEL

   @ C(005),C(005) Jpeg FILE "logoautoma.bmp" Size C(111),C(027) PIXEL NOBORDER OF oDlg
   @ C(147),C(085) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(159),C(085) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(367),C(001) PIXEL OF oDlg

   @ C(041),C(005) Say "Filial"                 Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(044) Say "Ped.Venda"              Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(085) Say "Nota Fiscal"            Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(133) Say "Série"                  Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(154) Say "Cliente"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(146),C(005) Say "Porta de Impressão"     Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(148),C(097) Say "Volumes informados"     Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(160),C(097) Say "Volumes nâo informados" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(051),C(005) MsGet    oGet7    Var   kFilial    Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(051),C(044) MsGet    oGet6    Var   cPVenda    Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(051),C(085) MsGet    oGet1    Var   cNota      Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(051),C(133) MsGet    oGet2    Var   cSerie     Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(051),C(154) MsGet    oGet3    Var   cCliente   Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(051),C(181) MsGet    oGet4    Var   cLoja      Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(051),C(202) MsGet    oGet5    Var   cDescricao Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(155),C(005) ComboBox cPortas  Items aPortas    Size C(072),C(010)                              PIXEL OF oDlg

   @ C(151),C(168) Button "V o l u m e s"  Size C(037),C(012) PIXEL OF oDlg ACTION( xDivVolumes(cPvenda, cCliente, cLoja, aLista[oLista:nAt,13], aLista[oLista:nAt,06], aLista[oLista:nAt,07], aLista[oLista:nAt,09]) )  &&, _Volumes, _Quantidade) )
   @ C(151),C(212) Button "Para Arquivo"   Size C(037),C(012) PIXEL OF oDlg ACTION( ImpEtqGKN(1,1) ) When Upper(Alltrim(cUserName)) == "ADMINISTRADOR"
   @ C(151),C(257) Button "Imprimir"       Size C(037),C(012) PIXEL OF oDlg ACTION( ImpEtqGKN(1,0) )
   @ C(151),C(296) Button "Reimpressão"    Size C(037),C(012) PIXEL OF oDlg ACTION( ImpEtqGKN(2,0) )
   @ C(151),C(335) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oLista := TCBrowse():New( 083 , 005, 470, 100,,{'','N.Fiscal', 'Série', 'Emissão', 'Item PV', 'Cód.Produto', 'Descrição dos Produtos', 'Part Number', 'Quantª', 'Peso Bruto'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oLista:SetArray(aLista) 
    
   // Monta a linha a ser exibina no Browse
   oLista:bLine := {||{ If(aLista[oLista:nAt,01] == "1", oBranco   ,;
                        If(aLista[oLista:nAt,01] == "2", oVerde    ,;
                        If(aLista[oLista:nAt,01] == "3", oPink     ,;                         
                        If(aLista[oLista:nAt,01] == "4", oAmarelo  ,;                         
                        If(aLista[oLista:nAt,01] == "5", oAzul     ,;                         
                        If(aLista[oLista:nAt,01] == "6", oLaranja  ,;                         
                        If(aLista[oLista:nAt,01] == "7", oPreto    ,;                         
                        If(aLista[oLista:nAt,01] == "8", oVermelho ,;
                        If(aLista[oLista:nAt,01] == "0", oCancel   ,;
                        If(aLista[oLista:nAt,01] == "9", oEncerra, "")))))))))),;                         
                        aLista[oLista:nAt,02]            ,;
                        aLista[oLista:nAt,03]            ,;
                        aLista[oLista:nAt,04]            ,;
                        aLista[oLista:nAt,05]            ,;
                        aLista[oLista:nAt,06]            ,;
                        aLista[oLista:nAt,07]            ,;                                                                           
                        aLista[oLista:nAt,08]            ,;
                        aLista[oLista:nAt,09]            } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa os dados da nota fiscal informada
Static function psqnfgkn(_Nota, _Serie, _Cliente, _Loja)

   Local cSql    := ""
   Local cStatus := ""

   If Empty(Alltrim(_Nota))
      MsgAlert("Nº da Nota Fiscal a ser pesquisada não informada.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(_Serie))
      MsgAlert("Série da Nota Fiscal a ser pesquisada não informada.")
      Return(.T.)
   Endif

   // Pesquisa dados da nota fiscal/série informada
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   aLista := {}

   cSql := ""
   cSql := "SELECT D2_COD     ,"
   cSql += "       D2_ITEM    ,"
   cSql += "       D2_QUANT   ,"
   cSql += "       F2_PBRUTO  ,"
   cSql += "       F2_VOLUME1 ,"
   cSql += "       F2_EMISSAO ,"
   cSql += "       B1_DESC    ,"
   cSql += "       B1_DAUX    ,"
   cSql += "       B1_PARNUM  ,"
   cSql += "       D2_DOC     ,"
   cSql += "       D2_SERIE   ,"
   cSql += "       D2_UM      ," 
   cSql += "       D2_PEDIDO  ,"
   cSql += "       D2_ITEMPV  ,"
   cSql += "       D2_FILIAL   "
   cSql += "  FROM " + RetSqlName("SD2")+" SD2 "
   cSql += "  Inner Join " + RetSqlName("SF2") +" SF2 On ( F2_FILIAL  = D2_FILIAL  " 
   cSql += " 										  And  F2_TIPO    = D2_TIPO    "
   cSql += " 										  And  F2_DOC     = D2_DOC     "
   cSql += " 										  And  F2_SERIE   = D2_SERIE   "
   cSql += " 										  And  F2_CLIENTE = D2_CLIENTE "
   cSql += " 										  And  F2_LOJA    = D2_LOJA    "
   cSql += " 										  And  SF2.D_E_L_E_T_   = '')  "
   cSql += "  Inner Join " + RetSqlName("SB1") +" SB1 On ( B1_FILIAL  = '" + xFilial("SB1") + "' "
   cSql += " 										  And  B1_COD     = D2_COD     "
   cSql += " 										  And  SB1.D_E_L_E_T_   = '')  "
   cSql += " WHERE D2_DOC         = '" + Alltrim(_Nota)        + "'"
   cSql += "   AND D2_SERIE       = '" + Alltrim(_Serie)       + "'"
   cSql += "   AND D2_CLIENTE     = '" + Alltrim(_Cliente)     + "'"
   cSql += "   AND D2_LOJA        = '" + Alltrim(_Loja)        + "'"
   cSql += "   AND D2_FILIAL      = '" + Substr(kFilial,01,02) + "'"
   cSql += "   AND SD2.D_E_L_E_T_ = ''"
   cSql += "   ORDER BY D2_ITEM "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
   
   T_PRODUTOS->( DbGoTop() )

   WHILE !T_PRODUTOS->( EOF() )

      // Verifica se volumes foram informados para o item/produto
      If Empty(Alltrim(Posicione("SC6",1,T_PRODUTOS->D2_FILIAL + T_PRODUTOS->D2_PEDIDO + T_PRODUTOS->D2_ITEMPV + T_PRODUTOS->D2_COD,"C6_ZVOLUME")))
         cStatus := "8"
      Else
         cStatus := "2"
      Endif

      // Prepara a quantidade para gravação
      // Se for etiqueta, multiplica por 1000
      If Len(Alltrim(T_PRODUTOS->D2_COD)) == 6
         _GravaQtd := T_PRODUTOS->D2_QUANT
      Else
         _GravaQtd := T_PRODUTOS->D2_QUANT * 1000
      Endif            

      // ###############################################################################################
      // Se produto não for etiqueta, verifica se o mesmo está cadastrado na tabela PRODUTO X CLIENTE ##
      // ###############################################################################################
      If Len(Alltrim(T_PRODUTOS->D2_COD)) == 17

         kPartNumber := T_PRODUTOS->B1_PARNUM
         
      Else

         If Select("T_RELACAO") > 0
            T_RELACAO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A7_FILIAL ,"
         cSql += "       A7_CLIENTE,"
 	     cSql += "       A7_LOJA   ,"
 	     cSql += "       A7_PRODUTO,"
 	     cSql += "       A7_CODCLI  "
         cSql += "  FROM " + RetSqlName("SA7")
         cSql += " WHERE A7_FILIAL  = '" + Substr(kFilial,01,02)       + "'"
         cSql += "   AND A7_CLIENTE = '" + Alltrim(_Cliente)           + "'"
         cSql += "   AND A7_LOJA    = '" + Alltrim(_Loja)              + "'"
         cSql += "   AND A7_PRODUTO = '" + Alltrim(T_PRODUTOS->D2_COD) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"
      
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RELACAO", .T., .T. )
         
         kPartNumber := IIF(T_RELACAO->( EOF() ), "SEM CADASTRO", T_RELACAO->A7_CODCLI)
         
      Endif   

      aAdd( aLista, {cStatus                                                           ,; && 01 - Status
                     T_PRODUTOS->D2_DOC                                                ,; && 02 - Nº da Nota Fiscal
                     T_PRODUTOS->D2_SERIE                                              ,; && 03 - Nº de Série da Nota Fiscal
                     T_PRODUTOS->F2_EMISSAO                                            ,; && 04 - Data de Emissão da Nota Fiscal
                     T_PRODUTOS->D2_ITEMPV                                             ,; && 05 - Sequencial do produto
                     T_PRODUTOS->D2_COD                                                ,; && 06 - Código do Produto
                     Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX) ,; && 07 - Descrição dos Produtos
                     kPartNumber                                                       ,; && 08 - Part Number do produto
                     _GravaQtd                                                         ,; && 09 - Quantidade do Produto
                     T_PRODUTOS->F2_PBRUTO                                             ,; && 10 - Peso Bruto
                     T_PRODUTOS->D2_FILIAL                                             ,; && 11 - Filial de Origem
                     T_PRODUTOS->D2_PEDIDO                                             ,; && 12 - Nº do Pedido de Venda
                     T_PRODUTOS->D2_ITEMPV                                             }) && 13 - Nº do item no Pedido de Venda

//                  (T_PRODUTOS->D2_QUANT * 1000)                                      ,; && 09 - Quantidade do Produto
                     
      T_PRODUTOS->( DbSkip() )
      
   ENDDO                  

   If Len(aLista) == 0
      aAdd( aLista, { "0", "","","","","","","","","","" })
   Endif
      
Return(.T.)

// ---------------------------------------- //
// Função que imprime a etiqueta            //
// TipoBotao == 1 - Impressão Total         //
// TipoBotao == 2 - Reimpressão de Etiqueta //
// ---------------------------------------- //
Static function ImpEtqGKN(_TipoBotao, _ParaArquivo)

   Local cPorta       := cPortas
   Local aImpressao   := {}
   Local nQtetq       := 1      
   Local _nPosPN      := ""
   Local _nPosDoc     := ""
   Local _nPosQtd     := 0
   Local _nPosSer     := ""
   Local _nPosVol     := 0
   Local _nPosCod     := ""
   Local _nPosDesc    := ""
   Local _nPosPBr     := 0
   Local _cCodBar     := ""
   Local _nIt         := 0
   Local _nVol        := 0
   Local _nTamQtd     := 7  // Numérico
   Local _nTamIt      := 14 // Caracter
   Local _nTamUM      := 02 // Caracter
   Local _nTamLot     := 10 // Caracter
   Local _nTamSub     := 08 // Numérico
   Local _cCodPos1    := ""
   Local _cCodPos2    := ""
   Local _cCodPos3    := ""
   Local _cCodPos4    := ""
   Local _cCodPos5    := ""
   Local nContar      := 0
   Local lTodosOK     := .T.
   Local nPorOnde     := 0
   Local nVolumes     := 0
   Local nVolTotal    := 0
   Local nCodGKN      := ""
   Local nSequencial  := 0
   Local nSubContrato := 0

   // Variáveis para reimpressão de etiquetas
   Local lChumba      := .F.
   Local nETQtotal    := 0
   Local nReimprimir  := 0
   Local cMemo1	      := ""
   Local cMemo2	      := ""
   Local xReimpressao := .F.
   Local oGet1
   Local oGet2
   Local oMemo1
   Local oMemo2
   Local cString      := ""

   // Variáveis da tela de solicitação do caminho para gravação dos dados da etiqueta
   Local lVoltar      := .F.
   Local cCaminho	  := Space(150)
   Local cMemo10	  := ""
   Local oGet1
   Local oMemo10

   Private oDlgR
   Private oDlgC
   Private nHdl

   // #######################################################
   // Carrega o sequenciador de geração da etiqueta da GKN ##
   // #######################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SGKN, ZZ4_XCON FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   nSequencial  := IIF(T_PARAMETROS->( EOF() ), 1, T_PARAMETROS->ZZ4_SGKN + 1)
   nSubContrato := IIF(T_PARAMETROS->( EOF() ), 0, INT(VAL(T_PARAMETROS->ZZ4_XCON)))

   If nSubContrato == 0
      MsgAlert("Nº SubContrato para geração de etiquetas n~]ao parametrizado. Entre em contato com o Administrador do Sistema.")
      Return(.T.)
   Endif

   // Realiza uma consistência para verificar se todos os produtos do array aLista possui informação de volumes e quantidades de produtos
   lTodosOK := .T.
   For nContar = 1 to Len(aLista)   
       
       If Empty(Alltrim(aLista[nContar,01]))
          nPorOnde := 1
          lTodosOK := .F.
          Exit
       Endif   
  
       If Select("T_VOLUMES") > 0
          T_VOLUMES->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT C6_FILIAL ,"
       cSql += "       C6_ITEM   ,"
       cSql += "       C6_PRODUTO,"
       cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C6_ZVOLUME)) AS VOLUMES"
       cSql += "  FROM " + RetSqlName("SC6")
       cSql += " WHERE C6_FILIAL  = '" + Alltrim(aLista[nContar,11]) + "'"
       cSql += "   AND C6_NUM     = '" + Alltrim(aLista[nContar,12]) + "'"
       cSql += "   AND C6_ITEM    = '" + Alltrim(aLista[nContar,04]) + "'"
       cSql += "   AND C6_PRODUTO = '" + Alltrim(aLista[nContar,05]) + "'"
       cSql += "   AND D_E_L_E_T_= ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VOLUMES", .T., .T. )
              	          
       If T_VOLUMES->( EOF() )
          nPorOnde := 2
          lTodosOK := .F.
          Exit
       Endif
       
       If Empty(Alltrim(T_VOLUMES->VOLUMES))
          nPorOnde := 2
          lTodosOK := .F.
          Exit
       Endif

   Next nContar
   
//   If lTodosOK == .F.
//      If nPorOnde == 1  
//         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Necessário realizar pesquisa de nota fiscal para impressão de etiquetas.")
//      Else
//         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existem produtos sem informação de volumes e quantidades." + chr(13) + chr(10) + "Impressão de etiqueta não permitida.")
//      Endif
//      Return(.T.)
//   Endif

   // Carrega o array aImpressao com os dados a serem impressos
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ," + CHR(13)
   cSql += "       SC6.C6_ITEM   ," + CHR(13)
   cSql += "       SC6.C6_PRODUTO," + CHR(13)
   cSql += "       SC6.C6_NOTA   ," + CHR(13)
   cSql += "       SC6.C6_SERIE  ," + CHR(13)
   cSql += "       SC6.C6_QTDVEN ," + CHR(13)
   cSql += "       SC6.C6_NUM    ," + CHR(13)
   cSql += "       SC6.C6_CLI    ," + CHR(13)
   cSql += "       SC6.C6_LOJA   ," + CHR(13)
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), SC6.C6_ZVOLUME)) AS VOLUMES," + CHR(13)
   cSql += "       SB1.B1_PARNUM ," + CHR(13)
   cSql += "       SB1.B1_DESC   ," + CHR(13)
   cSql += "       SB1.B1_DAUX   ," + CHR(13)
   cSql += "       SF2.F2_PBRUTO  " + CHR(13)
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, " + CHR(13)
   cSql += "       " + RetSqlName("SB1") + " SB1, " + CHR(13)
   cSql += "       " + RetSqlName("SF2") + " SF2  " + CHR(13)
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(aLista[nContar,11]) + "'" + CHR(13)
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(aLista[nContar,12]) + "'" + CHR(13)
   cSql += "   AND SC6.D_E_L_E_T_ = ''"             + CHR(13)
   cSql += "   AND SB1.B1_FILIAL  = ''"             + CHR(13)
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO" + CHR(13)
   cSql += "   AND SB1.D_E_L_E_T_ = ''"             + CHR(13)
   cSql += "   AND SF2.F2_FILIAL  = SC6.C6_FILIAL"  + CHR(13)
   cSql += "   AND SF2.F2_DOC     = SC6.C6_NOTA  "  + CHR(13)
   cSql += "   AND SF2.F2_SERIE   = SC6.C6_SERIE "  + CHR(13)
   cSql += "   AND SF2.D_E_L_E_T_ = ''"             + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      For nContar = 1 to U_P_OCCURS(T_PRODUTOS->VOLUMES, "|", 1)

          // Despreza a informação geral dos volumes
          If nContar == 1
             nVolTotal := VAL(U_P_CORTA(U_P_CORTA(T_PRODUTOS->VOLUMES, "|", nContar), "@", 1))
             Loop
          Endif

          // Captura o código do produto na GKN
          If Len(Alltrim(T_PRODUTOS->C6_PRODUTO)) == 17
             kPartNumber := T_PRODUTOS->B1_PARNUM
             nCodGKN     := U_P_CORTA(STRTRAN(SUBSTR(Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),;
                                      INT(VAL(U_P_OCCURS(Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX), "GKN",2))) + 4), " ", "|"), "|", 1)
          Else
              
             If Select("T_RELACAO") > 0
                T_RELACAO->( dbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT A7_FILIAL ,"
             cSql += "       A7_CLIENTE,"
    	     cSql += "       A7_LOJA   ,"
    	     cSql += "       A7_PRODUTO,"
    	     cSql += "       A7_CODCLI  "
             cSql += "  FROM " + RetSqlName("SA7")
             cSql += " WHERE A7_FILIAL  = '" + Alltrim(T_PRODUTOS->C6_FILIAL)  + "'"
             cSql += "   AND A7_CLIENTE = '" + Alltrim(T_PRODUTOS->C6_CLI)     + "'"
             cSql += "   AND A7_LOJA    = '" + Alltrim(T_PRODUTOS->C6_LOJA)    + "'"
             cSql += "   AND A7_PRODUTO = '" + Alltrim(T_PRODUTOS->C6_PRODUTO) + "'"
             cSql += "   AND D_E_L_E_T_ = ''"

             cSql := ChangeQuery( cSql )
             dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RELACAO", .T., .T. )
                                                
             If T_RELACAO->( EOF() )
                Loop
             Endif
                
             kPartNumber := T_RELACAO->A7_CODCLI
             
          Endif   

          nVolumes := nVolumes + 1

          aAdd( aImpressao, {kPartNumber                                                      ,; // 01 - Part Number do Produto
                             T_PRODUTOS->C6_NOTA                                              ,; // 02 - Número da Nota Fiscal
                             U_P_CORTA( U_P_CORTA(T_PRODUTOS->VOLUMES, "|", nContar) , "#", 2),; // 03 - Quantidade de Etiquetas no Volume
                             T_PRODUTOS->C6_SERIE                                             ,; // 04 - Número de Série da Nota Fiscal
                             Alltrim(Str(nVolumes)) + "/" + Alltrim(Str(nVolTotal))           ,; // 05 - Volumes
                             T_PRODUTOS->C6_PRODUTO                                           ,; // 06 - Código do Produto
                             Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX),; // 07 - Descrição do Produto
                             T_PRODUTOS->F2_PBRUTO                                            ,; // 08 - Peso Bruto total dos volumes
                             nCodGKN                                                          ,; // 09 - Código do Produto na GKN
                             T_PRODUTOS->C6_NUM                                               }) // 10 - Nº do Pedido de Venda

      Next nContar
      
      nVolumes := 0

      T_PRODUTOS->( DbSkip() )
      
   ENDDO                                              

   // Solicitação de reimpresão de etiqueta
   If _TipoBotao == 2
   
      xReimpressao := .F.
      nETQtotal    := nVolTotal

      DEFINE MSDIALOG oDlgR TITLE "Reimpressão de Etiquetas" FROM C(178),C(181) TO C(380),C(447) PIXEL

      @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgR

      @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(124),C(001) PIXEL OF oDlgR
      @ C(076),C(003) GET oMemo2 Var cMemo2 MEMO Size C(124),C(001) PIXEL OF oDlgR
   
      @ C(039),C(005) Say "Informe o nº da etiqueta a ser reimpressa" Size C(098),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
      @ C(051),C(005) Say "Total Etiquetas"                           Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
      @ C(051),C(049) Say "Reimprimir Etiqueta Nº"                    Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgR

      @ C(062),C(005) MsGet oGet1 Var nETQtotal   Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999999" PIXEL OF oDlgR When lChumba
      @ C(062),C(049) MsGet oGet2 Var nReimprimir Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999999" PIXEL OF oDlgR

      @ C(083),C(028) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgR ACTION( xReimpressao := .T., oDlgR:End() )
      @ C(083),C(066) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgR ACTION( xReimpressao := .F., oDlgR:End() )

      ACTIVATE MSDIALOG oDlgR CENTERED 

      If xReimpressao == .F.
         Return(.T.)
      Endif
      
      If nReimprimir == 0
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Etiqueta a ser reimpressa não informada. Impressão abortada.")
         Return(.T.)
      Endif

      If nReimprimir > nETQtotal
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Etiqueta a ser reimpressa inexistente. Impressão abortada.")
         Return(.T.)
      Endif
      
   Endif

   // --------------------------- //
   // Posicionamentos da Etiqueta //
   // --------------------------- //
   // 1º - Rotação                //
   // 2º - Fonte                  //
   // 3º - Largura                //
   // 4º - Altura                 //
   // 5º - Tamanho do Fonte       //
   // 6º - Linha                  //
   // 7º - Coluna                 //
   // 8º - Dados                  //
   // --------------------------- //

   For nContar = 1 to Len(aImpressao)

//       If nContar > 2
//          Exit
//       Endif

       // Em caso de reimpressão de etiqueta
       If _TipoBotao == 2
          If nContar <> nReimprimir
             Loop
          Endif
       Endif

       // Direciona a saída para arquivo
       If _ParaArquivo == 1

          DEFINE MSDIALOG oDlgC TITLE "Salvar dados da etiqueta" FROM C(178),C(181) TO C(333),C(605) PIXEL

          @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgC

          @ C(032),C(002) GET oMemo10 Var cMemo10 MEMO Size C(203),C(001) PIXEL OF oDlgC

          @ C(037),C(005) Say "Informe o caminho + nome do arquivo para salvar dados da etiqueta" Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

          @ C(046),C(005) MsGet oGet1 Var cCaminho Size C(200),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC

          @ C(060),C(128) Button "Salvar"          Size C(037),C(012) PIXEL OF oDlgC ACTION( lVoltar := .F., oDlgC:End() )
          @ C(060),C(168) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgC ACTION( lVoltar := .T., oDlgC:End() )

          ACTIVATE MSDIALOG oDlgC CENTERED 

          If lVoltar == .T.
             Return(.T.)
          Endif

          If Empty(Alltrim(cCaminho))
             MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Caminho a ser salvo os dados da etiqueta não informado. Procedimento será abortado.")
             Return(.T.)
          Endif

          // Gera a string para gravação em arquivo
          cString := ""
          cString += "^XA"              + chr(13) + chr(10)
 	      cString += "^FO202,19"        + chr(13) + chr(10)
 	      cString += "^GB204,801,6^FS"  + chr(13) + chr(10)
 	      cString += "^FO202,615"       + chr(13) + chr(10)
 	      cString += "^GB204,205,6^FS"  + chr(13) + chr(10)
	      cString += "^FO481,19"        + chr(13) + chr(10)
	      cString += "^GB85,801,6^FS"   + chr(13) + chr(10)
	      cString += "^FO401,555"       + chr(13) + chr(10)
	      cString += "^GB85,265,6^FS"   + chr(13) + chr(10)
	      cString += "^FO401,19"        + chr(13) + chr(10)
	      cString += "^GB85,266,6^FS"   + chr(13) + chr(10)
	      cString += "^FO122,19"        + chr(13) + chr(10)
	      cString += "^GB85,266,6^FS"   + chr(13) + chr(10)
	      cString += "^FO42,19"         + chr(13) + chr(10)
	      cString += "^GB85,265,6^FS"   + chr(13) + chr(10)
   	      cString += "^FT332,611"       + chr(13) + chr(10)
	      cString += "^CI0"             + chr(13) + chr(10)
	      _nTamPAr := 14
	      cString += "^A0B,37,48^FD"    + Alltrim(aImpressao[nContar,01]) + Space(_nTamPAr - len(Alltrim(aImpressao[nContar,01]))) + ' ' + ;
	                                      Transform(VAL(aImpressao[nContar,03]), "@E 99,999,999") + '    ' + 'PC' + '^FS'    + chr(13) + chr(10) //	Qunatidade
	      cString += "^FT469,801"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,37,49^FD"    + Alltrim(aImpressao[nContar,02]) + '/' + aImpressao[nContar,04] + '^FS'             + chr(13) + chr(10) // Doc e Série
	      cString += "^FT469,499"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,37,49^FD"       + aImpressao[nContar,05] + '^FS'                                                  + chr(13) + chr(10)// Qtd Volume
	      cString += "^FT469,195"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,37,49^FD"       + Transform(aImpressao[nContar,08], '@E 9,999.99') + '^FS'                        + chr(13) + chr(10)// Peso Bruto
	      cString += "^FT173,758"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,25,33^FD"       + 'SISTEMAS DE AUTOMACAO LTDA^FS'                                                 + chr(13) + chr(10)
	      cString += "^FT104,217"                                                                                            + chr(13) + chr(10)
          cString += "^A0B,25,36^FD"       + STRZERO(Day(DATE())  ,2) + '/' + ;
	                                         STRZERO(Month(DATE()),2) + '/' + ;
	                                         STRZERO(YEAR(DATE()),4)  + '^FS'                                                + chr(13) + chr(10)
	      cString += "^FT181,263"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,20,26^FD"      + aImpressao[nContar,06]   + "^FS"                                                 + chr(13) + chr(10)
	      cString += "^FT548,801"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,25,31^FD"      + Substr(aImpressao[nContar,07],01,52) + "^FS"                                     + chr(13) + chr(10)
	      cString += "^FT424,817"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,20,24^FD   Nota Fiscal :^FS"                                                                      + chr(13) + chr(10)
	      cString += "^FT425,557"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,20,23^FD  Numero de Volume:^FS"                                                                   + chr(13) + chr(10)
	      cString += "^FT425,282"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,20,23^FD  Peso Total (kg):^FS"                                                                    + chr(13) + chr(10)
	      cString += "^FT525,801"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,20,24^FDDescricao da Peca:^FS"                                                                    + chr(13) + chr(10)
	      cString += "^FT224,611"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,20,22^FDCodigo Peca GKN : ^FS"                                                                    + chr(13) + chr(10)
	      cString += "^FT226,320"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,23,25^FDQuantidade:^FS"                                                                           + chr(13) + chr(10)
	      cString += "^FT226,130"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,23,25^FDUnidade:^FS"                                                                              + chr(13) + chr(10)
	      cString += "^FT66,806"                                                                                             + chr(13) + chr(10)
	      cString += "^A0B,23,25^FDFornecedor:^FS"                                                                           + chr(13) + chr(10)
	      cString += "^FT66,270"                                                                                             + chr(13) + chr(10)
	      cString += "^A0B,23,25^FDData:^FS"                                                                                 + chr(13) + chr(10)
	      cString += "^FT146,270"                                                                                            + chr(13) + chr(10)
	      cString += "^A0B,23,24^FDCod. Peca Fornecedor:^FS"                                                                 + chr(13) + chr(10)
	      cString += "^FO239,640"                                                                                            + chr(13) + chr(10)
		
	      // - No de etiqueta: 10 caract. (numerico) : Numero sequencial unico da etiqueta por item, a fim de evitar duplicidade na conferencia;
	      // - Quantidade: 7 caract. (numerico) „³ Quantidade por caixa ou pallet;
	      // - Item: 14 caract. (alfanumerico) „³ PN usado pela GKN;
	      // - Unid. Medida: 2 caract. (alfanumerico) „³ deve ser descrito se a quantidade sera medida em pecas (PC), Quilos (KG), etc.
	      // - Lote: 10 caract. (alfanumerico) „³ informacao fornecida pelo fornecedor
	      // - Subcontratado: 8 caract. (numerico) „³ Numeracao fixa usada pela GKN para identificar os fornecedores.
	      //   Caso nao preencha o numero de caracteres informado:
	      //   Numerico: numero zero na esquerda.
	      //   Alfanumerico: espacos vazios na direita.

          nSequencial := nSequencial + 1

	      _cCodPos0 := StrZero(nSequencial, 10)                                                              // 10 Numero sequencial unico da etiqueta por item, a fim de evitar duplicidade na conferencia
 	      _cCodPos1 := StrZero(Int(Val(aImpressao[nContar,03])), 7)                                          // Qtde: 7 caract. (numérico)
	      _cCodPos2 := Alltrim(aImpressao[nContar,01]) + Space(14-Len(Alltrim(aImpressao[nContar,01])))      // Item: 14 caract. (alfanumérico)
	      _cCodPos3 := 'PC'                                                                                  // Unid. Medida: 2 caract. (alfanumérico)
	      _cCodPos4 := Alltrim(aImpressao[nContar,10]) + Space(10 - Len(Alltrim(aImpressao[nContar,10])))    // Lote: 10 caract. (alfanumérico)
//        _cCodPos5 := StrZero(12267,_nTamSub)                                                               // Subcontratado: 8 caract. (numérico)
	      _cCodPos5 := StrZero(nSubContrato,_nTamSub)                                                        // Subcontratado: 8 caract. (numérico)
	      _cCodBar  := _cCodPos0 + _cCodPos1 + _cCodPos2 + _cCodPos3 + _cCodPos4 + _cCodPos5

	      cString += "^F500,40^BQ,50,4^FDQA," + _cCodBar + '^FS' + chr(13) + chr(10) //Código de Barras
	      cString += "^FO42,19"                                  + chr(13) + chr(10)
	      cString += "^GB524,801,6^FS"                           + chr(13) + chr(10)
	      cString += "^FT118,744"                                + chr(13) + chr(10)
	      cString += "^A0B,51,68^FDAUTOMATECH^FS"                + chr(13) + chr(10)
	      cString += "^PQ1,0,1,Y"                                + chr(13) + chr(10)
	      cString += "^XZ"                                       + chr(13) + chr(10)
		
          // Gera o arquivo XML para o caminho informado
          nHdl := fCreate(cCaminho)
          fWrite (nHdl, cString ) 
          fClose(nHdl)

          Return(.T.)
          
       Else

          // --------------------------- //
          // Posicionamentos da Etiqueta //
          // --------------------------- //
          // 1º - Rotação                //
          // 2º - Fonte                  //
          // 3º - Largura                //
          // 4º - Altura                 //
          // 5º - Tamanho do Fonte       //
          // 6º - Linha                  //
          // 7º - Coluna                 //
          // 8º - Dados                  //
          // --------------------------- //

          // Saída para impressora
	      MSCBPRINTER("DATAMAX",cPorta)
	      MSCBCHKSTATUS(.F.)
	      MSCBBEGIN(2,6,)
	      MSCBWRITE("^FO202,19" + chr(13))
	      MSCBWRITE("^GB204,801,6^FS" + chr(13))
	      MSCBWRITE("^FO202,615" + chr(13))
	      MSCBWRITE("^GB204,205,6^FS" + chr(13))
	      MSCBWRITE("^FO481,19" + chr(13))
	      MSCBWRITE("^GB85,801,6^FS" + chr(13))
	      MSCBWRITE("^FO401,555" + chr(13))
	      MSCBWRITE("^GB85,265,6^FS" + chr(13))
	      MSCBWRITE("^FO401,19" + chr(13))
	      MSCBWRITE("^GB85,266,6^FS" + chr(13))
	      MSCBWRITE("^FO122,19" + chr(13))
	      MSCBWRITE("^GB85,266,6^FS" + chr(13))
	      MSCBWRITE("^FO42,19" + chr(13))
	      MSCBWRITE("^GB85,265,6^FS" + chr(13))
   	      MSCBWRITE("^FT332,611" + chr(13))
   	      MSCBWRITE("^CI0" + chr(13))
	      _nTamPAr := 14

          MSCBWRITE("^A0B,40,35^FD" + Alltrim(aImpressao[nContar,01]) + Space(_nTamPAr - len(Alltrim(aImpressao[nContar,01]))) + "    " + ;
                                   Transform(Val(aImpressao[nContar,03]), "@E 99,999.99") + "         " + "PC" + "^FS" + chr(13)) // Quantidade

	      MSCBWRITE("^FT469,801" + chr(13))

	      MSCBWRITE("^A0B,37,49^FD"      + Alltrim(aImpressao[nContar,02]) + "/" + aImpressao[nContar,04] + "^FS" + chr(13)) // Doc e Série

	      MSCBWRITE("^FT469,499" + chr(13))
	      MSCBWRITE("^A0B,37,49^FD"      + aImpressao[nContar,05] + "^FS" + chr(13))
	      MSCBWRITE("^FT469,195" + chr(13))
	      MSCBWRITE("^A0B,37,49^FD"      + Transform(aImpressao[nContar,08], "@E 9,999.99") + "^FS" + chr(13))
	      MSCBWRITE("^FT173,758" + chr(13))
	      MSCBWRITE("^A0B,25,33^FD"      + "SISTEMAS DE AUTOMACAO LTDA^FS" + chr(13))
	      MSCBWRITE("^FT104,217" + chr(13))
	      MSCBWRITE("^A0B,25,36^FD"      + STRZERO(Day(DATE())  ,2) + "/" + ;
	                                       STRZERO(Month(DATE()),2) + "/" + ;
	                                       STRZERO(YEAR(DATE()),4)  + "^FS" + chr(13))
	      MSCBWRITE("^FT181,263" + chr(13))
	      MSCBWRITE("^A0B,20,26^FD"      + aImpressao[nContar,06]   + "^FS" + chr(13))
	 
	      MSCBWRITE("^FT550,801" + chr(13))
	      MSCBWRITE("^A0B,37,25^FD"      + Alltrim(aImpressao[nContar,07]) + "^FS" + chr(13))

	      MSCBWRITE("^FT424,817" + chr(13))
	      MSCBWRITE("^A0B,20,24^FD   Nota Fiscal :^FS" + chr(13))
	      MSCBWRITE("^FT425,557" + chr(13))
	      MSCBWRITE("^A0B,20,23^FD  Numero de Volume:^FS" + chr(13))
	      MSCBWRITE("^FT425,282" + chr(13))
	      MSCBWRITE("^A0B,20,23^FD  Peso Total (kg):^FS" + chr(13))
	      MSCBWRITE("^FT505,801" + chr(13))
	      MSCBWRITE("^A0B,20,24^FDDescricao da Peca:^FS" + chr(13))
	      MSCBWRITE("^FT224,611" + chr(13))
	      MSCBWRITE("^A0B,20,22^FDCodigo Peca GKN : ^FS" + chr(13))
	      MSCBWRITE("^FT226,320" + chr(13))
	      MSCBWRITE("^A0B,23,25^FDQuantidade:^FS" + chr(13))
	      MSCBWRITE("^FT226,130" + chr(13))
	      MSCBWRITE("^A0B,23,25^FDUnidade:^FS" + chr(13))
	      MSCBWRITE("^FT66,806" + chr(13))
	      MSCBWRITE("^A0B,23,25^FDFornecedor:^FS" + chr(13))
	      MSCBWRITE("^FT66,270" + chr(13))
	      MSCBWRITE("^A0B,23,25^FDData:^FS" + chr(13))
	      MSCBWRITE("^FT146,270" + chr(13))
	      MSCBWRITE("^A0B,23,24^FDCod. Peca Fornecedor:^FS" + chr(13))
	      MSCBWRITE("^FO239,640" + chr(13))

 	      // - No de etiqueta: 10 caract. (numerico) : Numero sequencial unico da etiqueta por item, a fim de evitar duplicidade na conferencia;
	      // - Quantidade: 7 caract. (numerico) „³ Quantidade por caixa ou pallet;
	      // - Item: 14 caract. (alfanumerico) „³ PN usado pela GKN;
	      // - Unid. Medida: 2 caract. (alfanumerico) „³ deve ser descrito se a quantidade sera medida em pecas (PC), Quilos (KG), etc.
	      // - Lote: 10 caract. (alfanumerico) „³ informacao fornecida pelo fornecedor
	      // - Subcontratado: 8 caract. (numerico) „³ Numeracao fixa usada pela GKN para identificar os fornecedores.
	      //   Caso nao preencha o numero de caracteres informado:
	      //   Numerico: numero zero na esquerda.
	      //   Alfanumerico: espacos vazios na direita.

          nSequencial := nSequencial + 1

//	      _cCodPos0 := StrZero(nSequencial, 10)                                                              // 10 Numero sequencial unico da etiqueta por item, a fim de evitar duplicidade na conferencia
// 	      _cCodPos1 := StrZero(Int(aImpressao[nContar,03]), 7)                                               // Qtde: 7 caract. (numérico)
//	      _cCodPos2 := Alltrim(aImpressao[nContar,01]) + Space(14-Len(Alltrim(aImpressao[nContar,01])))      // Item: 14 caract. (alfanumérico)
//	      _cCodPos3 := "PC"                                                                                  // Unid. Medida: 2 caract. (alfanumérico)
//        _cCodPos4 := Alltrim(aImpressao[nContar,10]) + Space(10 - Len(Alltrim(aImpressao[nContar,10])))     // Lote: 10 caract. (alfanumérico)
//	      _cCodPos5 := StrZero(12267,_nTamSub)                                                               // Subcontratado: 8 caract. (numérico)
		  
          _cCodPos0 := StrZero(nSequencial, 10)                                                              // 10 Numero sequencial unico da etiqueta por item, a fim de evitar duplicidade na conferencia
 	      _cCodPos1 := StrZero(Int(Val(aImpressao[nContar,03])), 7)                                          // Qtde: 7 caract. (numérico)
	      _cCodPos2 := Alltrim(aImpressao[nContar,01]) + Space(14-Len(Alltrim(aImpressao[nContar,01])))      // Item: 14 caract. (alfanumérico)
	      _cCodPos3 := 'PC'                                                                                  // Unid. Medida: 2 caract. (alfanumérico)
	      _cCodPos4 := Alltrim(aImpressao[nContar,10]) + Space(10 - Len(Alltrim(aImpressao[nContar,10])))    // Lote: 10 caract. (alfanumérico)
//        _cCodPos5 := StrZero(12267,_nTamSub)                                                               // Subcontratado: 8 caract. (numérico)
	      _cCodPos5 := StrZero(nSubContrato,_nTamSub)                                                        // Subcontratado: 8 caract. (numérico)
	      _cCodBar  := _cCodPos0 + _cCodPos1 + _cCodPos2 + _cCodPos3 + _cCodPos4 + _cCodPos5

	      MSCBWRITE("^F500,40^BQ,50,4^FDQA," + _cCodBar + "^FS" + chr(13))
	      MSCBWRITE("^FO42,19" + chr(13))
	      MSCBWRITE("^GB524,801,6^FS" + chr(13))
	      MSCBWRITE("^FT118,744" + chr(13))
	      MSCBWRITE("^A0B,51,68^FDAUTOMATECH^FS" + chr(13))
	      MSCBWRITE("^PQ1,0,1,Y" + chr(13))
	      MSCBWRITE("^XZ" + chr(13))
		
	      MSCBEND()
		
	      MSCBCLOSEPRINTER()

	   Endif   
	   
   Next nContar

   // ##############################################################
   // Atualiza o sequenciador no parametrizador de geração da GKN ##
   // ##############################################################
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_SGKN := nSequencial
   MsUnLock()

Return(.T.)

// Função que habilita a divisão dos volumes para o produto selecionado
//, _Volumes, _Quantidade)
Static Function xDivVolumes(_Pedido, _Cliente, _Loja, _Item, _Produto, _Descricao, _Quantidade)

   Local cSql     := ""
   Local lChumba  := .F.
   Local nContar  := 0
   Local nPosicao := 0
   Local j       

   Local cMemo1	  := ""                                                                                      
   Local cMemo2	  := ""                                                                                      
   Local cMemo3	  := ""                                                                                      

   Local oMemo1                                                                                               
   Local oMemo2                                                                                               
   Local oMemo3                                                                                               

   Private xPedido   := _Pedido
   Private xCliente  := _Cliente + "." + _Loja + " - " + Posicione("SA1",1,xFilial("SA1") + _Cliente + _Loja, "A1_NOME")
   Private xProduto  := _Item + " - " + Alltrim(_Produto) + " - " + Alltrim(_Descricao)
   Private xVolumes  := 0
   Private xQtdTotal := 0 
   Private xQtdInfom := 0
   Private xQtdSaldo := 0

   Private xVol01 := 0
   Private xVol02 := 0
   Private xVol03 := 0
   Private xVol04 := 0
   Private xVol05 := 0

   Private xQtd01 := 0
   Private xQtd02 := 0
   Private xQtd03 := 0
   Private xQtd04 := 0
   Private xQtd05 := 0

   Private xVol06 := 0
   Private xVol07 := 0
   Private xVol08 := 0
   Private xVol09 := 0
   Private xVol10 := 0

   Private xQtd06 := 0
   Private xQtd07 := 0
   Private xQtd08 := 0
   Private xQtd09 := 0
   Private xQtd10 := 0

   Private xVol11 := 0
   Private xVol12 := 0
   Private xVol13 := 0
   Private xVol14 := 0
   Private xVol15 := 0

   Private xQtd11 := 0
   Private xQtd12 := 0
   Private xQtd13 := 0
   Private xQtd14 := 0
   Private xQtd15 := 0

   Private oGet1                                                                                                
   Private oGet10                                                                                               
   Private oGet11                                                                                               
   Private oGet12                                                                                               
   Private oGet13                                                                                               
   Private oGet14                                                                                               
   Private oGet15                                                                                               
   Private oGet16                                                                                               
   Private oGet17                                                                                               
   Private oGet18                                                                                               
   Private oGet19                                                                                               
   Private oGet2                                                                                                
   Private oGet20                                                                                               
   Private oGet21                                                                                               
   Private oGet22                                                                                               
   Private oGet23                                                                                               
   Private oGet24                                                                                               
   Private oGet25                                                                                               
   Private oGet26                                                                                               
   Private oGet27                                                                                               
   Private oGet28                                                                                               
   Private oGet29                                                                                               
   Private oGet3                                                                                                
   Private oGet30                                                                                               
   Private oGet31                                                                                               
   Private oGet32                                                                                               
   Private oGet33                                                                                               
   Private oGet34                                                                                               
   Private oGet4                                                                                                
   Private oGet5                                                                                                
   Private oGet6                                                                                                
   Private oGet7                                                                                                
   Private oGet8                                                                                                
   Private oGet9                                                                                                
   Private oGet35
   Private oGet36
   Private oGet37   
                                                                                                              
   Private oDlgV

   // Pesquisa os dados para dispaly
   If Select("T_VOLUMES") > 0
      T_VOLUMES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_FILIAL ,"
   cSql += "       C6_ITEM   ,"
   cSql += "       C6_PRODUTO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C6_ZVOLUME)) AS VOLUMES"
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(_Pedido)  + "'"
   cSql += "   AND C6_ITEM    = '" + Alltrim(_Item)    + "'"
   cSql += "   AND C6_PRODUTO = '" + Alltrim(_Produto) + "'"
   cSql += "   AND D_E_L_E_T_= ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VOLUMES", .T., .T. )

   If T_VOLUMES->( EOF() )
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Dados para este produto não localizados. Verifique!")
      Return(.T.)
   Else

      xVolumes  := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", 1), "@", 1))
      xQtdTotal := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", 1), "@", 2))
      nPosicao  := 0

      If xQtdTotal == 0
         xQtdTotal := _Quantidade
      Endif

      For nContar = 1 to U_P_OCCURS(T_VOLUMES->VOLUMES, "|", 1)

          If U_P_OCCURS(U_P_CORTA(T_VOLUMES->VOLUMES, "|", nContar), "@", 1) <> 0
             Loop
          Endif
                       
          nPosicao := nPosicao + 1

          j := Strzero(nPosicao,2)

          xVol&j := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", nContar), "#", 1))
          xQtd&j := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", nContar), "#", 2))

          xQtdInfom := xQtdInfom + xQtd&j

      Next nContar

      xQtdSaldo := xQtdTotal - xQtdInfom

   Endif
                                                                                                              
   // Deseha a tela para display das variáveis
   DEFINE MSDIALOG oDlgV TITLE "Divisão de Volumes por Produtos" FROM C(178),C(181) TO C(523),C(769) PIXEL
                                                                                                              
   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgV
                                                                                                              
   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(285),C(001) PIXEL OF oDlgV                                
   @ C(063),C(003) GET oMemo2 Var cMemo2 MEMO Size C(285),C(001) PIXEL OF oDlgV                                
   @ C(144),C(003) GET oMemo3 Var cMemo3 MEMO Size C(285),C(001) PIXEL OF oDlgV                                
                                                                                                              
   @ C(036),C(005) Say "Nº Ped. Venda" Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                       
   @ C(038),C(046) Say "Cliente"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(051),C(046) Say "Produto"       Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(036),C(259) Say "Qtd Volumes"   Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(068),C(005) Say "Volumes"       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                             
   @ C(068),C(033) Say "Quantidades"   Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(068),C(102) Say "Volumes"       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                             
   @ C(068),C(130) Say "Quantidades"   Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(068),C(200) Say "Volumes"       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                             
   @ C(068),C(228) Say "Quantidades"   Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(149),C(005) Say "Qtd Total"     Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgV    
   @ C(149),C(071) Say "Qtd Informada" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(149),C(138) Say "Saldo"         Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgV        

   @ C(046),C(005) MsGet oGet33 Var xPedido  Size C(035),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgV When lChumba
   @ C(037),C(068) MsGet oGet1  Var xCliente Size C(184),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgV When lChumba        
   @ C(050),C(068) MsGet oGet34 Var xProduto Size C(184),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgV When lChumba        
   @ C(046),C(259) MsGet oGet2  Var xVolumes Size C(028),C(009) COLOR CLR_BLACK Picture "@E 999999" PIXEL OF oDlgV        

   @ C(158),C(005) MsGet oGet35 Var xQtdTotal Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV When lChumba 
   @ C(158),C(071) MsGet oGet36 Var xQtdInfom Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV When lChumba 
   @ C(158),C(138) MsGet oGet37 Var xQtdSaldo Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV When lChumba 

   @ C(079),C(005) MsGet oGet3  Var xVol01  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(079),C(033) MsGet oGet4  Var xQtd01  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(092),C(005) MsGet oGet5  Var xVol02  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(092),C(033) MsGet oGet9  Var xQtd02  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(105),C(005) MsGet oGet6  Var xVol03  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(105),C(033) MsGet oGet10 Var xQtd03  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(118),C(005) MsGet oGet7  Var xVol04  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(118),C(033) MsGet oGet11 Var xQtd04  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(131),C(005) MsGet oGet8  Var xVol05  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(131),C(033) MsGet oGet12 Var xqtd05  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )

   @ C(079),C(102) MsGet oGet13 Var xVol06  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(079),C(130) MsGet oGet18 Var xQtd06  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(092),C(102) MsGet oGet14 Var xVol07  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(092),C(130) MsGet oGet19 Var xQtd07  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(105),C(102) MsGet oGet15 Var xVol08  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(105),C(130) MsGet oGet20 Var xQtd08  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(118),C(102) MsGet oGet16 Var xVol09  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(118),C(130) MsGet oGet21 Var xQtd09  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(131),C(102) MsGet oGet17 Var xVol10  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(131),C(130) MsGet oGet22 Var xQtd10  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )

   @ C(079),C(200) MsGet oGet23 Var xVol11  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(079),C(228) MsGet oGet28 Var xQtd11  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(092),C(200) MsGet oGet24 Var xVol12  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(092),C(228) MsGet oGet29 Var xQtd12  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(105),C(200) MsGet oGet25 Var xVol13  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(105),C(228) MsGet oGet30 Var xQtd13  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(118),C(200) MsGet oGet26 Var xVol14  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(118),C(228) MsGet oGet31 Var xQtd14  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(131),C(200) MsGet oGet27 Var xVol15  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(131),C(228) MsGet oGet32 Var xQtd15  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
                                                                                                              
   @ C(155),C(212) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgV ACTION( GravaVolumes(_Pedido, _Cliente, _Loja, _Item, _Produto, _Descricao, xVolumes, _Quantidade) )
   @ C(155),C(251) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgv ACTION( oDlgV:End() )    
                                                                                                              
   ACTIVATE MSDIALOG oDlgV CENTERED                                                                               
                                                                                                              
Return(.T.)

// Função que calcula o saldo da quantidade
Static Function CalSldVol()

   Local nContar

   xQtdInfom := 0 

   For nContar = 1 to 15
       j := Strzero(nContar,2)
       xQtdInfom := xQtdInfom + xQtd&j
   Next nContar

   xQtdSaldo := xQtdTotal - xQtdInfom

   oGet35:Refresh()
   oGet36:Refresh()
   oGet37:Refresh()

Return(.T.)

// Função que grava os volumes informados para o produto selecionado
Static Function GravaVolumes(_Pedido, _Cliente, _Loja, _Item, _Produto, _Descricao, xVolumes, _Quantidade)

   Local tVolIndi := 0
   Local tQtdIndi := 0
   Local nContar  := 0
   Local lTemErro := .F.
   Local cLinha   := ""

   // Verifica se a quantidade total de volumes foi informada
   If xVolumes == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidade de volumes total não informado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // Verifica se a quantidade individual de volumes confere com a quantidade total de volumes   
   tVolIndi := xVol01 + xVol02 + xVol03 + xVol04 + xVol05 + xVol06 + xVol07 + xVol08 + xVol09 + xVol10 + xVol11 + xVol12 + xVol13 + xVol14 + xVol15 

   If tVolIndi <> xVolumes
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidade de volumes individuais não confere com a quantidade de volumes total." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif
   
   // Verifica se a quantidade individual de quantidades confere com a quantidade total de quantidades
   tQtdIndi := xQtd01 + xQtd02 + xQtd03 + xQtd04 + xQtd05 + xQtd06 + xQtd07 + xQtd08 + xQtd09 + xQtd10 + xQtd11 + xQtd12 + xQtd13 + xQtd14 + xQtd15

   If tQtdIndi <> _Quantidade
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidades individuais não confere com a quantidade total do produto." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // Verifica se existe informação de volume individual sem informação de quantidade
   lTemErro := .F.
   For nContar = 1 to 15
       j := Strzero(nContar,02)
       If xVol&j <> 0
          If xQtd&j == 0
             lTemErro := .T.
             Exit
          endif
       Endif
   Next nContar
   
   If lTemErro == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existe volumes sem informação de quantidades." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif
                       
   // Verifica se existe informação de quantidade sem informação de volume
   lTemErro := .F.
   For nContar = 1 to 15
       j := Strzero(nContar,02)
       If xQtd&j <> 0
          If xVol&j == 0
             lTemErro := .T.
             Exit
          endif
       Endif
   Next nContar
   
   If lTemErro == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existe quantidades sem informação de volumes." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // Prepara a variável para gravação
   cLinha := ""
   cLinha := Alltrim(Str(xVolumes)) + "@" + Alltrim(Str(xQtdTotal,10,02)) + "@|"
   For nContar = 1 to 15
       j := Strzero(nContar,2)
       If xVol&j <> 0
          cLinha := cLinha + Alltrim(Str(xVol&j)) + "#" + Alltrim(Str(xQtd&j,10,02)) + "#|"
       Endif
   Next nContar       

   // Pesquisa o produto na tabela SC6 para gravação dos volumes
   dbSelectArea("SC6")
   dbSetOrder(1)
   If dbSeek( xFilial("SC6") + _Pedido + _Item + _Produto )
 	  RecLock("SC6",.F.)
      SC6->C6_ZVOLUME := cLinha
	  MsUnLock()
   Endif

   oDlgV:End()

   psqnfgkn(cNota, cSerie, _Cliente, _Loja)

Return(.T.)





//   Local _nPosPN    := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "B1_PARNUM" } )
//   Local _nPosDoc   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_DOC" } )
//   Local _nPosQtd   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_QUANT" } )
//   Local _nPosSer   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_SERIE" } )
//   Local _nPosVol   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "F2_VOLUME1" } )
//   Local _nPosCod   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_COD" } )
//   Local _nPosDesc  := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "B1_DESC" } )
//   Local _nPosPBr   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "F2_PBRUTO" } )



//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////






























// Função que imprime a etiqueta
Static function xAUTR270A(_aItens,_aCabec, cPorta)

  Local   _nOpc      := 0
  Local   _aArea     := GetArea()

  Private _oDlgExp
  Private _oBtOk
  Private _ocCliente
  Private _oCliente
  Private coCliente  := Posicione("SA1",1,xFilial("SA1")+"000859"+"001","A1_NOME")
  Private _oLbNota
  Private _onSerie
  Private conSerie   := "1  "
  Private _oNumNota
  Private coNumNota  := "014284   "
  Private _onVolumes
  Private _oSerie
  Private _oTotVol
  Private oButton2
  Private oGroup1 
  Private __aItens
  Private __aCabec
  Private _cNotaTela := Alltrim(coNumNota)+"/"+Alltrim(conSerie)           
  Private __nTotVol  := 0

  DEFINE MSDIALOG _oDlgExp TITLE "Informações Adicionais" FROM 000, 000  TO 450, 750 COLORS 0, 16777215 PIXEL

  @ 047, 007 GROUP  oGroup1 TO 188, 370                    OF _oDlgExp COLOR 0, 16777215 PIXEL
  @ 006, 006 GROUP  oGroup2 TO 045, 370                    OF _oDlgExp COLOR 0, 16777215 PIXEL
  @ 193, 006 GROUP  oGroup3 TO 217, 370                    OF _oDlgExp COLOR 0, 16777215 PIXEL

  @ 012, 012 SAY    _oLbNota    PROMPT "Nota:"             SIZE 025, 007 OF _oDlgExp COLORS 0, 16777215 PIXEL
  @ 011, 048 MSGET  _oNumNota   VAR _cNotaTela             SIZE 057, 010 OF _oDlgExp COLORS 0, 16777215 READONLY PIXEL

  @ 029, 013 SAY    _ocCliente  PROMPT "Cliente:"          SIZE 025, 007 OF _oDlgExp COLORS 0, 16777215 PIXEL
  @ 028, 046 MSGET  _oCliente   VAR coCliente              SIZE 239, 010 OF _oDlgExp COLORS 0, 16777215 READONLY PIXEL

  @ 202, 014 SAY    _oTotVol    PROMPT "Total de Volumes:" SIZE 060, 011 OF _oDlgExp COLORS 0, 16777215 PIXEL
  @ 202, 076 SAY    _onVolumes  PROMPT "0"                 SIZE 025, 007 OF _oDlgExp COLORS 0, 16777215 PIXEL

  @ 199, 276 BUTTON oButton2    PROMPT "Cancelar"          Action(_oDlgExp:End())             SIZE 037, 012 OF _oDlgExp PIXEL
  @ 199, 329 BUTTON _oBtOk      PROMPT "Confirmar"         Action( AUTR256A(__aItens, __aCabec,"LPT1"),_oDlgExp:End() )   SIZE 037, 012 OF _oDlgExp PIXEL
    
  fMSNewGetDados1(coNumNota,conSerie,"000859","001")

  ACTIVATE MSDIALOG _oDlgExp
          
  RestArea(_aArea)                                               

Return(.T.)



// Função que imprime a etiqueta
Static function AUTR270A(_aItens,_aCabec, cPorta)

   Local cPorta  := cPorta
   Local nQtetq  := 1      
   Local _nPosPN    := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "B1_PARNUM" } )
   Local _nPosDoc   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_DOC" } )
   Local _nPosQtd   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_QUANT" } )
   Local _nPosSer   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_SERIE" } )
   Local _nPosVol   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "F2_VOLUME1" } )
   Local _nPosCod   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "D2_COD" } )
   Local _nPosDesc  := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "B1_DESC" } )
   Local _nPosPBr   := aScan( _aCabec, { | x | AllTrim( x[ 2 ] ) == "F2_PBRUTO" } )
   Local _cCodBar   := ""
   Local _nIt       := 0
   Local _nVol      := 0
   Local _nTamQtd   := 10 //Numérico
   Local _nTamIt    := 14 //Caracter
   Local _nTamUM    := 02 //Caracter
   Local _nTamLot   := 10 //Caracter
   Local _nTamSub   := 08 //Numérico
   Local _cCodPos1  := ""
   Local _cCodPos2  := ""
   Local _cCodPos3  := ""
   Local _cCodPos4  := ""
   Local _cCodPos5  := ""
   Local _nAtuEt    := 0

   // 1º - Rotação
   // 2º - Fonte
   // 3º - Largura
   // 4º - Altura
   // 5º - Tamanho do Fonte
   // 6º - Linha
   // 7º - Coluna
   // 8º - Dados
   __nTotVol := 0

   For _i:= 1 to Len(_aItens)
       __nTotVol += _aItens[_i][_nPosVol]
   Next _i

   For _nIt := 1 to 1//to Len(_aItens) //Todos os itens       

	   DbSelectArea("SB1")
	   DbSetOrder(1)
	   DbSeek(xFilial("SB1") + _aItens[_nIt][_nPosCod])

	   For _nVol := 1 to 1 //_aItens[_nIt][_nPosVol] //Quantidade de volumes
		   _nAtuEt++
		   MSCBPRINTER("DATAMAX",cPorta)
		   MSCBCHKSTATUS(.F.)
		   MSCBBEGIN(2,6,)
		   MSCBWRITE("^FO202,19"          + chr(13))
		   MSCBWRITE("^GB204,801,6^FS"    + chr(13))
		   MSCBWRITE("^FO202,615"         + chr(13))
		   MSCBWRITE("^GB204,205,6^FS"    + chr(13))
		   MSCBWRITE("^FO481,19"          + chr(13))
		   MSCBWRITE("^GB85,801,6^FS"     + chr(13))
		   MSCBWRITE("^FO401,555"         + chr(13))
		   MSCBWRITE("^GB85,265,6^FS"     + chr(13))
		   MSCBWRITE("^FO401,19"          + chr(13))
		   MSCBWRITE("^GB85,266,6^FS"     + chr(13))
		   MSCBWRITE("^FO122,19"          + chr(13))
		   MSCBWRITE("^GB85,266,6^FS"     + chr(13))
		   MSCBWRITE("^FO42,19"           + chr(13))
		   MSCBWRITE("^GB85,265,6^FS"     + chr(13))
   		   MSCBWRITE("^FT332,611"         + chr(13))
		   MSCBWRITE("^CI0"               + chr(13)) 
		   _nTamPAr := 14
                             

 && ^A0B,37,48^FD
 
		   MSCBWRITE("^A0B,10,48^FD"+Alltrim(SB1->B1_PARNUM)+Space(_nTamPAr-len(Alltrim(SB1->B1_PARNUM)))+" "+Transform(_aItens[_nIt][_nPosQtd]  ,"@E 99,999.99")+"    "+SB1->B1_UM+"^FS"    + chr(13)) //Qunatidade

		   MSCBWRITE("^FT469,801"                            + chr(13))
		   MSCBWRITE("^A0B,37,49^FD"                         +_aItens[_nIt][_nPosDoc]+"/"+_aItens[_nIt][_nPosSer]+"^FS"    + chr(13)) //Doc e Série
		   MSCBWRITE("^FT469,499"                            + chr(13))
		   MSCBWRITE("^A0B,37,49^FD"+StrZero(_nAtuEt,2)+" / "+Strzero(__nTotVol,2)+"^FS"               + chr(13)) //Qtd Volume
		   MSCBWRITE("^FT469,195"                            + chr(13))
		   MSCBWRITE("^A0B,37,49^FD"+Transform(_aItens[_nIt][_nPosPBr]  ,"@E 9,999.99")+"^FS"    + chr(13))   //Peso
		   MSCBWRITE("^FT173,758"                            + chr(13))
		   MSCBWRITE("^A0B,25,33^FDSISTEMAS DE AUTOMACAO LTDA^FS"  + chr(13))
		   MSCBWRITE("^FT104,217"                            + chr(13))
		   MSCBWRITE("^A0B,25,36^FD"+STRZERO(Day(DATE()),2) +"/"+ STRZERO(Month(DATE()),2) +"/" + STRZERO(YEAR(DATE()),4)+"^FS"    + chr(13))
		   MSCBWRITE("^FT181,263"                            + chr(13))
		   MSCBWRITE("^A0B,20,26^FD"+SB1->B1_COD+"^FS"       + chr(13))
		   MSCBWRITE("^FT548,801"                            + chr(13))

		   MSCBWRITE("^A0B,25,31^FD"+Substr(Alltrim(SB1->B1_DESC)+" "+Alltrim(SB1->B1_DAUX),1,52)+"^FS"    + chr(13))

		   MSCBWRITE("^FT424,817"                            + chr(13))
		   MSCBWRITE("^A0B,20,24^FD   Nota Fiscal :^FS"      + chr(13))
		   MSCBWRITE("^FT425,557"                            + chr(13))
		   MSCBWRITE("^A0B,20,23^FD  Numero de Volume:^FS"   + chr(13))
		   MSCBWRITE("^FT425,282"                            + chr(13))
		   MSCBWRITE("^A0B,20,23^FD  Peso Total (kg):^FS"    + chr(13))
		   MSCBWRITE("^FT503,801"                            + chr(13))
		   MSCBWRITE("^A0B,20,24^FDDescricao da Peca:^FS"    + chr(13))
		   MSCBWRITE("^FT224,611"                            + chr(13))
		   MSCBWRITE("^A0B,20,22^FDCodigo Peca GKN : ^FS"    + chr(13))
		   MSCBWRITE("^FT226,293"                            + chr(13))
		   MSCBWRITE("^A0B,23,25^FDQuantidade:^FS"           + chr(13))
		   MSCBWRITE("^FT226,130"                            + chr(13))
		   MSCBWRITE("^A0B,23,25^FDUnidade:^FS"              + chr(13))
		   MSCBWRITE("^FT66,806"                             + chr(13))
		   MSCBWRITE("^A0B,23,25^FDFornecedor:^FS"           + chr(13))
		   MSCBWRITE("^FT66,270"                             + chr(13))
		   MSCBWRITE("^A0B,23,25^FDData:^FS"                 + chr(13))
		   MSCBWRITE("^FT146,270"                            + chr(13))
		   MSCBWRITE("^A0B,23,24^FDCod. Peca Fornecedor:^FS" + chr(13))
		   MSCBWRITE("^FO239,663"                            + chr(13))
		
		   // - No de etiqueta: 10 caract. (numerico) : Numero sequencial unico da etiqueta por item, a fim de evitar duplicidade na conferencia;
	       // - Quantidade: 7 caract. (numerico) „³ Quantidade por caixa ou pallet;
		   // - Item: 14 caract. (alfanumerico) „³ PN usado pela GKN;
		   // - Unid. Medida: 2 caract. (alfanumerico) „³ deve ser descrito se a quantidade sera medida em pecas (PC), Quilos (KG), etc.
		   // - Lote: 10 caract. (alfanumerico) „³ informacao fornecida pelo fornecedor
		   // - Subcontratado: 8 caract. (numerico) „³ Numeracao fixa usada pela GKN para identificar os fornecedores.
		   // 	Caso nao preencha o numero de caracteres informado:
		   //  	Numerico: numero zero na esquerda.
		   //  	Alfanumerico: espacos vazios na direita.

		   _cCodPos0 := StrZero(1, 10)                                                      //10 Numero sequencial unico da etiqueta por item, a fim de evitar duplicidade na conferencia
 		   _cCodPos1 := StrZero(Int(_aItens[_nIt][_nPosQtd]), _nTamQtd)                     //Qtde: 7 caract. (numérico)
		   _cCodPos2 := Alltrim(SB1->B1_PARNUM)+Space(_nTamIt-Len(Alltrim(SB1->B1_PARNUM))) //Item: 14 caract. (alfanumérico)
		   _cCodPos3 := Alltrim(SB1->B1_UM)                                                 //Unid. Medida: 2 caract. (alfanumérico)
		   _cCodPos4 := Space(_nTamLot)                                                     //Lote: 10 caract. (alfanumérico)
		   _cCodPos5 := StrZero(0,_nTamSub)                                                 //Subcontratado: 8 caract. (numérico)
		  
	       _cCodBar := _cCodPos0+_cCodPos1+_cCodPos2+_cCodPos3+_cCodPos4+_cCodPos5

		   MSCBWRITE("^F500,40^BQ,50,4^FDQA,"+_cCodBar+"^FS"   + chr(13)) //Código de Barras
		   MSCBWRITE("^FO42,19"                                + chr(13))
		   MSCBWRITE("^GB524,801,6^FS"                         + chr(13))
		   MSCBWRITE("^FT118,744"                              + chr(13))
		   MSCBWRITE("^A0B,51,68^FDAUTOMATECH^FS"              + chr(13))
		   MSCBWRITE("^PQ1,0,1,Y"                              + chr(13))
		   MSCBWRITE("^XZ"                                     + chr(13))
		
		   MSCBEND()
		
		   MSCBCLOSEPRINTER()
	   
	   Next _nVol
   
   Next _nIt

Return

//------------------------------------------------ 
Static Function fMSNewGetDados1(_cNota,_cSerie,_cCliente,_cLoja)

   Local nX
   Local aHeaderEx    := {}
   Local aColsEx      := {}
   Local aFieldFill   := {}
   Local aFields      := {}
   Local aAlterFields := {}
   Local _cValid      := ""
   
   Private oMSNew

   aAdd(aFields,"D2_QUANT")
   aAdd(aFields,"F2_PBRUTO")
   aAdd(aFields,"F2_VOLUME1")
   aAdd(aFields,"D2_ITEM")
   aAdd(aFields,"D2_COD")
   aAdd(aFields,"B1_DESC")
   aAdd(aFields,"B1_PARNUM")
   aAdd(aFields,"D2_DOC")
   aAdd(aFields,"D2_SERIE")

   // Define field properties
   DbSelectArea("SX3")
   SX3->(DbSetOrder(2))
   For nX := 1 to Len(aFields)
	   If SX3->(DbSeek(aFields[nX]))
		 
		  Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
					  	   SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	   Endif
   Next nX

   aColsEx :=  _BuscaDados(_cNota,_cSerie,_cCliente,_cLoja,aFields)

   If Empty(aColsEx)
	  // Define field values
	  For nX := 1 to Len(aFields)
		  If DbSeek(aFields[nX])
			 Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		  Endif
	  Next nX
	  
	  Aadd(aFieldFill, .F.)
	
	  Aadd(aColsEx, aFieldFill)

   EndIf

   //Itens que podem ser alterados
   aAdd(aAlterFields,"D2_QUANT")
   aAdd(aAlterFields,"F2_PBRUTO")
   aAdd(aAlterFields,"F2_VOLUME1")

   oMSNew   := MsNewGetDados():New(058, 015, 182, 358,GD_UPDATE, "U_SomaVolume()"/*lok*/, "AllwaysTrue"/*tok*/,'', aAlterFields,, 999, "AllwaysTrue"  , "", "AllwaysTrue" , _oDlgExp, aHeaderEx, aColsEx)
   __aItens := aClone(aColsEx)
   __aCabec := aClone(aHeaderEx)

Return                 

Static Function _BuscaDados(_cNota,_cSerie,_cCliente,_cLoja,aFields)

   Local _aRet      := {} 
   Local aFieldFill := {}
   Local _aArea     := GetArea()
   Local _nTotVol   := 0

   cSql := "SELECT             "
   cSql += "       D2_COD     ,"
   cSql += "       D2_ITEM    ,"
   cSql += "       D2_QUANT   ,"
   cSql += "       F2_PBRUTO  ,"
   cSql += "       F2_VOLUME1 ,"
   cSql += "       B1_DESC    ,"
   cSql += "       B1_PARNUM  ,"
   cSql += "       D2_DOC     ,"
   cSql += "       D2_SERIE    "
   cSql += "  FROM " + RetSqlName("SD2")+" SD2 "
   cSql += "  Inner Join " + RetSqlName("SF2") +" SF2 On ( F2_FILIAL  = D2_FILIAL  " 
   cSql += " 										  And  F2_TIPO    = D2_TIPO    "
   cSql += " 										  And  F2_DOC     = D2_DOC     "
   cSql += " 										  And  F2_SERIE   = D2_SERIE   "
   cSql += " 										  And  F2_CLIENTE = D2_CLIENTE "
   cSql += " 										  And  F2_LOJA    = D2_LOJA    "
   cSql += " 										  And  SF2.D_E_L_E_T_   = '')  "
   cSql += "  Inner Join " + RetSqlName("SB1") +" SB1 On ( B1_FILIAL  = '" + xFilial("SB1") + "' "
   cSql += " 										  And  B1_COD     = D2_COD     "
   cSql += " 										  And  SB1.D_E_L_E_T_   = '')  "
   cSql += " WHERE D2_DOC         = '" + Alltrim(_cNota)    + "'"
   cSql += "   AND D2_SERIE       = '" + Alltrim(_cSerie)   + "'"
   cSql += "   AND D2_CLIENTE     = '" + Alltrim(_cCliente) + "'"
   cSql += "   AND D2_LOJA        = '" + Alltrim(_cLoja)    + "'"
   cSql += "   AND D2_FILIAL      = '" + xFilial("SD2")     + "'"
   cSql += "   AND SD2.D_E_L_E_T_ = ''"
   cSql += "   ORDER BY D2_ITEM "

   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "TMP", .T., .T. )
   
   While TMP->(!eOf()) 
   	   aFieldFill:= {}

	   // Define field values
  	   For nX := 1 to Len(aFields)
          Aadd(aFieldFill, &("TMP->"+aFields[nX]))
          If aFields[nX] == "F2_VOLUME1"
	          _nTotVol += &("TMP->"+aFields[nX])
          EndIf
  	   Next nX
	   Aadd(aFieldFill, .F.)
  	 
  	   Aadd(_aRet, aFieldFill)
   	
       TMP->(DbSkip())
   EndDo

   TMP->(DbCloseArea())

   _onVolumes:cCapTion := Alltrim(Str(_nTotVol))
             
   RestArea(_aArea)

Return(_aRet)

User Function SomaVolume()

   Local _nTotVol :=  0
   Local _nPosVol   := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "F2_VOLUME1" } )

   For _i:= 1 to Len(aCols)
      _nTotVol += aCols[_i][_nPosVol]
   Next _i

   _onVolumes:cCapTion := Alltrim(Str(_nTotVol))
   __aItens := aClone(aCols)
   __aCabec := aClone(aHeader)

Return .t.

*/