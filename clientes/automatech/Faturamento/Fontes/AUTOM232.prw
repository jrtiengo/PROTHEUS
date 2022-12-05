#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM232.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/04/2014                                                          *
// Objetivo..: Programa que realiza o cálculo do DIFAL - Diferencial de Alíquota   *
// Parâmetros: __Filial   - Código da Filial                                       *
//             __Pedido   - Nº do Pedido, Proposta, Callcenter                     *  
//             __Item     - Nº do ítem do grid                                     *
//             __Produto  - Código do Produto                                      *
//             __Mostra   - 0 - Não Mostra Tela, 1 - Mostra a Tela                 *
//             __Chamado  - De onde foi chamado                                    *
//                          PC - Proposta Comecial                                 *
//                          CC - Call Center                                       *
//                          PV - Pedido de Venda                                   *
//             __Unitario - Preço Unitário do Produto                              *
//             __TES      - TES informada no Produto                               *
//**********************************************************************************

User Function AUTOM232( __Filial, __Pedido, __Item, __Produto, __Mostra, __Chamado, __Unitario, __TES)

   Local cSql       := ""
   Local nContar    := 0
   Local nRet       := 0
   Local nTotal     := 0
   Local nTConf     := 0
   Local cItem      := ""
   Local cProd      := ""
   Local cTes       := ""
   Local cOri       := ""
   lOCAL cNcm       := ""
   Local cCFOP      := ""
   Local _ALQINTEST := 0
   Local _ALQINT    := 0
   Local MV_ESTICM  := SuperGetMV("MV_ESTICM")
   Local cEst       := ""
   Local cTip       := ""
   Local cGrp       := ""
   Local cSol       := ""
   Local cIcm       := ""
   Local cGtp       := ""
   Local vPedido    := 0
   Local vFrete     := 0

   Local _ICMBASE   := 0
   Local _ALIBASE   := 0
   Local _ICMRETI   := 0
   Local _VALBASE   := 0
   Local _ALIRETI   := 0
   Local _VALRETI   := 0
   Local _CUSTENT   := 0
   Local _MVA       := 0
   Local _ALIQINT   := 0
   Local _TES       := ""
   Local _REDUCAO   := 0
   
   // Variáveis da tela do DIFAL
   Local lChumba     := .F.
   Local kCliente    := ""
   Local kEstado     := ""
   Local kTipoCli    := ""
   Local kTribCli    := ""
   Local kProduto    := ""
   Local kDescricao  := ""
   Local kTribPro    := ""
   Local kQuantidade := 0
   Local kUnitario 	 := 0
   Local kSubtotal   := 0
   Local kFrete  	 := 0
   Local kDifal  	 := 0
   Local kTES   	 := ""
   Local kSolidario	 := ""
   Local kICMS  	 := ""
   Local kCFOP  	 := ""
   Local kEstadual	 := 0
   Local kInterno	 := 0

   Local cMemo1	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""

   Local oGet10
   Local oGet11
   Local oGet12
   Local oGet13
   Local oGet14
   Local oGet15
   Local oGet16
   Local oGet17
   Local oGet18
   Local oGet19
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9

   Local oMemo1
   Local oMemo3
   Local oMemo4

   Private oDlgDET

   U_AUTOM628("AUTOM232")

   // PV - Pedido de Venda
   If __Chamado == "PV"

      // Pesquisa dados do Pedido de Venda
      If Select("T_CAMPOS") > 0
         T_CAMPOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "       SC6.C6_CLI    ,"
      cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SC6.C6_ITEM   ,"
      cSql += "       SC6.C6_PRODUTO,"
      cSql += "       SC6.C6_DESCRI ,"
      cSql += "       SC6.C6_QTDVEN ,"
      cSql += "       SC6.C6_PRCVEN ,"
      cSql += "       SC6.C6_VALOR  ,"
      cSql += "       SC6.C6_TES    ," 
      cSql += "       SC5.C5_EMISSAO,"
      cSql += "       SC5.C5_FRETE  ,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       SA1.A1_EST    ,"
      cSql += "       SA1.A1_TIPO   ,"
      cSql += "       SA1.A1_GRPTRIB "
      cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
      cSql += "       " + RetSqlName("SC5") + " SC5, "
      cSql += "       " + RetSqlName("SA1") + " SA1  "
      cSql += " WHERE SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SC6.C6_FILIAL  = '" + Alltrim(__Filial)  + "'"
      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(__Pedido)  + "'"
      cSql += "   AND SC6.C6_ITEM    = '" + Alltrim(__Item)    + "'"
      cSql += "   AND SC6.C6_PRODUTO = '" + Alltrim(__Produto) + "'"
      cSql += "   AND SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SC6.C6_FILIAL  = SC5.C5_FILIAL"
      cSql += "   AND SC6.C6_NUM     = SC5.C5_NUM   "
      cSql += "   AND SC5.D_E_L_E_T_ = ''           "
      cSql += "   AND SA1.A1_COD     = SC6.C6_CLI   "
      cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA  "
      cSql += "   AND SA1.D_E_L_E_T_ = ''           "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CAMPOS", .T., .T. )

      If T_CAMPOS->( EOF() )
	     Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
      Endif

   Endif

   // Estado do Cliente (UF)
   Do Case
      Case __Chamado == "PV"
           cEstado  := T_CAMPOS->A1_EST
      Case __Chamado == "PC"
           cEstado  := Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_EST")
      Case __Chamado == "CC"
           cEstado  := Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_EST")
   EndCase

   // Tipo de Cliente
   Do Case
      Case __Chamado == "PV"
           Do Case
              Case T_CAMPOS->A1_TIPO == "F"
                   cTipoCli := "F"
              Case T_CAMPOS->A1_TIPO == "L"
                   cTipoCli := "L"
              Case T_CAMPOS->A1_TIPO == "R"
                   cTipoCli := "R"
              Case T_CAMPOS->A1_TIPO == "S"
                   cTipoCli := "S"
              Case T_CAMPOS->A1_TIPO == "X"
                   cTipoCli := "X"
              Otherwise     
                   cTipoCli := ""
           EndCase        
      Case __Chamado == "PC"
           Do Case
              Case Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_TIPO") == "F"
                   cTipoCli := "F"
              Case Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_TIPO") == "L"
                   cTipoCli := "L"
              Case Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_TIPO") == "R"
                   cTipoCli := "R"
              Case Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_TIPO") == "S"
                   cTipoCli := "S"
              Case Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_TIPO") == "X"
                   cTipoCli := "X"
              Otherwise     
                   cTipoCli := ""
           EndCase        
      Case __Chamado == "CC"
           Do Case
              Case Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_TIPO") == "F"
                   cTipoCli := "F"
              Case Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_TIPO") == "L"
                   cTipoCli := "L"
              Case Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_TIPO") == "R"
                   cTipoCli := "R"
              Case Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_TIPO") == "S"
                   cTipoCli := "S"
              Case Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_TIPO") == "X"
                   cTipoCli := "X"
              Otherwise     
                   cTipoCli := ""
           EndCase        
   EndCase
   
   // Grupo Tributário do Cliente
   Do Case
      Case __Chamado == "PV"
           cGrpTrib := T_CAMPOS->A1_GRPTRIB
      Case __Chamado == "PC"     
           cGrpTrib := Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_GRPTRIB")
      Case __Chamado == "CC"     
           cGrpTrib := Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_GRPTRIB")
   EndCase

   // Captura o valor do Frete
   Do Case
      Case __Chamado == "PV"
           vFrete := T_CAMPOS->C5_FRETE
      Case __Chamado == "PC"   
           vFrete := M->ADY_FRETE
      Case __Chamado == "CC"   
           vFrete := M->UA_FRETE
   EndCase        

   // Calcula o ICM DIFAL para display
   cEst := cEstado
   cTip := cTipoCli
   cGrp := cGrpTrib
   cSol := ""
   cIcm := ""
   cGtp := ""

   // Rateia o Frete
   If vFrete > 0
      Do Case
         Case __Chamado == "PV"
              vFrete := Round(T_CAMPOS->C5_FRETE * Round((T_CAMPOS->C5_FRETE / T_CAMPOS->C6_PRCVEN) * 100,2) / 100,2)
         Case __Chamado == "PC"     
              vFrete := Round(M->ADY_FRETE * Round((M->ADY_FRETE / __Unitario) * 100,2) / 100,2)
         Case __Chamado == "CC"     
              vFrete := Round(M->UA_FRETE * Round((M->UA_FRETE / __Unitario) * 100,2) / 100,2)
      EndCase        
   Endif

   // Verifica se o Estado da Empresa Logada é diferente do estado do cliente
   If Alltrim(cEst) == Alltrim(SM0->M0_ESTENT)
	  Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
   Endif
 
   // Verifica se cliente é F = Consumidor Final
   If Alltrim(cTip) <> "F"
	  Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
   Endif

   // Verifica se IE do Cliente está Ativa
   If Alltrim(cGrp) <> "002"
	  Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
   Endif

   Do Case
      Case __Chamado == "PV"
           cTes  := T_CAMPOS->C6_TES
           cSol  := Posicione("SF4", 1, xFilial("SF4") + T_CAMPOS->C6_TES, "F4_INCSOL")
           cIcm  := Posicione("SF4", 1, xFilial("SF4") + T_CAMPOS->C6_TES, "F4_ICM")
           cCFOP := Posicione("SF4", 1, xFilial("SF4") + T_CAMPOS->C6_TES, "F4_CF")
      Case __Chamado == "PC"
           cTes  := __TES
           cSol  := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_INCSOL")
           cIcm  := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_ICM")
           cCFOP := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_CF")
      Case __Chamado == "CC"
           cTes  := __TES
           cSol  := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_INCSOL")
           cIcm  := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_ICM")
           cCFOP := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_CF")
   EndCase

   If cEst <> "CE"
      If Alltrim(cCfop) == "5102" .Or. Alltrim(cCfop) == "6102" .Or. Alltrim(cCfop) == ""
  	     Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
      Endif   
   Endif

   Do Case
      Case __Chamado == "PV"
           cPro := T_CAMPOS->C6_PRODUTO
           cGtp := Posicione("SB1", 1, xFilial("SB1") + T_CAMPOS->C6_PRODUTO, "B1_GRTRIB")
           cOri := Posicione("SB1", 1, xFilial("SB1") + T_CAMPOS->C6_PRODUTO, "B1_ORIGEM")
           cNcm := Posicione("SB1", 1, xFilial("SB1") + T_CAMPOS->C6_PRODUTO, "B1_POSIPI")
      Case __Chamado == "PC"
           cPro := __Produto
           cGtp := Posicione("SB1", 1, xFilial("SB1") + __Produto, "B1_GRTRIB")
           cOri := Posicione("SB1", 1, xFilial("SB1") + __Produto, "B1_ORIGEM")
           cNcm := Posicione("SB1", 1, xFilial("SB1") + __Produto, "B1_POSIPI")
      Case __Chamado == "CC"
           cPro := __Produto
           cGtp := Posicione("SB1", 1, xFilial("SB1") + __Produto, "B1_GRTRIB")
           cOri := Posicione("SB1", 1, xFilial("SB1") + __Produto, "B1_ORIGEM")
           cNcm := Posicione("SB1", 1, xFilial("SB1") + __Produto, "B1_POSIPI")
   EndCase

   // Verifica o ICM Solidário
   If !(cSol <> "S") .And. !(cIcm <> "S") .And. !(AllTrim( cGtp ) == "017")

      // Carrega a alíquota interestadual pela origem do produto
      Do Case
         Case cOri = "0"
   	          If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
                      
                 If cEst $ "RJ"			          
			        _ALQINTEST := 13
			     Endif   
			          			          
		      ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif

         Case cOri = "1"
		      _ALQINTEST := 4
         Case cOri = "2"
              _ALQINTEST := 4
         Case cOri = "3"
              _ALQINTEST := 4
         Case cOri = "4"
     	      If cEst $ "MG/PR/RJ/SC/SP"
		         _ALQINTEST := 12
		      ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
		         _ALQINTEST := 7
			  Endif
         Case cOri = "5"
  		      If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
			  ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif
         Case cOri = "6"
  		      If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
			  ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif
         Case cOri = "7"
  		      If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
			  ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif
	  EndCase        
		
      If cEst $ "MG/PR/SP"
	  	 _ALIQINT := 18
      ElseIf cEst $ "RJ"

	     _ALIQINT := 19

         If Substr(cNcm,01,04) == "8471"
            _ALIQINT := 13
    	 Endif                               

      ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RS/RO/RR/SC/SE/TO"
	   	  _ALIQINT := 17
	  EndIf

      // Verifica se existe execeção fiscal
   	  If (Select( "T_DETALHES" ) != 0 )
	     T_DETALHES->( DbCloseArea() )
	  EndIf

      cSql := ""
      cSql := "SELECT F7_ALIQDST,"
      cSql += "       F7_MARGEM  "
      cSql += "  FROM " + RetSqlName("SF7")
      cSql += " WHERE F7_GRTRIB  = '" + Alltrim(cGtp)      + "'"
      cSql += "   AND F7_EST     = '" + Alltrim(cEst)      + "'"
      cSql += "   AND F7_TIPOCLI = '" + Substr(cTip,01,01) + "'"
      cSql += "   AND F7_GRPCLI  = '" + Substr(cGrp,01,03) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
                   
  	  cSql := ChangeQuery( cSql )
 	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DETALHES",.T.,.T.)

      If T_DETALHES->( EOF() )
      Else

         _MVA := T_DETALHES->F7_MARGEM

         If T_DETALHES->F7_ALIQDST == 0
         Else
            If cEst == "RJ"
               _ALIQINT := T_DETALHES->F7_ALIQDST + 1
            Else
               _ALIQINT := T_DETALHES->F7_ALIQDST
            Endif   
         Endif
      Endif

	  If cEst == "RJ"
         If Substr(cNcm,01,04) == "8471"
            _ALIQINT := 13
  		 Endif                               
   	  Endif

      // Pesquisa o custo de entrada
   	  If Select("T_CUSENT") > 0
	   	 T_CUSENT->( dbCloseArea() )
	  EndIf

 	  cSql := ""
 	  cSql := "SELECT TOP 1 ROUND( ( D1_TOTAL + D1_VALIPI ) / D1_QUANT, 2 ) BASE1, D1_TES "
	  cSql += " FROM "+ RetSqlName("SD1")
	  cSql += " WHERE " 
	  cSql += " D_E_L_E_T_ = '' AND " 
	  cSql += " D1_PEDIDO <> '' AND " 
	  cSql += " D1_TIPO = 'N' AND " 
	  cSql += " D1_COD = '" + cProd + "' " 
	  cSql += " ORDER BY D1_EMISSAO DESC" 
	
	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSENT", .T., .T. )
 
	  If T_CUSENT->( EOF() )
		 _CUSTENT := 0
	  Else	
		 _CUSTENT := T_CUSENT->BASE1
 	  Endif

      // Aplica o cálculo e acumula (item)
      Do Case
         Case __Chamado == "PV"
    	      _VALRETI := ( T_CAMPOS->C6_PRCVEN * ( _ALIQINT / 100 ) ) - ( T_CAMPOS->C6_PRCVEN * ( _ALQINTEST / 100 ) )
         Case __Chamado == "PC"
    	      _VALRETI := ( __Unitario * ( _ALIQINT / 100 ) ) - ( __Unitario * ( _ALQINTEST / 100 ) )
         Case __Chamado == "CC"
    	      _VALRETI := ( __Unitario * ( _ALIQINT / 100 ) ) - ( __Unitario * ( _ALQINTEST / 100 ) )
      EndCase	      
    	      
      _ALIQINT := _ALIQINT
      _REDUCAO := _ALQINTEST	  

      // Se for estado do CE, zera o DIFAL
      If Alltrim(cEst) == "CE"
         nRet := 0
      Endif

   Endif      

   // Mostra os valores caso solicitado
   If __Mostra == 0
      Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
   Endif

   kCliente    := Alltrim(T_CAMPOS->C6_CLI) + "." + Alltrim(T_CAMPOS->C6_LOJA) + " - " + Alltrim(T_CAMPOS->A1_NOME)
   kEstado     := Alltrim(T_CAMPOS->A1_EST)
   kTipoCli    := cTipoCli
   kTribCli    := cGrpTrib
   kProduto    := T_CAMPOS->C6_PRODUTO
   kDescricao  := T_CAMPOS->C6_DESCRI
   kTribPro    := cGrp
   kQuantidade := T_CAMPOS->C6_QTDVEN
   kUnitario   := T_CAMPOS->C6_PRCVEN
   kSubtotal   := T_CAMPOS->C6_VALOR
   kFrete  	   := vFrete
   kDifal  	   := (_VALRETI * kQuantidade)
   kTES   	   := T_CAMPOS->C6_TES
   kSolidario  := cSol
   kICMS  	   := cIcm
   kCFOP  	   := cCfop
   kEstadual   := _ALQINTEST
   kInterno	   := _ALIQINT

   cMemo3 := ""
   cMemo3 := "1. Tipo de Cliente deve ser igual a F (Consumidor Final)" + chr(13) + chr(10)
   cMemo3 += "2. O grupo tributário do cliente deve ser igual a 002 (IE Ativa)" + chr(13) + chr(10)
   cMemo3 += "3. O estado (UF) do cliente deve ser diferente do estado emissor. Se o estado for igual a CE (Ceará), o cálculo não é realizado." + chr(13) + chr(10)
   cMemo3 += "4. O ICMS Solidário deve ser igual a S - Sim." + chr(13) + chr(10) 
   cMemo3 += "5. A indicação de cálculo de ICMS no TES deve estar igual a S - Sim." + chr(13) + chr(10) 
   cMemo3 += "6. Se o grupo tributário do produto for igual a 017, o cálculo não é realizado para o produto." + chr(13) + chr(10) 
   cMemo3 += "7. Alíquota Interestadual:"  + chr(13) + chr(10) 
   cMemo3 += "   Se Origem do produto = 0 e UF do Cliente = MG/PR/RJ/SC/SP, alíquota = 12%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 0 e UF do Cliente = RJ, alíquota = 13%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 0 e UF do cliente = AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO, alíquota = 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 1, alíquota = 4%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 2, alíquota = 4%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 3, alíquota = 4%"    + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 4 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 7%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 5 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 12%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 6 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 12%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 7 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 12%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "8. Alíquota Interna:" + chr(13) + chr(10)
   cMemo3 += "   Se estado do Cliente = MG/PR/SP, alíquota = 18%" + chr(13) + chr(10)
   cMemo3 += "   Se estado do Cliente = RJ, alíquota = 19%" + chr(13) + chr(10)
   cMemo3 += "   Se estado do Cliente = RJ e NCM do produto (4 dígitos) = 8471, alíquota = 13%" + chr(13) + chr(10)
   cMemo3 += "   Para os estados AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RS/RO/RR/SC/SE/TO, alíquota = 17%" + chr(13) + chr(10)
   cMemo3 += "9. Se existir execeção fiscal para o estado RJ e o NCM do produto (4 dígitos) forem diferentes de 8471, alíquota interna é a alíquota" + chr(13) + chr(10)
   cMemo3 += "   informada na execeção fiscal acrescida de mais 1%. Se NMC (4 dígitos) forem = a 8471, alíquota interna é = a 13%." + chr(13) + chr(10)
   cMemo3 += "   Para os demais estados, é alíquota interna é a alíquota informada na execeção fiscal." + chr(13) + chr(10)
   cMemo3 += "10. Cálculo do DIFAL: (Valor total do Produto * Alíquota Interna) - (Valor Total do Produto * Alíquota Interestadual)" + chr(13) + chr(10)

   DEFINE MSDIALOG oDlgDET TITLE "Regras Cálculo DIFAL" FROM C(178),C(181) TO C(634),C(959) PIXEL

   @ C(001),C(001) Jpeg FILE "logoautoma.bmp" Size C(131),C(033) PIXEL NOBORDER OF oDlgDET
   
   @ C(026),C(265) Say "VARIÁVEIS DE CÁLCULO ICMS RETIDO (DIFAL)" Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(040),C(005) Say "Cliente"                                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(040),C(159) Say "UF"                                       Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(040),C(179) Say "Tipo de Cliente"                          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(040),C(277) Say "Grupo Tributário"                         Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(061),C(005) Say "Produto"                                  Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(061),C(066) Say "Descrição do Produto"                     Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(061),C(277) Say "Grp Tributário Produto"                   Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(061),C(366) Say "TES"                                      Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(005) Say "Quantidade"                               Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(035) Say "Unitário"                                 Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(131) Say "Frete"                                    Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(179) Say "DIFAL"                                    Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(227) Say "Total"                                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(277) Say "Solid."                                   Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(298) Say "ICMS"                                     Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(316) Say "CFOP"                                     Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(340) Say "Alq.IEst."                                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(082),C(364) Say "Alq.Int."                                 Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(083),C(083) Say "Sub-Total"                                Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET
   @ C(109),C(005) Say "Regras de Cálculo do ICMS DIFAL"          Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlgDET

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlgDET
   @ C(106),C(005) GET oMemo4 Var cMemo4 MEMO Size C(382),C(001) PIXEL OF oDlgDET
   @ C(118),C(005) GET oMemo3 Var cMemo3 MEMO Size C(383),C(090) PIXEL OF oDlgDET

   kTotal := kSubTotal + kFrete + kDifal

   Do Case
      Case kTipoCli == "F"
           kTipoCli := "F - Consumidor Final"
      Case kTipoCli == "L"
           kTipoCli := "L - Produtor Rural"
      Case kTipoCli == "R"
           kTipoCli := "R - Revendedor"
      Case kTipoCli == "S"
           kTipoCli := "S - Solidário"
      Case kTipoCli == "X"
           kTipoCli := "X - Exportação"
   EndCase

   @ C(049),C(005) MsGet oGet2  Var kCLiente    When lChumba Size C(150),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(049),C(159) MsGet oGet3  Var kEstado     When lChumba Size C(014),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(049),C(179) MsGet oGet4  Var kTipoCli    When lChumba Size C(092),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(049),C(277) MsGet oGet5  Var kTribCli    When lChumba Size C(107),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(070),C(005) MsGet oGet6  Var kProduto    When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(070),C(066) MsGet oGet7  Var kDescricao  When lChumba Size C(204),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(070),C(277) MsGet oGet10 Var kTribPro    When lChumba Size C(084),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(070),C(366) MsGet oGet11 Var kTES        When lChumba Size C(018),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(092),C(005) MsGet oGet13 Var kQuantidade When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgDET
   @ C(092),C(035) MsGet oGet14 Var kUnitario   When lChumba Size C(040),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgDET
   @ C(092),C(083) MsGet oGet15 Var kSubtotal   When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgDET
   @ C(092),C(131) MsGet oGet16 Var kFrete      When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgDET
   @ C(092),C(179) MsGet oGet17 Var kDifal      When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgDET
   @ C(092),C(227) MsGet oGet20 Var kTotal      When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgDET
   @ C(092),C(277) MsGet oGet8  Var kSolidario  When lChumba Size C(009),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(092),C(298) MsGet oGet9  Var kICMS       When lChumba Size C(009),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(092),C(316) MsGet oGet12 Var kCFOP       When lChumba Size C(006),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgDET
   @ C(092),C(340) MsGet oGet18 Var kEstadual   When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@E 99"           PIXEL OF oDlgDET
   @ C(092),C(364) MsGet oGet19 Var kInterno    When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@E 99"           PIXEL OF oDlgDET

   @ C(212),C(348) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDET ACTION( oDlgDET:End() )

   ACTIVATE MSDIALOG oDlgDET CENTERED 

Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )