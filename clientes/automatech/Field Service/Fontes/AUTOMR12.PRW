#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR12.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/09/2011                                                          *
// Objetivo..: Relatório Gerencial Assistência Técnica                             *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR12()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   	  := {}
   Local _aAlias  	  := {}
   Local cSql         := ""
   Local cNomeProduto := ""
   Local cProduto     := Space(30)

   // Variáveis Private da Função
   Private dData01   := Ctod("  /  /    ")
   Private dData02   := Ctod("  /  /    ")
   Private cCliente  := Space(06)
   Private cLoja     := Space(03)
   Private NomeCli   := Space(60)
   Private NomeGru   := Space(30)
   Private cProduto  := Space(30)
   Private cGrupo    := Space(06)
   Private NomePro   := Space(60)
   Private cTecnico  := Space(06)
   Private cSerie    := Space(30)
   Private cParte    := Space(40)

   NomeCli := "......................................................................"
   NomePro := "......................................................................"
   NomeGru := "......................................................................"

   Private aComboBx1 := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS"}
   Private aComboBx2 := {}
   Private aComboBx3 := {"1 - NÃO FATURADAS", "2 - FATURADAS"}
   Private aComboBx4 := {"0 - TODOS OS STATUS", "1 - O.S.", "2 - PV GERADO", "3 - EM ATENDIMENTO", "4 - ATENDIDO", "5 - ENCERRADO"}
   Private aComboBx5 := {"0 - INICIANDO", "1 - CONTENDO"}
   Private aComboBx6 := {"0 - SOMENTE LOJA INFORMADA", "1 - TODAS AS LOJAS DO CLIENTE INFORMADO"}

   Private nGet1	 := Ctod("  /  /    ")
   Private nGet2	 := Ctod("  /  /    ")
   Private nGet3	 := Space(06)
   Private nGet4	 := Space(03)
   Private nGet5	 := Space(30)
   Private nGet6	 := Space(06)
   Private nGet7	 := Space(30)
   Private nGet8	 := Space(06)
   Private nGet9	 := Space(40)

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   Private cComboBx6

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

   DEFINE MSDIALOG oDlg TITLE "Relatório Gerencial Assistência Técnica" FROM C(178),C(181) TO C(590),C(550) PIXEL

   // Solicita o nº da etiqueta a ser impressa
   @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(011),C(085) Say "Data Final:"   Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(029),C(005) Say "Cliente:"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(085) Say NomeCli         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(043),C(005) Say "Pesq.Cliente:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Produto:"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(085) Say NomePro         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(005) Say "Grupo:"        Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(085) Say NomeGru         Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(112),C(005) Say "Técnico:"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(129),C(005) Say "Filial:"       Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(146),C(005) Say "Nº Série:"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(163),C(005) Say "Status:"       Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(180),C(005) Say "Faturamento:"  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(009),C(035) MsGet oGet1 Var dData01            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(009),C(110) MsGet oGet2 Var dData02            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(026),C(035) MsGet oGet3 Var cCliente           Size C(020),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1") 
   @ C(026),C(063) MsGet oGet4 Var cLoja              Size C(005),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TrazNomeCliente(cCliente, cLoja) ) 
   @ C(042),C(035) ComboBox cComboBx6 Items aComboBx6 WHEN !Empty(cCliente) Size C(140),C(010) PIXEL OF oDlg
   @ C(055),C(035) MsGet oGet5 Var cProduto           Size C(045),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNomeProd(cProduto) )
   @ C(072),C(035) MsGet oGet8 Var cGrupo             Size C(020),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SBM") VALID( BuscaNomeGrupo(cGrupo) )
   @ C(092),C(035) MsGet oGet9 Var cParte             WHEN !Empty(cGrupo) Size C(095),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg 
   @ C(093),C(135) ComboBox cComboBx5 Items aComboBx5 WHEN !Empty(cGrupo) Size C(040),C(010) PIXEL OF oDlg
   @ C(109),C(035) ComboBox cComboBx2 Items aComboBx2 Size C(140),C(010) PIXEL OF oDlg
   @ C(126),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(140),C(010) PIXEL OF oDlg
   @ C(143),C(035) MsGet oGet7 Var cSerie             Size C(050),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg 
   @ C(160),C(035) ComboBox cComboBx4 Items aComboBx4 Size C(140),C(010) PIXEL OF oDlg
   @ C(177),C(035) ComboBox cComboBx3 Items aComboBx3 WHEN Substr(cCombobx4,01,01) == "2" Size C(140),C(010) PIXEL OF oDlg
   
   DEFINE SBUTTON FROM C(190),C(132) TYPE  6 ENABLE OF oDlg ACTION( RELTECNICA( dData01, dData02, cCliente, cLoja, cProduto, cSerie, cComboBx1, cComboBx2, cComboBx4, cGrupo, cComboBx3, cParte, cComboBx5, cComboBx6 ))
   DEFINE SBUTTON FROM C(190),C(155) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

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

