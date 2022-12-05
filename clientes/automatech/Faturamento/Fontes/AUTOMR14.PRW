#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR14.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/09/2011                                                          *
// Objetivo..: Tracker Automatech                                                  *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR14()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea  := {}
   Local _aAlias := {}

   Local lLibera         := .F.

   Private oGet1         := Space(06)
   Private oGet2         := Space(06)
   Private oGet3         := Space(06)
   Private oGet4         := Space(06)
   Private oGet5         := Space(09)       
   Private oGet6         := Space(06)
   Private oGet7         := Space(40)
   Private oGet8         := Space(40)
   Private oGet9         := Space(40)
   Private oGet10        := Space(40)   
   Private oGet11        := Space(06)   
   Private oGet12        := Space(06)   
   Private oGet13        := Space(06)         

   Private aBrowse       := {} 
   Private lMoeda1       := .F.
   Private lMoeda2       := .F.
   Private cOportunidade := Space(06)
   Private cProposta     := Space(06)
   Private cOrcamento    := Space(06)
   Private cPedido       := Space(06)
   Private cPro2         := Space(06)
   Private cOrc2         := Space(06)
   Private cPed2         := Space(06)

   Private cNota         := Space(06)
   Private cProducao     := Space(06)
   Private cNomeCliente  := ""
   Private cNomeCondicao := ""
   Private cNomeV01      := ""
   Private cNomeV02      := ""
   Private aComboBx1     := {"", "Oportunidade", "Proposta Comercial", "Orçamento", "Pedido de Venda", "Nota Fiscal"}
   Private aComboBx2     := {"", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas" }
   Private cComboBx1
   Private cComboBx2
      
   cCodigo             := Space(06)
   cOportunidade       := ""
   cProposta           := ""
   cOrcamento          := ""
   cPedido             := ""
   cNota               := ""
   cProducao           := ""
   cNomeCliente        := ""
   cNomeCondicao       := ""
   cNomeV01            := ""
   cNomeV02            := ""

   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTOMR14")

   DEFINE FONT oFont Name "Arial" Size 0, -14 BOLD

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg TITLE "Rastreabilidade de Oportunidades" FROM C(178),C(181) TO C(480),C(700) PIXEL

   @ C(010),C(005) Say "CÓDIGO:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(075) Say "FILIAL:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(007),C(027) MsGet oGet1 Var cCodigo Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(008),C(090) ComboBox cComboBx2 Items aComboBx2 Size C(060),C(010) PIXEL OF oDlg

   @ C(020),C(005) Say Replicate("-",250) Size C(250),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg

   @ C(032),C(005) Say "OPORTUNIDADE:"       Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(060) Say "PROP.COMERCIAL"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(110) Say "ORÇAMENTO"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(160) Say "PEDIDO DE VENDA"     Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "M O E D A - 1"       Size C(050),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg
   @ C(072),C(005) Say "M O E D A - 2"       Size C(050),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(005) Say "CLIENTE:"            Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(105),C(005) Say "CONDIÇÃO PAGAMENTO:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(120),C(005) Say "VENDEDOR 01:"        Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(135),C(005) Say "VENDEDOR 02:"        Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(029),C(060) MsGet oGet1  Var cOportunidade when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(055),C(060) MsGet oGet2  Var cProposta     when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(055),C(110) MsGet oGet3  Var cOrcamento    when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(055),C(160) MsGet oGet4  Var cPedido       when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(070),C(060) MsGet oGet11 Var cPro2         when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(070),C(110) MsGet oGet12 Var cOrc2         when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(070),C(160) MsGet oGet13 Var cPed2         when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(089),C(060) MsGet oGet7  Var cNomeCliente  when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(103),C(060) MsGet oGet8  Var cNomeCondicao when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(118),C(060) MsGet oGet9  Var cNomeV01      when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(133),C(060) MsGet oGet10 Var cNomeV02      when lLibera Size C(195),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   // Oportunidade
   @ 070,280  BUTTON "Produtos" Size 40,12 when !Empty(cPedido) ACTION ( Abre_Produto(cPedido, cComboBx2)) OF oDlg Pixel
   @ 090,280  BUTTON "Produtos" Size 40,12 when !Empty(cPed2)   ACTION ( Abre_Produto(cPed2  , cComboBx2)) OF oDlg Pixel   

   @ 037,130  BUTTON "Visualizar" Size 40,12 when !Empty(cOportunidade) ACTION (Abre_Tela(1, cComboBx2, cOportunidade )) OF oDlg Pixel
   @ 010,225  BUTTON "Pesquisar"  Size 50,12 when !Empty(cCodigo) ACTION( PESQDADOS( cCodigo, cComboBx2 ) ) OF oDlg Pixel
   @ 010,280  BUTTON "Voltar"     Size 50,12 ACTION( odlg:end() ) OF oDlg Pixel

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que prepara a impressão do relatório
Static Function PESQDADOS( cCodigo, cComboBx2 )

   Local cSql      := ""
   Private aBrowse := {}

   cOportunidade := Space(06)
   cProposta     := Space(06)
   cOrcamento    := Space(06)
   cPedido       := Space(06)
   cPro2         := Space(06)
   cOrc2         := Space(06)
   cPed2         := Space(06)
   cNota         := Space(06)
   cProducao     := Space(06)
   cNomeCliente  := ""
   cNomeCondicao := ""
   cNomeV01      := ""
   cNomeV02      := ""

   oGet1         := Space(06)
   oGet2         := Space(06)
   oGet3         := Space(06)
   oGet4         := Space(06)
   oGet5         := Space(09)       
   oGet6         := Space(06)
   oGet7         := Space(40)
   oGet8         := Space(40)
   oGet9         := Space(40)
   oGet10        := Space(40)   
   oGet11        := Space(06)   
   oGet12        := Space(06)   
   oGet13        := Space(06)         

   // Valida os dados informados. Somente permite a informação de um dos campos para pesquisa.
   If Empty(Alltrim(cCodigo))
      MsgAlert("Código a ser pesquisado não foi informado.")
      Return .T.
   Endif
      
   If Empty(Alltrim(cComboBx2))
      MsgAlert("Filial não informada para pesquisa.")
      Return .T.
   Endif

   // Dispara a pesquisa dos dados da Oportunidade
   PESQ_OPORTUNIDADE( cCodigo, cComboBx2 )

Return .T.

// Função que pesquisa pela informação de Oportunidade, Proposta Comercial ou Orçamento
Static Function PESQ_OPORTUNIDADE( cCodigo, cComboBx2 )

   Local nContar := 0
   Local nCodV01 := ""
   Local nCodV02 := ""
   Local nCodPag := ""

   // Verifica se abre os botões de Moeda R$ e Moeda US$
   If Select("T_CONJUNTO") > 0
      T_CONJUNTO->( dbCloseArea() )
   EndIf

   csql := ""
   cSql := "SELECT A.CJ_NUM    ," 
   cSql += "       A.CJ_PROPOST," 
   cSql += "       A.CJ_NROPOR ,"
   cSql += "       A.CJ_CLIENTE,"
   cSql += "       A.CJ_LOJA   ,"
   cSql += "       B.A1_NOME   ,"
   cSql += "       A.CJ_VEND1  ,"
   cSql += "       A.CJ_VEND2   "
   cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B  "
   csql += " WHERE CJ_NROPOR      = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''       "
   cSql += "   AND A.CJ_CLIENTE   = B.A1_COD "
   cSql += "   AND A.CJ_LOJA      = B.A1_LOJA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONJUNTO", .T., .T. )

   If T_CONJUNTO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para esta Oportunidade.")
      Return .T.
   ENDIF

   T_CONJUNTO->( DbGoTop () )

   // Caotura o Nome do Cliente
   cNomeCliente := T_CONJUNTO->A1_NOME

   nContar := 1

   WHILE !T_CONJUNTO->( EOF() )

      cNomeCliente := T_CONJUNTO->A1_NOME

      If nContar == 1
         cOportunidade := cCodigo
         cProposta     := T_CONJUNTO->CJ_PROPOST
         cOrcamento    := T_CONJUNTO->CJ_NUM

         // Pesquisa o nº do Pedido de Venda
         If Select("T_PEDIDO") > 0
            T_PEDIDO->( dbCloseArea() )
         EndIf

         csql := ""
         csql := "SELECT C6_NUM "
         cSql += "  FROM " + RetSqlName("SC6010")
         csql += " WHERE C6_NUMORC LIKE '" + Alltrim(T_CONJUNTO->CJ_NUM)      + "%'"
         cSql += "   AND C6_FILIAL    = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
         csql += "   AND R_E_C_D_E_L_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

         IF T_PEDIDO->( Eof() )
            cPedido := ""
         Else
            cPedido := T_PEDIDO->C6_NUM
         Endif
                        
      Else
         cOportunidade := cCodigo
         cPro2         := T_CONJUNTO->CJ_PROPOST
         cOrc2         := T_CONJUNTO->CJ_NUM

         // Pesquisa o nº do Pedido de Venda
         If Select("T_PEDIDO") > 0
            T_PEDIDO->( dbCloseArea() )
         EndIf

         csql := ""
         csql := "SELECT C6_NUM "
         cSql += "  FROM " + RetSqlName("SC6010")
         csql += " WHERE C6_NUMORC LIKE '" + Alltrim(T_CONJUNTO->CJ_NUM)      + "%'"
         cSql += "   AND C6_FILIAL    = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
         csql += "   AND R_E_C_D_E_L_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

         IF T_PEDIDO->( Eof() )
            cPed2   := ""
         Else
            cPed2   := T_PEDIDO->C6_NUM
         Endif

      Endif
      
      nContar := nContar + 1

      T_CONJUNTO->( DbSkip() )
      
   ENDDO   

   // Pesquisa o nome dos Vendedores do Pedido de Venda
   If Select("T_CABECALHO") > 0
      T_CABECALHO->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT C5_VEND1  , "
   csql += "       C5_VEND2  , "
   csql += "       C5_CONDPAG  "
   cSql += "  FROM " + RetSqlName("SC5010")
   csql += " WHERE C5_NUM = '" + Alltrim(cPedido) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CABECALHO", .T., .T. )

   nCodV01 := T_CABECALHO->C5_VEND1
   nCodV02 := T_CABECALHO->C5_VEND2
   nCodPag := T_CABECALHO->C5_CONDPAG
   
   // Pesquisa o vendedor 1
   IF !Empty(Alltrim(nCodV01))

      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf

      csql := ""
      csql := "SELECT A3_COD , "
      csql += "       A3_NOME  "
      cSql += "  FROM " + RetSqlName("SA3010")
      csql += " WHERE A3_COD = '" + Alltrim(nCodV01) + "'"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
      
      cNomeV01 := IIF(T_VENDEDOR->( EOF() ), "", T_VENDEDOR->A3_NOME)

   Endif
   
   // Pesquisa o Vendedor 2
   IF !Empty(Alltrim(nCodV02))

      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf

      csql := ""
      csql := "SELECT A3_COD , "
      csql += "       A3_NOME  "
      cSql += "  FROM " + RetSqlName("SA3010")
      csql += " WHERE A3_COD = '" + Alltrim(nCodV02) + "'"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
      
      cNomeV02 := IIF(T_VENDEDOR->( EOF() ), "", T_VENDEDOR->A3_NOME)

   Endif

   // Pesquisa a condição de Pagamento
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT E4_CODIGO, "
   csql += "       E4_DESCRI  "
   cSql += "  FROM " + RetSqlName("SE4010")
   csql += " WHERE E4_CODIGO = '" + Alltrim(nCodPag) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   cNomeCondicao := IIF(T_CONDICAO->( EOF() ), "", T_CONDICAO->E4_DESCRI)
      
