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
User Function AUTOMR68()   
 
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
                   
   Private aBrowse       := {} 

   Private cOportunidade := Space(06)
   Private cProposta     := Space(06)
   Private cOrcamento    := Space(06)
   Private cPedido       := Space(06)
   Private cNota         := Space(06)
   Private cProducao     := Space(06)
   Private cNomeCliente  := ""
   Private cNomeCondicao := ""
   Private cNomeV01      := ""
   Private cNomeV02      := ""

   Private aComboBx1   := {"", "Oportunidade", "Proposta Comercial", "Orçamento", "Pedido de Venda", "Nota Fiscal", "Nº de Série"}
   Private aComboBx2   := U_AUTOM539(2, cEmpAnt) // {"", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos" }
   Private aComboBx3   := {"", "1", "51", "P1", "2", "52", "P2", "3", "53", "P3" }
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
      
   cCodigo             := Space(20)
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

   DEFINE FONT oFont Name "Arial" Size 0, -14 BOLD

   // Variáveis que definem a Ação do Formulário

   U_AUTOM628("AUTOMR68")

   DEFINE MSDIALOG oDlg TITLE "TRACKER - Automatech" FROM C(178),C(181) TO C(600),C(700) PIXEL

   @ C(010),C(005) Say "TIPO:"             Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(070) Say "CÓDIGO:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(010),C(133) Say "SÉRIE:"            Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(185) Say "FILIAL:"           Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(008),C(017) ComboBox cComboBx1 Items aComboBx1 Size C(050),C(010) PIXEL OF oDlg
   @ C(007),C(090) MsGet oGet1 Var cCodigo Size C(040),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   @ C(008),C(150) ComboBox cComboBx3 Items aComboBx3 When cComboBx1 = "Nota Fiscal"  Size C(030),C(010) PIXEL OF oDlg on change TROCAFILIAL()

   @ C(008),C(200) ComboBox cComboBx2 Items aComboBx2 When cComboBx1 <> "Nota Fiscal" Size C(055),C(010) PIXEL OF oDlg

   @ C(020),C(005) Say Replicate("-",250) Size C(250),C(020) FONT oFont COLOR CLR_BLACK PIXEL OF oDlg

   @ C(032),C(005) Say "OPORTUNIDADE:"       Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(005) Say "ORÇAMENTO:"          Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "NOTA FISCAL:"        Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(032),C(130) Say "PROPOSTA COMERCIAL:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(130) Say "PEDIDO DE VENDA:"    Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(130) Say "ORDEM DE PRODUÇÃO:"  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(075),C(005) Say "CLIENTE:"            Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(005) Say "CONDIÇÃO PAGAMENTO:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(105),C(005) Say "VENDEDOR 01:"        Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(120),C(005) Say "VENDEDOR 02:"        Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(131),C(005) Say "Produtos do Pedido de Venda"  Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(029),C(060) MsGet oGet1  Var cOportunidade when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(029),C(200) MsGet oGet2  Var cProposta     when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(060) MsGet oGet3  Var cOrcamento    when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(200) MsGet oGet4  Var cPedido       when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(058),C(060) MsGet oGet5  Var cNota         when lLibera Size C(066),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(058),C(200) MsGet oGet6  Var cProducao     when lLibera Size C(035),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(074),C(060) MsGet oGet7  Var cNomeCliente  when lLibera Size C(175),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(089),C(060) MsGet oGet8  Var cNomeCondicao when lLibera Size C(175),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(103),C(060) MsGet oGet9  Var cNomeV01      when lLibera Size C(175),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(117),C(060) MsGet oGet10 Var cNomeV02      when lLibera Size C(175),C(010) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   oBrowse := TSBrowse():New(180,005,324,070,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   // Oportunidade
   @ 037,120  BUTTON "Visualizar" Size 40,12 when !Empty(cOportunidade) ACTION (Abre_Tela(1, cComboBx2, cOportunidade )) OF oDlg Pixel

   // Proposta Comercial
// DEFINE SBUTTON FROM 038,300 when !Empty(cProposta)     TYPE 05 ACTION (Abre_Tela(3, cComboBx2, cOportunidade )) Of oDlg PIXEL ENABLE

   // Pedido de venda
// DEFINE SBUTTON FROM 056,300 when !Empty(cPedido)       TYPE 05 ACTION (Abre_Tela(2, cComboBx2, cPedido )) Of oDlg PIXEL ENABLE

   @ 255,225  BUTTON "Pesquisar" Size 50,12 when !Empty(cCodigo) ACTION( PESQDADOS( Alltrim(cCodigo), cComboBx1, cComboBx2 ) ) OF oDlg Pixel
   @ 255,280  BUTTON "Voltar"    Size 50,12 ACTION( odlg:end() ) OF oDlg Pixel

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que prepara a impressão do relatório
Static Function TROCAFILIAL()

   If cComboBx1 == "Nota Fiscal"

      If Empty(cComboBx3)
         Return .T.
      Endif
      
      If cComboBx3 == "1" .OR. cComboBx3 == "51" .OR. cComboBx3 == "P1"
         cComboBx2 := "01 - Porto Alegre"
      Endif
               
      If cComboBx3 == "2" .OR. cComboBx3 == "52" .OR. cComboBx3 == "P2"
         cComboBx2 := "02 - Caxias do Sul"
      Endif
               
      If cComboBx3 == "3" .OR. cComboBx3 == "53" .OR. cComboBx3 == "P3"
         cComboBx2 := "03 - Pelotas"
      Endif
      
   Endif
   
Return .T.

// Função que pesquisa os dados conforme informado
Static Function PESQDADOS( cCodigo, cComboBx1, cComboBx2 )

   Local   cSql    := ""
   Private aBrowse := {}
   Private xFilial := ""
   Private xNota   := ""
   Private xSerie  := ""

   // Caso a pesquisa for por nº de série, abre tela para selecionar a nota fiscal a ser pesquisada
   If Alltrim(cComboBx1) == "Nº de Série"
      If Empty(Alltrim(cCodigo))
         MsgAlert("Código a ser pesquisado não foi informado.")
         Return .T.
      Endif
      
      If Empty(Alltrim(cComboBx1))
         MsgAlert("Tipo não informado para pesquisa.")
         Return .T.
      Endif

      If Empty(Alltrim(cComboBx2))
         MsgAlert("Filial não informada para pesquisa.")
         Return .T.
      Endif

      xFilial := ""
      xNota   := ""
      xSerie  := ""

      NFSERIE(Alltrim(cCodigo))

      If Empty(Alltrim(xNota))
         Return .T.
      Else
         cCodigo   := Alltrim(xNota)
         cComboBx1 := "Nota Fiscal"
         cComboBx2 := xFilial
         cComboBx3 := xSerie
      Endif

   Endif

   cOportunidade := Space(06)
   cProposta     := Space(06)
   cOrcamento    := Space(06)
   cPedido       := Space(06)
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

   // Limpa o Grid de produtos
   aBrowse := {}

   oBrowse := TSBrowse():New(180,005,324,070,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Nº NF',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   // Valida os dados informados. Somente permite a informação de um dos campos para pesquisa.
   If Empty(Alltrim(cCodigo))
      MsgAlert("Código a ser pesquisado não foi informado.")
      Return .T.
   Endif
      
   If Empty(Alltrim(cComboBx1))
      MsgAlert("Tipo não informado para pesquisa.")
      Return .T.
   Endif

   If Empty(Alltrim(cComboBx2))
      MsgAlert("Filial não informada para pesquisa.")
      Return .T.
   Endif

   Do Case
      Case Alltrim(cComboBx1) == "Oportunidade"
           PESQ_OPORTUNIDADE( cCodigo, cComboBx1, cComboBx2 )
      Case Alltrim(cComboBx1) == "Proposta Comercial"
           PESQ_OPORTUNIDADE( cCodigo, cComboBx1, cComboBx2 )
      Case Alltrim(cComboBx1) == "Orçamento"
           PESQ_OPORTUNIDADE( cCodigo, cComboBx1, cComboBx2 )
      Case Alltrim(cComboBx1) == "Pedido de Venda"
           PESQ_PEDIDOVENDA( cCodigo, cComboBx1, cComboBx2 )
      Case Alltrim(cComboBx1) == "Nota Fiscal"
           PESQ_NOTAFISCAL( cCodigo, cComboBx1, cComboBx2 )
   EndCase        

Return .T.

// Função que pesquisa pela informação de Oportunidade, Proposta Comercial ou Orçamento
Static Function PESQ_OPORTUNIDADE( cCodigo, cComboBx1, cComboBx2 )

   // Pesquisa os Dados pela informação da Oportunidade, Proposta Comercial ou Orçamento
   If Select("T_RESUMO") > 0
      T_RESUMO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT AD1_NROPOR, "
   cSql += "       AD1_PROPOS, "
   cSql += "       AD1_NUMORC  "
   cSql += "  FROM " + RetSqlName("AD1010")

   Do Case
      Case Alltrim(cComboBx1) == "Oportunidade"
           cSql += " WHERE AD1_NROPOR = '" + Alltrim(cCodigo) + "'"
      Case Alltrim(cComboBx1) == "Proposta Comercial"
           cSql += " WHERE AD1_PROPOS = '" + Alltrim(cCodigo) + "'"
      Case Alltrim(cComboBx1) == "Orçamento"
           cSql += " WHERE AD1_NUMORC = '" + Alltrim(cCodigo) + "'"
   EndCase        
         
   cSql += "   AND AD1_FILIAL = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND R_E_C_D_E_L_ = '' "  
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )

   If T_RESUMO->( Eof() )
         
      Do Case
         Case Alltrim(cComboBx1) == "Oportunidade"
              MsgAlert("Não existem dados a serem visualizados para esta Oportunidade.")
         Case Alltrim(cComboBx1) == "Proposta Comercial"
              MsgAlert("Não existem dados a serem visualizados para esta Proposta Comercial.")
         Case Alltrim(cComboBx1) == "Orçamento"
              MsgAlert("Não existem dados a serem visualizados para este Orçamento.")
      EndCase        

      Return .T.
         
   Else

      cOportunidade := T_RESUMO->AD1_NROPOR
      cProposta     := T_RESUMO->AD1_PROPOS
      cOrcamento    := T_RESUMO->AD1_NUMORC

      // Se código do orçamento <> de branco, pesquisa cliente e vendedores do Orçamento para display
      If !Empty(Alltrim(T_RESUMO->AD1_NUMORC))

         If Select("T_DEMAIS") > 0
            T_DEMAIS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.CJ_NUM    , "
         cSql += "       A.CJ_CLIENTE, "
         cSql += "       A.CJ_LOJA   , "
         cSql += "       A.CJ_VEND1  , "
         cSql += "       A.CJ_VEND2  , "
         cSql += "       B.A1_NOME   , "
         cSql += "       A.CJ_CONDPAG, "
         cSql += "       C.E4_DESCRI   "
         cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
         cSql += "       " + RetSqlName("SA1010") + " B, "
         cSql += "       " + RetSqlName("SE4010") + " C  "
         cSql += " WHERE A.CJ_NUM     = '" + Alltrim(T_RESUMO->AD1_NUMORC)    + "'"
         cSql += "   AND A.CJ_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
         cSql += "   AND A.CJ_CONDPAG = C.E4_CODIGO "
         cSql += "   AND A.CJ_CLIENTE = B.A1_COD    "
         cSql += "   AND A.CJ_LOJA    = B.A1_LOJA   "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEMAIS", .T., .T. )

         If !T_DEMAIS->( Eof() )

            cNomeCliente  := T_DEMAIS->A1_NOME
            cNomeCondicao := T_DEMAIS->E4_DESCRI

            If Empty(Alltrim(cNomeCliente))
               MsgAlert("Não existem dados a serem visualizados.")
               Return .T.
            Endif

            // Pesquisa o vendedor 1 se preenchido
            If !Empty(T_DEMAIS->CJ_VEND1)

               If Select("T_COMISSAO") > 0
                  T_COMISSAO->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT A3_NOME "
               cSql += "  FROM " + RetSqlName("SA3010")
               cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND1) + "'"
              
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

               If !T_COMISSAO->( Eof() )
                  cNomeV01 := T_COMISSAO->A3_NOME
               Endif   
                                 
            Endif
               
            // Pesquisa o vendedor 2 se preenchido
            If !Empty(T_DEMAIS->CJ_VEND2)

               If Select("T_COMISSAO1") > 0
                  T_COMISSAO1->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT A3_NOME "
               cSql += "  FROM " + RetSqlName("SA3010")
               cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND2) + "'"
               
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO1", .T., .T. )

               If !T_COMISSAO1->( Eof() )
                  cNomeV02 := T_COMISSAO->A3_NOME
               Endif   
                                 
            Endif
            
         Endif   
            
      Endif

      // Pesquisa o Nº do Pedido de Venda
      If Select("T_PEDIDO") > 0
         T_PEDIDO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT C6_NUM  , "
      cSql += "       C6_NOTA , " 
      cSql += "       C6_NUMOP  "
      cSql += "  FROM " + RetSqlName("SC6010")
