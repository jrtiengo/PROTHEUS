#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTR003.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 15/07/2011                                                          *
// Objetivo..: Impressão do Pedido de Intermediação		                           *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR02()   
                                
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private cPedido := space(8)
   Private nGet1   := space(8)
   Private aComboBx1 := {"do Pedido de Venda", "do Faturamento", "Atual"}
   Private cComboBx1
   Private aComboBx2 := {"do Pedido de Venda", "Corrente"}
   Private cComboBx2
      
   // Diálogo Principal
   Private oDlg

   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTOMR02")

   // Desenha a tela de solicitação de impressão do pedido de intermediação
   DEFINE MSDIALOG oDlg TITLE "Impressão Pedido de Intermediação" FROM C(250),C(181) TO C(370),C(450) PIXEL

   // Solicita o nº do Pedido de Intermediação a ser impresso
   @ C(008),C(005) Say "Informe dados abaixo para impressão do Pedido de Intermediação:" Size C(150),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   // Tipo de Relatório a ser impresso
   @ C(024),C(005) Say "Nº Pedido:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(029) MsGet oGet1 Var cPedido Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

//   @ C(040),C(005) Say "Moeda.....:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
//   @ C(039),C(029) ComboBox cComboBx2 Items aComboBx2 Size C(090),C(010) PIXEL OF oDlg

//   @ C(055),C(005) Say "Data.....:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
//   @ C(054),C(029) ComboBox cComboBx1 Items aComboBx1 Size C(090),C(010) PIXEL OF oDlg

   DEFINE SBUTTON FROM C(40),C(112) TYPE  6 ENABLE OF oDlg ACTION( ImprimePV(cPedido, cComboBx1, cComboBx2))
   DEFINE SBUTTON FROM C(40),C(090) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Funcção que gera a impressão do Chamado Técnico / Ordem de Serviço
