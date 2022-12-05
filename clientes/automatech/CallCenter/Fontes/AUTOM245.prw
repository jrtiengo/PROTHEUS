#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM245.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 12/08/2014                                                          *
// Objetivo..: Programa que realiza pesquisa de Atendimento Call Center            *
//**********************************************************************************

User Function AUTOM245()

   Local lchumba       := .F.

   Private aVendedores := {}
   Private aKLegenda   := {"00 - Todos os Status", "01 - Atendimento", "02 - Orçamento", "03 - Faturamento", "04 - NF.Emitida", "05 - Cancelado" }
   Private aKFiliais   := {}
   Private aKOrdenacao := {"01 - Atendimento", "02 - Data", "03 - Cliente", "04 - Contato", "05 - Vendedor"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private cKInicial := Ctod("  /  /    ")
   Private cKFinal	 := cTod("  /  /    ")
   Private cKCliente := Space(100)
   Private cKAtendi  := Space(06)

   Private cMemo1	 := ""
   Private cMemo2	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oMemo1
   Private oMemo2
  
   Private oDlgK

   Private aAtendimento := {}

   Private nMeter1	 := 0
   Private oMeter1

   // Declara as Legendas
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

   // Carrega o Array aFiliais conforme a Empresa logada
   akFiliais := u_autom539(2, cEmpAnt) 

//   do Case
//      Case cEmpAnt == "01"
//           akFiliais := {"01 - POA", "02 - CXS", "03 - PEL", "04 - SUP"}
//      Case cEmpAnt == "02"
//           akFiliais := {"01 - TI"}      
//      Case cEmpAnt == "03"
//           akFiliais := {"01 - ATECH"}      
//   EndCase

   // Verifica o tipo de usuário.
   If Select("T_TIPOVENDE") > 0
      T_TIPOVENDE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A3_COD   ,"
   cSql += "       A3_NOME  ,"
   cSql += "       A3_CODUSR,"
   cSql += "       A3_TSTAT ,"
   cSql += "       A3_OUTR   "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A3_CODUSR  = '" + Alltrim(__cUserID) + "'"
   cSql += " ORDER BY A3_NOME     "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPOVENDE", .T., .T. )
   
   If T_TIPOVENDE->( EOF() )
      MsgAlert("Usuário não configurado como Vendedor. Entre em contato com o seu supervisor de área.")
      Return(.T.)
   Endif

   // Carrega o combobox de vendedores
   If Select("T_VENDEDORES") > 0
      T_VENDEDORES->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT A.A3_COD   ,"
   cSql += "       A.A3_NOME  ,"
   cSql += "       A.A3_CODUSR,"
   cSql += "       A.A3_TSTAT  "
   cSql += "  FROM " + RetSqlName("SA3") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.A3_CODUSR <> ''"
   cSql += "   AND A.A3_NREDUZ <> ''"

   If T_TIPOVENDE->A3_TSTAT == '1'

      If Empty(Alltrim(T_TIPOVENDE->A3_OUTR))
         cSql += " AND A.A3_CODUSR = '" + Alltrim(__cUserID) + "'"
      Else
         cWhere := " IN ('" + Alltrim(__cUserID) + "',"
         For nContar = 1 to U_P_OCCURS(T_TIPOVENDE->A3_OUTR, "|", 1)
             cWhere := cWhere + "'" + U_P_CORTA(T_TIPOVENDE->A3_OUTR, "|", nContar) + "',"
         Next nContar
         cWhere := Substr(cWhere,01,Len(Alltrim(cWhere)) - 1) + "')"
         cSql += " AND A.A3_CODUSR " + cWhere 
      Endif
   Endif

   cSql += " ORDER BY A.A3_NOME"     

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDORES", .T., .T. )

   aKVendedores := {}

   T_VENDEDORES->( DbGoTop() )
   WHILE !T_VENDEDORES->( EOF() )
      If Empty(Alltrim(T_VENDEDORES->A3_NOME))
         T_VENDEDORES->( DbSkip() )         
         Loop
      Endif   

      If T_TIPOVENDE->A3_TSTAT = '1'
         If Empty(Alltrim(T_TIPOVENDE->A3_OUTR))     
            If T_VENDEDORES->A3_CODUSR == __CuserID
               aAdd( aKVendedores, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )
               Exit
            endif
         Else
            aAdd( aKVendedores, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )                     
         Endif
      Else
         aAdd( aKVendedores, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )            
      Endif
      T_VENDEDORES->( DbSkip() )
   ENDDO

//   cComboBx1 := aKVendedores[1]

   // Desenha a janela do programa
   DEFINE MSDIALOG oDlgK TITLE "Atendimento Call Center - Pesquisa" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgK
   @ C(055),C(279) Jpeg FILE "carrinho.png"   Size C(134),C(028) PIXEL NOBORDER OF oDlgK

   @ C(023),C(400) Say "ATENDIMENTO CALL CENTER"  Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(035),C(005) Say "Filial"                   Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(035),C(044) Say "Dta Inicial"              Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(035),C(084) Say "Dta Final"                Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(035),C(123) Say "Cliente"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(035),C(279) Say "Operador"                 Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(035),C(400) Say "Atendimento"              Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(055),C(005) Say "Legenda"                  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(055),C(123) Say "Ordenação Visualização"   Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(082),C(005) Say "Atendimentos pesquisados" Size C(065),C(008) COLOR CLR_BLACK PIXEL OF oDlgK

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO     Size C(495),C(001) PIXEL OF oDlgK
   @ C(077),C(002) GET oMemo2 Var cMemo2 MEMO     Size C(495),C(001) PIXEL OF oDlgK
   
   @ C(044),C(005) ComboBox cComboBx3 Items aKFiliais    Size C(033),C(010)                              PIXEL OF oDlgK
   @ C(044),C(044) MsGet    oGet1     Var   cKInicial    Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(044),C(084) MsGet    oGet2     Var   cKFinal      Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(044),C(123) MsGet    oGet3     Var   cKCliente    Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK When lChumba
   @ C(044),C(264) Button "..."                          Size C(010),C(009)                              PIXEL OF oDlgK ACTION( KRapidaCli(1) )
   @ C(044),C(279) ComboBox cComboBx1 Items aKVendedores Size C(113),C(010)                              PIXEL OF oDlgK
   @ C(042),C(450) Button "Atualizar"                    Size C(037),C(012)                              PIXEL OF oDlgK ACTION( PAtendCall() )
   @ C(063),C(005) ComboBox cComboBx2 Items aKLegenda    Size C(113),C(010)                              PIXEL OF oDlgK
   @ C(063),C(123) ComboBox cComboBx4 Items aKOrdenacao  Size C(151),C(010)                              PIXEL OF oDlgK
   @ C(044),C(400) MsGet    oGet4     Var   cKAtendi     Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK

   @ C(204),C(005) Button "Produtos do Atendimento"      Size C(074),C(012) PIXEL OF oDlgK ACTION( AbreCCenter(aAtendimento[oAtendimento:nAt,02], aAtendimento[oAtendimento:nAt,03], aAtendimento[oAtendimento:nAt,05], aAtendimento[oAtendimento:nAt,06], aAtendimento[oAtendimento:nAt,07]) )
   @ C(063),C(310) Button "Todas as Vendas"              Size C(045),C(009) PIXEL OF oDlgK ACTION( TodosCallCenter( aAtendimento[oAtendimento:nAt,05], aAtendimento[oAtendimento:nAt,06], aAtendimento[oAtendimento:nAt,07]) )

// @ C(204),C(374) Button "Copiar para Oportunidade"     Size C(084),C(012) PIXEL OF oDlgK ACTION( DuplicaCall(aAtendimento[oAtendimento:nAt,02], aAtendimento[oAtendimento:nAt,03], aAtendimento[oAtendimento:nAt,05], aAtendimento[oAtendimento:nAt,06], aAtendimento[oAtendimento:nAt,07]) ) 
   @ C(204),C(460) Button "Voltar"                       Size C(037),C(012) PIXEL OF oDlgK ACTION( oDlgK:End() )

   If Len(aAtendimento) == 0
      aAdd( aAtendimento, { "1", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif   

   // Cria o grid de visualização da pesquisa
   oAtendimento := TCBrowse():New( 115 , 005, 630, 140,,{'Lg'                         ,; // 01
                                                         'Filial'                     ,; // 02
                                                         'Atendimento'                ,; // 03
                                                         'Data'                       ,; // 04
                                                         'Cliente'                    ,; // 05
                                                         'Loja'                       ,; // 06
                                                         'Descrição dos Clientes'     ,; // 07
                                                         'Contatos'                   ,; // 08
                                                         'Descrição dos Contatos'     ,; // 09
                                                         'Operador'                   ,; // 10
                                                         'Descrição dos Operadores'   ,; // 11
                                                         'Condição Pagamento'       } ,; // 12
                                                          {20,50,50,50},oDlgK,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oAtendimento:SetArray(aAtendimento) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aAtendimento) == 0
   Else
      oAtendimento:bLine := {||{ If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "7", oBranco  ,;
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "1", oVerde   ,;
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "4", oPink    ,;                         
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "3", oAmarelo ,;                         
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "5", oAzul    ,;                         
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "6", oLaranja ,;                         
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "2", oPreto   ,;                         
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "9", oVermelho,;
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "X", oCancel  ,;
                                 If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                                 aAtendimento[oAtendimento:nAt,02]               ,;
                                 aAtendimento[oAtendimento:nAt,03]               ,;
                                 aAtendimento[oAtendimento:nAt,04]               ,;                         
                                 aAtendimento[oAtendimento:nAt,05]               ,;                         
                                 aAtendimento[oAtendimento:nAt,06]               ,;                         
                                 aAtendimento[oAtendimento:nAt,07]               ,;                         
                                 aAtendimento[oAtendimento:nAt,08]               ,;                         
                                 aAtendimento[oAtendimento:nAt,09]               ,;                         
                                 aAtendimento[oAtendimento:nAt,10]               ,;                                                     
                                 aAtendimento[oAtendimento:nAt,11]               ,;                                                     
                                 aAtendimento[oAtendimento:nAt,12]               }}
      
   Endif   

   ACTIVATE MSDIALOG oDlgK CENTERED 

Return(.T.)

// Função que abre a tela do Atendimento de Call Center para visualização
Static Function AbreCCenter(_kFilial, _Atendimento, _KCliente, _KLoja, _KNome)

   Local cSql      := ""
   Local lChumba   := .F.
   Local cJFilial  := _KFilial
   Local cJAtendi  := _Atendimento
   Local cjCliente := _KCliente + "." + _KLoja + " - " + Alltrim(_KNome)

   Local cMemo1	   := ""
   Local cMemo2	   := ""

   Local oGet1
   Local oGet3
   Local oGet4

   Local oMemo1
   Local oMemo2

   Local aProdutos := {}

   If Empty(Alltrim(_Atendimento))
      MsgAlert("Nenhum atendimento selecionado para visualização.")
      Return(.T.)
   Endif   

   Private oDlgPro

   // Pesquisa os produtos do atendimento selecionado para display
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT SUB.UB_ITEM   ,"
   cSql += "       SUB.UB_PRODUTO,"
   cSql += "       SB1.B1_COD    ,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SUB.UB_QUANT  ,"
   cSql += "       SUB.UB_VRUNIT ,"
   cSql += "       SUB.UB_VLRITEM,"
   cSql += "       SUB.UB_DESC   ,"
   cSql += "       SUB.UB_VALDESC,"
   cSql += "       SUB.UB_ACRE   ,"
   cSql += "       SUB.UB_VALACRE,"
   cSql += "       SUB.UB_TES    ,"
   cSql += "       SUB.UB_CF     ,"
   cSql += "       SUB.UB_PRCTAB ,"
   cSql += "       SUB.UB_BASEICM,"
   cSql += "       SUB.UB_LOCAL  ,"
   cSql += "       SUB.UB_UM     ,"
   cSql += "       SUBSTRING(SUB.UB_DTENTRE,07,02) + '/' + SUBSTRING(SUB.UB_DTENTRE,05,02) + '/' + SUBSTRING(SUB.UB_DTENTRE,01,04) AS ENTREGA"
   cSql += "  FROM SUB010 SUB,    "
   cSql += "       SB1010 SB1     "
   cSql += " WHERE SUB.UB_FILIAL  = '" + Alltrim(Substr(_kFilial,01,02)) + "'"
   cSql += "   AND SUB.UB_NUM     = '" + Alltrim(_Atendimento)           + "'"
   cSql += "   AND SUB.D_E_L_E_T_ = ''"
   cSql += "   AND SUB.UB_PRODUTO = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"

   // Executa o SQL elaborado
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      MsgAlert("Não exitem dados a serem visualizados.")
      Return(.T.)
   Endif
   
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
         
      aAdd( aProdutos, { T_PRODUTOS->UB_ITEM   ,;  // 01
                         T_PRODUTOS->UB_PRODUTO,;  // 02
                         T_PRODUTOS->B1_DESC   ,;  // 03
                         T_PRODUTOS->UB_QUANT  ,;  // 04
                         T_PRODUTOS->UB_VRUNIT ,;  // 05
                         T_PRODUTOS->UB_VLRITEM,;  // 06
                         T_PRODUTOS->UB_DESC   ,;  // 07
                         T_PRODUTOS->UB_VALDESC,;  // 08
                         T_PRODUTOS->UB_ACRE   ,;  // 09
                         T_PRODUTOS->UB_VALACRE,;  // 10
                         T_PRODUTOS->UB_TES    ,;  // 11
                         T_PRODUTOS->UB_CF     ,;  // 12
                         T_PRODUTOS->UB_PRCTAB ,;  // 13
                         T_PRODUTOS->UB_BASEICM,;  // 14
                         T_PRODUTOS->UB_LOCAL  ,;  // 15
                         T_PRODUTOS->UB_UM     ,;  // 16
                         T_PRODUTOS->ENTREGA   })  // 17

      T_PRODUTOS->( DbSkip() )
      
   Enddo

   DEFINE MSDIALOG oDlgPro TITLE "Atendimento Call Center - Pesquisa" FROM C(178),C(181) TO C(550),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgPro

   @ C(023),C(310) Say "ATENDIMENTO CALL CENTER" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlgPro
   @ C(057),C(002) GET oMemo2 Var cMemo2 MEMO Size C(385),C(001) PIXEL OF oDlgPro
   
   @ C(035),C(005) Say "Filial"      Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   @ C(035),C(090) Say "Atendimento" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   @ C(035),C(130) Say "Cliente"     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro

   @ C(044),C(005) MsGet oGet4 Var cJFilial  Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro When lChumba
   @ C(044),C(090) MsGet oGet1 Var cJAtendi  Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro When lChumba
   @ C(044),C(130) MsGet oGet3 Var cJCliente Size C(258),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPro When lChumba

   @ C(061),C(005) Say "Produtos do Atendimento" Size C(065),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro

   @ C(170),C(351) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgPro ACTION( oDlgPro:End() )

   // Cria o grid de visualização da pesquisa
   oProduto := TCBrowse():New( 088 , 005, 489, 127,,{'Item'                   ,; // 01
                                                     'Produto'                ,; // 02
                                                     'Descrição dos Produtos' ,; // 03
                                                     'Quantª'                 ,; // 04
                                                     'Preço Unitário'         ,; // 05
                                                     'Valor Item'             ,; // 06
                                                     'Desc.'                  ,; // 07
                                                     'Valor Desconto'         ,; // 08
                                                     'Acréscimo'              ,; // 09
                                                     'Valor Acréscimo'        ,; // 10
                                                     'TES'                    ,; // 11
                                                     'Cod.Fiscal'             ,; // 12
                                                     'Preço Tabela'           ,; // 13
                                                     'Base ICMS'              ,; // 14
                                                     'Armazém'                ,; // 15
                                                     'Unidade'                ,; // 16
                                                     'Data Entrega'         } ,; // 17
                                                     {20,50,50,50},oDlgPro,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oProduto:SetArray(aProdutos) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aProdutos) == 0
   Else
      oProduto:bLine := {||{ aProdutos[oProduto:nAt,01] ,;
                             aProdutos[oProduto:nAt,02] ,;
                             aProdutos[oProduto:nAt,03] ,;
                             aProdutos[oProduto:nAt,04] ,;
                             aProdutos[oProduto:nAt,05] ,;
                             aProdutos[oProduto:nAt,06] ,;
                             aProdutos[oProduto:nAt,07] ,;
                             aProdutos[oProduto:nAt,08] ,;
                             aProdutos[oProduto:nAt,09] ,;
                             aProdutos[oProduto:nAt,10] ,;
                             aProdutos[oProduto:nAt,11] ,;
                             aProdutos[oProduto:nAt,12] ,;
                             aProdutos[oProduto:nAt,13] ,;
                             aProdutos[oProduto:nAt,14] ,;
                             aProdutos[oProduto:nAt,15] ,;
                             aProdutos[oProduto:nAt,16] ,;
                             aProdutos[oProduto:nAt,17] }}
      
   Endif   

   ACTIVATE MSDIALOG oDlgPro CENTERED 

Return(.T.)

// Função que pesquisa os atendimento de call center conforme filtro informado
Static Function PAtendCall()

   Local cSql   := ""

   aAtendimento := {}

   // Pesquisa os atendimentos de call center
   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SUA.UA_STATUS   ," + chr(13) 
   cSql += "       SUA.UA_FILIAL   ," + chr(13) 
   cSql += "       SUA.UA_NUM      ," + chr(13) 
   cSql += "       SUBSTRING(SUA.UA_EMISSAO,07,02) + '/' + SUBSTRING(SUA.UA_EMISSAO,05,02) + '/' + SUBSTRING(SUA.UA_EMISSAO,01,04) AS EMISSAO, " + chr(13) 
   cSql += "       SUA.UA_CLIENTE  ," + chr(13) 
   cSql += "       SUA.UA_LOJA     ," + chr(13) 
   cSql += "       SA1.A1_NOME     ," + chr(13) 
   cSql += "       SUA.UA_CODCONT  ," + chr(13) 
   cSql += "       SUA.UA_DESCNT   ," + chr(13) 
   cSql += "       SUA.UA_VEND     ," + chr(13) 
   cSql += "       SA3.A3_NOME     ," + chr(13) 
   cSql += "       SUA.UA_CONDPG   ," + chr(13)
   cSql += "       SE4.E4_DESCRI    " + chr(13)
   cSql += "  FROM " + RetSqlName("SUA") + " SUA, " + chr(13) 
   cSql += "       " + RetSqlName("SA1") + " SA1, " + chr(13) 
   cSql += "       " + RetSqlName("SA3") + " SA3, " + chr(13) 
   cSql += "       " + RetSqlName("SE4") + " SE4  " + chr(13) 
   cSql += " WHERE SUA.D_E_L_E_T_ = ''" + chr(13) 

   // Filtra pela Filial informada
   cSql += "   AND SUA.UA_FILIAL = '" + Substr(cComboBx3,01,02) + "'" + chr(13) 

   // Filtra pela data inicial e final
   If !Empty(cKInicial)
      cSql += " AND SUA.UA_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cKInicial) + "', 103)" + chr(13) 
      cSql += " AND SUA.UA_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cKFinal)   + "', 103)" + chr(13) 
   Endif
   
   // Filtra pelo Cliente informado
   If !Empty(Alltrim(cKCliente))
      cSql += " AND SUA.UA_CLIENTE = '" + Substr(cKCliente,01,06) + "'" + chr(13) 
      cSql += " AND SUA.UA_LOJA    = '" + Substr(cKCliente,08,03) + "'" + chr(13) 
   Endif

   // Filtra pelo vendedor
   cSql += " AND SUA.UA_VEND    = '" + Substr(cComboBx1,01,06) + "'" + chr(13) 
   cSql += " AND SUA.UA_CONDPG  = SE4.E4_CODIGO" + chr(13) 
   cSql += " AND SE4.D_E_L_E_T_ = ''" + chr(13) 
         
   // Filtra pelo nº do atendimento
   If !Empty(Alltrim(cKAtendi))
      cSql += " AND SUA.UA_NUM = '" + Alltrim(cKAtendi) + "'" + chr(13) 
   Endif

   // Filtra pelos Status
   If Substr(cComboBx2,01,02) <> "00"
      Do Case
         Case Substr(cComboBx2,01,02) == "01"
              cSql += " AND SUA.UA_STATUS = 'SUP'" + chr(13) 
         Case Substr(cComboBx2,01,02) == "02"
              cSql += " AND SUA.UA_STATUS = 'ORC'" + chr(13) 
         Case Substr(cComboBx2,01,02) == "03"
              cSql += " AND SUA.UA_STATUS = 'LIB'" + chr(13) 
         Case Substr(cComboBx2,01,02) == "04"
              cSql += " AND SUA.UA_STATUS = 'NF.'" + chr(13) 
         Case Substr(cComboBx2,01,02) == "05"
              cSql += " AND SUA.UA_STATUS = 'CAN'" + chr(13) 
       EndCase
   Endif
   
   cSql += "   AND SUA.UA_CLIENTE = SA1.A1_COD " + chr(13) 
   cSql += "   AND SUA.UA_LOJA    = SA1.A1_LOJA" + chr(13) 
   cSql += "   AND SA3.A3_COD     = SUA.UA_VEND" + chr(13) 
   cSql += "   AND SA3.D_E_L_E_T_ = ''         " + chr(13) 

   Do Case
      Case Substr(cComboBx4,01,02) == "01"
           cSql += " ORDER BY SUA.UA_NUM" + chr(13) 
      Case Substr(cComboBx4,01,02) == "02"
           cSql += " ORDER BY SUA.UA_EMISSAO" + chr(13) 
      Case Substr(cComboBx4,01,02) == "03"
           cSql += " ORDER BY SUA.UA_CLIENTE, SUA.UA_LOJA" + chr(13) 
      Case Substr(cComboBx4,01,02) == "04"
           cSql += " ORDER BY SUA.UA_DESCNT" + chr(13) 
      Case Substr(cComboBx4,01,02) == "05"                        
           cSql += " ORDER BY SA3.A3_NOME" + chr(13) 
   EndCase

   // Executa o SQL elaborado
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )

   T_PEDIDOS->( DbGoTop() )
   
   WHILE !T_PEDIDOS->( EOF() )

      // Elabora a Legenda
      Do Case
         Case T_PEDIDOS->UA_STATUS == "SUP"
              __Legenda := "X"
         Case T_PEDIDOS->UA_STATUS == "ORC"
              __Legenda := "5"
         Case T_PEDIDOS->UA_STATUS == "LIB"
              __Legenda := "1"
         Case T_PEDIDOS->UA_STATUS == "NF."
              __Legenda := "9"
         Case T_PEDIDOS->UA_STATUS == "CAN"
              __Legenda := "2"
      EndCase              

      // Elabora o nome da Filial
      Do Case
         Case T_PEDIDOS->UA_FILIAL == "01"
              __Filial := "01 - PORTO ALEGRE"
         Case T_PEDIDOS->UA_FILIAL == "02"
              __Filial := "02 - CAXIAS DO SUL"
         Case T_PEDIDOS->UA_FILIAL == "03"
              __Filial := "03 - PELOTAS"
         Case T_PEDIDOS->UA_FILIAL == "04"
              __Filial := "04 - SUPRIMENTOS"
         Otherwise
              __Filial := "99 - INDEFINIDO"
      EndCase                

      // Carrega o array aAtendimento
      aAdd( aAtendimento, { __Legenda            ,; // 01
                            __Filial             ,; // 02 
                            T_PEDIDOS->UA_NUM    ,; // 03
                            T_PEDIDOS->EMISSAO   ,; // 04
                            T_PEDIDOS->UA_CLIENTE,; // 05
                            T_PEDIDOS->UA_LOJA   ,; // 06
                            T_PEDIDOS->A1_NOME   ,; // 07
                            T_PEDIDOS->UA_CODCONT,; // 08
                            T_PEDIDOS->UA_DESCNT ,; // 09
                            T_PEDIDOS->UA_VEND   ,; // 10
                            T_PEDIDOS->A3_NOME   ,; // 11
                            T_PEDIDOS->E4_DESCRI }) // 12

     T_PEDIDOS->( DbSkip() )
     
  ENDDO
  
  // Se array aAtendimento vazio, inciializa o array aAtendimento com um registro em branco
  If Len(aAtendimento) == 0
     aAdd( aAtendimento, { "7", "", "", "", "", "", "", "", "", "", "", "" } )
  Endif
  
  // Seta vetor para a browse                            
  oAtendimento:SetArray(aAtendimento) 
    
  // Monta a linha a ser exibina no Browse
  oAtendimento:bLine := {||{ If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "7", oBranco  ,;
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "1", oVerde   ,;
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "4", oPink    ,;                         
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "3", oAmarelo ,;                         
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "5", oAzul    ,;                         
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "6", oLaranja ,;                         
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "2", oPreto   ,;                         
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "9", oVermelho,;
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "X", oCancel  ,;
                             If(Alltrim(aAtendimento[oAtendimento:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                             aAtendimento[oAtendimento:nAt,02]               ,;
                             aAtendimento[oAtendimento:nAt,03]               ,;
                             aAtendimento[oAtendimento:nAt,04]               ,;                         
                             aAtendimento[oAtendimento:nAt,05]               ,;                         
                             aAtendimento[oAtendimento:nAt,06]               ,;                         
                             aAtendimento[oAtendimento:nAt,07]               ,;                         
                             aAtendimento[oAtendimento:nAt,08]               ,;                         
                             aAtendimento[oAtendimento:nAt,09]               ,;                         
                             aAtendimento[oAtendimento:nAt,10]               ,;                                                     
                             aAtendimento[oAtendimento:nAt,11]               ,;                                                     
                             aAtendimento[oAtendimento:nAt,12]               }}
   
Return(.T.)

// Função: PRAPIDACLI - Função que pesquisa clientes
Static Function KRapidaCli()

   Local cMemo1	      := ""
   Local oMemo1

   Private cString	  := Space(100)
   Private cCadastro  := ""
   Private cCampo     := ReadVar()
   Private cCodLoja   := ReadVar()

   Private aCampo  	  := {"01 - Nome", "02 - Código", "03 - CNPJ/CPF", "04 - Município"}
   Private aOperador  := {"01 - Igual", "02 - Iniciando", "03 - Contendo"}
   Private aOrdenacao := {"01 - Por Código", "02 - Por Nome", "03 - Por CNPJ/CPF", "04 - Município"}

   Private oGet1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private aBrowse := {}

   Private oDlg

   // Declara as Legendas
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

   // Limpa a variável que recebe o código do cliente
   cCliente := ""

   // Inicializa o conteúdo do combo
   cComboBx3 := "03 - Contendo"
   cComboBx4 := "02 - Por Nome"
   
   DEFINE MSDIALOG oDlg TITLE "Pesquisa Cadastro de Entidades" FROM C(178),C(181) TO C(602),C(909) PIXEL

   @ C(008),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg
   @ C(197),C(085) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(197),C(154) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(043),C(002) GET oMemo1 Var cMemo1 MEMO Size C(357),C(001) PIXEL OF oDlg
   
   @ C(006),C(138) Say "String a Pesquisar"   Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(138) Say "Ordenação Pesquisa"   Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(019),C(138) Say "Pesquisar pelo Campo" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(269) Say "Operação"             Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(097) Say "Sem pendências financeiras" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(166) Say "Com pendências financeiras" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(193) MsGet oGet1 Var cString  Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(003),C(323) Button "Pesquisar"       Size C(037),C(012) PIXEL OF oDlg ACTION( kbuscaCli() )

   @ C(018),C(193) ComboBox cComboBx2 Items aCampo     Size C(071),C(010) PIXEL OF oDlg
   @ C(018),C(295) ComboBox cComboBx3 Items aOperador  Size C(065),C(010) PIXEL OF oDlg
   @ C(029),C(193) ComboBox cComboBx4 Items aOrdenacao Size C(168),C(010) PIXEL OF oDlg

   @ C(195),C(005) Button "Visualizar Cadastro" Size C(063),C(012) PIXEL OF oDlg ACTION( kCadCliente( aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], "", aBrowse[oBrowse:nAt,01]) )
   @ C(195),C(283) Button "Selecionar"          Size C(037),C(012) PIXEL OF oDlg ACTION( kSelCliente( aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,01]) )
   @ C(195),C(322) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( kSelCliente( "", "", "", "") )

   aAdd( aBrowse, { "1", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 062 , 005, 456, 182,,{"LG", "Código", "Loja", "Descrição", "CNPJ/CPF", "Município", "UF"}, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowse) == 0
   Else
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
                            aBrowse[oBrowse:nAt,02]               ,;
                            aBrowse[oBrowse:nAt,03]               ,;
                            aBrowse[oBrowse:nAt,04]               ,;
                            aBrowse[oBrowse:nAt,05]               ,;
                            aBrowse[oBrowse:nAt,06]               }}

   Endif   

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que fecha a janela pelo botão selecionar e transfere código e loja selecionados
Static Function kSelCliente(_Codigo, _Loja, _NomeCli, _Legenda)
   
   oDlg:End()

   If Empty(Alltrim(_Codigo))
      cKCliente := "                    "
   Else
      cKCliente := _Codigo + "." + _Loja + " - " + Alltrim(_NomeCli)
   Endif   

Return(.T.)

// Função que pesquisa o cliente informado
Static Function kbuscaCli()

   Local cSql   := ""

   aArea := GetArea()
   
   aBrowse := {}

   If Len(Alltrim(cString)) == 0
      aAdd( aBrowse, { '1', '', '', '', '', '', '' } )
      oBrowse:SetArray(aBrowse) 
      Return .T.
   Endif   

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.A1_COD ," + chr(13)
   cSql += "       A.A1_LOJA," + chr(13)
   cSql += "       A.A1_NOME," + chr(13)
   cSql += "       CASE WHEN LEN(A.A1_CGC) = 14  THEN SUBSTRING(A.A1_CGC,01,02) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,03,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,06,03) + '/' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,09,04) + '-' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,13,02)        " + chr(13)
   cSql += "            WHEN LEN(A.A1_CGC) <> 14 THEN SUBSTRING(A.A1_CGC,01,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,04,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,07,03) + '-' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,10,02)        " + chr(13)
   cSql += "       END AS CGC," + chr(13)
   cSql += "       A.A1_MUN  ," + chr(13)
   cSql += "       A.A1_EST   " + chr(13)
   cSql += "  FROM " + RetSqlName("SA1") + " A " + chr(13)
   cSql += " WHERE A.D_E_L_E_T_ = ''"   + chr(13)

   Do Case

      // Nome
      Case Substr(cComboBx2,01,02) = "01"
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND A.A1_NOME = '" + Alltrim(cString) + "'" + CHR(13)
              // Iniciando
              Case Substr(cComboBx3,01,02) == "02" 
                   cSql += " AND A.A1_NOME LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND A.A1_NOME LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // Código
      Case Substr(cComboBx2,01,02) = "02"
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND A.A1_COD = '" + Alltrim(cString) + "'" + CHR(13)
              // Iniciando
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += " AND A.A1_COD  LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND A.A1_COD  LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // CNPJ/CPF
      Case Substr(cComboBx2,01,02) = "03"
           Do Case
              Case Substr(cComboBx3,01,02) == "01" // Igual
                   cSql += " AND A.A1_CGC = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx3,01,02) == "02" // Iniciando
                   cSql += " AND A.A1_CGC LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx3,01,02) == "03" // Contendo
                   cSql += " AND A.A1_CGC LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // Município
      Case Substr(cComboBx2,01,02) = "04" 
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND A.B1_POSIPI = '" + Alltrim(cPesquisa) + "'" + CHR(13)
              // Inicando
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += " AND A.B1_POSIPI LIKE '" + Alltrim(cPesquisa) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND A.B1_POSIPI LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
           EndCase                   

   EndCase

   // Ordenação
   Do Case
      // Código
      Case Substr(cComboBx4,01,02) == "01"
           cSql += " ORDER BY A.A1_COD, A.A1_LOJA" + CHR(13)
      // Descrição
      Case Substr(cComboBx4,01,02) == "02" 
           cSql += " ORDER BY A.A1_NOME" + CHR(13)
      // Part Number
      Case Substr(cComboBx4,01,02) == "03" 
           cSql += " ORDER BY A.A1_CGC" + CHR(13)
      // NCM
      Case Substr(cComboBx4,01,02) == "04" 
           cSql += " ORDER BY A.A1_MUN" + CHR(13)
   EndCase                   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aBrowse, { '1', '', '', '', '', '', '' } )
   Else

      T_CLIENTE->( DbGoTop() )

      WHILE !T_CLIENTE->( EOF() )

         // Pesquisa possíveis parcelas em atraso
         If Select("T_PARCELAS") > 0
            T_PARCELAS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.E1_CLIENTE ,"
         cSql += "       A.E1_LOJA    ,"
         cSql += "       A.E1_PREFIXO ,"
         cSql += "       A.E1_NUM     ,"
         cSql += "       A.E1_PARCELA ,"
         cSql += "       A.E1_EMISSAO ,"
         cSql += "       A.E1_VENCTO  ,"
         cSql += "       A.E1_BAIXA   ,"
         cSql += "       A.E1_VALOR   ,"
         cSql += "       A.E1_SALDO    "
         cSql += "  FROM " + RetSqlName("SE1") + " A "
         cSql += " WHERE A.D_E_L_E_T_ = ''"
         cSql += "   AND A.E1_SALDO  <> 0 "
         cSql += "   AND A.E1_CLIENTE = '" + Alltrim(T_CLIENTE->A1_COD)   + "'"
         cSql += "   AND A.E1_LOJA    = '" + Alltrim(T_CLIENTE->A1_LOJA)  + "'"
         cSql += "   AND A.E1_VENCTO < CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
         cSql += "   AND (A.E1_TIPO   <> 'RA' AND A.E1_TIPO <> 'NCC')"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

         If T_PARCELAS->( EOF() )
            _Devedor := "2"
         Else
            _Devedor := "8"         
         Endif

         aAdd( aBrowse, { _Devedor                      ,;
                          T_CLIENTE->A1_COD             ,;
                          T_CLIENTE->A1_LOJA            ,;
                          T_CLIENTE->A1_NOME + Space(50),;
                          T_CLIENTE->CGC     + Space(10),;
                          T_CLIENTE->A1_MUN  + Space(30),;
                          T_CLIENTE->A1_EST             })

         T_CLIENTE->( DbSkip() )

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
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;
                         aBrowse[oBrowse:nAt,05]               ,;
                         aBrowse[oBrowse:nAt,06]               }}

   RestArea( aArea )

