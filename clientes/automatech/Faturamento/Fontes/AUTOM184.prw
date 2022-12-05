#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM184.PRW                                                         ##
// Par�metros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                              ##
// Data......: 05/08/2013                                                           ##
// Objetivo..: Pesquisa Customizada de Produtos                                     ##
// ###################################################################################

User Function AUTOM184()

   Local lChumba      := .F.
   Local lTem500      := .F.
   Local cTabela      := ""

   Private cCampo     := ReadVar()
   Private cPesquisa  := Space(40)
   Private cCadastro  := ""

   Private aVoltaFil  := {}

   Private oGet1

   Private aComboBx1  := {"1 - C�digo","2 - Descri��o", "3 - Part Number", "4 - NCM"}
   Private aComboBx2  := {"1 - C�digo","2 - Descri��o", "3 - Part Number", "4 - NCM"}
   Private aComboBx3  := {"1 - Igual" ,"2 - Iniciando", "3 - Contendo"}
   Private aComboBx4  := {}
   Private aComboBx5  := {"1 - Todos" ,"2 - Estoque", "4 - Est. + Liquida��o", "5 - Est. + Promo", "8 - Est.s/Giro"}

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

   Private cMostraBtn := .F.

   Private axBrowse := {}

   Private oDlg

   aAdd( aVoltaFil, { cEmpAnt, cFilAnt } )

   U_AUTOM628("AUTOM184")
   
   // ###################################################################################
   // Verifica se o usu�rio logado possui permiss�o de acesso ao Hist�rios de Produtos ##
   // ###################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_AHIS" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If Alltrim(__CUSERID) == "000000"
      cMostraBtn := .T.
   Else
      If U_P_OCCURS(T_PARAMETROS->ZZ4_AHIS, __CUSERID, 1) == 0
         cMostraBtn := .F.
      Else
         cMostraBtn := .T.            
      Endif
   Endif      

   // ######################################
   // Carrega o combo de Tabela de Pre�os ##
   // ######################################
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

   cComboBx1 := "2 - Descri��o"
   cComboBx2 := "2 - Descri��o"
   cComboBx3 := "3 - Contendo"
   cComboBx5 := "1 - Todos"
   
   If lTem500 == .T.
      cComboBx4 := cTabela
   Endif   

   // #############################################################
   // Envia apara a fun��o que carrega o grid na entrada da tela ##
   // xbuscapro(1)                                               ##
   // #############################################################
           
   // #############################################
   // Desenha a tela para visualiza��o dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Pesquisa de Produtos" FROM C(178),C(181) TO C(596),C(958) PIXEL

   @ C(010),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(051) PIXEL NOBORDER OF oDlg

   @ C(037),C(060) Say "CONSULTA CADASTRO DE PRODUTOS" Size C(103),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(174) Say "String Pesquisa"               Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(017),C(174) Say "Pesquisar por"                 Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(174) Say "Ordenar por"                   Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(174) Say "Tabela Pre�o"                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(003),C(216) MsGet oGet1 Var cPesquisa Size C(110),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(001),C(330) Button "Pesquisar" Size C(053),C(012) PIXEL OF oDlg ACTION(xbuscapro(2))
   
   @ C(016),C(216) ComboBox cComboBx1 Items aComboBx1 Size C(063),C(010) PIXEL OF oDlg
   @ C(016),C(282) ComboBox cComboBx3 Items aComboBx3 Size C(045),C(010) PIXEL OF oDlg
   @ C(016),C(330) ComboBox cComboBx5 Items aComboBx5 Size C(053),C(010) PIXEL OF oDlg
   @ C(028),C(216) ComboBox cComboBx2 Items aComboBx2 Size C(166),C(010) PIXEL OF oDlg
   @ C(039),C(216) ComboBox cComboBx4 Items aComboBx4 Size C(166),C(010) PIXEL OF oDlg

   @ C(193),C(005) Button "Visualizar Cadastro" Size C(053),C(012) PIXEL OF oDlg ACTION(xCadProd(axBrowse[oxBrowse:nAt,02]))
   @ C(193),C(059) Button "Visualizar Saldos"   Size C(053),C(012) PIXEL OF oDlg ACTION(xSaldoProd(axBrowse[oxBrowse:nAt,02]))

   @ C(193),C(121) Button "Cta Cont�bil"        Size C(037),C(012) PIXEL OF oDlg ACTION(MostraCtaConta(axBrowse[oxBrowse:nAt,02]))
   @ C(193),C(166) Button "Regras"              Size C(037),C(012) PIXEL OF oDlg ACTION(xRegrasNeg())
   @ C(193),C(206) Button "Legenda"             Size C(037),C(012) PIXEL OF oDlg ACTION(xLegendaPq())
