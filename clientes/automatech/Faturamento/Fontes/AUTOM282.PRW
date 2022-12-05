#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM282.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/03/2015                                                          *
// Objetivo..: Emissão do relatório de Produtos em Locação                         *
//**********************************************************************************

// Função que define a Window
User Function AUTOM282()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	  := {}
   Local _aAlias  	  := {}
   Local cSql         := ""
   Local cProduto     := Space(30)
   Local lLibera      := .F.

   // Variáveis Private da Função
   Private dData01      := Ctod("  /  /    ")
   Private dData02      := Ctod("  /  /    ")
   Private cCliente     := Space(06)
   Private cLoja        := Space(03)
   Private cFornece     := Space(06)
   Private cFLoja       := Space(03)
   Private nSerie       := Space(20)
   Private __Empresa    := ""

   Private aComboBx1    := {}
   Private aComboBx2    := {"1 - Em Terceiros","2 - De Terceiros"}
   Private aComboBx3    := {"0 - Ambas", "1 - Somente em Aberto", "2 - Somente Encerradas"}
   Private aComboBx4    := {}
   Private aComboBx5    := {}
   Private cNomeCliente := Replicate("_",200)
   Private cNomeProduto := Replicate("_",200)
   Private cNomeFornece := Replicate("_",200)

   Private nGet1	 := Ctod("  /  /    ")
   Private nGet2	 := Ctod("  /  /    ")
   Private nGet3	 := Space(30)
   Private nGet4	 := Space(200)
   Private nGet5	 := Space(06)
   Private nGet6	 := Space(03)   
   Private nGet7	 := Space(06)   
   Private nGet8	 := Space(06) 
   Private nGet9	 := Space(03)        
   Private nGet10    := Space(20)

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   
   U_AUTOM628("AUTOM282")

   // Carrega o Combo de Filiais
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   __Empresa := SM0->M0_CODIGO
   aComboBx1 := U_AUTOM539(2, __Empresa) 

//   Do Case
//      Case __Empresa == "01"
//           aComboBx1  := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS", "04 - SUPRIMENTOS"}
//      Case __Empresa == "02"
//           aComboBx1  := {"01 - TI CURITIBA"}
//      Case __Empresa == "03"
//           aComboBx1  := {"01 - ATECH"}
//   EndCase

   // Diálogo Principal
   Private oDlg

   // Carrega o Combo de Vendedores
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD ,"
   cSql += "       A3_NOME "
   cSql += "  FROM " + RetSqlName("SA3010")
   cSql += " ORDER BY A3_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   T_VENDEDOR->( DbGoTop() )

   aAdd( aComboBx4, "000000 - Todos os Vendedores" )
   
   While !T_VENDEDOR->( EOF() )
      aAdd( aComboBx4, Alltrim(T_VENDEDOR->A3_COD) + " - " + Alltrim(T_VENDEDOR->A3_NOME) )
      T_VENDEDOR->( DBSKIP() )
   Enddo

   // Carrega o combo de grupos de produtos
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM010")
   cSql += " ORDER BY BM_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   T_GRUPO->( DbGoTop() )

   aAdd( aComboBx5, "0000 - TODOS OS GRUPOS" )
   
   While !T_GRUPO->( EOF() )
      aAdd( aComboBx5, Alltrim(T_GRUPO->BM_GRUPO) + " - " + Alltrim(T_GRUPO->BM_DESC) )
      T_GRUPO->( DBSKIP() )
   Enddo

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg TITLE "Acompanhamento de Demonstração de Produtos" FROM C(178),C(181) TO C(580),C(550) PIXEL

   // Solicita o nº da etiqueta a ser impressa
   @ C(040),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(085) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(005) Say "Filial:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

// @ C(055),C(005) Say "Tipo:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(070),C(005) Say "Status:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(085),C(005) Say "Vendedor:    " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(102),C(005) Say "Cliente:     " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(005) Say "Fornecedor:  " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(134),C(005) Say "Produto:     " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(168),C(005) Say "Nº Série:    " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(148),C(005) Say "Grupo:       " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(005) Jpeg FILE "logoautoma.bmp"  Size C(150),C(030) PIXEL NOBORDER OF oDlg
   
   @ C(102),C(080) Say      cNomeCliente                 Size C(090),C(020) COLOR CLR_BLACK              PIXEL OF oDlg
   @ C(117),C(080) Say      cNomeFornece                 Size C(090),C(020) COLOR CLR_BLACK              PIXEL OF oDlg
   @ C(134),C(090) Say      cNomeProduto                 Size C(080),C(020) COLOR CLR_BLACK              PIXEL OF oDlg

   @ C(038),C(035) MsGet    oGet1        Var   dData01   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(038),C(115) MsGet    oGet2        Var   dData02   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   @ C(055),C(035) ComboBox cComboBx1    Items aComboBx1 Size C(140),C(010)                              PIXEL OF oDlg
