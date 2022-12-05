#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR05.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/07/2011                                                          *
// Objetivo..: Impressão Ordem de Produção.         	                           *
// ------------------------------------------------------------------------------- *
// Alterações: 04/11/2011 - Impressão da descrição auxiliar (B1_DAUX)              *
//**********************************************************************************

User Function AUTOMR05()

   Local lChumba        := .F.

   Private cCliente	    := Space(06)
   Private cLoja	    := Space(03)
   Private cNomeCli	    := Space(60)
   Private cProduto	    := Space(20)
   Private cNomePro	    := Space(60)
   Private cProducao    := Space(06)
   Private cPedido	    := Space(06)
   Private cAtendimento := Space(06)
   Private cMemo1	    := ""
   Private cMemo2	    := ""
   Private lCal	        := .F.
   Private lCRM	        := .F.

   Private oCheckBox1
   Private oCheckBox2
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oMemo1
   Private oMemo2

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Impressão Ordem de Produção" FROM C(178),C(181) TO C(493),C(605) PIXEL

   @ C(005),C(005) Jpeg FILE "logoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(205),C(001) PIXEL OF oDlg
   @ C(133),C(002) GET oMemo2 Var cMemo2 MEMO Size C(205),C(001) PIXEL OF oDlg

   @ C(041),C(005) Say "Pesquisar em"          Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(064),C(005) Say "Cliente"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(086),C(005) Say "Produto"               Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(107),C(005) Say "Nº Ord.Produção"       Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(107),C(079) Say "Nº Ped.Venda"          Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(107),C(153) Say "Nº Atend./P.Comercial" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      
   @ C(051),C(005) CheckBox oCheckBox1 Var lCal Prompt "Call Center" Size C(037),C(008) PIXEL OF oDlg
   @ C(051),C(054) CheckBox oCheckBox2 Var lCRM Prompt "C R M" Size C(026),C(008) PIXEL OF oDlg

   @ C(074),C(005) MsGet oGet1 Var cCliente     Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(074),C(040) MsGet oGet2 Var cLoja        Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TrazNomeCliente(cCliente, cLoja) )
   @ C(074),C(063) MsGet oGet3 Var cNomeCli     Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(094),C(005) MsGet oGet4 Var cProduto     Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( TrazNomeProd(cProduto) )
   @ C(094),C(040) MsGet oGet5 Var cNomePro     Size C(166),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(117),C(005) MsGet oGet6 Var cProducao    Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(117),C(079) MsGet oGet7 Var cPedido      Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(117),C(153) MsGet oGet8 Var cAtendimento Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(140),C(066) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( ImpProducao( cCliente, cLoja, cProduto, cProducao, cPedido, cAtendimento, lCal, lCRM ))
   @ C(140),C(105) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )
 
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que trás a descrição do produto selecionado
Static Function TrazNomeProd( cProduto )

   Local cSql := ""
   
   If Empty(cProduto)
      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf
      cNomePro := ""
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
       cNomePro := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
    Else
       cNomePro := ""
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
      cNomeCli := ""
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
      cNomeCli := Alltrim(T_CLIENTE->A1_NOME)
   Else
      cCliente := Space(06)
      cLoja    := Space(06)
      cNomeCli := ""
   Endif
          
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

Return .T.