// Função que prepara a impressão do relatório
Static Function RELTECNICA( dData01, dData02, cCliente, cLoja, cProduto, cSerie, cComboBx1, cComboBx2, cComboBx4, cGrupo, cComboBx3, cParte, cComboBx5, cComboBx6 )

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
   
   xComboBx1 := cComboBx1
   xComboBx2 := cComboBx2
   xComboBx3 := cComboBx3
   xComboBx4 := cComboBx4
   xComboBx5 := cComboBx5                            
   xComboBx6 := cComboBx6
   
   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

   pergunte(cPerg,.F.)

   // Monta a interface padrao com o usuario
   wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   xTitulo := dtoc(dData01)           + "|"   + ;
              dtoc(dData02)           + "|"   + ;
              cCliente                + "|"   + ;
              cLoja                   + "|"   + ;
              cProduto                + "|"   + ;
              cSerie                  + "|"   + ;
              Substr(cComboBx1,01,02) + "|"   + ;
              Substr(cComboBx2,01,06) + "|0|" + ;
              Substr(cComboBx4,01,01) + "|"   + ;
              cGrupo                  + "|"   + ;
              Substr(cComboBx3,01,01) + "|"   + ;
              cParte                  + "|"   + ;
              Substr(cComboBx5,01,01) + "|"   + ;
              Substr(cComboBx6,01,01) + "|"

   // Processamento. RPTSTATUS monta janela com a regua de processamento.
   RptStatus({|| RunReport(Cabec1,Cabec2,xTitulo,nLin) },Titulo)

Return .T.

