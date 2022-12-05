#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MT120GRV.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/08/2012                                                          *
// Objetivo..: Ponto de Entrada disparado no botão confirmar do Pedido de Compra.  *
//             Utilizado para abrir a janela de solicitação da transportadora  do  *
//             Pedido de Compra.                                                   *
//             Este ponto de entrada trata também do desconto financeiro do pedi-  *
//             do de compra.
// Parâmetros: Sem Parâmetros                                                      *
//**********************************************************************************

User Function MT120GRV()

   Local cSql    := ""
   Local lChumba := .F.

   Private cPedido   := SC7->C7_NUM
   Private cFornec   := SC7->C7_FORNECE
   Private cLoja     := SC7->C7_LOJA
   Private cNomeF    := Space(40)
   Private cTransp   := SC7->C7_TRANSP
   Private cNomeT    := Space(40)
   Private cValorSub := 0
   Private cValorIpi := 0
   Private cValorFin := 0
   Private cValorTot := 0
   Private cLinha    := ""
   Private lemail	 := .F.

   Private oGet1
   Private oGet10
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oMemo1
   Private oCheckBox1

   Private oDlg

   Private _Medicao
   
   Default _Medicao := .F.

   U_AUTOM628("MT120GRV")

   If _Medicao 
      return .t.
   endif

   // Pesquisa o nome do Fornecedor
   If Select("T_FORNECE") > 0
      T_FORNECE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_NOME"
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_COD       = '" + Alltrim(cFornec) + "'"
   cSql += "   AND A2_LOJA      = '" + Alltrim(cLoja)   + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECE", .T., .T. )

   cNomeF := IIF(T_FORNECE->( EOF() ), "", T_FORNECE->A2_NOME)

   // Pesquisa o nome da Transportadora
   If !Empty(Alltrim(cTransp))
      If Select("T_FRETE") > 0
         T_FRETE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A4_NOME"
      cSql += "  FROM " + RetSqlName("SA4")
      cSql += " WHERE A4_COD       = '" + Alltrim(cTransp) + "'"
      cSql += "   AND R_E_C_D_E_L_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FRETE", .T., .T. )

      cNomeT := IIF(T_FRETE->( EOF() ), "", T_FRETE->A4_NOME)
   Endif   

   // Pesquisa os totais do Pedido de Compra para display
   If Select("T_TOTAIS") > 0
      T_TOTAIS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C7_NUM                 ,"
   cSql += "       SUM(C7_TOTAL)  AS TOTAL," 
   cSql += "       SUM(C7_VALIPI) AS IPI   "
   cSql += "  FROM " + RetSqlName("SC7")
   cSql += " WHERE C7_NUM    = '" + Alltrim(cPedido) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY C7_NUM      "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TOTAIS", .T., .T. )

   // Pesquisa o valor do desconto financeiro
   If Select("T_DESCONTO") > 0
      T_DESCONTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT C7_DFIN"
   cSql += "  FROM " + RetSqlName("SC7")
   cSql += " WHERE C7_NUM     = '" + Alltrim(cPedido) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESCONTO", .T., .T. )
   
   // Carrega os totais
   cValorSub := T_TOTAIS->TOTAL
   cValorIpi := T_TOTAIS->IPI
   cValorFin := T_DESCONTO->C7_DFIN
   cValorTot := cValorSub + cValorIpi - cValorFin

   DEFINE MSDIALOG oDlg TITLE "Totais do Pedido de Compra" FROM C(178),C(181) TO C(405),C(684) PIXEL

   @ C(005),C(005) Say "Nº P.Compra"                Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(043) Say "Fornecedor"                 Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Transportadora"             Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Totais do Pedido de Compra" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(067),C(036) Say "Sub-Total "                 Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(067),C(101) Say "Valor IPI"                  Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(067),C(142) Say "Desc. Financeiro"           Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(067),C(223) Say "Total PC"                   Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1  Var cPedido     When lChumba Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(043) MsGet oGet7  Var cFornec     When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(073) MsGet oGet8  Var cLoja       When lChumba Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(097) MsGet oGet2  Var cNomeF      When lChumba Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(036),C(005) MsGet oGet9  Var cTransp                  Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA4") VALID(__BTRANSP( cTransp ) )
   @ C(036),C(043) MsGet oGet10 Var cNomeT      When lChumba Size C(201),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(052),C(005) GET oMemo1   Var cLinha MEMO When lChumba Size C(239),C(001) PIXEL OF oDlg
   @ C(076),C(005) MsGet oGet3  Var cValorSub   When lChumba Size C(055),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg
   @ C(076),C(066) MsGet oGet4  Var cValorIpi   When lChumba Size C(055),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg
   @ C(076),C(128) MsGet oGet5  Var cValorFin                Size C(055),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg VALID(__CALCULO() )
   @ C(076),C(189) MsGet oGet6  Var cValorTot   When lChumba Size C(055),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg
   @ C(095),C(005) CheckBox oCheckBox1 Var lemail Prompt "Enviar e-mail ao departamento de recepção de mercadorias" Size C(151),C(008) PIXEL OF oDlg

   @ C(094),C(198) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( _GRAVAFECHA(SC7->C7_FILIAL, cPedido, cTransp, cValorFin ) )

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return .T.
                                       
// Função que pesquisa a transportadora pesquisada ou informada
Static Function __CALCULO()

   cValorTot := cValorSub + cValorIpi - cValorFin
   oGet6:Refresh()
   
Return .T.
   
// Função que pesquisa a transportadora pesquisada ou informada
Static Function __BTRANSP( _Frete )

   Local cSql := ""

   If Empty(Alltrim(_Frete))
      cNomeT := Space(40)
      Return .T.
   Endif

   If Select("T_FRETE") > 0
      T_FRETE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A4_NOME"
   cSql += "  FROM " + RetSqlName("SA4")
   cSql += " WHERE A4_COD       = '" + Alltrim(_Frete) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FRETE", .T., .T. )

   cNomeT := IIF(T_FRETE->( EOF() ), "", T_FRETE->A4_NOME)
   
Return .T.

// Função que atualiza o código da transportadora nos ítens do pedido de compra
Static Function _GRAVAFECHA( _Filial, _Pedido, _Frete, _DescFinanc )

   Local nContar   := 0
   Local nPosicao  := 0
   Local nPosFina  := 0
   Local cEmail    := ""
   Local cEndereco := ""

   nPosicao := aScan(aHeader,{|x| AllTrim(x[2])=="C7_TRANSP"})    
   nPosFina := aScan(aHeader,{|x| AllTrim(x[2])=="C7_DFIN"})  
 
   If !Empty(Alltrim(_Frete)) .AND. nPosicao !=0 .AND. nPosFina != 0

      For nContar = 1 to Len(aCols)
          
          If nPosicao != 0 
          	aCols[nContar, nPosicao] := _Frete
          EndIf
          
          If nPosFina != 0 .AND. !EMPTY(_DescFinanc)
          	aCols[nContar, nPosFina] := _DescFinanc
          EndIf

      Next nContar    
      
   Endif
   
   // Envia e-mail ao departamento de recepção de mercadorias caso solicitado
   If lEmail = .T.

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
         cEndereco := T_PARAMETROS->ZZ4_MERC
      Else
         cEndereco := ""
      Endif

      If !Empty(Alltrim(cEndereco))
         cEmail := ""
         cEmail := "Ao Departamento de Recepção de Mercadorias"
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Informamos que o Pedido de Compra de nº " + Alltrim(cPedido) + ", do fornecedor " + Alltrim(cFornec) + "." + Alltrim(cLoja) + " - " + Alltrim(cNomeF)
         cEmail += chr(13) + chr(10)
         cEmail += "possui um desconto financeiro no valor de R$ " + Transform(cValorFin," 999999999.99")
         cEmail += chr(13) + chr(10)
         cEmail += "Favor observar este desconto no momento da recepção da(s) mercadoria(s) deste pedido de compra."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Att."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Departamento de Compras"
         
         // Envia e-mail ao Aprovador
         U_AUTOMR20(cEmail, Alltrim(cEndereco), "", "Aviso de Desconto Financeiro" )
      Endif

   Endif

   oDlg:End()
   
Return .T.