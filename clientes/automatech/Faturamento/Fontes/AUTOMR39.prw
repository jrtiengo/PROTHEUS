#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR39.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/04/2012                                                          *
// Objetivo..: Programa que importa o arquivo de clientes no formato:              *
//             Código do Vendedor                                                  *
//             Nome do Vendedor                                                    *
//             Código do Cliente                                                   *
//             Loja do Cliente                                                     *  
//**********************************************************************************

User Function AUTOMR39()

   Private cCaminho := Space(60)
   Private oGet1

   Private oDlg

   U_AUTOM628("AUTOMR39")

   DEFINE MSDIALOG oDlg TITLE "Importação de Vendedores Layout II" FROM C(178),C(181) TO C(270),C(596) PIXEL

   @ C(005),C(006) Say "Arquivo a ser importado" Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(006) MsGet oGet1 Var cCaminho Size C(192),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(027),C(119) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION ( ImpVenCli(cCaminho) )
   @ C(027),C(160) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return .T.

// Função que le o arquivo especificado para importação
Static Function ImpVenCli( cCaminho )

   Local nContar   := 0
   Local cCliente  := ""
   Local aClientes := {}

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado não informado.")
      Return .T.
   Endif
          
   If !File(Alltrim(cCaminho))
      MsgAlert("Arquivo informado inexistente. Verifique !!")
      Return .T.
   Endif

   // Abre o arquivo ser lido da Aprove e atualiza a coluna do Browse
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cCliente  := ""
   lPrimeiro := .T.

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
 
          cCliente := cCliente + Substr(xBuffer, nContar, 1)
                
       Else

          // Separa os campos em variáveis
          _Vendedor := ""
          _Nome     := ""
          _Cliente  := ""
          _Loja     := ""
          
          cCliente  := StrTran(cCliente, Chr(9), "#")

          If lPrimeiro
             _Vendedor := Substr(cCliente,01,06)
             _Cliente  := Substr(cCliente,21,06)
             _Loja     := Substr(cCliente,28,03)
             lPrimeiro := .F.
          Else   
             _Vendedor := Substr(cCliente,02,06)
             _Cliente  := Substr(cCliente,22,06)
             _Loja     := Substr(cCliente,29,03)
          Endif   
             
          aAdd(aClientes, { _Cliente, _Loja } )

          // Posiciona o cliente para limpar o código do vendedor
          DbSelectArea("SA1")
          DbSetOrder(1)
          DbSeek(xfilial("SA1") + _Cliente + _Loja )
          Reclock("SA1",.f.)

          If _Vendedor == "000000"
             A1_VEND := ""
          Else
             A1_VEND := _Vendedor
          Endif   
                  
          Msunlock()

          cCliente := ""

          If Substr(xBuffer, nContar, 1) == chr(10)
             nContar += 1
          Endif   
            
       Endif

   Next nContar    
    
Return .T.      
      








