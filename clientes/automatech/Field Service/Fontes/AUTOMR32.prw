#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR32.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/09/2011                                                          *
// Objetivo..: Relatório Gerencial Assistência Técnica - Grafico - HTML            *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR32()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	   := {}
   Local _aAlias  	   := {}
   Local cSql          := ""
   Local cNomeProduto  := ""

   // Variáveis Private da Função
   Private dData01     := Ctod("  /  /    ")
   Private dData02     := Ctod("  /  /    ")
   Private cCliente    := Space(06)
   Private cLoja       := Space(03)
   Private NomeCli     := Space(60)
   Private cProduto    := Space(30)
   Private NomeGru     := Space(30)
   Private cProduto    := Space(30)
   Private cGrupo      := Space(06)
   Private NomePro     := Space(60)
   Private cTecnico    := Space(06)
   Private cSerie      := Space(30)
   Private cParte      := Space(40)
   Private cOcorrencia := Space(06)
   Private NomeOcorr   := Space(40)

   NomeCli   := "......................................................................"
   NomePro   := "......................................................................"
   NomeGru   := "......................................................................"
   NomeOcorr := "......................................................................"

   Private aComboBx1  := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS"}
   Private aComboBx2  := {}
   Private aComboBx3  := {"1 - NÃO FATURADAS", "2 - FATURADAS"}
   Private aComboBx5  := {"0 - INICIANDO", "1 - CONTENDO"}
   Private aComboBx6  := {"0 - SOMENTE LOJA INFORMADA", "1 - TODAS AS LOJAS DO CLIENTE INFORMADO"}
   Private aComboBx7  := {"0 - CONFERÊNCIA", "1 - ENVIO DE INFORMAÇÕES A CLIENTE"}
   Private aComboBx8  := {"1 - CHAMADO TÉCNICO (Em Aberto, 1 - Chamado)", "2 - ORÇAMENTO (Em Aberto, 1 - Orçamento)", "3 - ORDEM DE SERVIÇO (Em aberto, 1 - OS e 3 - Em Atendimento)"}
   Private aComboBx9  := {"0 - Todos os Status", "1 - Chamado", "2 - Orçamento", "3 - OS", "4 - Suspenso", "5 - Encerrado", "6 - Help Desk", "X - Sem Tipos"}
   Private aComboBx10 := {"0 - Todos os Status", "1 - Orçamento", "2 - OS", "X - Sem Tipos"}
   Private aComboBx11 := {"0 - Todos os Status", "1 - OS", "2 - Pedido Gerado", "3 - Em Atendimento", "4 - Atndido", "5 - Encerrado", "X - Sem Tipos"}
   Private aComboBx12 := {"T - Ambos", "A - Abertos", "E - Encerrados"}
   Private aComboBx13 := {"T - Ambos", "A - Abertos", "E - Encerrados"}
   Private aComboBx14 := {"T - Ambos", "A - Abertas", "B - Encerradas s/FAT", "E - Encerradas c/FAT"}
   Private aComboBx15 := {"T - Todas", "F - Em Fabricante", "P - Aguardando Peças", "A - Aguardando Aprovação", "E - Encerradas"}

   Private nGet1	 := Ctod("  /  /    ")                                       
   Private nGet2	 := Ctod("  /  /    ")
   Private nGet3	 := Space(06)
   Private nGet4	 := Space(03)
   Private nGet5	 := Space(30)
   Private nGet6	 := Space(06)
   Private nGet7	 := Space(30)
   Private nGet8	 := Space(06)
   Private nGet9	 := Space(40)
   Private nGet10	 := Space(06)

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   Private cComboBx6
   Private cComboBx7
   Private cComboBx8
   Private cComboBx9
   Private cComboBx10
   Private cComboBx11
   Private cComboBx12
   Private cComboBx13
   Private cComboBx14
   Private cComboBx15
      
   // Diálogo Principal
   Private oDlg

   // Carrega o combo dos Técnicos
   If Select("T_TECNICO") > 0
      T_TECNICO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_NOMTEC "
   cSql += "  FROM " + RetSqlName("AA1010")
   cSql += " ORDER BY AA1_NOMTEC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICO", .T., .T. )

   T_TECNICO->( DbGoTop() )

   aAdd( aComboBx2, "000000 - TODOS OS TECNICOS" )
   
   While !T_TECNICO->( EOF() )
      aAdd( aComboBx2, Alltrim(T_TECNICO->AA1_CODTEC) + " - " + Alltrim(T_TECNICO->AA1_NOMTEC) )
      T_TECNICO->( DBSKIP() )
   Enddo

   // Variáveis que definem a Ação do Formulário

   DEFINE MSDIALOG oDlg TITLE "Relatório Gerencial Assistência Técnica" FROM C(178),C(181) TO C(640),C(550) PIXEL

   // Solicita o nº da etiqueta a ser impressa
   @ C(011),C(005) Say "Data Inicial:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(011),C(085) Say "Data Final:"       Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(005) Say "Cliente:"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(085) Say NomeCli             Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(043),C(005) Say "Pesq.Cliente:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Produto:"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(085) Say NomePro             Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(005) Say "Grupo:"            Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(085) Say NomeGru             Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(111),C(005) Say "Filial:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(127),C(005) Say "Nº Série:"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(143),C(005) Say "Pesquisar Em:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(156),C(005) Say "Tipo Chamado"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(156),C(065) Say "Tipo Orçamento"    Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(156),C(125) Say "Tipo O.S."         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg   
   @ C(186),C(005) Say "Ocorrências:"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(186),C(085) Say NomeOcorr           Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(203),C(005) Say "Técnico:"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(194),C(108) Say "Posição Orçamento" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(009),C(035) MsGet oGet1 Var dData01            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(009),C(110) MsGet oGet2 Var dData02            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(026),C(035) MsGet oGet3 Var cCliente           Size C(020),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1") 
   @ C(026),C(063) MsGet oGet4 Var cLoja              Size C(005),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TrazNomeCliente(cCliente, cLoja) ) 
   @ C(042),C(035) ComboBox cComboBx6 Items aComboBx6 WHEN !Empty(cCliente) Size C(140),C(010) PIXEL OF oDlg
   @ C(055),C(035) MsGet oGet5 Var cProduto           Size C(045),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNomeProd(cProduto) )
   @ C(072),C(035) MsGet oGet8 Var cGrupo             Size C(020),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SBM") VALID( BuscaNomeGrupo(cGrupo) )
   @ C(092),C(035) MsGet oGet9 Var cParte             WHEN !Empty(cGrupo) Size C(095),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg 
   @ C(093),C(135) ComboBox cComboBx5 Items aComboBx5 WHEN !Empty(cGrupo) Size C(040),C(010) PIXEL OF oDlg
   @ C(109),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(140),C(010) PIXEL OF oDlg
   @ C(125),C(035) MsGet oGet7 Var cSerie             Size C(050),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg 
   @ C(142),C(035) ComboBox cComboBx8 Items aComboBx8 Size C(140),C(010) PIXEL OF oDlg

   @ C(163),C(005) ComboBox cComboBx9  Items aComboBx9  when Substr(cComboBx8,01,01) == "1" Size C(050),C(010) PIXEL OF oDlg
   @ C(163),C(065) ComboBox cComboBx10 Items aComboBx10 when Substr(cComboBx8,01,01) == "2" Size C(050),C(010) PIXEL OF oDlg
   @ C(163),C(125) ComboBox cComboBx11 Items aComboBx11 when Substr(cComboBx8,01,01) == "3" Size C(050),C(010) PIXEL OF oDlg      

   @ C(172),C(005) ComboBox cComboBx12 Items aComboBx12 when Substr(cComboBx8,01,01) == "1" Size C(050),C(010) PIXEL OF oDlg
   @ C(172),C(065) ComboBox cComboBx13 Items aComboBx13 when Substr(cComboBx8,01,01) == "2" Size C(050),C(010) PIXEL OF oDlg
   @ C(172),C(125) ComboBox cComboBx14 Items aComboBx14 when Substr(cComboBx8,01,01) == "3" Size C(050),C(010) PIXEL OF oDlg      

   @ C(183),C(035) MsGet    oGet10     Var   cOcorrencia Size C(020),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("AAG") VALID( BuscaNomeOcorrencia(cOcorrencia) ) 
   @ C(202),C(035) ComboBox cComboBx2  Items aComboBx2   when Substr(cComboBx8,01,01) <> "1" Size C(070),C(010) PIXEL OF oDlg
   @ C(202),C(108) ComboBox cComboBx15 Items aComboBx15  when Substr(cComboBx8,01,01) == "2" Size C(070),C(010) PIXEL OF oDlg
   
   @ C(215),C(100) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( RELTECNICAG())
   @ C(215),C(140) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end()  )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que trás a descrição do produto selecionado
Static Function BuscaNomeProd( cProduto )

   Local cSql := ""
   
   If Empty(cProduto)
      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf
      NomePro := "......................................................................"
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
       NomePro := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
    Else
       MsgAlert("Produto informado inexistente.")
       NomePro := "......................................................................"
    Endif

    If Select("T_PRODUTO") > 0
   	   T_PRODUTO->( dbCloseArea() )
    EndIf

Return .T.

// Função que trás a descrição do cliente selecionado
Static Function TrazNomeCliente( cCliente, cLoja )

   Local cSql := ""
   
   If Empty(cCliente) .and. Empty(cLoja)
      If Select("T_CLIENTE") > 0
         T_CLIENTE->( dbCloseArea() )
      EndIf
      cCliente := Space(06)
      cLoja    := Space(03)
      NomeCli  := "......................................................................"
      Return .T.
   Endif   

   If Select("T_CLIENTE") > 0
   	  T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, "
   cSql += "       A1_NOME  "
   cSql += "  FROM " + RetSqlName("SA1010")
   cSql += " WHERE A1_COD  = '" + Alltrim(cCliente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(cLoja)    + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
	
   If !T_CLIENTE->( EOF() )
      cCliente := T_CLIENTE->A1_COD
      cLoja    := T_CLIENTE->A1_LOJA
      NomeCli  := Alltrim(T_CLIENTE->A1_NOME)
   Else
      cCliente := Space(06)
      cLoja    := Space(06)
      NomeCli  := "......................................................................"
   Endif
          
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

Return .T.

// Função que trás a descrição do cliente selecionado
Static Function BuscaNomeGrupo( cGrupo )

   Local cSql := ""
   
   If Empty(cGrupo)
      If Select("T_GRUPO") > 0
         T_GRUPO->( dbCloseArea() )
      EndIf
      cGrupo   := Space(06)
      NomeGrup := "......................................................................"
      Return .T.
   Endif   

   If Select("T_GRUPO") > 0
   	  T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := "SELECT BM_GRUPO , "
   cSql += "       BM_DESC    "
   cSql += "  FROM " + RetSqlName("SBM010")
   cSql += " WHERE BM_GRUPO     = '" + Alltrim(cGrupo) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )
	
   If !T_GRUPO->( EOF() )
      cGrupo  := T_GRUPO->BM_GRUPO
      NomeGru := Alltrim(T_GRUPO->BM_DESC)
   Else
      cGrupo  := Space(06)
      NomeGru := "......................................................................"
   Endif
          
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

Return .T.

// Função que trás a descrição da Ocorrência informada
Static Function BuscaNomeOcorrencia( cOcorrencia )

   Local cSql := ""
   
   If Empty(cOcorrencia)
      If Select("T_OCORRENCIA") > 0
         T_OCORRENCIA->( dbCloseArea() )
      EndIf
      cOcorrencia := Space(06)
      NomeOcorr   := "......................................................................"
      Return .T.
   Endif   

   If Select("T_OCORRENCIA") > 0
   	  T_OCORRENCIA->( dbCloseArea() )
   EndIf

   cSql := "SELECT AAG_CODPRB , "
   cSql += "       AAG_DESCRI   "
   cSql += "  FROM " + RetSqlName("AAG010")
   cSql += " WHERE AAG_CODPRB   = '" + Alltrim(cOcorrencia) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCORRENCIA", .T., .T. )
	
   If !T_OCORRENCIA->( EOF() )
      cOcorrencia := T_OCORRENCIA->AAG_CODPRB
      NomeOcorr   := Alltrim(T_OCORRENCIA->AAG_DESCRI)
   Else
      cOcorrencia := Space(06)
      NomeOcorr   := "......................................................................"
   Endif
          
   If Select("T_OCORRENCIA") > 0
      T_OCORRENCIA->( dbCloseArea() )
   EndIf

Return .T.

// Função que prepara a impressão do relatório
Static Function RELTECNICAG()

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
   
   _Filial := Substr(cComboBx1,01,02)

   Private aPesq        := {}
   Private aPesquisa    := {}
   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""

   If Alltrim(cComboBx2) == "ANALÍTICO"
      Private limite  := 220
      Private tamanho := "G"
   Else   
      Private limite  := 80
      Private tamanho := "P"
   Endif   

   Private nomeprog     := "Relacao-Chamados"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Relacao-Chamados"
   Private cString      := "SC5"

   Private xComboBx1
   Private xComboBx2
   Private xComboBx3
   Private xComboBx4
   Private xComboBx5   
   Private xComboBx6   
   Private xComboBx7   
   
   xComboBx1 := cComboBx1
   xComboBx2 := cComboBx2
   xComboBx3 := cComboBx3
   xComboBx4 := cComboBx4
   xComboBx5 := cComboBx5                            
   xComboBx6 := cComboBx6
   xComboBx7 := cComboBx7

   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

   // Prepara os parâmetros para o relatorio
   xTitulo := Dtoc(dData01)            + "|" + ;
              Dtoc(dData02)            + "|" + ;
              cCliente                 + "|" + ;
              cLoja                    + "|" + ;
              cProduto                 + "|" + ;
              cGrupo                   + "|" + ;
              cParte                   + "|" + ;
              cSerie                   + "|" + ;
              Substr(cComboBx1 ,01,02) + "|" + ;
              Substr(cComboBx5 ,01,01) + "|" + ;
              Substr(cComboBx6 ,01,01) + "|" + ;
              Substr(cComboBx8 ,01,01) + "|" + ;
              Substr(cComboBx9 ,01,01) + "|" + ;
              Substr(cComboBx10,01,01) + "|" + ;
              Substr(cComboBx11,01,01) + "|" + ;
              cOcorrencia              + "|" + ;
              Substr(cComboBx2 ,01,06) + "|" + ;
              Substr(cComboBx12,01,01) + "|" + ;
              Substr(cComboBx13,01,01) + "|" + ;
              Substr(cComboBX14,01,01) + "|"

   Processa( {|| I_TECNICO(Cabec1,Cabec2,xTitulo,nLin) }, "Aguarde...", "Gerando Relatório",.F.)

Return .T.

