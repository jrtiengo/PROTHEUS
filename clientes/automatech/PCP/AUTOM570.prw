#INCLUDE "rwmake.ch"
#INCLUDE "jpeg.ch"    
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM570.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 10/05/2017                                                          ##
// Objetivo..: Painel Template Produção                                            ##
// ##################################################################################

User Function AUTOM570()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private dInicial  := Ctod("  /  /    ")
   Private dFinal 	 := Ctod("  /  /    ")
   Private cCliente	 := Space(06)
   Private cLoja 	 := Space(03)
   Private cNomeCli	 := Space(60)
   Private cProduto	 := Space(30)
   Private cNomePro	 := Space(60)
   Private cString   := Space(60)
   Private cPedido	 := Space(06)
   Private cProducao := Space(11)

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

   Private aTipoData	 := {"1 - Dta Inc. OP", "2 - Data Entrega"}
   Private aVendedor	 := {}
   Private aStatus01	 := {"0 - Todos", "1 - Abertas", "2 - Fechadas"}
   Private aStatus02	 := {"0 - Todos", "1 - No Prazo", "2 - Em Atraso", "3 - Antecipado", "4 - Em Produção"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

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

   Private aBrowse   := {}

   Private aLista    := {}

   Private cGramat := ''
   Private cMetr   :=	''
   Private cEtqRol :=	''
   Private cRolos  :=	''
   Private nMetr   := 0
   Private nEtqRol := 0
   Private nRolos  := 0

   Private aHead   := {}

   Private oDlg

   // ######################################################
   // Carrega o array aHead com o cabeçalho para o execel ##
   // ######################################################
   aAdd( aHead, 'Obs'               )
   aAdd( aHead, 'Nº Pedido'         )
   aAdd( aHead, 'Código'            )
   aAdd( aHead, 'Loja'              )
   aAdd( aHead, 'Clientes'          )
   aAdd( aHead, 'Código'            )
   aAdd( aHead, 'Vendedores'        )
   aAdd( aHead, 'Dta Emi. OP'       )
   aAdd( aHead, 'Nº OP'             )
   aAdd( aHead, 'Sts OP'            )
   aAdd( aHead, 'Dta Ent. Origem'   )
   aAdd( aHead, 'Dta Entrega'       )
   aAdd( aHead, 'Dta Finalizada'    )
   aAdd( aHead, 'Sts Fin.'          )
   aAdd( aHead, 'Cod.Produto'       )
   aAdd( aHead, 'Item da OP'        )
   aAdd( aHead, 'Medida Faca'       )
   aAdd( aHead, 'Papel'             )
   aAdd( aHead, 'Tubete'            )
   aAdd( aHead, 'Serrilha'          )
   aAdd( aHead, 'Característica'    )
   aAdd( aHead, 'Quant. OP'         )
   aAdd( aHead, 'Und'               )
   aAdd( aHead, 'Metros Lineares'   )
   aAdd( aHead, 'M2'                )
   aAdd( aHead, 'Quant. Empenho'    )
   aAdd( aHead, 'Quant. Fecham.'    )
   aAdd( aHead, 'Cod.Comp.'         )
   aAdd( aHead, 'Componentes'       )
   aAdd( aHead, 'Cód.Transp.'       )
   aAdd( aHead, 'Transportadoras'   )
   aAdd( aHead, 'Máquina 01'        )
   aAdd( aHead, 'Operador 01'       )
   aAdd( aHead, 'Tempo 01'          )
   aAdd( aHead, 'Máquina 02'        )
   aAdd( aHead, 'Operador 02'       )
   aAdd( aHead, 'Tempo 02'          )

   // ################################
   // Carrega o combo de vendedores ##
   // ################################
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A3_COD   ,"
   cSql += "       A3_NOME  ,"
   cSql += "       A3_CODUSR,"
   cSql += "       A3_TSTAT ,"
   cSql += "       A3_OUTR   "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND A3_CODUSR  <> ''"
   cSql += "   AND D_E_L_E_T_  = ''"
   cSql += " ORDER BY A3_NOME      "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   aAdd( avendedor, "000000 - Todos os Vendedores" )

   T_VENDEDOR->( DbGoTop() )
   
   WHILE !T_VENDEDOR->( EOF() )
      aAdd( aVendedor, T_VENDEDOR->A3_COD + " - " + Alltrim(T_VENDEDOR->A3_NOME) )
      T_VENDEDOR->( DbSkip() )
   ENDDO   

   DEFINE MSDIALOG oDlg TITLE "Painel Template" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(080),C(002) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlg
                                          
   @ C(036),C(005) Say "Data Inicial"      Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(041) Say "Data Final"        Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(077) Say "Tipo Data"         Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(136) Say "Cliente"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(319) Say "Vendedor"          Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Produto"           Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(163) Say "Descrição Produto" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(264) Say "Ped.Venda"         Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(303) Say "O.Produção"        Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(342) Say "Status 1"          Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(398) Say "Status 2"          Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(350) Say "Clique no título da coluna para ordenar os dados" Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet    oGet1     Var   dInicial  Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(041) MsGet    oGet2     Var   dFinal    Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(077) ComboBox cComboBx1 Items aTipoData Size C(056),C(010)                              PIXEL OF oDlg
   @ C(045),C(136) MsGet    oGet3     Var   cCliente  Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1") 
   @ C(045),C(163) MsGet    oGet4     Var   cLoja     Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( CargaCli() )
   @ C(045),C(182) MsGet    oGet5     Var   cNomeCli  Size C(133),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(319) ComboBox cComboBx2 Items aVendedor Size C(179),C(010)                              PIXEL OF oDlg
   @ C(067),C(005) MsGet    oGet6     Var   cProduto  Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( CargaPro() )
   @ C(067),C(054) MsGet    oGet7     Var   cNomePro  Size C(105),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(067),C(163) MsGet    oGet10    Var   cString   Size C(097),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(067),C(264) MsGet    oGet8     Var   cPedido   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(067),C(303) MsGet    oGet9     Var   cProducao Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(067),C(342) ComboBox cComboBx3 Items aStatus01 Size C(053),C(010)                              PIXEL OF oDlg
   @ C(067),C(398) ComboBox cComboBx4 Items aStatus02 Size C(053),C(010)                              PIXEL OF oDlg

   @ C(064),C(459) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( CargaGrid() )

   @ C(210),C(005) Button "Apontamento"        Size C(037),C(012) PIXEL OF oDlg ACTION( MaqTempo(aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,15], aBrowse[oBrowse:nAt,16], aBrowse[oBrowse:nAt,32], aBrowse[oBrowse:nAt,33], aBrowse[oBrowse:nAt,34], aBrowse[oBrowse:nAt,35], aBrowse[oBrowse:nAt,36], aBrowse[oBrowse:nAt,37], aBrowse[oBrowse:nAt,38], aBrowse[oBrowse:nAt,39], aBrowse[oBrowse:nAt,40]) )
   @ C(210),C(044) Button "Observações"        Size C(037),C(012) PIXEL OF oDlg ACTION( xxObserva(aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,15], aBrowse[oBrowse:nAt,16]) )
// @ C(210),C(083) Button "Roteiro Acabamento" Size C(053),C(012) PIXEL OF oDlg ACTION( ImpRotAcaba(aBrowse[oBrowse:nAt,09]) )
   @ C(210),C(083) Button "Roteiro Acabamento" Size C(053),C(012) PIXEL OF oDlg ACTION( xImpRotAcaba(aBrowse[oBrowse:nAt,09]) )
//////   @ C(210),C(137) Button "Excel"              Size C(037),C(012) PIXEL OF oDlg ACTION( Geraexcel(aBrowse[oBrowse:nAt,09]) )
   @ C(210),C(137) Button "Excel"              Size C(037),C(012) PIXEL OF oDlg ACTION( TGeraPCSV(aBrowse[oBrowse:nAt,09]) )
   @ C(210),C(175) Button "Em Arquivo"         Size C(037),C(012) PIXEL OF oDlg ACTION( GeraArquivo(aBrowse[oBrowse:nAt,09]) )
   @ C(210),C(214) Button "Legenda"            Size C(037),C(012) PIXEL OF oDlg ACTION( MostraLegenda() )
   @ C(210),C(253) Button "Consulta Facas"     Size C(053),C(012) PIXEL OF oDlg ACTION( U_AUTOM599() )
   @ C(210),C(461) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "1", "", "", "", "", "", "", "", "", "1", "", "", "", "1", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } ) 

   oBrowse := TCBrowse():New( 110 , 005, 633, 155,,{'Obs'               ,; // 01
                                                    'Nº Pedido'         ,; // 02
                                                    'Código'            ,; // 03
                                                    'Loja'              ,; // 04
                                                    'Clientes'          ,; // 05
                                                    'Código'            ,; // 06
                                                    'Vendedores'        ,; // 07
                                                    'Dta Emi. OP'       ,; // 08
                                                    'Nº OP'             ,; // 09
                                                    'Sts OP'            ,; // 10
                                                    'Dta Ent. Orig.'    ,; // 11
                                                    'Dta Entrega'       ,; // 12
                                                    'Dta Finalizada'    ,; // 13
                                                    'Sts Fin.'          ,; // 14
                                                    'Cod.Produto'       ,; // 15
                                                    'Item da OP'        ,; // 16  
                                                    'Medida Faca'       ,; // 17
                                                    'Papel'             ,; // 18
                                                    'Tubete'            ,; // 19
                                                    'Serrilha'          ,; // 20
                                                    'Característica'    ,; // 21
                                                    'Quant. OP'         ,; // 22
                                                    'Und'               ,; // 23
                                                    'Metros Lineares'   ,; // 24
                                                    'M2'                ,; // 25
                                                    'Quant. Empenho'    ,; // 26   
                                                    'Quant. Fecham.'    ,; // 27
                                                    'Cod.Comp.'         ,; // 28
                                                    'Componentes'       ,; // 29
                                                    'Cód.Transp.'       ,; // 30
                                                    'Transportadoras'   ,; // 31
                                                    'Máquina 01'        ,; // 32
                                                    'Operador 01'       ,; // 33
                                                    'Tempo 01'          ,; // 34
                                                    'Máquina 02'        ,; // 35
                                                    'Operador 02'       ,; // 36
                                                    'Tempo 02'          ,; // 37
                                                    'Máquina 03'        ,; // 38
                                                    'Operador 03'       ,; // 39
                                                    'Tempo 03'          }, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // 40
   
   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,15],;
                         aBrowse[oBrowse:nAt,16],;
                         aBrowse[oBrowse:nAt,17],;
                         aBrowse[oBrowse:nAt,18],;
                         aBrowse[oBrowse:nAt,19],;
                         aBrowse[oBrowse:nAt,20],;
                         aBrowse[oBrowse:nAt,21],;
                         aBrowse[oBrowse:nAt,22],;
                         aBrowse[oBrowse:nAt,23],;
                         aBrowse[oBrowse:nAt,24],;
                         aBrowse[oBrowse:nAt,25],;
                         aBrowse[oBrowse:nAt,26],;
                         aBrowse[oBrowse:nAt,27],;
                         aBrowse[oBrowse:nAt,28],;
                         aBrowse[oBrowse:nAt,29],;
                         aBrowse[oBrowse:nAt,30],;
                         aBrowse[oBrowse:nAt,31],;
                         aBrowse[oBrowse:nAt,32],;
                         aBrowse[oBrowse:nAt,33],;
                         aBrowse[oBrowse:nAt,34],;
                         aBrowse[oBrowse:nAt,35],;
                         aBrowse[oBrowse:nAt,36],;
                         aBrowse[oBrowse:nAt,37],;
                         aBrowse[oBrowse:nAt,38],;
                         aBrowse[oBrowse:nAt,39],;
                         aBrowse[oBrowse:nAt,40]}}
   
   oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################
// Função que ordena o grid conforme coluna selecionada ##
// #######################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// ##########################################
// Função que pesquisa o cliente informado ##
// ##########################################
Static Function CargaCli()

   If Alltrim(cCliente) + Alltrim(cLoja) == ""
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()
      Return(.T.)
   Endif
                  
   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_NOME")

   If Empty(alltrim(cNomeCli))
      MsgAlert("Cliente inexistente.")
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()
      Return(.T.)
   Endif

