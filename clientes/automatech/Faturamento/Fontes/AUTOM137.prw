#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM137.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/10/2012                                                          *
// Objetivo..: Programa do Parametrizador Customizável.                            *
//**********************************************************************************

User Function AUTOM137()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private oDlg

// U_AUTOM628("AUTOM137")
   
   If Alltrim(Upper(cUserName)) <> "ADMINISTRADOR"
      MsgAlert("Atenção !!!!" + Chr(13) + chr(10) + chr(13) + Chr(10) + "Procedimento somente permitido para usuário Administrador.")
      Return .T.
   Endif

   // Desenha atela do parametrizador Automatech
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Customizados" FROM C(178),C(181) TO C(590),C(1143) PIXEL

   @ C(005),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(145),C(040) PIXEL NOBORDER OF oDlg
   @ C(043),C(002) GET oMemo1 Var cMemo1 MEMO Size C(500),C(001) PIXEL OF oDlg

   @ C(046),C(002) Button "Frete"                                Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Frete() )
   @ C(046),C(098) Button "Comissões"                            Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Comissao() )
   @ C(046),C(194) Button "Condição de Pagamento"                Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Condicao() )
   @ C(046),C(290) Button "Medição de Contrato"                  Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Medicao() )
   @ C(046),C(386) Button "Prothelito News"                      Size C(095),C(012) PIXEL OF oDlg ACTION( U_AUTOM340() )
   @ C(060),C(002) Button "E-Mail Reserva de Produtos"           Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Reserva() )
   @ C(060),C(098) Button "S E R A S A - CREDINET"               Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Serasa() )
   @ C(060),C(194) Button "TES de Demonstração"                  Size C(095),C(012) PIXEL OF oDlg ACTION( Par_TES() )
   @ C(060),C(290) Button "Preço de Orçamento Técnico"           Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Preco() )
   @ C(060),C(386) Button "Sale Machine"                         Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Sales() )
   @ C(073),C(002) Button "Pesquisa Customizada de Produtos"     Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Pesquisa() )
   @ C(073),C(098) Button "Produtos em Liquidação"               Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Liquidacao() )
   @ C(073),C(194) Button "E-mail Entrada de Mercadorias"        Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Entrada() )
   @ C(073),C(290) Button "TES Devolução R M A"                  Size C(095),C(012) PIXEL OF oDlg ACTION( Par_RMA() )
   @ C(073),C(386) Button "Transferências / Mov. Interna"        Size C(095),C(012) PIXEL OF oDlg ACTION( Par_TRANSF() )
   @ C(087),C(002) Button "Encerramento Automático RMA"          Size C(095),C(012) PIXEL OF oDlg ACTION( Par_VALRMA() )
   @ C(087),C(098) Button "Consulta Preços Cad. Produtos"        Size C(095),C(012) PIXEL OF oDlg ACTION( Par_LibPreco() )
   @ C(087),C(194) Button "Validação CFOP (PC,PV,CC)"            Size C(095),C(012) PIXEL OF oDlg ACTION( VerCFOPS() )
   @ C(087),C(290) Button "TES de Devolução"                     Size C(095),C(012) PIXEL OF oDlg ACTION( Par_DEV() )
   @ C(087),C(386) Button "Importação de XML"                    Size C(095),C(012) PIXEL OF oDlg ACTION( Imp_XML() )
   @ C(100),C(002) Button "Instrução Boletos Bancários"          Size C(095),C(012) PIXEL OF oDlg ACTION( Par_BOLETO() )
   @ C(100),C(098) Button "C O R R E I O S"                      Size C(095),C(012) PIXEL OF oDlg ACTION( Par_CORREIOS() )
   @ C(100),C(194) Button "E-Mail Recepção Mercadorias"          Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Recepcao() )
   @ C(100),C(290) Button "Atendimento Call Center"              Size C(095),C(012) PIXEL OF oDlg ACTION( Par_CallCenter() )
   @ C(100),C(386) Button "SimFrete"                             Size C(095),C(012) PIXEL OF oDlg ACTION( Par_SimFrete() )
   @ C(114),C(002) Button "Grupos com Acesso ao Kardex"          Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Kardex() )
   @ C(114),C(098) Button "Comissão Call Center"                 Size C(095),C(012) PIXEL OF oDlg ACTION( Par_CCenter() )
   @ C(114),C(194) Button "Relatório de Vendas por Vendedores"   Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Vendedor() )
   @ C(114),C(290) Button "Copia de T E S"                       Size C(095),C(012) PIXEL OF oDlg ACTION( Par_CopiaTes() )
   @ C(114),C(386) Button "Acesso ao SimFrete"                   Size C(095),C(012) PIXEL OF oDlg ACTION( Par_CalSimFrete() )
   @ C(127),C(002) Button "Liberadores Cadastro de Produtos"     Size C(095),C(012) PIXEL OF oDlg ACTION( Par_Liberadores() )
   @ C(127),C(098) Button "Aprovadores de RMA"                   Size C(095),C(012) PIXEL OF oDlg ACTION( Par_AprovaRMA() )
   @ C(127),C(194) Button "Abertura Arquivos Externos"           Size C(095),C(012) PIXEL OF oDlg ACTION( Par_AEXT() )
   @ C(127),C(290) Button "Usuários Autorizados Lanç. RA"        Size C(095),C(012) PIXEL OF oDlg ACTION( Par_RSSCR() )
   @ C(127),C(386) Button "% Custo Produção"                     Size C(095),C(012) PIXEL OF oDlg ACTION( Par_CustoProd() )
   @ C(141),C(002) Button "Campo TES Pedido de Venda"            Size C(095),C(012) PIXEL OF oDlg ACTION( Par_TESVDA() )
   @ C(141),C(098) Button "Naturezas de Serviços"                Size C(095),C(012) PIXEL OF oDlg ACTION( LeiTransp() )
   @ C(141),C(194) Button "Produtos Genéricos"                   Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_Gene() )
   @ C(141),C(290) Button "Contrato de Locação"                  Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_Locacao() )
   @ C(141),C(386) Button "Fabricante Ordem de Serviço"          Size C(095),C(012) PIXEL OF oDlg ACTION( FabricOS() )
   @ C(154),C(002) Button "CTe - Importação de XML"              Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_CTEFRETE() )
   @ C(154),C(098) Button "Arquivos Word"                        Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_ARQWORD() )
   @ C(154),C(194) Button "Loja Virtual"                         Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_SHOP() )
   @ C(154),C(290) Button "Tela de Margem de Produtos"           Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_Margem() )
   @ C(154),C(386) Button "Transferência Mercadorias (Seetores)" Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_Setores() )
   @ C(167),C(002) Button "Liberadores de Margem (Quoting)"      Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_Quoting() )
   @ C(167),C(098) Button "Substituição de Caracteres"           Size C(095),C(012) PIXEL OF oDlg ACTION( Sub_Caracter() )
   @ C(167),C(194) Button "Aprovador Transf./Mercadorias."       Size C(095),C(012) PIXEL OF oDlg ACTION( AprovaMerc() )
   @ C(167),C(290) Button "Configurações Carga BI"               Size C(095),C(012) PIXEL OF oDlg ACTION( CargaBI() )
   @ C(167),C(386) Button "Análise de Crédito (ACESSO)"          Size C(095),C(012) PIXEL OF oDlg ACTION( AnaCredito() )
// @ C(180),C(002) Button "SIGEP - Correios"                     Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_Sigep() )
   @ C(180),C(002) Button "Embalagem/Dimensões de Produtos"      Size C(095),C(012) PIXEL OF oDlg ACTION( Pro_Dimensao() )
   @ C(180),C(098) Button "SERASA - RELATO"                      Size C(095),C(012) PIXEL OF oDlg ACTION( AbreRelato() )
   @ C(180),C(194) Button "Atech Portal"                         Size C(095),C(012) PIXEL OF oDlg ACTION( xAbrePergunta() )
   @ C(180),C(290) Button "Risco Cliente"                        Size C(095),C(012) PIXEL OF oDlg ACTION( AltRiscoCli() )
   @ C(180),C(386) Button "Grupos para Descrição OS"             Size C(095),C(012) PIXEL OF oDlg ACTION( GruposOS() )
   @ C(193),C(002) Button "Proposta Comercial"                   Size C(095),C(012) PIXEL OF oDlg ACTION( PropostaC() )
   @ C(193),C(098) Button "Movimentações Internas"               Size C(095),C(012) PIXEL OF oDlg ACTION( MovInternas() )
   @ C(193),C(194) Button "Garantia Field Service"               Size C(095),C(012) PIXEL OF oDlg ACTION( GarantiaFS() )
   @ C(193),C(290) Button "Consistência Doc. Saída"              Size C(095),C(012) PIXEL OF oDlg ACTION( JanConsiste() )
   @ C(193),C(386) Button "Mais ..."                             Size C(047),C(012) PIXEL OF oDlg ACTION( U_AUTOM642() )
   @ C(193),C(434) Button "Voltar"                               Size C(047),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

// Função que4 abre janela para informação dos parâmetros de valor de Frete
Static Function Par_Frete()

   Local cSql      := ""

   Private cPfre01 := 0
   Private cPfre02 := 0
   Private cPfre03 := 0
   Private cPfre04 := 0
   Private cPfre05 := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlgF

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL," 
   cSql += "       ZZ4_CODI  ,"
   cSql += "       ZZ4_FTOT  ,"
   cSql += "       ZZ4_FNRS  ,"
   cSql += "       ZZ4_FFRS  ,"
   cSql += "       ZZ4_FNNO  ,"
   cSql += "       ZZ4_FRNO   "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cPfre01 := T_PARAMETROS->ZZ4_FTOT
      cPfre02 := T_PARAMETROS->ZZ4_FNRS
      cPfre03 := T_PARAMETROS->ZZ4_FFRS
      cPfre04 := T_PARAMETROS->ZZ4_FNNO
      cPfre05 := T_PARAMETROS->ZZ4_FRNO
   Endif

   DEFINE MSDIALOG oDlgF TITLE "Parametros de Cobrança de Frete" FROM C(178),C(181) TO C(383),C(838) PIXEL

   @ C(005),C(005) Say "Permitir Frete CIF para Proposta Comercial/Pedido de Venda acima de  R$"                                            Size C(188),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(021),C(005) Say "Se Frete = CIF e cidade do Cliente = Porto Alegre/RS, valor do frete deve ser maior ou igual a R$"                  Size C(233),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(037),C(005) Say "Se Frete = CIF e cidade do Cliente diferente de Porto Alegre/RS, valor do frete deve ser maior ou igual a R$"       Size C(256),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(052),C(005) Say "Se Frete = CIF e Cliente fora do RS e que não pertença a região Norte, valor do frete deve ser maior ou igual a R$" Size C(270),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(067),C(005) Say "Se Frete = CIF e Cliente pertença a região Norte, valor do frete deve ser maior ou igual a R$"                      Size C(219),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
      
   @ C(004),C(280) MsGet oGet1 Var cPfre01 Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlgF
   @ C(020),C(280) MsGet oGet2 Var cPfre02 Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlgF
   @ C(035),C(280) MsGet oGet3 Var cPfre03 Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlgF
   @ C(051),C(280) MsGet oGet4 Var cPfre04 Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlgF
   @ C(066),C(280) MsGet oGet5 Var cPfre05 Size C(042),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlgF

   @ C(084),C(145) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgF ACTION( SAI_FRETE() )

   ACTIVATE MSDIALOG oDlgF CENTERED 

Return(.T.)

// Função que grava os parâmetros do Frete
Static Function Sai_Frete()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_FTOT   := cPfre01
      ZZ4_FNRS   := cPfre02
      ZZ4_FFRS   := cPfre03
      ZZ4_FNNO   := cPfre04
      ZZ4_FRNO   := cPfre05
   Endif
   MsUnLock()

   oDlgF:End() 
   
Return .T.

// Função que abre janela para informação dos parâmetros de Comissões
Static Function Par_Comissoes()

   Private cComissao := 0

   Private oGet1

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_COMIS" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cComissao := T_PARAMETROS->ZZ4_COMIS
   Endif

   Private oDlgC

   DEFINE MSDIALOG oDlgC TITLE "Parâmetros de Comissões" FROM C(178),C(181) TO C(304),C(532) PIXEL

   @ C(005),C(005) Say "Informe o % de comissão a ser aplicado para os Gerentes de Vendas" Size C(165),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(023),C(071) Say "% sobre o total da comissão"                                       Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(022),C(044) MsGet oGet1 Var cComissao Size C(024),C(009) COLOR CLR_BLACK Picture "999.99" PIXEL OF oDlgC

   @ C(044),C(065) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgC ACTION( SaiComissao(cComissao) )

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que grava os parâmetros do Frete
Static Function SaiComissao(cComissao)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_COMIS  := cComissao
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_COMIS  := cComissao
   Endif

   MsUnLock()

   oDlgC:End() 
   
Return .T.

// Função Condição de Pagamento Padrão
Static Function Par_Condicao()

   Local lChumba     := .F.
   
   Private cCondicao := Space(03)
   Private cNomeCond := Space(40)

   Private oGet1
   Private oGet2

   Private oDlgP

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZ4_COND ,"
   cSql += "       B.E4_DESCRI "
   cSql += "  FROM " + RetSqlName("ZZ4") + " A, "
   cSql += "       " + RetSqlName("SE4") + " B  "
   cSql += " WHERE A.ZZ4_COND = B.E4_CODIGO"    

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cCondicao := T_PARAMETROS->ZZ4_COND
      cNomeCond := T_PARAMETROS->E4_DESCRI
   Endif

   DEFINE MSDIALOG oDlgP TITLE "Condição de Pagamento Padrão (Filed Service)" FROM C(178),C(181) TO C(284),C(647) PIXEL

   @ C(005),C(005) Say "Condição de Pagamento padrão de CHAMADO TÉCNICO para ORÇAMENTO (Field Service)" Size C(224),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(016),C(005) Say "Código"                                                                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(016),C(030) MsGet oGet1 Var cCondicao F3("SE4")    Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP VALID( TrazCond(cCondicao))
   @ C(016),C(058) MsGet oGet2 Var cNomeCond When lChumba Size C(133),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP

   @ C(033),C(096) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( SaiCondicao(cCondicao) )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que grava os parâmetros do Frete
Static Function TrazCond(cCondicao)

   Local cSql := ""
   
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT E4_DESCRI "
   cSql += "  FROM " + RetSqlName("SE4")
   cSql += " WHERE E4_CODIGO  = '" + Alltrim(cCondicao) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   If T_CONDICAO->( EOF() )
      cNomeCond := Space(40)
   Else
      cNomeCond := T_CONDICAO->E4_DESCRI
   Endif
   
Return .T.      

// Função que grava os parâmetros do Frete
Static Function SaiCondicao(cCondicao)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_COND   := cCondicao
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_COND   := cCondicao
   Endif

   MsUnLock()

   oDlgP:End() 
   
Return .T.

// Função Medição de Contratos
Static Function Par_Medicao()

   Local cSql    := ""
   Local lChumba := .F.

   Private dData := Ctod("  /  /    ")
   Private oGet1

   Private oDlgM

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZ4_MEDI"
   cSql += "  FROM " + RetSqlName("ZZ4") + " A "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      dData := Ctod(Substr(T_PARAMETROS->ZZ4_MEDI,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_MEDI,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_MEDI,01,04))
   Endif

   DEFINE MSDIALOG oDlgM TITLE "Medição Manual de Contratos" FROM C(178),C(181) TO C(279),C(456) PIXEL

   @ C(005),C(005) Say "Data da última execução da Medição de Contratos" Size C(123),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   @ C(015),C(049) MsGet oGet1 Var dData When lChumba Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM

   @ C(032),C(049) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// Função E-Mail reserva de Produtos
Static Function Par_Reserva()

   Local lChumba    := .F.
   
   Private cReserva := Space(250)
   Private oGet1

   Private oDlgE

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZ4_RESE "
   cSql += "  FROM " + RetSqlName("ZZ4") + " A "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cReserva := T_PARAMETROS->ZZ4_RESE
   Endif

   DEFINE MSDIALOG oDlgE TITLE "E-Mail Reserva de Produtos" FROM C(178),C(181) TO C(271),C(820) PIXEL

   @ C(005),C(005) Say "Informe e-mail de notificação de solicitação de reserva de produtos" Size C(160),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(014),C(005) MsGet oGet1 Var cReserva Size C(309),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(028),C(140) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE  ACTION( SaiReserva(cReserva) )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// Função que grava os parâmetros do E-Mail de reserva de Produtos
Static Function SaiReserva(cReserva)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_RESE   := cReserva
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_RESE   := cReserva
   Endif

   MsUnLock()

   oDlgE:End() 
   
Return .T.

// Função Usuários com permissão Consulta SERASA
Static Function Par_Serasa()

   Local cSql    := ""
   Local cLogon	   := Space(08)
   Local cSenha	   := Space(08)
   Local cNova	   := Space(08)
   Local cHomologa := Space(100)
   Local cProducao := Space(100)
   Local cSerasa   := Space(250)
   Local cRecipro  := Space(250)
   Local cRelato   := Space(250)

// Local cAmbiente := Space(01)
   Local cTimeOut  := 0
   Local aAmbiente := {"H - Homologação","P - Produção"}

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oRadioGrp1
   Local cAmbiente

   Private oDlgS

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SERA,"
   cSql += "       ZZ4_LOGO,"
   cSql += "       ZZ4_SENH,"
   cSql += "       ZZ4_NOVA,"
   cSql += "       ZZ4_HOMO,"
   cSql += "       ZZ4_PROD," 
   cSql += "       ZZ4_AMBI,"
   cSql += "       ZZ4_TIME,"
   cSql += "       ZZ4_ASER,"
   cSql += "       ZZ4_AREL "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cLogon    := T_PARAMETROS->ZZ4_LOGO
      cSenha    := T_PARAMETROS->ZZ4_SENH
      cNova	    := T_PARAMETROS->ZZ4_NOVA
      cHomologa := T_PARAMETROS->ZZ4_HOMO
      cProducao := T_PARAMETROS->ZZ4_PROD
      cSerasa   := T_PARAMETROS->ZZ4_SERA
      cAmbiente := T_PARAMETROS->ZZ4_AMBI
      cTimeOut  := T_PARAMETROS->ZZ4_TIME
      cRecipro  := T_PARAMETROS->ZZ4_ASER
      cRelato   := T_PARAMETROS->ZZ4_AREL
   Endif

   DEFINE MSDIALOG oDlgS TITLE "Parâmetros Consulta SERASA" FROM C(178),C(181) TO C(400),C(707) PIXEL && 520

   @ C(005),C(005) Say "Logon"                                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(005),C(052) Say "Senha"                                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(005),C(099) Say "Nova Senha"                                                 Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(027),C(005) Say "URL de Homologação"                                         Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(048),C(005) Say "URL de Produção"                                            Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(070),C(005) Say "Usuários com permissão de realizar consultas no SERASA"     Size C(143),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(096),C(005) Say "Separe os usuários com |  Exemplo:  Fulano|Beltrano|"       Size C(128),C(008) COLOR CLR_RED   PIXEL OF oDlgS
   @ C(005),C(146) Say "Ambiente de Consulta"                                       Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(005),C(216) Say "TimeOut"                                                    Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
// @ C(105),C(005) Say "Caminho para gravação do arquivo de envio da RECIPROCIDADE" Size C(128),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
// @ C(129),C(005) Say "Caminho para gravação do arquivo de envio do RELATO"        Size C(128),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
      
   @ C(014),C(005) MsGet oGet2        Var cLogon      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgS
   @ C(014),C(052) MsGet oGet3        Var cSenha      Size C(036),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgS
   @ C(014),C(099) MsGet oGet4        Var cNova       Size C(036),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgS
   @ C(015),C(146) ComboBox cAmbiente Items aAmbiente Size C(060),C(010) PIXEL OF oDlgS
   @ C(014),C(216) MsGet oGet7        Var cTimeOut    Size C(020),C(009) COLOR CLR_BLACK Picture "999"     PIXEL OF oDlgS
   @ C(037),C(005) MsGet oGet5        Var cHomologa   Size C(251),C(009) COLOR CLR_BLACK Picture "@&"      PIXEL OF oDlgS
   @ C(058),C(005) MsGet oGet6        Var cProducao   Size C(251),C(009) COLOR CLR_BLACK Picture "@&"      PIXEL OF oDlgS
   @ C(079),C(005) MsGet oGet1        Var cSerasa     Size C(251),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgS
// @ C(115),C(005) MsGet oGet8        Var cRecipro    Size C(251),C(009) COLOR CLR_BLACK Picture "@&"      PIXEL OF oDlgS
// @ C(139),C(005) MsGet oGet9        Var cRelato     Size C(251),C(009) COLOR CLR_BLACK Picture "@&"      PIXEL OF oDlgS

// @ C(154),C(219) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgS ACTION( SaiSerasa(cLogon, cSenha, cNova, cHomologa, cProducao, cSerasa, cAmbiente, cTimeOut, cRecipro, cRelato) )
   @ C(096),C(219) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgS ACTION( SaiSerasa(cLogon, cSenha, cNova, cHomologa, cProducao, cSerasa, cAmbiente, cTimeOut, cRecipro, cRelato) )

   ACTIVATE MSDIALOG oDlgs CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Usuários com permissão de consultar SERASA
Static Function SaiSerasa(cLogon, cSenha, cNova, cHomologa, cProducao, cSerasa, cAmbiente, cTimeOut, cRecipro, cRelato)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_SERA   := cSerasa
      ZZ4_LOGO   := cLogon
      ZZ4_SENH   := cSenha
      ZZ4_NOVA   := cNova
      ZZ4_HOMO   := cHomologa
      ZZ4_PROD   := cProducao
      ZZ4_AMBI   := cAmbiente
      ZZ4_TIME   := cTimeOut
      ZZ4_ASER   := cRecipro
      ZZ4_AREL   := cRelato
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_SERA   := cSerasa
      ZZ4_LOGO   := cLogon
      ZZ4_SENH   := cSenha
      ZZ4_NOVA   := cNova
      ZZ4_HOMO   := cHomologa
      ZZ4_PROD   := cProducao
      ZZ4_AMBI   := cAmbiente
      ZZ4_TIME   := cTimeOut
      ZZ4_ASER   := cRecipro
      ZZ4_AREL   := cRelato
   Endif

   MsUnLock()

   oDlgS:End() 
   
Return(.T.)

// Função quee abre a tela de informação dos TES de Demosntração
Static Function Par_TES()

   Local cSql := ""
   Local cTes := Space(250)
   Local oTes

   Private oDlgTES

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TESD" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cTes := T_PARAMETROS->ZZ4_TESD
   Endif

   DEFINE MSDIALOG oDlgTES TITLE "TES de Demonstração" FROM C(178),C(181) TO C(289),C(655) PIXEL

   @ C(005),C(005) Say "Indique abaixo os TES que representam operações de Demonstração." Size C(168),C(008) COLOR CLR_BLACK PIXEL OF oDlgTES
   @ C(013),C(005) Say "Informe os TES separados pelo caracter |. Exemplo 999|999|999|"   Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgTES

   @ C(024),C(005) MsGet oTes Var cTes Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTES

   @ C(038),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgTES ACTION( SaiTES(cTes) )

   ACTIVATE MSDIALOG oDlgTES CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Usuários com permissão de consultar SERASA
Static Function SaiTES(cTes)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_TESD   := cTes
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_TESD   := cTes
   Endif

   MsUnLock()

   oDlgTES:End() 
   
Return(.T.)

// Função que abre a tela de informação dos TES de Devolução
Static Function Par_DEV()
	
   Local cSql := ""
   Local cDev := Space(250)
   Local oTes

   Private oDlgTES

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_DEVO" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cDev := T_PARAMETROS->ZZ4_DEVO
   Endif

   DEFINE MSDIALOG oDlgTES TITLE "TES de Devolução" FROM C(178),C(181) TO C(289),C(655) PIXEL

   @ C(005),C(005) Say "Indique abaixo os TES que representam operações de Devolução."  Size C(168),C(008) COLOR CLR_BLACK PIXEL OF oDlgTES
   @ C(013),C(005) Say "Informe os TES separados pelo caracter |. Exemplo 999|999|999|" Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgTES

   @ C(024),C(005) MsGet oTes Var cDev Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTES

   @ C(038),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgTES ACTION( SaiDEV(cDev) )

   ACTIVATE MSDIALOG oDlgTES CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Usuários com permissão de consultar SERASA
Static Function SaiDEV(cDev)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_DEVO   := cDev
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_DEVO   := cDev
   Endif

   MsUnLock()

   oDlgTES:End() 
   
Return(.T.)

// Função que abre a tela de informação dos TES de Demosntração
Static Function Par_BOLETO()

   Local cMemo1   := ""
   Local oMemo1 

   Local cLinha01   := Space(100)
   Local cLinha02   := Space(100)
   Local cLinha03   := Space(100)
   Local cLinha04   := Space(100)
   Local cLinha05   := Space(100)
   Local cDespesa   := 0
   Local lSantander := .F.
   Local lItau      := .F.

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oCheckBox1
   Local oCheckBox2   
   
   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_BOL1," 
   cSql += "       ZZ4_BOL2," 
   cSql += "       ZZ4_BOL3," 
   cSql += "       ZZ4_BOL4," 
   cSql += "       ZZ4_BOL5,"          
   cSql += "       ZZ4_DTAX,"
   cSql += "       ZZ4_TBOL "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )           
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cLinha01 := T_PARAMETROS->ZZ4_BOL1
      cLinha02 := T_PARAMETROS->ZZ4_BOL2
      cLinha03 := T_PARAMETROS->ZZ4_BOL3
      cLinha04 := T_PARAMETROS->ZZ4_BOL4            
      cLinha05 := T_PARAMETROS->ZZ4_BOL5
      cDespesa := T_PARAMETROS->ZZ4_DTAX

      Do Case
         Case T_PARAMETROS->ZZ4_TBOL == "1"
              lSantander := .T.
              lItau      := .F.
         Case T_PARAMETROS->ZZ4_TBOL == "2"
              lSantander := .F.
              lItau      := .T.
         Case T_PARAMETROS->ZZ4_TBOL == "3"
              lSantander := .T.
              lItau      := .T.
      EndCase

   Endif

   Private oDlgBol

   DEFINE MSDIALOG oDlgBOL TITLE "Instruções Boletos Bancários" FROM C(178),C(181) TO C(423),C(627) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(106),C(026) PIXEL NOBORDER OF oDlgBOL

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(215),C(001) PIXEL OF oDlgBOL

   @ C(037),C(005) Say "Informe abaixo as instruções que serão impressas no boleto bacário" Size C(161),C(008) COLOR CLR_BLACK PIXEL OF oDlgBOL
   @ C(097),C(005) Say "Valor Despesas Bancárias"                                           Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgBOL
   @ C(097),C(070) Say "Emitir Boleto do Banco"                                             Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgBOL
   
   @ C(047),C(005) MsGet    oGet1      Var cLinha01                            Size C(214),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgBOL
   @ C(056),C(005) MsGet    oGet2      Var cLinha02                            Size C(214),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgBOL
   @ C(065),C(005) MsGet    oGet3      Var cLinha03                            Size C(214),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgBOL
   @ C(074),C(005) MsGet    oGet4      Var cLinha04                            Size C(214),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgBOL
   @ C(083),C(005) MsGet    oGet5      Var cLinha05                            Size C(214),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgBOL
   @ C(106),C(005) MsGet    oGet6      Var cDespesa                            Size C(046),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgBOL
   @ C(106),C(070) CheckBox oCheckBox1 Var lSantander Prompt "Banco Santander" Size C(053),C(008)                                         PIXEL OF oDlgBOL
   @ C(114),C(070) CheckBox oCheckBox2 Var lItau      Prompt "Banco Itaú"      Size C(048),C(008)                                         PIXEL OF oDlgBOL

   @ C(104),C(181) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgBOL ACTION( SaiBOLETO(cLinha01, cLinha02, cLinha03, cLinha04, cLinha05, cDespesa, lSantander, lItau) )

   ACTIVATE MSDIALOG oDlgBOL CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Usuários com permissão de consultar SERASA
Static Function SaiBOLETO(cLinha01, cLinha02, cLinha03, cLinha04, cLinha05, cDespesa, lSantander, lItau)

   Local cSql := ""

   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4->ZZ4_FILIAL := cFilAnt
      ZZ4->ZZ4_CODI   := "000001"
      ZZ4->ZZ4_BOL1   := cLinha01
      ZZ4->ZZ4_BOL2   := cLinha02
      ZZ4->ZZ4_BOL3   := cLinha03
      ZZ4->ZZ4_BOL4   := cLinha04
      ZZ4->ZZ4_BOL5   := cLinha05                  
      ZZ4->ZZ4_DTAX   := cDespesa

      Do Case
         Case lSantander == .T. .And. lItau == .F.
              ZZ4->ZZ4_TBOL := "1"
         Case lSantander == .F. .And. lItau == .T.
              ZZ4->ZZ4_TBOL := "2"
         Case lSantander == .T. .And. lItau == .T.
              ZZ4->ZZ4_TBOL := "3"
      EndCase               

   Else

      RecLock("ZZ4",.F.)     
      ZZ4->ZZ4_BOL1   := cLinha01
      ZZ4->ZZ4_BOL2   := cLinha02
      ZZ4->ZZ4_BOL3   := cLinha03                               
      ZZ4->ZZ4_BOL4   := cLinha04
      ZZ4->ZZ4_BOL5   := cLinha05                  
      ZZ4->ZZ4_DTAX   := cDespesa

      Do Case
         Case lSantander == .T. .And. lItau == .F.
              ZZ4->ZZ4_TBOL := "1"
         Case lSantander == .F. .And. lItau == .T.
              ZZ4->ZZ4_TBOL := "2"
         Case lSantander == .T. .And. lItau == .T.
              ZZ4->ZZ4_TBOL := "3"
      EndCase               

   Endif

   MsUnLock()

   oDlgBol:End() 
   
Return(.T.)

