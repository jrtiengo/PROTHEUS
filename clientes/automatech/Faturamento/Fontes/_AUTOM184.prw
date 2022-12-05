#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM184.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 05/08/2013                                                           *
// Objetivo..: Pesquisa Customizada de Produtos sem bot]ao de selecção              *
//***********************************************************************************

User Function AUTOM184()

   Local lChumba      := .F.
   Local lTem500      := .F.
   Local cTabela      := ""

   Private cCampo     := ReadVar()
   Private cPesquisa  := Space(40)
   Private cCadastro  := ""

   Private oGet1

   Private aComboBx1  := {"1 - Código","2 - Descrição", "3 - Part Number", "4 - NCM"}
   Private aComboBx2  := {"1 - Código","2 - Descrição", "3 - Part Number", "4 - NCM"}
   Private aComboBx3  := {"1 - Igual" ,"2 - Iniciando", "3 - Contendo"}
   Private aComboBx4  := {}
   Private aComboBx5  := {"1 - Todos" ,"2 - Estoque", "5 - Est. + Promo", "8 - Est.s/Giro"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5

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

   Private aBrowse := {}

   Private oDlg

   // Carrega o combo de Tabela de Preços
   If Select("T_TABELA") > 0
      T_TABELA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA0_CODTAB,"
   cSql += "       DA0_DESCRI"
   cSql += "  FROM " + RetSqlName("DA0")
   cSql += " WHERE DA0_ATIVO  = '1'"  
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += " ORDER BY DA0_CODTAB   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

   lTem500 := .F.

   WHILE !T_TABELA->( EOF() )
      aAdd( aComboBx4, T_TABELA->DA0_CODTAB + " - " + T_TABELA->DA0_DESCRI )
      If T_TABELA->DA0_CODTAB == "500"
         lTem500 := .T.
         cTabela := T_TABELA->DA0_CODTAB + " - " + T_TABELA->DA0_DESCRI
      Endif
      T_TABELA->( DbSkip() )
   ENDDO

   cComboBx1 := "2 - Descrição"
   cComboBx2 := "2 - Descrição"
   cComboBx3 := "3 - Contendo"

   If lTem500 == .T.
      cComboBx4 := cTabela
   Endif   
           
   DEFINE MSDIALOG oDlg TITLE "Pesquisa de Produtos" FROM C(178),C(181) TO C(562),C(798) PIXEL

   @ C(005),C(199) Say "Pesquisar por" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(005) Say "Pesquisar por" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(016),C(199) Say "Ordenar por"   Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(199) Say "Filtrar por"   Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(199) Say "Tab. Preço"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(020),C(005) MsGet oGet1 Var cPesquisa Size C(145),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(018),C(155) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION(xbuscapro())

   @ C(003),C(228) ComboBox cComboBx1 Items aComboBx1 Size C(039),C(010) PIXEL OF oDlg
   @ C(003),C(268) ComboBox cComboBx5 Items aComboBx5 Size C(037),C(010) PIXEL OF oDlg
   @ C(015),C(228) ComboBox cComboBx2 Items aComboBx2 Size C(078),C(010) PIXEL OF oDlg
   @ C(027),C(228) ComboBox cComboBx3 Items aComboBx3 Size C(078),C(010) PIXEL OF oDlg
   @ C(039),C(228) ComboBox cComboBx4 Items aComboBx4 Size C(078),C(010) PIXEL OF oDlg

   @ C(176),C(005) Button "Visualizar Cadastro" Size C(053),C(012) PIXEL OF oDlg ACTION(xCadProd(aBrowse[oBrowse:nAt,02]))
   @ C(176),C(059) Button "Visualizar Saldos"   Size C(053),C(012) PIXEL OF oDlg ACTION(xSaldoProd(aBrowse[oBrowse:nAt,02]))
   @ C(176),C(160) Button "Legenda"             Size C(037),C(012) PIXEL OF oDlg ACTION(xLegendaPq())
// @ C(176),C(217) Button "Selecionar"          Size C(044),C(012) PIXEL OF oDlg 
   @ C(176),C(268) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 065 , 006, 385, 155,,{'','Codigo', 'Part Number', 'Descrição dos Produtos', 'NCM'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   aAdd( aBrowse, { '1', '', '', '', '' } )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return .T.

// Função que fecha a janela pelo botão selecionar
Static Function xSeleciona(_Produto)

   // Posiciona no produto selecionado
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)
   
   &cCampo     := _Produto
   aCpoRet[1]  := _Produto

   oDlg:End()
   
Return

// Função que pesquisa o saldo do produto selecionado
Static Function xSaldoProd(_Produto)

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return .T.

// Função que pesquisa o cadastro do produtoselecionado
Static Function xCadProd(_Produto)

   aArea := GetArea()
   
   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   AxVisual("SB1", SB1->( Recno() ), 2)

   RestArea( aArea )

Return .T.

// Função que pesquisa o produto a medida que o usuário vai digitando
Static Function xbuscapro()

   Local cSql   := ""
   Local nSaldo := 0
   Local nCor   := ""
   Local nDias  := 0

   aArea := GetArea()
   
   aBrowse := {}

   If Len(Alltrim(cPesquisa)) == 0
      aAdd( aBrowse, { '1', '', '', '', '' } )
      oBrowse:SetArray(aBrowse) 
      Return .T.
   Endif   

   // Pesquisa o Parâmetro de Dias para Leganda Vermelha
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_DIAS" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      nDias := 999
   Else   
      nDias := T_PARAMETROS->ZZ4_DIAS
   Endif

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.B1_COD   ," + CHR(13)
   cSql += "       A.B1_PARNUM," + CHR(13)
   cSql += "       A.B1_DESC  ," + CHR(13)
   cSql += "       A.B1_DAUX  ," + CHR(13)
   cSql += "       A.B1_POSIPI," + CHR(13)
   cSql += "       A.B1_UCOM AS DT_ENTRADA," + CHR(13)
   cSql += "      (" + CHR(13)
   cSql += "       SELECT DISTINCT DA1_PROMO" + CHR(13)
   cSql += "         FROM " + RetSqlName("DA1")  + CHR(13)
   cSql += "        WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx4,01,03)) + "'" + CHR(13)
   cSql += "          AND DA1_CODPRO = A.B1_COD" + CHR(13)
   cSql += "          AND D_E_L_E_T_ = ''" + CHR(13)
   cSql += "      ) AS PROMOCAO," + CHR(13)
   cSql += "      (" + CHR(13)
   cSql += "       SELECT SUM(B2_QATU)" + CHR(13)
   cSql += "         FROM " + RetSqlName("SB2")  + CHR(13)
   cSql += "        WHERE B2_COD     = A.B1_COD " + CHR(13)
   cSql += "          AND D_E_L_E_T_ = ''"  + CHR(13)
   cSql += "        GROUP BY B2_COD" + CHR(13)
   cSql += "      ) AS DISPONIVEL," + CHR(13)
   cSql += "      (" + CHR(13)
   cSql += "       SELECT B2_USAI" + CHR(13)
   cSql += "         FROM " + RetSqlName("SB2")  + CHR(13)
   cSql += "        WHERE B2_COD     = A.B1_COD " + CHR(13)
   cSql += "          AND D_E_L_E_T_ = ''" + CHR(13)
   cSql += "          AND B2_FILIAL  = '01'" + CHR(13)
   cSql += "          AND B2_LOCAL   = '01'" + CHR(13)
   cSql += "      ) AS DT_SAIDA"    + CHR(13)
   cSql += "  FROM " + RetSqlName("SB1") + " A " + CHR(13)

   Do Case
      Case Substr(cComboBx1,01,01) = "1" // Código
           Do Case
              Case Substr(cComboBx3,01,01) == "1" // Igual
                   cSql += " WHERE A.B1_COD = '" + Alltrim(cPesquisa) + "'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "2" // Iniciando
                   cSql += " WHERE A.B1_COD  LIKE '" + Alltrim(cPesquisa) + "%'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "3" // Contendo
                   cSql += " WHERE A.B1_COD  LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
           EndCase                   

      Case Substr(cComboBx1,01,01) = "2" // Descrição
           Do Case
              Case Substr(cComboBx3,01,01) == "1" // Igual
                   cSql += " WHERE A.B1_DESC = '" + Alltrim(cPesquisa) + "'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "2" // Iniciando
                   cSql += " WHERE A.B1_DESC LIKE '" + Alltrim(cPesquisa) + "%'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "3" // Contendo
                   cSql += " WHERE A.B1_DESC LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
           EndCase                   

      Case Substr(cComboBx1,01,01) = "3" // Part Number
           Do Case
              Case Substr(cComboBx3,01,01) == "1" // Igual
                   cSql += " WHERE A.B1_PARNUM = '" + Alltrim(cPesquisa) + "'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "2" // Iniciando
                   cSql += " WHERE A.B1_PARNUM LIKE '" + Alltrim(cPesquisa) + "%'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "3" // Contendo
                   cSql += " WHERE A.B1_PARNUM LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
           EndCase                   

      Case Substr(cComboBx1,01,01) = "4" // NCM
           Do Case
              Case Substr(cComboBx3,01,01) == "1" // Igual
                   cSql += " WHERE A.B1_POSIPI = '" + Alltrim(cPesquisa) + "'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "2" // Inicando
                   cSql += " WHERE A.B1_POSIPI LIKE '" + Alltrim(cPesquisa) + "%'" + CHR(13)
              Case Substr(cComboBx3,01,01) == "3" // Contendo
                   cSql += " WHERE A.B1_POSIPI LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
           EndCase                   

   EndCase

   cSql += " AND A.B1_MSBLQL <> '1'" + CHR(13)
   cSql += " AND A.D_E_L_E_T_ = '' " + CHR(13)

   // Ordenação
   Do Case
      Case Substr(cComboBx2,01,01) == "1" // Código
           cSql += " ORDER BY A.B1_COD" + CHR(13)
      Case Substr(cComboBx2,01,01) == "2" // Descrição
           cSql += " ORDER BY A.B1_DESC" + CHR(13)
      Case Substr(cComboBx2,01,01) == "3" // Part Number
           cSql += " ORDER BY A.B1_PARNUM" + CHR(13)
      Case Substr(cComboBx2,01,01) == "4" // NCM
           cSql += " ORDER BY A.B1_POSIPI" + CHR(13)
   EndCase                   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If T_PRODUTO->( EOF() )
      aAdd( aBrowse, { '1', '', '', '', '' } )
   Else
      T_PRODUTO->( DbGoTop() )
      WHILE !T_PRODUTO->( EOF() )

         If T_PRODUTO->DISPONIVEL = 0
            nCor   := '1'
         Else
            nCor   := '2'

            If T_PRODUTO->PROMOCAO == "P"
               nCor := '5'
            Endif

         Endif

         // Aplica a legenda Vermelha conforme parâmetro de Dias
         If T_PRODUTO->DISPONIVEL <> 0
 
            If T_PRODUTO->DT_ENTRADA = Nil
               ULTIMA_ENTRADA := Ctod("  /  /    ")
            Else   
               ULTIMA_ENTRADA := Ctod(Substr(T_PRODUTO->DT_ENTRADA,07,02) + "/" + ;
                                      Substr(T_PRODUTO->DT_ENTRADA,05,02) + "/" + ;
                                      Substr(T_PRODUTO->DT_ENTRADA,01,04))
            Endif
               
            If T_PRODUTO->DT_SAIDA = Nil
               ULTIMA_SAIDA := Ctod("  /  /    ")
            Else   
               ULTIMA_SAIDA := Ctod(Substr(T_PRODUTO->DT_SAIDA,07,02) + "/" + ;
                                    Substr(T_PRODUTO->DT_SAIDA,05,02) + "/" + ;
                                    Substr(T_PRODUTO->DT_SAIDA,01,04))
            Endif

            If EMPTY(ULTIMA_SAIDA) .And. EMPTY(ULTIMA_ENTRADA)
               nCor := '8'
            Else   
               If !EMPTY(ULTIMA_SAIDA)
                  If ULTIMA_SAIDA < (Date() - nDias)
                     nCor := '8'
                  Endif
               Else
                  If !EMPTY(ULTIMA_ENTRADA)
                     If ULTIMA_ENTRADA < (Date() - nDias)
                        nCor := '8'
                     Endif
                  Endif
               Endif
            Endif
         Endif

         If T_PRODUTO->PROMOCAO == "L"
            nCor := '4'
         Endif

         // Filtra pela Legenda
         If Substr(cComboBx5,01,01) == "1"
         Else
            Do Case
               Case Substr(cComboBx5,01,01) == "2"
                    If nCor <> "2"
                       T_PRODUTO->( DbSkip() )                       
                       Loop
                    Endif
               Case Substr(cComboBx5,01,01) == "5"
                    If nCor <> "5"
                       T_PRODUTO->( DbSkip() )                       
                       Loop
                    Endif
               Case Substr(cComboBx5,01,01) == "8"
                    If nCor <> "8"
                       T_PRODUTO->( DbSkip() )                       
                       Loop
                    Endif
            EndCase
         Endif    

         // Carrega o Array aBrowse
         aAdd( aBrowse, { nCor                 , ;
                          T_PRODUTO->B1_COD    , ;
                          T_PRODUTO->B1_PARNUM , ;
                          Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX) + Space(40) ,;
                          Substr(T_PRODUTO->B1_POSIPI,01,04) + "." + Substr(T_PRODUTO->B1_POSIPI,05,02) + "." + Substr(T_PRODUTO->B1_POSIPI,07,02) } )
         T_PRODUTO->( DbSkip() )
      ENDDO
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               } }

   RestArea( aArea )