Return(.T.)

// ##########################################
// Função que pesquisa o produto informado ##
// ##########################################
Static Function CargaPro()

   If Empty(Alltrim(cProduto))
      cProduto := Space(30)
      cNomePro := Space(60)
      oGet6:Refresh()
      oGet7:Refresh()
      Return(.T.)
   Endif

   If Len(alltrim(cProduto)) <= 6
      MsgAlert("Código Produto não é etiqueta.")
      cProduto := Space(30)
      cNomePro := Space(60)
      oGet6:Refresh()
      oGet7:Refresh()
      Return(.T.)
   Endif
                  
   cNomePro := POSICIONE("SB1",1,XFILIAL("SB1") + cProduto,"B1_DESC")

   If Empty(alltrim(cNomePro))
      MsgAlert("Produto inexistente.")
      cProduto := Space(30)
      cNomePro := Space(60)
      oGet6:Refresh()
      oGet7:Refresh()
      Return(.T.)
   Endif

Return(.T.)

// ##############################################################
// Função que carrega o grid conforme os parâmetros informados ##
// ##############################################################
Static Function CargaGrid()

   MsgRun("Aguarde! Gerando Template ...", "Painel Template",{|| xCargaGrid() })

Return(.T.)

// ##############################################################
// Função que carrega o grid conforme os parâmetros informados ##
// ##############################################################
Static Function xCargaGrid()

   Local cSql := ""

   // #######################################
   // Consiste os dados antes da pesquiusa ##
   // #######################################
   If dInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial de pesquisa não informada.")
      Return(.T.)
   Endif
      
   If dFinal == Ctod("  /  /    ")
      MsgAlert("Data final de pesquisa não informada.")
      Return(.T.)
   Endif
   
   // ########################
   // Limpa o array aBrowse ##
   // ########################
   aBrowse := {}

   // #########################################
   // Realiza a pesquisa conforme parâmetros ##
   // #########################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC2.C2_PEDIDO ," + chr(13) 
   cSql += "       SC2.C2_ITEMPV ," + Chr(13)
   cSql += "       SC2.C2_ITEM   ," + chr(13) 
   cSql += "       SC2.C2_PRODUTO," + chr(13) 
   cSql += "      (LTRIM(RTRIM(SB1.B1_DESC)) + '' + LTRIM(RTRIM(SB1.B1_DAUX))) AS NOME_PRO ," + chr(13) 
   cSql += "       SC2.C2_QUANT  ," + chr(13)
   cSql += "       SC2.C2_UM     ," + chr(13)
   cSql += "       SC2.C2_NUM    ," + Chr(13)
   cSql += "       SC2.C2_SEQUEN ," + Chr(13) 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), SC2.C2_OBSI)) AS OBSERVACAO,"
   cSql += "       SC2.C2_MAQU   ," + Chr(13)
   cSql += "       SC2.C2_OPER   ," + Chr(13)
   cSql += "       SC2.C2_TPRO   ," + Chr(13)
   cSql += "       SC2.C2_MAQ2   ," + Chr(13)
   cSql += "       SC2.C2_OPE2   ," + Chr(13)
   cSql += "       SC2.C2_TPR2   ," + Chr(13)
   cSql += "       SC2.C2_MAQ3   ," + Chr(13)
   cSql += "       SC2.C2_OPE3   ," + Chr(13)
   cSql += "       SC2.C2_TPR3   ," + Chr(13)
   cSql += "       SC2.C2_DATPRF ," + Chr(13)
   cSql += "       SC2.C2_ZDOE   ," + Chr(13)

   // ###############################
   // Pesquisa o código do cliente ##
   // ###############################
   cSql += "      (SELECT C5_CLIENTE " + chr(13) 
   cSql += "         FROM " + RetSqlName("SC5") + chr(13) 
   cSql += "        WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
   cSql += "          AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
   cSql += "          AND D_E_L_E_T_ = '') AS CLIENTE,"  + chr(13) 

   // #######################################
   // Pesquisa o código da loja do cliente ##
   // #######################################
   cSql += "      (SELECT C5_LOJACLI " + chr(13) 
   cSql += "         FROM " + RetSqlName("SC5") + chr(13) 
   cSql += "        WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
   cSql += "          AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
   cSql += "          AND D_E_L_E_T_ = '')  AS LOJA,"  + chr(13) 

   // #############################
   // Pesquisa o nome do cliente ##
   // #############################
   cSql += "      (SELECT A1_NOME " + chr(13) 
   cSql += "         FROM " + RetSqlName("SA1") + chr(13) 
   cSql += "	       WHERE A1_COD  = (SELECT C5_CLIENTE " + chr(13) 
   cSql += "                           FROM " + RetSqlName("SC5") + chr(13) 
   cSql += "                          WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
   cSql += "                            AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
   cSql += "                            AND D_E_L_E_T_ = '')" + chr(13) 
   cSql += "    	     AND A1_LOJA = (SELECT C5_LOJACLI"  + chr(13) 
   cSql += "                           FROM " + RetSqlName("SC5") + chr(13) 
   cSql += "                          WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
   cSql += "                            AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
   cSql += "                            AND D_E_L_E_T_ = '')) AS NOMECLI," + chr(13) 

   // ################################
   // Pesquisa o código do vendedor ##
   // ################################
   cSql += "       (SELECT C5_VEND1 " + chr(13) 
   cSql += "          FROM " + RetSqlName("SC5") + chr(13) 
   cSql += "         WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
   cSql += "           AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
   cSql += "           AND D_E_L_E_T_ = '')  AS VENDEDOR," + chr(13) 

   // ##############################
   // Pesquisa o nome do vendedor ##
   // ##############################
   cSql += "       (SELECT top(1) A3_NOME " + chr(13) 
   cSql += "          FROM " + RetSqlName("SA3") + chr(13) 
   cSql += "     	WHERE A3_COD  = (SELECT C5_VEND1" + chr(13) 
   cSql += "                            FROM " + RetSqlName("SC5") + chr(13) 
   cSql += "                           WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
   cSql += "                             AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
   cSql += "                             AND D_E_L_E_T_ = '')) AS NOMEVEN," + chr(13) 
   cSql += "        SC2.C2_EMISSAO," + chr(13) 
   cSql += "       (SC2.C2_NUM + '-' + SC2.C2_ITEM + '-' + SC2.C2_SEQUEN) AS PRODUCAO," + chr(13) 

   // ###############################################
   // Pesquisa data prevista de entrega do produto ##
   // ###############################################
   cSql += "       (SELECT C6_ENTREG " + chr(13) 
   cSql += "          FROM " + RetSqlName("SC6") + chr(13) 
   cSql += "         WHERE C6_FILIAL  = SC2.C2_FILIAL " + chr(13) 
   cSql += "           AND C6_NUM     = SC2.C2_PEDIDO " + chr(13) 
   cSql += "           AND C6_PRODUTO = SC2.C2_PRODUTO" + chr(13) 
   cSql += "           AND C6_ITEM    = SC2.C2_ITEM   " + chr(13) 
   cSql += "           AND D_E_L_E_T_ = '')  AS DTA_ENTREGA," + chr(13) 

   // ##############################
   // Pesquisa a faca do etiqueta ##
   // ##############################
   cSql += "       (SELECT BX_DESC " + chr(13) 
   cSql += "          FROM " + RetSqlName("SBX") + chr(13) 
   cSql += "         WHERE BX_CONJUN = 'FAC'" + chr(13) 
   cSql += "           AND BX_CODOP   = SUBSTRING(SC2.C2_PRODUTO,03,04)" + chr(13) 
   cSql += "           AND D_E_L_E_T_ = '') AS FACA," + chr(13) 

   // ###########################
   // Pesquisa a faca do papel ##
   // ###########################
   cSql += "      (SELECT BX_DESCPR " + chr(13) 
   cSql += "        FROM " + RetSqlName("SBX") + chr(13) 
   cSql += "       WHERE BX_CONJUN = 'PAP'" + chr(13) 
   cSql += "         AND BX_CODOP   = SUBSTRING(SC2.C2_PRODUTO,07,03)" + chr(13) 
   cSql += "         AND D_E_L_E_T_ = '') AS PAPEL," + chr(13) 

   // ####################
   // Pesquisa o tubete ##
   // ####################
   cSql += "      (SELECT BX_DESCPR" + chr(13) 
   cSql += "         FROM " + RetSqlName("SBX") + chr(13) 
   cSql += "        WHERE BX_CONJUN  = 'TUB'" + chr(13) 
   cSql += "          AND BX_CODOP   = SUBSTRING(SC2.C2_PRODUTO,10,01)" + chr(13) 
   cSql += "          AND D_E_L_E_T_ = '') AS TUBETE," + chr(13) 

   // ######################
   // Pesquisa a serrilha ##
   // ######################
   cSql += "      (SELECT BX_DESCPR" + chr(13) 
   cSql += "           FROM " + RetSqlName("SBX") + chr(13) 
   cSql += "          WHERE BX_CONJUN  = 'SER'" + chr(13) 
   cSql += "            AND BX_CODOP   = SUBSTRING(SC2.C2_PRODUTO,11,02)" + chr(13) 
   cSql += "            AND D_E_L_E_T_ = '') AS SERRILHA," + chr(13) 

   // ############################
   // Pesquisa a característica ##
   // ############################
   cSql += "      (SELECT BX_DESCPR" + chr(13) 
   cSql += "         FROM " + RetSqlName("SBX") + chr(13) 
   cSql += "          WHERE BX_CONJUN  = 'CAR'" + chr(13) 
   cSql += "            AND BX_CODOP   = SUBSTRING(SC2.C2_PRODUTO,13,05)" + chr(13) 
   cSql += "            AND D_E_L_E_T_ = '') AS CARACTER," + chr(13) 

   // ######################################
   // Pesquisa o código da transportadora ##
   // ######################################
   cSql += "      (SELECT SC5.C5_TRANSP"                    + chr(13) 
   cSql += "         FROM " + RetSqlName("SC5") + " SC5  "  + chr(13) 
   cSql += "        WHERE SC5.C5_FILIAL  = SC2.C2_FILIAL  " + chr(13) 
   cSql += "          AND SC5.C5_NUM     = SC2.C2_PEDIDO  " + chr(13) 
   cSql += "          AND SC5.D_E_L_E_T_ = '') AS TRANSPO," + chr(13) 

   // ####################################
   // Pesquisa o nome da transportadora ##
   // ####################################
   cSql += "      (SELECT A4_NOME"                                             + chr(13)
   cSql += "         FROM " + RetSqlName("SA4")                                + chr(13)
   cSql += "        WHERE A4_COD = (SELECT SC5.C5_TRANSP"                      + chr(13) 
   cSql += "                          FROM " + RetSqlName("SC5") + " SC5    "  + chr(13) 
   cSql += "                         WHERE SC5.C5_FILIAL  = SC2.C2_FILIAL   "  + chr(13) 
   cSql += "                           AND SC5.C5_NUM     = SC2.C2_PEDIDO   "  + chr(13) 
   cSql += "                           AND SC5.D_E_L_E_T_ = '')) AS NOMEFRE,"  + chr(13) 

   // #####################################################
   // Pesquisa a data de fechamento da Ordem de Produção ##
   // #####################################################
   cSql += "      (SELECT TOP(1) D3_EMISSAO"                                     + chr(13)
   cSql += "         FROM " + RetSqlName("SD3")                                  + chr(13)
   cSql += "        WHERE D3_FILIAL  = SC2.C2_FILIAL"                            + chr(13)
   cSql += "          AND D3_COD     = SC2.C2_PRODUTO"                           + chr(13)
   cSql += "          AND D3_OP      = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN" + chr(13)
   cSql += "          AND D_E_L_E_T_ = ''"                                       + chr(13)
   cSql += "        ORDER BY R_E_C_N_O_ DESC) AS DATA_FIM_OP "                   + chr(13)

   cSql += "      FROM SC2030 SC2, " + chr(13) 
   cSql += "           SB1010 SB1  " + chr(13) 
      
   If Substr(cCOmboBx1,01,01) == "1"
      cSql += "    WHERE SC2.C2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + chr(13) 
      cSql += "      AND SC2.C2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + chr(13) 
   Else
      cSql += "   WHERE (SELECT C6_ENTREG " + chr(13) 
      cSql += "            FROM " + RetSqlName("SC6") + chr(13) 
      cSql += "           WHERE C6_FILIAL  = SC2.C2_FILIAL " + chr(13) 
      cSql += "             AND C6_NUM     = SC2.C2_PEDIDO " + chr(13) 
      cSql += "             AND C6_PRODUTO = SC2.C2_PRODUTO" + chr(13) 
      cSql += "             AND C6_ITEM    = SC2.C2_ITEM   " + chr(13) 
      cSql += "             AND D_E_L_E_T_ = '')  >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + chr(13) 
      cSql += "      AND (SELECT C6_ENTREG " + chr(13) 
      cSql += "            FROM " + RetSqlName("SC6") + chr(13) 
      cSql += "           WHERE C6_FILIAL  = SC2.C2_FILIAL " + chr(13) 
      cSql += "             AND C6_NUM     = SC2.C2_PEDIDO " + chr(13) 
      cSql += "             AND C6_PRODUTO = SC2.C2_PRODUTO" + chr(13) 
      cSql += "             AND C6_ITEM    = SC2.C2_ITEM   " + chr(13) 
      cSql += "             AND D_E_L_E_T_ = '')  <= CONVERT(DATETIME,'" + Dtoc(dFinal) + "', 103)" + chr(13) 
   Endif

   cSql += "      AND SB1.B1_COD      = SC2.C2_PRODUTO" + chr(13) 
   cSql += "      AND SB1.D_E_L_E_T_  = ''" + chr(13) 

   // ################################
   // Filtra pelo cliente informado ##
   // ################################
   If Empty(Alltrim(cCliente))
   Else
      cSql += "   AND (SELECT C5_CLIENTE " + chr(13) 
      cSql += "          FROM " + RetSqlName("SC5") + chr(13) 
      cSql += "         WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
      cSql += "           AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
      cSql += "           AND D_E_L_E_T_ = '') = '" + Alltrim(cCliente) + "'" + chr(13) 
      cSql += "   AND (SELECT C5_LOJACLI " + chr(13) 
      cSql += "          FROM " + RetSqlName("SC5") + chr(13) 
      cSql += "         WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
      cSql += "           AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
      cSql += "           AND D_E_L_E_T_ = '') = '" + Alltrim(cLoja) + "'" + chr(13) 
   Endif   

   // #################################
   // Filtra pelo vendedor informado ##
   // #################################
   If Substr(cComboBx2,01,06) == "000000"
   Else
      cSql += "   AND (SELECT C5_VEND1 " + chr(13) 
      cSql += "          FROM " + RetSqlName("SC5") + chr(13) 
      cSql += "         WHERE C5_FILIAL  = SC2.C2_FILIAL" + chr(13) 
      cSql += "           AND C5_NUM     = SC2.C2_PEDIDO" + chr(13) 
      cSql += "           AND D_E_L_E_T_ = '') = '" + Alltrim(Substr(cComboBx2,01,06)) + "'" + chr(13) 
   Endif

   // ################################
   // Filtra pelo código do produto ##
   // ################################
   If Empty(Alltrim(cProduto))
   Else
      cSql += " AND SC2.C2_PRODUTO = '" + Alltrim(cProduto) + "'" + chr(13) 
   Endif

   // ####################################
   // Filtra pelo nº do pedido de venda ##
   // ####################################
   If Empty(Alltrim(cPedido))
   Else
      cSql += " AND SC2.C2_PEDIDO = '" + Alltrim(cPedido) + "'" + chr(13) 
   Endif

   // ######################################
   // Filtra pelo nº da Ordem de Produção ##
   // ######################################
   If Empty(Alltrim(cProducao))
   Else
      cSql += " AND SC2.C2_NUM LIKE '%" + Alltrim(cProducao) + "%'" + Chr(13)
   Endif

   cSql += " AND SC2.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      // ##########################################
      // Filtra pelo status de OP Aberta/Fechada ##
      // ##########################################
      Do Case 
         Case Substr(cComboBx3,01,01) == "0"
         Case Substr(cComboBx3,01,01) == "1"
              IF Empty(T_CONSULTA->DATA_FIM_OP)
              Else
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif
                 
         Case Substr(cComboBx3,01,01) == "2"
              IF Empty(T_CONSULTA->DATA_FIM_OP)
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif
      EndCase                                      

      // ###############################################################################
      // Prepara a data de Entrega para visualização e cálculo dos status do template ##
      // ###############################################################################
                                                                                        
      If Empty(Alltrim(T_CONSULTA->C2_ZDOE))
         cDataEntrega := T_CONSULTA->DTA_ENTREGA
      Else
         cDataEntrega := T_CONSULTA->C2_ZDOE
      Endif

      cDataEntOP := IIF(Empty(Alltrim(T_CONSULTA->DTA_ENTREGA)), T_CONSULTA->C2_DATPRF, T_CONSULTA->DTA_ENTREGA)

      cDataFimOP := IIF(Empty(Alltrim(T_CONSULTA->DATA_FIM_OP)), "        ", T_CONSULTA->DATA_FIM_OP)

      // #######################
      // Filtra pelo status 2 ##
      // #######################

      // #####################
      // Calcula o Status 2 ##
      // #####################
      If Ctod(Substr(T_CONSULTA->DATA_FIM_OP,07,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,05,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,01,04)) == ;
         Ctod(Substr(cDataentrega,07,02) + "/" + Substr(cDataEntrega,05,02) + "/" + Substr(cDataEntrega,01,04))