// Função que abre a tela de informação dos Parâmetros dos Correios
Static Function Par_CORREIOS()

   Private cSql         := ""
   Private lChumba      := .F.
   Private cEndereco    := Space(25)
   Private cEmpresa     := Space(25)
   Private cSenha       := Space(25)
   Private cFrete       := Space(25)
   Private cNome        := Space(25)
   Private cCepOrig     := Space(08)
   Private cCEPCaxias   := Space(08)
   Private cCEPPELOTAS  := Space(08)
   Private cCEPSUPRI    := Space(08)
   Private cCEPCURITIBA := Space(08)
   Private cFreteAc     := 0
   Private cPesoP       := 0
   Private cPesoB       := 0
   Private cAltura      := 0
   Private clargura     := 0
   Private cCompri      := 0

   Private lHabilita    := .T.
   Private lProposta    := .T.
   Private lCallCenter  := .T.
   Private lPedido      := .T.

   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oCheckBox4
   Private oGet1
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet16
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9

   Private oDlgCor

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_EMPR," 
   cSql += "       ZZ4_CSEN," 
   cSql += "       ZZ4_CURL," 
   cSql += "       ZZ4_FRET,"
   cSql += "       ZZ4_HABI,"
   cSql += "       ZZ4_PROP,"
   cSql += "       ZZ4_CALL,"
   cSql += "       ZZ4_PEDI,"
   cSql += "       ZZ4_CEPO,"
   cSql += "       ZZ4_CEPX,"
   cSql += "       ZZ4_CEPP,"
   cSql += "       ZZ4_CEPS,"
   cSql += "       ZZ4_CEPC,"         
   cSql += "       ZZ4_FREA,"
   cSql += "       ZZ4_PESP,"
   cSql += "       ZZ4_PESB,"
   cSql += "       ZZ4_ALTU,"
   cSql += "       ZZ4_LARG,"
   cSql += "       ZZ4_COMP "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cEmpresa     := T_PARAMETROS->ZZ4_EMPR
      cSenha       := T_PARAMETROS->ZZ4_CSEN
      cEndereco    := T_PARAMETROS->ZZ4_CURL
      cFrete       := T_PARAMETROS->ZZ4_FRET
      lHabilita    := IIF(T_PARAMETROS->ZZ4_HABI == "T", .T., .F.)
      lProposta	   := IIF(T_PARAMETROS->ZZ4_PROP == "T", .T., .F.)
      lCallCenter  := IIF(T_PARAMETROS->ZZ4_CALL == "T", .T., .F.)
      lPedido 	   := IIF(T_PARAMETROS->ZZ4_PEDI == "T", .T., .F.)
      cCepOrig     := T_PARAMETROS->ZZ4_CEPO
      cCEPCaxias   := T_PARAMETROS->ZZ4_CEPX
      cCEPPELOTAS  := T_PARAMETROS->ZZ4_CEPP
      cCEPSUPRI    := T_PARAMETROS->ZZ4_CEPS
      cCEPCURITIBA := T_PARAMETROS->ZZ4_CEPC
      cFreteAC     := T_PARAMETROS->ZZ4_FREA
      cPesoP       := T_PARAMETROS->ZZ4_PESP
      cPesoB       := T_PARAMETROS->ZZ4_PESB
      cAltura      := T_PARAMETROS->ZZ4_ALTU
      cLargura     := T_PARAMETROS->ZZ4_LARG
      cCompri      := T_PARAMETROS->ZZ4_COMP
   Endif

   DEFINE MSDIALOG oDlgCor TITLE "Parâmetros dos Correios" FROM C(178),C(181) TO C(563),C(653) PIXEL

   // Pesquisa o nome da transportadora para display
   PesFrete(cFrete)

   @ C(006),C(123) Say "(*) CAMPO NÃO OBRIGATÓRIOS"            Size C(084),C(008) COLOR CLR_RED   PIXEL OF oDlgCor
   @ C(019),C(005) Say "Código Administrativo junto à ECT (*)" Size C(088),C(008) COLOR CLR_RED   PIXEL OF oDlgCor
   @ C(019),C(101) Say "Senha (*)"                             Size C(024),C(008) COLOR CLR_RED   PIXEL OF oDlgCor
   @ C(042),C(005) Say "Url"                                   Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(063),C(005) Say "Transportadora"                        Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(089),C(005) Say "CEP de Origem - Porto Alegre"          Size C(073),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(089),C(140) Say "Frete (Acréscimo)"                     Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(102),C(005) Say "CEP de Origem - Caxias do Sul"         Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(102),C(140) Say "Peso Padrão"                           Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(115),C(005) Say "CEP de Origem - Pelotas"               Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(115),C(140) Say "Peso Base"                             Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(128),C(005) Say "CEP de Origem - Suprimentos"           Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(128),C(140) Say "Altura Padrão"                         Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(141),C(005) Say "CEP de Origem - Curitiba"              Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(141),C(139) Say "Largura Padrão"                        Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(154),C(139) Say "Comp. Padrão"                          Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   @ C(159),C(005) Say "Aplicar em"                            Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
   
   @ C(005),C(005) CheckBox oCheckBox1 Var lHabilita Prompt "Habilitar a pesquisa" Size C(059),C(008)              PIXEL OF oDlgCor
   @ C(030),C(005) MsGet    oGet2      Var cEmpresa     Size C(045),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(030),C(101) MsGet    oGet3      Var cSenha       Size C(045),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(050),C(005) MsGet    oGet1      Var cEndereco    Size C(225),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(073),C(005) MsGet    oGet4      Var cFrete       Size C(030),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor F3("SA4") VALID( PesFrete(cFrete))
   @ C(073),C(041) MsGet    oGet5      Var cNome        Size C(188),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(089),C(083) MsGet    oGet6      Var cCepOrig     Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(102),C(084) MsGet    oGet13     Var cCEPCaxias   Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(115),C(084) MsGet    oGet14     Var cCEPPELOTAS  Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(128),C(084) MsGet    oGet15     Var cCEPSUPRI    Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(141),C(084) MsGet    oGet16     Var cCEPCURITIBA Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgCor
   @ C(089),C(190) MsGet    oGet8      Var cFreteAC     Size C(039),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgCor
   @ C(102),C(190) MsGet    oGet7      Var cPesoP       Size C(024),C(009) COLOR CLR_BLACK Picture "@E 99.999"     PIXEL OF oDlgCor
   @ C(115),C(190) MsGet    oGet9      Var cPesoB       Size C(024),C(009) COLOR CLR_BLACK Picture "@E 99.999"     PIXEL OF oDlgCor
   @ C(128),C(190) MsGet    oGet10     Var cAltura      Size C(024),C(009) COLOR CLR_BLACK Picture "@E 99.999"     PIXEL OF oDlgCor
   @ C(141),C(190) MsGet    oGet11     Var cLargura     Size C(024),C(009) COLOR CLR_BLACK Picture "@E 99.999"     PIXEL OF oDlgCor
   @ C(154),C(190) MsGet    oGet12     Var cCompri      Size C(024),C(009) COLOR CLR_BLACK Picture "@E 99.999"     PIXEL OF oDlgCor
   @ C(158),C(036) CheckBox oCheckBox2 Var lProposta    Prompt "Proposta Comercial"        Size C(057),C(008)      PIXEL OF oDlgCor
   @ C(168),C(036) CheckBox oCheckBox3 Var lCallCenter  Prompt "Atendimento Call Center"   Size C(069),C(008)      PIXEL OF oDlgCor
   @ C(179),C(036) CheckBox oCheckBox4 Var lPedido      Prompt "Pedido de Venda"           Size C(053),C(008)      PIXEL OF oDlgCor

   @ C(171),C(155) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCor ACTION( SaiCORREIOS(cEmpresa, cSenha, cEndereco, cFrete, lHabilita, lProposta, lCallCenter, lPedido) )

   ACTIVATE MSDIALOG oDlgCor CENTERED 

Return(.T.)

// Função que pesquisa a transportadora informada na janela dos parâmetros dos Correios
Static Function PesFrete(_Frete)

   Local cSql := ""
   
   If Empty(Alltrim(_Frete))
      cNome := ""
      Return .T.
   Endif
   
   // Pesquisa a transportadora
   If Select("T_FRETE") > 0
      T_FRETE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A4_COD , "
   cSql += "       A4_NOME  "
   cSql += "  FROM " + RetSqlName("SA4")
   cSql += " WHERE A4_COD = '" + Alltrim(_Frete) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FRETE", .T., .T. )

   If T_FRETE->( EOF() )
      cNome := ""
   Else
      cNome := T_FRETE->A4_NOME
   Endif

Return(.T.)

// Função que grava os parâmetros dos Correios
Static Function SaiCORREIOS(cEmpresa, cSenha, cEndereco, cFrete, lHabilita, lProposta, lCallCenter, lPedido)

   Local cSql := ""

   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_EMPR   := cEmpresa
      ZZ4_CSEN   := cSenha
      ZZ4_CURL   := Alltrim(cEndereco)
      ZZ4_FRET   := cFrete
      ZZ4_HABI   := IIF(lHabilita   == .F., "F", "T")
      ZZ4_PROP   := IIF(lProposta   == .F., "F", "T")
      ZZ4_CALL   := IIF(lCallCenter == .F., "F", "T")
      ZZ4_PEDI   := IIF(lPedido     == .F., "F", "T")            
      ZZ4_CEPO   := cCepOrig
      ZZ4_CEPX   := cCEPCaxias   
      ZZ4_CEPP   := cCEPPELOTAS  
      ZZ4_CEPS   := cCEPSUPRI    
      ZZ4_CEPC   := cCEPCURITIBA 
      ZZ4_FREA   := cFreteAC
      ZZ4_PESP   := cPesoP  
      ZZ4_PESB   := cPesoB  
      ZZ4_ALTU   := cAltura 
      ZZ4_LARG   := cLargura
      ZZ4_COMP   := cCompri 
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_EMPR   := cEmpresa
      ZZ4_CSEN   := cSenha
      ZZ4_CURL   := Alltrim(cEndereco)
      ZZ4_FRET   := cFrete
      ZZ4_HABI   := IIF(lHabilita   == .F., "F", "T")
      ZZ4_PROP   := IIF(lProposta   == .F., "F", "T")
      ZZ4_CALL   := IIF(lCallCenter == .F., "F", "T")
      ZZ4_PEDI   := IIF(lPedido     == .F., "F", "T")            
      ZZ4_CEPO   := cCepOrig
      ZZ4_CEPX   := cCEPCaxias   
      ZZ4_CEPP   := cCEPPELOTAS  
      ZZ4_CEPS   := cCEPSUPRI    
      ZZ4_CEPC   := cCEPCURITIBA 
      ZZ4_FREA   := cFreteAC
      ZZ4_PESP   := cPesoP  
      ZZ4_PESB   := cPesoB  
      ZZ4_ALTU   := cAltura 
      ZZ4_LARG   := cLargura
      ZZ4_COMP   := cCompri 
   Endif

   MsUnLock()

   oDlgCor:End() 
   
Return(.T.)

// Função E-Mail para Departamento de recepção de Mercadorias
Static Function Par_Recepcao()

   Local lChumba     := .F.
   
   Private cRecepcao := Space(250)
   Private oGet1

   Private oDlgE

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZ4_MERC "
   cSql += "  FROM " + RetSqlName("ZZ4") + " A "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cRecepcao := T_PARAMETROS->ZZ4_MERC
   Endif

   DEFINE MSDIALOG oDlgE TITLE "E-Mail Departamento de Recepção de Mercadorias" FROM C(178),C(181) TO C(271),C(820) PIXEL

   @ C(005),C(005) Say "Informe e-mail de notificação ao Departamento de Recepção de Mercadorias" Size C(160),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(014),C(005) MsGet oGet1 Var cRecepcao Size C(309),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(028),C(140) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE  ACTION( SaiRecepcao(cRecepcao) )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// Função que grava os parâmetros do E-Mail de reserva de Produtos
Static Function SaiRecepcao(cReserva)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_MERC   := cRecepcao
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_MERC   := cRecepcao
   Endif

   MsUnLock()

   oDlgE:End() 
   
Return .T.

// Função que abre a tela de informação dos grupos de usuários do Call Center
Static Function Par_CALLCENTER()

   Private cGrupos := Space(150)
   Private cFilCon := Space(02)

   Private oGet1
   Private oGet2

   Private oDlgCall

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL," 
   cSql += "       ZZ4_GRUP  ,"
   cSql += "       ZZ4_FLAT   "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cGrupos := T_PARAMETROS->ZZ4_GRUP
      cFilCon := T_PARAMETROS->ZZ4_FLAT
   Endif

   DEFINE MSDIALOG oDlgCall TITLE "Atendimento Call Center" FROM C(178),C(181) TO C(367),C(583) PIXEL

   @ C(005),C(005) Say "Informe abaixo os códigos dos grupos de usuários que deverão ser consistidos" Size C(187),C(008) COLOR CLR_BLACK PIXEL OF oDlgCall
   @ C(014),C(005) Say "no momento da inclusão de Atendimento de Call Center para que somente sejam"  Size C(193),C(008) COLOR CLR_BLACK PIXEL OF oDlgCall
   @ C(024),C(005) Say "incluídos produtos Etiquetas/Ribbon na Filial 04 - Suprimentos."              Size C(151),C(008) COLOR CLR_BLACK PIXEL OF oDlgCall
   @ C(036),C(005) Say "Grupos de Usuários"                                                           Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgCall
   @ C(056),C(005) Say "Para informar mais do que um grupo, separe-os com o caracter |"               Size C(154),C(008) COLOR CLR_BLACK PIXEL OF oDlgCall
   @ C(070),C(005) Say "Código Filial a ser verificada"                                               Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlgCall

   @ C(045),C(005) MsGet oGet1 Var cGrupos Size C(189),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCall
   @ C(080),C(005) MsGet oGet2 Var cFilCon Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCall

   @ C(073),C(123) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCall action( Sai_Call() )

   ACTIVATE MSDIALOG oDlgCall CENTERED 

Return(.T.)

// Função que grava os parâmetros do Frete
Static Function Sai_Call()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_GRUP   := cGrupos
      ZZ4_FLAT   := cFilcon
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_GRUP   := cGrupos
      ZZ4_FLAT   := cFilcon
   Endif

   MsUnLock()

   oDlgCall:End() 
   
Return .T.

// Função que abre a tela de informação dos Grupos com Acesso ao Kardex pela Ações Relacionadas do Cadastro de Produtos
Static Function Par_Kardex()

   Local cSql    := ""
   Local cKardex := Space(250)
   Local oKardex

   Private oDlgKar

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_KARD" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cKardex := T_PARAMETROS->ZZ4_KARD
   Endif

   DEFINE MSDIALOG oDlgKar TITLE "Acesso ao Kardex/Histórico de Produtos" FROM C(178),C(181) TO C(289),C(655) PIXEL

   @ C(005),C(005) Say "Indique abaixo os Grupos que possuem acesso ao Kardex/Histórico de Produtos pelo Cadastro de Produtos." Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlgKar
   @ C(013),C(005) Say "Informe os Grupos separados pelo caracter |. Exemplo 999999|999999|999999|"                             Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgKar

   @ C(024),C(005) MsGet oKardex Var cKardex Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgKAR

   @ C(038),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgKar ACTION( SaiKar(cKardex) )

   ACTIVATE MSDIALOG oDlgKAR CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Grupos de Acessos ao Kardex
Static Function SaiKar(cKardex)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_KARD   := cKardex
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_KARD   := cKardex
   Endif

   MsUnLock()

   oDlgKAR:End() 
   
Return(.T.)

// Função que abre a tela Comissão Call Center
Static Function Par_CCenter()

   Local cSql      := ""
   Local cComissao := 0
   Local oComissao

   Private oDlgCenter

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_CCEN" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cComissao := T_PARAMETROS->ZZ4_CCEN
   Endif

   DEFINE MSDIALOG oDlgCenter TITLE "Comissão Call Center" FROM C(178),C(181) TO C(315),C(514) PIXEL

   @ C(005),C(005) Say "Indique o % de comissão a ser utilizado para bloqueio de Quoting" Size C(156),C(008) COLOR CLR_BLACK PIXEL OF oDlgCenter
   @ C(012),C(005) Say "na elaboração de pedidos do Call Center."                         Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgCenter
   @ C(023),C(005) Say "Bloquear PVs de Call Center c/comissão MAIOR QUE"                 Size C(128),C(008) COLOR CLR_BLACK PIXEL OF oDlgCenter

   @ C(035),C(068) MsGet oComissao Var cComissao Size C(025),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgCenter

   @ C(050),C(061) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCenter ACTION( FechaCall(cComissao) )

   ACTIVATE MSDIALOG oDlgCenter CENTERED 

Return(.T.)

// Função que grava o parâmetro de Comissão de Call Center e fecha a janela
Static Function FechaCall(_Comissao)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_CCEN   := _Comissao
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_CCEN   := _Comissao
   Endif

   MsUnLock()

   oDlgCenter:End() 
   
Return(.T.)

// Função que abre a tela Preço de Orçamento Técnico
Static Function Par_Preco()

   Local cSql   := ""

   Local cValor := 0
   Local oGet1

   Private oDlgP

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_PRECO" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cValor := T_PARAMETROS->ZZ4_PRECO
   Endif

   DEFINE MSDIALOG oDlgP TITLE "Preço de Orçamento Técnico" FROM C(178),C(181) TO C(280),C(560) PIXEL

   @ C(005),C(005) Say "Valor de Orçamentação a ser informado no Chamado Técnico e Orçamento" Size C(180),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(017),C(056) Say "Valor"                                                                Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg´P
   
   @ C(016),C(075) MsGet oGet1 Var cValor Size C(037),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlgP

   @ C(032),C(075) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( FechaPreco(cValor) )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que grava o Preço de Orçamento Técnico
Static Function FechaPreco(_Valor)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_PRECO  := _Valor
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_PRECO  := _Valor
   Endif

   MsUnLock()

   oDlgP:End() 
   
Return(.T.)

// Função que abre a tela do Relatório de Vendas por Vendeores
Static Function Par_Vendedor()

   Local cSql        := ""
   Local cSupervisor := 0
   Local oGet1

   Private oDlgV

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SVEN" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cSupervisor := T_PARAMETROS->ZZ4_SVEN
   Endif

   DEFINE MSDIALOG oDlgV TITLE "Relatório de Vendas por Vendedor" FROM C(178),C(181) TO C(317),C(499) PIXEL

   @ C(005),C(005) Say "Indique abaixo os códigos dos Grupos de Usuários que podem"  Size C(149),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(014),C(005) Say "emitir o Relatório de Vendas por Vendedores."                Size C(110),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(023),C(005) Say "Informe os grupos separados por |. Exemplo: 000001|0000002|" Size C(148),C(008) COLOR CLR_BLACK PIXEL OF oDlgV

   @ C(035),C(005) MsGet oGet1 Var cSupervisor Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV

   @ C(051),C(060) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgV ACTION( FechaVenda(cSupervisor) )

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return(.T.)

// Função que grava o Preço de Orçamento Técnico
Static Function FechaVenda(_Supervisor)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_SVEN   := _Supervisor
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_SVEN   := _Supervisor
   Endif

   MsUnLock()

   oDlgV:End() 
   
Return(.T.)

// Função que abre a tela de parametrização de dias para pesquisa de produtos sem movimentação
Static Function Par_Pesquisa()

   Local cSql  := ""
   Local cDias := 0
   Local oGet1

   Private oDlgP

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_DIAS" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cDias := T_PARAMETROS->ZZ4_DIAS
   Endif

   Private oDlgP

   DEFINE MSDIALOG oDlgP TITLE "Dias Produtos sem movimentação (Pesquisa de produtos)" FROM C(178),C(181) TO C(306),C(696) PIXEL

   @ C(005),C(005) Say "Informe abaixo a quantidade de dias a serem consideradas para produtos que atendam a seguinte regra:" Size C(249),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(014),C(005) Say "Tem estoque disponivel para venda na Companhia e que não tem giro de estoque a mais de XX dias."      Size C(239),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(028),C(092) Say "Quantidade de Dias"                                                                                   Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(027),C(142) MsGet oGet1 Var cDias Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgP

   @ C(046),C(109) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlgP ACTION( FechaPesquisa(cDias) )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que grava o Preço de Orçamento Técnico
Static Function FechaPesquisa(_Dias)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_DIAS   := _Dias
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_DIAS   := _Dias
   Endif

   MsUnLock()

   oDlgP:End() 
   
Return(.T.)

// Função que abre de solicitação dos usuários que podem realizar cópia de TES
Static Function Par_CopiaTes()

   Local cSql      := ""
   Local cCopiaTes := ""
   Local oGet1

   Private oDlgV

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_CTES" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cCopiaTes := T_PARAMETROS->ZZ4_CTES
   Endif

   DEFINE MSDIALOG oDlgV TITLE "Copiar TES" FROM C(178),C(181) TO C(317),C(499) PIXEL

   @ C(005),C(005) Say "Indique abaixo os usuários que podem realizar cópia de TES."  Size C(149),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(023),C(005) Say "Informe os Usuários separados por |. Exemplo: JOAO|PEDRO|" Size C(148),C(008) COLOR CLR_BLACK PIXEL OF oDlgV

   @ C(035),C(005) MsGet oGet1 Var cCopiaTes Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV

   @ C(051),C(060) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgV ACTION( FechaCopia(cCopiaTes) )

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return(.T.)

// Função que grava o Preço de Orçamento Técnico
Static Function FechaCopia(_CopiaTes)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_CTES   := _CopiaTes
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_CTES   := _CopiaTes
   Endif

   MsUnLock()

   oDlgV:End() 
   
Return(.T.)

// Função que abre parametrização de usuários que podem ver produtos em liquidação sem estoque na entrada do módulo de Faturamento (SIGAFAT)
Static Function Par_Liquidacao()

   Local cSql     := ""
   Local cLiquida := ""
   Local oGet1

   Private oDlgV

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LIQU" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cLiquida := T_PARAMETROS->ZZ4_LIQU
   Endif

   DEFINE MSDIALOG oDlgV TITLE "Produtos em Liquidação" FROM C(178),C(181) TO C(317),C(499) PIXEL

   @ C(005),C(005) Say "Indique abaixo os usuários que podem visualizar produtos em liquidação." Size C(149),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(023),C(005) Say "Informe os Usuários separados por |. Exemplo: FULANO|BELTRANO|"          Size C(148),C(008) COLOR CLR_BLACK PIXEL OF oDlgV

   @ C(035),C(005) MsGet oGet1 Var cLiquida Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV

   @ C(051),C(060) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgV ACTION( FechaLiquida(cLiquida) )

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return(.T.)

// Função que grava o Preço de Orçamento Técnico
Static Function FechaLiquida(_Liquida)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_LIQU   := _Liquida
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_LIQU   := _Liquida
   Endif

   MsUnLock()

   oDlgV:End() 
   
Return(.T.)

// Função que abre parametrização de Usuários Liberadores do Cadastro de Produtos
Static Function Par_Liberadores()

   Local cSql           := ""

   Private cLiberadores := Space(200)
   Private oGet1

   Private oDlgL

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LIBE" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cliberadores := T_PARAMETROS->ZZ4_LIBE
   Endif

   DEFINE MSDIALOG oDlgL TITLE "E-mails Liberadores Cadastro de Produtos" FROM C(178),C(181) TO C(291),C(746) PIXEL
 
   @ C(005),C(005) Say "Informe abaixo os e-mail(s) dos responsáveis pela liberação do Cadastro de Produtos quando estes forem incluídos." Size C(272),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(014),C(005) Say "Informe os e-mail separando-os com Ponto e Vírgula (;)"                                                            Size C(137),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(024),C(005) MsGet oGet1 Var cLiberadores Size C(271),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL

   @ C(038),C(121) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( fechaLiberador( cLiberadores) )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// Função que grava os Usuários Liberadores do Cadastro de Produtos
Static Function FechaLiberador(_Liberadores)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_LIBE   := _Liberadores
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_LIBE   := _Liberadores
   Endif

   MsUnLock()

   oDlgL:End() 
   
Return(.T.)

// Função que abre parametrização de Envio de E-mail da Entrada da Mercadoria
Static Function Par_Entrada()

   Local cSql     := ""

   Private cEmail := ""
   Private cEtes  := ""
   
   Private oGet1
   Private oGet2
   
   Private oDlgE

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GENT,"
   cSql += "       ZZ4_ETES "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cEmail := T_PARAMETROS->ZZ4_GENT
      cEtes  := T_PARAMETROS->ZZ4_ETES
   Endif

   DEFINE MSDIALOG oDlgE TITLE "E-mails Recebimento de Aviso de Entrada de Mercadorias" FROM C(178),C(181) TO C(334),C(717) PIXEL

   @ C(005),C(005) Say "Informe e-mails dos usuários que receberão o aviso de entrada de mercadorias."                  Size C(189),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(028),C(005) Say "Indique os TES que serão considerados para envio de e-mail de aviso de entrada de mercadorias." Size C(234),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(037),C(005) Say "Informe os TES que receberão e-mail de entrada - Sintaxe XXX|XXX|"                              Size C(221),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(015),C(005) MsGet oGet1 Var cEmail Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
   @ C(047),C(005) MsGet oGet2 Var cEtes  Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(061),C(113) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( FechaEmail(cEmail, cEtes))

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// Função que grava os Usuários Liberadores do Cadastro de Produtos
Static Function FechaEmail(_cEmail, _cEtes)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_GENT   := _cEmail
      ZZ4_ETES   := _cEtes
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_GENT   := _cEmail
      ZZ4_ETES   := _cEtes
   Endif

   MsUnLock()

   oDlgE:End() 
   
Return(.T.)

// Função que abre a parametrização dos aprovadores de RMA
Static Function Par_AprovaRMA()

/*

   Private cNome1	 := Space(30)
   Private cNome3	 := Space(30)
   Private cNome5	 := Space(30)
   Private cNome7	 := Space(30)
   Private cNome9	 := Space(30)

   Private cEmai2	 := Space(100)
   Private cEmai4	 := Space(100)
   Private cEmai6	 := Space(100)
   Private cEmai8	 := Space(100)
   Private cEmai10	 := Space(100)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   
   Private oDlgRMA

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_NRMA1,"
   cSql += "       ZZ4_NRMA2,"
   cSql += "       ZZ4_NRMA3,"
   cSql += "       ZZ4_NRMA4,"
   cSql += "       ZZ4_NRMA5,"      
   cSql += "       ZZ4_ERMA1,"
   cSql += "       ZZ4_ERMA2,"
   cSql += "       ZZ4_ERMA3,"
   cSql += "       ZZ4_ERMA4,"
   cSql += "       ZZ4_ERMA5 "         
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cNome1  := T_PARAMETROS->ZZ4_NRMA1
      cNome3  := T_PARAMETROS->ZZ4_NRMA2
      cNome5  := T_PARAMETROS->ZZ4_NRMA3
      cNome7  := T_PARAMETROS->ZZ4_NRMA4
      cNome9  := T_PARAMETROS->ZZ4_NRMA5
      cEmai2  := T_PARAMETROS->ZZ4_ERMA1
      cEmai4  := T_PARAMETROS->ZZ4_ERMA2
      cEmai6  := T_PARAMETROS->ZZ4_ERMA3
      cEmai8  := T_PARAMETROS->ZZ4_ERMA4
      cEmai10 := T_PARAMETROS->ZZ4_ERMA5
   Endif

   DEFINE MSDIALOG oDlgRMA TITLE "Aprovadores de RMA" FROM C(178),C(181) TO C(369),C(697) PIXEL

   @ C(005),C(005) Say "Nome Aprovadores"    Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA
   @ C(005),C(107) Say "E-mail do Aprovador" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA

   @ C(015),C(005) MsGet oGet1  Var cNome1  Size C(096),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(015),C(107) MsGet oGet2  Var cEmai2  Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(027),C(005) MsGet oGet3  Var cNome3  Size C(096),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(027),C(107) MsGet oGet4  Var cEmai4  Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(039),C(005) MsGet oGet5  Var cNome5  Size C(096),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(039),C(107) MsGet oGet6  Var cEmai6  Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(051),C(005) MsGet oGet7  Var cNome7  Size C(096),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(051),C(107) MsGet oGet8  Var cEmai8  Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(063),C(005) MsGet oGet9  Var cNome9  Size C(096),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(063),C(107) MsGet oGet10 Var cEmai10 Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA

   @ C(078),C(108) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRMA ACTION( FechaRMA() )

   ACTIVATE MSDIALOG oDlgRMA CENTERED 

***********************************

*/

   Local cMemo1 := ""
   Local cMemo2 := ""

   Private cNome01 := Space(30)
   Private cNome02 := Space(30)
   Private cNome03 := Space(30)
   Private cNome04 := Space(30)
   Private cNome05 := Space(30)
   Private cNome06 := Space(30)
   Private cNome07 := Space(30)
   Private cNome08 := Space(30)
   Private cNome09 := Space(30)
   Private cNome10 := Space(30)                        

   Private cEmai01 := Space(100)
   Private cEmai02 := Space(100)
   Private cEmai03 := Space(100)
   Private cEmai04 := Space(100)
   Private cEmai05 := Space(100)
   Private cEmai06 := Space(100)
   Private cEmai07 := Space(100)
   Private cEmai08 := Space(100)
   Private cEmai09 := Space(100)                     
   Private cEmai10 := Space(100)                     

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5         
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
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
   Private oGet20         

   Private oDlgRMA

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_NRMA1 ,"
   cSql += "       ZZ4_NRMA2 ,"
   cSql += "       ZZ4_NRMA3 ,"
   cSql += "       ZZ4_NRMA4 ,"
   cSql += "       ZZ4_NRMA5 ,"      
   cSql += "       ZZ4_NRMA6 ,"      
   cSql += "       ZZ4_NRMA7 ,"      
   cSql += "       ZZ4_NRMA8 ,"         
   cSql += "       ZZ4_NRMA9 ,"      
   cSql += "       ZZ4_NRMA10,"                                             
   cSql += "       ZZ4_ERMA1 ,"
   cSql += "       ZZ4_ERMA2 ,"
   cSql += "       ZZ4_ERMA3 ,"
   cSql += "       ZZ4_ERMA4 ,"
   cSql += "       ZZ4_ERMA5 ,"
   cSql += "       ZZ4_EMAI6 ,"
   cSql += "       ZZ4_EMAI7 ,"
   cSql += "       ZZ4_EMAI8 ,"
   cSql += "       ZZ4_EMAI9 ,"
   cSql += "       ZZ4_EMAI10 "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cNome01 := T_PARAMETROS->ZZ4_NRMA1
      cNome02 := T_PARAMETROS->ZZ4_NRMA2
      cNome03 := T_PARAMETROS->ZZ4_NRMA3
      cNome04 := T_PARAMETROS->ZZ4_NRMA4
      cNome05 := T_PARAMETROS->ZZ4_NRMA5
      cNome06 := T_PARAMETROS->ZZ4_NRMA6
      cNome07 := T_PARAMETROS->ZZ4_NRMA7
      cNome08 := T_PARAMETROS->ZZ4_NRMA8
      cNome09 := T_PARAMETROS->ZZ4_NRMA9
      cNome10 := T_PARAMETROS->ZZ4_NRMA10                        
      cEmai01 := T_PARAMETROS->ZZ4_ERMA1
      cEmai02 := T_PARAMETROS->ZZ4_ERMA2
      cEmai03 := T_PARAMETROS->ZZ4_ERMA3
      cEmai04 := T_PARAMETROS->ZZ4_ERMA4
      cEmai05 := T_PARAMETROS->ZZ4_ERMA5
      cEmai06 := T_PARAMETROS->ZZ4_EMAI6
      cEmai07 := T_PARAMETROS->ZZ4_EMAI7
      cEmai08 := T_PARAMETROS->ZZ4_EMAI8
      cEmai09 := T_PARAMETROS->ZZ4_EMAI9
      cEmai10 := T_PARAMETROS->ZZ4_EMAI10                        
   Endif

   DEFINE MSDIALOG oDlgRMA TITLE "Aprovadores RMA" FROM C(178),C(181) TO C(588),C(591) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgRMA

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(196),C(001) PIXEL OF oDlgRMA
   @ C(179),C(003) GET oMemo2 Var cMemo2 MEMO Size C(196),C(001) PIXEL OF oDlgRMA

   @ C(036),C(005) Say "Informe login e e-mail dos aprovadores de RMA" Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA

   @ C(048),C(005) MsGet oGet1  Var cNome01 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(048),C(071) MsGet oGet2  Var cEmai01 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(061),C(005) MsGet oGet3  Var cNome02 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(061),C(071) MsGet oGet4  Var cEmai02 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(074),C(005) MsGet oGet5  Var cNome03 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(074),C(071) MsGet oGet6  Var cEmai03 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(087),C(005) MsGet oGet7  Var cNome04 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(087),C(071) MsGet oGet8  Var cEmai04 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(100),C(005) MsGet oGet9  Var cNome05 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(100),C(071) MsGet oGet10 Var cEmai05 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(113),C(005) MsGet oGet11 Var cNome06 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(113),C(071) MsGet oGet12 Var cEmai06 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(126),C(005) MsGet oGet13 Var cNome07 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(126),C(071) MsGet oGet14 Var cEmai07 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(139),C(005) MsGet oGet15 Var cNome08 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(139),C(071) MsGet oGet16 Var cEmai08 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(152),C(005) MsGet oGet17 Var cNome09 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(152),C(071) MsGet oGet18 Var cEmai09 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(165),C(005) MsGet oGet19 Var cNome10 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA
   @ C(165),C(071) MsGet oGet20 Var cEmai10 Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA

   @ C(187),C(083) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRMA ACTION( FechaRMA() )

   ACTIVATE MSDIALOG oDlgRMA CENTERED 