Return .T.

// Função que apresenta a janela de legendas de pesquisa de produtos
Static Function xLegendaPq()

   Local cSql  := ""
   Local nDias := 0

   Private oDlgL

   // Pesquisa o Parâmetro de Dias para Leganda Vermelha
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_DIAS" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      nDias := 999
   Else   
      nDias := T_PARAMETROS->ZZ4_DIAS
   Endif

   DEFINE MSDIALOG oDlgLG TITLE "Legenda Pesquisa" FROM C(178),C(181) TO C(341),C(711) PIXEL

   @ C(005),C(018) Say "Outros"                                                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(017),C(018) Say "Produtos com estoque em toda a Companhia"                         Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(028),C(018) Say "Produtos com estoque em toda a Companhia e que estão em PROMOÇÂO" Size C(177),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(041),C(018) Say "Tem estoque disponivel para venda na Companhia e que não tem giro de estoque na Matriz a mais de " + Alltrim(Str(nDias)) + " dias." Size C(240),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(053),C(018) Say "Produtos em Liquidação"                                           Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
      
   @ C(003),C(003) Jpeg FILE "br_branco"   Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(015),C(003) Jpeg FILE "br_verde"    Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(027),C(003) Jpeg FILE "br_azul"     Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(039),C(003) Jpeg FILE "br_vermelho" Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(051),C(003) Jpeg FILE "br_amarelo"  Size C(010),C(011) PIXEL NOBORDER OF oDlgLG

   @ C(064),C(116) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLG ACTION( oDlgLG:End() )

   ACTIVATE MSDIALOG oDlgLG CENTERED 

Return(.T.)