//       Ctod(Substr(T_CONSULTA->DTA_ENTREGA,07,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,05,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,01,04))
         xStatus02 := "4"
      Endif
         
      If Ctod(Substr(T_CONSULTA->DATA_FIM_OP,07,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,05,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,01,04)) > ;
         Ctod(Substr(cDataentrega,07,02) + "/" + Substr(cDataEntrega,05,02) + "/" + Substr(cDataEntrega,01,04))
//       Ctod(Substr(T_CONSULTA->DTA_ENTREGA,07,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,05,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,01,04))
         xStatus02 := "8"
      Endif

      If Ctod(Substr(T_CONSULTA->DATA_FIM_OP,07,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,05,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,01,04)) < ;
         Ctod(Substr(cDataentrega,07,02) + "/" + Substr(cDataEntrega,05,02) + "/" + Substr(cDataEntrega,01,04))
//       Ctod(Substr(T_CONSULTA->DTA_ENTREGA,07,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,05,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,01,04))
         xStatus02 := "5"
      Endif

//    If Ctod(Substr(T_CONSULTA->DTA_ENTREGA,07,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,05,02) + "/" + Substr(T_CONSULTA->DTA_ENTREGA,01,04)) <> Ctod("  /  /    ") .And. ;
//       Ctod(Substr(T_CONSULTA->DATA_FIM_OP,07,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,05,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,01,04)) == Ctod("  /  /    ")

      If Ctod(Substr(cDataEntrega,07,02) + "/" + Substr(cDataEntrega,05,02) + "/" + Substr(cDataEntrega,01,04)) <> Ctod("  /  /    ") .And. ;
         Ctod(Substr(T_CONSULTA->DATA_FIM_OP,07,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,05,02) + "/" + Substr(T_CONSULTA->DATA_FIM_OP,01,04)) == Ctod("  /  /    ")
         xStatus02 := "1"
      Endif

      // #####################################################
      // Seleciona registros conforme parâmetros de Status2 ##
      // #####################################################
      Do Case
         Case Substr(cComboBx4,01,01) == "0"

         // ########### 
         // No Prazo ##
         // ###########
         Case Substr(cComboBx4,01,01) == "1"
              If xStatus02 <> "4"
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif
                 
         // ############ 
         // Em Atraso ##
         // ############
         Case Substr(cComboBx4,01,01) == "2"
              If xStatus02 <> "8"
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif
              
         // ############# 
         // Antecipado ##
         // #############
         Case Substr(cComboBx4,01,01) == "3"
              If xStatus02 <> "5"
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif

         // ############## 
         // Em Produção ##
         // ##############
         Case Substr(cComboBx4,01,01) == "4"
              If xStatus02 <> "1"
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif

      EndCase

      // ######################################
      // Filtra por parte do nome do produto ##
      // ######################################
      If Empty(Alltrim(cString))
      Else
         If U_P_OCCURS(T_CONSULTA->NOME_PRO, cString, 1) == 0
            T_CONSULTA->( DbSkip() )
            Loop
         Endif
      Endif

      // ####################################################################
      // Separa dados do código do produtos para pesquisa de matéria-prima ##
      // ####################################################################
      k_Base  :=                Substr(T_CONSULTA->C2_PRODUTO,01,02)
      k_Faca  := '@FAC == "'  + Substr(T_CONSULTA->C2_PRODUTO,03,04) + '"'
      k_Papel := "PAP       " + Substr(T_CONSULTA->C2_PRODUTO,07,03)