Static Function ImpProducao( cCliente, cLoja, cProduto, cProducao, cPedido, cAtendimento, _Call, _Crm )

   Local OLIST
   Local oOk      := LoadBitmap( GetResources(), "LBOK" )
   Local oNo      := LoadBitmap( GetResources(), "LBNO" )
   LOCAL aLista   := {}
   local aPergs   := {}

   Private cSql   := ""
   Private nLista := 0

   If _Call == .F. .And. _Crm == .F.
      MsgAlert("Necessário informar Pesquisar em")
      Return(.T.)
   Endif
      
   If _Call == .T. .And. _Crm == .T.
      MsgAlert("Indique somente Call Center ou CRM para pesquisar em")
      Return(.T.)
   Endif

   // Pesquisa as Ordens de Produção conforme filtro informado     
   cSql := ""
   cSql := "SELECT A.C2_FILIAL , " + chr(13)
   cSql += "       A.C2_NUM    , " + chr(13)
   cSql += "       A.C2_ITEM   , " + chr(13)
   cSql += "       A.C2_PRODUTO, " + chr(13)
   cSql += "       A.C2_LOCAL  , " + chr(13)
   cSql += "       A.C2_QUANT  , " + chr(13)
   cSql += "       A.C2_UM     , " + chr(13)
   cSql += "       A.C2_DATPRI , " + chr(13)
   cSql += "       A.C2_DATPRF , " + chr(13)
   cSql += "       A.C2_EMISSAO, " + chr(13)
   cSql += "       A.C2_CC     , " + chr(13)
   cSql += "       A.C2_STATUS , " + chr(13)
   cSql += "       A.C2_SEQUEN , " + chr(13)
   cSql += "       A.C2_OBSI   , " + chr(13)
   cSql += "       A.C2_PEDIDO , " + chr(13)
   cSql += "       B.B1_DESC   , " + chr(13)
   cSql += "       B.B1_DAUX   , " + chr(13)
   cSql += "       C.C5_CLIENTE, " + chr(13)
   cSql += "       C.C5_LOJACLI, " + chr(13)
   cSql += "       C.C5_VEND1  , " + chr(13)
   cSql += "       D.A1_NOME   , " + chr(13)
   cSql += "       D.A1_CGC    , " + chr(13)
   cSql += "       D.A1_MUN    , " + chr(13)
   cSql += "       D.A1_EST      " + chr(13)
   cSql += "  FROM " + RetSqlName("SC2010") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1010") + " B, " + chr(13)
   cSql += "       " + RetSqlName("SC5010") + " C, " + chr(13)
   cSql += "       " + RetSqlName("SA1010") + " D  " + chr(13)
   cSql += " WHERE A.C2_PRODUTO   = B.B1_COD  " + chr(13)
   cSql += "   AND A.C2_FILIAL    = '" + Alltrim(cFilAnt ) + "'" + chr(13)
   cSql += "   AND A.R_E_C_D_E_L_ = 0         " + chr(13)