Return .T.

// Função que abre a tela conforme o botão selecionado
Static Function ABRE_TELA( _Tipo, cComboBx2, _Codigo)

   Local aIndex   := {}
   Local cFiltro1 := "AD1_FILIAL == '" + Substr(cComboBx2,01,02) + "', AD1_NROPOR == '" + Alltrim(_Codigo) + "'"
   Local cFiltro2 := "C5_FILIAL  == '" + Substr(cComboBx2,01,02) + "', C5_NUM     == '" + Alltrim(_Codigo) + "'"
   Local cFiltro3 := "ADY_FILIAL == '" + Substr(cComboBx2,01,02) + "', ADY_PROPOS == '" + Alltrim(_Codigo) + "'"
   
   Private aRotina := {;
                      { "Pesquisar"  , ""         , 0 , 1 },;
                      { "Visualizar" , "AxVisual" , 0 , 2 },;
                      { "Incluir"    , ""         , 0 , 3 },;
                      { "Alterar"    , ""         , 0 , 4 },;
                      { "Excluir"    , ""         , 0 , 5 } ;
                      }

   //Determina a Expressão do Filtro
   Do Case
      Case _Tipo == 1
           Private bFiltraBrw := { || FilBrowse( "AD1" , @aIndex , @cFiltro1 ) } 
           Private cCadastro := "Consulta de Oprtunidades"
      Case _Tipo == 2
           Private bFiltraBrw := { || FilBrowse( "SC5" , @aIndex , @cFiltro2 ) } 
           Private cCadastro := "Consulta de Pedido de venda"
      Case _Tipo == 3
           Private bFiltraBrw := { || FilBrowse( "ADY" , @aIndex , @cFiltro3 ) } 
           Private cCadastro := "Consulta de Proposta Comercial"

   EndCase        

   //Efetiva o Filtro antes da Chamada a mBrowse
   Eval( bFiltraBrw )    

   Do Case
      Case _Tipo == 1
           mBrowse( 6 , 1 , 22 , 75 , "AD1" )
           EndFilBrw( "AD1" , @aIndex ) //Finaliza o Filtro

      Case _Tipo == 2
           mBrowse( 6 , 1 , 22 , 75 , "SC5", .f. )
           EndFilBrw( "SC5" , @aIndex ) //Finaliza o Filtro

      Case _Tipo == 3
           mBrowse( 6 , 1 , 22 , 75 , "ADY", .f. )
           EndFilBrw( "ADY" , @aIndex ) //Finaliza o Filtro

   EndCase        