//      // #######################################
//      // Pesquisa a matéria-prima da etiqueta ##
//      // #######################################
//      If (Select( "T_MATERIAPRIMA" ) != 0 )
//         T_MATERIAPRIMA->( DbCloseArea() )
//      EndIf
//
//      cSql := ""          
//      cSql := "SELECT SBU.BU_BASE   ,"
//      cSql += "       SBU.BU_IDC2   ,"
// 	  cSql += "       SBU.BU_CONDICA," 
// 	  cSql += "       SBU.BU_COMP   ,"
//  	  cSql += "       SBU.BU_QUANT  ,"
//  	  cSql += "       SB1.B1_DESC    "
//      cSql += "  FROM " + RetSqlName("SBU") + " SBU, "
//      cSql += "       " + RetSqlName("SB1") + " SB1  "
//      cSql += " WHERE SBU.BU_BASE    = '" + Alltrim(k_Base)  + "'"
//      cSql += "   AND SBU.BU_IDC2    = '" + Alltrim(k_Papel) + "'"
//      cSql += "   AND SBU.BU_CONDICA = '" + Alltrim(k_Faca)  + "'"
//      cSql += "   AND SBU.D_E_L_E_T_ = ''
//      cSql += "   AND SB1.B1_COD     = SBU.BU_COMP"
//      cSql += "   AND SB1.D_E_L_E_T_ = ''"
//      
//      cSql := ChangeQuery( cSql )
//      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MATERIAPRIMA",.T.,.T.)
//
//      k_Materia := IIF(T_MATERIAPRIMA->( EOF() ), "",  T_MATERIAPRIMA->BU_COMP)
//      k_DescMat := IIF(T_MATERIAPRIMA->( EOF() ), "",  T_MATERIAPRIMA->B1_DESC)


      // #######################################
      // Pesquisa a matéria-prima da etiqueta ##
      // #######################################
      If (Select( "T_MATERIAPRIMA" ) != 0 )
         T_MATERIAPRIMA->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SD4.D4_FILIAL,"
      cSql += "       SD4.D4_COD   ,"
      cSql += "      (SB1.B1_DESC + SB1.B1_DAUX) AS DESCRICAO,"
      cSql += "	      SD4.D4_QTDEORI"
      cSql += " FROM " + RetSqlName("SD4") + " SD4 (NOLOCK), "
      cSql += "      " + RetSqlName("SB1") + " SB1 (NOLOCK)  "
      cSql += " WHERE SD4.D4_FILIAL  = '"  + Alltrim(cFilAnt)            + "'"
      cSql += "   AND SD4.D4_OP      = '"  + Alltrim(T_CONSULTA->C2_NUM) + Alltrim(T_CONSULTA->C2_ITEM) + Alltrim(T_CONSULTA->C2_SEQUEN) + "'" 
      cSql += "   AND SD4.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SD4.D4_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MATERIAPRIMA",.T.,.T.)

      k_Materia  := IIF(T_MATERIAPRIMA->( EOF() ), "",  T_MATERIAPRIMA->D4_COD)
      k_DescMat  := IIF(T_MATERIAPRIMA->( EOF() ), "",  T_MATERIAPRIMA->DESCRICAO)
      k_QEmpenho := IIF(T_MATERIAPRIMA->( EOF() ), 0 ,  T_MATERIAPRIMA->D4_QTDEORI)

      // ############################################
      // Pesquisa a quantidade de fechamento da OS ##
      // ############################################
      If (Select( "T_FECHAMENTO" ) != 0 )
         T_FECHAMENTO->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT D3_FILIAL,"
      cSql += "       D3_COD   ,"
	  cSql += "       D3_TM    ,"
	  cSql += "       SUM(D3_QUANT) AS QUANTIDADE"
      cSql += "  FROM " + RetSqlName("SD3")
      cSql += " WHERE D3_FILIAL  = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND D3_OP      = '"  + Alltrim(T_CONSULTA->C2_NUM) + Alltrim(T_CONSULTA->C2_ITEM) + Alltrim(T_CONSULTA->C2_SEQUEN) + "'" 
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += "   AND D3_TM      = '101'"
      cSql += " GROUP BY D3_FILIAL, D3_COD, D3_TM"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FECHAMENTO",.T.,.T.)

      k_Fechamento  := IIF(T_FECHAMENTO->( EOF() ), 0,  T_FECHAMENTO->QUANTIDADE)

      // ################################################################
      // Envia para a função que calcula a metragem linear da etiqueta ##
      // ################################################################
      DadosMetragem(T_CONSULTA->C2_PRODUTO)

      // ###########################
      // Calcula Metros Quadrados ##
      // ###########################
      DbSelectArea("SC2")
      DBSEEK(xFilial("SC2") + T_CONSULTA->C2_NUM + T_CONSULTA->C2_ITEM + T_CONSULTA->C2_SEQUEN)

      aComp     := {}
      aComp     := U_BuscaComp()		
      __nQtdLin := U_CalcPerda("OP", T_CONSULTA->C2_NUM + T_CONSULTA->C2_ITEM + T_CONSULTA->C2_SEQUEN,k_materia,.F.)
      __nQtdM2  := IIF(Len(aComp) > 0, __nQtdLin * aComp[1][8],0)

      // ##########################
      // Carrega o array aBrowse ##
      // ##########################
      aAdd( aBrowse, { IIF(EMPTY(ALLTRIM(T_CONSULTA->OBSERVACAO)), "1", "8")  ,; // 01
                       T_CONSULTA->C2_PEDIDO             ,;                      // 02
                       Alltrim(T_CONSULTA->CLIENTE)      ,;                      // 03
                       Alltrim(T_CONSULTA->LOJA)         ,;                      // 04
                       Alltrim(T_CONSULTA->NOMECLI)      ,;                      // 05
                       Alltrim(T_CONSULTA->VENDEDOR)     ,;                      // 06
                       Alltrim(T_CONSULTA->NOMEVEN)      ,;                      // 07
                       Substr(T_CONSULTA->C2_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->C2_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->C2_EMISSAO,01,04) ,; // 08
                       T_CONSULTA->PRODUCAO              ,;                      // 09
                       IIF(Empty(T_CONSULTA->DATA_FIM_OP), "2", "7") ,;          // 10
                       Substr(cDataEntrega,07,02) + "/" + Substr(cDataEntrega,05,02) + "/" + Substr(cDataEntrega,01,04)                                  ,; // 11
                       Substr(cDataEntOP,07,02) + "/" + Substr(cDataEntOP,05,02) + "/" + Substr(cDataEntOP,01,04) ,; // 12
                       Substr(cDataFimOP_OP,07,02) + "/" + Substr(cDataFimOP_OP,05,02) + "/" + Substr(cDataFimOP_OP,01,04) ,; // 13
                       xStatus02                ,;         && 'Sts Fin.'                      ,; // 14
                       T_CONSULTA->C2_PRODUTO   ,;         && 'Cod.Produto'                   ,; // 15
                       T_CONSULTA->C2_ITEM      ,;         && 'Item da Op'                    ,; // 16
                       T_CONSULTA->FACA         ,;         && 'Medida Faca'                   ,; // 17
                       T_CONSULTA->PAPEL        ,;         && 'Papel'                         ,; // 18
                       T_CONSULTA->TUBETE       ,;         && 'Tubete'                        ,; // 19
                       T_CONSULTA->SERRILHA     ,;         && 'Serrilha'                      ,; // 20
                       T_CONSULTA->CARACTER     ,;         && 'Característica'                ,; // 21
                       str(T_CONSULTA->C2_QUANT,10,02),;   && 'Quantdiade'                    ,; // 22
                       T_CONSULTA->C2_UM        ,;         && 'Und'                           ,; // 23
                       Str(Round(__nQtdLin,2),10,02) ,;    && 'Metros Lineares'               ,; // 24
                       Str(Round(__nQtdM2,2),10,02)  ,;    && 'M2'                            ,; // 25
                       str(k_QEmpenho,10,02)    ,;         && 'Quantidade Empenho'            ,; // 26
                       str(k_Fechamento,10,02)  ,;         && 'Quantidade Fechamento'         ,; // 27
                       k_Materia                ,;         && 'Cod.Componente'                ,; // 28
                       k_DescMat                ,;         && 'Descrição dos Componentes'     ,; // 29
                       T_CONSULTA->TRANSPO      ,;         && 'Cód.Transp.'                   ,; // 30
                       T_CONSULTA->NOMEFRE      ,;         && 'Descrição das Transportadoras' ,; // 31
                       T_CONSULTA->C2_MAQU      ,;         && 'Máquina 1'                     ,; // 32
                       T_CONSULTA->C2_OPER      ,;         && 'Operador 1'                    ,; // 33 
                       T_CONSULTA->C2_TPRO      ,;         && 'Tempo Total de Produção 1'     ,; // 34
                       T_CONSULTA->C2_MAQ2      ,;         && 'Máquina 1'                     ,; // 35
                       T_CONSULTA->C2_OPE2      ,;         && 'Operador 1'                    ,; // 36 
                       T_CONSULTA->C2_TPR2      ,;         && 'Tempo Total de Produção 2'     ,; // 37
                       T_CONSULTA->C2_MAQ3      ,;         && 'Máquina 3'                     ,; // 38
                       T_CONSULTA->C2_OPE3      ,;         && 'Operador 3'                    ,; // 39 
                       T_CONSULTA->C2_TPR3      })         && 'Tempo de Produção 3'           ,; // 40

      T_CONSULTA->( DbSkip() )
      
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "1", "", "", "", "", "", "", "", "", "8", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif  
   
   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,15],;
                         aBrowse[oBrowse:nAt,16],;
                         aBrowse[oBrowse:nAt,17],;
                         aBrowse[oBrowse:nAt,18],;
                         aBrowse[oBrowse:nAt,19],;
                         aBrowse[oBrowse:nAt,20],;
                         aBrowse[oBrowse:nAt,21],;
                         aBrowse[oBrowse:nAt,22],;
                         aBrowse[oBrowse:nAt,23],;
                         aBrowse[oBrowse:nAt,24],;
                         aBrowse[oBrowse:nAt,25],;
                         aBrowse[oBrowse:nAt,26],;
                         aBrowse[oBrowse:nAt,27],;
                         aBrowse[oBrowse:nAt,28],;
                         aBrowse[oBrowse:nAt,29],;
                         aBrowse[oBrowse:nAt,30],;
                         aBrowse[oBrowse:nAt,31],;
                         aBrowse[oBrowse:nAt,32],;
                         aBrowse[oBrowse:nAt,33],;
                         aBrowse[oBrowse:nAt,34],;
                         aBrowse[oBrowse:nAt,35],;
                         aBrowse[oBrowse:nAt,36],;                                                                           
                         aBrowse[oBrowse:nAt,37],;
                         aBrowse[oBrowse:nAt,38],;
                         aBrowse[oBrowse:nAt,39],;
                         aBrowse[oBrowse:nAt,40]}}

Return(.T.)

// ###################################################
// Função que calcula a metragem linear da etiqueta ##
// ###################################################
Static Function DadosMetragem(kProduto)

   DbSelectArea('SB1')
   DbSetOrder(1)
   
   DbGoTop()
   
   If DbSeek(xFilial('SB1') + kProduto, .F.)

	  _aRet1 := U_CALCMETR(kProduto)

	  // ###############################
	  // 1 = Metragem Linear por rolo ##
	  // 2 = Qtd Etoquetas por rolo   ##
	  // 3= Tubete                    ##
	  // ###############################
      cGramat :=	TABELA("ZP",SB1->B1_MPCLAS,.f.)
 	  nMetr	  :=	_aRet1[1]
 	  nEtqRol :=	_aRet1[2]
	 
	  IF SB1->B1_UM == "MI"
	     nRolos	:= (SC2->C2_QUANT * 1000) / nEtqRol
	  ELSE
	     nRolos	:=	SC2->C2_QUANT
	  ENDIF
  
   EndIf
  
Return(.T.)

// ######################################################
// Função que abre as observações da Ordem de Produção ##
// ######################################################
Static Function xxObserva(kProducao, kProduto, kItem)

   Local lChumba   := .F.
   Local cMemo1    := ""
   Local oMemo1
   Local xProducao := Substr(kProducao,01,06)
   Local xItem     := Substr(kProducao,08,02)
   Local xSequen   := Substr(kProducao,11,03)
   
   Private cProducao := kProducao
   Private oGet1
   
   Private cObserva  := ""
   Private oMemo2

   Private oDlgObs

   If Empty(Alltrim(kProducao))
      MsgAlert("Nenhum registro selecionado para visualização.")
      Return(.T.)
   Endif

   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql += "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C2_OBSI)) AS OBSERVACAO"
   cSql += "  FROM " + RetSqlName("SC2")
   cSql += " WHERE C2_FILIAL  = '" + Alltrim(cFilAnt)   + "'"
   cSql += "   AND C2_NUM     = '" + Alltrim(xProducao) + "'"
   cSql += "   AND C2_ITEM    = '" + Alltrim(xItem)     + "'"
   cSql += "   AND C2_SEQUEN  = '" + Alltrim(xSequen)   + "'"
   cSql += "   AND C2_PRODUTO = '" + Alltrim(kProduto)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"                                                             

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   cObserva := IIF(T_PRODUCAO->( EOF() ), "", T_PRODUCAO->OBSERVACAO)

   DEFINE MSDIALOG oDlgObs TITLE "Observações Ordem de Produção" FROM C(178),C(181) TO C(491),C(542) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgObs

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(173),C(001) PIXEL OF oDlgObs

   @ C(037),C(005) Say "Observações Ref. Ordem de Produção" Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlgObs

   @ C(046),C(005) MsGet oGet1  Var cProducao     Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgObs When lChumba
   @ C(060),C(005) GET   oMemo2 Var cObserva MEMO Size C(171),C(076)                              PIXEL OF oDlgObs

   @ C(140),C(100) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgObs ACTION( GrvObsInt(xProducao, xItem, xSequen, kItem, kProduto, cObserva) )
   @ C(140),C(139) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgObs ACTION( oDlgObs:End() )

   ACTIVATE MSDIALOG oDlgObs CENTERED 

Return(.T.)