//    cSql += " WHERE LEFT(C6_NUMORC,6) = '" + Alltrim(T_DEMAIS->CJ_NUM)        + "'"
      cSql += " WHERE LEFT(C6_NUMORC,6) = '" + Alltrim(T_RESUMO->AD1_NUMORC)    + "'"
      cSql += "   AND C6_FILIAL         = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
      cSql += "   AND R_E_C_D_E_L_      = ''  "
      cSql += " GROUP BY C6_NUM, C6_NOTA, C6_NUMOP "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

      If !T_PEDIDO->( Eof() )

         cPedido   := T_PEDIDO->C6_NUM
         cProducao := T_PEDIDO->C6_NUMOP 

         // Pesquisa o nº das notas fiscais para display
         cNFiscal := ""

         T_PEDIDO->( DbGoTop() )

         While !T_PEDIDO->( EOF() )
            If !Empty(aLLTRIM(T_PEDIDO->C6_NOTA))
               cNFiscal := cNFiscal + Alltrim(T_PEDIDO->C6_NOTA) + "/"
            Endif
            T_PEDIDO->( DbSkip() )
         Enddo
            
         If !Empty(Alltrim(cNFiscal))
            cNFiscal := Substr(cNFiscal,01, Len(Alltrim(cNFiscal)) - 1)
         Endif
                                 
         cNota := cNFiscal

      Endif

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
      cSql += "       A.C6_NOTA    " + chr(13)
      cSql += "  FROM " + RetSqlName("SC6010") + " A, " + chr(13)
      cSql += "       " + RetSqlName("SB1010") + " B  " + chr(13)
