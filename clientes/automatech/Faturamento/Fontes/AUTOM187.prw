#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM187.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 16/08/2013                                                          ##
// Objetivo..: Tela de Manutenção de Boletos A Vista pela Proposta Comercial.      ##
// ##################################################################################

User Function AUTOM187()

   MsgRun("Aguarde! Abrindo Programa Boletos A Vista ...", "Programa: AUTOM187",{|| xAUTOM187() })

Return(.T.)

Static Function xAUTOM187()

   Local cMemo1 := ""
   Local oMemo1

   Private aFiltro   := {"1 - Nome", "2 - Código", "3 - CNPJ", "4 - CPF", "5 - Nosso Número", "6 - Pedido de Venda", "7 - Todos (Abertos/Baixados)", "8 - Somente em Aberto", "9 - Somente Baixados", "0 - Vendedor" }
   Private cFiltro
   Private aBrowse   := {}

   Private cPesquisa := Space(100)
   Private oGet1

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

   Private oDlg

   U_AUTOM628("AUTOM187")

   aAdd( aBrowse, { "1","","","","","","","","",0,"","","","","","","","","" } )

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Controle Boleto bancário - A Vista" FROM C(178),C(181) TO C(603),C(950) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(379),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Pesquisar por"           Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(099) Say "String a ser pesquisada" Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cFiltro Items aFiltro   Size C(089),C(010)                              PIXEL OF oDlg
   @ C(046),C(099) MsGet    oGet1   Var   cPesquisa Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(043),C(275) Button "Pesquisar"          Size C(037),C(012) PIXEL OF oDlg ACTION(gPesquisa())
   @ C(197),C(005) Button "Alterar Vencimento" Size C(052),C(012) PIXEL OF oDlg ACTION( aDetalhes("A") )
   @ C(197),C(058) Button "Visualizar"         Size C(052),C(012) PIXEL OF oDlg ACTION( aDetalhes("V") )
   @ C(197),C(112) Button "Excluir Registro"   Size C(052),C(012) PIXEL OF oDlg ACTION( aDetalhes("E") )
   @ C(197),C(165) Button "Baixar Boleto"      Size C(052),C(012) PIXEL OF oDlg ACTION( aDetalhes("B") )