// @ C(055),C(035) ComboBox cComboBx2    Items aComboBx2 Size C(140),C(010)                              PIXEL OF oDlg
   @ C(070),C(035) ComboBox cComboBx3    Items aComboBx3 Size C(140),C(010)                              PIXEL OF oDlg
   @ C(085),C(035) ComboBox cComboBx4    Items aComboBx4 Size C(140),C(010)                              PIXEL OF oDlg
   @ C(101),C(035) MsGet    oGet5        Var   cCliente  Size C(010),C(010) COLOR CLR_BLACK Picture "@!" F3('SA1') PIXEL OF oDlg
   @ C(101),C(062) MsGet    oGet6        Var   cLoja     Size C(004),C(010) COLOR CLR_BLACK Picture "@!" VALID(TrazCliente( cCliente, cLoja)) PIXEL OF oDlg
   @ C(115),C(035) MsGet    oGet8        Var   cFornece  Size C(010),C(010) COLOR CLR_BLACK Picture "@!" F3('SA2') PIXEL OF oDlg
   @ C(115),C(062) MsGet    oGet9        Var   cFLoja    Size C(004),C(010) COLOR CLR_BLACK Picture "@!" VALID(TrazFornece( cFornece, cFLoja)) PIXEL OF oDlg
   @ C(133),C(035) MsGet    oGet7        Var   cProduto  Size C(055),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNProd(cProduto) )
   @ C(148),C(035) ComboBox cComboBx5    Items aComboBx5 Size C(140),C(010)                              PIXEL OF oDlg         
   @ C(166),C(035) MsGet    oGet10       Var   nSerie    Size C(045),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(180),C(081) Button "Relatório"     Size C(030),C(012) PIXEL OF oDlg ACTION( I_LOCACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cComboBx4, cComboBx5, cCliente, cLoja, cProduto, cFornece, cFloja, "R" ))
   @ C(180),C(113) Button "Exportar"      Size C(030),C(012) PIXEL OF oDlg ACTION( I_LOCACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cComboBx4, cComboBx5, cCliente, cLoja, cProduto, cFornece, cFloja, "E" ))
   @ C(180),C(145) Button "Voltar"        Size C(030),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que trás a descrição do Cliente informado
Static Function TrazCliente( _Cliente, _Loja )

   Local cSql := ""
   
   If Empty(_Cliente)
      If Select("T_PRODUTO") > 0
         T_CLIENTE->( dbCloseArea() )
      EndIf
      cNomeCliente := Replicate("_",200)
      Return .T.
   Endif   

   If Select("T_CLIENTE") > 0
   	  T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, " 
   cSql += "       A1_NOME  "
   cSql += "  FROM " + RetSqlName("SA1010")
   cSql += " WHERE A1_COD  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(_Loja)    + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
	
    If !T_CLIENTE->( EOF() )
       cCliente     := T_CLIENTE->A1_COD
       cLoja        := T_CLIENTE->A1_LOJA
       cNomeCliente := Alltrim(T_CLIENTE->A1_NOME)
    Else
       MsgAlert("Cliente informado inexistente.")
       cCliente     := Space(06)
       cLoja        := Space(03)
       cNomeCliente := Replicate("_",200)
    Endif

    If Select("T_CLIENTE") > 0
   	   T_CLIENTE->( dbCloseArea() )
    EndIf

Return .T.

// Função que trás a descrição do Fornecedor informado
Static Function TrazFornece( _Fornece, _FLoja )

   Local cSql := ""
   
   If Empty(_Fornece)
      If Select("T_PRODUTO") > 0
         T_CLIENTE->( dbCloseArea() )
      EndIf
      cNomeFornece := Replicate("_",200)
      Return .T.
   Endif   

   If Select("T_FORNECE") > 0
   	  T_FORNECE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A2_COD , "
   cSql += "       A2_LOJA, " 
   cSql += "       A2_NOME  "
   cSql += "  FROM " + RetSqlName("SA2010")
   cSql += " WHERE A2_COD  = '" + Alltrim(_Fornece) + "'"
   cSql += "   AND A2_LOJA = '" + Alltrim(_FLoja)   + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECE", .T., .T. )
	
    If !T_FORNECE->( EOF() )
       cFornece     := T_FORNECE->A2_COD
       cFLoja       := T_FORNECE->A2_LOJA
       cNomeFornece := Alltrim(T_FORNECE->A2_NOME)
    Else
       MsgAlert("Fornecedor informado inexistente.")
       cFornece     := Space(06)
       cFLoja       := Space(03)
       cNomeFornece := Replicate("_",200)
    Endif

    If Select("T_FORNECE") > 0
   	   T_FORNECE->( dbCloseArea() )
    EndIf

Return .T.

// Função que trás a descrição do produto selecionado
Static Function BuscaNProd( cProduto )

   Local cSql := ""
   
   If Empty(cProduto)
      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf
      cNomeProduto := Replicate("_",200)
      Return .T.
   Endif   

   If Select("T_PRODUTO") > 0
   	  T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := "SELECT B1_DESC, "
   cSql += "       B1_DAUX  "
   cSql += "  FROM " + RetSqlName("SB1010")
   cSql += " WHERE B1_COD = '" + Alltrim(cProduto) + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )
	
    If !T_PRODUTO->( EOF() )
       cNomeProduto := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
    Else
       MsgAlert("Produto informado inexistente.")
       cNomeProduto := Replicate("_",200)
    Endif

    If Select("T_PRODUTO") > 0
   	   T_PRODUTO->( dbCloseArea() )
    EndIf

Return .T.