// #####################################################
// Função que grava a observação da Ordem de Produção ##
// #####################################################
Static Function GrvObsInt(xProducao, xItem, xSequen, kItem, kProduto, kObservacao)

   Local cSql := ""

   cSql := ""
   cSql := "UPDATE " + RetSqlName("SC2")
   cSql += "   SET "
   cSql += "   C2_OBSI = '" + Alltrim(kObservacao)      + "'"
   cSql += " WHERE C2_FILIAL  = '" + Alltrim(cFilAnt)   + "'"
   cSql += "   AND C2_NUM     = '" + Alltrim(xProducao) + "'"
   cSql += "   AND C2_ITEM    = '" + Alltrim(xItem)     + "'"
   cSql += "   AND C2_SEQUEN  = '" + Alltrim(xSequen)   + "'"
   cSql += "   AND C2_PRODUTO = '" + Alltrim(kProduto)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      MsgAlert(TCSQLERROR())
      oDlgObs:End()
      Return(.T.)
   Endif

   oDlgObs:End()
   
   If Empty(Alltrim(kObservacao))
      aBrowse[oBrowse:nAt,01] := "1"
   Else
      aBrowse[oBrowse:nAt,01] := "8"       
   Endif
          
   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,15],;
                         aBrowse[oBrowse:nAt,16],;
                         aBrowse[oBrowse:nAt,17],;
                         aBrowse[oBrowse:nAt,18],;
                         aBrowse[oBrowse:nAt,19],;
                         aBrowse[oBrowse:nAt,20],;
                         aBrowse[oBrowse:nAt,21],;
                         aBrowse[oBrowse:nAt,22],;
                         aBrowse[oBrowse:nAt,23],;
                         aBrowse[oBrowse:nAt,24],;
                         aBrowse[oBrowse:nAt,25],;
                         aBrowse[oBrowse:nAt,26],;
                         aBrowse[oBrowse:nAt,27],;
                         aBrowse[oBrowse:nAt,28],;
                         aBrowse[oBrowse:nAt,29],;
                         aBrowse[oBrowse:nAt,30],;
                         aBrowse[oBrowse:nAt,31],;
                         aBrowse[oBrowse:nAt,32],;
                         aBrowse[oBrowse:nAt,33],;
                         aBrowse[oBrowse:nAt,34],;
                         aBrowse[oBrowse:nAt,35],;
                         aBrowse[oBrowse:nAt,36],;
                         aBrowse[oBrowse:nAt,37],;
                         aBrowse[oBrowse:nAt,38],;
                         aBrowse[oBrowse:nAt,39],;
                         aBrowse[oBrowse:nAt,40]}}

Return(.T.)

// #########################################################################
// Função que abre tela de seleção do tipo de apontamento a ser realizado ##
// #########################################################################
Static Function MaqTempo(kProducao, kProduto, kItem, kMaqu01, kOpera01, kTempo01, kMaqui02, kOpera02, kTempo02, kMaqui03, kOpera03, kTempo03)

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgMMM

   DEFINE MSDIALOG oDlgMMM TITLE "Apontamento Template de Produção" FROM C(178),C(181) TO C(467),C(475) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlgMMM

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(141),C(001) PIXEL OF oDlgMMM

   @ C(040),C(005) Button "APONTAMENTO MÁQUINA 01" Size C(138),C(024) PIXEL OF oDlgMMM ACTION( xMaqTempo(1, kProducao, kProduto, kItem, kMaqu01, kOpera01, kTempo01, kMaqui02, kOpera02, kTempo02, kMaqui03, kOpera03, kTempo03) )
   @ C(065),C(005) Button "APONTAMENTO MÁQUINA 02" Size C(138),C(024) PIXEL OF oDlgMMM ACTION( xMaqTempo(2, kProducao, kProduto, kItem, kMaqu01, kOpera01, kTempo01, kMaqui02, kOpera02, kTempo02, kMaqui03, kOpera03, kTempo03) )
   @ C(091),C(005) Button "APONTAMENTO MÁQUINA 03" Size C(138),C(024) PIXEL OF oDlgMMM ACTION( xMaqTempo(3, kProducao, kProduto, kItem, kMaqu01, kOpera01, kTempo01, kMaqui02, kOpera02, kTempo02, kMaqui03, kOpera03, kTempo03) )
   @ C(116),C(005) Button "VOLTAR"                 Size C(138),C(024) PIXEL OF oDlgMMM ACTION( oDlgMMM:End() )

   ACTIVATE MSDIALOG oDlgMMM CENTERED 

Return(.T.)

// ########################################
// Função que abre tela de maquina/tempo ##
// ########################################
Static Function xMaqTempo(kAponta, kProducao, kProduto, kItem, kMaqui01, kOpera01, kTempo01, kMaqui02, kOpera02, kTempo02, kMaqui03, kOpera03, kTempo03)

   Local lChumba := .F.
   Local lEdita1 := .F.
   Local lEdita2 := .F.   
   Local lEdita3 := .F.   

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local mProducao := kProducao
   Local mMaqui01  := IIF(Empty(Alltrim(kMaqui01)), Space(20), kMaqui01)
   Local mOpera01  := IIF(Empty(Alltrim(kOpera01)), Space(20), kOpera01)
   Local mTempo01  := IIF(Empty(Alltrim(kTempo01)), Space(08), kTempo01)
   Local mMaqui02  := IIF(Empty(Alltrim(kMaqui02)), Space(20), kMaqui02)
   Local mOpera02  := IIF(Empty(Alltrim(kOpera02)), Space(20), kOpera02)
   Local mTempo02  := IIF(Empty(Alltrim(kTempo02)), Space(08), kTempo02)
   Local mMaqui03  := IIF(Empty(Alltrim(kMaqui03)), Space(20), kMaqui03)
   Local mOpera03  := IIF(Empty(Alltrim(kOpera03)), Space(20), kOpera03)
   Local mTempo03  := IIF(Empty(Alltrim(kTempo03)), Space(08), kTempo03)

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7         
   Local oGet8         
   Local oGet9         
   Local oGet10            

   Local xProducao := Substr(kProducao,01,06)
   Local xItem     := Substr(kProducao,08,02)
   Local xSequen   := Substr(kProducao,11,03)

   If kAponta == 1
      lEdita1 := .T.
      lEdita2 := .F.
      lEdita3 := .F.
   Endif   

   If kAponta == 2
      lEdita1 := .F.
      lEdita2 := .T.
      lEdita3 := .F.
   Endif   

   If kAponta == 3
      lEdita1 := .F.
      lEdita2 := .F.
      lEdita3 := .T.
   Endif   

   Private oDlgMAQ

   If Empty(Alltrim(kProducao))
      MsgAlert("Nenhum registro selecionado para visualização.")
      Return(.T.)
   Endif

   // ###################################
   // Pesquisa dados para visualização ##
   // ###################################
   If Select("T_MAQUINAS") > 0
      T_MAQUINAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C2_FILIAL,"
   cSql += "       C2_NUM   ,"
   cSql	+= "       C2_ITEM  ,"
   cSql	+= "       C2_SEQUEN,"
   cSql += "       C2_DINC  ,"
   cSql += "       C2_MAQU  ,"
   cSql	+= "       C2_TPRO  ,"
   cSql	+= "       C2_OPER  ,"
   cSql	+= "       C2_MAQ2  ,"
   cSql	+= "       C2_OPE2  ,"
   cSql	+= "       C2_TPR2  ,"
   cSql	+= "       C2_MAQ3  ,"
   cSql	+= "       C2_OPE3  ,"
   cSql	+= "       C2_TPR3   "
   cSql += "   FROM " + RetSqlName("SC2")
   cSql += "  WHERE C2_FILIAL  = '" + Alltrim(cFilAnt)   + "'"
   cSql += "    AND C2_NUM     = '" + Alltrim(Substr(kProducao,01,06)) + "'"
   cSql += "    AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MAQUINAS", .T., .T. )

   If T_MAQUINAS->( EOF() )
   Else
      mMaqui01 := T_MAQUINAS->C2_MAQU
      mOpera01 := T_MAQUINAS->C2_OPER
      mTempo01 := T_MAQUINAS->C2_TPRO
      mMaqui02 := T_MAQUINAS->C2_MAQ2
      mOpera02 := T_MAQUINAS->C2_OPE2
      mTempo02 := T_MAQUINAS->C2_TPR2
      mMaqui03 := T_MAQUINAS->C2_MAQ3
      mOpera03 := T_MAQUINAS->C2_OPE3
      mTempo03 := T_MAQUINAS->C2_TPR3
   Endif    

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlgMAQ TITLE "Apontamento Template de Produção" FROM C(178),C(181) TO C(559),C(625) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlgMAQ

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(215),C(001) PIXEL OF oDlgMAQ
   @ C(167),C(002) GET oMemo2 Var cMemo2 MEMO Size C(215),C(001) PIXEL OF oDlgMAQ
   
   @ C(039),C(005) Say "Ordem de Produção" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ

   @ C(063),C(005) Say "APONTAMENTO 1" Size C(049),C(008) COLOR CLR_RED   PIXEL OF oDlgMAQ
   @ C(074),C(005) Say "Máquina"       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(074),C(095) Say "Operador"      Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(074),C(185) Say "Tempo Total"   Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(099),C(005) Say "APONTAMENTO 2" Size C(049),C(008) COLOR CLR_RED   PIXEL OF oDlgMAQ
   @ C(109),C(005) Say "Máquina"       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(109),C(095) Say "Operador"      Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(109),C(185) Say "Tempo Total"   Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(134),C(005) Say "APONTAMENTO 3" Size C(049),C(008) COLOR CLR_RED   PIXEL OF oDlgMAQ
   @ C(143),C(005) Say "Máquina"       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(143),C(095) Say "Operador"      Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ
   @ C(143),C(185) Say "Tempo Total"   Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgMAQ

   @ C(049),C(005) MsGet oGet1  Var mProducao Size C(056),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgMAQ When lChumba
   @ C(083),C(005) MsGet oGet2  Var mMaqui01  Size C(084),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgMAQ When lEdita1
   @ C(083),C(095) MsGet oGet3  Var mOpera01  Size C(084),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgMAQ When lEdita1
   @ C(083),C(185) MsGet oGet4  Var mTempo01  Size C(031),C(009) COLOR CLR_BLACK Picture "XX:XX:XX" PIXEL OF oDlgMAQ When lEdita1
   @ C(118),C(005) MsGet oGet5  Var mMaqui02  Size C(084),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgMAQ When lEdita2
   @ C(118),C(095) MsGet oGet6  Var mOpera02  Size C(084),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgMAQ When lEdita2
   @ C(118),C(185) MsGet oGet7  Var mTempo02  Size C(031),C(009) COLOR CLR_BLACK Picture "XX:XX:XX" PIXEL OF oDlgMAQ When lEdita2
   @ C(152),C(005) MsGet oGet8  Var mMaqui03  Size C(084),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgMAQ When lEdita3
   @ C(152),C(095) MsGet oGet9  Var mOpera03  Size C(084),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgMAQ When lEdita3
   @ C(152),C(185) MsGet oGet10 Var mTempo03  Size C(031),C(009) COLOR CLR_BLACK Picture "XX:XX:XX" PIXEL OF oDlgMAQ When lEdita3

   @ C(174),C(072) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgMAQ ACTION( GrvMaqTempo(xProducao, xItem, xSequen, kItem, kProduto, mMaqui01, mOpera01, mTempo01, mMaqui02, mOpera02, mTempo02, mMaqui03, mOpera03, mTempo03) )
   @ C(174),C(111) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgMAQ ACTION( oDlgMAQ:End() )

   ACTIVATE MSDIALOG oDlgMAQ CENTERED 

Return(.T.)