Return(.T.)

// Função que grava os Usuários Liberadores do Cadastro de Produtos
Static Function FechaRMA()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_NRMA1  := cNome01
      ZZ4_NRMA2  := cNome02
      ZZ4_NRMA3  := cNome03
      ZZ4_NRMA4  := cNome04
      ZZ4_NRMA5  := cNome05
      ZZ4_NRMA6  := cNome06
      ZZ4_NRMA7  := cNome07
      ZZ4_NRMA8  := cNome08
      ZZ4_NRMA9  := cNome09
      ZZ4_NRMA10 := cNome10                        
      ZZ4_ERMA1  := cEmai01
      ZZ4_ERMA2  := cEmai02
      ZZ4_ERMA3  := cEmai03
      ZZ4_ERMA4  := cEmai04
      ZZ4_ERMA5  := cEmai05                  
      ZZ4_EMAI6  := cEmai06                  
      ZZ4_EMAI7  := cEmai07                  
      ZZ4_EMAI8  := cEmai08                  
      ZZ4_EMAI9  := cEmai09                  
      ZZ4_EMAI10 := cEmai10                                          
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_NRMA1  := cNome01
      ZZ4_NRMA2  := cNome02
      ZZ4_NRMA3  := cNome03
      ZZ4_NRMA4  := cNome04
      ZZ4_NRMA5  := cNome05
      ZZ4_NRMA6  := cNome06
      ZZ4_NRMA7  := cNome07
      ZZ4_NRMA8  := cNome08
      ZZ4_NRMA9  := cNome09
      ZZ4_NRMA10 := cNome10                        
      ZZ4_ERMA1  := cEmai01
      ZZ4_ERMA2  := cEmai02
      ZZ4_ERMA3  := cEmai03
      ZZ4_ERMA4  := cEmai04
      ZZ4_ERMA5  := cEmai05                  
      ZZ4_EMAI6  := cEmai06                  
      ZZ4_EMAI7  := cEmai07                  
      ZZ4_EMAI8  := cEmai08                  
      ZZ4_EMAI9  := cEmai09                  
      ZZ4_EMAI10 := cEmai10                                          
   Endif

   MsUnLock()

   oDlgRMA:End() 
   
Return(.T.)

// Função que abre a tela de informação dos TES de Devolução de R M A
Static Function Par_RMA()

   Local cSql := ""
   Local cRMA := Space(250)
   Local oRMA

   Private oDlgRMA

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TRMA" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cRMA := T_PARAMETROS->ZZ4_TRMA
   Endif

   DEFINE MSDIALOG oDlgRMA TITLE "TES de Demonstração" FROM C(178),C(181) TO C(289),C(655) PIXEL

   @ C(005),C(005) Say "Indique abaixo os TES que representam operações de Devolução de RMA." Size C(168),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA
   @ C(013),C(005) Say "Informe os TES separados pelo caracter |. Exemplo 999|999|999|"       Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA

   @ C(024),C(005) MsGet oRMA Var cRMA Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRMA

   @ C(038),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRMA ACTION( SaiRMA(cRMA) )

   ACTIVATE MSDIALOG oDlgRMA CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Usuários com permissão de consultar SERASA
Static Function SaiRMA(cRMA)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_TRMA   := cRMA
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_TRMA   := cRMA
   Endif

   MsUnLock()

   oDlgRMA:End() 
   
Return(.T.)

// Função que abre a tela de informação dos dados que abre arquivos externos
Static Function Par_AEXT()

   Local cSql      := ""
   Local cPrograma := Space(250)
   Local cArquivo  := Space(250)

   Local oPrograma
   Local oArquivo

   Private oDlgEXT

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_EPRG," 
   cSql += "       ZZ4_EARQ "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cPrograma := T_PARAMETROS->ZZ4_EPRG
      cArquivo  := T_PARAMETROS->ZZ4_EARQ
   Endif

   DEFINE MSDIALOG oDlgEXT TITLE "Parâmetros abertura de arquivos" FROM C(178),C(181) TO C(339),C(621) PIXEL

   @ C(005),C(005) Say "Parâmetros que serão utilizados para abertura de arquivos externos"                        Size C(160),C(008) COLOR CLR_BLACK PIXEL OF oDlgEXT
   @ C(016),C(005) Say "Abrir arquivo com o aplicativo (Incluir o endereço completo da localização do aplicativo)" Size C(209),C(008) COLOR CLR_BLACK PIXEL OF oDlgEXT
   @ C(039),C(005) Say "Arquivo a ser aberto (Incluir o endereço completo da localização do arquivo)"              Size C(183),C(008) COLOR CLR_BLACK PIXEL OF oDlgEXT
   
   @ C(026),C(005) MsGet oGet1 Var cPrograma Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEXT
   @ C(048),C(005) MsGet oGet2 Var cArquivo  Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEXT

   @ C(062),C(090) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgEXT ACTION( SaiEXT(cPrograma, cArquivo) )
   
   ACTIVATE MSDIALOG oDlgEXT CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Usuários com permissão de consultar SERASA
Static Function SaiEXT(cPrograma, cArquivo)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_EPRG   := cPrograma
      ZZ4_EARQ   := cArquivo
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_EPRG   := cPrograma
      ZZ4_EARQ   := cArquivo
   Endif
   MsUnLock()

   oDlgEXT:End() 
   
Return(.T.)

// Função que abre a tela de parâmetros de validade/encerramento de RMA
Static Function Par_VALRMA()

   Local cSql      := ""
   Local cValidade := 0
   Local cEncerrar := 0
   Local cAviso    := 0

   Local oGet1
   Local oGet2
   Local oGet3
   
   Private oDlgRMA

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_VRMA," 
   cSql += "       ZZ4_ERMA,"
   cSql += "       ZZ4_AVIS "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cValidade := T_PARAMETROS->ZZ4_VRMA
      cEncerrar := T_PARAMETROS->ZZ4_ERMA
      cAviso    := T_PARAMETROS->ZZ4_AVIS
   Endif

   DEFINE MSDIALOG oDlgRMA TITLE "Parâmetros RMA (Validade/Encerramento)" FROM C(178),C(181) TO C(309),C(461) PIXEL

   @ C(005),C(005) Say "Qtd de dias para cálculo de validade da RMA" Size C(110),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA
   @ C(019),C(005) Say "Encerrar RMA automaticamente após (Dias)"    Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA
   @ C(033),C(005) Say "Avisar Vendedor quando faltar (Dias) Vcto"   Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA

   @ C(004),C(118) MsGet oGet1 Var cValidade Size C(014),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgRMA
   @ C(018),C(118) MsGet oGet2 Var cEncerrar Size C(014),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgRMA
   @ C(032),C(118) MsGet oGet3 Var cAviso    Size C(014),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgRMA
	
   @ C(047),C(050) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRMA ACTION( SaiRMAV( cValidade, cEncerrar, cAviso ) )

   ACTIVATE MSDIALOG oDlgRMA CENTERED 

Return(.T.)

// Função que grava os parâmetros da Validade/Encerramento de RMA
Static Function SaiRMAV( _Validade, _Encerrar, _Aviso )

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_VRMA   := _Validade
      ZZ4_ERMA   := _Encerrar
      ZZ4_AVIS   := _Aviso
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_VRMA   := _Validade
      ZZ4_ERMA   := _Encerrar
      ZZ4_AVIS   := _Aviso
   Endif
   MsUnLock()

   oDlgRMA:End() 
   
Return(.T.)

// Função que abre a tela de informação de usuários que possuem autorização para lançar RA no Contas a Receber
Static Function Par_RSSCR()

   Local cSql    := ""
   Local cLancar := Space(250)
   Local oGet1

   Private oDlgRA

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LARA" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cLancar := T_PARAMETROS->ZZ4_LARA
   Endif

   DEFINE MSDIALOG oDlgRA TITLE "Autorização Lançamento de RA" FROM C(178),C(181) TO C(306),C(654) PIXEL

   @ C(005),C(005) Say "Informe o Login dos usuários que possuem autorização para realizar" Size C(161),C(008) COLOR CLR_BLACK PIXEL OF oDlgRA
   @ C(013),C(005) Say "lançamentos de RA no Módulo Contas a Receber."                      Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlgRA
   @ C(022),C(005) Say "Informar da seguinte maneira: joao|pedro|maria|"                    Size C(123),C(008) COLOR CLR_BLACK PIXEL OF oDlgRA

   @ C(033),C(005) MsGet oGet1 Var cLancar Size C(224),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRA

   @ C(047),C(098) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRA ACTION( SaiLARA( cLancar ) )

   ACTIVATE MSDIALOG oDlgRA CENTERED 

Return(.T.)

// Função que grava os parâmetros da Validade/Encerramento de RMA
Static Function SaiLARA( _Lancar )

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_LARA   := _Lancar
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_LARA   := _Lancar
   Endif
   MsUnLock()

   oDlgRA:End() 
   
Return(.T.)

// Função que abre a tela de solicitação dos Grupos que NÃO PODEM CONSULTAR PREÇOS pelo cadastro de produtos
Static Function Par_LibPreco()

   Local cSql      := ""
   Local cLibPreco := Space(250)
   Local oLibPreco

   Private oDlgPre

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LIBP" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cLibPreco := T_PARAMETROS->ZZ4_LIBP
   Endif

   DEFINE MSDIALOG oDlgPre TITLE "Sem Acesso a Consulta de Preços pelo Cadastro de Produtos" FROM C(178),C(181) TO C(289),C(655) PIXEL

   @ C(005),C(005) Say "Indique abaixo os Grupos que NÃO DEVEM TER ACESSO A CONSULTA DE PREÇO pelo Cadastro de Produtos." Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlgPre
   @ C(013),C(005) Say "Informe os Grupos separados pelo caracter |. Exemplo 999999|999999|999999|"                       Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgPre

   @ C(024),C(005) MsGet oLibPreco Var cLibPreco Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPre

   @ C(038),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgPre ACTION( SaiLprec(cLibPreco) )

   ACTIVATE MSDIALOG oDlgPre CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Grupos que não possuem Acessos a Preços pelo Cadastro de Produtos
Static Function SaiLPrec(cLibPreco)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_LIBP   := cLibPreco
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_LIBP   := cLibPreco
   Endif

   MsUnLock()

   oDlgPre:End() 
   
Return(.T.) 

// Função que abre a tela de solicitação dos Grupos que podem alterar o campo TES do Pedido de Venda
Static Function Par_TESVDA()

   Local cSql       := ""
   Local cTESPedido := Space(250)
   Local oTESPedido

   Private oDlgPre

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TESP" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cTESPedido := T_PARAMETROS->ZZ4_TESP
   Endif

   DEFINE MSDIALOG oDlgPre TITLE "Grupo que possuem permissão alterar campo TES do Pedido de Venda" FROM C(178),C(181) TO C(289),C(655) PIXEL

   @ C(005),C(005) Say "Indique abaixo os Grupos que podem alterar o campo TES do Pedido de Venda." Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlgPre
   @ C(013),C(005) Say "Informe os Grupos separados pelo caracter |. Exemplo 999999|999999|999999|" Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgPre

   @ C(024),C(005) MsGet oTESPedido Var cTESPedido Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPre

   @ C(038),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgPre ACTION( SaiTESPedido(cTESPedido) )

   ACTIVATE MSDIALOG oDlgPre CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Grupos que não possuem Acessos a Preços pelo Cadastro de Produtos
Static Function SaiTESPedido(cTESPedido)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_TESP   := cTESPedido
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_TESP   := cTESPedido
   Endif

   MsUnLock()

   oDlgPre:End() 
   
Return(.T.)

// Função que abre a tela de informação dos CFOPs a serem consistidos
Static Function VerCFOPS()

   Local cSql     := ""
   Local cVenda   := ""
   Local cRemessa := ""

   Local oMemo1
   Local oMemo2

   Private oDlgCFOP

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CFPV)) AS VENDA  ," 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CFPR)) AS REMESSA "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cVenda   := T_PARAMETROS->VENDA
      cRemessa := T_PARAMETROS->REMESSA
   Endif

   DEFINE MSDIALOG oDlgCFOP TITLE "Validação CFOP " FROM C(178),C(181) TO C(516),C(683) PIXEL

   @ C(005),C(005) Say "Informe abaixo os CFOPS que deverão ser consistidos nos processos de venda."                   Size C(193),C(008) COLOR CLR_BLACK PIXEL OF oDlgCFOP
   @ C(013),C(005) Say "Somente poderá ser elaborado documentos de venda pelo conjunto dos CFOPs abaixo relacionados." Size C(239),C(008) COLOR CLR_BLACK PIXEL OF oDlgCFOP
   @ C(025),C(005) Say "CFOPs de Venda"                                                                                Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgCFOP
   @ C(084),C(005) Say "CFOPs de Remessa"                                                                              Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlgCFOP
   @ C(140),C(005) Say "ATENÇÃO! Os CFOPs deverão ser informados sendo eles separados pelo caracter | (Pipe)"          Size C(216),C(008) COLOR CLR_RED   PIXEL OF oDlgCFOP

   @ C(034),C(005) GET oMemo1 Var cVenda   MEMO Size C(239),C(044) PIXEL OF oDlgCFOP
   @ C(092),C(005) GET oMemo2 Var cRemessa MEMO Size C(239),C(044) PIXEL OF oDlgCFOP

   @ C(152),C(207) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCFOP ACTION( SaiTelaCfop(cVenda, cRemessa) )

   ACTIVATE MSDIALOG oDlgCFOP CENTERED 

Return(.T.)

// Função que grava os parâmetros dos Grupos que não possuem Acessos a Preços pelo Cadastro de Produtos
Static Function SaiTelaCfop(cVenda, cRemessa)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_CFPV   := cVenda
      ZZ4_CFPR   := cRemessa
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_CFPV   := cVenda
      ZZ4_CFPR   := cRemessa
   Endif

   MsUnLock()

   oDlgCFOP:End() 
   
Return(.T.)

// Função que abre tela de informação das naturezas de serviços para a Lei da Transparência de Notas Fiscais de Serviços
Static Function LeiTransp()

   Local cSql   := ""
   Local cMemo1 := ""
   Local oMemo1

   Private cNatTecnica := Space(250)
   Private cNatProjeto := Space(250)
   Private cNatAgencia := Space(250)   

   Private oGet1
   Private oGet2
   Private oGet3   

   Private oDlgLei

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_NATT, "
   cSql += "       ZZ4_NATP, "
   cSql += "       ZZ4_NATA  "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cNatTecnica := T_PARAMETROS->ZZ4_NATT
      cNatProjeto := T_PARAMETROS->ZZ4_NATP
      cNatAgencia := T_PARAMETROS->ZZ4_NATA
   Endif

   DEFINE MSDIALOG oDlgLei TITLE "Naturezas de Serviços" FROM C(178),C(181) TO C(429),C(717) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgLei

   @ C(030),C(002) GET oMemo1 Var cMemo1 MEMO Size C(260),C(001) PIXEL OF oDlgLei

   @ C(036),C(005) Say "Informe as Naturezas de Serviços (Assistência Técnica) para cálculo Tributos Aproximados - NF Serviço" Size C(247),C(008) COLOR CLR_BLACK PIXEL OF oDlgLei
   @ C(059),C(005) Say "Informe as Naturezas de Serviços (Projetos) para cálculo Tributos Aproximados - NF Serviço"            Size C(219),C(008) COLOR CLR_BLACK PIXEL OF oDlgLei
   @ C(081),C(005) Say "Informe as Naturezas de serviços (Agenciamento) para cálculo Tributos Aproximados - NF Serviço"        Size C(233),C(008) COLOR CLR_BLACK PIXEL OF oDlgLei
   
   @ C(046),C(005) MsGet oGet1 Var cNatTecnica Size C(256),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLei
   @ C(068),C(005) MsGet oGet2 Var cNatProjeto Size C(256),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLei
   @ C(091),C(005) MsGet oGet3 Var cNatAgencia Size C(256),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLei

   @ C(107),C(114) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLei ACTION( SALVALEI() )

   ACTIVATE MSDIALOG oDlgLei CENTERED 

Return(.T.)

// Função que grava os parâmetros das naturezas de serviços de assistência técnica e projetos
Static Function SalvaLei()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_NATT   := cNatTecnica
      ZZ4_NATP   := cNatProjeto
      ZZ4_NATA   := cNatAgencia
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_NATT   := cNatTecnica
      ZZ4_NATP   := cNatProjeto
      ZZ4_NATA   := cNatAgencia
   Endif

   MsUnLock()

   oDlgLei:End() 
   
Return(.T.)

// Função que abre a janela para informação dos produtos genéricos
Static Function Pro_Gene()

   Local cSql      := ""
   Local cGenerico := Space(250)
   Local cMemo1	   := ""
   Local oGet1
   Local oMemo1

   Private oDlgGen

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GENE "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cGenerico := T_PARAMETROS->ZZ4_GENE
   Endif

   DEFINE MSDIALOG oDlgGen TITLE "Produtos Genéricos" FROM C(178),C(181) TO C(378),C(627) PIXEL
   
   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgGen

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(215),C(001) PIXEL OF oDlgGen

   @ C(036),C(005) Say "Informe abaixo os códigos dos produtos que não poderão ser utilizados na efetivação" Size C(202),C(008) COLOR CLR_BLACK PIXEL OF oDlgGen
   @ C(045),C(005) Say "de Ordens de Serviço bem como em documentos de entrada."                             Size C(146),C(008) COLOR CLR_BLACK PIXEL OF oDlgGen
   @ C(054),C(005) Say "Utilizar o caracter (Pipe) para separar os códigos: Exemplo:  999999|999999|"        Size C(183),C(008) COLOR CLR_BLACK PIXEL OF oDlgGen

   @ C(066),C(005) MsGet oGet1 Var cGenerico Size C(211),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgGen

   @ C(082),C(091) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgGen ACTION( SalvaGen(cGenerico) )

   ACTIVATE MSDIALOG oDlgGen CENTERED 

Return(.T.)

// Função que grava os parâmetros das naturezas de serviços de assistência técnica e projetos
Static Function SalvaGen(_Generico)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_GENE   := _Generico
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_GENE   := _Generico
   Endif

   MsUnLock()

   oDlgGen:End() 
   
Return(.T.)

// Função que abre a janela para informação dos parâmetros do Contrato de Locação
Static Function Pro_Locacao()

   Local cSql       := ""
   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1
   
   Private cAcessos   := Space(250)
   Private cContrato  := Space(250)
   Private cRecibo    := Space(250)
   Private cTipoPoa   := Space(250)
   Private cTipoCur   := Space(250)
   Private cTipoAte   := Space(250)
   Private cProduto   := Space(06)
   Private cDescricao := Space(60)
   Private cTES	      := Space(03)
   Private cNomeTES   := Space(40)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11

   Private oDlgLoc

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ACON, "
   cSql += "       ZZ4_WORD, "
   cSql += "       ZZ4_PRAZ, "
   cSql += "       ZZ4_RECI, "
   cSql += "       ZZ4_TPOA, "
   cSql += "       ZZ4_TCUR, "
   cSql += "       ZZ4_TATE, "
   cSql += "       ZZ4_LPRO, "
   cSql += "       ZZ4_LTES  "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cAcessos   := T_PARAMETROS->ZZ4_ACON
      cContrato  := T_PARAMETROS->ZZ4_WORD
      cLprazo    := T_PARAMETROS->ZZ4_PRAZ
      cRecibo    := T_PARAMETROS->ZZ4_RECI
      cTipoPoa   := T_PARAMETROS->ZZ4_TPOA
      cTipoCur   := T_PARAMETROS->ZZ4_TCUR
      cTipoAte   := T_PARAMETROS->ZZ4_TATE
      cProduto   := T_PARAMETROS->ZZ4_LPRO
      cDescricao := Posicione("SB1", 1, xFilial("SB1") + cProduto + Space(24) , "B1_DESC")
      cTES       := T_PARAMETROS->ZZ4_LTES
      cNomeTES   := Posicione("SF4", 1, xFilial("SF4") + cTES, "F4_TEXTO")
   Endif

   DEFINE MSDIALOG oDlgLoc TITLE "Parâmetros de Contratos de Locação" FROM C(178),C(181) TO C(606),C(903) PIXEL

   @ C(002),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgLoc

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(351),C(001) PIXEL OF oDlgLoc

   @ C(037),C(005) Say "Usuários com acesso ao módulo de contratos (Utilizado para dar acesso aos contratos gerados)"             Size C(228),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(045),C(005) Say "Informe o código de login dos usuário separados pelo caracter [ PIPE ]. Exemplo: 000001|000002|000003|"   Size C(251),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(068),C(005) Say "Arquivo Contrato Tradicional (Formato .DOT)"                                                              Size C(118),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(068),C(183) Say "Arquivo Contrato Longo Prazo (Formato .DOT)"                                                              Size C(112),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(091),C(005) Say "Arquivo do Recibo de Quitação de Parcelas (Formato .DOT)"                                                 Size C(145),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(116),C(005) Say "Código de Contrato de Locação. Informe a Filial e o código do Tipo de Contrato de Locação para a filial." Size C(252),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(126),C(234) Say "ATECH"                                                                                                    Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(127),C(005) Say "Porto Alegre/Caxias do Sul/Pelotas e Suprimentos"                                                         Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(127),C(133) Say "TI AUTOMAÇÃO"                                                                                             Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(150),C(005) Say "Produto a ser utilizado na planilha para contratos de locação"                                            Size C(145),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
   @ C(172),C(005) Say "TES a ser utilizado na planilha para contratos de locação"                                                Size C(139),C(008) COLOR CLR_BLACK PIXEL OF oDlgLoc
		   
   @ C(055),C(005) MsGet oGet1  Var cAcessos   Size C(351),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc
   @ C(078),C(005) MsGet oGet2  Var cContrato  Size C(173),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc
   @ C(078),C(183) MsGet oGet7  Var cLprazo    Size C(173),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc
   @ C(101),C(005) MsGet oGet3  Var cRecibo    Size C(351),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc
   @ C(136),C(005) MsGet oGet4  Var cTipoPoa   Size C(123),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc
   @ C(136),C(134) MsGet oGet5  Var cTipoCur   Size C(094),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc
   @ C(136),C(234) MsGet oGet6  Var cTipoAte   Size C(122),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc
   @ C(159),C(005) MsGet oGet8  Var cProduto   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc F3("SB1") VALID( BuscaCad(1, cProduto))
   @ C(159),C(048) MsGet oGet9  Var cDescricao Size C(308),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba
   @ C(181),C(005) MsGet oGet10 Var cTES       Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc F3("SF4") VALID( BuscaCad(2, cTES) )
   @ C(181),C(048) MsGet oGet11 Var cNomeTES   Size C(308),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLoc When lChumba

   @ C(196),C(165) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLoc  ACTION( SalvaLoc( cAcessos, cContrato, cRecibo, cTipoPoa, cTipoCur, cTipoAte, cLprazo, cProduto, cTES ) )

   ACTIVATE MSDIALOG oDlgLoc CENTERED 

Return(.T.)

// Função que pesquisa produtos e TES da tela de locação
Static Function BuscaCad(_TipoCad, _Codigo)

   If Empty(Alltrim(_Codigo))
      Return(.T.)
   Endif   

   If _TipoCad == 1
      cDescricao := Posicione("SB1", 1, xFilial("SB1") + _Codigo + Space(24), "B1_DESC") 
      oGet9:Refresh()
   Else
      cNomeTES   := Posicione("SF4", 1, xFilial("SF4") + _Codigo, "F4_TEXTO")
      oGet11:Refresh()
   Endif
   
Return(.T.)

// Função que grava os parâmetros dos contratos de locação
Static Function SalvaLoc(_Acessos, _Contrato, _Recibo, _TipoPoa, _TipoCur, _TipoAte, _Lprazo, _Produto, _TES)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_ACON   := _Acessos
      ZZ4_WORD   := _Contrato
      ZZ4_PRAZ   := _Lprazo
      ZZ4_RECI   := _Recibo
      ZZ4_TPOA   := _TipoPoa
      ZZ4_TCUR   := _TipoCur
      ZZ4_TATE   := _TipoAte
      ZZ4_LPRO   := _Produto
      ZZ4_LTES   := _TES
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_ACON   := _Acessos
      ZZ4_WORD   := _Contrato
      ZZ4_PRAZ   := _Lprazo
      ZZ4_RECI   := _Recibo
      ZZ4_TPOA   := _TipoPoa
      ZZ4_TCUR   := _TipoCur
      ZZ4_TATE   := _TipoAte
      ZZ4_LPRO   := _Produto
      ZZ4_LTES   := _TES
   Endif

   MsUnLock()

   oDlgLoc:End() 
   
Return(.T.)

// Função que abre a janela para informação dos parâmetros do CTe - Conhecimento de Transporte
Static Function Pro_CTEFRETE()

   Local cSql         := ""
   Local lChumba      := .F.
   Local cMemo1	      := ""
   Local oMemo1
      
   Private cPro1	  := Space(30)
   Private cNPro1     := Space(60)
   Private cPro2	  := Space(30)
   Private cNPro2     := Space(60)
   Private cCondicao  := Space(06)
   Private cNomeCondi := Space(60)
   Private cTESsICM   := Space(03)
   Private cNomeTESs  := Space(60)
   Private cTEScICM   := Space(03)
   Private cNomeTESc  := Space(60)
   Private cDiretorio := Space(250)
   Private cNatureza  := Space(10)
   Private cNomeNatu  := Space(60)
   Private cCustoP    := Space(09)
   Private cNomeCP    := Space(60)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11   
   Private oGet12   
   Private oGet13   
   Private oGet14      
   Private oGet15   

   Private oDlgCTE

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_PCTE, "
   cSql += "       ZZ4_PCT1, "
   cSql += "       ZZ4_DCTE, "
   cSql += "       ZZ4_SCTE, "
   cSql += "       ZZ4_CCTE, "
   cSql += "       ZZ4_DXML, "
   cSql += "       ZZ4_NATC, "   
   cSql += "       ZZ4_CCUS  "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cPro1  	 := T_PARAMETROS->ZZ4_PCTE
      cNPro1     := Posicione("SB1", 1, xFilial("SB1") + cPro1    , "B1_DESC")
      cPro2      := T_PARAMETROS->ZZ4_PCT1
      cNPro2     := Posicione("SB1", 1, xFilial("SB1") + cPro2    , "B1_DESC")
      cCondicao	 := T_PARAMETROS->ZZ4_DCTE
      cNomeCondi := Posicione("SE4", 1, xFilial("SE4") + cCondicao, "E4_DESCRI")
      cTESsICM   := T_PARAMETROS->ZZ4_SCTE
      cNomeTESs	 := Posicione("SF4", 1, xFilial("SF4") + cTESsICM , "F4_TEXTO")
      cTEScICM   := T_PARAMETROS->ZZ4_CCTE
      cNomeTESc	 := Posicione("SF4", 1, xFilial("SF4") + cTEScICM , "F4_TEXTO")
      cDiretorio := T_PARAMETROS->ZZ4_DXML
      cNatureza  := T_PARAMETROS->ZZ4_NATC
      cNomeNatu  := Posicione("SED", 1, xFilial("SED") + cNatureza , "ED_DESCRIC")
      cCustoP    := T_PARAMETROS->ZZ4_CCUS
      cNomeCP    := Posicione("CTT", 1, xFilial("CTT") + cCustoP, "CTT_DESC01")
   Endif

   // Desenha a tela 
   DEFINE MSDIALOG oDlgCTE TITLE "Parâmetros Importação CTE's - Conhecimento de Transporte" FROM C(178),C(181) TO C(626),C(738) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(030) PIXEL NOBORDER OF oDlgCTE

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(270),C(001) PIXEL OF oDlgCTE

   @ C(042),C(005) Say "Produto frete para notas fiscais de entrada"   Size C(102),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
   @ C(064),C(005) Say "Produto frere para notas fiscais de saída"     Size C(105),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
   @ C(086),C(005) Say "Condição de Pagamento"                         Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
   @ C(108),C(005) Say "TES para CTE's sem cálculo de icms"            Size C(095),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
   @ C(131),C(005) Say "TES para CTE's com cálculo de icms"            Size C(091),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
   @ C(153),C(005) Say "Diretório dos arquivos XML a serem importados" Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
   @ C(176),C(005) Say "Natureza"                                      Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
   @ C(199),C(005) Say "Centro de Custo padrão"                        Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTE
	
   @ C(051),C(005) MsGet oGet1  Var cPro1      Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE F3("SB1") VALID( AlimentaT(1, cPro1) )
   @ C(051),C(043) MsGet oGet2  Var cNPro1     Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE When lChumba
   @ C(073),C(005) MsGet oGet3  Var cPro2      Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE F3("SB1") VALID( AlimentaT(5, cPro2) )
   @ C(073),C(043) MsGet oGet4  Var cNPro2     Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE When lChumba
   @ C(096),C(005) MsGet oGet5  Var cCondicao  Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE F3("SE4") VALID( AlimentaT(2, cCondicao) )
   @ C(096),C(043) MsGet oGet6  Var cNomeCondi Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE When lChumba
   @ C(118),C(005) MsGet oGet7  Var cTESsICM   Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE F3("SF4") VALID( AlimentaT(3, cTESsICM) )
   @ C(118),C(043) MsGet oGet8  Var cNomeTesS  Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE When lChumba
   @ C(140),C(005) MsGet oGet9  Var cTEScICM   Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE F3("SF4") VALID( AlimentaT(4, cTEScICM) )
   @ C(140),C(043) MsGet oGet10 Var cNomeTesC  Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE When lChumba
   @ C(163),C(005) MsGet oGet11 Var cDiretorio Size C(266),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE
   @ C(186),C(005) MsGet oGet12 Var cNatureza  Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE F3("SED") VALID( AlimentaT(6, cNatureza) )
   @ C(186),C(043) MsGet oGet13 Var cNomeNatu  Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE When lChumba
   @ C(209),C(005) MsGet oGet14 Var cCustoP    Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE F3("CTT") VALID( AlimentaT(7, cCustoP) )
   @ C(209),C(043) MsGet oGet15 Var cNomeCP    Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTE When lChumba

   @ C(207),C(233) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCTE ACTION( GravaCTE(cPro1, cPro2, cCondicao, cTESsICM, cTEScICM, cDiretorio, cNatureza, cCustoP) )

   ACTIVATE MSDIALOG oDlgCTE CENTERED 