Return( NIL )
 
// Função que abre a tela de visualização de produtos
Static Function ABRE_PRODUTO( _Pedido, cComboBx2 )

   Local cSql      := ""

   Private aBrowse := {} 
   
   // Pesquisa os Produtos do Pedido de Venda para alimentar o Grid de Produtos da Tela.
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C6_PRODUTO," + chr(13)
   cSql += "       B.B1_DESC   ," + chr(13)
   cSql += "       B.B1_DAUX   ," + chr(13)
   cSql += "       A.C6_QTDVEN ," + chr(13)
   cSql += "       A.C6_PRCVEN ," + chr(13)
   cSql += "       A.C6_VALOR  ," + chr(13)
   cSql += "       A.C6_NOTA   ," + chr(13)
   cSql += "       A.C6_DATFAT  " + chr(13)
   cSql += "  FROM " + RetSqlName("SC6010") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1010") + " B  " + chr(13)
   cSql += " WHERE A.C6_NUM          = '" + Alltrim(_Pedido)                 + "'" + chr(13)
   cSql += "   AND A.C6_FILIAL       = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" + chr(13)
   cSql += "   AND A.C6_PRODUTO      = B.B1_COD " + chr(13)
   cSql += "   AND A.R_E_C_D_E_L_    = ''       " + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If !T_PRODUTOS->( Eof() )
            
      While !T_PRODUTOS->( EOF() )

  	     aAdd( aBrowse, { Substr(T_PRODUTOS->C6_PRODUTO,01,06),;
                          T_PRODUTOS->B1_DESC                 ,;
                          STR(T_PRODUTOS->C6_QTDVEN,05)       ,;
                          STR(T_PRODUTOS->C6_PRCVEN,10,02)    ,;
                          STR(T_PRODUTOS->C6_VALOR,10,02)     ,;
                          SUBSTR(T_PRODUTOS->C6_NOTA,01,10)   ,;
                          Substr(T_PRODUTOS->C6_DATFAT,07,02) + "/" + Substr(T_PRODUTOS->C6_DATFAT,05,02) + "/" + Substr(T_PRODUTOS->C6_DATFAT,01,04) } )
         T_PRODUTOS->( DbSkip() )
               
      Enddo
      
   Endif   

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg2 TITLE "Produto do Pedido" FROM C(178),C(181) TO C(350),C(650) PIXEL

   oBrowse := TSBrowse():New(005,005,294,085,oDlg2,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('NFiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Data Fat.',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   @ 095,005 BUTTON "Voltar" Size 50,12 ACTION( odlg2:end() ) OF oDlg2 Pixel


   ACTIVATE MSDIALOG oDlg2 CENTERED  




Return .T.