Return(.T.)

// Função que visualiza o cadastro do cliente selecionado
Static Function kCadCliente(_Codigo, _Loja)

   If Empty(Alltrim(_Codigo))
      MsgAlert("Necessário selecione um cliente para realizar esta operação.")
      Return(.T.)
   Endif

   aArea := GetArea()
   
   // Posiciona no cliente a ser pesquisado
   DbSelectArea("SUA")
   DbSetOrder(1)
   DbSeek(xFilial("SA1") + _Codigo + _Loja)

   AxVisual("SA1", SA1->( Recno() ), 1)

Return(.T.)

// Função que realiza a duplicação do atendimento de call center para oportunidade de venda
Static Function DuplicaCall( _tFilial, _tOportunidade, _tCliente, _tLoja, _tNomeCli)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private hFilial	     := Substr(_tFilial,01,02)
   Private hOportunidade := _tOportunidade
   Private hCliente      := _tCliente + "." + _tLoja + " - " + Alltrim(_tNomeCli)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgU

   DEFINE MSDIALOG oDlgU TITLE "Cópia de Oportunidade" FROM C(178),C(181) TO C(411),C(622) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgU

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(213),C(001) PIXEL OF oDlgU
   @ C(096),C(002) GET oMemo2 Var cMemo2 MEMO Size C(213),C(001) PIXEL OF oDlgU

   @ C(038),C(005) Say "Este processo tem por finalidade de realizar a duplicação de um atendimento para uma oportunidade de venda." Size C(212),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(054),C(005) Say "Confirme os dados para duplicação" Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(071),C(005) Say "Filial"                            Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(071),C(025) Say "Atendimento Nº"                    Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgU
   @ C(071),C(063) Say "Cliente"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgU

   @ C(080),C(005) MsGet oGet1 Var hFilial       Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgU When lChumba
   @ C(080),C(025) MsGet oGet2 Var hOportunidade Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgU When lChumba
   @ C(080),C(063) MsGet oGet3 Var hCliente      Size C(152),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgU When lChumba

   @ C(100),C(138) Button "Confimar" Size C(037),C(012) PIXEL OF oDlgU ACTION( COPIAOCALL(hFilial, hOportunidade, hCliente) )
   @ C(100),C(177) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgU ACTION( oDlgU:End() )

   ACTIVATE MSDIALOG oDlgU CENTERED 