// ###############################################
// Função que grava máquina e tempo de produção ##
// ###############################################
Static Function GrvMaqTempo(xProducao, xItem, xSequen, kItem, kProduto, kMaqui01, kOpera01, kTempo01, kMaqui02, kOpera02, kTempo02, kMaqui03, kOpera03, kTempo03)

   Local cSql := ""

   cSql := ""
   cSql := "UPDATE " + RetSqlName("SC2")
   cSql += "   SET "
   cSql += "   C2_MAQU = '" + Alltrim(kMaqui01)         + "',"
   cSql += "   C2_OPER = '" + Alltrim(kOpera01)         + "',"
   cSql += "   C2_TPRO = '" + Alltrim(kTempo01)         + "',"
   cSql += "   C2_MAQ2 = '" + Alltrim(kMaqui02)         + "',"
   cSql += "   C2_OPE2 = '" + Alltrim(kOpera02)         + "',"
   cSql += "   C2_TPR2 = '" + Alltrim(kTempo02)         + "',"
   cSql += "   C2_MAQ3 = '" + Alltrim(kMaqui03)         + "',"
   cSql += "   C2_OPE3 = '" + Alltrim(kOpera03)         + "',"
   cSql += "   C2_TPR3 = '" + Alltrim(kTempo03)         + "' "
   cSql += " WHERE C2_FILIAL  = '" + Alltrim(cFilAnt)   + "'"
   cSql += "   AND C2_NUM     = '" + Alltrim(xProducao) + "'"
   cSql += "   AND C2_ITEM    = '" + Alltrim(xItem)     + "'"
   cSql += "   AND C2_SEQUEN  = '" + Alltrim(xSequen)   + "'"
   cSql += "   AND C2_PRODUTO = '" + Alltrim(kProduto)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      MsgAlert(TCSQLERROR())
      oDlgObs:End()
      Return(.T.)
   Endif

   oDlgMAQ:End()

   aBrowse[oBrowse:nAt,32] := IIF(Empty(Alltrim(kMaqui01)), "", kMaqui01)
   aBrowse[oBrowse:nAt,33] := IIF(Empty(Alltrim(kOpera01)), "", kOpera01)
   aBrowse[oBrowse:nAt,34] := IIF(Empty(Alltrim(kTempo01)), "", kTempo01)   
   aBrowse[oBrowse:nAt,35] := IIF(Empty(Alltrim(kMaqui02)), "", kMaqui02)
   aBrowse[oBrowse:nAt,36] := IIF(Empty(Alltrim(kOpera02)), "", kOpera02)
   aBrowse[oBrowse:nAt,37] := IIF(Empty(Alltrim(kTempo02)), "", kTempo02)   
   aBrowse[oBrowse:nAt,38] := IIF(Empty(Alltrim(kMaqui03)), "", kMaqui03)
   aBrowse[oBrowse:nAt,39] := IIF(Empty(Alltrim(kOpera03)), "", kOpera03)
   aBrowse[oBrowse:nAt,40] := IIF(Empty(Alltrim(kTempo03)), "", kTempo03)   

   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,10]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,14]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,15],;
                         aBrowse[oBrowse:nAt,16],;
                         aBrowse[oBrowse:nAt,17],;
                         aBrowse[oBrowse:nAt,18],;
                         aBrowse[oBrowse:nAt,19],;
                         aBrowse[oBrowse:nAt,20],;
                         aBrowse[oBrowse:nAt,21],;
                         aBrowse[oBrowse:nAt,22],;
                         aBrowse[oBrowse:nAt,23],;
                         aBrowse[oBrowse:nAt,24],;
                         aBrowse[oBrowse:nAt,25],;
                         aBrowse[oBrowse:nAt,26],;
                         aBrowse[oBrowse:nAt,27],;
                         aBrowse[oBrowse:nAt,28],;
                         aBrowse[oBrowse:nAt,29],;
                         aBrowse[oBrowse:nAt,30],;
                         aBrowse[oBrowse:nAt,31],;
                         aBrowse[oBrowse:nAt,32],;                                                  
                         aBrowse[oBrowse:nAt,33],;
                         aBrowse[oBrowse:nAt,34],;                                                  
                         aBrowse[oBrowse:nAt,35],;                                                  
                         aBrowse[oBrowse:nAt,36],;
                         aBrowse[oBrowse:nAt,37],;                                                  
                         aBrowse[oBrowse:nAt,38],;                                                  
                         aBrowse[oBrowse:nAt,39],;                                                  
                         aBrowse[oBrowse:nAt,40]}}

Return(.T.)

// ######################################
// Função que abre janela das legendas ##
// ######################################
Static Function MostraLegenda()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

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

   Private oDlgCOR

   DEFINE MSDIALOG oDlgCOR TITLE "Legendas" FROM C(178),C(181) TO C(512),C(431) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgCOR

   @ C(050),C(016) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgCOR
   @ C(063),C(016) Jpeg FILE "br_preto.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgCOR
   @ C(092),C(016) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgCOR
   @ C(105),C(016) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlgCOR
   @ C(118),C(016) Jpeg FILE "br_azul.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlgCOR
   @ C(131),C(016) Jpeg FILE "br_branco.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlgCOR

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(119),C(001) PIXEL OF oDlgCOR
   @ C(147),C(005) GET oMemo2 Var cMemo2 MEMO Size C(115),C(001) PIXEL OF oDlgCOR
   
   @ C(039),C(005) Say "Legenda Status 1"               Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   @ C(051),C(030) Say "Ordens de Produção Abertas"     Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   @ C(065),C(030) Say "Ordens de produção Finalizadas" Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   @ C(080),C(005) Say "Legenda Status 2"               Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   @ C(093),C(030) Say "No Prazo"                       Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   @ C(106),C(030) Say "Em Atraso"                      Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   @ C(119),C(030) Say "Antecipado"                     Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   @ C(132),C(030) Say "Em Produção"                    Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlgCOR
   
   @ C(151),C(044) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCOR ACTION( oDlgCor:End() )

   ACTIVATE MSDIALOG oDlgCOR CENTERED 

Return(.T.)

// #########################################
// Função que gera a saída em Arquivo TXT ##
// #########################################
Static Function GeraArquivo(kProducao)

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local cString   := ""
   Local nContar   := ""
   Local lPrimeiro := .T.
   Local lVolta    := .T.
   Local oMemo1

   Private cOriCaminho  := Space(250) 
   Private lSeparador   := .F.
   Private aTipoArquivo	:= {"00 - SELECIONE O TIPO DE ARQUIVO", "01 - TXT TABULADO", "02 - TXT SEM TABULAÇÃO", "03 - TXT COM SEPARADOR", "04 - CSV SEM TABULAÇÂO", "05 - CSV COM SEPARADOR" }
   Private cComboBx1
   Private cGeraTXT     := Space(250)
   Private cSeparador   := Space(001)
   Private lFiltrosPar  := .T.
   Private lCabecalho   := .T.
   Private oCheckBox1
   Private oCheckBox2
   Private oGet1
   Private oGet2

   Private oDlgTXT

   If Empty(Alltrim(kProducao))
      MsgAlert("Nenhum registro selecionado para visualização.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgTXT TITLE "Gerar Resultado em Arquivo" FROM C(178),C(181) TO C(388),C(792) PIXEL

   @ C(005),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgTXT

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(297),C(001) PIXEL OF oDlgTXT

   @ C(036),C(005) Say "Tipo de Arquivo a ser gerado"          Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT
   @ C(036),C(141) Say "Separdor"                              Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT
   @ C(062),C(005) Say "Caminho onde arquivo deverá ser salvo" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT

   @ C(046),C(005) ComboBox cComboBx1  Items aTipoArquivo Size C(131),C(010)                              PIXEL OF oDlgTXT ON CHANGE AbreSeparador()
   @ C(046),C(141) MsGet    oGet2      Var   cSeparador   Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTXT When lSeparador
// @ C(054),C(172) CheckBox oCheckBox2 Var   lFiltrosPar  Prompt "Gerar arquivo com parâmertos de filtro" Size C(102),C(008) PIXEL OF oDlgTXT
   @ C(054),C(172) CheckBox oCheckBox1 Var   lCabecalho   Prompt "Gerar arquivo com cabeçalho dos campos" Size C(111),C(008) PIXEL OF oDlgTXT
   @ C(072),C(005) MsGet    oGet1      Var   cGeraTXT     Size C(278),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTXT When lChumba
   @ C(072),C(287) Button "..."                           Size C(012),C(009)                              PIXEL OF oDlgTXT ACTION( CaminhoTXT())

   @ C(088),C(113) Button "Gerar"  Size C(037),C(012) PIXEL OF oDlgTXT ACTION( xGeraTXT() )
   @ C(088),C(151) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgTXT ACTION( oDlgTXT:End() )

   ACTIVATE MSDIALOG oDlgTXT CENTERED 

Return(.T.)

// #######################################################
// Função que abre ou fecha o campo Separador de campos ##
// #######################################################
Static Function AbreSeparador()

   Do Case
      Case Substr(cComboBx1,01,02) == "00"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "01"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "02"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "03"
           cSeparador := Space(001)
           lSeparador := .T.
      Case Substr(cComboBx1,01,02) == "04"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "05"                        
           cSeparador := ";"
           lSeparador := .T.
   EndCase

   oGet2:Refresh()

   If Empty(Alltrim(cOriCaminho))
   Else

      cGeraTXT := Space(250)

      Do Case
         // 01 - TABULADO
         Case Substr(cComboBx1,01,02) == "01"
              cGeraTXT := Alltrim(cOriCaminho) + "Template_Producao.TXT"

         // 02 - TXT SEM TABULAÇÃO
         Case Substr(cComboBx1,01,02) == "02"
              cGeraTXT := Alltrim(cOriCaminho) + "Template_Producao.TXT"

         // 03 - TXT COM SEPARADOR
         Case Substr(cComboBx1,01,02) == "03"
              cGeraTXT := Alltrim(cOriCaminho) + "Template_Producao.TXT"

         // 04 - CSV SEM TABULAÇÂO
         Case Substr(cComboBx1,01,02) == "04"
              cGeraTXT := Alltrim(cOriCaminho) + "Template_Producao.CSV"
        
         // 05 - CSV COM SEPARADOR
         Case Substr(cComboBx1,01,02) == "05"
              cGeraTXT := Alltrim(cOriCaminho) + "Template_Producao.CSV"

      EndCase

      oGet1:Refresh()
      
   Endif   

Return(.T.)   

// #########################################
// Função que gera a saída em Arquivo TXT ##
// #########################################
Static Function xGeraTXT()

   If Substr(cComboBx1,01,02) == "00"
      MsgStop("Tipo de arquivo a ser gerado não selecionado.")
      Return(.T.)
   Endif

   Do Case
      Case Substr(cComboBx1,01,02) == "03"
           If Empty(Alltrim(cSeparador))
              MsgStop("Separador de campos para o tipo de arquivo selecionado não informado.")
              Return(.T.)
           Endif
      Case Substr(cComboBx1,01,02) == "05"
           If Empty(Alltrim(cSeparador))
              MsgStop("Separador de campos para o tipo de arquivo selecionado não informado.")
              Return(.T.)
           Endif
   EndCase

   If Empty(Alltrim(cGeraTXT))
      MsgStop("Caminho e Nome do arquivo a ser salvo não informado.")
      Return(.T.)
   Endif

   If File(Alltrim(cGeraTXT))
      If (MsgYesNo("Arquivo já existe na pasta infromada. Deseja sobrescrever o arquivo?","Atenção!"))
      Else
         Return(.T.)
      Endif
   Endif      
                                                                              
   // Envia para a função que gera o arquivo conforme parâmetros informados
   MsgRun("Aguarde! Preparando inclusão de consulta ...", "Manutenção de Consulta",{|| yGeraTXT() })

Return(.T.)

// #########################################
// Função que gera a saída em Arquivo TXT ##
// #########################################
Static Function yGeraTXT()

   Local cString   := ""
   Local nContar   := ""
   Local lPrimeiro := .T.

   Do Case
      // ################
      // 01 - TABULADO ##
      // ################
      Case Substr(cComboBx1,01,02) == "01"
           kSeparador := " "

      // #########################
      // 02 - TXT SEM TABULAÇÃO ##
      // #########################
      Case Substr(cComboBx1,01,02) == "02"
           kSeparador := ""

      // #########################
      // 03 - TXT COM SEPARADOR ##  
      // #########################
      Case Substr(cComboBx1,01,02) == "03"
           kSeparador := Alltrim(cSeparador)

      // #########################
      // 04 - CSV SEM TABULAÇÂO ##
      // #########################
      Case Substr(cComboBx1,01,02) == "04"
           kSeparador := ""
        
     // #########################
     // 05 - CSV COM SEPARADOR ##
     // #########################
     Case Substr(cComboBx1,01,02) == "05"
          kSeparador := Alltrim(cSeparador)

   EndCase

   If lCabecalho == .T.
      cString := cString + 'Nº Pedido'          + kSeparador + ;
                           'Código'             + kSeparador + ;
                           'Loja'               + kSeparador + ;
                           'Clientes'           + kSeparador + ;
                           'Código'             + kSeparador + ;
                           'Vendedores'         + kSeparador + ;
                           'Dta Emi. OP'        + kSeparador + ;
                           'Nº OP'              + kSeparador + ;
                           'Dta Ent. Orig.'     + kSeparador + ;
                           'Dta Entrega'        + kSeparador + ;
                           'Dta Finalizada'     + kSeparador + ;
                           'Cod.Produto'        + kSeparador + ;
                           'Item da OP'         + kSeparador + ;
                           'Medida Faca'        + kSeparador + ;
                           'Papel'              + kSeparador + ;
                           'Tubete'             + kSeparador + ;
                           'Serrilha'           + kSeparador + ;
                           'Característica'     + kSeparador + ;
                           'Quantdiade'         + kSeparador + ;
                           'Und'                + kSeparador + ;
                           'Metros Lineares'    + kSeparador + ;
                           'M2'                 + kSeparador + ;
                           'Quant. Empenho'     + kSeparador + ;
                           'Quant. Fecham.'     + kSeparador + ;
                           'Cod.Comp.'          + kSeparador + ;
                           'Componentes'        + kSeparador + ;
                           'Cód.Transp.'        + kSeparador + ;
                           'Transportadoras'    + kSeparador + ;
                           'Máquina 01'         + kSeparador + ;
                           'Operador 01'        + kSeparador + ;
                           'Tempo 01'           + kSeparador + ;
                           'Máquina 02'         + kSeparador + ;
                           'Operador 02'        + kSeparador + ;
                           'Tempo 02'           + kSeparador + ;
                           'Máquina 03'         + kSeparador + ;
                           'Operador 03'        + kSeparador + ;
                           'Tempo 03'           + kSeparador + Chr(13) + chr(10)

   Endif

   // ##############################
   // Imprime os dados no arquivo ##
   // ##############################
   For nContar = 1 to Len(aBrowse)

       cString := cString + aBrowse[nContar,02] + kSeparador + ;
                            aBrowse[nContar,03] + kSeparador + ;
                            aBrowse[nContar,04] + kSeparador + ;
                            aBrowse[nContar,05] + kSeparador + ;
                            aBrowse[nContar,06] + kSeparador + ;
                            aBrowse[nContar,07] + kSeparador + ;
                            aBrowse[nContar,08] + kSeparador + ;
                            aBrowse[nContar,09] + kSeparador + ;
                            aBrowse[nContar,11] + kSeparador + ;
                            aBrowse[nContar,12] + kSeparador + ;
                            aBrowse[nContar,14] + kSeparador + ;
                            aBrowse[nContar,15] + kSeparador + ;
                            aBrowse[nContar,16] + kSeparador + ;
                            aBrowse[nContar,17] + kSeparador + ;
                            aBrowse[nContar,18] + kSeparador + ;
                            aBrowse[nContar,19] + kSeparador + ;
                            aBrowse[nContar,20] + kSeparador + ;
                            str(aBrowse[nContar,21],10,02) + kSeparador + ;
                            aBrowse[nContar,22] + kSeparador + ;
                            Str(aBrowse[nContar,23],10,02) + kSeparador + ;
                            Str(aBrowse[nContar,24],10,02) + kSeparador + ;
                            Str(aBrowse[nContar,25],10,02) + kSeparador + ;
                            Str(aBrowse[nContar,26],10,02) + kSeparador + ;
                            aBrowse[nContar,27] + kSeparador + ;
                            aBrowse[nContar,28] + kSeparador + ;
                            aBrowse[nContar,29] + kSeparador + ;
                            aBrowse[nContar,30] + kSeparador + ;
                            aBrowse[nContar,31] + kSeparador + ;
                            aBrowse[nContar,32] + kSeparador + ;
                            aBrowse[nContar,33] + kSeparador + ;
                            aBrowse[nContar,34] + kSeparador + ;
                            aBrowse[nContar,35] + kSeparador + ;
                            aBrowse[nContar,36] + kSeparador + ;
                            aBrowse[nContar,37] + kSeparador + ;
                            aBrowse[nContar,38] + kSeparador + ;
                            aBrowse[nContar,39] + kSeparador + ;
                            aBrowse[nContar,40] + kSeparador + chr(13) + chr(10)

   Next nContar

   // #####################################
   // Gera o arquivo conforme parâmetros ##
   // #####################################
   nHdl := fCreate(cGeraTXT)

   If nHdl == -1
      MsgaStop("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Erro ao gravar arquivo TXT." + chr(13) + chr(10) + "Verifique se a pasta informada está correta.")
      Return(.T.)
   Endif

   fWrite (nHdl, cString ) 
   fClose(nHdl)

   MsgAlert("Arquivo " + Alltrim(cGeraTXT) + " gerado com sucesso.")
   
Return(.T.)

// ############################################################################
// Função que abre diálogo para seleção do caminho de gravação do arquvo TXT ##
// ############################################################################
Static Function CaminhoTXT()

   cGeraTXT := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )

   cOriCaminho := Alltrim(cGeraTXT)

   Do Case
      // 01 - TABULADO
      Case Substr(cComboBx1,01,02) == "01"
           cGeraTXT := Alltrim(cGeraTXT) + "Template_Producao.TXT"

      // 02 - TXT SEM TABULAÇÃO
      Case Substr(cComboBx1,01,02) == "02"
           cGeraTXT := Alltrim(cGeraTXT) + "Template_Producao.TXT"

      // 03 - TXT COM SEPARADOR
      Case Substr(cComboBx1,01,02) == "03"
           cGeraTXT := Alltrim(cGeraTXT) + "Template_Producao.TXT"

      // 04 - CSV SEM TABULAÇÂO
      Case Substr(cComboBx1,01,02) == "04"
           cGeraTXT := Alltrim(cGeraTXT) + "Template_Producao.CSV"
        
      // 05 - CSV COM SEPARADOR
      Case Substr(cComboBx1,01,02) == "05"
           cGeraTXT := Alltrim(cGeraTXT) + "Template_Producao.CSV"

   EndCase