// Função que gera o relatório
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
   Local nPagina   := 0
   Local aPesquisa := {}
   Local nContar   := 0
   Local dData01   := Ctod('  /  /    ')
   Local dData02   := Ctod('  /  /    ')
   Local _Produto  := Space(30)
   Local _Cliente  := Space(06)
   Local _Loja     := Space(03)
   Local _Serie    := Space(30)
   Local _Tecnico  := Space(06)
   Local _Filial   := Space(02)
   Local _Status   := Space(01)
   Local _Posicao  := Space(01)
   Local _Grupo    := Space(06)
   Local cConteudo := ""
   Local _Faturado := Space(01)
   Local _Parte    := Space(40)
   Local _Busca    := Space(01)

   // Captura os valores do parâmetro Título
   nPipe     := 1
   cConteudo := ""
   For nContar = 1 to len(Titulo)
       If Substr(titulo,nContar,1) <> "|"
          cConteudo := cConteudo + Substr(titulo,nContar,1)
       Else
          Do Case
             Case nPipe == 1
                  dData01   := ctod(cConteudo)
             Case nPipe == 2
                  dData02   := ctod(cConteudo)
             Case nPipe == 3
                  _Cliente  := cConteudo
             Case nPipe == 4
                  _Loja     := cConteudo
             Case nPipe == 5
                  _Produto  := cConteudo
             Case nPipe == 6
                  _Serie    := cConteudo
             Case nPipe == 7
                  _Filial   := cConteudo
             Case nPipe == 8
                  _Tecnico  := cConteudo
             Case nPipe == 9
                  _Status   := cConteudo
             Case nPipe == 10
                  _Posicao  := cConteudo
             Case nPipe == 11
                  _Grupo    := cConteudo
             Case nPipe == 12
                  _Faturado := cConteudo
             Case nPipe == 13
                  _Parte    := cConteudo
             Case nPipe == 14
                  _Busca    := cConteudo
             Case nPipe == 15
                  _TipoPq   := cConteudo
          EndCase        
          nPipe     := nPipe + 1
          cConteudo := ""
       Endif
   Next nContar    

   // Pesquisa os dados para emissão do relatório
   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AB1_FILIAL, "
   cSql += "       A.AB1_EMISSA, "
   cSql += "       A.AB1_ETIQUE, "
   cSql += "       A.AB1_CODCLI, "
   cSql += "       A.AB1_LOJA  , "
   cSql += "       B.A1_NOME   , "
   cSql += "       C.AB2_TIPO  , "
   cSql += "       C.AB2_CODPRO, "
   cSql += "       C.AB2_NUMSER, "
   cSql += "       D.B1_DESC   , "
   cSql += "       D.B1_DAUX   , "
   cSql += "       D.B1_GRUPO    "
   cSql += "  FROM " + RetSqlName("AB1010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B, "
   cSql += "       " + RetSqlName("AB2010") + " C, "
   cSql += "       " + RetSqlName("SB1010") + " D  "
   cSql += " WHERE A.AB1_CODCLI   = B.A1_COD     "
   cSql += "   AND A.AB1_LOJA     = B.A1_LOJA    "
   cSql += "   AND A.AB1_NRCHAM   = C.AB2_NRCHAM "
   cSql += "   AND A.AB1_EMISSA  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND A.AB1_EMISSA <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
   cSql += "   AND A.R_E_C_D_E_L_ = ''           "
   cSql += "   AND C.AB2_FILIAL   = A.AB1_FILIAL "  
   cSql += "   AND C.R_E_C_D_E_L_ = ''           "
   cSql += "   AND C.AB2_CODPRO   = D.B1_COD     "

   // Filtra por Cliente
   If !Empty(Alltrim(_Cliente))
      cSql += " AND A.AB1_CODCLI = '" + Alltrim(_Cliente) + "'"

      If _TipoPQ == "0"
         cSql += " AND A.AB1_LOJA   = '" + Alltrim(_Loja)    + "'"
      Endif
         
   Endif
      
   // Filtra por Produto
   If !Empty(Alltrim(_Produto))
      cSql += " AND C.AB2_CODPRO = '" + Alltrim(_Produto) + "'"
   Endif
      
   // Filtra por Nº Série
   If !Empty(Alltrim(_Serie))
      cSql += " AND C.AB2_NUMSER = '" + Alltrim(_Serie)   + "'"
   Endif
 
   // Filtra por Filial
   If _Filial <> "00"     
      cSql += " AND A.AB1_FILIAL = '" + Alltrim(_Filial) + "'"
   Endif

   // Tipo de Lançamento
   If _Status <> "0"
      cSql += "  AND C.AB2_TIPO = '" + Alltrim(_Status) + "'"
   Endif   

   // Seleciona por codigo de grupo de produtos
   If !Empty(_Grupo)
      cSql += " AND D.B1_GRUPO = '" + Alltrim(_Grupo) + "'"
   Endif

   If !Empty(_Parte)
      If _Busca == "0"
         cSql += " AND D.B1_DESC LIKE '" + Alltrim(_Parte) + "%'"
      Else
         cSql += " AND D.B1_DESC LIKE '%" + Alltrim(_Parte) + "%'"         
      Endif
   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )

   RESULTADO->( DbGoTop() )

   If RESULTADO->( Eof() )
      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   // Carrega o Array com o resultado a ser impresso
   Resultado->( DbGoTop() )
   While !Resultado->( EOF() )

      // Pesquisa o nome do técnico do chamado técnico
      If Select("T_TECNICO") > 0
         T_TECNICO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB3_RLAUDO, "
      cSql += "       B.AA1_CODTEC, "
      cSql += "       B.AA1_NOMTEC  "
      cSql += "  FROM " + RetSqlName("AB3010") + " A, "
      cSql += "       " + RetSqlName("AA1010") + " B  "
      cSql += " WHERE A.AB3_ETIQUE   = '" + Alltrim(RESULTADO->AB1_ETIQUE) + "'"
      cSql += "   AND A.AB3_FILIAL   = '" + Alltrim(RESULTADO->AB1_FILIAL) + "'"
      cSql += "   AND A.AB3_RLAUDO   = B.AA1_CODTEC "
      cSql += "   AND A.R_E_C_D_E_L_ = ''"
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICO", .T., .T. )

      If !T_TECNICO->( EOF() )
         cCodiTecnico := T_TECNICO->AA1_CODTEC
         cNomeTecnico := T_TECNICO->AA1_NOMTEC
      Else
         cCodiTecnico := "000000"
         cNomeTecnico := "SEM INFORMAÇÃO DE TÉCNICO"
      Endif

      If _Tecnico <> "000000"
         If _Tecnico <> cCodiTecnico
            Resultado->( DbSkip() )
            Loop
         Endif
      Endif

      Do Case
         Case Int(val(Resultado->AB2_TIPO)) == 1
              cSituacao := "CHAMADO"
         Case Int(val(Resultado->AB2_TIPO)) == 2
              cSituacao := "ORÇAMENTO"
         Case Int(val(Resultado->AB2_TIPO)) == 3
              cSituacao := "O.S."
         Case Int(val(Resultado->AB2_TIPO)) == 4
              cSituacao := "SUSPENSO"
         Case Int(val(Resultado->AB2_TIPO)) == 5
              cSituacao := "ENCERRADO"
         Case Int(val(Resultado->AB2_TIPO)) == 6
              cSituacao := "HELP DESK"
         OtherWise
              cSituacao := "---------------"

      EndCase              

      // Pesquisa os Valores do Orçamento
      If Select("T_VALORES") > 0
         T_VALORES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB3_ETIQUE,    "
      cSql += "       A.AB3_NUMORC,    "
      cSql += "       C.B1_TIPO,       "
      cSql += "       SUM(B.AB5_TOTAL) AS TOTCHAM "
      cSql += "  FROM " + RetSqlName("AB3010") + " A, "
      cSql += "       " + RetSqlName("AB5010") + " B, "
      cSql += "       " + RetSqlName("SB1010") + " C  "
      cSql += " WHERE A.AB3_ETIQUE = '" + Alltrim(RESULTADO->AB1_ETIQUE) + "'"
      cSql += "   AND A.AB3_FILIAL = '" + Alltrim(RESULTADO->AB1_FILIAL) + "'"
      cSql += "   AND B.AB5_NUMORC = A.AB3_NUMORC "
      cSql += "   AND B.AB5_FILIAL = '" + Alltrim(RESULTADO->AB1_FILIAL) + "'"
      cSql += "   AND C.B1_COD = B.AB5_CODPRO     "
      cSql += "   AND A.R_E_C_D_E_L_ = ''         "
      cSql += "   AND B.R_E_C_D_E_L_ = ''         "
      cSql += " GROUP BY A.AB3_ETIQUE, A.AB3_NUMORC, C.B1_TIPO "
      
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
         cNumOrc   := T_VALORES->AB3_NUMORC
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

      // Pesquisa o Status do Atendimento
      If !Empty(cNumOrc)
         
         If Select("T_STATUS") > 0
            T_STATUS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT AB7_TIPO " 
         cSql += "  FROM " + RetSqlName("AB7010")
         cSql += " WHERE AB7_NUMORC = '" + Alltrim(cNumOrc) + Alltrim(RESULTADO->AB1_FILIAL) + "'"
         cSql += "   AND AB7_FILIAL = '" + Alltrim(RESULTADO->AB1_FILIAL) + "'"
         cSql += "   AND R_E_C_D_E_L_ = ''"             

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

         If T_STATUS->( EOF() )        

            If Select("T_STATUS") > 0
               T_STATUS->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT AB7_TIPO " 
            cSql += "  FROM " + RetSqlName("AB7010")
            cSql += " WHERE AB7_NUMOS  = '" + Alltrim(cNumOrc) + "'"
            cSql += "   AND AB7_FILIAL = '" + Alltrim(RESULTADO->AB1_FILIAL) + "'"
            cSql += "   AND R_E_C_D_E_L_ = ''"             

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

            If T_STATUS->( EOF() )        
               c_Status := "X"            
            Else
               c_Status := T_STATUS->AB7_TIPO            
            Endif
         Else
            c_Status := T_STATUS->AB7_TIPO
         Endif
            
      Else
         
         c_Status := "X"
            
      Endif
         
      If _Posicao <> "0"

         If c_Status <> _Posicao
            RESULTADO->( DbSkip() )
            Loop
         Endif
                        
      Endif

      // Pesquisa as notas fiscais dos pedidos ggerados
      If Select("T_NOTA") > 0
         T_NOTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT C6_NOTA "
      cSql += "  FROM " + RetSqlName("SC6010")
      cSql += " WHERE C6_NUMORC    = '" + Alltrim(cNumOrc) + Alltrim(RESULTADO->AB1_FILIAL) + "'"
      cSql += "   AND R_E_C_D_E_L_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

      If T_NOTA->( EOF() )        
         c_Nota := Space(10)
      Else
         c_Nota := T_NOTA->C6_NOTA
      Endif

      // Carrega o Array
      aPesq := {RESULTADO->AB1_FILIAL,; // 01 - Filial
                cCodiTecnico         ,; // 02 - Código do Técnico
                cNomeTecnico         ,; // 03 - Nome do Técnico
                RESULTADO->AB1_EMISSA,; // 04 - Data de Emissão
                RESULTADO->AB1_ETIQUE,; // 05 - Código da Etiqueta
                RESULTADO->AB1_CODCLI,; // 06 - Código o Cliente
                RESULTADO->AB1_LOJA  ,; // 07 - Código da Loja
                RESULTADO->A1_NOME   ,; // 08 - Nome do Cliente
                cSituacao            ,; // 09 - Situtação do Chamado
                Alltrim(RESULTADO->B1_DESC) + " " + Alltrim(RESULTADO->B1_DAUX),; // 10 - Descrição do Produto
                RESULTADO->AB2_NUMSER,; // 11 - Nº de Série
                nProdutos            ,; // 12 - Valor dos Produtos
                nServicos            ,; // 13 - Valor dos Serviços
                nTotal               ,; // 14 - Total do Chamado Técnico
                c_Status             ,; // 15 - Status
                c_Nota}                 // 16 - Nº da Nota Fiscal de Faturamento
       
      aAdd( aPesquisa, aPesq )

      RESULTADO->( DbSkip() )
      
   Enddo
      
   // Ordena o Array para Impressão
   ASORT(aPesquisa,,,{ | x,y | x[1] + x[2] < y[1] + y[2] } )

   // Imprime o relatório analítico
   nPagina  := 0

   nTotProI := 0
   nTotSerI := 0
   nTotTotI := 0

   nTotProF := 0
   nTotSerF := 0
   nTotTotF := 0

   nTotProG := 0
   nTotSerG := 0
   nTotTotG := 0

   If Len(aPesquisa) == 0
      If Select("RESULTADO") > 0
         RESULTADO->( dbCloseArea() )
      EndIf
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   xFilial  := aPesquisa[01,01]
   xTecnico := aPesquisa[01,02]

   For nContar = 1 to Len(aPesquisa)
   
      If Alltrim(aPesquisa[nContar,1]) == Alltrim(xFilial)

         If Alltrim(aPesquisa[nContar,2]) == Alltrim(xTecnico)

            // Se Faturado = 2, despreza os não faturados
            If _Faturado == "2"
               If Empty(Alltrim(Upper(aPesquisa[nContar,16])))
                  Loop
               Endif
            Else
               If !Empty(Alltrim(Upper(aPesquisa[nContar,16])))
                  Loop
               Endif
            Endif

            // Impressao do cabecalho do relatorio
            If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
               nPagina := nPagina + 1
               nLin    := 1
               @ nLin,001 PSAY "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
               @ nLin,084 PSAY "RELAÇÃO DE CHAMADOS TÉCNICOS"
               @ nLin,180 PSAY dtoc(DATE()) + " - " + TIME()
               nLin := nLin + 1
               @ nLin,001 PSAY "AUTOMR12.PRW"
               @ nLin,084 PSAY "PERÍODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02)
               @ nLin,180 PSAY "PÁGINA:"
               @ nLin,195 PSAY Strzero(nPagina,6)
               nLin = nLin + 1
               @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               nLin := nLin + 1
               @ nLin,001 PSAY "   DATA    ETIQUETA NOME DO CLIENTE                          STATUS         NF     DESCRIÇÃO DO PRODUTO                                 NR. DE SÉRIE             VLR PROD.       VLR SER.          TOTAL"
               nLin := nLin + 1                     
               @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               nLin := nLin + 2

               Do Case
                  Case aPesquisa[nContar,01] == "01"
                       @ nLin,077 PSAY "FILIAL.: 01 - PORTO ALEGRE"
                  Case aPesquisa[nContar,01] == "02"
                       @ nLin,077 PSAY "FILIAL.: 02 - CAXIAS DO SUL"
                  Case aPesquisa[nContar,01] == "03"
                       @ nLin,077 PSAY "FILIAL.: 03 - PELOTAS"
               EndCase                       

               nLin = nLin + 2
               @ nLin,077 PSAY "TÉCNICO: " + Alltrim(aPesquisa[nContar,2]) + " - " + Alltrim(aPesquisa[nContar,3])
               nLin = nLin + 2

            Endif

            // Impressão dos dados
            @ nLin,001 PSAY Substr(aPesquisa[nContar,04],07,02) + "/" + Substr(aPesquisa[nContar,04],05,02) + "/" + Substr(aPesquisa[nContar,04],01,04)
            @ nLin,012 PSAY aPesquisa[nContar,05]
            @ nLin,021 PSAY aPesquisa[nContar,08]

            // Status
            Do Case
               Case aPesquisa[nContar,15] == "1"
                    @ nLin,062 PSAY "O.S."
               Case aPesquisa[nContar,15] == "2"
                    @ nLin,062 PSAY "PV GERADO"
               Case aPesquisa[nContar,15] == "3"
                    @ nLin,062 PSAY "EM ATENDIMENTO"
               Case aPesquisa[nContar,15] == "4"
                    @ nLin,062 PSAY "ATENDIDO"    
               Case aPesquisa[nContar,15] == "5"
                    @ nLin,062 PSAY "ENCERRADO"
               Case aPesquisa[nContar,15] == "X"
                    @ nLin,062 PSAY "EM ORÇAMENTO"                    
            EndCase

            @ nLin,077 PSAY Substr(aPesquisa[nContar,16],01,06)
            @ nLin,084 PSAY Substr(aPesquisa[nContar,10],01,52)
            @ nLin,137 PSAY aPesquisa[nContar,11]
            @ nLin,159 PSAY aPesquisa[nContar,12] PICTURE "@E 9,999,999.99
            @ nLin,174 PSAY aPesquisa[nContar,13] PICTURE "@E 9,999,999.99"
            @ nLin,189 PSAY aPesquisa[nContar,14] PICTURE "@E 9,999,999.99"

            nTotProI := nTotProI + aPesquisa[nContar,12]
            nTotSerI := nTotSerI + aPesquisa[nContar,13]
            nTotTotI := nTotTotI + aPesquisa[nContar,14]

            nTotProF := nTotProF + aPesquisa[nContar,12]
            nTotSerF := nTotSerF + aPesquisa[nContar,13]
            nTotTotF := nTotTotF + aPesquisa[nContar,14]

            nTotProG := nTotProG + aPesquisa[nContar,12]
            nTotSerG := nTotSerG + aPesquisa[nContar,13]
            nTotTotG := nTotTotG + aPesquisa[nContar,14]

            nLin = nLin + 1
            
            Loop
            
         Else

            nLin = nLin + 1
                                                                                                       
            // Totaliza o Técnico
            @ nLin,137 PSAY "TOTAL DO TÉCNICO:"
            @ nLin,159 PSAY nTotProI picture "@E 9,999,999.99"
            @ nLin,174 PSAY nTotSerI picture "@E 9,999,999.99"
            @ nLin,189 PSAY nTotTotI picture "@E 9,999,999.99"
            
            nTotProI := 0
            nTotSerI := 0
            nTotTotI := 0

            xTecnico := aPesquisa[nContar,2]

            nLin = nLin + 2
            
            @ nLin,073 PSAY "TÉCNICO: " + Alltrim(aPesquisa[nContar,2]) + " - " + Alltrim(aPesquisa[nContar,3])

            nLin = nLin + 2

            nContar := nContar - 1

         Endif
         
      Else            
      
         nLin = nLin + 1

         // Totaliza o Técnico
         @ nLin,137 PSAY "TOTAL DO TÉCNICO:"
         @ nLin,159 PSAY nTotProI picture "@E 9,999,999.99"
         @ nLin,174 PSAY nTotSerI picture "@E 9,999,999.99"
         @ nLin,189 PSAY nTotTotI picture "@E 9,999,999.99"
            
         nLin = nLin + 1

         // Totaliza a Filial
         @ nLin,137 PSAY "TOTAL DA FILIAL.:"
         @ nLin,159 PSAY nTotProF picture "@E 9,999,999.99"
         @ nLin,174 PSAY nTotSerF picture "@E 9,999,999.99"
         @ nLin,189 PSAY nTotTotF picture "@E 9,999,999.99"
         
         nLin = nLin + 2         

         nTotProI := 0
         nTotSerI := 0
         nTotTotI := 0

         nTotProF := 0
         nTotSerF := 0
         nTotTotF := 0

         xFilial  := aPesquisa[nContar,1]
         xTecnico := aPesquisa[nContar,2]

         nContar := nContar - 1

      Endif

   Next nContar

   nLin = nLin + 1

   // Totaliza o último Técnico
   @ nLin,137 PSAY "TOTAL DO TÉCNICO:"
   @ nLin,159 PSAY nTotProI picture "@E 9,999,999.99"
   @ nLin,174 PSAY nTotSerI picture "@E 9,999,999.99"
   @ nLin,189 PSAY nTotTotI picture "@E 9,999,999.99"
            
   nLin = nLin + 2

   // Totaliza a última Filial
   @ nLin,137 PSAY "TOTAL DA FILIAL.:"
   @ nLin,159 PSAY nTotProF picture "@E 9,999,999.99"
   @ nLin,174 PSAY nTotSerF picture "@E 9,999,999.99"
   @ nLin,189 PSAY nTotTotF picture "@E 9,999,999.99"

   nLin = nLin + 2

   // Totalizador Geral
   @ nLin,137 PSAY "TOTAL GERAL.....:"
   @ nLin,159 PSAY nTotProG picture "@E 9,999,999.99"
   @ nLin,174 PSAY nTotSerG picture "@E 9,999,999.99"
   @ nLin,189 PSAY nTotTotG picture "@E 9,999,999.99"

   // Finaliza a execucao do relatorio
   SET DEVICE TO SCREEN

   // Se impressao em disco, chama o gerenciador de impressao

   If aReturn[5]==1
      dbCommitAll()
      SET PRINTER TO
      OurSpool(wnrel)
   Endif

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.

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