Return(.T.)

// Função que duplica a oportunidade selecionada
Static Function CopiaCall( _hFilial, _hOportunidade, _hCliente)

   Local cSql := ""
 
   Private INCLUI
   Private ALTERA

   If !MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente duplicar o Atendimento selecionado?")
      Return(.T.)
   Endif
   
   // Pesquisa os dados a serem utilizados para duplicação
   If Select("T_OPORTUNIDADE") > 0
      T_OPORTUNIDADE->( dbCloseArea() )
   EndIf
        
   // Pesquisa a oportunidade a ser utilizada para a duplicação
   cSql := ""
   cSql := "SELECT UA_FILIAL,"
   cSql += "       UA_NUM   ,"
   cSql += "       AD1_REVISA,"
   cSql += "       AD1_DESCRI,"
   cSql += "       AD1_DTINI ,"
   cSql += "       AD1_DTFIM ,"
   cSql += "       AD1_VEND  ,"
   cSql += "       AD1_VEND2 ,"
   cSql += "       AD1_DATA  ,"
   cSql += "       AD1_HORA  ,"
   cSql += "       AD1_CODCLI,"
   cSql += "       AD1_LOJCLI,"
   cSql += "       AD1_MOEDA ,"
   cSql += "       AD1_PROVEN,"
   cSql += "       AD1_STAGE ,"
   cSql += "       AD1_PRIOR ,"
   cSql += "       AD1_STATUS,"
   cSql += "       AD1_USER  ,"
   cSql += "       AD1_VERBA ,"
   cSql += "       AD1_MODO  ,"
   cSql += "       AD1_COMIS1,"
   cSql += "       AD1_COMIS2 "
   cSql += "  FROM " + RetSqlName("AD1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND AD1_FILIAL = '" + Alltrim(_hFilial)       + "'"
   cSql += "   AND AD1_NROPOR = '" + Alltrim(_hOportunidade) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OPORTUNIDADE", .T., .T. )

   If T_OPORTUNIDADE->( EOF() )
      MsgAlert("Não existem dados a serem utilizados para duplicação.")
      Return(.T.)
   Endif
       
   Num_Proposta     := T_OPORTUNIDADE->AD1_NROPOR
   Num_Oportunidade := Ft300Num()

   BEGIN TRANSACTION
   
   // ----------------------------- //
   // Duplicação proposta comercial //
   // ----------------------------- // 
   k_Proposta := GetSXENum( "ADY", "ADY_PROPOS" ) 

   // Inclui a nova opotunidade
   aArea := GetArea()
   dbSelectArea("AD1")
   RecLock("AD1",.T.)
   AD1_FILIAL := T_OPORTUNIDADE->AD1_FILIAL
   AD1_NROPOR := Num_Oportunidade
   AD1_REVISA := "01"
   AD1_DESCRI := T_OPORTUNIDADE->AD1_DESCRI
   AD1_DTINI  := DATE()
   AD1_DTFIM  := DATE()
   AD1_VEND   := T_OPORTUNIDADE->AD1_VEND
   AD1_VEND2  := T_OPORTUNIDADE->AD1_VEND2
   AD1_DATA   := DATE()
   AD1_HORA   := TIME()
   AD1_CODCLI := T_OPORTUNIDADE->AD1_CODCLI
   AD1_LOJCLI := T_OPORTUNIDADE->AD1_LOJCLI
   AD1_MOEDA  := T_OPORTUNIDADE->AD1_MOEDA
   AD1_PROVEN := T_OPORTUNIDADE->AD1_PROVEN
   AD1_STAGE  := T_OPORTUNIDADE->AD1_STAGE
   AD1_PRIOR  := T_OPORTUNIDADE->AD1_PRIOR
   AD1_STATUS := "1"
   AD1_USER   := T_OPORTUNIDADE->AD1_USER
   AD1_VERBA  := T_OPORTUNIDADE->AD1_VERBA
   AD1_MODO   := T_OPORTUNIDADE->AD1_MODO
   AD1_COMIS1 := T_OPORTUNIDADE->AD1_COMIS1
   AD1_COMIS2 := T_OPORTUNIDADE->AD1_COMIS2
   AD1_PROPOS := k_Proposta
   MsUnLock()    

   // Cria variáveis de memória com a tabela ADY - Proposta Comercial
   DbSelectArea("ADY")
   DbSetorder(2)
   If !DbSeek(_hFilial + _hOportunidade)
      Return(.T.)   
   Else
      xADY_FILIAL := ADY->ADY_FILIAL
      xADY_PROPOS := k_Proposta
      xADY_OPORTU := Num_Oportunidade
      xADY_REVISA := ADY->ADY_REVISA
      xADY_ENTIDA := ADY->ADY_ENTIDA
      xADY_CODIGO := ADY->ADY_CODIGO
      xADY_LOJA   := ADY->ADY_LOJA
      xADY_TABELA := ADY->ADY_TABELA
      xADY_ORCAME := ADY->ADY_ORCAME
      xADY_STATUS := ADY->ADY_STATUS
      xADY_DATA   := ADY->ADY_DATA
      xADY_VAL    := ADY->ADY_VAL
      xADY_OBSP   := ADY->ADY_OBSP
      xADY_OBSI   := ADY->ADY_OBSI
      xADY_TRANSP := ADY->ADY_TRANSP
      xADY_TPFRET := ADY->ADY_TPFRET
      xADY_PARAQ  := ADY->ADY_PARAQ
      xADY_ENTREG := ADY->ADY_ENTREG
      xADY_FRETE  := ADY->ADY_FRETE
      xADY_OC     := ADY->ADY_OC
      xADY_FCOR   := ADY->ADY_FCOR
      xADY_TSRV   := ADY->ADY_TSRV
      xADY_FORMA  := ADY->ADY_FORMA
      xADY_ADM    := ADY->ADY_ADM
   Endif

   // Inclui a Proposta Comercial
   aArea := GetArea()
   dbSelectArea("ADY")
   RecLock("ADY",.T.)
   ADY_FILIAL := xADY_FILIAL
   ADY_PROPOS := k_Proposta
   ADY_OPORTU := Num_Oportunidade
   ADY_REVISA := xADY_REVISA
   ADY_ENTIDA := xADY_ENTIDA
   ADY_CODIGO := xADY_CODIGO
   ADY_LOJA   := xADY_LOJA
   ADY_TABELA := xADY_TABELA
   ADY_ORCAME := xADY_ORCAME
   ADY_STATUS := xADY_STATUS
   ADY_DATA   := xADY_DATA
   ADY_VAL    := xADY_VAL
   ADY_OBSP   := xADY_OBSP
   ADY_OBSI   := xADY_OBSI
   ADY_TRANSP := xADY_TRANSP
   ADY_TPFRET := xADY_TPFRET
   ADY_PARAQ  := xADY_PARAQ
   ADY_ENTREG := xADY_ENTREG
   ADY_FRETE  := xADY_FRETE
   ADY_OC     := xADY_OC
   ADY_FCOR   := xADY_FCOR
   ADY_TSRV   := xADY_TSRV
   ADY_FORMA  := xADY_FORMA
   ADY_ADM    := xADY_ADM
   MsUnLock()    

   // Confirma o número alocado através do último comando GETSXENUM()
   ConfirmSX8(.T.) // Se o parâmetro for passado como (.T.) verifica se o número já existe na base de dados.
      
   // Inclui os produtos da Proposta Comercial
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ADZ_FILIAL,"	
   cSql += "       ADZ_ITEM	 ,"
   cSql += "       ADZ_PRODUT,"	
   cSql += "       ADZ_DESCRI,"	
   cSql += "       ADZ_UM	 ,"
   cSql += "       ADZ_MOEDA ,"	
   cSql += "       ADZ_CONDPG,"	
   cSql += "       ADZ_QTDVEN,"	
   cSql += "       ADZ_PRCVEN,"	
   cSql += "       ADZ_PRCTAB,"	
   cSql += "       ADZ_TOTAL ,"	
   cSql += "       ADZ_DESCON,"	
   cSql += "       ADZ_VALDES,"	
   cSql += "       ADZ_PMS   ,"
   cSql += "       ADZ_DT1VEN,"	
   cSql += "       ADZ_ITEMOR,"	
   cSql += "       ADZ_ORCAME,"	
   cSql += "       ADZ_PROPOS,"	
   cSql += "       ADZ_ITPAI ,"
   cSql += "       ADZ_FOLDER,"	
   cSql += "       ADZ_TES	 ,"
   cSql += "       ADZ_COMIS1,"	
   cSql += "       ADZ_COMIS2,"	
   cSql += "       ADZ_QTGMRG,"	
   cSql += "       ADZ_LACRE ,"
   cSql += "       ADZ_MARGEM,"	
   cSql += "       ADZ_ORDC	 ,"
   cSql += "       ADZ_ORDA	 ,"
   cSql += "       ADZ_ORDS  ,"
   cSql += "       ADZ_DEVO   "
   cSql += "  FROM " + RetSqlName("ADZ")
   cSql += " WHERE ADZ_FILIAL = '" + Alltrim(_hFilial)     + "'"
   cSql += "   AND ADZ_PROPOS = '" + Alltrim(Num_Proposta) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   // Inclui nova proposta comercial
   aArea := GetArea()
   dbSelectArea("ADZ")
   RecLock("ADZ",.T.)
   ADZ_FILIAL := T_PRODUTOS->ADZ_FILIAL 
   ADZ_ITEM	  := T_PRODUTOS->ADZ_ITEM
   ADZ_PRODUT := T_PRODUTOS->ADZ_PRODUT
   ADZ_DESCRI := T_PRODUTOS->ADZ_DESCRI
   ADZ_UM	  := T_PRODUTOS->ADZ_UM
   ADZ_MOEDA  := T_PRODUTOS->ADZ_MOEDA
   ADZ_CONDPG := T_PRODUTOS->ADZ_CONDPG
   ADZ_QTDVEN := T_PRODUTOS->ADZ_QTDVEN
   ADZ_PRCVEN := T_PRODUTOS->ADZ_PRCVEN
   ADZ_PRCTAB := T_PRODUTOS->ADZ_PRCTAB
   ADZ_TOTAL  := T_PRODUTOS->ADZ_TOTAL
   ADZ_DESCON := T_PRODUTOS->ADZ_DESCON
   ADZ_VALDES := T_PRODUTOS->ADZ_VALDES
   ADZ_PMS	  := T_PRODUTOS->ADZ_PMS
   ADZ_DT1VEN := Stod(T_PRODUTOS->ADZ_DT1VEN)
   ADZ_ITEMOR := T_PRODUTOS->ADZ_ITEMOR
   ADZ_ORCAME := T_PRODUTOS->ADZ_ORCAME
   ADZ_PROPOS := k_Proposta
   ADZ_ITPAI  := T_PRODUTOS->ADZ_ITPAI
   ADZ_FOLDER := T_PRODUTOS->ADZ_FOLDER
   ADZ_TES	  := T_PRODUTOS->ADZ_TES
   ADZ_COMIS1 := T_PRODUTOS->ADZ_COMIS1
   ADZ_COMIS2 := T_PRODUTOS->ADZ_COMIS2
   ADZ_QTGMRG := T_PRODUTOS->ADZ_QTGMRG
   ADZ_LACRE  := T_PRODUTOS->ADZ_LACRE
   ADZ_MARGEM := T_PRODUTOS->ADZ_MARGEM
   ADZ_ORDC   := T_PRODUTOS->ADZ_ORDC
   ADZ_ORDA   := T_PRODUTOS->ADZ_ORDA
   ADZ_ORDS   := T_PRODUTOS->ADZ_ORDS
   ADZ_DEVO   := Stod(T_PRODUTOS->ADZ_DEVO)
   MsUnLock()    

   END TRANSACTION

   MsgAlert("Duplicação da Oportunidade realizada com sucesso." + chr(13) + chr(10) + chr(13) + chr(10) + "Nº Oportunidade: " + Alltrim(Num_Oportunidade) + chr(13) + Chr(10) + "Nº Proposta Comercial: " + Alltrim(K_Proposta))
 
   oDlgU:End()

Return(.T.)

// Função que mostra todas as vendas efetuadas para o Cliente selecionado
Static Function TodosCallCenter( xx_Cliente, xx_Loja, xx_Nome )

   Local cSql      := ""
   Local lChumba   := .F.
   Local cDadosCli := xx_cliente + "." + xx_Loja + " - " + Alltrim(xx_Nome)
   Local cMemo1	   := ""
   Local oGet1
   Local oMemo1
   
   Private aVendas := {}

   Private oDlgVDA

   If Empty(Alltrim(xx_Cliente))
      MsgAlert("Nenhum pedido de venda selecionado para realizar a pesquisa.")
      Return(.T.)
   Endif

   If Select("T_VENDAS") > 0
  	  T_VENDAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UB_FILIAL ,"
   cSql += "       B.UA_EMISSAO,"
   cSql += "       A.UB_NUMPV  ,"
   cSql += "       C.C6_NOTA   ,"
   cSql += "       C.C6_SERIE  ,"
   cSql += "       A.UB_ITEM   ,"
   cSql += "       A.UB_PRODUTO,"
   cSql += "       D.B1_DESC AS DESCRICAO,"
   cSql += "       A.UB_QUANT  ,"
   cSql += "       A.UB_VRUNIT ,"
   cSql += "       A.UB_VLRITEM,"
   cSql += "       B.UA_VEND   ,"
   cSql += "       E.A3_NOME    "
   cSql += "  FROM " + RetSqlName("SUB") +" A,"
   cSql += "       " + RetSqlName("SUA") +" B,"
   cSql += "       " + RetSqlName("SC6") +" C,"
   cSql += "       " + RetSqlName("SB1") +" D,"
   cSql += "       " + RetSqlName("SA3") +" E "
   cSql += " WHERE B.UA_FILIAL  = A.UB_FILIAL "
   cSql += "   AND B.UA_NUM     = A.UB_NUM    "
   cSql += "   AND B.UA_CLIENTE = '" + Alltrim(xx_cliente) + "'"
   cSql += "   AND B.UA_LOJA    = '" + Alltrim(xx_loja)    + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''          "
   cSql += "   AND B.D_E_L_E_T_ = ''          "
   cSql += "   AND C.C6_FILIAL  = A.UB_FILIAL "
   cSql += "   AND C.C6_NUM     = A.UB_NUMPV  "
   cSql += "   AND C.D_E_L_E_T_ = ''          "
   cSql += "   AND D.B1_FILIAL  = ''          "
   cSql += "   AND D.B1_COD     = A.UB_PRODUTO"
   cSql += "   AND D.D_E_L_E_T_ = ''          "
   cSql += "   AND E.A3_FILIAL  = ''          "
   cSql += "   AND E.A3_COD     = B.UA_VEND   "
   cSql += " ORDER BY A.UB_FILIAL, B.UA_EMISSAO, A.UB_NUMPV, A.UB_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDAS", .T., .T. )

   aVendas := {}
   
   T_VENDAS->( DbGoTop() )
   
   WHILE !T_VENDAS->( EOF() )
   
      aAdd( aVendas, {T_VENDAS->UB_FILIAL ,;
                      SUBSTR(T_VENDAS->UA_EMISSAO,07,02) + "/" + SUBSTR(T_VENDAS->UA_EMISSAO,05,02) + "/" + SUBSTR(T_VENDAS->UA_EMISSAO,01,04) ,;
                      T_VENDAS->UB_NUMPV  ,;
                      T_VENDAS->C6_NOTA   ,;
                      T_VENDAS->C6_SERIE  ,;
                      T_VENDAS->UB_ITEM   ,;
                      T_VENDAS->UB_PRODUTO,;
                      T_VENDAS->DESCRICAO ,;
                      T_VENDAS->UB_QUANT  ,;
                      T_VENDAS->UB_VRUNIT ,;
                      T_VENDAS->UB_VLRITEM,;
                      T_VENDAS->UA_VEND   ,;
                      T_VENDAS->A3_NOME } )                      
                      
      T_VENDAS->( DbSkip() )
      
   ENDDO
  
   DEFINE MSDIALOG oDlgVDA TITLE "Relação de vendas efetuadas a Cliente" FROM C(178),C(181) TO C(603),C(967) PIXEL

   @ C(002),C(005) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgVDA

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlgVDA

   @ C(034),C(005) Say "Relação de todas as vendas efetuadas para o cliente" Size C(129),C(008) COLOR CLR_BLACK PIXEL OF oDlgVDA

   @ C(043),C(005) MsGet oGet1 Var cDadosCli Size C(383),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgVDA When lChumba

   @ C(196),C(351) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgVDA ACTION( oDlgVDA:End() )

   // Inicializa o browse 
   oVendas := TCBrowse():New( 075 , 005, 490, 170,,{'Fl', 'Data', 'Nº PV', 'N.Fiscal', 'Série', 'Item', 'Código', 'Descrição dos Produtos', 'Qtd', 'Unitário', 'Total', 'Vendedor', 'Descrição Vendedores'}, {20,50,50,50},oDlgVDA,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oVendas:SetArray(aVendas) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aVendas) == 0
      aAdd( aVendas, { "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   oVendas:bLine := {||{aVendas[oVendas:nAt,01],;
                        aVendas[oVendas:nAt,02],;
                        aVendas[oVendas:nAt,03],;
                        aVendas[oVendas:nAt,04],;
                        aVendas[oVendas:nAt,05],;
                        aVendas[oVendas:nAt,06],;
                        aVendas[oVendas:nAt,07],;
                        aVendas[oVendas:nAt,08],;
                        aVendas[oVendas:nAt,09],;
                        aVendas[oVendas:nAt,10],;
                        aVendas[oVendas:nAt,11],;
                        aVendas[oVendas:nAt,12],;                                                
                        aVendas[oVendas:nAt,13]}}
      
   oVendas:Refresh()

   ACTIVATE MSDIALOG oDlgVDA CENTERED 

Return(.T.)