/*



   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	     := {}
   Local _aAlias  	     := {}
   Local lAbre           := .F.

   // Variáveis Locais da Função
   Private dData01       := Ctod("  /  /    ")
   Private dData02       := Ctod("  /  /    ")
   Private cCaminho01    := Space(100)
   Private cCaminho02    := Space(100)
   Private cCaminho03    := Space(100)

   // Totalizadores da Contabilidade
   Private nProdutoV     := 0
   Private nServicoV     := 0
   Private nDevolveV     := 0
   Private nTotalV       := 0

   // Totalizadores da Aprove
   Private nProdutoA     := 0
   Private nServicoA     := 0
   Private nDevolveA     := 0
   Private nTotalA       := 0

   // Totalizadores das Diferenças
   Private nProdutoD     := 0
   Private nServicoD     := 0
   Private nDevolveD     := 0
   Private nTotalD       := 0

   Private nDiferenca    := 0
   Private nLeiProduto   := 0
   Private nLeiServico   := 0
   Private nLeiDevolucao := 0

   Private nMaiorAut   := 0
   Private nMaiorApr   := 0
   Private NomeCam1    := Space(100)
   Private NomeCam2    := Space(100)
   Private NomeCam3    := Space(100)

   Private oCheckBox1
   Private lCheckBox1

   NomeCam1 := Replicate(".", 100)
   NomeCam2 := Replicate(".", 100)
   NomeCam3 := Replicate(".", 100)

   Private nGet1	   := Ctod("  /  /    ")
   Private nGet2	   := Ctod("  /  /    ")
   Private nGet3	   := Space(100)
   Private nGet4	   := Space(100)
   Private nGet5	   := 0
   Private nGet6	   := 0
   Private nGet7	   := 0
   Private nGet8	   := 0
   Private nGet9	   := 0
   Private nGet10	   := 0
   Private nGet11      := 0      
   Private nGet12      := 0      
   Private nGet13      := 0      
   Private nGet14      := 0      
   Private nGet15      := 0      
   Private nGet16      := 0      
   Private nGet17      := 0         
   Private nGet18      := Space(100)

   Private aBrowse     := {}
   Private aTransito   := {}
   
   // Variáveis Private da Função
   Private cCliente      := Space(06)
   Private cLoja         := Space(03)
   Private cProduto      := Space(30)
   Private cProducao     := Space(06)
   Private cPedido       := Space(06)
   Private cAtendimento  := Space(06)
   Private cNomeCliente  := Space(60)
   Private cNomeProduto  := Space(60)
   Private oFont12b

   // Diálogo Principal
   Private oDlg

   DEFINE FONT oFont   Name "Arial" Size 0, -10 BOLD

   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg TITLE "Comparativo APROVE X AUTOMATECH" FROM C(000),C(000) TO C(470),C(1000) PIXEL

   // Solicita os Parâmetros para impressão das Ordens de Produção
   @ C(012),C(005) Say "Data Inicial:"                  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(005) Say "Data Final:  "                  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(008),C(100) Say "Produtos: "                     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(100) Say "Serviços:"                      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(100) Say "Devoluções:"                    Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

// @ C(011),C(300) Say "Total Leitura Arquivo:"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(027),C(300) Say "Total Leitura Arquivo:"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg


   @ C(164),C(005) Say "TOTAIS DA CONTABILIDADE" Size C(050),C(020) FONT oFont12b COLOR CLR_BLACK PIXEL OF oDlg
   @ C(175),C(005) Say "Total Produtos"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(005) Say "Total Serviços"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(005) Say "Total Devoluções"        Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(223),C(005) Say "Total"                   Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(164),C(110) Say "TOTAIS DA AUTOMATECH"   Size C(100),C(020) FONT oFont12b COLOR CLR_BLACK PIXEL OF oDlg
   @ C(175),C(110) Say "Total Produtos"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(110) Say "Total Serviços"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(191),C(150) Say "Total Devoluções AUTOMATECH:"   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(110) Say "Total Devoluções"       Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(223),C(110) Say "Total"                  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(164),C(220) Say "DIFERENÇAS CONTABILIDADE X AUTOMATECH"   Size C(100),C(020) FONT oFont12b COLOR CLR_BLACK PIXEL OF oDlg
   @ C(175),C(220) Say "Total Produtos"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(220) Say "Total Serviços"         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(191),C(150) Say "Total Devoluções AUTOMATECH:"   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(220) Say "Total Devoluções"       Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(223),C(220) Say "Total"                  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(175),C(360) Say "Valor A MAIOR na AUTOMATECH" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(360) Say "Valor A MAIOR na APROVE"     Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg   

// @ C(223),C(300) Say "Diferença APROVE X AUTOMATECH:" Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(011),C(035) MsGet oGet1  Var dData01             Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(024),C(035) MsGet oGet2  Var dData02             Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   @ C(008),C(130) Say NomeCam1 Size C(140),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(130) Say NomeCam2 Size C(140),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(130) Say NomeCam3 Size C(140),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg

   // Totalizadores da Contabilidade
   @ C(172),C(040) MsGet oGet5  Var nProdutoV   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(040) MsGet oGet6  Var nServicoV   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(040) MsGet oGet15 Var nDevolveV   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(220),C(040) MsGet oGet7  Var nTotalV     When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   // Totalizadores da Automatech
   @ C(172),C(150) MsGet oGet8  Var nProdutoA   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(150) MsGet oGet9  Var nServicoA   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(150) MsGet oGet15 Var nDevolveA   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(220),C(150) MsGet oGet11 Var nTotalA     When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   // Totalizadores das Diferenças
   @ C(172),C(260) MsGet oGet8  Var nProdutoD   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(260) MsGet oGet9  Var nServicoD   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(260) MsGet oGet15 Var nDevolveD   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(220),C(260) MsGet oGet11 Var nTotalD     When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

// @ C(220),C(400) MsGet oGet12 Var nDiferenca  When lAbre Size C(060),C(010) PICTURE "@EZ 999,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   @ C(172),C(430) MsGet oGet16 Var nMaiorAut   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(430) MsGet oGet17 Var nMaiorApr   When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

//   @ C(010),C(350) MsGet oGet13 Var nLeiProduto When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg
//   @ C(023),C(350) MsGet oGet14 Var nLeiServico When lAbre Size C(060),C(010) PICTURE "@EZ 9,999,999.99" COLOR CLR_BLACK PIXEL OF oDlg

   @ C(020),C(320) CHECKBOX oCheckBox1 VAR lCheckBox1 PROMPT "Visualizar Somente Registros com Diferenças" SIZE 150, 014 OF oDlg COLORS 0, 16777215 PIXEL

   @ C(007),C(080) Button "..." Size C(015),C(010) PIXEL OF oDlg ACTION( PESQARQ1(1) )
   @ C(020),C(080) Button "..." Size C(015),C(010) PIXEL OF oDlg ACTION( PESQARQ1(2) )
   @ C(033),C(080) Button "..." Size C(015),C(010) PIXEL OF oDlg ACTION( PESQARQ1(3) )

   @ C(010),C(450) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( CAPTURADADOS( dData01, dData02, cCaminho01, cCaminho02) )
   @ C(023),C(450) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end()  )

   oBrowse := TSBrowse():New(060,005,630,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('FL'        ,,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Nº NF'     ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Série'     ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Cliente'   ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New("Prod. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Serv. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Dev.  Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Total Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Prod. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Serv. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Dev.  Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Total Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:AddColumn( TCColumn():New("Diferença"   ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED  

Return .T.

// Função que abre diálogo de pesquisa dos arquivos a serem lidos
Static Function PESQARQ1( _Botao )

   Do Case
      Case _Botao == 1
           cCaminho01 := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)
           NomeCam1   := Upper(cCaminho01)
      Case _Botao == 2
           cCaminho02 := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)
           NomeCam2   := Upper(cCaminho02)
      Case _Botao == 3
           cCaminho03 := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)
           NomeCam3   := Upper(cCaminho03)
   EndCase

Return .T. 

// Função que define a Window
Static Function CAPTURADADOS( dData01, dData02, cCaminho01, cCaminho02 )

     Local nLidos
     Local nTamArq
     Local aCNPJ 
     Local nContar    := 0
     Local nAlen
     Local cSql 
     Local nReg
     Local cProduto   := space(30)
     Local nPosicao
     Local nPipe      := 1
     Local cLinha     := ""
     Local _Codigo    := ""
     Local _PartNum   := ""
     Local _Nome01    := ""
     Local _Nome02    := ""
     Local _Ativo     := ""
     Local aProdutos  := {}
     Local nProduto   := 0
     Local nServico   := 0
     Local nFilial    := ""
     Local nDocumento := ""
     Local nSerie     := ""
     Local nCliente   := ""
     Local aNotas     := {}
     Local nProcura   := 0
     Local lAchei     := .F.
     Local nNovoValor := ""
     Local nTotDevolu := 0
     Local nTabs      := 0
     Local _Valor01   := ""
     Local aLinhas    := {}
     Local aFiltrados := {}
     Local _TotalNF   := ""
     Local _Limpado   := ""
     Local _LimpaNF   := ""

     Private xBuffer

     If Empty(dData01)
        Msgalert("Data inicial de pesquisa não informada.")
        Return .T.
     Endif   

     If Empty(dData02)
        Msgalert("Data final de pesquisa não informada.")
        Return .T.
     Endif   

     If dData02 < dData01
        Msgalert("Datas inconsistentes.")
        Return .T.
     Endif   

     If Empty(Alltrim(cCaminho01)) .and. Empty(Alltrim(cCaminho02)) .and. Empty(Alltrim(cCaminho03))
        Msgalert("Necessario informar pelo menos um do(s) arquivo(s) a ser(em) importado(s).")
        Return .T.
     Endif   

     If !Empty(cCaminho01)
        If !File(Alltrim(cCaminho01))
           MsgAlert("Arquivo de importação de Produtos inexistente.")
           Return .T.
        Endif
     Endif
        
     If !Empty(cCaminho02)
        If !File(Alltrim(cCaminho02))
           MsgAlert("Arquivo de importação de Serviços inexistente.")
           Return .T.
        Endif
     Endif

     If !Empty(cCaminho03)
        If !File(Alltrim(cCaminho03))
           MsgAlert("Arquivo de importação de Devoluções inexistente.")
           Return .T.
        Endif
     Endif

     oBrowse := TSBrowse():New(060,005,630,140,oDlg,,1,,1)
     oBrowse:AddColumn( TCColumn():New('FL'        ,,,{|| },{|| }) ) 
     oBrowse:AddColumn( TCColumn():New('Nº NF'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Série'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Cliente'   ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New("Prod. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Prod. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Diferença"   ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:SetArray(aBrowse)

     // Pesquisa o faturamento do período

     // Pesquisa os dados para emissão do relatório
     If Select("RESULTADO") > 0
        RESULTADO->( dbCloseArea() )
     EndIf

     cSql := ""   
     cSql := "SELECT A.D2_FILIAL , "
     cSql += "       A.D2_DOC    , "
     cSql += "       A.D2_SERIE  , "
     cSql += "       A.D2_EMISSAO, "
     cSql += "       A.D2_TES    , "
     cSql += "       G.F4_DUPLIC , "
     cSql += "       G.F4_ISS    , "
     cSql += "       A.D2_CF     , "
     cSql += "       A.D2_PEDIDO , "
     cSql += "       F.C5_FRETE  , "
     cSql += "       A.D2_CLIENTE, "
     cSql += "       A.D2_LOJA   , "
     cSql += "       C.A1_NOME   , "
     cSql += "       C.A1_MUN    , "
     cSql += "       C.A1_EST    , "
     cSql += "       A.D2_ITEM   , "
     cSql += "       A.D2_COD    , "
     cSql += "       D.B1_DESC   , "
     cSql += "       D.B1_DAUX   , "
     cSql += "       D.B1_TIPO   , "
     cSql += "       A.D2_UM     , "
     cSql += "       A.D2_QUANT  , "
//   cSql += "       A.D2_TOTAL  , "
     cSql += "       A.D2_VALBRUT, "
     cSql += "       A.D2_VALFRE , "
     cSql += "       F.C5_FORNEXT  "
     cSql += "  FROM " + RetSqlName("SD2010") + " A, "
     cSql += "       " + RetSqlName("SF2010") + " B, "
     cSql += "       " + RetSqlName("SA1010") + " C, "
     cSql += "       " + RetSqlName("SB1010") + " D, "
     cSql += "       " + RetSqlName("SC5010") + " F, "
     cSql += "       " + RetSqlName("SF4010") + " G  "
     cSql += " WHERE B.F2_DOC       = A.D2_DOC    "
     cSql += "   AND B.F2_FILIAL    = A.D2_FILIAL "
     cSql += "   AND B.F2_SERIE     = A.D2_SERIE  "
     csql += "   AND B.F2_TIPO      = 'N'         "
     cSql += "   AND A.D2_CLIENTE   = C.A1_COD    "
     cSql += "   AND A.D2_LOJA      = C.A1_LOJA   "
     cSql += "   AND A.D2_COD       = D.B1_COD    "
     cSql += "   AND A.D2_PEDIDO    = F.C5_NUM    "
     cSql += "   AND F.C5_FILIAL    = A.D2_FILIAL "
     cSql += "   AND F.R_E_C_D_E_L_ = ''          "
     cSql += "   AND A.D2_TES       = G.F4_CODIGO "
     cSql += "   AND (G.F4_DUPLIC   = 'S' OR A.D2_TES = '543')"
     cSql += "   AND A.R_E_C_D_E_L_ = ''          "
     cSql += "   AND B.R_E_C_D_E_L_ = ''          "
     cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
     cSql += " ORDER BY A.D2_FILIAL, A.D2_DOC, A.D2_SERIE, C.A1_NOME "

     cSql := ChangeQuery( cSql )
     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

     RESULTADO->( DbGoTop() )
     
     nFilial    := RESULTADO->D2_FILIAL
     nDocumento := RESULTADO->D2_DOC
     nSerie     := RESULTADO->D2_SERIE
     nCliente   := RESULTADO->A1_NOME

     While !RESULTADO->( EOF() )
 
        If RESULTADO->D2_TES == "543"
           RESULTADO->( DbSkip() )
           Loop
        Endif

        If Alltrim(RESULTADO->D2_SERIE) == "P1" .AND. ;
           Alltrim(RESULTADO->D2_SERIE) == "P2" .AND. ;
           Alltrim(RESULTADO->D2_SERIE) == "P3"
           RESULTADO->( DbSkip() )
           Loop
        Endif

        If RESULTADO->D2_FILIAL == nFilial    .AND. ;
           RESULTADO->D2_DOC    == nDocumento .AND. ;
           RESULTADO->D2_SERIE  == nSerie     .AND. ;
           RESULTADO->A1_NOME   == nCliente
           
           If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
              nServico := nServico + RESULTADO->D2_VALBRUT
           Else   
//              nProduto := nProduto + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                nProduto := nProduto + RESULTADO->D2_VALBRUT
           Endif   
           
           RESULTADO->( DbSkip() )
           
           Loop
           
        Else
     
           aAdd(aBrowse, { nFilial                        ,; // Código da Filial
                           nDocumento                     ,; // Nº da Nota Fiscal
                           nSerie                         ,; // Série da Nota Fiscal
                           nCliente                       ,; // Nome do Cliente
                           Str(0,10,02)                   ,; // Valor Totao dos Produtos da Aprove
                           Str(0,10,02)                   ,; // Valor Total dos Serviços da Aprove
                           Str(0,10,02)                   ,; // Valor Total das Devoluções da Aprove
                           Str(0,10,02)                   ,; // Valor Total da Aprove                          
                           Str(nProduto,10,02)            ,; // Valor Total dos Produtos da Automatech
                           Str(nServico,10,02)            ,; // Valor Total dos Serviços da Automatech
                           Str(0,10,02)                   ,; // Valor Total das Devoluções da Automatech
                           Str(nProduto + nServico,10,02) ,; // Valor Total da Automatech
                           Str(0,10,02) } )                  // Valor Total das Diferenças entre Aprove x Automatech

           nFilial    := RESULTADO->D2_FILIAL
           nDocumento := RESULTADO->D2_DOC
           nSerie     := RESULTADO->D2_SERIE
           nCliente   := RESULTADO->A1_NOME

           nProduto   := 0
           nServico   := 0
           
           If RESULTADO->F4_DUPLIC == "S" .AND. RESULTADO->F4_ISS == "S"
              nServico := nServico + RESULTADO->D2_VALBRUT
           Else   
//              nProduto := nProduto + RESULTADO->D2_TOTAL + RESULTADO->D2_VALFRE
                nProduto := nProduto + RESULTADO->D2_VALBRUT
           Endif   

           RESULTADO->( DbSkip() )

        Endif   
        
     Enddo

     aAdd(aBrowse, { nFilial                        ,; // Código da Filial
                     nDocumento                     ,; // Nº da Nota Fiscal
                     nSerie                         ,; // Série da Nota Fiscal
                     nCliente                       ,; // Nome do Cliente
                     Str(0,10,02)                   ,; // Valor Totao dos Produtos da Aprove
                     Str(0,10,02)                   ,; // Valor Total dos Serviços da Aprove
                     Str(0,10,02)                   ,; // Valor Total das Devoluções da Aprove
                     Str(0,10,02)                   ,; // Valor Total da Aprove                          
                     Str(nProduto,10,02)            ,; // Valor Total dos Produtos da Automatech
                     Str(nServico,10,02)            ,; // Valor Total dos Serviços da Automatech
                     Str(0,10,02)                   ,; // Valor Total das Devoluções da Automatech
                     Str(nProduto + nServico,10,02) ,; // Valor Total da Automatech
                     Str(0,10,02) } )                  // Valor Total das Diferenças entre Aprove x Automatech

     // Pesquisa as devoluções ref. ao período informado
     If Select("T_DEVOLUCAO") > 0
        T_DEVOLUCAO->( dbCloseArea() )
     EndIf

     csql = ""
     csql += "SELECT A.D1_FILIAL    ,"
     csql += "       A.D1_EMISSAO   ,"
     csql += "       A.D1_NFORI     ,"
     csql += "       A.D1_SERIORI   ," 
     csql += "       A.D1_TES       ,"
     csql += "       SUM(A.D1_TOTAL) AS DEVOLVE"
     csql += "  FROM " + RetSqlName("SD1010") + " A, "
     cSql += "       " + RetSqlName("SF4010") + " B  "
     cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
     csql += "   AND A.D1_NFORI    <> ''"
     csql += "   AND A.R_E_C_D_E_L_ = ''"
     cSql += "   AND A.D1_TES       = B.F4_CODIGO "
     cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "
     csql += " GROUP BY A.D1_FILIAL, A.D1_EMISSAO, A.D1_NFORI, A.D1_SERIORI, A.D1_TES"

     cSql := ChangeQuery( cSql )
     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLUCAO", .T., .T. )

     nTotDevolu := 0
     T_DEVOLUCAO->( DbGoTop() )
     While !T_DEVOLUCAO->( EOF() )
        nTotDevolu := nTotDevolu + T_DEVOLUCAO->DEVOLVE
        T_DEVOLUCAO->( DbSkip() )
     Enddo    

     T_DEVOLUCAO->( DbGoTop() )

     While !T_DEVOLUCAO->( EOF() )
 
        If T_DEVOLUCAO->D1_TES == "543"
           T_DEVOLUCAO->( DbSkip() )
           Loop
        Endif   

        // Pesquisa no array aBrowse o laçamento referente a nota fiscal da devolução
        For nContar = 1 to Len(aBrowse)

            If Alltrim(aBrowse[nContar,01]) == Alltrim(T_DEVOLUCAO->D1_FILIAL) .AND. ;
               Alltrim(aBrowse[nContar,02]) == Alltrim(T_DEVOLUCAO->D1_NFORI)  .AND. ;
               Alltrim(aBrowse[nContar,03]) == Alltrim(T_DEVOLUCAO->D1_SERIORI)

               aBrowse[nContar,11] := Str(val(aBrowse[nContar,11]) + T_DEVOLUCAO->DEVOLVE,10,02)
               aBrowse[nContar,12] := Str(Val(aBrowse[nContar,09]) + Val(aBrowse[nContar,10]) - Val(aBrowse[nContar,11]),10,02)
               
               Exit
               
            Endif
            
        Next nContar       
        
        T_DEVOLUCAO->( DbSkip() )
        
     Enddo   

     // Abre o arquivo ser lido da Aprove e atualiza a coluna do Browse
     // ---------------------------------------------------------------
     If !Empty(Alltrim(cCaminho01))
        nHandle := FOPEN(Alltrim(cCaminho01), FO_READWRITE + FO_SHARED)
     
        If FERROR() != 0
           MsgAlert("Erro ao abrir o arquivo de podutos da APROVE.")
           Return .T.
        Endif

        // Lê o tamanho total do arquivo
        nLidos :=0
	    FSEEK(nHandle,0,0)
	    nTamArq:=FSEEK(nHandle,0,2)
	    FSEEK(nHandle,0,0)

        // Lê todos os Produtos
        xBuffer:=Space(nTamArq)
        FREAD(nHandle,@xBuffer,nTamArq)
 
        // Carrega o Array aNotas
        aNotas      := {}
        cNotas      := ""
        nNota01     := ""
        nNota02     := ""
        nNota03     := ""     
        cProxima    := .F.
        nLimpa      := 0
        nLinha      := 0
        nPosicao    := 1
        nAlen       := 0
        nPipe       := 1
        aNotas      := {}
        cBuffer     := 1
        nContar     := 0
        nAlen       := 0
        nReg        := 0
        nPosicao    := 1
        nPontoVir   := 0
        nLeiProduto := 0
        aLinhas     := {}
        aFiltrados  := {}

        For nContar = 1 to Len(xBuffer)

            If Substr(xBuffer, nContar, 1) <> chr(13)
 
               cNotas := cNotas + Substr(xBuffer, nContar, 1)
                
            Else

               aAdd(aLinhas, { Alltrim(StrTran(cNotas, chr(9), "_")) } )

               cNotas := ""

               If Substr(xBuffer, nContar, 1) == chr(10)
                  nContar += 1
               Endif   
            
            Endif

        Next nContar    
            
        // Elimina os elementos do array que não utilizados
        For nContar = 1 to Len(aLinhas)
     
            If Substr(aLinhas[nContar,1],02,03) == "___"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,03) == "***"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,04) == "0357"
               Loop
            Endif
         
            If Substr(aLinhas[nContar,1],02,04) == "CNPJ"
               Loop
            Endif
            
            If Substr(aLinhas[nContar,1],02,03) == "Raz"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,04) == "Data"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,06) == "Conta:"
               Loop
            Endif

            If Substr(StrTran(aLinhas[nContar,1], chr(9), " "),13,05) == "Saldo"
               Loop
            Endif
     
            aAdd( aFiltrados, { StrTran(aLinhas[nContar,1], "_", " ") } )
         
        Next nContar    

        // Recarrega o Array aLista com os dados efetivos
        For nContar = 1 to Len(aFiltrados)

            // Verifica se existe a expressão R$ na String para separar o valor do Documento
            lTem     := .F.
            _TotalNF := ""
            For _Separa = 1 to Len(aFiltrados[nContar,1])

                If !lTem 
                   If Substr(aFiltrados[nContar,1], _Separa, 1) == "$"
                      lTem := .T.
                      Loop
                   Endif
                Else
                   _TotalNF := _TotalNF + Substr(aFiltrados[nContar,1], _Separa, 1)
                Endif
             
             Next _Separa
          
             If !Empty(Alltrim(_totalNF))

                // Limpa o Valor para Gravação
                _TotalNF := Alltrim(_TotalNF)
                _Limpado := ""
                For Limpa = 1 to Len(_TotalNF)
                    If Substr(Alltrim(_TotalNF),Limpa,1) == " "
                       Exit   
                    Else
                       _Limpado := _Limpado + Substr(_TotalNF,Limpa,1)
                    Endif
                Next Limpa

                _Limpado := StrTran(_Limpado, ".", "" )
                _Limpado := StrTran(_Limpado, ",", ".")             

                // Captura o nº da Nota Fiscal
                nContar += 1
                _NotaFiscal := Alltrim(Substr(aFiltrados[nContar,1],02,7))
                _LimpaNF    := ""
                For Limpa = 1 to Len(_NotaFiscal)
                    If Substr(_NotaFiscal,Limpa,1) == " "
                       Exit   
                    Else
                       If Substr(_NotaFiscal,Limpa,1) == "1" .OR. Substr(_NotaFiscal,Limpa,1) == "2" .OR. ;
                          Substr(_NotaFiscal,Limpa,1) == "3" .OR. Substr(_NotaFiscal,Limpa,1) == "4" .OR. ;
                          Substr(_NotaFiscal,Limpa,1) == "5" .OR. Substr(_NotaFiscal,Limpa,1) == "6" .OR. ;                                                               
                          Substr(_NotaFiscal,Limpa,1) == "7" .OR. Substr(_NotaFiscal,Limpa,1) == "8" .OR. ;
                          Substr(_NotaFiscal,Limpa,1) == "9" .OR. Substr(_NotaFiscal,Limpa,1) == "0"
                          _LimpaNF := _LimpaNF + Substr(_NotaFiscal,Limpa,1)
                       Endif
                    Endif
                Next Limpa

                aAdd(aNotas, { Strzero(Int(Val(_LimpaNF)),6), Alltrim(_Limpado) } )

             Endif
          
        Next nContar

        nLeiProduto := 0
        For nContar = 1 to Len(aNotas)
            nLeiProduto := nLeiProduto + Val(aNotas[nContar,2])
        nExt nContar

        lAchei := .F.

        For nContar = 1 to Len(aNotas)
                  
            // Localiza no array aBrowse o possível lançamento do array aNotas - Série 1 - Porto Alegre
            For nProcura = 1 to Len(aBrowse)
                If Alltrim(aBrowse[nProcura,02]) == Alltrim(aNotas[nContar,01]) .AND. ;                        // Nota Fisca
                   Alltrim(aBrowse[nProcura,03]) == "1"                         .AND. ;                        // Série da Nota Fiscal
                   ALLTRIM(STR(VAL(aBrowse[nProcura,09]),10,02)) == ALLTRIM(STR(VAL(aNotas[nContar,2]),10,02)) // Valor da Nota Fiscal
                   aBrowse[nProcura,05] := Alltrim(aNotas[nContar,02])
                   lAchei    := .T.
                   Exit
                Endif
            Next nProcura        
        
            // Localiza no array aBrowse o possível lançamento do array aNotas - Série 2 - Caxias do Sul
            If !lAchei  
               For nProcura = 1 to Len(aBrowse)
                   If Alltrim(aBrowse[nProcura,02]) == Alltrim(aNotas[nContar,01]) .AND. ;                        // Nota Fisca
                      Alltrim(aBrowse[nProcura,03]) == "2"                         .AND. ;                        // Série da Nota Fiscal
                      ALLTRIM(STR(VAL(aBrowse[nProcura,09]),10,02)) == ALLTRIM(STR(VAL(aNotas[nContar,2]),10,02)) // Valor da Nota Fiscal
                      aBrowse[nProcura,05] := Alltrim(aNotas[nContar,02])
                      lAchei := .T.
                      Exit
                   Endif
               Next nProcura        
            Endif  

            // Localiza no array aBrowse o possível lançamento do array aNotas - Série 3 - Caxias do Sul
            If !lAchei  
               For nProcura = 1 to Len(aBrowse)
                   If Alltrim(aBrowse[nProcura,02]) == Alltrim(aNotas[nContar,01]) .AND. ;                        // Nota Fisca
                      Alltrim(aBrowse[nProcura,03]) == "3"                         .AND. ;                        // Série da Nota Fiscal
                      ALLTRIM(STR(VAL(aBrowse[nProcura,09]),10,02)) == ALLTRIM(STR(VAL(aNotas[nContar,2]),10,02)) // Valor da Nota Fiscal
                      aBrowse[nProcura,05] := Alltrim(aNotas[nContar,02])
                      lAchei := .T.
                      Exit
                   Endif
               Next nProcura        
            Endif  

            lAchei := .F.

        Next nContar   
        
     Endif   

     // Abre o arquivo ser lido da Aprove e atualiza a coluna do Browse
     // ---------------------------------------------------------------
     If !Empty(Alltrim(cCaminho02))

        nHandle := FOPEN(Alltrim(cCaminho02), FO_READWRITE + FO_SHARED)
     
        If FERROR() != 0
           MsgAlert("Erro ao abrir o arquivo de Serviços da APROVE.")
           Return .T.
        Endif

        // Lê o tamanho total do arquivo
  	    nLidos :=0
 	    FSEEK(nHandle,0,0)
 	    nTamArq:=FSEEK(nHandle,0,2)
	    FSEEK(nHandle,0,0)

        // Lê todos os Produtos
        xBuffer:=Space(nTamArq)
        FREAD(nHandle,@xBuffer,nTamArq)

        // Carrega o Array aNotas
        aNotas      := {}
        cNotas      := ""
        nNota01     := ""
        nNota02     := ""
        nNota03     := ""     
        cProxima    := .F.
        nLimpa      := 0
        nLinha      := 0
        nPosicao    := 1
        nAlen       := 0
        nPipe       := 1
        aNotas      := {}
        cBuffer     := 1
        nContar     := 0
        nAlen       := 0
        nReg        := 0
        nPosicao    := 1
        nPontoVir   := 0
        nLeiServico := 0

        For nContar = 1 to Len(xBuffer)

            If Substr(xBuffer, nContar, 1) <> chr(13)
            
               cNotas := cNotas + Substr(xBuffer, nContar, 1)
                 
            Else

               If Empty(Substr(cNotas,01,63))
                  nContar += 13
                  cNotas := ""
                  Loop   
               Endif

               If Alltrim(Substr(cNotas,13,04)) == "VLR."

                  _Nota   := Alltrim(Substr(cnotas,34,04))
                  nNota02 := ""
               
                  For _Limpa = 1 to Len(_Nota)
                      
                      If Empty(Alltrim(Substr(_Nota,_Limpa,1)))
                         Exit
                      Endif

                      If Substr(_Nota,_Limpa,1) == "1" .OR. Substr(_Nota,_Limpa,1) == "2" .OR. ;
                         Substr(_Nota,_Limpa,1) == "3" .OR. Substr(_Nota,_Limpa,1) == "4" .OR. ;
                         Substr(_Nota,_Limpa,1) == "5" .OR. Substr(_Nota,_Limpa,1) == "6" .OR. ;                                                               
                         Substr(_Nota,_Limpa,1) == "7" .OR. Substr(_Nota,_Limpa,1) == "8" .OR. ;
                         Substr(_Nota,_Limpa,1) == "9" .OR. Substr(_Nota,_Limpa,1) == "0"
                         nNota02 := nNota02 + Substr(_nota,_limpa,1)
                      Endif

                  Next _Limpa

                  nNota03  := Strzero(Int(val(nNota02)),6)

                  // Laço que separa o valor da nota fiscal
                  nTabs    := 0
                  _Valor01 := ""
                  For _Separacao = 1 to Len(cNotas)

                      If nTabs < 6
                         If Substr(cNotas, _Separacao, 1) == CHR(9)
                            nTabs := nTabs + 1
                         Endif
                      Else
                         If Substr(cNotas, _Separacao, 1) == CHR(9)                     
                            Exit
                         Endif   
                         _Valor01 := _Valor01 + Substr(cNotas, _Separacao, 1)                   
                      Endif

                  Next _Separacao                   
                          
                  nValor01 := ""

                  For _Limpa = 1 to Len(_Valor01)

                      If Empty(Alltrim(Substr(_Valor01,_Limpa,1)))
                         Loop
                      Endif   

                      If Substr(_Valor01,_Limpa,1) == CHR(9)
                         Loop
                      Endif   

                      If Substr(_Valor01,_Limpa,1) == "1" .OR. Substr(_Valor01,_Limpa,1) == "2" .OR. ;
                         Substr(_Valor01,_Limpa,1) == "3" .OR. Substr(_Valor01,_Limpa,1) == "4" .OR. ;
                         Substr(_Valor01,_Limpa,1) == "5" .OR. Substr(_Valor01,_Limpa,1) == "6" .OR. ;                                                               
                         Substr(_Valor01,_Limpa,1) == "7" .OR. Substr(_Valor01,_Limpa,1) == "8" .OR. ;
                         Substr(_Valor01,_Limpa,1) == "9" .OR. Substr(_Valor01,_Limpa,1) == "0" .OR. ;
                         Substr(_Valor01,_Limpa,1) == "," .OR. Substr(_Valor01,_Limpa,1) == "."
                         nValor01 := nValor01 + Substr(_Valor01,_limpa,1)
                      Endif

                   Next _Limpa

                   // Elimina o ponto e substitui a vírgula para gravação
                   nNovoValor := ""
                   For _Separa = 1 to Len(nValor01)

                       If Substr(nValor01, _Separa, 1) == " "
                          Exit
                       Endif

                       If Substr(nValor01, _Separa, 1) == "."
                          Loop
                       Endif
                      
                       If Substr(nValor01, _Separa, 1) == ","
                          nNovoValor := nNovoValor + "."
                          Loop
                       Endif

                       nNovoValor := nNovoValor + Substr(nValor01, _Separa, 1)
    
                   Next _Separa    

                   nValor02 := nNovoValor

                   aAdd(aNotas, { nNota03, nValor02 } )
         
                   nLeiServico := nLeiServico + Val(nValor02)

                Endif

                cNotas := ""

                If Substr(xBuffer, nContar, 1) == chr(10)
                   nContar += 1
                Endif   
            
             Endif

         Next nContar    

         lAchei    := .F.
  
         For nContar = 1 to Len(aNotas)
                  
             // Localiza no array aBrowse o possível lançamento do array aNotas - Série 51 - Serviços Porto Alegre
             For nProcura = 1 to Len(aBrowse)
                 If Alltrim(aBrowse[nProcura,02]) == Alltrim(aNotas[nContar,01]) .AND. ;                        // Nota Fiscal 
                    Alltrim(aBrowse[nProcura,03]) == "51"                        .AND. ;                        // Série da Nota Fiscal
                    ALLTRIM(STR(VAL(aBrowse[nProcura,10]),10,02)) == ALLTRIM(STR(VAL(aNotas[nContar,2]),10,02)) // Valor da Nota Fiscal
                    aBrowse[nProcura,06] := aNotas[nContar,02]
                    lAchei := .T.
                    Exit
                 Endif
             Next nProcura        
        
             // Localiza no array aBrowse o possível lançamento do array aNotas - Série 52 - Serviços Caxias do Sul
             If !lAchei
                For nProcura = 1 to Len(aBrowse)
                    If Alltrim(aBrowse[nProcura,02]) == Alltrim(aNotas[nContar,01]) .AND. ;                        // Nota Fiscal 
                       Alltrim(aBrowse[nProcura,03]) == "52"                        .AND. ;                        // Série da Nota Fiscal
                       ALLTRIM(STR(VAL(aBrowse[nProcura,10]),10,02)) == ALLTRIM(STR(VAL(aNotas[nContar,2]),10,02)) // Valor da Nota Fiscal
                       aBrowse[nProcura,06] := aNotas[nContar,02]
                       lAchei := .T.
                       Exit
                    Endif
                Next nProcura        
             Endif   

             // Localiza no array aBrowse o possível lançamento do array aNotas - Série 53 - Serviços Pelotas
             If !lAchei
                For nProcura = 1 to Len(aBrowse)
                    If Alltrim(aBrowse[nProcura,02]) == Alltrim(aNotas[nContar,01]) .AND. ;                        // Nota Fiscal 
                       Alltrim(aBrowse[nProcura,03]) == "53"                        .AND. ;                        // Série da Nota Fiscal
                       ALLTRIM(STR(VAL(aBrowse[nProcura,10]),10,02)) == ALLTRIM(STR(VAL(aNotas[nContar,2]),10,02)) // Valor da Nota Fiscal
                       aBrowse[nProcura,06] := aNotas[nContar,02]
                       lAchei := .T.
                       Exit
                    Endif
                Next nProcura        
             Endif  

             lAchei := .F.

         Next nContar   
         
     Endif    

     // Trata os dados do arquivo de Devoluções da Aprove
     // -------------------------------------------------
     If !Empty(Alltrim(cCaminho03))

        nHandle := FOPEN(Alltrim(cCaminho03), FO_READWRITE + FO_SHARED)
     
        If FERROR() != 0
           MsgAlert("Erro ao abrir o arquivo de Devoluções.")
           Return .T.
        Endif

        // Lê o tamanho total do arquivo
        nLidos :=0
	    FSEEK(nHandle,0,0)
	    nTamArq:=FSEEK(nHandle,0,2)
	    FSEEK(nHandle,0,0)

        // Lê todos os Produtos
        xBuffer:=Space(nTamArq)
        FREAD(nHandle,@xBuffer,nTamArq)
 
        // Carrega o Array aNotas
        aNotas        := {}
        cNotas        := ""
        nNota01       := ""
        nNota02       := ""
        nNota03       := ""     
        cProxima      := .F.
        nLimpa        := 0
        nLinha        := 0
        nPosicao      := 1
        nAlen         := 0
        nPipe         := 1
        aNotas        := {}
        cBuffer       := 1
        nContar       := 0
        nAlen         := 0
        nReg          := 0
        nPosicao      := 1
        nPontoVir     := 0
        nLeiDevolucao := 0
        aLinhas       := {}
        aFiltrados    := {}

        For nContar = 1 to Len(xBuffer)

            If Substr(xBuffer, nContar, 1) <> chr(13)
 
               cNotas := cNotas + Substr(xBuffer, nContar, 1)
                
            Else

               aAdd(aLinhas, { Alltrim(StrTran(cNotas, chr(9), "_")) } )

               cNotas := ""

               If Substr(xBuffer, nContar, 1) == chr(10)
                  nContar += 1
               Endif   
            
            Endif

        Next nContar    
            
        // Elimina os elementos do array que não utilizados
        For nContar = 1 to Len(aLinhas)
     
            If Substr(aLinhas[nContar,1],02,03) == "___"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,03) == "***"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,05) == "_0357"
               Loop
            Endif
         
            If Substr(aLinhas[nContar,1],02,05) == "_CNPJ"
               Loop
            Endif
            
            If Substr(aLinhas[nContar,1],02,04) == "_Raz"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,05) == "_Data"
               Loop
            Endif

            If Substr(aLinhas[nContar,1],02,06) == "_Conta"
               Loop
            Endif

            If Substr(StrTran(aLinhas[nContar,1], chr(9), " "),13,05) == "Saldo"
               Loop
            Endif
     
            aAdd( aFiltrados, { StrTran(aLinhas[nContar,1], "_", " ") } )
         
        Next nContar    

        // Recarrega o Array aLista com os dados efetivos
        For nContar = 1 to Len(aFiltrados)
                
            _String := ALLTRIM(SUBSTR(aFiltrados[nContar,01],01,08))
            _String := STRTRAN(_string, chr(13), "")
            _String := STRTRAN(_string, chr(09), "")            
            _String := STRTRAN(_string, " "    , "")                        

            If Substr(_String,3,4) <> "FE.N" .AND. Substr(aFiltrados[nContar,1],11,06) <> "Matriz"
               Loop
            Endif

            // Captura o nº da nota fiscal de devolução
            If Substr(_String,3,4) == "FE.N"
               _LimpaNF := ALLTRIM(STR(INT(VAL(Alltrim(Substr(aFiltrados[nContar,1],11,09))))))
               If Len(_LimpaNF) < 6
                  _LimpaNF := Strzero(INT(VAL(_LimpaNF)),6)
               Endif
            Endif

            // Captura o valor da nota fiscal de devolução
            If Substr(aFiltrados[nContar,1],11,06) == "Matriz"
               _Limpado := Alltrim(Substr(aFiltrados[nContar,1],18,10))
               _Limpado := StrTran(_Limpado, ".", "")
               _Limpado := StrTran(_Limpado, ",", ".")               
               aAdd(aNotas, { Alltrim(_LimpaNF), Alltrim(_Limpado) } )
               _LimpaNF := ""
               _Limpado := ""

            Endif

        Next nContar

        nLeiDevolucao := 0
        For nContar = 1 to Len(aNotas)
            nLeiDevolucao := nLeiDevolucao + Val(aNotas[nContar,2])
        nExt nContar

        // Pesquisa na tabela D1 a nota fiscal de entrada.
        // Captura o nº da NF de Origem e pesquisa na tabela D2 a Nota de Origem para associar a NF da Contabilidade
        lAchei := .F.

        For nContar = 1 to Len(aNotas)
                  
            If Select("T_ORIGEM") > 0
               T_ORIGEM->( dbCloseArea() )
            EndIf

            csql := ""
            csql := "SELECT A.D1_DOC                 , "                           
            csql += "       A.D1_NFORI               , "
            csql += "       A.D1_SERIORI             , "
            csql += "       SUM(A.D1_TOTAL) AS _TOTAL  "
            csql += "  FROM " + RetSqlName("SD1010") + " A, "
            cSql += "       " + RetSqlName("SF4010") + " B  "
            cSql += " WHERE A.D1_DTDIGIT  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
            csql += "   AND A.D1_DOC         = '" + ALLTRIM(aNotas[nContar,1]) + "'"
            csql += "   AND A.R_E_C_D_E_L_ = ''"
            cSql += "   AND A.D1_TES       = B.F4_CODIGO "
            cSql += "   AND (B.F4_DUPLIC   = 'S' OR A.D1_TES = '543') "
            csql += " GROUP BY D1_DOC, D1_NFORI, D1_SERIORI "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORIGEM", .T., .T. )

            If !T_ORIGEM->( EOF() )

               // Localiza no array aBrowse o possível lançamento do array aNotas - Série 1 - Porto Alegre
               For nProcura = 1 to Len(aBrowse)
                   If Alltrim(aBrowse[nProcura,02]) == Alltrim(T_ORIGEM->D1_NFORI) .AND. ;                    // Nota Fisca
                      Alltrim(aBrowse[nProcura,03]) == "1"                         .AND. ;                    // Série da Nota Fiscal
                      ALLTRIM(STR(VAL(aBrowse[nProcura,11]),10,02)) == ALLTRIM(STR(T_ORIGEM->_TOTAL,10,02)) // Valor da Nota Fiscal
                      aBrowse[nProcura,07] := Alltrim(Str(_Total,10,02))
                      lAchei := .T.
                      Exit
                   Endif
               Next nProcura        
        
               // Localiza no array aBrowse o possível lançamento do array aNotas - Série 2 - Caxias do Sul
               If !lAchei  
                  For nProcura = 1 to Len(aBrowse)
                      If Alltrim(aBrowse[nProcura,02]) == Alltrim(T_ORIGEM->D1_NFORI) .AND. ;                    // Nota Fisca
                         Alltrim(aBrowse[nProcura,03]) == "2"                         .AND. ;                    // Série da Nota Fiscal
                         ALLTRIM(STR(VAL(aBrowse[nProcura,11]),10,02)) == ALLTRIM(STR(T_ORIGEM->_TOTAL,10,02)) // Valor da Nota Fiscal
                         aBrowse[nProcura,07] := Alltrim(Str(_Total,10,02))
                         lAchei := .T.
                         Exit
                      Endif
                  Next nProcura        
               Endif  

               // Localiza no array aBrowse o possível lançamento do array aNotas - Série 3 - Caxias do Sul
               If !lAchei  
                  For nProcura = 1 to Len(aBrowse)
                      If Alltrim(aBrowse[nProcura,02]) == Alltrim(T_ORIGEM->D1_NFORI) .AND. ;                  // Nota Fisca
                         Alltrim(aBrowse[nProcura,03]) == "3"                         .AND. ;                  // Série da Nota Fiscal
                         ALLTRIM(STR(VAL(aBrowse[nProcura,11]),10,02)) == ALLTRIM(STR(T_ORIGEM->_TOTAL,10,02)) // Valor da Nota Fiscal
                         aBrowse[nProcura,07] := Alltrim(Str(_Total,10,02))
                         lAchei := .T.
                         Exit
                      Endif
                  Next nProcura        
               Endif  

               lAchei := .F.

            ENDIF
            
         Next nContar   

     Endif   

     // Atualiza os totalizadores da pesquisa
     nProdutoV  := 0
     nServicoV  := 0
     nTotalV    := 0
     nProdutoA  := 0
     nServicoA  := 0
     nDevolveA  := 0
     nTotalA    := 0
     nDiferenca := 0

     // Acerta os totais do browse
     For nContar = 1to Len(aBrowse)
         aBrowse[ncontar,08] := Str(Val(aBrowse[nContar,05]) + Val(aBrowse[nContar,06]) - Val(aBrowse[nContar,07]),10,02)
         aBrowse[nContar,12] := Str(Val(aBrowse[ncontar,09]) + Val(aBrowse[nContar,10]) - Val(aBrowse[nContar,11]),10,02)
         aBrowse[nContar,13] := Str(Val(aBrowse[nContar,08]) - Val(aBrowse[nContar,12]),10,02)

         // Acumula os totalizadores da consulta
         nProdutoV := nProdutoV + Val(aBrowse[nContar,05])
         nServicoV := nServicoV + Val(aBrowse[ncontar,06])
         nDevolveV := nDevolveV + Val(aBrowse[ncontar,07])
         nTotalV   := nTotalV   + Val(aBrowse[nContar,08])

         nProdutoA := nProdutoA + Val(aBrowse[nContar,09])
         nServicoA := nServicoA + Val(aBrowse[nContar,10])
         nDevolveA := nDevolveA + Val(aBrowse[nContar,11])
         nTotalA   := nTotalA   + Val(aBrowse[nContar,12])

     Next nContar     

     nProdutoD := nProdutoA - nprodutoV
     nServicoD := nServicoA - nServicoV  
     nDevolveD := nDevolveA - nDevolveV  
     nTotalD   := nTotalA   - nTotalV    

     If nTotDevolu <> 0
        If nDevolveA > nTotDevolu
           nTotalA  := nTotalA - (nDevolveA - nTotDevolu)
           nOutrasA := nDevolveA - nTotDevolu
        Else
           nTotalA  := nTotalA - (nTotDevolu - nDevolveA)
           nOutrasA := nTotDevolu - nDevolveA
        Endif
     Endif

     nDevolveA  := nDevolveA + nOutrasA

     nDiferenca := nTotalV - nTotalA

     nMaiorAut  := 0
     nMaiorApr  := 0

     For nContar = 1 to Len(aBrowse)

         If Val(aBrowse[nContar,13]) == 0
            Loop
         Endif
          
         If Val(aBrowse[nContar,13]) < 0
            nMaiorAut := nMaiorAut + Val(aBrowse[nContar,13]) 
         Else
            nMaiorApr := nMaiorApr + Val(aBrowse[nContar,13]) 
         Endif   
         
     Next nContar    

     If nMaiorAut < 0
        nMaiorAut := nMaiorAut * -1
     Endif   

     If nMaiorApr < 0
        nMaiorApr := nMaiorApr * -1
     Endif   

     If lCheckbox1 == .T.

        aTransito := {}

        For nContar = 1 to Len(aBrowse)

            aAdd( aTransito, { aBrowse[nContar,01],; 
                               aBrowse[nContar,02],;
                               aBrowse[nContar,03],;
                               aBrowse[nContar,04],;
                               aBrowse[nContar,05],;
                               aBrowse[nContar,06],;
                               aBrowse[nContar,07],;
                               aBrowse[nContar,08],;                                                                                                                            
                               aBrowse[nContar,09],;
                               aBrowse[nContar,10],;
                               aBrowse[nContar,11],;
                               aBrowse[nContar,12],;
                               aBrowse[nContar,13] } )

        Next nContar

        aBrowse := {}

        For nContar = 1 to Len(aTransito)

            If VAL(aTransito[nContar,13]) == 0
               Loop
            Endif

            aAdd( aBrowse, { aTransito[nContar,01],; 
                             aTransito[nContar,02],;
                             aTransito[nContar,03],;
                             aTransito[nContar,04],;
                             aTransito[nContar,05],;
                             aTransito[nContar,06],;
                             aTransito[nContar,07],;
                             aTransito[nContar,08],;                                                                                                                            
                             aTransito[nContar,09],;
                             aTransito[nContar,10],;
                             aTransito[nContar,11],;
                             aTransito[nContar,12],;
                             aTransito[nContar,13] } )
                             
         Next nContar                    

     Endif

     oBrowse := TSBrowse():New(060,005,630,140,oDlg,,1,,1)
     oBrowse:AddColumn( TCColumn():New('FL'        ,,,{|| },{|| }) ) 
     oBrowse:AddColumn( TCColumn():New('Nº NF'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Série'     ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New('Cliente'   ,,,{|| },{|| }) )
     oBrowse:AddColumn( TCColumn():New("Prod. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aprove",{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Prod. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Serv. Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Dev.  Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Total Aut."  ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:AddColumn( TCColumn():New("Diferença"   ,{||},,,,"RIGHT",,.F.,.F.,,,,,))
     oBrowse:SetArray(aBrowse)

Return .T.

*/