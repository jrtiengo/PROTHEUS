#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM179.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 05/08/2013                                                           *
// Objetivo..: Pesquisa Customizada de Produtos                                     *
//***********************************************************************************

User Function AUTOM179()

   Local lChumba      := .F.
   Local lTem500      := .F.
   Local cTabela      := ""

   Private cCampo     := ReadVar()
   Private cPesquisa  := Space(40)

   Private oGet1

   Private aComboBx1  := {"1 - Código","2 - Descrição", "3 - Part Number", "4 - NCM"}
   Private aComboBx2  := {"1 - Código","2 - Descrição", "3 - Part Number", "4 - NCM"}
   Private aComboBx3  := {"1 - Igual" ,"2 - Iniciando", "3 - Contendo"}
   Private aComboBx4  := {""}
   Private aComboBx5  := {"1 - Todos" ,"2 - Estoque", "4 - Est. + Liquidação", "5 - Est. + Promo", "8 - Est.s/Giro"}

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
// Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
// Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private aBrowse := {}

   Private oDlg

// U_AUTOM628("AUTOM179")

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
   cComboBx5 := "1 - Todos"
   
   If lTem500 == .T.
      cComboBx4 := cTabela
   Endif   

   // Envia apara a função que carrega o grid na entrada da tela
// xbuscapro(1)
           
   DEFINE MSDIALOG oDlg TITLE "Pesquisa de Produtos" FROM C(178),C(181) TO C(596),C(958) PIXEL

   @ C(010),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(051) PIXEL NOBORDER OF oDlg

   @ C(037),C(060) Say "CONSULTA CADASTRO DE PRODUTOS" Size C(103),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(174) Say "String Pesquisa"               Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(017),C(174) Say "Pesquisar por"                 Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(174) Say "Ordenar por"                   Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(174) Say "Tabela Preço"                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(003),C(216) MsGet oGet1 Var cPesquisa Size C(110),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(001),C(330) Button "Pesquisar" Size C(053),C(012) PIXEL OF oDlg ACTION(xbuscapro(2))
   
   @ C(016),C(216) ComboBox cComboBx1 Items aComboBx1 Size C(063),C(010) PIXEL OF oDlg
   @ C(016),C(282) ComboBox cComboBx3 Items aComboBx3 Size C(045),C(010) PIXEL OF oDlg
   @ C(016),C(330) ComboBox cComboBx5 Items aComboBx5 Size C(053),C(010) PIXEL OF oDlg
   @ C(028),C(216) ComboBox cComboBx2 Items aComboBx2 Size C(166),C(010) PIXEL OF oDlg
   @ C(039),C(216) ComboBox cComboBx4 Items aComboBx4 Size C(166),C(010) PIXEL OF oDlg

   @ C(193),C(005) Button "Visualizar Cadastro" Size C(053),C(012) PIXEL OF oDlg ACTION(xCadProd(aBrowse[oBrowse:nAt,02]))
   @ C(193),C(059) Button "Visualizar Saldos"   Size C(053),C(012) PIXEL OF oDlg ACTION(xSaldoProd(aBrowse[oBrowse:nAt,02]))

   @ C(193),C(113) Button "Saldos Consolidado"  Size C(053),C(012) PIXEL OF oDlg ACTION(U_AUTOM291(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,04]))

   @ C(193),C(171) Button "Cta Contábil"        Size C(037),C(012) PIXEL OF oDlg ACTION(MostraCtaConta(aBrowse[oBrowse:nAt,02]))
   @ C(193),C(209) Button "Regras"              Size C(037),C(012) PIXEL OF oDlg ACTION(xRegrasNeg())
   @ C(193),C(251) Button "Legenda"             Size C(037),C(012) PIXEL OF oDlg ACTION(xLegendaPq())

   @ C(193),C(293) Button "Selecionar"          Size C(044),C(012) PIXEL OF oDlg ACTION(xSeleciona(aBrowse[oBrowse:nAt,02]))
   @ C(193),C(345) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 065 , 006, 483, 178,,{'','Codigo', 'Part Number', 'Descrição dos Produtos', 'NCM', 'Moeda', 'Preço Unit.', 'Qtd.Et.Rolo'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   If Len(aBrowse) == 0
      aAdd( aBrowse, { '1', '', '', '', '', '', '','' } )
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
                         aBrowse[oBrowse:nAt,05]               ,;
                         aBrowse[oBrowse:nAt,06]               ,;
                         aBrowse[oBrowse:nAt,07]               ,;
                         aBrowse[oBrowse:nAt,08]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return .T.

// Função que fecha a janela pelo botão selecionar
Static Function xSeleciona(_Produto)

   Local nPosCod := 0

   aAdd( aCpoRet, '0' )

   // Posiciona no produto selecionado
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)
   
   &cCampo     := _Produto
   aCpoRet[1]  := _Produto

   Do Case

      // ##################
      // Pedido de Venda ##
      // ##################
      Case FunName() == "MATA410" .OR. FunName() == "AUTOM587"
           nPosCod := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
           aCols[n,nPosCod] := _Produto

      // #######################
      // Documento de Entrada ##
      // #######################
      Case FunName() == "MATA103"
           nPosCod := aScan( aHeader, { |x| x[2] == 'D1_COD    ' } )
           aCols[n,nPosCod] := _Produto

      // ###################
      // Pedido de Compra ##
      // ###################
      Case FunName() == "MATA121"
           nPosCod := aScan( aHeader, { |x| x[2] == 'C7_PRODUTO' } )
           aCols[n,nPosCod] := _Produto

   EndCase           

   oDlg:End()                                        
   