Static Function ImprimePV( cPedido, cData, cTipo )

	Local cSql         := ""
	Local aStru        := {}
	Local _cPedAtu     := ""
	Local _lPrimeiro   := .T.
    Local cSql         := ""
    Local nContador    := 10
    Local xLinhas      := 0
    Local cTexto1 	   := ""
    Local cTexto2      := ""
    Local dData        := ""
    Local cComentario  := ""
    Local nProdutos    := 0
    Local nServicos    := 0
    Local cCondicao    := ""
    Local lExiste      := .F.
    Local cMoeda       := ""

	Private aObs       := {}
	Private cObs       := ""
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 3500
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nLin      := 0
	Private _nCotDia   := 1
	Private _dCotDia   := DtoS( dDataBase )
	Private _cPrevisao := ""
	Private _cPrazoPag := ""
	Private _nMoeda    := 1
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21b, oFont25, oFont30b

    // Gera consistência dos dados informados antes da impressão
    If Empty(cPedido)
       Msgalert("Nº do Pedido de Intermediação a ser impresso não informado.")
       Return nil
    Endif

    // Verifica se o Pedido informado está cadastrado.
    cSql := ""
    cSql := "SELECT C5_NUM    , " // 01 - Nº do Pedido de Venda
    cSql += "       C5_FORNEXT  " // 02 - Indica se Pedido de Venda é PV Externo
    cSql += "  FROM " + RetSqlName("SC5010")
    cSql += " WHERE C5_NUM = '" + Alltrim(cPedido) + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXISTE", .T., .T. )

    T_EXISTE-> (DbGoTop() )
    lExiste := .F.
    While !T_EXISTE->( Eof() )
       If Alltrim(T_EXISTE->C5_NUM) == Alltrim(cPedido)
          lExiste := .T.
          Exit
       Endif
       T_EXISTE->( DbSkip() )
    End          

    If !lExiste
       MsgAlert("Atenção !!" + chr(13) + chr(13) + "Pedido de Intermediação informado inexistente.")
       	T_EXISTE->( dbCloseArea() )
       Return Nil
    Endif

    If Empty(T_EXISTE->C5_FORNEXT)
       MsgAlert("Atenção !!" + chr(13) + chr(13) + "Pedido informado não é um pedido de Intermediação.")
       	T_EXISTE->( dbCloseArea() )
       Return Nil
    Endif
    
	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()
	
	// Orientação da página
	//oPrint:SetLandScape() // Para Paisagem
	oPrint:SetPortrait()    // Para Retrato
	
	// Tamanho da página na impressão
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	oPrint:SetPaperSize(9)   // A4
	
	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20   := TFont():New( "Courier New",,10,,.f.,,,,.f.,.f. )
	oFont21b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
	oFont25   := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
	oFont30b  := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )
	
	// Pesquisa o nome da Empresa/Filial para o cabecalho
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )

    // Monta o SQL com os dados do pedido informado
    cSql := ""
    cSql += "SELECT A.C5_NUM    , "
    cSql += "       A.C5_EMISSAO, " 
    cSql += "       A.C5_NOTA   , "
    cSql += "       A.C5_CLIENTE, "
    cSql += "       A.C5_LOJACLI, "
    cSql += "       A.C5_VEND1  , "
    cSql += "       A.C5_VEND2  , "
    cSql += "       A.C5_FORNEXT, "
    cSql += "       A.C5_CONDPAG, "
    cSql += "       A.C5_TRANSP , "
    cSql += "       A.C5_TPFRETE, "
    cSql += "       CAST (CAST (A.C5_OBSI AS VARBINARY (1000)) AS VARCHAR (1000)) OBSERVACAO,"
    cSql += "       A.C5_FRETE  , "
    cSql += "       B.A1_COD    , "
    cSql += "       B.A1_LOJA   , "
    cSql += "       B.A1_NOME   , "
    cSql += "       B.A1_END    , "
    cSql += "       B.A1_BAIRRO , "
    cSql += "       B.A1_CEP    , "
    cSql += "       B.A1_MUN    , "
    cSql += "       B.A1_EST    , "
    cSql += "       B.A1_CGC    , "
    cSql += "       B.A1_INSCR  , "
    cSql += "       B.A1_DDD    , "
    cSql += "       B.A1_TEL    , "
    cSql += "       B.A1_EMAIL  , "
    cSql += "       B.A1_FAX    , "
    cSql += "       C.A2_NOME   , "
    cSql += "       D.E4_DESCRI , "
    cSql += "       A.C5_MOEDA    "
    cSql += "  FROM " + RetSqlName("SC5010") + " A, "
    cSql += "       " + RetSqlName("SA1010") + " B, "
    cSql += "       " + RetSqlName("SA2010") + " C, "
    cSql += "       " + RetSqlName("SE4010") + " D  "
    cSql += " WHERE A.C5_CLIENTE = B.A1_COD    "
    cSql += "   AND A.C5_LOJACLI = B.A1_LOJA   "
    cSql += "   AND A.C5_FORNEXT = C.A2_COD    "
    cSql += "   AND A.C5_CONDPAG = D.E4_CODIGO "
    cSql += "   AND A.C5_NUM     = '" + Alltrim(cPedido) + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )
	
    // Posiciona no prmeiro registroVerifica se existe resultado na tabela
	RESULTADO->( dbGoTop() )

    // Guarda a moeda do pedido de venda
    cMoeda := If(RESULTADO->C5_MOEDA == 1, "R$", "US$")

    // Início do relatório
    oPrint:StartPage()
	
    // Logotipo e identificação do pedido
    oPrint:SayBitmap( 0060, 0100, "logoautoma.bmp", 0700, 0200 )
    
    oPrint:Say( 0150, 1500, "P E D I D O Nº" , oFont10  )
    oPrint:Say( 0140, 2100, RESULTADO->C5_NUM, oFont16b )
              
    oPrint:Line( 0210, 0100, 0210, 2330 )

    dbSelectArea("SM0")
    SM0->( DbSeek( cEmpAnt + cFilAnt ) )
	
    // Dados de cadastro
    oPrint:Say( 0250, 0110, "Razão Social:" , oFont10)
    oPrint:Say( 0300, 0110, "Endereço:" , oFont10)
    oPrint:Say( 0350, 0110, "CNPJ:"     , oFont10)
    oPrint:Say( 0400, 0110, "E-mail:"   , oFont10)
    oPrint:Say( 0300, 1500, "Cidade:"   , oFont10)
    oPrint:Say( 0350, 1500, "Estado:"   , oFont10)
    oPrint:Say( 0400, 1500, "Fone/Fax:" , oFont10)
    oPrint:Say( 0450, 1500, "Emissão:"  , oFont10)
  
    oPrint:Say( 0250, 0400, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont10b)
    oPrint:Say( 0300, 0400, AllTrim( SM0->M0_ENDENT ) +" "+ AllTrim( SM0->M0_COMPENT ), oFont10b)
    oPrint:Say( 0350, 0400, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), oFont10b)
    oPrint:Say( 0400, 0400, "automatech@automatech.com.br", oFont10b)
    oPrint:Say( 0300, 1730, SM0->M0_CIDENT, oFont10b)
    oPrint:Say( 0350, 1730, SM0->M0_ESTENT, oFont10b)
    oPrint:Say( 0400, 1730, Transform( SM0->M0_TEL, "@R (99) 9999-9999" )+"/"+Transform( SM0->M0_FAX, "@R (99) 9999-9999" ), oFont10b)
    oPrint:Say( 0450, 1730, DtoC( dDataBase ) +" "+ Time(), oFont10b)

    oPrint:Line( 0500, 0100, 0500, 2330 )
	
    // Dados do Cliente
    oPrint:Say( 0520, 0110, "Cliente:" , oFont10)
    oPrint:Say( 0570, 0110, "Endereço:", oFont10)
    oPrint:Say( 0620, 0110, "E-mail:"  , oFont10)

    oPrint:Say( 0670, 0110, "CNPJ/CPF:", oFont10)
    oPrint:Say( 0720, 0110, "I.E.:"    , oFont10)    

    oPrint:Say( 0520, 1500, "Fone/Fax:", oFont10)
    oPrint:Say( 0570, 1500, "Cidade:"  , oFont10)
    oPrint:Say( 0620, 1500, "Estado:"  , oFont10)

    oPrint:Say( 0520, 0400, "["+ RESULTADO->A1_COD +"] "+ RESULTADO->A1_NOME, oFont10b)
    oPrint:Say( 0570, 0400, AllTrim( RESULTADO->A1_END ) +" "+ AllTrim( RESULTADO->A1_BAIRRO ), oFont10b)
    oPrint:Say( 0620, 0400, AllTrim( RESULTADO->A1_EMAIL ), oFont10b)

    If Len(AllTrim(RESULTADO->A1_CGC)) == 14
       oPrint:Say( 0670, 0400, Substr(RESULTADO->A1_CGC,01,02) + "." + Substr(RESULTADO->A1_CGC,03,03) + "." + Substr(RESULTADO->A1_CGC,06,03) + "/" + Substr(RESULTADO->A1_CGC,09,04) + "-" + Substr(RESULTADO->A1_CGC,13,02), oFont10b)
    Else
       oPrint:Say( 0670, 0400, Substr(RESULTADO->A1_CGC,01,03) + "." + Substr(RESULTADO->A1_CGC,04,03) + "." + Substr(RESULTADO->A1_CGC,07,03) + "-" + Substr(RESULTADO->A1_CGC,10,02), oFont10b)       
    Endif
        
    oPrint:Say( 0720, 0400, AllTrim( RESULTADO->A1_INSCR ), oFont10b)    

    oPrint:Say( 0520, 1730, Transform( AllTrim( RESULTADO->A1_DDD ) + RESULTADO->A1_TEL, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( RESULTADO->A1_DDD ) + RESULTADO->A1_FAX, "@R (99) 9999-9999" ), oFont10b)
    oPrint:Say( 0570, 1730, Alltrim(RESULTADO->A1_MUN) + " - " + Transform( AllTrim( RESULTADO->A1_CEP ), "@R 99999-999"), oFont10b)
    oPrint:Say( 0620, 1730, RESULTADO->A1_EST, oFont10b)

    oPrint:Line( 0770, 0100, 0770, 2330 )

    dData := Substr(Resultado->C5_EMISSAO,07,02) + "/" + Substr(Resultado->C5_EMISSAO,05,02) + "/" + Substr(Resultado->C5_EMISSAO,01,04)
    oPrint:Say( 0790, 0100, "Aberto em:", oFont10)
    oPrint:Say( 0790, 0400, dData, oFont10b)

    oPrint:Line( 0850, 0100, 0850, 2330 )

    oPrint:Say( 0900, 0110, "Representante I:"  , oFont10)
    oPrint:Say( 0950, 0110, "Representante II:" , oFont10)
    oPrint:Say( 1000, 0110, "Distribuidor:"     , oFont10)
    oPrint:Say( 1050, 0110, "Cond. Pagtº.:"     , oFont10)
    oPrint:Say( 1100, 0110, "Transportadora:"   , oFont10)
    oPrint:Say( 1150, 0110, "Frete:"            , oFont10)

    // Pesquisa o nome do Representante I
	If Select("T_VENDEDOR") > 0
		T_VENDEDOR->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT A3_COD , "
    cSql += "       A3_NOME  "
    cSql += "  FROM " + RetSqlName("SA3010")
    cSql += " WHERE A3_COD = '" + Alltrim(Resultado->C5_VEND1) + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

    If !T_VENDEDOR->( EOF() )
       oPrint:Say( 0900, 0400, T_Vendedor->A3_NOME, oFont10b)
    Endif

    // Pesquisa o nome do Representante II
	If Select("T_VENDEDOR") > 0
		T_VENDEDOR->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT A3_COD , "
    cSql += "       A3_NOME  "
    cSql += "  FROM " + RetSqlName("SA3010")
    cSql += " WHERE A3_COD = '" + Alltrim(Resultado->C5_VEND2) + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

    If !T_VENDEDOR->( EOF() )
       oPrint:Say( 0950, 0400, T_Vendedor->A3_NOME, oFont10b)
    Endif

    // Pesquisa o nome do Distribuidor para impressão
	If Select("T_DISTRIBUI") > 0
		T_DISTRIBUI->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT A2_COD, "
    cSql += "       A2_NOME "
    cSql += "  FROM " + RetSqlName("SA2010")
    cSql += " WHERE A2_COD = '" + Alltrim(Resultado->C5_FORNEXT) + "'"
    
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DISTRIBUI", .T., .T. )

    If !T_DISTRIBUI->( EOF() )
       oPrint:Say( 1000, 0400, T_distribui->A2_NOME, oFont10b)
    Endif

    // Pesquisa a descrição da condição de pagamento
	If Select("T_CONDICAO") > 0
		T_CONDICAO->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT E4_CODIGO, "
    cSql += "       E4_COND    "
    cSql += "  FROM " + RetSqlName("SE4010")
    cSql += " WHERE E4_CODIGO = '" + Alltrim(Resultado->C5_CONDPAG) + "'"
    
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

    If !T_CONDICAO->( EOF() )
       oPrint:Say( 1050, 0400, T_condicao->E4_COND, oFont10b)
    Endif

    // Pesquisa a descrição da Transportadora
	If Select("T_TRANSPORTE") > 0
		T_TRANSPORTE->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT A4_COD, "
    cSql += "       A4_NOME "
    cSql += "  FROM " + RetSqlName("SA4010")
    cSql += " WHERE A4_COD = '" + Alltrim(Resultado->C5_TRANSP) + "'"
    
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTE", .T., .T. )

    If !T_TRANSPORTE->( EOF() )
       oPrint:Say( 1100, 0400, T_transporte->A4_NOME, oFont10b)
    Endif

    // Tipo de Frete CIF/FOB
    If !Empty(Resultado->C5_TPFRETE)
       If Resultado->C5_TPFRETE == "C"
          oPrint:Say( 1150, 0400, "C I F", oFont10b)          
       Else
          oPrint:Say( 1150, 0400, "F O B", oFont10b)                    
       Endif
    Endif

    // Pesquisa os produtos do pedido de venda para impressão
	If Select("T_PRODUTOS") > 0
		T_PRODUTOS->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT A.C6_FILIAL , "
    cSql += "       A.C6_PRODUTO, "
    cSql += "       A.C6_DESCRI , "
    cSql += "       A.C6_UM     , "
    cSql += "       A.C6_QTDVEN , "
    cSql += "       A.C6_PRCVEN , "
    cSql += "       A.C6_VALOR  , "
    cSql += "       A.C6_VALDESC, "
    cSql += "       A.C6_COMIAUT, "
    cSql += "       A.C6_MEDCC  , "
    cSql += "       A.C6_CUSMED , "
    cSql += "       A.C6_DATFAT , "
    cSql += "       B.B1_PARNUM   "
    cSql += "  FROM " + RetSqlName("SC6010") + " A, "
    cSql += "       " + RetSqlName("SB1010") + " B  " 
    cSql += " WHERE A.C6_NUM       = '" + Alltrim(cPedido) + "'"
    cSql += "   AND A.C6_FILIAL    = '" + Alltrim(cFilAnt) + "'" 
    cSql += "   AND A.R_E_C_D_E_L_ = ''"                         
    cSql += "   AND A.C6_PRODUTO   = B.B1_COD "

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

    T_PRODUTOS->( DbGoTop() )

    oPrint:Line( 1200, 0100, 1200, 2330 )
    oPrint:Say(  1225, 0930, "P R O D U T O S  D O  P E D I D O", oFont12b)
    oPrint:Line( 1300, 0100, 1300, 2330 )

    oPrint:Say( 1320, 0110, "Código"                , oFont30b)
    oPrint:Say( 1320, 0250, "Descrição dos Produtos", oFont30b)
    oPrint:Say( 1320, 0900, "Part Number"           , oFont30b)
    oPrint:Say( 1320, 1300, "Und"                   , oFont30b)
    oPrint:Say( 1320, 1430, "Qtd"                   , oFont30b)
    oPrint:Say( 1320, 1540, "Vlr Custo"             , oFont30b) 
    oPrint:Say( 1320, 1740, "Total Custo"           , oFont30b)
    oPrint:Say( 1320, 1940, "Vlr Venda"             , oFont30b)
    oPrint:Say( 1320, 2149, "Total Venda"           , oFont30b)
    oPrint:Say( 1360, 1540, "(Unitário)"            , oFont30b) 
    oPrint:Say( 1360, 1940, "(Unitário)"            , oFont30b) 

    oPrint:Line( 1400, 0100, 1400, 2330 )

    // Imprime os produtos do pedido de intermediação
    T_PRODUTOS->( DbGoTop() )

    _nLin := 1450

    nSomaCusto   := 0
    nSomaProduto := 0
    nSomaServico := 0
    nSomaFrete   := RESULTADO->C5_FRETE

    nPosicao1 := 1300

    While !T_PRODUTOS->( Eof() )
         
       oPrint:Say( _nLin, 0110, Substr(T_PRODUTOS->C6_PRODUTO,01,06), oFont25)
       oPrint:Say( _nLin, 0250, T_PRODUTOS->C6_DESCRI               , oFont25)
       oPrint:Say( _nLin, 0900, Substr(T_PRODUTOS->B1_PARNUM,01,15) , oFont25)    
       oPrint:Say( _nLin, 1300, T_PRODUTOS->C6_UM                   , oFont25)    
       oPrint:Say( _nLin, 1370, STR(T_PRODUTOS->C6_QTDVEN,07,02)    , oFont25)        

       oPrint:Say( _nLin, 1520, If(Alltrim(T_PRODUTOS->C6_MEDCC) = "2", "U$", "R$") + STR(T_PRODUTOS->C6_CUSMED,09,02), oFont25)
       oPrint:Say( _nLin, 1730, If(Alltrim(T_PRODUTOS->C6_MEDCC) = "2", "U$", "R$") + STR((T_PRODUTOS->C6_QTDVEN * T_PRODUTOS->C6_CUSMED),09,02), oFont25)

       nSomaCusto := nSomaCusto + (T_PRODUTOS->C6_QTDVEN * T_PRODUTOS->C6_CUSMED)

       oPrint:Say( _nLin, 1940, If(Resultado->C5_MOEDA == 2, "U$", "R$") + STR(T_PRODUTOS->C6_PRCVEN,09,02)    , oFont25)        
       oPrint:Say( _nLin, 2140, If(Resultado->C5_MOEDA == 2, "U$", "R$") + STR(T_PRODUTOS->C6_VALOR ,09,02)    , oFont25)        

       If Substr(T_PRODUTOS->C6_DESCRI,01,03) == "AST"
          nSomaServico := nSomaServico + T_PRODUTOS->C6_VALOR
       Else
          nSomaProduto := nSomaProduto + T_PRODUTOS->C6_VALOR         
       Endif

       T_PRODUTOS->( DbSkip() )
       
       _nLin := _nLin + 50
       
    Enddo

    // Linhas Verticais
    oPrint:Line( nPosicao1, 0100, _nLin, 0100 )    
    oPrint:Line( nPosicao1, 0240, _nLin, 0240 )    
    oPrint:Line( nPosicao1, 0890, _nLin, 0890 )    
    oPrint:Line( nPosicao1, 1290, _nLin, 1290 )    
    oPrint:Line( nPosicao1, 1360, _nLin, 1360 )            
    oPrint:Line( nPosicao1, 1510, _nLin, 1510 )            
    oPrint:Line( nPosicao1, 1720, _nLin, 1720 )            
    oPrint:Line( nPosicao1, 1930, _nLin, 1930 )            
    oPrint:Line( nPosicao1, 2130, _nLin, 2130 )            
    oPrint:Line( nPosicao1, 2330, _nLin, 2330 )            

    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    // Imprime os Totais do Pedido de Intermediação
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, "Total Produto "           , oFont30b)
    oPrint:Say( _nLin, 1730, If(Alltrim(T_PRODUTOS->C6_MEDCC) = "2", "U$", "R$") + STR(nSomaCusto,09,02), oFont25)
    oPrint:Say( _nLin, 2140, If(Resultado->C5_MOEDA == 2, "U$", "R$") + STR(nSomaProduto,09,02)    , oFont25)        
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, "Total Frete   "           , oFont30b)
    oPrint:Say( _nLin, 2140, If(Resultado->C5_MOEDA == 2, "U$", "R$") + STR(nSomaFrete,09,02)    , oFont25)        
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, "Total Serviços"           , oFont30b)
    oPrint:Say( _nLin, 2140, If(Resultado->C5_MOEDA == 2, "U$", "R$") + STR(nSomaServico,09,02)    , oFont25)        
    _nLin := _nLin + 100
    oPrint:Say( _nLin, 0110, "Total Pedido"             , oFont30b)
    oPrint:Say( _nLin, 1730, If(Alltrim(T_PRODUTOS->C6_MEDCC) = "2", "U$", "R$") + STR(nSomaCusto,09,02), oFont25)
    oPrint:Say( _nLin, 2140, If(Resultado->C5_MOEDA == 2, "U$", "R$") + STR((nSomaProduto + nSomaServico + nSomaFrete),09,02)    , oFont25)        
    _nLin := _nLin + 50

    oPrint:Line( nPosicao1, 0100, _nLin, 0100 )    
    oPrint:Line( nPosicao1, 1720, _nLin, 1720 )            
    oPrint:Line( nPosicao1, 1930, _nLin, 1930 )            
    oPrint:Line( nPosicao1, 2130, _nLin, 2130 )            
    oPrint:Line( nPosicao1, 2330, _nLin, 2330 )            
    oPrint:Line( _nLin, 0100, _nLin, 2330 )            
    
    _nLin := _nLin + 50
    oPrint:Say( _nLin - 30, 0110, "Observações"         , oFont12b) 
    _nLin := _nLin + 50    
    
    // Prepara o campo Memo para Impressão
    For nContar = 1 to 12
        j := Strzero(nContar,2)
        cNota&j := ""
    Next nContar
    
    cNota01 := Substr(RESULTADO->OBSERVACAO,001,055)
    cNota02 := Substr(RESULTADO->OBSERVACAO,056,055)
    cNota03 := Substr(RESULTADO->OBSERVACAO,111,055)
    cNota04 := Substr(RESULTADO->OBSERVACAO,166,055)
    cNota05 := Substr(RESULTADO->OBSERVACAO,221,055)
    cNota06 := Substr(RESULTADO->OBSERVACAO,276,055)
    cNota07 := Substr(RESULTADO->OBSERVACAO,331,055)
    cNota08 := Substr(RESULTADO->OBSERVACAO,386,055)
    cNota09 := Substr(RESULTADO->OBSERVACAO,441,055)
    cNota10 := Substr(RESULTADO->OBSERVACAO,496,055)
    cNota11 := Substr(RESULTADO->OBSERVACAO,551,055)
    cNota12 := Substr(RESULTADO->OBSERVACAO,606,055)                                        

    oPrint:Say( _nLin, 0110, Alltrim(cNota01) + " " + Alltrim(cNota02), oFont09b) 
    _nLin := _nLin + 50    
    oPrint:Say( _nLin, 0110, Alltrim(cNota03) + " " + Alltrim(cNota04), oFont09b) 
    _nLin := _nLin + 50    
    oPrint:Say( _nLin, 0110, Alltrim(cNota05) + " " + Alltrim(cNota06), oFont09b) 
    _nLin := _nLin + 50    
    oPrint:Say( _nLin, 0110, Alltrim(cNota07) + " " + Alltrim(cNota08), oFont09b) 
    _nLin := _nLin + 50    
    oPrint:Say( _nLin, 0110, Alltrim(cNota09) + " " + Alltrim(cNota10), oFont09b) 
    _nLin := _nLin + 50    
    oPrint:Say( _nLin, 0110, Alltrim(cNota11) + " " + Alltrim(cNota12), oFont09b)                 
    _nLin := _nLin + 50    
   
    // Pesquisa a cotação do U$ para a data do pedido de venda
	If Select("T_MOEDA") > 0
		T_MOEDA->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT M2_DATA  , "
    cSql += "       M2_MOEDA2  "
    cSql += "  FROM " + RetSqlName("SM2010")
    cSql += " WHERE M2_DATA = CONVERT(DATETIME,'" + Resultado->C5_EMISSAO + "', 103) "

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOEDA", .T., .T. )

    If T_MOEDA->( Eof() )    
       nCotacao := 0
    Else
       nCotacao := T_MOEDA->M2_MOEDA2
    Endif   

    T_MOEDA->( dbCloseArea() )

    oPrint:Say( _nLin, 0110, "Cotação U$", oFont09)         
    oPrint:Say( _nLin, 0250, Str(nCotacao, 11,4), oFont09)                     

    _nLin := _nLin + 50    
    
    oPrint:Line( nPosicao1, 0100, _nLin, 0100 )    
    oPrint:Line( nPosicao1, 2330, _nLin, 2330 )            
    oPrint:Line( _nLin, 0100, _nLin, 2330 )            

    _nLin := _nLin + 150

    oPrint:Line( _nLin, 0250, _nLin, 1000 )        

    oPrint:Line( _nLin, 1400, _nLin, 2200 )        

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0250, RESULTADO->A1_NOME                     , oFont09b)     
    oPrint:Say( _nLin, 1400, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09b)         
 
    _nLin := _nLin + 100

    oPrint:Line( 0210, 0100, _nLin, 0100 )
    oPrint:Line( 0210, 2330, _nLin, 2330 )
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := 800

    RESULTADO->( dbCloseArea() )
    T_EXISTE->( dbCloseArea() )

	oPrint:Preview()
	
	MS_FLUSH()

Return nil