// @ C(197),C(219) Button "Emitir Boleto"      Size C(052),C(012) PIXEL OF oDlg ACTION( aBreEBol(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], "R", aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,14]) )
   @ C(197),C(328) Button "Voltar"             Size C(052),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 075 , 005, 485, 172,,{'Lg', 'FL','PV', 'Emissão', 'Cliente', 'Loja', 'Nome do Cliente', 'Parc.', 'Vectº', 'Valor', 'Nosso Número', 'C.Pgtº', 'Descrição C.Pagamento', 'Data da Baixa', 'Vendedor', 'Nome dos Vendedores'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;
                         aBrowse[oBrowse:nAt,14],;
                         aBrowse[oBrowse:nAt,15],;
                         aBrowse[oBrowse:nAt,16]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################
// Função que abre a emissão dos boletos bancários ##
// ##################################################
Static Function aBreEBol( y__Filial, y__Pedido, y__Operacao, y__Parcela, y__Vencimento, y__Valor, y__Baixa  )

   If Substr(y__Baixa,01,02) <> "  "
      MsgAlert("Emissão de Boleto não permitida. Registro já baixado.")
      Return(.T.)
   Endif

   // ####################################################
   // Envia para o programa que emite o boleto bancário ##
   // Banco Itaú      = 1                               ##
   // Banco Santander = 2                               ##
   // ####################################################
   kk_Banco := SelBanco()
   
   If kk_Banco == "0"
      Return(.T.)
   Else
      If kk_banco == "1"
         U_AUTOM186(y__Filial, y__Pedido, y__Operacao, y__Parcela, y__Vencimento, y__Valor, "1")
      Else
         U_AUTOM667(y__Filial, y__Pedido, y__Operacao, y__Parcela, y__Vencimento, y__Valor, "2")
      Endif
   Endif      

   // ##############################
   // Atualiza o Grid dos Boletos ##
   // ##############################
   gPesquisa()

Return(.T.)

// ###################################################################################
// Função que permite o usuário selecionar o banco a ser impresso o boleto bancário ##
// ###################################################################################
Static Function SelBanco()

   Local cMemo1	 := ""
   Local oMemo1
   Local cBcoRet := "0"

   Local aBancos := {"0 - Selecione o Banco", "1 - Banco ITAÚ", "2 - BANCO SANTANDER"}
   Local cComboBx1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Seleção Banco" FROM C(178),C(181) TO C(331),C(500) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(152),C(001) PIXEL OF oDlg

   @ C(034),C(005) Say "Emitir o boleto para o Banco" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(043),C(005) ComboBox cComboBx1 Items aBancos Size C(149),C(010) PIXEL OF oDlg

   @ C(059),C(041) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( cBcoRet := Substr(cComboBx1,01,01), oDlg:End() )
   @ C(059),C(080) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( cBcoRet := "0", oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(cBcoRet)

// ###################################################
// Função que pesquisa os dados para popular o Grid ##
// ###################################################
Static Function GPesquisa()

   Local cSql := ""
   
   aBrowse := {}
   
   If Substr(cFiltro,01,01) == "7" .Or. Substr(cFiltro,01,01) == "8" .Or. Substr(cFiltro,01,01) == "9"
      cPesquisa := Space(100)
      oGet1:Refresh()
   Endif

   If Select("T_BOLETOS") > 0
      T_BOLETOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZS0_FILIAL," + CHR(13)
   cSql += "       A.ZS0_PEDIDO," + CHR(13)
   cSql += "       A.ZS0_EMISSA," + CHR(13)
   cSql += "       A.ZS0_CODCLI," + CHR(13)
   cSql += "       A.ZS0_LOJCLI," + CHR(13)
   cSql += "       E.C5_CLIENTE," + CHR(13)
   cSql += "	   E.C5_LOJACLI," + CHR(13)
   cSql += "       B.A1_NOME   ," + CHR(13)
   cSql += "       B.A1_CGC    ," + CHR(13)
   cSql += "       A.ZS0_COND  ," + CHR(13)
   cSql += "       C.E4_DESCRI ," + CHR(13)
   cSql += "       A.ZS0_NOSN  ," + CHR(13)
   cSql += "       A.ZS0_VENC  ," + CHR(13)
   cSql += "       A.ZS0_VALOR ," + CHR(13)
   cSql += "       A.ZS0_PARC  ," + CHR(13)
   cSql += "       A.ZS0_EMAIL ," + CHR(13)
   cSql += "       A.ZS0_BAIXA ," + CHR(13)
   cSql += "       A.ZS0_VEND  ," + CHR(13)
   cSql += "       D.A3_NOME   ," + CHR(13)
   cSql += "       A.ZS0_BANCO ," + CHR(13)
   cSql += "       A.ZS0_AGEN  ," + CHR(13)
   cSql += "       A.ZS0_CONTA  " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZS0") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("SE4") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("SA3") + " D, " + CHR(13)
   cSql += "       " + RetSqlName("SC5") + " E  " + CHR(13)
   cSql += " WHERE A.D_E_L_E_T_ = ''" + CHR(13)
   cSql += "   AND A.ZS0_DELE   = ''" + CHR(13)
   cSql += "   AND E.C5_FILIAL  = A.ZS0_FILIAL" + CHR(13)
   cSql += "   AND E.C5_NUM     = A.ZS0_PEDIDO" + CHR(13)
   cSql += "   AND E.D_E_L_E_T_ = ''"           + CHR(13)
   cSql += "   AND B.A1_COD     = E.C5_CLIENTE" + CHR(13)
   cSql += "   AND B.A1_LOJA    = E.C5_LOJACLI" + CHR(13)
   cSql += "   AND B.A1_FILIAL  = ''"           + CHR(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"           + CHR(13)
   cSql += "   AND A.ZS0_COND   = C.E4_CODIGO"  + CHR(13)
   cSql += "   AND C.D_E_L_E_T_ = ''"           + CHR(13)
   cSql += "   AND A.ZS0_VEND   = D.A3_COD"     + CHR(13)
   cSql += "   AND D.A3_FILIAL  = ''      "     + CHR(13)
   cSql += "   AND D.D_E_L_E_T_ = ''"           + CHR(13)
   cSql += "   AND A.ZS0_DELE   = ''"           + CHR(13)
   
   If !Empty(Alltrim(cPesquisa))

      // Por Nome do Cliente
      If Substr(cFiltro,01,01) == "1"
         cSql += " AND B.A1_NOME LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
      Endif
      
      // Por Código do Cliente
      If Substr(cFiltro,01,01) == "2"
         cSql += " AND E.C5_CLIENTE LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
      Endif
   
      // Por CNPJ
      If Substr(cFiltro,01,01) == "3"
         cSql += " AND B.A1_CGC LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
      Endif

      // Por CPF
      If Substr(cFiltro,01,01) == "4"
         cSql += " AND B.A1_CGC LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
      Endif

      // Por Nosso Número
      If Substr(cFiltro,01,01) == "5"
         cSql += " AND A.ZS0_NOSN LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
      Endif

      // Por Pedido de Venda
      If Substr(cFiltro,01,01) == "6"
         cSql += " AND A.ZS0_PEDIDO LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
      Endif
   
      // Por Vendedor
      If Substr(cFiltro,01,01) == "0"
         cSql += " AND D.A3_NOME LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
      Endif

   Else

      // Abertos e Encerrados
      If Substr(cFiltro,01,01) == "7"
      Endif

      // Somente Abertos
      If Substr(cFiltro,01,01) == "8"
         cSql += " AND A.ZS0_BAIXA = ''"
      Endif

      // Somente Encerrados
      If Substr(cFiltro,01,01) == "9"
         cSql += " AND A.ZS0_BAIXA <> ''"
      Endif
   
   Endif   
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BOLETOS", .T., .T. )

   If T_BOLETOS->( eof() )
      aAdd( aBrowse, { "1","","","","","","","","",0,"","","","","","","" } )
      MsgAlert("Não existem dados a serem visualizados para este tipo de filtro.")
   Else
      T_BOLETOS->( DbGoTop() )
      WHILE !T_BOLETOS->( EOF() )      
         // Carrega o Array aBrowse
         aAdd( aBrowse, { IIF(Substr(T_BOLETOS->ZS0_BAIXA,07,02) == "  ", "2", "8"),;
                          T_BOLETOS->ZS0_FILIAL,;
                          T_BOLETOS->ZS0_PEDIDO,;
                          Substr(T_BOLETOS->ZS0_EMISSA,07,02) + "/" + Substr(T_BOLETOS->ZS0_EMISSA,05,02) + "/" + Substr(T_BOLETOS->ZS0_EMISSA,01,04) ,;
                          T_BOLETOS->C5_CLIENTE,;
                          T_BOLETOS->C5_LOJACLI,;
                          T_BOLETOS->A1_NOME   ,;
                          T_BOLETOS->ZS0_PARC  ,;
                          Substr(T_BOLETOS->ZS0_VENC,07,02) + "/" + Substr(T_BOLETOS->ZS0_VENC,05,02) + "/" + Substr(T_BOLETOS->ZS0_VENC,01,04) ,;
                          T_BOLETOS->ZS0_VALOR ,;
                          T_BOLETOS->ZS0_NOSN  ,;
                          T_BOLETOS->ZS0_COND  ,;
                          T_BOLETOS->E4_DESCRI ,;
                          Substr(T_BOLETOS->ZS0_BAIXA,07,02) + "/" + Substr(T_BOLETOS->ZS0_BAIXA,05,02) + "/" + Substr(T_BOLETOS->ZS0_BAIXA,01,04) ,;
                          T_BOLETOS->ZS0_VEND  ,;
                          T_BOLETOS->A3_NOME   ,;
                          T_BOLETOS->ZS0_BANCO ,;
                          T_BOLETOS->ZS0_AGEN  ,;
                          T_BOLETOS->ZS0_CONTA })
         T_BOLETOS->( DbSkip() )                       
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
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;
                         aBrowse[oBrowse:nAt,14],;
                         aBrowse[oBrowse:nAt,15],;
                         aBrowse[oBrowse:nAt,16]} }

Return(.T.)

// Função que abre a janela para mostrar os detalhes da parcela selecionada
Static Function ADetalhes( _Operacao)

   Local lChumba := .F.
   Local lSalvar := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private cGet1 	 := aBrowse[oBrowse:nAt,02]
   Private cGet2     := Space(25)
   Private cGet3	 := aBrowse[oBrowse:nAt,03]
   Private cGet4	 := aBrowse[oBrowse:nAt,04]
   Private cGet16	 := aBrowse[oBrowse:nAt,15]
   Private cGet5	 := aBrowse[oBrowse:nAt,16]
   Private cGet6	 := aBrowse[oBrowse:nAt,05]
   Private cGet7	 := aBrowse[oBrowse:nAt,06]
   Private cGet8	 := aBrowse[oBrowse:nAt,07]
   Private cGet9	 := aBrowse[oBrowse:nAt,12]
   Private cGet10	 := aBrowse[oBrowse:nAt,13]
   Private cGet11	 := aBrowse[oBrowse:nAt,08]
   Private cGet12	 := Ctod(aBrowse[oBrowse:nAt,09])
   Private cGet13	 := aBrowse[oBrowse:nAt,10]
   Private cGet14	 := aBrowse[oBrowse:nAt,11]
   Private cGet15	 := Ctod(aBrowse[oBrowse:nAt,14])
   Private cGet17    := aBrowse[oBrowse:nAt,17]
   Private cGet19    := aBrowse[oBrowse:nAt,18]
   Private cGet20    := aBrowse[oBrowse:nAt,19]

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet16
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

   Private oGet17
   Private oGet18
   Private oGet19   
   Private oGet20
   
   Private oDlgDet

   Do Case
      Case cGet1 == "01"
           cGet2 := "PORTO ALEGRE"
      Case cGet1 == "02"
           cGet2 := "CAXIAS DO SUL"
      Case cGet1 == "03"
           cGet2 := "PELOTAS"
      Case cGet1 == "04"
           cget2 := "SUPRIMENTOS"
      Case cGet1 == "05"
           cget2 := "SAO PAULO"
   EndCase

   DEFINE MSDIALOG oDlgDet TITLE "Controle de Boletos Bancários - A Vista" FROM C(178),C(181) TO C(540),C(595) PIXEL

   @ C(005),C(005) Say "Filial"                Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(005),C(119) Say "Pedido de Venda"       Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(005),C(164) Say "Dta Emissão"           Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(026),C(005) Say "Vendedor"              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(046),C(005) Say "Cliente"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(067),C(005) Say "Condição de Pagamento" Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(097),C(005) Say "Nº Parcela"            Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(097),C(039) Say "Vencimento"            Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(097),C(083) Say "Valor"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(097),C(133) Say "Nosso Número"          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(128),C(005) Say "Data Baixa"            Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(128),C(056) Say "Banco"                 Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(128),C(089) Say "Agência"               Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet
   @ C(128),C(133) Say "Nº da Conta"           Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgDet

   @ C(092),C(005) GET oMemo1 Var cMemo1 MEMO Size C(196),C(001) PIXEL OF oDlgDet
   @ C(121),C(005) GET oMemo2 Var cMemo2 MEMO Size C(196),C(001) PIXEL OF oDlgDet
   @ C(154),C(005) GET oMemo3 Var cMemo3 MEMO Size C(196),C(001) PIXEL OF oDlgDet
      
   // Trata o botão Salvar
   If Empty(cGet15)
      lSalvar := .T.
   Else
      lSalvar := .F.
   Endif

   @ C(014),C(005) MsGet oGet1  Var cGet1  When lChumba Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(014),C(021) MsGet oGet2  Var cget2  When lChumba Size C(094),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(014),C(119) MsGet oGet3  Var cGet3  When lChumba Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(014),C(164) MsGet oGet4  Var cGet4  When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(034),C(005) MsGet oGet16 Var cGet16 When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(034),C(032) MsGet oGet5  Var cGet5  When lChumba Size C(169),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(055),C(005) MsGet oGet6  Var cGet6  When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(055),C(032) MsGet oGet7  Var cGet7  When lChumba Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(055),C(051) MsGet oGet8  Var cGet8  When lChumba Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(076),C(005) MsGet oGet9  Var cGet9  When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(076),C(033) MsGet oGet10 Var cGet10 When lChumba Size C(168),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
   @ C(106),C(005) MsGet oGet11 Var cGet11 When lChumba Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
 
   If _Operacao == "V"
      @ C(106),C(039) MsGet oGet12 Var cGet12 When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet      
   Else
      @ C(106),C(039) MsGet oGet12 Var cGet12 When lSalvar Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet      
   Endif

   If _Operacao == "E" .Or. _Operacao == "B"
      @ C(106),C(039) MsGet oGet12 Var cGet12 When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet      
   Endif
      
   @ C(106),C(083) MsGet oGet13 Var cGet13 When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgDet
   @ C(106),C(133) MsGet oGet14 Var cGet14 When lChumba Size C(067),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet

   If _Operacao == "V"
      @ C(138),C(005) MsGet oGet15 Var cGet15 When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet         
      @ C(138),C(056) MsGet oGet17 Var cGet17 When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet F3("SA6")
      @ C(138),C(089) MsGet oGet19 Var cGet19 When lChumba Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
      @ C(138),C(133) MsGet oGet20 Var cGet20 When lChumba Size C(067),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
      lSalvar := .F.
   Else
      If _Operacao == "B"
         If Empty(cGet15)
            @ C(138),C(005) MsGet oGet15 Var cGet15              Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
         Else
            @ C(138),C(005) MsGet oGet15 Var cGet15 When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet         
         Endif
      Else
         @ C(138),C(005) MsGet oGet15 Var cGet15 When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
      Endif

      If _Operacao == "B"
         If Empty(cGet15)
            @ C(138),C(056) MsGet oGet17 Var cGet17 Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet F3("SA6")
            @ C(138),C(089) MsGet oGet19 Var cGet19 Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
            @ C(138),C(133) MsGet oGet20 Var cGet20 Size C(067),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
         Else
            @ C(138),C(056) MsGet oGet17 Var cGet17 When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet F3("SA6")
            @ C(138),C(089) MsGet oGet19 Var cGet19 When lChumba Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
            @ C(138),C(133) MsGet oGet20 Var cGet20 When lChumba Size C(067),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
         Endif
      Else
         @ C(138),C(056) MsGet oGet17 Var cGet17 When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
         @ C(138),C(089) MsGet oGet19 Var cGet19 When lChumba Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
         @ C(138),C(133) MsGet oGet20 Var cGet20 When lChumba Size C(067),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDet
      Endif
   Endif

   @ C(162),C(065) Button "Salvar" When lSalvar Size C(037),C(012) PIXEL OF oDlgDet ACTION( SalvaDetB(_Operacao) )
   @ C(162),C(104) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlgDet ACTION( oDlgDet:End() )

   ACTIVATE MSDIALOG oDlgDet CENTERED 

Return(.T.)

// Função que Salva os dados alterados no Detalhe do Boleto selecionado
Static Function SalvaDetB( _Operacao)

   // Alteração de Vencimento da Parcela
   IF _Operacao == "A"

      If Empty(cGet12)
         Msgalert("Data de vencimento não informada.")
         Return(.T.)
      Endif

      DbSelectArea("ZS0")
      DbSetOrder(2)
      If DbSeek(cGet1 + cGet3 + cGet11)
         RecLock("ZS0",.F.)
         ZS0_VENC := cGet12
         MsUnLock()              
      Endif

   Endif

   // Exclusão de Registros
   IF _Operacao == "E"

	  If MsgYesNo("Confirma a exclusão deste registro?")
         DbSelectArea("ZS0")
         DbSetOrder(2)
         If DbSeek(cGet1 + cGet3 + cGet11)
            RecLock("ZS0",.F.)
            ZS0_DELE := "X"
            MsUnLock()              
         Endif
      Endif

   Endif

   // Baixa do Título
   IF _Operacao == "B"

      If Empty(cGet15)
         Msgalert("Data da Baixa da parcela não informada.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cGet17))
         Msgalert("Banco não informado.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cGet19))
         Msgalert("Agência não informada.")
         Return(.T.)
      Endif

      If Empty(Alltrim(cGet20))
         Msgalert("Conta não informada.")
         Return(.T.)
      Endif

	  If MsgYesNo("Confirma a baixa deta parcela?")
         DbSelectArea("ZS0")
         DbSetOrder(2)
         If DbSeek(cGet1 + cGet3 + cGet11)
            RecLock("ZS0",.F.)
            ZS0_BAIXA := cGet15
            ZS0_BANCO := cGet17
            ZS0_AGEN  := cGet19
            ZS0_CONTA := cGet20                        
            MsUnLock()              

            // Cria o RA do recebimento
            dbSelectArea("SE1")
            RecLock("SE1",.T.)
            SE1->E1_FILIAL  := ""
            SE1->E1_PREFIXO := "RA"
            SE1->E1_NUM     := Alltrim(cGet3) + Alltrim(cGet11)
            SE1->E1_PARCELA := Alltrim(cGet11)
            SE1->E1_TIPO    := "RA"
            SE1->E1_NATUREZ := "10105"
            SE1->E1_CLIENTE := cGet6
            SE1->E1_LOJA    := cGet7
            SE1->E1_NOMCLI  := cGet8
            SE1->E1_EMISSAO := cGet15
            SE1->E1_VENCTO  := cGet12
            SE1->E1_VENCREA := cGet12            
            SE1->E1_VALOR   := cGet13
            SE1->E1_VLCRUZ  := cGet13
            SE1->E1_HIST    := "REF. PV Nº " + Alltrim(cGet3) + " da Parcela " + Alltrim(cGet11)
            SE1->E1_MOEDA   := 1
            SE1->E1_FILORIG := cGet1
            SE1->E1_TIPODES := "1"
            SE1->E1_FLUXO   := "S"
            SE1->E1_VENCORI := cGet12
            SE1->E1_SALDO   := cGet13
            SE1->E1_EMIS1   := cGet15
            SE1->E1_PORTADO := cGet17
            SE1->E1_AGEDEP  := cGet19
            SE1->E1_CONTA   := cGet20
            SE1->E1_STATUS  := "A"
            SE1->E1_ORIGEM  := "FINA040"
            SE1->E1_MULTNAT := "2"
            SE1->E1_MSFIL   := cGet1
            SE1->E1_MSEMP   := cGet1
            SE1->E1_PROJPMS := "2"
            SE1->E1_DESDOBR := "2"
            SE1->E1_MODSPB  := "1"
            SE1->E1_SCORGP  := "2"
            SE1->E1_RELATO  := "2"
            SE1->E1_APLVLMN := "1"
            MsUnLock()

            // Cria o RA do recebimento
            dbSelectArea("SE5")
            RecLock("SE5",.T.)
            SE5->E5_DATA    := cGet15
            SE5->E5_TIPO    := "RA"
            SE5->E5_MOEDA   := "01"
            SE5->E5_VALOR   := cGet13
            SE5->E5_NATUREZ := "10105"
            SE5->E5_BANCO   := cGet17
            SE5->E5_AGENCIA := cGet19
            SE5->E5_CONTA   := cGet20
            SE5->E5_RECPAG  := "R"
            SE5->E5_BENEF   := cGet8
            SE5->E5_HISTOR  := "REF. PV Nº " + Alltrim(cGet3) + " da Parcela " + Alltrim(cGet11)
            SE5->E5_TIPO    := "RA"
            SE5->E5_VLMOED2 := cGet13
            SE5->E5_LA      := "S"
            SE5->E5_PREFIXO := "RA"
            SE5->E5_NUMERO  := Alltrim(cGet3) + Alltrim(cGet11)
            SE5->E5_CLIFOR  := cGet6
            SE5->E5_LOJA    := cGet7
            SE5->E5_DTDIGIT := cGet15
            SE5->E5_MOTBX   := "NOR"
            SE5->E5_DTDISPO := cGet15
            SE5->E5_FILORIG := cGet1
            SE5->E5_CLIENTE := cGet6
            SE5->E5_MSFIL   := cGet7 
            MsUnLock()

         Endif

      Endif

   Endif

   // Fecha a janela de detalhes
   oDlgDet:End()

   // Atualiza o Grid dos Boletos
   gPesquisa()

Return(.T.)