// Função que gera o relatório
Static Function I_TECNICO(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto    := 0
   Local nServico    := 0
   Local nPagina     := 0
   Local aPesquisa   := {}
   Local nContar     := 0
   Local dData01     := Ctod('  /  /    ')
   Local dData02     := Ctod('  /  /    ')
   Local _Produto    := Space(30)
   Local _Cliente    := Space(06)
   Local _Loja       := Space(03)
   Local _Serie      := Space(30)
   Local _Tecnico    := Space(06)
   Local _Filial     := Space(02)
   Local _Status     := Space(01)
   Local _StatusCh   := Space(01)
   Local _StatusOR   := Space(01)
   Local _StatusOS   := Space(01)
   Local _Posicao    := Space(01)
   Local _Grupo      := Space(06)
   Local cConteudo   := ""
   Local _Faturado   := Space(01)
   Local _Parte      := Space(40)
   Local _Busca      := Space(01)
   Local _TipoRel    := Space(01)
   Local _Ocorrencia := Space(06)
   Local _SituA      := Space(01)
   Local _SituB      := Space(01)
   Local _SituC      := Space(01)

   Private oPrint, oFont7, oFont08, oFont8, oFont08b, oFont09, oFont9, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert    := 2000
   Private nPagina     := 0
   Private _nLin       := 0
   Private aPesquisa   := {}
   Private cEmail      := ""
   Private cReduzido   := ""
   Private aPaginas    := {}
   Private cErroEnvio  := 0
   Private aNotas      := {}
   Private cLayout     := ""
   Private aComentario := {}

   Private cFrase01, cFrase02, cFrase03, cFrase04, cFrase05
   Private cFrase06, cFrase07, cFrase08, cFrase09, cFrase10
   Private cFrase11, cFrase12, cFrase13, cFrase14, cFrase15
   Private cFrase16, cFrase17, cFrase18, cFrase19, cFrase20
   Private cFrase21, cFrase22, cFrase23, cFrase24, cFrase25
   Private cFrase26, cFrase27, cFrase28, cFrase29, cFrase30
   
   Private cLaudo01, cLaudo02, cLaudo03, cLaudo04, cLaudo05
   Private cLaudo06, cLaudo07, cLaudo08, cLaudo09, cLaudo10
   Private cLaudo11, cLaudo12, cLaudo13, cLaudo14, cLaudo15
   Private cLaudo16, cLaudo17, cLaudo18, cLaudo19, cLaudo20
   Private cLaudo21, cLaudo22, cLaudo23, cLaudo24, cLaudo25
   Private cLaudo26, cLaudo27, cLaudo28, cLaudo29, cLaudo30

   Private cPecas01, cPecas02, cPecas03, cPecas04, cPecas05
   Private cPecas06, cPecas07, cPecas08, cPecas09, cPecas10
   Private cPecas11, cPecas12, cPecas13, cPecas14, cPecas15
   Private cPecas16, cPecas17, cPecas18, cPecas19, cPecas20
   Private cPecas21, cPecas22, cPecas23, cpecas24, cPecas25
   Private cPecas26, cPecas27, cPecas28, cpecas29, cPecas30

   Private nDivisor     := 0
   Private nImprime     := 0
   Private _nPosicao    := 0
   Private _Letras      := 0
   Private _Posicao     := 0
   Private _GravaString := ""
   Private _Trinta      := 0
   Private _String      := ""

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape()  // Para Paisagem
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont7    := TFont():New( "Courier New",,07,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont8    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )
   oFont9    := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
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

   // Captura os valores do parâmetro Título
   nPipe     := 1
   cConteudo := ""
   For nContar = 1 to len(Titulo)
       If Substr(titulo,nContar,1) <> "|"
          cConteudo := cConteudo + Substr(titulo,nContar,1)
       Else
          Do Case
             Case nPipe == 1
                  dData01     := ctod(cConteudo)
             Case nPipe == 2
                  dData02     := ctod(cConteudo)
             Case nPipe == 3
                  _Cliente    := cConteudo
             Case nPipe == 4
                  _Loja       := cConteudo
             Case nPipe == 5
                  _Produto    := cConteudo
             Case nPipe == 6
                  _Grupo      := cConteudo
             Case nPipe == 7
                  _Parte      := cConteudo
             Case nPipe == 8
                  _Serie      := cConteudo
             Case nPipe == 9
                  _Filial     := cConteudo
             Case nPipe == 10
                  _Posicao    := cConteudo
             Case nPipe == 11
                  _TipoPq     := cConteudo
             Case nPipe == 12
                  _Status     := cConteudo
             Case nPipe == 13
                  _StatusCh   := cConteudo
             Case nPipe == 14
                  _StatusOR   := cConteudo
             Case nPipe == 15
                  _StatusOS   := cConteudo
             Case nPipe == 16
                  _Ocorrencia := cConteudo
             Case nPipe == 17
                  _Tecnico    := cConteudo
             Case nPipe == 18
                  _SitA       := cConteudo
             Case nPipe == 19
                  _SitB       := cConteudo
             Case nPipe == 20
                  _SitC       := cConteudo
          EndCase        
          nPipe     := nPipe + 1
          cConteudo := ""
       Endif
   Next nContar    

   // Pesquisa os Dados dos Chamados
   If _Status == "1"
      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf

      cSql := ""                   
      cSql := "SELECT A.AB1_FILIAL, " + chr(13)
      cSql += "       A.AB1_EMISSA, " + chr(13)
      cSql += "       A.AB1_ETIQUE, " + chr(13)
      cSql += "       A.AB1_CODCLI, " + chr(13)
      cSql += "       A.AB1_LOJA  , " + chr(13)
      cSql += "       A.AB1_STATUS, " + chr(13)
      cSql += "       C.A1_NOME   , " + chr(13)
      cSql += "       B.AB2_TIPO  , " + chr(13)
      cSql += "       B.AB2_CODPRB, " + chr(13)
      cSql += "       B.AB2_CODPRO, " + chr(13)
      cSql += "       B.AB2_NUMSER, " + chr(13)
      cSql += "       B.AB2_CODPRB, " + chr(13)
      cSql += "       D.AAG_DESCRI, " + chr(13)
      cSql += "       E.B1_DESC   , " + chr(13)
      cSql += "       E.B1_DAUX   , " + chr(13)
      cSql += "       E.B1_GRUPO    " + chr(13)
      cSql += "  FROM " + RetSqlName("AB1010") + " A, " + chr(13)
      cSql += "       " + RetSqlName("AB2010") + " B, " + chr(13)
      cSql += "       " + RetSqlName("SA1010") + " C, " + chr(13)
      cSql += "       " + RetSqlName("AAG010") + " D, " + chr(13)
      cSql += "       " + RetSqlName("SB1010") + " E, " + chr(13)
      cSql += " WHERE B.AB2_NRCHAM   = A.AB1_NRCHAM " + chr(13)
      cSql += "   AND A.AB1_EMISSA  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.AB1_EMISSA <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)"  + chr(13)
      cSql += "   AND A.R_E_C_D_E_L_ = ''           " + chr(13)
      cSql += "   AND A.AB1_CODCLI   = C.A1_COD     " + chr(13)
      cSql += "   AND A.AB1_LOJA     = C.A1_LOJA    " + chr(13)
      cSql += "   AND B.AB2_CODPRB   = D.AAG_CODPRB " + chr(13)
      cSql += "   AND B.AB2_CODPRO   = E.B1_COD     " + chr(13)

      // Filtra por Status
      If _StatusCH <> "0"
         If _StaTusCH <> "X"
            cSql += "   AND B.AB2_TIPO     = '" + Alltrim(_StatusCH) + "'" + chr(13)
         Endif   
      Endif   

      // Filtra pelo Status do Chamado
      If _SitA <> "T"
         cSql += "   AND B.AB2_STATUS   = '" + Alltrim(_SitA) + "'" + chr(13)         
      Endif

      // Filtra por Cliente
      If !Empty(Alltrim(_Cliente))
         cSql += " AND A.AB1_CODCLI = '" + Alltrim(_Cliente) + "'" + chr(13)
         If _TipoPQ == "0"
            cSql += " AND A.AB1_LOJA   = '" + Alltrim(_Loja) + "'" + chr(13)
         Endif
      Endif

      // Filtra por Produto
      If !Empty(Alltrim(_Produto))
         cSql += " AND C.AB2_CODPRO = '" + Alltrim(_Produto) + "'" + chr(13)
      Endif
      
      // Filtra por Nº Série
      If !Empty(Alltrim(_Serie))
         cSql += " AND C.AB2_NUMSER = '" + Alltrim(_Serie) + "'" + chr(13)
      Endif
 
      // Filtra por Filial
      If _Filial <> "00"     
         cSql += " AND A.AB1_FILIAL = '" + Alltrim(_Filial) + "'" + chr(13)
      Endif

      // Seleciona por codigo de grupo de produtos
      If !Empty(_Grupo)
         cSql += " AND E.B1_GRUPO = '" + Alltrim(_Grupo) + "'" + chr(13)
      Endif

      If !Empty(_Parte)
         If _Busca == "0"
            cSql += " AND E.B1_DESC LIKE '" + Alltrim(_Parte) + "%'" + chr(13)
         Else
            cSql += " AND E.B1_DESC LIKE '%" + Alltrim(_Parte) + "%'" + chr(13)
         Endif
      Endif

      // Filtra por Ocorrência
      If !Empty(_Ocorrencia)
         cSql += " AND B.AB2_CODPRB = '" + Alltrim(_Ocorrencia) + "'" + chr(13)
      Endif

      // Ordenação do Resultado
      cSql += " ORDER BY A.AB1_FILIAL, B.AB2_TIPO " + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

      DbSelectArea("RESULTADO")

      If EOF()
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif

   Endif
   
   // Pesquisa os Dados dos Orçamentos
   If _Status == "2"
      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB3_FILIAL,"
      cSql += "       A.AB3_EMISSA,"
      cSql += "       A.AB3_ETIQUE,"
      cSql += "       A.AB3_CODCLI,"
      cSql += "       A.AB3_LOJA  ,"
      cSql += "       A.AB3_NUMORC,"
      cSql += "       A.AB3_RLAUDO,"
      cSql += "       A.AB3_STATUS,"
      cSql += "       B.AB4_CODPRB,"
      cSql += "       B.AB4_CODPRO,"
      cSql += "       B.AB4_NUMSER,"
      cSql += "       B.AB4_TIPO  ,"
      cSql += "       C.B1_DESC   ,"
      cSql += "       C.B1_DAUX   ,"
      cSql += "       C.B1_GRUPO  ,"
      cSql += "       D.AAG_DESCRI,"
      cSql += "       E.A1_NOME   ,"
      cSql += "       F.AA1_NOMTEC "
      cSql += "  FROM " + RetSqlName("AB3010") + " A, "
      cSql += "       " + RetSqlName("AB4010") + " B, "
      cSql += "       " + RetSqlName("SB1010") + " C, "
      cSql += "       " + RetSqlName("AAG010") + " D, "
      cSql += "       " + RetSqlName("SA1010") + " E, "      
      cSql += "       " + RetSqlName("AA1010") + " F  "      
      cSql += " WHERE A.AB3_FILIAL   = B.AB4_FILIAL"
      cSql += "   AND A.AB3_NUMORC   = B.AB4_NUMORC"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND B.AB4_CODPRO   = C.B1_COD    "
      cSql += "   AND B.AB4_CODPRB   = D.AAG_CODPRB"
      cSql += "   AND A.AB3_CODCLI   = E.A1_COD    "
      cSql += "   AND A.AB3_LOJA     = E.A1_LOJA   "
      cSql += "   AND A.AB3_EMISSA  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.AB3_EMISSA <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)"
      cSql += "   AND A.AB3_RLAUDO   = F.AA1_CODTEC"

      // Filtra por Status
      If _StatusOR <> "0"
         If _StatusOR <> "X"
            cSql += "   AND B.AB4_TIPO     = '" + Alltrim(_StatusOR) + "'" + chr(13)
         Endif   
      Endif   

      // Filtra pelo Status do Orçamento
      If _SitB <> "T"
         cSql += "   AND A.AB3_STATUS   = '" + Alltrim(_SitB) + "'" + chr(13)         
      Endif

      // Filtra por Cliente
      If !Empty(Alltrim(_Cliente))
         cSql += " AND A.AB3_CODCLI = '" + Alltrim(_Cliente) + "'" + chr(13)
         If _TipoPQ == "0"
            cSql += " AND A.AB3_LOJA   = '" + Alltrim(_Loja) + "'" + chr(13)
         Endif
      Endif

      // Filtra por Produto
      If !Empty(Alltrim(_Produto))
         cSql += " AND B.AB4_CODPRO = '" + Alltrim(_Produto) + "'" + chr(13)
      Endif
      
      // Filtra por Nº Série
      If !Empty(Alltrim(_Serie))
         cSql += " AND B.AB4_NUMSER = '" + Alltrim(_Serie) + "'" + chr(13)
      Endif
 
      // Filtra por Filial
      If _Filial <> "00"     
         cSql += " AND A.AB3_FILIAL = '" + Alltrim(_Filial) + "'" + chr(13)
      Endif

      // Seleciona por codigo de grupo de produtos
      If !Empty(_Grupo)
         cSql += " AND C.B1_GRUPO = '" + Alltrim(_Grupo) + "'" + chr(13)
      Endif

      If !Empty(_Parte)
         If _Busca == "0"
            cSql += " AND C.B1_DESC LIKE '" + Alltrim(_Parte) + "%'" + chr(13)
         Else
            cSql += " AND C.B1_DESC LIKE '%" + Alltrim(_Parte) + "%'" + chr(13)
         Endif
      Endif

      // Filtra por Ocorrência
      If !Empty(_Ocorrencia)
         cSql += " AND B.AB4_CODPRB = '" + Alltrim(_Ocorrencia) + "'" + chr(13)
      Endif

      // Filtra pelo Técnico
      If !Empty(_Tecnico)
         If _Tecnico <> "000000"
            cSql += " AND A.AB3_RLAUDO = '" + Alltrim(_Tecnico) + "'" + chr(13)
         Endif
      Endif

      // Filtra pela Pisição do Orçamento
      If Substr(cComboBx15,01,01) == "T"
      Else
         cSql += " AND A.AB3_POSI = '" + Alltrim(Substr(cComboBx15,01,01)) + "'"
      Endif

      // Ordenação do Resultado
      cSql += " ORDER BY A.AB3_FILIAL, A.AB3_RLAUDO, B.AB4_TIPO " + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

      DbSelectArea("RESULTADO")

      If EOF()
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif

   Endif

   // Pesquisa os Dados das OS - Ordens de Serviço
   If _Status == "3"

      cLayout := _AbreSolici()

      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB6_FILIAL,"
      cSql += "       A.AB6_EMISSA,"
      cSql += "       A.AB6_ETIQUE,"
      cSql += "       A.AB6_CODCLI,"
      cSql += "       A.AB6_LOJA  ,"
      cSql += "       A.AB6_NUMOS ,"
      cSql += "       A.AB6_RLAUDO,"
//      cSql += "       A.AB6_MLAUDO,"
  
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.AB6_MLAUDO)) AB6_MLAUDO ,"
      cSql += "       A.AB6_STATUS,"
      cSql += "       B.AB7_FILIAL,"
      cSql += "       B.AB7_CODPRB,"
      cSql += "       B.AB7_CODPRO,"
      cSql += "       B.AB7_NUMSER,"
      cSql += "       B.AB7_TIPO  ,"
      cSql += "       B.AB7_NUMORC,"
      cSql += "       C.B1_DESC   ,"
      cSql += "       C.B1_DAUX   ,"
      cSql += "       C.B1_GRUPO  ,"
      cSql += "       c.B1_MODELO ,"
      cSql += "       D.AAG_DESCRI,"
      cSql += "       E.A1_NOME   ,"
      cSql += "       F.AA1_NOMTEC "
      cSql += "  FROM " + RetSqlName("AB6010") + " A, "
      cSql += "       " + RetSqlName("AB7010") + " B, "
      cSql += "       " + RetSqlName("SB1010") + " C, "
      cSql += "       " + RetSqlName("AAG010") + " D, "
      cSql += "       " + RetSqlName("SA1010") + " E, "      
      cSql += "       " + RetSqlName("AA1010") + " F  "      
      cSql += " WHERE A.AB6_FILIAL   = B.AB7_FILIAL"
      cSql += "   AND A.AB6_NUMOS    = B.AB7_NUMOS "
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND B.AB7_CODPRO   = C.B1_COD    "
      cSql += "   AND B.AB7_CODPRB   = D.AAG_CODPRB"
      cSql += "   AND A.AB6_CODCLI   = E.A1_COD    "
      cSql += "   AND A.AB6_LOJA     = E.A1_LOJA   "
      cSql += "   AND A.AB6_EMISSA  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.AB6_EMISSA <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)"
      cSql += "   AND A.AB6_RLAUDO   = F.AA1_CODTEC"

      // Filtra por Status
      If _StatusOS <> "0"
         If _StatusOS <> "X"        
            If _StatusOS == "1" .OR. _StatusOS == "3"
               cSql += "   AND (B.AB7_TIPO = '1' OR B.AB7_TIPO = '3')" + chr(13)
            Else
               cSql += "   AND B.AB7_TIPO     = '" + Alltrim(_StatusOS) + "'" + chr(13)
            Endif
         Endif   
      Endif   

      // Filtra pelo Status da OS
      If _SitC <> "T"
         cSql += "   AND A.AB6_STATUS   = '" + Alltrim(_SitC) + "'" + chr(13)         
      Endif

      // Filtra por Cliente
      If !Empty(Alltrim(_Cliente))
         cSql += " AND A.AB6_CODCLI = '" + Alltrim(_Cliente) + "'" + chr(13)
         If _TipoPQ == "0"
            cSql += " AND A.AB6_LOJA   = '" + Alltrim(_Loja) + "'" + chr(13)
         Endif
      Endif

      // Filtra por Produto
      If !Empty(Alltrim(_Produto))
         cSql += " AND B.AB7_CODPRO = '" + Alltrim(_Produto) + "'" + chr(13)
      Endif
      
      // Filtra por Nº Série
      If !Empty(Alltrim(_Serie))
         cSql += " AND B.AB7_NUMSER = '" + Alltrim(_Serie) + "'" + chr(13)
      Endif
 
      // Filtra por Filial
      If _Filial <> "00"     
         cSql += " AND A.AB6_FILIAL = '" + Alltrim(_Filial) + "'" + chr(13)
      Endif

      // Seleciona por codigo de grupo de produtos
      If !Empty(_Grupo)
         cSql += " AND C.B1_GRUPO = '" + Alltrim(_Grupo) + "'" + chr(13)
      Endif

      If !Empty(_Parte)
         If _Busca == "0"
            cSql += " AND C.B1_DESC LIKE '" + Alltrim(_Parte) + "%'" + chr(13)
         Else
            cSql += " AND C.B1_DESC LIKE '%" + Alltrim(_Parte) + "%'" + chr(13)
         Endif
      Endif

      // Filtra por Ocorrência
      If !Empty(_Ocorrencia)
         cSql += " AND B.AB7_CODPRB = '" + Alltrim(_Ocorrencia) + "'" + chr(13)
      Endif

      // Filtra pelo Técnico
      If !Empty(_Tecnico)
         If _Tecnico <> "000000"
            cSql += " AND A.AB6_RLAUDO = '" + Alltrim(_Tecnico) + "'" + chr(13)
         Endif
      Endif

      // Ordenação do Resultado
      cSql += " ORDER BY A.AB6_FILIAL, A.AB6_RLAUDO, B.AB7_TIPO " + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

      DbSelectArea("RESULTADO")

      If EOF()
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif

   Endif

   // ----------------------- //
   // IMPRESSÃO DE RELATORIOS //
   // ----------------------- //

   // Impressão do Relatório de Chamados Técnicos
   If _Status == "1"

      nPagina  := 0

      nQtdTec  := 0
      nQtdGer  := 0
      nQtdTot  := 0

      RESULTADO->( DbGoTop() )

      xFilial  := RESULTADO->AB1_FILIAL
      xStatus  := RESULTADO->AB2_TIPO

      Do Case
         Case RESULTADO->AB2_TIPO == "1"
              xNomeSts := "CHAMADOS"
         Case RESULTADO->AB2_TIPO == "2"
              xNomeSts := "ORÇAMENTOS"
         Case RESULTADO->AB2_TIPO == "3"
              xNomeSts := "ORDENS DE SERVIÇOS"
         Case RESULTADO->AB2_TIPO == "4"
              xNomeSts := "SUSPENSOS"
         Case RESULTADO->AB2_TIPO == "5"
              xNomeSts := "ENCERRADOS"
         Case RESULTADO->AB2_TIPO == "6"
              xNomeSts := "HELP DESK"
      EndCase              

      DbSelectArea("RESULTADO")
      
      ProcRegua( RecCount() )

      CABECACHA(xFilial, xStatus, xNomeSts, nPagina)

      While !RESULTADO->( EOF() )
   
         If Alltrim(RESULTADO->AB1_FILIAL) == Alltrim(xFilial)

            If Alltrim(RESULTADO->AB2_TIPO) == Alltrim(xStatus)

               oPrint:Say( _nLin,0100, Substr(RESULTADO->AB1_EMISSA,07,02) + "/" + Substr(RESULTADO->AB1_EMISSA,05,02) + "/" + Substr(RESULTADO->AB1_EMISSA,01,04), oFont8)
               oPrint:Say( _nLin,0275, RESULTADO->AB1_ETIQUE, oFont8)
               oPrint:Say( _nLin,0440, RESULTADO->A1_NOME   , oFont8)
               oPrint:Say( _nLin,1170, RESULTADO->AAG_DESCRI, oFont8)
               oPrint:Say( _nLin,1550, Substr(Alltrim(RESULTADO->B1_DESC) + " " + Alltrim(RESULTADO->B1_DAUX),01,80), oFont8)
               oPrint:Say( _nLin,2700, RESULTADO->AB2_NUMSER              , oFont8)

               nQtdTec  := nQtdTec + 1
               nQtdGer  := nQtdGer + 1
               nQtdTot  := nQtdTot + 1

               SomaLinhaCha(50,xFilial, xStatus, xNomeSts, nPagina)

               RESULTADO->( DbSkip() )
               Loop
            
            Else

               oPrint:Say( _nLin,0100, "Total do Status: " + Str(nQtdTec,5), oFont10b)

               nQtdTec := 0

               xStatus := RESULTADO->AB2_TIPO

               Do Case
                  Case RESULTADO->AB2_TIPO == "1"
                       xNomeSts := "CHAMADOS"
                  Case RESULTADO->AB2_TIPO == "2"
                       xNomeSts := "ORÇAMENTOS"
                  Case RESULTADO->AB2_TIPO == "3"
                       xNomeSts := "ORDENS DE SERVIÇOS"
                  Case RESULTADO->AB2_TIPO == "4"
                       xNomeSts := "SUSPENSOS"
                  Case RESULTADO->AB2_TIPO == "5"
                       xNomeSts := "ENCERRADOS"
                  Case RESULTADO->AB2_TIPO == "6"
                       xNomeSts := "HELP DESK"
               EndCase              

               SomaLinhaCha(100,xFilial, xStatus, xNomeSts, nPagina)
            
               oPrint:Say( _nLin,1400, "STATUS.:  " + RESULTADO->AB2_TIPO + " - " + xNomeSts, oFont10b)

               SomaLinhaCha(100,xFilial, xStatus, xNomeSts, nPagina)

            Endif
         
         Else            

            oPrint:Say( _nLin,0100, "Total do Status: " + Str(nQtdTec,5), oFont10b)
            SomaLinhaCha(50,xFilial, xStatus, xNomeSts, nPagina)
            oPrint:Say( _nLin,0100, "Total da Filial: " + Str(nQtdGer,5), oFont10b)            

            xFilial := RESULTADO->AB1_FILIAL
            xStatus := RESULTADO->AB2_TIPO

            nQtdTec := 0
            nQtdGer := 0

            Do Case
               Case RESULTADO->AB2_TIPO == "1"
                    xNomeSts := "CHAMADOS"
               Case RESULTADO->AB2_TIPO == "2"
                    xNomeSts := "ORÇAMENTOS"
               Case RESULTADO->AB2_TIPO == "3"
                    xNomeSts := "ORDENS DE SERVIÇOS"
               Case RESULTADO->AB2_TIPO == "4"
                    xNomeSts := "SUSPENSOS"
               Case RESULTADO->AB2_TIPO == "5"
                    xNomeSts := "ENCERRADOS"
               Case RESULTADO->AB2_TIPO == "6"
                    xNomeSts := "HELP DESK"
            EndCase              

            Do Case
               Case Alltrim(xFilial) == "01"
                    oPrint:Say( _nLin, 1400, "FILIAL.: 01 - PORTO ALEGRE" , oFont10b)
               Case Alltrim(xFilial) == "02"
                    oPrint:Say( _nLin, 1400, "FILIAL.: 02 - CAXIAS DO SUL", oFont10b)
               Case Alltrim(xFilial) == "03"
                    oPrint:Say( _nLin, 1400, "FILIAL.: 03 - PELOTAS"      , oFont10b)
            EndCase

            SomaLinhaCha(50,xFilial, xStatus, xNomeSts, nPagina)

            oPrint:Say( _nLin, 1400, "STATUS.:  " + Alltrim(xStatus) + " - " + Alltrim(xNomeSts), oFont10b)

            SomaLinhaCha(100,xFilial, xStatus, xNomeSts, nPagina)

         Endif

      Enddo

      SomaLinhaCha(50,xFilial, xStatus, xNomeSts, nPagina)

      oPrint:Say( _nLin,0100, "Total do Status: " + Str(nQtdTec,5), oFont10b)
      SomaLinhaCha(50,xFilial, xStatus, xNomeSts, nPagina)
      oPrint:Say( _nLin,0100, "Total da Filial: " + Str(nQtdGer,5), oFont10b)            
      SomaLinhaCha(50,xFilial, xStatus, xNomeSts, nPagina)
      oPrint:Say( _nLin,0100, "Total Geral....: " + Str(nQtdTot,5), oFont10b)            
      
      oPrint:EndPage()

      oPrint:Preview()

   Endif

   // ------------------------------------ //
   // Impressão do Relatório de Orçamentos //
   // ------------------------------------ //
   If _Status == "2"

      nPagina  := 0

      nTotProF := 0; nTotSerF := 0; nTotTotF := 0
      nTotProS := 0; nTotSerS := 0; nTotTotS := 0
      nTotProT := 0; nTotSerT := 0; nTotTotT := 0
      nTotProG := 0; nTotSerG := 0; nTotTotG := 0

      nQtdFil  := 0; nQtdSts  := 0; nQtdTec  := 0; nQtdGer := 0

      RESULTADO->( DbGoTop() )

      xFilial      := RESULTADO->AB3_FILIAL
      xTecnico     := RESULTADO->AB3_RLAUDO
      xNomeTecnico := RESULTADO->AA1_NOMTEC
      xStatus      := RESULTADO->AB4_TIPO

      Do Case
         Case RESULTADO->AB4_TIPO == "1"
              xNomeSts := "ORÇAMENTOS"
         Case RESULTADO->AB4_TIPO == "2"
              xNomeSts := "ORDENS DE SERVIÇO"
      EndCase              

      DbSelectArea("RESULTADO")
      
      ProcRegua( RecCount() )

      CABECAORC(xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

      While !RESULTADO->( EOF() )
   
         If Alltrim(RESULTADO->AB3_FILIAL) == Alltrim(xFilial)

            If Alltrim(RESULTADO->AB3_RLAUDO) == Alltrim(xTecnico)

               If Alltrim(RESULTADO->AB4_TIPO) == Alltrim(xStatus)

                  oPrint:Say( _nLin,0100, Substr(RESULTADO->AB3_EMISSA,07,02) + "/" + Substr(RESULTADO->AB3_EMISSA,05,02) + "/" + Substr(RESULTADO->AB3_EMISSA,01,04), oFont8)
                  oPrint:Say( _nLin,0275, RESULTADO->AB3_ETIQUE, oFont8)
                  oPrint:Say( _nLin,0440, Substr(RESULTADO->A1_NOME,01,35)   , oFont8)
                  oPrint:Say( _nLin,0970, Substr(RESULTADO->AAG_DESCRI,01,15), oFont8)
                  oPrint:Say( _nLin,1200, Substr(Alltrim(RESULTADO->B1_DESC) + " " + Alltrim(RESULTADO->B1_DAUX),01,60), oFont8)
                  oPrint:Say( _nLin,2300, RESULTADO->AB4_NUMSER, oFont8)

                  // Pesquisa os Valores do Orçamento
                  If Select("T_VALORES") > 0
                     T_VALORES->( dbCloseArea() )
                  EndIf

                  cSql := ""
                  cSql := "SELECT A.AB5_NUMORC," 
                  cSql += "       A.AB5_CODPRO,"
                  cSql += "       B.B1_TIPO   ,"
                  cSql += "       A.AB5_TOTAL AS TOTCHAM"
                  cSql += "  FROM " + RetSqlName("AB5010") + " A, "
                  cSql += "       " + RetSqlName("SB1010") + " B  "
                  cSql += " WHERE A.AB5_NUMORC   = '" + Alltrim(RESULTADO->AB3_NUMORC) + "'"
                  cSql += "   AND A.AB5_FILIAL   = '" + Alltrim(RESULTADO->AB3_FILIAL) + "'"
                  cSql += "   AND A.R_E_C_D_E_L_ = ''"
                  cSql += "   AND A.AB5_CODPRO   = B.B1_COD "
       
                  cSql := ChangeQuery( cSql )
                  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VALORES", .T., .T. )

                  nProdutos := 0
                  nServicos := 0
                  nTotal    := 0

                  If T_VALORES->( EOF() )
                     nProdutos := 0
                     nServicos := 0
                     nTotal    := 0
                     cNumOrc   := ""
                  Else
                     T_VALORES->( DbGoTop() )
                     While !T_VALORES->( EOF() )
                        If T_VALORES->B1_TIPO == "MO"
                           nServicos := nServicos + T_VALORES->TOTCHAM
                        Else
                           nProdutos := nProdutos + T_VALORES->TOTCHAM
                        Endif
                        T_VALORES->( DbSkip() )
                     Enddo
                     nTotal := nProdutos + nServicos
                  Endif

                  oPrint:Say( _nLin,2700, Str(nProdutos,12,02), oFont8)
                  oPrint:Say( _nLin,2900, Str(nServicos,12,02), oFont8)
                  oPrint:Say( _nLin,3100, Str(nTotal   ,12,02), oFont8)

                  nTotProF := nTotProF + nProdutos
                  nTotSerF := nTotSerF + nServicos
                  nTotTotF := nTotTotF + nTotal

                  nTotProT := nTotProT + nProdutos
                  nTotSerT := nTotSerT + nServicos
                  nTotTotT := nTotTotT + nTotal

                  nTotProS := nTotProS + nProdutos
                  nTotSerS := nTotSerS + nServicos
                  nTotTotS := nTotTotS + nTotal

                  nTotProG := nTotProG + nProdutos
                  nTotSerG := nTotSerG + nServicos
                  nTotTotG := nTotTotG + nTotal

                  nQtdFil  := nQtdFil + 1
                  nQtdSts  := nQtdSts + 1
                  nQtdTec  := nQtdTec + 1
                  nQtdGer  := nQtdGer + 1

                  SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
      
                  RESULTADO->( DbSkip() )

                  Loop
            
               Else

                  // Totaliza o Status
                  oPrint:Say( _nLin,0100, "Total de OS do Status: " + Str(nQtdSts,5), oFont10b)
                  oPrint:Say( _nLin,2100, "TOTAL DO STATUS: ", oFont08b)
                  oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
                  oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
                  oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

                  xStatus  := RESULTADO->AB4_TIPO

                  nTotProS := 0
                  nTotSerS := 0
                  nTotTotS := 0
                  nQtdSts  := 0
                  
                  Do Case
                     Case RESULTADO->AB4_TIPO == "1"
                          xNomeSts := "ORÇAMENTOS"
                     Case RESULTADO->AB4_TIPO == "2"
                          xNomeSts := "ORDENS DE SERVIÇO"
                  EndCase              

                  SomaLinhaOrc(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

                  oPrint:Say( _nLin,1300, "STATUS.:      " + xStatus + " - " + xNomeSts, oFont10b)

                  SomaLinhaOrc(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

               Endif
               
            Else
               
               // Totaliza o Status
               oPrint:Say( _nLin,0100, "Total de OS do Status.: " + Str(nQtdSts,5), oFont10b)
               oPrint:Say( _nLin,2100, "TOTAL DO STATUS: ", oFont08b)
               oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
               oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
               oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

               SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

               // Totaliza o Técnico
               oPrint:Say( _nLin,0100, "Total de OS do Técnico: " + Str(nQtdTec,5), oFont10b)
               oPrint:Say( _nLin,2100, "TOTAL DO TECNICO: ", oFont08b)
               oPrint:Say( _nLin,2700, Str(nTotProT,12,02), oFont08b)
               oPrint:Say( _nLin,2900, Str(nTotSerT,12,02), oFont08b)
               oPrint:Say( _nLin,3100, Str(nTotTotT,12,02), oFont08b)

               xStatus      := RESULTADO->AB4_TIPO
               xTecnico     := RESULTADO->AB3_RLAUDO
               xNomeTecnico := RESULTADO->AA1_NOMTEC

               nTotProS := 0
               nTotSerS := 0
               nTotTotS := 0

               nTotProT := 0
               nTotSerT := 0
               nTotTotT := 0
                  
               nQtdSts  := 0
               nQtdTec  := 0

               Do Case
                  Case RESULTADO->AB4_TIPO == "1"
                       xNomeSts := "ORÇAMENTOS"
                  Case RESULTADO->AB4_TIPO == "2"
                       xNomeSts := "ORDENS DE SERVIÇO"
               EndCase              

               SomaLinhaOrc(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
            
               oPrint:Say( _nLin,1300, "TECNICO: " + xTecnico + " - " + xNomeTecnico, oFont10b)

               SomaLinhaOrc(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
               
               Loop

            Endif
         
         Else            

            oPrint:Say( _nLin,0100, "Total de OS do Status: " + Str(nQtdSts,5), oFont10b)
            oPrint:Say( _nLin,2100, "TOTAL DO STATUS: ", oFont08b)
            oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
            oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
            oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

            SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

            oPrint:Say( _nLin,0100, "Total de OS do Técnico: " + Str(nQtdTec,5), oFont10b)
            oPrint:Say( _nLin,2100, "TOTAL DO TÉCNICO: ", oFont08b)
            oPrint:Say( _nLin,2700, Str(nTotProT,12,02), oFont08b)
            oPrint:Say( _nLin,2900, Str(nTotSerT,12,02), oFont08b)
            oPrint:Say( _nLin,3100, Str(nTotTotT,12,02), oFont08b)

            SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

            oPrint:Say( _nLin,0100, "Total de OS da Filial.: " + Str(nQtdFil,5), oFont10b)            
            oPrint:Say( _nLin,2100, "TOTAL DA FILIAL: ", oFont08b)
            oPrint:Say( _nLin,2700, Str(nTotProF,12,02), oFont08b)
            oPrint:Say( _nLin,2900, Str(nTotSerF,12,02), oFont08b)
            oPrint:Say( _nLin,3100, Str(nTotTotF,12,02), oFont08b)

            SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
            
            xFilial      := RESULTADO->AB3_FILIAL
            xTecnico     := RESULTADO->AB3_RLAUDO
            xNomeTecnico := RESULTADO->AA1_NOMTEC
            xStatus      := RESULTADO->AB4_TIPO

            nQtdSts  := 0
            nQtdFil  := 0
            nQtdTec  := 0

            nTotProS := 0
            nTotSerS := 0
            nTotTotS := 0

            nTotProT := 0
            nTotSerT := 0
            nTotTotT := 0

            nTotProF := 0
            nTotSerF := 0
            nTotTotF := 0

            Do Case
               Case RESULTADO->AB4_TIPO == "1"
                    xNomeSts := "ORÇAMENTOS"
               Case RESULTADO->AB4_TIPO == "2"
                    xNomeSts := "ORDENS DE SERVIÇO"
            EndCase              

            Do Case
               Case Alltrim(xFilial) == "01"
                    oPrint:Say( _nLin, 1300, "FILIAL.:     01 - PORTO ALEGRE" , oFont10b)
               Case Alltrim(xFilial) == "02"
                    oPrint:Say( _nLin, 1300, "FILIAL.:     02 - CAXIAS DO SUL", oFont10b)
               Case Alltrim(xFilial) == "03"
                    oPrint:Say( _nLin, 1300, "FILIAL.:     03 - PELOTAS"      , oFont10b)
            EndCase

            SomaLinhaOrc(50,xFilial, xStatus, xNomeTecnico, xNomeSts, nPagina)
            oPrint:Say( _nLin, 1300, "TÉCNICO: " + Alltrim(xTecnico) + " - " + Alltrim(xNomeTecnico), oFont10b)
            SomaLinhaOrc(50,xFilial, xStatus, xNomeTecnico, xNomeSts, nPagina)
            oPrint:Say( _nLin, 1300, "STATUS.:      " + Alltrim(xStatus) + " - " + Alltrim(xNomeSts), oFont10b)
            SomaLinhaOrc(100,xFilial, xStatus, xNomeTecnico, xNomeSts, nPagina)

         Endif

      Enddo

      SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

      oPrint:Say( _nLin,0100, "Total de OS do Status.: " + Str(nQtdSts,5), oFont10b)
      oPrint:Say( _nLin,2100, "TOTAL DO STATUS.: ", oFont08b)
      oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
      oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
      oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

      SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

      oPrint:Say( _nLin,0100, "Total de OS do Técnico: " + Str(nQtdTec,5), oFont10b)
      oPrint:Say( _nLin,2100, "TOTAL DO TÉCNICO:", oFont08b)
      oPrint:Say( _nLin,2700, Str(nTotProT,12,02), oFont08b)
      oPrint:Say( _nLin,2900, Str(nTotSerT,12,02), oFont08b)
      oPrint:Say( _nLin,3100, Str(nTotTotT,12,02), oFont08b)

      SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

      oPrint:Say( _nLin,0100, "Total de OS da Filial.: " + Str(nQtdFil,5), oFont10b)            
      oPrint:Say( _nLin,2100, "TOTAL DA FILIAL.: ", oFont08b)
      oPrint:Say( _nLin,2700, Str(nTotProF,12,02), oFont08b)
      oPrint:Say( _nLin,2900, Str(nTotSerF,12,02), oFont08b)
      oPrint:Say( _nLin,3100, Str(nTotTotF,12,02), oFont08b)

      SomaLinhaOrc(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

      oPrint:Say( _nLin,0100, "Total de OS Geral.....: " + Str(nQtdGer,5), oFont10b)            
      oPrint:Say( _nLin,2100, "TOTAL GERAL.....: ", oFont08b)
      oPrint:Say( _nLin,2700, Str(nTotProG,12,02), oFont08b)
      oPrint:Say( _nLin,2900, Str(nTotSerG,12,02), oFont08b)
      oPrint:Say( _nLin,3100, Str(nTotTotG,12,02), oFont08b)
      
      oPrint:EndPage()

      oPrint:Preview()

   Endif

   // ------------------------------------------- //
   // Impressão do Relatório de Ordens de Serviço //
   // ------------------------------------------- //
   If _Status == "3"


      If Substr(cLayout,01,01) == "1"

         nPagina  := 0

         nTotProF := 0; nTotSerF := 0; nTotTotF := 0
         nTotProS := 0; nTotSerS := 0; nTotTotS := 0
         nTotProT := 0; nTotSerT := 0; nTotTotT := 0
         nTotProG := 0; nTotSerG := 0; nTotTotG := 0

         nQtdFil  := 0; nQtdSts  := 0; nQtdTec  := 0; nQtdGer := 0

         RESULTADO->( DbGoTop() )

         xFilial      := RESULTADO->AB6_FILIAL
         xTecnico     := RESULTADO->AB6_RLAUDO
         xNomeTecnico := RESULTADO->AA1_NOMTEC
         xStatus      := RESULTADO->AB7_TIPO

         Do Case
            Case RESULTADO->AB7_TIPO == "1"
                 xNomeSts := "OS"
            Case RESULTADO->AB7_TIPO == "2"
                 xNomeSts := "PEDIDO GERADO"
            Case RESULTADO->AB7_TIPO == "3"
                 xNomeSts := "EM ATENDIMENTO"
            Case RESULTADO->AB7_TIPO == "4"
                 xNomeSts := "ATENDIDO"
            Case RESULTADO->AB7_TIPO == "5"
                 xNomeSts := "ENCERRADO"
         EndCase              

         DbSelectArea("RESULTADO")
      
         ProcRegua( RecCount() )

         CABECAOS(xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

         While !RESULTADO->( EOF() )
   
            If Alltrim(RESULTADO->AB6_FILIAL) == Alltrim(xFilial)

               If Alltrim(RESULTADO->AB6_RLAUDO) == Alltrim(xTecnico)

                  If Alltrim(RESULTADO->AB7_TIPO) == Alltrim(xStatus)

                     oPrint:Say( _nLin,0100, Substr(RESULTADO->AB6_EMISSA,07,02) + "/" + Substr(RESULTADO->AB6_EMISSA,05,02) + "/" + Substr(RESULTADO->AB6_EMISSA,01,04), oFont8)
                     oPrint:Say( _nLin,0275, RESULTADO->AB6_ETIQUE, oFont8)
                     oPrint:Say( _nLin,0440, Substr(RESULTADO->A1_NOME,01,20)   , oFont8)
                     oPrint:Say( _nLin,0800, Substr(RESULTADO->AAG_DESCRI,01,20), oFont8)

                     // Pesquisa as notas fiscais dos pedidos gerados
                     aNotas  := {}
                     cPedido := Space(06)
                     cNota   := Space(10)
                     If Select("T_NOTA") > 0
                        T_NOTA->( dbCloseArea() )
                     EndIf

                     cSql := ""
                     cSql := "SELECT C6_NUM , "
                     cSql += "       C6_NOTA  "
                     cSql += "  FROM " + RetSqlName("SC6010")
                     cSql += " WHERE C6_NUMOS     LIKE '" + Alltrim(RESULTADO->AB6_NUMOS) + Alltrim(RESULTADO->AB6_FILIAL) + "%'"
                     cSql += "   AND C6_NOTA     <> ''"
                     cSql += "   AND C6_FILIAL    = '" + Alltrim(RESULTADO->AB6_FILIAL) + "'"
                     cSql += "   AND R_E_C_D_E_L_ = ''"
                     cSql += " GROUP BY C6_NUM, C6_NOTA "
                     cSql += " ORDER BY C6_NOTA "

                     cSql := ChangeQuery( cSql )
                     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

                     T_NOTA->( DbGoTop() )

                     If T_NOTA->( EOF() )        
                        cPedido := Space(06)
                        cNota   := Space(10)
                     Else
                        T_NOTA->( DbGoTop() )
                        cPedido := T_NOTA->C6_NUM
                        Do While !T_NOTA->( EOF() )
                           aAdd( aNotas, { T_NOTA->C6_NOTA } )
                           T_NOTA->( DbSkip() )
                        Enddo
                     Endif

                     oPrint:Say( _nLin,1050, cPedido, oFont8)

                     If Len(aNotas) == 0
                        oPrint:Say( _nLin,1170, "      ", oFont8)
                     Else
                        oPrint:Say( _nLin,1170, Substr(aNotas[1,1],01,06), oFont8)
                     Endif
                     
                     oPrint:Say( _nLin,1300, Substr(Alltrim(RESULTADO->B1_DESC) + " " + Alltrim(RESULTADO->B1_DAUX),01,50), oFont8)
                     oPrint:Say( _nLin,2300, RESULTADO->AB7_NUMSER, oFont8)

                     // Pesquisa os Valores do Orçamento
                     If Select("T_VALORES") > 0
                        T_VALORES->( dbCloseArea() )
                     EndIf

                     cSql := ""
                     cSql := "SELECT A.AB5_NUMORC," + chr(13)
                     cSql += "       A.AB5_CODPRO," + chr(13)
                     cSql += "       B.B1_TIPO   ," + chr(13)
                     cSql += "       A.AB5_TOTAL AS TOTCHAM" + chr(13)
                     cSql += "  FROM " + RetSqlName("AB5010") + " A, " + chr(13)
                     cSql += "       " + RetSqlName("SB1010") + " B  " + chr(13)
                     cSql += " WHERE A.AB5_NUMORC   = '" + Substr(RESULTADO->AB7_NUMORC,01,06) + "'"
                     cSql += "   AND A.AB5_FILIAL   = '" + Alltrim(RESULTADO->AB7_FILIAL) + "'"
                     cSql += "   AND A.R_E_C_D_E_L_ = ''" + chr(13)
                     cSql += "   AND A.AB5_CODPRO   = B.B1_COD " + chr(13)
       
                     cSql := ChangeQuery( cSql )
                     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VALORES", .T., .T. )

                     nProdutos := 0
                     nServicos := 0
                     nTotal    := 0

                     If T_VALORES->( EOF() )
                        nProdutos := 0
                        nServicos := 0
                        nTotal    := 0
                        cNumOrc   := ""
                     Else
                        T_VALORES->( DbGoTop() )
                        While !T_VALORES->( EOF() )
                           If T_VALORES->B1_TIPO == "MO"
                              nServicos := nServicos + T_VALORES->TOTCHAM
                           Else
                              nProdutos := nProdutos + T_VALORES->TOTCHAM
                           Endif
                           T_VALORES->( DbSkip() )
                        Enddo
                        nTotal := nProdutos + nServicos
                     Endif

                     oPrint:Say( _nLin,2700, Str(nProdutos,12,02), oFont8)
                     oPrint:Say( _nLin,2900, Str(nServicos,12,02), oFont8)
                     oPrint:Say( _nLin,3100, Str(nTotal   ,12,02), oFont8)

                     nTotProF := nTotProF + nProdutos
                     nTotSerF := nTotSerF + nServicos
                     nTotTotF := nTotTotF + nTotal

                     nTotProT := nTotProT + nProdutos
                     nTotSerT := nTotSerT + nServicos
                     nTotTotT := nTotTotT + nTotal

                     nTotProS := nTotProS + nProdutos
                     nTotSerS := nTotSerS + nServicos
                     nTotTotS := nTotTotS + nTotal

                     nTotProG := nTotProG + nProdutos
                     nTotSerG := nTotSerG + nServicos
                     nTotTotG := nTotTotG + nTotal

                     nQtdFil  := nQtdFil + 1
                     nQtdSts  := nQtdSts + 1
                     nQtdTec  := nQtdTec + 1
                     nQtdGer  := nQtdGer + 1

                     SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

                     // Verifica se existem mais notas fiscais a serem impressas
                     If Len(aNotas) > 1
                        For nContar = 2 to Len(aNotas)
                            oPrint:Say( _nLin,1170, Substr(aNotas[nContar,1],01,06), oFont8)
                            SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
                        Next nContar
                     Endif
                  
                     RESULTADO->( DbSkip() )

                     Loop
            
                  Else

                     // Totaliza o Status
                     oPrint:Say( _nLin,0100, "Total de OS do Status: " + Str(nQtdSts,5), oFont10b)
                     oPrint:Say( _nLin,2300, "TOTAL DO STATUS: ", oFont08b)
                     oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
                     oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
                     oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

                     xStatus  := RESULTADO->AB7_TIPO

                     nTotProS := 0
                     nTotSerS := 0
                     nTotTotS := 0
                     nQtdSts  := 0
                  
                     Do Case
                        Case RESULTADO->AB7_TIPO == "1"
                             xNomeSts := "OS"
                        Case RESULTADO->AB7_TIPO == "2"
                             xNomeSts := "PEDIDO GERADO"
                        Case RESULTADO->AB7_TIPO == "3"
                             xNomeSts := "EM ATENDIMENTO"
                        Case RESULTADO->AB7_TIPO == "4"
                             xNomeSts := "ATENDIDO"
                        Case RESULTADO->AB7_TIPO == "5"
                             xNomeSts := "ENCERRADO"
                     EndCase              
          
                     SomaOS(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
             
                     oPrint:Say( _nLin,1300, "STATUS.:      " + xStatus + " - " + xNomeSts, oFont10b)

                     SomaOS(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

                  Endif
               
               Else
               
                  // Totaliza o Status
                  oPrint:Say( _nLin,0100, "Total de OS do Status.: " + Str(nQtdSts,5), oFont10b)
                  oPrint:Say( _nLin,2300, "TOTAL DO STATUS: ", oFont08b)
                  oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
                  oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
                  oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

                  SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

                  // Totaliza o Técnico
                  oPrint:Say( _nLin,0100, "Total de OS do Técnico: " + Str(nQtdTec,5), oFont10b)
                  oPrint:Say( _nLin,2300, "TOTAL DO TECNICO: ", oFont08b)
                  oPrint:Say( _nLin,2700, Str(nTotProT,12,02), oFont08b)
                  oPrint:Say( _nLin,2900, Str(nTotSerT,12,02), oFont08b)
                  oPrint:Say( _nLin,3100, Str(nTotTotT,12,02), oFont08b)

                  xStatus      := RESULTADO->AB7_TIPO
                  xTecnico     := RESULTADO->AB6_RLAUDO
                  xNomeTecnico := RESULTADO->AA1_NOMTEC

                  nTotProS := 0
                  nTotSerS := 0
                  nTotTotS := 0

                  nTotProT := 0
                  nTotSerT := 0
                  nTotTotT := 0

                  nQtdSts  := 0
                  nQtdTec  := 0

                  Do Case
                     Case RESULTADO->AB7_TIPO == "1"
                          xNomeSts := "OS"
                     Case RESULTADO->AB7_TIPO == "2"
                          xNomeSts := "PEDIDO GERADO"
                     Case RESULTADO->AB7_TIPO == "3"
                          xNomeSts := "EM ATENDIMENTO"
                     Case RESULTADO->AB7_TIPO == "4"
                          xNomeSts := "ATENDIDO"
                     Case RESULTADO->AB7_TIPO == "5"
                          xNomeSts := "ENCERRADO"
                  EndCase              

                  SomaOS(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

                  oPrint:Say( _nLin,1300, "TECNICO: " + xTecnico + " - " + xNomeTecnico, oFont10b)

                  SomaOS(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

                  Loop

               Endif
         
            Else            

               oPrint:Say( _nLin,0100, "Total de OS do Status: " + Str(nQtdSts,5), oFont10b)
               oPrint:Say( _nLin,2300, "TOTAL DO STATUS: ", oFont08b)
               oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
               oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
               oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

               SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

               oPrint:Say( _nLin,0100, "Total de OS do Técnico: " + Str(nQtdTec,5), oFont10b)
               oPrint:Say( _nLin,2300, "TOTAL DO TÉCNICO: ", oFont08b)
               oPrint:Say( _nLin,2700, Str(nTotProT,12,02), oFont08b)
               oPrint:Say( _nLin,2900, Str(nTotSerT,12,02), oFont08b)
               oPrint:Say( _nLin,3100, Str(nTotTotT,12,02), oFont08b)

               SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

               oPrint:Say( _nLin,0100, "Total de OS da Filial.: " + Str(nQtdFil,5), oFont10b)            
               oPrint:Say( _nLin,2300, "TOTAL DA FILIAL: ", oFont08b)
               oPrint:Say( _nLin,2700, Str(nTotProF,12,02), oFont08b)
               oPrint:Say( _nLin,2900, Str(nTotSerF,12,02), oFont08b)
               oPrint:Say( _nLin,3100, Str(nTotTotF,12,02), oFont08b)

               SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

               xFilial      := RESULTADO->AB6_FILIAL
               xTecnico     := RESULTADO->AB6_RLAUDO
               xNomeTecnico := RESULTADO->AA1_NOMTEC
               xStatus      := RESULTADO->AB7_TIPO

               nQtdSts  := 0
               nQtdFil  := 0
               nQtdTec  := 0

               nTotProS := 0
               nTotSerS := 0
               nTotTotS := 0

               nTotProT := 0
               nTotSerT := 0
               nTotTotT := 0

               nTotProF := 0
               nTotSerF := 0
               nTotTotF := 0

               Do Case
                  Case RESULTADO->AB7_TIPO == "1"
                       xNomeSts := "OS"
                  Case RESULTADO->AB7_TIPO == "2"
                       xNomeSts := "PEDIDO GERADO"
                  Case RESULTADO->AB7_TIPO == "3"
                       xNomeSts := "EM ATENDIMENTO"
                  Case RESULTADO->AB7_TIPO == "4"
                       xNomeSts := "ATENDIDO"
                  Case RESULTADO->AB7_TIPO == "5"
                       xNomeSts := "ENCERRADO"
               EndCase              

               Do Case
                  Case Alltrim(xFilial) == "01"
                       oPrint:Say( _nLin, 1300, "FILIAL.:     01 - PORTO ALEGRE" , oFont10b)
                  Case Alltrim(xFilial) == "02"
                       oPrint:Say( _nLin, 1300, "FILIAL.:     02 - CAXIAS DO SUL", oFont10b)
                  Case Alltrim(xFilial) == "03"
                       oPrint:Say( _nLin, 1300, "FILIAL.:     03 - PELOTAS"      , oFont10b)
               EndCase

               SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
               oPrint:Say( _nLin, 1300, "TÉCNICO: " + Alltrim(xTecnico) + " - " + Alltrim(xNomeTecnico), oFont10b)
               SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
               oPrint:Say( _nLin, 1300, "STATUS.:      " + Alltrim(xStatus) + " - " + Alltrim(xNomeSts), oFont10b)
               SomaOS(100,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

            Endif

         Enddo

         SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

         oPrint:Say( _nLin,0100, "Total de OS do Status.: " + Str(nQtdSts,5), oFont10b)
         oPrint:Say( _nLin,2300, "TOTAL DO STATUS.: ", oFont08b)
         oPrint:Say( _nLin,2700, Str(nTotProS,12,02), oFont08b)
         oPrint:Say( _nLin,2900, Str(nTotSerS,12,02), oFont08b)
         oPrint:Say( _nLin,3100, Str(nTotTotS,12,02), oFont08b)

         SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

         oPrint:Say( _nLin,0100, "Total de OS do Técnico: " + Str(nQtdTec,5), oFont10b)
         oPrint:Say( _nLin,2300, "TOTAL DO TÉCNICO:", oFont08b)
         oPrint:Say( _nLin,2700, Str(nTotProT,12,02), oFont08b)
         oPrint:Say( _nLin,2900, Str(nTotSerT,12,02), oFont08b)
         oPrint:Say( _nLin,3100, Str(nTotTotT,12,02), oFont08b)

         SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

         oPrint:Say( _nLin,0100, "Total de OS da Filial.: " + Str(nQtdFil,5), oFont10b)            
         oPrint:Say( _nLin,2300, "TOTAL DA FILIAL.: ", oFont08b)
         oPrint:Say( _nLin,2700, Str(nTotProF,12,02), oFont08b)
         oPrint:Say( _nLin,2900, Str(nTotSerF,12,02), oFont08b)
         oPrint:Say( _nLin,3100, Str(nTotTotF,12,02), oFont08b)

         SomaOS(50,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

         oPrint:Say( _nLin,0100, "Total de OS Geral.....: " + Str(nQtdGer,5), oFont10b)            
         oPrint:Say( _nLin,2300, "TOTAL GERAL.....: ", oFont08b)
         oPrint:Say( _nLin,2700, Str(nTotProG,12,02), oFont08b)
         oPrint:Say( _nLin,2900, Str(nTotSerG,12,02), oFont08b)
         oPrint:Say( _nLin,3100, Str(nTotTotG,12,02), oFont08b)
      
         oPrint:EndPage()

         oPrint:Preview()

      Else

         DbSelectArea("RESULTADO")
      
         ProcRegua( RecCount() )

         nPagina := 0

         CABECAOZ(nPagina)

         While !RESULTADO->( EOF() )
   
            // PESQUISA OS COMNETÁRIOS DA ORDEM DE SERVIÇO
            // -------------------------------------------
            If Select("T_COMENTARIO") > 0
               T_COMENTARIO->( dbCloseArea() )
            EndIf  

            cSql := "SELECT A.YP_TEXTO "
            cSql += "  FROM " + RetSqlName("SYP010") + " A, "
            cSql += "       " + RetSqlName("AB4010") + " B  "
            cSql += " WHERE B.AB4_MEMO     = A.YP_CHAVE "
            cSql += "   AND B.AB4_NUMORC   = '" + Alltrim(RESULTADO->AB6_NUMOS)  + "'"
            cSql += "   AND B.AB4_FILIAL   = '" + Alltrim(RESULTADO->AB6_FILIAL) + "'"
            cSql += "   AND A.R_E_C_D_E_L_ = '' "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMENTARIO", .T., .T. )

            T_COMENTARIO->( DbGoTop() )

            For nContar = 1 to 30
                j := Strzero(nContar,2)
                cFrase&j := ""
            Next nContar    
               
            nContar  := 1
            _Posicao := 1
            _String  := ""

            While !T_COMENTARIO->( EOF() )
               j        := Strzero(nContar,2)
               _Frase01 := StrTran(T_COMENTARIO->YP_TEXTO, "\13\10", "")
               _Frase01 := StrTran(_Frase01, CHR(13), "")
               _Frase01 := StrTran(_Frase01, CHR(10), "")               
               _String  := _String + Alltrim(_Frase01) + " "
               T_COMENTARIO->( DbSkip() )
            Enddo   

            // Separa a string
            _Trinta      := 1
            _GravaString := ""

            For _Letras = 1 to Len(Alltrim(_String))
                If _Trinta <= 25
                   _GravaString := _GravaString + Substr(_String,_Letras,1)
                   _Trinta := _Trinta + 1
                Else
                   t := Strzero(_Posicao,2)
                   cFrase&t     := _GravaString
                   _Trinta      := 1
                   _Posicao     := _Posicao + 1
                   _GravaString := ""
                   _Letras      := _Letras - 1
                Endif
            Next _Letras    

            t := Strzero(_Posicao,2)
            cFrase&t := _GravaString

            // PESQUISA O LAUDO DA ORDEM DE SERVIÇO
            // ------------------------------------   
            /*
            If Select("T_LAUDO") > 0
               T_LAUDO->( dbCloseArea() )
            EndIf  

            cSql := "SELECT A.YP_TEXTO "
            cSql += "  FROM " + RetSqlName("SYP010") + " A, "
            cSql += "       " + RetSqlName("AB6010") + " B  "
            cSql += " WHERE B.AB6_MEMO7    = A.YP_CHAVE "
            cSql += "   AND B.AB6_NUMOS    = '" + Alltrim(RESULTADO->AB6_NUMOS)  + "'"
            cSql += "   AND B.AB6_FILIAL   = '" + Alltrim(RESULTADO->AB6_FILIAL) + "'"
            cSql += "   AND A.R_E_C_D_E_L_ = '' "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LAUDO", .T., .T. )
			
			T_LAUDO->( DbGoTop() )
			
            
            For nContar = 1 to 30
                j := Strzero(nContar,2)
                cLaudo&j := ""
            Next nContar    
               
            nContar  := 1
            _Posicao := 1
            _String  := ""

            While !T_LAUDO->( EOF() )
               j        := Strzero(nContar,2)
               _Frase01 := StrTran(T_LAUDO->YP_TEXTO, "\13\10", "")
               _Frase01 := StrTran(_Frase01, CHR(13), "")
               _Frase01 := StrTran(_Frase01, CHR(10), "")               
               _String := _String + Alltrim(_Frase01) + " "
               T_LAUDO->( DbSkip() )
            Enddo   
			*/
			_String:= RESULTADO->AB6_MLAUDO
			
            // Separa a string
            _Trinta      := 1
            _GravaString := ""

            For _Letras = 1 to Len(Alltrim(_String))
                If _Trinta <= 25
                   _GravaString := _GravaString + Substr(_String,_Letras,1)
                   _Trinta := _Trinta + 1
                Else
                   t := Strzero(_Posicao,2)
                   cLaudo&t     := _GravaString
                   _Trinta      := 1
                   _Posicao     := _Posicao + 1
                   _GravaString := ""
                   _Letras      := _Letras - 1
                Endif
            Next _Letras    

            t := Strzero(_Posicao,2)
            cLaudo&t := _GravaString

            // Pesquisa as peças aplicadas na ordem de serviço
            // -----------------------------------------------
            If Select("T_PECAS") > 0
               T_PECAS->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.AB5_NUMORC," 
            cSql += "       A.AB5_CODPRO,"
            cSql += "       B.B1_TIPO   ,"
            cSql += "       B.B1_DESC   ,"
            cSql += "       B.B1_PARNUM  "
            cSql += "  FROM " + RetSqlName("AB5010") + " A, "
            cSql += "       " + RetSqlName("SB1010") + " B  "
            cSql += " WHERE A.AB5_NUMORC   = '" + Substr(RESULTADO->AB7_NUMORC,01,06) + "'"
            cSql += "   AND A.AB5_FILIAL   = '" + Substr(RESULTADO->AB7_NUMORC,07,02) + "'"
            cSql += "   AND A.R_E_C_D_E_L_ = ''"
            cSql += "   AND A.AB5_CODPRO   = B.B1_COD "
       
            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PECAS", .T., .T. )

            T_PECAS->( DbGoTop() )

            _Posicao := 1

            While !T_PECAS->( EOF() )
               If T_PECAS->B1_TIPO == "MO"
               Else
                  J        := Strzero(_posicao,2)
                  cPecas&j := T_PECAS->B1_PARNUM
                  _Posicao := _Posicao + 1
               Endif
               T_PECAS->( DbSkip() )
            Enddo

            // Pesquisa o Contato do cliente da ordem de Serviço
            If Select("T_CONTATO") > 0
               T_CONTATO->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.AB3_CONTWF,"
            cSql += "       B.U5_CODCONT,"
            cSql += "       B.U5_CONTAT ,"
            cSql += "       B.U5_DDD    ,"
            cSql += "       B.U5_FONE    "
            cSql += "  FROM " + RetSqlName("AB3010") + " A, "
            cSql += "       " + RetSqlName("SU5010") + " B  "
            cSql += " WHERE A.AB3_CONTWF  = B.U5_CODCONT"
            cSql += "  AND A.R_E_C_D_E_L_ = ''"
            cSql += "  AND A.AB3_ETIQUE   = '" + Alltrim(RESULTADO->AB6_ETIQUE) + "'"
            cSql += "  AND A.AB3_FILIAL   = '" + Alltrim(RESULTADO->AB6_FILIAL) + "'"
            cSql += " GROUP BY A.AB3_CONTWF, B.U5_CODCONT, B.U5_CONTAT, B.U5_DDD,B.U5_FONE"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )
            
            If T_CONTATO->( Eof() )
               cContato := "          "
               cFone    := "             "
            Else
               cContato := T_CONTATO->U5_DDD
               cFone    := T_CONTATO->U5_FONE
            Endif   

            // Imprime os dados no relatório
            oPrint:Say( _nLin,0100, Substr(RESULTADO->B1_DESC,01,30), oFont7)
            oPrint:Say( _nLin,0600, RESULTADO->AB6_ETIQUE           , oFont7)
            oPrint:Say( _nLin,0800, Substr(RESULTADO->AB6_EMISSA,07,02) + "/" + Substr(RESULTADO->AB6_EMISSA,05,02) + "/" + Substr(RESULTADO->AB6_EMISSA,01,04) , oFont7)
            oPrint:Say( _nLin,1000, Substr(RESULTADO->AB6_EMISSA,07,02) + "/" + Substr(RESULTADO->AB6_EMISSA,05,02) + "/" + Substr(RESULTADO->AB6_EMISSA,01,04) , oFont7)
            oPrint:Say( _nLin,2570, Substr(RESULTADO->A1_NOME   ,01,23), oFont7)  
            oPrint:Say( _nLin,2950, Substr(cContato,01,10)          , oFont7)              
            oPrint:Say( _nLin,3120, Substr(cFone   ,01,13)          , oFont)              

            If !Empty(Alltrim(cFrase01))
               oPrint:Say( _nLin,1200, Alltrim(cFrase01), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo01))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo01), oFont7)
            Endif

            If !Empty(Alltrim(cPecas01))
               oPrint:Say( _nLin,2100, Alltrim(cPecas01), oFont7)
            Endif

            SomaOZ(50,nPagina)                        
            oPrint:Say( _nLin,0100, RESULTADO->AB7_NUMSER           , oFont7)

//          If !Empty(Alltrim(cFrase01) + Alltrim(claudo01) + Alltrim(cPecas01))
//             SomaOZ(50,nPagina)                        
//          Endif

            If !Empty(Alltrim(cFrase02))
               oPrint:Say( _nLin,1200, Alltrim(cFrase02), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo02))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo02), oFont7)
            Endif

            If !Empty(Alltrim(cPecas02))
               oPrint:Say( _nLin,2100, Alltrim(cPecas02), oFont7)
            Endif

            If !Empty(Alltrim(cFrase02) + Alltrim(claudo02) + Alltrim(cPecas02))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase03))
               oPrint:Say( _nLin,1200, Alltrim(cFrase03), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo03))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo03), oFont7)
            Endif

            If !Empty(Alltrim(cPecas03))
               oPrint:Say( _nLin,2100, Alltrim(cPecas03), oFont7)
            Endif

            If !Empty(Alltrim(cFrase03) + Alltrim(claudo03) + Alltrim(cPecas03))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase04))
               oPrint:Say( _nLin,1200, Alltrim(cFrase04), oFont7)
            Endif   

            If !Empty(Alltrim(cLaudo04))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo04), oFont7)
            Endif   

            If !Empty(Alltrim(cPecas04))
               oPrint:Say( _nLin,2100, Alltrim(cpecas04), oFont7)
            Endif   

            If !Empty(Alltrim(cFrase04) + Alltrim(claudo04) + Alltrim(cPecas04))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase05))
               oPrint:Say( _nLin,1200, Alltrim(cFrase05), oFont7)
            Endif   

            If !Empty(Alltrim(cLaudo05))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo05), oFont7)
            Endif   

            If !Empty(Alltrim(cPecas05))
               oPrint:Say( _nLin,2100, Alltrim(cPecas05), oFont7)
            Endif   

            If !Empty(Alltrim(cFrase05) + Alltrim(claudo05) + Alltrim(cPecas05))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase06))
               oPrint:Say( _nLin,1200, Alltrim(cFrase06), oFont7)
            Endif   

            If !Empty(Alltrim(cLaudo06))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo06), oFont7)
            Endif   

            If !Empty(Alltrim(cPecas06))
               oPrint:Say( _nLin,2100, Alltrim(cPecas06), oFont7)
            Endif   

            If !Empty(Alltrim(cFrase06) + Alltrim(claudo06) + Alltrim(cPecas06))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase07))
               oPrint:Say( _nLin,1200, Alltrim(cFrase07), oFont7)
            Endif   

            If !Empty(Alltrim(cLaudo07))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo07), oFont7)
            Endif   

            If !Empty(Alltrim(cPecas07))
               oPrint:Say( _nLin,2100, Alltrim(cPecas07), oFont7)
            Endif   

            If !Empty(Alltrim(cFrase07) + Alltrim(claudo07) + Alltrim(cPecas07))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase08))
               oPrint:Say( _nLin,1200, Alltrim(cFrase08), oFont7)
            Endif
               
            If !Empty(Alltrim(cLaudo08))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo08), oFont7)
            Endif

            If !Empty(Alltrim(cPecas08))
               oPrint:Say( _nLin,2100, Alltrim(cPecas08), oFont7)
            Endif

            If !Empty(Alltrim(cFrase08) + Alltrim(claudo08) + Alltrim(cPecas08))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase09))
               oPrint:Say( _nLin,1200, Alltrim(cFrase09), oFont7)                                    
            Endif
               
            If !Empty(Alltrim(cLaudo09))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo09), oFont7)                                    
            Endif

            If !Empty(Alltrim(cPecas09))
               oPrint:Say( _nLin,2100, Alltrim(cPecas09), oFont7)                                    
            Endif

            If !Empty(Alltrim(cFrase09) + Alltrim(claudo09) + Alltrim(cPecas09))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase10))
               oPrint:Say( _nLin,1200, Alltrim(cFrase10), oFont7)                        
            Endif
               
            If !Empty(Alltrim(cLaudo10))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo10), oFont7)                        
            Endif

            If !Empty(Alltrim(cPecas10))
               oPrint:Say( _nLin,2100, Alltrim(cPecas10), oFont7)                        
            Endif

            If !Empty(Alltrim(cFrase10) + Alltrim(claudo10) + ALltrim(cPecas10))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase11))
               oPrint:Say( _nLin,1200, Alltrim(cFrase11), oFont7)
            Endif
               
            If !Empty(Alltrim(cLaudo11))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo11), oFont7)
            Endif

            If !Empty(Alltrim(cPecas11))
               oPrint:Say( _nLin,2100, Alltrim(cPecas11), oFont7)
            Endif

            If !Empty(Alltrim(cFrase11) + Alltrim(claudo11) + Alltrim(cPecas11))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase12))
               oPrint:Say( _nLin,1200, Alltrim(cFrase12), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo12))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo12), oFont7)
            Endif

            If !Empty(Alltrim(cPecas12))
               oPrint:Say( _nLin,2100, Alltrim(cPecas12), oFont7)
            Endif

            If !Empty(Alltrim(cFrase12) + Alltrim(claudo12) + Alltrim(cPecas12))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase13))
               oPrint:Say( _nLin,1200, Alltrim(cFrase13), oFont7)
            Endif   

            If !Empty(Alltrim(cLaudo13))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo13), oFont7)
            Endif   

            If !Empty(Alltrim(cPecas13))
               oPrint:Say( _nLin,2100, Alltrim(cPecas13), oFont7)
            Endif   

            If !Empty(Alltrim(cFrase13) + Alltrim(claudo13) + Alltrim(cPecas13))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase14))
               oPrint:Say( _nLin,1200, Alltrim(cFrase14), oFont7)
            Endif
               
            If !Empty(Alltrim(cLaudo14))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo14), oFont7)
            Endif

            If !Empty(Alltrim(cPecas14))
               oPrint:Say( _nLin,2100, Alltrim(cPecas14), oFont7)
            Endif

            If !Empty(Alltrim(cFrase14) + Alltrim(claudo14) + Alltrim(cPecas14))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase15))
               oPrint:Say( _nLin,1200, Alltrim(cFrase15), oFont7)
            Endif   

            If !Empty(Alltrim(cLaudo15))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo15), oFont7)
            Endif   

            If !Empty(Alltrim(cPecas15))
               oPrint:Say( _nLin,2100, Alltrim(cPecas15), oFont7)
            Endif   

            If !Empty(Alltrim(cFrase15) + Alltrim(claudo15) + Alltrim(cPecas15))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase16))
               oPrint:Say( _nLin,1200, Alltrim(cFrase16), oFont7)
            Endif   

            If !Empty(Alltrim(cLaudo16))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo16), oFont7)
            Endif   

            If !Empty(Alltrim(cPecas16))
               oPrint:Say( _nLin,2100, Alltrim(cPecas16), oFont7)
            Endif   

            If !Empty(Alltrim(cFrase16) + Alltrim(claudo16) + Alltrim(cPecas16))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase17))
               oPrint:Say( _nLin,1200, Alltrim(cFrase17), oFont7)
            Endif
               
            If !Empty(Alltrim(cLaudo17))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo17), oFont7)
            Endif

            If !Empty(Alltrim(cPecas17))
               oPrint:Say( _nLin,2100, Alltrim(cPecas17), oFont7)
            Endif

            If !Empty(Alltrim(cFrase17) + Alltrim(claudo17) + Alltrim(cPecas17))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase18))
               oPrint:Say( _nLin,1200, Alltrim(cFrase18), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo18))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo18), oFont7)
            Endif

            If !Empty(Alltrim(cPecas18))
               oPrint:Say( _nLin,2100, Alltrim(cPecas18), oFont7)
            Endif

            If !Empty(Alltrim(cFrase18) + Alltrim(claudo18) + Alltrim(cPecas18))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase19))
               oPrint:Say( _nLin,1200, Alltrim(cFrase19), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo19))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo19), oFont7)
            Endif

            If !Empty(Alltrim(cPecas19))
               oPrint:Say( _nLin,2100, Alltrim(cPecas19), oFont7)
            Endif

            If !Empty(Alltrim(cFrase19) + Alltrim(claudo19) + Alltrim(cPecas19))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase20))
               oPrint:Say( _nLin,1200, Alltrim(cFrase20), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo20))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo20), oFont7)
            Endif

            If !Empty(Alltrim(cPecas20))
               oPrint:Say( _nLin,2100, Alltrim(cPecas20), oFont7)
            Endif

            If !Empty(Alltrim(cFrase20) + Alltrim(claudo20) + Alltrim(cPecas20))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase21))
               oPrint:Say( _nLin,1200, Alltrim(cFrase21), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo21))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo21), oFont7)
            Endif

            If !Empty(Alltrim(cPecas21))
               oPrint:Say( _nLin,2100, Alltrim(cPecas21), oFont7)
            Endif

            If !Empty(Alltrim(cFrase21) + Alltrim(claudo21) + Alltrim(cPecas21))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase22))
               oPrint:Say( _nLin,1200, Alltrim(cFrase22), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo22))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo22), oFont7)
            Endif

            If !Empty(Alltrim(cPecas22))
               oPrint:Say( _nLin,2100, Alltrim(cPecas22), oFont7)
            Endif

            If !Empty(Alltrim(cFrase22) + Alltrim(claudo22) + Alltrim(cPecas22))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase23))
               oPrint:Say( _nLin,1200, Alltrim(cFrase23), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo23))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo23), oFont7)
            Endif

            If !Empty(Alltrim(cPecas23))
               oPrint:Say( _nLin,2100, Alltrim(cPecas23), oFont7)
            Endif

            If !Empty(Alltrim(cFrase23) + Alltrim(claudo23) + Alltrim(cPecas23))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase24))
               oPrint:Say( _nLin,1200, Alltrim(cFrase24), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo24))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo24), oFont7)
            Endif

            If !Empty(Alltrim(cPecas24))
               oPrint:Say( _nLin,2100, Alltrim(cPecas24), oFont7)
            Endif

            If !Empty(Alltrim(cFrase24) + Alltrim(claudo24) + Alltrim(cPecas24))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase25))
               oPrint:Say( _nLin,1200, Alltrim(cFrase25), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo25))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo25), oFont7)
            Endif

            If !Empty(Alltrim(cPecas25))
               oPrint:Say( _nLin,2100, Alltrim(cPecas25), oFont7)
            Endif

            If !Empty(Alltrim(cFrase25) + Alltrim(claudo25) + Alltrim(cPecas25))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase26))
               oPrint:Say( _nLin,1200, Alltrim(cFrase26), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo26))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo26), oFont7)
            Endif

            If !Empty(Alltrim(cPecas26))
               oPrint:Say( _nLin,2100, Alltrim(cPecas26), oFont7)
            Endif

            If !Empty(Alltrim(cFrase26) + Alltrim(claudo26) + Alltrim(cPecas26))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase27))
               oPrint:Say( _nLin,1200, Alltrim(cFrase27), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo27))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo27), oFont7)
            Endif

            If !Empty(Alltrim(cPecas27))
               oPrint:Say( _nLin,2100, Alltrim(cPecas27), oFont7)
            Endif

            If !Empty(Alltrim(cFrase27) + Alltrim(claudo27) + Alltrim(cPecas27))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase28))
               oPrint:Say( _nLin,1200, Alltrim(cFrase28), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo28))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo28), oFont7)
            Endif

            If !Empty(Alltrim(cPecas28))
               oPrint:Say( _nLin,2100, Alltrim(cPecas28), oFont7)
            Endif

            If !Empty(Alltrim(cFrase28) + Alltrim(claudo28) + Alltrim(cPecas28))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase29))
               oPrint:Say( _nLin,1200, Alltrim(cFrase29), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo29))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo29), oFont7)
            Endif

            If !Empty(Alltrim(cPecas29))
               oPrint:Say( _nLin,2100, Alltrim(cPecas29), oFont7)
            Endif

            If !Empty(Alltrim(cFrase29) + Alltrim(claudo29) + Alltrim(cPecas29))
               SomaOZ(50,nPagina)                        
            Endif

            If !Empty(Alltrim(cFrase30))
               oPrint:Say( _nLin,1200, Alltrim(cFrase30), oFont7)
            Endif

            If !Empty(Alltrim(cLaudo30))
               oPrint:Say( _nLin,1650, Alltrim(cLaudo30), oFont7)
            Endif

            If !Empty(Alltrim(cPecas30))
               oPrint:Say( _nLin,2100, Alltrim(cPecas30), oFont7)
            Endif

            If !Empty(Alltrim(cFrase30) + Alltrim(claudo30) + Alltrim(cPecas30))
               SomaOZ(50,nPagina)                        
            Endif

            SomaOZ(50,nPagina)
   
            RESULTADO->( DBSKIP() )
          
         ENDDO   
  
         oPrint:EndPage()

         oPrint:Preview()
   
      Endif
      
   Endif

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.