// Função que prepara a impressão do relatório
Static Function I_LOCACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cComboBx4, cComboBx5, cCliente, cLoja, cProduto, cFornece, cFloja, cLetra )

   // Declaracao de Variaveis
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Vendedor"
   Local cPict          := ""
   Local titulo         := "Vendas por Vendedor"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}
   Local _Filial        := ""
   Local cCaminho       := ""
   
   _Filial := Substr(cComboBx1,01,02)

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""

   Private limite  := 220
   Private tamanho := "G"
   Private nomeprog     := "Locações"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Locações"
   Private cString      := "SC5"
   Private aDevolucao   := {}
   Private nDevolve     := 0

   Private nHdl
   Private cLinha       := ""
   
// Private limite  := 80
// Private tamanho := "P"
// Private nomeprog     := "AUTOMR08"

   Private aSaida   := {}
   Private aFiltro  := {}

   Private xComboBx1
   Private xComboBx2
   Private xComboBx3
   Private xComboBx4
   Private xComboBx5

   xComboBx1 := Substr(cComboBx1,01,02) // Filial
// xComboBx2 := Substr(cComboBx2,01,01) // Tipo
   xComboBx3 := Substr(cComboBx3,01,01) // Status
   xComboBx4 := Substr(cComboBx4,01,06) // Vendedor
   xComboBx5 := Substr(cComboBx5,01,04) // Grupo de Produtos

   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de emissão não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de emissão não informada.")
      Return .T.
   Endif

   If Empty(Alltrim(xComboBx1))
      MsgAlert("Filial não informada.")
      Return .T.
   Endif

// If Empty(Alltrim(xComboBx2))
//    MsgAlert("TES não informada.")
//    Return .T.
// Endif

   If Empty(Alltrim(xComboBx3))
      MsgAlert("Status não informado.")
      Return .T.
   Endif

   If Empty(Alltrim(xComboBx4))
      MsgAlert("Vendedor não informado.")
      Return .T.
   Endif

   // Pesquisa as devoluções ref. ao período informado
   If Select("T_DEMO") > 0
      T_DEMO->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.D2_FILIAL , B.F2_VEND1  , C.A3_NOME   , A.D2_TES    , A.D2_DOC    , " + chr(13)       
   cSql += "       A.D2_SERIE  , A.D2_EMISSAO, A.D2_CLIENTE, A.D2_LOJA   , A.D2_COD    , " + chr(13)       
   cSql += "       A.D2_ITEM   , A.D2_QUANT  , A.D2_PRCVEN , A.D2_TOTAL  , A.D2_PEDIDO , " + chr(13)       
   cSql += "       E.B1_DESC   , E.B1_DAUX   , A.D2_QUANT  , A.D2_PRCVEN , A.D2_TOTAL  , "    + chr(13)       
   cSql += "       D.C5_TIPO   " + chr(13)       
   cSql += "  FROM " + RetSqlName("SD2010") + " A, " + chr(13)       
   cSql += "       " + RetSqlName("SF2010") + " B, " + chr(13)       
   cSql += "       " + RetSqlName("SA3010") + " C, " + chr(13)       
   cSql += "       " + RetSqlName("SC5010") + " D, "       + chr(13)       
   cSql += "       " + RetSqlName("SB1010") + " E " + chr(13)       
   cSql += " WHERE A.R_E_C_D_E_L_ = ''"    + chr(13)       
   cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + chr(13)       
   cSql += "   AND A.D2_EMISSAO  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)       
   cSql += "   AND A.D2_TES IN ('728','231')"                                       + chr(13)       
   cSql += "   AND A.D2_PEDIDO    = D.C5_NUM    " + chr(13)       
   cSql += "   AND A.D2_FILIAL    = D.C5_FILIAL " + chr(13)       

   // Filial
   If xComboBx1 == "01"
      cSql += " AND A.D2_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)       
   Endif

   If xComboBx1 == "02"
      cSql += " AND A.D2_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)       
   Endif

   If xComboBx1 == "03"
      cSql += " AND A.D2_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)       
   Endif

   // Cliente
   If !Empty(cCliente)
      cSql += "   AND A.D2_CLIENTE = '" + Alltrim(cCliente) + "'" + chr(13)       
      cSql += "   AND A.D2_LOJA    = '" + Alltrim(cLoja)    + "'" + chr(13)       
   Endif

   // Produto
   If !Empty(cProduto)
      cSql += " AND A.D2_COD = '" + Alltrim(cProduto) + "'" + chr(13)       
   Endif
      
   // Grupo de Produto
   If Alltrim(xComboBx5) <> "0000"
      cSql += " AND A.D2_GRUPO = '" + Alltrim(xComboBx5) + "'" + chr(13)       
   Endif

   // Vendedor
   If Alltrim(xComboBx4) <> "000000"
      cSql += " AND B.F2_VEND1 = '" + Alltrim(xComboBx4) + "'" + chr(13)       
   Endif

   cSql += "   AND A.D2_DOC       = B.F2_DOC   " + chr(13)       
   cSql += "   AND A.D2_SERIE     = B.F2_SERIE " + chr(13)       
   cSql += "   AND A.D2_FILIAL    = B.F2_FILIAL" + chr(13)       
   cSql += "   AND B.F2_VEND1     = C.A3_COD   " + chr(13)       
   cSql += "   AND C.A3_FILIAL    = ''         " + chr(13)       
   cSql += "   AND A.D2_COD       = E.B1_COD   " + chr(13)       
   cSql += " ORDER BY A.D2_FILIAL, B.F2_VEND1, A.D2_DOC, A.D2_SERIE,A.D2_ITEM" + chr(13)       

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEMO", .T., .T. )

   T_DEMO->( DbGoTop() )

   If T_DEMO->( Eof() )
      MsgAlert("Não existem dados a serem visualizados para este filtro.")
      Return .T.
   Endif

   // Carrega o Array aSaida
   SELECT T_DEMO->( DbGoTop() )

   While !T_DEMO->( EOF() )
      
      If T_DEMO->C5_TIPO == "N"

         If Select("T_CLIENTE") > 0
            T_CLIENTE->( dbCloseArea() )
         EndIf

         cSql := "SELECT A1_NOME"
         cSql += "  FROM " + RetSqlName("SA1010")
         cSql += " WHERE A1_COD  = '" + Alltrim(T_DEMO->D2_CLIENTE) + "'"
         cSql += "   AND A1_LOJA = '" + Alltrim(T_DEMO->D2_LOJA)    + "'"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
            
         Select T_CLIENTE
         _NomeCliente := IIF(T_CLIENTE->(EOF()), "", T_CLIENTE->A1_NOME)
            
      Else

         If Select("T_CLIENTE") > 0
            T_CLIENTE->( dbCloseArea() )
         EndIf

         cSql := "SELECT A2_NOME"
         cSql += "  FROM " + RetSqlName("SA2010")
         cSql += " WHERE A2_COD  = '" + Alltrim(T_DEMO->D2_CLIENTE) + "'"
         cSql += "   AND A2_LOJA = '" + Alltrim(T_DEMO->D2_LOJA)    + "'"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
            
         Select T_CLIENTE
         _NomeCliente := IIF(T_CLIENTE->(EOF()), "", Substr(T_CLIENTE->A2_NOME,01,25))
            
      Endif   

      // Guarda em variáveis os dados da saída para posterior gravação