Return(.T.)

// ###############################################
// Função que gera a saída da pesquisa em Excel ##
// ###############################################
Static Function Geraexcel(kProducao)

   // ####################################################
   // Verifica se o excel está instalado no equipamento ##
   // ####################################################
   If ! ApOleClient( 'MsExcel' )
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
	  Return(Nil)
   EndIf

   If Empty(Alltrim(kProducao))
      MsgAlert("Nenhum registro selecionado para visualização.")
      Return(.T.)
   Endif

   // ################################################################
   // Envia para a função que gera o excel do resultado da pesquisa ##
   // ################################################################
   MsgRun("Favor Aguarde! Gerando Excel do resultado da pesquisa ...", "Gerando Excel de resultados",{|| xGeraexcel() })
   
Return

// ###################################################################
// Função que grava a indicação de impressão, grupo e totalizadores ##
// ###################################################################
Static Function xGeraexcel()

    Local cString      := ""
    Local xComando     := ""
    Local nContar      := 0
	Local oExcelApp
	Local oExcel
	Local cSpreadSheet := ""
	Local cTable       := ""
	Local cArq         := CriaTrab(Nil,.F.) + ".xml"
	Local cDirTmp      := GetTempPath()
    Local nColunas     := 0

    Local cPesquisa    := "Template de Produção - Período de " + Dtoc(dInicial) + " a " + Dtoc(dFinal)

	oExcel := FWMSEXCEL():New()
	cSpreadSheet := Alltrim(cPesquisa)
	cTable       := Alltrim(cPesquisa)
	oExcel:AddworkSheet(cSpreadSheet)

	oExcel:AddTable (cSpreadSheet,cTable)

    // ############################
    // Cria o cabeçalho do excel ##
    // ############################
    For nContar := 1 to Len(aHead)
   	    oExcel:AddColumn(cSpreadSheet,cTable,aHead[nContar],1,1,.F.)
        nColunas += 1
    Next nContar                                       
    
    // ###############################
    // Imprime os dados da consulta ##
    // ###############################
	For nContar := 1 To Len(aBrowse)

        // ################################
        // Carrega o conteúdo dos campos ##
        // ################################
        cString := "{"

        For nVezes = 1 to Len(aBrowse[1])
            If nVezes == 21 .Or. nVezes == 23 .Or. nVezes == 24 .Or. nVezes == 25 .Or. nVezes == 26 
               cString := cString + "'" + StrTran(StrTran(StrTran(aBrowse[nContar,nVezes], "'", ""), '"', ""), ".", ",")• + "',"
            Else   
               cString := cString + "'" + StrTran(StrTran(aBrowse[nContar,nVezes], "'", ""), '"', "") + "',"            
            Endif
        Next nVezes    

        // ###########################
        // Elimina a última vírgula ##
        // ###########################       
        cString := Substr(cString,01, Len(Alltrim(cString))-1) + "}"
                                             
        // ####################
        // Executa o comando ##
        // ####################
  		oExcel:AddRow(cSpreadSheet,cTable, &(cString) )

    Next nContar

    // ###################################
    // Cria o arquivo para visualização ##
    // ###################################
	cArq := CriaTrab( NIL, .F. ) + ".xml"
	cDirTmp := GetTempPath()

	oExcel:Activate()
	oExcel:GetXMLFile(cArq)

	If __CopyFile( cArq, cDirTmp + cArq )
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cDirTmp + cArq )
		oExcelApp:SetVisible(.T.)
	EndIf

Return(.T.)

// #############################################
// Função que imprime o Roteiro de Acabamento ##
// #############################################
Static Function ImpRotAcaba()

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
   Local cNomeCliente := ""
   Local cEndereco    := ""
   Local cCidade      := ""
   Local cEstado      := ""
   Local cNomeTransp  := ""
   Local cAtendimento := ""
   Local nAdicional   := 15
   Local cEntresi     := ""
   Local nContar      := 0
   Local lMarcados    := .F.
    
   Private aObs       := {}
   Private cObs       := ""
   Private _nQuant    := 0
   Private _nTot      := 0
   Private _nIpi      := 0
   Private _nTamLin   := 80
   Private _nVia      := 1
   Private _nPagina   := 1
   Private _nIniLin   := 0
   Private _nLin      := 0
   Private nVertical  := 0
   Private _nCotDia   := 1
   Private _dCotDia   := DtoS( dDataBase )
   Private _cPrevisao := ""
   Private _cPrazoPag := ""
   Private _nMoeda    := 1
   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont30
   Private nLimvert   := 2500
   Private nDifLinha  := 0

   // ########################################################################
   // Verifica se houve a marcação de pelo menos um regsitro para impressão ##
   // ########################################################################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar

   If lMarcados == .F.
      MsgAlert("Nenhum registro foi marcado para ser impresso. Verifique!")
      Return(.T.)
   Endif
   
   // #############################
   // Cria o objeto de impressão ##
   // #############################
   oPrint := TmsPrinter():New()
	
   // #######################
   // Orientação da página ##
   // #######################
   //oPrint:SetLandScape() // Para Paisagem
   oPrint:SetPortrait()    // Para Retrato
	
   // #################################
   // Tamanho da página na impressão ##
   // #################################
   //oPrint:SetPaperSize(8) // A3
   //oPrint:SetPaperSize(1) // Carta
   oPrint:SetPaperSize(9)   // A4
	
   // ###########################################################################
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio ##
   // ###########################################################################
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

   // #####################################################
   // Pesquisa o nome da Empresa/Filial para o cabecalho ##
   // #####################################################
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   // #############################################################
   // Ordena o Array aBrowse pela data de Entrega para impressão ##
   // #############################################################
   ASORT(aBrowse,,,{ | x,y | x[11] < y[11] } )

   // ###############################################
   // Imprime o cabeçalho do Roteiro de Acabamento ##
   // ###############################################
   _nLin := 60

   ImpCabRotAcaba()

   // ###############################################
   // Imprime os produtos do Roteiro de Acabamento ##
   // ###############################################
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif    
   
       xNomeProduto := POSICIONE("SB1",1,XFILIAL("SB1") + aLista[nContar,11], "B1_DESC") + "" + ;
                       POSICIONE("SB1",1,XFILIAL("SB1") + aLista[nContar,11], "B1_DAUX")

       oPrint:Say( _nLin, 0125, aLista[nContar,09] , oFont10b  )
       oPrint:Say( _nLin, 0500, xNomeProduto       , oFont10b  )
       oPrint:Say( _nLin, 1700, aLista[nContar,12] , oFont10b  )
       oPrint:Say( _nLin, 1930, aLista[nContar,10] , oFont10b  )

       SomaLinhaAna(60)

       nDifLinha := nDifLinha - 60

   Next nContar

    SomaLinhaAna(30)

    oPrint:Line( nVertical, 0480, _nLin, 0480 )
    oPrint:Line( nVertical, 1600, _nLin, 1600 )
    oPrint:Line( nVertical, 1850, _nLin, 1850 )
    oPrint:Line( nVertical, 2300, _nLin, 2300 )

    SomaLinhaAna(30)

    _nLin := _nLin + nDifLinha

    oPrint:Line( 060, 0100, _nLin, 0100 )
    oPrint:Line( 060, 2300, _nLin, 2300 )

    oPrint:Line( nVertical, 0480, _nLin, 0480 )
    oPrint:Line( nVertical, 1600, _nLin, 1600 )
    oPrint:Line( nVertical, 1850, _nLin, 1850 )
    oPrint:Line( nVertical, 2300, _nLin, 2300 )

    oPrint:Line( _nLin, 0100, _nLin, 2300 )

 	oPrint:Preview()
	
	MS_FLUSH()