// Imprime o cabeçalho do relatório
Static Function CABECACHA(xFilial, xStatus, xNomeSts, nPagina)

   Private nPagina := 0

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "RELAÇÃO DE CHAMADOS TÉCNICOS"         , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR32", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "DATA"                  , oFont21)  
   oPrint:Say( _nLin, 0275, "ETIQUETA"              , oFont21)  
   oPrint:Say( _nLin, 0440, "DESCRICAO DOS CLIENTES", oFont21)  
   oPrint:Say( _nLin, 1170, "OCORRÊNCIA"            , oFont21)  
   oPrint:Say( _nLin, 1550, "DESCRIÇÃO DOS PRODUTOS", oFont21)  
   oPrint:Say( _nLin, 2700, "Nº DE SÉRIE"           , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

   Do Case
      Case Alltrim(xFilial) == "01"
           oPrint:Say( _nLin, 1400, "FILIAL.: 01 - PORTO ALEGRE" , oFont10b)
      Case Alltrim(xFilial) == "02"
           oPrint:Say( _nLin, 1400, "FILIAL.: 02 - CAXIAS DO SUL", oFont10b)
      Case Alltrim(xFilial) == "03"
           oPrint:Say( _nLin, 1400, "FILIAL.: 03 - PELOTAS"      , oFont10b)
   EndCase

   _nLin += 50
   oPrint:Say( _nLin, 1400, "STATUS.:  " + Alltrim(xStatus) + " - " + Alltrim(xNomeSts), oFont10b)

   _nLin += 100

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaCha(nLinhas,xFilial, xStatus, xNomeSts, nPagina)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECACHA(xFilial, xStatus, xNomeSts, nPagina)
   Endif
   
Return .T.      

// Imprime o cabeçalho do relatório
Static Function CABECAORC(xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

   Private nPagina := 0

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "RELAÇÃO DE ORÇAMENTOS"                , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR32", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "DATA"                  , oFont21)  
   oPrint:Say( _nLin, 0275, "ETIQUETA"              , oFont21)  
   oPrint:Say( _nLin, 0440, "DESCRICAO DOS CLIENTES", oFont21)  
   oPrint:Say( _nLin, 0970, "OCORRÊNCIA"            , oFont21)  
   oPrint:Say( _nLin, 1200, "DESCRIÇÃO DOS PRODUTOS", oFont21)  
   oPrint:Say( _nLin, 2300, "Nº DE SÉRIE"           , oFont21)  
   oPrint:Say( _nLin, 2700, "    PRODUTOS"          , oFont21)  
   oPrint:Say( _nLin, 2900, "    SERVIÇOS"          , oFont21)  
   oPrint:Say( _nLin, 3150, "    TOTAL"             , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

   Do Case
      Case Alltrim(xFilial) == "01"
           oPrint:Say( _nLin, 1300, "FILIAL.:     01 - PORTO ALEGRE" , oFont10b)
      Case Alltrim(xFilial) == "02"
           oPrint:Say( _nLin, 1300, "FILIAL.:     02 - CAXIAS DO SUL", oFont10b)
      Case Alltrim(xFilial) == "03"
           oPrint:Say( _nLin, 1300, "FILIAL.:     03 - PELOTAS"      , oFont10b)
   EndCase

   _nLin += 50
   oPrint:Say( _nLin, 1300, "TÉCNICO: " + Alltrim(xTecnico) + " - " + Alltrim(xNomeTecnico), oFont10b)   
   _nLin += 50   
   oPrint:Say( _nLin, 1300, "STATUS.:      " + Alltrim(xStatus) + " - " + Alltrim(xNomeSts), oFont10b)
   _nLin += 100

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaOrc(nLinhas,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAORC(xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
   Endif
   
Return .T.      

// Imprime o cabeçalho do relatório - ORDENS DE SERVIÇO
Static Function CABECAOS(xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)

   Private nPagina := 0

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "RELAÇÃO DE ORDENS DE SERVIÇO"         , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR32", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "DATA"                  , oFont21)  
   oPrint:Say( _nLin, 0275, "ETIQUETA"              , oFont21)  
   oPrint:Say( _nLin, 0440, "DESCRICAO DOS CLIENTES", oFont21)  
   oPrint:Say( _nLin, 0800, "OCORRÊNCIA"            , oFont21)  
   oPrint:Say( _nLin, 1050, "Nº PV"                 , oFont21)  
   oPrint:Say( _nLin, 1170, "NF"                    , oFont21)  
   oPrint:Say( _nLin, 1300, "DESCRIÇÃO DOS PRODUTOS", oFont21)  
   oPrint:Say( _nLin, 2300, "Nº DE SÉRIE"           , oFont21)  
   oPrint:Say( _nLin, 2700, "    PRODUTOS"          , oFont21)  
   oPrint:Say( _nLin, 2900, "    SERVIÇOS"          , oFont21)  
   oPrint:Say( _nLin, 3150, "    TOTAL"             , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

   Do Case
      Case Alltrim(xFilial) == "01"
           oPrint:Say( _nLin, 1300, "FILIAL.:     01 - PORTO ALEGRE" , oFont10b)
      Case Alltrim(xFilial) == "02"
           oPrint:Say( _nLin, 1300, "FILIAL.:     02 - CAXIAS DO SUL", oFont10b)
      Case Alltrim(xFilial) == "03"
           oPrint:Say( _nLin, 1300, "FILIAL.:     03 - PELOTAS"      , oFont10b)
   EndCase

   _nLin += 50
   oPrint:Say( _nLin, 1300, "TÉCNICO: " + Alltrim(xTecnico) + " - " + Alltrim(xNomeTecnico), oFont10b)   
   _nLin += 50   
   oPrint:Say( _nLin, 1300, "STATUS.:      " + Alltrim(xStatus) + " - " + Alltrim(xNomeSts), oFont10b)
   _nLin += 100

Return .T.


// Função que soma linhas para impressão
Static Function SomaOS(nLinhas,xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAOS(xFilial, xStatus, xTecnico, xNomeTecnico, xNomeSts, nPagina)
   Endif
   
Return .T.      

// Imprime o cabeçalho do relatório do Layout ZEBRA
Static Function CABECAOZ(nPagina)

   Private nPagina := 0

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "RELAÇÃO DE ORDENS DE SERVIÇO"         , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR32", oFont09  )
   oPrint:Say( _nLin, 1400, "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "MODELO"             , oFont21)  
   oPrint:Say( _nLin, 0600, "Nº ETIQUETA"        , oFont21)  
   oPrint:Say( _nLin, 0800, "DT ENTRADA"         , oFont21)  
   oPrint:Say( _nLin, 1000, "DT SAÍDA"           , oFont21)  
   oPrint:Say( _nLin, 1200, "PROBLEMA INFORMADO" , oFont21)  
   oPrint:Say( _nLin, 1650, "PROBLEMA VERIFICADO", oFont21)  
   oPrint:Say( _nLin, 2100, "PART NUMBER"        , oFont21)  
   oPrint:Say( _nLin, 2570, "CLIENTE"            , oFont21)  
   oPrint:Say( _nLin, 2950, "CONTATO"            , oFont21)  
   oPrint:Say( _nLin, 3120, "TELEFONE"           , oFont21)  
   _nLin += 30
   oPrint:Say( _nLin, 0100, "Nº SÉRIE"           , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 100

Return .T.

// Função que soma linhas para impressão
Static Function SomaOZ(nLinhas,nPagina)
   
//   _nLin := _nLin + nLinhas

   _nLin := _nLin + 30

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAOZ(nPagina)         
   Endif
   
Return .T.      

// Função que solicita o tipo de layout a ser utilizado em caso de Pesquisa em Orçamento
Static Function _AbreSolici()

   Private aComboBx15 := {"1 - Normal", "2 - Layout ZEBRA"}
   Private cComboBx15 := ""

   DEFINE MSDIALOG _oDlg TITLE "Novo Formulário" FROM C(178),C(181) TO C(295),C(440) PIXEL

   @ C(004),C(006) Say "Informe o Layout de relatório a ser utilizado para esta opção" Size C(143),C(008) COLOR CLR_BLACK PIXEL OF _oDlg

   @ C(016),C(006) ComboBox cComboBx15 Items aComboBx15 Size C(111),C(010) PIXEL OF _oDlg

   @ C(037),C(050) Button "OK" Size C(037),C(012) PIXEL OF _oDlg ACTION( _odlg:end()  )

   ACTIVATE MSDIALOG _oDlg CENTERED 

Return cComboBx15


/*
         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              RELAÇÃO DE CHAMADOS TÉCNICOS                                                                      XX/XX/XXXX-XX:XX:XX
AUTOMR06.PRW                                                                       PERIODO DE XX/XX/XXXX A XX/XX/XXXX                                                                PAGINA:       XXXXX 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   DATA    ETIQUETA NOME DO CLIENTE                          STATUS              NF     DESCRIÇÃO DO PRODUTO                                       NR. DE SÉRIE          VLR PROD.   VLR SER.      TOTAL"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                                                                        FILIAL.:     01 - PORTO ALEGRE 
                                                                        TÉCNICO: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
XX/XX/XXXX XXXXXXXX OS         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX .................................................... XXXXXXXXXXXXXXXXXXXX 9,999,999.99 9,999,999.99 9,999,999.99
XX/XX/XXXX XXXXXXXX PV GERADO  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9,999,999.99 9,999,999.99 9,999,999.99 
XX/XX/XXXX XXXXXXXX EM ATEND.  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9,999,999.99 9,999,999.99 9,999,999.99
XX/XX/XXXX XXXXXXXX ATENDIDO   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9,999,999.99 9,999,999.99 9,999,999.99
XX/XX/XXXX XXXXXXXX ENCERRADO  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9,999,999.99 9,999,999.99 9,999,999.99
                    NAO DEFIN.
         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                                                                                                                                                 TOTAL DO TÉCNICO XXXXXXX.XX XXXXXXX.XX XXXXXXX.XX
*/