// @ C(193),C(273) Button "Saldo Consolidado"   Size C(044),C(012) PIXEL OF oDlg ACTION(xSeleciona(axBrowse[oxBrowse:nAt,02]))
   @ C(193),C(247) Button "Saldo Consolidado"   Size C(044),C(012) PIXEL OF oDlg ACTION(U_AUTOM291(axBrowse[oxBrowse:nAt,02], axBrowse[oxBrowse:nAt,04]))

   If cMostraBtn == .T.            
      @ C(193),C(296) Button "Hist�rico Produto"   Size C(044),C(012) PIXEL OF oDlg ACTION(OpcaoHistorico())
   Endif   

   @ C(193),C(345) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( K_Produto := axBrowse[oxBrowse:nAt,02], oDlg:End() )

   oxBrowse := TCBrowse():New( 065 , 006, 483, 178,,{'','Codigo', 'Part Number', 'Descri��o dos Produtos', 'NCM', 'Moeda', 'Pre�o Unit.', 'Qtd.Rolo.Etq'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   If Len(axBrowse) == 0
      aAdd( axBrowse, { '1', '', '', '', '', '', '', '' } )
   Endif   

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oxBrowse:SetArray(axBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oxBrowse:bLine := {||{ If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         axBrowse[oxBrowse:nAt,02]               ,;
                         axBrowse[oxBrowse:nAt,03]               ,;
                         axBrowse[oxBrowse:nAt,04]               ,;                         
                         axBrowse[oxBrowse:nAt,05]               ,;
                         axBrowse[oxBrowse:nAt,06]               ,;
                         axBrowse[oxBrowse:nAt,07]               ,;
                         axBrowse[oxBrowse:nAt,08]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################
// Fun��o que fecha a janela pelo bot�o selecionar ##
// ##################################################
Static Function xSeleciona(_Produto)

   // ###################################
   // Posiciona no produto selecionado ##
   // ###################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)
   
   &cCampo     := _Produto
   aCpoRet[1]  := _Produto

   oDlg:End()
   
Return

// #####################################################
// Fun��o que pesquisa o saldo do produto selecionado ##
// #####################################################
Static Function xSaldoProd(_Produto)

   aArea := GetArea()

   // ####################################################
   // Posiciona no produto a ser pesquisado o seu saldo ##
   // ####################################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   If DbSeek(xFilial("SB1") + _Produto)
      MaViewSB2(_Produto)
   Else
      MsgAlert("Saldo n�o encontrado.")   
   Endif   

   RestArea( aArea )

Return .T.

// ########################################################
// Fun��o que pesquisa o cadastro do produto selecionado ##
// ########################################################
Static Function xCadProd(_Produto)

   aArea := GetArea()
   
   // ####################################################
   // Posiciona no produto a ser pesquisado o seu saldo ##
   // ####################################################
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   AxVisual("SB1", SB1->( Recno() ), 2)

   RestArea( aArea )

Return .T.

// #####################################################################
// Fun��o que pesquisa o produto a medida que o usu�rio vai digitando ##
// #####################################################################
Static Function xbuscapro(_Tipo)

   MsgRun("Aguarde! Pesquisando produtos conforme par�metros ...", "Pesquisa de Produtos",{|| kbuscapro(_Tipo) })

Return(.T.)

// #####################################################################
// Fun��o que pesquisa o produto a medida que o usu�rio vai digitando ##
// #####################################################################
Static Function kbuscapro(_Tipo)

   Local cSql   := ""
   Local nSaldo := 0
   Local nCor   := ""
   Local nDias  := 0

   Local cGramat := 	''
   Local cMetr	 :=	''
   Local cEtqRol :=	''
   Local cRolos	 :=	''
   Local nMetr   := 0
   Local nEtqRol := 0
   Local nRolos  := 0

   aArea := GetArea()
   
   axBrowse := {}

//   If _Tipo == 2
//      If Len(Alltrim(cPesquisa)) == 0
//         aAdd( axBrowse, { '1', '', '', '', '', '', '' } )
//         oxBrowse:SetArray(axBrowse) 
//         Return .T.
//      Endif   
//   Endif

   // #####################################################
   // Pesquisa o Par�metro de Dias para Leganda Vermelha ##
   // #####################################################
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

   // ###########################################
   // Carrega o Array com os dados pesquisados ##
   // ###########################################
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
            Case Substr(cComboBx1,01,01) = "1" // C�digo
                 Do Case
                    Case Substr(cComboBx3,01,01) == "1" // Igual
                         cSql += " WHERE A.B1_COD = '" + Alltrim(cPesquisa) + "'" + CHR(13)
                    Case Substr(cComboBx3,01,01) == "2" // Iniciando
                         cSql += " WHERE A.B1_COD  LIKE '" + Alltrim(cPesquisa) + "%'" + CHR(13)
                    Case Substr(cComboBx3,01,01) == "3" // Contendo
                         cSql += " WHERE A.B1_COD  LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
                 EndCase                   
  
            Case Substr(cComboBx1,01,01) = "2" // Descri��o
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

   // ############
   // Ordena��o ##
   // ############
   Do Case
      Case Substr(cComboBx2,01,01) == "1" // C�digo
           cSql += " ORDER BY A.B1_COD" + CHR(13)
      Case Substr(cComboBx2,01,01) == "2" // Descri��o
           cSql += " ORDER BY A.B1_DESC" + CHR(13)
      Case Substr(cComboBx2,01,01) == "3" // Part Number
           cSql += " ORDER BY A.B1_PARNUM" + CHR(13)
      Case Substr(cComboBx2,01,01) == "4" // NCM
           cSql += " ORDER BY A.B1_POSIPI" + CHR(13)
   EndCase                   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If T_PRODUTO->( EOF() )
      aAdd( axBrowse, { '1', '', '', '', '', '', '', '' } )
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

         // #######################################################
         // Aplica a legenda Vermelha conforme par�metro de Dias ##
         // #######################################################
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

         // ######################
         // Filtra pela Legenda ##
         // ######################
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
         // Calcula a quantidade de rolos por etiquetas caso o produto selecionado � etiqueta ##
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

         // ##########################
         // Carrega o Array axBrowse ##
         // ##########################
         aAdd( axBrowse, { nCor                 , ;
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

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oxBrowse:SetArray(axBrowse) 
    
   // ######################################## 
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oxBrowse:bLine := {||{ If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(axBrowse[oxBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         axBrowse[oxBrowse:nAt,02]               ,;
                         axBrowse[oxBrowse:nAt,03]               ,;
                         axBrowse[oxBrowse:nAt,04]               ,;                         
                         axBrowse[oxBrowse:nAt,05]               ,;
                         axBrowse[oxBrowse:nAt,06]               ,;
                         axBrowse[oxBrowse:nAt,07]               ,;
                         axBrowse[oxBrowse:nAt,08]               }}

   RestArea( aArea )

Return .T.

// ####################################################################
// Fun��o que apresenta a janela de legendas de pesquisa de produtos ##
// ####################################################################
Static Function xLegendaPq()

   Local cSql  := ""
   Local nDias := 0

   Private oDlgL

   // #####################################################
   // Pesquisa o Par�metro de Dias para Leganda Vermelha ##
   // #####################################################
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
   @ C(028),C(018) Say "Produtos com estoque em toda a Companhia e que est�o em PROMO��O" Size C(177),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(041),C(018) Say "Tem estoque disponivel para venda na Companhia e que n�o tem giro de estoque na Matriz a mais de " + Alltrim(Str(nDias)) + " dias." Size C(240),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(053),C(018) Say "Produtos em Liquida��o"                                           Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
      
   @ C(003),C(003) Jpeg FILE "br_branco"   Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(015),C(003) Jpeg FILE "br_verde"    Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(027),C(003) Jpeg FILE "br_azul"     Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(039),C(003) Jpeg FILE "br_vermelho" Size C(010),C(011) PIXEL NOBORDER OF oDlgLG
   @ C(051),C(003) Jpeg FILE "br_amarelo"  Size C(010),C(011) PIXEL NOBORDER OF oDlgLG

   @ C(064),C(116) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLG ACTION( oDlgLG:End() )

   ACTIVATE MSDIALOG oDlgLG CENTERED 

Return(.T.)

// ###############################################
// Fun��o que apresenta as regras de negocia��o ##
// ###############################################
Static Function xRegrasNeg()

   Local cSql      := ""
   Local _Programa := ""
   Local _Arquivo  := ""

   U_AUTO214B()

   RETURN(.T.)

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
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
      MsgAlert("Regras inexistentes para visualiza��o.")
      Return(.T.)
   Endif

   _Programa := Alltrim(T_PARAMETROS->ZZ4_EPRG)
   _Arquivo  := Alltrim(T_PARAMETROS->ZZ4_EARQ)

   If !File(_Arquivo)
      MsgAlert("Arquivo de Regras de Neg�cio inexistente.")
      Return(.T.)
   Endif
      
   WinExec(_Programa + " " + _Arquivo)

Return(.T.)

// #####################################################################################
// Fun��o que abre a tela para visualiza��o do c�digo cont�bil do produto selecionado ##
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

   DEFINE MSDIALOG oDlgCta TITLE "N� Conta Cont�bil" FROM C(178),C(181) TO C(395),C(486) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgCta

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(146),C(001) PIXEL OF oDlgCta
   @ C(084),C(002) GET oMemo2 Var cMemo2 MEMO Size C(146),C(001) PIXEL OF oDlgCta

   @ C(037),C(005) Say "N� Conta Cont�bil"        Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgCta
   @ C(060),C(005) Say "Descri��o Conta Cont�bil" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgCta

   @ C(047),C(005) MsGet oGet1 Var kConta     Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCta When lChumba
   @ C(069),C(005) MsGet oGet2 Var kDescricao Size C(145),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCta When lChumba

   @ C(091),C(056) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCta ACTION( oDlgCta:End() )

   ACTIVATE MSDIALOG oDlgCta CENTERED 

Return(.T.)

// ####################################################
// Fun��o que abre as op��es do Hist�rico do Produto ##
// ####################################################
Static Function OpcaoHistorico()

   Private oDlgHIST

   DEFINE MSDIALOG oDlgHIST TITLE "Historico do Produto" FROM C(178),C(181) TO C(502),C(445) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp"            Size C(126),C(022) PIXEL NOBORDER OF oDlgHIST

   @ C(027),C(004) Button "�ltimos Pedidos de Compra"     Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(1, axBrowse[oxBrowse:nAt,02], "") )
   @ C(046),C(004) Button "�ltimas Notas Fiscais"         Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(2, axBrowse[oxBrowse:nAt,02], "") )
   @ C(065),C(004) Button "Consumo / Vendas"              Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(3, axBrowse[oxBrowse:nAt,02], "") )
   @ C(084),C(004) Button "Estoque Empresa/Filial Logada" Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(4, axBrowse[oxBrowse:nAt,02], "") )
   @ C(103),C(004) Button "Estoque Consolidado"           Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(5, axBrowse[oxBrowse:nAt,02], axBrowse[oxBrowse:nAt,04]))
   @ C(122),C(004) Button "Custo Sale Machine"            Size C(126),C(018) PIXEL OF oDlgHIST ACTION( DisparaOPC(6, axBrowse[oxBrowse:nAt,02], "") )
   @ C(141),C(004) Button "Voltar"                        Size C(126),C(018) PIXEL OF oDlgHIST ACTION( oDlgHIST:End() )

   ACTIVATE MSDIALOG oDlgHIST CENTERED 

Return(.T.)

// ##########################################################################
// Fun��o que direciona ao programa relacionado conforme sele��o das o��es ##
// ##########################################################################
Static Function DisparaOPC(DOpcao, DProduto, dDescricao)

   Do Case

      // ###############################
      // Pedidos de Compra do Produto ##
      // ###############################
      Case dOpcao == 1
           U_AUTOM639(dProduto)

      // ######################################
      // Notas Fiscais de Entrada do produto ##
      // ######################################
      Case dOpcao == 2
           U_AUTOM640(dProduto)

           cEmpAnt := aVoltaFil[1,1]
           cFilAnt := aVoltaFil[1,2]           

      // ###########################
      // Consumo/Venda do produto ##
      // ###########################
      Case dOpcao == 3
           U_AUTOM598(dProduto)

      // ################################
      // Estoque Empresa/Filial Logada ##
      // ################################
      Case dOpcao == 4
           xSaldoProd(dProduto)

      // ######################
      // Estoque Consolidado ##
      // ######################
      Case dOpcao == 5
           U_AUTOM291(dProduto, dDescricao)

      // #####################
      // Custo Sale Machine ##
      // #####################
      Case dOpcao == 6
           U_AUTOM537(dProduto)

   EndCase

Return(.T.)