Return(.T.)

// Função que pesquisa os dados para popular a tela
Static Function AlimentaT(__Tipo, __Codigo)

   Do Case 
      Case __Tipo == 1
          If Empty(Alltrim(__Codigo))
             cNPro1 := Space(60)
          Else
             cNPro1 := Posicione("SB1", 1, xFilial("SB1") + __Codigo , "B1_DESC")
          Endif
          oGet2:Refresh()             
      Case __Tipo == 2
          If Empty(Alltrim(__Codigo))
             cNomeCondi   := Space(60)
          Else   
             cNomeCondi   := Posicione("SE4", 1, xFilial("SE4") + __Codigo , "E4_DESCRI")
          Endif   
          oGet6:Refresh()             
      Case __Tipo == 3
          If Empty(Alltrim(__Codigo))
             cNomeTESs := Space(60)
          Else
             cNomeTESs := Posicione("SF4", 1, xFilial("SF4") + __Codigo , "F4_TEXTO")
          Endif   
          oGet8:Refresh()
      Case __Tipo == 4
          If Empty(Alltrim(__Codigo))
             cNomeTESc := Space(60)
          Else
             cNomeTESc := Posicione("SF4", 1, xFilial("SF4") + __Codigo , "F4_TEXTO")
          Endif
          oGet10:Refresh()
      Case __Tipo == 5
          If Empty(Alltrim(__Codigo))
             cNPro2 := Space(60)
          Else
             cNPro2 := Posicione("SB1", 1, xFilial("SB1") + __Codigo , "B1_DESC")
          Endif
          oGet4:Refresh()             
      Case __Tipo == 6
          If Empty(Alltrim(__Codigo))
             cNomeNatu := Space(60)
          Else
             cNomeNatu := Posicione("SED", 1, xFilial("SED") + __Codigo , "ED_DESCRIC")
          Endif
          oGet13:Refresh()             

      Case __Tipo == 7
          If Empty(Alltrim(__Codigo))
             cNomeCP := Space(60)
          Else
             cNomeCP := Posicione("CTT", 1, xFilial("CTT") + __Codigo , "CTT_DESC01")
          Endif
          oGet15:Refresh()             
   EndCase

Return(.T.)   
   
// Função que grava os parâmetros dos contratos de locação
Static Function GravaCTE(__cPro1, __CPro2, __cCondicao, __cTESsICM, __cTEScICM, __cDiretorio, __cNatureza, __cCustoP)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_PCTE   := __cPro1
      ZZ4_PCT1   := __cPro2
      ZZ4_DCTE   := __cCondicao
      ZZ4_SCTE   := __cTESsICM
      ZZ4_CCTE   := __cTEScICM
      ZZ4_DXML   := __cDiretorio
      ZZ4_NATC   := __cNatureza
      ZZ4_CCUS   := __cCustoP
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_PCTE   := __cPro1
      ZZ4_PCT1   := __cPro2
      ZZ4_DCTE   := __cCondicao
      ZZ4_SCTE   := __cTESsICM
      ZZ4_CCTE   := __cTEScICM
      ZZ4_DXML   := __cDiretorio
      ZZ4_NATC   := __cNatureza
      ZZ4_CCUS   := __cCustoP
   Endif

   MsUnLock()

   oDlgCTE:End() 
   
Return(.T.)

// Função que abre a janela para informação da localização dos arquivos word
Static Function Pro_ARQWORD()

   Local cArq01 := Space(250)
   Local cArq02 := Space(250)
   Local cArq03 := Space(250)
   Local cArq04 := Space(250)
   Local cArq05 := Space(250)
   Local cArq06 := Space(250)
   Local cMemo1	:= ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oMemo1

   Private oDlgWord

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_WA01, "
   cSql += "       ZZ4_WA02, "
   cSql += "       ZZ4_WA03, "
   cSql += "       ZZ4_WA04, "
   cSql += "       ZZ4_WA05, "
   cSql += "       ZZ4_WA06  "   
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cArq01 := T_PARAMETROS->ZZ4_WA01
      cArq02 := T_PARAMETROS->ZZ4_WA02
      cArq03 := T_PARAMETROS->ZZ4_WA03
      cArq04 := T_PARAMETROS->ZZ4_WA04
      cArq05 := T_PARAMETROS->ZZ4_WA05
      cArq06 := T_PARAMETROS->ZZ4_WA06                        
   Endif

   DEFINE MSDIALOG oDlgWord TITLE "Documentos WORD" FROM C(178),C(181) TO C(585),C(789) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"                                                     Size C(134),C(026) PIXEL NOBORDER OF oDlgWord
   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO                                                     Size C(298),C(001) PIXEL OF oDlgWord
   @ C(037),C(005) Say "Indique abaixo a localização dos arquivos no formato Word para impressão" Size C(179),C(008) COLOR CLR_BLACK PIXEL OF oDlgWord
   @ C(050),C(005) Say "Arquivo de Projetos - Proposta Comercial"                                 Size C(098),C(008) COLOR CLR_BLACK PIXEL OF oDlgWord
   @ C(073),C(005) Say "Reservado 1" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgWord
   @ C(095),C(005) Say "Reservado 2" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgWord
   @ C(117),C(005) Say "Reservado 3" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgWord
   @ C(139),C(005) Say "Reservado 4" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgWord
   @ C(160),C(005) Say "Reservado 5" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgWord

   @ C(060),C(005) MsGet oGet1 Var cArq01 Size C(292),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgWord
   @ C(082),C(005) MsGet oGet2 Var cArq02 Size C(292),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgWord
   @ C(104),C(005) MsGet oGet3 Var cArq03 Size C(292),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgWord
   @ C(126),C(005) MsGet oGet4 Var cArq04 Size C(292),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgWord
   @ C(147),C(005) MsGet oGet5 Var cArq05 Size C(292),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgWord
   @ C(169),C(005) MsGet oGet6 Var cArq06 Size C(292),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgWord
   @ C(186),C(132) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlgWord ACTION( GRAVAWORD(cArq01, cArq02, cArq03, cArq04, cArq05, cArq06 ) ) 

   ACTIVATE MSDIALOG oDlgWord CENTERED 

Return(.T.)

// Função que grava os parâmetros dos arquivos word a serem utilizados para impressão
Static Function GravaWORD(_Arq01, _Arq02, _Arq03, _Arq04, _Arq05, _Arq06 )

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_WA01   := _Arq01
      ZZ4_WA02   := _Arq02
      ZZ4_WA03   := _Arq03
      ZZ4_WA04   := _Arq04
      ZZ4_WA05   := _Arq05
      ZZ4_WA06   := _Arq06
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_WA01   := _Arq01
      ZZ4_WA02   := _Arq02
      ZZ4_WA03   := _Arq03
      ZZ4_WA04   := _Arq04
      ZZ4_WA05   := _Arq05
      ZZ4_WA06   := _Arq06
   Endif

   MsUnLock()

   oDlgWord:End() 
   
Return(.T.)

// Função que pesquisa o nome da tabeal de preço informada
Static Function xxxPro_SHOP()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private aAmbiente := { "0 - Nenhum", "1 - Homologação", "2 - Produção" }
   Private cURLH     := Space(250)
   Private cCHVH     := Space(250)
   Private cUSUH     := Space(50)
   Private cSHOW     := Space(50)
   Private cENDLH    := Space(250)
   Private cENDAH    := Space(250)
   Private cLOGINH   := Space(50)
   Private cSENHALH  := Space(50)
   Private cURLP     := Space(250)
   Private cCHVP     := Space(250)
   Private cUSUP     := Space(50)
   Private cSENP     := Space(50)
   Private cENDLP    := Space(250)
   Private cENDAP    := Space(250)
   Private cLOGINP   := Space(50)
   Private cSENHALP  := Space(50)
   Private cTABELA   := Space(03)
   Private cNOMETAB  := Space(40)
   Private cARQDLL   := Space(20)
   Private cXcaminho := Space(250)
   
   Private cComboBx1
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
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
 
   Private oDlgShop

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4.ZZ4_URLH,"
   cSql += "       ZZ4.ZZ4_CHVH,"
   cSql += "       ZZ4.ZZ4_USUH,"
   cSql += "       ZZ4.ZZ4_SHOM,"
   cSql += "       ZZ4.ZZ4_EDLH,"
   cSql += "       ZZ4.ZZ4_EDAH,"
   cSql += "       ZZ4.ZZ4_LOGH,"
   cSql += "       ZZ4.ZZ4_SLOH,"
   cSql += "       ZZ4.ZZ4_URLP,"
   cSql += "       ZZ4.ZZ4_CHVP,"
   cSql += "       ZZ4.ZZ4_USUP,"
   cSql += "       ZZ4.ZZ4_SENP,"
   cSql += "       ZZ4.ZZ4_EDLP,"
   cSql += "       ZZ4.ZZ4_EDAP,"
   cSql += "       ZZ4.ZZ4_LOGP,"
   cSql += "       ZZ4.ZZ4_SLOP,"
   cSql += "       ZZ4.ZZ4_TABE,"
   cSql += "       ZZ4.ZZ4_AVIR,"
   cSql += "       ZZ4.ZZ4_ADLL,"
   cSql += "       ZZ4.ZZ4_CSLV,"
   cSql += "       DA0.DA0_DESCRI"
   cSql += "  FROM " + RetSqlName("ZZ4") + " ZZ4, "
   cSql += "       " + RetSqlName("DA0") + " DA0  "
   cSql += " WHERE ZZ4_TABE = DA0.DA0_CODTAB"
   cSql += "   AND DA0.DA0_ATIVO  = '1'"  
   cSql += "   AND DA0.D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cURLH     := T_PARAMETROS->ZZ4_URLH
      cCHVH     := T_PARAMETROS->ZZ4_CHVH
      cUSUH     := T_PARAMETROS->ZZ4_USUH
      cSHOW     := T_PARAMETROS->ZZ4_SHOM
      cENDLH    := T_PARAMETROS->ZZ4_EDLH
      cENDAH    := T_PARAMETROS->ZZ4_EDAH
      cLOGINH   := T_PARAMETROS->ZZ4_LOGH
      cSENHALH  := T_PARAMETROS->ZZ4_SLOH
      cURLP     := T_PARAMETROS->ZZ4_URLP
      cCHVP     := T_PARAMETROS->ZZ4_CHVP
      cUSUP     := T_PARAMETROS->ZZ4_USUP
      cSENP     := T_PARAMETROS->ZZ4_SENP
      cENDLP    := T_PARAMETROS->ZZ4_EDLP
      cENDAP    := T_PARAMETROS->ZZ4_EDAP
      cLOGINP   := T_PARAMETROS->ZZ4_LOGP
      cSENHALP  := T_PARAMETROS->ZZ4_SLOP
      cTABELA   := T_PARAMETROS->ZZ4_TABE
      cNOMETAB  := T_PARAMETROS->DA0_DESCRI
      cARQDLL   := T_PARAMETROS->ZZ4_ADLL
      cXcaminho := T_PARAMETROS->ZZ4_CSLV

      Do Case
         Case T_PARAMETROS->ZZ4_AVIR = "0"
              cComboBx1 := "0 - Nenhum"
         Case T_PARAMETROS->ZZ4_AVIR = "1"
              cComboBx1 := "1 - Homologação"
         Case T_PARAMETROS->ZZ4_AVIR = "2"
              cComboBx1 := "2 - Produção"
      EndCase              
   Endif

   DEFINE MSDIALOG oDlgShop TITLE "Parâmetros Acesso Loja Virtual" FROM C(178),C(181) TO C(634),C(863) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgShop

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(330),C(001) PIXEL OF oDlgShop
   @ C(120),C(005) GET oMemo2 Var cMemo2 MEMO Size C(330),C(001) PIXEL OF oDlgShop
   @ C(209),C(005) GET oMemo3 Var cMemo3 MEMO Size C(330),C(001) PIXEL OF oDlgShop

   @ C(007),C(195) Say "Ambiente Configurado"                       Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(036),C(005) Say "H O M O L O G A Ç Ã O"                      Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(048),C(005) Say "URL do Integrador"                          Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(059),C(005) Say "Chave de Integração"                        Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(071),C(005) Say "Acesso Loja Homologação"                    Size C(065),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(071),C(079) Say "Usuário"                                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(071),C(182) Say "Senha"                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(083),C(005) Say "Endereço Homologação Loja"                  Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(096),C(005) Say "Endereço Homologação Painel Administrativo" Size C(109),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(107),C(005) Say "Login"                                      Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(107),C(118) Say "Senha"                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(124),C(005) Say "P R O D U Ç Ã O"                            Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(136),C(005) Say "URL do Integrador"                          Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(148),C(005) Say "Chave de Integração"                        Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(160),C(005) Say "Acesso Loja Produção"                       Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(160),C(079) Say "Usuário"                                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(160),C(182) Say "Senha"                                      Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(172),C(005) Say "Endereço Produção Loja"                     Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(184),C(005) Say "Endereço Produção Painel Administrativo"    Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(196),C(005) Say "Login"                                      Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(196),C(118) Say "Senha"                                      Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(150),C(005) Say "Tabela de Preço"                            Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(215),C(223) Say "DLL"                                        Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(170),C(005) Say "T E S"                                      Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(170),C(160) Say "Usuários com permissão para importar Pedidos de Vendas ( F1 X AUTOMATECH)" Size C(195),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop

   @ C(016),C(195) ComboBox cComboBx1 Items aAmbiente      Size C(140),C(010)                              PIXEL OF oDlgShop
   @ C(047),C(059) MsGet    oGet1     Var   cURLH          Size C(276),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(059),C(059) MsGet    oGet2     Var   cCHVH          Size C(276),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(071),C(102) MsGet    oGet3     Var   cUSUH          Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(071),C(203) MsGet    oGet4     Var   cSHOW          Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(083),C(078) MsGet    oGet5     Var   cENDLH         Size C(213),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(095),C(118) MsGet    oGet6     Var   cENDAH         Size C(174),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(107),C(022) MsGet    oGet7     Var   cLOGINH        Size C(090),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(107),C(138) MsGet    oGet8     Var   cSENHALH       Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(135),C(059) MsGet    oGet9     Var   cURLP          Size C(276),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(147),C(059) MsGet    oGet10    Var   cCHVP          Size C(276),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(159),C(102) MsGet    oGet11    Var   cUSUP          Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(159),C(203) MsGet    oGet12    Var   cSENP          Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(171),C(078) MsGet    oGet13    Var   cENDLP         Size C(213),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(183),C(118) MsGet    oGet14    Var   cENDAP         Size C(174),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(195),C(022) MsGet    oGet15    Var   cLOGINP        Size C(090),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(195),C(139) MsGet    oGet16    Var   cSENHALP       Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(214),C(067) MsGet    oGet17    Var   cTABELA        Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop F3("DA0") VALID( PsqTabPre(cTabela))
   @ C(214),C(094) MsGet    oGet18    Var   cNOMETAB       Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop When lChumba
   @ C(214),C(238) MsGet    oGet19    Var   cArqDll        Size C(054),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(195),C(254) Button "Arquivo Produtos Salvar em ..." Size C(081),C(012) PIXEL OF oDlgShop ACTION( SALVAARQF1(cXcaminho) )
   @ C(195),C(087) Button "% Sobre Preço"                  Size C(045),C(012) PIXEL OF oDlgShop

   @ C(083),C(295) Button   "Testar" Size C(041),C(009) PIXEL OF oDlgShop ACTION( ChamaTeste(cENDLH) )
   @ C(095),C(295) Button   "Testar" Size C(041),C(009) PIXEL OF oDlgShop ACTION( ChamaTeste(cENDAH) )
   @ C(171),C(295) Button   "Testar" Size C(041),C(009) PIXEL OF oDlgShop ACTION( ChamaTeste(cENDLP) )
   @ C(183),C(295) Button   "Testar" Size C(041),C(009) PIXEL OF oDlgShop ACTION( ChamaTeste(cENDAP) )

   @ C(212),C(295) Button "Voltar" Size C(041),C(012) PIXEL OF oDlgShop ACTION( GravaSHOP() )
   
   ACTIVATE MSDIALOG oDlgShop CENTERED 

Return(.T.)
// HAHAHAHAHAHAHAHAHAHAHA

// Função que pesquisa o nome da tabeal de preço informada
Static Function Pro_SHOP()

   Local lChumba        := .F.
   Local cSql           := ""

   Private aAmbiente    := { "0 - Nenhum", "1 - Homologação", "2 - Produção" }
   Private cURLH        := Space(250)
   Private cCHVH        := Space(250)
   Private cUSUH        := Space(50)
   Private cSHOW        := Space(50)
   Private cENDLH       := Space(250)
   Private cENDAH       := Space(250)
   Private cLOGINH      := Space(50)
   Private cSENHALH     := Space(50)
   Private cURLP        := Space(250)
   Private cCHVP        := Space(250)
   Private cUSUP        := Space(50)
   Private cSENP        := Space(50)
   Private cENDLP       := Space(250)
   Private cENDAP       := Space(250)
   Private cLOGINP      := Space(50)
   Private cSENHALP     := Space(50)
   Private cTabela      := Space(03)
   Private cNomeTab     := Space(40)
   Private cArqDll      := Space(20)
   Private cVendShp     := Space(06)
   Private cNomeShp     := Space(40)
   Private cTesShp      := Space(03)
   Private cNomShp      := Space(40)
   Private cPermissa    := Space(250)
   Private cXcaminho    := Space(250)
   Private cXVendedores := Space(250)
   Private pSobre       := 0.00
   Private pComo        := "A"
   Private xNumeral     := 0

   Private cMemo1	 := ""
   Private cMemo2	 := ""
   Private cMemo3	 := ""
   Private cMemo4	 := ""

   Private cComboBx1
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
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4

   Private oDlgShop

   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4.ZZ4_URLH  ,"
   cSql += "       ZZ4.ZZ4_CHVH  ,"
   cSql += "       ZZ4.ZZ4_USUH  ,"
   cSql += "       ZZ4.ZZ4_SHOM  ,"
   cSql += "       ZZ4.ZZ4_EDLH  ,"
   cSql += "       ZZ4.ZZ4_EDAH  ,"
   cSql += "       ZZ4.ZZ4_LOGH  ,"
   cSql += "       ZZ4.ZZ4_SLOH  ,"
   cSql += "       ZZ4.ZZ4_URLP  ,"
   cSql += "       ZZ4.ZZ4_CHVP  ,"
   cSql += "       ZZ4.ZZ4_USUP  ,"
   cSql += "       ZZ4.ZZ4_SENP  ,"
   cSql += "       ZZ4.ZZ4_EDLP  ,"
   cSql += "       ZZ4.ZZ4_EDAP  ,"
   cSql += "       ZZ4.ZZ4_LOGP  ,"
   cSql += "       ZZ4.ZZ4_SLOP  ,"
   cSql += "       ZZ4.ZZ4_TABE  ,"
   cSql += "       ZZ4.ZZ4_AVIR  ,"
   cSql += "       ZZ4.ZZ4_ADLL  ,"
   cSql += "       ZZ4.ZZ4_CSLV  ,"
   cSql += "       ZZ4.ZZ4_VDAS  ,"
   cSql += "       ZZ4.ZZ4_TESS  ,"
   cSql += "       ZZ4.ZZ4_PEMS  ,"
   cSql += "       ZZ4.ZZ4_PLOJ  ,"
   cSql += "       ZZ4.ZZ4_CLOJ  ,"
   cSql += "       ZZ4.ZZ4_VENL  ,"
   cSql += "       ZZ4.ZZ4_NMRA  ,"
   cSql += "       ZZ4.ZZ4_MAXE   "
   cSql += "  FROM " + RetSqlName("ZZ4") + " ZZ4 "
   cSql += " WHERE ZZ4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cURLH        := T_PARAMETROS->ZZ4_URLH
      cCHVH        := T_PARAMETROS->ZZ4_CHVH
      cUSUH        := T_PARAMETROS->ZZ4_USUH
      cSHOW        := T_PARAMETROS->ZZ4_SHOM
      cENDLH       := T_PARAMETROS->ZZ4_EDLH
      cENDAH       := T_PARAMETROS->ZZ4_EDAH
      cLOGINH      := T_PARAMETROS->ZZ4_LOGH
      cSENHALH     := T_PARAMETROS->ZZ4_SLOH
      cURLP        := T_PARAMETROS->ZZ4_URLP
      cCHVP        := T_PARAMETROS->ZZ4_CHVP
      cUSUP        := T_PARAMETROS->ZZ4_USUP
      cSENP        := T_PARAMETROS->ZZ4_SENP
      cENDLP       := T_PARAMETROS->ZZ4_EDLP
      cENDAP       := T_PARAMETROS->ZZ4_EDAP
      cLOGINP      := T_PARAMETROS->ZZ4_LOGP
      cSENHALP     := T_PARAMETROS->ZZ4_SLOP
      cARQDLL      := T_PARAMETROS->ZZ4_ADLL
      cXcaminho    := T_PARAMETROS->ZZ4_CSLV
      cXVendedores := T_PARAMETROS->ZZ4_VENL
      cPermissa    := T_PARAMETROS->ZZ4_PEMS
      pSobre       := T_PARAMETROS->ZZ4_PLOJ
      PComo        := T_PARAMETROS->ZZ4_CLOJ
      cNumeral     := T_PARAMETROS->ZZ4_NMRA
      cMaximo      := T_PARAMETROS->ZZ4_MAXE
      
      // Tabela de Preço
      If Select("T_TABELA") > 0
         T_TABELA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DA0_CODTAB,"
      cSql += "       DA0_DESCRI,"
      cSql += "       DA0_ATIVO  "
      cSql += "  FROM " + RetSqlName("DA0")
      cSql += " WHERE D_E_L_E_T_ = '' "
      cSql += "   AND DA0_CODTAB = '" + Alltrim(T_PARAMETROS->ZZ4_TABE) + "'"
      cSql += " ORDER BY DA0_CODTAB   "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

      If T_PARAMETROS->( EOF() )
         cTABELA   := Space(03)
         cNOMETAB  := Space(40)
      Else
         cTABELA   := T_PARAMETROS->ZZ4_TABE
         cNOMETAB  := T_TABELA->DA0_DESCRI
      Endif      
         
      // Vendedor Automatech Shop   
      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT A3_COD, A3_NOME "
      cSql += "  FROM " + RetSqlName("SA3") 
      cSql += " WHERE A3_COD = '" + Alltrim(T_PARAMETROS->ZZ4_VDAS) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
 
      If T_VENDEDOR->( EOF() )
         cVendShp  := Space(06)
         cNomeShp  := Space(40)
      Else
         cVendShp  := T_PARAMETROS->ZZ4_VDAS
         cNomeShp  := T_VENDEDOR->A3_NOME
      Endif

      // TES         
      If Select("T_TES") > 0
         T_TES->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT F4_CODIGO, F4_TEXTO "
      cSql += "  FROM " + RetSqlName("SF4") 
      cSql += " WHERE F4_CODIGO = '" + Alltrim(T_PARAMETROS->ZZ4_TESS) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TES", .T., .T. )

      If T_TES->( EOF() )
         cTesShp   := Space(03)
         cNomShp   := Space(40)
      Else   
         cTesShp   := T_PARAMETROS->ZZ4_TESS
         cNomShp   := T_TES->F4_TEXTO
      Endif

      Do Case
         Case T_PARAMETROS->ZZ4_AVIR = "0"
              cComboBx1 := "0 - Nenhum"
         Case T_PARAMETROS->ZZ4_AVIR = "1"
              cComboBx1 := "1 - Homologação"
         Case T_PARAMETROS->ZZ4_AVIR = "2"
              cComboBx1 := "2 - Produção"
      EndCase              

   Endif

   DEFINE MSDIALOG oDlgShop TITLE "Parâmetros Acesso Loja Virtual" FROM C(178),C(181) TO C(602),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgShop

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(383),C(001) PIXEL OF oDlgShop
   @ C(034),C(196) GET oMemo4 Var cMemo4 MEMO Size C(001),C(111) PIXEL OF oDlgShop
   @ C(147),C(005) GET oMemo2 Var cMemo2 MEMO Size C(383),C(001) PIXEL OF oDlgShop
   @ C(192),C(005) GET oMemo3 Var cMemo3 MEMO Size C(383),C(001) PIXEL OF oDlgShop

   @ C(007),C(200) Say "Ambiente selecionado"                       Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(036),C(005) Say "H O M O L O G A Ç Ã O"                      Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(037),C(200) Say "P R O D U Ç Ã O"                            Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(047),C(200) Say "URL do Integrador"                          Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(048),C(005) Say "URL do Integrador"                          Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(067),C(005) Say "Chave de Integração"                        Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(067),C(075) Say "Usuário"                                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(067),C(139) Say "Senha"                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(067),C(200) Say "Chave de Integração"                        Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(067),C(270) Say "Usuário"                                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(067),C(334) Say "Senha"                                      Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(086),C(005) Say "Endereço Homologação Loja"                  Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(086),C(201) Say "Endereço Produção Loja"                     Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(105),C(005) Say "Endereço Homologação Painel Administrativo" Size C(109),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(105),C(200) Say "Endereço Produção Painel Administrativo"    Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(124),C(005) Say "Login"                                      Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(124),C(101) Say "Senha"                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(124),C(200) Say "Login"                                      Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(125),C(296) Say "Senha"                                      Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(150),C(160) Say "DLL"                                        Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(150),C(217) Say "Código Vendedor Automatech Shop"            Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(150),C(005) Say "Tabela de Preço"                            Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(170),C(005) Say "T E S"                                      Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop
   @ C(170),C(160) Say "Usuários com permissão para importar Pedidos de Vendas ( F1 X AUTOMATECH)" Size C(195),C(008) COLOR CLR_BLACK PIXEL OF oDlgShop

   @ C(016),C(200) ComboBox cComboBx1 Items aAmbiente Size C(188),C(010)                              PIXEL OF oDlgShop
   @ C(056),C(005) MsGet    oGet1     Var   cURLH     Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(075),C(005) MsGet    oGet2     Var   cCHVH     Size C(066),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(075),C(075) MsGet    oGet3     Var   cUSUH     Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(075),C(139) MsGet    oGet4     Var   cSHOW     Size C(054),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(095),C(005) MsGet    oGet5     Var   cENDLH    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(114),C(005) MsGet    oGet6     Var   cENDAH    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(133),C(005) MsGet    oGet7     Var   cLOGINH   Size C(090),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(133),C(101) MsGet    oGet8     Var   cSENHALH  Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(057),C(200) MsGet    oGet9     Var   cURLP     Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(075),C(200) MsGet    oGet10    Var   cCHVP     Size C(066),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(075),C(270) MsGet    oGet11    Var   cUSUP     Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(075),C(334) MsGet    oGet12    Var   cSENP     Size C(054),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(095),C(200) MsGet    oGet13    Var   cENDLP    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(114),C(200) MsGet    oGet14    Var   cENDAP    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(133),C(200) MsGet    oGet15    Var   cLOGINP   Size C(090),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(133),C(296) MsGet    oGet16    Var   cSENHALP  Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(159),C(005) MsGet    oGet17    Var   cTabela   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop F3("DA0") VALID( PsqTabPre(cTabela))
   @ C(159),C(032) MsGet    oGet18    Var   cNomeTab  Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop When lChumba
   @ C(159),C(160) MsGet    oGet19    Var   cArqDll   Size C(054),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop
   @ C(159),C(217) MsGet    oGet20    Var   cVendShp  Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop F3("SA3") VALID( PsqVendShop() )
   @ C(159),C(251) MsGet    oGet21    Var   cNomeShp  Size C(137),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop When lChumba
   @ C(178),C(005) MsGet    oGet22    Var   cTesShp   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop F3("SF4") VALID( PsqTESShop() )
   @ C(178),C(032) MsGet    oGet23    Var   cNomShp   Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop When lChumba
   @ C(178),C(160) MsGet    oGet24    Var   cPermissa Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgShop

   @ C(196),C(005) Button "Arquivo Produtos Salvar em ..." Size C(081),C(012) PIXEL OF oDlgShop ACTION( SALVAARQF1() )
   @ C(196),C(087) Button "% Sobre Preço"                  Size C(045),C(012) PIXEL OF oDlgShop ACTION( PRCSOBRE() )
   @ C(196),C(133) Button "Seleção Vendedores"             Size C(081),C(012) PIXEL OF oDlgShop ACTION( VALVENDEDOR() )

   @ C(196),C(216) Button "Nuemeral Grupos"                Size C(081),C(012) PIXEL OF oDlgShop ACTION( NUMERALGRP() )

   @ C(196),C(347) Button "Voltar"                         Size C(041),C(012) PIXEL OF oDlgShop ACTION( GravaSHOP() )

   ACTIVATE MSDIALOG oDlgShop CENTERED 

Return(.T.)

// Função que abre janela para informação/visualização do numeral por grupo
Static Function NUMERALGRP()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cNumGrupo := cNumeral
   Private cMaxGrupo := cMaximo

   Private oGet1
   Private oGet2

   Private oDlgRal

   DEFINE MSDIALOG oDlgRal TITLE "Numeral Grupos" FROM C(178),C(181) TO C(403),C(438) PIXEL

   @ C(003),C(003) Jpeg FILE "nlogoautoma.bmp" Size C(121),C(029) PIXEL NOBORDER OF oDlgRal

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(121),C(001) PIXEL OF oDlgRal
   @ C(086),C(003) GET oMemo2 Var cMemo2 MEMO Size C(121),C(001) PIXEL OF oDlgRal
   
   @ C(040),C(005) Say "Este parâmetro indica qual os grupo de produtos"   Size C(117),C(008) COLOR CLR_BLACK PIXEL OF oDlgRal
   @ C(049),C(005) Say "serão enviados na próxima remessa a Loja Virtual." Size C(118),C(008) COLOR CLR_BLACK PIXEL OF oDlgRal
   @ C(061),C(005) Say "Próximo Exportação"                                Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgRal
   @ C(061),C(050) Say "Máximo a Exportar"                                 Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgRal

   @ C(072),C(005) MsGet oGet1 Var cNumGrupo Size C(018),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgRal
   @ C(072),C(050) MsGet oGet2 Var cMaxGrupo Size C(018),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgRal   

   @ C(094),C(046) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRal ACTION( FCHGRUPOS() )

   ACTIVATE MSDIALOG oDlgRal CENTERED 

Return(.T.)