//    cSql += " WHERE LEFT(C6_NUMORC,6) = '" + Alltrim(T_DEMAIS->CJ_NUM)        + "'"
      cSql += " WHERE A.C6_NUM          = '" + Alltrim(cPedido)        + "'" + chr(13)
      cSql += "   AND A.C6_FILIAL       = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"  + chr(13)
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
        	                 SUBSTR(T_PRODUTOS->C6_NOTA,01,10) } )
            T_PRODUTOS->( DbSkip() )
               
         Enddo

         oBrowse := TSBrowse():New(180,005,324,070,oDlg,,1,,1)
         oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Nº NF',,,{|| },{|| }) )
         oBrowse:SetArray(aBrowse)
            
      Endif      

   Endif
      
Return .T.

// Função que pesquisa pela informação do nº do Pedido de Venda
Static Function PESQ_PEDIDOVENDA( cCodigo, cComboBx1, cComboBx2 )

   Local cSql     := ""
   Local cNFiscal := ""
   Local cLink    := ""

   // Pesquisa o Nº do Pedido de Venda
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C6_NUM  , "
   cSql += "       A.C6_NOTA , " 
   cSql += "       A.C6_NUMOP, "
   cSql += "       B.A1_NOME , "
   cSql += "       A.C6_NUMORC "
   cSql += "  FROM " + RetSqlName("SC6010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B  "
   cSql += " WHERE A.C6_NUM       = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND A.C6_FILIAL    = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
   cSql += "   AND A.R_E_C_D_E_L_ = ''       "
   cSql += "   AND A.C6_CLI       = B.A1_COD "
   cSql += "   AND A.C6_LOJA      = B.A1_LOJA"
   cSql += " GROUP BY A.C6_NUM, A.C6_NOTA, A.C6_NUMOP, B.A1_NOME, A.C6_NUMORC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( Eof() )
   
      MsgAlert("Não existem dados a serem visualizados para este Pedido de venda.")
      
   Else

      cPedido      := T_PEDIDO->C6_NUM
      cProducao    := T_PEDIDO->C6_NUMOP 
      cNomeCliente := T_PEDIDO->A1_NOME
      cLink        := Substr(T_PEDIDO->C6_NUMORC,01,06)
      
      // Pesquisa o nº das notas fiscais para display
      cNFiscal := ""

      T_PEDIDO->( DbGoTop() )

      While !T_PEDIDO->( EOF() )
         If !Empty(aLLTRIM(T_PEDIDO->C6_NOTA))
            cNFiscal := cNFiscal + Alltrim(T_PEDIDO->C6_NOTA) + "/"
         Endif
         T_PEDIDO->( DbSkip() )
      Enddo
            
      If !Empty(Alltrim(cNFiscal))
         cNFiscal := Substr(cNFiscal,01, Len(Alltrim(cNFiscal)) - 1)
      Endif
                              
      cNota := cNFiscal

      // Pesquisa os nº da Oportunidade, Proposta Comercial e Orçamento
      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""   
      cSql := "SELECT AD1_NROPOR, "
      cSql += "       AD1_PROPOS, "
      cSql += "       AD1_NUMORC  "
      cSql += "  FROM " + RetSqlName("AD1010")
      cSql += " WHERE AD1_NUMORC = '" + Alltrim(cLink)                   + "'"
      cSql += "   AND AD1_FILIAL = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "   AND R_E_C_D_E_L_ = '' "  
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )

      If !T_RESUMO->( Eof() )

         cOportunidade := T_RESUMO->AD1_NROPOR
         cProposta     := T_RESUMO->AD1_PROPOS
         cOrcamento    := T_RESUMO->AD1_NUMORC

         // Se código do orçamento <> de branco, pesquisa cliente e vendedores do Orçamento para display
         If !Empty(Alltrim(T_RESUMO->AD1_NUMORC))

            If Select("T_DEMAIS") > 0
               T_DEMAIS->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.CJ_NUM    , "
            cSql += "       A.CJ_CLIENTE, "
            cSql += "       A.CJ_LOJA   , "
            cSql += "       A.CJ_VEND1  , "
            cSql += "       A.CJ_VEND2  , "
            cSql += "       B.A1_NOME   , "
            cSql += "       A.CJ_CONDPAG, "
            cSql += "       C.E4_DESCRI   "
            cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
            cSql += "       " + RetSqlName("SA1010") + " B, "
            cSql += "       " + RetSqlName("SE4010") + " C  "
            cSql += " WHERE A.CJ_NUM     = '" + Alltrim(T_RESUMO->AD1_NUMORC)    + "'"
            cSql += "   AND A.CJ_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
            cSql += "   AND A.CJ_CONDPAG = C.E4_CODIGO "
            cSql += "   AND A.CJ_CLIENTE = B.A1_COD    "
            cSql += "   AND A.CJ_LOJA    = B.A1_LOJA   "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEMAIS", .T., .T. )

            If !T_DEMAIS->( Eof() )
               cNomeCliente := T_DEMAIS->A1_NOME
            Endif

            cNomeCondicao := T_DEMAIS->E4_DESCRI

            // Pesquisa o vendedor 1 se preenchido
            If !Empty(T_DEMAIS->CJ_VEND1)

               If Select("T_COMISSAO") > 0
                  T_COMISSAO->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT A3_NOME "
               cSql += "  FROM " + RetSqlName("SA3010")
               cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND1) + "'"
              
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

               If !T_COMISSAO->( Eof() )
                  cNomeV01 := T_COMISSAO->A3_NOME
               Endif   
                                 
            Endif
               
            // Pesquisa o vendedor 2 se preenchido
            If !Empty(T_DEMAIS->CJ_VEND2)

               If Select("T_COMISSAO1") > 0
                  T_COMISSAO1->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT A3_NOME "
               cSql += "  FROM " + RetSqlName("SA3010")
               cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND2) + "'"
               
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO1", .T., .T. )

               If !T_COMISSAO1->( Eof() )
                  cNomeV02 := T_COMISSAO->A3_NOME
               Endif   
                                 
            Endif
            
         Endif   
      
         // Pesquisa os Produtos do Pedido de Venda para alimentar o Grid de Produtos da Tela.
         If Select("T_PRODUTOS") > 0
            T_PRODUTOS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.C6_PRODUTO,"
         cSql += "       B.B1_DESC   ,"
         cSql += "       B.B1_DAUX   ,"
         cSql += "       A.C6_QTDVEN ,"
         cSql += "       A.C6_PRCVEN ,"
         cSql += "       A.C6_VALOR  ,"
         cSql += "       A.C6_NOTA   ,"
         cSql += "       A.C6_NUMOP   "
         cSql += "  FROM " + RetSqlName("SC6010") + " A, "
         cSql += "       " + RetSqlName("SB1010") + " B  "