// cSql += "   AND C.C5_NUM       = A.C2_NUM  " + chr(13)
   cSql += "   AND C.C5_NUM       = A.C2_PEDIDO" + chr(13)
   cSql += "   AND C.C5_FILIAL    = A.C2_FILIAL" + chr(13)
   cSql += "   AND C.C5_CLIENTE   = D.A1_COD  " + chr(13)
   cSql += "   AND C.C5_LOJACLI   = D.A1_LOJA " + chr(13)
   cSql += "   AND A.C2_STATUS    = ''        " + chr(13)

   // Filtra pela Ordem de Produção
   If !Empty(cProducao)
      cSql += "  AND A.C2_NUM = '" + Alltrim(cProducao) + "'" + chr(13)
   Endif
   
   // Filtra pelo Pedido
   If !Empty(cPedido)
      cSql += " AND A.C2_PEDIDO = '" + Alltrim(cPedido) + "'" + chr(13)
   Endif

   // Filtra pelo Produto
   If !Empty(cProduto)
      cSql += " AND A.C2_PRODUTO = '" + Alltrim(cProduto) + "'" + chr(13)
   Endif   

   // Filtra pelo Cliente
   If !Empty(cCliente)
      cSql += " AND C.C5_CLIENTE = '" + Alltrim(cCliente) + "' AND C.C5_LOJACLI = '" + Alltrim(cLoja) + "'"  + chr(13)
   Endif

   cSql += " ORDER BY D.A1_NOME, A.C2_NUM " + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )
   
   // Carrega o Array aLista
   DbSelectArea("T_PRODUCAO") 	                  
   T_PRODUCAO->( DbGoTop() )
   
   While T_PRODUCAO->(!EOF())

      // Pesquisa o Nº do Atendimento
      If Select("T_ATENDIMENTO") > 0
         T_ATENDIMENTO->( dbCloseArea() )
      EndIf

      If lCal == .T.
         cSql := ""
         cSql := "SELECT UA_NUM   AS ATENDIMENTO, "
         cSql += "       UA_QEXAT AS EXATA        "
         cSql += "  FROM " + RetSqlName("SUA010")
         cSql += " WHERE UA_NUMSC5 = '" + Alltrim(T_PRODUCAO->C2_PEDIDO) + "'"
         cSql += "   AND UA_FILIAL = '" + Alltrim(cFilAnt) + "'"
      Else
         cSql := ""
         cSql := "SELECT A.C6_FILIAL ,"
         cSql += "       A.C6_NUM    ,"
         cSql += "       A.C6_NUMOP  ,"
         cSql += "       A.C6_NUMORC ,"
         cSql += "       B.CJ_NUM    ,"
         cSql += "       B.CJ_NROPOR ," 
         cSql += "       B.CJ_PROPOST AS ATENDIMENTO,"
         cSql += "       C.ADY_QEXAT  AS EXATA       "
         cSql += "  FROM " + RetSqlName("SC6") + " A,"
         cSql += "       " + RetSqlName("SCJ") + " B,"
         cSql += "       " + RetSqlName("ADY") + " C "
         cSql += " WHERE A.C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
         cSql += "   AND A.C6_NUM     = '" + Alltrim(T_PRODUCAO->C2_PEDIDO) + "'"
         cSql += "   AND A.D_E_L_E_T_ = ''"
         cSql += "   AND B.CJ_NUM     = SUBSTRING(A.C6_NUMORC,01,06)"
         cSql += "   AND C.ADY_FILIAL = B.CJ_FILIAL"
         cSql += "   AND C.ADY_PROPOS = B.CJ_PROPOST"      
      Endif

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATENDIMENTO", .T., .T. )

      xExata := "N"

      If !T_ATENDIMENTO->( EOF() )
         xAtendimento := T_ATENDIMENTO->ATENDIMENTO
         xExata       := T_ATENDIMENTO->EXATA
         T_ATENDIMENTO->( dbCloseArea() )
      Else
         // Pesquisa o Nº da Oportunidade
         If Select("T_ATENDIMENTO") > 0
            T_ATENDIMENTO->( dbCloseArea() )
         EndIf
         
         cSql := ""
         cSql := "SELECT A.C6_NUMOP  , "
         cSql += "       A.C6_NUM    , "
         cSql += "       B.CK_PROPOST, "
         cSql += "       C.AD1_NROPOR  "
         cSql += "  FROM " + RetSqlName("SC6010") + " A, "
         cSql += "       " + RetSqlName("SCK010") + " B, "
         cSql += "       " + RetSqlName("AD1010") + " C  "
         cSql += " WHERE A.C6_NUMOP   = '" + Alltrim(T_PRODUCAO->C2_NUM) + "'"
         cSql += "   AND B.CK_NUMPV   = A.C6_NUM     "
         cSql += "   AND A.C6_FILIAL  = '" + Alltrim(cFilAnt) + "'" 
         cSql += "   AND C.AD1_PROPOS = B.CK_PROPOST "        
         
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATENDIMENTO", .T., .T. )
         
         xAtendimento := If(!T_ATENDIMENTO->(EOF()), T_ATENDIMENTO->AD1_NROPOR  , "")         

         T_ATENDIMENTO->( dbCloseArea() )

      Endif

      // Valida pelo nº do Atendimento
      If !Empty(cAtendimento)
         If Alltrim(cAtendimento) <> Alltrim(xAtendimento)
            T_PRODUCAO->( DbSkip() )
            Loop
         Endif
      Endif

      // Carrega o nº do Pedido de Venda
      xPedidoPv    := T_PRODUCAO->C2_PEDIDO

      // Carrega o Nº da Ordem de Produção
      xProducao    := T_PRODUCAO->C2_NUM

      // Carrega os dados do Cliente
      xCnpj      := T_PRODUCAO->A1_CGC
      xCliente   := T_PRODUCAO->A1_NOME
      xMunicipio := T_PRODUCAO->A1_MUN
      xEstado    := T_PRODUCAO->A1_EST

      // Carrega a Qauntidade solicitada no Pedido de Venda
      xQuantidade  := T_PRODUCAO->C2_QUANT

      // Carre o código e a descrição do produto
      xProduto     := T_PRODUCAO->C2_PRODUTO
      xNomeProduto := Alltrim(T_PRODUCAO->B1_DESC) + " " + Alltrim(T_PRODUCAO->B1_DAUX)

      // Pesquisa a Nota Fiscal e data de Faturamento do Pedido de Venda
      If Select("T_NOTA") > 0
         T_NOTA->( dbCloseArea() )
      EndIf
  
      cSql := ""
      cSql := "SELECT C6_NOTA  , "
      cSql += "       C6_DATFAT  "
      cSql += "  FROM " + RetSqlName("SC6010")
      cSql += " WHERE C6_NUMOP = '" + Alltrim(T_PRODUCAO->C2_NUM) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

      xNotaFiscal := If(!T_NOTA->(EOF()), T_NOTA->C6_NOTA  , "")
      xDataFatu   := If(!T_NOTA->(EOF()), T_NOTA->C6_DATFAT, "")

      T_NOTA->( dbCloseArea() )

      // Pesquisa a Transportadora do Pedido de Venda
      If Select("T_FRETE") > 0
         T_FRETE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.C6_NUM   , "
      cSql += "       A.C6_NUMOP , "
      cSql += "       B.C5_TRANSP, "
      cSql += "       C.A4_NOME    "
      cSql += "  FROM " + RetSqlName("SC6010") + " A, " 
      cSql += "       " + RetSqlName("SC5010") + " B, "
      cSql += "       " + RetSqlName("SA4010") + " C  "  
      cSql += " WHERE A.C6_NUM    = '" + Alltrim(T_PRODUCAO->C2_PEDIDO) + "'"
      cSql += "   AND A.C6_FILIAL = '" + Alltrim(T_PRODUCAO->C2_FILIAL) + "'"
      cSql += "   AND A.C6_NUM    = B.C5_NUM "
      cSql += "   AND B.C5_FILIAL = '" + Alltrim(T_PRODUCAO->C2_FILIAL) + "'"
      cSql += "   AND B.C5_TRANSP = C.A4_COD " 

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FRETE", .T., .T. )

      xTransp     := If(!T_FRETE->( EOF()), T_FRETE->C5_TRANSP, "")
      xNomeTransp := If(!T_FRETE->( EOF()), T_FRETE->A4_NOME  , "")

      T_FRETE->( dbCloseArea() )         
         
      // Pesquisa o Nome do vendedor
      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_COD , "
      cSql += "       A3_NOME  "
      cSql += "  FROM " + RetSqlName("SA3010") 
      cSql += " WHERE A3_COD = '" + Alltrim(T_PRODUCAO->C5_VEND1) + "'"
  
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

      xCodVend  := If(!T_VENDEDOR->( EOF()), T_VENDEDOR->A3_COD , "")
      xVendedor := If(!T_VENDEDOR->( EOF()), T_VENDEDOR->A3_NOME, "")

      T_VENDEDOR->( dbCloseArea() )
 
      // Pesquisa a quantidade do pedido de venda
      If Select("T_QUANTIDADE") > 0
         T_QUANTIDADE->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT C6_QTDVEN " 
      cSql += "  FROM " + RetSqlName("SC6010") 
      cSql += " WHERE C6_NUMOP   = '" + Alltrim(T_PRODUCAO->C2_NUM)     + "'"
      cSql += "   AND C6_FILIAL  = '" + Alltrim(T_PRODUCAO->C2_FILIAL)  + "'"
      cSql += "   AND C6_PRODUTO = '" + Alltrim(T_PRODUCAO->C2_PRODUTO) + "'"
      cSql += "   AND C6_ITEM    = '" + Alltrim(T_PRODUCAO->C2_ITEM)    + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QUANTIDADE", .T., .T. )

      xQtdPedido := If(!T_QUANTIDADE->( EOF()), T_QUANTIDADE->C6_QTDVEN , "")

      T_QUANTIDADE->( dbCloseArea() )

      // Pesquisa os componentes do produto a ser produzido
      If Select("T_COMPO") > 0
         T_COMPO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.G1_FILIAL, "
      cSql += "       A.G1_COD   , "
      cSql += "       A.G1_COMP  , "
      cSql += "       A.G1_QUANT , "
      cSql += "       B.B1_DESC  , "
      cSql += "       B.B1_DAUX    "
      cSql += "  FROM " + RetSqlName("SG1010") + " A, "
      cSql += "       " + RetSqlName("SB1010") + " B  " 
      cSql += " WHERE A.G1_COD    = '" + Alltrim(T_PRODUCAO->C2_PRODUTO) + "'"