// Função que consiste e fecha a tela de parâmetros de exportação para a loja virtual
Static Function FCHGRUPOS()

   If cNumGrupo == 0
      cMaxGrupo := 0
   Endif

   If cNumGrupo <> 0
      If cMaxGrupo == 0
         MsgAlert("Nº máximo de grupos a exportar inconsitente.")
         Return(.T.)
      Endif         

      If cMaxGrupo < cNumGrupo
         MsgAlert("Nº máximo de grupos a exportar inconsitente.")
         Return(.T.)
      Endif         

   Endif

   cNumeral := cNumGrupo
   cMaximo  := cMaxGrupo
   
   oDlgRal:End()
   
Return(.T.)   

// Função que abre janela de solicitação do % sobre preço na exportação de produtos para loja virtual
Static Function PRCSOBRE()

   Local cMemo1	     := ""
   Local oMemo1

   Local aComo	     := {"A - Acréscimo", "D - Desconto"}
   Local cComboBx1
   Local cPercentual := pSobre
   Local oGet1

   Private oDlgSobre

   If pComo == "A"
      cComboBx1 := "A - Acréscimo"
   Else
      cComboBx1 := "D - Desconto"
   Endif

   // Desenha a Janela
   DEFINE MSDIALOG oDlgSobre TITLE "Composição de Preço de Venda (F1)" FROM C(178),C(181) TO C(489),C(471) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgSobre

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(137),C(001) PIXEL OF oDlgSobre
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(137),C(001) PIXEL OF oDlgSobre
   
   @ C(037),C(005) Say "Informe o divisor a ser aplicado sobre o preço de venda" Size C(132),C(008) COLOR CLR_BLACK PIXEL OF oDlgSobre
   @ C(044),C(005) Say "dos produtos que seão enviados para a Loja Virtual."     Size C(132),C(008) COLOR CLR_BLACK PIXEL OF oDlgSobre
   @ C(055),C(005) Say "Exemplo"                                                 Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgSobre
   @ C(068),C(013) Say "Preço de Venda = R$ 100,00 / 0.9 = R$ 111,11"            Size C(116),C(008) COLOR CLR_BLACK PIXEL OF oDlgSobre
   @ C(087),C(025) Say "Divisor"                                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSobre
   @ C(099),C(025) Say "Aplicar como"                                            Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgSobre

   @ C(086),C(045) MsGet    oGet1     Var   cPercentual Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgSobre
   @ C(109),C(025) ComboBox cComboBx1 Items aComo       Size C(091),C(010)                                     PIXEL OF oDlgSobre

   @ C(137),C(052) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgSobre ACTION( oDlgSobre:End() )

   ACTIVATE MSDIALOG oDlgSobre CENTERED 

   pSobre := cPercentual
   pComo  := Substr(cComboBx1,01,01)

Return(.T.)

// Função que abre janela de solicitação do caminho de salvamento do arquivo de produtos
Static Function SALVAARQF1()

   Local cCaminhoSlv := cXcaminho
   Local cMemo1	     := ""
   Local oGet1
   Local oMemo1

   Private oDlgSalva

   DEFINE MSDIALOG oDlgSalva TITLE "Salvar arquivo de produtos em ..." FROM C(178),C(181) TO C(333),C(559) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgSalva

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(180),C(001) PIXEL OF oDlgSalva

   @ C(037),C(005) Say "Salvar arquivo de produtos a ser importado em " Size C(113),C(008) COLOR CLR_BLACK PIXEL OF oDlgSalva

   @ C(046),C(005) MsGet oGet1 Var cCaminhoSlv Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSalva

   @ C(060),C(077) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlgSalva ACTION( cXcaminho := cCaminhoSlv, oDlgSalva:End() )

   ACTIVATE MSDIALOG oDlgSalva CENTERED 

Return(.T.)

// Função que abre janela de solicitação dos vendedores que deverão ser filtrados para informação de nota fiscal e código postal para a Loja Virtual (F1)
Static Function VALVENDEDOR()

   Local cSelecaoVendedores := cXVendedores
   Local cMemo1	     := ""
   Local oGet1
   Local oMemo1

   Private oDlgSelecao

   DEFINE MSDIALOG oDlgSelecao TITLE "Seleção de Vendedores - Loja Virtual (F1)" FROM C(178),C(181) TO C(333),C(559) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgSelecao

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(180),C(001) PIXEL OF oDlgSelecao

   @ C(037),C(005) Say "Vendedores utilizados para filtro para exportação de N.Fiscais e Código Postal" Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgSelecao

   @ C(046),C(005) MsGet oGet1 Var cSelecaoVendedores Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSelecao

   @ C(060),C(077) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlgSelecao ACTION( cXVendedores := cSelecaoVendedores, oDlgSelecao:End() )

   ACTIVATE MSDIALOG oDlgSelecao CENTERED 

Return(.T.)

// Função que pesquisa o nome da tabela de preço informada
Static Function ChamaTeste(_StringTeste)

   If Empty(Alltrim(_StringTeste))
      Return(.T.)
   Endif
      
   ShellExecute("open", Alltrim(_StringTeste),"","",5)
   
Return(.T.)   

// Função que pesquisa o nome da tabeal de preço informada
Static Function PsqTabPre(_Tabela)
                         
   Local cSql := ""

   If Empty(Alltrim(_Tabela))
      cTabela  := Space(03)
      cNomeTab := Space(40)
      oGet17:Refresh()
      oGet18:Refresh()
      Return(.T.)
   Endif

   // Carrega o combo de Tabela de Preços
   If Select("T_TABELA") > 0
      T_TABELA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA0_CODTAB,"
   cSql += "       DA0_DESCRI,"
   cSql += "       DA0_ATIVO  "
   cSql += "  FROM " + RetSqlName("DA0")
   cSql += " WHERE D_E_L_E_T_ = '' "
   cSql += "   AND DA0_CODTAB = '" + Alltrim(_Tabela) + "'"
   cSql += " ORDER BY DA0_CODTAB   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )
 
   If T_TABELA->( EOF() )
      MsgAlert("Tabela de preço informada inexistente.")
      cTabela  := Space(03)
      cNomeTab := Space(40)
      oGet17:Refresh()
      oGet18:Refresh()
      Return(.T.)
   Endif
   
   If T_TABELA->DA0_ATIVO <> '1'
      MsgAlert("Tabela de preço informada inativa.")
      cTabela  := Space(03)
      cNomeTab := Space(40)
      oGet17:Refresh()
      oGet18:Refresh()
      Return(.T.)
   Endif
      
   cNomeTab := T_TABELA->DA0_DESCRI
   oGet18:Refresh()

Return(.T.)

// Função que pesquisa o nome do vendedor informado
Static Function PsqVendShop()

   If Empty(Alltrim(cVendShp))
      cVendShp := Space(06)
      cNomeShp := Space(40)
      oGet20:Refresh()
      oGet21:Refresh()
      Return(.T.)
   Endif
      
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A3_COD, A3_NOME FROM " + RetSqlName("SA3") + " WHERE A3_COD = '" + Alltrim(cVendShp) + "' AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( EOF() )
      cVendShp := Space(06)
      cNomeShp := Space(40)
      oGet20:Refresh()
      oGet21:Refresh()
   Else
      cVendShp := T_VENDEDOR->A3_COD
      cNomeShp := T_VENDEDOR->A3_NOME
      oGet20:Refresh()
      oGet21:Refresh()
   Endif
   
Return(.T.)   

// Função que pesquisa o nome do TES
Static Function PsqTESShop()

   If Empty(Alltrim(cVendShp))
      cTESShp := Space(03)
      cNomShp := Space(40)
      oGet22:Refresh()
      oGet23:Refresh()
      Return(.T.)
   Endif
      
   If Select("T_TES") > 0
      T_TES->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT F4_CODIGO, F4_TEXTO FROM " + RetSqlName("SF4") + " WHERE F4_CODIGO = '" + Alltrim(cTESShp) + "' AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TES", .T., .T. )

   If T_TES->( EOF() )
      cTESShp := Space(03)
      cNomShp := Space(40)
      oGet22:Refresh()
      oGet23:Refresh()
   Else
      cTESShp := T_TES->F4_CODIGO
      cNomShp := T_TES->F4_TEXTO
      oGet23:Refresh()
      oGet24:Refresh()
   Endif
   
Return(.T.)   

// Função que grava os parâmetros da Automatech Shop
Static Function GravaSHOP()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_URLH := cURLH    
   ZZ4_CHVH := cCHVH    
   ZZ4_USUH := cUSUH    
   ZZ4_SHOM := cSHOW    
   ZZ4_EDLH := cENDLH   
   ZZ4_EDAH := cENDAH   
   ZZ4_LOGH := cLOGINH  
   ZZ4_SLOH := cSENHALH 
   ZZ4_URLP := cURLP    
   ZZ4_CHVP := cCHVP    
   ZZ4_USUP := cUSUP    
   ZZ4_SENP := cSENP    
   ZZ4_EDLP := cENDLP   
   ZZ4_EDAP := cENDAP   
   ZZ4_LOGP := cLOGINP  
   ZZ4_SLOP := cSENHALP 
   ZZ4_TABE := cTABELA  
   ZZ4_AVIR := Substr(cComboBx1,01,01)
   ZZ4_ADLL := cARQDLL   
   ZZ4_CSLV := cXcaminho
   ZZ4_VDAS := cVendShp
   ZZ4_TESS := cTesShp
   ZZ4_PEMS := cPermissa
   ZZ4_PLOJ := pSobre
   ZZ4_CLOJ := pComo
   ZZ4_VENL := cXVendedores
   ZZ4_NMRA := cNumeral
   ZZ4_MAXE := cMaximo
   MsUnLock()

   oDlgShop:End() 
   
Return(.T.)

// Função que abre a janela dos parâmetros de Margem de Produtos
Static Function pro_Margem()
                     
   Private cUsuEmp01  := Space(250)
   Private cUsuEmp02  := Space(250)
   Private cUsuEmp03  := Space(250)
   Private cMemo1	  := ""
   Private lEmpresa01 := .F.
   Private lEmpresa02 := .F.
   Private lEmpresa03 := .F.
   Private lFLPOA 	  := .F.
   Private lFLTI	  := .F.
   Private lFLAtech	  := .F.
   Private lFLCaxias  := .F.
   Private lFLPelotas := .F.
   Private lFLFabrica := .F.

   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oCheckBox4
   Private oCheckBox5
   Private oCheckBox6
   Private oCheckBox7
   Private oCheckBox8
   Private oCheckBox9
   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo1

   Private oDlgMargem

   // Carrega o combo de Tabela de Preços
   If Select("T_MARGEM") > 0
      T_MARGEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_MEP1,"
   cSql += "       ZZ4_MEP2,"
   cSql += "       ZZ4_MEP3,"
   cSql += "       ZZ4_MPOA,"
   cSql += "       ZZ4_MCXS,"
   cSql += "       ZZ4_MPEL,"
   cSql += "       ZZ4_MSUP,"
   cSql += "       ZZ4_MTIC,"
   cSql += "       ZZ4_MATC,"   
   cSql += "       ZZ4_MUS1,"   
   cSql += "       ZZ4_MUS2,"   
   cSql += "       ZZ4_MUS3 "      
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MARGEM", .T., .T. )

   If T_MARGEM->( EOF() )
      lEmpresa01 := .F.
      lEmpresa02 := .F.
      lEmpresa03 := .F.
      lFlPoa     := .F.
      lFLTI      := .F.
      lFLAtech   := .F.
      lFLCaxias  := .F.
      lFLPelotas := .F.
      lFLFabrica := .F.
      cUsuEmp01  := Space(250)
      cUsuEmp02  := Space(250)
      cUsuEmp03  := Space(250)
   Else
      lEmpresa01 := IIF(T_MARGEM->ZZ4_MEP1 == "T", .T., .F.)
      lEmpresa02 := IIF(T_MARGEM->ZZ4_MEP2 == "T", .T., .F.)
      lEmpresa03 := IIF(T_MARGEM->ZZ4_MEP3 == "T", .T., .F.)
      lFlPoa     := IIF(T_MARGEM->ZZ4_MPOA == "T", .T., .F.)
      lFLCaxias  := IIF(T_MARGEM->ZZ4_MCXS == "T", .T., .F.)
      lFLPelotas := IIF(T_MARGEM->ZZ4_MPEL == "T", .T., .F.)
      lFLFabrica := IIF(T_MARGEM->ZZ4_MSUP == "T", .T., .F.)
      lFLTI      := IIF(T_MARGEM->ZZ4_MTIC == "T", .T., .F.)
      lFLAtech   := IIF(T_MARGEM->ZZ4_MATC == "T", .T., .F.)
      cUsuEmp01  := T_MARGEM->ZZ4_MUS1
      cUsuEmp02  := T_MARGEM->ZZ4_MUS2
      cUsuEmp03  := T_MARGEM->ZZ4_MUS3
   Endif

   DEFINE MSDIALOG oDlgMargem TITLE "Acesso Tela de Margem de Produtos" FROM C(178),C(181) TO C(617),C(717) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgMargem
   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(256),C(001) PIXEL OF oDlgMargem

   @ C(042),C(005) Say "Grupo de Empresas"                                                                   Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem
   @ C(066),C(015) Say "Filiais Grupo Empresa 01"                                                            Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem
   @ C(066),C(092) Say "Filiais Grupo de Empresa 02"                                                         Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem
   @ C(066),C(175) Say "Filiais Grupo de Empresa 03"                                                         Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem
   @ C(121),C(005) Say "Usuários com permissão de acesso a tela de margem de produtos por Grupo de Empresas" Size C(215),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem
   @ C(133),C(005) Say "Empresa 01 - Automatech"                                                             Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem
   @ C(155),C(005) Say "Empresa 02 - TI Automação"                                                           Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem
   @ C(175),C(005) Say "Empresa 03 - ATECH"                                                                  Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgMargem

   @ C(053),C(015) CheckBox oCheckBox1 Var lEmpresa01 Prompt "01 - Automatech"    Size C(052),C(008) PIXEL OF oDlgMargem
   @ C(053),C(092) CheckBox oCheckBox2 Var lEmpresa02 Prompt "02 - TI Automação"  Size C(055),C(008) PIXEL OF oDlgMargem
   @ C(053),C(175) CheckBox oCheckBox3 Var lEmpresa03 Prompt "03 - ATECH"         Size C(040),C(008) PIXEL OF oDlgMargem
   @ C(076),C(025) CheckBox oCheckBox4 Var lFlPoa     Prompt "01 - Porto Alegre"  Size C(051),C(008) PIXEL OF oDlgMargem
   @ C(076),C(102) CheckBox oCheckBox8 Var lFLTI      Prompt "01 - TI Automação"  Size C(056),C(008) PIXEL OF oDlgMargem
   @ C(076),C(185) CheckBox oCheckBox9 Var lFLAtech   Prompt "01 - Atech"         Size C(038),C(008) PIXEL OF oDlgMargem
   @ C(086),C(025) CheckBox oCheckBox5 Var lFLCaxias  Prompt "02 - Caxias do Sul" Size C(053),C(008) PIXEL OF oDlgMargem
   @ C(097),C(025) CheckBox oCheckBox6 Var lFLPelotas Prompt "03 - Pelotas"       Size C(048),C(008) PIXEL OF oDlgMargem
   @ C(107),C(025) CheckBox oCheckBox7 Var lFLFabrica Prompt "04 - Suprimentos"   Size C(052),C(008) PIXEL OF oDlgMargem

   @ C(142),C(005) MsGet oGet1 Var cUsuEmp01 Size C(256),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMargem
   @ C(164),C(005) MsGet oGet2 Var cUsuEmp02 Size C(256),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMargem
   @ C(184),C(005) MsGet oGet3 Var cUsuEmp03 Size C(256),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMargem
   @ C(201),C(114) Button "Voltar"           Size C(037),C(012)                              PIXEL OF oDlgMargem ACTION( GrvMrgem() )
   
   ACTIVATE MSDIALOG oDlgMargem CENTERED 

Return(.T.)

// Função que grava os parâmetros da tela de Margem por Empresa/Filial;Usuário
Static Function GrvMrgem()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_MEP1 := IIF(lEmpresa01 == .T., "T", "F")
   ZZ4_MEP2 := IIF(lEmpresa02 == .T., "T", "F")
   ZZ4_MEP3 := IIF(lEmpresa03 == .T., "T", "F")
   ZZ4_MPOA := IIF(lFLPOA     == .T., "T", "F")
   ZZ4_MCXS := IIF(lFLCAXIAS  == .T., "T", "F")
   ZZ4_MPEL := IIF(lFLPELOTAS == .T., "T", "F")
   ZZ4_MSUP := IIF(lFLFABRICA == .T., "T", "F")
   ZZ4_MTIC := IIF(lFLTI      == .T., "T", "F")
   ZZ4_MATC := IIF(lFLATECH   == .T., "T", "F")
   ZZ4_MUS1 := cUsuEmp01
   ZZ4_MUS2 := cUsuEmp02
   ZZ4_MUS3 := cUsuEmp03
   MsUnLock()

   oDlgMargem:End() 
   
Return(.T.)

// Função que abre a janela dos Liberadores de Margem (Quoting)
Static Function pro_Quoting()

   Local cSql   := ""
   Local cMemo1 := ""
   Local oMemo1

   Private cQuoting := Space(250)
   Private oGet1
   
   Private oDlgQ

   // Carrega o combo de Tabela de Preços
   If Select("T_QUOTING") > 0
      T_QUOTING->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_QUOT FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QUOTING", .T., .T. )

   If T_QUOTING->( EOF() )
      cQuoting := space(250)
   Else
      cQuoting := T_QUOTING->ZZ4_QUOT   
   Endif

   // Desenha a tela para display dos liberadores de margem (Quoting)
   DEFINE MSDIALOG oDlgQ TITLE "Usuários com acesso a Liberação de Margem (Quoting)" FROM C(178),C(181) TO C(363),C(704) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlgQ

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(251),C(001) PIXEL OF oDlgQ

   @ C(041),C(005) Say "Informe o ID dos usuários que possuem autorização para realizar Liberação de Margem (Quoting)" Size C(231),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   @ C(063),C(005) Say "Informar os ID separados por pipe ( | )"                                                       Size C(091),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   
   @ C(051),C(005) MsGet oGet1 Var cQuoting Size C(251),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgQ

   @ C(076),C(112) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgQ ACTION( FechaQuoting() )
 
   ACTIVATE MSDIALOG oDlgQ CENTERED 

Return(.T.)

// Função que grava os liberadores de Margem (Quoting)
Static Function FechaQuoting()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_QUOT := cQuoting

   MsUnLock()

   oDlgQ:End() 
   
Return(.T.)

// Função que abre a janela para informação da substituição de caractres
Static Function Sub_Caracter()

   Local cSql      := ""
   Local cMemo1	   := ""
   Local cCaracter := ""
   Local oMemo1
   Local oMemo2

   Private oDlgT

   // Carrega a variável cCaracter para edição
   If Select("T_CARACTER") > 0
      T_CARACTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CARA)) AS CARACTER FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CARACTER", .T., .T. )

   If T_CARACTER->( EOF() )
      cCaracter := ""
   Else
      cCaracter := T_CARACTER->CARACTER
   Endif

   DEFINE MSDIALOG oDlgT TITLE "Substituição de caracteres" FROM C(178),C(181) TO C(499),C(655) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlgT

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(229),C(001) PIXEL OF oDlgT

   @ C(040),C(005) Say "Informe abaixo a sequencia de caracteres para substituição em strings." Size C(173),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(049),C(005) Say "Importante a forma da disposição destas informações. Veja exemplo:"     Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(058),C(005) Say "Ã;#á#|Ã@#é|"                                                            Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

   @ C(068),C(005) GET oMemo2 Var cCaracter MEMO Size C(227),C(072) PIXEL OF oDlgT

   @ C(144),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgT ACTION( FchCaracter(cCaracter))
 
   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// Função que grava os caracter informados
Static Function FchCaracter(_Caracter)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_CARA := _Caracter

   MsUnLock()

   oDlgT:End() 
   
Return(.T.)

// Função que abre a janela para informação dos usuários que possuem autorização para aprovar/reprovar solicitação de mercadorias
Static Function AprovaMerc()

   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1
   
   Private cAprova01 := Space(20)
   Private cAprova02 := Space(20)
   Private cAprova03 := Space(20)
   Private oGet1
   Private oGet2
   Private oGet3

   // Carrega a variável cCaracter para edição
   If Select("T_APROVADOR") > 0
      T_APROVADOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_ST01, ZZ4_ST02, ZZ4_ST03 FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APROVADOR", .T., .T. )

   If T_APROVADOR->( EOF() )
      cAprova01 := Space(20)
      cAprova02 := Space(20)
      cAprova03 := Space(20)   
   Else
      cAprova01 := T_APROVADOR->ZZ4_ST01
      cAprova02 := T_APROVADOR->ZZ4_ST02
      cAprova03 := T_APROVADOR->ZZ4_ST03
   Endif

   Private oDlgTransfe

   DEFINE MSDIALOG oDlgTransfe TITLE "Aprovadores/Reprovadores Sol.Tranf.Mercadorias" FROM C(178),C(181) TO C(420),C(488) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(146),C(026) PIXEL NOBORDER OF oDlgTransfe

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(145),C(001) PIXEL OF oDlgTransfe

   @ C(038),C(005) Say "Aprovadores/Reprovadores Solicitação de Transferência Mercadorias" Size C(144),C(008) COLOR CLR_BLACK PIXEL OF oDlgTransfe

   @ C(059),C(038) MsGet oGet1 Var cAprova01 Size C(082),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTransfe
   @ C(072),C(038) MsGet oGet2 Var cAprova02 Size C(082),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTransfe
   @ C(085),C(038) MsGet oGet3 Var cAprova03 Size C(082),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTransfe

   @ C(102),C(062) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgTransfe ACTION( FchAprovador(cAprova01, cAprova02, cAprova03))

   ACTIVATE MSDIALOG oDlgTransfe CENTERED 

Return(.T.)

// Função que grava os caracter informados
Static Function FchAprovador(_Aprova01, _Aprova02, _Aprova03)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_ST01 := _Aprova01
   ZZ4_ST02 := _Aprova02
   ZZ4_ST03 := _Aprova03   

   MsUnLock()

   oDlgTransfe:End() 
   
Return(.T.)

// Função que abre janela de configuração da Carga BI
Static Function CargaBI()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas	 := {"00 - Todas as Empresas", "01 - Automatech Sistemas de Automação Ltda", "02 - TI Automação", "03 - Atech"}
   Private aFiliais  	 := {"00 - Todas as Filiais", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "CC - Curitiba", "AA - Atech"}
   Private aGrupoDe 	 := {}
   Private aGrupoAte	 := {}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private dSaldo 	     := Ctod("  /  /    ")
   Private dMovimento 	 := Ctod("  /  /    ")

   Private cProduDe 	 := Space(30)
   Private cNomeDe   	 := Space(80)
   Private cProduAte	 := Space(30)
   Private cNomeAte	     := Space(80)

   Private cCaminho  	 := Space(250)
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlg

   // Carrega os combobs de grupos de produtos
   If Select("T_GRUPOS") > 0
      T_GRUPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY BM_GRUPO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPOS", .T., .T. )

   T_GRUPOS->( DbGoTop() )
   
   aAdd( aGrupoDe , "0000 - Todos os Grupos de Produtos" )
   aAdd( aGrupoAte, "0000 - Todos os Grupos de Produtos" )

   WHILE !T_GRUPOS->( EOF() )
      aAdd( aGrupoDe , T_GRUPOS->BM_GRUPO + " - " + T_GRUPOS->BM_DESC )
      aAdd( aGrupoAte, T_GRUPOS->BM_GRUPO + " - " + T_GRUPOS->BM_DESC )
      T_GRUPOS->( DbSkip() )
   ENDDO

   // Carrega as variável 
   If Select("T_CARGABI") > 0
      T_CARGABI->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_BIEM,"
   cSql += "       ZZ4_BIFI,"
   cSql += "       ZZ4_BISL,"
   cSql += "       ZZ4_BIMV,"
   cSql += "       ZZ4_BIGD,"
   cSql += "       ZZ4_BIGA,"
   cSql += "       ZZ4_BIPD,"
   cSql += "       ZZ4_BIPA,"
   cSql += "       ZZ4_BICA "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CARGABI", .T., .T. )

   If T_CARGABI->( EOF() )
   Else
      dSaldo 	 := Ctod(Substr(T_CARGABI->ZZ4_BISL,07,02) + "/" + Substr(T_CARGABI->ZZ4_BISL,05,02) + "/" + Substr(T_CARGABI->ZZ4_BISL,01,04))
      dMovimento := Ctod(Substr(T_CARGABI->ZZ4_BIMV,07,02) + "/" + Substr(T_CARGABI->ZZ4_BIMV,05,02) + "/" + Substr(T_CARGABI->ZZ4_BIMV,01,04))
      cProduDe 	 := T_CARGABI->ZZ4_BIPD
      cNomeDe    := ProduBI(0, 1)
      cProduAte	 := T_CARGABI->ZZ4_BIPA
      cNomeAte	 := ProduBI(0, 2)
      cCaminho   := T_CARGABI->ZZ4_BICA

      // Posiciona na Empresa
      Do Case
         Case T_CARGABI->ZZ4_BIEM == "00"
              cComboBx1 := "00 - Todas as Empresas" 
         Case T_CARGABI->ZZ4_BIEM == "01"
              cComboBx1 := "01 - Automatech Sistemas de Automação Ltda" 
         Case T_CARGABI->ZZ4_BIEM == "02"
              cComboBx1 := "02 - TI Automação" 
         Case T_CARGABI->ZZ4_BIEM == "03"
              cComboBx1 := "03 - Atech"  
      EndCase              

      // Posiciona a Filial
      Do Case
         Case T_CARGABI->ZZ4_BIFI == "00"
              cComboBx2 := "00 - Todas as Filiais" 
         Case T_CARGABI->ZZ4_BIFI == "01"
              cComboBx2 := "01 - Porto Alegre" 
         Case T_CARGABI->ZZ4_BIFI == "02"
              cComboBx2 := "02 - Caxias do Sul" 
         Case T_CARGABI->ZZ4_BIFI == "03"
              cComboBx2 := "03 - Pelotas" 
         Case T_CARGABI->ZZ4_BIFI == "04"
              cComboBx2 := "04 - Suprimentos" 
         Case T_CARGABI->ZZ4_BIFI == "CC"
              cComboBx2 := "CC - Curitiba" 
         Case T_CARGABI->ZZ4_BIFI == "AA"
              cComboBx2 := "AA - Atech"
      EndCase

      // Posiciona o grupo De
      For nContar = 1 to Len(aGrupoDe)
          If Substr(aGrupoDe[nContar],01,04) == T_CARGABI->ZZ4_BIGD
             cComboBx3 := aGrupoDe[nContar]
             Exit
          Endif
      Next nContar        
      
      // Posiciona o grupo Ate
      For nContar = 1 to Len(aGrupoAte)
          If Substr(aGrupoAte[nContar],01,04) == T_CARGABI->ZZ4_BIGA
             cComboBx4 := aGrupoAte[nContar]
             Exit
          Endif
      Next nContar        

   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgBI TITLE "Configurações Carga BI" FROM C(178),C(181) TO C(618),C(644) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgBI

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(223),C(001) PIXEL OF oDlgBI

   @ C(041),C(005) Say "Empresas"              Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(041),C(119) Say "Filiais"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(065),C(005) Say "Data Saldo Inicial"    Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(065),C(058) Say "Mvtos. Apartir de"     Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(088),C(005) Say "Grupo de Produtos de"  Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(112),C(005) Say "Grupo de Produtos Até" Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(135),C(005) Say "Produto de"            Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(158),C(005) Say "Produto Até"           Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
   @ C(180),C(005) Say "Caminho para gravação do arquivo de log de execusão do processo de carga de saldos" Size C(209),C(008) COLOR CLR_BLACK PIXEL OF oDlgBI
         
   @ C(051),C(005) ComboBox cComboBx1 Items aEmpresas  Size C(108),C(010)                              PIXEL OF oDlgBI
   @ C(051),C(119) ComboBox cComboBx2 Items aFiliais   Size C(108),C(010)                              PIXEL OF oDlgBI
   @ C(075),C(005) MsGet    oGet1     Var   dSaldo     Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBI
   @ C(075),C(058) MsGet    oGet2     Var   dMovimento Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBI
   @ C(098),C(005) ComboBox cComboBx3 Items aGrupoDe   Size C(222),C(010)                              PIXEL OF oDlgBI
   @ C(122),C(005) ComboBox cComboBx4 Items aGrupoAte  Size C(222),C(010)                              PIXEL OF oDlgBI
   @ C(145),C(005) MsGet    oGet3     Var   cProduDe   Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBI F3("SB1") VALID(ProduBI(1, 1))
   @ C(145),C(054) MsGet    oGet4     Var   cNomeDe    Size C(172),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBI When lChumba
   @ C(167),C(005) MsGet    oGet5     Var   cProduAte  Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBI F3("SB1") VALID(ProduBI(1, 2))
   @ C(167),C(054) MsGet    oGet6     Var   cNomeAte   Size C(172),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBI When lChumba
   @ C(190),C(005) MsGet    oGet7     Var   cCaminho   Size C(221),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBI

   @ C(204),C(005) Button "Calendário" Size C(037),C(012) PIXEL OF oDlgBI ACTION( ACalendario())
   @ C(204),C(189) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlgBI ACTION( FechaBI())

   ACTIVATE MSDIALOG oDlgBI CENTERED 

Return(.T.)

// Função que abre tela de geração de calendário de carga do Estoque do BI
Static Function ACalendario()

   Local cSql        := ""
   Local cMemo1	     := ""
   Local oMemo1
   
   Private aAnos     := {}
   Private cComboBx1
   Private cAno 	 := Space(25)
   Private oGet1

   Private oDlgCld

   // Carrega o ComboBox dos Calendários já Gerados
   If Select("T_CALENDARIO") > 0
      T_CALENDARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZPG_ANO"
   cSql += "  FROM " + RetSqlName("ZPG")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " GROUP BY ZPG_ANO"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CALENDARIO", .T., .T. )
        
   WHILE !T_CALENDARIO->( EOF() )
      aAdd( aAnos, T_CALENDARIO->ZPG_ANO )
      T_CALENDARIO->( DbSkip() )
   ENDDO
   
   If Len(aAnos) == 0
      aAdd( aAnos, "Nenhum Calendário gerado" )
   Endif

   DEFINE MSDIALOG oDlgCld TITLE "Calendário Carga Estoque BI" FROM C(178),C(181) TO C(400),C(454) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlgCld

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(129),C(001) PIXEL OF oDlgCld

   @ C(041),C(005) Say "Calendário Gerados"          Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgCld
   @ C(066),C(033) Say "Gerar Calendário para o Ano" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgCld

   @ C(050),C(005) ComboBox cComboBx1 Items aAnos Size C(126),C(010) PIXEL OF oDlgCld
   @ C(076),C(054) MsGet    oGet1     Var   cAno  Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCld

   @ C(092),C(030) Button "Gerar"  Size C(037),C(012) PIXEL OF oDlgCld ACTION( GeraCalendario(cAno) )
   @ C(092),C(069) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCld ACTION( oDlgCld:End() )
  
   ACTIVATE MSDIALOG oDlgCld CENTERED 