//       cSql += " WHERE A.C6_NUM       = '" + Alltrim(cCodigo) + "'"
         cSql += " WHERE A.C6_NUM          = '" + Alltrim(cPedido)        + "'" + chr(13)
         cSql += "   AND A.C6_FILIAL    = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
         cSql += "   AND A.C6_PRODUTO   = B.B1_COD "
         cSql += "   AND A.R_E_C_D_E_L_ = ''       "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

         If !T_PRODUTOS->( Eof() )
            
            cProducao := T_PRODUTOS->C6_NUMOP

            While !T_PRODUTOS->( EOF() )

               aAdd( aBrowse, { Substr(T_PRODUTOS->C6_PRODUTO,01,06),;
        	                    T_PRODUTOS->B1_DESC                 ,;
        	                    STR(T_PRODUTOS->C6_QTDVEN,05)       ,;
        	                    STR(T_PRODUTOS->C6_PRCVEN,10,02)    ,;
        	                    STR(T_PRODUTOS->C6_VALOR,10,02)     ,;
        	                    SUBSTR(T_PRODUTOS->C6_NOTA,01,10) } )
               T_PRODUTOS->( DbSkip() )
               
            Enddo

            oBrowse := TSBrowse():New(180,005,324,070,oDlg,,1,,1)
            oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
            oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
            oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
            oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
            oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
            oBrowse:AddColumn( TCColumn():New('Nº NF',,,{|| },{|| }) )
            oBrowse:SetArray(aBrowse)
            
         Endif      

      Endif

   Endif
      