Return .T.

// ##########################################################
// Função que imprime o Cabeçalho do Roteiro de Acabamento ##
// ##########################################################
Static Function ImpCabRotAcaba()

   _nLin := 60

   // ######################
   // Início do relatório ##
   // ######################
   oPrint:StartPage()
	
   oPrint:Line( _nLin, 0100, _nLin, 2300 )   
   _nLin += 30

   // ###########################
   // Logotipo e identificação ##
   // ###########################
   oPrint:SayBitmap( _nLin, 0150, "logoautoma.bmp", 0700, 0200 )
   _nLin += 90
    
    oPrint:Say( _nLin, 0990, "ROTEIRO DE ACABAMENTO", oFont20b  )
    _nLin += 120

    oPrint:Line( _nLin, 0100, _nLin, 2300 )

    nVertical := _nLin

    _nLin += 50    

    oPrint:Say( _nLin, 0125, "Nº OP"                , oFont12b  )
    oPrint:Say( _nLin, 0500, "Descrição dos Produtos", oFont12b  )
    oPrint:Say( _nLin, 1650, "Tubete"                , oFont12b  )
    oPrint:Say( _nLin, 1930, "Data Entrega"          , oFont12b  )

    _nLin += 90
    oPrint:Line( _nLin, 0100, _nLin, 2300 )
    _nLin += 30    

    nDifLinha := 2500

Return(.T.)

// Função que soma linhas para impressão
Static Function SomaLinhaAna(nLinhas)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10

      _nLin := _nLin + nDifLinha

      oPrint:Line( 060, 0100, _nLin, 0100 )
      oPrint:Line( 060, 2300, _nLin, 2300 )

      oPrint:Line( nVertical, 0480, _nLin, 0480 )
      oPrint:Line( nVertical, 1600, _nLin, 1600 )
      oPrint:Line( nVertical, 1850, _nLin, 1850 )
      oPrint:Line( nVertical, 2300, _nLin, 2300 )

      oPrint:Line( _nLin, 0100, _nLin, 2300 )

      oPrint:EndPage()

      ImpCabRotAcaba()

   Endif
   
Return .T.      

// #######################################################################################################
// Função que abre janela para marcar/desmarcar os produtos a serem utilizados no Roteiro de Acabamento ##
// #######################################################################################################
Static Function xImpRotAcaba(kProducao)

   Local cMemo1	 := ""
   Local oMemo1

   Local nContar := 0

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgROT

   If Empty(Alltrim(kProducao))
      MsgAlert("Nenhum registro selecionado para visualização.")
      Return(.T.)
   Endif

   // ###################################################
   // Carrega o array aLista com o conteúdo do aBrowse ##
   // ###################################################
   For nContar = 1 to Len(aBrowse)
       aAdd( aLista, { .F. ,;
                       aBrowse[nContar,02] ,;
                       aBrowse[nContar,03] ,;
                       aBrowse[nContar,04] ,;
                       aBrowse[nContar,05] ,;
                       aBrowse[nContar,06] ,;
                       aBrowse[nContar,07] ,;
                       aBrowse[nContar,08] ,;
                       aBrowse[nContar,09] ,;
                       aBrowse[nContar,12] ,;
                       aBrowse[nContar,15] ,;
                       aBrowse[nContar,19] })


//                       aBrowse[nContar,11] ,;
//                       aBrowse[nContar,14] ,;
//                       aBrowse[nContar,18] })

   Next nContar                       

   DEFINE MSDIALOG oDlgROT TITLE "Relatório Template de Produção" FROM C(178),C(181) TO C(600),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgROT

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlgROT

   @ C(036),C(005) Say "Selecione os produtos a serem considerados para o relatório" Size C(144),C(008) COLOR CLR_BLACK PIXEL OF oDlgROT

   @ C(195),C(005) Button "Marcar Todos"    Size C(050),C(012) PIXEL OF oDlgROT ACTION( MrcDsmrcAca(1) )
   @ C(195),C(056) Button "Desmarcar Todos" Size C(050),C(012) PIXEL OF oDlgROT ACTION( MrcDsmrcAca(2) )
   @ C(195),C(178) Button "Imprimir"        Size C(037),C(012) PIXEL OF oDlgROT ACTION( ImpRotAcaba() )
   @ C(195),C(351) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgROT ACTION( oDlgROT:End() )

   @ 058,005 LISTBOX oLista FIELDS HEADER "M", "Nº Pedido", "Código", "Loja", "Clientes", "Código", "Vendedores", "Dta.Emi.OP", "Nº OP", "Dta Entrega", "Produto", "Tubete" ;
             PIXEL SIZE 488,183 OF oDlgROT ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )
   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),; // 01 - Marcação
                           aLista[oLista:nAt,02]         ,; // 02 - Nº Pedido de Venda
                           aLista[oLista:nAt,03]         ,; // 03 - Código do Cliente
                           aLista[oLista:nAt,04]         ,; // 04 - Loja do Cliente
                           aLista[oLista:nAt,05]         ,; // 05 - Descrição dos Clientes
                           aLista[oLista:nAt,06]         ,; // 06 - Código Vendedor
                           aLista[oLista:nAt,07]         ,; // 07 - Descrilão dos Vendedores
                           aLista[oLista:nAt,08]         ,; // 08 - Data emissão da OP
                           aLista[oLista:nAt,09]         ,; // 09 - Nº da OP
                           aLista[oLista:nAt,10]         ,; // 10 - Data de entrega
                           aLista[oLista:nAt,11]         ,; // 11 - Código do Produto
                           aLista[oLista:nAt,12]         }} // 12 - Tubete

   ACTIVATE MSDIALOG oDlgROT CENTERED 

Return(.T.)

// #####################################################
// Função que marca/desmarca registros para impressão ##
// #####################################################
Static Function MrcDsmrcAca(kTipo)

   Local cContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function TGeraPCSV(kProducao)

   Local aCabExcel   :={}
   Local aItensExcel :={}
   
   // ####################################################
   // Verifica se o excel está instalado no equipamento ##
   // ####################################################
   If ! ApOleClient( 'MsExcel' )
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
	  Return(Nil)
   EndIf

   If Empty(Alltrim(kProducao))
      MsgAlert("Nenhum registro selecionado para visualização.")
      Return(.T.)
   Endif

   // AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
   AADD(aCabExcel, {'Nº Pedido'      , "C", 06, 00 })
   AADD(aCabExcel, {'Código'         , "C", 06, 00 })
   AADD(aCabExcel, {'Loja'           , "C", 03, 00 })
   AADD(aCabExcel, {'Clientes'       , "C", 60, 00 })
   AADD(aCabExcel, {'Código'         , "C", 06, 00 })
   AADD(aCabExcel, {'Vendedores'     , "C", 60, 00 })
   AADD(aCabExcel, {'Dta Emi. OP'    , "C", 10, 00 })
   AADD(aCabExcel, {'Nº OP'          , "C", 15, 00 })
   AADD(aCabExcel, {'Dta Ent. Orig.' , "C", 10, 00 })
   AADD(aCabExcel, {'Dta Entrega'    , "C", 10, 00 })
   AADD(aCabExcel, {'Dta Finalizada' , "C", 10, 00 })
   AADD(aCabExcel, {'Cod.Produto'    , "C", 30, 00 })
   AADD(aCabExcel, {'Item da OP'     , "C", 02, 00 })
   AADD(aCabExcel, {'Medida Faca'    , "C", 30, 00 })
   AADD(aCabExcel, {'Papel'          , "C", 30, 00 })
   AADD(aCabExcel, {'Tubete'         , "C", 10, 00 })
   AADD(aCabExcel, {'Serrilha'       , "C", 10, 00 })
   AADD(aCabExcel, {'Característica' , "C", 30, 00 })
   AADD(aCabExcel, {'Quant. OP'      , "N", 10, 02 })
   AADD(aCabExcel, {'Und'            , "C", 02, 00 })
   AADD(aCabExcel, {'Metros Lineares', "N", 10, 02 })
   AADD(aCabExcel, {'M2'             , "N", 10, 02 })
   AADD(aCabExcel, {'Quant. Empenho' , "N", 10, 02 })
   AADD(aCabExcel, {'Quant. Fecham.' , "N", 10, 02 })
   AADD(aCabExcel, {'Cod.Comp.'      , "C", 06, 00 })
   AADD(aCabExcel, {'Componentes'    , "C", 60, 00 })
   AADD(aCabExcel, {'Cód.Transp.'    , "C", 06, 00 })
   AADD(aCabExcel, {'Transportadoras', "C", 60, 00 })
   AADD(aCabExcel, {'Máquina 01'     , "C", 20, 00 })
   AADD(aCabExcel, {'Operador 01'    , "C", 20, 00 })
   AADD(aCabExcel, {'Tempo 01'       , "C", 10, 00 })
   AADD(aCabExcel, {'Máquina 02'     , "C", 20, 00 })
   AADD(aCabExcel, {'Operador 02'    , "C", 20, 00 })
   AADD(aCabExcel, {'Tempo 02'       , "C", 10, 00 })
   AADD(aCabExcel, {'Máquina 03'     , "C", 20, 00 })
   AADD(aCabExcel, {'Operador 03'    , "C", 20, 00 })
   AADD(aCabExcel, {'Tempo 03'       , "C", 10, 00 })
   AADD(aCabExcel, {" "              , "C", 01, 00 })

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| GProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","TEMPLATE DE PRODUÇÃO - PERÍODO DE " + Dtoc(dInicial) + " A " + Dtoc(dFinal), aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function GProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aBrowse)

       aAdd( aCols, {aBrowse[nContar,02],;
                     aBrowse[nContar,03],;
                     aBrowse[nContar,04],;
                     aBrowse[nContar,05],;
                     aBrowse[nContar,06],;
                     aBrowse[nContar,07],;
                     aBrowse[nContar,08],;
                     aBrowse[nContar,09],;
                     aBrowse[nContar,11],;
                     aBrowse[nContar,12],;
                     aBrowse[nContar,13],;
                     "'" + Alltrim(aBrowse[nContar,15]) + "'",;
                     aBrowse[nContar,16],;
                     aBrowse[nContar,17],;
                     aBrowse[nContar,18],;
                     aBrowse[nContar,19],;
                     aBrowse[nContar,20],;
                     aBrowse[nContar,21],;
                     aBrowse[nContar,22],;
                     aBrowse[nContar,23],;
                     aBrowse[nContar,24],;
                     aBrowse[nContar,25],;
                     aBrowse[nContar,26],;
                     aBrowse[nContar,27],;
                     aBrowse[nContar,28],;
                     aBrowse[nContar,29],;
                     aBrowse[nContar,30],;
                     aBrowse[nContar,31],;
                     aBrowse[nContar,32],;
                     aBrowse[nContar,33],;
                     aBrowse[nContar,34],;
                     aBrowse[nContar,35],;
                     aBrowse[nContar,36],;
                     aBrowse[nContar,37],;
                     aBrowse[nContar,38],;
                     aBrowse[nContar,39],;
                     aBrowse[nContar,40],;
                     ""                 })

   Next nContar

Return(.T.)