Return(.T.)

// Função que gera calendário pela informação do ano
Static Function GeraCalendario(_Ano)
   
   Local cSql    := ""
   Local nContar := 0
   Local nVezes  := 0
   Local dData   := Ctod("  /  /    ")

   If Empty(Alltrim(_Ano))
      Msgalert("Ano a ser gerado não informado.")
      Return(.T.)
   Endif
   
   // Verifica se o ano informado já foi gerado
   If Select("T_JAEXISTE") > 0
      T_JAEXISTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZPG_ANO"
   cSql += "  FROM " + RetSqlName("ZPG")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZPG_ANO    = '" + Alltrim(_Ano) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

   If !T_JAEXISTE->( EOF() )
      MsgAlert("Atenção! Ano informado já foi gerado.")
      Return(.T.)
   Endif
   
   // Carrega a variável nVezes
   nVezes := (CTOD("31/12/" + Alltrim(_Ano)) - CTOD("01/01/" + Alltrim(_Ano))) + 1
   
   // Abre o Calendário
   dData := CTOD("01/01/" + Alltrim(_Ano))

   For nContar = 1 to nVezes
             
       RecLock("ZPG",.T.)
       ZPG_FILIAL := "  "
       ZPG_MES    := Strzero(Month(dData),2)
       ZPG_ANO    := Str(Year(dData),4)
       ZPG_DATA   := dData
       MsUnLock()
       
       dData := dData + 1
       
   Next nContar    

   MsgAlert("Calendário para o ano " + Alltrim(_Ano) + " gerado com sucesso.")
   
   oDlgCld:End()

Return(.T.)   

// Função que pesquisa o produto informado para pesquisa na carga do BI
Static Function ProduBI(_Mostra, _Tipo)

   If _Tipo == 1
      cNomeDe  := Alltrim(Posicione("SB1",1,xFilial("SB1") + cProduDe, 'B1_DESC')) + " " + Alltrim(Posicione("SB1",1,xFilial("SB1") + cProduDe, 'B1_DAUX'))
      If _Mostra == 0
      Else
         oGet4:Refresh()
      Endif   
   Else
      cNomeAte := Alltrim(Posicione("SB1",1,xFilial("SB1") + cProduDe, 'B1_DESC')) + " " + Alltrim(Posicione("SB1",1,xFilial("SB1") + cProduDe, 'B1_DAUX'))
      If _Mostra == 0
      Else
         oGet6:Refresh()
      Endif   
   Endif

Return(.T.)

// Função que grava os parâmetros do Configurador de Carga do BI
Static Function FechaBI()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_BIEM := Substr(cComboBx1,01,02) 
   ZZ4_BIFI := Substr(cComboBx2,01,02) 
   ZZ4_BISL := dSaldo
   ZZ4_BIMV := dMovimento
   ZZ4_BIGD := Substr(cComboBx3,01,04) 
   ZZ4_BIGA := Substr(cComboBx4,01,04) 
   ZZ4_BIPD := cProduDe
   ZZ4_BIPA := cProduAte
   ZZ4_BICA := cCaminho

   MsUnLock()

   oDlgBI:End() 
   
Return(.T.)

// Função que abre parâmetros do SIGEP Correios
Static Function Pro_Sigep()

   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1

   Private cSURL := Space(150)
   Private cSCON := Space(010)
   Private cSCAR := Space(010) 
   Private cSUSA := Space(020) 
   Private cSSEN := Space(010)
   Private cSADM := Space(010)
   Private cSTIM := 0
   Private cSCCO := Space(150)
   Private cSCRE := Space(150)
   Private cSDIR := Space(002)   

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10

   Private oDlgSigep
   
   // Verifica se existe algum registro na Tabela ZZ4010 para os parâmetros SIGEP - Correios
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SURL,"
   cSql += "       ZZ4_SCON,"
   cSql += "       ZZ4_SCAR,"
   cSql += "       ZZ4_SUSA,"
   cSql += "       ZZ4_SSEN,"
   cSql += "       ZZ4_SADM,"
   cSql += "       ZZ4_STIM,"
   cSql += "       ZZ4_SCCO,"
   cSql += "       ZZ4_SCRE,"
   cSql += "       ZZ4_CDIR "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cSURL := IIF(T_PARAMETROS->( EOF() ), Space(150), T_PARAMETROS->ZZ4_SURL)
   cSCON := IIF(T_PARAMETROS->( EOF() ), Space(010), T_PARAMETROS->ZZ4_SCON)
   cSCAR := IIF(T_PARAMETROS->( EOF() ), Space(010), T_PARAMETROS->ZZ4_SCAR)
   cSUSA := IIF(T_PARAMETROS->( EOF() ), Space(020), T_PARAMETROS->ZZ4_SUSA)
   cSSEN := IIF(T_PARAMETROS->( EOF() ), Space(010), T_PARAMETROS->ZZ4_SSEN)
   cSADM := IIF(T_PARAMETROS->( EOF() ), Space(010), T_PARAMETROS->ZZ4_SADM)
   cSTIM := IIF(T_PARAMETROS->( EOF() ), 0         , T_PARAMETROS->ZZ4_STIM)
   cSCCO := IIF(T_PARAMETROS->( EOF() ), Space(150), T_PARAMETROS->ZZ4_SCCO)
   cSCRE := IIF(T_PARAMETROS->( EOF() ), Space(150), T_PARAMETROS->ZZ4_SCRE)
   cSDIR := IIF(T_PARAMETROS->( EOF() ), Space(002), T_PARAMETROS->ZZ4_CDIR)

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgSigep TITLE "Parâmetros SIGEP - Correios" FROM C(178),C(181) TO C(515),C(660) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgSigep

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(233),C(001) PIXEL OF oDlgSigep

   @ C(035),C(005) Say "URL"                                                 Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(057),C(005) Say "Contrato"                                            Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(057),C(071) Say "Cartão Postagem"                                     Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(057),C(137) Say "Código Administrativo"                               Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(080),C(137) Say "Código Diretoria"                                    Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(057),C(204) Say "Time-Out"                                            Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(080),C(005) Say "Usuário"                                             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(080),C(071) Say "Senha"                                               Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(102),C(005) Say "Caminho gravação arquivo de solicitação de consulta" Size C(129),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   @ C(125),C(005) Say "Caminho gravação arquivo de retorno"                 Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlgSigep
   
   @ C(044),C(005) MsGet oGet1  Var cSURL Size C(231),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(066),C(005) MsGet oGet2  Var cSCON Size C(060),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(066),C(071) MsGet oGet3  Var cSCAR Size C(060),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(066),C(137) MsGet oGet4  Var cSADM Size C(060),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(066),C(204) MsGet oGet9  Var cSTIM Size C(032),C(009) COLOR CLR_BLACK Picture "@E 9999999999" PIXEL OF oDlgSigep
   @ C(089),C(005) MsGet oGet5  Var cSUSA Size C(060),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(089),C(071) MsGet oGet6  Var cSSEN Size C(060),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(089),C(137) MsGet oGet10 Var cSDIR Size C(030),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(112),C(005) MsGet oGet7  Var cSCCO Size C(231),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep
   @ C(135),C(005) MsGet oGet8  Var cSCRE Size C(231),C(009) COLOR CLR_BLACK                         PIXEL OF oDlgSigep

   @ C(151),C(198) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgSigep ACTION( SalvaSigep() )

   ACTIVATE MSDIALOG oDlgSigep CENTERED 

Return(.T.)

// Função que grava os parâmetros do Configurador de Carga do BI
Static Function SalvaSigep()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_SURL := cSURL
   ZZ4_SCON := cSCON
   ZZ4_SCAR := cSCAR
   ZZ4_SUSA := cSUSA
   ZZ4_SSEN := cSSEN
   ZZ4_SADM := cSADM
   ZZ4_STIM := cSTIM
   ZZ4_SCCO := cSCCO
   ZZ4_SCRE := cSCRE
   ZZ4_CDIR := cSDIR
   MsUnLock()

   oDlgSigep:End() 
   
Return(.T.)

// Função que abre a janela de manutenção dos dados da Consulta RELATO - SERASA
Static Function AbreRelato()

   Local cMemo1	   := ""
   Local oMemo1
   
   Private aAmbiente := {"0 - Selecione", "1 - Homologação", "2 - Produção"}
   Private cComboBx1
   Private cLogon	 := Space(08)
   Private cSenha    := Space(08)
   Private cTimeOut  := 0
   Private cEnvio	 := Space(250)
   Private cRetorno  := Space(250)
   Private cAcessoH  := Space(250)
   Private cAcessoP  := Space(250)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7   

   Private oDlgR

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_RLOG,"
   cSql += "       ZZ4_RSEN,"
   cSql += "       ZZ4_RAMB,"
   cSql += "       ZZ4_RTIM,"
   cSql += "       ZZ4_ASER,"
   cSql += "       ZZ4_AREL,"
   cSql += "       ZZ4_RHOM,"
   cSql += "       ZZ4_RPRO "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cLogon	:= T_PARAMETROS->ZZ4_RLOG
      cSenha    := T_PARAMETROS->ZZ4_RSEN
      cTimeOut  := T_PARAMETROS->ZZ4_RTIM
      cEnvio	:= T_PARAMETROS->ZZ4_ASER
      cRetorno  := T_PARAMETROS->ZZ4_AREL
      cAcessoH  := T_PARAMETROS->ZZ4_RHOM
      cAcessoP  := T_PARAMETROS->ZZ4_RPRO

      Do Case
         Case T_PARAMETROS->ZZ4_RAMB == "1"
              cComboBx1 := "1 - Homologação"
         Case T_PARAMETROS->ZZ4_RAMB == "2"
              cComboBx1 := "2 - Produção"
         Otherwise              
              cComboBx1 := "0 - Selecione"
      EndCase        

   Endif

   // Desenha a tela para display
   DEFINE MSDIALOG oDlgR TITLE "Parâmetros RELATO SERASA" FROM C(178),C(181) TO C(506),C(620) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgR
   
   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(213),C(001) PIXEL OF oDlgR

   @ C(038),C(005) Say "Logon"                                                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(038),C(056) Say "Senha"                                                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(038),C(108) Say "Ambiente"                                                                   Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(038),C(185) Say "TimeOut"                                                                    Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(060),C(005) Say "Acesso ao ambiebnte de Homologação"                                         Size C(097),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(082),C(005) Say "Acesso ao ambiente de Produção"                                             Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(104),C(005) Say "Caminho para gravação do arquivo de envio da RECIPROCIDADE"                 Size C(162),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(126),C(005) Say "Caminho para gravação do arquivo de envio das informações de RECIPROCIDADE" Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   
   @ C(047),C(005) MsGet    oGet1     Var   cLogon    Size C(045),C(009) COLOR CLR_BLACK Picture "@&"            PIXEL OF oDlgR
   @ C(047),C(056) MsGet    oGet2     Var   cSenha    Size C(045),C(009) COLOR CLR_BLACK Picture "@&"            PIXEL OF oDlgR
   @ C(047),C(108) ComboBox cComboBx1 Items aAmbiente Size C(072),C(010)                                         PIXEL OF oDlgR
   @ C(047),C(185) MsGet    oGet3     Var   cTimeOut  Size C(029),C(009) COLOR CLR_BLACK Picture "@E 9999999999" PIXEL OF oDlgR
   @ C(069),C(005) MsGet    oGet6     Var   cAcessoH  Size C(209),C(009) COLOR CLR_BLACK Picture "@&"            PIXEL OF oDlgR
   @ C(091),C(005) MsGet    oGet7     Var   cAcessoP  Size C(209),C(009) COLOR CLR_BLACK Picture "@&"            PIXEL OF oDlgR
   @ C(113),C(005) MsGet    oGet4     Var   cEnvio    Size C(209),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgR
   @ C(135),C(005) MsGet    oGet5     Var   cRetorno  Size C(209),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgR

   @ C(148),C(177) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgR ACTION( SalvaRelato() )

   ACTIVATE MSDIALOG oDlgR CENTERED 

Return(.T.)

// Função que grava os parâmetros do Reciprocidade/Relato
Static Function SalvaRelato()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_RLOG := cLogon
   ZZ4_RSEN := cSenha
   ZZ4_RAMB := Substr(cComboBx1,01,01)
   ZZ4_RTIM := cTimeOut
   ZZ4_ASER := cEnvio
   ZZ4_AREL := cRetorno
   ZZ4_RHOM := cAcessoH
   ZZ4_RPRO := cAcessoP

   MsUnLock()

   oDlgR:End() 
   
Return(.T.)

// Função que abre solicitação da pergunta e respostas do Auxilio da Área de Projetos
Static Function AbrePergunta()

   Local cMemo1	 := ""
   Local oMemo1

   Private cPergunta  := Space(150)
   Private cResposta1 := Space(050)
   Private cResposta2 := Space(050)
   Private cResposta3 := Space(050)
   Private cURLHom    := Space(150)
   Private cURLPro    := Space(150)
   Private cArqRet    := Space(150)
   Private cArqXML    := Space(150)
   Private nAmbiente  := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6   
   Private oGet7   
   Private oGet8      
   Private oAmbiente

   Private oDlgPergunta

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_PERG,"
   cSql += "       ZZ4_RES1,"
   cSql += "       ZZ4_RES2,"
   cSql += "       ZZ4_RES3,"
   cSql += "       ZZ4_UATH,"
   cSql += "       ZZ4_UATP,"
   cSql += "       ZZ4_ARRT,"
   cSql += "       ZZ4_ARXM,"
   cSql += "       ZZ4_APER "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cPergunta  := T_PARAMETROS->ZZ4_PERG
      cResposta1 := T_PARAMETROS->ZZ4_RES1
      cResposta2 := T_PARAMETROS->ZZ4_RES2
      cResposta3 := T_PARAMETROS->ZZ4_RES3      
      cURLHom    := T_PARAMETROS->ZZ4_UATH
      cURLPro    := T_PARAMETROS->ZZ4_UATP
      cArqRet    := T_PARAMETROS->ZZ4_ARRT
      cArqXML    := T_PARAMETROS->ZZ4_ARXM
      nAmbiente  := T_PARAMETROS->ZZ4_APER
   Else
      cPergunta  := Space(150)
      cResposta1 := Space(050)
      cResposta2 := Space(050)
      cResposta3 := Space(050)
      cURLHom    := Space(150)
      cURLPro    := Space(150)
      cArqRet    := Space(150)
      cArqXML    := Space(150)
      nAmbiente  := 0
   Endif

   // Desenha a tela para visualização
   Private oDlgPergunta

   DEFINE MSDIALOG oDlgPergunta TITLE "Solicitação Auxilio Pré-Venda" FROM C(178),C(181) TO C(579),C(703) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgPergunta

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(253),C(001) PIXEL OF oDlgPergunta

   @ C(004),C(215) Say "Ambiente"                                                                                         Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(037),C(005) Say "URL de Homologação para criação de tarefas no AtechPortal"                                        Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(060),C(005) Say "URL de Produção para criação de tarefas no AtechPortal"                                           Size C(139),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(082),C(005) Say "Caminho Completo + Nome do arquivo de retorno de envio de comando"                                Size C(172),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(104),C(005) Say "Caminho Completo + Nome do arquivo de XML a ser enviado para abertura de tarefa"                  Size C(203),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(127),C(005) Say "Informe abaixo o título da pergunta bem como as 3 opções de respostas que será feita ao vendedor" Size C(238),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(136),C(005) Say "Pergunta"                                                                                         Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(158),C(005) Say "Resposta 1"                                                                                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(158),C(091) Say "Resposta 2"                                                                                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(158),C(177) Say "Resposta 3"                                                                                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
	   
   @ C(011),C(213) Radio oAmbiente Var nAmbiente  Items "Homoloação","Produção" 3D Size C(033),C(010) PIXEL OF oDlgPergunta
   @ C(047),C(005) MsGet oGet5     Var cURLHom    Size C(252),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta
   @ C(069),C(005) MsGet oGet6     Var cURLPro    Size C(252),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta
   @ C(091),C(005) MsGet oGet7     Var cArqRet    Size C(252),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta
   @ C(113),C(005) MsGet oGet8     Var cArqXML    Size C(252),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta
   @ C(145),C(005) MsGet oGet1     Var cPergunta  Size C(252),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta
   @ C(167),C(005) MsGet oGet2     Var cResposta1 Size C(080),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta
   @ C(167),C(091) MsGet oGet3     Var cResposta2 Size C(080),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta
   @ C(167),C(177) MsGet oGet4     Var cResposta3 Size C(080),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgPergunta

   @ C(184),C(005) Button "Cadastro de Usuários AtechPortal" Size C(102),C(012) PIXEL OF oDlgPergunta ACTION( ObsAtechPortal() )
   @ C(184),C(219) Button "Voltar"                           Size C(037),C(012) PIXEL OF oDlgPergunta ACTION( SPergunta() )

   ACTIVATE MSDIALOG oDlgPergunta CENTERED 

Return(.T.)

// Função que abre solicitação da pergunta e respostas do Auxilio da Área de Projetos
Static Function xAbrePergunta()

   Local cMemo1	 := ""
   Local oMemo1

   Private cURLHom    := Space(150)
   Private cURLPro    := Space(150)
   Private cArqRet    := Space(150)
   Private cArqXML    := Space(150)
   Private nAmbiente  := 0

   Private oAmbeinte
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8

   Private oDlgPergunta

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_PERG,"
   cSql += "       ZZ4_RES1,"
   cSql += "       ZZ4_RES2,"
   cSql += "       ZZ4_RES3,"
   cSql += "       ZZ4_UATH,"
   cSql += "       ZZ4_UATP,"
   cSql += "       ZZ4_ARRT,"
   cSql += "       ZZ4_ARXM,"
   cSql += "       ZZ4_APER "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cURLHom    := T_PARAMETROS->ZZ4_UATH
      cURLPro    := T_PARAMETROS->ZZ4_UATP
      cArqRet    := T_PARAMETROS->ZZ4_ARRT
      cArqXML    := T_PARAMETROS->ZZ4_ARXM
      nAmbiente  := T_PARAMETROS->ZZ4_APER
   Else
      cURLHom    := Space(150)
      cURLPro    := Space(150)
      cArqRet    := Space(150)
      cArqXML    := Space(150)
      nAmbiente  := 0
   Endif

   DEFINE MSDIALOG oDlgPergunta TITLE "Solicitação Auxilio Pré-Venda" FROM C(178),C(181) TO C(579),C(703) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(120),C(026) PIXEL NOBORDER OF oDlgPergunta

   @ C(032),C(003) GET oMemo1      Var cMemo1 MEMO Size C(253),C(001) PIXEL OF oDlgPergunta
   
   @ C(004),C(215) Say "Ambiente"                                                                        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(037),C(005) Say "URL de Homologação para criação de tarefas no AtechPortal"                       Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(060),C(005) Say "URL de Produção para criação de tarefas no AtechPortal"                          Size C(139),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(082),C(005) Say "Caminho Completo + Nome do arquivo de retorno de envio de comando"               Size C(172),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(104),C(005) Say "Caminho Completo + Nome do arquivo de XML a ser enviado para abertura de tarefa" Size C(203),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   @ C(125),C(005) Say "Perguntas e Respostas encerramento de oportunidades de venda"                    Size C(159),C(008) COLOR CLR_BLACK PIXEL OF oDlgPergunta
   
   @ C(011),C(213) Radio oAmbeinte Var nAmbiente Items "Homoloação","Produção" 3D Size C(033),C(010) PIXEL OF oDlgPergunta

   @ C(047),C(005) MsGet oGet5 Var cURLHom Size C(252),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPergunta
   @ C(069),C(005) MsGet oGet6 Var cURLPro Size C(252),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPergunta
   @ C(091),C(005) MsGet oGet7 Var cArqRet Size C(252),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPergunta
   @ C(113),C(005) MsGet oGet8 Var cArqXML Size C(252),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPergunta

   @ C(135),C(005) Button "1ª pergunta/respoistas para encerramento de Oportunidades de Venda com Sucesso" Size C(252),C(012) PIXEL OF oDlgPergunta ACTION( pRespostas(1) )
   @ C(148),C(005) Button "2ª pergunta/respostas para encerramento de Oportunidades de Venda com Sucesso"  Size C(252),C(012) PIXEL OF oDlgPergunta ACTION( pRespostas(2) )
   @ C(162),C(005) Button "3ª pergunta/respostas em caso de Oportunidade de Venda PERDIDA"                 Size C(252),C(012) PIXEL OF oDlgPergunta ACTION( pRespostas(3) )
   @ C(184),C(005) Button "Cadastro de Usuários AtechPortal"                                               Size C(102),C(012) PIXEL OF oDlgPergunta ACTION( ObsAtechPortal() )
   @ C(184),C(219) Button "Voltar"                                                                         Size C(037),C(012) PIXEL OF oDlgPergunta ACTION( SPergunta() )

   ACTIVATE MSDIALOG oDlgPergunta CENTERED 

Return(.T.)

// Função que a pergunta e as respostas
Static Function SPergunta()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
// ZZ4_PERG := cPergunta
// ZZ4_RES1 := cResposta1
// ZZ4_RES2 := cResposta2
// ZZ4_RES3 := cResposta3
   ZZ4_UATH := cURLHom
   ZZ4_UATP := cURLPro
   ZZ4_ARRT := cArqRet
   ZZ4_ARXM := cArqXML
   ZZ4_APER := nAmbiente

   MsUnLock()

   oDlgPergunta:End() 
   
Return(.T.)

// Função que abre a janela da primeira pergunta
Static Function pRespostas(_Tipo)

   Local cMemo1	 := ""
   Local oMemo1
      
   Private cPergunta := Space(150)
   Private cRespo01  := "" && Space(200)
   Private cRespo02  := "" && Space(200)
   Private cRespo03  := "" && Space(200)
   Private cRespo04  := "" && Space(200)
   Private cRespo05  := "" && Space(200)
   Private cRespo06  := "" && Space(200)
   Private cRespo07  := "" && Space(200)
   Private cRespo08  := "" && Space(200)
   Private cRespo09  := "" && Space(200)
   Private cRespo10  := "" && Space(200)
   Private cRespo11  := "" && Space(200)
   Private cRespo12  := "" && Space(200)
   Private cRespo13  := "" && Space(200)
   Private cRespo14  := "" && Space(200)
   Private cRespo15  := "" && Space(200)
   Private cRespo16  := "" && Space(200)
   Private cRespo17  := "" && Space(200)
   Private cRespo18  := "" && Space(200)
   Private cRespo19  := "" && Space(200)
   Private cRespo20  := "" && Space(200)

   Private oGet5
   Private oGet8
   Private oGet9
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
   Private oGet20
   Private oGet21
   Private oGet22
   Private oGet23
   Private oGet24
   Private oGet25
   Private oGet26
   Private oGet27

   Private oDlgPerResp

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_PER1,"
   cSql += "       ZZ4_PER2,"
   cSql += "       ZZ4_PER3,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_RES1)) AS RESP1,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_RES2)) AS RESP2,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_RES3)) AS RESP3 "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )

      Do Case
         Case _Tipo == 1
              cPergunta := T_PARAMETROS->ZZ4_PER1
              cRespo01  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   1))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   1))
              cRespo02  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   2))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   2))
              cRespo03  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   3))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   3))
              cRespo04  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   4))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   4))
              cRespo05  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   5))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   5))
              cRespo06  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   6))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   6))
              cRespo07  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   7))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   7))
              cRespo08  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   8))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   8))
              cRespo09  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",   9))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",   9))
              cRespo10  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  10))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  10))
              cRespo11  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  11))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  11))
              cRespo12  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  12))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  12))
              cRespo13  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  13))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  13))
              cRespo14  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  14))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  14))
              cRespo15  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  15))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  15))
              cRespo16  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  16))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  16))
              cRespo17  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  17))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  17))
              cRespo18  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  18))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  18))
              cRespo19  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  19))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  19))
              cRespo20  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP1, "|",  20))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP1, "|",  20))
         Case _Tipo == 2
              cPergunta := T_PARAMETROS->ZZ4_PER2
              cRespo01  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   1))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   1))
              cRespo02  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   2))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   2))
              cRespo03  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   3))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   3))
              cRespo04  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   4))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   4))
              cRespo05  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   5))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   5))
              cRespo06  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   6))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   6))
              cRespo07  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   7))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   7))
              cRespo08  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   8))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   8))
              cRespo09  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",   9))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",   9))
              cRespo10  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  10))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  10))
              cRespo11  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  11))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  11))
              cRespo12  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  12))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  12))
              cRespo13  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  13))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  13))
              cRespo14  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  14))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  14))
              cRespo15  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  15))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  15))
              cRespo16  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  16))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  16))
              cRespo17  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  17))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  17))
              cRespo18  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  18))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  18))
              cRespo19  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  19))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  19))
              cRespo20  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP2, "|",  20))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP2, "|",  20))
         Case _Tipo == 3
              cPergunta := T_PARAMETROS->ZZ4_PER3
              cRespo01  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   1))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   1))
              cRespo02  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   2))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   2))
              cRespo03  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   3))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   3))
              cRespo04  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   4))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   4))
              cRespo05  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   5))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   5))
              cRespo06  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   6))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   6))
              cRespo07  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   7))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   7))
              cRespo08  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   8))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   8))
              cRespo09  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",   9))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",   9))
              cRespo10  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  10))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  10))
              cRespo11  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  11))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  11))
              cRespo12  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  12))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  12))
              cRespo13  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  13))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  13))
              cRespo14  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  14))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  14))
              cRespo15  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  15))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  15))
              cRespo16  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  16))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  16))
              cRespo17  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  17))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  17))
              cRespo18  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  18))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  18))
              cRespo19  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  19))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  19))
              cRespo20  := IIF(EMPTY(ALLTRIM(U_P_CORTA(T_PARAMETROS->RESP3, "|",  20))), SPACE(200), U_P_CORTA(T_PARAMETROS->RESP3, "|",  20))
      EndCase

      cRespo01  := cRespo01 + Space(200 - Len(Alltrim(cRespo01)))
      cRespo02  := cRespo02 + Space(200 - Len(Alltrim(cRespo02)))
      cRespo03  := cRespo03 + Space(200 - Len(Alltrim(cRespo03)))
      cRespo04  := cRespo04 + Space(200 - Len(Alltrim(cRespo04)))
      cRespo05  := cRespo05 + Space(200 - Len(Alltrim(cRespo05)))
      cRespo06  := cRespo06 + Space(200 - Len(Alltrim(cRespo06)))
      cRespo07  := cRespo07 + Space(200 - Len(Alltrim(cRespo07)))
      cRespo08  := cRespo08 + Space(200 - Len(Alltrim(cRespo08)))
      cRespo09  := cRespo09 + Space(200 - Len(Alltrim(cRespo09)))
      cRespo10  := cRespo10 + Space(200 - Len(Alltrim(cRespo10)))
      cRespo11  := cRespo11 + Space(200 - Len(Alltrim(cRespo11)))
      cRespo12  := cRespo12 + Space(200 - Len(Alltrim(cRespo12)))
      cRespo13  := cRespo13 + Space(200 - Len(Alltrim(cRespo13)))
      cRespo14  := cRespo14 + Space(200 - Len(Alltrim(cRespo14)))
      cRespo15  := cRespo15 + Space(200 - Len(Alltrim(cRespo15)))
      cRespo16  := cRespo16 + Space(200 - Len(Alltrim(cRespo16)))
      cRespo17  := cRespo17 + Space(200 - Len(Alltrim(cRespo17)))
      cRespo18  := cRespo18 + Space(200 - Len(Alltrim(cRespo18)))
      cRespo19  := cRespo19 + Space(200 - Len(Alltrim(cRespo19)))
      cRespo20  := cRespo20 + Space(200 - Len(Alltrim(cRespo20)))

   Else

      cPergunta := Space(150)
      cRespo01  := Space(200)
      cRespo02  := Space(200)
      cRespo03  := Space(200)
      cRespo04  := Space(200)
      cRespo05  := Space(200)
      cRespo06  := Space(200)
      cRespo07  := Space(200)
      cRespo08  := Space(200)
      cRespo09  := Space(200)
      cRespo10  := Space(200)
      cRespo11  := Space(200)
      cRespo12  := Space(200)
      cRespo13  := Space(200)
      cRespo14  := Space(200)
      cRespo15  := Space(200)
      cRespo16  := Space(200)
      cRespo17  := Space(200)
      cRespo18  := Space(200)
      cRespo19  := Space(200)
      cRespo20  := Space(200)
      
   Endif

   Do Case
      Case _Tipo == 1
           DEFINE MSDIALOG oDlgPerResp TITLE "1ª Pergunta/Resposta - Oportunidade de Venda com SUCESSO" FROM C(179),C(182) TO C(571),C(714) PIXEL
      Case _Tipo == 2
           DEFINE MSDIALOG oDlgPerResp TITLE "2ª Pergunta/Resposta - Oportunidade de Venda com SUCESSO" FROM C(179),C(182) TO C(571),C(714) PIXEL
      Case _Tipo == 3
           DEFINE MSDIALOG oDlgPerResp TITLE "Pergunta/Resposta - Oportunidade PERDIDA"                 FROM C(179),C(182) TO C(571),C(714) PIXEL
   EndCase           

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(120),C(026) PIXEL NOBORDER OF oDlgPerResp

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(253),C(001) PIXEL OF oDlgPerResp

   Do Case
      Case _Tipo == 1
           @ C(037),C(005) Say "1ª Pergunta em caso de encerramento de oportunidade de venda com SUCESSO" Size C(190),C(008) COLOR CLR_BLACK PIXEL OF oDlgPerResp
      Case _Tipo == 2
           @ C(037),C(005) Say "2ª Pergunta em caso de encerramento de oportunidade de venda com SUCESSO" Size C(190),C(008) COLOR CLR_BLACK PIXEL OF oDlgPerResp
      Case _Tipo == 3
           @ C(037),C(005) Say "Pergunta em caso de encerramento de oportunidade PERDIDA"                 Size C(190),C(008) COLOR CLR_BLACK PIXEL OF oDlgPerResp
   EndCase           
           
   @ C(058),C(005) Say "Respostas a pergunta"                                                  Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgPerResp

   @ C(047),C(005) MsGet oGet5  Var cPergunta Size C(252),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp

   @ C(068),C(005) MsGet oGet8  Var cRespo01  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(078),C(005) MsGet oGet9  Var cRespo02  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(089),C(005) MsGet oGet10 Var cRespo03  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(099),C(005) MsGet oGet11 Var cRespo04  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(110),C(005) MsGet oGet12 Var cRespo05  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(120),C(005) MsGet oGet13 Var cRespo06  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(131),C(005) MsGet oGet14 Var cRespo07  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(142),C(005) MsGet oGet15 Var cRespo08  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(152),C(005) MsGet oGet16 Var cRespo09  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(163),C(005) MsGet oGet17 Var cRespo10  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp

   @ C(068),C(136) MsGet oGet18 Var cRespo11  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(079),C(136) MsGet oGet19 Var cRespo12  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(089),C(136) MsGet oGet20 Var cRespo13  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(100),C(136) MsGet oGet21 Var cRespo14  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(110),C(136) MsGet oGet22 Var cRespo15  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(121),C(136) MsGet oGet23 Var cRespo16  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(131),C(136) MsGet oGet24 Var cRespo17  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(142),C(136) MsGet oGet25 Var cRespo18  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(152),C(136) MsGet oGet26 Var cRespo19  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp
   @ C(163),C(136) MsGet oGet27 Var cRespo20  Size C(125),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPerResp

   @ C(178),C(114) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgPerResp ACTION( GrvPergResp(_Tipo) )

   ACTIVATE MSDIALOG oDlgPerResp CENTERED 