Return .T.

// Função que pesquisa pela informação da Nota Fiscal
Static Function PESQ_NOTAFISCAL( cCodigo, cComboBx1, cComboBx2 )

   Local cSql  := ""
   Local cLink := ""

   // Pesquisa o Nº do Pedido de Venda
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C6_NUM   , "
   cSql += "       A.C6_FILIAL, "
   cSql += "       A.C6_NOTA  , " 
   cSql += "       A.C6_NUMOP , "
   cSql += "       A.C6_NUMORC, "
   cSql += "       A.C6_CLI   , "
   cSql += "       A.C6_LOJA  , "
   cSql += "       B.A1_NOME    "
   cSql += "  FROM " + RetSqlName("SC6010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B  "
   cSql += " WHERE A.C6_NOTA      = '" + Alltrim(cCodigo)                 + "'"
   cSql += "   AND A.C6_FILIAL    = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
   cSql += "   AND A.C6_SERIE     = '" + Alltrim(cComboBx3)               + "'" 
   cSql += "   AND A.R_E_C_D_E_L_ = ''  "
   cSql += "   AND A.C6_CLI       = B.A1_COD  "
   cSql += "   AND A.C6_LOJA      = B.A1_LOJA "
   cSql += " GROUP BY A.C6_NUM, A.C6_FILIAL, A.C6_NOTA, A.C6_NUMOP, A.C6_NUMORC , A.C6_CLI, A.C6_LOJA, B.A1_NOME

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( Eof() )
      MsgAlert("Não existem dados a serem pesquisados para este nº de Nota Fiscal.")
      Return .T.
   Endif

   cPedido   := T_PEDIDO->C6_NUM
   cProducao := T_PEDIDO->C6_NUMOP 
   cNota     := T_PEDIDO->C6_NOTA
   cLink     := Substr(T_PEDIDO->C6_NUMORC,01,06)

   // Pesquisa os Dados da Oportunidade, Proposta Comercial e Orçamento
   If Empty(Alltrim(cLink))
      
      cNomeCliente  := T_PEDIDO->A1_NOME

      // Pesquisa o Nº do Pedido de Venda
      If Select("T_RESTO") > 0
         T_RESTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.C5_CONDPAG," 
      cSql += "       A.C5_TRANSP ,"
      cSql += "       A.C5_VEND1  ,"
      cSql += "       D.A3_NOME   ,"
      cSql += "       A.C5_VEND2  ,"
      cSql += "       B.E4_DESCRI ,"
      cSql += "       C.A4_NOME    "
      cSql += "  FROM " + RetSqlName("SC5") + " A, "
      cSql += "       " + RetSqlName("SE4") + " B, "
      cSql += "       " + RetSqlName("SA4") + " C, "
      cSql += "       " + RetSqlName("SA3") + " D  "
      cSql += " WHERE A.C5_NUM     = '" + Alltrim(T_PEDIDO->C6_NUM)    + "'"
      cSql += "   AND A.C5_FILIAL  = '" + Alltrim(T_PEDIDO->C6_FILIAL) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
      cSql += "   AND A.C5_CONDPAG = B.E4_CODIGO"
      cSql += "   AND A.C5_TRANSP  = C.A4_COD   "
      cSql += "   AND A.C5_VEND1   = D.A3_COD   "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESTO", .T., .T. )

      If T_RESTO->( EOF() )
         cNomeCondicao := ""
         cNomeV01      := ""
      Else
         cNomeCondicao := T_RESTO->E4_DESCRI
         cNomeV01      := T_RESTO->A3_NOME
      Endif

      If !Empty(Alltrim(T_RESTO->C5_VEND2))
      
         If Select("T_VENDEDOR") > 0
            T_VENDEDOR->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A3_NOME "
         cSql += "  FROM " + RetSqlName("SA3010")
         cSql += " WHERE A3_COD = '" + Alltrim(T_RESTO->C5_VEND2) + "'"
              
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

         If T_VENDEDOR->( EOF() )
            cNomeV02 := ""
         Else
            cNomeV02 := T_VENDEDOR->A3_NOME      
         Endif   
      Endif

      // Pesquisa os Produtos do Pedido de Venda para alimentar o Grid de Produtos da Tela.
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.C6_PRODUTO,"
      cSql += "       B.B1_DESC   ,"
      cSql += "       B.B1_DAUX   ,"
      cSql += "       A.C6_QTDVEN ,"
      cSql += "       A.C6_PRCVEN ,"
      cSql += "       A.C6_VALOR  ,"
      cSql += "       A.C6_NOTA    "
      cSql += "  FROM " + RetSqlName("SC6010") + " A, "
      cSql += "       " + RetSqlName("SB1010") + " B  "
      cSql += " WHERE A.C6_FILIAL       = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
      cSql += "   AND A.C6_NOTA         = '" + Alltrim(cCodigo)                 + "'"
      cSql += "   AND A.C6_SERIE        = '" + Alltrim(cComboBx3)               + "'" 
      cSql += "   AND A.C6_PRODUTO      = B.B1_COD "
      cSql += "   AND A.R_E_C_D_E_L_    = ''       "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      If !T_PRODUTOS->( Eof() )
            
         aBrowse := {}

         While !T_PRODUTOS->( EOF() )

     	    aAdd( aBrowse, { Substr(T_PRODUTOS->C6_PRODUTO,01,06),;
        	                 T_PRODUTOS->B1_DESC                 ,;
        	                 STR(T_PRODUTOS->C6_QTDVEN,05)       ,;
        	                 STR(T_PRODUTOS->C6_PRCVEN,10,02)    ,;
        	                 STR(T_PRODUTOS->C6_VALOR,10,02)     ,;
        	                 SUBSTR(T_PRODUTOS->C6_NOTA,01,10) } )
            T_PRODUTOS->( DbSkip() )
               
         Enddo

         oBrowse := TSBrowse():New(180,005,324,070,oDlg,,1,,1)
         oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Nº NF',,,{|| },{|| }) )
         oBrowse:SetArray(aBrowse)
            
      Endif      

   Else

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""   
      cSql := "SELECT AD1_NROPOR, "
      cSql += "       AD1_PROPOS, "
      cSql += "       AD1_NUMORC  "
      cSql += "  FROM " + RetSqlName("AD1010")
      cSql += " WHERE AD1_NUMORC = '" + Alltrim(cLInk) + "'"
      cSql += "   AND AD1_FILIAL = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      cSql += "   AND R_E_C_D_E_L_ = '' "  
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )

      If !T_RESUMO->( Eof() )

         cOportunidade := T_RESUMO->AD1_NROPOR
         cProposta     := T_RESUMO->AD1_PROPOS
         cOrcamento    := T_RESUMO->AD1_NUMORC

         // Se código do orçamento <> de branco, pesquisa cliente e vendedores do Orçamento para display
         If !Empty(Alltrim(T_RESUMO->AD1_NUMORC))

            If Select("T_DEMAIS") > 0
               T_DEMAIS->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT A.CJ_NUM    , "
            cSql += "       A.CJ_CLIENTE, "
            cSql += "       A.CJ_LOJA   , "
            cSql += "       A.CJ_VEND1  , "
            cSql += "       A.CJ_VEND2  , "
            cSql += "       B.A1_NOME   , "
            cSql += "       A.CJ_CONDPAG, "
            cSql += "       C.E4_DESCRI   "
            cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
            cSql += "       " + RetSqlName("SA1010") + " B, "
            cSql += "       " + RetSqlName("SE4010") + " C  "
            cSql += " WHERE A.CJ_NUM     = '" + Alltrim(T_RESUMO->AD1_NUMORC)    + "'"
            cSql += "   AND A.CJ_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
            cSql += "   AND A.CJ_CONDPAG = C.E4_CODIGO "
            cSql += "   AND A.CJ_CLIENTE = B.A1_COD    "
            cSql += "   AND A.CJ_LOJA    = B.A1_LOJA   "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEMAIS", .T., .T. )

            If !T_DEMAIS->( Eof() )

               cNomeCliente  := T_DEMAIS->A1_NOME
               cNomeCondicao := T_DEMAIS->E4_DESCRI

               // Pesquisa o vendedor 1 se preenchido
               If !Empty(T_DEMAIS->CJ_VEND1)

                  If Select("T_COMISSAO") > 0
                     T_COMISSAO->( dbCloseArea() )
                  EndIf

                  cSql := ""
                  cSql := "SELECT A3_NOME "
                  cSql += "  FROM " + RetSqlName("SA3010")
                  cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND1) + "'"
              
                  cSql := ChangeQuery( cSql )
                  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

                  If !T_COMISSAO->( Eof() )
                     cNomeV01 := T_COMISSAO->A3_NOME
                  Endif   
                                 
               Endif
               
               // Pesquisa o vendedor 2 se preenchido
               If !Empty(T_DEMAIS->CJ_VEND2)

                  If Select("T_COMISSAO1") > 0
                     T_COMISSAO1->( dbCloseArea() )
                  EndIf

                  cSql := ""
                  cSql := "SELECT A3_NOME "
                  cSql += "  FROM " + RetSqlName("SA3010")
                  cSql += " WHERE A3_COD = '" + Alltrim(T_DEMAIS->CJ_VEND2) + "'"
               
                  cSql := ChangeQuery( cSql )
                  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO1", .T., .T. )

                  If !T_COMISSAO1->( Eof() )
                     cNomeV02 := T_COMISSAO->A3_NOME
                  Endif   
                                 
               Endif
            
            Endif   
            
         Endif
         
      Endif
      
      // Pesquisa os Produtos do Pedido de Venda para alimentar o Grid de Produtos da Tela.
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.C6_PRODUTO,"
      cSql += "       B.B1_DESC   ,"
      cSql += "       B.B1_DAUX   ,"
      cSql += "       A.C6_QTDVEN ,"
      cSql += "       A.C6_PRCVEN ,"
      cSql += "       A.C6_VALOR  ,"
      cSql += "       A.C6_NOTA    "
      cSql += "  FROM " + RetSqlName("SC6010") + " A, "
      cSql += "       " + RetSqlName("SB1010") + " B  "
      cSql += " WHERE LEFT(C6_NUMORC,6) = '" + Alltrim(T_RESUMO->AD1_NUMORC)    + "'"
      cSql += "   AND A.C6_FILIAL       = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" 
      cSql += "   AND A.C6_NOTA         = '" + Alltrim(cCodigo)                 + "'"
      cSql += "   AND A.C6_SERIE        = '" + Alltrim(cComboBx3)               + "'" 
      cSql += "   AND A.C6_PRODUTO      = B.B1_COD "
      cSql += "   AND A.R_E_C_D_E_L_    = ''       "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      If !T_PRODUTOS->( Eof() )
            
         aBrowse := {}

         While !T_PRODUTOS->( EOF() )

     	    aAdd( aBrowse, { Substr(T_PRODUTOS->C6_PRODUTO,01,06),;
        	                 T_PRODUTOS->B1_DESC                 ,;
        	                 STR(T_PRODUTOS->C6_QTDVEN,05)       ,;
        	                 STR(T_PRODUTOS->C6_PRCVEN,10,02)    ,;
        	                 STR(T_PRODUTOS->C6_VALOR,10,02)     ,;
        	                 SUBSTR(T_PRODUTOS->C6_NOTA,01,10) } )
            T_PRODUTOS->( DbSkip() )
               
         Enddo

         oBrowse := TSBrowse():New(180,005,324,070,oDlg,,1,,1)
         oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Quantidade',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Unitário',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Total',,,{|| },{|| }) )
         oBrowse:AddColumn( TCColumn():New('Nº NF',,,{|| },{|| }) )
         oBrowse:SetArray(aBrowse)
            
      Endif      
     
   Endif
      
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
 