//    cSql += "   AND A.G1_FILIAL = '" + Alltrim(T_PRODUCAO->C2_FILIAL)  + "'"
      cSql += "   AND A.G1_COMP   = B.B1_COD "
    
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPO", .T., .T. )

      xProFicha := If(!T_COMPO->( EOF()), T_COMPO->G1_COMP, "")
      xNomFicha := If(!T_COMPO->( EOF()), Alltrim(T_COMPO->B1_DESC) + " " + Alltrim(T_COMPO->B1_DAUX), "")
      xQtdFicha := If(!T_COMPO->( EOF()), (T_PRODUCAO->C2_QUANT * T_COMPO->G1_QUANT), 0)
      
      T_COMPO->( dbCloseArea() )      

      // Prepara o documento do cliente
      If Len(Alltrim(xCnpj)) == 14
         xCnpj := Substr(xCnpj,01,02) + "." + Substr(xCnpj,03,03) + "." + Substr(xCnpj,06,03) + "/" + Substr(xCnpj,09,04) + "-" + Substr(xCnpj,13,02)
      Else
         xCnpj := Substr(xCnpj,01,03) + "." + Substr(xCnpj,04,03) + "." + Substr(xCnpj,07,03) + "-" + Substr(xCnpj,10,02)
      Endif

      // Carrega o Array aLista com o conteúdo da pesquisa
      AADD(aLista, {.F.                   ,; // 01 - Marcação
                    xAtendimento          ,; // 02 - Nº do Atendimento Call Center/Oportunidade
                    xPedidoPV             ,; // 03 - Nº do Pedido de Venda
                    xProducao             ,; // 04 - Nº da Ordem de Produção
                    xCnpj	              ,; // 05 - CNPJ/CPF do Cliente
                    xCliente              ,; // 06 - Nome do Cliente
                    xQuantidade           ,; // 07 - Quantidade da Ordem de Produção
                    xProduto              ,; // 08 - Código do Produto a ser produzido
                    xNomeProduto          ,; // 09 - Nome do Produto
                    xNotaFiscal           ,; // 10 - Nº da Nota Fiscal
                    xDataFatu             ,; // 11 - Data do Faturamento
                    xTransp               ,; // 12 - Código da Transportadora
                    xNomeTransp           ,; // 13 - Nome da Transportadora
                    xMunicipio            ,; // 14 - Nome da Cidade do Cliente
                    xEstado               ,; // 15 - Estado da Cidade do Cliente
                    xCodVend              ,; // 16 - Código do Vendedor
                    xVendedor             ,; // 17 - Nome do Vendedor
                    T_PRODUCAO->C2_DATPRI ,; // 18 - Data Inicial de Entrega
                    T_PRODUCAO->C2_DATPRF ,; // 19 - Data Final de Entrega
                    T_PRODUCAO->C2_EMISSAO,; // 20 - Data de Emissão da Ordem de Produção
                    xQtdPedido            ,; // 21 - Quantidade do Pedido de Venda
                    xProFicha             ,; // 22 - Código do Produto da Ficha Técnica 
                    xNomFicha             ,; // 23 - Nome do Produto da Ficha Técnica
                    xQtdFicha             ,; // 24 - Quantidade a ser utilizada na produção
                    T_PRODUCAO->C5_CLIENTE,; // 25 - Código do Cliente
                    T_PRODUCAO->C5_LOJACLI,; // 26 - Loja do Cliente
                    xExata                }) // 27 - Indica Quantidade Exata a ser entregue do pedido
                         
       T_PRODUCAO->( DbSkip() )
       
   Enddo                            

   // Verifica se o Array está carregado
   If Len(aLista) == 0
      MsgAlert("Atenção !!" + chr(13) + chr(13) + "Não existem dados a serem visualizados para este filtro.")
	  T_PRODUCAO->(DBCLOSEAREA())
  	  RETURN()
   ENDIF

   // Mostra o resultado
   DEFINE MSDIALOG _oDlg TITLE "Impressão Ordens de Produção" FROM (180),(210) TO (700),(1320) PIXEL

   // Cria Componentes Padroes do Sistema
   @ 10,05 LISTBOX oList FIELDS HEADER "", "Atendimento" ,"Nº Pedido", "Nº O.Produção", "CNPJ/CPF", "Cliente", "Quantidade", "Descrição dos Produtos", "Produto", "NF", "Data Fat.", "Transp.", "Descrição Transportadoras" PIXEL SIZE 550,230 OF _oDlg ;
           ON dblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aLista )
   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
          					   aLista[oList:nAt,02],;
         	        	       aLista[oList:nAt,03],;
         	        	       aLista[oList:nAt,04],;
         	        	       aLista[oList:nAt,05],;
         	        	       aLista[oList:nAt,06],;
         	        	       aLista[oList:nAt,07],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,12],;
         	        	       aLista[oList:nAt,13]}}
         	        	                	        	        
   DEFINE SBUTTON BUTON1 FROM C(190), C(190) TYPE 06 OF _oDlg ENABLE ACTION( I_PRODUCAO(aLista) )
   DEFINE SBUTTON BUTON1 FROM C(190), C(220) TYPE 20 OF _oDlg ENABLE ACTION _oDlg:End()
     
   ACTIVATE MSDIALOG _oDlg CENTERED 

   T_PRODUCAO->(DBCLOSEAREA())

   // Limpa as variáveis de filtro
   cCliente      := Space(06)
   cLoja         := Space(03)
   cProduto      := Space(30)
   cProducao     := Space(06)
   cPedido       := Space(06)  
   cAtendimento  := Space(06)  
   cNomeCliente  := Space(60)
   cNomeProduto  := Space(60)

   nGet1	     := Space(06)
   nGet2	     := Space(03)
   nGet3         := Space(30)
   nGet4         := Space(06)
   nGet5         := Space(06)
   nGet6         := Space(06)