Return(.T.)

// Função que grava as perguntas e respoistas do tipo de encerramento de oportunidade de venda
Static Function GrvPergResp(_Tipo)

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   Do Case
      Case _Tipo == 1
           ZZ4_PER1 := cPergunta
           ZZ4_RES1 := Alltrim(cRespo01) + "|" + Alltrim(cRespo02) + "|" + Alltrim(cRespo03) + "|" + Alltrim(cRespo04) + "|" + Alltrim(cRespo05) + "|" + ;
                       Alltrim(cRespo06) + "|" + Alltrim(cRespo07) + "|" + Alltrim(cRespo08) + "|" + Alltrim(cRespo09) + "|" + Alltrim(cRespo10) + "|" + ;
                       Alltrim(cRespo11) + "|" + Alltrim(cRespo12) + "|" + Alltrim(cRespo13) + "|" + Alltrim(cRespo14) + "|" + Alltrim(cRespo15) + "|" + ;
                       Alltrim(cRespo16) + "|" + Alltrim(cRespo17) + "|" + Alltrim(cRespo18) + "|" + Alltrim(cRespo19) + "|" + Alltrim(cRespo20) + "|"
      Case _Tipo == 2
           ZZ4_PER2 := cPergunta
           ZZ4_RES2 := Alltrim(cRespo01) + "|" + Alltrim(cRespo02) + "|" + Alltrim(cRespo03) + "|" + Alltrim(cRespo04) + "|" + Alltrim(cRespo05) + "|" + ;
                       Alltrim(cRespo06) + "|" + Alltrim(cRespo07) + "|" + Alltrim(cRespo08) + "|" + Alltrim(cRespo09) + "|" + Alltrim(cRespo10) + "|" + ;
                       Alltrim(cRespo11) + "|" + Alltrim(cRespo12) + "|" + Alltrim(cRespo13) + "|" + Alltrim(cRespo14) + "|" + Alltrim(cRespo15) + "|" + ;
                       Alltrim(cRespo16) + "|" + Alltrim(cRespo17) + "|" + Alltrim(cRespo18) + "|" + Alltrim(cRespo19) + "|" + Alltrim(cRespo20) + "|"
      Case _Tipo == 3
           ZZ4_PER3 := cPergunta
           ZZ4_RES3 := Alltrim(cRespo01) + "|" + Alltrim(cRespo02) + "|" + Alltrim(cRespo03) + "|" + Alltrim(cRespo04) + "|" + Alltrim(cRespo05) + "|" + ;
                       Alltrim(cRespo06) + "|" + Alltrim(cRespo07) + "|" + Alltrim(cRespo08) + "|" + Alltrim(cRespo09) + "|" + Alltrim(cRespo10) + "|" + ;
                       Alltrim(cRespo11) + "|" + Alltrim(cRespo12) + "|" + Alltrim(cRespo13) + "|" + Alltrim(cRespo14) + "|" + Alltrim(cRespo15) + "|" + ;
                       Alltrim(cRespo16) + "|" + Alltrim(cRespo17) + "|" + Alltrim(cRespo18) + "|" + Alltrim(cRespo19) + "|" + Alltrim(cRespo20) + "|"
   EndCase

   MsUnLock()

   oDlgPerResp:End()
   
Return(.T.)   

// Função que abre a tela de manutenção dos observadores do Atech Portal
Static Function ObsAtechPortal()

   Local cMemo1	   := ""
   Local oMemo1

   Private aBrowse := {}

   Private oDlgObservadores

   // Envia para a função que carrega o grid dos usuários do AtechPortal
   carrega_usu_atech(1)
   
   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgObservadores TITLE "Usuários AtechPortal " FROM C(178),C(181) TO C(497),C(686) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(146),C(030) PIXEL NOBORDER OF oDlgObservadores

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(245),C(001) PIXEL OF oDlgObservadores

   @ C(040),C(005) Say "Relação de usuários observadores de tarefas no AtechPortal" Size C(146),C(008) COLOR CLR_BLACK PIXEL OF oDlgObservadores

   @ C(144),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgObservadores ACTION( DetalheIdPortal("I", "" ) )
   @ C(144),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgObservadores ACTION( DetalheIdPortal("A", aBrowse[oBrowse:nAt,01]) )
   @ C(144),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgObservadores ACTION( DetalheIdPortal("E", aBrowse[oBrowse:nAt,01]) )
   @ C(144),C(211) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgObservadores ACTION( oDlgObservadores:End() )

   oBrowse := TCBrowse():New( 065 , 005, 310, 110,,{'Logon Protheus'           ,; // 01 - Logon ndo Protheus
                                                    'Código Atech Portal'      ,; // 02 - Código do Usuário no Atech Portal
                                                    'Descrição dos Usuários'   ,; // 03 - Descrição dos Usuários
                                                    'Chave Acesso API'       } ,; // 04 - Chave de Acesso a API
                                                   {20,50,50,50},oDlgObservadores,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
   
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04]}}

   ACTIVATE MSDIALOG oDlgObservadores CENTERED 

Return(.T.)

// Função que carrega os dados para popular o grid de usuários do AtechPortal
Static Function carrega_usu_atech(__Abertura)
                
   Local cSql := ""
   
   aBrowse    := {}

   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTI_FILIAL,"
   cSql += "       ZTI_LPRO  ,"
   cSql += "       ZTI_IDCO  ,"
   cSql += "       ZTI_IDNO  ,"
   cSql += "       ZTI_IDCH  ,"
   cSql += "       ZTI_DELE   "
   cSql += "  FROM " + RetSqlName("ZTI")
   cSql += " WHERE ZTI_FILIAL = ''"
   cSql += "   AND ZTI_DELE   = ''"
   cSql += " ORDER BY ZTI_LPRO "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   T_USUARIOS->( DbGoTop() )
   
   WHILE !T_USUARIOS->( EOF() )
      aAdd( aBrowse, { T_USUARIOS->ZTI_LPRO, T_USUARIOS->ZTI_IDCO, T_USUARIOS->ZTI_IDNO, T_USUARIOS->ZTI_IDCH } )
      T_USUARIOS->( DbSkip() )
   ENDDO
      
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "" } )   
      Return(.T.)
   Endif
      
   If __Abertura == 1
      Return(.T.)
   Endif

   oBrowse:SetArray(aBrowse) 
   
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04]}}

Return(.T.)

// Função que grava e fecha a janela de observadores do Atech Portal
Static Function DetalheIdPortal(_Operacao, __IdLogon)

   Local  cSql   := ""
   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cIDCodigo := Space(10)
   Private cIDNome   := Space(40)
   Private cIDChave  := Space(50)
   Private cIDLogon  := Space(20)
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlgIDUsuario

   If _Operacao == "I"

//    cIdLogon  := Alltrim(cUserName)
      cIdLogon  := Space(20)
      cIDCodigo := Space(10)
      cIDNome   := Space(40)
      cIDChave  := Space(50)
      
   Else

      If Select("T_USUARIOS") > 0
         T_USUARIOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTI_FILIAL,"
      cSql += "       ZTI_IDCO  ,"
      cSql += "       ZTI_IDNO  ,"
      cSql += "       ZTI_IDCH  ,"
      cSql += "       ZTI_DELE  ,"
      cSql += "       ZTI_LPRO   "
      cSql += "  FROM " + RetSqlName("ZTI")
      cSql += " WHERE ZTI_FILIAL = ''"
      cSql += "   AND ZTI_LPRO   = '" + Alltrim(__IdLogon) + "'"
      cSql += "   AND ZTI_DELE   = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

      If T_USUARIOS->( EOF() )
         MsgAlert("Atenção! Não existem dados para este Logon.")
         Return(.T.)
      Else
         cIdLogon  := __IdLogon
         cIDCodigo := T_USUARIOS->ZTI_IDCO
         cIDNome   := T_USUARIOS->ZTI_IDNO
         cIDChave  := T_USUARIOS->ZTI_IDCH
      Endif
      
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgIDUsuario TITLE "Usuários AtechPortal " FROM C(178),C(181) TO C(445),C(533) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(146),C(030) PIXEL NOBORDER OF oDlgIDUsuario

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(168),C(001) PIXEL OF oDlgIDUsuario
   @ C(111),C(003) GET oMemo2 Var cMemo2 MEMO Size C(168),C(001) PIXEL OF oDlgIDUsuario

   @ C(042),C(005) Say "Login do Protheus"       Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgIDUsuario
// @ C(042),C(076) Say "Id Usuário Atech Portal" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgIDUsuario
   @ C(065),C(005) Say "Nome do Usuário"         Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgIDUsuario
   @ C(087),C(005) Say "Chave de Acesso a API"   Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgIDUsuario

   Do Case
      Case _Operacao == "I"
           @ C(052),C(005) MsGet oGet5 Var cIdLogon  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIDUsuario && When IIF(Alltrim(Upper(cUserName)) == "ADMINISTRADOR", .T., .F.)
//         @ C(052),C(076) MsGet oGet2 Var cIdCodigo Size C(035),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgIDUsuario
           @ C(074),C(005) MsGet oGet3 Var cIdNome   Size C(167),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIDUsuario
           @ C(096),C(005) MsGet oGet4 Var cIdChave  Size C(103),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgIDUsuario
      Case _Operacao == "A"
           @ C(052),C(005) MsGet oGet5 Var cIdLogon  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIDUsuario When lChumba 
//         @ C(052),C(076) MsGet oGet2 Var cIdCodigo Size C(035),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgIDUsuario
           @ C(074),C(005) MsGet oGet3 Var cIdNome   Size C(167),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIDUsuario
           @ C(096),C(005) MsGet oGet4 Var cIdChave  Size C(103),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgIDUsuario
      Case _Operacao == "E"
           @ C(052),C(005) MsGet oGet5 Var cIdLogon  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIDUsuario When lChumba 
//         @ C(052),C(076) MsGet oGet2 Var cIdCodigo Size C(035),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgIDUsuario When lChumba 
           @ C(074),C(005) MsGet oGet3 Var cIdNome   Size C(167),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgIDUsuario When lChumba 
           @ C(096),C(005) MsGet oGet4 Var cIdChave  Size C(103),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgIDUsuario When lChumba 
   EndCase

   @ C(116),C(096) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgIDUsuario ACTION( SalvaIDUsuario(_Operacao) )
   @ C(116),C(134) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgIDUsuario ACTION( oDlgIDUsuario:End() )

   ACTIVATE MSDIALOG oDlgIDUsuario CENTERED 

Return(.T.)

// Função que grava os dados do usuário do AtechPortal
Static Function SalvaIdUsuario(_Operacao)

   Local cSql := ""

   // Verifica se o código do ID do Usuário foi informado
//   If Empty(Alltrim(cIdCodigo))
//      MsgAlert("Código ID do Usuário não informado.")
//      Return(.T.)
//   Endif
   
   // Verifica se o nome do Usuário foi informado
   If Empty(Alltrim(cIdNome))
      MsgAlert("Nome do Usuário não informado.")
      Return(.T.)
   Endif
      
   // Verifica se a Chave de Acesso a API foi informada
   If Empty(Alltrim(cIdChave))
//      MsgAlert("Chave de Acesso a API não informada.")
//      Return(.T.)
   Endif
   
   // Inclusão de Usuário
   If _Operacao == "I"

      // Verificase se código já está cadastrado na tabela
      If Select("T_USUARIOS") > 0
         T_USUARIOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTI_FILIAL,"
      cSql += "       ZTI_IDCO  ,"
      cSql += "       ZTI_IDNO  ,"
      cSql += "       ZTI_IDCH  ,"
      cSql += "       ZTI_DELE  ,"
      cSql += "       ZTI_LPRO   "
      cSql += "  FROM " + RetSqlName("ZTI")
      cSql += " WHERE ZTI_FILIAL = ''"
      cSql += "   AND ZTI_LPRO   = '" + Alltrim(cIdLogon) + "'"
      cSql += "   AND ZTI_DELE   = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

      If !T_USUARIOS->( EOF() )      
         MsgAlert("usuário já cadastrado. Verifique!")
         Return(.T.)
      Endif

      // Inclui os dados na tabela ZTI
      RecLock("ZTI",.T.)
      ZTI_FILIAL := ""
//    ZTI_IDCO   := cIdCodigo
      ZTI_IDNO   := cIdNome
      ZTI_IDCH   := cIdChave
      ZTI_DELE   := ""
      ZTI_LPRO   := cIdLogon
      MsUnLock()
   Endif
      
   // Alteração de Usuário
   If _Operacao == "A"
          
      cSql := ""
      cSql := "UPDATE " + RetSqlName("ZTI")
      cSql += "   SET "
      cSql += "   ZTI_IDNO = '" + Alltrim(cIdNome)  + "'" + ", "
      cSql += "   ZTI_IDCH = '" + Alltrim(cIdChave) + "'" + ", "
      cSql += "   ZTI_DELE = ''" 
      cSql += " WHERE ZTI_LPRO = '" + Alltrim(cIdLogon) + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif

   Endif
   
   // Exclusão de Usuário
   If _Operacao == "E"

      cSql := ""
      cSql := "UPDATE " + RetSqlName("ZTI")
      cSql += "   SET "
      cSql += "   ZTI_DELE = 'X'"
      cSql += " WHERE ZTI_LPRO = '" + Alltrim(cIdLogon) + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif

   Endif

   oDlgIDUsuario:End()

   carrega_usu_atech(2)
   
Return(.T.)

// Função que abre janela para informação dos logins que podem alterar o RISCO do Cliente
Static Function AltRiscoCli()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cRisco  := Space(250)
   Private oGet5

   Private oDlgRisco

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_RISC FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   IF T_PARAMETROS->( EOF() )
      cRisco := Space(250)
   Else
      cRisco := T_PARAMETROS->ZZ4_RISC
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgRisco TITLE "Usuários AtechPortal " FROM C(178),C(181) TO C(378),C(699) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(146),C(030) PIXEL NOBORDER OF oDlgRisco

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(250),C(001) PIXEL OF oDlgRisco
   @ C(078),C(003) GET oMemo2 Var cMemo2 MEMO Size C(250),C(001) PIXEL OF oDlgRisco
   
   @ C(042),C(005) Say "Indique o login dos usuários que possuem autorização para alterar o campo Risco do cadastro de clientes." Size C(252),C(008) COLOR CLR_BLACK PIXEL OF oDlgRisco
   @ C(052),C(005) Say "NECESSARIAMENTE informe os logins separados por PIPE (|)"                                                 Size C(152),C(008) COLOR CLR_BLACK PIXEL OF oDlgRisco

   @ C(062),C(005) MsGet oGet5 Var cRisco Size C(249),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRisco

   @ C(084),C(109) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRisco ACTION( SairRisco() )

   ACTIVATE MSDIALOG oDlgRisco CENTERED 

Return(.T.)

// Função que grava e fecha a tela de Alteração de Risco Cliente
Static Function SairRisco()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_RISC := cRisco

   MsUnLock()

   oDlgRisco:End() 
   
Return(.T.)

// Função que abre janela de parâmetros da proposta comercial
Static Function PropostaC()

   Local cSql     := ""

   Local cMemo1	 := ""
   Local oMemo1
      
   Private cMens01 := Space(150)
   Private cMens02 := Space(150)
   Private cMens03 := Space(150)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgPC

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_MP01,"
   cSql += "       ZZ4_MP02,"
   cSql += "       ZZ4_MP03 "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   IF T_PARAMETROS->( EOF() )
      cMens01 := Space(150)
      cMens02 := Space(150)
      cMens03 := Space(150)      
   Else
      cMens01 := T_PARAMETROS->ZZ4_MP01
      cMens02 := T_PARAMETROS->ZZ4_MP02
      cMens03 := T_PARAMETROS->ZZ4_MP03      
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgPC TITLE "Proposta Comercial" FROM C(178),C(181) TO C(375),C(894) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgPC

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(349),C(001) PIXEL OF oDlgPC

   @ C(041),C(005) Say "Mensagem a ser impressa na proposta comercial" Size C(119),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   @ C(050),C(005) MsGet oGet1 Var cMens01 Size C(348),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgPC
   @ C(059),C(005) MsGet oGet2 Var cMens02 Size C(348),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgPC
   @ C(068),C(005) MsGet oGet3 Var cMens03 Size C(348),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgPC

   @ C(082),C(315) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgPC ACTION( SlvProposta() )

   ACTIVATE MSDIALOG oDlgPC CENTERED 

Return(.T.)

// Função que grava e fecha a tela de Alteração de Risco Cliente
Static Function SlvProposta()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_MP01 := cMens01
   ZZ4_MP02 := cMens02
   ZZ4_MP03 := cMens03

   MsUnLock()

   oDlgPC:End() 
   
Return(.T.)

// Função que abre janela de parâmetros de usuários que possuem autorização de realizar movimentações internas
Static Function MovInternas()

   Local cMemo1       := ""
   Local oMemo1
   
   Private cMinternos := Space(250)
   Private oGet1

   Private oDlg

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_MINT FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cMinternos := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_MINT)

   DEFINE MSDIALOG oDlg TITLE "Permissão Movimentações Internas" FROM C(178),C(181) TO C(350),C(823) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(314),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Usuários com permissão para realizar lançamentos de Movimentações Internas" Size C(188),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(044),C(005) Say "Informe o login do usuário separado com pipe ( | )"                         Size C(119),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(054),C(005) MsGet oGet1 Var cMinternos Size C(312),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(069),C(143) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvMovInt() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava e fecha a tela de Alteração de Risco Cliente
Static Function SlvMovInt()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_MINT := cMinternos

   MsUnLock()

   oDlg:End() 
   
Return(.T.)

// Função que abre janela de parâmetros de informação do código de garantia do fields service
Static Function GarantiaFS()

   Local cMemo1      := ""
   Local oMemo1
   
   Private cGarantia := Space(250)
   Private cEmailGar := Space(250)
   Private oGet1
   Private oGet2
   
   Private oDlg

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TGAR, ZZ4_EGAR FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cGarantia := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_TGAR)
   cEmailGar := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_EGAR)

   DEFINE MSDIALOG oDlg TITLE "Novo Formulário" FROM C(178),C(181) TO C(455),C(802) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(303),C(001) PIXEL OF oDlg

   @ C(040),C(005) Say "Informe abaixo os códigos dos serviços técnicos que deverão ser transferidos do armazém do técnico para o armazém 01" Size C(290),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "no momento da efetivação das Ordens de Serviços."                                                                     Size C(124),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(005) Say "Os códigos deverão ser informados sendo estes separados por PIPE ( | )."                                              Size C(174),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(086),C(005) Say "Informe o(s) email(s) que receberão alerta em caso de transferência que apresentarem problemas."                      Size C(232),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(096),C(005) Say "Para mais do que um email, separá-los com PONTO E VÍRGULA."                                                           Size C(163),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(072),C(005) MsGet oGet1 Var cGarantia Size C(300),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(106),C(005) MsGet oGet2 Var cEmailGar Size C(300),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(121),C(136) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlg ACTION( SlvGarantia() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava e fecha a tela de Alteração de Risco Cliente
Static Function SlvGarantia()

   Local cSql := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TGAR FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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
   
   ZZ4_TGAR := cGarantia
   ZZ4_EGAR := cEmailGar

   MsUnLock()

   oDlg:End() 
   
Return(.T.)

// Função que abre a janela de seleção do tipo de consistência a ser parametrizada
Static Function JanConsiste()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgConsiste

   DEFINE MSDIALOG oDlgConsiste TITLE "Consistência de Dados" FROM C(178),C(181) TO C(433),C(478) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgConsiste

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(140),C(001) PIXEL OF oDlgConsiste

   @ C(040),C(005) Button "Oportunidade de Vendas"        Size C(140),C(020) PIXEL OF oDlgConsiste ACTION( ConOportunidade() )
   @ C(061),C(005) Button "Preparação Documento de Saída" Size C(140),C(020) PIXEL OF oDlgConsiste ACTION( PrepDocSaida() )
   @ C(082),C(005) Button "Departamento Financeiro"       Size C(140),C(020) PIXEL OF oDlgConsiste ACTION( MsgAlert("Em Desenvolvimento.") )
   @ C(103),C(005) Button "Voltar"                        Size C(140),C(020) PIXEL OF oDlgConsiste ACTION( oDlgConsiste:End() )

   ACTIVATE MSDIALOG oDlgConsiste CENTERED 

Return(.T.)

// Função que abre janela dos parâmetros de consistência de dados da Oprotunidade de Venda
Static Function ConOportunidade()

   Local cSql      := ""
   Local nContar   := 0
   Local nElemento := 0

   Local cMemo1	   := ""
   Local cMemo2	   := ""

   Local oMemo1
   Local oMemo2

   Private cGrupos := Space(250)
   Private cCFOP   := Space(250)
   Private oGet1
   Private oGet2

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   Private oDlgDoc

   // Conteúdo a serem consistidos
   // -------------------------------------------------------
   // 00 - Consiste Dados                                    
   // 01 - Condição de Pagamento Negociável Valor            
   // 02 - Grupo Tributário do Cliente                       
   // 03 - Endereço do Cliente                               
   // 04 - CEP do Endereço do Cliente                        
   // 05 - Telefone do Cliente                               
   // 06 - E-mail do Cliente                                 
   // 07 - NCM dos Produtos do Pedido de Venda               

   // Carrega o conteúdo das variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL,"
   cSql += "       ZZ4_CONS   "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )

      aLista := {}
      aAdd( aLista, { .F., "00", "Realiza Consistência de Dados no Encerramento de Oportunidade de Venda" })
      aAdd( aLista, { .F., "01", "Condição de Pagamento Negociável Valor" })
      aAdd( aLista, { .F., "02", "Grupo Tributário do Cliente" })
      aAdd( aLista, { .F., "03", "Endereço do Cliente" })
      aAdd( aLista, { .F., "04", "Cep do Endereço do Cliente" })
      aAdd( aLista, { .F., "05", "Telefone do Cliente" })
      aAdd( aLista, { .F., "06", "E-mail do Cliente" })
      aAdd( aLista, { .F., "07", "NCM dos Produtos do Pedido de Venda" })

      cGrupos   := ""
      cCFOP     := ""

   Else

      If Empty(Alltrim(T_PARAMETROS->ZZ4_CONS))
         aLista := {}
         aAdd( aLista, { .F., "00", "Realiza Consistência de Dados no Encerramento de Oportunidade de Venda" })
         aAdd( aLista, { .F., "01", "Condição de Pagamento Negociável Valor" })
         aAdd( aLista, { .F., "02", "Grupo Tributário do Cliente" })
         aAdd( aLista, { .F., "03", "Endereço do Cliente" })
         aAdd( aLista, { .F., "04", "Cep do Endereço do Cliente" })
         aAdd( aLista, { .F., "05", "Telefone do Cliente" })
         aAdd( aLista, { .F., "06", "E-mail do Cliente" })
         aAdd( aLista, { .F., "07", "NCM dos Produtos do Pedido de Venda" })
      Else

         For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_CONS, "#", 1)

             __Consistencia := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",  nContar), "|", 1)
             __Habilita     := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",  nContar), "|", 2)
      
             Do Case
                Case __Consistencia == "00"
                     __DescricaoCons := "00 - Realiza Consistência de Dados no Encerramento de Oportunidade de Venda"
                Case __Consistencia == "01"
                     __DescricaoCons := "01 - Condição de Pagamento Negociável Valor"
                Case __Consistencia == "02"
                     __DescricaoCons := "02 - Grupo Tributário do Cliente"
                Case __Consistencia == "03"
                     __DescricaoCons := "03 - Endereço do Cliente"
                Case __Consistencia == "04"
                     __DescricaoCons := "04 - Cep do Endereço do Cliente"
                Case __Consistencia == "05"
                     __DescricaoCons := "05 - Telefone do Cliente"
                Case __Consistencia == "06"
                     __DescricaoCons := "06 - E-mail do Cliente"
                Case __Consistencia == "07"
                     __DescricaoCons := "07 - NCM dos Produtos do Pedido de Venda"
             EndCase                  

             aAdd(aLista, { IIF(__Habilita == "0", .F., .T.), __Consistencia,  __DescricaoCons })

         Next nContar
         
      Endif   

   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgDoc TITLE "Parâmetros Consistência Encerramento de Oprotunidade de Venda" FROM C(178),C(181) TO C(506),C(874) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp " Size C(130),C(030) PIXEL NOBORDER OF oDlgDoc

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(339),C(001) PIXEL OF oDlgDoc
   @ C(144),C(003) GET oMemo2 Var cMemo2 MEMO Size C(339),C(001) PIXEL OF oDlgDoc

   @ C(041),C(005) Say "Este parametrizador pemite que sejam habilitados/desabilitados a verificação de ítens antes de realizar o encerramento d Oportunidade de Venda" Size C(338),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc

   @ C(148),C(154) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDoc ACTION( SlvParOportu() )

   // Lista com os produtos do pedido selecionado
   @ 065,005 LISTBOX oLista FIELDS HEADER "H/D", "Código", "Descrição da Validação" PIXEL SIZE 430,117 OF oDlgDoc ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo), aLista[oLista:nAt,02], aLista[oLista:nAt,03]}}

   ACTIVATE MSDIALOG oDlgDoc CENTERED 

Return(.T.)
      
// Função que grava os parâmetros de consistência de preparação documento de saída
Static Function SlvParOportu()

   Local cSql    := ""
   Local cLinha  := ""
   Local nContar := 0
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_CONS FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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

   cLinha := ""

   For nContar = 1 to Len(aLista)
       cLinha := cLinha + aLista[nContar,02] + "|" + IIF(aLista[nContar,01] == .F., "0", "1") + "|#"
   Next nContar       
   
   ZZ4_CONS := cLinha

   MsUnLock()

   oDlgDoc:End()    
   
Return(.T.)

// Função que grava o0s par^âmetros de Consistência de Preparação Documento de Saída
Static Function PrepDocSaida()

   Local cSql      := ""
   Local nContar   := 0
   Local nElemento := 0

   Local cMemo1	   := ""
   Local cMemo2	   := ""

   Local oMemo1
   Local oMemo2

   Private cGrupos := Space(250)
   Private cCFOP   := Space(250)
   Private oGet1
   Private oGet2

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   Private oDlgDoc

   // Conteúdo a serem consistidos
   // -------------------------------------------------------
   // 00 - Consiste Dados                                    
   // 01 - Contrato de Locação                               
   // 02 - Nº de Série produtos com controle de nº de série                           
   // 03 - Nota Fiscal de Serviço - Filial 02 - Caxias do Sul
   // 04 - CFOP produtos do Pedido de Venda                  

   // Carrega o conteúdo das variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL,"
   cSql += "       ZZ4_CONC  ,"
   cSql += "       ZZ4_GTRI  ,"
   cSql += "       ZZ4_CFOP   "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )

      aLista := {}
      aAdd( aLista, { .F., "00", "Permite Consistência de Dados" })
      aAdd( aLista, { .F., "01", "Pedidos de Venda - Contrato de Locação" })
      aAdd( aLista, { .F., "02", "Nº de Séries para produtos com controle de Nº de Série" })
      aAdd( aLista, { .F., "03", "Nota Fiscal de Serviço - Caxias do Sul" })
      aAdd( aLista, { .F., "04", "CFOP dos produtos do Pedido de Venda" })

      cGrupos   := ""
      cCFOP     := ""

   Else

      cGrupos := T_PARAMETROS->ZZ4_GTRI
      cCFOP   := T_PARAMETROS->ZZ4_CFOP

      If Empty(Alltrim(T_PARAMETROS->ZZ4_CONC))
         aLista := {}
         aAdd( aLista, { .F., "00", "Permite Consistência de Dados" })
         aAdd( aLista, { .F., "01", "Pedidos de Venda - Contrato de Locação" })
         aAdd( aLista, { .F., "02", "Nº de Séries para produtos com controle de Nº de Série" })
         aAdd( aLista, { .F., "03", "Nota Fiscal de Serviço - Caxias do Sul" })
         aAdd( aLista, { .F., "04", "CFOP dos produtos do Pedido de Venda" })
      Else

         For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_CONC, "#", 1)

             __Consistencia := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",  nContar), "|", 1)
             __Habilita     := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONC, "#",  nContar), "|", 2)
      
             Do Case
                Case __Consistencia == "00"
                     __DescricaoCons := "00 - Permite Consistência de Dados"
                Case __Consistencia == "01"
                     __DescricaoCons := "01 - Pedidos de Venda - Contrato de Locação"
                Case __Consistencia == "02"
                     __DescricaoCons := "02 - Nº de Séries para produtos com controle de Nº de Série"
                Case __Consistencia == "03"
                     __DescricaoCons := "03 - Nota Fiscal de Serviço - Caxias do Sul"
                Case __Consistencia == "04"
                     __DescricaoCons := "04 - CFOP dos produtos do Pedido de Venda"
             EndCase                  

             aAdd(aLista, { IIF(__Habilita == "0", .F., .T.), __Consistencia,  __DescricaoCons })

         Next nContar
         
      Endif   

   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgDoc TITLE "Parâmetros Consistência Preparação Documento de Saída" FROM C(178),C(181) TO C(592),C(874) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlgDoc

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(339),C(001) PIXEL OF oDlgDoc
   @ C(186),C(003) GET oMemo2 Var cMemo2 MEMO Size C(339),C(001) PIXEL OF oDlgDoc
   
   @ C(042),C(005) Say 'Este parametrizador pemite que sejam habilitados/desabilitados a verificação de ítens antes de realizar a Preparação do Documento de Saída.' Size C(338),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc
   @ C(143),C(005) Say 'Grupos Tributários de Produtos a serem verificados ( Exemplo "001#002#003#004" )'                                                            Size C(204),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc
   @ C(163),C(005) Say 'CFOPs ( Exemplo  "5102#6102" )'                                                                                                              Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc
   
   @ C(152),C(005) MsGet oGet1 Var cGrupos Size C(336),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDoc
   @ C(172),C(005) MsGet oGet2 Var cCFOP   Size C(336),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDoc

   @ C(190),C(154) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDoc ACTION( SlvParDocSai() )

   // Lista com os produtos do pedido selecionado
   @ 065,005 LISTBOX oLista FIELDS HEADER "H/D", "Código", "Descrição da Validação" PIXEL SIZE 430,117 OF oDlgDoc ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo), aLista[oLista:nAt,02], aLista[oLista:nAt,03]}}

   ACTIVATE MSDIALOG oDlgDoc CENTERED 