//    _SaidaTipo := xComboBx2          // 01 - Tipo de Pesquisa (Em Terceiros)
      _SaidaVend := T_DEMO->F2_VEND1   // 02 - Codigo do Vendedor
      _SaidaVNom := T_DEMO->A3_NOME    // 03 - Nome do Vendedor
      _SaidaFili := T_DEMO->D2_FILIAL  // 04 - Código da Filial  
      _SaidaSaid := "S"                // 05 - Indica Lançamento de Saida
      _SaidaNota := T_DEMO->D2_DOC     // 06 - Nota Fiscal
      _SaidaSeri := T_DEMO->D2_SERIE   // 07 - Série da Nota Fiscal
      _SaidaData := T_DEMO->D2_EMISSAO // 08 - Data de Emissão da Nota Fiscal
      _SaidaTtes := T_DEMO->D2_TES     // 09 - TES utilizada na operação
      _SaidaPedi := T_DEMO->D2_PEDIDO  // 10 - Nº Pedido de Venda
      _SaidaClie := T_DEMO->D2_CLIENTE // 11 - Código do Cliente/Fornecedor 
      _SaidaLoja := T_DEMO->D2_LOJA    // 12 - Loja do Cliente/Fornecedor
      _SaidaNome := Substr(_NomeCliente,01,25) // 13 - Nome do Cliente
      _SaidaProd := T_DEMO->D2_COD     // 14 - Código do Produto
      _SaidaItem := T_DEMO->D2_ITEM    // 15 - Ítem do Produto
      _SaidaNom1 := T_DEMO->B1_DESC    // 16 - Descrição  I do Produto
      _SaidaNom2 := T_DEMO->B1_DAUX    // 17 - Descrição II do Produto
      _SaidaQuan := T_DEMO->D2_QUANT   // 18 - Quantidade 
      _SaidaUnit := T_DEMO->D2_PRCVEN  // 19 - Preço Unitário
      _SaidaValo := T_DEMO->D2_TOTAL   // 20 - Valor Total
                                       // 21 - Reservado
      _SaidaItem := T_DEMO->D2_ITEM    // 22 - Nº do Item do Produto
         
      // Pesquisa o possível retorno da nota fiscal de remessa de demonstração
      If Select("T_RETORNO") > 0
         T_RETORNO->( dbCloseArea() )
      EndIf
        
      cSql := "SELECT A.D1_FILIAL ,"
      cSql += "       A.D1_DOC    ,"
      cSql += "       A.D1_SERIE  ,"
      cSql += "       A.D1_TES    ,"
      cSql += "       A.D1_PEDIDO ,"
      cSql += "       A.D1_EMISSAO,"
      cSql += "       A.D1_COD    ,"
      cSql += "       A.D1_ITEM   ,"
      cSql += "       A.D1_FORNECE,"
      cSql += "       A.D1_LOJA   ,"
      cSql += "       A.D1_QUANT  ,"
      cSql += "       A.D1_VUNIT  ,"
      cSql += "       A.D1_TOTAL  ,"
      cSql += "       B.A1_NOME   ,"
      cSql += "       C.B1_DESC   ,"
      cSql += "       C.B1_DAUX    "
      cSql += "  FROM " + RetSqlName("SD1010") + " A, "
      cSql += "       " + RetSqlName("SA1010") + " B, "
      cSql += "       " + RetSqlName("SB1010") + " C  "
      cSql += " WHERE A.D1_NFORI     = '" + Alltrim(T_DEMO->D2_DOC)    + "'"
      cSql += "   AND A.D1_SERIORI   = '" + Alltrim(T_DEMO->D2_SERIE)  + "'"
      cSql += "   AND A.D1_FILIAL    = '" + Alltrim(T_DEMO->D2_FILIAL) + "'"
      cSql += "   AND A.D1_COD       = '" + Alltrim(T_DEMO->D2_COD)    + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = '' "                                 
      cSql += "   AND A.D1_COD       = C.B1_COD "
      cSql += "   AND A.D1_FORNECE   = B.A1_COD "
      cSql += "   AND A.D1_LOJA      = B.A1_LOJA"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETORNO", .T., .T. )

      T_RETORNO->( DbGoTop() )
         
      If !T_RETORNO->( EOF() )
         
         // Grava o registro de Saída
         aAdd ( aSaida, {""         ,; // _SaidaTipo ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                         _SaidaVend ,; // 02 - Codigo do Vendedor
                         _SaidaVNom ,; // 03 - Nome do Vendedor
                         _SaidaFili ,; // 04 - Código da Filial  
                         _SaidaSaid ,; // 05 - Indica Lançamento de Saida
                         _SaidaNota ,; // 06 - Nota Fiscal
                         _SaidaSeri ,; // 07 - Série da Nota Fiscal
                         _SaidaData ,; // 08 - Data de Emissão da Nota Fiscal
                         _SaidaTtes ,; // 09 - TES utilizada na operação
                         _SaidaPedi ,; // 10 - Nº Pedido de Venda
                         _SaidaClie ,; // 11 - Código do Cliente/Fornecedor 
                         _SaidaLoja ,; // 12 - Loja do Cliente/Fornecedor
                         _SaidaNome ,; // 13 - Nome do Cliente
                         _SaidaProd ,; // 14 - Código do Produto
                         _SaidaItem ,; // 15 - Ítem do Produto
                         _SaidaNom1 ,; // 16 - Descrição  I do Produto
                         _SaidaNom2 ,; // 17 - Descrição II do Produto
                         _SaidaQuan ,; // 18 - Quantidade 
                         _SaidaUnit ,; // 19 - Preço Unitário
                         _SaidaValo ,; // 20 - Valor Total
                         "X"        ,; // 21 - Flag que indica que já houve devolução
                         _SaidaItem }) // 22 - Item do Produto

         While !T_RETORNO->( EOF() )      

            aAdd( aSaida, {""                   ,; //xComboBx2            ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                           T_DEMO->F2_VEND1     ,; // 02 - Codigo do Vendedor
                           T_DEMO->A3_NOME      ,; // 03 - Nome do Vendedor
                           T_RETORNO->D1_FILIAL ,; // 04 - Código da Filial  
                           "E"                  ,; // 05 - Indica Lançamento de Saida
                           T_RETORNO->D1_DOC    ,; // 06 - Nota Fiscal
                           T_RETORNO->D1_SERIE  ,; // 07 - Série da Nota Fiscal
                           T_RETORNO->D1_EMISSAO,; // 08 - Data de Emissão da Nota Fiscal
                           T_RETORNO->D1_TES    ,; // 09 - TES utilizada na operação
                           T_RETORNO->D1_PEDIDO ,; // 10 - Nº Pedido de Venda
                           T_RETORNO->D1_FORNECE,; // 11 - Código do Cliente/Fornecedor 
                           T_RETORNO->D1_LOJA   ,; // 12 - Loja do Cliente/Fornecedor
                           Substr(T_RETORNO->A1_NOME,01,25)   ,; // 13 - Nome do Fornecedor
                           T_RETORNO->D1_COD    ,; // 14 - Código do Produto
                           Substr(T_RETORNO->D1_ITEM,03,02),; // 15 - Ítem do Produto
                           T_RETORNO->B1_DESC   ,; // 16 - Descrição  I do Produto
                           T_RETORNO->B1_DAUX   ,; // 17 - Descrição II do Produto
                           T_RETORNO->D1_QUANT  ,; // 18 - Quantidade 
                           T_RETORNO->D1_VUNIT  ,; // 19 - Preço Unitário
                           T_RETORNO->D1_TOTAL  ,; // 20 - Valor Total
                           "X"                  ,; // 21 - Flag que indica que já houve devolução
                           T_RETORNO->D1_ITEM   }) // 22 - Item do Produto
            T_RETORNO->( DbSkip() )
               
         Enddo
            
      Else
      
         // Grava o registro de Saída
         aAdd ( aSaida, {""         ,; // _SaidaTipo ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                         _SaidaVend ,; // 02 - Codigo do Vendedor
                         _SaidaVNom ,; // 03 - Nome do Vendedor
                         _SaidaFili ,; // 04 - Código da Filial  
                         _SaidaSaid ,; // 05 - Indica Lançamento de Saida
                         _SaidaNota ,; // 06 - Nota Fiscal
                         _SaidaSeri ,; // 07 - Série da Nota Fiscal
                         _SaidaData ,; // 08 - Data de Emissão da Nota Fiscal
                         _SaidaTtes ,; // 09 - TES utilizada na operação
                         _SaidaPedi ,; // 10 - Nº Pedido de Venda
                         _SaidaClie ,; // 11 - Código do Cliente/Fornecedor 
                         _SaidaLoja ,; // 12 - Loja do Cliente/Fornecedor
                         _SaidaNome ,; // 13 - Nome do Cliente
                         _SaidaProd ,; // 14 - Código do Produto
                         _SaidaItem ,; // 15 - Ítem do Produto
                         _SaidaNom1 ,; // 16 - Descrição  I do Produto
                         _SaidaNom2 ,; // 17 - Descrição II do Produto
                         _SaidaQuan ,; // 18 - Quantidade 
                         _SaidaUnit ,; // 19 - Preço Unitário
                         _SaidaValo ,; // 20 - Valor Total
                         " "        ,; // 21 - Flag que indica que já houve devolução
                         _SaidaItem }) // 22 - Item do Produto
      
      Endif

      SELECT T_DEMO
      T_DEMO->( DbSkip() )
         
   Enddo               

   If Len(aSaida) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   // Exporta para arquivo o resultado da pesquisa
   If cLetra == "E"

      cCaminho := Alltrim(SoliArqExp())
 
      If Empty(Alltrim(cCaminho))
         MsgAlert("Exportação abortada.")
         Return .T.
      Endif
         
      nHdl := fCreate(cCaminho)

      cLinha := ""
     
      For nContar = 1 to Len(aSaida)

          // Pesquisa o nº de série do produto lido
          If Select("T_SERIE") > 0
             T_SERIE->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT DB_NUMSERI"
          cSql += "  FROM " + RetSqlName("SDB")
          cSql += " WHERE DB_FILIAL  = '" + Alltrim(aSaida[nContar,04]) + "'" 
          cSql += "   AND DB_PRODUTO = '" + Alltrim(aSaida[nContar,14]) + "'" 
          cSql += "   AND DB_DOC     = '" + Alltrim(aSaida[nContar,06]) + "'"
          cSql += "   AND DB_SERIE   = '" + Alltrim(aSaida[nContar,07]) + "'"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

          cSerie := IIF(T_SERIE->( EOF() ), "", T_SERIE->DB_NUMSERI)

          cLinha := cLinha + Alltrim(aSaida[nContar,14]) + Space(50 - Len(Alltrim(aSaida[nContar,14]))) + ;
                             Alltrim(cSerie) + Space(50 - Len(Alltrim(cSerie)))                         + ;
                             "0000000001"                                                      + ;
                             CHR(10)
      Next nContar    

      fWrite (nHdl, cLinha ) 

      fClose(nHdl)

      MsgAlert("Arquivo de Exportação gerado com sucesso.")
   
      Return .T.
      
   Endif    

   // Ordena o Array para Impressão
   // ASORT(aSaida,,,{ | x,y | x[1] + x[2] < y[1] + y[2] } )

   Processa( {|| ILOCACAO(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Gerando Relatório",.F.)

Return .T.

// Função que abre diálogo solicitando o caminho a ser salvo o arquvio de exportação
Static Function SOLIARQEXP()

   Local cCaminho := Space(100)
   Local oCaminho
                 
   Private OdlgExporta

   DEFINE MSDIALOG oDlgExporta TITLE "Exportação Produtos em Demonstração" FROM C(178),C(181) TO C(269),C(598) PIXEL

   @ C(005),C(004) Say "Informe o caminho onde o arquivo de exportação deverá ser salvo:" Size C(165),C(008) COLOR CLR_BLACK PIXEL OF oDlgExporta

   @ C(014),C(004) MsGet oCaminho Var cCaminho Size C(198),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgExporta

   @ C(028),C(166) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlgExporta ACTION( oDlgExporta:End() )

   ACTIVATE MSDIALOG oDlgExporta CENTERED 

Return cCaminho

// Função que gera o relatório
Static Function ILOCACAO(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21
   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0
   Private aTempo     := {}

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape() // Para Paisagem
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Elimina os elementos diferentes do número de série solicitado no filtro
   If !Empty(Alltrim(nSerie))

      aTempo := {}

      For nContar = 1 to Len(aSaida)   

          // Seleciona somente dados em Aberto
          If xComboBx3 = "1"
             If aSaida[nContar,21] == " "
                Loop
             Endif
          Endif
                
          // Seleciona somente dados Encerrados
          If xComboBx3 = "2"
             If aSaida[nContar,21] == "X"
                Loop
             Endif
          Endif

          // Pesquisa o nº de série do produto lido
          If Select("T_SERIE") > 0
             T_SERIE->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT DB_NUMSERI"
          cSql += "  FROM " + RetSqlName("SDB")
          cSql += " WHERE DB_FILIAL  = '" + Alltrim(aSaida[nContar,04]) + "'" 
          cSql += "   AND DB_PRODUTO = '" + Alltrim(aSaida[nContar,14]) + "'" 
          cSql += "   AND DB_DOC     = '" + Alltrim(aSaida[nContar,06]) + "'"
          cSql += "   AND DB_SERIE   = '" + Alltrim(aSaida[nContar,07]) + "'"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

          If T_SERIE->( EOF() )
          Else
             If Alltrim(T_SERIE->DB_NUMSERI) == Alltrim(nSerie)
                aAdd( aTempo, {aSaida[nContar,01],; // 01 - Tipo de Pesquisa (Em Terceiros)
                               aSaida[nContar,02],; // 02 - Codigo do Vendedor
                               aSaida[nContar,03],; // 03 - Nome do Vendedor
                               aSaida[nContar,04],; // 04 - Código da Filial  
                               aSaida[nContar,05],; // 05 - Indica Lançamento de Saida
                               aSaida[nContar,06],; // 06 - Nota Fiscal
                               aSaida[nContar,07],; // 07 - Série da Nota Fiscal
                               aSaida[nContar,08],; // 08 - Data de Emissão da Nota Fiscal
                               aSaida[nContar,09],; // 09 - TES utilizada na operação
                               aSaida[nContar,10],; // 10 - Nº Pedido de Venda
                               aSaida[nContar,11],; // 11 - Código do Cliente/Fornecedor 
                               aSaida[nContar,12],; // 12 - Loja do Cliente/Fornecedor
                               aSaida[nContar,13],; // 13 - Nome do Fornecedor
                               aSaida[nContar,14],; // 14 - Código do Produto
                               aSaida[nContar,15],; // 15 - Ítem do Produto
                               aSaida[nContar,16],; // 16 - Descrição  I do Produto
                               aSaida[nContar,17],; // 17 - Descrição II do Produto
                               aSaida[nContar,18],; // 18 - Quantidade 
                               aSaida[nContar,19],; // 19 - Preço Unitário
                               aSaida[nContar,20],; // 20 - Valor Total
                               aSaida[nContar,21],; // 21 - Flag de Aberto/Encerrado
                               aSaida[nContar,22]}) // 22 - Item do Produto                              
             Endif                               
          Endif
          
      Next nContar

      If Len(aTempo) <> 0

         aSaida := {}

         For nContar = 1 to Len(aTempo)

             aAdd( aSaida, {aTempo[nContar,01],; // 01 - Tipo de Pesquisa (Em Terceiros)
                            aTempo[nContar,02],; // 02 - Codigo do Vendedor
                            aTempo[nContar,03],; // 03 - Nome do Vendedor
                            aTempo[nContar,04],; // 04 - Código da Filial  
                            aTempo[nContar,05],; // 05 - Indica Lançamento de Saida
                            aTempo[nContar,06],; // 06 - Nota Fiscal
                            aTempo[nContar,07],; // 07 - Série da Nota Fiscal
                            aTempo[nContar,08],; // 08 - Data de Emissão da Nota Fiscal
                            aTempo[nContar,09],; // 09 - TES utilizada na operação
                            aTempo[nContar,10],; // 10 - Nº Pedido de Venda
                            aTempo[nContar,11],; // 11 - Código do Cliente/Fornecedor 
                            aTempo[nContar,12],; // 12 - Loja do Cliente/Fornecedor
                            aTempo[nContar,13],; // 13 - Nome do Fornecedor
                            aTempo[nContar,14],; // 14 - Código do Produto
                            aTempo[nContar,15],; // 15 - Ítem do Produto
                            aTempo[nContar,16],; // 16 - Descrição  I do Produto
                            aTempo[nContar,17],; // 17 - Descrição II do Produto
                            aTempo[nContar,18],; // 18 - Quantidade 
                            aTempo[nContar,19],; // 19 - Preço Unitário
                            aTempo[nContar,20],; // 20 - Valor Total
                            aTempo[nContar,21],; // 21 - Flag de Aberto/Encerrado
                            aTempo[nContar,22]}) // 22 - Item do Produto                              
         Next nContar
         
      Endif   
      
   Endif       

   // Imprime o relatório analítico
   cTipo     := aSaida[01,01]
   cVendedor := aSaida[01,02]
   _NomeVend := aSaida[01,03]
    
   // Controle numeração de páginas
   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( Len(aSaida) )

   // Envia para a função que imprime o cabeçalho do relatório
   CABECADEMO(cTipo, cVendedor, _NomeVend)

   For nContar = 1 to Len(aSaida)

      If Alltrim(aSaida[nContar,01]) == Alltrim(cTipo)

         If Alltrim(aSaida[nContar,02]) == Alltrim(cVendedor)

            // Lista Somente os Abertos
            If Substr(cComboBx3,01,01) == "1"
               If aSaida[nContar,21] == "X"
                  Loop
               Endif
            Endif
                  
            // Lista Somente os Encerrados
            If Substr(cComboBx3,01,01) == "2"
               If aSaida[nContar,21] == " "
                  Loop
               Endif
            Endif

            // Pesquisa o nº de série do produto lido
            If Select("T_SERIE") > 0
               T_SERIE->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT DB_NUMSERI"
            cSql += "  FROM " + RetSqlName("SDB")
            cSql += " WHERE DB_FILIAL  = '" + Alltrim(aSaida[nContar,04]) + "'" 
            cSql += "   AND DB_PRODUTO = '" + Alltrim(aSaida[nContar,14]) + "'" 
            cSql += "   AND DB_DOC     = '" + Alltrim(aSaida[nContar,06]) + "'"
            cSql += "   AND DB_SERIE   = '" + Alltrim(aSaida[nContar,07]) + "'"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

            If T_SERIE->( EOF() )
               cSerie := ""
            Else
               cSerie := T_SERIE->DB_NUMSERI
            Endif

            // Impressão dos dados
            If cTipo == "1"
               If aSaida[nContar,05] == "S"
                  oPrint:Say( _nLin, 0100, aSaida[nContar,04] , oFont21)
               Endif   
            Else
               If aSaida[nContar,05] == "E"
                  oPrint:Say( _nLin, 0100, aSaida[nContar,04] , oFont21)
               Endif   
            Endif   

            oPrint:Say( _nLin, 0180, aSaida[nContar,05] , oFont21)
            oPrint:Say( _nLin, 0250, aSaida[nContar,06] , oFont21)
            oPrint:Say( _nLin, 0370, aSaida[nContar,07] , oFont21)
            oPrint:Say( _nLin, 0430, aSaida[nContar,09] , oFont21)
            oPrint:Say( _nLin, 0520, aSaida[nContar,10] , oFont21)
            oPrint:Say( _nLin, 0680, Substr(aSaida[nContar,08],07,02) + "/" + Substr(aSaida[nContar,08],05,02) + "/" + Substr(aSaida[nContar,08],01,04), oFont21)
            oPrint:Say( _nLin, 0900, aSaida[nContar,13] , oFont21)
   	        oPrint:Say( _nLin, 1380, Substr(aSaida[nContar,14],01,06), oFont21)
            oPrint:Say( _nLin, 1500, Substr(Alltrim(aSaida[nContar,16]) + " " + Alltrim(aSaida[nContar,17]),01,45), oFont21)

            oPrint:Say( _nLin, 2300, cSerie, oFont21)
            oPrint:Say( _nLin, 2740, Str(aSaida[nContar,18],05), oFont21)
            oPrint:Say( _nLin, 2900, Str(aSaida[nContar,19],10,02), oFont21) 
            oPrint:Say( _nLin, 3140, Str(aSaida[nContar,20],10,02), oFont21)

            SomaDemo(50,cTipo, cVendedor, _NomeVend)

            Loop
            
         Else

            SomaDemo(50,cTipo, cVendedor, _NomeVend)

            cVendedor := aSaida[nContar,02]

            oPrint:Say( _nLin, 1380, "VENDEDOR: " + aSaida[nContar,02] + " - " + Alltrim(aSaida[nContar,03]),oFont10b)

            SomaDemo(100,cTipo, cVendedor, _NomeVend)

            nContar -= 1

         Endif
         
      Else
         
         SomaDemo(50,cTipo, cVendedor, _NomeVend)

         cTipo := aSaida[nContar,01]

         If cTipo == "1"
            oPrint:Say( _nLin, 1380, "TIPO....:      1 - PRODUTOS EM TERCEIROS",oFont10b)
         Else
            oPrint:Say( _nLin, 1380, "TIPO....:      2 - PRODUTOS DE TERCEIROS",oFont10b)            
         Endif

         If cTipo == "1"
            SomaDemo(50,cTipo, cVendedor, _NomeVend)
            oPrint:Say( _nLin, 1380, "VENDEDOR: " + Alltrim(cVendedor) + " - " + Alltrim(_NomeVend) ,oFont10b)
         Endif   
         
         SomaDemo(100,cTipo, cVendedor, _NomeVend)

         nContar -= 1
         
      Endif   

   Next nContar

   // Encerra Relatório
   oPrint:EndPage()

   // Preview do Relatório
   oPrint:Preview()

   If Select("T_DEMO") > 0
      T_DEMO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por VendedorGrupo de Produtos
Static Function CABECADEMO(xTipo, xVendedor, xNomeVend)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1380, "ACOMPANHAMENTO PRODUTOS EM LOCAÇÃO"   , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM282", oFont09  )
   oPrint:Say( _nLin, 1380, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "FL"                    , oFont21)  
   oPrint:Say( _nLin, 0180, "T"                     , oFont21)  
   oPrint:Say( _nLin, 0250, "DOC"                   , oFont21)  
   oPrint:Say( _nLin, 0370, "SR"                    , oFont21)  
   oPrint:Say( _nLin, 0430, "TES"                   , oFont21)  
   oPrint:Say( _nLin, 0520, "PEDIDO"                , oFont21)  
   oPrint:Say( _nLin, 0680, "EMISSAO"               , oFont21)  
   oPrint:Say( _nLin, 0900, "DESCIÇÃO DOS CLIENTES" , oFont21)  
   oPrint:Say( _nLin, 1380, "CÓDIGO"                , oFont21)  
   oPrint:Say( _nLin, 1500, "DESCRIÇÃO DOS PRODUTOS", oFont21)  
   oPrint:Say( _nLin, 2300, "Nº SÉRIE"              , oFont21)  
   oPrint:Say( _nLin, 2750, "QTD"                   , oFont21)  
   oPrint:Say( _nLin, 2910, "UNITARIO"              , oFont21)  
   oPrint:Say( _nLin, 3150, "VLR TOTAL"             , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

//   If xTipo == "1"
//      oPrint:Say( _nLin, 1380, "TIPO....:      1 - PRODUTOS EM TERCEIROS",oFont10b)
//   Endif
//      
//   If xTipo == "2"
//      oPrint:Say( _nLin, 1380, "TIPO....:      2 - PRODUTOS DE TERCEIROS",oFont10b)
//   Endif

   If xTipo == "1"
      _nLin += 40
      oPrint:Say( _nLin, 1380, "VENDEDOR: " + Alltrim(cVendedor) + " - " + Alltrim(xNomeVend) ,oFont10b)
   Endif
      
   _nLin += 100

Return .T.

// Função que soma linhas para impressão
Static Function SomaDemo(nLinhas, cTipo, cVendedor, _Nomevend)

   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECADEMO(cTipo, cVendedor, _NomeVend)
   Endif
   
Return .T.