Return .T.

// Funcção que gera a impressão do Chamado Técnico / Ordem de Serviço
Static Function I_PRODUCAO(aLista)

	Local cQuery       := ""
	Local aStru        := {}
	Local _cPedAtu     := ""
	Local _lPrimeiro   := .T.
    Local cSql         := ""
    Local nContador    := 0
    Local xLinhas      := 0
    Local cTexto1 	   := ""
    Local cTexto2      := ""
    Local dData        := ""
    Local cComentario  := ""
    Local nProdutos    := 0
    Local nServicos    := 0
    Local cCondicao    := ""
    Local nFonte       := 0
    Local lExiste      := .F.
    Local cCodigos     := ""
    Local cNomeTransp  := ""
    Local cAtendimento := ""
    Local nAdicional   := 15
    Local cEntresi     := ""
    Local _nLin        := 0

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
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont30

    // Verifica se houve a marcação de pelo menos um aordem de produção para impressão
    lExiste  := .F.    
    cCodigos := ""
    cEntresi := ""
    For nContar = 1 to Len(aLista)
        If aLista[nContar,1] == .T.
           If !Empty(cEntresi)
              If cEntresi <> Alltrim(aLista[nContar,3])
                 MsgAlert("Atenção !!" + chr(13) + chr(13) + "Indique somente uma Ordem de Produção para Impressão de cada vez.")
                 Return .T.
              Endif
           Endif   
           lExiste  := .T.
           cCodigos := cCodigos + "'" + Alltrim(aLista[nContar,3]) + "',"
           cEntresi := Alltrim(aLista[nContar,3])
        Endif
    Next nContar       

    If lExiste == .F.
       MsgAlert("Atenção !!" + chr(13) + chr(13) + "Não foi indicada nenhuma Ordem de Produção para impressão." + chr(13) + chr(13) + "Verifique !")
       Return .T.
    Endif

    // Elimina a última vírgula da string de nº das ordens de produção
    cCodigos := Substr(cCodigos,1,Len(Alltrim(cCodigos))-1)

    // Posiciona na primeira Ordem de Produtos para capturar os dados a serem impressos
    For nContar = 1 to Len(aLista)
        If aLista[nContar,1] == .T.
           Exit
        Endif
    Next nContar    

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
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,8,,.t.,,,,.f.,.f. )   

	// Pesquisa o nome da Empresa/Filial para o cabecalho
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )

    cAtendimento := aLista[nContar,2]
   
    _nLin := 60

    // Início do relatório
    oPrint:StartPage()
	
    oPrint:Line( _nLin, 0100, _nLin, 2370 )   
    _nLin += 30

    // Logotipo e identificação do pedido
    oPrint:SayBitmap( _nLin, 0150, "logoautoma.bmp", 0700, 0200 )
    _nLin += 90
    
    oPrint:Say( _nLin, 1500, "ORDEM DE PRODUÇÃO Nº", oFont10  )
    oPrint:Say( _nLin, 2100, aLista[nContar,4], oFont16b )

    _nLin += 120
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin += 20    

    dbSelectArea("SM0")
    SM0->( DbSeek( cEmpAnt + cFilAnt ) )
	
    // Imprime os Dados do Cliente
    oPrint:Say( _nLin, 0110, "Cliente:" , oFont10)
    oPrint:Say( _nLin, 1500, "Cidade:"  , oFont10)

    oPrint:Say( _nLin, 0370, "[" + Alltrim(aLista[nContar,25]) + "." + Alltrim(aLista[nContar,26]) + "] - "+ Alltrim(aLista[nContar,6]), oFont10b)
    oPrint:Say( _nLin, 1780, Alltrim(aLista[nContar,14]) + " / " + Alltrim(aLista[nContar,15]), oFont10b)

    _nLin += 80
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin += 20

    // Imprime o Nome do Vendedor
    oPrint:Say( _nLin, 0110, "Vendedor:"  , oFont10)
    oPrint:Say( _nLin, 0370, "["+ Alltrim(aLista[nContar,16]) + "] - " + Alltrim(aLista[nContar,17]), oFont10b)
    
    _nLin += 50

    // Imprime os dados da Transportadora
    oPrint:Say( _nLin, 0110, "Transportadora:"  , oFont10)
    oPrint:Say( _nLin, 0370, "["+ Alltrim(aLista[nContar,12]) + "] - "+ Alltrim(aLista[nContar,13]), oFont10b)

    _nLin += 80
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin += 20

    oPrint:Say( _nLin, 0110, "Data Emissão:"     , oFont10)
    oPrint:Say( _nLin, 1500, "Nº Atendimento:"   , oFont10)
    oPrint:Say( _nLin, 0370, Substr(aLista[nContar,20],07,02) + "/" + Substr(aLista[nContar,20],05,02) + "/" + Substr(aLista[nContar,20],01,04), oFont10b)
    oPrint:Say( _nLin, 1850, Alltrim(aLista[nContar,02]), oFont10b)

    _nLin += 50
        
    oPrint:Say( _nLin, 0110, "Previsão Inicial:" , oFont10)
    oPrint:Say( _nLin, 1500, "Nº Pedido Venda:"  , oFont10)
    oPrint:Say( _nLin, 0370, Substr(aLista[nContar,18],07,02) + "/" + Substr(aLista[nContar,18],05,02) + "/" + Substr(aLista[nContar,18],01,04), oFont10b)
    oPrint:Say( _nLin, 1850, Alltrim(aLista[nContar,03]), oFont10b)

    _nLin += 50

    oPrint:Say( _nLin, 0110, "Previsão Final:"    , oFont10)
    oPrint:Say( _nLin, 1500, "Nº Ordem Produção:" , oFont10)
    oPrint:Say( _nLin, 0370, Substr(aLista[nContar,19],07,02) + "/" + Substr(aLista[nContar,19],05,02) + "/" + Substr(aLista[nContar,19],01,04), oFont10b)
    oPrint:Say( _nLin, 1850, Alltrim(aLista[nContar,04]), oFont10b)

    _nLin += 80
    
    // Guarda a posição do Array
    nListIndex := nContar

    // Imprime os produtos da Ordem de Produção
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin += 20
    oPrint:Say(  _nLin, 0950, "P R O D U T O S"  , oFont16b)
    
    If aLista[nContar,27] == "S"
       oPrint:Say(  _nLin, 1750, "QUANTIDADE EXATA"  , oFont16b)
    Endif

    _nLin += 80
    oPrint:Line( _nLin, 0100, _nLin, 2370 )

    cColunas := _nLin

    _nLin += 20

    oPrint:Say( _nLin, 0110, "Código"   , oFont09b)
    oPrint:Say( _nLin, 0400, "Descrição", oFont09b)
    oPrint:Say( _nLin, 1160, "Qtd PV"   , oFont09b)
    oPrint:Say( _nLin, 1310, "Qtd OP"   , oFont09b)
    oPrint:Say( _nLin, 1500, "Cod"      , oFont09b)
    oPrint:Say( _nLin, 1600, "Descrição", oFont09b)
    oPrint:Say( _nLin, 2160, "Qtd"      , oFont09b)
    oPrint:Say( _nLin, 2230, "Und"      , oFont09b)

    _nLin += 80
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin += 50

    For nContar = 1 to Len(aLista)
       
        If aLista[nContar,1] == .F.
           Loop
        Endif
           
        If nAdicional == 0
           Exit
        Endif

        oPrint:Say( _nLin, 0110, Alltrim(aLista[nContar,08])  , oFont30)

        If Len(Alltrim(aLista[nContar,09])) > 40
           oPrint:Say( _nLin, 0400, Substr(Alltrim(aLista[nContar,09]),01,40), oFont30)
        Else
           oPrint:Say( _nLin, 0400, Alltrim(aLista[nContar,09])  , oFont30)
        Endif   

        oPrint:Say( _nLin, 1100, Str(aLista[nContar,21],10,02), oFont30)
        oPrint:Say( _nLin, 1250, Str(aLista[nContar,07],10,02), oFont30)
        oPrint:Say( _nLin, 1450, Alltrim(aLista[nContar,22])  , oFont30)
        oPrint:Say( _nLin, 1600, Substr(Alltrim(aLista[nContar,23]),01,25), oFont30)
        oPrint:Say( _nLin, 2040, Str(aLista[nContar,24],10,02), oFont30)
        oPrint:Say( _nLin, 2250, "M2", oFont30)
       
        _nLin += 50

        If Len(Alltrim(aLista[nContar,09])) > 40
           If Len(Alltrim(aLista[nContar,09])) < 70
              oPrint:Say( _nLin, 0400, Substr(Alltrim(aLista[nContar,09]),41,30), oFont30)
              _nLin += 50
              nAdicional := nAdicional - 1
           Else
              oPrint:Say( _nLin, 0400, Substr(Alltrim(aLista[nContar,09]),41,40), oFont30)
              _nLin += 50
              nAdicional := nAdicional - 1
              oPrint:Say( _nLin, 0400, Substr(Alltrim(aLista[nContar,09]),81), oFont30)              
              _nLin += 50
              nAdicional := nAdicional - 1
           Endif
        Endif   
 
        nAdicional := nAdicional - 1

    Next nContar

    // Adicional Linhas em branco
    If nAdicional <> 0
       For nContar = 1 to nAdicional
           _nLin := _nLin + 50
       Next nContar
    Endif

    // Imprime as Colunas
    oPrint:Line( cColunas, 0395, _nLin, 0395 )   
    oPrint:Line( cColunas, 1145, _nLin, 1145 )   
    oPrint:Line( cColunas, 1285, _nLin, 1285 )   
    oPrint:Line( cColunas, 1435, _nLin, 1435 )       
    oPrint:Line( cColunas, 1595, _nLin, 1595 )       
    oPrint:Line( cColunas, 2050, _nLin, 2050 )       
    oPrint:Line( cColunas, 2225, _nLin, 2225 )       

    // Imprime as observações
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin := _nLin + 20
    oPrint:Say(  _nLin, 0900, "O B S E R V A Ç Õ E S"  , oFont16b)
    _nLin := _nLin + 70
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin := _nLin + 50

    // Pesquisa as Observações internas a serem impressas na Ordem de produção
    If Select("T_NOTA") > 0
       T_NOTA->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A.UA_CODOBS, "
    cSql += "       B.YP_TEXTO   "
    cSql += "  FROM " + RetSqlName("SUA010") + " A, "
    cSql += "       " + RetSqlName("SYP010") + " B  "
    cSql += " WHERE A.UA_NUM    = '" + Alltrim(aLista[nListIndex,2]) + "'"
    cSql += "   AND A.UA_FILIAL = '" + Alltrim(cFilAnt)              + "'"
    cSql += "   AND A.UA_CODOBS = B.YP_CHAVE "
    cSql += "   AND B.YP_FILIAL = ''"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

    T_NOTA->( DbGoTop() )
       
    nAdicional := 10

    If !T_NOTA->( EOF() )

       While T_NOTA->(!EOF())
          If nAdicional == 0
             Exit
          Endif
          oPrint:Say( _nLin, 0400, Strtran(T_NOTA->YP_TEXTO, "\13\10","")  , oFont09)
          T_NOTA->( DbSkip() )
          _nLin := _nLin + 50
          nAdicional := nAdicional - 1 
       Enddo
       
    Endif

    // Adicional Linhas em branco
    If nAdicional <> 0
       For nContar = 1 to nAdicional
           _nLin := _nLin + 50
       Next nContar
    Endif

    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin := _nLin + 20
    oPrint:Say(  _nLin, 0110, "Para Uso Exclusivo da Produção"  , oFont09)
    _nLin := _nLin + 50
    
    // Imprime linhas para observações da Produção
    For nContar = 1 to 10
        oPrint:Line( _nLin, 0100, _nLin, 2370 )
        _nLin := _nLin + 50
    Next nContar

    // Imprime o quadro de Peso/Qtd Caixas e Experdido Por
    oPrint:Line( _nLin, 0100, _nLin, 2370 )
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, "Data                        Hora                 Peso           Qtd CX         Embalado por", oFont16b)
    _nLin := _nLin + 100
    oPrint:Say( _nLin, 0110, "___/___/____         ____:____        ________     ________     ___________________", oFont16b)
    _nLin += 100

    oPrint:Line( _nLin, 0100, _nLin, 2370 )

    oPrint:Line( 060, 0100, _nLin, 0100 )
    oPrint:Line( 060, 2370, _nLin, 2370 )

 	oPrint:Preview()
	
	MS_FLUSH()

    // Limpa a marcação da ordem de produção impressa
    For nContar = 1 to Len(aLista)
        aLista[nContar,1] := .F.
    Next nContar    

    // Limpa as variáveis de filtro
    cCliente      := Space(06)
    cLoja         := Space(03)
    cProduto      := Space(30)
    cProducao     := Space(06)
    cPedido       := Space(06)  
    cAtendimento  := Space(06)  
    cNomeCliente  := Space(60)
    cNomeProduto  := Space(60)

    nGet1	     := Space(06)
    nGet2	     := Space(03)
    nGet3         := Space(30)
    nGet4         := Space(06)
    nGet5         := Space(06)
    nGet6         := Space(06)

Return nil