// Função que abre a tela de seleção da nota fiscal de pesquisa pela pesquisa por nº de série
Static Function NFSERIE( _Serie )

   Local lChumba     := .F.
   Local cSql        := ""
   Local cGet1       := _Serie
   Local oGet1

   Private aConsulta := {}

   Private oDlgSSS

   // Pesquisa as notas fiscais em que o nº de série teve movimentação de saída (Venda)
   If Select("T_SERIE") > 0
      T_SERIE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.DB_FILIAL, "
   cSql += "       A.DB_DOC   , "
   cSql += "       A.DB_SERIE , "
   cSql += "       A.DB_DATA  , "
   cSql += "       A.DB_CLIFOR, "
   cSql += "       A.DB_LOJA  , "
   cSql += "       B.A1_NOME    "
   cSql += "  FROM " + RetSqlName("SDB") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.DB_NUMSERI = '" + Alltrim(_serie) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''  "
   cSql += "   AND A.DB_ESTORNO = ''  "
   cSql += "   AND A.DB_ORIGEM = 'SC6'"
   cSql += "   AND A.DB_CLIFOR = B.A1_COD"
   cSql += "   AND B.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

   If T_SERIE->( EOF() )
      aAdd(aConsulta, { '','','','','','','' } )
   Else
      T_SERIE->( DbGoTop() )
      WHILE !T_SERIE->( EOF() )
         aAdd( aConsulta, { T_SERIE->DB_FILIAL, ;
                            T_SERIE->DB_DOC   , ;
                            T_SERIE->DB_SERIE , ;
                            T_SERIE->DB_DATA  , ;
                            T_SERIE->DB_CLIFOR, ;
                            T_SERIE->DB_LOJA  , ;
                            T_SERIE->A1_NOME } )
         T_SERIE->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgSSS TITLE "Tracker p/Nº de Série" FROM C(178),C(181) TO C(401),C(717) PIXEL

   @ C(010),C(089) Say "Nº de Série"                           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgSSS
   @ C(021),C(004) Say "Selecione a Nota Fiscal para Pesquisa" Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlgSSS

   @ C(009),C(119) MsGet oGet1 Var cGet1 When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSSS

   @ C(094),C(186) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgSSS ACTION( SAIRSSS( aConsulta[oConsulta:nAt,01], aConsulta[oConsulta:nAt,02], aConsulta[oConsulta:nAt,03] ) )
   @ C(094),C(225) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgSSS ACTION( oDlgSSS:End() )

   // Desenha o Browse
   oConsulta := TCBrowse():New( 035 , 004, 335, 082,,{'FL', 'N.Fiscal', 'Série', 'Data', 'Cliente', 'Loja', 'Descrição dos Clientes' },{20,50,50,50},oDlgSSS,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta) 
    
   // Monta a linha a ser exibina no Browse
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01],;
                           aConsulta[oConsulta:nAt,02],;
                           aConsulta[oConsulta:nAt,03],;
                           aConsulta[oConsulta:nAt,04],;
                           aConsulta[oConsulta:nAt,05],;
                           aConsulta[oConsulta:nAt,06],;
                           aConsulta[oConsulta:nAt,07]} }

   ACTIVATE MSDIALOG oDlgSSS CENTERED 

Return .T.

// Função que carrega os dados a serem pesquisados para o tipoNº de Série e fecha a janela de pesquisa de notas fiscais
Static Function SAIRSSS( _Filial, _Nota, _Serie )

   xFilial := _Filial
   xNota   := _Nota
   xSerie  := _Serie
   
   oDlgSSS:End() 
   
Return .t.