Return(aCpoRet[1])

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
Static Function xbuscapro(_Tipo)

   MsgRun("Aguarde! Pesquisando produtos conforme parâmetros ...", "Pesquisa de Produtos",{|| kbuscapro(_Tipo) })

Return(.T.)

// Função que pesquisa o produto a medida que o usuário vai digitando
Static Function kbuscapro(_Tipo)

   Local cSql   := ""
   Local nCor   := ""
   Local nDias  := 0

   Local cGramat := ''
   Local nMetr   := 0
   Local nRolos  := 0

   aArea := GetArea()
   
   aBrowse := {}

//   If _Tipo == 2
//      If Len(Alltrim(cPesquisa)) == 0
//         aAdd( aBrowse, { '1', '', '', '', '', '', '' } )
//         oBrowse:SetArray(aBrowse) 
//         Return .T.
//      Endif   
//   Endif

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
   cSql += "       A.B1_MPCLAS," + CHR(13)
   cSql += "       A.B1_UCOM AS DT_ENTRADA," + CHR(13)
   cSql += "      (" + CHR(13)
   cSql += "       SELECT DISTINCT DA1_PROMO" + CHR(13)
   cSql += "         FROM " + RetSqlName("DA1")  + CHR(13)
   cSql += "        WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx4,01,03)) + "'" + CHR(13)
   cSql += "          AND DA1_CODPRO = A.B1_COD" + CHR(13)
   cSql += "          AND D_E_L_E_T_ = ''" + CHR(13)
   cSql += "      ) AS PROMOCAO," + CHR(13)
   cSql += "  ISNULL((SELECT DISTINCT DA1_MOEDA" + CHR(13)
   cSql += "      FROM " + RetSqlName("DA1") + CHR(13)
   cSql += "     WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx4,01,03)) + "'" + CHR(13)
   cSql += "       AND DA1_CODPRO = A.B1_COD" + CHR(13)
   cSql += "       AND D_E_L_E_T_ = ''" + CHR(13)
   cSql += "   ), '') AS MOEDA," + CHR(13)
   cSql += "  ISNULL((SELECT DISTINCT DA1_PRCVEN" + CHR(13)
   cSql += "      FROM " + RetSqlName("DA1")
   cSql += "     WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx4,01,03)) + "'" + CHR(13)
   cSql += "       AND DA1_CODPRO = A.B1_COD"
   cSql += "       AND D_E_L_E_T_ = ''"
   cSql += "   ), 0) AS PRECO,"
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

   If _Tipo == 1
   
      cSql += " WHERE A.B1_MSBLQL <> '1'" + CHR(13)
      cSql += "   AND A.D_E_L_E_T_ = '' " + CHR(13)
   
   Else

      If Len(Alltrim(cPesquisa)) <> 0

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

      Else

         cSql += " WHERE A.B1_MSBLQL <> '1'" + CHR(13)
         cSql += "   AND A.D_E_L_E_T_ = '' " + CHR(13)

      Endif

   Endif   

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
      aAdd( aBrowse, { '1', '', '', '', '', '', '', '' } )
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
         If _Tipo == 1
            If nCor <> "4"
               T_PRODUTO->( DbSkip() )                       
               Loop
            Endif
         Else
            If Substr(cComboBx5,01,01) == "1"
            Else
               Do Case
                  Case Substr(cComboBx5,01,01) == "2"
                       If nCor <> "2"
                          T_PRODUTO->( DbSkip() )                       
                          Loop
                       Endif
                  Case Substr(cComboBx5,01,01) == "4"
                       If nCor <> "4"
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
         Endif   

         // ####################################################################################
         // Calcula a quantidade de rolos por etiquetas caso o produto selecionado é etiqueta ##
         // ####################################################################################
         If Len(Alltrim(T_PRODUTO->B1_COD)) > 6

            _aRet1   := U_CALCMETR(T_PRODUTO->B1_COD)

            // ###############################
            // 1 = Metragem Linear por rolo ##
            // 2 = Qtd Etoquetas por rolo   ##
            // 3= Tubete                    ##
            // ###############################
            cGramat := TABELA("ZP",T_PRODUTO->B1_MPCLAS,.F.)
            nMetr   := _aRet1[1]
            nEtqRol := _aRet1[2]
            nRolos  := nEtqRol
      
         Else

            nRolos  := 0

         Endif  

         // Carrega o Array aBrowse
         aAdd( aBrowse, { nCor                 , ;
                          T_PRODUTO->B1_COD    , ;
                          T_PRODUTO->B1_PARNUM , ;
                          Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX) + Space(40) ,;
                          Substr(T_PRODUTO->B1_POSIPI,01,04) + "." + Substr(T_PRODUTO->B1_POSIPI,05,02) + "." + Substr(T_PRODUTO->B1_POSIPI,07,02),;
                          T_PRODUTO->MOEDA ,;
                          T_PRODUTO->PRECO ,;
                          nRolos           })
         T_PRODUTO->( DbSkip() )
      ENDDO
   Endif

   If _Tipo == 1
      Return(.T.)
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
                         aBrowse[oBrowse:nAt,05]               ,;
                         aBrowse[oBrowse:nAt,06]               ,;
                         aBrowse[oBrowse:nAt,07]               ,;
                         aBrowse[oBrowse:nAt,08]               }}

   RestArea( aArea )