Return(.T.)
      
// Função que grava os parâmetros de consistência de preparação documento de saída
Static Function SlvParDocSai()

   Local cSql    := ""
   Local cLinha  := ""
   Local nContar := 0
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_CONC FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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

   cLinha := ""

   For nContar = 1 to Len(aLista)
       cLinha := cLinha + aLista[nContar,02] + "|" + IIF(aLista[nContar,01] == .F., "0", "1") + "|#"
   Next nContar       
   
   ZZ4_CONC := cLinha
   ZZ4_GTRI := cGrupos
   ZZ4_CFOP := cCFOP

   MsUnLock()

   oDlgDoc:End()    
   
Return(.T.)

// ##################################################
// Função que trata os parâmetros do Sales Machine ##
// ##################################################
Static Function par_Sales()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cOFilial	 := Space(002)
   Private cOPropos  := Space(006)
   Private cOCope	 := Space(006)
   Private cOLope	 := Space(003)
   Private cOOemp	 := Space(100)
   Private cOOSTQ	 := Space(100)
   Private cCOOarq	 := Space(100)
   Private cNomeC	 := Space(060)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8

   Private oDlgSales

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FPRO,"
   cSql += "       ZZ4_PCOM,"
   cSql += "       ZZ4_COPE,"
   cSql += "       ZZ4_LOPE,"
   cSql += "       ZZ4_OEMP,"
   cSql += "       ZZ4_OEMS,"
   cSql += "       ZZ4_OARQ "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cOFilial := IIF(T_PARAMETROS->( EOF() ), Space(002), T_PARAMETROS->ZZ4_fpro)
   cOPropos := IIF(T_PARAMETROS->( EOF() ), Space(006), T_PARAMETROS->ZZ4_pcom)
   cOCope   := IIF(T_PARAMETROS->( EOF() ), Space(006), T_PARAMETROS->ZZ4_cope)
   cOLope   := IIF(T_PARAMETROS->( EOF() ), Space(003), T_PARAMETROS->ZZ4_lope)
   cOOemp   := IIF(T_PARAMETROS->( EOF() ), Space(100), T_PARAMETROS->ZZ4_oemp)
   cOOSTQ   := IIF(T_PARAMETROS->( EOF() ), Space(100), T_PARAMETROS->ZZ4_oems)
   cOOarq   := IIF(T_PARAMETROS->( EOF() ), Space(100), T_PARAMETROS->ZZ4_oarq)

   If Empty(Alltrim(cOCope))
      cNomeC := ""
   Else
      cNomec := Posicione("SA1", 1, xFilial("SA1") + cOCope + cOLope, "A1_NOME")
   Endif

   DEFINE MSDIALOG oDlgSales TITLE "Parametrizador Sales Machine" FROM C(178),C(181) TO C(522),C(701) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgSales

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(252),C(001) PIXEL OF oDlgSales
   @ C(149),C(002) GET oMemo2 Var cMemo2 MEMO Size C(252),C(001) PIXEL OF oDlgSales

   @ C(037),C(005) Say "Filial/Proposta Comercial Modelo"                                                           Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgSales
   @ C(060),C(005) Say "Cliente Modelo"                                                                             Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgSales
   @ C(082),C(005) Say "Empresas e Filiais a serem calculadas. Padrão de Preenchimento  01|01|02|03|04|#02|01|#"    Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlgSales
   @ C(103),C(005) Say "Empresas e Filiais para geração de estoque. Padrão de Preechimento 01|01|02|03|04|#02|01|#" Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlgSales
   @ C(125),C(005) Say "Pasta para gravação dos log de cálculo. Exemplo   C:\PASTA\"                                Size C(249),C(008) COLOR CLR_BLACK PIXEL OF oDlgSales
   
   @ C(047),C(005) MsGet oGet1 Var cOFilial Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales                                                           
   @ C(047),C(027) MsGet oGet2 Var cOPropos Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales
   @ C(069),C(005) MsGet oGet3 Var cOCope   Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales
   @ C(069),C(037) MsGet oGet4 Var cOLope   Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales F3("SA1") VALID( TrzClienteSales() )
   @ C(069),C(062) MsGet oGet5 Var cNomeC   Size C(193),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales When lChumba
   @ C(091),C(005) MsGet oGet6 Var cOOemp   Size C(250),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales
   @ C(112),C(005) MsGet oGet8 Var cOOSTQ   Size C(250),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales
   @ C(135),C(005) MsGet oGet7 Var cOOarq   Size C(250),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSales

   @ C(154),C(112) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgSales ACTION( SalvaSale() )

   ACTIVATE MSDIALOG oDlgSales CENTERED 

Return(.T.)

// ##################################################################################
// Função que pesquisa o cliente selecionado ou informado na tela do Sales Machine ##
// ##################################################################################
Static Function TrzClienteSales()

   If Empty(Alltrim(cOCope))
      cNomec := ""
   Else
      cNomec := Posicione("SA1", 1, xFilial("SA1") + cOCope + cOLope, "A1_NOME")      
      oGet5:Refresh()
   Endif
   
Return(.T.)

// #####################################################
// Função que grava as variáveis da tela Sale Machine ##
// #####################################################
Static Function SalvaSale()

   Local cSql    := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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

   ZZ4->ZZ4_FPRO := cOFilial
   ZZ4->ZZ4_PCOM := cOPropos
   ZZ4->ZZ4_COPE := cOCope
   ZZ4->ZZ4_LOPE := cOLope
   ZZ4->ZZ4_OEMP := cOOemp
   ZZ4->ZZ4_OEMS := cOOSTQ
   ZZ4->ZZ4_OARQ := cOOarq
   MsUnLock()

   oDlgSales:End()
   
Return(.T.)

// ################################################################################################
// Função que abre janela de informação de usuários com acesso as transferências / Mov. Internas ##
// ################################################################################################
Static Function par_transf()

   Local cSql       := ""
   Local cTransfere := Space(250)
   Local cInternas  := Space(250)
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oGet1
   Local oGet2
   Local oMemo1
   Local oMemo2

   Private oDlgTM
  
   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TRFS,"
   cSql += "       ZZ4_MVIN "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cTransfere := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_TRFS)
   cInternas  := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_MVIN)

   DEFINE MSDIALOG oDlgTM TITLE "Transferências de Mercadorias / Movimentações Internas" FROM C(178),C(181) TO C(388),C(622) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgTM

   @ C(038),C(005) Say "Usuários com acesso as Transferências de Mercadorias (Informar: 000001|000002|)" Size C(201),C(008) COLOR CLR_BLACK PIXEL OF oDlgTM
   @ C(061),C(005) Say "Usuários com acesso as Movimetações Internas (Informar: 000001|0000002|)"        Size C(185),C(008) COLOR CLR_BLACK PIXEL OF oDlgTM

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(213),C(001) PIXEL OF oDlgTM
   @ C(084),C(002) GET oMemo2 Var cMemo2 MEMO Size C(213),C(001) PIXEL OF oDlgTM
   
   @ C(048),C(005) MsGet oGet1 Var cTransfere Size C(211),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTM
   @ C(071),C(005) MsGet oGet2 Var cInternas  Size C(211),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTM

   @ C(088),C(178) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgTM ACTION( SalvaTrf(cTransfere, cInternas) )

   ACTIVATE MSDIALOG oDlgTM CENTERED 

Return(.T.)

// #########################################################################################
// Função que grava os usuários com permissão de acesso as transferências / Mov; Internas ##
// #########################################################################################
Static Function SalvaTrf(cTransfere, cInternas)

   Local cSql    := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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

   ZZ4->ZZ4_TRFS := cTransfere
   ZZ4->ZZ4_MVIN := cInternas
   MsUnLock()

   oDlgTM:End()
   
Return(.T.)

// #########################################################################
// Função que abre janela de configurações de importação de tipos de XMLs ##
// #########################################################################
Static Function Imp_XML()

   Local cSql    := ""
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cGrupo01 := Space(25)
   Private cGrupo02 := Space(25)
   Private cGrupo03 := Space(25)
   Private cGrupo04 := Space(25)

   Private lComOC01 := .F.
   Private lComOC02 := .F.
   Private lComOC03 := .F.
   Private lComOC04 := .T.

   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oCheckBox4

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgX

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_XOC1,"
   cSql += "       ZZ4_XOC2,"
   cSql += "       ZZ4_XOC3,"
   cSql += "       ZZ4_XOC4,"      
   cSql += "       ZZ4_XGR1,"   
   cSql += "       ZZ4_XGR2,"   
   cSql += "       ZZ4_XGR3,"   
   cSql += "       ZZ4_XGR4 "            
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cGrupo01 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_XGR1)
   cGrupo02 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_XGR2)
   cGrupo03 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_XGR3)
   cGrupo04 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_XGR4)      

   lComOC01 := IIF(T_PARAMETROS->( EOF() ), .F., IIF(T_PARAMETROS->ZZ4_XOC1 == "1", .T., .F.))
   lComOC02 := IIF(T_PARAMETROS->( EOF() ), .F., IIF(T_PARAMETROS->ZZ4_XOC2 == "1", .T., .F.))
   lComOC03 := IIF(T_PARAMETROS->( EOF() ), .F., IIF(T_PARAMETROS->ZZ4_XOC3 == "1", .T., .F.))
   lComOC04 := IIF(T_PARAMETROS->( EOF() ), .F., IIF(T_PARAMETROS->ZZ4_XOC4 == "1", .T., .F.))

   DEFINE MSDIALOG oDlgX TITLE "Importação XML's" FROM C(178),C(181) TO C(474),C(848) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(106),C(026) PIXEL NOBORDER OF oDlgX

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(325),C(001) PIXEL OF oDlgX
   @ C(123),C(002) GET oMemo2 Var cMemo2 MEMO Size C(325),C(001) PIXEL OF oDlgX

   @ C(036),C(005) Say "Parametrize abaixo os tipos de importação de XML a serem utilizados" Size C(165),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(047),C(005) Say "Tipo de Importação"                                                  Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(047),C(067) Say "CheckBox O.Compra"                                                   Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(047),C(134) Say "Grupos a serem considerados"                                         Size C(073),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(060),C(005) Say "COMPRAS COM OC"                                                      Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(073),C(005) Say "DESPESAS"                                                            Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(086),C(005) Say "REMESSAS"                                                            Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(099),C(005) Say "DEVOLUÇÕES"                                                          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(112),C(134) Say "Preechimento dos grupos Exemplo '0100', '0200', '0300'"              Size C(129),C(008) COLOR CLR_BLACK PIXEL OF oDlgX   

   @ C(059),C(067) CheckBox oCheckBox1 Var lComOC01 Prompt "Com OC" Size C(033),C(008)                              PIXEL OF oDlgX
   @ C(059),C(134) MsGet    oGet1      Var cGrupo01                 Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(072),C(067) CheckBox oCheckBox2 Var lComOC02 Prompt "Com OC" Size C(048),C(008)                              PIXEL OF oDlgX
   @ C(072),C(134) MsGet    oGet2      Var cGrupo02                 Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(085),C(067) CheckBox oCheckBox3 Var lComOC03 Prompt "Com OC" Size C(048),C(008)                              PIXEL OF oDlgX
   @ C(085),C(134) MsGet    oGet3      Var cGrupo03                 Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX
   @ C(098),C(067) CheckBox oCheckBox4 Var lComOC04 Prompt "Com OC" Size C(048),C(008)                              PIXEL OF oDlgX
   @ C(098),C(134) MsGet    oGet4      Var cGrupo04                 Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX

   @ C(130),C(147) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgX ACTION( SalvaXML() )

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// ######################################################
// Função que grava os parâmetros de importação de XML ##
// ######################################################
Static Function SalvaXML()

   Local cSql    := ""
   
   // Verifica se existe algum registro na Tabela ZZ4010.
   // Se não existir, inclui senão altera
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

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

   ZZ4->ZZ4_XOC1 := IIF(lComOC01 == .F., "0", "1")
   ZZ4->ZZ4_XOC2 := IIF(lComOC02 == .F., "0", "1")
   ZZ4->ZZ4_XOC3 := IIF(lComOC03 == .F., "0", "1")
   ZZ4->ZZ4_XOC4 := IIF(lComOC04 == .F., "0", "1")
   ZZ4->ZZ4_XGR1 := cGrupo01
   ZZ4->ZZ4_XGR2 := cGrupo02
   ZZ4->ZZ4_XGR3 := cGrupo03
   ZZ4->ZZ4_XGR4 := cGrupo04      
   MsUnLock()

   oDlgX:End()
   
Return(.T.)

// ####################################################################
// Função que abre janela para manutenção dos parâmetros do SimFrete ##
// ####################################################################
Static Function Par_SimFrete()

   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cURLSimFrete     := Space(250)
   Private cEmpresaSimFrete := Space(50)
   Private cLoginSimFrete   := Space(20)
   Private cSenhaSimfrete   := Space(20)
   Private cEmailSimFrete   := Space(250)
   Private cDiretorioRet    := Space(250)

   Private oGet1 
   Private oGet2 
   Private oGet3 
   Private oGet4 
   Private oGet5 
   Private oGet6 
   
   Private oDlgSF

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_SFRE)) AS SIMFRETE"    
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cURLSimFrete     := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1)))
   cEmpresaSimFrete := IIF(T_PARAMETROS->( EOF() ), Space(050), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2))), Space(050), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2)))
   cLoginSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3)))
   cSenhaSimfrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4)))
   cEmailSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5)))
   cDiretorioRet    := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6)))

   cURLSimFrete     := Alltrim(cURLSimFrete)     + Space(250 - Len(Alltrim(cURLSimFrete)))
   cEmpresaSimFrete := Alltrim(cEmpresaSimFrete) + Space(050 - Len(Alltrim(cEmpresaSimFrete)))
   cLoginSimFrete   := Alltrim(cLoginSimFrete)   + Space(020 - Len(Alltrim(cLoginSimFrete)))
   cSenhaSimfrete   := Alltrim(cSenhaSimfrete)   + Space(020 - Len(Alltrim(cSenhaSimfrete)))
   cEmailSimFrete   := Alltrim(cEmailSimFrete)   + Space(250 - Len(Alltrim(cEmailSimFrete)))
   cDiretorioRet    := Alltrim(cDiretorioRet)    + Space(250 - Len(Alltrim(cDiretorioRet)))

   DEFINE MSDIALOG oDlgSF TITLE "Parãmetros SimFrete" FROM C(178),C(181) TO C(570),C(653) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgSF

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(229),C(001) PIXEL OF oDlgSF
   @ C(173),C(002) GET oMemo2 Var cMemo2 MEMO Size C(229),C(001) PIXEL OF oDlgSF

   @ C(037),C(005) Say "URL Web Service SimFrete"                                         Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgSF
   @ C(060),C(005) Say "Empresa cadastrada para acesso ao Web Service"                    Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlgSF
   @ C(082),C(005) Say "Usuário"                                                          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgSF
   @ C(105),C(005) Say "Senha"                                                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSF
   @ C(127),C(005) Say "Endereço e-mail SimFrete que irá receber o XML das notas fiacais" Size C(159),C(008) COLOR CLR_BLACK PIXEL OF oDlgSF
   @ C(149),C(005) Say "Diretório de retorno da pesquisa do web service Sim-Frete"        Size C(116),C(008) COLOR CLR_BLACK PIXEL OF oDlgSF

   @ C(047),C(005) MsGet oGet1 Var cURLSimFrete     Size C(227),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgSF
   @ C(069),C(005) MsGet oGet2 Var cEmpresaSimFrete Size C(120),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgSF
   @ C(092),C(005) MsGet oGet3 Var cLoginSimFrete   Size C(068),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgSF
   @ C(114),C(005) MsGet oGet4 Var cSenhaSimfrete   Size C(068),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgSF
   @ C(136),C(005) MsGet oGet5 Var cEmailSimFrete   Size C(227),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgSF
   @ C(159),C(005) MsGet oGet6 Var cDiretorioRet    Size C(227),C(009) COLOR CLR_BLACK Picture "@x" PIXEL OF oDlgSF

   @ C(178),C(098) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgSF  ACTION( Salvasfrete() )

   ACTIVATE MSDIALOG oDlgSF CENTERED 

Return(.T.)

// #############################################
// Função que grava os parâmetros do SimFrete ##
// #############################################
Static Function Salvasfrete()

   Local cSql    := ""
   
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

   ZZ4->ZZ4_SFRE := Alltrim(cURLSimFrete)     + "|" + ;
                    Alltrim(cEmpresaSimFrete) + "|" + ;
                    Alltrim(cLoginSimFrete)   + "|" + ;
                    Alltrim(cSenhaSimfrete)   + "|" + ;
                    Alltrim(cEmailSimFrete)   + "|" + ;
                    Alltrim(cDiretorioRet)    + "|"
   MsUnLock()

   oDlgSF:End()
   
Return(.T.)

// ###########################################################################################
// Função que abre janela para informação dos grupos com permissão para cálculo do SimFrete ##
// ###########################################################################################
Static Function Par_CalSimFrete()

   Local cMemo1	      := ""
   Local oMemo1

   Private cAgrupos     := Space(250)
   Private cNgrupos     := Space(250)
   Private lTodosGrupos := .F.
   Private oCheckBox1
   Private oGet1
   Private oGet2

   Private oDlgASF

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TGRU, "
   cSql += "       ZZ4_AGRU, "
   cSql += "       ZZ4_NGRU  "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cAgrupos     := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_AGRU)
   cNgrupos     := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_NGRU)
   lTodosGrupos := IIF(T_PARAMETROS->( EOF() ), .F.       , IIF(T_PARAMETROS->ZZ4_TGRU == "S", .T., .F.))

   DEFINE MSDIALOG oDlgASF TITLE "Acesso ao Cálculo SimFrete" FROM C(178),C(181) TO C(395),C(681) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(022) PIXEL NOBORDER OF oDlgASF

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(241),C(001) PIXEL OF oDlgASF

   @ C(046),C(005) Say "Grupos de usuários com permissão para cálculo do SimFrete (Informar grupos separados por | )" Size C(226),C(008) COLOR CLR_BLACK PIXEL OF oDlgASF
   @ C(068),C(005) Say "Usuário(s) que não necessitam de acesso ao cálculo do SimFrete mesmo com grupo liberado"      Size C(220),C(008) COLOR CLR_BLACK PIXEL OF oDlgASF
   
   @ C(033),C(005) CheckBox oCheckBox1 Var lTodosGrupos Prompt "Todos os grupo de usuários possuem permissão para cálculo do SimFrete" Size C(187),C(008) PIXEL OF oDlgASF
   @ C(055),C(005) MsGet    oGet1      Var cAgrupos     Size C(239),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgASF
   @ C(077),C(005) MsGet    oGet2      Var cNgrupos     Size C(239),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgASF

   @ C(092),C(207) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgASF ACTION( SalvasASF() )

   ACTIVATE MSDIALOG oDlgASF CENTERED 

Return(.T.)

// #######################################################
// Função que grava os parâmetros do Acesso ao SimFrete ##
// #######################################################
Static Function SalvasASF()

   Local cSql    := ""
   
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

   ZZ4->ZZ4_TGRU := IIF(lTodosGrupos == .F., "N", "S")
   ZZ4->ZZ4_AGRU := cAgrupos
   ZZ4->ZZ4_NGRU := cNgrupos
   MsUnLock()

   oDlgASF:End()
   
Return(.T.)

// ############################################################################
// Função que abre janela para informação do percentual de custo de produção ##
// ############################################################################
Static Function Par_CustoProd()

   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cCustoP := 0
   Private oGet1

   Private oDlgCP

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_PCPR"
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cCustoP := IIF(T_PARAMETROS->( EOF() ), 0, T_PARAMETROS->ZZ4_PCPR)

   DEFINE MSDIALOG oDlgCP TITLE "Custo de Produção" FROM C(178),C(181) TO C(386),C(583) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgCP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(195),C(001) PIXEL OF oDlgCP
   @ C(080),C(002) GET oMemo2 Var cMemo2 MEMO Size C(195),C(001) PIXEL OF oDlgCP

   @ C(036),C(005) Say "Percentual a ser considerado para Cálculo de Custo de Venda Sales Machine."     Size C(187),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP
   @ C(045),C(005) Say "Este percentual será aplicado para o Cálculo de Margem para produtos Etiqueta." Size C(192),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP
   @ C(057),C(086) Say "Percentual"                                                                     Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgCP

   @ C(066),C(086) MsGet oGet1 Var cCustoP Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCP

   @ C(087),C(081) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCP ACTION( GrvCProducao() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #####################################################
// Função que grava o percentual de custo de produção ##
// #####################################################
Static Function GrvCProducao()

   Local cSql    := ""
   
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

   ZZ4->ZZ4_PCPR := cCustoP
   MsUnLock()

   oDlgCP:End()
   
Return(.T.)

// ###############################################################
// Função que abre janela de informação dos fabricantes para OS ##
// ###############################################################
Static Function FabricOS()

   Local cMemo1	  := ""
   Local oMemo1

   Local cFabri01 := Space(250)
   Local cFabri02 := Space(250)
   Local cFabri03 := Space(250)

   Local oGet1
   Local oGet5
   Local oGet6

   Private oDlgFAB

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FAB1,"
   cSql += "       ZZ4_FAB2,"
   cSql += "       ZZ4_FAB3 "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cFabri01 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_FAB1)
   cFabri02 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_FAB2)
   cFabri03 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_FAB3)   

   DEFINE MSDIALOG oDlgFAB TITLE "Fabricante Ordem de Serviço" FROM C(178),C(181) TO C(399),C(782) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgFAB

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(293),C(001) PIXEL OF oDlgFAB

   @ C(036),C(005) Say "Informe o primeiro nome do Fabricante a ser carregado no combo Fabricante da Ordem de Serviço" Size C(233),C(008) COLOR CLR_BLACK PIXEL OF oDlgFAB
   @ C(045),C(005) Say "IMPORTANTE: Serapar o nome do fabricante com |"                                                Size C(128),C(008) COLOR CLR_BLACK PIXEL OF oDlgFAB

   @ C(056),C(005) MsGet oGet1 Var cFabri01 Size C(291),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgFAB
   @ C(066),C(005) MsGet oGet5 Var cFabri02 Size C(291),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgFAB
   @ C(077),C(005) MsGet oGet6 Var cFabri03 Size C(291),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgFAB

   @ C(092),C(131) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgFAB ACTION( GrvFabricante(cFabri01, cFabri02, cFabri03) )

   ACTIVATE MSDIALOG oDlgFAB CENTERED 

Return(.T.)

// #####################################################
// Função que grava o percentual de custo de produção ##
// #####################################################
Static Function GrvFabricante(kFabric01, kFabric02, kFabric03)

   Local cSql    := ""
   
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

   ZZ4->ZZ4_FAB1 := kFabric01
   ZZ4->ZZ4_FAB2 := kFabric02
   ZZ4->ZZ4_FAB3 := kFabric03   
   MsUnLock()

   oDlgFAB:End()
   
Return(.T.)

// ##################################################################################
// Função que abre a tela de manutenção do setores de transferência de mercadorias ##
// ##################################################################################
Static Function Pro_setores()

   Local cMemo1	 := ""
   Local oMemo1

   Local cSetores := Space(250)
   Local oGet1

   Private oDlgSET

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SETO FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cSetores := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_SETO)

   DEFINE MSDIALOG oDlgSET TITLE "Transferência de Mercadorias" FROM C(178),C(181) TO C(330),C(744) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgSET

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(274),C(001) PIXEL OF oDlgSET

   @ C(036),C(005) Say "Indique os setores que poderão solicitar transferência de mercaodrias" Size C(169),C(008) COLOR CLR_BLACK PIXEL OF oDlgSET
   @ C(058),C(005) Say "Separar os setores com ( | ) "                                         Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlgSET

   @ C(045),C(005) MsGet oGet1 Var cSetores Size C(273),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSET

   @ C(059),C(240) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgSET ACTION( SalvaSetores( cSetores) )

   ACTIVATE MSDIALOG oDlgSET CENTERED 

Return(.T.)

// ###############################################################
// Função que grava os setores de transferências de mercadorias ##
// ###############################################################
Static Function SalvaSetores(kSetores)

   Local cSql    := ""
   
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

   ZZ4->ZZ4_SETO := kSetores
   MsUnLock()

   oDlgSET:End()
   
Return(.T.)

// ###################################################################################
// Função que abre a tela de manutenção da liberação de acesso a análide se crédito ##
// ###################################################################################
Static Function AnaCredito()

   Local cCredito01	 := Space(250)
   Local cCredito02  := Space(250)
   Local cMemo1	     := ""
   Local cMemo2	     := ""

   Local oGet1
   Local oGet2
   Local oMemo1
   Local oMemo2

   Private oDlgCRE

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LCRE1, ZZ4_LCRE2 FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cCredito01 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_LCRE1)
   cCredito02 := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_LCRE2)

   DEFINE MSDIALOG oDlgCRE TITLE "Análise de Crédito" FROM C(178),C(181) TO C(540),C(752) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgCRE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(278),C(001) PIXEL OF oDlgCRE
   @ C(128),C(002) GET oMemo2 Var cMemo2 MEMO Size C(278),C(001) PIXEL OF oDlgCRE
   
   @ C(037),C(005) Say "Este parâmetro tem por finalidade de liberar o programa de Análise de Crédito de Pedidos para determinados usuários." Size C(277),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(045),C(005) Say "Além desta liberação, também poderá ser liberado as condições de pagamento que o usuário poderá analisar."            Size C(260),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(053),C(005) Say "Para o correto preenchimento deste parâmetro, observe a forma de preechimento."                                       Size C(196),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(065),C(005) Say "EXEMPLO 01 ->"                                                                                                        Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(065),C(050) Say "000001#018#020#|"                                                                                                     Size C(051),C(008) COLOR CLR_RED   PIXEL OF oDlgCRE
   @ C(078),C(005) Say "No exemplo acima, o parâmetro está indicando que o usuário de código 000001 poderá realiazar análise de crédito"      Size C(273),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(086),C(005) Say "porém, somente poderá analisar pedidos que contenham as condições de pagamento 018 e 020."                            Size C(232),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(098),C(005) Say "EXEMPLO 02 ->"                                                                                                        Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(098),C(050) Say "000001#999#|"                                                                                                         Size C(049),C(008) COLOR CLR_RED   PIXEL OF oDlgCRE
   @ C(108),C(005) Say "Neste segundo exemplo, indica que o usuário de código 000001 porderá realizar análise de crédito não levando em"      Size C(274),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(117),C(005) Say "consideração as condições de pagamento, ou seja, poderá liberar qualquer pedido de venda."                            Size C(224),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE
   @ C(132),C(005) Say "Usuários/Condições de Pagamentos"                                                                                     Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlgCRE

   @ C(141),C(005) MsGet oGet1 Var cCredito01 Size C(275),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCRE
   @ C(150),C(005) MsGet oGet2 Var cCredito02 Size C(275),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCRE

   @ C(164),C(124) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCRE ACTION( SlvAnaCrerdito(cCredito01, cCredito02) )

   ACTIVATE MSDIALOG oDlgCRE CENTERED 

Return(.T.)

// ########################################################
// Função que grava os liberadores de Análise de Crédito ##
// ########################################################
Static Function SlvAnaCrerdito(kCredito01, kCredito02)

   Local cSql    := ""
   
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

   ZZ4->ZZ4_LCRE1 := kCredito01
   ZZ4->ZZ4_LCRE2 := kCredito02
   MsUnLock()

   oDlgCRE:End()
   
Return(.T.)

// ##############################################################################################
// Função que abre a tela para inclusão de grupos para Descrição de OS no Cadastro de Produtos ##
// ##############################################################################################
Static Function GruposOS()

   Local cMemo1	   := ""
   Local oMemo1

   Local cGruposOS := Space(250)
   Local oGet1

   Private oDlgGRP

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GDES FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cGruposOS := IIF(T_PARAMETROS->( EOF() ), Space(250), T_PARAMETROS->ZZ4_GDES)

   DEFINE MSDIALOG oDlgGRP TITLE "Grupos para Descrição para OS" FROM C(178),C(181) TO C(346),C(631) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(113),C(022) PIXEL NOBORDER OF oDlgGRP

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(217),C(001) PIXEL OF oDlgGRP

   @ C(033),C(005) Say "Informe abaixo os códigos dos grupo, concatenados por |, que permitem editar a Descrição" Size C(215),C(008) COLOR CLR_BLACK PIXEL OF oDlgGRP
   @ C(042),C(005) Say "para Ordem de Serviço no cadastro de Produtos."                                           Size C(117),C(008) COLOR CLR_BLACK PIXEL OF oDlgGRP

   @ C(052),C(005) MsGet oGet1 Var cGruposOS Size C(215),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgGRP

   @ C(067),C(094) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgGRP ACTION( SlvGruposOS(cGruposOS) )

   ACTIVATE MSDIALOG oDlgGRP CENTERED 

Return(.T.)

// ##################################################
// Função que grava os grupos para descrição da OS ##
// ##################################################
Static Function SlvGruposOS(cGruposOS)

   Local cSql    := ""
   
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

   ZZ4->ZZ4_GDES := cGruposOS
   MsUnLock()

   oDlgGRP:End()
   
Return(.T.)

// ##########################################################################################
// Função que determina quais usuários podem alterar as embalagens e dimensões de produtos ##
// ##########################################################################################
Static Function Pro_Dimensao()

   Local cSql           := ""

   Private cLiberadores := Space(200)
   Private oGet1

   Private oDlgL

   // Pesquisa os valores para display
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ADIM" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cliberadores := T_PARAMETROS->ZZ4_ADIM
   Endif

   DEFINE MSDIALOG oDlgL TITLE "Liberadores de Embalagem/Dimensões de Produtos" FROM C(178),C(181) TO C(291),C(746) PIXEL
 
   @ C(005),C(005) Say "Informe abaixo os usuários que podem alterar Embalagens e Dimensões do Cadastro de Produtos." Size C(272),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(014),C(005) Say "Informe os usuários separando-os com |"                                                       Size C(137),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(024),C(005) MsGet oGet1 Var cLiberadores Size C(271),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL

   @ C(038),C(121) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( fechaDimensao( cLiberadores) )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// ################################################################################################
// Função que grava os Usuários que podem alterar Embalagens e Dimensões do Cadastro de Produtos ##
// ################################################################################################
Static Function FechaDimensao(_Liberadores)

   Local cSql := ""

   // ######################################################   
   // Verifica se existe algum registro na Tabela ZZ4010. ##
   // Se não existir, inclui senão altera                 ##
   // ######################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
      ZZ4_ADIM   := _Liberadores
   Else
      RecLock("ZZ4",.F.)     
      ZZ4_ADIM   := _Liberadores
   Endif

   MsUnLock()

   oDlgL:End() 
   
Return(.T.)