Return .T.

// Função que apresenta a janela de legendas de pesquisa de produtos
Static Function xLegendaPq()

   Local cSql  := ""
   Local nDias := 0

   Private oDlgLG

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

// Função que apresenta as regras de negociação
Static Function xRegrasNeg()

   Local cSql      := ""
   Local _Programa := ""
   Local _Arquivo  := ""

   U_AUTO214B()

   RETURN(.T.)

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

   If T_PARAMETROS->( EOF() )
      MsgAlert("Regras inexistentes para visualização.")
      Return(.T.)
   Endif

   _Programa := Alltrim(T_PARAMETROS->ZZ4_EPRG)
   _Arquivo  := Alltrim(T_PARAMETROS->ZZ4_EARQ)

   If !File(_Arquivo)
      MsgAlert("Arquivo de Regras de Negócio inexistente.")
      Return(.T.)
   Endif
      
   WinExec(_Programa + " " + _Arquivo)

Return(.T.)

// #####################################################################################
// Função que abre a tela para visualização do código contábil do produto selecionado ##
// #####################################################################################
Static Function MostraCtaConta(kProduto)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local kConta	    := Space(20)
   Local kDescricao := Space(40)

   Local oGet1
   Local oGet2

   Private oDlgCta

   kConta     := POSICIONE("SB1",1,XFILIAL("SB1") + kProduto, "B1_CONTA")
   kDescricao := POSICIONE("CT1",1,XFILIAL("CT1") + kConta  , "CT1_DESC01")

   DEFINE MSDIALOG oDlgCta TITLE "Nº Conta Contábil" FROM C(178),C(181) TO C(395),C(486) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgCta

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(146),C(001) PIXEL OF oDlgCta
   @ C(084),C(002) GET oMemo2 Var cMemo2 MEMO Size C(146),C(001) PIXEL OF oDlgCta

   @ C(037),C(005) Say "Nº Conta Contábil"        Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgCta
   @ C(060),C(005) Say "Descrição Conta Contábil" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgCta

   @ C(047),C(005) MsGet oGet1 Var kConta     Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCta When lChumba
   @ C(069),C(005) MsGet oGet2 Var kDescricao Size C(145),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCta When lChumba

   @ C(091),C(056) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCta ACTION( oDlgCta:End() )

   ACTIVATE MSDIALOG oDlgCta CENTERED 

Return(.T.)